&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME d-gds-prt
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS d-gds-prt
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Справочник шкал

Автор: Перваков Михаил Сергеевич
Дата создания: 04/12/06
Author: Mikhail Pervakov
Creation date: 04/12/06

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO.
DEFine INPUT PARAMeter as-ref AS LOG   NO-UNDO.
DEFine OUTPUT PARAMeter rid    AS RECID NO-UNDO INIT ?.

define variable vss-revision    as character no-undo initial "$Revision$":U .
define variable vss-author      as character no-undo initial "$Author$":U .
define variable vss-date        as character no-undo initial "$Date$":U .
define variable vss-workfile    as character no-undo initial "$Workfile$":U .
define variable vss-archive     as character no-undo initial "$Archive$":U .
define variable vss-description as character no-undo initial "Справочник шкал".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ cmp/showinf.i  }
{ gbl/getcntxt.i def }

/* Local Variable Definitions ---                                       */
define variable rr as recid no-undo.
define variable conf-par as char no-undo.                  /* для чтения параметра конфигурации */
define variable par-type as char no-undo.                  /* тип параметра конфигурации */
define variable print-option as character no-undo.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME d-gds-prt
&Scoped-define BROWSE-NAME br-scales

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES ub.gds-prt

/* Definitions for BROWSE br-scales                                     */
&Scoped-define FIELDS-IN-QUERY-br-scales ub.gds-prt.node-name
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-scales
&Scoped-define QUERY-STRING-br-scales FOR EACH ub.gds-prt ~
      WHERE gds-prt.root = TRUE NO-LOCK
&Scoped-define OPEN-QUERY-br-scales OPEN QUERY br-scales FOR EACH ub.gds-prt ~
      WHERE gds-prt.root = TRUE NO-LOCK.
&Scoped-define TABLES-IN-QUERY-br-scales ub.gds-prt
&Scoped-define FIRST-TABLE-IN-QUERY-br-scales ub.gds-prt


/* Definitions for DIALOG-BOX d-gds-prt                                 */
&Scoped-define OPEN-BROWSERS-IN-QUERY-d-gds-prt ~
    ~{&OPEN-QUERY-br-scales}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-sel b-lkp b-add b-copy b-chg b-del ~
b-print b-help b-hist br-scales

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Menu Definitions                                                     */
DEFINE MENU MENU-b-print
       MENU-ITEM m_hor          LABEL "Уровни по горизонтали"
       MENU-ITEM m_vert         LABEL "Уровни по вертикали".


/* Definitions of the field level widgets                               */
DEFINE BUTTON b-add
     LABEL "&Добавить":L
     SIZE 10 BY 1.

DEFINE BUTTON b-chg
     LABEL "&Изменить":L
     SIZE 10 BY 1.

DEFINE BUTTON b-copy
     LABEL "&Копия":L
     SIZE 10 BY 1.

DEFINE BUTTON b-del
     LABEL "&Удалить":L
     SIZE 10 BY 1.

DEFINE BUTTON b-exit AUTO-END-KEY DEFAULT
     LABEL "&Выход ":L
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-help
     LABEL "Помо&щь":L
     SIZE 10 BY 1.

DEFINE BUTTON b-hist
     LABEL "Ис&тория":L
     SIZE 10 BY 1.

DEFINE BUTTON b-lkp
     LABEL "&Просмотр":L
     SIZE 10 BY 1.

DEFINE BUTTON b-print
     LABEL "Пе&чать":L
     SIZE 10 BY 1.

