from snowflake.snowpark.types import StructType, StructField, StringType
from snowflake.snowpark.functions import udtf

class SplitToWords:
    def process(self, s: str):
        for word in s.split("_"):
            yield (word,)

split_to_words = udtf(
    SplitToWords,
    output_schema=StructType([StructField("word", StringType())]),
    input_types=[StringType()],
    name="split_to_words",
    replace=True,
    is_permanent=False
)
