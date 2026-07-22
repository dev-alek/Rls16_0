block-level on error undo, throw.
/*


$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: volspace.p $
$Archive: gbl/volspace.p $

Определить количество свободного места на диске

Автор: Перваков Михаил Сергеевич
Дата создания: 04/05/06
Author: Mikhail Pervakov
Creation date: 04/05/06

Источник
http://www.global-shared.com/cgi-bin/twiki/bin/view/Win32/GetDiskFreeSpaceEx

    Program:  VolSpace.p
    Created:  Michael Rusweg-Gilbert    Feb 2001
              mailto:rg@rgilbert.de
Description:  returns the capacity and free space of a volume (even if Vol > 2 GB)
      Usage:  for ex. run gbl/volspace.p ("C:",
                                      "KB",
                                      output freeSpace,
                                      output totalSpace).
 Parameters: - Volume to check or Blank
                 (Blank returns informations abaout the working drirector drive)
               It does not have to be the root, accepts any directory.
             - Unit to format the result; legal entries are
                   "KB", "MB" or "GB".
               If the unit is not recognized or empty, VolSpace will return
               Number of Bytes.
             - OUTPUT available free space in given unit
             - OUTPUT total space in given unit

             When VolSpace is not successful, both output parameters will return ?.

modifications:
   March 14, 2001: Jurjen - added function IsAPIFunctionSupported()

*/

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
{ cmp/vssrevis.i }
&SCOPED-DEFINE WTRUE 1
&SCOPED-DEFINE WFALSE 0

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

/* See if GetDiskFreeSpaceEx is available in this Windows version.
   (it is available in NT4, Windows 95 OSR2, Windows 98, Windows 2000)  */
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

/* No directory specified? Then use the current directory */
IF (p-drive = "") OR (p-drive=?) THEN DO:
    FILE-INFO:FILE-NAME = ".".
    p-drive = FILE-INFO:FULL-PATHNAME.
END.

/* If a UNC name was specified, make sure it ends with a backslash ( \\drive\share\dir\ )
   This won't hurt for a mapped drive too */
IF SUBSTR(p-drive, LENGTH(p-drive), 1) <> "\"
   THEN p-drive = p-drive + "\".

SET-SIZE(mem1) = 8.  /* 64 bit integer! */
SET-SIZE(mem2) = 8.
SET-SIZE(mem3) = 8.

RUN GetDiskFreeSpaceExA ( p-drive + CHR(0),
                         OUTPUT mem1,
                         OUTPUT mem2,
                         OUTPUT mem3,
                         OUTPUT retVal  ).
IF retVal <> {&WTRUE} THEN DO:
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


/* See if GetDiskFreeSpaceEx is available in this Windows version */
FUNCTION IsAPIFunctionSupported RETURNS LOGICAL
    (FunctionName AS CHAR, ModuleName AS CHAR):

    DEFINE VARIABLE hModule AS INTEGER NO-UNDO.
    DEFINE VARIABLE lpFarProc AS INTEGER NO-UNDO.

    /* you should run LoadLibraryA to load the module into memory,
       but this is not necessary for ModuleName="kernel32.dll": the kernel is
       always available. */
    RUN GetModuleHandleA (ModuleName, OUTPUT hModule).
    RUN GetProcAddress   (hModule, FunctionName, OUTPUT lpFarProc).
    RETURN lpFarProc NE 0.
END FUNCTION.


/* Converts a 64-bit integer given in a 8 byte mempointer into a decimal */
FUNCTION get64BitValue RETURNS DECIMAL
( INPUT m64 AS MEMPTR ):

    /* constant 2^32 */
    &SCOPED-DEFINE BigInt 4294967296

    DEFINE VARIABLE d1 AS DECIMAL    NO-UNDO.
    DEFINE VARIABLE d2 AS DECIMAL    NO-UNDO.

    d1 = GET-LONG(m64, 1).
    IF d1 < 0
    THEN d1 = d1 + {&BigInt}.

    d2 = GET-LONG(m64, 5).
    IF d2 < 0
    THEN d2 = d2 + {&BigInt}.

    IF d2 > 0
    THEN d1 = d1 + (d2 * {&BigInt}).

    RETURN d1.

END FUNCTION.