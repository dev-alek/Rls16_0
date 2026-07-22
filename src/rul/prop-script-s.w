&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER X_prop-script FOR ub.prop-script.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Список prop-script


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
define input parameter p-list-mode as character no-undo .
define input parameter p-language as character no-undo .
define input parameter p-dtm-code as integer no-undo .
define input parameter p-proc-type as character no-undo .
define input parameter p-script-type as character no-undo .
define input-output parameter p-rid-list as character no-undo.


/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Список prop-script".
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
DEFINE VARIABLE link-option AS CHARACTER NO-UNDO.
define variable sort-column-name as character no-undo .
define variable filter-point-label as character no-undo init "Скрипты RULE-машины" .
define variable filter-point0 as character no-undo init "prop-script-s" .
define variable filter-point as character no-undo init "prop-script-s" .
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
&Scoped-define BROWSE-NAME br-prop-script

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_prop-script

/* Definitions for BROWSE br-prop-script                                */
&Scoped-define FIELDS-IN-QUERY-br-prop-script mark-string(recid(X_prop-script), v-rid-list) X_prop-script.dtm-code X_prop-script.class-dtm-code X_prop-script.language X_prop-script.script-name get-translation(X_prop-script.uniq-key-rec) entry(1, X_prop-script.script-value-type) (IF NUM-ENTRIES(X_prop-script.script-value-type) > 1 THEN entry(2, X_prop-script.script-value-type) ELSE '':U) X_prop-script.script-type X_prop-script.proc-type X_prop-script.revis_id
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-prop-script
&Scoped-define SELF-NAME br-prop-script
&Scoped-define QUERY-STRING-br-prop-script FOR EACH X_prop-script NO-LOCK
&Scoped-define OPEN-QUERY-br-prop-script OPEN QUERY br-prop-script FOR EACH X_prop-script NO-LOCK.
&Scoped-define TABLES-IN-QUERY-br-prop-script X_prop-script
&Scoped-define FIRST-TABLE-IN-QUERY-br-prop-script X_prop-script


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-br-prop-script}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit b-mark b-sel b-add b-chg b-del b-lkp ~
b-link b-sch B-Help rs-language b-copy cb-prop-head rs-find f-script-name ~
br-prop-script mark-num
&Scoped-Define DISPLAYED-OBJECTS rs-language cb-prop-head rs-find ~
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

/* Menu Definitions                                                     */
DEFINE MENU MENU-b-link
       MENU-ITEM m_pscript-ruleset LABEL "Привязка к наборам правил"
       MENU-ITEM m_rule-i-script LABEL "Привязка к правилам"
       MENU-ITEM m_ruledict-param LABEL "Параметры"     .


/* Definitions of the field level widgets                               */
DEFINE BUTTON b-add
     LABEL "&Добавить"
     SIZE 10 BY 1.

DEFINE BUTTON b-chg
     LABEL "&Изменить"
     SIZE 10 BY 1.

DEFINE BUTTON b-copy
     LABEL "&Копировать"
     SIZE 10 BY 1.

DEFINE BUTTON b-del
     LABEL "&Удалить"
     SIZE 10 BY 1.

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-link
     LABEL "Связи"
     SIZE 10 BY 1.

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

DEFINE VARIABLE cb-prop-head AS CHARACTER FORMAT "X(256)":U
     LABEL "Объект-операнд"
     VIEW-AS COMBO-BOX INNER-LINES 10
     LIST-ITEM-PAIRS "Item 1","Item 1"
     DROP-DOWN-LIST
     SIZE 80.5 BY 1 NO-UNDO.

DEFINE VARIABLE f-script-name AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 73 BY 1 NO-UNDO.

DEFINE VARIABLE mark-num AS INTEGER FORMAT "->,>>>,>>9":U INITIAL ?
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
DEFINE QUERY br-prop-script FOR
      X_prop-script SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-prop-script
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-prop-script Dialog-Frame _FREEFORM
  QUERY br-prop-script NO-LOCK DISPLAY
      mark-string(recid(X_prop-script), v-rid-list) Format "X(1)" COLUMN-LABEL "*"
