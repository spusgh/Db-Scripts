
"""
=============================================
Apache Spark Structured Streaming Setup
XYZ_Financials_Securities Migration
=============================================
This file contains PySpark code to create streaming
tables, views, and continuous queries
=============================================
"""

from pyspark.sql import SparkSession
from pyspark.sql.functions import *
from pyspark.sql.types import *
from pyspark.sql.window import Window
import pyspark.sql.streaming as streaming

# =============================================
# PART 1: SPARK SESSION CONFIGURATION
# =============================================

def create_spark_session():
    """Create and configure Spark session with streaming support"""
    spark = SparkSession.builder \
        .appName("XYZ_Financials_Securities_Streaming") \
        .config("spark.sql.streaming.checkpointLocation", "/tmp/spark_checkpoint") \
        .config("spark.sql.shuffle.partitions", "200") \
        .config("spark.sql.adaptive.enabled", "true") \
        .config("spark.sql.adaptive.coalescePartitions.enabled", "true") \
        .config("spark.streaming.kafka.maxRatePerPartition", "1000") \
        .config("spark.sql.streaming.stateStore.providerClass", 
                "org.apache.spark.sql.execution.streaming.state.HDFSBackedStateStoreProvider") \
        .getOrCreate()
    
    spark.sparkContext.setLogLevel("WARN")
    return spark

# =============================================
# PART 2: SCHEMA DEFINITIONS
# =============================================

# Customers Schema
customers_schema = StructType([
    StructField("customer_id", IntegerType(), False),
    StructField("first_name", StringType(), False),
    StructField("last_name", StringType(), False),
    StructField("ssn", StringType(), False),
    StructField("date_of_birth", DateType(), False),
    StructField("email", StringType(), True),
    StructField("phone", StringType(), True),
    StructField("annual_income", DecimalType(15, 2), True),
    StructField("employment_status", StringType(), True),
    StructField("employer", StringType(), True),
    StructField("years_employed", IntegerType(), True),
    StructField("credit_score", IntegerType(), True),
    StructField("created_date", TimestampType(), True),
    StructField("last_updated_date", TimestampType(), True)
])

# Applications Schema
applications_schema = StructType([
    StructField("application_id", IntegerType(), False),
    StructField("customer_id", IntegerType(), False),
    StructField("product_id", IntegerType(), False),
    StructField("officer_id", IntegerType(), False),
    StructField("application_date", TimestampType(), False),
    StructField("loan_amount", DecimalType(15, 2), False),
    StructField("loan_purpose", StringType(), False),
    StructField("status", StringType(), False),
    StructField("closing_date", DateType(), True),
    StructField("application_fee", DecimalType(10, 2), True),
    StructField("dti", DecimalType(5, 2), True),
    StructField("property_value", DecimalType(15, 2), True),
    StructField("ltv", DecimalType(5, 2), True),
    StructField("rate_offered", DecimalType(5, 3), True),
    StructField("term_offered", IntegerType(), True),
    StructField("denial_reason", StringType(), True)
])

# Loans Schema
loans_schema = StructType([
    StructField("loan_id", IntegerType(), False),
    StructField("application_id", IntegerType(), False),
    StructField("customer_id", IntegerType(), False),
    StructField("property_id", IntegerType(), False),
    StructField("product_id", IntegerType(), False),
    StructField("loan_amount", DecimalType(15, 2), False),
    StructField("interest_rate", DecimalType(5, 3), False),
    StructField("term", IntegerType(), False),
    StructField("origination_date", DateType(), False),
    StructField("maturity_date", DateType(), False),
    StructField("monthly_payment", DecimalType(12, 2), False),
    StructField("remaining_balance", DecimalType(15, 2), False),
    StructField("status", StringType(), False),
    StructField("escrow_required", BooleanType(), True),
    StructField("pmi_required", BooleanType(), True),
    StructField("pmi_amount", DecimalType(10, 2), True),
    StructField("first_payment_date", DateType(), False),
    StructField("next_payment_date", DateType(), True),
    StructField("payment_frequency", StringType(), True),
    StructField("security_id", IntegerType(), True),
    StructField("last_updated_date", DateType(), True)
])

