USE PlanetTogether_Export_OOM_CAT_PRD
GO

BEGIN
SELECT J_PRM.ExternalId AS JobExternalId_PRM
	,J_PRM.JobId AS JobId_PRM
	,J_Real.ExternalId AS JobExternalId_REAL
	,J_Real.JobId AS JobId_REAL
	,J_PRM.ScheduledStartDateTime AS ScheduledStartDateTime_PRM
	,J_Real.ScheduledStartDateTime
INTO #FakePRMJobs
FROM Jobs J_PRM
	,Jobs J_Real
WHERE J_PRM.PublishDate = dbo.AGG_fnGet_latestPublishDate()
	AND J_Real.PublishDate = dbo.AGG_fnGet_latestPublishDate()
	AND J_PRM.ExternalId LIKE '%PRM'
	AND REPLACE(J_PRM.ExternalId, '_PRM', '') = J_Real.ExternalId

DELETE Jobs
WHERE PublishDate = dbo.AGG_fnGet_latestPublishDate()
AND JobId IN (Select JobId_PRM FROM #FakePRMJobs)

UPDATE Jobs
SET ScheduledStartDateTime = PRM.ScheduledStartDateTime_PRM
FROM #FakePRMJobs PRM
WHERE PublishDate = dbo.AGG_fnGet_latestPublishDate()
AND Jobs.JobId = PRM.JobId_REAL

UPDATE JobActivities
SET JobId = PRM.JobId_REAL
,ScheduledStartDate = PRM.ScheduledStartDateTime_PRM
FROM #FakePRMJobs PRM
WHERE PublishDate = dbo.AGG_fnGet_latestPublishDate()
AND JobActivities.JobId = PRM.JobId_PRM

UPDATE JobOperations
SET JobId = PRM.JobId_REAL
,ScheduledStart = PRM.ScheduledStartDateTime_PRM
FROM #FakePRMJobs PRM
WHERE PublishDate = dbo.AGG_fnGet_latestPublishDate()
AND JobOperations.JobId = PRM.JobId_PRM

UPDATE JobResourceBlocks
SET JobId = PRM.JobId_REAL
,ScheduledStart = PRM.ScheduledStartDateTime_PRM
FROM #FakePRMJobs PRM
WHERE PublishDate = dbo.AGG_fnGet_latestPublishDate()
AND JobResourceBlocks.JobId = PRM.JobId_PRM
END
GO

/****** Object:  View [dbo].[AGG_vAPS2EXT_JobOperations]    Script Date: 01/04/2025 13:43:36 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER VIEW [dbo].[AGG_vAPS2EXT_JobOperations]
AS
SELECT JOB.OrderNumber
	,JOB.Name
	,OPE.Name AS OperationName
	,OPE.Description
	,CONVERT(VARCHAR, JOB.ScheduledStartDateTime, 1) AS ScheduledStartDate
	,CONVERT(VARCHAR, JOB.ScheduledEndDateTime, 1) AS ScheduledEndDate
	,JOB.LeadResource
	,JOB.Product
	,JOB.Qty
	,CONVERT(VARCHAR, JOB.NeedDateTime, 1) AS NeedDate
	,OPE.ExpectedRunHours
	,OPE.ExpectedSetupHours
FROM dbo.Jobs AS JOB
INNER JOIN dbo.JobOperations AS OPE ON JOB.JobId = OPE.JobId
WHERE (JOB.ScheduledStatus <> 'Finished')
	AND (JOB.Name NOT LIKE 'PT%')
	AND (JOB.Name NOT LIKE 'MRP%')
	AND (JOB.PublishDate = dbo.AGG_fnGet_latestPublishDate())
	AND (OPE.PublishDate = dbo.AGG_fnGet_latestPublishDate())
GO

/****** Object:  View [dbo].[AGG_vAPS2EXT_Jobs]    Script Date: 01/04/2025 13:43:36 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER VIEW [dbo].[AGG_vAPS2EXT_Jobs]
AS
SELECT Name
	,OrderNumber
	,CONVERT(VARCHAR, ScheduledStartDateTime, 1) AS ScheduledStartDateTime
	,CONVERT(VARCHAR, ScheduledEndDateTime, 1) AS ScheduledEndDateTime
	,Product
	,Qty
	,CONVERT(VARCHAR, NeedDateTime, 1) AS NeedDateTime
FROM dbo.Jobs
WHERE (ScheduledStatus <> 'Finished')
	AND (Name NOT LIKE 'PT%')
	AND (Name NOT LIKE 'MRP%')
	AND (PublishDate = dbo.AGG_fnGet_latestPublishDate())
GO

/****** Object:  View [dbo].[AGG_vAPS2EXT_Ordini]    Script Date: 01/04/2025 13:43:36 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER VIEW [dbo].[AGG_vAPS2EXT_Ordini]
AS
SELECT DISTINCT JOB.Name AS Order_Number
	,JOB.[UDF Customer UDF] AS Ordine_Cliente
	,JOB.Commitment
	,JOB.Product
	,JOB.ProductDescription
	,JOB.Description AS Codice_Matricola
	,JOB.Qty
	,CONVERT(VARCHAR, JOB.ScheduledStartDateTime, 3) AS ScheduledStartDateTime
	,CONVERT(VARCHAR, JOB.ScheduledEndDateTime, 3) AS ScheduledEndDateTime
	,CONVERT(VARCHAR, JOB.NeedDateTime, 3) AS NeedDateTime
	,CONVERT(VARCHAR, JOB.[CUS_DataRTS UDF], 3) AS Data_RTS
	,CONVERT(VARCHAR, JOB.[UDF DataInizioJob UDF], 3) AS DataInizioJob
	,JOB.LatenessDays
	,PT.Name AS Stabilimento
	,JOB.ResourceNames
FROM dbo.Jobs AS JOB
INNER JOIN dbo.JobResourceBlocks AS JB ON JOB.JobId = JB.JobId
INNER JOIN dbo.Plants AS PT ON JB.PlantId = PT.PlantId
GO

/****** Object:  View [dbo].[AGG_vAPS2EXT_Ordini_date]    Script Date: 01/04/2025 13:43:36 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER VIEW [dbo].[AGG_vAPS2EXT_Ordini_date]
AS
SELECT DISTINCT JOB.Name AS Order_Number
	,JOB.[UDF Customer UDF] AS Ordine_Cliente
	,JOB.Commitment
	,JOB.Product
	,JOB.ProductDescription
	,JOB.Description AS Codice_Matricola
	,JOB.Qty
	,CONVERT(VARCHAR, JOB.ScheduledStartDateTime, 11) AS ScheduledStartDateTime
	,CONVERT(VARCHAR, JOB.ScheduledEndDateTime, 11) AS ScheduledEndDateTime
	,CONVERT(VARCHAR, JOB.NeedDateTime, 11) AS NeedDateTime
	,CONVERT(VARCHAR, JOB.[CUS_DataRTS UDF], 11) AS Data_RTS
	,CONVERT(VARCHAR, JOB.[UDF DataInizioJob UDF], 11) AS DataInizioJob
	,JOB.LatenessDays
	,PT.Name AS Stabilimento
	,JOB.ResourceNames
FROM dbo.Jobs AS JOB
INNER JOIN dbo.JobResourceBlocks AS JB ON JOB.JobId = JB.JobId
INNER JOIN dbo.Plants AS PT ON JB.PlantId = PT.PlantId
GO

/****** Object:  View [dbo].[AGG_vAPS2EXT_Ordini_esplosi]    Script Date: 01/04/2025 13:43:36 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER VIEW [dbo].[AGG_vAPS2EXT_Ordini_esplosi]
AS
SELECT TOP (100) PERCENT (
		CASE 
			WHEN JOB.OrderNumber = '#'
				THEN job.Name
			ELSE JOB.OrderNumber
			END
		) AS OrderNumber
	,JOB.Name AS Order_Number
	,JOB.[UDF Customer UDF] AS Ordine_Cliente
	,JA.ExternalId
	,JA.ResourcesUsed
	,CONVERT(VARCHAR, JA.ScheduledStartDate, 1) AS ScheduledStartDate
	,CONVERT(VARCHAR, JA.ScheduledEndDate, 1) AS ScheduledEndDate
	,JA.RequiredFinishQty
	,JA.CycleHrs
	,JOB1.Description AS DescOperazione
	,JOB.Notes AS CodiceMatricola
	,JOB1.[UDF CycleTimeOriginale UDF] AS CycleHrsOriginali
FROM dbo.Jobs AS JOB
INNER JOIN dbo.JobActivities AS JA ON JOB.JobId = JA.JobId
INNER JOIN dbo.JobOperations AS JOB1 ON JA.OperationId = JOB1.OperationId
--WHERE        (JA.ScheduledStartDate > '2000-01-01 00:00:00.000')
ORDER BY OrderNumber
	,ScheduledStartDate
GO

/****** Object:  View [dbo].[AGG_vAPS2EXT_Ordini_esplosi_combo]    Script Date: 01/04/2025 13:43:36 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER VIEW [dbo].[AGG_vAPS2EXT_Ordini_esplosi_combo]
AS
WITH LastJobPublishDate_CTE
AS (
	SELECT MAX(PublishDate) AS LastPublishDate
	FROM dbo.Jobs
	)
SELECT JOB.Name AS Ordine_di_lavoro
	,JOB.[UDF Customer UDF] AS Ordine_Cliente
	,JOB.Commitment
	,JOB.Product AS Prodotto
	,JOB.ProductDescription AS Descrizione_Prodotto
	,JA.ResourcesUsed
	,JOB.Description AS Codice_Matricola
	,JOB.Qty AS Quantità
	,IIF(JA.ResourcesUsed IN (
			'CPLNLINEA#00420 (Minerbio)'
			,'MCPLNLINEA#00420 (Minerbio)'
			,'UCOMLINEA#00910 (Minerbio)'
			,'MCPLNLINEA#00420 (Minerbio), Uomo_420-430_MCPLN (Minerbio)'
			,'MRMLINEA#520 (Minerbio), Uomo_520-530_MRM (Minerbio)'
			,'MRMLINEA#520 (Minerbio)'
			,'RMLINEA#520 (Minerbio)'
			,'RMLINEA#520 (Minerbio), Uomo_520-530_RM (Minerbio)'
			), CONVERT(VARCHAR, JA.ScheduledStartDate, 20), NULL) AS Inizio_Linea
	,IIF(JA.ResourcesUsed IN (
			'CPLNLINEA#00460 (Minerbio)'
			,'MCPLNLINEA#00450 (Minerbio)'
			,'UCOMLINEA#00975 (Minerbio)'
			,'MRMLINEA#550 (Minerbio)'
			,'MRMLINEA#550 (Minerbio), Uomo_540-550_MRM (Minerbio)'
			,'RMLINEA#550 (Minerbio)'
			,'RMLINEA#550 (Minerbio), Uomo_540-550_RM (Minerbio)'
			), CONVERT(VARCHAR, JA.ScheduledEndDate, 20), NULL) AS Fine_Linea
	,IIF(JA.ResourcesUsed IN (
			'CPLNOPTIO (Minerbio)'
			,'MCPLNFIN02 (Minerbio)'
			,'UCOMFINIT (Minerbio)'
			,'RMFINIT (Minerbio)'
			,'MRMCOLLA (Minerbio)'
			), CONVERT(VARCHAR, JA.ScheduledEndDate, 20), NULL) AS Fine_Prod
	,CONVERT(VARCHAR, JA.ScheduledStartDate, 20) AS Data_Inizio_Schedulata
	,CONVERT(VARCHAR, JA.ScheduledEndDate, 20) AS Data_Fine_Schedulata
	,CONVERT(VARCHAR, JOB.NeedDateTime, 11) AS Data_richiesta
	,CONVERT(VARCHAR, JOB.[CUS_DataRTS UDF], 11) AS Data_RTS
	,CONVERT(VARCHAR, JOB.[UDF DataInizioJob UDF], 11) AS Data_Inizio_Job
	,JA.RequiredFinishQty
	,JA.CycleHrs
	,OP.Description AS DescOperazione
	,JOB.Notes AS CodiceMatricola
	,OP.[UDF CycleTimeOriginale UDF] AS CycleHrsOriginali
	,JOB.ResourceNames
	,JOB.LatenessDays
	,JOB.Destination
	,JOB.PublishDate
FROM dbo.Jobs AS JOB
INNER JOIN dbo.JobActivities AS JA ON JOB.JobId = JA.JobId
	AND JOB.PublishDate = JA.PublishDate
INNER JOIN dbo.JobOperations AS OP ON JA.OperationId = OP.OperationId
	AND JOB.PublishDate = OP.PublishDate
INNER JOIN LastJobPublishDate_CTE AS LJ ON JOB.PublishDate = LJ.LastPublishDate
GO

/****** Object:  View [dbo].[AGG_vAPS2EXT_Ordini_esplosi_LAST]    Script Date: 01/04/2025 13:43:36 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER VIEW [dbo].[AGG_vAPS2EXT_Ordini_esplosi_LAST]
AS
WITH LastJobPublishDate_CTE
AS (
	SELECT MAX(PublishDate) AS LastPublishDate
	FROM dbo.Jobs
	)
SELECT TOP (100) PERCENT (
		CASE 
			WHEN JOB.OrderNumber = '#'
				THEN job.Name
			ELSE JOB.OrderNumber
			END
		) AS OrderNumber
	,JOB.Name AS Order_Number
	,JOB.[UDF Customer UDF] AS Ordine_Cliente
	,JA.ExternalId
	,JA.ResourcesUsed
	,CONVERT(VARCHAR, JA.ScheduledStartDate, 20) AS ScheduledStartDate
	,CONVERT(VARCHAR, JA.ScheduledEndDate, 20) AS ScheduledEndDate
	,JA.RequiredFinishQty
	,JA.CycleHrs
	,OP.Description AS DescOperazione
	,JOB.Notes AS CodiceMatricola
	,OP.[UDF CycleTimeOriginale UDF] AS CycleHrsOriginali
	,job.Destination
	,JOB.PublishDate
FROM dbo.Jobs AS JOB
INNER JOIN dbo.JobActivities AS JA ON JOB.JobId = JA.JobId
	AND JOB.PublishDate = JA.PublishDate
INNER JOIN dbo.JobOperations AS OP ON JA.OperationId = OP.OperationId
	AND JOB.PublishDate = OP.PublishDate
INNER JOIN LastJobPublishDate_CTE AS LJ ON JOB.PublishDate = LJ.LastPublishDate
ORDER BY OrderNumber
	,ScheduledStartDate
GO

/****** Object:  View [dbo].[AGG_vAPS2EXT_Ordini_esplosi_NEW]    Script Date: 01/04/2025 13:43:36 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER VIEW [dbo].[AGG_vAPS2EXT_Ordini_esplosi_NEW]
AS
WITH LastJobPublishDate_CTE
AS (
	SELECT ExternalId AS JobExternalId
		,MAX(PublishDate) AS LastPublishDate
	FROM dbo.Jobs J
	WHERE J.Commitment = 'Firm'
	GROUP BY ExternalId
	
	UNION ALL
	
	SELECT ExternalId AS JobExternalId
		,PublishDate AS LastPublishDate
	FROM dbo.Jobs J
	WHERE J.Commitment <> 'Firm'
		AND J.PublishDate = dbo.AGG_fnGet_latestPublishDate()
	)
SELECT TOP (100) PERCENT (
		CASE 
			WHEN JOB.OrderNumber = '#'
				THEN job.Name
			ELSE JOB.OrderNumber
			END
		) AS OrderNumber
	,JOB.Name AS Order_Number
	,JOB.[UDF Customer UDF] AS Ordine_Cliente
	,JA.ExternalId
	,JA.ResourcesUsed
	,CONVERT(VARCHAR, JA.ScheduledStartDate, 20) AS ScheduledStartDate
	,CONVERT(VARCHAR, JA.ScheduledEndDate, 20) AS ScheduledEndDate
	,JA.RequiredFinishQty
	,JA.CycleHrs
	,OP.Description AS DescOperazione
	,JOB.Notes AS CodiceMatricola
	,OP.[UDF CycleTimeOriginale UDF] AS CycleHrsOriginali
	,JOB.PublishDate
FROM dbo.Jobs AS JOB
INNER JOIN dbo.JobActivities AS JA ON JOB.JobId = JA.JobId
	AND JOB.PublishDate = JA.PublishDate
INNER JOIN dbo.JobOperations AS OP ON JA.OperationId = OP.OperationId
	AND JOB.PublishDate = OP.PublishDate
INNER JOIN LastJobPublishDate_CTE AS LJ ON JOB.ExternalId = LJ.JobExternalId
	AND JOB.PublishDate = LJ.LastPublishDate
ORDER BY OrderNumber
	,ScheduledStartDate
GO

/****** Object:  View [dbo].[AGG_vAPS2EXT_Ordini_esplosi_orig]    Script Date: 01/04/2025 13:43:36 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER VIEW [dbo].[AGG_vAPS2EXT_Ordini_esplosi_orig]
AS
SELECT TOP (100) PERCENT (
		CASE 
			WHEN JOB.OrderNumber = '#'
				THEN job.Name
			ELSE JOB.OrderNumber
			END
		) AS OrderNumber
	,JOB.Name AS Order_Number
	,JOB.[UDF Customer UDF] AS Ordine_Cliente
	,JA.ExternalId
	,JA.ResourcesUsed
	,CONVERT(VARCHAR, JA.ScheduledStartDate, 1) AS ScheduledStartDate
	,CONVERT(VARCHAR, JA.ScheduledEndDate, 1) AS ScheduledEndDate
	,JA.RequiredFinishQty
	,JA.CycleHrs
	,JOB.Notes AS CodiceMatricola
	,JOB1.[UDF CycleTimeOriginale UDF] AS CycleHrsOriginali
FROM dbo.Jobs AS JOB
INNER JOIN dbo.JobActivities AS JA ON JOB.JobId = JA.JobId
INNER JOIN dbo.JobOperations AS JOB1 ON JA.OperationId = JOB1.OperationId
WHERE (JA.ScheduledStartDate > '2000-01-01 00:00:00.000')
ORDER BY OrderNumber
	,ScheduledStartDate
GO

/****** Object:  View [dbo].[AGG_vAPS2EXT_Ordini_LAST]    Script Date: 01/04/2025 13:43:36 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*WHERE JOB.PublishDate = dbo.AGG_fnGet_latestPublishDate();*/
ALTER VIEW [dbo].[AGG_vAPS2EXT_Ordini_LAST]
AS
WITH LastJobPublishDate_CTE
AS (
	SELECT MAX(PublishDate) AS LastPublishDate
	FROM dbo.Jobs
	)
SELECT DISTINCT JOB.Name AS Order_Number
	,JOB.[UDF Customer UDF] AS Ordine_Cliente
	,JOB.Commitment
	,JOB.Product
	,JOB.ProductDescription
	,JOB.Description AS Codice_Matricola
	,JOB.Qty
	,CONVERT(VARCHAR, JOB.ScheduledStartDateTime, 20) AS ScheduledStartDateTime
	,CONVERT(VARCHAR, JOB.ScheduledEndDateTime, 20) AS ScheduledEndDateTime
	,CONVERT(VARCHAR, JOB.NeedDateTime, 11) AS NeedDateTime
	,CONVERT(VARCHAR, JOB.[CUS_DataRTS UDF], 11) AS Data_RTS
	,CONVERT(VARCHAR, JOB.[UDF DataInizioJob UDF], 11) AS DataInizioJob
	,JOB.LatenessDays
	,JOB.ResourceNames
	,JOB.Product AS Stabilimento
	,JOB.Destination
	,JOB.PublishDate
FROM dbo.Jobs AS JOB
INNER JOIN LastJobPublishDate_CTE AS LJ ON JOB.PublishDate = LJ.LastPublishDate
GO

/****** Object:  View [dbo].[AGG_vAPS2EXT_Ordini_NEW]    Script Date: 01/04/2025 13:43:36 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER VIEW [dbo].[AGG_vAPS2EXT_Ordini_NEW]
AS
WITH LastJobPublishDate_CTE
AS (
	SELECT ExternalId AS JobExternalId
		,MAX(PublishDate) AS LastPublishDate
	FROM dbo.Jobs J
	WHERE J.Commitment = 'Firm'
	GROUP BY ExternalId
	
	UNION ALL
	
	SELECT ExternalId AS JobExternalId
		,PublishDate AS LastPublishDate
	FROM dbo.Jobs J
	WHERE J.Commitment <> 'Firm'
		AND J.PublishDate = dbo.AGG_fnGet_latestPublishDate()
	)
SELECT DISTINCT JOB.Name AS Order_Number
	,JOB.[UDF Customer UDF] AS Ordine_Cliente
	,JOB.Commitment
	,JOB.Product
	,JOB.ProductDescription
	,JOB.Description AS Codice_Matricola
	,JOB.Qty
	,CONVERT(VARCHAR, JOB.ScheduledStartDateTime, 3) AS ScheduledStartDateTime
	,CONVERT(VARCHAR, JOB.ScheduledEndDateTime, 3) AS ScheduledEndDateTime
	,CONVERT(VARCHAR, JOB.NeedDateTime, 3) AS NeedDateTime
	,CONVERT(VARCHAR, CAST(JOB.[CUS_DataRTS UDF] AS DATE), 3) AS Data_RTS
	,CONVERT(VARCHAR, JOB.[UDF DataInizioJob UDF], 11) AS DataInizioJob
	,JOB.LatenessDays
	,JOB.ResourceNames
	,JOB.Product AS Stabilimento
	,JOB.PublishDate
FROM dbo.Jobs AS JOB
INNER JOIN LastJobPublishDate_CTE AS LJ ON JOB.ExternalId = LJ.JobExternalId
	AND JOB.PublishDate = LJ.LastPublishDate
GO

/****** Object:  View [dbo].[CAT_vAPS2EXT_Offline_Puntuale]    Script Date: 01/04/2025 13:43:36 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER VIEW [dbo].[CAT_vAPS2EXT_Offline_Puntuale]
AS
WITH LastJobPublishDate_CTE
AS (
	SELECT MAX(PublishDate) AS LastPublishDate
	FROM dbo.Jobs
	)
SELECT rs.Name
	,rs.Description
	,rc.StartDateTime
	,rc.EndDateTime
FROM [PlanetTogether_Export_OOM_CAT_PRD].[dbo].[CapacityIntervals] AS RC
INNER JOIN dbo.CapacityIntervalResourceAssignments AS RA ON rc.CapacityIntervalId = ra.CapacityIntervalId
	AND ra.PublishDate = rc.PublishDate
INNER JOIN dbo.Resources AS RS ON Rs.ResourceId = ra.ResourceId
INNER JOIN LastJobPublishDate_CTE AS LJ ON rc.PublishDate = LJ.LastPublishDate
WHERE rc.IntervalType = 'Offline'
GO

/****** Object:  View [dbo].[CAT_vAPS2EXT_Offline_Ricorrente]    Script Date: 01/04/2025 13:43:36 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER VIEW [dbo].[CAT_vAPS2EXT_Offline_Ricorrente]
AS
WITH LastJobPublishDate_CTE
AS (
	SELECT MAX(PublishDate) AS LastPublishDate
	FROM dbo.Jobs
	)
SELECT rs.Name
	,rs.Description
	,ir.StartDateTime
	,ir.EndDateTime
FROM [PlanetTogether_Export_OOM_CAT_PRD].[dbo].[RecurringCapacityIntervals] AS RC
INNER JOIN dbo.RecurringCapacityIntervalRecurrences AS IR ON rc.RecurringCapacityIntervalId = ir.RecurringCapacityIntervalId
	AND rc.PublishDate = ir.PublishDate
INNER JOIN dbo.RecurringCapacityIntervalResourceAssignments AS RA ON rc.RecurringCapacityIntervalId = ra.RecurringCapacityIntervalId
	AND ra.PublishDate = ir.PublishDate
INNER JOIN dbo.Resources AS RS ON rs.ResourceId = ra.ResourceId
INNER JOIN LastJobPublishDate_CTE AS LJ ON rc.PublishDate = LJ.LastPublishDate
WHERE rc.IntervalType = 'Offline'
GO


/****** Object:  StoredProcedure [dbo].[AGG_sExportData]    Script Date: 02/04/2025 10:09:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		ADL
-- Create date: 22/12/23
-- Description:	Export procedure
-- =============================================
ALTER PROCEDURE [dbo].[AGG_sExportData] 
  @MES varchar(255) = ''
 ,@ERP varchar(255) = ''
, @PlanetTogether_Import varchar(255) = 'PlanetTogether_Import'
, @PlanetTogether_Export varchar(255) = 'PlanetTogether_Export'
, @ErrMess varchar(8000) = '' OUTPUT
, @ReturnCode int = 0 OUTPUT -- 0 = OK, 1 = WARNING, -1 = ERROR
, @PublishDate DateTime = null
, @UserDefinedParameter  varchar(8000) = '' OUTPUT
, @Message  varchar(8000) = '' OUTPUT
, @Undo bit = -1 OUTPUT
	-- Add the parameters for the stored procedure here
AS
BEGIN

SELECT 1
END
GO
