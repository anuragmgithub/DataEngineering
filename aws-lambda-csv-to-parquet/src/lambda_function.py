import boto3
import pandas as pd
import pyarrow.parquet as pq
import io, os

s3 = boto3.client('s3')

def lambda_handler(event, context):
    source_bucket = event['Records'][0]['s3']['bucket']['name']
    file_key = event['Records'][0]['s3']['object']['key']
    target_bucket = os.environ['TARGET_BUCKET']

    response = s3.get_object(Bucket=source_bucket, Key=file_key)
    df = pd.read_csv(response['Body'])

    parquet_buffer = io.BytesIO()
    df.to_parquet(parquet_buffer, engine='pyarrow')

    target_key = file_key.replace('.csv', '.parquet')
    s3.put_object(Bucket=target_bucket, Key=target_key, Body=parquet_buffer.getvalue())

    return {"statusCode": 200, "body": "File converted successfully!"}