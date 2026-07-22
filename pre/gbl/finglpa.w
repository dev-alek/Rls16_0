define input parameter parparentproc as widget-handle no-undo.
define input parameter p-mode as character no-undo.
define input parameter p-obj-type like ub.clients.obj-type no-undo.
define input parameter p-obj-code like ub.shop.obj-code no-undo.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-Workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Глобальные параметры Ассортиментной политики" .
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
define buffer buf_thbj-attr for ub.thbj-attr.
define temp-table temp-thbj-attr no-undo like ub.thbj-attr.
define temp-table thbjattr_thbj-attr-fin no-undo like ub.thbj-attr.
define variable v-tth-abc as handle no-undo .
define variable v-to-create as logical no-undo.
define variable v-to-create-abc as logical no-undo.
define variable str-attr as character no-undo .
assign
v-tth-abc = buffer thbjattr_thbj-attr-fin:table-handle .
if p-mode =  'ИЗМЕНЕНИЕ':U then do:
    if g#db-num = 0 then p-mode = 'ИЗМЕНЕНИЕ':U.
      else p-mode = 'ПРОСМОТР':U .
end.
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
DEFINE VARIABLE fo-nakl-status_ AS CHARACTER FORMAT "X(256)":U INITIAL "накл +"
     VIEW-AS COMBO-BOX INNER-LINES 3
     LIST-ITEMS "накл +","разр","факт"
     DROP-DOWN-LIST
     SIZE 16 BY 1 NO-UNDO.
DEFINE VARIABLE v-fo-buyer-nws AS CHARACTER FORMAT "X(256)":U INITIAL "1"
      VIEW-AS TEXT
     SIZE 81 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE v-fo-gen AS CHARACTER FORMAT "X(256)":U INITIAL "4"
      VIEW-AS TEXT
     SIZE 81 BY .92
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE v-fo-mc-mode AS CHARACTER FORMAT "X(256)":U INITIAL "3"
      VIEW-AS TEXT
     SIZE 81 BY .92
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE v-fo-supp-nws AS CHARACTER FORMAT "X(256)":U INITIAL "2"
      VIEW-AS TEXT
     SIZE 81 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE v-stat-text AS CHARACTER FORMAT "X(256)":U INITIAL "в статусе"
      VIEW-AS TEXT
     SIZE 10 BY .63 NO-UNDO.
DEFINE IMAGE I-add-conn-avt
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.75.
DEFINE IMAGE I-del-conn-avt
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.75.
DEFINE IMAGE I-fo-buyer-nws
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 2.04.
DEFINE IMAGE I-fo-fact
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY .75.
DEFINE IMAGE I-fo-gen
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.75.
DEFINE IMAGE I-fo-mc-mode
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 2.04.
DEFINE IMAGE I-fo-supp-nws
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.75.
DEFINE VARIABLE fo-buyer-nws AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Создаются на активной стороне", 0,
"Только в ГБД", 1
     SIZE 33.75 BY 2 NO-UNDO.
DEFINE VARIABLE fo-mc-mode AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Простая (старая схема)", 0,
"Мастер договор", 1,
"Смешанная схема", 2
     SIZE 41.25 BY 2 NO-UNDO.
DEFINE VARIABLE fo-supp-nws AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Не ходят по новостям", 0,
"Из ГБД в УБД", 1
     SIZE 32.25 BY 2 NO-UNDO.
DEFINE VARIABLE add-conn-avt AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 80 BY .83 NO-UNDO.
DEFINE VARIABLE del-conn-avt AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 80 BY .83 NO-UNDO.
DEFINE VARIABLE fo-fact AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 80 BY .83 NO-UNDO.
DEFINE VARIABLE fo-gen-nakl AS LOGICAL INITIAL no
     LABEL "Накладных"
     VIEW-AS TOGGLE-BOX
     SIZE 15.25 BY .79
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE fo-gen-ord AS LOGICAL INITIAL no
     LABEL "Заказов"
     VIEW-AS TOGGLE-BOX
     SIZE 80 BY .79
     FGCOLOR 4  NO-UNDO.
DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     B-quit AT ROW 1 COL 11
     B-Help AT ROW 1 COL 74.5
     fo-buyer-nws AT ROW 3 COL 4.75 NO-LABEL WIDGET-ID 2
     fo-supp-nws AT ROW 6 COL 4.75 NO-LABEL WIDGET-ID 12
     fo-fact AT ROW 8.58 COL 5 WIDGET-ID 38
     fo-mc-mode AT ROW 11.5 COL 5 NO-LABEL WIDGET-ID 44
     add-conn-avt AT ROW 14.25 COL 5.5 WIDGET-ID 38
     del-conn-avt AT ROW 15.92 COL 5.5 WIDGET-ID 38
     fo-gen-ord AT ROW 18.46 COL 5.5 WIDGET-ID 60
     fo-nakl-status_ AT ROW 19.25 COL 25.88 COLON-ALIGNED NO-LABEL WIDGET-ID 64
     fo-gen-nakl AT ROW 19.42 COL 5.5 WIDGET-ID 62
     v-fo-buyer-nws AT ROW 2.25 COL 1.5 NO-LABEL WIDGET-ID 6
     v-fo-supp-nws AT ROW 5.25 COL 1.5 NO-LABEL WIDGET-ID 18
     v-fo-mc-mode AT ROW 10.25 COL 1.5 NO-LABEL WIDGET-ID 40
     v-fo-gen AT ROW 17.25 COL 1.75 NO-LABEL WIDGET-ID 70
     v-stat-text AT ROW 19.46 COL 15.75 COLON-ALIGNED NO-LABEL WIDGET-ID 68
     I-fo-buyer-nws AT ROW 2.96 COL 1 WIDGET-ID 10
     I-fo-supp-nws AT ROW 6 COL 1 WIDGET-ID 34
     I-fo-fact AT ROW 8.58 COL 1 WIDGET-ID 36
     I-add-conn-avt AT ROW 14.25 COL 1.5 WIDGET-ID 36
     I-del-conn-avt AT ROW 15.92 COL 1.5 WIDGET-ID 36
     I-fo-mc-mode AT ROW 11.25 COL 1 WIDGET-ID 42
     I-fo-gen AT ROW 18.42 COL 1 WIDGET-ID 58
     SPACE(83.12) SKIP(0.53)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Настройки для блока Взаиморасчеты"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON B-quit WIDGET-ID 100.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       v-fo-buyer-nws:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       v-fo-gen:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       v-fo-mc-mode:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       v-fo-supp-nws:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       v-stat-text:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ON GO OF FRAME Dialog-Frame
DO:
  run save-proc in this-procedure no-error.
  if error-status :error then return no-apply.
END.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON VALUE-CHANGED OF fo-gen-nakl IN FRAME Dialog-Frame
DO:
  IF fo-gen-nakl:SCREEN-VALUE = "yes" THEN DO :
     enable  fo-nakl-status_ v-stat-text with frame Dialog-Frame .
     display fo-nakl-status_ v-stat-text with frame Dialog-Frame .
  end.
  ELSE HIDE fo-nakl-status_ v-stat-text in frame Dialog-Frame .
END.
ON MOUSE-SELECT-CLICK OF I-add-conn-avt IN FRAME Dialog-Frame
DO:
  MESSAGE I-add-conn-avt:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-del-conn-avt IN FRAME Dialog-Frame
DO:
  MESSAGE I-del-conn-avt:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-fo-buyer-nws IN FRAME Dialog-Frame
DO:
  MESSAGE I-fo-buyer-nws:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-fo-fact IN FRAME Dialog-Frame
DO:
  MESSAGE I-fo-fact:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-fo-gen IN FRAME Dialog-Frame
DO:
  MESSAGE I-fo-gen:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-fo-mc-mode IN FRAME Dialog-Frame
DO:
  MESSAGE I-fo-mc-mode:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-fo-supp-nws IN FRAME Dialog-Frame
DO:
  MESSAGE I-fo-supp-nws:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable loc#log as logical   no-undo .
define variable vss-include-info4 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  g#db-num
    ,input  g#userid
    ,input  0
    ,input  'actn_global-fin_lookup':U
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
    RUN init-tt.
    RUN enable_UI.
    RUN init-proc.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY fo-buyer-nws fo-supp-nws fo-fact fo-mc-mode add-conn-avt del-conn-avt
          fo-gen-ord fo-nakl-status_ fo-gen-nakl v-fo-buyer-nws v-fo-supp-nws
          v-fo-mc-mode v-fo-gen v-stat-text
      WITH FRAME Dialog-Frame.
  ENABLE B-exit B-quit B-Help I-fo-buyer-nws I-fo-supp-nws I-fo-fact
         I-add-conn-avt I-del-conn-avt I-fo-mc-mode I-fo-gen fo-buyer-nws
         fo-supp-nws fo-fact fo-mc-mode add-conn-avt del-conn-avt fo-gen-ord
         fo-nakl-status_ fo-gen-nakl v-fo-buyer-nws v-fo-supp-nws v-fo-mc-mode
         v-fo-gen v-stat-text
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
for each thbjattr_thbj-attr-fin:
  delete thbjattr_thbj-attr-fin.
