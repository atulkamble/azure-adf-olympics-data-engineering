-- =====================================================
-- Tokyo Olympics - Analysis Queries
-- =====================================================

-- =====================================================
-- 1. Medal Analysis
-- =====================================================

-- Top 10 Countries by Total Medals
SELECT TOP 10
    Country,
    Gold,
    Silver,
    Bronze,
    Total,
    Rank
FROM dbo.Medals
ORDER BY Total DESC;

-- Medal Distribution by Type
SELECT 
    SUM(Gold) AS Total_Gold,
    SUM(Silver) AS Total_Silver,
    SUM(Bronze) AS Total_Bronze,
    SUM(Total) AS Grand_Total
FROM dbo.Medals;

-- Countries with more than 50 medals
SELECT 
    Country,
    Total AS Total_Medals,
    CONCAT(CAST(ROUND((Gold * 100.0 / Total), 1) AS VARCHAR), '%') AS Gold_Percentage
FROM dbo.Medals
WHERE Total > 50
ORDER BY Total DESC;

-- =====================================================
-- 2. Athlete Analysis
-- =====================================================

-- Top 10 Countries by Athlete Count
SELECT TOP 10
    Country,
    COUNT(*) AS Athlete_Count
FROM dbo.Athletes
GROUP BY Country
ORDER BY Athlete_Count DESC;

-- Top 10 Disciplines by Participation
SELECT TOP 10
    Discipline,
    COUNT(*) AS Athlete_Count
FROM dbo.Athletes
GROUP BY Discipline
ORDER BY Athlete_Count DESC;

-- Athletes from USA in Swimming
SELECT 
    Athlete_Name,
    Discipline
FROM dbo.Athletes
WHERE Country = 'United States of America' 
  AND Discipline LIKE '%Swimming%';

-- =====================================================
-- 3. Gender Participation Analysis
-- =====================================================

-- Overall Gender Distribution
SELECT 
    SUM(Female) AS Total_Female,
    SUM(Male) AS Total_Male,
    SUM(Total) AS Total_Participants,
    ROUND((SUM(Female) * 100.0 / SUM(Total)), 2) AS Female_Percentage,
    ROUND((SUM(Male) * 100.0 / SUM(Total)), 2) AS Male_Percentage
FROM dbo.EntriesGender;

-- Disciplines with Perfect Gender Parity
SELECT 
    Discipline,
    Female,
    Male,
    Total
FROM dbo.EntriesGender
WHERE Female = Male
ORDER BY Total DESC;

-- Most Female-Dominated Disciplines
SELECT TOP 5
    Discipline,
    Female,
    Male,
    Female_Percentage
FROM dbo.EntriesGender
WHERE Female > Male
ORDER BY Female_Percentage DESC;

-- Most Male-Dominated Disciplines
SELECT TOP 5
    Discipline,
    Female,
    Male,
    Male_Percentage
FROM dbo.EntriesGender
WHERE Male > Female
ORDER BY Male_Percentage DESC;

-- =====================================================
-- 4. Team Sports Analysis
-- =====================================================

-- Count of Teams by Country
SELECT 
    Country,
    COUNT(*) AS Team_Count
FROM dbo.Teams
GROUP BY Country
ORDER BY Team_Count DESC;

-- Teams by Discipline
SELECT 
    Discipline,
    COUNT(*) AS Team_Count,
    COUNT(DISTINCT Country) AS Countries_Participating
FROM dbo.Teams
GROUP BY Discipline
ORDER BY Team_Count DESC;

-- Countries participating in both Men and Women events
SELECT 
    Country,
    Discipline,
    COUNT(DISTINCT Event) AS Event_Count
FROM dbo.Teams
GROUP BY Country, Discipline
HAVING COUNT(DISTINCT Event) > 1
ORDER BY Country, Discipline;

-- =====================================================
-- 5. Coach Analysis
-- =====================================================

-- Top Countries by Coach Count
SELECT TOP 10
    Country,
    COUNT(*) AS Coach_Count
FROM dbo.Coaches
GROUP BY Country
ORDER BY Coach_Count DESC;

-- Coaches by Discipline
SELECT 
    Discipline,
    COUNT(*) AS Coach_Count
FROM dbo.Coaches
GROUP BY Discipline
ORDER BY Coach_Count DESC;

-- =====================================================
-- 6. Advanced Analytics - Join Queries
-- =====================================================

-- Medal-to-Athlete Ratio
SELECT 
    m.Country,
    m.Total AS Total_Medals,
    COUNT(DISTINCT a.Athlete_Name) AS Athlete_Count,
    CASE 
        WHEN COUNT(DISTINCT a.Athlete_Name) > 0 
        THEN ROUND(CAST(m.Total AS FLOAT) / COUNT(DISTINCT a.Athlete_Name), 2)
        ELSE 0 
    END AS Medal_Per_Athlete
FROM dbo.Medals m
LEFT JOIN dbo.Athletes a ON m.Country = a.Country
GROUP BY m.Country, m.Total
ORDER BY Medal_Per_Athlete DESC;

-- Countries with High Medal Efficiency (Top 20)
WITH CountryStats AS (
    SELECT 
        m.Country,
        m.Total AS Total_Medals,
        COUNT(DISTINCT a.Athlete_Name) AS Athlete_Count
    FROM dbo.Medals m
    LEFT JOIN dbo.Athletes a ON m.Country = a.Country
    GROUP BY m.Country, m.Total
)
SELECT TOP 20
    Country,
    Total_Medals,
    Athlete_Count,
    ROUND(CAST(Total_Medals AS FLOAT) / NULLIF(Athlete_Count, 0), 3) AS Efficiency_Score
FROM CountryStats
WHERE Athlete_Count > 0
ORDER BY Efficiency_Score DESC;

-- Disciplines with most International Diversity
SELECT TOP 10
    Discipline,
    COUNT(DISTINCT Country) AS Countries_Count,
    COUNT(*) AS Total_Athletes
FROM dbo.Athletes
GROUP BY Discipline
ORDER BY Countries_Count DESC;
