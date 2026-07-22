define input parameter parparentproc as widget-handle no-undo.
define input parameter p-mode        as character no-undo.
define input parameter p-obj-type    like ub.clients.obj-type no-undo.
define input parameter p-obj-code    like ub.shop.obj-code no-undo.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-Workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Настроечные параметры для инвентаризации" .
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
DEFINE BUTTON B-12
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
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE VARIABLE inv-prs AS INTEGER FORMAT ">>9":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 13.38 BY 1 NO-UNDO.
DEFINE VARIABLE mxpcdcp AS DECIMAL FORMAT "->>,>>9.99":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 13.38 BY 1 NO-UNDO.
DEFINE VARIABLE mxpcicp AS DECIMAL FORMAT "->>,>>9.99":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 13.38 BY 1 NO-UNDO.
DEFINE VARIABLE mxsmdcp AS DECIMAL FORMAT "->>,>>9.99":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 13.38 BY 1 NO-UNDO.
DEFINE VARIABLE mxsmicp AS DECIMAL FORMAT "->>,>>9.99":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 13.38 BY 1 NO-UNDO.
DEFINE VARIABLE v-inv-prs AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 90.5 BY 1 NO-UNDO.
DEFINE VARIABLE v-invclcas AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 101.75 BY 1 NO-UNDO.
DEFINE VARIABLE v-invclcsp AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 98.63 BY 1 NO-UNDO.
DEFINE VARIABLE v-invclcwt AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 101.75 BY 1 NO-UNDO.
DEFINE VARIABLE v-invdnull AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 98.13 BY 1 NO-UNDO.
DEFINE VARIABLE v-izlcstpr AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 98.13 BY 1 NO-UNDO.
DEFINE VARIABLE v-mxpcdcp AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 87.5 BY 1 NO-UNDO.
DEFINE VARIABLE v-mxpcicp AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 87.5 BY 1 NO-UNDO.
DEFINE VARIABLE v-mxsmdcp AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 87.5 BY 1 NO-UNDO.
DEFINE VARIABLE v-mxsmicp AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 87.5 BY 1 NO-UNDO.
DEFINE VARIABLE v-minus AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 98.13 BY 1 NO-UNDO.
DEFINE VARIABLE v-pstgrp AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 98.13 BY 1 NO-UNDO.
DEFINE VARIABLE v-pstunit AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 98.13 BY 1 NO-UNDO.
DEFINE VARIABLE v-pstunqtn AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 98.13 BY 1 NO-UNDO.
DEFINE VARIABLE v-wastage AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 98.13 BY 1 NO-UNDO.
DEFINE IMAGE I-inv-prs
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.04.
DEFINE IMAGE I-invclcas
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.
DEFINE IMAGE I-invclcsp
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.
DEFINE IMAGE I-invclcwt
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.
DEFINE IMAGE I-invdnull
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.
DEFINE IMAGE I-izlcstpr
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.
DEFINE IMAGE I-mxpcdcp
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.04.
DEFINE IMAGE I-mxpcicp
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.
DEFINE IMAGE I-mxsmdcp
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.
DEFINE IMAGE I-mxsmicp
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.04.
DEFINE IMAGE I-minus
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.
DEFINE IMAGE I-pstgrp
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.
DEFINE IMAGE I-pstunit
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.
DEFINE IMAGE I-pstunqtn
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.
DEFINE IMAGE I-wastage
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.
DEFINE VARIABLE invclcas AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.38 BY 1 NO-UNDO.
DEFINE VARIABLE invclcsp AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.38 BY 1 NO-UNDO.
DEFINE VARIABLE invclcwt AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.38 BY 1 NO-UNDO.
DEFINE VARIABLE invdnull AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.38 BY 1 NO-UNDO.
DEFINE VARIABLE izlcstpr AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.38 BY 1 NO-UNDO.
DEFINE VARIABLE minus AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.38 BY 1 NO-UNDO.
DEFINE VARIABLE pstgrp AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.38 BY 1 NO-UNDO.
DEFINE VARIABLE pstunit AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.38 BY 1 NO-UNDO.
DEFINE VARIABLE pstunqtn AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.38 BY 1 NO-UNDO.
DEFINE VARIABLE wastage AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.38 BY 1 NO-UNDO.
DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     B-quit AT ROW 1 COL 11
     B-Help AT ROW 1 COL 98
     B-2 AT ROW 3.04 COL 3.63 WIDGET-ID 82
     invclcsp AT ROW 3.04 COL 6.63 WIDGET-ID 46
     B-3 AT ROW 4 COL 3.63 WIDGET-ID 84
     invdnull AT ROW 4 COL 6.63 WIDGET-ID 52
     B-4 AT ROW 5.04 COL 3.63 WIDGET-ID 86
     pstunqtn AT ROW 5.04 COL 6.63 WIDGET-ID 58
     invclcas AT ROW 6 COL 3.63 WIDGET-ID 182
     invclcwt AT ROW 7 COL 3.63 WIDGET-ID 148
     inv-prs AT ROW 8 COL 1.63 COLON-ALIGNED NO-LABEL WIDGET-ID 194
     B-7 AT ROW 9.25 COL 3.63 WIDGET-ID 92
     wastage AT ROW 9.25 COL 6.63 WIDGET-ID 96
     B-1 AT ROW 12.92 COL 3.63 WIDGET-ID 80
     mxpcdcp AT ROW 12.92 COL 4.63 COLON-ALIGNED NO-LABEL WIDGET-ID 48
     B-9 AT ROW 14 COL 3.63 WIDGET-ID 108
     mxpcicp AT ROW 14 COL 4.63 COLON-ALIGNED NO-LABEL WIDGET-ID 186
     B-5 AT ROW 15.75 COL 3.63 WIDGET-ID 88
     mxsmdcp AT ROW 15.75 COL 4.63 COLON-ALIGNED NO-LABEL WIDGET-ID 188
     B-6 AT ROW 16.88 COL 3.63 WIDGET-ID 90
     mxsmicp AT ROW 16.88 COL 4.63 COLON-ALIGNED NO-LABEL WIDGET-ID 190
     B-8 AT ROW 18.63 COL 3.63 WIDGET-ID 198
     pstgrp AT ROW 18.63 COL 6.63 WIDGET-ID 202
     B-11 AT ROW 20 COL 3.63 WIDGET-ID 298
     pstunit AT ROW 20 COL 6.63 WIDGET-ID 302
     B-10 AT ROW 21.5 COL 3.63 WIDGET-ID 84
     izlcstpr AT ROW 21.5 COL 6.63 WIDGET-ID 20
     B-12 AT ROW 22.71 COL 3.75 WIDGET-ID 306
     minus AT ROW 22.71 COL 6.75 WIDGET-ID 308
     v-invclcsp AT ROW 3.04 COL 9.38 NO-LABEL WIDGET-ID 18
     v-invdnull AT ROW 4 COL 9.38 NO-LABEL WIDGET-ID 54
     v-pstunqtn AT ROW 5.13 COL 9.38 NO-LABEL WIDGET-ID 60
     v-invclcas AT ROW 6 COL 5.75 NO-LABEL WIDGET-ID 184
     v-invclcwt AT ROW 7 COL 5.75 NO-LABEL WIDGET-ID 150
     v-inv-prs AT ROW 8 COL 17 NO-LABEL WIDGET-ID 196
     v-wastage AT ROW 9.38 COL 9.38 NO-LABEL WIDGET-ID 98
     v-mxpcdcp AT ROW 12.92 COL 20 NO-LABEL WIDGET-ID 6
     v-mxpcicp AT ROW 14 COL 20 NO-LABEL WIDGET-ID 114
     v-mxsmdcp AT ROW 15.75 COL 20 NO-LABEL WIDGET-ID 66
     v-mxsmicp AT ROW 16.88 COL 20 NO-LABEL WIDGET-ID 78
     v-pstgrp AT ROW 18.63 COL 9.38 NO-LABEL WIDGET-ID 204
     v-pstunit AT ROW 20 COL 9.38 NO-LABEL WIDGET-ID 304
     v-izlcstpr AT ROW 21.5 COL 7.38 COLON-ALIGNED NO-LABEL WIDGET-ID 20
     v-minus AT ROW 22.71 COL 7.5 COLON-ALIGNED NO-LABEL WIDGET-ID 310
     I-mxpcdcp AT ROW 12.92 COL 1 WIDGET-ID 10
     I-invclcsp AT ROW 3.04 COL 1 WIDGET-ID 34
     I-invdnull AT ROW 4 COL 1 WIDGET-ID 50
     I-pstunqtn AT ROW 5.04 COL 1 WIDGET-ID 56
     I-mxsmdcp AT ROW 15.75 COL 1 WIDGET-ID 64
     I-mxsmicp AT ROW 16.88 COL 1 WIDGET-ID 72
     I-wastage AT ROW 9.25 COL 1 WIDGET-ID 94
     I-mxpcicp AT ROW 14 COL 1 WIDGET-ID 110
     I-invclcwt AT ROW 7 COL 1 WIDGET-ID 146
     I-invclcas AT ROW 6 COL 1 WIDGET-ID 180
     I-inv-prs AT ROW 8 COL 1 WIDGET-ID 192
     I-pstgrp AT ROW 18.63 COL 1 WIDGET-ID 200
     I-pstunit AT ROW 20 COL 1 WIDGET-ID 300
     I-izlcstpr AT ROW 21.5 COL 1 WIDGET-ID 36
     I-minus AT ROW 22.67 COL 1 WIDGET-ID 312
     SPACE(103.99) SKIP(0.32)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Настройки Инвентаризации"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON B-quit WIDGET-ID 100.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       v-inv-prs:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       v-invclcas:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       v-invclcsp:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       v-invclcwt:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       v-invdnull:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       v-mxpcdcp:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       v-mxpcicp:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       v-mxsmdcp:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       v-mxsmicp:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       v-pstgrp:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       v-pstunit:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       v-pstunqtn:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       v-wastage:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
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
      ('inv-obj':U,
       "mxpcdcp"
       ).