X_prop-script.dtm-code format ">9"
X_prop-script.class-dtm-code format ">9" COLUMN-LABEL "Код!класса"
X_prop-script.language COLUMN-LABEL "lang" FORMAT "X(3)":U
    WIDTH 3
X_prop-script.script-name COLUMN-LABEL "Скрипт" FORMAT "X(255)":U
    WIDTH 40
get-translation(X_prop-script.uniq-key-rec) COLUMN-LABEL "Перевод" FORMAT "X(255)":U
          WIDTH 40
entry(1, X_prop-script.script-value-type) COLUMN-LABEL "Тип!знач" FORMAT "X(12)":U
    WIDTH 10
(IF NUM-ENTRIES(X_prop-script.script-value-type) > 1
 THEN entry(2, X_prop-script.script-value-type)
 ELSE '':U) COLUMN-LABEL "Объектн.!знач" FORMAT "X(12)":U
        WIDTH 10

X_prop-script.script-type FORMAT "X(255)":U
    WIDTH 15
X_prop-script.proc-type FORMAT "X(255)":U
    WIDTH 15
X_prop-script.revis_id FORMAT ">>>>>>>>9":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 97 BY 17.54 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     b-mark AT ROW 1 COL 24 WIDGET-ID 12
     b-sel AT ROW 1 COL 28 WIDGET-ID 10
     b-add AT ROW 1 COL 38 WIDGET-ID 2
     b-chg AT ROW 1 COL 48 WIDGET-ID 4
     b-del AT ROW 1 COL 58 WIDGET-ID 8
     b-lkp AT ROW 1 COL 68 WIDGET-ID 6
     b-link AT ROW 1 COL 78 WIDGET-ID 16
     b-sch AT ROW 1 COL 92 WIDGET-ID 20
     B-Help AT ROW 1 COL 95
     rs-language AT ROW 2 COL 21 NO-LABEL WIDGET-ID 48
     b-copy AT ROW 2 COL 48 WIDGET-ID 56
     cb-prop-head AT ROW 3 COL 1.5 WIDGET-ID 46
     rs-find AT ROW 4 COL 1.5 NO-LABEL WIDGET-ID 52
     f-script-name AT ROW 4 COL 25 NO-LABEL WIDGET-ID 18
     br-prop-script AT ROW 5 COL 1.5 WIDGET-ID 100
     mark-num AT ROW 1 COL 13 COLON-ALIGNED NO-LABEL WIDGET-ID 14
     SPACE(74.50) SKIP(21.52)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE ""
         CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: X_prop-script B "?" ? ub prop-script
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB br-prop-script f-script-name Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN
       b-link:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-b-link:HANDLE.

/* SETTINGS FOR COMBO-BOX cb-prop-head IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN f-script-name IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-prop-script
/* Query rebuild information for BROWSE br-prop-script
     _START_FREEFORM
OPEN QUERY br-prop-script FOR EACH X_prop-script NO-LOCK.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is OPENED
*/  /* BROWSE br-prop-script */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame
DO:
  p-rid-list = v-rid-list.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-add Dialog-Frame
