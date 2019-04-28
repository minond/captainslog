import * as React from "react"
import * as ReactDOM from "react-dom"
import { Router, Route } from "react-router-dom"

import Books from "./components/books"
import Entries from "./components/entries"

import history from "./history"

require("./index.css")
require("./react-datepicker.css")

export const Index = () => (
  <div>
    <Router history={history}>
      <Books />
      <Route exact={true} path="/book/:guid/:at?" render={(prop) => {
        let guid = prop.match.params["guid"]
        let at = prop.match.params["at"] || Date.now()
        let date = new Date(+at)
        return <Entries guid={guid} date={date} />
      }} />
    </Router>
  </div>
)

ReactDOM.render(<Index />, document.getElementById("body"))
