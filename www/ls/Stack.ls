return if window.location.hash != \#stack
sum = -> it.reduce (curr, prev = 0) -> prev + curr
container = d3.select ig.containers.base
  ..classed \stack yes
data = d3.tsv.parse ig.data.naklady, (row) ->
  for field, value of row
    row[field] = parseInt value, 10 if field != "Úřad"
  row.count = row['Počet papírů']
  row['displayed'] = ['Tonery' 'Náklady na papír' 'Servis' 'Tiskárny' 'Software'].map (category) ->
    count = row[category] || 0
    relative = (row[category] || 0) / row.count
    {category, count, relative}
  row['sort1'] = sum (row.displayed.slice 0, 2 .map (.relative))
  row.sum = row['sort2'] = sum (row.displayed.map (.relative))
  row


lineHeight = 36px


xScale = d3.scale.linear!
  ..domain [0 d3.max data.map (.sum)]
  ..range [0 550]

paperScale = d3.scale.linear!
  ..domain [0 12e6]
  ..range [0 480]


currentOrder = null
reorder = (field) ->
  field ?= if currentOrder == "sort1" then "sort2" else "sort1"
  currentOrder := field
  list.attr \class field
  data
    .sort (a, b) -> b[field] - a[field]
    .forEach (it, i) -> it.top = i * lineHeight
  listItems.style \top -> "#{it.top}px"
  orderButton.html if field == "sort1" then "Seřadit podle celkových nákladů" else "Seřadit podle spotřebních nákladů"

orderButton = container.append \button
  ..attr \class \reorder
  ..on \click reorder
list = container.append \ul
listItems = list.selectAll \li .data data .enter!append \li
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
    ..append \svg
      ..attr \width -> paperScale it.count
      ..attr \height 4
      ..append \line
        ..attr \x2 -> paperScale it.count

reorder 'sort1'
