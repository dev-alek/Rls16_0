block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: sockserver.p $
$Archive: gbl/sockserver.p $

Сокет-сервер

Автор: Хныкин Павел Андреевич
Дата создания: 06/17/08
Author: Pavel Khnykin
Creation date: 06/17/08

*/

/*
define input  parameter parparentproc as handle    no-undo .
define input  parameter p-socket-port as integer   no-undo .
define output parameter p-ret-val     as integer   no-undo .
define output parameter p-message     as character no-undo .
*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: sockserver.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/sockserver.p $":U .
define variable vss-description as character no-undo init "Сокет-сервер".

{ cmp/str-glbl.i }

define stream slog.

&scop log-file-name "c:\socklog.log":U

define variable s-socket as handle    no-undo .
define variable v-retval as logical   no-undo .


define temp-table tt-cli-socket no-undo
  field sock-handle     as handle
  field remote-host     as character
  field remote-port     as integer
  field conn-time       as integer
  field last-conn-time  as integer
index pi is primary unique
  sock-handle
.


main-block :
do
on error undo main-block, return error return-value
:
  run empty-tt-cli-socket in this-procedure .

  create server-socket s-socket no-error .
  if error-status :error or
     not valid-handle (s-socket)
  then do:
    message
      "Ошибка при создании серверного сокета!" skip
      error-status :get-message(1) skip
      error-status :get-message(2) skip
      error-status :get-message(3) skip
    view-as alert-box error.
    undo main-block, return error. /* --->>>--- */
  end.

  assign
    v-retval = s-socket:enable-connections( "-S 12222" )
  .

  assign
    v-retval = s-socket:set-connect-procedure( "conproc" )
  .

  wait-for "close" of this-procedure.

  for each tt-cli-socket:
    if valid-handle( tt-cli-socket.sock-handle )
    then do:
      tt-cli-socket.sock-handle :disconnect() .
    end.
  end.

  s-socket:disable-connections() .
  delete object s-socket.

end.

/* ================================================================================ */
procedure conproc :
  define input param clienthandle as handle.
do
on error undo, return error return-value
:
  define variable v-log as logical   no-undo .

  assign
    v-log = clienthandle :set-read-response-procedure("readproc").
  .

  if v-log <> yes then do:

  end.

  clienthandle :set-socket-option( "SO-LINGER" , "FALSE" ).
  clienthandle :set-socket-option( "TCP-NODELAY" , "TRUE" ).

  find first tt-cli-socket no-lock
    where tt-cli-socket.sock-handle = clienthandle
  no-error .
  if not available tt-cli-socket
  then do:
    create tt-cli-socket.
    assign
      tt-cli-socket.sock-handle = clienthandle
    .
  end.

  assign
    tt-cli-socket.remote-host     = clienthandle :remote-host
    tt-cli-socket.remote-port     = clienthandle :remote-port
    tt-cli-socket.conn-time       = time
    tt-cli-socket.last-conn-time  = tt-cli-socket.conn-time
  .

  run write-log in this-procedure ( substitute( "Установлено соединение. Удаленный хост: &1 , удаленный порт: &2"
                                              , tt-cli-socket.remote-host
                                              , tt-cli-socket.remote-port
                                              )
                                  ) .

end.
end procedure. /* connproc */

/* ================================================================================ */
procedure readproc :

  define variable v-size          as integer    no-undo .
  define variable v-crc32         as int64      no-undo .
  define variable v-func_num      as integer    no-undo .
  define variable v-req_num       as integer    no-undo .
  define variable v-field_num     as integer    no-undo .
  define variable v-text          as character  no-undo .
  define variable v-checked-crc32 as int64      no-undo .
  define variable v-msg-size      as integer    no-undo .
  define variable v-memptr        as memptr     no-undo .
  define variable v-memptrw       as memptr     no-undo .
  define variable v-memptrs       as memptr     no-undo .
  define variable v-msg-str       as longchar   no-undo .
  define variable v-bytes-readed  as integer    no-undo .
  define variable v-log           as logical    no-undo .
  define variable v-sendmemptr    as memptr     no-undo .
  define variable v-sendstr       as longchar   no-undo .

