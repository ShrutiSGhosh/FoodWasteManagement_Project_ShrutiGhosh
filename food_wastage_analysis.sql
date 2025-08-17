-- # Local Food Wastage Management System
-- ## Phase 1: Database Setup
-- Purpose: Create SQLite database 'food_wastage.db' and define the structure for four core tables:
-- providers, receivers, food_listings, claims.
-- Actions Completed:
-- 1. Created 'food_wastage.db' in D:\Local_Food_Wastage_Management_System\sql\
-- 2. Defined table schemas with correct data types and foreign key relationships.
-- 3. Saved database file for persistent storage.

-- ## Phase 2: Data Import
-- Purpose: Load CSV data into the four tables without altering the structure.
-- Actions Completed:
-- 1. Used DB Browser → File → Import → Table from CSV file.
-- 2. Imported providers_data.csv into providers table.
-- 3. Imported receivers_data.csv into receivers table.
-- 4. Imported food_listings_data.csv into food_listings table.
-- 5. Imported claims_data.csv into claims table.
-- 6. Clicked 'Write Changes' to save data permanently to the database file.

-- ## Step: Data Verification After Import
-- Purpose: Confirm that all rows from CSV files have been loaded successfully.

-- Verify row counts for all tables
SELECT COUNT(*) AS Provider_Count FROM providers;
SELECT COUNT(*) AS Receiver_Count FROM receivers;
SELECT COUNT(*) AS Food_Listing_Count FROM food_listings;
SELECT COUNT(*) AS Claim_Count FROM claims;
-- ## Interpretation:
-- If the counts match the row numbers in the CSV files (expected: 1000 each), 
-- the import process was successful and the database is ready for analysis.

-- # Local Food Wastage Management System
-- ## Phase 3: Analysis Queries
-- Author: Shruti Sumadhur Ghosh
-- Date: 2025-08-11
-- Purpose: Answer 15 business questions using SQL queries on the food_wastage.db database.
-- Note: Each query includes purpose, SQL code, and interpretation notes.

---------------------------------------------------------
-- 1. How many food providers and receivers are there in each city?
---------------------------------------------------------
-- ## Purpose:
-- Understand distribution of providers and receivers by city to identify coverage areas.
SELECT 
    p.City,
    COUNT(DISTINCT p.Provider_ID) AS Total_Providers,
    COUNT(DISTINCT r.Receiver_ID) AS Total_Receivers
FROM providers p
LEFT JOIN receivers r ON p.City = r.City
GROUP BY p.City
ORDER BY p.City;

-- Sample output (first 5 rows):
-- City | Total_Providers | Total_Receivers
-- Adambury | 1 | 0
-- Adamsview | 1 | 0
-- Adamsville | 1 | 0
-- Addieworth | 1 | 2
-- Addieland | 1 | 3

-- Interpretation:
-- Many cities have providers but no receivers. Outreach is needed in these cities.

---------------------------------------------------------
-- 2. Which type of food provider contributes the most food?
---------------------------------------------------------
-- ## Purpose:
-- Identify the provider type that lists the most total quantity of food.
SELECT 
    Provider_Type,
    SUM(Quantity) AS Total_Quantity
FROM food_listings
GROUP BY Provider_Type
ORDER BY Total_Quantity DESC;

-- 
-- #### Sample Output
-- Provider_Type     | Total_Quantity
-- ----------------- | --------------
-- Restaurant        | 6923
-- Supermarket       | 6696
-- Catering Service  | 6116
-- Grocery Store     | 6059
--
-- #### Interpretation
-- Restaurants contribute the highest total quantity of food (6,923 units), 
-- followed closely by supermarkets (6,696 units).  
-- This indicates that restaurants are the primary source of surplus food 
-- in the system, making them key stakeholders in food redistribution efforts.
---------------------------------------------------------
-- 3. What is the contact information of food providers in a specific city? (Example: 'Delhi')
---------------------------------------------------------
-- ## Purpose:
-- Enable quick access to provider contact details in a given location.

SELECT 
    Name,
    Contact,
    Address
