;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;First we set globals and breeds;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
breeds [
  virus ;of many different types
  white-cell
  T-cell
  B-cell
  helper-T-cell
  macrophage
  antibodies
  red-cell
  platelets
  bacteria
  memory cell
  satan
  jesus
]

globals [
  initial-B-count
  initial-T-count
  initial-helper-T-count
  breath-width
  virus-strains
  virus-count
  minute ;is our time step
  initial-red-cell
  initial-macrophage
  red-cell-count
  macrophage-count
  skin-cell-count
  white-cell-production?
  bloodflow?
  skin-bound-left
  skin-bound-right
  sneeze-count-down
  confirmed-kills
  time
  oxygen-per-patch
  virus-hatch-rate
  higher-defenses        ;the level cells' defences are at once warned
  normal-defenses        ;the normal level of defenses
  temperature            ;the temperature of the body which will affect virus production.  it goes up by cells which are being attacked
  show-defenses
  
]

to setup-globals
  set initial-B-count 10
  set initial-T-count 10
  set initial-helper-T-count 10
  set initial-red-cell 1000
  set initial-macrophage 20                    ;(initial-red-cell / 500) ;the number of white blood cells equals 1 percent of red cell count
  set virus-count initial-virus
  set white-cell-production? true
  set bloodflow? true
  set skin-bound-left (- (screen-edge-x / 2))
  set skin-bound-right (screen-edge-x / 2)
  set sneeze-count-down sneeze-rate            ;when sneeze count-down reaches zero, there is a sneeze equal to the initial values of all viruses
  set virus-count count virus
  set confirmed-kills 0
  set time 0
  set breath-width 10
  set oxygen-per-patch 10
  set virus-hatch-rate 30
  set temperature 98.6     ;we will have our organism start at a healthy temperature
  set higher-defenses 5
  set normal-defenses 2   ;only 1 out of 5 viruses will succeed in reproducing on a cell block
  ;set virus-strains 1
end

patches-own [
  skin?
  dead-skin?
  alive-skin?
  flesh?
  inside?
  outside?
  hunger
  skin-being-attacked?
  skin-age
  hole?
  marrow?
  oxygen?                  ;is the patch one that will fill with oxygen when a breath is taken?
  oxygen                   ;how much oxygen is in patch?
  cells-here              ;how many cells are in this patch?
  warned?
  defenses
  patch-count-down
  infected?
  ]
  
