block-level on error undo, throw.
define input-output     parameter p-rec as recid no-undo.
define input parameter  p-mode                as character no-undo .
define input parameter  p-silent              as logical no-undo .
define input parameter  p-is-deploy           as logical no-undo .
define input parameter  p-host-code           like ub.sysconf.host-code        no-undo .
define input parameter  p-grp-code            like ub.clients.grp-code         no-undo .
define input parameter  p-obj-name            like ub.clients.obj-name         no-undo .
define input parameter  p-avrg-price          like ub.sysconf.avrg-price       no-undo .
define input parameter  p-artic-disable       like ub.sysconf.artic-disable    no-undo .
define input parameter  p-base-code           like ub.sysconf.base-code        no-undo .
define input parameter  p-branch              like ub.sysconf.branch           no-undo .
define input parameter  p-cash-pay            like ub.sysconf.cash-pay         no-undo .
define input parameter  p-cashier             like ub.sysconf.cashier          no-undo .
define input parameter  p-cons-vat-pc         like ub.sysconf.cons-vat-pc      no-undo .
define input parameter  p-credit-pay          like ub.sysconf.credit-pay       no-undo .
define input parameter  p-firm-db-num         like ub.sysconf.firm-db-num      no-undo .
define input parameter  p-head-position       like ub.sysconf.head-position    no-undo .
define input parameter  p-KOPF                like ub.sysconf.KOPF             no-undo .
define input parameter  p-negative-rest       like ub.sysconf.negative-rest    no-undo .
define input parameter  p-ord-prt             like ub.sysconf.ord-prt          no-undo .
define input parameter  p-osn-base            like ub.sysconf.osn-base         no-undo .
define input parameter  p-property            like ub.sysconf.property         no-undo .
define input parameter  p-purch-code          like ub.sysconf.purch-code       no-undo .
define input parameter  p-ret-credit-pay      like ub.sysconf.ret-credit-pay   no-undo .
define input parameter  p-sale-type           like ub.sysconf.sale-type        no-undo .
define input parameter  p-sale-code           like ub.sysconf.sale-code        no-undo .
define input parameter  p-snr-accnt           like ub.sysconf.snr-accnt        no-undo .
define input parameter  p-SOEI                like ub.sysconf.SOEI             no-undo .
define input parameter  p-transport-cli-type  like ub.sysconf.transport-cli-type no-undo .
define input parameter  p-transport-cli-code  like ub.sysconf.transport-cli-code no-undo .
define input parameter  p-transport-host      like ub.sysconf.transport-host   no-undo .
define input parameter  p-transport-contract  like ub.sysconf.transport-contract no-undo .
define input parameter  p-transport-uslov     like ub.sysconf.transport-uslov  no-undo .
define input parameter  p-transport-value     like ub.sysconf.transport-value  no-undo .
define input parameter  p-main-obj-type       like ub.firm.main-obj-type       no-undo .
define input parameter  p-main-obj-code       like ub.firm.main-obj-code       no-undo .
define input parameter  p-als-gds             as   logical                     no-undo .
define input parameter  p-egrip-date          as date                          no-undo.
define input parameter  p-egrip-num           as character                     no-undo.
define input parameter  p-gen-s-f-office      like ub.sysconf.gen-s-f-office   no-undo .
define variable vss-revision    as character no-undo init "$Revision: 7d2fe421d6dd, 1113, rls $":U .
define variable vss-author      as character no-undo init "$Author: SMMolotkov $":U .
define variable vss-date        as character no-undo init "$Date: Thu Dec 14 02:13:53 2017 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: sysconf1.p $":U .
define variable vss-archive     as character no-undo init "$Archive: adm/sysconf1.p $":U .
define variable vss-description as character no-undo init "Сохранение изменений СВОЕЙ ФИРМЫ".
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
def var vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable v-db-num like ub.db.db-num no-undo .
define variable conf-par     as character no-undo .
define variable par-type     as character no-undo .
define variable v-is-hold    as logical   no-undo .
define variable v-is-fin     as logical   no-undo .
define variable v-is-credit  as logical no-undo .
define variable vartpsi      as character no-undo .
define variable vartpsi-type as character no-undo .
define variable vardeleted   as logical   no-undo.
define variable glog         as logical no-undo .
define buffer buf_sysconf for ub.sysconf.
define buffer buf_clients for ub.clients.
define buffer buf_pay-type for ub.pay-type .
define buffer buf_cash-pay for ub.cash-pay.
define buffer buf_currency for ub.currency.
define buffer posr_sysconf for ub.sysconf.
define buffer main_sysconf for ub.sysconf.
define buffer main_clients for ub.clients.
define buffer main_firm  for ub.firm.
if p-mode <> 'ДОБАВЛЕНИЕ':U
AND p-mode <> 'ИЗМЕНЕНИЕ':U then do:
  message
  vss-workfile vss-revision vss-description skip
  "Неверный параметр p-mode" p-mode
  view-as alert-box error .
  return error '':u.
