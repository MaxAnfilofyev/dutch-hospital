/****** Script for calculating the average volume and standard deviation of a given activity for a given diagnosis and specialist*****/

INSERT INTO [dbo].[avg and stdev]
           (
           Specialist
           ,[Diagnosis_code]
           ,[Activity_code]
           ,[activity_count_total]
           ,[Diagnosis_code_count]
           ,[activity_count_avg]
           ,[activity_count_stdev]
		   ,[CareProfile_class_code])
		
           (
           
SELECT
	[Specialist]
	,[DIAGNOSIS_CODE]
	,[ACTIVITY_CODE]
	,ACTIVITY_COUNT_TOTAL
	,[DIAGNOSIS_CODE_COUNT]
	,ACTIVITY_COUNT_TOTAL/[DIAGNOSIS_CODE_COUNT] AS ACTIVITY_COUNT_AVG
	--,CASE WHEN [DIAGNOSIS_CODE_COUNT]>1 THEN SQRT(([DIAGNOSIS_CODE_COUNT]-ACTIVITY_COUNT_TOTAL)*(ACTIVITY_COUNT_AVG*ACTIVITY_COUNT_AVG)/([DIAGNOSIS_CODE_COUNT]-1)) ELSE 0 END AS ACTIVITY_COUNT_STDEV
	--,SQRT(([DIAGNOSIS_CODE_COUNT]-ACTIVITY_COUNT_TOTAL)*(ACTIVITY_COUNT_AVG*ACTIVITY_COUNT_AVG)/([DIAGNOSIS_CODE_COUNT]-1)) AS ACTIVITY_COUNT_STDEV2
	, ACTIVITY_COUNT_TOTAL*([DIAGNOSIS_CODE_COUNT]-ACTIVITY_COUNT_TOTAL)/([DIAGNOSIS_CODE_COUNT]*[DIAGNOSIS_CODE_COUNT]) as ACTIVITY_COUNT_STDEV
	,[CareProfile_class_code]
	FROM
	(
		SELECT 
			DTC.[Specialist]
			,DTC.[DIAGNOSIS_CODE]
			,[ACTIVITY_CODE]
			,CAST (COUNT(*)  AS FLOAT) AS ACTIVITY_COUNT_TOTAL
			,CAST ([DIAGNOSIS_CODE_COUNT] AS FLOAT) [DIAGNOSIS_CODE_COUNT]
			,CAST(COUNT(*) AS FLOAT)/CAST([DIAGNOSIS_CODE_COUNT] AS FLOAT) AS ACTIVITY_COUNT_AVG
			,[CareProfile_class_code]	
		FROM [ANALYTICS].[DBO].[DTC]
		JOIN [ANALYTICS].[DBO].CA ON [DTC].DTC_KEY=CA.DTC_KEY
		JOIN (
			SELECT 
				[Specialist]
				,[DIAGNOSIS_CODE]
				,COUNT(*) AS [DIAGNOSIS_CODE_COUNT]
			FROM [ANALYTICS].[DBO].[DTC]
			JOIN [ANALYTICS].[DBO].CA ON [DTC].DTC_KEY=CA.DTC_KEY
			WHERE [DIAGNOSIS_CODE] <> '' and [Expected_Careproduct]<>''
			GROUP BY [Specialist], [DIAGNOSIS_CODE]
			) A 
		ON DTC.DIAGNOSIS_CODE=A.DIAGNOSIS_CODE AND DTC.[Specialist]=A.[Specialist]
		WHERE DTC.[DIAGNOSIS_CODE] <> '' and [Expected_Careproduct]<>''
		GROUP BY 
			DTC.[Specialist]
			,DTC.[DIAGNOSIS_CODE]
			,[ACTIVITY_CODE]
			,[DIAGNOSIS_CODE_COUNT]
			,[CareProfile_class_code]		
) R

)
