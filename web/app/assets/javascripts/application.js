//= require jquery
//= require jquery_ujs

// @param {String} slug
// @param {Array<Number>} ids
// @param {Number} waitTime, defaults to two seconds
function pollForEntryUpdates(slug, ids, waitTime) {
  setTimeout(function () {
    $(ids).each(function (i, id) {
      $.getScript(entryUpdateScriptUrl(slug, id))
    })
  }, waitTime || 2000)
}

// @param {String} slug
// @param {Number} id
// @return {String}
function entryUpdateScriptUrl(slug, id) {
  return "/book/" + slug + "/entry/" + id + ".js"
}

// Sets up an key press event listener on the entry textarea field so that
// pressing enter/return submits the form. This givens us the best of both
// worlds where we can have multiline input for adding multiple entries at a
// time and also being able to submit with pressing enter on destop and mobile.
function setupSubmitFormOnTextareaPressEnter() {
  $("textarea[data-enter-to-submit=true]").on("keypress", function(ev) {
    if (ev.keyCode === 13) {
      $("form").submit()
      ev.preventDefault()
      return false
    }
  })
}

$(setupSubmitFormOnTextareaPressEnter)