end.
for each temp-thbj-attr:
  delete temp-thbj-attr.
end.
run adm/shattri.p (
    input "init":U
  , input ""
  , input 0
  , input 'fin-global':U
  , input "":U
  , output v-value-character
  , output v-value-date
  , output v-value-decimal
  , output v-value-integer
  , output v-value-logical
  , output v-param-type
  , input-output TABLE-HANDLE v-tth-abc
  ) no-error .
if error-status:error
and not available buf_thbj-attr then do:
  message
  "Не удалось получить начальные значения настроек" skip
  error-status:get-message(1) return-value
  view-as alert-box error .
  undo, return error .
end.
FOR EACH thbjattr_thbj-attr-fin:
  IF thbjattr_thbj-attr-fin.prop-code = 'fo-buyer-nws':U THEN DO:
     fo-buyer-nws = thbjattr_thbj-attr-fin.property-value-integer.
     fo-buyer-nws:PRIVATE-DATA IN FRAME Dialog-Frame = "recid=" + string(recid(thbjattr_thbj-attr-fin)).
     display fo-buyer-nws with frame Dialog-Frame .
  END.
  IF thbjattr_thbj-attr-fin.prop-code = 'fo-supp-nws':U THEN DO:
     fo-supp-nws = thbjattr_thbj-attr-fin.property-value-integer.
     fo-supp-nws:private-data = "recid=" + string(recid(thbjattr_thbj-attr-fin)).
     display fo-supp-nws with frame Dialog-Frame .
  END.
  IF thbjattr_thbj-attr-fin.prop-code = 'fo-fact':U THEN DO:
     fo-fact = thbjattr_thbj-attr-fin.property-value-logical.
     fo-fact:private-data = "recid=" + string(recid(thbjattr_thbj-attr-fin)).
     display fo-fact with frame Dialog-Frame .
  END.
  IF thbjattr_thbj-attr-fin.prop-code = 'fo-mc-mode':U THEN DO:
     fo-mc-mode = thbjattr_thbj-attr-fin.property-value-integer.
     fo-mc-mode:private-data = "recid=" + string(recid(thbjattr_thbj-attr-fin)).
     display fo-mc-mode with frame Dialog-Frame .
  END.
  IF thbjattr_thbj-attr-fin.prop-code = 'add-conn-avt':U THEN DO:
     add-conn-avt = thbjattr_thbj-attr-fin.property-value-logical.
     add-conn-avt:private-data = "recid=" + string(recid(thbjattr_thbj-attr-fin)).
     display add-conn-avt with frame Dialog-Frame .
  END.
  IF thbjattr_thbj-attr-fin.prop-code = 'del-conn-avt':U THEN DO:
     del-conn-avt = thbjattr_thbj-attr-fin.property-value-logical.
     del-conn-avt:private-data = "recid=" + string(recid(thbjattr_thbj-attr-fin)).
     display del-conn-avt with frame Dialog-Frame .
  END.
  IF thbjattr_thbj-attr-fin.prop-code = 'fo-gen':U THEN DO:
     fo-gen-ord = if ((thbjattr_thbj-attr-fin.property-value-integer + 1) MODULO 2 = 0) then true else false.
     display fo-gen-ord with frame Dialog-Frame .
     fo-gen-nakl = if (thbjattr_thbj-attr-fin.property-value-integer >= 2) then true else false.
     display fo-gen-nakl with frame Dialog-Frame .
          if (thbjattr_thbj-attr-fin.property-value-integer = 2 or thbjattr_thbj-attr-fin.property-value-integer = 3) then fo-nakl-status_ = "накл +".
     else if (thbjattr_thbj-attr-fin.property-value-integer = 4 or thbjattr_thbj-attr-fin.property-value-integer = 5) then fo-nakl-status_ = "разр"  .
     else if (thbjattr_thbj-attr-fin.property-value-integer = 6 or thbjattr_thbj-attr-fin.property-value-integer = 7) then fo-nakl-status_ = "факт"  .
     display fo-nakl-status_ with frame Dialog-Frame .
          if (thbjattr_thbj-attr-fin.property-value-integer = 0 or thbjattr_thbj-attr-fin.property-value-integer = 1) then
                                    hide v-stat-text fo-nakl-status_ in frame Dialog-Frame .
  END.
  create temp-thbj-attr.
  buffer-copy thbjattr_thbj-attr-fin to temp-thbj-attr.
END.
define variable v-tooltip as character no-undo .
define variable v-label   as character no-undo .
define variable v-tooltip-code as character no-undo .
run thbjattr_tooltip in this-procedure (
             input   'fin-global':U
            ,input  "fo-buyer-nws"
            ,output v-tooltip
            ,output v-label
            ,output v-tooltip-code
            ) no-error .
v-fo-buyer-nws:screen-value = entry(2,v-label,":") .
I-fo-buyer-nws:private-data = v-tooltip-code .
run thbjattr_tooltip in this-procedure (
             input   'fin-global':U
            ,input  "fo-supp-nws"
            ,output v-tooltip
            ,output v-label
            ,output v-tooltip-code
            ) no-error .
v-fo-supp-nws:screen-value = entry(2,v-label,":") .
I-fo-supp-nws:private-data = v-tooltip-code .
run thbjattr_tooltip in this-procedure (
             input   'fin-global':U
            ,input  "fo-fact"
            ,output v-tooltip
            ,output v-label
            ,output v-tooltip-code
            ) no-error .
fo-fact:label = entry(2,v-label,":") + "                                    _".
I-fo-fact:private-data = v-tooltip-code .
run thbjattr_tooltip in this-procedure (
             input   'fin-global':U
            ,input  "fo-mc-mode"
            ,output v-tooltip
            ,output v-label
            ,output v-tooltip-code
            ) no-error .
           .
v-fo-mc-mode:screen-value = entry(2,v-label,":") .
I-fo-mc-mode:private-data = v-tooltip-code .
run thbjattr_tooltip in this-procedure (
             input   'fin-global':U
            ,input  "add-conn-avt"
            ,output v-tooltip
            ,output v-label
            ,output v-tooltip-code
            ) no-error .
                            .
add-conn-avt:label = entry(2,v-label,":") .
I-add-conn-avt:private-data = v-tooltip-code .
run thbjattr_tooltip in this-procedure (
             input   'fin-global':U
            ,input  "del-conn-avt"
            ,output v-tooltip
            ,output v-label
            ,output v-tooltip-code
            ) no-error .
                            .
del-conn-avt:label = entry(2,v-label,":") .
I-del-conn-avt:private-data = v-tooltip-code .
run thbjattr_tooltip in this-procedure (
             input   'fin-global':U
            ,input  "fo-gen"
            ,output v-tooltip
            ,output v-label
            ,output v-tooltip-code
            ) no-error .
v-fo-gen:screen-value = entry(2,v-label,":") .
I-fo-gen:private-data = v-tooltip-code .
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
    find first buf_thbj-attr exclusive-lock where
              buf_thbj-attr.obj-type = ""
        and   buf_thbj-attr.obj-code = 0
        and   buf_thbj-attr.upper-prop-code = 'fin-global':U
        and   buf_thbj-attr.prop-code = '':u no-wait no-error.
     if locked buf_thbj-attr then do:
        message
        vss-workfile vss-revision vss-description skip
        'fin-global':U skip
        "Запись Глобальных ПАРАМЕТРОВ для взаиморасчетов  занята"
        view-as alert-box error .
        undo, return error.
      end.
  end.
  else do:
    find first buf_thbj-attr no-lock where
          buf_thbj-attr.obj-type = ""
    and   buf_thbj-attr.obj-code = 0
    and   buf_thbj-attr.upper-prop-code = 'fin-global':U
    and   buf_thbj-attr.prop-code = '':u no-error.
  end.
  if not available buf_thbj-attr then do:
    assign
      v-to-create  = true
      .
    message
    substitute ("Внимание!!!&1Параметра НЕТ в БД!&1Будут показаны ЗНАЧЕНИЯ ПО УМОЛЧАНИЮ",
                chr(10))
                 view-as alert-box warning.
  end.
  run fill-widgets in this-procedure no-error.
  if error-status:error then undo, return error.
  apply "value-changed":u to fo-buyer-nws in frame Dialog-Frame.
  if p-mode <> 'ИЗМЕНЕНИЕ':U then do:
     disable fo-buyer-nws
             fo-supp-nws
             fo-fact
             fo-mc-mode
             add-conn-avt
             del-conn-avt
                         fo-gen-ord
             fo-gen-nakl
             fo-nakl-status_
             with frame Dialog-Frame.
     B-exit:label = "Вы&ход"  .
     hide B-quit in frame Dialog-Frame .
     if not fo-gen-nakl then hide fo-nakl-status_ v-stat-text in frame Dialog-Frame .
     else v-stat-text:FGCOLOR = 7 .
  END.
