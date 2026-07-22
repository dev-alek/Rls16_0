&Scop WINDOW-NAME d-c-grp-f
&Scop FRAME-NAME    d-c-grp-f

/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Форма для создания и редактирования группы клиентов

Автор: Белоусов Илья Александрович
Дата создания: 04/12/06
Author: Ilia Belousov
Creation date: 04/12/06

Input:

Output:

*/
/* ***************************  Definitions  ************************** */
define input parameter parparentproc as widget-handle no-undo .
define input parameter mode as char no-undo.
define input parameter up-code like ub.cli-grp.upper-code no-undo.
define input-output parameter rid as recid no-undo.

define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Форма для создания и редактирования группы клиентов" .
{ cmp/vssrevis.i }
{ cmp/str-glbl.i  }
{ cmp/library.i }
{ ref/cgrplib.i  }
{ cmp/showinf.i  }

define variable grp-code like ub.cli-grp.node-code no-undo.
define variable v-need-update   as logical  init yes    no-undo.
define buffer upper_cli-grp for ub.cli-grp.
/* ***********************  Control Definitions  ********************** */

DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Ввод ":L
     SIZE 10 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена":L
     SIZE 10 BY 1.

DEFINE BUTTON b-help AUTO-END-KEY
     LABEL "Помо&щь":L
     SIZE 3 BY 1.

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME {&frame-name}
b-exit AT ROW 1 COL 1
b-quit AT ROW 1 COL 11
b-help AT ROW 1 COL 21
ub.cli-grp.node-name AT ROW 3.25 COL 7.5 COLON-ALIGNED LABEL "Группа" VIEW-AS FILL-IN SIZE 41 BY 1
SPACE (16.65) SKIP (0.35) WITH VIEW-AS DIALOG-BOX SIDE-LABELS THREE-D SCROLLABLE DEFAULT-BUTTON b-exit.

/* ***************  Runtime Attributes and UIB Settings  ************** */

ASSIGN FRAME {&frame-name}:SCROLLABLE = FALSE.

/* ************************  Control Triggers  ************************ */

ON GO OF FRAME {&frame-name} DO:
define variable v-grp-name      as character         no-undo.
define variable v-error-code    as integer           no-undo.
DEFINE VARIABLE v-node-code     like ub.cli-grp.node-code no-undo .
DEFINE VARIABLE v-upper-code    like ub.cli-grp.upper-code no-undo .
define buffer buf_cli-grp       for ub.cli-grp.

 do on endkey undo, return no-apply on error undo, return no-apply on stop undo, return no-apply:
    if mode = {&add-def}  then do:
      assign
      v-node-code = 0
      v-upper-code = up-code
        .
    end.
  else do:
    assign
      v-node-code = ub.cli-grp.node-code
      v-upper-code = ub.cli-grp.upper-code
      .
  end.
  run ref/cligrp01.p (
                  input mode
                  ,input no
                  ,input no /*p-get-node-code*/
                  ,input-output  v-node-code
                  ,input-output  v-upper-code
                  ,input frame {&frame-name} cli-grp.node-name
                  ,output rid
                  ) no-error .
  if error-status:error then UNDO, return no-apply.
 end.
END.

/* ***************************  Main Block  *************************** */

{ gbl/app_help.i }

IF CURRENT-WINDOW:WINDOW-STATE = WINDOW-MINIMIZED
THEN CURRENT-WINDOW:WINDOW-STATE = WINDOW-NORMAL.

ON WINDOW-CLOSE OF FRAME {&FRAME-NAME} APPLY "END-ERROR":U TO SELF.
if mode = {&add-def} then do:
  find upper_cli-grp no-lock where
       upper_cli-grp.node-code = up-code no-error .
  if not avail upper_cli-grp then do:
    message
    vss-workfile vss-revision vss-description skip
    "Не найдена группа с кодом"
    up-code
    view-as alert-box error .
    return error .
  end.
end.

if mode = {&update} then
  find cli-grp where recid (cli-grp) =  rid.
rid = ?. /* rid <> ? --> запись добавлена / изменена */
frame {&frame-name}:title = "ГРУППА КЛИЕНТОВ   -    " + mode.
if available cli-grp then
display cli-grp.node-name  WITH FRAME {&frame-name}.
enable
cli-grp.node-name
b-exit
b-quit
b-help WITH FRAME {&frame-name}.
/* процент скидки можно менять только в терминальной группе, добавляется всегда терминальная */
if mode = {&update} then do:
  grp-code = cli-grp.node-code.
  /*
  if can-find (first gds-grp where gds-grp.upper-code = grp-code no-lock)
  then do:
    assign
        v-need-update = no
    .
  end.
  */
end.
WAIT-FOR GO OF FRAME {&FRAME-NAME}.
RUN disable_UI.

/* **********************  Internal Procedures  *********************** */

PROCEDURE disable_UI :
  HIDE FRAME {&frame-name}.
END PROCEDURE.

&UNDEFINE FRAME-NAME
&UNDEFINE WINDOW-NAME