&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER X_ext-classif FOR ub.ext-classif.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Соответствие клиентов в разных TH

Автор: Бахтадзе Наталья Викторовна
Дата создания: 07/31/07
Author: Bakhtadze Natalya
Creation date: 07/31/07

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO.
DEFINE INPUT PARAMETER bttns AS character NO-UNDO.
define input parameter p-from-version as character no-undo .
DEFINE INPUT PARAMETER p-list-mode AS character NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER p-rid-list AS character NO-UNDO.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Соответствие клиентов в разных TH".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/trg-def.i }
{ cmp/showinf.i }
{ cmp/library.i }
{ gbl/getcntxt.i def }
{ gbl/key-rec.i }
{ gbl/flt-def.i  }
{ gbl/fltfield.i }
{ cmp/mrk-strf.i }
{ ref/extclass.i }
{ gbl/cur-time.i }
{ cmp/r-pril.i }
{ gbl/prn-lib.i }
{ gbl/fltopend.i defproc }
{ gbl/color.i }
{ cmp/ththclit.i " new shared "}
{ cmp/thth150.i }
{ cmp/thth14.i }
define variable sort-column-name as character no-undo.
define variable filter-point     as character NO-UNDO INIT "thth-cli".
define variable filter-label     as character NO-UNDO INIT "Соответствие клиентов в разных TH".
define variable filter-point0     as character NO-UNDO INIT "thth-cli".
define variable filter-label0     as character NO-UNDO INIT "Соответствие клиентов в разных TH".
DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
DEFINE VARIABLE copy-option  AS CHARACTER NO-UNDO.
define variable v-doc-rec as recid no-undo .
define variable v-closed as character no-undo .
define variable v-type as character no-undo .
define variable v-attr-code as character no-undo .
define variable v-cli-classif-name as character no-undo .
&scop cli-type-code-label "КЛИЕНТ!"

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br-clients

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_ext-classif

/* Definitions for BROWSE br-clients                                    */
&Scoped-define FIELDS-IN-QUERY-br-clients mark-string(recid(X_ext-classif), v-rid-list) (X_ext-classif.key#_three = 1) (IF X_ext-classif.uniq-key-rec BEGINS {&table_clients} THEN (entry(2, X_ext-classif.uniq-key-rec, {&delim-key}) + entry(3, X_ext-classif.uniq-key-rec, {&delim-key}) ) ELSE '' ) (X_ext-classif.charkey_one + string(X_ext-classif.KEY#_one)) X_ext-classif.charkey_two X_ext-classif.charkey_three
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-clients
&Scoped-define SELF-NAME br-clients
&Scoped-define QUERY-STRING-br-clients FOR EACH X_ext-classif NO-LOCK OUTER-JOIN INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-br-clients OPEN QUERY {&SELF-NAME} FOR EACH X_ext-classif NO-LOCK OUTER-JOIN INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-br-clients X_ext-classif
&Scoped-define FIRST-TABLE-IN-QUERY-br-clients X_ext-classif


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-br-clients}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit B-mark B-sel b-tie b-copy b-imp ~
b-close b-sch b-print B-Help rs-key#_three b-imp-gds sch-old-code ~
rs-cli-type sch-self-code br-clients f-cli-name mark-num
&Scoped-Define DISPLAYED-OBJECTS rs-key#_three sch-old-code rs-cli-type ~
sch-self-code f-cli-name mark-num

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-cli-name Dialog-Frame
FUNCTION get-cli-name RETURNS CHARACTER
  ( INPUT p-uniq-key-rec AS character )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Menu Definitions                                                     */
DEFINE MENU MENU-b-copy
       MENU-ITEM m_one          LABEL "Текущий"
       MENU-ITEM m_list         LABEL "Отмеченные (только без соответствия)"
       MENU-ITEM m_all          LABEL "ВСЕ (только без соответствия)".


/* Definitions of the field level widgets                               */
DEFINE BUTTON b-close
     LABEL "Закр"
     SIZE 8 BY 1.

DEFINE BUTTON b-copy
     LABEL "Копировать из"
     SIZE 20 BY 1.

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-imp
     LABEL "Получ.соответствие"
     SIZE 20 BY 1 TOOLTIP "Получение соответствия данных по клиентам системы TH".

DEFINE BUTTON b-imp-gds
     LABEL "Сведение по товарам"
     SIZE 20 BY 1 TOOLTIP "Получение соответствия данных по клиентам системы TH".

DEFINE BUTTON B-mark
     LABEL "&*"
     SIZE 3 BY 1.

DEFINE BUTTON b-print
     LABEL "&Печать"
     SIZE 3 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-sch
     LABEL "Фильтр"
     SIZE 3 BY 1.

DEFINE BUTTON B-sel AUTO-GO
     LABEL "Вы&бор"
     SIZE 10 BY 1.

DEFINE BUTTON b-tie
     LABEL "Связать"
     SIZE 10 BY 1.

DEFINE VARIABLE f-cli-name AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 98 BY .93
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE mark-num AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 6 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE sch-old-code AS INTEGER FORMAT ">>>>>>>>9":U INITIAL 0
     LABEL "Поиск по коду"
     VIEW-AS FILL-IN
     SIZE 10 BY 1 NO-UNDO.

DEFINE VARIABLE sch-self-code AS INTEGER FORMAT ">>>>>>>>9":U INITIAL 0
     LABEL "Поиск по коду v16.0"
     VIEW-AS FILL-IN
     SIZE 10 BY 1 NO-UNDO.

DEFINE VARIABLE rs-cli-type AS CHARACTER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Item 1", "1"
     SIZE 13.5 BY .8 NO-UNDO.

DEFINE VARIABLE rs-key#_three AS INTEGER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Все", -1,
"В работе", 0,
"Сведенные ранее", 2,
"Были уже до upgrade", 1
     SIZE 59 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-clients FOR X_ext-classif SCROLLING.

&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-clients
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-clients Dialog-Frame _FREEFORM
  QUERY br-clients NO-LOCK DISPLAY
      mark-string(recid(X_ext-classif), v-rid-list) COLUMN-LABEL "" FORMAT "X(1)"