DEFINE BUTTON b-sel AUTO-GO
     LABEL "Вы&бор ":L
     SIZE 10 BY 1.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-scales FOR
      ub.gds-prt SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-scales
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-scales d-gds-prt _STRUCTURED
  QUERY br-scales NO-LOCK DISPLAY
      ub.gds-prt.node-name COLUMN-LABEL "Шкала" FORMAT "X(40)":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH SEPARATORS SIZE 43 BY 18.5 ROW-HEIGHT-CHARS .67.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME d-gds-prt
     b-exit AT ROW 1 COL 1
     b-sel AT ROW 1 COL 11
     b-lkp AT ROW 1 COL 21
     b-add AT ROW 1 COL 31
     b-copy AT ROW 1 COL 41
     b-chg AT ROW 1 COL 51
     b-del AT ROW 1 COL 61
     b-print AT ROW 1 COL 71
     b-help AT ROW 1 COL 81
     b-hist AT ROW 2 COL 71
     br-scales AT ROW 2.5 COL 22
     SPACE(30.12) SKIP(0.62)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "ШКАЛЫ  ТОВАРОВ":L
         DEFAULT-BUTTON b-exit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX d-gds-prt
                                                                        */
/* BROWSE-TAB br-scales b-hist d-gds-prt */
ASSIGN
       FRAME d-gds-prt:SCROLLABLE       = FALSE.

ASSIGN
       b-print:POPUP-MENU IN FRAME d-gds-prt       = MENU MENU-b-print:HANDLE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-scales
/* Query rebuild information for BROWSE br-scales
     _TblList          = "ub.gds-prt"
     _Options          = "NO-LOCK"
     _Where[1]         = "gds-prt.root = TRUE"
     _FldNameList[1]   > ub.gds-prt.node-name
"gds-prt.node-name" "Шкала" "X(40)" "character" ? ? ? ? ? ? no ? no no ? yes no no "U" "" ""
     _Query            is OPENED
*/  /* BROWSE br-scales */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME b-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-add d-gds-prt
ON CHOOSE OF b-add IN FRAME d-gds-prt /* Добавить */
DO:
run gbl/conf-rd.p ("is-prt", "", "", 0, "", "", "", yes, output conf-par, output par-type) no-error.
if error-status:error then return.
if par-type <> "L" then do:
  message "Неправильный тип параметра is-prt (должно быть logical)." view-as alert-box error.
  return.
end.
if conf-par <> "yes" then do:
  /* шкалы отключены */
  message  "Работа со шкалами в текущей конфигурации системы запрещена." conf-par view-as alert-box error.
  return no-apply.
end.

define variable v-ok as logical   no-undo .
{ gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_scale_update':U
  {&cntxt-global}
  0
  '':U
  0
  0
  0
  0
  true
  v-ok
}
if v-ok <> true
then do:
  return no-apply .
end.
run ref/prop.w
  (input  {&add-def} /* mode */
  ,input  ?          /* n-c  */
  ,output rr         /* rid  */
  ).
if rr = ? then return no-apply.
{&open-query-br-scales}
reposition br-scales to recid rr.
apply "ENTRY":U to br-scales .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-chg d-gds-prt
ON CHOOSE OF b-chg IN FRAME d-gds-prt /* Изменить */
DO:
define variable v-ok as logical   no-undo .
{ gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_scale_update':U
  {&cntxt-global}
  0
  '':U
  0
  0
  0
  0
  true
  v-ok
}
if v-ok <> true then do:
  return no-apply .
end.

if not available ub.gds-prt then do:
  message "Неправильный выбор шкалы.".
  return no-apply.
end.
if ub.gds-prt.node-name = {&empty-scale}  then do:
  message "Шкала пустая. Изменение невозможно.".
  return no-apply.
end.
run ref/prop.w
  (input  {&update}         /* mode */
  ,input  gds-prt.node-code /* n-c  */
  ,output rr                /* rid  */
  ).
if rr <> ? then do:
  {&open-query-br-scales}
  reposition br-scales to recid rr.
  apply "ENTRY":U to br-scales .
end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-copy
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-copy d-gds-prt
ON CHOOSE OF b-copy IN FRAME d-gds-prt /* Копия */
DO:
run gbl/conf-rd.p ("is-prt", "", "", 0, "", "", "", yes, output conf-par, output par-type) no-error.
if error-status :error then do:
  message "Ошибка при чтении параметра is-prt"
          view-as alert-box error.
  return.
end.
if par-type <> "L" then do:
  message "Неправильный тип параметра is-prt (должно быть logical)."
          view-as alert-box error.
  return.
