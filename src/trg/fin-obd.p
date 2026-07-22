block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на yдаление  финансового обязательства

Автор: Чернова Светлана Александровна
Дата создания: 03/20/06
Author: Svetlana Chernova
Creation date: 03/20/06


*/

TRIGGER PROCEDURE FOR DELETE OF ub.fin-ob .

define variable  vss-revision    as character no-undo init "$Revision$":U .
define variable  vss-author      as character no-undo init "$Author$":U .
define variable  vss-date        as character no-undo init "$Date$":U .
define variable  vss-workfile    as character no-undo init "$Workfile$":U .
define variable  vss-archive     as character no-undo init "$Archive$":U .
define variable  vss-description as character no-undo init "Триггер на yдаление финансового обязательства ".
{ cmp/vssrevis.i "substitute('&1|&2', ub.fin-ob.doc-code, ub.fin-ob.host-code) " }
{ cmp/trg-def.i }
{ gbl/cur-time.i }
main-block :
do transaction
on error undo main-block, return error
:

/* проверка на наличие таких же фо по накладной */
define buffer other_fin-ob        for ub.fin-ob.
define buffer other_fin-ob-before for ub.fin-ob-before.
define buffer other_fin-ob-trn    for ub.fin-ob-trn.
define buffer buf_c-fin-ob        for ub.c-fin-ob.

define variable v-trn-code as character no-undo .
define variable v-fin-ob as character no-undo .
define variable v-col-fin-ob as integer no-undo .
define variable v-type-pay-orig  as character no-undo .
define variable v-type-pay       as character no-undo .
define variable v-pay as character no-undo .
define variable v-ok as logical no-undo .
define variable v-not-flag as logical no-undo .
define variable v-galki as logical no-undo .
define variable v-date as date no-undo .
define variable v-time as integer no-undo .


find first contract no-lock where  contract.contract-code = fin-ob.contract-code no-error .

v-ok = true .
v-not-flag = true .
if available contract then do:
    if lookup ( contract.usl-opl , {&o-postavka} ) > 0
      then
        assign
          v-type-pay-orig = "по поставке"
          v-pay = {&o-postavka}
        .
      else
        assign
            v-type-pay-orig = "по реализации"
            v-pay = {&o-realiz}
        .
end.


for each fin-ob-trn no-lock where fin-ob-trn.doc-code  = fin-ob.doc-code
    on error undo, return error :
    v-trn-code = fin-ob-trn.trn-doc-code.
    v-fin-ob =  "" .
    v-col-fin-ob =  0 .
    if v-trn-code <> "" then do:
        for each other_fin-ob-trn no-lock where other_fin-ob-trn.trn-doc-code  = v-trn-code and
                                                other_fin-ob-trn.doc-code      <> fin-ob.doc-code ,
            first other_fin-ob no-lock where other_fin-ob.doc-code  = other_fin-ob-trn.doc-code ,
              first contract   no-lock where contract.contract-code = other_fin-ob.contract-code and
                                             lookup( contract.usl-opl , v-pay ) > 0
            on error undo, return error :
            v-fin-ob = v-fin-ob + " ФО " + string(other_fin-ob-trn.doc-code) + "," .
            v-col-fin-ob = v-col-fin-ob + 1.
        end. /* for each */
    end.
    if v-pay = {&o-realiz} then do:
        if v-trn-code <> "" then do:
        for each other_fin-ob-trn no-lock where other_fin-ob-trn.trn-doc-code  = v-trn-code and
                                                other_fin-ob-trn.doc-code      <> fin-ob.doc-code ,
            first other_fin-ob-before no-lock where other_fin-ob-before.before-code  = other_fin-ob-trn.doc-code ,
              first contract   no-lock where contract.contract-code = other_fin-ob-before.contract-code and
                                             lookup( contract.usl-opl , v-pay ) > 0
            on error undo, return error :
            v-fin-ob = v-fin-ob + "  ПФО " + string(other_fin-ob-trn.doc-code).
            v-col-fin-ob = v-col-fin-ob + 1.
        end. /* for each */
       end.
    end. /* o-realiz */


    if v-col-fin-ob > 0 then
    message "Финансовое обязательство было создано по накладной  " v-trn-code skip
             "Тип оплаты : " v-type-pay-orig skip
             "По этой же накладной было одновременно создано еще : " v-col-fin-ob   skip
             "Вн. номера : " v-fin-ob                                     skip
             "По накладной ФО и ПФО автоматически генерируются один раз "  skip
             "   по одному типу оплаты (поставке или реализации)       "  skip
             " "                                                          skip  skip
             "( ДА  - удалить финансовое обязательство " fin-ob.doc-code " , "  skip
             "      без возможности повторной автоматической генерации по накладной "  skip
             " НЕТ - не удалять ) "
             view-as alert-box question
             buttons yes-no
             title "Вопрос"
             update v-ok
             .

