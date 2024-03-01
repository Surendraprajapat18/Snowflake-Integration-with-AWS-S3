
-- Creating the database
CREATE DATABASE s3_to_snowflake_db;

-- Creating the integration for snowflake with s3
CREATE OR REPLACE STORAGE INTEGRATION S3_Snowflake 
	TYPE = EXTERNAL_STAGE 
	STORAGE_PROVIDER = 'S3'
	ENABLED = TRUE 
	STORAGE_AWS_ROLE_ARN = '<aws role arn>' -- Creat role and paste arn 
	STORAGE_ALLOWED_LOCATIONS = ('s3://<bucket_name>');


SHOW INTEGRATIONS;

DESC INTEGRATION S3_Snowflake;


-- Creat the file format for csv 
CREATE OR REPLACE file format csv_format
type='CSV'
field_delimiter=','
skip_header=1;


-- creating the stage with the name of mystage
CREATE OR REPLACE STAGE mystage 
storage_integration = S3_Snowflake
file_format = CSV_FORMAT
url = 's3://sp-sf-s3-bucket/' ; 


list @mystage;

remove @mystage/insuranse_data.csv;


-- Creating the table for data
CREATE OR REPLACE TABLE insurance_data
( age number,
  sex varchar(10),	
  bmi decimal(4,2),
  children number,
  smoker varchar(12),
  region varchar(30),
  charges decimal(38,3)
);

COPY INTO INSURANCE_DATA
FROM @mystage
files = ('insuranse_data.csv')
file_format=(format_name=csv_format);

SELECT * FROM INSURANCE_DATA LIMIT 10;