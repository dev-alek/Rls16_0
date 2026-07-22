&Scop WINDOW-NAME d-g-grp-f
&Scop FRAME-NAME    d-g-grp-f

/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Форма для добавления / изменения группы товара

Автор: Белоусов Илья Александрович
Дата создания: 04/12/06
Author: Ilia Belousov
Creation date: 04/12/06

Input:

Output:

*/
/* ***************************  Definitions  ************************** */
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .
define input parameter mode as char no-undo.
define input parameter up-code like ub.gds-grp.upper-code no-undo.
define input-output param rid as recid no-undo.


define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Форма для добавления / изменения группы товара".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/showinf.i }

{ str/tt-tax.i "NEW SHARED" tt-tax full }
{ str/tt-tax.i new output-tax full }
{ ref/grplib.i }
{ ref/grpobj.i }

define variable grp-code like ub.gds-grp.node-code no-undo.
define variable v-margins-range     as integer           no-undo.
define variable v-margins-exists    as logical           no-undo.
define variable v-increase-range    as integer           no-undo.
define variable v-increase-exists   as logical           no-undo.
define variable v-min-marg          as decimal           no-undo.
define variable v-max-marg          as decimal           no-undo.
define variable v-increase-pc       as decimal           no-undo.
define variable v-round-method      as character         no-undo .
define variable v-rmethod-range     as integer           no-undo .
define variable v-rmethod-exists    as logical           no-undo .
define variable v-base              as decimal           no-undo .
define variable v-round-method-str  as character         no-undo .
define variable v-host-code         like ub.sysconf.host-code no-undo .
define buffer upper_gds-grp for ub.gds-grp.
/* ***********************  Control Definitions  ********************** */

DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Ввод ":L
     SIZE 10 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена":L
     SIZE 10 BY 1.

DEFINE BUTTON b-help AUTO-END-KEY
     LABEL "Помо&щь":L
     SIZE 10 BY 1.

DEFINE BUTTON b-tax
     LABEL "&Налоги":L
     SIZE 10 BY 1.

DEFINE BUTTON b-marg
     LABEL "&Параметры на объектах":L
     SIZE 40 BY 1.

DEFINE VARIABLE f-base AS DECIMAL FORMAT "->>>>9.99":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 15.38 BY 1
     NO-UNDO.

/*DEFINE VARIABLE f-print-code AS CHARACTER FORMAT "X(256)":U INITIAL "0"*/
/*     LABEL "Код"                                                       */
/*     VIEW-AS FILL-IN                                                   */
/*     SIZE 30 BY 1 NO-UNDO.                                             */
     
DEFINE VARIABLE S-round-method AS CHARACTER
     VIEW-AS SELECTION-LIST SINGLE SCROLLBAR-VERTICAL
     SIZE 23.5 BY 5
     BGCOLOR 15
     NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 92 BY 10.25.

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME {&frame-name}
b-exit AT ROW 1 COL 1
b-quit AT ROW 1 COL 11
b-tax  AT ROW 1 COL 21
b-marg  AT ROW 1 COL 31
b-help AT ROW 1 COL 81
ub.gds-grp.node-name AT ROW 2.5 COL 18 COLON-ALIGNED LABEL "Название" VIEW-AS FILL-IN SIZE 50 BY 1 format "X(90)"
"Правило назначения продажной цены для автопереоценок" VIEW-AS TEXT
          SIZE 59 BY 1 AT ROW 4.1 COL 3 WIDGET-ID 4  FGCOLOR 4 
"Метод расчета" VIEW-AS TEXT
SIZE 13 BY 1 AT ROW 5.1 COL 6 WIDGET-ID 4
"баз. цены:" VIEW-AS TEXT
SIZE 10 BY 1 AT ROW 6 COL 9 WIDGET-ID 4

ub.gds-grp.calc-method AT row 5.3 col 18 colon-aligned
          no-label
          VIEW-AS SELECTION-LIST SINGLE SCROLLBAR-VERTICAL
          LIST-ITEMS
          {&pr-calc-methods-grp}
          SIZE 30 BY 5
S-round-method AT ROW 5.3 col 66 COLON-ALIGNED
          LABEL "Метод округления"
ub.gds-grp.increase-pc AT row 10.5 col 18 COLON-ALIGNED
          LABEL "Наценка"
          VIEW-AS FILL-IN
          SIZE 10 BY 1
RECT-1 AT ROW 4 COL 1.5 WIDGET-ID 2
f-base AT ROW 10.5 COL 68 COLON-ALIGNED LABEL "База округления"
ub.gds-grp.print-code AT ROW 12.5 COL 18 COLON-ALIGNED LABEL "Код" 
          VIEW-AS FILL-IN
          SIZE 30 BY 1
SPACE (5) SKIP (0) WITH VIEW-AS DIALOG-BOX SIDE-LABELS THREE-D SCROLLABLE DEFAULT-BUTTON b-exit.

