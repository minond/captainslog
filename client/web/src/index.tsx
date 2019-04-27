import * as React from "react"
import * as ReactDOM from "react-dom"
import { BrowserRouter as Router, Route } from "react-router-dom"

import Books from "./components/books"
import Entries from "./components/entries"

export const Index = () => (
  <div>
    <Router>
      <Books />
      <Route exact={true} path="/book/:guid" render={(prop) => {
        let guid = prop.match.params["guid"]
        return <Entries guid={guid} />
      }} />
    </Router>
  </div>
)

ReactDOM.render(<Index />, document.getElementById("body"))
