-- Kickstarter Projects Database Schema
CREATE DATABASE IF NOT EXISTS kickstarter;
USE kickstarter;

CREATE TABLE projects (
    id INT PRIMARY KEY,
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