turtles-own [              ;used for all breeds (some of these variables are only for a certain type of breed
  lifespan                 ;each cell will be given their own lifespan at birth.  These will differ slightly within
                           ;the same breed in order to make the model more realistic.  The lifespan will be how long they 
                           ;will live if not killed some other way other than natural causes.
  alive?                   ;dead cells will remain seen but unable to move or do anything for a certain amount of time.
                           ;This seems to be more realistic than cells that suddenly dissapear.
  being-attacked?          ;increacing it's chance of unatural death.
  attacking?               ;a cell attacking acts differently then one wandering.
  attacked?
  age                      ;This is measured in time clicks.
  hunger-value             ;1 is hungry and 10 is full.  Once this hits zero the cell will die a painful death.
  severity                 ;On a scale from 1 (a cold) to 10 (ebola).
  flesh-eating?            ;These viruses are rare but mean.
  multiply-rate            ;once attached to host cell, how many time clicks go by before new viruses spawn?
  wandering?
  stink-radius             ;used so white cells can attach on to its chemical signal
  stink-magnitude
  strain                   ;to distinguish virus types
  in-body?
  age-max
  out-of-body?
  empty??                  ;used for red blood cells
  oxygen-amount            ;used for red blood cells
  hunting?                  ;used by white-blood-cells
  hatch-count-down
  speed
  initial-side            ; 1 for left and 0 for right (or is it the other way?)
  tagged?                 ;if virus is tagged it is picked up by macrophage at a higher rate (tagged meaning receptors have antibodies) it also makes it unable to attach to a cell
  in-memory                  ;remembers virus strain
  flowing?
  count-down
]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;Now we make buttons do things;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to go
  play-god
  ;if periodic-sneeze?[sneeze]
  set red-cell-count count red-cell
  set macrophage-count count macrophage
  set skin-cell-count count patches with [skin? = true]
  set virus-count count virus
  set time time + 1
  ;if random 5 = 1 [setup-macrophage 2] 
  do-plots
end

to play-god
   go-virus
   go-macrophage
   go-helper-T-cell
   go-B-cell
   go-T-cell
   go-antibodies
   go-patches
   ;go-red-cell
   ;go-neutrients
end

to go-patches
  ask patches with [infected? = true and pcolor != black][warn set patch-count-down (patch-count-down - 1) if patch-count-down = 0[sprout-virus 5[set color green set age 0 set speed 1 set wandering? true set tagged? false ] set pcolor black set flesh? false 
              set cells-here cells-here - 1 if cells-here <= 0 [set flesh? false set pcolor black]]
              ]
end
to setup
  clear-all
  clear-patches
  setup-globals
  ;setup-virus
  setup-macrophage initial-macrophage  ;this corresponds to the virus killing turtles
  ;setup-red-cell     ;this corresponds to the neutrient delivery turtles
  setup-patches
  ;setup-neutrients
  ;setup-marrow
  setup-B-cell
  setup-T-cell
  setup-helper-T-cell
end

to kill-all-viruses
  ask virus [die]
end

to kill-all-white-bloodcells
  ask macrophage [die]
  ask B-cell [die]
  ask T-cell [die]
  ask helper-T-cell [die]
  
end

to big-sneeze
  set initial-virus initial-virus * 2
  setup-virus
  set initial-virus initial-virus / 2
end

to donate-blood
  ask random-n-of (.10 * (count red-cell)) red-cell [die]
  ask random-n-of (.10 * (count macrophage)) macrophage [die]
  ask random-n-of (.10 * (count B-cell)) B-cell [die]
  ask random-n-of (.10 * (count T-cell)) T-cell [die]
  ask random-n-of (.10 * (count helper-T-cell)) helper-T-cell [die]
  ask random-n-of (.10 * (count antibodies)) antibodies [die]
end

to stop-white-cell-production
  set white-cell-production? false
end

to stop-blood-flow
  ask red-cell [set speed 0]
  ask macrophage [set speed 0]
end

to start-blood-flow
  ask red-cell [set speed 1]
  ask macrophage [set speed 1]
end

to sneeze
  ifelse sneeze-count-down = 0 [
    setup-virus
    set sneeze-count-down sneeze-rate
  ]
    [set sneeze-count-down (sneeze-count-down - 1)
  ]                           
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;Now we set up everything;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to setup-T-cell
  create-custom-T-cell initial-T-count [set color brown set shape "whiteblood"
    set age random white-cell-lifespan 
    set speed .5 
    set flowing? true
    set count-down 10
    set shape "whiteblood" 
    set out-of-body? false
  ifelse random 2 = 1 [set heading (360 - random 10)][set heading (360 + random 10)]] ;set headings to be mostly forward but having some small component in the x or -x direction]
  ask random-n-of (initial-T-count / 2) T-cell [set initial-side 1]
  ask T-cell [if initial-side = 1 [(set xcor random skin-bound-right ) (set ycor random screen-size-y)]
                  if initial-side != 1 [(set xcor (- random skin-bound-right - 1 )) (set ycor (random screen-size-y - 1))]
  ]
end

to setup-helper-T-cell
  create-custom-helper-T-cell initial-helper-T-count [set color pink set shape "whiteblood"
  set age random white-cell-lifespan 
    set speed 1 
    set count-down 10
    set shape "whiteblood" 
    set out-of-body? false
  ifelse random 2 = 1 [set heading (360 - random 10)][set heading (360 + random 10)]] ;set headings to be mostly forward but having some small component in the x or -x direction]
  ask random-n-of (initial-helper-T-count / 2) helper-T-cell [set initial-side 1]
  ask helper-T-cell [if initial-side = 1 [(set xcor random skin-bound-right ) (set ycor random screen-size-y)]
                  if initial-side != 1 [(set xcor (- random skin-bound-right - 1 )) (set ycor (random screen-size-y - 1))]]
  
end

to setup-B-cell
  create-custom-B-cell initial-B-count [
    set age random white-cell-lifespan 
    set speed 1 
    set flowing? true
    set shape "whiteblood" 
    set color green
    set out-of-body? false
  ifelse random 2 = 1 [set heading (360 - random 10)][set heading (360 + random 10)]] ;set headings to be mostly forward but having some small component in the x or -x direction]
  ask random-n-of (initial-B-count / 2) B-cell [set initial-side 1]
  ask B-cell [if initial-side = 1 [(set xcor random skin-bound-right ) (set ycor random screen-size-y)]
                  if initial-side != 1 [(set xcor (- random skin-bound-right - 1 )) (set ycor (random screen-size-y - 1))]]
