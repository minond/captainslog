import * as React from "react"
import * as ReactDOM from "react-dom"
import { ReactNode, useEffect } from "react"
import { Router, Route, Link, Switch } from "react-router-dom"

import { Books } from "./component/books"
import { Entries } from "./component/entries"
import { LoginForm } from "./component/login_form"
import { ReportView } from "./component/report"

import { logout, isLoggedIn } from "./auth"
import { cachedGetBook } from "./remote"

import history from "./history"

/* tslint:disable:no-var-requires */
require("./index.css")
require("./react-datepicker.css")
/* tslint:enable:no-var-requires */

type PageProps = {
  active?: string
  children?: ReactNode
}

const Page = ({ active, children }: PageProps) => {
  useEffect(() => {
    document.title = `Captain's Log`
  })

  return <div className="page-wrapper">
    <div className="page-header">
      <div className="page-header-content">
        <Link to="/">Captain's Log</Link>
        {isLoggedIn() ?
          <>
            <Books active={active} />
            <div className="logout" onClick={logout}>logout</div>
          </> : null}
      </div>
    </div>
    <div className="page-content">
      {children}
    </div>
  </div>
}

const IndexPage = (props: {}) =>
  <Page>
    {isLoggedIn() ? <ReportView /> : <LoginForm />}
  </Page>

type BookPageProps = {
  guid: string
  date: Date
}

const BookPage = ({ guid, date }: BookPageProps) => {
  useEffect(() => {
    document.title = "Captain's Log"
    cachedGetBook(guid).then((book) => {
      if (book) {
        document.title = `${book.name} - Captain's Log`
      }
    })
  })

  return <>
    <Page active={guid}>
      <Entries bookGuid={guid} date={date} />
    </Page>
  </>
}

const App = () =>
  <div>
    <Router history={history}>
      <Switch>
        <Route exact={true} path="/" component={IndexPage} />
        <Route exact={true} path="/book/:guid/:at?" render={(prop) => {
          let guid = prop.match.params["guid"]
          let at = prop.match.params["at"] || Date.now()
          return <BookPage guid={guid} date={new Date(+at)} />
        }} />
      </Switch>
    </Router>
  </div>

ReactDOM.render(<App />, document.getElementById("body"))
