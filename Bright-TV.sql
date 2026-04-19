/*
asasa

asas

asaas

*/

-- BRIGHT TV - DATABRICKS ANALYTICAL SQL QUERIES
--------------------------------------------------------------
 
CREATE DATABASE IF NOT EXISTS bright_tv;
USE bright_tv;
 
-- Drop and recreate tables
DROP TABLE IF EXISTS bright_tv.user_profiles;
DROP TABLE IF EXISTS bright_tv.viewership;
 
CREATE TABLE bright_tv.user_profiles (
  user_id              BIGINT,
  name                 STRING,
  surname              STRING,
  email                STRING,
  gender               STRING,
  race                 STRING,
  age                  INT,
  province             STRING,
  social_media_handle  STRING
) USING DELTA;
 
CREATE TABLE bright_tv.viewership (
  user_id          BIGINT,
  channel          STRING,
  record_date      TIMESTAMP,
  duration_seconds INT,
  userid_alt       BIGINT
) USING DELTA;
 
-- Check row counts
SELECT 'user_profiles' AS table_name, COUNT(*) AS row_count FROM bright_tv.user_profiles
UNION ALL
SELECT 'viewership',                   COUNT(*)               FROM bright_tv.viewership;
 
SELECT * FROM bright_tv.user_profiles LIMIT 10;
 
SELECT * FROM bright_tv.viewership LIMIT 10;
 
 
-- ============================================================
-- STEP 3: USER PROFILE ANALYSIS
-- ============================================================
 
-- 3A: Total number of registered users
SELECT COUNT(*) AS total_users
FROM bright_tv.user_profiles;
 
-- 3B: User breakdown by gender
SELECT
  COALESCE(NULLIF(TRIM(gender), ''), 'Unknown') AS gender,
  COUNT(*)                                        AS user_count,
  ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS pct
FROM bright_tv.user_profiles
GROUP BY gender
ORDER BY user_count DESC;
 
-- 3C: User breakdown by race
SELECT
  COALESCE(NULLIF(TRIM(race), ''), 'Unknown') AS race,
  COUNT(*)                                     AS user_count,
  ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS pct
FROM bright_tv.user_profiles
GROUP BY race
ORDER BY user_count DESC;
 
-- 3D: User breakdown by province
SELECT
  COALESCE(NULLIF(TRIM(province), ''), 'Unknown') AS province,
  COUNT(*)                                          AS user_count,
  ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS pct
FROM bright_tv.user_profiles
GROUP BY province
ORDER BY user_count DESC;
 
-- 3E: Age distribution (grouped into brackets)
SELECT
  CASE
    WHEN age BETWEEN 0  AND 17 THEN 'Under 18'
    WHEN age BETWEEN 18 AND 24 THEN '18-24'
    WHEN age BETWEEN 25 AND 34 THEN '25-34'
    WHEN age BETWEEN 35 AND 44 THEN '35-44'
    WHEN age BETWEEN 45 AND 54 THEN '45-54'
    WHEN age BETWEEN 55 AND 64 THEN '55-64'
    ELSE '65+'
  END AS age_group,
  COUNT(*) AS user_count
FROM bright_tv.user_profiles
GROUP BY age_group
ORDER BY age_group;
 
-- 3F: Average age by gender
SELECT
  COALESCE(NULLIF(TRIM(gender), ''), 'Unknown') AS gender,
  ROUND(AVG(age), 1)                             AS avg_age,
  MIN(age)                                       AS min_age,
  MAX(age)                                       AS max_age
FROM bright_tv.user_profiles
GROUP BY gender;
 
-- 3G: Average age by province
SELECT
  COALESCE(NULLIF(TRIM(province), ''), 'Unknown') AS province,
  ROUND(AVG(age), 1)                               AS avg_age,
  COUNT(*)                                          AS user_count
FROM bright_tv.user_profiles
GROUP BY province
ORDER BY avg_age DESC;
 