FROM providers
WHERE City = 'Adambury';
-- ### Query 3 – What is the contact information of food providers in a specific city?
--
-- ## Purpose:
-- Enable quick access to provider contact details in a given location.
--
-- #### Sample Output
-- Name         | Contact    | Address
-- -------------|------------|-----------------------------------------
-- Ibarra LLC   | 6703380260 | 064 Andrea Land Suite 946, Lake Melody, ME 49581
--
-- #### Interpretation
-- In Adambury, there is currently only one registered food provider, "Ibarra LLC."  
-- This information is useful for NGOs or receivers operating in the Adambury area  
-- to directly contact the provider for surplus food claims.

-- ### Query 3 – All Cities: Provider contact details for every city
--
-- ## Purpose:
-- Returns contact details for all providers, regardless of city.
-- Ideal for exporting to Streamlit where city filtering is done via dropdowns or search.
--
-- ## Instructions:
-- 1. No need to change anything here.
-- 2. Save/export this as query03_all_provider_contacts.csv.

SELECT 
    Name,
    Contact,
    Address,
    City
FROM providers;
-- ### Query 3 – All Cities: Provider contact details for every city
--
-- ## Purpose:
-- Retrieves the full list of provider contact details across all cities.
-- Useful for exporting a complete dataset to Streamlit, where city-based filtering
-- can be handled dynamically via dropdowns or search.
--
-- ## Output Columns:
-- - Name: Full name or organization name of the provider.
-- - Contact: Phone number or contact information.
-- - Address: Street address and suite/apartment details.
-- - City: City name, including state abbreviation and ZIP code.
--
-- ## Sample Output:
-- | Name                      | Contact              | Address                              | City                     |
-- |---------------------------|----------------------|---------------------------------------|--------------------------|
-- | Gonzales-Cochran          | +1-600-220-0480      | 74347 Christopher Extensions          | Andreamouth, OK 91839    |
-- | Nielsen, Johnson and Fuller | +1-925-283-8901x6297 | 91228 Hanson Stream                   | Welchtown, OR 27136      |
-- | Miller-Black              | 001-517-295-2206     | 561 Martinez Point Suite 507         | Guzmanchester, WA 94320  |
-- | Clark, Prince and Williams | 556.944.8935x401     | 467 Bell Trail Suite 409             | Port Jesus, IA 61188     |
-- | Coleman-Farley            | 193.714.6577         | 078 Matthew Creek Apt. 319           | Saraborough, MA 53978    |
--
-- ## Notes:
-- - Execution returned 1000 rows in 6ms.
-- - No errors encountered.
-- - Ideal for generating query03_all_provider_contacts.csv for use in Streamlit.
---------------------------------------------------------
-- 4. Which receivers have claimed the most food?
---------------------------------------------------------
-- ## Purpose:
-- Find the most active receivers based on number of claims.
SELECT 
    r.Name,
    COUNT(c.Claim_ID) AS Total_Claims
FROM receivers r
JOIN claims c ON r.Receiver_ID = c.Receiver_ID
GROUP BY r.Name
ORDER BY Total_Claims DESC
LIMIT 10;

--
-- ## Output Columns:
-- - Name: Full name of the receiver.
-- - Total_Claims: Number of claims submitted by the receiver.
--
-- ## Sample Output:
-- | Name              | Total_Claims |
-- |-------------------|--------------|
-- | William Frederick | 5            |
-- | Scott Hunter      | 5            |
-- | Matthew Webb      | 5            |
-- | Anthony Garcia    | 5            |
-- | Kristine Martin   | 4            |
-- | Kristina Simpson  | 4            |
-- | Jennifer Nelson   | 4            |
-- | Donald Caldwell   | 4            |
-- | Chelsea Powell    | 4            |
-- | Betty Reid        | 4            |
--
-- ## Notes:
-- - Execution returned 10 rows in 13ms.
-- - No errors encountered.
-- - Ideal for generating query04_top_receivers.csv for reporting or dashboard use.
---------------------------------------------------------
-- 5. What is the total quantity of food available from all providers?
---------------------------------------------------------
-- ## Purpose:
-- Calculate the overall stock available in the system.
SELECT 
    SUM(Quantity) AS Total_Food_Quantity
