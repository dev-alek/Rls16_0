block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись истории атрибута бар-кода

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/14/07
Author: Bakhtadze Natalya
Creation date: 03/14/07

*/

TRIGGER PROCEDURE FOR write OF ub.c-bar-code-attr .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись истории атрибута бар-кода".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4':u~
                              ,ub.c-bar-code-attr.b-code~
                              ,ub.c-bar-code-attr.attr-code~
                              ,ub.c-bar-code-attr.corr-user-db-num~
                              ,ub.c-bar-code-attr.chip-num~
                              )" }
{ cmp/trg-def.i  }

do
on error undo, return error
:
  if
  not g#news   /*пересылаем записи  измененные ПОЛЬЗОВАТЕЛЕМ а не СПН */
  OR (g#news
      and not ( g#db-num > 0 )
      and ub.c-bar-code-attr.corr-user-name <> {&nts-user}
      ) /*транзит из УБД1 через ГБД в УБД2*/
      /*здесь надо отсечь данные которые родились в СПН в УБД и ВОЗВРАЩАЮТСЯ в ГБД!!!!*/
  or (g#news
      and ( g#db-num > 0 )
      and ub.c-bar-code-attr.corr-user-name = {&nts-user}
      )   /*из УБД - записи рожденные СПН*/
  then do:
      run str/callnews.p
        (input {&table_c-bar-code-attr}
    ,input (buffer ub.c-bar-code-attr:handle)
    ).
 end.

  if g#oxml = yes
  then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_c-bar-code-attr}
        , input ( buffer ub.c-bar-code-attr:handle )
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