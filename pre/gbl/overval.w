define input parameter parparentproc as widget-handle no-undo.
define input parameter p-mode     as character no-undo.
define input parameter p-obj-type like ub.clients.obj-type no-undo.
define input parameter p-obj-code like ub.shop.obj-code no-undo.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-Workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Настройки для переоценок" .
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
define temp-table x_thbj-attr no-undo like ub.thbj-attr
  field p1 as char
  field d1 as char
  .
define buffer buf_thbj-attr for ub.thbj-attr.
define temp-table temp-thbj-attr        no-undo like ub.thbj-attr.
define temp-table thbjattr_thbj-attr-tt no-undo like ub.thbj-attr.
define variable v-tth           as handle    no-undo .
define variable v-buff-tth      as handle    no-undo .
define variable v-to-create     as logical   no-undo .
define variable v-to-create-trn as logical   no-undo .
define variable str-attr        as character no-undo .
assign
v-tth = buffer thbjattr_thbj-attr:table-handle .
v-buff-tth = buffer thbjattr_thbj-attr-tt:table-handle .
if g#db-num <> 0 then p-mode = 'ПРОСМОТР':U .
DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-frame-a
     LABEL "Параметры 1"
     SIZE 15 BY 1.13.
DEFINE BUTTON b-frame-b
     LABEL "Параметры 2"
     SIZE 15 BY 1.13.
DEFINE BUTTON B-Help
     LABEL "&Help"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-attr-pr-abs-d
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE BUTTON B-attr-pr-altex
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE BUTTON B-attr-pr-clt-q
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE BUTTON B-attr-pr-discm
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE BUTTON B-attr-pr-dpl-q
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE BUTTON B-attr-pr-dscnt
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE BUTTON B-attr-pr-equ-dq
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE BUTTON B-attr-pr-incpc
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE BUTTON B-attr-pr-list
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE BUTTON B-attr-pr-notls
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE BUTTON B-attr-pr-parex
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE BUTTON B-attr-pr-print
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE BUTTON B-attr-pr-rdc-q
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE BUTTON B-attr-pr-rndbs
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE BUTTON B-attr-pr-rndmt
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE BUTTON B-attr-pr-sclex
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE BUTTON B-attr-pr-sigma
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE BUTTON B-corr-pr-list
     IMAGE-UP FILE "cmp/update.bmp":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE VARIABLE pr-discm AS CHARACTER FORMAT "X(256)":U INITIAL "cost"
     VIEW-AS COMBO-BOX INNER-LINES 7
     LIST-ITEMS "","cost","sale","sale-","cost-vat","prod","prod-vat"
     DROP-DOWN-LIST
     SIZE 11 BY 1 NO-UNDO.
DEFINE VARIABLE pr-equ-dq AS INTEGER FORMAT "9":U INITIAL 2
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEM-PAIRS "Не удалять",1,
                     "Запрос на удаление",2,
                     "Удаление без запроса",3
     DROP-DOWN-LIST
     SIZE 24 BY 1 NO-UNDO.
DEFINE VARIABLE pr-rndmt AS CHARACTER FORMAT "X(256)":U INITIAL "pr-round-off"
     VIEW-AS COMBO-BOX INNER-LINES 7
     LIST-ITEM-PAIRS "9-окончание","pr-round-9end   ",
                     "9-99окончание","pr-round-9-99end",
                     "Без-дробных","pr-round-integer",
                     "Произвольно","pr-round-select ",
                     "Вверх","pr-round-up     ",
                     "Коэффициент","pr-round-coef   ",
                     "Отключено","pr-round-off"
     DROP-DOWN-LIST
     SIZE 14 BY 1 NO-UNDO.
DEFINE VARIABLE pr-list AS CHARACTER INITIAL "Товар,Группа,УчетнаяS,Учетная,Учет-рзрвS,Учет-резерв,ПриходнаяS,Приходная,Старая,Новая,Объект,Накладная,Переоценка,ДокФормЦены,Накл-безНДС,Учет-НДСS,Учет-безНДС,Стар-безНДС,Учет+накл,Уч+накл-НДС,Единая,Отсутствует,Откат_цен,Не-считать,Производит,Произв-НДС,ПорогПр-НДС,ПорогПр+НДС,Спецификация"
     VIEW-AS EDITOR
     SIZE 56 BY 2.5
     FONT 4 NO-UNDO.
DEFINE VARIABLE FILL-IN-2 AS CHARACTER FORMAT "X(256)":U INITIAL "Начальные значения для ТПЛ"
      VIEW-AS TEXT
     SIZE 28 BY .67
     FGCOLOR 1  NO-UNDO.
DEFINE VARIABLE pr-incpc AS DECIMAL FORMAT "->>,>>9.99":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 9 BY 1 NO-UNDO.
DEFINE VARIABLE pr-rndbs AS DECIMAL FORMAT "->>,>>9.99":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 9 BY 1 NO-UNDO.
DEFINE VARIABLE pr-sigma AS DECIMAL FORMAT "->>,>>9.99":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 10.88 BY 1 NO-UNDO.
DEFINE VARIABLE v-pr-abs-d AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 79 BY 1 NO-UNDO.
DEFINE VARIABLE v-pr-altex AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 48.75 BY 1 NO-UNDO.
DEFINE VARIABLE v-pr-clt-q AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 77 BY 1 NO-UNDO.
DEFINE VARIABLE v-pr-discm AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 39.38 BY 1 NO-UNDO.
DEFINE VARIABLE v-pr-dpl-q AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 77 BY 1 NO-UNDO.
DEFINE VARIABLE v-pr-dscnt AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 77 BY 1 NO-UNDO.
DEFINE VARIABLE v-pr-equ-dq AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 70 BY 1 NO-UNDO.
DEFINE VARIABLE v-pr-incpc AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 30.5 BY 1 NO-UNDO.
DEFINE VARIABLE v-pr-list AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 32 BY 1
     FGCOLOR 1  NO-UNDO.
DEFINE VARIABLE v-pr-notls AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 77 BY 1 NO-UNDO.
DEFINE VARIABLE v-pr-parex AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 48 BY 1 NO-UNDO.
DEFINE VARIABLE v-pr-print AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 77 BY 1 NO-UNDO.
DEFINE VARIABLE v-pr-rdc-q AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 77 BY 1 NO-UNDO.
DEFINE VARIABLE v-pr-rndbs AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 30.38 BY 1 NO-UNDO.
DEFINE VARIABLE v-pr-rndmt AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 25.75 BY 1 NO-UNDO.
DEFINE VARIABLE v-pr-sclex AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 49.75 BY 1 NO-UNDO.
DEFINE VARIABLE v-pr-sigma AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 59.5 BY 1 NO-UNDO.
DEFINE IMAGE I-pr-abs-d
     FILENAME "cmp/info.bmp":U
     SIZE 2.5 BY 1.04.
DEFINE IMAGE I-pr-altex
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.
DEFINE IMAGE I-pr-clt-q
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.
DEFINE IMAGE I-pr-discm
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.
DEFINE IMAGE I-pr-dpl-q
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.
DEFINE IMAGE I-pr-dscnt
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.
DEFINE IMAGE I-pr-equ-dq
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.
DEFINE IMAGE I-pr-incpc
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.
DEFINE IMAGE I-pr-list
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.
DEFINE IMAGE I-pr-notls
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.
DEFINE IMAGE I-pr-parex
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.
DEFINE IMAGE I-pr-print
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.
DEFINE IMAGE I-pr-rdc-q
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.
DEFINE IMAGE I-pr-rndbs
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.
DEFINE IMAGE I-pr-rndmt
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.
DEFINE IMAGE I-pr-sclex
     FILENAME "cmp/info.bmp":U
     SIZE 2.5 BY 1.
