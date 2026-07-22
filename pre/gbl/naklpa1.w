define input parameter parparentproc as widget-handle no-undo.
define input parameter p-mode        as character no-undo.
define input parameter p-obj-type    like ub.clients.obj-type no-undo.
define input parameter p-obj-code    like ub.shop.obj-code no-undo.
define variable vss-revision    as character no-undo init "$Revision: aafc1433d2fb, 3161, rls $":U .
define variable vss-author      as character no-undo init "$Author: SSlivenko $":U .
define variable vss-date        as character no-undo init "$Date: 2022/12/27 12:54:22 $":U .
define variable vss-Workfile    as character no-undo init "$Workfile: naklpa1.w $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/naklpa1.w $":U .
define variable vss-description as character no-undo init "Настроечные параметры для накладных" .
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
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
define variable vss-include-info4 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define temp-table temp_onewin_items no-undo
    field itm-key       as integer
    field itmExtKey     as character
    field itmName       as character
    field itmDesc       as character
    field itmSelected   as logical
    index pi is primary unique
        itm-key
    index ie
        itmExtKey
.
define temp-table temp_onewin_itemsSelected no-undo
    field its-key   as integer
    field itm-key   as integer
    field itmExtKey as character
    index pi is primary unique
        its-key
    index im
        itm-key
.
define variable v-onewin4-itm-key    as integer      no-undo.
procedure onewin_clear :
    define buffer buf_temp_onewin_items        for temp_onewin_items.
do
for buf_temp_onewin_items
on error undo, return error
:
    empty temp-table buf_temp_onewin_items.
end.
end procedure.
procedure onewin_add-item :
define input parameter p-ext-key   as character        no-undo.
define input parameter p-item-name as character        no-undo.
define input parameter p-item-desc as character        no-undo.
define input parameter p-selected  as logical          no-undo.
    define buffer buf_temp_onewin_items        for temp_onewin_items.
do
for buf_temp_onewin_items
on error undo, return error
:
    find last buf_temp_onewin_items no-error.
    if available buf_temp_onewin_items then do:
      v-onewin4-itm-key = buf_temp_onewin_items.itm-key.
    end.
    else do:
      v-onewin4-itm-key = 0.
    end.
    assign
        v-onewin4-itm-key = v-onewin4-itm-key + 1
    .
    create buf_temp_onewin_items.
    assign
    buf_temp_onewin_items.itm-key      = v-onewin4-itm-key
    buf_temp_onewin_items.itmExtKey    = p-ext-key
    buf_temp_onewin_items.itmName      = p-item-name
    buf_temp_onewin_items.itmDesc      = p-item-desc
    buf_temp_onewin_items.itmSelected  = p-selected
    .
end.
end procedure.
procedure onewin_create-selection :
define input parameter p-itm-key as integer no-undo .
define input parameter p-itmextkey as character no-undo .
define variable v-counter as integer no-undo .
define buffer buf_temp_onewin_itemsSelected for temp_onewin_itemsSelected .
do
on error undo, return error
:
  find last buf_temp_onewin_itemsSelected use-index pi no-error.
  if available buf_temp_onewin_itemsSelected then do:
    v-counter = buf_temp_onewin_itemsSelected.its-key.
  end.
  find first buf_temp_onewin_itemsSelected where
       buf_temp_onewin_itemsSelected.itm-key = p-itm-key no-error.
  if not available buf_temp_onewin_itemsSelected then do:
    create buf_temp_onewin_itemsSelected.
    assign
    buf_temp_onewin_itemsSelected.its-key   = v-counter + 1
    v-counter = v-counter + 1
    buf_temp_onewin_itemsSelected.itm-key   = p-itm-key
    buf_temp_onewin_itemsSelected.itmExtKey = p-itmExtKey
    .
  end.
end.
end procedure.
procedure onewin_check-item :
define input parameter p-ext-key   as character        no-undo.
define output parameter p-exists as logical no-undo .
define buffer buf_temp_onewin_items for temp_onewin_items.
find first buf_temp_onewin_items where
buf_temp_onewin_items.itmExtKey    = p-ext-key no-error.
if available buf_temp_onewin_items then do:
  p-exists = yes.
end.
end procedure.
define variable vss-include-info5 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define temp-table temp_twowin_items no-undo
    field itm-key       as integer
    field itmExtKey     as character
    field itmName       as character
    field itmDesc       as character
    field itmSelected   as logical
    field selLeft       as logical
    field selRight      as logical
    index pi is primary unique
        itm-key
    index ie
        itmExtKey
.
define temp-table temp_twowin_itemsSelected no-undo
    field its-key   as integer
    field itm-key   as integer
    field itmExtKey as character
    index pi is primary unique
        its-key
    index im
        itm-key
.
define variable v-twowin5-itm-key    as integer      no-undo.
procedure twowin_clear :
    define buffer buf_temp_twowin_items        for temp_twowin_items.
do
for buf_temp_twowin_items
on error undo, return error
:
    empty temp-table buf_temp_twowin_items.
end.
end procedure.
procedure twowin_add-item :
define input parameter p-ext-key   as character        no-undo.
define input parameter p-item-name as character        no-undo.
define input parameter p-item-desc as character        no-undo.
define input parameter p-selected  as logical          no-undo.
    define buffer buf_temp_twowin_items        for temp_twowin_items.
do
for buf_temp_twowin_items
on error undo, return error
:
    assign
        v-twowin5-itm-key = v-twowin5-itm-key + 1
    .
    create temp_twowin_items.
    assign
        temp_twowin_items.itm-key      = v-twowin5-itm-key
        temp_twowin_items.itmExtKey    = p-ext-key
        temp_twowin_items.itmName      = p-item-name
        temp_twowin_items.itmDesc      = p-item-desc
        temp_twowin_items.itmSelected  = p-selected
        temp_twowin_items.selLeft      = no
        temp_twowin_items.selRight     = no
    .
end.
end procedure.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#trdcalib as handle no-undo.
define buffer obj_thbj-attr for ub.thbj-attr.
define buffer glb_thbj-attr for ub.thbj-attr.
define temp-table temp-thbj-attr no-undo like ub.thbj-attr.
define variable v-tth     as handle no-undo .
define variable v-tthg    as handle no-undo .
define variable v-to-create as logical no-undo.
define variable v-to-create-trn as logical no-undo.
define variable v-to-create-trn-g as logical no-undo.
define variable str-attr as character no-undo .
define temp-table thbjattr_thbj-attr-g no-undo like thbjattr_thbj-attr .
define VARIABLE v-string   as character  no-undo .
define temp-table temp_twowin_itemsSelected_col no-undo
    field its-key   as integer
    field itm-key   as integer
    field itmExtKey as character
    index pi is primary unique
      its-key
    index im
      itm-key
.
define variable v-list-edt-full as character    no-undo.
define variable v-list-edt      as character    no-undo.
define variable v-list-attr-PN-full as character    no-undo.
define variable v-list-attr-PN      as character    no-undo.
define variable v-list-attr-mandatory-gds-in-wayb-full  as character no-undo.
define variable v-list-attr-mandatory-gds-in-wayb       as character no-undo.
define variable v-list-attr-mandatory-gds-ret-wayb-full as character no-undo.
define variable v-list-attr-mandatory-gds-ret-wayb      as character no-undo.
define variable v-list-attr-mandatory-gds-exp-wayb-full as character no-undo.
define variable v-list-attr-mandatory-gds-exp-wayb      as character no-undo.
define variable v-list-reasons-for-return-full  as character no-undo .
define variable v-list-reasons-for-return       as character no-undo .
define variable v-list-reasons-write-off-full  as character no-undo .
define variable v-list-reasons-write-off       as character no-undo .
assign
v-tth  = buffer thbjattr_thbj-attr:table-handle .
v-tthg = buffer thbjattr_thbj-attr-g:table-handle .
 if g#db-num <> 0 and p-obj-type = "" and  p-obj-code = 0
    then p-mode = 'ПРОСМОТР':U .
DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-Help
     LABEL "&Help"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON button-1
     IMAGE-UP FILE "adeicon\ts-up":U
     IMAGE-DOWN FILE "adeicon\ts-down":U
     IMAGE-INSENSITIVE FILE "adeicon\ts-up":U NO-FOCUS
     LABEL "Страница&1"
     SIZE 14 BY 1.13 TOOLTIP "Закладка №1".
DEFINE BUTTON button-2
     IMAGE-UP FILE "adeicon\ts-up":U
     IMAGE-DOWN FILE "adeicon\ts-down":U
     IMAGE-INSENSITIVE FILE "adeicon\ts-up":U NO-FOCUS
     LABEL "Страница&2"
     SIZE 14 BY 1.13 TOOLTIP "Закладка №2".
DEFINE VARIABLE F-button-1 AS CHARACTER FORMAT "X(256)":U INITIAL "№ &1."
      VIEW-AS TEXT
     SIZE 5 BY .67 TOOLTIP "Закладка №1" NO-UNDO.
DEFINE VARIABLE F-button-2 AS CHARACTER FORMAT "X(256)":U INITIAL "№ &2."
      VIEW-AS TEXT
     SIZE 4.75 BY .67 TOOLTIP "Закладка №2" NO-UNDO.
DEFINE RECTANGLE RECT-3
     EDGE-PIXELS 1 GRAPHIC-EDGE  NO-FILL   ROUNDED
     SIZE 100 BY 20.5
     FGCOLOR 15 .
DEFINE BUTTON B-1
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE BUTTON B-10
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE BUTTON B-2
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE BUTTON B-3
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE BUTTON B-4
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE BUTTON B-5
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE BUTTON B-6
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE BUTTON B-7
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE BUTTON B-8
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE BUTTON B-9
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE VARIABLE date-close-period AS DATE FORMAT "99/99/9999":U
     VIEW-AS FILL-IN
     SIZE 11.63 BY 1 NO-UNDO.
DEFINE VARIABLE factorrt AS DECIMAL FORMAT "->>,>>9.99":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 5.5 BY 1 NO-UNDO.
DEFINE VARIABLE prc-exp AS DECIMAL FORMAT ">>9.99":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 7 BY 1 NO-UNDO.
DEFINE VARIABLE rnd-znk AS INTEGER FORMAT ">>9":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 3.5 BY 1 NO-UNDO.
DEFINE VARIABLE slt-ext AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN NATIVE
     SIZE 11 BY 1 NO-UNDO.
DEFINE VARIABLE v-avail-on-date AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 56.63 BY 1 NO-UNDO.
DEFINE VARIABLE v-chk-prs AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 40 BY 1 NO-UNDO.
DEFINE VARIABLE v-convimp AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 40 BY 1 NO-UNDO.
DEFINE VARIABLE v-curcli AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 57.88 BY 1 NO-UNDO.
DEFINE VARIABLE v-date-close-period AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 23.88 BY 1 NO-UNDO.
DEFINE VARIABLE v-factorrt AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 28.38 BY 1 NO-UNDO.
DEFINE VARIABLE v-inp_sum AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 66.13 BY 1 NO-UNDO.
DEFINE VARIABLE v-intprmvq AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 56.63 BY 1 NO-UNDO.
DEFINE VARIABLE v-is-bcdoc AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 40 BY 1 NO-UNDO.
DEFINE VARIABLE v-is-ov AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 44.38 BY 1 NO-UNDO.
DEFINE VARIABLE v-minusprt AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 56.63 BY 1 NO-UNDO.
DEFINE VARIABLE v-multdtyp AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 57.88 BY .88 NO-UNDO.
DEFINE VARIABLE v-noapndsc AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 43.38 BY 1 NO-UNDO.
DEFINE VARIABLE v-nocurbas AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 56 BY 1 NO-UNDO.
DEFINE VARIABLE v-part-prc AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 58.38 BY 1 NO-UNDO.
DEFINE VARIABLE v-prc-exp AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 65.13 BY 1 NO-UNDO.
DEFINE VARIABLE v-proxycrd AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 58.38 BY 1 NO-UNDO.
DEFINE VARIABLE v-rnd-znk AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 46 BY 1 NO-UNDO.
DEFINE VARIABLE v-slt-ext AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 36.5 BY 1 NO-UNDO.
DEFINE VARIABLE v-stfactdt AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 56.63 BY 1 NO-UNDO.
DEFINE VARIABLE v-type-slt AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 35 BY 1 NO-UNDO.
DEFINE VARIABLE v-type-vat AS CHARACTER FORMAT "X(240)":U
      VIEW-AS TEXT
     SIZE 35 BY 1 NO-UNDO.
DEFINE VARIABLE v-vat-ext AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 29.38 BY 1 NO-UNDO.
DEFINE VARIABLE v-vat-sum AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 29.38 BY .92 NO-UNDO.
DEFINE VARIABLE vat-ext AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN NATIVE
     SIZE 11 BY 1 NO-UNDO.
DEFINE IMAGE I-avail-on-date
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.
DEFINE IMAGE I-chk-prs
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.
DEFINE IMAGE I-convimp
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.
DEFINE IMAGE I-curcli
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.
DEFINE IMAGE I-date-close-period
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.04.
DEFINE IMAGE I-factorrt
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.04.
DEFINE IMAGE I-inp_sum
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.
DEFINE IMAGE I-intprmvq
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.
DEFINE IMAGE I-is-bcdoc
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.
DEFINE IMAGE I-is-ov
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.
DEFINE IMAGE I-minusprt
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.
DEFINE IMAGE I-multdtyp
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.
DEFINE IMAGE I-noapndsc
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.
DEFINE IMAGE I-nocurbas
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.
DEFINE IMAGE I-part-prc
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.
DEFINE IMAGE I-prc-exp
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.
DEFINE IMAGE I-proxycrd
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.
DEFINE IMAGE I-rnd-znk
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.
DEFINE IMAGE I-slt-ext
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.
DEFINE IMAGE I-stfactdt
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.
DEFINE IMAGE I-type-slt
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.04.
DEFINE IMAGE I-type-vat
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.
DEFINE IMAGE I-vat-ext
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.
DEFINE IMAGE I-vat-sum
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.
DEFINE VARIABLE nocurbas AS CHARACTER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Нет", "no",
"Да", "yes",
"Запрещено сегодня", "no_today"
     SIZE 29.5 BY 1
     FONT 4 NO-UNDO.
DEFINE VARIABLE type-slt AS INTEGER INITIAL 3
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "в.т.ч", 1,
"нет", 2,
"без", 3
     SIZE 15.63 BY 1
     FONT 4 NO-UNDO.
DEFINE VARIABLE type-vat AS INTEGER INITIAL 1
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "в.т.ч", 1,
"нет", 2,
"без", 3
     SIZE 15.63 BY 1
     FONT 4 NO-UNDO.
