--*****************************************************Mapping Tables**********************************************************************************************
--AutoEnrollment and WorkFlow#2 SCRIPTS

Create Table customer.RegisteredStatusByPOGMap    
(
RegisteredStatusByPOGMapId INT IDENTITY NOT NULL UNIQUE CLUSTERED,
InitialSySchoolStatusID INT NOT NULL,
FinalSySchoolStatusID INT NOT NULL,
[Description] VARCHAR(MAX) NOT NULL,
DateAdded DATETIME NOT NULL,
DateLstMod DATETIME NOT NULL
CONSTRAINT [PK_RegisteredStatusByPOGMap] PRIMARY KEY  
(InitialSySchoolStatusID,FinalSySchoolStatusID))
GO
---- make sure below ID's are in sync with Prod tables
INSERT INTO customer.RegisteredStatusByPOGMap(InitialSySchoolStatusID,FinalSySchoolStatusID,[Description],DateAdded,DateLstMod)VALUES
(60,79,'Status Change (Provisionally Accepted, POG => Accepted)',GETDATE(),''),
(101,7,'Status Change (Provisionally ReEntry,POG => ReEntry)',GETDATE(),''),
(61,92,'Status Change (Provisionally ReAdmit,POG => ReAdmit)',GETDATE(),''),
(93,96,'Status Change (Registered Provisionally Accepted, POG => Registered Accepted)',GETDATE(),''),
(102,103,'Status Change (Registered Provisionally ReEntry,POG => Registered ReEntry)',GETDATE(),''),
(95,98,'Status Change (Registered Provisionally ReAdmit => Registered ReAdmit)',GETDATE(),''),
(90,13,'Status Change (Provisionally Active,POG => Active)',GETDATE(),'')
GO

--WORKFLOW#1 SCRIPTS

Create Table customer.RegisteredStatusByCourseMap
(
RegisteredStatusByCourseMapId INT IDENTITY NOT NULL UNIQUE CLUSTERED,
InitialSySchoolStatusID INT NOT NULL,
CourseSelected VARCHAR(1) NOT NULL,
FinalSySchoolStatusID INT NOT NULL,
[Description] VARCHAR(MAX) NOT NULL,
DateAdded DATETIME NOT NULL,
DateLstMod DATETIME NOT NULL,
CONSTRAINT [PK_RegisteredStatusByCourseMap] PRIMARY KEY 
(InitialSySchoolStatusID,CourseSelected,FinalSySchoolStatusID))
GO

---- make sure below ID's are in sync with Prod tables

INSERT INTO customer.RegisteredStatusByCourseMap (InitialSySchoolStatusID,CourseSelected,FinalSySchoolStatusID,[Description],DateAdded,DateLstMod) VALUES
--Forward Status
(60,'Y',93,'Status Change from Provisionally Accepted to Registered Provisionally Accepted',GetDate(),''),
(101,'Y',102,'Status Change from Provisionally ReEntry to Registered Provisionally ReEntry',GetDate(),''),
(61,'Y',95,'Status Change from Provisionally ReAdmit to Registered Provisionally ReAdmit',GetDate(),''),
(79,'Y',96,'Status Change from Accepted to Registered Accepted',GetDate(),''),
(7,'Y',103,'Status Change from ReEntry to Registered ReEntry',GetDate(),''),
(92,'Y',98,'Status Change from ReAdmit to Registered ReAdmit',GetDate(),''),
--Reverse Staus
(93,'N',60,'Status Change from Registered Provisionally Accepted to Provisionally Accepted',GetDate(),''),
(102,'N',101,'Status Change from Registered Provisionally ReEntry to Provisionally ReEntry',GetDate(),''),
(95,'N',61,'Status Change from Registered Provisionally ReAdmit to Provisionally ReAdmit',GetDate(),''),
(96,'N',79,'Status Change from Registered Accepted to Accepted',GetDate(),''),
(103,'N',7,'Status Change from Registered ReEntry to ReEntry',GetDate(),''),
(98,'N',92,'Status Change from Registered ReAdmit to ReAdmit',GetDate(),'')
GO