DEFINE IMAGE I-pr-sigma
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.
DEFINE VARIABLE pr-abs-d AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.38 BY 1 NO-UNDO.
DEFINE VARIABLE pr-altex AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.13 BY 1 NO-UNDO.
DEFINE VARIABLE pr-clt-q AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.38 BY 1 NO-UNDO.
DEFINE VARIABLE pr-dpl-q AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 1.88 BY 1 NO-UNDO.
DEFINE VARIABLE pr-dscnt AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.38 BY 1 NO-UNDO.
DEFINE VARIABLE pr-notls AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.25 BY 1 NO-UNDO.
DEFINE VARIABLE pr-parex AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.13 BY 1 NO-UNDO.
DEFINE VARIABLE pr-print AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.38 BY 1 NO-UNDO.
DEFINE VARIABLE pr-rdc-q AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.38 BY 1 NO-UNDO.
DEFINE VARIABLE pr-sclex AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.13 BY 1 NO-UNDO.
DEFINE BUTTON B-attr-pr-goods
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE BUTTON B-attr-pr-goods0
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE BUTTON B-attr-pr-nogds
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE BUTTON B-attr-pr-nogds0
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE BUTTON B-corr-pr-nogds
     IMAGE-UP FILE "cmp/update.bmp":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE BUTTON B-corr-pr-nogds0
     IMAGE-UP FILE "cmp/update.bmp":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE VARIABLE pr-goods AS CHARACTER FORMAT "X(256)":U INITIAL "1.нет запрета"
     VIEW-AS COMBO-BOX INNER-LINES 8
     LIST-ITEMS "1.нет запрета","2.на товар","3.на топливо","4.на услугу","5.на товар и услугу","6.на товар и топливо","7.на услугу и топливо","8.запрет на все"
     DROP-DOWN-LIST
     SIZE 24.5 BY 1 NO-UNDO.
DEFINE VARIABLE pr-goods0 AS CHARACTER FORMAT "X(256)":U INITIAL "1.нет запрета"
     VIEW-AS COMBO-BOX INNER-LINES 8
     LIST-ITEMS "1.нет запрета","2.на товар","3.на топливо","4.на услугу","5.на товар и услугу","6.на товар и топливо","7.на услугу и топливо","8.запрет на все"
     DROP-DOWN-LIST
     SIZE 24.5 BY 1 NO-UNDO.
DEFINE VARIABLE pr-nogds AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 46 BY 1
     FONT 2 NO-UNDO.
DEFINE VARIABLE pr-nogds0 AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 46 BY 1
     FONT 2 NO-UNDO.
DEFINE VARIABLE scr-nogrp AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 51.75 BY 2.75
     FONT 2 NO-UNDO.
DEFINE VARIABLE scr-nogrp0 AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 51.75 BY 2.75
     FONT 2 NO-UNDO.
DEFINE VARIABLE v-pr-goods AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 69 BY 1 NO-UNDO.
DEFINE VARIABLE v-pr-goods0 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 69 BY 1 NO-UNDO.
DEFINE VARIABLE v-pr-nogds AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 47 BY 1 NO-UNDO.
DEFINE VARIABLE v-pr-nogds0 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 47 BY 1 NO-UNDO.
DEFINE IMAGE I-pr-goods
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.
DEFINE IMAGE I-pr-goods0
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.
DEFINE IMAGE I-pr-nogds
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.
DEFINE IMAGE I-pr-nogds0
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.
DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1 WIDGET-ID 244
     B-quit AT ROW 1 COL 11 WIDGET-ID 246
     b-frame-a AT ROW 1 COL 26 WIDGET-ID 248
     b-frame-b AT ROW 1 COL 41 WIDGET-ID 250
     B-Help AT ROW 1 COL 93
     SPACE(0.12) SKIP(20.87)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Настройки для  П Е Р Е О Ц Е Н О К" WIDGET-ID 100.
DEFINE FRAME FRAME-A
     B-attr-pr-notls AT ROW 1.21 COL 2.88 WIDGET-ID 102
     pr-notls AT ROW 1.21 COL 6.25 WIDGET-ID 106
     B-attr-pr-altex AT ROW 2.21 COL 5.5 WIDGET-ID 52
     pr-altex AT ROW 2.21 COL 8.88 WIDGET-ID 46
     B-attr-pr-sclex AT ROW 3.21 COL 5.5 WIDGET-ID 186
     pr-sclex AT ROW 3.21 COL 8.88 WIDGET-ID 190
     B-attr-pr-parex AT ROW 4.21 COL 5.5 WIDGET-ID 110
     pr-parex AT ROW 4.21 COL 8.88 WIDGET-ID 114
     B-attr-pr-clt-q AT ROW 5.21 COL 2.75 WIDGET-ID 54
     pr-clt-q AT ROW 5.21 COL 6.13 WIDGET-ID 58
     B-attr-pr-dpl-q AT ROW 6.21 COL 2.75 WIDGET-ID 62
     pr-dpl-q AT ROW 6.21 COL 6.13 WIDGET-ID 66
     B-attr-pr-rdc-q AT ROW 7.21 COL 2.75 WIDGET-ID 126
     pr-rdc-q AT ROW 7.21 COL 6.13 WIDGET-ID 130
     B-attr-pr-equ-dq AT ROW 8.21 COL 2.75 WIDGET-ID 216
     pr-equ-dq AT ROW 8.21 COL 4 COLON-ALIGNED NO-LABEL WIDGET-ID 274
     B-attr-pr-abs-d AT ROW 10.21 COL 2.75 WIDGET-ID 48
     pr-abs-d AT ROW 10.21 COL 6.13 WIDGET-ID 44
     B-attr-pr-dscnt AT ROW 12 COL 2.75 WIDGET-ID 70
     pr-dscnt AT ROW 12 COL 6.13 WIDGET-ID 74
     B-attr-pr-print AT ROW 13 COL 2.75 WIDGET-ID 118
     pr-print AT ROW 13 COL 6.13 WIDGET-ID 122
     B-attr-pr-list AT ROW 14 COL 2.75 WIDGET-ID 170
     B-corr-pr-list AT ROW 14 COL 38.75 WIDGET-ID 222
     pr-list AT ROW 15 COL 1 NO-LABEL WIDGET-ID 214
     B-attr-pr-rndmt AT ROW 15 COL 59.13 WIDGET-ID 178
     pr-rndmt AT ROW 15 COL 60.13 COLON-ALIGNED NO-LABEL WIDGET-ID 210
     B-attr-pr-rndbs AT ROW 16 COL 59.13 WIDGET-ID 154
     pr-rndbs AT ROW 16 COL 60.13 COLON-ALIGNED NO-LABEL WIDGET-ID 158
     B-attr-pr-incpc AT ROW 17 COL 59.13 WIDGET-ID 144
     pr-incpc AT ROW 17 COL 60.13 COLON-ALIGNED NO-LABEL WIDGET-ID 152
     B-attr-pr-discm AT ROW 17.63 COL 3.25 WIDGET-ID 134
     pr-discm AT ROW 17.63 COL 4.63 COLON-ALIGNED NO-LABEL WIDGET-ID 142
     B-attr-pr-sigma AT ROW 18.63 COL 3.25 WIDGET-ID 162
     pr-sigma AT ROW 18.63 COL 4.63 COLON-ALIGNED NO-LABEL WIDGET-ID 166
     v-pr-notls AT ROW 1.21 COL 8.63 NO-LABEL WIDGET-ID 108
     v-pr-altex AT ROW 2.21 COL 11.25 NO-LABEL WIDGET-ID 18
     v-pr-sclex AT ROW 3.21 COL 11.25 NO-LABEL WIDGET-ID 192
     v-pr-parex AT ROW 4.21 COL 11.25 NO-LABEL WIDGET-ID 116
     v-pr-clt-q AT ROW 5.21 COL 8.5 NO-LABEL WIDGET-ID 60
     v-pr-dpl-q AT ROW 6.21 COL 8.5 NO-LABEL WIDGET-ID 68
     v-pr-rdc-q AT ROW 7.21 COL 8.5 NO-LABEL WIDGET-ID 132
     v-pr-equ-dq AT ROW 8.21 COL 29 COLON-ALIGNED NO-LABEL WIDGET-ID 220
     v-pr-abs-d AT ROW 10.21 COL 8.5 NO-LABEL WIDGET-ID 6
     v-pr-dscnt AT ROW 12 COL 8.5 NO-LABEL WIDGET-ID 76
     v-pr-print AT ROW 13 COL 8.25 NO-LABEL WIDGET-ID 124
     v-pr-list AT ROW 14 COL 6 NO-LABEL WIDGET-ID 176
     FILL-IN-2 AT ROW 14.13 COL 55 COLON-ALIGNED NO-LABEL WIDGET-ID 212
     v-pr-rndmt AT ROW 15 COL 77 NO-LABEL WIDGET-ID 184
     v-pr-rndbs AT ROW 16 COL 72.38 NO-LABEL WIDGET-ID 160
     v-pr-incpc AT ROW 17 COL 72.25 NO-LABEL WIDGET-ID 150
     v-pr-discm AT ROW 17.63 COL 18.13 NO-LABEL WIDGET-ID 140
     v-pr-sigma AT ROW 18.63 COL 18 NO-LABEL WIDGET-ID 168
     I-pr-abs-d AT ROW 10.25 COL 1 WIDGET-ID 10
     I-pr-altex AT ROW 2.21 COL 3.75 WIDGET-ID 34
     I-pr-clt-q AT ROW 5.25 COL 1 WIDGET-ID 56
     I-pr-dpl-q AT ROW 6.25 COL 1 WIDGET-ID 64
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY
         SIDE-LABELS NO-UNDERLINE THREE-D
         AT COL 1 ROW 2
         SIZE 102 BY 20.75 WIDGET-ID 200.
