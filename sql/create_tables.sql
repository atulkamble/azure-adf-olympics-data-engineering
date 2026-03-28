-- =====================================================
-- Tokyo Olympics - Azure Synapse Table Definitions
-- =====================================================

-- Drop tables if they exist (for clean deployment)
DROP TABLE IF EXISTS dbo.Athletes;
DROP TABLE IF EXISTS dbo.Coaches;
DROP TABLE IF EXISTS dbo.Medals;
DROP TABLE IF EXISTS dbo.Teams;
DROP TABLE IF EXISTS dbo.EntriesGender;

-- =====================================================
-- 1. Athletes Table
-- =====================================================
CREATE TABLE dbo.Athletes (
    Athlete_Name VARCHAR(200) NOT NULL,
    Country VARCHAR(100) NOT NULL,
    Discipline VARCHAR(100) NOT NULL,
    Country_Upper VARCHAR(100)
)
WITH (
    DISTRIBUTION = HASH(Country),
    CLUSTERED COLUMNSTORE INDEX
);

-- =====================================================
-- 2. Coaches Table
-- =====================================================
CREATE TABLE dbo.Coaches (
    Name VARCHAR(200) NOT NULL,
    Country VARCHAR(100) NOT NULL,
    Discipline VARCHAR(100) NOT NULL,
    Event VARCHAR(200)
)
WITH (
    DISTRIBUTION = HASH(Country),
    CLUSTERED COLUMNSTORE INDEX
);

-- =====================================================
-- 3. Medals Table
-- =====================================================
CREATE TABLE dbo.Medals (
    Rank INT NOT NULL,
    Country VARCHAR(100) NOT NULL,
    Gold INT NOT NULL DEFAULT 0,
    Silver INT NOT NULL DEFAULT 0,
    Bronze INT NOT NULL DEFAULT 0,
    Total INT NOT NULL DEFAULT 0,
    Total_Rank INT NOT NULL,
    Medal_Score INT
)
WITH (
    DISTRIBUTION = HASH(Country),
    CLUSTERED COLUMNSTORE INDEX
);

-- =====================================================
-- 4. Teams Table
-- =====================================================
CREATE TABLE dbo.Teams (
    TeamName VARCHAR(100) NOT NULL,
    Discipline VARCHAR(100) NOT NULL,
    Country VARCHAR(100) NOT NULL,
    Event VARCHAR(100)
)
WITH (
    DISTRIBUTION = HASH(Country),
    CLUSTERED COLUMNSTORE INDEX
);

-- =====================================================
-- 5. EntriesGender Table
-- =====================================================
CREATE TABLE dbo.EntriesGender (
    Discipline VARCHAR(100) NOT NULL,
    Female INT NOT NULL DEFAULT 0,
    Male INT NOT NULL DEFAULT 0,
    Total INT NOT NULL DEFAULT 0,
    Female_Percentage DECIMAL(5,2),
    Male_Percentage DECIMAL(5,2)
)
WITH (
    DISTRIBUTION = ROUND_ROBIN,
    CLUSTERED COLUMNSTORE INDEX
);

-- =====================================================
-- Create Views for Common Queries
-- =====================================================

-- View: Top Medal Countries
CREATE VIEW dbo.vw_TopMedalCountries AS
SELECT 
    Country,
    Gold,
    Silver,
    Bronze,
    Total,
    Rank
FROM dbo.Medals
WHERE Rank <= 10;

-- View: Athletes per Country
CREATE VIEW dbo.vw_AthletesPerCountry AS
SELECT 
    Country,
    COUNT(*) AS Athlete_Count
FROM dbo.Athletes
GROUP BY Country;

-- View: Gender Parity by Discipline
CREATE VIEW dbo.vw_GenderParity AS
SELECT 
    Discipline,
    Female,
    Male,
    Total,
    Female_Percentage,
    Male_Percentage,
    CASE 
        WHEN ABS(Female - Male) = 0 THEN 'Perfect Parity'
        WHEN ABS(Female - Male) <= 5 THEN 'Near Parity'
        ELSE 'Imbalanced'
    END AS Parity_Status
FROM dbo.EntriesGender;
