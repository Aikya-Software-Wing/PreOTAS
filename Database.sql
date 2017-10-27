USE [RNSIT]
GO
/****** Object:  UserDefinedFunction [dbo].[fnGetNmberOfCombinatiosOfSubjects]    Script Date: 10/27/2017 8:27:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [dbo].[fnGetNmberOfCombinatiosOfSubjects](@usn varchar(20)) returns integer
as
begin
	declare @total integer

	set @total = (select count(*) as total from
(
SELECT  
	Subcomb.CombId,
	SubComb.[SubCode],
	[Subject].SubName,
    Teacher.TeacherName,
	SubComb.Elective  
  FROM [RNSIT].[dbo].[SubComb], STUDENT, Teacher, [Subject]
  where SubComb.TID = Teacher.TID and SubComb.SubCode = [Subject].SubCode and
  SubComb.DeptId = STUDENT.DeptID and SubComb.Sem = STUDENT.Sem and
  SubComb.Section = STUDENT.Section and STUDENT.USN = @usn
  and SubComb.Elective = 0
	union

SELECT  
	Subcomb.CombId,
	SubComb.[SubCode],
	[Subject].SubName,
    Teacher.TeacherName,
	SubComb.Elective  
  FROM [RNSIT].[dbo].[SubComb], STUDENT S, Teacher, [Subject], NewElectivesTable E
  where SubComb.TID = Teacher.TID and SubComb.SubCode = [Subject].SubCode and
  SubComb.DeptId = S.DeptID and SubComb.Sem = S.Sem and
  SubComb.Section = S.Section and e.USN = S.USN and S.USN = @usn and e.SubCode = SubComb.SubCode
  and SubComb.[SubCode] in (select N.SubCode from NewElectivesTable N where n.USN = @usn)
  )tbl)

	return @total
end

GO
/****** Object:  Table [dbo].[STUDENT]    Script Date: 10/27/2017 8:27:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[STUDENT](
	[USN] [nvarchar](50) NOT NULL,
	[NAME] [nvarchar](100) NOT NULL,
	[DOB] [nvarchar](10) NULL,
	[FATHERNAME] [nvarchar](100) NULL,
	[MOTHERNAME] [nvarchar](100) NULL,
	[GUARDIANNAME] [nvarchar](100) NULL,
	[PERM_ADDRESS] [nvarchar](500) NULL,
	[LOC_ADDRESS] [nvarchar](500) NULL,
	[MOBILE] [nvarchar](10) NULL,
	[PRIMARY_CONTACT] [nvarchar](13) NULL,
	[DeptID] [nchar](10) NULL,
	[Sem] [int] NULL,
	[Section] [nchar](10) NULL,
	[EMail] [nvarchar](50) NULL,
	[SSLC] [decimal](4, 2) NULL,
	[PUC] [decimal](4, 2) NULL,
	[Batch] [int] NULL,
	[isVallid] [bit] NULL,
 CONSTRAINT [PK_STUDENT] PRIMARY KEY CLUSTERED 
(
	[USN] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ValidS]    Script Date: 10/27/2017 8:27:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ValidS](
	[USN] [nvarchar](50) NOT NULL,
	[PASSGEN] [varchar](50) NULL,
	[COUNTER] [int] NOT NULL,
	[FG] [bit] NOT NULL,
	[STUDENTDETAILS] [bit] NOT NULL,
 CONSTRAINT [PK_ValidS] PRIMARY KEY CLUSTERED 
(
	[USN] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  View [dbo].[CountStatus]    Script Date: 10/27/2017 8:27:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[CountStatus]
AS
SELECT        TOP (100) PERCENT Q1.DeptID, Q1.Sem, Q1.Section, Q1.Given, Q2.NotGiven
FROM            (SELECT        dbo.STUDENT.DeptID, dbo.STUDENT.Sem, dbo.STUDENT.Section, COUNT(*) AS Given
                          FROM            dbo.ValidS INNER JOIN
                                                    dbo.STUDENT ON dbo.ValidS.USN = dbo.STUDENT.USN
                          WHERE        (dbo.ValidS.FG = 1)
                          GROUP BY dbo.STUDENT.DeptID, dbo.STUDENT.Sem, dbo.STUDENT.Section) AS Q1 INNER JOIN
                             (SELECT        STUDENT_1.DeptID, STUDENT_1.Sem, STUDENT_1.Section, COUNT(*) AS NotGiven
                               FROM            dbo.ValidS AS ValidS_1 INNER JOIN
                                                         dbo.STUDENT AS STUDENT_1 ON ValidS_1.USN = STUDENT_1.USN
                               WHERE        (ValidS_1.FG = 0)
                               GROUP BY STUDENT_1.DeptID, STUDENT_1.Sem, STUDENT_1.Section) AS Q2 ON Q1.DeptID = Q2.DeptID AND Q1.Sem = Q2.Sem AND Q1.Section = Q2.Section
ORDER BY Q1.DeptID, Q1.Sem, Q1.Section

GO
/****** Object:  Table [dbo].[Subject]    Script Date: 10/27/2017 8:27:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Subject](
	[SubCode] [nvarchar](50) NOT NULL,
	[SubName] [nchar](100) NOT NULL,
	[Sem] [int] NOT NULL,
	[DeptId] [nchar](10) NULL,
	[Elective] [int] NULL,
 CONSTRAINT [PK_Subject] PRIMARY KEY CLUSTERED 
(
	[SubCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[SubComb]    Script Date: 10/27/2017 8:27:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SubComb](
	[CombId] [nvarchar](50) NOT NULL,
	[TID] [nvarchar](50) NOT NULL,
	[SubCode] [nvarchar](50) NOT NULL,
	[Sem] [int] NOT NULL,
	[DeptId] [nchar](10) NOT NULL,
	[Section] [nchar](10) NOT NULL,
	[CGPA] [numeric](20, 3) NULL,
	[Elective] [bit] NULL,
	[Count] [int] NOT NULL,
	[Percentile] [numeric](20, 3) NULL,
	[ClassesHeld] [int] NULL,
	[isValid] [bit] NULL,
 CONSTRAINT [PK_SubComb_2] PRIMARY KEY CLUSTERED 
(
	[CombId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Teacher]    Script Date: 10/27/2017 8:27:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Teacher](
	[TID] [nvarchar](50) NOT NULL,
	[TeacherName] [nvarchar](100) NOT NULL,
	[DeptId] [nchar](10) NOT NULL,
	[Designation] [nvarchar](50) NOT NULL,
	[E-mail] [nchar](100) NULL,
	[password] [nvarchar](50) NULL,
 CONSTRAINT [PK_Teacher] PRIMARY KEY CLUSTERED 
(
	[TID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  View [dbo].[vwCGPAReport]    Script Date: 10/27/2017 8:27:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[vwCGPAReport]
as
select subcomb.SubCode,Subject.SubName,Teacher.TeacherName,SubComb.DeptId,subcomb.Sem,subcomb.Section,CGPA
from Teacher,SubComb,Subject
where SubComb.SubCode=Subject.SubCode and Teacher.TID=SubComb.TID 

GO
/****** Object:  View [dbo].[vwCGPAReportSortedByDepartment]    Script Date: 10/27/2017 8:27:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[vwCGPAReportSortedByDepartment]
as


select subcomb.SubCode,Subject.SubName,Teacher.TeacherName,Teacher.DeptId,subcomb.Sem,subcomb.Section,CGPA
from Teacher,SubComb,Subject
where SubComb.SubCode=Subject.SubCode and Teacher.TID=SubComb.TID 
GO
/****** Object:  View [dbo].[sucombs]    Script Date: 10/27/2017 8:27:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Script for SelectTopNRows command from SSMS  ******/
CREATE VIEW [dbo].[sucombs]
AS
SELECT     TOP (100) PERCENT dbo.Teacher.TeacherName, dbo.Teacher.DeptId, dbo.SubComb.SubCode, dbo.SubComb.DeptId AS Expr1, dbo.STUDENT.Sem, 
                      dbo.STUDENT.Section, dbo.SubComb.CGPA, dbo.SubComb.Percentile, COUNT(dbo.STUDENT.USN) AS Total
FROM         dbo.SubComb INNER JOIN
                      dbo.Teacher ON dbo.SubComb.TID = dbo.Teacher.TID INNER JOIN
                      dbo.STUDENT ON dbo.SubComb.DeptId = dbo.STUDENT.DeptID AND dbo.SubComb.Sem = dbo.STUDENT.Sem AND 
                      dbo.SubComb.Section = dbo.STUDENT.Section INNER JOIN
                      dbo.ValidS ON dbo.STUDENT.USN = dbo.ValidS.USN
GROUP BY dbo.Teacher.TeacherName, dbo.Teacher.DeptId, dbo.SubComb.SubCode, dbo.SubComb.DeptId, dbo.STUDENT.Sem, dbo.STUDENT.Section, dbo.SubComb.CGPA, 
                      dbo.SubComb.Percentile
ORDER BY dbo.Teacher.DeptId, dbo.STUDENT.Sem, dbo.STUDENT.Section

