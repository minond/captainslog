import * as React from "react"
import { Component, KeyboardEvent, RefObject } from "react"

import { css, StyleSheet } from "aphrodite"

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
  guid: string
}

interface State {
  loaded: boolean
  entries: Entry[]
  unsynced: EntryCreateRequest[]
}

export default class Entries extends Component<Props, State> {
  entriesRef: RefObject<HTMLDivElement>
  inputRef: RefObject<HTMLTextAreaElement>
  boundOnEntryInputKeyPress: (ev: KeyboardEvent<HTMLTextAreaElement>) => void

  constructor(props: Props) {
    super(props)
    this.state = this.getInitialState()
    this.entriesRef = React.createRef()
    this.inputRef = React.createRef()
    this.boundOnEntryInputKeyPress = this.onEntryInputKeyPress.bind(this)
  }

  getInitialState(): State {
    return {
      entries: [],
      loaded: false,
      unsynced: [],
    }
  }

  componentWillReceiveProps(next: Props) {
    if (next.guid != this.props.guid) {
      this.setState(this.getInitialState(), () =>
        this.componentWillMount())
    }
  }

  componentWillMount() {
    const now = Math.floor(Date.now() / 1000)
    retrieveEntriesForBook(this.props.guid, now).then((entries) =>
      this.setState({ loaded: true, entries }))
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
      }, {at: new Date(), items: []})

      this.addEntries(processed.items)

      ev.currentTarget.value = ""
      ev.preventDefault()
    }
  }

  render() {
    const entries = this.getEntries().map((entry, i) => (
      <EntryLine
        key={entry.guid}
        className={css(i ? styles.tailEntry : null)}
        text={entry.text}
        data={entry.data}
      />))

    return (
      <div className={css(styles.wrapper)}>
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
