;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;First we set globals and breeds;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
breeds [
  virus-1
  virus-2
  virus-3
  virus-4
  white-cell
  red-cell
]

globals [
  minute ;is our time step
  initial-virus-1
  initial-virus-2
  initial-virus-3
  initial-virus-4
  initial-red-cell
  initial-white-cell
  red-cell-count
  white-cell-count
  virus-count
  skin-cell-count
  white-cell-production?
  bloodflow?
  skin-bound-left
  skin-bound-right
  sneeze-count-down
  virus-1-count
  virus-2-count
  virus-3-count
  virus-4-count
]

to setup-globals
  set initial-virus-1 20
  set initial-virus-2 20
  set initial-virus-3 20
  set initial-virus-4 20
  set initial-red-cell 1000
  set initial-white-cell 200;(initial-red-cell / 500) ;the number of white blood cells equals red-cells/500 from research
  set virus-count (initial-virus-1 + initial-virus-2 + initial-virus-3 + initial-virus-4)
  set white-cell-production? true
  set bloodflow? true
  set skin-bound-left (- (screen-edge-x / 2))
  set skin-bound-right (screen-edge-x / 2)
  set sneeze-count-down sneeze-rate  ;when sneeze count-down reaches zero, there is a sneeze equal to the initial values of all viruses
  set virus-1-count count virus-1
  set virus-2-count count virus-2
  set virus-3-count count virus-3
  set virus-4-count count virus-4
end

patches-own [
  skin?
  dead-skin?
  alive-skin?
  inside?
  outside?
  skin-hunger
  skin-being-attacked?
  skin-age
  
]
virus-1-own [ ;attacks skin
  lifespan                 ;each cell will be given their own lifespan at birth.  These will differ slightly within
                           ;the same breed in order to make the model more realistic.  The lifespan will be how long they 
                           ;will live if not killed some other way other than natural causes.
  alive?                   ;dead cells will remain seen but unable to move or do anything for a certain amount of time.
                           ;This seems to be more realistic than cells that suddenly dissapear.
  being-attacked?          ;increacing it's chance of unatural death.
  attacking?               ;a cell attacking acts differently then one wandering.
  attacked?
  age                      ;This is measured in time clicks.
  hunger                   ;1 is hungry and 10 is full.  Once this hits zero the cell will die a painful death.
  severity                 ;On a scale from 1 (a cold) to 10 (ebola).
  flesh-eating?            ;These viruses are rare but mean.
  multiply-rate            ;once attached to host cell, how many time clicks go by before new viruses spawn?
  wandering?
  stink-radius             ;used so white cells can attach on to its chemical signal
  stink-magnitude
]

virus-2-own [ ;attacks flesh
  lifespan                 ;each cell will be given their own lifespan at birth.  These will differ slightly within
                           ;the same breed in order to make the model more realistic.  The lifespan will be how long they 
                           ;will live if not killed some other way other than natural causes.
  alive?                   ;dead cells will remain seen but unable to move or do anything for a certain amount of time.
                           ;This seems to be more realistic than cells that suddenly dissapear.
  being-attacked?          ;increacing it's chance of unatural death.
  attacking?               ;a cell attacking acts differently then one wandering.
  attacked?
  age                      ;This is measured in time clicks.
  hunger                   ;1 is hungry and 10 is full.  Once this hits zero the cell will die a painful death.
  severity                 ;On a scale from 1 (a cold) to 10 (ebola).
  flesh-eating?            ;These viruses are rare but mean.
  multiply-rate            ;once attached to host cell, how many time clicks go by before new viruses spawn?
  wandering?
  stink-radius             ;used so white cells can attach on to its chemical signal
  stink-magnitude
]