# Payments Schema
payments_schema = StructType([
    StructField("payment_id", IntegerType(), False),
    StructField("loan_id", IntegerType(), False),
    StructField("payment_date", TimestampType(), False),
    StructField("payment_amount", DecimalType(12, 2), False),
    StructField("principal_amount", DecimalType(12, 2), False),
    StructField("interest_amount", DecimalType(12, 2), False),
    StructField("escrow_amount", DecimalType(12, 2), True),
    StructField("late_fee_amount", DecimalType(10, 2), True),
    StructField("payment_method", StringType(), True),
    StructField("transaction_id", StringType(), True),
    StructField("payment_status", StringType(), True),
    StructField("processed_date", TimestampType(), True)
])

# Property Details Schema
property_details_schema = StructType([
    StructField("property_id", IntegerType(), False),
    StructField("address_line1", StringType(), False),
    StructField("address_line2", StringType(), True),
    StructField("city", StringType(), False),
    StructField("state", StringType(), False),
    StructField("zip_code", StringType(), False),
    StructField("country", StringType(), True),
    StructField("property_type", StringType(), False),
    StructField("year_built", IntegerType(), True),
    StructField("square_feet", IntegerType(), True),
    StructField("bedrooms", IntegerType(), True),
    StructField("bathrooms", DecimalType(3, 1), True),
    StructField("purchase_price", DecimalType(15, 2), True),
    StructField("current_value", DecimalType(15, 2), True),
    StructField("last_appraisal_date", DateType(), True),
    StructField("last_appraisal_value", DecimalType(15, 2), True),
    StructField("tax_assessment_value", DecimalType(15, 2), True),
    StructField("annual_tax_amount", DecimalType(10, 2), True),
    StructField("hoa_fees", DecimalType(10, 2), True),
    StructField("flood_zone", StringType(), True),
    StructField("property_tax_id", StringType(), True),
    StructField("latitude", DecimalType(9, 6), True),
    StructField("longitude", DecimalType(9, 6), True)
])

# Mortgage Products Schema
mortgage_products_schema = StructType([
    StructField("product_id", IntegerType(), False),
    StructField("product_name", StringType(), False),
    StructField("product_type", StringType(), False),
    StructField("term", IntegerType(), False),
    StructField("base_interest_rate", DecimalType(5, 3), False),
    StructField("min_credit_score", IntegerType(), False),
    StructField("max_ltv", DecimalType(5, 2), False),
    StructField("min_loan_amount", DecimalType(15, 2), False),
    StructField("max_loan_amount", DecimalType(15, 2), False),
    StructField("origination_fee", DecimalType(5, 2), True),
    StructField("is_active", BooleanType(), True)
])

# Escrow Accounts Schema
escrow_accounts_schema = StructType([
    StructField("escrow_id", IntegerType(), False),
    StructField("loan_id", IntegerType(), False),
    StructField("current_balance", DecimalType(12, 2), False),
    StructField("property_tax_amount", DecimalType(12, 2), True),
    StructField("property_insurance_amount", DecimalType(12, 2), True),
    StructField("pmi_amount", DecimalType(12, 2), True),
    StructField("cushion_amount", DecimalType(12, 2), True),
    StructField("last_analysis_date", DateType(), True),
    StructField("next_analysis_date", DateType(), True),
    StructField("monthly_contribution", DecimalType(12, 2), True),
    StructField("shortage_amount", DecimalType(12, 2), True)
])

# Securities Schema
securities_schema = StructType([
    StructField("security_id", IntegerType(), False),
    StructField("security_name", StringType(), False),
    StructField("security_type", StringType(), False),
    StructField("cusip", StringType(), True),
    StructField("issue_date", DateType(), False),
    StructField("maturity_date", DateType(), False),
    StructField("coupon_rate", DecimalType(5, 3), False),
    StructField("face_value", DecimalType(15, 2), False),
    StructField("current_balance", DecimalType(15, 2), False),
    StructField("issuer", StringType(), False),
    StructField("rating", StringType(), True),
    StructField("status", StringType(), True),
    StructField("last_trade_date", DateType(), True),
    StructField("last_trade_price", DecimalType(10, 3), True)
])

