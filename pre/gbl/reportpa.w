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
define variable vss-description as character no-undo init "Настройки для ОТЧЕТОВ" .
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
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
define buffer obj_thbj-attr for ub.thbj-attr.
define buffer glb_thbj-attr for ub.thbj-attr.
define buffer frm_thbj-attr for ub.thbj-attr.
define temp-table temp-thbj-attr no-undo like ub.thbj-attr.
define variable v-ttho     as handle no-undo .
define variable v-tthg    as handle no-undo .
define variable v-tthf    as handle no-undo .
define variable v-to-create as logical no-undo.
define variable v-to-create-report as logical no-undo.
define variable v-to-create-report-g as logical no-undo.
define variable v-to-create-report-f as logical no-undo.
define variable str-attr as character no-undo .
define temp-table thbjattr_thbj-attr-o no-undo like thbjattr_thbj-attr .
define temp-table thbjattr_thbj-attr-g no-undo like thbjattr_thbj-attr .
define temp-table thbjattr_thbj-attr-f no-undo like thbjattr_thbj-attr .
define variable v-obj-type  as character no-undo .
define variable v-obj-code as integer   no-undo .
define variable v-host-code as integer   no-undo .
define variable fl as character no-undo .
define variable v-onewin-point as character no-undo .
v-ttho = buffer thbjattr_thbj-attr-o:table-handle .
v-tthg = buffer thbjattr_thbj-attr-g:table-handle .
v-tthf = buffer thbjattr_thbj-attr-f:table-handle .
 if g#db-num <> 0 and p-obj-type = "" and  p-obj-code = 0
    then p-mode = 'ПРОСМОТР':U .
DEFINE BUTTON B-10
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE BUTTON B-11
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL ""
     SIZE 3 BY .79.
DEFINE BUTTON B-17
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE BUTTON B-alcgrpgd
     IMAGE-UP FILE "cmp/update.bmp":U
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
DEFINE BUTTON B-set_cplot
     IMAGE-UP FILE "cmp/update.bmp":U
     LABEL ""
     SIZE 2.63 BY 1.08.
DEFINE BUTTON B-set_rep-sort
     IMAGE-UP FILE "cmp/update.bmp":U
     LABEL ""
     SIZE 2.63 BY 1.08.
DEFINE BUTTON BUTTON-1
     IMAGE-UP FILE "adeicon\ts-up":U
     IMAGE-DOWN FILE "adeicon\ts-down":U
     IMAGE-INSENSITIVE FILE "adeicon\ts-up":U NO-FOCUS
     LABEL "&1.Параметры"
     SIZE 14 BY 1.13 TOOLTIP "Закладка №1".
DEFINE BUTTON BUTTON-2
     IMAGE-UP FILE "adeicon\ts-up":U
     IMAGE-DOWN FILE "adeicon\ts-down":U
     IMAGE-INSENSITIVE FILE "adeicon\ts-up":U NO-FOCUS
     LABEL "&2.Параметры"
     SIZE 14 BY 1.13 TOOLTIP "Закладка №2".
DEFINE VARIABLE rep-shift-format AS INTEGER FORMAT "->,>>>,>>9":U INITIAL 1
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEM-PAIRS "Стандарт",1,
                     "Форма 1",2,
                     "Форма 3",3
     DROP-DOWN-LIST
     SIZE 23 BY 1 NO-UNDO.
DEFINE VARIABLE cplot AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 45.38 BY 1
     FGCOLOR 4 FONT 4 NO-UNDO.
DEFINE VARIABLE rep-sort AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 45.38 BY 1
     FGCOLOR 4 FONT 4 NO-UNDO.
DEFINE VARIABLE sumvals AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 24.63 BY 1
     FONT 4 NO-UNDO.
DEFINE VARIABLE alcgrpgd AS INTEGER FORMAT ">>>>>>9":U INITIAL 0
     VIEW-AS FILL-IN NATIVE
     SIZE 10.63 BY 1 NO-UNDO.
DEFINE VARIABLE ardecldt AS DATE FORMAT "99/99/9999":U
     VIEW-AS FILL-IN
     SIZE 11 BY 1 NO-UNDO.
DEFINE VARIABLE F-button-1 AS CHARACTER FORMAT "X(256)":U INITIAL "№ &1."
      VIEW-AS TEXT
     SIZE 5 BY .67 TOOLTIP "Закладка №1" NO-UNDO.
DEFINE VARIABLE F-button-2 AS CHARACTER FORMAT "X(256)":U INITIAL "№ &2."
      VIEW-AS TEXT
     SIZE 4.75 BY .67 TOOLTIP "Закладка №2" NO-UNDO.
DEFINE VARIABLE FILL-IN-2 AS CHARACTER FORMAT "X(256)":U INITIAL "Диапозоны для ОТЧЕТА ~"Почасовой отчет по диапазонам сумм продаж~""
      VIEW-AS TEXT
     SIZE 65 BY .67
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE s-alcgrpgd AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 51.25 BY .67 NO-UNDO.
DEFINE VARIABLE sum-from AS DECIMAL FORMAT "->>>>>>>9.99":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 10 BY .79 NO-UNDO.
DEFINE VARIABLE sum-step AS DECIMAL FORMAT "->>,>>9.99":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 14 BY .79 NO-UNDO.
DEFINE VARIABLE sum-to AS DECIMAL FORMAT "->>>>>>>9.99":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 10 BY .79 NO-UNDO.
DEFINE VARIABLE v-actuate AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 70 BY .79 NO-UNDO.
DEFINE VARIABLE v-alcgrpgd AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 32.63 BY .79 NO-UNDO.
DEFINE VARIABLE v-ardecldt AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 47.75 BY .79 NO-UNDO.
DEFINE VARIABLE v-cdens AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 40 BY .79 NO-UNDO.
DEFINE VARIABLE v-cplot AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 48.25 BY .79 NO-UNDO.
DEFINE VARIABLE v-prt-z-no AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 42.63 BY .79 NO-UNDO.
DEFINE VARIABLE v-rep-sort AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 48.25 BY .79 NO-UNDO.
DEFINE VARIABLE v-shft-qty AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 41 BY .79 NO-UNDO.
DEFINE VARIABLE v-sum-from AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 12.63 BY .79 NO-UNDO.
DEFINE VARIABLE v-sum-step AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 5.63 BY .79 NO-UNDO.
DEFINE VARIABLE v-sum-to AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 12.63 BY .79 NO-UNDO.
DEFINE VARIABLE v-sumvals AS CHARACTER FORMAT "X(256)":U INITIAL "Список"
      VIEW-AS TEXT
     SIZE 6.63 BY 1 NO-UNDO.
