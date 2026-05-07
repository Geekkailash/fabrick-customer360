# Fabric notebook source

# METADATA ********************

# META {
# META   "kernel_info": {
# META     "name": "synapse_pyspark"
# META   },
# META   "dependencies": {
# META     "lakehouse": {
# META       "default_lakehouse": "71329364-5fc3-4b71-a75a-0b851ee4e3ba",
# META       "default_lakehouse_name": "LH_BRONZE_LAYER",
# META       "default_lakehouse_workspace_id": "2effab8c-7fe4-4bfd-b678-34e1fd29d8ab",
# META       "known_lakehouses": [
# META         {
# META           "id": "71329364-5fc3-4b71-a75a-0b851ee4e3ba"
# META         },
# META         {
# META           "id": "09ebc56b-7f06-401a-827d-342a754ba8d3"
# META         }
# META       ]
# META     },
# META     "warehouse": {
# META       "known_warehouses": [
# META         {
# META           "id": "4a2ecce9-6539-4d54-91bf-38ab15bfdb35",
# META           "type": "Datawarehouse"
# META         }
# META       ]
# META     }
# META   }
# META }

# PARAMETERS CELL ********************

# Notebook parameters
schema_name = "bronze"  #


# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

from pyspark.sql import functions as F
from pyspark.sql import Row


def get_schema_snapshot_lakehouse(parameter1):

    table_schema = parameter1

    tables_df = spark.sql(f"SHOW TABLES IN {table_schema}")

    all_columns = []

    for row in tables_df.collect():

        table_name = row["tableName"]

        full_table_name = f"{table_schema}.{table_name}"

        df_schema = spark.table(full_table_name).schema

        rows = []

        for idx, field in enumerate(df_schema.fields, start=1):

            rows.append(
                Row(
                    layer=table_schema,
                    schema_name=table_schema,
                    table_name=table_name,
                    column_name=field.name,
                    data_type=str(field.dataType),
                    ordinal_position=idx,
                    is_nullable=str(field.nullable)
                )
            )

        cols_df = spark.createDataFrame(rows)

        cols_df = (
            cols_df
            .withColumn(
                "hash_value",
                F.sha2(
                    F.concat_ws("|", "data_type", "is_nullable"),
                    256
                )
            )
            .withColumn("run_time", F.current_timestamp())
        )

        all_columns.append(cols_df)

    if all_columns:

        final_df = all_columns[0]

        for d in all_columns[1:]:
            final_df = final_df.unionByName(d)

        return final_df

    else:
        return None


# 🔹 CALL FUNCTION
#final_df = get_schema_snapshot("dbo")


# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

def get_jdb_url():
    server = "5q6eezjaqpaexbe4umwg7qqbyq-rsv76lxep76uxntygtq72koyvm.datawarehouse.fabric.microsoft.com"
    database = "WH_CURATED_LAYER"
    
    jdbc_url = (
        f"jdbc:sqlserver://{server}:1433;"
        f"database={database};"
        f"encrypt=true;"
        f"trustServerCertificate=false;"
        f"hostNameInCertificate=*.datawarehouse.fabric.microsoft.com;"
    )
    return jdbc_url


# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

from pyspark.sql import functions as F
from notebookutils import mssparkutils