FROM food_listings;
--
-- ## Output Columns:
-- - Total_Food_Quantity: Sum of all food quantities listed across providers.
--
-- ## Sample Output:
-- | Total_Food_Quantity |
-- |---------------------|
-- | 25794               |
--

-- ## Interpretation:
-- Gives a snapshot of current food supply capacity.
-- Calculates the total quantity of food currently listed by all providers.
-- Useful for assessing overall inventory and planning distribution efforts.
-- ## Notes:
-- - Execution returned 1 row in 8ms.
-- - No errors encountered.
-- - Ideal for generating query05_total_food_quantity.csv or integrating into dashboard metrics.

---------------------------------------------------------
---------------------------------------------------------
-- 6. Which city has the highest number of food listings?
---------------------------------------------------------
-- ## Purpose:
-- Find the most active city in terms of food availability.
SELECT 
    Location,
    COUNT(Food_ID) AS Total_Listings
FROM food_listings
GROUP BY Location
ORDER BY Total_Listings DESC
LIMIT 1;
-- ## Output Columns:
-- - Location: Name of the city.
-- - Total_Listings: Total number of food listings in that city.
--
-- ## Sample Output:
-- | Location      | Total_Listings |
-- |---------------|----------------|
-- | South Kathryn | 6              |
--

-- ## Interpretation:
-- This city is the hub for food donations.
--
-- ## Purpose:
-- Identifies the city with the greatest number of food listings.
-- Helps highlight regional activity and potential distribution hubs.
--
-- ## Notes:
-- - Execution returned 1 row in 5ms.
-- - No errors encountered.
-- - Ideal for generating query06_top_city_listings.csv or visualizing geographic trends.
---------------------------------------------------------
-- 7. What are the most commonly available food types?
---------------------------------------------------------
-- ## Purpose:
-- Determine which food categories dominate the listings.
SELECT 
    Food_Type,
    COUNT(Food_ID) AS Listings_Count
FROM food_listings
GROUP BY Food_Type
ORDER BY Listings_Count DESC;
-- ## Output Columns:
-- - Food_Type: Category of food (e.g., Vegetarian, Vegan, Non-Vegetarian).
-- - Listings_Count: Number of listings available for each food type.
--
-- ## Sample Output:
-- | Food_Type       | Listings_Count |
-- |------------------|----------------|
-- | Vegetarian       | 336            |
-- | Vegan            | 334            |
-- | Non-Vegetarian   | 330            |
--

-- ## Interpretation:
-- High counts indicate popular or abundant food categories.
-- Analyzes the distribution of food listings by type to understand dietary preferences or availability.
-- Useful for tailoring outreach, inventory planning, and dietary-specific programs.
--
-- ## Notes:
-- - Execution returned 3 rows.
-- - No errors encountered.
-- - Ideal for generating query07_food_type_distribution.csv or visualizing dietary trends.

---------------------------------------------------------
---------------------------------------------------------
-- 8. How many food claims have been made for each food item?
---------------------------------------------------------
-- ## Purpose:
-- See claim frequency per specific food item.
SELECT 
    fl.Food_Name,
    COUNT(c.Claim_ID) AS Total_Claims
FROM food_listings fl
LEFT JOIN claims c ON fl.Food_ID = c.Food_ID
GROUP BY fl.Food_Name
ORDER BY Total_Claims DESC;
-- ## Output Columns:
-- - Food_Name: Name of the food item.
-- - Total_Claims: Number of claims made for that item.
--
-- ## Sample Output:
-- | Food_Name   | Total_Claims |
-- |-------------|--------------|
-- | Rice        | 122          |
-- | Soup        | 114          |
-- | Dairy       | 110          |
-- | Fish        | 108          |
-- | Salad       | 106          |
-- | Chicken     | 102          |
-- | Bread       | 94           |
-- | Pasta       | 87           |
-- | Vegetables  | 86           |
-- | Fruits      | 71           |
--

