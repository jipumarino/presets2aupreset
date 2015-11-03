#!/usr/bin/env ruby

require 'active_support/all'
require 'json'
require 'pathname'
require 'plist'
require 'yaml'

class PresetConverter
  class_attribute :settings

  PLUGINS_CONFIG = YAML.load_file("config.yml").with_indifferent_access

  def initialize(plugin)
    @plugin = plugin
    @config = PLUGINS_CONFIG[@plugin]
    raise "Missing config for plugin #{@plugin}" if @config.nil?

    @config.merge!(self.class.settings)

    @default_plist = Plist::parse_xml("default_aupresets/#{@plugin}.aupreset")
    raise "Missing default file for plugin #{@plugin}" if @default_plist.nil?

    @converted_base_dir = File.join(".", "converted", @plugin)
    @patches_base_dir = Pathname.new(@config[:patches_base_dir])

    @extension = @config[:extension]
    raise "Missing extension for plugin #{@plugin}" if @extension.nil?

    @data_field = @config[:data_field]
    raise "Missing data_field for plugin #{@plugin}" if @data_field.nil?

    @bank_format = @config[:bank_format]
    raise "Invalid bank_format #{@bank_format} for plugin #{@plugin}" unless %i(plist).include?(@bank_format) || @bank_format.nil?

    @grouping = @config[:grouping]
    raise "Invalid grouping #{@grouping} for plugin #{@plugin}" unless %i(patches banks).include?(@grouping)
  end

  def run
    FileUtils.mkdir_p(@converted_base_dir)
    File.write(File.join(@converted_base_dir, "Default.aupreset"), @default_plist.to_plist)
    if @grouping == :patches
      Dir[File.join(@patches_base_dir, "**/*.#{@extension}")].each do |patch_file|
        relative_path = Pathname.new(patch_file).relative_path_from(@patches_base_dir)
        dir_name = File.dirname(relative_path)
        patch_name = File.basename(patch_file, ".#{@extension}")
        aupreset_file = File.join(@converted_base_dir, dir_name, patch_name + ".aupreset")
        original_patch_content = @binary ? File.read(patch_file) : File.open(patch_file, "r:ISO-8859-1", &:read)
        @default_plist[@data_field] = StringIO.new(patch_content_wrapper(original_patch_content))
        @default_plist["name"] = patch_name
        FileUtils.mkdir_p(File.dirname(aupreset_file))
        File.write(aupreset_file, @default_plist.to_plist)
      end
    elsif @grouping == :banks
      Dir[File.join(@patches_base_dir, "**/*.#{@extension}")].each do |bank_file|
        if @bank_format == :plist
          Plist::parse_xml(bank_file).each do |original_patch_content|
            relative_path = Pathname.new(bank_file).relative_path_from(@patches_base_dir)
            dir_name = File.basename(relative_path, @extension)
            patch_name = name_extractor(original_patch_content)
            aupreset_file = File.join(@converted_base_dir, dir_name, patch_name + ".aupreset")
            @default_plist[@data_field] = StringIO.new(patch_content_wrapper(original_patch_content))
            @default_plist["name"] = patch_name
            FileUtils.mkdir_p(File.dirname(aupreset_file))
            File.write(aupreset_file, @default_plist.to_plist)
          end
        end
      end
    end
  end

  def patch_content_wrapper(content)
    content
  end

  def name_extractor(content)
    raise "Must implement method"
  end

  def self.config(hash)
    self.settings = hash
  end

end

class PresetConverterInstantiator
  def self.get_converter(plugin)
    klass_name = "#{plugin}PresetConverter".delete(" ")
    klass = klass_name.safe_constantize
    raise "Missing converter class #{klass_name} for #{plugin}" if klass.nil?
    klass.new(plugin)
  end
end

class UhePresetConverter < PresetConverter
  config(
    grouping: :patches,
    extension: "h2p",
    data_field: "AM_STATE",
  )
end
class ACEPresetConverter < UhePresetConverter; end
class BazillePresetConverter < UhePresetConverter; end
class DivaPresetConverter < UhePresetConverter; end
class HivePresetConverter < UhePresetConverter; end
class SatinPresetConverter < UhePresetConverter; end
class TyrellN6PresetConverter < UhePresetConverter; end
class Zebra2PresetConverter < UhePresetConverter; end
class ZebraHZPresetConverter < UhePresetConverter; end
class ZebralettePresetConverter < UhePresetConverter; end

class KarmaFXSynthPresetConverter < PresetConverter
  config(
    grouping: :patches,
    extension: "kfx",
    data_field: "KFXS",
    binary: true,
  )
end

class AaltoPresetConverter < PresetConverter
  config(
    grouping: :patches,
    extension: "mlpreset",
    data_field: "jucePluginState",
  )

  def patch_content_wrapper(content)
    '{"patch": ' + content + "}"
  end
end

class SunrizerPresetConverter < PresetConverter
  config(
    grouping: :banks,
    extension: "srb",
    data_field: "jucePluginState",
    bank_format: :plist,
  )

  def patch_content_wrapper(content)
    content.to_plist
  end

  def name_extractor(content)
    content["name"]
  end
end

[
  'ACE',
  'Bazille',
  'Diva',
  'Hive',
  'Satin',
  'TyrellN6',
  'Zebra2',
  'ZebraHZ',
  'Zebralette',
  'Aalto',
  'KarmaFX Synth',
  'Sunrizer',
].each do |plugin|
  PresetConverterInstantiator.get_converter(plugin).run
end