DEFINE VARIABLE v-xl-delim AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 50.75 BY .79 NO-UNDO.
DEFINE VARIABLE xl-delim AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 3 BY 1 NO-UNDO.
DEFINE IMAGE I-actuate
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY .79.
DEFINE IMAGE I-alcgrpgd
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY .79.
DEFINE IMAGE I-ardecldt
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY .79.
DEFINE IMAGE I-cdens
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY .79.
DEFINE IMAGE I-cplot
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY .79.
DEFINE IMAGE I-prt-z-no
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY .79.
DEFINE IMAGE I-rep-excel
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY .79.
DEFINE IMAGE I-rep-sort
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY .79.
DEFINE IMAGE I-shft-qty
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY .79.
DEFINE IMAGE I-sum-from
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY .79.
DEFINE IMAGE I-sum-step
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY .79.
DEFINE IMAGE I-sum-to
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY .79.
DEFINE IMAGE I-sumvals
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY .79.
DEFINE IMAGE I-xl-delim
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY .79.
DEFINE VARIABLE cdens AS INTEGER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "По средней", 0,
"По чекам", 1
     SIZE 28 BY .79
     FONT 4 NO-UNDO.
DEFINE VARIABLE shft-qty AS CHARACTER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Расчетно-книжный остаток", "system",
"Фактический остаток", "state"
     SIZE 38 BY .79
     FONT 4 NO-UNDO.
DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL  GROUP-BOX
     SIZE 101 BY .25.
DEFINE VARIABLE actuate AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 72.63 BY .79 NO-UNDO.
DEFINE VARIABLE prt-z-no AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 45 BY .79 NO-UNDO.
DEFINE VARIABLE rep-excel AS LOGICAL INITIAL yes
     LABEL "Вывод отчетов в EXCEL"
     VIEW-AS TOGGLE-BOX
     SIZE 57.25 BY .83 NO-UNDO.
DEFINE VARIABLE rep-password AS LOGICAL INITIAL no
     LABEL "Excel для отчетов, защита от редактирования"
     VIEW-AS TOGGLE-BOX
     SIZE 57.25 BY .83 NO-UNDO.
DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     BUTTON-1 AT ROW 1 COL 34.63 WIDGET-ID 342
     B-quit AT ROW 1 COL 11
     B-Help AT ROW 1 COL 98
     BUTTON-2 AT ROW 1 COL 48.38 WIDGET-ID 344
     actuate AT ROW 2.25 COL 2.75 WIDGET-ID 268
     B-10 AT ROW 3 COL 2.75 WIDGET-ID 298
     prt-z-no AT ROW 3.08 COL 6 WIDGET-ID 300
     sum-from AT ROW 4.75 COL 15 COLON-ALIGNED NO-LABEL WIDGET-ID 272
     sum-step AT ROW 4.75 COL 34.63 COLON-ALIGNED NO-LABEL WIDGET-ID 288
     sum-to AT ROW 5.58 COL 17 NO-LABEL WIDGET-ID 270
     sumvals AT ROW 5.58 COL 36.63 NO-LABEL WIDGET-ID 284
     B-17 AT ROW 6.5 COL 2.75 WIDGET-ID 378
     xl-delim AT ROW 6.5 COL 4 COLON-ALIGNED NO-LABEL WIDGET-ID 386
     rep-sort AT ROW 7.5 COL 2.75 NO-LABEL WIDGET-ID 278
     B-set_rep-sort AT ROW 7.5 COL 49.63 WIDGET-ID 480
     ardecldt AT ROW 8.58 COL 2.75 NO-LABEL WIDGET-ID 274
     B-11 AT ROW 9.58 COL 2.75 WIDGET-ID 314
     shft-qty AT ROW 9.58 COL 47.63 NO-LABEL WIDGET-ID 308
     rep-shift-format AT ROW 10.58 COL 26.63 COLON-ALIGNED NO-LABEL WIDGET-ID 488
     rep-password AT ROW 11.75 COL 2.5 WIDGET-ID 368
     alcgrpgd AT ROW 12.83 COL 34.38 COLON-ALIGNED NO-LABEL WIDGET-ID 472
     B-alcgrpgd AT ROW 12.83 COL 47.25 WIDGET-ID 464
     cplot AT ROW 13.88 COL 2.75 NO-LABEL WIDGET-ID 478
     B-set_cplot AT ROW 13.88 COL 49 WIDGET-ID 476
     cdens AT ROW 15.25 COL 47 NO-LABEL WIDGET-ID 494
     rep-excel AT ROW 16.33 COL 2.25 WIDGET-ID 370
     F-button-1 AT ROW 1.25 COL 34 COLON-ALIGNED NO-LABEL WIDGET-ID 350
     F-button-2 AT ROW 1.25 COL 47.25 COLON-ALIGNED NO-LABEL WIDGET-ID 348
     v-actuate AT ROW 2.25 COL 5.63 NO-LABEL WIDGET-ID 122
     v-prt-z-no AT ROW 3.08 COL 9.38 NO-LABEL WIDGET-ID 304
     FILL-IN-2 AT ROW 4 COL 2 NO-LABEL WIDGET-ID 338
     v-sum-from AT ROW 4.75 COL 2.75 NO-LABEL WIDGET-ID 172
     v-sum-step AT ROW 4.75 COL 30 NO-LABEL WIDGET-ID 178
     v-sum-to AT ROW 5.58 COL 2.75 NO-LABEL WIDGET-ID 184
     v-sumvals AT ROW 5.58 COL 30 NO-LABEL WIDGET-ID 208
     v-xl-delim AT ROW 6.5 COL 10.25 NO-LABEL WIDGET-ID 384
     v-rep-sort AT ROW 7.5 COL 52.75 NO-LABEL WIDGET-ID 160
     v-ardecldt AT ROW 8.63 COL 14.75 NO-LABEL WIDGET-ID 132
     v-shft-qty AT ROW 9.58 COL 6 NO-LABEL WIDGET-ID 312
     v-alcgrpgd AT ROW 12.83 COL 2.75 NO-LABEL WIDGET-ID 470
     s-alcgrpgd AT ROW 13.04 COL 48.63 COLON-ALIGNED NO-LABEL WIDGET-ID 474
     v-cplot AT ROW 13.96 COL 52.25 NO-LABEL WIDGET-ID 484
     v-cdens AT ROW 15.25 COL 5 NO-LABEL WIDGET-ID 498
     "Форма сменного отчета:" VIEW-AS TEXT
          SIZE 23.63 BY .67 AT ROW 10.67 COL 2.75 WIDGET-ID 486
     I-actuate AT ROW 2.25 COL 1 WIDGET-ID 118
     I-ardecldt AT ROW 8.67 COL 1 WIDGET-ID 128
     I-rep-sort AT ROW 7.5 COL 1 WIDGET-ID 158
     I-sum-from AT ROW 4.75 COL 1 WIDGET-ID 168
     I-sum-step AT ROW 4.75 COL 27.63 WIDGET-ID 174
     I-sum-to AT ROW 5.58 COL 1 WIDGET-ID 180
     I-sumvals AT ROW 5.58 COL 27.63 WIDGET-ID 204
     I-prt-z-no AT ROW 3.08 COL 1 WIDGET-ID 302
     I-shft-qty AT ROW 9.58 COL 1 WIDGET-ID 306
     RECT-2 AT ROW 2 COL 1 WIDGET-ID 346
     I-xl-delim AT ROW 6.5 COL 1 WIDGET-ID 380
     I-alcgrpgd AT ROW 12.88 COL 1 WIDGET-ID 466
     I-cplot AT ROW 13.88 COL 1 WIDGET-ID 482
     I-cdens AT ROW 15.25 COL 1 WIDGET-ID 490
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         DEFAULT-BUTTON B-exit CANCEL-BUTTON B-quit WIDGET-ID 100.
DEFINE FRAME Dialog-Frame
     I-rep-excel AT ROW 11.75 COL 1 WIDGET-ID 500
     SPACE(98.24) SKIP(10.70)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Настройки для ОТЧЕТОВ"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON B-quit WIDGET-ID 100.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       cplot:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       v-actuate:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       v-alcgrpgd:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       v-ardecldt:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       v-cdens:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       v-cplot:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       v-prt-z-no:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       v-rep-sort:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       v-shft-qty:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       v-sum-from:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       v-sum-step:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       v-sum-to:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       v-sumvals:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       v-xl-delim:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ON GO OF FRAME Dialog-Frame
