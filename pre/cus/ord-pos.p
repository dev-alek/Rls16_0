block-level on error undo, throw.
define input parameter parParentProc  as widget-handle no-undo.
define input parameter p-place  as character no-undo .
define input parameter tt       as character no-undo .
define input parameter p-status as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: ord-pos.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cus/ord-pos.p $":U .
define variable vss-description as character no-undo init "Вызов заказов".
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
procedure proc-alt-shift-f2:
  if not ibs.th.gbl.gbl-var:rcode
then
  run gbl\inidebug.p .
end.
procedure proc-alt-shift-f3:
  run gbl/prvssinf.p
    ( input this-procedure
    ) .
end.
define variable v-inform-launched as logical no-undo initial false .
procedure proc-alt-shift-f4:
  define variable v-action as character no-undo .
  if v-inform-launched = false then do:
    assign
      v-inform-launched = true
    .
    run gbl/d-inform.w
      (  input self
      ,  input this-procedure
      , output v-action
      ) no-error .
    run gbl/infrmact.p (input self, input this-procedure, input v-action) no-error .
    assign
      v-inform-launched = false
    .
  end.
end.
procedure proc-alt-f1:
  run gbl/corrhelp.p
    (input this-procedure
    ) .
end .
on alt-shift-f2 anywhere do:
  run proc-alt-shift-f2.
end.
on alt-shift-f3 anywhere do:
  run proc-alt-shift-f3 in this-procedure .
end.
on alt-shift-f4 anywhere do:
  run proc-alt-shift-f4 in this-procedure.
end.
on alt-f1 anywhere do:
  run proc-alt-f1 in this-procedure .
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
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
    undo, return error substitute( "&1. &2&3&4", vss-include-info1, return-value, chr(10), error-status :get-message (1)).
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
    undo, return error substitute( "&1. &2&3&4", vss-include-info1, return-value, chr(10), error-status :get-message (1)).
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
define variable p-list        as character no-undo .
define variable g#type        as character no-undo .
define variable g#stat        as character no-undo .
define variable par-ord-ofof  as logical   no-undo .
define variable type-par      as character no-undo .
define variable v-obj-active  as character no-undo .
define variable v-office      as character no-undo .
define variable par-mode      as character no-undo .
define variable pardoc-rec    as recid no-undo .
define variable p-char        as character no-undo .
define variable list-mode   as character no-undo .
define variable store-type  as character no-undo .
define variable store-code  as integer   no-undo .
define variable g#host-name as character no-undo .
define variable g#host-code as integer   no-undo .
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
assign
  store-type    = v-cntxt-obj-type
  store-code    = v-cntxt-obj-code
.
define variable v-fin-block as character no-undo .
if p-place = 'firm-fin':U    or
   p-place = 'without-fo':U  or
   p-place = 'with-fo':U
    then v-fin-block = ",fin-block" .
    else v-fin-block = "" .
define buffer buf_clients-name for ub.clients  .
if store-type = ? or store-type = "" then do:
  g#host-code = v-cntxt-host-code-obj .
  find first buf_clients-name no-lock where
             buf_clients-name.obj-code =  g#host-code and
             buf_clients-name.obj-type = 'орг':U
             no-error .
   g#host-name = buf_clients-name.obj-name.
   v-obj-active = 'no' .
end.
else do:
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  store-type
  ,input  store-code
  ,output g#host-code
  )  .
  find first buf_clients-name no-lock where
             buf_clients-name.obj-code =  g#host-code and
             buf_clients-name.obj-type = 'орг':U
             no-error .
   g#host-name = buf_clients-name.obj-name.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  store-type
  ,input  store-code
  ,input  'active=request':u
  ,output v-obj-active
  )  .
end.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run currdbat in g#library
  (input  'office=request':u
  ,output v-office
  )  .
