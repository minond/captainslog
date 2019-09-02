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
  <LineChart
    data={flattenResultsHash(props.results)}
    width={500}
    height={300}
    margin={{ top: 5, right: 30, left: 20, bottom: 5 }}
  >
    <XAxis dataKey="x" />
    <YAxis />
    <Tooltip />
    <Line type="monotone" dataKey="y" stroke="#82ca9d" />
  </LineChart>
