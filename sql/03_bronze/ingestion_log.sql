/*
    File: ingestion_log.sql

    Purpose:
    Creates the Bronze ingestion log table used to track pipeline
    executions, processing status, record counts, and errors.
*/


-- Create bronze.ingestion_log
CREATE TABLE bronze.ingestion_log
(
    ingestion_id UNIQUEIDENTIFIER NOT NULL,

    pipeline_name VARCHAR(100) NOT NULL,

    start_time DATETIME2 NOT NULL,

    end_time DATETIME2 NULL,

    status VARCHAR(20) NOT NULL,

    records_received INT DEFAULT 0,

    error_message VARCHAR(2000) NULL,

    CONSTRAINT PK_bronze_ingestion_log
        PRIMARY KEY (ingestion_id)
);
GO
