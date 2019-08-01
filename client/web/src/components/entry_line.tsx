import * as React from "react"
import { HTMLAttributes } from "react"

interface Props {
  text: string
  data?: { [index: string]: string }
}

const mmap = <V, R>(xs: { [index: string]: V }, fn: (k: string, v: V, i: number) => R) =>
  Object.keys(xs).map((k, i) => fn(k, xs[k], i))

export default function EntryLine(props: Props & HTMLAttributes<HTMLDivElement>) {
  const datalist = !props.data ? null : mmap(props.data, (key, val, i) =>
    <span key={i}>{key}: {val}</span>)

  return (
    <div>
      <div>{props.text}</div>
      <div>{datalist}</div>
    </div>
  )
}
