block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Тригер на корректировку Групп объектов для ценообразовани

Автор: Чернова Светлана Александровна
Дата создания: 02/06/06
Author: Svetlana Chernova
Creation date: 02/06/06

*/

TRIGGER PROCEDURE FOR WRITE OF ub.grp-obj-price OLD old_grp-obj-price.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Тригер на корректировку Групп объектов для ценообразовани".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ gbl/cur-time.i }

define variable v-today     as date      no-undo.
define variable start-time  as integer   no-undo .
define variable v-chg-fields as character no-undo .



main-block :
do transaction
on error undo main-block, return error
:
   /* Истори

      run cur-time in this-procedure(output v-today, output start-time).
      create ub.c-grp-obj-price.
      BUFFER-COPY ub.grp-obj-price TO ub.c-grp-obj-price
      assign
        ub.c-grp-obj-price.chip-num           = next-value (s-corr-chip, {&db-name_schema})
        ub.c-grp-obj-price.corr-time          = start-time
        ub.c-grp-obj-price.corr-user-db-num   = g#db-num
        ub.c-grp-obj-price.corr-user-name     = g#userid
        ub.c-grp-obj-price.corr-date          = v-today
    .
   */

if g#db-num = 0 or ( g#db-num <> 0 and g#news = false  )  then do:
  run str/callnews.p
    (input "grp-obj-price"
    ,input (buffer ub.grp-obj-price:handle)
    ) no-error .
  if error-status:error then do:
     message
      vss-workfile vss-revision vss-description skip
      "Ошибка при передаче в новости grp-obj-price" skip
      return-value skip
      view-as alert-box error .
      return error.
  end.
 end.


    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_grp-obj-price}
        , input ( buffer ub.grp-obj-price:handle )
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