end

to setup-virus
  create-custom-virus initial-virus [ 
    set age random virus-lifespan 
    set color green 
    set strain random virus-strains 
  ]
  ask virus [
    ;set shape "virus "
    set xcor random screen-size-x
    set ycor random screen-size-y
    set wandering? true print strain
    set speed 1
    set hatch-count-down virus-hatch-rate
    set tagged? false
  ]
end

to setup-macrophage[number]
  create-custom-macrophage number [
    set age random white-cell-lifespan 
    set speed 1 
    set shape "whiteblood" 
    set color white
    set out-of-body? false
  ifelse random 2 = 1 [set heading (360 - random 10)][set heading (360 + random 10)]] ;set headings to be mostly forward but having some small component in the x or -x direction]
  ask random-n-of (number / 2) macrophage [set initial-side 1]
  ask macrophage [if initial-side = 1 [(set xcor random skin-bound-right ) (set ycor random screen-size-y)]
                  if initial-side != 1 [(set xcor (- random skin-bound-right - 1 )) (set ycor (random screen-size-y - 1))]
  ]
end

to setup-patches
  ask patches [
    set outside? true
    set skin? false
    set oxygen? false
    set oxygen 0
    if pxcor >= skin-bound-left and pxcor <= skin-bound-right [
      set inside? true set 
      outside? false
    ]
  ]
  setup-skin
  setup-flesh
  ;setup-breath
end

to setup-skin
  let n 0
  repeat (skin-thickness) [
    ask  patches [
      if (pxcor = (skin-bound-right - n) or pxcor = (skin-bound-left + n)) [
        set pcolor yellow 
        set skin? true 
        set inside? true 
        set cells-here cells-per-patch
        set outside? false
        set flesh? false]
      ] set n (n + 1)
      ]
    if skin-pores? [ask patches [if skin? = true and random (poressness) = 1 [set pcolor black set skin? false set hole? true set cells-here 0 ]]]
end

to setup-red-cell
  create-custom-red-cell initial-red-cell [
    set age random red-cell-lifespan
    set speed 1 
    set shape "redblood" 
    set color orange 
    set out-of-body? false 
    ifelse random 2 = 1 [
      set heading (360 - random 10)][set heading (360 + random 10)]
  ] ;set headings to be mostly forward but having some small component in the x or -x direction
  ask random-n-of (initial-red-cell / 2) red-cell [set initial-side 1]
  ask red-cell [if initial-side = 1 [(set xcor random skin-bound-right ) (set ycor random screen-size-y)]
                if initial-side != 1 [(set xcor (- random skin-bound-right - 1 )) (set ycor (random screen-size-y - 1))]]
end

to setup-breath
  let n 0
  repeat breath-width [ask patches [if pycor = ((- screen-edge-y) + n) and (pxcor <= (skin-bound-right - skin-thickness - flesh-thickness) and pxcor >= (skin-bound-left + skin-thickness + flesh-thickness)) [set pcolor blue set oxygen? true set oxygen oxygen-per-patch] ]set n n + 1]
end

to setup-flesh
  let n 0
  repeat (flesh-thickness) [ask  patches [if (pxcor = (skin-bound-right - skin-thickness - n) or pxcor = (skin-bound-left + skin-thickness + n)) [set defenses 1 set pcolor 26 set flesh? true set inside? true set cells-here cells-per-patch set outside? false]] set n (n + 1)]
  
end

to flow   ;for viruses and blood cells to do while in the body  
  fd speed
  if xcor >= skin-bound-right or xcor <= skin-bound-left[set heading (- heading)]
  if count other-macrophage-here >= 1 or count other-red-cell-here >= 1 or count other-virus-here >= 1 or count other-antibodies-here >= 1 [set heading (- heading)]
end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;Now we make everything go;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to go-antibodies
  ask antibodies [if virus-here = true[die ask virus-here[set tagged? true]]
                  flow
  ]
end

