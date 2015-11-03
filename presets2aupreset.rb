#!/usr/bin/env ruby

require 'plist'
require 'zlib'
require 'pathname'

class PresetConverter

  PLUGINS_CONFIG = {
    'ACE' => {
      patches_base_dir: "/Library/Audio/Presets/u-he/ACE",
      grouping: :patches,
      extension: "h2p",
      data_field: "AM_STATE",
    },
    'Bazille' => {
      patches_base_dir: "/Library/Audio/Presets/u-he/Bazille",
      grouping: :patches,
      extension: "h2p",
      data_field: "AM_STATE",
    },
    'Diva' => {
      patches_base_dir: "/Library/Audio/Presets/u-he/Diva",
      grouping: :patches,
      extension: "h2p",
      data_field: "AM_STATE",
    },
    'Hive' => {
      patches_base_dir: "/Library/Audio/Presets/u-he/Hive",
      grouping: :patches,
      extension: "h2p",
      data_field: "AM_STATE",
    },
    'TyrellN6' => {
      patches_base_dir: "/Library/Audio/Presets/u-he/TyrellN6",
      grouping: :patches,
      extension: "h2p",
      data_field: "AM_STATE",
    },
    'Zebra2' => {
      patches_base_dir: "/Library/Audio/Presets/u-he/Zebra2",
      grouping: :patches,
      extension: "h2p",
      data_field: "AM_STATE",
    },
    'ZebraHZ' => {
      patches_base_dir: "/Library/Audio/Presets/u-he/ZebraHZ",
      grouping: :patches,
      extension: "h2p",
      data_field: "AM_STATE",
    },
    'Zebralette' => {
      patches_base_dir: "/Library/Audio/Presets/u-he/Zebralette",
      grouping: :patches,
      extension: "h2p",
      data_field: "AM_STATE",
    },
    'KarmaFX Synth' => {
      patches_base_dir: "/Library/Application Support/KarmaFX/KarmaFX Synth/Patches",
      grouping: :patches,
      extension: "kfx",
      data_field: "KFXS",
      binary: true,
    },
    'Aalto' => {
      patches_base_dir: "/Users/juan/Music/Madrona Labs/Aalto",
      grouping: :patches,
      extension: "mlpreset",
      data_field: "jucePluginState",
    },
    'Sunrizer' => {
      patches_base_dir: "/Users/juan/Library/Application Support/Beepstreet/Sunrizer/Banks/",
      grouping: :banks,
      extension: "srb",
      data_field: "jucePluginState",
      bank_format: :plist,
    },

  }

  def initialize(plugin)
    @plugin = plugin
    @config = PLUGINS_CONFIG[@plugin]
    raise "Missing config for plugin #{@plugin}" if @config.nil?
    @plist = Plist::parse_xml("default_aupresets/#{@plugin}.aupreset")
    raise "Missing default file for plugin #{@plugin}" if @plist.nil?
    @converted_base_dir = File.join(".", "converted", @plugin)
    @patches_base_dir = Pathname.new(@config[:patches_base_dir])
    @extension = @config[:extension]
    raise "Missing extension for plugin #{@plugin}" if @extension.nil?
    @data_field = @config[:data_field]
    raise "Missing data_field for plugin #{@plugin}" if @data_field.nil?
    @bank_format = @config[:bank_format]
    raise "Invalid bank_format for plugin #{@plugin}" unless %i(plist).include?(@bank_format)
    @grouping = @config[:grouping]
    raise "Invalid grouping #{@grouping} for plugin #{@plugin}" unless %i(patches banks).include?(@grouping)
    @binary = !!@config[:binary]
  end

  def run
    FileUtils.mkdir_p(@converted_base_dir)
    File.write(File.join(converted_base_dir, "Default.aupreset"), plist.to_plist)
    if @grouping == :patches
      Dir[File.join(patches_base_dir, "**/*.#{@extension}")].each do |patch_file|
        relative_path = Pathname.new(patch_file).relative_path_from(@patches_base_dir)
        dir_name = File.dirname(relative_path)
        patch_name = File.basename(patch_file, ".#{@extension}")
        aupreset_file = File.join(converted_base_dir, dir_name, patch_name + ".aupreset")
        original_patch_content = @binary ? File.read(patch_file) : File.open(patch_file, "r:ISO-8859-1", &:read)
        plist[@data_field] = StringIO.new(patch_content_wrapper(original_patch_content))
        plist["name"] = patch_name
        FileUtils.mkdir_p(File.dirname(aupreset_file))
        File.write(aupreset_file, plist.to_plist)
      end
    elsif @grouping == :banks
      Dir[File.join(patches_base_dir, "**/*.#{@extension}")].each do |bank_file|
        if @bank_format == :plist
          Plist::parse_xml(bank_file).each do |original_patch_content|
            relative_path = Pathname.new(bank_file).relative_path_from(patches_base_dir)
            dir_name = File.basename(relative_path, @extension)
            patch_name = name_extractor(original_patch_content)
            aupreset_file = File.join(converted_base_dir, dir_name, patch_name + ".aupreset")
            plist[@data_field] = StringIO.new(patch_content_wrapper(original_patch_content))
            plist["name"] = patch_name
            FileUtils.mkdir_p(File.dirname(aupreset_file))
            File.write(aupreset_file, plist.to_plist)
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

class UhePresetConverter < PresetConverter; end
class ACEPresetConverter < UhePresetConverter; end
class BazillePresetConverter < UhePresetConverter; end
class DivaPresetConverter < UhePresetConverter; end
class HivePresetConverter < UhePresetConverter; end
class TyrellN6PresetConverter < UhePresetConverter; end
class Zebra2PresetConverter < UhePresetConverter; end
class ZebraHZPresetConverter < UhePresetConverter; end
class ZebralettePresetConverter < UhePresetConverter; end

class KarmaFXPresetConverter < PresetConverter; end

class AaltoPresetConverter < PresetConverter
  def patch_content_wrapper(content)
    '{"patch": ' + content + "}"
  end
end

class SunrizerPresetConverter < PresetConverter
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

end

# Wat
# Satin.component !!!!!

# SynthMaster2.component
# XILS 4.component
# Z3TA+ 2.component
# Dexed.component
# KarmaFX Synth.component
# ComboF.component
# chipsounds.component
# minimoogVOriginalAU.component
# Reaktor 6.component

