Convert AudioUnit plugins presets from various vendors to the standard aupreset file format so they can be used with Ableton Live and other DAWs.

# Usage
The script converts all presets for a particular plugin from the location specified in config.yml (you need to create your own config based on the example provided) and puts them inside the converted directory. For example, for converting U-He's Diva presets:

```
bundle exec ruby presets2aupreset Diva
```

# TODO
- Specify presets destination in command
- Extract common code between grouping patches/banks
- Validate directories existence

# Pending plugins
- SynthMaster2
- XILS 4
- Z3TA+ 2
- chipsounds
- minimoogVOriginalAU
- Reaktor 6