end.
if lookup(conf-par, "true,yes") = 0
then do:
  /* шкалы отключены */
  message  "Работа со шкалами в текущей конфигурации системы запрещена."
           view-as alert-box error.
  return no-apply.
end.
define variable v-ok as logical   no-undo .
{ gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_scale_update':U
  {&cntxt-global}
  0
  '':U
  0
  0
  0
  0
  true
  v-ok
}
if v-ok <> true then do:
  return no-apply .
end.

if not available ub.gds-prt then do:
  message "Неправильный выбор шкалы."
          view-as alert-box error.
  return no-apply.
end.
if ub.gds-prt.node-name = {&empty-scale}  then do:
  message "Шкала пустая. Копирование невозможно."
          view-as alert-box error.
  return no-apply.
end.
run ref/prop.w
  (input  {&add-copy}       /* mode */
  ,input  gds-prt.node-code /* n-c  */
  ,output rr                /* rid  */
  ).
if rr <> ? then do:
  {&open-query-br-scales}
  reposition br-scales to recid rr no-error.
  apply "ENTRY":U to br-scales .
end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-del d-gds-prt
ON CHOOSE OF b-del IN FRAME d-gds-prt /* Удалить */
DO:

find first ub.db no-lock
  where ub.db.db-num <> 0
  no-error.
if available db then do:
  message
    "Нельзя удалять шкалу если есть УБД "
    view-as alert-box error.
  return no-apply.
end.

define variable v-ok as logical   no-undo .
{ gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_scale_update':U
  {&cntxt-global}
  0
  '':U
  0
  0
  0
  0
  true
  v-ok
}
if v-ok <> true then do:
    return no-apply .
end.

if not available ub.gds-prt then do:
    message "Неправильный выбор шкалы.".
    return no-apply.
end.
if ub.gds-prt.node-name = {&empty-scale} then do:
    message "Шкала пустая. Удаление невозможно.".
    return no-apply.
end.
assign
  rr = recid (ub.gds-prt)
.

assign
  v-ok = false
.
message
  "Удалить шкалу ?   Вы уверены ?"
  view-as alert-box question buttons OK-Cancel update v-ok .
if v-ok <> true then do:
  return no-apply.
end.
find first ub.goods
  where ub.goods.prt-root = ub.gds-prt.upper-code
  no-error .
if available goods then do:
  message
    "Шкала уже использована в товаре :" ub.goods.artic ub.goods.gds-name skip
    "Удаление невозможно." skip
    view-as alert-box error .
  return no-apply.
end.
run del-scale (ub.gds-prt.upper-code).
{&open-query-br-scales}
apply "ENTRY":U to br-scales .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-hist
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-hist d-gds-prt
ON CHOOSE OF b-hist IN FRAME d-gds-prt /* История */
DO:
 DEFINE VARIABLE rid-list AS character NO-UNDO.
 IF NOT AVAILABLE ub.gds-prt THEN RETURN NO-APPLY.
   run ref/cgdsprts.w (
                     input parparentproc
                    ,INPUT "":U /* bttns */
                    ,INPUT "prt-root":U /*parref-mode */
                    ,INPUT ub.gds-prt.prt-root
                    ,INPUT NO
                    ,OUTPUT rid-list
       ) .

 apply "ENTRY":U to br-scales .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-lkp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-lkp d-gds-prt
ON CHOOSE OF b-lkp IN FRAME d-gds-prt /* Просмотр */
DO:
  if not available ub.gds-prt then do:
    message
      "Неправильный выбор шкалы."
      view-as alert-box information .
    return no-apply.
  end.
  if ub.gds-prt.node-name = {&empty-scale}  then do:
    message
      "Шкала пустая. Просмотр не имеет смысла." skip
      view-as alert-box information .
    return no-apply.
  end.

  /* Просмотр шкалы */
  run str/scl-p.w
    (
     input parparentproc
    ,input v-cntxt-obj-type
    ,input v-cntxt-obj-code
    ,input {&lookup}
    ,input recid (gds-prt)
    ) .
  apply "entry" to br-scales in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-print d-gds-prt
