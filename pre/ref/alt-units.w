using Progress.Lang.*.
using ibs.th.str.gds.*.
using ibs.th.str.mercury.*.
using ibs.th.gbl.storage.*.
define input parameter parparentproc as handle no-undo .
define input parameter p-mode        as character no-undo .
define input parameter p-gds-code    as integer no-undo .
define input parameter p-unit-list   as character no-undo .
define output parameter p-unit-name  as character no-undo .
define output parameter p-coeff      as decimal no-undo .
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
define variable ii as integer no-undo .
define variable v-unit-name as character no-undo .
define variable v-value as character no-undo .
define variable v-coeff as decimal no-undo .
define variable unitsObj as class unitsubs .
define variable unitObj as class unitsub .
define variable unitsObj2 as class unitsubs .
define variable unitsStr as class unitmercstr .
define buffer buf_units for ub.units .
define buffer buf_units-attr for ub.units-attr .
define buffer buf_goods for ub.goods .
define temp-table tt-units like ub.units
  field guid_ as character format "X(40)"
  field coeff as decimal
.
define buffer buf_tt-units for tt-units .
DEFINE BUTTON b-add-unit
     LABEL "&Добавить":L
     SIZE 10 BY 1.
DEFINE BUTTON b-change
     LABEL "&Изменить":L
     SIZE 10 BY 1.
DEFINE BUTTON b-exit AUTO-END-KEY
     LABEL "&Выход ":L
     SIZE 10 BY 1.
DEFINE BUTTON b-select
     LABEL "Вы&брать":L
     SIZE 10 BY 1.
DEFINE BUTTON b-del
     LABEL "Удалить":L
     SIZE 10 BY 1.
DEFINE QUERY br-units FOR tt-units SCROLLING.
DEFINE BROWSE br-units QUERY br-units NO-LOCK DISPLAY
      tt-units.unit-name
      tt-units.long-name FORMAT "X(30)"
      tt-units.coeff COLUMn-LABEL "Коэфф." format ">>>>>>>>9.<<<<<<<<"
      tt-units.guid_ column-label "GUID в ФГИС Меркурий" format "X(40)"
    WITH SEPARATORS
           size 90.25 by 12.58
         .
         .
DEFINE FRAME d-units
     br-units at row 2.5 col 3
     b-exit at row 1 col 1
     b-select at row 1 col 11
     b-add-unit at row 1 col 21
     b-change at row 1 col 31
     b-del at row 1 col 41
    WITH VIEW-AS DIALOG-BOX
         SIDE-LABELS THREE-D
         SCROLLABLE size 93.5 by 16.25
         TITLE "ДОПОЛНИТЕЛЬНЫЕ ЕДИНИЦЫ  ИЗМЕРЕНИЯ":L.
ASSIGN
       FRAME d-units:SCROLLABLE       = FALSE.
ON CHOOSE OF b-add-unit IN FRAME d-units
DO:
  run bge\units-merc.w (input parparentproc,
                        input yes,
                        output v-unit-name) .
  if v-unit-name <> ? and v-unit-name <> ""
  then do :
    find first ub.goods no-lock where ub.goods.gds-code = p-gds-code .
    if ub.goods.unit-base = v-unit-name
    then do :
      message "Данная ед. изм. совпадает с учётной." view-as alert-box .
      return no-apply .
    end.
    find first buf_tt-units no-lock where buf_tt-units.unit-name = v-unit-name no-error .
    if available buf_tt-units
    then do :
      message "Данная ед. изм. уже добавлена." view-as alert-box .
      return no-apply .
    end.
    run gbl/d-prompt.w (
        'title=':u + "ВВЕДИТЕ КОЭФФИЦИЕНТ" + '\':u
      + 'text1=' + substitute("Коэффициент") + '\':u
      + 'format=' + ">>>>>>>>9.<<<<<<<<" + '\':u
      + 'type=' + 'D':U + '\':u
      + 'fillin_row=2\':u
      + 'fillin_col=4\':u
      + 'fillin_width=30\':u
      + 'fillin_height=1\':u
      + 'max-chars=70\':u
      + 'readonly=no\':u
      , input-output v-value
      ).
    if v-value <> ? and v-value <> ""
    then do :
      v-coeff = decimal(v-value) no-error.
      if error-status:error
      then do :
        message "Введен неверный коэффициент" view-as alert-box .
        return no-apply .
      end.
      find first buf_units no-lock where buf_units.unit-name = v-unit-name .
      find first buf_units-attr no-lock where buf_units-attr.unit-name = v-unit-name no-error .
      create tt-units.
      assign
        tt-units.unit-name = buf_units.unit-name
        tt-units.long-name = buf_units.long-name
        tt-units.guid_     = if available buf_units-attr then buf_units-attr.attr-value else ""
        tt-units.coeff     = v-coeff
      .
      OPEN QUERY br-units FOR EACH tt-units exclusive-LOCK  .
    end.
  end.
END.
ON CHOOSE OF b-change IN FRAME d-units
DO:
  if not available tt-units then return no-apply .
  run gbl/d-prompt.w (
      'title=':u + "ВВЕДИТЕ КОЭФФИЦИЕНТ" + '\':u
    + 'text1=' + substitute("Коэффициент") + '\':u
    + 'format=' + ">>>>>>>>9.<<<<<<<<" + '\':u
    + 'type=' + 'D':U + '\':u
    + 'fillin_row=2\':u
    + 'fillin_col=4\':u
    + 'fillin_width=30\':u
    + 'fillin_height=1\':u
    + 'max-chars=70\':u
    + 'readonly=no\':u
    , input-output v-value
    ).
  if v-value <> ? and v-value <> ""
  then do :
    v-coeff = decimal(v-value) no-error.
    if error-status:error
    then do :
      message "Введен неверный коэффициент" view-as alert-box .
      return no-apply .
    end.
    assign
      tt-units.coeff     = v-coeff
    .
    br-units:refresh () .
  end.
END.
ON CHOOSE OF b-del IN FRAME d-units
DO:
  if not available tt-units then return no-apply .
  delete tt-units .
  br-units:refresh () .
END.
ON CHOOSE OF b-select IN FRAME d-units
DO:
    // @FUTU вместо идент.ЕИ можно возвращать класс, содержащий выбранную единицу измерения
    if available tt-units then do:
      assign
        p-unit-name = tt-units.unit-name
        p-coeff     = tt-units.coeff
      .
      apply  "GO" to FRAME d-units.
    end.
END.
ON DEFAULT-ACTION OF br-units IN FRAME d-units
DO:
    if p-mode = 'ВЫБОР':U then
      apply "CHOOSE":U to b-select.
END.
ON RETURN OF br-units IN FRAME d-units
DO:
    if p-mode = 'ВЫБОР':U then
      apply "CHOOSE":U to b-select.
END.
ON CHOOSE OF b-exit IN FRAME d-units
DO:
  if (p-mode <> 'ВЫБОР':U) then do :
  find first tt-units no-lock no-error.
  if available tt-units
  then do :
    unitsObj2 = new unitsubs () .
    for each tt-units no-lock :
      unitObj = new unitsub () .
      unitObj:UnitName = tt-units.unit-name .
      unitObj:UnitFullName = tt-units.long-name .
      unitObj:UnitGuid = tt-units.guid_ .
      unitObj:UnitCoef = tt-units.coeff .
      unitsObj2:AddItem(unitObj) .
    end.
    unitsStr:writeDB(unitsObj2, p-gds-code) .
  end.
  else do :
    unitsStr:deleteDB(p-gds-code) .
  end.
  delete object unitsObj2 no-error .
  delete object unitsObj no-error .
  delete object unitsStr no-error .
  delete object unitObj no-error .
  end . // end_of not_mode_select
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
  unitsObj = new unitsubs () .
  unitsStr = new unitmercstr () .
  unitsObj = unitsStr:getunitmercs(p-gds-code) .
  do ii = 1 to unitsObj:GetItem(ii) :
    v-unit-name = unitsObj:UnitObjCurr:UnitName .
    if p-unit-list > "" then do :
      if not can-do (p-unit-list, v-unit-name) then next .
    end .
    create tt-units .
    tt-units.unit-name  = v-unit-name .
    tt-units.long-name  = unitsObj:UnitObjCurr:UnitFullName .
    tt-units.guid_      = unitsObj:UnitObjCurr:UnitGuid .
    tt-units.coeff      = unitsObj:UnitObjCurr:UnitCoef .
  end.
  if (p-mode = 'ВЫБОР':U) then do :
    assign
      p-unit-name = ""
      p-coeff     = 0.0
    .
    find first buf_goods no-lock where buf_goods.gds-code = p-gds-code no-error .
    if available buf_goods then do :
      if not can-find (first tt-units where tt-units.unit-name = buf_goods.unit-base) then do :
        create tt-units .
        assign
          tt-units.unit-name  = buf_goods.unit-base
          tt-units.long-name  = " БАЗОВАЯ "
          tt-units.guid_      = ""
          tt-units.coeff      = 1
        .
      end .
    end .
  end .
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
define variable v-is-editable as logical no-undo .
    v-is-editable = (ibs.th.gbl.gbl-var:g#db-num = 0) and
                    (p-mode <> 'ПРОСМОТР':U) and
                    (p-mode <> 'ВЫБОР':U) .
    b-select:visible   IN FRAME d-units = (p-mode = 'ВЫБОР':U) .
    ENABLE  br-units b-exit
                    b-select    WHEN b-select:visible
                    b-add-unit  when v-is-editable
                    b-change    when v-is-editable
                    b-del       when v-is-editable
        WITH FRAME d-units.
    OPEN QUERY br-units FOR EACH tt-units exclusive-LOCK  .
END PROCEDURE.