end. /* for each */
v-not-flag  = v-ok.
if v-ok = false then   UNDO , RETURN ERROR.

/*-----------------------------------------------------------------------------------------------------------------------*/
find first fin-connect NO-LOCK
  where fin-connect.host-code = fin-ob.host-code
    and fin-connect.fin-ob-code = fin-ob.doc-code
no-error .
if available fin-connect then do:
  MESSAGE
    "Нельзя удалять связанные фин. обязательства! Сначала удалите связь с платежем."
   VIEW-AS ALERT-BOX ERROR TITLE "Удаление невозможно!" .
   UNDO , RETURN ERROR.
end.
for each fin-ob-tax  exclusive-lock  where
    fin-ob-tax.doc-code  = fin-ob.doc-code  and
    fin-ob-tax.host-code = fin-ob.host-code
    on error undo main-block, return error
    :
       delete  fin-ob-tax.
end.
for each fin-ob-trn no-lock where
    fin-ob-trn.doc-code  = fin-ob.doc-code  and
    fin-ob-trn.host-code = fin-ob.host-code
    on error undo main-block, return error
    :
    for each trn-doc  exclusive-lock   where
       trn-doc.doc-code = fin-ob-trn.trn-doc-code
        on error undo main-block, return error  :
       /*  проверка - есть ли другие ФО и ПФО по этой накладной */
        v-galki = true .
            for each other_fin-ob-trn no-lock where other_fin-ob-trn.trn-doc-code =  fin-ob-trn.trn-doc-code and
                                                    other_fin-ob-trn.doc-code     <>  fin-ob-trn.doc-code ,
                first other_fin-ob no-lock where other_fin-ob.doc-code  = other_fin-ob-trn.doc-code ,
                  first contract   no-lock where contract.contract-code = other_fin-ob.contract-code and
                                                lookup( contract.usl-opl , v-pay ) > 0
                  on error undo, return error :
                  /* есть - зачищать галки в накладных нельзя */
                  v-galki = false .
            end. /* for each */

            for each other_fin-ob-trn no-lock where other_fin-ob-trn.trn-doc-code =  fin-ob-trn.trn-doc-code and
                                                    other_fin-ob-trn.doc-code     <>  fin-ob-trn.doc-code ,
                first other_fin-ob-before no-lock where other_fin-ob-before.before-code  = other_fin-ob-trn.doc-code ,
                  first contract   no-lock where contract.contract-code = other_fin-ob-before.contract-code and
                                                lookup( contract.usl-opl , v-pay ) > 0
                  on error undo, return error :
                  /* есть - зачищать галки в накладных нельзя */
                  v-galki = false .
            end. /* for each */

              if v-galki = true  then do:
                  if v-pay = {&o-realiz} then do:
                      assign
                          trn-doc.cr-expfo    = false
                          trn-doc.expfo-date  = 01/01/1990
                      no-error .
                  end.
                  else do:
                      assign
                          trn-doc.cr-incfo    = false
                          trn-doc.incfo-date  = 01/01/1990
                      no-error .
                  end.
                  if trn-doc.cr-expfo = false and
                     trn-doc.cr-incfo = false then do:
                    assign
                      trn-doc.cr-incorexpfo = false.
                  end.
                    if error-status :error then
                    message vss-workfile vss-revision vss-description skip
                        "Ошибка корректировки накладной" skip
                        error-status :get-message(1)
                        view-as alert-box information .
              end.
    end. /* for each trn-doc */
    for each c-trn-doc  exclusive-lock   where
       c-trn-doc.doc-code = fin-ob-trn.trn-doc-code
        on error undo main-block, return error  :
       /*  проверка - есть ли другие ФО и ПФО по этой накладной */
        v-galki = true .
            for each other_fin-ob-trn no-lock where other_fin-ob-trn.trn-doc-code =  fin-ob-trn.trn-doc-code and
                                                    other_fin-ob-trn.doc-code     <>  fin-ob-trn.doc-code ,
                first other_fin-ob no-lock where other_fin-ob.doc-code  = other_fin-ob-trn.doc-code ,
                  first contract   no-lock where contract.contract-code = other_fin-ob.contract-code and
                                                lookup( contract.usl-opl , v-pay ) > 0
                  on error undo, return error :
                  /* есть - зачищать галки в накладных нельзя */
                  v-galki = false .
            end. /* for each */

            for each other_fin-ob-trn no-lock where other_fin-ob-trn.trn-doc-code =  fin-ob-trn.trn-doc-code and
                                                    other_fin-ob-trn.doc-code     <>  fin-ob-trn.doc-code ,
                first other_fin-ob-before no-lock where other_fin-ob-before.before-code  = other_fin-ob-trn.doc-code ,
                  first contract   no-lock where contract.contract-code = other_fin-ob-before.contract-code and
                                                lookup( contract.usl-opl , v-pay ) > 0
                  on error undo, return error :
                  /* есть - зачищать галки в накладных нельзя */
                  v-galki = false .
            end. /* for each */

              if v-galki = true  then do:
                  if v-pay = {&o-realiz} then do:
                      assign
                          c-trn-doc.cr-expfo    = false
                          c-trn-doc.expfo-date  = 01/01/1990
                      no-error .
                  end.
                  else do:
                      assign
                          c-trn-doc.cr-incfo    = false
                          c-trn-doc.incfo-date  = 01/01/1990
                      no-error .
                  end.
                  if c-trn-doc.cr-expfo = false and
                     c-trn-doc.cr-incfo = false then do:
                    assign
                      c-trn-doc.cr-incorexpfo = false.
                  end.

                    if error-status :error then
                    message vss-workfile vss-revision vss-description skip
                        "Ошибка корректировки накладной" skip
                        error-status :get-message(1)
                        view-as alert-box information .
              end.
    end. /* for each c-trn-doc */


