&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER X_prop-head FOR ub.prop-head.
DEFINE BUFFER X_prop-script FOR ub.prop-script.
DEFINE BUFFER X_pscript-ruleset FOR ub.pscript-ruleset.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Список pscript-ruleset

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/11/05
Author: Bakhtadze Natalya
Creation date: 11/11/05

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .
define input parameter bttns as character no-undo.
DEFINE INPUT PARAMETER p-list-mode AS CHARACTER NO-UNDO.
/*{&all} "ruleset" "dtm-code" script-name*/
DEFINE INPUT PARAMETER p-codex-id AS INTEGER NO-UNDO.
DEFINE INPUT PARAMETER p-ruleset-id AS INTEGER NO-UNDO.
DEFINE INPUT PARAMETER p-dtm-code AS INTEGER NO-UNDO.
define input parameter p-language as character no-undo .
define input parameter p-script-name as character no-undo .
define input-output parameter p-rid-list as character no-undo.


/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Список pscript-ruleset".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i }
{ gbl/getcntxt.i def }
{ cmp/mrk-strf.i }
{ gbl/flt-def.i  }
{ gbl/fltfield.i }
{ gbl/fltopend.i defproc }

DEFINE VARIABLE v-doc-rec AS RECID NO-UNDO.
define variable sort-column-name as character no-undo .
define variable filter-point-label as character no-undo init "Привязка скриптов к наборам правил" .
define variable filter-point0 as character no-undo init "pscript-ruleset-s" .
define variable filter-point as character no-undo init "pscript-ruleset-s" .
DEFINE VARIABLE p-word-script-name AS CHARACTER NO-UNDO.
define variable v-rid-list as character no-undo .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br-pscript-ruleset

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_pscript-ruleset X_prop-script X_prop-head

/* Definitions for BROWSE br-pscript-ruleset                            */
&Scoped-define FIELDS-IN-QUERY-br-pscript-ruleset mark-string(recid(X_pscript-ruleset), v-rid-list) X_pscript-ruleset.codex_id X_pscript-ruleset.ruleset_id X_pscript-ruleset.dtm-code X_pscript-ruleset.revis_id X_pscript-ruleset.script-name get-translation(X_prop-script.uniq-key-rec) X_prop-head.prop-name X_prop-head.prop-label   
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-pscript-ruleset   
&Scoped-define SELF-NAME br-pscript-ruleset
&Scoped-define QUERY-STRING-br-pscript-ruleset FOR EACH X_pscript-ruleset NO-LOCK, ~
       FIRST X_prop-script no-lock, ~
       FIRST X_prop-head NO-LOCK
&Scoped-define OPEN-QUERY-br-pscript-ruleset OPEN QUERY br-pscript-ruleset FOR EACH X_pscript-ruleset NO-LOCK, ~
       FIRST X_prop-script no-lock, ~
       FIRST X_prop-head NO-LOCK.
&Scoped-define TABLES-IN-QUERY-br-pscript-ruleset X_pscript-ruleset ~
X_prop-script X_prop-head
&Scoped-define FIRST-TABLE-IN-QUERY-br-pscript-ruleset X_pscript-ruleset
&Scoped-define SECOND-TABLE-IN-QUERY-br-pscript-ruleset X_prop-script
&Scoped-define THIRD-TABLE-IN-QUERY-br-pscript-ruleset X_prop-head


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-br-pscript-ruleset}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit b-mark b-sel b-add b-chg b-del b-lkp ~
b-sch B-Help rs-language cb-pscript-ruleset rs-find f-script-name ~
br-pscript-ruleset mark-num 
&Scoped-Define DISPLAYED-OBJECTS rs-language cb-pscript-ruleset rs-find ~
f-script-name mark-num 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-translation Dialog-Frame 
FUNCTION get-translation RETURNS CHARACTER
  ( INPUT p-uniq-key-rec AS character )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-add 
     LABEL "&Добавить" 
     SIZE 10 BY 1.

DEFINE BUTTON b-chg 
     LABEL "&Изменить" 
     SIZE 10 BY 1.

DEFINE BUTTON b-del 
     LABEL "&Удалить" 
     SIZE 10 BY 1.

DEFINE BUTTON B-Help 
     LABEL "Помо&щь" 
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-lkp 
     LABEL "&Просмотр" 
     SIZE 10 BY 1.

DEFINE BUTTON b-mark 
     LABEL "&*" 
     SIZE 4 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY 
     LABEL "&Выход" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-sch 
     LABEL "&Фильтр" 
     SIZE 3 BY 1.

DEFINE BUTTON b-sel AUTO-GO 
     LABEL "Выбор" 
     SIZE 10 BY 1.

