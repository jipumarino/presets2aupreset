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
