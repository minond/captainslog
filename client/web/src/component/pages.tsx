import * as React from "react"
import { ReactNode, useEffect } from "react"
import { Link } from "react-router-dom"

import { Books } from "./books"
import { Entries } from "./entries"
import { Query } from "./query"
import { Report } from "./report"

import { cachedGetBook } from "../remote"

type PageProps = {
  active?: string
  children?: ReactNode
  wide?: boolean
}

const Page = ({ active, wide, children }: PageProps) => {
  useEffect(() => {
    document.title = `Captain's Log`
  })

  const contentClass = wide && "wide"

  return <div className="page-wrapper">
    <div className={"page-header " + (active ? "page-header-active" : "")}>
      <div className={`page-header-content ${contentClass}`}>
        <Link to="/">Captain's Log</Link>
        <Link to="/report" className={active === "report" ? "active" : ""}>Report</Link>
        <Link to="/query" className={active === "query" ? "active" : ""}>Query</Link>
        <Books active={active} />
      </div>
    </div>
    <div className={`page-content ${contentClass}`}>
      {children}
    </div>
  </div>
}

export const IndexPage = (props: {}) =>
  <Page />

export const ReportPage = (props: {}) =>
  <Page active="report" wide={true}>
    <Report />
  </Page>

export const QueryPage = (props: {}) =>
  <Page active="query" wide={true}>
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
