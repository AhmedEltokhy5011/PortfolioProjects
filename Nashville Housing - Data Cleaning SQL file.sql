
 /*
Cleaning Data in SQL Queries
*/

--- Property Address field data cleaning

--Observations:
--1) have found 29 NULL values in property address column, shouldn't have NULL values
--2) observed that when ParcelID have the same value, the property address has the same value

SELECT *
FROM [dbo].[Nashville]
--Where PropertyAddress is null
ORDER BY ParcelID
--GROUP BY PropertyAddress

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
FROM [dbo].[Nashville] AS a
JOIN [dbo].[Nashville] AS b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL

UPDATE a
SET a.PropertyAddress= ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [dbo].[Nashville] AS a
JOIN [dbo].[Nashville] AS b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
WHERE  a.PropertyAddress IS NULL


---------------------------------------------------------------------------------------


-- Splitting PropertyAddress field into (Address, City) fields by delimeter ','

SELECT PropertyAddress, SUBSTRING(PropertyAddress,1, CHARINDEX(',', PropertyAddress)-1) AS address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) AS city
FROM [dbo].[Nashville]
WHERE CHARINDEX(',', OwnerAddress) > 0;

-- Adding Property_Address column
ALTER TABLE [dbo].[Nashville]
Add Property_Address varchar(255);

Update [dbo].[Nashville]
SET Property_Address = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

-- Adding Property_City column
ALTER TABLE [dbo].[Nashville]
Add Property_City varchar(255);

Update [dbo].[Nashville]
SET Property_City = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

---------------------------------------------------------------------------------------


--- Splitting OwnerAddress field into (Address, City, State) fields


SELECT OwnerAddress
FROM dbo.Nashville


SELECT OwnerAddress,
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3), 
	PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2),
	PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
FROM dbo.Nashville


-------------
ALTER TABLE dbo.Nashville
Add Owner_Address varchar(255);

Update dbo.Nashville
SET Owner_Address = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE dbo.Nashville
Add Owner_City varchar(255);

Update dbo.Nashville
SET Owner_City = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE dbo.Nashville
Add Owner_State varchar(255);

Update dbo.Nashville
SET Owner_State  = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)


SELECT *
FROM dbo.Nashville

-------------------------------------------------------------------------



--- "SoldAsVacant" field data cleaning
-- Change Y to Yes and N to No

SELECT DISTINCT SoldAsVacant, COUNT(*)
FROM [dbo].[Nashville]
GROUP BY SoldAsVacant

SELECT SoldAsVacant,
	CASE WHEN SoldAsVacant='Y' THEN 'Yes'
	WHEN SoldAsVacant='N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM [dbo].[Nashville]

UPDATE [dbo].[Nashville]
SET SoldAsVacant = CASE WHEN SoldAsVacant='Y' THEN 'Yes'
	WHEN SoldAsVacant='N' THEN 'No'
	ELSE SoldAsVacant
	END
------------------------------------------------------------------------------------------------------------------




-- REMOVE Duplicates

--creating temp table of duplicates rows
WITH RowNumCTE AS(
SELECT *,ROW_NUMBER() OVER (PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
						ORDER BY UniqueID) AS row_num
FROM dbo.Nashville
--order by ParcelID
)

SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress

--Delete Duplicates Rows
DELETE
FROM RowNumCTE
WHERE row_num > 1

-----------------------------------------------------------------------------------




-- Delete Unused Columns


Select *
From dbo.Nashville


ALTER TABLE dbo.Nashville
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress
