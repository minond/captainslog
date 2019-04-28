import * as React from "react"
import { Component, KeyboardEvent, RefObject } from "react"

import { css, StyleSheet } from "aphrodite"

import history from "../history"

import { Book } from "../definitions/book"
import { Entry, EntryCreateRequest } from "../definitions/entry"
import { createEntry, getEntriesForBook, getBook } from "../remote"

import BookTitle from "./book_title"
import DateGroupPicker, { Grouping } from "./date_group_picker"
import EntryLine from "./entry_line"
import EntryList from "./entry_list"
import FieldLabel from "./field_label"

import { inputField, textAreaField } from "../styles"

type MaybeData = { data?: { [index: string]: string } }
type EntryView = Entry | (EntryCreateRequest & MaybeData)
type UnsavedEntry = { at: Date, item: string }

const KEY_ENTER = 13

const styles = StyleSheet.create({
  wrapper: {
    boxSizing: "content-box",
  },

  entryInput: {
    ...textAreaField,
    marginBottom: "10px",
    width: "100%",
  },
})

interface Props {
  date: Date
  bookGuid: string
}

interface State {
  date: Date
  book?: Book
  entries: Entry[]
  loaded: boolean
  unsynced: EntryCreateRequest[]
}

export default class Entries extends Component<Props, State> {
  boundOnEntryInputKeyPress: (ev: KeyboardEvent<HTMLTextAreaElement>) => void
  boundSetViewDate: (date: Date) => void

  constructor(props: Props) {
    super(props)
    this.state = { ...this.getInitialState(), date: this.props.date }
    this.boundOnEntryInputKeyPress = this.onEntryInputKeyPress.bind(this)
    this.boundSetViewDate = this.setViewDate.bind(this)
  }

  getInitialState(): State {
    return {
      date: new Date(),
      entries: [],
      loaded: false,
      unsynced: [],
    }
  }

  componentWillReceiveProps(next: Props) {
    const sameBook = next.bookGuid === this.props.bookGuid
    const sameDate = +next.date === +this.props.date

    if (!sameBook) {
      this.setState(this.getInitialState(), () =>
        this.loadData(true))
    } else if (!sameDate) {
      this.setViewDate(next.date)
    }
  }

  componentWillMount() {
    this.loadData(true)
  }

  loadData(withMetadata: boolean) {
    const { date } = this.state
    const { bookGuid } = this.props
    const now = Math.floor(+date / 1000)

    if (withMetadata) {
      getBook(bookGuid).then((book) =>
        getEntriesForBook(bookGuid, now).then((entries) =>
          this.setState({ loaded: true, entries, book })))

      return
    }

    getEntriesForBook(bookGuid, now).then((entries) =>
      this.setState({ loaded: true, entries }))
  }

  setViewDate(date: Date) {
    const { bookGuid } = this.props
    this.setState({ date }, () => this.loadData(false))
    history.replace(`/book/${bookGuid}/${+date}`)
  }

  getEntries(): EntryView[] {
    const { unsynced, entries } = this.state
    return [...entries, ...unsynced].sort((a, b) => {
      if (a.createdAt === b.createdAt) {
        return 0
      } else if (a.createdAt > b.createdAt) {
        return -1
      } else {
        return 1
      }
    })
  }

  addEntry(text: string, at: Date) {
    const guid = Math.random().toString()
    const createdAt = at.toISOString()
    const bookGuid = this.props.bookGuid
    const entry = { guid, text, createdAt, bookGuid }

    this.state.unsynced.push(entry)
    this.setState({ unsynced: this.state.unsynced }, () =>
      createEntry(entry).then((res) => {
        const { entries } = this.state
        let { unsynced } = this.state

        entries.push(res.entry)
        unsynced = unsynced.filter((item) => item.guid !== res.guid)

        this.setState({ unsynced, entries })
      }))
  }

  addEntries(entries: UnsavedEntry[]) {
    const prev = new Promise((ok, _) => ok())

    while (entries.length) {
      ((entry?: UnsavedEntry) => {
        if (entry) {
          prev.then(() => {
            this.addEntry(entry.item, entry.at)
          })
        }
      })(entries.pop())
    }
  }

  parseDate(line: string): Date | null {
    if (line[0] === "#") {
      const match = line.match(/\d{4}-\d{2}-\d{2}/)

      if (match && match[0]) {
        const date = new Date(match[0] + " 00:00:00")

        if (!isNaN(date.getTime())) {
          return date
        }
      }
    }

    return null
  }

  onEntryInputKeyPress(ev: KeyboardEvent<HTMLTextAreaElement>) {
    if (ev.charCode === KEY_ENTER) {
      const { date } = this.state

      const lines = ev.currentTarget.value.split("\n")
        .map((line) => line.trim())
        .filter((line) => !!line)

      const processed = lines.reduce(({at, items}: { at: Date; items: UnsavedEntry[]; }, item) => {
        const dateMaybe = this.parseDate(item)
        if (dateMaybe !== null) {
          return {at: dateMaybe, items}
        } else {
          return {at, items: [{at, item}, ...items]}
        }
      }, {at: date, items: []})

      this.addEntries(processed.items)

      ev.currentTarget.value = ""
      ev.preventDefault()
    }
  }

  render() {
    const { date, book } = this.state
    const grouping = book ? book.grouping : Grouping.DAY

    const textarea = <textarea
      rows={1}
      className={css(styles.entryInput)}
      onKeyPress={this.boundOnEntryInputKeyPress}
    />

    const datePicker = grouping === Grouping.NONE ? null :
      <DateGroupPicker grouping={grouping} date={date} onChange={this.boundSetViewDate} />

    return (
      <div className={css(styles.wrapper)}>
        {book && <BookTitle guid={book.guid} name={book.name} />}
        <FieldLabel text="New entry">{textarea}</FieldLabel>
        <FieldLabel text="Date selection" />
        {datePicker}
        <EntryList items={this.getEntries()} />
      </div>
    )
  }
}
