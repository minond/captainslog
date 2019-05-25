# Captain's Log

Captain's Log is an application for logging anything you want about yourself.

[![Build Status](https://travis-ci.org/minond/captainslog.svg?branch=master)](https://travis-ci.org/minond/captainslog)
[![Go Report Card](https://goreportcard.com/badge/github.com/minond/captainslog)](https://goreportcard.com/report/github.com/minond/captainslog)


## Outline

The intent of this project is to have an application that I can use to log
anything in relatively free form, and still be able to extract (or inject)
important information from the logs. This is done using features like
Extractors that know how to extract and label data from a piece of text.

### Sample use-case: Workouts log

#### Extracting data from logs

Here's an example use-case: Let's say I want to log my workouts. I'd start by
creating a new "Workouts" Book and group it by Day since I think of workouts on
a day-by-day basis. I'd then add some Extractors to extract the exercise,
weight, set/rep, and time information. Since Extractors are regular expression
based, I first need to know what my general format will be. I'll use the
grammar below to explain the format:

```
exercise = ?? any character except comma ??
sets = ?? integer number ??
reps = ?? integer number ??
weight = ?? real number ??
time = ?? real number ?? , [ "min" | "minute" | "minutes" | "hour" | "hours" ]
distance = ?? real number ?? , [ "mile" | "miles" | "k" | "kilometer" | "kilometers" ]
log = exercise "," [ sets , "x" reps ] [ "@" weight ] [ distance ] [ time ] ]
```

We convert that into Extractors with the following labels and regular
expression matches:

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
of it. At this point we can start entering logs.

#### Using the extracted data

Now that we have our Extractors set up and we're entering logs, we need a way
to get that data... I need to spend some time writing this in more detail, but
the tl;dw is that the extracted data is stored in a JSON field, and this lets
us query it like we would any other column. In addition, there is a layer in
between the user and the database that processes and scopes SQL queries to make
writing them a lot easier. For example, instead of writing:

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

This can currently be done with the `./captainslog repl` command. Start it and
set the user scope with the `\user <GUID>` command and then run any query (only
select statements are supported):

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
may change, though the SQL interface is more or less how I want it. One of the
features to come is the ability to execute queries from clients instead of
having to run them in this repl. More to come on this.


## Development

Run `make` to build server and web client, run linterns and autoformatters with
`make fmt lint`. To start the application server, run `./captainslog server`
after building project. Run `./captainslog help` to see a list of other
commands.

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