DEFINE VARIABLE avail-on-date AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.38 BY 1 NO-UNDO.
DEFINE VARIABLE chk-prs AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.38 BY 1 NO-UNDO.
DEFINE VARIABLE convimp AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.38 BY 1 NO-UNDO.
DEFINE VARIABLE curcli AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.38 BY 1 NO-UNDO.
DEFINE VARIABLE inp_sum AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.38 BY 1 NO-UNDO.
DEFINE VARIABLE intprmvq AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.38 BY 1 NO-UNDO.
DEFINE VARIABLE is-bcdoc AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.38 BY 1 NO-UNDO.
DEFINE VARIABLE is-ov AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.38 BY 1 NO-UNDO.
DEFINE VARIABLE minusprt AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.38 BY 1 NO-UNDO.
DEFINE VARIABLE multdtyp AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.38 BY 1 NO-UNDO.
DEFINE VARIABLE noapndsc AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.38 BY 1 NO-UNDO.
DEFINE VARIABLE part-prc AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.38 BY 1 NO-UNDO.
DEFINE VARIABLE proxycrd AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.38 BY 1 NO-UNDO.
DEFINE VARIABLE stfactdt AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.38 BY 1 NO-UNDO.
DEFINE VARIABLE vat-sum AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.38 BY .92 NO-UNDO.
DEFINE BUTTON B-11
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE BUTTON B-12
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE BUTTON B-13
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE BUTTON B-14
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE BUTTON B-15
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE BUTTON B-16
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE BUTTON B-17
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE BUTTON B-18
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE BUTTON B-19
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE BUTTON B-20
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE BUTTON B-21
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE BUTTON B-22
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE BUTTON B-23
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE BUTTON B-24
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE BUTTON B-25
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE BUTTON B-26
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE BUTTON B-27
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE BUTTON B-ex
     IMAGE-UP FILE "cmp/update.bmp":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE BUTTON B-set_attr-mandatory-gds-exp-wayb
     IMAGE-UP FILE "cmp/update.bmp":U
     LABEL ""
     SIZE 2.63 BY 1.08.
DEFINE BUTTON B-set_attr-mandatory-gds-in-wayb
     IMAGE-UP FILE "cmp/update.bmp":U
     LABEL ""
     SIZE 2.63 BY 1.08.
DEFINE BUTTON B-set_attr-mandatory-gds-ret-wayb
     IMAGE-UP FILE "cmp/update.bmp":U
     LABEL ""
     SIZE 2.63 BY 1.08.
DEFINE BUTTON B-set_reasons-for-return
     IMAGE-UP FILE "cmp/update.bmp":U
     LABEL ""
     SIZE 2.63 BY 1.08.
DEFINE BUTTON B-set_reasons-write-off
     IMAGE-UP FILE "cmp/update.bmp":U
     LABEL ""
     SIZE 2.63 BY 1.08.
DEFINE BUTTON B-set_attr-PN
     IMAGE-UP FILE "cmp/update.bmp":U
     LABEL ""
     SIZE 2.63 BY 1.08.
DEFINE VARIABLE attr-mandatory-gds-exp-wayb AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 35.5 BY 1 NO-UNDO.
DEFINE VARIABLE attr-mandatory-gds-in-wayb AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 35.5 BY 1 NO-UNDO.
DEFINE VARIABLE attr-mandatory-gds-ret-wayb AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 35.5 BY 1 NO-UNDO.
DEFINE VARIABLE reasons-for-return AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 35.5 BY 1 NO-UNDO.
DEFINE VARIABLE reasons-write-off AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 35.5 BY 1 NO-UNDO.
DEFINE VARIABLE attr-PN AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 35.5 BY 1 NO-UNDO.
DEFINE VARIABLE reasonme AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 41.25 BY 1
     FGCOLOR 1  NO-UNDO.
DEFINE VARIABLE v-attr-mandatory-gds-exp-wayb AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 28 BY 1 NO-UNDO.
DEFINE VARIABLE v-attr-mandatory-gds-in-wayb AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 28 BY 1 NO-UNDO.
DEFINE VARIABLE v-attr-mandatory-gds-ret-wayb AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 28 BY 1 NO-UNDO.
DEFINE VARIABLE v-reasons-for-return AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 28 BY 1 NO-UNDO.
DEFINE VARIABLE v-reasons-write-off AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 28 BY 1 NO-UNDO.
DEFINE VARIABLE v-attr-PN AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 28 BY 1 NO-UNDO.
DEFINE VARIABLE v-back-date AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 66.13 BY 1 NO-UNDO.
DEFINE VARIABLE v-edit-fact-wayb AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 66.13 BY 1 NO-UNDO.
DEFINE VARIABLE v-exc-max-qnty AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 66.13 BY 1 NO-UNDO.
DEFINE VARIABLE v-gtd-to-imp-prod AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 71 BY 1 NO-UNDO.
DEFINE VARIABLE v-inv-ship AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 66.13 BY 1 NO-UNDO.
DEFINE VARIABLE v-neg-ask AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 66.13 BY 1 NO-UNDO.
DEFINE VARIABLE v-not-ord AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 66.13 BY 1 NO-UNDO.
DEFINE VARIABLE v-reasonm AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 66.13 BY 1 NO-UNDO.
DEFINE VARIABLE v-reasonme AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 21.75 BY 1 NO-UNDO.
DEFINE VARIABLE v-round-vat-sum AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 66.13 BY 1 NO-UNDO.
DEFINE VARIABLE v-vat-goods AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 66.13 BY 1 NO-UNDO.
DEFINE IMAGE I-attr-mandatory-gds-exp-wayb
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.
DEFINE IMAGE I-attr-mandatory-gds-in-wayb
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.
DEFINE IMAGE I-attr-mandatory-gds-ret-wayb
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.
DEFINE IMAGE I-reasons-for-return
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.
DEFINE IMAGE I-reasons-write-off
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.
DEFINE IMAGE I-attr-PN
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.
DEFINE IMAGE I-back-date
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.
DEFINE IMAGE I-edit-fact-wayb
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.
DEFINE IMAGE I-exc-max-qnty
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.
DEFINE IMAGE I-gtd-to-imp-prod
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.
DEFINE IMAGE I-inv-ship
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.
DEFINE IMAGE I-neg-ask
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.
DEFINE IMAGE I-not-ord
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.
DEFINE IMAGE I-reasonm
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.
DEFINE IMAGE I-reasonme
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.
DEFINE IMAGE I-round-vat-sum
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.
DEFINE IMAGE I-vat-goods
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.
DEFINE VARIABLE back-date AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2 BY 1 NO-UNDO.
DEFINE VARIABLE edit-fact-wayb AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY 1 NO-UNDO.
DEFINE VARIABLE exc-max-qnty AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY 1 NO-UNDO.
DEFINE VARIABLE gtd-to-imp-prod AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY 1 NO-UNDO.
DEFINE VARIABLE inv-ship AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY 1 NO-UNDO.
DEFINE VARIABLE neg-ask AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY 1 NO-UNDO.
DEFINE VARIABLE not-ord AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY 1 NO-UNDO.
DEFINE VARIABLE reasonm AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY 1 NO-UNDO.
DEFINE VARIABLE round-vat-sum AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY 1 NO-UNDO.
DEFINE VARIABLE vat-goods AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY 1 NO-UNDO.
DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     B-quit AT ROW 1 COL 11
     B-Help AT ROW 1 COL 90.5
     button-1 AT ROW 1.08 COL 21.13 WIDGET-ID 244
     button-2 AT ROW 1.08 COL 34.63 WIDGET-ID 246
     F-button-1 AT ROW 1.33 COL 20.38 COLON-ALIGNED NO-LABEL WIDGET-ID 350
     F-button-2 AT ROW 1.33 COL 33.63 COLON-ALIGNED NO-LABEL WIDGET-ID 348
     RECT-3 AT ROW 2 COL 1 WIDGET-ID 248
     SPACE(0.62) SKIP(1.87)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Настройки для накладных"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON B-quit WIDGET-ID 100.
DEFINE FRAME page-2
     B-11 AT ROW 1.13 COL 2.88 WIDGET-ID 238
     reasonm AT ROW 1.13 COL 6 WIDGET-ID 236
     B-14 AT ROW 2.17 COL 5.75 WIDGET-ID 260
     B-ex AT ROW 2.17 COL 31.13 WIDGET-ID 268
     back-date AT ROW 3.25 COL 6 WIDGET-ID 248
     B-12 AT ROW 3.29 COL 2.88 WIDGET-ID 244
     B-13 AT ROW 4.42 COL 2.88 WIDGET-ID 252
     not-ord AT ROW 4.42 COL 6 WIDGET-ID 254
     B-15 AT ROW 5.46 COL 2.88 WIDGET-ID 270
     neg-ask AT ROW 5.46 COL 6 WIDGET-ID 274
     B-16 AT ROW 6.58 COL 2.88 WIDGET-ID 278
     vat-goods AT ROW 6.58 COL 6 WIDGET-ID 282
     B-17 AT ROW 7.75 COL 2.88 WIDGET-ID 286
     inv-ship AT ROW 7.75 COL 6 WIDGET-ID 290
     B-18 AT ROW 9 COL 2.88 WIDGET-ID 294
     round-vat-sum AT ROW 9 COL 6 WIDGET-ID 298
     B-19 AT ROW 10.25 COL 2.88 WIDGET-ID 302
     gtd-to-imp-prod AT ROW 10.25 COL 6 WIDGET-ID 306
     B-20 AT ROW 11.5 COL 2.88 WIDGET-ID 310
     exc-max-qnty AT ROW 11.5 COL 6 WIDGET-ID 314
     B-22 AT ROW 13.75 COL 6.88 WIDGET-ID 484
     B-set_attr-PN AT ROW 13.75 COL 39 WIDGET-ID 480
     attr-PN AT ROW 13.75 COL 42 NO-LABEL WIDGET-ID 492
     B-23 AT ROW 14.75 COL 6.88 WIDGET-ID 504
     B-set_attr-mandatory-gds-in-wayb AT ROW 14.75 COL 39 WIDGET-ID 506
     attr-mandatory-gds-in-wayb AT ROW 14.75 COL 42 NO-LABEL WIDGET-ID 528
     B-24 AT ROW 15.75 COL 6.88 WIDGET-ID 512
     B-set_attr-mandatory-gds-ret-wayb AT ROW 15.75 COL 39 WIDGET-ID 514
     attr-mandatory-gds-ret-wayb AT ROW 15.75 COL 42 NO-LABEL WIDGET-ID 530
     B-25 AT ROW 16.75 COL 6.88 WIDGET-ID 520
     B-set_attr-mandatory-gds-exp-wayb AT ROW 16.75 COL 39 WIDGET-ID 522
     attr-mandatory-gds-exp-wayb AT ROW 16.75 COL 42 NO-LABEL WIDGET-ID 532
     B-26 AT ROW 18.8 COL 2.88 WIDGET-ID 620
     B-set_reasons-for-return AT ROW 18.8 COL 35 WIDGET-ID 622
     reasons-for-return AT ROW 18.8 COL 38 NO-LABEL WIDGET-ID 632
     B-27 AT ROW 19.85 COL 2.88 WIDGET-ID 620
     B-set_reasons-write-off AT ROW 19.85 COL 35 WIDGET-ID 622
     reasons-write-off AT ROW 19.85 COL 38 NO-LABEL WIDGET-ID 632
     B-21 AT ROW 17.79 COL 2.88 WIDGET-ID 496
     edit-fact-wayb AT ROW 17.79 COL 6 WIDGET-ID 498
     v-reasonm AT ROW 1.13 COL 8.75 NO-LABEL WIDGET-ID 242
     v-reasonme AT ROW 2.17 COL 6.75 COLON-ALIGNED NO-LABEL WIDGET-ID 264
     reasonme AT ROW 2.25 COL 32.75 COLON-ALIGNED NO-LABEL WIDGET-ID 266
     v-back-date AT ROW 3.38 COL 6.5 COLON-ALIGNED NO-LABEL WIDGET-ID 250
     v-not-ord AT ROW 4.42 COL 6.75 COLON-ALIGNED NO-LABEL WIDGET-ID 258
     v-neg-ask AT ROW 5.46 COL 6.75 COLON-ALIGNED NO-LABEL WIDGET-ID 276
     v-vat-goods AT ROW 6.58 COL 6.75 COLON-ALIGNED NO-LABEL WIDGET-ID 284
     v-inv-ship AT ROW 7.75 COL 6.5 COLON-ALIGNED NO-LABEL WIDGET-ID 292
     v-round-vat-sum AT ROW 9 COL 6.5 COLON-ALIGNED NO-LABEL WIDGET-ID 300
     v-gtd-to-imp-prod AT ROW 10.25 COL 6.5 COLON-ALIGNED NO-LABEL WIDGET-ID 308
     v-exc-max-qnty AT ROW 11.5 COL 8.5 NO-LABEL WIDGET-ID 316
     v-attr-PN AT ROW 13.75 COL 8.5 COLON-ALIGNED NO-LABEL WIDGET-ID 494
     v-attr-mandatory-gds-in-wayb AT ROW 14.75 COL 8.5 COLON-ALIGNED NO-LABEL WIDGET-ID 510
     v-attr-mandatory-gds-ret-wayb AT ROW 15.75 COL 8.5 COLON-ALIGNED NO-LABEL WIDGET-ID 518
     v-attr-mandatory-gds-exp-wayb AT ROW 16.75 COL 8.5 COLON-ALIGNED NO-LABEL WIDGET-ID 526
     v-edit-fact-wayb AT ROW 17.79 COL 6.5 COLON-ALIGNED NO-LABEL WIDGET-ID 502
     "Обязательные атрибуты накладных:" VIEW-AS TEXT
          SIZE 36 BY .67 AT ROW 12.75 COL 1 WIDGET-ID 534
     I-reasonm AT ROW 1.13 COL 1 WIDGET-ID 240
     I-back-date AT ROW 3.29 COL 1.5 WIDGET-ID 246
     I-not-ord AT ROW 4.42 COL 1 WIDGET-ID 256
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY
         SIDE-LABELS NO-UNDERLINE THREE-D
         AT COL 1.63 ROW 2.33
         SIZE 99 BY 20.67 WIDGET-ID 300.
DEFINE FRAME page-2
     I-reasonme AT ROW 2.17 COL 3.88 WIDGET-ID 262
     I-neg-ask AT ROW 5.46 COL 1 WIDGET-ID 272
     I-vat-goods AT ROW 6.58 COL 1 WIDGET-ID 280
     I-inv-ship AT ROW 7.75 COL 1 WIDGET-ID 288
     I-round-vat-sum AT ROW 9 COL 1 WIDGET-ID 296
     I-gtd-to-imp-prod AT ROW 10.25 COL 1 WIDGET-ID 304
     I-exc-max-qnty AT ROW 11.5 COL 1 WIDGET-ID 312
     I-attr-PN AT ROW 13.75 COL 5 WIDGET-ID 486
     I-edit-fact-wayb AT ROW 17.79 COL 1 WIDGET-ID 500
     I-attr-mandatory-gds-in-wayb AT ROW 14.75 COL 5 WIDGET-ID 508
     I-attr-mandatory-gds-ret-wayb AT ROW 15.75 COL 5 WIDGET-ID 516
     I-attr-mandatory-gds-exp-wayb AT ROW 16.75 COL 5 WIDGET-ID 524
     v-reasons-for-return AT ROW 18.8 COL 4.5 COLON-ALIGNED NO-LABEL WIDGET-ID 626
     I-reasons-for-return AT ROW 18.8 COL 1 WIDGET-ID 624
     v-reasons-write-off AT ROW 19.85 COL 4.5 COLON-ALIGNED NO-LABEL WIDGET-ID 626
     I-reasons-write-off AT ROW 19.85 COL 1 WIDGET-ID 624
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY
         SIDE-LABELS NO-UNDERLINE THREE-D
         AT COL 1.63 ROW 2.33
         SIZE 99 BY 20.67 WIDGET-ID 300.