to go-B-cell
ask B-cell [if flowing?[
    fd speed
    if xcor >= skin-bound-right or xcor <= skin-bound-left[set heading (- heading)]
    if count other-B-cell-here >= 1 or count other-macrophage-here >= 1 [set heading (- heading)]
  ]]
  ask B-cell[set hatch-count-down hatch-count-down - 1
    let virus-near (virus in-radius 4)
    let x 0
    let y 0
    if count virus-near != 0 and hatch-count-down <= 0 [hatch-antibodies 4[set color yellow set wandering? true set hatch-count-down 10 set xcor (xcor + random 3) set ycor (ycor + random 3)]
        hatch-B-cell 1[set hatch-count-down 10]
        set hatch-count-down 10 set flowing? false]
    if count virus-near = 0[set flowing? true]
  ]
end

to go-T-cell
  ask T-cell [if flowing? [flow]
        if count-down = 0 [hatch-macrophage 1[flow set wandering? true set speed 1 set age 0]set count-down 10];ask random-one-of macrophage [hatch 1[flow set wandering? true set speed 1 set age 0]] set count-down 10 ]
        
        if infected?-of patch-here = true [set count-down (count-down - 1 )ask patch-here [set flesh? false set pcolor black set patch-count-down -1 set infected? false]]
        if flesh?-of patch-here = false [find-flesh-T]]
end

to go-helper-T-cell
  ask helper-T-cell [flow]
end

to wander
  fd speed set heading random 360
end

to go-virus
  ask virus [
    set age age + 1
    if age = virus-lifespan [die]
    if inside?-of patch-here = true [set in-body? true]
    ;if in-body? and wandering? = true and flesh?-of patch-here = false [flow]
    ifelse wandering? [fd speed set heading random 360][set hatch-count-down hatch-count-down - 1]
    if flesh?-of patch-here = false [find-flesh]
    if tagged? = true [set wandering? true]
    virus-reproduce
  ]
end

to go-red-cell
  ask red-cell [
    fd speed
    if xcor >= skin-bound-right or xcor <= skin-bound-left[set heading (- heading)]
    if count other-white-cell-here >= 1 or count other-red-cell-here >= 1 [set heading (- heading)]
  ]
  collect-oxygen
end

to go-macrophage
  ask macrophage [
    set age age + 1
    ;if age >= white-cell-lifespan [die]
    fd speed 
    let radi (virus in-radius 1)
    let close-virus (radi with [tagged? = true])
    ifelse count close-virus >= 1 [ask random-n-of (count close-virus) close-virus [die] set confirmed-kills confirmed-kills + 1][if count radi >= 1[if random 4 = 1 [ask random-one-of radi [die]]]]  ;they have only a 1/4 chance of eating a non-tagged virus
    if count other-macrophage-here >= 1 or count other-red-cell-here >= 1 [set heading (- heading)] ;causes cells to bounce off eachother
    ifelse xcor > skin-bound-right or xcor < skin-bound-left[set heading (- heading) set out-of-body? true][set out-of-body? false]
    ;if xcor > skin-bound-right or xcor < skin-bound-left [set out-of-body? true]
  ]
  ask macrophage with [out-of-body? = false][find-virus]
  ask macrophage with [out-of-body? = true][set heading 45 fd 1]   ;this is just a temporary safety things so virus don't leave the body for long
end

to find-flesh  ;a virus command
  let go-here (patches in-radius (virus-smell-radius) with [flesh? = true])
  ifelse (any? go-here)and flesh?-of patch-here != true[
    set heading towards (min-one-of go-here [distance myself])][flow]
end

to find-flesh-T  ;a virus command
  let go-here (patches in-radius (virus-smell-radius) with [flesh? = true and infected? = true])
  ifelse (any? go-here) and infected?-of patch-here != true[
    set heading towards (min-one-of go-here[distance myself])][set heading 360 flow]
end

to virus-reproduce  ;a virus command
if flesh?-of patch-here = true and wandering? [set wandering? false ask patch-here[set patch-count-down virus-hatch-rate set infected? true]]
    ;if hatch-count-down = 0 [if random (defenses-of patch-here) = 1[ hatch 2[set wandering? true set hatch-count-down virus-hatch-rate set age 0]]set wandering? true
    ;ask patch-here [set cells-here cells-here - 1 warn if cells-here <= 0 [set flesh? false set pcolor black]]
    ;]