DO:
  run save-proc in this-procedure no-error.
  if error-status :error then return no-apply.
END.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF B-10 IN FRAME Dialog-Frame
DO:
  run gbl/v-taobj.w
      ('report-obj':U,
       "prt-z-no"
       ).
END.
ON CHOOSE OF B-11 IN FRAME Dialog-Frame
DO:
  run gbl/v-taobj.w
      ('report-obj':U,
       "shft-qty"
       ).
END.
ON CHOOSE OF B-17 IN FRAME Dialog-Frame
DO:
  run gbl/v-taobj.w
      ('report-firm':U,
       "xl-delim"
       ).
END.
ON CHOOSE OF B-alcgrpgd IN FRAME Dialog-Frame
DO:
define variable v-rid-list as character no-undo .
 if p-mode = 'ПРОСМОТР':U then return .
    run ref/gds-grp.w (
                  input parparentproc
                , input ('b-sel')
                , input v-cntxt-obj-type
                , input v-cntxt-obj-code
                , input-output v-rid-list) NO-ERROR.
 if error-status :error or v-rid-list = "" then return no-apply .
 define buffer buf_gds-grp for ub.gds-grp  .
 find first buf_gds-grp no-lock where recid(buf_gds-grp) = int(v-rid-list) no-error .
 if error-status :error then return no-apply .
 alcgrpgd   = buf_gds-grp.node-code .
 s-alcgrpgd = buf_gds-grp.node-name .
 DISPLAY alcgrpgd s-alcgrpgd  with FRAME Dialog-Frame.
END.
ON CHOOSE OF B-set_cplot IN FRAME Dialog-Frame
DO:
  RUN proc-set_cplot IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.
ON CHOOSE OF B-set_rep-sort IN FRAME Dialog-Frame
DO:
  RUN proc-set_rep-sort IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.
ON CHOOSE OF BUTTON-1 IN FRAME Dialog-Frame
DO:
    if fl = '' then do:
        .
    end.
    fl = ''  .
    DISPLAY I-actuate I-ardecldt I-rep-sort I-sum-from I-sum-step I-sum-to I-sumvals I-prt-z-no I-shft-qty I-xl-delim I-alcgrpgd I-cplot I-cdens I-rep-excel actuate B-10 prt-z-no sum-from sum-step sum-to sumvals B-17 xl-delim rep-sort B-set_rep-sort ardecldt B-11 shft-qty alcgrpgd B-alcgrpgd cplot B-set_cplot cdens v-actuate v-prt-z-no FILL-IN-2 v-sum-from v-sum-step v-sum-to v-sumvals v-xl-delim v-rep-sort v-ardecldt v-shft-qty v-alcgrpgd s-alcgrpgd v-cplot v-cdens with FRAME Dialog-Frame.
button-1:LOAD-IMAGE-UP("adeicon\ts-up":U)        in frame Dialog-Frame .
button-2:LOAD-IMAGE-Up("adeicon\ts-down":U)      in frame Dialog-Frame .
F-button-1:fgcolor = 1   .
f-button-2:fgcolor = ? .
END.
ON CHOOSE OF BUTTON-2 IN FRAME Dialog-Frame
DO:
    assign  FRAME Dialog-Frame rep-shift-format rep-excel rep-password .
    DISPLAY  with FRAME Dialog-Frame.
    HIDE I-actuate I-ardecldt I-rep-sort I-sum-from I-sum-step I-sum-to I-sumvals I-prt-z-no I-shft-qty I-xl-delim I-alcgrpgd I-cplot I-cdens I-rep-excel actuate B-10 prt-z-no sum-from sum-step sum-to sumvals B-17 xl-delim rep-sort B-set_rep-sort ardecldt B-11 shft-qty alcgrpgd B-alcgrpgd cplot B-set_cplot cdens v-actuate v-prt-z-no FILL-IN-2 v-sum-from v-sum-step v-sum-to v-sumvals v-xl-delim v-rep-sort v-ardecldt v-shft-qty v-alcgrpgd s-alcgrpgd v-cplot v-cdens IN FRAME Dialog-Frame.
    button-2:LOAD-IMAGE-UP("adeicon\ts-up":U)        in frame Dialog-Frame .
    button-1:LOAD-IMAGE-Up("adeicon\ts-down":U)      in frame Dialog-Frame .
    F-button-2:fgcolor = 1   .
    f-button-1:fgcolor = ? .
