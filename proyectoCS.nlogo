 turtles-own [
  wealth
  social-class
]
globals [
  funds ;; Account where the money gained by taxing goes
  sum-trades ;; Total amount made by trades
  mean-wealth-mid  ;; Variable that stores the mean wealth of the middle class
  trade-tax ;; Tax applied to trades. In our case 21% (General type of IVA)
]

to setup
  clear-all
  set funds 0
  ask patches [ set pcolor black ]

  ;; Next, we'll create low, mid and high class turtles in the same proportion as in the spanish economy
  let high-count round (population * 0.1)
  let mid-count round (population * 0.75)
  let low-count round (population * 0.15)

  create-turtles high-count [
    set social-class "high"
    set wealth 3000 + 500
    set color green
    set shape "person"
    set heading random 360
    setxy random-xcor random-ycor
  ]

  create-turtles low-count [
    set social-class "low"
    set wealth 900 + 200
    set color red
    set shape "person"
    set heading random 360
    setxy random-xcor random-ycor
  ]

  create-turtles mid-count [
    set social-class "mid"
    set wealth 1100 + 1500
    set color yellow
    set shape "person"
    set heading random 360
    setxy random-xcor random-ycor
  ]

  reset-ticks
end

to go
  set sum-trades 0
  ask turtles [
    set heading heading + random 10
    fd 1
    applytax
    encounter
  ]
  update-plot-2
  share-funds
  update-social-class
  calculate-mean-wealth
  update-plot
  tick
end

to applytax
  ;; Sets a different tax rate for every class and extracts the tax from their wealth to be given to the funds variable
  let tax 0
  if social-class = "high" [
    set tax (wealth * high-tax / 100)
    set wealth wealth - tax
    set funds funds + tax
  ]
  if social-class = "middle" [
    set tax (wealth * mid-tax / 100)
    set wealth wealth - tax
    set funds funds + tax
  ]
  if social-class = "low" [
    set tax (wealth * low-tax / 100)
    set wealth wealth - tax
    set funds funds + tax
  ]
end

to encounter
  ;; Sets an economic encounter between two turtles in the same patch. The amount traded is one fith of the minimum wealth between both turtles. Tax applied
  if (count turtles-here = 2) [
    let n2 one-of other turtles-here
    let trade (min [ wealth ] of turtles-here / 5.0)

    set trade-tax 0.21
    let tax (trade * trade-tax)
    set wealth wealth - trade
    ask n2 [
      set wealth wealth + trade - tax
    ]
    set sum-trades sum-trades + trade
    set funds funds + tax
  ]
end

to share-funds
  ;; Shares funds gained throughout the whole population of turtles. If redistribution is ON, different classes get different amounts
  if ( funds > 0 ) [
    ifelse ( redistribution ) [
      let low-turtles turtles with [ social-class = "low" ]
      let mid-turtles turtles with [ social-class = "mid" ]
      let high-turtles turtles with [ social-class = "high" ]

      let num-low count low-turtles
      let num-mid count mid-turtles
      let num-high count high-turtles

      let share-low ifelse-value (num-low > 0) [ (funds * 0.7) / num-low ] [ 0 ]
      let share-mid ifelse-value (num-mid > 0) [ (funds * 0.25) / num-mid ] [ 0 ]
      let share-high ifelse-value (num-high > 0) [ (funds * 0.05) / num-high ] [ 0 ]

      ask low-turtles [ set wealth wealth + share-low ]
      ask mid-turtles [ set wealth wealth + share-mid ]
      ask high-turtles [ set wealth wealth + share-high ]

      set funds 0
    ]
    [
      let share ( funds / count turtles )
      ask turtles [ set wealth wealth + share ]
      set funds 0
    ]
  ]
end

to update-social-class
  ;; Updates the social class of turtles based on their new wealth
  ask turtles with [wealth < 1000] [
      set social-class "low"
      set color red
  ]
  ask turtles with [wealth >= 1000 and wealth < 3000] [
      set social-class "mid"
      set color yellow
  ]
  ask turtles with [wealth >= 3000] [
      set social-class "high"
      set color green
  ]
end

to calculate-mean-wealth
  ;; Calculates the mean wealth of the middle class in every tick
  let mids turtles with [social-class = "mid"]
  if any? mids[
    set mean-wealth-mid mean [wealth] of mids
  ]
  if not any? mids [
    set mean-wealth-mid 0
  ]
end

to update-plot
  let count-low count turtles with [social-class = "low"]
  let count-mid count turtles with [social-class = "mid"]
  let count-high count turtles with [social-class = "high"]

  set-current-plot "Population Class Over Time"

  set-current-plot-pen "low-class-population"
  plot count-low

  set-current-plot-pen "mid-class-population"
  plot count-mid

  set-current-plot-pen "high-class-population"
  plot count-high
end

to update-plot-2
  set-current-plot "Tax Funds Over Time"

  set-current-plot-pen "tax-funds"

  plot funds
end
@#$#@#$#@
GRAPHICS-WINDOW
193
10
674
492
-1
-1
14.33333333333334
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

SLIDER
7
276
179
309
mid-tax
mid-tax
0
100
100.0
1
1
NIL
HORIZONTAL

SLIDER
7
313
179
346
low-tax
low-tax
0
100
100.0
1
1
NIL
HORIZONTAL

BUTTON
6
13
69
46
NIL
setup\n
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
70
13
133
46
NIL
go\n
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SWITCH
7
201
134
234
redistribution
redistribution
1
1
-1000