end

to warn
  ask neighbors [if flesh? = true [set defenses higher-defenses if show-defeses = true [set pcolor blue]]];warn neighbors
end

to place-virus  ;so the user can place a virus
  if mouse-down? [create-custom-virus 1[
    set color green
    set wandering? true
    set xcor mouse-xcor
    set ycor mouse-ycor
    set speed 1
    set hatch-count-down virus-hatch-rate]]
end

to find-virus ;for macrophage
 ifelse any? virus in-radius blood-sensing-radius [
   set heading (towards min-one-of (virus in-radius white-cell-smell-radius)[distance myself ])][ifelse random 2 = 1 [set heading 360 - random 15][set heading 360 + random 15]]
end

to breath
  ask patches with [oxygen?][set oxygen 10]
end

to collect-oxygen ;called in red-cell-go procedure
  ask red-cell with [oxygen-amount < 10] [if oxygen?-of patch-here = true [set oxygen-amount oxygen-amount + 1] ask patch-here [if oxygen? = true [set oxygen oxygen - 1 set pcolor pcolor - 1]]
  ]
  ask patches with [oxygen? = true][if oxygen = 0 [set oxygen? false]]
end

to add-white-cells
  setup-macrophage initial-macrophage
end


to do-plots
  set-current-plot "Plot"
  set-current-plot-pen "viruses"
  plot count virus
  set-current-plot-pen "flesh"
  plot count patches with [flesh? = true]
  
  set-current-plot "Defenses"
  set-current-plot-pen "warned flesh"
  plot count patches with [flesh? = true and defenses = higher-defenses]
end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;I put this part in to render the movies;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to movie
  ;setup
  movie-start "cell movie.mov"
  repeat 100 
  [ movie-grab-graphics 
    go ]
  movie-close
end

to cancel-movie
  movie-cancel
end
;;;;;;;;;;;;;;;;;;;;;you should probably ignore this next part;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to rapture
  ask turtles [disco-party]
  call-down-jesus
end

to disco-party
  set shape "fire"    ;every disco party has cool lights for the Jesus
end

to call-down-jesus
  create-custom-jesus 1 [set shape "Jesus" set size 20 set color random 140]
end
@#$#@#$#@
GRAPHICS-WINDOW
464
10
1167
734
38
38
9.0
1
10
1
1
1
0

CC-WINDOW
5
1216
1176
1311
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
1000
694
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
373
172
472
221
macrophage count
macrophage-count
3
1

MONITOR
286
172
367
221
red cell count
red-cell-count
3
1

BUTTON
187
132
281
165
big sneeze
big-sneeze
NIL
1
T
OBSERVER
T
NIL

BUTTON
200
1169
353
1202
stop white cell production
stop-white-cell-production
T
1
T
OBSERVER
T
NIL

MONITOR
285
226
367
275
virus count
virus-count
3
1

BUTTON
186
172
281
205
stop blood flow
stop-blood-flow
NIL
1
T
OBSERVER
T
NIL

SLIDER
205
1127
377
1160
white-cell-production-rate
white-cell-production-rate
0
100
17
1
1
NIL

SWITCH
13
1065
166
1098
show-dead-cells
show-dead-cells
1
1
-1000

SWITCH
7
1027
158
1060
show-virus-trails
show-virus-trails
1
1
-1000

SWITCH
8
986
180
1019
show-red-cell-trails
show-red-cell-trails
1
1
-1000

BUTTON
187
298
282
331
donate blood
donate-blood
NIL
1
T
OBSERVER
T
NIL

SWITCH
12
1106
164
1139
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
5
1
1
NIL

SWITCH
10
340
128
373
skin-pores?
skin-pores?
0
1
-1000

SLIDER
287
131
424
164
poressness
poressness
1
20
1
1
1
NIL

SLIDER
186
845
323
878
white-cell-smell-radius
white-cell-smell-radius
0
100
7
1
1
NIL

SLIDER
189
901
326
934
virus-smell-radius
virus-smell-radius
0
50
10
1
1
NIL

MONITOR
373
226
458
275
skin cell count
skin-cell-count
3
1

SLIDER
191
1036
328
1069
blood-preasure
blood-preasure
0
100
50
1
1
NIL

SLIDER
212
984
385
1017
heart-beats-per-minute
heart-beats-per-minute
0
300
100
1
1
NIL

