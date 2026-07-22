block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: libofarh.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/libofarh.p $":U .
define variable vss-description as character no-undo init "Библиотека для работы с финансовыми архивами по финансовым обязательствам".
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
define new global shared variable g#libofarh as handle no-undo .
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
procedure thbjattr_code :
   define input  parameter p-upper-code     as character no-undo .
   define input  parameter p-code           as character no-undo .
   define output parameter p-label          as character no-undo .
   define output parameter p-user-can-edit  as logical   no-undo .
   define output parameter p-output-display as logical   no-undo .
   define output parameter p-other          as character no-undo .
   define output parameter p-prop-list      as character no-undo .
   define output parameter p-prop-type-list as character no-undo .
   define output parameter p-prop-label-list as character no-undo .
   define output parameter p-global          as logical no-undo .
   define output parameter p-host           as logical no-undo .
   define output parameter p-shop           as logical no-undo .
   define output parameter p-store          as logical no-undo .
   define output parameter p-db             as logical no-undo .
   define variable p-region as logical no-undo.
   run thbjattr_code_reg in this-procedure (
                                            p-upper-code,
                                            p-code,
                                            output p-label,
                                            output p-user-can-edit,
                                            output p-output-display,
                                            output p-other,
                                            output p-prop-list,
                                            output p-prop-type-list,
                                            output p-prop-label-list,
                                            output p-global,
                                            output p-host,
                                            output p-shop,
                                            output p-store,
                                            output p-db,
                                            output p-region
                                            ).
end procedure.
procedure thbjattr_code_reg :
define input  parameter p-upper-code     as character no-undo .
define input  parameter p-code           as character no-undo .
define output parameter p-label          as character no-undo .
define output parameter p-user-can-edit  as logical   no-undo .
define output parameter p-output-display as logical   no-undo .
define output parameter p-other          as character no-undo .
define output parameter p-prop-list      as character no-undo .
define output parameter p-prop-type-list as character no-undo .
define output parameter p-prop-label-list as character no-undo .
define output parameter p-global          as logical no-undo .
define output parameter p-host           as logical no-undo .
define output parameter p-shop           as logical no-undo .
define output parameter p-store          as logical no-undo .
define output parameter p-db             as logical no-undo .
define output parameter p-region         as logical no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_code in g#attr-lib
    (input  p-upper-code
    ,input  p-code
    ,output p-label
    ,output p-user-can-edit
    ,output p-output-display
    ,output p-other
    ,output p-prop-list
    ,output p-prop-type-list
    ,output p-prop-label-list
    ,output p-global
    ,output p-host
    ,output p-shop
    ,output p-store
    ,output p-db
    ,output p-region
    ) no-error .
  if error-status :error
  then do:
    undo, return error substitute( "&1. &2&3&4", vss-include-info0, return-value, chr(10), error-status :get-message (1)).
  end.
end.
end procedure.
procedure thbjattr_tooltip :
define input  parameter p-upper-code  as character no-undo .
define input  parameter p-code      as character no-undo .
define output parameter p-tooltip   as character no-undo .
define output parameter p-label     as character no-undo .
define output parameter p-tooltip-code as character no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_tooltip in g#attr-lib
    (input  p-upper-code
    ,input  p-code
    ,output p-tooltip
    ,output p-label
    ,output p-tooltip-code
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
procedure thbjattr_legacy :
define input  parameter p-upper-code     as character no-undo .
define output parameter p-level-way      as character no-undo .
define output parameter p-up-way         as character no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_legacy in g#attr-lib
    (input  p-upper-code
    ,output p-level-way
    ,output p-up-way
    ) no-error .
  if error-status :error
  then do:
    undo, return error substitute( "&1. &2&3&4", vss-include-info0, return-value, chr(10), error-status :get-message (1)).
  end.
end.
end procedure.
procedure thbjattr_value :
define input  parameter p-obj-type like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-code like ub.thbj-attr.upper-prop-code  no-undo .
define input  parameter p-code     like ub.thbj-attr.prop-code  no-undo .
define output parameter p-value-character like ub.thbj-attr.property-value-character no-undo .
define output parameter p-value-date    like ub.thbj-attr.property-value-date no-undo .
define output parameter p-value-decimal like ub.thbj-attr.property-value-decimal no-undo .
define output parameter p-value-integer like ub.thbj-attr.property-value-integer no-undo .
define output parameter p-value-logical like ub.thbj-attr.property-value-logical no-undo .
define output parameter p-type     as character no-undo .
define output parameter p-found as decimal no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_value in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-code
    ,input  p-code
    ,output p-value-character
    ,output p-value-date
    ,output p-value-decimal
    ,output p-value-integer
    ,output p-value-logical
    ,output p-type
    ,output p-found
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
procedure thbjattr_get-section :
define input  parameter p-obj-type like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-param-code  like ub.thbj-attr.upper-prop-code  no-undo .
define input  parameter p-mode as character no-undo .
define input-output parameter table-handle p-tth.
define output parameter p-all-found as decimal no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_get-section in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-param-code
    ,input  p-mode
    ,input-output table-handle p-tth
    ,output p-all-found
    ) no-error .
  if error-status :error
  then do:
    delete object p-tth.
    undo, return error return-value .
  end.
  delete object p-tth.
end.
end procedure.
procedure thbjattr_write :
define input  parameter p-obj-type like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-code  like ub.thbj-attr.upper-prop-code  no-undo .
define input  parameter p-code     like ub.thbj-attr.prop-code  no-undo .
define input  parameter p-value-character like ub.thbj-attr.property-value-character no-undo .
define input  parameter p-value-date like ub.thbj-attr.property-value-date no-undo .
define input  parameter p-value-decimal like ub.thbj-attr.property-value-decimal no-undo .
define input  parameter p-value-integer like ub.thbj-attr.property-value-integer no-undo .
define input  parameter p-value-logical like ub.thbj-attr.property-value-logical no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_write in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-code
    ,input  p-code
    ,input  p-value-character
    ,input  p-value-date
    ,input  p-value-decimal
    ,input  p-value-integer
    ,input  p-value-logical
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
procedure thbjattr_set-section :
define input  parameter p-obj-type like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-code  like ub.thbj-attr.upper-prop-code  no-undo .
define input  parameter table-handle p-tth.
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_set-section in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-code
    ,input  table-handle p-tth
    ) no-error .
  if error-status :error
  then do:
    delete object p-tth.
    undo, return error return-value .
  end.
  delete object p-tth.
