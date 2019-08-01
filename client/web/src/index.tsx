import * as React from "react"
import * as ReactDOM from "react-dom"
import { Router, Route } from "react-router-dom"

import BooksNavigation from "./components/books_navigation"
import Entries from "./components/entries"

import history from "./history"

require("./react-datepicker.css")

export const Index = () => (
  <div>
    <Router history={history}>
      <Route exact={true} path="/" component={BooksNavigation} />
      <Route exact={true} path="/:guid/:at?" render={(prop) => {
        let guid = prop.match.params["guid"]
        let at = prop.match.params["at"] || Date.now()
        let date = new Date(+at)
        return <>
          <BooksNavigation active={guid} />
          <Entries bookGuid={guid} date={date} />
        </>
      }} />
    </Router>
  </div>
)

ReactDOM.render(<Index />, document.getElementById("body"))