--*******************************************CUSTOMER_SCHEMA--Si_Configurations & SP*****************************************************************************
--Customer Schema Config Table
CREATE TABLE [customer].[si_Configurations](
	[ConfigurationId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[Key] [varchar](200) NOT NULL,
	[Value] [varchar](max) NOT NULL,
	[DataType] [varchar](50) NOT NULL,
	[DisplayOrder] [int] NOT NULL,
	[Prompt] [varchar](50) NOT NULL,
	[ListType] [char](1) NOT NULL,
	[ValueList] [varchar](1000) NULL,
	[LongPrompt] [varchar](255) NOT NULL,
	[MaxLength] [tinyint] NOT NULL,
	[UserId] [int] NOT NULL,
	[DateAdded] [datetime] NOT NULL,
	[DateLstMod] [datetime] NOT NULL,
	[TS] [timestamp] NOT NULL,
	[ConfigType] [varchar](1) NOT NULL,
	[PackageNameId] [int] NULL,
 CONSTRAINT [PK_si_Configurations_ConfigurationId] PRIMARY KEY CLUSTERED 
(
	[ConfigurationId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

ALTER TABLE [customer].[si_Configurations] ADD  CONSTRAINT [Def_si_Configurations_DateAdded]  DEFAULT (getdate()) FOR [DateAdded]
GO

ALTER TABLE [customer].[si_Configurations] ADD  CONSTRAINT [Def_si_Configurations_DateLstMod]  DEFAULT (getdate()) FOR [DateLstMod]
GO

ALTER TABLE [customer].[si_Configurations] ADD  DEFAULT ('G') FOR [ConfigType]
GO

--Customer Schema Config Data 
Insert Into [customer].[si_Configurations]([Key],[Value],[DataType],[DisplayOrder],[Prompt],[ListType],[ValueList],[LongPrompt],[MaxLength],[UserId],[DateAdded]) values
('GetAutoEnroll_ProvisionallyAcceptedStatusCode','PROVACC','',40,'AutoEnroll_ProvisionallyAcceptedStatusCode','s','select code, descrip from syschoolstatus (nolock) where active=1 order by code','Provisionally Accepted Ending status for AutoEnrollment Workflow',0,1,GETDATE()),
('GetAutoEnroll_ProvisionallyRe-EntryStatusCode','PRVREN2','',40,'AutoEnroll_ProvisionallyRe-EntryStatusCode','s','select code, descrip from syschoolstatus (nolock) where active=1 order by code','Provisionally Re-Entry Ending status for AutoEnrollment Workflow',0,1,GETDATE()),
('GetAutoEnroll_ProvisionallyRe-AdmitStatusCode','PROVREAD','',40,'AutoEnroll_ProvisionallyRe-AdmitStatusCode','s','select code, descrip from syschoolstatus (nolock) where active=1 order by code','Provisionally Re-Admit Ending status for AutoEnrollment Workflow',0,1,GETDATE()),
('GetRegistered_SchoolStatus_TriggerStatusCode','ACCEPT,PROVACC,PROVREAD,PRVREN2,READM,REENTRY','',40,'Registered_SchoolStatus_TriggerStatusCode','m','select code, descrip from syschoolstatus (nolock) where active=1 order by code','Valid Status Codes to change Registered School Status',0,1,GETDATE()),
('GetRegistered_SchoolStatus_ReverseTriggerStatusCode','REGPROAC,REGPRVRA,REGPRVRE,REGACC,REGREADM,REGRNE','',40,'Registered_SchoolStatus_ReverseTriggerStatusCode','m','select code, descrip from syschoolstatus (nolock) where active=1 order by code','Valid Status Codes to change Non-Registered School Staus Change',0,1,GETDATE()),
('GetAdvisorAssignment_TriggerStatusCodes','ACCEPT,NDSENR,PROVACC,PROVREAD,PRVREN2,READM,REENTRY','',40,'AdvisorAssignment_TriggerStatusCodes','m','select code, descrip from syschoolstatus (nolock) where active=1 order by code','Valid Status codes for advisor assignment',0,1,GETDATE())
GO

--SP Depends on Configs

DROP PROCEDURE [customer].[SPROC_Registered_SchoolStatus_GetConfiguration]
GO
CREATE PROCEDURE [customer].[SPROC_Registered_SchoolStatus_GetConfiguration] @AdenrollID Int  
AS  
BEGIN  
 BEGIN TRANSACTION  
 BEGIN TRY  
  
 BEGIN  
 DECLARE @ValidStatusToMoveStatusForward VARCHAR(MAX)  
 DECLARE @ValidStatusToReverseStatusBack VARCHAR(MAX)
 ----Begin validTriggeringStatus Check
 SELECT @ValidStatusToMoveStatusForward = [value]  
 FROM [customer].[si_Configurations] a(NOLOCK)  
 WHERE [Key] = 'GetRegistered_SchoolStatus_TriggerStatusCode'  
 --select * from [customer].[si_Configurations] a (NOLOCK) WHERE [Key] = 'GetRegistered_SchoolStatus_TriggeringStatusCode'  
  
 CREATE TABLE #SySchoolStatus (  
  Id INT  
 ,Code VARCHAR(50)  
 )  
  
 INSERT INTO #SySchoolStatus (  
  Id  
 ,Code  
 )  
 SELECT 0  
 ,rtrim(ltrim(ListValue))  
 FROM dbo.dv_StrSplit(@ValidStatusToMoveStatusForward, ',')  
  
 UPDATE #SySchoolStatus  
 SET Id = b.SySchoolStatusId  
 FROM #SySchoolStatus a  
 JOIN SySchoolStatus b(NOLOCK)  
 ON b.Code = a.Code  
  
 -----Begin validReverseTriggeringStatus Check
  SELECT @ValidStatusToReverseStatusBack = [value]  
 FROM [customer].si_Configurations a(NOLOCK)  
 WHERE [Key] = 'GetRegistered_SchoolStatus_ReverseTriggerStatusCode'  
 --select * from [customer].si_Configurations a (NOLOCK) WHERE [Key] = 'GetRegistered_SchoolStatus_ReverseTriggerStatusCode'  
  
 CREATE TABLE #SyReverseSchoolStatus (  
  Id INT  
 ,Code VARCHAR(50)  
 )  
  
 INSERT INTO #SyReverseSchoolStatus (  
  Id  
 ,Code  
 )  
 SELECT 0  
 ,rtrim(ltrim(ListValue))  
 FROM dbo.dv_StrSplit(@ValidStatusToReverseStatusBack, ',')  
  
 UPDATE #SyReverseSchoolStatus  
 SET Id = b.SySchoolStatusId  
 FROM #SyReverseSchoolStatus a  
 JOIN SySchoolStatus b(NOLOCK)  
 ON b.Code = a.Code


 SELECT 
 CASE WHEN EXISTS  
  (  
  SELECT *  
  FROM Adenroll (Nolock)  
  JOIN #SySchoolStatus ON Adenroll.SyschoolstatusID = #SySchoolStatus.id  
  --WHERE AdenrollID = 71739  
  WHERE AdenrollID = @AdenrollID  
  )  
 THEN 'True'  
 ELSE 'False'  
 END as IsValidToMoveStatusForward,  
 CASE WHEN EXISTS  
  (  
  SELECT *  
  FROM Adenroll (Nolock)  
  JOIN #SyReverseSchoolStatus ON Adenroll.SyschoolstatusID = #SyReverseSchoolStatus.id  
  --WHERE AdenrollID = 71736  
  WHERE AdenrollID = @AdenrollID  
  )  
 THEN 'True'  
 ELSE 'False'  
 END as IsValidToReverseStatusBack,

   Count(*) AS RegisteredCourseStatusCount  
  FROM AdEnrollSched (Nolock)  
  --WHERE AdenrollID = 71736  
  WHERE AdenrollID = @AdenrollID and Status IN ('C','S')  
 END  
  
 IF OBJECT_ID('tempdb..#SySchoolStatus') IS NOT NULL  
 DROP TABLE #SySchoolStatus  
 IF OBJECT_ID('tempdb..#SyReverseSchoolStatus') IS NOT NULL  
 DROP TABLE #SyReverseSchoolStatus  
  
 COMMIT TRANSACTION  
 END TRY  
  
 BEGIN CATCH  
 ROLLBACK TRANSACTION  
 END CATCH  
