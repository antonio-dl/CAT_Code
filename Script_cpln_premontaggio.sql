SELECT *
	,JobExternalId + '_PRM' AS PremontaggioMO
INTO #PremontaggiCPLN
FROM ResourceOperations
WHERE CustomizerString2 = 'SF'
	AND OperationSequence = 10

INSERT INTO [dbo].[ManufacturingOrders] (
	[ExternalId]
	,[JobExternalId]
	,[Name]
	,[Description]
	,[Notes]
	,[RequiredQty]
	,[ExpectedFinishQty]
	,[Family]
	,[IsReleased]
	,[MoNeedDate]
	,[NeedDate]
	,[ProductColor]
	,[ProductDescription]
	,[ProductName]
	,[ReleaseDateTime]
	,[UOM]
	,[Hold]
	,[HoldUntilDate]
	,[DefaultPathExternalId]
	,[UserFields]
	,[FirstUser]
	,[LastUser]
	,[FlagInternal]
	,[FlagEnabled]
	)
SELECT PRM.PremontaggioMO AS [ExternalId]
	,MO.[JobExternalId] AS [JobExternalId]
	,MO.[Name] AS [Name]
	,MO.[Description] AS [Description]
	,MO.[Notes] AS [Notes]
	,MO.[RequiredQty] AS [RequiredQty]
	,MO.[ExpectedFinishQty] AS [ExpectedFinishQty]
	,MO.[Family] AS [Family]
	,MO.[IsReleased] AS [IsReleased]
	,MO.[MoNeedDate] AS [MoNeedDate]
	,MO.[NeedDate] AS [NeedDate]
	,MO.[ProductColor] AS [ProductColor]
	,MO.[ProductDescription] AS [ProductDescription]
	,MO.[ProductName] AS [ProductName]
	,MO.[ReleaseDateTime] AS [ReleaseDateTime]
	,MO.[UOM] AS [UOM]
	,MO.[Hold] AS [Hold]
	,MO.[HoldUntilDate] AS [HoldUntilDate]
	,PRM.PremontaggioMO AS [DefaultPathExternalId]
	,MO.[UserFields] AS [UserFields]
	,'APS' AS [FirstUser]
	,'APS' AS [LastUser]
	,MO.[FlagInternal] AS [FlagInternal]
	,MO.[FlagEnabled] AS [FlagEnabled]
FROM ManufacturingOrders MO
JOIN #PremontaggiCPLN PRM ON MO.JobExternalId = PRM.JobExternalId

UPDATE ResourceOperations
SET MOExternalId = PRM.PremontaggioMO
FROM #PremontaggiCPLN PRM
WHERE ResourceOperations.ExternalId = PRM.ExternalId

UPDATE InternalActivities
SET MOExternalId = PRM.PremontaggioMO
FROM #PremontaggiCPLN PRM
WHERE InternalActivities.OpExternalId = PRM.ExternalId

UPDATE ResourceRequirements
SET MOExternalId = PRM.PremontaggioMO
FROM #PremontaggiCPLN PRM
WHERE ResourceRequirements.OpExternalId = PRM.ExternalId

UPDATE RequiredCapabilities
SET MOExternalId = PRM.PremontaggioMO
FROM #PremontaggiCPLN PRM
WHERE RequiredCapabilities.OpExternalId = PRM.ExternalId

INSERT INTO [dbo].[AlternatePaths] (
	[ExternalId]
	,[JobExternalId]
	,[MOExternalId]
	,[Name]
	,[Description]
	,[Notes]
	,[AutoBuildLinearPath]
	,[Preference]
	,[AutoUse]
	,[AutoUseReleaseOffsetDays]
	,[FirstUser]
	,[LastUser]
	,[FlagInternal]
	,[FlagEnabled]
	)
SELECT 
	 PRM.PremontaggioMO AS [ExternalId]
	,AP.[JobExternalId] AS [JobExternalId]
	,PRM.PremontaggioMO AS [MOExternalId]
	,AP.[Name] AS [Name]
	,AP.[Description] AS [Description]
	,AP.[Notes] AS [Notes]
	,AP.[AutoBuildLinearPath] AS [AutoBuildLinearPath]
	,AP.[Preference] AS [Preference]
	,AP.[AutoUse] AS [AutoUse]
	,AP.[AutoUseReleaseOffsetDays] AS [AutoUseReleaseOffsetDays]
	,'APS' AS [FirstUser]
	,'APS' AS [LastUser]
	,AP.[FlagInternal] AS [FlagInternal]
	,AP.[FlagEnabled] AS [FlagEnabled]
FROM AlternatePaths AP
JOIN #PremontaggiCPLN PRM ON AP.JobExternalId = PRM.JobExternalId

UPDATE AlternatePathNodes
SET MOExternalId = PRM.PremontaggioMO
,SuccessorOperationExternalId = NULL
FROM #PremontaggiCPLN PRM
WHERE AlternatePathNodes.PredecessorOperationExternalId = PRM.ExternalId