do
on error undo, return error return-value
:
    /* проверяем что клиент не отключился */
    if not self:connected() then return.

    /* читаем шапку сообщения */
    set-size(v-memptr) = 20 .
    self:read(v-memptr,1,20) .
    assign
        v-bytes-readed = self:bytes-read
    .
    /* пока пропускаем */
    if v-bytes-readed < 20
    then do:
        return.
    end.

    /* разбираем поля сообщения */
    assign
      v-size        = get-long(v-memptr,1)
      v-crc32       = int64(4294967296 + get-long(v-memptr,5))
      v-func_num    = get-long(v-memptr,9)
      v-req_num     = get-long(v-memptr,13)
      v-field_num   = get-long(v-memptr,17)
      v-msg-size    =  v-size - 20
    .

    run check-crc32 in this-procedure ( input v-memptr , 12, output v-checked-crc32) .
    set-size(v-memptr) = 0.

    /* читаем тело сообщения */
    if v-msg-size > 0
    then do:
        set-size(v-memptrs) = v-msg-size .
        self:read(v-memptrs,1,v-msg-size) .
        assign
            v-msg-str = get-string(v-memptrs, 1, v-msg-size)
        .
        set-size(v-memptrs) = 0 .
    end.

    /* отладочные сообщения */
    assign
      v-text =   substitute( "1=&1, 2=&2, 3=&3, 4=&4, 5=&5, CRC32=&6"
                           , v-size
                           , v-crc32
                           , v-func_num
                           , v-req_num
                           , v-field_num
                           , v-checked-crc32
                           )
    .

    run write-log in this-procedure ( substitute( "&1:&2 &3&4&5 byte recieved : &4&6&4&7&4&6"
                                                , self :remote-host
                                                , self :remote-port
                                                , v-text
                                                , {&new-line}
                                                , self :bytes-read
                                                , fill('-',120)
                                                , v-msg-str
                                                )
                                    ) .
    case v-req_num:
        when 12
        then do:
            run gbl/mtreq12.p ( input this-procedure , input v-msg-str , output v-sendstr) .

            set-size(v-sendmemptr) = 20 + length(v-sendstr) + 1 .

            put-long(v-sendmemptr , 1 )   = 20 + length(v-sendstr) .
            put-long(v-sendmemptr , 5 )   = 0 .
            put-long(v-sendmemptr , 9 )   = 0 .
            put-long(v-sendmemptr , 13 )  = 0 .
            put-long(v-sendmemptr , 17 )  = 0 .
            put-string(v-sendmemptr,21)   = v-sendstr .



            v-log = self:write(v-sendmemptr, 1, 20 + length(v-sendstr) ) no-error .
            if error-status :error
            then do:
              message
                error-status :get-message(1) skip
                error-status :get-message(2) skip
                error-status :get-message(3)
              view-as alert-box error.
            end.

            set-size(v-sendmemptr) = 0 .


                run write-log in this-procedure ( substitute("&1 bytes writen: &2&3&2&4&2&3"
                                                            , self:BYTES-WRITTEN
                                                            , {&new-line}
                                                            , fill('-',120)
                                                            , v-sendstr
                                                            )
                                                ).
        end. /* when 12 */

        when 13
        then do:
          /* пришла команда на отключение */
          self:disconnect().
          run write-log in this-procedure ( substitute( "Client disconnected! &1&2&1"
                                                      , {&new-line}
                                                      , fill('*',120)
                                                      )
                                          ).
        end.
    end case.
end.

end procedure. /* readproc */

/* ================================================================================ */
procedure write-log :
  define input  parameter p-message as character no-undo .
do
on error undo, return error return-value
:

  output stream slog to value({&log-file-name}) append.
  put stream slog unformatted string( time , "HH:MM:SS") " " trim(p-message)   skip.
  output stream slog close.

end.

end procedure. /* write-log */

/* ================================================================================ */
procedure crc32 external "crc32.dll" CDECL :
    define input    parameter p-crc    as long.
    define input    parameter p-array  as memptr.
    define input    parameter p-len    as long.
    define return   parameter p-crc32  as long.
end.

/* ================================================================================ */
procedure check-crc32:
    define input parameter  p-mem   as memptr no-undo.
    define input parameter  p-len   as integer no-undo.

    define output parameter p-crc32     as int64 no-undo.


    define variable v-message as memptr no-undo.
    define variable v-crc32   as int64  no-undo.

    SET-SIZE(v-message) = p-len .
    set-pointer-value(v-message) = get-pointer-value(p-mem) + 8.
    run crc32 ( input 0 , input v-message , input p-len , output v-crc32).
    p-crc32 = int64(4294967296 + v-crc32).
