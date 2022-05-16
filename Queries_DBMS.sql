delimiter $$
create procedure Queries_01()
begin 
SELECT C.* , CL.* , V.* FROM T7_CUSTOMER C
INNER JOIN T7_CLAIM CL
ON C.T7_Cust_Id = CL.T7_Cust_Id
INNER JOIN T7_VEHICLE V
ON CL.T7_VEHICLE_Id = V.T7_VEHICLE_Id
INNER JOIN T7_INCIDENT I
ON I.T7_VEHICLE_Id = V.T7_VEHICLE_Id
WHERE CL.T7_Claim_Status = 'Pending';
end; $$

delimiter $$
create procedure Queries_02()
begin 
SELECT C.*, P.T7_Premium_Payment_Amount FROM T7_CUSTOMER C
INNER JOIN T7_PREMIUM_PAYMENT P
ON C.T7_Cust_Id = P.T7_Cust_Id 
HAVING P.T7_Premium_Payment_Amount > (SELECT SUM(C.T7_Cust_Id) FROM T7_CUSTOMER C);
end; $$

delimiter $$
create procedure Queries_03()
begin 
SELECT * FROM T7_INSURANCE_COMPANY 
WHERE T7_Company_Name IN
	(SELECT T1.T7_Company_Name 
	FROM (SELECT T7_Company_Name, COUNT(T7_Company_Name) AS C1 FROM T7_PRODUCT GROUP BY T7_Company_Name) AS T1
	INNER JOIN   	
	(SELECT T7_Company_Name, COUNT(T7_Company_Name) AS C2 FROM T7_DEPARTMENT GROUP BY T7_Company_Name) AS T2
	ON T1.T7_Company_Name = T2.T7_Company_Name
	WHERE T1.C1 > T2.C2) 
AND 
T7_Company_Name IN
(SELECT T7_Company_Name FROM T7_OFFICE GROUP BY T7_Company_Name HAVING GROUP_CONCAT(DISTINCT T7_Address) LIKE '%,%');
end; $$

delimiter $$
create procedure Queries_04()
begin 
SELECT * FROM T7_CUSTOMER
WHERE T7_Cust_Id IN 
(SELECT T7_Cust_Id FROM T7_VEHICLE GROUP BY T7_Cust_Id HAVING COUNT(*) > 1)
AND T7_Cust_Id IN
(SELECT T7_Cust_Id from T7_PREMIUM_PAYMENT WHERE ifnull(T7_Premium_Payment_Amount, 0) = 0)
AND T7_Cust_Id IN
(SELECT T7_Cust_Id from T7_INCIDENT_REPORT
WHERE T7_Incident_Type = 'accident');
end; $$

delimiter $$
create procedure Queries_05()
begin 
SELECT * FROM T7_VEHICLE V
INNER JOIN T7_PREMIUM_PAYMENT P
ON V.T7_Policy_Number = P.T7_Policy_Number
WHERE P.T7_Premium_Payment_Amount > V.T7_Vehicle_Number;
end; $$

delimiter $$
create procedure Queries_06()
begin 
SELECT * FROM T7_CUSTOMER
WHERE T7_Cust_Id IN (SELECT T7_Cust_Id FROM (SELECT C.T7_Claim_Id, C.T7_Cust_Id , CS.T7_Coverage_Id FROM T7_CLAIM C
INNER JOIN T7_CLAIM_SETTLEMENT CS
ON C.T7_Claim_Id = CS.T7_Claim_Id
INNER JOIN T7_COVERAGE CV
ON CS.T7_Coverage_Id = CV.T7_Coverage_Id
WHERE (C.T7_Claim_Amount < CV.T7_Coverage_Amount)
AND (C.T7_Claim_Amount > CS.T7_Claim_Settlement_Id + CS.T7_Claim_Id + CS.T7_Cust_Id + CS.T7_Vehicle_Id)) AS T);
end; $$

CALL Queries_01;
CALL Queries_02;t7_claim_settlement
CALL Queries_03;
CALL Queries_04;
CALL Queries_05;t7_insurance_policy
CALL Queries_06;