GO
/****** Object:  Table [dbo].[Admin]    Script Date: 10/27/2017 8:27:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Admin](
	[Id] [varchar](50) NOT NULL,
	[Password] [varchar](50) NOT NULL,
	[Dept] [nchar](10) NOT NULL,
	[Roles] [varchar](50) NOT NULL,
 CONSTRAINT [PK_Admin] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  View [dbo].[vwStudentLogins]    Script Date: 10/27/2017 8:27:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
	create View [dbo].[vwStudentLogins]
	as
	select V.USN as UserName, V.PASSGEN as [Password], 'Student' as [Role]
	from ValidS V
	union
	select A.Id, A.[Password], A.Roles
	from [Admin] A
GO
/****** Object:  Table [dbo].[__MigrationHistory]    Script Date: 10/27/2017 8:27:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[__MigrationHistory](
	[MigrationId] [nvarchar](150) NOT NULL,
	[ContextKey] [nvarchar](300) NOT NULL,
	[Model] [varbinary](max) NOT NULL,
	[ProductVersion] [nvarchar](32) NOT NULL,
 CONSTRAINT [PK_dbo.__MigrationHistory] PRIMARY KEY CLUSTERED 
(
	[MigrationId] ASC,
	[ContextKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ABCD]    Script Date: 10/27/2017 8:27:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ABCD](
	[tid] [varchar](20) NOT NULL,
	[S1] [varchar](10) NULL,
	[S2] [varchar](10) NULL,
	[S3] [varchar](10) NULL,
	[S4] [varchar](10) NULL,
	[S5] [varchar](10) NULL,
	[S6] [varchar](10) NULL,
	[S7] [varchar](10) NULL,
PRIMARY KEY CLUSTERED 
(
	[tid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[AspNetRoles]    Script Date: 10/27/2017 8:27:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AspNetRoles](
	[Id] [nvarchar](128) NOT NULL,
	[Name] [nvarchar](256) NOT NULL,
 CONSTRAINT [PK_dbo.AspNetRoles] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[AspNetUserClaims]    Script Date: 10/27/2017 8:27:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AspNetUserClaims](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[UserId] [nvarchar](128) NOT NULL,
	[ClaimType] [nvarchar](max) NULL,
	[ClaimValue] [nvarchar](max) NULL,
 CONSTRAINT [PK_dbo.AspNetUserClaims] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[AspNetUserLogins]    Script Date: 10/27/2017 8:27:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AspNetUserLogins](
	[LoginProvider] [nvarchar](128) NOT NULL,
	[ProviderKey] [nvarchar](128) NOT NULL,
	[UserId] [nvarchar](128) NOT NULL,
 CONSTRAINT [PK_dbo.AspNetUserLogins] PRIMARY KEY CLUSTERED 
(
	[LoginProvider] ASC,
	[ProviderKey] ASC,
	[UserId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[AspNetUserRoles]    Script Date: 10/27/2017 8:27:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AspNetUserRoles](
	[UserId] [nvarchar](128) NOT NULL,
	[RoleId] [nvarchar](128) NOT NULL,
 CONSTRAINT [PK_dbo.AspNetUserRoles] PRIMARY KEY CLUSTERED 
(
	[UserId] ASC,
	[RoleId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[AspNetUsers]    Script Date: 10/27/2017 8:27:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AspNetUsers](
	[Id] [nvarchar](128) NOT NULL,
	[Email] [nvarchar](256) NULL,
	[EmailConfirmed] [bit] NOT NULL,
	[PasswordHash] [nvarchar](max) NULL,
	[SecurityStamp] [nvarchar](max) NULL,
	[PhoneNumber] [nvarchar](max) NULL,
	[PhoneNumberConfirmed] [bit] NOT NULL,
	[TwoFactorEnabled] [bit] NOT NULL,
	[LockoutEndDateUtc] [datetime] NULL,
	[LockoutEnabled] [bit] NOT NULL,
	[AccessFailedCount] [int] NOT NULL,
	[UserName] [nvarchar](256) NOT NULL,
 CONSTRAINT [PK_dbo.AspNetUsers] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[DEPT]    Script Date: 10/27/2017 8:27:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DEPT](
	[DeptId] [nchar](10) NOT NULL,
	[DeptName] [nvarchar](50) NOT NULL,
	[Password] [varchar](255) NULL,
	[HodPassword] [nvarchar](255) NULL,
 CONSTRAINT [PK_DEPT] PRIMARY KEY CLUSTERED 
(
	[DeptId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[GivenNotGiven]    Script Date: 10/27/2017 8:27:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[GivenNotGiven](
	[DeptID] [nchar](10) NULL,
	[DeptName] [nvarchar](50) NOT NULL,
	[Sem] [int] NULL,
	[Section] [nchar](10) NULL,
	[Given] [int] NULL,
	[NotGiven] [int] NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[LowerTable]    Script Date: 10/27/2017 8:27:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LowerTable](
	[Question] [varchar](1000) NOT NULL,
	[Ones] [int] NOT NULL,
	[Twos] [int] NOT NULL,
	[Threes] [int] NOT NULL,
	[Fours] [int] NOT NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[my1]    Script Date: 10/27/2017 8:27:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[my1](
	[USN] [nvarchar](50) NULL,
	[subcode] [nvarchar](50) NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[NEW_RID_TABLE]    Script Date: 10/27/2017 8:27:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[NEW_RID_TABLE](
	[USN] [nvarchar](50) NOT NULL,
	[RID] [nvarchar](50) NOT NULL,
	[A1] [numeric](10, 4) NOT NULL,
	[A2] [numeric](10, 4) NOT NULL,
	[A3] [numeric](10, 4) NOT NULL,
	[A4] [numeric](10, 4) NOT NULL,
	[A5] [numeric](10, 4) NOT NULL,
	[A6] [numeric](10, 4) NOT NULL,
	[A7] [numeric](10, 4) NOT NULL,
	[A8] [numeric](10, 4) NOT NULL,
	[A9] [numeric](10, 4) NOT NULL,
	[A10] [numeric](10, 4) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[USN] ASC,
	[RID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[NewElectivesTable]    Script Date: 10/27/2017 8:27:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[NewElectivesTable](
	[USN] [nvarchar](50) NOT NULL,
	[SubCode] [nvarchar](50) NOT NULL,
	[id] [int] IDENTITY(1,1) NOT NULL,
	[isValid] [bit] NULL,
 CONSTRAINT [PK_NewElectivesTable] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Suggestions]    Script Date: 10/27/2017 8:27:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Suggestions](
	[USN] [nvarchar](50) NOT NULL,
	[Suggestions] [nvarchar](1000) NULL,
	[GeneralOrOtas] [bit] NOT NULL,
	[Ratings] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[USN] ASC,
	[GeneralOrOtas] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
INSERT [dbo].[__MigrationHistory] ([MigrationId], [ContextKey], [Model], [ProductVersion]) VALUES (N'201710261437475_InitialCreate', N'PreOTAS.Models.ApplicationDbContext', 0x1F8B0800000000000400DD5C5B6FE3B6127E3FC0F90F829E7A0E522B97B38B6D60EF2275929EA09B0BD6D9A26F0B5AA21D61254A95A83441D15FD687FEA4FE850E254A166FBAD88AED140B2C2272F8CD70382487C3A1FFFAE3CFF187A730B01E7192FA1199D847A343DBC2C48D3C9F2C27764617DFBEB33FBCFFF7BFC6175EF864FD54D29D303A6849D289FD40697CEA38A9FB8043948E42DF4DA2345AD0911B850EF222E7F8F0F03BE7E8C8C100610396658D3F6584FA21CE3FE0731A1117C73443C175E4E120E5E55033CB51AD1B14E234462E9ED87709BEBD3F9B8D0A4ADB3A0B7C0452CC70B0B02D4448441105194F3FA7784693882C673114A0E0FE39C640B740418AB9ECA72BF2AEDD383C66DD70560D4B28374B6914F6043C3AE17A71E4E66B69D7AEF4069ABB000DD367D6EB5C7B13FBCAC379D1A7280005C80C4FA741C28827F675C5E22C8D6F301D950D4705E4650270BF46C9D7511DF1C0EADCEEA0B2A3E3D121FB77604DB38066099E109CD1040507D65D360F7CF747FC7C1F7DC5647272345F9CBC7BF31679276FFF874FDED47B0A7D053AA1008AEE9228C609C8861755FF6DCB11DB3972C3AA59AD4DA115B0259812B6758D9E3E62B2A40F30598EDFD9D6A5FF84BDB2841BD767E2C30C824634C9E0F3260B02340F7055EF34F264FF37703D7EF37610AE37E8D15FE6432FF1878993C0BCFA8483BC367DF0E3627A09E3FD85935D2651C8BE45FB2A6ABFCCA22C7159672223C93D4A96988AD28D9D95F17632690635BC5997A8FB6FDA4C52D5BCB5A4AC43EBCC8492C5B6674329EFCBF2ED6C7167710C83979B16D34893C1891BD5486A097650D4AF4CE6A8ABC910E8CA3F7905BC08911F0CB00476E0029EC7C24F425CF5F2FB080C0E91DE32DFA1348515C0FB3F4A1F1A44873F07107D86DD2C01C39C5114C62FCEEDEE2122F8260BE7CCDEB7C76BB0A1B9FF35BA442E8D920BC25A6D8CF73172BF4619BD20DE39A2F833754B40F679EF87DD010611E7CC75719A5E8231636F1A81635D025E117A72DC1B8E2D4EBB7641A601F243BD0F222DA35F4AD2951FA2A7507C110399CE1F6912F563B4F44937514B52B3A80545ABA89CACAFA80CAC9BA49CD22C684ED02A6741359887978FD0F02E5E0EBBFF3EDE669BB7692DA8A971062B24FE01139CC032E6DD214A71425623D065DDD885B3900F1F63FAE27B53CEE927146443B35A6B36E48BC0F0B32187DDFFD9908B09C58FBEC7BC920E079F9218E03BD1EBCF54ED734E926CDBD341E8E6B6996F670D304D97B3348D5C3F9F059A90170F5888F2830F67B5472F8ADEC81110E81818BACFB63C2881BED9B251DD92731C608AAD33B708094E51EA224F552374C8EB2158B9A36A045B454244E1FEABF0044BC7096B84D821288599EA13AA4E0B9FB87E8C82562D492D3B6E61ACEF150FB9E61CC7983086AD9AE8C25C1FF86002547CA44169D3D0D8A9595CB3211ABC56D398B7B9B0AB7157E2115BB1C916DFD96097DC7F7B11C36CD6D8168CB359255D043006F17661A0FCACD2D500E483CBBE19A8746232182877A9B662A0A2C67660A0A24A5E9D811647D4AEE32F9D57F7CD3CC583F2F6B7F54675EDC036057DEC996916BE27B4A1D00227AA799ECF59257EA29AC319C8C9CF67297775651361E0334CC590CDCADFD5FAA14E33886C444D802B436B01E5D77F0A9032A17A0857C6F21AA5E35E440FD832EED608CBD77E09B666032A76FD1AB44668BE2C958DB3D3E9A3EA59650D8A91773A2CD4703406212F5E62C73B28C514975515D3C517EEE30DD73AC607A341412D9EAB4149656706D752699AED5AD239647D5CB28DB424B94F062D959D195C4BDC46DB95A4710A7AB8051BA948DCC2079A6C65A4A3DA6DAABAB1536446F182B16348A11A5FA338F6C9B29652C54BAC59914F35FD76D63FD9282C301C37D5E41C55D2569C6894A025966A8135487AE927293D4714CD118BF34CBD5021D3EEAD86E5BF6459DF3ED5412CF781929AFD5D86CF844B7B619F551D11DEFE127A17326F260FA16BC65EDFDC62E96D284089266A3F8D822C2466E7CADCBAB8BBABB72F4A5484B123C9AF384F8AA6141757547BA7415127C4000354F92DEB0F9219C2A4EAD2EBAC2BDBE4899A51CAC0541DC514ACDAD9A0991C98CE0325FB85FDC7A915E165E6134F46A903F0A29E18B57C0605AC56D71D554C39A9638A35DD11A5BC923AA454D543CA7AF6882064BD622D3C8346F514DD39A8F9227574B5B63BB22673A40EADA95E035B23B35CD71D55935C5207D65477C75E659AC80BE81EEF58C6D3CA5A5B567198DD6CCF3260BCCC6A38CC9657BBB3AF03D58A7B62F15B79058C97EFA525194F746B595211BFD8CC920C18E61547B8E916179CC6EB7933A6707D2D2CEA4DD7F766BC7EF6FAA256A11CE664928A7B75A8930E6F637E906A7F24A39CAC0A12DB2AD5081BFA734A71386204A3D92FC134F0315BBE4B826B44FC054E6991B2611F1F1E1D4B6F6DF6E7DD8B93A65EA039889A1EBF8863B685EC2BF28812F701256A2EC4066F4356A04A98F98A78F86962FF96B73ACD2316ECAFBCF8C0BA4A3F13FF970C2AEE930C5BBFABB99DC3E4CA371FACF6F4654377AD5EFDFCA5687A60DD2630634EAD434997EB8CB0F8DEA1973445D30DA459FB15C4EB9D50C253032DAA3421D67F5930F7E920AF0A4A29BF09D1D37FFA8AA67D39B011A2E675C0507883A8D094FDBF0E9631F3DF834F9A67FEF7EBACFE25C03AA2195F01F8A43F98FC06A0FB3254B6DCE156A3390F6D6349CAF5DC9A43BD5142E5AEF72625D57AA389AEA653F780DB20657A0DCB7865D9C683ED8E9A64E2C1B07769DA2F9E41BC2F49C3AB748EDDE60A6F333DB8E12AE81F9515BC07796C9ABC9CDDE7FE6EDBD64C31DC3D4FA0EC97E1BB67C6C6B3B5769FC7BB6D63338579F7DCD87A65EBEE99ADED6AFFDCB1A575DE42779E7BABA61119EE6274B1E0B6DCDA22700E27FC790446507894C593487D325753226A0BC3158999A9398B4C66AC4C1C85AF42D1CCB65F5FF986DFD8594ED3CCD6907BD9C49BAFFF8DBC394D336F4346E32EB282B53985BA4CED9675AC29F1E93565010B3D69493A6FF3591B2FD65F53D2EF204A11668FE18EF8F5E4F80EA29221A74E8F9C5EF5BA17F6CEDA2F27C2FE9DFACB1504FB1D45825D61D7AC68AEC8222A376F49A292448AD05C638A3CD852CF12EA2F904BA19AC598F337DD79DC8EDD74CCB177456E331A6714BA8CC3792004BC9813D0C43F4F5C16651EDFC6F9CF930CD10510D367B1F95BF27DE6075E25F7A52626648060DE058FE8B2B1A42CB2BB7CAE906E22D21188ABAF728AEE7118070096DE92197AC4EBC806E6F7112F91FBBC8A009A40DA074254FBF8DC47CB048529C758B5874FB0612F7C7AFF3702739ED840540000, N'6.1.3-40302')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'CHEM001', N'93.879', N'0', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'CHEM002', N'70.455', N'0', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'CHEM003', N'76.864', N'0', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'CHEM004', N'81.944', N'84.239', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'CHEM005', N'92.806', N'0', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'CHEM006', N'91.582', N'0', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'CIV001', N'92.455', N'0', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'CIV002', N'83.5', N'91.462', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'CIV003', N'89.762', N'71.722', N'80.278', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'CIV004', N'74.837', N'83.319', N'64.591', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'CIV006', N'89.5', N'94.048', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'CIV007', N'89.643', N'79.42', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'CIV008', N'79.227', N'80.17', N'78.571', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'CIV009', N'87.024', N'71.094', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'CIV11', N'77.449', N'74.722', N'80.51', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'CIV14', N'87.034', N'81.389', N'62.136', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'CIV15', N'79.198', N'67', N'73.698', N'76.652', N'73.843', N'83.724', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'CSE002', N'85.328', N'0', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'CSE003', N'92.213', N'0', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'CSE005', N'85.122', N'87.542', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'CSE007', N'68.456', N'83.171', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'CSE008', N'88.284', N'0', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'CSE009', N'78.807', N'0', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'CSE010', N'75.543', N'0', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'CSE011', N'84.634', N'79.549', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'CSE012', N'78.589', N'0', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'CSE013', N'80.968', N'0', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'CSE014', N'66.721', N'0', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'CSE015', N'78.065', N'0', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'CSE016', N'88.266', N'91.964', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'CSE017', N'85.919', N'92.092', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'CSE018', N'88.415', N'77.188', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'CSE019', N'89.509', N'79.898', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'CSE020', N'79.926', N'83.777', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'CSE021', N'76.695', N'86.89', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'CSE022', N'82.076', N'0', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'CSE023', N'88.911', N'88.476', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'CSE024', N'88.852', N'89.268', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'CSE025', N'74.234', N'0', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'CSE026', N'89.398', N'0', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'CSE027', N'76.604', N'0', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'CSE028', N'90', N'82.378', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'EC001', N'89.569', N'91.815', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'EC002', N'79.743', N'86.979', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'EC003', N'82.845', N'0', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'EC004', N'85.324', N'86.633', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'EC005', N'82.373', N'90.227', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'EC006', N'87.112', N'89.612', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'EC007', N'70.366', N'71.528', N'76.094', N'81.591', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'EC008', N'79.948', N'0', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'EC009', N'65.568', N'67.656', N'66.389', N'82.407', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'EC010', N'86.848', N'66.02', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'EC011', N'87.463', N'0', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'EC012', N'86.029', N'94.722', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'EC013', N'72.198', N'64.261', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'EC015', N'87.096', N'0', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'EC017', N'87.54', N'87.87', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'EC018', N'87.989', N'81.507', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'EC019', N'90.765', N'95.636', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'EC020', N'87.5', N'0', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'EC021', N'88.103', N'83.136', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'EC022', N'90.606', N'86.6', N'82.688', N'86.528', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'EC023', N'71.89', N'0', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'EC024', N'88.636', N'90.435', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'EC026', N'87.866', N'90.152', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'EC027', N'92.273', N'0', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'EC028', N'81.837', N'88.669', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'EC029', N'80.612', N'88.78', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'EC030', N'85.303', N'0', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'EC031', N'83.906', N'0', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'EC032', N'91.488', N'82.744', N'92.222', N'85.35', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'EC033', N'84.516', N'89.074', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'EC034', N'96.97', N'93.073', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'EC036', N'75.255', N'0', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'ECE37', N'85.887', N'0', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'ECE38', N'96.475', N'0', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'ECE39', N'91.141', N'0', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'EEE001', N'89.918', N'0', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'EEE002', N'92.449', N'0', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'EEE003', N'67.459', N'0', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'EEE004', N'96.667', N'0', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'EEE005', N'78.542', N'77.3', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'EEE006', N'71.65', N'88.208', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'EEE007', N'92.705', N'0', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'EEE008', N'94.167', N'82.783', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'EEE009', N'74.205', N'0', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'EEE010', N'96.979', N'0', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'EEE011', N'96.583', N'0', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'EEE012', N'81.958', N'73.45', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'EEE013', N'81.434', N'85.694', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'EEE014', N'69.098', N'69.42', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'EEE15', N'81.556', N'78.4', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'EI001', N'90.5', N'86.985', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'EI002', N'88', N'90.5', N'79.12', N'85', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'EI003', N'86.019', N'77.337', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'EI004', N'92.287', N'94', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'EI005', N'80', N'84.439', N'78.818', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'EI006', N'68.75', N'92.963', N'65', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'EI007', N'93.5', N'88.79', N'79.681', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'EI008', N'89.167', N'72.806', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'EI011', N'85.417', N'84.412', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'EI012', N'85.532', N'0', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'EI013', N'83.871', N'85.37', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'ISE001', N'87.371', N'0', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'ISE002', N'83.182', N'0', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'ISE003', N'79.483', N'69.703', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'ISE004', N'83.602', N'0', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'ISE005', N'88.517', N'0', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'ISE006', N'72.727', N'86.449', N'83.459', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'ISE008', N'88.949', N'0', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'ISE009', N'82.415', N'92.692', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'ISE011', N'91.779', N'79.42', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'ISE012', N'88.938', N'0', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'ISE013', N'68.442', N'91', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'ISE014', N'80.086', N'0', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'ISE017', N'86.167', N'0', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'ISE018', N'78.017', N'76.021', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'ISE019', N'62.933', N'0', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'ISE020', N'77.585', N'64.075', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'ISE021', N'75.819', N'85.433', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'ISE022', N'74.958', N'82.065', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'ISE23', N'84.746', N'88.491', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'ISE24', N'78.253', N'0', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'MAT001', N'97.386', N'98.292', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'MAT002', N'87.232', N'82.296', N'89.152', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'MAT003', N'90.072', N'90.794', N'87.755', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'MAT005', N'96.97', N'95.765', N'91.25', N'92.134', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'MAT006', N'87.13', N'71.378', N'81.463', N'92.421', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'MAT007', N'93.333', N'86.441', N'89.191', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'MAT009', N'91.359', N'86.29', N'87.824', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'MAT011', N'83.167', N'94.074', N'96.293', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'MBA002', N'98.776', N'95.585', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'MBA003', N'73.148', N'82.656', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'MBA004', N'96.139', N'0', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'MBA005', N'84.722', N'0', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'MBA006', N'86.634', N'85', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'MBA007', N'83.673', N'92.115', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'MBA008', N'90.167', N'90.663', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'MBA009', N'88.639', N'0', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'MBA011', N'96.154', N'94.643', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'MBA012', N'88.367', N'84.306', N'95.333', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'MBA014', N'91.346', N'90.104', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'MBA015', N'90', N'88.333', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'MBA016', N'90.556', N'88.981', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'MBA017', N'94.49', N'96.708', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'MBA18', N'91.044', N'91.979', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'MBA19', N'90.156', N'93.949', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'MBA21', N'91.944', N'93.409', N'94.306', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'MBA22', N'72.296', N'78.802', N'76.296', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'MBA23', N'79.059', N'0', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'MBA24', N'87.681', N'0', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'MCA001', N'97.2', N'92.982', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'MCA002', N'82.558', N'90.909', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'MCA003', N'88.322', N'89.434', N'78.75', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'MCA004', N'85.044', N'88.676', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'MCA005', N'79.7', N'0', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'MCA006', N'90.147', N'0', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'MCA007', N'79.792', N'81.196', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'MCA008', N'78.25', N'0', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'MCA009', N'96.373', N'0', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'MCA010', N'94.47', N'0', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'MCA011', N'76.326', N'0', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'MCA012', N'93.289', N'0', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'MCA013', N'88.22', N'0', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'MCA014', N'94.1', N'0', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'MCA015', N'80.95', N'0', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'MCA016', N'90.539', N'0', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'MCA017', N'88.947', N'0', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'MCA018', N'89.508', N'0', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'MCA019', N'98.578', N'0', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'ME001', N'47.222', N'0', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'ME003', N'76.638', N'56.556', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'ME004', N'85.202', N'81.276', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'ME005', N'94.637', N'0', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'ME007', N'82.768', N'83.305', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'ME008', N'74.076', N'91.582', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'ME009', N'93.702', N'88.971', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'ME010', N'73.527', N'88.349', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'ME011', N'87.273', N'82.5', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'ME012', N'75.625', N'83.75', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'ME013', N'86.694', N'82.698', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'ME015', N'76.089', N'80.365', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'ME016', N'80.278', N'91.635', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'ME017', N'88.462', N'90.357', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'ME018', N'80', N'80.343', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'ME019', N'82.806', N'87.419', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'ME020', N'85.398', N'81.852', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'ME021', N'82.768', N'84.018', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'ME022', N'91.582', N'88.889', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'ME023', N'74.476', N'76.984', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'ME024', N'87.455', N'94.388', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'ME025', N'91.633', N'81.087', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'ME026', N'88.136', N'79.461', N'88.316', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'ME027', N'95.896', N'89.955', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'ME028', N'81.682', N'76.569', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'ME29', N'74.949', N'59.611', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'ME30', N'73.922', N'84.364', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'ME31', N'83.48', N'0', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'ME32', N'93.469', N'0', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'PHY001', N'87.778', N'0', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'PHY002', N'94.009', N'0', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'PHY003', N'85.787', N'0', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'PHY005', N'81.302', N'0', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'PHY006', N'79.866', N'0', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[ABCD] ([tid], [S1], [S2], [S3], [S4], [S5], [S6], [S7]) VALUES (N'PHY007', N'84.592', N'0', N'0', N'0', N'0', N'0', N'0')
GO
INSERT [dbo].[Admin] ([Id], [Password], [Dept], [Roles]) VALUES (N'admincse', N'admin', N'CSE       ', N'Admin')
GO
INSERT [dbo].[Admin] ([Id], [Password], [Dept], [Roles]) VALUES (N'CIV', N'civ@rnsit', N'CIV       ', N'IAdmin')
GO
INSERT [dbo].[Admin] ([Id], [Password], [Dept], [Roles]) VALUES (N'CSE', N'cse@rnsit', N'CSE       ', N'IAdmin')
GO
INSERT [dbo].[Admin] ([Id], [Password], [Dept], [Roles]) VALUES (N'ECE', N'ece@rnsit', N'ECE       ', N'IAdmin')
GO
INSERT [dbo].[Admin] ([Id], [Password], [Dept], [Roles]) VALUES (N'EEE', N'eee@rnsit', N'EEE       ', N'IAdmin')
GO
INSERT [dbo].[Admin] ([Id], [Password], [Dept], [Roles]) VALUES (N'GTRaju', N'admin', N'CSE       ', N'Dean')
GO
INSERT [dbo].[Admin] ([Id], [Password], [Dept], [Roles]) VALUES (N'ISE', N'ise@rnsit', N'ISE       ', N'IAdmin')
GO
INSERT [dbo].[Admin] ([Id], [Password], [Dept], [Roles]) VALUES (N'MBA', N'mba@rnsit', N'MBA       ', N'IAdmin')
GO
INSERT [dbo].[Admin] ([Id], [Password], [Dept], [Roles]) VALUES (N'MCA', N'mca@rnsit', N'MCA       ', N'IAdmin')
GO
INSERT [dbo].[Admin] ([Id], [Password], [Dept], [Roles]) VALUES (N'ME', N'me@rnsit', N'ME        ', N'IAdmin')
GO
INSERT [dbo].[Admin] ([Id], [Password], [Dept], [Roles]) VALUES (N'MKVenkatesha', N'admin', N'EEE       ', N'Principal')
GO
INSERT [dbo].[Admin] ([Id], [Password], [Dept], [Roles]) VALUES (N'VipulaSingh', N'admin', N'ECE       ', N'HOD')
GO
INSERT [dbo].[AspNetRoles] ([Id], [Name]) VALUES (N'9256c249-76ef-466d-8ff7-ec48848b4934', N'Admin')
GO
INSERT [dbo].[AspNetRoles] ([Id], [Name]) VALUES (N'9ebee954-3490-4c71-a60a-d28f626cba9b', N'Clerk')
GO
INSERT [dbo].[AspNetRoles] ([Id], [Name]) VALUES (N'd1808ae0-15a1-47a1-8428-4385bb7dcfae', N'Hod')
GO
INSERT [dbo].[AspNetUserRoles] ([UserId], [RoleId]) VALUES (N'bc098f3c-351f-4fbe-b361-2fcaadf8d527', N'9256c249-76ef-466d-8ff7-ec48848b4934')
GO
INSERT [dbo].[AspNetUserRoles] ([UserId], [RoleId]) VALUES (N'0e6fa040-755b-4968-ba50-eae863543a45', N'9ebee954-3490-4c71-a60a-d28f626cba9b')
GO
INSERT [dbo].[AspNetUserRoles] ([UserId], [RoleId]) VALUES (N'1a47c5ad-0268-403e-ab38-ccb60e2356bb', N'9ebee954-3490-4c71-a60a-d28f626cba9b')
GO
INSERT [dbo].[AspNetUserRoles] ([UserId], [RoleId]) VALUES (N'2100f87e-8e30-4cf1-b982-c03fe3f131cf', N'9ebee954-3490-4c71-a60a-d28f626cba9b')
GO
INSERT [dbo].[AspNetUserRoles] ([UserId], [RoleId]) VALUES (N'2f38d295-3acf-4ea1-aff0-bb342f8dbdda', N'9ebee954-3490-4c71-a60a-d28f626cba9b')
GO
INSERT [dbo].[AspNetUserRoles] ([UserId], [RoleId]) VALUES (N'4ffa0a5d-3934-4d8e-831b-2e96fb9c197e', N'9ebee954-3490-4c71-a60a-d28f626cba9b')
GO
INSERT [dbo].[AspNetUserRoles] ([UserId], [RoleId]) VALUES (N'65473bc6-03a0-4a43-9724-cb817bca3669', N'9ebee954-3490-4c71-a60a-d28f626cba9b')
GO
INSERT [dbo].[AspNetUserRoles] ([UserId], [RoleId]) VALUES (N'7142ab52-99dc-4165-9e5c-a81f1da6b779', N'9ebee954-3490-4c71-a60a-d28f626cba9b')
GO
INSERT [dbo].[AspNetUserRoles] ([UserId], [RoleId]) VALUES (N'76a0e3b4-afd8-4dc9-9b43-541460161250', N'9ebee954-3490-4c71-a60a-d28f626cba9b')
GO
INSERT [dbo].[AspNetUserRoles] ([UserId], [RoleId]) VALUES (N'7813bca7-96f8-4069-8789-19d4af2c31d9', N'9ebee954-3490-4c71-a60a-d28f626cba9b')
GO
INSERT [dbo].[AspNetUserRoles] ([UserId], [RoleId]) VALUES (N'a0b4cb8f-22da-4746-b39d-6ac52263d145', N'9ebee954-3490-4c71-a60a-d28f626cba9b')
GO
INSERT [dbo].[AspNetUserRoles] ([UserId], [RoleId]) VALUES (N'c0d21c6c-4ca4-4f09-959f-be0ace70c35d', N'9ebee954-3490-4c71-a60a-d28f626cba9b')
GO
INSERT [dbo].[AspNetUserRoles] ([UserId], [RoleId]) VALUES (N'f9372eda-5df3-43a1-9a88-a39324a045f1', N'9ebee954-3490-4c71-a60a-d28f626cba9b')
GO
INSERT [dbo].[AspNetUserRoles] ([UserId], [RoleId]) VALUES (N'fc69cfbc-6a4e-41d7-9aaa-4cbc4a5867d7', N'9ebee954-3490-4c71-a60a-d28f626cba9b')
GO
INSERT [dbo].[AspNetUserRoles] ([UserId], [RoleId]) VALUES (N'ff6beed5-3664-4be0-bfbe-e02cb5f8be51', N'9ebee954-3490-4c71-a60a-d28f626cba9b')
GO
INSERT [dbo].[AspNetUserRoles] ([UserId], [RoleId]) VALUES (N'05d77ff0-2c92-4e0b-bc08-943935e421b0', N'd1808ae0-15a1-47a1-8428-4385bb7dcfae')
GO
INSERT [dbo].[AspNetUserRoles] ([UserId], [RoleId]) VALUES (N'143fac7b-57e9-4209-92ad-9f2157bd74d5', N'd1808ae0-15a1-47a1-8428-4385bb7dcfae')
GO
INSERT [dbo].[AspNetUserRoles] ([UserId], [RoleId]) VALUES (N'19e6ef43-3554-493f-b729-b9e96a5577c2', N'd1808ae0-15a1-47a1-8428-4385bb7dcfae')
GO
INSERT [dbo].[AspNetUserRoles] ([UserId], [RoleId]) VALUES (N'4a90228e-8be9-4dc3-b52e-432eff6b9fbc', N'd1808ae0-15a1-47a1-8428-4385bb7dcfae')
GO
INSERT [dbo].[AspNetUserRoles] ([UserId], [RoleId]) VALUES (N'4bdecb69-35fe-4690-b8fc-4858461d20fa', N'd1808ae0-15a1-47a1-8428-4385bb7dcfae')
GO
INSERT [dbo].[AspNetUserRoles] ([UserId], [RoleId]) VALUES (N'7c7df2d2-25d1-4c04-b1cc-6ff615ac08f0', N'd1808ae0-15a1-47a1-8428-4385bb7dcfae')
GO
INSERT [dbo].[AspNetUserRoles] ([UserId], [RoleId]) VALUES (N'aea890a3-10cf-41ad-88c2-f1a815f74751', N'd1808ae0-15a1-47a1-8428-4385bb7dcfae')
GO
INSERT [dbo].[AspNetUserRoles] ([UserId], [RoleId]) VALUES (N'b41815b3-96fe-4d0a-865e-34ab0cc8ebd9', N'd1808ae0-15a1-47a1-8428-4385bb7dcfae')
GO
INSERT [dbo].[AspNetUserRoles] ([UserId], [RoleId]) VALUES (N'd05093eb-25fe-47c6-b301-dc8d4db3d09a', N'd1808ae0-15a1-47a1-8428-4385bb7dcfae')
GO
INSERT [dbo].[AspNetUserRoles] ([UserId], [RoleId]) VALUES (N'd715e5b3-9f73-4e00-bb44-540f4c232c23', N'd1808ae0-15a1-47a1-8428-4385bb7dcfae')
GO
INSERT [dbo].[AspNetUserRoles] ([UserId], [RoleId]) VALUES (N'd72899e4-e6a4-4551-a607-4453560f1196', N'd1808ae0-15a1-47a1-8428-4385bb7dcfae')
GO
INSERT [dbo].[AspNetUserRoles] ([UserId], [RoleId]) VALUES (N'e92f87e4-af77-4612-ba5f-cb2262de2aee', N'd1808ae0-15a1-47a1-8428-4385bb7dcfae')
GO
INSERT [dbo].[AspNetUserRoles] ([UserId], [RoleId]) VALUES (N'f0c88b2f-3c41-4ea1-915b-92c2710d06da', N'd1808ae0-15a1-47a1-8428-4385bb7dcfae')
GO
INSERT [dbo].[AspNetUserRoles] ([UserId], [RoleId]) VALUES (N'f666c8dc-a273-4a94-8471-bc4933f89140', N'd1808ae0-15a1-47a1-8428-4385bb7dcfae')
GO
INSERT [dbo].[AspNetUsers] ([Id], [Email], [EmailConfirmed], [PasswordHash], [SecurityStamp], [PhoneNumber], [PhoneNumberConfirmed], [TwoFactorEnabled], [LockoutEndDateUtc], [LockoutEnabled], [AccessFailedCount], [UserName]) VALUES (N'05d77ff0-2c92-4e0b-bc08-943935e421b0', N'ece@hod.rnsit.ac.in', 0, N'ACGqwo+sIQTQtuitKI3hheqHdbPCxBZS5u+kQe5SlMYpAi/oOcurAF5abKkl4lXnnw==', N'e3109093-6993-4817-8c55-44f5d502f646', NULL, 0, 0, NULL, 0, 0, N'ece@hod.rnsit.ac.in')
GO
INSERT [dbo].[AspNetUsers] ([Id], [Email], [EmailConfirmed], [PasswordHash], [SecurityStamp], [PhoneNumber], [PhoneNumberConfirmed], [TwoFactorEnabled], [LockoutEndDateUtc], [LockoutEnabled], [AccessFailedCount], [UserName]) VALUES (N'0e6fa040-755b-4968-ba50-eae863543a45', N'ei@rnsit.ac.in', 0, N'AH8Pc33E1tLNaI4POpw6vTOrAxCkTtEEI9eAzPPeNnS5GgP6dh1tlQkmuDVKR3Hi4A==', N'8d4d5462-2256-4add-882d-437360d27437', NULL, 0, 0, NULL, 0, 0, N'ei@rnsit.ac.in')
GO
INSERT [dbo].[AspNetUsers] ([Id], [Email], [EmailConfirmed], [PasswordHash], [SecurityStamp], [PhoneNumber], [PhoneNumberConfirmed], [TwoFactorEnabled], [LockoutEndDateUtc], [LockoutEnabled], [AccessFailedCount], [UserName]) VALUES (N'143fac7b-57e9-4209-92ad-9f2157bd74d5', N'eee@hod.rnsit.ac.in', 0, N'APDYqbingfsv/5QH7rDDCNuJCaI97yWC1Zzz/iqE3wupVib6AsSJmJQ3w27CKbdWww==', N'52eb01df-3162-4d34-8e35-5d87b8a234fd', NULL, 0, 0, NULL, 0, 0, N'eee@hod.rnsit.ac.in')
GO
INSERT [dbo].[AspNetUsers] ([Id], [Email], [EmailConfirmed], [PasswordHash], [SecurityStamp], [PhoneNumber], [PhoneNumberConfirmed], [TwoFactorEnabled], [LockoutEndDateUtc], [LockoutEnabled], [AccessFailedCount], [UserName]) VALUES (N'19e6ef43-3554-493f-b729-b9e96a5577c2', N'mca@hod.rnsit.ac.in', 0, N'AFgInA5i2AEGzrMJaoHQ20oPyTReosRtNtRd+syRfJmVxxeWBixEPwebYpFJfsvbRA==', N'22c0445a-1307-4927-a396-633b95a67f2b', NULL, 0, 0, NULL, 0, 0, N'mca@hod.rnsit.ac.in')
GO
INSERT [dbo].[AspNetUsers] ([Id], [Email], [EmailConfirmed], [PasswordHash], [SecurityStamp], [PhoneNumber], [PhoneNumberConfirmed], [TwoFactorEnabled], [LockoutEndDateUtc], [LockoutEnabled], [AccessFailedCount], [UserName]) VALUES (N'1a47c5ad-0268-403e-ab38-ccb60e2356bb', N'chem@rnsit.ac.in', 0, N'AAvvM8d/W0sKBAci74Mcm5AABd6OPAq/qd20sFeO9VbVMYtfp0nTt58X7flC+WQF4g==', N'315f6a99-222f-4021-a96b-f85a10b2f5a2', NULL, 0, 0, NULL, 0, 0, N'chem@rnsit.ac.in')
GO
INSERT [dbo].[AspNetUsers] ([Id], [Email], [EmailConfirmed], [PasswordHash], [SecurityStamp], [PhoneNumber], [PhoneNumberConfirmed], [TwoFactorEnabled], [LockoutEndDateUtc], [LockoutEnabled], [AccessFailedCount], [UserName]) VALUES (N'2100f87e-8e30-4cf1-b982-c03fe3f131cf', N'me@rnsit.ac.in', 0, N'AOzLCCP+Gxef6rp3dEP2JioUkItdptqegrQiXJUUWjk6AlgpSOkVXX2Es4Qiv5Ms9A==', N'f6fddf44-a6a2-490d-9515-d9d5c431b85f', NULL, 0, 0, NULL, 0, 0, N'me@rnsit.ac.in')
GO
INSERT [dbo].[AspNetUsers] ([Id], [Email], [EmailConfirmed], [PasswordHash], [SecurityStamp], [PhoneNumber], [PhoneNumberConfirmed], [TwoFactorEnabled], [LockoutEndDateUtc], [LockoutEnabled], [AccessFailedCount], [UserName]) VALUES (N'2f38d295-3acf-4ea1-aff0-bb342f8dbdda', N'cse@rnsit.ac.in', 0, N'AAXWebZxtXVwWCAl7vxN26iNhC8WNM33uTyLGOoSN4qcnnnnGQmdcGpLf8n/G7kv6Q==', N'9019ab3c-bbac-4b74-95a4-4713a246cf58', NULL, 0, 0, NULL, 0, 0, N'cse@rnsit.ac.in')
GO
INSERT [dbo].[AspNetUsers] ([Id], [Email], [EmailConfirmed], [PasswordHash], [SecurityStamp], [PhoneNumber], [PhoneNumberConfirmed], [TwoFactorEnabled], [LockoutEndDateUtc], [LockoutEnabled], [AccessFailedCount], [UserName]) VALUES (N'4a90228e-8be9-4dc3-b52e-432eff6b9fbc', N'me@hod.rnsit.ac.in', 0, N'ALcMEsSEziL6LWhD8EXQwJvrLaCUXj/XKULXlYEh+UogtDG+u7MR7KysV/LG/Az3Fg==', N'a7afe5b4-9dc4-4069-967c-549007f04e8d', NULL, 0, 0, NULL, 0, 0, N'me@hod.rnsit.ac.in')
GO
INSERT [dbo].[AspNetUsers] ([Id], [Email], [EmailConfirmed], [PasswordHash], [SecurityStamp], [PhoneNumber], [PhoneNumberConfirmed], [TwoFactorEnabled], [LockoutEndDateUtc], [LockoutEnabled], [AccessFailedCount], [UserName]) VALUES (N'4bdecb69-35fe-4690-b8fc-4858461d20fa', N'es@hod.rnsit.ac.in', 0, N'APnAef0aYS5VaQJl8hlHbCeQbnhROmOFpsMnjiGHMyQR8OLcaRPtdVjzjULGNFdgfw==', N'42893f75-77ca-4240-adf8-b5d4df56a16b', NULL, 0, 0, NULL, 0, 0, N'es@hod.rnsit.ac.in')
GO
INSERT [dbo].[AspNetUsers] ([Id], [Email], [EmailConfirmed], [PasswordHash], [SecurityStamp], [PhoneNumber], [PhoneNumberConfirmed], [TwoFactorEnabled], [LockoutEndDateUtc], [LockoutEnabled], [AccessFailedCount], [UserName]) VALUES (N'4ffa0a5d-3934-4d8e-831b-2e96fb9c197e', N'ece@rnsit.ac.in', 0, N'AFK2ZUgIJH7xHjI/+JfOkSq/sEsJCdGwPXCfQPj6sNJiY0SyZCWg4z4OdkuYGcB4GQ==', N'90fe6b6a-42db-414f-9a77-5c9ad2e2b060', NULL, 0, 0, NULL, 0, 0, N'ece@rnsit.ac.in')
GO
INSERT [dbo].[AspNetUsers] ([Id], [Email], [EmailConfirmed], [PasswordHash], [SecurityStamp], [PhoneNumber], [PhoneNumberConfirmed], [TwoFactorEnabled], [LockoutEndDateUtc], [LockoutEnabled], [AccessFailedCount], [UserName]) VALUES (N'65473bc6-03a0-4a43-9724-cb817bca3669', N'ise@rnsit.ac.in', 0, N'AM/BNu2OTfWD8pC50Y5oTvXuJSkn7o18sjnR8cCPTZib7FnU7BqLxMJocNHSvxuyQQ==', N'2ec8fa8e-2dd5-4cf7-8f3e-c4af7716cb72', NULL, 0, 0, NULL, 0, 0, N'ise@rnsit.ac.in')
GO
INSERT [dbo].[AspNetUsers] ([Id], [Email], [EmailConfirmed], [PasswordHash], [SecurityStamp], [PhoneNumber], [PhoneNumberConfirmed], [TwoFactorEnabled], [LockoutEndDateUtc], [LockoutEnabled], [AccessFailedCount], [UserName]) VALUES (N'7142ab52-99dc-4165-9e5c-a81f1da6b779', N'mca@rnsit.ac.in', 0, N'AIZs5motLFm8o3K4kiR4oIP3JZLImDk04GZFQufl1hgc5rpqPGL+qHEmChEy1gC+Qg==', N'6debb4a6-6555-439a-887e-9fcac2ccd747', NULL, 0, 0, NULL, 0, 0, N'mca@rnsit.ac.in')
GO
INSERT [dbo].[AspNetUsers] ([Id], [Email], [EmailConfirmed], [PasswordHash], [SecurityStamp], [PhoneNumber], [PhoneNumberConfirmed], [TwoFactorEnabled], [LockoutEndDateUtc], [LockoutEnabled], [AccessFailedCount], [UserName]) VALUES (N'76a0e3b4-afd8-4dc9-9b43-541460161250', N'it@rnsit.ac.in', 0, N'AJEjnZzdsTO7RJKadYQNKxkz5TLS5lfTcchN5Ka7jSE9a/qyF+TNOiJW8lY/HZV1Wg==', N'6f0fa9b1-dc67-4cea-8540-024f0ae4cc12', NULL, 0, 0, NULL, 0, 0, N'it@rnsit.ac.in')
GO
INSERT [dbo].[AspNetUsers] ([Id], [Email], [EmailConfirmed], [PasswordHash], [SecurityStamp], [PhoneNumber], [PhoneNumberConfirmed], [TwoFactorEnabled], [LockoutEndDateUtc], [LockoutEnabled], [AccessFailedCount], [UserName]) VALUES (N'7813bca7-96f8-4069-8789-19d4af2c31d9', N'es@rnsit.ac.in', 0, N'AIyr9D4A+zGEKANtshjci8ztzW/9YE89UL64hR5nRPrIu4N+NuZ8k0pj/U4I43uoJg==', N'cf996b31-617e-4ff6-bff9-08a0f2303a52', NULL, 0, 0, NULL, 0, 0, N'es@rnsit.ac.in')
GO
INSERT [dbo].[AspNetUsers] ([Id], [Email], [EmailConfirmed], [PasswordHash], [SecurityStamp], [PhoneNumber], [PhoneNumberConfirmed], [TwoFactorEnabled], [LockoutEndDateUtc], [LockoutEnabled], [AccessFailedCount], [UserName]) VALUES (N'7c7df2d2-25d1-4c04-b1cc-6ff615ac08f0', N'ise@hod.rnsit.ac.in', 0, N'AHcBwyjEqSb67yzlVv8Ok53YmLPUoba3sdq94cLl+NumWB9gsE5Xhgkx4E7dnijjxw==', N'6826ef21-995e-4efc-8503-018dc15cb344', NULL, 0, 0, NULL, 0, 0, N'ise@hod.rnsit.ac.in')
GO
INSERT [dbo].[AspNetUsers] ([Id], [Email], [EmailConfirmed], [PasswordHash], [SecurityStamp], [PhoneNumber], [PhoneNumberConfirmed], [TwoFactorEnabled], [LockoutEndDateUtc], [LockoutEnabled], [AccessFailedCount], [UserName]) VALUES (N'a0b4cb8f-22da-4746-b39d-6ac52263d145', N'mba@rnsit.ac.in', 0, N'AFlkW7Pnwc8H7/PwtvivVvaBPUqi32TD5gw/K2+9g5pdT7doe538ykI+l0+Je6iVhg==', N'e16ced5d-b597-44b6-86a5-d82807671e2a', NULL, 0, 0, NULL, 0, 0, N'mba@rnsit.ac.in')
GO
INSERT [dbo].[AspNetUsers] ([Id], [Email], [EmailConfirmed], [PasswordHash], [SecurityStamp], [PhoneNumber], [PhoneNumberConfirmed], [TwoFactorEnabled], [LockoutEndDateUtc], [LockoutEnabled], [AccessFailedCount], [UserName]) VALUES (N'aea890a3-10cf-41ad-88c2-f1a815f74751', N'civ@hod.rnsit.ac.in', 0, N'AOpSHREzeeYRdYmwyIq+J7eSseVmirB0ZbbpsbRKLMAXIfNeOLV7eq7TFzjDTVEdiQ==', N'97e688e7-dbc9-4a10-b0cf-ce43f840f47e', NULL, 0, 0, NULL, 0, 0, N'civ@hod.rnsit.ac.in')
GO
INSERT [dbo].[AspNetUsers] ([Id], [Email], [EmailConfirmed], [PasswordHash], [SecurityStamp], [PhoneNumber], [PhoneNumberConfirmed], [TwoFactorEnabled], [LockoutEndDateUtc], [LockoutEnabled], [AccessFailedCount], [UserName]) VALUES (N'b41815b3-96fe-4d0a-865e-34ab0cc8ebd9', N'mba@hod.rnsit.ac.in', 0, N'ADY5qW2msdNHVbUKzmrgCnnPRdLRng+Mdbp0CAPdqkH5kZfo/PdTvmYzeDGkhpOz8A==', N'0e4c072d-ec7d-4fff-acfe-59dcfd6a0128', NULL, 0, 0, NULL, 0, 0, N'mba@hod.rnsit.ac.in')
GO
INSERT [dbo].[AspNetUsers] ([Id], [Email], [EmailConfirmed], [PasswordHash], [SecurityStamp], [PhoneNumber], [PhoneNumberConfirmed], [TwoFactorEnabled], [LockoutEndDateUtc], [LockoutEnabled], [AccessFailedCount], [UserName]) VALUES (N'bc098f3c-351f-4fbe-b361-2fcaadf8d527', N'admin@rnsit.ac.in', 0, N'AC8G+cErFEcKH0Xhw3lz2NKjO5HdBFdTED8N3kwRtEwthvGAWLMUElNsBG67oAaoUw==', N'451d101d-62ab-46bf-9865-4ebde0a3d83c', NULL, 0, 0, NULL, 0, 0, N'admin@rnsit.ac.in')
GO
INSERT [dbo].[AspNetUsers] ([Id], [Email], [EmailConfirmed], [PasswordHash], [SecurityStamp], [PhoneNumber], [PhoneNumberConfirmed], [TwoFactorEnabled], [LockoutEndDateUtc], [LockoutEnabled], [AccessFailedCount], [UserName]) VALUES (N'c0d21c6c-4ca4-4f09-959f-be0ace70c35d', N'mat@rnsit.ac.in', 0, N'AEmeCqzkj61/XS2F0DwOiAzJbu37liHU5THVAQY7nO8JfuV2m2UmsyaCLc9blISWBA==', N'12622ee1-9ef0-4e82-9bc7-438b2e7ee517', NULL, 0, 0, NULL, 0, 0, N'mat@rnsit.ac.in')
GO
INSERT [dbo].[AspNetUsers] ([Id], [Email], [EmailConfirmed], [PasswordHash], [SecurityStamp], [PhoneNumber], [PhoneNumberConfirmed], [TwoFactorEnabled], [LockoutEndDateUtc], [LockoutEnabled], [AccessFailedCount], [UserName]) VALUES (N'd05093eb-25fe-47c6-b301-dc8d4db3d09a', N'mat@hod.rnsit.ac.in', 0, N'AIprqTtY4T9s8p9VwGsRj8uOL5HplsHqGJ0CNwa+pSKBe1wDqLZc7bgPXoknp/XQ/A==', N'5d028e36-1a7d-4320-9d21-98a65eddeb44', NULL, 0, 0, NULL, 0, 0, N'mat@hod.rnsit.ac.in')
GO
INSERT [dbo].[AspNetUsers] ([Id], [Email], [EmailConfirmed], [PasswordHash], [SecurityStamp], [PhoneNumber], [PhoneNumberConfirmed], [TwoFactorEnabled], [LockoutEndDateUtc], [LockoutEnabled], [AccessFailedCount], [UserName]) VALUES (N'd715e5b3-9f73-4e00-bb44-540f4c232c23', N'chem@hod.rnsit.ac.in', 0, N'AFlmD+QThASOEYL0m2QYX6Cfcep8MnQxHzanUdR5Pu436SHcywwUTF9pAs6MRhLtVg==', N'f2848f8c-7f73-4f0e-9f31-7015357e4594', NULL, 0, 0, NULL, 0, 0, N'chem@hod.rnsit.ac.in')
GO
INSERT [dbo].[AspNetUsers] ([Id], [Email], [EmailConfirmed], [PasswordHash], [SecurityStamp], [PhoneNumber], [PhoneNumberConfirmed], [TwoFactorEnabled], [LockoutEndDateUtc], [LockoutEnabled], [AccessFailedCount], [UserName]) VALUES (N'd72899e4-e6a4-4551-a607-4453560f1196', N'phy@hod.rnsit.ac.in', 0, N'AKacEFXJFP89KuvQ0Egj+Gn/U+dxZ3dAf8/xrQor2zIUv1pqyF2u0Zb4PMAPRwHQbA==', N'7a3e7bfe-99f3-48ea-8f1b-dc0c41673c0c', NULL, 0, 0, NULL, 0, 0, N'phy@hod.rnsit.ac.in')
GO
INSERT [dbo].[AspNetUsers] ([Id], [Email], [EmailConfirmed], [PasswordHash], [SecurityStamp], [PhoneNumber], [PhoneNumberConfirmed], [TwoFactorEnabled], [LockoutEndDateUtc], [LockoutEnabled], [AccessFailedCount], [UserName]) VALUES (N'e92f87e4-af77-4612-ba5f-cb2262de2aee', N'cse@hod.rnsit.ac.in', 0, N'APlI3I3536+j0doFBnRSh8krIbLEhEqPf8+DJrXL9MbtMtgb/NHPr4VirMPzQq6HIg==', N'783b62fd-edc1-4d56-aa78-306d78eec640', NULL, 0, 0, NULL, 0, 0, N'cse@hod.rnsit.ac.in')
GO
INSERT [dbo].[AspNetUsers] ([Id], [Email], [EmailConfirmed], [PasswordHash], [SecurityStamp], [PhoneNumber], [PhoneNumberConfirmed], [TwoFactorEnabled], [LockoutEndDateUtc], [LockoutEnabled], [AccessFailedCount], [UserName]) VALUES (N'f0c88b2f-3c41-4ea1-915b-92c2710d06da', N'ei@hod.rnsit.ac.in', 0, N'AOiweNGqxT1H2c34InZ8uMAt4xqBmtZ27IEq1SRf2jI1uNpkqjPGfHMeiCCMm1n+0A==', N'a9c4329d-3a1a-4f8e-936c-bffc74d696e8', NULL, 0, 0, NULL, 0, 0, N'ei@hod.rnsit.ac.in')
GO
INSERT [dbo].[AspNetUsers] ([Id], [Email], [EmailConfirmed], [PasswordHash], [SecurityStamp], [PhoneNumber], [PhoneNumberConfirmed], [TwoFactorEnabled], [LockoutEndDateUtc], [LockoutEnabled], [AccessFailedCount], [UserName]) VALUES (N'f666c8dc-a273-4a94-8471-bc4933f89140', N'it@hod.rnsit.ac.in', 0, N'AJr0C8MPDKJgfL8jq+33+6XhNKV1uXsoBeuxWZwd1S2Salbd4LVzKqrPC1/ejVEiwA==', N'4c2f2dfc-1b39-4464-968e-135603a2907d', NULL, 0, 0, NULL, 0, 0, N'it@hod.rnsit.ac.in')
GO
INSERT [dbo].[AspNetUsers] ([Id], [Email], [EmailConfirmed], [PasswordHash], [SecurityStamp], [PhoneNumber], [PhoneNumberConfirmed], [TwoFactorEnabled], [LockoutEndDateUtc], [LockoutEnabled], [AccessFailedCount], [UserName]) VALUES (N'f9372eda-5df3-43a1-9a88-a39324a045f1', N'eee@rnsit.ac.in', 0, N'AIFqvrJrkiP0t0wB3yroypCGcYlXPByofbnJEiRILQMWWQ2KrNIr5FUwpaaSlN+KZA==', N'4d867204-0432-4c3d-bcf6-11ad549e776f', NULL, 0, 0, NULL, 0, 0, N'eee@rnsit.ac.in')
GO
INSERT [dbo].[AspNetUsers] ([Id], [Email], [EmailConfirmed], [PasswordHash], [SecurityStamp], [PhoneNumber], [PhoneNumberConfirmed], [TwoFactorEnabled], [LockoutEndDateUtc], [LockoutEnabled], [AccessFailedCount], [UserName]) VALUES (N'fc69cfbc-6a4e-41d7-9aaa-4cbc4a5867d7', N'phy@rnsit.ac.in', 0, N'AMxU6CDQjYIcSm0eOkJFTG78BkwOJvyOjgbio2QJLvcYVMvTDq77ZbmEd045r4Jk6g==', N'ae0f30ae-24f4-464a-ac74-8f835469d70d', NULL, 0, 0, NULL, 0, 0, N'phy@rnsit.ac.in')
GO
INSERT [dbo].[AspNetUsers] ([Id], [Email], [EmailConfirmed], [PasswordHash], [SecurityStamp], [PhoneNumber], [PhoneNumberConfirmed], [TwoFactorEnabled], [LockoutEndDateUtc], [LockoutEnabled], [AccessFailedCount], [UserName]) VALUES (N'ff6beed5-3664-4be0-bfbe-e02cb5f8be51', N'civ@rnsit.ac.in', 0, N'ACfy/A8GSTtuOkQdrZ7Dsp4bkzgWSqd1iy0QBBtd0uh/gDlxBIK1F/43PQkILS/Tbw==', N'141e837f-367c-4203-a50b-8315e4440f70', NULL, 0, 0, NULL, 0, 0, N'civ@rnsit.ac.in')
GO
INSERT [dbo].[DEPT] ([DeptId], [DeptName], [Password], [HodPassword]) VALUES (N'CHEM      ', N'Chemitry', N'P@ssw0rd@chem', N'P@ssw0rd@chem')
GO
INSERT [dbo].[DEPT] ([DeptId], [DeptName], [Password], [HodPassword]) VALUES (N'CIV       ', N'Civil', N'P@ssw0rd@civ', N'P@ssw0rd@civ')
GO
INSERT [dbo].[DEPT] ([DeptId], [DeptName], [Password], [HodPassword]) VALUES (N'CSE       ', N'Computer Science & Engineering', N'P@ssw0rd@cse', N'P@ssw0rd@cse')
GO
INSERT [dbo].[DEPT] ([DeptId], [DeptName], [Password], [HodPassword]) VALUES (N'ECE       ', N'Electronics and Communication Engineering  ', N'P@ssw0rd@ece', N'P@ssw0rd@ece')
GO
INSERT [dbo].[DEPT] ([DeptId], [DeptName], [Password], [HodPassword]) VALUES (N'EEE       ', N'Electrical and Electronics Engineering    ', N'P@ssw0rd@eee', N'P@ssw0rd@eee')
GO
INSERT [dbo].[DEPT] ([DeptId], [DeptName], [Password], [HodPassword]) VALUES (N'EI        ', N'Electronics and Instrumentation Engineering', N'P@ssw0rd@ei', N'P@ssw0rd@ei')
GO
INSERT [dbo].[DEPT] ([DeptId], [DeptName], [Password], [HodPassword]) VALUES (N'ES        ', N'Electronic Stream', N'P@ssw0rd@es', N'P@ssw0rd@es')
GO
INSERT [dbo].[DEPT] ([DeptId], [DeptName], [Password], [HodPassword]) VALUES (N'ISE       ', N'Information Science and Engineering ', N'P@ssw0rd@ise', N'P@ssw0rd@ise')
GO
INSERT [dbo].[DEPT] ([DeptId], [DeptName], [Password], [HodPassword]) VALUES (N'IT        ', N'Instrumentation Engineering', N'P@ssw0rd@it', N'P@ssw0rd@it')
GO
INSERT [dbo].[DEPT] ([DeptId], [DeptName], [Password], [HodPassword]) VALUES (N'MAT       ', N'Mathematics  ', N'P@ssw0rd@mat', N'P@ssw0rd@mat')
GO
INSERT [dbo].[DEPT] ([DeptId], [DeptName], [Password], [HodPassword]) VALUES (N'MBA       ', N'Masters in Business Administration  ', N'P@ssw0rd@mba', N'P@ssw0rd@mba')
GO
INSERT [dbo].[DEPT] ([DeptId], [DeptName], [Password], [HodPassword]) VALUES (N'MCA       ', N'Masters in Computer Application', N'P@ssw0rd@mca', N'P@ssw0rd@mca')
GO
INSERT [dbo].[DEPT] ([DeptId], [DeptName], [Password], [HodPassword]) VALUES (N'ME        ', N'Mechanical Engineering ', N'P@ssw0rd@me', N'P@ssw0rd@me')
GO
INSERT [dbo].[DEPT] ([DeptId], [DeptName], [Password], [HodPassword]) VALUES (N'PHY       ', N'Physics', N'P@ssw0rd@phy', N'P@ssw0rd@phy')
GO
INSERT [dbo].[LowerTable] ([Question], [Ones], [Twos], [Threes], [Fours]) VALUES (N'1. Effective Communication and Clarity in Explanation', 0, 3, 11, 35)
GO
INSERT [dbo].[LowerTable] ([Question], [Ones], [Twos], [Threes], [Fours]) VALUES (N'2.Preparedness and Depth of Subject Knowledge (Relevant Practical Applications wherever applicable', 0, 2, 14, 33)
GO
INSERT [dbo].[LowerTable] ([Question], [Ones], [Twos], [Threes], [Fours]) VALUES (N'3.Time Management (Effective use of the class hour and timely coverage of syllabus', 0, 2, 7, 40)
GO
INSERT [dbo].[LowerTable] ([Question], [Ones], [Twos], [Threes], [Fours]) VALUES (N'4.Enforcement of Discipline in the class', 0, 1, 10, 38)
GO
INSERT [dbo].[LowerTable] ([Question], [Ones], [Twos], [Threes], [Fours]) VALUES (N'5.Invites Questions and Encourages Thinking (Class Motivation towards Enhanced Learning', 0, 2, 11, 36)
GO
INSERT [dbo].[LowerTable] ([Question], [Ones], [Twos], [Threes], [Fours]) VALUES (N'6.Provide discussions on Problems, Programs, Assignments, Quiz, case studies/situation analysis, Exam questions and Illustrations', 0, 1, 11, 37)
GO
INSERT [dbo].[LowerTable] ([Question], [Ones], [Twos], [Threes], [Fours]) VALUES (N'7.Availability, Accessibility and Approachability for clarifications outside the Class', 0, 1, 10, 38)
GO
INSERT [dbo].[LowerTable] ([Question], [Ones], [Twos], [Threes], [Fours]) VALUES (N'8.Study materials such as Lecture notes, handouts, PPTs, etc.', 0, 2, 7, 40)
GO
INSERT [dbo].[LowerTable] ([Question], [Ones], [Twos], [Threes], [Fours]) VALUES (N'9.Coverage of Syllabus', 0, 2, 7, 40)
GO
INSERT [dbo].[LowerTable] ([Question], [Ones], [Twos], [Threes], [Fours]) VALUES (N'10.Evaluation of Tests or Assignments with suggestions for Improvement', 0, 0, 8, 41)
GO
INSERT [dbo].[my1] ([USN], [subcode]) VALUES (N'1RN15MCA01', N'13MCA351')
GO
INSERT [dbo].[my1] ([USN], [subcode]) VALUES (N'1RN15MCA03', N'13MCA351')
GO
INSERT [dbo].[my1] ([USN], [subcode]) VALUES (N'1RN15MCA05', N'13MCA351')
GO
INSERT [dbo].[my1] ([USN], [subcode]) VALUES (N'1RN15MCA06', N'13MCA351')
GO
INSERT [dbo].[my1] ([USN], [subcode]) VALUES (N'1RN15MCA07', N'13MCA351')
GO
INSERT [dbo].[my1] ([USN], [subcode]) VALUES (N'1RN15MCA08', N'13MCA351')
GO
INSERT [dbo].[my1] ([USN], [subcode]) VALUES (N'1RN15MCA09', N'13MCA351')
GO
INSERT [dbo].[my1] ([USN], [subcode]) VALUES (N'1RN15MCA10', N'13MCA351')
GO
INSERT [dbo].[my1] ([USN], [subcode]) VALUES (N'1RN15MCA11', N'13MCA351')
GO
INSERT [dbo].[my1] ([USN], [subcode]) VALUES (N'1RN15MCA12', N'13MCA351')
GO
INSERT [dbo].[my1] ([USN], [subcode]) VALUES (N'1RN15MCA13', N'13MCA351')
GO
INSERT [dbo].[my1] ([USN], [subcode]) VALUES (N'1RN15MCA14', N'13MCA351')
GO
INSERT [dbo].[my1] ([USN], [subcode]) VALUES (N'1RN15MCA15', N'13MCA351')
GO
INSERT [dbo].[my1] ([USN], [subcode]) VALUES (N'1RN15MCA16', N'13MCA351')
GO
INSERT [dbo].[my1] ([USN], [subcode]) VALUES (N'1RN15MCA17', N'13MCA351')
GO
INSERT [dbo].[my1] ([USN], [subcode]) VALUES (N'1RN15MCA18', N'13MCA351')
GO
INSERT [dbo].[my1] ([USN], [subcode]) VALUES (N'1RN15MCA19', N'13MCA351')
GO
INSERT [dbo].[my1] ([USN], [subcode]) VALUES (N'1RN15MCA20', N'13MCA351')
GO
INSERT [dbo].[my1] ([USN], [subcode]) VALUES (N'1RN15MCA22', N'13MCA351')
GO
INSERT [dbo].[my1] ([USN], [subcode]) VALUES (N'1RN15MCA23', N'13MCA351')
GO
INSERT [dbo].[my1] ([USN], [subcode]) VALUES (N'1RN15MCA24', N'13MCA351')
GO
INSERT [dbo].[my1] ([USN], [subcode]) VALUES (N'1RN15MCA28', N'13MCA351')
GO
INSERT [dbo].[my1] ([USN], [subcode]) VALUES (N'1RN15MCA30', N'13MCA351')
GO
INSERT [dbo].[my1] ([USN], [subcode]) VALUES (N'1RN15MCA31', N'13MCA351')
GO
INSERT [dbo].[my1] ([USN], [subcode]) VALUES (N'1RN15MCA32', N'13MCA351')
GO
INSERT [dbo].[my1] ([USN], [subcode]) VALUES (N'1RN15MCA33', N'13MCA351')
GO
INSERT [dbo].[my1] ([USN], [subcode]) VALUES (N'1RN15MCA34', N'13MCA351')
GO
INSERT [dbo].[my1] ([USN], [subcode]) VALUES (N'1RN15MCA36', N'13MCA351')
GO
INSERT [dbo].[my1] ([USN], [subcode]) VALUES (N'1RN15MCA37', N'13MCA351')
GO
INSERT [dbo].[my1] ([USN], [subcode]) VALUES (N'1RN15MCA40', N'13MCA351')
GO
INSERT [dbo].[my1] ([USN], [subcode]) VALUES (N'1RN15MCA41', N'13MCA351')
GO
INSERT [dbo].[my1] ([USN], [subcode]) VALUES (N'1RN15MCA42', N'13MCA351')
GO
INSERT [dbo].[my1] ([USN], [subcode]) VALUES (N'1RN15MCA43', N'13MCA351')
GO
INSERT [dbo].[my1] ([USN], [subcode]) VALUES (N'1RN15MCA44', N'13MCA351')
GO
INSERT [dbo].[my1] ([USN], [subcode]) VALUES (N'1RN15MCA45', N'13MCA351')
GO
INSERT [dbo].[my1] ([USN], [subcode]) VALUES (N'1RN15MCA47', N'13MCA351')
GO
INSERT [dbo].[my1] ([USN], [subcode]) VALUES (N'1RN15MCA48', N'13MCA351')
GO
INSERT [dbo].[my1] ([USN], [subcode]) VALUES (N'1RN15MCA49', N'13MCA351')
GO
INSERT [dbo].[my1] ([USN], [subcode]) VALUES (N'1RN15MCA50', N'13MCA351')
GO
INSERT [dbo].[my1] ([USN], [subcode]) VALUES (N'1RN13MCA22', N'13MCA351')
GO
INSERT [dbo].[my1] ([USN], [subcode]) VALUES (N'1RN16MCA75', N'13MCA351')
GO
INSERT [dbo].[my1] ([USN], [subcode]) VALUES (N'1RN16MCA85', N'13MCA351')
GO
INSERT [dbo].[my1] ([USN], [subcode]) VALUES (N'1RN16MCA76', N'13MCA351')
GO
INSERT [dbo].[my1] ([USN], [subcode]) VALUES (N'1RN16MCA71', N'13MCA351')
GO
INSERT [dbo].[my1] ([USN], [subcode]) VALUES (N'1RN16MCA82', N'13MCA351')
GO
INSERT [dbo].[my1] ([USN], [subcode]) VALUES (N'1RN16MCA74', N'13MCA351')
GO
INSERT [dbo].[my1] ([USN], [subcode]) VALUES (N'1RX15MCA03', N'13MCA351')
GO
INSERT [dbo].[my1] ([USN], [subcode]) VALUES (N'1RX15MCA04', N'13MCA351')
GO
INSERT [dbo].[my1] ([USN], [subcode]) VALUES (N'1RX15MCA05', N'13MCA351')
GO
INSERT [dbo].[my1] ([USN], [subcode]) VALUES (N'1RX15MCA06', N'13MCA351')
GO
INSERT [dbo].[my1] ([USN], [subcode]) VALUES (N'1RX15MCA08', N'13MCA351')
GO
INSERT [dbo].[my1] ([USN], [subcode]) VALUES (N'1RX15MCA10', N'13MCA351')
GO
INSERT [dbo].[my1] ([USN], [subcode]) VALUES (N'1RX15MCA11', N'13MCA351')
GO
INSERT [dbo].[my1] ([USN], [subcode]) VALUES (N'1RX15MCA13', N'13MCA351')
GO
INSERT [dbo].[my1] ([USN], [subcode]) VALUES (N'1RX15MCA14', N'13MCA351')
GO
INSERT [dbo].[my1] ([USN], [subcode]) VALUES (N'1RX15MCA18', N'13MCA351')
GO
INSERT [dbo].[my1] ([USN], [subcode]) VALUES (N'1RX15MCA19', N'13MCA351')
GO
INSERT [dbo].[my1] ([USN], [subcode]) VALUES (N'1RX15MCA20', N'13MCA351')
GO
INSERT [dbo].[my1] ([USN], [subcode]) VALUES (N'1RX15MCA21', N'13MCA351')
GO
INSERT [dbo].[my1] ([USN], [subcode]) VALUES (N'1RX15MCA22', N'13MCA351')
GO
INSERT [dbo].[my1] ([USN], [subcode]) VALUES (N'1RX15MCA23', N'13MCA351')
GO
INSERT [dbo].[my1] ([USN], [subcode]) VALUES (N'1RX15MCA25', N'13MCA351')
GO
INSERT [dbo].[my1] ([USN], [subcode]) VALUES (N'1RX15MCA26', N'13MCA351')
GO
INSERT [dbo].[my1] ([USN], [subcode]) VALUES (N'1RX15MCA28', N'13MCA351')
GO
INSERT [dbo].[my1] ([USN], [subcode]) VALUES (N'1RX15MCA29', N'13MCA351')
GO
INSERT [dbo].[my1] ([USN], [subcode]) VALUES (N'1RX15MCA33', N'13MCA351')
GO
INSERT [dbo].[my1] ([USN], [subcode]) VALUES (N'1RX15MCA34', N'13MCA351')
GO
INSERT [dbo].[my1] ([USN], [subcode]) VALUES (N'1RX15MCA35', N'13MCA351')
GO
INSERT [dbo].[my1] ([USN], [subcode]) VALUES (N'1RX15MCA37', N'13MCA351')
GO
INSERT [dbo].[my1] ([USN], [subcode]) VALUES (N'1RX15MCA39', N'13MCA351')
GO
INSERT [dbo].[my1] ([USN], [subcode]) VALUES (N'1RX15MCA40', N'13MCA351')
GO
INSERT [dbo].[my1] ([USN], [subcode]) VALUES (N'1RX15MCA43', N'13MCA351')
GO
INSERT [dbo].[my1] ([USN], [subcode]) VALUES (N'1RX15MCA44', N'13MCA351')
GO
INSERT [dbo].[my1] ([USN], [subcode]) VALUES (N'1RX15MCA47', N'13MCA351')
GO
INSERT [dbo].[my1] ([USN], [subcode]) VALUES (N'1RX15MCA48', N'13MCA351')
GO
INSERT [dbo].[my1] ([USN], [subcode]) VALUES (N'1RX15MCA50', N'13MCA351')
GO
INSERT [dbo].[my1] ([USN], [subcode]) VALUES (N'1RX15MCA51', N'13MCA351')
GO
INSERT [dbo].[my1] ([USN], [subcode]) VALUES (N'1RX15MCA52', N'13MCA351')
GO
INSERT [dbo].[my1] ([USN], [subcode]) VALUES (N'1RX15MCA53', N'13MCA351')
GO
INSERT [dbo].[my1] ([USN], [subcode]) VALUES (N'1RX15MCA56', N'13MCA351')
GO
INSERT [dbo].[my1] ([USN], [subcode]) VALUES (N'1RX15MCA57', N'13MCA351')
GO
INSERT [dbo].[my1] ([USN], [subcode]) VALUES (N'1RX15MCA58', N'13MCA351')
GO
INSERT [dbo].[my1] ([USN], [subcode]) VALUES (N'1RN15MCA02', N'13MCA355')
GO
INSERT [dbo].[my1] ([USN], [subcode]) VALUES (N'1RN15MCA21', N'13MCA355')
GO
INSERT [dbo].[my1] ([USN], [subcode]) VALUES (N'1RN15MCA26', N'13MCA355')
GO
INSERT [dbo].[my1] ([USN], [subcode]) VALUES (N'1RN15MCA27', N'13MCA355')
GO
INSERT [dbo].[my1] ([USN], [subcode]) VALUES (N'1RN15MCA29', N'13MCA355')
GO
INSERT [dbo].[my1] ([USN], [subcode]) VALUES (N'1RN15MCA35', N'13MCA355')
GO
INSERT [dbo].[my1] ([USN], [subcode]) VALUES (N'1RN15MCA39', N'13MCA355')
GO
INSERT [dbo].[my1] ([USN], [subcode]) VALUES (N'1RN15MCA46', N'13MCA355')
GO
INSERT [dbo].[my1] ([USN], [subcode]) VALUES (N'1RN16MCA70', N'13MCA355')
GO
INSERT [dbo].[my1] ([USN], [subcode]) VALUES (N'1RN16MCA72', N'13MCA355')
GO
INSERT [dbo].[my1] ([USN], [subcode]) VALUES (N'1RN16MCA73', N'13MCA355')
GO
INSERT [dbo].[my1] ([USN], [subcode]) VALUES (N'1RN16MCA77', N'13MCA355')
GO
INSERT [dbo].[my1] ([USN], [subcode]) VALUES (N'1RN16MCA78', N'13MCA355')
GO
INSERT [dbo].[my1] ([USN], [subcode]) VALUES (N'1RN16MCA80', N'13MCA355')
GO
INSERT [dbo].[my1] ([USN], [subcode]) VALUES (N'1RN16MCA81', N'13MCA355')
GO
INSERT [dbo].[my1] ([USN], [subcode]) VALUES (N'1RN16MCA83', N'13MCA355')
GO
INSERT [dbo].[my1] ([USN], [subcode]) VALUES (N'1RN16MCA84', N'13MCA355')
GO
INSERT [dbo].[my1] ([USN], [subcode]) VALUES (N'1RN16MCA86', N'13MCA355')
GO
INSERT [dbo].[my1] ([USN], [subcode]) VALUES (N'1RN16MCA87', N'13MCA355')
GO
INSERT [dbo].[my1] ([USN], [subcode]) VALUES (N'1RN16MCA88', N'13MCA355')
GO
INSERT [dbo].[my1] ([USN], [subcode]) VALUES (N'1RN16MCA89', N'13MCA355')
GO
INSERT [dbo].[my1] ([USN], [subcode]) VALUES (N'1RN16MCA90', N'13MCA355')
GO
INSERT [dbo].[my1] ([USN], [subcode]) VALUES (N'1RN16MCA91', N'13MCA355')
GO
INSERT [dbo].[my1] ([USN], [subcode]) VALUES (N'1RX15MCA01', N'13MCA355')
GO
INSERT [dbo].[my1] ([USN], [subcode]) VALUES (N'1RX15MCA02', N'13MCA355')
GO
INSERT [dbo].[my1] ([USN], [subcode]) VALUES (N'1RX15MCA09', N'13MCA355')
GO
INSERT [dbo].[my1] ([USN], [subcode]) VALUES (N'1RX15MCA12', N'13MCA355')
GO
INSERT [dbo].[my1] ([USN], [subcode]) VALUES (N'1RX15MCA15', N'13MCA355')
GO
INSERT [dbo].[my1] ([USN], [subcode]) VALUES (N'1RX15MCA16', N'13MCA355')
GO
INSERT [dbo].[my1] ([USN], [subcode]) VALUES (N'1RX15MCA17', N'13MCA355')
GO
INSERT [dbo].[my1] ([USN], [subcode]) VALUES (N'1RX15MCA24', N'13MCA355')
GO
INSERT [dbo].[my1] ([USN], [subcode]) VALUES (N'1RX15MCA27', N'13MCA355')
GO
INSERT [dbo].[my1] ([USN], [subcode]) VALUES (N'1RX15MCA30', N'13MCA355')
GO
INSERT [dbo].[my1] ([USN], [subcode]) VALUES (N'1RX15MCA31', N'13MCA355')
GO
INSERT [dbo].[my1] ([USN], [subcode]) VALUES (N'1RX15MCA32', N'13MCA355')
GO
INSERT [dbo].[my1] ([USN], [subcode]) VALUES (N'1RX15MCA36', N'13MCA355')
GO
INSERT [dbo].[my1] ([USN], [subcode]) VALUES (N'1RX15MCA38', N'13MCA355')
GO
INSERT [dbo].[my1] ([USN], [subcode]) VALUES (N'1RX15MCA41', N'13MCA355')
GO
INSERT [dbo].[my1] ([USN], [subcode]) VALUES (N'1RX15MCA42', N'13MCA355')
GO
INSERT [dbo].[my1] ([USN], [subcode]) VALUES (N'1RX15MCA45', N'13MCA355')
GO
INSERT [dbo].[my1] ([USN], [subcode]) VALUES (N'1RX15MCA46', N'13MCA355')
GO
INSERT [dbo].[my1] ([USN], [subcode]) VALUES (N'1RX15MCA49', N'13MCA355')
GO
INSERT [dbo].[my1] ([USN], [subcode]) VALUES (N'1RX15MCA54', N'13MCA355')
GO
INSERT [dbo].[my1] ([USN], [subcode]) VALUES (N'1RX15MCA55', N'13MCA355')
GO
INSERT [dbo].[STUDENT] ([USN], [NAME], [DOB], [FATHERNAME], [MOTHERNAME], [GUARDIANNAME], [PERM_ADDRESS], [LOC_ADDRESS], [MOBILE], [PRIMARY_CONTACT], [DeptID], [Sem], [Section], [EMail], [SSLC], [PUC], [Batch], [isVallid]) VALUES (N'1RN14CS129', N'Lalit Adithya ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'CSE       ', 3, N'A         ', NULL, NULL, NULL, NULL, 1)
GO
INSERT [dbo].[STUDENT] ([USN], [NAME], [DOB], [FATHERNAME], [MOTHERNAME], [GUARDIANNAME], [PERM_ADDRESS], [LOC_ADDRESS], [MOBILE], [PRIMARY_CONTACT], [DeptID], [Sem], [Section], [EMail], [SSLC], [PUC], [Batch], [isVallid]) VALUES (N'1RN14CS138', N'asd', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'CSE       ', 5, N'B         ', NULL, NULL, NULL, NULL, 1)
GO
INSERT [dbo].[STUDENT] ([USN], [NAME], [DOB], [FATHERNAME], [MOTHERNAME], [GUARDIANNAME], [PERM_ADDRESS], [LOC_ADDRESS], [MOBILE], [PRIMARY_CONTACT], [DeptID], [Sem], [Section], [EMail], [SSLC], [PUC], [Batch], [isVallid]) VALUES (N'1RN14CS147', N'qwewq', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'CSE       ', 7, N'C         ', NULL, NULL, NULL, NULL, 1)
GO
INSERT [dbo].[STUDENT] ([USN], [NAME], [DOB], [FATHERNAME], [MOTHERNAME], [GUARDIANNAME], [PERM_ADDRESS], [LOC_ADDRESS], [MOBILE], [PRIMARY_CONTACT], [DeptID], [Sem], [Section], [EMail], [SSLC], [PUC], [Batch], [isVallid]) VALUES (N'1RN14CS156', N'cvxc', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'CSE       ', 8, N'D         ', NULL, NULL, NULL, NULL, 1)
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'CHEM001', N'T Jeevananda ', N'CHEM      ', N'HoD', N'                                                                                                    ', N'FD2B7F6')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'CHEM002', N'V Bheema raju', N'CHEM      ', N'Professor', N'                                                                                                    ', N'0ED4F4B')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'CHEM003', N'Vinay Kumar B', N'CHEM      ', N'Associate Professor', N'                                                                                                    ', N'DCE4B80')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'CHEM004', N'Karthika Shetty', N'CHEM      ', N'Associate Professor', N'                                                                                                    ', N'5DB13B7')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'CHEM005', N'Ramanath Prabhu', N'CHEM      ', N'Associate Professor', N'                                                                                                    ', N'8E56575')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'CHEM006', N'Vidyavathi G T', N'CHEM      ', N'Associate Professor', N'                                                                                                    ', N'B5453A4')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'CIV001', N'Pratap Kumar M T', N'CIV       ', N'HoD', N'                                                                                                    ', N'819DFEE')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'CIV002', N'Abhilash N R', N'CIV       ', N'Assistant Professor', N'                                                                                                    ', N'769B859')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'CIV003', N'Apoorva', N'CIV       ', N'Assistant Professor', N'                                                                                                    ', N'E0A9E32')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'CIV004', N'Indrakiran Reddy A', N'CIV       ', N'Assistant Professor', N'                                                                                                    ', N'1EA6F66')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'CIV005', N'Mrs. Pragnya V J', N'CIV       ', N'Assistant Professor', N'                                                                                                    ', N'E8BA274')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'CIV006', N'Rumpa Sarkhel', N'CIV       ', N'Assistant Professor', N'                                                                                                    ', N'483FA99')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'CIV007', N'Shashirekha S', N'CIV       ', N'Assistant Professor', N'                                                                                                    ', N'764B881')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'CIV008', N'Shivakumar B Patil', N'CIV       ', N'Assistant Professor', N'                                                                                                    ', N'CEB2996')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'CIV009', N'Suchetha D', N'CIV       ', N'Assistant Professor', N'                                                                                                    ', N'ABBB969')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'CIV010', N'Vindyashree H S', N'CIV       ', N'Assistant Professor', N'                                                                                                    ', N'37FF563')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'CIV11', N'CHANDAN G S', N'CIV       ', N'Assistant Professor', N'111@foo.com                                                                                         ', N'484B714')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'CIV12', N'Gargi G S', N'CIV       ', N'Assistant Professor', N'foo@foo.com                                                                                         ', N'33A3145')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'CIV13', N'VIDYA M N', N'CIV       ', N'Assistant Professor', N'123@foo.com                                                                                         ', N'1FCCF41')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'CIV14', N'PRAGNYA V J', N'CIV       ', N'Assistant Professor', N'foo@bar.com                                                                                         ', N'109F886')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'CIV15', N'B.J.S Acharya', N'CIV       ', N'Assistant Professor', N'foof@foo.com                                                                                        ', N'AD4D580')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'CSE001', N'G T Raju', N'CSE       ', N'HoD', N'                                                                                                    ', N'61F1155')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'CSE002', N'Girijamma H A', N'CSE       ', N'Professor', N'                                                                                                    ', N'59AF949')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'CSE003', N'Kiran P', N'CSE       ', N'Associate Professor', N'                                                                                                    ', N'18F0901')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'CSE004', N'Nandini N', N'CSE       ', N'Assistant Professor', N'                                                                                                    ', N'0A46C7D')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'CSE005', N'S Sathish Kumar', N'CSE       ', N'Associate Professor', N'                                                                                                    ', N'C23588A')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'CSE006', N'T Satish Kumar', N'CSE       ', N'Assistant Professor', N'                                                                                                    ', N'6B74336')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'CSE007', N'Anjan Kumar K N', N'CSE       ', N'Assistant Professor', N'                                                                                                    ', N'6BCA43F')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'CSE008', N'Bhavani ShankarK', N'CSE       ', N'Assistant Professor', N'                                                                                                    ', N'32F45EC')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'CSE009', N'Chandrashekar B S', N'CSE       ', N'Assistant Professor', N'                                                                                                    ', N'C0990F6')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'CSE010', N'Chethan D S', N'CSE       ', N'Assistant Professor', N'                                                                                                    ', N'5F441B5')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'CSE011', N'Chethana H R', N'CSE       ', N'Assistant Professor', N'                                                                                                    ', N'0FC4530')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'CSE012', N'Devaraj B M', N'CSE       ', N'Assistant Professor', N'                                                                                                    ', N'F40E931')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'CSE013', N'Disha D N', N'CSE       ', N'Assistant Professor', N'                                                                                                    ', N'587425D')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'CSE014', N'Gayatri V Kanade', N'CSE       ', N'Assistant Professor', N'                                                                                                    ', N'880B7C2')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'CSE015', N'H R Shashidhar', N'CSE       ', N'Assistant Professor', N'                                                                                                    ', N'4DD0770')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'CSE016', N'Hemanth S', N'CSE       ', N'Associate Professor', N'                                                                                                    ', N'64A710F')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'CSE017', N'Karanam Sunil Kumar', N'CSE       ', N'Assistant Professor', N'                                                                                                    ', N'4E18CEA')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'CSE018', N'Mahima M Katti', N'CSE       ', N'Assistant Professor', N'                                                                                                    ', N'4A0057F')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'CSE019', N'Medha Gourayya ', N'CSE       ', N'Assistant Professor', N'                                                                                                    ', N'6D5CCCD')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'CSE020', N'Ramyashree A N', N'CSE       ', N'Assistant Professor', N'                                                                                                    ', N'812F0BD')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'CSE021', N'Rashmi M', N'CSE       ', N'Assistant Professor', N'                                                                                                    ', N'ACAAD11')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'CSE022', N'Reshma Jakabal ', N'CSE       ', N'Assistant Professor', N'                                                                                                    ', N'AA2F71D')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'CSE023', N'Sampada K S', N'CSE       ', N'Assistant Professor', N'                                                                                                    ', N'2EC333C')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'CSE024', N'Sanjay P Kalas', N'CSE       ', N'Assistant Professor', N'                                                                                                    ', N'3DB5975')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'CSE025', N'Srinivas Biradar', N'CSE       ', N'Assistant Professor', N'                                                                                                    ', N'336D0F0')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'CSE026', N'Sudhamani M J', N'CSE       ', N'Assistant Professor', N'                                                                                                    ', N'E31CCC9')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'CSE027', N'Swathi G', N'CSE       ', N'Assistant Professor', N'                                                                                                    ', N'E53BF74')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'CSE028', N'Vidya Y', N'CSE       ', N'Assistant Professor', N'                                                                                                    ', N'112BC38')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'CSE29', N'test', N'CSE       ', N'asd', N'asd@adc.com                                                                                         ', N'AC76F7B')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'CSE30', N'as6da', N'CSE       ', N'Professor', N'as6d@ad.com                                                                                         ', N'6336CEC')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'EC001', N'Rajini V Honnungar', N'ECE       ', N'Associate Professor', N'                                                                                                    ', N'7982BB5')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'EC002', N'Uma S V', N'ECE       ', N'Associate Professor', N'                                                                                                    ', N'06A6515')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'EC003', N'Vipula Singh', N'ECE       ', N'HoD', N'                                                                                                    ', N'7BA406A')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'EC004', N' Aparna Vishwanath', N'ECE       ', N'Assistant Professor', N'                                                                                                    ', N'2810A21')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'EC005', N' Chaitra T S', N'ECE       ', N'Assistant Professor', N'                                                                                                    ', N'F6D4A5C')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'EC006', N' Chethana J', N'ECE       ', N'Assistant Professor', N'                                                                                                    ', N'892DA40')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'EC007', N' Ghousia Begum S', N'ECE       ', N'Assistant Professor', N'                                                                                                    ', N'6F8F897')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'EC008', N' Leena Chandrashekar', N'ECE       ', N'Assistant Professor', N'                                                                                                    ', N'D8C0EC6')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'EC009', N' Manjunath Naik V', N'ECE       ', N'Assistant Professor', N'                                                                                                    ', N'53F3AF8')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'EC010', N' Nandini K. S', N'ECE       ', N'Assistant Professor', N'                                                                                                    ', N'2094D7C')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'EC011', N' Neethu R', N'ECE       ', N'Assistant Professor', N'                                                                                                    ', N'7D64636')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'EC012', N' Niya Jackson ', N'ECE       ', N'Assistant Professor', N'                                                                                                    ', N'D6750D9')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'EC013', N' Praveen G', N'ECE       ', N'Assistant Professor', N'                                                                                                    ', N'3FB7811')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'EC014', N' Praveen S P', N'ECE       ', N'Assistant Professor', N'                                                                                                    ', N'5DF8DED')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'EC015', N' Sanjay M Belgaonkar', N'ECE       ', N'Assistant Professor', N'                                                                                                    ', N'561632E')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'EC016', N' Saraswathi G Joshi', N'ECE       ', N'Assistant Professor', N'                                                                                                    ', N'B570A0F')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'EC017', N' Suchandana Mishra', N'ECE       ', N'Assistant Professor', N'                                                                                                    ', N'694D53A')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'EC018', N' Vanitha', N'ECE       ', N'Assistant Professor', N'                                                                                                    ', N'22BE5AB')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'EC019', N' Vinaya Kusuma', N'ECE       ', N'Assistant Professor', N'                                                                                                    ', N'C80A1CD')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'EC020', N'Archana R Kulkarni', N'ECE       ', N'Assistant Professor', N'                                                                                                    ', N'FA24DE4')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'EC021', N'Ibrar Jahan.M.A', N'ECE       ', N'Assistant Professor', N'                                                                                                    ', N'2A2CCC1')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'EC022', N'Mamatha A S', N'ECE       ', N'Assistant Professor', N'                                                                                                    ', N'A6A63FD')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'EC023', N'Manjula V K', N'ECE       ', N'Associate Professor', N'                                                                                                    ', N'421C17A')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'EC024', N'Ms. Geetha G', N'ECE       ', N'Assistant Professor', N'                                                                                                    ', N'B40D90A')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'EC025', N'Ms. Kalpana M', N'ECE       ', N'Assistant Professor', N'                                                                                                    ', N'F7B322D')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'EC026', N'Narendra Kumar', N'ECE       ', N'Assistant Professor', N'                                                                                                    ', N'5D0C673')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'EC027', N'Ohileshwari M.S', N'ECE       ', N'Assistant Professor', N'                                                                                                    ', N'193914F')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'EC028', N'Prabhavati C N', N'ECE       ', N'Assistant Professor', N'                                                                                                    ', N'CAB5BA4')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'EC029', N'Prakash Tunga P', N'ECE       ', N'Assistant Professor', N'                                                                                                    ', N'F998300')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'EC030', N'Sangeetha B G', N'ECE       ', N'Assistant Professor', N'                                                                                                    ', N'AE96592')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'EC031', N'Sankalp Bailur', N'ECE       ', N'Assistant Professor', N'                                                                                                    ', N'78396C7')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'EC032', N'Smitha N', N'ECE       ', N'Assistant Professor', N'                                                                                                    ', N'44D736B')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'EC033', N'Sreenivasa Babu M O', N'ECE       ', N'Assistant Professor', N'                                                                                                    ', N'31FFD71')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'EC034', N'Sridhara .S. N', N'ECE       ', N'Professor', N'                                                                                                    ', N'4D62C0B')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'EC035', N'Swetha B', N'ECE       ', N'Assistant Professor', N'                                                                                                    ', N'0C880A0')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'EC036', N'Usha B S', N'ECE       ', N'Assistant Professor', N'                                                                                                    ', N'E32F874')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'ECE37', N'Kalpana M', N'ECE       ', N'Assistant Professor', N'111@foo.com                                                                                         ', N'DACF1A5')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'ECE38', N'M K Venkatesha', N'ECE       ', N'Principal', N'12@12.com                                                                                           ', N'C4224CA')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'ECE39', N'SANJAY M B', N'ECE       ', N'Assistant Professor', N'foo@foo.com                                                                                         ', N'33AF13B')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'EEE001', N'S SUMATHI ', N'EEE       ', N'HoD', N'                                                                                                    ', N'9F47145')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'EEE002', N'SHARADA PRASAD N ', N'EEE       ', N'Associate Professor', N'                                                                                                    ', N'C63E000')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'EEE003', N'ANOOP H A ', N'EEE       ', N'Associate Professor', N'                                                                                                    ', N'240C836')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'EEE004', N'BALAJI CHAKRAVARTHY', N'EEE       ', N'Associate Professor', N'                                                                                                    ', N'1321D82')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'EEE005', N'KOKILA R ', N'EEE       ', N'Associate Professor', N'                                                                                                    ', N'D74C92E')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'EEE006', N'M N RAKESH ', N'EEE       ', N'Associate Professor', N'                                                                                                    ', N'FB41981')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'EEE007', N'MALLIKARJUNA B ', N'EEE       ', N'Associate Professor', N'                                                                                                    ', N'071A07E')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'EEE008', N'Md. AMEEN SADIQ', N'EEE       ', N'Associate Professor', N'                                                                                                    ', N'49A5378')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'EEE009', N'RASHMY DEEPAK ', N'EEE       ', N'Associate Professor', N'                                                                                                    ', N'23B79AB')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'EEE010', N'ROOPA NAYAK ', N'EEE       ', N'Associate Professor', N'                                                                                                    ', N'E87FD14')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'EEE011', N'S SRIDHAR ', N'EEE       ', N'Associate Professor', N'                                                                                                    ', N'4E57D17')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'EEE012', N'SHRUTHI SHIVANAND ', N'EEE       ', N'Associate Professor', N'                                                                                                    ', N'F96DA0A')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'EEE013', N'SHWETHA', N'EEE       ', N'Associate Professor', N'                                                                                                    ', N'748516B')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'EEE014', N'SUPRIYA P ', N'EEE       ', N'Associate Professor', N'                                                                                                    ', N'268276D')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'EEE15', N'SHARMILA', N'EEE       ', N'Assistant Professor', N'foo@foo.com                                                                                         ', N'1742A2E')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'EI001', N'ANDHE PALLAVI', N'EI        ', N'HoD', N'                                                                                                    ', N'35DB1D0')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'EI002', N'CHETAN GHATAGE', N'EI        ', N'Associate Professor', N'                                                                                                    ', N'570124E')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'EI003', N'G N SRIKANTH', N'EI        ', N'Associate Professor', N'                                                                                                    ', N'5CF2CB3')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'EI004', N'GANESH YERENALLY', N'EI        ', N'Associate Professor', N'                                                                                                    ', N'9D0E0E7')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'EI005', N'LATHA P ', N'EI        ', N'Associate Professor', N'                                                                                                    ', N'288F9E4')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'EI006', N'MADHURA G', N'EI        ', N'Associate Professor', N'                                                                                                    ', N'212D4F8')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'EI007', N'MALLIKARJUN H M', N'EI        ', N'Associate Professor', N'                                                                                                    ', N'A378F31')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'EI008', N'MANOHAR P ', N'EI        ', N'Associate Professor', N'                                                                                                    ', N'9B53C38')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'EI009', N'PANNGA P K', N'EI        ', N'Associate Professor', N'                                                                                                    ', N'639BCB2')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'EI010', N'SANDHYA M S', N'EI        ', N'Associate Professor', N'                                                                                                    ', N'D00FC71')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'EI011', N'SAVITA S J', N'EI        ', N'Associate Professor', N'                                                                                                    ', N'4E165FA')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'EI012', N'SHALINI M S', N'EI        ', N'Associate Professor', N'                                                                                                    ', N'3C15AB1')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'EI013', N'SNEHA G C', N'EI        ', N'Associate Professor', N'                                                                                                    ', N'8DACFBD')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'ISE001', N'M V Sudhamani', N'ISE       ', N'HoD', N'                                                                                                    ', N'25C2090')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'ISE002', N'Asha M V', N'ISE       ', N'Assistant Professor', N'                                                                                                    ', N'8887FA8')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'ISE003', N'Bhagavath Singh T', N'ISE       ', N'Assistant Professor', N'                                                                                                    ', N'CBBFD9F')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'ISE004', N'Chethan J', N'ISE       ', N'Assistant Professor', N'                                                                                                    ', N'D3EF5FA')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'ISE005', N'Hema N', N'ISE       ', N'Assistant Professor', N'                                                                                                    ', N'137BEAE')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'ISE006', N'Kusuma R', N'ISE       ', N'Assistant Professor', N'                                                                                                    ', N'CA6CA86')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'ISE007', N'Kusuma S', N'ISE       ', N'Assistant Professor', N'                                                                                                    ', N'10A7E0F')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'ISE008', N'Leelavathi H V', N'ISE       ', N'Assistant Professor', N'                                                                                                    ', N'5496AE3')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'ISE009', N'Manoj Kumar H', N'ISE       ', N'Assistant Professor', N'                                                                                                    ', N'BD22C30')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'ISE010', N'Navya N', N'ISE       ', N'Assistant Professor', N'                                                                                                    ', N'B3A3A12')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'ISE011', N'Prakash S', N'ISE       ', N'Assistant Professor', N'                                                                                                    ', N'3692188')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'ISE012', N'Rajkumar R', N'ISE       ', N'Assistant Professor', N'                                                                                                    ', N'21A1062')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'ISE013', N'Ramesh S C', N'ISE       ', N'Assistant Professor', N'                                                                                                    ', N'94E7290')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'ISE014', N'Ravikumar S G', N'ISE       ', N'Assistant Professor', N'                                                                                                    ', N'E9BB28A')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'ISE015', N'Roopashree T P', N'ISE       ', N'Assistant Professor', N'                                                                                                    ', N'F16E742')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'ISE016', N'Sahana B', N'ISE       ', N'Assistant Professor', N'                                                                                                    ', N'E69B184')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'ISE017', N'Santhosh Kumar', N'ISE       ', N'Assistant Professor', N'                                                                                                    ', N'49492A3')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'ISE018', N'Sudha V', N'ISE       ', N'Assistant Professor', N'                                                                                                    ', N'85466C7')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'ISE019', N'Sunanda B', N'ISE       ', N'Assistant Professor', N'                                                                                                    ', N'373B8BE')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'ISE020', N'Tejashwini P', N'ISE       ', N'Assistant Professor', N'                                                                                                    ', N'ABEB633')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'ISE021', N'Vanishree S', N'ISE       ', N'Assistant Professor', N'                                                                                                    ', N'5A96F3E')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'ISE022', N'Vinutha G K', N'ISE       ', N'Assistant Professor', N'                                                                                                    ', N'D4E92C1')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'ISE23', N'Sowmya S K', N'ISE       ', N'Assistant Professor', N'123@foo.com                                                                                         ', N'BF47A21')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'ISE24', N'Srinidhi B K', N'ISE       ', N'Assitant Professor', N'foof@foo.com                                                                                        ', N'8696135')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'MAT001', N'Suresha C.M', N'MAT       ', N'HOD', N'                                                                                                    ', N'CE2609B')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'MAT002', N'Sampath Kumar. R', N'MAT       ', N'Assistant Professor', N'                                                                                                    ', N'2A4C198')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'MAT003', N'Narasimhan', N'MAT       ', N'Assistant Professor', N'                                                                                                    ', N'4DC9A9F')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'MAT004', N'Naveen Kumar B', N'MAT       ', N'Assistant Professor', N'                                                                                                    ', N'5D869DF')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'MAT005', N'Srihari M Subodha', N'MAT       ', N'Assistant Professor', N'                                                                                                    ', N'C6C40C4')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'MAT006', N'Dhruvathara B S', N'MAT       ', N'Assistant Professor', N'                                                                                                    ', N'BF9E16D')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'MAT007', N'Ambika', N'MAT       ', N'Assistant Professor', N'                                                                                                    ', N'A4754C8')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'MAT008', N'NANDINI B J', N'MAT       ', N'Assistant Professor', N'                                                                                                    ', N'F2B7648')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'MAT009', N'Chinni Krishna', N'MAT       ', N'Assistant Professor', N'                                                                                                    ', N'E5B7EB9')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'MAT010', N'Soumya', N'MAT       ', N'Assistant Professor', N'                                                                                                    ', N'C9C060A')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'MAT011', N'SHRUTHI RAO', N'MAT       ', N'Assistant Professor', N'                                                                                                    ', N'24D6912')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'MBA001', N'G V M Sharma', N'MBA       ', N'HOD', N'                                                                                                    ', N'BCF16EC')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'MBA002', N'S N Murthy', N'MBA       ', N'Professor', N'                                                                                                    ', N'180E669')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'MBA003', N'Satya Swaroopa Boyina', N'MBA       ', N'Associate Professor', N'                                                                                                    ', N'B549670')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'MBA004', N'Tamizharasi', N'MBA       ', N'Assistant Professor', N'                                                                                                    ', N'88CF310')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'MBA005', N'U Bhojanna', N'MBA       ', N'Assistant Professor', N'                                                                                                    ', N'7AEAD25')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'MBA006', N'Ajit V Deva', N'MBA       ', N'Assistant Professor', N'                                                                                                    ', N'15CABBF')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'MBA007', N'Archana JR', N'MBA       ', N'Assistant Professor', N'                                                                                                    ', N'1574213')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'MBA008', N'Ashok Kumar R S', N'MBA       ', N'Assistant Professor', N'                                                                                                    ', N'25AA015')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'MBA009', N'Deepak Kumar D', N'MBA       ', N'Assistant Professor', N'                                                                                                    ', N'EFB10F4')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'MBA010', N'Mamta Hegde', N'MBA       ', N'Assistant Professor', N'                                                                                                    ', N'A702EAD')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'MBA011', N'Manjunath N', N'MBA       ', N'Assistant Professor', N'                                                                                                    ', N'2437A3E')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'MBA012', N'MeenaDevi K ', N'MBA       ', N'Assistant Professor', N'                                                                                                    ', N'6E98995')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'MBA013', N'Pradeep Kumar K', N'MBA       ', N'Assistant Professor', N'                                                                                                    ', N'289A102')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'MBA014', N'Santosh Basavaraj', N'MBA       ', N'Assistant Professor', N'                                                                                                    ', N'430B616')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'MBA015', N'Shekar H S', N'MBA       ', N'Assistant Professor', N'                                                                                                    ', N'BC8589A')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'MBA016', N'Srikanth I G ', N'MBA       ', N'Assistant Professor', N'                                                                                                    ', N'3758B2F')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'MBA017', N'Vinay H V', N'MBA       ', N'Assistant Professor', N'                                                                                                    ', N'BED255B')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'MBA18', N'Rajashekharaiah ', N'MBA       ', N'Assistant Professor', N'123@foo.com                                                                                         ', N'CE943CA')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'MBA19', N'Shreedhar N.', N'MBA       ', N'Assistant Professor', N'12@12.com                                                                                           ', N'2CB3CB5')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'MBA20', N'Manjunath K C', N'MBA       ', N'Assistant Professor', N'123@123.com                                                                                         ', N'AA24A41')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'MBA21', N'Rajan L P', N'MBA       ', N'Assistant Professor ', N'admin@mba.com                                                                                       ', N'4814D48')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'MBA22', N'Dr. G V M SHARMA ', N'MBA       ', N'Associate Professor', N'foo@foo.com                                                                                         ', N'16A8C8F')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'MBA23', N'PRIYANKA TILAK ', N'MBA       ', N'Assistant Professor', N'foo@foo.com                                                                                         ', N'EEAFC96')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'MBA24', N'Mrs. DIVYA RAI', N'MBA       ', N'Assistant Professor', N'foo@foo.com                                                                                         ', N'893AD59')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'MCA001', N'Chetana Hegde', N'MCA       ', N'Associate Professor', N'                                                                                                    ', N'DF90FE7')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'MCA002', N'N P Kavya', N'MCA       ', N'HOD', N'                                                                                                    ', N'383B656')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'MCA003', N'Padmanabhan  ', N'MCA       ', N'Assistant Professor', N'                                                                                                    ', N'24A4C2B')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'MCA004', N'Rajani Narayan', N'MCA       ', N'Assistant Professor', N'                                                                                                    ', N'AF8E9A0')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'MCA005', N'Akshata Bhayyar', N'MCA       ', N'Assistant Professor', N'                                                                                                    ', N'E8CBD62')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'MCA006', N'Hemanth Kumar', N'MCA       ', N'Assistant Professor', N'                                                                                                    ', N'2A595ED')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'MCA007', N'Jyothi T', N'MCA       ', N'Assistant Professor', N'                                                                                                    ', N'47D0C38')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'MCA008', N'Karthik S Chouri', N'MCA       ', N'Assistant Professor', N'                                                                                                    ', N'D333716')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'MCA009', N'Nagesh  B S', N'MCA       ', N'Assistant Professor', N'                                                                                                    ', N'E8D5477')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'MCA010', N'Nandan G P', N'MCA       ', N'Assistant Professor', N'                                                                                                    ', N'CAB297D')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'MCA011', N'Nayana B M ', N'MCA       ', N'Assistant Professor', N'                                                                                                    ', N'82E6C16')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'MCA012', N'Raghu Prasad K', N'MCA       ', N'Assistant Professor', N'                                                                                                    ', N'A38112F')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'MCA013', N'Rajatha S', N'MCA       ', N'Assistant Professor', N'                                                                                                    ', N'8515405')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'MCA014', N'Ramasatish K V', N'MCA       ', N'Assistant Professor', N'                                                                                                    ', N'458C932')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'MCA015', N'Roopa H M', N'MCA       ', N'Assistant Professor', N'                                                                                                    ', N'C9F6892')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'MCA016', N'Shreedevi ', N'MCA       ', N'Assistant Professor', N'                                                                                                    ', N'2C20148')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'MCA017', N'Shwetha G N  ', N'MCA       ', N'Assistant Professor', N'                                                                                                    ', N'4E91977')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'MCA018', N'Suma M G', N'MCA       ', N'Assistant Professor', N'                                                                                                    ', N'C347A70')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'MCA019', N'Vishwanath   Murthy', N'MCA       ', N'Assistant Professor', N'                                                                                                    ', N'CEAEC18')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'ME001', N'T Srinivasan', N'ME        ', N'HoD', N'                                                                                                    ', N'18F92C7')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'ME002', N'Yeshovanth H R', N'ME        ', N'Professor', N'                                                                                                    ', N'3426569')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'ME003', N'Amruta Bahuguni', N'ME        ', N'Assistant Professor', N'                                                                                                    ', N'7C3E818')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'ME004', N'Aruna K', N'ME        ', N'Assistant Professor', N'                                                                                                    ', N'1777232')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'ME005', N'Basava Kumar K G', N'ME        ', N'Professor', N'                                                                                                    ', N'A6DAA62')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'ME006', N'Chetana S Batakurki', N'ME        ', N'Assistant Professor', N'                                                                                                    ', N'2CB8E69')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'ME007', N'Chethan K', N'ME        ', N'Assistant Professor', N'                                                                                                    ', N'6703125')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'ME008', N'Darshan K B', N'ME        ', N'Assistant Professor', N'                                                                                                    ', N'A8AA4A5')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'ME009', N'Guruprasad T', N'ME        ', N'Assistant Professor', N'                                                                                                    ', N'E5E2E2D')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'ME010', N'Gutta Aparna', N'ME        ', N'Assistant Professor', N'                                                                                                    ', N'AEDFC12')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'ME011', N'Madan K ', N'ME        ', N'Assistant Professor', N'                                                                                                    ', N'6808E1C')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'ME012', N'Mahesh Kumar N', N'ME        ', N'Assistant Professor', N'                                                                                                    ', N'A85A582')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'ME013', N'Mrs. Laxmi B Wali', N'ME        ', N'Assistant Professor', N'                                                                                                    ', N'5CCC8AF')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'ME014', N'Nagaraja N', N'ME        ', N'Assistant Professor', N'                                                                                                    ', N'5ACD912')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'ME015', N'Nagarjun C M', N'ME        ', N'Assistant Professor', N'                                                                                                    ', N'EC8258F')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'ME016', N'Nagendra R N', N'ME        ', N'Assistant Professor', N'                                                                                                    ', N'78D4722')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'ME017', N'Preetham S', N'ME        ', N'Assistant Professor', N'                                                                                                    ', N'1F58DF5')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'ME018', N'Pritam Bhat', N'ME        ', N'Assistant Professor', N'                                                                                                    ', N'E16EAB3')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'ME019', N'Raghavendra G Galgali', N'ME        ', N'Assistant Professor', N'                                                                                                    ', N'62BE158')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'ME020', N'Rangaswamy N. S.', N'ME        ', N'Assistant Professor', N'                                                                                                    ', N'E0B489F')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'ME021', N'Rohini A', N'ME        ', N'Assistant Professor', N'                                                                                                    ', N'75DD9E8')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'ME022', N'Salim Firdosh', N'ME        ', N'Assistant Professor', N'                                                                                                    ', N'71CAB9B')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'ME023', N'Shaik Nasser S N', N'ME        ', N'Assistant Professor', N'                                                                                                    ', N'4962DCB')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'ME024', N'Shidhar N Shastry', N'ME        ', N'Assistant Professor', N'                                                                                                    ', N'74E8A0A')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'ME025', N'Siddu Kataraki', N'ME        ', N'Assistant Professor', N'                                                                                                    ', N'2D863F1')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'ME026', N'Srikanth P Chakravarthy', N'ME        ', N'Assistant Professor', N'                                                                                                    ', N'4EC9C11')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'ME027', N'Vasantha Rao K P', N'ME        ', N'Assistant Professor', N'                                                                                                    ', N'1C07B76')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'ME028', N'Vasudeva Upadhyaya', N'ME        ', N'Assistant Professor', N'                                                                                                    ', N'F7E3690')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'ME29', N'AKANKSHA', N'ME        ', N'Assitant Professor', N'foo@foo.com                                                                                         ', N'B3639E5')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'ME30', N'RANGANATH', N'ME        ', N'Assitant Professor', N'foo@foo.com                                                                                         ', N'511DB6B')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'ME31', N'SANJU H', N'ME        ', N'Assistant Professor', N'foo@foo.com                                                                                         ', N'7E87FB7')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'ME32', N'SHALINI S.H', N'ME        ', N'Assistant Professor', N'foo@foo.com                                                                                         ', N'6908360')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'PHY001', N'Pandurangappa C.', N'PHY       ', N'HoD', N'                                                                                                    ', N'7158F08')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'PHY002', N'Daly Paul', N'PHY       ', N'Assistant Professor', N'                                                                                                    ', N'6DC05F0')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'PHY003', N'Smitha M.G', N'PHY       ', N'Assistant Professor', N'                                                                                                    ', N'3959A83')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'PHY004', N'Jagadeesh Kumar P', N'PHY       ', N'Assistant Professor', N'                                                                                                    ', N'FE08E04')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'PHY005', N'RAJENDRA.H.J', N'PHY       ', N'Assistant Professor', N'                                                                                                    ', N'78CB452')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'PHY006', N'Sandeep Kumar', N'PHY       ', N'Assistant Professor', N'                                                                                                    ', N'F64586F')
GO
INSERT [dbo].[Teacher] ([TID], [TeacherName], [DeptId], [Designation], [E-mail], [password]) VALUES (N'PHY007', N'Asha Paravathi', N'PHY       ', N'Assistant Professor', N'                                                                                                    ', N'8B329BA')
GO
INSERT [dbo].[ValidS] ([USN], [PASSGEN], [COUNTER], [FG], [STUDENTDETAILS]) VALUES (N'1RN14CS129', N'42117B6', 0, 0, 0)
GO
INSERT [dbo].[ValidS] ([USN], [PASSGEN], [COUNTER], [FG], [STUDENTDETAILS]) VALUES (N'1RN14CS138', N'7CB9FBA', 0, 0, 0)
GO
INSERT [dbo].[ValidS] ([USN], [PASSGEN], [COUNTER], [FG], [STUDENTDETAILS]) VALUES (N'1RN14CS147', N'D8A230B', 0, 0, 0)
GO
INSERT [dbo].[ValidS] ([USN], [PASSGEN], [COUNTER], [FG], [STUDENTDETAILS]) VALUES (N'1RN14CS156', N'4719B37', 0, 0, 0)
GO
ALTER TABLE [dbo].[ValidS] ADD  CONSTRAINT [DF_ValidS_Counter]  DEFAULT ((0)) FOR [COUNTER]
GO
ALTER TABLE [dbo].[ValidS] ADD  CONSTRAINT [DF_ValidS_FG]  DEFAULT ((0)) FOR [FG]
GO
ALTER TABLE [dbo].[ValidS] ADD  CONSTRAINT [DF_ValidS_Studentdetails]  DEFAULT ((0)) FOR [STUDENTDETAILS]
GO
ALTER TABLE [dbo].[Admin]  WITH CHECK ADD  CONSTRAINT [FK_Admin_DEPT] FOREIGN KEY([Dept])
REFERENCES [dbo].[DEPT] ([DeptId])
GO
ALTER TABLE [dbo].[Admin] CHECK CONSTRAINT [FK_Admin_DEPT]
GO
ALTER TABLE [dbo].[AspNetUserClaims]  WITH CHECK ADD  CONSTRAINT [FK_dbo.AspNetUserClaims_dbo.AspNetUsers_UserId] FOREIGN KEY([UserId])
REFERENCES [dbo].[AspNetUsers] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[AspNetUserClaims] CHECK CONSTRAINT [FK_dbo.AspNetUserClaims_dbo.AspNetUsers_UserId]
GO
ALTER TABLE [dbo].[AspNetUserLogins]  WITH CHECK ADD  CONSTRAINT [FK_dbo.AspNetUserLogins_dbo.AspNetUsers_UserId] FOREIGN KEY([UserId])
REFERENCES [dbo].[AspNetUsers] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[AspNetUserLogins] CHECK CONSTRAINT [FK_dbo.AspNetUserLogins_dbo.AspNetUsers_UserId]
GO
ALTER TABLE [dbo].[AspNetUserRoles]  WITH CHECK ADD  CONSTRAINT [FK_dbo.AspNetUserRoles_dbo.AspNetRoles_RoleId] FOREIGN KEY([RoleId])
REFERENCES [dbo].[AspNetRoles] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[AspNetUserRoles] CHECK CONSTRAINT [FK_dbo.AspNetUserRoles_dbo.AspNetRoles_RoleId]
GO
ALTER TABLE [dbo].[AspNetUserRoles]  WITH CHECK ADD  CONSTRAINT [FK_dbo.AspNetUserRoles_dbo.AspNetUsers_UserId] FOREIGN KEY([UserId])
REFERENCES [dbo].[AspNetUsers] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[AspNetUserRoles] CHECK CONSTRAINT [FK_dbo.AspNetUserRoles_dbo.AspNetUsers_UserId]
GO
ALTER TABLE [dbo].[NEW_RID_TABLE]  WITH CHECK ADD FOREIGN KEY([RID])
REFERENCES [dbo].[SubComb] ([CombId])
GO
ALTER TABLE [dbo].[NEW_RID_TABLE]  WITH CHECK ADD FOREIGN KEY([USN])
REFERENCES [dbo].[STUDENT] ([USN])
GO
ALTER TABLE [dbo].[NewElectivesTable]  WITH CHECK ADD  CONSTRAINT [FK__NewElecti__SubCo__02284B6B] FOREIGN KEY([SubCode])
REFERENCES [dbo].[Subject] ([SubCode])
GO
ALTER TABLE [dbo].[NewElectivesTable] CHECK CONSTRAINT [FK__NewElecti__SubCo__02284B6B]
GO
ALTER TABLE [dbo].[NewElectivesTable]  WITH CHECK ADD  CONSTRAINT [FK__NewElective__USN__01342732] FOREIGN KEY([USN])
REFERENCES [dbo].[STUDENT] ([USN])
GO
ALTER TABLE [dbo].[NewElectivesTable] CHECK CONSTRAINT [FK__NewElective__USN__01342732]
GO
ALTER TABLE [dbo].[STUDENT]  WITH NOCHECK ADD  CONSTRAINT [FK_STUDENT_DEPT] FOREIGN KEY([DeptID])
REFERENCES [dbo].[DEPT] ([DeptId])
GO
ALTER TABLE [dbo].[STUDENT] CHECK CONSTRAINT [FK_STUDENT_DEPT]
GO
ALTER TABLE [dbo].[SubComb]  WITH CHECK ADD  CONSTRAINT [FK_SubComb_DEPT1] FOREIGN KEY([DeptId])
REFERENCES [dbo].[DEPT] ([DeptId])
GO
ALTER TABLE [dbo].[SubComb] CHECK CONSTRAINT [FK_SubComb_DEPT1]
GO
ALTER TABLE [dbo].[SubComb]  WITH CHECK ADD  CONSTRAINT [FK_SubComb_Teacher1] FOREIGN KEY([TID])
REFERENCES [dbo].[Teacher] ([TID])
GO
ALTER TABLE [dbo].[SubComb] CHECK CONSTRAINT [FK_SubComb_Teacher1]
GO
ALTER TABLE [dbo].[SubComb]  WITH CHECK ADD  CONSTRAINT [FK_Subject_Subcode] FOREIGN KEY([SubCode])
REFERENCES [dbo].[Subject] ([SubCode])
GO
ALTER TABLE [dbo].[SubComb] CHECK CONSTRAINT [FK_Subject_Subcode]
GO
ALTER TABLE [dbo].[Subject]  WITH CHECK ADD  CONSTRAINT [FK_Subject_DEPT] FOREIGN KEY([DeptId])
REFERENCES [dbo].[DEPT] ([DeptId])
GO
ALTER TABLE [dbo].[Subject] CHECK CONSTRAINT [FK_Subject_DEPT]
GO
ALTER TABLE [dbo].[Suggestions]  WITH CHECK ADD FOREIGN KEY([USN])
REFERENCES [dbo].[STUDENT] ([USN])
GO
ALTER TABLE [dbo].[Teacher]  WITH CHECK ADD  CONSTRAINT [FK_Teacher_DEPT] FOREIGN KEY([DeptId])
REFERENCES [dbo].[DEPT] ([DeptId])
GO
ALTER TABLE [dbo].[Teacher] CHECK CONSTRAINT [FK_Teacher_DEPT]
GO
ALTER TABLE [dbo].[ValidS]  WITH CHECK ADD  CONSTRAINT [FK_ValidS_STUDENT] FOREIGN KEY([USN])
REFERENCES [dbo].[STUDENT] ([USN])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[ValidS] CHECK CONSTRAINT [FK_ValidS_STUDENT]
GO
/****** Object:  StoredProcedure [dbo].[A1]    Script Date: 10/27/2017 8:27:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
create PROCEDURE [dbo].[A1] 
	@rid varchar(50)
AS
BEGIN
	
	SET NOCOUNT ON;
	select [1] as "No._of_1s" ,[2] as "No._of_2s",[3] as "No._of_3s",[4] as "No._of_4s" from(select A1,COUNT(*)-1 as cnt from RNSIT.[dbo].RID_TABLE where RID=@rid group by A1) AS TableToBePIVOTED
	PIVOT
	(
	sum(cnt)
	for A1 in ([1],[2],[3],[4])
	)AS PivotedTable;
 
END

GO
/****** Object:  StoredProcedure [dbo].[A10]    Script Date: 10/27/2017 8:27:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
create PROCEDURE [dbo].[A10] 
	@rid varchar(50)
AS
BEGIN
	
	SET NOCOUNT ON;
	select [1] as "No._of_1s" ,[2] as "No._of_2s",[3] as "No._of_3s",[4] as "No._of_4s" from(select A10,COUNT(*)-1 as cnt from RNSIT.[dbo].RID_TABLE where RID=@rid group by A10) AS TableToBePIVOTED
	PIVOT
	(
	sum(cnt)
	for A10 in ([1],[2],[3],[4])
	)AS PivotedTable;
 
END

GO
/****** Object:  StoredProcedure [dbo].[A2]    Script Date: 10/27/2017 8:27:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
create PROCEDURE [dbo].[A2] 
	@rid varchar(50)
AS
BEGIN
	
	SET NOCOUNT ON;
	select [1] as "No._of_1s" ,[2] as "No._of_2s",[3] as "No._of_3s",[4] as "No._of_4s" from(select A2,COUNT(*)-1 as cnt from RNSIT.[dbo].RID_TABLE where RID=@rid group by A2) AS TableToBePIVOTED
	PIVOT
	(
	sum(cnt)
	for A2 in ([1],[2],[3],[4])
	)AS PivotedTable;
 
END

GO
/****** Object:  StoredProcedure [dbo].[A3]    Script Date: 10/27/2017 8:27:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
create PROCEDURE [dbo].[A3] 
	@rid varchar(50)
AS
BEGIN
	
	SET NOCOUNT ON;
	select [1] as "No._of_1s" ,[2] as "No._of_2s",[3] as "No._of_3s",[4] as "No._of_4s" from(select A3,COUNT(*)-1 as cnt from RNSIT.[dbo].RID_TABLE where RID=@rid group by A3) AS TableToBePIVOTED
	PIVOT
	(
	sum(cnt)
	for A3 in ([1],[2],[3],[4])
	)AS PivotedTable;
 
END

GO
/****** Object:  StoredProcedure [dbo].[A4]    Script Date: 10/27/2017 8:27:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
create PROCEDURE [dbo].[A4] 
	@rid varchar(50)
AS
BEGIN
	
	SET NOCOUNT ON;
	select [1] as "No._of_1s" ,[2] as "No._of_2s",[3] as "No._of_3s",[4] as "No._of_4s" from(select A4,COUNT(*)-1 as cnt from RNSIT.[dbo].RID_TABLE where RID=@rid group by A4) AS TableToBePIVOTED
	PIVOT
	(
	sum(cnt)
	for A4 in ([1],[2],[3],[4])
	)AS PivotedTable;
 
END

GO
/****** Object:  StoredProcedure [dbo].[A5]    Script Date: 10/27/2017 8:27:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
create PROCEDURE [dbo].[A5] 
	@rid varchar(50)
AS
BEGIN
	
	SET NOCOUNT ON;
	select [1] as "No._of_1s" ,[2] as "No._of_2s",[3] as "No._of_3s",[4] as "No._of_4s" from(select A5,COUNT(*)-1 as cnt from RNSIT.[dbo].RID_TABLE where RID=@rid group by A5) AS TableToBePIVOTED
	PIVOT
	(
	sum(cnt)
	for A5 in ([1],[2],[3],[4])
	)AS PivotedTable;
 
END

GO
/****** Object:  StoredProcedure [dbo].[A6]    Script Date: 10/27/2017 8:27:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
create PROCEDURE [dbo].[A6] 
	@rid varchar(50)
AS
BEGIN
	
	SET NOCOUNT ON;
	select [1] as "No._of_1s" ,[2] as "No._of_2s",[3] as "No._of_3s",[4] as "No._of_4s" from(select A6,COUNT(*)-1 as cnt from RNSIT.[dbo].RID_TABLE where RID=@rid group by A6) AS TableToBePIVOTED
	PIVOT
	(
	sum(cnt)
	for A6 in ([1],[2],[3],[4])
	)AS PivotedTable;
 
END

GO
/****** Object:  StoredProcedure [dbo].[A7]    Script Date: 10/27/2017 8:27:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
create PROCEDURE [dbo].[A7] 
	@rid varchar(50)
AS
BEGIN
	
	SET NOCOUNT ON;
	select [1] as "No._of_1s" ,[2] as "No._of_2s",[3] as "No._of_3s",[4] as "No._of_4s" from(select A7,COUNT(*)-1 as cnt from RNSIT.[dbo].RID_TABLE where RID=@rid group by A7) AS TableToBePIVOTED
	PIVOT
	(
	sum(cnt)
	for A7 in ([1],[2],[3],[4])
	)AS PivotedTable;
 
END

GO
/****** Object:  StoredProcedure [dbo].[A8]    Script Date: 10/27/2017 8:27:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
create PROCEDURE [dbo].[A8] 
	@rid varchar(50)
AS
BEGIN
	
	SET NOCOUNT ON;
	select [1] as "No._of_1s" ,[2] as "No._of_2s",[3] as "No._of_3s",[4] as "No._of_4s" from(select A8,COUNT(*)-1 as cnt from RNSIT.[dbo].RID_TABLE where RID=@rid group by A8) AS TableToBePIVOTED
	PIVOT
	(
	sum(cnt)
	for A8 in ([1],[2],[3],[4])
	)AS PivotedTable;
 
END

GO
/****** Object:  StoredProcedure [dbo].[A9]    Script Date: 10/27/2017 8:27:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
create PROCEDURE [dbo].[A9] 
	@rid varchar(50)
AS
BEGIN
	
	SET NOCOUNT ON;
	select [1] as "No._of_1s" ,[2] as "No._of_2s",[3] as "No._of_3s",[4] as "No._of_4s" from(select A9,COUNT(*)-1 as cnt from RNSIT.[dbo].RID_TABLE where RID=@rid group by A9) AS TableToBePIVOTED
	PIVOT
	(
	sum(cnt)
	for A9 in ([1],[2],[3],[4])
	)AS PivotedTable;
 
END

GO
/****** Object:  StoredProcedure [dbo].[calc]    Script Date: 10/27/2017 8:27:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[calc] 
	-- Add the parameters for the stored procedure here
	
	
	
AS
declare @RID nvarchar(50);
declare @su numeric(10,3);
declare @ri nvarchar(50);
declare @co numeric(10,3);
declare @per numeric(20,3);

declare getRID CURSOR for
select CombID from SubComb
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
    -- Insert statements for procedure here
	 
	open getRID;
	fetch next from getRID into @RID;
	
	while @@FETCH_STATUS=0
	 begin
	  
	SELECT
	   @ri=[RID]
	  ,@su=Sum([A1]+[A2]+[A3]+[A4]+[A5]+[A6]+[A7]+[A8]+[A9]+[A10])
      ,@co=COUNT(*)       
  FROM RNSIT.[dbo].[NEW_RID_TABLE]
  where RID=@RID
  group by RID
 if @co>0
 begin
  Select @per=((@su*100)/(@co*40));
 
 update SubComb set CGPA=@per where CombID=@RID
 end
else
update SubComb set CGPA=0 where CombID=@RID
 
fetch next from getRID into @RID;
END;
close getRID;

open getRID;
fetch next from getRID into @RID;
	
	while @@FETCH_STATUS=0
	 begin
	 select @co=COUNT(*) from SubComb where CGPA<=(Select CGPA from SubComb where CombID=@RID);
	 select @su=COUNT(*) from SubComb;
	 
	  if @su>0
		begin
			select @per=(@co*100)/@su;
			update SubComb set Percentile=@per where CombID=@RID;
			END
			fetch next from getRID into @RID;
		END;
			close getRID;
			deallocate getRID;
			
END


GO
/****** Object:  StoredProcedure [dbo].[department]    Script Date: 10/27/2017 8:27:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROCEDURE [dbo].[department]
(
	@dept nchar(10)
)
AS
	SET NOCOUNT ON;
SELECT DeptName FROM Dept WHERE (DeptID = @dept)
GO
/****** Object:  StoredProcedure [dbo].[GetLowerTableByRID]    Script Date: 10/27/2017 8:27:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[GetLowerTableByRID]
@rid varchar(50)
as
begin
Delete from LowerTable;
With LT
as
  (
  SELECT '1. Effective Communication and Clarity in Explanation' as Question,* FROM (select A1,COALESCE(count(A1),0) as CountOfA1 from NEW_RID_TABLE

  where rid = @rid
  group by A1) as Data
  pivot(
  
  sum(CountOfA1)
  FOR A1 in ([1],[2],[3],[4])
  ) as pivotTable
union all

  SELECT '2.Preparedness and Depth of Subject Knowledge (Relevant Practical Applications wherever applicable' as Question,* FROM (select A2,COALESCE(count(A2),0) as CountOfA2 from NEW_RID_TABLE

  where rid = @rid
  group by A2) as Data
  pivot(
  
  sum(CountOfA2)
  FOR A2 in ([1],[2],[3],[4])
  ) as pivotTable

  union all

  SELECT '3.Time Management (Effective use of the class hour and timely coverage of syllabus' as Question,* FROM (select A3,COALESCE(count(A3),0) as CountOfA3 from NEW_RID_TABLE

  where rid = @rid
  group by A3) as Data
  pivot(
  
  sum(CountOfA3)
  FOR A3 in ([1],[2],[3],[4])
  ) as pivotTable

  union all

  SELECT '4.Enforcement of Discipline in the class' as Question,* FROM (select A4,COALESCE(count(A4),0) as CountOfA4 from NEW_RID_TABLE

  where rid = @rid
  group by A4) as Data
  pivot(
  
  sum(CountOfA4)
  FOR A4 in ([1],[2],[3],[4])
  ) as pivotTable

    union all

  SELECT '5.Invites Questions and Encourages Thinking (Class Motivation towards Enhanced Learning' as Question,* FROM (select A5,COALESCE(count(A5),0) as CountOfA5 from NEW_RID_TABLE

  where rid = @rid
  group by A5) as Data
  pivot(
  
  sum(CountOfA5)
  FOR A5 in ([1],[2],[3],[4])
  ) as pivotTable

  union all

  SELECT '6.Provide discussions on Problems, Programs, Assignments, Quiz, case studies/situation analysis, Exam questions and Illustrations' as Question,* FROM (select A6,COALESCE(count(A6),0) as CountOfA6 from NEW_RID_TABLE

  where rid = @rid
  group by A6) as Data
  pivot(
  
  sum(CountOfA6)
  FOR A6 in ([1],[2],[3],[4])
  ) as pivotTable

    union all

  SELECT '7.Availability, Accessibility and Approachability for clarifications outside the Class' as Question,* FROM (select A7,COALESCE(count(A7),0) as CountOfA7 from NEW_RID_TABLE

  where rid = @rid
  group by A7) as Data
  pivot(
  
  sum(CountOfA7)
  FOR A7 in ([1],[2],[3],[4])
  ) as pivotTable

    union all

  SELECT '8.Study materials such as Lecture notes, handouts, PPTs, etc.' as Question,* FROM (select A8,COALESCE(count(A8),0) as CountOfA8 from NEW_RID_TABLE

  where rid = @rid
  group by A8) as Data
  pivot(
  
  sum(CountOfA8)
  FOR A8 in ([1],[2],[3],[4])
  ) as pivotTable

    union all

  SELECT '9.Coverage of Syllabus' as Question,* FROM (select A9,COALESCE(count(A9),0) as CountOfA9 from NEW_RID_TABLE

  where rid =@rid
  group by A9) as Data
  pivot(
  
  sum(CountOfA9)
  FOR A9 in ([1],[2],[3],[4])
  ) as pivotTable

    union all

  SELECT '10.Evaluation of Tests or Assignments with suggestions for Improvement' as Question,* FROM (select A10,COALESCE(count(A10),0) as CountOfA10 from NEW_RID_TABLE

  where rid = @rid
  group by A10) as Data
  pivot(
  
  sum(CountOfA10)
  FOR A10 in ([1],[2],[3],[4])
  ) as pivotTable
  )
  insert into LowerTable
  select Question, COALESCE([1],0) as [1],  COALESCE([2],0) as [2], COALESCE([3],0) as [3], COALESCE([4],0) as [4] from LT

  select * from LowerTable
  END
GO
/****** Object:  StoredProcedure [dbo].[getScores]    Script Date: 10/27/2017 8:27:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROCEDURE [dbo].[getScores]
	
	
	/*@DeptID nvarchar(10),
	@TeacherID nvarchar(50)*/
	@rid nvarchar(50)
	