SLIDER
5
215
178
248
energy-level-per-neutrients
energy-level-per-neutrients
0
100
10
1
1
NIL

SLIDER
10
379
128
412
sneeze-rate
sneeze-rate
0
1000
262
1
1
NIL

MONITOR
374
284
456
333
confirmed kills
confirmed-kills
9
1

MONITOR
284
336
352
385
time
time
9
1

SWITCH
8
1146
186
1179
show-white-cell-trails
show-white-cell-trails
1
1
-1000

SWITCH
199
1081
312
1114
trail-toggle
trail-toggle
1
1
-1000

SWITCH
141
342
279
375
periodic-sneeze?
periodic-sneeze?
1
1
-1000

SLIDER
6
297
178
330
blood-sensing-radius
blood-sensing-radius
0
10
3
1
1
NIL

BUTTON
363
348
456
381
place virus
place-virus
T
1
T
OBSERVER
T
NIL

MONITOR
284
282
371
331
total virus count
virus-count
3
1

SLIDER
6
256
178
289
flesh-thickness
flesh-thickness
0
100
7
1
1
NIL

SLIDER
7
177
179
210
virus-lifespan
virus-lifespan
0
200
57
1
1
NIL

BUTTON
183
209
276
242
start blood flow
start-blood-flow
NIL
1
T
OBSERVER
T
NIL

SLIDER
142
384
281
417
initial-virus
initial-virus
0
100
50
1
1
NIL

BUTTON
192
250
269
283
go once
go
NIL
1
T
OBSERVER
T
NIL

BUTTON
135
12
268
45
add 10 white cells
add-white-cells
NIL
1
T
OBSERVER
T
NIL

BUTTON
31
854
95
887
NIL
movie
NIL
1
T
OBSERVER
T
NIL

SLIDER
9
425
146
458
cells-per-patch
cells-per-patch
0
100
3
1
1
NIL

BUTTON
16
898
109
931
NIL
cancel-movie
NIL
1
T
OBSERVER
T
NIL

SWITCH
331
390
452
423
show-defeses
show-defeses
1
1
-1000

TEXTBOX
76
948
258
978
These things don't do anything yet

CHOOSER
347
1060
485
1105
virus-types
virus-types
"flu" "cold" "polio" "ebola" "rabies" "rubella" "yellow fever" "measeals" "mumps" "chicken pox"
0

PLOT
514
945
714
1095
plot
NIL
NIL
0.0
10.0
0.0
10.0
true
false
PENS
"flesh" 1.0 0 -16777216 true
"white cells" 1.0 0 -16777216 true
"viruses" 1.0 0 -16777216 true

PLOT
735
944
935
1094
defenses
NIL
NIL
0.0
10.0
0.0
10.0
true
false
PENS
"warned flesh" 1.0 0 -16776961 true

BUTTON
286
49
446
126
begin rapture 2 popes early
rapture
T
1
T
OBSERVER
T
NIL

@#$#@#$#@
WHAT IS IT?
-----------
The program I have written is meant as a simplified version of the immune system.  This program consists of the several different kinds of cells:  macrophages, T-cells, B-cells, mucous membranes helper T-cells as well as antibodies. It also has viruses which attack the system.

Viruses are placed into the system by the user (god).  The viruses follow a simple command which tells them to wander around until they get close enough to a flesh cell to detect it.  Once detected, the virus heads toward the flesh cell.  In reality, viruses don't "`wander around"' they more or less let the forces of their host push them around until they become close enough to the right kind of cell to want to be able to attach on to it.  This process, however, has the same out come: some viruses attach themselves to host cells.  It will cling on to the first flesh cell it comes across where it will atempt to use the cell to produce more viruses.  It starts a hatch count down in the host cell which when it hits zero spits a set number of viruses out of the cell, thus killing the host.  The virus' offspring then go out and cling to the whatever poor host cell they come across.  The everflowing macrophage cells are constantly gobbling up viruses with limited sucess.  The sucess is only enhanced when the virus has antibodies attached to it, allowing for the macrophage to more easily attach itself to the virus.  These antibodies are secreted by the B-cells which also flow around and multiply if near an infection.  They secrete even more antibodies if there is a helper T-cell present which knows that nearby macrophages are consuming the very antigens the B-cells are creating antibodies for.  T-cells are what call for nearby macrophages to come and help if near an infection and they also get rid of infected host cells.  The host cells themselves tell their neighbors (done chemically in reality) to up their defences because of present viruses.  This is the basic model followed by the actual program.  The actual code may be more enlightning especially for one interested in the specifics of the procedures.

