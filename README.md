# Data Cleaning in SQL (SQL Project)

## Project Overview

**Project Title**: Data Cleaning in SQL  
**Level**: Intermediate  
**Database**: `Property_sale`
**table**: `property`

This project demonstrates dive into SQL for a data cleaning project, focusing on techniques to clean and prepare a Nashville housing dataset for analysis

## Key Insights
📈 Importance of Data Cleaning: Data cleaning is crucial for accurate analysis, making this project highly relevant for aspiring data analysts.
🔄 SQL Techniques: The project covers various SQL techniques, such as using substrings and character indexing, enhancing viewers’ SQL skills.
🏡 Real Dataset Usage: Utilizing a real-world dataset, like Nashville housing data, adds practical relevance and engagement to the learning experience.
🔑 Understanding Data Structure: The video teaches viewers how to recognize and manipulate data structures effectively to improve data usability.
⚙️ Advanced SQL Functions: Introducing concepts like CTEs and window functions offers deeper insights into SQL’s capabilities.
✅ Iterative Learning: Encouraging viewers to pause and research fosters a deeper understanding of SQL, promoting an iterative learning approach.
🌟 Portfolio Growth: Completing this project equips viewers with a tangible addition to their portfolios, showcasing their data cleaning abilities.

## Project Structure

1 Standardize Date Format
```sql
Select *
From dbo.property order by UniqueID;

SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'property';

-- Standardize Date Format
Select alterdate,convert(date,SaleDate)
From dbo.property order by UniqueID;

update dbo.property
SET SaleDate=convert(date,SaleDate)

ALTER TABLE dbo.property
ADD  alterdate DATE;

UPDATE dbo.property
SET alterdate=convert(date,SaleDate)


```

2 Populate Property Address data

```sql

-- Populate Property Address data

Select *
From dbo.property
--Where PropertyAddress is null
order by ParcelID


select A.ParcelID, A.PropertyAddress,B.ParcelID, B.PropertyAddress,ISNULL(A.PropertyAddress,B.PropertyAddress)
From dbo.property A
	JOIN dbo.property B
	ON A.ParcelID= B.ParcelID 
	AND A.UniqueID <> B.UniqueID
WHERE A.PropertyAddress IS NULL


UPDATE A
SET PropertyAddress = ISNULL(A.PropertyAddress,B.PropertyAddress)
From dbo.property A
	JOIN dbo.property B
	ON A.ParcelID= B.ParcelID 
	AND A.UniqueID <> B.UniqueID
WHERE A.PropertyAddress IS NULL


```


3. Breaking out Address into Individual Columns (Address, City, State)

```sql
Select PropertyAddress
From dbo.property
Where PropertyAddress is null
--order by ParcelID

Select PropertyAddress,SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1),
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))
From dbo.property

ALTER TABLE dbo.property
ADD address1 NVARCHAR(50);

ALTER TABLE dbo.property
ADD address2 NVARCHAR(50);

UPDATE dbo.property
SET address1 =SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1);

UPDATE dbo.property
SET address2 =SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress));

Select PropertyAddress,address1,address2
From dbo.property
```

4. split Owner Address 
```sql
Select PropertyAddress,OwnerAddress
From dbo.property

select count(OwnerAddress)
From dbo.property where OwnerAddress is not null AND OwnerAddress LIKE '%, TN';

ALTER TABLE dbo.property
ADD OwnerAddress1 NVARCHAR(50);

ALTER TABLE dbo.property
ADD OwnerCity NVARCHAR(50);

ALTER TABLE dbo.property
ADD OwnerState NVARCHAR(50);

UPDATE dbo.property
SET OwnerAddress1 =PARSENAME(REPLACE(OwnerAddress,',','.'),3);

UPDATE dbo.property
SET OwnerCity =PARSENAME(REPLACE(OwnerAddress,',','.'),2);

UPDATE dbo.property
SET OwnerState =PARSENAME(REPLACE(OwnerAddress,',','.'),1);

Select PropertyAddress,OwnerAddress1,OwnerCity,OwnerState
From dbo.property
```


5. Change Y and N to Yes and No in "Sold as Vacant" field
```sql
Select *
From dbo.property

Select DISTINCT(SoldAsVacant),COUNT(SoldAsVacant)
From dbo.property
GROUP BY SoldAsVacant

SELECT SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y'  THEN 'Y'  
		WHEN SoldAsVacant = 'N'  THEN 'N'
		ELSE SoldAsVacant END 
From dbo.property


UPDATE dbo.property
SET SoldAsVacant= CASE WHEN SoldAsVacant = 'Y'  THEN 'YES'  
		WHEN SoldAsVacant = 'N'  THEN 'NO'
		ELSE SoldAsVacant END 
From dbo.property
```

6. Remove Duplicates
```sql
SELECT *,ROW_NUMBER() OVER(PARTITION BY ParcelId,PropertyAddress,SaleDate,LegalReference order by UniqueId) AS counts
FROM dbo.property 
-- ----------------

WITH NumberedProperties AS (
  SELECT *, ROW_NUMBER() OVER (PARTITION BY ParcelId, PropertyAddress, SaleDate,SalePrice, LegalReference ORDER BY UniqueId) AS counts
  FROM dbo.property
)
DELETE 
FROM NumberedProperties
WHERE counts > 1
```
7. Delete Unused Columns
```sql
Select *
From dbo.property


ALTER TABLE dbo.property
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
```

## project Summury

This project demonstrates the application of SQL skills in creating and managing a library management system. It includes database setup, data manipulation, and advanced querying, providing a solid foundation for data management and analysis.

- The date format standardization.
- The property address was populated before being separated into individual columns to avoid data loss.
- A combination of substring, char index, parse name, and replace functions were used to manipulate the data.
- Case statements were utilized to change "yes" to "no" and "y" to "yes" and "no."
- Duplicate entries remove using a row number, CTE, and windows function.
- unnecessary columns were deleted from the project

Thank you for your interest in this project!