END.
ON MOUSE-SELECT-CLICK OF I-actuate IN FRAME Dialog-Frame
DO:
  MESSAGE I-actuate:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-alcgrpgd IN FRAME Dialog-Frame
DO:
  MESSAGE I-alcgrpgd:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-ardecldt IN FRAME Dialog-Frame
DO:
  MESSAGE I-ardecldt:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-cdens IN FRAME Dialog-Frame
DO:
  MESSAGE I-cdens:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-cplot IN FRAME Dialog-Frame
DO:
  MESSAGE I-cplot:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-prt-z-no IN FRAME Dialog-Frame
DO:
  MESSAGE I-prt-z-no:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-rep-excel IN FRAME Dialog-Frame
DO:
  MESSAGE I-rep-excel:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-rep-sort IN FRAME Dialog-Frame
DO:
  MESSAGE I-rep-sort:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-shft-qty IN FRAME Dialog-Frame
DO:
  MESSAGE I-shft-qty:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-sum-from IN FRAME Dialog-Frame
DO:
  MESSAGE I-sum-from:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-sum-step IN FRAME Dialog-Frame
DO:
  MESSAGE I-sum-step:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-sum-to IN FRAME Dialog-Frame
DO:
  MESSAGE I-sum-to:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-sumvals IN FRAME Dialog-Frame
DO:
  MESSAGE I-sumvals:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-xl-delim IN FRAME Dialog-Frame
DO:
  MESSAGE I-xl-delim:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON VALUE-CHANGED OF rep-excel IN FRAME Dialog-Frame
DO:
  assign rep-excel .
END.
ON VALUE-CHANGED OF rep-password IN FRAME Dialog-Frame
DO:
  assign rep-password .
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
on ' ' of ardecldt in frame Dialog-Frame
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
on delete-character of ardecldt in frame Dialog-Frame
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
on ctrl-d of ardecldt in frame Dialog-Frame
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
on ctrl-b of ardecldt in frame Dialog-Frame
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
on ctrl-e of ardecldt in frame Dialog-Frame
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
on ctrl-f of ardecldt in frame Dialog-Frame
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
  if ardecldt :POPUP-MENU in frame Dialog-Frame = ?
  then do:
    ASSIGN
      ardecldt :POPUP-MENU in frame Dialog-Frame = MENU m-ed-date8 :HANDLE
      ardecldt :MENU-MOUSE in frame Dialog-Frame = 3
    .
  end.
  define variable v-label-handle8 as handle no-undo .
  assign
    v-label-handle8 = ardecldt :side-label-handle in frame Dialog-Frame
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
    apply "ctrl-b":U to ardecldt in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date8-2 in menu m-ed-date8 DO:
    apply "ctrl-d":U to ardecldt in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date8-3 in menu m-ed-date8 DO:
    apply "ctrl-e":U to ardecldt in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date8-4 in menu m-ed-date8 DO:
    apply "ctrl-f":U to ardecldt in frame Dialog-Frame .
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
    fl = 'new' .
    apply  "CHOOSE":U   to  button-1 in frame Dialog-Frame .
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
run disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY actuate prt-z-no sum-from sum-step sum-to sumvals xl-delim rep-sort
          ardecldt shft-qty rep-shift-format rep-password alcgrpgd cplot cdens
          rep-excel F-button-1 F-button-2 v-actuate v-prt-z-no FILL-IN-2
          v-sum-from v-sum-step v-sum-to v-sumvals v-xl-delim v-rep-sort
          v-ardecldt v-shft-qty v-alcgrpgd s-alcgrpgd v-cplot v-cdens
      WITH FRAME Dialog-Frame.
  ENABLE B-exit BUTTON-1 B-quit B-Help I-actuate BUTTON-2 I-ardecldt I-rep-sort
         I-sum-from I-sum-step I-sum-to I-sumvals I-prt-z-no I-shft-qty RECT-2
         I-xl-delim I-alcgrpgd I-cplot I-cdens I-rep-excel actuate B-10
         prt-z-no sum-from sum-step sum-to sumvals B-17 xl-delim rep-sort
         B-set_rep-sort ardecldt B-11 shft-qty rep-shift-format
         B-alcgrpgd cplot B-set_cplot cdens F-button-1 F-button-2
         v-actuate v-prt-z-no FILL-IN-2 v-sum-from v-sum-step v-sum-to
         v-sumvals v-xl-delim v-rep-sort v-ardecldt v-shft-qty v-alcgrpgd
         v-cplot v-cdens
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
    , input 'report-glob':U
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
      , input 'report-firm':U
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
      , input 'report-obj':U
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
FOR EACH thbjattr_thbj-attr-g :
  case thbjattr_thbj-attr-g.prop-code :