DEFINE FRAME page-1
     B-1 AT ROW 1.08 COL 3.13 WIDGET-ID 80
     date-close-period AT ROW 1.08 COL 4.63 COLON-ALIGNED NO-LABEL WIDGET-ID 48
     B-2 AT ROW 2.13 COL 3.13 WIDGET-ID 82
     stfactdt AT ROW 2.13 COL 6.63 WIDGET-ID 46
     B-3 AT ROW 3.17 COL 3.13 WIDGET-ID 84
     intprmvq AT ROW 3.17 COL 6.63 WIDGET-ID 52
     B-4 AT ROW 4.21 COL 3.13 WIDGET-ID 86
     minusprt AT ROW 4.21 COL 6.63 WIDGET-ID 58
     part-prc AT ROW 5.17 COL 3.13 WIDGET-ID 182
     curcli AT ROW 6 COL 3.13 WIDGET-ID 148
     B-7 AT ROW 6.88 COL 3.13 WIDGET-ID 92
     avail-on-date AT ROW 6.88 COL 6.63 WIDGET-ID 96
     nocurbas AT ROW 7.83 COL 60 NO-LABEL WIDGET-ID 124
     rnd-znk AT ROW 9.88 COL 46.5 COLON-ALIGNED NO-LABEL WIDGET-ID 214
     chk-prs AT ROW 9.88 COL 3.13 WIDGET-ID 130
     convimp AT ROW 10.79 COL 3.13 WIDGET-ID 134
     noapndsc AT ROW 10.79 COL 48.5 WIDGET-ID 176
     is-bcdoc AT ROW 11.67 COL 3.13 WIDGET-ID 156
     is-ov AT ROW 11.67 COL 48.5 WIDGET-ID 164
     B-9 AT ROW 12.58 COL 3.13 WIDGET-ID 108
     proxycrd AT ROW 12.58 COL 6.63 WIDGET-ID 112
     vat-sum AT ROW 13.54 COL 3.13 WIDGET-ID 232
     B-5 AT ROW 14.33 COL 3.13 WIDGET-ID 88
     type-vat AT ROW 14.33 COL 41.5 NO-LABEL WIDGET-ID 68
     vat-ext AT ROW 14.33 COL 60.5 COLON-ALIGNED NO-LABEL WIDGET-ID 226
     B-6 AT ROW 15.38 COL 3.13 WIDGET-ID 90
     type-slt AT ROW 15.38 COL 41.5 NO-LABEL WIDGET-ID 74
     slt-ext AT ROW 15.38 COL 60.5 COLON-ALIGNED NO-LABEL WIDGET-ID 220
     multdtyp AT ROW 16.33 COL 3.13 WIDGET-ID 170
     prc-exp AT ROW 17.21 COL 1.13 COLON-ALIGNED NO-LABEL WIDGET-ID 210
     B-8 AT ROW 18.29 COL 3.13 WIDGET-ID 100
     factorrt AT ROW 18.29 COL 5 COLON-ALIGNED NO-LABEL WIDGET-ID 102
     B-10 AT ROW 19.38 COL 3.13 WIDGET-ID 238
     inp_sum AT ROW 19.38 COL 6.63 WIDGET-ID 236
     v-date-close-period AT ROW 1.08 COL 19.13 NO-LABEL WIDGET-ID 6
     v-stfactdt AT ROW 2.13 COL 9.38 NO-LABEL WIDGET-ID 18
     v-intprmvq AT ROW 3.17 COL 9.38 NO-LABEL WIDGET-ID 54
     v-minusprt AT ROW 4.21 COL 9.38 NO-LABEL WIDGET-ID 60
     v-part-prc AT ROW 5.17 COL 6.63 NO-LABEL WIDGET-ID 184
     v-curcli AT ROW 6 COL 6.63 NO-LABEL WIDGET-ID 150
     v-avail-on-date AT ROW 6.88 COL 9.38 NO-LABEL WIDGET-ID 98
     v-nocurbas AT ROW 7.83 COL 3.13 NO-LABEL WIDGET-ID 122
     v-rnd-znk AT ROW 9.88 COL 52.5 NO-LABEL WIDGET-ID 216
     v-chk-prs AT ROW 9.88 COL 5.75 NO-LABEL WIDGET-ID 132
     v-convimp AT ROW 10.79 COL 5.75 NO-LABEL WIDGET-ID 138
     v-noapndsc AT ROW 10.8 COL 52.25 NO-LABEL WIDGET-ID 178
     v-is-bcdoc AT ROW 11.67 COL 5.75 NO-LABEL WIDGET-ID 160
     v-is-ov AT ROW 11.67 COL 52.13 NO-LABEL WIDGET-ID 166
     v-proxycrd AT ROW 12.58 COL 9.00 NO-LABEL WIDGET-ID 114
     v-vat-sum AT ROW 13.54 COL 6.63 NO-LABEL WIDGET-ID 234
     v-type-vat AT ROW 14.33 COL 6.5 NO-LABEL WIDGET-ID 66
     v-vat-ext AT ROW 14.33 COL 75 NO-LABEL WIDGET-ID 228
     v-type-slt AT ROW 15.38 COL 6.5 NO-LABEL WIDGET-ID 78
     v-slt-ext AT ROW 15.38 COL 75 NO-LABEL WIDGET-ID 222
     v-multdtyp AT ROW 16.33 COL 6.63 NO-LABEL WIDGET-ID 172
     v-prc-exp AT ROW 17.21 COL 10.88 NO-LABEL WIDGET-ID 208
     v-factorrt AT ROW 18.29 COL 13.13 NO-LABEL WIDGET-ID 106
     v-inp_sum AT ROW 19.38 COL 9.38 NO-LABEL WIDGET-ID 242
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY
         SIDE-LABELS NO-UNDERLINE THREE-D
         AT COL 1.5 ROW 2.25
         SIZE 99 BY 20 WIDGET-ID 200.
DEFINE FRAME page-1
     I-date-close-period AT ROW 1.08 COL 1.25 WIDGET-ID 10
     I-stfactdt AT ROW 2.13 COL 1 WIDGET-ID 34
     I-intprmvq AT ROW 3.17 COL 1 WIDGET-ID 50
     I-minusprt AT ROW 4.21 COL 1 WIDGET-ID 56
     I-part-prc AT ROW 5.17 COL 1 WIDGET-ID 180
     I-curcli AT ROW 6 COL 1 WIDGET-ID 146
     I-avail-on-date AT ROW 6.88 COL 1 WIDGET-ID 94
     I-nocurbas AT ROW 7.83 COL 1 WIDGET-ID 118
     I-chk-prs AT ROW 9.85 COL 1 WIDGET-ID 128
     I-rnd-znk AT ROW 9.85 COL 46 WIDGET-ID 212
     I-convimp AT ROW 10.79 COL 1 WIDGET-ID 136
     I-noapndsc AT ROW 10.79 COL 46 WIDGET-ID 174
     I-is-bcdoc AT ROW 11.67 COL 1 WIDGET-ID 158
     I-is-ov AT ROW 11.67 COL 46 WIDGET-ID 162
     I-proxycrd AT ROW 12.58 COL 1 WIDGET-ID 110
     I-vat-sum AT ROW 13.46 COL 1 WIDGET-ID 230
     I-type-vat AT ROW 14.33 COL 1 WIDGET-ID 64
     I-vat-ext AT ROW 14.33 COL 60 WIDGET-ID 224
     I-type-slt AT ROW 15.33 COL 1 WIDGET-ID 72
     I-slt-ext AT ROW 15.38 COL 60 WIDGET-ID 218
     I-multdtyp AT ROW 16.38 COL 1 WIDGET-ID 168
     I-prc-exp AT ROW 17.21 COL 1 WIDGET-ID 204
     I-factorrt AT ROW 18.25 COL 1 WIDGET-ID 104
     I-inp_sum AT ROW 19.38 COL 1 WIDGET-ID 240
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY
         SIDE-LABELS NO-UNDERLINE THREE-D
         AT COL 1.5 ROW 2.25
         SIZE 99 BY 20 WIDGET-ID 200.
ASSIGN FRAME page-1:FRAME = FRAME Dialog-Frame:HANDLE
       FRAME page-2:FRAME = FRAME Dialog-Frame:HANDLE.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       v-avail-on-date:READ-ONLY IN FRAME page-1        = TRUE.
ASSIGN
       v-chk-prs:READ-ONLY IN FRAME page-1        = TRUE.
ASSIGN
       v-convimp:READ-ONLY IN FRAME page-1        = TRUE.
ASSIGN
       v-curcli:READ-ONLY IN FRAME page-1        = TRUE.
ASSIGN
       v-date-close-period:READ-ONLY IN FRAME page-1        = TRUE.
ASSIGN
       v-factorrt:READ-ONLY IN FRAME page-1        = TRUE.
ASSIGN
       v-inp_sum:READ-ONLY IN FRAME page-1        = TRUE.
ASSIGN
       v-intprmvq:READ-ONLY IN FRAME page-1        = TRUE.
ASSIGN
       v-is-bcdoc:READ-ONLY IN FRAME page-1        = TRUE.
ASSIGN
       v-is-ov:READ-ONLY IN FRAME page-1        = TRUE.
ASSIGN
       v-minusprt:READ-ONLY IN FRAME page-1        = TRUE.
ASSIGN
       v-multdtyp:READ-ONLY IN FRAME page-1        = TRUE.
ASSIGN
       v-noapndsc:READ-ONLY IN FRAME page-1        = TRUE.
ASSIGN
       v-nocurbas:READ-ONLY IN FRAME page-1        = TRUE.
ASSIGN
       v-part-prc:READ-ONLY IN FRAME page-1        = TRUE.
ASSIGN
       v-prc-exp:READ-ONLY IN FRAME page-1        = TRUE.
ASSIGN
       v-proxycrd:READ-ONLY IN FRAME page-1        = TRUE.
ASSIGN
       v-rnd-znk:READ-ONLY IN FRAME page-1        = TRUE.
ASSIGN
       v-slt-ext:READ-ONLY IN FRAME page-1        = TRUE.
ASSIGN
       v-stfactdt:READ-ONLY IN FRAME page-1        = TRUE.
ASSIGN
       v-type-slt:READ-ONLY IN FRAME page-1        = TRUE.
ASSIGN
       v-type-vat:READ-ONLY IN FRAME page-1        = TRUE.
ASSIGN
       v-vat-ext:READ-ONLY IN FRAME page-1        = TRUE.
ASSIGN
       v-vat-sum:READ-ONLY IN FRAME page-1        = TRUE.
ASSIGN
       attr-mandatory-gds-exp-wayb:READ-ONLY IN FRAME page-2        = TRUE.
ASSIGN
       attr-mandatory-gds-in-wayb:READ-ONLY IN FRAME page-2        = TRUE.
ASSIGN
       attr-mandatory-gds-ret-wayb:READ-ONLY IN FRAME page-2        = TRUE.
ASSIGN
       reasons-for-return:READ-ONLY IN FRAME page-2        = TRUE.
ASSIGN
       reasons-write-off:READ-ONLY IN FRAME page-2        = TRUE.
ASSIGN
       attr-PN:READ-ONLY IN FRAME page-2        = TRUE.
ASSIGN
       v-attr-mandatory-gds-exp-wayb:READ-ONLY IN FRAME page-2        = TRUE.
ASSIGN
       v-attr-mandatory-gds-in-wayb:READ-ONLY IN FRAME page-2        = TRUE.
ASSIGN
       v-attr-mandatory-gds-ret-wayb:READ-ONLY IN FRAME page-2        = TRUE.
ASSIGN
       v-reasons-for-return:READ-ONLY IN FRAME page-2        = TRUE.
ASSIGN
       v-reasons-write-off:READ-ONLY IN FRAME page-2        = TRUE.
ASSIGN
       v-attr-PN:READ-ONLY IN FRAME page-2        = TRUE.
ASSIGN
       v-back-date:READ-ONLY IN FRAME page-2        = TRUE.
ASSIGN
       v-edit-fact-wayb:READ-ONLY IN FRAME page-2        = TRUE.
ASSIGN
       v-exc-max-qnty:READ-ONLY IN FRAME page-2        = TRUE.
ASSIGN
       v-gtd-to-imp-prod:READ-ONLY IN FRAME page-2        = TRUE.
ASSIGN
       v-inv-ship:READ-ONLY IN FRAME page-2        = TRUE.
ASSIGN
       v-neg-ask:READ-ONLY IN FRAME page-2        = TRUE.
ASSIGN
       v-not-ord:READ-ONLY IN FRAME page-2        = TRUE.
ASSIGN
       v-reasonm:READ-ONLY IN FRAME page-2        = TRUE.
ASSIGN
       v-reasonme:READ-ONLY IN FRAME page-2        = TRUE.
ASSIGN
       v-round-vat-sum:READ-ONLY IN FRAME page-2        = TRUE.
ASSIGN
       v-vat-goods:READ-ONLY IN FRAME page-2        = TRUE.
ON GO OF FRAME Dialog-Frame
DO:
  run save-proc in this-procedure no-error.
  if error-status :error then return no-apply.
END.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF B-1 IN FRAME page-1
DO:
  run gbl/v-taobj.w
      ('nakl_par':U,
       "date-close-period"
       ).
END.
ON CHOOSE OF B-10 IN FRAME page-1
DO:
  run gbl/v-taobj.w
      ('nakl_par':U,
       "inp_sum"
       ).
END.
ON CHOOSE OF B-11 IN FRAME page-2
DO:
  run gbl/v-taobj.w
      ('nakl_par':U,
       "reasonm"
       ).
END.
ON CHOOSE OF B-12 IN FRAME page-2
DO:
  run gbl/v-taobj.w
      ('nakl_par':U,
       "back-date"
       ).
END.
ON CHOOSE OF B-13 IN FRAME page-2
DO:
  run gbl/v-taobj.w
      ('nakl_par':U,
       "not-ord"
       ).
END.
ON CHOOSE OF B-14 IN FRAME page-2
DO:
  run gbl/v-taobj.w
      ('nakl_par':U,
       "reasonme"
       ).
END.
ON CHOOSE OF B-15 IN FRAME page-2
DO:
  run gbl/v-taobj.w
      ('nakl_par':U,
       "neg-ask"
       ).
END.
ON CHOOSE OF B-16 IN FRAME page-2
DO:
  run gbl/v-taobj.w
      ('nakl_par':U,
       "vat-goods"
       ).
END.
ON CHOOSE OF B-17 IN FRAME page-2
DO:
  run gbl/v-taobj.w
      ('nakl_par':U,
       "inv-ship"
       ).
END.
ON CHOOSE OF B-18 IN FRAME page-2
DO:
  run gbl/v-taobj.w
      ('nakl_par':U,
       "round-vat-sum"
       ).
END.
ON CHOOSE OF B-19 IN FRAME page-2
DO:
  run gbl/v-taobj.w
      ('nakl_par':U,
       "gtd-to-imp-prod"
       ).
END.
ON CHOOSE OF B-2 IN FRAME page-1
DO:
  run gbl/v-taobj.w
      ('nakl_par':U,
       "stfactdt"
       ).
