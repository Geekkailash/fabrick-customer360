CREATE TABLE [execution].[PipelineSilverLayerEntity] (
    [PipelineSilverLayerEntityId] BIGINT         IDENTITY (1, 1) NOT NULL,
    [SilverLayerEntityId]         BIGINT         NOT NULL,
    [SchemaName]                  NVARCHAR (300) NOT NULL,
    [TableName]                   NVARCHAR (MAX) NOT NULL,
    [InsertDateTime]              DATETIME       NULL,
    [IsProcessed]                 BIT            NOT NULL,
    [LoadEndDateTime]             DATETIME       NULL,
    [LastLoadValue]               DATETIME       NULL,
    CONSTRAINT [PK_execution_PipelineSilverLayerEntity] PRIMARY KEY CLUSTERED ([PipelineSilverLayerEntityId] ASC)
);


GO

