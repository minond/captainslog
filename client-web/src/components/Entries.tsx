import * as React from "react"
import { Component, KeyboardEvent, RefObject } from "react"

import { css, StyleSheet } from "aphrodite"

import { Entry, EntryCreateRequest } from "../definitions/entry"
import { getEntriesForBook } from "../service/entry"

const KEY_ENTER = 13

const styles = StyleSheet.create({
  wrapper: {
    boxSizing: "content-box",
  },

  entries: {
    maxHeight: "80vh",
    overflow: "auto",
  },

  tailEntries: {
    borderTop: "1px solid #dadada",
  },

  entry: {
    fontSize: "1.1rem",
    marginBottom: "10px",
    padding: "10px 0",
  },

  input: {
    fontSize: "1.1rem",
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
  inputRef: RefObject<HTMLInputElement>
  boundOnEntryInputKeyPress: (ev: KeyboardEvent<HTMLInputElement>) => void

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
    getEntriesForBook(this.props.guid).then((entries) =>
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

  getEntries(): ReadonlyArray<Entry | EntryCreateRequest> {
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
    this.state.unsynced.push({ guid, text, createdAt, bookGuid })
    this.setState({ unsynced: this.state.unsynced })
  }

  onEntryInputKeyPress(ev: KeyboardEvent<HTMLInputElement>) {
    if (ev.charCode === KEY_ENTER) {
      this.addEntry(ev.currentTarget.value)
      ev.currentTarget.value = ""
    }
  }

  render() {
    const { loaded } = this.state
    const entries = this.getEntries().map((entry, i) =>
      <div className={css(i ? styles.tailEntries : null, styles.entry)} key={entry.guid}>{entry.text}</div>)

    if (!loaded) {
      return <h1>Loading...</h1>
    }

    return (
      <div className={css(styles.wrapper)}>
        <div ref={this.entriesRef} className={css(styles.entries)}>{entries}</div>

        <input
          ref={this.inputRef}
          className={css(styles.input)}
          type="text"
          onKeyPress={this.boundOnEntryInputKeyPress}
        />
      </div>
    )
  }
}
