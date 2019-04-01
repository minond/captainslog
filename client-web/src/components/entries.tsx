import * as React from "react"
import { Component, KeyboardEvent, RefObject } from "react"

import { css, StyleSheet } from "aphrodite"

import { Entry, EntryCreateRequest } from "../definitions/entry"
import { createEntry, retrieveEntriesForBook } from "../service/entry"

import { Entry as EntryLine } from "./entry"

type MaybeData = { data?: { [index: string]: string } }
type InMemoryEntry = Entry | (EntryCreateRequest & MaybeData)

const KEY_ENTER = 13

const styles = StyleSheet.create({
  wrapper: {
    boxSizing: "content-box",
  },

  entries: {
    maxHeight: "calc(100vh - 120px)",
    overflow: "auto",
  },

  tailEntry: {
    borderTop: "1px solid #dadada",
  },

  input: {
    fontSize: "1.1rem",
    height: "20px",
    marginLeft: "-10px",
    padding: "10px 8px",
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

export class Entries extends Component<Props, State> {
  entriesRef: RefObject<HTMLDivElement>
  inputRef: RefObject<HTMLTextAreaElement>
  boundOnEntryInputKeyPress: (ev: KeyboardEvent<HTMLTextAreaElement>) => void

  constructor(props: Props) {
    super(props)

    this.state = {
      entries: [],
      loaded: false,
      unsynced: [],
    }

    this.entriesRef = React.createRef()
    this.inputRef = React.createRef()
    this.boundOnEntryInputKeyPress = this.onEntryInputKeyPress.bind(this)
  }

  componentWillMount() {
    retrieveEntriesForBook(this.props.guid).then((entries) =>
      this.setState({ loaded: true, entries }))
  }

  componentDidUpdate() {
    if (this.entriesRef.current) {
      this.entriesRef.current.scrollTop = Number.MAX_SAFE_INTEGER
    }
  }

  componentDidMount() {
    if (this.inputRef.current) {
      this.inputRef.current.focus()
    }
  }

  getEntries(): ReadonlyArray<InMemoryEntry> {
    const { unsynced, entries } = this.state
    return [...entries, ...unsynced].sort((a, b) => {
      if (a.createdAt === b.createdAt) {
        return 0
      } else if (a.createdAt > b.createdAt) {
        return 1
      } else {
        return -1
      }
    })
  }

  addEntry(text: string) {
    const guid = Math.random().toString()
    const createdAt = new Date().toISOString()
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

  onEntryInputKeyPress(ev: KeyboardEvent<HTMLTextAreaElement>) {
    if (ev.charCode === KEY_ENTER) {
      ev.currentTarget.value.split("\n")
        .map((item) => item.trim())
        .filter((item) => !!item)
        .map((part) => this.addEntry(part))

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
          ref={this.inputRef}
          className={css(styles.input)}
          onKeyPress={this.boundOnEntryInputKeyPress}
        />
      </div>
    )
  }
}
