# GasoCan launcher artwork

`app_icon.png` is the selected full-background artwork, created with the built-in
image generation tool. The OS supplies the outer mask.

Final brief: a larger, centered white fuel dispenser; a simple U-shaped hose and
recognizable nozzle; clear display cutout; opaque blue background; no text,
shadow, bevel or outer rounded corners.

`ic_launcher_foreground.xml` is the Android vector adaptation. Adaptive and
monochrome icons share transparent display/handle cutouts and a 16% safe inset.

Run `python3 generate_icon.py` from the project to export all configured platform
sizes and install Android vector layers. It exports the selected source artwork
without redrawing it.
