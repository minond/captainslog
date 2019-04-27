import * as React from "react"
import DatePicker from "react-datepicker"

import { css, StyleSheet } from "aphrodite"

import { inputField } from "../styles"

const styles = StyleSheet.create({
  input: {
    ...inputField,
    textAlign: "center",
    width: "100%",
  },
})

type Props = {
  date: Date
  onChange: (_: Date) => void
}

export default function DateGroupPicker({ date, onChange }: Props) {
  return (
    <DatePicker
      selected={date}
      className={css(styles.input)}
      onChange={(maybeDate) => {
        if (maybeDate) {
          onChange(maybeDate)
        }
      }}
    />
  )
}
