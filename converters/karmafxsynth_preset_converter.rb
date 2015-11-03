class KarmaFXSynthPresetConverter < PresetConverter
  config(
    grouping: :patches,
    extension: "kfx",
    data_field: "KFXS",
    binary: true,
  )
end