END 

GO

--***************************************************************************CMC Schema-Si_Configurations&SP**************************************************************


--SI-CONFIGURATIONS FOR AUTOENROLLMENT
--Provisionally Accepted
Execute Cst_sproc_si_Configurations_Insert
'WF',
'GetAutoEnroll_ProvisionallyAcceptedStatusCode',
'PROVACC',
'',
40,
'AutoEnroll_ProvisionallyAcceptedStatusCode',
's',
'select code, descrip from syschoolstatus (nolock) where active=1 order by code',
'Provisionally Accepted Ending status for AutoEnrollment Workflow',
0,
1,
'G'
GO
--Provisionally Re-Entry
Execute Cst_sproc_si_Configurations_Insert
'WF',
'GetAutoEnroll_ProvisionallyRe-EntryStatusCode',
'PRVREN2',
'',
40,
'AutoEnroll_ProvisionallyRe-EntryStatusCode',
's',
'select code, descrip from syschoolstatus (nolock) where active=1 order by code',
'Provisionally Re-Entry Ending status for AutoEnrollment Workflow',
0,
1,
'G'
GO
--Provisionally Re-Admit
Execute Cst_sproc_si_Configurations_Insert
'WF',
'GetAutoEnroll_ProvisionallyRe-AdmitStatusCode',
'PROVREAD',
'',
40,
'AutoEnroll_ProvisionallyRe-AdmitStatusCode',
's',
'select code, descrip from syschoolstatus (nolock) where active=1 order by code',
'Provisionally Re-Admit Ending status for AutoEnrollment Workflow',
0,
1,
'G'
GO
--SI-CONFIGURATIONS FOR WORKFLOW#1
Execute Cst_sproc_si_Configurations_Insert
'WF',
'GetRegistered_SchoolStatus_TriggerStatusCode',
'ACCEPT,PROVACC,PROVREAD,PRVREN2,READM,REENTRY',
'',
40,
'Registered_SchoolStatus_TriggerStatusCode',
'm',
'select code, descrip from syschoolstatus (nolock) where active=1 order by code',
'Status Code for Registered School Staus Change',
0,
1,
'G'
GO

