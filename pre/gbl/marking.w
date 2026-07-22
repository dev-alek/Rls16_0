DEFINE TEMP-TABLE type-marking NO-UNDO
  field mark-orig       as character
  field mark-type       as character
  field EDO             as logical
  field mark            as logical
  field artic           as logical
  field transitional    as logical
  field blockCashUnMark as logical
  field saleReturn      as logical
  field saleUPD         as logical
  field onlySale        as logical
  field checkBlock      as logical
  field checkDate       as logical
  field checkMRC        as logical
  field checkOwner      as logical
  field checkStatusKM   as logical
  field checkTracking   as logical
  index mark-type mark-type
  .
define input parameter parparentproc as widget-handle no-undo.
define input parameter p-mode     as character no-undo.
define input parameter p-obj-type like ub.clients.obj-type no-undo.
define input parameter p-obj-code like ub.clients.obj-code no-undo.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-Workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Редактирование секции параметры для для Электронный документооборот" .
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
DEF VAR BLACK_COLOR        AS INTEGER NO-UNDO INIT  0.
DEF VAR DARK_BLUE_COLOR    AS INTEGER NO-UNDO INIT  1.
DEF VAR DARK_GREEN_COLOR   AS INTEGER NO-UNDO INIT  2.
DEF VAR CYAN_COLOR         AS INTEGER NO-UNDO INIT  3.
DEF VAR BROWN_COLOR        AS INTEGER NO-UNDO INIT  4.
DEF VAR DARK_GRAY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR DARK_GREY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR VERY_GRAY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR VERY_GREY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR GRAY_COLOR         AS INTEGER NO-UNDO INIT  8.
DEF VAR GREY_COLOR         AS INTEGER NO-UNDO INIT  8.
DEF VAR BLUE_COLOR         AS INTEGER NO-UNDO INIT  9.
DEF VAR GREEN_COLOR        AS INTEGER NO-UNDO INIT 10.
DEF VAR RED_COLOR          AS INTEGER NO-UNDO INIT 12.
DEF VAR LIGHT_RED_COLOR    AS INTEGER NO-UNDO INIT 13.
DEF VAR YELLOW_COLOR       AS INTEGER NO-UNDO INIT 14.
DEF VAR WHITE_COLOR        AS INTEGER NO-UNDO INIT 15.
def var objSrv as class ibs.th.gbl.sys.objsrv no-undo.
run gbl/getobjsrvhndl.p (input-output ObjSrv).
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEFINE new shared TEMP-TABLE thbjattr-list no-undo like ub.thbj-attr .
define variable Types as ibs.th.str.marking.Types no-undo.
Types = ObjSrv:Env:Marking:Types.
define temp-table temp-thbj-attr no-undo like ub.thbj-attr.
define variable v-tth     as handle no-undo .
define variable v-tth-host as handle no-undo .
define variable v-to-create-host as logical no-undo.
define variable str-attr as character no-undo .
define variable S-type-EDO as character no-undo .
define variable S-type-artic as character no-undo .
define variable S-type-transitional as character no-undo .
define variable S-type-saleReturn      as character no-undo .
define variable S-type-checkBlock      as character no-undo .
define variable S-type-checkDate       as character no-undo .
define variable S-type-checkMRC        as character no-undo .
define variable S-type-checkOwner      as character no-undo .
define variable S-type-checkStatusKM   as character no-undo .
define variable S-type-checkTracking   as character no-undo .
assign
v-tth      = buffer temp-thbj-attr:table-handle .
FUNCTION isArticAvail RETURNS LOGICAL
  (  )  FORWARD.
FUNCTION isMarkAZKAvail RETURNS LOGICAL
  (  )  FORWARD.
FUNCTION isMarkVnAvail RETURNS LOGICAL
  (  )  FORWARD.
FUNCTION isTransitionalAvail RETURNS LOGICAL
  (  )  FORWARD.
FUNCTION isblockCashUnMarkAvail RETURNS LOGICAL
  (  )  FORWARD.
FUNCTION issaleReturnAvail RETURNS LOGICAL
  (  )  FORWARD.
FUNCTION issaleUPDAvail RETURNS LOGICAL
  (  )  FORWARD.
FUNCTION isonlySaleAvail RETURNS LOGICAL
  (  )  FORWARD.
FUNCTION ischeckBlockAvail RETURNS LOGICAL
  (  )  FORWARD.
FUNCTION ischeckDateAvail RETURNS LOGICAL
  (  )  FORWARD.
FUNCTION ischeckMRCAvail RETURNS LOGICAL
  (  )  FORWARD.
FUNCTION ischeckOwnerAvail RETURNS LOGICAL
  (  )  FORWARD.
FUNCTION ischeckStatusKMAvail RETURNS LOGICAL
  (  )  FORWARD.
FUNCTION ischeckTrackingAvail RETURNS LOGICAL
  (  )  FORWARD.
DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1.
DEFINE BUTTON B-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1.
DEFINE VARIABLE cb-gray_zone_qnty AS INTEGER FORMAT "->>9":U INITIAL 0
     LABEL "Допустимое отсутствие КМ для ~"Серой зоны~""
     VIEW-AS COMBO-BOX INNER-LINES 6
     LIST-ITEMS "0" ,
     "1",
     "2",
     "3",
     "4",
     "5",
     "6",
     "7",
     "8",
     "9",
     "10",
     "100"
     DROP-DOWN-LIST
     SIZE 27.75 BY 1 NO-UNDO.
DEFINE VARIABLE t-ban-altr AS LOGICAL INITIAL no
     LABEL "Использования рецепта Альтернатива только для получения ингредиентов"
     VIEW-AS TOGGLE-BOX
     SIZE 74.75 BY .83 NO-UNDO.
DEFINE VARIABLE t-ban_recipes AS LOGICAL INITIAL no
     LABEL "Запрет на создание рецептов и маркетинговых акций"
     VIEW-AS TOGGLE-BOX
     SIZE 79.25 BY .83 NO-UNDO.
DEFINE VARIABLE t-bar-code AS LOGICAL INITIAL no
     LABEL "Определение товара по штрих-коду"
     VIEW-AS TOGGLE-BOX
     SIZE 74.75 BY .83 NO-UNDO.
DEFINE VARIABLE t-rus-key AS LOGICAL INITIAL no
     LABEL "Автоматическое переключение раскладки на русский"
     VIEW-AS TOGGLE-BOX
     SIZE 74.75 BY .83 NO-UNDO.
DEFINE VARIABLE t-edo AS LOGICAL INITIAL no
     LABEL "Включена работа с ЭДО для маркированных документов"
     VIEW-AS TOGGLE-BOX
     SIZE 60 BY .83 NO-UNDO.
DEFINE VARIABLE t-edo-NotMark AS LOGICAL INITIAL no
     LABEL "Включена работа с ЭДО для не маркированных документов"
     VIEW-AS TOGGLE-BOX
     SIZE 60 BY .83 NO-UNDO.
DEFINE VARIABLE t-manual AS LOGICAL INITIAL no
     LABEL "Ручной ввод марок"
     VIEW-AS TOGGLE-BOX
     SIZE 30.5 BY .83 NO-UNDO.
DEFINE QUERY br_marking-type FOR
      type-marking SCROLLING.
