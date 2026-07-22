block-level on error undo, throw.
/*

$Revision: 98888aefbee4, 1809, rls $
$Author: druban $
$Date: Fri Mar 15 12:41:42 2019 +0300 $
$Workfile: send-tax.p $
$Archive: str/send-tax.p $

Толчкач пересылки категорий налогов и ставок налогов на кассу из интерфейса

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/09/05
Author: Bakhtadze Natalya
Creation date: 09/09/05

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-pos-type like ub.cash-desk.pos-type no-undo .
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .
DEFINE INPUT PARAMETER action as char no-undo.

define variable vss-revision    as character no-undo init "$Revision: 98888aefbee4, 1809, rls $":u .
define variable vss-author      as character no-undo init "$Author: druban $":u .
define variable vss-date        as character no-undo init "$Date: Fri Mar 15 12:41:42 2019 +0300 $":u .
define variable vss-workfile    as character no-undo init "$Workfile: send-tax.p $":u .
define variable vss-archive     as character no-undo init "$Archive: str/send-tax.p $":u .
define variable vss-description as character no-undo init "Пересылка категорий налогов и ставок налогов на кассу из интерфейса" .
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ str/defc-txn.i "NEW SHARED" }
{ str/defc-txr.i "NEW SHARED" }
{ gbl/getcntxt.i def }

define variable rid# as recid no-undo.
define variable tax-rate-rid as char no-undo init "".
define variable ii as integer no-undo.
define variable choice as integer.
define variable glog as logical no-undo .
define variable v-host-code like ub.sysconf.host-code no-undo .

{ gbl/getcntxt.i get }

{ gbl/hostcode.i
  p-obj-type
  p-obj-code
  v-host-code
}


CASE p-pos-type:
  when {&cd-type-IBM}
  or
  when {&cd-type-IBM-XML} then do:
    FIND FIRST ub.cash-desk NO-LOCK WHERE
              ub.cash-desk.db-num = g#db-num AND
              (ub.cash-desk.pos-type = {&cd-type-IBM}
              or ub.cash-desk.pos-type = {&cd-type-IBM-XML} )
              No-error.
    IF not avail(ub.cash-desk) then do:
        message
        "Передача категорий и ставок налогов" skip
        "реализуется только для касс фирмы IBM."
        view-as alert-box INFORMATION .
        return.
    end.
    if action = "U"
    then do:
      { gbl/chk-actg.i
        v-cntxt-db-num
        v-cntxt-userid
        {&action-head-code-main}
        'actn_cashdesk-taxn_add-def':U
        {&cntxt-object}
        v-host-code
        p-obj-type
        p-obj-code
        0
        0
        0
        true
        glog
      }
    end.
    else do:
      { gbl/chk-actg.i
        v-cntxt-db-num
        v-cntxt-userid
        {&action-head-code-main}
        'actn_cashdesk-taxn_deletion':U
        {&cntxt-object}
        v-host-code
        p-obj-type
        p-obj-code
        0
        0
        0
        true
        glog
      }
    end.
    if NOT glog then return .
  end. /*ibm*/
  when {&cd-type-MAGIA-XML} then do:
    FIND FIRST ub.cash-desk NO-LOCK WHERE
              ub.cash-desk.db-num = g#db-num AND
              ub.cash-desk.pos-type = {&cd-type-IBM} No-error.
    IF not avail(ub.cash-desk) then do:
      message
      "Передача категорий и ставок налогово" skip
      "реализуется только для POS" {&cd-type-MAGIA-XML}
      view-as alert-box INFORMATION .
      return.
    end.
    if not g#news then do:
      { gbl/chk-actg.i
        v-cntxt-db-num
        v-cntxt-userid
        {&action-head-code-main}
        'actn_cashdesk-restaurant_work':U
        {&cntxt-object}
        v-host-code
        p-obj-type
        p-obj-code
        0
        0
        0
        true
        glog
      }
      if NOT glog then return .
    end.
  end. /*when MAGIA*/
END CASE.

for each cash-txn:
    delete cash-txn.
end.
for each cash-txr:
    delete cash-txr.
end.

run gbl/d-askw.w (input "Выбор категорий и ставок налогов для пересылки на кассу",
                    input ((if action = "U" then "Переслать на кассу" else "удалить с кассы") +
                              " категории и ставки налогов"),
                    input "|",
                    input "Все|Выборочно|Отказ",
                    input "||",
                    input 1,
                    input 3,
                    output choice).

if choice  = 3 then return.

if    choice = 1  
   or choice = 5
      then do:
    /*родим таблицу*/

    FOR EACH ub.tax NO-LOCK WHERE ub.tax.to-cashdesk = yes:
        create cash-txn.
        assign
        cash-txn.tax-code = tax.tax-code
        cash-txn.tax-name = tax.tax-name
        .
        _tax-rate:
        FOR EACH ub.tax-rate NO-LOCK WHERE
                          ub.tax-rate.tax-code = ub.tax.tax-code
                      and ub.tax-rate.status_  <>   {&deleted-status-int-full}:
            create cash-txr.
            assign
            cash-txr.tax-code = tax.tax-code
            cash-txr.rate-code = tax-rate.rate-code
            cash-txr.tax-type = tax.tax-type
            cash-txr.host-code = v-host-code
            cash-txr.obj-type = p-obj-type
            cash-txr.obj-code = p-obj-code
            cash-txr.status_ = tax-rate.status_
            cash-txr.rc = ii
            cash-txr.crf = ii
            ii = ii + 1
            .
            { gbl/pftaxval.i recid(ub.tax-rate) 0 0 ? v-host-code p-obj-type p-obj-code cash-txr.rate-value no-error }
            if error-status:error then NEXT _tax-rate.
        END.
    END.
end.
else if choice = 4 then do:
  create cash-txn.
  assign
     cash-txn.tax-code = ?.
end.  
else do:
    tax-rate-rid = "".
    run ref/tax-tree.w (parparentproc,
                   "b-marktax-rate,b-seltax-rate":U,
                   "ALl-TAX-RATES":U,
                   v-host-code,
                   p-obj-type,
                   p-obj-code,
                   ?,
                   input-output tax-rate-rid) no-error .
    if error-status:error then return error.
    if tax-rate-rid = "" then do:
        message "Не выбрано ни одного налога для отсылки на кассу" view-as alert-box.
        return.
    end.
    else do:
            _ii:
    DO  ii = 1 to num-entries(tax-rate-rid) :
        FIND FIRST ub.tax-rate NO-LOCK WHERE recid(tax-rate) = integer(entry(ii,tax-rate-rid)) NO-ERROR.
        if avail ub.tax-rate then do:
            FIND FIRST ub.tax NO-LOCK WHERE ub.tax.tax-code = ub.tax-rate.tax-code No-ERROR.
            if ub.tax.to-cashdesk then do:
                FIND FIRST cash-txn where cash-txn.tax-code = ub.tax.tax-code NO-ERROR.
                IF NOT avail cash-txn then do:
                    create cash-txn.
                    assign
                    cash-txn.tax-code = ub.tax.tax-code
                    cash-txn.tax-name = ub.tax.tax-name
                    .
                    define variable mi as integer no-undo.
                     FOR EACH ub.tax-rate NO-LOCK WHERE
                          ub.tax-rate.tax-code = ub.tax.tax-code
                      and ub.tax-rate.status_  <>   {&deleted-status-int-full}:
                        create cash-txr.
                        assign
                        cash-txr.tax-code = tax.tax-code
                        cash-txr.rate-code = tax-rate.rate-code
                        cash-txr.tax-type = tax.tax-type
                        cash-txr.host-code = v-host-code
                        cash-txr.obj-type = p-obj-type
                        cash-txr.obj-code = p-obj-code
                        cash-txr.status_ = tax-rate.status_
                        cash-txr.rc = mi
                        cash-txr.crf = mi
                        mi = mi + 1
                        .
                        { gbl/pftaxval.i recid(ub.tax-rate) 0 0 ? v-host-code p-obj-type p-obj-code cash-txr.rate-value no-error }
                        if error-status:error then next _ii.
                    END.
                end. /*IF NOT avail cash-txn*/
                
            end. /*tax.to-cashdesk = yes*/
        end. /*avail tax-rate*/
    END. /*DO ii = 1 to*/
    FOR EACH ub.tax where ub.tax.individual = yes AND ub.tax.to-cashdesk = yes:
                    create cash-txn.
                    assign
                    cash-txn.tax-code = ub.tax.tax-code
                    cash-txn.tax-name = ub.tax.tax-name
                    .
    END.

    end.
end.
if can-find(first cash-txr NO-LOCK) OR can-find(first cash-txn) then
      run str/diallog.w (   ?
                    , this-procedure
                    , 'str/sendtaxn.p':U
                    , (string(p-obj-code) + {&delim-par} + action)
                    , if    choice = 4  or choice = 5 then yes else no /*p-auto-go*/
                    , '':U
                    , 'Отправка информации по налогам кассу') no-error .
else do:
    message "Не выбрано ни одного налога, отсылаемого на кассу" view-as alert-box.
end.