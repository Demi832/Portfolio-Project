-- Data Cleaning
Select *
From layoffs
;


-- 1. Remove Duplicates if any
-- 2. Standardizze the Data
-- 3. Null Values or blank values
-- 4. Remove Any Columns


Create Table layoffs_staging
Like layoffs
;


Select *
From layoffs_staging
;

Insert layoffs_staging
Select *
From layoffs
;

-- Removing Duplicates
Select *,
row_number() OVER(
Partition by company, industry, total_laid_off, percentage_laid_off, `date`) as Row_Num
From layoffs_staging
;

-- CTE to check for duplicates using row number
With Duplicate_CTE as
(
Select *,
row_number() OVER(
Partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as Row_Num
From layoffs_staging
)
Select *
From Duplicate_CTE
where Row_Num > 1;


With Duplicate_CTE as
(
Select *,
row_number() OVER(
Partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as Row_Num
From layoffs_staging
)
Delete
From Duplicate_CTE
where Row_Num > 1;

CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int 
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;



Insert into layoffs_staging2
Select *,
row_number() OVER(
Partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as Row_Num
From layoffs_staging
;

Delete 
From layoffs_staging2
Where row_num > 1;

Select *
From layoffs_staging2
;

-- Standardizing Data
Select distinct company, trim(company)
From layoffs_staging2
;

update layoffs_staging2
set company = trim(company)
;

Select distinct industry
From layoffs_staging2
;

-- Make Crypto standard all through
update layoffs_staging2
set industry = 'Crypto'
where industry like 'Crypto%'
;

-- 1 option
update layoffs_staging2
set country = 'United States'
where country like 'United States%'
;

-- what we did to fix . at the end of US

Select distinct country
From layoffs_staging2
Order by 1;

update layoffs_staging2
set country = Trim(Trailing '.' From country)
where country like 'United States%'
;

Select `date`
From layoffs_staging2
;

update layoffs_staging2
set `date` = Str_to_date(`date`, '%m/%d/%Y')
;

Alter table layoffs_staging2
Modify column `date` Date
;


Select * 
From layoffs_staging2
Where company Like 'Bally%'
;

Select *
From layoffs_staging2
Where company = 'Airbnb'
;

-- Set blanks to NULL
Update layoffs_staging2
set industry = NULL
where industry = ''
; 

Select t1. industry, t2. industry
from layoffs_staging2 t1
Join layoffs_staging2 t2
On t1.company = t2.company
and t1.location = t2.location
Where (t1.industry is NULL OR t1.industry = '') 
and t2.industry is NOT NULL
;

Update layoffs_staging2 t1
Join layoffs_staging2 t2
	On t1.company = t2.company
set t1.industry = t2.industry
Where t1.industry is NULL
and t2.industry is NOT NULL 
;

-- Remove Columns and Rows that need to be removed

Select *
From layoffs_staging2
Where total_laid_off is NULL
And percentage_laid_off is NULL;

Delete
From layoffs_staging2
Where total_laid_off is NULL
And percentage_laid_off is NULL;

Select *
From layoffs_staging2
;

Alter table layoffs_staging2
Drop Column row_num
;
