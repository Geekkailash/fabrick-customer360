[StagingDefinition = [Kind = "FastCopy"]]
section Section1;
shared start_time = "NULL" meta [IsParameterQuery = true, IsParameterQueryRequired = false, Type = type text, DefaultValue = ""];
[Description = "end_time"]
shared end_time = "2026-05-02T19:46:38.253" meta [IsParameterQuery = true, IsParameterQueryRequired = true, Type = type text];
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "payments_DataDestination", IsNewTarget = false], Settings = [Kind = "Manual", AllowCreation = false, ColumnSettings = [Mappings = {[SourceColumnName = "payment_id", DestinationColumnName = "payment_id"], [SourceColumnName = "customer_id", DestinationColumnName = "customer_id"], [SourceColumnName = "payment_date", DestinationColumnName = "payment_date"], [SourceColumnName = "payment_method", DestinationColumnName = "payment_method"], [SourceColumnName = "payment_status", DestinationColumnName = "payment_status"], [SourceColumnName = "amount", DestinationColumnName = "amount"], [SourceColumnName = "year", DestinationColumnName = "year"], [SourceColumnName = "month", DestinationColumnName = "month"], [SourceColumnName = "day", DestinationColumnName = "day"], [SourceColumnName = "HashedPKColumn", DestinationColumnName = "HashedPKColumn"], [SourceColumnName = "HashedNonKeyColumns", DestinationColumnName = "HashedNonKeyColumns"], [SourceColumnName = "RecordLoadDate", DestinationColumnName = "RecordLoadDate"]}], DynamicSchema = false, UpdateMethod = [Kind = "Replace"], TypeSettings = [Kind = "Table"]]]}]
shared payments = let
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
  #"Navigation 2" = #"Navigation 1"{[Id = "payments", ItemKind = "Table"]}[Data],

  #"Changed Type" =
    Table.TransformColumnTypes(
      #"Navigation 2",
      {
        {"payment_id", type text},
        {"RecordLoadDate", type datetime}
      }
    ),
  #"Change type" = Table.TransformColumnTypes(#"Navigation 2", {{"payment_id", type text}}),
  #"Change type 1" = Table.TransformColumnTypes(#"Change type", {{"payment_id", type text}, {"customer_id", Int64.Type}, {"payment_date", type text}, {"payment_method", type text}, {"payment_status", type text}, {"amount", type number}}),
  Custom = Table.TransformColumns(#"Change type 1", {{"payment_method", Text.Proper}, {"payment_status", Text.Proper}}),
  #"Transform columns" = Table.TransformColumns(Custom, {{"amount", each if _ = null or _ = "" or (try Number.From(_) otherwise null) = null or Number.From(_) < 0 then null else Number.From(_), type nullable number}}),
  #"Custom 1" = Table.TransformColumns(
    #"Transform columns",
    {
        {
            "payment_date",
            (d) =>
                let
                    val = if d = null or d = "" or Text.Lower(Text.Trim(d)) = "n/a" or Text.Lower(Text.Trim(d)) = "na" then null else Text.Trim(d),
                    parse =
                        if val = null then null
                        else if Text.Length(val) = 10 and Text.Range(val,4,1) = "-" and Text.Range(val,7,1) = "-" then
                            try Date.FromText(val) otherwise null
                        else if Text.Length(val) = 10 and Text.Range(val,2,1) = "-" and Text.Range(val,5,1) = "-" then
                            try Date.FromText(Text.Range(val,6,4) & "-" & Text.Range(val,3,2) & "-" & Text.Range(val,0,2)) otherwise null
                        else if Text.Length(val) = 10 and Text.Range(val,4,1) = "/" and Text.Range(val,7,1) = "/" then
                            try Date.FromText(Text.Replace(val, "/", "-")) otherwise null
                        else if Text.Length(val) = 10 and Text.Range(val,2,1) = "/" and Text.Range(val,5,1) = "/" then
                            try Date.FromText(Text.Range(val,6,4) & "-" & Text.Range(val,3,2) & "-" & Text.Range(val,0,2)) otherwise null
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
            type date
        }
    }
)
in
  #"Custom 1";
shared payments_DataDestination = let
  Pattern = Fabric.Warehouse([CreateNavigationProperties = false]),
  Navigation_1 = Pattern{[workspaceId = "2effab8c-7fe4-4bfd-b678-34e1fd29d8ab"]}[Data],
  Navigation_2 = Navigation_1{[warehouseId = "4a2ecce9-6539-4d54-91bf-38ab15bfdb35"]}[Data],
  TableNavigation = Navigation_2{[Schema = "temp", Item = "payments"]}[Data]
in
  TableNavigation;
