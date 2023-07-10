/*

Cleaning Data in SQL Queries

*/ 

SELECT *
FROM NashvilleHousingData
ORDER BY ParcelID


-- Standardize Date Format

SELECT SaleDate, CONVERT(Date, SaleDate)
FROM NashvilleHousingData

UPDATE NashvilleHousingData
SET SaleDate = CONVERT(Date,SaleDate)


-- Populate Property Address data

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousingData a
JOIN NashvilleHousingData b
    ON a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousingData a
JOIN NashvilleHousingData b
    ON a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID


-- Breaking out Address into Individual Columns (Address, City, State) --

-- Break out Property Address by Substring

SELECT *
FROM NashvilleHousingData

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as City
FROM NashvilleHousingData

ALTER TABLE NashvilleHousingData
ADD PropertySplitAddress NVARCHAR(255)

UPDATE NashvilleHousingData
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)

ALTER TABLE NashvilleHousingData
ADD PropertySplitCity NVARCHAR(255)

UPDATE NashvilleHousingData
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

ALTER TABLE NashvilleHousingData
ADD StateofAddress NVARCHAR(255)

UPDATE NashvilleHousingData
SET StateofAddress = 'TN'

-- Break out Owber Address by PARSENAME

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) AS OwnerStreetName,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) AS OwnerCity,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) AS OwnerState
FROM NashvilleHousingData

ALTER TABLE NashvilleHousingData
ADD OwnerStreetName NVARCHAR(255)

UPDATE NashvilleHousingData
SET OwnerStreetName = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHousingData
ADD OwnerCity NVARCHAR(255)

UPDATE NashvilleHousingData
SET OwnerCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousingData
ADD OwnerState NVARCHAR(255)

UPDATE NashvilleHousingData
SET OwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


-- Change Y and N to Yes and No in "Sold as Vacant" field


SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM NashvilleHousingData
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
    WHEN SoldAsVacant = 'N' THEN 'No'
    ELSE SoldAsVacant
    END
FROM NashvilleHousingData

UPDATE NashvilleHousingData
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
    WHEN SoldAsVacant = 'N' THEN 'No'
    ELSE SoldAsVacant
    END


-- Delete Duplicates

WITH RowNumCTE AS (
SELECT *,
    ROW_NUMBER() OVER (
        PARTITION BY ParcelID,
            PropertyAddress,
            SalePrice,
            SaleDate,
            LegalReference
            ORDER BY
                UniqueID
    ) AS row_num
FROM NashvilleHousingData
)

SELECT *
FROM RowNumCTE
WHERE row_num > 1


-- Delete Unused Columns (Owner Address and Property Address)

SELECT *
FROM NashvilleHousingData

ALTER TABLE NashvilleHousingData
DROP COLUMN OwnerAddress, PropertyAddress

/* 

Attempt to see which properties had owners with another address

SELECT *
FROM NashvilleHousingData
WHERE PropertyAddress <> SUBSTRING(OwnerAddress, 1, CHARINDEX(', TN', OwnerAddress) - 1)

SELECT SUBSTRING(OwnerAddress, 1, CHARINDEX(', TN', OwnerAddress) - 1)
FROM NashvilleHousingData

*/