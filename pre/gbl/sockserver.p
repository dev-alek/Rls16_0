block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: sockserver.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/sockserver.p $":U .
define variable vss-description as character no-undo init "Сокет-сервер".
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define stream slog.
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
    undo main-block, return error.
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
end procedure.
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
    if not self:connected() then return.
    set-size(v-memptr) = 20 .
    self:read(v-memptr,1,20) .
    assign
        v-bytes-readed = self:bytes-read
    .
    if v-bytes-readed < 20
    then do:
        return.
    end.
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
    if v-msg-size > 0
    then do:
        set-size(v-memptrs) = v-msg-size .
        self:read(v-memptrs,1,v-msg-size) .
        assign
            v-msg-str = get-string(v-memptrs, 1, v-msg-size)
        .
        set-size(v-memptrs) = 0 .
    end.
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
                                                , chr(10)
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
                                                            , chr(10)
                                                            , fill('-',120)
                                                            , v-sendstr
                                                            )
                                                ).
        end.
        when 13
        then do:
          self:disconnect().
          run write-log in this-procedure ( substitute( "Client disconnected! &1&2&1"
                                                      , chr(10)
                                                      , fill('*',120)
                                                      )
                                          ).
        end.
    end case.
end.
end procedure.
procedure write-log :
  define input  parameter p-message as character no-undo .
do
on error undo, return error return-value
:
  output stream slog to value("c:\socklog.log":U) append.
  put stream slog unformatted string( time , "HH:MM:SS") " " trim(p-message)   skip.
  output stream slog close.
end.
end procedure.
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
    define variable v-crc32   as int64  no-undo.
    SET-SIZE(v-message) = p-len .
    set-pointer-value(v-message) = get-pointer-value(p-mem) + 8.
    run crc32 ( input 0 , input v-message , input p-len , output v-crc32).
    p-crc32 = int64(4294967296 + v-crc32).
end procedure.
procedure empty-tt-cli-socket :
do
on error undo, return error return-value
:
  empty temp-table tt-cli-socket .
end.
end procedure.
