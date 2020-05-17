//= require action_cable

$(function () {
  const cable = ActionCable.createConsumer("/ws")

  cable.subscriptions.create("JobChannel", { received: handleJobChannelMessage })
})

/**
 * @param {Object} payload
 * @payload {Job} job
 * @payload {Connection} connection
 * @payload {String} job_row_html
 * @payload {String} connection_row_html
 */
function handleJobChannelMessage({
  job,
  connection,
  job_row_html,
  connection_row_html
}) {
  viewConnectionRow(connection, connection_row_html)
  viewJobRow(job, job_row_html)
}

/**
 * @param {Connection} connection
 * @param {String} html
 */
function viewConnectionRow(connection, html) {
  if (hasConnectionRow(connection)) {
    getConnectionRow(connection).replaceWith(html)
  } else {
    $(html).prependTo("[data-connections]");
  }
}

/**
 * @param {Connection} connection
 * @return {jQuery}
 */
function getConnectionRow(connection) {
  return $(`[data-connections] [data-connection-id=${connection.id}]`)
}

/**
 * @param {Connection} connection
 * @return {Boolean}
 */
function hasConnectionRow(connection) {
  return !!getConnectionRow(connection).length
}

/**
 * @param {Connection} connection
 * @param {String} html
 */
function viewJobRow(job, html) {
  if (hasJobRow(job)) {
    getJobRow(job).replaceWith(html)
  } else {
    $(html).prependTo("[data-jobs]");
  }
}

/**
 * @param {Job} job
 * @return {jQuery}
 */
function getJobRow(job) {
  return $(`[data-jobs] [data-job-id=${job.id}]`)
}

/**
 * @param {Job} job
 * @return {Boolean}
 */
function hasJobRow(job) {
  return !!getJobRow(job).length
}
