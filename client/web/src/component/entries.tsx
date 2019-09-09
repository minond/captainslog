import * as React from "react"
import { useEffect, useState } from "react"
import { KeyboardEvent } from "react"

import history from "../history"

import { Book, EntriesCreateRequest, Entry, EntryUnsaved } from "../definitions"
import { cachedGetBook, createEntries, getEntriesForBook } from "../remote"

import { DatePicker, Grouping } from "./date_picker"

const KEY_ENTER = 13

type EntriesGenerationId = {
  entries: EntryUnsaved[]
  createdAt: Date
}

const buildEntriesCreateRequest =
  (text: string, createdAt: Date): EntryUnsaved[] =>
    text.trim().split("\n").reduce((acc, line) => {
      if (line[0] === "#") {
        acc.createdAt = new Date(Date.parse(line.replace(/^#+/, "")))
      } else if (line) {
        acc.entries.push({
          createdAt: acc.createdAt.toISOString(),
          text: line,
        })
      }
      return acc
    }, { entries: [], createdAt } as EntriesGenerationId).entries

const noEntriesMessage = (date: Date, grouping: Grouping) => {
  switch (grouping) {
    case Grouping.NONE: return "No entries were found."
    case Grouping.DAY: return `No entries were found on ${date.toDateString()}.`
    default: return
  }
}

const genDatePicker = (date: Date, book: Book | null) =>
  !book || book.grouping === Grouping.NONE ? null :
    <DatePicker
      grouping={book.grouping}
      date={date}
      onChange={(d) => history.replace(`/book/${book.guid}/${+d}`)}
    />

type EntriesProps = {
  bookGuid: string
  date: Date
}

export const Entries = ({ bookGuid, date }: EntriesProps) => {
  const [text, setText] = useState("")
  const [book, setBook] = useState<Book | null>(null)
  const [entries, setEntries] = useState<Entry[]>([])

  const fetchEntries = () =>
    getEntriesForBook(bookGuid, date).then(setEntries)

  useEffect(() => {
    setEntries([])
    cachedGetBook(bookGuid)
      .then(setBook)
      .then(fetchEntries)
  }, [bookGuid, date])

  const handleKeyPress = (ev: KeyboardEvent<HTMLTextAreaElement>) => {
    if (ev.charCode !== KEY_ENTER || !book || !text.trim()) {
      return
    }

    createEntries(book.guid, buildEntriesCreateRequest(text, date))
      .then(fetchEntries)

    setText("")
    ev.preventDefault()
  }

  const dateInput = genDatePicker(date, book)
  const textInput =
    <textarea
      rows={1}
      placeholder="Enter a new log!"
      value={text}
      onChange={(e) => setText(e.target.value)}
      onKeyPress={handleKeyPress}
      className="entries-textarea"
    />

  const title = book ? <h1>{book.name}</h1> : null
  const header = !book ? null :
    <div className="entries-action-header">
      <div className="entries-action-header-col">{textInput}</div>
      <div className="entries-action-header-col">{dateInput}</div>
    </div>

  let content
  if (entries.length) {
    content = <EntryList items={entries} />
  } else if (book) {
    content = <div className="entries-empty">{noEntriesMessage(date, book.grouping)}</div>
  } else {
    content = null
  }

  return <div className="entries">
    {title}
    {header}
    {content}
  </div>
}

type HasCreatedAt = Pick<Entry, "createdAt">

const sortByCreatedAt = (a: HasCreatedAt, b: HasCreatedAt) => {
  if (a.createdAt === b.createdAt) {
    return 0
  } else if (a.createdAt > b.createdAt) {
    return -1
  } else {
    return 1
  }
}

const mmap = <V, R>(xs: { [index: string]: V }, fn: (k: string, v: V, i: number) => R) =>
  Object.keys(xs).map((k, i) => fn(k, xs[k], i))

type EntryListProps = {
  items: Entry[]
}

export const EntryList = ({ items }: EntryListProps) => {
  const sorted = items.sort(sortByCreatedAt)
  const elems = sorted.map((entry, i) => {
    const datalist = !entry.data ? null : mmap(entry.data, (key, val, j) =>
      <span key={j} className="entry-data-item">{key}: {val}</span>)

    return (
      <div key={entry.guid} className="entry">
        <div>{entry.text}</div>
        <div className="entry-data">{datalist}</div>
      </div>
    )
  })

  return <div>{elems}</div>
}
