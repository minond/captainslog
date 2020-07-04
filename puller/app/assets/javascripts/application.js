//= require jquery
//= require jquery_ujs
//= require action_cable
//= require d3
//= require_self

/**
 * Creates a subscription used to handle model HTML updates.
 *
 * @param {String} channel
 * @param {Object} extraParams, defaults to {}
 */
function streamModelUpdates(channel, extraParams = {}) {
  streamModelUpdates.consumer = streamModelUpdates.consumer ||
    ActionCable.createConsumer("/ws")

  const options = { ...extraParams, channel }
  const handlers = { received: modelUpdateReceived }

  streamModelUpdates.consumer.subscriptions.create(options, handlers)
}

/**
 * Helper method use to handle messages from ActionCable with HTML updates to a
 * component.
 *
 * @param {Object} payload
 * @payload {Number} id
 * @payload {String} model
 * @payload {String} component
 * @payload {String} container
 * @payload {String} html
 */
function modelUpdateReceived({ id, model, component, container, html }) {
  const elemSelector = [
    `[data-id="${id}"]`,
    `[data-model="${model}"]`,
    `[data-component="${component}"]`,
  ].join("")

  const containerSelector = [
    `[data-model="${model}"]`,
    `[data-component="${container}"]`,
  ].join("")

  const $elem = $(elemSelector)

  if ($elem.length) {
    $elem.replaceWith(html)
  } else if (container) {
    $(html).prependTo(containerSelector)
  }
}

/**
 * @param {String} containerSelector
 * @param {Array<Number>} items
 */
function drawLineGraph(containerSelector, items) {
  const data = items
    .map(Math.log2)
    .map((val, pos) => ({ pos, val }))

  const margin = 5
  const outerWidth = 400
  const outerHeight = 30
  const innerWidth = outerWidth - margin
  const innerHeight = outerHeight - margin

  const svg = d3.select(containerSelector)
    .append("svg")
    .attr("width", outerWidth)
    .attr("height", outerHeight)
    .append("g")
    .attr("transform", `translate(${margin}, ${margin})`)

  const xRange = d3.scaleTime()
    .domain(d3.extent(data, (d) => d.pos))
    .range([0, innerWidth])

  const yRange = d3.scaleLinear()
    .domain([0, d3.max(data, (d) => d.val)])
    .range([innerHeight, 0])

  const lineGenerator = d3.line()
    .x((d) => xRange(d.pos))
    .y((d) => yRange(d.val))

  svg.append("path")
    .datum(data)
    .attr("fill", "none")
    .attr("stroke", "steelblue")
    .attr("stroke-width", 1.5)
    .attr("d", lineGenerator)
}
