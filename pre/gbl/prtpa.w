define input parameter parparentproc as widget-handle no-undo.
define input parameter p-mode        as character no-undo.
define input parameter p-obj-type    like ub.clients.obj-type no-undo.
define input parameter p-obj-code    like ub.shop.obj-code no-undo.
define input parameter p-type        as char no-undo.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-Workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Настройки для ПЕЧАТНЫХ ФОРМ" .
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
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
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
define buffer obj_thbj-attr for ub.thbj-attr.
define buffer glb_thbj-attr for ub.thbj-attr.
define buffer frm_thbj-attr for ub.thbj-attr.
define temp-table temp-thbj-attr no-undo like ub.thbj-attr.
define variable v-ttho     as handle no-undo .
define variable v-tthg    as handle no-undo .
define variable v-tthf    as handle no-undo .
define variable v-to-create as logical no-undo.
define variable v-to-create-prt as logical no-undo.
define variable v-to-create-prt-g as logical no-undo.
define variable v-to-create-prt-f as logical no-undo.
define variable str-attr as character no-undo .
define temp-table thbjattr_thbj-attr-o no-undo like thbjattr_thbj-attr .
define temp-table thbjattr_thbj-attr-g no-undo like thbjattr_thbj-attr .
define temp-table thbjattr_thbj-attr-f no-undo like thbjattr_thbj-attr .
define variable v-obj-type  as character no-undo .
define variable v-obj-code as integer   no-undo .
define variable v-host-code as integer   no-undo .
define variable fl as character no-undo .
define variable v-twowin-point as character no-undo .
assign
v-ttho = buffer thbjattr_thbj-attr-o:table-handle .
v-tthg = buffer thbjattr_thbj-attr-g:table-handle .
v-tthf = buffer thbjattr_thbj-attr-f:table-handle .
 if g#db-num <> 0 and p-obj-type = "" and  p-obj-code = 0
    then p-mode = 'ПРОСМОТР':U .
DEFINE BUTTON B-1
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL ""
     SIZE 3 BY .92.
DEFINE BUTTON B-12
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL ""
     SIZE 3 BY .92.
DEFINE BUTTON B-13
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL ""
     SIZE 3 BY .92.
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
DEFINE BUTTON B-18
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE BUTTON B-19
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL ""
     SIZE 3 BY .92.
DEFINE BUTTON B-2
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE BUTTON B-20
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL ""
     SIZE 3 BY .92.
DEFINE BUTTON B-21
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL ""
     SIZE 3 BY .92.
DEFINE BUTTON B-22
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL ""
     SIZE 3 BY .92.
DEFINE BUTTON B-23
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL ""
     SIZE 3 BY .92.
DEFINE BUTTON B-24
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL ""
     SIZE 3 BY .92.
DEFINE BUTTON B-25
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL ""
     SIZE 3 BY .92.
DEFINE BUTTON B-26
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL ""
     SIZE 3 BY .92.
DEFINE BUTTON B-27
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL ""
     SIZE 3 BY .92.
DEFINE BUTTON B-3
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL ""
     SIZE 3 BY .92.
DEFINE BUTTON B-4
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL ""
     SIZE 3 BY .92.
DEFINE BUTTON B-5
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL ""
     SIZE 3 BY .92.
DEFINE BUTTON B-6
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL ""
     SIZE 3 BY .92.
DEFINE BUTTON B-7
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL ""
     SIZE 3 BY .92.
DEFINE BUTTON B-8
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL ""
     SIZE 3 BY .92.
DEFINE BUTTON B-9
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL ""
     SIZE 3 BY .92.
DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-Help
     LABEL "&Help"
     SIZE 3 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-outappr
     IMAGE-UP FILE "cmp/update.bmp":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE BUTTON B-outares
     IMAGE-UP FILE "cmp/update.bmp":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE BUTTON B-outasend
     IMAGE-UP FILE "cmp/update.bmp":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE BUTTON B-outdate
     IMAGE-UP FILE "cmp/update.bmp":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE BUTTON B-outdisc
     IMAGE-UP FILE "cmp/update.bmp":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE BUTTON B-outegrp
     IMAGE-UP FILE "cmp/update.bmp":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE BUTTON B-outhold
     IMAGE-UP FILE "cmp/update.bmp":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE BUTTON B-outnum
     IMAGE-UP FILE "cmp/update.bmp":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE BUTTON B-outobj
     IMAGE-UP FILE "cmp/update.bmp":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE BUTTON B-outprim
     IMAGE-UP FILE "cmp/update.bmp":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE BUTTON B-outrecv
     IMAGE-UP FILE "cmp/update.bmp":U
     LABEL "B-outrecv"
     SIZE 3 BY 1 TOOLTIP "Список типов единиц измерений".
DEFINE BUTTON B-outrubl
     IMAGE-UP FILE "cmp/update.bmp":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE BUTTON B-outsend
     IMAGE-UP FILE "cmp/update.bmp":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE BUTTON B-outsubs
     IMAGE-UP FILE "cmp/update.bmp":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE BUTTON B-outt12
     IMAGE-UP FILE "cmp/update.bmp":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE BUTTON B-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE VARIABLE outappr AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 10 BY 1
     FONT 4 NO-UNDO.
DEFINE VARIABLE outares AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 10 BY 1
     FONT 4 NO-UNDO.
DEFINE VARIABLE outasend AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 10 BY 1
     FONT 4 NO-UNDO.
DEFINE VARIABLE outdate AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 10 BY 1
     FONT 4 NO-UNDO.
DEFINE VARIABLE outdisc AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 10 BY 1
     FONT 4 NO-UNDO.
DEFINE VARIABLE outegrp AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 10 BY 1
     FONT 4 NO-UNDO.
DEFINE VARIABLE outhold AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 10 BY 1
     FONT 4 NO-UNDO.
DEFINE VARIABLE outnum AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 10 BY 1
     FONT 4 NO-UNDO.
DEFINE VARIABLE outobj AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 10 BY 1
     FONT 4 NO-UNDO.
DEFINE VARIABLE outprim AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 10 BY 1
     FONT 4 NO-UNDO.
DEFINE VARIABLE outrecv AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 45.25 BY 1
     FONT 4 NO-UNDO.
DEFINE VARIABLE outrubl AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 10 BY 1
     FONT 4 NO-UNDO.
DEFINE VARIABLE outsend AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 10 BY 1
     FONT 4 NO-UNDO.
DEFINE VARIABLE outsubs AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 10 BY 1
     FONT 4 NO-UNDO.
DEFINE VARIABLE outt12 AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 10 BY 1
     FONT 4 NO-UNDO.
DEFINE VARIABLE FILL-IN-1 AS CHARACTER FORMAT "X(256)":U INITIAL "Список печатных форм, для которых :"
      VIEW-AS TEXT
     SIZE 35.63 BY .67
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE FILL-IN-4 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 26 BY 1 NO-UNDO.
DEFINE VARIABLE in-docpr AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.
DEFINE VARIABLE v-factur01 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 91.63 BY .79 NO-UNDO.
DEFINE VARIABLE v-fgdsnind AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 70.63 BY .92 NO-UNDO.
DEFINE VARIABLE v-in-docpr AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 80.63 BY .79 NO-UNDO.
DEFINE VARIABLE v-incurrat AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 91.63 BY .79 NO-UNDO.
DEFINE VARIABLE v-invprn0 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 93.63 BY .79 NO-UNDO.
DEFINE VARIABLE v-outappr AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 59.63 BY .79 NO-UNDO.
DEFINE VARIABLE v-outares AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 82.25 BY .79 NO-UNDO.
DEFINE VARIABLE v-outasend AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 80 BY .79 NO-UNDO.
DEFINE VARIABLE v-outb AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 34.63 BY .79 NO-UNDO.
DEFINE VARIABLE v-outc AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 38.63 BY .79 NO-UNDO.
DEFINE VARIABLE v-outdate AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 20.75 BY .79 NO-UNDO.
DEFINE VARIABLE v-outdisc AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 80.63 BY .79 NO-UNDO.
DEFINE VARIABLE v-outegrp AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 31.75 BY .79 NO-UNDO.
DEFINE VARIABLE v-outhold AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 59 BY .79 NO-UNDO.
DEFINE VARIABLE v-outnum AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 30.75 BY .79 NO-UNDO.
DEFINE VARIABLE v-outobj AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 62 BY .79 NO-UNDO.
DEFINE VARIABLE v-outogr AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 34.63 BY .92 NO-UNDO.
DEFINE VARIABLE v-outprim AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 80 BY .79 NO-UNDO.
DEFINE VARIABLE v-outprncd AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 93.25 BY 1 NO-UNDO.
DEFINE VARIABLE v-outprops AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 80 BY .79 NO-UNDO.
DEFINE VARIABLE v-outR AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 34.63 BY .79 NO-UNDO.
DEFINE VARIABLE v-outrecv AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 48.25 BY .79 NO-UNDO.
DEFINE VARIABLE v-outrubl AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 82.25 BY .79 NO-UNDO.
DEFINE VARIABLE v-outsend AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 80 BY .79 NO-UNDO.
DEFINE VARIABLE v-outssdoc AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 49 BY .92 NO-UNDO.
DEFINE VARIABLE v-outsubs AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 80 BY .79 NO-UNDO.
DEFINE VARIABLE v-outt12 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 82.63 BY .79 NO-UNDO.
DEFINE VARIABLE v-rep-artic AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 80 BY .79 NO-UNDO.
DEFINE VARIABLE v-sort-prd AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 80 BY .79 NO-UNDO.
DEFINE VARIABLE v-tick-w AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 91.63 BY .79 NO-UNDO.
DEFINE VARIABLE v-torg2-no AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 80 BY .79 NO-UNDO.
DEFINE IMAGE I-factur01
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY .79.
DEFINE IMAGE I-fgdsnind
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY .79.
DEFINE IMAGE I-in-docpr
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY .79.
DEFINE IMAGE I-incurrat
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY .79.
DEFINE IMAGE I-invprn0
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY .79.
DEFINE IMAGE I-outappr
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY .79.
DEFINE IMAGE I-outares
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY .79.
DEFINE IMAGE I-outasend
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY .79.
DEFINE IMAGE I-outb
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY .79.
DEFINE IMAGE I-outc
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY .79.
DEFINE IMAGE I-outdate
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY .92.
DEFINE IMAGE I-outdisc
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY .79.
DEFINE IMAGE I-outegrp
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY .79.
DEFINE IMAGE I-outhold
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY .79.
DEFINE IMAGE I-outnum
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY .79.
DEFINE IMAGE I-outobj
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY .79.
DEFINE IMAGE I-outogr
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY .79.
DEFINE IMAGE I-outprim
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY .79.
DEFINE IMAGE I-outprncd
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY .79.
DEFINE IMAGE I-outprops
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY .79.
DEFINE IMAGE I-outR
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY .79.
DEFINE IMAGE I-outrecv
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY .79.
DEFINE IMAGE I-outrubl
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY .79.
DEFINE IMAGE I-outsend
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY .79.
DEFINE IMAGE I-outssdoc
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY .92.
DEFINE IMAGE I-outsubs
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY .79.
DEFINE IMAGE I-outt12
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY .79.
DEFINE IMAGE I-rep-artic
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY .79.
DEFINE IMAGE I-sort-prd
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY .79.
DEFINE IMAGE I-tick-w
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY .79.
DEFINE IMAGE I-torg2-no
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY .79.
DEFINE VARIABLE outb AS CHARACTER INITIAL "no_print"
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Item 1", "no_print",
"Item 2", "2",
"Item 3", "3"
     SIZE 54.25 BY .79
     FONT 4 NO-UNDO.
DEFINE VARIABLE outc AS CHARACTER INITIAL "clad_doc"
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Item 1", "no_print",
"Item 2", "2",
"Item 3", "3"
     SIZE 54.25 BY .79
     FONT 4 NO-UNDO.
DEFINE VARIABLE outogr AS CHARACTER INITIAL "no_print"
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Item 1", "no_print",
"Item 2", "2",
"Item 3", "3"
     SIZE 60 BY .79
     FONT 4 NO-UNDO.
DEFINE VARIABLE outR AS CHARACTER INITIAL "no_print"
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Item 1", "no_print",
"Item 2", "2",
"Item 3", "3"
     SIZE 54.25 BY .79
     FONT 4 NO-UNDO.
DEFINE VARIABLE outssdoc AS CHARACTER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Накладная", "nacl",
"Фин.док-т", "findoc",
"Пусто", ""
     SIZE 20 BY 2
     FONT 4 NO-UNDO.
DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL  GROUP-BOX
     SIZE 97 BY .75.
