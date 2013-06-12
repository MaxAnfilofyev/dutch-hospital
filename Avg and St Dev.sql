/****** Script for calculating the average volume and standard deviation of a given activity for a given diagnosis *****/
SELECT
  [DIAGNOSIS_CODE]
	,[ACTIVITY_CODE]
	,ACTIVITY_COUNT_TOTAL/[DIAGNOSIS_CODE_COUNT] as activity_count_avg
	,case when [DIAGNOSIS_CODE_COUNT]>1 then SQRT(([DIAGNOSIS_CODE_COUNT]-ACTIVITY_COUNT_TOTAL)*(ACTIVITY_COUNT_AVG*ACTIVITY_COUNT_AVG)/([DIAGNOSIS_CODE_COUNT]-1)) else 0 end as activity_count_stdev
	FROM
	(
		SELECT 
			DTC.[DIAGNOSIS_CODE]
			,[ACTIVITY_CODE]
			,cast (COUNT(*)  as float) AS ACTIVITY_COUNT_TOTAL
			,cast ([DIAGNOSIS_CODE_COUNT] as float) [DIAGNOSIS_CODE_COUNT]
			,cast(COUNT(*) as float)/cast([DIAGNOSIS_CODE_COUNT] as float) AS ACTIVITY_COUNT_AVG	
		FROM [ANALYTICS].[DBO].[DTC]
		JOIN [ANALYTICS].[DBO].CA ON [DTC].DTC_KEY=CA.DTC_KEY
		JOIN (
			SELECT 
				[DIAGNOSIS_CODE]
				,COUNT(*) AS [DIAGNOSIS_CODE_COUNT]
			FROM [ANALYTICS].[DBO].[DTC]
			JOIN [ANALYTICS].[DBO].CA ON [DTC].DTC_KEY=CA.DTC_KEY
			WHERE [DIAGNOSIS_CODE] <> ''
			GROUP BY [DIAGNOSIS_CODE]
			) A 
		ON DTC.DIAGNOSIS_CODE=A.DIAGNOSIS_CODE
		WHERE DTC.[DIAGNOSIS_CODE] <> ''
		GROUP BY 
			DTC.[DIAGNOSIS_CODE]
			,[ACTIVITY_CODE]
			,[DIAGNOSIS_CODE_COUNT]		
) r
