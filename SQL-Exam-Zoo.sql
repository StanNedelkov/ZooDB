CREATE DATABASE Zoo
USE Zoo

--Database design
CREATE TABLE Owners
(
	Id INT PRIMARY KEY IDENTITY
	,[Name] VARCHAR (50) NOT NULL
	,PhoneNumber VARCHAR (15) NOT NULL
	,[Address] VARCHAR (50) 
)

CREATE TABLE AnimalTypes
(
	Id INT PRIMARY KEY IDENTITY
	,AnimalType VARCHAR (30) NOT NULL
)

CREATE TABLE Cages
(
	Id INT PRIMARY KEY IDENTITY
	,AnimalTypeId INT NOT NULL FOREIGN KEY REFERENCES AnimalTypes(Id)
)

CREATE TABLE Animals
(
	Id INT PRIMARY KEY IDENTITY
	,[Name] VARCHAR (30) NOT NULL
	,BirthDate DATE NOT NULL
	,OwnerId INT FOREIGN KEY REFERENCES Owners (Id)
	,AnimalTypeId INT NOT NULL FOREIGN KEY REFERENCES AnimalTypes(Id)
)

CREATE TABLE AnimalsCages
(
	CageId INT NOT NULL FOREIGN KEY REFERENCES Cages (Id)
	,AnimalId INT NOT NULL FOREIGN KEY REFERENCES Animals(Id)
	,PRIMARY KEY(CageId, AnimalId)
)

CREATE TABLE VolunteersDepartments
(
	Id INT PRIMARY KEY IDENTITY
	,DepartmentName VARCHAR (30) NOT NULL
)

CREATE TABLE Volunteers
(
	Id INT PRIMARY KEY IDENTITY
	,[Name] VARCHAR (50) NOT NULL
	,PhoneNumber VARCHAR (15) NOT NULL
	,[Address] VARCHAR (50) 
	,AnimalId INT FOREIGN KEY REFERENCES Animals(Id)
	,DepartmentId INT NOT NULL FOREIGN KEY REFERENCES VolunteersDepartments (Id)
)
--2. Insert
INSERT INTO Volunteers([Name], PhoneNumber, [Address], AnimalId, DepartmentId)
VALUES
('Anita Kostova','0896365412','Sofia, 5 Rosa str.',15,1)
,('Dimitur Stoev','0877564223',null,42,4)
,('Kalina Evtimova','0896321112','Silistra, 21 Breza str.',9,7)
,('Stoyan Tomov','0898564100','Montana, 1 Bor str.',18,8)
,('Boryana Mileva','0888112233',null,31,5)

INSERT INTO Animals([Name],	BirthDate, OwnerId, AnimalTypeId)
VALUES
('Giraffe','2018-09-21',21,1)
,('Harpy Eagle','2015-04-17',15,3)
,('Hamadryas Baboon','2017-11-02',null,1)
,('Tuatara','2021-06-30',2,4)

--3. Update
UPDATE Animals
SET OwnerId = 4
WHERE OwnerId IS NULL

--4. Delete
DELETE FROM Volunteers
WHERE DepartmentId = 2
DELETE FROM VolunteersDepartments
WHERE Id = 2

--5. Information
SELECT
[Name]
,PhoneNumber
,[Address]
,AnimalId
,DepartmentId
FROM Volunteers
ORDER BY [Name] ASC, AnimalId ASC, DepartmentId ASC

SELECT 
a.[Name]
,aa.AnimalType
,FORMAT(a.BirthDate,'dd.MM.yyyy') AS BirthDate
FROM Animals AS a
LEFT JOIN AnimalTypes AS aa
ON(a.AnimalTypeId = aa.Id)
ORDER BY a.[Name] ASC

SELECT TOP 5
o.[Name]
,COUNT(*) AS CountOfAnimals
FROM Animals AS a
LEFT JOIN Owners AS o
ON(o.Id = a.OwnerId)
WHERE o.[Name] IS NOT NULL
GROUP BY o.[Name] 
ORDER BY CountOfAnimals DESC

SELECT 
CONCAT(o.[Name],'-',a.[Name]) AS OwnersAnimals
,o.PhoneNumber
,ag.CageId
FROM Owners AS o
JOIN Animals AS a
ON(o.Id = a.OwnerId)
JOIN AnimalsCages AS ag
ON(a.Id = ag.AnimalId)
WHERE a.AnimalTypeId = 1
ORDER BY o.[Name] ASC, a.[Name] DESC

SELECT 
v.[Name]
,v.PhoneNumber
,REPLACE(REPLACE(v.[Address],'Sofia, ',''),' Sofia , ','') AS [Address]
FROM Volunteers AS v
JOIN VolunteersDepartments AS vd
ON(v.DepartmentId = vd.Id)
WHERE vd.DepartmentName = 'Education program assistant' AND v.Address LIKE '%Sofia%'
ORDER BY v.[Name] ASC

SELECT
a.[Name]
,FORMAT(a.BirthDate,'yyyy') AS BirthYear
,aa.AnimalType
FROM Animals AS a
JOIN AnimalTypes AS aa
ON(a.AnimalTypeId = aa.Id)
WHERE a.OwnerId IS NULL AND aa.AnimalType != 'Birds' AND a.BirthDate >'2018-01-01'
ORDER BY a.[Name]

--Functions and procedures
GO
CREATE FUNCTION udf_GetVolunteersCountFromADepartment (@VolunteersDepartment VARCHAR (50))
RETURNS INT AS
BEGIN
	DECLARE @res INT = (
	SELECT 
	COUNT(*)
	FROM Volunteers AS v
	WHERE v.DepartmentId IN (
	SELECT Id FROM VolunteersDepartments
	WHERE DepartmentName =@VolunteersDepartment))
	RETURN @res
END

GO
CREATE PROC usp_AnimalsWithOwnersOrNot(@AnimalName VARCHAR(30))
AS
BEGIN
	SELECT 
	a.[Name]
	,CASE
		WHEN o.[Name] IS NULL THEN 'For adoption'
		ELSE o.[Name]
	END AS OwnersName
	FROM Animals AS a
	LEFT JOIN Owners AS o
	ON (a.OwnerId = o.Id)
	WHERE a.[Name] = @AnimalName
END