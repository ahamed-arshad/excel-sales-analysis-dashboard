# Finishing steps in Excel (Microsoft 365, Windows)

The workbook already contains the cleaned data, 8 real pivot tables, 5 pivot charts, the KPI cards and the formula summary. Three things can only be done inside Excel: making the cleaned data a live Power Query output, adding slicers, and capturing the screenshot and GIF. Allow about 30 minutes.

> When you open the file, Excel rebuilds every pivot from the **Cleaned Data** sheet (the pivots are set to *refresh on open*). If Excel ever says it found a problem and offers to repair, let it repair, then follow the **Fallback** section at the end.

---

## 1. Power Query: make Cleaned Data a live query (about 10 min)

The **Cleaned Data** sheet is currently a static copy of exactly what the query produces. You will replace it with the real query output, so the project is genuinely "loaded and cleaned through Power Query".

1. Open `excel-sales-analysis-dashboard.xlsx`.
2. **Data → Get Data → From File → From Text/CSV**, choose `Sample - Superstore.csv`, then click **Transform Data** (not Load).
3. In the Power Query Editor: **Home → Advanced Editor**. Select everything, paste the contents of `power-query/Superstore_Clean.m`, and change the file path on the `Source` line to where your CSV lives. Click **Done**.
4. In the right-hand **Query Settings** pane, rename the query to `Superstore_Clean`. Click through the **Applied Steps** list once, so you can explain each one (trim, types, padded postal code, duplicates, blanks, rename, calculated columns).
5. **Home → Close & Load → Close & Load To… → Only Create Connection → OK.**
6. Go to the **Cleaned Data** sheet. Select columns **A:AA**, then **Home → Clear → Clear All**.
   *Use Clear, not Delete. Deleting columns would break the formulas that point at this sheet.*
7. **Data → Queries & Connections**, right-click `Superstore_Clean` → **Load To… → Table → Existing worksheet: `='Cleaned Data'!$A$1` → OK.**
8. **Data → Refresh All.**

**Check:** the table should have 9,993 rows and 27 columns. The Dashboard should show $2.30M sales, $286.4K profit, 12.5% margin and 5,009 orders.

*Optional:* load the raw file the same way with only the Source and Promoted Headers steps into the **Raw Data** sheet. Clear it first using the same Clear All method.

---

## 2. Slicers connected to every pivot (about 10 min)

1. On the **Analysis** sheet, click any cell inside pivot **a)** (for example B6).
2. **PivotTable Analyze → Insert Slicer**, tick **Region, Category, Segment, Order Year → OK.**
3. With the four slicers selected, press **Ctrl+X**, go to **Dashboard**, click cell **B11** and press **Ctrl+V**. Arrange them in one row across the dashed "slicer zone".
4. For **each** slicer: right-click → **Report Connections…** → tick **all 8 pivots** (PT_Region, PT_CategorySub, PT_MonthlyTrend, PT_DiscountBand, PT_TopCustomers, PT_ShipMode, PT_KPI, PT_BandMarginChart) → **OK**.
   All 8 appear in the list because they share one pivot cache.
5. Style the slicers. On the **Slicer** tab, choose a dark-blue slicer style and set **Columns**: Region 4, Category 3, Segment 3, Order Year 4. Set **Height** to about 1.9 cm.
6. Test: click *Central*. The KPI cards, all five charts and every pivot should change. Press **Alt+C** on a slicer, or click its clear-filter icon, to reset.

**What does not change with slicers, by design:** the formula summary (Region scorecard and Sub-category lookup) and the Key Insights text. Both always show the full dataset.

---

## 3. Chart and dashboard polish (about 5 min)

- On each chart, choose **PivotChart Analyze → Field Buttons → Hide All** for a clean look.
- If Excel re-applied default colours on refresh, recolour the series: Sales navy `#1F3A5F`, Profit teal `#2A9D8F`, and the margin bars red `#D1495B`.
- Gridlines are already off on Dashboard and Analysis. Headers are frozen on every sheet.
- **File → Save** (keep the .xlsx format; there are no macros).

---

## 4. Screenshot and GIF for the repo

