import * as React from "react"
import { act } from "react-dom/test-utils"
import { mount } from "enzyme"

import "./testsetup"

import { EntryList } from "./entries"

test("snapshot EntryList", () => {
  const day = new Date(1566096667888).toString()
  const entries = [
    { guid: "e1", text: "entry #1", createdAt: day, updatedAt: day, data: { a: "A1", b: "B1", c: "C1" } },
    { guid: "e2", text: "entry #2", createdAt: day, updatedAt: day, data: { a: "A2", b: "B2", c: "C2" } },
    { guid: "e3", text: "entry #3", createdAt: day, updatedAt: day, data: { a: "A3", b: "B3", c: "C3" } },
  ]
  const component = mount(<EntryList items={entries} />)
  expect(component).toMatchSnapshot()
})
