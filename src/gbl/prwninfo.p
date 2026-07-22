block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: prwninfo.p $
$Archive: gbl/prwninfo.p $

Возвращает информацию о сессиях progress, запущенных на компьютере

Автор: Перваков Михаил Сергеевич
Дата создания: 04/05/06
Author: Mikhail Pervakov
Creation date: 04/05/06

*/

{ gbl/prwnshow.i }

define output parameter table for temp-prwninfo .
define output parameter table for temp-prwnprocinfo .


define stream sinp .

&GLOB PROCESS_QUERY_INFORMATION 1024
&GLOB PROCESS_VM_READ 16
&GLOB MAX_PATH 260



procedure GetProcessName :

  define input  parameter pid            as integer   no-undo .
  define output parameter p-process-name as character no-undo .
  define output parameter p-file-name    as character no-undo .

  define variable hProcess      as integer   no-undo .
  define variable hModule       as integer   no-undo .
  define variable cbNeeded      as integer   no-undo .
  define variable lphMod        as memptr    no-undo .
  define variable vProcessName  as char      no-undo .
  define variable RetVal        as integer   no-undo .

  do
  on error undo, return error return-value
  :
    RUN OpenProcess
      (input  {&PROCESS_QUERY_INFORMATION} + {&PROCESS_VM_READ}
      ,input  0
      ,input  PID
      ,output hProcess
      ).

    assign
      vProcessName = "unknown" + FILL(" ", {&MAX_PATH})
    .
    IF hProcess <> 0
    THEN DO:
      assign
        SET-SIZE (lphMod) = 4
      .
      RUN EnumProcessModules
        (input  hProcess
        ,input  GET-POINTER-VALUE(lphMod)
        ,input  GET-SIZE(lphMod)
        ,output cbNeeded
        ,output RetVal
        ).
      IF RetVal NE 0
      THEN DO:
        assign
          hModule = GET-LONG(lphMod,1)
        .
      END.
      else do:
        assign
          hModule = ?
        .
      end.
      assign
        SET-SIZE (lphMod) = 0
      .
      if hModule <> ?
      then do:
        run GetModuleBaseNameA
          (input  hProcess
          ,input  hModule
          ,output vProcessName
          ,input  LENGTH(vProcessName)
          ,output RetVal
          ).
        assign
          vProcessName = SUBSTRING(vProcessName,1,RetVal)
        .

          define variable cfilename as character no-undo .
          assign
            cfilename = "unknown" + FILL(" ", {&MAX_PATH})
          .

        run GetModuleFileNameExA
          (input  hProcess
          ,input  hModule
          ,output cFileName
          ,input  LENGTH(cFileName)
          ,output RetVal
          ).
        assign
          cFileName = substring(cFileName,1,RetVal)
        .
      end.

      run CloseHandle
        (input  hProcess
        ,output RetVal
        ).
    end.

    assign
      p-process-name = TRIM(vProcessName)
      p-file-name    = TRIM(cFileName)
    .
  end.

end procedure. /* GetProcessName */


/******************  MAIN BLOCK *******************/
define variable vpid          as integer   no-undo.
define variable vpidlist      as memptr    no-undo.
define variable cbneeded      as integer   no-undo.
define variable vretval       as integer   no-undo.

/* считываем информацию о поддерживаемых версиях progress */
define variable v-progress-version as character no-undo .
define variable v-procedure-handle as character no-undo .
define variable v-pgc              as character no-undo .
define variable v-pdb-task         as character no-undo .
define variable v-savename         as character no-undo .
define variable v-the-display      as character no-undo .
define variable v-wic-max-id       as character no-undo .

input stream sinp from value(search("cmp/procinrm.txt")) .
repeat :
  assign
    v-progress-version = ""
    v-procedure-handle = ""
    v-pgc              = ""
    v-pdb-task         = ""
    v-savename         = ""
    v-the-display      = ""
    v-wic-max-id       = ""
  .

  import stream sinp
    v-progress-version
    v-procedure-handle
    v-pgc
    v-pdb-task
    v-savename
    v-the-display
    v-wic-max-id
    .

  if v-progress-version <> ""
  then do:
    find first temp-progress-version-info
      where temp-progress-version-info.progress-version = v-progress-version
      no-error .
    if not available temp-progress-version-info
    then do:
      create temp-progress-version-info .
      assign
        temp-progress-version-info.progress-version = v-progress-version
      .
    end.
    assign
      temp-progress-version-info.procedure-handle = v-procedure-handle
      temp-progress-version-info.pgc              = v-pgc
      temp-progress-version-info.pdb-task         = v-pdb-task
      temp-progress-version-info.savename         = v-savename
      temp-progress-version-info.the-display      = v-the-display
      temp-progress-version-info.wic-max-id       = v-wic-max-id
    .
  end.
