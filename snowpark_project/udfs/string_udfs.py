from snowflake.snowpark import Session
from snowflake.snowpark.types import IntegerType, StringType, StructField, StructType
from snowflake.snowpark.functions import col, lit, udf 
import pytest
from config import get_session

# Permanent UDF stored in snowflake, requires stage
@udf(name="add_one_permanent", is_permanent=True, stage_location="@snowpark_stage", replace=True)
def capitalize_first(s: str) -> str:
    return s.capitalize()


# Anonymous UDF (inline, not sotred in snowflake)
def get_reverse_udf():
    return udf(lambda s: s[::-1], 
            return_type=StringType(),
            input_types=[StringType()])