end.
for each fin-ob-trn  exclusive-lock  where
    fin-ob-trn.doc-code  = fin-ob.doc-code  and
    fin-ob-trn.host-code = fin-ob.host-code
    on error undo main-block, return error
    :
       delete  fin-ob-trn.
end.
for each fin-gds-part  exclusive-lock  where
    fin-gds-part.fin-ob-code  = fin-ob.doc-code  and
    fin-gds-part.host-code = fin-ob.host-code
    on error undo main-block, return error
    :
       delete  fin-gds-part.
end.
for each fin-ob-before  exclusive-lock  where
    fin-ob-before.doc-code  = fin-ob.doc-code  and
    fin-ob-before.host-code = fin-ob.host-code
    on error undo main-block, return error
    :
       assign
         fin-ob-before.status_= {&g___new}
         fin-ob-before.doc-code = ""       .

end.
    if fin-ob.status_ = {&fin-fact} then  /* пересчитаем баланс по договору */
      run str/calc-bal.p (input "finob", input no, input fin-ob.doc-type, input fin-ob.host-code, input fin-ob.contract-code, input fin-ob.sum-contract, input fin-ob.sum-rubl, input fin-ob.sum-base) .

    run cur-time in this-procedure(output v-date, output v-time).
    create buf_c-fin-ob.
    buffer-copy fin-ob to buf_c-fin-ob
    assign
    buf_c-fin-ob.chip-num           = next-value (s-corr-chip, {&db-name_schema})
    buf_c-fin-ob.corr-time          = v-time
    buf_c-fin-ob.corr-user-db-num   = g#db-num
    buf_c-fin-ob.corr-user-name     = g#userid
    buf_c-fin-ob.corr-date          = v-date
    buf_c-fin-ob.is-doc-del         = true
    .
    if fin-ob.status_ = {&fin-fact} then  buf_c-fin-ob.is-del  = true .
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_delete}
        , input {&table_fin-ob}
        , input ( buffer ub.fin-ob:handle )
    ) no-error.
    if error-status :error
    then do:
        undo, return error substitute( "&2&1Ошибка при отправке в систему OpenXML команды на удаление записи&1&3&1&4"
                            , {&new-line}
                            , vss-workfile
                            , return-value
                            , error-status :get-message ( 1 ) ).
    end.
    end.
end.