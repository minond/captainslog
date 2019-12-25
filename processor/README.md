The processor service handles request for entry text processing. It exposes an
HTTP interface which accepts the text and book id of an entry which is then
uses for processing.


=== Configuration

The services needs to know what database to connect to and port binding
information for the HTTP service. This is done using the following environment
variables:

    PROCESSOR_DB_CONN      # database connection url, example "postgres://ro_user@localhost:5432/captainslog"
    PROCESSOR_HTTP_LISTEN  # http host/port string, example ":8081"
