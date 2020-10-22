#!/bin/sh

# Check whether there is a passwd entry for the container UID
uid=$(id -u)
gid=$(id -g)
# turn off -e for getent because it will return error code in anonymous uid case
set +e
uid_entry=$(getent passwd ${uid})
set -e

# If there is no passwd entry for the container UID, attempt to create one
if [[ -z "${uid_entry}" ]] ; then
    if [[ -w /etc/passwd ]] ; then
        echo "$uid:x:$uid:$gid:anonymous uid:${SPARK_HOME}:/bin/false" >> /etc/passwd
    else
        echo "Container entrypoint.sh failed to add passwd entry for anonymous UID"
    fi
fi

if [ "$enablePVC" == "true" ]; then
  export SPARK_HISTORY_OPTS="$SPARK_HISTORY_OPTS \
  -Dspark.history.fs.logDirectory=file:/data/$eventsDir";
elif [ "$enableGCS" == "true" ]; then
  export SPARK_HISTORY_OPTS="$SPARK_HISTORY_OPTS \
  -Dspark.history.fs.logDirectory=$logDirectory";
  if [ "$enableIAM" == "false" ]; then
    export SPARK_HISTORY_OPTS="$SPARK_HISTORY_OPTS \
    -Dspark.hadoop.google.cloud.auth.service.account.json.keyfile=/etc/secrets/$key";
  fi;
elif [ "$enableS3" == "true" ]; then
  export SPARK_HISTORY_OPTS="$SPARK_HISTORY_OPTS \
    -Dspark.history.fs.logDirectory=$logDirectory \
    -Dspark.hadoop.fs.s3a.impl=org.apache.hadoop.fs.s3a.S3AFileSystem \
    -Dspark.hadoop.fs.s3a.connection.ssl.enabled=false \
    -Dspark.eventLog.enabled=true \
    -Dspark.hadoop.fs.s3a.path.style.access=true \
    -Dspark.eventLog.dir=$logDirectory";
  if [ -n "$endpoint" ] && [ "$endpoint" != "default" ]; then
    export SPARK_HISTORY_OPTS="$SPARK_HISTORY_OPTS \
    -Dspark.hadoop.fs.s3a.endpoint=$endpoint";
  fi;
  if [ "$enableIAM" == "false" ]; then
    export SPARK_HISTORY_OPTS="$SPARK_HISTORY_OPTS \
    -Dspark.hadoop.fs.s3a.access.key=$(cat /etc/secrets/${accessKeyName}) \
    -Dspark.hadoop.fs.s3a.secret.key=$(cat /etc/secrets/${secretKeyName})";
  fi;
elif [ "$enableWASBS" == "true" ]; then
  container=$(cat /etc/secrets/${containerKeyName})
  storageAccount=$(cat /etc/secrets/${storageAccountNameKeyName})

  export SPARK_HISTORY_OPTS="$SPARK_HISTORY_OPTS \
    -Dspark.history.fs.logDirectory=$logDirectory \
    -Dspark.hadoop.fs.defaultFS=wasbs://$container@$storageAccount.blob.core.windows.net \
    -Dspark.hadoop.fs.wasbs.impl=org.apache.hadoop.fs.azure.NativeAzureFileSystem \
    -Dspark.hadoop.fs.AbstractFileSystem.wasbs.impl=org.apache.hadoop.fs.azure.Wasbs";
  if [ "$sasKeyMode" == "true" ]; then
    export SPARK_HISTORY_OPTS="$SPARK_HISTORY_OPTS \
      -Dspark.hadoop.fs.azure.local.sas.key.mode=true \
      -Dspark.hadoop.fs.azure.sas.$container.$storageAccount.blob.core.windows.net=$(cat /etc/secrets/${sasKeyName})";
  else
    export SPARK_HISTORY_OPTS="$SPARK_HISTORY_OPTS \
      -Dspark.hadoop.fs.azure.account.key.$storageAccount.blob.core.windows.net=$(cat /etc/secrets/${storageAccountKeyName})";
  fi;
else
  export SPARK_HISTORY_OPTS="$SPARK_HISTORY_OPTS \
  -Dspark.history.fs.logDirectory=$logDirectory";
fi;

exec /usr/bin/tini -s -- /opt/spark/sbin/start-history-server.sh