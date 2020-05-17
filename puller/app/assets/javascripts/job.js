//= require action_cable

$(function () {
  const jobId = $(`[data-job-details]`).data("job-details")

  if (!jobId) {
    return
  }

  ActionCable.createConsumer("/ws").subscriptions
    .create({ channel: "JobChannel", job_id: jobId },
            { received: handleJobChannelMessage })
})

/**
 * @param {Object} payload
 * @payload {Job} job
 */
function handleJobChannelMessage({
  job,
}) {
  viewJobDetails(job)
}

/**
 * @param {Job} job
 */
function viewJobDetails(job) {
  const $container = $(`[data-job-details=${job.id}]`)
  const setValue = (attr) => {
    if (job[attr]) {
      $container.find(`[data-job-details-${attr}]`).text(job[attr])
    }
  }

  Object.keys(job).forEach(setValue)
}
