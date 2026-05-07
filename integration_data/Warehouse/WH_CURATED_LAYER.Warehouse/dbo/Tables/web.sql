CREATE TABLE [dbo].[web] (

	[session_id] varchar(8000) NULL, 
	[customer_id] bigint NULL, 
	[page_viewed] varchar(8000) NULL, 
	[session_time] date NULL, 
	[device_type] varchar(8000) NULL, 
	[year] int NULL, 
	[month] int NULL, 
	[day] int NULL, 
	[HashedPKColumn] varchar(8000) NULL, 
	[HashedNonKeyColumns] varchar(8000) NULL, 
	[RecordLoadDate] datetime2(6) NULL
);