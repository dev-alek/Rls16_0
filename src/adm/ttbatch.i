define temp-table tt-BatchProcess
 field BP_Type as char
 field CharKey_One as char
 field CharKey_Two as char
 field CharKey_Three as char
 field BP_ExecSysDate as date
 field BP_ExecSysTimeInt as int
 index dt BP_ExecSysDate BP_ExecSysTimeInt.