DEFINE FRAME FRAME-A
     I-pr-dscnt AT ROW 12 COL 1 WIDGET-ID 72
     I-pr-equ-dq AT ROW 8.25 COL 1 WIDGET-ID 272
     I-pr-notls AT ROW 1.21 COL 1.13 WIDGET-ID 104
     I-pr-parex AT ROW 4.21 COL 3.75 WIDGET-ID 112
     I-pr-print AT ROW 13.04 COL 1 WIDGET-ID 120
     I-pr-rdc-q AT ROW 7.25 COL 1 WIDGET-ID 128
     I-pr-discm AT ROW 17.63 COL 1.5 WIDGET-ID 136
     I-pr-incpc AT ROW 17 COL 57 WIDGET-ID 146
     I-pr-rndbs AT ROW 16 COL 57 WIDGET-ID 156
     I-pr-sigma AT ROW 18.63 COL 1.5 WIDGET-ID 164
     I-pr-list AT ROW 14.04 COL 1 WIDGET-ID 172
     I-pr-rndmt AT ROW 15 COL 57 WIDGET-ID 180
     I-pr-sclex AT ROW 3.21 COL 3.75 WIDGET-ID 188
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY
         SIDE-LABELS NO-UNDERLINE THREE-D
         AT COL 1 ROW 2
         SIZE 102 BY 20.75 WIDGET-ID 200.
DEFINE FRAME FRAME-B
     B-attr-pr-goods0 AT ROW 2 COL 3.38 WIDGET-ID 244
     pr-goods0 AT ROW 2 COL 4.63 COLON-ALIGNED NO-LABEL WIDGET-ID 248
     B-attr-pr-nogds0 AT ROW 3.08 COL 3.5 WIDGET-ID 252
     pr-nogds0 AT ROW 3.08 COL 55 NO-LABEL WIDGET-ID 258
     B-corr-pr-nogds0 AT ROW 4.29 COL 2.75 WIDGET-ID 254
     scr-nogrp0 AT ROW 4.29 COL 6 NO-LABEL WIDGET-ID 260
     B-attr-pr-goods AT ROW 7.96 COL 3.38 WIDGET-ID 224
     pr-goods AT ROW 7.96 COL 4.63 COLON-ALIGNED NO-LABEL WIDGET-ID 228
     B-attr-pr-nogds AT ROW 9.21 COL 3.5 WIDGET-ID 232
     pr-nogds AT ROW 9.21 COL 55 NO-LABEL WIDGET-ID 240
     B-corr-pr-nogds AT ROW 10.42 COL 2.75 WIDGET-ID 234
     scr-nogrp AT ROW 10.42 COL 6 NO-LABEL WIDGET-ID 242
     v-pr-goods0 AT ROW 2.04 COL 29.38 COLON-ALIGNED NO-LABEL WIDGET-ID 250
     v-pr-nogds0 AT ROW 3.08 COL 4.5 COLON-ALIGNED NO-LABEL WIDGET-ID 262
     v-pr-goods AT ROW 8 COL 31 NO-LABEL WIDGET-ID 230
     v-pr-nogds AT ROW 9.21 COL 6.5 NO-LABEL WIDGET-ID 238
     "УБД" VIEW-AS TEXT
          SIZE 8 BY .67 AT ROW 7.25 COL 3.63 WIDGET-ID 270
          FGCOLOR 1
     "ГБД" VIEW-AS TEXT
          SIZE 8 BY .67 AT ROW 1.25 COL 4 WIDGET-ID 268
          FGCOLOR 1
     I-pr-goods AT ROW 7.96 COL 1.63 WIDGET-ID 226
     I-pr-nogds AT ROW 9.21 COL 1.5 WIDGET-ID 236
     I-pr-goods0 AT ROW 2 COL 1.63 WIDGET-ID 246
     I-pr-nogds0 AT ROW 3.08 COL 1.5 WIDGET-ID 256
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY
         SIDE-LABELS NO-UNDERLINE THREE-D
         AT COL 1 ROW 2
         SIZE 102 BY 20.75 WIDGET-ID 300.
ASSIGN FRAME FRAME-A:FRAME = FRAME Dialog-Frame:HANDLE
       FRAME FRAME-B:FRAME = FRAME Dialog-Frame:HANDLE.
DEFINE VARIABLE XXTABVALXX AS LOGICAL NO-UNDO.
ASSIGN XXTABVALXX = FRAME FRAME-B:MOVE-AFTER-TAB-ITEM (B-Help:HANDLE IN FRAME Dialog-Frame)
       XXTABVALXX = FRAME FRAME-B:MOVE-BEFORE-TAB-ITEM (FRAME FRAME-A:HANDLE)
.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       pr-list:READ-ONLY IN FRAME FRAME-A        = TRUE.
ASSIGN
       v-pr-abs-d:READ-ONLY IN FRAME FRAME-A        = TRUE.
ASSIGN
       v-pr-altex:READ-ONLY IN FRAME FRAME-A        = TRUE.
ASSIGN
       v-pr-clt-q:READ-ONLY IN FRAME FRAME-A        = TRUE.
ASSIGN
       v-pr-discm:READ-ONLY IN FRAME FRAME-A        = TRUE.
ASSIGN
       v-pr-dpl-q:READ-ONLY IN FRAME FRAME-A        = TRUE.
ASSIGN
       v-pr-dscnt:READ-ONLY IN FRAME FRAME-A        = TRUE.
ASSIGN
       v-pr-incpc:READ-ONLY IN FRAME FRAME-A        = TRUE.
ASSIGN
       v-pr-list:READ-ONLY IN FRAME FRAME-A        = TRUE.
ASSIGN
       v-pr-notls:READ-ONLY IN FRAME FRAME-A        = TRUE.
ASSIGN
       v-pr-parex:READ-ONLY IN FRAME FRAME-A        = TRUE.
ASSIGN
       v-pr-print:READ-ONLY IN FRAME FRAME-A        = TRUE.
ASSIGN
       v-pr-rdc-q:READ-ONLY IN FRAME FRAME-A        = TRUE.
ASSIGN
       v-pr-rndbs:READ-ONLY IN FRAME FRAME-A        = TRUE.
ASSIGN
       v-pr-rndmt:READ-ONLY IN FRAME FRAME-A        = TRUE.
ASSIGN
       v-pr-sclex:READ-ONLY IN FRAME FRAME-A        = TRUE.
ASSIGN
       v-pr-sigma:READ-ONLY IN FRAME FRAME-A        = TRUE.
ASSIGN
       pr-nogds:READ-ONLY IN FRAME FRAME-B        = TRUE.
ASSIGN
       pr-nogds0:READ-ONLY IN FRAME FRAME-B        = TRUE.
ASSIGN
       scr-nogrp:READ-ONLY IN FRAME FRAME-B        = TRUE.
ASSIGN
       scr-nogrp0:READ-ONLY IN FRAME FRAME-B        = TRUE.
ASSIGN
       v-pr-goods:READ-ONLY IN FRAME FRAME-B        = TRUE.
ASSIGN
       v-pr-goods0:READ-ONLY IN FRAME FRAME-B        = TRUE.
ASSIGN
       v-pr-nogds:READ-ONLY IN FRAME FRAME-B        = TRUE.
ASSIGN
       v-pr-nogds0:READ-ONLY IN FRAME FRAME-B        = TRUE.
ON GO OF FRAME Dialog-Frame
DO:
  run save-proc in this-procedure no-error.
  if error-status :error then return no-apply.
END.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF B-attr-pr-abs-d IN FRAME FRAME-A
DO:
  run gbl/v-taobj.w
      ('overval':U,
       trim(substring("B-attr-pr-abs-d",8,10))
       ).
END.
ON CHOOSE OF B-attr-pr-altex IN FRAME FRAME-A
DO:
  run gbl/v-taobj.w
      ('overval':U,
       trim(substring("B-attr-pr-altex",8,10))
       ).
END.
ON CHOOSE OF B-attr-pr-clt-q IN FRAME FRAME-A
DO:
  run gbl/v-taobj.w
      ('overval':U,
        trim (substring("B-attr-pr-clt-q",8,10))
       ).
