-- =====================================================
-- BRIGHT TV ANALYTICS PROJECT
-- =====================================================

CREATE DATABASE IF NOT EXISTS bright_tv;

USE bright_tv;


-- Total Users
SELECT COUNT(*) AS total_users
FROM bright_tv_dataset_1;


-- Gender Breakdown
SELECT
    Gender,
    COUNT(*) AS total_users,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS percentage
FROM bright_tv_dataset_1
GROUP BY Gender
ORDER BY total_users DESC;

-- Province Breakdown
SELECT
    Province,
    COUNT(*) AS total_users
FROM bright_tv_dataset_1
GROUP BY Province
ORDER BY total_users DESC;

-- Age Groups
SELECT
    CASE
        WHEN Age < 18 THEN 'Under 18'
        WHEN Age BETWEEN 18 AND 24 THEN '18-24'
        WHEN Age BETWEEN 25 AND 34 THEN '25-34'
        WHEN Age BETWEEN 35 AND 44 THEN '35-44'
        WHEN Age BETWEEN 45 AND 54 THEN '45-54'
        ELSE '55+'
    END AS age_group,
    COUNT(*) AS total_users
FROM bright_tv_dataset_1
GROUP BY
    CASE
        WHEN Age < 18 THEN 'Under 18'
        WHEN Age BETWEEN 18 AND 24 THEN '18-24'
        WHEN Age BETWEEN 25 AND 34 THEN '25-34'
        WHEN Age BETWEEN 35 AND 44 THEN '35-44'
        WHEN Age BETWEEN 45 AND 54 THEN '45-54'
        ELSE '55+'
    END
ORDER BY total_users DESC;


-- Social Media Penetration
SELECT
    COUNT(*) AS total_users,
    SUM(
        CASE
            WHEN `Social Media Handle` IS NOT NULL
            THEN 1
            ELSE 0
        END
    ) AS social_media_users,
    ROUND(
        SUM(
            CASE
                WHEN `Social Media Handle` IS NOT NULL
                THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS percentage_social_media
FROM bright_tv_dataset_1;

-- Total Viewing Records
SELECT COUNT(*) AS total_views
FROM viewership;


-- Channel Performance
SELECT
    Channel2,
    COUNT(*) AS total_views,
    COUNT(DISTINCT UserID) AS unique_viewers,
    ROUND(COUNT(*) / 60.0, 2) AS estimated_hours_watched
FROM viewership
GROUP BY Channel2
ORDER BY total_views DESC;


-- Monthly Viewership
SELECT
    DATE_FORMAT(RecordDate2, 'yyyy-MM') AS month,
    COUNT(*) AS total_views
FROM viewership
GROUP BY DATE_FORMAT(RecordDate2, 'yyyy-MM')
ORDER BY month;


-- Peak Viewing Hours
SELECT
    HOUR(RecordDate2) AS viewing_hour,
    COUNT(*) AS total_views
FROM viewership
GROUP BY HOUR(RecordDate2)
ORDER BY viewing_hour;


-- Top 10 Active Viewers
SELECT
    UserID,
    COUNT(*) AS total_sessions
FROM viewership
GROUP BY UserID
ORDER BY total_sessions DESC
LIMIT 10;

-- Viewership By Gender
SELECT
    u.Gender,
    COUNT(*) AS total_views
FROM viewership v
JOIN bright_tv_dataset_1 u
ON v.UserID = u.UserID
GROUP BY u.Gender
ORDER BY total_views DESC;


-- Viewership By Province
SELECT
    u.Province,
    COUNT(*) AS total_views
FROM viewership v
JOIN bright_tv_dataset_1 u
ON v.UserID = u.UserID
GROUP BY u.Province
ORDER BY total_views DESC;
