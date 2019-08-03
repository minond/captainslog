import * as React from "react"
import { useEffect, useState } from "react"
import { KeyboardEvent } from "react"

import history from "../history"

import { Book, Entry, EntryCreateRequest } from "../definitions"
import { cachedGetBook, createEntry, getEntriesForBook } from "../remote"

import { DatePicker, Grouping } from "./date_picker"

const KEY_ENTER = 13

const buildEntryCreateRequest =
  (book: Book, text: string, createdAt: Date): EntryCreateRequest =>
    ({
      bookGuid: book.guid,
      createdAt: createdAt.toISOString(),
      guid: Math.random().toString(),
      text,
    })

const genDatePicker = (date: Date, book: Book | null) =>
  !book || book.grouping === Grouping.NONE ? null :
    <div>
      <DatePicker
        grouping={book.grouping}
        date={date}
        onChange={(d) => history.replace(`/${book.guid}/${+d}`)}
      />
    </div>

type EntryListViewProps = {
  date: Date
  bookGuid: string
}

export function EntryListView(props: EntryListViewProps) {
  const [text, setText] = useState("")
  const [book, setBook] = useState<Book | null>(null)
  const [entries, setEntries] = useState<Entry[]>([])

  const fetchEntries = () =>
    getEntriesForBook(props.bookGuid, props.date).then(setEntries)

  useEffect(() => {
    cachedGetBook(props.bookGuid)
      .then(setBook)
      .then(fetchEntries)
  }, [props.bookGuid, props.date])

  const handleKeyPress = (ev: KeyboardEvent<HTMLTextAreaElement>) => {
    if (ev.charCode !== KEY_ENTER || !book || !text.trim()) {
      return
    }

    createEntry(buildEntryCreateRequest(book, text.trim(), props.date))
      .then(fetchEntries)

    setText("")
    ev.preventDefault()
  }

  return <div>
    <textarea
      rows={1}
      placeholder="Enter a new log!"
      value={text}
      onChange={(e) => setText(e.target.value)}
      onKeyPress={handleKeyPress}
    />
    {genDatePicker(props.date, book)}
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
      <span key={j}>{key}: {val}</span>)

    return (
      <div key={entry.guid}>
        <div>{entry.text}</div>
        <div>{datalist}</div>
      </div>
    )
  })

  return <div>{elems}</div>
}
