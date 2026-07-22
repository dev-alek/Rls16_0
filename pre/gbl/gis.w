define input parameter parparentproc as widget-handle no-undo.
define input parameter p-mode     as character no-undo.
define input parameter p-obj-type like ub.clients.obj-type no-undo.
define input parameter p-obj-code like ub.clients.obj-code no-undo.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-Workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Редактирование секции Настройки для подключения к ГИС МТ и проверки КМ" .
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
define variable vss-include-info2 as character format "X(65)" no-undo
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
define variable v-onewin2-itm-key    as integer      no-undo.
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
      v-onewin2-itm-key = buf_temp_onewin_items.itm-key.
    end.
    else do:
      v-onewin2-itm-key = 0.
    end.
    assign
        v-onewin2-itm-key = v-onewin2-itm-key + 1
    .
    create buf_temp_onewin_items.
    assign
    buf_temp_onewin_items.itm-key      = v-onewin2-itm-key
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEFINE new shared TEMP-TABLE thbjattr-list no-undo like ub.thbj-attr .
define temp-table temp-thbj-attr no-undo like ub.thbj-attr.
define temp-table x_thbj-attr no-undo like ub.thbj-attr.
define variable v-tth     as handle no-undo .
define variable v-tth-host as handle no-undo .
define variable v-to-create-host as logical no-undo.
define variable str-attr as character no-undo .
assign
v-tth      = buffer temp-thbj-attr:table-handle .
DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1.
DEFINE BUTTON B-Help
     LABEL "&Help"
     SIZE 10 BY 1.
DEFINE BUTTON B-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1.
DEFINE VARIABLE AgeConfirmBox AS CHARACTER FORMAT "X(256)":U
     LABEL "Проверка возраста при продаже НП"
     VIEW-AS COMBO-BOX INNER-LINES 3
     LIST-ITEMS "Проверка отключена","Проверка при помощи соглашения оферты","Проверка при помощи MAX"
     DROP-DOWN-LIST
     SIZE 40 BY 1 NO-UNDO.
DEFINE VARIABLE Resp_TH_required AS CHARACTER FORMAT "X(256)":U INITIAL "Да"
     LABEL "Обязательность получения результатов проверки КМ в ТН"
     VIEW-AS COMBO-BOX INNER-LINES 2
     LIST-ITEMS "Да","Нет"
     DROP-DOWN-LIST
     SIZE 8 BY 1 NO-UNDO.
DEFINE VARIABLE addTimeoutPIoT AS DECIMAL FORMAT "->>,>>9.99":U INITIAL 1
     LABEL "Длительность обработки ответа ГИС МТ в ТС ПИоТ (секунды)"
     VIEW-AS FILL-IN
     SIZE 8 BY 1 NO-UNDO.
DEFINE VARIABLE adressPort AS CHARACTER FORMAT "X(256)":U
     LABEL "Адрес и порт"
     VIEW-AS FILL-IN
     SIZE 71 BY 1 NO-UNDO.
DEFINE VARIABLE AgeConfirm AS INTEGER FORMAT ">9":U INITIAL 0.
DEFINE VARIABLE banDate AS INTEGER FORMAT "->,>>>,>>9":U INITIAL 5
     LABEL "Опережение срабатывания запрета по сроку годности в минутах"
     VIEW-AS FILL-IN
     SIZE 8 BY 1 NO-UNDO.
DEFINE VARIABLE cdnAdress AS CHARACTER FORMAT "X(256)":U
     LABEL "Адрес cdn"
     VIEW-AS FILL-IN
     SIZE 72 BY 1 NO-UNDO.
DEFINE VARIABLE cdnTimeUpdate AS INTEGER FORMAT "->,>>>,>>9":U INITIAL 24
     LABEL "Период обновления списка CDN-площадок (часы)"
     VIEW-AS FILL-IN
     SIZE 8 BY 1 NO-UNDO.
DEFINE VARIABLE dopParam AS CHARACTER FORMAT "X(256)":U
     LABEL "Дополнительные параметры запроса"
     VIEW-AS FILL-IN
     SIZE 51 BY 1 NO-UNDO.
DEFINE VARIABLE gisAdress AS CHARACTER FORMAT "X(256)":U
     LABEL "Адрес ГИС МТ"
     VIEW-AS FILL-IN
     SIZE 72 BY 1 NO-UNDO.
DEFINE VARIABLE LMCHzPort AS CHARACTER FORMAT "X(256)":U
     LABEL "Порт ЛМ ЧЗ"
     VIEW-AS FILL-IN
     SIZE 8 BY 1 NO-UNDO.
DEFINE VARIABLE login AS CHARACTER FORMAT "X(256)":U
     LABEL "Логин"
     VIEW-AS FILL-IN
     SIZE 27 BY 1 NO-UNDO.
DEFINE VARIABLE MACC_IP AS CHARACTER FORMAT "X(256)":U
     LABEL "IP адрес ТН"
     VIEW-AS FILL-IN
     SIZE 27 BY 1 NO-UNDO.
DEFINE VARIABLE MACC_PORT AS CHARACTER FORMAT "X(256)":U
     LABEL "Порт проверки КМ в ТН"
     VIEW-AS FILL-IN
     SIZE 8 BY 1 NO-UNDO.
DEFINE VARIABLE MACC_Timeout AS DECIMAL FORMAT ">,>>>,>>9.99":U INITIAL 0
     LABEL "Длительность ожидания ответа ТН (секунды)"
     VIEW-AS FILL-IN
     SIZE 8 BY 1 NO-UNDO.
DEFINE VARIABLE MaxApiToken AS CHARACTER FORMAT "X(256)":U
     LABEL "Токен авторизации MAX"
     VIEW-AS FILL-IN
     SIZE 40 BY 1 NO-UNDO.
DEFINE VARIABLE maxTime AS INTEGER FORMAT ">,>>>,>>9":U INITIAL 72
     LABEL "Макс. допустимое время разрешения продажи при сбое онлайн проверки (часы)"
     VIEW-AS FILL-IN
     SIZE 8 BY 1 NO-UNDO.
DEFINE VARIABLE OflineAdress AS CHARACTER FORMAT "X(256)":U
     LABEL "Адрес ЛМ ЧЗ"
     VIEW-AS FILL-IN
     SIZE 71 BY 1 NO-UNDO.
DEFINE VARIABLE OflineLogin AS CHARACTER FORMAT "X(256)":U
     LABEL "Логин в ЛМ ЧЗ"
     VIEW-AS FILL-IN
     SIZE 15 BY 1 NO-UNDO.
DEFINE VARIABLE OflinePswd AS CHARACTER FORMAT "X(256)":U
     LABEL "Пароль"
     VIEW-AS FILL-IN
     SIZE 46 BY 1 NO-UNDO.
DEFINE VARIABLE password AS CHARACTER FORMAT "X(256)":U
     LABEL "Пароль"
     VIEW-AS FILL-IN
     SIZE 34 BY 1 NO-UNDO.
DEFINE VARIABLE Proxytext AS CHARACTER FORMAT "x(13)" INITIAL "Прокси-сервер"
      VIEW-AS TEXT
     SIZE 17 BY .67.
DEFINE VARIABLE registrationKey AS CHARACTER FORMAT "X(256)":U
     LABEL "Ключ авторизации"
     VIEW-AS FILL-IN
     SIZE 72 BY 1 NO-UNDO.
DEFINE VARIABLE timeFalStart AS INTEGER FORMAT "->,>>>,>>9":U INITIAL 2
     LABEL "Время с момента сбоя до начала уведомления персонала (часы)"
     VIEW-AS FILL-IN
     SIZE 8 BY 1 NO-UNDO.
DEFINE VARIABLE TxtCopy AS CHARACTER FORMAT "X(256)":U INITIAL "Копир."
      VIEW-AS TEXT
     SIZE 7 BY .63 NO-UNDO.
DEFINE VARIABLE TxtCopy-2 AS CHARACTER FORMAT "X(256)":U INITIAL "в ЛС"
      VIEW-AS TEXT
     SIZE 5 BY .63 NO-UNDO.
DEFINE VARIABLE waitTime AS DECIMAL FORMAT "->>,>>9.99":U INITIAL 1.5
     LABEL "Длительность ожидания ответа ГИС МТ (секунды)"
     VIEW-AS FILL-IN
     SIZE 8 BY 1 NO-UNDO.
DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 108.5 BY 30.04.
DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 93 BY 3.08.
DEFINE RECTANGLE RECT-3
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 9 BY 29.33.
DEFINE VARIABLE cdnChange AS LOGICAL INITIAL no
     LABEL "Смена площадки"
     VIEW-AS TOGGLE-BOX
     SIZE 23 BY .79 NO-UNDO.
DEFINE VARIABLE cdnRepeat AS LOGICAL INITIAL no
     LABEL "Повторный опрос площадки"
     VIEW-AS TOGGLE-BOX
     SIZE 33 BY .79 NO-UNDO.
DEFINE VARIABLE cdnTurnOn AS LOGICAL INITIAL no
     LABEL "Работа с cdn-площадками"
     VIEW-AS TOGGLE-BOX
     SIZE 32 BY .79 NO-UNDO.
DEFINE VARIABLE Copy-addTimeoutPIoT AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 4 BY .79 NO-UNDO.
DEFINE VARIABLE Copy-adressPort AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 3 BY .79 NO-UNDO.
DEFINE VARIABLE Copy-AgeConfirm AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 4 BY .79 NO-UNDO.
DEFINE VARIABLE Copy-cdnAdress AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 4 BY .79 NO-UNDO.
DEFINE VARIABLE Copy-dopParam AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 4 BY .79 NO-UNDO.
DEFINE VARIABLE Copy-LMCHzPort AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 4 BY .79 NO-UNDO.
DEFINE VARIABLE Copy-LogPass AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 3 BY .79 NO-UNDO.
DEFINE VARIABLE Copy-MaxApiToken AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 4 BY .79 NO-UNDO.
DEFINE VARIABLE Copy-OflineAdress AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 4 BY .79 NO-UNDO.
DEFINE VARIABLE Copy-registrationKey AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 4 BY .79 NO-UNDO.
DEFINE VARIABLE Copy-Resp AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 4 BY .79 NO-UNDO.
DEFINE VARIABLE Copy-THport AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 4 BY .79 NO-UNDO.
DEFINE VARIABLE Copy-Timeout AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 4 BY .79 NO-UNDO.
DEFINE VARIABLE Copy-waitTime AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 4 BY .79 NO-UNDO.
DEFINE VARIABLE crashSituat AS LOGICAL INITIAL no
     LABEL "Аварийная ситуация в ГИС МТ"
     VIEW-AS TOGGLE-BOX
     SIZE 35 BY .79 NO-UNDO.
DEFINE VARIABLE UpdateRequest AS LOGICAL INITIAL no
     LABEL "Обновление параметров при запросе КМ"
     VIEW-AS TOGGLE-BOX
     SIZE 47 BY .79 NO-UNDO.
DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     B-quit AT ROW 1 COL 11
     B-Help AT ROW 1 COL 92
     gisAdress AT ROW 2.42 COL 21 COLON-ALIGNED WIDGET-ID 118
     cdnTurnOn AT ROW 3.63 COL 23 WIDGET-ID 174
     cdnAdress AT ROW 4.58 COL 21 COLON-ALIGNED WIDGET-ID 118
     Copy-cdnAdress AT ROW 4.58 COL 97 HELP
          "Наследовать изменения на все секции" WIDGET-ID 192
     registrationKey AT ROW 5.75 COL 21 COLON-ALIGNED WIDGET-ID 142
     Copy-registrationKey AT ROW 5.75 COL 97 HELP
          "Наследовать изменения на все секции" WIDGET-ID 194
     adressPort AT ROW 7.79 COL 22 COLON-ALIGNED WIDGET-ID 144
     Copy-adressPort AT ROW 7.92 COL 97 HELP
          "Наследовать изменения на все секции" WIDGET-ID 196
     login AT ROW 9 COL 22 COLON-ALIGNED WIDGET-ID 146
     password AT ROW 9 COL 94 RIGHT-ALIGNED WIDGET-ID 148 PASSWORD-FIELD
     Copy-LogPass AT ROW 9.08 COL 97 HELP
          "Наследовать изменения на все секции" WIDGET-ID 198
     dopParam AT ROW 10.75 COL 42 COLON-ALIGNED WIDGET-ID 154
     Copy-dopParam AT ROW 10.88 COL 97 HELP
          "Наследовать изменения на все секции" WIDGET-ID 200
     OflineAdress AT ROW 11.96 COL 22 COLON-ALIGNED WIDGET-ID 180
     Copy-OflineAdress AT ROW 12.04 COL 97 HELP
          "Наследовать изменения на все секции" WIDGET-ID 202
     OflineLogin AT ROW 13.13 COL 22 COLON-ALIGNED WIDGET-ID 182
     OflinePswd AT ROW 13.13 COL 94 RIGHT-ALIGNED WIDGET-ID 184
     waitTime AT ROW 14.58 COL 94 RIGHT-ALIGNED WIDGET-ID 156
     Copy-waitTime AT ROW 14.67 COL 97 HELP
          "Наследовать изменения на все секции" WIDGET-ID 206
     Resp_TH_required AT ROW 15.75 COL 94 RIGHT-ALIGNED WIDGET-ID 212
     Copy-Resp AT ROW 15.88 COL 97 HELP
          "Наследовать изменения на все секции" WIDGET-ID 208
     MACC_Timeout AT ROW 16.96 COL 94 RIGHT-ALIGNED WIDGET-ID 186
     Copy-Timeout AT ROW 16.96 COL 97 HELP
          "Наследовать изменения на все секции" WIDGET-ID 210
     maxTime AT ROW 18.13 COL 94 RIGHT-ALIGNED WIDGET-ID 168
     timeFalStart AT ROW 19.33 COL 94 RIGHT-ALIGNED WIDGET-ID 170
     banDate AT ROW 20.5 COL 94 RIGHT-ALIGNED WIDGET-ID 172
     cdnTimeUpdate AT ROW 21.71 COL 94 RIGHT-ALIGNED WIDGET-ID 168
     MACC_IP AT ROW 22.92 COL 22 COLON-ALIGNED WIDGET-ID 214
     MACC_PORT AT ROW 22.92 COL 85 COLON-ALIGNED WIDGET-ID 216
     Copy-THport AT ROW 22.92 COL 97 HELP
          "Наследовать изменения на все секции" WIDGET-ID 226
     LMCHzPort AT ROW 24.08 COL 85 COLON-ALIGNED WIDGET-ID 224
     Copy-LMCHzPort AT ROW 24.08 COL 97 HELP
          "Наследовать изменения на все секции" WIDGET-ID 228
     addTimeoutPIoT AT ROW 25.29 COL 94 RIGHT-ALIGNED WIDGET-ID 230
     Copy-addTimeoutPIoT AT ROW 25.29 COL 97 HELP
          "Наследовать изменения на все секции" WIDGET-ID 232
     UpdateRequest AT ROW 26.71 COL 11 HELP
          "Обновление параметров при запросе КМ" WIDGET-ID 176
     crashSituat AT ROW 26.71 COL 59 WIDGET-ID 174
     cdnChange AT ROW 27.67 COL 11 WIDGET-ID 174
     cdnRepeat AT ROW 27.67 COL 59 WIDGET-ID 174
     MaxApiToken AT ROW 29 COL 94 RIGHT-ALIGNED WIDGET-ID 234
     Copy-MaxApiToken AT ROW 29 COL 97 HELP
          "Наследовать изменения на все секции" WIDGET-ID 240
     AgeConfirmBox AT ROW 30.25 COL 94 RIGHT-ALIGNED WIDGET-ID 242
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         DEFAULT-BUTTON B-exit CANCEL-BUTTON B-quit WIDGET-ID 100.
DEFINE FRAME Dialog-Frame
     Copy-AgeConfirm AT ROW 30.25 COL 97 HELP
          "Наследовать изменения на все секции" WIDGET-ID 236
     TxtCopy AT ROW 2.67 COL 95 COLON-ALIGNED NO-LABEL WIDGET-ID 220
     TxtCopy-2 AT ROW 3.38 COL 95 COLON-ALIGNED NO-LABEL WIDGET-ID 222
     Proxytext AT ROW 6.96 COL 39 COLON-ALIGNED NO-LABEL WIDGET-ID 152
     RECT-1 AT ROW 2.21 COL 1.5 WIDGET-ID 116
     RECT-2 AT ROW 7.21 COL 3 WIDGET-ID 150
     RECT-3 AT ROW 2.42 COL 96 WIDGET-ID 218
     SPACE(5.00) SKIP(0.60)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Настройки для подключения к ГИС МТ и проверки КМ"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON B-quit WIDGET-ID 100.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON GO OF FRAME Dialog-Frame
DO:
  run save-proc in this-procedure no-error.
  if error-status :error then return no-apply.