/* ***************  Runtime Attributes and UIB Settings  ************** */

ASSIGN FRAME {&frame-name}:SCROLLABLE = FALSE.

/* ************************  Control Triggers  ************************ */

ON GO OF FRAME {&frame-name} DO:
DEFINE VARIABLE varnode-code like ub.gds-grp.node-code no-undo .
DEFINE VARIABLE varupper-code like ub.gds-grp.upper-code no-undo .

do on endkey undo, return no-apply on error undo, return no-apply on stop undo, return no-apply:
if mode = {&add-def} then do:
  assign
  varnode-code = 0
  varupper-code = up-code
  .
end.
else do:
  assign
  varnode-code = ub.gds-grp.node-code
  varupper-code = ub.gds-grp.upper-code
  .
end.
assign
s-round-method
f-base
.
  run ref/gdsgrp01.p (
                  input mode
                  ,input no /*-silent*/
                  ,input no /*p-get-node-code*/
                  ,input no /*p-fill-tax-from-upper*/
                  ,input-output  varnode-code
                  ,input-output  varupper-code
                  ,input frame {&frame-name} gds-grp.node-name
                  ,input frame {&frame-name} gds-grp.calc-method
                  ,input frame {&frame-name} gds-grp.increase-pc
                  ,input frame {&frame-name} gds-grp.print-code 
                  ,input s-round-method
                  ,input f-base
                  ,output rid
                  ) no-error .
  if error-status:error then UNDO, return no-apply.
  run ref/dtaxgrpu.p (
                  input varnode-code
                 ,input varupper-code
                 ,input yes
                 ,input 0
                 ,input "":U
                 ,input 0
                  ) no-error .
  if error-status:error then undo, return no-apply.
end.

END.

ON CHOOSE OF b-tax in FRAME {&frame-name} DO:
  run proc-b-tax in this-procedure ( input parparentproc
                                    ,input v-host-code
                                    ,input p-obj-type
                                    ,input p-obj-code
                                    ,buffer ub.gds-grp
                                    ,input mode) no-error.
  if error-status:error then return no-apply.
END.

ON VALUE-CHANGED OF S-round-method IN FRAME {&frame-name}
DO:
  assign
  S-round-method
  .
  if LOOKUP(s-round-method, {&pr-rounds-need-coef}) > 0 then do:
    display
    f-base
    with frame {&frame-name}.
    if mode = {&add-def} then
    enable
    f-base
    with frame {&frame-name}.
  end.
  else do:
    hide
    f-base
    in frame {&frame-name}.
    disable
    f-base
    with frame {&frame-name}.
  end.
END.

ON CHOOSE OF b-marg in FRAME {&frame-name} DO:
    run ref/pr-marg.w (
          input parparentproc
        , input ub.gds-grp.node-code
    ) no-error.
    if error-status :error
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Ошибка при установке диапазона торговых наценок"
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
               trim(error-status :get-message(4))
               trim(error-status :get-message(5))
        view-as alert-box error.
        undo, return no-apply.
    end.
    run grp-obj-margin-value in this-procedure (
                            input gds-grp.node-code
                            , input p-obj-type
                            , input p-obj-code
                            , output v-min-marg
                            , output v-max-marg
                            , output v-increase-pc
                            , output v-round-method
                            , output v-base
                            , output v-margins-range
                            , output v-margins-exists
                            , output v-increase-range
                            , output v-increase-exists
                            , output v-rmethod-range
                            , output v-rmethod-exists

    ) no-error .
    display
    v-increase-pc @ gds-grp.increase-pc
    with frame {&frame-name}.
    assign
    s-round-method:screen-value = v-round-method
    f-base = v-base
    .
    APPLY "VALUE-CHANGED" to s-round-method.
END.

/* ***************************  Main Block  *************************** */

{ gbl/app_help.i }

IF CURRENT-WINDOW:WINDOW-STATE = WINDOW-MINIMIZED
THEN CURRENT-WINDOW:WINDOW-STATE = WINDOW-NORMAL.

ON WINDOW-CLOSE OF FRAME {&FRAME-NAME} APPLY "END-ERROR":U TO SELF.

define variable p-list as character no-undo .
assign
s-round-method:list-items in frame {&frame-name}  = {&pr-rounds}.

if mode = {&add-def} then do:
  find upper_gds-grp no-lock where
       upper_gds-grp.node-code = up-code no-error .
  if not avail upper_gds-grp then do:
    message
    vss-workfile vss-revision vss-description skip
    "Не найдена группа с кодом"
    up-code
    view-as alert-box error .
    return error .
  end.
end.


if mode = {&update} then do:
  find gds-grp where recid (gds-grp) =  rid.
end.
rid = ?. /* rid <> ? --> запись добавлена / изменена */

run str/pr-listv.p (
                 input {&pr-calc-methods-grp-list}
                ,input (if mode = {&update}
                        then gds-grp.calc-method
                        else "":U)
                ,output p-list) .
gds-grp.calc-method:list-items in frame {&frame-name}  = p-list .

{ gbl/hostcode.i p-obj-type p-obj-code v-host-code }

run ref/dtaxgrps.p (if avail gds-grp then gds-grp.node-code else 0,
               up-code,
               v-host-code,
               p-obj-type,
               p-obj-code) no-error.
if error-status:error then do:
  message
  error-status:get-message(1) skip
  return-value
  view-as alert-box error .
  return error.
end.
frame {&frame-name}:title = "ГРУППА ТОВАРОВ   -    " + mode.
if available gds-grp then do:
    run grp-obj-margin-value in this-procedure (
                            input gds-grp.node-code
                            , input p-obj-type
                            , input p-obj-code
                            , output v-min-marg
                            , output v-max-marg
                            , output v-increase-pc
                            , output v-round-method
                            , output v-base
                            , output v-margins-range
                            , output v-margins-exists
                            , output v-increase-range
                            , output v-increase-exists
                            , output v-rmethod-range
                            , output v-rmethod-exists

    ) no-error .
    if error-status:error then do:
      return error .
    end.
  disp
  gds-grp.node-name
  gds-grp.calc-method
  v-increase-pc @ gds-grp.increase-pc
  gds-grp.print-code
  WITH FRAME {&frame-name}.
  assign
  s-round-method:screen-value = v-round-method
  f-base = v-base
  .
  APPLY "VALUE-CHANGED" to s-round-method.
end.
enable
gds-grp.node-name
gds-grp.calc-method
gds-grp.increase-pc  when mode = {&add-def}
s-round-method when mode = {&add-def}
gds-grp.print-code
b-exit
b-quit
b-tax
b-help WITH FRAME {&frame-name}.
/* процент наценки и метод расчета можно менять только в терминальной группе,
   добавляется всегда терминальная */
if mode = {&update} then do:
  run enable-button-marg in this-procedure ( input gds-grp.node-code ) no-error.
  grp-code = gds-grp.node-code.
  if (v-round-method = ''
  or v-round-method = ?)
  and not can-find(first ub.gds-grp where ub.gds-grp.upper-code = grp-code)
  then do:
    assign
    v-round-method = {&pr-round-off}.
    s-round-method:screen-value = v-round-method.
  end.
  /*
  if can-find (first gds-grp where gds-grp.upper-code = grp-code no-lock) then
    hide gds-grp.calc-method gds-grp.increase-pc b-marg in frame {&frame-name}.
  */
end.
if mode = {&add-def} then do:
  /*найдем v-round-method для вышестоящего*/
  run grp-obj-margin-value in this-procedure (
                          input upper_gds-grp.node-code
                          , input p-obj-type
                          , input p-obj-code
                          , output v-min-marg
                          , output v-max-marg
                          , output v-increase-pc
                          , output v-round-method
                          , output v-base
                          , output v-margins-range
                          , output v-margins-exists
                          , output v-increase-range
                          , output v-increase-exists
                          , output v-rmethod-range
                          , output v-rmethod-exists

  ) no-error .
  if error-status:error or v-rmethod-exists = no then do:
    assign
    v-round-method = {&pr-round-off}
    .
  end.
  assign
  gds-grp.calc-method:screen-value = upper_gds-grp.calc-method
  s-round-method:screen-value = v-round-method
  f-base = v-base
  no-error .
  APPLY "VALUE-CHANGED" to S-round-method.
end.
WAIT-FOR GO OF FRAME {&FRAME-NAME}.
RUN disable_UI.

/* **********************  Internal Procedures  *********************** */

PROCEDURE disable_UI :
  HIDE FRAME {&frame-name}.
END PROCEDURE.

PROCEDURE enable-button-marg :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define input parameter p-node-code as integer      no-undo.

    define variable v-is-terminal     as logical           no-undo.

    define buffer buf_upper_gds-grp for ub.gds-grp.
    define buffer buf_node_gds-grp  for ub.gds-grp.
    if not b-marg :visible in FRAME {&frame-name}
    then do:
        /* Кнопка не видна, не надо анализировать */
    end.
    else do:
        run grplib-is-terminal in this-procedure ( input p-node-code, output v-is-terminal ) no-error.
        if error-status :error
        then do:
            undo, return error "enable-button-marg: Не удается определить, корневая группа или терминальная." + {&new-line} + return-value.
        end.
        if v-is-terminal = no
        then do:
            disable b-marg with FRAME {&frame-name}.
        end.
        else do:
            enable b-marg with FRAME {&frame-name}.
        end.
    end.
end.

END PROCEDURE.


{ gbl/cur-time.i }
{ ref/dtaxgrpr.i }

&UNDEFINE FRAME-NAME
&UNDEFINE WINDOW-NAME