ON CHOOSE OF b-add IN FRAME Dialog-Frame /* Добавить */
DO:
 define variable v-rec as recid no-undo.
  run rul/prop-script-i.w (  input parparentproc
                            ,input {&add-def}
                            ,INPUT p-dtm-code
                            ,input "ABL"
                            ,input '':U /*script-name*/
                            ,input 0 /*.revis_id*/
                            ,input-output v-rec) no-error.
  if v-rec <> ? then do:
    run openbr in this-procedure ( input yes, input no, input '':U).
    reposition br-prop-script to recid v-rec no-error.
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-chg Dialog-Frame
ON CHOOSE OF b-chg IN FRAME Dialog-Frame /* Изменить */
DO:
  define variable v-rec as recid no-undo.
  if not available X_prop-script then return no-apply.
  v-rec = recid(X_prop-script).
  run rul/prop-script-i.w ( input parparentproc
                       ,input {&update}
                       ,INPUT X_prop-script.dtm-code
                       ,input X_prop-script.language
                       ,input X_prop-script.script-name
                       ,input X_prop-script.revis_id
                       ,input-output v-rec) no-error.
  if v-rec <> ? then do:
     br-prop-script:refresh().
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-copy
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-copy Dialog-Frame
ON CHOOSE OF b-copy IN FRAME Dialog-Frame /* Копировать */
DO:
   define variable v-rec as recid no-undo.
   if not available X_prop-script then return no-apply.
   v-rec = recid(X_prop-script).
   run rul/prop-script-i.w (  input parparentproc
                             ,input {&add-copy}
                             ,INPUT X_prop-script.dtm-code
                             ,input "ABL"
                             ,input X_prop-script.script-name /*script-name*/
                             ,input X_prop-script.revis_id /*.revis_id*/
                             ,input-output v-rec) no-error.
   if v-rec <> ? then do:
     run openbr in this-procedure ( input yes, input no, input '':U).
     reposition br-prop-script to recid v-rec no-error.
   end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-del Dialog-Frame
ON CHOOSE OF b-del IN FRAME Dialog-Frame /* Удалить */
DO:
  define variable v-rec as recid no-undo.
  define variable glog as logical no-undo.
  if not available X_prop-script then return no-apply.
  v-rec = recid(X_prop-script).
  message "Вы уверены, что хотите удалить скрипт?"
  view-as alert-box question buttons yes-no update glog.
  if not glog then return no-apply.
 run rul/prop-script3.p ( input no /*p-silent */
                         ,input v-rec
                         ) no-error.
 if error-status:error then return no-apply.
 run openbr in this-procedure ( input yes, input no, input '':U).
 END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-link
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-link Dialog-Frame
ON CHOOSE OF b-link IN FRAME Dialog-Frame /* Связи */
DO:
  IF NOT AVAILABLE X_prop-script THEN RETURN NO-APPLY.
  IF link-option = '':U  THEN DO:
    run gbl/pop-up.p ( input self :handle, input no ) no-error.
    if error-status :error then do: return no-apply. end.
  end.
  if link-option = "":U then do:
      return no-apply.
  end.
  RUN proc-b-link IN THIS-PROCEDURE ( INPUT link-option) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
     link-option = '':U.
     RETURN NO-APPLY.
  END.
  link-option = '':U.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-lkp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-lkp Dialog-Frame
ON CHOOSE OF b-lkp IN FRAME Dialog-Frame /* Просмотр */
DO:
  define variable v-rec as recid no-undo.
  if not available X_prop-script then return no-apply.
  v-rec = recid(X_prop-script).
  run rul/prop-script-i.w ( input parparentproc
                       ,input {&lookup}
                       ,INPUT X_prop-script.dtm-code
                       ,input X_prop-script.language
                       ,input X_prop-script.script-name
                       ,input X_prop-script.revis_id
                       ,input-output v-rec) no-error.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-mark Dialog-Frame
