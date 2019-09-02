import * as React from "react"

import {
  Line,
  LineChart,
  Tooltip,
  XAxis,
  YAxis,
} from 'recharts';

import { QueryResults } from "../../definitions"

import { flattenResultsHash } from "./utils"

type ChartOutputProps = {
  results: QueryResults
}

export const ChartOutput = (props: ChartOutputProps) =>
  <div className="chart-output">
    <LineChart
      data={flattenResultsHash(props.results)}
      width={740}
      height={200}
      margin={{ top: 0, right: 0, bottom: 0, left: 0 }}
    >
      <Tooltip />
      <XAxis dataKey="x" />
      <YAxis dataKey="y" width={40} />
      <Line type="monotone" dataKey="y" stroke="#82ca9d" isAnimationActive={false} />
    </LineChart>
  </div>