END.
ON CHOOSE OF B-10 IN FRAME Dialog-Frame
DO:
  run gbl/v-taobj.w
      ('inv-obj':U,
       "izlcstpr"
       ).
END.
ON CHOOSE OF B-11 IN FRAME Dialog-Frame
DO:
  run gbl/v-taobj.w
      ('inv-obj':U,
       "pstunit"
       ).
END.
ON CHOOSE OF B-12 IN FRAME Dialog-Frame
DO:
  run gbl/v-taobj.w
      ('inv-obj':U,
       "minus"
       ).
END.
ON CHOOSE OF B-2 IN FRAME Dialog-Frame
DO:
  run gbl/v-taobj.w
      ('inv-obj':U,
       "invclcsp"
       ).
END.
ON CHOOSE OF B-3 IN FRAME Dialog-Frame
DO:
  run gbl/v-taobj.w
      ('inv-obj':U,
       "invdnull"
       ).
END.
ON CHOOSE OF B-4 IN FRAME Dialog-Frame
DO:
  run gbl/v-taobj.w
      ('inv-obj':U,
       "pstunqtn"
       ).
END.
ON CHOOSE OF B-5 IN FRAME Dialog-Frame
DO:
  run gbl/v-taobj.w
      ('inv-obj':U,
       "mxsmdcp"
       ).
END.
ON CHOOSE OF B-6 IN FRAME Dialog-Frame
DO:
  run gbl/v-taobj.w
      ('inv-obj':U,
       "mxsmicp"
       ).
END.
ON CHOOSE OF B-7 IN FRAME Dialog-Frame
DO:
  run gbl/v-taobj.w
      ('inv-obj':U,
       "wastage"
       ).
END.
ON CHOOSE OF B-8 IN FRAME Dialog-Frame
DO:
  run gbl/v-taobj.w
      ('inv-obj':U,
       "pstgrp"
       ).
END.
ON CHOOSE OF B-9 IN FRAME Dialog-Frame
DO:
  run gbl/v-taobj.w
      ('inv-obj':U,
       "mxpcicp"
       ).
END.
ON MOUSE-SELECT-CLICK OF I-inv-prs IN FRAME Dialog-Frame
DO:
  MESSAGE I-inv-prs:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-invclcas IN FRAME Dialog-Frame
DO:
  MESSAGE I-invclcas:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-invclcsp IN FRAME Dialog-Frame
DO:
  MESSAGE I-invclcsp:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-invclcwt IN FRAME Dialog-Frame
DO:
  MESSAGE I-invclcwt:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-invdnull IN FRAME Dialog-Frame
DO:
  MESSAGE I-invdnull:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-izlcstpr IN FRAME Dialog-Frame
DO:
  MESSAGE I-izlcstpr:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-mxpcdcp IN FRAME Dialog-Frame
DO:
  MESSAGE I-mxpcdcp:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-mxpcicp IN FRAME Dialog-Frame
DO:
  MESSAGE I-mxpcicp:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-mxsmdcp IN FRAME Dialog-Frame
DO:
  MESSAGE I-mxsmdcp:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-mxsmicp IN FRAME Dialog-Frame
DO:
  MESSAGE I-mxsmicp:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-minus IN FRAME Dialog-Frame
DO:
  MESSAGE I-minus:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-pstgrp IN FRAME Dialog-Frame
DO:
  MESSAGE I-pstgrp:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-pstunit IN FRAME Dialog-Frame
DO:
  MESSAGE I-pstunit:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-pstunqtn IN FRAME Dialog-Frame
DO:
  MESSAGE I-pstunqtn:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-wastage IN FRAME Dialog-Frame
DO:
  MESSAGE I-wastage:private-data  VIEW-AS ALERT-BOX INFORMATION.
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
on ' ' of mxpcdcp in frame Dialog-Frame
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
on delete-character of mxpcdcp in frame Dialog-Frame
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
on ctrl-d of mxpcdcp in frame Dialog-Frame
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
on ctrl-b of mxpcdcp in frame Dialog-Frame
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
on ctrl-e of mxpcdcp in frame Dialog-Frame
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
on ctrl-f of mxpcdcp in frame Dialog-Frame
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
  if mxpcdcp :POPUP-MENU in frame Dialog-Frame = ?
  then do:
    ASSIGN
      mxpcdcp :POPUP-MENU in frame Dialog-Frame = MENU m-ed-date8 :HANDLE
      mxpcdcp :MENU-MOUSE in frame Dialog-Frame = 3
    .
  end.
  define variable v-label-handle8 as handle no-undo .
  assign
    v-label-handle8 = mxpcdcp :side-label-handle in frame Dialog-Frame
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
    apply "ctrl-b":U to mxpcdcp in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date8-2 in menu m-ed-date8 DO:
    apply "ctrl-d":U to mxpcdcp in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date8-3 in menu m-ed-date8 DO:
    apply "ctrl-e":U to mxpcdcp in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date8-4 in menu m-ed-date8 DO:
    apply "ctrl-f":U to mxpcdcp in frame Dialog-Frame .
  END.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
if p-obj-type <> "" then
   frame Dialog-Frame:title = frame Dialog-Frame:title + (if p-obj-type = 'орг':U then " фирма" else " маг") + string(p-obj-code) .
define variable loc#log as logical   no-undo .
define variable vss-include-info9 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  DISPLAY invclcsp invdnull pstunqtn invclcas invclcwt inv-prs wastage mxpcdcp
          mxpcicp mxsmdcp mxsmicp pstgrp pstunit izlcstpr minus v-invclcsp
          v-invdnull v-pstunqtn v-invclcas v-invclcwt v-inv-prs v-wastage
          v-mxpcdcp v-mxpcicp v-mxsmdcp v-mxsmicp v-pstgrp v-pstunit v-izlcstpr
          v-minus
      WITH FRAME Dialog-Frame.
  ENABLE B-exit I-mxpcdcp I-invclcsp I-invdnull I-pstunqtn I-mxsmdcp I-mxsmicp
         I-wastage I-mxpcicp I-invclcwt I-invclcas I-inv-prs I-pstgrp I-pstunit
         I-izlcstpr I-minus B-quit B-Help B-2 invclcsp B-3 invdnull B-4
         pstunqtn invclcas invclcwt inv-prs B-7 wastage B-1 mxpcdcp B-9 mxpcicp
         B-5 mxsmdcp B-6 mxsmicp B-8 pstgrp B-11 pstunit B-10 izlcstpr B-12
         minus v-invclcsp v-invdnull v-pstunqtn v-invclcas v-invclcwt
         v-inv-prs v-wastage v-mxpcdcp v-mxpcicp v-mxsmdcp v-mxsmicp v-pstgrp
         v-pstunit v-izlcstpr v-minus
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
  , input 'inv-obj':U
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
  , input 'inv-global':U
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
IF thbjattr_thbj-attr-g.prop-code = 'invclcwt':U THEN DO:     invclcwt = thbjattr_thbj-attr-g.property-value-logical.     invclcwt:private-data in frame Dialog-Frame = "recid3=" + string(recid(thbjattr_thbj-attr-g)).     display invclcwt with frame Dialog-Frame . END.
IF thbjattr_thbj-attr-g.prop-code = 'invclcas':U THEN DO:     invclcas = thbjattr_thbj-attr-g.property-value-logical.     invclcas:private-data in frame Dialog-Frame = "recid3=" + string(recid(thbjattr_thbj-attr-g)).     display invclcas with frame Dialog-Frame . END.
IF thbjattr_thbj-attr-g.prop-code = 'inv-prs':U THEN DO:     inv-prs = thbjattr_thbj-attr-g.property-value-integer.     inv-prs:private-data in frame Dialog-Frame = "recid3=" + string(recid(thbjattr_thbj-attr-g)).     display inv-prs with frame Dialog-Frame . END.
  create temp-thbj-attr.
  buffer-copy thbjattr_thbj-attr-g to temp-thbj-attr.