end procedure. /* check-crc32 */

/* ================================================================================ */
procedure empty-tt-cli-socket :

do
on error undo, return error return-value
:
  empty temp-table tt-cli-socket .
end.

end procedure. /* empty-tt-client-socket */




/*
/*Server1.p */
DEFINE VARIABLE mytext      AS CHARACTER  NO-UNDO.
DEFINE VARIABLE mysocket    AS HANDLE     NO-UNDO.
DEFINE VARIABLE v-memptr    AS MEMPTR     NO-UNDO.
DEFINE VARIABLE ret         AS LOGICAL    NO-UNDO.

CREATE SERVER-SOCKET mysocket NO-ERROR. /* Point 1 */
ret = mysocket:ENABLE-CONNECTIONS("-S 5001"). /* Point 2 */
mysocket:SET-CONNECT-PROCEDURE("conproc"). /* Point 3 */

WAIT-FOR "CLOSE" OF THIS-PROCEDURE.
DELETE OBJECT mysocket.

PROCEDURE conproc:
    DEFINE INPUT PARAM clienthandle AS HANDLE. /* Point 4 */
    /*
    MESSAGE "Client connected" VIEW-AS ALERT-BOX.
    */
    clienthandle:SET-READ-RESPONSE-PROCEDURE("readproc"). /* Point 5 */
END PROCEDURE.

PROCEDURE readproc:
    def var size as int no-undo.
    def var crc32 as int64 no-undo.
    def var func_num as int no-undo.
    def var req_num as int no-undo.
    def var field_num as int no-undo.
    def var v-text as character no-undo.
    def var v-checked-crc32 as int64 no-undo.

    self:SET-SOCKET-OPTION( "SO-LINGER" , "FALSE" ).
    self:SET-SOCKET-OPTION( "TCP-NODELAY" , "TRUE" ).



    SET-SIZE(v-memptr) = 20. /* Point 6 */
    self:READ(v-memptr,1,20). /* Point 8 */

    assign
        size        = get-long(v-memptr,1)
        crc32       = int64(4294967296 + get-long(v-memptr,5))
        func_num    = get-long(v-memptr,9)
        req_num     = get-long(v-memptr,13)
        field_num   = get-long(v-memptr,17)
    .
    run check-crc32 ( input v-memptr , 12, output v-checked-crc32) .

        v-text =   substitute( "1=&1, 2=&2, 3=&3, 4=&4, 5=&5, CRC32=&6"
                  , size
                  , crc32
                  , func_num
                  , req_num
                  , field_num
                  , v-checked-crc32
                  ).

    output to c:\sock.txt append.
    put unformatted string(time, "HH:MM:SS") " "
                    self:remote-host ":" self:remote-port " " v-text
    skip.
    output close.

    if v-checked-crc32 = crc32 and
       req_num = 13
    then do:
        SELF:DISCONNECT().
        output to c:\sock.txt append.
        put unformatted " Client disconnected!" skip(2).
        output close.
    end.

    SET-SIZE(v-memptr) = 0.
END PROCEDURE.


/*
PROCEDURE FindFirstChangeNotificationA EXTERNAL "kernel32.dll"
:
    DEFINE INPUT        PARAMETER lpPathName       AS MEMPTR . /*  */
    DEFINE INPUT        PARAMETER bWatchSubtree    AS LONG   . /*  */
    DEFINE INPUT        PARAMETER dwNotifyFilter   AS LONG   . /*  */
    DEFINE RETURN       PARAMETER RetParam         AS LONG   .
END PROCEDURE. /* FindFirstChangeNotificationA */
*/

procedure crc32 external "crc32.dll" CDECL :
    define input    parameter p-crc    as long.
    define input    parameter p-array  as memptr.
    define input    parameter p-len    as long.
    define return   parameter p-crc32  as long.
end.

procedure check-crc32:
    define input parameter  p-mem   as memptr no-undo.
    define input parameter  p-len   as integer no-undo.

    define output parameter p-crc32     as int64 no-undo.


    define variable v-message as memptr no-undo.
    define variable v-crc32s   as intege  no-undo.
    define variable v-crc32   as int64  no-undo.

    SET-SIZE(v-message) = p-len .
    set-pointer-value(v-message) = get-pointer-value(p-mem) + 8.
    run crc32 ( input 0 , input v-message , input p-len , output v-crc32s).
    p-crc32 = int64(4294967296 + v-crc32s).
end procedure.
*/