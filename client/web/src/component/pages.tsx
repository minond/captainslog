import * as React from "react"
import { ReactNode, useEffect } from "react"
import { Link } from "react-router-dom"

import { Books } from "./books"
import { Entries } from "./entries"
import { Query } from "./query"
import { ReportView } from "./report"

import { cachedGetBook } from "../remote"

type PageProps = {
  active?: string
  children?: ReactNode
}

const Page = ({ active, children }: PageProps) => {
  useEffect(() => {
    document.title = `Captain's Log`
  })

  return <div className="page-wrapper">
    <div className={"page-header " + (active ? "page-header-active" : "")}>
      <div className="page-header-content">
        <Link to="/">Captain's Log</Link>
        <Link to="/report" className={active === "report" ? "active" : ""}>Report</Link>
        <Link to="/query" className={active === "query" ? "active" : ""}>Query</Link>
        <Books active={active} />
      </div>
    </div>
    <div className="page-content">
      {children}
    </div>
  </div>
}

export const IndexPage = (props: {}) =>
  <Page>
    <form method="post" action="/" className="login-form">
      <div className="login-form-wrapper">
        <input placeholder="Email" name="email" />
        <input placeholder="Password" name="password" type="password" />
        <button>Login</button>
      </div>
    </form>
  </Page>

export const ReportPage = (props: {}) =>
  <Page active="report">
    <ReportView />
  </Page>

export const QueryPage = (props: {}) =>
  <Page active="query">
    <Query />
  </Page>

type BookPageProps = {
  guid: string
  date: Date
}

export const BookPage = ({ guid, date }: BookPageProps) => {
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
