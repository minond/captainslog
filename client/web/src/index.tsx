import * as React from "react"
import * as ReactDOM from "react-dom"
import { Router, Route } from "react-router-dom"

import { BookListView } from "./books"
import { EntryListView } from "./entries"
import { QueryView } from "./query"

import history from "./history"

require("./index.css")

type EntryViewProps = {
  bookGuid: string
  date: Date
}

const EntryView = ({ bookGuid, date }: EntryViewProps) =>
  <>
    <BookListView />
    <div className={"column"}>
      <EntryListView bookGuid={bookGuid} date={date} />
    </div>
    <div className={"column"}>
      <QueryView bookGuid={bookGuid} />
    </div>
  </>

export const Index = () => (
  <div>
    <Router history={history}>
      <Route exact={true} path="/" component={BookListView} />
      <Route exact={true} path="/:guid/:at?" render={(prop) =>
        <EntryView
          bookGuid={prop.match.params["guid"]}
          date={new Date(+prop.match.params["at"] || Date.now())}
        />}
      />
    </Router>
  </div>
)

ReactDOM.render(<Index />, document.getElementById("body"))
