block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись истории номинала МЦ

Автор: Бахтадзе Наталья Викторовна
Дата создания: 21/01/04
Author: Bakhtadze Natalya
Creation date: 21/01/04

*/

TRIGGER PROCEDURE FOR WRITE OF ub.c-wth-par.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись истории номинала МЦ".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4'
                           , ub.c-wth-par.wth-code
                           , ub.c-wth-par.par-code
                           , ub.c-wth-par.corr-user-db-num
                           , ub.c-wth-par.chip-num
                           ) " }
{ cmp/trg-def.i }

define buffer buf_wth-par for ub.wth-par.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  if not g#news then do:
    /*проверим реляционность*/
    find first buf_wth-par no-lock where
               buf_wth-par.wth-code = c-wth-par.wth-code
            AND buf_wth-par.par-code = c-wth-par.par-code
              no-error .
    if not available buf_wth-par then do:
      message
      vss-workfile vss-revision vss-description skip
      "Неправильная ссылка на МЦ" skip
      "МЦ" c-wth-par.wth-code skip
      "Номинал" c-wth-par.par-code
      view-as alert-box error .
      undo main-block, return error.
    end.
  end.
  if
  not g#news   /*пересылаем записи  измененные ПОЛЬЗОВАТЕЛЕМ а не СПН */
  OR (g#news
      and not ( g#db-num > 0 )
      and ub.c-wth-par.corr-user-name <> {&nts-user}
      ) /*транзит из УБД1 через ГБД в УБД2*/
      /*здесь надо отсечь данные которые родились в СПН в УБД и ВОЗВРАЩАЮТСЯ в ГБД!!!!*/
  or (g#news
      and ( g#db-num > 0 )
      and ub.c-wth-par.corr-user-name = {&nts-user}
      )   /*из УБД - записи рожденные СПН*/
  then
  run str/callnews.p
    (input "c-wth-par"
    ,input (buffer ub.c-wth-par:handle)
    ).

    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_c-wth-par}
        , input ( buffer ub.c-wth-par:handle )
    ) no-error.
    if error-status :error
    then do:
        undo, return error substitute( "&2&1Ошибка при отправке записи в систему OpenXML&1&3&1&4"
                             , {&new-line}
                             , vss-workfile
                             , return-value
                             , error-status :get-message ( 1 ) ).
    end.
    end.
end.