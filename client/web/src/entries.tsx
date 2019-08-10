import * as React from "react"
import { useEffect, useState } from "react"
import { KeyboardEvent } from "react"

import history from "./history"

import { Book, Entry, EntryCreateRequest, EntriesCreateRequest } from "./definitions"
import { cachedGetBook, createEntries, getEntriesForBook } from "./remote"

import { DatePicker, Grouping } from "./date_picker"

const KEY_ENTER = 13

type EntriesGenerationId = {
  entries: EntryCreateRequest[]
  createdAt: Date
}

const buildEntriesCreateRequest =
  (book: Book, text: string, createdAt: Date): EntriesCreateRequest =>
    text.trim().split("\n").reduce((acc, line) => {
      if (line[0] === "#") {
        acc.createdAt = new Date(Date.parse(line.replace(/^#+/, "")))
      } else if (line) {
        acc.entries.push({
          bookGuid: book.guid,
          createdAt: acc.createdAt.toISOString(),
          guid: Math.random().toString(),
          text: line,
        })
      }
      return acc
    }, { entries: [], createdAt } as EntriesGenerationId)

const genDatePicker = (date: Date, book: Book | null) =>
  !book || book.grouping === Grouping.NONE ? null :
    <DatePicker
      grouping={book.grouping}
      date={date}
      onChange={(d) => history.replace(`/${book.guid}/${+d}`)}
    />

type EntriesProps = {
  date: Date
  bookGuid: string
}

export const Entries = (props: EntriesProps) => {
  const [text, setText] = useState("")
  const [book, setBook] = useState<Book | null>(null)
  const [entries, setEntries] = useState<Entry[]>([])

  const fetchEntries = () =>
    getEntriesForBook(props.bookGuid, props.date).then(setEntries)

  useEffect(() => {
    setEntries([])
    cachedGetBook(props.bookGuid)
      .then(setBook)
      .then(fetchEntries)
  }, [props.bookGuid, props.date])

  const handleKeyPress = (ev: KeyboardEvent<HTMLTextAreaElement>) => {
    if (ev.charCode !== KEY_ENTER || !book || !text.trim()) {
      return
    }

    createEntries(buildEntriesCreateRequest(book, text, props.date))
      .then(fetchEntries)

    setText("")
    ev.preventDefault()
  }

  return <div className="entries">
    <h1>{book ? book.name : "\u00A0"}</h1>
    <div className="entries-action-header">
      <div className="entries-action-header-col">
        <textarea
          rows={1}
          placeholder="Enter a new log!"
          value={text}
          onChange={(e) => setText(e.target.value)}
          onKeyPress={handleKeyPress}
          className="entries-textarea"
        />
      </div>
      <div className="entries-action-header-col">
        {genDatePicker(props.date, book)}
      </div>
    </div>
    <EntryList items={entries} />
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
