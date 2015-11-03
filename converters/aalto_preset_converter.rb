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