Execute Cst_sproc_si_Configurations_Insert
'WF',
'GetRegistered_SchoolStatus_ReverseTriggerStatusCode',
'REGPROAC,REGPRVRA,REGPRVRE,REGACC,REGREADM,REGRNE',
'',
40,
'Registered_SchoolStatus_ReverseTriggerStatusCode',
'm',
'select code, descrip from syschoolstatus (nolock) where active=1 order by code',
'Status Code for Registered School Staus Change',
0,
1,
'G'
GO


--Update PakageNameId for all new configurations


update si_Configurations set PackageNameId=2 where ConfigurationId In('')
Go

--SP for WORKFLOW#1

CREATE PROCEDURE [customer].[SPROC_Registered_SchoolStatus_GetConfiguration] @AdenrollID Int  
AS  
BEGIN  
 BEGIN TRANSACTION  
 BEGIN TRY  
  
 BEGIN  
 DECLARE @ValidStatusToMoveStatusForward VARCHAR(MAX)  
 DECLARE @ValidStatusToReverseStatusBack VARCHAR(MAX)
 ----Begin validTriggeringStatus Check
 SELECT @ValidStatusToMoveStatusForward = [value]  
 FROM si_Configurations a(NOLOCK)  
 WHERE [Key] = 'GetRegistered_SchoolStatus_TriggerStatusCode'  
 --select * from si_Configurations a (NOLOCK) WHERE [Key] = 'GetRegistered_SchoolStatus_TriggeringStatusCode'  
  
 CREATE TABLE #SySchoolStatus (  
  Id INT  
 ,Code VARCHAR(50)  
 )  
  
 INSERT INTO #SySchoolStatus (  
  Id  
 ,Code  
 )  
 SELECT 0  
 ,rtrim(ltrim(ListValue))  
 FROM dbo.dv_StrSplit(@ValidStatusToMoveStatusForward, ',')  
  
 UPDATE #SySchoolStatus  
 SET Id = b.SySchoolStatusId  
 FROM #SySchoolStatus a  
 JOIN SySchoolStatus b(NOLOCK)  
 ON b.Code = a.Code  
  
 -----Begin validReverseTriggeringStatus Check
  SELECT @ValidStatusToReverseStatusBack = [value]  
 FROM si_Configurations a(NOLOCK)  
 WHERE [Key] = 'GetRegistered_SchoolStatus_ReverseTriggerStatusCode'  
 --select * from si_Configurations a (NOLOCK) WHERE [Key] = 'GetRegistered_SchoolStatus_ReverseTriggerStatusCode'  
  
 CREATE TABLE #SyReverseSchoolStatus (  
  Id INT  
 ,Code VARCHAR(50)  
 )  
  
 INSERT INTO #SyReverseSchoolStatus (  
  Id  
 ,Code  
 )  
 SELECT 0  
 ,rtrim(ltrim(ListValue))  
 FROM dbo.dv_StrSplit(@ValidStatusToReverseStatusBack, ',')  
  
 UPDATE #SyReverseSchoolStatus  
 SET Id = b.SySchoolStatusId  
 FROM #SyReverseSchoolStatus a  
 JOIN SySchoolStatus b(NOLOCK)  
 ON b.Code = a.Code


 SELECT 
 CASE WHEN EXISTS  
  (  
  SELECT *  
  FROM Adenroll (Nolock)  
  JOIN #SySchoolStatus ON Adenroll.SyschoolstatusID = #SySchoolStatus.id  
  --WHERE AdenrollID = 71739  
  WHERE AdenrollID = @AdenrollID  
  )  
 THEN 'True'  
 ELSE 'False'  
 END as IsValidToMoveStatusForward,  
 CASE WHEN EXISTS  
  (  
  SELECT *  
  FROM Adenroll (Nolock)  
  JOIN #SyReverseSchoolStatus ON Adenroll.SyschoolstatusID = #SyReverseSchoolStatus.id  
  --WHERE AdenrollID = 71736  
  WHERE AdenrollID = @AdenrollID  
  )  
 THEN 'True'  
 ELSE 'False'  
 END as IsValidToReverseStatusBack,

   Count(*) AS RegisteredCourseStatusCount  
  FROM AdEnrollSched (Nolock)  
  --WHERE AdenrollID = 71736  
  WHERE AdenrollID = @AdenrollID and Status IN ('C','S')  
 END  
  
 IF OBJECT_ID('tempdb..#SySchoolStatus') IS NOT NULL  
 DROP TABLE #SySchoolStatus  
 IF OBJECT_ID('tempdb..#SyReverseSchoolStatus') IS NOT NULL  
 DROP TABLE #SyReverseSchoolStatus  
  
 COMMIT TRANSACTION  
 END TRY  
  
 BEGIN CATCH  
 ROLLBACK TRANSACTION  
 END CATCH  
