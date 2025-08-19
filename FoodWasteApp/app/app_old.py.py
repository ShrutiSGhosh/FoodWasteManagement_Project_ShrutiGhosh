import streamlit as st
import pandas as pd
import plotly.express as px
import os

# ---------------------------
# CONFIG / PATHS
# ---------------------------
DATA_PATH = r"D:\DA Projects\Food Waste Management\FoodWasteApp\data"
LOGO_PATH = os.path.join(DATA_PATH, "logo.png")

st.set_page_config(layout="wide", page_title="Food Waste Dashboard")

# ---------------------------
# FILE NAMES (cleaned CSVs)
# ---------------------------
FILES = {
    "q01": "query01_city_provider_receiver_counts_cleaned.csv",
    "q02": "query02_To_contributing_provider_type_cleaned.csv",
    "q03": "query03_all_provider_contacts_cleaned.csv",
    "q04": "query04_receivers_with_most_claims_cleaned.csv",
    "q05": "query05_total_food_quantity_cleaned.csv",
    "q06": "query06_city_with_highest_listings_cleaned.csv",
    "q07": "query07_Most_common_food_types_cleaned.csv",
    "q08": "query08_food_claims_by_item_cleaned.csv",
    "q09": "query09_provider_with_highest_successful_claims_cleaned.csv",
    "q10": "query10_Claim_status_percentages_cleaned.csv",
    "q11": "query11_avg_claim_quantity_cleaned.csv",
    "q12": "query12_Most_claimed_meal_type_cleaned.csv",
    "q13": "query13_quantity_donated_per_provider_cleaned.csv",
    "q14": "query14_most_demanded_food_type_per_city_cleaned.csv",
    "q15": "query15_peak_claim_month_cleaned.csv",
}

# ---------------------------
# LOAD CSVS (safe)
# ---------------------------
@st.cache_data
def load_csv(path):
    try:
        return pd.read_csv(path)
    except Exception:
        return pd.DataFrame()

dfs = {}
for k, fname in FILES.items():
    path = os.path.join(DATA_PATH, fname)
    dfs[k] = load_csv(path)

# ---------------------------
# QUERY TITLES & QUESTIONS
# ---------------------------
QUERY_TITLES = {
    "q01": "Cities with Provider & Receiver Counts",
    "q02": "Top Contributing Provider Types",
    "q03": "All Provider Contact Details",
    "q04": "Receivers with Most Claims",
    "q05": "Total Food Quantity Donated",
    "q06": "City with Highest Listings",
    "q07": "Most Common Food Types",
    "q08": "Food Claims by Item",
    "q09": "Provider with Highest Successful Claims",
    "q10": "Claim Status Percentages",
    "q11": "Average Claim Quantity per Claim",
    "q12": "Most Claimed Meal Type",
    "q13": "Quantity Donated per Provider",
    "q14": "Most Demanded Food Type per City",
    "q15": "Peak Claim Month",
}

QUERY_QUESTIONS = {
    "q01": "Which cities have the most providers and receivers (counts)?",
    "q02": "Which provider types contribute the most quantity?",
    "q03": "List all provider contact details.",
    "q04": "Which receivers have the most claims?",
    "q05": "What is the total food quantity donated (overall / by filter)?",
    "q06": "Which city has the highest number of listings?",
    "q07": "Which food types are most common?",
    "q08": "Which food items receive the most claims?",
    "q09": "Which provider has the highest number of successful claims?",
    "q10": "What are the percentages of claim statuses (Cancelled, Completed, etc.)?",
    "q11": "What is the average claim quantity per claimant?",
    "q12": "Which meal types (Breakfast/Lunch/Dinner) are claimed most often?",
    "q13": "How much quantity does each provider donate?",
    "q14": "Which food types are most demanded in each city?",
    "q15": "Which month(s) have peak claims?",
}

# ---------------------------
# HELPERS
# ---------------------------
def kpi_card(label, value, color="#2ecc71"):
    st.markdown(
        f"""
        <div style="padding:14px;border-radius:8px;background-color:{color};text-align:center">
            <h5 style="color:white;margin:0;">{label}</h5>
            <h2 style="color:white;margin:0;">{value}</h2>
        </div>
        """,
        unsafe_allow_html=True,
    )

def download_button(df, filename):
    if df is None or df.empty:
        st.info("No data to download.")
        return
    csv = df.to_csv(index=False).encode("utf-8")
    st.download_button("📥 Download CSV", csv, file_name=filename, mime="text/csv")

