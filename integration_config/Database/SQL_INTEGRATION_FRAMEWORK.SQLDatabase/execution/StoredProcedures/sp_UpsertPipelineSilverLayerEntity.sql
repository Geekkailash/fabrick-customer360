


    CREATE PROCEDURE [execution].[sp_UpsertPipelineSilverLayerEntity] (
        @SilverLayerEntityId BIGINT,
        @SchemaName NVARCHAR(300),
        @TableName NVARCHAR(300),
        @IsProcessed BIT
    )
    WITH EXECUTE AS CALLER
    AS
    BEGIN
        SET NOCOUNT ON;

        IF NOT EXISTS (
            SELECT 1
            FROM [execution].[PipelineSilverLayerEntity] PLE
            WHERE PLE.[SilverLayerEntityId] = @SilverLayerEntityId
                AND PLE.[SchemaName] = @SchemaName
                AND PLE.[TableName] = @TableName
                AND PLE.[IsProcessed] = 0
        )
        BEGIN
            INSERT INTO [execution].[PipelineSilverLayerEntity] (
                [SilverLayerEntityId],
                [TableName],
                [SchemaName],
                [InsertDateTime],
                [IsProcessed]
            )
            SELECT @SilverLayerEntityId,
                @TableName,
                @SchemaName,
                GETDATE(),
                @IsProcessed;
        END
        ELSE IF @IsProcessed = 1
        BEGIN
            UPDATE [execution].[PipelineSilverLayerEntity]
            SET [IsProcessed] = @IsProcessed,
                [LoadEndDateTime] = GETDATE()
            WHERE [SilverLayerEntityId] = @SilverLayerEntityId
                AND [SchemaName] = @SchemaName
                AND [TableName] = @TableName;
        END

        -- Output for Fabric Pipeline
        SELECT @SilverLayerEntityId AS SilverLayerEntityId, 
            @IsProcessed as IsProcessed,
            @TableName as TableName,
            @SchemaName as [SchemaName];

        SET NOCOUNT OFF;
    END

GO