end.
end procedure.
procedure thbjattr_delete :
define input  parameter p-obj-type   like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code   like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-code like ub.thbj-attr.upper-prop-code  no-undo .
define input  parameter p-code       like ub.thbj-attr.prop-code  no-undo .
define output parameter p-deleted  as logical no-undo.
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_delete in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-code
    ,input  p-code
    ,output p-deleted
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
procedure thbjattr_delete-section :
define input  parameter p-obj-type   like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code   like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-code like ub.thbj-attr.upper-prop-code  no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_delete-section in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-code
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
procedure thbjattr_manual-edit :
define input  parameter p-ucode          as character no-undo .
define input  parameter p-code           as character no-undo .
define output parameter p-section-num    as integer no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_manual-edit in g#attr-lib
    (input  p-ucode
    ,input  p-code
    ,output  p-section-num
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
if valid-handle (g#libofarh)
and g#libofarh <> this-procedure :handle
and g#libofarh :get-signature('libofarh_taskclco':u) <> ""
then do:
  message
    vss-workfile vss-revision vss-description skip
    "Попытка повторной загрузки библиотеки для работы с финансовыми архивами по финансовым обязательствам" skip
    g#libofarh skip
    g#libofarh :type skip
    g#libofarh :file-name skip
    valid-handle(g#libofarh) skip
    this-procedure :handle skip
    this-procedure :type skip
    this-procedure :file-name skip
    valid-handle(this-procedure) skip
    view-as alert-box error .
  undo, return error .
end.
else do:
  assign
    g#libofarh = this-procedure :handle
  .
end.
on delete of this-procedure do:
  assign
    g#libofarh = ?
  .
end.
define stream str-err.
procedure libofarh_taskclco:
define input parameter parhost-code   like ub.fin-ob.host-code   no-undo.
define input parameter pardoc-code    like ub.fin-ob.doc-code    no-undo.
define input parameter paruser-name   as character no-undo .
define input parameter parmode        as character no-undo .
define input parameter parcheck-order as logical   no-undo .
define output parameter p-recalc as logical   no-undo .
define buffer bf_contract                for ub.contract.
define buffer bf_fin-ob                  for ub.fin-ob.
define buffer bf-trb_fin-ob              for ub.fin-ob.
define buffer bf_fin-ob-tax              for ub.fin-ob-tax.
define buffer bf_sysconf                 for ub.sysconf.
define buffer bf_clients                 for ub.clients.
define buffer bf_fin-gds-part            for ub.fin-gds-part.
define buffer bf_parts                   for ub.parts.
define variable varsum-vat-doc   as   decimal               no-undo.
define variable varsum-vat-rubl  as   decimal               no-undo.
define variable varsum-vat-base  as   decimal               no-undo.
define variable varsum-vat-contr as   decimal               no-undo.
define variable varsum-slt-doc   as   decimal               no-undo.
define variable varsum-slt-rubl  as   decimal               no-undo.
define variable varsum-slt-base  as   decimal               no-undo.
define variable varsum-slt-contr as   decimal               no-undo.
define variable varrel-dog-code  as   logical               no-undo.
define variable varcurr-dog-code like ub.currency.curr-code no-undo.
do on error undo, return error substitute ("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
  find first bf_fin-ob where bf_fin-ob.host-code = parhost-code and
                             bf_fin-ob.doc-code  = pardoc-code  exclusive-lock no-error.
  if not available bf_fin-ob then do:
    return error substitute ("Не найдено финансовое обязательство с внутренним номером &1 по фирме &2.", pardoc-code, parhost-code).
  end.
  p-recalc = false  .
  if parcheck-order then do:
    find first bf-trb_fin-ob where bf-trb_fin-ob.host-code  = bf_fin-ob.host-code  and
                                   bf-trb_fin-ob.status_    = 'факт':U               and
                                   bf-trb_fin-ob.fact-order > bf_fin-ob.fact-order no-lock no-error.
    if available bf-trb_fin-ob then do:
      p-recalc = true .
    end.
  end.
  find first bf_sysconf where bf_sysconf.host-code = bf_fin-ob.host-code no-lock no-error.
  if error-status:error then do:
    return error substitute ("Критическая ошибка. Не найдена запись sysconf по фирме &1.", bf_fin-ob.host-code).
  end.
  if bf_sysconf.fin-calc = 1 then do:
    if bf_fin-ob.obj-type = "":u and
       bf_fin-ob.obj-code = 0    then do:
      return error substitute ("По фирме &1 ведется раздельный учет по объектам с поставщиками. В финансовом обязательстве с внутренним номером &2.",
                               bf_sysconf.host-code,
                               bf_fin-ob.doc-code).
    end.
    find first bf_clients where bf_clients.obj-type = bf_fin-ob.obj-type and
                                bf_clients.obj-code = bf_fin-ob.obj-code no-lock no-error.
    if not available bf_clients then do:
      return error substitute ("В финансовом обязательстве с внутренним номером &1, указан объект &2 &3 которого нет в справочнике.", bf_fin-ob.doc-code, bf_fin-ob.obj-type, bf_fin-ob.obj-code).
    end.
    for each bf_fin-gds-part where bf_fin-gds-part.host-code   = bf_fin-ob.host-code and
                                   bf_fin-gds-part.fin-ob-code = bf_fin-ob.doc-code  on error undo, return error substitute ("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)) :
      if bf_fin-gds-part.obj-type <> bf_clients.obj-type or
         bf_fin-gds-part.obj-code <> bf_clients.obj-code then do:
        return error substitute ("В финансовом обязательстве с внутренним номером &1 указан объект &2 &3, но данное фин. обязательство связано с партией из документа &4 по объекту &5 &6.",
                                 bf_fin-ob.doc-code,
                                 bf_fin-ob.obj-type,
                                 bf_fin-ob.obj-code,
                                 bf_fin-gds-part.out-code,
                                 bf_fin-gds-part.obj-type,
                                 bf_fin-gds-part.obj-code).
      end.
    end.
  end.
  if parmode <> "close":u  and
     parmode <> "delete":u then do:
    return error substitute ("Неверный параметр вызова расчета финансовых архивов &1. Должен быть close или delete.", parmode).
  end.
  assign
    varsum-vat-doc   = 0
    varsum-vat-rubl  = 0
    varsum-vat-base  = 0
    varsum-vat-contr = 0
    varsum-slt-doc   = 0
    varsum-slt-rubl  = 0
    varsum-slt-base  = 0
    varsum-slt-contr = 0 .
  for each bf_fin-ob-tax where bf_fin-ob-tax.host-code = bf_fin-ob.host-code and
                               bf_fin-ob-tax.doc-code  = bf_fin-ob.doc-code  on error undo, return error substitute ("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
     assign
       varsum-vat-doc   = varsum-vat-doc   + bf_fin-ob-tax.sum-vat-line-doc
       varsum-vat-rubl  = varsum-vat-rubl  + bf_fin-ob-tax.sum-vat-line-rubl
       varsum-vat-base  = varsum-vat-base  + bf_fin-ob-tax.sum-vat-line-base
       varsum-vat-contr = varsum-vat-contr + bf_fin-ob-tax.sum-vat-line-contr
       varsum-slt-doc   = varsum-slt-doc   + bf_fin-ob-tax.sum-slt-line-doc
       varsum-slt-rubl  = varsum-slt-rubl  + bf_fin-ob-tax.sum-slt-line-rubl
       varsum-slt-base  = varsum-slt-base  + bf_fin-ob-tax.sum-slt-line-base
       varsum-slt-contr = varsum-slt-contr + bf_fin-ob-tax.sum-slt-line-contr
    .
  end.
  if bf_fin-ob.status_ <> 'факт':U then do:
    return error substitute ("Финансовое обязательство с номером &1 не находится в статусе &2.", bf_fin-ob.prn-doc-code, 'факт':U).
  end.
  if not (bf_fin-ob.doc-type = 'при':U   or
          bf_fin-ob.doc-type = 'рас':U) then do:
    return error substitute ("Неизвестный тип &1 финансового обязательства с номером &2 внутренний номер &3.", bf_fin-ob.doc-type, bf_fin-ob.prn-doc-code, bf_fin-ob.doc-code).
  end.
  if bf_fin-ob.contract-code <> 0 then do:
    find first bf_contract where bf_contract.host-code     = bf_fin-ob.host-code     and
                                 bf_contract.contract-code = bf_fin-ob.contract-code exclusive-lock no-error.
    if not available bf_contract then do:
      return error substitute ("По финансовому обязательству с внутренним номером &1 на фирме &2 указан договор с внутренним номером &3, которого нет в базе данных.", bf_fin-ob.doc-code, bf_fin-ob.host-code, bf_fin-ob.contract-code).
    end.
    assign
      varrel-dog-code = yes.
  end.
  else do:
    assign
      varrel-dog-code = no.
  end.
  run libofarh_calc-arh-fin-ob-contr in this-procedure (input bf_fin-ob.host-code,
                                                        input bf_fin-ob.payer-type,
                                                        input bf_fin-ob.payer-code,
                                                        input bf_fin-ob.receiver-type,
                                                        input bf_fin-ob.receiver-code,
                                                        input bf_fin-ob.doc-type,
                                                        input "":u,
                                                        input bf_fin-ob.fact-order,
                                                        input bf_fin-ob.doc-code,
                                                        input bf_fin-ob.fact-date,
                                                        input bf_sysconf.base-code,
                                                        input varcurr-dog-code,
                                                        input varrel-dog-code,
                                                        input (if available bf_contract then bf_contract.contract-code else 0),
                                                        input (if parmode = "close":u then bf_fin-ob.sum-doc      else - bf_fin-ob.sum-doc  ),
                                                        input (if parmode = "close":u then bf_fin-ob.sum-rubl     else - bf_fin-ob.sum-rubl ),
                                                        input (if parmode = "close":u then bf_fin-ob.sum-base     else - bf_fin-ob.sum-base ),
                                                        input (if parmode = "close":u then bf_fin-ob.sum-contract else - bf_fin-ob.sum-contract),
                                                        input (if parmode = "close":u then varsum-vat-doc         else - varsum-vat-doc     ),
                                                        input (if parmode = "close":u then varsum-vat-rubl        else - varsum-vat-rubl    ),
                                                        input (if parmode = "close":u then varsum-vat-base        else - varsum-vat-base    ),
                                                        input (if parmode = "close":u then varsum-vat-contr       else - varsum-vat-contr   ),
                                                        input (if parmode = "close":u then varsum-slt-doc         else - varsum-slt-doc     ),
                                                        input (if parmode = "close":u then varsum-slt-rubl        else - varsum-slt-rubl    ),
                                                        input (if parmode = "close":u then varsum-slt-base        else - varsum-slt-base    ),
                                                        input (if parmode = "close":u then varsum-slt-contr       else - varsum-slt-contr   )
                                                        ) no-error.
  if error-status:error then do:
    return error substitute ("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)).
  end.
  if bf_sysconf.fin-calc = 1 then do:
    run libofarh_calc-arh-fin-ob-contr-obj in this-procedure (input bf_fin-ob.host-code,
                                                              input bf_fin-ob.obj-type,
                                                              input bf_fin-ob.obj-code,
                                                              input bf_fin-ob.payer-type,
                                                              input bf_fin-ob.payer-code,
                                                              input bf_fin-ob.receiver-type,
                                                              input bf_fin-ob.receiver-code,
                                                              input bf_fin-ob.doc-type,
                                                              input "":u,
                                                              input bf_fin-ob.fact-order,
                                                              input bf_fin-ob.doc-code,
                                                              input bf_fin-ob.fact-date,
                                                              input bf_sysconf.base-code,
                                                              input varcurr-dog-code,
                                                              input varrel-dog-code,
                                                              input (if available bf_contract then bf_contract.contract-code else 0),
                                                              input (if parmode = "close":u then bf_fin-ob.sum-doc      else - bf_fin-ob.sum-doc  ),
                                                              input (if parmode = "close":u then bf_fin-ob.sum-rubl     else - bf_fin-ob.sum-rubl ),
                                                              input (if parmode = "close":u then bf_fin-ob.sum-base     else - bf_fin-ob.sum-base ),
                                                              input (if parmode = "close":u then bf_fin-ob.sum-contract else - bf_fin-ob.sum-contract),
                                                              input (if parmode = "close":u then varsum-vat-doc         else - varsum-vat-doc     ),
                                                              input (if parmode = "close":u then varsum-vat-rubl        else - varsum-vat-rubl    ),
                                                              input (if parmode = "close":u then varsum-vat-base        else - varsum-vat-base    ),
                                                              input (if parmode = "close":u then varsum-vat-contr       else - varsum-vat-contr   ),
                                                              input (if parmode = "close":u then varsum-slt-doc         else - varsum-slt-doc     ),
                                                              input (if parmode = "close":u then varsum-slt-rubl        else - varsum-slt-rubl    ),
                                                              input (if parmode = "close":u then varsum-slt-base        else - varsum-slt-base    ),
                                                              input (if parmode = "close":u then varsum-slt-contr       else - varsum-slt-contr   )
                                                              ) no-error.
    if error-status:error then do:
      return error substitute ("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)).
    end.
  end.
end.
end procedure.
procedure libofarh_calc-arh-fin-ob-contr :
define input parameter parhost-code           like ub.fin-ob.host-code        no-undo.
define input parameter parpayer-type          like ub.fin-ob.payer-type       no-undo.
define input parameter parpayer-code          like ub.fin-ob.payer-code       no-undo.
define input parameter parreceiver-type       like ub.fin-ob.receiver-type    no-undo.
define input parameter parreceiver-code       like ub.fin-ob.receiver-code    no-undo.
define input parameter pardoc-type            like ub.fin-ob.doc-type         no-undo.
define input parameter parsum-type            as   character                  no-undo.
define input parameter parfact-order          like ub.fin-ob.fact-order       no-undo.
define input parameter pardoc-code            like ub.fin-ob.doc-code         no-undo.
define input parameter parfact-date           like ub.fin-ob.fact-date        no-undo.
define input parameter parbase-code           like ub.sysconf.base-code       no-undo.
define input parameter parcurr-dog-code       like ub.contract.curr-code      no-undo.
define input parameter parrel-dog-code        as   logical                    no-undo.
define input parameter parcontract-code       like ub.contract.contract-code  no-undo.
define input parameter parsum-doc             as   decimal                    no-undo.
define input parameter parsum-rubl            as   decimal                    no-undo.
define input parameter parsum-base            as   decimal                    no-undo.
define input parameter parsum-contr           as   decimal                    no-undo.
define input parameter parsum-vat-doc         as   decimal                    no-undo.
define input parameter parsum-vat-rubl        as   decimal                    no-undo.
define input parameter parsum-vat-base        as   decimal                    no-undo.
define input parameter parsum-vat-contr       as   decimal                    no-undo.
define input parameter parsum-slt-doc         as   decimal                    no-undo.
define input parameter parsum-slt-rubl        as   decimal                    no-undo.
define input parameter parsum-slt-base        as   decimal                    no-undo.
define input parameter parsum-slt-contr       as   decimal                    no-undo.
define buffer bfps_arh-fin-ob-contr for ub.arh-fin-ob-contr.
define buffer bops_arh-fin-ob-contr for ub.arh-fin-ob-contr.
define buffer bfpr_arh-fin-ob-contr for ub.arh-fin-ob-contr.
define buffer bopr_arh-fin-ob-contr for ub.arh-fin-ob-contr.
define buffer bfpb_arh-fin-ob-contr for ub.arh-fin-ob-contr.
define buffer bopb_arh-fin-ob-contr for ub.arh-fin-ob-contr.
define buffer bfpc_arh-fin-ob-contr for ub.arh-fin-ob-contr.
define buffer bopc_arh-fin-ob-contr for ub.arh-fin-ob-contr.
define buffer bfrs_arh-fin-ob-contr for ub.arh-fin-ob-contr.
define buffer bors_arh-fin-ob-contr for ub.arh-fin-ob-contr.
define buffer bfrr_arh-fin-ob-contr for ub.arh-fin-ob-contr.
define buffer borr_arh-fin-ob-contr for ub.arh-fin-ob-contr.
define buffer bfrb_arh-fin-ob-contr for ub.arh-fin-ob-contr.
define buffer borb_arh-fin-ob-contr for ub.arh-fin-ob-contr.
define buffer bfrc_arh-fin-ob-contr for ub.arh-fin-ob-contr.
define buffer borc_arh-fin-ob-contr for ub.arh-fin-ob-contr.
do on error undo, return error substitute ("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
find last bopr_arh-fin-ob-contr where bopr_arh-fin-ob-contr.host-code        = parhost-code     and
                                      bopr_arh-fin-ob-contr.cli-type         = parpayer-type    and
                                      bopr_arh-fin-ob-contr.cli-code         = parpayer-code    and
                                      bopr_arh-fin-ob-contr.contract-code    = parcontract-code and
                                      bopr_arh-fin-ob-contr.fin-ext-doc-type = pardoc-type      and
                                      bopr_arh-fin-ob-contr.calc-curr-code   = 0                and
                                      bopr_arh-fin-ob-contr.sum-type         = parsum-type      and
                                      bopr_arh-fin-ob-contr.fact-order       < parfact-order
                                      no-error.
find first bfpr_arh-fin-ob-contr exclusive-lock where
          bfpr_arh-fin-ob-contr.host-code        = parhost-code     and
          bfpr_arh-fin-ob-contr.cli-type         = parpayer-type    and
          bfpr_arh-fin-ob-contr.cli-code         = parpayer-code    and
          bfpr_arh-fin-ob-contr.contract-code    = parcontract-code and
          bfpr_arh-fin-ob-contr.fin-ext-doc-type = pardoc-type      and
          bfpr_arh-fin-ob-contr.calc-curr-code   = 0                and
          bfpr_arh-fin-ob-contr.sum-type         = parsum-type      and
          bfpr_arh-fin-ob-contr.fact-order       = parfact-order    and
          bfpr_arh-fin-ob-contr.fact-date        = parfact-date
          no-error .
if not available bfpr_arh-fin-ob-contr then create bfpr_arh-fin-ob-contr.
assign
  bfpr_arh-fin-ob-contr.host-code        = parhost-code
  bfpr_arh-fin-ob-contr.cli-type         = parpayer-type
  bfpr_arh-fin-ob-contr.cli-code         = parpayer-code
  bfpr_arh-fin-ob-contr.contract-code    = parcontract-code
  bfpr_arh-fin-ob-contr.fin-ext-doc-type = pardoc-type
  bfpr_arh-fin-ob-contr.calc-curr-code   = 0
  bfpr_arh-fin-ob-contr.sum-type         = parsum-type
  bfpr_arh-fin-ob-contr.cource-des       = "r":u
  bfpr_arh-fin-ob-contr.fact-order       = parfact-order
  bfpr_arh-fin-ob-contr.fin-ob-doc-code  = pardoc-code
  bfpr_arh-fin-ob-contr.fact-date        = parfact-date
  bfpr_arh-fin-ob-contr.income           = (if available bopr_arh-fin-ob-contr then bopr_arh-fin-ob-contr.income      else 0)
  bfpr_arh-fin-ob-contr.income-vat       = (if available bopr_arh-fin-ob-contr then bopr_arh-fin-ob-contr.income-vat  else 0)
  bfpr_arh-fin-ob-contr.income-slt       = (if available bopr_arh-fin-ob-contr then bopr_arh-fin-ob-contr.income-slt  else 0)
  bfpr_arh-fin-ob-contr.expense          = (if available bopr_arh-fin-ob-contr then bopr_arh-fin-ob-contr.expense     else 0) + parsum-rubl
  bfpr_arh-fin-ob-contr.expense-vat      = (if available bopr_arh-fin-ob-contr then bopr_arh-fin-ob-contr.expense-vat else 0) + parsum-vat-rubl
  bfpr_arh-fin-ob-contr.expense-slt      = (if available bopr_arh-fin-ob-contr then bopr_arh-fin-ob-contr.expense-slt else 0) + parsum-slt-rubl
.
if parbase-code <> 0 then do:
  find last bopb_arh-fin-ob-contr where bopb_arh-fin-ob-contr.host-code        = parhost-code     and
                                        bopb_arh-fin-ob-contr.cli-type         = parpayer-type    and
                                        bopb_arh-fin-ob-contr.cli-code         = parpayer-code    and
                                        bopb_arh-fin-ob-contr.contract-code    = parcontract-code and
                                        bopb_arh-fin-ob-contr.fin-ext-doc-type = pardoc-type      and
                                        bopb_arh-fin-ob-contr.calc-curr-code   = parbase-code     and
                                        bopb_arh-fin-ob-contr.sum-type         = parsum-type      and
                                        bopb_arh-fin-ob-contr.fact-order       < parfact-order
                                        no-error.
  find first bfpb_arh-fin-ob-contr exclusive-lock where
            bfpb_arh-fin-ob-contr.host-code        = parhost-code      and
            bfpb_arh-fin-ob-contr.cli-type         = parpayer-type     and
            bfpb_arh-fin-ob-contr.cli-code         = parpayer-code     and
            bfpb_arh-fin-ob-contr.contract-code    = parcontract-code  and
            bfpb_arh-fin-ob-contr.fin-ext-doc-type = pardoc-type       and
            bfpb_arh-fin-ob-contr.calc-curr-code   = parbase-code      and
            bfpb_arh-fin-ob-contr.sum-type         = parsum-type       and
            bfpb_arh-fin-ob-contr.fact-order       = parfact-order     and
            bfpb_arh-fin-ob-contr.fact-date        = parfact-date      no-error .
  if not available bfpb_arh-fin-ob-contr then create bfpb_arh-fin-ob-contr.
  assign
    bfpb_arh-fin-ob-contr.host-code        = parhost-code
    bfpb_arh-fin-ob-contr.cli-type         = parpayer-type
    bfpb_arh-fin-ob-contr.cli-code         = parpayer-code
    bfpb_arh-fin-ob-contr.contract-code    = parcontract-code
    bfpb_arh-fin-ob-contr.fin-ext-doc-type = pardoc-type
    bfpb_arh-fin-ob-contr.calc-curr-code   = parbase-code
    bfpb_arh-fin-ob-contr.sum-type         = parsum-type
    bfpb_arh-fin-ob-contr.cource-des       = "b":u
    bfpb_arh-fin-ob-contr.fact-order       = parfact-order
    bfpb_arh-fin-ob-contr.fin-ob-doc-code  = pardoc-code
    bfpb_arh-fin-ob-contr.fact-date        = parfact-date
    bfpb_arh-fin-ob-contr.income           = (if available bopb_arh-fin-ob-contr then bopb_arh-fin-ob-contr.income      else 0)
    bfpb_arh-fin-ob-contr.income-vat       = (if available bopb_arh-fin-ob-contr then bopb_arh-fin-ob-contr.income-vat  else 0)
    bfpb_arh-fin-ob-contr.income-slt       = (if available bopb_arh-fin-ob-contr then bopb_arh-fin-ob-contr.income-slt  else 0)
    bfpb_arh-fin-ob-contr.expense          = (if available bopb_arh-fin-ob-contr then bopb_arh-fin-ob-contr.expense     else 0) + parsum-base
    bfpb_arh-fin-ob-contr.expense-vat      = (if available bopb_arh-fin-ob-contr then bopb_arh-fin-ob-contr.expense-vat else 0) + parsum-vat-base
    bfpb_arh-fin-ob-contr.expense-slt      = (if available bopb_arh-fin-ob-contr then bopb_arh-fin-ob-contr.expense-slt else 0) + parsum-slt-base
  .
end.
if parrel-dog-code  =  yes          and
   parcurr-dog-code <> 0            and
   parcurr-dog-code <> parbase-code then do:
  find last bopc_arh-fin-ob-contr where bopc_arh-fin-ob-contr.host-code        = parhost-code     and
                                        bopc_arh-fin-ob-contr.cli-type         = parpayer-type    and
                                        bopc_arh-fin-ob-contr.cli-code         = parpayer-code    and
                                        bopc_arh-fin-ob-contr.contract-code    = parcontract-code and
                                        bopc_arh-fin-ob-contr.fin-ext-doc-type = pardoc-type      and
                                        bopc_arh-fin-ob-contr.calc-curr-code   = parcurr-dog-code and
                                        bopc_arh-fin-ob-contr.sum-type         = parsum-type      and
                                        bopc_arh-fin-ob-contr.fact-order       < parfact-order
                                        no-error.
  find first bfpc_arh-fin-ob-contr exclusive-lock where
    bfpc_arh-fin-ob-contr.host-code        = parhost-code    and
    bfpc_arh-fin-ob-contr.cli-type         = parpayer-type   and
    bfpc_arh-fin-ob-contr.cli-code         = parpayer-code   and
    bfpc_arh-fin-ob-contr.contract-code    = parcontract-code and
    bfpc_arh-fin-ob-contr.fin-ext-doc-type = pardoc-type      and
    bfpc_arh-fin-ob-contr.calc-curr-code   = parcurr-dog-code and
    bfpc_arh-fin-ob-contr.sum-type         = parsum-type      and
    bfpc_arh-fin-ob-contr.fact-order       = parfact-order    and
    bfpc_arh-fin-ob-contr.fact-date        = parfact-date
    no-error .
  if not available bfpc_arh-fin-ob-contr then create bfpc_arh-fin-ob-contr.
  assign
    bfpc_arh-fin-ob-contr.host-code        = parhost-code
    bfpc_arh-fin-ob-contr.cli-type         = parpayer-type
    bfpc_arh-fin-ob-contr.cli-code         = parpayer-code
    bfpc_arh-fin-ob-contr.contract-code    = parcontract-code
    bfpc_arh-fin-ob-contr.fin-ext-doc-type = pardoc-type
    bfpc_arh-fin-ob-contr.calc-curr-code   = parcurr-dog-code
    bfpc_arh-fin-ob-contr.sum-type         = parsum-type
    bfpc_arh-fin-ob-contr.cource-des       = "c":u
    bfpc_arh-fin-ob-contr.fact-order       = parfact-order
    bfpc_arh-fin-ob-contr.fin-ob-doc-code  = pardoc-code
    bfpc_arh-fin-ob-contr.fact-date        = parfact-date
    bfpc_arh-fin-ob-contr.income           = (if available bopc_arh-fin-ob-contr then bopc_arh-fin-ob-contr.income      else 0)
    bfpc_arh-fin-ob-contr.income-vat       = (if available bopc_arh-fin-ob-contr then bopc_arh-fin-ob-contr.income-vat  else 0)
    bfpc_arh-fin-ob-contr.income-slt       = (if available bopc_arh-fin-ob-contr then bopc_arh-fin-ob-contr.income-slt  else 0)
    bfpc_arh-fin-ob-contr.expense          = (if available bopc_arh-fin-ob-contr then bopc_arh-fin-ob-contr.expense     else 0) + parsum-contr
    bfpc_arh-fin-ob-contr.expense-vat      = (if available bopc_arh-fin-ob-contr then bopc_arh-fin-ob-contr.expense-vat else 0) + parsum-vat-contr
    bfpc_arh-fin-ob-contr.expense-slt      = (if available bopc_arh-fin-ob-contr then bopc_arh-fin-ob-contr.expense-slt else 0) + parsum-slt-contr
  .
end.
find last borr_arh-fin-ob-contr where borr_arh-fin-ob-contr.host-code        = parhost-code     and
                                      borr_arh-fin-ob-contr.cli-type         = parreceiver-type and
                                      borr_arh-fin-ob-contr.cli-code         = parreceiver-code and
                                      borr_arh-fin-ob-contr.contract-code    = parcontract-code and
                                      borr_arh-fin-ob-contr.fin-ext-doc-type = pardoc-type      and
                                      borr_arh-fin-ob-contr.calc-curr-code   = 0                and
                                      borr_arh-fin-ob-contr.sum-type         = parsum-type      and
                                      borr_arh-fin-ob-contr.fact-order       < parfact-order
                                      no-error.
find first bfrr_arh-fin-ob-contr exclusive-lock where
  bfrr_arh-fin-ob-contr.host-code        = parhost-code         and
  bfrr_arh-fin-ob-contr.cli-type         = parreceiver-type     and
  bfrr_arh-fin-ob-contr.cli-code         = parreceiver-code     and
  bfrr_arh-fin-ob-contr.contract-code    = parcontract-code     and
  bfrr_arh-fin-ob-contr.fin-ext-doc-type = pardoc-type          and
  bfrr_arh-fin-ob-contr.calc-curr-code   = 0                    and
  bfrr_arh-fin-ob-contr.sum-type         = parsum-type          and
  bfrr_arh-fin-ob-contr.fact-order       = parfact-order        and
  bfrr_arh-fin-ob-contr.fact-date        = parfact-date
  no-error .
if not available bfrr_arh-fin-ob-contr then  create bfrr_arh-fin-ob-contr.
assign
  bfrr_arh-fin-ob-contr.host-code        = parhost-code
  bfrr_arh-fin-ob-contr.cli-type         = parreceiver-type
  bfrr_arh-fin-ob-contr.cli-code         = parreceiver-code
  bfrr_arh-fin-ob-contr.contract-code    = parcontract-code
  bfrr_arh-fin-ob-contr.fin-ext-doc-type = pardoc-type
  bfrr_arh-fin-ob-contr.calc-curr-code   = 0
  bfrr_arh-fin-ob-contr.sum-type         = parsum-type
  bfrr_arh-fin-ob-contr.cource-des       = "r":u
  bfrr_arh-fin-ob-contr.fact-order       = parfact-order
  bfrr_arh-fin-ob-contr.fin-ob-doc-code  = pardoc-code
  bfrr_arh-fin-ob-contr.fact-date        = parfact-date
  bfrr_arh-fin-ob-contr.income           = (if available borr_arh-fin-ob-contr then borr_arh-fin-ob-contr.income      else 0) + parsum-rubl
  bfrr_arh-fin-ob-contr.income-vat       = (if available borr_arh-fin-ob-contr then borr_arh-fin-ob-contr.income-vat  else 0) + parsum-vat-rubl
  bfrr_arh-fin-ob-contr.income-slt       = (if available borr_arh-fin-ob-contr then borr_arh-fin-ob-contr.income-slt  else 0) + parsum-slt-rubl
  bfrr_arh-fin-ob-contr.expense          = (if available borr_arh-fin-ob-contr then borr_arh-fin-ob-contr.expense     else 0)
  bfrr_arh-fin-ob-contr.expense-vat      = (if available borr_arh-fin-ob-contr then borr_arh-fin-ob-contr.expense-vat else 0)
  bfrr_arh-fin-ob-contr.expense-slt      = (if available borr_arh-fin-ob-contr then borr_arh-fin-ob-contr.expense-slt else 0)
.
if parbase-code <> 0 then do:
  find last borb_arh-fin-ob-contr where borb_arh-fin-ob-contr.host-code        = parhost-code     and
                                        borb_arh-fin-ob-contr.cli-type         = parreceiver-type and
                                        borb_arh-fin-ob-contr.cli-code         = parreceiver-code and
                                        borb_arh-fin-ob-contr.contract-code    = parcontract-code and
                                        borb_arh-fin-ob-contr.fin-ext-doc-type = pardoc-type      and
                                        borb_arh-fin-ob-contr.calc-curr-code   = parbase-code     and
                                        borb_arh-fin-ob-contr.sum-type         = parsum-type      and
                                        borb_arh-fin-ob-contr.fact-order       = parfact-order
                                        no-error.
find first bfrb_arh-fin-ob-contr exclusive-lock where
    bfrb_arh-fin-ob-contr.host-code        = parhost-code        and
    bfrb_arh-fin-ob-contr.cli-type         = parreceiver-type    and
    bfrb_arh-fin-ob-contr.cli-code         = parreceiver-code    and
    bfrb_arh-fin-ob-contr.contract-code    = parcontract-code    and
    bfrb_arh-fin-ob-contr.fin-ext-doc-type = pardoc-type         and
    bfrb_arh-fin-ob-contr.calc-curr-code   = parbase-code        and
    bfrb_arh-fin-ob-contr.sum-type         = parsum-type         and
    bfrb_arh-fin-ob-contr.fact-order       = parfact-order       and
    bfrb_arh-fin-ob-contr.fact-date        = parfact-date
    no-error .
if not available bfrb_arh-fin-ob-contr then  create bfrb_arh-fin-ob-contr.
  assign
    bfrb_arh-fin-ob-contr.host-code        = parhost-code
    bfrb_arh-fin-ob-contr.cli-type         = parreceiver-type
    bfrb_arh-fin-ob-contr.cli-code         = parreceiver-code
    bfrb_arh-fin-ob-contr.contract-code    = parcontract-code
    bfrb_arh-fin-ob-contr.fin-ext-doc-type = pardoc-type
    bfrb_arh-fin-ob-contr.calc-curr-code   = parbase-code
    bfrb_arh-fin-ob-contr.sum-type         = parsum-type
    bfrb_arh-fin-ob-contr.cource-des       = "b":u
    bfrb_arh-fin-ob-contr.fact-order       = parfact-order
    bfrb_arh-fin-ob-contr.fin-ob-doc-code  = pardoc-code
    bfrb_arh-fin-ob-contr.fact-date        = parfact-date
    bfrb_arh-fin-ob-contr.income           = (if available borb_arh-fin-ob-contr then borb_arh-fin-ob-contr.income      else 0) + parsum-base
    bfrb_arh-fin-ob-contr.income-vat       = (if available borb_arh-fin-ob-contr then borb_arh-fin-ob-contr.income-vat  else 0) + parsum-vat-base
    bfrb_arh-fin-ob-contr.income-slt       = (if available borb_arh-fin-ob-contr then borb_arh-fin-ob-contr.income-slt  else 0) + parsum-slt-base
    bfrb_arh-fin-ob-contr.expense          = (if available borb_arh-fin-ob-contr then borb_arh-fin-ob-contr.expense     else 0)
    bfrb_arh-fin-ob-contr.expense-vat      = (if available borb_arh-fin-ob-contr then borb_arh-fin-ob-contr.expense-vat else 0)
    bfrb_arh-fin-ob-contr.expense-slt      = (if available borb_arh-fin-ob-contr then borb_arh-fin-ob-contr.expense-slt else 0)
  .
end.
if parrel-dog-code  =  yes          and
   parcurr-dog-code <> 0            and
   parcurr-dog-code <> parbase-code then do:
  find last borc_arh-fin-ob-contr where borc_arh-fin-ob-contr.host-code        = parhost-code     and
                                        borc_arh-fin-ob-contr.cli-type         = parreceiver-type and
                                        borc_arh-fin-ob-contr.cli-code         = parreceiver-code and
                                        borc_arh-fin-ob-contr.contract-code    = parcontract-code and
                                        borc_arh-fin-ob-contr.fin-ext-doc-type = pardoc-type      and
                                        borc_arh-fin-ob-contr.calc-curr-code   = parcurr-dog-code and
                                        borc_arh-fin-ob-contr.sum-type         = parsum-type      and
                                        borc_arh-fin-ob-contr.fact-order       = parfact-order
                                        no-error.
  find first bfrc_arh-fin-ob-contr exclusive-lock where
    bfrc_arh-fin-ob-contr.host-code        = parhost-code       and
    bfrc_arh-fin-ob-contr.cli-type         = parreceiver-type   and
    bfrc_arh-fin-ob-contr.cli-code         = parreceiver-code   and
    bfrc_arh-fin-ob-contr.contract-code    = parcontract-code   and
    bfrc_arh-fin-ob-contr.fin-ext-doc-type = pardoc-type        and
    bfrc_arh-fin-ob-contr.calc-curr-code   = parcurr-dog-code   and
    bfrc_arh-fin-ob-contr.sum-type         = parsum-type        and
    bfrc_arh-fin-ob-contr.fact-order       = parfact-order      and
    bfrc_arh-fin-ob-contr.fact-date        = parfact-date
    no-error .
  if not available bfrc_arh-fin-ob-contr then create bfrc_arh-fin-ob-contr.
  assign
    bfrc_arh-fin-ob-contr.host-code        = parhost-code
    bfrc_arh-fin-ob-contr.cli-type         = parreceiver-type
    bfrc_arh-fin-ob-contr.cli-code         = parreceiver-code
    bfrc_arh-fin-ob-contr.contract-code    = parcontract-code
    bfrc_arh-fin-ob-contr.fin-ext-doc-type = pardoc-type
    bfrc_arh-fin-ob-contr.calc-curr-code   = parcurr-dog-code
    bfrc_arh-fin-ob-contr.sum-type         = parsum-type
    bfrc_arh-fin-ob-contr.cource-des       = "c":u
    bfrc_arh-fin-ob-contr.fact-order       = parfact-order
    bfrc_arh-fin-ob-contr.fin-ob-doc-code  = pardoc-code
    bfrc_arh-fin-ob-contr.fact-date        = parfact-date
    bfrc_arh-fin-ob-contr.income           = (if available borc_arh-fin-ob-contr then borc_arh-fin-ob-contr.income      else 0) + parsum-contr
    bfrc_arh-fin-ob-contr.income-vat       = (if available borc_arh-fin-ob-contr then borc_arh-fin-ob-contr.income-vat  else 0) + parsum-vat-contr
    bfrc_arh-fin-ob-contr.income-slt       = (if available borc_arh-fin-ob-contr then borc_arh-fin-ob-contr.income-slt  else 0) + parsum-slt-contr
    bfrc_arh-fin-ob-contr.expense          = (if available borc_arh-fin-ob-contr then borc_arh-fin-ob-contr.expense     else 0)
    bfrc_arh-fin-ob-contr.expense-vat      = (if available borc_arh-fin-ob-contr then borc_arh-fin-ob-contr.expense-vat else 0)
    bfrc_arh-fin-ob-contr.expense-slt      = (if available borc_arh-fin-ob-contr then borc_arh-fin-ob-contr.expense-slt else 0)
  .
end.
end.
end procedure.
procedure libofarh_calc-arh-fin-ob-contr-obj :
define input parameter parhost-code           like ub.fin-ob.host-code        no-undo.
define input parameter parobj-type            like ub.fin-ob.obj-type         no-undo.
define input parameter parobj-code            like ub.fin-ob.obj-code         no-undo.
define input parameter parpayer-type          like ub.fin-ob.payer-type       no-undo.
define input parameter parpayer-code          like ub.fin-ob.payer-code       no-undo.
define input parameter parreceiver-type       like ub.fin-ob.receiver-type    no-undo.
define input parameter parreceiver-code       like ub.fin-ob.receiver-code    no-undo.
define input parameter pardoc-type            like ub.fin-ob.doc-type         no-undo.
define input parameter parsum-type            as   character                  no-undo.
define input parameter parfact-order          like ub.fin-ob.fact-order       no-undo.
define input parameter pardoc-code            like ub.fin-ob.doc-code         no-undo.
define input parameter parfact-date           like ub.fin-ob.fact-date        no-undo.
define input parameter parbase-code           like ub.sysconf.base-code       no-undo.
define input parameter parcurr-dog-code       like ub.contract.curr-code      no-undo.
define input parameter parrel-dog-code        as   logical                    no-undo.
define input parameter parcontract-code       like ub.contract.contract-code  no-undo.
define input parameter parsum-doc             as   decimal                    no-undo.
define input parameter parsum-rubl            as   decimal                    no-undo.
define input parameter parsum-base            as   decimal                    no-undo.
define input parameter parsum-contr           as   decimal                    no-undo.
define input parameter parsum-vat-doc         as   decimal                    no-undo.
define input parameter parsum-vat-rubl        as   decimal                    no-undo.
define input parameter parsum-vat-base        as   decimal                    no-undo.
define input parameter parsum-vat-contr       as   decimal                    no-undo.
define input parameter parsum-slt-doc         as   decimal                    no-undo.
define input parameter parsum-slt-rubl        as   decimal                    no-undo.
define input parameter parsum-slt-base        as   decimal                    no-undo.
define input parameter parsum-slt-contr       as   decimal                    no-undo.
define buffer bfps_arh-fin-ob-contr-obj for ub.arh-fin-ob-contr-obj.
define buffer bops_arh-fin-ob-contr-obj for ub.arh-fin-ob-contr-obj.
define buffer bfpr_arh-fin-ob-contr-obj for ub.arh-fin-ob-contr-obj.
define buffer bopr_arh-fin-ob-contr-obj for ub.arh-fin-ob-contr-obj.
define buffer bfpb_arh-fin-ob-contr-obj for ub.arh-fin-ob-contr-obj.
define buffer bopb_arh-fin-ob-contr-obj for ub.arh-fin-ob-contr-obj.
define buffer bfpc_arh-fin-ob-contr-obj for ub.arh-fin-ob-contr-obj.
define buffer bopc_arh-fin-ob-contr-obj for ub.arh-fin-ob-contr-obj.
define buffer bfrs_arh-fin-ob-contr-obj for ub.arh-fin-ob-contr-obj.
define buffer bors_arh-fin-ob-contr-obj for ub.arh-fin-ob-contr-obj.
define buffer bfrr_arh-fin-ob-contr-obj for ub.arh-fin-ob-contr-obj.
define buffer borr_arh-fin-ob-contr-obj for ub.arh-fin-ob-contr-obj.
define buffer bfrb_arh-fin-ob-contr-obj for ub.arh-fin-ob-contr-obj.
define buffer borb_arh-fin-ob-contr-obj for ub.arh-fin-ob-contr-obj.
define buffer bfrc_arh-fin-ob-contr-obj for ub.arh-fin-ob-contr-obj.
define buffer borc_arh-fin-ob-contr-obj for ub.arh-fin-ob-contr-obj.
do on error undo, return error substitute ("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
find last bopr_arh-fin-ob-contr-obj where bopr_arh-fin-ob-contr-obj.host-code        = parhost-code     and
                                          bopr_arh-fin-ob-contr-obj.obj-type         = parobj-type      and
                                          bopr_arh-fin-ob-contr-obj.obj-code         = parobj-code      and
                                          bopr_arh-fin-ob-contr-obj.cli-type         = parpayer-type    and
                                          bopr_arh-fin-ob-contr-obj.cli-code         = parpayer-code    and
                                          bopr_arh-fin-ob-contr-obj.contract-code    = parcontract-code and
                                          bopr_arh-fin-ob-contr-obj.fin-ext-doc-type = pardoc-type      and
                                          bopr_arh-fin-ob-contr-obj.calc-curr-code   = 0                and
                                          bopr_arh-fin-ob-contr-obj.sum-type         = parsum-type    and
                                          bopr_arh-fin-ob-contr-obj.fact-order       = parfact-order
                                          no-error.
find first bfpr_arh-fin-ob-contr-obj   exclusive-lock where
  bfpr_arh-fin-ob-contr-obj.host-code        = parhost-code     and
  bfpr_arh-fin-ob-contr-obj.obj-type         = parobj-type      and
  bfpr_arh-fin-ob-contr-obj.obj-code         = parobj-code      and
  bfpr_arh-fin-ob-contr-obj.cli-type         = parpayer-type    and
  bfpr_arh-fin-ob-contr-obj.cli-code         = parpayer-code    and
  bfpr_arh-fin-ob-contr-obj.contract-code    = parcontract-code and
  bfpr_arh-fin-ob-contr-obj.fin-ext-doc-type = pardoc-type      and
  bfpr_arh-fin-ob-contr-obj.calc-curr-code   = 0                and
  bfpr_arh-fin-ob-contr-obj.sum-type         = parsum-type      and
  bfpr_arh-fin-ob-contr-obj.fact-order       = parfact-order     and
  bfpr_arh-fin-ob-contr-obj.fact-date        = parfact-date
no-error .
if not available bfpr_arh-fin-ob-contr-obj then create bfpr_arh-fin-ob-contr-obj.
assign
  bfpr_arh-fin-ob-contr-obj.host-code        = parhost-code
  bfpr_arh-fin-ob-contr-obj.obj-type         = parobj-type
  bfpr_arh-fin-ob-contr-obj.obj-code         = parobj-code
  bfpr_arh-fin-ob-contr-obj.cli-type         = parpayer-type
  bfpr_arh-fin-ob-contr-obj.cli-code         = parpayer-code
  bfpr_arh-fin-ob-contr-obj.contract-code    = parcontract-code
  bfpr_arh-fin-ob-contr-obj.fin-ext-doc-type = pardoc-type
  bfpr_arh-fin-ob-contr-obj.calc-curr-code   = 0
  bfpr_arh-fin-ob-contr-obj.sum-type         = parsum-type
  bfpr_arh-fin-ob-contr-obj.cource-des       = "r":u
  bfpr_arh-fin-ob-contr-obj.fact-order       = parfact-order
  bfpr_arh-fin-ob-contr-obj.fin-ob-doc-code  = pardoc-code
  bfpr_arh-fin-ob-contr-obj.fact-date        = parfact-date
  bfpr_arh-fin-ob-contr-obj.income           = (if available bopr_arh-fin-ob-contr-obj then bopr_arh-fin-ob-contr-obj.income      else 0)
  bfpr_arh-fin-ob-contr-obj.income-vat       = (if available bopr_arh-fin-ob-contr-obj then bopr_arh-fin-ob-contr-obj.income-vat  else 0)
  bfpr_arh-fin-ob-contr-obj.income-slt       = (if available bopr_arh-fin-ob-contr-obj then bopr_arh-fin-ob-contr-obj.income-slt  else 0)
  bfpr_arh-fin-ob-contr-obj.expense          = (if available bopr_arh-fin-ob-contr-obj then bopr_arh-fin-ob-contr-obj.expense     else 0) + parsum-rubl
  bfpr_arh-fin-ob-contr-obj.expense-vat      = (if available bopr_arh-fin-ob-contr-obj then bopr_arh-fin-ob-contr-obj.expense-vat else 0) + parsum-vat-rubl
  bfpr_arh-fin-ob-contr-obj.expense-slt      = (if available bopr_arh-fin-ob-contr-obj then bopr_arh-fin-ob-contr-obj.expense-slt else 0) + parsum-slt-rubl
.
if parbase-code <> 0 then do:
  find last bopb_arh-fin-ob-contr-obj where bopb_arh-fin-ob-contr-obj.host-code        = parhost-code     and
                                            bopb_arh-fin-ob-contr-obj.obj-type         = parobj-type      and
                                            bopb_arh-fin-ob-contr-obj.obj-code         = parobj-code      and
                                            bopb_arh-fin-ob-contr-obj.cli-type         = parpayer-type    and
                                            bopb_arh-fin-ob-contr-obj.cli-code         = parpayer-code    and
                                            bopb_arh-fin-ob-contr-obj.contract-code    = parcontract-code and
                                            bopb_arh-fin-ob-contr-obj.fin-ext-doc-type = pardoc-type      and
                                            bopb_arh-fin-ob-contr-obj.calc-curr-code   = parbase-code     and
                                            bopb_arh-fin-ob-contr-obj.sum-type         = parsum-type      and
                                            bopb_arh-fin-ob-contr-obj.fact-order       = parfact-order
                                            no-error.
find first bfpb_arh-fin-ob-contr-obj exclusive-lock where
    bfpb_arh-fin-ob-contr-obj.host-code        = parhost-code   and
    bfpb_arh-fin-ob-contr-obj.obj-type         = parobj-type    and
    bfpb_arh-fin-ob-contr-obj.obj-code         = parobj-code    and
    bfpb_arh-fin-ob-contr-obj.cli-type         = parpayer-type  and
    bfpb_arh-fin-ob-contr-obj.cli-code         = parpayer-code   and
    bfpb_arh-fin-ob-contr-obj.contract-code    = parcontract-code  and
    bfpb_arh-fin-ob-contr-obj.fin-ext-doc-type = pardoc-type      and
    bfpb_arh-fin-ob-contr-obj.calc-curr-code   = parbase-code   and
    bfpb_arh-fin-ob-contr-obj.sum-type         = parsum-type    and
    bfpb_arh-fin-ob-contr-obj.fact-order       = parfact-order  and
    bfpb_arh-fin-ob-contr-obj.fact-date        = parfact-date
no-error .
if not available bfpb_arh-fin-ob-contr-obj then   create bfpb_arh-fin-ob-contr-obj.
  assign
    bfpb_arh-fin-ob-contr-obj.host-code        = parhost-code
    bfpb_arh-fin-ob-contr-obj.obj-type         = parobj-type
    bfpb_arh-fin-ob-contr-obj.obj-code         = parobj-code
    bfpb_arh-fin-ob-contr-obj.cli-type         = parpayer-type
    bfpb_arh-fin-ob-contr-obj.cli-code         = parpayer-code
    bfpb_arh-fin-ob-contr-obj.contract-code    = parcontract-code
    bfpb_arh-fin-ob-contr-obj.fin-ext-doc-type = pardoc-type
    bfpb_arh-fin-ob-contr-obj.calc-curr-code   = parbase-code
    bfpb_arh-fin-ob-contr-obj.sum-type         = parsum-type
    bfpb_arh-fin-ob-contr-obj.cource-des       = "b":u
    bfpb_arh-fin-ob-contr-obj.fact-order       = parfact-order
    bfpb_arh-fin-ob-contr-obj.fin-ob-doc-code  = pardoc-code
    bfpb_arh-fin-ob-contr-obj.fact-date        = parfact-date
    bfpb_arh-fin-ob-contr-obj.income           = (if available bopb_arh-fin-ob-contr-obj then bopb_arh-fin-ob-contr-obj.income      else 0)
    bfpb_arh-fin-ob-contr-obj.income-vat       = (if available bopb_arh-fin-ob-contr-obj then bopb_arh-fin-ob-contr-obj.income-vat  else 0)
    bfpb_arh-fin-ob-contr-obj.income-slt       = (if available bopb_arh-fin-ob-contr-obj then bopb_arh-fin-ob-contr-obj.income-slt  else 0)
    bfpb_arh-fin-ob-contr-obj.expense          = (if available bopb_arh-fin-ob-contr-obj then bopb_arh-fin-ob-contr-obj.expense     else 0) + parsum-base
    bfpb_arh-fin-ob-contr-obj.expense-vat      = (if available bopb_arh-fin-ob-contr-obj then bopb_arh-fin-ob-contr-obj.expense-vat else 0) + parsum-vat-base
    bfpb_arh-fin-ob-contr-obj.expense-slt      = (if available bopb_arh-fin-ob-contr-obj then bopb_arh-fin-ob-contr-obj.expense-slt else 0) + parsum-slt-base
  .
end.
if parrel-dog-code  =  yes          and
   parcurr-dog-code <> 0            and
   parcurr-dog-code <> parbase-code then do:
  find last bopc_arh-fin-ob-contr-obj where bopc_arh-fin-ob-contr-obj.host-code        = parhost-code     and
                                            bopc_arh-fin-ob-contr-obj.obj-type         = parobj-type      and
                                            bopc_arh-fin-ob-contr-obj.obj-code         = parobj-code      and
                                            bopc_arh-fin-ob-contr-obj.cli-type         = parpayer-type    and
                                            bopc_arh-fin-ob-contr-obj.cli-code         = parpayer-code    and
                                            bopc_arh-fin-ob-contr-obj.contract-code    = parcontract-code and
                                            bopc_arh-fin-ob-contr-obj.fin-ext-doc-type = pardoc-type      and
                                            bopc_arh-fin-ob-contr-obj.calc-curr-code   = parcurr-dog-code and
                                            bopc_arh-fin-ob-contr-obj.sum-type         = parsum-type      and
                                            bopc_arh-fin-ob-contr-obj.fact-order       = parfact-order
                                            no-error.
  find first bfpc_arh-fin-ob-contr-obj exclusive-lock where
    bfpc_arh-fin-ob-contr-obj.host-code        = parhost-code       and
    bfpc_arh-fin-ob-contr-obj.obj-type         = parobj-type        and
    bfpc_arh-fin-ob-contr-obj.obj-code         = parobj-code        and
    bfpc_arh-fin-ob-contr-obj.cli-type         = parpayer-type      and
    bfpc_arh-fin-ob-contr-obj.cli-code         = parpayer-code      and
    bfpc_arh-fin-ob-contr-obj.contract-code    = parcontract-code   and
    bfpc_arh-fin-ob-contr-obj.fin-ext-doc-type = pardoc-type        and
    bfpc_arh-fin-ob-contr-obj.calc-curr-code   = parcurr-dog-code   and
    bfpc_arh-fin-ob-contr-obj.sum-type         = parsum-type        and
    bfpc_arh-fin-ob-contr-obj.fact-order       = parfact-order      and
    bfpc_arh-fin-ob-contr-obj.fact-date        = parfact-date
  no-error .
  if not available bfpc_arh-fin-ob-contr-obj then create bfpc_arh-fin-ob-contr-obj.
  assign
    bfpc_arh-fin-ob-contr-obj.host-code        = parhost-code
    bfpc_arh-fin-ob-contr-obj.obj-type         = parobj-type
    bfpc_arh-fin-ob-contr-obj.obj-code         = parobj-code
    bfpc_arh-fin-ob-contr-obj.cli-type         = parpayer-type
    bfpc_arh-fin-ob-contr-obj.cli-code         = parpayer-code
    bfpc_arh-fin-ob-contr-obj.contract-code    = parcontract-code
    bfpc_arh-fin-ob-contr-obj.fin-ext-doc-type = pardoc-type
    bfpc_arh-fin-ob-contr-obj.calc-curr-code   = parcurr-dog-code
    bfpc_arh-fin-ob-contr-obj.sum-type         = parsum-type
    bfpc_arh-fin-ob-contr-obj.cource-des       = "c":u
    bfpc_arh-fin-ob-contr-obj.fact-order       = parfact-order
    bfpc_arh-fin-ob-contr-obj.fin-ob-doc-code  = pardoc-code
    bfpc_arh-fin-ob-contr-obj.fact-date        = parfact-date
    bfpc_arh-fin-ob-contr-obj.income           = (if available bopc_arh-fin-ob-contr-obj then bopc_arh-fin-ob-contr-obj.income      else 0)
    bfpc_arh-fin-ob-contr-obj.income-vat       = (if available bopc_arh-fin-ob-contr-obj then bopc_arh-fin-ob-contr-obj.income-vat  else 0)
    bfpc_arh-fin-ob-contr-obj.income-slt       = (if available bopc_arh-fin-ob-contr-obj then bopc_arh-fin-ob-contr-obj.income-slt  else 0)
    bfpc_arh-fin-ob-contr-obj.expense          = (if available bopc_arh-fin-ob-contr-obj then bopc_arh-fin-ob-contr-obj.expense     else 0) + parsum-contr
    bfpc_arh-fin-ob-contr-obj.expense-vat      = (if available bopc_arh-fin-ob-contr-obj then bopc_arh-fin-ob-contr-obj.expense-vat else 0) + parsum-vat-contr
    bfpc_arh-fin-ob-contr-obj.expense-slt      = (if available bopc_arh-fin-ob-contr-obj then bopc_arh-fin-ob-contr-obj.expense-slt else 0) + parsum-slt-contr
  .
end.
find last borr_arh-fin-ob-contr-obj where borr_arh-fin-ob-contr-obj.host-code        = parhost-code     and
                                          borr_arh-fin-ob-contr-obj.obj-type         = parobj-type      and
                                          borr_arh-fin-ob-contr-obj.obj-code         = parobj-code      and
                                          borr_arh-fin-ob-contr-obj.cli-type         = parreceiver-type and
                                          borr_arh-fin-ob-contr-obj.cli-code         = parreceiver-code and
                                          borr_arh-fin-ob-contr-obj.contract-code    = parcontract-code and
                                          borr_arh-fin-ob-contr-obj.fin-ext-doc-type = pardoc-type      and
                                          borr_arh-fin-ob-contr-obj.calc-curr-code   = 0                and
                                          borr_arh-fin-ob-contr-obj.sum-type         = parsum-type      and
                                          borr_arh-fin-ob-contr-obj.fact-order       = parfact-order
                                          no-error.
find first bfrr_arh-fin-ob-contr-obj exclusive-lock where
  bfrr_arh-fin-ob-contr-obj.host-code        = parhost-code  and
  bfrr_arh-fin-ob-contr-obj.obj-type         = parobj-type   and
  bfrr_arh-fin-ob-contr-obj.obj-code         = parobj-code      and
  bfrr_arh-fin-ob-contr-obj.cli-type         = parreceiver-type and
  bfrr_arh-fin-ob-contr-obj.cli-code         = parreceiver-code  and
  bfrr_arh-fin-ob-contr-obj.contract-code    = parcontract-code  and
  bfrr_arh-fin-ob-contr-obj.fin-ext-doc-type = pardoc-type       and
  bfrr_arh-fin-ob-contr-obj.calc-curr-code   = 0                 and
  bfrr_arh-fin-ob-contr-obj.sum-type         = parsum-type       and
  bfrr_arh-fin-ob-contr-obj.fact-order       = parfact-order     and
  bfrr_arh-fin-ob-contr-obj.fact-date        = parfact-date
no-error .
if not available bfrr_arh-fin-ob-contr-obj then create bfrr_arh-fin-ob-contr-obj.
assign
  bfrr_arh-fin-ob-contr-obj.host-code        = parhost-code
  bfrr_arh-fin-ob-contr-obj.obj-type         = parobj-type
  bfrr_arh-fin-ob-contr-obj.obj-code         = parobj-code
  bfrr_arh-fin-ob-contr-obj.cli-type         = parreceiver-type
  bfrr_arh-fin-ob-contr-obj.cli-code         = parreceiver-code
  bfrr_arh-fin-ob-contr-obj.contract-code    = parcontract-code
  bfrr_arh-fin-ob-contr-obj.fin-ext-doc-type = pardoc-type
  bfrr_arh-fin-ob-contr-obj.calc-curr-code   = 0
  bfrr_arh-fin-ob-contr-obj.sum-type         = parsum-type
  bfrr_arh-fin-ob-contr-obj.cource-des       = "r":u
  bfrr_arh-fin-ob-contr-obj.fact-order       = parfact-order
  bfrr_arh-fin-ob-contr-obj.fin-ob-doc-code  = pardoc-code
  bfrr_arh-fin-ob-contr-obj.fact-date        = parfact-date
  bfrr_arh-fin-ob-contr-obj.income           = (if available borr_arh-fin-ob-contr-obj then borr_arh-fin-ob-contr-obj.income      else 0) + parsum-rubl
  bfrr_arh-fin-ob-contr-obj.income-vat       = (if available borr_arh-fin-ob-contr-obj then borr_arh-fin-ob-contr-obj.income-vat  else 0) + parsum-vat-rubl
  bfrr_arh-fin-ob-contr-obj.income-slt       = (if available borr_arh-fin-ob-contr-obj then borr_arh-fin-ob-contr-obj.income-slt  else 0) + parsum-slt-rubl
  bfrr_arh-fin-ob-contr-obj.expense          = (if available borr_arh-fin-ob-contr-obj then borr_arh-fin-ob-contr-obj.expense     else 0)
  bfrr_arh-fin-ob-contr-obj.expense-vat      = (if available borr_arh-fin-ob-contr-obj then borr_arh-fin-ob-contr-obj.expense-vat else 0)
  bfrr_arh-fin-ob-contr-obj.expense-slt      = (if available borr_arh-fin-ob-contr-obj then borr_arh-fin-ob-contr-obj.expense-slt else 0)
.
if parbase-code <> 0 then do:
  find last borb_arh-fin-ob-contr-obj where borb_arh-fin-ob-contr-obj.host-code        = parhost-code     and
                                            borb_arh-fin-ob-contr-obj.obj-type         = parobj-type      and
                                            borb_arh-fin-ob-contr-obj.obj-code         = parobj-code      and
                                            borb_arh-fin-ob-contr-obj.cli-type         = parreceiver-type and
                                            borb_arh-fin-ob-contr-obj.cli-code         = parreceiver-code and
                                            borb_arh-fin-ob-contr-obj.contract-code    = parcontract-code and
                                            borb_arh-fin-ob-contr-obj.fin-ext-doc-type = pardoc-type      and
                                            borb_arh-fin-ob-contr-obj.calc-curr-code   = parbase-code     and
                                            borb_arh-fin-ob-contr-obj.sum-type         = parsum-type      and
                                            borb_arh-fin-ob-contr-obj.fact-order       = parfact-order
                                            no-error.
find first bfrb_arh-fin-ob-contr-obj exclusive-lock where
    bfrb_arh-fin-ob-contr-obj.host-code        = parhost-code     and
    bfrb_arh-fin-ob-contr-obj.obj-type         = parobj-type      and
    bfrb_arh-fin-ob-contr-obj.obj-code         = parobj-code      and
    bfrb_arh-fin-ob-contr-obj.cli-type         = parreceiver-type and
    bfrb_arh-fin-ob-contr-obj.cli-code         = parreceiver-code and
    bfrb_arh-fin-ob-contr-obj.contract-code    = parcontract-code and
    bfrb_arh-fin-ob-contr-obj.fin-ext-doc-type = pardoc-type      and
    bfrb_arh-fin-ob-contr-obj.calc-curr-code   = parbase-code     and
    bfrb_arh-fin-ob-contr-obj.sum-type         = parsum-type      and
    bfrb_arh-fin-ob-contr-obj.fact-order       = parfact-order    and
    bfrb_arh-fin-ob-contr-obj.fact-date        = parfact-date
no-error .
if not available bfrb_arh-fin-ob-contr-obj then  create bfrb_arh-fin-ob-contr-obj.
  assign
    bfrb_arh-fin-ob-contr-obj.host-code        = parhost-code
    bfrb_arh-fin-ob-contr-obj.obj-type         = parobj-type
    bfrb_arh-fin-ob-contr-obj.obj-code         = parobj-code
    bfrb_arh-fin-ob-contr-obj.cli-type         = parreceiver-type
    bfrb_arh-fin-ob-contr-obj.cli-code         = parreceiver-code
    bfrb_arh-fin-ob-contr-obj.contract-code    = parcontract-code
    bfrb_arh-fin-ob-contr-obj.fin-ext-doc-type = pardoc-type
    bfrb_arh-fin-ob-contr-obj.calc-curr-code   = parbase-code
    bfrb_arh-fin-ob-contr-obj.sum-type         = parsum-type
    bfrb_arh-fin-ob-contr-obj.cource-des       = "b":u
    bfrb_arh-fin-ob-contr-obj.fact-order       = parfact-order
    bfrb_arh-fin-ob-contr-obj.fin-ob-doc-code  = pardoc-code
    bfrb_arh-fin-ob-contr-obj.fact-date        = parfact-date
    bfrb_arh-fin-ob-contr-obj.income           = (if available borb_arh-fin-ob-contr-obj then borb_arh-fin-ob-contr-obj.income      else 0) + parsum-base
    bfrb_arh-fin-ob-contr-obj.income-vat       = (if available borb_arh-fin-ob-contr-obj then borb_arh-fin-ob-contr-obj.income-vat  else 0) + parsum-vat-base
    bfrb_arh-fin-ob-contr-obj.income-slt       = (if available borb_arh-fin-ob-contr-obj then borb_arh-fin-ob-contr-obj.income-slt  else 0) + parsum-slt-base
    bfrb_arh-fin-ob-contr-obj.expense          = (if available borb_arh-fin-ob-contr-obj then borb_arh-fin-ob-contr-obj.expense     else 0)
    bfrb_arh-fin-ob-contr-obj.expense-vat      = (if available borb_arh-fin-ob-contr-obj then borb_arh-fin-ob-contr-obj.expense-vat else 0)
    bfrb_arh-fin-ob-contr-obj.expense-slt      = (if available borb_arh-fin-ob-contr-obj then borb_arh-fin-ob-contr-obj.expense-slt else 0)
  .
end.
if parrel-dog-code  =  yes          and
   parcurr-dog-code <> 0            and
   parcurr-dog-code <> parbase-code then do:
  find last borc_arh-fin-ob-contr-obj where borc_arh-fin-ob-contr-obj.host-code        = parhost-code     and
                                            borc_arh-fin-ob-contr-obj.obj-type         = parobj-type      and
                                            borc_arh-fin-ob-contr-obj.obj-code         = parobj-code      and
                                            borc_arh-fin-ob-contr-obj.cli-type         = parreceiver-type and
                                            borc_arh-fin-ob-contr-obj.cli-code         = parreceiver-code and
                                            borc_arh-fin-ob-contr-obj.contract-code    = parcontract-code and
                                            borc_arh-fin-ob-contr-obj.fin-ext-doc-type = pardoc-type      and
                                            borc_arh-fin-ob-contr-obj.calc-curr-code   = parcurr-dog-code and
                                            borc_arh-fin-ob-contr-obj.sum-type         = parsum-type      and
                                            borc_arh-fin-ob-contr-obj.fact-order       = parfact-order
                                            no-error.
  find first bfrc_arh-fin-ob-contr-obj exclusive-lock where
    bfrc_arh-fin-ob-contr-obj.host-code        = parhost-code   and
    bfrc_arh-fin-ob-contr-obj.obj-type         = parobj-type    and
    bfrc_arh-fin-ob-contr-obj.obj-code         = parobj-code    and
    bfrc_arh-fin-ob-contr-obj.cli-type         = parreceiver-type and
    bfrc_arh-fin-ob-contr-obj.cli-code         = parreceiver-code and
    bfrc_arh-fin-ob-contr-obj.contract-code    = parcontract-code and
    bfrc_arh-fin-ob-contr-obj.fin-ext-doc-type = pardoc-type      and
    bfrc_arh-fin-ob-contr-obj.calc-curr-code   = parcurr-dog-code and
    bfrc_arh-fin-ob-contr-obj.sum-type         = parsum-type      and
    bfrc_arh-fin-ob-contr-obj.fact-order       = parfact-order    and
    bfrc_arh-fin-ob-contr-obj.fact-date        = parfact-date
  no-error .
  if not available bfrc_arh-fin-ob-contr-obj then  create bfrc_arh-fin-ob-contr-obj.
  assign
    bfrc_arh-fin-ob-contr-obj.host-code        = parhost-code
    bfrc_arh-fin-ob-contr-obj.obj-type         = parobj-type
    bfrc_arh-fin-ob-contr-obj.obj-code         = parobj-code
    bfrc_arh-fin-ob-contr-obj.cli-type         = parreceiver-type
    bfrc_arh-fin-ob-contr-obj.cli-code         = parreceiver-code
    bfrc_arh-fin-ob-contr-obj.contract-code    = parcontract-code
    bfrc_arh-fin-ob-contr-obj.fin-ext-doc-type = pardoc-type
    bfrc_arh-fin-ob-contr-obj.calc-curr-code   = parcurr-dog-code
    bfrc_arh-fin-ob-contr-obj.sum-type         = parsum-type
    bfrc_arh-fin-ob-contr-obj.cource-des       = "c":u
    bfrc_arh-fin-ob-contr-obj.fact-order       = parfact-order
    bfrc_arh-fin-ob-contr-obj.fin-ob-doc-code  = pardoc-code
    bfrc_arh-fin-ob-contr-obj.fact-date        = parfact-date
    bfrc_arh-fin-ob-contr-obj.income           = (if available borc_arh-fin-ob-contr-obj then borc_arh-fin-ob-contr-obj.income      else 0) + parsum-contr
    bfrc_arh-fin-ob-contr-obj.income-vat       = (if available borc_arh-fin-ob-contr-obj then borc_arh-fin-ob-contr-obj.income-vat  else 0) + parsum-vat-contr
    bfrc_arh-fin-ob-contr-obj.income-slt       = (if available borc_arh-fin-ob-contr-obj then borc_arh-fin-ob-contr-obj.income-slt  else 0) + parsum-slt-contr
    bfrc_arh-fin-ob-contr-obj.expense          = (if available borc_arh-fin-ob-contr-obj then borc_arh-fin-ob-contr-obj.expense     else 0)
    bfrc_arh-fin-ob-contr-obj.expense-vat      = (if available borc_arh-fin-ob-contr-obj then borc_arh-fin-ob-contr-obj.expense-vat else 0)
    bfrc_arh-fin-ob-contr-obj.expense-slt      = (if available borc_arh-fin-ob-contr-obj then borc_arh-fin-ob-contr-obj.expense-slt else 0)
  .
end.
end.
end procedure.
procedure libofarh_fo-activ :
define input  parameter p-host-code as integer   no-undo .
define input  parameter p-doc-code as character no-undo .
define input  parameter p-db-num as integer     no-undo .
define output parameter p-ask as logical   no-undo .
define buffer buf_fin-ob for ub.fin-ob  .
define buffer buf_fin-gds-part for ub.fin-gds-part  .
define variable v-obj-type as character no-undo .
define variable v-obj-code as integer   no-undo .
define variable v-db-num-obj as integer   no-undo .
  do
  on error undo, return error return-value
  :
  p-ask = true .
  find first buf_fin-ob no-lock where
             buf_fin-ob.host-code = p-host-code and
             buf_fin-ob.doc-code  = p-doc-code no-error .
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
  v-obj-type = "".
  v-obj-code = 0.
  for each  buf_fin-gds-part no-lock where
            buf_fin-gds-part.fin-ob-code = buf_fin-ob.doc-code and
            buf_fin-gds-part.host-code   = buf_fin-ob.host-code :
      v-obj-type = buf_fin-gds-part.obj-type.
      v-obj-code = buf_fin-gds-part.obj-code.
      leave.
  end.
  if v-obj-type = "" and  v-obj-code = 0 then do :
     p-ask = true .
     return .
  end.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdbnum in g#library
  (input  v-obj-type
  ,input  v-obj-code
  ,output v-db-num-obj
  )  .
  if v-db-num-obj <> p-db-num then do:
     p-ask = false  .
     return .
  end.
  end.
end procedure.
procedure libofarh_doc-fogn :
define input  parameter p-type-doc as character no-undo .
define input  parameter p-type-fo  as character no-undo .
define input  parameter p-doc-code as character no-undo .
define input  parameter p-db-num as integer     no-undo .
define output parameter p-may-be as logical   no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date      as date   no-undo .
define variable v-value-decimal   as decimal   no-undo .
define variable v-fo-buyer-nws    as integer   no-undo .
define variable v-fo-supp-nws     as integer   no-undo .
define variable v-value-logical   as logical   no-undo .
define variable par-type          as character no-undo .
define variable v-activ-side as logical   no-undo .
define buffer buf_trn-doc     for ub.trn-doc  .
define buffer buf_c-trn-doc   for ub.c-trn-doc  .
define buffer buf_ord-doc     for ub.ord-doc  .
define buffer buf_ord-doc-rcv for ub.ord-doc-rcv  .
  do
  on error undo, return error return-value
  :
  p-may-be = false .
run adm/shattri.p (
  input "get":U
  ,input ""
  ,input 0
  ,input 'fin-global':U
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
            thbjattr_thbj-attr.prop-code = 'fo-buyer-nws':U and
            thbjattr_thbj-attr.upper-prop-code = 'fin-global':U  no-error .
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
            thbjattr_thbj-attr.prop-code = 'fo-supp-nws':U and
            thbjattr_thbj-attr.upper-prop-code = 'fin-global':U  no-error .
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
define variable v-obj-type as character no-undo .
define variable v-obj-code as integer   no-undo .
    case p-type-doc :
      when "trn" then do:
          find first buf_trn-doc no-lock where
                     buf_trn-doc.doc-code = p-doc-code  no-error .
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
          v-obj-type  = buf_trn-doc.obj-type .
          v-obj-code  = buf_trn-doc.obj-code .
      end.
      when "ord" then do:
          find first buf_ord-doc no-lock where
                     buf_ord-doc.doc-code = p-doc-code  no-error .
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
          v-obj-type  = buf_ord-doc.obj-type .
          v-obj-code  = buf_ord-doc.obj-code .
      end.
      when "rcv" then do:
          find first buf_ord-doc-rcv no-lock where
                     buf_ord-doc-rcv.rcv-code = p-doc-code  no-error .
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
          v-obj-type  = buf_ord-doc-rcv.obj-type .
          v-obj-code  = buf_ord-doc-rcv.obj-code .
      end.
      when "del" then do:
          find first buf_c-trn-doc no-lock where
                     buf_c-trn-doc.is-del = true and
                     buf_c-trn-doc.doc-code = p-doc-code  no-error .
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
          v-obj-type  = buf_c-trn-doc.obj-type .
          v-obj-code  = buf_c-trn-doc.obj-code .
      end.
      otherwise do:
        message "Ошибка типа документа " p-type-doc view-as alert-box error .
        return error return-value .
      end.
    end case.
    define variable v-db-num-obj as integer   no-undo .
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdbnum in g#library
  (input  v-obj-type
  ,input  v-obj-code
  ,output v-db-num-obj
  )  .
p-may-be = true  .
    case p-type-fo :
      when 'рас':U then do:
          if p-db-num <> 0 then do:
            p-may-be = false .
            return .
          end.
      end.
      when 'при':U then do:
        if v-fo-buyer-nws = 0  then do:
            if v-db-num-obj  <> p-db-num then do:
              p-may-be = false .
              return .
            end.
        end.
        else do:
            if p-db-num <> 0 then do:
              p-may-be = false .
              return .
            end.
        end.
      end.
      otherwise do:
        message "Ошибка типа ФО" p-type-fo view-as alert-box error .
        return error return-value .
      end.
    end case.
  end.
end procedure.