AS
	/*DECLARE @ListofIDs TABLE(IDs VARCHAR(100));
	/* SET NOCOUNT ON */
	EXEC('select CombID from SubComb where TeacherID='+@TeacherID+' and DeptID='+@DeptID);
	*/
	EXEC('select AVG(PR) as Q1,AVG(DS) as Q2,AVG(AA) as Q3,AVG(CC) as Q4,AVG(EC) as Q5,AVG(PC) as Q6,AVG(DP) as Q7,AVG(IE) as Q8,AVG(PA) as Q9,AVG(ET) as Q10 from ' + @rid)
	RETURN

GO
/****** Object:  StoredProcedure [dbo].[GetTeacherDetailsByUSN]    Script Date: 10/27/2017 8:27:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[GetTeacherDetailsByUSN] --'1RX14MBA55'
@usn nvarchar(50)
as
SELECT  
	Subcomb.CombId,
	SubComb.[SubCode],
	[Subject].SubName,
    Teacher.TeacherName,
	SubComb.Elective  
  FROM [RNSIT].[dbo].[SubComb], STUDENT, Teacher, [Subject]
  where SubComb.TID = Teacher.TID and SubComb.SubCode = [Subject].SubCode and
  SubComb.DeptId = STUDENT.DeptID and SubComb.Sem = STUDENT.Sem and
  SubComb.Section = STUDENT.Section and STUDENT.USN = @usn
  and SubComb.Elective = 0
	union

SELECT  
	Subcomb.CombId,
	SubComb.[SubCode],
	[Subject].SubName,
    Teacher.TeacherName,
	SubComb.Elective  
  FROM [RNSIT].[dbo].[SubComb], STUDENT S, Teacher, [Subject], NewElectivesTable E
  where SubComb.TID = Teacher.TID and SubComb.SubCode = [Subject].SubCode and
  SubComb.DeptId = S.DeptID and SubComb.Sem = S.Sem and
  SubComb.Section = S.Section and e.USN = S.USN and S.USN = @usn and e.SubCode = SubComb.SubCode
  and SubComb.[SubCode] in (select N.SubCode from NewElectivesTable N where n.USN = @usn)
  
  order by SubComb.[SubCode] asc

GO
/****** Object:  StoredProcedure [dbo].[NewInsertCommand]    Script Date: 10/27/2017 8:27:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROCEDURE [dbo].[NewInsertCommand]
(
	@RID nvarchar(50),
	@A1 numeric(10, 4),
	@A2 numeric(10, 4),
	@A3 numeric(10, 4),
	@A4 numeric(10, 4),
	@A5 numeric(10, 4),
	@A6 numeric(10, 4),
	@A7 numeric(10, 4),
	@A8 numeric(10, 4),
	@A9 numeric(10, 4),
	@A10 numeric(10, 4)
)
AS
	SET NOCOUNT OFF;
INSERT INTO [RID_TABLE] ([RID], [A1], [A2], [A3], [A4], [A5], [A6], [A7], [A8], [A9], [A10]) VALUES (@RID, @A1, @A2, @A3, @A4, @A5, @A6, @A7, @A8, @A9, @A10)
GO
/****** Object:  StoredProcedure [dbo].[NewSelectCommand]    Script Date: 10/27/2017 8:27:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROCEDURE [dbo].[NewSelectCommand]
AS
	SET NOCOUNT ON;
SELECT        RID_TABLE.*
FROM            RID_TABLE
GO
/****** Object:  StoredProcedure [dbo].[passgen]    Script Date: 10/27/2017 8:27:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
create PROCEDURE [dbo].[passgen] 
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	/*declare @c int
	select @c=count(*) from StudentDetails
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.*/
	SET NOCOUNT ON;
		insert into ValidS (USN) select USN from Student;
		update ValidS set PassGen=SUBSTRING(convert(varchar(50),NEWID()),0,8) ;
    -- Insert statements for procedure here
		/*while(@c!=0)
		//begin
		
		set @c=@c-1
		end*/