end.
input stream sinp close .


assign
  set-size(vpidlist) = 1000
.

define variable v-current-id as integer   no-undo .
run GetCurrentProcessID (output v-current-id) .

run enumprocesses
  (input get-pointer-value(vpidlist)
  ,input get-size(vpidlist)
  ,output cbneeded
  ,output vretval
  ).


define variable v-ind as integer   no-undo .
do v-ind = 1 to cbneeded / 4
:
  assign
    vPID = GET-LONG(vPidList, 4 * (v-ind - 1) + 1)
  .

  define variable v-process-name as character no-undo .
  define variable v-file-name    as character no-undo .

  run getprocessname in this-procedure
    (input  vpid
    ,output v-process-name
    ,output v-file-name
    ) .

  if v-process-name = "prowin32.exe"
  then do:
    create temp-prwninfo .
    assign
      temp-prwninfo.proc-id          = vpid
      temp-prwninfo.module-file-name = v-file-name
    .
    if temp-prwninfo.proc-id = v-current-id
    then do:
      assign
        temp-prwninfo.progress-self = true
      .
    end.
    else do:
      assign
        temp-prwninfo.progress-self = false
      .
    end.

    /* определяем версию Progress */
    /* открываем и считываем информацию из файла version */
    define variable v-path as character no-undo .
    assign
      v-path = substring(v-file-name, 1, r-index(v-file-name, '\') - 1)
      v-path = substring(v-path, 1, r-index(v-path, '\') - 1)
    .

    define stream sinp .
    input stream sinp from value( v-path + '/':u + 'version':u) .
    define variable v-imp1 as character no-undo .
    define variable v-imp2 as character no-undo .
    define variable v-imp3 as character no-undo .
    import stream sinp v-imp1 v-imp2 v-imp3 .
    input stream sinp close .

    assign
      temp-prwninfo.progress-version = v-imp3
    .

    find first temp-progress-version-info
      where temp-progress-version-info.progress-version = temp-prwninfo.progress-version
      no-error .
    if available temp-progress-version-info
    then do:
      define variable v-progress-propath as character no-undo .
      define variable v-trans-active     as logical   no-undo .
      define variable v-ini-file         as character no-undo .
      define variable v-widget-num       as integer   no-undo .
      define variable v-max-widget-num   as integer   no-undo .

      run gbl/procinrm.p
        (input  temp-progress-version-info.progress-version
        ,input  temp-progress-version-info.procedure-handle
        ,input  temp-progress-version-info.pgc
        ,input  temp-progress-version-info.pdb-task
        ,input  temp-progress-version-info.savename
        ,input  temp-progress-version-info.the-display
        ,input  temp-progress-version-info.wic-max-id
        ,input  temp-prwninfo.proc-id
        ,output v-progress-propath
        ,output v-trans-active
        ,output v-ini-file
        ,output v-widget-num
        ,output v-max-widget-num
        ,output table temp-procinfo
        ) .

      assign
        temp-prwninfo.progress-propath = v-progress-propath
        temp-prwninfo.trans-active     = v-trans-active
        temp-prwninfo.progress-inifile = v-ini-file
        temp-prwninfo.widget-num       = v-widget-num
        temp-prwninfo.max-widget-num   = v-max-widget-num
      .

      assign
        temp-prwninfo.widget-percent = min((abs(temp-prwninfo.widget-num) * 100.0)
                                           / temp-prwninfo.max-widget-num
                                          ,100
                                          )
      .

      find first temp-procinfo
        where temp-procinfo.proc-level = 1
        no-error .
      if available temp-procinfo
      then do:
        assign
          temp-prwninfo.proc-name   = temp-procinfo.proc-name
          temp-prwninfo.proc-line   = temp-procinfo.proc-line
          temp-prwninfo.r-code-name = temp-procinfo.r-code-name
        .
      end.

      define variable v-new-proc-level as integer   no-undo .

      assign
        v-new-proc-level = 0
      .

      for each temp-procinfo
      on error undo, return error return-value
      by temp-procinfo.proc-level descending
      :
        assign
          v-new-proc-level = v-new-proc-level + 1
        .

        create temp-prwnprocinfo .
        buffer-copy temp-procinfo to temp-prwnprocinfo
        assign
          temp-prwnprocinfo.proc-level = v-new-proc-level
          temp-prwnprocinfo.proc-id    = temp-prwninfo.proc-id
        .
      end.
    end.
  end.
end.

assign
  SET-SIZE(vPidList) = 0
.

/*define variable v-test1 as character no-undo .*/
/*define variable v-test2 as character no-undo .*/

/*run GetProductVersion in this-procedure*/
/*  (input "c:\dlc83e\bin\prowin32.exe"*/
/*  ,output v-test1*/
/*  ,output v-test2*/
/*  ) .*/
/*message*/
/*  v-test1 skip*/
/*  v-test2 skip*/
/*  view-as alert-box error .*/

run gbl/windinfo.p
  (output table temp-window
  ) .


for each temp-window
  where temp-window.window-visible    = true
    and temp-window.window-class-name = "#32770"
:

  find first temp-prwninfo
    where temp-prwninfo.proc-id = temp-window.window-process-id
    no-error .
  if available temp-prwninfo
  then do:
    assign
      temp-prwninfo.message-handle = temp-window.window-handle
      temp-prwninfo.message-text   = temp-window.window-message-text
    .
  end.

end.


PROCEDURE GetProductVersion :

    DEFINE INPUT  PARAMETER pFilename       AS CHAR NO-UNDO.
    DEFINE OUTPUT PARAMETER pProductVersion AS CHAR NO-UNDO.
    DEFINE OUTPUT PARAMETER pFileVersion    AS CHAR NO-UNDO.

    DEF VAR dummy           AS INTEGER NO-UNDO.
    DEF VAR ReturnValue     AS INTEGER NO-UNDO.
    DEF VAR lpVersionInfo   AS MEMPTR  NO-UNDO.  /* VS_VERSION_INFO structure  */
    DEF VAR lpFixedFileInfo AS MEMPTR  NO-UNDO.  /* VS_FIXEDFILEINFO structure */
    DEF VAR versize         AS INTEGER NO-UNDO.  /* size of lpVersionInfo      */
    DEF VAR ptrInfo         AS INTEGER NO-UNDO.  /* address of lpFixedFileInfo */
    DEF VAR cInfo           AS INTEGER NO-UNDO.  /* size of lpFixedFileInfo    */

    RUN GetFileVersionInfoSizeA (pFileName,
                                 OUTPUT dummy,
                                 OUTPUT versize).

    IF versize = 0 THEN RETURN.

    assign
      SET-SIZE(lpVersionInfo) = 0
    .
    assign
      SET-SIZE(lpVersionInfo) = versize
    .

    RUN GetFileVersionInfoA ( pFileName,
                              0,
                              INPUT versize,
                              INPUT GET-POINTER-VALUE(lpVersionInfo),
                              OUTPUT returnvalue).

    IF returnvalue = 0 THEN DO:
      SET-SIZE(lpVersionInfo) = 0.
      RETURN.
    END.

    RUN VerQueryValueA (GET-POINTER-VALUE(lpVersionInfo),
                        "\":U,
                        OUTPUT ptrInfo,
                        OUTPUT cInfo,
                        OUTPUT returnvalue).

    IF NOT (returnvalue=0 OR cInfo=0) THEN DO:
/*       SET-SIZE(lpFixedFileInfo)          = cInfo.*/
       assign
         SET-POINTER-VALUE(lpFixedFileInfo) = ptrInfo
       .

       pProductVersion =  STRING(GET-SHORT (lpFixedFileInfo,19)) + '.' +
                          STRING(GET-SHORT (lpFixedFileInfo,17)) + '.' +
                          STRING(GET-SHORT (lpFixedFileInfo,23)) + '.' +
                          STRING(GET-SHORT (lpFixedFileInfo,21)).

       pFileVersion    =  STRING(GET-SHORT (lpFixedFileInfo,11)) + '.' +
                          STRING(GET-SHORT (lpFixedFileInfo, 9)) + '.' +
                          STRING(GET-SHORT (lpFixedFileInfo,15)) + '.' +
                          STRING(GET-SHORT (lpFixedFileInfo,13)).

    END.

    SET-SIZE (lpVersionInfo)   = 0.

/*  ------ DON'T DO THIS: --------
    SET-SIZE (lpFixedFileInfo) = 0. */

END PROCEDURE.


PROCEDURE GetCurrentProcessId EXTERNAL "kernel32.dll" :
  DEFINE RETURN PARAMETER RetVal          AS LONG.
END PROCEDURE.

PROCEDURE CloseHandle EXTERNAL "kernel32.dll" :
  DEFINE INPUT  PARAMETER hObject AS LONG.
  DEFINE RETURN PARAMETER RetVal  AS LONG.
END PROCEDURE.

PROCEDURE OpenProcess EXTERNAL "kernel32.dll" :
  DEFINE INPUT  PARAMETER dwDesiredAccess AS LONG.
  DEFINE INPUT  PARAMETER bInheritHandle  AS LONG.
  DEFINE INPUT  PARAMETER dwProcessId     AS LONG.
  DEFINE RETURN PARAMETER hProcess        AS LONG.
END PROCEDURE.


PROCEDURE ReadProcessMemory EXTERNAL "kernel32.dll" :
  DEFINE INPUT  PARAMETER hProcess            AS LONG.
  DEFINE INPUT  PARAMETER lpBaseAddress       AS LONG.
  DEFINE INPUT  PARAMETER lpBuffer            AS LONG.
  DEFINE INPUT  PARAMETER nSize               AS LONG.
  DEFINE INPUT  PARAMETER lpNumberOfBytesRead AS LONG.
  DEFINE RETURN PARAMETER RetVal  AS LONG.
END PROCEDURE.

PROCEDURE GetModuleFileNameA EXTERNAL "kernel32.dll" :
  DEFINE INPUT  PARAMETER hModule    AS LONG.
  DEFINE OUTPUT PARAMETER lpFilename AS CHAR.
  DEFINE INPUT  PARAMETER nSize      AS LONG.
  DEFINE RETURN PARAMETER ReturnSize AS LONG.
END PROCEDURE.

PROCEDURE GetModuleFileNameExA EXTERNAL "psapi.dll" :
  DEFINE INPUT  PARAMETER hProcess   AS LONG.
  DEFINE INPUT  PARAMETER hModule    AS LONG.
  DEFINE OUTPUT PARAMETER lpFilename AS CHAR.
  DEFINE INPUT  PARAMETER nSize      AS LONG.
  DEFINE RETURN PARAMETER ReturnSize AS LONG.
END PROCEDURE.

PROCEDURE EnumProcesses EXTERNAL "psapi.dll" :
  DEFINE INPUT  PARAMETER vPidListProcess AS LONG.
  DEFINE INPUT  PARAMETER cb              AS LONG.
  DEFINE OUTPUT PARAMETER cbNeeded        AS LONG.
  DEFINE RETURN PARAMETER RetVal          AS LONG.
END PROCEDURE.

PROCEDURE EnumProcessModules EXTERNAL "psapi.dll" :
  DEFINE INPUT  PARAMETER hProcess    AS LONG.
  DEFINE INPUT  PARAMETER lphModule   AS LONG.
  DEFINE INPUT  PARAMETER cb          AS LONG.
  DEFINE OUTPUT PARAMETER cbNeeded    AS LONG.
  DEFINE RETURN PARAMETER RetVal AS LONG.
END PROCEDURE.

PROCEDURE GetModuleBaseNameA EXTERNAL "psapi.dll" :
  DEFINE INPUT  PARAMETER hProcess      AS LONG.
  DEFINE INPUT  PARAMETER hModule       AS LONG.
  DEFINE OUTPUT PARAMETER lpBaseName    AS CHAR.
  DEFINE INPUT  PARAMETER nSize         AS LONG.
  DEFINE RETURN PARAMETER nReturnedSize AS LONG.
END PROCEDURE.



PROCEDURE GetFileVersionInfoSizeA EXTERNAL "version.dll" :
  DEFINE INPUT  PARAMETER lptstrFilename  AS CHARACTER.
  DEFINE OUTPUT PARAMETER lpdwHandle      AS LONG.
  DEFINE RETURN PARAMETER VersionInfoSize AS LONG.
END PROCEDURE.


PROCEDURE GetFileVersionInfoA EXTERNAL "version.dll" :
  DEFINE INPUT  PARAMETER lptstrFilename  AS CHARACTER.
  DEFINE INPUT  PARAMETER dwHandle        AS LONG.
  DEFINE INPUT  PARAMETER dwLen           AS LONG.
  DEFINE INPUT  PARAMETER lpData          AS LONG.
  DEFINE RETURN PARAMETER ReturnValue     AS LONG.
END PROCEDURE.


PROCEDURE VerQueryValueA EXTERNAL "version.dll" :
  DEFINE INPUT  PARAMETER lpBlock     AS LONG.
  DEFINE INPUT  PARAMETER lpSubBlock  AS CHARACTER.
  DEFINE OUTPUT PARAMETER lplpBuffer  AS LONG.
  DEFINE OUTPUT PARAMETER puLen       AS LONG.
  DEFINE RETURN PARAMETER ReturnValue AS LONG.
END PROCEDURE.