END.
ON CHOOSE OF B-20 IN FRAME page-2
DO:
  run gbl/v-taobj.w
      ('nakl_par':U,
       "exc-max-qnty"
       ).
END.
ON CHOOSE OF B-21 IN FRAME page-2
DO:
  run gbl/v-taobj.w
      ('nakl_par':U,
       "exc-max-qnty"
       ).
END.
ON CHOOSE OF B-22 IN FRAME page-2
DO:
  run gbl/v-taobj.w
      ('nakl_par':U,
       "attr-PN"
       ).
END.
ON CHOOSE OF B-23 IN FRAME page-2
DO:
  run gbl/v-taobj.w
      ('nakl_par':U,
       "attr-mandatory-gds-in-wayb"
       ).
END.
ON CHOOSE OF B-24 IN FRAME page-2
DO:
  run gbl/v-taobj.w
      ('nakl_par':U,
       "attr-mandatory-gds-ret-wayb"
       ).
END.
ON CHOOSE OF B-25 IN FRAME page-2
DO:
  run gbl/v-taobj.w
      ('nakl_par':U,
       "attr-mandatory-gds-exp-wayb"
       ).
END.
ON CHOOSE OF B-26 IN FRAME page-2
DO:
  run gbl/v-taobj.w
      ('nakl_par':U,
       "reasons-for-return"
       ).
END.
ON CHOOSE OF B-27 IN FRAME page-2
DO:
  run gbl/v-taobj.w
      ('nakl_par':U,
       "reasons-write-off"
       ).
END.
ON CHOOSE OF B-3 IN FRAME page-1
DO:
  run gbl/v-taobj.w
      ('nakl_par':U,
       "intprmvq"
       ).
END.
ON CHOOSE OF B-4 IN FRAME page-1
DO:
  run gbl/v-taobj.w
      ('nakl_par':U,
       "minusprt"
       ).
END.
ON CHOOSE OF B-5 IN FRAME page-1
DO:
  run gbl/v-taobj.w
      ('nakl_par':U,
       "type-vat"
       ).
END.
ON CHOOSE OF B-6 IN FRAME page-1
DO:
  run gbl/v-taobj.w
      ('nakl_par':U,
       "type-slt"
       ).
END.
ON CHOOSE OF B-7 IN FRAME page-1
DO:
  run gbl/v-taobj.w
      ('nakl_par':U,
       "avail-on-date"
       ).
END.
ON CHOOSE OF B-8 IN FRAME page-1
DO:
  run gbl/v-taobj.w
      ('nakl_par':U,
       "factorrt"
       ).
END.
ON CHOOSE OF B-9 IN FRAME page-1
DO:
  run gbl/v-taobj.w
      ('nakl_par':U,
       "proxycrd"
       ).
END.
ON CHOOSE OF B-ex IN FRAME page-2
DO:
    run select-col-type in this-procedure.
END.
ON CHOOSE OF B-set_attr-mandatory-gds-exp-wayb IN FRAME page-2
DO:
  run select-attr-mandat-wayb in this-procedure
    ( input v-list-attr-mandatory-gds-exp-wayb,
      input v-list-attr-mandatory-gds-exp-wayb-full,
      input-output attr-mandatory-gds-exp-wayb
    )
    .
  assign attr-mandatory-gds-exp-wayb:screen-value = attr-mandatory-gds-exp-wayb.
END.
ON CHOOSE OF B-set_attr-mandatory-gds-in-wayb IN FRAME page-2
DO:
  run select-attr-mandat-wayb in this-procedure
    ( input v-list-attr-mandatory-gds-in-wayb,
      input v-list-attr-mandatory-gds-in-wayb-full,
      input-output attr-mandatory-gds-in-wayb
    )
    .
  assign attr-mandatory-gds-in-wayb:screen-value = attr-mandatory-gds-in-wayb.
END.
ON CHOOSE OF B-set_attr-mandatory-gds-ret-wayb IN FRAME page-2
DO:
  run select-attr-mandat-wayb in this-procedure
    ( input v-list-attr-mandatory-gds-ret-wayb,
      input v-list-attr-mandatory-gds-ret-wayb-full,
      input-output attr-mandatory-gds-ret-wayb
    )
    .
  assign attr-mandatory-gds-ret-wayb:screen-value = attr-mandatory-gds-ret-wayb.
END.
ON CHOOSE OF B-set_reasons-for-return IN FRAME page-2
DO:
  run select-reasons-for-return  in this-procedure
    ( input v-list-reasons-for-return,
      input v-list-reasons-for-return-full,
      input-output reasons-for-return
    )
    .
  assign reasons-for-return:screen-value = reasons-for-return.
END.
ON CHOOSE OF B-set_reasons-write-off IN FRAME page-2
DO:
  define variable varlog as logical no-undo .
define variable vss-include-info7 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_write-off_chgfact':U
    ,input  'object':U
    ,input  v-cntxt-host-code-obj
    ,input  v-cntxt-obj-type
    ,input  v-cntxt-obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output varlog
    )  .
end.
  if  varlog then do:
  run select-reasons-write-off
    ( input v-list-reasons-write-off,
      input v-list-reasons-write-off-full,
      input-output reasons-write-off
    )
    .
  assign reasons-write-off:screen-value = reasons-write-off.
  end.
END.
ON CHOOSE OF B-set_attr-PN IN FRAME page-2
DO:
  run select-attr-mandat-wayb in this-procedure
    ( input v-list-attr-PN,
      input v-list-attr-PN-full,
      input-output attr-PN
    )
    .
  assign attr-PN:screen-value = attr-PN.
END.
ON CHOOSE OF button-1 IN FRAME Dialog-Frame
DO:
  HIDE FRAME page-2.
  VIEW FRAME page-1.
  button-1:LOAD-IMAGE-UP("adeicon\ts-up":U)        in frame Dialog-Frame .
  button-2:LOAD-IMAGE-Up("adeicon\ts-down":U)      in frame Dialog-Frame .
  F-button-1:fgcolor = 1   .
  f-button-2:fgcolor = ? .
END.
ON CHOOSE OF button-2 IN FRAME Dialog-Frame
DO:
    HIDE FRAME page-1.
    VIEW FRAME page-2.
    button-2:LOAD-IMAGE-UP("adeicon\ts-up":U)        in frame Dialog-Frame .
    button-1:LOAD-IMAGE-Up("adeicon\ts-down":U)      in frame Dialog-Frame .
    F-button-2:fgcolor = 1   .
    f-button-1:fgcolor = ? .
END.
ON MOUSE-SELECT-CLICK OF I-attr-mandatory-gds-exp-wayb IN FRAME page-2
DO:
  MESSAGE I-attr-mandatory-gds-exp-wayb:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-attr-mandatory-gds-in-wayb IN FRAME page-2
DO:
  MESSAGE I-attr-mandatory-gds-in-wayb:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-attr-mandatory-gds-ret-wayb IN FRAME page-2
DO:
  MESSAGE I-attr-mandatory-gds-ret-wayb:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-reasons-for-return IN FRAME page-2
DO:
  MESSAGE I-reasons-for-return:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-reasons-write-off IN FRAME page-2
DO:
  MESSAGE I-reasons-write-off:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-attr-PN IN FRAME page-2
DO:
  MESSAGE I-attr-PN:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-avail-on-date IN FRAME page-1
DO:
  MESSAGE I-avail-on-date:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-back-date IN FRAME page-2
DO:
  MESSAGE I-back-date:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-chk-prs IN FRAME page-1
DO:
  MESSAGE I-chk-prs:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-convimp IN FRAME page-1
DO:
  MESSAGE I-convimp:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-curcli IN FRAME page-1
DO:
  MESSAGE I-curcli:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-date-close-period IN FRAME page-1
DO:
  MESSAGE I-date-close-period:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-edit-fact-wayb IN FRAME page-2
DO:
  MESSAGE I-edit-fact-wayb:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-exc-max-qnty IN FRAME page-2
DO:
  MESSAGE I-exc-max-qnty:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-factorrt IN FRAME page-1
DO:
  MESSAGE I-factorrt:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-gtd-to-imp-prod IN FRAME page-2
DO:
  MESSAGE I-gtd-to-imp-prod:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-inp_sum IN FRAME page-1
DO:
  MESSAGE I-inp_sum:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-intprmvq IN FRAME page-1
DO:
  MESSAGE I-intprmvq:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-inv-ship IN FRAME page-2
DO:
  MESSAGE I-inv-ship:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-is-bcdoc IN FRAME page-1
DO:
  MESSAGE I-is-bcdoc:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-is-ov IN FRAME page-1
DO:
  MESSAGE I-is-ov:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-minusprt IN FRAME page-1
DO:
  MESSAGE I-minusprt:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-multdtyp IN FRAME page-1
DO:
  MESSAGE I-multdtyp:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-neg-ask IN FRAME page-2
DO:
  MESSAGE I-neg-ask:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-noapndsc IN FRAME page-1
DO:
  MESSAGE I-noapndsc:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-nocurbas IN FRAME page-1
DO:
  MESSAGE I-nocurbas:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-not-ord IN FRAME page-2
DO:
  MESSAGE I-not-ord:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-part-prc IN FRAME page-1
DO:
  MESSAGE I-part-prc:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-prc-exp IN FRAME page-1
DO:
  MESSAGE I-prc-exp:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-proxycrd IN FRAME page-1
DO:
  MESSAGE I-proxycrd:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-reasonm IN FRAME page-2
DO:
  MESSAGE I-reasonm:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-reasonme IN FRAME page-2
DO:
  MESSAGE I-reasonme:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-rnd-znk IN FRAME page-1
DO:
  MESSAGE I-rnd-znk:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-round-vat-sum IN FRAME page-2
DO:
  MESSAGE I-round-vat-sum:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-slt-ext IN FRAME page-1
DO:
  MESSAGE I-slt-ext:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-stfactdt IN FRAME page-1
DO:
  MESSAGE I-stfactdt:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-type-slt IN FRAME page-1
DO:
  MESSAGE I-type-slt:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-type-vat IN FRAME page-1
DO:
  MESSAGE I-type-vat:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-vat-ext IN FRAME page-1
DO:
  MESSAGE I-vat-ext:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-vat-goods IN FRAME page-2
DO:
  MESSAGE I-vat-goods:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-vat-sum IN FRAME page-1
DO:
  MESSAGE I-vat-sum:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame Dialog-Frame
do:
  run gbl/app_help.p
    (input this-procedure :file-name
    ,input ''
    ,input ?
    ) no-error.
  if error-status :error then do:
    message
      "Ошибка при вызове помощи"
      error-status :get-message(1)
      view-as alert-box .
  end.
end.
run minbtn-set in this-procedure .
on choose of b-help in frame Dialog-Frame
do:
  apply "help":u to frame Dialog-Frame .
end.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure minbtn-set :
    do
        on error undo, return error return-value
        :
        define variable ii              as integer       no-undo .
        define variable fh              as widget-handle no-undo .
        define variable hh              as widget-handle no-undo .
        define variable v-h             as handle        extent 4 no-undo .
        define variable v-name-button   as character     no-undo .
        define variable v-help-old-x    as decimal       no-undo .
        define variable v-help-old-y    as decimal       no-undo .
        define variable v-help-old-size as decimal       no-undo .
        define variable v-frame-width   as decimal       no-undo .
        define variable jj              as integer       no-undo .
        do
            on error undo, return error
            :
            assign
                v-frame-width = frame Dialog-Frame:width - 0.3
                fh            = frame Dialog-Frame:first-child
                hh            = fh:first-child
                ii            = 1
                .
            do while valid-handle(hh):
                if LOOKUP(lc(hh:name), "b-help,b-print,b-history,b-hist,b-hist-user,b-sch") > 0  then
                do:
                    case lc(hh:name) :
                        when "b-help" then
                            do:
                                hh:load-image-up("cmp/b-help.bmp":u) .
                                hh:load-image-down("cmp/b-help.bmp":u) .
                                hh:load-image-insensitive("cmp/b-help.bmp":u) .
                                hh:TOOLTIP = "Помощь" .
                                v-help-old-x = hh:column .
                                v-help-old-y = hh:row    .
                                v-help-old-size = hh:width .
                                hh:width-chars = 2.5 .
                            end.
                        when "b-print" then
                            do:
                                hh:load-image("cmp/b-print.bmp":u) .
                                hh:TOOLTIP = "Печать" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-history" or
                        when "b-hist" then
                            do:
                                hh:load-image("cmp/b-hist.bmp":u) .
                                hh:TOOLTIP = "История" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-sch" then
                            do:
                                hh:load-image("cmp/b-sch.bmp":u) .
                                hh:TOOLTIP = "Установка Фильтра" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-hist-user" then
                            do:
                                hh:load-image("cmp/b-hist.bmp":u) .
                                hh:TOOLTIP = "История пользователя" .
                                ii = ii + 1 .
                            end.
                    end case.
                end.
                hh = hh:next-sibling.
            end.
            b-help:column = v-frame-width - b-help:width-chars.
            jj = 0.
            repeat ii = 4 to 1 by -1 :
                if valid-handle (v-h[ii] ) then
                do:
                    jj  = jj + 1 .
                    v-h[ii]:column = v-frame-width - b-help:width-chars - ( 3 * jj ).
                    v-h[ii]:row    = v-help-old-y .
                end.
            end.
        end.
    end.
end procedure.
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on ' ' of date-close-period in frame page-1
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.
on delete-character of date-close-period in frame page-1
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.
on ctrl-d of date-close-period in frame page-1
do:
  define variable v-curr-sv-date as date no-undo .
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    run gbl/getcurdt.p
      (output v-curr-sv-date
      ) .
    assign
      self :screen-value = string(v-curr-sv-date) .
    .
  end.
  return no-apply.
end.
on ctrl-b of date-close-period in frame page-1
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      assign
        v-new-sv-date = date( month(v-curr-sv-date), 1, year(v-curr-sv-date))
      .
      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.
  return no-apply .
end.
on ctrl-e of date-close-period in frame page-1
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      run gbl/lastdate.p
        (input  v-curr-sv-date
        ,output v-new-sv-date
        ).
      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.
  return no-apply .
end.
on ctrl-f of date-close-period in frame page-1
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-ok            as logical   no-undo .
    define variable v-curr-sv-date  as date      no-undo .
    define variable v-description   as character no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      run gbl/d-inpday.w
        (input ?
        ,input "Выбор даты"
        ,input v-description
        ,input ""
        ,input-output v-curr-sv-date
        ,output v-ok
        ).
      if v-ok = true
      then do:
        assign
          self :screen-value = string(v-curr-sv-date) .
        .
      end.
    end.
  end.
  return no-apply .
end.
  define MENU m-ed-date11
    MENU-ITEM m-ed-date11-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date11-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date11-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date11-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if date-close-period :POPUP-MENU in frame page-1 = ?
  then do:
    ASSIGN
      date-close-period :POPUP-MENU in frame page-1 = MENU m-ed-date11 :HANDLE
      date-close-period :MENU-MOUSE in frame page-1 = 3
    .
  end.
  define variable v-label-handle11 as handle no-undo .
  assign
    v-label-handle11 = date-close-period :side-label-handle in frame page-1
  .
  if valid-handle (v-label-handle11)
  then do:
    if v-label-handle11 :tooltip = ""
    or v-label-handle11 :tooltip = ?
    then do:
      assign
        v-label-handle11 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date11-1 in menu m-ed-date11 DO:
    apply "ctrl-b":U to date-close-period in frame page-1 .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date11-2 in menu m-ed-date11 DO:
    apply "ctrl-d":U to date-close-period in frame page-1 .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date11-3 in menu m-ed-date11 DO:
    apply "ctrl-e":U to date-close-period in frame page-1 .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date11-4 in menu m-ed-date11 DO:
    apply "ctrl-f":U to date-close-period in frame page-1 .
  END.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
