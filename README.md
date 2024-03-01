# Snowflake Integration with AWS S3

## **Step 1: Create AWS IAM Policy**

Navigate to **Identity and Access Management (IAM) >> Policy >> Create Policy >> Paste into JSON**

*Note: Replace `<bucket name>` with your actual S3 bucket name.*

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:GetObject",
                "s3:GetObjectVersion",
                "s3:DeleteObject",
                "s3:DeleteObjectVersion"
            ],
            "Resource": "arn:aws:s3:::<bucket name>/*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket",
                "s3:GetBucketLocation"
            ],
            "Resource": "arn:aws:s3:::<bucket name>/*",
            "Condition": {
                "StringLike": {
                    "s3:prefix": [
                        "*"
                    ]
                }
            }
        }
    ]
}
```

## **Step 2: Create AWS IAM Role**

Navigate to **IAM >> Create Role >> Select AWS Account >> click on(This Account) >> External ID(Enter Random 4 number) >> Enter Name >> Select the policy that we created before**

![AWS IAM Role](https://github.com/Surendraprajapat18/Snowflake-Integration-with-AWS-S3/assets/97840357/80580695-6eab-4dcc-b807-762ea8427174)

![AWS IAM Role](https://github.com/Surendraprajapat18/Snowflake-Integration-with-AWS-S3/assets/97840357/00b3580a-75e4-4a6f-af9d-dd935e73b8ad)

## **Step 3: Integrate Snowflake and AWS**

Run on Snowflake Workbench >> Create Database and select the database

![image](https://github.com/Surendraprajapat18/Snowflake-Integration-with-AWS-S3/assets/97840357/ee0c00eb-1e93-4754-8930-87e08b8caa4a)

```sql
-- Creating the integration for Snowflake with S3
CREATE OR REPLACE STORAGE INTEGRATION S3_Snowflake 
	TYPE = EXTERNAL_STAGE 
	STORAGE_PROVIDER = 'S3'
	ENABLED = TRUE 
	STORAGE_AWS_ROLE_ARN = '<ROLE ARN>'
	STORAGE_ALLOWED_LOCATIONS = ('<Bucket Location>');
```

## **Step 4: Update AWS IAM Role**

Navigate to **IAM >> Role >> Select the role you created >> Trust relationships >> Edit trust policy**

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "",
            "Effect": "Allow",
            "Principal": {
                "AWS": "snowflake_arn"
            },
            "Action": "sts:AssumeRole",
            "Condition": {
                "StringEquals": {
                    "sts:ExternalId": "External ID"
                }
            }
        }
    ]
}
```

You can see your External ID or Snowflake ARN using this command: 

```sql
DESC INTEGRATION S3_Snowflake;
```

*Note: `STORAGE_AWS_IAM_USER_ARN = SNOWFLAKE ARN`*

![AWS IAM Role](https://github.com/Surendraprajapat18/Snowflake-Integration-with-AWS-S3/assets/97840357/d8a6de51-8239-439d-9824-209e58506dfd)

## **Step 5: Create Stage and File Format**

```sql
-- Creating the file format for CSV 
CREATE OR REPLACE FILE FORMAT csv_format
TYPE = 'CSV'
FIELD_DELIMITER = ','
SKIP_HEADER = 1;

-- Creating the stage with the name 'mystage'
CREATE OR REPLACE STAGE mystage 
	STORAGE_INTEGRATION = S3_Snowflake
	FILE_FORMAT = CSV_FORMAT
	URL = 's3://sp-sf-s3-bucket/';
```

Check if you can retrieve the bucket list using this command:

```sql
LIST @mystage;
```

## **Step 6: Create the Table**

```sql
-- Creating the table for data
CREATE OR REPLACE TABLE insurance_data
(
	age NUMBER,
	sex VARCHAR(10),	
	bmi DECIMAL(4,2),
	children NUMBER,
	smoker VARCHAR(12),
	region VARCHAR(30),
	charges DECIMAL(38,3)
);
```

## **Step 7: Copy the Data**

```sql
-- Copy the data from the S3 bucket file to Snowflake
COPY INTO INSURANCE_DATA
FROM @mystage
FILES = ('insuranse_data.csv')
FILE_FORMAT = (FORMAT_NAME = csv_format);
```

![Data Copy](https://github.com/Surendraprajapat18/Snowflake-Integration-with-AWS-S3/assets/97840357/2b038708-f30e-4fc3-b7d5-dbc0ba532214)

![image](https://github.com/Surendraprajapat18/Snowflake-Integration-with-AWS-S3/assets/97840357/e0be0dce-f8
