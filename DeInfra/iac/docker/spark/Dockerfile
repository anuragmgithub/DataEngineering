# Dockerfile for Spark with Iceberg
# This creates a custom Spark image with Iceberg and required dependencies pre-installed
FROM spark:3.5.0-python3

# Switch to root to install packages
USER root

# Install Python dependencies
RUN pip install --no-cache-dir \
    pyspark==3.5.0 \
    delta-spark==3.0.0 \
    pandas==2.0.3 \
    numpy==1.24.3 \
    pyarrow==12.0.1

# Download Iceberg Spark Runtime JAR
# iceberg-spark-runtime-3.5_2.12-1.4.0 includes all necessary Iceberg libraries
RUN cd $SPARK_HOME/jars && \
    wget -q https://repo1.maven.org/maven2/org/apache/iceberg/iceberg-spark-runtime-3.5_2.12/1.4.0/iceberg-spark-runtime-3.5_2.12-1.4.0.jar && \
    wget -q https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-aws/3.3.4/hadoop-aws-3.3.4.jar && \
    wget -q https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-bundle/1.12.261/aws-java-sdk-bundle-1.12.261.jar

# Create directories for Iceberg warehouse
RUN mkdir -p /warehouse /data /opt/spark/app && \
    chmod -R 777 /warehouse /data /opt/spark/app

# Set environment variables for Iceberg
ENV ICEBERG_SPARK_RUNTIME_VERSION="1.4.0"
ENV ICEBERG_SPARK_JAR="/opt/spark/jars/iceberg-spark-runtime-3.5_2.12-1.4.0.jar"

# Copy sample application (will be overridden by ConfigMap in K8s)
WORKDIR /opt/spark/app

# Switch back to spark user for security
USER spark

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD spark-submit --version || exit 1

CMD ["/opt/spark/bin/spark-class", "org.apache.spark.deploy.worker.Worker"]
