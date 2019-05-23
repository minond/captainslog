# Captain's Log

Captain's Log is an application for logging anything you want about yourself.

[![Build Status](https://travis-ci.org/minond/captainslog.svg?branch=master)](https://travis-ci.org/minond/captainslog)
[![Go Report Card](https://goreportcard.com/badge/github.com/minond/captainslog)](https://goreportcard.com/report/github.com/minond/captainslog)


## Outline

The intent of this project is to have an application that I can use to log
anything in relatively free form, and still be able to extract (or inject)
important information from the logs. This is done using features like
Extractors that know how to extract and label data from a piece of text.

### Workouts sample

#### Extracting data from logs

Let's say I want to log my workouts. I'd start by creating a new "Workouts"
Book and group by Day since I think of workouts on a day-by-day basis. I'd then
add some Extractors to extract the exercise, weight, set/rep, and time
information. Since Extractors are regular expression based, I first need to
know what my general format will be. I'll use the grammar below to explain the
format:

```
exercise = ?? any character except comma ??
sets = ?? integer number ??
reps = ?? integer number ??
weight = ?? real number ??
time = ?? real number ?? , [ "min" | "minute" | "minutes" | "hour" | "hours" ]
distance = ?? real number ?? , [ "mile" | "miles" | "k" | "kilometer" | "kilometers" ]
log = exercise "," [ sets , "x" reps ] [ "@" weight ] [ distance ] [ time ] ]
```

We convert that into extractors with the following regular expression:

- "exercise", `/^(.+),/`
- "sets", `/,\s{0,}(\d+)\s{0,}x/`
- "reps", `/\dx\s{0,}(\d+)/`
- "weight", `/@\s{0,}(\d+(\.\d{1,2})?)$/`
- "time", `/(\d+)\s{0,}(sec|seconds|min|minutes|hour|hours)/`
- "time_unit", `/\d+\s{0,}(sec|seconds|min|minutes|hour|hours)/`
- "distance", `/(\d+(\.\d+)?)\s{0,}(mile|miles|k|kilometers)/`
- "distance_unit", `/\d+\s{0,}(mile|miles|k|kilometers)/`

These allow us to take a log like `"Running, 5k 42min"` and get `distance = 5`,
`distance_unit = k`, `exercise = Running`, `time = 42`, `time_unit = min` out
of it.

#### Using the extracted data

I need to spen some time writing this, but the tl;dw is that the extracted data
is stored in a JSON field, and this lets us query it like we would any other
column. In addition, there is an additional layer in between the user and the
database that extracts a lot of the data section and access scoping. Included
in this project is a `captainslog-repl` command which acts as a database client
that processes the SQL the user inputs as a user-friendly form into SQL we can
actually send to the database. For example, instead of writing:

```sql
select data #>> '{exercise}',
  data #>> '{distance}',
  data #>> '{distance_unit}',
  data #>> '{time}', data #>> '{time_unit}'
from entries
where book_guid = (select guid from books where name ilike 'workouts')
and user_guid = 'e26e269c-0587-4094-bf01-108c61b0fa8a'
and data #>> '{exercise}' ilike 'running'
and data #>> '{distance}' is not null;
```

We can simply write:

```sql
select exercise, distance, distance_unit, time, time_unit
from workouts
where exercise ilike 'running'
and distance is not null;
```

```
$ ./captainslog-repl
> \user e26e269c-0587-4094-bf01-108c61b0fa8a
> select exercise, distance, distance_unit, time, time_unit
  from workouts
  where exercise ilike 'running'
  and distance is not null;

  ?COLUMN? | ?COLUMN? | ?COLUMN? | ?COLUMN? | ?COLUMN?
+----------+----------+----------+----------+----------+
  Running  |        5 | k        |       42 | min
(1 row)

> \q
```

This part of the application is still in its early stages and the interaction
may change, though the SQL interface is more or less how I want it. Clients
should also have easy access to this data, so with the web or mobile client,
one should be able to execute any query one could run in the `captainslog-repl`
tool. More to come on this.


## Development

Run `make` to build server and web client, `make run` to run the server in
development mode. Run linterns and autoformatters with `make fmt lint`. `make
build` will build everything including the tooling. Here's a breakdown of what
the commands do:

- `captainslog-server` runs the HTTP server process.
- `captainslog-migrate` executes database migrations.
- `captainslog-repl` starts a database client that accepts Captain's Log SQL.

Developing on the mobile client can be done with an emulator. To start an iOS
emulator and run the application:

```
cd client/mobile
flutter emulators --launch apple_ios_simulator
flutter run
```

Make sure to run `go generate` with Go modules disabled -- Kallax's generator
does not like to be ran with modules enabled:

```
GO111MODULE=off go generate ./...
```
