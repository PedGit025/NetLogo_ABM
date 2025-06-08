globals [
  total-rainfall         ; mm of rainfall over all patches
  total-landslides       ; number of landslide events
  total-sediment         ; kg or unitless measure of sediment moved
  total-trees            ; number of remaining trees (turtles)
]

patches-own [
  elevation              ; terrain height (unitless or meters if scaled)
  saturation             ; % saturation (0–100)
  sediment               ; kg or unitless sediment on patch
  failed?                ; has landslide occurred here?
]

turtles-own [
  tree?
]

; Slider: "rainfall-rate" [0, 5] (mm per tick) – controls rainfall per time step
; Slider: "landslide-threshold" [0, 100] (stability score threshold)
; Slider: "sediment-flow-rate" [0, 1] (fraction of sediment moved per tick)
; Slider: "number-of-trees" [0, 800] (number of tree turtles to create)

to setup
  clear-all
  set-default-shape turtles "tree"

  ; Initialize terrain
  ask patches [
    set elevation (100 - pxcor) + random-float 20   ; pseudo-slope
    set pcolor scale-color green elevation 0 100
    set saturation 0
    set sediment 0
    set failed? false
  ]

  ; Create tree turtles
  create-turtles number-of-trees [
    set tree? true
    set color brown

    let target-patch one-of patches with [elevation > 50]
    if target-patch != nobody [
      move-to target-patch
    ]
  ]

  set total-rainfall 0
  set total-landslides 0
  set total-sediment 0
  set total-trees number-of-trees

  reset-ticks
end

to go
  ; print (word "Tick: " ticks " | Trees: " count turtles with [tree?])
  rain
  saturate
  flow-sediment
  check-landslide
  deposit-sediment
  update-monitor

  tick
  wait 0.1

  ; Stop if all patches are brown (landslide occurred everywhere)
  if all? patches [pcolor = brown] [
    user-message "Simulation stopped: All terrain has failed (fully landslided)."
    stop
  ]


end

to rain ; Apply rainfall to all patches

  ask patches [
    set saturation saturation + rainfall-rate
  ]

  set total-rainfall total-rainfall + rainfall-rate ; Track total rainfall realistically (mm per tick, not per patch)
end


to saturate
  ask patches [
    if saturation > 100 [ set saturation 100 ] ; cap saturation to 100%
  ]
end

to flow-sediment
  ask patches [
    if failed? [
      let neighbors-with-slope neighbors with [elevation < [elevation] of self]
      if any? neighbors-with-slope [
        let target one-of neighbors-with-slope
        ask target [
          set sediment sediment + sediment-flow-rate  ; sediment-flow-rate is a fraction
        ]
      ]
    ]
  ]
end

to check-landslide
  ; Try each patch in random order, find the first vulnerable one
  let vulnerable-patch nobody

  ask one-of patches with [not failed?] [
    let slope (elevation - [elevation] of patch-at -1 0)
    let stability (slope - (saturation / 2))

    if stability < landslide-threshold [
      set vulnerable-patch self
    ]
  ]

  if vulnerable-patch != nobody [
    ask vulnerable-patch [ trigger-landslide ]
  ]
end



to trigger-landslide
  set pcolor brown
  set failed? true
  set saturation 0
  set sediment sediment + 5           ; 5 kg or units of sediment added
  set elevation elevation - 10        ; terrain erodes by 10 units

  ; Remove trees affected by landslide
  ask turtles in-radius 2 [
    if tree? [
      die
    ]
  ]
  ; update total-trees immediately after trees die
  set total-trees count turtles with [tree?]

  set total-landslides total-landslides + 1
  set total-sediment total-sediment + sediment
end

to deposit-sediment
  ask patches [
    if sediment > 0 [
      let target-patch min-one-of neighbors with [elevation < [elevation] of self] [
        elevation
      ]
      if target-patch != nobody [
        ask target-patch [
          set sediment sediment + sediment-flow-rate
        ]
      ]
    ]
  ]
end

to update-monitor
  set total-trees count turtles with [tree?]

  set-current-plot "Landslide Stats"
  plot total-landslides

  set-current-plot "Rainfall Stats"
  plot total-rainfall

  set-current-plot "Sediment Stats"
  plot total-sediment
end
@#$#@#$#@
GRAPHICS-WINDOW
1083
13
1872
803
-1
-1
23.67
1
10
1
1
1
0
1
1
1
-16
16
-16
16
0
0
1
ticks
30.0

BUTTON
43
296
109
329
setup
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
143
296
206
329
go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
234
300
406
333
rainfall-rate
rainfall-rate
0
0.2
0.1
0.01
1
NIL
HORIZONTAL

SLIDER
429
301
601
334
landslide-threshold
landslide-threshold
0
100
50.0
1
1
NIL
HORIZONTAL

SLIDER
233
362
405
395
sediment-flow-rate
sediment-flow-rate
0
1
0.5
0.1
1
NIL
HORIZONTAL

SLIDER
429
365
601
398
number-of-trees
number-of-trees
0
800
100.0
1
1
NIL
HORIZONTAL

MONITOR
735
686
884
731
Cumulative Rainfall (mm)
total-rainfall
17
1
11

MONITOR
738
744
890
789
Patches Affected N/1089
total-landslides
17
1
11

MONITOR
894
686
1048
731
Cumulative Sediment (kg)
total-sediment
17
1
11

MONITOR
897
745
1032
790
Total Trees Remaining
total-trees
17
1
11

PLOT
712
456
1035
660
Landslide Stats
Time (ticks)
total-landslides over time)
0.0
100.0
0.0
100.0
false
false
"" ""
PENS
"default" 1.0 0 -7500403 true "" "plot total-landslides"

PLOT
716
240
1036
440
Rainfall Stats
Time (ticks)
Total Rainfall
0.0
200.0
0.0
100.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot total-rainfall"

PLOT
716
40
1036
214
Sediment Stats
Time (ticks)
Total Sediment
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot total-sediment"

@#$#@#$#@
## WHAT IS IT?

This model simulates rainfall-induced landslides on a psuedo sloped terrain. it shows the effect of continued rainfall leads to soil saturation, terrain instability, sediment flow, and vegetation loss. The model is intended to help understand the dynamics of landslide under different environmental conditions such as rainfall intensity, sediment threshold and vegetation.

## HOW IT WORKS

The model uses an agent-based approach with two main types of agents:
- **Patches** represent units of terrain and hold information about elevation, soil saturation, sediment, and IF they have experienced a landslide.
- **Turtles** represent trees that grow on patches with sufficiently high elevation. Trees are removed if a landslide occurs nearby (neighbor).

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

Created by CA group 1 Grad/Undergrad,De La Salle University Manila, as part of our agent based modeling project in CA class? (forgot out class code) .

For educational use. No external datasets or libraries were used.

The model idea was inspired by the frequent occurrence of landslides in the Philippines, particularly during the rainy season. Mountainous regions that are heavily deforested or exploited for natural resources are prone to such.

This model aims to simulate and better understand how rainfall, vegetation, and terrain interact to contribute to landslides.
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.4.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
