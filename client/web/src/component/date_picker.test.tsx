import * as React from "react"
import { act } from "react-dom/test-utils"
import { mount } from "enzyme"

import "./testsetup"

import { DatePicker, Grouping } from "./date_picker"

test("snapshot DatePicker (no grouping)", () => {
  const date = new Date(1566096667888)
  const onChange = (_: Date) => {}
  const grouping = Grouping.NONE
  const component = mount(<DatePicker date={date} onChange={onChange} grouping={grouping} />)
  expect(component).toMatchSnapshot()
})

test("snapshot DatePicker (daily grouping)", () => {
  const date = new Date(1566096667888)
  const onChange = (_: Date) => {}
  const grouping = Grouping.DAY
  const component = mount(<DatePicker date={date} onChange={onChange} grouping={grouping} />)
  expect(component).toMatchSnapshot()
})
