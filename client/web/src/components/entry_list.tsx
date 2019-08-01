import * as React from "react"
import { Component } from "react"

import { Entry, EntryCreateRequest } from "../definitions/entry"

import EntryLine from "./entry_line"

type MaybeData = { data?: { [index: string]: string } }
type EntryView = Entry | (EntryCreateRequest & MaybeData)

interface Props {
  items: EntryView[]
}

export default function EntryList({ items }: Props) {
  const sorted = items.sort((a, b) => {
    if (a.createdAt === b.createdAt) {
      return 0
    } else if (a.createdAt > b.createdAt) {
      return -1
    } else {
      return 1
    }
  })

  const entries = sorted.map((entry, i) => (
    <EntryLine
      key={entry.guid}
      text={entry.text}
      data={entry.data}
    />))

  return <div>{entries}</div>
}
