from config import get_session
from snowflake.snowpark.functions import col
from udfs.string_udfs import capitalize_first, get_reverse_udf
from udfs.table_functions import split_to_words

def run_udfs(session):
    df = session.create_dataframe([["hello_snowflake"]]).to_df("example_column")
    reverse_udf = get_reverse_udf()

    df_with_udfs = df.select(
        capitalize_first(col("example_column")),
        reverse_udf(col("example_column"))
    )

    df_with_udfs.show()

def run_udtf(session):
    df = session.create_dataframe([["hello_snowflake_world"]]).to_df("text")
    df_with_words = df.join_table_function("split_to_words", df["text"])
    df_with_words.show()


if __name__ == "__main__":
    session = get_session()
    run_udfs(session)
    run_udtf(session)