define variable v-value-character  as character no-undo .
define variable v-value-date       as date      no-undo .
define variable v-value-decimal    as decimal   no-undo .
define variable v-value-integer    as integer   no-undo .
run adm/shattri.p (
  input "get":U
  ,input ""
  ,input 0
  ,input 'ord-global':U
  ,input 'ord-ofof':U
  ,output v-value-character
  ,output v-value-date
  ,output v-value-decimal
  ,output v-value-integer
  ,output par-ord-ofof
  ,output type-par
  ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
  ) no-error .
assign
    list-mode = p-place
    g#type = (If tt = "all":U     then ? else tt          )
    g#stat = (if p-status = "all":U then ? else p-status  )
    .
case g#type :
when 'ОО':U then do:
   if g#type =  ? then  par-mode = 'объ':U  .
                  else  par-mode =  "status":U .
    case g#stat :
        when 'новый':U then do:
          run cus/ord-ooz.w
          ( input   parParentProc,
            input  "b-add,b-chg,b-del,b-lkp,b-close" ,
            input  par-mode    ,
            input  pardoc-rec  ,
            input  g#host-code ,
            input  store-code  ,
            input  store-type  ,
            input  g#type      ,
            input  g#stat      ,
            input  p-char      ,
            output p-list
            ).
        end.
        when 'запрос':U then do:
          run cus/ord-ooz.w
          ( input   parParentProc,
            input  "b-chg,b-del,b-lkp,b-close" ,
            input  par-mode    ,
            input  pardoc-rec  ,
            input  g#host-code ,
            input  store-code  ,
            input  store-type  ,
            input  g#type      ,
            input  g#stat      ,
            input  p-char      ,
            output p-list
            ).
        end.
        when 'факт':U then do:
          run cus/ord-ooz.w
          ( input   parParentProc,
            input  "b-lkp" ,
            input  par-mode    ,
            input  pardoc-rec  ,
            input  g#host-code ,
            input  store-code  ,
            input  store-type  ,
            input  g#type      ,
            input  g#stat      ,
            input  p-char      ,
            output p-list
            ).
        end.
        when ? then do:
          par-mode = 'объ':U  .
          run cus/ord-ooz.w
          ( input   parParentProc,
            input  "b-add,b-chg,b-del,b-lkp,b-close" ,
            input  par-mode    ,
            input  pardoc-rec  ,
            input  g#host-code ,
            input  store-code  ,
            input  store-type  ,
            input  g#type      ,
            input  g#stat      ,
            input  p-char      ,
            output p-list
            ).
        end.
    end case.
end.
when 'ОР':U then do:
   if list-mode = "rc":U then do:
      if g#type =  ?
          then  par-mode = list-mode + 'объ':U  .
          else  par-mode = list-mode + "status":U .
   end.
   else do:
      if g#type =  ?
          then  par-mode = 'объ':U  .
          else  par-mode = "status":U .
   end.
    case g#stat :
        when 'новый':U then do:
          run cus/ord-orc.w
          ( input   parParentProc,
            input  "b-add,b-chg,b-del,b-lkp,b-close" ,
            input  par-mode    ,
            input  pardoc-rec  ,
            input  g#host-code ,
            input  store-code  ,
            input  store-type  ,
            input  g#type      ,
            input  g#stat      ,
            input  p-char      ,
            output p-list
            ).
        end.
        when 'запрос':U  or
        when 'разрешено':U  or
        when 'отказ':U  or
        when 'отгружено':U
          then do:
          run cus/ord-orc.w
            ( input   parParentProc,
              input  "b-lkp,b-close" ,
              input  par-mode    ,
              input  pardoc-rec  ,
              input  g#host-code ,
              input  store-code  ,
              input  store-type  ,
              input  g#type      ,
              input  g#stat      ,
              input  p-char      ,
              output p-list
              ).
        end.
        when 'факт':U then do:
          run cus/ord-orc.w
          ( input   parParentProc,
            input  "b-lkp" ,
            input  par-mode    ,
            input  pardoc-rec  ,
            input  g#host-code ,
            input  store-code  ,
            input  store-type  ,
            input  g#type      ,
            input  g#stat      ,
            input  p-char      ,
            output p-list
            ).
        end.
        when ? then do:
            if list-mode = "rc":U then do:
                    par-mode = list-mode + 'объ':U  .
            end.
            else do:
                    par-mode = 'объ':U  .
            end.
          run cus/ord-orc.w
          ( input   parParentProc,
            input  "b-add,b-chg,b-del,b-lkp,b-close" ,
            input  par-mode    ,
            input  pardoc-rec  ,
            input  g#host-code ,
            input  store-code  ,
            input  store-type  ,
            input  g#type      ,
            input  g#stat      ,
            input  p-char      ,
            output p-list
            ).
        end.
    end case.
