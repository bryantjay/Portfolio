## Data sources.

### EducationLevel.csv
Table containing 5 levels of factor data describing level of education. EducationLevelID is used to connect Employee to EducationLevel (many-to-one) to describe level of employee's education.

### Employee.csv
Table of employee data with 1470 entries. Each employee has a unique EmployeeID. The table also contains each employee's first and last name, gender, age, job department, and other data that may indicate their longevity with the company. (See Metadata for full context).

### PerformanceRating.csv
Catalog of employee job satisfaction surveys / performance reviews. 6709 entries, each marked with an employee ID and a unique performance ID, which connect the PerformanceRating table to the Employee table (many-to-one). Table also contains the date of each review, the employee's self-decribed satifaction with work and personal ascpects,  employee self-rated performance, manager's rating of employee performance, and training opportunities offered to and taken by the employee.
