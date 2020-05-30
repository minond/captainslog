//= require jquery
//= require jquery_ujs
//= require action_cable
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
