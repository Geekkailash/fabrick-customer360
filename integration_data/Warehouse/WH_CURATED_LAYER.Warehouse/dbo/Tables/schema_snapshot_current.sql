CREATE TABLE [dbo].[schema_snapshot_current] (

	[layer] varchar(20) NULL, 
	[schema_name] varchar(100) NULL, 
	[table_name] varchar(200) NULL, 
	[column_name] varchar(200) NULL, 
	[data_type] varchar(50) NULL, 
	[ordinal_position] bigint NULL, 
	[is_nullable] varchar(10) NULL, 
	[hash_value] varchar(256) NULL, 
	[run_time] datetime2(6) NULL
);