# Defaults/Foreclosures Schema
defaults_foreclosures_schema = StructType([
    StructField("default_id", IntegerType(), False),
    StructField("loan_id", IntegerType(), False),
    StructField("default_date", DateType(), False),
    StructField("stage", StringType(), False),
    StructField("reason_code", StringType(), True),
    StructField("resolution_type", StringType(), True),
    StructField("resolution_date", DateType(), True),
    StructField("loss_amount", DecimalType(15, 2), True),
    StructField("collection_agency", StringType(), True),
    StructField("legal_filing_date", DateType(), True),
    StructField("legal_case_number", StringType(), True),
    StructField("notes", StringType(), True)
])

# =============================================
# PART 3: KAFKA SOURCE READERS
# =============================================

def read_kafka_stream(spark, topic, schema, value_only=True):
    """Generic function to read from Kafka topic"""
    kafka_df = spark \
        .readStream \
        .format("kafka") \
        .option("kafka.bootstrap.servers", "localhost:9092") \
        .option("subscribe", topic) \
        .option("startingOffsets", "latest") \
        .option("failOnDataLoss", "false") \
        .load()
    
    if value_only:
        return kafka_df \
            .select(from_json(col("value").cast("string"), schema).alias("data")) \
            .select("data.*")
    else:
        return kafka_df

def setup_streaming_sources(spark):
    """Setup all streaming source tables"""
    
    # Customers Stream
    customers_df = read_kafka_stream(spark, "customers", customers_schema)
    customers_df.createOrReplaceTempView("customers")
    
    # Applications Stream
    applications_df = read_kafka_stream(spark, "loan-applications", applications_schema)
    applications_df.createOrReplaceTempView("applications")
    
    # Loans Stream
    loans_df = read_kafka_stream(spark, "loans", loans_schema)
    loans_df.createOrReplaceTempView("loans")
    
    # Payments Stream
    payments_df = read_kafka_stream(spark, "payments", payments_schema) \
        .withWatermark("payment_date", "10 minutes")
    payments_df.createOrReplaceTempView("payments")
    
    # Property Details Stream
    properties_df = read_kafka_stream(spark, "properties", property_details_schema)
    properties_df.createOrReplaceTempView("property_details")
    
    # Mortgage Products Stream
    products_df = read_kafka_stream(spark, "mortgage-products", mortgage_products_schema)
    products_df.createOrReplaceTempView("mortgage_products")
    
    # Escrow Accounts Stream
    escrow_df = read_kafka_stream(spark, "escrow-accounts", escrow_accounts_schema)
    escrow_df.createOrReplaceTempView("escrow_accounts")
    
    # Securities Stream
    securities_df = read_kafka_stream(spark, "securities", securities_schema)
    securities_df.createOrReplaceTempView("securities")
    
    # Defaults/Foreclosures Stream
    defaults_df = read_kafka_stream(spark, "defaults-foreclosures", defaults_foreclosures_schema)
    defaults_df.createOrReplaceTempView("defaults_foreclosures")
    
    return {
        "customers": customers_df,
        "applications": applications_df,
        "loans": loans_df,
        "payments": payments_df,
        "properties": properties_df,
        "products": products_df,
        "escrow": escrow_df,
        "securities": securities_df,
        "defaults": defaults_df
    }

# =============================================
# PART 4: USER-DEFINED FUNCTIONS
# =============================================

# Function: Calculate Monthly Payment
@udf(returnType=DecimalType(12, 2))
def calculate_monthly_payment(loan_amount, interest_rate, term):
    """Calculate monthly payment using amortization formula"""
    if loan_amount is None or interest_rate is None or term is None:
        return None
    
    monthly_rate = (float(interest_rate) / 100) / 12
    if monthly_rate == 0:
        return float(loan_amount) / term
    
    numerator = float(loan_amount) * monthly_rate * ((1 + monthly_rate) ** term)
    denominator = ((1 + monthly_rate) ** term) - 1
    
    return round(numerator / denominator, 2)

# Function: Calculate LTV
@udf(returnType=DecimalType(5, 2))
def calculate_ltv(loan_amount, property_value):
    """Calculate Loan-to-Value ratio"""
    if property_value is None or property_value == 0:
        return 100.0
    return round((float(loan_amount) / float(property_value)) * 100, 2)

# Function: Calculate DTI
@udf(returnType=DecimalType(5, 2))
def calculate_dti(monthly_debt, annual_income):
    """Calculate Debt-to-Income ratio"""
    if annual_income is None or annual_income == 0:
        return 100.0
    monthly_income = float(annual_income) / 12
    return round((float(monthly_debt) / monthly_income) * 100, 2)

