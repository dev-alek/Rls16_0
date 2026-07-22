&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE tt-dis-pos NO-UNDO LIKE ub.dis-cfg-rule
       field recid_ as recid.
DEFINE BUFFER X_dis-cfg-rule FOR ub.dis-cfg-rule.
DEFINE BUFFER X_dis-cp-rule FOR ub.dis-cp-rule.
DEFINE BUFFER X_dis-dc-rule FOR ub.dis-dc-rule.
DEFINE BUFFER X_dis-dct-rule FOR ub.dis-dct-rule.
DEFINE BUFFER X_dis-gds-rule FOR ub.dis-gds-rule.
DEFINE BUFFER X_dis-grp-rule FOR ub.dis-grp-rule.
DEFINE BUFFER X_dis-rule FOR ub.dis-rule.
DEFINE BUFFER X_dis-some-rule FOR ub.dis-some-rule.
DEFINE BUFFER X_dis-thbj-rule FOR ub.dis-thbj-rule.
DEFINE BUFFER X_dis-time-rule FOR ub.dis-time-rule.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Выбор типов возможных скидок

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/10/06
Author: Bakhtadze Natalya
Creation date: 12/10/06

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO.
define input parameter bttns  as CHARACTER   no-undo .
/*кнопки для нажатия*/
define input parameter p-mode  as CHARACTER   no-undo .
define input parameter p-has-glob as integer no-undo .
define input parameter p-has-host as integer no-undo .
define input parameter p-has-obj as integer no-undo .
define input parameter p-table-name  as CHARACTER   no-undo .
/*{&table_dis-gds-rule} {&table_dis-thbj-rule} {&table_dis-cp-rule} {&table_dis-dc-rule} {&table_dis-dct-rule} {&table_dis-grp-rule} {&table_dis-some-rule}*/
define input parameter p-classif-type as character no-undo .
define input parameter p-subject-type-list as character no-undo .
define input parameter p-pos-type  as CHARACTER   no-undo .
define input parameter p-discnt-role-list as character no-undo .
DEFINE INPUT-OUTPUT PARAMETER p-rid-list AS CHARACTER NO-UNDO.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Выбор типов возможных скидок".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/str-glbl.i }
{ gbl/getcntxt.i DEF }
{ cmp/library.i }
{ cmp/showinf.i }

define variable v-start as logical no-undo init yes.
/*
{ ref/disgdsru.i interface parparentproc }
{ ref/discprul.i interface parparentproc }
{ ref/disdcrul.i interface parparentproc }
{ ref/disdctru.i interface parparentproc }
*/
&glob cd-type-code tt-dis-pos.pos-type

&scop label_1 "Тип POS!(место использ)"
&scop label_6 "Код!шабл."
&scop label_7 "Код!шабл.!распис"
&scop label_8 "Тип расписания"
&scop label_9 "Описание"

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br-dis-pos

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-dis-pos X_dis-rule X_dis-time-rule

/* Definitions for BROWSE br-dis-pos                                    */
&Scoped-define FIELDS-IN-QUERY-br-dis-pos {&cd-type-name} rule-name( INPUT tt-dis-pos.table-name, INPUT tt-dis-pos.self-nonunique, INPUT tt-dis-pos.discnt-role) (tt-dis-pos.has-global = 1) (tt-dis-pos.has-host = 1) (tt-dis-pos.has-obj = 1) tt-dis-pos.templ-rl-root tt-dis-pos.time-templ-rl-root (IF AVAILABLE X_dis-time-rule THEN X_dis-time-rule.des ELSE "") X_dis-rule.des
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-dis-pos
&Scoped-define SELF-NAME br-dis-pos
&Scoped-define QUERY-STRING-br-dis-pos FOR EACH tt-dis-pos NO-LOCK, ~
             each X_dis-rule WHERE           X_dis-rule.templ-rl-root  = tt-dis-pos.templ-rl-root , ~
             FIRST X_dis-time-rule NO-LOCK WHERE             X_dis-time-rule.time-rule-num = tt-dis-pos.time-templ-rl-root OUTER-JOIN     NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-br-dis-pos OPEN QUERY {&SELF-NAME} FOR EACH tt-dis-pos NO-LOCK, ~
             each X_dis-rule WHERE           X_dis-rule.templ-rl-root  = tt-dis-pos.templ-rl-root , ~
             FIRST X_dis-time-rule NO-LOCK WHERE             X_dis-time-rule.time-rule-num = tt-dis-pos.time-templ-rl-root OUTER-JOIN     NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-br-dis-pos tt-dis-pos X_dis-rule ~
