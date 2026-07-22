block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись истории атрибута связи МЦ с товарами

Автор: Гридчина Полина Дмитриевна
Дата создания: 04/10/07
Author: Polina Gridchina
Creation date: 04/10/07

*/

TRIGGER PROCEDURE FOR WRITE OF ub.c-wth-gds-attr.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись истории атрибута связи МЦ с товарами".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }

define buffer buf_wth-gds-attr for ub.wth-gds-attr.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  if not g#news then do:
    /*проверим реляционность*/
    find first buf_wth-gds-attr no-lock where
               buf_wth-gds-attr.wth-code = c-wth-gds-attr.wth-code
            AND buf_wth-gds-attr.gds-code = c-wth-gds-attr.gds-code
            AND buf_wth-gds-attr.attr-code = c-wth-gds-attr.attr-code
            no-error .
    if not available buf_wth-gds-attr then do:
      message
      vss-workfile vss-revision vss-description skip
      "Неправильная ссылка на атрибут связи МЦ с товарами" skip
      "МЦ" c-wth-gds-attr.wth-code skip
      "Товар" c-wth-gds-attr.gds-code
      "Атрибут" c-wth-gds-attr.attr-code
      view-as alert-box error .
      undo main-block, return error.
    end.
  end.
  if
  not g#news   /*пересылаем записи  измененные ПОЛЬЗОВАТЕЛЕМ а не СПН */
  OR (g#news
      and not ( g#db-num > 0 )
      and ub.c-wth-gds-attr.corr-user-name <> {&nts-user}
      ) /*транзит из УБД1 через ГБД в УБД2*/
      /*здесь надо отсечь данные которые родились в СПН в УБД и ВОЗВРАЩАЮТСЯ в ГБД!!!!*/
  or (g#news
      and ( g#db-num > 0 )
      and ub.c-wth-gds-attr.corr-user-name = {&nts-user}
      )   /*из УБД - записи рожденные СПН*/
  then
  run str/callnews.p
    (input "c-wth-gds-attr"
    ,input (buffer ub.c-wth-gds-attr:handle)
    ).

    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_c-wth-gds-attr}
        , input ( buffer ub.c-wth-gds-attr:handle )
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