when 'actuate':U THEN DO:     actuate = thbjattr_thbj-attr-g.property-value-logical.     actuate:private-data in frame Dialog-Frame = "recid3=" + string(recid(thbjattr_thbj-attr-g)).     display actuate with frame Dialog-Frame . END.
when 'ardecldt':U THEN DO:     ardecldt = thbjattr_thbj-attr-g.property-value-date.     ardecldt:private-data in frame Dialog-Frame = "recid3=" + string(recid(thbjattr_thbj-attr-g)).     display ardecldt with frame Dialog-Frame . END.
when 'rep-sort':U THEN DO:     rep-sort = thbjattr_thbj-attr-g.property-value-character.     rep-sort:private-data in frame Dialog-Frame = "recid3=" + string(recid(thbjattr_thbj-attr-g)).     display rep-sort with frame Dialog-Frame . END.
when 'sum-from':U THEN DO:     sum-from = thbjattr_thbj-attr-g.property-value-decimal.     sum-from:private-data in frame Dialog-Frame = "recid3=" + string(recid(thbjattr_thbj-attr-g)).     display sum-from with frame Dialog-Frame . END.
when 'sum-step':U THEN DO:     sum-step = thbjattr_thbj-attr-g.property-value-decimal.     sum-step:private-data in frame Dialog-Frame = "recid3=" + string(recid(thbjattr_thbj-attr-g)).     display sum-step with frame Dialog-Frame . END.
when 'sum-to':U THEN DO:     sum-to = thbjattr_thbj-attr-g.property-value-decimal.     sum-to:private-data in frame Dialog-Frame = "recid3=" + string(recid(thbjattr_thbj-attr-g)).     display sum-to with frame Dialog-Frame . END.
when 'sumvals':U THEN DO:     sumvals = thbjattr_thbj-attr-g.property-value-character.     sumvals:private-data in frame Dialog-Frame = "recid3=" + string(recid(thbjattr_thbj-attr-g)).     display sumvals with frame Dialog-Frame . END.
when 'alcgrpgd':U THEN DO:     alcgrpgd = thbjattr_thbj-attr-g.property-value-integer.     alcgrpgd:private-data in frame Dialog-Frame = "recid3=" + string(recid(thbjattr_thbj-attr-g)).     display alcgrpgd with frame Dialog-Frame . END.
when 'rep-shift-format':U THEN DO:     rep-shift-format = thbjattr_thbj-attr-g.property-value-integer.     rep-shift-format:private-data in frame Dialog-Frame = "recid3=" + string(recid(thbjattr_thbj-attr-g)).     display rep-shift-format with frame Dialog-Frame . END.
when 'cplot':U THEN DO:     cplot = thbjattr_thbj-attr-g.property-value-character.     cplot:private-data in frame Dialog-Frame = "recid3=" + string(recid(thbjattr_thbj-attr-g)).     display cplot with frame Dialog-Frame . END.
when 'cdens':U THEN DO:     cdens = thbjattr_thbj-attr-g.property-value-integer.     cdens:private-data in frame Dialog-Frame = "recid3=" + string(recid(thbjattr_thbj-attr-g)).     display cdens with frame Dialog-Frame . END.
when 'rep-excel':U THEN DO:     rep-excel = thbjattr_thbj-attr-g.property-value-logical.     rep-excel:private-data in frame Dialog-Frame = "recid3=" + string(recid(thbjattr_thbj-attr-g)).     display rep-excel with frame Dialog-Frame . END.
when 'rep-password':U THEN DO:     rep-password = thbjattr_thbj-attr-g.property-value-logical.     rep-password:private-data in frame Dialog-Frame = "recid3=" + string(recid(thbjattr_thbj-attr-g)).     display rep-password with frame Dialog-Frame . END.
    otherwise .
  end case .
  create temp-thbj-attr.
  buffer-copy thbjattr_thbj-attr-g to temp-thbj-attr.
end.
FOR EACH thbjattr_thbj-attr-o
:
IF thbjattr_thbj-attr-o.prop-code = 'prt-z-no':U THEN DO:     prt-z-no = thbjattr_thbj-attr-o.property-value-logical.     prt-z-no:private-data in frame Dialog-Frame = "recid2=" + string(recid(thbjattr_thbj-attr-o)).     display prt-z-no with frame Dialog-Frame . END.
IF thbjattr_thbj-attr-o.prop-code = 'shft-qty':U THEN DO:     shft-qty = thbjattr_thbj-attr-o.property-value-character.     shft-qty:private-data in frame Dialog-Frame = "recid2=" + string(recid(thbjattr_thbj-attr-o)).     display shft-qty with frame Dialog-Frame . END.
  create temp-thbj-attr.
  buffer-copy thbjattr_thbj-attr-o to temp-thbj-attr.
END.
FOR EACH thbjattr_thbj-attr-f
:
IF thbjattr_thbj-attr-f.prop-code = 'xl-delim':U THEN DO:     xl-delim = thbjattr_thbj-attr-f.property-value-character.     xl-delim:private-data in frame Dialog-Frame = "recid4=" + string(recid(thbjattr_thbj-attr-f)).     display xl-delim with frame Dialog-Frame . END.
  create temp-thbj-attr.
  buffer-copy thbjattr_thbj-attr-f to temp-thbj-attr.