if p-obj-type <> "" then
   frame Dialog-Frame:title = frame Dialog-Frame:title + (if p-obj-type = 'орг':U then " фирма" else " маг") + string(p-obj-code) .
define variable loc#log as logical   no-undo .
define variable vss-include-info12 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  g#db-num
    ,input  g#userid
    ,input  0
    ,input  'actn_nakl-par_lookup':U
    ,input  'object':U
    ,input  v-cntxt-host-code-obj
    ,input  v-cntxt-obj-type
    ,input  v-cntxt-obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output loc#log
    )  .
end.
   if loc#log <> yes then do: return error. end.
    run init-tt.
    RUN proc-init-EX.
    RUN proc-init-attr-PN.
    RUN proc-init-reasons-for-return.
    RUN proc-init-reasons-write-off.
    run enable_UI.
    run init-proc.
    apply "choose" to button-1 .
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
run disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
  HIDE FRAME page-1.
  HIDE FRAME page-2.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY F-button-1 F-button-2
      WITH FRAME Dialog-Frame.
  ENABLE B-exit B-quit B-Help button-1 RECT-3 button-2 F-button-1 F-button-2
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  DISPLAY date-close-period stfactdt intprmvq minusprt part-prc curcli
          avail-on-date nocurbas rnd-znk chk-prs convimp noapndsc is-bcdoc is-ov
          proxycrd vat-sum type-vat vat-ext type-slt slt-ext multdtyp prc-exp
          factorrt inp_sum v-date-close-period v-stfactdt v-intprmvq v-minusprt
          v-part-prc v-curcli v-avail-on-date v-nocurbas v-rnd-znk v-chk-prs
          v-convimp v-noapndsc v-is-bcdoc v-is-ov v-proxycrd v-vat-sum
          v-type-vat v-vat-ext v-type-slt v-slt-ext v-multdtyp v-prc-exp
          v-factorrt v-inp_sum
      WITH FRAME page-1.
  ENABLE B-1 date-close-period I-date-close-period I-stfactdt I-intprmvq
         I-minusprt I-part-prc I-curcli I-avail-on-date I-nocurbas I-chk-prs
         I-rnd-znk I-convimp I-noapndsc I-is-bcdoc I-is-ov I-proxycrd I-vat-sum
         I-type-vat I-vat-ext I-type-slt I-slt-ext I-multdtyp I-prc-exp
         I-factorrt I-inp_sum B-2 stfactdt B-3 intprmvq B-4 minusprt part-prc
         curcli B-7 avail-on-date nocurbas rnd-znk chk-prs convimp noapndsc
         is-bcdoc is-ov B-9 proxycrd vat-sum B-5 type-vat vat-ext B-6 type-slt
         slt-ext multdtyp prc-exp B-8 factorrt B-10 inp_sum v-date-close-period
         v-stfactdt v-intprmvq v-minusprt v-part-prc v-curcli v-avail-on-date
         v-nocurbas v-rnd-znk v-chk-prs v-convimp v-noapndsc v-is-bcdoc v-is-ov
         v-proxycrd v-vat-sum v-type-vat v-vat-ext v-type-slt v-slt-ext
         v-multdtyp v-prc-exp v-factorrt v-inp_sum
      WITH FRAME page-1.
  DISPLAY reasonm back-date not-ord neg-ask vat-goods inv-ship round-vat-sum
          gtd-to-imp-prod exc-max-qnty attr-PN attr-mandatory-gds-in-wayb
          attr-mandatory-gds-ret-wayb attr-mandatory-gds-exp-wayb reasons-for-return edit-fact-wayb
          v-reasonm v-reasonme reasonme v-back-date v-not-ord v-neg-ask reasons-write-off
          v-vat-goods v-inv-ship v-round-vat-sum v-gtd-to-imp-prod
          v-exc-max-qnty v-attr-PN v-attr-mandatory-gds-in-wayb
          v-attr-mandatory-gds-ret-wayb v-attr-mandatory-gds-exp-wayb
          v-edit-fact-wayb v-reasons-for-return v-reasons-write-off
      WITH FRAME page-2.
  ENABLE I-reasonm I-back-date I-not-ord I-reasonme I-neg-ask I-vat-goods
         I-inv-ship I-round-vat-sum I-gtd-to-imp-prod I-exc-max-qnty I-attr-PN
         I-edit-fact-wayb I-attr-mandatory-gds-in-wayb I-reasons-for-return I-reasons-write-off
         I-attr-mandatory-gds-ret-wayb I-attr-mandatory-gds-exp-wayb B-11
         reasonm B-14 B-ex back-date B-12 B-13 not-ord B-15 neg-ask B-16
         vat-goods B-17 inv-ship B-18 round-vat-sum B-19 gtd-to-imp-prod B-20
         exc-max-qnty B-22 B-set_attr-PN attr-PN B-23
         B-set_attr-mandatory-gds-in-wayb attr-mandatory-gds-in-wayb B-24
         B-set_attr-mandatory-gds-ret-wayb attr-mandatory-gds-ret-wayb B-25
         B-set_reasons-for-return reasons-for-return reasons-write-off B-27
         B-set_reasons-write-off B-26
         B-set_attr-mandatory-gds-exp-wayb attr-mandatory-gds-exp-wayb B-21
         edit-fact-wayb v-reasonm v-reasonme reasonme v-back-date v-not-ord
         v-neg-ask v-vat-goods v-inv-ship v-round-vat-sum v-gtd-to-imp-prod
         v-exc-max-qnty v-attr-PN v-attr-mandatory-gds-in-wayb
         v-attr-mandatory-gds-ret-wayb v-attr-mandatory-gds-exp-wayb
         v-edit-fact-wayb v-reasons-for-return v-reasons-write-off
      WITH FRAME page-2.
END PROCEDURE.
PROCEDURE fill-widgets :
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-param-type as character no-undo .
define variable v-param-value as character no-undo .
for each thbjattr_thbj-attr:
  delete thbjattr_thbj-attr.
end.
for each thbjattr_thbj-attr-g:
  delete thbjattr_thbj-attr-g.
end.
for each temp-thbj-attr:
  delete temp-thbj-attr.
end.
run adm/shattri.p (
    input "init":U
  , input p-obj-type
  , input p-obj-code
  , input 'nakl_par':U
  , input "":U
  , output v-value-character
  , output v-value-date
  , output v-value-decimal
  , output v-value-integer
  , output v-value-logical
  , output v-param-type
  , input-output TABLE-HANDLE v-tth
  ) no-error .
if error-status:error then do:
  message
  "Не удалось получить начальные значения настроек" skip
  error-status:get-message(1) return-value
  view-as alert-box error .
  undo, return error .
end.
run adm/shattri.p (
    input "init":U
  , input ""
  , input 0
  , input 'nakl-glob':U
  , input "":U
  , output v-value-character
  , output v-value-date
  , output v-value-decimal
  , output v-value-integer
  , output v-value-logical
  , output v-param-type
  , input-output TABLE-HANDLE v-tthg
  ) no-error .
if error-status:error then do:
  message
  "Не удалось получить начальные значения настроек" skip
  error-status:get-message(1) return-value
  view-as alert-box error .
  undo, return error .
end.
FOR EACH thbjattr_thbj-attr-g
:
IF thbjattr_thbj-attr-g.prop-code = 'nocurbas':U THEN DO:     nocurbas = thbjattr_thbj-attr-g.property-value-character.     nocurbas:private-data in frame page-1 = "recid3=" + string(recid(thbjattr_thbj-attr-g)).     display nocurbas with frame page-1 . END.
IF thbjattr_thbj-attr-g.prop-code = 'chk-prs':U THEN DO:     chk-prs = thbjattr_thbj-attr-g.property-value-logical.     chk-prs:private-data in frame page-1 = "recid3=" + string(recid(thbjattr_thbj-attr-g)).     display chk-prs with frame page-1 . END.
IF thbjattr_thbj-attr-g.prop-code = 'convimp':U THEN DO:     convimp = thbjattr_thbj-attr-g.property-value-logical.     convimp:private-data in frame page-1 = "recid3=" + string(recid(thbjattr_thbj-attr-g)).     display convimp with frame page-1 . END.
IF thbjattr_thbj-attr-g.prop-code = 'curcli':U THEN DO:     curcli = thbjattr_thbj-attr-g.property-value-logical.     curcli:private-data in frame page-1 = "recid3=" + string(recid(thbjattr_thbj-attr-g)).     display curcli with frame page-1 . END.
IF thbjattr_thbj-attr-g.prop-code = 'is-bcdoc':U THEN DO:     is-bcdoc = thbjattr_thbj-attr-g.property-value-logical.     is-bcdoc:private-data in frame page-1 = "recid3=" + string(recid(thbjattr_thbj-attr-g)).     display is-bcdoc with frame page-1 . END.
IF thbjattr_thbj-attr-g.prop-code = 'is-ov':U THEN DO:     is-ov = thbjattr_thbj-attr-g.property-value-logical.     is-ov:private-data in frame page-1 = "recid3=" + string(recid(thbjattr_thbj-attr-g)).     display is-ov with frame page-1 . END.
IF thbjattr_thbj-attr-g.prop-code = 'multdtyp':U THEN DO:     multdtyp = thbjattr_thbj-attr-g.property-value-logical.     multdtyp:private-data in frame page-1 = "recid3=" + string(recid(thbjattr_thbj-attr-g)).     display multdtyp with frame page-1 . END.
IF thbjattr_thbj-attr-g.prop-code = 'noapndsc':U THEN DO:     noapndsc = thbjattr_thbj-attr-g.property-value-logical.     noapndsc:private-data in frame page-1 = "recid3=" + string(recid(thbjattr_thbj-attr-g)).     display noapndsc with frame page-1 . END.
IF thbjattr_thbj-attr-g.prop-code = 'part-prc':U THEN DO:     part-prc = thbjattr_thbj-attr-g.property-value-logical.     part-prc:private-data in frame page-1 = "recid3=" + string(recid(thbjattr_thbj-attr-g)).     display part-prc with frame page-1 . END.
IF thbjattr_thbj-attr-g.prop-code = 'prc-exp':U THEN DO:     prc-exp = thbjattr_thbj-attr-g.property-value-decimal.     prc-exp:private-data in frame page-1 = "recid3=" + string(recid(thbjattr_thbj-attr-g)).     display prc-exp with frame page-1 . END.
IF thbjattr_thbj-attr-g.prop-code = 'rnd-znk':U THEN DO:     rnd-znk = thbjattr_thbj-attr-g.property-value-integer.     rnd-znk:private-data in frame page-1 = "recid3=" + string(recid(thbjattr_thbj-attr-g)).     display rnd-znk with frame page-1 . END.
IF thbjattr_thbj-attr-g.prop-code = 'slt-ext':U THEN DO:     slt-ext = thbjattr_thbj-attr-g.property-value-character.     slt-ext:private-data in frame page-1 = "recid3=" + string(recid(thbjattr_thbj-attr-g)).     display slt-ext with frame page-1 . END.
IF thbjattr_thbj-attr-g.prop-code = 'vat-ext':U THEN DO:     vat-ext = thbjattr_thbj-attr-g.property-value-character.     vat-ext:private-data in frame page-1 = "recid3=" + string(recid(thbjattr_thbj-attr-g)).     display vat-ext with frame page-1 . END.
IF thbjattr_thbj-attr-g.prop-code = 'vat-sum':U THEN DO:     vat-sum = thbjattr_thbj-attr-g.property-value-logical.     vat-sum:private-data in frame page-1 = "recid3=" + string(recid(thbjattr_thbj-attr-g)).     display vat-sum with frame page-1 . END.
create temp-thbj-attr.
buffer-copy thbjattr_thbj-attr-g to temp-thbj-attr.
end.
FOR EACH thbjattr_thbj-attr
:
IF thbjattr_thbj-attr.prop-code = 'date-close-period':U THEN DO:     date-close-period = thbjattr_thbj-attr.property-value-date.     date-close-period:private-data in frame page-1 = "recid2=" + string(recid(thbjattr_thbj-attr)).     display date-close-period with frame page-1 . END.
IF thbjattr_thbj-attr.prop-code = 'stfactdt':U THEN DO:     stfactdt = thbjattr_thbj-attr.property-value-logical.     stfactdt:private-data in frame page-1 = "recid2=" + string(recid(thbjattr_thbj-attr)).     display stfactdt with frame page-1 . END.
IF thbjattr_thbj-attr.prop-code = 'intprmvq':U THEN DO:     intprmvq = thbjattr_thbj-attr.property-value-logical.     intprmvq:private-data in frame page-1 = "recid2=" + string(recid(thbjattr_thbj-attr)).     display intprmvq with frame page-1 . END.
IF thbjattr_thbj-attr.prop-code = 'minusprt':U THEN DO:     minusprt = thbjattr_thbj-attr.property-value-logical.     minusprt:private-data in frame page-1 = "recid2=" + string(recid(thbjattr_thbj-attr)).     display minusprt with frame page-1 . END.
IF thbjattr_thbj-attr.prop-code = 'type-vat':U THEN DO:     type-vat = thbjattr_thbj-attr.property-value-integer.     type-vat:private-data in frame page-1 = "recid2=" + string(recid(thbjattr_thbj-attr)).     display type-vat with frame page-1 . END.
IF thbjattr_thbj-attr.prop-code = 'type-slt':U THEN DO:     type-slt = thbjattr_thbj-attr.property-value-integer.     type-slt:private-data in frame page-1 = "recid2=" + string(recid(thbjattr_thbj-attr)).     display type-slt with frame page-1 . END.
IF thbjattr_thbj-attr.prop-code = 'avail-on-date':U THEN DO:     avail-on-date = thbjattr_thbj-attr.property-value-logical.     avail-on-date:private-data in frame page-1 = "recid2=" + string(recid(thbjattr_thbj-attr)).     display avail-on-date with frame page-1 . END.
IF thbjattr_thbj-attr.prop-code = 'inp_sum':U THEN DO:     inp_sum = thbjattr_thbj-attr.property-value-logical.     inp_sum:private-data in frame page-1 = "recid2=" + string(recid(thbjattr_thbj-attr)).     display inp_sum with frame page-1 . END.
IF thbjattr_thbj-attr.prop-code = 'factorrt':U THEN DO:     factorrt = thbjattr_thbj-attr.property-value-decimal.     factorrt:private-data in frame page-1 = "recid2=" + string(recid(thbjattr_thbj-attr)).     display factorrt with frame page-1 . END.
IF thbjattr_thbj-attr.prop-code = 'proxycrd':U THEN DO:     proxycrd = thbjattr_thbj-attr.property-value-logical.     proxycrd:private-data in frame page-1 = "recid2=" + string(recid(thbjattr_thbj-attr)).     display proxycrd with frame page-1 . END.
IF thbjattr_thbj-attr.prop-code = 'reasonm':U THEN DO:     reasonm = thbjattr_thbj-attr.property-value-logical.     reasonm:private-data in frame page-2 = "recid2=" + string(recid(thbjattr_thbj-attr)).     display reasonm with frame page-2 . END.
IF thbjattr_thbj-attr.prop-code = 'reasonme':U THEN DO:     reasonme = thbjattr_thbj-attr.property-value-character.     reasonme:private-data in frame page-2 = "recid2=" + string(recid(thbjattr_thbj-attr)).     display reasonme with frame page-2 . END.
IF thbjattr_thbj-attr.prop-code = 'back-date':U THEN DO:     back-date = thbjattr_thbj-attr.property-value-logical.     back-date:private-data in frame page-2 = "recid2=" + string(recid(thbjattr_thbj-attr)).     display back-date with frame page-2 . END.
IF thbjattr_thbj-attr.prop-code = 'not-ord':U THEN DO:     not-ord = thbjattr_thbj-attr.property-value-logical.     not-ord:private-data in frame page-2 = "recid2=" + string(recid(thbjattr_thbj-attr)).     display not-ord with frame page-2 . END.
IF thbjattr_thbj-attr.prop-code = 'neg-ask':U THEN DO:     neg-ask = thbjattr_thbj-attr.property-value-logical.     neg-ask:private-data in frame page-2 = "recid2=" + string(recid(thbjattr_thbj-attr)).     display neg-ask with frame page-2 . END.
IF thbjattr_thbj-attr.prop-code = 'vat-goods':U THEN DO:     vat-goods = thbjattr_thbj-attr.property-value-logical.     vat-goods:private-data in frame page-2 = "recid2=" + string(recid(thbjattr_thbj-attr)).     display vat-goods with frame page-2 . END.
IF thbjattr_thbj-attr.prop-code = 'inv-ship':U THEN DO:     inv-ship = thbjattr_thbj-attr.property-value-logical.     inv-ship:private-data in frame page-2 = "recid2=" + string(recid(thbjattr_thbj-attr)).     display inv-ship with frame page-2 . END.
IF thbjattr_thbj-attr.prop-code = 'round-vat-sum':U THEN DO:     round-vat-sum = thbjattr_thbj-attr.property-value-logical.     round-vat-sum:private-data in frame page-2 = "recid2=" + string(recid(thbjattr_thbj-attr)).     display round-vat-sum with frame page-2 . END.
IF thbjattr_thbj-attr.prop-code = 'gtd-to-imp-prod':U THEN DO:     gtd-to-imp-prod = thbjattr_thbj-attr.property-value-logical.     gtd-to-imp-prod:private-data in frame page-2 = "recid2=" + string(recid(thbjattr_thbj-attr)).     display gtd-to-imp-prod with frame page-2 . END.
IF thbjattr_thbj-attr.prop-code = 'exc-max-qnty':U THEN DO:     exc-max-qnty = thbjattr_thbj-attr.property-value-logical.     exc-max-qnty:private-data in frame page-2 = "recid2=" + string(recid(thbjattr_thbj-attr)).     display exc-max-qnty with frame page-2 . END.
IF thbjattr_thbj-attr.prop-code = 'attr-PN':U THEN DO:     attr-PN = thbjattr_thbj-attr.property-value-character.     attr-PN:private-data in frame page-2 = "recid2=" + string(recid(thbjattr_thbj-attr)).     display attr-PN with frame page-2 . END.
IF thbjattr_thbj-attr.prop-code = 'attr-mandatory-gds-in-wayb':U THEN DO:     attr-mandatory-gds-in-wayb = thbjattr_thbj-attr.property-value-character.     attr-mandatory-gds-in-wayb:private-data in frame page-2 = "recid2=" + string(recid(thbjattr_thbj-attr)).     display attr-mandatory-gds-in-wayb with frame page-2 . END.
IF thbjattr_thbj-attr.prop-code = 'attr-mandatory-gds-ret-wayb':U THEN DO:     attr-mandatory-gds-ret-wayb = thbjattr_thbj-attr.property-value-character.     attr-mandatory-gds-ret-wayb:private-data in frame page-2 = "recid2=" + string(recid(thbjattr_thbj-attr)).     display attr-mandatory-gds-ret-wayb with frame page-2 . END.
IF thbjattr_thbj-attr.prop-code = 'attr-mandatory-gds-exp-wayb':U THEN DO:     attr-mandatory-gds-exp-wayb = thbjattr_thbj-attr.property-value-character.     attr-mandatory-gds-exp-wayb:private-data in frame page-2 = "recid2=" + string(recid(thbjattr_thbj-attr)).     display attr-mandatory-gds-exp-wayb with frame page-2 . END.
IF thbjattr_thbj-attr.prop-code = 'reasons-for-return':U THEN DO:     reasons-for-return = thbjattr_thbj-attr.property-value-character.     reasons-for-return:private-data in frame page-2 = "recid2=" + string(recid(thbjattr_thbj-attr)).     display reasons-for-return with frame page-2 . END.
IF thbjattr_thbj-attr.prop-code = 'reasons-write-off':U THEN DO:     reasons-write-off = thbjattr_thbj-attr.property-value-character.     reasons-write-off:private-data in frame page-2 = "recid2=" + string(recid(thbjattr_thbj-attr)).     display reasons-write-off with frame page-2 . END.
IF thbjattr_thbj-attr.prop-code = 'edit-fact-wayb':U THEN DO:     edit-fact-wayb = thbjattr_thbj-attr.property-value-logical.     edit-fact-wayb:private-data in frame page-2 = "recid2=" + string(recid(thbjattr_thbj-attr)).     display edit-fact-wayb with frame page-2 . END.
  create temp-thbj-attr.
  buffer-copy thbjattr_thbj-attr to temp-thbj-attr.