virus-3-own [     ;attacks white blood cells
  lifespan                 ;each cell will be given their own lifespan at birth.  These will differ slightly within
                           ;the same breed in order to make the model more realistic.  The lifespan will be how long they 
                           ;will live if not killed some other way other than natural causes.
  alive?                   ;dead cells will remain seen but unable to move or do anything for a certain amount of time.
                           ;This seems to be more realistic than cells that suddenly dissapear.
  being-attacked?          ;increacing it's chance of unatural death.
  attacking?               ;a cell attacking acts differently then one wandering.
  attacked?
  age                      ;This is measured in time clicks.
  hunger                   ;1 is hungry and 10 is full.  Once this hits zero the cell will die a painful death.
  severity                 ;On a scale from 1 (a cold) to 10 (ebola).
  flesh-eating?            ;These viruses are rare but mean.
  multiply-rate            ;once attached to host cell, how many time clicks go by before new viruses spawn?
  wandering?
  stink-radius             ;used so white cells can attach on to its chemical signal
  stink-magnitude
]
virus-4-own [ ; attacks bacteria
  lifespan                 ;each cell will be given their own lifespan at birth.  These will differ slightly within
                           ;the same breed in order to make the model more realistic.  The lifespan will be how long they 
                           ;will live if not killed some other way other than natural causes.
  alive?                   ;dead cells will remain seen but unable to move or do anything for a certain amount of time.
                           ;This seems to be more realistic than cells that suddenly dissapear.
  being-attacked?          ;increacing it's chance of unatural death.
  attacking?               ;a cell attacking acts differently then one wandering.
  attacked?
  age                      ;This is measured in time clicks.
  hunger                   ;1 is hungry and 10 is full.  Once this hits zero the cell will die a painful death.
  severity                 ;On a scale from 1 (a cold) to 10 (ebola).
  flesh-eating?            ;These viruses are rare but mean.
  multiply-rate            ;once attached to host cell, how many time clicks go by before new viruses spawn?
  wandering?
  stink-radius             ;used so white cells can attach on to its chemical signal
  stink-magnitude
]

white-cell-own [ 
  lifespan
  alive?
  being-attacked?
  attacking?
  age
  hunger ;1 is hungry and 10 is full
  age-max
  wandering?
]

red-cell-own [ 
  lifespan
  alive?
  empty??
  resources
]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;Now we make buttons do things;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to go
  play-god
  sneeze
  set virus-count (count virus-1 + count virus-2 + count virus-3 + count virus-4)
  set red-cell-count count red-cell
  set white-cell-count count white-cell
  set skin-cell-count count patches with [pcolor = yellow]
  set virus-1-count count virus-1
  set virus-2-count count virus-2
  set virus-3-count count virus-3
  set virus-4-count count virus-4
end

to play-god
   go-virus-1
   go-virus-2
   go-virus-3
   go-virus-4
   go-white-cell
   go-red-cell
   ;go-neutrients
end

to setup
  clear-all
  clear-patches
  setup-globals
  setup-virus-1
  setup-virus-2
  setup-virus-3
  setup-virus-4 ;;this corresponds to the 4 different kinds of virus turtles to be defined
  setup-white-cell   ;;this corresponds to the virus killing turtles
  setup-red-cell     ;;this corresponds to the neutrient delivery turtles
  setup-skin-cell
  ;setup-neutrients
  ;setup-marrow
end

to kill-all-viruses
  ask virus-1 [ die ]
  ask virus-2 [ die ]
  ask virus-3 [ die ]
  ask virus-4 [ die ]
end

to stab

end

to stab-and-infect

end

to kill-all-white-bloodcells
  ask white-cell [ die ]
end

to big-sneeze
  set initial-virus-1 initial-virus-1 * 2
  set initial-virus-1 initial-virus-2 * 2
  set initial-virus-1 initial-virus-3 * 2
  set initial-virus-1 initial-virus-4 * 2  ;makes burst of viruses more extreme
  setup-virus-1
  setup-virus-2
  setup-virus-3
  setup-virus-4
  set initial-virus-1 initial-virus-1 / 2  ;puts these values back to where they were in case we need them
  set initial-virus-1 initial-virus-2 / 2
  set initial-virus-1 initial-virus-3 / 2
  set initial-virus-1 initial-virus-4 / 2
end

to donate-blood
  ask random-n-of (.10 * (count red-cell)) red-cell [die]
end

to inject-with-draino

end

to stop-white-cell-production
  set white-cell-production? false
end

to stop-blood-flow
  set bloodflow? false
end

to take-vitamin-c

end

to sneeze
;  if sneeze-count-down > 0 [set sneeze-count-down (sneeze-count-down - 1)]
;  if sneeze-count-down = 0 [setup-virus-1
;                            setup-virus-2
;                            setup-virus-3
;                            setup-virus-4
;                            set sneeze-count-down sneeze-rate
;                            ]
  ifelse sneeze-count-down = 0 [setup-virus-1
                            setup-virus-2
                            setup-virus-3
                            setup-virus-4
                            set sneeze-count-down sneeze-rate
                            ]
                            [set sneeze-count-down (sneeze-count-down - 1)]                           
end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;Now we set up everything;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to setup-virus-1
  create-custom-virus-1 initial-virus-1 [set color green]
  ask virus-1 [
    set shape "circle 1"
    set xcor random screen-size-x
    set ycor random screen-size-y
    set wandering? true
  ]
end

to setup-virus-2
  create-custom-virus-2 initial-virus-2 [ set color green ]
  ask virus-2 [
    ;set shape " "
    set xcor random screen-size-x
    set ycor random screen-size-y
    set wandering? true
  ]
