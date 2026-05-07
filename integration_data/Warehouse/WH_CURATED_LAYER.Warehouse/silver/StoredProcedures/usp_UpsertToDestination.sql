CREATE   PROCEDURE silver.usp_UpsertToDestination
(
    @SourceSchema      SYSNAME,
    @SourceTable       SYSNAME,
    @DestinationSchema SYSNAME,
    @DestinationTable  SYSNAME,
    @KeyColumn         SYSNAME
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @InsertColumnList NVARCHAR(MAX);
    DECLARE @SelectColumnList NVARCHAR(MAX);
    DECLARE @UpdateSetList NVARCHAR(MAX);
    DECLARE @SQL NVARCHAR(MAX);

    SELECT
        @InsertColumnList =
            STRING_AGG(QUOTENAME(dest.COLUMN_NAME), ', ')
            WITHIN GROUP (ORDER BY dest.ORDINAL_POSITION),

        @SelectColumnList =
            STRING_AGG('src.' + QUOTENAME(dest.COLUMN_NAME), ', ')
            WITHIN GROUP (ORDER BY dest.ORDINAL_POSITION),

        @UpdateSetList =
            STRING_AGG(
                'dest.' + QUOTENAME(dest.COLUMN_NAME) + ' = src.' + QUOTENAME(dest.COLUMN_NAME),
                ', '
            )
            WITHIN GROUP (ORDER BY dest.ORDINAL_POSITION)

    FROM INFORMATION_SCHEMA.COLUMNS dest
    INNER JOIN INFORMATION_SCHEMA.COLUMNS src
        ON src.COLUMN_NAME = dest.COLUMN_NAME
       AND src.TABLE_SCHEMA = @SourceSchema
       AND src.TABLE_NAME = @SourceTable

    WHERE dest.TABLE_SCHEMA = @DestinationSchema
      AND dest.TABLE_NAME = @DestinationTable

      -- 🔥 Exclusions
      AND dest.COLUMN_NAME <> @KeyColumn
      AND dest.COLUMN_NAME <> 'last_modified'
      AND dest.COLUMN_NAME NOT IN ('HashedPKColumn', 'HashedNonKeyColumn', 'RecordLoadDate');

    IF @InsertColumnList IS NULL
    BEGIN
        THROW 50001, 'No matching columns found between source and destination table.', 1;
    END;

    -- Add Key + last_modified
    SET @InsertColumnList =
        QUOTENAME(@KeyColumn) + ', ' + @InsertColumnList + ', [last_modified]';

    SET @SelectColumnList =
        'src.' + QUOTENAME(@KeyColumn) + ', ' + @SelectColumnList + ', CURRENT_TIMESTAMP';

    SET @UpdateSetList =
        @UpdateSetList + ', dest.[last_modified] = CURRENT_TIMESTAMP';

    --------------------------------------------------
    -- UPSERT
    --------------------------------------------------
    SET @SQL = '
        UPDATE dest
        SET ' + @UpdateSetList + '
        FROM '
            + QUOTENAME(@DestinationSchema) + '.'
            + QUOTENAME(@DestinationTable) + ' dest
        INNER JOIN '
            + QUOTENAME(@SourceSchema) + '.'
            + QUOTENAME(@SourceTable) + ' src
            ON dest.' + QUOTENAME(@KeyColumn) + ' = src.' + QUOTENAME(@KeyColumn) + ';

        INSERT INTO '
            + QUOTENAME(@DestinationSchema) + '.'
            + QUOTENAME(@DestinationTable) + '
        (' + @InsertColumnList + ')
        SELECT ' + @SelectColumnList + '
        FROM '
            + QUOTENAME(@SourceSchema) + '.'
            + QUOTENAME(@SourceTable) + ' src
        WHERE NOT EXISTS (
            SELECT 1
            FROM '
                + QUOTENAME(@DestinationSchema) + '.'
                + QUOTENAME(@DestinationTable) + ' dest
            WHERE dest.' + QUOTENAME(@KeyColumn) + ' = src.' + QUOTENAME(@KeyColumn) + '
        );
    ';

    EXEC sp_executesql @SQL;
END;