END

GO
/****** Object:  StoredProcedure [dbo].[rating4c]    Script Date: 10/27/2017 8:27:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[rating4c]
		
	@rid nvarchar(50)
	/*@c1 nvarchar(4) output,
	@c2 nvarchar(4) output,
	@c3 nvarchar(4) output*/
AS

	Exec('SELECT COUNT(*)-1 as Num,A1 FROM [RNSIT].[dbo].[RID_TABLE] where RID=O20121 group by A1 ');
	Return



GO
/****** Object:  StoredProcedure [dbo].[spAddElectiveForStudent]    Script Date: 10/27/2017 8:27:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[spAddElectiveForStudent]
@USN varchar(20),
@subcode varchar(max)
as
begin
insert into NewElectivesTable(Usn, SubCode)
values(@USN, @subcode)
end

GO
/****** Object:  StoredProcedure [dbo].[spAddElectivesForClass]    Script Date: 10/27/2017 8:27:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[spAddElectivesForClass]
@DeptId varchar(max),
@sem int,
@section varchar(max),
@SubCode varchar(max)
as
begin
insert into NewElectivesTable(Usn, SubCode)
select usn, @SubCode as subcode 
from STUDENT where DeptID=@DeptId and Sem=@sem and Section=@section
end
GO
/****** Object:  StoredProcedure [dbo].[spAddElectivesForSemester]    Script Date: 10/27/2017 8:27:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[spAddElectivesForSemester]
@DeptId varchar(max),
@sem int,
@SubCode varchar(max)
as
begin
insert into NewElectivesTable(Usn, SubCode)
select usn, @SubCode as subcode 
from STUDENT where DeptID=@DeptId and Sem=@sem
end
GO
/****** Object:  StoredProcedure [dbo].[spDeleteElectivesForParticularStudent]    Script Date: 10/27/2017 8:27:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[spDeleteElectivesForParticularStudent]
  @USN varchar(20),
  @subcode varchar(max)
  as
  begin
  Delete from NewElectivesTable
  where USN = @USN and SubCode = @subcode
  end

GO
/****** Object:  StoredProcedure [dbo].[spGetAll]    Script Date: 10/27/2017 8:27:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[spGetAll]
as
begin
select DeptId, Sem, Section, SubCode, CombId
from SubComb
order by 1,2,3
end
GO
/****** Object:  StoredProcedure [dbo].[spGetDepartments]    Script Date: 10/27/2017 8:27:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[spGetDepartments]
as
begin
	select * from DEPT
end
GO
/****** Object:  StoredProcedure [dbo].[spGetElectivesForParticularStudent]    Script Date: 10/27/2017 8:27:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  create procedure [dbo].[spGetElectivesForParticularStudent]
  @USN varchar(20)
  as
  begin
  select subcode from NewElectivesTable
  where USN = @USN
  end

GO
/****** Object:  StoredProcedure [dbo].[spGetElectivesForStudent]    Script Date: 10/27/2017 8:27:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[spGetElectivesForStudent] --'1rn12cs043'
  @usn varchar(50)
  as
  begin
  select sub.SubCode, sub.SubName, s.DeptID, s.Sem, s.Section
  from STUDENT s, Subject sub
  where s.Sem = sub.Sem and s.DeptID = sub.DeptId and elective !=0
  and usn = @usn
  end

GO
/****** Object:  StoredProcedure [dbo].[spGetGivenByDeptartment]    Script Date: 10/27/2017 8:27:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[spGetGivenByDeptartment]
  @dept varchar(50)
  as
  begin
		select * from GivenNotGiven
		where DeptID = @dept
  end

GO
/****** Object:  StoredProcedure [dbo].[spGetGivenNotGiven]    Script Date: 10/27/2017 8:27:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[spGetGivenNotGiven]
as
begin
delete from GivenNotGiven

Insert into GivenNotGiven
SELECT STUDENT.DeptID,DeptName, Sem,Section, 0 as Given, 0 as NotGiven--,count(*) as Given
FROM STUDENT, DEPT
where STUDENT.DeptID = DEPT.DeptId
group by STUDENT.DeptID,DeptName, Sem,Section
order by DeptID,Sem,Section

select STUDENT.DeptID,Sem,Section,count(*) as Not_Given
into #temp1
FROM STUDENT,ValidS
WHERE ValidS.USN=STUDENT.USN and fg=0
group by STUDENT.DeptID,Sem,Section
order by Not_Given 

update GivenNotGiven
set NotGiven = coalesce((select Not_Given from #temp1 where DeptID=GivenNotGiven.DeptID and Sem=GivenNotGiven.Sem
and Section= GivenNotGiven.Section),0)

SELECT STUDENT.DeptID,Sem,Section,count(*) as Given
into #temp2
FROM STUDENT,ValidS
WHERE ValidS.USN=STUDENT.USN and fg=1
group by STUDENT.DeptID,Sem,Section
order by Given 

update GivenNotGiven
set Given = coalesce((select Given from #temp2 where DeptID=GivenNotGiven.DeptID and Sem=GivenNotGiven.Sem
and Section= GivenNotGiven.Section),0)

drop table #temp1 
drop table #temp2

end




--select * from GivenNotGiven


--update ValidS
--set FG=0
--where usn in (select usn from STUDENT where DeptID = 'cse')


GO
/****** Object:  StoredProcedure [dbo].[spGetGivenNotGivenDataForCollege]    Script Date: 10/27/2017 8:27:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[spGetGivenNotGivenDataForCollege]
  as
  begin
 select distinct s.DeptID,(select count(*) from ValidS where FG=1 and USN in (select usn from STUDENT where DeptID = s.DeptID)) as Given
, (select count(*) from ValidS where FG=0 and USN in (select usn from STUDENT where DeptID = s.DeptID)) as NotGiven
from valids v, student s
where v.USN = s.USN
order by DeptID
  end

GO
/****** Object:  StoredProcedure [dbo].[spGetGivenNotGivenDepartmentwise]    Script Date: 10/27/2017 8:27:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[spGetGivenNotGivenDepartmentwise]
  as
  begin
  select DeptID, Sum(Given) as Given, Sum(NotGiven) as NotGiven
  from GivenNotGiven
  group by DeptID
  end
GO
/****** Object:  StoredProcedure [dbo].[spGetPasswordsForClass]    Script Date: 10/27/2017 8:27:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[spGetPasswordsForClass]
@deptId varchar(10),
@sem int,
@sec varchar(10)
as
begin
	select distinct s.DeptID, s.Sem, s.Section, S.USN, s.NAME as 'StudentName' , V.PASSGEN as Passwords
	from STUDENT S, ValidS V
	where DeptId = @deptId and Sem = @sem and  Section = @sec and S.USN = V.USN
end

GO
/****** Object:  StoredProcedure [dbo].[spGetPrincipalView]    Script Date: 10/27/2017 8:27:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[spGetPrincipalView] --'cse', 6,'A'
  @dept varchar(50),
  @sem varchar(5),
  @sec nchar(10)
  as
  begin
  select v.USN, s.NAME, s.Sem, s.Section, v.FG, s.DeptID, d.DeptName
  from ValidS v, STUDENT s, DEPT d
  where v.USN = s.USN and s.Sem = @sem and s.Section = @sec and s.DeptID = @dept and d.DeptId = s.DeptID
  end

GO
/****** Object:  StoredProcedure [dbo].[spGetResultshv]    Script Date: 10/27/2017 8:27:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  create procedure [dbo].[spGetResultshv]
  as
  begin
	select TeacherName, DeptId, SubCode, Sem, Section, Expr1, CGPA, Percentile
	from Result
	order by CGPA desc 
  end
GO
/****** Object:  StoredProcedure [dbo].[spGetSection]    Script Date: 10/27/2017 8:27:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[spGetSection]
@DeptId varchar(10),
@Sem int
as
begin
	select distinct Section as 'Value', Section as 'ID'  from STUDENT 
	where DeptId = @DeptId and Sem = @Sem
end
GO
/****** Object:  StoredProcedure [dbo].[spGetSem]    Script Date: 10/27/2017 8:27:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[spGetSem] 
@DeptId varchar(10)
as
begin
	
select distinct sem as ID, sem as Value
from STUDENT
where DeptID = @DeptId
end

GO
/****** Object:  StoredProcedure [dbo].[spGetSemesterWiseGivenNotGiven]    Script Date: 10/27/2017 8:27:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[spGetSemesterWiseGivenNotGiven]
as
begin
select DeptID, Sem, SUM(Given) as Given, SUM(NotGiven) as NotGiven
from GivenNotGiven
group by DeptID, Sem
order by DeptID, Sem
end
GO
/****** Object:  StoredProcedure [dbo].[spGetStudentDetails]    Script Date: 10/27/2017 8:27:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

  CREATE procedure [dbo].[spGetStudentDetails]
  @usn varchar(20)
  as
  begin
  select NAME, Dept.DeptName, Sem, Section, EMail, PRIMARY_CONTACT
  from STUDENT, DEPT
  where DEPT.DeptId = STUDENT.DeptID and usn = @usn
  end

GO
/****** Object:  StoredProcedure [dbo].[spGetStudentsInClass]    Script Date: 10/27/2017 8:27:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[spGetStudentsInClass] --'mba', 2, 'A'
@deptId varchar(10),
@sem int,
@sec varchar(10)
  as
  begin
  select * from student 
  where STUDENT.DeptID = @deptId and STUDENT.Sem = @sem and STUDENT.Section = @sec
  end
GO
/****** Object:  StoredProcedure [dbo].[spGetSuggestions]    Script Date: 10/27/2017 8:27:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[spGetSuggestions]
  as
  begin
  select d.DeptName, Suggestions
  from STUDENT s, DEPT d, Suggestions sug
  where s.USN = sug.USN and s.DeptID = d.DeptId
  order by d.DeptName
  end

GO
/****** Object:  StoredProcedure [dbo].[spGetTeacherFeedback]    Script Date: 10/27/2017 8:27:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[spGetTeacherFeedback]
  as
  begin
  select t.TID,t.TeacherName, sc.DeptId,d.DeptName , sc.Sem, sc.SubCode, s.SubName,tf.Feedback, tf.Ratings
  from TeacherFeedback tf, Teacher t, SubComb sc, DEPT d, Subject s
  where tf.CombId = sc.CombId and
  t.TID = sc.TID and d.DeptId = sc.DeptId and s.SubCode = sc.SubCode
  end

GO
/****** Object:  StoredProcedure [dbo].[spGetTeachersConsolidatedReports]    Script Date: 10/27/2017 8:27:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

  Create Procedure [dbo].[spGetTeachersConsolidatedReports]
  as
  begin
  select Row_Number() Over(order by Percentile desc) as Rank, t.DeptId as StaffDept, t.TeacherName as Name, 
  s.SubCode, s.DeptId as SubDept, s.Sem , s.Section as Sec, s.CGPA, s.Percentile
  from Teacher t, SubComb s
  where t.TID = s.TID
  end
GO
/****** Object:  StoredProcedure [dbo].[spGetTeachersMultipleSubjectReport]    Script Date: 10/27/2017 8:27:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 create procedure [dbo].[spGetTeachersMultipleSubjectReport]
  as
  begin
  select t.TeacherName, t.DeptId, S1, S2, S3, S4, S5, S6, S7
  from Teacher t, ABCD a
  where t.TID = a.tid
  end

GO
/****** Object:  StoredProcedure [dbo].[spGetUpperTable]    Script Date: 10/27/2017 8:27:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[spGetUpperTable] 
 @combid varchar(50)
 as
 begin
  select CombId, DeptId, Sem, Section,
	(select TeacherName from Teacher where TID = SubComb.TID) as 'TeacherName',
	(select DeptId from Teacher where TID = SubComb.TID) as  'StaffDept',
	 TID,
	(select SubName from Subject where SubCode = SubComb.SubCode) as 'SubName',
	SubCode,
	CGPA
  from SubComb
  where CombId = @combid
  end
GO
/****** Object:  StoredProcedure [dbo].[spInsertInNewElectives]    Script Date: 10/27/2017 8:27:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  CREATE procedure [dbo].[spInsertInNewElectives] --'1rn12cs097', '10CS661'
  @usn nvarchar(50),
  @Subcode nvarchar(50)
  as
  begin
	insert into NewElectivesTable(Usn, SubCode)
	values(@usn, @Subcode)
  end

  select * from STUDENT
  where usn = '1rn12cs097'

GO
/****** Object:  StoredProcedure [dbo].[spInsertIntoABCD]    Script Date: 10/27/2017 8:27:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spInsertIntoABCD]
@tid varchar(20),
@S1 VARCHAR(10),
@S2 VARCHAR(10),
@S3 VARCHAR(10),
@S4 VARCHAR(10),
@S5 VARCHAR(10),
@S6 VARCHAR(10),
@S7 VARCHAR(10)
as
begin
	insert into ABCD
	values(@tid, @S1, @S2, @S3, @S4, @S5, @S6, @S7) 
end
GO
/****** Object:  StoredProcedure [dbo].[UsersLogin]    Script Date: 10/27/2017 8:27:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[UsersLogin]
	@userId nvarchar(50)
	as
	begin
	with tbl as
	(
		select V.USN as UserName, V.PASSGEN as [Password], 'Student' as [Role]
	from ValidS V
	union
	select A.Id, A.[Password], A.Roles
	from [Admin] A)
	select * from tbl
	where UserName = @userId
	end
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "Q1"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 136
               Right = 208
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Q2"
            Begin Extent = 
               Top = 6
               Left = 246
               Bottom = 136
               Right = 416
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'CountStatus'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'CountStatus'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "SubComb"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 114
               Right = 205
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Teacher"
            Begin Extent = 
               Top = 6
               Left = 243
               Bottom = 114
               Right = 410
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "STUDENT"
            Begin Extent = 
               Top = 6
               Left = 448
               Bottom = 114
               Right = 643
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "ValidS"
            Begin Extent = 
               Top = 114
               Left = 38
               Bottom = 222
               Right = 220
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 10
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 12
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'sucombs'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane2', @value=N'= 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'sucombs'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=2 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'sucombs'
GO
