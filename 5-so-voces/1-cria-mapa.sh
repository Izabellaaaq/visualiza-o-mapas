#!/bin/bash

# export PATH=$PATH:./node_modules/.bin/

# a expressão js que decide os fills baseados em uma escala
# EXP_ESCALA='z = d3.scaleSequential(d3.interpolateViridis).domain([0, 100]),
#             d.features.forEach(f => f.properties.fill = z(f.properties["Percentual Aprendizado Adequado (%)"])),
#             d'
# EXP_ESCALA='z = d3.scaleThreshold().domain([1,2,3,4,5]).range(d3.schemePiYG[5]),
#             d.features.forEach(f => {f.properties.fill = z(f.properties["nota_2015"]); f.properties.stroke = "#0f0f0f";}),
#             d'

EXP_ESCALA='z = d3.scaleThreshold().domain([1,2,3,4,5]).range(d3.schemePiYG[5]),
            d.features.forEach(f => {f.properties.fill = z(f.properties["Porcentagem de crianças de 4 e 5 anos na escola"]); f.properties.stroke = "#0f0f0f";}), d'

ndjson-map -r d3 -r d3=d3-scale-chromatic \
  "$EXP_ESCALA" \
< geo4-municipios-e-educacao-basica-simplificado.json \
| ndjson-split 'd.features' \
| geo2svg -n --stroke none -w 1000 -h 600 \
  > aprendizagem-na-pb-choropleth.svg