-- ## Interpretation:
-- Highlights in-demand food items.
-- Determines how frequently each food item has been claimed.
-- Helps identify high-demand items and guide future stocking or procurement decisions.
--
-- ## Notes:
-- - Execution returned 10 rows in 6ms.
-- - No errors encountered.
-- - Ideal for generating query08_food_claims_by_item.csv or analyzing demand trends.

---------------------------------------------------------
---------------------------------------------------------
-- 9. Which provider has had the highest number of successful food claims?
---------------------------------------------------------
-- ## Purpose:
-- Identify providers whose food is most often successfully claimed.
SELECT 
    p.Name,
    COUNT(c.Claim_ID) AS Successful_Claims
FROM providers p
JOIN food_listings fl ON p.Provider_ID = fl.Provider_ID
JOIN claims c ON fl.Food_ID = c.Food_ID
WHERE c.Status = 'Completed'
GROUP BY p.Name
ORDER BY Successful_Claims DESC
LIMIT 1;
--
-- ## Output Columns:
-- - Name: Name of the provider.
-- - Successful_Claims: Number of claims marked as 'Completed' for that provider's listings.
--
-- ## Sample Output:
-- | Name        | Successful_Claims |
-- |-------------|-------------------|
-- | Barry Group | 5                 |
--

-- ## Interpretation:
-- Top provider in terms of completed claims indicates efficient distribution.
-- Identifies the provider whose food listings have resulted in the most completed claims.
-- Useful for recognizing high-performing providers and optimizing future partnerships.
-- ## Notes:
-- - Execution returned 1 row.
-- - No errors encountered.
-- - Ideal for generating query09_top_provider_success.csv or showcasing provider performance.
---------------------------------------------------------
-- 10. What percentage of food claims are completed vs pending vs cancelled?
---------------------------------------------------------
-- ## Purpose:
-- Analyze claim success rates.
SELECT 
    Status,
    COUNT(*) AS Count_Status,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM claims), 2) AS Percentage
FROM claims
GROUP BY Status;
--
-- ## Output Columns:
-- - Status: The current state of the claim (e.g., Completed, Pending, Cancelled).
-- - Count_Status: Total number of claims in that status.
-- - Percentage: Proportion of claims in that status relative to all claims, rounded to two decimal places.
--
-- ## Sample Output:
-- | Status    | Count_Status | Percentage |
-- |-----------|--------------|------------|
-- | Cancelled | 336          | 33.60      |
-- | Completed | 339          | 33.90      |
-- | Pending   | 325          | 32.50      |
--
-- ## Interpretation:
-- Shows the distribution of claim outcomes.
-- Analyzes the distribution of food claim statuses to assess operational efficiency and user engagement.
-- Helps identify bottlenecks (e.g., high pending rates) or areas for improvement.

-- ## Notes:
-- - Execution returned 3 rows.
-- - No errors encountered.
-- - Ideal for generating query10_claim_status_distribution.csv or visualizing claim lifecycle trends.

---------------------------------------------------------
--------------------------------------------------------
-- 11. What is the average quantity of food claimed per receiver?
---------------------------------------------------------
-- ## Purpose:
-- Measure typical claim size per receiver.
SELECT 
    r.Name,
    ROUND(AVG(fl.Quantity), 2) AS Avg_Quantity_Claimed
FROM receivers r
JOIN claims c ON r.Receiver_ID = c.Receiver_ID
JOIN food_listings fl ON c.Food_ID = fl.Food_ID
GROUP BY r.Name
ORDER BY Avg_Quantity_Claimed DESC;
--
-- ## Output Columns:
-- - Name: Full name of the receiver.
-- - Avg_Quantity_Claimed: Average quantity of food claimed, rounded to two decimal places.
--
-- ## Sample Output:
-- | Name             | Avg_Quantity_Claimed |
-- |------------------|----------------------|
-- | Thomas Villanueva| 50.0                 |
-- | Peggy Knight     | 50.0                 |
-- | Nancy Silva      | 50.0                 |
-- | Nancy Jones      | 50.0                 |
-- | Lisa Pitts       | 50.0                 |
-- | Daniel Williams  | 50.0                 |
--
-- ## Interpretation:
-- Larger averages may indicate bulk receivers.
-- Measures the typical size of food claims made by each receiver.
-- Useful for understanding consumption patterns and tailoring distribution strategies.

