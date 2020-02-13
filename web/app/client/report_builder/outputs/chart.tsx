import * as React from "react"
import { useEffect, useState, useRef } from "react"

import { QueryResults, QueryResult } from "../../definitions"
import { stringOf, numberOf, NO_RESULTS } from "./utils"

const TIGHT_FIT_CONTAINER_WIDTH_MAX = 400 // A container that is this wide or less is considered to be "small".
const TIGHT_FIT_DATUM_LENGTH_MIN = 50 // There must be at least this many items before the "tight fit" is used.
const TIGHT_FIT_BORDER_WIDTH = 1
const TIGHT_FIT_ITEM_PADDING = 4
const CONFY_FIT_BORDER_WIDTH = 2
const CONFY_FIT_ITEM_PADDING = 6

type ChartRow = {
  id: string
  x: {
    label: string
    value: number
  }
  y: number
}

type ChartData = {
  datum: ChartRow[],
  diffX: number
  diffY: number
  maxX: number
  minX: number
  maxY: number
  minY: number
}

const normalizeResults = (results: QueryResults): ChartData | undefined => {
  if (!results.results) {
    return
  }

  if (results.columns.length < 2) {
    return
  }

  const datum = results.results.map((cell: QueryResult[], i) => {
    return {
      id: Math.random().toString(),
      x: {
        label: stringOf(cell[0]),
        value: numberOf(cell[0]),
      },
      y: numberOf(cell[1]),
    }
  }).sort((a, b) => {
    if (a.x.value > b.x.value) {
      return 1
    } else if (a.x.value < b.x.value) {
      return -1
    }

    return 0
  })

  const X_PADDING = 10
  const Y_PADDING = X_PADDING

  const xs = datum.map((row) => row.x.value)
  const ys = datum.map((row) => row.y)

  const minX = Math.min.apply(Math, xs) - X_PADDING
  const maxX = Math.max.apply(Math, xs) + X_PADDING
  const minY = Math.min.apply(Math, ys) - Y_PADDING
  const maxY = Math.max.apply(Math, ys) + Y_PADDING

  const diffX = maxX - minX
  const diffY = maxY - minY

  return { datum, diffX, diffY, minX, maxX, minY, maxY }
}

const buildChartRow = (containerWidth: number, index: number, row: ChartRow, chartData: ChartData) => {
  let width
  let left
  let borderWidth
  let itemPadding

  const datumLength = chartData.datum.length
  const isSmallView = containerWidth <= TIGHT_FIT_CONTAINER_WIDTH_MAX
  const useTightFit = isSmallView && datumLength >= TIGHT_FIT_DATUM_LENGTH_MIN

  if (useTightFit) {
    borderWidth = TIGHT_FIT_BORDER_WIDTH
    itemPadding = TIGHT_FIT_ITEM_PADDING
  } else {
    borderWidth = CONFY_FIT_BORDER_WIDTH
    itemPadding = CONFY_FIT_ITEM_PADDING
  }

  if (datumLength === 1) {
    width = containerWidth - (borderWidth * 2)
    left = 0
  } else {
    const maxWidth = containerWidth / datumLength
    width = maxWidth - itemPadding
    left = index * maxWidth
  }

  const height = row.y
  const style = { height, width, left, borderWidth }
  const title = `${row.x.label}: ${row.y}`
  return <div
    className="chart-row"
    key={row.id}
    title={title}
    style={style}
  />
}

type ChartOutputProps = {
  results: QueryResults
}

export const ChartOutput = (props: ChartOutputProps) =>
  <ChartRawOutput {...props} />

type ChartRawOutputProps = {
  results?: QueryResults
}

export const ChartRawOutput = ({ results }: ChartRawOutputProps) => {
  const chartContainerRef = useRef(null)
  const [width, setWidth] = useState(0)

  const setWidthUsingContainer = () => {
    if (chartContainerRef.current) {
      // XXX need to do `as any` since the compiler is complaining about a
      // possible null value, but why?
      const container = chartContainerRef.current as any
      const { width: containerWidth } = container.getBoundingClientRect()
      setWidth(containerWidth)
    }
  }

  const containerResizeHandler = () => {
    window.addEventListener("resize", setWidthUsingContainer)
    return () => window.removeEventListener("resize", setWidthUsingContainer)
  }

  useEffect(containerResizeHandler)
  useEffect(setWidthUsingContainer, [chartContainerRef.current])

  if (!results || !results.results || !results.results.length) {
    return <div className="output-no-data">{NO_RESULTS}</div>
  }

  const chartData = normalizeResults(results)

  if (!chartData) {
    return <div className="output-no-data">{NO_RESULTS}</div>
  }

  return <div className="chart-output-wrapper">
    <div className="chart-container" ref={chartContainerRef}>
      {chartData.datum.map((row, i) => buildChartRow(width, i, row, chartData))}
    </div>
  </div>
}
