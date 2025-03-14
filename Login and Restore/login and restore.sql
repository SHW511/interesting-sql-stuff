CREATE TRIGGER trg_AutoCreateLogin
ON ALL SERVER
FOR LOGON
AS
BEGIN
    DECLARE @LoginName NVARCHAR(100) = ORIGINAL_LOGIN();
    DECLARE @SQL NVARCHAR(MAX);
    DECLARE @DatabaseName NVARCHAR(100) = 'DB_' + @LoginName;

    -- Check if login exists
    IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = @LoginName)
    BEGIN
        -- Create login
        SET @SQL = 'CREATE LOGIN [' + @LoginName + '] WITH PASSWORD = ''Student@123'', DEFAULT_DATABASE = [' + @DatabaseName + ']';
        EXEC sp_executesql @SQL;

        -- Restore database from a template backup
        SET @SQL = 'RESTORE DATABASE [' + @DatabaseName + '] FROM DISK = ''C:\SQLBackups\TemplateDB.bak'' 
                    WITH MOVE ''TemplateDB_Data'' TO ''C:\SQLData\' + @DatabaseName + '.mdf'', 
                         MOVE ''TemplateDB_Log'' TO ''C:\SQLLogs\' + @DatabaseName + '.ldf''';
        EXEC sp_executesql @SQL;

        -- Create a database user mapped to the login
        SET @SQL = 'USE [' + @DatabaseName + ']; CREATE USER [' + @LoginName + '] FOR LOGIN [' + @LoginName + ']; ALTER ROLE db_owner ADD MEMBER [' + @LoginName + '];';
        EXEC sp_executesql @SQL;
    END
END;
GO
