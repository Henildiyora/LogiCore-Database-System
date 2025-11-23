# LogiCore: Supply Chain Management Database

**LogiCore** is a centralized relational database system designed to optimize U.S. logistics operations. It unifies data fragmentation across customers, inventory, orders, suppliers, and shipments into a single, **BCNF-normalized PostgreSQL schema**. This project demonstrates enterprise-level database administration techniques, including ACID-compliant transactions, advanced PL/pgSQL triggers, and strategic query optimization.

## Project Features

### 1. **Data Integrity & Logic**
* **ACID Compliance:** Implements complex transactions to ensure data consistency (e.g., Atomic inventory deduction).

* **Advanced Triggers:** 
    * **Inventory Validation:** Prevents shipping orders if physical stock is insufficient (`BEFORE UPDATE` trigger).
    * **Price Protection:** Enforces business rules preventing illegal price drops on active or sold products.

* **Stored Procedures:** Encapsulates common logic like `RestockInventory` and `UpdateOrderStatus` for standardized operations.

### 2. **Performance Optimization**
* **Indexing Strategies:** Utilizes **B-Tree** and **Bitmap** indexes to optimize high-cost queries.

* **Execution Plan Analysis:** Achieved **90%+ cost reduction** on critical queries (e.g., Full Order Trace, Customer Search) by moving from Sequential Scans to Index Scans.

* **Scalability:** Designed and tested with a dataset of **10,000+ records** to simulate real-world production loads.

### 3. **Analytics & Business Intelligence**
* **Complex Reporting:** Includes SQL scripts for identifying VIP customers, tracking carrier reliability scores, and flagging low-inventory items.

* **Visualization:** Integrated with **Tableau Public** to provide a real-time dashboard for warehouse capacity, sales trends, and shipping metrics.


## Repository Structure

```text
LogiCore/
│
├── sql/                       # Source code for database logic
│   ├── 01_schema/             # DDL scripts (CREATE TABLE, Constraints)
│   ├── 02_procedures/         # Stored Procedures (Restock, Status Updates)
│   ├── 03_triggers/           # PL/pgSQL Triggers (Inventory Check, Price Logic)
│   ├── 04_queries/            # CRUD and Analytical Select Queries
│   └── 05_optimization/       # EXPLAIN ANALYZE scripts (Before/After Indexing)
│
├── docs/                      # Documentation and Reports
│   ├── ER_Diagram.png         # Visual Schema Representation
│   ├── Phase1_Report.pdf      # Initial Design Document
│   └── Phase2_Report.pdf      # Final Implementation & Optimization Report
│
└── README.md                  # Project Documentation
```

### Technology Stack
* **Database Engine:** PostgreSQL 15+
* **Query Language:** SQL, PL/pgSQL
* **Data Generation:** Python (Faker Library)
* **Visualization:** Tableau Public
* **Tools:** VS Code, pgAdmin 4

### Key Performance Optimizations
We acted as Database Administrators to identify bottlenecks using `EXPLAIN ANALYZE`.

| Query Case          | Initial Method (Problem) | Optimization (Solution)        | Result                      |
|---------------------|--------------------------|--------------------------------|-----------------------------|
| Full Order Trace    | Sequential Scan          | Index on Shipments(order_id)   | Index Scan (Instant retrieval)|
| Customer Search     | Sequential Scan          | Index on Customers(name)       | Bitmap Index Scan           |
| Inventory Join      | Full Table Scan          | Index on Inventory(product_id) | Optimized Join Strategy     |


### How to Run
1. **Clone the repository:**

   ```bash
   git clone https://github.com/Henildiyora/LogiCore.git
   ```
2. **Setup Database:**

   * Run `sql/01_schema/create_tables.sql` to build the 12-table schema.
   * Import data using your preferred method (or the scripts in `01_schema`).

3. **Deploy Logic:**

   * Execute scripts in `sql/02_procedures/` and `sql/03_triggers/` to install the business logic.

4. **Test:**

   * Run queries in `sql/04_queries/` to verify data retrieval.
   * Run optimization tests in `sql/05_optimization/` to see performance gains.