block-level on error undo, throw.
define input-output parameter p-rec as recid no-undo.
define input parameter        p-mode                as character no-undo .
define input parameter        p-obj-code            like ub.store.obj-code                 no-undo .
define input parameter        p-db-num              like ub.clients.db-num                no-undo .
define input parameter        p-host-code           like ub.store.host-code                no-undo .
define input parameter        p-grp-code            like ub.clients.grp-code              no-undo .
define input parameter        p-obj-name            like ub.clients.obj-name              no-undo .
define input parameter        p-PS                  like ub.clients.PS                    no-undo .
define input parameter        p-active              like ub.store.active                  no-undo .
define input parameter        p-addres1             like ub.store.addres1                  no-undo .
define input parameter        p-addres2             like ub.store.addres2                  no-undo .
define input parameter        p-doc-prt             like ub.store.doc-prt                  no-undo .
define input parameter        p-down-pay            like ub.store.down-pay                 no-undo .
define input parameter        p-fax                 like ub.store.fax                      no-undo .
define input parameter        p-holidays            like ub.store.holidays                 no-undo .
define input parameter        p-in-ov               like ub.store.in-ov                    no-undo .
define input parameter        p-in-pay              like ub.store.in-pay                   no-undo .
define input parameter        p-in-perm             like ub.store.in-perm                  no-undo .
define input parameter        p-inout-price         like ub.store.inout-price              no-undo .
define input parameter        p-inv-pay             like ub.store.inv-pay                  no-undo .
define input parameter        p-load-time           like ub.store.load-time                no-undo .
define input parameter        p-no-eq               like ub.store.no-eq                    no-undo .
define input parameter        p-out-line-discnt     like ub.store.out-line-discnt          no-undo .
define input parameter        p-out-pay             like ub.store.out-pay                  no-undo .
define input parameter        p-out-rate            like ub.store.out-rate                 no-undo .
define input parameter        p-phone               like ub.store.phone                    no-undo .
define input parameter        p-price-calc          like ub.store.price-calc               no-undo .
define input parameter        p-ret-pay             like ub.store.ret-pay                  no-undo .
define input parameter        p-ret-sup-pay         like ub.store.ret-sup-pay              no-undo .
define input parameter        p-fbr-pay             like ub.store.fbr-pay                  no-undo .
define input parameter        p-rsrv-time           like ub.store.rsrv-time                no-undo .
define input parameter        p-shift-on            like ub.store.shift-on                 no-undo .
define input parameter        p-store-boss          like ub.store.store-boss               no-undo .
define input parameter        p-store-man           like ub.store.store-man                no-undo .
define input parameter        p-unit-cli-perm       like ub.store.unit-cli-perm            no-undo .
define input parameter        p-work-hours          like ub.store.work-hours               no-undo .
define input parameter        p-purch-code          as   integer                           no-undo .
define input parameter        p-envd                as   logical                           no-undo .
define input parameter        p-pharm               as   logical                           no-undo .
define input parameter        p-KPP                 as   character                         no-undo .
define variable vss-revision    as character no-undo init "$Revision: 9b43ebeef021, 979, rls $":U .
define variable vss-author      as character no-undo init "$Author: AAShepel $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jun 19 10:51:53 2017 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: store01.p $":U .
define variable vss-archive     as character no-undo init "$Archive: adm/store01.p $":U .
define variable vss-description as character no-undo init "Сохранение изменений в карточке склада".
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
define variable v-curr-r-b as character no-undo .
define variable par-type as character no-undo .
define variable v-envd      as character no-undo.
define variable v-pharm      as character no-undo.
define variable v-delete    as logical no-undo.
define variable v-kpp       as character no-undo.
define buffer buf_sysconf for ub.sysconf.
define buffer buf_clients for ub.clients.
define buffer buf_pay-type for ub.pay-type .
define buffer buf_dis-card-type for ub.dis-card-type.
if p-mode <> 'ДОБАВЛЕНИЕ':U
AND p-mode <> 'ИЗМЕНЕНИЕ':U then do:
  message
  vss-workfile vss-revision vss-description skip
  "Неверный параметр p-mode" p-mode
  view-as alert-box error .
  return error '':u.
