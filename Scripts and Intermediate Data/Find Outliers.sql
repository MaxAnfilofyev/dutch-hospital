/*FIND OUTLIER DTCS
HIGHER ZSCORE_AVG INDICATES A DTC WITH # OF ACITIVITIES FAR FROM AVERAGE
IDEA: INSTEAD OF  SIMPLE AVERAGE, CALCULATE AN AVERAGE BASED ON THE ACTIVITY COST*/
SELECT
	DTC_KEY
	,AVG(ZSCORE*[weight]) ZSCORE_AVG
	FROM
	(
	SELECT
		DTC_KEY
		,[Specialist]
		,DIAGNOSIS_CODE
		,[ACTIVITY_CODE]
		,CASE WHEN [ACTIVITY_COUNT_STDEV]>0 THEN ABS(PRESENT-[ACTIVITY_COUNT_AVG])/[ACTIVITY_COUNT_STDEV] ELSE 0 END AS ZSCORE
		--,PRESENT
		--,[ACTIVITY_COUNT_AVG]
		--,[ACTIVITY_COUNT_STDEV]
		,C.[CareProfile_class_code]
		,[weight]
		FROM
			(
			SELECT 
				B.DTC_KEY
				, B.[Specialist]
				, B.DIAGNOSIS_CODE
				, B.[ACTIVITY_CODE]
				--,A.[ACTIVITY_CODE]
				,CASE WHEN A.[ACTIVITY_CODE] IS NOT NULL THEN 1 ELSE 0 END AS PRESENT
				, [ACTIVITY_COUNT_AVG]
				,[ACTIVITY_COUNT_STDEV]
				,B.[CareProfile_class_code]
				FROM 
					(SELECT 
						[DTC_KEY]
						,DTC.[Specialist]
						,DTC.DIAGNOSIS_CODE		
						,[AVG AND STDEV].[ACTIVITY_CODE]
						, [ACTIVITY_COUNT_AVG]
						,[ACTIVITY_COUNT_STDEV]
						,[CareProfile_class_code]
					FROM DTC JOIN [AVG AND STDEV] ON DTC.DIAGNOSIS_CODE=[AVG AND STDEV].DIAGNOSIS_CODE) B
					LEFT OUTER JOIN 
						(SELECT        
							DTC.DTC_KEY
							, DTC.DIAGNOSIS_CODE
							,[Specialist]
							, CA.[ACTIVITY_CODE]
						FROM DTC JOIN CA ON DTC.DTC_KEY=CA.DTC_KEY
						WHERE DIAGNOSIS_CODE<>'' and [Expected_Careproduct]<>'') A 
					ON B.DTC_KEY = A.DTC_KEY AND B.DIAGNOSIS_CODE=A.DIAGNOSIS_CODE AND B.[ACTIVITY_CODE]=A.ACTIVITY_CODE AND B.[Specialist]=A.[Specialist]
			) C
			JOIN [dim_care_profile_class] ON C.[CareProfile_class_code]=[dim_care_profile_class].[CareProfile_class_code]
		)D
		 
GROUP BY DTC_KEY
ORDER BY AVG(ZSCORE*[weight]) DESC