DEFINE VARIABLE factur01 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .79 NO-UNDO.
DEFINE VARIABLE fgdsnind AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 3 BY .92 NO-UNDO.
DEFINE VARIABLE incurrat AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2 BY .79 NO-UNDO.
DEFINE VARIABLE invprn0 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 39 BY .79 NO-UNDO.
DEFINE VARIABLE outprncd AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 50 BY 1 NO-UNDO.
DEFINE VARIABLE outprops AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 32.63 BY .79 NO-UNDO.
DEFINE VARIABLE rep-artic AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 47.25 BY .79 NO-UNDO.
DEFINE VARIABLE sort-prd AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 47.25 BY .79 NO-UNDO.
DEFINE VARIABLE tick-w AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2 BY .79 NO-UNDO.
DEFINE VARIABLE torg2-no AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 32.63 BY .79 NO-UNDO.
DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     B-quit AT ROW 1 COL 11
     B-Help AT ROW 1 COL 95
     RECT-2 AT ROW 2 COL 3.63 WIDGET-ID 346
     FILL-IN-4 AT ROW 2.25 COL 73 COLON-ALIGNED NO-LABEL WIDGET-ID 352
     invprn0 AT ROW 3 COL 4.63 WIDGET-ID 134
     outprncd AT ROW 3.75 COL 5 WIDGET-ID 148
     I-invprn0 AT ROW 3 COL 1.63 WIDGET-ID 136
     I-outprncd AT ROW 3.79 COL 1.63 WIDGET-ID 146
     v-invprn0 AT ROW 3 COL 6.63 NO-LABEL WIDGET-ID 138
     v-outprncd AT ROW 3.75 COL 7.25 NO-LABEL WIDGET-ID 150
     B-outrecv AT ROW 10.21 COL 48.75 WIDGET-ID 154
     outrecv AT ROW 10.25 COL 2.75 NO-LABEL WIDGET-ID 152
     v-outrecv AT ROW 10.21 COL 51.75 NO-LABEL WIDGET-ID 144
     I-outrecv AT ROW 10.29 COL 1 WIDGET-ID 142
     I-sort-prd AT ROW 13.25 COL 1 WIDGET-ID 162
     rep-artic AT ROW 12.25 COL 2.75 WIDGET-ID 480
     v-rep-artic AT ROW 12.25 COL 6 NO-LABEL WIDGET-ID 482
     I-rep-artic AT ROW 12.25 COL 1 WIDGET-ID 484
     outprops AT ROW 15.25 COL 2.75 WIDGET-ID 416
     v-outprops AT ROW 15.25 COL 5.25 NO-LABEL WIDGET-ID 418
     I-outprops AT ROW 15.25 COL 1 WIDGET-ID 414
     sort-prd AT ROW 13.25 COL 2.75 WIDGET-ID 164
     torg2-no AT ROW 14.25 COL 2.75 WIDGET-ID 286
     v-sort-prd AT ROW 13.25 COL 6 NO-LABEL WIDGET-ID 166
     v-torg2-no AT ROW 14.25 COL 6 NO-LABEL WIDGET-ID 216
     I-torg2-no AT ROW 14.25 COL 1 WIDGET-ID 212
     B-14 AT ROW 3.58 COL 2.75 WIDGET-ID 354
     factur01 AT ROW 3.58 COL 6 WIDGET-ID 358
     B-15 AT ROW 4.46 COL 2.75 WIDGET-ID 362
     incurrat AT ROW 4.46 COL 6 WIDGET-ID 364
     B-16 AT ROW 5.33 COL 2.75 WIDGET-ID 370
     tick-w AT ROW 5.33 COL 6 WIDGET-ID 374
     FILL-IN-4 AT ROW 2.25 COL 73 COLON-ALIGNED NO-LABEL WIDGET-ID 352
     v-factur01 AT ROW 3.58 COL 9.63 NO-LABEL WIDGET-ID 360
     v-incurrat AT ROW 4.46 COL 7.63 COLON-ALIGNED NO-LABEL WIDGET-ID 368
     v-tick-w AT ROW 5.33 COL 9.63 NO-LABEL WIDGET-ID 376
     RECT-2 AT ROW 2 COL 3.63 WIDGET-ID 346
     I-factur01 AT ROW 3.58 COL 1 WIDGET-ID 356
     I-incurrat AT ROW 4.46 COL 1 WIDGET-ID 366
     I-tick-w AT ROW 5.33 COL 1 WIDGET-ID 372
     B-1 AT ROW 2.21 COL 3 WIDGET-ID 392
     fgdsnind AT ROW 2.21 COL 6 WIDGET-ID 236
     v-fgdsnind AT ROW 2.21 COL 21 NO-LABEL WIDGET-ID 6
     I-fgdsnind AT ROW 2.21 COL 1 WIDGET-ID 10
     B-20 AT ROW 3.25 COL 3 WIDGET-ID 80
     outssdoc AT ROW 3.25 COL 57.5 NO-LABEL WIDGET-ID 280
     v-outssdoc AT ROW 3.25 COL 6 NO-LABEL WIDGET-ID 234
     I-outssdoc AT ROW 3.29 COL 1 WIDGET-ID 230
     B-2 AT ROW 5.75 COL 3 WIDGET-ID 82
     in-docpr AT ROW 5.75 COL 6 NO-LABEL WIDGET-ID 238
     I-in-docpr AT ROW 5.79 COL 1 WIDGET-ID 34
     v-in-docpr AT ROW 5.75 COL 21 NO-LABEL WIDGET-ID 18
     B-24 AT ROW 7 COL 3 WIDGET-ID 430
     outR AT ROW 7 COL 48 NO-LABEL WIDGET-ID 438
     v-outR AT ROW 7 COL 6 NO-LABEL WIDGET-ID 436
     I-outR AT ROW 7.04 COL 1 WIDGET-ID 432
     B-26 AT ROW 9.88 COL 3 WIDGET-ID 388
     outb AT ROW 9.88 COL 48 NO-LABEL WIDGET-ID 456
     v-outb AT ROW 9.88 COL 6 NO-LABEL WIDGET-ID 460 DISABLE-AUTO-ZAP
     I-outb AT ROW 9.92 COL 1 WIDGET-ID 454
     B-25 AT ROW 7.92 COL 3 WIDGET-ID 326
     outogr AT ROW 7.92 COL 48 NO-LABEL WIDGET-ID 446
     v-outogr AT ROW 7.92 COL 6 NO-LABEL WIDGET-ID 450
     I-outogr AT ROW 7.96 COL 1 WIDGET-ID 444
     B-27 AT ROW 8.92 COL 3 WIDGET-ID 462
     outc AT ROW 8.92 COL 48 NO-LABEL WIDGET-ID 466
     v-outc AT ROW 8.92 COL 6 NO-LABEL WIDGET-ID 464 DISABLE-AUTO-ZAP
     I-outc AT ROW 8.96 COL 1 WIDGET-ID 470
     B-3 AT ROW 11.96 COL 3 WIDGET-ID 84
     outdisc AT ROW 11.96 COL 6 NO-LABEL WIDGET-ID 240
     v-outdisc AT ROW 12.04 COL 19 NO-LABEL WIDGET-ID 54
     I-outdisc AT ROW 12 COL 1 WIDGET-ID 50
     B-outdisc AT ROW 11.96 COL 15.75 WIDGET-ID 250
     B-4 AT ROW 12.96 COL 3 WIDGET-ID 86
     outegrp AT ROW 12.96 COL 6 NO-LABEL WIDGET-ID 242
     B-outegrp AT ROW 12.96 COL 15.75 WIDGET-ID 248
     v-outegrp AT ROW 13.04 COL 19 NO-LABEL WIDGET-ID 60
     I-outegrp AT ROW 13.04 COL 1 WIDGET-ID 56
     B-9 AT ROW 13.96 COL 3 WIDGET-ID 108
     outobj AT ROW 13.96 COL 6 NO-LABEL WIDGET-ID 252
     B-outobj AT ROW 13.96 COL 15.75 WIDGET-ID 254
     v-outobj AT ROW 14.04 COL 19 NO-LABEL WIDGET-ID 114
     I-outobj AT ROW 14 COL 1 WIDGET-ID 110
     B-5 AT ROW 14.96 COL 3 WIDGET-ID 88
     outappr AT ROW 14.96 COL 6 NO-LABEL WIDGET-ID 256
     B-outappr AT ROW 14.96 COL 15.75 WIDGET-ID 258
     v-outappr AT ROW 15.04 COL 19 NO-LABEL WIDGET-ID 66
     I-outappr AT ROW 15 COL 1 WIDGET-ID 64
     B-6 AT ROW 15.96 COL 3 WIDGET-ID 90
     outdate AT ROW 15.96 COL 6 NO-LABEL WIDGET-ID 262
     B-outdate AT ROW 15.96 COL 15.75 WIDGET-ID 260
     v-outdate AT ROW 16.04 COL 19 NO-LABEL WIDGET-ID 78
     I-outdate AT ROW 16 COL 1 WIDGET-ID 72
     B-8 AT ROW 16.96 COL 3 WIDGET-ID 100
     outnum AT ROW 16.96 COL 6 NO-LABEL WIDGET-ID 266
     B-outnum AT ROW 16.96 COL 15.75 WIDGET-ID 264
     v-outnum AT ROW 17 COL 19 NO-LABEL WIDGET-ID 106
     I-outnum AT ROW 17 COL 1 WIDGET-ID 104
     B-7 AT ROW 17.96 COL 3 WIDGET-ID 92
     outhold AT ROW 17.96 COL 6 NO-LABEL WIDGET-ID 244
     B-outhold AT ROW 17.96 COL 15.75 WIDGET-ID 246
     v-outhold AT ROW 18.04 COL 19 NO-LABEL WIDGET-ID 98
     I-outhold AT ROW 18 COL 1 WIDGET-ID 94
     B-12 AT ROW 18.96 COL 3 WIDGET-ID 316
     outsubs AT ROW 18.96 COL 6 NO-LABEL WIDGET-ID 322
     B-outsubs AT ROW 18.96 COL 15.75 WIDGET-ID 318
     v-outsubs AT ROW 19.04 COL 19 NO-LABEL WIDGET-ID 324
     I-outsubs AT ROW 19 COL 1 WIDGET-ID 320
     B-13 AT ROW 19.96 COL 3 WIDGET-ID 442
     outt12 AT ROW 19.96 COL 6 NO-LABEL WIDGET-ID 332
     B-outt12 AT ROW 19.96 COL 15.75 WIDGET-ID 328
     I-outt12 AT ROW 20 COL 1 WIDGET-ID 330
     v-outt12 AT ROW 20.04 COL 19 NO-LABEL WIDGET-ID 334
     B-18 AT ROW 20.96 COL 3 WIDGET-ID 452
     outprim AT ROW 20.96 COL 6 NO-LABEL WIDGET-ID 296
     B-outprim AT ROW 20.96 COL 15.75 WIDGET-ID 294
     v-outprim AT ROW 21.04 COL 19 NO-LABEL WIDGET-ID 222
     I-outprim AT ROW 21 COL 1 WIDGET-ID 218
     B-19 AT ROW 21.96 COL 3 WIDGET-ID 390
     outrubl AT ROW 21.96 COL 6 NO-LABEL WIDGET-ID 292
     B-outrubl AT ROW 21.96 COL 15.75 WIDGET-ID 290
     I-outrubl AT ROW 22 COL 1 WIDGET-ID 224
     v-outrubl AT ROW 22.04 COL 19 NO-LABEL WIDGET-ID 228
     B-21 AT ROW 22.96 COL 3 WIDGET-ID 394
     outares AT ROW 22.96 COL 6 NO-LABEL WIDGET-ID 406
     B-outares AT ROW 22.96 COL 15.75 WIDGET-ID 398
     I-outares AT ROW 23 COL 1 WIDGET-ID 402
     v-outares AT ROW 23.04 COL 19 NO-LABEL WIDGET-ID 410
     B-22 AT ROW 23.96 COL 3 WIDGET-ID 396
     outsend AT ROW 23.96 COL 6 NO-LABEL WIDGET-ID 408
     B-outsend AT ROW 23.96 COL 15.75 WIDGET-ID 400
     I-outsend AT ROW 24 COL 1 WIDGET-ID 404
     v-outsend AT ROW 24.04 COL 19 NO-LABEL WIDGET-ID 412
     B-23 AT ROW 24.96 COL 3 WIDGET-ID 420
     outasend AT ROW 24.96 COL 6 NO-LABEL WIDGET-ID 426
     B-outasend AT ROW 24.96 COL 15.75 WIDGET-ID 422
     I-outasend AT ROW 25.04 COL 1 WIDGET-ID 424
     v-outasend AT ROW 25.04 COL 19 NO-LABEL WIDGET-ID 428
     FILL-IN-1 AT ROW 11.25 COL 1.75 NO-LABEL WIDGET-ID 336
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         DEFAULT-BUTTON B-exit CANCEL-BUTTON B-quit WIDGET-ID 100.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       invprn0:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       outappr:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       outares:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       outasend:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       outdate:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       outdisc:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       outegrp:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       outhold:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       outnum:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       outobj:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       outprim:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       outrecv:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       outrubl:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       outsend:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       outsubs:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       outt12:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       v-factur01:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       v-fgdsnind:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       v-in-docpr:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       v-incurrat:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       v-invprn0:HIDDEN IN FRAME Dialog-Frame           = TRUE
       v-invprn0:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       v-outappr:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       v-outares:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       v-outasend:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       v-outb:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       v-outc:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       v-outdate:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       v-outdisc:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       v-outegrp:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       v-outhold:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       v-outnum:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       v-outobj:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       v-outogr:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       v-outprim:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       v-outprncd:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       v-outprops:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       v-outR:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       v-outrecv:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       v-outrubl:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       v-outsend:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       v-outssdoc:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       v-outsubs:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       v-outt12:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       v-rep-artic:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       v-sort-prd:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       v-tick-w:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       v-torg2-no:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ON GO OF FRAME Dialog-Frame
DO:
  run save-proc in this-procedure no-error.
  if error-status :error then return no-apply.
END.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF B-1 IN FRAME Dialog-Frame
DO:
  run gbl/v-taobj.w
      ('prt-obj':U,
       "fgdsnind"
       ).
END.
ON CHOOSE OF B-12 IN FRAME Dialog-Frame
DO:
  run gbl/v-taobj.w
      ('prt-obj':U,
       "outsubs"
       ).
END.
ON CHOOSE OF B-13 IN FRAME Dialog-Frame
DO:
  run gbl/v-taobj.w
      ('prt-obj':U,
       "outt12"
       ).
END.
ON CHOOSE OF B-14 IN FRAME Dialog-Frame
DO:
  run gbl/v-taobj.w
      ('prt-firm':U,
       "factur01"
       ).
END.
ON CHOOSE OF B-15 IN FRAME Dialog-Frame
DO:
  run gbl/v-taobj.w
      ('prt-firm':U,
       "incurrat"
       ).
END.
ON CHOOSE OF B-16 IN FRAME Dialog-Frame
DO:
  run gbl/v-taobj.w
      ('prt-firm':U,
       "tick-w"
       ).
END.
ON CHOOSE OF B-18 IN FRAME Dialog-Frame
DO:
  run gbl/v-taobj.w
      ('prt-obj':U,
       "outprim"
       ).
END.
ON CHOOSE OF B-19 IN FRAME Dialog-Frame
DO:
  run gbl/v-taobj.w
      ('prt-obj':U,
       "outrubl"
       ).
END.
ON CHOOSE OF B-2 IN FRAME Dialog-Frame
DO:
  run gbl/v-taobj.w
      ('prt-obj':U,
       "in-docpr"
       ).
END.
ON CHOOSE OF B-20 IN FRAME Dialog-Frame
DO:
  run gbl/v-taobj.w
      ('prt-obj':U,
       "outssdoc"
       ).
END.
ON CHOOSE OF B-21 IN FRAME Dialog-Frame
DO:
  run gbl/v-taobj.w
      ('prt-obj':U,
       "outares"
       ).
END.
ON CHOOSE OF B-22 IN FRAME Dialog-Frame
DO:
  run gbl/v-taobj.w
      ('prt-obj':U,
       "outsend"
       ).
END.
ON CHOOSE OF B-23 IN FRAME Dialog-Frame
DO:
  run gbl/v-taobj.w
      ('prt-obj':U,
       "outasend"
       ).
END.
ON CHOOSE OF B-24 IN FRAME Dialog-Frame
DO:
  run gbl/v-taobj.w
      ('prt-obj':U,
       "outR"
       ).
END.
ON CHOOSE OF B-25 IN FRAME Dialog-Frame
DO:
  run gbl/v-taobj.w
      ('prt-obj':U,
       "outogr"
       ).
END.
ON CHOOSE OF B-26 IN FRAME Dialog-Frame
DO:
  run gbl/v-taobj.w
      ('prt-obj':U,
       "outb"
       ).
END.
ON CHOOSE OF B-27 IN FRAME Dialog-Frame
DO:
  run gbl/v-taobj.w
      ('prt-obj':U,
       "outc"
       ).
END.
ON CHOOSE OF B-3 IN FRAME Dialog-Frame
DO:
  run gbl/v-taobj.w
      ('prt-obj':U,
       "outdisc"
       ).
END.
ON CHOOSE OF B-4 IN FRAME Dialog-Frame
DO:
  run gbl/v-taobj.w
      ('prt-obj':U,
       "outegrp"
       ).
END.
ON CHOOSE OF B-5 IN FRAME Dialog-Frame
DO:
  run gbl/v-taobj.w
      ('prt-obj':U,
       "outappr"
       ).
END.
ON CHOOSE OF B-6 IN FRAME Dialog-Frame
DO:
  run gbl/v-taobj.w
      ('prt-obj':U,
       "outdate"
       ).
END.
ON CHOOSE OF B-7 IN FRAME Dialog-Frame
DO:
  run gbl/v-taobj.w
      ('prt-obj':U,
       "outhold"
       ).
