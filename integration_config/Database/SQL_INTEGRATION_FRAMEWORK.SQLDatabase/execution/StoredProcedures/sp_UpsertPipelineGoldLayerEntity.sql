


    CREATE PROCEDURE [execution].[sp_UpsertPipelineGoldLayerEntity] (
        @GoldLayerEntityId BIGINT,
        @SchemaName NVARCHAR(300),
        @TableName NVARCHAR(300),
        @WorkspaceId INT,
        @PipelineName NVARCHAR(300),
        @PipelineGuid NVARCHAR(300),
        @IsProcessed BIT
    )
    WITH EXECUTE AS CALLER
    AS
    BEGIN
        SET NOCOUNT ON;

        IF NOT EXISTS (
            SELECT 1
            FROM [execution].[PipelineGoldLayerEntity] PLE
            WHERE PLE.[GoldLayerEntityId] = @GoldLayerEntityId
                AND PLE.[SchemaName] = @SchemaName
                AND PLE.[PipelineGuid] = @PipelineGuid
                AND PLE.[IsProcessed] = 0
        )
        BEGIN
            INSERT INTO [execution].[PipelineGoldLayerEntity] (
                [GoldLayerEntityId],
                [TableName],
                [SchemaName],
                [WorkspaceId],
                [PipelineName],
                [PipelineGuid],
                [InsertDateTime],
                [IsProcessed]
            )
            SELECT @GoldLayerEntityId,
                @TableName,
                @SchemaName,
                @WorkspaceId,
                @PipelineName,
                @PipelineGuid,
                GETDATE(),
                @IsProcessed;
        END
        ELSE IF @IsProcessed = 1
        BEGIN
            UPDATE [execution].[PipelineGoldLayerEntity]
            SET [IsProcessed] = @IsProcessed,
                [LoadEndDateTime] = GETDATE()
            WHERE [GoldLayerEntityId] = @GoldLayerEntityId
                AND [SchemaName] = @SchemaName
                AND [PipelineGuid] = @PipelineGuid;
        END

        -- Output for Fabric Pipeline
        SELECT @GoldLayerEntityId AS GoldLayerEntityId, 
            @IsProcessed as IsProcessed,
            @TableName as TableName,
            @PipelineGuid as [PipelineGuid];

        SET NOCOUNT OFF;
    END

GO

