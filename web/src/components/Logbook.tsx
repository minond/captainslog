import * as React from "react"
import { Component, KeyboardEvent } from "react"

import { css, StyleSheet } from "aphrodite"

import { Log, UnsyncedLog } from "../definitions"

const KEY_ENTER = 13

const styles = StyleSheet.create({
  wrapper: {
    boxSizing: "border-box",
    padding: "10px",
  },

  tailLogs: {
    borderTop: "1px solid #dadada",
  },

  log: {
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
  logs?: Log[]
}

interface State {
  logs: Log[]
  unsynced: UnsyncedLog[]
}

export class Logbook extends Component<Props, State> {
  boundOnLogInputKeyPress: (ev: KeyboardEvent<HTMLInputElement>) => void

  constructor(props: Props) {
    super(props)

    this.state = {
      logs: props.logs || [],
      unsynced: [],
    }

    this.boundOnLogInputKeyPress = this.onLogInputKeyPress.bind(this)
  }

  getLogs(): ReadonlyArray<Log | UnsyncedLog> {
    const { unsynced, logs } = this.state
    return [...unsynced, ...logs].sort((a, b) =>
      a.createdOn < b.createdOn ? -1 : 1)
  }

  addLog(text: string) {
    const guid = Math.random().toString()
    const createdOn = Date.now()
    const updatedOn = createdOn

    this.state.unsynced.push({ guid, text, createdOn, updatedOn })
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
      <div className={css(i ? styles.tailLogs : null, styles.log)} key={log.guid}>{log.text}</div>)

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