X_dis-time-rule
&Scoped-define FIRST-TABLE-IN-QUERY-br-dis-pos tt-dis-pos
&Scoped-define SECOND-TABLE-IN-QUERY-br-dis-pos X_dis-rule
&Scoped-define THIRD-TABLE-IN-QUERY-br-dis-pos X_dis-time-rule


/* Definitions for DIALOG-BOX Dialog-Frame                              */

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit B-mark B-sel B-Help br-dis-pos ~
mark-num
&Scoped-Define DISPLAYED-OBJECTS mark-num

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD rule-name Dialog-Frame
FUNCTION rule-name RETURNS CHARACTER
  ( INPUT p-table-name AS character, input p-classif-type as character, input p-discnt-role AS character )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-mark
     LABEL "&*"
     SIZE 3 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-sel AUTO-GO
     LABEL "Вы&бор"
     SIZE 10 BY 1.

DEFINE VARIABLE mark-num AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 6 BY 1
     FGCOLOR 4  NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-dis-pos FOR
      tt-dis-pos,
      X_dis-rule,
      X_dis-time-rule SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-dis-pos
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-dis-pos Dialog-Frame _FREEFORM
  QUERY br-dis-pos NO-LOCK DISPLAY
      {&cd-type-name} FORMAT "X(15)":U COLUMN-LABEL {&label_1}
rule-name( INPUT tt-dis-pos.table-name, INPUT tt-dis-pos.self-nonunique, INPUT tt-dis-pos.discnt-role) COLUMN-LABEL "Роль скидки" FORMAT "X(255)":U WIDTH 35
(tt-dis-pos.has-global = 1) FORMAT "+":U COLUMN-LABEL "Глоб"
(tt-dis-pos.has-host = 1) FORMAT "+":U COLUMN-LABEL "Фирма"
(tt-dis-pos.has-obj = 1) FORMAT "+":U COLUMN-LABEL "Объ."
tt-dis-pos.templ-rl-root FORMAT ">>>9":U COLUMN-LABEL {&label_6}
tt-dis-pos.time-templ-rl-root FORMAT "->>>>9":U COLUMN-LABEL {&label_7}
(IF AVAILABLE X_dis-time-rule
 THEN X_dis-time-rule.des
 ELSE "") FORMAT "X(80)":U COLUMN-LABEL {&label_8} WIDTH 20
