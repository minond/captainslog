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

enum UNIT {
  DAY = 1000 * 60 * 60 * 24,
}

function add(date: Date, unit: UNIT): Date {
  return new Date(+date + unit)
}

function sub(date: Date, unit: UNIT): Date {
  return new Date(+date - unit)
}

export default function DateGroupPicker({ date, onChange }: Props) {
  return (
    <div>
      <div onClick={() => onChange(sub(date, UNIT.DAY))}>prev</div>
      <DatePicker
        selected={date}
        className={css(styles.input)}
        onChange={(maybeDate) => {
          if (maybeDate) {
            onChange(maybeDate)
          }
        }}
      />
      <div onClick={() => onChange(add(date, UNIT.DAY))}>next</div>
    </div>
  )
}
