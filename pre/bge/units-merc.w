define input parameter parparentproc as widget-handle no-undo .
define input parameter as-ref as log no-undo.
define output parameter unit-name as character init ? no-undo.
define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Справочник единиц измерения" .
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
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable ri as recid no-undo.
define variable glog as logical no-undo .
define variable v-guid_ as character no-undo .
define buffer buf_units-attr for ub.units-attr .
define temp-table tt-units like ub.units
  field guid_ as character format "X(40)"
.
DEFINE BUTTON b-connect
     LABEL "&Связать":L
     SIZE 10 BY 1.
DEFINE BUTTON b-exit AUTO-END-KEY
     LABEL "&Выход ":L
     SIZE 10 BY 1.
DEFINE BUTTON b-del
     LABEL "&Удалить":L
     SIZE 10 BY 1 tooltip "Удалить связку с данными ФГИС Меркурий".
DEFINE BUTTON b-select
     LABEL "Вы&брать":L
     SIZE 10 BY 1.
DEFINE QUERY br-units FOR tt-units SCROLLING.
DEFINE BROWSE br-units QUERY br-units NO-LOCK DISPLAY
      tt-units.unit-name
      tt-units.long-name FORMAT "X(30)"
      tt-units.OKEI COLUMn-LABEL "Код!ОКЕИ"
      tt-units.guid_ column-label "GUID в ФГИС Меркурий" format "X(40)"
    WITH SEPARATORS
           size 86.25 by 12.58
         .
DEFINE FRAME d-units
     br-units at row 2.5 col 3
     b-exit at row 1 col 1
     b-connect at row 1 col 11
     b-select at row 1 col 11
     b-del at row 1 col 21
    WITH VIEW-AS DIALOG-BOX
         SIDE-LABELS THREE-D
         SCROLLABLE size 91.88 by 16.25
         TITLE "Синхронизация единиц измерения с ФГИС Меркурий":L.
ASSIGN
       FRAME d-units:SCROLLABLE       = FALSE.
ON CHOOSE OF b-connect IN FRAME d-units
DO:
  if not available tt-units then return no-apply .
  run bge\units-merc-connect.w (input parparentproc,
                                output v-guid_ ) .
  if v-guid_ <> ""
  then do :
    tt-units.guid_ = v-guid_ .
    find first buf_units-attr exclusive-lock where buf_units-attr.unit-name = tt-units.unit-name
                                               and buf_units-attr.attr-code = "MercGuid"
                                               no-error .
    if not available buf_units-attr
    then do :
      create buf_units-attr .
      assign
        buf_units-attr.unit-name = tt-units.unit-name
        buf_units-attr.attr-code = "MercGuid"
      .
    end.
    buf_units-attr.attr-value = v-guid_ .
    br-units:refresh () .
  end.
END.
ON CHOOSE OF B-del IN FRAME d-units
DO:
  if not available tt-units or tt-units.guid_ = "" then return no-apply .
  find first buf_units-attr exclusive-lock where buf_units-attr.unit-name = tt-units.unit-name
                                               and buf_units-attr.attr-code = "MercGuid"
                                               no-error .
  if available buf_units-attr
  then do :
    delete buf_units-attr .
  end.
  tt-units.guid_ = "" .
  br-units:refresh () .
END.
ON CHOOSE OF b-select IN FRAME d-units
DO:
    if available tt-units then
        do:
            unit-name = tt-units.unit-name .
            apply  "GO" to FRAME d-units.
        end.
END.
ON DEFAULT-ACTION OF br-units IN FRAME d-units
DO:
    if as-ref then
        do:
                apply "CHOOSE":U to b-select.
        end.
END.
ON RETURN OF br-units IN FRAME d-units
DO:
    if as-ref then
        do:
                apply "CHOOSE":U to b-select.
        end.
END.
IF CURRENT-WINDOW:WINDOW-STATE = WINDOW-MINIMIZED
THEN CURRENT-WINDOW:WINDOW-STATE = WINDOW-NORMAL.
ON WINDOW-CLOSE OF FRAME d-units APPLY "END-ERROR":U TO SELF.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  empty temp-table tt-units .
  for each ub.units no-lock :
    create tt-units.
    buffer-copy ub.units to tt-units.
    find first ub.units-attr no-lock where ub.units-attr.unit-name = ub.units.unit-name
                                       and ub.units-attr.attr-code = "MercGuid" no-error .
    if available ub.units-attr then tt-units.guid_ =  ub.units-attr.attr-value .
  end.
  RUN enable_UI.
  if available tt-units then
      glog = br-units:select-focused-row( ).
do  on endkey undo, leave  on error undo, leave:
  WAIT-FOR GO OF FRAME d-units.
end.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME d-units.
END PROCEDURE.
PROCEDURE enable_UI :
    b-select:visible IN FRAME d-units = as-ref .
    b-connect:visible IN FRAME d-units = not as-ref .
    b-del:visible IN FRAME d-units = not as-ref .
    ENABLE  br-units b-exit
                    b-connect     WHEN v-cntxt-db-num = 0
                    b-del         WHEN v-cntxt-db-num = 0
                    b-select      WHEN b-select:visible
        WITH FRAME d-units.
    OPEN QUERY br-units FOR EACH tt-units exclusive-LOCK  .
END PROCEDURE.
