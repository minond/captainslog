//= require jquery
//= require jquery_ujs
//= require action_cable
//= require_self

$(function () {
  var cable = ActionCable.createConsumer("/ws")
  cable.subscriptions.create("JobChannel", {
    received: function (data) {
      console.log(data)
    }
  })
})
