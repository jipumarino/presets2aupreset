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
