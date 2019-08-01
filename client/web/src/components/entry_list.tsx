import * as React from "react"
import { Component } from "react"

import { Entry, EntryCreateRequest } from "../definitions/entry"

type MaybeData = { data?: { [index: string]: string } }
type EntryView = Entry | (EntryCreateRequest & MaybeData)

interface Props {
  items: EntryView[]
}

const mmap = <V, R>(xs: { [index: string]: V }, fn: (k: string, v: V, i: number) => R) =>
  Object.keys(xs).map((k, i) => fn(k, xs[k], i))

const sortByCreatedAt = (a: EntryView, b: EntryView) => {
  if (a.createdAt === b.createdAt) {
    return 0
  } else if (a.createdAt > b.createdAt) {
    return -1
  } else {
    return 1
  }
}

export default function EntryList({ items }: Props) {
  const sorted = items.sort(sortByCreatedAt)
  const elems = sorted.map((entry, i) => {
    const datalist = !entry.data ? null : mmap(entry.data, (key, val, i) =>
      <span key={i}>{key}: {val}</span>)

    return (
      <div key={entry.guid}>
        <div>{entry.text}</div>
        <div>{datalist}</div>
      </div>
    )
  })

  return <div>{elems}</div>
}
