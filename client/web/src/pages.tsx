import * as React from "react"

import { Books } from "./books"
import { Entries } from "./entries"
import { Query } from "./query"

export const IndexPage = (props: {}) =>
  <Books />

export const QueryPage = (props: {}) =>
  <Query />

type BookPageProps = {
  guid: string
  date: Date
}

export const BookPage = (props: BookPageProps) =>
  <>
    <Books />
    <Entries bookGuid={props.guid} date={props.date} />
  </>
