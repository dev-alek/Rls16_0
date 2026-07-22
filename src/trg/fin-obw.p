block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись финансового обязательства

Автор: Чернова Светлана Александровна
Дата создания: 03/20/06
Author: Svetlana Chernova
Creation date: 03/20/06

*/

TRIGGER PROCEDURE FOR WRITE OF ub.fin-ob OLD old_fin-ob.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись финансового обязательства ".
{ cmp/vssrevis.i "substitute('&1|&2', ub.fin-ob.doc-code, ub.fin-ob.host-code) " }
{ cmp/trg-def.i  }
{ gbl/cur-time.i }
{ trg/factord.i  }
{ gbl/thbjattr.i }
{ str/libofarh.i }

define variable v-date as date no-undo .
define variable v-time as integer no-undo .
define buffer buf_c-fin-ob for ub.c-fin-ob.
define buffer buf_sysconf  for ub.sysconf.
define variable v-value-character as character no-undo .
define variable v-value-date      as date   no-undo .
define variable v-value-decimal   as decimal   no-undo .
define variable v-fo-buyer-nws    as integer   no-undo .
define variable v-fo-supp-nws     as integer   no-undo .
define variable v-value-logical   as logical   no-undo .
define variable par-type          as character no-undo .
define variable v-activ-side as logical   no-undo .
main-block :
do transaction
on error undo main-block, return error
:
/* Общие параметры создания и хождения по новостям */
run adm/shattri.p (
  input "get":U
  ,input ""
  ,input 0
  ,input {&attr-fin-global}
  ,input  ""
  ,output v-value-character
  ,output v-value-date
  ,output v-value-decimal
  ,output v-fo-buyer-nws
  ,output v-value-logical
  ,output par-type
  ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
  ) no-error .

find first thbjattr_thbj-attr where
           thbjattr_thbj-attr.obj-code  = 0  and
           thbjattr_thbj-attr.obj-type  = ""  and
           thbjattr_thbj-attr.prop-code = {&attr-fin-global_fo-buyer-nws} and
           thbjattr_thbj-attr.upper-prop-code = {&attr-fin-global}  no-error .
.
if error-status :error then do:
   message
     vss-workfile vss-revision vss-description skip
     error-status :get-message(1) skip
     return-value skip
     ""
     view-as alert-box error
   .
    return error return-value .
end.
v-fo-buyer-nws = thbjattr_thbj-attr.property-value-integer .

find first thbjattr_thbj-attr where
           thbjattr_thbj-attr.obj-code  = 0  and
           thbjattr_thbj-attr.obj-type  = ""  and
           thbjattr_thbj-attr.prop-code = {&attr-fin-global_fo-supp-nws} and
           thbjattr_thbj-attr.upper-prop-code = {&attr-fin-global}  no-error .
.
if error-status :error then do:
   message
     vss-workfile vss-revision vss-description skip
     error-status :get-message(1) skip
     return-value skip
     ""
     view-as alert-box error
   .
    return error return-value .
end.
v-fo-supp-nws = thbjattr_thbj-attr.property-value-integer .


if ub.fin-ob.pay-date <> old_fin-ob.pay-date then do:
   ub.fin-ob.user-name-pay = g#userid .
end.