END.
ON CHOOSE OF B-attr-pr-discm IN FRAME FRAME-A
DO:
  run gbl/v-taobj.w
      ('overval':U,
        trim (substring("B-attr-pr-discm",8,10))
       ).
END.
ON CHOOSE OF B-attr-pr-dpl-q IN FRAME FRAME-A
DO:
  run gbl/v-taobj.w
      ('overval':U,
        trim (substring("B-attr-pr-dpl-q",8,10))
       ).
END.
ON CHOOSE OF B-attr-pr-dscnt IN FRAME FRAME-A
DO:
  run gbl/v-taobj.w
      ('overval':U,
        trim (substring("B-attr-pr-dscnt",8,10))
       ).
END.
ON CHOOSE OF B-attr-pr-equ-dq IN FRAME FRAME-A
DO:
  run gbl/v-taobj.w
      ('overval':U,
        trim (substring("B-attr-pr-equ-dq",8,10))
       ).
END.
ON CHOOSE OF B-attr-pr-goods IN FRAME FRAME-B
DO:
  run gbl/v-taobj.w
      ('overval':U,
        trim (substring("B-attr-pr-goods",8,10))
       ).
END.
ON CHOOSE OF B-attr-pr-goods0 IN FRAME FRAME-B
DO:
  run gbl/v-taobj.w
      ('overval':U,
        trim (substring("B-attr-pr-goods0",8,10))
       ).
END.
ON CHOOSE OF B-attr-pr-incpc IN FRAME FRAME-A
DO:
  run gbl/v-taobj.w
      ('overval':U,
        trim (substring("B-attr-pr-incpc",8,10))
       ).
END.
ON CHOOSE OF B-attr-pr-list IN FRAME FRAME-A
DO:
  run gbl/v-taobj.w
      ('overval':U,
        trim (substring("B-attr-pr-list",8,10))
       ).
END.
ON CHOOSE OF B-attr-pr-nogds IN FRAME FRAME-B
DO:
  run gbl/v-taobj.w
      ('overval':U,
        trim (substring("B-attr-pr-nogds",8,10))
       ).
END.
ON CHOOSE OF B-attr-pr-nogds0 IN FRAME FRAME-B
DO:
  run gbl/v-taobj.w
      ('overval':U,
        trim (substring("B-attr-pr-nogds0",8,10))
       ).
END.
ON CHOOSE OF B-attr-pr-notls IN FRAME FRAME-A
DO:
  run gbl/v-taobj.w
      ('overval':U,
        trim (substring("B-attr-pr-notls",8,10))
       ).
END.
ON CHOOSE OF B-attr-pr-parex IN FRAME FRAME-A
DO:
  run gbl/v-taobj.w
      ('overval':U,
        trim (substring("B-attr-pr-parex",8,10))
       ).
END.
ON CHOOSE OF B-attr-pr-print IN FRAME FRAME-A
DO:
  run gbl/v-taobj.w
      ('overval':U,
        trim (substring("B-attr-pr-print",8,10))
       ).
END.
ON CHOOSE OF B-attr-pr-rdc-q IN FRAME FRAME-A
DO:
  run gbl/v-taobj.w
      ('overval':U,
        trim (substring("B-attr-pr-rdc-q",8,10))
       ).
END.
ON CHOOSE OF B-attr-pr-rndbs IN FRAME FRAME-A
DO:
  run gbl/v-taobj.w
      ('overval':U,
        trim (substring("B-attr-pr-rndbs",8,10))
       ).
END.
ON CHOOSE OF B-attr-pr-rndmt IN FRAME FRAME-A
DO:
  run gbl/v-taobj.w
      ('overval':U,
        trim (substring("B-attr-pr-rndmt",8,10))
       ).
END.
ON CHOOSE OF B-attr-pr-sclex IN FRAME FRAME-A
DO:
  run gbl/v-taobj.w
      ('overval':U,
       trim(substring("B-attr-pr-sclex",8,10))
       ).
END.
ON CHOOSE OF B-attr-pr-sigma IN FRAME FRAME-A
DO:
  run gbl/v-taobj.w
      ('overval':U,
        trim (substring("B-attr-pr-sigma",8,10))
       ).
END.
ON CHOOSE OF B-corr-pr-list IN FRAME FRAME-A
DO:
    if p-mode <> 'ПРОСМОТР':U and p-obj-type <> "" then do :
    run gbl/v-ta-pr.w ( input 'ПРОСМОТР':U, INPUT-OUTPUT pr-list ) .
  end.
  else do:
    run gbl/v-ta-pr.w ( input p-mode, INPUT-OUTPUT pr-list ) .
  end.
  DISPLAY pr-list WITH FRAME FRAME-A .
END.
ON CHOOSE OF B-corr-pr-nogds IN FRAME FRAME-B
DO:
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
define buffer buf_gds-grp for ub.gds-grp  .
define variable gdsgrp_recids as character no-undo .
define variable ii as integer   no-undo .
define variable nn as integer   no-undo .
assign
  gdsgrp_recids = ""
  nn = num-entries(pr-nogds)
.
repeat ii = 1 to nn :
   find first buf_gds-grp no-lock where
              buf_gds-grp.node-code = integer(entry( ii , pr-nogds )) no-error  .
   if available buf_gds-grp then do:
      gdsgrp_recids = trim(gdsgrp_recids) + string(recid(buf_gds-grp)) + "," .
   end.
end.
run ref/gds-grp.w
  ( input parparentproc
   ,input "b-sel,b-mark"
   ,input v-cntxt-obj-type
   ,input v-cntxt-obj-code
   ,input-output gdsgrp_recids
   ) .
assign
  scr-nogrp = ""
  pr-nogds  = ""
  nn = num-entries(gdsgrp_recids)
.
repeat ii = 1 to nn :
   find first buf_gds-grp no-lock where
              recid(buf_gds-grp) = integer( entry( ii , gdsgrp_recids ))  no-error  .
   if available buf_gds-grp then do:
      assign
        scr-nogrp = scr-nogrp + substitute("&1.&2 &3" , buf_gds-grp.node-code , buf_gds-grp.node-name , chr(10) )
        pr-nogds  = trim(pr-nogds)  + string(buf_gds-grp.node-code)  +  ","
      .
   end.
end.
assign
  pr-nogds  = trim(pr-nogds, ",")
  scr-nogrp = trim(scr-nogrp)
.
DISPLAY pr-nogds scr-nogrp WITH FRAME FRAME-B .
END.
ON CHOOSE OF B-corr-pr-nogds0 IN FRAME FRAME-B
DO:
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define buffer buf_gds-grp for ub.gds-grp  .
define variable gdsgrp_recids as character no-undo .
define variable ii as integer   no-undo .
define variable nn as integer   no-undo .
gdsgrp_recids = "".
nn = num-entries(pr-nogds0).
repeat ii = 1 to nn :
   find first buf_gds-grp no-lock where
              buf_gds-grp.node-code = integer(entry( ii , pr-nogds0 )) no-error  .
   if available buf_gds-grp then do:
      gdsgrp_recids = trim(gdsgrp_recids) + string(recid(buf_gds-grp)) + "," .
   end.
end.
run ref/gds-grp.w
  ( input parparentproc
   ,input "b-sel,b-mark"
   ,input v-cntxt-obj-type
   ,input v-cntxt-obj-code
   ,input-output gdsgrp_recids
   ) .
assign
  scr-nogrp0 = ""
  pr-nogds0  = ""
  nn = num-entries(gdsgrp_recids)
.
repeat ii = 1 to nn :
   find first buf_gds-grp no-lock where
              recid(buf_gds-grp) = integer( entry( ii , gdsgrp_recids ))  no-error  .
   if available buf_gds-grp then do:
      assign
        scr-nogrp0 = scr-nogrp0 + substitute("&1.&2 &3" , buf_gds-grp.node-code , buf_gds-grp.node-name , chr(10) )
        pr-nogds0  = trim(pr-nogds0)  + string(buf_gds-grp.node-code)  +  ","
      .
   end.
end.
assign
  pr-nogds0   = trim(pr-nogds0, ",")
  scr-nogrp0  = trim(scr-nogrp0)
.
DISPLAY pr-nogds0 scr-nogrp0 WITH FRAME FRAME-b .
END.
ON CHOOSE OF b-frame-a IN FRAME Dialog-Frame
DO:
  HIDE FRAME frame-b.
  VIEW FRAME frame-a.
