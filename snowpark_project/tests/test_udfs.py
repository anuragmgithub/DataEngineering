# tests/test_udfs.py
from udfs.string_udfs import capitalize_first_py

def test_capitalize_function():
    assert capitalize_first_py("snowflake") == "Snowflake"
    assert capitalize_first_py("data") == "Data"
