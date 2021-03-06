/*
Deployment script for Ensek_Test

This code was generated by a tool.
Changes to this file may cause incorrect behavior and will be lost if
the code is regenerated.
*/

GO
SET ANSI_NULLS, ANSI_PADDING, ANSI_WARNINGS, ARITHABORT, CONCAT_NULL_YIELDS_NULL, QUOTED_IDENTIFIER ON;

SET NUMERIC_ROUNDABORT OFF;


GO
:setvar DatabaseName "Ensek_Test"
:setvar DefaultFilePrefix "Ensek_Test"
:setvar DefaultDataPath "C:\Program Files\Microsoft SQL Server\MSSQL13.SQLEXPRESS\MSSQL\DATA\"
:setvar DefaultLogPath "C:\Program Files\Microsoft SQL Server\MSSQL13.SQLEXPRESS\MSSQL\DATA\"

GO
:on error exit
GO
/*
Detect SQLCMD mode and disable script execution if SQLCMD mode is not supported.
To re-enable the script after enabling SQLCMD mode, execute the following:
SET NOEXEC OFF; 
*/
:setvar __IsSqlCmdEnabled "True"
GO
IF N'$(__IsSqlCmdEnabled)' NOT LIKE N'True'
    BEGIN
        PRINT N'SQLCMD mode must be enabled to successfully execute this script.';
        SET NOEXEC ON;
    END


GO
USE [$(DatabaseName)];


GO
PRINT N'Creating [dbo].[Meter_Readings]...';


GO
CREATE TABLE [dbo].[Meter_Readings] (
    [AccountId]            INT           NOT NULL,
    [MeterReadingDateTime] DATETIME2 (7) NOT NULL,
    [MeterReadValue]       FLOAT (53)    NOT NULL,
    CONSTRAINT [PK_Meter_Readings] PRIMARY KEY CLUSTERED ([AccountId] ASC, [MeterReadingDateTime] ASC) ON [PRIMARY]
) ON [PRIMARY];


GO
PRINT N'Creating [dbo].[Test_Accounts]...';


GO
CREATE TABLE [dbo].[Test_Accounts] (
    [AccountId] INT          NOT NULL,
    [FirstName] VARCHAR (50) NOT NULL,
    [LastName]  VARCHAR (50) NOT NULL,
    PRIMARY KEY CLUSTERED ([AccountId] ASC)
);


GO
PRINT N'Creating unnamed constraint on [dbo].[Meter_Readings]...';


GO
ALTER TABLE [dbo].[Meter_Readings] WITH NOCHECK
    ADD FOREIGN KEY ([AccountId]) REFERENCES [dbo].[Test_Accounts] ([AccountId]);


GO
PRINT N'Creating <unnamed>...';


GO
ALTER TABLE [dbo].[Meter_Readings] WITH NOCHECK
    ADD FOREIGN KEY ([AccountId]) REFERENCES [dbo].[Test_Accounts] ([AccountId]);


GO

INSERT INTO dbo.Test_Accounts (AccountId,FirstName,LastName)
VALUES  (2344,'Tommy','Test'),
		(2233,'Barry','Test'),
		(8766,'Sally','Test'),
		(2345,'Jerry','Test'),
		(2346,'Ollie','Test'),
		(2347,'Tara','Test'),
		(2348,'Tammy','Test'),
		(2349,'Simon','Test'),
		(2350,'Colin','Test'),
		(2351,'Gladys','Test'),
		(2352,'Greg','Test'),
		(2353,'Tony','Test'),
		(2355,'Arthur','Test'),
		(2356,'Craig','Test'),
		(6776,'Laura','Test'),
		(4534,'JOSH','Test'),
		(1234,'Freya','Test'),
		(1239,'Noddy','Test'),
		(1240,'Archie','Test'),
		(1241,'Lara','Test'),
		(1242,'Tim','Test'),
		(1243,'Graham','Test'),
		(1244,'Tony','Test'),
		(1245,'Neville','Test'),
		(1246,'Jo','Test'),
		(1247,'Jim','Test'),
		(1248,'Pam','Test')

	--INSERT INTO dbo.Test_Accounts (AccountId,FirstName,LastName)
	--SELECT
	--	AccountId,
	--	MIN(FirstName)FirstName,
	--	MIN(LastName)LastName
	--FROM #Test_Accounts
	--	GROUP BY AccountId
GO

GO
PRINT N'Checking existing data against newly created constraints';


GO
USE [$(DatabaseName)];


GO
CREATE TABLE [#__checkStatus] (
    id           INT            IDENTITY (1, 1) PRIMARY KEY CLUSTERED,
    [Schema]     NVARCHAR (256),
    [Table]      NVARCHAR (256),
    [Constraint] NVARCHAR (256)
);

SET NOCOUNT ON;

DECLARE tableconstraintnames CURSOR LOCAL FORWARD_ONLY
    FOR SELECT SCHEMA_NAME([schema_id]),
               OBJECT_NAME([parent_object_id]),
               [name],
               0
        FROM   [sys].[objects]
        WHERE  [parent_object_id] IN (OBJECT_ID(N'dbo.Meter_Readings'))
               AND [type] IN (N'F', N'C')
                   AND [object_id] IN (SELECT [object_id]
                                       FROM   [sys].[check_constraints]
                                       WHERE  [is_not_trusted] <> 0
                                              AND [is_disabled] = 0
                                       UNION
                                       SELECT [object_id]
                                       FROM   [sys].[foreign_keys]
                                       WHERE  [is_not_trusted] <> 0
                                              AND [is_disabled] = 0);

DECLARE @schemaname AS NVARCHAR (256);

DECLARE @tablename AS NVARCHAR (256);

DECLARE @checkname AS NVARCHAR (256);

DECLARE @is_not_trusted AS INT;

DECLARE @statement AS NVARCHAR (1024);

BEGIN TRY
    OPEN tableconstraintnames;
    FETCH tableconstraintnames INTO @schemaname, @tablename, @checkname, @is_not_trusted;
    WHILE @@fetch_status = 0
        BEGIN
            PRINT N'Checking constraint: ' + @checkname + N' [' + @schemaname + N'].[' + @tablename + N']';
            SET @statement = N'ALTER TABLE [' + @schemaname + N'].[' + @tablename + N'] WITH ' + CASE @is_not_trusted WHEN 0 THEN N'CHECK' ELSE N'NOCHECK' END + N' CHECK CONSTRAINT [' + @checkname + N']';
            BEGIN TRY
                EXECUTE [sp_executesql] @statement;
            END TRY
            BEGIN CATCH
                INSERT  [#__checkStatus] ([Schema], [Table], [Constraint])
                VALUES                  (@schemaname, @tablename, @checkname);
            END CATCH
            FETCH tableconstraintnames INTO @schemaname, @tablename, @checkname, @is_not_trusted;
        END
END TRY
BEGIN CATCH
    PRINT ERROR_MESSAGE();
END CATCH

IF CURSOR_STATUS(N'LOCAL', N'tableconstraintnames') >= 0
    CLOSE tableconstraintnames;

IF CURSOR_STATUS(N'LOCAL', N'tableconstraintnames') = -1
    DEALLOCATE tableconstraintnames;

SELECT N'Constraint verification failed:' + [Schema] + N'.' + [Table] + N',' + [Constraint]
FROM   [#__checkStatus];

IF @@ROWCOUNT > 0
    BEGIN
        DROP TABLE [#__checkStatus];
        RAISERROR (N'An error occurred while verifying constraints', 16, 127);
    END

SET NOCOUNT OFF;

DROP TABLE [#__checkStatus];


GO
PRINT N'Update complete.';


GO