#5q6eezjaqpaexbe4umwg7qqbyq-qiwjvmal7noelhz6ew3bbbzy5y.datawarehouse.fabric.microsoft.com
def get_schema_snapshot_warehouse(parameter1):

    # 🔹 CONNECTION
    #5q6eezjaqpaexbe4umwg7qqbyq-rsv76lxep76uxntygtq72koyvm.datawarehouse.fabric.microsoft.com
    server = "5q6eezjaqpaexbe4umwg7qqbyq-rsv76lxep76uxntygtq72koyvm.datawarehouse.fabric.microsoft.com"
    database = "WH_CURATED_LAYER"
    
    jdbc_url = (
        f"jdbc:sqlserver://{server}:1433;"
        f"database={database};"
        f"encrypt=true;"
        f"trustServerCertificate=false;"
        f"hostNameInCertificate=*.datawarehouse.fabric.microsoft.com;"
    )

    access_token = mssparkutils.credentials.getToken(
        "https://database.windows.net/"
    )

    # 🔹 QUERY
    query = f"""
    SELECT
        TABLE_SCHEMA,
        TABLE_NAME,
        COLUMN_NAME,
        DATA_TYPE,
        ORDINAL_POSITION,
        IS_NULLABLE
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = '{parameter1}'
    """

    df = spark.read.jdbc(
        url=jdbc_url,
        table=f"({query}) as q",
        properties={
            "driver": "com.microsoft.sqlserver.jdbc.SQLServerDriver",
            "accessToken": access_token
        }
    )

    # 🔹 TRANSFORM
    final_df = (
        df
        .withColumn(
            "layer",
            F.lit(parameter1)
        )
        .withColumn(
            "hash_value",
            F.sha2(
                F.concat_ws("|", "DATA_TYPE", "IS_NULLABLE"),
                256
            )
        )
        .withColumn(
            "run_time",
            F.current_timestamp()
        )
        .select(
            F.col("layer").cast("string").alias("layer"),
            F.col("TABLE_SCHEMA").alias("schema_name").cast("string"),
            F.col("TABLE_NAME").alias("table_name").cast("string"),
            F.col("COLUMN_NAME").alias("column_name").cast("string"),
            F.col("DATA_TYPE").alias("data_type").cast("string"),
            F.col("ORDINAL_POSITION").alias("ordinal_position").cast("bigint"),
            F.col("IS_NULLABLE").alias("is_nullable").cast("string"),
            F.col("hash_value").cast("string").alias("hash_value"),
            F.col("run_time")
        )
    )

    # 🔥 LIMIT STRING LENGTH
    final_df = final_df.select(
        F.expr("CAST(layer AS VARCHAR(20))").alias("layer"),
        F.expr("CAST(schema_name AS VARCHAR(100))").alias("schema_name"),
        F.expr("CAST(table_name AS VARCHAR(100))").alias("table_name"),
        F.expr("CAST(column_name AS VARCHAR(100))").alias("column_name"),
        F.expr("CAST(data_type AS VARCHAR(50))").alias("data_type"),
        F.col("ordinal_position"),
        F.expr("CAST(is_nullable AS VARCHAR(10))").alias("is_nullable"),
        F.expr("CAST(hash_value AS VARCHAR(256))").alias("hash_value"),
        F.col("run_time")
    )

    return final_df



# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************


# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

# Execute appropriate schema snapshot based on schema_name

# Expected values for schema_name: 'bronze', 'silver', or 'gold'
value = schema_name.lower()
final_df = None

if value == "bronze":
    final_df = get_schema_snapshot_lakehouse("dbo")
elif value == "silver":
    final_df = get_schema_snapshot_warehouse("silver")
elif value == "gold":
    final_df = get_schema_snapshot_warehouse("gold")
else:
    raise ValueError(f"Unsupported schema_name '{schema_name}'. Use 'bronze', 'silver', or 'gold'.")

display(final_df)


# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

display(final_df)
final_df_bounded = final_df.select(
    F.col("layer").cast("string").alias("layer"),
    F.col("schema_name").cast("string").alias("schema_name"),
    F.col("table_name").cast("string").alias("table_name"),
    F.col("column_name").cast("string").alias("column_name"),
    F.col("data_type").cast("string").alias("data_type"),
    F.col("ordinal_position").cast("bigint").alias("ordinal_position"),
    F.col("is_nullable").cast("string").alias("is_nullable"),
    F.col("hash_value").cast("string").alias("hash_value"),
    F.col("run_time").alias("run_time")
)

print(final_df_bounded.count())
display(final_df_bounded)

final_df_bounded.write \
    .format("jdbc") \
    .option("url", get_jdb_url()) \
    .option("dbtable", "dbo.schema_snapshot_current") \
    .option("accessToken", mssparkutils.credentials.getToken("https://database.windows.net/")) \
    .option("driver", "com.microsoft.sqlserver.jdbc.SQLServerDriver") \
    .mode("append") \
    .save()

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************


# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }
