define input parameter parparentproc as widget-handle no-undo.
define input parameter p-mode        as character no-undo.
define input parameter p-obj-type    like ub.clients.obj-type no-undo.
define input parameter p-obj-code    like ub.shop.obj-code no-undo.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-Workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Настроечные параметры резервированиЯ" .
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
assign
v-tth  = buffer thbjattr_thbj-attr:table-handle .
v-tthg = buffer thbjattr_thbj-attr-g:table-handle .
 if g#db-num <> 0 and p-obj-type = "" and  p-obj-code = 0
    then p-mode = 'ПРОСМОТР':U .
DEFINE BUTTON B-1
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE BUTTON B-10
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE BUTTON B-11
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
DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-Help
     LABEL "&Help"
     SIZE 3 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE VARIABLE v-negparts AS CHARACTER
     VIEW-AS EDITOR NO-BOX
     SIZE 81 BY 1.46
     FGCOLOR 1  NO-UNDO.
DEFINE VARIABLE v-prcshfc0 AS CHARACTER
     VIEW-AS EDITOR NO-BOX
     SIZE 89.13 BY 1.46 NO-UNDO.
DEFINE VARIABLE v-prcshrs0 AS CHARACTER
     VIEW-AS EDITOR NO-BOX
     SIZE 46 BY 2.17
     FGCOLOR 1  NO-UNDO.
DEFINE VARIABLE v-prcshrs1 AS CHARACTER
     VIEW-AS EDITOR NO-BOX
     SIZE 40 BY 2.17
     FGCOLOR 1  NO-UNDO.
DEFINE VARIABLE v-prdocrs0 AS CHARACTER
     VIEW-AS EDITOR NO-BOX
     SIZE 46 BY 1.63
     FGCOLOR 1  NO-UNDO.
DEFINE VARIABLE v-prdocrs1 AS CHARACTER
     VIEW-AS EDITOR NO-BOX
     SIZE 39.5 BY 1.63
     FGCOLOR 1  NO-UNDO.
DEFINE VARIABLE invngbeg AS DATE FORMAT "99/99/9999":U
     VIEW-AS FILL-IN
     SIZE 11.63 BY 1 NO-UNDO.
DEFINE VARIABLE invngend AS DATE FORMAT "99/99/9999":U
     VIEW-AS FILL-IN
     SIZE 11.5 BY 1 NO-UNDO.
DEFINE VARIABLE v-invngbeg AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 61.63 BY 1 NO-UNDO.
DEFINE VARIABLE v-invngend AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 2 BY 1 NO-UNDO.
DEFINE VARIABLE v-negmanuf AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 81 BY 1
     FGCOLOR 1  NO-UNDO.
DEFINE VARIABLE v-parts-bc AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 43.75 BY 1 NO-UNDO.
DEFINE VARIABLE v-prdocfc0 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 88 BY 1 NO-UNDO.
DEFINE VARIABLE v-prsalpr AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 89 BY 1 NO-UNDO.
DEFINE IMAGE I-invngbeg
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.04.
DEFINE IMAGE I-invngend
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.
DEFINE IMAGE I-negmanuf
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.
DEFINE IMAGE I-negparts
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.
DEFINE IMAGE I-parts-bc
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.
DEFINE IMAGE I-prcshfc0
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.
DEFINE IMAGE I-prcshrs0
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.
DEFINE IMAGE I-prcshrs1
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.04.
DEFINE IMAGE I-prdocfc0
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.
DEFINE IMAGE I-prdocrs0
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.
DEFINE IMAGE I-prdocrs1
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.04.
DEFINE IMAGE I-prsalpr
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.
DEFINE VARIABLE negmanuf AS CHARACTER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Да", "disable",
"Нет", ""
     SIZE 10.25 BY 1 NO-UNDO.
DEFINE VARIABLE negparts AS CHARACTER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Да", "disable",
"Нет", ""
     SIZE 10.25 BY 1 NO-UNDO.
DEFINE VARIABLE prcshrs0 AS CHARACTER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "не создаются", "disable",
"создаются без подтверждения", "enable",
"диалог подтверждения цены", "prompt",
"диалог редактирования партий", "manual"
     SIZE 31.5 BY 2.42 NO-UNDO.
DEFINE VARIABLE prcshrs1 AS CHARACTER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "не создаются", "disable",
"создаются без подтверждения", "enable",
"диалог подтверждения цены", "prompt",
"диалог редактирования партий", "manual"
     SIZE 31.5 BY 2.42 NO-UNDO.
DEFINE VARIABLE prdocrs0 AS CHARACTER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "не создаются", "disable",
"создаются без подтверждения", "enable",
"диалог подтверждения цены", "prompt",
"диалог редактирования партий", "manual"
     SIZE 32.13 BY 2.42 NO-UNDO.
DEFINE VARIABLE prdocrs1 AS CHARACTER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "не создаются", "disable",
"создаются без подтверждения", "enable",
"диалог подтверждения цены", "prompt",
"диалог редактирования партий", "manual"
     SIZE 32.13 BY 2.42 NO-UNDO.
DEFINE VARIABLE parts-bc AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.13 BY 1 NO-UNDO.
DEFINE VARIABLE prcshfc0 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.25 BY 1 NO-UNDO.
DEFINE VARIABLE prdocfc0 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.25 BY 1 NO-UNDO.
DEFINE VARIABLE prsalpr AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.25 BY 1 NO-UNDO.
DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     B-quit AT ROW 1 COL 11
     B-Help AT ROW 1 COL 95
     B-1 AT ROW 2 COL 64.75 WIDGET-ID 80
     invngbeg AT ROW 2 COL 65.63 COLON-ALIGNED NO-LABEL WIDGET-ID 48
     invngend AT ROW 2 COL 85.25 COLON-ALIGNED NO-LABEL WIDGET-ID 236
     B-2 AT ROW 2.04 COL 84 WIDGET-ID 82
     B-3 AT ROW 2.96 COL 3.5 WIDGET-ID 84
     negmanuf AT ROW 2.96 COL 6.75 NO-LABEL WIDGET-ID 238
     B-4 AT ROW 3.96 COL 3.5 WIDGET-ID 86
     negparts AT ROW 3.96 COL 6.75 NO-LABEL WIDGET-ID 242
     v-negparts AT ROW 4.04 COL 17.5 NO-LABEL WIDGET-ID 272
     B-10 AT ROW 5.42 COL 3.5 WIDGET-ID 246
     prcshfc0 AT ROW 5.42 COL 6.75 WIDGET-ID 182
     v-prcshfc0 AT ROW 5.5 COL 9.5 NO-LABEL WIDGET-ID 270
     parts-bc AT ROW 7.04 COL 3.88 WIDGET-ID 130
     B-7 AT ROW 8.08 COL 3.5 WIDGET-ID 92
     prdocfc0 AT ROW 8.08 COL 6.75 WIDGET-ID 96
     B-9 AT ROW 9.29 COL 3.5 WIDGET-ID 108
     prsalpr AT ROW 9.29 COL 6.75 WIDGET-ID 112
     B-6 AT ROW 10.83 COL 3.5 WIDGET-ID 90
     v-prcshrs1 AT ROW 10.83 COL 6.5 NO-LABEL WIDGET-ID 264
     B-5 AT ROW 10.83 COL 49 WIDGET-ID 88
     v-prcshrs0 AT ROW 10.83 COL 52 NO-LABEL WIDGET-ID 262
     prcshrs1 AT ROW 13.04 COL 6.5 NO-LABEL WIDGET-ID 74
     prcshrs0 AT ROW 13.04 COL 52 NO-LABEL WIDGET-ID 68
     B-8 AT ROW 16.88 COL 3.5 WIDGET-ID 100
     v-prdocrs1 AT ROW 16.88 COL 6.5 NO-LABEL WIDGET-ID 266
     B-11 AT ROW 16.88 COL 49 WIDGET-ID 254
     v-prdocrs0 AT ROW 16.88 COL 52 NO-LABEL WIDGET-ID 268
     prdocrs1 AT ROW 18.46 COL 6.5 NO-LABEL WIDGET-ID 256
     prdocrs0 AT ROW 18.46 COL 52 NO-LABEL WIDGET-ID 248
     v-invngbeg AT ROW 2 COL 3.38 NO-LABEL WIDGET-ID 6
     v-invngend AT ROW 2 COL 79.5 NO-LABEL WIDGET-ID 18
     v-negmanuf AT ROW 2.96 COL 17.5 NO-LABEL WIDGET-ID 54
     v-parts-bc AT ROW 7.04 COL 6.75 NO-LABEL WIDGET-ID 132
     v-prdocfc0 AT ROW 8.17 COL 9.5 NO-LABEL WIDGET-ID 98
     v-prsalpr AT ROW 9.25 COL 9.5 NO-LABEL WIDGET-ID 114
     I-invngbeg AT ROW 2 COL 1 WIDGET-ID 10
     I-invngend AT ROW 2.08 COL 81.5 WIDGET-ID 34
     I-negmanuf AT ROW 2.96 COL 1 WIDGET-ID 50
     I-negparts AT ROW 3.96 COL 1 WIDGET-ID 56
     I-prcshrs0 AT ROW 10.92 COL 46.5 WIDGET-ID 64
     I-prcshrs1 AT ROW 10.92 COL 1 WIDGET-ID 72
     I-prdocfc0 AT ROW 8.17 COL 1 WIDGET-ID 94
     I-prdocrs1 AT ROW 16.96 COL 1 WIDGET-ID 104
     I-prsalpr AT ROW 9.38 COL 1 WIDGET-ID 110
     I-parts-bc AT ROW 7.08 COL 1 WIDGET-ID 146
     I-prcshfc0 AT ROW 5.42 COL 1 WIDGET-ID 180
     I-prdocrs0 AT ROW 16.96 COL 46.5 WIDGET-ID 204
     SPACE(49.25) SKIP(4.29)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Настроечные параметры резервированиЯ"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON B-quit WIDGET-ID 100.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       v-invngbeg:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       v-invngend:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       v-negmanuf:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       v-negparts:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       v-parts-bc:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       v-prcshfc0:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       v-prcshrs0:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       v-prcshrs1:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       v-prdocfc0:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       v-prdocrs0:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       v-prdocrs1:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       v-prsalpr:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
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
      ('rezerv-obj':U,
       "invngbeg"
       ).
END.
ON CHOOSE OF B-10 IN FRAME Dialog-Frame
DO:
  run gbl/v-taobj.w
      ('rezerv-obj':U,
       "prcshfc0"
       ).
END.
ON CHOOSE OF B-11 IN FRAME Dialog-Frame
DO:
  run gbl/v-taobj.w
      ('rezerv-obj':U,
       "prdocrs0"
       ).
END.
ON CHOOSE OF B-2 IN FRAME Dialog-Frame
DO:
  run gbl/v-taobj.w
      ('rezerv-obj':U,
       "invngend"
       ).
END.
ON CHOOSE OF B-3 IN FRAME Dialog-Frame
DO:
  run gbl/v-taobj.w
      ('rezerv-obj':U,
       "negmanuf"
       ).
END.
ON CHOOSE OF B-4 IN FRAME Dialog-Frame
DO:
  run gbl/v-taobj.w
      ('rezerv-obj':U,
       "negparts"
       ).
END.
ON CHOOSE OF B-5 IN FRAME Dialog-Frame
DO:
  run gbl/v-taobj.w
      ('rezerv-obj':U,
       "prcshrs0"
       ).
END.
ON CHOOSE OF B-6 IN FRAME Dialog-Frame
DO:
  run gbl/v-taobj.w
      ('rezerv-obj':U,
       "prcshrs1"
       ).
END.
ON CHOOSE OF B-7 IN FRAME Dialog-Frame
DO:
  run gbl/v-taobj.w
      ('rezerv-obj':U,
       "prdocfc0" ).
