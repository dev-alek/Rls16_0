block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись истории СЕЗОННЫХ КОЭФФИЦИЕНТОВ

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/08/03
Author: Bakhtadze Natalya
Creation date: 12/08/03

*/

TRIGGER PROCEDURE FOR WRITE OF ub.c-s-coeff.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись истории СЕЗОННЫХ КОЭФФИЦИЕНТОВ".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5|&6|&7'
                         , ub.c-s-coeff.gds-code
                         , ub.c-s-coeff.host-code
                         , ub.c-s-coeff.obj-type
                         , ub.c-s-coeff.obj-code
                         , ub.c-s-coeff.s-date
                         , ub.c-s-coeff.corr-user-db-num
                         , ub.c-s-coeff.chip-num
                         ) " }
{ cmp/trg-def.i }

define variable v-db-num like ub.db.db-num no-undo .
define buffer buf_s-coeff for ub.s-coeff.
define buffer buf_c-gds-hist for ub.c-gds-hist.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  if not g#news then do:
    /*проверим реляционность*/
    find first buf_c-gds-hist no-lock where
              buf_c-gds-hist.gds-code = c-s-coeff.gds-code
           AND buf_c-gds-hist.obj-type = c-s-coeff.obj-type
           AND buf_c-gds-hist.obj-code = c-s-coeff.obj-code
           AND buf_c-gds-hist.host-code = c-s-coeff.host-code
           AND buf_c-gds-hist.chip-num = c-s-coeff.chip-num
           AND buf_c-gds-hist.corr-user-db-num = c-s-coeff.corr-user-db-num no-error .
    if buf_c-gds-hist.action <> integer({&hn-delete}) then do:
      find first buf_s-coeff no-lock where
                buf_s-coeff.obj-type = c-s-coeff.obj-type
            AND buf_s-coeff.obj-code = c-s-coeff.obj-code
            AND buf_s-coeff.host-code = c-s-coeff.host-code
            AND buf_s-coeff.gds-code = c-s-coeff.gds-code
            AND buf_s-coeff.s-date = c-s-coeff.s-date
                no-error .
      if not available buf_s-coeff then do:
        message
        vss-workfile vss-revision vss-description skip
        "Неправильная ссылка на СЕЗОННЫЙ КОЭФФИЦИЕНТ ТОВАРА" skip
        "Фирма" c-s-coeff.host-code
        "объект" c-s-coeff.obj-type  c-s-coeff.obj-code
        "Товар" c-s-coeff.gds-code
        "Дата" c-s-coeff.s-date
        view-as alert-box error .
        undo main-block, return error.
      end.
    end.
  end.
  if NOT (c-s-coeff.obj-type  = "":U
          AND c-s-coeff.obj-code = 0) then do:
   { gbl/objdbnum.i ub.c-s-coeff.obj-type ub.c-s-coeff.obj-code v-db-num }
   if not g#news and g#db-num <> v-db-num and g#db-num <> 0 then do:
      message
      vss-workfile vss-revision vss-description skip
      "Нельзя изменять запись ИСТОРИИ СЕЗОННОГО КОЭФФИЦИЕНТА ТОВАРА НА ОБЪЕКТЕ в БД, отличной от БД объекта, если она не ГБД" skip
      "Номер текущей БД" g#db-num "Номер БД объекта" v-db-num
      view-as alert-box error .
      undo, return error .
    end.
  end.
 if
  not g#news   /*пересылаем записи  измененные ПОЛЬЗОВАТЕЛЕМ а не СПН */
  OR (g#news
      and not ( g#db-num > 0 )
      and ub.c-s-coeff.corr-user-name <> {&nts-user}
      ) /*транзит из УБД1 через ГБД в УБД2*/
      /*здесь надо отсечь данные которые родились в СПН в УБД и ВОЗВРАЩАЮТСЯ в ГБД!!!!*/
  or (g#news
      and ( g#db-num > 0 )
      and ub.c-s-coeff.corr-user-name = {&nts-user}
      )   /*из УБД - записи рожденные СПН*/
  then do:
    run str/callnews.p
      (input "c-s-coeff"
      ,input (buffer ub.c-s-coeff:handle)
      ).
  end.
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_c-s-coeff}
        , input ( buffer ub.c-s-coeff:handle )
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