DEFINE BROWSE br_marking-type
  QUERY br_marking-type NO-LOCK DISPLAY
  type-marking.mark-type COLUMN-LABEL "Тип!маркировки" LABEL-BGCOLOR 8 FORMAT "X(35)":U
  type-marking.EDO column-label "Поэкземплярный!учет" LABEL-BGCOLOR 8 FORMAT "yes/no":U view-as toggle-box
  type-marking.artic column-label "Объемно-!артикульный!учет" LABEL-BGCOLOR 8 FORMAT "yes/no":U
  view-as toggle-box
  type-marking.transitional column-label "Переходный!период" LABEL-BGCOLOR 8 FORMAT "yes/no":U view-as toggle-box
  type-marking.saleReturn column-label "Разрешена!продажа!возвращенных!товаров" LABEL-BGCOLOR 8 FORMAT "yes/no":U view-as toggle-box
  type-marking.checkBlock column-label "Проверка!блокировок!контрол.!органов" LABEL-BGCOLOR 8 FORMAT "yes/no":U view-as toggle-box
  type-marking.checkDate column-label "Проверка!срока!годности" LABEL-BGCOLOR 8 FORMAT "yes/no":U view-as toggle-box
  type-marking.checkMRC column-label "Проверка!МРЦ" LABEL-BGCOLOR 8 FORMAT "yes/no":U view-as toggle-box
  type-marking.checkOwner column-label "Проверка!владельцев" LABEL-BGCOLOR 8 FORMAT "yes/no":U view-as toggle-box
  type-marking.checkStatusKM column-label "Проверка!статуса КМ" LABEL-BGCOLOR 8 FORMAT "yes/no":U view-as toggle-box
  type-marking.checkTracking column-label "Проверка!прослежи-!ваемости" LABEL-BGCOLOR 8 FORMAT "yes/no":U view-as toggle-box
  ENABLE
      type-marking.EDO
      type-marking.artic
      type-marking.transitional
      type-marking.checkBlock
      type-marking.checkDate
      type-marking.checkMRC
      type-marking.checkOwner
      type-marking.checkStatusKM
      type-marking.checkTracking
      type-marking.saleReturn
    WITH NO-ROW-MARKERS SEPARATORS SIZE 107 BY 12.42 .
DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     B-quit AT ROW 1 COL 11
     t-edo AT ROW 2 COL 5.75 WIDGET-ID 142
     t-edo-NotMark AT ROW 3 COL 5.75 WIDGET-ID 164
     t-manual AT ROW 3.88 COL 5.75 WIDGET-ID 148
     t-ban_recipes AT ROW 4.92 COL 5.75 WIDGET-ID 156
     t-ban-altr AT ROW 6.63 COL 5.75 WIDGET-ID 160
     t-bar-code AT ROW 7.79 COL 5.75 WIDGET-ID 162
     t-rus-key AT ROW 8.79 COL 5.75 WIDGET-ID 162
     cb-gray_zone_qnty AT ROW 10.08 COL 49.38 COLON-ALIGNED WIDGET-ID 150
     br_marking-type AT ROW 13.08 COL 2 WIDGET-ID 200
     "с маркированными товарами" VIEW-AS TEXT
          SIZE 33 BY .67 AT ROW 5.75 COL 8 WIDGET-ID 158
     SPACE(68.24) SKIP(19.24)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Настройки для Электронного документооборота"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON B-quit WIDGET-ID 100.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
define variable v-diasize-need-maximize        as logical   no-undo init true  .
define variable v-diasize-orig-frame-height    as decimal   no-undo .
define variable v-diasize-orig-frame-width     as decimal   no-undo .
define variable v-diasize-current-frame-width  as decimal   no-undo .
define variable v-diasize-current-frame-height as decimal   no-undo .
define variable v-diasize-change-size          as logical   no-undo .
define variable v-diasize-resize-button        as handle    no-undo .
define variable v-diasize-wndmax               as logical   no-undo .
define variable v-diasize-wndstore             as logical   no-undo .
define variable v-diasize-proc-name            as character no-undo .
define variable v-diasize-browse-handle        as handle    no-undo .
define variable v-diasize-browse-number        as integer   no-undo .
define variable v-diasize-need-full-display    as logical   no-undo init false .
define temp-table temp-diasize-handle no-undo
  field handle-value  as handle
  field save-position as decimal
  index xpk is primary unique handle-value
  .
define temp-table temp-browse-handle no-undo
  field browse-type   as character
  field browse-number as integer
  field browse-handle as handle
  field original-size as decimal
  index xpk is primary unique browse-type browse-number
  index xie browse-type browse-handle
.
procedure diasize_change-height :
  define input  parameter p-change-value  as decimal   no-undo .
  define input  parameter p-move-resize   as logical   no-undo .
  define variable v-field-group-handle    as handle    no-undo .
  define variable v-object-handle         as handle    no-undo .
  define variable v-frame-height          as decimal   no-undo .
  define variable v-frame-virtual-height  as decimal   no-undo .
  define variable v-browse-height         as decimal   no-undo .
  define variable v-window-height         as decimal   no-undo .
  define variable v-window-virtual-height as decimal   no-undo .
  define variable v-change-sign           as integer   no-undo .
  define buffer buf_temp-diasize-handle for temp-diasize-handle .
  define buffer buf_temp-browse-handle  for temp-browse-handle .
  if p-change-value > 0
  then do:
    if frame Dialog-Frame :height + p-change-value
        > decimal(session :work-area-height-pixels) / session :pixels-per-row
    then do:
      assign
        p-change-value = decimal(session :work-area-height-pixels) / session :pixels-per-row
                        - (frame Dialog-Frame :height-chars)
      .
      if p-change-value <= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value < 0
  then do:
    if frame Dialog-Frame :height + p-change-value < v-diasize-orig-frame-height
    then do:
      assign
        p-change-value = v-diasize-orig-frame-height
                       - (frame Dialog-Frame :height-chars)
      .
      if p-change-value >= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value >= 0
  then do:
    assign
      v-change-sign = 1
    .
  end.
  else do:
    assign
      v-change-sign = -1
    .
  end.
  assign
    p-change-value = truncate(abs(p-change-value), 0) * v-change-sign
  .
  if p-change-value = 0
  then do:
    run diasize_position-resize-button in this-procedure .
    return .
  end.
  move_block:
  do
  on error undo move_block, retry move_block
  :
    if retry
    then do:
      do
      on error undo move_block, leave move_block
      :
        if p-change-value > 0
        then do:
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :row = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          assign
            v-diasize-browse-handle :height = v-browse-height
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'height':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :height = buf_temp-browse-handle.original-size
            .
          end.
          assign
            frame Dialog-Frame :height = v-frame-height
          .
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-height = v-frame-virtual-height
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-height = v-frame-virtual-height
            .
          end.
          assign
            frame Dialog-Frame :height = v-frame-height
          .
          assign
            v-diasize-browse-handle :height = v-browse-height
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'height':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :height = buf_temp-browse-handle.original-size
            .
          end.
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :row = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        assign
          v-diasize-change-size = false
        .
        leave move_block .
      end.
    end.
    assign
      v-diasize-need-full-display = true
    .
    if v-diasize-change-size = false
    then do:
      assign
        v-diasize-change-size = true
      .
    end.
    else do:
      return .
    end.
    assign
      v-frame-height = frame Dialog-Frame :height
      v-frame-virtual-height = frame Dialog-Frame :virtual-height
      v-browse-height = v-diasize-browse-handle :height
    .
    for each buf_temp-browse-handle
      where buf_temp-browse-handle.browse-type = 'height':u
    :
      assign
        buf_temp-browse-handle.original-size = buf_temp-browse-handle.browse-handle :height
      .
    end.
    for each buf_temp-diasize-handle
    :
      delete buf_temp-diasize-handle .
    end.
    assign
      v-field-group-handle = frame Dialog-Frame :first-child
    .
    do while valid-handle(v-field-group-handle)
    :
      assign
        v-object-handle = v-field-group-handle :first-child
      .
      do while valid-handle(v-object-handle)
      :
        if  v-object-handle <> v-diasize-browse-handle :handle
        and can-query(v-object-handle, "row")
        and can-query(v-object-handle, "height")
        and ( v-object-handle :row > v-diasize-browse-handle :row )
        then do:
          find first buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type   = 'height':u
              and buf_temp-browse-handle.browse-handle = v-object-handle
            no-error .
          if available buf_temp-browse-handle
          then do:
          end.
          else do:
            create buf_temp-diasize-handle .
            assign
              buf_temp-diasize-handle.handle-value  = v-object-handle
              buf_temp-diasize-handle.save-position = v-object-handle :row
            .
          end.
        end.
        assign
          v-object-handle = v-object-handle :next-sibling
        .
      end.
      assign
        v-field-group-handle = v-field-group-handle :next-sibling
      .
    end.
    do with frame Dialog-Frame
    :
      hide v-diasize-resize-button .
      assign
        v-diasize-resize-button :row    = 1
        v-diasize-resize-button :column = 1
      .
    end.
    if p-change-value > 0
    then do:
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-height = frame Dialog-Frame :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame Dialog-Frame :height = frame Dialog-Frame :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      assign
        v-diasize-browse-handle :height = v-diasize-browse-handle :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'height':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :height
            = buf_temp-browse-handle.browse-handle :height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :row = v-object-handle :row + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
    end.
    else do:
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :row = v-object-handle :row + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
      assign
        v-diasize-browse-handle :height = v-diasize-browse-handle :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'height':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :height
            = buf_temp-browse-handle.browse-handle :height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame Dialog-Frame :height = frame Dialog-Frame :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-height = frame Dialog-Frame :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
    end.
    if p-move-resize = true
    then do:
      run diasize_position-resize-button in this-procedure .
    end.
    if v-diasize-wndstore = true
    then do:
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndsizew.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  v-diasize-proc-name
          ,input  'height':u
          ,input  string(frame Dialog-Frame :height - v-diasize-orig-frame-height)
          ) .
      end.
    end.
  end.
  assign
    v-diasize-change-size = false
  .