end.
if p-mode = 'ИЗМЕНЕНИЕ':U
and p-is-deploy = yes then do:
  message
  vss-workfile vss-revision vss-description skip
  "Неверный параметр p-is-deploy" p-is-deploy
  view-as alert-box error .
  return error '':u.
end.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdbnum in g#library
  (output v-db-num
  )  .
if v-db-num <> 0
then do:
  run err-mess in this-procedure ( input substitute("Нельзя изменять запись СВОЕЙ ФИРМЫ в УБД: Номер текущей БД &1", v-db-num ) ).
  undo, return error "":U.
end.
if not can-find (ub.currency where
                ub.currency.curr-code = p-base-code no-lock) then do:
  run err-mess in this-procedure ( input substitute("Не найдена базовая валюта: код валюты &1", p-base-code ) ).
  undo, return error "base-code":U.
end.
if p-obj-name = "":U then do:
  run err-mess in this-procedure ( input "Имя СВОЕЙ ФИРМЫ НЕ МОЖЕТ БЫТЬ ПУСТЫМ" ).
  undo, return error "obj-name":U.
end.
if p-mode = 'ДОБАВЛЕНИЕ':U then do:
  if can-find (ub.sysconf where
              ub.sysconf.host = p-host-code no-lock) then do:
    run err-mess in this-procedure ( input substitute("Уже есть СВОЯ ФИРМА с кодом &1", p-host-code) ).
    undo, return error "host-code":U.
  end.
  if not p-is-deploy
  and
  can-find (first ub.clients no-lock where
                  ub.clients.obj-code = p-host-code
              and ub.clients.obj-type = 'орг':U) then do:
    run err-mess in this-procedure ( input substitute("Уже есть КОНТРАГЕНТ-организация с кодом &1", p-host-code) ).
    undo, return error "host-code":U.
  end.
end.
else do:
  if not can-find (ub.clients where
                  ub.clients.obj-code = p-host-code
              and ub.clients.obj-type = 'орг':U no-lock)
  or
  p-host-code = 0 then do:
    if p-host-code = 0 then do:
      run err-mess in this-procedure ( input "Код СВОЕЙ ФИРМЫ не может быть равен 0" ).
    end.
    else do:
      run err-mess in this-procedure ( input substitute("Не найден КОНТРАГЕНТ для СВОЕЙ ФИРМЫ с кодом &1", p-host-code) ).
    end.
    undo, return error "host-code":U.
  end.
  if not can-find (ub.firm where
                  ub.firm.firm-code = p-host-code no-lock) then do:
    run err-mess in this-procedure ( input substitute("Не найдена ФИРМА для СВОЕЙ ФИРМЫ с кодом &1", p-host-code) ).
    undo, return error "host-code":U.
  end.
end.
if not p-is-deploy then do:
  if p-credit-pay <> 0 then do:
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'iscredit'
  ,input  0
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  no
  ,output conf-par
  ,output par-type
  ) no-error .
    if not error-status:error then
    assign
    v-is-credit = (conf-par = "yes")
    .
    if v-is-credit then do:
    find first buf_cash-pay no-lock where
              buf_cash-pay.cdpay-code = p-credit-pay no-error.
    if not available buf_cash-pay then do:
      run err-mess in this-procedure  ( input substitute("Не определен тип платежа в кредит на кассе - код &1", p-credit-pay ) ).
      undo, return error "credit-pay":U.
    end.
    if buf_cash-pay.is-credit = no then do:
      run err-mess in this-procedure ( input substitute("Тип платежа в кредит на кассе - код &1 НЕ задан как платеж <В кредит>", p-credit-pay ) ).
      undo, return error "credit-pay":U.
    end.
    if not can-find (ub.pay-type where
                    ub.pay-type.obj-code = p-ret-credit-pay no-lock) then do:
      run err-mess in this-procedure ( input substitute("Не найден тип оплаты долгов кредита с кодом &1", p-ret-credit-pay ) ).
      undo, return error "ret-credit-pay":U.
    end.
  end.
  end.
