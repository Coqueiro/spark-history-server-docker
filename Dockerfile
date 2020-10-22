ARG SPARK_IMAGE=datacrate/spark:3.0.0-hadoop3.2
FROM ${SPARK_IMAGE}

ENTRYPOINT ["/opt/entrypoint.sh"]