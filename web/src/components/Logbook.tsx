import * as React from "react"
import { Component, KeyboardEvent } from "react"

import { css, StyleSheet } from "aphrodite"

import { Entry, UnsyncedEntry } from "../definitions"

const KEY_ENTER = 13

const styles = StyleSheet.create({
  input: {
    bottom: "10px",
    padding: "10px",
    position: "absolute",
    width: "100%",
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
    const { unsynced, entries } = this.state
    const logs = [...unsynced, ...entries]

    return (
      <div>
        <h1>{name}</h1>
        {logs.map((log) => <div key={log.guid}>{log.text}</div>)}
        <input
          className={css(styles.input)}
          type="text"
          onKeyPress={this.boundOnLogInputKeyPress}
        />
      </div>
    )
  }
}
