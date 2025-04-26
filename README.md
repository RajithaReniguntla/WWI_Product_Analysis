# Worldwide Importers - A Product Analysis

This project performs an in-depth Exploratory Data Analysis (EDA) of the **Products** domain within the Worldwide Importers database.  

My primary goal was to **decode sales and profitability trends**, assess **supplier effectiveness**, and uncover **strategic purchasing patterns** from 2013 to 2015 — supporting smarter, data-driven **supply chain decisions**. I have provided insights to support inventory planning, supplier negotiations, and procurement strategy in a real-world context.


---

## Project Structure

I've broken down the analysis into two critical point of view: products and suppliers, looking at sales trends and supplier performance trends respectively. 

- **Sales and Profitability Trends (2013–2015)**  
  - Analyze year-over-year shifts in **sales volume**, **revenue**, and **profitability** of stock items.
  - Identify **high-growth** and **declining** product categories based on financial performance.

- **Supplier Performance Analysis**  
  - Track **supplier dependency** through order counts and order quantities.
  - Evaluate **suppliers** financial contribution to the company's bottom line through profit margin.
---

## Key Insights

- **Profitability Uptrend**:  
  Most stock items showed **positive profit growth** year-over-year, despite sales volume fluctuations.
  
- **SKU-Level/Product Category Level Planning Needed**:  
  Many SKUs have a hike and a dip in growth, suggesting a seasonal trend - understanding **seasonal fluctuations** can help plan inventory and maintain stock levels (or adjust re-order points and target stock levels) to better align with the changing customer demand. 

- **Supplier Dependence Risks**:  
  A small group of suppliers provided the majority of unique stock items, highlighting **supply chain concentration risks**.

- **Strategic Procurement Opportunities**:  
  Suppliers with steady year-on-year growth in order quantities can be prioritized for **long-term contracts** to stabilize supply lines. Strengthen partnership with suppliers of high-margin products.

---

## SQL Methods Used

- Complex Joins: `INNER JOIN`, `LEFT JOIN`
- Aggregations and Conditional Aggregations (`GROUP BY`, `CASE WHEN`)
- Time-Series Growth Calculations
- Data Validation using Cross-Checks and Summary Aggregations
- Trend Analysis with Logical Data Partitioning (by Year)

---

## Database Tables Referenced

- `Sales.Invoices`
- `Sales.InvoiceLines`
- `Warehouse.StockItems`
- `Warehouse.StockItemStockGroups`
- `Purchasing.PurchaseOrders`
- `Purchasing.PurchaseOrderLines`
- `Purchasing.Suppliers`

---