def collect_unique_values(cols_list):
    s = set()
    for df in dfs.values():
        if df is None or df.empty:
            continue
        for c in cols_list:
            if c in df.columns:
                s.update(df[c].dropna().astype(str).unique())
    return sorted(s)

# ---------------------------
# SIDEBAR - Global Filters
# ---------------------------
if os.path.exists(LOGO_PATH):
    try:
        st.sidebar.image(LOGO_PATH, use_container_width=True)
    except Exception:
        pass

st.sidebar.header("🔍 Global Filters")
all_cities = collect_unique_values(["Location", "City", "location", "city"])
all_providers = collect_unique_values(["Name", "Provider", "name", "provider"])
all_foods = collect_unique_values(["Food_Type", "Food_Name", "FoodType", "food_name", "food_type"])

selected_city = st.sidebar.selectbox("City", ["All"] + all_cities, index=0)
selected_provider = st.sidebar.selectbox("Provider", ["All"] + all_providers, index=0)
selected_food = st.sidebar.selectbox("Food Type", ["All"] + all_foods, index=0)
st.sidebar.caption("Global filters apply across Overview, EDA, Predictions, and Claims.")

st.sidebar.markdown("---")
page = st.sidebar.radio(
    "Navigation",
    ["Overview", "EDA (All Queries)", "Claims", "Predictions", "CRUD (Demo)", "About"]
)

# ---------------------------
# Filter apply function (global)
# ---------------------------
def apply_filters(df):
    if df is None or df.empty:
        return df
    out = df.copy()
    if selected_city and selected_city != "All":
        for col in ["Location", "City", "location", "city"]:
            if col in out.columns:
                out = out[out[col].astype(str) == selected_city]
                break
    if selected_provider and selected_provider != "All":
        for col in ["Name", "Provider", "name", "provider"]:
            if col in out.columns:
                out = out[out[col].astype(str) == selected_provider]
                break
    if selected_food and selected_food != "All":
        for col in ["Food_Type", "Food_Name", "FoodType", "food_name", "food_type"]:
            if col in out.columns:
                out = out[out[col].astype(str) == selected_food]
                break
    return out

# ---------------------------
# Initialize session_state storage for edits (demo only)
# ---------------------------
if "edited" not in st.session_state:
    st.session_state["edited"] = {}  # store edited DataFrames per query key

# ---------------------------
# OVERVIEW
# ---------------------------
if page == "Overview":
    st.title("🌍 Food Waste Dashboard — Overview (Hybrid filters)")
    st.markdown("Global filters are applied from the left sidebar. Local controls are available on specific charts.")

    # KPIs - respect global filters
    col1, col2, col3 = st.columns(3)

    # KPI: Total Food Quantity -> q05
    total_q = "N/A"
    if not dfs["q05"].empty:
        df05 = apply_filters(dfs["q05"])
        # try common numeric column names
        qty_cols = [c for c in df05.columns if "quantity" in c.lower() or "total_food" in c.lower() or "total" in c.lower()]
        if qty_cols:
            try:
                total_q = int(df05[qty_cols[0]].sum())
            except Exception:
                total_q = df05[qty_cols[0]].sum()
    with col1:
        kpi_card("Total Food Quantity", total_q, "#1abc9c")

    # KPI: Top City (q06)
    top_city = "N/A"
    if not dfs["q06"].empty:
        df06 = apply_filters(dfs["q06"])
        for c in ["Location", "City", "location", "city"]:
            if c in df06.columns and not df06[c].dropna().empty:
                top_city = df06.iloc[0][c]
                break
    with col2:
        kpi_card("Top City (Listings)", top_city, "#f39c12")

    # KPI: Top Provider (q09 or q13)
    top_provider = "N/A"
    if not dfs["q09"].empty:
        df09 = apply_filters(dfs["q09"])
        for c in ["Name", "Provider", "name", "provider"]:
            if c in df09.columns and not df09[c].dropna().empty:
                top_provider = df09.iloc[0][c]
                break
    elif not dfs["q13"].empty:
        df13 = apply_filters(dfs["q13"])
        for c in ["Name", "Provider", "name", "provider"]:
            if c in df13.columns and not df13[c].dropna().empty:
                top_provider = df13.iloc[0][c]
                break
    with col3:
        kpi_card("Top Provider", top_provider, "#3498db")

    st.markdown("---")
    st.subheader("Provider Type Contribution (sample)")
    if not dfs["q02"].empty:
        df02 = apply_filters(dfs["q02"])
        val_col = next((c for c in df02.columns if "total" in c.lower() or "quantity" in c.lower() or "count" in c.lower()), None)
        name_col = next((c for c in df02.columns if "provider" in c.lower() or "type" in c.lower()), None)
        if val_col and name_col:
            fig = px.pie(df02, values=val_col, names=name_col, title="Provider Type Contribution")
            st.plotly_chart(fig, use_container_width=True)
        else:
            st.info("q02 does not contain expected columns for pie chart; preview below.")
            st.dataframe(df02.head())