END 

GO

--***************************************************************************Advisor Assignment Changes****************************************
Update si_Configurations set [Value]=('ACCEPT,NDSENR,PROVACC,PROVREAD,PRVREN2,READM,REENTRY') where [Key]='GetAdvisorAssignment_TriggerStatusCodes'


--*************************************************************************SQL[Execute Datareader]***********************************************************************************
--WF:AUTOENROLLMENT
--"SELECT CASE WHEN NOT EXISTS(SELECT * FROM AdEnroll E (NOLOCK) JOIN AdprogramVersion PV (NOLOCK) ON E.AdprogramVersionID = PV.AdProgramVersionID WHERE  SystudentID =  " & Entity.StudentId & " AND AdenrollID <> " & entity.Id & " AND E.Applicant=0) THEN (SELECT SS.SySchoolStatusID FROM [customer].[si_Configurations] SI (NOLOCK) JOIN SySchoolStatus SS (NOLOCK) ON SI.[Value] = SS.Code WHERE [Key] = 'GetAutoEnroll_ProvisionallyAcceptedStatusCode') WHEN EXISTS(SELECT * FROM AdEnroll E (NOLOCK) JOIN AdprogramVersion PV (NOLOCK) ON E.AdprogramVersionID = PV.AdProgramVersionID WHERE   SystudentID =  " & Entity.StudentId & " AND AdenrollID <> " & entity.Id & " AND E.Applicant=0 AND E.EnrollDate BETWEEN DATEADD(yy,-1,GETDATE()) and GETDATE()) THEN (SELECT SS.SySchoolStatusID FROM [customer].[si_Configurations] SI (NOLOCK) JOIN SySchoolStatus SS (NOLOCK) ON SI.[Value] = SS.Code WHERE [Key] = 'GetAutoEnroll_ProvisionallyRe-EntryStatusCode') ELSE (SELECT SS.SySchoolStatusID FROM [customer].[si_Configurations] SI (NOLOCK) JOIN SySchoolStatus SS (NOLOCK) ON SI.[Value] = SS.Code WHERE [Key] = 'GetAutoEnroll_ProvisionallyRe-AdmitStatusCode') END as InitialSchoolStatusID"
--String.Format("Select FinalSySchoolStatusID as FinalSchoolStatusID from customer.RegisteredStatusByPOGMap Where InitialSySchoolStatusID={0}",InitialSchoolStatusID)
--WF:WF#1
--string.Format("EXECUTE [customer].[SPROC_Registered_SchoolStatus_GetConfiguration] {0}",StudentEnrollmentPeriod.Id)
--String.Format("Select FinalSySchoolStatusID from customer.RegisteredStatusByCourseMap Where InitialSySchoolStatusID='{0}' and CourseSelected='{1}'",StudentEnrollmentPeriod.SchoolStatusId,CourseSelected)
--WF:WF#2
--String.Format("Select FinalSySchoolStatusID as FinalSchoolStatusID from customer.RegisteredStatusByPOGMap Where InitialSySchoolStatusID={0}",item.SchoolStatusId)