end procedure.
procedure diasize_set-height :
  define input  parameter p-new-height  as decimal   no-undo .
  define input  parameter p-move-resize as logical   no-undo .
  do
  on error undo, return error return-value
  :
    run diasize_change-height in this-procedure
      (input  (p-new-height - frame Dialog-Frame :height)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_change-width :
  define input  parameter p-change-value as decimal   no-undo .
  define input  parameter p-move-resize  as logical   no-undo .
  define variable v-field-group-handle   as handle    no-undo .
  define variable v-object-handle        as handle    no-undo .
  define variable v-frame-width          as decimal   no-undo .
  define variable v-frame-virtual-width  as decimal   no-undo .
  define variable v-browse-width         as decimal   no-undo .
  define variable v-window-width         as decimal   no-undo .
  define variable v-window-virtual-width as decimal   no-undo .
  define variable v-change-sign          as integer   no-undo .
  define buffer buf_temp-diasize-handle for temp-diasize-handle .
  define buffer buf_temp-browse-handle  for temp-browse-handle .
  if p-change-value > 0
  then do:
    if frame Dialog-Frame :width + p-change-value >
        session :width-chars
    then do:
      assign
        p-change-value = session :width-chars - frame Dialog-Frame :width
      .
      if p-change-value <= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value < 0
  then do:
    if frame Dialog-Frame :width + p-change-value < v-diasize-orig-frame-width
    then do:
      assign
        p-change-value = v-diasize-orig-frame-width
                       - frame Dialog-Frame :width
      .
      if p-change-value >= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value >= 0
  then do:
    assign
      v-change-sign = 1
    .
  end.
  else do:
    assign
      v-change-sign = -1
    .
  end.
  assign
    p-change-value = truncate(abs(p-change-value), 0) * v-change-sign
  .
  if p-change-value = 0
  then do:
    run diasize_position-resize-button in this-procedure .
    return .
  end.
  move_block:
  do
  on error undo move_block, leave move_block
  :
    if retry
    then do:
      do
      on error undo move_block, leave move_block
      :
        if p-change-value > 0
        then do:
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :col = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          assign
            v-diasize-browse-handle :width = v-browse-width
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'width':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :width = buf_temp-browse-handle.original-size
            .
          end.
          assign
            frame Dialog-Frame :width = v-frame-width
          .
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-width = v-frame-virtual-width
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-width = v-frame-virtual-width
            .
          end.
          assign
            frame Dialog-Frame :width = v-frame-width
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'width':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :width = buf_temp-browse-handle.original-size
            .
          end.
          assign
            v-diasize-browse-handle :width = v-browse-width
          .
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :col = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        assign
          v-diasize-change-size = false
        .
        leave move_block .
      end.
    end.
    assign
      v-diasize-need-full-display = true
    .
    if v-diasize-change-size = false
    then do:
      assign
        v-diasize-change-size = true
      .
    end.
    else do:
      return .
    end.
    assign
      v-frame-width = frame Dialog-Frame :width
      v-frame-virtual-width = frame Dialog-Frame :virtual-width
      v-browse-width = v-diasize-browse-handle :width
    .
    for each buf_temp-browse-handle
      where buf_temp-browse-handle.browse-type = 'width':u
    :
      assign
        buf_temp-browse-handle.original-size = buf_temp-browse-handle.browse-handle :width
      .
    end.
    for each buf_temp-diasize-handle
    :
      delete buf_temp-diasize-handle .
    end.
    assign
      v-field-group-handle = frame Dialog-Frame :first-child
    .
    do while valid-handle(v-field-group-handle)
    :
      assign
        v-object-handle = v-field-group-handle :first-child
      .
      do while valid-handle(v-object-handle)
      :
        if  v-object-handle <> v-diasize-browse-handle :handle
        and v-object-handle <> v-diasize-resize-button
        and can-query(v-object-handle, "row")
        and can-query(v-object-handle, "height")
        and ( v-object-handle :col + v-object-handle :width
              > v-diasize-browse-handle :col + v-diasize-browse-handle :width
            )
        then do:
          find first buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type   = 'width':u
              and buf_temp-browse-handle.browse-handle = v-object-handle
            no-error .
          if available buf_temp-browse-handle
          then do:
          end.
          else do:
            create buf_temp-diasize-handle .
            assign
              buf_temp-diasize-handle.handle-value  = v-object-handle
              buf_temp-diasize-handle.save-position = v-object-handle :col
            .
          end.
        end.
        assign
          v-object-handle = v-object-handle :next-sibling
        .
      end.
      assign
        v-field-group-handle = v-field-group-handle :next-sibling
      .
    end.
    do with frame Dialog-Frame
    :
      hide v-diasize-resize-button .
      v-diasize-resize-button :row = 1.
      v-diasize-resize-button :column = 1.
    end.
    if p-change-value > 0
    then do:
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-width = frame Dialog-Frame :virtual-width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
      assign
        frame Dialog-Frame :width = v-frame-width + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      assign
        v-diasize-browse-handle :width = v-browse-width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'width':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :width
            = buf_temp-browse-handle.browse-handle :width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :col = v-object-handle :col + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
    end.
    else do:
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :col = v-object-handle :col + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'width':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :width
            = buf_temp-browse-handle.browse-handle :width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        v-diasize-browse-handle :width = v-diasize-browse-handle :width + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      assign
        frame Dialog-Frame :width = frame Dialog-Frame :width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-width = frame Dialog-Frame :virtual-width + p-change-value
        no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
    end.
    if p-move-resize
    then do:
      run diasize_position-resize-button in this-procedure .
    end.
    if v-diasize-wndstore = true
    then do:
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndsizew.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  v-diasize-proc-name
          ,input  'width':u
          ,input  string(frame Dialog-Frame :width - v-diasize-orig-frame-width)
          ) .
      end.
    end.
  end.
  assign
    v-diasize-change-size = false
  .