end procedure.
PROCEDURE init-tt :
END PROCEDURE.
PROCEDURE save-proc :
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-trf-type like ub.clients.obj-type no-undo .
define variable v-trf-code like ub.clients.obj-code no-undo .
define variable v-param-type as character no-undo .
define variable wh as widget-handle no-undo .
define variable fh as widget-handle no-undo .
define variable v-same as logical no-undo .
IF p-mode = 'ПРОСМОТР':U THEN RETURN .
define variable loc#log as logical   no-undo .
define variable vss-include-info5 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  g#db-num
    ,input  g#userid
    ,input  0
    ,input  'actn_global-fin_update':U
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
    fo-buyer-nws  FRAME Dialog-Frame
    fo-supp-nws
    fo-fact
    fo-mc-mode
    add-conn-avt
    del-conn-avt
    fo-gen-ord
    fo-gen-nakl
    fo-nakl-status_
    .
 assign
    fh = frame Dialog-Frame:first-child
    wh = fh:first-child
    .
do while valid-handle(wh):
  if wh:private-data begins "recid=" then do:
    find first thbjattr_thbj-attr-fin where
              recid(thbjattr_thbj-attr-fin) = integer(entry(2, wh:private-data, '=')).
    assign
    buffer thbjattr_thbj-attr-fin:buffer-field("property-value-" + wh:data-type):buffer-value = wh:input-value.
           thbjattr_thbj-attr-fin.obj-type = p-obj-type.
           thbjattr_thbj-attr-fin.obj-code = p-obj-code.
  end.
  wh = wh:next-sibling.
end.
find first thbjattr_thbj-attr-fin where thbjattr_thbj-attr-fin.prop-code = 'fo-gen':U .
           thbjattr_thbj-attr-fin.obj-type = p-obj-type.
           thbjattr_thbj-attr-fin.obj-code = p-obj-code.
if      not fo-gen-ord and not fo-gen-nakl             then assign buffer thbjattr_thbj-attr-fin:buffer-field("property-value-integer"):buffer-value = 0 .
else if     fo-gen-ord and not fo-gen-nakl             then assign buffer thbjattr_thbj-attr-fin:buffer-field("property-value-integer"):buffer-value = 1 .
else if not fo-gen-ord and     fo-gen-nakl and fo-nakl-status_ = "накл +"
                                                       then assign buffer thbjattr_thbj-attr-fin:buffer-field("property-value-integer"):buffer-value = 2 .
else if     fo-gen-ord and     fo-gen-nakl and fo-nakl-status_ = "накл +"
                                                       then assign buffer thbjattr_thbj-attr-fin:buffer-field("property-value-integer"):buffer-value = 3 .
else if not fo-gen-ord and     fo-gen-nakl and fo-nakl-status_ = "разр"
                                                       then assign buffer thbjattr_thbj-attr-fin:buffer-field("property-value-integer"):buffer-value = 4 .
else if     fo-gen-ord and     fo-gen-nakl and fo-nakl-status_ = "разр"
                                                       then assign buffer thbjattr_thbj-attr-fin:buffer-field("property-value-integer"):buffer-value = 5 .
else if not fo-gen-ord and     fo-gen-nakl and fo-nakl-status_ = "факт"
                                                       then assign buffer thbjattr_thbj-attr-fin:buffer-field("property-value-integer"):buffer-value = 6 .
else if     fo-gen-ord and     fo-gen-nakl and fo-nakl-status_ = "факт"
                                                       then assign buffer thbjattr_thbj-attr-fin:buffer-field("property-value-integer"):buffer-value = 7 .
v-same = yes.
for each thbjattr_thbj-attr-fin,
    first temp-thbj-attr where
          temp-thbj-attr.obj-type = thbjattr_thbj-attr-fin.obj-type
      and temp-thbj-attr.obj-code = thbjattr_thbj-attr-fin.obj-code
      and temp-thbj-attr.upper-prop-code = thbjattr_thbj-attr-fin.upper-prop-code
      and temp-thbj-attr.prop-code = thbjattr_thbj-attr-fin.prop-code:
   buffer-compare
   thbjattr_thbj-attr-fin
   to temp-thbj-attr
   save result in v-same.
   if not v-same then leave.
end.
do TRANSACTION
on error undo, return error return-value
:
  run thbjattr_set-section in this-procedure (
       input ""
      ,input 0
      ,input 'fin-global':U
      ,input table thbjattr_thbj-attr-fin
  ) no-error.
  if error-status:error then do:
    message error-status:get-message(1)  skip
    return-value
    view-as alert-box.
    undo, return error.
  end.
end.
END PROCEDURE.
