block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

<>

Автор: Чернова Светлана Александровна
Дата создания: 02/14/06
Author: Svetlana Chernova
Creation date: 02/14/06

*/

TRIGGER PROCEDURE FOR WRITE OF ub.price-list-type-cassa old old_price-list-type-cassa.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ gbl/cur-time.i }

define variable v-today     as date      no-undo.
define variable start-time  as integer   no-undo .
define variable v-chg-fields as character no-undo .
define variable  p-sec as integer   no-undo .

main-block :
do transaction
on error undo main-block, return error
:

if available old_price-list-type-cassa then do:
    buffer-compare ub.price-list-type-cassa except sys-date sys-time sys-time-chr to old_price-list-type-cassa
    save result in v-chg-fields.
    if v-chg-fields = "" then return .
end.

p-sec = next-value (s-corr-chip, {&db-name_schema}) .

run cur-time in this-procedure(output v-today, output start-time).
      create ub.c-price-list-type-cassa.
      BUFFER-COPY ub.price-list-type-cassa TO ub.c-price-list-type-cassa
      assign
        ub.c-price-list-type-cassa.chip-num           = p-sec
        ub.c-price-list-type-cassa.corr-time          = start-time
        ub.c-price-list-type-cassa.corr-user-db-num   = g#db-num
        ub.c-price-list-type-cassa.corr-user-name     = g#userid
        ub.c-price-list-type-cassa.corr-date          = v-today
    .

      find first ub.c-price-list-type no-lock where
                 ub.c-price-list-type.chip-num    = ub.c-price-list-type-cassa.chip-num and
                 ub.c-price-list-type.plt-id      = ub.c-price-list-type-cassa.plt-id and
                 ub.c-price-list-type.plt-db-num  = ub.c-price-list-type-cassa.plt-db-num
                 no-error .
      if not available ub.c-price-list-type then do:
            find first ub.price-list-type no-lock where
                      ub.price-list-type.plt-id      = ub.c-price-list-type-cassa.plt-id and
                      ub.price-list-type.plt-db-num  = ub.c-price-list-type-cassa.plt-db-num
                      no-error .

            if available ub.price-list-type then do :
                create ub.c-price-list-type.
                BUFFER-COPY ub.price-list-type TO ub.c-price-list-type
                assign
                  ub.c-price-list-type.chip-num           = ub.c-price-list-type-cassa.chip-num
                  ub.c-price-list-type.corr-time          = start-time
                  ub.c-price-list-type.corr-user-db-num   = g#db-num
                  ub.c-price-list-type.corr-user-name     = g#userid
                  ub.c-price-list-type.corr-date          = v-today
              .
            end.
      end.
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_price-list-type-cassa}
        , input ( buffer ub.price-list-type-cassa:handle )
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