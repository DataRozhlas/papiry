return if window.location.hash != \#stack
sum = -> it.reduce (curr, prev = 0) -> prev + curr
container = d3.select ig.containers.base
  ..classed \stack yes
data = d3.tsv.parse ig.data.naklady, (row) ->
  for field, value of row
    row[field] = parseInt value, 10 if field != "Úřad"
  row['displayed'] = ['Tonery' 'Náklady na papír' 'Servis' 'Tiskárny' 'Software'].map (category) ->
    count = row[category]
    relative = row[category] / row['Počet papírů']
    {category, count, relative}
  row['sort1'] = sum (row.displayed.slice 0, 2 .map (.relative))
  row.sum = row['sort2'] = sum (row.displayed.map (.relative))
  row

yScale = d3.scale.linear!
  ..domain [0 d3.max data.map -> it['Počet papírů']]
  ..range [0 100]

data.sort (a, b) -> b.sort1 - a.sort1
lineHeight = 36px
data.forEach (it, i) ->
  it.top = i * lineHeight


xScale = d3.scale.linear!
  ..domain [0 d3.max data.map (.sum)]
  ..range [0 600]

container.append \ul
  ..selectAll \li .data data .enter!append \li
    ..style \top -> "#{it.top}px"
    ..append \span
      ..attr \class \title
      ..html -> it['Úřad']
    ..append \div
      ..attr \class \bar
      ..selectAll \div.item .data (.displayed) .enter!append \div
        ..attr \class \item
        ..style \width -> "#{xScale it.relative}px"
      ..append \div
        ..attr \class "count service"
        ..style \left -> "#{xScale it.sort1}px"
        ..html -> "#{ig.utils.formatNumber it.sort1, 2} Kč"
      ..append \div
        ..attr \class "count all"
        ..style \left -> "#{xScale it.sort2}px"
        ..html -> "#{ig.utils.formatNumber it.sort2, 2} Kč"