X_dis-rule.des FORMAT "X(255)":U column-label {&label_9} WIDTH 45
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 12.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-mark AT ROW 1 COL 11
     B-sel AT ROW 1 COL 21
     B-Help AT ROW 1 COL 95
     br-dis-pos AT ROW 3 COL 1
     mark-num AT ROW 1 COL 12.5 COLON-ALIGNED NO-LABEL
     SPACE(78.50) SKIP(13.66)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Возможные типы скидок на товар"
         CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: tt-dis-pos T "?" NO-UNDO ub dis-cfg-rule
      ADDITIONAL-FIELDS:
          field recid_ as recid
      END-FIELDS.
      TABLE: X_dis-cfg-rule B "?" ? ub dis-cfg-rule
      TABLE: X_dis-cp-rule B "?" ? ub dis-cp-rule
      TABLE: X_dis-dc-rule B "?" ? ub dis-dc-rule
      TABLE: X_dis-dct-rule B "?" ? ub dis-dct-rule
      TABLE: X_dis-gds-rule B "?" ? ub dis-gds-rule
      TABLE: X_dis-grp-rule B "?" ? ub dis-grp-rule
      TABLE: X_dis-rule B "?" ? ub dis-rule
      TABLE: X_dis-some-rule B "?" ? ub dis-some-rule
      TABLE: X_dis-thbj-rule B "?" ? ub dis-thbj-rule
      TABLE: X_dis-time-rule B "?" ? ub dis-time-rule
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB br-dis-pos B-Help Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-dis-pos
/* Query rebuild information for BROWSE br-dis-pos
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt-dis-pos NO-LOCK,
      each X_dis-rule WHERE
          X_dis-rule.templ-rl-root  = tt-dis-pos.templ-rl-root ,
      FIRST X_dis-time-rule NO-LOCK WHERE
            X_dis-time-rule.time-rule-num = tt-dis-pos.time-templ-rl-root OUTER-JOIN
    NO-LOCK INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is NOT OPENED
*/  /* BROWSE br-dis-pos */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Возможные типы скидок на товар */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mark Dialog-Frame
ON CHOOSE OF B-mark IN FRAME Dialog-Frame /* * */
DO:
  define variable loc#log as logical no-undo .
  if available tt-dis-pos then do:
    { gbl/markstrn.i tt-dis-pos p-rid-list tt-dis-pos.recid_}
    loc#log = br-dis-pos:refresh() .
    if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
        loc#log = br-dis-pos:select-next-row ().
        apply "VALUE-CHANGED" to br-dis-pos in frame {&frame-name}.
    end.
    if num-entries( p-rid-list ) = 0
    then
        hide mark-num in frame {&frame-name}.
    else
        DISPLAY num-entries( p-rid-list ) @ mark-num with frame {&frame-name}.
  end.
  apply "entry" to br-dis-pos in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-sel Dialog-Frame
ON CHOOSE OF B-sel IN FRAME Dialog-Frame /* Выбор */
DO:
    if ( available tt-dis-pos ) then do:
    if  ( p-rid-list = "" ) or b-mark:sensitive = no
    then
    p-rid-list = string( tt-dis-pos.recid_ ) .
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-dis-pos
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.
{ gbl/app_help.i }
{ gbl/hot-key.i b-mark }
{ gbl/hot-key.i b-sel }
&scop b-quit ~{&b-exit~}
{ gbl/hot-key.i b-quit }


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  { gbl/getcntxt.i get }
  if lookup( p-mode, {&all} + {&comma-char} +
                     {&shop} + {&comma-char} +
                     {&stock} + {&comma-char} +
                     "cd-type-list" + {&comma-char} +
                     "cd-type-list-without-template-pos" + {&comma-char} +
                     "rum") = 0 then do:
    message
    substitute("Неверное значение параметра p-mode=&1", p-mode)
    view-as alert-box error .
    undo main-block, return error .
  end.
  run fill-table in this-procedure ( input p-table-name) no-error .
  if error-status:error then undo, return error .
  if return-value = "return" then return '':U.
  RUN Myenable IN THIS-PROCEDURE .
  run openbr in this-procedure .
  if return-value = "return" then return '':U.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI Dialog-Frame  _DEFAULT-DISABLE
PROCEDURE disable_UI :
/*------------------------------------------------------------------------------
  Purpose:     DISABLE the User Interface
  Parameters:  <none>
  Notes:       Here we clean-up the user-interface by deleting
               dynamic widgets we have created and/or hide
               frames.  This procedure is usually called when
               we are ready to "clean-up" after running.
------------------------------------------------------------------------------*/
  /* Hide all frames. */
  HIDE FRAME Dialog-Frame.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI Dialog-Frame  _DEFAULT-ENABLE
PROCEDURE enable_UI :
/*------------------------------------------------------------------------------
  Purpose:     ENABLE the User Interface
  Parameters:  <none>
  Notes:       Here we display/view/enable the widgets in the
               user-interface.  In addition, OPEN all queries
               associated with each FRAME and BROWSE.
               These statements here are based on the "Other
               Settings" section of the widget Property Sheets.
------------------------------------------------------------------------------*/
  DISPLAY mark-num
      WITH FRAME Dialog-Frame.
  ENABLE b-quit B-mark B-sel B-Help br-dis-pos mark-num
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-table Dialog-Frame
PROCEDURE fill-table :
DEFINE INPUT PARAMETER p-table-name AS CHARACTER NO-UNDO.
define variable v-found as logical no-undo .
define buffer buf_tt-dis-pos for tt-dis-pos.
FOR EACH tt-dis-pos:
  DELETE tt-dis-pos.