end procedure.
procedure diasize_set-width :
  define input  parameter p-new-width  as decimal   no-undo .
  define input  parameter p-move-resize as logical   no-undo .
  do
  on error undo, return error return-value
  :
    run diasize_change-width in this-procedure
      (input  (p-new-width - frame Dialog-Frame :width)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_position-resize-button :
  do with frame Dialog-Frame
  :
    hide v-diasize-resize-button .
    assign
      v-diasize-resize-button :row = frame Dialog-Frame :height - v-diasize-resize-button :height
                  - 1
                  - (frame Dialog-Frame :border-bottom-pixels / session :pixels-per-row)
      v-diasize-resize-button :col = frame Dialog-Frame :width - v-diasize-resize-button :width
                  - 1
                  - (frame Dialog-Frame :border-right-pixels / session :pixels-per-column)
    .
    view v-diasize-resize-button .
  end.
end procedure.
on alt-right anywhere
do:
  run diasize_change-width in this-procedure
    (input 1
    ,input true
    ) .
  return no-apply .
end.
on alt-left anywhere
do:
  run diasize_change-width in this-procedure
    (input -1
    ,input true
    ) .
  return no-apply .
end.
on alt-down anywhere
do:
  run diasize_change-height in this-procedure
    (input 1
    ,input true
    ) .
  return no-apply .
end.
on alt-up anywhere
do:
  run diasize_change-height in this-procedure
    (input -1
    ,input true
    ) .
  return no-apply .
end.
on alt-enter of frame Dialog-Frame
do:
  run diasize_maximize in this-procedure
    (input  ?
    ).
  return no-apply .
end.
procedure diasize_end-move :
  do
  on error undo, return error return-value
  :
    define variable v-row-delta as decimal   no-undo .
    define variable v-col-delta as decimal   no-undo .
    define variable v-new-row as decimal   no-undo .
    define variable v-new-col as decimal   no-undo .
    assign
      v-new-row = decimal(last-event :y) / (session :pixels-per-row)
      v-new-col = decimal(last-event :x) / (session :pixels-per-column)
    .
    assign
      v-row-delta = v-new-row - frame Dialog-Frame :height
      v-col-delta = v-new-col - frame Dialog-Frame :width
    .
    run diasize_change-height in this-procedure
      (input v-row-delta
      ,input true
      ) .
    run diasize_change-width in this-procedure
      (input v-col-delta
      ,input true
      ) .
  end.
end procedure.
procedure diasize_maximize :
  define input  parameter p-action as logical   no-undo .
  do
  on error undo, return error return-value
  :
    if p-action = ?
    then do:
      if v-diasize-need-maximize = true
      then do:
        assign
          p-action = true
        .
      end.
      else do:
        assign
          p-action = false
        .
      end.
    end.
    if p-action = true
    then do:
      run diasize_change-height in this-procedure
        (input decimal(session :work-area-height-pixels) / session :pixels-per-row
            - frame Dialog-Frame :height-chars
        ,input true
        ) .
      run diasize_change-width in this-procedure
        (input session :width-chars
            - frame Dialog-Frame :width-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = false
      .
    end.
    else do:
      run diasize_change-width in this-procedure
        (input v-diasize-orig-frame-width
            - frame Dialog-Frame :width-chars
        ,input true
        ) .
      run diasize_change-height in this-procedure
        (input v-diasize-orig-frame-height
            - frame Dialog-Frame :height-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = true
      .
    end.
  end.
end procedure.
procedure diasize_restore-orig-size :
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-current-frame-width  = frame Dialog-Frame :width
      v-diasize-current-frame-height = frame Dialog-Frame :height
    .
    run diasize_set-height in this-procedure
      (input  v-diasize-orig-frame-height
      ,input  true
      ) .
    run diasize_set-width in this-procedure
      (input  v-diasize-orig-frame-width
      ,input  true
      ) .
  end.
end procedure.
procedure diasize_restore-current-size :
  do
  on error undo, return error return-value
  :
    run diasize_set-height in this-procedure
      (input  v-diasize-current-frame-height
      ,input  true
      ) .
    run diasize_set-width in this-procedure
      (input  v-diasize-current-frame-width
      ,input  true
      ) .
  end.
end procedure.
procedure diasize_set-browse-handle :
  define input  parameter p-browse-handle as handle   no-undo .
  define buffer buf_temp-browse-handle for temp-browse-handle .
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-browse-handle = p-browse-handle
    .
    for each buf_temp-browse-handle
    on error undo, return error return-value
    :
      delete buf_temp-browse-handle .
    end.
  end.
end procedure.
procedure diasize_add_browse :
  define input  parameter p-browse-type   as character no-undo .
  define input  parameter p-browse-handle as handle    no-undo .
  define buffer buf_temp-browse-handle for temp-browse-handle .
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-browse-number = v-diasize-browse-number + 1
    .
    create buf_temp-browse-handle .
    assign
      buf_temp-browse-handle.browse-type   = p-browse-type
      buf_temp-browse-handle.browse-number = v-diasize-browse-number
      buf_temp-browse-handle.browse-handle = p-browse-handle
    .
  end.
end procedure.
procedure diasize_init :
  define variable v-default-value    as logical   no-undo .
  define variable v-restore-saved    as logical   no-undo .
  define variable v-resize-value-str as character no-undo .
  do
  on error undo, return error return-value
  :
    do with frame Dialog-Frame
    :
      assign
        v-diasize-orig-frame-height = frame Dialog-Frame :height
        v-diasize-orig-frame-width  = frame Dialog-Frame :width
        v-diasize-browse-handle     = browse br_marking-type :handle
      .
      create button v-diasize-resize-button
      assign
        parent        = frame Dialog-Frame :first-child
        label         = "s"
        height-pixels = 16
        width-pixels  = 16
        visible       = true
        sensitive     = true
        movable       = true
        triggers:
          on end-move persistent run diasize_end-move in this-procedure .
        end triggers.
      v-diasize-resize-button :load-mouse-pointer("SIZE") .
      v-diasize-resize-button :load-image("exe/grip.bmp":U) .
      v-diasize-resize-button :load-image-down("exe/grip.bmp":U) .
      v-diasize-resize-button :load-image-insensitive("exe/grip.bmp":U) .
      assign
        v-diasize-wndmax = false
      .
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndpar_r.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  'wndmax':U
          ,output v-diasize-wndmax
          ,output v-default-value
          ) .
      end.
      assign
        v-diasize-wndstore = false
      .
      if connected("ub") = true
      then do:
        run gbl/wndpar_r.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  'wndstore':U
          ,output v-diasize-wndstore
          ,output v-default-value
          ) .
      end.
      assign
        v-diasize-proc-name = entry(1, program-name(2), '.')
      .
      if v-diasize-wndstore = true
      then do:
        assign
          v-restore-saved = false
        .
        if connected("ub") = true
        then do:
          run gbl/wndsizer.p
            (input  v-cntxt-db-num
            ,input  v-cntxt-userid
            ,input  v-diasize-proc-name
            ,input  'height':u
            ,output v-resize-value-str
            ) .
          if v-resize-value-str <> '':U
          then do:
            run diasize_change-height in this-procedure
              (input  integer(v-resize-value-str)
              ,input  true
              ) .
            assign
              v-restore-saved = true
            .
          end.
        end.
        if connected("ub") = true
        then do:
          run gbl/wndsizer.p
            (input  v-cntxt-db-num
            ,input  v-cntxt-userid
            ,input  v-diasize-proc-name
            ,input  'width':u
            ,output v-resize-value-str
            ) .
          if v-resize-value-str <> '':U
          then do:
            run diasize_change-width in this-procedure
              (input  integer(v-resize-value-str)
              ,input  true
              ) .
            assign
              v-restore-saved = true
            .
          end.
        end.
        if v-restore-saved <> true
        then do:
          if v-diasize-wndmax = true
          then do:
            run diasize_maximize in this-procedure
              (input  true
              ) .
          end.
        end.
      end.
      else do:
        if v-diasize-wndmax = true
        then do:
          run diasize_maximize in this-procedure
            (input  true
            ) .
        end.
      end.
    end.
  end.
end procedure.
procedure diasize_need-full-display :
  define output parameter p-need-full-display as logical   no-undo .
  do
  on error undo, return error return-value
  :
    assign
      p-need-full-display = v-diasize-need-full-display
    .
    assign
      v-diasize-need-full-display = false
    .
  end.
end procedure.
procedure get-context :
   define output parameter p-db-num as integer          no-undo.
   define output parameter p-user-id as character        no-undo.
   define variable v-login               as character    no-undo.
   define buffer buf_sys-ctrl    for ub.sys-ctrl .
   define buffer buf_user-login  for ub.user-login .
   do
   on error undo, return error
   :
         FIND FIRST buf_sys-ctrl no-lock.
         ASSIGN
            v-login = USERID("ub")
            p-db-num = buf_sys-ctrl.db-num
         .
         FIND FIRST buf_user-login
              WHERE buf_user-login.db-num = p-db-num
                AND buf_user-login.user-login = v-login
              no-lock
              no-error
              .
         IF AVAILABLE buf_user-login
         THEN DO:
            assign
               p-user-id = buf_user-login.user-id
            .
         END.
   end.
end procedure.
    run diasize_init in this-procedure .
ASSIGN br_marking-type :NUM-LOCKED-COLUMNS IN FRAME Dialog-Frame = 1 .
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       type-marking.mark-type:COLUMN-READ-ONLY IN BROWSE br_marking-type = true.
ON GO OF FRAME Dialog-Frame
DO:
  run save-proc in this-procedure no-error.
  if error-status :error then return no-apply.
END.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON VALUE-CHANGED OF cb-gray_zone_qnty IN FRAME Dialog-Frame
DO:
  define buffer tt-mark for type-marking.
  if  cb-gray_zone_qnty:screen-value  eq "100"
  then do:
     for each tt-mark where     tt-mark.mark-orig eq Types:tabak:NameProp
                             or tt-mark.mark-orig eq Types:stiki:NameProp
     no-lock:
        if tt-mark.mark
        then do:
           message 'При помарочном учете для "' tt-mark.mark-type '" нельзя выставлять серую зону в 100'
              view-as alert-box.
           cb-gray_zone_qnty:screen-value = string(cb-gray_zone_qnty).
           return no-apply.
        end.
     end.
  end.
  assign cb-gray_zone_qnty .
END.
ON VALUE-CHANGED OF t-ban-altr IN FRAME Dialog-Frame
DO:
  assign t-ban-altr .
END.
ON VALUE-CHANGED OF t-ban_recipes IN FRAME Dialog-Frame
DO:
  assign t-ban_recipes .
END.
ON VALUE-CHANGED OF t-bar-code IN FRAME Dialog-Frame
DO:
  assign t-bar-code .
END.
ON VALUE-CHANGED OF t-rus-key IN FRAME Dialog-Frame
DO:
  assign t-rus-key .
END.
ON VALUE-CHANGED OF t-edo IN FRAME Dialog-Frame
DO:
  assign t-edo .
   do:
     enable
     t-edo-NotMark
     with frame Dialog-Frame .
  end.
END.
ON VALUE-CHANGED OF t-edo-NotMark IN FRAME Dialog-Frame
DO:
  assign t-edo-NotMark .
END.
ON VALUE-CHANGED OF t-manual IN FRAME Dialog-Frame
DO:
  assign t-manual .
END.
ON ROW-DISPLAY OF br_marking-type IN FRAME Dialog-Frame
  DO:
    type-marking.artic       :bgcolor  IN BROWSE br_marking-type = if isArticAvail()        then WHITE_COLOR else GRAY_COLOR .
    type-marking.edo         :bgcolor  IN BROWSE br_marking-type = if isMarkVnAvail()       then WHITE_COLOR else GRAY_COLOR .
    type-marking.transitional:bgcolor  IN BROWSE br_marking-type = if isTransitionalAvail() then WHITE_COLOR else GRAY_COLOR .
    type-marking.saleReturn        :bgcolor  IN BROWSE br_marking-type = if issaleReturnAvail()      then WHITE_COLOR else GRAY_COLOR .
    type-marking.checkBlock        :bgcolor  IN BROWSE br_marking-type = if ischeckBlockAvail()      then WHITE_COLOR else GRAY_COLOR .
    type-marking.checkDate        :bgcolor  IN BROWSE br_marking-type = if ischeckDateAvail()      then WHITE_COLOR else GRAY_COLOR .
    type-marking.checkMRC        :bgcolor  IN BROWSE br_marking-type = if ischeckMRCAvail()      then WHITE_COLOR else GRAY_COLOR .
    type-marking.checkOwner        :bgcolor  IN BROWSE br_marking-type = if ischeckOwnerAvail()      then WHITE_COLOR else GRAY_COLOR .
    type-marking.checkStatusKM        :bgcolor  IN BROWSE br_marking-type = if ischeckStatusKMAvail()      then WHITE_COLOR else GRAY_COLOR .
    type-marking.checkTracking        :bgcolor  IN BROWSE br_marking-type = if ischeckTrackingAvail()      then WHITE_COLOR else GRAY_COLOR .
  end.
ON row-leave OF br_marking-type IN FRAME Dialog-Frame
  DO:
    define variable vMarkvn        as logical no-undo.
    define variable vartic         as logical no-undo.
    define variable vtransitional  as logical no-undo.
    define variable vMarkAZK       as logical no-undo.
    define variable vBlockCashMark as logical no-undo .
    define variable vSaleReturn    as logical no-undo .
    define variable vSaleUPD       as logical no-undo .
    define variable vOnlySale      as logical no-undo .
    define variable vcheckBlock    as logical no-undo .
    define variable vcheckDate     as logical no-undo .
    define variable vcheckMRC      as logical no-undo .
    define variable vcheckOwner    as logical no-undo .
    define variable vcheckStatusKM as logical no-undo .
    define variable vcheckTracking as logical no-undo .
    assign
      vMarkvn        = type-marking.edo
      vartic         = type-marking.artic
      vtransitional  = type-marking.transitional
      vMarkAZK       = type-marking.mark
      vSaleReturn    = type-marking.saleReturn
      vcheckBlock    = type-marking.checkBlock
      vcheckDate     = type-marking.checkDate
      vcheckMRC      = type-marking.checkMRC
      vcheckOwner    = type-marking.checkOwner
      vcheckStatusKM = type-marking.checkStatusKM
      vcheckTracking = type-marking.checkTracking
      browse br_marking-type type-marking.edo
      browse br_marking-type type-marking.artic
      browse br_marking-type type-marking.transitional
      browse br_marking-type type-marking.saleReturn
      browse br_marking-type type-marking.checkBlock
      browse br_marking-type type-marking.checkDate
      browse br_marking-type type-marking.checkMRC
      browse br_marking-type type-marking.checkOwner
      browse br_marking-type type-marking.checkStatusKM
      browse br_marking-type type-marking.checkTracking
      .
    if      not isArticAvail()
      and  type-marking.artic ne vartic
      and  type-marking.artic ne no
   then do:
      type-marking.artic:checked IN BROWSE br_marking-type = no.
      type-marking.artic = no.
   end.
   if      not isMarkVnAvail()
      and  type-marking.edo ne vMarkvn
      and  type-marking.edo ne no
   then do:
      assign
      type-marking.edo:checked IN BROWSE br_marking-type = no.
      type-marking.edo = no.
   end.
   if    not  type-marking.edo
     or   (not isMarkAZKAvail()
      and  type-marking.mark ne vMarkAZK
      and  type-marking.mark ne no)
   then do:
      assign
      type-marking.mark = no.
      vMarkAZK = no.
   end.
   if      not isTransitionalAvail()
      and  type-marking.transitional ne vtransitional
      and  type-marking.transitional ne no
   then do:
      type-marking.transitional:checked IN BROWSE br_marking-type = no.
      type-marking.transitional = no.
   end.
      if      not issaleReturnAvail()
      and  type-marking.saleReturn ne vSaleReturn
      and  type-marking.saleReturn ne no
   then do:
      type-marking.saleReturn:checked IN BROWSE br_marking-type = no.
      type-marking.saleReturn = no.
   end.
   apply "ROW-DISPLAY" to br_marking-type IN FRAME Dialog-Frame.
   if    (type-marking.mark-orig eq Types:tabak:NameProp
       or type-marking.mark-orig eq Types:stiki:NameProp)
       and type-marking.mark ne vMarkAZK
       and type-marking.mark eq yes
       and cb-gray_zone_qnty :screen-value = "100"
   then do:
      cb-gray_zone_qnty = 2.
      cb-gray_zone_qnty :screen-value = "2".
      message 'Значение для Серой зоны изменено со 100  на ' cb-gray_zone_qnty
              view-as alert-box.
   end.
end.
ON VALUE-CHANGED  OF br_marking-type IN FRAME Dialog-Frame
DO:
   apply "row-leave" to br_marking-type IN FRAME Dialog-Frame.
end.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  if p-obj-type <> "" then do:
     FRAME Dialog-Frame:TITLE = FRAME Dialog-Frame:TITLE + (if p-obj-type = 'орг':U then " фирма" else " маг") + STRING(p-obj-code) .
  end.
    RUN init-tt.
    RUN fill-widgets.
    RUN enable_UI.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY t-edo t-edo-NotMark t-manual t-ban_recipes t-ban-altr t-bar-code t-rus-key
          cb-gray_zone_qnty
      WITH FRAME Dialog-Frame.
  ENABLE B-exit B-quit t-edo t-edo-NotMark t-manual t-ban_recipes t-ban-altr
    t-bar-code t-rus-key cb-gray_zone_qnty
    WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  if p-mode <> 'ИЗМЕНЕНИЕ':U then disable B-exit with frame Dialog-Frame.
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
  ENABLE  br_marking-type WITH FRAME Dialog-Frame.
  if p-mode = 'ИЗМЕНЕНИЕ':U then
  do:
    ENABLE  t-edo cb-gray_zone_qnty t-manual t-ban_recipes t-ban-altr t-edo-NotMark t-bar-code t-rus-key
      WITH FRAME Dialog-Frame.
  end.
  else do:
    Display  t-edo cb-gray_zone_qnty t-manual t-ban_recipes t-ban-altr t-edo-NotMark t-bar-code t-rus-key br_marking-type
      WITH FRAME Dialog-Frame.
    br_marking-type:read-only in frame Dialog-Frame = true.
    disable B-exit with frame Dialog-Frame.
   end.
run adm/shattri.p (
    input "init":U
    , input p-obj-type
    , input p-obj-code
    , input 'marking':U
    , input "":U
    , output v-value-character
    , output v-value-date
    , output v-value-decimal
    , output v-value-integer
    , output v-value-logical
    , output v-param-type
    , input-output TABLE-HANDLE v-tth
    ) no-error .
  if error-status:error then
  do:
    message
      "Не удалось получить начальные значения настроек" skip
      error-status:get-message(1) return-value
      view-as alert-box error .
    undo, return error .
  end.
  FOR EACH temp-thbj-attr where temp-thbj-attr.obj-code = p-obj-code and temp-thbj-attr.obj-type = p-obj-type
    :
    IF temp-thbj-attr.prop-code = 'marking-EDO':U THEN
    DO:
      t-edo = temp-thbj-attr.property-value-logical .
      display t-edo with frame Dialog-Frame .
    END.
    else IF temp-thbj-attr.prop-code = 'marking-EDO-NotMark':U THEN
      DO:
        t-edo-NotMark = temp-thbj-attr.property-value-logical .
        display t-edo-NotMark with frame Dialog-Frame .
      END.
      else IF temp-thbj-attr.prop-code = 'marking-manual':U THEN
        DO:
          t-manual = temp-thbj-attr.property-value-logical .
          display t-manual with frame Dialog-Frame .
        END.
        else IF temp-thbj-attr.prop-code = 'marking-type':U THEN
          DO:
          END.
          else IF temp-thbj-attr.prop-code = 'marking-type-edo':U THEN
            DO:
              S-type-edo = temp-thbj-attr.property-value-character .
            END.
            else IF temp-thbj-attr.prop-code = 'marking-type-artic':U THEN
              DO:
                S-type-artic = temp-thbj-attr.property-value-character .
              END.
              else IF temp-thbj-attr.prop-code = 'marking-type-transitional':U THEN
                DO:
                  S-type-transitional = temp-thbj-attr.property-value-character .
                END.
                else IF temp-thbj-attr.prop-code = 'marking-type-blockCashUnMark':U THEN
                  DO:
                  END.
                  else IF temp-thbj-attr.prop-code = 'marking-type-saleReturn':U THEN
                    DO:
                      S-type-saleReturn = temp-thbj-attr.property-value-character .
                    END.
                    else IF temp-thbj-attr.prop-code = 'marking-type-saleUPD':U THEN
                      DO:
                      END.
                      else IF temp-thbj-attr.prop-code = 'marking-type-onlySale':U THEN
                        DO:
                        END.
                        else IF temp-thbj-attr.prop-code = 'gray_zone_qnty':U THEN
                          DO:
                            cb-gray_zone_qnty = temp-thbj-attr.property-value-integer .
                            display cb-gray_zone_qnty with frame Dialog-Frame .
                          END.
                          else IF temp-thbj-attr.prop-code = 'ban-recipes':U THEN
                            DO:
                              t-ban_recipes = temp-thbj-attr.property-value-logical .
                              display t-ban_recipes with frame Dialog-Frame .
                            END.
                            else IF temp-thbj-attr.prop-code = 'ban-altr':U THEN
                              DO:
                                t-ban-altr = temp-thbj-attr.property-value-logical .
                                display t-ban-altr with frame Dialog-Frame .
                              END.
                              else IF temp-thbj-attr.prop-code = 'bar-code':U THEN
                                DO:
                                  t-bar-code = temp-thbj-attr.property-value-logical .
                                  display t-bar-code with frame Dialog-Frame .
                                END.
                                else IF temp-thbj-attr.prop-code = 'rus-key':U THEN
                                  DO:
                                    t-rus-key = temp-thbj-attr.property-value-logical .
                                    display t-rus-key with frame Dialog-Frame .
                                  END.
                                  else IF temp-thbj-attr.prop-code = 'checkBlock':U THEN
                                    DO:
                                      S-type-checkBlock = temp-thbj-attr.property-value-character .
                                    END.
                                    else IF temp-thbj-attr.prop-code = 'checkDate':U THEN
                                      DO:
                                        S-type-checkDate = temp-thbj-attr.property-value-character .
                                      END.
                                      else IF temp-thbj-attr.prop-code = 'checkMRC':U THEN
                                        DO:
                                          S-type-checkMRC = temp-thbj-attr.property-value-character .
                                        END.
                                        else IF temp-thbj-attr.prop-code = 'checkOwner':U THEN
                                          DO:
                                            S-type-checkOwner = temp-thbj-attr.property-value-character .
                                          END.
                                          else IF temp-thbj-attr.prop-code = 'checkStatusKM':U THEN
                                            DO:
                                              S-type-checkStatusKM = temp-thbj-attr.property-value-character .
                                            END.
                                            else IF temp-thbj-attr.prop-code = 'checkTracking':U THEN
                                              DO:
                                                S-type-checkTracking = temp-thbj-attr.property-value-character .
                                              END.
  END.
  for each type-marking:
    if lookup (type-marking.mark-orig,S-type-EDO) > 0 then type-marking.EDO = true .
    else type-marking.EDO = false .
    if lookup (type-marking.mark-orig,S-type-artic) > 0 then type-marking.artic = true .
    else type-marking.artic = false .
    if lookup (type-marking.mark-orig,S-type-transitional) > 0 then type-marking.transitional = true .
    else type-marking.transitional = false .
    if lookup (type-marking.mark-orig,S-type-saleReturn) > 0 then type-marking.saleReturn = true .
    else type-marking.saleReturn = false .
    if lookup (type-marking.mark-orig,S-type-checkBlock) > 0 then type-marking.checkBlock = true .
    else type-marking.checkBlock = false .
    if lookup (type-marking.mark-orig,S-type-checkDate) > 0 then type-marking.checkDate = true .
    else type-marking.checkDate = false .
    if lookup (type-marking.mark-orig,S-type-checkMRC) > 0 then type-marking.checkMRC = true .
    else type-marking.checkMRC = false .
    if lookup (type-marking.mark-orig,S-type-checkOwner) > 0 then type-marking.checkOwner = true .
    else type-marking.checkOwner = false .
    if lookup (type-marking.mark-orig,S-type-checkStatusKM) > 0 then type-marking.checkStatusKM = true .
    else type-marking.checkStatusKM = false .
    if lookup (type-marking.mark-orig,S-type-checkTracking) > 0 then type-marking.checkTracking = true .
    else type-marking.checkTracking = false .
  end.
  OPEN QUERY br_marking-type FOR EACH type-marking INDEXED-REPOSITION.
END PROCEDURE.
PROCEDURE init-tt :
define variable ii as integer no-undo .
define variable MarkType as ibs.th.gbl.map.mapstring no-undo.
define variable objType  as ibs.th.gbl.propmap no-undo.
define variable Types as ibs.th.gbl.TypeMap no-undo.
Types = ObjSrv:Env:Marking:Types.
MarkType = Types:mapType.
do ii = 1 to MarkType:GetItemByLab(ii):
objType  = ObjSrv:Env:Marking:Types:CurrProp.
create type-marking .
assign
   type-marking.mark-orig = objType:NameProp
   type-marking.mark-type = objType:Label_ .
end.
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
    t-edo
    t-edo-NotMark
    t-manual
    cb-gray_zone_qnty
    t-ban_recipes
    t-ban-altr
        t-bar-code
        t-rus-key
    .
  S-type-artic = "" .
  S-type-EDO = "" .
  S-type-transitional = "".
  S-type-saleReturn = "".
  S-type-checkBlock = "".
  S-type-checkDate = "".
  S-type-checkMRC = "".
  S-type-checkOwner = "".
  S-type-checkStatusKM = "".
  S-type-checkTracking = "".
  for each thbjattr-list :
      delete thbjattr-list.
  end.
  for each type-marking:
    if type-marking.edo = true then S-type-EDO = S-type-edo + "," + type-marking.mark-orig .
    if type-marking.artic = true then S-type-artic = S-type-artic + "," + type-marking.mark-orig .
    if type-marking.transitional = true then S-type-transitional = S-type-transitional + "," + type-marking.mark-orig .
    if type-marking.saleReturn = true then S-type-saleReturn = S-type-saleReturn + "," + type-marking.mark-orig .
    if type-marking.checkBlock = true then S-type-checkBlock = S-type-checkBlock + "," + type-marking.mark-orig .
    if type-marking.checkDate = true then S-type-checkDate = S-type-checkDate + "," + type-marking.mark-orig .
    if type-marking.checkMRC = true then S-type-checkMRC = S-type-checkMRC + "," + type-marking.mark-orig .
    if type-marking.checkOwner = true then S-type-checkOwner = S-type-checkOwner + "," + type-marking.mark-orig .
    if type-marking.checkStatusKM = true then S-type-checkStatusKM = S-type-checkStatusKM + "," + type-marking.mark-orig .
    if type-marking.checkTracking = true then S-type-checkTracking = S-type-checkTracking + "," + type-marking.mark-orig .
  end.
  find first temp-thbj-attr where temp-thbj-attr.prop-code = 'marking-EDO':U and temp-thbj-attr.obj-code = p-obj-code and temp-thbj-attr.obj-type = p-obj-type.
  temp-thbj-attr.property-value-logical = t-edo.
  find first temp-thbj-attr where temp-thbj-attr.prop-code = 'marking-EDO-NotMark':U and temp-thbj-attr.obj-code = p-obj-code and temp-thbj-attr.obj-type = p-obj-type.
  temp-thbj-attr.property-value-logical = t-edo-NotMark.
  find first temp-thbj-attr where temp-thbj-attr.prop-code = 'marking-manual':U and temp-thbj-attr.obj-code = p-obj-code and temp-thbj-attr.obj-type = p-obj-type.
  temp-thbj-attr.property-value-logical = t-manual.
  find first temp-thbj-attr where temp-thbj-attr.prop-code = 'marking-type-edo':U and temp-thbj-attr.obj-code = p-obj-code and temp-thbj-attr.obj-type = p-obj-type.
  temp-thbj-attr.property-value-character = trim(S-type-edo,",").
  find first temp-thbj-attr where temp-thbj-attr.prop-code = 'marking-type-artic':U and temp-thbj-attr.obj-code = p-obj-code and temp-thbj-attr.obj-type = p-obj-type.
  temp-thbj-attr.property-value-character = trim(S-type-artic,",").
  find first temp-thbj-attr where temp-thbj-attr.prop-code = 'marking-type-transitional':U and temp-thbj-attr.obj-code = p-obj-code and temp-thbj-attr.obj-type = p-obj-type.
  temp-thbj-attr.property-value-character = trim(S-type-transitional,",").
  find first temp-thbj-attr where temp-thbj-attr.prop-code = 'marking-type-saleReturn':U and temp-thbj-attr.obj-code = p-obj-code and temp-thbj-attr.obj-type = p-obj-type.
  temp-thbj-attr.property-value-character = trim(S-type-saleReturn,",").
  find first temp-thbj-attr where temp-thbj-attr.prop-code = 'gray_zone_qnty':U and temp-thbj-attr.obj-code = p-obj-code and temp-thbj-attr.obj-type = p-obj-type.
  temp-thbj-attr.property-value-integer = cb-gray_zone_qnty.
  find first temp-thbj-attr where temp-thbj-attr.prop-code = 'ban-recipes':U and temp-thbj-attr.obj-code = p-obj-code and temp-thbj-attr.obj-type = p-obj-type.
  temp-thbj-attr.property-value-logical = t-ban_recipes.
  find first temp-thbj-attr where temp-thbj-attr.prop-code = 'ban-altr':U and temp-thbj-attr.obj-code = p-obj-code and temp-thbj-attr.obj-type = p-obj-type.
  temp-thbj-attr.property-value-logical = t-ban-altr.
  find first temp-thbj-attr where temp-thbj-attr.prop-code = 'bar-code':U and temp-thbj-attr.obj-code = p-obj-code and temp-thbj-attr.obj-type = p-obj-type.
  temp-thbj-attr.property-value-logical = t-bar-code.
  find first temp-thbj-attr where temp-thbj-attr.prop-code = 'rus-key':U and temp-thbj-attr.obj-code = p-obj-code and temp-thbj-attr.obj-type = p-obj-type.
  IF AVAILABLE temp-thbj-attr THEN temp-thbj-attr.property-value-logical = t-rus-key.
  find first temp-thbj-attr where temp-thbj-attr.prop-code = 'checkBlock':U and temp-thbj-attr.obj-code = p-obj-code and temp-thbj-attr.obj-type = p-obj-type.
  IF AVAILABLE temp-thbj-attr THEN DO:
     IF temp-thbj-attr.property-value-character <> trim(S-type-checkBlock,",")
     THEN DO:
         create thbjattr-list.
         buffer-copy temp-thbj-attr to thbjattr-list.
     END.
     temp-thbj-attr.property-value-character = trim(S-type-checkBlock,",").
  END.
  find first temp-thbj-attr where temp-thbj-attr.prop-code = 'checkDate':U and temp-thbj-attr.obj-code = p-obj-code and temp-thbj-attr.obj-type = p-obj-type.
  IF AVAILABLE temp-thbj-attr THEN DO:
     IF temp-thbj-attr.property-value-character <> trim(S-type-checkDate,",")
     THEN DO:
         create thbjattr-list.
         buffer-copy temp-thbj-attr to thbjattr-list.
     END.
     temp-thbj-attr.property-value-character = trim(S-type-checkDate,",").
  END.
  find first temp-thbj-attr where temp-thbj-attr.prop-code = 'checkMRC':U and temp-thbj-attr.obj-code = p-obj-code and temp-thbj-attr.obj-type = p-obj-type.
  IF AVAILABLE temp-thbj-attr THEN DO:
     IF temp-thbj-attr.property-value-character <> trim(S-type-checkMRC,",")
     THEN DO:
         create thbjattr-list.
         buffer-copy temp-thbj-attr to thbjattr-list.
     END.
     temp-thbj-attr.property-value-character = trim(S-type-checkMRC,",").
  END.
  find first temp-thbj-attr where temp-thbj-attr.prop-code = 'checkOwner':U and temp-thbj-attr.obj-code = p-obj-code and temp-thbj-attr.obj-type = p-obj-type.
  IF AVAILABLE temp-thbj-attr THEN DO:
     IF temp-thbj-attr.property-value-character <> trim(S-type-checkOwner,",")
     THEN DO:
         create thbjattr-list.
         buffer-copy temp-thbj-attr to thbjattr-list.
     END.
     temp-thbj-attr.property-value-character = trim(S-type-checkOwner,",").
  END.
  find first temp-thbj-attr where temp-thbj-attr.prop-code = 'checkStatusKM':U and temp-thbj-attr.obj-code = p-obj-code and temp-thbj-attr.obj-type = p-obj-type.
  IF AVAILABLE temp-thbj-attr THEN DO:
     IF temp-thbj-attr.property-value-character <> trim(S-type-checkStatusKM,",")
     THEN DO:
         create thbjattr-list.
         buffer-copy temp-thbj-attr to thbjattr-list.
     END.
     temp-thbj-attr.property-value-character = trim(S-type-checkStatusKM,",").
  END.
  find first temp-thbj-attr where temp-thbj-attr.prop-code = 'checkTracking':U and temp-thbj-attr.obj-code = p-obj-code and temp-thbj-attr.obj-type = p-obj-type.
  IF AVAILABLE temp-thbj-attr THEN DO:
     IF temp-thbj-attr.property-value-character <> trim(S-type-checkTracking,",")
     THEN DO:
         create thbjattr-list.
         buffer-copy temp-thbj-attr to thbjattr-list.
     END.
     temp-thbj-attr.property-value-character = trim(S-type-checkTracking,",").
  END.
  do transaction:
    RUN thbjattr_set-section IN THIS-PROCEDURE (
      input p-obj-type
      ,input p-obj-code
      ,input 'marking':U
      ,INPUT table temp-thbj-attr
      ) NO-ERROR.
    if error-status:error then
    do:
      message "Не удалось сохранить настройки"
        view-as alert-box.
      undo, return error.
    end.
    if can-find(first thbjattr-list) then
        run str/diallog.w (
            input parparentproc
          , input this-procedure
          , input "str/send-all.p":U
          , input ( p-obj-type + chr(4) + string(p-obj-code) + chr(4) + 'U':U + chr(4) + 'gismt':U + chr(4) + 'Передача параметров работы с ТСПИоТ':U)
          , input ?
          , input "":U
          , input substitute("Отсылка параметров работы с ТСПИоТ")
          ) no-error.
  end.
END PROCEDURE.
FUNCTION isArticAvail RETURNS LOGICAL
  (  ) :
  RETURN not type-marking.EDO .
END FUNCTION.
FUNCTION isMarkAZKAvail RETURNS LOGICAL
  (  ) :
  RETURN not type-marking.artic and type-marking.EDO and not type-marking.transitional.
END FUNCTION.
FUNCTION isMarkVnAvail RETURNS LOGICAL
  (  ) :
  RETURN not type-marking.artic and not type-marking.transitional.
END FUNCTION.
FUNCTION isTransitionalAvail RETURNS LOGICAL
  (  ) :
  RETURN not type-marking.mark and ( type-marking.EDO or type-marking.artic).
END FUNCTION.
FUNCTION isblockCashUnMarkAvail RETURNS LOGICAL
  (  ) :
  RETURN isMarkAZKAvail().
END FUNCTION.
FUNCTION issaleReturnAvail RETURNS LOGICAL
  (  ) :
  RETURN yes.
END FUNCTION.
FUNCTION issaleUPDAvail RETURNS LOGICAL
  (  ) :
  RETURN yes.
END FUNCTION.
FUNCTION isonlySaleAvail RETURNS LOGICAL
  (  ) :
  RETURN yes.
END FUNCTION.
FUNCTION ischeckBlockAvail RETURNS LOGICAL
  (  ) :
  RETURN yes.
END FUNCTION.
FUNCTION ischeckDateAvail RETURNS LOGICAL
  (  ) :
  RETURN yes.
END FUNCTION.
FUNCTION ischeckMRCAvail RETURNS LOGICAL
  (  ) :
  RETURN yes.
END FUNCTION.
FUNCTION ischeckOwnerAvail RETURNS LOGICAL
  (  ) :
  RETURN yes.
END FUNCTION.
FUNCTION ischeckStatusKMAvail RETURNS LOGICAL
  (  ) :
  RETURN yes.
END FUNCTION.
FUNCTION ischeckTrackingAvail RETURNS LOGICAL
  (  ) :
  RETURN yes.
END FUNCTION.