END.
ON CHOOSE OF B-8 IN FRAME Dialog-Frame
DO:
  run gbl/v-taobj.w
      ('rezerv-obj':U,
       "prdocrs1"
       ).
END.
ON CHOOSE OF B-9 IN FRAME Dialog-Frame
DO:
  run gbl/v-taobj.w
      ('rezerv-obj':U,
       "prsalpr"
       ).
END.
ON MOUSE-SELECT-CLICK OF I-invngbeg IN FRAME Dialog-Frame
DO:
  MESSAGE I-invngbeg:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-invngend IN FRAME Dialog-Frame
DO:
  MESSAGE I-invngend:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-negmanuf IN FRAME Dialog-Frame
DO:
  MESSAGE I-negmanuf:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-negparts IN FRAME Dialog-Frame
DO:
  MESSAGE I-negparts:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-parts-bc IN FRAME Dialog-Frame
DO:
  MESSAGE I-parts-bc:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-prcshfc0 IN FRAME Dialog-Frame
DO:
  MESSAGE I-prcshfc0:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-prcshrs0 IN FRAME Dialog-Frame
DO:
  MESSAGE I-prcshrs0:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-prcshrs1 IN FRAME Dialog-Frame
DO:
  MESSAGE I-prcshrs1:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-prdocfc0 IN FRAME Dialog-Frame
DO:
  MESSAGE I-prdocfc0:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-prdocrs0 IN FRAME Dialog-Frame
DO:
  MESSAGE I-prdocrs0:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-prdocrs1 IN FRAME Dialog-Frame
DO:
  MESSAGE I-prdocrs1:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-prsalpr IN FRAME Dialog-Frame
DO:
  MESSAGE I-prsalpr:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on ' ' of invngbeg in frame Dialog-Frame
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
on delete-character of invngbeg in frame Dialog-Frame
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
on ctrl-d of invngbeg in frame Dialog-Frame
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
on ctrl-b of invngbeg in frame Dialog-Frame
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
on ctrl-e of invngbeg in frame Dialog-Frame
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
on ctrl-f of invngbeg in frame Dialog-Frame
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
  define MENU m-ed-date8
    MENU-ITEM m-ed-date8-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date8-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date8-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date8-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if invngbeg :POPUP-MENU in frame Dialog-Frame = ?
  then do:
    ASSIGN
      invngbeg :POPUP-MENU in frame Dialog-Frame = MENU m-ed-date8 :HANDLE
      invngbeg :MENU-MOUSE in frame Dialog-Frame = 3
    .
  end.
  define variable v-label-handle8 as handle no-undo .
  assign
    v-label-handle8 = invngbeg :side-label-handle in frame Dialog-Frame
  .
  if valid-handle (v-label-handle8)
  then do:
    if v-label-handle8 :tooltip = ""
    or v-label-handle8 :tooltip = ?
    then do:
      assign
        v-label-handle8 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date8-1 in menu m-ed-date8 DO:
    apply "ctrl-b":U to invngbeg in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date8-2 in menu m-ed-date8 DO:
    apply "ctrl-d":U to invngbeg in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date8-3 in menu m-ed-date8 DO:
    apply "ctrl-e":U to invngbeg in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date8-4 in menu m-ed-date8 DO:
    apply "ctrl-f":U to invngbeg in frame Dialog-Frame .
  END.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on ' ' of invngend in frame Dialog-Frame
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
on delete-character of invngend in frame Dialog-Frame
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
on ctrl-d of invngend in frame Dialog-Frame
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
on ctrl-b of invngend in frame Dialog-Frame
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
on ctrl-e of invngend in frame Dialog-Frame
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
on ctrl-f of invngend in frame Dialog-Frame
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
  define MENU m-ed-date10
    MENU-ITEM m-ed-date10-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date10-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date10-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date10-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if invngend :POPUP-MENU in frame Dialog-Frame = ?
  then do:
    ASSIGN
      invngend :POPUP-MENU in frame Dialog-Frame = MENU m-ed-date10 :HANDLE
      invngend :MENU-MOUSE in frame Dialog-Frame = 3
    .
  end.
  define variable v-label-handle10 as handle no-undo .
  assign
    v-label-handle10 = invngend :side-label-handle in frame Dialog-Frame
  .
  if valid-handle (v-label-handle10)
  then do:
    if v-label-handle10 :tooltip = ""
    or v-label-handle10 :tooltip = ?
    then do:
      assign
        v-label-handle10 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date10-1 in menu m-ed-date10 DO:
    apply "ctrl-b":U to invngend in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date10-2 in menu m-ed-date10 DO:
    apply "ctrl-d":U to invngend in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date10-3 in menu m-ed-date10 DO:
    apply "ctrl-e":U to invngend in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date10-4 in menu m-ed-date10 DO:
    apply "ctrl-f":U to invngend in frame Dialog-Frame .
  END.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
