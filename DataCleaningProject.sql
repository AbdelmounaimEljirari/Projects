/* Data Cleaning Project */

Select *
From NashvilleHousing

-- Reformat SaleDate

SELECT SaleDate, CONVERT(date, SaleDate)
From NashvilleHousing

UPDATE NashvilleHousing 
SET SaleDate = CONVERT(date, SaleDate)

--------------------------------------------------------------------

-- Handle Null Values in PropertyAddress
-- Observations with the same ParcelID share the same PropertyAddress

Select *
From NashvilleHousing
order by ParcelID

SELECT a.PropertyAddress, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] != b.[UniqueID ]
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] != b.[UniqueID ]
WHERE a.PropertyAddress is null

Select *
From NashvilleHousing
WHERE PropertyAddress is null


--------------------------------------------------------------------

-- Separate the Address into 3 Columns (Address, City, State)


-- 1. Property Address

SELECT PropertyAddress, 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS City
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD Property_Address nvarchar(255);

UPDATE NashvilleHousing
SET Property_Address = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
ADD Property_City nvarchar(255);

UPDATE NashvilleHousing
SET Property_City = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

-- 2. Owner Address

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) Owner_State,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) Owner_City,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) Owner_Address
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD Owner_Address nvarchar(255);

ALTER TABLE NashvilleHousing
ADD Owner_City nvarchar(255);

ALTER TABLE NashvilleHousing
ADD Owner_State nvarchar(255);

UPDATE NashvilleHousing
SET Owner_Address = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

UPDATE NashvilleHousing
SET Owner_City = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

UPDATE NashvilleHousing
SET Owner_State = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)



--------------------------------------------------------------------

-- Change Y and N to Yes and No in SoldAsVacant field

SELECT  DISTINCT SoldAsVacant, count(*) 
FROM NashvilleHousing
GROUP BY SoldAsVacant

UPDATE NashvilleHousing
SET SoldAsVacant = 'Yes'
WHERE SoldAsVacant = 'Y'

UPDATE NashvilleHousing
SET SoldAsVacant = 'No'
WHERE SoldAsVacant = 'N'

--------------------------------------------------------------------

-- Remove Duplicates

SELECT *
FROM NashvilleHousing


WITH CTE AS (
SELECT *, ROW_NUMBER() OVER(
    PARTITION BY ParcelID,
	             PropertyAddress,
				 SalePrice,
				 LegalReference
				 ORDER BY UniqueID
				 ) Row_Num
FROM
    NashvilleHousing
)
DELETE
FROM CTE
WHERE Row_Num > 1


--------------------------------------------------------------------

-- Delete Unused Columns

ALTER TABLE NashvilleHousing
DROP COLUMN PropertyAddress, OwnerAddress 

SELECT *
FROM NashvilleHousing