# Function: Is Property in Flood Zone
@udf(returnType=BooleanType())
def is_in_flood_zone(flood_zone):
    """Check if property is in a flood zone"""
    if flood_zone is None:
        return False
    return flood_zone in ['A', 'AE', 'AH', 'AO', 'V', 'VE']

# Function: Calculate Loan Age in Months
@udf(returnType=IntegerType())
def calculate_loan_age_months(origination_date):
    """Calculate loan age in months"""
    if origination_date is None:
        return 0
    from datetime import datetime
    today = datetime.now().date()
    months = (today.year - origination_date.year) * 12 + (today.month - origination_date.month)
    return months

# Register UDFs
def register_udfs(spark):
    """Register all user-defined functions"""
    spark.udf.register("calculate_monthly_payment", calculate_monthly_payment)
    spark.udf.register("calculate_ltv", calculate_ltv)
    spark.udf.register("calculate_dti", calculate_dti)
    spark.udf.register("is_in_flood_zone", is_in_flood_zone)
    spark.udf.register("calculate_loan_age_months", calculate_loan_age_months)

# =============================================
# PART 5: STREAMING VIEWS (SQL Server View Equivalents)
# =============================================

def create_streaming_views(spark):
    """Create streaming views that replicate SQL Server views"""
    
    # View: Loan Portfolio Overview
    spark.sql("""
        CREATE OR REPLACE TEMP VIEW vw_loan_portfolio_overview AS
        SELECT 
            l.loan_id,
            CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
            CONCAT(p.address_line1, ', ', p.city, ', ', p.state, ' ', p.zip_code) AS property_address,
            l.origination_date,
            l.maturity_date,
            l.loan_amount,
            l.remaining_balance,
            l.interest_rate,
            l.monthly_payment,
            l.status,
            mp.product_name,
            mp.product_type,
            s.security_name,
            CASE 
                WHEN l.remaining_balance = 0 THEN 'Paid Off'
                WHEN l.status = 'Active' THEN 'Active'
                ELSE l.status
            END AS current_status
        FROM loans l
        INNER JOIN customers c ON l.customer_id = c.customer_id
        INNER JOIN property_details p ON l.property_id = p.property_id
        INNER JOIN mortgage_products mp ON l.product_id = mp.product_id
        LEFT JOIN securities s ON l.security_id = s.security_id
    """)
    
    # View: Delinquent Loans
    spark.sql("""
        CREATE OR REPLACE TEMP VIEW vw_delinquent_loans AS
        SELECT 
            l.loan_id,
            CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
            c.phone,
            c.email,
            CONCAT(p.address_line1, ', ', p.city, ', ', p.state, ' ', p.zip_code) AS property_address,
            l.origination_date,
            l.remaining_balance,
            l.monthly_payment,
            l.next_payment_date,
            DATEDIFF(CURRENT_DATE(), l.next_payment_date) AS days_past_due,
            CASE 
                WHEN DATEDIFF(CURRENT_DATE(), l.next_payment_date) BETWEEN 1 AND 30 THEN '1-30 Days'
                WHEN DATEDIFF(CURRENT_DATE(), l.next_payment_date) BETWEEN 31 AND 60 THEN '31-60 Days'
                WHEN DATEDIFF(CURRENT_DATE(), l.next_payment_date) BETWEEN 61 AND 90 THEN '61-90 Days'
                WHEN DATEDIFF(CURRENT_DATE(), l.next_payment_date) > 90 THEN '90+ Days'
                ELSE 'Current'
            END AS delinquency_bucket
        FROM loans l
        INNER JOIN customers c ON l.customer_id = c.customer_id
        INNER JOIN property_details p ON l.property_id = p.property_id
        WHERE l.next_payment_date < CURRENT_DATE() 
          AND l.status = 'Active'
    """)
    
    # View: Customer Portfolio
    spark.sql("""
        CREATE OR REPLACE TEMP VIEW vw_customer_portfolio AS
        SELECT 
            c.customer_id,
            CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
            c.email,
            c.phone,
            c.credit_score,
            COUNT(l.loan_id) AS active_loan_count,
            SUM(l.loan_amount) AS total_loan_amount,
            SUM(l.remaining_balance) AS total_remaining_balance,
            MAX(l.origination_date) AS most_recent_loan_date
        FROM customers c
        LEFT JOIN loans l ON c.customer_id = l.customer_id AND l.status = 'Active'
        GROUP BY c.customer_id, c.first_name, c.last_name, c.email, c.phone, c.credit_score
    """)
    
    # View: Escrow Analysis
    spark.sql("""
        CREATE OR REPLACE TEMP VIEW vw_escrow_analysis AS
        SELECT 
            e.escrow_id,
            l.loan_id,
            CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
            CONCAT(p.address_line1, ', ', p.city, ', ', p.state, ' ', p.zip_code) AS property_address,
            e.current_balance,
            e.property_tax_amount,
            e.property_insurance_amount,
            e.pmi_amount,
            e.monthly_contribution,
            e.last_analysis_date,
            e.next_analysis_date,
            e.shortage_amount,
            e.cushion_amount,
            p.annual_tax_amount
        FROM escrow_accounts e
        INNER JOIN loans l ON e.loan_id = l.loan_id
        INNER JOIN customers c ON l.customer_id = c.customer_id
        INNER JOIN property_details p ON l.property_id = p.property_id
    """)