ON CHOOSE OF b-mark IN FRAME Dialog-Frame /* * */
DO:
  define variable loc#log as logical no-undo .
  if available X_prop-script then do:
    { gbl/markstrn.i X_prop-script v-rid-list }
    loc#log = br-prop-script:refresh() .

    if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
        loc#log = br-prop-script:select-next-row ().
        apply "VALUE-CHANGED" to br-prop-script in frame {&frame-name}.
    end.
    if num-entries( v-rid-list ) = 0
    then
        hide mark-num in frame {&frame-name}.
    else
        disp num-entries( v-rid-list ) @ mark-num with frame {&frame-name}.
  end.
  apply "entry" to br-prop-script in frame {&frame-name}.

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
  if available X_prop-script then do:
    if  ( v-rid-list = "" ) or b-mark:sensitive = no
    then  v-rid-list = string( recid( X_prop-script ) ) .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME cb-prop-head
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL cb-prop-head Dialog-Frame
ON VALUE-CHANGED OF cb-prop-head IN FRAME Dialog-Frame /* Объект-операнд */
DO:
  ASSIGN cb-prop-head.
  RUN Openbr IN THIS-PROCEDURE ( input yes, input no, input '':U).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-script-name
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-script-name Dialog-Frame
ON CTRL-J OF f-script-name IN FRAME Dialog-Frame
DO:
  run proc-find-script-name in this-procedure ( input YES
                                              , input frame {&frame-name} f-script-name
                                              , INPUT rs-find) no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-script-name Dialog-Frame
ON RETURN OF f-script-name IN FRAME Dialog-Frame
DO:
  run proc-find-script-name in this-procedure ( input no
                                              , input frame {&frame-name} f-script-name
                                              , INPUT rs-find) no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_pscript-ruleset
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_pscript-ruleset Dialog-Frame
ON CHOOSE OF MENU-ITEM m_pscript-ruleset /* Привязка к наборам правил */
DO:
    IF NOT AVAILABLE X_prop-script THEN RETURN NO-APPLY.
  ASSIGN
  link-option = {&TABLE_pscript-ruleset}.
  RUN proc-b-link IN THIS-PROCEDURE ( INPUT link-option) NO-ERROR.
  IF error-status:ERROR THEN DO:
     link-option = '':U.
     RETURN NO-APPLY.
  END.
  link-option = '':U.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_rule-i-script
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_rule-i-script Dialog-Frame
ON CHOOSE OF MENU-ITEM m_rule-i-script /* Привязка к правилам */
DO:
  IF NOT AVAILABLE X_prop-script THEN RETURN NO-APPLY.
  ASSIGN
  link-option = {&TABLE_rule-i-SCRIPT}.
  RUN proc-b-link IN THIS-PROCEDURE ( INPUT link-option) NO-ERROR.
  IF error-status:ERROR THEN DO:
     link-option = '':U.
     RETURN NO-APPLY.
  END.
  link-option = '':U.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_ruledict-param
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_ruledict-param Dialog-Frame
ON CHOOSE OF MENU-ITEM m_ruledict-param /* Параметры */
DO:
     IF NOT AVAILABLE X_prop-script THEN RETURN NO-APPLY.
  ASSIGN
  link-option = {&TABLE_ruledict-param}.
  RUN proc-b-link IN THIS-PROCEDURE ( INPUT link-option) NO-ERROR.
  IF error-status:ERROR THEN DO:
     link-option = '':U.
     RETURN NO-APPLY.
  END.
  link-option = '':U.
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
      X_prop-script.script-name:VISIBLE IN browse br-prop-script = YES.
    END.
    WHEN "{&language}" THEN DO:
      X_prop-script.script-name:VISIBLE IN browse br-prop-script = NO.
    END.
  END CASE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-prop-script
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