END.
ON VALUE-CHANGED OF cdnTurnOn IN FRAME Dialog-Frame
DO:
    ASSIGN cdnTurnOn.
    if cdnTurnOn then do:
       disable gisAdress with frame Dialog-Frame .
       enable cdnAdress with frame Dialog-Frame .
   end.
   else do:
       enable gisAdress with frame Dialog-Frame .
       disable cdnAdress with frame Dialog-Frame .
   end.
END.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON ENTRY OF OflinePswd IN FRAME Dialog-Frame
DO:
   self:SET-SELECTION(1,length (OflinePswd:screen-value) + 1).
END.
ON ENTRY OF MaxApiToken IN FRAME Dialog-Frame
DO:
   self:SET-SELECTION(1,length (MaxApiToken:screen-value) + 1).
END.
ON VALUE-CHANGED OF AgeConfirmBox IN FRAME Dialog-Frame
DO:
   assign AgeConfirmBox.
   AgeConfirm = lookup(AgeConfirmBox, AgeConfirmBox:LIST-ITEMS,",") - 1.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
    RUN init-tt.
    RUN enable_UI.
    RUN fill-widgets.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  if p-obj-type = "" and p-obj-code = 0
  then do:
      DISPLAY gisAdress cdnTurnOn cdnAdress Copy-cdnAdress registrationKey
            Copy-registrationKey adressPort Copy-adressPort login password
            Copy-LogPass dopParam Copy-dopParam OflineAdress Copy-OflineAdress
            OflineLogin waitTime Copy-waitTime
            Resp_TH_required Copy-Resp MACC_Timeout Copy-Timeout maxTime
            timeFalStart banDate cdnTimeUpdate MACC_PORT Copy-THport
            LMCHzPort Copy-LMCHzPort addTimeoutPIoT Copy-addTimeoutPIoT
            UpdateRequest crashSituat cdnChange cdnRepeat
            TxtCopy TxtCopy-2 Proxytext MaxApiToken Copy-MaxApiToken
            AgeConfirmBox Copy-AgeConfirm
      WITH FRAME Dialog-Frame.
      ENABLE B-exit RECT-1 RECT-2 RECT-3 B-quit B-Help gisAdress cdnTurnOn
             cdnAdress Copy-cdnAdress registrationKey Copy-registrationKey
             adressPort Copy-adressPort login password Copy-LogPass dopParam
             Copy-dopParam OflineAdress Copy-OflineAdress OflineLogin OflinePswd
             waitTime Copy-waitTime Resp_TH_required Copy-Resp
             MACC_Timeout Copy-Timeout maxTime timeFalStart banDate cdnTimeUpdate
             MACC_PORT Copy-THport LMCHzPort Copy-LMCHzPort addTimeoutPIoT Copy-addTimeoutPIoT
             UpdateRequest crashSituat cdnChange cdnRepeat Proxytext MaxApiToken Copy-MaxApiToken
             AgeConfirmBox Copy-AgeConfirm
      WITH FRAME Dialog-Frame.
      MACC_IP:VISIBLE = false.
      VIEW FRAME Dialog-Frame.
  end.
  else if p-obj-type = 'регион':U then do:
     DISPLAY gisAdress cdnTurnOn cdnAdress Copy-cdnAdress registrationKey
            Copy-registrationKey adressPort Copy-adressPort login password
            Copy-LogPass dopParam Copy-dopParam OflineAdress Copy-OflineAdress
            OflineLogin waitTime Copy-waitTime
            Resp_TH_required Copy-Resp MACC_Timeout Copy-Timeout
            MACC_PORT Copy-THport LMCHzPort Copy-LMCHzPort addTimeoutPIoT
            Copy-addTimeoutPIoT crashSituat TxtCopy TxtCopy-2 Proxytext
            MaxApiToken Copy-MaxApiToken AgeConfirmBox Copy-AgeConfirm
      WITH FRAME Dialog-Frame.
      ENABLE B-exit RECT-1 RECT-2 RECT-3 B-quit B-Help gisAdress cdnTurnOn
             cdnAdress Copy-cdnAdress registrationKey Copy-registrationKey
             adressPort Copy-adressPort login password Copy-LogPass dopParam
             Copy-dopParam OflineAdress Copy-OflineAdress OflineLogin OflinePswd
             waitTime Copy-waitTime Resp_TH_required Copy-Resp
             MACC_Timeout Copy-Timeout MACC_PORT Copy-THport LMCHzPort
             Copy-LMCHzPort addTimeoutPIoT Copy-addTimeoutPIoT
             crashSituat Proxytext MaxApiToken Copy-MaxApiToken
             AgeConfirmBox Copy-AgeConfirm
      WITH FRAME Dialog-Frame.
      ASSIGN
         maxTime:VISIBLE = false
         timeFalStart:VISIBLE = false
         banDate:VISIBLE = false
         cdnTimeUpdate:VISIBLE = false
         cdnRepeat:VISIBLE = false
         cdnChange:VISIBLE = false
         UpdateRequest:VISIBLE = false
         MACC_IP:VISIBLE = false
      .
      VIEW FRAME Dialog-Frame.
  end.
  else do:
      DISPLAY OflineAdress OflineLogin OflinePswd gisAdress cdnTurnOn
              cdnAdress registrationKey adressPort login password
              dopParam waitTime Proxytext crashSituat
              MACC_Timeout Resp_TH_required MACC_IP MACC_PORT LMCHzPort
              addTimeoutPIoT MaxApiToken AgeConfirmBox
          WITH FRAME Dialog-Frame.
      ENABLE B-exit B-quit OflineAdress OflineLogin OflinePswd gisAdress cdnTurnOn
              cdnAdress registrationKey adressPort login password
              dopParam waitTime crashSituat MACC_Timeout Resp_TH_required
              MACC_IP MACC_PORT LMCHzPort addTimeoutPIoT MaxApiToken AgeConfirmBox
          WITH FRAME Dialog-Frame.
      ASSIGN
         maxTime:VISIBLE = false
         timeFalStart:VISIBLE = false
         banDate:VISIBLE = false
         cdnTimeUpdate:VISIBLE = false
         cdnRepeat:VISIBLE = false
         cdnChange:VISIBLE = false
         UpdateRequest:VISIBLE = false
         Copy-cdnAdress:VISIBLE = false
         Copy-registrationKey:VISIBLE = false
         Copy-adressPort:VISIBLE = false
         Copy-LogPass:VISIBLE = false
         Copy-dopParam:VISIBLE = false
         Copy-OflineAdress:VISIBLE = false
         Copy-waitTime:VISIBLE = false
         Copy-Resp:VISIBLE = false
         Copy-Timeout:VISIBLE = false
         Copy-THport:VISIBLE = false
         Copy-LMCHzPort:VISIBLE = false
         Copy-addTimeoutPIoT:VISIBLE = false
         TxtCopy:VISIBLE = false
         TxtCopy-2:VISIBLE = false
         RECT-3:VISIBLE = false
         Copy-AgeConfirm:VISIBLE = false
         Copy-MaxApiToken:VISIBLE = false
      .
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
for each temp-thbj-attr:
  delete temp-thbj-attr.
