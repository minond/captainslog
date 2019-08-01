import * as React from "react"
import { Component } from "react"
import { Link } from "react-router-dom"

interface Props {
  name: string
  active?: boolean
}

export default function BookTitle(props: Props) {
  return (
    <div>
      {props.name}
    </div>
  )
}
