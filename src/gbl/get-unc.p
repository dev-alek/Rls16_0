block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: get-unc.p $
$Archive: gbl/get-unc.p $

Получение UNC

Автор: Бахтадзе Наталья Викторовна
Дата создания: 07/18/09
Author: Bakhtadze Natalya
Creation date: 07/18/09

*/

define input  parameter p-path as character no-undo .
define output parameter p-unc as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: get-unc.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/get-unc.p $":U .
define variable vss-description as character no-undo init "Получение UNC".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }

PROCEDURE WNetGetConnectionA EXTERNAL "mpr.dll" :
  DEFINE INPUT        PARAMETER lpDrive    AS CHARACTER.
  DEFINE OUTPUT       PARAMETER lpUNCName  AS CHARACTER.
  DEFINE INPUT-OUTPUT PARAMETER lpnLength  AS LONG.
  DEFINE RETURN       PARAMETER RetBool    AS LONG.
END PROCEDURE.

PROCEDURE WSACleanup EXTERNAL "wsock32.dll" :
  DEFINE RETURN       PARAMETER RetBool    AS LONG.
END PROCEDURE.


&GLOB ERROR_BAD_DEVICE 1200  /*The string pointed to by the lpLocalName parameter is invalid.*/
&GLOB ERROR_NOT_CONNECTED 2250 /*The device specified by lpLocalName is not a redirected device. For more information, see the following Remarks section.*/
&GLOB ERROR_MORE_DATA 234 /*The buffer is too small. The lpnLength parameter points to a variable that contains the required buffer size. More entries are available with subsequent calls.*/
&GLOB ERROR_CONNECTION_UNAVAIL 1201 /*The device is not currently connected, but it is a persistent connection. For more information, see the following Remarks section.*/
&GLOB ERROR_NO_NETWORK 1222 /*The network is unavailable.*/
&GLOB ERROR_EXTENDED_ERROR 1208 /*A network-specific error occurred. To obtain a description of the error, call the WNetGetLastError function.*/
&GLOB ERROR_NO_NET_OR_BAD_PATH 1203 /*None of the providers recognize the local name as having a connection. However, the network is not available for at least one provider to whom the connection may belong.*/



PROCEDURE gethostname EXTERNAL "wsock32.dll" :
  DEFINE OUTPUT       PARAMETER p-Hostname      AS CHARACTER.
  DEFINE INPUT        PARAMETER p-Length        AS LONG.
  DEFINE RETURN       PARAMETER p-Return        AS LONG.
END PROCEDURE.

PROCEDURE PathIsRelative External "shell32.dll" :
 define input         parameter p-path     as character.
 DEFINE RETURN        PARAMETER pRetBoll   as Long.
END PROCEDURE.




DEFINE VARIABLE Drive_Name AS CHARACTER NO-UNDO .
DEFINE VARIABLE namelen AS INTEGER NO-UNDO INITIAL 100.
DEFINE VARIABLE retBool AS INTEGER NO-UNDO.
DEFINE VARIABLE cClientName AS CHARACTER   NO-UNDO.
define variable v-var as integer   no-undo .


if ((substring(p-path, 2, 2) = ":\"
or substring(p-path, 2, 2) = ":/")
and index("ABCDEFGHIJKLMNOPQRSTUVXYZ", substring(p-path, 1, 1)) > 0
)
then do:
  Drive_Name = substring(p-path, 1, 2).
  p-UNC = FILL("x", namelen).
  RUN WNetGetConnectionA ( Drive_Name
                          ,OUTPUT p-unc
                          ,INPUT-OUTPUT namelen
                          ,OUTPUT retBool).
  IF retBool = 0 THEN do:
    p-UNC = SUBSTRING(p-unc, 1, namelen).
    p-unc = trim(p-unc) + (if length(p-path) > 2 then substring(p-path, 3) else '').
  end. /*IF retBool = 0 THEN do:*/
  ELSE do:
    if retBool = {&ERROR_NOT_CONNECTED} then do:
      ASSIGN
      namelen = 100
      cclientname = FILL(" ", namelen)
      .

      /* Call Win32 routine to get host name */
      RUN gethostname (OUTPUT cclientname,
                      INPUT  namelen,
                      OUTPUT retBool).

      /* Check for errors */
      IF retBool NE 0 THEN DO:
        RUN WSACleanup (OUTPUT retBool).
        undo, return error substitute("Ошибка при получении имени компьютера:&1&2"
                                      , {&new-line}
                                      , retbool).

      END.
      p-unc = ENTRY(1, cclientname, CHR(0)).
      .
      p-unc = substitute("\\&1\&2$&3", p-unc , substring(p-path, 1, 1), substring(p-path, 3)).
    end. /*if retBool = {&ERROR_NOT_CONNECTED} then do:*/
    else do:
     case retBool:
       when {&ERROR_BAD_DEVICE} then do:
         undo, return error substitute("Ошибка при определении UNC - 1200  -The string pointed to by the lpLocalName parameter is invalid.").
       end.
       when {&ERROR_MORE_DATA} then do:
         undo, return error substitute("Ошибка при определении UNC - 234  - The buffer is too small. The lpnLength parameter points to a variable that contains the required buffer size. More entries are available with subsequent calls.").
       end.
       when {&ERROR_CONNECTION_UNAVAIL} then do:
         undo, return error substitute("Ошибка при определении UNC - 1201 - The device is not currently connected, but it is a persistent connection. For more information, see the following Remarks section.").
       end.
       when {&ERROR_NO_NETWORK} then do:
         undo, return error substitute("Ошибка при определении UNC -  1222 - The network is unavailable.").
       end.
       when {&ERROR_EXTENDED_ERROR} then do:
         undo, return error substitute("Ошибка при определении UNC -  1208  = A network-specific error occurred. To obtain a description of the error, call the WNetGetLastError function.").
       end.
       when {&ERROR_NO_NET_OR_BAD_PATH} then do:
         undo, return error substitute("Ошибка при определении UNC -  1203  - None of the providers recognize the local name as having a connection. However, the network is not available for at least one provider to whom the connection may belong.").
       end.
     end case.
   end.
 end. /*else if retboool = 0*/
end.
else do:
  if p-path begins "\\" then do:
    /*
    run PathIsRelative ( input p-path
                         ,output retbool) .
    message  retBool view-as alert-box .
    if retBool = 0 then do:
      p-unc = p-path.
    end.
    else do:
      undo, return error substitute("Не удалось определить UNC для &1", p-path).
    end.*/
    p-unc = p-path.
  end.
  else do:
    undo, return error substitute("Не удалось определить UNC для &1", p-path).
  end.
end.

