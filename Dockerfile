FROM buildpack-deps:bionic

ENV DEBIAN_FRONTEND noninteractive
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ENV PIO_VERSION 0.12.1
ENV SPARK_VERSION 2.1.1
ENV HADOOP_VERSION 2.6
ENV SCALA_VERSION 2.11.12
ENV JDBC_PG_VERSION 42.2.0

ENV PIO_HOME /home/pio
ENV PATH=${PIO_HOME}/bin:$PATH
ENV JAVA_HOME /usr/lib/jvm/java-8-oracle

# Add user and install Oracle JDK, Scala
RUN useradd -d /home/pio -ms /bin/bash pio \
&&  apt-get update -qq -y \
&&  apt-get install -qq -y --no-install-recommends software-properties-common \
&&  add-apt-repository -y ppa:webupd8team/java \
&&  echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections \
&&  apt-get update -qq -y \
&&  apt-get install -qq -y oracle-java8-installer oracle-java8-set-default oracle-java8-unlimited-jce-policy \
&&  curl -sSL https://downloads.lightbend.com/scala/${SCALA_VERSION}/scala-${SCALA_VERSION}.deb -o /tmp/scala-${SCALA_VERSION}.deb \
&&  dpkg -i /tmp/scala-${SCALA_VERSION}.deb \
&&  apt-get install -qq -y -f \
&&  rm -rf /var/cache/apt/archives/* /var/cache/oracle-jdk8-installer/* /var/lib/apt/lists/* /tmp/* /var/tmp/*

USER pio
WORKDIR /home/pio

RUN curl -sSL https://www.apache.org/dist/predictionio/${PIO_VERSION}/apache-predictionio-${PIO_VERSION}-bin.tar.gz | tar -xzpf - --strip-components=1 -C ${PIO_HOME} \
&&  mkdir ${PIO_HOME}/vendors \
&&  curl -sSL https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz | tar -xzpf - -C ${PIO_HOME}/vendors \
&&  curl -sSL https://jdbc.postgresql.org/download/postgresql-${JDBC_PG_VERSION}.jar -o ${PIO_HOME}/lib/spark/postgresql-${JDBC_PG_VERSION}.jar
