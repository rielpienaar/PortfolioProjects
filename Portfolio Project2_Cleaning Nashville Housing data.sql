select * 
from PortfolioProject2.dbo.NashvilleHousing;

-- standardise SellDate to only date (without a timestamp)
alter table NashvilleHousing
add SaleDateConverted date;

update NashvilleHousing
set SaleDateConverted = convert(date, SaleDate);

select SaleDateConverted, convert(Date, SaleDate)
from PortfolioProject2.dbo.NashvilleHousing;

Select *
from NashvilleHousing;


-- ensuring that the PropertyAddress is not null by using join to fill the gap based on the ParcelID
select *
from NashvilleHousing
--where PropertyAddress is null;
order by ParcelID;

select a.parcelid, a.propertyaddress, b.parcelid, b.propertyaddress, isnull(a.propertyaddress, b.propertyaddress) as propertyaddess_filled
from PortfolioProject2.dbo.NashvilleHousing as a
join PortfolioProject2.dbo.NashvilleHousing as b
	on a.parcelid = b.parcelid
	and a.[uniqueid] <> b.[uniqueid]
where a.propertyaddress is null;

update a
set propertyaddress = isnull(a.propertyaddress, b.propertyaddress)
from PortfolioProject2.dbo.NashvilleHousing as a
join PortfolioProject2.dbo.NashvilleHousing as b
	on a.parcelid = b.parcelid
	and a.[uniqueid] <> b.[uniqueid]
where a.propertyaddress is null;

select *
from NashvilleHousing
where propertyaddress is null;

-- breaking out PropertyAdress into individual columns (adress, city)
select propertyaddress
from PortfolioProject2.dbo.NashvilleHousing;

select 
SUBSTRING(PropertyAddress, 1, charindex(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, charindex(',', PropertyAddress)+1, LEN(PropertyAddress)) as City
from PortfolioProject2..NashvilleHousing;

alter table NashvilleHousing
add PropertySplitAddress Nvarchar(255);

update NashvilleHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, charindex(',', PropertyAddress)-1);

alter table NashvilleHousing
add PropertySplitCity Nvarchar(255);

update NashvilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress, charindex(',', PropertyAddress)+1, LEN(PropertyAddress))

select *
from PortfolioProject2.dbo.NashvilleHousing;


-- breaking out OwnerAdress into individual columns (adress, city, state)
select owneraddress
from PortfolioProject2.dbo.NashvilleHousing;

select 
-- 1) split the parts of the owneraddress by the delimter [change it first from ',' to '.']
-- 2) parsename creates substrings in reverse of the original string [start with the last index]
-- 3) do it 3 times to get the address, city and state
PARSENAME(REPLACE(owneraddress, ',', '.'), 3), 
PARSENAME(REPLACE(owneraddress, ',', '.'), 2), 
PARSENAME(REPLACE(owneraddress, ',', '.'), 1)
from PortfolioProject2.dbo.NashvilleHousing;

alter table NashvilleHousing
add OwnerSplitAddress Nvarchar(255);

update NashvilleHousing
set OwnerSplitAddress = PARSENAME(REPLACE(owneraddress, ',', '.'), 3);

alter table NashvilleHousing
add OwnerSplitCity Nvarchar(255);

update NashvilleHousing
set PropertySplitCity = PARSENAME(REPLACE(owneraddress, ',', '.'), 2);

alter table NashvilleHousing
add OwnerSplitState Nvarchar(255);

update NashvilleHousing
set PropertySplitCity = PARSENAME(REPLACE(owneraddress, ',', '.'), 1);

select *
from PortfolioProject2.dbo.NashvilleHousing;


-- add the abbreviated SoldAsVacant data from Y/N to Yes or No
select distinct(SoldAsVacant), count(SoldAsVacant)
from PortfolioProject2.dbo.NashvilleHousing
group by SoldAsVacant
order by 2;

select SoldAsVacant, 
case when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	Else SoldAsVacant End
From PortfolioProject2.dbo.NashvilleHousing

update NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	Else SoldAsVacant End;

select * 
from PortfolioProject2.dbo.NashvilleHousing;


-- remove duplicate rows
with RowNumCT as(
select *,
	ROW_NUMBER() over(
	partition by parcelid,
					propertyaddress,
					saleprice,
					saledate,
					legalreference
					order by uniqueid
					) as row_num
from PortfolioProject2.dbo.NashvilleHousing
--order by parcelid
)

-- commented the delete function after deleting duplicate row [will get an error]
--delete 
--from RowNumCT
--where row_num > 1

select *  
from RowNumCT
where row_num > 1
order by PropertyAddress;


-- remove unused columns (use for views)
select * 
from PortfolioProject2.dbo.NashvilleHousing;

alter table PortfolioProject2.dbo.NashvilleHousing
drop column owneraddress, taxdistrict, propertyaddress;

alter table PortfolioProject2.dbo.NashvilleHousing
drop column saledate;