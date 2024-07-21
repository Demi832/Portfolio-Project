-- Exploratory Data Analysis

Select *
From layoffs_staging2
;

Select MAX(total_laid_off), MAX(percentage_laid_off)
From layoffs_staging2
;

Select *
From layoffs_staging2
Where percentage_laid_off = 1
Order by funds_raised_millions DESC;

Select company, SUM(total_laid_off)
From layoffs_staging2
group by company
Order by 2 DESC;

Select MIN(`date`), MAX(`date`)
From layoffs_staging2
;


Select year(`date`) , SUM(total_laid_off)
From layoffs_staging2
group by year(`date`)
Order by 1 DESC;


Select stage , SUM(total_laid_off)
From layoffs_staging2
group by stage
Order by 2 DESC;


Select company, SUM(percentage_laid_off)
From layoffs_staging2
group by company
Order by 2 DESC;


-- Rolling total layoffs
Select SUBSTRING(`date`,1,7) as `month`, Sum(total_laid_off)
From layoffs_staging2
Where SUBSTRING(`date`,1,7) is NOT NULL
Group by `month`
order by 1 ASC
;

Select *
From layoffs_staging2
;

With Rolling_Total As
(
Select SUBSTRING(`date`,1,7) as `month`, Sum(total_laid_off) as total_off
From layoffs_staging2
Where SUBSTRING(`date`,1,7) is NOT NULL
Group by `month`
order by 1 ASC
)
Select `month`, total_off,
Sum(total_off) Over(Order by `month`) as rolling_total
From Rolling_Total 
;

Select company, SUM(total_laid_off)
From layoffs_staging2
group by company
Order by 2 DESC;

Select company, Year(`date`), SUM(total_laid_off)
From layoffs_staging2
group by company,Year(`date`)
Order by 3 DESC
;



With Company_Year(company, years, total_laid_off) AS
(
Select company, Year(`date`), SUM(total_laid_off)
From layoffs_staging2
group by company,Year(`date`)
), Company_Year_Rank as
(
Select *, 
Dense_Rank() Over(partition by years Order By total_laid_off DESC) as ranking
From Company_Year
Where years is NOT NULL
)
Select *
From Company_Year_Rank
Where ranking <= 5
;