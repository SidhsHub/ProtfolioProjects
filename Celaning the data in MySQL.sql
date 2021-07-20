/*
Cleaing the data in MySQL
*/

USE housingdata;
SELECT 
    *
FROM
    housing;
------------------------------------------------------------------------------------------------------------------
-- Standardize Date Format

SELECT 
    SaleDate, STR_TO_DATE(SaleDate, '%M %d,%Y')
FROM
    housing;

Alter table housing add SaleDateConverted date;

UPDATE housing set SaleDateConverted = STR_TO_DATE(SaleDate, '%M %d,%Y');

SELECT 
    SaleDate, SaleDateConverted
FROM
    housing;
    
------------------------------------------------------------------------------------------------------------------    
-- populate property address

SELECT 
    PropertyAddress
FROM
    housing
WHERE
    PropertyAddress IS NULL;

SELECT 
    a.ParcelID,
    a.PropertyAddress,
    b.ParcelID,
    b.PropertyAddress,
    IFNULL(a.PropertyAddress, b.PropertyAddress)
FROM
    housing a
        JOIN
    housing b ON a.ParcelID = b.ParcelID
        AND a.UniqueID <> b.UniqueID
WHERE
    a.PropertyAddress IS NULL;

UPDATE housing a
        JOIN
    housing b ON a.ParcelID = b.ParcelID
        AND a.UniqueID <> b.UniqueID 
SET 
    a.PropertyAddress = IFNULL(a.PropertyAddress, b.PropertyAddress)
WHERE
    a.PropertyAddress IS NULL;
   
 ------------------------------------------------------------------------------------------------------------------  
-- breaking out Address into Individual Columns (Address, City, State)

SELECT 
    substring(PropertyAddress, 1, locate(',', PropertyAddress)-1) AS Address,
    substring(PropertyAddress, locate(',', PropertyAddress)+1) AS City,
    locate(',', PropertyAddress)
FROM
    housing;

Alter table housing add PropertySplitAddress varchar(255);
-- Alter table housing drop PropertySplitAddress;
UPDATE housing 
SET 
    PropertySplitAddress = SUBSTRING(PropertyAddress,
        1,
        LOCATE(',', PropertyAddress) - 1);


Alter table housing add PropertySplitCity varchar(255);

UPDATE housing 
SET 
    PropertySplitCity = SUBSTRING(PropertyAddress,
        LOCATE(',', PropertyAddress) + 1);

SELECT 
    OwnerAddress
FROM
    housing;
    
SELECT 
    substring_index(OwnerAddress, ",", 1) AS Address,
    substring_index(substring_index(OwnerAddress, ",", 2), ",", -1) AS City,
    substring_index(substring_index(OwnerAddress, ",", 3), ",", -1) AS State
FROM
    housing;
    
Alter table housing add OwnerSplitAddress varchar(255);

UPDATE housing 
SET 
    OwnerSplitAddress = SUBSTRING(PropertyAddress,
        LOCATE(',', PropertyAddress) + 1);
        
Alter table housing add OwnerSplitCity varchar(255);

UPDATE housing 
SET 
    OwnerSplitCity = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2),
            ',',
            - 1);
            
Alter table housing add OwnerSplitState varchar(255);

UPDATE housing 
SET 
    OwnerSplitState = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 3),
            ',',
            - 1);
            
 ------------------------------------------------------------------------------------------------------------------
-- Change Y and N to Yes and No in 'Sold as vacant' field.

SELECT 
    SoldAsVacant, COUNT(SoldAsVacant) AS count
FROM
    housing
GROUP BY SoldAsVacant
ORDER BY count;

SELECT 
    SoldAsVacant,
    CASE
        WHEN SoldAsVacant = 'Y' THEN 'Yes'
        WHEN SoldAsVacant = 'N' THEN 'No'
        ELSE SoldAsVacant
    END AS Cleaned
FROM
    housing
WHERE
    SoldAsVacant in ('Y', 'N');
    
UPDATE housing 
SET 
    SoldAsVacant = CASE
        WHEN SoldAsVacant = 'Y' THEN 'Yes'
        WHEN SoldAsVacant = 'N' THEN 'No'
        ELSE SoldAsVacant
    END;

 ------------------------------------------------------------------------------------------------------------------    
-- Remove duplicate

-- In MySQL CTE are read only
WITH row_num_cte AS (
select *, row_number() over (
partition by ParcelID,
PropertyAddress,
SaleDate,
SalePrice,
LegalReference
order by UniqueID) 
row_num
FROM
    housing)
-- DELETE
SELECT 
*
FROM
    row_num_cte
WHERE
    row_num > 1;
-- ORDER BY PropertyAddress

 ------------------------------------------------------------------------------------------------------------------  
 
 -- Delete unused columns
 
SELECT 
    *
FROM
    housing;
    
alter Table housing drop PropertyAddress, drop OwnerAddress, drop TaxDistrict, drop SaleDate;