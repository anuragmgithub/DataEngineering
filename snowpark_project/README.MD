# Snowpark Project

This project demonstrates how to use **Snowpark for Python** with Snowflake, including:
- Writing and registering **UDFs (User Defined Functions)**
- Unit testing Python logic locally with **pytest**
- Running integration tests against Snowflake
- Organizing code in a production-grade Python package

---

## 📌 What is Snowpark?

**Snowpark** is a developer framework provided by Snowflake that allows you to run Python (and other languages) directly inside Snowflake.  
Instead of moving data out of Snowflake, you **bring your code to the data**.

Key features:
- Write Python functions and register them as **UDFs** (row-based) or **UDTFs** (table-based).
- Use the **Snowpark DataFrame API** (similar to PySpark/Pandas) to manipulate data inside Snowflake.
- Push computation down into Snowflake’s engine for performance and scalability.
- Build **machine learning, data pipelines, and transformations** without leaving Snowflake.

---



