import * as React from "react"
import * as ReactDOM from "react-dom"
import { BrowserRouter, Route } from "react-router-dom"

import { Books } from "./components/books"
import { Entries } from "./components/entries"

export const Index = () => (
  <div>
    <BrowserRouter>
      <Route path="/" exact component={Books} />
      <Route path="/book/:guid" render={(prop) => {
        let guid = prop.match.params["guid"]
        return <Entries guid={guid} />
      }} />
    </BrowserRouter>
  </div>
)

ReactDOM.render(<Index />, document.getElementById("body"))