END.
ON CHOOSE OF b-frame-b IN FRAME Dialog-Frame
DO:
  HIDE FRAME frame-a.
  VIEW FRAME frame-b.
END.
ON MOUSE-SELECT-CLICK OF I-pr-abs-d IN FRAME FRAME-A
DO:
  MESSAGE I-pr-abs-d:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-pr-altex IN FRAME FRAME-A
DO:
  MESSAGE I-pr-altex:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-pr-clt-q IN FRAME FRAME-A
DO:
  MESSAGE I-pr-clt-q:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-pr-discm IN FRAME FRAME-A
DO:
  MESSAGE I-pr-discm:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-pr-dpl-q IN FRAME FRAME-A
DO:
  MESSAGE I-pr-dpl-q:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-pr-dscnt IN FRAME FRAME-A
DO:
  MESSAGE I-pr-dscnt:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-pr-equ-dq IN FRAME FRAME-A
DO:
  MESSAGE I-pr-equ-dq:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-pr-goods IN FRAME FRAME-B
DO:
  MESSAGE I-pr-goods:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-pr-goods0 IN FRAME FRAME-B
DO:
  MESSAGE I-pr-goods0:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-pr-incpc IN FRAME FRAME-A
DO:
  MESSAGE I-pr-incpc:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-pr-list IN FRAME FRAME-A
DO:
  MESSAGE I-pr-list:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-pr-nogds IN FRAME FRAME-B
DO:
  MESSAGE I-pr-nogds:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-pr-nogds0 IN FRAME FRAME-B
DO:
  MESSAGE I-pr-nogds0:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-pr-notls IN FRAME FRAME-A
DO:
  MESSAGE I-pr-notls:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-pr-parex IN FRAME FRAME-A
DO:
  MESSAGE I-pr-parex:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-pr-print IN FRAME FRAME-A
DO:
  MESSAGE I-pr-print:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-pr-rdc-q IN FRAME FRAME-A
DO:
  MESSAGE I-pr-rdc-q:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-pr-rndbs IN FRAME FRAME-A
DO:
  MESSAGE I-pr-rndbs:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-pr-rndmt IN FRAME FRAME-A
DO:
  MESSAGE I-pr-rndmt:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-pr-sclex IN FRAME FRAME-A
DO:
  MESSAGE I-pr-sclex:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-pr-sigma IN FRAME FRAME-A
DO:
  MESSAGE I-pr-sigma:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON VALUE-CHANGED OF pr-notls IN FRAME FRAME-A
DO:
  ASSIGN pr-notls.
  IF p-mode <> 'ПРОСМОТР':U THEN DO:
   IF NOT pr-notls THEN DO:
      assign
        pr-parex  = pr-notls
        pr-sclex  = pr-notls
        pr-altex  = pr-notls
      .
      DISPLAY  pr-parex pr-sclex pr-altex WITH FRAME FRAME-A .
      DISABLE pr-parex pr-sclex pr-altex WITH FRAME FRAME-A .
   END.
   ELSE DO:
      ENABLE pr-parex pr-sclex pr-altex WITH FRAME FRAME-A .
   END.
 END.
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
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
if p-obj-type <> "" then
   frame Dialog-Frame:title = frame Dialog-Frame:title + (if p-obj-type = 'орг':U then " фирма" else " маг") + string(p-obj-code) + " " + p-mode  .
define variable loc#log as logical   no-undo .
define variable vss-include-info8 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  g#db-num
    ,input  g#userid
    ,input  0
    ,input  'actn_global-trn_lookup':U
    ,input  'global':U
    ,input  0
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output loc#log
    )  .
end.
  if loc#log <> yes then do: return error. end.
    run enable_UI in THIS-PROCEDURE.
    run init-proc in THIS-PROCEDURE.
    if p-mode = 'ПРОСМОТР':U then do:
      disable B-corr-pr-list
         with  frame frame-a.
      disable
         B-corr-pr-nogds0
         B-corr-pr-nogds
         with  frame frame-b.
    end.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
run disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
  HIDE FRAME FRAME-A.
  HIDE FRAME FRAME-B.
END PROCEDURE.
PROCEDURE enable_UI :
  ENABLE B-exit B-quit b-frame-a b-frame-b B-Help
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  DISPLAY pr-notls pr-altex pr-sclex pr-parex pr-clt-q pr-dpl-q pr-rdc-q
          pr-equ-dq pr-abs-d pr-dscnt pr-print pr-list pr-rndmt pr-rndbs
          pr-incpc pr-discm pr-sigma v-pr-notls v-pr-altex v-pr-sclex v-pr-parex
          v-pr-clt-q v-pr-dpl-q v-pr-rdc-q v-pr-equ-dq v-pr-abs-d v-pr-dscnt
          v-pr-print v-pr-list FILL-IN-2 v-pr-rndmt v-pr-rndbs v-pr-incpc
          v-pr-discm v-pr-sigma
      WITH FRAME FRAME-A.
  ENABLE I-pr-abs-d I-pr-altex I-pr-clt-q I-pr-dpl-q I-pr-dscnt I-pr-equ-dq
         I-pr-notls I-pr-parex I-pr-print I-pr-rdc-q I-pr-discm I-pr-incpc
         I-pr-rndbs I-pr-sigma I-pr-list I-pr-rndmt I-pr-sclex B-attr-pr-notls
         pr-notls B-attr-pr-altex pr-altex B-attr-pr-sclex pr-sclex
         B-attr-pr-parex pr-parex B-attr-pr-clt-q pr-clt-q B-attr-pr-dpl-q
         pr-dpl-q B-attr-pr-rdc-q pr-rdc-q B-attr-pr-equ-dq pr-equ-dq
         B-attr-pr-abs-d pr-abs-d B-attr-pr-dscnt pr-dscnt B-attr-pr-print
         pr-print B-attr-pr-list B-corr-pr-list B-attr-pr-rndmt pr-rndmt
         B-attr-pr-rndbs pr-rndbs B-attr-pr-incpc pr-incpc B-attr-pr-discm
         pr-discm B-attr-pr-sigma pr-sigma v-pr-notls v-pr-altex v-pr-sclex
         v-pr-parex v-pr-clt-q v-pr-dpl-q v-pr-rdc-q v-pr-equ-dq v-pr-abs-d
         v-pr-dscnt v-pr-print v-pr-list FILL-IN-2 v-pr-rndmt v-pr-rndbs
         v-pr-incpc v-pr-discm v-pr-sigma
      WITH FRAME FRAME-A.
  DISPLAY pr-goods0 pr-nogds0 scr-nogrp0 pr-goods pr-nogds scr-nogrp v-pr-goods0
          v-pr-nogds0 v-pr-goods v-pr-nogds
      WITH FRAME FRAME-B.
  ENABLE I-pr-goods I-pr-nogds I-pr-goods0 I-pr-nogds0 B-attr-pr-goods0
         pr-goods0 B-attr-pr-nogds0 pr-nogds0 B-corr-pr-nogds0 scr-nogrp0
         B-attr-pr-goods pr-goods B-attr-pr-nogds pr-nogds B-corr-pr-nogds
         scr-nogrp v-pr-goods0 v-pr-nogds0 v-pr-goods v-pr-nogds
      WITH FRAME FRAME-B.
END PROCEDURE.
PROCEDURE fill-widgets :
define variable v-value-character as character no-undo .
define variable v-value-date      as date      no-undo .
define variable v-value-decimal   as decimal   no-undo .
define variable v-value-integer   as integer   no-undo .
define variable v-value-logical   as logical   no-undo .
define variable v-param-type      as character no-undo .
define variable v-param-value     as character no-undo .
for each thbjattr_thbj-attr:
  delete thbjattr_thbj-attr.
end.
for each thbjattr_thbj-attr-tt:
  delete thbjattr_thbj-attr-tt.
end.
for each temp-thbj-attr:
  delete temp-thbj-attr.
end.
run adm/shattri.p (
    input "get":U
  , input p-obj-type
  , input p-obj-code
  , input 'overval':U
  , input "":U
  , output v-value-character
  , output v-value-date
  , output v-value-decimal
  , output v-value-integer
  , output v-value-logical
  , output v-param-type
  , input-output TABLE thbjattr_thbj-attr-tt
  ) no-error .
if error-status:error then do:
  message
  "Не удалось получить начальные значения настроек" skip
  error-status:get-message(1) return-value
  view-as alert-box error .
  undo, return error .
