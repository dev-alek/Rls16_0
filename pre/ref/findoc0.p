block-level on error undo, throw.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define input-output parameter p-doc-rec as recid no-undo.
define input parameter p-mode                         as character no-undo .
define input parameter p-silent                       as logical no-undo .
define input parameter p-host-code           like ub.fin-doc.host-code            no-undo . define input parameter p-fin-doc-code        like ub.fin-doc.fin-doc-code         no-undo . define input parameter p-an-uchet-code       like ub.fin-doc.an-uchet-code        no-undo . define input parameter p-an-uchet-value      like ub.fin-doc.an-uchet-value       no-undo . define input parameter p-base-rate           like ub.fin-doc.base-rate            no-undo . define input parameter p-base-scale          like ub.fin-doc.base-scale           no-undo . define input parameter p-cel-nazn-code       like ub.fin-doc.cel-nazn-code        no-undo . define input parameter p-cel-nazn-value      like ub.fin-doc.cel-nazn-value       no-undo . define input parameter p-contract-code       like ub.fin-doc.contract-code        no-undo . define input parameter p-contract-curr       like ub.fin-doc.contract-curr        no-undo . define input parameter p-contract-rate       like ub.fin-doc.contract-rate        no-undo . define input parameter p-contract-scale      like ub.fin-doc.contract-scale       no-undo . define input parameter p-cor-acc             like ub.fin-doc.cor-acc              no-undo . define input parameter p-cor-acc-value       like ub.fin-doc.cor-acc-value        no-undo . define input parameter p-cor-acc1            like ub.fin-doc.cor-acc1             no-undo . define input parameter p-cor-acc1-value      like ub.fin-doc.cor-acc1-value       no-undo . define input parameter p-curr-code           like ub.fin-doc.curr-code            no-undo . define input parameter p-doc-date            like ub.fin-doc.doc-date             no-undo . define input parameter p-shift-date          like ub.fin-doc.shift-dat            no-undo . define input parameter p-shift-num           like ub.fin-doc.shift-num            no-undo . define input parameter p-shift-name          like ub.fin-doc.shift-name           no-undo . define input parameter p-enclosure           like ub.fin-doc.enclosure            no-undo . define input parameter p-exch-rate           like ub.fin-doc.exch-rate            no-undo . define input parameter p-exch-scale          like ub.fin-doc.exch-scale           no-undo . define input parameter p-f104                like ub.fin-doc.f104                 no-undo . define input parameter p-f105                like ub.fin-doc.f105                 no-undo . define input parameter p-f106                like ub.fin-doc.f106                 no-undo . define input parameter p-f107                like ub.fin-doc.f107                 no-undo . define input parameter p-f108                like ub.fin-doc.f108                 no-undo . define input parameter p-f109                like ub.fin-doc.f109                 no-undo . define input parameter p-f110                like ub.fin-doc.f110                 no-undo . define input parameter p-f22                 like ub.fin-doc.f22                  no-undo . define input parameter p-f23                 like ub.fin-doc.f23                  no-undo . define input parameter p-fact-date           like ub.fin-doc.fact-date            no-undo . define input parameter p-fin-doc-type        like ub.fin-doc.fin-doc-type         no-undo . define input parameter p-fin-ext-doc-type    like ub.fin-doc.fin-ext-doc-type     no-undo . define input parameter p-in-doc-code         like ub.fin-doc.in-doc-code          no-undo . define input parameter p-in-host-code        like ub.fin-doc.in-host-code         no-undo . define input parameter p-including           like ub.fin-doc.including            no-undo . define input parameter p-nazn-pl             like ub.fin-doc.nazn-pl              no-undo . define input parameter p-naznach-plat        like ub.fin-doc.naznach-plat         no-undo . define input parameter p-ocher-pl            like ub.fin-doc.ocher-pl             no-undo . define input parameter p-out-doc-code        like ub.fin-doc.out-doc-code         no-undo . define input parameter p-out-host-code       like ub.fin-doc.out-host-code        no-undo . define input parameter p-pay-date            like ub.fin-doc.pay-date             no-undo . define input parameter p-payer-bank-name     like ub.fin-doc.payer-bank-name      no-undo . define input parameter p-payer-bank-city     like ub.fin-doc.payer-bank-city      no-undo . define input parameter p-payer-bik           like ub.fin-doc.payer-bik            no-undo . define input parameter p-payer-c-schet       like ub.fin-doc.payer-c-schet        no-undo . define input parameter p-payer-code          like ub.fin-doc.payer-code           no-undo . define input parameter p-payer-code-schet    like ub.fin-doc.payer-code-schet     no-undo . define input parameter p-payer-dop1          like ub.fin-doc.payer-dop1           no-undo . define input parameter p-payer-dop2          like ub.fin-doc.payer-dop2           no-undo . define input parameter p-payer-inn           like ub.fin-doc.payer-inn            no-undo . define input parameter p-payer-kpp           like ub.fin-doc.payer-kpp            no-undo . define input parameter p-payer-name          like ub.fin-doc.payer-name           no-undo . define input parameter p-payer-okpo          like ub.fin-doc.payer-okpo           no-undo . define input parameter p-payer-passport      like ub.fin-doc.payer-passport       no-undo . define input parameter p-payer-r-schet       like ub.fin-doc.payer-r-schet        no-undo . define input parameter p-payer-type          like ub.fin-doc.payer-type           no-undo . define input parameter p-perm-date           like ub.fin-doc.perm-date            no-undo . define input parameter p-prn-doc-code        like ub.fin-doc.prn-doc-code         no-undo . define input parameter p-PS                  like ub.fin-doc.PS                   no-undo . define input parameter p-receiver-bank-name  like ub.fin-doc.receiver-bank-name   no-undo . define input parameter p-receiver-bank-city  like ub.fin-doc.receiver-bank-city   no-undo . define input parameter p-receiver-bik        like ub.fin-doc.receiver-bik         no-undo . define input parameter p-receiver-c-schet    like ub.fin-doc.receiver-c-schet     no-undo . define input parameter p-receiver-code       like ub.fin-doc.receiver-code        no-undo . define input parameter p-receiver-code-schet like ub.fin-doc.receiver-code-schet  no-undo . define input parameter p-receiver-dop1       like ub.fin-doc.receiver-dop1        no-undo . define input parameter p-receiver-dop2       like ub.fin-doc.receiver-dop2        no-undo . define input parameter p-receiver-inn        like ub.fin-doc.receiver-inn         no-undo . define input parameter p-receiver-kpp        like ub.fin-doc.receiver-kpp         no-undo . define input parameter p-receiver-name       like ub.fin-doc.receiver-name        no-undo . define input parameter p-receiver-okpo       like ub.fin-doc.receiver-okpo        no-undo . define input parameter p-receiver-passport   like ub.fin-doc.receiver-passport    no-undo . define input parameter p-receiver-r-schet    like ub.fin-doc.receiver-r-schet     no-undo . define input parameter p-receiver-type       like ub.fin-doc.receiver-type        no-undo . define input parameter p-srok-pl             like ub.fin-doc.srok-pl              no-undo . define input parameter p-stat-pl             like ub.fin-doc.stat-pl              no-undo . define input parameter p-str-podr-code       like ub.fin-doc.str-podr-code        no-undo . define input parameter p-str-podr-type       like ub.fin-doc.str-podr-type        no-undo . define input parameter p-str-podr-name       like ub.fin-doc.str-podr-name        no-undo . define input parameter p-sum-base            like ub.fin-doc.sum-base             no-undo . define input parameter p-sum-doc             like ub.fin-doc.sum-doc              no-undo . define input parameter p-sum-rubl            like ub.fin-doc.sum-rubl             no-undo . define input parameter p-sum-contr           like ub.fin-doc.sum-contr            no-undo . define input parameter p-trn-doc-code        like ub.fin-doc.trn-doc-code         no-undo . define input parameter p-vid-opl             like ub.fin-doc.vid-opl              no-undo . define input parameter p-vid-plat            like ub.fin-doc.vid-plat             no-undo .
define input parameter p-con-sum-rubl        like ub.fin-doc.con-sum-rubl         no-undo . define input parameter p-con-sum-base        like ub.fin-doc.con-sum-base         no-undo . define input parameter p-con-sum-doc         like ub.fin-doc.con-sum-doc          no-undo . define input parameter p-con-sum-contr       like ub.fin-doc.con-sum-contr        no-undo . define input parameter p-con-stat            like ub.fin-doc.con-stat             no-undo . define input parameter p-payer-sign1               like ub.fin-doc.payer-sign1                no-undo . define input parameter p-payer-sign2               like ub.fin-doc.payer-sign2                no-undo . define input parameter p-payer-sign3               like ub.fin-doc.payer-sign3                no-undo . define input parameter p-payer-sign4               like ub.fin-doc.payer-sign4                no-undo . define input parameter p-receiver-sign1               like ub.fin-doc.receiver-sign1                no-undo . define input parameter p-receiver-sign2               like ub.fin-doc.receiver-sign2                no-undo . define input parameter p-receiver-sign3               like ub.fin-doc.receiver-sign3                no-undo . define input parameter p-receiver-sign4               like ub.fin-doc.receiver-sign4                no-undo . define input parameter p-obj-type                  like ub.fin-doc.obj-type                  no-undo . define input parameter p-obj-code                  like ub.fin-doc.obj-code                  no-undo . define input parameter p-doc-author                like ub.fin-doc.doc-author                no-undo . define input parameter p-fact-author               like ub.fin-doc.fact-author               no-undo . define input parameter p-cashbookid               like ub.fin-doc.CashBookId                no-undo .
define temp-table tt0-fin-doc-tax no-undo like ub.fin-doc-tax.
define input parameter table for tt0-fin-doc-tax.
define temp-table tt0-fin-doc-attr no-undo like ub.fin-doc-attr.
define input parameter table for tt0-fin-doc-attr.
define input parameter p-save-payment as logical no-undo .
define temp-table tt0-payment no-undo like ub.payment.
define input parameter table for tt0-payment.
define variable vss-revision    as character no-undo init "$Revision: d6caaa2cda62, 3048, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Чт май 12 16:29:49 2022 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: findoc0.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/findoc0.p $":U .
define variable vss-description as character no-undo init "Сохранение изменений в платежных документах".
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
define variable v-db-num like ub.db.db-num no-undo .
define variable v-obj-db-num as integer no-undo init -1.
define variable v-base-code like ub.sysconf.base-code no-undo .
define variable v-correct-inn as logical no-undo .
define variable v-correct as logical no-undo .
define variable v-err-mess as character no-undo .
define variable v-acc as decimal no-undo .
define variable v-year-start-date as date no-undo .
define variable v-year-end-date as date no-undo .
define variable v-is-obj    as logical no-undo .
define variable accum-rubl as decimal no-undo .
define variable accum-base as decimal no-undo .
define variable accum-doc as decimal no-undo .
define variable accum-contr as decimal no-undo .
define variable v-type as character no-undo .
define variable v-author  as character no-undo .
define variable v-ret-mess as character no-undo .
define variable v-pmnt-code as character no-undo .
define variable v-full-pmnt-code as character no-undo .
define variable v-found as logical no-undo .
define variable v-cash-book-place as character no-undo .
define variable v-cash-book as integer no-undo .
define variable v-is-auto-obj as logical no-undo .
define variable v-flag-shift as logical no-undo .
define buffer buf_sysconf  for ub.sysconf.
define buffer buf_fin-doc for ub.fin-doc.
define buffer buf_clients for ub.clients.
define buffer buf_currency for ub.currency.
define buffer buf_fin-schet for ub.fin-schet.
define buffer buf_contract  for ub.contract.
define buffer buf_fin-code-cor-acc for ub.fin-code-cor-acc.
define buffer buf_fin-code-an-uchet for ub.fin-code-an-uchet.
define buffer buf_fin-code-cel-nazn for ub.fin-code-cel-nazn.
define buffer buf_clients-obj for ub.clients.
define buffer buf_fin-connect for ub.fin-connect.
define buffer buf_fin-ob      for ub.fin-ob.
define buffer buf0_payment for ub.payment.
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
def var vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
procedure clntattr-code :
  define input  parameter p-code           as character no-undo .
  define output parameter p-type           as character no-undo .
  define output parameter p-format         as character no-undo .
  define output parameter p-label          as character no-undo .
  define output parameter p-user-can-edit  as logical   no-undo .
  define output parameter p-output-display as logical   no-undo .
  define output parameter p-other          as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-code in g#attr-lib
      (input  p-code
      ,output p-type
      ,output p-format
      ,output p-label
      ,output p-user-can-edit
      ,output p-output-display
      ,output p-other
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-tooltip :
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-tooltip in g#attr-lib
      (input  p-code
      ,output p-tooltip
      ,output p-label
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-value :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.clients-attr.attr-code  no-undo .
  define output parameter p-value    like ub.clients-attr.attr-value no-undo .
  define output parameter p-type     as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-value in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-value
      ,output p-type
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-write :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.clients-attr.attr-code  no-undo .
  define input  parameter p-value    like ub.clients-attr.attr-value no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-write in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,input  p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-exist :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.clients-attr.attr-code  no-undo .
  define output parameter p-exist    as logical  no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-exist in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-delete :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.clients-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo.
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-delete in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-copy-to :
  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .
  define input  parameter p-code     as character no-undo .
  define input  parameter p-bh       as handle no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-copy-to in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,input  p-bh
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-news :
  define input  parameter p-code           as character no-undo .
  define output parameter p-news           as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-news in g#attr-lib
      (input  p-code
      ,output p-news
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-get-archive-attr :
  define output parameter p-archive-attr-list as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-get-archive-attr in g#attr-lib
      (output  p-archive-attr-list
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-get-auto-author-attr :
  define output parameter p-archive-attr-list as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-get-auto-author-attr in g#attr-lib
      (output  p-archive-attr-list
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-get-archive-by-type :
  define input  parameter p-archive-type      as character no-undo .
  define output parameter p-archive-attr-list as character no-undo .
  define variable vss-description as character no-undo initial "clntattr-get-archive-by-type-01: возвращает список атрибутов для складского архива".
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-get-archive-by-type in g#attr-lib
      (input  p-archive-type
      ,output p-archive-attr-list
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-vat-register :
  define input parameter p-obj-type like ub.clients.obj-type no-undo .
  define input parameter p-obj-code like ub.clients.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-vat-register in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-requisite-alc-decl :
  define input parameter p-obj-type like ub.clients.obj-type no-undo .
  define input parameter p-obj-code like ub.clients.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-requisite-alc-decl in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-manual-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-manual-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-batch-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-batch-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
define new global shared variable g#lib-farh as handle no-undo .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure fd-attr-code :
  do
  on error undo, return error
  :
    define input  parameter p-code           as character no-undo .
    define output parameter p-type           as character no-undo .
    define output parameter p-format         as character no-undo .
    define output parameter p-label          as character no-undo .
    define output parameter p-user-can-edit  as logical   no-undo .
    define output parameter p-output-display as logical   no-undo .
    define output parameter p-other          as character no-undo .
    case p-code :
            when 'shift-date':U then do:     assign     p-label = "Дата смены"     p-type = 'T':U      p-format = "99/99/9999"     p-label = "Дата смены"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'shift-num':U then do:     assign     p-label = "П.смены"     p-type = 'I':U      p-format = "99"     p-label = "П.смены"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'shift-name':U then do:     assign     p-label = "№ смены"     p-type = 'C':U      p-format = "X(2)"     p-label = "№ смены"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'barcode':U then do:     assign     p-label = "Штрих-код"     p-type = 'C':U      p-format = "X(20)"     p-label = "Штрих-код"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'lockid':U then do:     assign     p-label = "ID блокировки чека"     p-type = 'C':U      p-format = "X(2)"     p-label = "ID блокировки чека"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'cover_sheet':U then do:     assign     p-label = "Разбиение по номиналам"     p-type = 'C':U      p-format = "X(4000)"     p-label = "Разбиение по номиналам"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'pre-vedom':U then do:     assign     p-label = "Атрибут для препроводительной ведомости"     p-type = 'C':U      p-format = "X(256)"     p-label = "Атрибут для препроводительной ведомости"     p-user-can-edit  = false     p-output-display = false     p-other = '':u      .   end.
            when 'contr-kb':U then do:     assign     p-label = "Код кассовой книги получателя\отправителя при перемещении ДС между кассами"     p-type = 'I':U      p-format = ">>>9"     p-label = "Код кассовой книги получателя\отправителя при перемещении ДС между кассами"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
      otherwise do:
        undo, return error "неизвестный атрибут платежа" + " " + p-code .
      end.
    end.
  end.
end procedure.
procedure fd-attr-tooltip :
  do
  on error undo, return error
  :
    define input  parameter p-code    as character no-undo .
    define output parameter p-tooltip as character no-undo .
    define output parameter p-label   as character no-undo .
    case p-code :
            when 'shift-date':U then do:     assign     p-tooltip = "Дата смены"     p-label = "Дата смены" .   end.
            when 'shift-num':U then do:     assign     p-tooltip = "П.смены"     p-label = "П.смены" .   end.
            when 'shift-name':U then do:     assign     p-tooltip = "№ смены"     p-label = "№ смены" .   end.
            when 'barcode':U then do:     assign     p-tooltip = "Штрих-код"     p-label = "Штрих-код" .   end.
            when 'lockid':U then do:     assign     p-tooltip = "ID блокировки чека"     p-label = "ID блокировки чека" .   end.
            when 'cover_sheet':U then do:     assign     p-tooltip = "Разбиение по номиналам"     p-label = "Разбиение по номиналам" .   end.
            when 'pre-vedom':U then do:     assign     p-tooltip = "Атрибут для препроводительной ведомости"     p-label = "Атрибут для препроводительной ведомости" .   end.
            when 'contr-kb':U then do:     assign     p-tooltip = "Код кассовой книги получателя\отправителя при перемещении ДС между кассами"     p-label = "Код кассовой книги получателя\отправителя при перемещении ДС между кассами" .   end.
      otherwise do:
        undo, return error "неизвестный атрибут платежа" + " " + p-code .
      end.
    end.
  end.
end procedure.
procedure fin-doc-attr-write :
 do
 on error undo, return error return-value
 :
define input parameter p-host-code     like ub.fin-doc-attr.host-code  no-undo .
define input parameter p-fin-doc-code  like ub.fin-doc-attr.fin-doc-code   no-undo .
define input parameter p-attr-code     like ub.fin-doc-attr.attr-code  no-undo .
define input parameter p-attr-value    like ub.fin-doc-attr.attr-value no-undo .
define variable  v-format         as character no-undo .
define variable  v-label          as character no-undo .
define variable  v-user-can-edit  as logical   no-undo .
define variable  v-output-display as logical   no-undo .
define variable  v-other          as character no-undo .
define variable  v-type           as character no-undo .
define buffer buf_fin-doc-attr for ub.fin-doc-attr.
run fd-attr-code in this-procedure
                                  (input  p-attr-code
                                  ,output v-type
                                  ,output v-format
                                  ,output v-label
                                  ,output v-user-can-edit
                                  ,output v-output-display
                                  ,output v-other
                                  ) no-error .
if error-status :error then do:
  undo, return error return-value .
end.
find first buf_fin-doc-attr  exclusive-lock  where
          buf_fin-doc-attr.attr-code    = p-attr-code
      AND buf_fin-doc-attr.host-code    = p-host-code
      AND buf_fin-doc-attr.fin-doc-code     = p-fin-doc-code  no-error .
  if not available  buf_fin-doc-attr then do:
      create buf_fin-doc-attr.
      assign
      buf_fin-doc-attr.attr-code    = p-attr-code
      buf_fin-doc-attr.attr-value   = p-attr-value
      buf_fin-doc-attr.host-code    = p-host-code
      buf_fin-doc-attr.fin-doc-code     = p-fin-doc-code
      .
  end.
  else do:
       assign
       buf_fin-doc-attr.attr-value = p-attr-value.
  end.
 end.
end procedure.
procedure fd-attr-exist :
  do
  on error undo, return error
  :
    define input parameter p-host-code     like ub.fin-doc-attr.host-code  no-undo .
    define input parameter p-fin-doc-code  like ub.fin-doc-attr.fin-doc-code   no-undo .
    define input parameter p-code          like ub.fin-doc-attr.attr-code  no-undo .
    define output parameter p-exist   as logical  no-undo .
    define buffer buf_fin-doc-attr for ub.fin-doc-attr .
    define variable  v-type           as character no-undo .
    define variable  v-format         as character no-undo .
    define variable  v-label          as character no-undo .
    define variable  v-user-can-edit  as logical   no-undo .
    define variable  v-output-display as logical   no-undo .
    define variable  v-other          as character no-undo .
    run fd-attr-code in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_fin-doc-attr exclusive-lock
      where buf_fin-doc-attr.host-code  = p-host-code
        and buf_fin-doc-attr.fin-doc-code  = p-fin-doc-code
        and buf_fin-doc-attr.attr-code = p-code
      no-error .
    if  available buf_fin-doc-attr then do:
      p-exist = yes.
    end.
  end.
end procedure.
procedure fd-attr-delete :
  do
  on error undo, return error
  :
  define input parameter p-host-code     like ub.fin-doc-attr.host-code  no-undo .
  define input parameter p-fin-doc-code  like ub.fin-doc-attr.fin-doc-code   no-undo .
  define input parameter p-code          like ub.fin-doc-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo.
    define buffer buf_fin-doc-attr for ub.fin-doc-attr .
    define variable  v-type           as character no-undo .
    define variable  v-format         as character no-undo .
    define variable  v-label          as character no-undo .
    define variable  v-user-can-edit  as logical   no-undo .
    define variable  v-output-display as logical   no-undo .
    define variable  v-other          as character no-undo .
    run fd-attr-code in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_fin-doc-attr exclusive-lock
      where buf_fin-doc-attr.host-code  = p-host-code
        and buf_fin-doc-attr.fin-doc-code  = p-fin-doc-code
        and buf_fin-doc-attr.attr-code = p-code
      no-error NO-WAIT.
    if not available buf_fin-doc-attr then do:
      p-deleted = no.
    end.
    else do:
      delete buf_fin-doc-attr no-error .
      if error-status:error then do:
        undo, return error return-value .
      end.
      p-deleted = yes.
    end.
  end.
end procedure.
procedure fin-doc-attr-value :
 do
 on error undo, return error return-value
 :
define input  parameter p-host-code    like ub.fin-doc-attr.host-code    no-undo .
define input  parameter p-fin-doc-code like ub.fin-doc-attr.fin-doc-code     no-undo .
define input  parameter p-attr-code    like ub.fin-doc-attr.attr-code    no-undo .
define output parameter p-attr-value   like ub.fin-doc-attr.attr-value   no-undo .
define variable  v-format         as character no-undo .
define variable  v-label          as character no-undo .
define variable  v-user-can-edit  as logical   no-undo .
define variable  v-output-display as logical   no-undo .
define variable  v-other          as character no-undo .
define variable  v-type           as character no-undo .
define buffer buf_fin-doc-attr for ub.fin-doc-attr.
run fd-attr-code in this-procedure
  (input  p-attr-code
  ,output v-type
  ,output v-format
  ,output v-label
  ,output v-user-can-edit
  ,output v-output-display
  ,output v-other
  ) no-error .
if error-status :error then do:
  undo, return error return-value .
end.
find first buf_fin-doc-attr no-lock where
          buf_fin-doc-attr.attr-code    = p-attr-code
      AND buf_fin-doc-attr.host-code     = p-host-code
      AND buf_fin-doc-attr.fin-doc-code = p-fin-doc-code      no-error .
  if available  buf_fin-doc-attr then do:
    assign
    p-attr-value = buf_fin-doc-attr.attr-value
    .
  end.
  else do:
    p-attr-value = ? .
  end.
 end.
end procedure.
procedure fd-attr-news :
  do
  on error undo, return error
  :
    define input  parameter p-code           as character no-undo .
    define output parameter p-news           as logical   no-undo .
    case p-code :
            when 'shift-date':U then do:     assign     p-news = no.   end.
            when 'shift-num':U then do:     assign     p-news = no.   end.
            when 'shift-name':U then do:     assign     p-news = no.   end.
            when 'barcode':U then do:     assign     p-news = no.   end.
            when 'lockid':U then do:     assign     p-news = no.   end.
            when 'cover_sheet':U then do:     assign     p-news = no.   end.
            when 'pre-vedom':U then do:     assign     p-news = no.   end.
      otherwise do:
        undo, return error "неизвестный атрибут платежа " + " " + p-code .
      end.
    end.
  end.
end procedure.
procedure c-fin-doc-attr-write :
 do
 on error undo, return error return-value
 :
define input parameter p-host-code     like ub.c-fin-doc-attr.host-code  no-undo .
define input parameter p-fin-doc-code  like ub.c-fin-doc-attr.fin-doc-code   no-undo .
define input parameter p-corr-user-db-num  like ub.c-fin-doc-attr.corr-user-db-num   no-undo .
define input parameter p-chip-num      like ub.c-fin-doc-attr.chip-num   no-undo .
define input parameter p-attr-code     like ub.c-fin-doc-attr.attr-code  no-undo .
define input parameter p-attr-value    like ub.c-fin-doc-attr.attr-value no-undo .
define variable  v-format         as character no-undo .
define variable  v-label          as character no-undo .
define variable  v-user-can-edit  as logical   no-undo .
define variable  v-output-display as logical   no-undo .
define variable  v-other          as character no-undo .
define variable  v-type           as character no-undo .
define buffer buf_c-fin-doc-attr for ub.c-fin-doc-attr.
run fd-attr-code in this-procedure
                                  (input  p-attr-code
                                  ,output v-type
                                  ,output v-format
                                  ,output v-label
                                  ,output v-user-can-edit
                                  ,output v-output-display
                                  ,output v-other
                                  ) no-error .
if error-status :error then do:
  undo, return error return-value .
end.
find first buf_c-fin-doc-attr  exclusive-lock  where
          buf_c-fin-doc-attr.attr-code    = p-attr-code
      AND buf_c-fin-doc-attr.host-code    = p-host-code
      AND buf_c-fin-doc-attr.fin-doc-code     = p-fin-doc-code
      AND buf_c-fin-doc-attr.corr-user-db-num = p-corr-user-db-num
      AND buf_c-fin-doc-attr.chip-num         = p-chip-num      no-error .
  if not available  buf_c-fin-doc-attr then do:
      create buf_c-fin-doc-attr.
      assign
      buf_c-fin-doc-attr.attr-code    = p-attr-code
      buf_c-fin-doc-attr.attr-value   = p-attr-value
      buf_c-fin-doc-attr.host-code    = p-host-code
      buf_c-fin-doc-attr.fin-doc-code     = p-fin-doc-code
      .
  end.
  else do:
        buf_c-fin-doc-attr.attr-value   = p-attr-value .
  end.
 end.
end procedure.
procedure c-fin-doc-attr-value :
 do
 on error undo, return error return-value
 :
define input  parameter p-host-code    like ub.c-fin-doc-attr.host-code    no-undo .
define input  parameter p-fin-doc-code like ub.c-fin-doc-attr.fin-doc-code     no-undo .
define input parameter p-corr-user-db-num  like ub.c-fin-doc-attr.corr-user-db-num   no-undo .
define input parameter p-chip-num      like ub.c-fin-doc-attr.chip-num   no-undo .
define input  parameter p-attr-code    like ub.c-fin-doc-attr.attr-code    no-undo .
define output parameter p-attr-value   like ub.c-fin-doc-attr.attr-value   no-undo .
define variable  v-format         as character no-undo .
define variable  v-label          as character no-undo .
define variable  v-user-can-edit  as logical   no-undo .
define variable  v-output-display as logical   no-undo .
define variable  v-other          as character no-undo .
define variable  v-type           as character no-undo .
define buffer buf_c-fin-doc-attr for ub.c-fin-doc-attr.
run fd-attr-code in this-procedure
  (input  p-attr-code
  ,output v-type
  ,output v-format
  ,output v-label
  ,output v-user-can-edit
  ,output v-output-display
  ,output v-other
  ) no-error .
if error-status :error then do:
  undo, return error return-value .
end.
find first buf_c-fin-doc-attr no-lock where
          buf_c-fin-doc-attr.attr-code    = p-attr-code
      AND buf_c-fin-doc-attr.fin-doc-code      = p-fin-doc-code
      AND buf_c-fin-doc-attr.host-code      = p-host-code
      AND buf_c-fin-doc-attr.corr-user-db-num = p-corr-user-db-num
      AND buf_c-fin-doc-attr.chip-num         = p-chip-num      no-error .
  if available  buf_c-fin-doc-attr then do:
    assign
    p-attr-value = buf_c-fin-doc-attr.attr-value
    .
  end.
  else do:
    p-attr-value = ? .
  end.
 end.
end procedure.
procedure c-fin-doc-attr-value-nextchip :
 do
 on error undo, return error return-value
 :
define input  parameter p-host-code    like ub.c-fin-doc-attr.host-code    no-undo .
define input  parameter p-fin-doc-code like ub.c-fin-doc-attr.fin-doc-code     no-undo .
define input parameter p-corr-user-db-num  like ub.c-fin-doc-attr.corr-user-db-num   no-undo .
define input parameter p-chip-num      like ub.c-fin-doc-attr.chip-num   no-undo .
define input  parameter p-attr-code    like ub.c-fin-doc-attr.attr-code    no-undo .
define output parameter p-attr-value   like ub.c-fin-doc-attr.attr-value   no-undo .
define variable  v-format         as character no-undo .
define variable  v-label          as character no-undo .
define variable  v-user-can-edit  as logical   no-undo .
define variable  v-output-display as logical   no-undo .
define variable  v-other          as character no-undo .
define variable  v-type           as character no-undo .
define buffer buf_c-fin-doc-attr for ub.c-fin-doc-attr.
run fd-attr-code in this-procedure
  (input  p-attr-code
  ,output v-type
  ,output v-format
  ,output v-label
  ,output v-user-can-edit
  ,output v-output-display
  ,output v-other
  ) no-error .
if error-status :error then do:
  undo, return error return-value .
end.
find first buf_c-fin-doc-attr no-lock where
          buf_c-fin-doc-attr.attr-code    = p-attr-code
      and buf_c-fin-doc-attr.fin-doc-code      = p-fin-doc-code
      and buf_c-fin-doc-attr.host-code      = p-host-code
      and buf_c-fin-doc-attr.corr-user-db-num = p-corr-user-db-num
      and buf_c-fin-doc-attr.chip-num         > p-chip-num      no-error .
  if available  buf_c-fin-doc-attr then do:
    assign
    p-attr-value = buf_c-fin-doc-attr.attr-value
    .
  end.
  else do:
    p-attr-value = ? .
  end.
 end.
end procedure.
procedure fin-doc-temp-attr-write :
 do
 on error undo, return error return-value
 :
define input parameter p-host-code     like ub.fin-doc-attr.host-code  no-undo .
define input parameter p-fin-doc-code  like ub.fin-doc-attr.fin-doc-code   no-undo .
define input parameter p-attr-code     like ub.fin-doc-attr.attr-code  no-undo .
define input parameter p-attr-value    like ub.fin-doc-attr.attr-value no-undo .
define variable  v-format         as character no-undo .
define variable  v-label          as character no-undo .
define variable  v-user-can-edit  as logical   no-undo .
define variable  v-output-display as logical   no-undo .
define variable  v-other          as character no-undo .
define variable  v-type           as character no-undo .
define buffer buf_temp-fin-doc-attr for tt0-fin-doc-attr.
run fd-attr-code in this-procedure
                                  (input  p-attr-code
                                  ,output v-type
                                  ,output v-format
                                  ,output v-label
                                  ,output v-user-can-edit
                                  ,output v-output-display
                                  ,output v-other
                                  ) no-error .
if error-status :error then do:
  undo, return error return-value .
end.
find first buf_temp-fin-doc-attr  exclusive-lock  where
          buf_temp-fin-doc-attr.attr-code    = p-attr-code
      AND buf_temp-fin-doc-attr.host-code    = p-host-code
      AND buf_temp-fin-doc-attr.fin-doc-code     = p-fin-doc-code  no-error .
  if not available  buf_temp-fin-doc-attr then do:
      create buf_temp-fin-doc-attr.
      assign
      buf_temp-fin-doc-attr.attr-code    = p-attr-code
      buf_temp-fin-doc-attr.attr-value   = p-attr-value
      buf_temp-fin-doc-attr.host-code    = p-host-code
      buf_temp-fin-doc-attr.fin-doc-code     = p-fin-doc-code
      .
  end.
    assign
    buf_temp-fin-doc-attr.attr-value = p-attr-value.
 end.
end procedure.
procedure fin-doc-temp-attr-value :
 do
 on error undo, return error return-value
 :
define input  parameter p-host-code    like ub.fin-doc-attr.host-code    no-undo .
define input  parameter p-fin-doc-code like ub.fin-doc-attr.fin-doc-code     no-undo .
define input  parameter p-attr-code    like ub.fin-doc-attr.attr-code    no-undo .
define output parameter p-attr-value   like ub.fin-doc-attr.attr-value   no-undo .
define variable  v-format         as character no-undo .
define variable  v-label          as character no-undo .
define variable  v-user-can-edit  as logical   no-undo .
define variable  v-output-display as logical   no-undo .
define variable  v-other          as character no-undo .
define variable  v-type           as character no-undo .
define buffer buf_fin-doc-attr for tt0-fin-doc-attr.
run fd-attr-code in this-procedure
  (input  p-attr-code
  ,output v-type
  ,output v-format
  ,output v-label
  ,output v-user-can-edit
  ,output v-output-display
  ,output v-other
  ) no-error .
if error-status :error then do:
  undo, return error return-value .
  end.
find first buf_fin-doc-attr no-lock where
          buf_fin-doc-attr.attr-code    = p-attr-code
      AND buf_fin-doc-attr.host-code     = p-host-code
      AND buf_fin-doc-attr.fin-doc-code = p-fin-doc-code      no-error .
  if available  buf_fin-doc-attr then do:
    assign
    p-attr-value = buf_fin-doc-attr.attr-value
    .
  end.
  else do:
    p-attr-value = ? .
  end.
 end.
end procedure.
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
if entry(1, p-mode, chr(4)) <> 'ДОБАВЛЕНИЕ':U
and entry(1, p-mode, chr(4)) <> 'ИЗМЕНЕНИЕ':U then do:
  message
  vss-workfile vss-revision vss-description skip
  "Неверный параметр p-mode" p-mode
  view-as alert-box error .
  undo, return error '':u.
end.
assign
v-author = (if num-entries(p-mode, chr(4)) > 1
           then entry(2, p-mode, chr(4))
           else '':U)
p-mode = entry(1, p-mode, chr(4))
.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdbnum in g#library
  (output v-db-num
  )  .
find first buf_sysconf no-lock where
                buf_sysconf.host-code = p-host-code.
if not avail buf_sysconf then do:
  run err-mess in this-procedure ( substitute("Не найдена фирма с кодом &1", string(p-host-code)), output v-ret-mess).
  undo, return error (if p-silent = no then "host-code":U else v-ret-mess).
end.
if p-obj-type <> "":U
or p-obj-code <> 0 then do:
  find first buf_clients-obj no-lock where
            buf_clients-obj.obj-type = p-obj-type
        AND buf_clients-obj.obj-code = p-obj-code no-error .
  if not available buf_clients-obj
  or (p-obj-type <> 'маг':U and p-obj-type <> 'скл':U)
  then do:
    run err-mess in this-procedure ( substitute("Не найден объект &1&2", p-obj-type, p-obj-code), output v-ret-mess).
    undo, return error (if p-silent = no then "obj-code":U else v-ret-mess).
  end.
  if buf_clients-obj.host-code <> p-host-code then do:
    run err-mess in this-procedure ( substitute("Объект &1&2 принадлежит фирме &3, а платеж принадлежит фирме &4"
                             , p-obj-type, p-obj-code, buf_clients-obj.host-code , p-host-code), output v-ret-mess).
    undo, return error (if p-silent = no then "obj-code":U else v-ret-mess).
  end.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdbnum in g#library
  (input  buf_clients-obj.obj-type
  ,input  buf_clients-obj.obj-code
  ,output v-obj-db-num
  )  .
end.
assign
v-cash-book-place = p-trn-doc-code.
if not (p-obj-type = '' and p-obj-code = 0)
and v-obj-db-num = g#db-num then do:
  define variable l-shift-on as logical no-undo .
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  'shift-on=request'
  ,output l-shift-on
  )  .
end.
assign
v-base-code = buf_sysconf.base-code
.
if p-prn-doc-code <> "":U and p-prn-doc-code <> "тех_":U
then do:
  assign
  v-year-start-date = date(1, 1, year(p-doc-date))
  v-year-end-date = date(12, 31, year(p-doc-date))
  .
  IF can-find(first buf_fin-doc no-lock where
                    buf_fin-doc.host-code = p-host-code
                AND buf_fin-doc.prn-doc-code = p-prn-doc-code
                AND buf_fin-doc.fin-doc-type = p-fin-doc-type
                AND (buf_fin-doc.doc-date >= v-year-start-date
                     and
                     buf_fin-doc.doc-date <= v-year-end-date)
                AND (p-mode = 'ДОБАВЛЕНИЕ':U OR p-doc-rec <> recid(buf_fin-doc))
                AND (p-fin-doc-type <> 'ппп':U
                     OR (buf_fin-doc.payer-type = p-payer-type AND buf_fin-doc.payer-code = p-payer-code)
                    )
                ) then do:
    if p-fin-doc-type = 'ппп':U then do:
      run err-mess in this-procedure ( substitute("Уже есть ПЛАТЕЖ с номером &1 для фирмы &2 от плательщика &3&4 за &5 год"
                              , p-prn-doc-code
                              , p-host-code
                              , p-payer-type
                              , p-payer-code
                              , year(p-doc-date)), output v-ret-mess).
    end.
    else do:
      run err-mess in this-procedure ( substitute("Уже есть ПЛАТЕЖ с номером &1 для фирмы &2 за &3 год", p-prn-doc-code, p-host-code, year(p-doc-date)), output v-ret-mess).
    end.
    undo, return error (if p-silent = no then "prn-doc-code":U else v-ret-mess).
  end.
end.
if p-doc-date = ? then do:
  run err-mess in this-procedure ( "Неверная дата составления ПЛАТЕЖА", output v-ret-mess).
  undo, return error (if p-silent = no then "doc-date":U else v-ret-mess).
end.
if p-curr-code <> 0 then do:
  find first buf_currency no-lock where
            buf_currency.curr-code = p-curr-code no-error.
  if not available buf_currency then do:
    run err-mess in this-procedure ( substitute("Не надена валюта с кодом &1", p-curr-code), output v-ret-mess).
    undo, return error (if p-silent = no then "curr-code":U else v-ret-mess) .
  end.
end.
if p-contract-curr <> 0 then do:
  find first buf_currency no-lock where
            buf_currency.curr-code = p-contract-curr no-error.
  if not available buf_currency then do:
    run err-mess in this-procedure ( substitute("Не надена валюта контракта с кодом &1", p-contract-curr), output v-ret-mess).
    undo, return error (if p-silent = no then "contract-curr":U else v-ret-mess).
  end.
end.
if p-receiver-name = "":U then do:
  run err-mess in this-procedure ( "Имя ПОЛУЧАТЕЛЯ не может быть пустым", output v-ret-mess).
  undo, return error (if p-silent = no then "receiver-name":U else v-ret-mess).
end.
if p-receiver-inn <> "":U then do:
  run gbl/keyinn.p ( input p-receiver-inn
                    ,input p-receiver-type
                    ,input p-receiver-code
                    ,input ?
                    ,output v-correct-inn) no-error .
  if error-status:error or not v-correct-inn then do:
    run err-mess in this-procedure ( substitute("Неверный ИНН ПОЛУЧАТЕЛЯ &1 &2", p-receiver-inn, return-value), output v-ret-mess).
    undo, return error (if p-silent = no then "receiver-inn":U else v-ret-mess).
  end.
end.
if p-payer-inn <> "":U then do:
  run gbl/keyinn.p ( input p-payer-inn
                    ,input p-payer-type
                    ,input p-payer-code
                    ,input ?
                    ,output v-correct-inn) no-error .
  if error-status:error or not v-correct-inn then do:
    run err-mess in this-procedure (substitute("Неверный ИНН ПЛАТЕЛЬЩИКА &1 &2",  p-payer-inn, return-value), output v-ret-mess).
    undo, return error (if p-silent = no then "payer-inn":U else v-ret-mess).
  end.
end.
if p-fin-doc-type = 'пко':U or
   p-fin-doc-type = 'ппп':U or
   p-fin-doc-type = 'апп':U
   then do:
  if p-receiver-code <> p-host-code then do:
    run err-mess in this-procedure (substitute("Неверные ПОЛУЧАТЕЛЬ &1 &2: ПОЛУЧАТЕЛЬ для платежа &3 должен быть &4&5"
                             , p-receiver-type
                             , p-receiver-code
                             , p-fin-doc-type
                             , 'орг':U
                             , p-host-code) , output v-ret-mess).
    undo, return error (if p-silent = no then "receiver-code":U else v-ret-mess).
  end.
end.
find first buf_clients no-lock where
            buf_clients.obj-type = p-receiver-type
        AND buf_clients.obj-code = p-receiver-code no-error .
if not available buf_clients then do:
  run err-mess in this-procedure (substitute("Не найден ПОЛУЧАТЕЛЬ &1 &2", p-receiver-type, p-receiver-code) , output v-ret-mess).
  undo, return error (if p-silent = no then "receiver-code":U else v-ret-mess).
end.
if p-receiver-code-schet <> 0 then do:
  find first buf_fin-schet no-lock where
            buf_fin-schet.host-code = p-host-code
        AND buf_fin-schet.code-schet = p-receiver-code-schet no-error.
  if not available buf_fin-schet then do:
    run err-mess in this-procedure (substitute("Не найден СЧЕТ ПОЛУЧАТЕЛЯ &1&2: фирма &3 код счета &4", p-receiver-type, p-receiver-code, p-host-code, p-receiver-code-schet) , output v-ret-mess).
    undo, return error (if p-silent = no then "receiver-code-schet":U else v-ret-mess).
  end.
  if buf_fin-schet.curr-code <> p-curr-code then do:
    run err-mess in this-procedure (substitute("Валюта СЧЕТА ПОЛУЧАТЕЛЯ &1&2: фирма &3 код счета &4 валюта &5 - не совпадает с валютой ПЛАТЕЖА &6",
    p-receiver-type, p-receiver-code,
    p-host-code, p-payer-code-schet, buf_fin-schet.curr-code, p-curr-code) , output v-ret-mess).
    undo, return error (if p-silent = no then "receiver-code-schet":U else v-ret-mess).
  end.
  if not (buf_fin-schet.cli-type = p-receiver-type
          and
          buf_fin-schet.cli-code = p-receiver-code) then do:
    run err-mess in this-procedure (substitute("СЧЕТ ПОЛУЧАТЕЛЯ принадлежит &1&2 - не совпадает с ПОЛУЧАТЕЛЕМ &3&4"
                                               ,buf_fin-schet.cli-type
                                               ,buf_fin-schet.cli-code
                                               ,p-receiver-type
                                               ,p-receiver-code) , output v-ret-mess).
    undo, return error (if p-silent = no then  "receiver-code-schet":U else v-ret-mess).
  end.
end.
if p-fin-doc-type = 'рко':U
or p-fin-doc-type = 'рпп':U
or p-fin-doc-type = 'апр':U
   then do:
  if p-payer-code <> p-host-code then do:
    run err-mess in this-procedure (substitute("Неверный ПЛАТЕЛЬЩИК &1 &2: ПЛАТЕЛЬЩИК для платежа &3 должен быть &4&5"
                             , p-payer-type
                             , p-payer-code
                             , p-fin-doc-type
                             , 'орг':U
                             , p-host-code) , output v-ret-mess).
    undo, return error (if p-silent = no then "payer-code":U else v-ret-mess).
  end.
end.
find first buf_clients no-lock where
            buf_clients.obj-type = p-payer-type
        AND buf_clients.obj-code = p-payer-code no-error .
if not available buf_clients then do:
  run err-mess in this-procedure (substitute("Не найден ПЛАТЕЛЬЩИК &1 &2", p-payer-type, p-payer-code), output v-ret-mess).
  undo, return error (if p-silent = no then "payer-code":U else v-ret-mess).
end.
if p-payer-code-schet <> 0 then do:
  find first buf_fin-schet no-lock where
            buf_fin-schet.host-code = p-host-code
        AND buf_fin-schet.code-schet = p-payer-code-schet no-error.
  if not available buf_fin-schet then do:
    run err-mess in this-procedure (substitute("Не найден СЧЕТ ПЛАТЕЛЬЩИКА &1&2: фирма &3 код счета &4", p-payer-type, p-payer-code, p-host-code, p-payer-code-schet) , output v-ret-mess).
    undo, return error (if p-silent = no then "payer-code-schet":U else v-ret-mess).
  end.
  if buf_fin-schet.curr-code <> p-curr-code then do:
    run err-mess in this-procedure (substitute("Валюта СЧЕТА ПЛАТЕЛЬЩИКА &1&2: фирма &3 код счета &4 валюта &5 - не совпадает с валютой ПЛАТЕЖА &6",
    p-payer-type, p-payer-code,
    p-host-code, p-payer-code-schet, buf_fin-schet.curr-code, p-curr-code) , output v-ret-mess).
    undo, return error (if p-silent = no then  "payer-code-schet":U else v-ret-mess).
  end.
  if not (buf_fin-schet.cli-type = p-payer-type
          and
          buf_fin-schet.cli-code = p-payer-code) then do:
    run err-mess in this-procedure (substitute("СЧЕТ ПЛАТЕЛЬЩИКА принадлежит &1&2 - не совпадает с ПЛАТЕЛЬЩИКОМ &3&4"
                                               ,buf_fin-schet.cli-type
                                               ,buf_fin-schet.cli-code
                                               ,p-payer-type
                                               ,p-payer-code) , output v-ret-mess).
    undo, return error (if p-silent = no then  "payer-code-schet":U else v-ret-mess).
  end.
end.
if p-payer-type = p-receiver-type
and p-payer-code = p-receiver-code then do:
    run err-mess in this-procedure (substitute("ПЛАТЕЛЬЩИК и ПОЛУЧАТЕЛЬ - не могут быть одной и той же организацией/физ.лицом (&1&2)"
                                               ,p-payer-type
                                               ,p-payer-code) , output v-ret-mess).
    undo, return error (if p-silent = no then  "payer-code":U else v-ret-mess).
end.
if p-contract-code <> 0 then do:
  find first buf_contract no-lock where
            buf_contract.contract-code = p-contract-code no-error .
  if not available buf_contract then do:
    run err-mess in this-procedure (substitute("Не найден договор: фирма &1 код договора &2", p-host-code, p-contract-code), output v-ret-mess ).
    undo, return error (if p-silent = no then  "contract-code":U  else v-ret-mess).
  end.
  if p-contract-curr <> buf_contract.curr-code then do:
    run err-mess in this-procedure (substitute("Неверная валюта договора : фирма &1 код договора &2 - в договоре &3, а в платеже &4", p-host-code, p-contract-code, buf_contract.curr-code, p-contract-curr), output v-ret-mess ).
    undo, return error (if p-silent = no then  "contract-curr":U  else v-ret-mess).
  end.
end.
if p-cor-acc <> 0 then do:
  find first buf_fin-code-cor-acc no-lock where
            buf_fin-code-cor-acc.host-code = p-host-code
        AND buf_fin-code-cor-acc.fin-code = p-cor-acc no-error .
  if not available buf_fin-code-cor-acc then do:
    run err-mess in this-procedure (substitute("Не найден корреспондирующий счет: фирма &1 внутр. код счета &2", p-host-code, p-cor-acc), output v-ret-mess ).
    undo, return error (if p-silent = no then  "cor-acc":U  else v-ret-mess).
  end.
  if buf_fin-code-cor-acc.status_ <> integer('0':U) then do:
    run err-mess in this-procedure (substitute("Недопустимый статус корр счета: фирма &1 внутр. код счета &2 значение &3", p-host-code, p-cor-acc, p-cor-acc-value), output v-ret-mess ).
    undo, return error (if p-silent = no then  "an-uchet-value":U  else v-ret-mess).
  end.
end.
if p-cor-acc1 <> 0 then do:
  find first buf_fin-code-cor-acc no-lock where
            buf_fin-code-cor-acc.host-code = p-host-code
        AND buf_fin-code-cor-acc.fin-code = p-cor-acc1 no-error .
  if not available buf_fin-code-cor-acc then do:
    run err-mess in this-procedure (substitute("Не найден корреспондирующий счет2: фирма &1 внутр. код счета &2", p-host-code, p-cor-acc1), output v-ret-mess ).
    undo, return error (if p-silent = no then  "cor-acc1":U  else v-ret-mess).
  end.
  if buf_fin-code-cor-acc.status_ <> integer('0':U) then do:
    run err-mess in this-procedure (substitute("Недопустимый статус корр счета2: фирма &1 внутр. код счета &2 значение &3", p-host-code, p-cor-acc1, p-cor-acc1-value), output v-ret-mess ).
    undo, return error (if p-silent = no then  "cor-acc1-value":U else v-ret-mess).
  end.
end.
if p-AN-UCHET-CODE <> 0 then do:
  find first buf_fin-code-AN-UCHET no-lock where
            buf_fin-code-an-uchet.host-code = p-host-code
        AND buf_fin-code-an-uchet.fin-code = p-an-uchet-code no-error .
  if not available buf_fin-code-an-uchet then do:
    run err-mess in this-procedure (substitute("Не найден счет аналитического учета: фирма &1 внутр. код счета &2", p-host-code, p-an-uchet-code), output v-ret-mess ).
    undo, return error (if p-silent = no then  "an-uchet-code":U  else v-ret-mess).
  end.
  if buf_fin-code-an-uchet.code-value <> p-an-uchet-value then do:
    run err-mess in this-procedure (substitute("Не соответствуют друг другу внутр код счета ан. учета и его значение: фирма &1 внутр. код счета &2 значение &3", p-host-code, p-an-uchet-code, p-an-uchet-value), output v-ret-mess ).
    undo, return error (if p-silent = no then  "an-uchet-value":U  else v-ret-mess).
  end.
  if buf_fin-code-an-uchet.status_ <> integer('0':U) then do:
    run err-mess in this-procedure (substitute("Недопустимый статус кода ан. учета: фирма &1 внутр. код счета &2 значение &3", p-host-code, p-an-uchet-code, p-an-uchet-value), output v-ret-mess ).
    undo, return error (if p-silent = no then  "an-uchet-value":U else v-ret-mess).
  end.
end.
if p-cel-nazn-code <> 0 then do:
  find first buf_fin-code-cel-nazn no-lock where
            buf_fin-code-cel-nazn.host-code = p-host-code
        AND buf_fin-code-cel-nazn.fin-code = p-cel-nazn-code no-error .
  if not available buf_fin-code-cel-nazn then do:
    run err-mess in this-procedure (substitute("Не найден счет целевого назначения: фирма &1 внутр. код счета &2", p-host-code, p-cel-nazn-code), output v-ret-mess ).
    undo, return error (if p-silent = no then  "cel-nazn":U  else v-ret-mess).
  end.
  if buf_fin-code-cel-nazn.code-value <> p-cel-nazn-value then do:
    run err-mess in this-procedure (substitute("Не соответствуют друг другу внутр код счета цел. назн. и его значение: фирма &1 внутр. код счета &2 значение &3", p-host-code, p-cel-nazn-code, p-cel-nazn-value), output v-ret-mess ).
    undo, return error (if p-silent = no then  "cel-nazn-value":U  else v-ret-mess).
  end.
  if buf_fin-code-cel-nazn.status_ <> integer('0':U) then do:
    run err-mess in this-procedure (substitute("Недопустимый статус кода целевого назначения: фирма &1 внутр. код счета &2 значение &3", p-host-code, p-cel-nazn-code, p-cel-nazn-value), output v-ret-mess ).
    undo, return error (if p-silent = no then  "an-uchet-value":U else v-ret-mess).
  end.
end.
if p-sum-doc = 0 then do:
  if p-fin-doc-type = 'апр':U
  or p-fin-doc-type = 'апп':U then do:
    for each buf_fin-connect no-lock where
            buf_fin-connect.host-code = p-host-code
        AND buf_fin-connect.fin-doc-code = p-fin-doc-code:
      assign
      accum-rubl = accum-rubl   + buf_fin-connect.sum-rubl
      accum-base = accum-base   + buf_fin-connect.sum-base
      accum-doc  = accum-doc    + buf_fin-connect.sum-doc
      accum-contr = accum-contr + buf_fin-connect.sum-contr
      .
    end.
    if accum-rubl <> 0
    OR accum-base <> 0
    OR accum-doc <> 0
    OR accum-contr <> 0 then do:
      run err-mess in this-procedure ("Сумма по документу равна 0", output v-ret-mess ).
    end.
  end.
  else do:
    run err-mess in this-procedure ("Сумма по документу равна 0", output v-ret-mess ).
    undo, return error (if p-silent = no then  "sum-doc":U else v-ret-mess).
  end.
end.
if round(p-sum-contr,2) < round(p-con-sum-contr,2) then do:
  run err-mess in this-procedure ("Сумма по документу (вал.дог.) " + string(p-sum-contr) + " не может быть меньше суммы (вал.дог.) " + string(p-con-sum-contr) + " имеющихcя связей с ФО", output v-ret-mess ).
  undo, return error (if p-silent = no then  "sum-doc":U  else v-ret-mess).
end.
if l-shift-on
and lookup(p-fin-ext-doc-type, 'пко,рко':U) > 0
and (p-doc-author = 'manual':U or p-doc-author = 'auto':U)
then do:
  v-flag-shift = yes.
  define variable v-fin-doc-shift-name-check as character no-undo .
 if p-shift-date = ?
 or p-shift-num < 1
 or p-shift-num > 24
 then do:
    run err-mess in this-procedure ( substitute("Неверная сменная дата &1 или порядок смены &2"
                                     ,p-shift-date
                                     ,p-shift-num), output v-ret-mess).
    undo, return error (if p-silent = no then  "sum-doc":U  else v-ret-mess).
 end.
 define variable v-dop as character no-undo .
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_shiftnam in g#lib-trn3
  (
     input p-obj-type
  ,  input p-obj-code
  ,  input p-shift-date
  ,  input p-shift-num
  , output v-fin-doc-shift-name-check
  , output v-dop
  )        no-error .
  if error-status:error then do:
    run err-mess in this-procedure (substitute( "Ошибка при проверке сменной даты&1&2&1&3"
                                      ,chr(10), error-status :get-message (1), return-value  )
                                      , output v-ret-mess ).
    undo, return error (if p-silent = no then  "shift-date":U  else v-ret-mess).
  end.
end.
if not (p-mode = 'ИЗМЕНЕНИЕ':U
       and
       v-author <> '') then do:
  for each tt0-fin-doc-tax no-lock where
          tt0-fin-doc-tax.host-code = p-host-code
      AND tt0-fin-doc-tax.fin-doc-code = p-fin-doc-code:
    assign
    v-acc = v-acc + tt0-fin-doc-tax.sum-line-doc
    .
  end.
  if abs(v-acc - p-sum-doc) > 0.01 then do:
    run err-mess in this-procedure ("Сумма по документу " + string(p-sum-doc) + " не равна сумме строк по исчислению налогов " +  string(v-acc), output v-ret-mess ).
    undo, return error (if p-silent = no then  "sum-doc":U  else v-ret-mess).
  end.
end.
if not (p-mode = 'ИЗМЕНЕНИЕ':U
       and
       v-author <> '')
and p-save-payment
       then do:
  v-acc = 0.
  for each tt0-payment no-lock where
          tt0-payment.host-code = p-host-code
      AND tt0-payment.source-type = 'платеж':U
      AND tt0-payment.source-ref = string(p-fin-doc-code):
    if not (tt0-payment.payer-type = p-payer-type
            and
            tt0-payment.payer-code = p-payer-code) then do:
    run err-mess in this-procedure ( substitute("Привязка к ДК сделана для &1&2,&3" +
                                                "а ПЛАТЕЛЬЩИК для платежа  &4&5"
                                                , tt0-payment.payer-type
                                                , tt0-payment.payer-code
                                                , chr(10)
                                                , p-payer-type
                                                , p-payer-code
                                                )
                                          , output v-ret-mess ).
    undo, return error (if p-silent = no then  "sum-doc":U  else v-ret-mess).
    end.
    assign
    v-acc = v-acc + tt0-payment.tot-cli
    .
    v-found = yes.
  end.
  if v-found = yes
  and not (p-fin-ext-doc-type = 'пко':U
           or
           p-fin-ext-doc-type = 'ппп':U
           or
           p-fin-ext-doc-type = 'апп':U
           ) then do:
    run err-mess in this-procedure ( substitute("Не предусмотрена привязка к ДК для платежей типа &1"
                                                , p-fin-ext-doc-type)
                                          , output v-ret-mess ).
    undo, return error (if p-silent = no then  "":U  else v-ret-mess).
  end.
  if v-found = yes
  and v-acc <> p-sum-doc then do:
    run err-mess in this-procedure ("Сумма по документу не равна сумме строк по ДК", output v-ret-mess ).
    undo, return error (if p-silent = no then  "sum-doc":U  else v-ret-mess).
  end.
end.
CASE p-fin-doc-type:
  when 'пко':U then do:
    run ref/findoc01.p (
                    input p-mode
                    ,input "":U
                    ,input p-host-code            ,input p-fin-doc-code         ,input p-an-uchet-code        ,input p-an-uchet-value       ,input p-base-rate            ,input p-base-scale           ,input p-cel-nazn-code        ,input p-cel-nazn-value       ,input p-contract-code        ,input p-contract-curr        ,input p-contract-rate        ,input p-contract-scale       ,input p-cor-acc              ,input p-cor-acc-value        ,input p-cor-acc1             ,input p-cor-acc1-value       ,input p-curr-code            ,input p-doc-date             ,input p-shift-date           ,input p-shift-num            ,input p-shift-name           ,input p-enclosure            ,input p-exch-rate            ,input p-exch-scale           ,input p-f104                 ,input p-f105                 ,input p-f106                 ,input p-f107                 ,input p-f108                 ,input p-f109                 ,input p-f110                 ,input p-f22                  ,input p-f23                  ,input p-fact-date            ,input p-fin-doc-type         ,input p-fin-ext-doc-type     ,input p-in-doc-code          ,input p-in-host-code         ,input p-including            ,input p-nazn-pl              ,input p-naznach-plat         ,input p-ocher-pl             ,input p-out-doc-code         ,input p-out-host-code        ,input p-pay-date             ,input p-payer-bank-name      ,input p-payer-bank-city      ,input p-payer-bik            ,input p-payer-c-schet        ,input p-payer-code           ,input p-payer-code-schet     ,input p-payer-dop1           ,input p-payer-dop2           ,input p-payer-inn            ,input p-payer-kpp            ,input p-payer-name           ,input p-payer-okpo           ,input p-payer-passport      ,input p-payer-r-schet        ,input p-payer-type           ,input p-perm-date            ,input p-prn-doc-code         ,input p-PS                   ,input p-receiver-bank-name   ,input p-receiver-bank-city   ,input p-receiver-bik         ,input p-receiver-c-schet     ,input p-receiver-code        ,input p-receiver-code-schet  ,input p-receiver-dop1        ,input p-receiver-dop2        ,input p-receiver-inn         ,input p-receiver-kpp         ,input p-receiver-name        ,input p-receiver-okpo        ,input p-receiver-passport    ,input p-receiver-r-schet     ,input p-receiver-type        ,input p-srok-pl              ,input p-stat-pl              ,input p-str-podr-code        ,input p-str-podr-type        ,input p-str-podr-name        ,input p-sum-base             ,input p-sum-doc              ,input p-sum-rubl             ,input p-sum-contr            ,input p-trn-doc-code         ,input p-vid-opl              ,input p-vid-plat
                    ,input p-con-sum-rubl         ,input p-con-sum-base         ,input p-con-sum-doc          ,input p-con-sum-contr        ,input p-con-stat             ,input p-payer-sign1                ,input p-payer-sign2                ,input p-payer-sign3                ,input p-payer-sign4                ,input p-receiver-sign1                ,input p-receiver-sign2                ,input p-receiver-sign3                ,input p-receiver-sign4                ,input p-obj-type                   ,input p-obj-code                   ,input p-doc-author                 ,input p-fact-author                ,input p-CashBookId
                    ,input "":U
                    ,input ?
                    ,output v-correct
                    ,output v-err-mess
                    ) no-error.
  end.
  when 'ппп':U then do:
    run ref/findoc03.p (
                    input p-mode + chr(4) + v-author
                    ,input "":U
                    ,input p-host-code            ,input p-fin-doc-code         ,input p-an-uchet-code        ,input p-an-uchet-value       ,input p-base-rate            ,input p-base-scale           ,input p-cel-nazn-code        ,input p-cel-nazn-value       ,input p-contract-code        ,input p-contract-curr        ,input p-contract-rate        ,input p-contract-scale       ,input p-cor-acc              ,input p-cor-acc-value        ,input p-cor-acc1             ,input p-cor-acc1-value       ,input p-curr-code            ,input p-doc-date             ,input p-shift-date           ,input p-shift-num            ,input p-shift-name           ,input p-enclosure            ,input p-exch-rate            ,input p-exch-scale           ,input p-f104                 ,input p-f105                 ,input p-f106                 ,input p-f107                 ,input p-f108                 ,input p-f109                 ,input p-f110                 ,input p-f22                  ,input p-f23                  ,input p-fact-date            ,input p-fin-doc-type         ,input p-fin-ext-doc-type     ,input p-in-doc-code          ,input p-in-host-code         ,input p-including            ,input p-nazn-pl              ,input p-naznach-plat         ,input p-ocher-pl             ,input p-out-doc-code         ,input p-out-host-code        ,input p-pay-date             ,input p-payer-bank-name      ,input p-payer-bank-city      ,input p-payer-bik            ,input p-payer-c-schet        ,input p-payer-code           ,input p-payer-code-schet     ,input p-payer-dop1           ,input p-payer-dop2           ,input p-payer-inn            ,input p-payer-kpp            ,input p-payer-name           ,input p-payer-okpo           ,input p-payer-passport      ,input p-payer-r-schet        ,input p-payer-type           ,input p-perm-date            ,input p-prn-doc-code         ,input p-PS                   ,input p-receiver-bank-name   ,input p-receiver-bank-city   ,input p-receiver-bik         ,input p-receiver-c-schet     ,input p-receiver-code        ,input p-receiver-code-schet  ,input p-receiver-dop1        ,input p-receiver-dop2        ,input p-receiver-inn         ,input p-receiver-kpp         ,input p-receiver-name        ,input p-receiver-okpo        ,input p-receiver-passport    ,input p-receiver-r-schet     ,input p-receiver-type        ,input p-srok-pl              ,input p-stat-pl              ,input p-str-podr-code        ,input p-str-podr-type        ,input p-str-podr-name        ,input p-sum-base             ,input p-sum-doc              ,input p-sum-rubl             ,input p-sum-contr            ,input p-trn-doc-code         ,input p-vid-opl              ,input p-vid-plat
                    ,input p-con-sum-rubl         ,input p-con-sum-base         ,input p-con-sum-doc          ,input p-con-sum-contr        ,input p-con-stat             ,input p-payer-sign1                ,input p-payer-sign2                ,input p-payer-sign3                ,input p-payer-sign4                ,input p-receiver-sign1                ,input p-receiver-sign2                ,input p-receiver-sign3                ,input p-receiver-sign4                ,input p-obj-type                   ,input p-obj-code                   ,input p-doc-author                 ,input p-fact-author                ,input p-CashBookId
                    ,input "":U
                    ,input ?
                    ,output v-correct
                    ,output v-err-mess
                    ) no-error.
  end.
  when 'рко':U then do:
    run ref/findoc02.p (
                    input p-mode
                    ,input "":U
                    ,input p-host-code            ,input p-fin-doc-code         ,input p-an-uchet-code        ,input p-an-uchet-value       ,input p-base-rate            ,input p-base-scale           ,input p-cel-nazn-code        ,input p-cel-nazn-value       ,input p-contract-code        ,input p-contract-curr        ,input p-contract-rate        ,input p-contract-scale       ,input p-cor-acc              ,input p-cor-acc-value        ,input p-cor-acc1             ,input p-cor-acc1-value       ,input p-curr-code            ,input p-doc-date             ,input p-shift-date           ,input p-shift-num            ,input p-shift-name           ,input p-enclosure            ,input p-exch-rate            ,input p-exch-scale           ,input p-f104                 ,input p-f105                 ,input p-f106                 ,input p-f107                 ,input p-f108                 ,input p-f109                 ,input p-f110                 ,input p-f22                  ,input p-f23                  ,input p-fact-date            ,input p-fin-doc-type         ,input p-fin-ext-doc-type     ,input p-in-doc-code          ,input p-in-host-code         ,input p-including            ,input p-nazn-pl              ,input p-naznach-plat         ,input p-ocher-pl             ,input p-out-doc-code         ,input p-out-host-code        ,input p-pay-date             ,input p-payer-bank-name      ,input p-payer-bank-city      ,input p-payer-bik            ,input p-payer-c-schet        ,input p-payer-code           ,input p-payer-code-schet     ,input p-payer-dop1           ,input p-payer-dop2           ,input p-payer-inn            ,input p-payer-kpp            ,input p-payer-name           ,input p-payer-okpo           ,input p-payer-passport      ,input p-payer-r-schet        ,input p-payer-type           ,input p-perm-date            ,input p-prn-doc-code         ,input p-PS                   ,input p-receiver-bank-name   ,input p-receiver-bank-city   ,input p-receiver-bik         ,input p-receiver-c-schet     ,input p-receiver-code        ,input p-receiver-code-schet  ,input p-receiver-dop1        ,input p-receiver-dop2        ,input p-receiver-inn         ,input p-receiver-kpp         ,input p-receiver-name        ,input p-receiver-okpo        ,input p-receiver-passport    ,input p-receiver-r-schet     ,input p-receiver-type        ,input p-srok-pl              ,input p-stat-pl              ,input p-str-podr-code        ,input p-str-podr-type        ,input p-str-podr-name        ,input p-sum-base             ,input p-sum-doc              ,input p-sum-rubl             ,input p-sum-contr            ,input p-trn-doc-code         ,input p-vid-opl              ,input p-vid-plat
                    ,input p-con-sum-rubl         ,input p-con-sum-base         ,input p-con-sum-doc          ,input p-con-sum-contr        ,input p-con-stat             ,input p-payer-sign1                ,input p-payer-sign2                ,input p-payer-sign3                ,input p-payer-sign4                ,input p-receiver-sign1                ,input p-receiver-sign2                ,input p-receiver-sign3                ,input p-receiver-sign4                ,input p-obj-type                   ,input p-obj-code                   ,input p-doc-author                 ,input p-fact-author                ,input p-CashBookId
                    ,input "":U
                    ,input ?
                    ,output v-correct
                    ,output v-err-mess
                    ) no-error.
  end.
  when 'рпп':U then do:
    run ref/findoc04.p (
                    input p-mode + chr(4) + v-author
                    ,input "":U
                    ,input p-host-code            ,input p-fin-doc-code         ,input p-an-uchet-code        ,input p-an-uchet-value       ,input p-base-rate            ,input p-base-scale           ,input p-cel-nazn-code        ,input p-cel-nazn-value       ,input p-contract-code        ,input p-contract-curr        ,input p-contract-rate        ,input p-contract-scale       ,input p-cor-acc              ,input p-cor-acc-value        ,input p-cor-acc1             ,input p-cor-acc1-value       ,input p-curr-code            ,input p-doc-date             ,input p-shift-date           ,input p-shift-num            ,input p-shift-name           ,input p-enclosure            ,input p-exch-rate            ,input p-exch-scale           ,input p-f104                 ,input p-f105                 ,input p-f106                 ,input p-f107                 ,input p-f108                 ,input p-f109                 ,input p-f110                 ,input p-f22                  ,input p-f23                  ,input p-fact-date            ,input p-fin-doc-type         ,input p-fin-ext-doc-type     ,input p-in-doc-code          ,input p-in-host-code         ,input p-including            ,input p-nazn-pl              ,input p-naznach-plat         ,input p-ocher-pl             ,input p-out-doc-code         ,input p-out-host-code        ,input p-pay-date             ,input p-payer-bank-name      ,input p-payer-bank-city      ,input p-payer-bik            ,input p-payer-c-schet        ,input p-payer-code           ,input p-payer-code-schet     ,input p-payer-dop1           ,input p-payer-dop2           ,input p-payer-inn            ,input p-payer-kpp            ,input p-payer-name           ,input p-payer-okpo           ,input p-payer-passport      ,input p-payer-r-schet        ,input p-payer-type           ,input p-perm-date            ,input p-prn-doc-code         ,input p-PS                   ,input p-receiver-bank-name   ,input p-receiver-bank-city   ,input p-receiver-bik         ,input p-receiver-c-schet     ,input p-receiver-code        ,input p-receiver-code-schet  ,input p-receiver-dop1        ,input p-receiver-dop2        ,input p-receiver-inn         ,input p-receiver-kpp         ,input p-receiver-name        ,input p-receiver-okpo        ,input p-receiver-passport    ,input p-receiver-r-schet     ,input p-receiver-type        ,input p-srok-pl              ,input p-stat-pl              ,input p-str-podr-code        ,input p-str-podr-type        ,input p-str-podr-name        ,input p-sum-base             ,input p-sum-doc              ,input p-sum-rubl             ,input p-sum-contr            ,input p-trn-doc-code         ,input p-vid-opl              ,input p-vid-plat
                    ,input p-con-sum-rubl         ,input p-con-sum-base         ,input p-con-sum-doc          ,input p-con-sum-contr        ,input p-con-stat             ,input p-payer-sign1                ,input p-payer-sign2                ,input p-payer-sign3                ,input p-payer-sign4                ,input p-receiver-sign1                ,input p-receiver-sign2                ,input p-receiver-sign3                ,input p-receiver-sign4                ,input p-obj-type                   ,input p-obj-code                   ,input p-doc-author                 ,input p-fact-author                ,input p-CashBookId
                    ,input "":U
                    ,input ?
                    ,output v-correct
                    ,output v-err-mess
                    ) no-error.
  end.
  when 'апп':U then do:
    run ref/findoc05.p (
                    input p-mode
                    ,input "":U
                    ,input p-host-code            ,input p-fin-doc-code         ,input p-an-uchet-code        ,input p-an-uchet-value       ,input p-base-rate            ,input p-base-scale           ,input p-cel-nazn-code        ,input p-cel-nazn-value       ,input p-contract-code        ,input p-contract-curr        ,input p-contract-rate        ,input p-contract-scale       ,input p-cor-acc              ,input p-cor-acc-value        ,input p-cor-acc1             ,input p-cor-acc1-value       ,input p-curr-code            ,input p-doc-date             ,input p-shift-date           ,input p-shift-num            ,input p-shift-name           ,input p-enclosure            ,input p-exch-rate            ,input p-exch-scale           ,input p-f104                 ,input p-f105                 ,input p-f106                 ,input p-f107                 ,input p-f108                 ,input p-f109                 ,input p-f110                 ,input p-f22                  ,input p-f23                  ,input p-fact-date            ,input p-fin-doc-type         ,input p-fin-ext-doc-type     ,input p-in-doc-code          ,input p-in-host-code         ,input p-including            ,input p-nazn-pl              ,input p-naznach-plat         ,input p-ocher-pl             ,input p-out-doc-code         ,input p-out-host-code        ,input p-pay-date             ,input p-payer-bank-name      ,input p-payer-bank-city      ,input p-payer-bik            ,input p-payer-c-schet        ,input p-payer-code           ,input p-payer-code-schet     ,input p-payer-dop1           ,input p-payer-dop2           ,input p-payer-inn            ,input p-payer-kpp            ,input p-payer-name           ,input p-payer-okpo           ,input p-payer-passport      ,input p-payer-r-schet        ,input p-payer-type           ,input p-perm-date            ,input p-prn-doc-code         ,input p-PS                   ,input p-receiver-bank-name   ,input p-receiver-bank-city   ,input p-receiver-bik         ,input p-receiver-c-schet     ,input p-receiver-code        ,input p-receiver-code-schet  ,input p-receiver-dop1        ,input p-receiver-dop2        ,input p-receiver-inn         ,input p-receiver-kpp         ,input p-receiver-name        ,input p-receiver-okpo        ,input p-receiver-passport    ,input p-receiver-r-schet     ,input p-receiver-type        ,input p-srok-pl              ,input p-stat-pl              ,input p-str-podr-code        ,input p-str-podr-type        ,input p-str-podr-name        ,input p-sum-base             ,input p-sum-doc              ,input p-sum-rubl             ,input p-sum-contr            ,input p-trn-doc-code         ,input p-vid-opl              ,input p-vid-plat
                    ,input p-con-sum-rubl         ,input p-con-sum-base         ,input p-con-sum-doc          ,input p-con-sum-contr        ,input p-con-stat             ,input p-payer-sign1                ,input p-payer-sign2                ,input p-payer-sign3                ,input p-payer-sign4                ,input p-receiver-sign1                ,input p-receiver-sign2                ,input p-receiver-sign3                ,input p-receiver-sign4                ,input p-obj-type                   ,input p-obj-code                   ,input p-doc-author                 ,input p-fact-author                ,input p-CashBookId
                    ,input "":U
                    ,input ?
                    ,output v-correct
                    ,output v-err-mess
                    ) no-error.
  end.
  when 'апр':U then do:
    run ref/findoc06.p (
                    input p-mode
                    ,input "":U
                    ,input p-host-code            ,input p-fin-doc-code         ,input p-an-uchet-code        ,input p-an-uchet-value       ,input p-base-rate            ,input p-base-scale           ,input p-cel-nazn-code        ,input p-cel-nazn-value       ,input p-contract-code        ,input p-contract-curr        ,input p-contract-rate        ,input p-contract-scale       ,input p-cor-acc              ,input p-cor-acc-value        ,input p-cor-acc1             ,input p-cor-acc1-value       ,input p-curr-code            ,input p-doc-date             ,input p-shift-date           ,input p-shift-num            ,input p-shift-name           ,input p-enclosure            ,input p-exch-rate            ,input p-exch-scale           ,input p-f104                 ,input p-f105                 ,input p-f106                 ,input p-f107                 ,input p-f108                 ,input p-f109                 ,input p-f110                 ,input p-f22                  ,input p-f23                  ,input p-fact-date            ,input p-fin-doc-type         ,input p-fin-ext-doc-type     ,input p-in-doc-code          ,input p-in-host-code         ,input p-including            ,input p-nazn-pl              ,input p-naznach-plat         ,input p-ocher-pl             ,input p-out-doc-code         ,input p-out-host-code        ,input p-pay-date             ,input p-payer-bank-name      ,input p-payer-bank-city      ,input p-payer-bik            ,input p-payer-c-schet        ,input p-payer-code           ,input p-payer-code-schet     ,input p-payer-dop1           ,input p-payer-dop2           ,input p-payer-inn            ,input p-payer-kpp            ,input p-payer-name           ,input p-payer-okpo           ,input p-payer-passport      ,input p-payer-r-schet        ,input p-payer-type           ,input p-perm-date            ,input p-prn-doc-code         ,input p-PS                   ,input p-receiver-bank-name   ,input p-receiver-bank-city   ,input p-receiver-bik         ,input p-receiver-c-schet     ,input p-receiver-code        ,input p-receiver-code-schet  ,input p-receiver-dop1        ,input p-receiver-dop2        ,input p-receiver-inn         ,input p-receiver-kpp         ,input p-receiver-name        ,input p-receiver-okpo        ,input p-receiver-passport    ,input p-receiver-r-schet     ,input p-receiver-type        ,input p-srok-pl              ,input p-stat-pl              ,input p-str-podr-code        ,input p-str-podr-type        ,input p-str-podr-name        ,input p-sum-base             ,input p-sum-doc              ,input p-sum-rubl             ,input p-sum-contr            ,input p-trn-doc-code         ,input p-vid-opl              ,input p-vid-plat
                    ,input p-con-sum-rubl         ,input p-con-sum-base         ,input p-con-sum-doc          ,input p-con-sum-contr        ,input p-con-stat             ,input p-payer-sign1                ,input p-payer-sign2                ,input p-payer-sign3                ,input p-payer-sign4                ,input p-receiver-sign1                ,input p-receiver-sign2                ,input p-receiver-sign3                ,input p-receiver-sign4                ,input p-obj-type                   ,input p-obj-code                   ,input p-doc-author                 ,input p-fact-author                ,input p-CashBookId
                    ,input "":U
                    ,input ?
                    ,output v-correct
                    ,output v-err-mess
                    ) no-error.
  end.
  otherwise do:
    run err-mess in this-procedure (substitute("Неверный тип платежа &1", p-fin-doc-type), output v-ret-mess ).
    undo, return error (if p-silent = no then  "fin-doc-type":U  else v-ret-mess).
  end.
END CASE.
if error-status:error then do:
  run err-mess in this-procedure (substitute("Ошибка при проверке валидности платежа: &1", error-status:get-message(1) ), output v-ret-mess).
  undo, return error (if p-silent = no then  '':U  else v-ret-mess).
end.
if not v-correct then do:
  run err-mess in this-procedure (substitute("Неверные реквизиты платежа &1", v-err-mess), output v-ret-mess).
  undo, return error (if p-silent = no then  return-value  else v-ret-mess).
end.
if lookup(p-fin-ext-doc-type, 'пко,рко,ппп,рпп,апп,апр,':U) = 0 then do:
  run err-mess in this-procedure (substitute("Неверный расширенный тип платежа &1", p-fin-ext-doc-type), output v-ret-mess ).
  undo, return error (if p-silent = no then  "fin-ext-doc-type":U  else v-ret-mess).
end.
_MAIN:
DO ON ERROR UNDO, RETURN ERROR
ON STOP UNDO, RETURN ERROR:
  if p-mode = 'ДОБАВЛЕНИЕ':U then do:
    create ub.fin-doc.
    assign
    ub.fin-doc.host-code = p-host-code
    ub.fin-doc.fin-doc-code = p-fin-doc-code
    ub.fin-doc.status_ = 'новый':U
    p-doc-rec = recid(ub.fin-doc)
    .
        assign
        v-cash-book-place = buf_clients-obj.obj-type + string(buf_clients-obj.obj-code, "99999")
        .
  end.
  else do:
    FIND FIRST ub.fin-doc where
              recid(ub.fin-doc) = p-doc-rec No-ERROR.
    if not available ub.fin-doc then do:
      run err-mess in this-procedure (substitute("Не найдена запись ПЛАТЕЖА - p-doc-rec &1", p-doc-rec), output v-ret-mess).
      undo, return error (if p-silent = no then  '':u  else v-ret-mess).
    end.
    if ub.fin-doc.host-code <> p-host-code
    OR ub.fin-doc.fin-doc-code <> p-fin-doc-code
    OR ub.fin-doc.fin-doc-type <> p-fin-doc-type
    then do:
      run err-mess in this-procedure (substitute("Для уже имеющейся записи нельзя изменить&1" +
                               "код фирмы, внутренний код платежа, тип платежа&1"
                               , chr(10)), output v-ret-mess).
      undo, return error (if p-silent = no then  '':U  else v-ret-mess).
    end.
    v-cash-book-place = ub.fin-doc.trn-doc-code.
    if not (ub.fin-doc.obj-type = p-obj-type
           and
           ub.fin-doc.obj-code = p-obj-code
           )
    and ub.fin-doc.user-db-num-doc = g#db-num
    then do:
if (valid-handle(g#lib-farh) <> true) then do:   run str/lib-farh.p persistent no-error .   if error-status :error or (valid-handle(g#lib-farh) <> true) then do:     message       "Error starting lib-farh.p" skip       g#lib-farh skip       g#lib-farh :type skip       g#lib-farh :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-farh_fautoobj in g#lib-farh
(input p-host-code
,input p-fin-doc-code
,output v-is-auto-obj
)
.
      if not v-is-auto-obj then do:
        assign
        v-cash-book-place = p-obj-type + string(p-obj-code, "99999")
        .
      end.
      else do:
        assign v-cash-book-place = "".
      end.
    end.
    if ub.fin-doc.status_ <> 'новый':U
    then do:
      if  v-author = ''
      then do:
        if
        ub.fin-doc.base-rate           <> p-base-rate
        or
        ub.fin-doc.base-scale          <> p-base-scale
        or
        ub.fin-doc.contract-curr       <> p-contract-curr
        or
        ub.fin-doc.contract-rate       <> p-contract-rate
        or
        ub.fin-doc.contract-scale      <> p-contract-scale
        or
        ub.fin-doc.enclosure           <> p-enclosure
        or
        ub.fin-doc.exch-rate           <> p-exch-rate
        or
        ub.fin-doc.exch-scale          <> p-exch-scale
        or
        ub.fin-doc.f104                <> p-f104
        or
        ub.fin-doc.f105                <> p-f105
        or
        ub.fin-doc.f106                <> p-f106
        or
        ub.fin-doc.f107                <> p-f107
        or
        ub.fin-doc.f108                <> p-f108
        or
        ub.fin-doc.f109                <> p-f109
        or
        ub.fin-doc.f110                <> p-f110
        or
        ub.fin-doc.f22                 <> p-f22
        or
        ub.fin-doc.f23                 <> p-f23
        or
        ub.fin-doc.fin-doc-type        <> p-fin-doc-type
        or
        ub.fin-doc.including           <> p-including
        or
        ub.fin-doc.nazn-pl             <> p-nazn-pl
        or
        ub.fin-doc.naznach-plat        <> p-naznach-plat
        or
        ub.fin-doc.ocher-pl            <> p-ocher-pl
        or
        ub.fin-doc.payer-bank-name     <> p-payer-bank-name
        or
        ub.fin-doc.payer-bank-city     <> p-payer-bank-city
        or
        ub.fin-doc.payer-bik           <> p-payer-bik
        or
        ub.fin-doc.payer-c-schet       <> p-payer-c-schet
        or
        ub.fin-doc.payer-code-schet    <> p-payer-code-schet
        or
        ub.fin-doc.payer-inn           <> p-payer-inn
        or
        ub.fin-doc.payer-kpp           <> p-payer-kpp
        or
        ub.fin-doc.payer-name          <> p-payer-name
        or
        ub.fin-doc.payer-okpo          <> p-payer-okpo
        or
        ub.fin-doc.payer-passport   <> p-payer-passport
        or
        ub.fin-doc.payer-r-schet       <> p-payer-r-schet
        or
        ub.fin-doc.receiver-bank-name  <> p-receiver-bank-name
        or
        ub.fin-doc.receiver-bank-city  <> p-receiver-bank-city
        or
        ub.fin-doc.receiver-bik        <> p-receiver-bik
        or
        ub.fin-doc.receiver-c-schet    <> p-receiver-c-schet
        or
        ub.fin-doc.receiver-code-schet <> p-receiver-code-schet
        or
        ub.fin-doc.receiver-inn        <> p-receiver-inn
        or
        ub.fin-doc.receiver-kpp        <> p-receiver-kpp
        or
        ub.fin-doc.receiver-name       <> p-receiver-name
        or
        ub.fin-doc.receiver-okpo       <> p-receiver-okpo
        or
        ub.fin-doc.receiver-passport   <> p-receiver-passport
        or
        ub.fin-doc.receiver-r-schet    <> p-receiver-r-schet
        or
        ub.fin-doc.payer-sign1         <> p-payer-sign1
        or
        ub.fin-doc.payer-sign2         <> p-payer-sign2
        or
        ub.fin-doc.payer-sign3         <> p-payer-sign3
        or
        ub.fin-doc.receiver-sign1         <> p-receiver-sign1
        or
        ub.fin-doc.receiver-sign2         <> p-receiver-sign2
        or
        ub.fin-doc.receiver-sign3         <> p-receiver-sign3
        or
        ub.fin-doc.srok-pl             <> p-srok-pl
        or
        ub.fin-doc.stat-pl             <> p-stat-pl
        or
        ub.fin-doc.str-podr-code       <> p-str-podr-code
        or
        ub.fin-doc.str-podr-type       <> p-str-podr-type
        or
        ub.fin-doc.str-podr-name       <> p-str-podr-name
        or
        ub.fin-doc.sum-base            <> p-sum-base
        or
        ub.fin-doc.sum-doc             <> p-sum-doc
        or
        ub.fin-doc.sum-rubl            <> p-sum-rubl
        or
        ub.fin-doc.vid-opl             <> p-vid-opl
        or
        ub.fin-doc.vid-plat            <> p-vid-plat
        or
        not (ub.fin-doc.obj-type       = p-obj-type
             and
             ub.fin-doc.obj-code       = p-obj-code
             and
             (ub.fin-doc.shift-flag = integer('1':U)
              or
              not v-flag-shift
             )
             )
        then do:
          run err-mess in this-procedure (substitute("Для ПЛАТЕЖА в статусе не &1&2" +
                                  "можно менять только примечания, коды аналитического учета, объект(для несменных платежей) и НОМЕР&2"
                                  ,'новый':U
                                  , chr(10))
                        , output v-ret-mess).
          undo, return error (if p-silent = no then  '':U  else v-ret-mess).
        end.
      end.
      if
      ub.fin-doc.sum-doc             <> p-sum-doc
      or
      ub.fin-doc.curr-code           <> p-curr-code
      or
      ub.fin-doc.payer-type          <> p-payer-type
      or
      ub.fin-doc.payer-code          <> p-payer-code
      or
      ub.fin-doc.receiver-code       <> p-receiver-code
      or
      ub.fin-doc.receiver-type       <> p-receiver-type
      then do:
        if v-author = '':U then do:
          run err-mess in this-procedure (substitute("Для ПЛАТЕЖА в статусе не &1&2" +
                                  "можно менять только примечания, коды аналитического учета, объект и НОМЕР&2"
                                  ,'новый':U
                                  , chr(10))
                        , output v-ret-mess).
          undo, return error (if p-silent = no then  '':U  else v-ret-mess).
        end.
        if v-author <> '' then do:
          run err-mess in this-procedure (substitute("Для ПЛАТЕЖА в статусе не &1&2" +
                                  "НЕЛЬЗЯ менять сумму платежа, валюту платежа, ПЛАТЕЛЬЩИКА и ПОЛУЧАТЕЛЯ&2"
                                  ,'новый':U
                                  , chr(10))
                        , output v-ret-mess).
          undo, return error (if p-silent = no then  '':U  else v-ret-mess).
        end.
      end.
    end.
  end.
  assign
  ub.fin-doc.an-uchet-code       = p-an-uchet-code
  ub.fin-doc.an-uchet-value      = (if p-an-uchet-code <> 0 then p-an-uchet-value else "":U)
  ub.fin-doc.base-rate           = p-base-rate
  ub.fin-doc.base-scale          = p-base-scale
  ub.fin-doc.cel-nazn-code       = p-cel-nazn-code
  ub.fin-doc.cel-nazn-value      = (if p-cel-nazn-code <> 0 then p-cel-nazn-value else "":U)
  ub.fin-doc.contract-code       = p-contract-code
  ub.fin-doc.contract-curr       = p-contract-curr
  ub.fin-doc.contract-rate       = p-contract-rate
  ub.fin-doc.contract-scale      = p-contract-scale
  ub.fin-doc.cor-acc             = p-cor-acc
  ub.fin-doc.cor-acc-value       = (if p-cor-acc <> 0 then p-cor-acc-value else "":U)
  ub.fin-doc.cor-acc1            = p-cor-acc1
  ub.fin-doc.cor-acc1-value      = (if p-cor-acc1 <> 0 then p-cor-acc1-value else "":U)
  ub.fin-doc.curr-code           = p-curr-code
  ub.fin-doc.doc-date            = p-doc-date
  ub.fin-doc.enclosure           = p-enclosure
  ub.fin-doc.exch-rate           = p-exch-rate
  ub.fin-doc.exch-scale          = p-exch-scale
  ub.fin-doc.f104                = p-f104
  ub.fin-doc.f105                = p-f105
  ub.fin-doc.f106                = p-f106
  ub.fin-doc.f107                = p-f107
  ub.fin-doc.f108                = p-f108
  ub.fin-doc.f109                = p-f109
  ub.fin-doc.f110                = p-f110
  ub.fin-doc.f22                 = p-f22
  ub.fin-doc.f23                 = p-f23
  ub.fin-doc.fin-doc-type        = p-fin-doc-type
  ub.fin-doc.fin-ext-doc-type    = p-fin-ext-doc-type
  ub.fin-doc.in-doc-code         = p-in-doc-code
  ub.fin-doc.in-host-code        = p-in-host-code
  ub.fin-doc.including           = p-including
  ub.fin-doc.nazn-pl             = p-nazn-pl
  ub.fin-doc.naznach-plat        = p-naznach-plat
  ub.fin-doc.obj-type            = p-obj-type
  ub.fin-doc.obj-code            = p-obj-code
  ub.fin-doc.ocher-pl            = p-ocher-pl
  ub.fin-doc.out-doc-code        = p-out-doc-code
  ub.fin-doc.out-host-code       = p-out-host-code
  ub.fin-doc.payer-bank-name     = p-payer-bank-name
  ub.fin-doc.payer-bank-city     = p-payer-bank-city
  ub.fin-doc.payer-bik           = p-payer-bik
  ub.fin-doc.payer-c-schet       = p-payer-c-schet
  ub.fin-doc.payer-code          = p-payer-code
  ub.fin-doc.payer-code-schet    = p-payer-code-schet
  ub.fin-doc.payer-inn           = p-payer-inn
  ub.fin-doc.payer-kpp           = p-payer-kpp
  ub.fin-doc.payer-name          = p-payer-name
  ub.fin-doc.payer-okpo          = p-payer-okpo
  ub.fin-doc.payer-dop1          = p-payer-dop1
  ub.fin-doc.payer-dop2          = p-payer-dop2
  ub.fin-doc.payer-passport      = p-payer-passport
  ub.fin-doc.payer-r-schet       = p-payer-r-schet
  ub.fin-doc.payer-type          = p-payer-type
  ub.fin-doc.prn-doc-code        = p-prn-doc-code
  ub.fin-doc.PS                  = p-PS
  ub.fin-doc.receiver-bank-name  = p-receiver-bank-name
  ub.fin-doc.receiver-bank-city  = p-receiver-bank-city
  ub.fin-doc.receiver-bik        = p-receiver-bik
  ub.fin-doc.receiver-c-schet    = p-receiver-c-schet
  ub.fin-doc.receiver-code       = p-receiver-code
  ub.fin-doc.receiver-code-schet = p-receiver-code-schet
  ub.fin-doc.receiver-inn        = p-receiver-inn
  ub.fin-doc.receiver-kpp        = p-receiver-kpp
  ub.fin-doc.receiver-name       = p-receiver-name
  ub.fin-doc.receiver-okpo       = p-receiver-okpo
  ub.fin-doc.receiver-dop1       = p-receiver-dop1
  ub.fin-doc.receiver-dop2       = p-receiver-dop2
  ub.fin-doc.receiver-passport   = p-receiver-passport
  ub.fin-doc.receiver-r-schet    = p-receiver-r-schet
  ub.fin-doc.receiver-type       = p-receiver-type
  ub.fin-doc.payer-sign1         = p-payer-sign1
  ub.fin-doc.payer-sign2         = p-payer-sign2
  ub.fin-doc.payer-sign3         = p-payer-sign3
  ub.fin-doc.receiver-sign1      = p-receiver-sign1
  ub.fin-doc.receiver-sign2      = p-receiver-sign2
  ub.fin-doc.receiver-sign3      = p-receiver-sign3
  ub.fin-doc.srok-pl             = p-srok-pl
  ub.fin-doc.stat-pl             = p-stat-pl
  ub.fin-doc.str-podr-code       = p-str-podr-code
  ub.fin-doc.str-podr-type       = p-str-podr-type
  ub.fin-doc.str-podr-name       = p-str-podr-name
  ub.fin-doc.sum-base            = p-sum-base
  ub.fin-doc.sum-doc             = p-sum-doc
  ub.fin-doc.sum-rubl            = p-sum-rubl
  ub.fin-doc.sum-contr           = p-sum-contr
  ub.fin-doc.trn-doc-code        = v-cash-book-place
  ub.fin-doc.vid-opl             = p-vid-opl
  ub.fin-doc.vid-plat            = p-vid-plat
  ub.fin-doc.user-db-num-doc     = g#db-num
  ub.fin-doc.user-name-doc       = g#userid
  ub.fin-doc.CashBookId          = p-cashbookid
  ub.fin-doc.doc-author          = (if v-author = '':U
                                    and p-doc-author <> 'manual':U
                                    then ub.fin-doc.doc-author
                                    else p-doc-author
                                    )
  ub.fin-doc.shift-flag =  (if l-shift-on
                                  and lookup(ub.fin-doc.fin-ext-doc-type, 'пко,рко':U) > 0
                                  and (ub.fin-doc.doc-author = 'manual':U or ub.fin-doc.doc-author = 'auto':U)
                                  then integer('1':U)
                                  else 0)
  ub.fin-doc.shift-date  = p-shift-date
  ub.fin-doc.shift-num   = p-shift-num
  ub.fin-doc.shift-name  = p-shift-name
  .
  if ub.fin-doc.con-stat > 0 then do:
    if ub.fin-doc.con-stat = 1 then do:
      if ub.fin-doc.sum-contr <= ub.fin-doc.con-sum-contr then assign ub.fin-doc.con-stat = 2 .
    end.
    else do:
      if ub.fin-doc.sum-contr > ub.fin-doc.con-sum-contr then assign ub.fin-doc.con-stat = 1 .
    end.
  end.
  if available buf_contract then do:
    if (buf_contract.gen-factur = 3 or
        buf_contract.gen-factur = 13 or
        buf_contract.gen-factur = 103 or
        buf_contract.gen-factur = 113) then
      assign  ub.fin-doc.need-factur = 1 .
  end.
  release ub.fin-doc no-error.
  if error-status:error then do:
   run err-mess in this-procedure (substitute("Ошибка при сохранении записи ПЛАТЕЖА &1: &2", ERROR-STATUS:GET-message(1), return-value ), output v-ret-mess).
    undo, return error (if p-silent = no then  "":U  else v-ret-mess).
  end.
  if not (p-mode = 'ИЗМЕНЕНИЕ':U
         and
         v-author <> '') then do:
    for each ub.fin-doc-tax where
            ub.fin-doc-tax.host-code = p-host-code
        AND ub.fin-doc-tax.fin-doc-code = p-fin-doc-code:
      find first tt0-fin-doc-tax no-lock where
                tt0-fin-doc-tax.host-code = p-host-code
            AND tt0-fin-doc-tax.fin-doc-code = p-fin-doc-code
            AND tt0-fin-doc-tax.line-num = ub.fin-doc-tax.line-num no-error .
      if not available tt0-fin-doc-tax then do:
        delete ub.fin-doc-tax.
      end.
    end.
  for each tt0-fin-doc-tax :
      find first ub.fin-doc-tax where
                ub.fin-doc-tax.host-code = p-host-code
            AND ub.fin-doc-tax.fin-doc-code = p-fin-doc-code
            AND ub.fin-doc-tax.line-num   = tt0-fin-doc-tax.line-num
            no-error .
      if not available ub.fin-doc-tax then do:
        create ub.fin-doc-tax.
        assign
        ub.fin-doc-tax.host-code = p-host-code
        ub.fin-doc-tax.fin-doc-code = p-fin-doc-code
        ub.fin-doc-tax.line-num = tt0-fin-doc-tax.line-num
        .
      end.
      buffer-copy tt0-fin-doc-tax except host-code fin-doc-code line-num
      to ub.fin-doc-tax.
      run recalc-tax in this-procedure (buffer ub.fin-doc-tax
                                      , p-curr-code
                                      , p-contract-curr
                                      , p-base-rate
                                      , p-base-scale
                                      , p-exch-rate
                                      , p-exch-scale
                                      , p-contract-rate
                                      , p-contract-scale
                                      ).
    end.
    for each tt0-fin-doc-attr :
      find first ub.fin-doc-attr where
                ub.fin-doc-attr.host-code = p-host-code
            AND ub.fin-doc-attr.fin-doc-code = p-fin-doc-code
            AND ub.fin-doc-attr.attr-code   = tt0-fin-doc-attr.attr-code
            no-error .
      if not available ub.fin-doc-attr then do:
        create ub.fin-doc-attr.
      end.
      buffer-copy tt0-fin-doc-attr to ub.fin-doc-attr.
    end.
    define variable v-cmp as logical no-undo .
    if  p-save-payment then do:
      for each ub.payment where
              ub.payment.host-code = p-host-code
          AND ub.payment.source-type = 'платеж':U
          and ub.payment.source-ref = string(p-fin-doc-code)
    on error  undo , return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
    on stop   undo , return error substitute( "&1. stop", vss-workfile )
    on endkey undo , return error substitute( "&1. endkey", vss-workfile )
    :
        find first tt0-payment no-lock where
                  tt0-payment.host-code = p-host-code
              AND tt0-payment.source-type = ub.payment.source-type
              AND tt0-payment.source-ref = ub.payment.source-ref
              and tt0-payment.d-card = ub.payment.d-card  no-error .
        if not available tt0-payment then do:
          delete ub.payment no-error.
          if error-status:error then do:
            run err-mess in this-procedure (substitute("Ошибка при удалении привязки платежа к ДК &4&1&2&1&3"
                                    ,chr(10)
                                    , error-status:get-message(1)
                                    , return-value
                                    , tt0-payment.d-card
                                    )
                          , output v-ret-mess).
            undo, return error (if p-silent = no then  '':U  else v-ret-mess).
          end.
        end.
      end.
      for each tt0-payment
      on error  undo , return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
      on stop   undo , return error substitute( "&1. stop", vss-workfile )
      on endkey undo , return error substitute( "&1. endkey", vss-workfile )
      :
        v-cmp = yes.
        find first ub.payment where
                  ub.payment.host-code = p-host-code
              AND ub.payment.source-type = 'платеж':U
              AND ub.payment.source-ref = string(p-fin-doc-code)
              and ub.payment.d-card = tt0-payment.d-card
              no-error .
        if not available ub.payment then do:
          if v-pmnt-code = '':U then do:
            find first buf0_payment no-lock where buf0_payment.host-code = p-host-code
                AND buf0_payment.source-type = 'платеж':U
                AND buf0_payment.source-ref = string(p-fin-doc-code) no-error.
          if available buf0_payment then do:
            assign
            v-pmnt-code = entry(1, buf0_payment.pmnt-code, "_").
          end.
          end.
          assign
          v-full-pmnt-code  = substitute("&1_&2", v-pmnt-code, entry(2, tt0-payment.pmnt-code, "_"))
          tt0-payment.pmnt-code = v-full-pmnt-code
          .
          v-cmp = no.
        end.
        else do:
          buffer-compare tt0-payment
          except pmnt-code to ub.payment
          case-sensitive
          save result in v-cmp.
        end.
        if not v-cmp then do:
          run ref/payment1.p (
                                input (if available ub.payment then 'ИЗМЕНЕНИЕ':U else 'ДОБАВЛЕНИЕ':U)
                              ,input p-silent
                              ,input-output tt0-payment.pmnt-code
                              ,input tt0-payment.cli-type
                              ,input tt0-payment.cli-code
                              ,input p-payer-type
                              ,input p-payer-code
                              ,input tt0-payment.host-code
                              ,input tt0-payment.tot-cli
                              ,input (tt0-payment.tot-cli * p-exch-rate / p-exch-scale) /  (p-base-rate / p-base-scale)
                              ,input (tt0-payment.tot-cli * p-exch-rate / p-exch-scale)
                              ,input p-doc-date
                              ,input p-curr-code
                              ,input tt0-payment.exch-rate
                              ,input tt0-payment.exch-scale
                              ,input tt0-payment.base-rate
                              ,input tt0-payment.base-scale
                              ,input p-pay-date
                              ,input ?
                              ,input tt0-payment.source-type
                              ,input tt0-payment.source-ref
                              ,input tt0-payment.d-card
                              ,input tt0-payment.pay-code
                              ,input 'ожид':U
                              ,input tt0-payment.PS
                              ,INPUT g#userid
                              ,INPUT '':U
                              ) no-error .
          if error-status:error then do:
            run err-mess in this-procedure (substitute("Ошибка при создании привязки платежа к ДК &4&1&2&1&3"
                                    ,chr(10)
                                    , error-status:get-message(1)
                                    , return-value
                                    , tt0-payment.d-card
                                    )
                          , output v-ret-mess).
            undo, return error (if p-silent = no then  '':U  else v-ret-mess).
          end.
        end.
      end.
    end.
  end.
end.
PROCEDURE err-mess:
  DEFINE INPUT PARAMETER p-mess as character No-UNDO.
  define output parameter p-ret-mess as character no-undo .
  assign
  p-ret-mess =  substitute("ПЛАТЕЖ &1: фирма: &2 N: &3,&4 вн. № &5&4&6"
                            , p-fin-doc-type
                            , p-host-code
                            , p-prn-doc-code
                            , chr(10)
                            , p-fin-doc-code
                            , p-mess
                            ).
  CASE p-silent:
    when yes then do:
      p-ret-mess = substitute("ПЛАТЕЖ &1: фирма: &2 N: &3 Вн № &4&5&6"
                              , p-fin-doc-type
                              , p-host-code
                              , p-prn-doc-code
                              , p-fin-doc-code
                              , chr(10)
                              , p-mess
                              ).
    end.
    when no then do:
      message
      p-mess
      view-as alert-box error .
    end.
  end.
END PROCEDURE.
procedure recalc-tax :
define parameter buffer buf_fin-doc-tax for ub.fin-doc-tax.
define input parameter p-curr-code like ub.fin-doc.curr-code no-undo .
define input parameter p-contract-curr like ub.fin-doc.contract-curr no-undo .
define input parameter p-base-rate like ub.fin-doc.base-rate no-undo .
define input parameter p-base-scale like ub.fin-doc.base-scale no-undo .
define input parameter p-exch-rate like ub.fin-doc.exch-rate no-undo .
define input parameter p-exch-scale like ub.fin-doc.exch-scale no-undo .
define input parameter p-contract-rate like ub.fin-doc.contract-rate no-undo .
define input parameter p-contract-scale like ub.fin-doc.contract-scale no-undo .
  do
  on error undo, return error
  :
    CASE p-curr-code:
      when 0 then do:
        assign
        buf_fin-doc-tax.sum-line-rubl = buf_fin-doc-tax.sum-line-doc
        buf_fin-doc-tax.sum-line-base = buf_fin-doc-tax.sum-line-doc / p-base-rate * p-base-scale
        buf_fin-doc-tax.sum-slt-line-rubl = buf_fin-doc-tax.sum-slt-line-doc
        buf_fin-doc-tax.sum-slt-line-base = buf_fin-doc-tax.sum-slt-line-doc / p-base-rate * p-base-scale
        buf_fin-doc-tax.sum-vat-line-rubl = buf_fin-doc-tax.sum-vat-line-doc
        buf_fin-doc-tax.sum-vat-line-base = buf_fin-doc-tax.sum-vat-line-doc / p-base-rate * p-base-scale
        .
      end.
      when v-base-code then do:
        assign
        buf_fin-doc-tax.sum-line-base = buf_fin-doc-tax.sum-line-doc
        buf_fin-doc-tax.sum-line-rubl = buf_fin-doc-tax.sum-line-doc * p-base-rate / p-base-scale
        buf_fin-doc-tax.sum-slt-line-base = buf_fin-doc-tax.sum-slt-line-doc
        buf_fin-doc-tax.sum-slt-line-rubl = buf_fin-doc-tax.sum-slt-line-doc * p-base-rate / p-base-scale
        buf_fin-doc-tax.sum-vat-line-base = buf_fin-doc-tax.sum-vat-line-doc
        buf_fin-doc-tax.sum-vat-line-rubl = buf_fin-doc-tax.sum-vat-line-doc * p-base-rate / p-base-scale
        .
      end.
      otherwise do:
        assign
        buf_fin-doc-tax.sum-line-rubl = buf_fin-doc-tax.sum-line-doc * p-exch-rate / p-exch-scale
        buf_fin-doc-tax.sum-line-base = buf_fin-doc-tax.sum-line-doc * (p-exch-rate / p-exch-scale)  /
        p-base-rate * p-base-scale
        buf_fin-doc-tax.sum-slt-line-rubl = buf_fin-doc-tax.sum-slt-line-doc * p-exch-rate / p-exch-scale
        buf_fin-doc-tax.sum-slt-line-base = buf_fin-doc-tax.sum-slt-line-doc * (p-exch-rate / p-exch-scale)  /
        p-base-rate * p-base-scale
        buf_fin-doc-tax.sum-vat-line-rubl = buf_fin-doc-tax.sum-vat-line-doc * p-exch-rate / p-exch-scale
        buf_fin-doc-tax.sum-vat-line-base = buf_fin-doc-tax.sum-vat-line-doc * (p-exch-rate / p-exch-scale)  /
        p-base-rate * p-base-scale
        .
      end.
    END CASE.
    CASE p-contract-curr:
      when p-curr-code then do:
        assign
        buf_fin-doc-tax.sum-line-contr = buf_fin-doc-tax.sum-line-doc
        buf_fin-doc-tax.sum-slt-line-contr = buf_fin-doc-tax.sum-slt-line-doc
        buf_fin-doc-tax.sum-vat-line-contr = buf_fin-doc-tax.sum-vat-line-doc
        .
      end.
      when 0 then do:
        assign
        buf_fin-doc-tax.sum-line-contr = buf_fin-doc-tax.sum-line-rubl
        buf_fin-doc-tax.sum-slt-line-contr = buf_fin-doc-tax.sum-slt-line-rubl
        buf_fin-doc-tax.sum-vat-line-contr = buf_fin-doc-tax.sum-vat-line-rubl
        .
      end.
      when v-base-code then do:
        assign
        buf_fin-doc-tax.sum-line-contr = buf_fin-doc-tax.sum-line-base
        buf_fin-doc-tax.sum-slt-line-contr = buf_fin-doc-tax.sum-slt-line-base
        buf_fin-doc-tax.sum-vat-line-contr = buf_fin-doc-tax.sum-vat-line-base
        .
      end.
      otherwise do:
        assign
        buf_fin-doc-tax.sum-line-contr = buf_fin-doc-tax.sum-line-rubl / ( p-contract-rate / p-contract-scale)
        buf_fin-doc-tax.sum-slt-line-contr = buf_fin-doc-tax.sum-slt-line-rubl / ( p-contract-rate / p-contract-scale)
        buf_fin-doc-tax.sum-vat-line-contr = buf_fin-doc-tax.sum-vat-line-rubl / ( p-contract-rate / p-contract-scale )
        .
      end.
    END CASE.
  end.
end procedure.