END.
define variable v-tooltip as character no-undo .
define variable v-label   as character no-undo .
define variable v-tooltip-code as character no-undo .
run thbjattr_tooltip in this-procedure (    input   'nakl_par':U   ,input  "date-close-period"   ,output v-tooltip   ,output v-label   ,output v-tooltip-code   ) no-error . v-date-close-period:screen-value = REPLACE ( entry(2,v-label,":") , "`" , "," ) .  I-date-close-period:private-data = REPLACE ( v-tooltip-code , "`" , "," ) .
run thbjattr_tooltip in this-procedure (    input   'nakl_par':U   ,input  "stfactdt"   ,output v-tooltip   ,output v-label   ,output v-tooltip-code   ) no-error . v-stfactdt:screen-value = REPLACE ( entry(2,v-label,":") , "`" , "," ) .  I-stfactdt:private-data = REPLACE ( v-tooltip-code , "`" , "," ) .
run thbjattr_tooltip in this-procedure (    input   'nakl_par':U   ,input  "type-vat"   ,output v-tooltip   ,output v-label   ,output v-tooltip-code   ) no-error . v-type-vat:screen-value = REPLACE ( entry(2,v-label,":") , "`" , "," ) .  I-type-vat:private-data = REPLACE ( v-tooltip-code , "`" , "," ) .
run thbjattr_tooltip in this-procedure (    input   'nakl_par':U   ,input  "type-slt"   ,output v-tooltip   ,output v-label   ,output v-tooltip-code   ) no-error . v-type-slt:screen-value = REPLACE ( entry(2,v-label,":") , "`" , "," ) .  I-type-slt:private-data = REPLACE ( v-tooltip-code , "`" , "," ) .
run thbjattr_tooltip in this-procedure (    input   'nakl_par':U   ,input  "intprmvq"   ,output v-tooltip   ,output v-label   ,output v-tooltip-code   ) no-error . v-intprmvq:screen-value = REPLACE ( entry(2,v-label,":") , "`" , "," ) .  I-intprmvq:private-data = REPLACE ( v-tooltip-code , "`" , "," ) .
run thbjattr_tooltip in this-procedure (    input   'nakl_par':U   ,input  "minusprt"   ,output v-tooltip   ,output v-label   ,output v-tooltip-code   ) no-error . v-minusprt:screen-value = REPLACE ( entry(2,v-label,":") , "`" , "," ) .  I-minusprt:private-data = REPLACE ( v-tooltip-code , "`" , "," ) .
run thbjattr_tooltip in this-procedure (    input   'nakl_par':U   ,input  "avail-on-date"   ,output v-tooltip   ,output v-label   ,output v-tooltip-code   ) no-error . v-avail-on-date:screen-value = REPLACE ( entry(2,v-label,":") , "`" , "," ) .  I-avail-on-date:private-data = REPLACE ( v-tooltip-code , "`" , "," ) .
run thbjattr_tooltip in this-procedure (    input   'nakl_par':U   ,input  "inp_sum"   ,output v-tooltip   ,output v-label   ,output v-tooltip-code   ) no-error . v-inp_sum:screen-value = REPLACE ( entry(2,v-label,":") , "`" , "," ) .  I-inp_sum:private-data = REPLACE ( v-tooltip-code , "`" , "," ) .
run thbjattr_tooltip in this-procedure (    input   'nakl_par':U   ,input  "factorrt"   ,output v-tooltip   ,output v-label   ,output v-tooltip-code   ) no-error . v-factorrt:screen-value = REPLACE ( entry(2,v-label,":") , "`" , "," ) .  I-factorrt:private-data = REPLACE ( v-tooltip-code , "`" , "," ) .
run thbjattr_tooltip in this-procedure (    input   'nakl_par':U   ,input  "proxycrd"   ,output v-tooltip   ,output v-label   ,output v-tooltip-code   ) no-error . v-proxycrd:screen-value = REPLACE ( entry(2,v-label,":") , "`" , "," ) .  I-proxycrd:private-data = REPLACE ( v-tooltip-code , "`" , "," ) .
run thbjattr_tooltip in this-procedure (    input   'nakl-glob':U   ,input  "nocurbas"   ,output v-tooltip   ,output v-label   ,output v-tooltip-code   ) no-error . v-nocurbas:screen-value = REPLACE ( entry(2,v-label,":") , "`" , "," ) .  I-nocurbas:private-data = REPLACE ( v-tooltip-code , "`" , "," ) .
run thbjattr_tooltip in this-procedure (    input   'nakl-glob':U   ,input  "chk-prs"   ,output v-tooltip   ,output v-label   ,output v-tooltip-code   ) no-error . v-chk-prs:screen-value = REPLACE ( entry(2,v-label,":") , "`" , "," ) .  I-chk-prs:private-data = REPLACE ( v-tooltip-code , "`" , "," ) .
run thbjattr_tooltip in this-procedure (    input   'nakl-glob':U   ,input  "convimp"   ,output v-tooltip   ,output v-label   ,output v-tooltip-code   ) no-error . v-convimp:screen-value = REPLACE ( entry(2,v-label,":") , "`" , "," ) .  I-convimp:private-data = REPLACE ( v-tooltip-code , "`" , "," ) .
run thbjattr_tooltip in this-procedure (    input   'nakl-glob':U   ,input  "curcli"   ,output v-tooltip   ,output v-label   ,output v-tooltip-code   ) no-error . v-curcli:screen-value = REPLACE ( entry(2,v-label,":") , "`" , "," ) .  I-curcli:private-data = REPLACE ( v-tooltip-code , "`" , "," ) .
run thbjattr_tooltip in this-procedure (    input   'nakl-glob':U   ,input  "is-bcdoc"   ,output v-tooltip   ,output v-label   ,output v-tooltip-code   ) no-error . v-is-bcdoc:screen-value = REPLACE ( entry(2,v-label,":") , "`" , "," ) .  I-is-bcdoc:private-data = REPLACE ( v-tooltip-code , "`" , "," ) .
run thbjattr_tooltip in this-procedure (    input   'nakl-glob':U   ,input  "is-ov"   ,output v-tooltip   ,output v-label   ,output v-tooltip-code   ) no-error . v-is-ov:screen-value = REPLACE ( entry(2,v-label,":") , "`" , "," ) .  I-is-ov:private-data = REPLACE ( v-tooltip-code , "`" , "," ) .
run thbjattr_tooltip in this-procedure (    input   'nakl-glob':U   ,input  "multdtyp"   ,output v-tooltip   ,output v-label   ,output v-tooltip-code   ) no-error . v-multdtyp:screen-value = REPLACE ( entry(2,v-label,":") , "`" , "," ) .  I-multdtyp:private-data = REPLACE ( v-tooltip-code , "`" , "," ) .
run thbjattr_tooltip in this-procedure (    input   'nakl-glob':U   ,input  "noapndsc"   ,output v-tooltip   ,output v-label   ,output v-tooltip-code   ) no-error . v-noapndsc:screen-value = REPLACE ( entry(2,v-label,":") , "`" , "," ) .  I-noapndsc:private-data = REPLACE ( v-tooltip-code , "`" , "," ) .
run thbjattr_tooltip in this-procedure (    input   'nakl-glob':U   ,input  "part-prc"   ,output v-tooltip   ,output v-label   ,output v-tooltip-code   ) no-error . v-part-prc:screen-value = REPLACE ( entry(2,v-label,":") , "`" , "," ) .  I-part-prc:private-data = REPLACE ( v-tooltip-code , "`" , "," ) .
run thbjattr_tooltip in this-procedure (    input   'nakl-glob':U   ,input  "prc-exp"   ,output v-tooltip   ,output v-label   ,output v-tooltip-code   ) no-error . v-prc-exp:screen-value = REPLACE ( entry(2,v-label,":") , "`" , "," ) .  I-prc-exp:private-data = REPLACE ( v-tooltip-code , "`" , "," ) .
run thbjattr_tooltip in this-procedure (    input   'nakl-glob':U   ,input  "rnd-znk"   ,output v-tooltip   ,output v-label   ,output v-tooltip-code   ) no-error . v-rnd-znk:screen-value = REPLACE ( entry(2,v-label,":") , "`" , "," ) .  I-rnd-znk:private-data = REPLACE ( v-tooltip-code , "`" , "," ) .
run thbjattr_tooltip in this-procedure (    input   'nakl-glob':U   ,input  "slt-ext"   ,output v-tooltip   ,output v-label   ,output v-tooltip-code   ) no-error . v-slt-ext:screen-value = REPLACE ( entry(2,v-label,":") , "`" , "," ) .  I-slt-ext:private-data = REPLACE ( v-tooltip-code , "`" , "," ) .
run thbjattr_tooltip in this-procedure (    input   'nakl-glob':U   ,input  "vat-ext"   ,output v-tooltip   ,output v-label   ,output v-tooltip-code   ) no-error . v-vat-ext:screen-value = REPLACE ( entry(2,v-label,":") , "`" , "," ) .  I-vat-ext:private-data = REPLACE ( v-tooltip-code , "`" , "," ) .
run thbjattr_tooltip in this-procedure (    input   'nakl-glob':U   ,input  "vat-sum"   ,output v-tooltip   ,output v-label   ,output v-tooltip-code   ) no-error . v-vat-sum:screen-value = REPLACE ( entry(2,v-label,":") , "`" , "," ) .  I-vat-sum:private-data = REPLACE ( v-tooltip-code , "`" , "," ) .
run thbjattr_tooltip in this-procedure (    input   'nakl_par':U   ,input  "reasonm"   ,output v-tooltip   ,output v-label   ,output v-tooltip-code   ) no-error . v-reasonm:screen-value = REPLACE ( entry(2,v-label,":") , "`" , "," ) .  I-reasonm:private-data = REPLACE ( v-tooltip-code , "`" , "," ) .
run thbjattr_tooltip in this-procedure (    input   'nakl_par':U   ,input  "reasonme"   ,output v-tooltip   ,output v-label   ,output v-tooltip-code   ) no-error . v-reasonme:screen-value = REPLACE ( entry(2,v-label,":") , "`" , "," ) .  I-reasonme:private-data = REPLACE ( v-tooltip-code , "`" , "," ) .
run thbjattr_tooltip in this-procedure (    input   'nakl_par':U   ,input  "back-date"   ,output v-tooltip   ,output v-label   ,output v-tooltip-code   ) no-error . v-back-date:screen-value = REPLACE ( entry(2,v-label,":") , "`" , "," ) .  I-back-date:private-data = REPLACE ( v-tooltip-code , "`" , "," ) .
run thbjattr_tooltip in this-procedure (    input   'nakl_par':U   ,input  "not-ord"   ,output v-tooltip   ,output v-label   ,output v-tooltip-code   ) no-error . v-not-ord:screen-value = REPLACE ( entry(2,v-label,":") , "`" , "," ) .  I-not-ord:private-data = REPLACE ( v-tooltip-code , "`" , "," ) .
run thbjattr_tooltip in this-procedure (    input   'nakl_par':U   ,input  "neg-ask"   ,output v-tooltip   ,output v-label   ,output v-tooltip-code   ) no-error . v-neg-ask:screen-value = REPLACE ( entry(2,v-label,":") , "`" , "," ) .  I-neg-ask:private-data = REPLACE ( v-tooltip-code , "`" , "," ) .
run thbjattr_tooltip in this-procedure (    input   'nakl_par':U   ,input  "vat-goods"   ,output v-tooltip   ,output v-label   ,output v-tooltip-code   ) no-error . v-vat-goods:screen-value = REPLACE ( entry(2,v-label,":") , "`" , "," ) .  I-vat-goods:private-data = REPLACE ( v-tooltip-code , "`" , "," ) .
run thbjattr_tooltip in this-procedure (    input   'nakl_par':U   ,input  "inv-ship"   ,output v-tooltip   ,output v-label   ,output v-tooltip-code   ) no-error . v-inv-ship:screen-value = REPLACE ( entry(2,v-label,":") , "`" , "," ) .  I-inv-ship:private-data = REPLACE ( v-tooltip-code , "`" , "," ) .
run thbjattr_tooltip in this-procedure (    input   'nakl_par':U   ,input  "round-vat-sum"   ,output v-tooltip   ,output v-label   ,output v-tooltip-code   ) no-error . v-round-vat-sum:screen-value = REPLACE ( entry(2,v-label,":") , "`" , "," ) .  I-round-vat-sum:private-data = REPLACE ( v-tooltip-code , "`" , "," ) .
run thbjattr_tooltip in this-procedure (    input   'nakl_par':U   ,input  "gtd-to-imp-prod"   ,output v-tooltip   ,output v-label   ,output v-tooltip-code   ) no-error . v-gtd-to-imp-prod:screen-value = REPLACE ( entry(2,v-label,":") , "`" , "," ) .  I-gtd-to-imp-prod:private-data = REPLACE ( v-tooltip-code , "`" , "," ) .
run thbjattr_tooltip in this-procedure (    input   'nakl_par':U   ,input  "exc-max-qnty"   ,output v-tooltip   ,output v-label   ,output v-tooltip-code   ) no-error . v-exc-max-qnty:screen-value = REPLACE ( entry(2,v-label,":") , "`" , "," ) .  I-exc-max-qnty:private-data = REPLACE ( v-tooltip-code , "`" , "," ) .
run thbjattr_tooltip in this-procedure (    input   'nakl_par':U   ,input  "attr-PN"   ,output v-tooltip   ,output v-label   ,output v-tooltip-code   ) no-error . v-attr-PN:screen-value = REPLACE ( entry(2,v-label,":") , "`" , "," ) .  I-attr-PN:private-data = REPLACE ( v-tooltip-code , "`" , "," ) .
run thbjattr_tooltip in this-procedure (    input   'nakl_par':U   ,input  "attr-mandatory-gds-in-wayb"   ,output v-tooltip   ,output v-label   ,output v-tooltip-code   ) no-error . v-attr-mandatory-gds-in-wayb:screen-value = REPLACE ( entry(2,v-label,":") , "`" , "," ) .  I-attr-mandatory-gds-in-wayb:private-data = REPLACE ( v-tooltip-code , "`" , "," ) .
run thbjattr_tooltip in this-procedure (    input   'nakl_par':U   ,input  "attr-mandatory-gds-ret-wayb"   ,output v-tooltip   ,output v-label   ,output v-tooltip-code   ) no-error . v-attr-mandatory-gds-ret-wayb:screen-value = REPLACE ( entry(2,v-label,":") , "`" , "," ) .  I-attr-mandatory-gds-ret-wayb:private-data = REPLACE ( v-tooltip-code , "`" , "," ) .
run thbjattr_tooltip in this-procedure (    input   'nakl_par':U   ,input  "attr-mandatory-gds-exp-wayb"   ,output v-tooltip   ,output v-label   ,output v-tooltip-code   ) no-error . v-attr-mandatory-gds-exp-wayb:screen-value = REPLACE ( entry(2,v-label,":") , "`" , "," ) .  I-attr-mandatory-gds-exp-wayb:private-data = REPLACE ( v-tooltip-code , "`" , "," ) .
run thbjattr_tooltip in this-procedure (    input   'nakl_par':U   ,input  "reasons-for-return"   ,output v-tooltip   ,output v-label   ,output v-tooltip-code   ) no-error . v-reasons-for-return:screen-value = REPLACE ( entry(2,v-label,":") , "`" , "," ) .  I-reasons-for-return:private-data = REPLACE ( v-tooltip-code , "`" , "," ) .
run thbjattr_tooltip in this-procedure (    input   'nakl_par':U   ,input  "reasons-write-off"   ,output v-tooltip   ,output v-label   ,output v-tooltip-code   ) no-error . v-reasons-write-off:screen-value = REPLACE ( entry(2,v-label,":") , "`" , "," ) .  I-reasons-write-off:private-data = REPLACE ( v-tooltip-code , "`" , "," ) .
run thbjattr_tooltip in this-procedure (    input   'nakl_par':U   ,input  "edit-fact-wayb"   ,output v-tooltip   ,output v-label   ,output v-tooltip-code   ) no-error . v-edit-fact-wayb:screen-value = REPLACE ( entry(2,v-label,":") , "`" , "," ) .  I-edit-fact-wayb:private-data = REPLACE ( v-tooltip-code , "`" , "," ) .
END PROCEDURE.
PROCEDURE init-proc :
define variable v-i as integer   no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-type as character no-undo .
define variable v-value as character no-undo .
define variable v-found as decimal   no-undo .
  if p-mode = 'ИЗМЕНЕНИЕ':U then do:
    find first obj_thbj-attr exclusive-lock where
              obj_thbj-attr.obj-type = p-obj-type
        and   obj_thbj-attr.obj-code = p-obj-code
        and   obj_thbj-attr.upper-prop-code = 'nakl_par':U
        and   obj_thbj-attr.prop-code = '':u no-wait no-error.
     if locked obj_thbj-attr then do:
        message
        vss-workfile vss-revision vss-description skip
        'nakl_par':U skip
        "Запись ПАРАМЕТРОВ  занята"
        view-as alert-box error .
        undo, return error.
      end.
    find first glb_thbj-attr exclusive-lock where
              glb_thbj-attr.obj-type = ""
        and   glb_thbj-attr.obj-code = 0
        and   glb_thbj-attr.upper-prop-code = 'nakl-glob':U
        and   glb_thbj-attr.prop-code = '':u no-wait no-error.
     if locked glb_thbj-attr then do:
        message
        vss-workfile vss-revision vss-description skip
        'nakl-glob':U skip
        "Запись Глобальных ПАРАМЕТРОВ  занята"
        view-as alert-box error .
        undo, return error.
      end.
  end.
  else do:
    find first obj_thbj-attr no-lock where
          obj_thbj-attr.obj-type = p-obj-type
    and   obj_thbj-attr.obj-code = p-obj-code
    and   obj_thbj-attr.upper-prop-code = 'nakl_par':U
    and   obj_thbj-attr.prop-code = '':u no-error.
    find first glb_thbj-attr no-lock where
          glb_thbj-attr.obj-type = ""
    and   glb_thbj-attr.obj-code = 0
    and   glb_thbj-attr.upper-prop-code = 'nakl-glob':U
    and   glb_thbj-attr.prop-code = '':u no-error.
  end.
  if not available obj_thbj-attr then do:
    assign
      v-to-create-trn  = true
      .
    message
    substitute ("Внимание!!!&1Секции по объекту НЕТ в БД!&1Будут показаны ЗНАЧЕНИЯ ПО УМОЛЧАНИЮ",
                chr(10))
                 view-as alert-box warning.
  end.
  if not available glb_thbj-attr then do:
    assign
      v-to-create-trn-g  = true
      .
    message
    substitute ("Внимание!!!&1Секции Гл.Параметров НЕТ в БД!&1Будут показаны ЗНАЧЕНИЯ ПО УМОЛЧАНИЮ",
                chr(10))
                 view-as alert-box warning.
  end.
  run fill-widgets in this-procedure no-error.
  if error-status:error then undo, return error.
  if p-mode <> 'ИЗМЕНЕНИЕ':U then do:
     disable
     date-close-period
     stfactdt
     type-vat
     type-slt
     intprmvq
     minusprt
     avail-on-date
     inp_sum
     factorrt
     proxycrd
     nocurbas
     chk-prs
     convimp
     curcli
     is-bcdoc
     is-ov
     multdtyp
     noapndsc
     part-prc
     prc-exp
     rnd-znk
     slt-ext
     vat-ext
     vat-sum
     with frame page-1 .
     disable
     reasonm
     reasonme
     back-date
     not-ord
     neg-ask
     vat-goods
     inv-ship
     round-vat-sum
     gtd-to-imp-prod
     exc-max-qnty
     attr-PN
     edit-fact-wayb
     with frame page-2 .
     B-exit:label in frame Dialog-Frame  = "Вы&ход"  .
     hide B-quit in frame Dialog-Frame .
  END.
  if not ( p-obj-type = "" and p-obj-code = 0 ) then do:
     disable
       nocurbas
       chk-prs
       convimp
       curcli
       is-bcdoc
       is-ov
       multdtyp
       noapndsc
       part-prc
       prc-exp
       rnd-znk
       slt-ext
       vat-ext
       vat-sum
     with frame page-1.
  end.
  hide attr-PN in frame page-2 .
  hide attr-mandatory-gds-in-wayb in frame page-2 .
  hide attr-mandatory-gds-ret-wayb in frame page-2 .
  hide attr-mandatory-gds-exp-wayb in frame page-2 .
  hide reasons-for-return in frame page-2 .
  hide reasons-write-off in frame page-2 .
