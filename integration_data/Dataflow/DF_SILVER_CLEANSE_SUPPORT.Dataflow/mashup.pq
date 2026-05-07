[StagingDefinition = [Kind = "FastCopy"]]
section Section1;
shared start_time = "" meta [IsParameterQuery = true, IsParameterQueryRequired = false, Type = type text];
shared end_time = "2026-05-02T19:46:38.253" meta [IsParameterQuery = true, IsParameterQueryRequired = false, Type = type text];
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "support_DataDestination", IsNewTarget = false], Settings = [Kind = "Manual", AllowCreation = false, ColumnSettings = [Mappings = {[SourceColumnName = "ticket_id", DestinationColumnName = "ticket_id"], [SourceColumnName = "customer_id", DestinationColumnName = "customer_id"], [SourceColumnName = "issue_type", DestinationColumnName = "issue_type"], [SourceColumnName = "ticket_date", DestinationColumnName = "ticket_date"], [SourceColumnName = "resolution_status", DestinationColumnName = "resolution_status"], [SourceColumnName = "year", DestinationColumnName = "year"], [SourceColumnName = "month", DestinationColumnName = "month"], [SourceColumnName = "day", DestinationColumnName = "day"], [SourceColumnName = "HashedPKColumn", DestinationColumnName = "HashedPKColumn"], [SourceColumnName = "HashedNonKeyColumns", DestinationColumnName = "HashedNonKeyColumns"], [SourceColumnName = "RecordLoadDate", DestinationColumnName = "RecordLoadDate"]}], DynamicSchema = false, UpdateMethod = [Kind = "Replace"], TypeSettings = [Kind = "Table"]]]}]
shared support = let
  StartTimeValue =
    if start_time = null or Text.Trim(Text.From(start_time)) = "" then
      #datetime(2000, 1, 1, 0, 0, 0)
    else
      DateTime.FromText(Text.From(start_time)),

  EndTimeValue =
    if end_time = null or Text.Trim(Text.From(end_time)) = "" then
      DateTime.LocalNow()
    else
      DateTime.FromText(Text.From(end_time)),

  Source = Lakehouse.Contents(null),
  Navigation = Source{[workspaceId = "2effab8c-7fe4-4bfd-b678-34e1fd29d8ab"]}[Data],
  #"Navigation 1" = Navigation{[lakehouseId = "71329364-5fc3-4b71-a75a-0b851ee4e3ba"]}[Data],
  #"Navigation 2" = #"Navigation 1"{[Id = "support", ItemKind = "Table"]}[Data],
  #"Change type" = Table.TransformColumnTypes(#"Navigation 2", {{"ticket_id", type text}, {"customer_id", Int64.Type}, {"issue_type", type text}, {"ticket_date", type text}, {"resolution_status", type text}}),
  #"Transform columns" = Table.TransformColumns(#"Change type", {{"issue_type", each let
                    trimmed = Text.Trim(_),
                    proper = Text.Proper(trimmed),
                    cleaned = if List.Contains({"Na", "na", "n/a"}, proper) then null else proper
                in
                    cleaned, type nullable text}}),
  Custom = Table.TransformColumns(#"Transform columns", {{"resolution_status", Text.Proper}}),
  #"Custom 1" = Table.TransformColumns(
    #"Custom",
    {
        {
            "ticket_date",
            (d) =>
                let
                    val = if d = null or Text.Trim(Text.Lower(d)) = "" or Text.Trim(Text.Lower(d)) = "na" or Text.Trim(Text.Lower(d)) = "n/a" then null else Text.Trim(d),
                    parse =
                        if val = null then null
                        else if Text.Length(val) = 10 and Text.Range(val,4,1) = "-" then try Date.FromText(val) otherwise null
                        else if Text.Length(val) = 10 and Text.Range(val,2,1) = "-" then try Date.FromText(Text.Range(val,6,4) & "-" & Text.Range(val,3,2) & "-" & Text.Range(val,0,2)) otherwise null
                        else if Text.Length(val) = 10 and Text.Range(val,4,1) = "/" then try Date.FromText(Text.Replace(val,"/","-")) otherwise null
                        else if Text.Length(val) = 10 and Text.Range(val,2,1) = "/" then try Date.FromText(Text.Range(val,6,4) & "-" & Text.Range(val,3,2) & "-" & Text.Range(val,0,2)) otherwise null
                        else if Text.Length(val) = 8 and Text.Select(val, {"0".."9"}) = val then
                            let
                                y = Text.Range(val,0,4),
                                m = Text.Range(val,4,2),
                                d2 = Text.Range(val,6,2),
                                y2 = Text.Range(val,4,4),
                                m2 = Text.Range(val,2,2),
                                d3 = Text.Range(val,0,2),
                                tryYMD = try Date.FromText(y & "-" & m & "-" & d2) otherwise null,
                                tryDMY = try Date.FromText(y2 & "-" & m2 & "-" & d3) otherwise null
                            in
                                if tryYMD <> null then tryYMD else tryDMY
                        else null
                in
                    parse,
            type nullable date
        }
    }
),
  #"Custom 2" = Table.TransformColumns(#"Custom 1", {{"resolution_status", Text.Proper}})
in
  #"Custom 2";
shared support_DataDestination = let
  Pattern = Fabric.Warehouse([CreateNavigationProperties = false]),
  Navigation_1 = Pattern{[workspaceId = "2effab8c-7fe4-4bfd-b678-34e1fd29d8ab"]}[Data],
  Navigation_2 = Navigation_1{[warehouseId = "4a2ecce9-6539-4d54-91bf-38ab15bfdb35"]}[Data],
  TableNavigation = Navigation_2{[Schema = "temp", Item = "support"]}[Data]
in
  TableNavigation;
