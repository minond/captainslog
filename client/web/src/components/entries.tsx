import * as React from "react"
import { Component, KeyboardEvent, RefObject } from "react"
import DatePicker from "react-datepicker"

import { css, StyleSheet } from "aphrodite"

import history from "../history"

import { Entry, EntryCreateRequest } from "../definitions/entry"
import { createEntry, retrieveEntriesForBook } from "../service/entry"

import EntryLine from "./entry_line"

import { mediumText } from "../styles"

type MaybeData = { data?: { [index: string]: string } }
type EntryView = Entry | (EntryCreateRequest & MaybeData)
type UnsavedEntry = { at: Date, item: string }

const KEY_ENTER = 13

const styles = StyleSheet.create({
  wrapper: {
    boxSizing: "content-box",
  },

  entries: {
    maxHeight: "calc(100vh - 150px)",
    overflow: "auto",
  },

  tailEntry: {
    borderTop: "1px solid #dadada",
  },

  input: {
    ...mediumText,
    marginLeft: "-10px",
    padding: "10px",
    width: "100%",
  }
})

interface Props {
  date: Date
  guid: string
}

interface State {
  date: Date
  entries: Entry[]
  loaded: boolean
  unsynced: EntryCreateRequest[]
}

export default class Entries extends Component<Props, State> {
  entriesRef: RefObject<HTMLDivElement>
  inputRef: RefObject<HTMLTextAreaElement>
  boundOnEntryInputKeyPress: (ev: KeyboardEvent<HTMLTextAreaElement>) => void

  constructor(props: Props) {
    super(props)
    this.state = { ...this.getInitialState(), date: this.props.date }
    this.entriesRef = React.createRef()
    this.inputRef = React.createRef()
    this.boundOnEntryInputKeyPress = this.onEntryInputKeyPress.bind(this)
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
    if (next.guid !== this.props.guid) {
      this.setState(this.getInitialState(), () =>
        this.loadEntries())
    }
  }

  componentWillMount() {
    this.loadEntries()
  }

  componentDidUpdate() {
    if (this.entriesRef.current) {
      this.entriesRef.current.scrollTop = 0
    }
  }

  componentDidMount() {
    if (this.inputRef.current) {
      this.inputRef.current.focus()
    }
  }

  loadEntries() {
    const { date } = this.state
    const { guid } = this.props
    const now = Math.floor(+date / 1000)
    retrieveEntriesForBook(guid, now).then((entries) =>
      this.setState({ loaded: true, entries }))
  }

  setViewDate(date: Date | null) {
    if (date) {
      const { guid } = this.props
      this.setState({ date }, () => this.loadEntries())
      history.replace(`/book/${guid}/${+date}`)
    }
  }

  getEntries(): ReadonlyArray<EntryView> {
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
    const bookGuid = this.props.guid
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
    const { date } = this.state

    const entries = this.getEntries().map((entry, i) => (
      <EntryLine
        key={entry.guid}
        className={css(i ? styles.tailEntry : null)}
        text={entry.text}
        data={entry.data}
      />))

    return (
      <div className={css(styles.wrapper)}>
        <DatePicker selected={date} onChange={(maybeDate) => this.setViewDate(maybeDate)} />

        <div ref={this.entriesRef} className={css(styles.entries)}>{entries}</div>

        <textarea
          rows={1}
          ref={this.inputRef}
          className={css(styles.input)}
          onKeyPress={this.boundOnEntryInputKeyPress}
        />
      </div>
    )
  }
}