end.
if not can-find (ub.clients where
                ub.clients.obj-code = p-sale-code
            and ub.clients.obj-type = p-sale-type no-lock) then do:
  run err-mess in this-procedure ( input substitute("Не найден контрагент РЕАЛИЗАЦИЯ: тип &1 код&2", p-sale-type, p-sale-code) ).
  undo, return error "sale-code":U.
end.
if p-sale-type <> 'орг':U then do:
  run err-mess in this-procedure ( input substitute("Неверный тип контрагента РЕАЛИЗАЦИЯ: тип &1 код&2", p-sale-type, p-sale-code) ).
  undo, return error "sale-type":U.
end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'holding'
  ,input  0
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  no
  ,output conf-par
  ,output par-type
  ) no-error .
if not error-status:error then
assign
v-is-hold = (conf-par = "yes")
.
if v-is-hold and p-mode = 'ИЗМЕНЕНИЕ':U then do:
  run check-main-obj in this-procedure no-error .
  if error-status:error then do:
    undo, return error return-value.
  end.
end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-fin'
  ,input  0
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  no
  ,output conf-par
  ,output par-type
  ) no-error .
assign
v-is-fin = (conf-par = "yes")
.
if p-avrg-price = yes then do:
  find first posr_sysconf no-lock where
            posr_sysconf.avrg-price = yes
         and (p-mode = 'ДОБАВЛЕНИЕ':U
          or posr_sysconf.host-code <> p-host-code) no-error .
  if available posr_sysconf then do:
     if p-silent then do:
        run err-mess in this-procedure  ( input substitute("ПОСРЕДНИКОМ ДЛЯ ОТЧЕТОВ уже является другая фирма &1", posr_sysconf.host-code ) ).
        undo, return error "":U.
     end.
     else do:
       message
       substitute("ПОСРЕДНИКОМ ДЛЯ ОТЧЕТОВ УЖЕ является другая фирма &1&2" +
                  "Вы уверены, что хотите сделать ПОСРЕДНИКОМ ДЛЯ ОТЧЕТОВ данную фирму &3?"
                  , posr_sysconf.host-code
                  , chr(10)
                  , p-host-code
                  )
       view-as alert-box question update glog.
       if not glog then do:
          undo, return error 'avrg-price'.
       end.
       else do:
         find current posr_sysconf exclusive-lock.
       end.
     end.
  end.
