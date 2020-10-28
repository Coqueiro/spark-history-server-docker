ARG SPARK_IMAGE=datacrate/spark:3.0.0-hadoop3.2
FROM ${SPARK_IMAGE}
WORKDIR /

# Reset to root to run installation tasks
USER 0

RUN apt-get install tini
RUN mkdir /opt/spark/logs
RUN chmod 775 /opt/spark/logs

COPY entrypoint.sh /usr/bin/
WORKDIR /opt/spark/work-dir
ENTRYPOINT ["/usr/bin/entrypoint.sh"]

# Specify the User that the actual main process will run as
ARG spark_uid=185
USER ${spark_uid}
