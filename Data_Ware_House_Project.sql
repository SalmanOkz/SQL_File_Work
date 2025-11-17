-- 1. Create and use database
CREATE DATABASE HospitalDWH;
GO

USE HospitalDWH;
GO

CREATE TABLE DimHospital (
    HospitalKey     INT IDENTITY(1,1) PRIMARY KEY,
    HospitalName    NVARCHAR(100),
    City            NVARCHAR(50),
    StateProvince   NVARCHAR(50),
    Country         NVARCHAR(50)
);


CREATE TABLE DimDepartment (
    DepartmentKey   INT IDENTITY(1,1) PRIMARY KEY,
    DepartmentCode  NVARCHAR(20),
    DepartmentName  NVARCHAR(100),
    HospitalKey     INT NOT NULL,
    Floor           NVARCHAR(10),
    IsCriticalCare  BIT,
    FOREIGN KEY (HospitalKey) REFERENCES DimHospital(HospitalKey)
);

CREATE TABLE DimDoctor (
    DoctorKey       INT IDENTITY(1,1) PRIMARY KEY,
    DoctorNaturalID NVARCHAR(20),
    FirstName       NVARCHAR(50),
    LastName        NVARCHAR(50),
    Gender          CHAR(1),
    Specialization  NVARCHAR(100),
    ExperienceYears INT,
    EmploymentType  NVARCHAR(20)  -- Full-Time, Visiting, etc.
);


CREATE TABLE DimPatient (
    PatientKey      INT IDENTITY(1,1) PRIMARY KEY,
    PatientNaturalID NVARCHAR(20),
    FirstName       NVARCHAR(50),
    LastName        NVARCHAR(50),
    Gender          CHAR(1),
    DateOfBirth     DATE,
    City            NVARCHAR(50),
    StateProvince   NVARCHAR(50),
    Country         NVARCHAR(50),
    InsuranceType   NVARCHAR(50)
);

CREATE TABLE DimTime (
    TimeKey         INT PRIMARY KEY,  -- format: YYYYMMDD
    [Date]          DATE,
    [Day]           TINYINT,
    [Month]         TINYINT,
    MonthName       NVARCHAR(20),
    [Quarter]       TINYINT,
    [Year]          SMALLINT,
    IsWeekend       BIT
);

CREATE TABLE FactAdmissions (
    AdmissionID         INT IDENTITY(1,1) PRIMARY KEY,
    PatientKey          INT NOT NULL,
    DoctorKey           INT NOT NULL,
    DepartmentKey       INT NOT NULL,
    TimeKey_Admission   INT NOT NULL,
    TimeKey_Discharge   INT NULL,
    AdmissionDateTime   DATETIME,
    DischargeDateTime   DATETIME,
    DiagnosisCode       NVARCHAR(20),
    TotalCost           DECIMAL(18,2),
    RoomCharges         DECIMAL(18,2),
    MedicineCharges     DECIMAL(18,2),
    ProcedureCharges    DECIMAL(18,2),
    LengthOfStayDays    INT,
    FOREIGN KEY (PatientKey)        REFERENCES DimPatient(PatientKey),
    FOREIGN KEY (DoctorKey)         REFERENCES DimDoctor(DoctorKey),
    FOREIGN KEY (DepartmentKey)     REFERENCES DimDepartment(DepartmentKey),
    FOREIGN KEY (TimeKey_Admission) REFERENCES DimTime(TimeKey),
    FOREIGN KEY (TimeKey_Discharge) REFERENCES DimTime(TimeKey)
);
select * from FactAdmissions