# ---------------------------
# EDA (All Queries) - each query editable demo-only
# ---------------------------
elif page == "EDA (All Queries)":
    st.title("📊 Exploratory Data Analysis — All 15 Queries (Editable - demo only)")
    st.write("Each query below shows title + business question. You can edit the table in-session using the editor (changes are not saved to disk). Use global filters to narrow data.")

    for q_key in sorted(FILES.keys()):
        title = QUERY_TITLES.get(q_key, q_key)
        question = QUERY_QUESTIONS.get(q_key, "")
        df_raw = dfs.get(q_key, pd.DataFrame())
        df = apply_filters(df_raw)

        with st.expander(f"{title} — {q_key.upper()}", expanded=False):
            if question:
                st.markdown(f"**Business question:** {question}")
            if df is None or df.empty:
                st.warning("No data available after filters applied.")
                continue

            # Show editable table (demo-only)
            edited = st.data_editor(df, num_rows="dynamic", key=f"editor_{q_key}")
            # store in session to allow cross-page viewing during session
            st.session_state["edited"][q_key] = edited

            st.markdown("**Preview:**")
            st.dataframe(edited.head(200))

            # Quick chart suggestions
            cols = edited.columns.tolist()
            if any("claim" in c.lower() for c in cols) and any("name" in c.lower() or "food" in c.lower() or "location" in c.lower() for c in cols):
                metric_col = next((c for c in cols if "claim" in c.lower()), None)
                label_col = next((c for c in cols if "name" in c.lower() or "food" in c.lower() or "location" in c.lower()), cols[0])
                if metric_col and label_col:
                    try:
                        st.plotly_chart(px.bar(edited.sort_values(metric_col, ascending=False).head(20), x=label_col, y=metric_col), use_container_width=True)
                    except Exception:
                        pass
            elif any("quantity" in c.lower() or "total" in c.lower() for c in cols) and len(cols) >= 2:
                qty_col = next((c for c in cols if "quantity" in c.lower() or "total" in c.lower()), None)
                label_col = cols[0]
                if qty_col:
                    try:
                        st.plotly_chart(px.bar(edited.sort_values(qty_col, ascending=False).head(20), x=label_col, y=qty_col), use_container_width=True)
                    except Exception:
                        pass

            download_button(edited, f"{q_key}_edited.csv")

# ---------------------------
# CLAIMS (focused page with local controls)
# ---------------------------
elif page == "Claims":
    st.title("📦 Claims & Contributions (Local controls + global filters)")

    # Top Receivers (q04) with Top-N local control
    if not dfs["q04"].empty:
        st.subheader("Top Receivers by Claims (q04)")
        df04 = apply_filters(dfs["q04"]).copy()
        if df04.empty:
            st.warning("No q04 data after filters.")
        else:
            # editable demo-only
            edited04 = st.data_editor(df04, num_rows="dynamic", key="claims_q04")
            st.session_state["edited"]["q04"] = edited04

            # local control - top N
            top_n = st.slider("Top N receivers", 3, 50, 10, key="top_receivers")
            claim_col = next((c for c in edited04.columns if "claim" in c.lower()), None)
            name_col = next((c for c in edited04.columns if "name" in c.lower()), edited04.columns[0])
            if claim_col:
                top_df = edited04.nlargest(top_n, claim_col)
                fig = px.bar(top_df, x=name_col, y=claim_col, color=claim_col, title="Top Receivers by Claims")
                st.plotly_chart(fig, use_container_width=True)
            else:
                st.dataframe(edited04)

    # Claims by Food Item (q08) with sort option
    if not dfs["q08"].empty:
        st.subheader("Claims by Food Item (q08)")
        df08 = apply_filters(dfs["q08"]).copy()
        if df08.empty:
            st.warning("No q08 data after filters.")
        else:
            edited08 = st.data_editor(df08, num_rows="dynamic", key="claims_q08")
            st.session_state["edited"]["q08"] = edited08

            sort_opt = st.radio("Sort by:", ["Total Claims", "Total Quantity"], key="sort_claims_by")
            claims_col = next((c for c in edited08.columns if "claim" in c.lower()), None)
            qty_col = next((c for c in edited08.columns if "quantity" in c.lower()), None)
            name_col = next((c for c in edited08.columns if "food" in c.lower()), edited08.columns[0])
            if sort_opt == "Total Claims" and claims_col:
                fig = px.bar(edited08.sort_values(claims_col, ascending=False).head(30), x=name_col, y=claims_col, color=claims_col)
                st.plotly_chart(fig, use_container_width=True)
            elif sort_opt == "Total Quantity" and qty_col:
                fig = px.bar(edited08.sort_values(qty_col, ascending=False).head(30), x=name_col, y=qty_col, color=qty_col)
                st.plotly_chart(fig, use_container_width=True)
            else:
                st.dataframe(edited08)

