import * as React from "react"
import { Component, KeyboardEvent } from "react"

import { css, StyleSheet } from "aphrodite"

import { Entry, UnsyncedEntry } from "../definitions"

const KEY_ENTER = 13

const styles = StyleSheet.create({
  wrapper: {
    boxSizing: "border-box",
    height: "100vh",
    margin: "0 auto",
    maxWidth: "720px",
    padding: "10px",
    position: "relative",
  },

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
    const id = Math.random().toString()
    const createdOn = Date.now()

    this.state.unsynced.push({ id, text, createdOn })
    this.setState({ unsynced: this.state.unsynced })
  }

  onLogInputKeyPress(ev: KeyboardEvent<HTMLInputElement>) {
    if (ev.charCode === KEY_ENTER) {
      this.addLog(ev.currentTarget.value)
      ev.currentTarget.value = ""
    }
  }

  render() {
    let { name } = this.props
    let { unsynced } = this.state

    return (
      <div className={css(styles.wrapper)}>
        <h1>{name}</h1>
        {unsynced.map((log) => <div key={log.id}>{log.text}</div>)}
        <input
          className={css(styles.input)}
          type="text"
          onKeyPress={this.boundOnLogInputKeyPress}
        />
      </div>
    )
  }
}