end.
if p-obj-code <> 0 and p-obj-type <> "" then do:
  find first thbjattr_thbj-attr-tt where thbjattr_thbj-attr-tt.prop-code = 'pr-list':U.
  if available thbjattr_thbj-attr-tt then do:
    delete thbjattr_thbj-attr-tt.
  end.
  pr-list = "Параметр pr-list Глобальный".
  display pr-list WITH FRAME FRAME-A.
  disable B-corr-pr-list
      with  frame frame-a.
end.
FOR EACH thbjattr_thbj-attr-tt where thbjattr_thbj-attr-tt.obj-type  = p-obj-type :
if thbjattr_thbj-attr-tt.prop-code = "pr-abs-d" then do:      pr-abs-d = thbjattr_thbj-attr-tt.property-value-logical.      pr-abs-d:private-data IN FRAME frame-a = "recid2=" + string(recid(thbjattr_thbj-attr-tt)).      display pr-abs-d with frame frame-a .   end.
if thbjattr_thbj-attr-tt.prop-code = "pr-altex" then do:      pr-altex = thbjattr_thbj-attr-tt.property-value-logical.      pr-altex:private-data IN FRAME frame-a = "recid2=" + string(recid(thbjattr_thbj-attr-tt)).      display pr-altex with frame frame-a .   end.
if thbjattr_thbj-attr-tt.prop-code = "pr-clt-q" then do:      pr-clt-q = thbjattr_thbj-attr-tt.property-value-logical.      pr-clt-q:private-data IN FRAME frame-a = "recid2=" + string(recid(thbjattr_thbj-attr-tt)).      display pr-clt-q with frame frame-a .   end.
if thbjattr_thbj-attr-tt.prop-code = "pr-discm" then do:      pr-discm = thbjattr_thbj-attr-tt.property-value-character.      pr-discm:private-data IN FRAME frame-a = "recid2=" + string(recid(thbjattr_thbj-attr-tt)).      display pr-discm with frame frame-a .   end.
if thbjattr_thbj-attr-tt.prop-code = "pr-dpl-q" then do:      pr-dpl-q = thbjattr_thbj-attr-tt.property-value-logical.      pr-dpl-q:private-data IN FRAME frame-a = "recid2=" + string(recid(thbjattr_thbj-attr-tt)).      display pr-dpl-q with frame frame-a .   end.
if thbjattr_thbj-attr-tt.prop-code = "pr-dscnt" then do:      pr-dscnt = thbjattr_thbj-attr-tt.property-value-logical.      pr-dscnt:private-data IN FRAME frame-a = "recid2=" + string(recid(thbjattr_thbj-attr-tt)).      display pr-dscnt with frame frame-a .   end.
if thbjattr_thbj-attr-tt.prop-code = "pr-equ-dq" then do:      pr-equ-dq = thbjattr_thbj-attr-tt.property-value-integer.      pr-equ-dq:private-data IN FRAME frame-a = "recid2=" + string(recid(thbjattr_thbj-attr-tt)).      display pr-equ-dq with frame frame-a .   end.
if thbjattr_thbj-attr-tt.prop-code = "pr-incpc" then do:      pr-incpc = thbjattr_thbj-attr-tt.property-value-decimal.      pr-incpc:private-data IN FRAME frame-a = "recid2=" + string(recid(thbjattr_thbj-attr-tt)).      display pr-incpc with frame frame-a .   end.
if thbjattr_thbj-attr-tt.prop-code = "pr-list" then do:      pr-list = thbjattr_thbj-attr-tt.property-value-character.      pr-list:private-data IN FRAME frame-a = "recid2=" + string(recid(thbjattr_thbj-attr-tt)).      display pr-list with frame frame-a .   end.
if thbjattr_thbj-attr-tt.prop-code = "pr-notls" then do:      pr-notls = thbjattr_thbj-attr-tt.property-value-logical.      pr-notls:private-data IN FRAME frame-a = "recid2=" + string(recid(thbjattr_thbj-attr-tt)).      display pr-notls with frame frame-a .   end.
if thbjattr_thbj-attr-tt.prop-code = "pr-parex" then do:      pr-parex = thbjattr_thbj-attr-tt.property-value-logical.      pr-parex:private-data IN FRAME frame-a = "recid2=" + string(recid(thbjattr_thbj-attr-tt)).      display pr-parex with frame frame-a .   end.
if thbjattr_thbj-attr-tt.prop-code = "pr-print" then do:      pr-print = thbjattr_thbj-attr-tt.property-value-logical.      pr-print:private-data IN FRAME frame-a = "recid2=" + string(recid(thbjattr_thbj-attr-tt)).      display pr-print with frame frame-a .   end.
if thbjattr_thbj-attr-tt.prop-code = "pr-rdc-q" then do:      pr-rdc-q = thbjattr_thbj-attr-tt.property-value-logical.      pr-rdc-q:private-data IN FRAME frame-a = "recid2=" + string(recid(thbjattr_thbj-attr-tt)).      display pr-rdc-q with frame frame-a .   end.
if thbjattr_thbj-attr-tt.prop-code = "pr-rndbs" then do:      pr-rndbs = thbjattr_thbj-attr-tt.property-value-decimal.      pr-rndbs:private-data IN FRAME frame-a = "recid2=" + string(recid(thbjattr_thbj-attr-tt)).      display pr-rndbs with frame frame-a .   end.
if thbjattr_thbj-attr-tt.prop-code = "pr-rndmt" then do:      pr-rndmt = thbjattr_thbj-attr-tt.property-value-character.      pr-rndmt:private-data IN FRAME frame-a = "recid2=" + string(recid(thbjattr_thbj-attr-tt)).      display pr-rndmt with frame frame-a .   end.
if thbjattr_thbj-attr-tt.prop-code = "pr-sclex" then do:      pr-sclex = thbjattr_thbj-attr-tt.property-value-logical.      pr-sclex:private-data IN FRAME frame-a = "recid2=" + string(recid(thbjattr_thbj-attr-tt)).      display pr-sclex with frame frame-a .   end.
if thbjattr_thbj-attr-tt.prop-code = "pr-sigma" then do:      pr-sigma = thbjattr_thbj-attr-tt.property-value-decimal.      pr-sigma:private-data IN FRAME frame-a = "recid2=" + string(recid(thbjattr_thbj-attr-tt)).      display pr-sigma with frame frame-a .   end.
if thbjattr_thbj-attr-tt.prop-code = "pr-goods" then do:      pr-goods = thbjattr_thbj-attr-tt.property-value-character.      pr-goods:private-data IN FRAME frame-b = "recid2=" + string(recid(thbjattr_thbj-attr-tt)).      display pr-goods with frame frame-b .   end.
if thbjattr_thbj-attr-tt.prop-code = "pr-nogds" then do:      pr-nogds = thbjattr_thbj-attr-tt.property-value-character.      pr-nogds:private-data IN FRAME frame-b = "recid2=" + string(recid(thbjattr_thbj-attr-tt)).      display pr-nogds with frame frame-b .   end.
if thbjattr_thbj-attr-tt.prop-code = "pr-goods0" then do:      pr-goods0 = thbjattr_thbj-attr-tt.property-value-character.      pr-goods0:private-data IN FRAME frame-b = "recid2=" + string(recid(thbjattr_thbj-attr-tt)).      display pr-goods0 with frame frame-b .   end.
if thbjattr_thbj-attr-tt.prop-code = "pr-nogds0" then do:      pr-nogds0 = thbjattr_thbj-attr-tt.property-value-character.      pr-nogds0:private-data IN FRAME frame-b = "recid2=" + string(recid(thbjattr_thbj-attr-tt)).      display pr-nogds0 with frame frame-b .   end.
  create temp-thbj-attr.
  buffer-copy thbjattr_thbj-attr-tt to temp-thbj-attr.
END.
define variable nn as integer   no-undo .
define variable ii as integer   no-undo .
define buffer buf_gds-grp for ub.gds-grp  .
scr-nogrp = "" .
nn = num-entries ( pr-nogds ) .
repeat ii = 1 to nn :
   find first buf_gds-grp no-lock where
              buf_gds-grp.node-code = integer(entry( ii , pr-nogds ))  no-error  .
   if available buf_gds-grp then do:
      scr-nogrp = scr-nogrp + substitute( "&1.&2 &3" , buf_gds-grp.node-code , buf_gds-grp.node-name , chr(10) ) .
   end.
