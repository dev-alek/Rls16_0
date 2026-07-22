block-level on error undo, throw.
/*
$Revision:$
$Author:$
$Date:$
$Workfile:$
$Archive:$

Автор: Рубан Дмитрий Андреевич 
Дата создания: 9 марта 2020 г.
Author:  Ruban Dmitriy Andreevich
Creation date: 9 марта 2020 г.

*/
define variable vss-revision    as character no-undo init "$Revision:$":U .
define variable vss-author      as character no-undo init "$Author:$":U .
define variable vss-date        as character no-undo init "$Date:$":U .
define variable vss-workfile    as character no-undo init "$Workfile:$":U .
define variable vss-archive     as character no-undo init "$Archive:$":U .
define variable vss-description as character no-undo init "".
define variable mError as logical no-undo.
{ cmp/vssrevis.i }
{ gbl/getcntxt.i def }
{ cmp/trg-def.i }
{ utl/proc-async.i proc_def}
{ str/edo.i nosend}
/*
session:system-alert-boxes = yes.
session:appl-alert-boxes = yes.
session:debug-alert = yes.
*/
mPublishHand = this-procedure .
define variable mParam as character no-undo.
mParam = GetPARAMAsunc( 1).
if mParam eq ? then do:
   run PutstatAsunc( "error   Получение данных было преврвано пользователем." ).
   { utl/proc-async.i proc_end}
   return.
end.
mdb-num-local  = int(mParam).
define variable MdebugStr as character no-undo. 
MdebugStr = GetParamAsunc( 2).
if MdebugStr ne ? 
then
   mdebug = logical(MdebugStr) no-error.
if mdebug eq ?
then
   mdebug = no.

if mDiadocApi eq ?
then
   run PutstatAsunc(substitute("Error Не удалось создать объект Diadoc.DiadocClient. Проверьте установку библиоткеки Diadoc.") ).
 
else do:
   run PutstatAsunc (substitute ("Версия библиотеки Diadoc &1" , mDiadocApi:GetFullVersion())).   
   define variable mFirst as logical no-undo init no.
   run PutstatAsunc(substitute("Загрузка данных по БД &1",mdb-num-local) ).
   g#esys = yes.
   Block-extsys:   
   for each ext-system  where ext-system.db-num  eq mdb-num-local
                          and ext-system.esys-type eq {&bef-openxml-type-is_diadoc}
   no-lock,
      first ext-system-attr where ext-system-attr.db-num  eq ext-system.db-num
                                       and ext-system-attr.esys-id eq ext-system.esys-id
                                       and ext-system-attr.esya-attr-code eq {&attr-esys-host-code}
   no-lock:
      mFirst = yes.
      run PutstatAsunc(substitute("Загрузка данных по ВС &1",ext-system.esys-id) ).
      v-cntxt-host-code-obj = int(ext-system-attr.esya-attr-value).
      g#esys-source-esys = ext-system.esys-id.
      mext-sys = ext-system.esys-id.
      if    StopCheck()
      then 
         leave Block-extsys.
         
      mDiadocConnection = conectbylogin().
      if mDiadocConnection eq ?
      then do:
         run PutstatAsunc ( substitute("error Не удалось подключиться к серверу Диадок в БД &1 ВС &2" ,
                                  mdb-num-local, mext-sys)) .
         mError= yes.
      end.
      else do:
         run getNewUpd.
      end.
      
      
      if    StopCheck()
      then 
         leave Block-extsys.
      run PutstatAsunc(substitute("Загрузка данных по ВС &1 завершена.",ext-system.esys-id) ).
   end.
   if    StopCheck()
   then .
   else if not mFirst
   then
      run PutstatAsunc( substitute("Нет ВС Диадок для БД &1" , mdb-num-local)).
   else if not mError
   then do: 
      run PutstatAsunc( substitute("Данные загруженны в БД &1" , mdb-num-local)).
   end.
   else
      run PutstatAsunc( substitute("Данные загруженны в БД &1 загружены с ошибками." , mdb-num-local)).
end.
if    StopCheck()
then do:
   run PutstatAsunc( "error   Получение данных было преврвано пользователем." ).
end.
release object mDiadocApi.      
{ utl/proc-async.i proc_end}
      