import * as React from "react"
import { Component } from "react"

import { css, StyleSheet } from "aphrodite"

import { Entry, EntryCreateRequest } from "../definitions/entry"

import EntryLine from "./entry_line"

type MaybeData = { data?: { [index: string]: string } }
type EntryView = Entry | (EntryCreateRequest & MaybeData)

const styles = StyleSheet.create({
  entries: {
    maxHeight: "calc(100vh - 95px)",
    overflow: "auto",
  },

  tailEntry: {
    borderTop: "1px solid #dadada",
  },
})

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
      className={css(i ? styles.tailEntry : null)}
      text={entry.text}
      data={entry.data}
    />))

  return <div className={css(styles.entries)}>{entries}</div>
}
