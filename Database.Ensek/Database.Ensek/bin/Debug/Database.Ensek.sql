/*
Deployment script for Database.Ensek

This code was generated by a tool.
Changes to this file may cause incorrect behavior and will be lost if
the code is regenerated.
*/

GO
SET ANSI_NULLS, ANSI_PADDING, ANSI_WARNINGS, ARITHABORT, CONCAT_NULL_YIELDS_NULL, QUOTED_IDENTIFIER ON;

SET NUMERIC_ROUNDABORT OFF;


GO
:setvar DatabaseName "Database.Ensek"
:setvar DefaultFilePrefix "Database.Ensek"
:setvar DefaultDataPath "C:\Users\sha01869\AppData\Local\Microsoft\VisualStudio\SSDT\Ensek"
:setvar DefaultLogPath "C:\Users\sha01869\AppData\Local\Microsoft\VisualStudio\SSDT\Ensek"

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

/*

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

	*/
GO

GO
PRINT N'Update complete.';


GO