END.
case p-mode:
  when "rum" then do:
    for each X_dis-cfg-rule no-lock where
          X_dis-cfg-rule.pos-type = p-pos-type:
      if lookup(string(X_dis-cfg-rule.subject-type), p-subject-type-list) = 0  then next.

      find first buf_tt-dis-pos no-lock where
                buf_tt-dis-pos.discnt-role = X_dis-cfg-rule.discnt-role no-error.
      if available buf_tt-dis-pos then next.
      if X_dis-cfg-rule.link-prop <> integer({&dr-appl-object})
      and X_dis-cfg-rule.link-prop <> integer({&dr-no-rule}) then next.

      if p-has-glob = 1
      and p-has-host = 0
      and p-has-obj = 0
      and X_dis-cfg-rule.has-glob = 0 then next.
      if p-has-glob = 0
      and p-has-host = 1
      and p-has-obj = 0
      and X_dis-cfg-rule.has-host = 0 then next.
      if p-has-glob = 0
      and p-has-host = 0
      and p-has-obj = 1
      and X_dis-cfg-rule.has-obj = 0 then next.
      if p-discnt-role-list <> '':U
      and lookup( X_dis-cfg-rule.discnt-role, p-discnt-role-list) = 0 then next.
      CREATE tt-dis-pos.
      BUFFER-COPY
      X_dis-cfg-rule TO tt-dis-pos
      ASSIGN
      tt-dis-pos.RECID_ = RECID(X_dis-cfg-rule)
      .
      v-found = yes.
    end.
  end.
  when "cd-type-list-without-template-pos" then do:
    for each X_dis-cfg-rule no-lock where
            X_dis-cfg-rule.table-name = p-table-name
        and X_dis-cfg-rule.pos-type > "":U
            :
      if LOOKUP(X_dis-cfg-rule.pos-type, P-POS-TYPE) = 0 then next.
      find first buf_tt-dis-pos no-lock where
                buf_tt-dis-pos.discnt-role = X_dis-cfg-rule.discnt-role
             /*and buf_tt-dis-pos.pos-type = X_dis-cfg-rule.pos-type*/
                no-error.
      if available buf_tt-dis-pos then next.
      if X_dis-cfg-rule.link-prop <> integer({&dr-appl-object}) then next.
      if p-has-glob = 1
      and p-has-host = 0
      and p-has-obj = 0
      and X_dis-cfg-rule.has-glob = 0 then next.
      if p-has-glob = 0
      and p-has-host = 1
      and p-has-obj = 0
      and X_dis-cfg-rule.has-host = 0 then next.
      if p-has-glob = 0
      and p-has-host = 0
      and p-has-obj = 1
      and X_dis-cfg-rule.has-obj = 0 then next.
      if p-discnt-role-list <> '':U
      and lookup( X_dis-cfg-rule.discnt-role, p-discnt-role-list) = 0 then next.
      CREATE tt-dis-pos.
      BUFFER-COPY
      X_dis-cfg-rule TO tt-dis-pos
      ASSIGN
      tt-dis-pos.RECID_ = RECID(X_dis-cfg-rule)
      .
      v-found = yes.
    end.
  end.
  otherwise do:
    for each X_dis-cfg-rule no-lock where
            X_dis-cfg-rule.table-name = p-table-name
        and X_dis-cfg-rule.pos-type > "":U
            :
      if X_dis-cfg-rule.link-prop <> integer({&dr-appl-object}) then next.
      if p-has-glob = 1
      and p-has-host = 0
      and p-has-obj = 0
      and X_dis-cfg-rule.has-glob = 0 then next.
      if p-has-glob = 0
      and p-has-host = 1
      and p-has-obj = 0
      and X_dis-cfg-rule.has-host = 0 then next.
      if p-has-glob = 0
      and p-has-host = 0
      and p-has-obj = 1
      and X_dis-cfg-rule.has-obj = 0 then next.
      if p-discnt-role-list <> '':U
      and lookup( X_dis-cfg-rule.discnt-role, p-discnt-role-list) = 0 then next.
      CREATE tt-dis-pos.
      BUFFER-COPY
      X_dis-cfg-rule TO tt-dis-pos
      ASSIGN
      tt-dis-pos.RECID_ = RECID(X_dis-cfg-rule)
      .
      v-found = yes.
    end.
  end.
