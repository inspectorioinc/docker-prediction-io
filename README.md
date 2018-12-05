## Inspectorio PredictionIO Image

- Oracle JDK 8
- Scala 2.11.12
- Apache PredictionIO 0.13.0
- Apache Spark 2.1.1
- PostgreSQL JDBC 42.2.0
- Universal Recommender v0.7.3

### Environments

#### PostgreSQL

- `PIO_DB_HOST`: PostgreSQL server address
- `PIO_DB`: PostgreSQL database name
- `PIO_DB_USER`: PostgreSQL database user
- `PIO_DB_PASSWORD`: PostgreSQL database password

#### Elasticsearch

- `ES_HOST`: Elasticsearch host
- `ES_PORT`: Elasticsearch port

### Usage

```sh
$ docker-compose up

# open a new terminal and run below command to ssh into pio container
$ docker-compose exec app sh

$ pio status # check pio status
$ pio eventserver &
$ pio app new **your-app-name-here** # specify the appName used in the template's engine.json file (you can see it in the current directory)
```

Feed data through sdk and use `pio train` & `pio deploy` subsequently. Also, note that default UR integration tests are removed while building the container from scala source, and thus, can't be run.