-- ## Notes:
-- - Execution returned 620 rows in 5ms.
-- - No errors encountered.
-- - Ideal for generating query12_avg_claim_quantity.csv or analyzing receiver-level demand.

---------------------------------------------------------
--------------------------------------------------------
-- 12. Which meal type is claimed the most?
---------------------------------------------------------
-- ## Purpose:
-- Determine preferred meal categories.
SELECT 
    fl.Meal_Type,
    COUNT(c.Claim_ID) AS Total_Claims
FROM food_listings fl
JOIN claims c ON fl.Food_ID = c.Food_ID
GROUP BY fl.Meal_Type
ORDER BY Total_Claims DESC;
--
-- ## Output Columns:
-- - Meal_Type: Category of the meal.
-- - Total_Claims: Number of claims made for that meal type.
--
-- ## Sample Output:
-- | Meal_Type | Total_Claims |
-- |-----------|--------------|
-- | Breakfast | 278          |
-- | Lunch     | 250          |
-- | Snacks    | 240          |
-- | Dinner    | 232          |
--

-- ## Interpretation:
-- Top meal type shows demand trends.
-- Determines which meal category (e.g., Breakfast, Lunch, Snacks, Dinner) receives the highest number of claims.
-- Useful for understanding user preferences and optimizing meal planning or inventory.
-- ## Notes:
-- - Execution returned 4 rows in 8ms.
-- - No errors encountered.
-- - Ideal for generating query12_meal_type_claims.csv or visualizing meal demand trends.
---------------------------------------------------------
--------------------------------------------------------
-- 13. What is the total quantity of food donated by each provider?
---------------------------------------------------------
-- ## Purpose:
-- Rank providers by total quantity donated.
SELECT 
    p.Name,
    SUM(fl.Quantity) AS Total_Donated
FROM providers p
JOIN food_listings fl ON p.Provider_ID = fl.Provider_ID
GROUP BY p.Name
ORDER BY Total_Donated DESC;

-- ## Output Columns:
-- - Name: Name of the food provider.
-- - Total_Donated: Sum of all food quantities donated by the provider.
--
-- ## Sample Output:
-- | Name                        | Total_Donated |
-- |-----------------------------|---------------|
-- | Miller Inc                  | 217           |
-- | Barry Group                 | 179           |
-- | Evans, Wright and Mitchell | 158           |
-- | Smith Group                 | 150           |
-- | Campbell LLC                | 145           |
-- | Nelson LLC                  | 142           |
--
---- ## Interpretation:
-- Identifies the biggest contributors.
-- Calculates and ranks providers based on the total quantity of food they have donated.
-- Helps identify top contributors and assess donation distribution across providers.
--
-- ## Notes:
-- - Execution returned 628 rows in 7ms.
-- - No errors encountered.
-- - Suitable for generating query13_provider_donations.csv or visualizing donation impact.
---------------------------------------------------------
-- 14. Most demanded food type per city.
---------------------------------------------------------
-- ## Purpose:
-- Discover city-level demand preferences.
SELECT 
    fl.Location,
    fl.Food_Type,
    COUNT(c.Claim_ID) AS Claims_Count
FROM food_listings fl
JOIN claims c ON fl.Food_ID = c.Food_ID
GROUP BY fl.Location, fl.Food_Type
ORDER BY fl.Location, Claims_Count DESC;
-- ## Output Columns:
-- - Location: Geographic area where the claim was made.
-- - Food_Type: Category of food (e.g., Vegetarian, Non-Vegetarian, Vegan).
-- - Claims_Count: Number of claims for that food type in the given location.
--
-- ## Sample Output:
-- | Location         | Food_Type       | Claims_Count |
-- |------------------|------------------|--------------|
-- | Adambury         | Non-Vegetarian   | 3            |
-- | Alexanderchester | Vegetarian       | 2            |
-- | Allenborough     | Vegan            | 1            |
-- | Allenton         | Vegetarian       | 2            |
-- | Allenton         | Vegan            | 1            |
-- | Allenton         | Non-Vegetarian   | 1            |
--

