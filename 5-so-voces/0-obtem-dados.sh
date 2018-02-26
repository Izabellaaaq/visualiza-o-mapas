# export PATH=$PATH:./node_modules/.bin/

#!/bin/bash

# Cria um geojson simplificado e quantizado dos municípios da PB + dados do QEDU

# OBTER E TRANSFORMAR OS DADOS ======================

# Cria geometria projetada
shp2json UFEBRASIL.shp --encoding 'utf8' \
  | geoproject \
    'd3.geoOrthographic().rotate([54, 14, -2]).fitSize([1000, 600], d)' \
    > geo1-estados.json

# Dados de aprendizagem do QEDU
dsv2json \
  -r ',' \
  -n \
  < dados.csv \
  > dado1_educacao_basica_indice.ndjson

# JOIN Geometria, Dado ======================
# organiza geometria
ndjson-split 'd.features' \
  < geo1-estados.json \
  | ndjson-map 'd.Localidade = d.properties.NM_ESTADO, d' \
  > geo2-br_municipios.ndjson

# organiza variável
ndjson-map 'd.Localidade = d.Localidade.toUpperCase(), d' \
  < dado1_educacao_basica_indice.ndjson \
  > dado2_educacao_basica_indice-comchave.ndjson

# o join
# 1. left join (como em SQL)
# 2. o resultado do join é um array com 2 objetos por linha
# 3. o ndjson-map volta a um objeto por linha
EXP_PROPRIEDADE='d[0].properties = Object.assign({}, d[0].properties, d[1]), d[0]'
ndjson-join --left 'd.Localidade' \
  geo2-br_municipios.ndjson \
  dado2_educacao_basica_indice-comchave.ndjson \
  | ndjson-map \
    "$EXP_PROPRIEDADE" \
  > geo3-municipios-e-educacao-basica.ndjson

# SIMPLIFICA E QUANTIZA ======================
geo2topo -n \
  tracts=- \
< geo3-municipios-e-educacao-basica.ndjson \
| toposimplify -p 1 -f \
| topoquantize 1e5 \
| topo2geo tracts=- \
> geo4-municipios-e-educacao-basica-simplificado.json