find first buf_sysconf no-lock where buf_sysconf.host-code = ub.fin-ob.host-code.

  if not g#news then do:
    if ub.fin-ob.doc-type = {&expense} then do:
        if buf_sysconf.firm-db-num <> g#db-num then do:
          message
          vss-workfile vss-revision vss-description skip
          "Нельзя изменять запись ФИН обязательств в БД, отличной от главной БД фирмы" skip
          "Номер текущей БД" g#db-num "Номер главной БД фирмы" buf_sysconf.firm-db-num
          view-as alert-box error .
          undo, return error .
        end.
    end.
  end.

  if not new(ub.fin-ob) then do:
  /* доп проверки */
  /*
      if ub.fin-ob.sum-doc  = 0 or ub.fin-ob.sum-doc = ?  or
         ub.fin-ob.sum-base = 0 or ub.fin-ob.sum-base = ? or
         ub.fin-ob.sum-rubl = 0 or ub.fin-ob.sum-rubl = ?
         then do:
          message vss-workfile vss-revision vss-description skip
          "Не задана сумма финансового обязательства !" view-as alert-box information .
          return error.
      end.
    */
    if not g#news then do:
      if ub.fin-ob.receiver-code = 0 or ub.fin-ob.receiver-code = ? then do:
        message vss-workfile vss-revision vss-description skip
        "Не задан код контрагента !"  view-as alert-box information .
        return error .
      end.
      if ub.fin-ob.payer-code = 0 or ub.fin-ob.payer-code = ? then do:
        message
        vss-workfile vss-revision vss-description skip
        "Не задан код плательщика !"  view-as alert-box information .
        return error .
      end.

      if not can-find (first ub.clients where ub.clients.obj-code = ub.fin-ob.receiver-code
                                      and ub.clients.obj-type = ub.fin-ob.receiver-type no-lock )
        then do:
        message
        vss-workfile vss-revision vss-description skip
        "Не верно выбран получатель !"  view-as alert-box information .
        return error .
      end.
      if not can-find (first ub.clients where ub.clients.obj-code = ub.fin-ob.payer-code
                                          and ub.clients.obj-type = ub.fin-ob.payer-type no-lock )
        then do:
        message vss-workfile vss-revision vss-description skip
        "Не верно выбран плательшик !"  view-as alert-box information .
        return error .
      end.
   /*------*/
    end.
    run cur-time in this-procedure(output v-date, output v-time).

    create buf_c-fin-ob.
    buffer-copy old_fin-ob to buf_c-fin-ob
    assign
    buf_c-fin-ob.chip-num           = next-value (s-corr-chip, {&db-name_schema})
    buf_c-fin-ob.corr-time          = v-time
    buf_c-fin-ob.corr-user-db-num   = g#db-num
    buf_c-fin-ob.corr-user-name     = g#userid
    buf_c-fin-ob.corr-date          = v-date
    .

  end.
  if ub.fin-ob.status_ = {&fin-fact} and not g#news then do:
      if ub.fin-ob.doc-type = {&expense} then do:  /* ФО поставщика */
          if g#db-num = 0 and v-fo-supp-nws = 1 then do:
                run str/callnews.p
                (input "fin-ob"
                ,input (buffer ub.fin-ob:handle)
                ) no-error .
              if error-status:error then do:
                message
                  vss-workfile vss-revision vss-description skip
                  "Ошибка при передаче в новости ФО" skip
                  return-value skip
                  view-as alert-box error .
                  return error.
              end.
          end.
      end.
      if ub.fin-ob.doc-type = {&income} then do:   /* ФО покупателя */
          /* определение активной стороны для ФО */
          { str/fo-activ.i
            ub.fin-ob.host-code
            ub.fin-ob.doc-code
            g#db-num
            v-activ-side
          }

        if v-activ-side = true and v-fo-buyer-nws = 0 then do:  /* только с активной стороны */
                run str/callnews.p
                (input "fin-ob"
                ,input (buffer ub.fin-ob:handle)
                ) no-error .
              if error-status:error then do:
                message
                  vss-workfile vss-revision vss-description skip
                  "Ошибка при передаче в новости ФО" skip
                  return-value skip
                  view-as alert-box error .
                  return error.
              end.
          end.
        if g#db-num = 0 and v-fo-buyer-nws = 1 then do: /* только с ГБД */
                run str/callnews.p
                (input "fin-ob"
                ,input (buffer ub.fin-ob:handle)
                ) no-error .
              if error-status:error then do:
                message
                  vss-workfile vss-revision vss-description skip
                  "Ошибка при передаче в новости ФО" skip
                  return-value skip
                  view-as alert-box error .
                  return error.
              end.
          end.
      end.
  end.
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_fin-ob}
        , input ( buffer ub.fin-ob:handle )
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