end.
FOR EACH thbjattr_thbj-attr
:
IF thbjattr_thbj-attr.prop-code = 'mxpcdcp':U THEN DO:     mxpcdcp = thbjattr_thbj-attr.property-value-decimal.     mxpcdcp:private-data in frame Dialog-Frame = "recid2=" + string(recid(thbjattr_thbj-attr)).     display mxpcdcp with frame Dialog-Frame . END.
IF thbjattr_thbj-attr.prop-code = 'invclcsp':U THEN DO:     invclcsp = thbjattr_thbj-attr.property-value-logical.     invclcsp:private-data in frame Dialog-Frame = "recid2=" + string(recid(thbjattr_thbj-attr)).     display invclcsp with frame Dialog-Frame . END.
IF thbjattr_thbj-attr.prop-code = 'invdnull':U THEN DO:     invdnull = thbjattr_thbj-attr.property-value-logical.     invdnull:private-data in frame Dialog-Frame = "recid2=" + string(recid(thbjattr_thbj-attr)).     display invdnull with frame Dialog-Frame . END.
IF thbjattr_thbj-attr.prop-code = 'pstunqtn':U THEN DO:     pstunqtn = thbjattr_thbj-attr.property-value-logical.     pstunqtn:private-data in frame Dialog-Frame = "recid2=" + string(recid(thbjattr_thbj-attr)).     display pstunqtn with frame Dialog-Frame . END.
IF thbjattr_thbj-attr.prop-code = 'mxsmdcp':U THEN DO:     mxsmdcp = thbjattr_thbj-attr.property-value-decimal.     mxsmdcp:private-data in frame Dialog-Frame = "recid2=" + string(recid(thbjattr_thbj-attr)).     display mxsmdcp with frame Dialog-Frame . END.
IF thbjattr_thbj-attr.prop-code = 'mxsmicp':U THEN DO:     mxsmicp = thbjattr_thbj-attr.property-value-decimal.     mxsmicp:private-data in frame Dialog-Frame = "recid2=" + string(recid(thbjattr_thbj-attr)).     display mxsmicp with frame Dialog-Frame . END.
IF thbjattr_thbj-attr.prop-code = 'wastage':U THEN DO:     wastage = thbjattr_thbj-attr.property-value-logical.     wastage:private-data in frame Dialog-Frame = "recid2=" + string(recid(thbjattr_thbj-attr)).     display wastage with frame Dialog-Frame . END.
IF thbjattr_thbj-attr.prop-code = 'pstgrp':U THEN DO:     pstgrp = thbjattr_thbj-attr.property-value-logical.     pstgrp:private-data in frame Dialog-Frame = "recid2=" + string(recid(thbjattr_thbj-attr)).     display pstgrp with frame Dialog-Frame . END.
IF thbjattr_thbj-attr.prop-code = 'pstunit':U THEN DO:     pstunit = thbjattr_thbj-attr.property-value-logical.     pstunit:private-data in frame Dialog-Frame = "recid2=" + string(recid(thbjattr_thbj-attr)).     display pstunit with frame Dialog-Frame . END.
IF thbjattr_thbj-attr.prop-code = 'mxpcicp':U THEN DO:     mxpcicp = thbjattr_thbj-attr.property-value-decimal.     mxpcicp:private-data in frame Dialog-Frame = "recid2=" + string(recid(thbjattr_thbj-attr)).     display mxpcicp with frame Dialog-Frame . END.
IF thbjattr_thbj-attr.prop-code = 'izlcstpr':U THEN DO:     izlcstpr = thbjattr_thbj-attr.property-value-logical.     izlcstpr:private-data in frame Dialog-Frame = "recid2=" + string(recid(thbjattr_thbj-attr)).     display izlcstpr with frame Dialog-Frame . END.
IF thbjattr_thbj-attr.prop-code = 'minus':U THEN DO:     minus = thbjattr_thbj-attr.property-value-logical.     minus:private-data in frame Dialog-Frame = "recid2=" + string(recid(thbjattr_thbj-attr)).     display minus with frame Dialog-Frame . END.
  create temp-thbj-attr.
  buffer-copy thbjattr_thbj-attr to temp-thbj-attr.
