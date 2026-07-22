block-level on error undo, throw.
define input  parameter p-drive       as character no-undo .
define input  parameter p-unit       as character no-undo .
define output parameter p-free-space  as decimal   no-undo .
define output parameter p-total-space as decimal   no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: volspace.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/volspace.p $":U .
define variable vss-description as character no-undo init "".
procedure vss-get-info :
  define output parameter p-vss-revision    like vss-revision    no-undo .
  define output parameter p-vss-author      like vss-author      no-undo .
  define output parameter p-vss-date        like vss-date        no-undo .
  define output parameter p-vss-workfile    like vss-workfile    no-undo .
  define output parameter p-vss-archive     like vss-archive     no-undo .
  define output parameter p-vss-description like vss-description no-undo .
  assign
    p-vss-revision    = vss-revision
    p-vss-author      = vss-author
    p-vss-date        = vss-date
    p-vss-workfile    = vss-workfile
    p-vss-archive     = vss-archive
    p-vss-description = vss-description
  .
end procedure.
procedure vss-get-parameters :
  define output parameter p-vss-parameters as character no-undo .
end procedure.
define new global shared variable g#vssrevis-logger as handle    no-undo .
define variable v-vssrevis-logevent                 as logical   no-undo init false .
define variable v-vssrevis-logger                   as handle    no-undo .
procedure vss-logevent :
  define input  parameter p-extra-paramters as character no-undo .
  define variable v-vssrevis-parameters as character no-undo .
  do
  on error undo, return error return-value
  :
    if  valid-handle(v-vssrevis-logger)
    and v-vssrevis-logger :get-signature("logevent") <> ""
    then do:
      run vss-get-parameters in this-procedure
        (output v-vssrevis-parameters
        ).
      run logevent in v-vssrevis-logger
        (input vss-workfile
        ,input vss-revision
        ,input v-vssrevis-parameters
        ,input p-extra-paramters
        ).
    end.
  end.
end procedure.
assign
  v-vssrevis-logger = g#vssrevis-logger
.
if  valid-handle(v-vssrevis-logger)
and v-vssrevis-logger :get-signature("logevent") <> ""
then do:
  assign
    v-vssrevis-logevent = true
  .
  run vss-logevent in this-procedure (input vss-description) .
end.
FUNCTION get64BitValue RETURNS DECIMAL
    (INPUT m64 AS MEMPTR) FORWARD.
FUNCTION IsAPIFunctionSupported RETURNS LOGICAL
    (FunctionName AS CHAR, ModuleName AS CHAR) FORWARD.
DEF VAR retval     AS INT    NO-UNDO.
DEF VAR divident   AS INT    NO-UNDO INIT 1.
DEF VAR i          AS INT    NO-UNDO.
DEFINE VARIABLE mem1 AS MEMPTR     NO-UNDO.
DEFINE VARIABLE mem2 AS MEMPTR     NO-UNDO.
DEFINE VARIABLE mem3 AS MEMPTR     NO-UNDO.
IF NOT IsAPIFunctionSupported("GetDiskFreeSpaceExA":U, "kernel32.dll":U) THEN DO:
    MESSAGE "Sorry, your version of Windows does not support GetDiskFreeSpaceEx"
            VIEW-AS ALERT-BOX.
    ASSIGN p-free-space  = ?
           p-total-space = ?.
    RETURN.
END.
IF CAN-DO("KB,Kilo,Kilobyte,Kilobytes", p-unit)
THEN divident = 1024.
ELSE
IF CAN-DO("MB,Mega,Megabyte,Megabytes", p-unit)
THEN divident = 1024 * 1024.
ELSE
IF CAN-DO("GB,Giga,Gigabyte,Gigabytes", p-unit)
THEN divident = 1024 * 1024 * 1024.
ELSE divident = 1.
IF (p-drive = "") OR (p-drive=?) THEN DO:
    FILE-INFO:FILE-NAME = ".".
    p-drive = FILE-INFO:FULL-PATHNAME.
END.
IF SUBSTR(p-drive, LENGTH(p-drive), 1) <> "\"
   THEN p-drive = p-drive + "\".
SET-SIZE(mem1) = 8.
SET-SIZE(mem2) = 8.
SET-SIZE(mem3) = 8.
RUN GetDiskFreeSpaceExA ( p-drive + CHR(0),
                         OUTPUT mem1,
                         OUTPUT mem2,
                         OUTPUT mem3,
                         OUTPUT retVal  ).
IF retVal <> 1 THEN DO:
        p-free-space = ?.
        p-total-space = ?.
END.
ELSE DO:
     ASSIGN
        p-free-space  = TRUNC( get64BitValue(mem3) / divident, 3)
        p-total-space = TRUNC( get64BitValue(mem2) / divident, 3).
END.
SET-SIZE(mem1) = 0.
SET-SIZE(mem2) = 0.
SET-SIZE(mem3) = 0.
RETURN.
PROCEDURE GetModuleHandleA EXTERNAL "kernel32.dll" :
    DEFINE  INPUT PARAMETER lpModuleName       AS CHARACTER NO-UNDO.
    DEFINE RETURN PARAMETER hModule            AS LONG      NO-UNDO.
END PROCEDURE.
PROCEDURE GetProcAddress EXTERNAL "kernel32.dll" :
    DEFINE  INPUT PARAMETER hModule            AS LONG NO-UNDO.
    DEFINE  INPUT PARAMETER lpProcName         AS CHAR NO-UNDO.
    DEFINE RETURN PARAMETER lpFarproc          AS LONG NO-UNDO.
END PROCEDURE.
PROCEDURE GetDiskFreeSpaceExA EXTERNAL "kernel32.dll" :
    DEFINE  INPUT  PARAMETER  lpDirectoryName        AS CHARACTER NO-UNDO.
    DEFINE OUTPUT  PARAMETER  FreeBytesAvailable     AS MEMPTR    NO-UNDO.
    DEFINE OUTPUT  PARAMETER  TotalNumberOfBytes     AS MEMPTR    NO-UNDO.
    DEFINE OUTPUT  PARAMETER  TotalNumberOfFreeBytes AS MEMPTR    NO-UNDO.
    DEFINE RETURN  PARAMETER  retval                 AS LONG      NO-UNDO.
END PROCEDURE.
FUNCTION IsAPIFunctionSupported RETURNS LOGICAL
    (FunctionName AS CHAR, ModuleName AS CHAR):
    DEFINE VARIABLE hModule AS INTEGER NO-UNDO.
    DEFINE VARIABLE lpFarProc AS INTEGER NO-UNDO.
    RUN GetModuleHandleA (ModuleName, OUTPUT hModule).
    RUN GetProcAddress   (hModule, FunctionName, OUTPUT lpFarProc).
    RETURN lpFarProc NE 0.
END FUNCTION.
FUNCTION get64BitValue RETURNS DECIMAL
( INPUT m64 AS MEMPTR ):
    DEFINE VARIABLE d1 AS DECIMAL    NO-UNDO.
    DEFINE VARIABLE d2 AS DECIMAL    NO-UNDO.
    d1 = GET-LONG(m64, 1).
    IF d1 < 0
    THEN d1 = d1 + 4294967296.
    d2 = GET-LONG(m64, 5).
    IF d2 < 0
    THEN d2 = d2 + 4294967296.
    IF d2 > 0
    THEN d1 = d1 + (d2 * 4294967296).
    RETURN d1.
END FUNCTION.
