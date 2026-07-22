block-level on error undo, throw.
/*

$Revision: 82c3c9aafa8c, 420, rls $
$Author: EShklyar $
$Date: Wed Jan 20 20:29:51 2016 +0400 $
$Workfile: alc-type-news.p $
$Archive: utl/alc-type-news.p $

Передача таблицы alc-type-gds по новостям 

Автор: Шкляр Елена Львовна
Дата создания: 21/26/07
Author: Shklyar Elena
Creation date: 02/26/07

*/

define variable vss-revision    as character no-undo init "$Revision: 82c3c9aafa8c, 420, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Wed Jan 20 20:29:51 2016 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: alc-type-news.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/alc-type-news.p $":U .
define variable vss-description as character no-undo init "Передача таблицы alc-type-gds по новостям".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ gbl/waitfram.i }

  define buffer buf_alc-type-gds for ub.alc-type-gds .
  define variable v-message     as character no-undo .
  
  for each ub.alc-type-gds:
   run waitfram-show in this-procedure
    (INPUT 'Отправка алкогольных атрибутов в новости ...'
    ).
  
   run nws/cmd-del.p
      ( input "alc-type-gds":U
      ,input (buffer ub.alc-type-gds:handle)
      ,input ""
      ) no-error .
   if error-status :error
   then do:
      assign
         v-message = substitute( "&1. Ошибка при отправке в новости команды на удаление записи. &2&3&2&4", vss-workfile, {&new-line}, return-value, error-status :get-message ( error-status :num-messages ) )
      .
      return error v-message .
   end.
  
    run str/callnews.p
      (input {&table_alc-type-gds}
      ,input (buffer ub.alc-type-gds:handle)
      ) no-error .
   if error-status :error
   then do:
      return error substitute("&1. Невозможно маршрутизировать alc-type-gds для отправки в новости &2&3&2&4", vss-workfile, {&new-line}, return-value, error-status :get-message ( 1 ) ).
   end.
  
end.
run waitfram-hide in this-procedure .