CREATE TABLE [execution].[PipelineGoldLayerEntity] (
    [PipelineGoldLayerEntityId] BIGINT         IDENTITY (1, 1) NOT NULL,
    [GoldLayerEntityId]         BIGINT         NULL,
    [SchemaName]                NVARCHAR (300) NULL,
    [TableName]                 NVARCHAR (MAX) NULL,
    [WorkspaceId]               INT            NULL,
    [PipelineName]              NVARCHAR (MAX) NULL,
    [PipelineGuid]              NVARCHAR (MAX) NOT NULL,
    [InsertDateTime]            DATETIME       NULL,
    [IsProcessed]               BIT            NOT NULL,
    [LoadEndDateTime]           DATETIME       NULL,
    [LastLoadValue]             DATETIME       NULL,
    CONSTRAINT [PK_execution_PipelineGoldLayerEntity] PRIMARY KEY CLUSTERED ([PipelineGoldLayerEntityId] ASC)
);


GO

