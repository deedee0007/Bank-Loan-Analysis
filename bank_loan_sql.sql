	Use Finance;

	SELECT * FROM bank_loan;

	--Total loan apllication 

	SELECT COUNT(id) as Total_Loan_Application FROM bank_loan;

	--Month to date total application

	SELECT COUNT(id) as MTD_Total_Loan_Application FROM bank_loan
	WHERE MONTH(issue_date) = 12 ;

	--Month over Month total changes in application 

	WITH MonthlyApplications AS 
	(
		SELECT 
			FORMAT(issue_date, 'yyyy-MM') AS month,
			COUNT(id) AS total_applications
		FROM 
			bank_loan
		GROUP BY 
			FORMAT(issue_date, 'yyyy-MM') --for each month so GROUP BY
	),
	MonthlyChanges AS
	(
		SELECT 
			month,
			total_applications,
			LAG(total_applications) OVER (ORDER BY month) AS previous_month_applications
		FROM 
			MonthlyApplications
	)
	SELECT 
		month,
		total_applications,
		previous_month_applications,
		(total_applications - ISNULL(previous_month_applications, 0)) AS month_over_month_change --[total_applications - ISNULL(previous_month_applications, 0) = 100 - 0 = 100]
	FROM 
		MonthlyChanges
	ORDER BY month;

	--Total funded amount

	SELECT SUM(loan_amount) as Total_funded_amount 
	FROM bank_loan;


	-- Month to date total amount funded 

	SELECT SUM(loan_amount) as MTD_Total_funded_amount 
	FROM bank_loan
	WHERE MONTH(issue_date) = 12 ;

	--Month over month changes in total funds 

	WITH cte as 
	(
	SELECT  FORMAT(issue_date, 'yyyy-MM') as month , SUM(loan_amount) as Total_funded_amount 
	FROM bank_loan
	GROUP BY FORMAT(issue_date, 'yyyy-MM')
	),
	cte2 as 
	(
	SELECT month ,Total_funded_amount, LAG(Total_funded_amount) OVER(ORDER BY month) as Previous_Total_funded_amount
	FROM cte 
	)
	SELECT month , Total_funded_amount , Previous_Total_funded_amount, (Total_funded_amount - ISNULL(Previous_Total_funded_amount,0)) AS MOM_change
	FROM cte2
	ORDER BY month;

	--Total Amount Received 

	SELECT SUM(total_payment) as Total_amount_received 
	FROM bank_loan;

	-- Month to date total amount received

	SELECT SUM(total_payment) as MTD_Total_amount_received 
	FROM bank_loan
	WHERE MONTH(issue_date) = 12 ;

	--Month over month changes in total amount received

	WITH cte as 
	(
	SELECT  FORMAT(issue_date, 'yyyy-MM') as month , SUM(total_payment) as Total_amount_received 
	FROM bank_loan
	GROUP BY FORMAT(issue_date, 'yyyy-MM')
	),
	cte2 as 
	(
	SELECT month ,Total_amount_received , LAG(Total_amount_received ) OVER(ORDER BY month) as Previous_Total_amount_received
	FROM cte 
	)
	SELECT month , Total_amount_received  , Previous_Total_amount_received, (Total_amount_received  - ISNULL(Previous_Total_amount_received,0)) AS MOM_change
	FROM cte2
	ORDER BY month;


	SELECT * FROM bank_loan;

	--Avg interest rates

	SELECT ROUND(AVG(int_rate),4) * 100 as Avg_interest_rate 
	FROM bank_loan;

	-- Month to date Avg_interest_rate

	SELECT ROUND(AVG(int_rate),4) * 100 as MTD_Avg_interest_rate
	FROM bank_loan
	WHERE MONTH(issue_date) = 12 ;


	--Month over month changes in interest rates

	WITH cte as 
	(
	SELECT  FORMAT(issue_date, 'yyyy-MM') as month , AVG(int_rate) * 100 as Avg_interest_rate
	FROM bank_loan
	GROUP BY FORMAT(issue_date, 'yyyy-MM')
	),
	cte2 as 
	(
	SELECT month ,Avg_interest_rate , LAG(Avg_interest_rate ) OVER(ORDER BY month) as Previous_Avg_interest_rate
	FROM cte 
	)
	SELECT month , ROUND(Avg_interest_rate,2)  , ROUND(Previous_Avg_interest_rate,2) , 
	ROUND((Avg_interest_rate  - ISNULL(Previous_Avg_interest_rate,0)),2) AS MOM_change
	FROM cte2
	ORDER BY month;


	--Avg DTI

	SELECT ROUND(AVG(dti),4) * 100 as Avg_dti
	FROM bank_loan;

	-- Month to date dti

	SELECT ROUND(AVG(dti),4) * 100 as MTD_Avg_dti
	FROM bank_loan
	WHERE MONTH(issue_date) = 12 ;


	-- Change in average dti

	WITH cte as 
	(
	SELECT  FORMAT(issue_date, 'yyyy-MM') as month , AVG(dti) * 100 as Avg_dti
	FROM bank_loan
	GROUP BY FORMAT(issue_date, 'yyyy-MM')
	),
	cte2 as 
	(
	SELECT month ,Avg_dti , LAG(Avg_dti) OVER(ORDER BY month) as Previous_Avg_dti
	FROM cte 
	)
	SELECT month , ROUND(Avg_dti,2)  , ROUND(Previous_Avg_dti,2) , 
	ROUND((Avg_dti  - ISNULL(Previous_Avg_dti,0)),2) AS MOM_change
	FROM cte2
	ORDER BY month;

	--Percentage of Good Loan Applications 

	SELECT (COUNT(CASE WHEN loan_status = 'Fully Paid' OR loan_status = 'Current' THEN id end) *100) /
	COUNT(id) as Good_Loan_Percentage
	FROM bank_loan;


	-- Total Good Loan Applications

	SELECT COUNT(*) as Good_Loan_Applications
	FROM bank_loan
	WHERE loan_status IN ('Fully Paid', 'Current');

	-- Total Good Loan Funded amount

	SELECT SUM(loan_amount) as Good_loan_funded_amount
	FROM bank_loan
	WHERE loan_status = 'Fully Paid'
	OR loan_status = 'Current';

	--Total Good Loan received amount

	SELECT SUM(total_payment) as Good_loan_received_amount
	FROM bank_loan
	WHERE loan_status = 'Fully Paid'
	OR loan_status = 'Current';

	SELECT * FROM bank_loan;


	--Percentage of Bad Loan Applications 

	SELECT (COUNT(CASE WHEN loan_status = 'Charged Off' THEN id end) *100) /
	COUNT(id) as Bad_Loan_Percentage
	FROM bank_loan;

	-- Total Bad Loan Applications

	SELECT COUNT(*) as Bad_Loan_Applications
	FROM bank_loan
	WHERE loan_status IN ('Charged Off');

	-- Total Bad Loan Funded amount

	SELECT SUM(loan_amount) as Bad_loan_funded_amount
	FROM bank_loan
	WHERE loan_status = 'Charged Off';

	--Total Bad Loan received amount

	SELECT SUM(total_payment) as Bad_loan_received_amount
	FROM bank_loan
	WHERE loan_status = 'Charged Off';

	--Overall scenerio relating to loan status

	SELECT loan_status,
	COUNT(id) as Total_application,
	SUM(loan_amount) as Total_amount_funded,
	SUM(total_payment) as Total_amount_received,
	AVG((int_rate)*100) as Avg_interest,
	AVG((dti)*100) as Avg_dti
	FROM bank_loan
	GROUP BY loan_status;

	--MTD scenrio of loan status 

	SELECT loan_status,
	COUNT(id) as Total_application,
	SUM(loan_amount) as Total_amount_funded,
	SUM(total_payment) as Total_amount_received
	FROM bank_loan
	WHERE MONTH(issue_date) = 12
	GROUP BY loan_status;

	--Monthly Trend By issue date 

	SELECT MONTH(issue_date) as Month_Number,
	DATENAME(MONTH,issue_date) as Month_Name,
	COUNT(id) as Total_application,
	SUM(loan_amount) as Total_amount_funded,
	SUM(total_payment) as Total_amount_received
	FROM bank_loan
	GROUP BY DATENAME(MONTH,issue_date),MONTH(issue_date)   -- remember in group by we cannot use the alias name eg month_number and month_name 
	ORDER BY MONTH(issue_date);

	--STATE wise loan overview

	SELECT address_state ,
	COUNT(id) as Total_application,
	SUM(loan_amount) as Total_amount_funded,
	SUM(total_payment) as Total_amount_received
	FROM bank_loan
	GROUP BY address_state
	ORDER BY Total_application desc;

	-- State that paid less amount then taken 

	SELECT address_state ,
	COUNT(id) as Total_application,
	SUM(loan_amount) as Total_amount_funded,
	SUM(total_payment) as Total_amount_received
	FROM bank_loan
	GROUP BY address_state
	HAVING SUM(loan_amount)>SUM(total_payment);

	-- Loan Term wise loan overview 

	SELECT term ,
	COUNT(id) as Total_application,
	SUM(loan_amount) as Total_amount_funded,
	SUM(total_payment) as Total_amount_received
	FROM bank_loan
	GROUP BY term
	ORDER BY Total_application desc;


	--Employment Length wise loan overview

	SELECT emp_length ,
	COUNT(id) as Total_application,
	SUM(loan_amount) as Total_amount_funded,
	SUM(total_payment) as Total_amount_received
	FROM bank_loan
	GROUP BY emp_length 
	ORDER BY Total_application desc;


	-- Grade wise loan overview

	SELECT grade ,
	COUNT(id) as Total_application,
	SUM(loan_amount) as Total_amount_funded,
	SUM(total_payment) as Total_amount_received
	FROM bank_loan
	GROUP BY grade 
	ORDER BY Total_amount_funded desc;


	-- Home ownership wise loan overview

	SELECT home_ownership ,
	COUNT(id) as Total_application,
	SUM(loan_amount) as Total_amount_funded,
	SUM(total_payment) as Total_amount_received
	FROM bank_loan
	GROUP BY home_ownership 
	ORDER BY Total_application desc;

	-- For which home ownership status the bank is incurring loss

	SELECT home_ownership ,
	COUNT(id) as Total_application,
	SUM(loan_amount) as Total_amount_funded,
	SUM(total_payment) as Total_amount_received
	FROM bank_loan
	GROUP BY home_ownership
	HAVING SUM(loan_amount)>SUM(total_payment);

	-- Purpose wise loan overview

	SELECT purpose ,
	COUNT(id) as Total_application,
	SUM(loan_amount) as Total_amount_funded,
	SUM(total_payment) as Total_amount_received
	FROM bank_loan
	GROUP BY purpose 
	ORDER BY Total_amount_funded desc;

	-- Avg loan amount for each purpose
	SELECT purpose ,
	COUNT(id) as Total_application,
	AVG(loan_amount) as Avg_amount_funded
	FROM bank_loan
	GROUP BY purpose
	ORDER BY Avg_amount_funded desc; 

	-- For which loan purpose the bank is incurring loss

	SELECT purpose ,
	COUNT(id) as Total_application,
	SUM(loan_amount) as Total_amount_funded,
	SUM(total_payment) as Total_amount_received
	FROM bank_loan
	GROUP BY purpose 
	HAVING SUM(loan_amount)>SUM(total_payment);


	SELECT * FROM bank_loan;

	-- Annual income wise loan overview 

	SELECT Top 5 annual_income ,
	COUNT(id) as Total_application,
	SUM(loan_amount) as Total_amount_funded,
	SUM(total_payment) as Total_amount_received
	FROM bank_loan
	GROUP BY annual_income 
	ORDER BY Total_amount_funded desc;

	-- Annual income wise bad performing repayment

	SELECT Top 5 annual_income ,
	COUNT(id) as Total_application,
	SUM(loan_amount) as Total_amount_funded,
	SUM(total_payment) as Total_amount_received
	FROM bank_loan
	GROUP BY annual_income 
	HAVING SUM(loan_amount)>SUM(total_payment)
	ORDER BY Total_amount_funded desc ;