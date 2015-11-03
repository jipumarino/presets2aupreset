#!/usr/bin/env ruby

require 'plist'
require 'zlib'
require 'pathname'


def convert_uhe_presets(plugin)
  plist = Plist::parse_xml("default_aupresets/#{plugin}.aupreset")

  if plist.nil?
    puts "Missing default file for #{plugin}"
    return
  end

  patches_base_dir = Pathname.new("/Library/Audio/Presets/u-he/#{plugin}")
  converted_base_dir = "./converted/#{plugin}"
  FileUtils.mkdir_p(converted_base_dir)
  File.write(File.join(converted_base_dir, "Default.aupreset"), plist.to_plist)

  Dir[File.join(patches_base_dir, '**/*.h2p')].each do |patch_file|
    relative_path = Pathname.new(patch_file).relative_path_from(patches_base_dir)
    dir_name = File.dirname(relative_path)
    patch_name = File.basename(patch_file, ".h2p")
    aupreset_file = File.join(converted_base_dir, dir_name, patch_name + ".aupreset")

    original_patch_content = File.open(patch_file, "r:ISO-8859-1", &:read)
    plist["AM_STATE"] = StringIO.new(original_patch_content)
    plist["name"] = patch_name

    FileUtils.mkdir_p(File.dirname(aupreset_file))

    File.write(aupreset_file, plist.to_plist)

  end

end

def convert_karmafx_presets(plugin)
  plist = Plist::parse_xml("default_aupresets/#{plugin}.aupreset")

  if plist.nil?
    puts "Missing default file for #{plugin}"
    return
  end

  patches_base_dir = Pathname.new("/Library/Application Support/KarmaFX/KarmaFX Synth/Patches")
  converted_base_dir = "./converted/#{plugin}"
  FileUtils.mkdir_p(converted_base_dir)
  File.write(File.join(converted_base_dir, "Default.aupreset"), plist.to_plist)

  Dir[File.join(patches_base_dir, '**/*.kfx')].each do |patch_file|
    relative_path = Pathname.new(patch_file).relative_path_from(patches_base_dir)
    dir_name = File.dirname(relative_path)
    patch_name = File.basename(patch_file, ".kfx")
    aupreset_file = File.join(converted_base_dir, dir_name, patch_name + ".aupreset")

    original_patch_content = File.read(patch_file)
    plist["KFXS"] = StringIO.new(original_patch_content)
    plist["name"] = patch_name

    FileUtils.mkdir_p(File.dirname(aupreset_file))

    File.write(aupreset_file, plist.to_plist)

  end

end

def convert_aalto_presets(plugin)
  plist = Plist::parse_xml("default_aupresets/#{plugin}.aupreset")

  if plist.nil?
    puts "Missing default file for #{plugin}"
    return
  end

  patches_base_dir = Pathname.new("/Users/juan/Music/Madrona Labs/Aalto")
  converted_base_dir = "./converted/#{plugin}"
  FileUtils.mkdir_p(converted_base_dir)
  File.write(File.join(converted_base_dir, "Default.aupreset"), plist.to_plist)

  Dir[File.join(patches_base_dir, '**/*.mlpreset')].each do |patch_file|
    relative_path = Pathname.new(patch_file).relative_path_from(patches_base_dir)
    dir_name = File.dirname(relative_path)
    patch_name = File.basename(patch_file, ".mlpreset")
    aupreset_file = File.join(converted_base_dir, dir_name, patch_name + ".aupreset")

    original_patch_content = File.open(patch_file, "r:ISO-8859-1", &:read)

    plist["jucePluginState"] = StringIO.new('{"patch": ' + original_patch_content + "}")
    plist["name"] = patch_name

    FileUtils.mkdir_p(File.dirname(aupreset_file))

    File.write(aupreset_file, plist.to_plist)

  end

end

def convert_sunrizer_presets(plugin)
  plist = Plist::parse_xml("default_aupresets/#{plugin}.aupreset")

  if plist.nil?
    puts "Missing default file for #{plugin}"
    return
  end

  patches_base_dir = Pathname.new("/Users/juan/Library/Application Support/Beepstreet/Sunrizer/Banks/")
  converted_base_dir = "./converted/#{plugin}"
  FileUtils.mkdir_p(converted_base_dir)
  File.write(File.join(converted_base_dir, "Default.aupreset"), plist.to_plist)

  Dir[File.join(patches_base_dir, '**/*.srb')].each do |bank_file|
    Plist::parse_xml(bank_file).each do |original_patch_content|
      relative_path = Pathname.new(bank_file).relative_path_from(patches_base_dir)
      dir_name = File.basename(relative_path, ".srb")
      patch_name = original_patch_content["name"]
      aupreset_file = File.join(converted_base_dir, dir_name, patch_name + ".aupreset")

      plist["jucePluginState"] = StringIO.new(original_patch_content.to_plist)
      plist["name"] = patch_name

      FileUtils.mkdir_p(File.dirname(aupreset_file))

      File.write(aupreset_file, plist.to_plist)
    end

  end

end

[
  # 'ACE',
  # 'Bazille',
  # 'Diva',
  # 'Hive',
  # 'Satin',
  # 'TyrellN6',
  # 'Zebra2',
  # 'ZebraHZ',
  # 'Zebralette',
].each do |plugin|
  convert_uhe_presets(plugin)
end

# convert_aalto_presets('Aalto')

# convert_sunrizer_presets('Sunrizer')

# convert_karmafx_presets('KarmaFX Synth')

# Done:
# Aalto.component
# ACE.component
# Bazille.component
# Diva.component
# Hive.component
# TyrellN6.component
# Zebra2.component
# ZebraHZ.component
# Sunrizer.component

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

