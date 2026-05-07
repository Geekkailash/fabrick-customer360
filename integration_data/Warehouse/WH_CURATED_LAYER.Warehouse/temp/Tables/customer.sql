CREATE TABLE [temp].[customer] (

	[customer_id] bigint NULL, 
	[name] varchar(8000) NULL, 
	[gender] varchar(8000) NULL, 
	[email] varchar(8000) NULL, 
	[dob] date NULL, 
	[location] varchar(8000) NULL, 
	[year] int NULL, 
	[month] int NULL, 
	[day] int NULL, 
	[HashedPKColumn] varchar(8000) NULL, 
	[HashedNonKeyColumns] varchar(8000) NULL, 
	[RecordLoadDate] datetime2(6) NULL
);