-- ## Interpretation:
-- Within each city, the highest count per food type indicates top demand.
-- Analyzes the distribution of food claims across different locations and food types.
-- Useful for identifying regional preferences and tailoring food offerings accordingly.
--
-- ## Notes:
-- - Execution returned 584 rows in 11ms.
-- - No errors encountered.
-- - Ideal for generating query14_location_foodtype_claims.csv or mapping food demand by region.

---------------------------------------------------------
-- 15. Month with highest number of claims.
---------------------------------------------------------
-- ## Purpose:
-- Find the time period with peak demand.
SELECT 
    strftime('%Y-%m', Clean_Timestamp) AS Claim_Month,
    COUNT(*) AS Total_Claims
FROM claims
WHERE Clean_Timestamp IS NOT NULL
GROUP BY Claim_Month
ORDER BY Total_Claims DESC
LIMIT 1;

-- ## Purpose:
-- Identify the month with the highest volume of claims to understand peak demand periods.
-- This can inform resource allocation, staffing, or deeper analysis into claim drivers.

-- ## Query Breakdown:
-- 1. strftime('%Y-%m', Clean_Timestamp): Extracts the year and month from the cleaned timestamp.
-- 2. COUNT(*): Counts the total number of claims for each month.
-- 3. WHERE Clean_Timestamp IS NOT NULL: Ensures only valid timestamps are considered.
-- 4. GROUP BY Claim_Month: Aggregates claims by month.
-- 5. ORDER BY Total_Claims DESC: Sorts months by claim volume, highest first.
-- 6. LIMIT 1: Returns only the top month with the most claims.

-- ## Interpretation:
-- The result shows that March 2025 had the highest number of claims, totaling 1000.
-- This indicates a significant spike in activity during that month.

-- ## Investigative Note:
-- A sudden surge like this could be an outlier or signal a meaningful event:
-- - Was there a policy change, seasonal factor, or external incident?
-- - Is this spike consistent with historical trends or an anomaly?
-- - Consider comparing with adjacent months or previous years to assess context.
-- - Drill down into claim types, locations, or timestamps to uncover patterns.

-- ## Next Steps:
-- You may want to:
-- - Visualize monthly trends to spot other peaks or troughs.
-- - Run anomaly detection or calculate z-scores for monthly volumes.
-- - Segment claims by category or region for deeper insights.

-- ============================================================================
-- ============================================================================
-- 📌 Outlier Detection Across All Months
-- ============================================================================

WITH Monthly_Claims AS (
    SELECT 
        strftime('%Y-%m', Clean_Timestamp) AS Claim_Month,
        COUNT(*) AS Total_Claims
    FROM claims
    WHERE Clean_Timestamp IS NOT NULL
    GROUP BY Claim_Month
    ORDER BY Claim_Month
),
Mean_Calc AS (
    SELECT 
        AVG(Total_Claims) AS Mean_Claims
    FROM Monthly_Claims
),
Variance_Calc AS (
    SELECT 
        mc.Claim_Month,
        mc.Total_Claims,
        m.Mean_Claims,
        (mc.Total_Claims - m.Mean_Claims) * (mc.Total_Claims - m.Mean_Claims) AS Squared_Diff
    FROM Monthly_Claims mc
    CROSS JOIN Mean_Calc m
),
Std_Dev_Calc AS (
    SELECT 
        AVG(Squared_Diff) AS Variance,
        m.Mean_Claims
    FROM Variance_Calc
    CROSS JOIN Mean_Calc m
)
SELECT 
    mc.Claim_Month,
    mc.Total_Claims,
    ROUND((mc.Total_Claims - s.Mean_Claims) / SQRT(s.Variance), 2) AS Z_Score
FROM Monthly_Claims mc
CROSS JOIN Std_Dev_Calc s
ORDER BY Z_Score DESC;

