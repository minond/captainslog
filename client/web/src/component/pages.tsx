import * as React from "react"
import { ReactNode, useEffect } from "react"
import { Link } from "react-router-dom"

import { Books } from "./books"
import { Entries } from "./entries"
import { Query } from "./query"

import { cachedGetBook } from "../remote"

type PageProps = {
  active?: string
  children?: ReactNode
  wide?: boolean
}

const Page = (props: PageProps) => {
  useEffect(() => {
    document.title = `Captain's Log`
  })

  const contentClass = props.wide && "wide"

  return <div className="page-wrapper">
    <div className={"page-header " + (props.active ? "page-header-active" : "")}>
      <div className={`page-header-content ${contentClass}`}>
        <Link to="/">Captain's Log</Link>
        <Link to="/query" className={props.active === "query" ? "active" : ""}>Query</Link>
        <Books active={props.active} />
      </div>
    </div>
    <div className={`page-content ${contentClass}`}>
      {props.children}
    </div>
  </div>
}

export const IndexPage = (props: {}) =>
  <Page />

export const QueryPage = (props: {}) =>
  <Page active="query" wide={true}>
    <Query />
  </Page>

type BookPageProps = {
  guid: string
  date: Date
}

export const BookPage = (props: BookPageProps) => {
  useEffect(() => {
    document.title = "Captain's Log"
    cachedGetBook(props.guid).then((book) => {
      if (book) {
        document.title = `${book.name} - Captain's Log`
      }
    })
  })

  return <>
    <Page active={props.guid}>
      <Entries bookGuid={props.guid} date={props.date} />
    </Page>
  </>
}