{ gbl/brwrefre.i " v-doc-rec = recid(X_prop-script).  ~
  RUn OpenBR in this-procedure ( input yes, input no, input '':U).  REPOSITION br-prop-script to recid v-doc-rec No-ERROR. ~
  apply 'value-changed' to br-prop-script. " }

{ gbl/app_help.i }
{ gbl/setfltnm.i }
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
  RUN Myenable in this-procedure .
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
  DISPLAY rs-language cb-prop-head rs-find f-script-name mark-num
      WITH FRAME Dialog-Frame.
  ENABLE b-quit b-mark b-sel b-add b-chg b-del b-lkp b-link b-sch B-Help
         rs-language b-copy cb-prop-head rs-find f-script-name br-prop-script
         mark-num
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
DEFINE VARIABLE v-dtm-label AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-h AS handle NO-UNDO.
DEFINE BUFFER buf_prop-ruleset FOR ub.prop-ruleset.
DEFINE BUFFER buf_prop-head FOR ub.prop-head.
assign
cb-prop-head:DELIMITER in FRAME {&FRAME-NAME} = "|"
cb-prop-head:list-item-pairs =  " |-1"
X_prop-script.script-name:resizable in browse br-prop-script = yes
X_prop-script.script-type:resizable in browse br-prop-script = yes
X_prop-script.proc-type:resizable in browse br-prop-script = yes
b-link:MENU-MOUSE IN FRAME {&FRAME-NAME} = 1
v-h = br-prop-script:FIRST-COLUMN IN FRAME {&FRAME-NAME}
rs-language:RADIO-BUTTONS IN FRAME {&FRAME-NAME} = "ABL" + {&comma-char} + "ABL" + {&comma-char} +
                                                 "{&language}" + {&comma-char} + "{&language}"
rs-find = "begins"
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

if not (p-list-mode = "dtm-code") then do:
  _prop-ruleset:
  FOR EACH buf_prop-ruleset NO-LOCK WHERE
 BREAK BY buf_prop-ruleset.dtm-code:
    IF first-of(buf_prop-ruleset.dtm-CODE) THEN DO:
      FIND FIRST buf_prop-head NO-LOCK WHERE
                  buf_prop-head.dtm-code = buf_prop-ruleset.dtm-code NO-ERROR.
      IF NOT AVAILABLE buf_prop-head THEN DO:
          NEXT _prop-ruleset.
      END.
      v-dtm-label = replace(buf_prop-head.prop-label, "|", {&space-char}).
      cb-prop-head:ADD-LAST(v-dtm-label, string(buf_prop-ruleset.dtm-code)) IN FRAME {&FRAME-NAME}.
    END.
  END.
  ASSIGN
  cb-prop-head = "-1".
end.

ENABLE
b-quit
b-add WHEN (p-list-mode = "dtm-code" and lookup("b-add", bttns) > 0 and v-cntxt-db-num = 0)
b-copy when (lookup("b-add", bttns) > 0 and v-cntxt-db-num = 0)
b-chg when (lookup("b-add", bttns) > 0 and v-cntxt-db-num = 0)
b-del when (lookup("b-add", bttns) > 0 and v-cntxt-db-num = 0)
b-lkp
B-Help
b-mark when lookup("b-mark", bttns) > 0
b-sel when lookup("b-sel", bttns) > 0
b-link
b-sch
br-prop-script
f-script-name
cb-prop-head when not (p-list-mode = "dtm-code")
rs-language
rs-find
WITH FRAME {&frame-name}.
VIEW FRAME {&frame-name}.
if (p-list-mode = "dtm-code") then do:
  hide
  cb-prop-head
  in frame {&frame-name} .
end.

RUN Openbr IN THIS-PROCEDURE ( input yes, input no, input '':U).
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

&scop flt-open-open-query OPEN QUERY br-prop-script FOR EACH X_prop-script

&scop flt-open-dyn_open-query FOR EACH X_prop-script

&scop flt-open-query-handle  QUERY br-prop-script:handle

&scop flt-open-open-query-tail

&scop flt-open-query-was-opened  l-query-was-opened

&scop flt-open-sort-column-phrase sort-column-phrase

&scop flt-open-call-point filter-point

&scop flt-open-set-filter-name set-filter-name

&scop flt-open-indexed-reposition indexed-reposition

&scop flt-open-query p-open-query

&scop flt-open-table-name X_prop-script

&scop flt-open-search-option no-lock

&scop flt-open-find-next p-find-next

&scop flt-open-find-recid v-doc-rec

&scop flt-open-find-condition p-find-condition

&scop flt-open-find-buffer-name X_prop-script

&scop flt-open-waitfram true

define variable l-open-query as logical   no-undo .

filter-point = filter-point0 + p-list-mode.
CASE p-list-mode :
  WHEN {&all}        THEN DO:
    if cb-prop-head = string(-1 ) then do:
      assign filter-point-label = substitute("Все скрипты")
      .
      if p-open-query then do:
        assign
        frame {&frame-name}:title = filter-point-label
        .
      end.
      IF p-word-script-name = '':U  THEN DO:
          { gbl/fltopend.i
              &where-cond = " true  "
              &use-ind    = "  "
              &by         = "  " }

      END.
      ELSE DO:
          { gbl/fltopend.i
              &where-cond = " X_prop-script.script-name contains p-word-script-name "
              &dyn_where-cond = " substitute('X_prop-script.script-name contains &1&2&1', ~{&double-quote~}, p-word-script-name )"
              &use-ind    = "  "
              &by         = "  " }


      END.
    end.
    else do:
      assign
      filter-point-label = substitute("Все скрипты - объект-операнд &1", cb-prop-head)
      .
      if p-open-query then do:
        frame {&frame-name}:title = filter-point-label
        .
      end.
      IF p-word-script-name = '':U  THEN DO:
          { gbl/fltopend.i
              &where-cond = " X_prop-script.dtm-code = integer(cb-prop-head)  "
              &dyn_where-cond = " substitute('X_prop-script.dtm-code = integer(&1&2&1)', ~{&double-quote~}, cb-prop-head ) "
              &use-ind    = "  "
              &by         = "  " }
      END.
      ELSE DO:
          { gbl/fltopend.i
              &where-cond = " X_prop-script.dtm-code = integer(cb-prop-head) and ~
                              X_prop-script.script-name contains p-word-script-name "
              &dyn_where-cond = " substitute('X_prop-script.dtm-code = integer(&1&2&1) and ~
                              X_prop-script.script-name contains &1&3&1', ~{&double-quote~}, cb-prop-head, p-word-script-name)"

              &use-ind    = "  "
              &by         = "  " }

      END.
    end.
    END.
    when "dtm-code" then do:
      assign
      filter-point-label = substitute("Cкрипты для объекта-операнда &1", p-dtm-code)
      .
      if p-open-query then do:
        frame {&frame-name} :title = filter-point-label
        .
      end.
      IF p-word-script-name = '':U  THEN DO:
          { gbl/fltopend.i
                &where-cond = " X_prop-script.dtm-code = p-dtm-code  "
                &dyn_where-cond = " substitute('X_prop-script.dtm-code = &1', p-dtm-code)"
                &use-ind    = "  "
                &by         = "  " }

      END.
      ELSE DO:
          { gbl/fltopend.i
                &where-cond = " X_prop-script.dtm-code = p-dtm-code ~
                              and X_prop-script.script-name contains p-word-script-name "
                &dyn_where-cond = " substitute('X_prop-script.dtm-code = &1 ~
                              and X_prop-script.script-name contains &2&3&2 ', p-dtm-code, ~{&double-quote~}, p-word-script-name)"

                &use-ind    = "  "
                &by         = "  " }


      END.
  END.
END CASE.
if not p-open-query
and v-doc-rec <> ? then
REPOSITION br-prop-script to recid v-doc-rec No-ERROR.
if not p-open-query and v-fltopend-rowid[1] <> ? then
query br-prop-script:handle:reposition-to-rowid(v-fltopend-rowid) No-ERROR.
run waitfram-hide in this-procedure.
APPLY "VALUE-CHANGED" TO br-prop-script in frame {&frame-name}.
APPLY "ENTRY" TO br-prop-script.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-link Dialog-Frame
PROCEDURE proc-b-link :
DEFINE INPUT PARAMETER p-option AS CHARACTER no-undo.
DEFINE VARIABLE V-RID-LIST AS CHARACTER NO-UNDO.
DEFINE BUFFER buf_ruledict FOR ub.ruledict.
DEFINE BUFFER buf_ruledict-param FOR ub.ruledict-param.
CASE p-option:
    WHEN {&TABLE_rule-i-script} THEN DO:
      run rul/rule-i-script-s.w ( input parparentproc
                             ,INPUT "":U /*bttns*/
                             ,input "SCRIPT-NAME"
                             ,input 0 /*rule_id*/
                             ,INPUT x_PROP-SCRIPT.SCRIPT-TYPE /*script-type*/
                             ,INPUT x_PROP-SCRIPT.SCRIPT-NAME /*script-name*/
                             ,input-output v-RID-LIST) no-error.


    END.
    WHEN {&TABLE_pscript-ruleset} THEN DO:
    run rul/pscript-ruleset-s.w ( input parparentproc
                             ,INPUT (IF LOOKUP("B-ADD", BTTNS) > 0
                                     AND P-LIST-MODE = "DTM-CODE"
                                     THEN "b-add":U
                                     ELSE '':u) /*bttns*/
                             ,input "script-name"
                             ,input 0 /*codex_id*/
                             ,input 0 /*ruleset_id*/
                             ,INPUT X_prop-script.dtm-code /*dtm-code*/
                             ,INPUT X_prop-script.language /*dtm-code*/
                             ,INPUT X_prop-script.script-name /*script-name*/
                             ,input-output v-RID-LIST) no-error.


    END.
    WHEN {&TABLE_ruledict-param} THEN DO:
      FIND FIRST buf_ruledict no-lock WHERE
                buf_ruledict.entry-type = {&rdict-etype-prop-script}
           AND  buf_ruledict.uniq-key-rec = X_prop-script.uniq-key-rec NO-ERROR.
      IF NOT AVAILABLE buf_ruledict  THEN DO:
        MESSAGE
        "Еще отсутствует в словаре"
        VIEW-AS ALERT-BOX.
        RETURN error.
      END.
      find first buf_ruledict-param no-lock where
                buf_ruledict-param.entry-id = buf_ruledict.entry-id no-error.
      if not available buf_ruledict-param then do:
        message
        "Нет параметров!"
        view-as alert-box error .
        undo, return no-apply .
      end.
      run rul/ruledict-param-s.w ( INPUT parparentproc
                                   ,input ? /*p-update-proc-handle*/
                                   ,INPUT (IF LOOKUP("B-ADD", BTTNS) > 0
                                           AND P-LIST-MODE = "DTM-CODE"
                                           THEN "b-add":U
                                           ELSE '':u) /*bttns*/
                                   ,INPUT "entry-id"
                                   ,INPUT buf_ruledict.entry-id
                                   ,input {&rdict-etype-prop-script} /*p-entry-type*/
                                   ,INPUT-OUTPUT v-rid-list) NO-ERROR.
  END.
END CASE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-sch Dialog-Frame
PROCEDURE proc-b-sch :
assign
  tbl = 'prop-script'
  join-tbl = 'X_prop-script'
  fld = ""
  lab = ""
  spr = ""
  dim = '0'
  .
run fltfield-add in this-procedure('dtm-code', 'Код объекта-операнда', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('class-dtm-code', 'Код объекта-операнда обслуживающего класса', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('script-name', 'Название', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('documentation', 'Описание', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('signature', 'Сигнатура', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('proc-type', 'Тип процелуры', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('script-type', 'Тип скрипта', '',
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
        (input no /* p-open-query */
        ,input p-next  /* p-find-next  */
        ,input substitute("and X_prop-script.script-name begins &1 "
          , p-script-name)
        ).

  END.
  WHEN "contains" THEN DO:
    p-word-script-name = v-w-script-name.
        run OpenBr in this-procedure
            (input yes /* p-open-query */
            ,input NO  /* p-find-next  */
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