end.
_main:
do for
main_sysconf,
main_clients,
main_firm
on error undo, return error return-value
on stop undo, return error return-value
:
  if p-mode = 'ДОБАВЛЕНИЕ':U then do:
    run gbl/conf-rd.p ( input "host-num"
                       ,input ""
                       ,input ""
                       ,input 0
                       ,input ""
                       ,input ""
                       ,input ""
                       ,input yes
                       ,output conf-par
                       ,output par-type) no-error.
    if error-status:error then undo, return error.
    if par-type <> "i" then do:
      run err-mess in this-procedure ( input substitute("Неправильный тип параметра host-num &1 (должно быть integer)", par-type)).
      undo, return error "":U.
    end.
    if integer (conf-par) <> 0 then do:
      for each buf_sysconf no-lock:
        accumulate buf_sysconf.host-code (count).
      end.
      if (accum count buf_sysconf.host-code) >= integer (conf-par) then do:
        run err-mess in this-procedure ( input substitute("Создание новой фирмы запрещено. Превышено допустимое число фирм", conf-par)).
        undo, return error "":U.
      end.
    end.
    if p-is-deploy then do:
      FIND FIRST main_clients where
                main_clients.obj-type = 'орг':U
            AND main_clients.obj-code = p-host-code No-ERROR.
      if not available main_clients then do:
        create main_clients.
      end.
      find first main_firm where
                main_firm.firm-code = p-host-code no-error .
      if not available main_firm then do:
        run err-mess in this-procedure ( input substitute("Не найдена запись ФИРМА для записи СВОЯ ФИРМА с кодом &1", p-host-code)).
        undo, return error "":U.
      end.
    end.
    create main_sysconf.
    if not p-is-deploy then do:
      create main_clients.
      create main_firm.
    end.
    assign
    main_sysconf.firm-db-num = 0
    main_sysconf.ord-prt = yes
    main_sysconf.host-code = p-host-code
    main_sysconf.base-code = p-base-code
    p-rec = recid(main_sysconf)
    .
    assign
      main_clients.obj-code = p-host-code
      main_clients.obj-type = 'орг':U
      main_clients.obj-name = p-obj-name
      main_clients.stts     = 0
      main_clients.db-num   = ?
      main_clients.grp-code = p-grp-code
      main_firm.firm-code   = p-host-code
    .
  end.
  else do:
    find first main_sysconf where
               recid(main_sysconf) = p-rec no-error .
    if not available main_sysconf then do:
      run err-mess in this-procedure ( input substitute("Не найдена запись СВОЯ ФИРМА - p-rec &1", p-rec)).
      undo, return error "":U.
    end.
    FIND FIRST main_clients where
              main_clients.obj-type = 'орг':U
          AND main_clients.obj-code = p-host-code No-ERROR.
    if not available main_clients then do:
      run err-mess in this-procedure ( input substitute("Не найдена запись КЛИЕНТ для записи СВОЯ ФИРМА с кодом &1", p-host-code)).
      undo, return error "":U.
    end.
    find first main_firm where
              main_firm.firm-code = p-host-code no-error .
    if not available main_firm then do:
      run err-mess in this-procedure ( input substitute("Не найдена запись ФИРМА для записи СВОЯ ФИРМА с кодом &1", p-host-code)).
      undo, return error '':u.
    end.
    if main_sysconf.host-code <> p-host-code
    or main_sysconf.base-code <> p-base-code
    then do:
      run err-mess in this-procedure ( input substitute("Для уже имеющейся СВОЕЙ ФИРМЫ &1 нельзя изменить код и валюту", p-host-code)).
      undo, return error '':u.
    end.
  end.
  if available posr_sysconf
  and p-avrg-price then do:
    posr_sysconf.avrg-price = no.
  end.
  assign
  main_clients.obj-name         =  p-obj-name
  main_sysconf.artic-disable    =  p-artic-disable
  main_sysconf.avrg-price       =  p-avrg-price
  main_sysconf.gen-s-f-office   =  p-gen-s-f-office
  main_sysconf.base-code        =  p-base-code
  main_sysconf.branch           =  p-branch
  main_sysconf.cash-pay         =  p-cash-pay
  main_sysconf.cashier          =  p-cashier
  main_sysconf.cons-vat-pc      =  p-cons-vat-pc
  main_sysconf.credit-pay       =  p-credit-pay
  main_sysconf.head-position    =  p-head-position
  main_sysconf.KOPF             =  p-KOPF
  main_sysconf.negative-rest    =  p-negative-rest
  main_sysconf.osn-base         =  p-osn-base
  main_sysconf.property         =  p-property
  main_sysconf.purch-code       =  p-purch-code
  main_sysconf.ret-credit-pay   =  p-ret-credit-pay
  main_sysconf.sale-type        =  p-sale-type
  main_sysconf.sale-code        =  p-sale-code
  main_sysconf.snr-accnt        =  p-snr-accnt
  main_sysconf.SOEI             =  p-SOEI
  main_sysconf.transport-cli-type =  p-transport-cli-type
  main_sysconf.transport-cli-code =  p-transport-cli-code
  main_sysconf.transport-host   =  p-transport-host
  main_sysconf.transport-contract =  p-transport-contract
  main_sysconf.transport-uslov  =  p-transport-uslov
  main_sysconf.transport-value  =  p-transport-value
  main_firm.main-obj-type       =  p-main-obj-type
  main_firm.main-obj-code       =  p-main-obj-code
  p-rec = recid(main_sysconf)
  .
  release main_sysconf no-error.
  if error-status:error then do:
     run err-mess in this-procedure ( input substitute("Ошибка при сохранении записи СВОЯ ФИРМА &1: &2", p-host-code, ERROR-STATUS:GET-message(1))).
    undo, return error "":U.
  end.
  release main_clients no-error.
  if error-status:error then do:
    run err-mess in this-procedure ( input substitute("Ошибка при сохранении записи КЛИЕНТ для СВОЕЙ ФИРМЫ &1: &2", p-host-code, ERROR-STATUS:GET-message(1))).
    undo, return error "":U.
  end.
  release main_firm no-error.
  if error-status:error then do:
      run err-mess in this-procedure ( input substitute("Ошибка при сохранении записи ФИРМА для СВОЕЙ ФИРМЫ &1: &2", p-host-code, ERROR-STATUS:GET-message(1))).
      undo, return error "":U.
    end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'tpsi'
  ,input  0
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  no
  ,output vartpsi
  ,output vartpsi-type
  ) no-error .
    if ( not error-status :error ) and
      vartpsi = "yes"             and
      p-als-gds = yes             then do:
      run clntattr-write in this-procedure (
                                            input 'орг':U
                                            ,input p-host-code
                                            ,input 'als-gds':U
                                            ,input "yes":u).
  end.
  else do:
    run clntattr-delete in this-procedure (
                                          input  'орг':U
                                          ,input  p-host-code
                                          ,input  'als-gds':U
                                          ,output vardeleted
     ).
  end.
  if p-egrip-date = ?
  then do:
    run clntattr-delete in this-procedure (
                                            input  'орг':U
                                            ,input  p-host-code
                                            ,input  'egrip-date':U
                                            ,output vardeleted
     ).
  end.
  else do:
    run clntattr-write in this-procedure (
                                          input 'орг':U
                                          ,input p-host-code
                                          ,input 'egrip-date':U
                                          ,input string( p-egrip-date ) ).
  end.
  if p-egrip-num = "":U
  or p-egrip-num = ?
  then do:
    run clntattr-delete in this-procedure (
                                            input  'орг':U
                                            ,input  p-host-code
                                            ,input  'egrip-num':U
                                            ,output vardeleted
     ).
  end.
  else do:
    run clntattr-write in this-procedure (
                                            input 'орг':U
                                            ,input p-host-code
                                            ,input 'egrip-num':U
                                            ,input p-egrip-num ).
  end.
  find first main_sysconf where
            recid(main_sysconf) = p-rec .
