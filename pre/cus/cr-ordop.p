block-level on error undo, throw.
define input  parameter  parParentProc   AS WIDGET-HANDLE NO-UNDO.
define input  parameter  par-ord-type    as character no-undo .
define input  parameter  par-cli-code    as integer   no-undo .
define input  parameter  par-cli-type    as character no-undo .
define input  parameter  par-date-post   as date   no-undo .
define input  parameter  par-date-1      as date   no-undo .
define input  parameter  par-date-2      as date   no-undo .
define input  parameter  p-recid         as character no-undo .
define output parameter  par-ord-doc-recid  as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: cr-ordop.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cus/cr-ordop.p $":U .
define variable vss-description as character no-undo init "создание заказа".
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
procedure create-ord-line :
define input parameter  p-doc-code       like ub.ord-doc.doc-code         no-undo .
define input parameter  p-line-num       like ub.ord-line.line-num        no-undo .
define input parameter  p-artic          like ub.ord-line.artic           no-undo .
define input parameter  p-prod-code      like ub.ord-line.prod-code       no-undo .
define input parameter  p-prod-type      like ub.ord-line.prod-type       no-undo .
define input parameter  p-cli-base-rate  like ub.ord-line.cli-base-rate   no-undo .
define input parameter  p-qnty           like ub.ord-line.qnty            no-undo .
define input parameter  p-unit-cli       like ub.ord-line.unit-cli        no-undo .
 do
 on error undo, return error return-value
 :
 define variable p-cli-qnty               like ub.ord-line.cli-qnty        no-undo .
 define buffer bbb_ord-doc for ub.ord-doc  .
 define buffer tt-goods for ub.goods       .
 find first bbb_ord-doc where bbb_ord-doc.doc-code = p-doc-code no-lock no-error .
 if error-status :error then do:
      message vss-workfile vss-revision vss-description skip
              error-status :get-message(1)
              view-as alert-box error .
              undo, return error.
 end.
 find first tt-goods where
      tt-goods.artic             =   p-artic          and
      tt-goods.prod-code         =   p-prod-code      and
      tt-goods.prod-type         =   p-prod-type      no-lock no-error .
 if error-status :error then do:
      message vss-workfile vss-revision vss-description skip
              error-status :get-message(1)
              view-as alert-box error .
              undo, return error.
 end.
find first ub.ord-line where ub.ord-line.artic     = tt-goods.artic     and
                          ub.ord-line.prod-type = tt-goods.prod-type and
                          ub.ord-line.prod-code = tt-goods.prod-code and
                          ub.ord-line.doc-code  = p-doc-code   exclusive-lock    no-error.
if not available ub.ord-line then do:
  create  ub.ord-line.
end.
      assign
        ub.ord-line.gds-code       = tt-goods.gds-code
        ub.ord-line.doc-code       = p-doc-code
        ub.ord-line.line-num       = p-line-num
        ub.ord-line.artic          = p-artic
        ub.ord-line.prod-code      = p-prod-code
        ub.ord-line.prod-type      = p-prod-type
        ub.ord-line.cli-base-rate  = p-cli-base-rate
        ub.ord-line.qnty           = p-qnty
        ub.ord-line.cli-qnty       = ub.ord-line.qnty  / ub.ord-line.cli-base-rate
        ub.ord-line.unit-cli       = p-unit-cli
    .
 if ub.ord-line.price-rubl = 0 or ub.ord-line.price-rubl = ? then
 run last-price in this-procedure (
      input  bbb_ord-doc.host-code ,
      input  ub.ord-line.artic ,
      input  ub.ord-line.prod-type ,
      input  ub.ord-line.prod-code ,
      input  bbb_ord-doc.cli-code  ,
      input  bbb_ord-doc.cli-type  ,
      input  ub.ord-line.cli-base-rate ,
      input  bbb_ord-doc.exch-code ,
      output ub.ord-line.price-base ,
      output ub.ord-line.price-rubl ,
      output ub.ord-line.price-cli   )
      no-error  .
      if error-status :error then
      message
        vss-workfile vss-revision vss-description skip
        error-status :get-message(1) skip
        return-value skip
        ""
        view-as alert-box error
      .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  tt-goods.gds-code
  ,input  '1':U
  ,input  ?
  ,input  bbb_ord-doc.host-code
  ,input  bbb_ord-doc.obj-type
  ,input  bbb_ord-doc.obj-code
  ,output ub.ord-line.vat-pc
  ) no-error .
  if error-status :error then
  message
    vss-workfile vss-revision vss-description skip
    error-status :get-message(1) skip
    return-value skip
    ""
    view-as alert-box error
  .
     ub.ord-line.sum-rubl = ub.ord-line.qnty * ub.ord-line.price-rubl .
     ub.ord-line.sum-base = ub.ord-line.qnty * ub.ord-line.price-base .
     ub.ord-line.sum-cli  = ub.ord-line.cli-qnty * ub.ord-line.price-cli .
 end.
end procedure.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure last-price :
do on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
define input parameter  p-host-code     as integer no-undo .
define input parameter  p-artic         like ub.doc-line.artic  no-undo .
define input parameter  p-prod-type     like ub.doc-line.prod-type  no-undo .
define input parameter  p-prod-code     like ub.doc-line.prod-code  no-undo .
define input parameter  p-cli-code      like ub.ord-doc.cli-code  no-undo .
define input parameter  p-cli-type      like ub.ord-doc.cli-type  no-undo .
define input parameter  p-cli-base-rate like ub.ord-line.cli-base-rate no-undo .
define input parameter  p-curr-code  as integer   no-undo .
define output parameter p-price-base like ub.doc-line.price-base no-undo .
define output parameter p-price-rubl like ub.doc-line.price-rubl no-undo .
define output parameter p-price-cli  like ub.doc-line.price-cli  no-undo .
define buffer buf-lib-doc-line for ub.doc-line.
define buffer buf_cli-gds for ub.cli-gds .
define buffer buf_trn-doc for ub.trn-doc  .
define variable vp-curr-code  like ub.trn-doc.exch-code.
define variable vp-exch-rate  like ub.trn-doc.exch-rate.
define variable vp-exch-scale like ub.trn-doc.exch-scale.
define variable v-last-in-code   like ub.doc-line.doc-code  no-undo .
define variable v-last-obj-type  like ub.clients.obj-type no-undo .
define variable v-last-obj-code  like ub.clients.obj-code no-undo .
define variable v-cli-base-rate as decimal   no-undo .
 find first buf_cli-gds no-lock where
            buf_cli-gds.cli-type   = p-cli-type    and
            buf_cli-gds.cli-code   = p-cli-code    and
            buf_cli-gds.host-code  = p-host-code   and
            buf_cli-gds.artic      = p-artic       and
            buf_cli-gds.prod-type  = p-prod-type   and
            buf_cli-gds.prod-code  = p-prod-code
            no-error .
