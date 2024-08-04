select *
from PortolioProject.dbo.NashvilleHousing

-----------------------------------------------
--Standardise Date format

select SaleDateConverted, CONVERT(Date,SaleDate)
from PortolioProject.dbo.NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

Alter table NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

--populate property address data

select *
from PortolioProject.dbo.NashvilleHousing
--where PropertyAddress is null
order by ParcelID
--
select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortolioProject.dbo.NashvilleHousing a
join PortolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null
--
update a
set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortolioProject.dbo.NashvilleHousing a
join PortolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

--break out address into individual columns

select PropertyAddress
from PortolioProject.dbo.NashvilleHousing
--where PropertyAddress is null
--order by ParcelID

select
substring(PropertyAddress, 1, Charindex(',', PropertyAddress) -1 ) as Address
, substring(PropertyAddress, Charindex(',', PropertyAddress) + 1, LEN(PropertyAddress)) as Address
from PortolioProject.dbo.NashvilleHousing

Alter table NashvilleHousing
Add PropertySplitAddress nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = substring(PropertyAddress, 1, Charindex(',', PropertyAddress) -1 )


Alter table NashvilleHousing
Add PropertySplitCity nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = substring(PropertyAddress, Charindex(',', PropertyAddress) + 1, LEN(PropertyAddress))

----

select 
PARSENAME(replace(OwnerAddress,',','.'),3),
PARSENAME(replace(OwnerAddress,',','.'),2),
PARSENAME(replace(OwnerAddress,',','.'),1)
from PortolioProject.dbo.NashvilleHousing

Alter table NashvilleHousing
Add OwnerSplitAddress nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(replace(OwnerAddress,',','.'),3)


Alter table NashvilleHousing
Add OwnerSplitCity nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(replace(OwnerAddress,',','.'),2)

Alter table NashvilleHousing
Add OwnerSplitState nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(replace(OwnerAddress,',','.'),1)

--change Y and N to yes and no in "sold as vacant" field

select distinct(SoldAsVacant), count(SoldAsVacant)
from PortolioProject.dbo.NashvilleHousing
group by SoldAsVacant
order by 2

select SoldAsVacant,
Case when SoldAsVacant = 'Y' Then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
	END
from PortolioProject.dbo.NashvilleHousing

update NashvilleHousing
set SoldAsVacant = Case when SoldAsVacant = 'Y' Then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
	END



--remove duplicates (usually we don't delete raw data)

with RowNumCTE AS(
select *,
row_number() over (partition by ParcelID,
								PropertyAddress,
								SalePrice,
								SaleDate,
								LegalReference
								order by
									UniqueID)
									row_num
from PortolioProject.dbo.NashvilleHousing
--order by ParcelID
)
Select * --delete
from RowNumCTE
where row_num > 1
order by PropertyAddress

--delete unused columns (usually we don't delete raw data)

alter table PortolioProject.dbo.NashvilleHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

Select *
from PortolioProject.dbo.NashvilleHousing