end.
scr-nogrp  = trim(scr-nogrp) .
display scr-nogrp with frame frame-b .
scr-nogrp0 = "" .
nn = num-entries ( pr-nogds0 ) .
repeat ii = 1 to nn :
   find first buf_gds-grp no-lock where
              buf_gds-grp.node-code = integer(entry( ii , pr-nogds0 ))  no-error  .
   if available buf_gds-grp then do:
      scr-nogrp0 = scr-nogrp0 + substitute( "&1.&2 &3" , buf_gds-grp.node-code , buf_gds-grp.node-name , chr(10) ) .
   end.
end.
scr-nogrp0  = trim(scr-nogrp0) .
display scr-nogrp0 with frame frame-b .
define variable v-tooltip as character no-undo .
define variable v-label   as character no-undo .
define variable v-tooltip-code as character no-undo .
run thbjattr_tooltip in this-procedure (    input   'overval':U   ,input  "pr-abs-d"   ,output v-tooltip   ,output v-label   ,output v-tooltip-code   ) no-error . v-label =  REPLACE ( v-label , "`" , "," ). v-pr-abs-d:screen-value = entry(2,v-label,":") . v-pr-abs-d = entry(2,v-label,":") . I-pr-abs-d:private-data =  REPLACE ( v-tooltip-code , "`" , "," ).
run thbjattr_tooltip in this-procedure (    input   'overval':U   ,input  "pr-altex"   ,output v-tooltip   ,output v-label   ,output v-tooltip-code   ) no-error . v-label =  REPLACE ( v-label , "`" , "," ). v-pr-altex:screen-value = entry(2,v-label,":") . v-pr-altex = entry(2,v-label,":") . I-pr-altex:private-data =  REPLACE ( v-tooltip-code , "`" , "," ).
run thbjattr_tooltip in this-procedure (    input   'overval':U   ,input  "pr-clt-q"   ,output v-tooltip   ,output v-label   ,output v-tooltip-code   ) no-error . v-label =  REPLACE ( v-label , "`" , "," ). v-pr-clt-q:screen-value = entry(2,v-label,":") . v-pr-clt-q = entry(2,v-label,":") . I-pr-clt-q:private-data =  REPLACE ( v-tooltip-code , "`" , "," ).
run thbjattr_tooltip in this-procedure (    input   'overval':U   ,input  "pr-discm"   ,output v-tooltip   ,output v-label   ,output v-tooltip-code   ) no-error . v-label =  REPLACE ( v-label , "`" , "," ). v-pr-discm:screen-value = entry(2,v-label,":") . v-pr-discm = entry(2,v-label,":") . I-pr-discm:private-data =  REPLACE ( v-tooltip-code , "`" , "," ).
run thbjattr_tooltip in this-procedure (    input   'overval':U   ,input  "pr-dpl-q"   ,output v-tooltip   ,output v-label   ,output v-tooltip-code   ) no-error . v-label =  REPLACE ( v-label , "`" , "," ). v-pr-dpl-q:screen-value = entry(2,v-label,":") . v-pr-dpl-q = entry(2,v-label,":") . I-pr-dpl-q:private-data =  REPLACE ( v-tooltip-code , "`" , "," ).
run thbjattr_tooltip in this-procedure (    input   'overval':U   ,input  "pr-dscnt"   ,output v-tooltip   ,output v-label   ,output v-tooltip-code   ) no-error . v-label =  REPLACE ( v-label , "`" , "," ). v-pr-dscnt:screen-value = entry(2,v-label,":") . v-pr-dscnt = entry(2,v-label,":") . I-pr-dscnt:private-data =  REPLACE ( v-tooltip-code , "`" , "," ).
run thbjattr_tooltip in this-procedure (    input   'overval':U   ,input  "pr-equ-dq"   ,output v-tooltip   ,output v-label   ,output v-tooltip-code   ) no-error . v-label =  REPLACE ( v-label , "`" , "," ). v-pr-equ-dq:screen-value = entry(2,v-label,":") . v-pr-equ-dq = entry(2,v-label,":") . I-pr-equ-dq:private-data =  REPLACE ( v-tooltip-code , "`" , "," ).
run thbjattr_tooltip in this-procedure (    input   'overval':U   ,input  "pr-incpc"   ,output v-tooltip   ,output v-label   ,output v-tooltip-code   ) no-error . v-label =  REPLACE ( v-label , "`" , "," ). v-pr-incpc:screen-value = entry(2,v-label,":") . v-pr-incpc = entry(2,v-label,":") . I-pr-incpc:private-data =  REPLACE ( v-tooltip-code , "`" , "," ).
run thbjattr_tooltip in this-procedure (    input   'overval':U   ,input  "pr-list"   ,output v-tooltip   ,output v-label   ,output v-tooltip-code   ) no-error . v-label =  REPLACE ( v-label , "`" , "," ). v-pr-list:screen-value = entry(2,v-label,":") . v-pr-list = entry(2,v-label,":") . I-pr-list:private-data =  REPLACE ( v-tooltip-code , "`" , "," ).
run thbjattr_tooltip in this-procedure (    input   'overval':U   ,input  "pr-notls"   ,output v-tooltip   ,output v-label   ,output v-tooltip-code   ) no-error . v-label =  REPLACE ( v-label , "`" , "," ). v-pr-notls:screen-value = entry(2,v-label,":") . v-pr-notls = entry(2,v-label,":") . I-pr-notls:private-data =  REPLACE ( v-tooltip-code , "`" , "," ).
run thbjattr_tooltip in this-procedure (    input   'overval':U   ,input  "pr-parex"   ,output v-tooltip   ,output v-label   ,output v-tooltip-code   ) no-error . v-label =  REPLACE ( v-label , "`" , "," ). v-pr-parex:screen-value = entry(2,v-label,":") . v-pr-parex = entry(2,v-label,":") . I-pr-parex:private-data =  REPLACE ( v-tooltip-code , "`" , "," ).
run thbjattr_tooltip in this-procedure (    input   'overval':U   ,input  "pr-print"   ,output v-tooltip   ,output v-label   ,output v-tooltip-code   ) no-error . v-label =  REPLACE ( v-label , "`" , "," ). v-pr-print:screen-value = entry(2,v-label,":") . v-pr-print = entry(2,v-label,":") . I-pr-print:private-data =  REPLACE ( v-tooltip-code , "`" , "," ).
run thbjattr_tooltip in this-procedure (    input   'overval':U   ,input  "pr-rdc-q"   ,output v-tooltip   ,output v-label   ,output v-tooltip-code   ) no-error . v-label =  REPLACE ( v-label , "`" , "," ). v-pr-rdc-q:screen-value = entry(2,v-label,":") . v-pr-rdc-q = entry(2,v-label,":") . I-pr-rdc-q:private-data =  REPLACE ( v-tooltip-code , "`" , "," ).
run thbjattr_tooltip in this-procedure (    input   'overval':U   ,input  "pr-rndbs"   ,output v-tooltip   ,output v-label   ,output v-tooltip-code   ) no-error . v-label =  REPLACE ( v-label , "`" , "," ). v-pr-rndbs:screen-value = entry(2,v-label,":") . v-pr-rndbs = entry(2,v-label,":") . I-pr-rndbs:private-data =  REPLACE ( v-tooltip-code , "`" , "," ).
run thbjattr_tooltip in this-procedure (    input   'overval':U   ,input  "pr-rndmt"   ,output v-tooltip   ,output v-label   ,output v-tooltip-code   ) no-error . v-label =  REPLACE ( v-label , "`" , "," ). v-pr-rndmt:screen-value = entry(2,v-label,":") . v-pr-rndmt = entry(2,v-label,":") . I-pr-rndmt:private-data =  REPLACE ( v-tooltip-code , "`" , "," ).
run thbjattr_tooltip in this-procedure (    input   'overval':U   ,input  "pr-sclex"   ,output v-tooltip   ,output v-label   ,output v-tooltip-code   ) no-error . v-label =  REPLACE ( v-label , "`" , "," ). v-pr-sclex:screen-value = entry(2,v-label,":") . v-pr-sclex = entry(2,v-label,":") . I-pr-sclex:private-data =  REPLACE ( v-tooltip-code , "`" , "," ).
run thbjattr_tooltip in this-procedure (    input   'overval':U   ,input  "pr-sigma"   ,output v-tooltip   ,output v-label   ,output v-tooltip-code   ) no-error . v-label =  REPLACE ( v-label , "`" , "," ). v-pr-sigma:screen-value = entry(2,v-label,":") . v-pr-sigma = entry(2,v-label,":") . I-pr-sigma:private-data =  REPLACE ( v-tooltip-code , "`" , "," ).
run thbjattr_tooltip in this-procedure (    input   'overval':U   ,input  "pr-goods"   ,output v-tooltip   ,output v-label   ,output v-tooltip-code   ) no-error . v-label =  REPLACE ( v-label , "`" , "," ). v-pr-goods:screen-value = entry(2,v-label,":") . v-pr-goods = entry(2,v-label,":") . I-pr-goods:private-data =  REPLACE ( v-tooltip-code , "`" , "," ).
run thbjattr_tooltip in this-procedure (    input   'overval':U   ,input  "pr-nogds"   ,output v-tooltip   ,output v-label   ,output v-tooltip-code   ) no-error . v-label =  REPLACE ( v-label , "`" , "," ). v-pr-nogds:screen-value = entry(2,v-label,":") . v-pr-nogds = entry(2,v-label,":") . I-pr-nogds:private-data =  REPLACE ( v-tooltip-code , "`" , "," ).
run thbjattr_tooltip in this-procedure (    input   'overval':U   ,input  "pr-goods0"   ,output v-tooltip   ,output v-label   ,output v-tooltip-code   ) no-error . v-label =  REPLACE ( v-label , "`" , "," ). v-pr-goods0:screen-value = entry(2,v-label,":") . v-pr-goods0 = entry(2,v-label,":") . I-pr-goods0:private-data =  REPLACE ( v-tooltip-code , "`" , "," ).
run thbjattr_tooltip in this-procedure (    input   'overval':U   ,input  "pr-nogds0"   ,output v-tooltip   ,output v-label   ,output v-tooltip-code   ) no-error . v-label =  REPLACE ( v-label , "`" , "," ). v-pr-nogds0:screen-value = entry(2,v-label,":") . v-pr-nogds0 = entry(2,v-label,":") . I-pr-nogds0:private-data =  REPLACE ( v-tooltip-code , "`" , "," ).
END PROCEDURE.
PROCEDURE init-proc :
define variable v-i               as integer   no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date      as date      no-undo .
define variable v-value-decimal   as decimal   no-undo .
define variable v-value-integer   as integer   no-undo .
define variable v-value-logical   as logical   no-undo .
define variable v-type            as character no-undo .
define variable v-value           as character no-undo .
define variable v-found           as decimal   no-undo .
HIDE FRAME frame-b.
VIEW FRAME frame-a.
  if p-mode = 'ИЗМЕНЕНИЕ':U then do:
    find first buf_thbj-attr exclusive-lock where
              buf_thbj-attr.obj-type = p-obj-type
        and   buf_thbj-attr.obj-code = p-obj-code
        and   buf_thbj-attr.upper-prop-code = 'overval':U
        and   buf_thbj-attr.prop-code = '':u no-wait no-error.
     if locked buf_thbj-attr then do:
        message
        vss-workfile vss-revision vss-description skip
        'overval':U skip
        "Запись Глобальных ПАРАМЕТРОВ  занята"
        view-as alert-box error .
        undo, return error.
      end.
  end.
  else do:
    find first buf_thbj-attr no-lock where
          buf_thbj-attr.obj-type = p-obj-type
    and   buf_thbj-attr.obj-code = p-obj-code
    and   buf_thbj-attr.upper-prop-code = 'overval':U
    and   buf_thbj-attr.prop-code = '':u no-error.
  end.
  if not available buf_thbj-attr then do:
    assign
      v-to-create-trn  = true
      .
    message
    substitute ("Внимание!!!&1 Параметра НЕТ в БД!&1Будут показаны ЗНАЧЕНИЯ ПО УМОЛЧАНИЮ",
                chr(10))
                 view-as alert-box warning.
  end.
  run fill-widgets in this-procedure no-error.
  if error-status:error then undo, return error.
  if p-mode <> 'ИЗМЕНЕНИЕ':U then do:
     disable
    pr-abs-d
    pr-altex
    pr-clt-q
    pr-discm
    pr-dpl-q
    pr-dscnt
    pr-equ-dq
    pr-incpc
    pr-list
    pr-notls
    pr-parex
    pr-print
    pr-rdc-q
    pr-rndbs
    pr-rndmt
    pr-sclex
    pr-sigma
  with frame frame-a.
  disable
    pr-goods
    pr-nogds
    pr-goods0
    pr-nogds0
  with frame frame-b.
     B-exit:label in frame Dialog-Frame = "Вы&ход"  .
     hide B-quit in frame Dialog-Frame .
  END.
  IF p-mode <> 'ПРОСМОТР':U THEN DO:
   IF NOT pr-notls THEN DO:
      DISPLAY  pr-parex pr-sclex pr-altex WITH FRAME FRAME-a .
      DISABLE pr-parex pr-sclex pr-altex WITH FRAME FRAME-a .
   END.
 END.