end.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdbnum in g#library
  (output v-db-num
  )  .
if v-db-num <> 0
then do:
  run err-mess in this-procedure (substitute("Нельзя изменять запись СКЛАДА в УБД: Номер текущей БД &1 ", v-db-num ) ).
  undo, return error "":U.
end.
run chk-code in this-procedure (p-obj-code, p-mode) no-error .
if error-status:error then do:
  undo, return error "obj-code":U.
end.
if p-obj-name = "":U then do:
  run err-mess in this-procedure (substitute("Введите название склада &1 ", p-obj-code ) ).
  undo, return error "obj-name":U.
end.
if not can-find( ub.db where
                   ub.db.db-num = p-db-num )
then do:
  run err-mess in this-procedure (substitute("Неверный номер БД. Нет БД с номером &1 ", p-db-num ) ).
  undo, return error "db-num":U.
end.
find first buf_sysconf no-lock where
            buf_sysconf.host-code = p-host-code no-error .
if not available buf_sysconf then do:
  run err-mess in this-procedure (substitute("Не найдена фирма с кодом &1 для склада &2", p-host-code, p-obj-code ) ).
  undo, return error "":U.
end.
if buf_sysconf.firm-db-num <> 0
AND p-db-num <> buf_sysconf.firm-db-num
then do:
  run err-mess in this-procedure (substitute("Главная БД фирмы &1 не совпадает с БД, к которой относится склад &2: главная БД фирмы - &3, а склад относится к БД &4", p-host-code, p-obj-code, buf_sysconf.firm-db-num, p-db-num ) ).
  undo, return error "db-num":U.
end.
if p-down-pay <> 0 then do:
  FIND first buf_pay-type no-lock where
            buf_pay-type.obj-code = p-down-pay NO-error .
  if not available buf_pay-type then do:
    run err-mess in this-procedure (substitute("Неверный код оплаты списания для склада &1: &2", p-obj-code, p-down-pay) ).
    undo, return error "down-pay":U.
  end.
end.
if p-in-pay <> 0 then do:
  FIND first buf_pay-type no-lock where
            buf_pay-type.obj-code = p-in-pay NO-error .
  if not available buf_pay-type then do:
    run err-mess in this-procedure (substitute("Неверный код оплаты прихода для склада &1: &2", p-obj-code, p-in-pay) ).
    undo, return error "in-pay":U.
  end.
end.
if p-inv-pay <> 0 then do:
  FIND first buf_pay-type no-lock where
            buf_pay-type.obj-code  = p-inv-pay NO-error .
  if not available buf_pay-type then do:
    run err-mess in this-procedure (substitute("Неверный код оплаты инвентаризации для склада &1: &2", p-obj-code, p-inv-pay) ).
    undo, return error "inv-pay":U.
  end.
end.
if p-out-pay <> 0 then do:
  FIND first buf_pay-type no-lock where
            buf_pay-type.obj-code = p-out-pay NO-error .
  if not available buf_pay-type then do:
    run err-mess in this-procedure (substitute("Неверный код оплаты расхода для склада &1: &2", p-obj-code, p-out-pay) ).
    undo, return error "out-pay":U.
  end.
end.
if p-ret-pay <> 0 then do:
  FIND first buf_pay-type no-lock where
            buf_pay-type.obj-code = p-ret-pay NO-error .
  if not available buf_pay-type then do:
    run err-mess in this-procedure (substitute("Неверный код оплаты возврата от покупателя для склада &1: &2", p-obj-code, p-ret-pay) ).
    undo, return error "ret-pay":U.
  end.