HOW TO USE IT
-------------
First set the organism to be as big or small as you want it (the program is set up to work no matter what size you make the organism)  Use the sliders to 


THINGS TO NOTICE
----------------


THINGS TO TRY
-------------
-try making large groups of viruses and see how efficiently the body is able to rid of them.
-try getting rid of some of the red blood cells and see if this effects anything.
-expiriment with different types of viruses and see which ones are stronger.
-can you ever get the organism to die?

EXTENDING THE MODEL
-------------------
Future extensions of this model will include the different types of white blood cells, platelets and other parts of the blood, different shapes of the organism, more factors effecting the health of the organism, and more realistic interworkings of the cells and the viruses.  The observer rather than simply being able to infect the organism with viruses will be able to do other bad things to the organism in future versions such as poking and stabing it where the plateletss will come into play.  Bacteria will also be another kind of infection which can be implemented and more organs such as the spleen and liver will be present.

CREDITS AND REFERENCES
----------------------
This program was written in full by Sean Connolly.  All rights reserved May 2005.  No one is allowed to use this model without giving me lots of money.
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

fire
true
0
Polygon -44544 true false 30 240 90 90 135 165 150 90 165 180 165 225 180 60 195 165 195 225 210 75 255 255 30 255 30 240 90 225 90 195
Polygon -65536 true false 45 240 90 150 135 195 150 180 165 225 180 195 180 165 195 225 195 240 210 210 210 150 240 255 45 240
Polygon -44544 true false 30 240 45 225 45 210 45 240
Polygon -256 true false 45 225 90 195 120 210 135 210 150 225 180 225 180 210 195 240 210 240 210 225 225 240 45 240 45 225

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

jesus
false
0
Circle -7566196 true true 110 5 80
Polygon -7566196 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7566196 true true 127 79 172 94
Polygon -7566196 true true 195 90 240 150 225 180 165 105
Polygon -7566196 true true 105 90 60 150 75 180 135 105
Rectangle -6524078 true false 105 45 120 105
Rectangle -6524078 true false 120 15 135 75
Rectangle -6524078 true false 195 45 180 105
Rectangle -6524078 true false 135 15 195 30
Rectangle -6524078 true false 165 30 195 45
Rectangle -6524078 true false 105 15 120 45
Rectangle -6524078 true false 120 15 165 15
Rectangle -6524078 true false 120 0 180 15
Rectangle -256 true false 150 105 165 195
Rectangle -256 true false 135 135 180 150
Line -65536 false 135 75 165 75
Rectangle -16777216 true false 135 30 150 45
Rectangle -16777216 true false 179 29 164 44
Rectangle -65536 true false 135 0 180 15
Rectangle -6524078 true false 135 0 165 0
Rectangle -6524078 true false 135 0 180 15
Rectangle -6524078 true false 135 75 150 90
Rectangle -6524078 true false 150 75 165 105
Rectangle -6524078 true false 135 71 175 60
Rectangle -6524078 true false 136 90 151 101
Line -65536 false 130 70 175 71
Circle -1 true false 139 32 6
Circle -1 true false 167 33 6

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

sign of the devil
false
0
Polygon -7566196 true true 150 90 75 105 60 150 75 210 105 285 195 285 225 210 240 150 225 105
Polygon -16777216 true false 150 150 90 195 90 150
Polygon -16777216 true false 150 150 210 195 210 150
Polygon -16777216 true false 105 285 135 270 150 285 165 270 195 285
Polygon -7566196 true true 240 150 263 143 278 126 287 102 287 79 280 53 273 38 261 25 246 15 227 8 241 26 253 46 258 68 257 96 246 116 229 126
Polygon -7566196 true true 60 150 37 143 22 126 13 102 13 79 20 53 27 38 39 25 54 15 73 8 59 26 47 46 42 68 43 96 54 116 71 126
Line -256 false 150 165 150 270
Rectangle -256 true false 120 195 195 210
Rectangle -256 true false 150 165 165 270

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
Circle -16711738 true false 105 105 90

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
