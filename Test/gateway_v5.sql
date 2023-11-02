USE [gateway_v5]
GO
/****** Object:  UserDefinedTableType [dbo].[messageList]    Script Date: 01/11/2023 18:59:46 ******/
CREATE TYPE [dbo].[messageList] AS TABLE(
	[created] [datetime] NOT NULL,
	[processed] [datetime] NULL,
	[completed] [datetime] NULL,
	[messageText] [varchar](255) NULL,
	[transactionGUID] [varchar](38) NULL,
	[source] [varchar](15) NULL,
	[destination] [varchar](15) NULL,
	[type] [varchar](5) NULL,
	[status] [varchar](10) NULL
)
GO
/****** Object:  UserDefinedFunction [dbo].[CreateDateRange]    Script Date: 01/11/2023 18:59:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE FUNCTION [dbo].[CreateDateRange] (@DateFrom datetime,@DateTo datetime,@DatePart varchar(10),@Incr int)
Returns 
@ReturnVal Table (RetVal datetime)

As
Begin

-- Syntax Select * from [dbo].[udf-Create-Range-Date]('2016-10-01','2020-10-01','YY',1) 
-- Syntax Select * from [dbo].[udf-Create-Range-Date]('2016-10-01','2020-10-01','DD',1) 
-- Syntax Select * from [dbo].[udf-Create-Range-Date]('2016-10-01','2016-10-31','MI',15) 
-- Syntax Select * from [dbo].[udf-Create-Range-Date]('2016-10-01','2016-10-02','SS',1) 

    With DateTable As (
        Select DateFrom = @DateFrom
        Union All
        Select Case @DatePart
               When 'YY' then DateAdd(YY, @Incr, df.dateFrom)
               When 'QQ' then DateAdd(QQ, @Incr, df.dateFrom)
               When 'MM' then DateAdd(MM, @Incr, df.dateFrom)
               When 'WK' then DateAdd(WK, @Incr, df.dateFrom)
               When 'DD' then DateAdd(DD, @Incr, df.dateFrom)
               When 'HH' then DateAdd(HH, @Incr, df.dateFrom)
               When 'MI' then DateAdd(MI, @Incr, df.dateFrom)
               When 'SS' then DateAdd(SS, @Incr, df.dateFrom)
               End
        From DateTable DF
        Where DF.DateFrom < @DateTo
    )

    Insert into @ReturnVal(RetVal) Select DateFrom From DateTable option (maxrecursion 32767)

    Return
End



GO
/****** Object:  UserDefinedFunction [dbo].[CSVToTable]    Script Date: 01/11/2023 18:59:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE FUNCTION [dbo].[CSVToTable] (@InStr VARCHAR(MAX))
RETURNS 
@TempTab TABLE (id INT NOT NULL)

AS
BEGIN

	--  This function takes a comma separated value string and converts it into a table with an INT column

	--  The REPLACE part ensures the string is terminated with a single comma by appending one, and removing all double commas from the string. 
	SET @InStr = REPLACE(@InStr + ',', ',,', ',')
	DECLARE @SP INT
	DECLARE @VALUE VARCHAR(1000)

	WHILE PATINDEX('%,%', @INSTR ) <> 0 
	BEGIN
   		SELECT  @SP = PATINDEX('%,%',@INSTR)
   		SELECT  @VALUE = LEFT(@INSTR , @SP - 1)
   		SELECT  @INSTR = STUFF(@INSTR, 1, @SP, '')
   		INSERT INTO @TempTab(id) VALUES (@VALUE)
	END

	RETURN

END

GO
/****** Object:  UserDefinedFunction [dbo].[fnEndOfDay]    Script Date: 01/11/2023 18:59:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE FUNCTION [dbo].[fnEndOfDay] ( @DaysBack INT = 0 ) 
RETURNS DATETIME 
BEGIN 
    DECLARE @endDate AS DATETIME;
	SET @endDate = DATEADD(ms, -3, DATEADD(DAY, DATEDIFF(DAY, -1, GETDATE())-@DaysBack, 0));
	RETURN @endDate; 
END








GO
/****** Object:  UserDefinedFunction [dbo].[fnEndOfMonth]    Script Date: 01/11/2023 18:59:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE FUNCTION [dbo].[fnEndOfMonth] ( @MonthsBack INT = 0 )
RETURNS DATETIME 
BEGIN 
    DECLARE @endDate AS DATETIME;
	SET @endDate = DATEADD(ms, -3, DATEADD(MONTH, DATEDIFF(MONTH, -1, GETDATE())-@MonthsBack, 0));
	RETURN @endDate; 
END







GO
/****** Object:  UserDefinedFunction [dbo].[fnGetCountryCode]    Script Date: 01/11/2023 18:59:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE FUNCTION [dbo].[fnGetCountryCode](@countryCode varchar(10), @numberNPA varchar(10))  
RETURNS varchar(10)   
AS   
-- Returns normalized country code  
BEGIN  
    DECLARE @ret varchar(10);  
	IF @countryCode = 1 
		BEGIN
			IF @numberNPA IN ('800','888','877','866','855','844')
				SET @ret = CONCAT(@countryCode,@numberNPA)
			ELSE IF @numberNPA IN ('204','226','236','249','250','289','306','343','365','403','416','418','431','437','438','450','506','514','519','548','579','581','587','604','613','639','647','705','709','778','780','782','807','819','825','867','873','902','905')
				SET @ret = '1CA'
			ELSE
				SET @ret = '1US';
		END
	ELSE
		BEGIN
			SET @ret = @countryCode
		END;
		  
    RETURN @ret;  
END



GO
/****** Object:  UserDefinedFunction [dbo].[fnGetHour]    Script Date: 01/11/2023 18:59:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE FUNCTION [dbo].[fnGetHour] ( @HoursBack INT = 0 ) 
RETURNS DATETIME 
BEGIN 
	DECLARE @startDate AS DATETIME;
	SET @startDate = DATEADD(HOUR, DATEDIFF(HOUR, 0, GETUTCDATE())-@HoursBack, 0);
	RETURN @startDate; 
END


 





GO
/****** Object:  UserDefinedFunction [dbo].[fnStartOfDay]    Script Date: 01/11/2023 18:59:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE FUNCTION [dbo].[fnStartOfDay] ( @DaysBack INT = 0 ) 
RETURNS DATETIME 
BEGIN 
	DECLARE @startDate AS DATETIME;
	SET @startDate = DATEADD(DAY, DATEDIFF(DAY, 0, GETDATE())-@DaysBack, 0);
	RETURN @startDate; 
END


 




GO
/****** Object:  UserDefinedFunction [dbo].[fnStartOfMonth]    Script Date: 01/11/2023 18:59:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE FUNCTION [dbo].[fnStartOfMonth] ( @MonthsBack INT = 0 )
RETURNS DATETIME 
BEGIN 
	DECLARE @startDate AS DATETIME;
	SET @startDate = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-@MonthsBack, 0);
	RETURN @startDate; 
END







GO
/****** Object:  UserDefinedFunction [dbo].[parseMessageData]    Script Date: 01/11/2023 18:59:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE FUNCTION [dbo].[parseMessageData]
(  
	@BinaryColumn AS BINARY(4000)
)  
RETURNS NVARCHAR(2000) 
BEGIN   
	DECLARE @Counter INT, @ColumnLength INT, @Byte BINARY, @MessageText VARCHAR(2000);

	SET @ColumnLength = LEN(@BinaryColumn);
	SET @MessageText = '';

	SET @Byte = (SELECT SUBSTRING(@BinaryColumn, 1, 1));
	IF @Byte = 0x05 
		SET @Counter = 7
	ELSE
		SET @Counter = 1;

	WHILE (@Counter <= @ColumnLength) 
	BEGIN
	    SET @Byte = (SELECT SUBSTRING(@BinaryColumn, @Counter, 1));
		IF @Byte != 0x00 SET @MessageText += CHAR(@Byte);
	    SET @Counter = @Counter + 1;
	END; 

	RETURN REPLACE(REPLACE(REPLACE(@MessageText, CHAR(13), ''), CHAR(10), ''),',',' ')  ; 
END






GO
/****** Object:  UserDefinedFunction [dbo].[ExplodeDates]    Script Date: 01/11/2023 18:59:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE FUNCTION [dbo].[ExplodeDates](@startdate datetime, @enddate datetime)
returns table as
return (
with 
 N0 as (SELECT 1 as n UNION ALL SELECT 1)
,N1 as (SELECT 1 as n FROM N0 t1, N0 t2)
,N2 as (SELECT 1 as n FROM N1 t1, N1 t2)
,N3 as (SELECT 1 as n FROM N2 t1, N2 t2)
,N4 as (SELECT 1 as n FROM N3 t1, N3 t2)
,N5 as (SELECT 1 as n FROM N4 t1, N4 t2)
,N6 as (SELECT 1 as n FROM N5 t1, N5 t2)
,nums as (SELECT ROW_NUMBER() OVER (ORDER BY (SELECT 1)) as num FROM N6)
SELECT DATEADD(day,num-1,@startdate) as thedate
FROM nums
WHERE num <= DATEDIFF(day,@startdate,@enddate) + 1
);


GO
/****** Object:  Table [dbo].[account]    Script Date: 01/11/2023 18:59:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[account](
	[accountID] [int] IDENTITY(5000,1) NOT NULL,
	[accountGUID] [char](36) NOT NULL,
	[accountParentID] [int] NOT NULL,
	[accountRegistrationID] [int] NOT NULL,
	[accountIDPublic]  AS ([accountID]+(237425465)),
	[name] [varchar](100) NOT NULL,
	[billingType] [smallint] NOT NULL,
	[email] [varchar](100) NOT NULL,
	[phone1] [varchar](50) NOT NULL,
	[phone1isMobile] [bit] NOT NULL,
	[phone2] [varchar](50) NULL,
	[phone2isMobile] [bit] NULL,
	[address1] [varchar](50) NOT NULL,
	[address2] [varchar](50) NULL,
	[city] [varchar](50) NOT NULL,
	[state] [varchar](50) NOT NULL,
	[zip] [varchar](50) NOT NULL,
	[country] [varchar](50) NOT NULL,
	[website] [varchar](100) NULL,
	[paymentMethodOptionCard] [tinyint] NOT NULL,
	[paymentMethodOptionEFT] [tinyint] NOT NULL,
	[paymentMethodOptionCheck] [tinyint] NOT NULL,
	[paymentMethodSelection] [tinyint] NOT NULL,
	[paymentCardOnFile] [tinyint] NULL,
	[replyAbout] [varchar](160) NULL,
	[replyHelp] [varchar](160) NULL,
	[replyStop] [varchar](160) NULL,
	[tosVersion] [int] NULL,
	[tosAccepted] [datetime] NULL,
	[active] [bit] NOT NULL,
	[created] [datetime] NOT NULL,
	[lastUpdated] [datetime] NOT NULL,
	[IsMigrated] [bit] NOT NULL,
	[pantherAuthCode] [varchar](100) NULL,
 CONSTRAINT [PK_account] PRIMARY KEY CLUSTERED 
(
	[accountID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[accountContact]    Script Date: 01/11/2023 18:59:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[accountContact](
	[accountContactID] [int] IDENTITY(5000,1) NOT NULL,
	[accountContactGUID] [char](36) NOT NULL,
	[accountID] [int] NOT NULL,
	[accountContactPrimary] [bit] NOT NULL,
	[accountContactTechnical] [bit] NOT NULL,
	[accountContactBilling] [bit] NOT NULL,
	[accountContactOther] [bit] NOT NULL,
	[firstName] [varchar](50) NOT NULL,
	[lastName] [varchar](50) NOT NULL,
	[email] [varchar](100) NOT NULL,
	[phone1] [varchar](50) NOT NULL,
	[phone2] [varchar](50) NULL,
	[phone1isMobile] [bit] NOT NULL,
	[phone2isMobile] [bit] NOT NULL,
	[address1] [varchar](50) NOT NULL,
	[address2] [varchar](50) NULL,
	[city] [varchar](25) NOT NULL,
	[state] [varchar](20) NOT NULL,
	[zip] [varchar](15) NOT NULL,
	[country] [varchar](25) NOT NULL,
	[active] [bit] NOT NULL,
	[created] [datetime] NOT NULL,
	[lastUpdated] [datetime] NOT NULL,
 CONSTRAINT [PK_accountContact] PRIMARY KEY CLUSTERED 
(
	[accountContactID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[accountProperty]    Script Date: 01/11/2023 18:59:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[accountProperty](
	[accountPropertyID] [int] IDENTITY(1,1) NOT NULL,
	[accountID] [int] NOT NULL,
	[accountGUID] [char](36) NOT NULL,
	[name] [char](50) NOT NULL,
	[value] [char](50) NOT NULL,
	[created] [datetime] NOT NULL,
 CONSTRAINT [PK_accountProperty] PRIMARY KEY CLUSTERED 
(
	[accountPropertyID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[accountRegistration]    Script Date: 01/11/2023 18:59:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[accountRegistration](
	[accountRegistrationID] [int] IDENTITY(1,1) NOT NULL,
	[accountName] [varchar](100) NOT NULL,
	[address1] [varchar](50) NOT NULL,
	[address2] [varchar](50) NULL,
	[city] [varchar](25) NOT NULL,
	[state] [varchar](20) NOT NULL,
	[zip] [varchar](15) NOT NULL,
	[country] [varchar](25) NOT NULL,
	[website] [varchar](100) NULL,
	[firstName] [varchar](50) NOT NULL,
	[lastName] [varchar](50) NOT NULL,
	[email] [varchar](100) NOT NULL,
	[phone] [varchar](45) NOT NULL,
	[phoneIsMobile] [bit] NOT NULL,
	[userName] [varchar](50) NOT NULL,
	[userPassword] [varchar](50) NOT NULL,
	[termsVersion] [smallint] NOT NULL,
	[verificationKey] [char](32) NOT NULL,
	[created] [datetime] NOT NULL,
	[verified] [datetime] NULL,
	[approved] [datetime] NULL,
	[provisioned] [datetime] NULL,
	[lastUpdated] [datetime] NOT NULL,
	[serviceProviderAccountName] [varchar](50) NULL,
	[serviceProviderFirstName] [varchar](50) NULL,
	[serviceProviderLastName] [varchar](50) NULL,
	[serviceProviderEmail] [varchar](100) NULL,
	[serviceProviderPhone] [varchar](50) NULL,
 CONSTRAINT [PK_accountRegistration] PRIMARY KEY CLUSTERED 
(
	[accountRegistrationID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[accountUser]    Script Date: 01/11/2023 18:59:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[accountUser](
	[accountUserID] [int] IDENTITY(5000,1) NOT NULL,
	[accountUserGUID] [char](36) NOT NULL,
	[accountID] [int] NOT NULL,
	[userName] [varchar](50) NOT NULL,
	[userPassword] [varchar](50) NOT NULL,
	[passwordDigest] [varchar](255) NULL,
	[firstName] [varchar](50) NOT NULL,
	[lastName] [varchar](50) NOT NULL,
	[email] [varchar](100) NOT NULL,
	[phone1] [varchar](50) NOT NULL,
	[phone2] [varchar](50) NULL,
	[phone1isMobile] [bit] NOT NULL,
	[phone2isMobile] [bit] NOT NULL,
	[timezone] [tinyint] NULL,
	[timezoneName] [varchar](50) NULL,
	[daylightSavingTime] [bit] NULL,
	[active] [bit] NOT NULL,
	[created] [datetime] NOT NULL,
	[lastUpdated] [datetime] NOT NULL,
 CONSTRAINT [PK_accountUser] PRIMARY KEY CLUSTERED 
(
	[accountUserID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[accountUserAction]    Script Date: 01/11/2023 18:59:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[accountUserAction](
	[accountUserActionID] [int] IDENTITY(500000,1) NOT NULL,
	[accountUserActionGUID] [char](36) NOT NULL,
	[accountUserID] [int] NOT NULL,
	[action] [varchar](50) NOT NULL,
	[created] [datetime] NULL,
	[lastUpdated] [datetime] NOT NULL,
 CONSTRAINT [PK_accountUserAction] PRIMARY KEY CLUSTERED 
(
	[accountUserActionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[api]    Script Date: 01/11/2023 18:59:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[api](
	[apiID] [int] IDENTITY(1,1) NOT NULL,
	[apiGUID] [char](36) NOT NULL,
	[name] [varchar](50) NOT NULL,
	[description] [varchar](255) NULL,
	[baseURI] [varchar](255) NULL,
	[baseURIDisplay] [varchar](255) NULL,
	[active] [bit] NOT NULL,
	[created] [datetime] NOT NULL,
	[lastUpdated] [datetime] NOT NULL,
 CONSTRAINT [PK_api] PRIMARY KEY CLUSTERED 
(
	[apiID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[apiResource]    Script Date: 01/11/2023 18:59:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[apiResource](
	[apiResourceID] [int] IDENTITY(1,1) NOT NULL,
	[apiResourceGUID] [char](36) NOT NULL,
	[apiID] [int] NOT NULL,
	[name] [varchar](50) NOT NULL,
	[description] [varchar](255) NULL,
	[requestMethodPost] [bit] NOT NULL,
	[requestMethodGet] [bit] NOT NULL,
	[requestMethodPut] [bit] NOT NULL,
	[requestMethodDelete] [bit] NOT NULL,
	[responseMethodJSON] [bit] NOT NULL,
	[responseMethodXML] [bit] NOT NULL,
	[active] [bit] NOT NULL,
	[created] [datetime] NOT NULL,
	[lastUpdated] [datetime] NOT NULL,
 CONSTRAINT [PK_apiResource] PRIMARY KEY CLUSTERED 
(
	[apiResourceID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[apiResourceParameter]    Script Date: 01/11/2023 18:59:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[apiResourceParameter](
	[apiResourceParameterID] [int] IDENTITY(1,1) NOT NULL,
	[apiResourceParameterGUID] [char](36) NOT NULL,
	[apiResourceID] [int] NOT NULL,
	[name] [varchar](50) NOT NULL,
	[description] [varchar](1000) NULL,
	[maxLength] [int] NOT NULL,
	[isRequired] [bit] NOT NULL,
	[active] [bit] NOT NULL,
	[created] [datetime] NOT NULL,
	[lastUpdated] [datetime] NOT NULL,
 CONSTRAINT [PK_apiResourceParameter] PRIMARY KEY CLUSTERED 
(
	[apiResourceParameterID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[authClient]    Script Date: 01/11/2023 18:59:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[authClient](
	[authClientID] [int] IDENTITY(1,1) NOT NULL,
	[client_id] [varchar](50) NOT NULL,
	[client_secret] [varchar](50) NOT NULL,
	[alwaysIssueToken] [bit] NOT NULL,
	[active] [bit] NOT NULL,
	[accountUserID] [int] NULL,
	[redirect_uris] [varchar](2000) NULL,
	[created] [datetime] NOT NULL,
 CONSTRAINT [PK_authClient] PRIMARY KEY CLUSTERED 
(
	[authClientID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[authClientGrantType]    Script Date: 01/11/2023 18:59:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[authClientGrantType](
	[authClientID] [int] NOT NULL,
	[authGrantTypeID] [int] NOT NULL,
 CONSTRAINT [PK_authClientGrantType] PRIMARY KEY CLUSTERED 
(
	[authClientID] ASC,
	[authGrantTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[authClientScope]    Script Date: 01/11/2023 18:59:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[authClientScope](
	[authClientID] [int] NOT NULL,
	[authScopeID] [int] NOT NULL,
	[active] [bit] NOT NULL,
	[created] [datetime] NOT NULL,
 CONSTRAINT [PK_authClientScope] PRIMARY KEY CLUSTERED 
(
	[authClientID] ASC,
	[authScopeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[authenticationFailure]    Script Date: 01/11/2023 18:59:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[authenticationFailure](
	[authenticationFailureID] [int] IDENTITY(1,1) NOT NULL,
	[authenticationFailureGUID] [char](36) NULL,
	[authenticationTypeID] [tinyint] NULL,
	[authenticationFailureTypeID] [tinyint] NULL,
	[ipAddress] [varchar](50) NULL,
	[username] [varchar](50) NULL,
	[password] [varchar](50) NULL,
	[created] [datetime] NULL,
	[lastUpdated] [datetime] NOT NULL,
 CONSTRAINT [PK_authenticationFailure] PRIMARY KEY CLUSTERED 
(
	[authenticationFailureID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[authGrantType]    Script Date: 01/11/2023 18:59:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[authGrantType](
	[authGrantTypeID] [int] IDENTITY(1,1) NOT NULL,
	[grantTypeName] [varchar](50) NOT NULL,
 CONSTRAINT [PK_authGrantType] PRIMARY KEY CLUSTERED 
(
	[authGrantTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[authScope]    Script Date: 01/11/2023 18:59:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[authScope](
	[authScopeID] [int] IDENTITY(1,1) NOT NULL,
	[scopeName] [varchar](50) NOT NULL,
	[scopeDescription] [varchar](255) NOT NULL,
 CONSTRAINT [PK_authScope] PRIMARY KEY CLUSTERED 
(
	[authScopeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[blockCodeNumber]    Script Date: 01/11/2023 18:59:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[blockCodeNumber](
	[blockCodeNumberID] [int] IDENTITY(50000000,1) NOT NULL,
	[blockCodeNumberGUID] [char](36) NOT NULL,
	[blockCodeNumberType] [tinyint] NULL,
	[code] [varchar](15) NOT NULL,
	[number] [varchar](15) NOT NULL,
	[action] [tinyint] NOT NULL,
	[actionOrigin] [tinyint] NOT NULL,
	[note] [varchar](512) NULL,
	[created] [datetime] NOT NULL,
	[lastUpdated] [datetime] NOT NULL,
	[transactionGUID] [char](36) NULL,
 CONSTRAINT [PK_blockCodeNumber] PRIMARY KEY CLUSTERED 
(
	[blockCodeNumberID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cacheConnectionCodeAssign]    Script Date: 01/11/2023 18:59:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cacheConnectionCodeAssign](
	[cacheConnectionCodeAssignID] [bigint] IDENTITY(1,1) NOT NULL,
	[code] [varchar](15) NOT NULL,
	[connectionID] [int] NOT NULL,
	[cacheStatus] [bit] NOT NULL,
	[created] [datetime] NOT NULL,
 CONSTRAINT [PK_cacheConnectionCodeAssign] PRIMARY KEY CLUSTERED 
(
	[cacheConnectionCodeAssignID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[code]    Script Date: 01/11/2023 18:59:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[code](
	[codeID] [int] IDENTITY(50000000,1) NOT NULL,
	[codeGUID] [char](36) NOT NULL,
	[codeTypeID] [int] NOT NULL,
	[itemCode] [int] NOT NULL,
	[shared] [bit] NOT NULL,
	[code] [varchar](50) NOT NULL,
	[ton] [tinyint] NOT NULL,
	[npi] [tinyint] NOT NULL,
	[name] [varchar](100) NULL,
	[emailAddress] [varchar](75) NULL,
	[emailDomain] [varchar](50) NULL,
	[emailTemplateID] [tinyint] NULL,
	[number] [varchar](15) NULL,
	[codeRegistrationID] [int] NOT NULL,
	[espid] [varchar](10) NULL,
	[netNumberID] [int] NULL,
	[providerID] [int] NOT NULL,
	[voice] [bit] NOT NULL,
	[voiceForwardTypeID] [tinyint] NULL,
	[voiceForwardDestination] [varchar](255) NULL,
	[publishStatus] [bit] NULL,
	[publishUpdate] [tinyint] NULL,
	[notePrivate] [varchar](255) NULL,
	[replyHelp] [varchar](160) NULL,
	[replyStop] [varchar](160) NULL,
	[available] [bit] NULL,
	[surcharge] [bit] NULL,
	[active] [bit] NOT NULL,
	[deactivated] [bit] NOT NULL,
	[created] [datetime] NOT NULL,
	[lastUpdated] [datetime] NOT NULL,
	[audit] [bit] NULL,
	[campaignID] [varchar](10) NULL,
	[mnoStatus] [varchar](2000) NULL,
	[mnoIsPool] [bit] NULL,
 CONSTRAINT [PK_code] PRIMARY KEY CLUSTERED 
(
	[codeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[codeAudit]    Script Date: 01/11/2023 18:59:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[codeAudit](
	[codeAuditID] [int] IDENTITY(1,1) NOT NULL,
	[code] [varchar](15) NOT NULL,
	[espid] [varchar](10) NULL,
	[netNumberID] [int] NULL,
	[espidAudit] [varchar](10) NULL,
	[netNumberIDAudit] [int] NULL,
	[created] [datetime] NOT NULL,
 CONSTRAINT [PK_codeAudit] PRIMARY KEY CLUSTERED 
(
	[codeAuditID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[codeOverride]    Script Date: 01/11/2023 18:59:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[codeOverride](
	[codeOverrideID] [int] IDENTITY(1,1) NOT NULL,
	[codeOverrideGUID] [char](36) NOT NULL,
	[connectionID] [int] NOT NULL,
	[code] [varchar](15) NOT NULL,
	[number] [varchar](15) NOT NULL,
	[replacementCode] [varchar](15) NOT NULL,
	[action] [tinyint] NOT NULL,
	[note] [varchar](512) NULL,
	[created] [datetime] NOT NULL,
 CONSTRAINT [PK_codeOverride] PRIMARY KEY CLUSTERED 
(
	[codeOverrideID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[codeParameter]    Script Date: 01/11/2023 18:59:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[codeParameter](
	[codeParameterID] [int] IDENTITY(1,1) NOT NULL,
	[codeParameterGUID] [char](36) NOT NULL,
	[codeParameterTypeID] [smallint] NOT NULL,
	[codeID] [int] NOT NULL,
	[name] [varchar](50) NOT NULL,
	[value] [varchar](100) NOT NULL,
	[created] [datetime] NOT NULL,
	[lastUpdated] [datetime] NOT NULL,
 CONSTRAINT [PK_codeParameter] PRIMARY KEY CLUSTERED 
(
	[codeParameterID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[codePublishLog]    Script Date: 01/11/2023 18:59:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[codePublishLog](
	[codePublishLogID] [int] IDENTITY(1,1) NOT NULL,
	[filename] [varchar](150) NULL,
	[transferSuccess] [smallint] NULL,
	[count] [int] NULL,
	[created] [datetime] NULL,
	[lastUpdated] [datetime] NOT NULL,
 CONSTRAINT [PK_codePublishLog] PRIMARY KEY CLUSTERED 
(
	[codePublishLogID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[codeRegistration]    Script Date: 01/11/2023 18:59:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[codeRegistration](
	[codeRegistrationID] [int] IDENTITY(5000000,1) NOT NULL,
	[codeRegistrationGUID] [char](36) NOT NULL,
	[codeTypeID] [int] NOT NULL,
	[code] [varchar](50) NOT NULL,
	[ton] [tinyint] NULL,
	[npi] [tinyint] NULL,
	[connectionID] [int] NULL,
	[name] [varchar](100) NULL,
	[codeSourceID] [int] NULL,
	[assigneeName] [varchar](100) NULL,
	[assigneeAddress1] [varchar](50) NULL,
	[assigneeAddress2] [varchar](50) NULL,
	[assigneeCity] [varchar](50) NULL,
	[assigneeState] [varchar](50) NULL,
	[assigneeZip] [varchar](50) NULL,
	[documentURL] [varchar](255) NULL,
	[notePublic] [varchar](255) NULL,
	[notePrivate] [varchar](255) NULL,
	[status] [tinyint] NOT NULL,
	[created] [datetime] NOT NULL,
	[verified] [datetime] NULL,
	[completed] [datetime] NULL,
	[lastUpdated] [datetime] NOT NULL,
	[termsAccept] [smallint] NULL,
 CONSTRAINT [PK_codeRegistration] PRIMARY KEY CLUSTERED 
(
	[codeRegistrationID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[codeRegistryParameterTSS]    Script Date: 01/11/2023 18:59:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[codeRegistryParameterTSS](
	[codeRegistryParameterTSSID] [int] IDENTITY(1,1) NOT NULL,
	[accountID] [int] NOT NULL,
	[tspid] [int] NOT NULL,
	[businessName] [varchar](50) NOT NULL,
	[contactName] [varchar](50) NOT NULL,
	[contactJobTitle] [varchar](50) NOT NULL,
	[contactPhone] [varchar](15) NOT NULL,
	[contactEmail] [varchar](50) NOT NULL,
	[url] [varchar](250) NOT NULL,
	[created] [datetime] NULL,
	[lastUpdated] [datetime] NULL,
 CONSTRAINT [PK_codeRegistryParameterTSS] PRIMARY KEY CLUSTERED 
(
	[codeRegistryParameterTSSID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[codeType]    Script Date: 01/11/2023 18:59:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[codeType](
	[codeTypeID] [int] NOT NULL,
	[codeTypeCode] [int] NOT NULL,
	[name] [varchar](50) NOT NULL,
 CONSTRAINT [PK_codeType] PRIMARY KEY CLUSTERED 
(
	[codeTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[connection]    Script Date: 01/11/2023 18:59:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[connection](
	[connectionID] [int] IDENTITY(5000,1) NOT NULL,
	[connectionGUID] [char](36) NOT NULL,
	[accountID] [int] NOT NULL,
	[name] [varchar](100) NOT NULL,
	[codeDistributionMethodID] [tinyint] NOT NULL,
	[defaultCodeID] [int] NULL,
	[destinationNumberFormat] [bit] NOT NULL,
	[enforceOptOut] [bit] NOT NULL,
	[disableInNetworkRouting] [bit] NULL,
	[messageExpirationHours] [smallint] NULL,
	[segmentedMessageOption] [smallint] NOT NULL,
	[replyHelp] [varchar](160) NULL,
	[replyStop] [varchar](160) NULL,
	[registeredDeliveryDisable] [bit] NULL,
	[active] [bit] NOT NULL,
	[created] [datetime] NOT NULL,
	[lastUpdated] [datetime] NOT NULL,
	[enableInboundSC] [tinyint] NOT NULL,
	[utf16HttpStrip] [bit] NOT NULL,
	[spamFilterMO] [bit] NOT NULL,
	[spamFilterMT] [bit] NOT NULL,
	[s3Bucket] [varchar](250) NULL,
	[s3ApiKey] [varchar](50) NULL,
	[s3ApiSecret] [varchar](50) NULL,
	[s3Params] [varchar](2000) NULL,
	[spamOfflineMO] [bit] NOT NULL,
	[spamOfflineMT] [bit] NOT NULL,
	[moHttpTlvs] [bit] NOT NULL,
 CONSTRAINT [PK_connection] PRIMARY KEY CLUSTERED 
(
	[connectionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[connectionCodeAssign]    Script Date: 01/11/2023 18:59:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[connectionCodeAssign](
	[connectionID] [int] NOT NULL,
	[codeID] [int] NOT NULL,
	[default] [bit] NULL,
	[created] [datetime] NOT NULL,
	[created2] [date] NOT NULL,
	[lastUpdated] [datetime] NOT NULL,
 CONSTRAINT [PK_connectionCodeAssign] PRIMARY KEY CLUSTERED 
(
	[connectionID] ASC,
	[codeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[connectionCodeAssignHistory]    Script Date: 01/11/2023 18:59:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[connectionCodeAssignHistory](
	[connectionCodeAssignHistoryID] [int] IDENTITY(50000000,1) NOT NULL,
	[connectionID] [int] NOT NULL,
	[codeID] [int] NOT NULL,
	[action] [bit] NOT NULL,
	[created] [datetime] NOT NULL,
	[created2] [date] NOT NULL,
 CONSTRAINT [PK_connectionCodeAssignHistory] PRIMARY KEY CLUSTERED 
(
	[connectionCodeAssignHistoryID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[credential]    Script Date: 01/11/2023 18:59:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[credential](
	[credentialID] [int] IDENTITY(5000,1) NOT NULL,
	[credentialGUID] [char](36) NOT NULL,
	[connectionID] [int] NOT NULL,
	[name] [varchar](100) NULL,
	[apiKey] [char](32) NOT NULL,
	[apiSecret] [char](32) NOT NULL,
	[systemID] [char](8) NULL,
	[password] [char](8) NULL,
	[firewallRequired] [bit] NOT NULL,
	[active] [bit] NOT NULL,
	[created] [datetime] NOT NULL,
	[lastUpdated] [datetime] NOT NULL,
 CONSTRAINT [PK_credential] PRIMARY KEY CLUSTERED 
(
	[credentialID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[firewall]    Script Date: 01/11/2023 18:59:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[firewall](
	[firewallID] [int] IDENTITY(5000,1) NOT NULL,
	[firewallGUID] [char](36) NOT NULL,
	[accountID] [int] NOT NULL,
	[connectionID] [int] NOT NULL,
	[name] [varchar](50) NOT NULL,
	[ipAddress] [varchar](50) NOT NULL,
	[ipSubnet] [tinyint] NOT NULL,
	[active] [bit] NULL,
	[created] [datetime] NULL,
	[lastUpdated] [datetime] NOT NULL,
 CONSTRAINT [PK_firewall] PRIMARY KEY CLUSTERED 
(
	[firewallID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[httpCapture]    Script Date: 01/11/2023 18:59:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[httpCapture](
	[httpCaptureID] [int] IDENTITY(1,1) NOT NULL,
	[httpCaptureGUID] [char](36) NULL,
	[accountID] [int] NULL,
	[transactionGUID] [char](36) NULL,
	[remoteAddress] [varchar](15) NULL,
	[userAgent] [varchar](255) NULL,
	[requestMethod] [varchar](10) NULL,
	[queryString] [varchar](max) NULL,
	[requestBody] [varchar](max) NULL,
	[completed] [datetime] NOT NULL,
	[lastUpdated] [datetime] NOT NULL,
 CONSTRAINT [PK_httpCapture] PRIMARY KEY CLUSTERED 
(
	[httpCaptureID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[item]    Script Date: 01/11/2023 18:59:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[item](
	[itemCode] [int] NOT NULL,
	[name] [varchar](45) NULL,
	[created] [datetime] NULL,
	[lastUpdated] [datetime] NOT NULL,
 CONSTRAINT [PK_item] PRIMARY KEY CLUSTERED 
(
	[itemCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[keyword]    Script Date: 01/11/2023 18:59:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[keyword](
	[keywordID] [int] IDENTITY(5000,1) NOT NULL,
	[keywordGUID] [char](36) NOT NULL,
	[connectionID] [int] NOT NULL,
	[codeID] [int] NOT NULL,
	[keyword] [varchar](50) NOT NULL,
	[keywordReply] [varchar](160) NULL,
	[created] [datetime] NOT NULL,
	[lastUpdated] [datetime] NOT NULL,
 CONSTRAINT [PK_keyword] PRIMARY KEY CLUSTERED 
(
	[keywordID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[loadCode]    Script Date: 01/11/2023 18:59:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[loadCode](
	[code] [varchar](15) NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[loadPathfinderAnnexure]    Script Date: 01/11/2023 18:59:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[loadPathfinderAnnexure](
	[CountryCode] [varchar](50) NULL,
	[CountryName] [varchar](100) NULL,
	[SPNName] [varchar](100) NULL,
	[SPN] [char](10) NULL,
	[SPNType] [varchar](50) NULL,
	[MCC] [char](10) NULL,
	[MNC] [char](10) NULL,
	[PrimaryMCCMNC] [char](10) NULL,
	[ALTSPN] [char](10) NULL,
	[ParentSPN] [char](10) NULL,
	[NumberBlock] [char](10) NULL,
	[Onboard] [char](10) NULL,
	[Remote] [varchar](50) NULL,
	[RemoteFull] [varchar](50) NULL,
	[FixedGeo] [char](10) NULL,
	[FixedPremium] [char](10) NULL,
	[FixedNonGeo] [char](10) NULL,
	[Mobile] [char](10) NULL,
	[MobileCDMA] [char](10) NULL,
	[MobileGT] [char](10) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[maintenanceSchedule]    Script Date: 01/11/2023 18:59:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[maintenanceSchedule](
	[maintenanceScheduleID] [int] IDENTITY(1,1) NOT NULL,
	[maintenanceScheduleGUID] [char](36) NOT NULL,
	[name] [varchar](100) NOT NULL,
	[description] [varchar](max) NOT NULL,
	[start] [datetime] NOT NULL,
	[end] [datetime] NOT NULL,
	[reoccurring] [bit] NOT NULL,
	[pattern] [varchar](10) NULL,
	[active] [bit] NOT NULL,
	[created] [datetime] NOT NULL,
	[lastUpdated] [datetime] NOT NULL,
 CONSTRAINT [PK_maintenanceSchedule] PRIMARY KEY CLUSTERED 
(
	[maintenanceScheduleID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[MMSdeliver]    Script Date: 01/11/2023 18:59:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MMSdeliver](
	[MMSdeliverID] [bigint] IDENTITY(1,1) NOT NULL,
	[transactionGUID] [char](36) NULL,
	[accountID] [int] NULL,
	[connectionID] [int] NOT NULL,
	[sourceNumber] [varchar](50) NOT NULL,
	[destinationCode] [varchar](50) NOT NULL,
	[providerID] [int] NOT NULL,
	[messageText] [nvarchar](2000) NULL,
	[auditDeliver] [datetime] NOT NULL,
	[redeliver] [bit] NOT NULL,
	[subject] [varchar](50) NULL,
	[blocked] [bit] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[MMSdeliverResult]    Script Date: 01/11/2023 18:59:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MMSdeliverResult](
	[MMSdeliverResultID] [bigint] IDENTITY(1,1) NOT NULL,
	[transactionGUID] [char](36) NULL,
	[result] [smallint] NOT NULL,
	[statusCode] [varchar](50) NULL,
	[info] [varchar](500) NULL,
	[auditResult] [datetime] NULL,
	[auditRecordResult] [datetime] NULL,
	[redeliver] [bit] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[MMSsubmit]    Script Date: 01/11/2023 18:59:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MMSsubmit](
	[MMSsubmitID] [bigint] IDENTITY(1,1) NOT NULL,
	[transactionGUID] [char](36) NULL,
	[accountID] [int] NULL,
	[connectionID] [int] NOT NULL,
	[sourceCode] [varchar](50) NOT NULL,
	[destinationNumber] [varchar](50) NOT NULL,
	[providerID] [int] NOT NULL,
	[remoteIPAddress] [varchar](50) NOT NULL,
	[registeredDelivery] [smallint] NOT NULL,
	[blocked] [bit] NOT NULL,
	[messageText] [nvarchar](2000) NULL,
	[subject] [varchar](50) NULL,
	[auditSubmit] [datetime] NOT NULL,
	[redeliver] [bit] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[MMSsubmitResult]    Script Date: 01/11/2023 18:59:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MMSsubmitResult](
	[MMSsubmitResultID] [bigint] IDENTITY(1,1) NOT NULL,
	[transactionGUID] [char](36) NULL,
	[result] [smallint] NOT NULL,
	[providerTransactionID] [varchar](50) NULL,
	[providerStatusID] [varchar](50) NULL,
	[auditResult] [datetime] NULL,
	[auditRecordResult] [datetime] NULL,
	[redeliver] [bit] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[number]    Script Date: 01/11/2023 18:59:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[number](
	[numberID] [int] IDENTITY(500000000,1) NOT NULL,
	[numberGUID] [char](36) NOT NULL,
	[number] [varchar](50) NOT NULL,
	[countryCode] [int] NOT NULL,
	[numberOperatorID] [int] NOT NULL,
	[wireless] [bit] NOT NULL,
	[created] [datetime] NOT NULL,
	[lastUpdated] [datetime] NOT NULL,
 CONSTRAINT [PK_number] PRIMARY KEY CLUSTERED 
(
	[numberID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[numberAreaPrefix]    Script Date: 01/11/2023 18:59:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[numberAreaPrefix](
	[npa] [int] NOT NULL,
	[nxx] [int] NOT NULL,
	[stateCodeAlpha2] [char](2) NULL,
	[rateCenter] [varchar](50) NULL,
	[utcOffset] [smallint] NULL,
	[daylightSavings] [char](1) NULL,
 CONSTRAINT [PK_numberAreaPrefix] PRIMARY KEY CLUSTERED 
(
	[npa] ASC,
	[nxx] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[numberCountry]    Script Date: 01/11/2023 18:59:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[numberCountry](
	[countryCode] [int] NOT NULL,
	[countryName] [varchar](255) NULL,
	[countryCodeAlpha2] [char](2) NOT NULL,
	[zoneCode] [int] NULL,
	[gmtOffsetStart] [smallint] NULL,
	[gmtOffsetEnd] [smallint] NULL,
 CONSTRAINT [PK_numberCountry] PRIMARY KEY CLUSTERED 
(
	[countryCode] ASC,
	[countryCodeAlpha2] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[numberCountryNPAExtended]    Script Date: 01/11/2023 18:59:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[numberCountryNPAExtended](
	[countryCode] [int] NOT NULL,
	[countryName] [varchar](150) NOT NULL,
	[countryCodeNormalized] [varchar](4) NULL,
 CONSTRAINT [PK_numberCountryNPAExtended] PRIMARY KEY CLUSTERED 
(
	[countryCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[numberCountryNPAOverride]    Script Date: 01/11/2023 18:59:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[numberCountryNPAOverride](
	[numberCountryNPAOverrideID] [int] IDENTITY(1,1) NOT NULL,
	[numberCountryNPAOverrideGUID] [char](36) NOT NULL,
	[connectionID] [int] NOT NULL,
	[codeID] [int] NOT NULL,
	[countryCodeNormalized] [varchar](5) NOT NULL,
	[created] [datetime] NOT NULL,
	[lastUpdated] [datetime] NOT NULL,
 CONSTRAINT [PK_numberCountryNPAOverride] PRIMARY KEY CLUSTERED 
(
	[numberCountryNPAOverrideID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[numberCountrySurcharge]    Script Date: 01/11/2023 18:59:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[numberCountrySurcharge](
	[countryCode] [int] NULL,
	[countryName] [varchar](50) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[numberOperator]    Script Date: 01/11/2023 18:59:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[numberOperator](
	[numberOperatorID] [int] IDENTITY(1,1) NOT NULL,
	[numberOperatorGUID] [char](36) NOT NULL,
	[providerSPN] [varchar](50) NOT NULL,
	[providerAltSPN] [varchar](50) NULL,
	[providerParentSPN] [varchar](50) NULL,
	[primaryMCCMNC] [char](1) NULL,
	[operatorParent] [smallint] NULL,
	[operatorName] [varchar](100) NOT NULL,
	[operatorType] [varchar](50) NOT NULL,
	[countryCode] [int] NOT NULL,
	[mcc] [char](3) NULL,
	[mnc] [char](3) NULL,
	[wireless] [char](1) NULL,
	[created] [datetime] NOT NULL,
	[lastUpdated] [datetime] NOT NULL,
 CONSTRAINT [PK_numberOperator] PRIMARY KEY CLUSTERED 
(
	[numberOperatorID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[numberOperatorNetNumber]    Script Date: 01/11/2023 18:59:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[numberOperatorNetNumber](
	[numberOperatorID] [int] NOT NULL,
	[numberOperatorIDPublic]  AS (concat((38),[numberOperatorID])),
	[numberOperatorGUID] [char](36) NOT NULL,
	[serviceProvider] [varchar](255) NULL,
	[serviceProviderPublic]  AS (replace(replace([serviceProvider],'Syniverse',''),'Sybase365','')),
	[networkProvider] [varchar](255) NULL,
	[operatorType] [varchar](25) NULL,
	[mcc] [varchar](255) NULL,
	[mnc] [varchar](255) NULL,
	[countryCode] [int] NULL,
	[countryAbbreviation] [varchar](5) NULL,
	[countryName] [varchar](100) NULL,
	[created] [datetime] NOT NULL,
	[lastUpdated] [datetime] NOT NULL,
 CONSTRAINT [PK_numberOperatorNetNumber] PRIMARY KEY CLUSTERED 
(
	[numberOperatorID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[numberOperatorSyniverse]    Script Date: 01/11/2023 18:59:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[numberOperatorSyniverse](
	[numberOperatorID] [int] NOT NULL,
	[numberOperatorIDPublic]  AS (concat((38),[numberOperatorID])),
	[numberOperatorGUID] [char](36) NOT NULL,
	[numberOperatorParentID] [int] NULL,
	[serviceProvider] [varchar](255) NULL,
	[serviceProviderPublic]  AS (replace(replace(replace(replace(replace(replace(replace([serviceProvider],'Syniverse',''),'Sybase365',''),'360 NETWORKS',''),'BANDWIDTH.COM',''),'BANDWIDTH',''),'SAP',''),'LAB','')),
	[operatorType] [varchar](25) NULL,
	[mcc] [varchar](255) NULL,
	[mnc] [varchar](255) NULL,
	[countryName] [varchar](100) NULL,
	[created] [datetime] NOT NULL,
	[lastUpdated] [datetime] NOT NULL,
 CONSTRAINT [PK_numberOperatorSyniverse] PRIMARY KEY CLUSTERED 
(
	[numberOperatorID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[numberState]    Script Date: 01/11/2023 18:59:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[numberState](
	[stateCodeAlpha2] [char](10) NOT NULL,
	[stateName] [varchar](50) NOT NULL,
	[countryCodeAlpha3] [varchar](50) NOT NULL,
 CONSTRAINT [PK_numberState] PRIMARY KEY CLUSTERED 
(
	[stateCodeAlpha2] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[numberZone]    Script Date: 01/11/2023 18:59:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[numberZone](
	[numberZoneCode] [int] NOT NULL,
	[name] [varchar](50) NULL,
 CONSTRAINT [PK_numberZone] PRIMARY KEY CLUSTERED 
(
	[numberZoneCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[provider]    Script Date: 01/11/2023 18:59:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[provider](
	[providerID] [int] NOT NULL,
	[providerGUID] [char](36) NOT NULL,
	[providerCode] [int] NOT NULL,
	[providerTypeCode] [varchar](25) NULL,
	[name] [varchar](50) NOT NULL,
	[description] [varchar](50) NULL,
	[displayName] [varchar](50) NULL,
	[active] [bit] NULL,
	[created] [datetime] NOT NULL,
	[lastUpdated] [datetime] NOT NULL,
 CONSTRAINT [PK_provider] PRIMARY KEY CLUSTERED 
(
	[providerID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[route]    Script Date: 01/11/2023 18:59:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[route](
	[routeID] [int] IDENTITY(5000,1) NOT NULL,
	[routeGUID] [char](36) NOT NULL,
	[accountID] [int] NOT NULL,
	[connectionID] [int] NULL,
	[acceptDeny] [smallint] NOT NULL,
	[sourceCodeCompare] [varchar](50) NULL,
	[destinationCodeCompare] [varchar](50) NULL,
	[messageDataCompare] [varchar](max) NULL,
	[numberOperatorID] [int] NOT NULL,
	[validityDateStart] [datetime] NOT NULL,
	[validityDateEnd] [datetime] NULL,
	[validityTimeStart] [time](7) NOT NULL,
	[validityTimeEnd] [time](7) NOT NULL,
	[routeSequence] [int] NOT NULL,
	[created] [datetime] NOT NULL,
	[lastUpdated] [datetime] NOT NULL,
 CONSTRAINT [PK_route] PRIMARY KEY CLUSTERED 
(
	[routeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[routeAction]    Script Date: 01/11/2023 18:59:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[routeAction](
	[routeActionID] [int] IDENTITY(50000,1) NOT NULL,
	[routeActionGUID] [char](36) NOT NULL,
	[routeID] [int] NOT NULL,
	[routeActionTypeID] [int] NOT NULL,
	[routeActionValue] [int] NOT NULL,
	[active] [bit] NULL,
	[created] [datetime] NOT NULL,
	[lastUpdated] [datetime] NOT NULL,
	[routeActionSequence] [smallint] NOT NULL,
 CONSTRAINT [PK_routeAction] PRIMARY KEY CLUSTERED 
(
	[routeActionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[routeActionType]    Script Date: 01/11/2023 18:59:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[routeActionType](
	[routeActionTypeID] [int] IDENTITY(1,1) NOT NULL,
	[routeActionTypeGUID] [char](36) NOT NULL,
	[name] [varchar](50) NOT NULL,
	[created] [datetime] NOT NULL,
	[lastUpdated] [datetime] NOT NULL,
 CONSTRAINT [PK_routeActionType] PRIMARY KEY CLUSTERED 
(
	[routeActionTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[routeConnection]    Script Date: 01/11/2023 18:59:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[routeConnection](
	[routeConnectionID] [int] IDENTITY(500000,1) NOT NULL,
	[routeConnectionGUID] [char](36) NOT NULL,
	[accountID] [int] NOT NULL,
	[name] [varchar](50) NOT NULL,
	[protocol] [varchar](50) NULL,
	[method] [varchar](50) NULL,
	[host] [varchar](100) NULL,
	[port] [int] NULL,
	[path] [varchar](100) NULL,
	[queryString] [varchar](255) NULL,
	[userName] [varchar](50) NULL,
	[password] [varchar](50) NULL,
	[created] [datetime] NOT NULL,
	[lastUpdated] [datetime] NOT NULL,
	[active] [bit] NULL,
 CONSTRAINT [PK_routeConnection] PRIMARY KEY CLUSTERED 
(
	[routeConnectionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[schema_migrations]    Script Date: 01/11/2023 18:59:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[schema_migrations](
	[version] [varchar](255) NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[SMSdeliver]    Script Date: 01/11/2023 18:59:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SMSdeliver](
	[SMSdeliverID] [bigint] IDENTITY(1,1) NOT NULL,
	[transactionGUID] [char](36) NULL,
	[accountID] [int] NULL,
	[connectionID] [int] NOT NULL,
	[sourceNumber] [varchar](50) NOT NULL,
	[destinationCode] [varchar](50) NOT NULL,
	[dcs] [tinyint] NULL,
	[esmClass] [int] NULL,
	[providerID] [int] NOT NULL,
	[messageText] [nvarchar](2000) NULL,
	[messageData] [varbinary](4000) NULL,
	[auditDeliver] [datetime] NOT NULL,
	[espid] [varchar](10) NULL,
	[redeliver] [bit] NOT NULL,
 CONSTRAINT [PK_SMSdeliver] PRIMARY KEY CLUSTERED 
(
	[SMSdeliverID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[SMSdeliverResult]    Script Date: 01/11/2023 18:59:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SMSdeliverResult](
	[SMSdeliverResultID] [bigint] IDENTITY(1,1) NOT NULL,
	[transactionGUID] [char](36) NULL,
	[result] [smallint] NOT NULL,
	[statusCode] [varchar](50) NULL,
	[info] [varchar](500) NULL,
	[auditResult] [datetime] NULL,
	[auditRecordResult] [datetime] NULL,
	[redeliver] [bit] NOT NULL,
 CONSTRAINT [PK_SMSdeliverResult] PRIMARY KEY CLUSTERED 
(
	[SMSdeliverResultID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[SMSMTresult]    Script Date: 01/11/2023 18:59:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SMSMTresult](
	[SMSMTresultID] [bigint] IDENTITY(1,1) NOT NULL,
	[transactionGUID] [char](36) NULL,
	[result] [smallint] NOT NULL,
	[providerTransactionID] [varchar](50) NULL,
	[providerStatusID] [varchar](50) NULL,
	[auditResult] [datetime] NULL,
	[auditRecordResult] [datetime] NULL,
	[redeliver] [bit] NOT NULL,
 CONSTRAINT [PK_SMSMTresult] PRIMARY KEY CLUSTERED 
(
	[SMSMTresultID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[SMSMTsubmit]    Script Date: 01/11/2023 18:59:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SMSMTsubmit](
	[SMSMTsubmitID] [bigint] IDENTITY(1,1) NOT NULL,
	[transactionGUID] [char](36) NULL,
	[accountID] [int] NULL,
	[connectionID] [int] NOT NULL,
	[mode] [smallint] NULL,
	[sourceCode] [varchar](50) NOT NULL,
	[destinationNumber] [varchar](50) NOT NULL,
	[dcs] [tinyint] NULL,
	[esmClass] [int] NULL,
	[providerID] [int] NOT NULL,
	[remoteIPAddress] [varchar](50) NOT NULL,
	[registeredDelivery] [smallint] NOT NULL,
	[blocked] [bit] NOT NULL,
	[messageText] [nvarchar](2000) NULL,
	[messageData] [varbinary](4000) NULL,
	[segmentGroupGUID] [char](36) NULL,
	[systemID] [char](8) NULL,
	[auditSubmit] [datetime] NOT NULL,
	[redeliver] [bit] NOT NULL,
 CONSTRAINT [PK_SMSMTsubmit] PRIMARY KEY CLUSTERED 
(
	[SMSMTsubmitID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[sysdiagrams]    Script Date: 01/11/2023 18:59:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[sysdiagrams](
	[name] [nvarchar](160) NOT NULL,
	[principal_id] [int] NOT NULL,
	[diagram_id] [int] NOT NULL,
	[version] [int] NULL,
	[definition] [varbinary](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[timezone]    Script Date: 01/11/2023 18:59:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[timezone](
	[timezoneID] [tinyint] IDENTITY(1,1) NOT NULL,
	[timezoneLocation] [varchar](30) NOT NULL,
	[gmtDescription] [varchar](11) NOT NULL,
	[gmtOffset] [smallint] NOT NULL,
 CONSTRAINT [PK_timezone] PRIMARY KEY CLUSTERED 
(
	[timezoneID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[txnCodeAudit]    Script Date: 01/11/2023 18:59:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[txnCodeAudit](
	[auditDate] [datetime] NOT NULL,
	[accountID] [int] NULL,
	[connectionID] [int] NULL,
	[codeID] [int] NOT NULL,
	[code] [varchar](50) NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[txnMMSDeliver]    Script Date: 01/11/2023 18:59:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[txnMMSDeliver](
	[txnMMSDeliverID] [bigint] IDENTITY(1,1) NOT NULL,
	[txnMMSDeliverGUID] [char](36) NULL,
	[accountID] [int] NULL,
	[connectionID] [int] NOT NULL,
	[providerID] [int] NOT NULL,
	[mode] [smallint] NULL,
	[sourceNumber] [varchar](50) NOT NULL,
	[sourceNumberCountryCode] [varchar](50) NULL,
	[sourceNumberNPA] [varchar](50) NOT NULL,
	[sourceNumberNXX] [varchar](50) NOT NULL,
	[sourceNumberOperatorID] [int] NOT NULL,
	[sourceNumberTon] [smallint] NULL,
	[sourceNumberNPI] [smallint] NULL,
	[destinationCode] [varchar](50) NOT NULL,
	[destinationCountryCode] [varchar](50) NULL,
	[destinationCodeNPA] [varchar](50) NOT NULL,
	[destinationCodeNXX] [varchar](50) NOT NULL,
	[destinationCodeOperatorID] [int] NOT NULL,
	[destinationCodeTon] [smallint] NULL,
	[destinationCodeNPI] [smallint] NULL,
	[messageKeywordMatch] [varchar](50) NULL,
	[providerName] [varchar](50) NULL,
	[forwardURLHTTP] [varchar](500) NULL,
	[forwardStatusCodeHTTP] [int] NULL,
	[forwardRetryCount] [int] NOT NULL,
	[lastForwardRetry] [datetime] NULL,
	[picked] [bit] NOT NULL,
	[scheduledDelivery] [datetime] NULL,
	[surcharge] [bit] NOT NULL,
	[created] [datetime] NOT NULL,
	[processed] [datetime] NULL,
	[completed] [datetime] NULL,
	[lastUpdated] [datetime] NOT NULL,
	[messageText] [nvarchar](4000) NULL,
	[messageData] [varbinary](8000) NULL,
	[messagePDU] [nvarchar](4000) NULL,
	[attachments] [varchar](max) NULL,
	[mmsSubject] [varchar](150) NULL,
	[dlr] [bit] NULL,
 CONSTRAINT [PK_txnMMSDeliver] PRIMARY KEY CLUSTERED 
(
	[txnMMSDeliverID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[txnMMSSubmit]    Script Date: 01/11/2023 18:59:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[txnMMSSubmit](
	[txnMMSSubmitID] [bigint] IDENTITY(1,1) NOT NULL,
	[txnMMSSubmitGUID] [char](36) NULL,
	[txnMMSDeliverID] [int] NULL,
	[accountID] [int] NULL,
	[connectionID] [int] NOT NULL,
	[providerID] [int] NOT NULL,
	[mode] [smallint] NULL,
	[sourceCode] [varchar](50) NOT NULL,
	[sourceCodeCountryCode] [varchar](50) NULL,
	[sourceCodeNPA] [varchar](50) NOT NULL,
	[sourceCodeNXX] [varchar](50) NOT NULL,
	[sourceCodeOperatorID] [int] NOT NULL,
	[sourceCodeTon] [smallint] NOT NULL,
	[sourceCodeNPI] [smallint] NOT NULL,
	[destinationNumber] [varchar](50) NOT NULL,
	[destinationNumberCountryCode] [varchar](50) NULL,
	[destinationNumberNPA] [varchar](50) NOT NULL,
	[destinationNumberNXX] [varchar](50) NOT NULL,
	[destinationNumberOperatorID] [int] NOT NULL,
	[destinationNumberTon] [smallint] NULL,
	[destinationNumberNPI] [smallint] NULL,
	[providerName] [varchar](50) NULL,
	[providerTransactionID] [varchar](50) NULL,
	[providerStatusID] [varchar](50) NULL,
	[remoteIPAddress] [varchar](50) NOT NULL,
	[registeredDelivery] [smallint] NOT NULL,
	[validityPeriod] [char](17) NULL,
	[blocked] [bit] NOT NULL,
	[scheduledDelivery] [datetime] NULL,
	[created] [datetime] NOT NULL,
	[processed] [datetime] NULL,
	[completed] [datetime] NULL,
	[lastUpdated] [datetime] NOT NULL,
	[messageText] [nvarchar](2000) NULL,
	[messageData] [varbinary](4000) NULL,
	[messagePDU] [nvarchar](4000) NULL,
	[mmsURL] [varchar](500) NULL,
	[mmsSubject] [varchar](150) NULL,
	[secure] [bit] NULL,
 CONSTRAINT [PK_txnMMSSubmit] PRIMARY KEY CLUSTERED 
(
	[txnMMSSubmitID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[txnNumber]    Script Date: 01/11/2023 18:59:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[txnNumber](
	[txnNumberID] [bigint] IDENTITY(1,1) NOT NULL,
	[txnNumberGUID] [char](36) NULL,
	[accountID] [int] NULL,
	[connectionID] [int] NOT NULL,
	[providerID] [int] NOT NULL,
	[providerName] [varchar](50) NULL,
	[mode] [smallint] NULL,
	[destinationNumber] [varchar](50) NOT NULL,
	[destinationNumberCountryCode] [varchar](50) NOT NULL,
	[destinationNumberNPA] [varchar](50) NOT NULL,
	[destinationNumberNXX] [varchar](50) NOT NULL,
	[destinationNumberOperatorID] [int] NOT NULL,
	[spn] [varchar](50) NULL,
	[mcc] [varchar](500) NULL,
	[mnc] [varchar](500) NULL,
	[wireless] [bit] NULL,
	[cache] [bit] NOT NULL,
	[created] [datetime] NOT NULL,
	[processed] [datetime] NULL,
	[completed] [datetime] NULL,
	[lastUpdated] [datetime] NOT NULL,
	[deactivationCarrierID] [int] NULL,
	[deactivationCarrierName] [varchar](150) NULL,
	[deactivationDate] [datetime] NULL,
 CONSTRAINT [PK_txnNumber] PRIMARY KEY CLUSTERED 
(
	[txnNumberID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[txnSurcharge]    Script Date: 01/11/2023 18:59:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[txnSurcharge](
	[logged] [varchar](50) NULL,
	[accountIDPublic] [int] NULL,
	[accountName] [varchar](100) NULL,
	[operatorID] [varchar](50) NULL,
	[operatorName] [varchar](50) NULL,
	[mtCount] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[txnVoiceOrig]    Script Date: 01/11/2023 18:59:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[txnVoiceOrig](
	[txnVoiceID] [bigint] IDENTITY(1,1) NOT NULL,
	[txnVoiceGUID] [char](36) NULL,
	[accountID] [int] NOT NULL,
	[connectionID] [int] NOT NULL,
	[providerID] [int] NULL,
	[sipServer] [varchar](50) NOT NULL,
	[cdrGUID] [varchar](36) NOT NULL,
	[sourceNumber] [varchar](15) NOT NULL,
	[sourceNumberCountryCode] [varchar](4) NULL,
	[sourceNumberNPA] [varchar](3) NULL,
	[sourceNumberNXX] [varchar](3) NULL,
	[sourceIPAddress] [varchar](20) NULL,
	[destinationCode] [varchar](15) NOT NULL,
	[destinationCountryCode] [varchar](4) NULL,
	[destinationCodeNPA] [varchar](3) NULL,
	[destinationCodeNXX] [varchar](3) NULL,
	[providerName] [varchar](50) NULL,
	[created] [datetime] NOT NULL,
	[completed] [datetime] NULL,
	[duration] [int] NULL,
	[terminationCauseID] [int] NULL,
	[terminationCauseMessage] [varchar](250) NULL,
	[forwardType] [varchar](15) NULL,
	[lastUpdated] [datetime] NOT NULL,
	[archived] [bit] NULL,
	[minutes]  AS (ceiling(([duration]*(1.0))/(60.0))),
 CONSTRAINT [PK_txnVoiceOrig] PRIMARY KEY CLUSTERED 
(
	[txnVoiceID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[txnVoiceTerm]    Script Date: 01/11/2023 18:59:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[txnVoiceTerm](
	[txnVoiceID] [bigint] IDENTITY(1,1) NOT NULL,
	[txnVoiceGUID] [char](36) NULL,
	[accountID] [int] NOT NULL,
	[connectionID] [int] NOT NULL,
	[providerID] [int] NULL,
	[sipServer] [varchar](50) NOT NULL,
	[cdrGUID] [varchar](36) NOT NULL,
	[sourceCode] [varchar](15) NOT NULL,
	[sourceCountryCode] [varchar](4) NULL,
	[sourceCodeNPA] [varchar](3) NULL,
	[sourceCodeNXX] [varchar](3) NULL,
	[sourceIPAddress] [varchar](20) NULL,
	[destinationIPAddress] [varchar](20) NULL,
	[destinationNumber] [varchar](15) NOT NULL,
	[destinationCountryCode] [varchar](4) NULL,
	[destinationNumberNPA] [varchar](3) NULL,
	[destinationNumberNXX] [varchar](3) NULL,
	[providerName] [varchar](50) NULL,
	[created] [datetime] NOT NULL,
	[completed] [datetime] NULL,
	[duration] [int] NULL,
	[terminationCauseID] [int] NULL,
	[terminationCauseMessage] [varchar](250) NULL,
	[forwardType] [varchar](15) NULL,
	[lastUpdated] [datetime] NOT NULL,
	[archived] [bit] NULL,
	[minutes]  AS (ceiling(([duration]*(1.0))/(60.0))),
 CONSTRAINT [PK_txnVoiceTerm] PRIMARY KEY CLUSTERED 
(
	[txnVoiceID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[xDialogueComm_Codes]    Script Date: 01/11/2023 18:59:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[xDialogueComm_Codes](
	[code] [varchar](50) NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[xnpa-nxx-can-ctr-full]    Script Date: 01/11/2023 18:59:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[xnpa-nxx-can-ctr-full](
	[Area Code] [varchar](50) NULL,
	[Prefix] [varchar](50) NULL,
	[Province] [varchar](50) NULL,
	[RateCenter] [varchar](50) NULL,
	[Time Zone] [varchar](50) NULL,
	[DST] [varchar](50) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[xnpa-nxx-ctr-full]    Script Date: 01/11/2023 18:59:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[xnpa-nxx-ctr-full](
	[Area Code] [varchar](50) NULL,
	[Prefix] [varchar](50) NULL,
	[State] [varchar](50) NULL,
	[RateCenter] [varchar](50) NULL,
	[Time Zone] [varchar](50) NULL,
	[DST] [varchar](50) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[xnumberAreaPrefix]    Script Date: 01/11/2023 18:59:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[xnumberAreaPrefix](
	[npa] [int] NOT NULL,
	[nxx] [int] NOT NULL,
	[stateCodeAlpha2] [char](2) NULL,
	[rateCenter] [varchar](50) NULL,
	[utcOffset] [smallint] NULL,
	[daylightSavings] [char](1) NULL,
 CONSTRAINT [PK_xnumberAreaPrefix] PRIMARY KEY CLUSTERED 
(
	[npa] ASC,
	[nxx] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[xTempBulkAction]    Script Date: 01/11/2023 18:59:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[xTempBulkAction](
	[code] [varchar](15) NOT NULL,
	[codeRegistrationID] [int] NULL,
	[connectionID] [int] NULL,
 CONSTRAINT [PK_xTempBulkAction] PRIMARY KEY CLUSTERED 
(
	[code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Index [IDX_accountUser_accountUserID_active]    Script Date: 01/11/2023 18:59:47 ******/