if p-obj-type <> "" then
   frame Dialog-Frame:title = frame Dialog-Frame:title + (if p-obj-type = 'орг':U then " фирма" else " маг") + string(p-obj-code) .
define variable loc#log as logical   no-undo .
define variable vss-include-info11 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
run disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY invngbeg invngend negmanuf negparts v-negparts prcshfc0 v-prcshfc0
          parts-bc prdocfc0 prsalpr v-prcshrs1 v-prcshrs0 prcshrs1 prcshrs0
          v-prdocrs1 v-prdocrs0 prdocrs1 prdocrs0 v-invngbeg v-invngend
          v-negmanuf v-parts-bc v-prdocfc0 v-prsalpr
      WITH FRAME Dialog-Frame.
  ENABLE B-exit I-invngbeg I-invngend I-negmanuf I-negparts I-prcshrs0
         I-prcshrs1 I-prdocfc0 I-prdocrs1 I-prsalpr I-parts-bc I-prcshfc0
         I-prdocrs0 B-quit B-Help B-1 invngbeg invngend B-2 B-3 negmanuf B-4
         negparts v-negparts B-10 prcshfc0 v-prcshfc0 parts-bc B-7 prdocfc0 B-9
         prsalpr B-6 v-prcshrs1 B-5 v-prcshrs0 prcshrs1 prcshrs0 B-8 v-prdocrs1
         B-11 v-prdocrs0 prdocrs1 prdocrs0 v-invngbeg v-invngend v-negmanuf
         v-parts-bc v-prdocfc0 v-prsalpr
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
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
  , input 'rezerv-obj':U
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
  , input 'rezerv-global':U
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
IF thbjattr_thbj-attr-g.prop-code = 'parts-bc':U THEN DO:     parts-bc = thbjattr_thbj-attr-g.property-value-logical.     parts-bc:private-data in frame Dialog-Frame = "recid3=" + string(recid(thbjattr_thbj-attr-g)).     display parts-bc with frame Dialog-Frame . END.
  create temp-thbj-attr.
  buffer-copy thbjattr_thbj-attr-g to temp-thbj-attr.
end.
FOR EACH thbjattr_thbj-attr
:
IF thbjattr_thbj-attr.prop-code = 'invngbeg':U THEN DO:     invngbeg = thbjattr_thbj-attr.property-value-date.     invngbeg:private-data in frame Dialog-Frame = "recid2=" + string(recid(thbjattr_thbj-attr)).     display invngbeg with frame Dialog-Frame . END.
IF thbjattr_thbj-attr.prop-code = 'invngend':U THEN DO:     invngend = thbjattr_thbj-attr.property-value-date.     invngend:private-data in frame Dialog-Frame = "recid2=" + string(recid(thbjattr_thbj-attr)).     display invngend with frame Dialog-Frame . END.
IF thbjattr_thbj-attr.prop-code = 'negmanuf':U THEN DO:     negmanuf = thbjattr_thbj-attr.property-value-character.     negmanuf:private-data in frame Dialog-Frame = "recid2=" + string(recid(thbjattr_thbj-attr)).     display negmanuf with frame Dialog-Frame . END.
IF thbjattr_thbj-attr.prop-code = 'negparts':U THEN DO:     negparts = thbjattr_thbj-attr.property-value-character.     negparts:private-data in frame Dialog-Frame = "recid2=" + string(recid(thbjattr_thbj-attr)).     display negparts with frame Dialog-Frame . END.
IF thbjattr_thbj-attr.prop-code = 'prcshfc0':U THEN DO:     prcshfc0 = thbjattr_thbj-attr.property-value-logical.     prcshfc0:private-data in frame Dialog-Frame = "recid2=" + string(recid(thbjattr_thbj-attr)).     display prcshfc0 with frame Dialog-Frame . END.
IF thbjattr_thbj-attr.prop-code = 'prcshrs0':U THEN DO:     prcshrs0 = thbjattr_thbj-attr.property-value-character.     prcshrs0:private-data in frame Dialog-Frame = "recid2=" + string(recid(thbjattr_thbj-attr)).     display prcshrs0 with frame Dialog-Frame . END.
IF thbjattr_thbj-attr.prop-code = 'prcshrs1':U THEN DO:     prcshrs1 = thbjattr_thbj-attr.property-value-character.     prcshrs1:private-data in frame Dialog-Frame = "recid2=" + string(recid(thbjattr_thbj-attr)).     display prcshrs1 with frame Dialog-Frame . END.
IF thbjattr_thbj-attr.prop-code = 'prdocfc0':U THEN DO:     prdocfc0 = thbjattr_thbj-attr.property-value-logical.     prdocfc0:private-data in frame Dialog-Frame = "recid2=" + string(recid(thbjattr_thbj-attr)).     display prdocfc0 with frame Dialog-Frame . END.
IF thbjattr_thbj-attr.prop-code = 'prdocrs0':U THEN DO:     prdocrs0 = thbjattr_thbj-attr.property-value-character.     prdocrs0:private-data in frame Dialog-Frame = "recid2=" + string(recid(thbjattr_thbj-attr)).     display prdocrs0 with frame Dialog-Frame . END.
IF thbjattr_thbj-attr.prop-code = 'prdocrs1':U THEN DO:     prdocrs1 = thbjattr_thbj-attr.property-value-character.     prdocrs1:private-data in frame Dialog-Frame = "recid2=" + string(recid(thbjattr_thbj-attr)).     display prdocrs1 with frame Dialog-Frame . END.
IF thbjattr_thbj-attr.prop-code = 'prsalpr':U THEN DO:     prsalpr = thbjattr_thbj-attr.property-value-logical.     prsalpr:private-data in frame Dialog-Frame = "recid2=" + string(recid(thbjattr_thbj-attr)).     display prsalpr with frame Dialog-Frame . END.
  create temp-thbj-attr.
  buffer-copy thbjattr_thbj-attr to temp-thbj-attr.