CREATE TABLE FactBilling (
    BillingID           INT IDENTITY(1,1) PRIMARY KEY,
    PatientKey          INT NOT NULL,
    DoctorKey           INT NOT NULL,
    DepartmentKey       INT NOT NULL,
    TimeKey_Billing     INT NOT NULL,
    TotalBilledAmount   DECIMAL(18,2),
    AmountPaid          DECIMAL(18,2),
    InsuranceCovered    DECIMAL(18,2),
    OutOfPocketAmount   DECIMAL(18,2),
    PaymentStatus       NVARCHAR(20),  -- Paid / Partial / Pending
    FOREIGN KEY (PatientKey)      REFERENCES DimPatient(PatientKey),
    FOREIGN KEY (DoctorKey)       REFERENCES DimDoctor(DoctorKey),
    FOREIGN KEY (DepartmentKey)   REFERENCES DimDepartment(DepartmentKey),
    FOREIGN KEY (TimeKey_Billing) REFERENCES DimTime(TimeKey)
);
-- inserting in hospital table
INSERT INTO DimHospital (HospitalName, City, StateProvince, Country)
VALUES
('Central City Hospital', 'Central City', 'Sindh', 'Pakistan'),
('Northside Medical Center', 'North City', 'Punjab', 'Pakistan');
-- inserting in department table 
INSERT INTO DimDepartment (DepartmentCode, DepartmentName, HospitalKey, Floor, IsCriticalCare)
VALUES
('CARD', 'Cardiology', 1, '2nd', 1),
('NEUR', 'Neurology', 1, '3rd', 0),
('ORTH', 'Orthopedics', 1, '4th', 0),
('EMER', 'Emergency', 2, 'Ground', 1);
-- inserting in doctor table
INSERT INTO DimDoctor (DoctorNaturalID, FirstName, LastName, Gender, Specialization, ExperienceYears, EmploymentType)
VALUES
('DOC001', 'Ali',     'Khan',   'M', 'Cardiologist',      10, 'Full-Time'),
('DOC002', 'Sara',    'Malik',  'F', 'Neurologist',        8, 'Full-Time'),
('DOC003', 'Imran',   'Sheikh', 'M', 'Orthopedic Surgeon',12, 'Visiting'),
('DOC004', 'Nida',    'Ahmed',  'F', 'Emergency Physician',6, 'Full-Time');
-- inserting in patient table 
INSERT INTO DimPatient (PatientNaturalID, FirstName, LastName, Gender, DateOfBirth, City, StateProvince, Country, InsuranceType)
VALUES
('PAT001', 'Hassan',  'Raza',   'M', '1980-05-12', 'Karachi', 'Sindh', 'Pakistan', 'Private'),
('PAT002', 'Ayesha',  'Ali',    'F', '1990-09-20', 'Lahore',  'Punjab', 'Pakistan', 'Government'),
('PAT003', 'Bilal',   'Khan',   'M', '1975-02-10', 'Karachi', 'Sindh', 'Pakistan', 'Private'),
('PAT004', 'Sana',    'Iqbal',  'F', '1988-12-01', 'Islamabad','ICT',  'Pakistan', 'Private'),
('PAT005', 'Zain',    'Akhtar', 'M', '2000-07-07', 'Karachi', 'Sindh', 'Pakistan', 'None');
-- time dimention table
INSERT INTO DimTime (TimeKey, [Date], [Day], [Month], MonthName, [Quarter], [Year], IsWeekend)
VALUES
(20250101, '2025-01-01', 1, 1, 'January', 1, 2025, 0),
(20250102, '2025-01-02', 2, 1, 'January', 1, 2025, 0),
(20250103, '2025-01-03', 3, 1, 'January', 1, 2025, 0),
(20250104, '2025-01-04', 4, 1, 'January', 1, 2025, 1),
(20250105, '2025-01-05', 5, 1, 'January', 1, 2025, 1),
(20250106, '2025-01-06', 6, 1, 'January', 1, 2025, 0);


--insert into fact table
INSERT INTO FactAdmissions (
    PatientKey, DoctorKey, DepartmentKey,
    TimeKey_Admission, TimeKey_Discharge,
    AdmissionDateTime, DischargeDateTime,
    DiagnosisCode, TotalCost, RoomCharges, MedicineCharges, ProcedureCharges, LengthOfStayDays
)
VALUES
(1, 1, 1, 20250101, 20250103, '2025-01-01 10:00', '2025-01-03 09:00', 'D-CARD-01', 50000, 20000, 10000, 20000, 2),
(2, 2, 2, 20250102, 20250104, '2025-01-02 11:00', '2025-01-04 10:00', 'D-NEUR-01', 40000, 18000, 8000, 14000, 2),
(3, 1, 1, 20250103, 20250105, '2025-01-03 14:00', '2025-01-05 12:00', 'D-CARD-02', 65000, 25000, 12000, 28000, 2),
(4, 3, 3, 20250101, 20250102, '2025-01-01 09:00', '2025-01-02 18:00', 'D-ORTH-01', 30000, 12000, 5000, 13000, 1),
(5, 4, 4, 20250104, 20250104, '2025-01-04 02:00', '2025-01-04 20:00', 'D-EMER-01', 15000, 5000, 4000, 6000, 0),
(1, 2, 2, 20250105, 20250106, '2025-01-05 08:00', '2025-01-06 10:00', 'D-NEUR-02', 38000, 15000, 8000, 15000, 1),
(2, 1, 1, 20250103, 20250106, '2025-01-03 20:00', '2025-01-06 09:00', 'D-CARD-03', 72000, 30000, 15000, 27000, 3),
(3, 4, 4, 20250102, 20250102, '2025-01-02 05:00', '2025-01-02 23:00', 'D-EMER-02', 12000, 4000, 3000, 5000, 0),
(4, 1, 1, 20250106, 20250106, '2025-01-06 07:00', '2025-01-06 17:00', 'D-CARD-04', 22000, 9000, 4000, 9000, 0),
(5, 3, 3, 20250105, 20250106, '2025-01-05 13:00', '2025-01-06 15:00', 'D-ORTH-02', 27000, 10000, 5000, 12000, 1);

