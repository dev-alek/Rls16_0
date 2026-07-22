block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Тригер на корректировку ТПЛ для ценообразованиЯ

Автор: Чернова Светлана Александровна
Дата создания: 02/06/06
Author: Svetlana Chernova
Creation date: 02/06/06

*/

TRIGGER PROCEDURE FOR WRITE OF ub.price-list-type OLD old_price-list-type.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Тригер на корректировку ТПЛ для ценообразованиЯ".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ gbl/cur-time.i }
{ gbl/waitfram.i }
define variable v-today      as date      no-undo.
define variable start-time   as integer   no-undo .
define variable v-chg-fields as character no-undo .


main-block :
do transaction
on error undo main-block, return error
:

/* если родительский прописать все детям */
define buffer ch_price-list-type for ub.price-list-type  .

if ub.price-list-type.under-type-list = 0 then do:
  for each ch_price-list-type exclusive-lock where
           ch_price-list-type.stts            = integer({&pdf-new}) and
           ch_price-list-type.plt-main-id     = ub.price-list-type.plt-id and
           ch_price-list-type.plt-main-db-num = ub.price-list-type.plt-db-num and
           ch_price-list-type.under-type-list = 1
           :
          assign
              ch_price-list-type.calc-method        =  ub.price-list-type.calc-method
              ch_price-list-type.create-price-doc   =  ub.price-list-type.create-price-doc
              ch_price-list-type.fix-cource-crc-base=  ub.price-list-type.fix-cource-crc-base
              ch_price-list-type.fix-cource-crc-doc =  ub.price-list-type.fix-cource-crc-doc
              ch_price-list-type.have-rs-qnty-group =  ub.price-list-type.have-rs-qnty-group
              ch_price-list-type.have-rs-sum-group  =  ub.price-list-type.have-rs-sum-group
              ch_price-list-type.only-gbd           =  ub.price-list-type.only-gbd
              ch_price-list-type.priority           =  ub.price-list-type.priority
              ch_price-list-type.send-cassa         =  ub.price-list-type.send-cassa
              ch_price-list-type.use-cassa          =  ub.price-list-type.use-cassa
              ch_price-list-type.work-date          =  ub.price-list-type.work-date
              ch_price-list-type.curr-code          =  ub.price-list-type.curr-code
              ch_price-list-type.qgr-db-num         =  ub.price-list-type.qgr-db-num
              ch_price-list-type.qgr-id             =  ub.price-list-type.qgr-id
              ch_price-list-type.sgr-db-num         =  ub.price-list-type.sgr-db-num
              ch_price-list-type.sgr-id             =  ub.price-list-type.sgr-id
              ch_price-list-type.have-rs-turn-group =  ub.price-list-type.have-rs-turn-group
              ch_price-list-type.have-tog-db-num    =  ub.price-list-type.have-tog-db-num
              ch_price-list-type.have-tog-id        =  ub.price-list-type.have-tog-id
              ch_price-list-type.use-cash-pay       =  ub.price-list-type.use-cash-pay
              ch_price-list-type.use-pay-type       =  ub.price-list-type.use-pay-type
              .
  end.
end.

run cur-time in this-procedure ( output v-today, output start-time ) .
      create ub.c-price-list-type.
      BUFFER-COPY ub.price-list-type TO ub.c-price-list-type
      assign
        ub.c-price-list-type.chip-num           = next-value (s-corr-chip, {&db-name_schema})
        ub.c-price-list-type.corr-time          = start-time
        ub.c-price-list-type.corr-user-db-num   = g#db-num
        ub.c-price-list-type.corr-user-name     = g#userid
        ub.c-price-list-type.corr-date          = v-today
    .

   if ub.price-list-type.stts <> integer({&pdf-new}) then do:
       for each ub.batchprocess exclusive-lock
           where ub.batchprocess.bp_type   = {&btpr-type-twotpl} and
                 ub.batchprocess.BP_Status     = {&btpr-normal} and
                 ( ub.batchprocess.CharKey_One   = string(recid(ub.price-list-type)) or
                   ub.batchprocess.CharKey_Two   = string(recid(ub.price-list-type)) )
                 :
                 delete ub.batchprocess.
       end.
end.

if g#db-num = 0 or (g#db-num > 0 and g#news = false ) then do:
  run str/callnews.p
    ( input "price-list-type"
    , input (buffer ub.price-list-type:handle)
    ) no-error .

  if error-status:error then do:
     message
      vss-workfile vss-revision vss-description skip
      "Ошибка при передаче в новости price-list-type" skip
      return-value skip
      view-as alert-box error .
      return error.
  end.
end.


/* Проверка и изменение действующих цен по НТПЛ */
if g#news then do:
    if  ub.price-list-type.main = false  and
        ub.price-list-type.stts = integer({&pdf-new}) and
        (
        not (
            ub.price-list-type.bgr-id      = old_price-list-type.bgr-id and
            ub.price-list-type.bgr-db-num  = old_price-list-type.bgr-db-num ) or
            ub.price-list-type.priority   <> old_price-list-type.priority
         ) then do:
                  run waitfram-show in this-procedure ("Изменение действующих цен МПЛ...") .
                      for each ub.price-all exclusive-lock where
                          ub.price-all.plt-db-num = ub.price-list-type.plt-db-num and
                          ub.price-all.plt-id     = ub.price-list-type.plt-id
                          :
                          if ub.price-all.plt-priority <> ub.price-list-type.priority   then ub.price-all.plt-priority = ub.price-list-type.priority   .
                          if ub.price-all.bgr-id       <> ub.price-list-type.bgr-id     then ub.price-all.bgr-id       = ub.price-list-type.bgr-id     .
                          if ub.price-all.bgr-db-num   <> ub.price-list-type.bgr-db-num then ub.price-all.bgr-db-num   = ub.price-list-type.bgr-db-num .
                      end.
                  run waitfram-hide in this-procedure  .
           end.
end.


if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_price-list-type}
        , input ( buffer ub.price-list-type:handle )
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