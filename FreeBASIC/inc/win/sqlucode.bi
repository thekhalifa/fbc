''
''
'' sqlucode -- header translated with help of SWIG FB wrapper
''
'' NOTICE: This file is part of the FreeBASIC Compiler package and can't
''         be included in other distributions without authorization.
''
''
#ifndef __sqlucode_bi__
#define __sqlucode_bi__

#include once "win/sqlext.bi"

#define SQL_WCHAR (-8)
#define SQL_WVARCHAR (-9)
#define SQL_WLONGVARCHAR (-10)
#define SQL_C_WCHAR (-8)
#define SQL_C_TCHAR 1
#define SQL_SQLSTATE_SIZEW 10

#ifdef __USE_UNICODE 
declare function SQLColAttribute alias "SQLColAttributeW" (byval hstmt as SQLHSTMT, byval iCol as SQLUSMALLINT, byval iField as SQLUSMALLINT, byval pCharAttr as SQLPOINTER, byval cbCharAttrMax as SQLSMALLINT, byval pcbCharAttr as SQLSMALLINT ptr, byval pNumAttr as SQLPOINTER) as SQLRETURN
declare function SQLColAttributes alias "SQLColAttributesW" (byval hstmt as SQLHSTMT, byval icol as SQLUSMALLINT, byval fDescType as SQLUSMALLINT, byval rgbDesc as SQLPOINTER, byval cbDescMax as SQLSMALLINT, byval pcbDesc as SQLSMALLINT ptr, byval pfDesc as SQLINTEGER ptr) as SQLRETURN
declare function SQLConnect alias "SQLConnectW" (byval hdbc as SQLHDBC, byval szDSN as SQLWCHAR ptr, byval cbDSN as SQLSMALLINT, byval szUID as SQLWCHAR ptr, byval cbUID as SQLSMALLINT, byval szAuthStr as SQLWCHAR ptr, byval cbAuthStr as SQLSMALLINT) as SQLRETURN
declare function SQLDescribeCol alias "SQLDescribeColW" (byval hstmt as SQLHSTMT, byval icol as SQLUSMALLINT, byval szColName as SQLWCHAR ptr, byval cbColNameMax as SQLSMALLINT, byval pcbColName as SQLSMALLINT ptr, byval pfSqlType as SQLSMALLINT ptr, byval pcbColDef as SQLUINTEGER ptr, byval pibScale as SQLSMALLINT ptr, byval pfNullable as SQLSMALLINT ptr) as SQLRETURN
declare function SQLError alias "SQLErrorW" (byval henv as SQLHENV, byval hdbc as SQLHDBC, byval hstmt as SQLHSTMT, byval szSqlState as SQLWCHAR ptr, byval pfNativeError as SQLINTEGER ptr, byval szErrorMsg as SQLWCHAR ptr, byval cbErrorMsgMax as SQLSMALLINT, byval pcbErrorMsg as SQLSMALLINT ptr) as SQLRETURN
declare function SQLExecDirect alias "SQLExecDirectW" (byval hstmt as SQLHSTMT, byval szSqlStr as SQLWCHAR ptr, byval cbSqlStr as SQLINTEGER) as SQLRETURN
declare function SQLGetConnectAttr alias "SQLGetConnectAttrW" (byval hdbc as SQLHDBC, byval fAttribute as SQLINTEGER, byval rgbValue as SQLPOINTER, byval cbValueMax as SQLINTEGER, byval pcbValue as SQLINTEGER ptr) as SQLRETURN
declare function SQLGetCursorName alias "SQLGetCursorNameW" (byval hstmt as SQLHSTMT, byval szCursor as SQLWCHAR ptr, byval cbCursorMax as SQLSMALLINT, byval pcbCursor as SQLSMALLINT ptr) as SQLRETURN
declare function SQLSetDescField alias "SQLSetDescFieldW" (byval DescriptorHandle as SQLHDESC, byval RecNumber as SQLSMALLINT, byval FieldIdentifier as SQLSMALLINT, byval Value as SQLPOINTER, byval BufferLength as SQLINTEGER) as SQLRETURN
declare function SQLGetDescField alias "SQLGetDescFieldW" (byval hdesc as SQLHDESC, byval iRecord as SQLSMALLINT, byval iField as SQLSMALLINT, byval rgbValue as SQLPOINTER, byval cbValueMax as SQLINTEGER, byval pcbValue as SQLINTEGER ptr) as SQLRETURN
declare function SQLGetDescRec alias "SQLGetDescRecW" (byval hdesc as SQLHDESC, byval iRecord as SQLSMALLINT, byval szName as SQLWCHAR ptr, byval cbNameMax as SQLSMALLINT, byval pcbName as SQLSMALLINT ptr, byval pfType as SQLSMALLINT ptr, byval pfSubType as SQLSMALLINT ptr, byval pLength as SQLINTEGER ptr, byval pPrecision as SQLSMALLINT ptr, byval pScale as SQLSMALLINT ptr, byval pNullable as SQLSMALLINT ptr) as SQLRETURN
declare function SQLGetDiagField alias "SQLGetDiagFieldW" (byval fHandleType as SQLSMALLINT, byval handle as SQLHANDLE, byval iRecord as SQLSMALLINT, byval fDiagField as SQLSMALLINT, byval rgbDiagInfo as SQLPOINTER, byval cbDiagInfoMax as SQLSMALLINT, byval pcbDiagInfo as SQLSMALLINT ptr) as SQLRETURN
declare function SQLGetDiagRec alias "SQLGetDiagRecW" (byval fHandleType as SQLSMALLINT, byval handle as SQLHANDLE, byval iRecord as SQLSMALLINT, byval szSqlState as SQLWCHAR ptr, byval pfNativeError as SQLINTEGER ptr, byval szErrorMsg as SQLWCHAR ptr, byval cbErrorMsgMax as SQLSMALLINT, byval pcbErrorMsg as SQLSMALLINT ptr) as SQLRETURN
declare function SQLPrepare alias "SQLPrepareW" (byval hstmt as SQLHSTMT, byval szSqlStr as SQLWCHAR ptr, byval cbSqlStr as SQLINTEGER) as SQLRETURN
declare function SQLSetConnectAttr alias "SQLSetConnectAttrW" (byval hdbc as SQLHDBC, byval fAttribute as SQLINTEGER, byval rgbValue as SQLPOINTER, byval cbValue as SQLINTEGER) as SQLRETURN
declare function SQLSetCursorName alias "SQLSetCursorNameW" (byval hstmt as SQLHSTMT, byval szCursor as SQLWCHAR ptr, byval cbCursor as SQLSMALLINT) as SQLRETURN
declare function SQLColumns alias "SQLColumnsW" (byval hstmt as SQLHSTMT, byval szCatalogName as SQLWCHAR ptr, byval cbCatalogName as SQLSMALLINT, byval szSchemaName as SQLWCHAR ptr, byval cbSchemaName as SQLSMALLINT, byval szTableName as SQLWCHAR ptr, byval cbTableName as SQLSMALLINT, byval szColumnName as SQLWCHAR ptr, byval cbColumnName as SQLSMALLINT) as SQLRETURN
declare function SQLGetConnectOption alias "SQLGetConnectOptionW" (byval hdbc as SQLHDBC, byval fOption as SQLUSMALLINT, byval pvParam as SQLPOINTER) as SQLRETURN
declare function SQLGetInfo alias "SQLGetInfoW" (byval hdbc as SQLHDBC, byval fInfoType as SQLUSMALLINT, byval rgbInfoValue as SQLPOINTER, byval cbInfoValueMax as SQLSMALLINT, byval pcbInfoValue as SQLSMALLINT ptr) as SQLRETURN
declare function SQLGetTypeInfo alias "SQLGetTypeInfoW" (byval StatementHandle as SQLHSTMT, byval DataType as SQLSMALLINT) as SQLRETURN
declare function SQLSetConnectOption alias "SQLSetConnectOptionW" (byval hdbc as SQLHDBC, byval fOption as SQLUSMALLINT, byval vParam as SQLUINTEGER) as SQLRETURN
declare function SQLSpecialColumns alias "SQLSpecialColumnsW" (byval hstmt as SQLHSTMT, byval fColType as SQLUSMALLINT, byval szCatalogName as SQLWCHAR ptr, byval cbCatalogName as SQLSMALLINT, byval szSchemaName as SQLWCHAR ptr, byval cbSchemaName as SQLSMALLINT, byval szTableName as SQLWCHAR ptr, byval cbTableName as SQLSMALLINT, byval fScope as SQLUSMALLINT, byval fNullable as SQLUSMALLINT) as SQLRETURN
declare function SQLStatistics alias "SQLStatisticsW" (byval hstmt as SQLHSTMT, byval szCatalogName as SQLWCHAR ptr, byval cbCatalogName as SQLSMALLINT, byval szSchemaName as SQLWCHAR ptr, byval cbSchemaName as SQLSMALLINT, byval szTableName as SQLWCHAR ptr, byval cbTableName as SQLSMALLINT, byval fUnique as SQLUSMALLINT, byval fAccuracy as SQLUSMALLINT) as SQLRETURN
declare function SQLTables alias "SQLTablesW" (byval hstmt as SQLHSTMT, byval szCatalogName as SQLWCHAR ptr, byval cbCatalogName as SQLSMALLINT, byval szSchemaName as SQLWCHAR ptr, byval cbSchemaName as SQLSMALLINT, byval szTableName as SQLWCHAR ptr, byval cbTableName as SQLSMALLINT, byval szTableType as SQLWCHAR ptr, byval cbTableType as SQLSMALLINT) as SQLRETURN
declare function SQLDataSources alias "SQLDataSourcesW" (byval henv as SQLHENV, byval fDirection as SQLUSMALLINT, byval szDSN as SQLWCHAR ptr, byval cbDSNMax as SQLSMALLINT, byval pcbDSN as SQLSMALLINT ptr, byval szDescription as SQLWCHAR ptr, byval cbDescriptionMax as SQLSMALLINT, byval pcbDescription as SQLSMALLINT ptr) as SQLRETURN
declare function SQLDriverConnect alias "SQLDriverConnectW" (byval hdbc as SQLHDBC, byval hwnd as SQLHWND, byval szConnStrIn as SQLWCHAR ptr, byval cbConnStrIn as SQLSMALLINT, byval szConnStrOut as SQLWCHAR ptr, byval cbConnStrOutMax as SQLSMALLINT, byval pcbConnStrOut as SQLSMALLINT ptr, byval fDriverCompletion as SQLUSMALLINT) as SQLRETURN
declare function SQLBrowseConnect alias "SQLBrowseConnectW" (byval hdbc as SQLHDBC, byval szConnStrIn as SQLWCHAR ptr, byval cbConnStrIn as SQLSMALLINT, byval szConnStrOut as SQLWCHAR ptr, byval cbConnStrOutMax as SQLSMALLINT, byval pcbConnStrOut as SQLSMALLINT ptr) as SQLRETURN
declare function SQLColumnPrivileges alias "SQLColumnPrivilegesW" (byval hstmt as SQLHSTMT, byval szCatalogName as SQLWCHAR ptr, byval cbCatalogName as SQLSMALLINT, byval szSchemaName as SQLWCHAR ptr, byval cbSchemaName as SQLSMALLINT, byval szTableName as SQLWCHAR ptr, byval cbTableName as SQLSMALLINT, byval szColumnName as SQLWCHAR ptr, byval cbColumnName as SQLSMALLINT) as SQLRETURN
declare function SQLGetStmtAttr alias "SQLGetStmtAttrW" (byval hstmt as SQLHSTMT, byval fAttribute as SQLINTEGER, byval rgbValue as SQLPOINTER, byval cbValueMax as SQLINTEGER, byval pcbValue as SQLINTEGER ptr) as SQLRETURN
declare function SQLSetStmtAttr alias "SQLSetStmtAttrW" (byval hstmt as SQLHSTMT, byval fAttribute as SQLINTEGER, byval rgbValue as SQLPOINTER, byval cbValueMax as SQLINTEGER) as SQLRETURN
declare function SQLForeignKeys alias "SQLForeignKeysW" (byval hstmt as SQLHSTMT, byval szPkCatalogName as SQLWCHAR ptr, byval cbPkCatalogName as SQLSMALLINT, byval szPkSchemaName as SQLWCHAR ptr, byval cbPkSchemaName as SQLSMALLINT, byval szPkTableName as SQLWCHAR ptr, byval cbPkTableName as SQLSMALLINT, byval szFkCatalogName as SQLWCHAR ptr, byval cbFkCatalogName as SQLSMALLINT, byval szFkSchemaName as SQLWCHAR ptr, byval cbFkSchemaName as SQLSMALLINT, byval szFkTableName as SQLWCHAR ptr, byval cbFkTableName as SQLSMALLINT) as SQLRETURN
declare function SQLNativeSql alias "SQLNativeSqlW" (byval hdbc as SQLHDBC, byval szSqlStrIn as SQLWCHAR ptr, byval cbSqlStrIn as SQLINTEGER, byval szSqlStr as SQLWCHAR ptr, byval cbSqlStrMax as SQLINTEGER, byval pcbSqlStr as SQLINTEGER ptr) as SQLRETURN
declare function SQLPrimaryKeys alias "SQLPrimaryKeysW" (byval hstmt as SQLHSTMT, byval szCatalogName as SQLWCHAR ptr, byval cbCatalogName as SQLSMALLINT, byval szSchemaName as SQLWCHAR ptr, byval cbSchemaName as SQLSMALLINT, byval szTableName as SQLWCHAR ptr, byval cbTableName as SQLSMALLINT) as SQLRETURN
declare function SQLProcedureColumns alias "SQLProcedureColumnsW" (byval hstmt as SQLHSTMT, byval szCatalogName as SQLWCHAR ptr, byval cbCatalogName as SQLSMALLINT, byval szSchemaName as SQLWCHAR ptr, byval cbSchemaName as SQLSMALLINT, byval szProcName as SQLWCHAR ptr, byval cbProcName as SQLSMALLINT, byval szColumnName as SQLWCHAR ptr, byval cbColumnName as SQLSMALLINT) as SQLRETURN
declare function SQLProcedures alias "SQLProceduresW" (byval hstmt as SQLHSTMT, byval szCatalogName as SQLWCHAR ptr, byval cbCatalogName as SQLSMALLINT, byval szSchemaName as SQLWCHAR ptr, byval cbSchemaName as SQLSMALLINT, byval szProcName as SQLWCHAR ptr, byval cbProcName as SQLSMALLINT) as SQLRETURN
declare function SQLTablePrivileges alias "SQLTablePrivilegesW" (byval hstmt as SQLHSTMT, byval szCatalogName as SQLWCHAR ptr, byval cbCatalogName as SQLSMALLINT, byval szSchemaName as SQLWCHAR ptr, byval cbSchemaName as SQLSMALLINT, byval szTableName as SQLWCHAR ptr, byval cbTableName as SQLSMALLINT) as SQLRETURN
declare function SQLDrivers alias "SQLDriversW" (byval henv as SQLHENV, byval fDirection as SQLUSMALLINT, byval szDriverDesc as SQLWCHAR ptr, byval cbDriverDescMax as SQLSMALLINT, byval pcbDriverDesc as SQLSMALLINT ptr, byval szDriverAttributes as SQLWCHAR ptr, byval cbDrvrAttrMax as SQLSMALLINT, byval pcbDrvrAttr as SQLSMALLINT ptr) as SQLRETURN
#else 
declare function SQLColAttribute alias "SQLColAttributeA" (byval hstmt as SQLHSTMT, byval iCol as SQLSMALLINT, byval iField as SQLSMALLINT, byval pCharAttr as SQLPOINTER, byval cbCharAttrMax as SQLSMALLINT, byval pcbCharAttr as SQLSMALLINT ptr, byval pNumAttr as SQLPOINTER) as SQLRETURN
declare function SQLColAttributes alias "SQLColAttributesA" (byval hstmt as SQLHSTMT, byval icol as SQLUSMALLINT, byval fDescType as SQLUSMALLINT, byval rgbDesc as SQLPOINTER, byval cbDescMax as SQLSMALLINT, byval pcbDesc as SQLSMALLINT ptr, byval pfDesc as SQLINTEGER ptr) as SQLRETURN
declare function SQLConnect alias "SQLConnectA" (byval hdbc as SQLHDBC, byval szDSN as string, byval cbDSN as SQLSMALLINT, byval szUID as string, byval cbUID as SQLSMALLINT, byval szAuthStr as string, byval cbAuthStr as SQLSMALLINT) as SQLRETURN
declare function SQLDescribeCol alias "SQLDescribeColA" (byval hstmt as SQLHSTMT, byval icol as SQLUSMALLINT, byval szColName as string, byval cbColNameMax as SQLSMALLINT, byval pcbColName as SQLSMALLINT ptr, byval pfSqlType as SQLSMALLINT ptr, byval pcbColDef as SQLUINTEGER ptr, byval pibScale as SQLSMALLINT ptr, byval pfNullable as SQLSMALLINT ptr) as SQLRETURN
declare function SQLError alias "SQLErrorA" (byval henv as SQLHENV, byval hdbc as SQLHDBC, byval hstmt as SQLHSTMT, byval szSqlState as string, byval pfNativeError as SQLINTEGER ptr, byval szErrorMsg as string, byval cbErrorMsgMax as SQLSMALLINT, byval pcbErrorMsg as SQLSMALLINT ptr) as SQLRETURN
declare function SQLExecDirect alias "SQLExecDirectA" (byval hstmt as SQLHSTMT, byval szSqlStr as string, byval cbSqlStr as SQLINTEGER) as SQLRETURN
declare function SQLGetConnectAttr alias "SQLGetConnectAttrA" (byval hdbc as SQLHDBC, byval fAttribute as SQLINTEGER, byval rgbValue as SQLPOINTER, byval cbValueMax as SQLINTEGER, byval pcbValue as SQLINTEGER ptr) as SQLRETURN
declare function SQLGetCursorName alias "SQLGetCursorNameA" (byval hstmt as SQLHSTMT, byval szCursor as string, byval cbCursorMax as SQLSMALLINT, byval pcbCursor as SQLSMALLINT ptr) as SQLRETURN
declare function SQLGetDescField alias "SQLGetDescFieldA" (byval hdesc as SQLHDESC, byval iRecord as SQLSMALLINT, byval iField as SQLSMALLINT, byval rgbValue as SQLPOINTER, byval cbValueMax as SQLINTEGER, byval pcbValue as SQLINTEGER ptr) as SQLRETURN
declare function SQLGetDescRec alias "SQLGetDescRecA" (byval hdesc as SQLHDESC, byval iRecord as SQLSMALLINT, byval szName as string, byval cbNameMax as SQLSMALLINT, byval pcbName as SQLSMALLINT ptr, byval pfType as SQLSMALLINT ptr, byval pfSubType as SQLSMALLINT ptr, byval pLength as SQLINTEGER ptr, byval pPrecision as SQLSMALLINT ptr, byval pScale as SQLSMALLINT ptr, byval pNullable as SQLSMALLINT ptr) as SQLRETURN
declare function SQLGetDiagField alias "SQLGetDiagFieldA" (byval fHandleType as SQLSMALLINT, byval handle as SQLHANDLE, byval iRecord as SQLSMALLINT, byval fDiagField as SQLSMALLINT, byval rgbDiagInfo as SQLPOINTER, byval cbDiagInfoMax as SQLSMALLINT, byval pcbDiagInfo as SQLSMALLINT ptr) as SQLRETURN
declare function SQLGetDiagRec alias "SQLGetDiagRecA" (byval fHandleType as SQLSMALLINT, byval handle as SQLHANDLE, byval iRecord as SQLSMALLINT, byval szSqlState as string, byval pfNativeError as SQLINTEGER ptr, byval szErrorMsg as string, byval cbErrorMsgMax as SQLSMALLINT, byval pcbErrorMsg as SQLSMALLINT ptr) as SQLRETURN
declare function SQLGetStmtAttr alias "SQLGetStmtAttrA" (byval hstmt as SQLHSTMT, byval fAttribute as SQLINTEGER, byval rgbValue as SQLPOINTER, byval cbValueMax as SQLINTEGER, byval pcbValue as SQLINTEGER ptr) as SQLRETURN
declare function SQLGetTypeInfo alias "SQLGetTypeInfoA" (byval StatementHandle as SQLHSTMT, byval DataTyoe as SQLSMALLINT) as SQLRETURN
declare function SQLPrepare alias "SQLPrepareA" (byval hstmt as SQLHSTMT, byval szSqlStr as string, byval cbSqlStr as SQLINTEGER) as SQLRETURN
declare function SQLSetConnectAttr alias "SQLSetConnectAttrA" (byval hdbc as SQLHDBC, byval fAttribute as SQLINTEGER, byval rgbValue as SQLPOINTER, byval cbValue as SQLINTEGER) as SQLRETURN
declare function SQLSetCursorName alias "SQLSetCursorNameA" (byval hstmt as SQLHSTMT, byval szCursor as string, byval cbCursor as SQLSMALLINT) as SQLRETURN
declare function SQLColumns alias "SQLColumnsA" (byval hstmt as SQLHSTMT, byval szCatalogName as string, byval cbCatalogName as SQLSMALLINT, byval szSchemaName as string, byval cbSchemaName as SQLSMALLINT, byval szTableName as string, byval cbTableName as SQLSMALLINT, byval szColumnName as string, byval cbColumnName as SQLSMALLINT) as SQLRETURN
declare function SQLGetConnectOption alias "SQLGetConnectOptionA" (byval hdbc as SQLHDBC, byval fOption as SQLUSMALLINT, byval pvParam as SQLPOINTER) as SQLRETURN
declare function SQLGetInfo alias "SQLGetInfoA" (byval hdbc as SQLHDBC, byval fInfoType as SQLUSMALLINT, byval rgbInfoValue as SQLPOINTER, byval cbInfoValueMax as SQLSMALLINT, byval pcbInfoValue as SQLSMALLINT ptr) as SQLRETURN
declare function SQLGetStmtOption alias "SQLGetStmtOptionA" (byval hstmt as SQLHSTMT, byval fOption as SQLUSMALLINT, byval pvParam as SQLPOINTER) as SQLRETURN
declare function SQLSetConnectOption alias "SQLSetConnectOptionA" (byval hdbc as SQLHDBC, byval fOption as SQLUSMALLINT, byval vParam as SQLUINTEGER) as SQLRETURN
declare function SQLSetStmtOption alias "SQLSetStmtOptionA" (byval hstmt as SQLHSTMT, byval fOption as SQLUSMALLINT, byval vParam as SQLUINTEGER) as SQLRETURN
declare function SQLSpecialColumns alias "SQLSpecialColumnsA" (byval hstmt as SQLHSTMT, byval fColType as SQLUSMALLINT, byval szCatalogName as string, byval cbCatalogName as SQLSMALLINT, byval szSchemaName as string, byval cbSchemaName as SQLSMALLINT, byval szTableName as string, byval cbTableName as SQLSMALLINT, byval fScope as SQLUSMALLINT, byval fNullable as SQLUSMALLINT) as SQLRETURN
declare function SQLStatistics alias "SQLStatisticsA" (byval hstmt as SQLHSTMT, byval szCatalogName as string, byval cbCatalogName as SQLSMALLINT, byval szSchemaName as string, byval cbSchemaName as SQLSMALLINT, byval szTableName as string, byval cbTableName as SQLSMALLINT, byval fUnique as SQLUSMALLINT, byval fAccuracy as SQLUSMALLINT) as SQLRETURN
declare function SQLTables alias "SQLTablesA" (byval hstmt as SQLHSTMT, byval szCatalogName as string, byval cbCatalogName as SQLSMALLINT, byval szSchemaName as string, byval cbSchemaName as SQLSMALLINT, byval szTableName as string, byval cbTableName as SQLSMALLINT, byval szTableType as string, byval cbTableType as SQLSMALLINT) as SQLRETURN
declare function SQLDataSources alias "SQLDataSourcesA" (byval henv as SQLHENV, byval fDirection as SQLUSMALLINT, byval szDSN as string, byval cbDSNMax as SQLSMALLINT, byval pcbDSN as SQLSMALLINT ptr, byval szDescription as string, byval cbDescriptionMax as SQLSMALLINT, byval pcbDescription as SQLSMALLINT ptr) as SQLRETURN
declare function SQLDriverConnect alias "SQLDriverConnectA" (byval hdbc as SQLHDBC, byval hwnd as SQLHWND, byval szConnStrIn as string, byval cbConnStrIn as SQLSMALLINT, byval szConnStrOut as string, byval cbConnStrOutMax as SQLSMALLINT, byval pcbConnStrOut as SQLSMALLINT ptr, byval fDriverCompletion as SQLUSMALLINT) as SQLRETURN
declare function SQLBrowseConnect alias "SQLBrowseConnectA" (byval hdbc as SQLHDBC, byval szConnStrIn as string, byval cbConnStrIn as SQLSMALLINT, byval szConnStrOut as string, byval cbConnStrOutMax as SQLSMALLINT, byval pcbConnStrOut as SQLSMALLINT ptr) as SQLRETURN
declare function SQLColumnPrivileges alias "SQLColumnPrivilegesA" (byval hstmt as SQLHSTMT, byval szCatalogName as string, byval cbCatalogName as SQLSMALLINT, byval szSchemaName as string, byval cbSchemaName as SQLSMALLINT, byval szTableName as string, byval cbTableName as SQLSMALLINT, byval szColumnName as string, byval cbColumnName as SQLSMALLINT) as SQLRETURN
declare function SQLDescribeParam alias "SQLDescribeParamA" (byval hstmt as SQLHSTMT, byval ipar as SQLUSMALLINT, byval pfSqlType as SQLSMALLINT ptr, byval pcbParamDef as SQLUINTEGER ptr, byval pibScale as SQLSMALLINT ptr, byval pfNullable as SQLSMALLINT ptr) as SQLRETURN
declare function SQLForeignKeys alias "SQLForeignKeysA" (byval hstmt as SQLHSTMT, byval szPkCatalogName as string, byval cbPkCatalogName as SQLSMALLINT, byval szPkSchemaName as string, byval cbPkSchemaName as SQLSMALLINT, byval szPkTableName as string, byval cbPkTableName as SQLSMALLINT, byval szFkCatalogName as string, byval cbFkCatalogName as SQLSMALLINT, byval szFkSchemaName as string, byval cbFkSchemaName as SQLSMALLINT, byval szFkTableName as string, byval cbFkTableName as SQLSMALLINT) as SQLRETURN
declare function SQLNativeSql alias "SQLNativeSqlA" (byval hdbc as SQLHDBC, byval szSqlStrIn as string, byval cbSqlStrIn as SQLINTEGER, byval szSqlStr as string, byval cbSqlStrMax as SQLINTEGER, byval pcbSqlStr as SQLINTEGER ptr) as SQLRETURN
declare function SQLPrimaryKeys alias "SQLPrimaryKeysA" (byval hstmt as SQLHSTMT, byval szCatalogName as string, byval cbCatalogName as SQLSMALLINT, byval szSchemaName as string, byval cbSchemaName as SQLSMALLINT, byval szTableName as string, byval cbTableName as SQLSMALLINT) as SQLRETURN
declare function SQLProcedureColumns alias "SQLProcedureColumnsA" (byval hstmt as SQLHSTMT, byval szCatalogName as string, byval cbCatalogName as SQLSMALLINT, byval szSchemaName as string, byval cbSchemaName as SQLSMALLINT, byval szProcName as string, byval cbProcName as SQLSMALLINT, byval szColumnName as string, byval cbColumnName as SQLSMALLINT) as SQLRETURN
declare function SQLProcedures alias "SQLProceduresA" (byval hstmt as SQLHSTMT, byval szCatalogName as string, byval cbCatalogName as SQLSMALLINT, byval szSchemaName as string, byval cbSchemaName as SQLSMALLINT, byval szProcName as string, byval cbProcName as SQLSMALLINT) as SQLRETURN
declare function SQLTablePrivileges alias "SQLTablePrivilegesA" (byval hstmt as SQLHSTMT, byval szCatalogName as string, byval cbCatalogName as SQLSMALLINT, byval szSchemaName as string, byval cbSchemaName as SQLSMALLINT, byval szTableName as string, byval cbTableName as SQLSMALLINT) as SQLRETURN
declare function SQLDrivers alias "SQLDriversA" (byval henv as SQLHENV, byval fDirection as SQLUSMALLINT, byval szDriverDesc as string, byval cbDriverDescMax as SQLSMALLINT, byval pcbDriverDesc as SQLSMALLINT ptr, byval szDriverAttributes as string, byval cbDrvrAttrMax as SQLSMALLINT, byval pcbDrvrAttr as SQLSMALLINT ptr) as SQLRETURN
#endif ' __USE_UNICODE

#endif '__sqlucode_bi__