# ---------------------------
# PREDICTIONS (uses q14)
# ---------------------------
elif page == "Predictions":
    st.title("🔮 Predictions & Demand (Local + Global filters)")

    if dfs["q14"].empty:
        st.info("No q14 demand data available.")
    else:
        df14 = apply_filters(dfs["q14"]).copy()
        if df14.empty:
            st.warning("No q14 rows after filters.")
        else:
            # standardize Food_Type column if needed
            if "Food_Type" not in df14.columns and "FoodType" in df14.columns:
                df14 = df14.rename(columns={"FoodType": "Food_Type"})
            if "Food_Type" not in df14.columns and "Food_Name" in df14.columns:
                df14["Food_Type"] = df14["Food_Name"].astype(str)

            # local city selector (still restricted to already-applied global filter)
            if "Location" in df14.columns:
                cities_local = sorted(df14["Location"].dropna().astype(str).unique())
                city_local = st.selectbox("Local city view (optional)", options=["All"] + cities_local, index=0)
                if city_local != "All":
                    df14 = df14[df14["Location"].astype(str) == city_local]

            count_col = next((c for c in df14.columns if "claim" in c.lower() or "count" in c.lower()), None)
            if count_col and "Food_Type" in df14.columns:
                fig = px.bar(df14.sort_values(count_col, ascending=False).head(30), x="Food_Type", y=count_col, color="Food_Type", title="Most Demanded Food Types")
                st.plotly_chart(fig, use_container_width=True)
            else:
                st.dataframe(df14)

# ---------------------------
# CRUD (Demo page)
# ---------------------------
elif page == "CRUD (Demo)":
    st.title("📝 CRUD — Demo only (session-only edits)")
    st.info("Editing here does NOT save to disk. Use the EDA expanders to edit specific queries. This page provides quick editable access to Providers, Receivers, Listings, Claims tables if present.")

    # show some of the common tables if they exist
    def show_editable(q_key, display_name):
        if dfs[q_key].empty:
            st.info(f"No data for {display_name} ({q_key}).")
            return
        st.subheader(display_name)
        edited = st.data_editor(apply_filters(dfs[q_key]).copy(), num_rows="dynamic", key=f"crud_{q_key}")
        st.session_state["edited"][q_key] = edited
        st.write("Session edits (not saved):")
        st.dataframe(edited.head())

    show_editable("q03", "Provider Contacts (q03)")
    show_editable("q04", "Receivers / Claims (q04)")
    show_editable("q13", "Donations per Provider (q13)")

# ---------------------------
# ABOUT
# ---------------------------
elif page == "About":
    st.title("ℹ️ About — Food Waste Management Dashboard")
    st.markdown("""
    **What this app provides**
    - Loads 15 cleaned query CSVs from your data folder (session-safe).  
    - Global sidebar filters: City, Provider, Food Type (applies across pages).  
    - Hybrid model: global filters + local controls (Top N, sort, local city selector).  
    - All queries are editable in **demo-only** mode using `st.data_editor` — changes remain only for the session and are **not saved to disk**.  
    - Download edited previews (session CSV) if you want to export the session edits locally.
    """)
    st.markdown("**Files loaded from:**")
    st.code(DATA_PATH)
    st.markdown("**Files:**")
    for k, f in FILES.items():
        st.write(f"{k} — {f}")

    st.markdown("---")
    st.markdown("**Status — Done so far**")
    st.write(
        """
        - 15 cleaned CSVs loaded and shown.  
        - Global filters implemented and applied across pages.  
        - KPI cards on Overview respect global filters.  
        - EDA page exposes every query with editable table (demo-only).  
        - Claims and Predictions pages include useful local controls.  
        """
    )
    st.markdown("**To do (future / optional)**")
    st.write(
        """
        - Persist CRUD edits to CSV/SQLite (not implemented — demo only by request).  
        - Add Export All (zip) of all current edited results.  
        - Add authentication and role-based view if required.  
        """
    )