DEFINE VARIABLE cb-pscript-ruleset AS CHARACTER FORMAT "X(256)":U 
     LABEL "Объект-операнд" 
     VIEW-AS COMBO-BOX INNER-LINES 10
     LIST-ITEM-PAIRS "Item 1","Item 1"
     DROP-DOWN-LIST
     SIZE 80.5 BY 1 NO-UNDO.

DEFINE VARIABLE f-script-name AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 73.5 BY 1 NO-UNDO.

DEFINE VARIABLE mark-num AS INTEGER FORMAT "->,>>>,>>9":U INITIAL 0 
      VIEW-AS TEXT 
     SIZE 9 BY .67
     FGCOLOR 10  NO-UNDO.

DEFINE VARIABLE rs-find AS CHARACTER INITIAL "begins" 
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS 
          "Нач.назв.", "begins",
"Нач.слова", "contains"
     SIZE 23 BY 1 NO-UNDO.

DEFINE VARIABLE rs-language AS CHARACTER 
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS 
          "Item 1", "1",
"Item 2", "2"
     SIZE 24 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-pscript-ruleset FOR 
      X_pscript-ruleset, 
      X_prop-script, 
      X_prop-head SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-pscript-ruleset
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-pscript-ruleset Dialog-Frame _FREEFORM
  QUERY br-pscript-ruleset NO-LOCK DISPLAY
      mark-string(recid(X_pscript-ruleset), v-rid-list) Format "X(1)" COLUMN-LABEL "*"
X_pscript-ruleset.codex_id COLUMN-LABEL "Кодекс!правил" FORMAT ">>>>>>>>9"
X_pscript-ruleset.ruleset_id COLUMN-LABEL "Набор!правил" FORMAT ">>>>>>>>9"
X_pscript-ruleset.dtm-code COLUMN-LABEL "Код!объекта" FORMAT ">>>>>>>>9"
X_pscript-ruleset.revis_id COLUMN-LABEL "Версия" FORMAT ">>>>>>9"
X_pscript-ruleset.script-name COLUMN-LABEL "Имя скрипта" format "X(255)"
      width 45
get-translation(X_prop-script.uniq-key-rec) COLUMN-LABEL "Перевод" FORMAT "X(255)":U
        WIDTH 40
X_prop-head.prop-name COLUMN-LABEL "Имя объекта" format "X(32)"
X_prop-head.prop-label COLUMN-LABEL "Лейбл объекта" format "X(255)"
    width 45
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 97 BY 17.53 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     b-mark AT ROW 1 COL 24 WIDGET-ID 12
     b-sel AT ROW 1 COL 28 WIDGET-ID 10
     b-add AT ROW 1 COL 38 WIDGET-ID 2
     b-chg AT ROW 1 COL 48 WIDGET-ID 4
     b-del AT ROW 1 COL 58 WIDGET-ID 8
     b-lkp AT ROW 1 COL 68 WIDGET-ID 6
     b-sch AT ROW 1 COL 92 WIDGET-ID 48
     B-Help AT ROW 1 COL 95
     rs-language AT ROW 2 COL 21 NO-LABEL WIDGET-ID 52
     cb-pscript-ruleset AT ROW 3 COL 2 WIDGET-ID 46
     rs-find AT ROW 4 COL 1.5 NO-LABEL WIDGET-ID 56
     f-script-name AT ROW 4 COL 23 COLON-ALIGNED NO-LABEL WIDGET-ID 50
     br-pscript-ruleset AT ROW 5 COL 1.5 WIDGET-ID 100
     mark-num AT ROW 1 COL 13 COLON-ALIGNED NO-LABEL WIDGET-ID 14
     SPACE(74.50) SKIP(21.20)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Привязка скриптов объектов-операндов к наборам правил"
         CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: X_prop-head B "?" ? ub prop-head
      TABLE: X_prop-script B "?" ? ub prop-script
      TABLE: X_pscript-ruleset B "?" ? ub pscript-ruleset
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB br-pscript-ruleset f-script-name Dialog-Frame */
ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR COMBO-BOX cb-pscript-ruleset IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-pscript-ruleset
/* Query rebuild information for BROWSE br-pscript-ruleset
     _START_FREEFORM
OPEN QUERY br-pscript-ruleset
FOR EACH X_pscript-ruleset NO-LOCK, FIRST X_prop-script no-lock, FIRST X_prop-head NO-LOCK.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is OPENED
*/  /* BROWSE br-pscript-ruleset */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Привязка скриптов объектов-операндов к наборам правил */
DO:
  p-rid-list = v-rid-list.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Привязка скриптов объектов-операндов к наборам правил */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-add Dialog-Frame
ON CHOOSE OF b-add IN FRAME Dialog-Frame /* Добавить */
DO:
  run proc-b-add-chg in this-procedure ( input yes) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-chg
