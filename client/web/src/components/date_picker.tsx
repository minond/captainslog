import * as React from "react"
import ReactDatePicker from "react-datepicker"

/* tslint:disable:no-var-requires */
require("../react-datepicker.css")
/* tslint:enable:no-var-requires */

type Props = {
  date: Date
  onChange: (_: Date) => void
  grouping: Grouping
}

// This should always mimic the Grouping type found in model/book.go.
export enum Grouping {
  NONE,
  DAY,
}

enum Unit {
  DAY = 1000 * 60 * 60 * 24,
}

const GroupUnit: { [index: number]: Unit } = {
  [Grouping.DAY]: Unit.DAY,
}

function add(date: Date, unit: Unit): Date {
  return new Date(+date + unit)
}

function sub(date: Date, unit: Unit): Date {
  return new Date(+date - unit)
}

function Btn({ label, action }: { label: string, action: () => void }) {
  return <input type="button" onClick={action} value={label} />
}

export default function DatePicker({ grouping, date, onChange }: Props) {
  const unit = GroupUnit[grouping] || 0
  const handler = (maybeDate: Date | null) => {
    if (maybeDate) {
      onChange(maybeDate)
    }
  }

  return (
    <div>
      <ReactDatePicker
        selected={date}
        onChange={handler}
      />
      <Btn label="prev" action={() => onChange(sub(date, unit))} />
      <Btn label="next" action={() => onChange(add(date, unit))} />
      <Btn label="current" action={() => onChange(new Date())} />
    </div>
  )
}
