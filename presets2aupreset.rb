#!/usr/bin/env ruby

require 'plist'
require 'zlib'
require 'pathname'
require 'active_support/all'

class PresetConverter

  PLUGINS_CONFIG = {
    'ACE' => {
      patches_base_dir: "/Library/Audio/Presets/u-he/ACE",
    },
    'Bazille' => {
      patches_base_dir: "/Library/Audio/Presets/u-he/Bazille",
    },
    'Diva' => {
      patches_base_dir: "/Library/Audio/Presets/u-he/Diva",
    },
    'Hive' => {
      patches_base_dir: "/Library/Audio/Presets/u-he/Hive",
    },
    'TyrellN6' => {
      patches_base_dir: "/Library/Audio/Presets/u-he/TyrellN6",
    },
    'Zebra2' => {
      patches_base_dir: "/Library/Audio/Presets/u-he/Zebra2",
    },
    'ZebraHZ' => {
      patches_base_dir: "/Library/Audio/Presets/u-he/ZebraHZ",
    },
    'Zebralette' => {
      patches_base_dir: "/Library/Audio/Presets/u-he/Zebralette",
    },
    'KarmaFX Synth' => {
      patches_base_dir: "/Library/Application Support/KarmaFX/KarmaFX Synth/Patches",
    },
    'Aalto' => {
      patches_base_dir: "/Users/juan/Music/Madrona Labs/Aalto",
    },
    'Sunrizer' => {
      patches_base_dir: "/Users/juan/Library/Application Support/Beepstreet/Sunrizer/Banks/",
    },
  }

  def initialize(plugin)
    @plugin = plugin
    load_config
    @config = PLUGINS_CONFIG[@plugin]
    raise "Missing config for plugin #{@plugin}" if @config.nil?
    @default_plist = Plist::parse_xml("default_aupresets/#{@plugin}.aupreset")
    raise "Missing default file for plugin #{@plugin}" if @default_plist.nil?
    @converted_base_dir = File.join(".", "converted", @plugin)
    @patches_base_dir = Pathname.new(@config[:patches_base_dir])
    raise "Missing extension for plugin #{@plugin}" if @extension.nil?
    raise "Missing data_field for plugin #{@plugin}" if @data_field.nil?
    raise "Invalid bank_format #{@bank_format} for plugin #{@plugin}" unless %i(plist).include?(@bank_format) || @bank_format.nil?
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

  def self.get_converter_class(plugin)
  end

end

class PresetConverterInstantiator
  def self.get_converter(plugin)
    "#{plugin}PresetConverter".delete(" ").safe_constantize.new(plugin)
  end
end

class UhePresetConverter < PresetConverter
  def load_config
    @grouping = :patches
    @extension = "h2p"
    @data_field = "AM_STATE"
  end
end
class ACEPresetConverter < UhePresetConverter; end
class BazillePresetConverter < UhePresetConverter; end
class DivaPresetConverter < UhePresetConverter; end
class HivePresetConverter < UhePresetConverter; end
class TyrellN6PresetConverter < UhePresetConverter; end
class Zebra2PresetConverter < UhePresetConverter; end
class ZebraHZPresetConverter < UhePresetConverter; end
class ZebralettePresetConverter < UhePresetConverter; end

class KarmaFXPresetConverter < PresetConverter
  def load_config
    @grouping = :patches
    @extension = "kfx"
    @data_field = "KFXS"
    @binary = true
  end
end

class AaltoPresetConverter < PresetConverter
  def load_config
    @grouping = :patches
    @extension = "mlpreset"
    @data_field = "jucePluginState"
  end

  def patch_content_wrapper(content)
    '{"patch": ' + content + "}"
  end
end

class SunrizerPresetConverter < PresetConverter
  def load_config
    @grouping = :banks
    @extension = "srb"
    @data_field = "jucePluginState"
    @bank_format = :plist
  end

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
