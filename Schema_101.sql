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
  
  


