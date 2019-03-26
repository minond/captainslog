import * as React from "react"
import { Component, KeyboardEvent, RefObject } from "react"

import { css, StyleSheet } from "aphrodite"

import { Entry, EntryCreateRequest } from "../definitions/entry"

const KEY_ENTER = 13

const styles = StyleSheet.create({
  wrapper: {
    boxSizing: "content-box",
    padding: "10px",
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
  name: string
  entries?: Entry[]
}

interface State {
  entries: Entry[]
  unsynced: EntryCreateRequest[]
}

export class Logbook extends Component<Props, State> {
  entriesRef: RefObject<HTMLDivElement>
  inputRef: RefObject<HTMLInputElement>
  boundOnEntryInputKeyPress: (ev: KeyboardEvent<HTMLInputElement>) => void

  constructor(props: Props) {
    super(props)

    this.state = {
      entries: props.entries || [],
      unsynced: [],
    }

    this.entriesRef = React.createRef()
    this.inputRef = React.createRef()
    this.boundOnEntryInputKeyPress = this.onEntryInputKeyPress.bind(this)
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
    return [...entries, ...unsynced]
  }

  addEntry(text: string) {
    const guid = Math.random().toString()
    this.state.unsynced.push({ guid, text, })
    this.setState({ unsynced: this.state.unsynced })
  }

  onEntryInputKeyPress(ev: KeyboardEvent<HTMLInputElement>) {
    if (ev.charCode === KEY_ENTER) {
      this.addEntry(ev.currentTarget.value)
      ev.currentTarget.value = ""
    }
  }

  render() {
    const { name } = this.props
    const entries = this.getEntries().map((entry, i) =>
      <div className={css(i ? styles.tailEntries : null, styles.entry)} key={entry.guid}>{entry.text}</div>)

    return (
      <div className={css(styles.wrapper)}>
        <h1>{name}</h1>

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
