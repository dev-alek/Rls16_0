block-level on error undo, throw.
define output parameter p-host-name  as character no-undo .
define output parameter p-ip-address as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: tcp-info.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/tcp-info.p $":U .
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
do
on error undo, return error return-value
:
  run gettcpinfo in this-procedure
    (output p-host-name
    ,output p-ip-address
    ).
end.
PROCEDURE GetTcpInfo:
  DEFINE OUTPUT PARAMETER p-TcpName AS CHARACTER NO-UNDO.
  DEFINE OUTPUT PARAMETER p-TcpAddr AS CHARACTER NO-UNDO.
  do
  on error undo, return error return-value
  :
    DEFINE VARIABLE w-TcpName AS CHARACTER NO-UNDO.
    DEFINE VARIABLE w-Length AS INTEGER NO-UNDO.
    DEFINE VARIABLE w-Return AS INTEGER NO-UNDO.
    DEFINE VARIABLE ptr-WsaData AS MEMPTR NO-UNDO.
    DEFINE VARIABLE w-Hostent AS INTEGER NO-UNDO.
    DEFINE VARIABLE ptr-Hostent AS MEMPTR NO-UNDO.
    DEFINE VARIABLE ptr-AddrString AS MEMPTR NO-UNDO.
    DEFINE VARIABLE ptr-AddrList AS MEMPTR NO-UNDO.
    DEFINE VARIABLE ptr-ListEntry AS MEMPTR NO-UNDO.
    DEFINE VARIABLE w-TcpLong AS INTEGER NO-UNDO.
    ASSIGN p-TcpName = ?
    p-TcpAddr = ?
    .
    SET-SIZE(ptr-WsaData) = 403.
    RUN WSAStartup
      (INPUT 257
      ,INPUT GET-POINTER-VALUE(ptr-WsaData)
      ,OUTPUT w-Return
      ).
    SET-SIZE(ptr-WsaData) = 0.
    IF w-Return <> 0
    THEN DO:
      undo, return error "Ошибка при инициализации библиотеки WINSOCK" .
    END.
    ASSIGN
      w-Length = 100
      w-TcpName = FILL(" ", w-Length)
    .
    RUN gethostname
      (OUTPUT w-TcpName
      ,INPUT  w-Length
      ,OUTPUT w-Return
      ).
    IF w-Return <> 0
    THEN DO:
      RUN WSACleanup
        (OUTPUT w-Return
        ).
      undo, return error "Ошибка при получении имени компьютера" .
    END.
    assign
      p-TcpName = ENTRY(1,w-TcpName,CHR(0))
    .
    RUN gethostbyname
      (INPUT w-TcpName
      ,OUTPUT w-Hostent
      ).
    IF w-Hostent EQ 0
    THEN DO:
      RUN WSACleanup
        (OUTPUT w-Return
        ).
      undo, return error "Ошибка при получении адреса компьютера по имени" .
    END.
    assign
      SET-POINTER-VALUE(ptr-Hostent) = w-Hostent
    .
    assign
      SET-POINTER-VALUE(ptr-AddrList)  = GET-LONG(ptr-Hostent, 13)
      SET-POINTER-VALUE(ptr-ListEntry) = GET-LONG(ptr-AddrList, 1)
      w-TcpLong                        = GET-LONG(ptr-ListEntry, 1)
    .
    RUN inet_ntoa
      (INPUT w-TcpLong
      ,OUTPUT ptr-AddrString
      ).
    assign
      p-TcpAddr = GET-STRING(ptr-AddrString, 1)
    .
    RUN WSACleanup
      (OUTPUT w-Return
      ).
  end.
END PROCEDURE.
PROCEDURE gethostname EXTERNAL "wsock32.dll" :
DEFINE OUTPUT PARAMETER p-Hostname AS CHARACTER.
DEFINE INPUT PARAMETER p-Length AS LONG.
DEFINE RETURN PARAMETER p-Return AS LONG.
END PROCEDURE.
PROCEDURE gethostbyname EXTERNAL "wsock32.dll" :
DEFINE INPUT PARAMETER p-Name AS CHARACTER.
DEFINE RETURN PARAMETER p-Hostent AS LONG.
END PROCEDURE.
PROCEDURE inet_ntoa EXTERNAL "wsock32.dll" :
DEFINE INPUT PARAMETER p-AddrStruct AS LONG.
DEFINE RETURN PARAMETER p-AddrString AS MEMPTR.
END PROCEDURE.
PROCEDURE WSAStartup EXTERNAL "wsock32.dll" :
DEFINE INPUT PARAMETER p-VersionReq AS SHORT.
DEFINE INPUT PARAMETER ptr-WsaData AS LONG.
DEFINE RETURN PARAMETER p-Return AS LONG.
END PROCEDURE.
PROCEDURE WSACleanup EXTERNAL "wsock32":
DEFINE RETURN PARAMETER p-Return AS LONG.
END PROCEDURE.