end procedure.
PROCEDURE save-proc :
define variable v-value-character as character no-undo .
define variable v-value-date      as date      no-undo .
define variable v-value-decimal   as decimal   no-undo .
define variable v-value-integer   as integer   no-undo .
define variable v-value-logical   as logical   no-undo .
define variable v-sale-add        as character no-undo .
define variable v-same            as logical   no-undo .
define variable v-param-type      as character no-undo .
define variable v-trf-type like ub.clients.obj-type no-undo .
define variable v-trf-code like ub.clients.obj-code no-undo .
define variable wh as widget-handle no-undo .
define variable fh as widget-handle no-undo .
IF p-mode = 'ПРОСМОТР':U THEN RETURN .
define variable loc#log           as logical   no-undo .
define variable vss-include-info9 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  g#db-num
    ,input  g#userid
    ,input  0
    ,input  'actn_global-trn_update':U
    ,input  'global':U
    ,input  0
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output loc#log
    )  .
end.
  if loc#log <> yes then do: return error. end.
ASSIGN
    pr-abs-d FRAME FRAME-a
    pr-altex
    pr-clt-q
    pr-discm
    pr-dpl-q
    pr-dscnt
    pr-equ-dq
    pr-incpc
    pr-list
    pr-notls
    pr-parex
    pr-print
    pr-rdc-q
    pr-rndbs
    pr-rndmt
    pr-sclex
    pr-sigma
    .
ASSIGN
    pr-goods FRAME FRAME-b
    pr-nogds
    pr-goods0
    pr-nogds0
    .
assign
  fh = frame frame-a:first-child
  wh = fh:first-child
  .
do while valid-handle(wh):
  if wh:private-data begins "recid2=" then do:
    find first thbjattr_thbj-attr-tt where
              recid(thbjattr_thbj-attr-tt) = integer(entry(2, wh:private-data, '=')) exclusive-lock.
    assign
      buffer thbjattr_thbj-attr-tt:buffer-field("property-value-" + wh:data-type):buffer-value = wh:input-value
      thbjattr_thbj-attr-tt.obj-type = p-obj-type
      thbjattr_thbj-attr-tt.obj-code = p-obj-code
    .
  end.
  wh = wh:next-sibling.
end.
assign
  fh = frame frame-b:first-child
  wh = fh:first-child
  .
do while valid-handle(wh):
  if wh:private-data begins "recid2=" then do:
    find first thbjattr_thbj-attr-tt where
              recid(thbjattr_thbj-attr-tt) = integer(entry(2, wh:private-data, '=')).
    assign
      buffer thbjattr_thbj-attr-tt:buffer-field("property-value-" + wh:data-type):buffer-value = wh:input-value
      thbjattr_thbj-attr-tt.obj-type = p-obj-type
      thbjattr_thbj-attr-tt.obj-code = p-obj-code
    .
  end.
  wh = wh:next-sibling.
end.
v-same = yes.
for each thbjattr_thbj-attr-tt,
    first temp-thbj-attr where
          temp-thbj-attr.obj-type         = thbjattr_thbj-attr-tt.obj-type
      and temp-thbj-attr.obj-code         = thbjattr_thbj-attr-tt.obj-code
      and temp-thbj-attr.upper-prop-code  = thbjattr_thbj-attr-tt.upper-prop-code
      and temp-thbj-attr.prop-code        = thbjattr_thbj-attr-tt.prop-code
      :
   buffer-compare
   thbjattr_thbj-attr-tt
   to temp-thbj-attr
   save result in v-same.
   if not v-same then leave.
end.
v-same = no.
IF v-same  and not v-to-create THEN RETURN.
do TRANSACTION
on error undo, return error return-value
:
  run thbjattr_set-section in this-procedure (
        input p-obj-type
      , input p-obj-code
      , input 'overval':U
      , input table thbjattr_thbj-attr-tt
  ) no-error.
  if error-status:error then do:
    message error-status:get-message(1)  skip
    return-value
    view-as alert-box.
    undo, return error.
  end.
end.
END PROCEDURE.
