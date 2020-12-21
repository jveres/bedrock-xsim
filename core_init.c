
/* init extensions */

int core_init(const char* dummy)
{
	int nErr = 0;
	nErr += sqlite3_auto_extension((void(*)())sqlite3_percentile_init);
	nErr += sqlite3_auto_extension((void(*)())sqlite3_regexp_init);
	nErr += sqlite3_auto_extension((void(*)())sqlite3_uuid_init);
#ifndef SQLITE_OMIT_VIRTUALTABLE
	nErr += sqlite3_auto_extension((void(*)())sqlite3_series_init);
#endif
	return nErr ? SQLITE_ERROR : SQLITE_OK;
}