end.
if p-ret-sup-pay <> 0 then do:
  FIND first buf_pay-type no-lock where
            buf_pay-type.obj-code = p-ret-sup-pay NO-error .
  if not available buf_pay-type then do:
    run err-mess in this-procedure (substitute("Неверный код оплаты возврата поставщику для склада &1: &2", p-obj-code, p-ret-sup-pay) ).
    undo, return error "ret-sup-pay":U.
  end.
end.
if p-fbr-pay <> 0 then do:
  FIND first buf_pay-type no-lock where
            buf_pay-type.obj-code = p-fbr-pay NO-error .
  if not available buf_pay-type then do:
    run err-mess in this-procedure (substitute("Неверный код оплаты производства для склада &1: &2", p-obj-code, p-fbr-pay) ).
    undo, return error "fbr-pay":U.
  end.
end.
_MAIN:
DO ON ERROR UNDO, RETURN ERROR
ON STOP UNDO, RETURN ERROR:
  if p-mode = 'ДОБАВЛЕНИЕ':U then do:
    create ub.store.
    create ub.clients.
    assign
    ub.clients.obj-code = p-obj-code
    ub.clients.obj-type = 'скл':U
    ub.clients.db-num   = p-db-num
    ub.clients.grp-code = p-grp-code
    ub.clients.host-code = p-host-code
    ub.store.obj-code = p-obj-code
    ub.store.host-code   = p-host-code
    p-rec = recid(ub.clients)
    .
  end.
  else do:
    FIND FIRST ub.clients where
              recid(ub.clients) = p-rec No-ERROR.
    if not available ub.clients then do:
      message
      vss-workfile vss-revision vss-description skip
      "Не найдена запись КЛИЕНТ для записи СКЛАДА - p-rec" p-rec
      view-as alert-box error .
      undo, return error '':u.
    end.
    find first ub.store where
              ub.store.obj-code = p-obj-code no-error .
    if not available ub.store then do:
      message
      vss-workfile vss-revision vss-description skip
      "Не найдена запись СКЛАД с кодом" p-obj-code
      view-as alert-box error .
      undo, return error '':u.
    end.
    if ub.store.obj-code <> p-obj-code
    or ub.store.host-code <> p-host-code
    or ub.clients.db-num    <> p-db-num
    then do:
      message
      vss-workfile vss-revision vss-description skip
      "Для уже имеющегося СКЛАДА нельзя изменить номер склада, номер БД и код фирмы" skip
      view-as alert-box ERROR.
      undo, return error '':U.
    end.
  end.
  assign
  ub.clients.obj-name         =  p-obj-name
  ub.clients.PS               =  p-PS
  ub.store.active              =  p-active
  ub.store.addres1             =  p-addres1
  ub.store.addres2             =  p-addres2
  ub.store.doc-prt             =  p-doc-prt
  ub.store.down-pay            =  p-down-pay
  ub.store.fax                 =  p-fax
  ub.store.holidays            =  p-holidays
  ub.store.in-ov               =  p-in-ov
  ub.store.in-pay              =  p-in-pay
  ub.store.in-perm             =  p-in-perm
  ub.store.inout-price         =  p-inout-price
  ub.store.inv-pay             =  p-inv-pay
  ub.store.load-time           =  p-load-time
  ub.store.no-eq               =  p-no-eq
  ub.store.out-line-discnt     =  p-out-line-discnt
  ub.store.out-pay             =  p-out-pay
  ub.store.out-rate            =  p-out-rate
  ub.store.phone               =  p-phone
  ub.store.price-calc          =  p-price-calc
  ub.store.ret-pay             =  p-ret-pay
  ub.store.ret-sup-pay         =  p-ret-sup-pay
  ub.store.fbr-pay             =  p-fbr-pay
  ub.store.rsrv-time           =  p-rsrv-time
  ub.store.shift-on            =  p-shift-on
  ub.store.store-boss          =  p-store-boss
  ub.store.store-man           =  p-store-man
  ub.store.unit-cli-perm       =  p-unit-cli-perm
  ub.store.work-hours          =  p-work-hours
  ub.store.purch-code          =  p-purch-code
  p-rec = recid(ub.clients )
  .
 release ub.clients no-error.
 if error-status:error then do:
    run err-mess in this-procedure (substitute("Ошибка при сохранении записи КЛИЕНТ для склада &1:&2&3&2&4"
                          , p-obj-code
                          , chr(10)
                          , ERROR-STATUS:GET-message(1)
                          , return-value
                          )).
    undo, return error "":U.
 end.
 p-obj-code = ub.store.obj-code.
 release ub.store no-error.
 if error-status:error then do:
     run err-mess in this-procedure ( substitute("Ошибка при сохранении записи СКЛАД &1:&2&3&2&4"
                             , p-obj-code
                             , chr(10)
                             , ERROR-STATUS:GET-message(1)
                             , return-value
                             )).
    undo, return error "":U.
 end.
  run clntattr-value in this-procedure
    (input 'скл':U,
    input  p-obj-code,
    input  'pharm':U,
    output v-pharm,
    output par-type).
  if v-pharm = "yes":u then do:
     if p-pharm = no then do:
       run clntattr-delete in this-procedure
       (input 'скл':U,
        input  p-obj-code,
        input  'pharm':U,
        output v-delete).
     end.
  end.
  else do:
    if p-pharm = yes then do:
      run clntattr-write in this-procedure
       (input  'скл':U,
        input  p-obj-code,
        input  'pharm':U,
        input  "yes":u).
    end.
  end.
 run clntattr-value in this-procedure
      (input 'скл':U,
      input  p-obj-code,
      input  'kpp':U,
      output v-kpp,
      output par-type).
  if v-kpp <> "":u and v-kpp <> ? then do:
    if p-kpp = "" or p-kpp = ? then do:
      run clntattr-delete in this-procedure
       (input 'скл':U,
        input  p-obj-code,
        input  'kpp':U,
        output v-delete).
    end.
    else do:
      if p-kpp <> "" and p-kpp <> ? then do:
       run clntattr-write in this-procedure
       (input  'скл':U,
        input  p-obj-code,
        input  'kpp':U,
        input  p-kpp).
    end.
    end.
  end.
    else do:
    if p-kpp <> "" and p-kpp <> ? then do:
      run clntattr-write in this-procedure
       (input  'скл':U,
        input  p-obj-code,
        input  'kpp':U,
        input  p-kpp).
    end.
  end.
  run clntattr-value in this-procedure
    (input 'скл':U,
    input  p-obj-code,
    input  'envd':U,
    output v-envd,
    output par-type).
  if v-envd = "yes":u then do:
     if p-envd = no then do:
       run clntattr-delete in this-procedure
       (input 'скл':U,
        input  p-obj-code,
        input  'envd':U,
        output v-delete).
     end.
  end.
  else do:
    if p-envd = yes then do:
      run clntattr-write in this-procedure
       (input  'скл':U,
        input  p-obj-code,
        input  'envd':U,
        input  "yes":u).
    end.
  end.
end.
PROCEDURE chk-code :
define input parameter p-obj-code like ub.store.obj-code no-undo .
define input parameter p-mode     as character no-undo .
define variable  conf-par as character no-undo.
define variable  par-type as character no-undo.
define variable  dopi as integer no-undo.
if p-obj-code = 0 then do:
  run err-mess in this-procedure ("Код склада должен быть больше 0 " ).
  return error.
end.
if  p-mode = 'ДОБАВЛЕНИЕ':U
and can-find( ub.store where ub.store.obj-code = p-obj-code ) then   do:
  run err-mess in this-procedure (substitute("Склад с кодом &1 уже есть, измените код", p-obj-code ) ).
  return error.
end.
return.
END PROCEDURE.
PROCEDURE err-mess:
  DEFINE INPUT PARAMETER p-mess as character No-UNDO.
  message
  p-mess
  view-as alert-box error .
END PROCEDURE.