end case.
if not v-found then do:
  message
  "Нет ни одного (Доступного для редактирования) типа скидки с такими параметрами"
  view-as alert-box error .
  return "return".
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
DEFINE VARIABLE ii AS INTEGER NO-UNDO.
DEFINE VARIABLE ch AS WIDGET-HANDLE NO-UNDO.
ch = br-dis-pos:FIRST-COLUMN IN FRAME {&FRAME-NAME}.
DO ii = 1 TO br-dis-pos:NUM-COLUMNS IN FRAME {&FRAME-NAME}:
    ASSIGN
    ch:RESIZABLE = YES.
    if p-mode = "rum"
    or p-mode = "cd-type-list-without-template-pos"
    then do:
       if ch:label = {&label_6}
       or ch:label = {&label_7}
       or ch:label = {&label_8}
       or ch:label = {&label_9} then do:
         ch:visible = no.
       end.
    end.
    if p-mode = "cd-type-list-without-template-pos" then do:
      if ch:label = {&label_1} then do:
        ch:visible = no.
      end.
    end.
    ch = ch:NEXT-COLUMN.
END.

DISPLAY mark-num
WITH FRAME {&frame-name}.
ENABLE
b-quit
B-mark WHEn LOOKUP("b-mark", bttns) > 0
B-sel WHEN LOOKUP("b-sel", bttns) > 0
B-Help
br-dis-pos
mark-num
WITH FRAME {&frame-name}.
VIEW FRAME {&frame-name}.
HIDE
mark-num
IN FRAME {&FRAME-NAME}.
CASE p-table-name:
  WHEN {&table_dis-gds-rule} THEN DO:
     ASSIGN
     FRAME {&FRAME-NAME}:TITLE = "Возможные типы скидок на товар".
  END.
  WHEN {&table_dis-thbj-rule} THEN DO:
     ASSIGN
     FRAME {&FRAME-NAME}:TITLE = "Возможные типы общих скидок".
  END.
  WHEN {&table_dis-cp-rule} THEN DO:
     ASSIGN
     FRAME {&FRAME-NAME}:TITLE = "Возможные типы скидок на платеж".
  END.
  WHEN {&table_dis-dc-rule} THEN DO:
     ASSIGN
     FRAME {&FRAME-NAME}:TITLE = "Возможные типы скидок на отдельную ДК".
  END.
  WHEN {&table_dis-dct-rule} THEN DO:
     ASSIGN
     FRAME {&FRAME-NAME}:TITLE = "Возможные типы скидок на тип ДК".
  END.
  WHEN {&table_dis-grp-rule} THEN DO:
    case p-classif-type:
     when {&table_sum-grp} then do:
      ASSIGN
      FRAME {&FRAME-NAME}:TITLE = "Возможные типы скидок на группы товаров (на кассе)".
     end.
     when {&table_cli-grp} then do:
      ASSIGN
      FRAME {&FRAME-NAME}:TITLE = "Возможные типы скидок на группы клиентов".
     end.
    end case.
  END.
  WHEN {&table_dis-some-rule} THEN DO:
     ASSIGN
     FRAME {&FRAME-NAME}:TITLE = "Возможные типы скидок на что-то там".
  END.


END CASE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE openbr Dialog-Frame
PROCEDURE openbr :
if p-mode = {&all} then do:
  OPEN QUERY br-dis-pos
      FOR EACH tt-dis-pos NO-LOCK ,
          first X_dis-rule NO-LOCK WHERE
          X_dis-rule.rule-num  = tt-dis-pos.templ-rl-root,
           FIRST X_dis-time-rule NO-LOCK WHERE
            X_dis-time-rule.time-rule-num = tt-dis-pos.time-templ-rl-root outer-join
          INDEXED-REPOSITION.

