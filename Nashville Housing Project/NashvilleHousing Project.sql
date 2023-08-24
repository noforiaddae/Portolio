select * 
from NashvilleHousing

-- populate property address data by joining table to itself

select *
from PortfolioProject.dbo.NashvilleHousing
order by ParcelID

select *
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]



-- property addresses that are null
select a.ParcelID, a.propertyaddress, b.parcelid, b.propertyaddress
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


-- showing new column to replace null values in property address
select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

-- updating table to remove null values (update executed before previous code executed)
update a
set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null



-- breaking out address into individual columns (address, city, state)
select PropertyAddress
from PortfolioProject.dbo.NashvilleHousing

-- separate city from address using delimiter
select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1) as Address
from PortfolioProject.dbo.NashvilleHousing


-- city in its own column
select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress)) as City
from PortfolioProject.dbo.NashvilleHousing



alter table NashvilleHousing
Add PropertySplitAddress nvarchar(255);

update NashvilleHousing
set PropertySplitAddress  = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1)

alter table NashvilleHousing
add PropertySplitCity nvarchar(255);

update NashvilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress))


-- final 

select *
from PortfolioProject.dbo.NashvilleHousing


-- separate OwnerAddress column

select OwnerAddress
from PortfolioProject.dbo.NashvilleHousing


select 
PARSENAME(replace(OwnerAddress, ',', '.'), 3),
PARSENAME(replace(OwnerAddress, ',', '.'), 2),
PARSENAME(replace(OwnerAddress, ',', '.'), 1)
from PortfolioProject.dbo.NashvilleHousing

-- adding newly separated columns to the table

alter table NashvilleHousing
Add OwnerSplitAddress nvarchar(255);

update NashvilleHousing
set OwnerSplitAddress  = PARSENAME(replace(OwnerAddress, ',', '.'), 3)

alter table NashvilleHousing
add OwnerSplitCity nvarchar(255);

update NashvilleHousing
set OwnerSplitCity = PARSENAME(replace(OwnerAddress, ',', '.'), 2)

alter table NashvilleHousing
add OwnerSplitState nvarchar(255);

update NashvilleHousing
set OwnerSplitState = PARSENAME(replace(OwnerAddress, ',', '.'), 1)


-- final 

select *
from PortfolioProject.dbo.NashvilleHousing


-- change Y and N to Yes and No in "Sold as vacant" field

select Distinct(SoldAsVacant), count(SoldAsVacant)
from PortfolioProject.dbo.NashvilleHousing
group by SoldAsVacant
order by 2


select SoldAsVacant,
case when SoldAsVacant = 'Y' then 'Yes'
when SoldAsVacant = 'N' then 'No'
else SoldAsVacant
end 
from PortfolioProject.dbo.NashvilleHousing


-- update table 
update NashvilleHousing
set SoldAsVacant = 
case when SoldAsVacant = 'Y' then 'Yes'
when SoldAsVacant = 'N' then 'No'
else SoldAsVacant
end 




-- remove duplicates

with RowNumCTE as(
select*,
ROW_NUMBER() 
over(partition by ParcelID,PropertyAddress, SalePrice, SaleDate, LegalReference
order by UniqueID) row_num
from PortfolioProject.dbo.NashvilleHousing
)
select *
from RowNumCTE
where row_num>1
order by PropertyAddress


-- delete duplicates
with RowNumCTE as(
select*,
ROW_NUMBER() 
over(partition by ParcelID,PropertyAddress, SalePrice, SaleDate, LegalReference
order by UniqueID) row_num
from PortfolioProject.dbo.NashvilleHousing
)
delete
from RowNumCTE
where row_num>1




-- delete unused columns 

select *
from PortfolioProject.dbo.NashvilleHousing

alter table PortfolioProject.dbo.NashvilleHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress
