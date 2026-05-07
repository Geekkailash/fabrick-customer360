CREATE TABLE [dbo].[customer] (

	[customer_id] varchar(8000) NULL, 
	[name] varchar(8000) NULL, 
	[EMAIL] varchar(8000) NULL, 
	[gender] varchar(8000) NULL, 
	[dob] varchar(8000) NULL, 
	[location] varchar(8000) NULL, 
	[year] int NULL, 
	[month] int NULL, 
	[day] int NULL, 
	[HashedPKColumn] varchar(8000) NULL, 
	[HashedNonKeyColumns] varchar(8000) NULL, 
	[RecordLoadDate] datetime2(6) NULL
);