end

to setup-virus-3
  create-custom-virus-3 initial-virus-3 [ set color green ]
  ask virus-3 [
    ;set shape " "
    set xcor random screen-size-x
    set ycor random screen-size-y
    set wandering? true
  ]
end

to setup-virus-4
  create-custom-virus-4 initial-virus-4 [ set color green ]
  ask virus-4 [
    ;set shape " "
    set xcor random screen-size-x
    set ycor random screen-size-y
    set wandering? true
  ]
end

to setup-white-cell
    create-custom-white-cell initial-white-cell [set shape "whiteblood" set color white ifelse random 2 = 1 [set heading (360 - random 10)][set heading (360 + random 10)]] ;set headings to be mostly forward but having some small component in the x or -x direction]
    ask white-cell [if random 2 = 0[(set xcor random skin-bound-right + 1) (set ycor random screen-size-y)]
                    if random 2 = 1[(set xcor (- random skin-bound-right - 1)) (set ycor random screen-size-y)]]
end

to setup-skin-cell
  let n 0
  repeat (skin-thickness) [ask  patches [if (pxcor = (skin-bound-right - n) or pxcor = (skin-bound-left + n)) [set pcolor yellow]] set n (n + 1)]
  if skin-pores? [ask patches [if (pcolor = yellow) and random (poressness) = 1 [set pcolor black]]]
end

to setup-red-cell
  create-custom-red-cell initial-red-cell [set shape "redblood" set color orange ifelse random 2 = 1 [set heading (360 - random 10)][set heading (360 + random 10)]] ;set headings to be mostly forward but having some small component in the x or -x direction
  ask red-cell [if random 2 = 0[(set xcor random skin-bound-right ) (set ycor random screen-size-y)]
                if random 2 = 1[(set xcor (- random skin-bound-right )) (set ycor random screen-size-y)]]
end

to setup-nutrients
  let n 0
  let m 0
  repeat (skin-bound-right - skin-thickness) [ask patches [if pxcor = n and pycor = screen-edge-y - m [set pcolor blue]set n n + 1]]
end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;Now we make everything go;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to go-virus-1
  ask virus-1 [
    set age age + 1
    if wandering? [fd 1 set heading random 360]
    ]
end

to go-virus-2
  ask virus-2 [
    set age age + 1
    if wandering? [fd 1 set heading random 360]
    ]
end

to go-virus-3
  ask virus-3 [
    set age age + 1
    if wandering? [fd 1 set heading random 360]
    ]
end

to go-virus-4
  ask virus-4 [
    set age age + 1
    if wandering? [fd 1 set heading random 360]
    ]
end

to go-red-cell
  ask red-cell [fd 1
    if xcor >= skin-bound-right or xcor <= skin-bound-left[set heading (- heading)]
    if count other-white-cell-here >= 1 or count other-red-cell-here >= 1 [set heading (- heading)]]
               
end

to go-white-cell
  ask white-cell [fd 1 
    if count other-virus-1-here >= 1 [ask virus-1-here[die]]
    if count other-virus-2-here >= 1 [ask virus-2-here[die]]
    if count other-virus-3-here >= 1 [ask virus-3-here[die]]
    if count other-virus-4-here >= 1 [ask virus-4-here[die]]
    if count other-white-cell-here >= 1 or count other-red-cell-here >= 1 [set heading (- heading)]
    if xcor >= skin-bound-right or xcor <= skin-bound-left[set heading (- heading)]
    ]
end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;I put this part in to render the movies;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to movie
  setup
  movie-start "cell movie.mov"
  repeat 200 
  [ movie-grab-graphics 
    go ]
  movie-close
end
@#$#@#$#@
GRAPHICS-WINDOW
461
10
1456
1026
98
98
5.0
1
10
1
1
1
0

CC-WINDOW
5
1040
1465
1135
Command Center

BUTTON
7
10
62
43
go
go
T
1
T
OBSERVER
T
NIL

BUTTON
67
10
122
43
NIL
setup
NIL
1
T
OBSERVER
T
NIL

SLIDER
7
51
179
84
white-cell-lifespan
white-cell-lifespan
0
100
48
1
1
NIL

SLIDER
7
93
179
126
red-cell-lifespan
red-cell-lifespan
0
100
61
1
1
NIL

SLIDER
7
135
179
168
skin-cell-lifespan
skin-cell-lifespan
0
100
50
1
1
NIL

SLIDER
7
177
179
210
virus-1-lifespan
virus-1-lifespan
0
100
25
1
1
NIL