END.
define variable v-tooltip as character no-undo .
define variable v-label   as character no-undo .
define variable v-tooltip-code as character no-undo .
run thbjattr_tooltip in this-procedure (    input   'inv-obj':U   ,input  "mxpcdcp"   ,output v-tooltip   ,output v-label   ,output v-tooltip-code   ) no-error . v-mxpcdcp:screen-value = REPLACE ( entry(2,v-label,":") , "`" , "," ) .  I-mxpcdcp:private-data = REPLACE ( v-tooltip-code , "`" , "," ) .
run thbjattr_tooltip in this-procedure (    input   'inv-obj':U   ,input  "invclcsp"   ,output v-tooltip   ,output v-label   ,output v-tooltip-code   ) no-error . v-invclcsp:screen-value = REPLACE ( entry(2,v-label,":") , "`" , "," ) .  I-invclcsp:private-data = REPLACE ( v-tooltip-code , "`" , "," ) .
run thbjattr_tooltip in this-procedure (    input   'inv-obj':U   ,input  "mxsmdcp"   ,output v-tooltip   ,output v-label   ,output v-tooltip-code   ) no-error . v-mxsmdcp:screen-value = REPLACE ( entry(2,v-label,":") , "`" , "," ) .  I-mxsmdcp:private-data = REPLACE ( v-tooltip-code , "`" , "," ) .
run thbjattr_tooltip in this-procedure (    input   'inv-obj':U   ,input  "mxsmicp"   ,output v-tooltip   ,output v-label   ,output v-tooltip-code   ) no-error . v-mxsmicp:screen-value = REPLACE ( entry(2,v-label,":") , "`" , "," ) .  I-mxsmicp:private-data = REPLACE ( v-tooltip-code , "`" , "," ) .
run thbjattr_tooltip in this-procedure (    input   'inv-obj':U   ,input  "invdnull"   ,output v-tooltip   ,output v-label   ,output v-tooltip-code   ) no-error . v-invdnull:screen-value = REPLACE ( entry(2,v-label,":") , "`" , "," ) .  I-invdnull:private-data = REPLACE ( v-tooltip-code , "`" , "," ) .
run thbjattr_tooltip in this-procedure (    input   'inv-obj':U   ,input  "pstunqtn"   ,output v-tooltip   ,output v-label   ,output v-tooltip-code   ) no-error . v-pstunqtn:screen-value = REPLACE ( entry(2,v-label,":") , "`" , "," ) .  I-pstunqtn:private-data = REPLACE ( v-tooltip-code , "`" , "," ) .
run thbjattr_tooltip in this-procedure (    input   'inv-obj':U   ,input  "wastage"   ,output v-tooltip   ,output v-label   ,output v-tooltip-code   ) no-error . v-wastage:screen-value = REPLACE ( entry(2,v-label,":") , "`" , "," ) .  I-wastage:private-data = REPLACE ( v-tooltip-code , "`" , "," ) .
run thbjattr_tooltip in this-procedure (    input   'inv-obj':U   ,input  "pstgrp"   ,output v-tooltip   ,output v-label   ,output v-tooltip-code   ) no-error . v-pstgrp:screen-value = REPLACE ( entry(2,v-label,":") , "`" , "," ) .  I-pstgrp:private-data = REPLACE ( v-tooltip-code , "`" , "," ) .
run thbjattr_tooltip in this-procedure (    input   'inv-obj':U   ,input  "pstunit"   ,output v-tooltip   ,output v-label   ,output v-tooltip-code   ) no-error . v-pstunit:screen-value = REPLACE ( entry(2,v-label,":") , "`" , "," ) .  I-pstunit:private-data = REPLACE ( v-tooltip-code , "`" , "," ) .
run thbjattr_tooltip in this-procedure (    input   'inv-obj':U   ,input  "mxpcicp"   ,output v-tooltip   ,output v-label   ,output v-tooltip-code   ) no-error . v-mxpcicp:screen-value = REPLACE ( entry(2,v-label,":") , "`" , "," ) .  I-mxpcicp:private-data = REPLACE ( v-tooltip-code , "`" , "," ) .
run thbjattr_tooltip in this-procedure (    input   'inv-global':U   ,input  "invclcwt"   ,output v-tooltip   ,output v-label   ,output v-tooltip-code   ) no-error . v-invclcwt:screen-value = REPLACE ( entry(2,v-label,":") , "`" , "," ) .  I-invclcwt:private-data = REPLACE ( v-tooltip-code , "`" , "," ) .
run thbjattr_tooltip in this-procedure (    input   'inv-global':U   ,input  "invclcas"   ,output v-tooltip   ,output v-label   ,output v-tooltip-code   ) no-error . v-invclcas:screen-value = REPLACE ( entry(2,v-label,":") , "`" , "," ) .  I-invclcas:private-data = REPLACE ( v-tooltip-code , "`" , "," ) .
run thbjattr_tooltip in this-procedure (    input   'inv-global':U   ,input  "inv-prs"   ,output v-tooltip   ,output v-label   ,output v-tooltip-code   ) no-error . v-inv-prs:screen-value = REPLACE ( entry(2,v-label,":") , "`" , "," ) .  I-inv-prs:private-data = REPLACE ( v-tooltip-code , "`" , "," ) .
run thbjattr_tooltip in this-procedure (    input   'inv-obj':U   ,input  "izlcstpr"   ,output v-tooltip   ,output v-label   ,output v-tooltip-code   ) no-error . v-izlcstpr:screen-value = REPLACE ( entry(2,v-label,":") , "`" , "," ) .  I-izlcstpr:private-data = REPLACE ( v-tooltip-code , "`" , "," ) .
run thbjattr_tooltip in this-procedure (    input   'inv-obj':U   ,input  "minus"   ,output v-tooltip   ,output v-label   ,output v-tooltip-code   ) no-error . v-minus:screen-value = REPLACE ( entry(2,v-label,":") , "`" , "," ) .  I-minus:private-data = REPLACE ( v-tooltip-code , "`" , "," ) .
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
        and   obj_thbj-attr.upper-prop-code = 'inv-obj':U
        and   obj_thbj-attr.prop-code = '':u no-wait no-error.
     if locked obj_thbj-attr then do:
        message
        vss-workfile vss-revision vss-description skip
        'inv-obj':U skip
        "Запись ПАРАМЕТРОВ  занята"
        view-as alert-box error .
        undo, return error.
      end.
    find first glb_thbj-attr exclusive-lock where
              glb_thbj-attr.obj-type = ""
        and   glb_thbj-attr.obj-code = 0
        and   glb_thbj-attr.upper-prop-code = 'inv-global':U
        and   glb_thbj-attr.prop-code = '':u no-wait no-error.
     if locked glb_thbj-attr then do:
        message
        vss-workfile vss-revision vss-description skip
        'inv-global':U skip
        "Запись Глобальных ПАРАМЕТРОВ  занята"
        view-as alert-box error .
        undo, return error.
      end.
  end.
  else do:
    find first obj_thbj-attr no-lock where
          obj_thbj-attr.obj-type = p-obj-type
    and   obj_thbj-attr.obj-code = p-obj-code
    and   obj_thbj-attr.upper-prop-code = 'inv-obj':U
    and   obj_thbj-attr.prop-code = '':u no-error.
    find first glb_thbj-attr no-lock where
          glb_thbj-attr.obj-type = ""
    and   glb_thbj-attr.obj-code = 0
    and   glb_thbj-attr.upper-prop-code = 'inv-global':U
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
     mxpcdcp
     invclcsp
     mxsmdcp
     mxsmicp
     invdnull
     pstunqtn
     wastage
     mxpcicp
     invclcwt
     invclcas
     inv-prs
     pstgrp
     pstunit
     izlcstpr
     minus
     with frame Dialog-Frame.
     B-exit:label = "Вы&ход"  .
     hide B-quit in frame Dialog-Frame .
  END.
  if not ( p-obj-type = "" and p-obj-code = 0 ) then do:
     disable
       pstgrp
       invclcwt
       invclcas
       inv-prs
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
ASSIGN
    mxpcdcp FRAME Dialog-Frame
    invclcsp
    mxsmdcp
    mxsmicp
    invdnull
    pstunqtn
    wastage
    mxpcicp
    invclcwt
    invclcas
    inv-prs
    pstgrp
    pstunit
    izlcstpr
    minus
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
      , input 'inv-obj':U
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
          , input 'inv-global':U
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