SLIDER
7
237
179
270
high-tax
high-tax
0
100
100.0
1
1
NIL
HORIZONTAL

PLOT
688
44
1205
242
Population Class Over Time
Time
Number of Turtles
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"low-class-population" 1.0 0 -2674135 true "" "plot count turtles with [social-class = \"low\"]"
"mid-class-population" 1.0 0 -1184463 true "" "plot count turtles with [social-class = \"mid\"]"
"high-class-population" 1.0 0 -13840069 true "" "plot count turtles with [social-class = \"high\"]"

MONITOR
193
514
312
559
low-class-turtles
count turtles with [social-class = \"low\"]
17
1
11

MONITOR
319
513
433
558
mid-class-turtles
count turtles with [social-class = \"mid\"]
17
1
11

MONITOR
443
513
561
558
high-class-turtles
count turtles with [social-class = \"high\"]
17
1
11

SLIDER
7
351
179
384
population
population
100
1000
1000.0
1
1
NIL
HORIZONTAL

PLOT
690
263
1202
459
Tax Funds Over Time
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"tax-funds" 1.0 0 -13840069 true "" "plot funds"

MONITOR
567
513
741
558
Mean Wealth Of Middle Class
mean-wealth-mid
17
1
11

MONITOR
26
514
185
559
Wealth Made From Trades
sum-trades
17
1
11

@#$#@#$#@
## WHAT IS IT?

Esta simulación recrea lo que sucedería en la sociedad española ajustando diferentes niveles de impuestos según la clase social, la gestión de la redistribución de la riqueza y otros factores.

## HOW IT WORKS

Definimos tres tipos de tortugas: clase baja, media y alta. Cada tipo de tortuga tiene su propia riqueza y tasa impositiva, las cuales pueden variar con el tiempo. La riqueza y la tasa de impuestos dependen de la clase de la tortuga. Las tortugas se mueven por los parches de manera aleatoria y, cuando dos tortugas ocupan el mismo parche, se inicia un intercambio económico. Durante este intercambio, se intercambia una quinta parte de la menor riqueza entre las dos tortugas y se aplican los impuestos a la transacción.

Después de aplicar todos los impuestos y completar los intercambios, antes de avanzar el tiempo (tick), la riqueza generada por la recaudación se redistribuye, y todas las tortugas se reclasifican según su nueva riqueza. También se calcula la riqueza media de la clase media. Esto es útil en casos donde se intentan comparar modelos eficientes que tienden a aumentar la cantidad de personas en la clase media. Al revisar esta variable, podemos comparar qué modelo hace que la clase media sea más próspera.

En cada tick, se actualizan dos gráficos. Un gráfico se encarga de contar la cantidad de tortugas en cada clase social por tick, permitiendo hacer un seguimiento de la evolución de la cantidad de tortugas en cada clase a lo largo del tiempo.

También hay un segundo gráfico que rastrea la cantidad de dinero recaudado por impuestos en los fondos en cada tick. Después de cada tick, el monto se reduce a 0 (por lo tanto, habrá una pequeña caída entre ticks).

## HOW TO USE IT

Se necesita un botón de configuración (setup), que debe ser presionado primero.

Se necesita un botón de inicio (go), que debe ser presionado en segundo lugar.

Se necesita un interruptor para la redistribución. Cuando está ON, redistribuye cantidades diferentes (en nuestro caso, 70% a la clase baja, 25% a la clase media y el restante a la alta) según la clase social. Si está OFF, redistribuye la misma cantidad a todas las tortugas.

Se necesitan deslizadores para cada tipo de impuesto (bajo, medio y alto), junto con un deslizador de población para determinar el número de tortugas que se generarán. Las variables utilizadas son: población, impuesto bajo, impuesto medio e impuesto alto.

Debe añadirse un gráfico con tres indicadores, cada uno correspondiente a una de las clases sociales y con un color asignado. Este gráfico, llamado "Population Class Over Time", debe hacer un seguimiento del número de tortugas en cada clase con el tiempo.

Debe crearse otro gráfico, llamado "Tax Funds Over Time" que rastree la cantidad de riqueza obtenida por los impuestos.

Se necesitan tres monitores para mostrar el número de tortugas en cada clase. Aunque no son estrictamente necesarios, facilitarán el análisis de estos valores.

Otro monitor, aunque no es imprescindible, ayudará a visualizar la riqueza media de la clase media, lo que permitirá comparar qué porcentajes de impuestos aumentan este valor.

Un último monitor rastrea la cantidad de dinero que se ha utilizado para realizar intercambios en cada tick. No es esencial, pero es muy informativo.

## THINGS TO NOTICE

Si la cantidad de ticks es muy grande, la función de redistribución no funcionará tan bien debido a una pérdida acumulativa de riqueza, causada por los porcentajes redondeados para cada clase social.

## THINGS TO TRY

Se recomienda mover los deslizadores. Normalmente, impuestos altos para la clase alta, impuestos medios para la clase media y ninguno para la clase baja funcionan bien.

## EXTENDING THE MODEL

Mejorar la redistribución y también crear entidades más complejas, como empresas y trabajadores públicos, haría que la simulación fuera más realista.

## NETLOGO FEATURES

Se utilizan deslizadores, monitores, botones, interruptores y gráficos.

## RELATED MODELS

Estructura del código y función "encounter" inspiradas en Al Pugh - "A economic inequality ABM".

## CREDITS AND REFERENCES

Al Pugh - "A economic inequality ABM", https://blog.modelingcommons.org/browse/one_model/5269#model_tabs_browse_info
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