end.
IF P-MODE = {&SHOP} THEN DO:
    OPEN QUERY br-dis-pos
        FOR EACH tt-dis-pos NO-LOCK where
              (tt-dis-pos.pos-type = p-pos-type
              OR tt-dis-pos.pos-type = {&cd-type-no-cd}),
            first X_dis-rule NO-LOCK WHERE
           X_dis-rule.rule-num  = tt-dis-pos.templ-rl-root,
        FIRST X_dis-time-rule NO-LOCK where
        X_dis-time-rule.time-rule-num = tt-dis-pos.time-templ-rl-root outer-join
           INDEXED-REPOSITION.

END.
IF P-MODE = {&STOCK} THEN DO:
    OPEN QUERY br-dis-pos
        FOR EACH tt-dis-pos NO-LOCK where
            tt-dis-pos.pos-type = {&cd-type-no-cd},
            first X_dis-rule NO-LOCK WHERE
           X_dis-rule.rule-num  = tt-dis-pos.templ-rl-root,
        FIRST X_dis-time-rule NO-LOCK where
         X_dis-time-rule.time-rule-num = tt-dis-pos.time-templ-rl-root outer-join
           INDEXED-REPOSITION.

END.
IF P-MODE = "CD-TYPE-LIST"
or p-mode = "rum"
THEN DO:
    OPEN QUERY br-dis-pos
        FOR EACH tt-dis-pos NO-LOCK where
            LOOKUP(tt-dis-pos.pos-type, P-POS-TYPE) > 0,
            first X_dis-rule NO-LOCK WHERE
           X_dis-rule.rule-num  = tt-dis-pos.templ-rl-root,
        FIRST X_dis-time-rule NO-LOCK where
         X_dis-time-rule.time-rule-num = tt-dis-pos.time-templ-rl-root outer-join
           INDEXED-REPOSITION.

END.
IF p-mode = "cd-type-list-without-template-pos"
THEN DO:
    OPEN QUERY br-dis-pos
        FOR EACH tt-dis-pos NO-LOCK,
            first X_dis-rule NO-LOCK ,
        FIRST X_dis-time-rule NO-LOCK outer-join
           INDEXED-REPOSITION.

END.

if not available tt-dis-pos and v-start then do:
  message
  "Нет ни одного (доступного для редактирования) типа скидки с такими параметрами"
  view-as alert-box error .
  return "return".
end.
v-start = no.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION rule-name Dialog-Frame
FUNCTION rule-name RETURNS CHARACTER
  ( INPUT p-table-name AS character, input p-classif-type as character, input p-discnt-role AS character ) :
DEFINE VARIABLE v-rule-name AS CHARACTER NO-UNDO.
&SCOPED-DEFINE dis-gds-rule-code p-discnt-role
&SCOPED-DEFINE dis-thbj-rule-code p-discnt-role
&SCOPED-DEFINE dis-cp-rule-code p-discnt-role
&SCOPED-DEFINE dis-dc-rule-code p-discnt-role
&SCOPED-DEFINE dis-dct-rule-code p-discnt-role
&scoped-define dis-ggr-rule-code p-discnt-role
&scoped-define dis-clgr-rule-code p-discnt-role

CASE p-table-name :
  WHEN {&TABLE_dis-gds-rule} THEN DO:
    v-rule-name = {&dis-gds-rule-name}.
  END.
  WHEN {&TABLE_dis-thbj-rule} THEN DO:
    v-rule-name = {&dis-thbj-rule-name}.
  END.
  WHEN {&TABLE_dis-cp-rule} THEN DO:
    v-rule-name = {&dis-cp-rule-name}.
  END.
  WHEN {&TABLE_dis-dc-rule} THEN DO:
    v-rule-name = {&dis-dc-rule-name}.
  END.
  WHEN {&TABLE_dis-dct-rule} THEN DO:
    v-rule-name = {&dis-dct-rule-name}.
  END.
  WHEN {&TABLE_dis-grp-rule} THEN DO:
    case p-classif-type:
      when {&table_sum-grp} then do:
        v-rule-name = {&dis-ggr-rule-name}.
      end.
      when {&table_cli-grp} then do:
        v-rule-name = {&dis-clgr-rule-name}.
      end.
    end case.
  END.



END CASE.

RETURN v-RULE-name.

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME