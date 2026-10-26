// Power Query (M) — query name: Superstore_Clean
// Loads the raw Kaggle "Sample - Superstore.csv", cleans it and adds the calculated columns.
// Paste into Home → Advanced Editor. Only change the file path on the Source line.
let
    // 1. Load (raw file is never edited)
    Source = Csv.Document(
        File.Contents("C:\Users\YOUR-NAME\Downloads\Sample - Superstore.csv"),
        [Delimiter = ",", Columns = 21, Encoding = 1252, QuoteStyle = QuoteStyle.Csv]
    ),
    PromotedHeaders = Table.PromoteHeaders(Source, [PromoteAllScalars = true]),

    // 2. Clean
    //    a) trim and clean every text value (16 product names had stray spaces)
    TrimmedText = Table.TransformColumns(
        PromotedHeaders,
        List.Transform(Table.ColumnNames(PromotedHeaders), each {_, each Text.Clean(Text.Trim(_)), type text})
    ),
    //    b) fix data types (dates in the file are US format M/D/YYYY, so parse with en-US)
    ChangedTypes = Table.TransformColumnTypes(
        TrimmedText,
        {
            {"Row ID", Int64.Type}, {"Order Date", type date}, {"Ship Date", type date},
            {"Postal Code", type text}, {"Sales", type number}, {"Quantity", Int64.Type},
            {"Discount", type number}, {"Profit", type number}
        },
        "en-US"
    ),
    //    c) postal codes are IDs, not numbers: restore leading zeros (e.g. 5408 → 05408)
    PaddedPostalCode = Table.TransformColumns(ChangedTypes, {{"Postal Code", each Text.PadStart(_, 5, "0"), type text}}),
    //    d) remove duplicates (compare every column except the Row ID) → removes 1 duplicate line
    RemovedDuplicates = Table.Distinct(PaddedPostalCode, List.RemoveItems(Table.ColumnNames(PaddedPostalCode), {"Row ID"})),
    //    e) blank check: drop rows missing a key field (0 rows in this dataset, kept as a safeguard)
    RemovedBlanks = Table.SelectRows(
        RemovedDuplicates,
        each [Order ID] <> null and [Order ID] <> "" and [Order Date] <> null and [Sales] <> null and [Profit] <> null
    ),
    //    f) rename columns clearly
    RenamedColumns = Table.RenameColumns(
        RemovedBlanks,
        {
            {"Row ID", "Order Line ID"}, {"Sales", "Sales Amount"}, {"Quantity", "Units"},
            {"Discount", "Discount Rate"}, {"Profit", "Profit Amount"}
        }
    ),

    // 3. Calculated columns
    AddedOrderYear     = Table.AddColumn(RenamedColumns, "Order Year", each Date.Year([Order Date]), Int64.Type),
    AddedOrderMonth    = Table.AddColumn(AddedOrderYear, "Order Month", each Date.ToText([Order Date], "MMM", "en-US"), type text),
    AddedProfitMargin  = Table.AddColumn(AddedOrderMonth, "Profit Margin %",
                            each if [Sales Amount] = 0 then null else [Profit Amount] / [Sales Amount], Percentage.Type),
    AddedShippingDays  = Table.AddColumn(AddedProfitMargin, "Shipping Days",
                            each Duration.Days([Ship Date] - [Order Date]), Int64.Type),
    AddedDiscountBand  = Table.AddColumn(AddedShippingDays, "Discount Band",
                            each if [Discount Rate] = 0 then "0%"
                                 else if [Discount Rate] <= 0.20 then "1-20%"
                                 else if [Discount Rate] <= 0.40 then "21-40%"
                                 else "40%+", type text),

    // Helper: each line carries 1 / (lines in its order), so summing it in a pivot counts distinct orders
    LinesPerOrder      = Table.Group(AddedDiscountBand, {"Order ID"}, {{"Lines In Order", each Table.RowCount(_), Int64.Type}}),
    JoinedLines        = Table.NestedJoin(AddedDiscountBand, {"Order ID"}, LinesPerOrder, {"Order ID"}, "LPO", JoinKind.LeftOuter),
    ExpandedLines      = Table.ExpandTableColumn(JoinedLines, "LPO", {"Lines In Order"}),
    AddedOrderCount    = Table.AddColumn(ExpandedLines, "Order Count", each 1 / [Lines In Order], type number),
    RemovedHelper      = Table.RemoveColumns(AddedOrderCount, {"Lines In Order"}),
    SortedRows         = Table.Sort(RemovedHelper, {{"Order Line ID", Order.Ascending}})
in
    SortedRows
