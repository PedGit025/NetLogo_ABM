## WHAT IS IT?

This model simulates rainfall-induced landslides on a psuedo sloped terrain. it shows the effect of continued rainfall leads to soil saturation, terrain instability, sediment flow, and vegetation loss. The model is intended to help understand the dynamics of landslide under different environmental conditions such as rainfall intensity, sediment threshold and vegetation.

## HOW IT WORKS

The model uses an agent-based approach with two main types of agents:
- **Patches** represent units of terrain and hold information about elevation, soil saturation, sediment, and IF they have experienced a landslide.
- **Turtles** represent trees that grow on patches with sufficiently high elevation. Trees are removed if a landslide happen on the same patch. Trees are pulsing green to visually see trees are absorbing water, pulsing black indicating the patch used to have a tree but is not landslid.

Each tick (time step), the model performs the following actions:
1. **Rainfall** increases soil saturation across all patches.
2. **Saturation Check** limits saturation at 100%.
3. **Sediment Flow** moves sediments from failed patches to lower neighboring patches.
4. **Landslide Check** compares slope and saturation to determine if a patch becomes unstable. If stability falls below the user-defined (landslide-threshold slider) threshold, a landslide is triggered.
5. **Landslide Effects** include elevation loss, color change (to brown, from white/green), added sediment, and tree removal.
6. **Monitors and Plots** update total rainfall, landslides, sediment, and remaining trees.

The simulation stops when all terrain patches have failed.

## HOW TO USE IT

Use the sliders to adjust params and click the buttons in the Interface tab to configure and run the model:

**Sliders:**
  `rainfall-rate`: Controls how much rain (in mm) falls per tick.
  `landslide-threshold`: Determines how easily patches fail (lower = more frequent landslides).
  `sediment-flow-rate`: Controls how much sediment is transferred downhill during landslides.
  `number-of-trees`: Sets the initial number of tree agents on the terrain.

**Buttons:**
  `setup`: __init__ the environment and plants the trees.
  `go`: Runs the simulation continuously until manually stopped or the terrain fully fails.

**Monitors:**
  `total-trees`: Number of surviving trees.
  `total-rainfall`: Accumulated rainfall.
  `total-landslides`: Total number of landslides that occurred.
  `total-sediment`: Total sediment moved due to landslides.

**Plots:**
  `Landslide Stats`: Tracks number of landslides over time.
  `Rainfall Stats`: Tracks cumulative rainfall.
  `Sediment Stats`: Tracks sediment accumulation.

## THINGS TO NOTICE

Observe how saturation levels increase and eventually trigger landslides.

Watch how landslides change the terrain (brown color) and reduce elevation.

See how sediment flows to neighboring patches after failure.

Monitor the survival of tree and patch agents as the environment degrades.

## THINGS TO TRY

1.Increase the `rainfall-rate` to simulate heavy storms and observe faster failure AVERAGE 20 mm of rain.

2.Lower the `landslide-threshold` to simulate weaker terrain and trigger early landslides.

3.Increase `number-of-trees` and observe if more vegetation delays or prevents slope failure.

4.Adjust `sediment-flow-rate` to study how erosion and deposition patterns change.

## EXTENDING THE MODEL

Here are some possible extensions;

- Add actual DEM data to simulate possible landslide.

- fix Model's soil based from actual data or location.

- Sediment collision.

- Resistance from landslide through trees

## NETLOGO FEATURES

Uses `patches-own` and `turtles-own` variables to store agent states.

- Applies `neighbors with` for localized sediment flow.
- Employs elevation-based pseudo-slope using `(100 - pxcor)` to simulate downhill terrain.
- Uses visual color scaling and `pcolor` to indicate environmental changes (e.g.,white to - brown or green to brown, the higher the slope the white it is).

## RELATED MODELS

**NetLogo Models Library**:

"Fire" – similar behavior of spreading through an environment.

"Forest Fire" – vegetation and environmental interactions.

## CREDITS AND REFERENCES

Created by CA group 1 Grad/Undergrad,De La Salle University Manila, as part of our agent based modeling project in CA class CSC931M G01.

For educational use. No external datasets or libraries were used.

The model idea was inspired by the frequent occurrence of landslides in the Philippines, particularly during the rainy season. Mountainous regions that are heavily deforested or exploited for natural resources are prone to such.

This model aims to simulate and better understand how rainfall, vegetation, and terrain interact to contribute to landslides.

## Created By

Created by: 

https://github.com/jrcala7
https://github.com/PedGit025
https://github.com/jasgayamo
