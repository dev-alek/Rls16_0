block-level on error undo, throw.
define input  parameter p-path as character no-undo .
define output parameter p-unc as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: get-unc.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/get-unc.p $":U .
define variable vss-description as character no-undo init "Получение UNC".
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
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
PROCEDURE WNetGetConnectionA EXTERNAL "mpr.dll" :
  DEFINE INPUT        PARAMETER lpDrive    AS CHARACTER.
  DEFINE OUTPUT       PARAMETER lpUNCName  AS CHARACTER.
  DEFINE INPUT-OUTPUT PARAMETER lpnLength  AS LONG.
  DEFINE RETURN       PARAMETER RetBool    AS LONG.
END PROCEDURE.
PROCEDURE WSACleanup EXTERNAL "wsock32.dll" :
  DEFINE RETURN       PARAMETER RetBool    AS LONG.
END PROCEDURE.
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
  end.
  ELSE do:
    if retBool = 2250 then do:
      ASSIGN
      namelen = 100
      cclientname = FILL(" ", namelen)
      .
      RUN gethostname (OUTPUT cclientname,
                      INPUT  namelen,
                      OUTPUT retBool).
      IF retBool NE 0 THEN DO:
        RUN WSACleanup (OUTPUT retBool).
        undo, return error substitute("Ошибка при получении имени компьютера:&1&2"
                                      , chr(10)
                                      , retbool).
      END.
      p-unc = ENTRY(1, cclientname, CHR(0)).
      .
      p-unc = substitute("\\&1\&2$&3", p-unc , substring(p-path, 1, 1), substring(p-path, 3)).
    end.
    else do:
     case retBool:
       when 1200 then do:
         undo, return error substitute("Ошибка при определении UNC - 1200  -The string pointed to by the lpLocalName parameter is invalid.").
       end.
       when 234 then do:
         undo, return error substitute("Ошибка при определении UNC - 234  - The buffer is too small. The lpnLength parameter points to a variable that contains the required buffer size. More entries are available with subsequent calls.").
       end.
       when 1201 then do:
         undo, return error substitute("Ошибка при определении UNC - 1201 - The device is not currently connected, but it is a persistent connection. For more information, see the following Remarks section.").
       end.
       when 1222 then do:
         undo, return error substitute("Ошибка при определении UNC -  1222 - The network is unavailable.").
       end.
       when 1208 then do:
         undo, return error substitute("Ошибка при определении UNC -  1208  = A network-specific error occurred. To obtain a description of the error, call the WNetGetLastError function.").
       end.
       when 1203 then do:
         undo, return error substitute("Ошибка при определении UNC -  1203  - None of the providers recognize the local name as having a connection. However, the network is not available for at least one provider to whom the connection may belong.").
       end.
     end case.
   end.
 end.
end.
else do:
  if p-path begins "\\" then do:
    p-unc = p-path.
  end.
  else do:
    undo, return error substitute("Не удалось определить UNC для &1", p-path).
  end.
end.
