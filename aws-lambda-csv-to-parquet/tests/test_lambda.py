import pytest
from src.lambda_function import lambda_handler

def test_lambda_handler():
    event = {"Records": [{"s3": {"bucket": {"name": "source-bucket"}, "object": {"key": "test.csv"}}}]}
    context = None
    response = lambda_handler(event, context)
    assert response["statusCode"] == 200
