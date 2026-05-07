CREATE TABLE [dbo].[orders] (

	[order_id] bigint NULL, 
	[customer_id] bigint NULL, 
	[order_date] date NULL, 
	[amount] float NULL, 
	[status] varchar(8000) NULL, 
	[year] int NULL, 
	[month] int NULL, 
	[day] int NULL, 
	[HashedPKColumn] varchar(8000) NULL, 
	[HashedNonKeyColumns] varchar(8000) NULL, 
	[RecordLoadDate] datetime2(6) NULL
);