(X_ext-classif.key#_three = 1) COLUMN-LABEL "До upg" FORMAT "+/"
(IF X_ext-classif.uniq-key-rec BEGINS {&table_clients}
 THEN (entry(2, X_ext-classif.uniq-key-rec, {&delim-key}) +
       entry(3, X_ext-classif.uniq-key-rec, {&delim-key})
       )
ELSE ''
    ) COLUMN-LABEL "КЛИЕНТ!v16.0" FORMAT "X(12)"
(X_ext-classif.charkey_one + string(X_ext-classif.KEY#_one))  COLUMN-LABEL {&cli-type-code-label} FORMAT "X(12)"
X_ext-classif.charkey_two COLUMN-LABEL "{&abbr_INN_ALLSHIFT}" FORMAT "X(12)"
X_ext-classif.charkey_three COLUMN-LABEL "Название КЛИЕНТА в" FORMAT "X(60)"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 18.43 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-mark AT ROW 1 COL 11 WIDGET-ID 4
     B-sel AT ROW 1 COL 21 WIDGET-ID 6
     b-tie AT ROW 1 COL 31 WIDGET-ID 20
     b-copy AT ROW 1 COL 41 WIDGET-ID 22
     b-imp AT ROW 1 COL 61 WIDGET-ID 18
     b-close AT ROW 1 COL 81 WIDGET-ID 26
     b-sch AT ROW 1 COL 89 WIDGET-ID 12
     b-print AT ROW 1 COL 92 WIDGET-ID 10
     B-Help AT ROW 1 COL 95
     rs-key#_three AT ROW 2 COL 1.5 NO-LABEL WIDGET-ID 30
     b-imp-gds AT ROW 2 COL 61 WIDGET-ID 28
     sch-old-code AT ROW 3 COL 22 COLON-ALIGNED WIDGET-ID 38
     rs-cli-type AT ROW 3 COL 34.5 NO-LABEL WIDGET-ID 36
     sch-self-code AT ROW 3 COL 70 COLON-ALIGNED WIDGET-ID 40
     br-clients AT ROW 4 COL 1 WIDGET-ID 100
     f-cli-name AT ROW 22.33 COL 1 NO-LABEL WIDGET-ID 24
     mark-num AT ROW 1 COL 12.5 COLON-ALIGNED NO-LABEL WIDGET-ID 8
     SPACE(79.30) SKIP(21.26)
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
      TABLE: X_ext-classif B "?" ? ub ext-classif
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB br-clients sch-self-code Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN
       b-copy:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-b-copy:HANDLE.

/* SETTINGS FOR FILL-IN f-cli-name IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-clients
/* Query rebuild information for BROWSE br-clients
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH X_ext-classif NO-LOCK
OUTER-JOIN INDEXED-REPOSITION.
     _END_FREEFORM
     _START_FREEFORM_DEFINE
DEFINE QUERY br-clients FOR X_ext-classif SCROLLING.
     _END_FREEFORM_DEFINE
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is OPENED
*/  /* BROWSE br-clients */
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


&Scoped-define SELF-NAME b-close
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-close Dialog-Frame
ON CHOOSE OF b-close IN FRAME Dialog-Frame /* Закр */
DO:
  RUN proc-close IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN UNDO, RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-copy
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-copy Dialog-Frame
ON CHOOSE OF b-copy IN FRAME Dialog-Frame /* Копировать из */
DO:
  if copy-option = "":U then do:
    run gbl/pop-up.p ( input self :handle, input no ) no-error.
    if error-status :error then do: return no-apply. end.
  end.
  if copy-option = "":U then do:
      return no-apply.
  end.
  RUN proc-copy IN THIS-PROCEDURE ( INPUT copy-option) NO-ERROR.
  copy-option = ''.
  APPLY "entry" TO br-clients.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-imp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-imp Dialog-Frame
ON CHOOSE OF b-imp IN FRAME Dialog-Frame /* Получ.соответствие */
DO:
  RUN proc-imp IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-imp-gds
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-imp-gds Dialog-Frame
ON CHOOSE OF b-imp-gds IN FRAME Dialog-Frame /* Сведение по товарам */
DO:
  RUN proc-imp-gds IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mark Dialog-Frame
ON CHOOSE OF B-mark IN FRAME Dialog-Frame /* * */
DO:
  define variable loc#log as logical no-undo .
  if available X_ext-classif then do:
    { gbl/markstrn.i X_ext-classif v-rid-list }
    loc#log = br-clients:refresh() .

    if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
        loc#log = br-clients:select-next-row ().
        apply "VALUE-CHANGED" to br-clients in frame {&frame-name}.
    end.
    if num-entries( v-rid-list ) = 0
    then
        hide mark-num in frame {&frame-name}.
    else
        disp num-entries( v-rid-list ) @ mark-num with frame {&frame-name}.
  end.
  apply "entry" to br-clients in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-print Dialog-Frame
ON CHOOSE OF b-print IN FRAME Dialog-Frame /* Печать */
DO:
  run proc-b-print IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sch
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sch Dialog-Frame
ON CHOOSE OF b-sch IN FRAME Dialog-Frame /* Фильтр */
DO:
  run proc-b-sch IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-sel Dialog-Frame
ON CHOOSE OF B-sel IN FRAME Dialog-Frame /* Выбор */
DO:
    if ( available X_ext-classif ) then do:
    if  ( v-rid-list = "" ) or b-mark:sensitive = no
    then
    v-rid-list = string( recid( X_ext-classif ) ) .
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-tie
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-tie Dialog-Frame
ON CHOOSE OF b-tie IN FRAME Dialog-Frame /* Связать */
DO:
  if not available X_ext-classif then return no-apply.
  RUN proc-b-tie IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-clients
&Scoped-define SELF-NAME br-clients
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-clients Dialog-Frame
ON VALUE-CHANGED OF br-clients IN FRAME Dialog-Frame
DO:
 DEFINE VARIABLE v-cli-name AS CHARACTER NO-UNDO.
 IF AVAILABLE X_ext-classif
 and X_ext-classif.uniq-key-rec <> ''
 THEN DO:
     v-cli-name = get-cli-name (INPUT X_ext-classif.uniq-key-rec ) .
  END.
  ELSE DO:
     v-cli-name = ''.
  END.
  f-cli-name:SCREEN-VALUE = v-cli-name.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_all
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_all Dialog-Frame
ON CHOOSE OF MENU-ITEM m_all /* ВСЕ (только без соответствия) */
DO:
  ASSIGN
  copy-option = "all".
  APPLY "CHOOSE" TO b-copy IN FRAME {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_list
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_list Dialog-Frame
ON CHOOSE OF MENU-ITEM m_list /* Отмеченные (только без соответствия) */
DO:
  IF v-rid-list = '' THEN do:
     MESSAGE
     "Нет выбранных записей"
     VIEW-AS ALERT-BOX .
     RETURN NO-APPLY.
  END.
  ASSIGN
  copy-option = "list".
  APPLY "choose" TO b-copy IN FRAME {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_one
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_one Dialog-Frame
ON CHOOSE OF MENU-ITEM m_one /* Текущий */
DO:
  IF NOT AVAILABLE X_ext-classif THEN RETURN NO-APPLY.
  ASSIGN
  copy-option = "one".
  APPLY "CHOOSE" TO b-copy IN FRAME {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME rs-cli-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rs-cli-type Dialog-Frame
ON VALUE-CHANGED OF rs-cli-type IN FRAME Dialog-Frame
DO:
  ASSIGN
  rs-cli-type.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME rs-key#_three
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rs-key#_three Dialog-Frame
ON VALUE-CHANGED OF rs-key#_three IN FRAME Dialog-Frame
DO:
  ASSIGN
  rs-key#_three .
  if available X_ext-classif then v-doc-rec = recid(X_ext-classif).
  run openbr in this-procedure ( INPUT YES, INPUT NO, INPUT '':U) no-error.
  reposition br-clients to recid(v-doc-rec) no-error. APPLy 'ENTRY' to br-clients .


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME sch-old-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-old-code Dialog-Frame
ON RETURN OF sch-old-code IN FRAME Dialog-Frame /* Поиск по коду */
DO:

  run proc-find-old-code in this-procedure ( input no, input frame {&frame-name} sch-old-code) no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME sch-self-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-self-code Dialog-Frame
ON RETURN OF sch-self-code IN FRAME Dialog-Frame /* Поиск по коду v16.0 */
DO:
  run proc-find-self-code in this-procedure ( input no, input frame {&frame-name} sch-self-code) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.
{ gbl/app_help.i }
{ gbl/setfltnm.i }

{ gbl/hot-key.i b-print }
{ gbl/hot-key.i b-mark }
{ gbl/hot-key.i b-sel }
&scop b-quit ~{&b-exit~}
{ gbl/hot-key.i b-quit }

{ gbl/brwrefre.i "if available X_ext-classif then v-doc-rec = recid(X_ext-classif). ~
run openbr in this-procedure ( INPUT YES, INPUT NO, INPUT '':U) no-error. reposition br-clients to recid(v-doc-rec) no-error. APPLy 'ENTRY' to br-clients ." }

ON ROW-DISPLAY OF br-clients IN frame {&frame-name}
DO:
  IF AVAIL X_ext-classif THEN DO:
    RUN set-row-color.
  END.
END.


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
 { gbl/getcntxt.i get }
  v-rid-list = p-rid-list.
  case p-from-version:
    when {&thth150-from-version} then do:
      v-cli-classif-name = {&extclass_clients_th-th150}.
      if p-list-mode = {&g___object} then do:
        v-attr-code = {&attr-thth150-shop}.
      end.
      else do:
        v-attr-code = {&attr-thth150-clients}.
      end.
      run thth150-db-attr-value in this-procedure ( input g#db-num
                                                ,input v-attr-code
                                                ,output v-closed
                                                ,output v-type) .
    end.
    when {&thth14-from-version} then do:
      v-cli-classif-name = {&extclass_clients_th-th14}.
      if p-list-mode = {&g___object} then do:
        v-attr-code = {&attr-thth14-shop}.
      end.
      else do:
        v-attr-code = {&attr-thth14-clients}.
      end.
      run thth14-db-attr-value in this-procedure ( input g#db-num
                                                ,input v-attr-code
                                                ,output v-closed
                                                ,output v-type) .
    end.
    otherwise do:
      message
      substitute("Неверное значение параметра p-from-version=&1", p-from-version)
      view-as alert-box error .
      undo main-block, return error .
    end.
  end case. /*case p-from-version:*/
  RUN Myenable.
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
  DISPLAY rs-key#_three sch-old-code rs-cli-type sch-self-code f-cli-name
          mark-num
      WITH FRAME Dialog-Frame.
  ENABLE b-quit B-mark B-sel b-tie b-copy b-imp b-close b-sch b-print B-Help
         rs-key#_three b-imp-gds sch-old-code rs-cli-type sch-self-code
         br-clients f-cli-name mark-num
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
define variable v-cli-type-code-h as handle no-undo .
/*установим лейблы*/
v-cli-type-code-h = br-clients:FIRST-COLUMN IN FRAME {&FRAME-NAME}.
DO while valid-handle(v-cli-type-code-h) :
  if v-cli-type-code-h:LABEL = {&cli-type-code-label} then do:
    leave.
  end.
  ELSE DO:
    v-cli-type-code-h = v-cli-type-code-h:NEXT-COLUMN.
  END.
END.

assign
b-copy:label in frame {&frame-name} = substitute("&1 &2"
                                                  , b-copy:label in frame {&frame-name}
                                                  , p-from-version)
b-imp:tooltip in frame {&frame-name} = substitute("&1 &2"
                                                  , b-imp:tooltip in frame {&frame-name}
                                                  , p-from-version)
b-imp-gds:tooltip in frame {&frame-name} = substitute("&1 &2"
                                                  , b-imp-gds:tooltip in frame {&frame-name}
                                                  , p-from-version)
sch-old-code:label in frame {&frame-name} = substitute("&1 &2"
                                                  , sch-old-code:label in frame {&frame-name}
                                                  , p-from-version)
X_ext-classif.charkey_three:LABEL  in browse br-clients = substitute("&1 &2"
                                                            , X_ext-classif.charKEY_three:LABEL  in browse br-clients
                                                            ,p-from-version)
v-cli-type-code-h:label  = substitute("&1 &2"
                                    , v-cli-type-code-h:label
                                    , p-from-version)
.
assign
b-copy:menu-mouse in frame {&frame-name} = 1
X_ext-classif.charkey_two:visible in browse br-clients = (p-list-mode <> {&g___object})
X_ext-classif.charkey_three:resizable in browse br-clients = yes
rs-key#_three = 0
.
if p-list-mode = {&g___object} then do:
  b-imp:label in frame {&frame-name} = "Получение данных".
end.
rs-cli-type:radio-buttons in frame {&frame-name} = {&cmp} + {&comma-char} + {&cmp} + {&comma-char} +
                                                   {&prs} + {&comma-char} + {&prs}.
rs-cli-type = {&cmp}.
display
rs-key#_three
rs-cli-type
with frame {&frame-name} .

ENABLE
b-mark
b-quit
b-print
b-imp when (v-cntxt-db-num = 0 and lookup("b-add", bttns) > 0 and not transaction and logical(v-closed) = no)
b-imp-gds when (v-cntxt-db-num = 0 and lookup("b-add", bttns) > 0 and not transaction and logical(v-closed) = no
                AND p-list-mode <> {&g___object})
b-tie when (v-cntxt-db-num = 0 and lookup("b-add", bttns) > 0 and not transaction and logical(v-closed) = no)
b-copy when (v-cntxt-db-num = 0 and lookup("b-add", bttns) > 0 and not transaction and p-list-mode <> {&g___Object} and logical(v-closed) = no)
b-sch
B-Help
b-close when (v-cntxt-db-num = 0 and lookup("b-add", bttns) > 0 and not transaction and logical(v-closed) = no)
br-clients
rs-cli-type
rs-key#_three
sch-old-code
sch-self-code
b-sel  when lookup("b-sel", bttns) > 0
WITH FRAME {&frame-name}.
VIEW FRAME {&frame-name}.
RUN Openbr IN THIS-PROCEDURE ( INPUT YES, INPUT NO, INPUT '':U).
APPLy "entry" to br-clients.
apply "value-changed" to br-clients.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OpenBr Dialog-Frame
PROCEDURE OpenBr :
define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .
define variable sort-column-phrase as character no-undo .
define variable l-query-was-opened as logical no-undo .
define variable title0 as character no-undo .

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
&scop flt-open-debug-file

&scop flt-open-open-query         OPEN QUERY br-clients FOR EACH X_ext-classif no-lock

&scop flt-open-dyn_open-query     FOR EACH X_ext-classif no-lock


&scop flt-open-query-handle      QUERY br-clients:handle

&scop flt-open-open-query-tail

&scop flt-open-query-was-opened   l-query-was-opened

&scop flt-open-sort-column-phrase sort-column-phrase

&scop flt-open-call-point         filter-point

&scop flt-open-set-filter-name    set-filter-name

&scop flt-open-indexed-reposition INDEXED-REPOSITION

&scop flt-open-waitfram yes

filter-point = filter-point0 + p-list-mode .

&scop flt-open-search-option no-lock

&scop flt-open-find-next p-find-next

&scop flt-open-find-recid v-doc-rec

&scop flt-open-find-condition p-find-condition

&scop flt-open-find-buffer-name X_ext-classif

&scop flt-open-query p-open-query

&scop flt-open-table-name X_ext-classif

case p-list-mode:
  when '' then do:
     title0 = "Соответствие клиентов в разных системах TH".
    ASSIGN
    frame {&frame-name}:title = substitute("&1", title0)
    filter-label = SUBSTITUTE("&1"
                              , frame {&frame-name}:title
                              )
    .
    { gbl/fltopend.i
            &where-cond = " X_ext-classif.classif-subject = ~{&table_clients~} ~
                            and X_ext-classif.classif-name = v-cli-classif-name ~
                            AND X_ext-classif.db-num = - 1 ~
                            and (rs-key#_three = -1  or X_ext-classif.key#_three = rs-key#_three) ~
                            AND (X_ext-classif.charkey_One = ~{&cmp~} or X_ext-classif.charkey_One = ~{&prs~}) "
            &dyn_where-cond = " substitute('X_ext-classif.classif-subject = &1&2&1 ~
                            and X_ext-classif.classif-name = &1&3&1 ~
                            and (&6 = -1  or X_ext-classif.key#_three = &6) ~
                            AND X_ext-classif.db-num = - 1 AND (X_ext-classif.charkey_One = &1&4&1 or X_ext-classif.charkey_One = &1&5&1) ' ~
                            , ~{&double-quote~}, ~{&table_clients~}, v-cli-classif-name, ~{&cmp~}, ~{&prs~}, rs-key#_three ) "

            &use-ind    = "  "
            &by         = " BY X_ext-classif.charkey_three " }
  end.
  when {&g___Object} then do:
    title0 = "Соответствие объектов в разных системах TH".
    ASSIGN
    frame {&frame-name}:title = substitute("&1", title0)
    filter-label = SUBSTITUTE("&1"
                              , frame {&frame-name}:title
                              )
    .
    { gbl/fltopend.i
            &where-cond = " X_ext-classif.classif-subject = ~{&table_clients~} ~
                            and X_ext-classif.classif-name = v-cli-classif-name ~
                            AND X_ext-classif.db-num = - 1
                            and (rs-key#_three = -1  or X_ext-classif.key#_three = rs-key#_three) ~
                            AND (X_ext-classif.charkey_One = ~{&shop~} or X_ext-classif.charkey_One = ~{&stock~}) ~
                            "
            &dyn_where-cond = " substitute('X_ext-classif.classif-subject = &1&2&1 ~
                            and X_ext-classif.classif-name = &1&3&1 ~
                            and (&6 = -1  or X_ext-classif.key#_three = &6) ~
                            AND X_ext-classif.db-num = - 1 AND (X_ext-classif.charkey_One = &1&4&1 or X_ext-classif.charkey_One = &1&5&1) ' ~
                            , {&double-quote}, ~{&table_clients~}, v-cli-classif-name, ~{&shop~}, ~{&stock~}, rs-key#_three)    "

            &use-ind    = "  "
            &by         = " BY X_ext-classif.charkey_three " }

  end.
end case.
if not p-open-query and v-doc-rec <> ? then
REPOSITION br-clients to recid v-doc-rec No-ERROR.
if not p-open-query and v-fltopend-rowid[1] <> ? then
query br-clients:handle:reposition-to-rowid(v-fltopend-rowid) No-ERROR.
run waitfram-hide in this-procedure .
APPLY "VALUE-CHANGED" TO br-clients in frame {&frame-name}.
APPLY "ENTRY" TO br-clients.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-print Dialog-Frame
PROCEDURE proc-b-print :
DEFINE VARIABLE date_string              as   character no-undo .
DEFINE VARIABLE Line                     as   character no-undo .
DEFINE VARIABLE for-time                 as   character no-undo .
DEFINE VARIABLE accum-count              as   integer   no-undo .
DEFINE VARIABLE accum-count2             as   integer   no-undo .
define variable v-rid                    as   recid no-undo .
define variable v-self-objtypecode as character no-undo .
define variable v-alien-objtypecode as character no-undo .
define variable v-self-cli-name as character no-undo .
define variable v-old-client as logical no-undo .

DEFINE FRAME list1
v-self-objtypecode COLUMN-LABEL "КЛИЕНТ!v16.0" FORMAT "X(12)"
v-self-cli-name COLUMN-LABEL "НАЗВАНИЕ КЛИЕНТА!v16.0" FORMAT "X(60)"
X_ext-classif.charkey_two COLUMN-LABEL "{&abbr_INN_ALLSHIFT}" FORMAT "X(12)"
v-old-client column-label "До upg" FORMAT "+/"
v-alien-objtypecode COLUMN-LABEL "КЛИЕНТ!старой версии" FORMAT "X(12)"
X_ext-classif.charkey_three COLUMN-LABEL "Название клиента старой версии" FORMAT "X(60)"
HEADER  date_string AT 5 format "X(35)"
string( "Страница " ) format "X(9)" AT 75 PAGE-NUMBER(PrnLibStream) AT 85 FORMAT ">>9" SKIP
Line format "X(198)" AT 1
with width {&DOS_CW_2} down stream-io use-text    .

Line = fill("-", 198).
date_string = cur-time-print() .

run prn-lib-open-stream  in this-procedure (
                                             input parParentProc
                                            ,input {&LS_PS_A4}
                                            ,input yes /*p-is-stream*/
                                            ,input no /*p-append*/
                                            ).

PUT  STREAM PrnLibStream
SPACE(25) ( frame {&frame-name}:title )
format "x(90)" SKIP(1) .
FORM HEADER
Line format "X(198)" AT 1 SKIP
"Продолжение - на следующей странице" AT 30 SKIP
with FRAME BottomFrame width {&DOS_CW_2} PAGE-BOTTOM NO-LABELS NO-BOX .
VIEW  STREAM PrnLibStream FRAME BottomFrame .
v-rid = recid(X_ext-classif).
FORM with FRAME List1.
run waitfram-show in this-procedure ( input "Ждите...").
DO WHILE available X_ext-classif :
   GET prev br-clients.
END.
GET next br-clients.
DO WHILE available X_ext-classif :
  Display STREAM PrnLibStream
  (if X_ext-classif.uniq-key-rec BEGINS {&TABLE_clients}
  then (entry(2, X_ext-classif.uniq-key-rec, {&delim-key}) +
        entry(3, X_ext-classif.uniq-key-rec, {&delim-key}))
  else '') @ v-self-objtypecode
  (if X_ext-classif.uniq-key-rec BEGINS {&TABLE_clients}
  THEN get-cli-name(X_ext-classif.uniq-key-rec)
  ELSE '') @ v-self-cli-name
  (X_Ext-classif.key#_three = 1 ) @ v-old-client
  X_Ext-classif.charkey_two
  (X_ext-classif.charkey_one + string(X_ext-classif.key#_one)) @ v-alien-objtypecode
  X_Ext-classif.charkey_three
  with FRAME List1.
  DOWN STREAM PrnLibStream
  1
  with FRAME List1.
  assign
  accum-count = accum-count + 1
  .
  if X_ext-classif.uniq-key-rec <> '' then do:
    accum-count2 = accum-count2 + 1.
  end.
  GET next br-clients.
END.
UNDERLINE  STREAM PrnLibStream
v-self-objtypecode
v-alien-objtypecode
with FRAME List1.
DISPLAY STREAM PrnLibStream
accum-count2 @ v-self-objtypecode
accum-count @ v-alien-objtypecode
with frame List1.
HIDE  STREAM PrnLibStream FRAME BottomFrame .
HIDE  STREAM PrnLibStream FRAME List1.
output  STREAM PrnLibStream CLOSE.
reposition br-clients to recid v-rid no-error .
apply "ENTRY" to br-clients in frame {&frame-name} .
run waitfram-hide in this-procedure .
run prn-lib-prn-file in this-procedure (
                                          input parParentProc
                                          ,input 0
                                          ).


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-sch Dialog-Frame
PROCEDURE proc-b-sch :
define variable v-ri as recid no-undo .
assign
v-ri = (if avail X_ext-classif then recid(X_ext-classif) else ?)
.
assign
tbl = {&table_ext-classif}
join-tbl = 'X_ext-classif'
fld = ""
lab = ""
spr = ""
dim = '0'
.

run fltfield-add in this-procedure('charkey_one', substitute('Тип клиента &1', p-from-version), '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('key#_one', substitute('Код клиента &1', p-from-version), '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('charkey_two', "{&abbr_inn_allshift}", '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('charkey_three', substitute('Название клиента &1', p-from-version), '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('uniq-key-rec', 'Уникальный ключ записи в БД v16.0', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.


DO on stop undo, leave:
    run gbl/filter.w ( INPUT parparentproc
                 ,INPUT filter-point + {&delim-par} + filter-label
                 ,INPUT tbl
                 ,INPUT join-tbl
                 ,INPUT fld
                 ,INput lab
                 ,INPUT spr
                 ,INPUT  dim).
    run OpenBr IN THIS-PROCEDURE ( INPUT YES, INPUT NO, INPUT '':U).
    if v-ri <> ? then do:
      reposition br-clients to recid v-ri no-error.
    end.
    APPLY "ENTRY" to br-clients in frame {&frame-name} .
    APPLY "VALUE-CHANGED" to br-clients.
END .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-tie Dialog-Frame
PROCEDURE proc-b-tie :
define variable v-rid-list as character no-undo .
define variable glog as logical no-undo .
define variable v-rec as recid no-undo .
define variable v-uniq-key-rec as character no-undo .
define variable v-recid as recid  no-undo .
define buffer buf_clients for ub.clients.
define buffer buf_ext-classif for ub.ext-classif.
define buffer buf_sysconf for ub.sysconf.
if X_ext-classif.uniq-key-rec <> ''
and X_ext-classif.key#_three = 1
then do:
  message
  "Данное соответствие установлено в процессе upgrade - КЛИЕНТ ССЫЛАЕТСЯ САМ НА СЕБЯ - перепривязать НЕВОЗМОЖНО"
  view-as alert-box error .
  undo, return error .
end.
if X_ext-classif.uniq-key-rec <> ''
and X_ext-classif.key#_three = 2
then do:
  message
  "Данное соответствие установлено в процессе сведения объектов РАНЕЕ - перепривязать НЕВОЗМОЖНО"
  view-as alert-box error .
  undo, return error .
end.



if X_ext-classif.uniq-key-rec <> '' then do:
message
substitute("Уже есть соответствие  между данные клиента &1&2 в БД &4 и в БД v16.0&3" +
           "Вы УВЕРЕНЫ, что хотите их изменить?"
           , entry(2, X_ext-classif.uniq-key-rec, {&delim-key})
           , entry(3, X_ext-classif.uniq-key-rec, {&delim-key})
           , {&new-line}
           , p-from-version
           )
view-as alert-box question buttons yes-no update glog.
if not glog then return no-apply.
find first buf_clients no-lock where
        buf_clients.obj-type = entry(2, X_ext-classif.uniq-key-rec, {&delim-key})
    and buf_clients.obj-code = integer(entry(3, X_ext-classif.uniq-key-rec, {&delim-key})).
v-rid-list = string(recid(buf_clients)).
end.
run ref/cli-all.w (   input parparentproc
                ,input "b-sel"
                ,input (if p-list-mode = {&g___object} then {&g___object} else X_ext-classif.charkey_one)
                ,input {&all}
                ,input {&current}
                ,input ?
                ,input ",,,,,,NO,,"
                ,input (if p-list-mode = {&g___object} then "lock-cli-type" else '')
                ,output v-rid-list) no-error.
if v-rid-list = '':U then return no-apply.
find first buf_clients where recid (buf_clients) = integer (v-rid-list) no-lock no-error.
if p-list-mode = {&g___object} then do:
  if not (buf_clients.obj-type = {&shop}
      or
      buf_clients.obj-type = {&stock}) then do:
    message
    "Можно выбрать только ОРГАНИЗАЦИЮ или ФИЗ.ЛИЦО"
    view-as alert-box error .
    undo, return no-apply .
  end.
end.
else do:
  if not (buf_clients.obj-type = {&cmp}
      or
      buf_clients.obj-type = {&prs}) then do:
    message
    "Можно выбрать только ОРГАНИЗАЦИЮ или ФИЗ.ЛИЦО"
    view-as alert-box error .
    undo, return no-apply .
  end.
end.
run gen-key-rec in this-procedure ( input {&table_clients}
                                ,input (buffer buf_clients:handle)
                                ,output v-uniq-key-rec).
v-rec = recid(X_ext-classif).
find first buf_ext-classif no-lock where
          buf_ext-classif.classif-subject = {&table_clients}
      and buf_ext-classif.classif-name = v-cli-classif-name
      and buf_ext-classif.uniq-key-rec = v-uniq-key-rec no-error.
if available buf_ext-classif then do:
  message
  substitute('Клиент &1&2 в БД v16.0 уже привязан к клиенту в БД &5 (&3&4)'
                                , buf_clients.obj-type
                                , buf_clients.obj-code
                                , buf_ext-classif.charkey_One  /*obj-type*/
                                , buf_ext-classif.key#_one /*obj-code*/
                                , p-from-version
                                )
  view-as alert-box error .
  undo, return no-apply.
end.
if X_ext-classif.key#_two = 1
and p-list-mode <> {&g___object}
then do:
  if buf_clients.obj-type <> {&cmp}
  or not can-find(ub.sysconf no-lock where
                  ub.sysconf.host-code = buf_clients.obj-code)
  then do:
    if buf_clients.obj-type <> {&cmp} then do:
      message
      substitute('Клиент &1&2 в БД &4 является СВОЕЙ ФИРМОЙ - соответствующий клиент в БД v16.0 должен быть типа &3 и СВОЕЙ ФИРМОЙ'
                , X_ext-classif.charkey_One  /*obj-type*/
                , X_ext-classif.key#_one
                , {&cmp}
                /*obj-code*/
                ,p-from-version
                )
      view-as alert-box error .
      undo, return no-apply.
    end.
    else do:
      message
      substitute('Клиент &1&2 в БД &4 является СВОЕЙ ФИРМОЙ - соответствующий клиент в БД v16.0 должен быть СВОЕЙ ФИРМОЙ&3' +
                 "Сделать клиента &1&2 БД v16.0 СВОЕЙ ФИРМОЙ?"
                , X_ext-classif.charkey_One  /*obj-type*/
                , X_ext-classif.key#_one   /*obj-code*/
                , {&new-line}
                , p-from-version
                )
      view-as alert-box question buttons yes-no update glog .
      if not glog then do:
        undo, return no-apply.
      end.
      else do:
        run adm/config.w ( input parparentproc /*parparentproc*/
                            , input buf_clients.obj-code /*p-host-code*/
                            , input {&add-def} /*p-mode*/
                            , input yes /*p-is-deploy*/
                            )  no-error.
        if error-status:error then do:
          message
          substitute("Ошибка при создании СВОЕЙ ФИРМЫ из &1&2&3&4&3&5"
                     ,buf_clients.obj-type
                     ,buf_clients.obj-code
                     , {&new-line}
                     , error-status:get-message(1)
                     , return-value )
         view-as alert-box error .
         undo, return no-apply.
        end.
        else do:
          find first buf_sysconf no-lock where
                    buf_sysconf.host-code = buf_clients.obj-code no-error.
          if not available buf_sysconf then do:
            message
            substitute("Не найдена СВОЯ ФИРМА с кодом &1, видимо попытка создания СВОЕЙ ФИРМЫ из &2&1 НЕ УДАЛАСЬ"
                       , buf_clients.obj-code
                       , buf_clients.obj-type
                       )
            view-as alert-box error .
            undo, return no-apply.
          end.
          else do:
            message
            substitute("Успешно создана СВОЯ ФИРМА с кодом &1, теперь будем связывать"
                       , buf_clients.obj-code
                       , {&new-line}
                       )
            view-as alert-box WARNING.
          end.
        end.
      end.
    end.
  end.
end.
if p-list-mode = {&g___object} then do:
  /*ищем фирму для этого объекта*/
  define buffer sysconf_ext-classif for ub.ext-classif.
  find first sysconf_ext-classif no-lock where
            sysconf_ext-classif.classif-subject = {&table_clients}
        and sysconf_ext-classif.classif-name = v-cli-classif-name
        and sysconf_ext-classif.charkey_one = {&cmp}
        and sysconf_ext-classif.key#_one = X_ext-classif.key#_two  no-error.
  if not available sysconf_ext-classif then do:
      message
      substitute("Не найдена запись соответствия для СВОЕЙ ФИРМЫ &3 объекта &1&2 БД &4"
                  , X_ext-classif.charkey_one
                  , X_ext-classif.key#_one
                  , X_ext-classif.key#_two
                  , p-from-version
                  )
      view-as alert-box error .
      undo, return no-apply.
  end.
  DEFINE VARIABLE v-rowid AS ROWID NO-UNDO.
  DEFINE VARIABLE v-tbl-name AS character NO-UNDO.
  define buffer sysconf_clients for ub.clients.
  RUN gen-row-keyr IN THIS-PROCEDURE ( INPUT sysconf_ext-classif.uniq-key-rec
                                      ,input ?
                                      ,INPUT "ub"
                                      ,INPUT ? /*p-bh-handle*/
                                      ,INPUT NO-LOCK
                                      ,OUTPUT v-rowid
                                      ,OUTPUT v-tbl-name) no-error.
  if error-status:error then do:
      message
      substitute("Ошибка при поиcке записи соответствия с уникальным ключом записи <&4> для СВОЕЙ ФИРМЫ &3 объекта &1&2 БД &5"
                  , X_ext-classif.charkey_one
                  , X_ext-classif.key#_one
                  , X_ext-classif.key#_two
                  , sysconf_ext-classif.uniq-key-rec
                  , p-from-version
                  )
      view-as alert-box error .
      undo, return no-apply.
  end.
  find first sysconf_clients where
          rowid(sysconf_clients) = v-rowid no-error.
  if not available sysconf_clients then do:
    message
    substitute("Не найдена для СВОЕЙ ФИРМЫ &3 объекта &1&2 БД &4 не найдена соответствующая запись в БД v16.0"
                , X_ext-classif.charkey_one
                , X_ext-classif.key#_one
                , X_ext-classif.key#_two
                , p-from-version
                )
    view-as alert-box error .
    undo, return no-apply.
  end.
  if not can-find( first ub.sysconf no-lock where ub.sysconf.host-code = sysconf_clients.obj-code) then do:
      message
      substitute("СВОЯ ФИРМА &3 объекта &1&2 БД &4 в БД v16.0 НЕ ЯВЛЯЕТСЯ СВОЕЙ ФИРМОЙ"
                  , X_ext-classif.charkey_one
                  , X_ext-classif.key#_one
                  , X_ext-classif.key#_two
                  , p-from-version
                  )
      view-as alert-box error .
      undo, return no-apply.
  end.
  if not (buf_clients.host-code = sysconf_clients.obj-code)
  then do:
      message
      substitute("Для того чтобы связать объект &1&2 БД &5 и объект БД v16.0 &3&4 их СВОИ ФИРМЫ тоже должны быть СВЯЗАНЫ"
                  , X_ext-classif.charkey_one
                  , X_ext-classif.key#_one
                  , buf_clients.obj-type
                  , buf_clients.obj-code
                  , p-from-version
                  )
      view-as alert-box error .
      undo, return no-apply.
  end.
end.
run ref/extclas1.p (
                      input {&update}
                    ,input yes /*p-silent*/
                    ,input-output v-rec
                    ,input {&table_clients} /*p-classif-subject */
                    ,input v-cli-classif-name
                    ,input X_ext-classif.db-num
                    ,input X_ext-classif.Key#_One /* obj-code*/
                    ,input X_ext-classif.Key#_two
                    ,input X_ext-classif.Key#_three
                    ,input X_ext-classif.charkey_One  /*obj-type*/
                    ,input X_ext-classif.charkey_two /*inn*/
                    ,input X_ext-classif.charkey_three /*obj-name*/
                    ,input X_ext-classif.nonunique
                    ,input v-uniq-key-rec /*p-uniq-key-rec*/
                    ) no-error.
if error-status:error then do:
  message
  substitute('Ошибка при сохранении записи по клиенту &6 &1&2&3:&4&3&5'
                                , X_ext-classif.charkey_One
                                , X_ext-classif.key#_One
                                ,{&new-line}
                                , error-status:get-message(1)
                                , return-value
                                , p-from-version
                                )
  view-as alert-box error .
  undo, return no-apply.
end.
assign
v-recid = recid(X_ext-classif).
run Openbr in this-procedure ( INPUT YES, INPUT NO, INPUT '':U).
reposition  br-clients to recid v-recid no-error.
APPLY "entry" to br-clients in frame {&frame-name} .
apply "value-changed" to br-clients.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-close Dialog-Frame
PROCEDURE proc-close :
define variable v-loc-closed as character no-undo .
define variable glog as logical no-undo .
define buffer buf_ext-classif for ub.ext-classif.
case p-from-version:
  when {&thth150-from-version} then do:
    run thth150-db-attr-value in this-procedure ( input g#db-num
                                              ,input v-attr-code
                                              ,output v-loc-closed
                                              ,output v-type) .
  end.
  when {&thth14-from-version} then do:
    run thth14-db-attr-value in this-procedure ( input g#db-num
                                              ,input v-attr-code
                                              ,output v-loc-closed
                                              ,output v-type) .
  end.
end case. /*case p-from-version:*/
if logical(v-loc-closed) then do:
  if p-list-mode = {&g___object} then do:
    message
    "Уже завершен этап УСТАНОВКИ СООТВЕТСТВИЯ ДАННЫХ ПО ОБЪЕКТАМ в разных системах IBS TH"
    view-as alert-box error .
    undo, return error .
  end.
  else do:
    message
    "Уже завершен этап УСТАНОВКИ СООТВЕТСТВИЯ ДАННЫХ ПО КЛИЕНТОВ в разных системах IBS TH"
    view-as alert-box error .
    undo, return error .
  end.
end.
if p-list-mode = {&g___object} then do:
  message
  "Вы уверены, что Вы полностью установили СООТВЕТСТВИЕ ДАННЫХ ПО ОБЪЕКТАМ в разных системах IBS TH?"
  view-as alert-box question buttons yes-no update glog.
end.
else do:
  message
  "Вы уверены, что Вы полностью установили СООТВЕТСТВИЕ ДАННЫХ ПО КЛИЕНТАМ в разных системах IBS TH?"
  view-as alert-box question buttons yes-no update glog.
end.
if not glog then undo, return .
find first buf_ext-classif no-lock where
          buf_ext-classif.classif-subject = {&table_clients}
      and buf_ext-classif.classif-name = v-cli-classif-name
      AND buf_ext-classif.db-num = - 1
      AND (((buf_ext-classif.charkey_One = {&cmp} or buf_ext-classif.charkey_One = {&prs})
           and p-list-mode = '')
           or
           ((buf_ext-classif.charkey_One = {&shop} or buf_ext-classif.charkey_One = {&stock})
           and p-list-mode = {&g___object})
           )
      and buf_ext-classif.uniq-key-rec = '' no-error.
if available buf_ext-classif then do:
  if p-list-mode = {&g___object} then do:
    message
    substitute("ИМЕЕТСЯ запись по объекту в БД &1, которой не соответствует ни один ОБЪЕКТ БД v16.0", p-from-version) skip
    "Вы уверены, что хотите закрыть этап?"
    view-as alert-box question buttons YES-NO update glog .
    if not glog then undo, return error .
  end.
  else do:
    message
    substitute("ИМЕЕТСЯ запись по клиенту в БД &1, которой не соответствует ни один КЛИЕНТ БД v16.0", p-from-version) skip
    "Закрытие этапа НЕВОЗМОЖНО"

    view-as alert-box error .
    undo, return error .
  end.
end.

main-block:
do transaction:
  for each buf_ext-classif where
          buf_ext-classif.classif-subject = {&table_clients}
      and buf_ext-classif.classif-name = v-cli-classif-name
      AND buf_ext-classif.db-num = - 1
      AND buf_ext-classif.key#_three = 0
      and buf_ext-classif.uniq-key-rec > ''
      and (
            ( (buf_ext-classif.charkey_one = {&stock}
                or buf_ext-classif.charkey_one = {&shop})
                and p-list-mode = {&g___object}
            )
            or
              ( (buf_ext-classif.charkey_one = {&cmp}
                or buf_ext-classif.charkey_one = {&prs})
                and p-list-mode = ""
              )
           )
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
  on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
  :
    assign
    buf_ext-classif.key#_three = 2
    .
  end. /*for each buf_ext-classif no-lock where*/
case p-from-version:
  when {&thth150-from-version} then do:
    run thth150-db-attr-write in this-procedure (
                                              input g#db-num
                                              ,input v-attr-code
                                              ,input string(yes)).
  end.
  when {&thth14-from-version} then do:
    run thth14-db-attr-write in this-procedure (
                                              input g#db-num
                                              ,input v-attr-code
                                              ,input string(yes)).
  end.
end case. /*case p-from-version:*/

end. /*do transaction:*/

v-loc-closed = ''.
case p-from-version:
  when {&thth150-from-version} then do:
    run thth150-db-attr-value in this-procedure ( input g#db-num
                                              ,input v-attr-code
                                              ,output v-loc-closed
                                              ,output v-type) .
  end.
  when {&thth14-from-version} then do:
    run thth14-db-attr-value in this-procedure ( input g#db-num
                                              ,input v-attr-code
                                              ,output v-loc-closed
                                              ,output v-type) .
  end.
end case. /*case p-from-version:*/
if logical(v-loc-closed) = yes then do:
  disable
  b-close
  with frame {&frame-name} .
  if available X_ext-classif then v-doc-rec = recid(X_ext-classif).
  run openbr in this-procedure ( INPUT YES, INPUT NO, INPUT '':U) no-error.
  reposition br-clients to recid(v-doc-rec) no-error. APPLy 'ENTRY' to br-clients .
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-copy Dialog-Frame
PROCEDURE proc-copy :
DEFINE INPUT PARAMETER p-copy-option AS CHARACTER NO-UNDO.
define variable v-ok as logical no-undo .
define variable v-recid as recid no-undo .
/*заполним временные таблицу параметрами вызова сохранения клиентов*/
run cmp/upg-conn.p ( input "connect"
                    ,input p-from-version
                    ,output v-ok) no-error.
if not v-ok then do:
  message
  substitute("Ошибка при подключении к БД &4 TH&1&2&1&3"
             , {&new-line}
             , error-status:get-message(1)
             , return-value
             , p-from-version
             )
  view-as alert-box error .
  return error .
end.
run str/diallog.w ( input parparentproc
          , input this-procedure
          , input 'cmp/ththclit.p':U
          , input (p-copy-option + {&delim-par} +
                  (if p-copy-option = 'one'
                  then X_ext-classif.charkey_one
                  else '') + {&delim-par} +
                  (if p-copy-option = 'one'
                  then string(X_ext-classif.key#_one)
                  else '0') + {&delim-par} +
                  (if p-copy-option = 'list'
                  then v-rid-list
                  else '') + {&delim-par} +
                  p-from-version
                  )
          , input yes /*p-auto-go*/
          , input ''
          , input substitute('Копирование данных по клиентам из БД &1 во временную таблицу', p-from-version)) no-error .
if connected ("src") then do:
  disconnect src.
end.
if can-find (first clients-01) then do:
  run str/diallog.w ( input parparentproc
            , input this-procedure
            , input 'cmp/ththclis.p':U
            , input p-from-version
            , input no /*p-auto-go*/
            , input ''
            , input 'Сохранение данных по клиентам в БД v16.0') no-error .
end.
else do:
  message
  "Нет записей во временной таблице - НЕЧЕГО СОХРАНЯТЬ"
  view-as alert-box .
end.
assign
v-recid = recid(X_ext-classif).
run Openbr in this-procedure ( INPUT YES, INPUT NO, INPUT '':U).
reposition  br-clients to recid v-recid no-error.
APPLY "entry" to br-clients in frame {&frame-name} .
apply "value-changed" to br-clients.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-find-old-code Dialog-Frame
PROCEDURE proc-find-old-code :
define input parameter p-next as logical no-undo.
define input parameter p-old-code AS INTEGER no-undo.
DEFINE VARIABLE v-old-code AS CHARACTER NO-UNDO.
assign
sch-self-code = 0
.
display
0 @ sch-self-code
with frame {&frame-name}.
assign
v-old-code = string(p-old-code).
run OpenBr in this-procedure
    (input false /* p-open-query */
    ,input p-next  /* p-find-next  */
    ,input substitute(" and X_ext-classif.key#_one = &1 and X_ext-classif.charkey_one = &2&3&2"
      , v-old-code
      , {&double-quote}
      , rs-cli-type)
    ).
apply "entry":u to sch-self-code in frame {&frame-name} .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-find-self-code Dialog-Frame
PROCEDURE proc-find-self-code :
define input parameter p-next as logical no-undo.
define input parameter p-self-code AS INTEGER no-undo.
assign
sch-old-code = 0
.
display
0 @ sch-old-code
with frame {&frame-name}.
run OpenBr in this-procedure
    (input false /* p-open-query */
    ,input p-next  /* p-find-next  */
    ,input substitute(" and X_ext-classif.uniq-key-rec = &1&2&3&4&3&5&1 "
                      , {&double-quote}
                      , {&TABLE_clients}
                      , {&delim-KEY}
                      , rs-cli-type
                      , p-self-code)
    ).


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-imp Dialog-Frame
PROCEDURE proc-imp :
DEFINE VARIABLE glog AS LOGICAL NO-UNDO.
DEFINE VARIABLE v-ok AS LOGICAL NO-UNDO.
DEFINE BUFFER buf_ext-classif FOR ub.ext-classif.
if p-list-mode = {&g___Object} then do:
  FIND FIRST buf_ext-classif NO-LOCK WHERE
          buf_ext-classif.classif-subject = {&table_clients}
      and buf_ext-classif.classif-name = v-cli-classif-name
      AND buf_ext-classif.db-num = - 1
      and (buf_ext-classif.charkey_one = {&shop}
          or
          buf_ext-classif.charkey_one = {&stock}
          )
      and buf_ext-classif.key#_three = 0
      NO-ERROR.
end.
else do:
  FIND FIRST buf_ext-classif NO-LOCK WHERE
          buf_ext-classif.classif-subject = {&table_clients}
      and buf_ext-classif.classif-name = v-cli-classif-name
      AND buf_ext-classif.db-num = - 1
      and (buf_ext-classif.charkey_one = {&cmp}
          or
          buf_ext-classif.charkey_one = {&prs}
          )
      and buf_ext-classif.key#_three = 0
      NO-ERROR.
end.
IF NOT AVAILABLE buf_ext-classif THEN DO:
  if p-list-mode = {&g___Object} then do:
    MESSAGE
    substitute("Вы действительно хотите получить данные по объектам системы TH &1?", p-from-version)
    VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE glog.
  end.
  else do:
    MESSAGE
    substitute("Вы действительно хотите получить соответствие данных по клиентам системы TH &1?", p-from-version)
    VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE glog.
  end.
  IF NOT glog  THEN RETURN NO-APPLY.
END.
ELSE DO:
  if p-list-mode = {&g___Object} then do:
    MESSAGE
    substitute("У Вас уже есть закачанные данные по объектам системы TH &1", p-from-version) SKIP
    "Повторный импорт УНИЧТОЖИТ ВСЕ СООТВЕТСТВИЕ УСТАНОВЛЕННЫЕ ПОСЛЕ upgrade и предыдущих сведений" SKIP
    substitute("Вы действительно хотите вкачать данные по клиентам системы TH &1?", p-from-version)
    VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE glog.
  end.
  else do:
    MESSAGE
    substitute("У Вас уже есть закачанные соответствия по клиентам системы TH &1", p-from-version) SKIP
    "Повторный импорт УНИЧТОЖИТ ВСЕ СООТВЕТСТВИЕ УСТАНОВЛЕННЫЕ ПОСЛЕ upgrade и предыдущих сведений" SKIP
    substitute("Вы действительно хотите вкачать соответствия по клиентам системы TH &1?", p-from-version)
    VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE glog.
  end.
  IF NOT glog  THEN RETURN NO-APPLY.
END.
run cmp/upg-conn.p ( input "connect"
                    ,input p-from-version
                    ,output v-ok) no-error.
if not v-ok then do:
  message
  substitute("Ошибка при подключении к БД &4TH&1&2&1&3"
             , {&new-line}
             , error-status:get-message(1)
             , return-value
             , p-from-version
             )
  view-as alert-box error .
  return error .
end.
run str/diallog.w ( input parparentproc
          , input this-procedure
          , input (if p-list-mode = {&g___Object}
                   then 'cmp/ththshpi.p':U
                   else 'cmp/ththclii.p':U)
          , input p-from-version
          , input no /*p-auto-go*/
          , input ''
          , input substitute('Закачка соответствий по клиентам БД &1', p-from-version)) no-error .
if connected ("src") then do:
  disconnect src.
end.
RUN Openbr IN THIS-PROCEDURE ( INPUT YES, INPUT NO, INPUT '':U).
APPLY "entry" TO br-clients in frame {&frame-name} .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-imp-gds Dialog-Frame
PROCEDURE proc-imp-gds :
DEFINE VARIABLE glog AS LOGICAL NO-UNDO.
DEFINE VARIABLE v-ok AS LOGICAL NO-UNDO.
DEFINE BUFFER buf_ext-classif FOR ub.ext-classif.
FIND FIRST buf_ext-classif NO-LOCK WHERE
        buf_ext-classif.classif-subject = {&table_clients}
    and buf_ext-classif.classif-name = v-cli-classif-name
    AND buf_ext-classif.db-num = - 1
    and (buf_ext-classif.charkey_one = {&cmp}
        or
        buf_ext-classif.charkey_one = {&prs}
        )
    and buf_ext-classif.key#_three = 0
    NO-ERROR.

IF AVAILABLE buf_ext-classif THEN DO:
  MESSAGE
  "Вы действительно хотите начать процесс ИНТЕРАКТИВНОГО СВЕДЕНИЯ клиентов-производителей по их ТОВАРАМ(ДопБК)?"
  VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE glog.

  IF NOT glog  THEN RETURN NO-APPLY.
END.
ELSE DO:
  if p-list-mode = {&g___Object} then do:
    /*для объектов сюда не попадем*/
  end.
  else do:
    glog = no.
    MESSAGE
    substitute("ЕЩЕ НЕТ закачанных сведений по клиентам системы TH &1,", p-from-version) SKIP
    "(кнопка ПОЛУЧИТЬ СООТВЕТСТВИЯ)"
    VIEW-AS ALERT-BOX .
  end.
  IF NOT glog  THEN RETURN NO-APPLY.
END.
run cmp/upg-conn.p ( input "connect"
                    ,input p-from-version
                    ,output v-ok) no-error.
if not v-ok then do:
  message
  substitute("Ошибка при подключении к БД TH &4&1&2&1&3"
             , {&new-line}
             , error-status:get-message(1)
             , return-value
             , p-from-version
             )
  view-as alert-box error .
  return error .
end.
run str/diallog.w ( input parparentproc
          , input this-procedure
          , input 'cmp/ththclig.p':U
          , input p-from-version
          , input no /*p-auto-go*/
          , input ''
          , input 'Интерактивное сведение по товарам клиентов-производителей') no-error .
if connected ("src") then do:
  disconnect src.
end.
RUN Openbr IN THIS-PROCEDURE ( INPUT YES, INPUT NO, INPUT '':U).
APPLY "entry" TO br-clients in frame {&frame-name} .


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE set-row-color Dialog-Frame
PROCEDURE set-row-color :
DEF VAR iFGColor AS INTEGER NO-UNDO.
DEF VAR iBGColor AS INTEGER NO-UNDO.

  IF X_ext-classif.uniq-key-rec = "":U THEN DO:
      ASSIGN
        iFGColor = WHITE_COLOR
        iBGColor = RED_COLOR
      .
    end.
    ELSE do:
      ASSIGN
        iFGColor = Black_COLOR
        iBGColor = White_COLOR
      .
    end.

    ASSIGN
     X_ext-classif.charkey_three:FGCOLOR  in BROWSE {&BROWSE-NAME} = iFGColor
     X_ext-classif.charkey_three:BGCOLOR  in BROWSE {&BROWSE-NAME} = iBGColor
    .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-cli-name Dialog-Frame
FUNCTION get-cli-name RETURNS CHARACTER
  ( INPUT p-uniq-key-rec AS character ) :
DEFINE VARIABLE v-rowid AS ROWID NO-UNDO.
DEFINE VARIABLE v-tbl-name AS character NO-UNDO.
DEFINE BUFFER buf_clients FOR ub.clients.
RUN gen-row-keyr IN THIS-PROCEDURE ( INPUT p-uniq-key-rec
                                    ,input ?
                                    ,INPUT "ub"
                                    ,INPUT ? /*p-bh-handle*/
                                    ,INPUT NO-LOCK
                                    ,OUTPUT v-rowid
                                    ,OUTPUT v-tbl-name) no-error.
if error-status :error then do:
  message
    vss-workfile vss-revision vss-description skip
    error-status :get-message(1)
    error-status :get-message(2)
  view-as alert-box error.
  undo, return error.
end.
IF v-rowid = ? THEN RETURN 'НЕИЗВЕСТНЫЙ КЛИЕНТ'.

FIND FIRST buf_clients NO-LOCK WHERE ROWID(buf_clients) = v-rowid.
RETURN buf_clients.obj-name.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME