CREATE DATABASE kickstarter;

SHOW DATABASES;
USE kickstarter;
DROP TABLE IF EXISTS projects;

CREATE TABLE projects (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255),
    category VARCHAR(100),
    main_category VARCHAR(100),
    currency CHAR(3),
    deadline DATETIME,
    goal DECIMAL(15,2),
    launched DATETIME,
    pledged DECIMAL(15,2),
    state VARCHAR(50),
    backers INT,
    country CHAR(2),
    usd_pledged DECIMAL(15,2)
);

ALTER TABLE projects
MODIFY currency VARCHAR(10);




TRUNCATE TABLE projects;

LOAD DATA INFILE
'C:/ProgramData/MySQL/MySQL Server 9.5/Uploads/ks-projects-201612.csv'
INTO TABLE projects
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
  @id,
  @name,
  @category,
  @main_category,
  @currency,
  @deadline,
  @goal,
  @launched,
  @pledged,
  @state,
  @backers,
  @country,
  @usd_pledged,
  @usd_goal_real   -- 👈 extra column absorbed
)
SET
  name = NULLIF(@name,''),
  category = NULLIF(@category,''),
  main_category = NULLIF(@main_category,''),
  state = NULLIF(@state,''),

  currency = LEFT(TRIM(@currency), 3),

  deadline = CASE
      WHEN @deadline REGEXP '^[0-9]{2}/[0-9]{2}/[0-9]{4}'
      THEN STR_TO_DATE(@deadline, '%d/%m/%Y %H:%i')
      ELSE NULL
  END,

  launched = CASE
      WHEN @launched REGEXP '^[0-9]{2}/[0-9]{2}/[0-9]{4}'
      THEN STR_TO_DATE(@launched, '%d/%m/%Y %H:%i')
      ELSE NULL
  END,

  goal = CASE
      WHEN @goal REGEXP '^-?[0-9]+(\\.[0-9]+)?$' THEN @goal+0
      ELSE NULL
  END,

  pledged = CASE
      WHEN @pledged REGEXP '^-?[0-9]+(\\.[0-9]+)?$' THEN @pledged+0
      ELSE NULL
  END;
  
  
/* Research Q1: Which main Kickstarter categories have the highest success rates? */

SELECT 
    main_category,
    COUNT(*) AS total_projects,
    SUM(CASE WHEN state = 'successful' THEN 1 ELSE 0 END) AS successful_projects,
    ROUND(SUM(CASE WHEN state = 'successful' THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS success_rate_percent
FROM kickstarter.projects
WHERE main_category NOT IN ('USD', 'GBP', '')  -- remove any invalid categories
GROUP BY main_category
ORDER BY success_rate_percent DESC;
;

/* Research Q2: How does a project’s funding goal affect its likelihood of success? Do smaller goals achieve success more often than larger ones? */
SELECT  
    CASE 
        WHEN goal < 10000 THEN 'Small'
        WHEN goal BETWEEN 10000 AND 50000 THEN 'Medium'
        ELSE 'Large'
    END AS goal_size,
    COUNT(*) AS total_projects,
    SUM(CASE WHEN state = 'successful' THEN 1 ELSE 0 END) AS successful_projects,
    ROUND(100.0 * SUM(CASE WHEN state = 'successful' THEN 1 ELSE 0 END) / COUNT(*), 2) AS success_rate
FROM kickstarter.projects
WHERE state NOT IN ('undefined', '109', '34', '0')
GROUP BY goal_size
ORDER BY success_rate DESC;

/* Research Q3: How has the number of successful Kickstarter projects changed over time? */

SELECT
    YEAR(launched) AS launch_year,
    CASE
        WHEN state = 'successful' THEN 'Success'
        ELSE 'Not success'
    END AS project_result,
    COUNT(*) AS total_projects
FROM kickstarter.projects
WHERE launched IS NOT NULL
GROUP BY launch_year, project_result
ORDER BY launch_year;