SLIDER
7
219
179
252
virus-2-lifespan
virus-2-lifespan
0
100
24
1
1
NIL

SLIDER
7
260
179
293
virus-3-lifespan
virus-3-lifespan
0
100
22
1
1
NIL

SLIDER
7
302
179
335
virus-4-lifespan
virus-4-lifespan
0
100
20
1
1
NIL

BUTTON
186
51
280
84
kill all viruses
Kill-all-viruses
NIL
1
T
OBSERVER
T
NIL

BUTTON
186
94
280
127
kill white cells
kill-all-white-bloodcells
NIL
1
T
OBSERVER
T
NIL

MONITOR
374
344
458
393
white cell count
white-cell-count
3
1

BUTTON
187
135
280
168
stab
stab
NIL
1
T
OBSERVER
T
NIL

BUTTON
187
177
281
210
stab and infect
stab-and-infect
NIL
1
T
OBSERVER
T
NIL

MONITOR
287
344
368
393
red cell count
red-cell-count
3
1

BUTTON
187
219
281
252
big sneeze
big-sneeze
NIL
1
T
OBSERVER
T
NIL

BUTTON
127
10
280
43
stop white cell production
stop-white-cell-production
T
1
T
OBSERVER
T
NIL

MONITOR
286
398
368
447
virus count
virus-count
3
1

BUTTON
186
259
281
292
stop blood flow
stop-blood-flow
NIL
1
T
OBSERVER
T
NIL

BUTTON
186
302
281
335
take vitamin c
take-vitamin-c
NIL
1
T
OBSERVER
T
NIL

SLIDER
7
344
179
377
white-cell-production-rate
white-cell-production-rate
0
100
17
1
1
NIL

SWITCH
6
467
159
500
show-dead-cells
show-dead-cells
1
1
-1000

SWITCH
7
426
158
459
show-virus-trails
show-virus-trails
1
1
-1000

SWITCH
7
383
179
416
show-blood-cell-trails
show-blood-cell-trails
1
1
-1000

BUTTON
186
344
281
377
inject with draino
inject-with-draino
NIL
1
T
OBSERVER
T
NIL

BUTTON
187
385
282
418
donate blood
donate-blood
NIL
1
T
OBSERVER
T
NIL

SWITCH
6
509
158
542
show-cell-hunger
show-cell-hunger
1
1
-1000

SLIDER
286
11
420
44
skin-thickness
skin-thickness
1
50
22
1
1
NIL

SWITCH
163
426
281
459
skin-pores?
skin-pores?
0
1
-1000

SLIDER
287
302
424
335
poressness
poressness
1
20
14
1
1
NIL

SLIDER
287
177
424
210
white-cell-smell-radius
white-cell-smell-radius
0
100
50
1
1
NIL

SLIDER
287
220
424
253
virus-1-smell-radius
virus-1-smell-radius
0
100
50
1
1
NIL

SLIDER
287
95
423
128
virus-2-smell-radius
virus-2-smell-radius
0
100
49
1
1
NIL

SLIDER
286
135
423
168
virus-3-smell-radius
virus-3-smell-radius
0
100
50
1
1
NIL

SLIDER
286
50
420
83
virus-4-smell-radius
virus-4-smell-radius
0
100
50
1
1
NIL

MONITOR
374
398
459
447
skin cell count
skin-cell-count
3
1

SLIDER
287
260
424
293
blood-preasure
blood-preasure
0
100
50
1
1
NIL

SLIDER
286
490
459
523
heart-beats-per-minute
heart-beats-per-minute
0
300
100
1
1
NIL

SLIDER
286
452
459
485
energy-level-per-neutrients
energy-level-per-neutrients
0
100
10
1
1
NIL

SLIDER
163
465
281
498
sneeze-rate
sneeze-rate
0
1000
107
1
1
NIL

MONITOR
192
547
280
596
NIL
virus-1-count
3
1

MONITOR
99
547
187
596
NIL
virus-2-count
3
1

MONITOR
285
547
373
596
NIL
virus-3-count
3
1

MONITOR
6
547
94
596
NIL
virus-4-count
3
1

@#$#@#$#@
WHAT IS IT?
-----------
This section could give a general understanding of what the model is trying to show or explain.


HOW IT WORKS
------------
This section could explain what rules the agents use to create the overall behavior of the model.


HOW TO USE IT
-------------
This section could explain how to use the model, including a description of each of the items in the interface tab.


THINGS TO NOTICE
----------------
This section could give some ideas of things for the user to notice while running the model.


THINGS TO TRY
-------------
This section could give some ideas of things for the user to try to do (move sliders, switches, etc.) with the model.


