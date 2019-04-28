import * as React from "react"
import DatePicker from "react-datepicker"

import { css, StyleSheet } from "aphrodite"

import { inputField, normalText } from "../styles"

const styles = StyleSheet.create({
  input: {
    ...inputField,
  },

  btn: {
    ...normalText,
    marginLeft: "4px",
  },
})

type Props = {
  date: Date
  onChange: (_: Date) => void
  grouping: Grouping
}

export enum Grouping {
  DAY = 1000 * 60 * 60 * 24,
}

function add(date: Date, grouping: Grouping): Date {
  return new Date(+date + grouping)
}

function sub(date: Date, grouping: Grouping): Date {
  return new Date(+date - grouping)
}

function Btn({ label, action }: { label: string, action: () => void }) {
  return <input className={css(styles.btn)} type="button" onClick={action} value={label} />
}

export default function DateGroupPicker({ grouping, date, onChange }: Props) {
  const handler = (maybeDate: Date | null) => {
    if (maybeDate) {
      onChange(maybeDate)
    }
  }

  return (
    <div>
      <DatePicker
        selected={date}
        className={css(styles.input)}
        onChange={handler}
      />
      <Btn label="prev" action={() => onChange(sub(date, grouping))} />
      <Btn label="next" action={() => onChange(add(date, grouping))} />
      <Btn label="current" action={() => onChange(new Date())} />
    </div>
  )
}