end.
define variable v-tooltip as character no-undo .
define variable v-label   as character no-undo .
define variable v-tooltip-code as character no-undo .
run thbjattr_tooltip in this-procedure (    input   'report-obj':U   ,input  "prt-z-no"   ,output v-tooltip   ,output v-label   ,output v-tooltip-code   ) no-error . v-prt-z-no:screen-value = REPLACE ( entry(2,v-label,":") , "`" , "," ) .  v-prt-z-no = v-prt-z-no:screen-value .  I-prt-z-no:private-data = REPLACE ( v-tooltip-code , "`" , "," ) .
run thbjattr_tooltip in this-procedure (    input   'report-obj':U   ,input  "shft-qty"   ,output v-tooltip   ,output v-label   ,output v-tooltip-code   ) no-error . v-shft-qty:screen-value = REPLACE ( entry(2,v-label,":") , "`" , "," ) .  v-shft-qty = v-shft-qty:screen-value .  I-shft-qty:private-data = REPLACE ( v-tooltip-code , "`" , "," ) .
run thbjattr_tooltip in this-procedure (    input   'report-glob':U   ,input  "actuate"   ,output v-tooltip   ,output v-label   ,output v-tooltip-code   ) no-error . v-actuate:screen-value = REPLACE ( entry(2,v-label,":") , "`" , "," ) .  v-actuate = v-actuate:screen-value .  I-actuate:private-data = REPLACE ( v-tooltip-code , "`" , "," ) .
run thbjattr_tooltip in this-procedure (    input   'report-glob':U   ,input  "alcgrpgd"   ,output v-tooltip   ,output v-label   ,output v-tooltip-code   ) no-error . v-alcgrpgd:screen-value = REPLACE ( entry(2,v-label,":") , "`" , "," ) .  v-alcgrpgd = v-alcgrpgd:screen-value .  I-alcgrpgd:private-data = REPLACE ( v-tooltip-code , "`" , "," ) .
run thbjattr_tooltip in this-procedure (    input   'report-glob':U   ,input  "ardecldt"   ,output v-tooltip   ,output v-label   ,output v-tooltip-code   ) no-error . v-ardecldt:screen-value = REPLACE ( entry(2,v-label,":") , "`" , "," ) .  v-ardecldt = v-ardecldt:screen-value .  I-ardecldt:private-data = REPLACE ( v-tooltip-code , "`" , "," ) .
run thbjattr_tooltip in this-procedure (    input   'report-glob':U   ,input  "rep-sort"   ,output v-tooltip   ,output v-label   ,output v-tooltip-code   ) no-error . v-rep-sort:screen-value = REPLACE ( entry(2,v-label,":") , "`" , "," ) .  v-rep-sort = v-rep-sort:screen-value .  I-rep-sort:private-data = REPLACE ( v-tooltip-code , "`" , "," ) .
run thbjattr_tooltip in this-procedure (    input   'report-glob':U   ,input  "cplot"   ,output v-tooltip   ,output v-label   ,output v-tooltip-code   ) no-error . v-cplot:screen-value = REPLACE ( entry(2,v-label,":") , "`" , "," ) .  v-cplot = v-cplot:screen-value .  I-cplot:private-data = REPLACE ( v-tooltip-code , "`" , "," ) .
run thbjattr_tooltip in this-procedure (    input   'report-glob':U   ,input  "cdens"   ,output v-tooltip   ,output v-label   ,output v-tooltip-code   ) no-error . v-cdens:screen-value = REPLACE ( entry(2,v-label,":") , "`" , "," ) .  v-cdens = v-cdens:screen-value .  I-cdens:private-data = REPLACE ( v-tooltip-code , "`" , "," ) .
run thbjattr_tooltip in this-procedure (    input   'report-glob':U   ,input  "sum-from"   ,output v-tooltip   ,output v-label   ,output v-tooltip-code   ) no-error . v-sum-from:screen-value = REPLACE ( entry(2,v-label,":") , "`" , "," ) .  v-sum-from = v-sum-from:screen-value .  I-sum-from:private-data = REPLACE ( v-tooltip-code , "`" , "," ) .
run thbjattr_tooltip in this-procedure (    input   'report-glob':U   ,input  "sum-step"   ,output v-tooltip   ,output v-label   ,output v-tooltip-code   ) no-error . v-sum-step:screen-value = REPLACE ( entry(2,v-label,":") , "`" , "," ) .  v-sum-step = v-sum-step:screen-value .  I-sum-step:private-data = REPLACE ( v-tooltip-code , "`" , "," ) .
run thbjattr_tooltip in this-procedure (    input   'report-glob':U   ,input  "sum-to"   ,output v-tooltip   ,output v-label   ,output v-tooltip-code   ) no-error . v-sum-to:screen-value = REPLACE ( entry(2,v-label,":") , "`" , "," ) .  v-sum-to = v-sum-to:screen-value .  I-sum-to:private-data = REPLACE ( v-tooltip-code , "`" , "," ) .
run thbjattr_tooltip in this-procedure (    input   'report-glob':U   ,input  "sumvals"   ,output v-tooltip   ,output v-label   ,output v-tooltip-code   ) no-error . v-sumvals:screen-value = REPLACE ( entry(2,v-label,":") , "`" , "," ) .  v-sumvals = v-sumvals:screen-value .  I-sumvals:private-data = REPLACE ( v-tooltip-code , "`" , "," ) .
run thbjattr_tooltip in this-procedure (    input   'report-firm':U   ,input  "xl-delim"   ,output v-tooltip   ,output v-label   ,output v-tooltip-code   ) no-error . v-xl-delim:screen-value = REPLACE ( entry(2,v-label,":") , "`" , "," ) .  v-xl-delim = v-xl-delim:screen-value .  I-xl-delim:private-data = REPLACE ( v-tooltip-code , "`" , "," ) .
 define buffer buf_gds-grp for ub.gds-grp  .
 find first buf_gds-grp no-lock where buf_gds-grp.node-code = alcgrpgd no-error .
 if available buf_gds-grp then do:
 alcgrpgd   = buf_gds-grp.node-code .
 s-alcgrpgd = buf_gds-grp.node-name .
 DISPLAY alcgrpgd s-alcgrpgd  with FRAME Dialog-Frame.
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
    find first obj_thbj-attr exclusive-lock where
              obj_thbj-attr.obj-type = p-obj-type
        and   obj_thbj-attr.obj-code = p-obj-code
        and   obj_thbj-attr.upper-prop-code = 'report-obj':U
        and   obj_thbj-attr.prop-code = '':u no-wait no-error.
     if locked obj_thbj-attr then do:
        message
        vss-workfile vss-revision vss-description skip
        'report-obj':U skip
        "Запись ПАРАМЕТРОВ по объектам занята"
        view-as alert-box error .
        undo, return error.
      end.
    find first frm_thbj-attr exclusive-lock where
              frm_thbj-attr.obj-type = v-obj-type
        and   frm_thbj-attr.obj-code = v-obj-code
        and   frm_thbj-attr.upper-prop-code = 'report-firm':U
        and   frm_thbj-attr.prop-code = '':u no-wait no-error.
     if locked frm_thbj-attr then do:
        message
        vss-workfile vss-revision vss-description skip
        'report-obj':U skip
        "Запись ПАРАМЕТРОВ по фирмам занята"
        view-as alert-box error .
        undo, return error.
      end.
    find first glb_thbj-attr exclusive-lock where
              glb_thbj-attr.obj-type = ""
        and   glb_thbj-attr.obj-code = 0
        and   glb_thbj-attr.upper-prop-code = 'report-glob':U
        and   glb_thbj-attr.prop-code = '':u no-wait no-error.
     if locked glb_thbj-attr then do:
        message
        vss-workfile vss-revision vss-description skip
        'report-glob':U skip
        "Запись Глобальных ПАРАМЕТРОВ  занята"
        view-as alert-box error .
        undo, return error.
      end.
  end.
  else do:
    find first obj_thbj-attr no-lock where
          obj_thbj-attr.obj-type = p-obj-type
    and   obj_thbj-attr.obj-code = p-obj-code
    and   obj_thbj-attr.upper-prop-code = 'report-obj':U
    and   obj_thbj-attr.prop-code = '':u no-error.
    find first glb_thbj-attr no-lock where
          glb_thbj-attr.obj-type = ""
    and   glb_thbj-attr.obj-code = 0
    and   glb_thbj-attr.upper-prop-code = 'report-glob':U
    and   glb_thbj-attr.prop-code = '':u no-error.
    find first frm_thbj-attr no-lock where
          frm_thbj-attr.obj-type = v-obj-type
    and   frm_thbj-attr.obj-code = v-obj-code
    and   frm_thbj-attr.upper-prop-code = 'report-firm':U
    and   frm_thbj-attr.prop-code = '':u no-error.
  end.
  if not available obj_thbj-attr then do:
    assign
      v-to-create-report  = true
      .
    message
    substitute ("Внимание!!!&1Параметра obj НЕТ в БД!&1Будут показаны ЗНАЧЕНИЯ ПО УМОЛЧАНИЮ",
                chr(10))
                 view-as alert-box warning.
  end.
  if not available glb_thbj-attr then do:
    assign
      v-to-create-report-g  = true
      .
    message
    substitute ("Внимание!!!&1Гл.Параметра НЕТ в БД!&1Будут показаны ЗНАЧЕНИЯ ПО УМОЛЧАНИЮ",
                chr(10))
                 view-as alert-box warning.
  end.
  if not available frm_thbj-attr then do:
    assign
      v-to-create-report-f  = true
      .
    message
    substitute ("Внимание!!!&1 firm Параметра НЕТ в БД!&1Будут показаны ЗНАЧЕНИЯ ПО УМОЛЧАНИЮ",
                chr(10))
                 view-as alert-box warning.
  end.
  run fill-widgets in this-procedure no-error.
  if error-status:error then undo, return error.
  if p-mode <> 'ИЗМЕНЕНИЕ':U then do:
     disable
     rep-shift-format rep-excel rep-password
     with frame Dialog-Frame.
     B-exit:label = "Вы&ход"  .
     hide B-quit in frame Dialog-Frame .
  END.
    if not ( p-obj-type = "" and p-obj-code = 0 ) then do:
     disable
     actuate
     alcgrpgd
     ardecldt
     rep-sort
     sum-from
     sum-step
     sum-to
     sumvals
     cplot
     rep-shift-format
     cdens
     with frame Dialog-Frame.
     hide rep-excel rep-password I-rep-excel in frame Dialog-Frame .
  end.
  if not ( p-obj-type = 'орг':U or  ( p-obj-type = "" and p-obj-code = 0 ) ) then do:
     disable
     xl-delim
     with frame Dialog-Frame.
  end.
  if p-type = 'glob' then
  enable
  rep-sort
  cplot
  rep-shift-format
  cdens
  rep-excel
  rep-password
  with frame Dialog-Frame .