END.
ON CHOOSE OF B-8 IN FRAME Dialog-Frame
DO:
  run gbl/v-taobj.w
      ('prt-obj':U,
       "outnum"
       ).
END.
ON CHOOSE OF B-9 IN FRAME Dialog-Frame
DO:
  run gbl/v-taobj.w
      ('prt-obj':U,
       "outobj"
       ).
END.
ON CHOOSE OF B-outappr IN FRAME Dialog-Frame
DO:
 if p-mode = 'ПРОСМОТР':U then return .
    run twowin_clear in this-procedure.
    define variable v-accepted      as logical      no-undo.
    define variable v-cur-ext-key   as character    no-undo.
    run twowin_add-item in this-procedure ( input "",  input   "ПУСТО" , input "" , input no ).
    run twowin_add-item in this-procedure ( input 'torg12',  input  "ТОРГ12", input "Печатная форма ТОРГ-12",            input (if lookup ('torg12' , outappr ) > 0 then  true  else false )  ).
    run twowin_add-item in this-procedure ( input 'torg13',  input  "ТОРГ13", input "Печатная форма ТОРГ-13",            input (if lookup ('torg13' , outappr ) > 0 then  true  else false )  ).
    run twowin_add-item in this-procedure ( input 'torg16',  input  "ТОРГ16", input "Печатная форма ТОРГ-16",            input (if lookup ('torg16' , outappr ) > 0 then  true  else false )  ).
    run twowin_add-item in this-procedure ( input 'factur',  input  "Счет-фактура", input "Печатная форма Счет-фактура", input (if lookup ('factur' , outappr ) > 0 then  true  else false )  ).
    run twowin_add-item in this-procedure ( input 'schet',   input  "Счет",         input "Печатная форма Счет",         input (if lookup ('schet'  , outappr ) > 0 then  true  else false )  ).
    run gbl/twowin.w (
          input ?
        , input 1
        , input "Выбор из списка форм"
        , input ""
        , input ""
        , input table temp_twowin_items
        , output table temp_twowin_itemsSelected_col
        , output v-cur-ext-key
        , output v-accepted
    ).
    if v-accepted and can-find (first temp_twowin_itemsSelected_col) then do:
    outappr = ''.
    for each temp_twowin_itemsSelected_col
    :
      outappr = outappr + temp_twowin_itemsSelected_col.itmExtKey + "," .
    end.
    outappr = trim(outappr,"," ).
 end.
 DISPLAY outappr with FRAME Dialog-Frame.
END.
ON CHOOSE OF B-outares IN FRAME Dialog-Frame
DO:
 if p-mode = 'ПРОСМОТР':U then return .
    run twowin_clear in this-procedure.
    define variable v-accepted      as logical      no-undo.
    define variable v-cur-ext-key   as character    no-undo.
    run twowin_add-item in this-procedure ( input "",  input   "ПУСТО" , input "" , input no ).
    run twowin_add-item in this-procedure ( input 'torg12',   input  "ТОРГ12", input "Печатная форма ТОРГ-12",                                 input (if lookup ('torg12'   , outares ) > 0 then  true  else false ) ).
    run twowin_add-item in this-procedure ( input 'torg12n',  input  "ТОРГ12 с окр", input "Печатная форма ТОРГ-12 с округлением",             input (if lookup ('torg12n'  , outares ) > 0 then  true  else false ) ).
    run twowin_add-item in this-procedure ( input 'torg12z',  input  "ТОРГ12 для ювел.изд.", input "Печатная форма ТОРГ-12 для ювел.изделий ", input (if lookup ('torg12z'  , outares ) > 0 then  true  else false ) ).
    run twowin_add-item in this-procedure ( input 'torg13',   input  "ТОРГ13", input "Печатная форма ТОРГ-13",                                 input (if lookup ('torg13'   , outares ) > 0 then  true  else false ) ).
    run twowin_add-item in this-procedure ( input 'torg16',   input  "ТОРГ16", input "Печатная форма ТОРГ-16",                                 input (if lookup ('torg16'   , outares ) > 0 then  true  else false ) ).
    run twowin_add-item in this-procedure ( input 'factur',   input  "Счет-фактура", input "Печатная форма Счет-фактура",                      input (if lookup ('factur'   , outares ) > 0 then  true  else false ) ).
    run twowin_add-item in this-procedure ( input 'facturn',   input  "Счет-фактура с окр", input "Печатная форма Счет-фактура с округлением", input (if lookup ('facturn'  , outares ) > 0 then  true  else false ) ).
    run twowin_add-item in this-procedure ( input 'schet',    input  "Счет",         input "Печатная форма Счет",                              input (if lookup ('schet'    , outares ) > 0 then  true  else false ) ).
    run twowin_add-item in this-procedure ( input 'oldinp',   input  "Приходная Накладная", input "Печатная форма по ПН",                      input (if lookup ('oldinp'   , outares ) > 0 then  true  else false ) ).
    run twowin_add-item in this-procedure ( input 'oldexp',   input  "Накладная Расходная", input "Печатная форма по РН",                      input (if lookup ('oldexp'   , outares ) > 0 then  true  else false )).
    run twowin_add-item in this-procedure ( input 'torg1',   input  "Торг1", input "Акт приемки товара",                                       input (if lookup ('torg1'    , outares ) > 0 then  true  else false )).
    run gbl/twowin.w (
          input ?
        , input 1
        , input "Выбор из списка форм"
        , input ""
        , input ""
        , input table temp_twowin_items
        , output table temp_twowin_itemsSelected_col
        , output v-cur-ext-key
        , output v-accepted
    ).
    if v-accepted and can-find (first temp_twowin_itemsSelected_col) then do:
    outares = ''.
    for each temp_twowin_itemsSelected_col
    :
      outares = outares + temp_twowin_itemsSelected_col.itmExtKey + "," .
    end.
    outares = trim(outares,"," ).
 end.
 DISPLAY outares with FRAME Dialog-Frame.
END.
ON CHOOSE OF B-outasend IN FRAME Dialog-Frame
DO:
 if p-mode = 'ПРОСМОТР':U then return .
    run twowin_clear in this-procedure.
    define variable v-accepted      as logical      no-undo.
    define variable v-cur-ext-key   as character    no-undo.
    run twowin_add-item in this-procedure ( input "",         input   "ПУСТО" , input "" , input no ).
    run twowin_add-item in this-procedure ( input 'torg12',   input  "ТОРГ12", input "Печатная форма ТОРГ-12",                                 input (if lookup ('torg12'     , outasend ) > 0 then  true  else false ) ).
    run twowin_add-item in this-procedure ( input 'torg12n',  input  "ТОРГ12 с окр", input "Печатная форма ТОРГ-12 с округлением",             input (if lookup ('torg12n'    , outasend ) > 0 then  true  else false ) ).
    run twowin_add-item in this-procedure ( input 'torg12z',  input  "ТОРГ12 для ювел.изд.", input "Печатная форма ТОРГ-12 для ювел.изделий ", input (if lookup ('torg12z'    , outasend ) > 0 then  true  else false ) ).
    run twowin_add-item in this-procedure ( input 'torg13',   input  "ТОРГ13", input "Печатная форма ТОРГ-13",                                 input (if lookup ('torg13'     , outasend ) > 0 then  true  else false ) ).
    run twowin_add-item in this-procedure ( input 'torg16',   input  "ТОРГ16", input "Печатная форма ТОРГ-16",                                 input (if lookup ('torg16'     , outasend ) > 0 then  true  else false ) ).
    run twowin_add-item in this-procedure ( input 'factur',   input  "Счет-фактура", input "Печатная форма Счет-фактура",                      input (if lookup ('factur'     , outasend ) > 0 then  true  else false ) ).
    run twowin_add-item in this-procedure ( input 'facturn',  input  "Счет-фактура с окр", input "Печатная форма Счет-фактура с округлением",  input (if lookup ('facturn'    , outasend ) > 0 then  true  else false ) ).
    run twowin_add-item in this-procedure ( input 'schet',    input  "Счет",         input "Печатная форма Счет",                              input (if lookup ('schet'      , outasend ) > 0 then  true  else false ) ).
    run twowin_add-item in this-procedure ( input 'oldinp',   input  "Приходная Накладная", input "Печатная форма по ПН",                      input (if lookup ('oldinp'     , outasend ) > 0 then  true  else false ) ).
    run twowin_add-item in this-procedure ( input 'oldexp',   input  "Накладная Расходная", input "Печатная форма по РН",                      input (if lookup ('oldexp'     , outasend ) > 0 then  true  else false ) ).
    run gbl/twowin.w (
          input ?
        , input 1
        , input "Выбор из списка форм"
        , input ""
        , input ""
        , input table temp_twowin_items
        , output table temp_twowin_itemsSelected_col
        , output v-cur-ext-key
        , output v-accepted
    ).
    if v-accepted and can-find (first temp_twowin_itemsSelected_col) then do:
    outasend = ''.
    for each temp_twowin_itemsSelected_col
    :
      outasend = outasend + temp_twowin_itemsSelected_col.itmExtKey + "," .
    end.
    outasend = trim(outasend,"," ).
 end.
 DISPLAY outasend with FRAME Dialog-Frame.
END.
ON CHOOSE OF B-outdate IN FRAME Dialog-Frame
DO:
 if p-mode = 'ПРОСМОТР':U then return .
    run twowin_clear in this-procedure.
    define variable v-accepted      as logical      no-undo.
    define variable v-cur-ext-key   as character    no-undo.
    run twowin_add-item in this-procedure ( input "",  input   "ПУСТО" , input "" , input no ).
    run twowin_add-item in this-procedure ( input 'torg12',   input  "ТОРГ12", input "Печатная форма ТОРГ-12",                                 input (if lookup ('torg12'     , outdate ) > 0 then  true  else false )  ).
    run twowin_add-item in this-procedure ( input 'torg12n',  input  "ТОРГ12 с окр", input "Печатная форма ТОРГ-12 с округлением",             input (if lookup ('torg12n'    , outdate ) > 0 then  true  else false )  ).
    run twowin_add-item in this-procedure ( input 'torg12z',  input  "ТОРГ12 для ювел.изд.", input "Печатная форма ТОРГ-12 для ювел.изделий ", input (if lookup ('torg12z'    , outdate ) > 0 then  true  else false )  ).
    run twowin_add-item in this-procedure ( input 'torg13',   input  "ТОРГ13", input "Печатная форма ТОРГ-13",                                 input (if lookup ('torg13'     , outdate ) > 0 then  true  else false )  ).
    run twowin_add-item in this-procedure ( input 'torg16',   input  "ТОРГ16", input "Печатная форма ТОРГ-16",                                 input (if lookup ('torg16'     , outdate ) > 0 then  true  else false )  ).
    run twowin_add-item in this-procedure ( input 'factur',   input  "Счет-фактура", input "Печатная форма Счет-фактура",                      input (if lookup ('factur'     , outdate ) > 0 then  true  else false )  ).
    run twowin_add-item in this-procedure ( input 'facturn',   input  "Счет-фактура с окр", input "Печатная форма Счет-фактура с округлением", input (if lookup ('facturn'    , outdate ) > 0 then  true  else false )  ).
    run twowin_add-item in this-procedure ( input 'schet',    input  "Счет",         input "Печатная форма Счет",                              input (if lookup ('schet'      , outdate ) > 0 then  true  else false )  ).
    run twowin_add-item in this-procedure ( input 'oldinp',   input  "Приходная Накладная", input "Печатная форма по ПН",                      input (if lookup ('oldinp'     , outdate ) > 0 then  true  else false )  ).
    run twowin_add-item in this-procedure ( input 'oldexp',   input  "Накладная Расходная", input "Печатная форма по РН",                      input (if lookup ('oldexp'     , outdate ) > 0 then  true  else false )  ).
    run gbl/twowin.w (
          input ?
        , input 1
        , input "Выбор из списка форм"
        , input ""
        , input ""
        , input table temp_twowin_items
        , output table temp_twowin_itemsSelected_col
        , output v-cur-ext-key
        , output v-accepted
    ).
    if v-accepted and can-find (first temp_twowin_itemsSelected_col) then do:
    outdate = ''.
    for each temp_twowin_itemsSelected_col
    :
      outdate = outdate + temp_twowin_itemsSelected_col.itmExtKey + "," .
    end.
    outdate = trim(outdate,"," ).
 end.
 DISPLAY outdate with FRAME Dialog-Frame.
END.
ON CHOOSE OF B-outdisc IN FRAME Dialog-Frame
DO:
 if p-mode = 'ПРОСМОТР':U then return .
    run twowin_clear in this-procedure.
    define variable v-accepted      as logical      no-undo.
    define variable v-cur-ext-key   as character    no-undo.
    run twowin_add-item in this-procedure ( input "",  input   "ПУСТО" , input "" , input no ).
    run twowin_add-item in this-procedure ( input 'torg12',   input  "ТОРГ12", input "Печатная форма ТОРГ-12",                                 input (if lookup ('torg12'     , outdisc ) > 0 then  true  else false ) ).
    run twowin_add-item in this-procedure ( input 'torg12n',  input  "ТОРГ12 с окр", input "Печатная форма ТОРГ-12 с округлением",             input (if lookup ('torg12n'     , outdisc ) > 0 then  true  else false )  ).
    run twowin_add-item in this-procedure ( input 'torg12z',  input  "ТОРГ12 для ювел.изд.", input "Печатная форма ТОРГ-12 для ювел.изделий ", input (if lookup ('torg12z'     , outdisc ) > 0 then  true  else false ) ).
    run twowin_add-item in this-procedure ( input 'torg13',   input  "ТОРГ13", input "Печатная форма ТОРГ-13",                                 input (if lookup ('torg13'     , outdisc ) > 0 then  true  else false )  ).
    run twowin_add-item in this-procedure ( input 'torg16',   input  "ТОРГ16", input "Печатная форма ТОРГ-16",                                 input (if lookup ('torg16'     , outdisc ) > 0 then  true  else false ) ).
    run twowin_add-item in this-procedure ( input 'factur',   input  "Счет-фактура", input "Печатная форма Счет-фактура",                      input (if lookup ('factur'     , outdisc ) > 0 then  true  else false )  ).
    run twowin_add-item in this-procedure ( input 'facturn',   input  "Счет-фактура с окр", input "Печатная форма Счет-фактура с округлением", input (if lookup ('facturn'     , outdisc ) > 0 then  true  else false )  ).
    run twowin_add-item in this-procedure ( input 'schet',    input  "Счет",         input "Печатная форма Счет",                              input (if lookup ('schet'     , outdisc ) > 0 then  true  else false )  ).
    run twowin_add-item in this-procedure ( input 'oldinp',   input  "Приходная Накладная", input "Печатная форма по ПН",                      input (if lookup ('oldinp'     , outdisc ) > 0 then  true  else false )  ).
    run twowin_add-item in this-procedure ( input 'oldexp',   input  "Накладная Расходная", input "Печатная форма по РН",                      input (if lookup ('oldexp'     , outdisc ) > 0 then  true  else false )  ).
    run gbl/twowin.w (
          input ?
        , input 1
        , input "Выбор из списка форм"
        , input ""
        , input ""
        , input table temp_twowin_items
        , output table temp_twowin_itemsSelected_col
        , output v-cur-ext-key
        , output v-accepted
    ).
    if v-accepted and can-find (first temp_twowin_itemsSelected_col) then do:
    outdisc = ''.
    for each temp_twowin_itemsSelected_col
    :
      outdisc = outdisc + temp_twowin_itemsSelected_col.itmExtKey + "," .
    end.
    outdisc = trim(outdisc,"," ).
 end.
 DISPLAY outdisc with FRAME Dialog-Frame.
END.
ON CHOOSE OF B-outegrp IN FRAME Dialog-Frame
DO:
 if p-mode = 'ПРОСМОТР':U then return .
    run twowin_clear in this-procedure.
    define variable v-accepted      as logical      no-undo.
    define variable v-cur-ext-key   as character    no-undo.
    run twowin_add-item in this-procedure ( input "",  input   "ПУСТО" , input "" , input no ).
    run twowin_add-item in this-procedure ( input 'torg12',   input  "ТОРГ12", input "Печатная форма ТОРГ-12",                                 input ( if lookup ('torg12'     , outegrp ) > 0 then  true  else false )  ).
    run twowin_add-item in this-procedure ( input 'torg12n',  input  "ТОРГ12 с окр", input "Печатная форма ТОРГ-12 с округлением",             input ( if lookup ('torg12n'     , outegrp ) > 0 then  true  else false )  ).
    run twowin_add-item in this-procedure ( input 'torg12z',  input  "ТОРГ12 для ювел.изд.", input "Печатная форма ТОРГ-12 для ювел.изделий ", input ( if lookup ('torg12z'     , outegrp ) > 0 then  true  else false ) ).
    run twowin_add-item in this-procedure ( input 'torg13',   input  "ТОРГ13", input "Печатная форма ТОРГ-13",                                 input ( if lookup ('torg13'     , outegrp ) > 0 then  true  else false ) ).
    run twowin_add-item in this-procedure ( input 'torg16',   input  "ТОРГ16", input "Печатная форма ТОРГ-16",                                 input ( if lookup ('torg16'     , outegrp ) > 0 then  true  else false ) ).
    run twowin_add-item in this-procedure ( input 'factur',   input  "Счет-фактура", input "Печатная форма Счет-фактура",                      input ( if lookup ('factur'     , outegrp ) > 0 then  true  else false ) ).
    run twowin_add-item in this-procedure ( input 'facturn',   input  "Счет-фактура с окр", input "Печатная форма Счет-фактура с округлением", input ( if lookup ('facturn'     , outegrp ) > 0 then  true  else false ) ).
    run twowin_add-item in this-procedure ( input 'schet',    input  "Счет",         input "Печатная форма Счет",                              input ( if lookup ('schet'     , outegrp ) > 0 then  true  else false ) ).
    run twowin_add-item in this-procedure ( input 'oldinp',   input  "Приходная Накладная", input "Печатная форма по ПН",                      input ( if lookup ('oldinp'     , outegrp ) > 0 then  true  else false ) ).
    run twowin_add-item in this-procedure ( input 'oldexp',   input  "Накладная Расходная", input "Печатная форма по РН",                      input ( if lookup ('oldexp'     , outegrp ) > 0 then  true  else false ) ).
    run gbl/twowin.w (
          input ?
        , input 1
        , input "Выбор из списка форм"
        , input ""
        , input ""
        , input table temp_twowin_items
        , output table temp_twowin_itemsSelected_col
        , output v-cur-ext-key
        , output v-accepted
    ).
    if v-accepted and can-find (first temp_twowin_itemsSelected_col) then do:
    outegrp = ''.
    for each temp_twowin_itemsSelected_col
    :
      outegrp = outegrp + temp_twowin_itemsSelected_col.itmExtKey + "," .
    end.
    outegrp = trim(outegrp,"," ).
 end.
 DISPLAY outegrp with FRAME Dialog-Frame.
END.
ON CHOOSE OF B-outhold IN FRAME Dialog-Frame
DO:
 if p-mode = 'ПРОСМОТР':U then return .
    run twowin_clear in this-procedure.
    define variable v-accepted      as logical      no-undo.
    define variable v-cur-ext-key   as character    no-undo.
    run twowin_add-item in this-procedure ( input "",         input   "ПУСТО" , input "" ,                                input  no ).
    run twowin_add-item in this-procedure ( input 'torg12',   input  "ТОРГ12", input "Печатная форма ТОРГ-12",            input ( if lookup ('torg12' , outhold ) > 0 then  true  else false )).
    run twowin_add-item in this-procedure ( input 'factur',   input  "Счет-фактура", input "Печатная форма Счет-фактура", input ( if lookup ('factur' , outhold ) > 0 then  true  else false )).
    run twowin_add-item in this-procedure ( input 'schet',    input  "Счет",         input "Печатная форма Счет",         input ( if lookup ('schet'  , outhold ) > 0 then  true  else false )).
    run gbl/twowin.w (
          input ?
        , input 1
        , input "Выбор из списка форм"
        , input ""
        , input ""
        , input table temp_twowin_items
        , output table temp_twowin_itemsSelected_col
        , output v-cur-ext-key
        , output v-accepted
    ).
    if v-accepted and can-find (first temp_twowin_itemsSelected_col) then do:
    outhold = ''.
    for each temp_twowin_itemsSelected_col
    :
      outhold = outhold + temp_twowin_itemsSelected_col.itmExtKey + "," .
    end.
    outhold = trim(outhold,"," ).
 end.
 DISPLAY outhold with FRAME Dialog-Frame.
END.
ON CHOOSE OF B-outnum IN FRAME Dialog-Frame
DO:
 if p-mode = 'ПРОСМОТР':U then return .
    run twowin_clear in this-procedure.
    define variable v-accepted      as logical      no-undo.
    define variable v-cur-ext-key   as character    no-undo.
    run twowin_add-item in this-procedure ( input "",  input   "ПУСТО" , input "" , input no ).
    run twowin_add-item in this-procedure ( input 'torg12',   input  "ТОРГ12", input "Печатная форма ТОРГ-12",                                 input ( if lookup ('torg12'  ,  outnum ) > 0 then  true  else false ) ).
    run twowin_add-item in this-procedure ( input 'torg12n',  input  "ТОРГ12 с окр", input "Печатная форма ТОРГ-12 с округлением",             input ( if lookup ('torg12n'  , outnum ) > 0 then  true  else false ) ).
    run twowin_add-item in this-procedure ( input 'torg12z',  input  "ТОРГ12 для ювел.изд.", input "Печатная форма ТОРГ-12 для ювел.изделий ", input ( if lookup ('torg12z'  , outnum ) > 0 then  true  else false ) ).
    run twowin_add-item in this-procedure ( input 'torg13',   input  "ТОРГ13", input "Печатная форма ТОРГ-13",                                 input ( if lookup ('torg13'  ,  outnum ) > 0 then  true  else false ) ).
    run twowin_add-item in this-procedure ( input 'torg16',   input  "ТОРГ16", input "Печатная форма ТОРГ-16",                                 input ( if lookup ('torg16'  ,  outnum ) > 0 then  true  else false ) ).
    run twowin_add-item in this-procedure ( input 'factur',   input  "Счет-фактура", input "Печатная форма Счет-фактура",                      input ( if lookup ('factur'  ,  outnum ) > 0 then  true  else false ) ).
    run twowin_add-item in this-procedure ( input 'facturn',  input  "Счет-фактура с окр", input "Печатная форма Счет-фактура с округлением", input ( if lookup ('facturn'  , outnum ) > 0 then  true  else false ) ).
    run twowin_add-item in this-procedure ( input 'schet',    input  "Счет",         input "Печатная форма Счет",                              input ( if lookup ('schet'  ,   outnum ) > 0 then  true  else false ) ).
    run twowin_add-item in this-procedure ( input 'oldinp',   input  "Приходная Накладная", input "Печатная форма по ПН",                      input ( if lookup ('oldinp'  ,  outnum ) > 0 then  true  else false ) ).
    run twowin_add-item in this-procedure ( input 'oldexp',   input  "Накладная Расходная", input "Печатная форма по РН",                      input ( if lookup ('oldexp'  ,  outnum ) > 0 then  true  else false ) ).
    run gbl/twowin.w (
          input ?
        , input 1
        , input "Выбор из списка форм"
        , input ""
        , input ""
        , input table temp_twowin_items
        , output table temp_twowin_itemsSelected_col
        , output v-cur-ext-key
        , output v-accepted
    ).
    if v-accepted and can-find (first temp_twowin_itemsSelected_col) then do:
    outnum = ''.
    for each temp_twowin_itemsSelected_col
    :
      outnum = outnum + temp_twowin_itemsSelected_col.itmExtKey + "," .
    end.
    outnum = trim(outnum,"," ).
 end.
 DISPLAY outnum with FRAME Dialog-Frame.
END.
ON CHOOSE OF B-outobj IN FRAME Dialog-Frame
DO:
 if p-mode = 'ПРОСМОТР':U then return .
    run twowin_clear in this-procedure.
    define variable v-accepted      as logical      no-undo.
    define variable v-cur-ext-key   as character    no-undo.
    run twowin_add-item in this-procedure ( input "",  input   "ПУСТО" , input "" , input no ).
    run twowin_add-item in this-procedure ( input 'factur',   input  "Счет-фактура", input "Печатная форма Счет-фактура", input ( if lookup ('factur'  ,  outobj ) > 0 then  true  else false ) ).
    run gbl/twowin.w (
          input ?
        , input 1
        , input "Выбор из списка форм"
        , input ""
        , input ""
        , input table temp_twowin_items
        , output table temp_twowin_itemsSelected_col
        , output v-cur-ext-key
        , output v-accepted
         ).
    if v-accepted and can-find (first temp_twowin_itemsSelected_col) then do:
    outobj = ''.
    for each temp_twowin_itemsSelected_col
    :
      outobj = outobj + temp_twowin_itemsSelected_col.itmExtKey + "," .
    end.
    outobj = trim(outobj,"," ).
 end.
 DISPLAY outobj with FRAME Dialog-Frame.
END.
ON CHOOSE OF B-outprim IN FRAME Dialog-Frame
DO:
 if p-mode = 'ПРОСМОТР':U then return .
    run twowin_clear in this-procedure.
    define variable v-accepted      as logical      no-undo.
    define variable v-cur-ext-key   as character    no-undo.
    run twowin_add-item in this-procedure ( input "",  input   "ПУСТО" , input "" , input no ).
    run twowin_add-item in this-procedure ( input 'torg12',   input  "ТОРГ12", input "Печатная форма ТОРГ-12",                                  input ( if lookup ('torg12'   ,  outprim ) > 0 then  true  else false )  ).
    run twowin_add-item in this-procedure ( input 'torg12n',  input  "ТОРГ12 с окр", input "Печатная форма ТОРГ-12 с округлением",              input ( if lookup ('torg12n'  ,  outprim ) > 0 then  true  else false )  ).
    run twowin_add-item in this-procedure ( input 'torg12z',  input  "ТОРГ12 для ювел.изд.", input "Печатная форма ТОРГ-12 для ювел.изделий ",  input ( if lookup ('torg12z'  ,  outprim ) > 0 then  true  else false )  ).
    run twowin_add-item in this-procedure ( input 'torg13',   input  "ТОРГ13", input "Печатная форма ТОРГ-13",                                  input ( if lookup ('torg13'   ,  outprim ) > 0 then  true  else false )  ).
    run twowin_add-item in this-procedure ( input 'torg16',   input  "ТОРГ16", input "Печатная форма ТОРГ-16",                                  input ( if lookup ('torg16'   ,  outprim ) > 0 then  true  else false )  ).
    run twowin_add-item in this-procedure ( input 'factur',   input  "Счет-фактура", input "Печатная форма Счет-фактура",                       input ( if lookup ('factur'   ,  outprim ) > 0 then  true  else false )  ).
    run twowin_add-item in this-procedure ( input 'facturn',   input  "Счет-фактура с окр", input "Печатная форма Счет-фактура с округлением",  input ( if lookup ('facturn'  ,  outprim ) > 0 then  true  else false )  ).
    run twowin_add-item in this-procedure ( input 'schet',    input  "Счет",         input "Печатная форма Счет",                               input ( if lookup ('schet'    ,  outprim ) > 0 then  true  else false )  ).
    run twowin_add-item in this-procedure ( input 'oldinp',   input  "Приходная Накладная", input "Печатная форма по ПН",                       input ( if lookup ('oldinp'   ,  outprim ) > 0 then  true  else false )  ).
    run twowin_add-item in this-procedure ( input 'oldexp',   input  "Накладная Расходная", input "Печатная форма по РН",                       input ( if lookup ('oldexp'   ,  outprim ) > 0 then  true  else false )  ).
    run gbl/twowin.w (
          input ?
        , input 1
        , input "Выбор из списка форм"
        , input ""
        , input ""
        , input table temp_twowin_items
        , output table temp_twowin_itemsSelected_col
        , output v-cur-ext-key
        , output v-accepted
    ).
    if v-accepted and can-find (first temp_twowin_itemsSelected_col) then do:
    outprim = ''.
    for each temp_twowin_itemsSelected_col
    :
      outprim = outprim + temp_twowin_itemsSelected_col.itmExtKey + "," .
    end.
    outprim = trim(outprim,"," ).
 end.
 DISPLAY outprim with FRAME Dialog-Frame.
END.
ON CHOOSE OF B-outrecv IN FRAME Dialog-Frame
DO:
 if p-mode = 'ПРОСМОТР':U then return .
    run twowin_clear in this-procedure.
    define variable v-accepted      as logical      no-undo.
    define variable v-cur-ext-key   as character    no-undo.
    run twowin_add-item in this-procedure ( input "",  input   "ПУСТО" , input "" , input no ).
    run twowin_add-item in this-procedure ( input "",  input  string("","x(10)") + "ПУСТО" , input "" , input no ).
    run twowin_add-item in this-procedure ( input 'torg12',   input  "ТОРГ12", input "Печатная форма ТОРГ-12",                                 input ( if lookup ('torg12'   ,  outrecv ) > 0 then  true  else false )  ).
    run twowin_add-item in this-procedure ( input 'torg12n',  input  "ТОРГ12 с окр", input "Печатная форма ТОРГ-12 с округлением",             input ( if lookup ('torg12n'  ,  outrecv ) > 0 then  true  else false ) ).
    run twowin_add-item in this-procedure ( input 'torg12z',  input  "ТОРГ12 для ювел.изд.", input "Печатная форма ТОРГ-12 для ювел.изделий ", input ( if lookup ('torg12z'  ,  outrecv ) > 0 then  true  else false ) ).
    run twowin_add-item in this-procedure ( input 'torg13',   input  "ТОРГ13", input "Печатная форма ТОРГ-13",                                 input ( if lookup ('torg13'   ,  outrecv ) > 0 then  true  else false ) ).
    run twowin_add-item in this-procedure ( input 'torg16',   input  "ТОРГ16", input "Печатная форма ТОРГ-16",                                 input ( if lookup ('torg16'   ,  outrecv ) > 0 then  true  else false ) ).
    run twowin_add-item in this-procedure ( input 'factur',   input  "Счет-фактура", input "Печатная форма Счет-фактура",                      input ( if lookup ('factur'   ,  outrecv ) > 0 then  true  else false ) ).
    run twowin_add-item in this-procedure ( input 'facturn',   input  "Счет-фактура с окр", input "Печатная форма Счет-фактура с округлением", input ( if lookup ('facturn'  ,  outrecv ) > 0 then  true  else false ) ).
    run twowin_add-item in this-procedure ( input 'schet',    input  "Счет",                input "Печатная форма Счет",                       input ( if lookup ('schet'    ,  outrecv ) > 0 then  true  else false ) ).
    run twowin_add-item in this-procedure ( input 'oldinp',   input  "Приходная Накладная", input "Печатная форма по ПН",                     input  ( if lookup ('oldinp'   ,  outrecv ) > 0 then  true  else false ) ).
    run twowin_add-item in this-procedure ( input 'oldexp',   input  "Накладная Расходная", input "Печатная форма по РН",                     input  ( if lookup ('oldexp'   ,  outrecv ) > 0 then  true  else false ) ).
    run gbl/twowin.w (
          input ?
        , input 1
        , input "Выбор из списка форм"
        , input ""
        , input ""
        , input table temp_twowin_items
        , output table temp_twowin_itemsSelected_col
        , output v-cur-ext-key
        , output v-accepted
    ).
    if v-accepted and can-find (first temp_twowin_itemsSelected_col) then do:
    outrecv = ''.
    for each temp_twowin_itemsSelected_col
    :
      outrecv = outrecv + temp_twowin_itemsSelected_col.itmExtKey + "," .
    end.
    outrecv = trim(outrecv,"," ).
 end.
 DISPLAY outrecv with FRAME Dialog-Frame.
END.
ON CHOOSE OF B-outrubl IN FRAME Dialog-Frame
DO:
 if p-mode = 'ПРОСМОТР':U then return .
    run twowin_clear in this-procedure.
    define variable v-accepted      as logical      no-undo.
    define variable v-cur-ext-key   as character    no-undo.
    run twowin_add-item in this-procedure ( input "",          input   "ПУСТО" , input "" , input no ).
    run twowin_add-item in this-procedure ( input 'factur',   input  "Счет-фактура", input "Печатная форма Счет-фактура", input ( if lookup ('factur'   ,  outrubl ) > 0 then  true  else false ) ).
    run twowin_add-item in this-procedure ( input 'schet' ,    input  "Счет",         input "Печатная форма Счет",        input ( if lookup ('schet'    ,  outrubl ) > 0 then  true  else false ) ).
    run gbl/twowin.w (
          input ?
        , input 1
        , input "Выбор из списка форм"
        , input ""
        , input ""
        , input table temp_twowin_items
        , output table temp_twowin_itemsSelected_col
        , output v-cur-ext-key
        , output v-accepted
    ).
    if v-accepted and can-find (first temp_twowin_itemsSelected_col) then do:
    outrubl = ''.
    for each temp_twowin_itemsSelected_col
    :
      outrubl = outrubl + temp_twowin_itemsSelected_col.itmExtKey + "," .
    end.
    outrubl = trim(outrubl,"," ).
 end.
 DISPLAY outrubl with FRAME Dialog-Frame.
END.
ON CHOOSE OF B-outsend IN FRAME Dialog-Frame
DO:
 if p-mode = 'ПРОСМОТР':U then return .
    run twowin_clear in this-procedure.
    define variable v-accepted      as logical      no-undo.
    define variable v-cur-ext-key   as character    no-undo.
    run twowin_add-item in this-procedure ( input "",         input   "ПУСТО" , input "" , input no ).
    run twowin_add-item in this-procedure ( input 'torg12',   input  "ТОРГ12", input "Печатная форма ТОРГ-12",                                 input ( if lookup ('torg12' ,  outsend ) > 0 then  true  else false ) ).
    run twowin_add-item in this-procedure ( input 'torg12n',  input  "ТОРГ12 с окр", input "Печатная форма ТОРГ-12 с округлением",             input ( if lookup ('torg12n' ,  outsend ) > 0 then  true  else false ) ).
    run twowin_add-item in this-procedure ( input 'torg12z',  input  "ТОРГ12 для ювел.изд.", input "Печатная форма ТОРГ-12 для ювел.изделий ", input ( if lookup ('torg12z' ,  outsend ) > 0 then  true  else false ) ).
    run twowin_add-item in this-procedure ( input 'torg13',   input  "ТОРГ13", input "Печатная форма ТОРГ-13",                                 input ( if lookup ('torg13' ,  outsend ) > 0 then  true  else false ) ).
    run twowin_add-item in this-procedure ( input 'torg16',   input  "ТОРГ16", input "Печатная форма ТОРГ-16",                                 input ( if lookup ('torg16' ,  outsend ) > 0 then  true  else false ) ).
    run twowin_add-item in this-procedure ( input 'factur',   input  "Счет-фактура", input "Печатная форма Счет-фактура",                      input ( if lookup ('factur' ,  outsend ) > 0 then  true  else false ) ).
    run twowin_add-item in this-procedure ( input 'facturn',  input  "Счет-фактура с окр", input "Печатная форма Счет-фактура с округлением",  input ( if lookup ('facturn' ,  outsend ) > 0 then  true  else false ) ).
    run twowin_add-item in this-procedure ( input 'schet',    input  "Счет",         input "Печатная форма Счет",                              input ( if lookup ('schet',   outsend ) > 0 then  true  else false ) ).
    run twowin_add-item in this-procedure ( input 'oldinp',   input  "Приходная Накладная", input "Печатная форма по ПН",                      input ( if lookup ('oldinp',  outsend ) > 0 then  true  else false ) ).
    run twowin_add-item in this-procedure ( input 'oldexp',   input  "Накладная Расходная", input "Печатная форма по РН",                      input ( if lookup ('oldexp',  outsend ) > 0 then  true  else false ) ).
    run gbl/twowin.w (
          input ?
        , input 1
        , input "Выбор из списка форм"
        , input ""
        , input ""
        , input table temp_twowin_items
        , output table temp_twowin_itemsSelected_col
        , output v-cur-ext-key
        , output v-accepted
    ).
    if v-accepted and can-find (first temp_twowin_itemsSelected_col) then do:
    outsend = ''.
    for each temp_twowin_itemsSelected_col
    :
      outsend = outsend + temp_twowin_itemsSelected_col.itmExtKey + "," .
    end.
    outsend = trim(outsend,"," ).
 end.
 DISPLAY outsend with FRAME Dialog-Frame.
END.
ON CHOOSE OF B-outsubs IN FRAME Dialog-Frame
DO:
 if p-mode = 'ПРОСМОТР':U then return .
    run twowin_clear in this-procedure.
    define variable v-accepted      as logical      no-undo.
    define variable v-cur-ext-key   as character    no-undo.
    run twowin_add-item in this-procedure ( input "",  input   "ПУСТО" , input "" , input no ).
    run twowin_add-item in this-procedure ( input 'torg12',   input  "ТОРГ12", input "Печатная форма ТОРГ-12",                                 input ( if lookup ('torg12',  outsubs ) > 0 then  true  else false ) ).
    run twowin_add-item in this-procedure ( input 'torg12n',  input  "ТОРГ12 с окр", input "Печатная форма ТОРГ-12 с округлением",             input ( if lookup ('torg12n',  outsubs ) > 0 then  true  else false )  ).
    run twowin_add-item in this-procedure ( input 'torg12z',  input  "ТОРГ12 для ювел.изд.", input "Печатная форма ТОРГ-12 для ювел.изделий ", input ( if lookup ('torg12z',  outsubs ) > 0 then  true  else false )  ).
    run twowin_add-item in this-procedure ( input 'torg13',   input  "ТОРГ13", input "Печатная форма ТОРГ-13",                                 input ( if lookup ('torg13',  outsubs ) > 0 then  true  else false )  ).
    run twowin_add-item in this-procedure ( input 'torg16',   input  "ТОРГ16", input "Печатная форма ТОРГ-16",                                 input ( if lookup ('torg16',  outsubs ) > 0 then  true  else false )  ).
    run twowin_add-item in this-procedure ( input 'factur',   input  "Счет-фактура", input "Печатная форма Счет-фактура",                      input ( if lookup ('factur',  outsubs ) > 0 then  true  else false )  ).
    run twowin_add-item in this-procedure ( input 'facturn',   input  "Счет-фактура с окр", input "Печатная форма Счет-фактура с округлением", input ( if lookup ('facturn',  outsubs ) > 0 then  true  else false ) ).
    run twowin_add-item in this-procedure ( input 'schet',    input  "Счет",         input "Печатная форма Счет",                              input ( if lookup ('schet',   outsubs ) > 0 then  true  else false )  ).
    run twowin_add-item in this-procedure ( input 'oldinp',   input  "Приходная Накладная", input "Печатная форма по ПН",                      input ( if lookup ('oldinp',  outsubs ) > 0 then  true  else false )  ).
    run twowin_add-item in this-procedure ( input 'oldexp',   input  "Накладная Расходная", input "Печатная форма по РН",                      input ( if lookup ('oldexp',  outsubs ) > 0 then  true  else false )  ).
    run gbl/twowin.w (
          input ?
        , input 1
        , input "Выбор из списка форм"
        , input ""
        , input ""
        , input table temp_twowin_items
        , output table temp_twowin_itemsSelected_col
        , output v-cur-ext-key
        , output v-accepted
    ).
    if v-accepted and can-find (first temp_twowin_itemsSelected_col) then do:
    outsubs = ''.
    for each temp_twowin_itemsSelected_col
    :
      outsubs = outsubs + temp_twowin_itemsSelected_col.itmExtKey + "," .
    end.
    outsubs = trim(outsubs,"," ).
 end.
 DISPLAY outsubs with FRAME Dialog-Frame.
END.
ON CHOOSE OF B-outt12 IN FRAME Dialog-Frame
DO:
 if p-mode = 'ПРОСМОТР':U then return .
    run twowin_clear in this-procedure.
    define variable v-accepted      as logical      no-undo.
    define variable v-cur-ext-key   as character    no-undo.
    run twowin_add-item in this-procedure ( input "",         input   "ПУСТО" , input "" ,                     input no ).
    run twowin_add-item in this-procedure ( input 'torg12',   input  "ТОРГ12", input "Печатная форма ТОРГ-12",                                 input (if lookup ('torg12' , outt12 ) > 0 then  true  else false )  ).
    run twowin_add-item in this-procedure ( input 'torg12n',  input  "ТОРГ12 с окр", input "Печатная форма ТОРГ-12 с округлением",             input (if lookup ('torg12n' , outt12 ) > 0 then  true  else false )  ).
    run twowin_add-item in this-procedure ( input 'torg12z',  input  "ТОРГ12 для ювел.изд.", input "Печатная форма ТОРГ-12 для ювел.изделий ", input (if lookup ('torg12z' , outt12 ) > 0 then  true  else false )  ).
    run gbl/twowin.w (
          input ?
        , input 1
        , input "Выбор из списка форм"
        , input ""
        , input ""
        , input table temp_twowin_items
        , output table temp_twowin_itemsSelected_col
        , output v-cur-ext-key
        , output v-accepted
    ).
    if v-accepted and can-find (first temp_twowin_itemsSelected_col) then do:
    outt12 = ''.
    for each temp_twowin_itemsSelected_col
    :
      outt12 = outt12 + temp_twowin_itemsSelected_col.itmExtKey + "," .
    end.
    outt12 = trim(outt12,"," ).
 end.
 DISPLAY outt12 with FRAME Dialog-Frame.
END.
ON MOUSE-SELECT-CLICK OF I-factur01 IN FRAME Dialog-Frame
DO:
  MESSAGE I-factur01:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-fgdsnind IN FRAME Dialog-Frame
DO:
  MESSAGE I-fgdsnind:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-in-docpr IN FRAME Dialog-Frame
DO:
  MESSAGE I-in-docpr:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-incurrat IN FRAME Dialog-Frame
DO:
  MESSAGE I-incurrat:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-invprn0 IN FRAME Dialog-Frame
DO:
  MESSAGE I-invprn0:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-outappr IN FRAME Dialog-Frame
DO:
  MESSAGE I-outappr:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-outares IN FRAME Dialog-Frame
DO:
  MESSAGE I-outares:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-outasend IN FRAME Dialog-Frame
DO:
  MESSAGE I-outasend:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-outb IN FRAME Dialog-Frame
DO:
  MESSAGE I-outb:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-outc IN FRAME Dialog-Frame
DO:
  MESSAGE I-outc:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-outdate IN FRAME Dialog-Frame
DO:
  MESSAGE I-outdate:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-outdisc IN FRAME Dialog-Frame
DO:
  MESSAGE I-outdisc:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-outegrp IN FRAME Dialog-Frame
DO:
  MESSAGE I-outegrp:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-outhold IN FRAME Dialog-Frame
DO:
  MESSAGE I-outhold:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-outnum IN FRAME Dialog-Frame
DO:
  MESSAGE I-outnum:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-outobj IN FRAME Dialog-Frame
DO:
  MESSAGE I-outobj:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-outogr IN FRAME Dialog-Frame
DO:
  MESSAGE I-outogr:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-outprim IN FRAME Dialog-Frame
DO:
  MESSAGE I-outprim:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-outprncd IN FRAME Dialog-Frame
DO:
  MESSAGE I-outprncd:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-outprops IN FRAME Dialog-Frame
DO:
  MESSAGE I-outprops:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-outR IN FRAME Dialog-Frame
DO:
  MESSAGE I-outR:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-outrecv IN FRAME Dialog-Frame
DO:
  MESSAGE I-outrecv:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-outrubl IN FRAME Dialog-Frame
DO:
  MESSAGE I-outrubl:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-outsend IN FRAME Dialog-Frame
DO:
  MESSAGE I-outsend:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-outssdoc IN FRAME Dialog-Frame
DO:
  MESSAGE I-outssdoc:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-outsubs IN FRAME Dialog-Frame
DO:
  MESSAGE I-outsubs:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-outt12 IN FRAME Dialog-Frame
DO:
  MESSAGE I-outt12:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-rep-artic IN FRAME Dialog-Frame
DO:
  MESSAGE I-rep-artic:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-sort-prd IN FRAME Dialog-Frame
DO:
  MESSAGE I-sort-prd:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-tick-w IN FRAME Dialog-Frame
DO:
  MESSAGE I-tick-w:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-torg2-no IN FRAME Dialog-Frame
DO:
  MESSAGE I-torg2-no:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
   outR:Radio-BUTTONS in frame Dialog-Frame   = "Не печатать,no_print,Руководитель фирмы,ruk_firm,Директор объекта,dir_obj" .
   outB:Radio-BUTTONS in frame Dialog-Frame   = "Не печатать,no_print,Гл. бух. фирмы,glbuh_firm,Бухгалтер объекта,buh_obj"  .
   outogr:Radio-BUTTONS in frame Dialog-Frame  = "Не печатать,no_print,Руководитель фирмы,ruk_firm,Директор объекта,dir_obj,Менеджер документа,manag_doc".
   outC:Radio-BUTTONS in frame Dialog-Frame   = "Не печатать,no_print,Кладовщик документа,clad_doc,Кладовщик объекта,clad_obj"  .
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
if p-obj-type <> "" then
   frame Dialog-Frame:title = frame Dialog-Frame:title + (if p-obj-type = 'орг':U then " фирма" else " маг") + string(p-obj-code) .
define variable loc#log as logical   no-undo .
define variable vss-include-info8 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
    run enable_UI.
    run init-proc.
    fl = 'new' .
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
run disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  if p-type = "glob" then
  do:
    DISPLAY FILL-IN-4
      invprn0  I-invprn0  v-invprn0
      outprncd I-outprncd v-outprncd
      outrecv   I-outrecv B-outrecv v-outrecv
      rep-artic I-rep-artic   v-rep-artic
      outprops  I-outprops  v-outprops
      sort-prd  I-sort-prd    v-sort-prd
      torg2-no   I-torg2-no v-torg2-no
      WITH FRAME Dialog-Frame.
    ENABLE B-exit  B-quit  B-Help FILL-IN-4 RECT-2
      invprn0  I-invprn0  v-invprn0
      outprncd I-outprncd v-outprncd
      outrecv   I-outrecv B-outrecv v-outrecv
      rep-artic I-rep-artic   v-rep-artic
      outprops  I-outprops  v-outprops
      sort-prd  I-sort-prd    v-sort-prd
      torg2-no   I-torg2-no v-torg2-no
      WITH FRAME Dialog-Frame.
    HIDE
      I-factur01 factur01  v-factur01  B-14
      I-incurrat  incurrat  v-incurrat  B-15
      I-tick-w  tick-w    v-tick-w  B-16
      fgdsnind  B-20  I-fgdsnind  v-fgdsnind
      outssdoc  B-1 I-outssdoc  v-outssdoc
      in-docpr  B-2 I-in-docpr  v-in-docpr
      outR    B-24  I-outR    v-outR
      outB    B-18  I-outb    v-outb
      outogr    B-13  I-outogr  v-outogr
      outC    B-27  I-outc    v-outc
      FILL-IN-1
      outdisc   B-3 I-outdisc   B-outdisc v-outdisc
      outegrp   B-4 I-outegrp B-outegrp v-outegrp
      outobj    B-9   I-outobj  B-outobj  v-outobj
      outappr   B-5 I-outappr B-outappr   v-outappr
      outdate   B-6 I-outdate   B-outdate v-outdate
      outnum    B-8 I-outnum  B-outnum  v-outnum
      outhold   B-7 I-outhold B-outhold v-outhold
      outsubs   B-12  I-outsubs B-outsubs v-outsubs
      outt12    B-25  I-outt12  B-outt12  v-outt12
      outprim   B-26  I-outprim B-outprim v-outprim
      outrubl   B-19  I-outrubl B-outrubl v-outrubl
      outares   B-21  I-outares B-outares v-outares
      outsend   B-22  I-outsend B-outsend v-outsend
      outasend  B-23  I-outasend  B-outasend  v-outasend
      invprn0  I-invprn0  v-invprn0
      outprncd I-outprncd v-outprncd
      outrecv   I-outrecv B-outrecv v-outrecv
      rep-artic I-rep-artic   v-rep-artic
      outprops  I-outprops  v-outprops
      sort-prd  I-sort-prd    v-sort-prd
      torg2-no   I-torg2-no v-torg2-no
     IN FRAME Dialog-Frame.
    VIEW FRAME Dialog-Frame.
  end.
  if p-type = "firm" then
  do:
    DISPLAY FILL-IN-4
      I-factur01 factur01  v-factur01  B-14
      I-incurrat  incurrat  v-incurrat  B-15
      I-tick-w  tick-w    v-tick-w  B-16
      WITH FRAME Dialog-Frame.
    ENABLE B-exit  B-quit  B-Help FILL-IN-4 RECT-2
      I-factur01 factur01  v-factur01  B-14
      I-incurrat  incurrat  v-incurrat  B-15
      I-tick-w  tick-w    v-tick-w  B-16
      WITH FRAME Dialog-Frame.
    HIDE
     invprn0  I-invprn0  v-invprn0
      outprncd I-outprncd v-outprncd
      outrecv   I-outrecv B-outrecv v-outrecv
      rep-artic I-rep-artic   v-rep-artic
      outprops  I-outprops  v-outprops
      sort-prd  I-sort-prd    v-sort-prd
      torg2-no   I-torg2-no v-torg2-no
      fgdsnind  B-20  I-fgdsnind  v-fgdsnind
      outssdoc  B-1 I-outssdoc  v-outssdoc
      in-docpr  B-2 I-in-docpr  v-in-docpr
      outR    B-24  I-outR    v-outR
      outB    B-18  I-outb    v-outb
      outogr    B-13  I-outogr  v-outogr
      outC    B-27  I-outc    v-outc
      FILL-IN-1
      outdisc   B-3 I-outdisc   B-outdisc v-outdisc
      outegrp   B-4 I-outegrp B-outegrp v-outegrp
      outobj    B-9   I-outobj  B-outobj  v-outobj
      outappr   B-5 I-outappr B-outappr   v-outappr
      outdate   B-6 I-outdate   B-outdate v-outdate
      outnum    B-8 I-outnum  B-outnum  v-outnum
      outhold   B-7 I-outhold B-outhold v-outhold
      outsubs   B-12  I-outsubs B-outsubs v-outsubs
      outt12    B-25  I-outt12  B-outt12  v-outt12
      outprim   B-26  I-outprim B-outprim v-outprim
      outrubl   B-19  I-outrubl B-outrubl v-outrubl
      outares   B-21  I-outares B-outares v-outares
      outsend   B-22  I-outsend B-outsend v-outsend
      outasend  B-23  I-outasend  B-outasend  v-outasend
     IN FRAME Dialog-Frame.
    VIEW FRAME Dialog-Frame.
  end.
  if p-type = "obj" then
  do:
    DISPLAY FILL-IN-4
      fgdsnind  B-20  I-fgdsnind  v-fgdsnind
      outssdoc  B-1 I-outssdoc  v-outssdoc
      in-docpr  B-2 I-in-docpr  v-in-docpr
      outR    B-24  I-outR    v-outR
      outB    B-18  I-outb    v-outb
      outogr    B-13  I-outogr  v-outogr
      outC    B-27  I-outc    v-outc
      FILL-IN-1
      outdisc   B-3 I-outdisc   B-outdisc v-outdisc
      outegrp   B-4 I-outegrp B-outegrp v-outegrp
      outobj    B-9   I-outobj  B-outobj  v-outobj
      outappr   B-5 I-outappr B-outappr   v-outappr
      outdate   B-6 I-outdate   B-outdate v-outdate
      outnum    B-8 I-outnum  B-outnum  v-outnum
      outhold   B-7 I-outhold B-outhold v-outhold
      outsubs   B-12  I-outsubs B-outsubs v-outsubs
      outt12    B-25  I-outt12  B-outt12  v-outt12
      outprim   B-26  I-outprim B-outprim v-outprim
      outrubl   B-19  I-outrubl B-outrubl v-outrubl
      outares   B-21  I-outares B-outares v-outares
      outsend   B-22  I-outsend B-outsend v-outsend
      outasend  B-23  I-outasend  B-outasend  v-outasend
      WITH FRAME Dialog-Frame.
    ENABLE B-exit  B-quit  B-Help FILL-IN-4 RECT-2
      fgdsnind  B-20  I-fgdsnind  v-fgdsnind
      outssdoc  B-1 I-outssdoc  v-outssdoc
      in-docpr  B-2 I-in-docpr  v-in-docpr
      outR    B-24  I-outR    v-outR
      outB    B-18  I-outb    v-outb
      outogr    B-13  I-outogr  v-outogr
      outC    B-27  I-outc    v-outc
      FILL-IN-1
      outdisc   B-3 I-outdisc   B-outdisc v-outdisc
      outegrp   B-4 I-outegrp B-outegrp v-outegrp
      outobj    B-9   I-outobj  B-outobj  v-outobj
      outappr   B-5 I-outappr B-outappr   v-outappr
      outdate   B-6 I-outdate   B-outdate v-outdate
      outnum    B-8 I-outnum  B-outnum  v-outnum
      outhold   B-7 I-outhold B-outhold v-outhold
      outsubs   B-12  I-outsubs B-outsubs v-outsubs
      outt12    B-25  I-outt12  B-outt12  v-outt12
      outprim   B-26  I-outprim B-outprim v-outprim
      outrubl   B-19  I-outrubl B-outrubl v-outrubl
      outares   B-21  I-outares B-outares v-outares
      outsend   B-22  I-outsend B-outsend v-outsend
      outasend  B-23  I-outasend  B-outasend  v-outasend
      WITH FRAME Dialog-Frame.
      hide
      I-factur01 factur01  v-factur01  B-14
      I-incurrat  incurrat  v-incurrat  B-15
      I-tick-w  tick-w    v-tick-w  B-16
      invprn0  I-invprn0  v-invprn0
      outprncd I-outprncd v-outprncd
      outrecv   I-outrecv B-outrecv v-outrecv
      rep-artic I-rep-artic   v-rep-artic
      outprops  I-outprops  v-outprops
      sort-prd  I-sort-prd    v-sort-prd
      torg2-no   I-torg2-no v-torg2-no
      in frame Dialog-Frame.
    VIEW FRAME Dialog-Frame.
  end.
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
for each thbjattr_thbj-attr-o:
  delete thbjattr_thbj-attr-o.
end.
for each thbjattr_thbj-attr-g:
  delete thbjattr_thbj-attr-g.
end.
for each thbjattr_thbj-attr-f:
  delete thbjattr_thbj-attr-f.
end.
for each temp-thbj-attr:
  delete temp-thbj-attr.
end.
if p-type = 'glob' then do:
run adm/shattri.p (
    input "init":U
  , input ""
  , input 0
  , input 'prt-glob':U
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
  "Не удалось получить начальные значения настроек GLOB" skip
  error-status:get-message(1) skip
  return-value
  view-as alert-box error .
  undo, return error .
end.
end.
if p-type = 'firm' then do:
run adm/shattri.p (
    input "init":U
  , input v-obj-type
  , input v-obj-code
  , input 'prt-firm':U
  , input "":U
  , output v-value-character
  , output v-value-date
  , output v-value-decimal
  , output v-value-integer
  , output v-value-logical
  , output v-param-type
  , input-output TABLE-HANDLE v-tthf
  ) no-error .
if error-status:error then do:
  message
  "Не удалось получить начальные значения настроек firm" skip
  error-status:get-message(1) return-value
  view-as alert-box error .
  undo, return error .
end.
end.
if p-type = 'obj' then do:
run adm/shattri.p (
    input "init":U
  , input p-obj-type
  , input p-obj-code
  , input 'prt-obj':U
  , input "":U
  , output v-value-character
  , output v-value-date
  , output v-value-decimal
  , output v-value-integer
  , output v-value-logical
  , output v-param-type
  , input-output TABLE-HANDLE v-ttho
  ) no-error .
if error-status:error then do:
  message
  "Не удалось получить начальные значения настроек OBJ" skip
  error-status:get-message(1) skip
  return-value skip
  view-as alert-box error .
  undo, return error .
end.
end.
if p-type = "glob" then do:
FOR EACH thbjattr_thbj-attr-g
:
IF thbjattr_thbj-attr-g.prop-code = 'invprn0':U THEN DO:     invprn0 = thbjattr_thbj-attr-g.property-value-logical.     invprn0:private-data in frame Dialog-Frame = "recid3=" + string(recid(thbjattr_thbj-attr-g)).     display invprn0 with frame Dialog-Frame . END.
IF thbjattr_thbj-attr-g.prop-code = 'outprncd':U THEN DO:     outprncd = thbjattr_thbj-attr-g.property-value-logical.     outprncd:private-data in frame Dialog-Frame = "recid3=" + string(recid(thbjattr_thbj-attr-g)).     display outprncd with frame Dialog-Frame . END.
IF thbjattr_thbj-attr-g.prop-code = 'outrecv':U THEN DO:     outrecv = thbjattr_thbj-attr-g.property-value-character.     outrecv:private-data in frame Dialog-Frame = "recid3=" + string(recid(thbjattr_thbj-attr-g)).     display outrecv with frame Dialog-Frame . END.
IF thbjattr_thbj-attr-g.prop-code = 'sort-prd':U THEN DO:     sort-prd = thbjattr_thbj-attr-g.property-value-logical.     sort-prd:private-data in frame Dialog-Frame = "recid3=" + string(recid(thbjattr_thbj-attr-g)).     display sort-prd with frame Dialog-Frame . END.
IF thbjattr_thbj-attr-g.prop-code = 'torg2-no':U THEN DO:     torg2-no = thbjattr_thbj-attr-g.property-value-logical.     torg2-no:private-data in frame Dialog-Frame = "recid3=" + string(recid(thbjattr_thbj-attr-g)).     display torg2-no with frame Dialog-Frame . END.
IF thbjattr_thbj-attr-g.prop-code = 'outprops':U THEN DO:     outprops = thbjattr_thbj-attr-g.property-value-logical.     outprops:private-data in frame Dialog-Frame = "recid3=" + string(recid(thbjattr_thbj-attr-g)).     display outprops with frame Dialog-Frame . END.
IF thbjattr_thbj-attr-g.prop-code = 'rep-artic':U THEN DO:     rep-artic = thbjattr_thbj-attr-g.property-value-logical.     rep-artic:private-data in frame Dialog-Frame = "recid3=" + string(recid(thbjattr_thbj-attr-g)).     display rep-artic with frame Dialog-Frame . END.
  create temp-thbj-attr.
  buffer-copy thbjattr_thbj-attr-g to temp-thbj-attr.
end.
end.
if p-type = "obj" then do:
FOR EACH thbjattr_thbj-attr-o
:
IF thbjattr_thbj-attr-o.prop-code = 'outprim':U THEN DO:     outprim = thbjattr_thbj-attr-o.property-value-character.     outprim:private-data in frame Dialog-Frame = "recid2=" + string(recid(thbjattr_thbj-attr-o)).     display outprim with frame Dialog-Frame . END.
IF thbjattr_thbj-attr-o.prop-code = 'outrubl':U THEN DO:     outrubl = thbjattr_thbj-attr-o.property-value-character.     outrubl:private-data in frame Dialog-Frame = "recid2=" + string(recid(thbjattr_thbj-attr-o)).     display outrubl with frame Dialog-Frame . END.
IF thbjattr_thbj-attr-o.prop-code = 'outares':U THEN DO:     outares = thbjattr_thbj-attr-o.property-value-character.     outares:private-data in frame Dialog-Frame = "recid2=" + string(recid(thbjattr_thbj-attr-o)).     display outares with frame Dialog-Frame . END.
IF thbjattr_thbj-attr-o.prop-code = 'outsend':U THEN DO:     outsend = thbjattr_thbj-attr-o.property-value-character.     outsend:private-data in frame Dialog-Frame = "recid2=" + string(recid(thbjattr_thbj-attr-o)).     display outsend with frame Dialog-Frame . END.
IF thbjattr_thbj-attr-o.prop-code = 'outssdoc':U THEN DO:     outssdoc = thbjattr_thbj-attr-o.property-value-character.     outssdoc:private-data in frame Dialog-Frame = "recid2=" + string(recid(thbjattr_thbj-attr-o)).     display outssdoc with frame Dialog-Frame . END.
IF thbjattr_thbj-attr-o.prop-code = 'fgdsnind':U THEN DO:     fgdsnind = thbjattr_thbj-attr-o.property-value-logical.     fgdsnind:private-data in frame Dialog-Frame = "recid2=" + string(recid(thbjattr_thbj-attr-o)).     display fgdsnind with frame Dialog-Frame . END.
IF thbjattr_thbj-attr-o.prop-code = 'in-docpr':U THEN DO:     in-docpr = thbjattr_thbj-attr-o.property-value-character.     in-docpr:private-data in frame Dialog-Frame = "recid2=" + string(recid(thbjattr_thbj-attr-o)).     display in-docpr with frame Dialog-Frame . END.
IF thbjattr_thbj-attr-o.prop-code = 'outdisc':U THEN DO:     outdisc = thbjattr_thbj-attr-o.property-value-character.     outdisc:private-data in frame Dialog-Frame = "recid2=" + string(recid(thbjattr_thbj-attr-o)).     display outdisc with frame Dialog-Frame . END.
IF thbjattr_thbj-attr-o.prop-code = 'outegrp':U THEN DO:     outegrp = thbjattr_thbj-attr-o.property-value-character.     outegrp:private-data in frame Dialog-Frame = "recid2=" + string(recid(thbjattr_thbj-attr-o)).     display outegrp with frame Dialog-Frame . END.
IF thbjattr_thbj-attr-o.prop-code = 'outappr':U THEN DO:     outappr = thbjattr_thbj-attr-o.property-value-character.     outappr:private-data in frame Dialog-Frame = "recid2=" + string(recid(thbjattr_thbj-attr-o)).     display outappr with frame Dialog-Frame . END.
IF thbjattr_thbj-attr-o.prop-code = 'outdate':U THEN DO:     outdate = thbjattr_thbj-attr-o.property-value-character.     outdate:private-data in frame Dialog-Frame = "recid2=" + string(recid(thbjattr_thbj-attr-o)).     display outdate with frame Dialog-Frame . END.
IF thbjattr_thbj-attr-o.prop-code = 'outhold':U THEN DO:     outhold = thbjattr_thbj-attr-o.property-value-character.     outhold:private-data in frame Dialog-Frame = "recid2=" + string(recid(thbjattr_thbj-attr-o)).     display outhold with frame Dialog-Frame . END.
IF thbjattr_thbj-attr-o.prop-code = 'outnum':U THEN DO:     outnum = thbjattr_thbj-attr-o.property-value-character.     outnum:private-data in frame Dialog-Frame = "recid2=" + string(recid(thbjattr_thbj-attr-o)).     display outnum with frame Dialog-Frame . END.
IF thbjattr_thbj-attr-o.prop-code = 'outobj':U THEN DO:     outobj = thbjattr_thbj-attr-o.property-value-character.     outobj:private-data in frame Dialog-Frame = "recid2=" + string(recid(thbjattr_thbj-attr-o)).     display outobj with frame Dialog-Frame . END.
IF thbjattr_thbj-attr-o.prop-code = 'outsubs':U THEN DO:     outsubs = thbjattr_thbj-attr-o.property-value-character.     outsubs:private-data in frame Dialog-Frame = "recid2=" + string(recid(thbjattr_thbj-attr-o)).     display outsubs with frame Dialog-Frame . END.
IF thbjattr_thbj-attr-o.prop-code = 'outt12':U THEN DO:     outt12 = thbjattr_thbj-attr-o.property-value-character.     outt12:private-data in frame Dialog-Frame = "recid2=" + string(recid(thbjattr_thbj-attr-o)).     display outt12 with frame Dialog-Frame . END.
IF thbjattr_thbj-attr-o.prop-code = 'outasend':U THEN DO:     outasend = thbjattr_thbj-attr-o.property-value-character.     outasend:private-data in frame Dialog-Frame = "recid2=" + string(recid(thbjattr_thbj-attr-o)).     display outasend with frame Dialog-Frame . END.
IF thbjattr_thbj-attr-o.prop-code = 'outogr':U THEN DO:     outogr = thbjattr_thbj-attr-o.property-value-character.     outogr:private-data in frame Dialog-Frame = "recid2=" + string(recid(thbjattr_thbj-attr-o)).     display outogr with frame Dialog-Frame . END.
IF thbjattr_thbj-attr-o.prop-code = 'outR':U THEN DO:     outR = thbjattr_thbj-attr-o.property-value-character.     outR:private-data in frame Dialog-Frame = "recid2=" + string(recid(thbjattr_thbj-attr-o)).     display outR with frame Dialog-Frame . END.
IF thbjattr_thbj-attr-o.prop-code = 'outB':U THEN DO:     outB = thbjattr_thbj-attr-o.property-value-character.     outB:private-data in frame Dialog-Frame = "recid2=" + string(recid(thbjattr_thbj-attr-o)).     display outB with frame Dialog-Frame . END.
IF thbjattr_thbj-attr-o.prop-code = 'outC':U THEN DO:     outC = thbjattr_thbj-attr-o.property-value-character.     outC:private-data in frame Dialog-Frame = "recid2=" + string(recid(thbjattr_thbj-attr-o)).     display outC with frame Dialog-Frame . END.
  create temp-thbj-attr.
  buffer-copy thbjattr_thbj-attr-o to temp-thbj-attr.
END.
end.
if p-type = "firm" then do:
FOR EACH thbjattr_thbj-attr-f
:
IF thbjattr_thbj-attr-f.prop-code = 'factur01':U THEN DO:     factur01 = thbjattr_thbj-attr-f.property-value-logical.     factur01:private-data in frame Dialog-Frame = "recid4=" + string(recid(thbjattr_thbj-attr-f)).     display factur01 with frame Dialog-Frame . END.
IF thbjattr_thbj-attr-f.prop-code = 'incurrat':U THEN DO:     incurrat = thbjattr_thbj-attr-f.property-value-logical.     incurrat:private-data in frame Dialog-Frame = "recid4=" + string(recid(thbjattr_thbj-attr-f)).     display incurrat with frame Dialog-Frame . END.
IF thbjattr_thbj-attr-f.prop-code = 'tick-w':U THEN DO:     tick-w = thbjattr_thbj-attr-f.property-value-logical.     tick-w:private-data in frame Dialog-Frame = "recid4=" + string(recid(thbjattr_thbj-attr-f)).     display tick-w with frame Dialog-Frame . END.
  create temp-thbj-attr.
  buffer-copy thbjattr_thbj-attr-f to temp-thbj-attr.
end.
end.
define variable v-tooltip as character no-undo .
define variable v-label   as character no-undo .
define variable v-tooltip-code as character no-undo .
if p-type = "obj":U then do:
run thbjattr_tooltip in this-procedure (    input   'prt-obj':U   ,input  "fgdsnind"   ,output v-tooltip   ,output v-label   ,output v-tooltip-code   ) no-error . v-fgdsnind:screen-value = REPLACE ( entry(2,v-label,":") , "`" , "," ) .  v-fgdsnind = v-fgdsnind:screen-value .  I-fgdsnind:private-data = REPLACE ( v-tooltip-code , "`" , "," ) .
run thbjattr_tooltip in this-procedure (    input   'prt-obj':U   ,input  "in-docpr"   ,output v-tooltip   ,output v-label   ,output v-tooltip-code   ) no-error . v-in-docpr:screen-value = REPLACE ( entry(2,v-label,":") , "`" , "," ) .  v-in-docpr = v-in-docpr:screen-value .  I-in-docpr:private-data = REPLACE ( v-tooltip-code , "`" , "," ) .
run thbjattr_tooltip in this-procedure (    input   'prt-obj':U   ,input  "outappr"   ,output v-tooltip   ,output v-label   ,output v-tooltip-code   ) no-error . v-outappr:screen-value = REPLACE ( entry(2,v-label,":") , "`" , "," ) .  v-outappr = v-outappr:screen-value .  I-outappr:private-data = REPLACE ( v-tooltip-code , "`" , "," ) .
run thbjattr_tooltip in this-procedure (    input   'prt-obj':U   ,input  "outdate"   ,output v-tooltip   ,output v-label   ,output v-tooltip-code   ) no-error . v-outdate:screen-value = REPLACE ( entry(2,v-label,":") , "`" , "," ) .  v-outdate = v-outdate:screen-value .  I-outdate:private-data = REPLACE ( v-tooltip-code , "`" , "," ) .
run thbjattr_tooltip in this-procedure (    input   'prt-obj':U   ,input  "outdisc"   ,output v-tooltip   ,output v-label   ,output v-tooltip-code   ) no-error . v-outdisc:screen-value = REPLACE ( entry(2,v-label,":") , "`" , "," ) .  v-outdisc = v-outdisc:screen-value .  I-outdisc:private-data = REPLACE ( v-tooltip-code , "`" , "," ) .
run thbjattr_tooltip in this-procedure (    input   'prt-obj':U   ,input  "outegrp"   ,output v-tooltip   ,output v-label   ,output v-tooltip-code   ) no-error . v-outegrp:screen-value = REPLACE ( entry(2,v-label,":") , "`" , "," ) .  v-outegrp = v-outegrp:screen-value .  I-outegrp:private-data = REPLACE ( v-tooltip-code , "`" , "," ) .
run thbjattr_tooltip in this-procedure (    input   'prt-obj':U   ,input  "outhold"   ,output v-tooltip   ,output v-label   ,output v-tooltip-code   ) no-error . v-outhold:screen-value = REPLACE ( entry(2,v-label,":") , "`" , "," ) .  v-outhold = v-outhold:screen-value .  I-outhold:private-data = REPLACE ( v-tooltip-code , "`" , "," ) .
run thbjattr_tooltip in this-procedure (    input   'prt-obj':U   ,input  "outnum"   ,output v-tooltip   ,output v-label   ,output v-tooltip-code   ) no-error . v-outnum:screen-value = REPLACE ( entry(2,v-label,":") , "`" , "," ) .  v-outnum = v-outnum:screen-value .  I-outnum:private-data = REPLACE ( v-tooltip-code , "`" , "," ) .
run thbjattr_tooltip in this-procedure (    input   'prt-obj':U   ,input  "outobj"   ,output v-tooltip   ,output v-label   ,output v-tooltip-code   ) no-error . v-outobj:screen-value = REPLACE ( entry(2,v-label,":") , "`" , "," ) .  v-outobj = v-outobj:screen-value .  I-outobj:private-data = REPLACE ( v-tooltip-code , "`" , "," ) .
run thbjattr_tooltip in this-procedure (    input   'prt-obj':U   ,input  "outprim"   ,output v-tooltip   ,output v-label   ,output v-tooltip-code   ) no-error . v-outprim:screen-value = REPLACE ( entry(2,v-label,":") , "`" , "," ) .  v-outprim = v-outprim:screen-value .  I-outprim:private-data = REPLACE ( v-tooltip-code , "`" , "," ) .
run thbjattr_tooltip in this-procedure (    input   'prt-obj':U   ,input  "outrubl"   ,output v-tooltip   ,output v-label   ,output v-tooltip-code   ) no-error . v-outrubl:screen-value = REPLACE ( entry(2,v-label,":") , "`" , "," ) .  v-outrubl = v-outrubl:screen-value .  I-outrubl:private-data = REPLACE ( v-tooltip-code , "`" , "," ) .
run thbjattr_tooltip in this-procedure (    input   'prt-obj':U   ,input  "outares"   ,output v-tooltip   ,output v-label   ,output v-tooltip-code   ) no-error . v-outares:screen-value = REPLACE ( entry(2,v-label,":") , "`" , "," ) .  v-outares = v-outares:screen-value .  I-outares:private-data = REPLACE ( v-tooltip-code , "`" , "," ) .
run thbjattr_tooltip in this-procedure (    input   'prt-obj':U   ,input  "outsend"   ,output v-tooltip   ,output v-label   ,output v-tooltip-code   ) no-error . v-outsend:screen-value = REPLACE ( entry(2,v-label,":") , "`" , "," ) .  v-outsend = v-outsend:screen-value .  I-outsend:private-data = REPLACE ( v-tooltip-code , "`" , "," ) .
run thbjattr_tooltip in this-procedure (    input   'prt-obj':U   ,input  "outasend"   ,output v-tooltip   ,output v-label   ,output v-tooltip-code   ) no-error . v-outasend:screen-value = REPLACE ( entry(2,v-label,":") , "`" , "," ) .  v-outasend = v-outasend:screen-value .  I-outasend:private-data = REPLACE ( v-tooltip-code , "`" , "," ) .
run thbjattr_tooltip in this-procedure (    input   'prt-obj':U   ,input  "outssdoc"   ,output v-tooltip   ,output v-label   ,output v-tooltip-code   ) no-error . v-outssdoc:screen-value = REPLACE ( entry(2,v-label,":") , "`" , "," ) .  v-outssdoc = v-outssdoc:screen-value .  I-outssdoc:private-data = REPLACE ( v-tooltip-code , "`" , "," ) .
run thbjattr_tooltip in this-procedure (    input   'prt-obj':U   ,input  "outsubs"   ,output v-tooltip   ,output v-label   ,output v-tooltip-code   ) no-error . v-outsubs:screen-value = REPLACE ( entry(2,v-label,":") , "`" , "," ) .  v-outsubs = v-outsubs:screen-value .  I-outsubs:private-data = REPLACE ( v-tooltip-code , "`" , "," ) .
run thbjattr_tooltip in this-procedure (    input   'prt-obj':U   ,input  "outt12"   ,output v-tooltip   ,output v-label   ,output v-tooltip-code   ) no-error . v-outt12:screen-value = REPLACE ( entry(2,v-label,":") , "`" , "," ) .  v-outt12 = v-outt12:screen-value .  I-outt12:private-data = REPLACE ( v-tooltip-code , "`" , "," ) .
run thbjattr_tooltip in this-procedure (    input   'prt-obj':U   ,input  "outR"   ,output v-tooltip   ,output v-label   ,output v-tooltip-code   ) no-error . v-outR:screen-value = REPLACE ( entry(2,v-label,":") , "`" , "," ) .  v-outR = v-outR:screen-value .  I-outR:private-data = REPLACE ( v-tooltip-code , "`" , "," ) .
run thbjattr_tooltip in this-procedure (    input   'prt-obj':U   ,input  "outB"   ,output v-tooltip   ,output v-label   ,output v-tooltip-code   ) no-error . v-outB:screen-value = REPLACE ( entry(2,v-label,":") , "`" , "," ) .  v-outB = v-outB:screen-value .  I-outB:private-data = REPLACE ( v-tooltip-code , "`" , "," ) .
run thbjattr_tooltip in this-procedure (    input   'prt-obj':U   ,input  "outogr"   ,output v-tooltip   ,output v-label   ,output v-tooltip-code   ) no-error . v-outogr:screen-value = REPLACE ( entry(2,v-label,":") , "`" , "," ) .  v-outogr = v-outogr:screen-value .  I-outogr:private-data = REPLACE ( v-tooltip-code , "`" , "," ) .
run thbjattr_tooltip in this-procedure (    input   'prt-obj':U   ,input  "outC"   ,output v-tooltip   ,output v-label   ,output v-tooltip-code   ) no-error . v-outC:screen-value = REPLACE ( entry(2,v-label,":") , "`" , "," ) .  v-outC = v-outC:screen-value .  I-outC:private-data = REPLACE ( v-tooltip-code , "`" , "," ) .
end.
if p-type = "glob":U then do:
run thbjattr_tooltip in this-procedure (    input   'prt-glob':U   ,input  "invprn0"   ,output v-tooltip   ,output v-label   ,output v-tooltip-code   ) no-error . v-invprn0:screen-value = REPLACE ( entry(2,v-label,":") , "`" , "," ) .  v-invprn0 = v-invprn0:screen-value .  I-invprn0:private-data = REPLACE ( v-tooltip-code , "`" , "," ) .
run thbjattr_tooltip in this-procedure (    input   'prt-glob':U   ,input  "outprncd"   ,output v-tooltip   ,output v-label   ,output v-tooltip-code   ) no-error . v-outprncd:screen-value = REPLACE ( entry(2,v-label,":") , "`" , "," ) .  v-outprncd = v-outprncd:screen-value .  I-outprncd:private-data = REPLACE ( v-tooltip-code , "`" , "," ) .
run thbjattr_tooltip in this-procedure (    input   'prt-glob':U   ,input  "outrecv"   ,output v-tooltip   ,output v-label   ,output v-tooltip-code   ) no-error . v-outrecv:screen-value = REPLACE ( entry(2,v-label,":") , "`" , "," ) .  v-outrecv = v-outrecv:screen-value .  I-outrecv:private-data = REPLACE ( v-tooltip-code , "`" , "," ) .
run thbjattr_tooltip in this-procedure (    input   'prt-glob':U   ,input  "sort-prd"   ,output v-tooltip   ,output v-label   ,output v-tooltip-code   ) no-error . v-sort-prd:screen-value = REPLACE ( entry(2,v-label,":") , "`" , "," ) .  v-sort-prd = v-sort-prd:screen-value .  I-sort-prd:private-data = REPLACE ( v-tooltip-code , "`" , "," ) .
run thbjattr_tooltip in this-procedure (    input   'prt-glob':U   ,input  "torg2-no"   ,output v-tooltip   ,output v-label   ,output v-tooltip-code   ) no-error . v-torg2-no:screen-value = REPLACE ( entry(2,v-label,":") , "`" , "," ) .  v-torg2-no = v-torg2-no:screen-value .  I-torg2-no:private-data = REPLACE ( v-tooltip-code , "`" , "," ) .
run thbjattr_tooltip in this-procedure (    input   'prt-glob':U   ,input  "outprops"   ,output v-tooltip   ,output v-label   ,output v-tooltip-code   ) no-error . v-outprops:screen-value = REPLACE ( entry(2,v-label,":") , "`" , "," ) .  v-outprops = v-outprops:screen-value .  I-outprops:private-data = REPLACE ( v-tooltip-code , "`" , "," ) .
run thbjattr_tooltip in this-procedure (    input   'prt-glob':U   ,input  "rep-artic"   ,output v-tooltip   ,output v-label   ,output v-tooltip-code   ) no-error . v-rep-artic:screen-value = REPLACE ( entry(2,v-label,":") , "`" , "," ) .  v-rep-artic = v-rep-artic:screen-value .  I-rep-artic:private-data = REPLACE ( v-tooltip-code , "`" , "," ) .
end.
if p-type = "firm":U then do:
run thbjattr_tooltip in this-procedure (    input   'prt-firm':U   ,input  "factur01"   ,output v-tooltip   ,output v-label   ,output v-tooltip-code   ) no-error . v-factur01:screen-value = REPLACE ( entry(2,v-label,":") , "`" , "," ) .  v-factur01 = v-factur01:screen-value .  I-factur01:private-data = REPLACE ( v-tooltip-code , "`" , "," ) .
run thbjattr_tooltip in this-procedure (    input   'prt-firm':U   ,input  "incurrat"   ,output v-tooltip   ,output v-label   ,output v-tooltip-code   ) no-error . v-incurrat:screen-value = REPLACE ( entry(2,v-label,":") , "`" , "," ) .  v-incurrat = v-incurrat:screen-value .  I-incurrat:private-data = REPLACE ( v-tooltip-code , "`" , "," ) .
run thbjattr_tooltip in this-procedure (    input   'prt-firm':U   ,input  "tick-w"   ,output v-tooltip   ,output v-label   ,output v-tooltip-code   ) no-error . v-tick-w:screen-value = REPLACE ( entry(2,v-label,":") , "`" , "," ) .  v-tick-w = v-tick-w:screen-value .  I-tick-w:private-data = REPLACE ( v-tooltip-code , "`" , "," ) .
end.
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
  if p-type = "obj":U then do:
    find first obj_thbj-attr exclusive-lock where
              obj_thbj-attr.obj-type = p-obj-type
        and   obj_thbj-attr.obj-code = p-obj-code
        and   obj_thbj-attr.upper-prop-code = 'prt-obj':U
        and   obj_thbj-attr.prop-code = '':u no-wait no-error.
     if locked obj_thbj-attr then do:
        message
        vss-workfile vss-revision vss-description skip
        'prt-obj':U skip
        "Запись ПАРАМЕТРОВ по объектам занята"
        view-as alert-box error .
        undo, return error.
      end.
   end.
   if p-type = "firm":U then do:
    find first frm_thbj-attr exclusive-lock where
              frm_thbj-attr.obj-type = v-obj-type
        and   frm_thbj-attr.obj-code = v-obj-code
        and   frm_thbj-attr.upper-prop-code = 'prt-firm':U
        and   frm_thbj-attr.prop-code = '':u no-wait no-error.
     if locked frm_thbj-attr then do:
        message
        vss-workfile vss-revision vss-description skip
        'prt-obj':U skip
        "Запись ПАРАМЕТРОВ по фирмам занята"
        view-as alert-box error .
        undo, return error.
      end.
    end.
    if p-type = "glob":U then do:
    find first glb_thbj-attr exclusive-lock where
              glb_thbj-attr.obj-type = ""
        and   glb_thbj-attr.obj-code = 0
        and   glb_thbj-attr.upper-prop-code = 'prt-glob':U
        and   glb_thbj-attr.prop-code = '':u no-wait no-error.
     if locked glb_thbj-attr then do:
        message
        vss-workfile vss-revision vss-description skip
        'prt-glob':U skip
        "Запись Глобальных ПАРАМЕТРОВ  занята"
        view-as alert-box error .
        undo, return error.
      end.
     end.
  end.
  else do:
    if p-type = "obj":U then do:
    find first obj_thbj-attr no-lock where
          obj_thbj-attr.obj-type = p-obj-type
    and   obj_thbj-attr.obj-code = p-obj-code
    and   obj_thbj-attr.upper-prop-code = 'prt-obj':U
    and   obj_thbj-attr.prop-code = '':u no-error.
    end.
    if p-type = "glob":U then do:
    find first glb_thbj-attr no-lock where
          glb_thbj-attr.obj-type = ""
    and   glb_thbj-attr.obj-code = 0
    and   glb_thbj-attr.upper-prop-code = 'prt-glob':U
    and   glb_thbj-attr.prop-code = '':u no-error.
    end.
    if p-type = "firm":U then do:
    find first frm_thbj-attr no-lock where
          frm_thbj-attr.obj-type = v-obj-type
    and   frm_thbj-attr.obj-code = v-obj-code
    and   frm_thbj-attr.upper-prop-code = 'prt-firm':U
    and   frm_thbj-attr.prop-code = '':u no-error.
    end.
  end.
if p-type = "obj":U then do:
  if not available obj_thbj-attr then do:
    assign
      v-to-create-prt  = true
      .
    message
    substitute ("Внимание!!!&1Параметра obj НЕТ в БД!&1Будут показаны ЗНАЧЕНИЯ ПО УМОЛЧАНИЮ",
                chr(10))
                 view-as alert-box warning.
  end.
end.
if p-type = "glob":U then do:
  if not available glb_thbj-attr then do:
    assign
      v-to-create-prt-g  = true
      .
    message
    substitute ("Внимание!!!&1Гл.Параметра НЕТ в БД!&1Будут показаны ЗНАЧЕНИЯ ПО УМОЛЧАНИЮ",
                chr(10))
                 view-as alert-box warning.
  end.
end.
if p-type = "firm":U then do:
  if not available frm_thbj-attr then do:
    assign
      v-to-create-prt-f  = true
      .
    message
    substitute ("Внимание!!!&1 firm Параметра НЕТ в БД!&1Будут показаны ЗНАЧЕНИЯ ПО УМОЛЧАНИЮ",
                chr(10))
                 view-as alert-box warning.
  end.
end.
  run fill-widgets in this-procedure no-error.
  if error-status:error then undo, return error.
  if p-mode <> 'ИЗМЕНЕНИЕ':U then do:
     disable
     with frame Dialog-Frame.
     B-exit:label = "Вы&ход"  .
     hide B-quit in frame Dialog-Frame .
  END.
  if p-type = "glob":U then do:
    disable all EXCEPT B-exit B-quit B-Help with frame Dialog-Frame.
    enable
     invprn0  I-invprn0  v-invprn0
      outprncd I-outprncd v-outprncd
      outrecv   I-outrecv B-outrecv v-outrecv
      rep-artic I-rep-artic   v-rep-artic
      outprops  I-outprops  v-outprops
      sort-prd  I-sort-prd    v-sort-prd
      torg2-no   I-torg2-no v-torg2-no
     with frame Dialog-Frame.
  end.
  if p-type = "firm":U then do:
    disable all EXCEPT B-exit B-quit B-Help with frame Dialog-Frame.
    enable
      I-factur01  factur01  v-factur01  B-14
      I-incurrat  incurrat  v-incurrat  B-15
      I-tick-w  tick-w    v-tick-w  B-16
     with frame Dialog-Frame.
  end.
  if p-type = "obj":U then do:
    disable all EXCEPT B-exit B-quit B-Help with frame Dialog-Frame.
    enable
      fgdsnind  B-20  I-fgdsnind  v-fgdsnind
      outssdoc  B-1 I-outssdoc  v-outssdoc
      in-docpr  B-2 I-in-docpr  v-in-docpr
      outR    B-24  I-outR    v-outR
      outB    B-18  I-outb    v-outb
      outogr    B-13  I-outogr  v-outogr
      outC    B-27  I-outc    v-outc
      FILL-IN-1
      outdisc   B-3 I-outdisc   B-outdisc v-outdisc
      outegrp   B-4 I-outegrp B-outegrp v-outegrp
      outobj    B-9   I-outobj  B-outobj  v-outobj
      outappr   B-5 I-outappr B-outappr   v-outappr
      outdate   B-6 I-outdate   B-outdate v-outdate
      outnum    B-8 I-outnum  B-outnum  v-outnum
      outhold   B-7 I-outhold B-outhold v-outhold
      outsubs   B-12  I-outsubs B-outsubs v-outsubs
      outt12    B-25  I-outt12  B-outt12  v-outt12
      outprim   B-26  I-outprim B-outprim v-outprim
      outrubl   B-19  I-outrubl B-outrubl v-outrubl
      outares   B-21  I-outares B-outares v-outares
      outsend   B-22  I-outsend B-outsend v-outsend
      outasend  B-23  I-outasend  B-outasend  v-outasend
     with frame Dialog-Frame.
  end.
end procedure.
PROCEDURE init-tt :
    v-obj-type = p-obj-type .
    v-obj-code = p-obj-code .
    if p-obj-type <> 'орг':U  and p-obj-type <> "" then  do:
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  )  .
        v-obj-type = 'орг':U      .
        v-obj-code = v-host-code .
    end.
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
define variable v-same as logical no-undo .
define variable v-sameg as logical no-undo .
define variable v-samef as logical no-undo .
IF p-mode = 'ПРОСМОТР':U THEN RETURN .
define variable loc#log as logical   no-undo .
define variable vss-include-info10 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
if p-type = "glob" then do:
  ASSIGN
invprn0 FRAME Dialog-Frame
outprncd
outrecv
rep-artic
outprops
sort-prd
torg2-no
 .
end.
if p-type = "obj" then do:
  ASSIGN
    fgdsnind FRAME Dialog-Frame
    in-docpr
    outappr
    outdate
    outdisc
    outegrp
    outhold
    outnum
    outobj
    invprn0
    outprncd
    outrecv
    sort-prd
    torg2-no
    outprops
    outprim
    outrubl
    outssdoc
    outsubs
    outt12
    outares
    outsend
    outasend
    outR
    outB
    outogr
    outC
    rep-artic
 .
end.
if p-type = "firm" then do:
  ASSIGN
factur01
incurrat
tick-w
 .
end.
assign
  fh = frame Dialog-Frame:first-child
  wh = fh:first-child
  .
do while valid-handle(wh):
  if wh:private-data begins "recid2=" then do:
    find first thbjattr_thbj-attr-o where
               recid(thbjattr_thbj-attr-o) = integer(entry(2, wh:private-data, '='))
               no-error .
    if available thbjattr_thbj-attr-o then do:
    assign
    buffer thbjattr_thbj-attr-o:buffer-field("property-value-" + wh:data-type):buffer-value = wh:input-value.
    end.
  end.
  if wh:private-data begins "recid3=" then do:
    find first thbjattr_thbj-attr-g where
               recid(thbjattr_thbj-attr-g) = integer(entry(2, wh:private-data, '='))
               no-error .
    if available thbjattr_thbj-attr-g then do:
        assign
           buffer thbjattr_thbj-attr-g:buffer-field ("property-value-" + wh:data-type):buffer-value = wh:input-value.
    end.
  end.
  if wh:private-data begins "recid4=" then do:
    find first thbjattr_thbj-attr-f where
               recid(thbjattr_thbj-attr-f) = integer(entry(2, wh:private-data, '='))
               no-error .
    if available thbjattr_thbj-attr-f then do:
    assign
    buffer thbjattr_thbj-attr-f:buffer-field("property-value-" + wh:data-type):buffer-value = wh:input-value.
    end.
  end.
  wh = wh:next-sibling.
end.
do transaction
on error undo, return error return-value
:
  run thbjattr_set-section in this-procedure (
        input p-obj-type
      , input p-obj-code
      , input 'prt-obj':U
      , input table thbjattr_thbj-attr-o
  ) no-error.
  if error-status:error then do:
    message error-status:get-message(1)  skip
    return-value
    view-as alert-box.
    undo, return error.
  end.
  if ( p-obj-type = "" and p-obj-code = 0 ) or p-obj-type = 'орг':U then do:
      run thbjattr_set-section in this-procedure (
            input p-obj-type
          , input p-obj-code
          , input 'prt-firm':U
          , input table thbjattr_thbj-attr-f
      ) no-error.
      if error-status:error then do:
        message error-status:get-message(1)  skip
        return-value
        view-as alert-box.
        undo, return error.
      end.
  end.
  if p-obj-type = "" and p-obj-code = 0  then do:
      run thbjattr_set-section in this-procedure (
            input p-obj-type
          , input p-obj-code
          , input 'prt-glob':U
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
PROCEDURE twowin_custom-add-item :
DEFINE INPUT PARAMETER p-twowin-handle AS HANDLE NO-UNDO.
DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
define variable v-ii as integer no-undo .
define variable v-is-petrolium as logical no-undo .
define variable v-is-pieces as logical no-undo .
define variable v-b-code as integer no-undo .
define variable v-exists as logical no-undo .
DEFINE BUFFER buf_cash-pay FOR ub.cash-pay.
define buffer buf_goods for ub.goods.
define buffer buf_temp_twowin_items for temp_twowin_items.
case v-twowin-point :
end case.
END PROCEDURE.
PROCEDURE twowin_get-bttns :
DEFINE OUTPUT PARAMETER p-bttns as character no-undo .
if p-mode = 'ПРОСМОТР':U then do:
  p-bttns = "".
end.
else do:
  p-bttns = "b-add,b-del,b-up,b-down,b-exit".
end.
END PROCEDURE.
