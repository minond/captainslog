import * as React from "react"
import * as ReactDOM from "react-dom"
import { Router, Route } from "react-router-dom"

import { BookListView } from "./books"
import { EntryListView } from "./entries"

import history from "./history"

require("./index.css")

export const Index = () => (
  <div>
    <Router history={history}>
      <Route exact={true} path="/" component={BookListView} />
      <Route exact={true} path="/:guid/:at?" render={(prop) => {
        let guid = prop.match.params["guid"]
        let at = prop.match.params["at"] || Date.now()
        let date = new Date(+at)
        return <>
          <BookListView />
          <EntryListView bookGuid={guid} date={date} />
        </>
      }} />
    </Router>
  </div>
)

ReactDOM.render(<Index />, document.getElementById("body"))