end.
run adm/shattri.p (
    input "init":U
  , input p-obj-type
  , input p-obj-code
  , input 'gisMT':U
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
FOR EACH temp-thbj-attr
  :
    if p-obj-type eq "" and p-obj-code = 0
    then do:
        IF temp-thbj-attr.prop-code = 'maxTime':U THEN DO:
           maxTime = temp-thbj-attr.property-value-integer.
           display maxTime with frame Dialog-Frame .
        END.
        else IF temp-thbj-attr.prop-code = 'timeFalStart':U THEN DO:
           timeFalStart = temp-thbj-attr.property-value-integer.
           display timeFalStart with frame Dialog-Frame .
        END.
        else IF temp-thbj-attr.prop-code = 'crashSituat':U THEN DO:
           crashSituat = temp-thbj-attr.property-value-logical.
           display crashSituat with frame Dialog-Frame .
        END.
        else IF temp-thbj-attr.prop-code = 'banDate':U THEN DO:
           banDate = temp-thbj-attr.property-value-integer.
           display banDate with frame Dialog-Frame .
        END.
        else IF temp-thbj-attr.prop-code = 'cdnRepeat':U THEN DO:
           cdnRepeat = temp-thbj-attr.property-value-logical.
           display cdnRepeat with frame Dialog-Frame .
        END.
        else IF temp-thbj-attr.prop-code = 'cdnChange':U THEN DO:
           cdnChange = temp-thbj-attr.property-value-logical.
           display cdnChange with frame Dialog-Frame .
        END.
        else IF temp-thbj-attr.prop-code = 'cdnTimeUpdate':U THEN DO:
           cdnTimeUpdate = temp-thbj-attr.property-value-integer.
           display cdnTimeUpdate with frame Dialog-Frame .
        END.
        else IF temp-thbj-attr.prop-code = 'UpdateRequest':U THEN DO:
           UpdateRequest = temp-thbj-attr.property-value-logical.
           display UpdateRequest with frame Dialog-Frame .
        END.
    end.
    IF temp-thbj-attr.prop-code = 'adressPort':U THEN DO:
        adressPort = temp-thbj-attr.property-value-character.
        display adressPort with frame Dialog-Frame .
     END.
     else IF temp-thbj-attr.prop-code = 'dopParam':U THEN DO:
        dopParam = temp-thbj-attr.property-value-character.
        display dopParam with frame Dialog-Frame .
     END.
     else IF temp-thbj-attr.prop-code = 'gisAdress':U THEN DO:
        gisAdress = temp-thbj-attr.property-value-character.
        display gisAdress with frame Dialog-Frame .
     END.
     else IF temp-thbj-attr.prop-code = 'proxyLogin':U THEN DO:
        login = temp-thbj-attr.property-value-character.
        display login with frame Dialog-Frame .
     END.
     else IF temp-thbj-attr.prop-code = 'proxyPswd':U THEN DO:
        password = temp-thbj-attr.property-value-character.
        display password with frame Dialog-Frame .
     END.
     else IF temp-thbj-attr.prop-code = 'regKey':U THEN DO:
        registrationKey = temp-thbj-attr.property-value-character.
        display registrationKey with frame Dialog-Frame .
     END.
     else IF temp-thbj-attr.prop-code = 'waitTime':U THEN DO:
        waitTime = temp-thbj-attr.property-value-decimal.
        display waitTime with frame Dialog-Frame .
     END.
     else IF temp-thbj-attr.prop-code = 'cdnTurnOn':U THEN DO:
        cdnTurnOn = temp-thbj-attr.property-value-logical.
        display cdnTurnOn with frame Dialog-Frame .
     END.
     else IF temp-thbj-attr.prop-code = 'cdnAdress':U THEN DO:
        cdnAdress = temp-thbj-attr.property-value-character.
        display cdnAdress with frame Dialog-Frame .
     END.
    else IF temp-thbj-attr.prop-code = 'OflineAdress':U THEN DO:
       OflineAdress = temp-thbj-attr.property-value-character.
       display OflineAdress with frame Dialog-Frame .
    END.
    else IF temp-thbj-attr.prop-code = 'OflineLogin':U THEN DO:
       OflineLogin = temp-thbj-attr.property-value-character.
       display OflineLogin with frame Dialog-Frame .
    END.
    else IF temp-thbj-attr.prop-code = 'OflinePswd':U THEN DO:
       OflinePswd = fill("*",length (temp-thbj-attr.property-value-character)).
       display OflinePswd with frame Dialog-Frame .
    END.
    else IF temp-thbj-attr.prop-code = 'crashSituat':U THEN DO:
       crashSituat = temp-thbj-attr.property-value-logical.
       display crashSituat with frame Dialog-Frame .
    END.
    else if temp-thbj-attr.prop-code = 'MACC_Timeout':U then do:
       MACC_Timeout = temp-thbj-attr.property-value-decimal.
       display MACC_Timeout with frame Dialog-Frame .
    end.
    else if temp-thbj-attr.prop-code = 'Resp_TH_required':U then do:
    if available temp-thbj-attr
    then
       Resp_TH_required = if temp-thbj-attr.property-value-integer = 1 then "Да" else "Нет".
       display Resp_TH_required with frame Dialog-Frame .
    end.
    else if temp-thbj-attr.prop-code = 'TH_IP':U
            and p-obj-type = 'БД':U
    then do:
       MACC_IP = temp-thbj-attr.property-value-character.
       display MACC_IP with frame Dialog-Frame .
    end.
    else if temp-thbj-attr.prop-code = 'TH_Port':U then do:
       MACC_PORT = temp-thbj-attr.property-value-character.
       display MACC_PORT with frame Dialog-Frame .
    end.
    else if temp-thbj-attr.prop-code = 'LmCHzPort':U then do:
       LMCHzPort = temp-thbj-attr.property-value-character.
       display LMCHzPort with frame Dialog-Frame .
    end.
    else if temp-thbj-attr.prop-code = 'AddTimeoutPIoT':U then do:
       AddTimeoutPIoT = temp-thbj-attr.property-value-decimal.
       display AddTimeoutPIoT with frame Dialog-Frame .
    end.
    else if temp-thbj-attr.prop-code = 'MaxApiToken':U then do:
       MaxApiToken = fill("*",length (temp-thbj-attr.property-value-character)).
       display MaxApiToken with frame Dialog-Frame .
    end.
    else if temp-thbj-attr.prop-code = 'AgeConfirm':U then do:
       AgeConfirm = temp-thbj-attr.property-value-integer.
    end.
    else if p-obj-type ne ""
    then do:
       delete temp-thbj-attr.
    end.
END.
   if p-mode NE 'ПРОСМОТР':U then do:
       if cdnTurnOn then do:
          disable gisAdress with frame Dialog-Frame .
          enable cdnAdress with frame Dialog-Frame .
       end.
       else do:
          enable gisAdress with frame Dialog-Frame .
          disable cdnAdress with frame Dialog-Frame .
       end.
   end.
   AgeConfirmBox =  entry((AgeConfirm + 1), AgeConfirmBox:LIST-ITEMS,",").
   display AgeConfirmBox  with frame Dialog-Frame .
   if p-mode = 'ПРОСМОТР':U then do:
      disable all WITH FRAME Dialog-Frame .
      ENABLE B-quit b-help WITH FRAME Dialog-Frame.
      B-quit:label = "Вы&ход"  .
      hide B-exit in frame Dialog-Frame .
   end.
END PROCEDURE.
PROCEDURE init-tt :
END PROCEDURE.
PROCEDURE save-proc :
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-param-type as character no-undo .
define variable v-gds-copy-list as character no-undo .
define variable v-gdsreffi as character no-undo .
define variable wh as widget-handle no-undo .
define variable fh as widget-handle no-undo .
define variable v-same as logical no-undo .
define buffer buf_temp-thbj-attr for temp-thbj-attr .
IF p-mode = 'ПРОСМОТР':U THEN RETURN ERROR.
ASSIGN FRAME Dialog-Frame
    adressPort
    dopParam
    gisAdress
    login
    password
    maxTime
    registrationKey
    timeFalStart
    waitTime
    crashSituat
    banDate
    cdnTurnOn
    cdnAdress
    cdnRepeat
    cdnChange
    cdnTimeUpdate
    UpdateRequest
    OflineAdress
    OflineLogin
    OflinePswd
    MACC_Timeout
    Resp_TH_required
    MACC_IP
    MACC_PORT
    LMCHzPort
    AddTimeoutPIoT
    MaxApiToken
    Copy-cdnAdress
    Copy-registrationKey
    Copy-adressPort
    Copy-LogPass
    Copy-dopParam
    Copy-OflineAdress
    Copy-waitTime
    Copy-Resp
    Copy-Timeout
    Copy-THport
    Copy-LMCHzPort
    Copy-addTimeoutPIoT
    Copy-AgeConfirm
    Copy-MaxApiToken
    .
    for each temp-thbj-attr where
             temp-thbj-attr.obj-type = p-obj-type and
             temp-thbj-attr.obj-code = p-obj-code:
       case temp-thbj-attr.prop-code:
           when 'adressPort':U
           then do:
              if temp-thbj-attr.property-value-character <> adressPort
              then do:
                 create thbjattr-list.
                 buffer-copy temp-thbj-attr to thbjattr-list.
              end.
              temp-thbj-attr.property-value-character = adressPort.
           end.
           when 'dopParam':U then
              temp-thbj-attr.property-value-character = dopParam.
           when 'gisAdress':U then
              temp-thbj-attr.property-value-character = gisAdress.
           when 'proxyLogin':U
           then do:
               if temp-thbj-attr.property-value-character <> login
              then do:
                 create thbjattr-list.
                 buffer-copy temp-thbj-attr to thbjattr-list.
              end.
              temp-thbj-attr.property-value-character = login.
           end.
           when  'proxyPswd':U
           then do:
              if temp-thbj-attr.property-value-character <> password
              then do:
                 create thbjattr-list.
                 buffer-copy temp-thbj-attr to thbjattr-list.
              end.
              temp-thbj-attr.property-value-character = password.
           end.
           when 'maxTime':U
           then do:
              if temp-thbj-attr.property-value-integer <> maxTime
              then do:
                 create thbjattr-list.
                 buffer-copy temp-thbj-attr to thbjattr-list.
              end.
              temp-thbj-attr.property-value-integer = maxTime.
           end.
           when 'regKey':U then
              temp-thbj-attr.property-value-character = registrationKey.
           when 'timeFalStart':U
           then do:
              if temp-thbj-attr.property-value-integer = timeFalStart
              then do:
                 create thbjattr-list.
                 buffer-copy temp-thbj-attr to thbjattr-list.
              end.
              temp-thbj-attr.property-value-integer = timeFalStart.
           end.
           when 'waitTime':U
           then do:
               if temp-thbj-attr.property-value-decimal <> waitTime
               then do:
                  create thbjattr-list.
                  buffer-copy temp-thbj-attr to thbjattr-list.
               end.
               temp-thbj-attr.property-value-decimal = waitTime.
           end.
           when 'crashSituat':U
           then do:
              if temp-thbj-attr.property-value-logical <> crashSituat
              then do:
                 create thbjattr-list.
                 buffer-copy temp-thbj-attr to thbjattr-list.
              end.
              temp-thbj-attr.property-value-logical = crashSituat.
           end.
           when 'banDate':U
           then do:
              if temp-thbj-attr.property-value-integer <> banDate
              then do:
                 create thbjattr-list.
                 buffer-copy temp-thbj-attr to thbjattr-list.
              end.
              temp-thbj-attr.property-value-integer = banDate.
           end.
           when 'cdnTurnOn':U then
              temp-thbj-attr.property-value-logical = cdnTurnOn.
           when 'cdnAdress':U then
              temp-thbj-attr.property-value-character = cdnAdress.
           when 'cdnRepeat':U then
              temp-thbj-attr.property-value-logical = cdnRepeat.
           when 'cdnChange':U then
              temp-thbj-attr.property-value-logical = cdnChange.
           when 'cdnTimeUpdate':U then
              temp-thbj-attr.property-value-integer = cdnTimeUpdate.
           when 'UpdateRequest':U then
              temp-thbj-attr.property-value-logical = UpdateRequest.
           when 'OflineAdress':U then
              temp-thbj-attr.property-value-character = OflineAdress.
           when 'OflineLogin':U
           then do:
              if temp-thbj-attr.property-value-character <> OflineLogin
              then do:
                 create thbjattr-list.
                 buffer-copy temp-thbj-attr to thbjattr-list.
              end.
              temp-thbj-attr.property-value-character = OflineLogin.
           end.
           when 'OflinePswd':U
           then do:
              if (OflinePswd eq "" or (replace(OflinePswd,"*","") ne "" and OflinePswd ne ?)) then
              do:
                 if temp-thbj-attr.property-value-character <> OflinePswd
                 then do:
                    create thbjattr-list.
                    buffer-copy temp-thbj-attr to thbjattr-list.
                 end.
                 temp-thbj-attr.property-value-character = OflinePswd.
              end.
           end.
           when 'MACC_Timeout':U
           then do:
               if temp-thbj-attr.property-value-decimal <> MACC_Timeout
               then do:
                  create thbjattr-list.
                  buffer-copy temp-thbj-attr to thbjattr-list.
               end.
               temp-thbj-attr.property-value-decimal = MACC_Timeout.
           end.
           when 'Resp_TH_required':U
           then do:
               if (temp-thbj-attr.property-value-integer = 0 and Resp_TH_required = "Да") or
                  (temp-thbj-attr.property-value-integer = 1 and Resp_TH_required <> "Да")
               then do:
                  create thbjattr-list.
                  buffer-copy temp-thbj-attr to thbjattr-list.
               end.
               temp-thbj-attr.property-value-integer = if Resp_TH_required = "Да" then 1 else 0.
           end.
           when 'TH_IP':U then do:
              if MACC_IP <> "" and temp-thbj-attr.property-value-character <> MACC_IP
              then do:
                 create thbjattr-list.
                 buffer-copy temp-thbj-attr to thbjattr-list.
              end.
              temp-thbj-attr.property-value-character = MACC_IP.
           end.
           when 'TH_Port':U then do:
              if temp-thbj-attr.property-value-character <> MACC_PORT
              then do:
                 create thbjattr-list.
                 buffer-copy temp-thbj-attr to thbjattr-list.
              end.
              temp-thbj-attr.property-value-character = MACC_PORT.
           end.
           when 'LmCHzPort':U then do:
              if temp-thbj-attr.property-value-character <> LMCHzPort
              then do:
                 create thbjattr-list.
                 buffer-copy temp-thbj-attr to thbjattr-list.
              end.
              temp-thbj-attr.property-value-character = LMCHzPort.
           end.
           when 'AddTimeoutPIoT':U then do:
              if temp-thbj-attr.property-value-decimal <> AddTimeoutPIoT
              then do:
                 create thbjattr-list.
                 buffer-copy temp-thbj-attr to thbjattr-list.
              end.
              temp-thbj-attr.property-value-decimal = AddTimeoutPIoT.
           end.
           when 'MaxApiToken':U then do:
              if (MaxApiToken eq "" or (replace(MaxApiToken,"*","") ne "" and MaxApiToken ne ?)) then
              do:
                  if temp-thbj-attr.property-value-character <> MaxApiToken
                  then do:
                     create thbjattr-list.
                     buffer-copy temp-thbj-attr to thbjattr-list.
                  end.
                  temp-thbj-attr.property-value-character = MaxApiToken.
              end.
           end.
           when 'AgeConfirm':U then do:
              if temp-thbj-attr.property-value-integer <> AgeConfirm
              then do:
                 create thbjattr-list.
                 buffer-copy temp-thbj-attr to thbjattr-list.
              end.
              temp-thbj-attr.property-value-integer = AgeConfirm.
           end.
       end.
    end.
    do transaction:
        RUN thbjattr_set-section IN THIS-PROCEDURE (
             input p-obj-type
            ,input p-obj-code
            ,input 'gisMT':U
            ,INPUT table temp-thbj-attr
        ) NO-ERROR.
        if error-status:error then do:
            message "Не удалось сохранить настройки"
            view-as alert-box.
            undo, return error.
        end.
        if p-obj-type eq 'БД':U and
           can-find(first thbjattr-list) then
        run str/diallog.w (
            input parparentproc
          , input this-procedure
          , input "str/send-all.p":U
          , input ( p-obj-type + chr(4) + string(p-obj-code) + chr(4) + 'U':U + chr(4) + 'gismt':U + chr(4) + 'Передача параметров работы с ТСПИоТ':U)
          , input ?
          , input "":U
          , input substitute("Отсылка параметров работы с ТСПИоТ")
          ) no-error.
        if p-obj-type ne 'БД':U and
           (Copy-cdnAdress       or
            Copy-registrationKey or
            Copy-adressPort      or
            Copy-LogPass         or
            Copy-dopParam        or
            Copy-OflineAdress    or
            Copy-waitTime        or
            Copy-Resp            or
            Copy-Timeout         or
            Copy-THport          or
            Copy-LMCHzPort       or
            Copy-addTimeoutPIoT  or
            Copy-MaxApiToken     or
            Copy-AgeConfirm)
        then do:
            MESSAGE "Подтверждаете изменение значений в локальных секциях?"
                VIEW-AS ALERT-BOX QUESTION
                BUTTONS YES-NO
                UPDATE v-copy AS LOGICAL.
            if v-copy then do:
               run ObjCodeCreate.
               if Copy-cdnAdress then run PropCopy('cdnAdress':U).
               if Copy-registrationKey then run PropCopy('regKey':U).
               if Copy-adressPort then run PropCopy('adressPort':U).
               if Copy-LogPass then do:
                  run PropCopy('proxyLogin':U).
                  run PropCopy('proxyPswd':U).
               end.
               if Copy-dopParam then run PropCopy('dopParam':U).
               if Copy-OflineAdress then run PropCopy('OflineAdress':U).
               if Copy-waitTime then run PropCopy('waitTime':U).
               if Copy-Resp then run PropCopy('Resp_TH_required':U).
               if Copy-Timeout then run PropCopy('MACC_Timeout':U).
               if Copy-THport then run PropCopy('TH_Port':U).
               if Copy-LMCHzPort then run PropCopy('LmCHzPort':U).
               if Copy-addTimeoutPIoT then run PropCopy('AddTimeoutPIoT':U).
               if Copy-MaxApiToken then run PropCopy('MaxApiToken':U).
               if Copy-AgeConfirm then run PropCopy('AgeConfirm':U).
            end.
         end.
    end.
END PROCEDURE.
PROCEDURE ObjCodeCreate:
   define buffer buf_thbj-attr for ub.thbj-attr.
   define variable v-reg-code as integer no-undo.
   bth:
   for each buf_thbj-attr no-lock where
           (buf_thbj-attr.obj-type = 'БД':U
        and buf_thbj-attr.prop-code       = ''
        and buf_thbj-attr.upper-prop-code = 'gisMT':U
            )
        or (p-obj-type = ""
        and buf_thbj-attr.obj-type = 'регион':U
        and buf_thbj-attr.prop-code       = ''
        and buf_thbj-attr.upper-prop-code = 'gisMT':U)
        :
      if p-obj-type = 'регион':U then do:
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run regcode in g#library
  (input  buf_thbj-attr.obj-type
  ,input  buf_thbj-attr.obj-code
  ,output v-reg-code
  )  .
          if v-reg-code <> p-obj-code then next bth.
      end.
      find first x_thbj-attr where
          x_thbj-attr.obj-type = buf_thbj-attr.obj-type and
          x_thbj-attr.obj-code = buf_thbj-attr.obj-code no-error .
      if not available x_thbj-attr then do:
        create  x_thbj-attr.
        buffer-copy buf_thbj-attr to X_thbj-attr.
      end.
   end.
END PROCEDURE.
PROCEDURE PropCopy:
    define input parameter p-prop-code as character no-undo.
    define buffer buf_thbj-attr for ub.thbj-attr.
    define buffer thbj-attr for ub.thbj-attr.
    find first thbj-attr where
               thbj-attr.obj-type = p-obj-type
           and thbj-attr.obj-code = p-obj-code
           and thbj-attr.upper-prop-code = 'gisMT':U
           and thbj-attr.prop-code = p-prop-code
         no-lock no-error.
    if avail thbj-attr then
    do transaction:
        for each x_thbj-attr:
           find first buf_thbj-attr exclusive-lock where
                      buf_thbj-attr.obj-type = x_thbj-attr.obj-type
                  and buf_thbj-attr.obj-code = x_thbj-attr.obj-code
                  and buf_thbj-attr.upper-prop-code = 'gisMT':U
                  and buf_thbj-attr.prop-code = p-prop-code
           no-wait no-error.
           if not avail buf_thbj-attr
              and not locked buf_thbj-attr
           then do:
               create buf_thbj-attr.
               assign
                  buf_thbj-attr.obj-type = 'БД':U
                  buf_thbj-attr.obj-code = x_thbj-attr.obj-code
                  .
           end.
           if avail buf_thbj-attr then
           buffer-copy  thbj-attr except obj-type obj-code to buf_thbj-attr.
        end.
    end.
END PROCEDURE.
