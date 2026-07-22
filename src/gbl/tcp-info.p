block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: tcp-info.p $
$Archive: gbl/tcp-info.p $

Получить информацию о стеке TCP компьютера

Автор: Перваков Михаил Сергеевич
Дата создания: 01/16/07
Author: Mikhail Pervakov
Creation date: 01/16/07

Источник Progress Knowledge Base  KB-P47754

*/

define output parameter p-host-name  as character no-undo .
define output parameter p-ip-address as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: tcp-info.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/tcp-info.p $":U .
define variable vss-description as character no-undo init "".
{ cmp/vssrevis.i }
&SCOPED-DEFINE WSADESCRIPTION_LEN 256
&SCOPED-DEFINE WSASYS_STATUS_LEN  128

&SCOPED-DEFINE WSADATA_VERSION_LOW     1 /* WORD(2) */
&SCOPED-DEFINE WSADATA_VERSION_HIGH    3 /* WORD(2) */
&SCOPED-DEFINE WSADATA_DESCRIPTION     5 /* CHAR(WSADESCRIPTION_LEN + 1) */
&SCOPED-DEFINE WSADATA_SYSTEM_STATUS 262 /* CHAR(WSASYS_STATUS_LEN + 1) */
&SCOPED-DEFINE WSADATA_MAX_SOCKETS   391 /* SHORT(4) */
&SCOPED-DEFINE WSADATA_MAX_UDP       395 /* SHORT(4) */
&SCOPED-DEFINE WSADATA_VENDOR_INFO   399 /* CHAR*(4) */
&SCOPED-DEFINE WSADATA_LENGTH        403

&SCOPED-DEFINE HOSTENT_NAME         1 /* CHAR*(4) */
&SCOPED-DEFINE HOSTENT_ALIASES      5 /* CHAR**(4) */
&SCOPED-DEFINE HOSTENT_ADDR_TYPE    9 /* SHORT(2) */
&SCOPED-DEFINE HOSTENT_ADDR_LENGTH 11 /* SHORT(2) */
&SCOPED-DEFINE HOSTENT_ADDR_LIST   13 /* CHAR**(4) */
&SCOPED-DEFINE HOSTENT_LENGTH      16

do
on error undo, return error return-value
:
  run gettcpinfo in this-procedure
    (output p-host-name
    ,output p-ip-address
    ).
end.


PROCEDURE GetTcpInfo:
  /*------------------------------------------------------------------------
  Procedure : GetTcpInfo

  Description : Return the windows TCP host name and address of this PC.

  Parms : - Host name. (OUTPUT, CHARACTER)
  - Host address. (OUTPUT, CHARACTER):

  Sample usage: RUN GetTcpInfo (OUTPUT w-TcpName,
  OUTPUT w-TcpAddr).

  Notes : -
  ------------------------------------------------------------------------*/
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

    /* Initialize return values */
    ASSIGN p-TcpName = ?
    p-TcpAddr = ?
    .

    /* Allocate work structure for WSADATA */
    SET-SIZE(ptr-WsaData) = {&WSADATA_LENGTH}.

    /* Ask Win32 for winsock usage */
    RUN WSAStartup
      (INPUT 257 /* requested version 1.1 */
      ,INPUT GET-POINTER-VALUE(ptr-WsaData)
      ,OUTPUT w-Return
      ).

    /* Release allocated memory */
    SET-SIZE(ptr-WsaData) = 0.

    /* Check for errors */
    IF w-Return <> 0
    THEN DO:
      undo, return error "Ошибка при инициализации библиотеки WINSOCK" .
    END.

    /* Set up variables */
    ASSIGN
      w-Length = 100
      w-TcpName = FILL(" ", w-Length)
    .

    /* Call Win32 routine to get host name */
    RUN gethostname
      (OUTPUT w-TcpName
      ,INPUT  w-Length
      ,OUTPUT w-Return
      ).

    /* Check for errors */
    IF w-Return <> 0
    THEN DO:
      RUN WSACleanup
        (OUTPUT w-Return
        ).
      undo, return error "Ошибка при получении имени компьютера" .
    END.

    /* Pass back gathered info */
    /* remember: the string is null-terminated so there is a CHR(0)
    inside w-TcpName. We have to trim it: */
    assign
      p-TcpName = ENTRY(1,w-TcpName,CHR(0))
    .

    /* Call Win32 routine to get host address */
    RUN gethostbyname
      (INPUT w-TcpName
      ,OUTPUT w-Hostent
      ).

    /* Check for errors */
    IF w-Hostent EQ 0
    THEN DO:
      RUN WSACleanup
        (OUTPUT w-Return
        ).
      undo, return error "Ошибка при получении адреса компьютера по имени" .
    END.

    /* Set pointer to HostEnt data structure */
    assign
      SET-POINTER-VALUE(ptr-Hostent) = w-Hostent
    .

    /* "Chase" pointers to get to first address list entry */
    assign
      SET-POINTER-VALUE(ptr-AddrList)  = GET-LONG(ptr-Hostent, {&HOSTENT_ADDR_LIST})
      SET-POINTER-VALUE(ptr-ListEntry) = GET-LONG(ptr-AddrList, 1)
      w-TcpLong                        = GET-LONG(ptr-ListEntry, 1)
    .

    RUN inet_ntoa
      (INPUT w-TcpLong
      ,OUTPUT ptr-AddrString
      ).

    /* Pass back gathered info */
    assign
      p-TcpAddr = GET-STRING(ptr-AddrString, 1)
    .

    /* Terminate winsock usage */
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