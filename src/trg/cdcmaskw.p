block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись для таблицы ИСТОРИЯ МАСОК дисконтных карт

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/12/04
Author: Bakhtadze Natalya
Creation date: 04/12/04

*/

TRIGGER PROCEDURE FOR WRITE OF ub.c-dis-card-mask OLD old-c-dis-card-mask .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись для таблицы история маско дисконтных карт".
{ cmp/vssrevis.i "substitute('&1|&2|&3'
                         , ub.c-dis-card-mask.mask-num
                        , ub.c-dis-card-type-attr.corr-user-db-num
                        , ub.c-dis-card-type-attr.chip-num

                         ) " }

{ cmp/trg-def.i }
{ gbl/cur-time.i }

define buffer buf_dis-card-mask for ub.dis-card-mask.


main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  if
  not g#news   /*пересылаем записи  измененные ПОЛЬЗОВАТЕЛЕМ а не СПН */
  OR (g#news
      and not ( g#db-num > 0 )
      and ub.c-dis-card-mask.corr-user-name <> {&nts-user}
      ) /*транзит из УБД1 через ГБД в УБД2*/
      /*здесь надо отсечь данные которые родились в СПН в УБД и ВОЗВРАЩАЮТСЯ в ГБД!!!!*/
  or (g#news
      and ( g#db-num > 0 )
      and ub.c-dis-card-mask.corr-user-name = {&nts-user}
      )   /*из УБД - записи рожденные СПН*/
  then

  run str/callnews.p
    (input "c-dis-card-mask"
    ,input (buffer ub.c-dis-card-mask:handle)
    ).
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_c-dis-card-mask}
        , input ( buffer ub.c-dis-card-mask:handle )
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