if available buf_cli-gds then do:
    find first buf_trn-doc no-lock
         where buf_trn-doc.doc-code  = buf_cli-gds.in-code no-error .
     if available buf_trn-doc then do:
        vp-curr-code  = buf_trn-doc.exch-code.
        vp-exch-rate  = buf_trn-doc.exch-rate.
        vp-exch-scale = buf_trn-doc.exch-scale.
     end.
    find first buf-lib-doc-line no-lock
      where buf-lib-doc-line.doc-code  = buf_cli-gds.in-code
        and buf-lib-doc-line.artic     = p-artic
        and buf-lib-doc-line.prod-type = p-prod-type
        and buf-lib-doc-line.prod-code = p-prod-code
      no-error .
end.
else do:
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lastindc in g#library
  (input  p-host-code
  ,input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,output v-last-in-code
  ,output v-last-obj-type
  ,output v-last-obj-code
  )  .
    find first buf_trn-doc no-lock
         where buf_trn-doc.doc-code  = v-last-in-code no-error .
     if available buf_trn-doc then do:
        vp-curr-code  = buf_trn-doc.exch-code.
        vp-exch-rate  = buf_trn-doc.exch-rate.
        vp-exch-scale = buf_trn-doc.exch-scale.
     end.
    find first buf-lib-doc-line no-lock
      where buf-lib-doc-line.doc-code  = v-last-in-code
        and buf-lib-doc-line.artic     = p-artic
        and buf-lib-doc-line.prod-type = p-prod-type
        and buf-lib-doc-line.prod-code = p-prod-code
      no-error .
end.
    if available buf-lib-doc-line then do:
      assign
        v-cli-base-rate = buf-lib-doc-line.cli-base-rate
        p-price-base = buf-lib-doc-line.price-base
        p-price-rubl = buf-lib-doc-line.price-rubl
        p-price-cli  = (if vp-curr-code = 0 then buf-lib-doc-line.price-rubl else buf-lib-doc-line.price-base) * p-cli-base-rate
      .
      if v-cli-base-rate <> p-cli-base-rate
      then do:
          p-price-cli  = p-price-cli / v-cli-base-rate  .
      end.
       if p-curr-code <> vp-curr-code then do:
          p-price-cli  = p-price-rubl  .
      end.
    end.
    Else do:
      assign
        p-price-base = 0
        p-price-rubl = 0
        p-price-cli  = 0
      .
    end.
  end.
end procedure.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
    undo, return error substitute( "&1. &2&3&4", vss-include-info5, return-value, chr(10), error-status :get-message (1)).
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
    undo, return error substitute( "&1. &2&3&4", vss-include-info5, return-value, chr(10), error-status :get-message (1)).
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
define variable l-Ostatok-today  as decimal   no-undo .
define variable l-negative-rest  as logical   no-undo .
define variable l-qnty-day       as integer   no-undo .
define variable l-pay-day        as integer   no-undo .
define variable l-Temp-rash      as decimal   no-undo .
define variable l-null-day       as integer   no-undo init 0 .
define variable l-min-zap        as decimal   no-undo .
define variable l-order          as decimal   no-undo .
define variable l-a              as decimal   no-undo .
define variable l-b              as decimal   no-undo .
define variable l-negative-sale  as logical   no-undo .
define variable l-goods-way      as decimal   no-undo .
define variable l-min-order      as decimal   no-undo .
define variable l-tog-min-order  as logical   no-undo .
define variable loc-unit-base    as character no-undo .
define variable l-min-ost        as logical   no-undo .
define variable l-tog-deadline   as logical   no-undo .
define variable l-deadline       as integer   no-undo .
define variable l-type-MR        as character no-undo .
define variable par-ord-min-ost  as logical   no-undo .
define variable v-media-qnty     as decimal   no-undo .
define variable l-corr-coeff     as decimal   no-undo .
define stream stream_order .
define variable is-log             as logical   no-undo .
define variable p-val              as character no-undo .
define variable p-type             as character no-undo .
define variable v-value-character  as character no-undo .
define variable v-value-date       as date      no-undo .
define variable v-value-decimal    as decimal   no-undo .
define variable v-value-integer    as integer   no-undo .
define variable v-stroka-protocol  as character no-undo .
define variable v-protocol-date    as date      no-undo .
define variable v-protocol-time    as integer   no-undo .
run adm/shattri.p (
  input "get":U
  ,input ""
  ,input 0
  ,input 'ord-global':U
  ,input 'ord-log':U
  ,output v-value-character
  ,output v-value-date
  ,output v-value-decimal
  ,output v-value-integer
  ,output is-log
  ,output p-type
  ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
  ) no-error .
  if error-status :error then is-log = false .
run adm/shattri.p (
  input "get":U
  ,input ""
  ,input 0
  ,input 'ord-global':U
  ,input 'ord-min-ost-day':U
  ,output v-value-character
  ,output v-value-date
  ,output v-value-decimal
  ,output v-value-integer
  ,output par-ord-min-ost
  ,output p-type
  ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
  ) no-error .
  if error-status :error then par-ord-min-ost = false .
procedure recalc-cli-qnty :
  do
  on error undo, return error return-value
  :
define input  parameter p-gds-code      as integer   no-undo .
define input  parameter p-round-m       as character no-undo .
define input  parameter p-round-base    as decimal   no-undo .
define input  parameter p-unit-cli      as character no-undo .
define input  parameter p-cli-base-rate as decimal   no-undo .
define input  parameter p-price-cli     as decimal   no-undo .
define input  parameter p-price-rubl    as decimal   no-undo .
define input  parameter p-price-base    as decimal   no-undo .
define input-output parameter p-cli-qnty as decimal   no-undo .
define input-output parameter p-qnty     as decimal   no-undo .
define input-output parameter p-sum-cli  as decimal   no-undo .
define input-output parameter p-sum-rubl as decimal   no-undo .
define input-output parameter p-sum-base as decimal   no-undo .
define buffer buf_goods for ub.goods  .
define buffer buf_units for ub.units  .
define variable v-cli-qnty as decimal   no-undo .
find first buf_goods no-lock where
           buf_goods.gds-code = p-gds-code no-error .