end procedure.
PROCEDURE init-tt :
    v-obj-type = p-obj-type .
    v-obj-code = p-obj-code .
    if p-obj-type <> 'орг':U  and p-obj-type <> "" then  do:
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  )  .
        v-obj-type = 'орг':U      .
        v-obj-code = v-host-code .
    end.
END PROCEDURE.
PROCEDURE onewin_custom-add-item :
DEFINE INPUT PARAMETER p-onewin-handle AS HANDLE NO-UNDO.
DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
define variable v-ii as integer no-undo .
define variable v-is-petrolium as logical no-undo .
define variable v-is-pieces as logical no-undo .
define variable v-b-code as integer no-undo .
define variable v-exists as logical no-undo .
DEFINE BUFFER buf_cash-pay FOR ub.cash-pay.
define buffer buf_goods for ub.goods.
define buffer buf_temp_onewin_items for temp_onewin_items.
case v-onewin-point :
  when 'cplot':U then do:
    run ref/cashpays.w (
                   input parparentproc
                  ,input "b-mark,b-sel":U
                  ,input 'все':U
                  ,input 0
                  ,input ''
                  ,input 0
                  ,output v-rid-list) no-error.
    IF NOT ERROR-STATUS:ERROR
    AND v-rid-list <> '' THEN DO:
      _ii:
      do v-ii = 1 to num-entries(v-rid-list):
        FIND FIRST buf_cash-pay NO-LOCK WHERE
                  RECID(buf_cash-pay) = INTEGER(entry(v-ii, v-rid-list)) NO-ERROR.
        IF AVAILABLE buf_cash-pay THEN DO:
          if buf_cash-pay.curr-code <> 0 then do:
            message
            substitute("Нельзя добавить тип кассового платежа с валютой, отличной от национальной&1"  +
                      "Игнорируем выбор платежа &2 (код &3 валюта &4)"
                      , chr(10)
                      , buf_cash-pay.obj-name
                      , buf_cash-pay.cdpay-code
                      , buf_cash-pay.curr-code
                      )
            view-as alert-box warning .
            next _ii.
          end.
          find first buf_temp_onewin_items where
                  buf_temp_onewin_items.itmextkey = string(buf_cash-pay.cdpay-code) no-error.
          if not available temp_onewin_items then do:
            run onewin_check-item in p-onewin-handle (
                                                       input string(buf_cash-pay.cdpay-code)
                                                      ,output v-exists) no-error.
            if v-exists then do:
              message
              "Вы уже выбрали этот тип кассового платежа!"
              view-as alert-box warning.
              return.
            end.
            run onewin_add-item in p-onewin-handle (
                  input string(buf_cash-pay.cdpay-code)
                , input substitute("&1-&2"
                                  , string(buf_cash-pay.cdpay-code, ">>>>9")
                                  , buf_cash-pay.obj-name
                                  )
                , ''
                , input yes
            ).
          end.
          else do:
            message
            "Вы уже выбрали этот тип кассового платежа!"
            view-as alert-box warning.
            return.
          end.
        END.
      end.
    END.
  end.
  when 'rep-sort':U then do:
    run ref/gds-ref.p ( input parparentproc
                      , input "b-sel,b-mark"
                      , input 'текущие':U
                      , input 'все':U
                      , input ?
                      , input ?
                      , input ?
                      , input ?
                      , input ?
                      , input ?
                      , input ?
                      , input ?
                      , output v-rid-list
                      ) no-error.
    IF NOT ERROR-STATUS:ERROR
    AND v-rid-list <> '' THEN DO:
      _ii:
      do v-ii = 1 to num-entries(v-rid-list):
        FIND FIRST buf_goods NO-LOCK WHERE
                  RECID(buf_goods) = INTEGER(entry(v-ii, v-rid-list)) NO-ERROR.
        IF AVAILABLE buf_goods THEN DO:
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_is-petrl in g#lib-trn
  (
     input buf_goods.artic
  ,  input buf_goods.prod-type
  ,  input buf_goods.prod-code
  , output v-is-petrolium
  , output v-is-pieces
  ) no-error.
          if error-status:error
          or not v-is-petrolium
          or v-is-pieces then do:
            message
            substitute("Нельзя добавить товар с кодом &1 &2"  +
                      "Он не является весовым топливом&2" +
                      "Игнорируем выбор товара"
                      , buf_goods.gds-code
                      , chr(10)
                      )
            view-as alert-box warning .
            next _II.
          end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  buf_goods.gds-code
  ,input  ?
  ,output v-b-code
  ) no-error .
          if not error-status:error then do:
            find first buf_temp_onewin_items where
                    buf_temp_onewin_items.itmextkey = string(buf_goods.gds-code) no-error.
            if not available temp_onewin_items then do:
              run onewin_check-item in p-onewin-handle (
                                                        input string(buf_goods.gds-code)
                                                        ,output v-exists) no-error.
              if v-exists then do:
                message
                "Вы уже выбрали этот товар!"
                view-as alert-box warning.
                return.
              end.
              run onewin_add-item in p-onewin-handle (
                    input string(buf_goods.gds-code)
                  , input substitute("&1-&2"
                                    , string(buf_goods.gds-code)
                                    , buf_goods.gds-name
                                    )
                  , ''
                  , input yes
              ).
            end.
            else do:
              message
              "Вы уже выбрали этот товар!"
              view-as alert-box warning.
              return.
            end.
          end.
        end.
      END.
    end.
  end.