end procedure.
PROCEDURE init-tt :
END PROCEDURE.
PROCEDURE proc-init-reasons-for-return :
define buffer buf_trn-reason for ub.trn-reason .
for each buf_trn-reason no-lock :
  assign
    v-list-reasons-for-return       = v-list-reasons-for-return + string(buf_trn-reason.reason-code) + ","
    v-list-reasons-for-return-full  = v-list-reasons-for-return-full + buf_trn-reason.reason-name + chr(8)
  .
end.
assign
  v-list-reasons-for-return     = trim(v-list-reasons-for-return, ",")
  v-list-reasons-for-return-full = trim(v-list-reasons-for-return-full, chr(8))
.
END PROCEDURE.
PROCEDURE proc-init-reasons-write-off :
define buffer buf_trn-reason for ub.trn-reason .
for each buf_trn-reason no-lock :
  assign
    v-list-reasons-write-off       = v-list-reasons-write-off + string(buf_trn-reason.reason-code) + ","
    v-list-reasons-write-off-full  = v-list-reasons-write-off-full + buf_trn-reason.reason-name + chr(8)
  .
end.
assign
  v-list-reasons-write-off     = trim(v-list-reasons-write-off, ",")
  v-list-reasons-write-off-full = trim(v-list-reasons-write-off-full, chr(8))
.
END PROCEDURE.
PROCEDURE proc-init-attr-PN :
   assign
      v-list-attr-PN      = 'nids':U + "," + 'dids':U + "," + 'nsf':U + "," + 'dsf':U + "," + 'expense_own':U + "," + 'ndog':U + ","
      + 'ddog':U + "," + 'ndov':U + "," + 'ddov':U + "," + 'print-num':U + "," + 'idCountryContr':U + "," + 'car-time':U +
      "," + 't_pass-fname':U + "," + 't_pass-position':U + "," + 't_accept-fname':U + "," + 't_accept-position':U + "," +
      'ndovwho':U + "," + 'nosn':U + "," + 'Shipper':U + "," + 'othermoves':U
      v-list-attr-PN-full = "Номер приходной накладной поставщика" + chr(8) + "Дата приходной накладной поставщика" + chr(8) + "Счет-фактура поставщика: Номер" + chr(8) + "Счет-фактура поставщика: Дата" + chr(8) + "Расходы не включаемые в учетную цену" + chr(8) + "Договор: Номер" + chr(8)
      + "Договор: Дата" + chr(8) + "Доверенность: Номер" + chr(8) + "Доверенность: Дата" + chr(8) + "Номер документа для печати" + chr(8) + "Идентификатор государственного контракта" + chr(8) + "Время прихода машины" +
      chr(8) + "Сдал /Расшифровка/" + chr(8) + "Сдал /Должность/" + chr(8) + "Принял /Расшифровка/" + chr(8) + "Принял /Должность/" + chr(8) +
      "Доверенность: Кем и кому выдана" + chr(8) + "Документ-основание. Наименование" + chr(8) + "Грузоотправитель" + chr(8) + "Прочие перемещения НП".
   assign
      v-list-attr-mandatory-gds-in-wayb = v-list-attr-PN
      v-list-attr-mandatory-gds-in-wayb-full = v-list-attr-PN-full
   .
   assign
      v-list-attr-mandatory-gds-exp-wayb = 'nsf':U + "," + 'dsf':U + "," + 'expense_own':U + "," + 'ndog':U + ","
      + 'ddog':U + "," + 'ndov':U + "," + 'ddov':U + "," + 'print-num':U + "," + 'idCountryContr':U +
      "," + 't_pass-fname':U + "," + 't_pass-position':U + "," + 't_accept-fname':U + "," + 't_accept-position':U
      + "," + 'ndovwho':U + "," + 'nosn':U
      + "," + 'Auto':U + "," + 'Driver':U + "," + 'DFinDoc':U
      + "," + 'NFinDoc':U + "," + 'delivery-date':U + "," + 'Recipient':U
      + "," + 'delivery-time':U + "," + '21ord_phone':U + "," + '22ord_contact':U
      + "," + 'Dispath':U + "," + 'Packer':U + "," + '22ord_contact':U
      + "," + 'QntyPlace':U + "," + 'zakaz-date':U + "," + '4ord_dl':U
      + "," + '8ord_adr':U + "," + 'carry-type':U + "," + 'cargo-mass':U
      + "," + 'cargo-desc':U + "," + 'exp-trans':U + "," + 'zakaz-number':U
      v-list-attr-mandatory-gds-exp-wayb-full = "Счет-фактура поставщика: Номер" + chr(8) + "Счет-фактура поставщика: Дата" + chr(8) + "Расходы не включаемые в учетную цену" + chr(8) + "Договор: Номер" + chr(8)
      + "Договор: Дата" + chr(8) + "Доверенность: Номер" + chr(8) + "Доверенность: Дата" + chr(8) + "Номер документа для печати" + chr(8) + "Идентификатор государственного контракта" +
      chr(8) + "Сдал /Расшифровка/" + chr(8) + "Сдал /Должность/" + chr(8) + "Принял /Расшифровка/" + chr(8) + "Принял /Должность/"
      + chr(8) + "Доверенность: Кем и кому выдана" + chr(8) + "Документ-основание. Наименование"
      + chr(8) + "Автомобиль: Марка, Номер" + chr(8) + "Автомобиль: Водитель" + chr(8) + "Расчетный документ: Дата"
      + chr(8) + "Расчетный документ: Номер" + chr(8) + "Дата доставки" + chr(8) + "Грузополучатель"
      + chr(8) + "Время доставки (период)" + chr(8) + "Контактный телефон" + chr(8) + "Контактное лицо"
      + chr(8) + "Способ отгрузки" + chr(8) + "Упаковщик" + chr(8) + "Контактное лицо"
      + chr(8) + "Количество мест" + chr(8) + "Дата заказа" + chr(8) + "Требуется доставка"
      + chr(8) + "Адрес доставки" + chr(8) + "Вид перевозки" + chr(8) + "Масса груза, кг"
      + chr(8) + "Описание груза" + chr(8) + "Складские/транспортные расходы" + chr(8) + "Номер заказа"
      .
    assign
      v-list-attr-mandatory-gds-ret-wayb = v-list-attr-mandatory-gds-exp-wayb
      v-list-attr-mandatory-gds-ret-wayb-full = v-list-attr-mandatory-gds-exp-wayb-full
    .
