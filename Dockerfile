FROM buildpack-deps:bionic

ENV DEBIAN_FRONTEND noninteractive

ENV PIO_VERSION 0.13.0
ENV SPARK_VERSION 2.1.1
ENV HADOOP_VERSION 2.6
ENV SCALA_VERSION 2.11.12
ENV SCALA_MAJOR_VERSION 2.11
ENV SBT_VERSION 1.2.0
ENV JDBC_PG_VERSION 42.2.0
ENV UNIVERSAL_RECOMMENDER_VERSION v0.7.3

ENV PIO_HOME /home/pio
ENV PATH ${PIO_HOME}/bin:$PATH
ENV UR_HOME ${PIO_HOME}/universal-recommender
ENV APP_HOME ${PIO_HOME}/app
ENV JAVA_HOME /usr/lib/jvm/java-8-oracle

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Add user and install Oracle JDK, Scala
RUN useradd -d ${PIO_HOME} -ms /bin/bash pio \
&&  mkdir -p ${PIO_HOME}/vendors ${APP_HOME}/lib ${UR_HOME} \
&&  apt-get update -qq -y \
&&  apt-get install -qq -y --no-install-recommends software-properties-common vim-nox \
&&  add-apt-repository -y ppa:webupd8team/java \
&&  echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections \
&&  apt-get update -qq -y \
&&  apt-get install -qq -y oracle-java8-installer oracle-java8-set-default oracle-java8-unlimited-jce-policy \
&&  curl -sSL https://downloads.lightbend.com/scala/${SCALA_VERSION}/scala-${SCALA_VERSION}.deb -o /tmp/scala-${SCALA_VERSION}.deb \
&&  dpkg -i /tmp/scala-${SCALA_VERSION}.deb \
&&  apt-get install -qq -y -f \
&&  rm -rf /var/cache/apt/archives/* /var/cache/oracle-jdk8-installer/* /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Apache PredictionIO, Spark and JDBC PostgreSQL driver
RUN curl -sSL https://archive.apache.org/dist/predictionio/${PIO_VERSION}/apache-predictionio-${PIO_VERSION}-bin.tar.gz | tar -xzpf - --strip-components=1 -C ${PIO_HOME} \
&&  curl -sSL https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz | tar -xzpf - -C ${PIO_HOME}/vendors \
&&  curl -sSL https://jdbc.postgresql.org/download/postgresql-${JDBC_PG_VERSION}.jar -o ${PIO_HOME}/lib/postgresql-${JDBC_PG_VERSION}.jar

WORKDIR ${UR_HOME}

# Universal Recommender build with sbt and scala
RUN curl -sSL https://piccolo.link/sbt-${SBT_VERSION}.tgz | tar -xzpf - -C ${PIO_HOME} \
&&  curl -sSL https://github.com/actionml/universal-recommender/archive/${UNIVERSAL_RECOMMENDER_VERSION}.tar.gz | tar -xzpf - --strip-components=1 -C ${UR_HOME} \
&&  pio build \
&&  mv -vf ${UR_HOME}/target/scala-${SCALA_MAJOR_VERSION}/*.jar ${APP_HOME}/lib \
&&  cp -vf ${UR_HOME}/engine.json.template ${APP_HOME}/engine.json \
&&  cp -vf ${UR_HOME}/template.json ${APP_HOME}/template.json \
&&  rm -rf ${UR_HOME} ~/.sbt ~/.ivy2/

# pio-env.sh
COPY conf/ ${PIO_HOME}/conf/
RUN chown -R pio:pio ${PIO_HOME}

WORKDIR ${APP_HOME}
USER pio
CMD ["pio"]