-- ============================================================================
-- ✅ Interpretation:
-- Z-score > 2 → Month is significantly above average (likely outlier)
-- Z-score < -2 → Month is significantly below average
-- ============================================================================
-- ============================================================================
-- 📌 Data Coverage Limitation – March 2025 Only
-- ============================================================================
-- Observation:
--   The claims dataset contains records exclusively from March 2025.
--
-- Impact:
--   - Monthly outlier detection is not meaningful, as there is only one month.
--   - Z-score calculations across months are invalid due to the lack of comparative periods.
--
-- Recommended Action:
--   - Document March 2025 as the sole available month in this dataset.
--   - If required, perform daily outlier detection within March 2025 to identify intra-month spikes.
--   - For robust trend or anomaly analysis, obtain a dataset spanning multiple months or years.
--
-- Decision:
--   For this project, we will treat March 2025 as the baseline month and skip monthly outlier detection.
-- ============================================================================
-- Note: All claim records are from March 2025; monthly outlier detection not applicable.

-- 📌 Phase 4: Data Export for Streamlit
-- ============================================================================
-- Purpose:
--   Prepare query outputs as CSV files for use in the Streamlit application.
--   These files provide the underlying datasets for interactive dashboards,
--   KPI cards, and charts.
--
-- Exported Query Results:
--
--   A) Large Tables for Interactive Views:
--   1. query01_city_provider_receiver_counts.csv
--        - City-wise counts of providers and receivers
--        - Used for: City-level maps, bar charts, and coverage analysis
--
--   2. query03_all_provider_contacts.csv
--        - Full provider directory with Name, Contact, Address, and City
--        - Used for: Searchable contact list and city-based filtering
--
--   3. query08_food_claims_by_item.csv
--        - Food items with total number of claims
--        - Used for: Ranking tables and bar charts of most demanded items
--
--   4. query11_avg_claim_quantity.csv
--        - Receiver-wise average claim quantity
--        - Used for: Leaderboards of bulk receivers vs. small receivers
--
--   5. query13_quantity_donated_per_provider.csv
--        - Provider-wise total quantity donated
--        - Used for: Top donor charts and recognition tables
--
--   6. query14_most_demanded_food_type_per_city.csv
--        - City-wise most demanded food type and claim counts
--        - Used for: Regional demand analysis and heatmaps
--
--   B) KPI / Small Summary Tables:
--   7. query02_to_contributing_provider_type.csv
--        - Provider type with total contribution quantity
--        - Used for: KPI card or small bar chart
--
--   8. query07_most_common_food_types.csv
--        - Food type distribution by listing count
--        - Used for: Pie chart or donut chart in dashboard
--
--   9. query10_claim_status_percentages.csv
--        - Completed vs Pending vs Cancelled claims
--        - Used for: Status KPI cards and claim lifecycle visuals
--
--   10. query12_most_claimed_meal_type.csv
--        - Meal type with the most claims
--        - Used for: KPI card or small bar chart
--
-- Export Location:
--   All CSVs stored in /results directory for easy import into Streamlit.
--   File naming follows the pattern: queryXX_short_description.csv
--
-- Notes:
--   - Each file directly maps to a visual in the Streamlit app.
--   - Smaller KPI tables are exported to avoid recomputation in Streamlit.
-- ============================================================================
-- 📌 Phase 5: Streamlit App Overview & Data-to-Visual Mapping
-- ============================================================================
-- Purpose:
--   Define how each exported CSV from Phase 4 will be integrated into the
--   Streamlit application, including its intended visualizations and user interactions.
--
-- App Sections & Data Sources:
--
-- 1. City Coverage & Network Analysis
--    Data: query01_city_provider_receiver_counts.csv
--    Visuals:
--       - Interactive map showing provider/receiver distribution per city
--       - Horizontal bar chart comparing providers vs. receivers
--    User Interaction:
--       - City dropdown filter
--       - Hover tooltips with counts
--
-- 2. Provider Directory
--    Data: query03_all_provider_contacts.csv
--    Visuals:
--       - Searchable, paginated table of provider contacts
--       - Filter by city
--    User Interaction:
--       - Search bar (name, contact, city)
--       - City filter dropdown
--
-- 3. Demand by Food Item
--    Data: query08_food_claims_by_item.csv
--    Visuals:
--       - Ranked bar chart of most claimed food items
--       - Option to sort ascending/descending
--    User Interaction:
--       - Filter by item name search
--       - Sort toggle
--
-- 4. Receiver Claim Size Analysis
--    Data: query11_avg_claim_quantity.csv
--    Visuals:
--       - Leaderboard table of receivers by average claim size
--       - Histogram showing distribution of average quantities
--    User Interaction:
--       - Top N slider
--       - Receiver name search
--
-- 5. Provider Contribution Ranking
--    Data: query13_quantity_donated_per_provider.csv
--    Visuals:
--       - Bar chart ranking providers by total donated quantity
--       - Downloadable table
--    User Interaction:
--       - Search by provider name
--       - Sort ascending/descending
--
-- 6. Regional Demand Heatmap
--    Data: query14_most_demanded_food_type_per_city.csv
--    Visuals:
--       - Heatmap of demand by city & food type
--       - Grouped bar chart for selected city
--    User Interaction:
--       - City selector
--       - Food type filter
--
-- 7. KPI Cards
--    Data:
--       - query02_top_contributing_provider_type.csv → "Top Provider Type" KPI
--       - query07_most_common_food_types.csv → "Most Common Food Type" KPI
--       - query10_claim_status_percentages.csv → "Claim Status Breakdown" donut chart
--       - query12_most_claimed_meal_type.csv → "Most Claimed Meal Type" KPI
--    Visuals:
--       - KPI number cards
--       - Donut/pie chart for status
--    User Interaction:
--       - Status filter toggle
--
-- Integration Notes:
--   - All CSVs are loaded using pandas.read_csv() in Streamlit.
--   - App will use sidebar filters (city, provider type, food type) to filter datasets.
--   - KPI metrics are computed once in SQL to improve performance.
--   - All visuals will have export buttons (CSV/Excel).
-- ============================================================================
-- 📌 Phase 6: Final Documentation Wrap-Up
-- ============================================================================
-- Project: Local Food Wastage Management System
-- Author: Shruti Sumadhur Ghosh
-- Date: 2025-08-12
--
-- ✅ Phase 1 – Data Loading & Schema Review
--    - Loaded all source CSVs into SQLite database (food_wastage.db).
--    - Verified schema integrity and applied necessary data type corrections.
--
-- ✅ Phase 2 – Data Cleaning & Preparation
--    - Standardized city names, provider types, and timestamps.
--    - Created Clean_Timestamp column for date-based analysis.
--    - Ensured referential integrity between providers, receivers, listings, and claims.
--
-- ✅ Phase 3 – Business Question Analysis
--    - Wrote and executed 15 SQL queries to answer key operational questions.
--    - Added detailed comments for purpose, query logic, and interpretation.
--    - Performed outlier check; documented limitation of single-month data (March 2025 only).
--
-- ✅ Phase 4 – Data Export for Visualization
--    - Identified queries with large/multi-dimensional outputs suitable for visual exploration.
--    - Exported CSVs for:
--         query01_city_provider_receiver_counts.csv
--         query03_all_provider_contacts.csv
--         query08_food_claims_by_item.csv
--         query11_avg_claim_quantity.csv
--         query13_quantity_donated_per_provider.csv
--         query14_most_demanded_food_type_per_city.csv
--    - Also exported smaller KPI datasets for key stats.
--
-- ✅ Phase 5 – Streamlit App Data Mapping
--    - Documented exactly how each exported CSV will be used in the app:
--         - Maps, charts, tables, KPI cards, and filters.
--    - Mapped each dataset to specific user interactions (dropdowns, search, sort, download).
--    - Ensured performance by pre-aggregating data in SQL before export.
--
-- 📌 Next Steps – Deployment & Testing
--    1. Develop Streamlit app using exported CSVs.
--    2. Implement all documented visuals, filters, and KPIs.
--    3. Conduct functional testing with sample user flows.
--    4. Deploy Streamlit app to Streamlit Cloud or internal server.
--    5. Prepare project report & demo video for submission.
--
-- Final Note:
--    This SQL script, along with exported CSVs, forms the complete data foundation
--    for the Streamlit application. All business questions are answered and
--    visual-ready datasets are prepared. The project is now ready for the
--    visualization and deployment phase.
-- ============================================================================