&Scoped-define SELF-NAME b-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-del Dialog-Frame
ON CHOOSE OF b-del IN FRAME Dialog-Frame /* Удалить */
DO:
  define variable v-rec as recid no-undo.
  define variable glog as logical no-undo.
  if not available X_pscript-ruleset then return no-apply.
  v-rec = recid(X_pscript-ruleset).
  message "Вы уверены, что хотите удалить привязку скрипта к набору правил?"
  view-as alert-box question buttons yes-no  update glog.
  if not glog then return no-apply.
  run rul/pscript-ruleset3.p ( input no /*p-silent*/
                               ,input v-rec
                                ) no-error.
  if error-status:error then return no-apply.
  Run Openbr in this-procedure ( input yes, input no, input '':U).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-lkp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-lkp Dialog-Frame
ON CHOOSE OF b-lkp IN FRAME Dialog-Frame /* Просмотр */
DO:
  define variable v-rec as recid no-undo.
  if not available X_pscript-ruleset then return no-apply.
  v-rec = recid(X_pscript-ruleset).
  run rul/prop-script-i.w ( input parparentproc
                       ,input {&lookup}
                       ,input X_pscript-ruleset.dtm-code
                       ,input X_pscript-ruleset.language
                       ,input X_pscript-ruleset.script-name
                       ,input X_pscript-ruleset.revis_id
                       ,input-output v-rec) no-error.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-mark Dialog-Frame
ON CHOOSE OF b-mark IN FRAME Dialog-Frame /* * */
DO:
    define variable glog as logical no-undo .
  if available X_pscript-ruleset then do:
 { gbl/markstrn.i X_pscript-ruleset v-rid-list }
  glog = br-pscript-ruleset:refresh() .

  if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
      glog = br-pscript-ruleset:select-next-row ().
      apply "VALUE-CHANGED" to br-pscript-ruleset in frame {&frame-name}.
  end.
  if num-entries( v-rid-list ) = 0
  then
      hide mark-num in frame {&frame-name}.
  else
      disp num-entries( v-rid-list ) @ mark-num with frame {&frame-name}.
end.
apply "entry" to br-pscript-ruleset in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sch
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sch Dialog-Frame
ON CHOOSE OF b-sch IN FRAME Dialog-Frame /* Фильтр */
DO:
  RUN proc-b-sch IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sel Dialog-Frame
ON CHOOSE OF b-sel IN FRAME Dialog-Frame /* Выбор */
DO:
  if available X_pscript-ruleset then do:
    if  ( v-rid-list = "" ) or b-mark:sensitive = no
    then  v-rid-list = string( recid( X_pscript-ruleset ) ) .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME cb-pscript-ruleset
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL cb-pscript-ruleset Dialog-Frame
ON VALUE-CHANGED OF cb-pscript-ruleset IN FRAME Dialog-Frame /* Объект-операнд */
DO:
  ASSIGN cb-pscript-ruleset.
  RUN Openbr IN THIS-PROCEDURE ( input yes, input no, input '':U).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-script-name
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-script-name Dialog-Frame
ON CTRL-J OF f-script-name IN FRAME Dialog-Frame
DO:
    run proc-find-script-name in this-procedure ( input YES
                                                 ,input frame {&frame-name} f-script-name
                                                 ,INPUT rs-find) no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-script-name Dialog-Frame
ON RETURN OF f-script-name IN FRAME Dialog-Frame
DO:
  run proc-find-script-name in this-procedure ( input NO
                                              , input frame {&frame-name} f-script-name
                                              , INPUT rs-find) no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME rs-find
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rs-find Dialog-Frame
ON VALUE-CHANGED OF rs-find IN FRAME Dialog-Frame
DO:
  ASSIGN
  rs-find.
  apply "ENTRY" to f-script-name.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME rs-language
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rs-language Dialog-Frame
ON VALUE-CHANGED OF rs-language IN FRAME Dialog-Frame
DO:
  ASSIGN
  rs-language.
  CASE rs-language:
    WHEN "ABL" THEN DO:
      X_pscript-ruleset.script-name:VISIBLE IN browse br-pscript-ruleset = YES.
    END.
    WHEN "{&language}" THEN DO:
      X_pscript-ruleset.script-name:VISIBLE IN browse br-pscript-ruleset = NO.
    END.
  END CASE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-pscript-ruleset
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame 


/* ***************************  Main Block  *************************** */