ON CHOOSE OF b-print IN FRAME d-gds-prt /* Печать */
DO:
 if print-option = "" then do:
    run gbl/pop-up.p (b-print:handle, no) no-error.
 end.
 if print-option = "" then return no-apply.
CASE print-option:
    when "hor":U then do:
        run ref/gdsprtpr.p (parparentproc, ub.gds-prt.node-code) no-error.
    end.
    when "vert":U then do:
        run ref/gdsprtpv.p (parparentproc, ub.gds-prt.node-code) no-error.
    end.
END CASE.
print-option = "":U.
if error-status:error then do:
    return no-apply.
end.
apply "ENTRY":U to br-scales .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sel d-gds-prt
ON CHOOSE OF b-sel IN FRAME d-gds-prt /* Выбор  */
DO:
  define variable r as recid no-undo.

  if available ub.gds-prt  then do ON STOP UNDO, RETURN NO-APPLY :
      r = recid( ub.gds-prt ).
      find ub.gds-prt where recid( ub.gds-prt ) = r share-lock.
      rid = r.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-scales
&Scoped-define SELF-NAME br-scales
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-scales d-gds-prt
ON MOUSE-SELECT-DBLCLICK OF br-scales IN FRAME d-gds-prt
DO:
  if as-ref
      then apply "CHOOSE":U to b-sel.
      else apply "CHOOSE":U to b-lkp.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-scales d-gds-prt
ON RETURN OF br-scales IN FRAME d-gds-prt
DO:
  if as-ref
      then apply "CHOOSE":U to b-sel.
      else apply "CHOOSE":U to b-lkp.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_hor
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_hor d-gds-prt
ON CHOOSE OF MENU-ITEM m_hor /* Уровни по горизонтали */
DO:
  assign
  print-option = "hor":U.
  apply "CHOOSE" to b-print in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_vert
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_vert d-gds-prt
ON CHOOSE OF MENU-ITEM m_vert /* Уровни по вертикали */
DO:
    assign
  print-option = "vert":U.
  apply "CHOOSE" to b-print in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK d-gds-prt


IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

{ gbl/app_help.i }
{ gbl/hot-key.i b-lkp }
{ gbl/hot-key.i b-add }
{ gbl/hot-key.i b-chg }
{ gbl/hot-key.i b-del }
{ gbl/hot-key.i b-sel }

ON WINDOW-CLOSE OF FRAME {&FRAME-NAME} APPLY "END-ERROR":U TO SELF.

MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  { gbl/getcntxt.i get }
  if v-cntxt-db-num <> 0
  and not as-ref then do:
    message
    "Нельзя вызывать справочник шкал в режиме изменения в УБД"
    view-as alert-box error .
    return.
  end.
  RUN enable_UI.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE del-scale d-gds-prt
PROCEDURE del-scale :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
def input param u-c like ub.gds-prt.upper-code no-undo.
def buffer d-prt for ub.gds-prt.

for each d-prt where d-prt.upper-code = u-c:
  run del-scale (d-prt.node-code).
  delete d-prt.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI d-gds-prt  _DEFAULT-DISABLE
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
  HIDE FRAME d-gds-prt.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI d-gds-prt
PROCEDURE enable_UI :
/* --------------------------------------------------------------------
  Purpose:     ENABLE the User Interface
  Parameters:  <none>
  Notes:       Here we display/view/enable the widgets in the
               user-interface.  In addition, OPEN all queries
               associated with each FRAME and BROWSE.
               These statements here are based on the "Other
               Settings" section of the widget Property Sheets.
   -------------------------------------------------------------------- */
b-print:MENU-MOUSE in frame {&frame-name}  = 1.
  ENABLE br-scales b-lkp b-exit b-help b-hist
      b-sel WHEN as-ref
      b-del  WHEN not as-ref
      b-chg  WHEN not as-ref
      b-add WHEN not as-ref
      b-copy WHEN not as-ref
      b-print
      WITH FRAME {&frame-name}.
  {&OPEN-QUERY-br-scales}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME