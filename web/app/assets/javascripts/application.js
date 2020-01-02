//= require jquery
//= require jquery_ujs

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