{ gbl/brwrefre.i " v-doc-rec = recid(X_pscript-ruleset).  ~
  RUn OpenBR in this-procedure ( input yes, input no, input '':U).  REPOSITION br-pscript-ruleset to recid v-doc-rec No-ERROR. ~
  apply 'value-changed' to br-pscript-ruleset. " }

{ gbl/setfltnm.i }
{ gbl/app_help.i }


/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  { gbl/getcntxt.i get }
  v-rid-list = p-rid-list.
  run Myenable in this-procedure .
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
  DISPLAY rs-language cb-pscript-ruleset rs-find f-script-name mark-num 
      WITH FRAME Dialog-Frame.
  ENABLE b-quit b-mark b-sel b-add b-chg b-del b-lkp b-sch B-Help rs-language 
         cb-pscript-ruleset rs-find f-script-name br-pscript-ruleset mark-num 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame 
PROCEDURE MyEnable :
DEFINE VARIABLE v-dtm-label AS CHARACTER no-undo.
DEFINE VARIABLE v-h AS handle NO-UNDO.
DEFINE BUFFER buf_prop-ruleset FOR ub.prop-ruleset.
DEFINE BUFFER buf_prop-head FOR ub.prop-head.
ASSIGN
v-h = br-pscript-ruleset:FIRST-COLUMN IN FRAME {&FRAME-NAME}
cb-pscript-ruleset:DELIMITER in FRAME {&FRAME-NAME} = "|"
cb-pscript-ruleset:LIST-ITEM-PAIRS  = "|-1":U
rs-language:RADIO-BUTTONS IN FRAME {&FRAME-NAME} = "ABL" + {&comma-char} + "ABL" + {&comma-char} +
                                                 "{&language}" + {&comma-char} + "{&language}"
rs-find = "contains"
.
DO while valid-handle(v-h) :
  if v-h:LABEL = "Перевод" then do:
    v-h:RESIZABLE = YES.
    leave.
  end.
  ELSE DO:
    v-h = v-h:NEXT-COLUMN.
  END.
END.

if not (p-list-mode = "dtm-code" or p-list-mode = "script-name") then do:
  _prop-ruleset:
  FOR EACH buf_prop-ruleset NO-LOCK WHERE
          buf_prop-ruleset.codex_id = p-codex-id
  BREAK BY buf_prop-ruleset.dtm-code:
    IF first-of(buf_prop-ruleset.dtm-CODE) THEN DO:
      FIND FIRST buf_prop-head NO-LOCK WHERE
                  buf_prop-head.dtm-code = buf_prop-ruleset.dtm-code NO-ERROR.
      IF NOT AVAILABLE buf_prop-head THEN DO:
          NEXT _prop-ruleset.
      END.
      v-dtm-label = replace(buf_prop-head.prop-label, "|", {&space-char}).
      cb-pscript-ruleset:ADD-LAST(v-dtm-label, string(buf_prop-ruleset.dtm-code)) IN FRAME {&FRAME-NAME}.
    END.
  END.
  ASSIGN
  cb-pscript-ruleset = "-1".
end.
assign
X_prop-head.prop-name :resizable in browse br-pscript-ruleset = yes
X_prop-head.prop-label:resizable in browse br-pscript-ruleset = yes
X_pscript-ruleset.script-name:resizable in browse br-pscript-ruleset = yes.
ENABLE
b-quit
b-add when ((p-list-mode = "ruleset"
             or p-list-mode = "dtm-code"
             or p-list-mode = "script-name"
             ) and v-cntxt-db-num = 0 and lookup("b-add", bttns) > 0)
b-del when (v-cntxt-db-num = 0  and lookup("b-add", bttns) > 0)
b-lkp
B-Help
b-sch
b-mark when lookup("b-mark", bttns) > 0
b-sel when lookup("b-sel", bttns) > 0
br-pscript-ruleset
cb-pscript-ruleset when not (p-list-mode = "dtm-code" or p-list-mode = "script-name")
f-script-name
rs-find
WITH FRAME {&frame-name}.
VIEW FRAME {&frame-name}.
if (p-list-mode = "dtm-code" or p-list-mode = "script-name") then do:
  hide
  cb-pscript-ruleset
  in frame {&frame-name} .
end.
if (p-list-mode = "script-name") then do:
  hide
  f-script-name
  in frame {&frame-name} .
end.

run Openbr in this-procedure ( input yes, input no, input '':U).
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Openbr Dialog-Frame 
PROCEDURE Openbr :
define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .
define variable l-query-was-opened as logical no-undo .
run waitfram-show in this-procedure ("Ждите...").
define variable sort-column-phrase as character no-undo .

case sort-column-name :
  when "" then do:
    assign
      sort-column-phrase = ""
    .
  end.
  otherwise do:
    assign
      sort-column-phrase = "by " + sort-column-name
    .
  end.
end case.
/* определяем здесь общие параметры для процедуры открытия query fltopend.i */


&scop flt-open-open-query OPEN QUERY br-pscript-ruleset FOR EACH X_pscript-ruleset

&scop flt-open-dyn_open-query FOR EACH X_pscript-ruleset

&scop flt-open-query-handle QUERY br-pscript-ruleset:handle

&scop flt-open-open-query-tail , FIRST X_prop-script NO-LOCK WHERE ~
X_prop-script.dtm-code = X_pscript-ruleset.dtm-code  ~
AND X_prop-script.language = X_pscript-ruleset.LANGUAGE ~
AND X_prop-script.script-name = X_pscript-ruleset.script-name ~
AND X_prop-script.revis_id = X_pscript-ruleset.revis_id ~
,first X_prop-head NO-LOCK OUTER-JOIN WHERE X_prop-head.dtm-code = X_pscript-ruleset.dtm-code


&scop flt-open-query-was-opened  l-query-was-opened

&scop flt-open-sort-column-phrase sort-column-phrase

&scop flt-open-call-point filter-point

&scop flt-open-set-filter-name set-filter-name

&scop flt-open-indexed-reposition indexed-reposition

&scop flt-open-query p-open-query

&scop flt-open-table-name X_pscript-ruleset

&scop flt-open-search-option no-lock

&scop flt-open-find-next p-find-next

&scop flt-open-find-recid v-doc-rec

&scop flt-open-find-condition p-find-condition

&scop flt-open-find-buffer-name X_pscript-ruleset

&scop flt-open-waitfram true

define variable l-open-query as logical   no-undo .

filter-point = filter-point0 + p-list-mode.
CASE p-list-mode :
  WHEN {&all}        THEN DO:
    if cb-pscript-ruleset = string(-1) then do:
      assign
      filter-point-label = substitute("Все связи СКРИПТ-НАБОРЫ ПРАВИЛ")
      .
      if p-open-query then do:
        frame {&frame-name}:title = filter-point-label
        .
      end.
      IF p-word-script-name = '':U THEN DO:
          { gbl/fltopend.i
              &where-cond = " true "
              &use-ind    = "  "
              &by         = "  " }

      END.
      ELSE DO:
          { gbl/fltopend.i
              &where-cond = " X_pscript-ruleset.script-name contains p-word-script-name "
              &dyn_where-cond = " substitute('X_pscript-ruleset.script-name contains &1&2&1', ~{&double-quote~}, p-word-script-name )"
              &use-ind    = "  "
              &by         = "  " }


      END.
    end.
    else do:
      assign
      filter-point-label =  substitute("Все связи СКРИПТ-НАБОРЫ ПРАВИЛ - с кодом объекта-операнда &1", cb-pscript-ruleset)
      .
      if p-open-query then do:
        frame {&frame-name}:title = filter-point-label
        .
      end.
      IF p-word-script-name = '':U THEN DO:
      { gbl/fltopend.i
          &where-cond = " X_pscript-ruleset.dtm-code =    integer(cb-pscript-ruleset) "
          &dyn_where-cond = " substitute('X_pscript-ruleset.dtm-code = integer(&1&2&1) ', ~{&double-quote~}, cb-pscript-ruleset)"
          &use-ind    = "  "
          &by         = "  " }
      END.
      ELSE DO:
        { gbl/fltopend.i
            &where-cond = " X_pscript-ruleset.dtm-code = integer(cb-pscript-ruleset) ~
                          and X_pscript-ruleset.script-name contains p-word-script-name "
            &dyn_where-cond = " substitute('X_pscript-ruleset.dtm-code = integer(&1&2&1) ~
                          and X_pscript-ruleset.script-name contains &1&3&1 ', ~{&double-quote~}, cb-pscript-ruleset, p-word-script-name)"
            &use-ind    = "  "
            &by         = "  " }

      END.
    end.
  END.
  WHEN "ruleset"       THEN DO:
    if cb-pscript-ruleset = string(-1) then do:
      assign
      filter-point-label = substitute("Скрипты для кодекса &1, набора правил &2"
                                            , p-codex-id
                                            , p-ruleset-id
                                            )
      .
      if p-open-query then do:
        frame {&frame-name}:title = filter-point-label
        .
      end.
      IF p-word-script-name = '':U THEN DO:
      { gbl/fltopend.i
          &where-cond = " X_pscript-ruleset.codex_id = p-codex-id ~
                    AND X_pscript-ruleset.ruleset_id = p-ruleset-id ~
                        "
          &dyn_where-cond = " substitute('X_pscript-ruleset.codex_id = &1 ~
                    AND X_pscript-ruleset.ruleset_id = &2 ', p-codex-id, p-ruleset-id)  "

          &use-ind    = "  "
          &by         = "  " }
      END.
      ELSE DO:
          { gbl/fltopend.i
              &where-cond = " X_pscript-ruleset.codex_id = p-codex-id ~
                        AND X_pscript-ruleset.ruleset_id = p-ruleset-id ~
                        and X_pscript-ruleset.script-name contains p-word-script-name ~
                            "
              &dyn_where-cond = " substitute('X_pscript-ruleset.codex_id = &1 ~
                        AND X_pscript-ruleset.ruleset_id = &2 ~
                        and X_pscript-ruleset.script-name contains &3&4&3 ', p-codex-id, p-ruleset-id, ~{&double-quote~}, p-word-script-name) "
              &use-ind    = "  "
              &by         = "  " }

      END.
    end.
    else do:
      assign
      filter-point-label = substitute("Скрипты для кодекса &1, набора правил &2 - с кодом объекта-операнда &3"
                                            , p-codex-id
                                            , p-ruleset-id
                                            ,cb-pscript-ruleset
                                            ).
      if p-open-query then do:
        frame {&frame-name}:title = filter-point-label
        .
      end.
      IF p-word-script-name = '':U THEN DO:
      { gbl/fltopend.i
          &where-cond = " X_pscript-ruleset.codex_id = p-codex-id ~
                    AND X_pscript-ruleset.ruleset_id = p-ruleset-id ~
                    AND X_pscript-ruleset.dtm-code = integer(cb-pscript-ruleset) ~
                        "
          &dyn_where-cond = " substitute('X_pscript-ruleset.codex_id = &1 ~
                    AND X_pscript-ruleset.ruleset_id = &2 ~
                    AND X_pscript-ruleset.dtm-code = integer(&3&4&3) ', p-codex-id, p-ruleset-id, ~{&double-quote~}, cb-pscript-ruleset) "

          &use-ind    = "  "
          &by         = "  " }
      END.
      ELSE DO:
          { gbl/fltopend.i
    &where-cond = " X_pscript-ruleset.codex_id = p-codex-id ~
              AND X_pscript-ruleset.ruleset_id = p-ruleset-id ~
              AND X_pscript-ruleset.dtm-code = integer(cb-pscript-ruleset)  ~
          and X_pscript-ruleset.script-name contains p-word-script-name ~
                  "
    &dyn_where-cond = " substitute('X_pscript-ruleset.codex_id = &1 ~
              AND X_pscript-ruleset.ruleset_id = &2 ~
              AND X_pscript-ruleset.dtm-code = integer(&3&4&3)  ~
          and X_pscript-ruleset.script-name contains &3&5&3 ', p-codex-id, p-ruleset-id, ~{&double-quote~}, cb-pscript-ruleset, p-word-script-name) "

    &use-ind    = "  "
    &by         = "  " }


      END.
    end.
  END.
  WHEN "dtm-code"       THEN DO:
    assign
    filter-point-label = substitute("Связи скриптов объекта &1 с наборами правил", p-dtm-code)
    .
    if p-open-query then do:
      frame {&frame-name}:title = filter-point-label
      .
    end.
    IF p-word-script-name = '':U THEN DO:
    { gbl/fltopend.i
        &where-cond = " X_pscript-ruleset.dtm-code = p-dtm-code ~
                      "
        &dyn_where-cond = " substitute('X_pscript-ruleset.dtm-code = &1', p-dtm-code )"
        &use-ind    = "  "
        &by         = "  " }
    END.
    ELSE DO:
        { gbl/fltopend.i
            &where-cond = " X_pscript-ruleset.dtm-code = p-dtm-code ~
                        and X_pscript-ruleset.script-name contains p-word-script-name ~
                          "
            &dyn_where-cond = " substitute('X_pscript-ruleset.dtm-code = &1 ~
                        and X_pscript-ruleset.script-name contains &2&3&2 ', p-dtm-code, ~{&double-quote~}, p-word-script-name) "

            &use-ind    = "  "
            &by         = "  " }

    END.
  END.
  WHEN "script-name"       THEN DO:
    assign
    filter-point-label = substitute("Связи скрипта &1 объекта-операнда &2 с наборами правил"
                                           , p-script-name
                                           , p-dtm-code)
    .
    if p-open-query then do:
      frame {&frame-name}:title = filter-point-label
      .
    end.
    { gbl/fltopend.i
        &where-cond = " X_pscript-ruleset.dtm-code = p-dtm-code ~
                    and X_pscript-ruleset.language = p-language ~
                    and X_pscript-ruleset.script-name = p-script-name ~
                      "
        &dyn_where-cond = " substitute('X_pscript-ruleset.dtm-code = &1 ~
                    and X_pscript-ruleset.language = &2&3&2 ~
                    and X_pscript-ruleset.script-name = &2&4&2 ', p-dtm-code, ~{&double-quote~}, p-language, p-script-name ) "

        &use-ind    = "  "
        &by         = "  " }
  END.
END CASE.
if not p-open-query and v-doc-rec <> ? then
REPOSITION br-pscript-ruleset to recid v-doc-rec No-ERROR.
if not p-open-query and v-fltopend-rowid[1] <> ? then
query br-pscript-ruleset:handle:reposition-to-rowid(v-fltopend-rowid) No-ERROR.
run waitfram-hide in this-procedure.
APPLY "VALUE-CHANGED" TO br-pscript-ruleset in frame {&frame-name}.
APPLY "ENTRY" TO br-pscript-ruleset.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-add-chg Dialog-Frame 
PROCEDURE proc-b-add-chg :
define input parameter p-add as logical no-undo .
define variable v-rid-list as character no-undo .
define variable v-rec as recid no-undo .
define variable v-ok as logical no-undo .
define variable v-is-dynamic as logical no-undo .
define variable v-ii as integer no-undo .
define buffer buf_prop-script for dictdb.prop-script.
define buffer buf_prop-ruleset for dictdb.prop-ruleset.
CASE p-add:
  when yes then do:
    if p-list-mode = "ruleset" then do:
      /*ВЫберем объект*/
      run rul/prop-ruleset-s.w ( input parparentproc
                            ,input "b-sel"
                            ,input "ruleset"
                            ,input p-codex-id
                            ,input p-ruleset-id
                            ,input 0 /*p-dtm-code*/
                            ,input-output v-rid-list
                            ) no-error.
      if v-rid-list = '':U then do:
        return.
      end.
      find first buf_prop-ruleset no-lock where
                recid(buf_prop-ruleset) = integer(v-rid-list).
      run rul/prop-script-s.w ( input parparentproc
                            ,input "b-sel"
                            ,input "dtm-code"
                            ,input '':U /*p-language*/
                            ,input buf_prop-ruleset.dtm-code
                            ,input '':U /* p-proc-type */
                            ,input '':U /* p-script-type */
                            ,input-output v-rid-list) no-error.
      if v-rid-list = '':U then do:
        return.
      end.
      do v-ii = 1 to num-entries( v-rid-list):
        find first buf_prop-script no-lock where
                  recid(buf_prop-script) = integer(entry(v-ii, v-rid-list)).
        run rul/pscript-ruleset1.p ( input {&add-def}
                                  ,input no /*p-silent*/
                                  ,input-output v-rec
                                  ,input  p-codex-id
                                  ,input  p-ruleset-id
                                  ,input buf_prop-script.dtm-code
                                  ,input buf_prop-script.language
                                  ,input buf_prop-script.script-name
                                  ,input buf_prop-script.revis_id
                                  ) no-error.
        if error-status:error then do:
          undo, return error .
        end.
      end.
    end.
    if p-list-mode = "dtm-code" then do:
      run rul/prop-ruleset-s.w ( input parparentproc
                            ,input "b-sel"
                            ,input "dtm-code"
                            ,input 0 /*p-codex-id*/
                            ,input 0 /*p-ruleset-id*/
                            ,input p-dtm-code
                            ,input-output v-rid-list
                            ) no-error.
      if v-rid-list = '':U then do:
        return.
      end.
      find first buf_prop-ruleset no-lock where
                recid(buf_prop-ruleset) = integer(v-rid-list).
      /*выбор скрита*/
      run rul/prop-script-s.w ( input parparentproc
                            ,input "b-sel,b-mark"
                            ,input "dtm-code"
                            ,input '':U /*p-language*/
                            ,input buf_prop-ruleset.dtm-code
                            ,input '':U /* p-proc-type */
                            ,input '':U /* p-script-type */
                            ,input-output v-rid-list) no-error.
      if v-rid-list = '':U then do:
        return.
      end.
      do v-ii = 1 to num-entries( v-rid-list):
        find first buf_prop-script no-lock where
                  recid(buf_prop-script) = integer(entry(v-ii, v-rid-list)).
        run rul/pscript-ruleset1.p ( input {&add-def}
                                  ,input no /*p-silent*/
                                  ,input-output v-rec
                                  ,input  buf_prop-ruleset.codex_id
                                  ,input  buf_prop-ruleset.ruleset_id
                                  ,input  buf_prop-script.dtm-code
                                  ,input buf_prop-script.language
                                  ,input buf_prop-script.script-name
                                  ,input buf_prop-script.revis_id
                                  ) no-error.
        if error-status:error then do:
          undo, return error .
        end.
      end.
    end.
    if p-list-mode = "script-name" then do:
      run rul/prop-ruleset-s.w ( input parparentproc
                            ,input "b-sel,b-mark"
                            ,input "dtm-code"
                            ,input 0 /*p-codex-id*/
                            ,input 0 /*p-ruleset-id*/
                            ,input p-dtm-code
                            ,input-output v-rid-list
                            ) no-error.
      if v-rid-list = '':U then do:
        return.
      end.
      find first buf_prop-script no-lock where
                buf_prop-script.dtm-code = p-dtm-code
           and  buf_prop-script.language = p-language
           and  buf_prop-script.script-name = p-script-name.
      do v-ii = 1 to num-entries( v-rid-list):
        find first buf_prop-ruleset no-lock where
                  recid(buf_prop-ruleset) = integer(entry(v-ii, v-rid-list)).
        run rul/pscript-ruleset1.p ( input {&add-def}
                                  ,input no /*p-silent*/
                                  ,input-output v-rec
                                  ,input buf_prop-ruleset.codex_id
                                  ,input buf_prop-ruleset.ruleset_id
                                  ,input buf_prop-script.dtm-code
                                  ,input buf_prop-script.language
                                  ,input buf_prop-script.script-name
                                  ,input buf_prop-script.revis_id
                                  ) no-error.
        if error-status:error then do:
          undo, return error .
        end.
      end.
    end.
    run openbr in this-procedure ( input yes, input no, input '':U).
    reposition br-pscript-ruleset to recid v-rec no-error.
    APPLY "ENTRY" to browse br-pscript-ruleset.
  end.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-sch Dialog-Frame 
PROCEDURE proc-b-sch :
assign
  tbl = 'pscript-ruleset'
  join-tbl = 'X_pscript-ruleset'
  fld = ""
  lab = ""
  spr = ""
  dim = '0'
  .
run fltfield-add in this-procedure('codex_id', 'Кодекс правил', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('ruleset_id', 'Набор правил', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('language', 'Язык', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('dtm-code', 'Код объекта-операнда', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('script-name', 'Скрипт', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('revis_id', 'Версия скрипта', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.



Filter-Block:
DO ON STOP    UNDO Filter-Block, LEAVE Filter-Block
    ON ERROR   UNDO Filter-Block, LEAVE Filter-Block
    ON END-KEY UNDO Filter-Block, LEAVE Filter-Block :
  run gbl/filter.w ( INPUT parparentproc
                   , INPUT filter-point + {&delim-par} + filter-point-label
                   , INPUT tbl
                   , INPUT join-tbl
                   , INPUT fld
                   , INPUT lab
                   , INPUT spr
                   , INPUT dim ).
  RUN OpenBr IN THIS-PROCEDURE (INPUT yes
                               ,INPUT no
                               ,INPUT '':U).
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-find-script-name Dialog-Frame 
PROCEDURE proc-find-script-name :
define input parameter p-next as logical no-undo.
define input parameter p-script-name AS CHARACTER no-undo.
define input parameter p-find-option AS CHARACTER no-undo.
define variable old-word-script-name as character no-undo .
define variable v-w-script-name as character no-undo .

assign
frame {&frame-name} f-script-name.
assign
p-script-name = replace(p-script-name, {&double-quote}, "":U)
p-script-name = replace(p-script-name, {&single-quote}, {&single-quote} + {&single-quote})
v-w-script-name = p-script-name
p-script-name = {&double-quote} + p-script-name + {&double-quote}.
CASE p-find-option:
  WHEN "begins" THEN DO:
    old-word-script-name = p-word-script-name.
    p-word-script-name = '':U.
    v-doc-rec = ?.
    if old-word-script-name <> p-word-script-name then do:
      run OpenBr in this-procedure
          (input yes /* p-open-query */
          ,input no  /* p-find-next  */
          ,input '':U
          ).
    end.
    run OpenBr in this-procedure
        (input false /* p-open-query */
        ,input p-next  /* p-find-next  */
        ,input substitute("and X_pscript-ruleset.script-name contains &1 "
          , p-script-name)
        ).
  END.
  WHEN "contains":U  THEN DO:
    p-word-script-name = p-script-name.
    run OpenBr in this-procedure
        (input yes /* p-open-query */
        ,input no  /* p-find-next  */
        ,input '':U
        ).

  END.
END CASE.
apply "entry":u to f-script-name in frame {&frame-name} .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-translation Dialog-Frame 
FUNCTION get-translation RETURNS CHARACTER
  ( INPUT p-uniq-key-rec AS character ) :
DEFINE BUFFER buf_ruledict FOR ub.ruledict.
FIND FIRST buf_ruledict NO-LOCK WHERE
          buf_ruledict.entry-type = {&rdict-etype-prop-script}
    AND   buf_ruledict.uniq-key-rec = p-uniq-key-rec NO-ERROR.
IF AVAILABLE buf_ruledict THEN DO:
   RETURN buf_ruledict.script-nl.
END.
ELSE DO:
    RETURN '':U.
END.
END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

