CREATE TABLE REGIONS (
    region_id INT PRIMARY KEY,
    region_name VARCHAR(50)
);

CREATE TABLE COUNTRIES (
    country_id CHAR(2) PRIMARY KEY,
    country_name VARCHAR(50),
    region_id INT,
    FOREIGN KEY (region_id) REFERENCES REGIONS(region_id)
);

CREATE TABLE LOCATIONS (
    location_id INT PRIMARY KEY,
    street_address VARCHAR(150),
    postal_code VARCHAR(20),
    city VARCHAR(50),
    state_province VARCHAR(50),
    country_id CHAR(2),
    FOREIGN KEY (country_id) REFERENCES COUNTRIES(country_id)
);

CREATE TABLE DEPARTMENTS (
    department_id INT PRIMARY KEY,
    department_name VARCHAR(100) NOT NULL,
    manager_id INT,
    location_id INT,
);

CREATE TABLE JOBS (
    job_id VARCHAR(10) PRIMARY KEY,
    job_title VARCHAR(100),
    min_salary INT,
    max_salary INT,
    CHECK (min_salary < max_salary AND min_salary >= 2000)
);

CREATE TABLE EMPLOYEES (
    employee_id INT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100),
    phone_number VARCHAR(20),
    hire_date DATE,
    job_id VARCHAR(10),
    salary INT,
    commission_pct DECIMAL(5,2),
    manager_id INT,
    department_id INT,
    FOREIGN KEY (job_id) REFERENCES JOBS(job_id),
    FOREIGN KEY (manager_id) REFERENCES EMPLOYEES(employee_id),
    FOREIGN KEY (department_id) REFERENCES DEPARTMENTS(department_id)
);

CREATE TABLE JOB_HISTORY (
    employee_id INT,
    start_date DATE,
    end_date DATE,
    job_id VARCHAR(10),
    department_id INT,
    PRIMARY KEY (employee_id, start_date),
    FOREIGN KEY (employee_id) REFERENCES EMPLOYEES(employee_id),
    FOREIGN KEY (job_id) REFERENCES JOBS(job_id),
    FOREIGN KEY (department_id) REFERENCES DEPARTMENTS(department_id)
);

ALTER TABLE DEPARTMENTS
ADD CONSTRAINT FK_DEPT_MANAGER FOREIGN KEY (manager_id) REFERENCES EMPLOYEES(employee_id);


INSERT INTO JOBS VALUES ('J01', 'Sales Manager', 3000, 8000);
INSERT INTO JOBS VALUES ('J02', 'IT Specialist', 3500, 9000);
INSERT INTO JOBS VALUES ('J03', 'HR Assistant', 2500, 6000);
INSERT INTO JOBS VALUES ('J04', 'Business Analyst', 4000, 10000);

INSERT INTO EMPLOYEES VALUES 
(1, 'Anna', 'Kowalska', 'anna.k@email.com', '123456789', GETDATE(), 'J01', 5000, NULL, NULL, 1),
(2, 'Piotr', 'Nowak', 'piotr.n@email.com', '987654321', GETDATE(), 'J02', 6000, NULL, 1, 1),
(3, 'Kasia', 'Wiśniewska', 'kasia.w@email.com', '555666777', GETDATE(), 'J03', 5500, NULL, 2, 1),
(4, 'Tomasz', 'Lewandowski', 'tomasz.l@email.com', '444333222', GETDATE(), 'J04', 7000, NULL, 2, 1);

UPDATE EMPLOYEES SET manager_id = 1 WHERE manager_id IN (2, 3);

UPDATE JOBS
SET min_salary = min_salary + 500,
    max_salary = max_salary + 500
WHERE LOWER(job_title) LIKE '%b%' OR LOWER(job_title) LIKE '%s%';

DELETE FROM EMPLOYEES;
DELETE FROM JOBS
WHERE max_salary > 9000;

-- DELETE FOREIGN KEY FROM COUNTRIES
-- ALTER TABLE COUNTRIES DROP CONSTRAINT COUNTRIES_FK_ID
BEGIN TRANSACTION;	
DROP TABLE REGIONS;
ROLLBACK;
