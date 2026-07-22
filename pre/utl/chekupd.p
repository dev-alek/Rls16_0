block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision:$":U .
define variable vss-author      as character no-undo init "$Author:$":U .
define variable vss-date        as character no-undo init "$Date:$":U .
define variable vss-workfile    as character no-undo init "$Workfile:$":U .
define variable vss-archive     as character no-undo init "$Archive:$":U .
define variable vss-description as character no-undo init "Проверка обновления".
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
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
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define new  shared variable g#auto as logical no-undo.
define new  shared variable g#news as logical no-undo.
define new  shared variable g#oxml as logical no-undo.
define new  shared variable g#esys as logical no-undo.
define new  shared variable g#news-source-db as integer no-undo.
define new  shared variable g#esys-source-esys as integer no-undo.
define new  shared variable g#db-num as integer   no-undo .
define new  shared variable g#userid as character no-undo .
define new  shared variable g#passwd as character no-undo .
define input  parameter iChek as logical no-undo.
define input  parameter iTarg as integer no-undo.
define output parameter oUpd  as logical no-undo.
define variable mdb-ver as integer  no-undo init ?.
define variable mdbverd as integer no-undo.
define variable mdbveri as integer no-undo.
define buffer sys-ctrl     for ub.sys-ctrl.
define buffer db-attr      for ub.db-attr.
define buffer db           for ub.db.
define buffer b_file       for ub._file.
define buffer b_field      for ub._field.
define buffer b_Connect    for ub._Connect.
find first sys-ctrl no-lock no-error.
if not available sys-ctrl then do: oUpd = yes. return. end.
g#db-num = sys-ctrl.db-num.
find first db-attr where db-attr.db-num    eq sys-ctrl.db-num
                     and db-attr.attr-code eq  'ver-db':U
no-lock no-error.
if available db-attr then mdb-ver = integer (db-attr.attr-value) no-error.
release db-attr.
release sys-ctrl.
if    iChek
then do:
   oUpd = mdb-ver ne ? and mdb-ver < iTarg.
   publish "putstat" (substitute ("Проверка Нужно обновление бд? &1",oUpd) ).
end.
else do:
   if mdb-ver eq ? or mdb-ver >= iTarg
   then do:
      oUpd = true.
      return.
   end.
   define variable v-process-id   as integer   no-undo.
   define variable v-process-list as character no-undo.
   define variable vUserIgnor     as character no-undo.
   define variable Msg            as character no-undo.
   run gbl/getprcid.p ( output v-process-id ) no-error.
   if error-status:error
   then do:
      Msg = ( "Невозможно получить PID процесса. Обновление схемы БД невозможно. Работа с ней запрещена!" ).
      return Msg.
   end.
   publish "putstat" (substitute ("Запускаем понижение версии БД ") ).
   vUserIgnor = "nws".
   for each b_Connect where b_Connect._Connect-Type = "REMC"
                        and b_Connect._Connect-Pid <> ?
                        and b_Connect._Connect-Pid <> v-process-id
                        and not can-do(vUserIgnor,b_Connect._Connect-Name)
   no-lock:
      v-process-list = v-process-list + chr(10) + string (b_Connect._Connect-Pid) + " - " + b_Connect._Connect-Name +  " - " + b_Connect._Connect-Device.
   end.
   if v-process-list <> ""
   then do:
      publish "putstat" (substitute ("Есть не завершенные процесы &1 ", v-process-list) ).
      Msg = substitute ( "Для обновления схемы БД завершите процессы. &1",  v-process-list).
      return Msg.
   end.
   find first sys-ctrl no-lock.
   find first db no-lock where db.db-num = sys-ctrl.db-num no-error.
   publish "putstat" (substitute ("Понижаем версию БД  ") ).
   find first b_file no-lock where b_file._file-name = "db"  no-error.
   if available b_file
   then do:
      find first b_field of b_file where b_field._Field-Name =  "reserve1-char" no-lock no-error.
      release b_file.
   end.
   mdbverd = int(db.reserve1-char) no-error.
   release db.
   mdbveri = int(b_field._initial ) no-error.
   release _field.
   do trans:
      if mdbverd > mdb-ver
      then do:
         find first db where db.db-num = sys-ctrl.db-num.
         db.reserve1-char = string(mdb-ver).
         release db.
      end.
      if mdbveri > mdb-ver
      then do:
         find first b_file no-lock where b_file._file-name = "db"  no-error.
         if available b_file
         then do:
            find first b_field of b_file where b_field._Field-Name =  "reserve1-char"  no-error.
            b_field._initial = string(mdb-ver).
            release b_file.
            release b_field.
         end.
      end.
      find first db-attr where db-attr.db-num    eq sys-ctrl.db-num
                           and db-attr.attr-code eq  'ver-db':U
      exclusive-lock.
      delete db-attr.
      release sys-ctrl.
      publish "putstat" (substitute ("Версия Бд понижена. Нужен перезапуск Th  ") ).
      return "Для обновление структуры базы запустите TH еще раз.".
   end.
end.