# =============================================
# PART 6: CONTINUOUS QUERIES
# =============================================

def create_delinquency_alert_stream(spark):
    """Generate real-time delinquency alerts"""
    
    delinquency_query = spark.sql("""
        SELECT 
            l.loan_id,
            l.customer_id,
            DATEDIFF(CURRENT_DATE(), l.next_payment_date) AS days_past_due,
            CASE 
                WHEN DATEDIFF(CURRENT_DATE(), l.next_payment_date) > 90 THEN '90+ Days'
                WHEN DATEDIFF(CURRENT_DATE(), l.next_payment_date) > 60 THEN '61-90 Days'
                WHEN DATEDIFF(CURRENT_DATE(), l.next_payment_date) > 30 THEN '31-60 Days'
                ELSE '1-30 Days'
            END AS delinquency_bucket,
            CURRENT_TIMESTAMP() AS alert_timestamp,
            l.remaining_balance AS outstanding_balance,
            CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
            CONCAT(p.address_line1, ', ', p.city, ', ', p.state) AS property_address
        FROM loans l
        INNER JOIN customers c ON l.customer_id = c.customer_id
        INNER JOIN property_details p ON l.property_id = p.property_id
        WHERE l.next_payment_date < CURRENT_DATE() 
          AND l.status = 'Active'
          AND DATEDIFF(CURRENT_DATE(), l.next_payment_date) > 0
    """)
    
    # Write to Kafka
    query = delinquency_query \
        .selectExpr("to_json(struct(*)) AS value") \
        .writeStream \
        .format("kafka") \
        .option("kafka.bootstrap.servers", "localhost:9092") \
        .option("topic", "delinquency-alerts") \
        .option("checkpointLocation", "/tmp/spark_checkpoint/delinquency_alerts") \
        .outputMode("append") \
        .start()
    
    return query

def create_payment_metrics_stream(spark):
    """Calculate loan payment metrics with tumbling windows"""
    
    payment_metrics = spark.sql("""
        SELECT 
            loan_id,
            window(payment_date, '1 day') AS window,
            COUNT(*) AS payment_count,
            SUM(principal_amount) AS total_principal_paid,
            SUM(interest_amount) AS total_interest_paid,
            SUM(payment_amount) AS total_amount_paid
        FROM payments
        WHERE payment_status = 'Processed'
        GROUP BY loan_id, window(payment_date, '1 day')
    """)
    
    # Flatten window struct
    payment_metrics_flat = payment_metrics \
        .select(
            col("loan_id"),
            col("window.start").alias("window_start"),
            col("window.end").alias("window_end"),
            col("payment_count"),
            col("total_principal_paid"),
            col("total_interest_paid"),
            col("total_amount_paid")
        )
    
    # Write to Kafka
    query = payment_metrics_flat \
        .selectExpr("to_json(struct(*)) AS value") \
        .writeStream \
        .format("kafka") \
        .option("kafka.bootstrap.servers", "localhost:9092") \
        .option("topic", "loan-payment-metrics") \
        .option("checkpointLocation", "/tmp/spark_checkpoint/payment_metrics") \
        .outputMode("update") \
        .start()
    
    return query

