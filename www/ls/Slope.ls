return if window.location.hash != \#slope
container = d3.select ig.containers.base
data = d3.tsv.parse ig.data.objemy, (row) ->
  for i in <[2012 2013 2014]>
    row[i] = parseInt row[i], 10
  row.start = row.2012
  row.end = row.2014 || row.2013
  row

fullWidth = 610
fullHeight = 600
margin = top: 20 right: 390 bottom: 20 left: 40
width = fullWidth - margin.left - margin.right
height = fullHeight - margin.top - margin.bottom
yScale = d3.scale.linear!
  ..domain [429000, 12931000]
  ..range [height, 0]

path = d3.svg.line!
  ..x (d, i) -> i * width
  ..y -> yScale it

color = d3.scale.threshold!
  ..domain [1.5 1.1 0.9 0.6].reverse!
  ..range ['rgb(215,25,28)','rgb(253,174,97)','rgb(230,230,0)','rgb(166,217,106)','rgb(26,150,65)'].reverse!

svg = container.append \svg
  ..attr {width:fullWidth, height:fullHeight}
drawing = svg.append \g
  .attr \transform "translate(#{margin.left},#{margin.top})"
drawing.selectAll \g.urad.black .data data .enter!append \g
  ..attr \class "urad black"
  ..append \circle
    ..attr \cy -> yScale it.start
    ..attr \r 3
  ..append \circle
    ..attr \cy -> yScale it.end
    ..attr \cx width
    ..attr \r 3
  ..append \path
    ..attr \data-name -> it.urad
    ..attr \data-pago -> it.end / it.start
    ..attr \d -> path [it.start, it.end]
uradG = drawing.selectAll \g.urad.color .data data .enter!append \g
  ..attr \class "urad color"
  ..append \path
    ..attr \stroke -> color it.end / it.start
    ..attr \data-name -> it.urad
    ..attr \data-pago -> it.end / it.start
    ..attr \d -> path [it.start, it.end]
  ..append \circle
    ..attr \cy -> yScale it.start
    ..attr \r 3
    ..attr \fill -> color it.end / it.start
  ..append \circle
    ..attr \cy -> yScale it.end
    ..attr \cx width
    ..attr \r 3
    ..attr \fill -> color it.end / it.start
  ..append \text
    ..attr \class "count start"
    ..attr \x -10
    ..attr \y -> yScale it.start
    ..attr \dy 5
    ..attr \text-anchor \end
    ..text -> ig.utils.formatNumber it.start / 1e6, 1
  ..append \text
    ..attr \class \name
    ..attr \x width + 10
    ..attr \dy -4
    ..text (.urad)
    ..attr \y -> yScale it.end
  ..append \text
    ..attr \class \count
    ..attr \x width + 10
    ..attr \dy 14
    ..text ->
      perc = it.end / it.start
      str = if perc > 1
        "+#{ig.utils.formatNumber 100 * (perc - 1)} %"
      else
        "-#{ig.utils.formatNumber Math.abs 100 * (perc - 1)} %"
      "#{ig.utils.formatNumber it.end / 1e6, 1} milionů listů papíru (#str)"
    ..attr \y -> yScale it.end

points = []
for datum in data
  points.push {datum, value: datum.start}, {datum, value: datum.end}

highlightUrad = ({{datum:urad}:point}) ->
  uradG.classed \preselected -> it is urad
downlightUrad = ->
  uradG.classed \preselected (d, i) -> i in [4 11 19 23]
polygon = -> "M#{it.join "L"}Z"
voronoi = d3.geom.voronoi!
    ..x (d, i) ~> margin.left + (i % 2) * width
    ..y ~> margin.top + yScale it.value
    ..clipExtent [[0, 0], [fullWidth, fullHeight]]
voronoiPolygons = voronoi points
  .filter -> it


voronoiSvg = container.append \svg
  ..attr {width:fullWidth, height:fullHeight}
  ..attr \class \voronoi
  ..selectAll \path .data voronoiPolygons .enter!append \path
    ..attr \d polygon
    ..on \mouseover highlightUrad
    ..on \touchstart highlightUrad
    ..on \mouseout downlightUrad

downlightUrad!
