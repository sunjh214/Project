use PortfolioProject
select *
from Nashville_House

-- Standardize Data Format --

alter table Nashville_House
add SaleDate2 date;

update Nashville_House
set SaleDate2 = CONVERT(Date, SaleDate)

-- Populate Property Address Data --

--select *
--from Nashville_House
--where PropertyAddress is null
--order by ParcelID

--select a.[UniqueID ] aID, b.[UniqueID ] bID, b.ParcelID, a.PropertyAddress, b.PropertyAddress
--from Nashville_House a
--join Nashville_House b
	--on a.ParcelID = b.ParcelID
	--and a.[UniqueID ] <> b.[UniqueID ]
--where a.PropertyAddress is null

Update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from Nashville_House a
join Nashville_House b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]

-- Breaking out Address into Individual Columns (Address, City, State) --

select PropertyAddress
from Nashville_House

--select 
--SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1) as Address,
--SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as City
--from Nashville_House

alter table Nashville_House
add PropertySplitAddress nvarchar(255);

update Nashville_House
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, charindex(',', PropertyAddress) -1)

alter table Nashville_House
add PropertySplitCity nvarchar(255);

update Nashville_House
set PropertySplitCity = SUBSTRING(PropertyAddress, charindex(',', PropertyAddress) +1, LEN(PropertyAddress))


select
PARSENAME(replace(OwnerAddress, ',', '.'), 3)
from Nashville_House

alter table Nashville_House
add OwnerSplitAddress nvarchar(255);

update Nashville_House
set OwnerSplitAddress = PARSENAME(replace(owneraddress, ',', '.'), 3)

alter table Nashville_House
add OwnerSplitCity nvarchar(255);

update Nashville_House
set OwnerSplitCity = PARSENAME(replace(owneraddress, ',', '.'), 2)

alter table Nashville_House
add OwnerSplitState nvarchar(255);

update Nashville_House
set OwnerSplitState = PARSENAME(replace(owneraddress, ',', '.'), 1)

-- Change Y and N to Yes and No in "Sold as Vacant" field --

select distinct(SoldAsVacant), count(SoldAsVacant)
from Nashville_House
group by SoldAsVacant
order by 2

--select SoldAsVacant,
--CASE when SoldAsVacant = 'Y' then 'Yes'
	 --when SoldAsVacant = 'N' then 'No'
	 --else SoldAsVacant
	 --end
--from Nashville_House

update Nashville_House
set SoldAsVacant = CASE when SoldAsVacant = 'Y' then 'Yes'
	 when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 end