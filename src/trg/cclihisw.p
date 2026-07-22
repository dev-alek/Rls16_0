block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись шапки истории КЛИЕНТА

Автор: Бахтадзе Наталья Викторовна
Дата создания: 22/01/04
Author: Bakhtadze Natalya
Creation date: 22/01/04

*/

TRIGGER PROCEDURE FOR WRITE OF ub.c-cli-hist.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись шапки истории КЛИЕНТА".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5|&6'
                        ,  ub.c-cli-hist.obj-type
                        , ub.c-cli-hist.obj-code
                        , ub.c-cli-hist.corr-user-db-num
                        , ub.c-cli-hist.chip-num
                        , ub.c-cli-hist.host-code
                        , ub.c-cli-hist.subject
                        ) " }

{ cmp/trg-def.i }

main-block:
do transaction
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  if ub.c-cli-hist.subject = {&table_staff} then do:
    if not g#news
    or g#db-num > 0 then do:
      run str/callnews.p (
        input {&table_c-cli-hist}
        ,input (buffer ub.c-cli-hist:handle)
        ) no-error .
      if error-status:error then do:
        undo main-block, return error return-value .
      end.
    end.
  end.
  else do:
    if
    not g#news   /*пересылаем записи  измененные ПОЛЬЗОВАТЕЛЕМ а не СПН */
    OR (g#news
        and  g#db-num = 0
        and ub.c-cli-hist.is-news = no
        ) /*транзит из УБД1 через ГБД в УБД2*/
        /*здесь надо отсечь данные которые родились в СПН в УБД и ВОЗВРАЩАЮТСЯ в ГБД!!!!*/
    or (g#news
      and g#db-num > 0
      and ub.c-cli-hist.is-news = yes
      )   /*из УБД - записи рожденные СПН*/
    then do:
      run str/callnews.p (
        input {&table_c-cli-hist}
        ,input (buffer ub.c-cli-hist:handle)
        ) no-error .
      if error-status:error then do:
        undo main-block, return error return-value .
      end.
    end. /*if v-send*/
  end.
end.