end case.
END PROCEDURE.
PROCEDURE onewin_get-bttns :
DEFINE OUTPUT PARAMETER p-bttns as character no-undo .
if p-mode = 'ПРОСМОТР':U or not p-type = 'glob'  then do:
  p-bttns = "".
end.
else do:
  p-bttns = "b-add,b-del,b-up,b-down,b-exit".
end.
END PROCEDURE.
PROCEDURE proc-set_cplot :
DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-ii AS integer NO-UNDO.
DEFINE VARIABLE v-local-cplot AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-cur-ext-key AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-accepted AS logical NO-UNDO.
DEFINE BUFFER buf_cash-pay FOR ub.cash-pay.
define buffer buf_temp_onewin_items for temp_onewin_items.
define buffer buf_temp_onewin_itemsSelected for temp_onewin_itemsSelected.
run onewin_clear in this-procedure.
_ii:
DO v-ii = 1 TO NUM-ENTRIES(cplot):
  FIND FIRST buf_cash-pay NO-LOCK WHERE
            buf_cash-pay.cdpay-code = INTEGER(ENTRY(v-ii, cplot) )
       AND buf_cash-pay.curr-code = 0 NO-ERROR.
  IF AVAILABLE buf_cash-pay THEN DO:
        run onewin_add-item in this-procedure (
              input string(buf_cash-pay.cdpay-code)
            , input substitute("&1-&2"
                               , string(buf_cash-pay.cdpay-code, ">>>>9")
                               , buf_cash-pay.obj-name
                               )
            , ''
            , input yes
        ).
  END.
END.
v-onewin-point = 'cplot':U.
run gbl/onewin.w (
      input parparentproc
    , input 1
    , input v-cplot
    , input "":U
    , input "&Тест"
    , input table temp_onewin_items
    , output table temp_onewin_itemsSelected
    , output v-cur-ext-key
    , output v-accepted
).
IF v-accepted THEN DO:
  FOR EACH buf_temp_onewin_itemsSelected:
    FIND FIRST buf_cash-pay NO-LOCK WHERE
              buf_cash-pay.cdpay-code = integer(buf_temp_onewin_itemsSelected.itmextkey)
        AND    buf_cash-pay.curr-code = 0
        NO-ERROR.
    IF AVAILABLE buf_cash-pay THEN DO:
      v-local-cplot = v-local-cplot + (IF v-local-cplot = '' THEN '' ELSE chr(44)) +
                      STRING(buf_cash-pay.cdpay-code).
    END.
  END.
  ASSIGN
  cplot = v-local-cplot.
  cplot:SCREEN-VALUE IN FRAME Dialog-Frame = v-local-cplot.
END.
END PROCEDURE.
PROCEDURE proc-set_rep-sort :
define variable v-ii as integer no-undo .
define variable v-rid-list as character no-undo .
define variable v-local_rep-sort as character no-undo .
define variable v-b-code as integer no-undo .
DEFINE VARIABLE v-cur-ext-key AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-accepted AS logical NO-UNDO.
define buffer buf_temp_onewin_items for temp_onewin_items.
define buffer buf_temp_onewin_itemsSelected for temp_onewin_itemsSelected.
run onewin_clear in this-procedure.
define buffer buf_goods for ub.goods.
define buffer buf_bar-code for ub.bar-code.
do v-ii = 1 to num-entries(rep-sort):
  find first buf_goods no-lock where
          buf_goods.gds-code = integer(entry(v-ii, rep-sort)) no-error.
  if available buf_goods then do:
  run onewin_add-item in this-procedure (
        input string(buf_goods.gds-code)
      , input substitute("&1 - &2"
                          ,buf_goods.gds-code
                          ,buf_goods.gds-name)
      , ''
      , input yes
  ).
  end.
end.
v-onewin-point = 'rep-sort':U.
run gbl/onewin.w (
      input parparentproc
    , input 1
    , input v-rep-sort
    , input "":U
    , input "&Тест"
    , input table temp_onewin_items
    , output table temp_onewin_itemsSelected
    , output v-cur-ext-key
    , output v-accepted
).
IF v-accepted THEN DO:
  FOR EACH buf_temp_onewin_itemsSelected:
    find first buf_goods no-lock where
              buf_goods.gds-code = integer(buf_temp_onewin_itemsSelected.itmextkey) no-error.
    if available buf_goods then do:
      assign
      v-local_rep-sort = v-local_rep-sort +
                          (if v-local_rep-sort = '' then '' else chr(44)) +
                          trim(string(buf_goods.gds-code)).
    end.
  end.
  assign
  rep-sort = v-local_rep-sort.
  rep-sort:screen-value in frame Dialog-Frame = v-local_rep-sort.
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
define variable vss-include-info11 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  ibs.th.gbl.gbl-var:g#db-num
    ,input  ibs.th.gbl.gbl-var:g#userid
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
    actuate FRAME Dialog-Frame
    alcgrpgd
    ardecldt
    rep-sort
    sum-from
    sum-step
    sum-to
    sumvals
    prt-z-no
    shft-qty
    cplot
    rep-shift-format
    rep-excel
    rep-password
    cdens
 .
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
      , input 'report-obj':U
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
          , input 'report-firm':U
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
          , input 'report-glob':U
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
