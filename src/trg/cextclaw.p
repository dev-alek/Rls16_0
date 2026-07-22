block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись c-ext-classif

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/04/04
Author: Bakhtadze Natalya
Creation date: 12/04/04

*/

TRIGGER PROCEDURE FOR WRITE OF ub.c-ext-classif old old-c-ext-classif.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись c-ext-classif".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5|&6|&7|&8|&9'
                        , ub.c-ext-classif.classif-subject
                        , ub.c-ext-classif.classif-name
                        , ub.c-ext-classif.key#_one
                        , ub.c-ext-classif.key#_two
                        , ub.c-ext-classif.key#_three
                        , ub.c-ext-classif.charkey_one
                        , ub.c-ext-classif.charkey_two
                        , ub.c-ext-classif.charkey_three
                        , ub.c-ext-classif.nonunique
                        ) " }
{ cmp/trg-def.i }


main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  if
  not g#news   /*пересылаем записи  измененные ПОЛЬЗОВАТЕЛЕМ а не СПН */
  OR (g#news
      and g#db-num = 0
      and ub.c-ext-classif.corr-user-name <> {&nts-user}
      ) /*транзит из УБД1 через ГБД в УБД2*/
      /*здесь надо отсечь данные которые родились в СПН в УБД и ВОЗВРАЩАЮТСЯ в ГБД!!!!*/
  or (g#news
      and g#db-num > 0
      and ub.c-ext-classif.corr-user-name = {&nts-user}
      )   /*из УБД - записи рожденные СПН*/
  then do:
    run str/callnews.p
      (input {&table_c-ext-classif}
      ,input (buffer ub.c-ext-classif:handle)
      ).
  end.
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_c-ext-classif}
        , input ( buffer ub.c-ext-classif:handle )
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