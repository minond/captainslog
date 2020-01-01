![Captain's Log](https://raw.githubusercontent.com/minond/captainslog/master/web/app/assets/images/logo.png)

Captain's Log is an application for logging anything you want. The intent is to
be able to log anything in relatively free form while still being able to
extract and analyze your logs. Think
[Logstash](https://github.com/elastic/logstash) but for persons and in personal
use.

The application is made up of three separate services: a service for [entry
processing](processor), one for [entry querying](querier), and a [web
application](web). Note that the web application is itself made up of a web
server and a background worker.

Code and documentation for each service can be found in the appropriate
directory, however below you will find diagrams that give a high level overview
of how a request flows through the system.

#### Entry processing flow

![Entry processing flow](web/docs/entry_processing_flow.svg)

<br>

#### Entry querying flow

![Entry querying flow](web/docs/entry_querying_flow.svg)

---

[![Processor Service](https://github.com/minond/captainslog/workflows/Processor%20Service/badge.svg)](https://github.com/minond/captainslog/actions?query=workflow%3A%22Processor+Service%22)
[![Querier Service](https://github.com/minond/captainslog/workflows/Querier%20Service/badge.svg)](https://github.com/minond/captainslog/actions?query=workflow%3A%22Querier+Service%22)
[![Web App](https://github.com/minond/captainslog/workflows/Web%20App/badge.svg)](https://github.com/minond/captainslog/actions?query=workflow%3A%22Web+App%22)