-- 3H: Users with social media handles (social media penetration)
SELECT
  COUNT(*)                                                              AS total_users,
  SUM(CASE WHEN social_media_handle IS NOT NULL THEN 1 ELSE 0 END)     AS has_social_media,
  ROUND(SUM(CASE WHEN social_media_handle IS NOT NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS pct_with_social_media
FROM bright_tv.user_profiles;
 
-- 3I: Full user profile list (all columns)
SELECT
  user_id,
  name,
  surname,
  email,
  gender,
  race,
  age,
  province,
  social_media_handle
FROM bright_tv.user_profiles
ORDER BY user_id;
 
-- STEP 4: VIEWERSHIP ANALYSIS
 
-- 4A: Total viewing records
SELECT COUNT(*) AS total_viewing_records FROM bright_tv.viewership;
 
SELECT
  channel,
  COUNT(*)                                    AS total_views,
  COUNT(DISTINCT user_id)                     AS unique_viewers,
  SUM(duration_seconds)                       AS total_seconds_watched,
  ROUND(SUM(duration_seconds) / 3600.0, 2)   AS total_hours_watched,
  ROUND(AVG(duration_seconds), 0)             AS avg_seconds_per_view
FROM bright_tv.viewership
GROUP BY channel
ORDER BY total_views DESC;
 
-- 4C: Viewership by month
SELECT
  DATE_FORMAT(record_date, 'yyyy-MM') AS month,
  COUNT(*)                             AS total_views,
  COUNT(DISTINCT user_id)              AS unique_viewers,
  ROUND(SUM(duration_seconds) / 3600.0, 2) AS total_hours_watched
FROM bright_tv.viewership
GROUP BY month
ORDER BY month;
 
-- 4D: Viewership by day of week
SELECT
  DATE_FORMAT(record_date, 'EEEE') AS day_of_week,
  COUNT(*)                          AS total_views,
  ROUND(AVG(duration_seconds), 0)  AS avg_duration_seconds
FROM bright_tv.viewership
GROUP BY day_of_week
ORDER BY total_views DESC;
 
-- 4E: Viewership by hour of day (peak viewing times)
SELECT
  HOUR(record_date)               AS hour_of_day,
  COUNT(*)                        AS total_views,
  ROUND(AVG(duration_seconds), 0) AS avg_duration_seconds
FROM bright_tv.viewership
GROUP BY hour_of_day
ORDER BY hour_of_day;
 
-- 4F: Top 10 most active viewers
SELECT
  user_id,
  COUNT(*)                              AS total_sessions,
  COUNT(DISTINCT channel)               AS channels_watched,
  SUM(duration_seconds)                 AS total_seconds_watched,
  ROUND(SUM(duration_seconds) / 3600.0, 2) AS total_hours_watched
FROM bright_tv.viewership
GROUP BY user_id
ORDER BY total_hours_watched DESC
LIMIT 10;
 
 
-- 5A: Viewership by gender
SELECT
  COALESCE(NULLIF(TRIM(u.gender), ''), 'Unknown') AS gender,
  COUNT(v.user_id)                                 AS total_views,
  COUNT(DISTINCT v.user_id)                        AS unique_viewers,
  ROUND(AVG(v.duration_seconds), 0)               AS avg_duration_seconds,
  ROUND(SUM(v.duration_seconds) / 3600.0, 2)      AS total_hours_watched
FROM bright_tv.viewership v
JOIN bright_tv.user_profiles u ON v.user_id = u.user_id
GROUP BY gender
ORDER BY total_views DESC;
 
-- 5B: Viewership by province
SELECT
  COALESCE(NULLIF(TRIM(u.province), ''), 'Unknown') AS province,
  COUNT(v.user_id)                                    AS total_views,
  COUNT(DISTINCT v.user_id)                           AS unique_viewers,
  ROUND(SUM(v.duration_seconds) / 3600.0, 2)         AS total_hours_watched
FROM bright_tv.viewership v
JOIN bright_tv.user_profiles u ON v.user_id = u.user_id
GROUP BY province
ORDER BY total_views DESC;
 
-- 5C: Viewership by race
SELECT
  COALESCE(NULLIF(TRIM(u.race), ''), 'Unknown') AS race,
  COUNT(v.user_id)                               AS total_views,
  COUNT(DISTINCT v.user_id)                      AS unique_viewers,
  ROUND(AVG(v.duration_seconds), 0)             AS avg_duration_seconds,
  ROUND(SUM(v.duration_seconds) / 3600.0, 2)    AS total_hours_watched
FROM bright_tv.viewership v
JOIN bright_tv.user_profiles u ON v.user_id = u.user_id
GROUP BY race
ORDER BY total_views DESC;
 
-- 5D: Viewership by age group
SELECT
  CASE
    WHEN u.age BETWEEN 0  AND 17 THEN 'Under 18'
    WHEN u.age BETWEEN 18 AND 24 THEN '18-24'
    WHEN u.age BETWEEN 25 AND 34 THEN '25-34'
    WHEN u.age BETWEEN 35 AND 44 THEN '35-44'
    WHEN u.age BETWEEN 45 AND 54 THEN '45-54'
    WHEN u.age BETWEEN 55 AND 64 THEN '55-64'
    ELSE '65+'
  END AS age_group,
  COUNT(v.user_id)                            AS total_views,
  COUNT(DISTINCT v.user_id)                   AS unique_viewers,
  ROUND(AVG(v.duration_seconds), 0)           AS avg_duration_seconds,
  ROUND(SUM(v.duration_seconds) / 3600.0, 2) AS total_hours_watched
FROM bright_tv.viewership v
JOIN bright_tv.user_profiles u ON v.user_id = u.user_id
GROUP BY age_group
ORDER BY age_group;
 
-- 5E: Most popular channel per province
SELECT
  province,
  channel,
  total_views
FROM (
  SELECT
    COALESCE(NULLIF(TRIM(u.province), ''), 'Unknown') AS province,
    v.channel,
    COUNT(*) AS total_views,
    ROW_NUMBER() OVER (
      PARTITION BY COALESCE(NULLIF(TRIM(u.province), ''), 'Unknown')
      ORDER BY COUNT(*) DESC
    ) AS rn
  FROM bright_tv.viewership v
  JOIN bright_tv.user_profiles u ON v.user_id = u.user_id
  GROUP BY province, channel
) ranked
WHERE rn = 1
ORDER BY province;
 
-- 5F: Most popular channel per gender
SELECT
  gender,
  channel,
  total_views
FROM (
  SELECT
    COALESCE(NULLIF(TRIM(u.gender), ''), 'Unknown') AS gender,
    v.channel,
    COUNT(*) AS total_views,
    ROW_NUMBER() OVER (
      PARTITION BY COALESCE(NULLIF(TRIM(u.gender), ''), 'Unknown')
      ORDER BY COUNT(*) DESC
    ) AS rn
  FROM bright_tv.viewership v
  JOIN bright_tv.user_profiles u ON v.user_id = u.user_id
  GROUP BY gender, channel
) ranked
WHERE rn = 1
ORDER BY gender;
 
-- 5G: Most popular channel by age group
SELECT
  age_group,
  channel,
  total_views
FROM (
  SELECT
    CASE
      WHEN u.age BETWEEN 0  AND 17 THEN 'Under 18'
      WHEN u.age BETWEEN 18 AND 24 THEN '18-24'
      WHEN u.age BETWEEN 25 AND 34 THEN '25-34'
      WHEN u.age BETWEEN 35 AND 44 THEN '35-44'
      WHEN u.age BETWEEN 45 AND 54 THEN '45-54'
      WHEN u.age BETWEEN 55 AND 64 THEN '55-64'
      ELSE '65+'
    END AS age_group,
    v.channel,
    COUNT(*) AS total_views,
    ROW_NUMBER() OVER (
      PARTITION BY CASE
        WHEN u.age BETWEEN 0  AND 17 THEN 'Under 18'
        WHEN u.age BETWEEN 18 AND 24 THEN '18-24'
        WHEN u.age BETWEEN 25 AND 34 THEN '25-34'
        WHEN u.age BETWEEN 35 AND 44 THEN '35-44'
        WHEN u.age BETWEEN 45 AND 54 THEN '45-54'
        WHEN u.age BETWEEN 55 AND 64 THEN '55-64'
        ELSE '65+'
      END
      ORDER BY COUNT(*) DESC
    ) AS rn
  FROM bright_tv.viewership v
  JOIN bright_tv.user_profiles u ON v.user_id = u.user_id
  GROUP BY age_group, channel
) ranked
WHERE rn = 1
ORDER BY age_group;
 
-- 5H: Full joined dataset — user details + all their viewing records
SELECT
  u.user_id,
  u.name,
  u.surname,
  u.email,
  u.gender,
  u.race,
  u.age,
  u.province,
  u.social_media_handle,
  v.channel,
  v.record_date,
  v.duration_seconds,
  ROUND(v.duration_seconds / 60.0, 2) AS duration_minutes
FROM bright_tv.user_profiles u
LEFT JOIN bright_tv.viewership v ON u.user_id = v.user_id
ORDER BY u.user_id, v.record_date;
 
-- 5I: Users who have NOT watched anything (registered but no viewership record)
SELECT
  u.user_id,
  u.name,
  u.surname,
  u.email,
  u.province
FROM bright_tv.user_profiles u
LEFT JOIN bright_tv.viewership v ON u.user_id = v.user_id
WHERE v.user_id IS NULL
ORDER BY u.user_id;
 
-- 6A: Overall KPI summary
SELECT
  (SELECT COUNT(*)               FROM bright_tv.user_profiles)                        AS total_users,
  (SELECT COUNT(*)               FROM bright_tv.viewership)                           AS total_viewing_sessions,
  (SELECT COUNT(DISTINCT user_id)FROM bright_tv.viewership)                           AS users_who_watched,
  (SELECT COUNT(DISTINCT channel)FROM bright_tv.viewership)                           AS total_channels,
  (SELECT ROUND(SUM(duration_seconds)/3600.0, 2) FROM bright_tv.viewership)          AS total_hours_watched,
  (SELECT ROUND(AVG(duration_seconds)/60.0, 2)   FROM bright_tv.viewership)          AS avg_session_minutes;