CREATE NONCLUSTERED INDEX [IDX_accountUser_accountUserID_active] ON [dbo].[accountUser]
(
	[accountUserID] ASC,
	[active] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IDX_blockCodeNumber_action]    Script Date: 01/11/2023 18:59:47 ******/
CREATE NONCLUSTERED INDEX [IDX_blockCodeNumber_action] ON [dbo].[blockCodeNumber]
(
	[action] ASC
)
INCLUDE([blockCodeNumberID],[code],[number]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IDX_blockCodeNumber_blockCodeNumberType]    Script Date: 01/11/2023 18:59:47 ******/
CREATE NONCLUSTERED INDEX [IDX_blockCodeNumber_blockCodeNumberType] ON [dbo].[blockCodeNumber]
(
	[blockCodeNumberType] ASC
)
INCLUDE([code]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IDX_blockCodeNumber_code_number]    Script Date: 01/11/2023 18:59:47 ******/
CREATE NONCLUSTERED INDEX [IDX_blockCodeNumber_code_number] ON [dbo].[blockCodeNumber]
(
	[code] ASC,
	[number] ASC
)
INCLUDE([action]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IDX_code_active]    Script Date: 01/11/2023 18:59:47 ******/
CREATE NONCLUSTERED INDEX [IDX_code_active] ON [dbo].[code]
(
	[active] ASC
)
INCLUDE([codeID],[shared],[code],[providerID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IDX_code_active_code]    Script Date: 01/11/2023 18:59:47 ******/
CREATE NONCLUSTERED INDEX [IDX_code_active_code] ON [dbo].[code]
(
	[active] ASC,
	[code] ASC
)
INCLUDE([codeID],[ton],[npi]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IDX_code_active_emailAddress]    Script Date: 01/11/2023 18:59:47 ******/
CREATE NONCLUSTERED INDEX [IDX_code_active_emailAddress] ON [dbo].[code]
(
	[active] ASC,
	[emailAddress] ASC
)
INCLUDE([codeID],[code],[emailTemplateID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IDX_code_available]    Script Date: 01/11/2023 18:59:47 ******/
CREATE NONCLUSTERED INDEX [IDX_code_available] ON [dbo].[code]
(
	[available] ASC
)
INCLUDE([code]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IDX_code_code]    Script Date: 01/11/2023 18:59:47 ******/
CREATE NONCLUSTERED INDEX [IDX_code_code] ON [dbo].[code]
(
	[code] ASC
)
INCLUDE([codeID],[providerID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IDX_code_code_active_available]    Script Date: 01/11/2023 18:59:47 ******/
CREATE NONCLUSTERED INDEX [IDX_code_code_active_available] ON [dbo].[code]
(
	[code] ASC,
	[active] ASC,
	[available] ASC
)
INCLUDE([codeID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IDX_code_codeGUID]    Script Date: 01/11/2023 18:59:47 ******/
CREATE NONCLUSTERED INDEX [IDX_code_codeGUID] ON [dbo].[code]
(
	[codeGUID] ASC
)
INCLUDE([codeID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IDX_code_codeID_active]    Script Date: 01/11/2023 18:59:47 ******/
CREATE NONCLUSTERED INDEX [IDX_code_codeID_active] ON [dbo].[code]
(
	[codeID] ASC,
	[active] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IDX_code_providerID]    Script Date: 01/11/2023 18:59:47 ******/
CREATE NONCLUSTERED INDEX [IDX_code_providerID] ON [dbo].[code]
(
	[providerID] ASC
)
INCLUDE([code]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IDX_code_publishStatus_espid]    Script Date: 01/11/2023 18:59:47 ******/
CREATE NONCLUSTERED INDEX [IDX_code_publishStatus_espid] ON [dbo].[code]
(
	[publishStatus] ASC,
	[espid] ASC
)
INCLUDE([codeID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IDX_code_publishUpdate]    Script Date: 01/11/2023 18:59:47 ******/
CREATE NONCLUSTERED INDEX [IDX_code_publishUpdate] ON [dbo].[code]
(
	[publishUpdate] ASC
)
INCLUDE([codeID],[code],[espid],[publishStatus]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IDX_code_voice_active_voiceForwardTypeID_voiceForwardDestination]    Script Date: 01/11/2023 18:59:47 ******/
CREATE NONCLUSTERED INDEX [IDX_code_voice_active_voiceForwardTypeID_voiceForwardDestination] ON [dbo].[code]
(
	[voice] ASC,
	[active] ASC,
	[voiceForwardTypeID] ASC,
	[voiceForwardDestination] ASC
)
INCLUDE([codeID],[code],[codeRegistrationID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IDX_codeOverride_action]    Script Date: 01/11/2023 18:59:47 ******/
CREATE NONCLUSTERED INDEX [IDX_codeOverride_action] ON [dbo].[codeOverride]
(
	[action] ASC
)
INCLUDE([codeOverrideID],[code],[replacementCode]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IDX_codeOverride_code_replacementCode]    Script Date: 01/11/2023 18:59:47 ******/
CREATE NONCLUSTERED INDEX [IDX_codeOverride_code_replacementCode] ON [dbo].[codeOverride]
(
	[code] ASC,
	[replacementCode] ASC
)
INCLUDE([action]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IDX_connection_defaultCodeID]    Script Date: 01/11/2023 18:59:47 ******/
CREATE NONCLUSTERED INDEX [IDX_connection_defaultCodeID] ON [dbo].[connection]
(
	[defaultCodeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IDX_connectionCodeAssign_codeID]    Script Date: 01/11/2023 18:59:47 ******/
CREATE NONCLUSTERED INDEX [IDX_connectionCodeAssign_codeID] ON [dbo].[connectionCodeAssign]
(
	[codeID] ASC
)
INCLUDE([connectionID],[default]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IDX_connectionCodeAssign_created]    Script Date: 01/11/2023 18:59:47 ******/
CREATE NONCLUSTERED INDEX [IDX_connectionCodeAssign_created] ON [dbo].[connectionCodeAssign]
(
	[created] ASC
)
INCLUDE([codeID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IDX_connectionCodeAssignHistory_action]    Script Date: 01/11/2023 18:59:47 ******/
CREATE NONCLUSTERED INDEX [IDX_connectionCodeAssignHistory_action] ON [dbo].[connectionCodeAssignHistory]
(
	[action] ASC
)
INCLUDE([connectionID],[codeID],[created]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IDX_connectionCodeAssignHistory_action_created]    Script Date: 01/11/2023 18:59:47 ******/
CREATE NONCLUSTERED INDEX [IDX_connectionCodeAssignHistory_action_created] ON [dbo].[connectionCodeAssignHistory]
(
	[action] ASC,
	[created] ASC
)
INCLUDE([connectionID],[codeID],[created2]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IDX_connectionCodeAssignHistory_codeID_created]    Script Date: 01/11/2023 18:59:47 ******/
CREATE NONCLUSTERED INDEX [IDX_connectionCodeAssignHistory_codeID_created] ON [dbo].[connectionCodeAssignHistory]
(
	[codeID] ASC,
	[created] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IDX_connectionCodeAssignHistory_connectionID]    Script Date: 01/11/2023 18:59:47 ******/
CREATE NONCLUSTERED INDEX [IDX_connectionCodeAssignHistory_connectionID] ON [dbo].[connectionCodeAssignHistory]
(
	[connectionID] ASC
)
INCLUDE([codeID],[created2]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IDX_connectionCodeAssignHistory_connectionID_action]    Script Date: 01/11/2023 18:59:47 ******/
CREATE NONCLUSTERED INDEX [IDX_connectionCodeAssignHistory_connectionID_action] ON [dbo].[connectionCodeAssignHistory]
(
	[connectionID] ASC,
	[action] ASC
)
INCLUDE([codeID],[created]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IDX_connectionCodeAssignHistory_connectionID_action_created]    Script Date: 01/11/2023 18:59:47 ******/
CREATE NONCLUSTERED INDEX [IDX_connectionCodeAssignHistory_connectionID_action_created] ON [dbo].[connectionCodeAssignHistory]
(
	[connectionID] ASC,
	[action] ASC,
	[created] ASC
)
INCLUDE([codeID],[created2]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IDX_connectionCodeAssignHistory_connectionID_created]    Script Date: 01/11/2023 18:59:47 ******/
CREATE NONCLUSTERED INDEX [IDX_connectionCodeAssignHistory_connectionID_created] ON [dbo].[connectionCodeAssignHistory]
(
	[connectionID] ASC,
	[created] ASC
)
INCLUDE([codeID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IDX_connectionCodeAssignHistory_created]    Script Date: 01/11/2023 18:59:47 ******/
CREATE NONCLUSTERED INDEX [IDX_connectionCodeAssignHistory_created] ON [dbo].[connectionCodeAssignHistory]
(
	[created] ASC
)
INCLUDE([connectionID],[codeID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IDX_firewall_firewallID_accountID_connectionID_active]    Script Date: 01/11/2023 18:59:47 ******/
CREATE NONCLUSTERED INDEX [IDX_firewall_firewallID_accountID_connectionID_active] ON [dbo].[firewall]
(
	[firewallID] ASC,
	[accountID] ASC,
	[connectionID] ASC,
	[active] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IDX_firewall_ipAddress]    Script Date: 01/11/2023 18:59:47 ******/
CREATE NONCLUSTERED INDEX [IDX_firewall_ipAddress] ON [dbo].[firewall]
(
	[ipAddress] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [AK_MMSdeliver_transactionGUID]    Script Date: 01/11/2023 18:59:47 ******/
CREATE UNIQUE NONCLUSTERED INDEX [AK_MMSdeliver_transactionGUID] ON [dbo].[MMSdeliver]
(
	[transactionGUID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IDX_MMSdeliver_accountID]    Script Date: 01/11/2023 18:59:47 ******/
CREATE NONCLUSTERED INDEX [IDX_MMSdeliver_accountID] ON [dbo].[MMSdeliver]
(
	[accountID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IDX_MMSdeliver_auditDeliver]    Script Date: 01/11/2023 18:59:47 ******/
CREATE NONCLUSTERED INDEX [IDX_MMSdeliver_auditDeliver] ON [dbo].[MMSdeliver]
(
	[auditDeliver] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IDX_MMSdeliver_connectionID_auditDeliver]    Script Date: 01/11/2023 18:59:47 ******/
CREATE NONCLUSTERED INDEX [IDX_MMSdeliver_connectionID_auditDeliver] ON [dbo].[MMSdeliver]
(
	[connectionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IDX_MMSdeliver_destinationCode]    Script Date: 01/11/2023 18:59:47 ******/
CREATE NONCLUSTERED INDEX [IDX_MMSdeliver_destinationCode] ON [dbo].[MMSdeliver]
(
	[destinationCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IDX_MMSdeliver_sourceNumber]    Script Date: 01/11/2023 18:59:47 ******/
CREATE NONCLUSTERED INDEX [IDX_MMSdeliver_sourceNumber] ON [dbo].[MMSdeliver]
(
	[sourceNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [AK_MMSdeliverResult_transactionGUID]    Script Date: 01/11/2023 18:59:47 ******/
CREATE UNIQUE NONCLUSTERED INDEX [AK_MMSdeliverResult_transactionGUID] ON [dbo].[MMSdeliverResult]
(
	[transactionGUID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IDX_MMSdeliver_auditRecordResult]    Script Date: 01/11/2023 18:59:47 ******/
CREATE NONCLUSTERED INDEX [IDX_MMSdeliver_auditRecordResult] ON [dbo].[MMSdeliverResult]
(
	[auditRecordResult] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IDX_MMSdeliver_auditResult]    Script Date: 01/11/2023 18:59:47 ******/
CREATE NONCLUSTERED INDEX [IDX_MMSdeliver_auditResult] ON [dbo].[MMSdeliverResult]
(
	[auditResult] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [AK_MMSsubmit_transactionGUID]    Script Date: 01/11/2023 18:59:47 ******/
CREATE UNIQUE NONCLUSTERED INDEX [AK_MMSsubmit_transactionGUID] ON [dbo].[MMSsubmit]
(
	[transactionGUID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IDX_MMSsubmit_accountID]    Script Date: 01/11/2023 18:59:47 ******/
CREATE NONCLUSTERED INDEX [IDX_MMSsubmit_accountID] ON [dbo].[MMSsubmit]
(
	[accountID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IDX_MMSsubmit_accountID_auditSubmit]    Script Date: 01/11/2023 18:59:47 ******/
CREATE NONCLUSTERED INDEX [IDX_MMSsubmit_accountID_auditSubmit] ON [dbo].[MMSsubmit]
(
	[accountID] ASC,
	[auditSubmit] ASC
)
INCLUDE([sourceCode],[destinationNumber],[providerID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IDX_MMSsubmit_auditSubmit]    Script Date: 01/11/2023 18:59:47 ******/
CREATE NONCLUSTERED INDEX [IDX_MMSsubmit_auditSubmit] ON [dbo].[MMSsubmit]
(
	[auditSubmit] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IDX_MMSsubmit_connectionID_auditSubmit]    Script Date: 01/11/2023 18:59:47 ******/
CREATE NONCLUSTERED INDEX [IDX_MMSsubmit_connectionID_auditSubmit] ON [dbo].[MMSsubmit]
(
	[connectionID] ASC,
	[auditSubmit] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IDX_MMSsubmit_destinationNumber]    Script Date: 01/11/2023 18:59:47 ******/
CREATE NONCLUSTERED INDEX [IDX_MMSsubmit_destinationNumber] ON [dbo].[MMSsubmit]
(
	[destinationNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IDX_MMSsubmit_sourceCode]    Script Date: 01/11/2023 18:59:47 ******/
CREATE NONCLUSTERED INDEX [IDX_MMSsubmit_sourceCode] ON [dbo].[MMSsubmit]
(
	[sourceCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IDX_MMMSsubmitResult_auditResult]    Script Date: 01/11/2023 18:59:47 ******/
CREATE NONCLUSTERED INDEX [IDX_MMMSsubmitResult_auditResult] ON [dbo].[MMSsubmitResult]
(
	[auditResult] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IDX_MMSsubmitResult_auditRecordResult]    Script Date: 01/11/2023 18:59:47 ******/
CREATE NONCLUSTERED INDEX [IDX_MMSsubmitResult_auditRecordResult] ON [dbo].[MMSsubmitResult]
(
	[auditRecordResult] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IDX_MMSsubmitResult_providerTransactionID]    Script Date: 01/11/2023 18:59:47 ******/
CREATE NONCLUSTERED INDEX [IDX_MMSsubmitResult_providerTransactionID] ON [dbo].[MMSsubmitResult]
(
	[providerTransactionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IDX_MMSsubmitResult_transactionGUID]    Script Date: 01/11/2023 18:59:47 ******/
CREATE NONCLUSTERED INDEX [IDX_MMSsubmitResult_transactionGUID] ON [dbo].[MMSsubmitResult]
(
	[transactionGUID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IDX_number_number]    Script Date: 01/11/2023 18:59:47 ******/
CREATE NONCLUSTERED INDEX [IDX_number_number] ON [dbo].[number]
(
	[number] ASC
)
INCLUDE([numberID],[countryCode],[numberOperatorID],[numberGUID],[wireless],[created],[lastUpdated]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IDX_number_number_lastUpdated_numberOperatorID]    Script Date: 01/11/2023 18:59:47 ******/
CREATE NONCLUSTERED INDEX [IDX_number_number_lastUpdated_numberOperatorID] ON [dbo].[number]
(
	[number] ASC,
	[lastUpdated] ASC,
	[numberOperatorID] ASC
)
INCLUDE([numberID],[numberGUID],[countryCode],[wireless],[created]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IDX_number_numberOperatorID]    Script Date: 01/11/2023 18:59:47 ******/
CREATE NONCLUSTERED INDEX [IDX_number_numberOperatorID] ON [dbo].[number]
(
	[numberOperatorID] ASC
)
INCLUDE([numberID],[numberGUID],[countryCode],[wireless]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IDX_numberAreaPrefix_stateCodeAlpha2]    Script Date: 01/11/2023 18:59:47 ******/
CREATE NONCLUSTERED INDEX [IDX_numberAreaPrefix_stateCodeAlpha2] ON [dbo].[numberAreaPrefix]
(
	[stateCodeAlpha2] ASC
)
INCLUDE([npa]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IDX_route_routeID_routeSequence]    Script Date: 01/11/2023 18:59:47 ******/
CREATE NONCLUSTERED INDEX [IDX_route_routeID_routeSequence] ON [dbo].[route]
(
	[routeID] ASC,
	[routeSequence] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IDX_route_routeSequence]    Script Date: 01/11/2023 18:59:47 ******/
CREATE NONCLUSTERED INDEX [IDX_route_routeSequence] ON [dbo].[route]
(
	[routeSequence] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IDX_routeAction_active]    Script Date: 01/11/2023 18:59:47 ******/
CREATE NONCLUSTERED INDEX [IDX_routeAction_active] ON [dbo].[routeAction]
(
	[active] ASC
)
INCLUDE([routeActionID],[routeID],[routeActionTypeID],[routeActionValue],[routeActionSequence]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IDX_routeAction_routeID]    Script Date: 01/11/2023 18:59:47 ******/
CREATE NONCLUSTERED INDEX [IDX_routeAction_routeID] ON [dbo].[routeAction]
(
	[routeID] ASC
)
INCLUDE([routeActionID],[routeActionGUID],[routeActionTypeID],[routeActionValue],[active]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [AK_SMSdeliver_transactionGUID]    Script Date: 01/11/2023 18:59:47 ******/
CREATE UNIQUE NONCLUSTERED INDEX [AK_SMSdeliver_transactionGUID] ON [dbo].[SMSdeliver]
(
	[transactionGUID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IDX_SMSdeliver_accountID]    Script Date: 01/11/2023 18:59:47 ******/
CREATE NONCLUSTERED INDEX [IDX_SMSdeliver_accountID] ON [dbo].[SMSdeliver]
(
	[accountID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IDX_SMSdeliver_auditDeliver]    Script Date: 01/11/2023 18:59:47 ******/
CREATE NONCLUSTERED INDEX [IDX_SMSdeliver_auditDeliver] ON [dbo].[SMSdeliver]
(
	[auditDeliver] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IDX_SMSdeliver_connectionID_auditDeliver]    Script Date: 01/11/2023 18:59:47 ******/
CREATE NONCLUSTERED INDEX [IDX_SMSdeliver_connectionID_auditDeliver] ON [dbo].[SMSdeliver]
(
	[connectionID] ASC,
	[auditDeliver] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IDX_SMSdeliver_destinationCode]    Script Date: 01/11/2023 18:59:47 ******/
CREATE NONCLUSTERED INDEX [IDX_SMSdeliver_destinationCode] ON [dbo].[SMSdeliver]
(
	[destinationCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IDX_SMSdeliver_SMSdeliverID]    Script Date: 01/11/2023 18:59:47 ******/
CREATE NONCLUSTERED INDEX [IDX_SMSdeliver_SMSdeliverID] ON [dbo].[SMSdeliver]
(
	[SMSdeliverID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IDX_SMSdeliver_sourceNumber]    Script Date: 01/11/2023 18:59:47 ******/
CREATE NONCLUSTERED INDEX [IDX_SMSdeliver_sourceNumber] ON [dbo].[SMSdeliver]
(
	[sourceNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IDX_SMSdeliverResult_transactionGUID_result]    Script Date: 01/11/2023 18:59:47 ******/
CREATE NONCLUSTERED INDEX [IDX_SMSdeliverResult_transactionGUID_result] ON [dbo].[SMSdeliverResult]
(
	[transactionGUID] ASC,
	[result] ASC
)
INCLUDE([auditResult],[auditRecordResult]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IDX_SMSMTresult_auditRecordResult]    Script Date: 01/11/2023 18:59:47 ******/
CREATE NONCLUSTERED INDEX [IDX_SMSMTresult_auditRecordResult] ON [dbo].[SMSMTresult]
(
	[auditRecordResult] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IDX_SMSMTresult_auditResult]    Script Date: 01/11/2023 18:59:47 ******/
CREATE NONCLUSTERED INDEX [IDX_SMSMTresult_auditResult] ON [dbo].[SMSMTresult]
(
	[auditResult] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IDX_SMSMTresult_providerTransactionID]    Script Date: 01/11/2023 18:59:47 ******/
CREATE NONCLUSTERED INDEX [IDX_SMSMTresult_providerTransactionID] ON [dbo].[SMSMTresult]
(
	[providerTransactionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IDX_SMSMTresult_result]    Script Date: 01/11/2023 18:59:47 ******/
CREATE NONCLUSTERED INDEX [IDX_SMSMTresult_result] ON [dbo].[SMSMTresult]
(
	[result] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IDX_SMSMTresult_result_2]    Script Date: 01/11/2023 18:59:47 ******/
CREATE NONCLUSTERED INDEX [IDX_SMSMTresult_result_2] ON [dbo].[SMSMTresult]
(
	[result] ASC
)
INCLUDE([transactionGUID],[auditResult]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IDX_SMSMTresult_SMSMTresultID]    Script Date: 01/11/2023 18:59:47 ******/
CREATE NONCLUSTERED INDEX [IDX_SMSMTresult_SMSMTresultID] ON [dbo].[SMSMTresult]
(
	[SMSMTresultID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IDX_SMSMTresult_transactionGUID]    Script Date: 01/11/2023 18:59:47 ******/
CREATE NONCLUSTERED INDEX [IDX_SMSMTresult_transactionGUID] ON [dbo].[SMSMTresult]
(
	[transactionGUID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [AK_SMSMTsubmit_transactionGUID]    Script Date: 01/11/2023 18:59:47 ******/
CREATE UNIQUE NONCLUSTERED INDEX [AK_SMSMTsubmit_transactionGUID] ON [dbo].[SMSMTsubmit]
(
	[transactionGUID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IDX_SMSMTsubmit_accountID]    Script Date: 01/11/2023 18:59:47 ******/
CREATE NONCLUSTERED INDEX [IDX_SMSMTsubmit_accountID] ON [dbo].[SMSMTsubmit]
(
	[accountID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IDX_SMSMTsubmit_accountID_auditSubmit]    Script Date: 01/11/2023 18:59:47 ******/
CREATE NONCLUSTERED INDEX [IDX_SMSMTsubmit_accountID_auditSubmit] ON [dbo].[SMSMTsubmit]
(
	[accountID] ASC,
	[auditSubmit] ASC
)
INCLUDE([sourceCode],[destinationNumber],[providerID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IDX_SMSMTsubmit_auditSubmit]    Script Date: 01/11/2023 18:59:47 ******/
CREATE NONCLUSTERED INDEX [IDX_SMSMTsubmit_auditSubmit] ON [dbo].[SMSMTsubmit]
(
	[auditSubmit] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IDX_SMSMTsubmit_auditSubmit_remoteIPAddress]    Script Date: 01/11/2023 18:59:47 ******/
CREATE NONCLUSTERED INDEX [IDX_SMSMTsubmit_auditSubmit_remoteIPAddress] ON [dbo].[SMSMTsubmit]
(
	[auditSubmit] ASC,
	[remoteIPAddress] ASC
)
INCLUDE([messageText]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IDX_SMSMTsubmit_connectionID_auditSubmit]    Script Date: 01/11/2023 18:59:47 ******/
CREATE NONCLUSTERED INDEX [IDX_SMSMTsubmit_connectionID_auditSubmit] ON [dbo].[SMSMTsubmit]
(
	[connectionID] ASC,
	[auditSubmit] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IDX_SMSMTsubmit_destinationNumber]    Script Date: 01/11/2023 18:59:47 ******/
CREATE NONCLUSTERED INDEX [IDX_SMSMTsubmit_destinationNumber] ON [dbo].[SMSMTsubmit]
(
	[destinationNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IDX_SMSMTsubmit_SMSMTsubmitID]    Script Date: 01/11/2023 18:59:47 ******/
CREATE NONCLUSTERED INDEX [IDX_SMSMTsubmit_SMSMTsubmitID] ON [dbo].[SMSMTsubmit]
(
	[SMSMTsubmitID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IDX_SMSMTsubmit_sourceCode]    Script Date: 01/11/2023 18:59:47 ******/
CREATE NONCLUSTERED INDEX [IDX_SMSMTsubmit_sourceCode] ON [dbo].[SMSMTsubmit]
(
	[sourceCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IDX_txnMMSDeliver_accountID_created]    Script Date: 01/11/2023 18:59:47 ******/
CREATE NONCLUSTERED INDEX [IDX_txnMMSDeliver_accountID_created] ON [dbo].[txnMMSDeliver]
(
	[accountID] ASC,
	[created] ASC
)
INCLUDE([providerID],[sourceNumberCountryCode],[destinationCode]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IDX_txnMMSDeliver_txnMMSDeliverGUID]    Script Date: 01/11/2023 18:59:47 ******/
CREATE NONCLUSTERED INDEX [IDX_txnMMSDeliver_txnMMSDeliverGUID] ON [dbo].[txnMMSDeliver]
(
	[txnMMSDeliverGUID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IDX_txnMMSSubmit_accountID]    Script Date: 01/11/2023 18:59:47 ******/
CREATE NONCLUSTERED INDEX [IDX_txnMMSSubmit_accountID] ON [dbo].[txnMMSSubmit]
(
	[accountID] ASC
)
INCLUDE([sourceCode],[destinationNumber]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IDX_txnMMSSubmit_accountID_created]    Script Date: 01/11/2023 18:59:47 ******/
CREATE NONCLUSTERED INDEX [IDX_txnMMSSubmit_accountID_created] ON [dbo].[txnMMSSubmit]
(
	[accountID] ASC,
	[created] ASC
)
INCLUDE([providerID],[sourceCode],[destinationNumberCountryCode]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IDX_txnMMSSubmit_txnMMSDeliverID]    Script Date: 01/11/2023 18:59:47 ******/
CREATE NONCLUSTERED INDEX [IDX_txnMMSSubmit_txnMMSDeliverID] ON [dbo].[txnMMSSubmit]
(
	[txnMMSDeliverID] ASC
)
INCLUDE([txnMMSSubmitGUID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IDX_txnMMSSubmit_txnMMSSubmitGUID]    Script Date: 01/11/2023 18:59:47 ******/
CREATE NONCLUSTERED INDEX [IDX_txnMMSSubmit_txnMMSSubmitGUID] ON [dbo].[txnMMSSubmit]
(
	[txnMMSSubmitGUID] ASC
)
INCLUDE([txnMMSSubmitID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IDX_txnNumber_accountID_created]    Script Date: 01/11/2023 18:59:47 ******/
CREATE NONCLUSTERED INDEX [IDX_txnNumber_accountID_created] ON [dbo].[txnNumber]
(
	[accountID] ASC,
	[created] ASC
)
INCLUDE([destinationNumberCountryCode]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IDX_txnNumber_txnNumberGUID_accountID]    Script Date: 01/11/2023 18:59:47 ******/
CREATE NONCLUSTERED INDEX [IDX_txnNumber_txnNumberGUID_accountID] ON [dbo].[txnNumber]
(
	[txnNumberGUID] ASC,
	[accountID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IDX_txnVoiceOrig_accountID_created]    Script Date: 01/11/2023 18:59:47 ******/
CREATE NONCLUSTERED INDEX [IDX_txnVoiceOrig_accountID_created] ON [dbo].[txnVoiceOrig]
(
	[accountID] ASC,
	[created] ASC
)
INCLUDE([destinationCode],[destinationCodeNPA],[forwardType],[minutes]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [dbo].[account] ADD  CONSTRAINT [DF_account_accountGUID]  DEFAULT (newid()) FOR [accountGUID]
GO
ALTER TABLE [dbo].[account] ADD  CONSTRAINT [DF_account_paymentMethodOptionCard]  DEFAULT ((0)) FOR [paymentMethodOptionCard]
GO
ALTER TABLE [dbo].[account] ADD  CONSTRAINT [DF_account_paymentMethodOptionEFT]  DEFAULT ((0)) FOR [paymentMethodOptionEFT]
GO
ALTER TABLE [dbo].[account] ADD  CONSTRAINT [DF_account_paymentMethodOptionCheck]  DEFAULT ((0)) FOR [paymentMethodOptionCheck]
GO
ALTER TABLE [dbo].[account] ADD  CONSTRAINT [DF_account_paymentMethodSelection]  DEFAULT ((0)) FOR [paymentMethodSelection]
GO
ALTER TABLE [dbo].[account] ADD  CONSTRAINT [DF_account_paymentCardOnFile]  DEFAULT ((0)) FOR [paymentCardOnFile]
GO
ALTER TABLE [dbo].[account] ADD  CONSTRAINT [DF_account_created]  DEFAULT (getutcdate()) FOR [created]
GO
ALTER TABLE [dbo].[account] ADD  CONSTRAINT [DF_account_lastUpdated]  DEFAULT (getutcdate()) FOR [lastUpdated]
GO
ALTER TABLE [dbo].[accountContact] ADD  CONSTRAINT [DF_accountContact_accountContactGUID]  DEFAULT (newid()) FOR [accountContactGUID]
GO
ALTER TABLE [dbo].[accountContact] ADD  CONSTRAINT [DF_accountContact_accountContactPrimary]  DEFAULT ((0)) FOR [accountContactPrimary]
GO
ALTER TABLE [dbo].[accountContact] ADD  CONSTRAINT [DF_accountContact_accountContactTechnical]  DEFAULT ((0)) FOR [accountContactTechnical]
GO
ALTER TABLE [dbo].[accountContact] ADD  CONSTRAINT [DF_accountContact_accountContactBilling]  DEFAULT ((0)) FOR [accountContactBilling]
GO
ALTER TABLE [dbo].[accountContact] ADD  CONSTRAINT [DF_accountContact_accountContactOther]  DEFAULT ((0)) FOR [accountContactOther]
GO
ALTER TABLE [dbo].[accountContact] ADD  CONSTRAINT [DF_accountContact_phone1isMobile]  DEFAULT ((0)) FOR [phone1isMobile]
GO
ALTER TABLE [dbo].[accountContact] ADD  CONSTRAINT [DF_accountContact_phone2isMobile]  DEFAULT ((0)) FOR [phone2isMobile]
GO
ALTER TABLE [dbo].[accountContact] ADD  CONSTRAINT [DF_accountContact_created]  DEFAULT (getutcdate()) FOR [created]
GO
ALTER TABLE [dbo].[accountContact] ADD  CONSTRAINT [DF_accountContact_lastUpdated]  DEFAULT (getutcdate()) FOR [lastUpdated]
GO
ALTER TABLE [dbo].[accountProperty] ADD  CONSTRAINT [DF_accountProperty_created]  DEFAULT (getutcdate()) FOR [created]
GO
ALTER TABLE [dbo].[accountRegistration] ADD  CONSTRAINT [DF_accountRegistration_created]  DEFAULT (getutcdate()) FOR [created]
GO
ALTER TABLE [dbo].[accountRegistration] ADD  CONSTRAINT [DF_accountRegistration_lastUpdated]  DEFAULT (getutcdate()) FOR [lastUpdated]
GO
ALTER TABLE [dbo].[accountUser] ADD  CONSTRAINT [DF_accountUser_accountUserGUID]  DEFAULT (newid()) FOR [accountUserGUID]
GO
ALTER TABLE [dbo].[accountUser] ADD  CONSTRAINT [DF_accountUser_phone1isMobile]  DEFAULT ((0)) FOR [phone1isMobile]
GO
ALTER TABLE [dbo].[accountUser] ADD  CONSTRAINT [DF_accountUser_phone2isMobile]  DEFAULT ((0)) FOR [phone2isMobile]
GO
ALTER TABLE [dbo].[accountUser] ADD  CONSTRAINT [DF_accountUser_created]  DEFAULT (getutcdate()) FOR [created]
GO
ALTER TABLE [dbo].[accountUser] ADD  CONSTRAINT [DF_accountUser_lastUpdated]  DEFAULT (getutcdate()) FOR [lastUpdated]
GO
ALTER TABLE [dbo].[accountUserAction] ADD  CONSTRAINT [DF_accountUserAction_accountUserActionGUID]  DEFAULT (newid()) FOR [accountUserActionGUID]
GO
ALTER TABLE [dbo].[accountUserAction] ADD  CONSTRAINT [DF_accountUserAction_created]  DEFAULT (getutcdate()) FOR [created]
GO
ALTER TABLE [dbo].[accountUserAction] ADD  CONSTRAINT [DF_accountUserAction_lastUpdated]  DEFAULT (getutcdate()) FOR [lastUpdated]
GO
ALTER TABLE [dbo].[api] ADD  CONSTRAINT [DF_api_apiGUID]  DEFAULT (newid()) FOR [apiGUID]
GO
ALTER TABLE [dbo].[api] ADD  CONSTRAINT [DF_api_created]  DEFAULT (getutcdate()) FOR [created]
GO
ALTER TABLE [dbo].[api] ADD  CONSTRAINT [DF_api_lastUpdated]  DEFAULT (getutcdate()) FOR [lastUpdated]
GO
ALTER TABLE [dbo].[apiResource] ADD  CONSTRAINT [DF_apiResource_apiResourceGUID]  DEFAULT (newid()) FOR [apiResourceGUID]
GO
ALTER TABLE [dbo].[apiResource] ADD  CONSTRAINT [DF_apiResource_created]  DEFAULT (getutcdate()) FOR [created]
GO
ALTER TABLE [dbo].[apiResource] ADD  CONSTRAINT [DF_apiResource_lastUpdated]  DEFAULT (getutcdate()) FOR [lastUpdated]
GO
ALTER TABLE [dbo].[apiResourceParameter] ADD  CONSTRAINT [DF_apiResourceParameter_apiResourceParameterGUID]  DEFAULT (newid()) FOR [apiResourceParameterGUID]
GO
ALTER TABLE [dbo].[apiResourceParameter] ADD  CONSTRAINT [DF_apiResourceParameter_created]  DEFAULT (getutcdate()) FOR [created]
GO
ALTER TABLE [dbo].[apiResourceParameter] ADD  CONSTRAINT [DF_apiResourceParameter_lastUpdated]  DEFAULT (getutcdate()) FOR [lastUpdated]
GO
ALTER TABLE [dbo].[authClient] ADD  CONSTRAINT [DF_authClient_alwaysIssueToken]  DEFAULT ((1)) FOR [alwaysIssueToken]
GO
ALTER TABLE [dbo].[authClient] ADD  CONSTRAINT [DF_authClient_active]  DEFAULT ((1)) FOR [active]
GO
ALTER TABLE [dbo].[authClient] ADD  CONSTRAINT [DF_authClient_created]  DEFAULT (getutcdate()) FOR [created]
GO
ALTER TABLE [dbo].[authClientScope] ADD  CONSTRAINT [DF_authClientScope_active]  DEFAULT ((1)) FOR [active]
GO
ALTER TABLE [dbo].[authClientScope] ADD  CONSTRAINT [DF_authClientScope_created]  DEFAULT (getutcdate()) FOR [created]
GO
ALTER TABLE [dbo].[authenticationFailure] ADD  CONSTRAINT [DF_authenticationFailure_authenticationFailureGUID]  DEFAULT (newid()) FOR [authenticationFailureGUID]
GO
ALTER TABLE [dbo].[authenticationFailure] ADD  CONSTRAINT [DF_authenticationFailure_created]  DEFAULT (getutcdate()) FOR [created]
GO
ALTER TABLE [dbo].[authenticationFailure] ADD  CONSTRAINT [DF_authenticationFailure_lastUpdated]  DEFAULT (getutcdate()) FOR [lastUpdated]
GO
ALTER TABLE [dbo].[blockCodeNumber] ADD  CONSTRAINT [DF_blockCodeNumber_blockCodeNumberGUID]  DEFAULT (newid()) FOR [blockCodeNumberGUID]
GO
ALTER TABLE [dbo].[blockCodeNumber] ADD  CONSTRAINT [DF_blockCodeNumber_created]  DEFAULT (getutcdate()) FOR [created]
GO
ALTER TABLE [dbo].[blockCodeNumber] ADD  CONSTRAINT [DF_blockCodeNumber_lastUpdated]  DEFAULT (getutcdate()) FOR [lastUpdated]
GO
ALTER TABLE [dbo].[cacheConnectionCodeAssign] ADD  CONSTRAINT [DF_cacheConnectionCodeAssign_created]  DEFAULT (getutcdate()) FOR [created]
GO
ALTER TABLE [dbo].[code] ADD  CONSTRAINT [DF_code_codeGUID]  DEFAULT (newid()) FOR [codeGUID]
GO
ALTER TABLE [dbo].[code] ADD  CONSTRAINT [DF_code_itemCode]  DEFAULT ((0)) FOR [itemCode]
GO
ALTER TABLE [dbo].[code] ADD  CONSTRAINT [DF_code_shared]  DEFAULT ((0)) FOR [shared]
GO
ALTER TABLE [dbo].[code] ADD  CONSTRAINT [DF_code_ton]  DEFAULT ((1)) FOR [ton]
GO
ALTER TABLE [dbo].[code] ADD  CONSTRAINT [DF_code_npi]  DEFAULT ((1)) FOR [npi]
GO
ALTER TABLE [dbo].[code] ADD  CONSTRAINT [DF_code_emailTemplateID]  DEFAULT ((0)) FOR [emailTemplateID]
GO
ALTER TABLE [dbo].[code] ADD  CONSTRAINT [DF_code_voice]  DEFAULT ((0)) FOR [voice]
GO
ALTER TABLE [dbo].[code] ADD  CONSTRAINT [DF_code_surcharge]  DEFAULT ((0)) FOR [surcharge]
GO
ALTER TABLE [dbo].[code] ADD  CONSTRAINT [DF_code_deactivated]  DEFAULT ((0)) FOR [deactivated]
GO
ALTER TABLE [dbo].[code] ADD  CONSTRAINT [DF_code_created]  DEFAULT (getutcdate()) FOR [created]
GO
ALTER TABLE [dbo].[code] ADD  CONSTRAINT [DF_code_lastUpdated]  DEFAULT (getutcdate()) FOR [lastUpdated]
GO
ALTER TABLE [dbo].[codeAudit] ADD  CONSTRAINT [DF_codeAudit_created]  DEFAULT (getutcdate()) FOR [created]
GO
ALTER TABLE [dbo].[codeOverride] ADD  CONSTRAINT [DF_codeOverride_codeOverrideGUID]  DEFAULT (newid()) FOR [codeOverrideGUID]
GO
ALTER TABLE [dbo].[codeOverride] ADD  CONSTRAINT [DF_codeOverride_created]  DEFAULT (getutcdate()) FOR [created]
GO
ALTER TABLE [dbo].[codeParameter] ADD  CONSTRAINT [DF_codeParameter_codeParameterGUID]  DEFAULT (newid()) FOR [codeParameterGUID]
GO
ALTER TABLE [dbo].[codeParameter] ADD  CONSTRAINT [DF_codeParameter_created]  DEFAULT (getutcdate()) FOR [created]
GO
ALTER TABLE [dbo].[codeParameter] ADD  CONSTRAINT [DF_codeParameter_lastUpdated]  DEFAULT (getutcdate()) FOR [lastUpdated]
GO
ALTER TABLE [dbo].[codePublishLog] ADD  CONSTRAINT [DF_codePublishLog_created]  DEFAULT (getutcdate()) FOR [created]
GO
ALTER TABLE [dbo].[codePublishLog] ADD  CONSTRAINT [DF_codePublishLog_lastUpdated]  DEFAULT (getutcdate()) FOR [lastUpdated]
GO
ALTER TABLE [dbo].[codeRegistration] ADD  CONSTRAINT [DF_codeRegistration_codeRegistrationGUID]  DEFAULT (newid()) FOR [codeRegistrationGUID]
GO
ALTER TABLE [dbo].[codeRegistration] ADD  CONSTRAINT [DF_codeRegistration_ton]  DEFAULT ((1)) FOR [ton]
GO
ALTER TABLE [dbo].[codeRegistration] ADD  CONSTRAINT [DF_codeRegistration_npi]  DEFAULT ((1)) FOR [npi]
GO
ALTER TABLE [dbo].[codeRegistration] ADD  CONSTRAINT [DF_codeRegistration_status]  DEFAULT ((0)) FOR [status]
GO
ALTER TABLE [dbo].[codeRegistration] ADD  CONSTRAINT [DF_codeRegistration_created]  DEFAULT (getutcdate()) FOR [created]
GO
ALTER TABLE [dbo].[codeRegistration] ADD  CONSTRAINT [DF_codeRegistration_lastUpdated]  DEFAULT (getutcdate()) FOR [lastUpdated]
GO
ALTER TABLE [dbo].[codeRegistryParameterTSS] ADD  CONSTRAINT [DF_codeRegistryParameterTSS_created]  DEFAULT (getutcdate()) FOR [created]
GO
ALTER TABLE [dbo].[codeRegistryParameterTSS] ADD  CONSTRAINT [DF_codeRegistryParameterTSS_lastUpdated]  DEFAULT (getutcdate()) FOR [lastUpdated]
GO
ALTER TABLE [dbo].[connection] ADD  CONSTRAINT [DF_connection_connectionGUID]  DEFAULT (newid()) FOR [connectionGUID]
GO
ALTER TABLE [dbo].[connection] ADD  CONSTRAINT [DF_connection_destinationNumberFormat]  DEFAULT ((0)) FOR [destinationNumberFormat]
GO
ALTER TABLE [dbo].[connection] ADD  CONSTRAINT [DF_connection_enforceOptOut]  DEFAULT ((0)) FOR [enforceOptOut]
GO
ALTER TABLE [dbo].[connection] ADD  CONSTRAINT [DF_connection_disableInNetworkRouting]  DEFAULT ((0)) FOR [disableInNetworkRouting]
GO
ALTER TABLE [dbo].[connection] ADD  CONSTRAINT [DF_connection_segmentedMessageOption]  DEFAULT ((2)) FOR [segmentedMessageOption]
GO
ALTER TABLE [dbo].[connection] ADD  CONSTRAINT [DF_connection_registeredDeliveryDisable]  DEFAULT ((0)) FOR [registeredDeliveryDisable]
GO
ALTER TABLE [dbo].[connection] ADD  CONSTRAINT [DF_connection_created]  DEFAULT (getutcdate()) FOR [created]
GO
ALTER TABLE [dbo].[connection] ADD  CONSTRAINT [DF_connection_lastUpdated]  DEFAULT (getutcdate()) FOR [lastUpdated]
GO
ALTER TABLE [dbo].[connection] ADD  CONSTRAINT [DF_connection_enableInboundSC]  DEFAULT ((0)) FOR [enableInboundSC]
GO
ALTER TABLE [dbo].[connection] ADD  CONSTRAINT [DF_connection_utf16HttpStrip]  DEFAULT ((0)) FOR [utf16HttpStrip]
GO
ALTER TABLE [dbo].[connection] ADD  CONSTRAINT [DF_connection_spamFilterMO]  DEFAULT ((0)) FOR [spamFilterMO]
GO
ALTER TABLE [dbo].[connection] ADD  CONSTRAINT [DF_connection_spamFilterMT]  DEFAULT ((0)) FOR [spamFilterMT]
GO
ALTER TABLE [dbo].[connection] ADD  CONSTRAINT [DF_connection_spamOfflineMO]  DEFAULT ((0)) FOR [spamOfflineMO]
GO
ALTER TABLE [dbo].[connection] ADD  CONSTRAINT [DF_connection_spamOfflineMT]  DEFAULT ((0)) FOR [spamOfflineMT]
GO
ALTER TABLE [dbo].[connection] ADD  CONSTRAINT [DF_connection_moHttpTlvs]  DEFAULT ((0)) FOR [moHttpTlvs]
GO
ALTER TABLE [dbo].[connectionCodeAssign] ADD  CONSTRAINT [DF_connectionCodeAssign_default]  DEFAULT ((0)) FOR [default]
GO
ALTER TABLE [dbo].[connectionCodeAssign] ADD  CONSTRAINT [DF_connectionCodeAssign_created]  DEFAULT (getutcdate()) FOR [created]
GO
ALTER TABLE [dbo].[connectionCodeAssign] ADD  CONSTRAINT [DF_connectionCodeAssign_created2]  DEFAULT (getutcdate()) FOR [created2]
GO
ALTER TABLE [dbo].[connectionCodeAssign] ADD  CONSTRAINT [DF_connectionCodeAssign_lastUpdated]  DEFAULT (getutcdate()) FOR [lastUpdated]
GO
ALTER TABLE [dbo].[connectionCodeAssignHistory] ADD  CONSTRAINT [DF_connectionCodeAssignHistory_created]  DEFAULT (getutcdate()) FOR [created]
GO
ALTER TABLE [dbo].[connectionCodeAssignHistory] ADD  CONSTRAINT [DF_connectionCodeAssignHistory_created2]  DEFAULT (getutcdate()) FOR [created2]
GO
ALTER TABLE [dbo].[credential] ADD  CONSTRAINT [DF_credential_credentialGUID]  DEFAULT (newid()) FOR [credentialGUID]
GO
ALTER TABLE [dbo].[credential] ADD  CONSTRAINT [DF_credential_firewallRequired]  DEFAULT ((1)) FOR [firewallRequired]
GO
ALTER TABLE [dbo].[credential] ADD  CONSTRAINT [DF_credential_created]  DEFAULT (getutcdate()) FOR [created]
GO
ALTER TABLE [dbo].[credential] ADD  CONSTRAINT [DF_credential_lastUpdated]  DEFAULT (getutcdate()) FOR [lastUpdated]
GO
ALTER TABLE [dbo].[firewall] ADD  CONSTRAINT [DF_firewall_firewallGUID]  DEFAULT (newid()) FOR [firewallGUID]
GO
ALTER TABLE [dbo].[firewall] ADD  CONSTRAINT [DF_firewall_created]  DEFAULT (getutcdate()) FOR [created]
GO
ALTER TABLE [dbo].[firewall] ADD  CONSTRAINT [DF_firewall_lastUpdated]  DEFAULT (getutcdate()) FOR [lastUpdated]
GO
ALTER TABLE [dbo].[httpCapture] ADD  CONSTRAINT [DF_httpCapture_httpCaptureGUID]  DEFAULT (newid()) FOR [httpCaptureGUID]
GO
ALTER TABLE [dbo].[httpCapture] ADD  CONSTRAINT [DF_httpCapture_completed]  DEFAULT (getutcdate()) FOR [completed]
GO
ALTER TABLE [dbo].[httpCapture] ADD  CONSTRAINT [DF_httpCapture_lastUpdated]  DEFAULT (getutcdate()) FOR [lastUpdated]
GO
ALTER TABLE [dbo].[item] ADD  CONSTRAINT [DF_item_created]  DEFAULT (getutcdate()) FOR [created]
GO
ALTER TABLE [dbo].[item] ADD  CONSTRAINT [DF_item_lastUpdated]  DEFAULT (getutcdate()) FOR [lastUpdated]
GO
ALTER TABLE [dbo].[keyword] ADD  CONSTRAINT [DF_keyword_keywordGUID]  DEFAULT (newid()) FOR [keywordGUID]
GO
ALTER TABLE [dbo].[keyword] ADD  CONSTRAINT [DF_keyword_created]  DEFAULT (getutcdate()) FOR [created]
GO
ALTER TABLE [dbo].[keyword] ADD  CONSTRAINT [DF_keyword_lastUpdated]  DEFAULT (getutcdate()) FOR [lastUpdated]
GO
ALTER TABLE [dbo].[maintenanceSchedule] ADD  CONSTRAINT [DF_maintenanceSchedule_maintenanceScheduleGUID]  DEFAULT (newid()) FOR [maintenanceScheduleGUID]
GO
ALTER TABLE [dbo].[maintenanceSchedule] ADD  CONSTRAINT [DF_maintenanceSchedule_created]  DEFAULT (getutcdate()) FOR [created]
GO
ALTER TABLE [dbo].[maintenanceSchedule] ADD  CONSTRAINT [DF_maintenanceSchedule_lastUpdated]  DEFAULT (getutcdate()) FOR [lastUpdated]
GO
ALTER TABLE [dbo].[number] ADD  CONSTRAINT [DF_number_numberGUID]  DEFAULT (newid()) FOR [numberGUID]
GO
ALTER TABLE [dbo].[number] ADD  CONSTRAINT [DF_number_created]  DEFAULT (getutcdate()) FOR [created]
GO
ALTER TABLE [dbo].[number] ADD  CONSTRAINT [DF_number_lastUpdated]  DEFAULT (getutcdate()) FOR [lastUpdated]
GO
ALTER TABLE [dbo].[numberCountryNPAOverride] ADD  CONSTRAINT [DF_numberCountryNPAOverride_numberCountryNPAOverrideGUID]  DEFAULT (newid()) FOR [numberCountryNPAOverrideGUID]
GO
ALTER TABLE [dbo].[numberCountryNPAOverride] ADD  CONSTRAINT [DF_numberCountryNPAOverride_created]  DEFAULT (getutcdate()) FOR [created]
GO
ALTER TABLE [dbo].[numberCountryNPAOverride] ADD  CONSTRAINT [DF_numberCountryNPAOverride_lastUpdated]  DEFAULT (getutcdate()) FOR [lastUpdated]
GO
ALTER TABLE [dbo].[numberOperator] ADD  CONSTRAINT [DF_numberOperator_numberOperatorGUID]  DEFAULT (newid()) FOR [numberOperatorGUID]
GO
ALTER TABLE [dbo].[numberOperator] ADD  CONSTRAINT [DF_numberOperator_created]  DEFAULT (getutcdate()) FOR [created]
GO
ALTER TABLE [dbo].[numberOperator] ADD  CONSTRAINT [DF_numberOperator_lastUpdated]  DEFAULT (getutcdate()) FOR [lastUpdated]
GO
ALTER TABLE [dbo].[numberOperatorNetNumber] ADD  CONSTRAINT [DF_numberOperatorNetNumber_numberOperatorGUID]  DEFAULT (newid()) FOR [numberOperatorGUID]
GO
ALTER TABLE [dbo].[numberOperatorNetNumber] ADD  CONSTRAINT [DF_numberOperatorNetNumber_created]  DEFAULT (getutcdate()) FOR [created]
GO
ALTER TABLE [dbo].[numberOperatorNetNumber] ADD  CONSTRAINT [DF_numberOperatorNetNumber_lastUpdated]  DEFAULT (getutcdate()) FOR [lastUpdated]
GO
ALTER TABLE [dbo].[numberOperatorSyniverse] ADD  CONSTRAINT [DF_numberOperatorSyniverse_numberOperatorGUID]  DEFAULT (newid()) FOR [numberOperatorGUID]
GO
ALTER TABLE [dbo].[numberOperatorSyniverse] ADD  CONSTRAINT [DF_numberOperatorSyniverse_created]  DEFAULT (getutcdate()) FOR [created]
GO
ALTER TABLE [dbo].[numberOperatorSyniverse] ADD  CONSTRAINT [DF_numberOperatorSyniverse_lastUpdated]  DEFAULT (getutcdate()) FOR [lastUpdated]
GO
ALTER TABLE [dbo].[provider] ADD  CONSTRAINT [DF_provider_providerGUID]  DEFAULT (newid()) FOR [providerGUID]
GO
ALTER TABLE [dbo].[provider] ADD  CONSTRAINT [DF_provider_active]  DEFAULT ((0)) FOR [active]
GO
ALTER TABLE [dbo].[provider] ADD  CONSTRAINT [DF_provider_created]  DEFAULT (getutcdate()) FOR [created]
GO
ALTER TABLE [dbo].[provider] ADD  CONSTRAINT [DF_provider_lastUpdated]  DEFAULT (getutcdate()) FOR [lastUpdated]
GO
ALTER TABLE [dbo].[route] ADD  CONSTRAINT [DF_route_routeGUID]  DEFAULT (newid()) FOR [routeGUID]
GO
ALTER TABLE [dbo].[route] ADD  CONSTRAINT [DF_route_created]  DEFAULT (getutcdate()) FOR [created]
GO
ALTER TABLE [dbo].[route] ADD  CONSTRAINT [DF_route_lastUpdated]  DEFAULT (getutcdate()) FOR [lastUpdated]
GO
ALTER TABLE [dbo].[routeAction] ADD  CONSTRAINT [DF_routeAction_routeActionGUID]  DEFAULT (newid()) FOR [routeActionGUID]
GO
ALTER TABLE [dbo].[routeAction] ADD  CONSTRAINT [DF_routeAction_routeActionValue]  DEFAULT ((0)) FOR [routeActionValue]
GO
ALTER TABLE [dbo].[routeAction] ADD  CONSTRAINT [DF_routeAction_created]  DEFAULT (getutcdate()) FOR [created]
GO
ALTER TABLE [dbo].[routeAction] ADD  CONSTRAINT [DF_routeAction_lastUpdated]  DEFAULT (getutcdate()) FOR [lastUpdated]
GO
ALTER TABLE [dbo].[routeAction] ADD  CONSTRAINT [DF_routeAction_routeActionSequence]  DEFAULT ((1)) FOR [routeActionSequence]
GO
ALTER TABLE [dbo].[routeActionType] ADD  CONSTRAINT [DF_routeActionType_routeActionTypeGUID]  DEFAULT (newid()) FOR [routeActionTypeGUID]
GO
ALTER TABLE [dbo].[routeActionType] ADD  CONSTRAINT [DF_routeActionType_created]  DEFAULT (getutcdate()) FOR [created]
GO
ALTER TABLE [dbo].[routeActionType] ADD  CONSTRAINT [DF_routeActionType_lastUpdated]  DEFAULT (getutcdate()) FOR [lastUpdated]
GO
ALTER TABLE [dbo].[routeConnection] ADD  CONSTRAINT [DF_routeConnection_routeConnectionGUID]  DEFAULT (newid()) FOR [routeConnectionGUID]
GO
ALTER TABLE [dbo].[routeConnection] ADD  CONSTRAINT [DF_routeConnection_created]  DEFAULT (getutcdate()) FOR [created]
GO
ALTER TABLE [dbo].[routeConnection] ADD  CONSTRAINT [DF_routeConnection_lastUpdated]  DEFAULT (getutcdate()) FOR [lastUpdated]
GO
ALTER TABLE [dbo].[routeConnection] ADD  CONSTRAINT [DF_routeConnection_active]  DEFAULT ((1)) FOR [active]
GO
ALTER TABLE [dbo].[SMSdeliver] ADD  CONSTRAINT [DK_SMSdeliver_redeliver]  DEFAULT ((0)) FOR [redeliver]
GO
ALTER TABLE [dbo].[SMSdeliverResult] ADD  CONSTRAINT [DK_SMSdeliverResult_redeliver]  DEFAULT ((0)) FOR [redeliver]
GO
ALTER TABLE [dbo].[SMSMTresult] ADD  CONSTRAINT [DK_SMSMTresult_redeliver]  DEFAULT ((0)) FOR [redeliver]
GO
ALTER TABLE [dbo].[SMSMTsubmit] ADD  CONSTRAINT [DK_SMSMTsubmit_redeliver]  DEFAULT ((0)) FOR [redeliver]
GO
ALTER TABLE [dbo].[txnMMSDeliver] ADD  CONSTRAINT [DF_txnMMSDeliver_txnMMSDeliverGUID]  DEFAULT (newid()) FOR [txnMMSDeliverGUID]
GO
ALTER TABLE [dbo].[txnMMSDeliver] ADD  CONSTRAINT [DF_txnMMSDeliver_forwardRetryCount]  DEFAULT ((0)) FOR [forwardRetryCount]
GO
ALTER TABLE [dbo].[txnMMSDeliver] ADD  CONSTRAINT [DF_txnMMSDeliver_picked]  DEFAULT ((0)) FOR [picked]
GO
ALTER TABLE [dbo].[txnMMSDeliver] ADD  CONSTRAINT [DF_txnMMSDeliver_scheduledDelivery]  DEFAULT (getutcdate()) FOR [scheduledDelivery]
GO
ALTER TABLE [dbo].[txnMMSDeliver] ADD  CONSTRAINT [DF_txnMMSDeliver_surcharge]  DEFAULT ((0)) FOR [surcharge]
GO
ALTER TABLE [dbo].[txnMMSDeliver] ADD  CONSTRAINT [DF_txnMMSDeliver_created]  DEFAULT (getutcdate()) FOR [created]
GO
ALTER TABLE [dbo].[txnMMSDeliver] ADD  CONSTRAINT [DF_txnMMSDeliver_lastUpdated]  DEFAULT (getutcdate()) FOR [lastUpdated]
GO
ALTER TABLE [dbo].[txnMMSSubmit] ADD  CONSTRAINT [DF_txnMMSSubmit_txnMMSSubmitGUID]  DEFAULT (newid()) FOR [txnMMSSubmitGUID]
GO
ALTER TABLE [dbo].[txnMMSSubmit] ADD  CONSTRAINT [DF_txnMMSSubmit_scheduledDelivery]  DEFAULT (getutcdate()) FOR [scheduledDelivery]
GO
ALTER TABLE [dbo].[txnMMSSubmit] ADD  CONSTRAINT [DF_txnMMSSubmit_created]  DEFAULT (getutcdate()) FOR [created]
GO
ALTER TABLE [dbo].[txnMMSSubmit] ADD  CONSTRAINT [DF_txnMMSSubmit_lastUpdated]  DEFAULT (getutcdate()) FOR [lastUpdated]
GO
ALTER TABLE [dbo].[txnMMSSubmit] ADD  CONSTRAINT [DF_txnMMSSubmit_secure]  DEFAULT ((0)) FOR [secure]
GO
ALTER TABLE [dbo].[txnNumber] ADD  CONSTRAINT [DF_txnNumber_txnNumberGUID]  DEFAULT (newid()) FOR [txnNumberGUID]
GO
ALTER TABLE [dbo].[txnNumber] ADD  CONSTRAINT [DF_txnNumber_created]  DEFAULT (getutcdate()) FOR [created]
GO
ALTER TABLE [dbo].[txnNumber] ADD  CONSTRAINT [DF_txnNumber_lastUpdated]  DEFAULT (getutcdate()) FOR [lastUpdated]
GO
ALTER TABLE [dbo].[txnVoiceOrig] ADD  CONSTRAINT [DF_txnVoiceOrig_txnVoiceGUID]  DEFAULT (newid()) FOR [txnVoiceGUID]
GO
ALTER TABLE [dbo].[txnVoiceOrig] ADD  CONSTRAINT [DF_txnVoiceOrig_created]  DEFAULT (getutcdate()) FOR [created]
GO
ALTER TABLE [dbo].[txnVoiceOrig] ADD  CONSTRAINT [DF_txnVoiceOrig_lastUpdated]  DEFAULT (getutcdate()) FOR [lastUpdated]
GO
ALTER TABLE [dbo].[txnVoiceTerm] ADD  CONSTRAINT [DF_txnVoiceTerm_txnVoiceGUID]  DEFAULT (newid()) FOR [txnVoiceGUID]
GO
ALTER TABLE [dbo].[txnVoiceTerm] ADD  CONSTRAINT [DF_txnVoiceTerm_created]  DEFAULT (getutcdate()) FOR [created]
GO
ALTER TABLE [dbo].[txnVoiceTerm] ADD  CONSTRAINT [DF_txnVoiceTerm_lastUpdated]  DEFAULT (getutcdate()) FOR [lastUpdated]
GO
/****** Object:  StoredProcedure [dbo].[accountDeleteByAccountID]    Script Date: 01/11/2023 18:59:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[accountDeleteByAccountID]
	@accountID INT
AS
BEGIN
	BEGIN TRY

	SET NOCOUNT ON;

	DECLARE @count INT; 

	BEGIN TRANSACTION

		SET @count = (SELECT COUNT (accountContactID) FROM accountContact WHERE accountID IN (@accountID));
		PRINT 'accountContact:' + CAST(@count AS VARCHAR(10));
		DELETE FROM accountContact WHERE accountID IN (@accountID);

		SET @count = (SELECT COUNT (accountRegistrationID) FROM accountRegistration WHERE accountRegistrationID IN ( SELECT accountRegistrationID FROM account where accountID IN (@accountID)));
		PRINT 'accountRegistration:' + CAST(@count AS VARCHAR(10));
		DELETE FROM accountRegistration WHERE accountRegistrationID IN ( SELECT accountRegistrationID FROM account where accountID IN (@accountID));

		SET @count = (SELECT COUNT (accountUserActionID) FROM accountUserAction WHERE accountUserID IN ( SELECT accountUserID FROM accountUser WHERE accountID IN (@accountID)));
		PRINT 'accountUserAction:' + CAST(@count AS VARCHAR(10));
		DELETE FROM accountUserAction WHERE accountUserID IN ( SELECT accountUserID FROM accountUser WHERE accountID IN (@accountID));

		SET @count = (SELECT COUNT(blockCodeNumberID) FROM blockCodeNumber WHERE code IN ( SELECT code FROM code WHERE codeID IN ( SELECT codeID FROM connectionCodeAssign WHERE connectionID IN (SELECT connectionID FROM connection WHERE accountID IN (@accountID)))));
		PRINT 'blockCodeNumber:' + CAST(@count AS VARCHAR(10));
		DELETE FROM blockCodeNumber WHERE code IN ( SELECT code FROM code WHERE codeID IN ( SELECT codeID FROM connectionCodeAssign WHERE connectionID IN (SELECT connectionID FROM connection WHERE accountID IN (@accountID))));

		SET @count = (SELECT COUNT (cacheConnectionCodeAssignID) FROM cacheConnectionCodeAssign WHERE connectionID IN (SELECT connectionID FROM connection WHERE accountID IN (@accountID)));
		PRINT 'cacheConnectionCodeAssign:' + CAST(@count AS VARCHAR(10));
		DELETE FROM cacheConnectionCodeAssign WHERE connectionID IN (SELECT connectionID FROM connection WHERE accountID IN (@accountID));

		SET @count = (SELECT COUNT (codeRegistrationID) FROM codeRegistration WHERE connectionID IN (SELECT connectionID FROM connection WHERE accountID IN (@accountID)));
		PRINT 'codeRegistration:' + CAST(@count AS VARCHAR(10));
		DELETE FROM codeRegistration WHERE connectionID IN (SELECT connectionID FROM connection WHERE accountID IN (@accountID));

		SET @count = (SELECT COUNT (credentialID) FROM credential WHERE connectionID IN (SELECT connectionID FROM connection WHERE accountID IN (@accountID)));
		PRINT 'credential:' + CAST(@count AS VARCHAR(10));
		DELETE FROM credential WHERE connectionID IN (SELECT connectionID FROM connection WHERE accountID IN (@accountID));

		SET @count = (SELECT COUNT (firewallID) FROM firewall WHERE accountID IN (@accountID));
		PRINT 'firewall:' + CAST(@count AS VARCHAR(10));
		DELETE FROM firewall WHERE accountID IN (@accountID);

		SET @count = (SELECT COUNT (keywordID) FROM keyword WHERE connectionID IN (SELECT connectionID FROM connection WHERE accountID IN (@accountID)));
		PRINT 'keyword:' + CAST(@count AS VARCHAR(10));
		DELETE FROM keyword WHERE connectionID IN (SELECT connectionID FROM connection WHERE accountID IN (@accountID));

		SET @count = (SELECT COUNT(routeActionID) FROM routeAction WHERE routeID IN (SELECT routeID FROM route WHERE accountID IN (@accountID)));
		PRINT 'routeAction:' + CAST(@count AS VARCHAR(10));
		DELETE FROM routeAction WHERE routeID IN (SELECT routeID FROM route WHERE accountID IN (@accountID));

		SET @count = (SELECT COUNT (routeConnectionID) FROM routeConnection WHERE accountID IN (@accountID));
		PRINT 'routeConnection:' + CAST(@count AS VARCHAR(10));
		DELETE FROM routeConnection WHERE accountID IN (@accountID);

		SET @count = (SELECT COUNT (connectionID) FROM xTempBulkAction WHERE connectionID IN (SELECT connectionID FROM connection WHERE accountID IN (@accountID)));
		PRINT 'xTempBulkAction:' + CAST(@count AS VARCHAR(10));
		DELETE FROM xTempBulkAction WHERE connectionID IN (SELECT connectionID FROM connection WHERE accountID IN (@accountID));


		SET @count = (SELECT COUNT (routeID) FROM route WHERE accountID IN (@accountID));
		PRINT 'route:' + CAST(@count AS VARCHAR(10));
		DELETE FROM route WHERE accountID IN (@accountID);

		SET @count = (SELECT COUNT (connectionID) FROM connectionCodeAssign WHERE connectionID IN (SELECT connectionID FROM connection WHERE accountID IN (@accountID)));
		PRINT 'connectionCodeAssign:' + CAST(@count AS VARCHAR(10));
		DELETE FROM connectionCodeAssign WHERE connectionID IN (SELECT connectionID FROM connection WHERE accountID IN (@accountID));

		SET @count = (SELECT COUNT (connectionID) FROM connection WHERE accountID IN (@accountID));
		PRINT 'connection:' + CAST(@count AS VARCHAR(10));
		DELETE FROM connection WHERE accountID IN (@accountID);

		SET @count = (SELECT COUNT (accountUserID) FROM accountUser WHERE accountID IN (@accountID));
		PRINT 'accountUser:' + CAST(@count AS VARCHAR(10));
		DELETE FROM accountUser WHERE accountID IN (@accountID);

		SET @count = (SELECT COUNT (@accountID) FROM account WHERE accountID IN (@accountID));
		PRINT 'account:' + CAST(@count AS VARCHAR(10));
		DELETE FROM account WHERE accountID IN (@accountID);

	COMMIT TRANSACTION

	END TRY

	BEGIN CATCH
        IF @@TRANCOUNT > 0
        	ROLLBACK TRANSACTION;
		THROW;
	END CATCH

END


GO
/****** Object:  StoredProcedure [dbo].[accountDisableByAccountID]    Script Date: 01/11/2023 18:59:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[accountDisableByAccountID]
	@accountID INT
AS
BEGIN
	BEGIN TRY

	SET NOCOUNT ON;

	BEGIN TRANSACTION

    	UPDATE account SET active = 0 WHERE accountID = @accountID;

		UPDATE connection SET active = 0 WHERE accountID = @accountID;

		UPDATE credential SET active = 0 WHERE connectionID IN (select connectionID FROM connection WHERE accountID = @accountID);

		UPDATE routeAction SET active = 0 WHERE routeID IN (select routeID FROM route WHERE connectionID IN (SELECT connectionID FROM connection WHERE accountID = @accountID));
	
		SELECT 'Account, Connections, Credentials, and Route Actions have been Disabled';

	COMMIT TRANSACTION

	END TRY

	BEGIN CATCH
        IF @@TRANCOUNT > 0
        	ROLLBACK TRANSACTION;
		THROW;
	END CATCH

END


GO
/****** Object:  StoredProcedure [dbo].[accountEnableByAccountID]    Script Date: 01/11/2023 18:59:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[accountEnableByAccountID]
	@accountID INT
AS
BEGIN
	BEGIN TRY

	SET NOCOUNT ON;

	BEGIN TRANSACTION

    UPDATE account SET active = 1 WHERE accountID = @accountID;

	UPDATE connection SET active = 1 WHERE accountID = @accountID;

	UPDATE credential SET active = 1 WHERE connectionID IN (SELECT connectionID FROM connection WHERE accountID = @accountID);

	UPDATE routeAction SET active = 1 WHERE routeID IN (SELECT routeID FROM route WHERE connectionID IN (SELECT connectionID FROM connection WHERE accountID = @accountID));
	
	SELECT 'Account, Connections, Credentials, and Route Actions have been ENABLED' ;

	COMMIT TRANSACTION

	END TRY

	BEGIN CATCH
        IF @@TRANCOUNT > 0
        	ROLLBACK TRANSACTION;
		THROW;
	END CATCH

END


GO
/****** Object:  StoredProcedure [dbo].[approveAccountRegistration]    Script Date: 01/11/2023 18:59:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[approveAccountRegistration]
	@accountRegistrationID INT
AS
BEGIN
	BEGIN TRY

	SET NOCOUNT ON;

	BEGIN TRANSACTION

		--update verified in case they did not verify
		UPDATE accountRegistration SET verified = getUTCDate() WHERE accountRegistrationID = @accountRegistrationID AND verified IS NULL;
    	UPDATE accountRegistration SET approved = getUTCDate() WHERE accountRegistrationID = @accountRegistrationID;

	COMMIT TRANSACTION

	END TRY

	BEGIN CATCH
        IF @@TRANCOUNT > 0
        	ROLLBACK TRANSACTION;
		THROW;
	END CATCH

END


GO
/****** Object:  StoredProcedure [dbo].[checkCode]    Script Date: 01/11/2023 18:59:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[checkCode]
	@code varchar(15)
WITH EXECUTE AS 'dbo' 
AS
BEGIN


	SET NOCOUNT ON;

	SELECT
	  a.created,
	  b.created AS [assigned],
	  b.accountID,
	  b.accountName,
	  b.connectionID,
	  b.connectionName,
	  a.code,
	  a.codeTypeID,
	  a.codeRegistrationID,
	  a.sms,
	  a.mms,
	  a.voice,
	  a.surcharge,
	  a.espid,
	  a.providerID,
	  p.name AS [providerName],
	  a.publishStatus,
	  a.publishUpdate,
	  a.active,
	  a.deactivated,
	  a.available,
	  a.name,
	  a.emailAddress,
	  a.emailDomain,
	  a.voiceForwardTypeID,
	  a.voiceForwardDestination,
	  a.replyHelp,
	  a.replyStop,
	  a.notePrivate,
	  a.notePublic
	FROM code a WITH (NOLOCK) LEFT JOIN (
	  SELECT 
		ac.name AS [accountName],
		f.accountID,
		codeID,
		e.connectionID,
		f.connectionGUID,
		f.name AS connectionName,
		e.created,
		ac.active
	  FROM connectionCodeAssign e WITH (NOLOCK), connection f WITH (NOLOCK), account ac WITH (NOLOCK)
	  WHERE e.connectionID = f.connectionID
	  AND	f.accountID = ac.accountID
	) b ON a.codeID = b.codeID
	LEFT JOIN provider p WITH (NOLOCK) 
		ON a.providerID = p.providerID
	WHERE a.code = @code


END





























GO
/****** Object:  StoredProcedure [dbo].[checkOperatorID]    Script Date: 01/11/2023 18:59:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[checkOperatorID]
	@operatorID	INT
AS	 
BEGIN 
	
	-- Using NOCOUNT to reduce traffic and load on the system.
	SET NOCOUNT ON 

	SELECT	numberOperatorID AS operatorID, 
			operatorName,
			CASE WHEN numberOperatorID IN (
					SELECT	numberOperatorID
					FROM	numberOperator WITH (NOLOCK)
					WHERE	operatorName LIKE '%wireless%'
					AND	NOT	operatorName LIKE '%aerialink%'
				 ) THEN 'wireless'
				 WHEN numberOperatorID IN (
					SELECT	numberOperatorID
					FROM	numberOperator WITH (NOLOCK)
					WHERE	((operatorName LIKE '%VONAGE%')
					OR		(operatorName LIKE '%SKPE%')
					OR		(operatorName LIKE '%GOOGLE%')
					OR		(operatorName LIKE '%RINGCENTRAL%')
					OR		(operatorName LIKE '%TWILIO%')
					OR		(operatorName LIKE '%BANDWIDTH%'))
					AND NOT operatorName LIKE '%wireless%'
				 ) THEN 'exception'
				 ELSE 'OK' END AS [type]
	FROM	numberOperator WITH (NOLOCK)
	WHERE	numberOperatorID = @operatorID


END 








GO
/****** Object:  StoredProcedure [dbo].[createNewConnection]    Script Date: 01/11/2023 18:59:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[createNewConnection] 
	-- Add the parameters for the stored procedure here
	@connectionName varchar(50),
	@accountID INT

AS
BEGIN
	BEGIN TRY

	SET NOCOUNT ON;

	declare @connectionID INT;
	declare @routeID INT;

	BEGIN TRANSACTION

	--#STEP 1: INSERT connection : we will always create one default connection for them
	INSERT connection (connectionTypeID,accountID,name,codeDistributionMethodID,
		requestLimitPerSecond,requestLimitPerDay,requestLimitPerMonth,
		requireList,enforceOptOut,messageExpirationHours,
		active,created,lastUpdated)
	VALUES (1,@accountID,@connectionName,0,
		1,0,0,
		0,0,24,
		1,getUTCDate(),getUTCDate());
	
	--#get newly created connectionID
	SET @connectionID = SCOPE_IDENTITY();
	
	--#STEP 2: INSERT route : create default route
	INSERT route (accountID,connectionID,acceptDeny,sourceCodeCompare,destinationCodeCompare,messageDataCompare,numberOperatorID,
				validityDateStart,validityDateEnd,validityTimeStart,validityTimeEnd,routeSequence,
				created,lastUpdated)
	VALUES (@accountID, @connectionID, 1, 0, 0, 0, 0, 
				'1900-01-01 00:00:00', '2900-01-01 00:00:00', '00:00:00', '23:59:59', 1,
				getUTCDate(), getUTCDate());
	
	--#get newly created routeID
	SET @routeID = SCOPE_IDENTITY();
	
	--#STEP 3: Provide access to SMS MT, reports and query/publish leased codes.
	INSERT routeAction (routeID,routeActionTypeID,routeActionValue, active, created,lastUpdated)
	VALUES (@routeID, 1, 0, 1, getUTCDate(), getUTCDate());
	
	INSERT routeAction (routeID,routeActionTypeID,routeActionValue, active, created,lastUpdated)
	VALUES (@routeID, 10, 0, 1, getUTCDate(), getUTCDate());
	
	INSERT routeAction (routeID,routeActionTypeID,routeActionValue, active, created,lastUpdated)
	VALUES (@routeID, 17, 0, 1, getUTCDate(), getUTCDate());
	
	INSERT routeAction (routeID,routeActionTypeID,routeActionValue, active, created,lastUpdated)
	VALUES (@routeID, 18, 0, 1, getUTCDate(), getUTCDate());
	
	INSERT routeAction (routeID,routeActionTypeID,routeActionValue, active, created,lastUpdated)
	VALUES (@routeID, 19, 0, 1, getUTCDate(), getUTCDate());
	
	SELECT 'createNewConnection Completed', @connectionID;

	COMMIT TRANSACTION

	END TRY

	BEGIN CATCH
        IF @@TRANCOUNT > 0
        	ROLLBACK TRANSACTION;
		THROW;
	END CATCH

END










GO
/****** Object:  StoredProcedure [dbo].[deProvisionConnectionCodeAssign]    Script Date: 01/11/2023 18:59:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[deProvisionConnectionCodeAssign]
	@code varchar(15), 
	@connectionID INT 
AS
BEGIN
	BEGIN TRY

	SET NOCOUNT ON;

	declare @@codeID int;
	declare @@shared int;

	BEGIN TRANSACTION

		SET @@codeID = (SELECT TOP 1 c.codeID FROM code c, connectionCodeAssign cca WHERE c.code = @code AND c.codeID = cca.codeID AND cca.connectionID = @connectionID);
		SET @@shared = (SELECT c.shared FROM code c WHERE c.codeID = @@codeID);

		PRINT @@codeID

		IF @@codeID > 0
			BEGIN
				DELETE connectionCodeAssign WHERE connectionID = @connectionID AND codeID = @@codeID;
				UPDATE code SET active=@@shared, deactivated=0, available=0 WHERE codeID = @@codeID;
				INSERT connectionCodeAssignHistory (connectionID, codeID, action, created) VALUES (@connectionID, @@codeID, 0, getutcdate());
				INSERT cacheConnectionCodeAssign (code, connectionID, cacheStatus) VALUES (@code, @connectionID, 0);
				--we are not making the code available yet as were not sure how to handle 50's which are not our numbers yet
				--i.e cannot make an LOA code available following deact as it is not ours
				SELECT 'true' AS result; --code was deleted FROM connectionCodeAssign, but NOT the code table.
			END
		ELSE
			SELECT 'false' AS result; --nothing was done, no code match

	COMMIT TRANSACTION

	END TRY

	BEGIN CATCH
        IF @@TRANCOUNT > 0
        	ROLLBACK TRANSACTION;
		THROW;
	END CATCH

END












GO
/****** Object:  StoredProcedure [dbo].[disableMMS]    Script Date: 01/11/2023 18:59:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[disableMMS]
	@code varchar(15), 
	@connectionID INT
WITH EXECUTE AS 'dbo' 
AS
BEGIN

	DECLARE @codeID INT;
	DECLARE @currentESPID VARCHAR(10);
	DECLARE @itemCode INT;
	DECLARE @inConnection INT = 0;
	DECLARE @errorMessage VARCHAR(255);

	SET NOCOUNT ON;

	BEGIN TRY

		SET @codeID = (SELECT codeID FROM code WHERE code = @code);
		SET @currentESPID = (SELECT espid FROM code WHERE codeID = @codeID);
		SET @itemCode = (SELECT itemCode FROM code WHERE codeID = @codeID);
		SET @inConnection = (SELECT COUNT(*) FROM connectionCodeAssign WHERE codeID = @codeID AND connectionID = @connectionID);

		IF (@inConnection > 0) AND (@itemCode = 101)
		BEGIN
			IF (@currentESPID IN ('E136'))
			BEGIN
				UPDATE code SET mms=0, espid='E0B4', publishUpdate=2 WHERE codeID = @codeID;
				SELECT 'Success' AS [result], @code AS [code], @connectionID AS [connectionID];
			END
			ELSE IF (@currentESPID IN ('E19B'))
			BEGIN
				UPDATE code SET mms=0 WHERE codeID = @codeID;
				SELECT 'Success' AS [result], @code AS [code], @connectionID AS [connectionID];
			END
			ELSE
				SELECT 'Failed' AS [result], @code AS [code], @connectionID AS [connectionID];
		END
		ELSE
		BEGIN
			SELECT 'Failed' AS [result], @code AS [code], @connectionID AS [connectionID];
		END

	END TRY
	BEGIN CATCH

		SET @errorMessage = (SELECT LEFT(ERROR_MESSAGE(), 255) AS ErrorMessage);
		PRINT @errorMessage;

		SELECT 'Failed', @code, @connectionID;
	END CATCH
END





























GO
/****** Object:  StoredProcedure [dbo].[dlrLookup]    Script Date: 01/11/2023 18:59:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[dlrLookup]
	@dlrTransactionGUID VARCHAR(40) = ''
AS	 
BEGIN 
	SET NOCOUNT ON 

	SELECT	mt.transactionGUID AS [mtTransactionGUID],
			dlr.txnSMSDeliverGUID AS [dlrTransactionGUID],
			CASE WHEN CONVERT(INT, SUBSTRING(mt.messageData,1,1)) = 5 THEN CONVERT(INT, SUBSTRING(mt.messageData,5,1)) ELSE NULL END AS [totalSegments],
			CASE WHEN CONVERT(INT, SUBSTRING(mt.messageData,1,1)) = 5 THEN CONVERT(INT, SUBSTRING(mt.messageData,6,1)) ELSE NULL END AS [segmentNumber],
			CASE 
				WHEN dlr.messageText IS NULL THEN 'NO DLR' 
				WHEN LTRIM(RTRIM(dlr.messageText))  = '' THEN 'EMPTY'
				WHEN (PATINDEX('%err:%',dlr.messageText))-(PATINDEX('%stat:%',dlr.messageText)+5) < 1 THEN 'INVALID'
				WHEN LEFT(dlr.messageText,3) = 'id:' THEN SUBSTRING(dlr.messageText, PATINDEX('%stat:%',dlr.messageText)+5, (PATINDEX('%err:%',dlr.messageText))-(PATINDEX('%stat:%',dlr.messageText)+5)) 
				ELSE 'INVALID'
			END AS [dlrStatus],
			CASE 
				WHEN dlr.messageText IS NULL THEN 'NO ERR' 
				WHEN LTRIM(RTRIM(dlr.messageText)) = '' THEN 'EMPTY'
				WHEN (PATINDEX('%text:%',dlr.messageText))-(PATINDEX('%err:%',dlr.messageText)+4) < 1 THEN 'INVALID'
				WHEN LEFT(dlr.messageText,3) = 'id:' THEN SUBSTRING(dlr.messageText, PATINDEX('%err:%',dlr.messageText)+4, (PATINDEX('%text:%',dlr.messageText))-(PATINDEX('%err:%',dlr.messageText)+4)) 
				ELSE 'INVALID'	
			END AS [dlrResultCode]
	FROM	SMSMTsubmit mt WITH (NOLOCK)
	INNER	JOIN (
		SELECT	TOP 1	mts.segmentGroupGUID,
						rss.auditResult AS [created]
		FROM	SMSMTsubmit mts WITH (NOLOCK),
				SMSMTresult rss WITH (NOLOCK)
		WHERE	rss.providerTransactionID = @dlrTransactionGUID
		AND		mts.transactionGUID = rss.transactionGUID
	) seg ON mt.segmentGroupGUID = seg.segmentGroupGUID
	LEFT OUTER JOIN SMSMTresult rs WITH (NOLOCK) ON (mt.transactionGUID = rs.transactionGUID AND rs.result = 2)
	LEFT OUTER JOIN txnSMSDeliver dlr WITH (NOLOCK) ON dlr.txnSMSDeliverGUID = rs.providerTransactionID
	ORDER	BY [segmentNumber]

END 






GO
/****** Object:  StoredProcedure [dbo].[dlrLookup_new]    Script Date: 01/11/2023 18:59:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[dlrLookup_new]
	@dlrTransactionGUID VARCHAR(40) = ''
AS	 
BEGIN 
	SET NOCOUNT ON 

	SELECT	mt.transactionGUID AS [mtTransactionGUID],
			dlr.transactionGUID AS [dlrTransactionGUID],
			[totalSegments] = (SELECT COUNT(*) FROM SMSMTsubmit (NOLOCK) WHERE segmentGroupGUID = mt.segmentGroupGUID),
			ROW_NUMBER() OVER(ORDER BY auditSubmit ASC) [segmentNumber],
			CASE 
				WHEN dlr.messageText IS NULL THEN 'NO DLR' 
				WHEN LTRIM(RTRIM(dlr.messageText))  = '' THEN 'EMPTY'
				WHEN (PATINDEX('%err:%',dlr.messageText))-(PATINDEX('%stat:%',dlr.messageText)+5) < 1 THEN 'INVALID'
				WHEN LEFT(dlr.messageText,3) = 'id:' THEN SUBSTRING(dlr.messageText, PATINDEX('%stat:%',dlr.messageText)+5, (PATINDEX('%err:%',dlr.messageText))-(PATINDEX('%stat:%',dlr.messageText)+5)) 
				ELSE 'INVALID'
			END AS [dlrStatus],
			CASE 
				WHEN dlr.messageText IS NULL THEN 'NO ERR' 
				WHEN LTRIM(RTRIM(dlr.messageText)) = '' THEN 'EMPTY'
				WHEN (PATINDEX('%text:%',dlr.messageText))-(PATINDEX('%err:%',dlr.messageText)+4) < 1 THEN 'INVALID'
				WHEN LEFT(dlr.messageText,3) = 'id:' THEN SUBSTRING(dlr.messageText, PATINDEX('%err:%',dlr.messageText)+4, (PATINDEX('%text:%',dlr.messageText))-(PATINDEX('%err:%',dlr.messageText)+4)) 
				ELSE 'INVALID'	
			END AS [dlrResultCode]
	FROM	SMSMTsubmit mt WITH (NOLOCK)
	LEFT OUTER JOIN SMSMTresult rs WITH (NOLOCK) ON (mt.transactionGUID = rs.transactionGUID AND rs.result = 2)
	LEFT OUTER JOIN SMSDeliver dlr WITH (NOLOCK) ON dlr.transactionGUID = rs.providerTransactionID
	WHERE	mt.segmentGroupGUID IN (
		SELECT	TOP 1	mts.segmentGroupGUID
		FROM	SMSMTsubmit mts WITH (NOLOCK),
				SMSMTresult rss WITH (NOLOCK)
		WHERE	rss.providerTransactionID = @dlrTransactionGUID
		AND		mts.transactionGUID = rss.transactionGUID
	) 
	ORDER	BY [segmentNumber]



END 





GO
/****** Object:  StoredProcedure [dbo].[enableMMS]    Script Date: 01/11/2023 18:59:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[enableMMS]
	@code varchar(15), 
	@connectionID INT
WITH EXECUTE AS 'dbo' 
AS
BEGIN

	DECLARE @codeID INT;
	DECLARE @currentESPID VARCHAR(10);
	DECLARE @itemCode INT;
	DECLARE @inConnection INT = 0;
	DECLARE @mmsConnection INT = 0;
	DECLARE @errorMessage VARCHAR(255);

	SET NOCOUNT ON;

	BEGIN TRY

		SET @codeID = (SELECT codeID FROM code WHERE code = @code);
		SET @currentESPID = (SELECT espid FROM code WHERE codeID = @codeID);
		SET @itemCode = (SELECT itemCode FROM code WHERE codeID = @codeID);
		SET @inConnection = (SELECT COUNT(*) FROM connectionCodeAssign WHERE codeID = @codeID AND connectionID = @connectionID);
		SET @mmsConnection = (SELECT COUNT(*) FROM routeAction WHERE routeActionTypeID = 10 AND routeID IN (SELECT routeID FROM [route] WHERE connectionID = @connectionID));

		PRINT 'In Connection: ' + CAST(@inConnection AS VARCHAR(5));
		PRINT 'Item Code: ' + CAST(@itemCode AS VARCHAR(5));
		PRINT 'Connection has MMS route: ' + CAST(@mmsConnection AS VARCHAR(5));

		IF (@inConnection > 0) AND (@itemCode = 101) AND (@mmsConnection > 0)
		BEGIN
			IF (@currentESPID IN ('E0B4','E0B5','E136'))
			BEGIN
				UPDATE code SET mms=1, espid='E136', publishUpdate=2 WHERE codeID = @codeID;
				SELECT 'Success' AS [result], @code AS [code], @connectionID AS [connectionID];
			END
			ELSE IF (@currentESPID IN ('E19B'))
			BEGIN
				UPDATE code SET mms=1 WHERE codeID = @codeID;
				SELECT 'Success' AS [result], @code AS [code], @connectionID AS [connectionID];
			END
			ELSE
				SELECT 'Failed' AS [result], @code AS [code], @connectionID AS [connectionID];
		END
		ELSE
		BEGIN
			SELECT 'Failed' AS [result], @code AS [code], @connectionID AS [connectionID];
		END

	END TRY
	BEGIN CATCH

		SET @errorMessage = (SELECT LEFT(ERROR_MESSAGE(), 255) AS ErrorMessage);
		PRINT @errorMessage;

		SELECT 'Failed' AS [result], @code AS [code], @connectionID AS [connectionID];
	END CATCH
END






























GO
/****** Object:  StoredProcedure [dbo].[getAccountLatency]    Script Date: 01/11/2023 18:59:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[getAccountLatency]
	@accountID INT = 1
AS	 
BEGIN 

	SET NOCOUNT ON 

	SELECT AVG(DATEDIFF(millisecond,[start],[complete])) AS latencyMS
	FROM (
		SELECT	mt.auditSubmit [start],
				[complete] = (
					SELECT	TOP 1 auditResult
					FROM	smsMTResult AS mtr with (nolock)
					WHERE	RESULT = 1
					AND		transactionGUID = mt.transactionGUID
				)
		FROM	SMSMTsubmit mt (NOLOCK)
		WHERE	mt.auditSubmit >= DATEADD(minute, -5, GETUTCDATE())
		AND		mt.accountID = @accountID
	) a


END 







GO
/****** Object:  StoredProcedure [dbo].[getAccountMDR]    Script Date: 01/11/2023 18:59:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[getAccountMDR]
	@type		VARCHAR(3),
	@accountID	INT,
	@includeConnection INT = 0
AS	 
BEGIN 

	-- Using NOCOUNT to reduce traffic and load on the system.
	SET NOCOUNT ON 

	DECLARE @activityStart	AS DATETIME;
	DECLARE @activityEnd	AS DATETIME;

	SET @activityStart	= (SELECT DATEADD(HOUR, -2, DATEADD(HOUR, DATEDIFF(HOUR, 0, GETUTCDATE()), 0)));
	SET @activityEnd	= (SELECT DATEADD(HOUR, -1, DATEADD(HOUR, DATEDIFF(HOUR, 0, GETUTCDATE()), 0)));

	IF @includeConnection = 0
	BEGIN

		IF @type = 'DLR'
		BEGIN

		  --DLR / Inbound
		  SELECT
			b.accountGUID AS [AccountGUID],
			b.name AS [AccountName],
			txnSMSDeliverGUID AS [MessageGUID],
			'DLR' AS [Type],
			sourceNumber AS [Source],
			destinationCode AS [Destination],
			[Dcs],
			[EsmClass],
			a.[Created],
			LEFT(a.[messageText],106) AS [StatusMsg]
		  FROM	txnSMSDeliver a WITH (NOLOCK), account b  WITH (NOLOCK)
		  WHERE a.created >= @activityStart AND a.created < @activityEnd
				AND(esmClass = 4 OR esmClass = 8)
				AND a.accountID in (select accountID from account where accountParentID = @accountID OR accountID = @accountID)
				AND a.accountID = b.accountID;

		END
		ELSE IF @type = 'MO'
		BEGIN

		  --MO / Inbound
		  SELECT
			b.accountGUID AS [AccountGUID],
			b.name AS [AccountName],
			txnSMSDeliverGUID AS [MessageGUID],
			'MO' AS [Type],
			sourceNumber AS [Source],
			destinationCode AS [Destination],
			[Dcs],
			[EsmClass],
			a.[Created],
			[Processed],
			[Completed]
		  FROM	txnSMSDeliver a WITH (NOLOCK), account b WITH (NOLOCK)
		  WHERE	a.created >= @activityStart AND a.created < @activityEnd
				AND esmClass != 4
				AND esmClass != 8
				AND a.accountID in (select accountID from account where accountParentID = @accountID OR accountID = @accountID)
				AND a.accountID = b.accountID;

		END
		ELSE
		BEGIN

		  --MT / Outbound
		  SELECT
			b.accountGUID AS [AccountGUID],
			b.name AS [AccountName],
			txnSMSSubmitGUID AS [MessageGUID],
			'MT' AS [Type],
			sourceCode AS [Source],
			destinationNumber AS [Destination],
			[Dcs],
			[EsmClass],
			a.[Created],
			[Processed],
			[Completed],
			[SegmentGroupGUID],
			[SegmentTotal] =
			  CASE
				WHEN [SegmentGroupGUID] IS NOT NULL THEN CONVERT(int, SUBSTRING(messageData, 5, 1))
			  ELSE NULL END,
			[SegmentNumber] =
			  CASE
				WHEN [SegmentGroupGUID] IS NOT NULL THEN CONVERT(int, SUBSTRING(messageData, 6, 1))
			  ELSE NULL END,
  			a.[providerTransactionID] AS [TransactionID]
		  FROM	txnSMSSubmit a WITH (NOLOCK), account b WITH (NOLOCK)
		  WHERE a.created >= @activityStart AND a.created < @activityEnd
				AND a.accountID in (select accountID from account where accountParentID = @accountID OR accountID = @accountID)
				AND a.accountID = b.accountID

		END
	END
	ELSE
	BEGIN

		IF @type = 'DLR'
		BEGIN

		  --DLR / Inbound
		  SELECT
			b.accountGUID AS [AccountGUID],
			b.name AS [AccountName],
			c.connectionGUID AS [ConnectionGUID],
			c.name AS [ConnectionName],
			txnSMSDeliverGUID AS [MessageGUID],
			'DLR' AS [Type],
			sourceNumber AS [Source],
			destinationCode AS [Destination],
			[Dcs],
			[EsmClass],
			a.[Created],
			LEFT(a.[messageText],106) AS [StatusMsg]
		  FROM	txnSMSDeliver a WITH (NOLOCK), account b  WITH (NOLOCK), connection c WITH (NOLOCK)
		  WHERE a.created >= @activityStart AND a.created < @activityEnd
				AND(esmClass = 4 OR esmClass = 8)
				AND a.accountID in (select accountID from account where accountParentID = @accountID OR accountID = @accountID)
				AND a.accountID = b.accountID
				AND a.connectionID = c.connectionID;

		END
		ELSE IF @type = 'MO'
		BEGIN

			--MO / INBOUND
			SELECT
				b.accountGUID AS [AccountGUID],
				b.name AS [AccountName],
				c.connectionGUID AS [ConnectionGUID],
				c.name AS [ConnectionName],
				txnMMSDeliverGUID AS [MessageGUID],
				'MO' AS [Type],
				sourceNumber AS [Source],
				destinationCode AS [Destination],
				0 AS [Dcs],
				0 AS [EsmClass],
				a.[Created],
				[Processed],
				[Completed],
				'MMS' AS [MsgType]
			FROM	txnMMSDeliver a WITH (NOLOCK), account b WITH (NOLOCK), connection c WITH (NOLOCK)
			WHERE	a.created >= @activityStart AND a.created < @activityEnd
				AND a.accountID in (select accountID from account where accountParentID = @accountID OR accountID = @accountID)
				AND a.accountID = b.accountID
				AND a.connectionID = c.connectionID
			UNION
			SELECT
				b.accountGUID AS [AccountGUID],
				b.name AS [AccountName],
				c.connectionGUID AS [ConnectionGUID],
				c.name AS [ConnectionName],
				txnSMSDeliverGUID AS [MessageGUID],
				'MO' AS [Type],
				sourceNumber AS [Source],
				destinationCode AS [Destination],
				[Dcs],
				[EsmClass],
				a.[Created],
				[Processed],
				[Completed],
				'SMS' AS [MsgType]
			FROM	txnSMSDeliver a WITH (NOLOCK), account b WITH (NOLOCK), connection c WITH (NOLOCK)
			WHERE	a.created >= @activityStart AND a.created < @activityEnd
				AND esmClass != 4
				AND esmClass != 8
				AND a.accountID in (select accountID from account where accountParentID = @accountID OR accountID = @accountID)
				AND a.accountID = b.accountID
				AND a.connectionID = c.connectionID
			ORDER BY [Created]

		END
		ELSE
		BEGIN

			--MT / Outbound
			SELECT
				b.accountGUID AS [AccountGUID],
				b.name AS [AccountName],
				c.connectionGUID AS [ConnectionGUID],
				c.name AS [ConnectionName],
				txnMMSSubmitGUID AS [MessageGUID],
				'MT' AS [Type],
				sourceCode AS [Source],
				destinationNumber AS [Destination],
				0 AS [Dcs],
				0 AS [EsmClass],
				a.[Created],
				[Processed],
				[Completed],
				NULL AS [SegmentGroupGUID],
				0 AS [SegmentTotal],
				0 AS [SegmentNumber],
				a.[providerTransactionID] AS [TransactionID],
				'MMS' AS [MsgType]
			FROM	txnMMSSubmit a WITH (NOLOCK), account b WITH (NOLOCK), connection c WITH (NOLOCK)
			WHERE a.created >= @activityStart AND a.created < @activityEnd
				AND a.accountID in (select accountID from account where accountParentID = @accountID OR accountID = @accountID)
				AND a.accountID = b.accountID
				AND a.connectionID = c.connectionID
			UNION
			SELECT
				b.accountGUID AS [AccountGUID],
				b.name AS [AccountName],
				c.connectionGUID AS [ConnectionGUID],
				c.name AS [ConnectionName],
				txnSMSSubmitGUID AS [MessageGUID],
				'MT' AS [Type],
				sourceCode AS [Source],
				destinationNumber AS [Destination],
				[Dcs],
				[EsmClass],
				a.[Created],
				[Processed],
				[Completed],
				[SegmentGroupGUID],
				[SegmentTotal] =
				CASE
					WHEN [SegmentGroupGUID] IS NOT NULL THEN CONVERT(int, SUBSTRING(messageData, 5, 1))
				ELSE NULL END,
				[SegmentNumber] =
				CASE
					WHEN [SegmentGroupGUID] IS NOT NULL THEN CONVERT(int, SUBSTRING(messageData, 6, 1))
				ELSE NULL END,
				a.[providerTransactionID] AS [TransactionID],
				'SMS' AS [MsgType]
			FROM	txnSMSSubmit a WITH (NOLOCK), account b WITH (NOLOCK), connection c WITH (NOLOCK)
			WHERE a.created >= @activityStart AND a.created < @activityEnd
				AND a.accountID in (select accountID from account where accountParentID = @accountID OR accountID = @accountID)
				AND a.accountID = b.accountID
				AND a.connectionID = c.connectionID
			ORDER BY [created]

		END

	END

END 










GO
/****** Object:  StoredProcedure [dbo].[getAccountMDRbyRange]    Script Date: 01/11/2023 18:59:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[getAccountMDRbyRange]
	@type				VARCHAR(3),
	@accountID			INT,
	@activityStart		DATETIME,
	@activityEnd		DATETIME,
	@includeConnection	INT = 0,
	@includeContent		INT = 1
AS	 
BEGIN 

	-- Using NOCOUNT to reduce traffic and load on the system.
	SET NOCOUNT ON 

	IF @type = 'DLR'
	BEGIN
		PRINT 'Get DLR data'
		--DLR / Inbound

		SELECT	
				b.accountGUID AS [AccountGUID],
				b.name AS [AccountName],
				c.connectionGUID AS [ConnectionGUID],
				c.name AS [ConnectionName],
				a.txnSMSDeliverGUID AS [MessageGUID],
				mt.txnSMSSubmitGUID AS [SourceMessageGUID],
				'DLR' AS [Type],
				sourceNumber AS [Source],
				destinationCode AS [Destination],
				CAST(a.[Dcs] AS VARCHAR(10)) AS [Dcs],
				CAST(a.[EsmClass] AS VARCHAR(10)) AS [EsmClass],
				a.[Created],
				a.[Processed],
				a.[Completed],
				CASE WHEN @includeContent = 0 THEN ' -- redacted -- ' ELSE dbo.parseMessageData(a.[messageData]) END AS [MessageText]
		FROM	account b WITH (NOLOCK), connection c WITH (NOLOCK), txnSMSDeliver a WITH (NOLOCK)
		LEFT	OUTER JOIN txnSMSSubmit mt WITH (NOLOCK) ON  a.txnSMSDeliverID = mt.txnSMSDeliverID
		WHERE	a.created >= @activityStart AND a.created < @activityEnd
		AND		b.accountID in (select accountID from account where accountParentID = @accountID OR accountID = @accountID)
		AND		a.esmClass IN (4,8)
		AND		a.accountID = b.accountID
		AND		a.connectionID = c.connectionID

	END
	ELSE IF @type = 'MO'
	BEGIN
		PRINT 'Get MO data'
		--MO / INBOUND
		SELECT	
				b.accountGUID AS [AccountGUID],
				b.name AS [AccountName],
				c.connectionGUID AS [ConnectionGUID],
				c.name AS [ConnectionName],
				a.txnSMSDeliverGUID AS [MessageGUID],
				'MO' AS [Type],
				a.sourceNumber AS [Source],
				a.destinationCode AS [Destination],
				CAST(a.[Dcs] AS VARCHAR(10)) AS [Dcs],
				CAST(a.[EsmClass] AS VARCHAR(10)) AS [EsmClass],
				a.[Created],
				a.[Processed],
				a.[Completed],
				CASE WHEN @includeContent = 0 THEN ' -- redacted -- ' ELSE dbo.parseMessageData(a.[messageData]) END AS [MessageText],
				'SMS' AS [MsgType]
		FROM	txnSMSDeliver a WITH (NOLOCK), account b WITH (NOLOCK), connection c WITH (NOLOCK)
		WHERE	a.created >= @activityStart AND a.created < @activityEnd
		AND		b.accountID in (select accountID from account where accountParentID = @accountID OR accountID = @accountID)
		AND		esmClass NOT IN (4,8)
		AND		a.accountID = b.accountID
		AND		a.connectionID = c.connectionID
		UNION
		SELECT	
				b.accountGUID AS [AccountGUID],
				b.name AS [AccountName],
				c.connectionGUID AS [ConnectionGUID],
				c.name AS [ConnectionName],
				a.txnMMSDeliverGUID AS [MessageGUID],
				'MO' AS [Type],
				a.sourceNumber AS [Source],
				a.destinationCode AS [Destination],
				'N/A' AS [Dcs],
				'N/A' AS [EsmClass],
				a.[Created],
				a.[Processed],
				a.[Completed],
				CASE WHEN @includeContent = 0 THEN ' -- redacted -- ' ELSE a.[MessageText] END AS [MessageText],
				'MMS' AS [MsgType]
		FROM	txnMMSDeliver a WITH (NOLOCK), account b WITH (NOLOCK), connection c WITH (NOLOCK)
		WHERE	a.created >= @activityStart AND a.created < @activityEnd
		AND		b.accountID in (select accountID from account where accountParentID = @accountID OR accountID = @accountID)
		AND		dlr=0
		AND		a.accountID = b.accountID
		AND		a.connectionID = c.connectionID
		ORDER BY [Created]

	END
	ELSE
	BEGIN
		PRINT 'Get MT Data'
		--MT / Outbound
		SELECT
			b.accountGUID AS [AccountGUID],
			b.name AS [AccountName],
			c.connectionGUID AS [ConnectionGUID],
			c.name AS [ConnectionName],
			a.txnMMSSubmitGUID AS [MessageGUID],
			'MT' AS [Type],
			a.sourceCode AS [Source],
			a.destinationNumber AS [Destination],
			'N/A' AS [Dcs],
			'N/A' AS [EsmClass],
			a.[Created],
			a.[Processed],
			a.[Completed],
			CASE WHEN @includeContent = 0 THEN ' -- redacted -- ' ELSE a.[MessageText] END AS [MessageText],
			NULL AS [SegmentGroupGUID],
			0 AS [SegmentTotal],
			0 AS [SegmentNumber],
			a.[providerTransactionID] AS [TransactionID],
			'MMS' AS [MsgType]
		FROM	txnMMSSubmit a WITH (NOLOCK), account b WITH (NOLOCK), connection c WITH (NOLOCK)
		WHERE a.created >= @activityStart AND a.created < @activityEnd
			AND a.accountID in (select accountID from account where accountParentID = @accountID OR accountID = @accountID)
			AND a.accountID = b.accountID
			AND a.connectionID = c.connectionID
		UNION
		SELECT
			b.accountGUID AS [AccountGUID],
			b.name AS [AccountName],
			c.connectionGUID AS [ConnectionGUID],
			c.name AS [ConnectionName],
			a.txnSMSSubmitGUID AS [MessageGUID],
			'MT' AS [Type],
			a.sourceCode AS [Source],
			a.destinationNumber AS [Destination],
			CAST(a.[Dcs] AS VARCHAR(10)) AS [Dcs],
			CAST(a.[EsmClass] AS VARCHAR(10)) AS [EsmClass],
			a.[Created],
			a.[Processed],
			a.[Completed],
			CASE WHEN @includeContent = 0 THEN ' -- redacted -- ' ELSE dbo.parseMessageData(a.[messageData]) END AS [MessageText],
			a.[segmentGroupGUID],
			[SegmentTotal] =
			CASE
				WHEN a.[segmentGroupGUID] IS NOT NULL THEN CONVERT(int, SUBSTRING(messageData, 5, 1))
			ELSE NULL END,
			[SegmentNumber] =
			CASE
				WHEN a.[segmentGroupGUID] IS NOT NULL THEN CONVERT(int, SUBSTRING(messageData, 6, 1))
			ELSE NULL END,
			a.[providerTransactionID] AS [TransactionID],
			'SMS' AS [MsgType]
		FROM	txnSMSSubmit a WITH (NOLOCK), account b WITH (NOLOCK), connection c WITH (NOLOCK)
		WHERE a.created >= @activityStart AND a.created < @activityEnd
			AND a.accountID in (select accountID from account where accountParentID = @accountID OR accountID = @accountID)
			AND a.accountID = b.accountID
			AND a.connectionID = c.connectionID
		UNION
		SELECT 
			a.accountGUID AS [AccountGUID],
			a.name AS [AccountName],
			c.connectionGUID AS [ConnectionGUID],
			c.name AS [ConnectionName],
			MT.[transactionGUID] AS [MessageGUID],
			'MT' AS [Type],
			MT.sourceCode AS [Source],
			MT.destinationNumber AS [Destination],
			CAST(mt.[Dcs] AS VARCHAR(10)) AS [Dcs],
			CAST(mt.[EsmClass] AS VARCHAR(10)) AS [EsmClass],
			mt.auditSubmit AS [Created],
			p.auditResult AS [Processed],
			rs.auditResult AS [Complete],
			CASE WHEN @includeContent = 0 THEN ' -- redacted -- ' ELSE mt.messageText END AS [MessageText],
			mt.segmentGroupGUID AS [SegmentGroupGUID],
			[SegmentTotal] =
			CASE
				WHEN mt.[segmentGroupGUID] IS NOT NULL THEN CONVERT(int, SUBSTRING(messageData, 5, 1))
			ELSE NULL END,
			[SegmentNumber] =
			CASE
				WHEN mt.[segmentGroupGUID] IS NOT NULL THEN CONVERT(int, SUBSTRING(messageData, 6, 1))
			ELSE NULL END,
			rs.[providerTransactionID] AS [TransactionID],
			'SMS' AS [MsgType]
		FROM SMSMTSubmit mt WITH (NOLOCK)
		LEFT JOIN account a WITH (NOLOCK)
			ON mt.accountID = a.accountID
		LEFT JOIN connection c WITH (NOLOCK)
			ON mt.connectionID = c.connectionID
		LEFT JOIN SMSMTResult p WITH (NOLOCK)
			ON mt.transactionGUID = p.transactionGUID AND p.result = 0
		LEFT JOIN smsMTResult rs WITH (NOLOCK)
			on mt.transactionGUID = rs.transactionGUID
			AND	rs.result IN (
				1, -- SUCCESS: got response back success
				4, -- PHANTOM: phantom message
			   -1, -- NACK: message nacked by provider
			   -2, -- FAIL: internal fail
			   -3, -- ERROR: internal error
			   -6, -- BLOCKED: message blocked
			   -7, -- UNHANDLED: response unhandled (you should NEVER see this)
			   -8, -- INVALID: message was invalid
			   -9, -- UNROUTABLE: message is unrouteable
			  -10  -- TOOLONG: message took too long to send (24 hours)
			)
		WHERE mt.accountID = @accountID
		AND auditSubmit BETWEEN @activityStart AND @activityEnd
		ORDER BY [created]

	END

END 





GO
/****** Object:  StoredProcedure [dbo].[getAccountMDRdaily]    Script Date: 01/11/2023 18:59:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[getAccountMDRdaily]
	@type		VARCHAR(3),
	@accountID	INT,
	@includeConnection INT = 0
AS	 
BEGIN 

	-- Using NOCOUNT to reduce traffic and load on the system.
	SET NOCOUNT ON 

	DECLARE @activityStart	AS DATETIME;
	DECLARE @activityEnd	AS DATETIME;

	SET @activityStart	= dbo.fnStartOfDay(1);
	SET @activityEnd	= dbo.fnEndOfDay(1);

	IF @includeConnection = 0
	BEGIN

		IF @type = 'DLR'
		BEGIN

		  --DLR / Inbound
		  SELECT
			b.accountGUID AS [AccountGUID],
			b.name AS [AccountName],
			txnSMSDeliverGUID AS [MessageGUID],
			'DLR' AS [Type],
			sourceNumber AS [Source],
			destinationCode AS [Destination],
			[Dcs],
			[EsmClass],
			a.[Created],
			LEFT(a.[messageText],106) AS [StatusMsg]
		  FROM	txnSMSDeliver a WITH (NOLOCK), account b  WITH (NOLOCK)
		  WHERE a.created >= @activityStart AND a.created < @activityEnd
				AND(esmClass = 4 OR esmClass = 8)
				AND a.accountID in (select accountID from account where accountParentID = @accountID OR accountID = @accountID)
				AND a.accountID = b.accountID;

		END
		ELSE IF @type = 'MO'
		BEGIN

		  --MO / Inbound
		  SELECT
			b.accountGUID AS [AccountGUID],
			b.name AS [AccountName],
			txnSMSDeliverGUID AS [MessageGUID],
			'MO' AS [Type],
			sourceNumber AS [Source],
			destinationCode AS [Destination],
			[Dcs],
			[EsmClass],
			a.[Created],
			[Processed],
			[Completed]
		  FROM	txnSMSDeliver a WITH (NOLOCK), account b WITH (NOLOCK)
		  WHERE	a.created >= @activityStart AND a.created < @activityEnd
				AND esmClass != 4
				AND esmClass != 8
				AND a.accountID in (select accountID from account where accountParentID = @accountID OR accountID = @accountID)
				AND a.accountID = b.accountID;

		END
		ELSE
		BEGIN

		  --MT / Outbound
		  SELECT
			b.accountGUID AS [AccountGUID],
			b.name AS [AccountName],
			txnSMSSubmitGUID AS [MessageGUID],
			'MT' AS [Type],
			sourceCode AS [Source],
			destinationNumber AS [Destination],
			[Dcs],
			[EsmClass],
			a.[Created],
			[Processed],
			[Completed],
			[SegmentGroupGUID],
			[SegmentTotal] =
			  CASE
				WHEN [SegmentGroupGUID] IS NOT NULL THEN CONVERT(int, SUBSTRING(messageData, 5, 1))
			  ELSE NULL END,
			[SegmentNumber] =
			  CASE
				WHEN [SegmentGroupGUID] IS NOT NULL THEN CONVERT(int, SUBSTRING(messageData, 6, 1))
			  ELSE NULL END,
  			a.[providerTransactionID] AS [TransactionID]
		  FROM	txnSMSSubmit a WITH (NOLOCK), account b WITH (NOLOCK)
		  WHERE a.created >= @activityStart AND a.created < @activityEnd
				AND a.accountID in (select accountID from account where accountParentID = @accountID OR accountID = @accountID)
				AND a.accountID = b.accountID

		END
	END
	ELSE
	BEGIN

		IF @type = 'DLR'
		BEGIN

		  --DLR / Inbound
		  SELECT
			b.accountGUID AS [AccountGUID],
			b.name AS [AccountName],
			c.connectionGUID AS [ConnectionGUID],
			c.name AS [ConnectionName],
			txnSMSDeliverGUID AS [MessageGUID],
			'DLR' AS [Type],
			sourceNumber AS [Source],
			destinationCode AS [Destination],
			[Dcs],
			[EsmClass],
			a.[Created],
			LEFT(a.[messageText],106) AS [StatusMsg]
		  FROM	txnSMSDeliver a WITH (NOLOCK), account b  WITH (NOLOCK), connection c WITH (NOLOCK)
		  WHERE a.created >= @activityStart AND a.created < @activityEnd
				AND(esmClass = 4 OR esmClass = 8)
				AND a.accountID in (select accountID from account where accountParentID = @accountID OR accountID = @accountID)
				AND a.accountID = b.accountID
				AND a.connectionID = c.connectionID;

		END
		ELSE IF @type = 'MO'
		BEGIN

			--MO / INBOUND
			SELECT
				b.accountGUID AS [AccountGUID],
				b.name AS [AccountName],
				c.connectionGUID AS [ConnectionGUID],
				c.name AS [ConnectionName],
				txnMMSDeliverGUID AS [MessageGUID],
				'MO' AS [Type],
				sourceNumber AS [Source],
				destinationCode AS [Destination],
				0 AS [Dcs],
				0 AS [EsmClass],
				a.[Created],
				[Processed],
				[Completed],
				'MMS' AS [MsgType]
			FROM	txnMMSDeliver a WITH (NOLOCK), account b WITH (NOLOCK), connection c WITH (NOLOCK)
			WHERE	a.created >= @activityStart AND a.created < @activityEnd
				AND a.accountID in (select accountID from account where accountParentID = @accountID OR accountID = @accountID)
				AND a.accountID = b.accountID
				AND a.connectionID = c.connectionID
			UNION
			SELECT
				b.accountGUID AS [AccountGUID],
				b.name AS [AccountName],
				c.connectionGUID AS [ConnectionGUID],
				c.name AS [ConnectionName],
				txnSMSDeliverGUID AS [MessageGUID],
				'MO' AS [Type],
				sourceNumber AS [Source],
				destinationCode AS [Destination],
				[Dcs],
				[EsmClass],
				a.[Created],
				[Processed],
				[Completed],
				'SMS' AS [MsgType]
			FROM	txnSMSDeliver a WITH (NOLOCK), account b WITH (NOLOCK), connection c WITH (NOLOCK)
			WHERE	a.created >= @activityStart AND a.created < @activityEnd
				AND esmClass != 4
				AND esmClass != 8
				AND a.accountID in (select accountID from account where accountParentID = @accountID OR accountID = @accountID)
				AND a.accountID = b.accountID
				AND a.connectionID = c.connectionID
			ORDER BY [Created]

		END
		ELSE
		BEGIN

			--MT / Outbound
			SELECT
				b.accountGUID AS [AccountGUID],
				b.name AS [AccountName],
				c.connectionGUID AS [ConnectionGUID],
				c.name AS [ConnectionName],
				txnMMSSubmitGUID AS [MessageGUID],
				'MT' AS [Type],
				sourceCode AS [Source],
				destinationNumber AS [Destination],
				0 AS [Dcs],
				0 AS [EsmClass],
				a.[Created],
				[Processed],
				[Completed],
				NULL AS [SegmentGroupGUID],
				0 AS [SegmentTotal],
				0 AS [SegmentNumber],
				a.[providerTransactionID] AS [TransactionID],
				'MMS' AS [MsgType]
			FROM	txnMMSSubmit a WITH (NOLOCK), account b WITH (NOLOCK), connection c WITH (NOLOCK)
			WHERE a.created >= @activityStart AND a.created < @activityEnd
				AND a.accountID in (select accountID from account where accountParentID = @accountID OR accountID = @accountID)
				AND a.accountID = b.accountID
				AND a.connectionID = c.connectionID
			UNION
			SELECT
				b.accountGUID AS [AccountGUID],
				b.name AS [AccountName],
				c.connectionGUID AS [ConnectionGUID],
				c.name AS [ConnectionName],
				txnSMSSubmitGUID AS [MessageGUID],
				'MT' AS [Type],
				sourceCode AS [Source],
				destinationNumber AS [Destination],
				[Dcs],
				[EsmClass],
				a.[Created],
				[Processed],
				[Completed],
				[SegmentGroupGUID],
				[SegmentTotal] =
				CASE
					WHEN [SegmentGroupGUID] IS NOT NULL THEN CONVERT(int, SUBSTRING(messageData, 5, 1))
				ELSE NULL END,
				[SegmentNumber] =
				CASE
					WHEN [SegmentGroupGUID] IS NOT NULL THEN CONVERT(int, SUBSTRING(messageData, 6, 1))
				ELSE NULL END,
				a.[providerTransactionID] AS [TransactionID],
				'SMS' AS [MsgType]
			FROM	txnSMSSubmit a WITH (NOLOCK), account b WITH (NOLOCK), connection c WITH (NOLOCK)
			WHERE a.created >= @activityStart AND a.created < @activityEnd
				AND a.accountID in (select accountID from account where accountParentID = @accountID OR accountID = @accountID)
				AND a.accountID = b.accountID
				AND a.connectionID = c.connectionID
			ORDER BY [created]

		END

	END

END 












GO
/****** Object:  StoredProcedure [dbo].[getCodeAssignedDetail]    Script Date: 01/11/2023 18:59:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[getCodeAssignedDetail]
	@connectionID INT,
	@code VARCHAR(50) = '',
	@page INT = 1,
	@pageSize INT = 100
AS	 
BEGIN 

	SET NOCOUNT ON 

	DECLARE @CodeLength INT = LEN(@code)

	PRINT @CodeLength

	SELECT	a.code, 
			c.connectionGUID, 
			a.name as emailName, 
			emailDomain, 
			emailAddress
	FROM	code a WITH (NOLOCK), connectionCodeAssign b WITH (NOLOCK), connection c WITH (NOLOCK) 
	WHERE	a.codeID = b.codeID
	AND		b.connectionID = c.connectionID
	AND		b.connectionID = @connectionID
	AND		(@CodeLength = 0 OR (LEFT(code, @CodeLength) = @code))
	ORDER	BY code OFFSET (@pageSize * (@page - 1)) ROWS FETCH NEXT @pageSize ROWS ONLY; 

END 



GO
/****** Object:  StoredProcedure [dbo].[getCodeStatus]    Script Date: 01/11/2023 18:59:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[getCodeStatus]
	@code VARCHAR(15) = ''
AS	 
BEGIN 

	SET NOCOUNT ON 

	SELECT
	  a.created,
	  b.created AS [assigned],
	  b.accountName,
	  b.accountID,
	  b.connectionName,
	  b.connectionID,
	  a.code,
	  a.codeID,
	  a.codeTypeID,
	  a.codeRegistrationID,
	  a.sms,
	  a.mms,
	  a.voice,
	  a.surcharge,
	  a.espid,
	  a.providerID,
	  p.name AS [providerName],
	  a.publishStatus,
	  a.publishUpdate,
	  a.active,
	  a.deactivated,
	  a.available,
	  a.name,
	  a.emailAddress,
	  a.emailDomain,
	  a.voiceForwardTypeID,
	  a.voiceForwardDestination,
	  a.replyHelp,
	  a.replyStop
	FROM code a WITH (NOLOCK) LEFT JOIN (
	  SELECT 
		ac.name AS [accountName],
		f.accountID,
		codeID,
		e.connectionID,
		f.connectionGUID,
		f.name AS connectionName,
		e.created,
		ac.active
	  FROM connectionCodeAssign e WITH (NOLOCK), connection f WITH (NOLOCK), account ac WITH (NOLOCK)
	  WHERE e.connectionID = f.connectionID
	  AND	f.accountID = ac.accountID
	) b ON a.codeID = b.codeID
	LEFT JOIN provider p WITH (NOLOCK) 
		ON a.providerID = p.providerID
	WHERE a.code = @code;

END 





GO
/****** Object:  StoredProcedure [dbo].[getConcatenationCount]    Script Date: 01/11/2023 18:59:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[getConcatenationCount]
	@accountID	INT,
	@monthsBack INT = 0
AS	 
BEGIN 

	-- Using NOCOUNT to reduce traffic and load on the system.
	SET NOCOUNT ON 

	IF OBJECT_ID('tempdb..#smsConcatenated') IS NOT NULL DROP TABLE #smsConcatenated;

	DECLARE @startDate AS DATETIME;
	DECLARE @endDate AS DATETIME;

	SET @startDate = dbo.fnStartOfMonth(@monthsBack);
	SET @endDate = dbo.fnEndOfMonth(@monthsBack);

	SELECT  (CAST(CREATED AS DATE)) AS [date],
			(CONVERT([varchar](10), messageData, 2) + ':' + sourceCode + ':' + destinationNumber) AS [key],
			(CONVERT(INT, SUBSTRING(messageData,5,1))) AS [totalSegments],
			([created]) AS [created]
	INTO	#smsConcatenated
	FROM	txnSMSSUbmit (NOLOCK) 
	WHERE	accountID = @accountID
	AND		created BETWEEN @startDate AND @endDate
	AND		esmClass = 64;

	WITH concatenated AS ( 
		SELECT	MIN([created]) AS [firstSegment],
				MAX([created]) AS [lastSegment],
				DATEDIFF(SECOND,MIN([created]),MAX([created])) AS [timeSpan],
				MAX([key]) AS [key],
				MIN([totalSegments]) AS [expectedSegments],
				COUNT(*) AS [totalSegments]
		FROM	#smsConcatenated
		GROUP	BY [date],[key]
	)

	SELECT  MIN([totalSegments]) AS [minSegments],
			MAX([totalSegments]) AS [maxSegments],
			AVG([totalSegments]) AS [avgSegments],
			COUNT(*) AS [totalMessages],
			SUM([totalSegments]) AS [totalSegments]
	FROM	concatenated
	WHERE	totalSegments > 1;

	IF OBJECT_ID('tempdb..#smsConcatenated') IS NOT NULL DROP TABLE #smsConcatenated;


END 





GO
/****** Object:  StoredProcedure [dbo].[getConnectionIDforAccountByAccountID]    Script Date: 01/11/2023 18:59:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[getConnectionIDforAccountByAccountID]
	@accountID int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT a.name AS accountName, c.name AS connectionName, c.connectionID
	FROM connection c, account a
	WHERE c.accountID = a.accountID
	AND a.accountID = @accountID
	ORDER BY c.name ASC
END

GO
/****** Object:  StoredProcedure [dbo].[getConnectionIDforAccountByAccountName]    Script Date: 01/11/2023 18:59:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[getConnectionIDforAccountByAccountName]
	@accountName varchar(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
select a.name as accountName,c.name as connectionName,c.connectionID
from connection c, account a
where c.accountID = a.accountID
and a.name like '%'+@accountName + '%'
order by c.name asc
END





GO
/****** Object:  StoredProcedure [dbo].[getFreeSpace]    Script Date: 01/11/2023 18:59:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[getFreeSpace]
AS	 
BEGIN 
	SET NOCOUNT ON 

	;WITH 
		t(s) AS (
			SELECT	CONVERT(DECIMAL(12,2),CAST(SUM(size) AS DECIMAL(12,2))*8/1024.0)  
			FROM	sys.database_files  
			WHERE	[type] % 2 = 0 
		),
		d(s) AS (
			SELECT	CONVERT(DECIMAL(12,2),CAST(SUM(total_pages) AS DECIMAL(12,2))*8/1024.0) 
			FROM sys.partitions AS p 
			INNER JOIN sys.allocation_units AS a 
			ON p.[partition_id] = a.container_id 
		)
	SELECT	Allocated_Space = t.s, 
			Available_Space = t.s - d.s, 
			[Available_%] = CONVERT(DECIMAL(5,2), (t.s - d.s)*100.0/t.s) 
	FROM	t CROSS APPLY d;

END 



GO
/****** Object:  StoredProcedure [dbo].[getMessages]    Script Date: 01/11/2023 18:59:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[getMessages]
	@connectionID INT,
	@startDate VARCHAR(25) = '',
	@endDate VARCHAR(25) = '',
	@source VARCHAR(15) = '',
	@destination VARCHAR(15) = '',
	@startRow INT = 1,
	@maxRows INT = 1000,
	@messageType VARCHAR(5) = 'MT',
	@sortOrder VARCHAR(5) = 'ASC'
AS	 
BEGIN 
	SET NOCOUNT ON 

	DECLARE @@start DATETIME = @startDate; 
	DECLARE @@end DATETIME = @endDate;
	DECLARE @@maxRows INT = @maxRows;
	DECLARE @@startRow INT = @startRow;
	DECLARE @@connectionID INT = @connectionID;
	DECLARE @@source VARCHAR(15) = @source;
	DECLARE @@destination VARCHAR(15) = @destination;
	DECLARE @@sortOrder VARCHAR(5) = @sortOrder;
	DECLARE @@messageType VARCHAR(5) = @messageType;
	
	IF @@start = '' SET @@start = dbo.fnStartOfDay(0);
	IF @@end = '' SET @@end = dbo.fnEndOfDay(0);
	IF @@maxRows > 1000 SET @@maxRows = 1000;

	PRINT @@start;
	PRINT @@end;
	PRINT @@maxRows;
	PRINT @@startRow;
	PRINT @@connectionID;
	PRINT @@source;
	PRINT @@destination;
	PRINT @@sortOrder;

	IF (@@messageType='MT')
	BEGIN

		SELECT 
			mt.auditSubmit AS [created],
			p.auditResult AS [processed],
			c.auditResult AS [complete],
			mt.messageText,
			MT.[transactionGUID],
			sourceCode AS [source],
			destinationNumber AS [destination],
			'MT' AS [type],
			CASE 
				WHEN mode=1 THEN 'Phantom' 
				WHEN mode=0 AND c.auditResult IS NULL THEN 'Pending'
				WHEN mode=0 AND c.auditResult IS NOT NULL AND c.result IN (1,4) THEN 'Success'
				ELSE 'Failed'
			END AS [status]
		FROM SMSMTSubmit mt WITH (NOLOCK)
		LEFT OUTER JOIN SMSMTResult p WITH (NOLOCK)
			ON mt.transactionGUID = p.transactionGUID AND p.result = 0
		LEFT OUTER JOIN smsMTResult c WITH (NOLOCK) ON mt.transactionGUID = c.transactionGUID AND c.result IN (1,4,-1,-2,-3,-6,-7,-8,-9,-10)
		WHERE connectionID = @@connectionID
		AND auditSubmit BETWEEN @@start AND @@end
		AND	(@@source = '' OR sourceCode = @@source)
		AND	(@@destination = '' OR destinationNumber = @@destination)
		ORDER BY 
			--CASE WHEN @@sortOrder = 'DESC' THEN auditSubmit END DESC, CASE WHEN @@sortOrder != 'DESC' THEN auditSubmit END ASC 
			auditSubmit ASC
			OFFSET (@@startRow-1) ROWS FETCH NEXT @@maxRows ROWS ONLY;

	END
	ELSE 
	BEGIN

		SELECT
			d.auditDeliver AS [created],
			(SELECT MIN(drp.auditResult) FROM SMSdeliverResult drp WHERE drp.transactionGUID = d.transactionGUID) AS [processed],
			dr.auditResult AS [completed],
			d.messageText,
			d.transactionGUID,
			d.sourceNumber AS [source],
			d.destinationCode AS [destination],
			'MO' AS [type],
			CASE 
				WHEN dr.result IN (1) THEN 'Success'
				WHEN dr.result IN (-6,-7,-8,-10) THEN 'Failed'
				ELSE 'Pending'
			END AS [status]
			FROM SMSdeliver d
			LEFT OUTER JOIN SMSdeliverResult dr 
			ON d.transactionGUID = dr.transactionGUID
			AND dr.auditResult = (SELECT MAX(auditResult) FROM SMSdeliverResult WHERE transactionGUID = dr.transactionGUID AND dr.result IN (1,-6,-7,-8,-10))
			WHERE d.connectionID = @@connectionID
				AND d.auditDeliver BETWEEN @@start AND @@end
				AND	d.esmClass NOT IN (4,8)
				AND	(@@source = '' OR d.sourceNumber = @@source)
				AND	(@@destination = '' OR d.destinationCode = @@destination)
			ORDER BY d.auditDeliver ASC
			OFFSET (@@startRow-1) ROWS FETCH NEXT @@maxRows ROWS ONLY;			

	END 

END 


GO
/****** Object:  StoredProcedure [dbo].[getNumberCountryNPAOverride]    Script Date: 01/11/2023 18:59:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[getNumberCountryNPAOverride]
	@destinationCode CHAR(50),
	@sourceNumber CHAR(50)
AS	 
BEGIN 
	SET NOCOUNT ON 

	SELECT	cn.*, c.code, c.codeID 
	FROM	numberCountryNPAOverride npa, code c, connection cn
	WHERE countryCodeNormalized = (
		SELECT  countryCodeNormalized
		FROM	numberCountryNPAExtended WITH (NOLOCK)
		WHERE	countryCode = LEFT(@sourceNumber, LEN(countryCode))
	)
	AND	c.code = @destinationCode
	AND npa.connectionID = cn.connectionID
	AND	npa.codeID = c.codeID

END 






GO
/****** Object:  StoredProcedure [dbo].[getRecentAccountRegistrations]    Script Date: 01/11/2023 18:59:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[getRecentAccountRegistrations]

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT top 10 * from accountRegistration order by accountRegistrationID desc 

END





GO
/****** Object:  StoredProcedure [dbo].[getRouteActions]    Script Date: 01/11/2023 18:59:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[getRouteActions]
	@sourceCode VARCHAR(50),
	@destinationCode VARCHAR(50),
	@connectionID INT,
	@routeActionTypeID INT
AS	 
BEGIN 

	SET NOCOUNT ON 

	DECLARE @MaxRows INT;

/* The following query selects the default route for given connectionID */
/* routeActionTypeID = message.codeTransactionType = MT(1), MO(2), MMS_MO(8), MMS_MT(10), or MMS_DLR(15) */
/* if MT, then return records with routingActionTypeID = 1, 24 */
/* if MMS_MT, then force exactly one record to be returned with routingActionTypeID = 10 */
/* if MO, MMS_MO, or MMS_DLR, then return all routingActionTypeIDs except 1 or 10  */

/* destinationCode is not used in selecting the default route but will be needed if this procedure does conditional routing (see commented out code at bottom) */

/* ordering the routeSequence is only needed for routeActionTypeID = 1, 10 */
/* ordering the routeAction records returned from this query is not needed; code logic in messages/Router.js handles the proper ordering */ 

	SET @MaxRows = 9999
	IF @routeActionTypeID = 10
	BEGIN
		SET @MaxRows = 1
	END

	SELECT	TOP (@MaxRows)
			ra.routeActionTypeID, 
			ra.routeActionValue, 
			conn.connectionTypeID, 
			conn.requestLimitPerSecond, 
			code.providerID
	FROM	route r with (NOLOCK)
			INNER JOIN routeAction ra with (NOLOCK) 
				ON r.routeID = ra.routeID
			INNER JOIN connection conn with (NOLOCK) 
				ON conn.connectionID = r.connectionID 
			LEFT OUTER JOIN code with (NOLOCK)  
				ON code.code = @sourceCode
	WHERE	r.connectionID = @connectionID 
			AND r.routeID IN ( SELECT routeID FROM route 
								WHERE connectionID = @connectionID 
								AND sourceCodeCompare = '0' 
								AND destinationCodeCompare = '0')
			AND ra.active = 1
            AND (
                 (@routeActionTypeID != 1 AND @routeActionTypeID != 10 AND ra.routeActionTypeID >= 2)
                 OR (@routeActionTypeID = 10 AND ra.routeActionTypeID = @routeActionTypeID)
                 OR (@routeActionTypeID = 1 AND (ra.routeActionTypeID = @routeActionTypeID OR ra.routeActionTypeID = 24))
            )
			ORDER BY routeSequence DESC

END

GO
/****** Object:  StoredProcedure [dbo].[getVoiceConfig]    Script Date: 01/11/2023 18:59:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[getVoiceConfig]
AS
BEGIN
    -- Using NOCOUNT to reduce traffic and load on the system.
    SET NOCOUNT ON
    SELECT
        LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(a.name,',',''),'&','_'),'/',''),'(',''),')',''),' ','_'),'-','_'),'.',''),'___','_'),'__','_')) AS [name],
        d.code,
        d.voiceForwardTypeID,
        d.voiceForwardDestination,
        CASE WHEN d.codeRegistrationID IN (750) OR b.accountID IN (7) THEN 'false' ELSE 'true' END AS [mediaBypass]
    FROM account a (NOLOCK), connection b (NOLOCK), connectionCodeAssign c (NOLOCK), code d (NOLOCK)
    WHERE a.accountID = b.accountID
        AND b.connectionID = c.connectionID
        AND c.codeID = d.codeID
        AND d.voice = 1
        AND d.active = 1
        AND d.voiceForwardDestination IS NOT NULL
        AND RTRIM(LTRIM(d.voiceForwardDestination)) != ''
        AND
            (
                d.voiceForwardTypeID IN (1,3)
                OR
                (
                    d.voiceForwardTypeID = 2
                    AND
                    LEFT(d.voiceForwardDestination,4) IN (
                        SELECT  countryCode
                        FROM    numberCountryNPAExtended
                        WHERE   countryCodeNormalized IN ('1USA','1CAN','18xx')
                        AND     countryCode NOT IN (
                            SELECT  CONCAT('1',npa) AS [NPA]
                            FROM    numberAreaPrefix
                            WHERE   stateCodeAlpha2 IN ('AK','HI')
                        )
                    )
                )
            )
    UNION ALL
    SELECT
        'e_telecocom' AS [name],
        d.code,
        '1' AS voiceForwardTypeID,
        '68.64.83.168' AS voiceForwardDestination,
        'true' AS [mediaBypass]
    FROM code d (NOLOCK)
    WHERE d.voice = 1
        AND d.available = 1
        AND d.voiceForwardDestination IS NULL
        AND d.codeRegistrationID IN (200,550,700)
    ORDER BY name, code
END


GO
/****** Object:  StoredProcedure [dbo].[getVoicePRIMARY]    Script Date: 01/11/2023 18:59:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[getVoicePRIMARY]
AS	 
BEGIN 

	-- Using NOCOUNT to reduce traffic and load on the system.
	SET NOCOUNT ON 

	SELECT
		LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(a.name,',',''),'&','_'),'/',''),'(',''),')',''),' ','_'),'-','_'),'.',''),'___','_'),'__','_')) AS [name],
		d.code,
		d.voiceForwardTypeID,
		d.voiceForwardDestination,
		CASE WHEN d.codeRegistrationID IN (750) OR b.accountID IN (7) THEN 'false' ELSE 'true' END AS [mediaBypass]
	FROM account a (NOLOCK), connection b (NOLOCK), connectionCodeAssign c (NOLOCK), code d (NOLOCK)
	WHERE a.accountID = b.accountID
		AND b.connectionID = c.connectionID
		AND c.codeID = d.codeID
		AND d.voice = 1
		AND d.active = 1
		AND d.voiceForwardDestination IS NOT NULL
		AND RTRIM(LTRIM(d.voiceForwardDestination)) != ''
		AND 
			( 
				d.voiceForwardTypeID IN (1,3) 
				OR
				(
					d.voiceForwardTypeID = 2
					AND
					LEFT(d.voiceForwardDestination,4) IN (
						SELECT	countryCode
						FROM	numberCountryNPAExtended
						WHERE	countryCodeNormalized IN ('1USA','1CAN','18xx')
						AND		countryCode NOT IN (
							SELECT	CONCAT('1',npa) AS [NPA]
							FROM	numberAreaPrefix
							WHERE	stateCodeAlpha2 IN ('AK','HI')
						)
					)
				)
			)
	UNION ALL
	SELECT
		'e_telecocom' AS [name],
		d.code,
		'1' AS voiceForwardTypeID,
		'68.64.83.168' AS voiceForwardDestination,
		'true' AS [mediaBypass]
	FROM code d (NOLOCK)
	WHERE d.voice = 1
		AND d.available = 1
		AND d.voiceForwardDestination IS NULL
		AND d.codeRegistrationID IN (200,550,700)
	ORDER BY name, code

END 









GO
/****** Object:  StoredProcedure [dbo].[incrementDeliverRetryCount]    Script Date: 01/11/2023 18:59:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[incrementDeliverRetryCount]
	-- Add the parameters for the stored procedure here
	@txnSMSDeliverID bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	UPDATE txnSMSDeliver SET forwardRetryCount = forwardRetryCount+1 WHERE txnSMSDeliverID = @txnSMSDeliverID
END




GO
/****** Object:  StoredProcedure [dbo].[mosaicSwitchToESPID]    Script Date: 01/11/2023 18:59:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[mosaicSwitchToESPID]
	@code varchar(15), 
	@connectionID INT
WITH EXECUTE AS 'dbo'  
AS
BEGIN

	DECLARE @codeID INT;
	DECLARE @currentESPID VARCHAR(10);
	DECLARE @inConnection INT = 0;
	DECLARE @errorMessage VARCHAR(255);

	SET NOCOUNT ON;

	BEGIN TRY

		SET @codeID = (SELECT codeID FROM code WHERE code = @code);
		SET @currentESPID = (SELECT espid FROM code WHERE codeID = @codeID);
		SET @inConnection = (SELECT COUNT(*) FROM connectionCodeAssign ca, connection co WHERE ca.codeID = @codeID AND ca.connectionID = @connectionID AND ca.connectionID=co.connectionID AND co.accountID IN (SELECT accountID FROM account WHERE accountID=44 OR accountParentID=44));

		PRINT 'In Connection: ' + CAST(@inConnection AS VARCHAR(5));

		IF (@inConnection > 0) AND (@currentESPID != 'E911')
		BEGIN
			UPDATE code SET publishStatus=1, espid='E911', publishUpdate=2 WHERE codeID = @codeID;
			SELECT 'Success' AS [result], @code AS [code], @connectionID AS [connectionID];
		END
		ELSE
		BEGIN
			SELECT 'Failed' AS [result], @code AS [code], @connectionID AS [connectionID];
		END

	END TRY
	BEGIN CATCH

		SET @errorMessage = (SELECT LEFT(ERROR_MESSAGE(), 255) AS ErrorMessage);
		PRINT @errorMessage;

		SELECT 'Failed', @code, @connectionID;
	END CATCH
END
































GO
/****** Object:  StoredProcedure [dbo].[provisionAccount]    Script Date: 01/11/2023 18:59:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[provisionAccount] 
	@accountRegistrationID INT,
	@permissions INT = 0,
    @billingType SMALLINT = 1,
	@active BIT = 1
AS
BEGIN
	BEGIN TRY

	SET NOCOUNT ON;

	declare @checkRecord INT;
	declare @accountID INT;
	declare @accountGUID CHAR(36);
	declare @accountName varchar(100);
	declare @connectionID INT;
	declare @connectionGUID CHAR(36);
	declare @routeID INT;

--##Dynamic Parameter Values:
--##X = accountRegistrationID (put this value in every query WHERE X is stated)
--##Y = accountID (get this after step 3 is run and put it in every query WHERE Y is stated)
--##Z = connectionID
--##W = routeID

--#STEP 1: manually create an accountRegistration record or have the customer complete the form

--#STEP 2: registration must be verified and approved before provisioning can start

--STEP 3A - verify registration record is ready or exit out of procedure
    SET @checkRecord = (
		SELECT COUNT(*) FROM accountRegistration WHERE verified IS NOT NULL AND approved IS NOT NULL AND provisioned IS NULL AND accountRegistrationID = @accountRegistrationID
	);
	IF (@checkRecord = 0)
    BEGIN
    	RAISERROR('AERIALINK Message - Registration Record does not exist, is not approved, or is already provisioned!', 18, 1)
    	RETURN -1
    END

	BEGIN TRANSACTION

	--#STEP 3: INSERT 'account' record FROM the 'accountRegistration' record - A REGISTRATION RECORD MUST EXIST PRIOR TO THIS PROCESS
	--## required parameters are: accountRegistrationID, accountParentID (defaults to 0), billingType (defaults to 1)
	--#NOTES:
	--#billingType:
	--#1 = Post Paid, not subject to rating blocks
	--#2 = Pre-paid, allow to queue, but do not send
	--#3 = Pre-paid, do not allow queueing, full block
	INSERT account (accountParentID,accountRegistrationID,name,billingType,email,phone1,phone1isMobile,address1,address2,city,state,zip,country,active,created,lastUpdated)
		SELECT 0 AS accountParentID, @accountRegistrationID, accountName AS name, @billingType, email, phone AS phone1, phoneIsMobile AS phone1isMobile,
			address1, address2, city, state, zip, country, @active, getUTCDate() AS created, getUTCDate() AS lastUpdated
		FROM accountRegistration 
		WHERE verified IS NOT NULL AND approved IS NOT NULL AND provisioned is null AND accountRegistrationID = @accountRegistrationID;

	--#get newly created accountID which should be the last autoincrementID for the new account record and the accountname
	SET @accountID = SCOPE_IDENTITY();
	SET @accountName = (SELECT name FROM account WHERE accountID = @accountID);
	SET @accountGUID = (SELECT accountGUID FROM account WHERE accountID = @accountID);

	--#STEP 4: INSERT accountContact : we will always create the default primary contact for them
	--# provide accountID WHERE you see Y and accountRegistrationID WHERE you see X
	--#!PROVIDE accountRegistrationID!#
	--#NOTES:accountContactTypeID: 1-Administrator/Primary, 2-Technical, 3-Billing, 4-Other - we always SET this default accountContact AS admin/primary
	INSERT accountContact (accountID,accountContactPrimary,firstName,lastName,email,phone1,phone1isMobile,address1,address2,city,state,zip,country,active,created,lastUpdated)
		SELECT @accountID AS accountID,1 AS accountContactPrimary,firstName,lastName,email,phone AS phone1,phoneIsMobile AS phone1isMobile,
			address1,address2,city,state,zip,country,@active,getUTCDate() AS created,getUTCDate() AS lastUpdated
		FROM accountRegistration 
		WHERE verified IS NOT NULL AND approved IS NOT NULL AND provisioned IS NULL AND accountRegistrationID = @accountRegistrationID;    

	--#STEP 5: INSERT accountUser : we will always create the default user account for them
	--#NOTES: #it defaults to timezone = 13 and daylightSavingTime = 1, in the provisioning tool, allow us to SET these - the new umi handles timezones differently
	INSERT accountUser (accountID, userName, userPassword, firstName, lastName, email, phone1, phone1isMobile, timezone, daylightSavingTime, active, created, lastUpdated)
		SELECT @accountID AS accountID, userName, CONVERT(VARCHAR(32), HashBytes('MD5', userPassword), 2) AS userPassword, firstName, lastName, email, phone AS phone1, phoneIsMobile AS phone1isMobile, 
		13 AS timezone, 1 AS daylightSavingTime, @active, getUTCDate() AS created, getUTCDate() AS lastUpdated
		FROM accountRegistration 
		WHERE verified IS NOT NULL AND approved IS NOT NULL AND provisioned IS NULL AND accountRegistrationID = @accountRegistrationID;

	--#STEP 6: INSERT connection : we will always create one default connection for them
	INSERT connection (connectionTypeID,accountID,name,codeDistributionMethodID, requestLimitPerSecond,requestLimitPerDay,requestLimitPerMonth,
		requireList,enforceOptOut,messageExpirationHours, active,created,lastUpdated)
	VALUES (1,@accountID,@accountName,0,1,0,0,0,0,24,@active,getUTCDate(),getUTCDate());

	--#get newly created connectionID
	SET @connectionID = SCOPE_IDENTITY();
	SET @connectionGUID = (SELECT connectionGUID FROM connection WHERE connectionID = @connectionID);

	--#STEP 7: INSERT route : create default route
	INSERT route (accountID,connectionID,acceptDeny,sourceCodeCompare,destinationCodeCompare,messageDataCompare,numberOperatorID,
			validityDateStart,validityDateEnd,validityTimeStart,validityTimeEnd,routeSequence, created,lastUpdated)
	VALUES (@accountID, @connectionID, 1, 0, 0, 0, 0, '1900-01-01 00:00:00', '2900-01-01 00:00:00', '00:00:00', '23:59:59', 1, getUTCDate(), getUTCDate());

	--#get newly created routeID
	SET @routeID = SCOPE_IDENTITY();

	--#STEP 8: SET DEFAULT MT ROUTE, the MO WILL HAVE TO BE DEFINED IN THEIR UMI
	INSERT routeAction (routeID,routeActionTypeID,routeActionValue,active,created,lastUpdated)
	VALUES (@routeID, 1, 0, @active, getUTCDate(), getUTCDate());

	INSERT routeAction (routeID,routeActionTypeID,routeActionValue, active, created,lastUpdated)
	VALUES (@routeID, 10, 0, @active, getUTCDate(), getUTCDate());

	--Add access to codes lookup, leased code provisioning and reporting by default
	INSERT routeAction (routeID,routeActionTypeID,routeActionValue, active, created,lastUpdated)
	VALUES (@routeID, 17, 0, @active, getUTCDate(), getUTCDate());

	INSERT routeAction (routeID,routeActionTypeID,routeActionValue, active, created,lastUpdated)
	VALUES (@routeID, 18, 0, @active, getUTCDate(), getUTCDate());

	INSERT routeAction (routeID,routeActionTypeID,routeActionValue, active, created,lastUpdated)
	VALUES (@routeID, 19, 0, @active, getUTCDate(), getUTCDate());

	--Permissions Values:
		--Connection API Access		1	/* 001 */
		--Account API Access		2	/* 010 */
		--Internal Codes API Access	4	/* 100 */
	IF (@permissions & 1) = 1 
	BEGIN
		INSERT routeAction (routeID,routeActionTypeID,routeActionValue, active, created,lastUpdated)
		VALUES (@routeID, 16, 0, @active, getUTCDate(), getUTCDate());
	END;

	IF (@permissions & 2) = 2
	BEGIN
		INSERT routeAction (routeID,routeActionTypeID,routeActionValue, active, created,lastUpdated)
		VALUES (@routeID, 20, 0, @active, getUTCDate(), getUTCDate());
	END;

	IF (@permissions & 4) = 4 
	BEGIN
		INSERT routeAction (routeID,routeActionTypeID,routeActionValue, active, created,lastUpdated)
		VALUES (@routeID, 21, 0, @active, getUTCDate(), getUTCDate());
	END;

	--update the accountregistration record to mark it now AS provisioned
	UPDATE accountRegistration SET provisioned = getUTCDate(), lastUpdated = getUTCDate() WHERE accountRegistrationID = @accountRegistrationID;

	-- return accountName, accountID, accountGUID, and connectionGUID
	SELECT @accountName AS [accountName], @accountID AS [accountID], @accountGUID AS [accountGUID], @connectionGUID AS [connectionGUID];

	COMMIT TRANSACTION

	END TRY

	BEGIN CATCH
        IF @@TRANCOUNT > 0
        	ROLLBACK TRANSACTION;
		THROW;
	END CATCH

END

GO
/****** Object:  StoredProcedure [dbo].[provisionCode]    Script Date: 01/11/2023 18:59:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[provisionCode] 
	@code varchar(15),
	@name varchar(100),
	@itemCode INT, 
	@espid varchar(10), 
	@codeTypeID INT,
	@codeRegistrationID INT,
	@providerID INT,
	@publishStatus BIT,
	@publishUpdate TINYINT,
	@emailAddress varchar(75),
	@emailDomain varchar(50),
	@surcharge BIT = 0,
	@notePrivate varchar(255) = NULL

AS
BEGIN

	BEGIN TRY

	SET NOCOUNT ON;

	--Check to see if data has already been added to activity for this customer, and if so, kill the process
	declare @checkRecord INT

    SET @checkRecord = ( SELECT COUNT(*) FROM code c WHERE c.code = @code );
	IF (@checkRecord > 0)
    BEGIN
		RAISERROR('AERIALINK Message - This CODE already EXISTS! Process has been halted!', 18, 1)
		RETURN -1
    END
	
	BEGIN TRANSACTION

		INSERT INTO code (codeGUID,codeTypeID,code,name,itemCode,espid,codeRegistrationID,providerID,sms,publishStatus,publishUpdate,active,emailAddress,emailDomain,created, surcharge, notePrivate) 
		VALUES (newid(),@codeTypeID,@code,@name,@itemCode,@espid,@codeRegistrationID,@providerID,1,@publishStatus,@publishUpdate,0,@emailAddress,@emailDomain,getutcdate(), @surcharge, @notePrivate);

		SELECT 'provisionCode Completed', @@identity;

	COMMIT TRANSACTION

	END TRY

	BEGIN CATCH
        IF @@TRANCOUNT > 0
        	ROLLBACK TRANSACTION;
		THROW;
	END CATCH

END


GO
/****** Object:  StoredProcedure [dbo].[provisionConnection]    Script Date: 01/11/2023 18:59:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[provisionConnection] 
	@connectionName varchar(100),
	@accountID INT

AS
BEGIN
	BEGIN TRY

	SET NOCOUNT ON;

	declare @connectionID INT;
	declare @connectionGUID CHAR(36);
	declare @routeID INT;

	BEGIN TRANSACTION

	--#STEP 1: INSERT connection : we will always create one default connection
	INSERT connection (connectionTypeID, accountID, name, codeDistributionMethodID,
		requestLimitPerSecond, messageExpirationHours, active)
	VALUES (1, @accountID, @connectionName, 0, 1, 24, 1);
	
	-- get newly created connectionID
	SET @connectionID = SCOPE_IDENTITY();
	SET @connectionGUID = (SELECT connectionGUID FROM connection WHERE connectionID = @connectionID);
	
	--#STEP 2: INSERT route : create default route
	INSERT route (accountID, connectionID, acceptDeny, numberOperatorID,
				validityDateStart, validityDateEnd, validityTimeStart, validityTimeEnd, routeSequence)
	VALUES (@accountID, @connectionID, 1, 0, '1900-01-01 00:00:00', '2900-01-01 00:00:00', '00:00:00', '23:59:59', 1);
	
	-- get newly created routeID
	SET @routeID = SCOPE_IDENTITY();
	
	--#STEP 3: Provide access to SMS MT, reports and query/publish leased codes.

	-- route action type SMS Outbound (MT)
	INSERT routeAction (routeID, routeActionTypeID, routeActionValue, active) VALUES (@routeID, 1, 0, 1);
	
	-- route action type MMS Outbound (MT) HTTP
	INSERT routeAction (routeID, routeActionTypeID, routeActionValue, active) VALUES (@routeID, 10, 0, 1);
	
	-- route action type Code Publish API Access
	INSERT routeAction (routeID, routeActionTypeID, routeActionValue, active) VALUES (@routeID, 17, 0, 1);
	
	-- route action type Code Query API Access
	INSERT routeAction (routeID, routeActionTypeID, routeActionValue, active) VALUES (@routeID, 18, 0, 1);
	
	-- route action type Reporting API Access
	INSERT routeAction (routeID,routeActionTypeID,routeActionValue, active) VALUES (@routeID, 19, 0, 1);
	
	SELECT @connectionID AS [connectionID], @connectionGUID AS [connectionGUID];

	COMMIT TRANSACTION

	END TRY

	BEGIN CATCH
        IF @@TRANCOUNT > 0
        	ROLLBACK TRANSACTION;
		THROW;
	END CATCH

END










GO
/****** Object:  StoredProcedure [dbo].[provisionConnectionCodeAssign]    Script Date: 01/11/2023 18:59:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[provisionConnectionCodeAssign]
	@code varchar(15), 
	@connectionID INT,
	@ignoreBlock BIT = 0
AS
BEGIN
	BEGIN TRY

	SET NOCOUNT ON;

	declare @@codeID int;
	declare @@publishStatus BIT;
	declare @@espid AS VARCHAR(10);
	declare @@priority AS INT;
	declare @@deactivated AS BIT;
	declare @@voice AS BIT;
	declare @@assignedCnt AS INT;
	declare @@publishUPDATE AS INT;
	declare @@isShared AS BIT;
	declare @@accountID INT;
	declare @@providerID INT;
	declare @@blocked INT;

	SET @@priority=1;

	BEGIN TRANSACTION

		SET @@codeID = (SELECT codeID FROM code WHERE code = @code);
		SET @@deactivated = (SELECT deactivated FROM code WHERE codeID = @@codeID);
		SET @@assignedCnt = (SELECT COUNT(*) FROM connectionCodeAssign WHERE codeID = @@codeID); -- 0 means not already assign (available)
		SET @@isShared = (SELECT shared FROM code WHERE codeID = @@codeID);
		SET @@accountID = (SELECT accountID FROM connection WHERE connectionID = @connectionID);
		SET @@blocked = 0 -- Default to allow

		IF (@@accountID = 372) -- Blocking CSF Corporation - 1stPoint Communications, LLC (Endstream Communications) FROM provisioning Canadian codes
		BEGIN
			SET @@blocked = ( SELECT COUNT(*) FROM numberCountryNPAExtended WHERE countryCodeNormalized = '1CAN' AND countryCode = LEFT(@code,4) )
		END

		IF (@@accountID = 189) -- Blocking Text My Main Number - Live API FROM provisioning 8XX codes
		BEGIN
			SET @@blocked = ( SELECT COUNT(*) FROM numberCountryNPAExtended WHERE countryCodeNormalized = '18XX' AND countryCode = LEFT(@code,4) )
		END

		-- Blocking MauguChat and Telefinity FROM publishing
		-- Don't allow publishing of deactivated codes
		-- Only publish a code that is already assigned if it is marked as shared
		-- Removing account block for Teli 2019-12-19 [JR]
		IF ((@connectionID NOT IN (488) AND @@accountID NOT IN (0)) OR @ignoreBlock = 1) AND @@deactivated=0 AND (@@blocked = 0 OR @ignoreBlock = 1) AND (@@assignedCnt=0 OR @@isShared=1)
		BEGIN

			SET @@publishUPDATE = (SELECT publishUPDATE FROM code WHERE codeID = @@codeID);
			SET @@publishStatus = (SELECT publishstatus FROM code WHERE codeID = @@codeID);
			SET @@providerID = (SELECT providerID FROM code WHERE codeID = @@codeID);
			SET @@espid = (SELECT espid FROM code WHERE codeID = @@codeID);
			SET @@voice = (SELECT voice FROM code WHERE codeID = @@codeID);

			BEGIN
				INSERT connectionCodeAssign (connectionID, codeID) VALUES (@connectionID, @@codeID);
				UPDATE code SET active=1, available=0, sms=1 WHERE codeID = @@codeID;
				INSERT connectionCodeAssignHistory (connectionID, codeID, action, created) VALUES (@connectionID, @@codeID, 1, getutcdate());
				INSERT cacheConnectionCodeAssign (code, connectionID, cacheStatus) VALUES (@code, @connectionID, 1);
			END

			/*
			IF (@@accountID IN ('11','82') AND @@providerID = 8) -- Blocking TSG FROM publishing new active TF while ZipWhip has them blocked.
			BEGIN
				UPDATE code SET active=0, providerID=999 WHERE codeID = @@codeID;
			END
			*/

			IF @@publishUPDATE > 0 
			BEGIN
				SET @@priority = @@publishUPDATE
			END

			IF @connectionID = 15 
			BEGIN
				SET @@priority = 2
			END

			IF @connectionID IN (365,346,396)
			BEGIN
				SET @@priority = 3
			END

			-- Call-Em-All default PRIMARYuration
			IF @connectionID IN (396,365,346) AND @@voice = 1
			BEGIN
				UPDATE code SET voiceForwardTypeID=3, voiceForwardDestination='message.wav' WHERE codeID = @@codeID;	
			END

			-- SAS2 default voice PRIMARYuration
			IF @connectionID IN (1310) AND @@voice = 1
			BEGIN
				UPDATE code SET voiceForwardTypeID=1, voiceForwardDestination='smssip7560217519402816365@phone.plivo.com' WHERE codeID = @@codeID;	
			END

			-- Openity default voice PRIMARYuration
			IF @@accountID = 60 AND @@voice = 1
			BEGIN
				UPDATE code SET voiceForwardTypeID=1, voiceForwardDestination='proxy1.openity.us' WHERE codeID = @@codeID;	
			END

			-- Plivo MMS connection
			IF @connectionID = 1846 AND @@providerID = 1
			BEGIN
				UPDATE code SET espid='E136', mms=1 WHERE codeID = @@codeID;	
			END

			IF len(@code) = 11 and LEFT(@@espid,1) = 'E' 
			BEGIN
				UPDATE code SET publishstatus=1, publishUPDATE=@@priority WHERE codeID = @@codeID;	
			END

			SELECT 'Completed', @code, @connectionID;

		END
		ELSE
		BEGIN
			SELECT 'Failed', @code, @connectionID, @@deactivated, @@assignedCnt, @@isShared;
		END

	COMMIT TRANSACTION

	END TRY

	BEGIN CATCH
        IF @@TRANCOUNT > 0
        	ROLLBACK TRANSACTION;
		THROW;
	END CATCH
END


GO
/****** Object:  StoredProcedure [dbo].[provisionConnectionCodeAssignByCodeID]    Script Date: 01/11/2023 18:59:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[provisionConnectionCodeAssignByCodeID]
	@connectionID INT, 
	@codeID INT,
	@ignoreBlock BIT = 0
AS
BEGIN

	BEGIN TRY

	SET NOCOUNT ON;

	declare @@code			AS VARCHAR(15);
	declare @@publishStatus AS BIT;
	declare @@espid			AS VARCHAR(10);
	declare @@priority		AS INT;
	declare @@deactivated	AS BIT;

	SET @@priority=1;

	BEGIN TRANSACTION

		SET @@deactivated = (SELECT deactivated FROM code WHERE code = @codeID);

		IF (@connectionID NOT IN (488) OR @ignoreBlock = 1) AND @@deactivated=0
		BEGIN

			SET @@code = (SELECT code FROM code WHERE code = @codeID and deactivated = 0);
			SET @@publishStatus = (SELECT publishstatus FROM code WHERE code = @@code and deactivated = 0);
			SET @@espid = (SELECT espid FROM code WHERE code = @@code);

			INSERT connectionCodeAssign (connectionID, codeID) VALUES (@connectionID, @codeID);
			UPDATE code SET active=1, available=0, sms=1 WHERE codeID = @codeID;
			INSERT connectionCodeAssignHistory (connectionID, codeID, action, created) VALUES (@connectionID, @codeID, 1, getutcdate());
			INSERT cacheConnectionCodeAssign (code, connectionID, cacheStatus) VALUES (@@code, @connectionID, 1);

			IF @connectionID = 15 
			BEGIN
				SET @@priority = 2;
			END

			IF len(@@code) = 11 and LEFT(@@espid,1) = 'E' 
			BEGIN
				UPDATE code SET publishstatus=1, publishupdate=@@priority WHERE codeID = @codeID;	
			END

			SELECT 'Completed', @@code, @connectionID;
		END
		ELSE
		BEGIN
			SELECT 'Failed', @@code, @connectionID;
		END

	COMMIT TRANSACTION

	END TRY

	BEGIN CATCH
        IF @@TRANCOUNT > 0
        	ROLLBACK TRANSACTION;
		THROW;
	END CATCH

END


GO
/****** Object:  StoredProcedure [dbo].[recordCountByAccountID]    Script Date: 01/11/2023 18:59:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[recordCountByAccountID]
	@accountList VARCHAR(255)	-- comma seperated list of accountIDs
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @count INT; 

		SET @count = (SELECT COUNT (accountID) FROM account WHERE accountID IN (SELECT * FROM CSVToTable(@accountList)));
		PRINT 'account:' + CAST(@count AS VARCHAR(10));

		SET @count = (SELECT COUNT (accountContactID) FROM accountContact WHERE accountID IN (SELECT * FROM CSVToTable(@accountList)));
		PRINT 'accountContact:' + CAST(@count AS VARCHAR(10));

		SET @count = (SELECT COUNT (accountRegistrationID) FROM accountRegistration WHERE accountRegistrationID IN ( SELECT accountRegistrationID FROM account where accountID IN (SELECT * FROM CSVToTable(@accountList))));
		PRINT 'accountRegistration:' + CAST(@count AS VARCHAR(10));

		SET @count = (SELECT COUNT (accountUserID) FROM accountUser WHERE accountID IN (SELECT * FROM CSVToTable(@accountList)));
		PRINT 'accountUser:' + CAST(@count AS VARCHAR(10));

		SET @count = (SELECT COUNT (accountUserActionID) FROM accountUserAction WHERE accountUserID IN ( SELECT accountUserID FROM accountUser WHERE accountID IN (SELECT * FROM CSVToTable(@accountList))));
		PRINT 'accountUserAction:' + CAST(@count AS VARCHAR(10));

		SET @count = (SELECT COUNT(blockCodeNumberID) FROM blockCodeNumber WHERE code IN ( SELECT code FROM code WHERE codeID IN ( SELECT codeID FROM connectionCodeAssign WHERE connectionID IN (SELECT connectionID FROM connection WHERE accountID IN (SELECT * FROM CSVToTable(@accountList))))));
		PRINT 'blockCodeNumber:' + CAST(@count AS VARCHAR(10));

		SET @count = (SELECT COUNT (cacheConnectionCodeAssignID) FROM cacheConnectionCodeAssign WHERE connectionID IN (SELECT connectionID FROM connection WHERE accountID IN (SELECT * FROM CSVToTable(@accountList))));
		PRINT 'cacheConnectionCodeAssign:' + CAST(@count AS VARCHAR(10));

		SET @count = (SELECT COUNT (codeRegistrationID) FROM codeRegistration WHERE connectionID IN (SELECT connectionID FROM connection WHERE accountID IN (SELECT * FROM CSVToTable(@accountList))));
		PRINT 'codeRegistration:' + CAST(@count AS VARCHAR(10));

		SET @count = (SELECT COUNT (connectionID) FROM connection WHERE accountID IN (SELECT * FROM CSVToTable(@accountList)));
		PRINT 'connection:' + CAST(@count AS VARCHAR(10));

		SET @count = (SELECT COUNT (connectionID) FROM connectionCodeAssign WHERE connectionID IN (SELECT connectionID FROM connection WHERE accountID IN (SELECT * FROM CSVToTable(@accountList))));
		PRINT 'connectionCodeAssign:' + CAST(@count AS VARCHAR(10));

		SET @count = (SELECT COUNT (credentialID) FROM credential WHERE connectionID IN (SELECT connectionID FROM connection WHERE accountID IN (SELECT * FROM CSVToTable(@accountList))));
		PRINT 'credential:' + CAST(@count AS VARCHAR(10));

		SET @count = (SELECT COUNT (firewallID) FROM firewall WHERE accountID IN (SELECT * FROM CSVToTable(@accountList)));
		PRINT 'firewall:' + CAST(@count AS VARCHAR(10));

		SET @count = (SELECT COUNT (keywordID) FROM keyword WHERE connectionID IN (SELECT connectionID FROM connection WHERE accountID IN (SELECT * FROM CSVToTable(@accountList))));
		PRINT 'keyword:' + CAST(@count AS VARCHAR(10));

		SET @count = (SELECT COUNT (routeID) FROM route WHERE accountID IN (SELECT * FROM CSVToTable(@accountList)));
		PRINT 'route:' + CAST(@count AS VARCHAR(10));

		SET @count = (SELECT COUNT(routeActionID) FROM routeAction WHERE routeID IN (SELECT routeID FROM route WHERE accountID IN (SELECT * FROM CSVToTable(@accountList))));
		PRINT 'routeAction:' + CAST(@count AS VARCHAR(10));

		SET @count = (SELECT COUNT (routeConnectionID) FROM routeConnection WHERE accountID IN (SELECT * FROM CSVToTable(@accountList)));
		PRINT 'routeConnection:' + CAST(@count AS VARCHAR(10));

		SET @count = (SELECT COUNT (connectionID) FROM xTempBulkAction WHERE connectionID IN (SELECT connectionID FROM connection WHERE accountID IN (SELECT * FROM CSVToTable(@accountList))));
		PRINT 'xTempBulkAction:' + CAST(@count AS VARCHAR(10));

END


GO
/****** Object:  StoredProcedure [dbo].[refreshNumberCountryNPAExtended]    Script Date: 01/11/2023 18:59:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[refreshNumberCountryNPAExtended]
AS
BEGIN
	BEGIN TRY

	SET NOCOUNT ON;

	BEGIN TRANSACTION

	DELETE numberCountryNPAExtended;

	INSERT numberCountryNPAExtended (countryCode, countryName, countryCodeNormalized) 
	--SELECT '1' AS countryCode, 'United States of America' AS countryName, '1USA' AS countryCodeNormalized
	--UNION - CANT HAVE BOTH +1 and ALL OF THE +1xxx, it will create duplicate counts
	SELECT countryCode, countryName, convert(varchar(4),countryCode) AS countryCodeNormalized FROM numberCountry WHERE countryCode != '1'
	UNION
	SELECT DISTINCT CONCAT('1',npa) AS countryCode, 'United States of America' AS countryName, '1USA' AS countryCodeNormalized 
		FROM numberAreaPrefix a LEFT JOIN numberState b ON a.stateCodeAlpha2 = b.stateCodeAlpha2
		WHERE countrycodealpha3 = 'USA'
	UNION
	SELECT DISTINCT CONCAT('1',npa) AS countryCode, 'Canada' AS countryName, '1CAN' AS countryCodeNormalized 
		FROM numberAreaPrefix a LEFT JOIN numberState b ON a.stateCodeAlpha2 = b.stateCodeAlpha2
		WHERE countrycodealpha3 = 'CAN'
	UNION
	SELECT countryCode, 'Location Neutral 8XX' AS countryName, '18XX' AS countryCodeNormalized 
	FROM (VALUES ('1800'),('1833'),('1844'),('1855'),('1866'),('1877'),('1888')) x(countryCode)
	UNION
	SELECT countryCode, 'Location Neutral 5XX' AS countryName, '15XX' AS countryCodeNormalized 
	FROM (VALUES ('1500'),('1522'),('1533'),('1544'),('1566'),('1577'),('1588')) x(countryCode)
	--add Trinidad and Tobago AS it is not in the code US/CAN great data file - it is its own COUNTRY, so not grouped with 1USA, 1CAN, or 18XX/15XX
	UNION
	SELECT countryCode, 'Trinidad and Tobago' AS countryName, '1868' AS countryCodeNormalized 
	FROM (VALUES ('1868')) x(countryCode)

	COMMIT TRANSACTION

	END TRY

	BEGIN CATCH
        IF @@TRANCOUNT > 0
        	ROLLBACK TRANSACTION;
		THROW;
	END CATCH

END


GO
/****** Object:  StoredProcedure [dbo].[releaseCode]    Script Date: 01/11/2023 18:59:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[releaseCode]
	@code VARCHAR(50) = '',
	@connectionID INT = 1
AS	 
BEGIN 

	SET NOCOUNT ON 

	DECLARE @status VARCHAR(20);
	DECLARE @accountName VARCHAR(100);
	DECLARE @connectionName VARCHAR(50);
	DECLARE @publishStatus INT;
	DECLARE @itemCode INT;

	DECLARE @SP_Results TABLE
	(
	  result VARCHAR(20)
	)

	SET @accountName = (SELECT name FROM account WHERE accountID = (SELECT accountID FROM connection WHERE connectionID=@connectionID));
	SET @connectionName = (SELECT name FROM connection WHERE connectionID=@connectionID);
	SET @publishStatus = (SELECT publishStatus FROM code WHERE code = @code);
	SET @itemCode = (SELECT itemCode FROM code WHERE code = @code);

	INSERT INTO @SP_Results (result)
	EXEC dbo.deProvisionConnectionCodeAssign @code, @connectionID

	SET @status = (SELECT TOP 1 result FROM @SP_Results)

	IF (@status = 'true' AND @publishStatus = 1 AND @itemCode = 101)
		UPDATE code SET publishStatus=0, publishUpdate=1 WHERE code = @code;
	
	SELECT @accountName [accountName], @connectionName [connectionName], @code [code], @status [result]

END 






GO
/****** Object:  StoredProcedure [dbo].[reportAccountMO]    Script Date: 01/11/2023 18:59:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[reportAccountMO]
AS
BEGIN

DECLARE @cols AS NVARCHAR(MAX),
		@query AS NVARCHAR(MAX)

SELECT @cols = STUFF((
	SELECT ',' + QUOTENAME(CONVERT(VARCHAR(10),RetVal,120)) FROM dbo.CreateDateRange(DATEADD(DAY,-31,dbo.fnStartOfDay(0)), dbo.fnStartOfDay(1), 'DD', 1)
	FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'),1,1,''
)

SET @query =   'SELECT	*
FROM (
	SELECT	MAX(ac.name) AS [account],
			MAX(CONVERT(VARCHAR(11),mo.created,120)) AS [Date],
			COUNT(*) AS [MO] 
	FROM	txnSMSDeliver mo WITH (NOLOCK), account ac WITH (NOLOCK)
	WHERE	(mo.created >= DATEADD(DAY,-31,dbo.fnStartOfDay(0)) AND mo.created < dbo.fnStartOfDay(0))
	AND		esmClass NOT IN (4,8)
	AND		ac.accountID = mo.accountID
	GROUP	BY mo.accountID, CONVERT(VARCHAR(11),mo.created,120)
) AS SourceTable PIVOT (
	AVG([MO]) FOR [Date] IN (
		' + @cols + '
	)
) AS PivotTable
ORDER BY [account]'

execute(@query)

END





GO
/****** Object:  StoredProcedure [dbo].[reportAccountMT]    Script Date: 01/11/2023 18:59:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[reportAccountMT]
AS
BEGIN

DECLARE @cols AS NVARCHAR(MAX),
		@query AS NVARCHAR(MAX)

SELECT @cols = STUFF((
	SELECT ',' + QUOTENAME(CONVERT(VARCHAR(10),RetVal,120)) FROM dbo.CreateDateRange(DATEADD(DAY,-31,dbo.fnStartOfDay(0)), dbo.fnStartOfDay(1), 'DD', 1)
	FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'),1,1,''
)

SET @query =   'SELECT	*
FROM (
	SELECT	MAX([account]) AS [account],
			MAX([date]) AS [date],
			SUM([MT]) AS [mt]
	FROM (
		SELECT	MAX(ac.name) AS [account],
				MAX(CONVERT(VARCHAR(11),mt.created,120)) AS [date],
				COUNT(*) AS [MT] 
		FROM	txnSMSSubmit mt WITH (NOLOCK), account ac WITH (NOLOCK)
		WHERE	(mt.created >= DATEADD(DAY,-31,dbo.fnStartOfDay(0)) AND mt.created < dbo.fnStartOfDay(0))
		AND		ac.accountID = mt.accountID
		GROUP	BY mt.accountID, CONVERT(VARCHAR(11),mt.created,120)
		UNION ALL
		SELECT	MAX(ac.name) AS [account],
				MAX(CONVERT(VARCHAR(11),mt.auditSubmit,120)) AS [date],
				COUNT(*) AS [MT] 
		FROM	SMSMTsubmit mt WITH (NOLOCK), account ac WITH (NOLOCK)
		WHERE	(mt.auditSubmit >= DATEADD(DAY,-31,dbo.fnStartOfDay(0)) AND mt.auditSubmit < dbo.fnStartOfDay(0))
		AND		ac.accountID = mt.accountID
		GROUP	BY mt.accountID, CONVERT(VARCHAR(11),mt.auditSubmit,120)
	) mt
	GROUP BY [account],[date]
) AS SourceTable PIVOT (
	AVG([MT]) FOR [Date] IN (
		' + @cols + '
	)
) AS PivotTable
ORDER BY [account]'

execute(@query)

END




GO
/****** Object:  StoredProcedure [dbo].[republishCode]    Script Date: 01/11/2023 18:59:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[republishCode]
	@code varchar(15)
WITH EXECUTE AS 'dbo' 
AS
BEGIN

	DECLARE @codeID INT;
	DECLARE @inConnection INT = 0;
	DECLARE @publishStatus INT = 0;
	DECLARE @errorMessage VARCHAR(255);

	SET NOCOUNT ON;

	BEGIN TRY

		SET @codeID = (SELECT codeID FROM code WHERE code = @code);
		SET @inConnection = (SELECT COUNT(*) FROM connectionCodeAssign WHERE codeID = @codeID);
		SET @publishStatus = (SELECT publishStatus FROM code WHERE codeID = @codeID);

		PRINT 'In Connection: ' + CAST(@inConnection AS VARCHAR(5));
		PRINT 'Published Status: ' + CAST(@publishStatus AS VARCHAR(5));

		IF (@inConnection > 0) AND (@publishStatus = 1) 
		BEGIN
			UPDATE code SET publishUpdate=3 WHERE codeID = @codeID;
			SELECT 'Success' AS [result], @code AS [code];
		END
		ELSE
		BEGIN
			SELECT 'Failed' AS [result], @code AS [code];
		END

	END TRY
	BEGIN CATCH

		SET @errorMessage = (SELECT LEFT(ERROR_MESSAGE(), 255) AS ErrorMessage);
		PRINT @errorMessage;

		SELECT 'Failed' AS [result], @code AS [code];
	END CATCH
END


GO
/****** Object:  StoredProcedure [dbo].[testprocedure]    Script Date: 01/11/2023 18:59:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[testprocedure] 

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	declare @checkRecord INT

    set @checkRecord = (select count(*) from accountRegistration where accountRegistrationID = 500)

	if @checkRecord = 0
    begin
    raiserror('Registration Record does not exist, is not approved, or is already provisioned!', 18, 1)
    return -1
    end

END





GO
/****** Object:  StoredProcedure [dbo].[txnPurgeStateFarm]    Script Date: 01/11/2023 18:59:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[txnPurgeStateFarm]
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE txnSMSDeliver SET 
		sourceNumber = REPLACE(sourceNumber,SUBSTRING(sourceNumber, 5, 7),'9999999'), sourceNumberNXX = '999',
		messageText = 'PURGED',
		messageData = 0,
		messagePDU = 'PURGED'
	WHERE accountID IN (3,124,125)
	AND created BETWEEN DATEADD (d,-30,GETUTCDATE()) AND DATEADD (d,-33,GETUTCDATE());

	UPDATE txnSMSSubmit SET 
		destinationNumber = REPLACE(destinationNumber,SUBSTRING(destinationNumber, 5, 7),'9999999'), destinationNumberNXX = '999',
		messageText = 'PURGED',
		messageData = 0,
		messagePDU = 'PURGED'
	WHERE accountID IN (3,124,125)
	AND created BETWEEN DATEADD (d,-30,GETUTCDATE()) AND DATEADD (d,-33,GETUTCDATE());

	UPDATE SMSMTsubmit SET 
		destinationNumber = REPLACE(destinationNumber,SUBSTRING(destinationNumber, 5, 7),'9999999'), 
		messageText = 'PURGED',
		messageData = 0
	WHERE accountID IN (3,124,125)
	AND auditSubmit BETWEEN DATEADD (d,-30,GETUTCDATE()) AND DATEADD (d,-33,GETUTCDATE());

END




GO
/****** Object:  StoredProcedure [dbo].[txnVoiceOrigInsert]    Script Date: 01/11/2023 18:59:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[txnVoiceOrigInsert]
	@providerID					INT,
	@sipServer					VARCHAR(50),
	@cdrGUID					VARCHAR(36),
	@sourceNumber				VARCHAR(15),
	@sourceIPAddress			VARCHAR(20),
	@destinationCode			VARCHAR(15),
	@providerName				VARCHAR(50),
	@created					DATETIME,
	@completed					DATETIME,
	@duration					INT,
	@terminationCauseID			INT,
	@terminationCauseMessage	VARCHAR(250),
	@forwardType				VARCHAR(15)
AS	 
BEGIN 

-- Using NOCOUNT to reduce traffic and load on the system.
SET NOCOUNT ON 

INSERT	INTO dbo.txnVoiceOrig (
		[accountID],
		[connectionID],
		[providerID],
		[sipServer],
		[cdrGUID],
		[sourceNumber],
		[sourceNumberCountryCode],
		[sourceNumberNPA],
		[sourceNumberNXX],
		[sourceIPAddress],
		[destinationCode],
		[destinationCountryCode],
		[destinationCodeNPA],
		[destinationCodeNXX],
		[providerName],
		[created],
		[completed],
		[duration],
		[terminationCauseID],
		[terminationCauseMessage],
		[forwardType],
		[archived]
) 
SELECT	ISNULL(cn.accountID, 0) AS [accountID],
		ISNULL(cn.connectionID, 0) AS [connectionID],
		@providerID AS [providerID],
		@sipServer AS [sipServer],
		@cdrGUID AS [cdrGUID],
		@sourceNumber AS [sourceNumber],
		(SELECT TOP 1 countryCode FROM numberCountry WHERE LEFT(@sourceNumber, LEN(countryCode)) = CAST(countryCode AS VARCHAR(5))) AS [sourceNumberCountryCode],
		CASE 
			WHEN LEFT(@sourceNumber,1) = '1' THEN SUBSTRING(@sourceNumber,2,3) 
			ELSE NULL
		END AS [sourceNumberNPA],
		CASE 
			WHEN LEFT(@sourceNumber,1) = '1' THEN SUBSTRING(@sourceNumber,5,3) 
			ELSE NULL
		END AS [sourceNumberNXX],
		@sourceIPAddress AS [sourceIPAddress],
		@destinationCode AS [destinationCode],
		(SELECT countryCode FROM numberCountry WHERE LEFT(@destinationCode, LEN(countryCode)) = countryCode) AS [destinationCountryCode],
		CASE 
			WHEN LEFT(@destinationCode,1) = '1' THEN SUBSTRING(@destinationCode,2,3) 
			ELSE NULL
		END AS [destinationCodeNPA],
		CASE 
			WHEN LEFT(@destinationCode,1) = '1' THEN SUBSTRING(@destinationCode,5,3) 
			ELSE NULL
		END AS [destinationCodeNXX],
		@providerName AS [providerName],
		@created AS [created],
		@completed AS [completed],
		@duration AS [duration],
		@terminationCauseID AS [terminationCauseID],
		@terminationCauseMessage AS [terminationCauseMessage],
		@forwardType AS [forwardType],
		0 AS [archived]
FROM	dbo.code cd WITH (NOLOCK)
		LEFT JOIN dbo.connectionCodeAssign cna WITH (NOLOCK)
			ON cd.codeID = cna.codeID
		LEFT JOIN dbo.connection cn WITH (NOLOCK)
			ON cna.connectionID = cn.connectionID
WHERE	cd.code = @destinationCode

END 












GO
/****** Object:  StoredProcedure [dbo].[txnVoiceTermInsert]    Script Date: 01/11/2023 18:59:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[txnVoiceTermInsert]
	@providerID					INT,
	@sipServer					VARCHAR(50),
	@cdrGUID					VARCHAR(36),
	@sourceCode					VARCHAR(15),
	@sourceIPAddress			VARCHAR(20),
	@destinationIPAddress		VARCHAR(20),
	@destinationNumber			VARCHAR(15),
	@providerName				VARCHAR(50),
	@created					DATETIME,
	@completed					DATETIME,
	@duration					INT,
	@terminationCauseID			INT,
	@terminationCauseMessage	VARCHAR(250),
	@forwardType				VARCHAR(15)
AS	 
BEGIN 

-- Using NOCOUNT to reduce traffic and load on the system.
SET NOCOUNT ON 

INSERT	INTO dbo.txnVoiceTerm (
		[accountID],
		[connectionID],
		[providerID],
		[sipServer],
		[cdrGUID],
		[sourceCode],
		[sourceCountryCode],
		[sourceCodeNPA],
		[sourceCodeNXX],
		[sourceIPAddress],
		[destinationIPAddress],
		[destinationNumber],
		[destinationCountryCode],
		[destinationNumberNPA],
		[destinationNumberNXX],
		[providerName],
		[created],
		[completed],
		[duration],
		[terminationCauseID],
		[terminationCauseMessage],
		[forwardType],
		[archived]
) 
SELECT	ISNULL(cn.accountID, 0) AS [accountID],
		ISNULL(cn.connectionID, 0) AS [connectionID],
		@providerID AS [providerID],
		@sipServer AS [sipServer],
		@cdrGUID AS [cdrGUID],
		@sourceCode AS [sourceCode],
		(SELECT TOP 1 countryCode FROM numberCountry WHERE LEFT(@sourceCode, LEN(countryCode)) = CAST(countryCode AS VARCHAR(5))) AS [sourceNumberCountryCode],
		CASE 
			WHEN LEFT(@sourceCode,1) = '1' THEN SUBSTRING(@sourceCode,2,3) 
			ELSE NULL
		END AS [sourceNumberNPA],
		CASE 
			WHEN LEFT(@sourceCode,1) = '1' THEN SUBSTRING(@sourceCode,5,3) 
			ELSE NULL
		END AS [sourceNumberNXX],
		@sourceIPAddress AS [sourceIPAddress],
		@destinationIPAddress AS [destinationIPAddress],
		@destinationNumber AS [destinationCode],
		(SELECT countryCode FROM numberCountry WHERE LEFT(@destinationNumber, LEN(countryCode)) = countryCode) AS [destinationCountryCode],
		CASE 
			WHEN LEFT(@destinationNumber,1) = '1' THEN SUBSTRING(@destinationNumber,2,3) 
			ELSE NULL
		END AS [destinationCodeNPA],
		CASE 
			WHEN LEFT(@destinationNumber,1) = '1' THEN SUBSTRING(@destinationNumber,5,3) 
			ELSE NULL
		END AS [destinationCodeNXX],
		@providerName AS [providerName],
		@created AS [created],
		@completed AS [completed],
		@duration AS [duration],
		@terminationCauseID AS [terminationCauseID],
		@terminationCauseMessage AS [terminationCauseMessage],
		@forwardType AS [forwardType],
		0 AS [archived]
FROM	dbo.code cd WITH (NOLOCK)
		LEFT JOIN dbo.connectionCodeAssign cna WITH (NOLOCK)
			ON cd.codeID = cna.codeID
		LEFT JOIN dbo.connection cn WITH (NOLOCK)
			ON cna.connectionID = cn.connectionID
WHERE	cd.code = @sourceCode

END 














GO
/****** Object:  StoredProcedure [dbo].[unPublishInactiveCodes]    Script Date: 01/11/2023 18:59:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[unPublishInactiveCodes]
AS	 
BEGIN 
	-- Using NOCOUNT to reduce traffic and load on the system.
	SET NOCOUNT ON 

	DECLARE @codeList AS CURSOR;
	DECLARE @code AS VARCHAR(50);
	DECLARE @codeID AS INT;
	DECLARE	@espid AS VARCHAR(10);
	DECLARE @count AS INT;

	SET @count = 0;
	
	SET @codeList = CURSOR FOR
		SELECT	c.codeID, 
				c.code, 
				c.espid
		FROM	connectionCodeAssignHistory ch1 
		JOIN	code c
			ON	c.codeID = ch1.codeID
		LEFT JOIN	connectionCodeAssignHistory ch2 
			ON	ch2.codeID = ch1.codeID
				AND ch2.created > ch1.created
		LEFT JOIN	connectionCodeAssign ca
			ON	c.codeID = ca.codeID
		LEFT JOIN	connection cn
			ON ca.connectionID = cn.connectionID
		WHERE	ch2.codeID IS NULL
		AND		c.publishStatus = 1
		AND		c.espid NOT IN ('E0B2','E0B3')
		AND		cn.connectionID IS NULL
		AND		ch1.created <= DATEADD(HOUR,-12,GETUTCDATE())


	FETCH NEXT FROM @codeList INTO @codeID, @code, @espid

	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @count = @count + 1;

		PRINT 'codeID: '+CAST(@codeID AS CHAR(5)) + ', code: ' + @code + ', espid: ' + @espid;

		FETCH NEXT FROM @codeList INTO @codeID, @code, @espid
	END

	PRINT CAST(@count AS CHAR(5)) + ' records affected';

	CLOSE @codeList;

END 



GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'0 - friendly format mode, 1 = international format of number expected' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'connection', @level2type=N'COLUMN',@level2name=N'destinationNumberFormat'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'ITU CC' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'numberOperatorNetNumber', @level2type=N'COLUMN',@level2name=N'countryCode'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'ISO2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'numberOperatorNetNumber', @level2type=N'COLUMN',@level2name=N'countryAbbreviation'
GO
USE [master]
GO
ALTER DATABASE [gateway_v5] SET  READ_WRITE 
GO