END.
define variable v-tooltip as character no-undo .
define variable v-label   as character no-undo .
define variable v-tooltip-code as character no-undo .
run thbjattr_tooltip in this-procedure (    input   'rezerv-obj':U   ,input  "invngbeg"   ,output v-tooltip   ,output v-label   ,output v-tooltip-code   ) no-error . v-invngbeg:screen-value = REPLACE ( entry(2,v-label,":") , "`" , "," ) .  I-invngbeg:private-data = REPLACE ( v-tooltip-code , "`" , "," ) .
run thbjattr_tooltip in this-procedure (    input   'rezerv-obj':U   ,input  "invngend"   ,output v-tooltip   ,output v-label   ,output v-tooltip-code   ) no-error . v-invngend:screen-value = REPLACE ( entry(2,v-label,":") , "`" , "," ) .  I-invngend:private-data = REPLACE ( v-tooltip-code , "`" , "," ) .
run thbjattr_tooltip in this-procedure (    input   'rezerv-obj':U   ,input  "negmanuf"   ,output v-tooltip   ,output v-label   ,output v-tooltip-code   ) no-error . v-negmanuf:screen-value = REPLACE ( entry(2,v-label,":") , "`" , "," ) .  I-negmanuf:private-data = REPLACE ( v-tooltip-code , "`" , "," ) .
run thbjattr_tooltip in this-procedure (    input   'rezerv-obj':U   ,input  "negparts"   ,output v-tooltip   ,output v-label   ,output v-tooltip-code   ) no-error . v-negparts:screen-value = REPLACE ( entry(2,v-label,":") , "`" , "," ) .  I-negparts:private-data = REPLACE ( v-tooltip-code , "`" , "," ) .
run thbjattr_tooltip in this-procedure (    input   'rezerv-obj':U   ,input  "prcshfc0"   ,output v-tooltip   ,output v-label   ,output v-tooltip-code   ) no-error . v-prcshfc0:screen-value = REPLACE ( entry(2,v-label,":") , "`" , "," ) .  I-prcshfc0:private-data = REPLACE ( v-tooltip-code , "`" , "," ) .
run thbjattr_tooltip in this-procedure (    input   'rezerv-obj':U   ,input  "prcshrs0"   ,output v-tooltip   ,output v-label   ,output v-tooltip-code   ) no-error . v-prcshrs0:screen-value = REPLACE ( entry(2,v-label,":") , "`" , "," ) .  I-prcshrs0:private-data = REPLACE ( v-tooltip-code , "`" , "," ) .
run thbjattr_tooltip in this-procedure (    input   'rezerv-obj':U   ,input  "prcshrs1"   ,output v-tooltip   ,output v-label   ,output v-tooltip-code   ) no-error . v-prcshrs1:screen-value = REPLACE ( entry(2,v-label,":") , "`" , "," ) .  I-prcshrs1:private-data = REPLACE ( v-tooltip-code , "`" , "," ) .
run thbjattr_tooltip in this-procedure (    input   'rezerv-obj':U   ,input  "prdocfc0"   ,output v-tooltip   ,output v-label   ,output v-tooltip-code   ) no-error . v-prdocfc0:screen-value = REPLACE ( entry(2,v-label,":") , "`" , "," ) .  I-prdocfc0:private-data = REPLACE ( v-tooltip-code , "`" , "," ) .
run thbjattr_tooltip in this-procedure (    input   'rezerv-obj':U   ,input  "prdocrs0"   ,output v-tooltip   ,output v-label   ,output v-tooltip-code   ) no-error . v-prdocrs0:screen-value = REPLACE ( entry(2,v-label,":") , "`" , "," ) .  I-prdocrs0:private-data = REPLACE ( v-tooltip-code , "`" , "," ) .
run thbjattr_tooltip in this-procedure (    input   'rezerv-obj':U   ,input  "prdocrs1"   ,output v-tooltip   ,output v-label   ,output v-tooltip-code   ) no-error . v-prdocrs1:screen-value = REPLACE ( entry(2,v-label,":") , "`" , "," ) .  I-prdocrs1:private-data = REPLACE ( v-tooltip-code , "`" , "," ) .
run thbjattr_tooltip in this-procedure (    input   'rezerv-obj':U   ,input  "prsalpr"   ,output v-tooltip   ,output v-label   ,output v-tooltip-code   ) no-error . v-prsalpr:screen-value = REPLACE ( entry(2,v-label,":") , "`" , "," ) .  I-prsalpr:private-data = REPLACE ( v-tooltip-code , "`" , "," ) .
run thbjattr_tooltip in this-procedure (    input   'rezerv-global':U   ,input  "parts-bc"   ,output v-tooltip   ,output v-label   ,output v-tooltip-code   ) no-error . v-parts-bc:screen-value = REPLACE ( entry(2,v-label,":") , "`" , "," ) .  I-parts-bc:private-data = REPLACE ( v-tooltip-code , "`" , "," ) .
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
        and   obj_thbj-attr.upper-prop-code = 'rezerv-obj':U
        and   obj_thbj-attr.prop-code = '':u no-wait no-error.
     if locked obj_thbj-attr then do:
        message
        vss-workfile vss-revision vss-description skip
        'rezerv-obj':U skip
        "Запись ПАРАМЕТРОВ  занята"
        view-as alert-box error .
        undo, return error.
      end.
    find first glb_thbj-attr exclusive-lock where
              glb_thbj-attr.obj-type = ""
        and   glb_thbj-attr.obj-code = 0
        and   glb_thbj-attr.upper-prop-code = 'rezerv-global':U
        and   glb_thbj-attr.prop-code = '':u no-wait no-error.
     if locked glb_thbj-attr then do:
        message
        vss-workfile vss-revision vss-description skip
        'rezerv-global':U skip
        "Запись Глобальных ПАРАМЕТРОВ  занята"
        view-as alert-box error .
        undo, return error.
      end.
  end.
  else do:
    find first obj_thbj-attr no-lock where
          obj_thbj-attr.obj-type = p-obj-type
    and   obj_thbj-attr.obj-code = p-obj-code
    and   obj_thbj-attr.upper-prop-code = 'rezerv-obj':U
    and   obj_thbj-attr.prop-code = '':u no-error.
    find first glb_thbj-attr no-lock where
          glb_thbj-attr.obj-type = ""
    and   glb_thbj-attr.obj-code = 0
    and   glb_thbj-attr.upper-prop-code = 'rezerv-global':U
    and   glb_thbj-attr.prop-code = '':u no-error.
  end.
  if not available obj_thbj-attr then do:
    assign
      v-to-create-trn  = true
      .
    message
    substitute ("Внимание!!!&1Параметра НЕТ в БД!&1Будут показаны ЗНАЧЕНИЯ ПО УМОЛЧАНИЮ",
                chr(10))
                 view-as alert-box warning.
  end.
  if not available glb_thbj-attr then do:
    assign
      v-to-create-trn-g  = true
      .
    message
    substitute ("Внимание!!!&1Гл.Параметра НЕТ в БД!&1Будут показаны ЗНАЧЕНИЯ ПО УМОЛЧАНИЮ",
                chr(10))
                 view-as alert-box warning.
  end.
  run fill-widgets in this-procedure no-error.
  if error-status:error then undo, return error.
  if p-mode <> 'ИЗМЕНЕНИЕ':U then do:
     disable
     invngbeg
     invngend
     prcshfc0
     prcshrs0
     negmanuf
     negparts
     prcshrs1
     prdocfc0
     prdocrs0
     parts-bc
     prsalpr
     prdocrs1
     with frame Dialog-Frame.
     B-exit:label = "Вы&ход"  .
     hide B-quit in frame Dialog-Frame .
  END.
  if not ( p-obj-type = "" and p-obj-code = 0 ) then do:
     disable
       parts-bc
     with frame Dialog-Frame.
  end.
end procedure.
PROCEDURE init-tt :
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
IF p-mode = 'ПРОСМОТР':U THEN RETURN .
define variable loc#log as logical   no-undo .
define variable vss-include-info12 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
    invngbeg FRAME Dialog-Frame
    invngend
    parts-bc
    prcshfc0
    prcshrs0
    negmanuf
    negparts
    prcshrs1
    prdocfc0
    prdocrs0
    prdocrs1
    prsalpr
 .
assign
  fh = frame Dialog-Frame:first-child
  wh = fh:first-child
  .
do while valid-handle(wh):
  if wh:private-data begins "recid2=" then do:
    find first thbjattr_thbj-attr where
               recid(thbjattr_thbj-attr) = integer(entry(2, wh:private-data, '='))
               no-error .
    if available thbjattr_thbj-attr then do:
    assign
    buffer thbjattr_thbj-attr:buffer-field("property-value-" + wh:data-type):buffer-value = wh:input-value.
           thbjattr_thbj-attr.obj-type = p-obj-type.
           thbjattr_thbj-attr.obj-code = p-obj-code.
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
      , input 'rezerv-obj':U
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
          , input 'rezerv-global':U
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
