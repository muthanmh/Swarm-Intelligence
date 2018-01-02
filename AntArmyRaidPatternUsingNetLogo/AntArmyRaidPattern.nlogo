patches-own [
  chemical             ;; amount of chemical on this patch
  food                 ;; amount of food on this patch (0, 1, or 2)
  nest?                ;; true on nest patches, false elsewhere
]

to clear display
  clear-all
  reset-ticks
end


to setup
  clear-all
  set-default-shape turtles "bug"
  create-turtles num
  [ set size 2         ;; easier to see
    set color red      ;; red = not carrying food
    setxy nestx nesty ;Setting x and Y coordiantes
    if not showants
    [set hidden? true]
  ]
  setup-patches
  reset-ticks
end

to setup-patches
  ask patches
  [ setup-nest  setup-food  recolor-patch ]
end

to setup-nest  ;; patch procedure
  ;; set nest? variable to true inside the nest, false elsewhere
  set nest? (distancexy nestx nesty) < 2

  ;;set chemical 0.1 + 0.01 * (random 100) ;; Initializing pheromone/chemical with atleast 0.0001
  set chemical 0.1 ;; + 0.001 * (random 10) ;; Initializing pheromone/chemical with atleast 0.1
  ;; spread a nest-scent over the whole world -- stronger near the nest
  ;;set nest-scent 200 - distancexy nestx nesty
  ;;set chemical 200 - distancexy nestx nesty

end

to setup-food  ;; patch procedure
  ;; setting up the food using food density and concentration
  if (distancexy (random one-of [-20 20]) (random one-of [-40 80])) < 1 + fooddensity / 3
  [ set food foodconc ] ;; setting food units equalto foodconc/co-ordinate
end

to recolor-patch  ;; patch procedure
  ;; give color to nest and food sources
  ifelse nest?
  [ set pcolor violet ]
  [ ifelse food > 0
    [
      if showfood
      [ set pcolor cyan ]
    ]
    ;; scale color to show chemical concentration
    [
      if showpheromones
      [  set pcolor scale-color green chemical 1 1000 ]
    ]
    ;[ set pcolor scale-color green chemical 0.1 5 ]
  ]
end


to go  ;; forever button
  ask turtles
  [
    if who >= ticks * 10 [ stop ] ;; launching 10 ants per tick

    ifelse color = red
    [ look-for-food  ]       ;; not carrying food? look for it
    [ return-to-nest ]       ;; carrying food? take it back to nest --when orange
    ;wiggle                  ;; uncomment it when needed --used if ant is stuck
  ]

  ask patches
  [
    set chemical chemical * (100 - evaprate) / 100  ;; slowly evaporate chemical
    recolor-patch ]
  tick
end


to return-to-nest  ;; turtle procedure
  if ycor < ( xcor - nestx ) + nesty or ycor < (nestx - xcor) + nesty  ;; area covered when y < |x|
  [ setxy nestx nesty]  ;; setting boundary at 45 and -45 angle
  ifelse nest?
  [ ;; drop food and head out again
    set color red
    rt 180 ]
  [ set chemical chemical + pherofrom  ;; drop chemical/pheromone
    move-the-ant 180
  ]
end

to look-for-food  ;; turtle procedure

  move-the-ant 0
  set chemical chemical + pheroto  ;; drop chemical/pheromone
  if ( xcor > max-pxcor - 60 ) or ( xcor < min-pxcor + 60 ) or ( ycor > max-pycor - 7 ) or ( ycor < min-pycor + 7)  ;;use some food conditions else other will follow same trail
  [ setxy nestx nesty]  ;; re-setting agents to nest if they cross the boundary
  ;;if ( xcor > m ) or ( xcor < -10 ) or ( ycor < nesty ) or ( ycor > nesty + 70 )  ;;use some food conditions else other will follow same trail
  ;[die] ;;incase the ants reach patch borders then they will again start from the nest (nothing is mentioned about this in assigmnent reqs.).

  if food > 0
  [ set color orange + 1     ;; pick up food
    set food food - 1        ;; and reduce the food source
    rt 180                   ;; and turn around
    stop ]
end

to move-the-ant [head]
  set heading head
  let l 0
  let r 0

  let la patch-right-and-ahead -45 1
  ifelse la = nobody
  [ set l 0.1 ]
  [ set l [chemical] of la]

  let ra patch-right-and-ahead 45 1
  ifelse ra = nobody
  [ set r 0.1 ]
  [ set r [chemical] of ra]

  let p1 0.5 * ( 1 + tanh (((l + r) / 100) - 1) )
  print ""
  ;;type " l: "  type l type " r: " type r type " p1: " type p1 ;;type " temp: " type temp type " t1: " type t1
  if p1 > ( 0.01 * random 10 )  ;; can move
  ;;if p1 > ( 0.1 )  ;; can move
  [
    ;;print "ant can move"

    ;; l and r are total pheromone/chemical deposits at -45 and +45 blocks
    let p2 ((k + l) ^ n) / (((k + l) ^ n) + ((k + r) ^ n))
    ;;type " l: " type l type " r: " type r type " P: " type p2
    ;;ifelse p2 > 0.5
    ifelse p2 > ( 0.01 * random 100 )  ;; can move
    [ lt 45 ]  ;; move left
    [ rt 45 ]   ;;move right

    fd 1

  ]
end

; see http://en.wikipedia.org/wiki/Hyperbolic_function for this definition
to-report tanh [x]
  let exp2x exp(2 * x)
  report (exp2x - 1)/(exp2x + 1)
end

to wiggle  ;; turtle procedure
  ;  rt 45
  ;  lt 45
  ;[ set food one-of [rt 45 lt 45] ]
  if not can-move? 1 [ rt 180 ]