v-cli-qnty = p-cli-qnty .
if can-find (
first buf_units where
      buf_units.unit-name = p-unit-cli and
      lookup ('шту':U, buf_units.type) > 0 ) and
  truncate ( p-cli-qnty, 0 ) <> p-cli-qnty then do:
  assign
    v-cli-qnty = trunc( p-cli-qnty, 0 ) .
end.
   case p-round-m :
          when 'Кол-во_в_коробке':U then do:
           if buf_goods.qnty-cart  <> 0 then do:
                if ( p-qnty  > 0 and p-qnty <  buf_goods.qnty-cart ) then p-qnty = buf_goods.qnty-cart .
                assign
                  p-qnty     = round ( p-qnty / buf_goods.qnty-cart, 0 ) *  buf_goods.qnty-cart
                  .
                  if ( p-qnty > 0 and p-qnty <  buf_goods.qnty-cart ) then p-qnty = buf_goods.qnty-cart .
                assign
                  p-cli-qnty = p-qnty / p-cli-base-rate
                  p-sum-cli  = p-price-cli  * p-cli-qnty
                  p-sum-rubl = p-price-rubl * p-qnty
                  p-sum-base = p-price-base * p-qnty
                .
             end.
             else do:
                assign
                  p-qnty     = v-cli-qnty   * p-cli-base-rate
                  p-sum-cli  = p-price-cli  * v-cli-qnty
                  p-sum-rubl = p-price-rubl * p-qnty
                  p-sum-base = p-price-base * p-qnty
                .
             end.
          end.
          when 'Без-дробных':U then do:
              if can-find(first buf_units where
                      buf_units.unit-name = p-unit-cli and
                      lookup ('шту':U, buf_units.type) > 0 ) and
                      trunc ( p-cli-qnty, 0 ) <> p-cli-qnty then do:
                      assign
                        p-cli-qnty = trunc( p-cli-qnty, 0 ) + 1
                        p-qnty     = p-cli-qnty   * p-cli-base-rate
                        p-sum-cli  = p-price-cli  * p-cli-qnty
                        p-sum-rubl = p-price-rubl * p-qnty
                        p-sum-base = p-price-base * p-qnty
                      .
              end.
              else do:
                      assign
                        p-cli-qnty = round( p-cli-qnty, 0 )
                        p-qnty     = p-cli-qnty   * p-cli-base-rate
                        p-sum-cli  = p-price-cli  * p-cli-qnty
                        p-sum-rubl = p-price-rubl * p-qnty
                        p-sum-base = p-price-base * p-qnty
                      .
              end.
          end.
          when 'Произвольно':U then do:
            if p-round-base <> 0 then do:
              assign
                p-cli-qnty = round ( p-cli-qnty / p-round-base , 0 ) * p-round-base
              .
            end.
            assign
                p-qnty     = p-cli-qnty   * p-cli-base-rate
                p-sum-cli  = p-price-cli  * p-cli-qnty
                p-sum-rubl = p-price-rubl * p-qnty
                p-sum-base = p-price-base * p-qnty
              .
          end.
          when 'Отключено':U or when ""  then do:
            assign
                p-cli-qnty = v-cli-qnty
                p-qnty     = p-cli-qnty   * p-cli-base-rate
                p-sum-cli  = p-price-cli  * p-cli-qnty
                p-sum-rubl = p-price-rubl * p-qnty
                p-sum-base = p-price-base * p-qnty
              .
          end.
   end case.
if is-log = true then  Output stream stream_order to value ("order_raschet.txt") APPEND .
if is-log = true then  put stream stream_order unformatted
        " После округления кол-во в баз.ед. изм. : " p-qnty  skip
        " Метод округления :  " p-round-m
          ( if p-round-m = 'Произвольно':U
              then  string(p-round-base)
              else  "" )
          ( if p-round-m = 'Кол-во_в_коробке':U
              then  string(buf_goods.qnty-cart)
              else  "" ) skip
        "__________________________________________________"     skip  .
if is-log = true then  OUTPUT  STREAM  stream_order CLOSE.
v-stroka-protocol = v-stroka-protocol + chr(4) +
                  "18.Метод округления : " +  p-round-m +
                    ( if p-round-m = 'Произвольно':U
                        then  string(p-round-base)
                        else  " " )  +
                    ( if p-round-m = 'Кол-во_в_коробке':U
                        then  string(buf_goods.qnty-cart)
                        else  "" ) + chr(4) +
                  "19.После округления кол-во в баз.ед. изм. : " + string( p-qnty)
                    .
  end.
end procedure.
procedure create-protocol :
define input  parameter p-ord-doc  as character no-undo .
define input  parameter p-gds-code as integer   no-undo .
define input  parameter p-date     as date     no-undo .
define input  parameter p-time     as integer   no-undo .
define input  parameter p-obj-type as character no-undo .
define input  parameter p-obj-code as integer   no-undo .
define input  parameter p-str      as character no-undo .
define buffer buf_ord-line-attr for ub.ord-line-attr  .
  do
  on error undo, return error return-value
  :
  if p-gds-code = ? or p-gds-code = 0 then return.
  if p-ord-doc = ? or p-ord-doc = ""   then return.
  if p-obj-type = ?  then return.
  if p-obj-code = ?  then return.
  if p-date = ?  then return.
    find first buf_ord-line-attr exclusive-lock where
              buf_ord-line-attr.doc-code = p-ord-doc  and
              buf_ord-line-attr.gds-code = p-gds-code and
              buf_ord-line-attr.attr-code =  "protocol"           + chr(4) +
                                              p-obj-type          + chr(4) +
                                              string(p-obj-code)  + chr(4) +
                                              string(p-date, "99-99-9999" )  + chr(4) +
                                              string(p-time,"hh:mm:ss"  )
                                              no-error .
    if not available buf_ord-line-attr then do:
       create buf_ord-line-attr no-error .
    end.
    if available buf_ord-line-attr then do:
    assign
      buf_ord-line-attr.doc-code  = p-ord-doc
      buf_ord-line-attr.gds-code  = p-gds-code
      buf_ord-line-attr.attr-code =  "protocol"           + chr(4) +
                                      p-obj-type          + chr(4) +
                                      string(p-obj-code)  + chr(4) +
                                      string(p-date, "99-99-9999" )  + chr(4) +
                                      string(p-time, "hh:mm:ss"  )
      buf_ord-line-attr.attr-value  = p-str
      no-error
    .
    end.
  end.
