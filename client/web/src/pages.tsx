import * as React from "react"
import { ReactNode } from "react"
import { Link } from "react-router-dom"

import { Books } from "./books"
import { Entries } from "./entries"
import { Query } from "./query"

type PageProps = {
  active?: string
  children?: ReactNode
}

const Page = (props: PageProps) =>
  <div className="page-wrapper">
    <div className={"page-header " + (props.active ? "page-header-active" : "")}>
      <div className="page-header-content">
        <span className="logo">Captain's log</span>
        <Link to="/" className={props.active === "home" ? "active" : ""}>Home</Link>
        <Link to="/query" className={props.active === "query" ? "active" : ""}>Query</Link>
        <Books active={props.active} />
      </div>
    </div>
    <div className="page-content">
      {props.children}
    </div>
  </div>

export const IndexPage = (props: {}) =>
  <Page active="home" />

export const QueryPage = (props: {}) =>
  <Page active="query">
    <Query />
  </Page>

type BookPageProps = {
  guid: string
  date: Date
}

export const BookPage = (props: BookPageProps) =>
  <Page active={props.guid}>
    <Entries bookGuid={props.guid} date={props.date} />
  </Page>