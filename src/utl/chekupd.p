block-level on error undo, throw.
/*
$Revision:$
$Author:$
$Date:$
$Workfile:$
$Archive:$

Автор: Рубан Дмитрий Андреевич 
Дата создания: 3 марта 2021 г.
Author:  Ruban Dmitriy Andreevich
Creation date: 3 марта 2021 г.

*/
define variable vss-revision    as character no-undo init "$Revision:$":U .
define variable vss-author      as character no-undo init "$Author:$":U .
define variable vss-date        as character no-undo init "$Date:$":U .
define variable vss-workfile    as character no-undo init "$Workfile:$":U .
define variable vss-archive     as character no-undo init "$Archive:$":U .
define variable vss-description as character no-undo init "Проверка обновления".
{cmp\str-glbl.i }
{ cmp/vssrevis.i }
{ cmp/trg-def.i  new}
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
                     and db-attr.attr-code eq  {&attr-ver-db}
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
      v-process-list = v-process-list + {&new-line} + string (b_Connect._Connect-Pid) + " - " + b_Connect._Connect-Name +  " - " + b_Connect._Connect-Device.
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
                           and db-attr.attr-code eq  {&attr-ver-db}
      exclusive-lock.
      
      delete db-attr.
      release sys-ctrl.
      publish "putstat" (substitute ("Версия Бд понижена. Нужен перезапуск Th  ") ).
   
      return "Для обновление структуры базы запустите TH еще раз.".
   end.
   
   
      
end.    