end.
otherwise do:
If g#stat    = 'новый':U
   or g#stat = 'отказ':U
   or g#type = 'ОФ':U
   then  do:
       if (list-mode = "obj" or list-mode = "firm" ) and g#type = ? then
          run ref/all-zakz.w
         ( input   parParentProc
          ,input   g#type
          ,input   g#stat
          ,input   list-mode
          ,input   ""
          ,input   "b-chg,b-del,b-lkp,b-close,b-open" + v-fin-block
          ,input   ""
          ,output  p-list       ) .
          else do:
              if  par-ord-ofof = false then dO :
                  If g#type = 'ОФ':U and g#db-num = 0 then do:
                      run ref/all-zakz.w
                      (   input   parParentProc
                         ,input   g#type
                         ,input   g#stat
                         ,input   list-mode
                         ,input   ""
                         ,input   "b-chg,b-del,b-lkp,b-close,b-open" + v-fin-block
                         ,input   ""
                         ,output  p-list       ) .
                      end.
                      else do:
                      run ref/all-zakz.w
                      (      input   parParentProc
                            ,input   g#type
                            ,input   g#stat
                            ,input   list-mode
                            ,input   ""
                            ,input   "b-add,b-chg,b-del,b-lkp,b-close,b-open" + v-fin-block
                            ,input   ""
                            ,output  p-list       ) .
                      end.
              end.
              else do:
                  If g#type = 'ОФ':U and g#db-num = 0 then
                      run ref/all-zakz.w
                      (    input   parParentProc
                          ,input   g#type
                          ,input   g#stat
                          ,input   list-mode
                          ,input   ""
                          ,input   "b-add,b-chg,b-del,b-lkp,b-close,b-open" + v-fin-block
                          ,input   ""
                          ,output  p-list       ) .
                      else do:
                          If g#type = 'ФП':U and g#db-num = 0 then
                                 run ref/all-zakz.w
                                 (   input   parParentProc
                                    ,input   g#type
                                    ,input   g#stat
                                    ,input   list-mode
                                    ,input   ""
                                    ,input   "b-add,b-chg,b-del,b-lkp,b-close,b-open" + v-fin-block
                                    ,input   ""
                                    ,output  p-list       ) .
                            else run ref/all-zakz.w
                                (   input   parParentProc
                                   ,input   g#type
                                   ,input   g#stat
                                   ,input   list-mode
                                   ,input   ""
                                   ,input   "b-chg,b-del,b-lkp,b-close,b-open" + v-fin-block
                                   ,input   ""
                                   ,output  p-list       ) .
                      end.
              end.
          end.
       end.
   else do:
      if v-fin-block = "" then
      run cus/zakz-rcv.w
      ( input   parParentProc
        ,input   g#type
        ,input   g#stat
        ,input   list-mode
        ,input   ""
        ,input   "b-add,b-chg,b-del,b-lkp,b-close,b-open"
        ,input   ""
        ,output  p-list       ) .
        else
           run ref/all-zakz.w
              ( input   parParentProc
                ,input   g#type
                ,input   g#stat
                ,input   list-mode
                ,input   ""
                ,input   "b-lkp" + v-fin-block
                ,input   ""
                ,output  p-list
                  ) .
    end.
end.
end case.
return.
