block-level on error undo, throw.
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
procedure vss-get-info :
  define output parameter p-vss-revision    like vss-revision    no-undo .
  define output parameter p-vss-author      like vss-author      no-undo .
  define output parameter p-vss-date        like vss-date        no-undo .
  define output parameter p-vss-workfile    like vss-workfile    no-undo .
  define output parameter p-vss-archive     like vss-archive     no-undo .
  define output parameter p-vss-description like vss-description no-undo .
  assign
    p-vss-revision    = vss-revision
    p-vss-author      = vss-author
    p-vss-date        = vss-date
    p-vss-workfile    = vss-workfile
    p-vss-archive     = vss-archive
    p-vss-description = vss-description
  .
end procedure.
procedure vss-get-parameters :
  define output parameter p-vss-parameters as character no-undo .
end procedure.
define new global shared variable g#vssrevis-logger as handle    no-undo .
define variable v-vssrevis-logevent                 as logical   no-undo init false .
define variable v-vssrevis-logger                   as handle    no-undo .
procedure vss-logevent :
  define input  parameter p-extra-paramters as character no-undo .
  define variable v-vssrevis-parameters as character no-undo .
  do
  on error undo, return error return-value
  :
    if  valid-handle(v-vssrevis-logger)
    and v-vssrevis-logger :get-signature("logevent") <> ""
    then do:
      run vss-get-parameters in this-procedure
        (output v-vssrevis-parameters
        ).
      run logevent in v-vssrevis-logger
        (input vss-workfile
        ,input vss-revision
        ,input v-vssrevis-parameters
        ,input p-extra-paramters
        ).
    end.
  end.
end procedure.
assign
  v-vssrevis-logger = g#vssrevis-logger
.
if  valid-handle(v-vssrevis-logger)
and v-vssrevis-logger :get-signature("logevent") <> ""
then do:
  assign
    v-vssrevis-logevent = true
  .
  run vss-logevent in this-procedure (input vss-description) .
end.
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define   shared variable g#auto as logical no-undo.
define   shared variable g#news as logical no-undo.
define   shared variable g#oxml as logical no-undo.
define   shared variable g#esys as logical no-undo.
define   shared variable g#news-source-db as integer no-undo.
define   shared variable g#esys-source-esys as integer no-undo.
define   shared variable g#db-num as integer   no-undo .
define   shared variable g#userid as character no-undo .
define   shared variable g#passwd as character no-undo .
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEFINE NEW SHARED TEMP-TABLE cash-txn no-undo
FIELD tax-code like ub.tax.tax-code
FIELD tax-name like ub.tax.tax-name
FIELD news-action as logical
index pi IS UNIQUE PRIMARY tax-code.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define NEW SHARED temp-table cash-txr no-undo
  field tax-code    like ub.tax.tax-code
  field rate-code   like ub.tax-rate.rate-code
  field host-code   like ub.sysconf.host-code
  field obj-type    like ub.clients.obj-type
  field obj-code    like ub.clients.obj-code
  field tax-type    like ub.tax.tax-type
  field status_     like ub.tax-rate-value.status_
  field rate-value  as decimal
  field rc          as recid
  field crf         as integer
  field news-action as logical
  index pi is unique primary tax-code host-code obj-type obj-code status_ rc
  index crf-i  crf host-code obj-type obj-code rc
.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable rid# as recid no-undo.
define variable tax-rate-rid as char no-undo init "".
define variable ii as integer no-undo.
define variable choice as integer.
define variable glog as logical no-undo .
define variable v-host-code like ub.sysconf.host-code no-undo .
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run mainmenu_getcntxt in parparentproc
    (output v-cntxt-db-num
    ,output v-cntxt-userid
    ,output v-cntxt-level
    ,output v-cntxt-host-code-obj
    ,output v-cntxt-obj-type
    ,output v-cntxt-obj-code
    ,output v-cntxt-db-num-obj
    ,output v-cntxt-is-admin
    ) .
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  )  .
CASE p-pos-type:
  when 'IBM':U
  or
  when 'IBM-XML':U then do:
    FIND FIRST ub.cash-desk NO-LOCK WHERE
              ub.cash-desk.db-num = g#db-num AND
              (ub.cash-desk.pos-type = 'IBM':U
              or ub.cash-desk.pos-type = 'IBM-XML':U )
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
define variable vss-include-info5 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_cashdesk-taxn_add-def':U
    ,input  'object':U
    ,input  v-host-code
    ,input  p-obj-type
    ,input  p-obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output glog
    )  .
end.
    end.
    else do:
define variable vss-include-info6 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_cashdesk-taxn_deletion':U
    ,input  'object':U
    ,input  v-host-code
    ,input  p-obj-type
    ,input  p-obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output glog
    )  .
end.
    end.
    if NOT glog then return .
  end.
  when 'MAGIA-XML':U then do:
    FIND FIRST ub.cash-desk NO-LOCK WHERE
              ub.cash-desk.db-num = g#db-num AND
              ub.cash-desk.pos-type = 'IBM':U No-error.
    IF not avail(ub.cash-desk) then do:
      message
      "Передача категорий и ставок налогово" skip
      "реализуется только для POS" 'MAGIA-XML':U
      view-as alert-box INFORMATION .
      return.
    end.
    if not g#news then do:
define variable vss-include-info7 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_cashdesk-restaurant_work':U
    ,input  'object':U
    ,input  v-host-code
    ,input  p-obj-type
    ,input  p-obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output glog
    )  .
end.
      if NOT glog then return .
    end.
  end.
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
    FOR EACH ub.tax NO-LOCK WHERE ub.tax.to-cashdesk = yes:
        create cash-txn.
        assign
        cash-txn.tax-code = tax.tax-code
        cash-txn.tax-name = tax.tax-name
        .
        _tax-rate:
        FOR EACH ub.tax-rate NO-LOCK WHERE
                          ub.tax-rate.tax-code = ub.tax.tax-code
                      and ub.tax-rate.status_  <>   'удал':U:
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
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftaxval in g#library
  (input  recid(ub.tax-rate)
  ,input  0
  ,input  0
  ,input  ?
  ,input  v-host-code
  ,input  p-obj-type
  ,input  p-obj-code
  ,output cash-txr.rate-value
  ) no-error .
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
                      and ub.tax-rate.status_  <>   'удал':U:
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
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftaxval in g#library
  (input  recid(ub.tax-rate)
  ,input  0
  ,input  0
  ,input  ?
  ,input  v-host-code
  ,input  p-obj-type
  ,input  p-obj-code
  ,output cash-txr.rate-value
  ) no-error .
                        if error-status:error then next _ii.
                    END.
                end.
            end.
        end.
    END.
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
                    , (string(p-obj-code) + chr(4) + action)
                    , if    choice = 4  or choice = 5 then yes else no
                    , '':U
                    , 'Отправка информации по налогам кассу') no-error .
else do:
    message "Не выбрано ни одного налога, отсылаемого на кассу" view-as alert-box.
end.