end.
PROCEDURE check-main-obj :
define buffer buf_shop  for ub.shop.
define buffer buf_store for ub.store.
if p-main-obj-code = 0
and p-main-obj-type = "":U then return.
find first buf_clients no-lock where
           buf_clients.obj-type = p-main-obj-type
       and buf_clients.obj-code = p-main-obj-code no-error .
if not available buf_clients then do:
  run err-mess in this-procedure ( input substitute("Не найден контрагент ГЛАВНЫЙ ОБЪЕКТ ФИРМЫ для межфирменного перемещения: тип &1 код&2", p-main-obj-type, p-main-obj-code) ).
  undo, return error "main-obj-code":U.
end.
if buf_clients.obj-type <> 'маг':U
AND buf_clients.obj-type <> 'скл':U then do:
  run err-mess in this-procedure ( input substitute("ГЛАВНЫЙ ОБЪЕКТ ФИРМЫ для межфирменного перемещения: тип &1 код &2, а может быть только типа &3 или &4", p-main-obj-type, p-main-obj-code, 'маг':U, 'скл':U) ).
  undo, return error "main-obj-type":U.
end.
if p-main-obj-type = 'маг':U then do:
  find first buf_shop where
            buf_shop.obj-code = p-main-obj-code no-lock.
  if buf_shop.host-code <> p-host-code then do:
    run err-mess in this-procedure ( input substitute("Магазин &1, выбранный как ГЛАВНЫЙ ОБЪЕКТ межфирменного перемещения, не принадлежит фирме &2", p-main-obj-code, p-host-code ) ).
    return error.
  end.
end.
if buf_clients.obj-type = 'скл':U then do:
  find first buf_store where
            buf_store.obj-code = p-main-obj-code no-lock.
  if buf_store.host-code <> p-host-code then do:
    run err-mess in this-procedure ( input substitute("Склад &1, выбранный как ГЛАВНЫЙ ОБЪЕКТ межфирменного перемещения, не принадлежит фирме &2", p-main-obj-code, p-host-code ) ).
    return error "main-obj-code":U.
  end.
end.
END PROCEDURE.
PROCEDURE err-mess:
  DEFINE INPUT PARAMETER p-mess as character No-UNDO.
  message
  p-mess
  view-as alert-box error .
END PROCEDURE.
