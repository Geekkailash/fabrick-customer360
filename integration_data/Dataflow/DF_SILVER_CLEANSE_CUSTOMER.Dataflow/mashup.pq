[DefaultOutputDestinationSettings = [DestinationDefinition = [Kind = "Reference", QueryName = "DefaultDestination", IsNewTarget = true], UpdateMethod = [Kind = "Append"], DestinationTypeSettings = [Kind = "Table"]], StagingDefinition = [Kind = "FastCopy"]]
section Section1;
[Description = "start timestamp"]
shared start_time = "" meta [IsParameterQuery = true, IsParameterQueryRequired = false, Type = type text];
shared end_time = "2026-05-02T19:46:38.253" meta [IsParameterQuery = true, IsParameterQueryRequired = true, Type = type text];
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "customer_DataDestination", IsNewTarget = false], Settings = [Kind = "Manual", AllowCreation = false, ColumnSettings = [Mappings = {[SourceColumnName = "customer_id", DestinationColumnName = "customer_id"], [SourceColumnName = "name", DestinationColumnName = "name"], [SourceColumnName = "gender", DestinationColumnName = "gender"], [SourceColumnName = "email", DestinationColumnName = "email"], [SourceColumnName = "dob", DestinationColumnName = "dob"], [SourceColumnName = "location", DestinationColumnName = "location"], [SourceColumnName = "year", DestinationColumnName = "year"], [SourceColumnName = "month", DestinationColumnName = "month"], [SourceColumnName = "day", DestinationColumnName = "day"], [SourceColumnName = "HashedPKColumn", DestinationColumnName = "HashedPKColumn"], [SourceColumnName = "HashedNonKeyColumns", DestinationColumnName = "HashedNonKeyColumns"], [SourceColumnName = "RecordLoadDate", DestinationColumnName = "RecordLoadDate"]}], DynamicSchema = false, UpdateMethod = [Kind = "Replace"], TypeSettings = [Kind = "Table"]]]}]
shared customer = let
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
  #"Navigation 2" = #"Navigation 1"{[Id = "customer", ItemKind = "Table"]}[Data],

  #"Changed Type" =
    Table.TransformColumnTypes(
      #"Navigation 2",
      {
        {"customer_id", type text},
        {"RecordLoadDate", type datetime}
      }
    ),
  #"Change type" = Table.TransformColumnTypes(#"Changed Type", {{"customer_id", Int64.Type}, {"name", type text}, {"EMAIL", type text}, {"gender", type text}, {"dob", type text}, {"location", type text}}),
  #"Renamed columns" = Table.RenameColumns(
    Table.TransformColumns(
        #"Change type",
        {{"EMAIL", each Text.Lower(Text.Trim(_)), type text}}
    ),
    {{"EMAIL", "email"}}
),
  lowercase = Table.TransformColumns(#"Renamed columns", {{"name", each Text.Lower(Text.From(_)), type text}}),
  #"Transform columns" = Table.TransformColumns(lowercase, {{"gender", each if _ = null then "Other"
            else
                let
                    g = Text.Lower(_)
                in
                    if Text.StartsWith(g, "f") then "Female"
                    else if Text.StartsWith(g, "m") then "Male"
                    else "Other", type text}}),
  #"Transform columns 1" = Table.TransformColumns(#"Transform columns", {{"dob", each let
                    dobText = Text.Replace(_, "/", "-"),
                    tryISO = try Date.From(dobText),
                    tryDMY = try Date.From(Date.FromText(dobText, [Format="dd-MM-yyyy"])),
                    tryYMD = try Date.From(Date.FromText(dobText, [Format="yyyy-MM-dd"])),
                    tryYMD2 = try Date.From(Date.FromText(Text.Replace(dobText, "-", ""), [Format="yyyyMMdd"])),
                    tryDMY2 = try Date.From(Date.FromText(Text.Replace(dobText, "-", ""), [Format="ddMMyyyy"])),
                    tryDMYslash = try Date.From(Date.FromText(Text.Replace(dobText, "-", "/"), [Format="dd/MM/yyyy"])),
                    tryYMDslash = try Date.From(Date.FromText(Text.Replace(dobText, "-", "/"), [Format="yyyy/MM/dd"])),
                    result =
                        if tryISO[HasError] = false then tryISO[Value]
                        else if tryDMY[HasError] = false then tryDMY[Value]
                        else if tryYMD[HasError] = false then tryYMD[Value]
                        else if tryYMD2[HasError] = false then tryYMD2[Value]
                        else if tryDMY2[HasError] = false then tryDMY2[Value]
                        else if tryDMYslash[HasError] = false then tryDMYslash[Value]
                        else if tryYMDslash[HasError] = false then tryYMDslash[Value]
                        else null
                in
                    result, type nullable date}}),
  Custom = Table.TransformColumns(#"Transform columns 1", {{"location", Text.Lower, type text}}),
  #"Removed duplicates" = Table.Distinct(
    Table.ReorderColumns(
        #"Custom",
        {"customer_id", "name", "gender", "email", "dob", "location"}
    ),
    {"customer_id"}
)
in
  #"Removed duplicates";
shared DefaultDestination = let
  Source = Fabric.Warehouse([CreateNavigationProperties = false, HierarchicalNavigation = null]),
  #"Navigation 1" = Source{[workspaceId = "."]}[Data],
  #"Navigation 2" = #"Navigation 1"{[displayName = "WH_CURATED_LAYER"]}[Data]
in
  #"Navigation 2";
shared customer_DataDestination = let
  Pattern = Fabric.Warehouse([CreateNavigationProperties = false]),
  Navigation_1 = Pattern{[workspaceId = "2effab8c-7fe4-4bfd-b678-34e1fd29d8ab"]}[Data],
  Navigation_2 = Navigation_1{[warehouseId = "4a2ecce9-6539-4d54-91bf-38ab15bfdb35"]}[Data],
  TableNavigation = Navigation_2{[Schema = "temp", Item = "customer"]}[Data]
in
  TableNavigation;
