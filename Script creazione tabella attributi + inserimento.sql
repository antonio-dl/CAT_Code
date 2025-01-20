/****** Object:  Table [import].[PT_Attributes]    Script Date: 10/01/2025 14:14:17 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [PT_Attributes](
	[ExternalId] [varchar](100) NOT NULL,
	[AttributeTrigger] [varchar](100) NULL,
	[AttributeType] [varchar](100) NULL,
	[CleanoutGrade] [int] NULL,
	[ColorCode] [varchar](100) NULL,
	[ConsecutiveSetup] [bit] NULL,
	[DefaultCost] [float] NULL,
	[DefaultDurationHrs] [float] NULL,
	[Description] [varchar](100) NULL,
	[HideInGrids] [bit] NULL,
	[Name] [varchar](100) NULL,
	[ShowInGantt] [bit] NULL,
	[UseInSequencing] [bit] NULL,
	[FlagInternal] [bit] NULL,
	[FlagEnabled] [bit] NULL,
	[FirstUser] [varchar](100) NULL,
	[LastUser] [varchar](100) NULL,
 CONSTRAINT [PK_import.PT_Attributes] PRIMARY KEY CLUSTERED 
(
	[ExternalId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO




INSERT INTO [import].[PT_Attributes]
           ([ExternalId]
           ,[AttributeTrigger]
           ,[AttributeType]
           ,[CleanoutGrade]
           ,[ColorCode]
           ,[ConsecutiveSetup]
           ,[DefaultCost]
           ,[DefaultDurationHrs]
           ,[Description]
           ,[HideInGrids]
           ,[Name]
           ,[ShowInGantt]
           ,[UseInSequencing]
           ,[FirstUser]
           ,[LastUser]
           ,[FlagInternal]
           ,[FlagEnabled])
     VALUES
           ('MATRICOLA'
           ,'Never'
           ,'Setup'
           ,NULL
           ,NULL
           ,1
           ,NULL
           ,0
           ,'MATRICOLA'
           ,0
           ,'MATRICOLA'
           ,1
           ,NULL
           ,'MES'
           ,'MES'
           ,1
           ,1),

		    ('PRODUCT'
           ,'Never'
           ,'Setup'
           ,NULL
           ,NULL
           ,1
           ,NULL
           ,0
           ,'PRODUCT'
           ,0
           ,'PRODUCT'
           ,1
           ,NULL
           ,'MES'
           ,'MES'
           ,1
           ,1)

GO

Select * from OperationAttribute

Select * from PT_TME_UAE_DEV.import.PT_Attributes