-- insert into factbilling table
INSERT INTO FactBilling (
    PatientKey, DoctorKey, DepartmentKey, TimeKey_Billing,
    TotalBilledAmount, AmountPaid, InsuranceCovered, OutOfPocketAmount, PaymentStatus
)
VALUES
(1, 1, 1, 20250103, 50000, 50000, 35000, 15000, 'Paid'),
(2, 2, 2, 20250104, 40000, 35000, 25000, 15000, 'Partial'),
(3, 1, 1, 20250105, 65000, 65000, 40000, 25000, 'Paid'),
(4, 3, 3, 20250102, 30000, 30000, 20000, 10000, 'Paid'),
(5, 4, 4, 20250104, 15000, 10000, 5000, 10000, 'Partial'),
(1, 2, 2, 20250106, 38000, 38000, 25000, 13000, 'Paid'),
(2, 1, 1, 20250106, 72000, 60000, 40000, 32000, 'Partial'),
(3, 4, 4, 20250102, 12000, 12000, 7000, 5000, 'Paid');

-- All the select quries 
-- inner join
SELECT 
    d.DepartmentName,
    t.[Year],
    SUM(f.TotalCost) AS TotalCost
FROM FactAdmissions f
JOIN DimDepartment d ON f.DepartmentKey = d.DepartmentKey
JOIN DimTime t ON f.TimeKey_Admission = t.TimeKey
GROUP BY ROLLUP (d.DepartmentName, t.[Year])
ORDER BY d.DepartmentName, t.[Year];

SELECT TOP 3
    doc.DoctorKey,
    doc.FirstName,
    doc.LastName,
    SUM(f.TotalCost) AS TotalRevenue
FROM FactAdmissions f
JOIN DimDoctor doc ON f.DoctorKey = doc.DoctorKey
GROUP BY doc.DoctorKey, doc.FirstName, doc.LastName
ORDER BY TotalRevenue DESC;

SELECT
    d.DepartmentName,
    f.AdmissionID,
    f.LengthOfStayDays,
    AVG(f.LengthOfStayDays) OVER (PARTITION BY d.DepartmentName) AS AvgStayDept,
    MIN(f.LengthOfStayDays) OVER (PARTITION BY d.DepartmentName) AS MinStayDept,
    MAX(f.LengthOfStayDays) OVER (PARTITION BY d.DepartmentName) AS MaxStayDept,
    COUNT(*) OVER (PARTITION BY d.DepartmentName) AS AdmissionCountDept
FROM FactAdmissions f
JOIN DimDepartment d ON f.DepartmentKey = d.DepartmentKey
ORDER BY d.DepartmentName, f.AdmissionID;



SELECT
    p.PatientKey,
    p.FirstName,
    p.LastName,
    t.[Date] AS AdmissionDate,
    FIRST_VALUE(t.[Date]) OVER (
        PARTITION BY p.PatientKey
        ORDER BY t.[Date]
    ) AS FirstAdmissionDate,
    LAST_VALUE(t.[Date]) OVER (
        PARTITION BY p.PatientKey
        ORDER BY t.[Date]
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS LastAdmissionDate
FROM FactAdmissions f
JOIN DimPatient p ON f.PatientKey = p.PatientKey
JOIN DimTime t ON f.TimeKey_Admission = t.TimeKey
ORDER BY p.PatientKey, t.[Date];



-- sub query
select PatientKey,DoctorKey,TotalCost
    from FactAdmissions b
    where TotalCost in (
    select max(a.TotalCost) as total_cost
        from FactAdmissions a
        where a.AdmissionID = b.AdmissionID
        group by
            a.AdmissionID
    
    )
    order by
        PatientKey,DoctorKey

