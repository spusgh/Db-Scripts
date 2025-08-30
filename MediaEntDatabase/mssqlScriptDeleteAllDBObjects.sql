-- Disable foreign key constraints
EXEC sp_msforeachtable "ALTER TABLE ? NOCHECK CONSTRAINT ALL"

-- Drop all foreign key constraints
DECLARE @sql NVARCHAR(MAX) = N''
SELECT @sql += 'ALTER TABLE [' + OBJECT_SCHEMA_NAME(parent_object_id) + '].[' + OBJECT_NAME(parent_object_id) + '] DROP CONSTRAINT [' + name + '];' + CHAR(13)
FROM sys.foreign_keys
EXEC sp_executesql @sql

-- Drop all views
SET @sql = ''
SELECT @sql += 'DROP VIEW [' + SCHEMA_NAME(schema_id) + '].[' + name + '];' + CHAR(13)
FROM sys.views
EXEC sp_executesql @sql

-- Drop all stored procedures
SET @sql = ''
SELECT @sql += 'DROP PROCEDURE [' + SCHEMA_NAME(schema_id) + '].[' + name + '];' + CHAR(13)
FROM sys.procedures
EXEC sp_executesql @sql

-- Drop all functions
SET @sql = ''
SELECT @sql += 'DROP FUNCTION [' + SCHEMA_NAME(schema_id) + '].[' + name + '];' + CHAR(13)
FROM sys.objects
WHERE type IN ('FN', 'IF', 'TF')
EXEC sp_executesql @sql

-- Drop all triggers
-- Drop all functions (scalar, inline, table-valued)
SET @sql = ''
SELECT @sql += 'DROP FUNCTION [' + OBJECT_SCHEMA_NAME(object_id) + '].[' + name + '];' + CHAR(13)
FROM sys.objects
WHERE type IN ('FN', 'IF', 'TF')
EXEC sp_executesql @sql

-- Drop all tables
EXEC sp_msforeachtable "DROP TABLE ?"

-- Drop user-defined types (optional)
SET @sql = ''
SELECT @sql += 'DROP TYPE [' + SCHEMA_NAME(schema_id) + '].[' + name + '];' + CHAR(13)
FROM sys.types
WHERE is_user_defined = 1
EXEC sp_executesql @sql