end procedure.
procedure create-obj-temp :
define input  parameter p-ord-doc as character no-undo .
define input  parameter p-gds-code as integer   no-undo .
define input  parameter p-obj-type as character no-undo .
define input  parameter p-obj-code as integer   no-undo .
define input  parameter p-qnty as decimal   no-undo .
define buffer buf_ord-line-attr for ub.ord-line-attr  .
  do
  on error undo, return error return-value
  :
  if p-gds-code = ? or p-gds-code = 0 then return.
  if p-ord-doc = ? or p-ord-doc = "" then return.
  if p-obj-type = ?  then return.
  if p-obj-code = ?  then return.
    find first buf_ord-line-attr exclusive-lock where
              buf_ord-line-attr.doc-code = p-ord-doc  and
              buf_ord-line-attr.gds-code = p-gds-code and
              buf_ord-line-attr.attr-code =  "objqnty"   + chr(4) +
                                              p-obj-type + chr(4) +
                                              string(p-obj-code)  no-error .
    if not available buf_ord-line-attr then do:
       create buf_ord-line-attr no-error .
    end.
    assign
      buf_ord-line-attr.doc-code  = p-ord-doc
      buf_ord-line-attr.gds-code  = p-gds-code
      buf_ord-line-attr.attr-code = "objqnty"  + chr(4) +
                                    p-obj-type + chr(4) +
                                    string(p-obj-code)
      buf_ord-line-attr.attr-value = string( p-qnty )
      no-error
    .
  end.
end procedure.
procedure create-min-stock-gds-way :
define input  parameter p-ord-doc   as character no-undo .
define input  parameter p-gds-code  as integer   no-undo .
define input  parameter p-min-stock as decimal   no-undo .
define input  parameter p-gds-way   as decimal   no-undo .
define buffer buf_ord-line-attr for ub.ord-line-attr  .
  do
  on error undo, return error return-value
  :
  if p-gds-code = ? or p-gds-code = 0 then return.
  if p-ord-doc  = ? or p-ord-doc = "" then return.
    find first buf_ord-line-attr exclusive-lock where
              buf_ord-line-attr.doc-code = p-ord-doc  and
              buf_ord-line-attr.gds-code = p-gds-code and
              buf_ord-line-attr.attr-code = 'min-stock':U
                                             no-error .
    if not available buf_ord-line-attr then do:
       create buf_ord-line-attr no-error .
    end.
    if available buf_ord-line-attr then do:
    assign
      buf_ord-line-attr.doc-code  = p-ord-doc
      buf_ord-line-attr.gds-code  = p-gds-code
      buf_ord-line-attr.attr-code = 'min-stock':U
      buf_ord-line-attr.attr-value = string (p-min-stock)
      no-error
    .
    end.
    find first buf_ord-line-attr exclusive-lock where
              buf_ord-line-attr.doc-code = p-ord-doc  and
              buf_ord-line-attr.gds-code = p-gds-code and
              buf_ord-line-attr.attr-code = 'gds-way':U
                                             no-error .
    if not available buf_ord-line-attr then do:
       create buf_ord-line-attr no-error .
    end.
    if available buf_ord-line-attr then do:
    assign
      buf_ord-line-attr.doc-code  = p-ord-doc
      buf_ord-line-attr.gds-code  = p-gds-code
      buf_ord-line-attr.attr-code = 'gds-way':U
      buf_ord-line-attr.attr-value = string (p-gds-way)
      no-error
    .
    end.
  end.
end procedure.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure proc-ord-code :
define input  parameter  p-type as character no-undo .
define input  parameter  v-cntxt-db-num   as integer   no-undo .
define input  parameter  v-cntxt-obj-type as character no-undo .
define input  parameter  v-cntxt-obj-code as integer   no-undo .
define input  parameter  p-i-doc    as character no-undo .
define output parameter  p-ord-doc  as character no-undo .
define variable          v-idop     as character no-undo .
  do
  on error undo, return error return-value
  :
