import * as React from "react"
import * as ReactDOM from "react-dom"
import { Router, Route, Switch } from "react-router-dom"

import { BookPage, IndexPage, ReportPage, QueryPage } from "./component/pages"

import history from "./history"

/* tslint:disable:no-var-requires */
require("./index.css")
require("./react-datepicker.css")
/* tslint:enable:no-var-requires */

export const Index = () => (
  <div>
    <Router history={history}>
      <Switch>
        <Route exact={true} path="/" component={IndexPage} />
        <Route exact={true} path="/report" component={ReportPage} />
        <Route exact={true} path="/query" component={QueryPage} />
        <Route exact={true} path="/:guid/:at?" render={(prop) => {
          let guid = prop.match.params["guid"]
          let at = prop.match.params["at"] || Date.now()
          return <BookPage guid={guid} date={new Date(+at)} />
        }} />
      </Switch>
    </Router>
  </div>
)

ReactDOM.render(<Index />, document.getElementById("body"))