END PROCEDURE.
PROCEDURE proc-init-EX :
   assign
      v-list-edt      = 'ie,ee,ep,re,we,vt,vp,iv,ev,rv,ap,io,eo':U
      v-list-edt-full = 'приход внешний,расход внешний,возврат пост.,возврат внешний,списание,инвентаризация,пересортица,приход внутренний,расход внутренний,возврат внутренний,коррекция учетных цен,приход внутриобъектный,расход внутриобъектный':U
   .
END PROCEDURE.
PROCEDURE save-proc :
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-sale-add as character no-undo .
define variable v-trf-type like ub.clients.obj-type no-undo .
define variable v-trf-code like ub.clients.obj-code no-undo .
define variable v-param-type as character no-undo .
define variable wh as widget-handle no-undo .
define variable fh as widget-handle no-undo .
define variable fh2 as widget-handle no-undo .
define variable v-same as logical no-undo .
define variable v-sameg as logical no-undo .
IF p-mode = 'ПРОСМОТР':U THEN RETURN .
define variable loc#log as logical   no-undo .
define variable vss-include-info13 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  g#db-num
    ,input  g#userid
    ,input  0
    ,input  'actn_nakl-par_update':U
    ,input  'object':U
    ,input  v-cntxt-host-code-obj
    ,input  v-cntxt-obj-type
    ,input  v-cntxt-obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output loc#log
    )  .
end.
  if loc#log <> yes then do: return error. end.
ASSIGN
    date-close-period FRAME page-1
    stfactdt
    type-vat
    type-slt
    intprmvq
    minusprt
    avail-on-date
    inp_sum
    factorrt
    proxycrd
    nocurbas
    chk-prs
    convimp
    curcli
    is-bcdoc
    is-ov
    multdtyp
    noapndsc
    part-prc
    prc-exp
    rnd-znk
    slt-ext
    vat-ext
    vat-sum
 .
 assign frame page-2
    reasonm
    reasonme
    back-date
    not-ord
    neg-ask
    vat-goods
    attr-PN
    edit-fact-wayb
    .
assign
  fh = frame page-1:first-child
  fh2 = frame page-2:first-child
  .
define variable v-ind as integer   no-undo .
define variable v-num-entries as integer   no-undo .
define variable v-str as character no-undo .
v-str = string(fh:first-child) + "," + string(fh2:first-child) .
v-num-entries = num-entries (v-str) .
do v-ind = 1 to v-num-entries :
  wh  = widget-handle (entry(v-ind , v-str )) no-error .
  do while valid-handle(wh):
    if wh:private-data begins "recid2=" then do:
      find first thbjattr_thbj-attr where
                recid(thbjattr_thbj-attr) = integer(entry(2, wh:private-data, '='))
                no-error .
      if available thbjattr_thbj-attr then do:
      assign
          buffer thbjattr_thbj-attr:buffer-field("property-value-" + wh:data-type):buffer-value = wh:input-value
          .
      end.
    end.
    if wh:private-data begins "recid3=" then do:
      find first thbjattr_thbj-attr-g where
                recid(thbjattr_thbj-attr-g) = integer(entry(2, wh:private-data, '='))
                no-error .
      if available thbjattr_thbj-attr-g then do:
      assign
      buffer thbjattr_thbj-attr-g:buffer-field("property-value-" + wh:data-type):buffer-value = wh:input-value.
      end.
    end.
    wh = wh:next-sibling.
  end.
end.
v-same = yes.
for each thbjattr_thbj-attr where
         thbjattr_thbj-attr.obj-type = p-obj-type and
         thbjattr_thbj-attr.obj-code = p-obj-code ,
    first temp-thbj-attr where
          temp-thbj-attr.obj-type = p-obj-type
      and temp-thbj-attr.obj-code = p-obj-code
      and temp-thbj-attr.upper-prop-code = thbjattr_thbj-attr.upper-prop-code
      and temp-thbj-attr.prop-code = thbjattr_thbj-attr.prop-code :
   buffer-compare
   thbjattr_thbj-attr
   to temp-thbj-attr
   save result in v-same.
   if not v-same then leave.
end.
v-same = no.
v-sameg = yes.
for each thbjattr_thbj-attr-g ,
    first temp-thbj-attr where
          temp-thbj-attr.obj-type = ""
      and temp-thbj-attr.obj-code = 0
      and temp-thbj-attr.upper-prop-code = thbjattr_thbj-attr-g.upper-prop-code
      and temp-thbj-attr.prop-code = thbjattr_thbj-attr-g.prop-code :
   buffer-compare
   thbjattr_thbj-attr-g
   to temp-thbj-attr
   save result in v-sameg.
   if not v-sameg then leave.
end.
v-sameg = no.
do transaction
on error undo, return error return-value
:
  run thbjattr_set-section in this-procedure (
        input p-obj-type
      , input p-obj-code
      , input 'nakl_par':U
      , input table thbjattr_thbj-attr
  ) no-error.
  if error-status:error then do:
    message error-status:get-message(1)  skip
    return-value
    view-as alert-box.
    undo, return error.
  end.
  if p-obj-type = "" and p-obj-code = 0  then do:
      run thbjattr_set-section in this-procedure (
            input p-obj-type
          , input p-obj-code
          , input 'nakl-glob':U
          , input table thbjattr_thbj-attr-g
      ) no-error.
      if error-status:error then do:
        message error-status:get-message(1)  skip
        return-value
        view-as alert-box.
        undo, return error.
      end.
  end.
end.
END PROCEDURE.
PROCEDURE select-attr-mandat-wayb :
define input  parameter p-list-attr-mandat-wayb       as character no-undo.
define input  parameter p-list-attr-mandat-wayb-full  as character no-undo.
define input-output parameter p-attr-mandat-wayb      as character no-undo.
define variable v-counter       as integer      no-undo.
define variable v-label         as character    no-undo.
define variable v-value         as character    no-undo.
define variable v-list          as character    no-undo.
define variable v-changed       as logical      no-undo.
define variable v-accepted      as logical      no-undo.
define variable V-EX            as logical      no-undo.
define variable v-mode          as integer      no-undo.
do
with frame Dialog-Frame
on error undo, return error
:
if p-mode = 'ПРОСМОТР':U then v-mode = 0 .
else v-mode = 1 .
    run twowin_clear in this-procedure.
    do v-counter = 1 to num-entries( p-list-attr-mandat-wayb-full, chr(8))
    on error undo, return error
    :
        assign
            v-label = entry( v-counter, p-list-attr-mandat-wayb-full, chr(8) )
            v-value = entry( v-counter, p-list-attr-mandat-wayb )
            v-ex = false
        .
           if  lookup (v-value , p-attr-mandat-wayb ) > 0 then  v-ex = true .
           else v-ex = false .
        run twowin_add-item in this-procedure (
              input v-value
            , input v-label
            , input substitute( "Атрибуты: &1", v-VALUE)
            , input  V-EX
        ).
    end.
    run gbl/twowin.w (
          input ?
        , input v-mode
        , input "Выбор атрибутов":U
        , input "":U
        , input "&Тест"
        , input table temp_twowin_items
        , output table temp_twowin_itemsSelected_col
        , output v-changed
        , output v-accepted
    ).
    if v-changed then do:
        p-attr-mandat-wayb = "" .
        for each temp_twowin_itemsSelected_col :
          p-attr-mandat-wayb = p-attr-mandat-wayb + temp_twowin_itemsSelected_col.itmExtKey + "," .
        end.
        p-attr-mandat-wayb = trim(p-attr-mandat-wayb, ",") .
    end.
end.
END PROCEDURE.
PROCEDURE select-reasons-for-return :
define input  parameter p-list-reasons-for-return       as character no-undo.
define input  parameter p-list-reasons-for-return-full  as character no-undo.
define input-output parameter p-reasons-for-return      as character no-undo.
define variable v-counter       as integer      no-undo.
define variable v-label         as character    no-undo.
define variable v-value         as character    no-undo.
define variable v-list          as character    no-undo.
define variable v-changed       as logical      no-undo.
define variable v-accepted      as logical      no-undo.
define variable V-EX            as logical      no-undo.
define variable v-mode          as integer      no-undo.
do
with frame Dialog-Frame
on error undo, return error
:
if p-mode = 'ПРОСМОТР':U then v-mode = 0 .
else v-mode = 1 .
    run twowin_clear in this-procedure.
    do v-counter = 1 to num-entries( p-list-reasons-for-return-full, chr(8))
    on error undo, return error
    :
        assign
            v-label = entry( v-counter, p-list-reasons-for-return-full, chr(8) )
            v-value = entry( v-counter, p-list-reasons-for-return )
            v-ex = false
        .
           if  lookup (v-value , p-reasons-for-return ) > 0 then  v-ex = true .
           else v-ex = false .
        run twowin_add-item in this-procedure (
              input v-value
            , input v-label
            , input substitute( "Основания: &1", v-VALUE)
            , input  V-EX
        ).
    end.
    run gbl/twowin.w (
          input ?
        , input v-mode
        , input "Выбор оснований для возврата":U
        , input "":U
        , input "&Тест"
        , input table temp_twowin_items
        , output table temp_twowin_itemsSelected_col
        , output v-changed
        , output v-accepted
    ).
    if v-changed then do:
        p-reasons-for-return = "" .
        for each temp_twowin_itemsSelected_col :
          p-reasons-for-return = p-reasons-for-return + temp_twowin_itemsSelected_col.itmExtKey + "," .
        end.
        p-reasons-for-return = trim(p-reasons-for-return, ",") .
    end.
end.
END PROCEDURE.
PROCEDURE select-reasons-write-off :
define input  parameter p-list-reasons-write-off       as character no-undo.
define input  parameter p-list-reasons-write-off-full  as character no-undo.
define input-output parameter p-reasons-write-off      as character no-undo.
define variable v-counter       as integer      no-undo.
define variable v-label         as character    no-undo.
define variable v-value         as character    no-undo.
define variable v-list          as character    no-undo.
define variable v-changed       as logical      no-undo.
define variable v-accepted      as logical      no-undo.
define variable V-EX            as logical      no-undo.
define variable v-mode          as integer      no-undo.
do
with frame Dialog-Frame
on error undo, return error
:
if p-mode = 'ПРОСМОТР':U then v-mode = 0 .
else v-mode = 1 .
    run twowin_clear in this-procedure.
    do v-counter = 1 to num-entries( p-list-reasons-write-off-full, chr(8))
    on error undo, return error
    :
        assign
            v-label = entry( v-counter, p-list-reasons-write-off-full, chr(8) )
            v-value = entry( v-counter, p-list-reasons-write-off )
            v-ex = false
        .
           if  lookup (v-value , p-reasons-write-off ) > 0 then  v-ex = true .
           else v-ex = false .
        run twowin_add-item in this-procedure (
              input v-value
            , input v-label
            , input substitute( "Причины: &1", v-VALUE)
            , input  V-EX
        ).
    end.
    run gbl/twowin.w (
          input ?
        , input v-mode
        , input "Выбор причины списания":U
        , input "":U
        , input "&Тест"
        , input table temp_twowin_items
        , output table temp_twowin_itemsSelected_col
        , output v-changed
        , output v-accepted
    ).
    if v-changed then do:
        p-reasons-write-off = "" .
        for each temp_twowin_itemsSelected_col :
          p-reasons-write-off = p-reasons-write-off + temp_twowin_itemsSelected_col.itmExtKey + "," .
        end.
        p-reasons-write-off = trim(p-reasons-write-off, ",") .
    end.
end.
END PROCEDURE.
PROCEDURE select-col-type :
define variable v-counter       as integer      no-undo.
define variable v-label         as character    no-undo.
define variable v-value         as character    no-undo.
define variable v-list          as character    no-undo.
define variable v-changed       as logical    no-undo.
define variable v-accepted      as logical    no-undo.
define variable V-EX as logical   no-undo .
do
with frame Dialog-Frame
on error undo, return error
:
    run twowin_clear in this-procedure.
    do v-counter = 1 to num-entries( v-list-edt-full )
    on error undo, return error
    :
        assign
            v-label = entry( v-counter, v-list-edt-full)
            v-value = entry( v-counter, v-list-edt )
            v-ex = false
        .
           if  lookup (v-value , reasonme ) > 0 then  v-ex = true .
           else v-ex = false .
        run twowin_add-item in this-procedure (
              input v-value
            , input v-label
            , input substitute( "Документ: &1", v-VALUE)
            , input  V-EX
        ).
    end.
    run gbl/twowin.w (
          input ?
        , input 1
        , input "Выбор ДОКУМЕНТОВ - ИСКЛЮЧЕНИЙ":U
        , input "":U
        , input "&Тест"
        , input table temp_twowin_items
        , output table temp_twowin_itemsSelected_col
        , output v-changed
        , output v-accepted
    ).
    if v-changed then do:
        reasonme = "" .
        for each temp_twowin_itemsSelected_col :
        reasonme = reasonme +  temp_twowin_itemsSelected_col.itmExtKey + "," .
        end.
        reasonme = trim(reasonme, ",") .
        display reasonme with frame page-2 .
    end.
end.
END PROCEDURE.