case p-type :
    when "main-no-ver" then do:
      if  (v-cntxt-db-num <> 0) then
        p-ord-doc = trim (string (next-value (s-ord-doc, ub), ">>>>>>>>>9")) + "-" + trim (string (v-cntxt-obj-code, ">>>>9")) + substring (v-cntxt-obj-type, (if g#language = "RUS" then 1 else 2), 1).
      else
        p-ord-doc = trim (string (next-value (s-ord-doc, ub), ">>>>>>>>>9")) + "-".
    end.
    when "main" then do:
          do while true:
          if  (v-cntxt-db-num <> 0) then
            p-ord-doc = trim (string (next-value (s-ord-doc, ub), ">>>>>>>>>9")) + "-" + trim (string (v-cntxt-obj-code, ">>>>9")) + substring (v-cntxt-obj-type, (if g#language = "RUS" then 1 else 2), 1).
          else
            p-ord-doc = trim (string (next-value (s-ord-doc, ub), ">>>>>>>>>9")) + "-".
          if not can-find (ub.ord-doc where ub.ord-doc.doc-code = p-ord-doc no-lock) then leave.
          End.
    end.
    when "chip" then do:
      assign
        v-idop = p-i-doc .
      do while true :
        if index (v-idop , ".") = 0 then
          v-idop  = replace (v-idop , "-", "-1.").
        else
          v-idop  =
          substring (v-idop , 1, index (v-idop, "-")) +
          string (integer (substring (v-idop, index (v-idop, "-") + 1, index (v-idop, ".") - index (v-idop, "-") - 1)) + 1) +
          substring (v-idop, index (v-idop, ".")).
        if not can-find (ub.ord-doc where ub.ord-doc.doc-code = v-idop no-lock) then leave.
      end.
      assign
        p-ord-doc = v-idop.
    end.
end case.
  end.
end procedure.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define buffer buf_clients              for ub.clients.
define buffer buf_currency             for ub.currency.
define buffer buf_curr-accnt           for ub.curr-accnt .
define buffer buf_abc-analysis-obj     for ub.abc-analysis-obj.
define buffer buf_abc-analysis-goods   for ub.abc-analysis-goods.
define buffer buf_analysis-gds-obj     for ub.abc-analysis-gds-obj.
define buffer buf_abc-analysis-gds-obj for ub.abc-analysis-gds-obj.
define buffer buf_analysis-goods       for ub.abc-analysis-goods.
define buffer buf_goods                for ub.goods.
define variable var-ok-assort-pol   as logical   no-undo .
define variable var-mess-assort-pol as character no-undo .
define variable par-ord-doc-code    as character no-undo .
define variable v-host-code as integer    no-undo .
define variable v-obj-code  as integer    no-undo .
define variable v-obj-type  as character  no-undo .
define variable store-code  as integer    no-undo .
define variable store-type  as character  no-undo .
define variable ship-day    as integer    no-undo .
define variable pay-day     as integer    no-undo .
define variable all-day     as integer    no-undo .
define variable v-e-method as character no-undo .
define buffer tmp#zakaz  for ub.goods.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
assign
  v-host-code = v-cntxt-host-code-obj
  v-obj-type  = v-cntxt-obj-type
  v-obj-code  = v-cntxt-obj-code
  store-code  = v-obj-code
  store-type  = v-obj-type
  v-e-method = "Методы расчета темпа продаж : Базовый способ;"
  .
find first buf_clients no-lock where
           buf_clients.obj-code = par-cli-code and
           buf_clients.obj-type = par-cli-type
           no-error .
if not available buf_clients then return error .
define variable v-kol-rec as integer no-undo .
define variable v-i       as integer no-undo .
define variable v-qnty    as decimal no-undo .
v-kol-rec = num-entries (p-recid) .
   find first buf_abc-analysis-goods no-lock where
              recid(buf_abc-analysis-goods) = int(entry(1 , p-recid))
              no-error .
    if not available buf_abc-analysis-goods then return error .
define variable v-abc-id     as integer   no-undo .
define variable v-abc-db-num as integer   no-undo .
define variable v-doc-db-num as integer   no-undo .
v-abc-id      = buf_abc-analysis-goods.abc-id.
v-abc-db-num  = buf_abc-analysis-goods.db-num.
if par-ord-type = 'ОП':U then do:
    for each buf_abc-analysis-obj no-lock where
             buf_abc-analysis-obj.abc-id =      v-abc-id     and
             buf_abc-analysis-obj.db-num =  v-abc-db-num :
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  buf_abc-analysis-obj.obj-type
  ,input  buf_abc-analysis-obj.obj-code
  ,output v-host-code
  )  .
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdbnum in g#library
  (input  buf_abc-analysis-obj.obj-type
  ,input  buf_abc-analysis-obj.obj-code
  ,output v-doc-db-num
  )  .
      if v-doc-db-num = v-cntxt-db-num then do:
        run create-ord (
            v-host-code ,
            buf_abc-analysis-obj.obj-code ,
            buf_abc-analysis-obj.obj-type ).
      end.
    end.
end.
if par-ord-type = 'ФП':U then do:
   run create-ord (
        v-host-code ,
        store-code  ,
        store-type  ) .
end.
par-ord-doc-recid = trim (par-ord-doc-recid , "," ) .
procedure create-ord :
  do
  on error undo, return error return-value
  :
define input  parameter p-host-code as integer   no-undo .
define input  parameter p-obj-code  as integer   no-undo .
define input  parameter p-obj-type  as character no-undo .
define variable to-day       as date      no-undo .
define variable v-base-code  as integer   no-undo .
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curobjdt in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output to-day
  )  .
ship-day = par-date-post - to-day .
pay-day  = par-date-2 - par-date-1  + 1 .
define variable v-i-doc as character no-undo .
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run proc-ord-code in this-procedure
 (input   'main' ,
  input   v-cntxt-db-num ,
  input   v-cntxt-obj-type ,
  input   v-cntxt-obj-code ,
  input   v-i-doc ,
  output  par-ord-doc-code
 ) .
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  p-host-code
  ,output v-base-code
  )  .
   create ub.ord-doc.
   assign
      ub.ord-doc.doc-code    = par-ord-doc-code
      ub.ord-doc.cli-code    = buf_clients.obj-code
      ub.ord-doc.cli-type    = buf_clients.obj-type
      ub.ord-doc.cli-name    = buf_clients.obj-name
      ub.ord-doc.cons-code   = ""
      ub.ord-doc.host-code   = p-host-code
      ub.ord-doc.obj-code    = p-obj-code
      ub.ord-doc.obj-type    = p-obj-type
      ub.ord-doc.doc-type    = par-ord-type
      ub.ord-doc.status_     = 'новый':U
      ub.ord-doc.start-date  = ?
      ub.ord-doc.end-date    = ?
      ub.ord-doc.doc-date    = to-day
      ub.ord-doc.ship-date   = par-date-post
      ub.ord-doc.date-sale-1 = par-date-1
      ub.ord-doc.date-sale-2 = par-date-2
      ub.ord-doc.ship-time   = 0
      ub.ord-doc.vat-type    = 'в т. ч.':U
      ub.ord-doc.slt-type    = 'без':U
      ub.ord-doc.pay-code    = 1
      ub.ord-doc.tot-lines   = v-kol-rec
      .
      ub.ord-doc.exch-code = 0 .
      find buf_currency no-lock  where buf_currency.curr-code = ub.ord-doc.exch-code no-error.
        if available buf_currency then do:
            find last buf_curr-accnt no-lock   where buf_curr-accnt.curr-code = buf_currency.curr-code  use-index pi no-error.
              if available buf_curr-accnt then
                assign
                    ub.ord-doc.exch-rate = buf_curr-accnt.exch-rate
                    ub.ord-doc.exch-scale = buf_curr-accnt.exch-scale
                    .
       end.
      find last buf_curr-accnt no-lock  where buf_curr-accnt.curr-code = v-base-code  use-index pi no-error .
        if available buf_curr-accnt then
            assign
              ub.ord-doc.base-rate  = buf_curr-accnt.exch-rate
              ub.ord-doc.base-scale = buf_curr-accnt.exch-scale
              .
   par-ord-doc-recid = par-ord-doc-recid + "," + string(recid(ub.ord-doc)) .
repeat v-i = 1 to v-kol-rec :
   find first buf_abc-analysis-goods no-lock where
              recid(buf_abc-analysis-goods) = int(entry(v-i , p-recid))
              no-error .
     if available buf_abc-analysis-goods then do:
     find first buf_goods no-lock where buf_goods.gds-code = buf_abc-analysis-goods.gds-code no-error .
        if not available buf_goods then next.
        var-ok-assort-pol = true .
        if par-ord-type <> 'ФП':U then do:
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run goassizt in g#library2
  (input  par-ord-type
  ,input  buf_goods.gds-code
  ,input  p-obj-type
  ,input  p-obj-code
  ,input  true
  ,output var-ok-assort-pol
  ,output var-mess-assort-pol
  ) .
        end.
        if var-ok-assort-pol = false then
        do:
           next .
        end.
        find first tmp#zakaz no-lock where recid(tmp#zakaz) = recid(buf_goods) no-error .
        run calc-zakz ( output v-qnty) .
        run create-ord-line
        ( input  par-ord-doc-code
         ,input  v-i
         ,input  buf_goods.artic
         ,input  buf_goods.prod-code
         ,input  buf_goods.prod-type
         ,input  buf_goods.cli-base-rate
         ,input  v-qnty
         ,input  buf_goods.unit-cli ) no-error .
         if error-status :error then next.
     end.
end.
  end.
end procedure.
procedure calc-zakz :
  do
  on error undo, return error return-value
  :
define output parameter par-ord-qnty as decimal   no-undo .
define variable v-temp      as decimal   no-undo .
define variable v-min-stock as decimal   no-undo .
define variable v-min-order as decimal   no-undo .
define variable v-qnty-stk  as decimal   no-undo .
define variable v-corr-coeff as decimal  no-undo init 1.
define variable       v-neg-sale     as logical   no-undo .
define variable       v-gds-way-all  as decimal   no-undo .
define variable       v-min-zapas    as logical   no-undo .
define variable       v-min-ost      as logical   no-undo .
define variable       v-deadline     as logical   no-undo .
define variable p-return-AssMin         as logical   no-undo .
define variable p-return-igt            as character no-undo .
define variable p-grop-max-stock        as decimal   no-undo .
define variable p-grop-level-always-presence     as decimal   no-undo .
define variable to-day        as date      no-undo .
define variable vs-min-stock  as decimal   no-undo .
define variable vs-min-order  as decimal   no-undo .
pay-day  = par-date-2 - par-date-1  + 1 .
all-day = pay-day .
if par-ord-type = 'ОП':U then do:
    find first buf_abc-analysis-gds-obj no-lock where
               buf_abc-analysis-gds-obj.abc-id   =  buf_abc-analysis-obj.abc-id and
               buf_abc-analysis-gds-obj.db-num   =  buf_abc-analysis-obj.db-num and
               buf_abc-analysis-gds-obj.obj-code =  buf_abc-analysis-obj.obj-code and
               buf_abc-analysis-gds-obj.obj-type =  buf_abc-analysis-obj.obj-type and
               buf_abc-analysis-gds-obj.gds-code =  buf_goods.gds-code
               no-error .
  if available buf_abc-analysis-gds-obj then do:
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjpr in g#library
  (input  buf_abc-analysis-gds-obj.obj-type
  ,input  buf_abc-analysis-gds-obj.obj-code
  ,input  ?
  ,input  ?
  ,input  ?
  ,input  buf_abc-analysis-gds-obj.gds-code
  ,output p-return-AssMin
  ,output p-return-igt
  ,output v-min-stock
  ,output p-grop-max-stock
  ,output p-grop-level-always-presence
  ,output v-min-order
  )  .
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curobjdt in g#library
  (input  buf_abc-analysis-gds-obj.obj-type
  ,input  buf_abc-analysis-gds-obj.obj-code
  ,output to-day
  )  .
    ship-day = par-date-post - to-day .
    v-temp     = buf_abc-analysis-gds-obj.abog-temp-sale-goods.
    v-qnty-stk = buf_abc-analysis-gds-obj.abog-stock-qnty .
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if is-log = true then Output stream stream_order to value ("order_raschet.txt") APPEND .
Assign
  l-Ostatok-today =  v-qnty-stk
  l-negative-rest =  buf_goods.negative-rest
  l-qnty-day      =  ship-day
  l-pay-day       =  pay-day
  l-Temp-rash     = if v-temp < 0  then 0 else v-temp
  l-min-zap       =  v-min-stock
  l-negative-sale =  v-neg-sale
  l-goods-way     =  v-gds-way-all
  l-tog-min-order =  v-min-zapas
  l-min-order     =  v-min-order
  loc-unit-base   =  buf_goods.unit-base
  l-min-ost       =  v-min-ost
  l-TOG-deadline  =  v-deadline
  l-deadline      =  buf_goods.deadline
  l-type-MR       =  v-e-method
  l-corr-coeff    =  v-corr-coeff
  .
if l-Temp-rash = ? then l-Temp-rash = 0.
  if par-ord-min-ost = yes then do:
    assign l-min-zap = l-Temp-rash * l-corr-coeff * v-min-stock .
  end.
  assign L-a = l-Ostatok-today - (l-Temp-rash * l-corr-coeff * l-qnty-day) .
  if L-a  <= 0 then do:
    if l-negative-rest = true then do:
      if l-negative-sale then do:
        Assign
          l-a = 0
          l-order = ABSOLUTE(l-a) + l-min-zap + (l-pay-day * l-Temp-rash * l-corr-coeff)
        .
      end.
      else do:
        assign l-order = ABSOLUTE(l-a) + l-min-zap + (l-pay-day * l-Temp-rash * l-corr-coeff).
      end.
    end.
    else do:
      Assign
        l-a = 0
        l-order = ABSOLUTE(l-a) + l-min-zap + (l-pay-day * l-Temp-rash * l-corr-coeff)
      .
    end.
  end.
  Else do :
    assign l-b = l-Ostatok-today - (l-Temp-rash * l-corr-coeff * (l-qnty-day + l-pay-day ) ) .
          if l-b >= l-min-zap then l-order = 0.
                              else DO:
                              If l-b < 0 Then l-order = absolute(l-b) + l-min-zap.
                                         Else l-order = l-min-zap - absolute(l-b).
                              End.
   End.
 assign
  v-protocol-date = today
  v-protocol-time = time
 .
if is-log = true then  put stream stream_order unformatted
">> Базовый способ расчета заказа "  v-protocol-date " " string(v-protocol-time,"hh:mm:ss") skip
   tmp#zakaz.gds-code " " tmp#zakaz.gds-name skip
   "Остаток на сегодня:" l-Ostatok-today skip
   "Отриц.остатки     :" l-negative-rest skip
   "дней до доставки  :" l-qnty-day      skip
   "дней в продаже    :" l-pay-day       skip
   "Темп продаж       :" l-Temp-rash     skip
   "Коррект.коэфф.    :" l-corr-coeff    skip
   "Дней без продажи  :" l-null-day      skip
   "MIN остаток       :" l-min-zap       skip
   "отриц.продажа     :" l-negative-sale skip
   "рассчитано заказа :" l-order         skip
   "_________________  "                 skip
   "min заказ         :" l-min-order     skip
   "товар в пути      :" l-goods-way     skip
   "срок хранения     :" l-deadline      skip
   .
l-type-MR = entry(2, entry(1,l-type-MR,";"),":") no-error .
if l-type-MR = ? then l-type-MR = "Базовый способ расчета заказа" .
v-stroka-protocol = "" .
v-stroka-protocol =
   "00.Метод расчета заказа:" + l-type-MR  + chr(4) +
   "01.Остаток на сегодня:" + string(l-Ostatok-today) + chr(4) +
   "02.Отриц.остатки     :" + string(l-negative-rest) + chr(4) +
   "03.дней до доставки  :" + string(l-qnty-day     ) + chr(4) +
   "04.дней в продаже    :" + string(l-pay-day      ) + chr(4) +
   "05.Темп продаж       :" + string(l-Temp-rash    ) + chr(4) +
   "05.1>>Коррект.коэфф. :" + string(l-corr-coeff   ) + chr(4) +
   "06.Дней без продажи  :" + string(l-null-day     ) + chr(4) +
   "07.MIN остаток       :" + string(l-min-zap      ) + chr(4) +
   "08.отриц.продажа     :" + string(l-negative-sale) + chr(4) +
   "09.рассчитано заказа :" + string(l-order        ) + chr(4) +
   "10.MIN заказ         :" + string(l-min-order    ) + chr(4) +
   "11.товар в пути      :" + string(l-goods-way    ) + chr(4) +
   "12.срок хранения     :" + string(l-deadline     ) + chr(4) .
  v-media-qnty = l-order .
  if (l-order - l-goods-way) < 0 then
     par-ord-qnty = 0 .
  else
     par-ord-qnty = l-order - l-goods-way .
 assign v-stroka-protocol = v-stroka-protocol + "13.1>>После учета товара в пути:" + string(par-ord-qnty) + chr(4)  .
  if l-min-ost = true then do:
      if l-Ostatok-today > l-min-zap then
          par-ord-qnty = 0 .
      assign v-stroka-protocol = v-stroka-protocol + "13.2>>После проверки на MIN остаток:" + string(par-ord-qnty) + chr(4)  .
  end.
if can-find(first ub.units where ub.units.unit-name = loc-unit-base
    and lookup('шту':U, ub.units.type) > 0)
    and trunc( par-ord-qnty, 0 ) <> par-ord-qnty then do:
        par-ord-qnty = trunc( par-ord-qnty, 0 ) + 1 .
        assign v-stroka-protocol = v-stroka-protocol + "13.3>>После округления до штук + 1:" + string(par-ord-qnty) + chr(4)  .
    end.
  if  l-deadline > 0 and l-tog-deadline = true   then do:
     par-ord-qnty = min(par-ord-qnty, l-Temp-rash * l-deadline ) .
     v-stroka-protocol = v-stroka-protocol + "13.4>>После проверки на срок хронения:" + string(par-ord-qnty) + chr(4)  .
 end .
 if l-tog-min-order then do:
  if ( par-ord-qnty - l-min-order) < 0 and l-min-order > 0 then
     par-ord-qnty = 0 .
     assign v-stroka-protocol = v-stroka-protocol + "13.5>>После проверки на MIN заказ:" + string(par-ord-qnty) + chr(4)  .
 end .
if par-ord-qnty = ? then par-ord-qnty = 0 .
if is-log = true then  put STREAM  stream_order unformatted "Итого (БЕЗ ОКР)"  par-ord-qnty skip
 .
if is-log = true then  OUTPUT  STREAM  stream_order CLOSE.
 assign v-stroka-protocol = v-stroka-protocol + "17.Итого рассчитано(БЕЗ ОКР):" + string(par-ord-qnty) .
   end.
end.
if par-ord-type = 'ФП':U then do:
v-temp     = 0 .
v-qnty-stk = 0 .
vs-min-stock = 0 .
vs-min-order = 0 .
    for each   buf_abc-analysis-obj no-lock where
               buf_abc-analysis-obj.abc-id =  v-abc-id and
               buf_abc-analysis-obj.db-num =  v-abc-db-num
               :
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjpr in g#library
  (input  buf_abc-analysis-obj.obj-type
  ,input  buf_abc-analysis-obj.obj-code
  ,input  ?
  ,input  ?
  ,input  ?
  ,input  buf_goods.gds-code
  ,output p-return-AssMin
  ,output p-return-igt
  ,output v-min-stock
  ,output p-grop-max-stock
  ,output p-grop-level-always-presence
  ,output v-min-order
  )  .
    vs-min-stock  = vs-min-stock + v-min-stock .
    vs-min-order  = vs-min-order + v-min-order.
    v-temp     = v-temp     +  buf_abc-analysis-goods.abcg-temp-sale-goods.
    v-qnty-stk = v-qnty-stk +  buf_abc-analysis-goods.abcg-stock-qnty .
end.
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if is-log = true then Output stream stream_order to value ("order_raschet.txt") APPEND .
Assign
  l-Ostatok-today =  v-qnty-stk
  l-negative-rest =  buf_goods.negative-rest
  l-qnty-day      =  ship-day
  l-pay-day       =  pay-day
  l-Temp-rash     = if v-temp < 0  then 0 else v-temp
  l-min-zap       =  vs-min-stock
  l-negative-sale =  v-neg-sale
  l-goods-way     =  v-gds-way-all
  l-tog-min-order =  v-min-zapas
  l-min-order     =  vs-min-order
  loc-unit-base   =  buf_goods.unit-base
  l-min-ost       =  v-min-ost
  l-TOG-deadline  =  v-deadline
  l-deadline      =  buf_goods.deadline
  l-type-MR       =  v-e-method
  l-corr-coeff    =  v-corr-coeff
  .
if l-Temp-rash = ? then l-Temp-rash = 0.
  if par-ord-min-ost = yes then do:
    assign l-min-zap = l-Temp-rash * l-corr-coeff * vs-min-stock .
  end.
  assign L-a = l-Ostatok-today - (l-Temp-rash * l-corr-coeff * l-qnty-day) .
  if L-a  <= 0 then do:
    if l-negative-rest = true then do:
      if l-negative-sale then do:
        Assign
          l-a = 0
          l-order = ABSOLUTE(l-a) + l-min-zap + (l-pay-day * l-Temp-rash * l-corr-coeff)
        .
      end.
      else do:
        assign l-order = ABSOLUTE(l-a) + l-min-zap + (l-pay-day * l-Temp-rash * l-corr-coeff).
      end.
    end.
    else do:
      Assign
        l-a = 0
        l-order = ABSOLUTE(l-a) + l-min-zap + (l-pay-day * l-Temp-rash * l-corr-coeff)
      .
    end.
  end.
  Else do :
    assign l-b = l-Ostatok-today - (l-Temp-rash * l-corr-coeff * (l-qnty-day + l-pay-day ) ) .
          if l-b >= l-min-zap then l-order = 0.
                              else DO:
                              If l-b < 0 Then l-order = absolute(l-b) + l-min-zap.
                                         Else l-order = l-min-zap - absolute(l-b).
                              End.
   End.
 assign
  v-protocol-date = today
  v-protocol-time = time
 .
if is-log = true then  put stream stream_order unformatted
">> Базовый способ расчета заказа "  v-protocol-date " " string(v-protocol-time,"hh:mm:ss") skip
   tmp#zakaz.gds-code " " tmp#zakaz.gds-name skip
   "Остаток на сегодня:" l-Ostatok-today skip
   "Отриц.остатки     :" l-negative-rest skip
   "дней до доставки  :" l-qnty-day      skip
   "дней в продаже    :" l-pay-day       skip
   "Темп продаж       :" l-Temp-rash     skip
   "Коррект.коэфф.    :" l-corr-coeff    skip
   "Дней без продажи  :" l-null-day      skip
   "MIN остаток       :" l-min-zap       skip
   "отриц.продажа     :" l-negative-sale skip
   "рассчитано заказа :" l-order         skip
   "_________________  "                 skip
   "min заказ         :" l-min-order     skip
   "товар в пути      :" l-goods-way     skip
   "срок хранения     :" l-deadline      skip
   .
l-type-MR = entry(2, entry(1,l-type-MR,";"),":") no-error .
if l-type-MR = ? then l-type-MR = "Базовый способ расчета заказа" .
v-stroka-protocol = "" .
v-stroka-protocol =
   "00.Метод расчета заказа:" + l-type-MR  + chr(4) +
   "01.Остаток на сегодня:" + string(l-Ostatok-today) + chr(4) +
   "02.Отриц.остатки     :" + string(l-negative-rest) + chr(4) +
   "03.дней до доставки  :" + string(l-qnty-day     ) + chr(4) +
   "04.дней в продаже    :" + string(l-pay-day      ) + chr(4) +
   "05.Темп продаж       :" + string(l-Temp-rash    ) + chr(4) +
   "05.1>>Коррект.коэфф. :" + string(l-corr-coeff   ) + chr(4) +
   "06.Дней без продажи  :" + string(l-null-day     ) + chr(4) +
   "07.MIN остаток       :" + string(l-min-zap      ) + chr(4) +
   "08.отриц.продажа     :" + string(l-negative-sale) + chr(4) +
   "09.рассчитано заказа :" + string(l-order        ) + chr(4) +
   "10.MIN заказ         :" + string(l-min-order    ) + chr(4) +
   "11.товар в пути      :" + string(l-goods-way    ) + chr(4) +
   "12.срок хранения     :" + string(l-deadline     ) + chr(4) .
  v-media-qnty = l-order .
  if (l-order - l-goods-way) < 0 then
     par-ord-qnty = 0 .
  else
     par-ord-qnty = l-order - l-goods-way .
 assign v-stroka-protocol = v-stroka-protocol + "13.1>>После учета товара в пути:" + string(par-ord-qnty) + chr(4)  .
  if l-min-ost = true then do:
      if l-Ostatok-today > l-min-zap then
          par-ord-qnty = 0 .
      assign v-stroka-protocol = v-stroka-protocol + "13.2>>После проверки на MIN остаток:" + string(par-ord-qnty) + chr(4)  .
  end.
if can-find(first ub.units where ub.units.unit-name = loc-unit-base
    and lookup('шту':U, ub.units.type) > 0)
    and trunc( par-ord-qnty, 0 ) <> par-ord-qnty then do:
        par-ord-qnty = trunc( par-ord-qnty, 0 ) + 1 .
        assign v-stroka-protocol = v-stroka-protocol + "13.3>>После округления до штук + 1:" + string(par-ord-qnty) + chr(4)  .
    end.
  if  l-deadline > 0 and l-tog-deadline = true   then do:
     par-ord-qnty = min(par-ord-qnty, l-Temp-rash * l-deadline ) .
     v-stroka-protocol = v-stroka-protocol + "13.4>>После проверки на срок хронения:" + string(par-ord-qnty) + chr(4)  .
 end .
 if l-tog-min-order then do:
  if ( par-ord-qnty - l-min-order) < 0 and l-min-order > 0 then
     par-ord-qnty = 0 .
     assign v-stroka-protocol = v-stroka-protocol + "13.5>>После проверки на MIN заказ:" + string(par-ord-qnty) + chr(4)  .
 end .
if par-ord-qnty = ? then par-ord-qnty = 0 .
if is-log = true then  put STREAM  stream_order unformatted "Итого (БЕЗ ОКР)"  par-ord-qnty skip
 .
if is-log = true then  OUTPUT  STREAM  stream_order CLOSE.
 assign v-stroka-protocol = v-stroka-protocol + "17.Итого рассчитано(БЕЗ ОКР):" + string(par-ord-qnty) .
end.
  end.
end procedure.
