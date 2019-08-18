import * as React from "react"
import ReactDatePicker from "react-datepicker"

// This should always mimic the Grouping type found in model/book.go.
export enum Grouping {
  NONE,
  DAY,
}

enum Unit {
  NONE = 0,
  DAY = 1000 * 60 * 60 * 24,
}

const GroupUnit: { [index: number]: Unit } = {
  [Grouping.NONE]: Unit.NONE,
  [Grouping.DAY]: Unit.DAY,
}

const add = (date: Date, unit: Unit): Date =>
  new Date(+date + unit)

const sub = (date: Date, unit: Unit): Date =>
  new Date(+date - unit)

const Btn = ({ label, action }: { label: string, action: () => void }) =>
  <input type="button" onClick={action} value={label} />

type DatePickerProps = {
  date: Date
  onChange: (_: Date) => void
  grouping: Grouping
}

export const DatePicker = ({ grouping, date, onChange }: DatePickerProps) => {
  const unit = GroupUnit[grouping] || Unit.NONE
  const handler = (maybeDate: Date | null) =>
    maybeDate ? onChange(maybeDate) : null

  return <>
    <ReactDatePicker selected={date} onChange={handler} />
    <Btn label="Previous" action={() => onChange(sub(date, unit))} />
    <Btn label="Next" action={() => onChange(add(date, unit))} />
    <Btn label="Current" action={() => onChange(new Date())} />
  </>
}