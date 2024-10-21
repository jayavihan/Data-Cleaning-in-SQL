create database property_Sale;

use property_Sale;
 
select * from dbo.property; 

/*

Cleaning Data in SQL Queries

*/


Select *
From dbo.property order by UniqueID;

SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'property';

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format
Select alterdate,convert(date,SaleDate)
From dbo.property order by UniqueID;

update dbo.property
SET SaleDate=convert(date,SaleDate)

ALTER TABLE dbo.property
ADD  alterdate DATE;

UPDATE dbo.property
SET alterdate=convert(date,SaleDate)


 --------------------------------------------------------------------------------------------------------------------------

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


-- Breaking out Address into Individual Columns (Address, City, State)


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



-- check Owner Address 

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

--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field
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


-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates
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



---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

Select *
From dbo.property


ALTER TABLE dbo.property
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate





-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------

--- Importing Data using OPENROWSET and BULK INSERT	

--  More advanced and looks cooler, but have to configure server appropriately to do correctly
--  Wanted to provide this in case you wanted to try it


--sp_configure 'show advanced options', 1;
--RECONFIGURE;
--GO
--sp_configure 'Ad Hoc Distributed Queries', 1;
--RECONFIGURE;
--GO


--USE PortfolioProject 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 1 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 1 

--GO 


---- Using BULK INSERT

--USE PortfolioProject;
--GO
--BULK INSERT nashvilleHousing FROM 'C:\Temp\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv'
--   WITH (
--      FIELDTERMINATOR = ',',
--      ROWTERMINATOR = '\n'
--);
--GO


---- Using OPENROWSET
--USE PortfolioProject;
--GO
--SELECT * INTO nashvilleHousing
--FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
--    'Excel 12.0; Database=C:\Users\alexf\OneDrive\Documents\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv', [Sheet1$]);
--GO