EXTENDING THE MODEL
-------------------
This section could give some ideas of things to add or change in the procedures tab to make the model more complicated, detailed, accurate, etc.


NETLOGO FEATURES
----------------
This section could point out any especially interesting or unusual features of NetLogo that the model makes use of, particularly in the Procedures tab.  It might also point out places where workarounds were needed because of missing features.


RELATED MODELS
--------------
This section could give the names of models in the NetLogo Models Library or elsewhere which are of related interest.


CREDITS AND REFERENCES
----------------------
This section could contain a reference to the model's URL on the web if it has one, as well as any other necessary credits or references.
@#$#@#$#@
default
true
0
Polygon -7566196 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7566196 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7566196 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7566196 true true 150 285 285 225 285 75 150 135
Polygon -7566196 true true 150 135 15 75 150 15 285 75
Polygon -7566196 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7566196 true true 96 182 108
Circle -7566196 true true 110 127 80
Circle -7566196 true true 110 75 80
Line -7566196 true 150 100 80 30
Line -7566196 true 150 100 220 30

butterfly
true
0
Polygon -7566196 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7566196 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7566196 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7566196 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7566196 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7566196 true true 47 195 58
Circle -7566196 true true 195 195 58

circle 1
false
0
Circle -7566196 true true 30 30 240

circle 2
false
0
Circle -7566196 true true 16 16 270
Circle -16777216 true false 46 46 210

cow
false
0
Polygon -7566196 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7566196 true true 73 210 86 251 62 249 48 208
Polygon -7566196 true true 25 114 16 195 9 204 23 213 25 200 39 123

face happy
false
0
Circle -7566196 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7566196 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7566196 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7566196 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7566196 true true 60 15 75 300
Polygon -7566196 true true 90 150 270 90 90 30
Line -7566196 true 75 135 90 135
Line -7566196 true 75 45 90 45

flower
false
0
Polygon -11352576 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7566196 true true 85 132 38
Circle -7566196 true true 130 147 38
Circle -7566196 true true 192 85 38
Circle -7566196 true true 85 40 38
Circle -7566196 true true 177 40 38
Circle -7566196 true true 177 132 38
Circle -7566196 true true 70 85 38
Circle -7566196 true true 130 25 38
Circle -7566196 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -11352576 true false 189 233 219 188 249 173 279 188 234 218
Polygon -11352576 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7566196 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7566196 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7566196 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7566196 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7566196 true 150 0 150 300

pentagon
false
0
Polygon -7566196 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7566196 true true 110 5 80
Polygon -7566196 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7566196 true true 127 79 172 94
Polygon -7566196 true true 195 90 240 150 225 180 165 105
Polygon -7566196 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7566196 true true 135 90 165 300
Polygon -7566196 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7566196 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7566196 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7566196 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7566196 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7566196 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7566196 true true 135 90 120 45 150 15 180 45 165 90

redblood
false
2
Circle -65536 true false 30 30 240
Circle -44544 true true 75 75 150

square
false
0
Rectangle -7566196 true true 30 30 270 270

square 2
false
0
Rectangle -7566196 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7566196 true true 60 270 150 0 240 270 15 105 285 105
Polygon -7566196 true true 75 120 105 210 195 210 225 120 150 75

target
false
0
Circle -7566196 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7566196 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7566196 true true 120 120 60

tree
false
0
Circle -7566196 true true 118 3 94
Rectangle -6524078 true false 120 195 180 300
Circle -7566196 true true 65 21 108
Circle -7566196 true true 116 41 127
Circle -7566196 true true 45 90 120
Circle -7566196 true true 104 74 152

triangle
false
0
Polygon -7566196 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7566196 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7566196 true true 4 45 195 187
Polygon -7566196 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7566196 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7566196 false true 24 174 42
Circle -7566196 false true 144 174 42
Circle -7566196 false true 234 174 42

turtle
true
0
Polygon -11352576 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -11352576 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -11352576 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -11352576 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -11352576 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7566196 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7566196 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7566196 true 150 285 150 15
Line -7566196 true 15 150 285 150
Circle -7566196 true true 120 120 60
Line -7566196 true 216 40 79 269
Line -7566196 true 40 84 269 221
Line -7566196 true 40 216 269 79
Line -7566196 true 84 40 221 269

whiteblood
false
15
Circle -1 true true 30 30 240
Circle -16711738 true false 75 75 150

x
false
0
Polygon -7566196 true true 270 75 225 30 30 225 75 270
Polygon -7566196 true true 30 75 75 30 270 225 225 270

@#$#@#$#@
NetLogo 2.1.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