- **Screenshot:** on Dashboard at 90% zoom, press **Win+Shift+S**, capture rows 1–62, and save it as `images/dashboard.png`.
- **GIF with ScreenToGif (free):**
  1. Open **Recorder** and frame the slicers plus KPI cards and charts.
  2. Record 10–15 seconds: click *West*, then *Furniture*, then *2017*, then clear.
  3. In the **Editor**, use **Save As → GIF** and save as `images/slicers-demo.gif`.

  Keep the GIF under about 10 MB: 10 fps and roughly 1280 px wide is plenty.

---

## 5. Push to GitHub

### Option A: GitHub Desktop (easiest)
1. Install GitHub Desktop and sign in.
2. **File → New repository**. Name it `excel-sales-analysis-dashboard` and choose a local path. Leave "Initialize with README" unticked, because you already have one.
3. Copy everything from this folder into the new repository folder: the workbook, `README.md`, `FINISHING_STEPS.md`, `power-query/` and `images/`.
4. In GitHub Desktop, write the summary "Excel sales analysis dashboard" → **Commit to main** → **Publish repository**. Untick "Keep this code private" so recruiters can see it.

### Option B: command line
```bash
cd path/to/excel-sales-analysis-dashboard
git init
git add .
git commit -m "Excel sales analysis dashboard: Power Query, pivots, slicers, insights"
git branch -M main
# create an empty public repo named excel-sales-analysis-dashboard on github.com first, then:
git remote add origin https://github.com/<your-username>/excel-sales-analysis-dashboard.git
git push -u origin main
```

**Last check on github.com:** the README renders, `images/dashboard.png` and the GIF display in it, and the .xlsx downloads.

---

## Be ready to explain (interview prep)

- **Why one pivot cache?** Slicers can only control pivots that share a cache. All 8 pivots are built on the same cache, which is why one slicer drives everything.
- **Why is Profit Margin a calculated field and not an average of the row-level `Profit Margin %`?** Averaging row margins gives every order line equal weight, so a $2 sale counts as much as a $2,000 sale. The calculated field computes `SUM(Profit) / SUM(Sales)`, which is the correct weighted margin.
- **How is "Total Orders" counted in a normal pivot?** Every line carries `Order Count = 1 / lines in its order`, so summing it gives distinct orders (5,009). This is exact when filtering by Region, Segment and Year, because those are order-level fields. With a Category filter it counts each order's share of lines in that category. The exact alternative is a Data Model pivot with *Distinct Count*.
- **Why do KPI cards use GETPIVOTDATA?** It ties each card to the KPI pivot, so the cards react to slicers.
- **Why does the formula summary use whole-column references to Cleaned Data?** So it keeps working when the Power Query table is reloaded into the same sheet.

---

## Fallback: rebuild a pivot by hand

Use this if Excel repairs the file and a pivot is lost. For each pivot:

1. Click in **Cleaned Data** and choose **Insert → PivotTable → Existing Worksheet**, then pick the cell under that block's title on **Analysis**.

2. Lay out the fields for the pivot you are rebuilding:

   | Pivot | Rows | Columns | Values |
   |---|---|---|---|
   | a | Region | | Sum of Sales Amount, Sum of Profit Amount |
   | b | Category, Sub-Category | | Sum of Sales Amount, Sum of Profit Amount |
   | c | Order Month | Order Year | Sum of Sales Amount |
   | d | Discount Band | | Sales, Profit, and calculated field Margin |
   | e | Customer Name | | Sum of Sales Amount, filtered with Value Filters → Top 10 by Sales, sorted descending |
   | f | Ship Mode | | Average of Shipping Days |

   For pivot d, create the calculated field first: **PivotTable Analyze → Fields, Items & Sets → Calculated Field**, `Margin = 'Profit Amount'/'Sales Amount'`.

3. Rename the value fields to match the KPI formulas: Total Sales, Total Profit, Profit Margin, Orders.

4. Rebuild a chart with **PivotTable Analyze → PivotChart**.

When you create the second and later pivots from the same table, Excel reuses the first pivot's cache automatically, so slicers will still connect to all of them.