end

@#$#@#$#@
GRAPHICS-WINDOW
259
10
669
421
-1
-1
2.0
1
8
1
1
1
0
1
1
1
-100
100
-100
100
0
0
1
ticks
30.0

BUTTON
23
10
78
43
NIL
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
24
47
79
80
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

SLIDER
109
10
201
43
num
num
1
3000
2000.0
1
1
NIL
HORIZONTAL

SLIDER
110
47
202
80
nestx
nestx
-100
100
1.0
1
1
NIL
HORIZONTAL

SLIDER
111
81
203
114
nesty
nesty
-100
100
-45.0
1
1
NIL
HORIZONTAL

SLIDER
6
142
98
175
n
n
1
100
2.0
1
1
NIL
HORIZONTAL

SLIDER
7
178
99
211
k
k
1
100
5.0
1
1
NIL
HORIZONTAL

SLIDER
112
175
204
208
fooddensity
fooddensity
1
100
30.0
1
1
NIL
HORIZONTAL

BUTTON
8
89
90
122
NIL
clear display
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
113
211
205
244
pherofrom
pherofrom
1
100
10.0
1
1
NIL
HORIZONTAL

SLIDER
113
245
205
278
pheroto
pheroto
1
100
1.0
1
1
NIL
HORIZONTAL

SLIDER
113
280
205
313
evaprate
evaprate
1
100
10.0
1
1
NIL
HORIZONTAL

SWITCH
4
327
114
360
showfood
showfood
0
1
-1000

SWITCH
5
399
157
432
showpheromones
showpheromones
0
1
-1000

SWITCH
4
363
113
396
showants
showants
0
1
-1000

SLIDER
112
143
204
176
foodconc
foodconc
1
100
27.0
1
1
NIL
HORIZONTAL

PLOT
920
95
1161
422
Time Evolution of food
Time
Food
0.0
50.0
0.0
120.0
true
false
"" ""
PENS
"default" 1.0 0 -14454117 true "" "plotxy ticks sum [food] of patches with [pcolor = cyan]"

PLOT
689
142
895
423
Time evolution of pheromones
time
avg pheromone deposited by an ant
0.0
100.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -15040220 true "" "plotxy ticks sum [chemical] of patches / num"

@#$#@#$#@
## WHAT IS IT?

Assignment-1: Foraging Raid pattern of ant army.

This is a computational model which tries to simulate the foraging raid pattern of the biological ant colony. In this simulation project, an army of ants forages using the rules mentioned in Bonabeau,et al.(1999).The army of ants as a whole acts in a sophisticated way.

## HOW IT WORKS (Rules)

1. The environment is represented as a 2D grid with each block representing a site. The environment is updated depending upon the actions carried by ants (agents/turtles). 

2. The ants lay pheromone trails both on their way out to forage raid front and while returning to the nest. Ants deposit one unit of pheromone per block while foraging and ten units when they are returning back. The pheromone level at particular site on return journey is restricted to 300 units however the overall cap is 1000 units per block. 

3. The decision to move an ant is mostly dependent on the pheromone levels at the top-left (-45°) and top-right (+45°) site location. We used the probability value pm to make the judgement to move an ant. 
	pm = 0.5 * (1 + tanh (((l + r) / 100) - 1)) 
	where l and r are the pheromone levels at top-left and top-right sites.  
If the ant chooses to move then the direction of an advancement is decided on basis of another probability value pl and pr. 
	pl = ((k + l) n) / (((k + l) n) + ((k + r) n)) 
	where pr = 1 - pl. 

4. Ten ants leave per tick timer from the nest. 

5. The food distribution is configured using the food density and food concentration parameter. If the ant finds a food then it returns back to nest with one unit of food. 

## HOW TO USE IT

1. Setup button sets up the patch(environment) and turtles(ants) using the parameter values (regulated by other controls) and some predefined rules.  

2. Go button is to initiate the interaction between ants and the environment to generate foraging raid pattern.  

3. Clear display is to clear the grid display.  

4. Internal configuration: 
	a).Nest is in violet color. 
	b).Food items are in cyan color. 
	c).Ants are in red color. They will turn orange once they collect a food unit and will go red again when they reach the nest. 
	d).Evaporation fade can be seen with green color gradient. 

5. Use showfood, showants, showpheromones switches to show/hide the food, ants, and pheromones respectively. 

6. Line graph shows the time varied food consumption by an ant army. 
 
## ASSUMPTIONS

1. Ants will die if they crossed the border limit of patch grid. 

2. If returning ants strayed away by more than 45° angle (in either direction) relative to the nest location then they will be reset to nest. 

3. For initialization, micro-amount has been spread randomly across the patch environment. 
 
## THINGS TO TRY

User can play around the output patterns by tuning the parameter values using the sliders and switches. The parameters of interest are n, k, evaporation-rate and food density.


## CREDITS AND REFERENCES

* Barton, A. (2005). Modelling the Foraging Patterns of a Colony of Co-operating Army Ant Agents using NetLogo.

* Bonabeau, E., Dorigo, M., & Theraulaz, G. (1999). Swarm intelligence: from natural to artificial systems (No. 1). Oxford university press.

* Wilensky, U. (1999). NetLogo. http://ccl.northwestern.edu/netlogo/. Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.

* Wilensky, U. (1997).  NetLogo Ants model.  http://ccl.northwestern.edu/netlogo/models/Ants.  Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.

* White, T. (2017). COMP5206 Lecture Notes.
https://sikaman.dyndns.org/courses/5206/handouts/03-RaidArmyAnts.pdf Evolutionary Computing and Artificial Life, Carleton University, Ottawa, ON

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
NetLogo 6.0.2
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
