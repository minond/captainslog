import * as React from "react"
import { Component, KeyboardEvent } from "react"

import { css, StyleSheet } from "aphrodite"

import { Entry, UnsyncedEntry } from "../definitions"

const KEY_ENTER = 13

const styles = StyleSheet.create({
  wrapper: {
    boxSizing: "border-box",
    padding: "10px",
  },

  tailEntries: {
    borderTop: "1px solid #dadada",
  },

  entry: {
    fontSize: "1.1rem",
    padding: "10px 0",
  },

  input: {
    padding: "10px",
    width: "calc(100% - 24px)",
  }
})

interface Props {
  name: string
  entries?: Entry[]
}

interface State {
  entries: Entry[]
  unsynced: UnsyncedEntry[]
}

export class Logbook extends Component<Props, State> {
  boundOnLogInputKeyPress: (ev: KeyboardEvent<HTMLInputElement>) => void

  constructor(props: Props) {
    super(props)

    this.state = {
      entries: props.entries || [],
      unsynced: [],
    }

    this.boundOnLogInputKeyPress = this.onLogInputKeyPress.bind(this)
  }

  getLogs(): ReadonlyArray<Entry | UnsyncedEntry> {
    const { unsynced, entries } = this.state
    return [...unsynced, ...entries].sort((a, b) =>
      a.createdOn < b.createdOn ? -1 : 1)
  }

  addLog(text: string) {
    const guid = Math.random().toString()
    const createdOn = Date.now()

    this.state.unsynced.push({ guid, text, createdOn })
    this.setState({ unsynced: this.state.unsynced })
  }

  onLogInputKeyPress(ev: KeyboardEvent<HTMLInputElement>) {
    if (ev.charCode === KEY_ENTER) {
      this.addLog(ev.currentTarget.value)
      ev.currentTarget.value = ""
    }
  }

  render() {
    const { name } = this.props
    const logs = this.getLogs().map((log, i) =>
      <div className={css(i ? styles.tailEntries : null, styles.entry)} key={log.guid}>{log.text}</div>)

    return (
      <div className={css(styles.wrapper)}>
        <h1>{name}</h1>

        {logs}

        <input
          className={css(styles.input)}
          type="text"
          onKeyPress={this.boundOnLogInputKeyPress}
        />
      </div>
    )
  }
}
