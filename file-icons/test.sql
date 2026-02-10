CREATE TABLE employees (
    id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    department_id INTEGER REFERENCES departments(id),
    hire_date DATE DEFAULT CURRENT_DATE,
    salary NUMERIC(10, 2) CHECK (salary > 0)
);

CREATE INDEX idx_employees_department ON employees(department_id);

INSERT INTO employees (first_name, last_name, email, department_id, salary)
VALUES ('Alice', 'Johnson', 'alice@example.com', 1, 85000.00),
       ('Bob', 'Smith', 'bob@example.com', 2, 92000.00);

SELECT e.first_name, e.last_name, d.name AS department, e.salary
FROM employees e
JOIN departments d ON e.department_id = d.id
WHERE e.salary > 80000
ORDER BY e.salary DESC;