def create_portfolio_metrics_stream(spark):
    """Calculate portfolio-level metrics"""
    
    portfolio_metrics = spark.sql("""
        SELECT 
            window(CURRENT_TIMESTAMP(), '1 hour') AS window,
            COUNT(DISTINCT loan_id) AS total_active_loans,
            SUM(loan_amount) AS total_loan_amount,
            SUM(remaining_balance) AS total_outstanding_balance,
            AVG(interest_rate) AS average_interest_rate
        FROM loans
        WHERE status = 'Active'
        GROUP BY window(CURRENT_TIMESTAMP(), '1 hour')
    """)
    
    # Write to Delta Lake for historical analysis
    query = portfolio_metrics \
        .writeStream \
        .format("delta") \
        .option("path", "/data/portfolio_metrics") \
        .option("checkpointLocation", "/tmp/spark_checkpoint/portfolio_metrics") \
        .outputMode("append") \
        .start()
    
    return query

# =============================================
# PART 7: BATCH PROCESSING FUNCTIONS
# =============================================

def calculate_amortization_schedule(spark, loan_id):
    """Calculate complete amortization schedule for a loan (batch)"""
    
    # Read loan details from JDBC (or Kafka snapshot)
    loan_df = spark.read \
        .format("jdbc") \
        .option("url", "jdbc:sqlserver://localhost:1433;databaseName=XYZ_Financials_Securities") \
        .option("dbtable", "dbo.Loans") \
        .option("user", "username") \
        .option("password", "password") \
        .load() \
        .filter(col("loan_id") == loan_id)
    
    # Generate amortization schedule using UDF
    # This would typically be done with a Pandas UDF for better performance
    return loan_df

def load_historical_data_to_delta(spark):
    """Load historical data from SQL Server to Delta Lake"""
    
    tables = [
        "Customers", "Loans", "Payments", "Applications",
        "PropertyDetails", "MortgageProducts", "EscrowAccounts",
        "Securities", "DefaultsForeclosures"
    ]
    
    jdbc_url = "jdbc:sqlserver://localhost:1433;databaseName=XYZ_Financials_Securities"
    
    for table in tables:
        df = spark.read \
            .format("jdbc") \
            .option("url", jdbc_url) \
            .option("dbtable", f"dbo.{table}") \
            .option("user", "username") \
            .option("password", "password") \
            .load()
        
        # Write to Delta Lake
        df.write \
            .format("delta") \
            .mode("overwrite") \
            .option("path", f"/data/delta/{table.lower()}") \
            .save()
        
        print(f"Loaded {table} to Delta Lake")

# =============================================
# PART 8: MAIN EXECUTION
# =============================================

def main():
    """Main execution function"""
    
    # Create Spark session
    spark = create_spark_session()
    
    # Register UDFs
    register_udfs(spark)
    
    # Setup streaming sources
    print("Setting up streaming sources...")
    sources = setup_streaming_sources(spark)
    
    # Create views
    print("Creating streaming views...")
    create_streaming_views(spark)
    
    # Start continuous queries
    print("Starting continuous queries...")
    
    # Query 1: Delinquency Alerts
    delinquency_query = create_delinquency_alert_stream(spark)
    
    # Query 2: Payment Metrics
    payment_query = create_payment_metrics_stream(spark)
    
    # Query 3: Portfolio Metrics
    portfolio_query = create_portfolio_metrics_stream(spark)
    
    # Optionally load historical data
    # load_historical_data_to_delta(spark)
    
    print("All streaming queries started successfully!")
    print("Waiting for termination...")
    
    # Wait for all queries to finish
    spark.streams.awaitAnyTermination()

if __name__ == "__main__":
    main()

# =============================================
# PART 9: UTILITY FUNCTIONS
# =============================================

def stop_all_streams(spark):
    """Stop all active streaming queries"""
    for query in spark.streams.active:
        query.stop()
    print("All streaming queries stopped")

def show_stream_status(spark):
    """Display status of all active streams"""
    for query in spark.streams.active:
        print(f"Query: {query.name}")
        print(f"Status: {query.status}")
        print(f"Recent Progress: {query.lastProgress}")
        print("-" * 50)

# =============================================
# END OF SPARK SETUP
# =============================================