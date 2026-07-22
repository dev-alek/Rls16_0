&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER X_clients FOR ub.clients.
DEFINE BUFFER X_dis-card FOR ub.dis-card.
DEFINE BUFFER X_stop-list-line FOR ub.stop-list-line.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Один стоплист по ДК

Автор: Бахтадзе Наталья Викторовна
Дата создания: 07/12/07
Author: Bakhtadze Natalya
Creation date: 07/12/07

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO.
DEFINE INPUT PARAMETER bttns AS character NO-UNDO.
DEFINE INPUT PARAMETER p-mode AS character NO-UNDO.
define input parameter p-stop-list-code as character no-undo .
define input parameter p-d-card as character no-undo .
DEFINE INPUT-OUTPUT PARAMETER p-rid-list AS CHARACTER NO-UNDO.


/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Один стоплист по ДК".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/showinf.i }
{ cmp/mrk-strf.i }
{ gbl/getcntxt.i DEF }
{ gbl/flt-def.i  }
{ gbl/fltfield.i }
{ gbl/cur-time.i }
{ cmp/r-pril.i new }
{ gbl/prn-lib.i }
{ rul/calldscr.i }
{ gbl/key-rec.i }
{ cmp/dc-list.i  dc-list def "NEW SHARED" }
{ cmp/cli-list.i cli-list def "NEW SHARED" }
{ gbl/fltopend.i defproc }

DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
define variable filter-label as character no-undo .
define variable filter-label0 as character no-undo init "Стоплист" .
define variable filter-point as character no-undo .
define variable filter-point0 as character no-undo init "stop-lls" .
DEFINE VARIABLE sort-column-name as character no-undo .
define variable v-doc-rec as recid no-undo .
define buffer buf_stop-list for ub.stop-list.
DEFINE BUFFER buf_dis-card FOR ub.dis-card.
define buffer buf_clients for ub.clients.
DEFINE VARIABLE v-doc-date AS DATE NO-UNDO.
DEFINE VARIABLE v-sl-status AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-card-resource-id AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-client-resource-id AS CHARACTER NO-UNDO.
DEFINE variable add-option AS CHARACTER NO-UNDO.
DEFINE variable chg-option AS CHARACTER NO-UNDO.
DEFINE variable del-option AS CHARACTER NO-UNDO.
&SCOPED-DEFINE stop-status-code string(X_stop-list-line.key#_one)
&scop label1 "Клиент"
&scop label3 "Заблокированный!ресурс"

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br-stop-list-line

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_stop-list-line X_DIS-CARD X_clients

/* Definitions for BROWSE br-stop-list-line                             */
&Scoped-define FIELDS-IN-QUERY-br-stop-list-line mark-string(recid(X_stop-list-line), v-rid-list) X_stop-list-line.line-num X_stop-list-line.charkey_one (X_clients.obj-type + string(X_clients.obj-code)) X_clients.obj-name {&stop-status-name} calldscr(X_stop-list-line.resource_id) X_stop-list-line.stop-list-code get-sl-doc-date(X_stop-list-line.stop-list-code) @ v-doc-date get-sl-status(X_stop-list-line.stop-list-code) @ v-sl-status
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-stop-list-line
&Scoped-define SELF-NAME br-stop-list-line
&Scoped-define QUERY-STRING-br-stop-list-line FOR EACH X_stop-list-line NO-LOCK WHERE         X_stop-list-line.classif-type = {&TABLE_dis-card}      AND X_stop-list-line.stop-list-code = p-stop-list-code , ~
           FIRST X_DIS-CARD NO-LOCK WHERE          X_dis-card.d-card = X_stop-list-line.charkey_one, ~
           first  X_clients NO-LOCK WHERE          X_clients.obj-type  = X_dis-card.cli-type     AND  X_clients.obj-code  = X_dis-card.cli-code     INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-br-stop-list-line OPEN QUERY {&SELF-NAME} FOR EACH X_stop-list-line NO-LOCK WHERE         X_stop-list-line.classif-type = {&TABLE_dis-card}      AND X_stop-list-line.stop-list-code = p-stop-list-code , ~
           FIRST X_DIS-CARD NO-LOCK WHERE          X_dis-card.d-card = X_stop-list-line.charkey_one, ~
           first  X_clients NO-LOCK WHERE          X_clients.obj-type  = X_dis-card.cli-type     AND  X_clients.obj-code  = X_dis-card.cli-code     INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-br-stop-list-line X_stop-list-line ~
X_DIS-CARD X_clients
&Scoped-define FIRST-TABLE-IN-QUERY-br-stop-list-line X_stop-list-line
&Scoped-define SECOND-TABLE-IN-QUERY-br-stop-list-line X_DIS-CARD
&Scoped-define THIRD-TABLE-IN-QUERY-br-stop-list-line X_clients


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-br-stop-list-line}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit B-mark B-sel b-add b-chg b-del b-lkp ~
b-cli b-print b-sch B-Help sch-d-card sch-cli-code RS-cli-type B-cli-2 ~
br-stop-list-line mark-num fi-search
&Scoped-Define DISPLAYED-OBJECTS sch-d-card sch-cli-code RS-cli-type ~
mark-num fi-search

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-sl-doc-date Dialog-Frame
FUNCTION get-sl-doc-date RETURNS DATE
  ( INPUT p-stop-list-code AS CHARACTER )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-sl-status Dialog-Frame
FUNCTION get-sl-status RETURNS CHARACTER
  ( INPUT p-stop-list-code AS CHARACTER )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Menu Definitions                                                     */
DEFINE MENU MENU-b-add
       MENU-ITEM m_list-add     LABEL "Стоп-карта по списку"
       MENU-ITEM m_one-add      LABEL "Стоп-карта по одной"
       MENU-ITEM m_list-add-client LABEL "Стоп-клиент по списку"
       MENU-ITEM m_one-add-client LABEL "Стоп-клиент по одному".

DEFINE MENU MENU-b-chg
       MENU-ITEM m_selected-chg LABEL "Отмеченные"
       MENU-ITEM m_one-chg      LABEL "Один"          .

DEFINE MENU MENU-b-del
       MENU-ITEM m_selected-del LABEL "Отмеченные"
       MENU-ITEM m_one-del      LABEL "Одна карта"
       MENU-ITEM m_client-del   LABEL "ВСЕ карты клиента".


/* Definitions of the field level widgets                               */
DEFINE BUTTON b-add
     LABEL "&Добавить"
     SIZE 10 BY 1.

DEFINE BUTTON b-chg
     LABEL "&Изменить"
     SIZE 10 BY 1.

DEFINE BUTTON b-cli
     LABEL "Клиент"
     SIZE 10 BY 1.

DEFINE BUTTON B-cli-2
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 1"
     SIZE 3 BY 1.

DEFINE BUTTON b-del
     LABEL "&Удалить"
     SIZE 10 BY 1.

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-lkp
     LABEL "ДК"
     SIZE 10 BY 1.

DEFINE BUTTON B-mark
     LABEL "&*"
     SIZE 3 BY 1.

DEFINE BUTTON b-print
     LABEL "Пе&чать"
     SIZE 3 BY 1.

DEFINE BUTTON b-quit AUTO-GO
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-sch
     LABEL "&Фильтр"
     SIZE 3 BY 1.

DEFINE BUTTON B-sel AUTO-GO
     LABEL "Вы&бор"
     SIZE 10 BY 1.

DEFINE VARIABLE fi-search AS CHARACTER FORMAT "X(256)":U INITIAL "Поиск по"
      VIEW-AS TEXT
     SIZE 10 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE mark-num AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 6 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE sch-cli-code AS INTEGER FORMAT ">>>>>>>>9":U INITIAL 0
     LABEL "Код клиента"
     VIEW-AS FILL-IN
     SIZE 10 BY 1 NO-UNDO.

DEFINE VARIABLE sch-d-card AS CHARACTER FORMAT "X(19)":U
     LABEL "№ ДК"
     VIEW-AS FILL-IN
     SIZE 20 BY 1 NO-UNDO.

DEFINE VARIABLE RS-cli-type AS CHARACTER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Item 1", "1",
"Item 1", "2"
     SIZE 14.13 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-stop-list-line FOR
                X_stop-list-line,
                X_DIS-CARD,
                X_clients SCROLLING.

&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-stop-list-line
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-stop-list-line Dialog-Frame _FREEFORM
  QUERY br-stop-list-line NO-LOCK DISPLAY
      mark-string(recid(X_stop-list-line), v-rid-list) COLUMN-LABEL "*" FORMAT "X(2)"
X_stop-list-line.line-num COLUMN-LABEL "№№" FORMAT ">>>>>>>>9"
X_stop-list-line.charkey_one COLUMN-LABEL "№ ДК" FORMAT "X(19)"
(X_clients.obj-type + string(X_clients.obj-code)) COLUMN-LABEL {&label1} FORMAT "X(12)"
X_clients.obj-name COLUMN-LABEL "Наимен.Держателя карты" FORMAT "X(105)" WIDTH 40
{&stop-status-name} COLUMN-LABEL "Флаг" FORMAT "X(20)"
calldscr(X_stop-list-line.resource_id) COLUMN-LABEL {&label3} FORMAT "X(19)"
X_stop-list-line.stop-list-code COLUMN-LABEL "№ стоплиста" FORMAT "X(9)"
get-sl-doc-date(X_stop-list-line.stop-list-code) @ v-doc-date COLUMN-LABEL "Дата" FORMAT "99/99/9999"
get-sl-status(X_stop-list-line.stop-list-code) @ v-sl-status COLUMN-LABEL "Статус" FORMAT "X(8)"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98.88 BY 18 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-mark AT ROW 1 COL 11
     B-sel AT ROW 1 COL 21
     b-add AT ROW 1 COL 31 WIDGET-ID 2
     b-chg AT ROW 1 COL 41 WIDGET-ID 4
     b-del AT ROW 1 COL 51 WIDGET-ID 6
     b-lkp AT ROW 1 COL 71
     b-cli AT ROW 1 COL 81
     b-print AT ROW 1 COL 89
     b-sch AT ROW 1 COL 92
     B-Help AT ROW 1 COL 95
     sch-d-card AT ROW 2.08 COL 16 COLON-ALIGNED
     sch-cli-code AT ROW 3 COL 48.5 COLON-ALIGNED
     RS-cli-type AT ROW 3.08 COL 18 NO-LABEL
     B-cli-2 AT ROW 3.08 COL 33
     br-stop-list-line AT ROW 4 COL 1
     mark-num AT ROW 1 COL 12.5 COLON-ALIGNED NO-LABEL
     fi-search AT ROW 2.33 COL 1.5 NO-LABEL WIDGET-ID 8
     SPACE(88.40) SKIP(19.47)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Стоплист"
         CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: X_clients B "?" ? ub clients
      TABLE: X_dis-card B "?" ? ub dis-card
      TABLE: X_stop-list-line B "?" ? ub stop-list-line
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB br-stop-list-line B-cli-2 Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN
       b-add:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-b-add:HANDLE.

ASSIGN
       b-chg:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-b-chg:HANDLE.

ASSIGN
       b-del:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-b-del:HANDLE.

/* SETTINGS FOR FILL-IN fi-search IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-stop-list-line
/* Query rebuild information for BROWSE br-stop-list-line
     _START_FREEFORM
OPEN QUERY {&SELF-NAME}
FOR EACH X_stop-list-line NO-LOCK WHERE
        X_stop-list-line.classif-type = {&TABLE_dis-card}
     AND X_stop-list-line.stop-list-code = p-stop-list-code ,
    FIRST X_DIS-CARD NO-LOCK WHERE
         X_dis-card.d-card = X_stop-list-line.charkey_one,
    first  X_clients NO-LOCK WHERE
         X_clients.obj-type  = X_dis-card.cli-type
    AND  X_clients.obj-code  = X_dis-card.cli-code
    INDEXED-REPOSITION.
     _END_FREEFORM
     _START_FREEFORM_DEFINE
DEFINE QUERY br-stop-list-line FOR
                X_stop-list-line,
                X_DIS-CARD,
                X_clients SCROLLING.
     _END_FREEFORM_DEFINE
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is OPENED
*/  /* BROWSE br-stop-list-line */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Стоплист */
DO:
  p-rid-list = v-rid-list.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Стоплист */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-add Dialog-Frame
ON CHOOSE OF b-add IN FRAME Dialog-Frame /* Добавить */
DO:
     IF add-option = '':U THEN DO:
     run gbl/pop-up.p ( input self:handle, input no) no-error.
    if error-status:error or add-option = "":U then return no-apply.
  END.

  RUN proc-b-add IN THIS-PROCEDURE ( add-option) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN do:
      add-option = "":U.
      RETURN NO-APPLY.
  END.
  add-option = "":U.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-chg Dialog-Frame
ON CHOOSE OF b-chg IN FRAME Dialog-Frame /* Изменить */
DO:
  IF chg-option = '':U THEN DO:
     run gbl/pop-up.p ( input self:handle, input no) no-error.
    if error-status:error or chg-option = "":U then return no-apply.
  END.

  RUN proc-b-chg IN THIS-PROCEDURE ( chg-option) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN do:
      chg-option = "":U.
      RETURN NO-APPLY.
  END.
  chg-option = "":U.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-cli
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-cli Dialog-Frame
ON CHOOSE OF b-cli IN FRAME Dialog-Frame /* Клиент */
DO:
  IF NOT AVAILABLE X_stop-list-line THEN RETURN NO-APPLY.
  run ref/showcli.p ( INPUT parparentproc
                 ,INPUT X_dis-card.cli-type
                 ,INPUT X_dis-card.cli-code) NO-ERROR.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-cli-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-cli-2 Dialog-Frame
ON CHOOSE OF B-cli-2 IN FRAME Dialog-Frame /* Btn 1 */
DO:
define variable ref-list as character no-undo.
define variable ref-rec as recid no-undo.
define buffer buf_clients for ub.clients.
  run ref/cli-all.w ( input parParentProc
                  ,input "b-sel"
                  ,input RS-cli-type
                  ,input ?
                  ,input ?
                  ,input ?
                  ,input ?
                  ,input "":U
                  ,output ref-list) .
    if ref-list = "" then   do:
      apply "entry" to b-cli in frame {&frame-name}.
      return no-apply.
     end.
    ref-rec = integer( ref-list ).
    FIND FIRST buf_clients WHERE recid (buf_clients) = ref-rec NO-LOCK .
    if NOT (buf_clients.obj-type = {&cmp}
            or
            buf_clients.obj-type = {&prs} ) then do:
      message
      "Выберите контрагента типа" {&cmp} "или" {&prs}
      view-as alert-box error .
      return no-apply.
    end.
    assign
    RS-cli-type =  buf_clients.obj-type
    sch-cli-code = buf_clients.obj-code
    .
    display
    RS-cli-type
    sch-cli-code
    with frame {&frame-name}.
  apply "return" to sch-cli-code.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-del Dialog-Frame
ON CHOOSE OF b-del IN FRAME Dialog-Frame /* Удалить */
DO:
  IF del-option = '':U THEN DO:
    run gbl/pop-up.p ( input self:handle, input no) no-error.
    if error-status:error or del-option = "":U then return no-apply.
  END.

  RUN proc-b-del IN THIS-PROCEDURE ( del-option) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN do:
      del-option = "":U.
      RETURN NO-APPLY.
  END.
  del-option = "":U.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-lkp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-lkp Dialog-Frame
ON CHOOSE OF b-lkp IN FRAME Dialog-Frame /* ДК */
DO:
DEFINE VARIABLE v-ri AS RECID NO-UNDO.
DEFINE BUFFER buf_dis-card FOR ub.dis-card.
 IF NOT AVAILABLE X_stop-list-line THEN RETURN NO-APPLY.
 FIND FIRST buf_dis-card NO-LOCK WHERE
            buf_dis-card.d-card = X_stop-list-line.charkey_one NO-ERROR.
IF NOT AVAILABLE buf_dis-card THEN DO:
   MESSAGE
   substitute("Не найдена карта &1", X_stop-list-line.charkey_one)
   VIEW-AS ALERT-BOX ERROR.
   RETURN NO-APPLY.
END.
v-ri = recid( buf_dis-card ) .
run ref/dcardi.w (
                      input parparentproc
                    , input {&lookup}
                    , input buf_dis-card.emitent-host-code
                    , input v-cntxt-host-code-obj
                    , INPUT v-cntxt-obj-type
                    , input v-cntxt-obj-code
                    , input ?
                    , input-output v-ri ) no-error.
apply "entry" to br-stop-list-line.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mark Dialog-Frame
ON CHOOSE OF B-mark IN FRAME Dialog-Frame /* * */
DO:
  define variable loc#log as logical no-undo .
  if available X_stop-list-line then do:
    { gbl/markstrn.i X_stop-list-line v-rid-list }
    loc#log = br-stop-list-line:refresh() .

    if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
        loc#log = br-stop-list-line:select-next-row ().
        apply "VALUE-CHANGED" to br-stop-list-line in frame {&frame-name}.
    end.
    if num-entries( v-rid-list ) = 0
    then
        hide mark-num in frame {&frame-name}.
    else
        disp num-entries( v-rid-list ) @ mark-num with frame {&frame-name}.
  end.
  apply "entry" to br-stop-list-line in frame {&frame-name}.
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
    if ( available X_stop-list-line ) then do:
    if  ( v-rid-list = "" ) or b-mark:sensitive = no
    then
    v-rid-list = string( recid( X_stop-list-line ) ) .
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_client-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_client-del Dialog-Frame
ON CHOOSE OF MENU-ITEM m_client-del /* ВСЕ карты клиента */
DO:
  if not available X_stop-list-line  then undo, return no-apply.
  ASSIGN
  del-OPTION = "client":U.
  RUN proc-b-del IN THIS-PROCEDURE  ( del-option) NO-ERROR.
  IF error-status:ERROR THEN DO:
    del-option = '':U.
    RETURN NO-APPLY.
  END.
  del-option = '':U.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_list-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_list-add Dialog-Frame
ON CHOOSE OF MENU-ITEM m_list-add /* Стоп-карта по списку */
DO:
  ASSIGN
  ADD-OPTION = "list":U.
  RUN proc-b-add IN THIS-PROCEDURE  ( add-option) NO-ERROR.
  IF error-status:ERROR THEN DO:
    add-option = '':U.
    RETURN NO-APPLY.
  END.
  add-option = '':U.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_list-add-client
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_list-add-client Dialog-Frame
ON CHOOSE OF MENU-ITEM m_list-add-client /* Стоп-клиент по списку */
DO:
    ASSIGN
    ADD-OPTION = "list-client":U.
    RUN proc-b-add IN THIS-PROCEDURE  ( add-option) NO-ERROR.
    IF error-status:ERROR THEN DO:
      add-option = '':U.
      RETURN NO-APPLY.
    END.
    add-option = '':U.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_one-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_one-add Dialog-Frame
ON CHOOSE OF MENU-ITEM m_one-add /* Стоп-карта по одной */
DO:
  ASSIGN
  ADD-OPTION = "one":U.
  RUN proc-b-add IN THIS-PROCEDURE  ( add-option) NO-ERROR.
  IF error-status:ERROR THEN DO:
    add-option = '':U.
    RETURN NO-APPLY.
  END.
  add-option = '':U.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_one-add-client
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_one-add-client Dialog-Frame
ON CHOOSE OF MENU-ITEM m_one-add-client /* Стоп-клиент по одному */
DO:
  ASSIGN
  ADD-OPTION = "one-client":U.
  RUN proc-b-add IN THIS-PROCEDURE  ( add-option) NO-ERROR.
  IF error-status:ERROR THEN DO:
    add-option = '':U.
    RETURN NO-APPLY.
  END.
  add-option = '':U.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_one-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_one-chg Dialog-Frame
ON CHOOSE OF MENU-ITEM m_one-chg /* Один */
DO:
  if not available X_stop-list-line  then undo, return no-apply .
  ASSIGN
  chg-OPTION = "one":U.
  RUN proc-b-chg IN THIS-PROCEDURE  ( chg-option) NO-ERROR.
  IF error-status:ERROR THEN DO:
    chg-option = '':U.
    RETURN NO-APPLY.
  END.
  chg-option = '':U.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_one-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_one-del Dialog-Frame
ON CHOOSE OF MENU-ITEM m_one-del /* Одна карта */
DO:
  if not available X_stop-list-line  then undo, return no-apply.
  ASSIGN
  del-OPTION = "one":U.
  RUN proc-b-del IN THIS-PROCEDURE  ( del-option) NO-ERROR.
  IF error-status:ERROR THEN DO:
    del-option = '':U.
    RETURN NO-APPLY.
  END.
  del-option = '':U.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_selected-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_selected-chg Dialog-Frame
ON CHOOSE OF MENU-ITEM m_selected-chg /* Отмеченные */
DO:
 if v-rid-list = '':U then do:
    message
    "Ничего не отмечено"
    view-as alert-box error .
    undo, return no-apply.
  end.
  ASSIGN
  chg-OPTION = "selected":U.
  RUN proc-b-chg IN THIS-PROCEDURE  ( chg-option) NO-ERROR.
  IF error-status:ERROR THEN DO:
    chg-option = '':U.
    RETURN NO-APPLY.
  END.
  chg-option = '':U.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_selected-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_selected-del Dialog-Frame
ON CHOOSE OF MENU-ITEM m_selected-del /* Отмеченные */
DO:
   ASSIGN
  del-OPTION = "selected":U.
  RUN proc-b-del IN THIS-PROCEDURE  ( del-option) NO-ERROR.
  IF error-status:ERROR THEN DO:
    del-option = '':U.
    RETURN NO-APPLY.
  END.
  del-option = '':U.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME RS-cli-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL RS-cli-type Dialog-Frame
ON VALUE-CHANGED OF RS-cli-type IN FRAME Dialog-Frame
DO:
  assign
  RS-cli-type.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME sch-cli-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-cli-code Dialog-Frame
ON RETURN OF sch-cli-code IN FRAME Dialog-Frame /* Код клиента */
DO:
  run Openbr in this-procedure ( input YES, INPUT NO, input '':U, rs-cli-type, INPUT FRAME {&FRAME-NAME} sch-cli-code) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME sch-d-card
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-d-card Dialog-Frame
ON CTRL-J OF sch-d-card IN FRAME Dialog-Frame /* № ДК */
DO:
    run proc-find-d-card in this-procedure ( input yes, input frame {&frame-name} sch-D-CARD) no-error.
   if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-d-card Dialog-Frame
ON RETURN OF sch-d-card IN FRAME Dialog-Frame /* № ДК */
DO:
    run proc-find-d-card in this-procedure ( input NO, input frame {&frame-name} sch-d-card) no-error.
   if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-stop-list-line
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.
{ gbl/app_help.i }

{ gbl/brwrepos.i
  &line-num=5
}
{ gbl/hot-key.i b-mark }
{ gbl/hot-key.i b-lkp }
{ gbl/hot-key.i b-sel }
&scop b-quit ~{&b-exit~}
{ gbl/hot-key.i b-quit }
{ gbl/hot-key.i b-print }
{ gbl/setfltnm.i }

{ gbl/brwrefre.i
  " if available X_stop-list-line then v-doc-rec = recid(X_stop-list-line). ~
    RUn OpenBr in this-procedure ( input yes, input no, input '':U, input rs-cli-type, input frame {&frame-name} sch-cli-code). ~
    reposition br-stop-list-line to recid v-doc-rec no-error. "
}



/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON STOP UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
{ gbl/getcntxt.i get}
 if not (p-mode = {&update}
       or p-mode = {&lookup}) then do:

    message
    substitute("Неверное значение параметра p-mode=&1 ", p-mode)
    view-as alert-box error.
    undo main-block, return error .
  end.
  ASSIGN
  v-rid-list = p-rid-list.
 case p-mode:
    when  {&lookup} then do:
      if p-stop-list-code <> "":U
      then do:
        find first buf_stop-list no-lock where
                  buf_stop-list.stop-list-code = p-stop-list-code
            AND buf_stop-list.classif-type = {&TABLE_dis-card}  no-error.
        if not available buf_stop-list then do:
          message
          substitute("Не найден стоплист ДК &1", p-stop-list-code)
          view-as alert-box error .
          undo, return error .
        end.
      end.
      if p-d-card <> '':U then do:
        find first buf_Dis-card no-lock where
                  buf_Dis-card.d-card = p-d-card no-error.
        if not available buf_Dis-card then do:
          message
          substitute("Не найдена ДК &1", p-d-card)
          view-as alert-box error .
          undo, return error .
        end.
        find first buf_clients no-lock where
                  buf_clients.obj-type = buf_Dis-card.cli-type
              and buf_clients.obj-code = buf_Dis-card.cli-code no-error.
        if not available buf_Dis-card then do:
          message
          substitute("Не найден держатель карты ДК &1 &2&3"
                      , p-d-card
                      , buf_Dis-card.cli-type
                      , buf_Dis-card.cli-code
                      )
          view-as alert-box error .
          undo, return error .
        end.
        RUN gen-key-rec IN THIS-PROCEDURE ( INPUT {&TABLE_dis-card}
                                           ,INPUT BUFFER buf_dis-card:HANDLE
                                           ,OUTPUT v-card-resource-id).
        RUN gen-key-rec IN THIS-PROCEDURE ( INPUT {&TABLE_clients}
                                           ,INPUT BUFFER buf_clients:HANDLE
                                           ,OUTPUT v-client-resource-id).

      end.
    end.
    when {&update} then do:
      if p-d-card <> '':U then do:
        message
        substitute("Неверное значение параметре p-d-card=&1&2Данный параметр при редактировании задан быть не может"
                    , p-d-card
                    , {&new-line})
        view-as alert-box error .
        undo main-block, return error .
      end.
      do transaction:
      find first buf_stop-list exclusive-lock where
                buf_stop-list.stop-list-code = p-stop-list-code
          AND buf_stop-list.classif-type = {&TABLE_dis-card}  no-error.
      end.
      if not available buf_stop-list then do:
        message
        substitute("Не найден стоплист &1", p-stop-list-code)
        view-as alert-box error .
        undo main-block, return error .
      end.
      if buf_stop-list.status_ = {&fact} then do:
        message
        substitute("Стоплист &1 находится в статусе &2&3Изменение невозможно"
                    , p-stop-list-code
                    , buf_stop-list.status_
                    , {&new-line}
                    )
        view-as alert-box error .
        undo main-block, return error .

      end.
    end.
  end case.


  RUN Myenable IN THIS-PROCEDURE NO-ERROR.
  IF v-rid-list <> '':U THEN DO:
    REPOSITION br-stop-list-line to RECID INTEGER(entry(1, v-rid-list)) NO-ERROR.
    APPLY "entry" to br-stop-list-line.
    APPLY "value-changed" TO br-stop-list-line.
  END.
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
  DISPLAY sch-d-card sch-cli-code RS-cli-type mark-num fi-search
      WITH FRAME Dialog-Frame.
  ENABLE b-quit B-mark B-sel b-add b-chg b-del b-lkp b-cli b-print b-sch B-Help
         sch-d-card sch-cli-code RS-cli-type B-cli-2 br-stop-list-line mark-num
         fi-search
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
DEFINE variable v-h AS HANDLE NO-UNDO.

ASSIGN
RS-cli-type:radio-buttons IN FRAME {&FRAME-NAME} = {&CMp} + {&comma-char} + {&cmp} + {&comma-char} + {&prs} + {&comma-char} + {&prs}
X_clients.obj-name:RESIZABLE IN BROWSE br-stop-list-line = YES
RS-cli-type = {&cmp}
b-add:MENU-MOUSE in FRAME {&FRAME-NAME} = 1
b-chg:MENU-MOUSE in FRAME {&FRAME-NAME} = 1
b-del:MENU-MOUSE in FRAME {&FRAME-NAME} = 1
v-h = br-stop-list-line:FIRST-COLUMN IN FRAME {&FRAME-NAME}
.
DO while valid-handle(v-h) :
  if (v-h:LABEL = {&label1} and p-d-card <> '')
  OR (v-h:LABEL = {&label3} and p-d-card <> '')
  then do:
    v-h:visible = no.
    leave.
  end.
  ELSE DO:
    v-h = v-h:NEXT-COLUMN.
  END.
END.

ASSIGN
v-doc-date:VISIBLE IN BROWSE br-stop-list-line = (p-d-card <> '')
v-sl-status:VISIBLE IN BROWSE br-stop-list-line = (p-d-card <> '')
X_stop-list-line.charkey_one:VISIBLE IN BROWSE br-stop-list-line = (p-d-card = '')
X_clients.obj-name:VISIBLE IN BROWSE br-stop-list-line = (p-d-card = '')
.

display
rs-cli-type
with frame {&frame-name} .
ENABLE
b-quit
B-mark  when lookup("b-mark", bttns) > 0 OR P-MODE <> {&LOOKUP}
B-sel when lookup("b-sel", bttns) > 0
b-add WHEN p-mode <> {&LOOKUP} and not transaction
b-CHG WHEN p-mode <> {&LOOKUP} and not transaction
b-DEL WHEN p-mode <> {&LOOKUP} and not transaction

b-sch  when p-d-card = '':U
b-cli
b-print
b-lkp
B-Help
RS-cli-type when p-d-card = '':U
sch-cli-code when p-d-card = '':U
sch-d-card when p-d-card = '':U
B-CLI-2 when p-d-card = '':U
BR-stop-list-line
WITH FRAME {&frame-name} .
VIEW FRAME {&frame-name} .
if p-d-card <> '':U then do:
  hide
  RS-cli-type
  sch-cli-code
  sch-d-card
  B-CLI-2
  rs-cli-type
  fi-search
  in frame {&frame-name} .
end.
run openbr in this-procedure ( input yes, input no, input '':U, input rs-cli-type, input frame {&frame-name} sch-cli-code).
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OpenBr Dialog-Frame
PROCEDURE OpenBr :
define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .
DEFINE INPUT PARAMETER p-cli-type AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-cli-code AS integer NO-UNDO.
{&OPEN-QUERY-br-stop-list-line}
APPLY "entry" to br-stop-list-line in frame {&frame-name} .
APPLY "value-changed" TO br-stop-list-line.
define variable l-query-was-opened as logical no-undo .
run waitfram-show in this-procedure ( input "Ждите...").
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

&scop flt-open-sort-column-phrase sort-column-phrase

&scop flt-open-debug-file

&scop flt-open-open-query OPEN QUERY br-stop-list-line FOR EACH X_stop-list-line

&scop flt-open-dyn_open-query FOR EACH X_stop-list-line

&scop flt-open-query-handle QUERY br-stop-list-line:handle

&scop flt-open-query p-open-query

&scop flt-open-find-next p-find-next

&scop flt-open-find-condition p-find-condition

&scop flt-open-find-recid v-doc-rec

&scop flt-open-find-buffer-def define buffer X_stop-list-line for ub.stop-list-line.

&scop flt-open-open-query-tail , FIRST X_dis-card NO-LOCK WHERE ~
                                      X_dis-card.d-card = X_stop-list-line.charkey_one ~
                            , FIRST X_clients NO-LOCK WHERE ~
                                  X_clients.obj-type = X_dis-card.cli-type ~
                                  AND X_clients.obj-code = X_dis-card.cli-code

&scop flt-open-query-was-opened  l-query-was-opened

&scop flt-open-call-point filter-point

&scop flt-open-set-filter-name set-filter-name

&scop flt-open-indexed-reposition indexed-reposition

&scop flt-open-waitfram yes

&scop flt-open-table-name X_stop-list-line

&scop flt-open-search-option no-lock

if p-d-card = '':u then do:
  IF p-cli-code = 0 THEN DO:
    &scop flt-open-open-query-tail , FIRST X_dis-card NO-LOCK WHERE ~
                                          X_dis-card.d-card = X_stop-list-line.charkey_one ~
                                , FIRST X_clients NO-LOCK WHERE                ~
                                       X_clients.obj-type = X_dis-card.cli-type ~
                                   and X_clients.obj-code = X_dis-card.cli-code

    if p-open-query then do:
      ASSIGN
      FRAME {&frame-name}:TITLE = substitute("ДИСКОНТНЫЕ КАРТЫ СТОПЛИСТА &1"
                                            , p-stop-list-code
                                            ).
    end.
    assign
    filter-label = substitute("&1: ДК одного СТОПЛИСТА", filter-label0)
    filter-point = filter-point0
    .

      if sort-column-name = '':u then do:
        { gbl/fltopend.i
          &where-cond = " X_stop-list-line.classif-type = ~{&table_dis-card~} ~
                           and X_stop-list-line.stop-list-code =  p-stop-list-code "
          &dyn_where-cond = " substitute('X_stop-list-line.classif-type = &1&2&1 ~
                           and X_stop-list-line.stop-list-code =  &1&3&1 ', ~{&double-quote~}, ~{&table_dis-card~}, p-stop-list-code)"

          &use-ind = "  "
          &by = " by X_stop-list-line.charkey_one "
        }
      end.
  END.
  ELSE DO:
    &scop flt-open-open-query-tail , FIRST X_dis-card NO-LOCK WHERE ~
                                          X_dis-card.d-card = X_stop-list-line.charkey_one ~
                                     AND X_dis-card.cli-type = p-cli-type ~
                                     AND X_dis-card.cli-code = p-cli-code ~
                                , FIRST X_clients NO-LOCK WHERE ~
                                       X_clients.obj-type = X_dis-card.cli-type ~
                                   and X_clients.obj-code = X_dis-card.cli-code

    &scop flt-open-dyn_open-query-tail substitute(', FIRST X_dis-card NO-LOCK WHERE ~
                                          X_dis-card.d-card = X_stop-list-line.charkey_one ~
                                     AND X_dis-card.cli-type = &1&2&1 ~
                                     AND X_dis-card.cli-code = &3 ~
                                , FIRST X_clients NO-LOCK WHERE ~
                                       X_clients.obj-type = X_dis-card.cli-type ~
                                   and X_clients.obj-code = X_dis-card.cli-code', ~{&double-quote~}, p-cli-type, p-cli-code)


    if p-open-query then do:
      ASSIGN
      FRAME {&frame-name}:TITLE = substitute("ДИСКОНТНЫЕ КАРТЫ СТОПЛИСТА &1 &2"
                                           , p-stop-list-code
                                           , buf_stop-list.stop-list-code
                                           ).
    end.
    assign
      filter-label = substitute("&1: ДК одного СТОПЛИСТА", filter-label0)
      filter-point = filter-point0
      .

      if sort-column-name = '':u then do:
        { gbl/fltopend.i
          &where-cond = " X_stop-list-line.classif-type = ~{&table_dis-card~} ~
                           and X_stop-list-line.stop-list-code = p-stop-list-code ~
                            "
          &dyn_where-cond = " substitute('X_stop-list-line.classif-type = &1&2&1 ~
                           and X_stop-list-line.stop-list-code = &1&3&1 ', ~{&double-quote~}, ~{&table_dis-card~}, p-stop-list-code)
                            "

          &use-ind = "  "
          &by = " by X_stop-list-line.charkey_one "
        }
      end.

    END.
END. /*if p-d-card = '':U*/
ELSE DO:
  IF p-cli-code = 0 THEN DO:
    &scop flt-open-open-query-tail , FIRST X_dis-card NO-LOCK WHERE ~
                                          X_dis-card.d-card = X_stop-list-line.charkey_one ~
                                , FIRST X_clients NO-LOCK WHERE                ~
                                       X_clients.obj-type = X_dis-card.cli-type ~
                                   and X_clients.obj-code = X_dis-card.cli-code

    if p-open-query then do:
      ASSIGN
      FRAME {&frame-name}:TITLE = substitute("СТОПЛИСТЫ ДИСКОНТНОЙ КАРТЫ &1"
                                                , p-d-card
                                                ).
    end.
    assign
    filter-label = substitute("&1: СТОПЛИСТЫ одной ДК", filter-label0)
    filter-point = filter-point0 + {&comma-char} + "one"
    .

      if sort-column-name = '':u then do:
        { gbl/fltopend.i
          &where-cond = " X_stop-list-line.classif-type = ~{&table_dis-card~} ~
                           and X_stop-list-line.charkeY_one = p-d-card "
          &dyn_where-cond = " substitute('X_stop-list-line.classif-type = &1&2&1 ~
                           and X_stop-list-line.charkeY_one = &1&3&1 ', ~{&double-quote~}, ~{&table_dis-card~}, p-d-card)"

          &use-ind = "  "
          &by = " by X_stop-list-line.charkey_one "
        }
      end.
  END.
  ELSE DO:
    &scop flt-open-open-query-tail , FIRST X_dis-card NO-LOCK WHERE ~
                                          X_dis-card.d-card = X_stop-list-line.charkey_one ~
                                     AND X_dis-card.cli-type = p-cli-type ~
                                     AND X_dis-card.cli-code = p-cli-code ~
                                , FIRST X_clients NO-LOCK WHERE ~
                                       X_clients.obj-type = X_dis-card.cli-type ~
                                   and X_clients.obj-code = X_dis-card.cli-code

    &scop flt-open-dyn_open-query-tail substitute(', FIRST X_dis-card NO-LOCK WHERE ~
                                          X_dis-card.d-card = X_stop-list-line.charkey_one ~
                                     AND X_dis-card.cli-type = &1&2&1 ~
                                     AND X_dis-card.cli-code = &3 ~
                                , FIRST X_clients NO-LOCK WHERE ~
                                       X_clients.obj-type = X_dis-card.cli-type ~
                                   and X_clients.obj-code = X_dis-card.cli-code', ~{&double-quote~}, p-cli-type, p-cli-code)


    if p-open-query then do:
    ASSIGN
    FRAME {&frame-name}:TITLE = substitute("ДИСКОНТНЫЕ КАРТЫ СТОПЛИСТА &1 &2"
                                           , p-stop-list-code
                                           , buf_stop-list.stop-list-code
                                           ).
    end.
    assign
      filter-label = substitute("&1: СТОПЛИСТЫ одной ДК", filter-label0)
      filter-point = filter-point0 + {&comma-char} + "one"
      .

      if sort-column-name = '':u then do:
        { gbl/fltopend.i
          &where-cond = " X_stop-list-line.classif-type = ~{&table_dis-card~} ~
                           and X_stop-list-line.stop-list-code = p-stop-list-code ~
                            "
          &dyn_where-cond = " substitute('X_stop-list-line.classif-type = &1&2&1 ~
                           and X_stop-list-line.stop-list-code = &1&3&1 ', ~{&double-quote~}, ~{&table_dis-card~}, p-stop-list-code)
                            "

          &use-ind = "  "
          &by = " by X_stop-list-line.charkey_one "
        }
      end.
  END.
END.
if not p-open-query and v-doc-rec <> ? then
REPOSITION br-stop-list-line to recid v-doc-rec No-ERROR.
if not p-open-query and v-fltopend-rowid[1] <> ? then
query br-stop-list-line:handle:reposition-to-rowid(v-fltopend-rowid) No-ERROR.

run waitfram-hide in this-procedure .
APPLY "VALUE-CHANGED" TO br-stop-list-line in frame {&frame-name}.
APPLY "ENTRY" TO br-stop-list-line.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-add Dialog-Frame
PROCEDURE proc-b-add :
DEFINE INPUT PARAMETER p-add-option AS CHARACTER NO-UNDO.
define variable v-rid-list as character no-undo .
define variable v-ok as integer no-undo .
define variable v-ok-old as integer no-undo .
define variable v-ii as integer no-undo .
define variable v-jj as integer no-undo .
define variable v-num as integer no-undo .
define variable v-recid as recid no-undo .
define variable v-loc-rid-list as character no-undo .
define variable v-status-codes as character no-undo .
define variable v-sel-status-code as integer no-undo .
define variable v-status-codes-full as character no-undo .
define variable v-key-rec as character no-undo .
define variable choice as integer no-undo .
define buffer buf_Dis-card for ub.dis-card.
define buffer buf_clients for ub.clients.
define buffer exist_stop-list-line for Ub.stop-list-line.



case p-add-option:
  when "list" then do:
    v-sel-status-code = integer({&stop-card}).
    for each dc-list:
      delete dc-list.
    end.
    run str/dc-list.w (
               input parparentproc
              ,input v-cntxt-host-code-obj
              ,input v-cntxt-obj-type
              ,input v-cntxt-obj-code) no-error.
    v-num = 0.
    for each dc-list no-lock:
      if dc-list.mask-card then next.
      v-num = v-num + 1.
      run ref/stop-ll1.p (
                        input {&add-def}
                      ,input no /*p-silent*/
                      ,input-output v-recid
                      ,input p-stop-list-code
                      ,input dc-list.d-card
                      ,input v-sel-status-code
                      ) no-error.
      if not error-status:error then do:
        v-ok = v-ok + 1.
      end.
    end.
  end. /*when "list" then do:*/
  when "list-client" then do:
    v-sel-status-code = integer({&stop-client}).
    for each cli-list:
      delete cli-list.
    end.
    run str/cli-list.w (
               input parparentproc
              ,input v-cntxt-host-code-obj
              ,input v-cntxt-obj-type
              ,input v-cntxt-obj-code) no-error.
    v-num = 0.
    for each cli-list no-lock,
        each buf_dis-card no-lock where
            buf_Dis-card.cli-type = cli-list.obj-type
        and  buf_Dis-card.cli-code = cli-list.obj-code  :
      if buf_Dis-card.mask-card then next.
      v-num = v-num + 1.
      RUN gen-key-rec IN THIS-PROCEDURE ( INPUT {&TABLE_dis-card}
                                          ,INPUT BUFFER buf_Dis-card:HANDLE
                                          ,OUTPUT v-key-rec).
      find first exist_stop-list-line no-lock where
                exist_stop-list-line.stop-list-code = buf_stop-list.stop-list-code
            AND exist_stop-list-line.classif-type = {&TABLE_dis-card}
            and exist_stop-list-line.resource_id = v-key-rec no-error.
      if available exist_stop-list-line
      and exist_stop-list-line.key#_one = INTEGER({&stop-card}) then do:
        v-recid = recid(exist_stop-list-line).
        run ref/stop-ll1.p (
                          input {&update}
                        ,input no /*p-silent*/
                        ,input-output v-recid
                        ,input p-stop-list-code
                        ,input buf_Dis-card.d-card
                        ,input integer({&stop-card-and-client})
                        ) no-error.
        if not error-status:error then do:
          v-ok-old = v-ok-old + 1.
        end.
      end.
      else do:
        run ref/stop-ll1.p (
                          input {&add-def}
                        ,input no /*p-silent*/
                        ,input-output v-recid
                        ,input p-stop-list-code
                        ,input buf_Dis-card.d-card
                        ,input v-sel-status-code
                        ) no-error.
        if not error-status:error then do:
          v-ok = v-ok + 1.
        end.
      end.
    end.
  end. /*when "list-client" then do:*/
  when "one" then do:
    v-sel-status-code = integer({&stop-card}).
    run ref/discards.w ( INPUT parparentproc
                    ,input "b-sel,b-mark":U
                    ,input {&all}
                    ,INPUT v-cntxt-host-code-obj
                    ,INPUT v-cntxt-obj-type
                    ,INPUT v-cntxt-obj-code
                    ,INPUT '':U /*p-first-main-card*/
                    ,input ? /*cli-recid*/
                    ,output v-loc-rid-list ) no-error .
    if v-loc-rid-list <> '':U then do:
      do v-ii =  1 to num-entries(v-loc-rid-list) :
        v-num = v-num + 1.
        find first buf_dis-card no-lock where
                  recid(buf_dis-card) = integer(entry(v-ii, v-loc-rid-list)) no-error.
        if available buf_dis-card
        and buf_Dis-card.mask-card = no
        then do:
          run ref/stop-ll1.p (
                          input {&add-def}
                          ,input no /*p-silent*/
                          ,input-output v-recid
                          ,input p-stop-list-code
                          ,input buf_Dis-card.d-card
                          ,input v-sel-status-code
                          ) no-error.
          if error-status:error then do:

          end.
          else do:
            v-ok = v-ok + 1.
          end.
        end.
      end. /*do v-ii =  1 to num-entries(v-loc-rid-list) :*/
    end. /*if v-rid-list <> '':U then do:*/
    else do:
      undo, return error .
    end.
  end. /*when "one" then do:*/
  when "one-client" then do:
    v-sel-status-code = integer({&stop-client}).
    run ref/cli-all.w ( input parparentproc
                  ,input "b-sel"
                  ,input {&cmp}
                  ,input {&all}
                  ,input {&current}
                  ,input ?
                  ,input ",,,,,,NO,,"
                  ,input ""
                  ,output v-loc-rid-list ) NO-ERROR.
    IF v-loc-rid-list = '':U THEN undo, return error .
      do v-ii =  1 to num-entries(v-loc-rid-list) :
        find first buf_clients no-lock where
                  recid(buf_clients) = integer(entry(v-ii, v-loc-rid-list)) no-error.
        if available buf_clients then do:
          for each buf_dis-card no-lock where
                  buf_Dis-card.cli-type = buf_clients.obj-type
              and buf_Dis-card.cli-code = buf_clients.obj-code:
            if buf_Dis-card.mask-card then next.
            v-num = v-num + 1.
            RUN gen-key-rec IN THIS-PROCEDURE ( INPUT {&TABLE_dis-card}
                                                ,INPUT BUFFER buf_Dis-card:HANDLE
                                                ,OUTPUT v-key-rec).
            find first exist_stop-list-line no-lock where
                      exist_stop-list-line.stop-list-code = buf_stop-list.stop-list-code
                  AND exist_stop-list-line.classif-type = {&TABLE_dis-card}
                  and exist_stop-list-line.resource_id = v-key-rec no-error.
            if available exist_stop-list-line
            and exist_stop-list-line.key#_one = INTEGER({&stop-card}) then do:
          v-recid = recid(exist_stop-list-line).
          run ref/stop-ll1.p (
                            input {&update}
                          ,input no /*p-silent*/
                          ,input-output v-recid
                          ,input p-stop-list-code
                          ,input buf_Dis-card.d-card
                          ,input integer({&stop-card-and-client})
                          ) no-error.
          if not error-status:error then do:
            v-ok-old = v-ok-old + 1.
          end.
        end.
        else do:
          run ref/stop-ll1.p (
                            input {&add-def}
                            ,input no /*p-silent*/
                            ,input-output v-recid
                            ,input p-stop-list-code
                            ,input buf_Dis-card.d-card
                            ,input v-sel-status-code
                            ) no-error.
          if error-status:error then do:

          end.
          else do:
            v-ok = v-ok + 1.
          end.
        end.
        end.
      end.
    end. /*do v-ii =  1 to num-entries(v-rid-list) :*/
  end. /*when "one-client" then do:*/
end case.
run openbr in this-procedure ( input yes, input no, input '':U, input rs-cli-type, input frame {&frame-name} sch-cli-code).
if v-ii > 0 and v-ok <> v-num then do:
  message
  substitute("Из выбранных Вами &1 карт в стоп-лист удалось добавить &2", v-num, v-ok) skip(0)
  string(if v-ok-old > 0
   then substitute("&1 карт поменяли статус на &2"
                   ,v-ok-old
                  , {&stop-card-and-client-full})
   else '')
  view-as alert-box warning.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-chg Dialog-Frame
PROCEDURE proc-b-chg :
DEFINE INPUT PARAMETER p-chg-option AS CHARACTER NO-UNDO.
define variable v-status-codes as character no-undo .
define variable v-sel-status-code as integer no-undo .
define variable v-status-codes-full as character no-undo .
define variable choice as integer no-undo .
define variable v-ii as integer no-undo .
define variable v-ok as integer no-undo .
define variable v-num as integer no-undo .
define variable v-recid as recid no-undo .
DEFINE BUFFER buf_stop-list-line FOR ub.stop-list-line.
&scop stop-status-code entry(v-ii, v-status-codes)
if p-chg-option = "one" then do:
  if X_stop-list-line.key#_one = INTEGER({&stop-client})
  then do:
    v-status-codes = {&stop-card-and-client} .
  end.
  else do:
    v-status-codes = {&stop-client}  .
  end.
end.
else do:
  v-status-codes = {&stop-client} + {&comma-char} + {&stop-card-and-client} .
end.
do v-ii = 1 to num-entries(v-status-codes):
    v-status-codes-full = v-status-codes-full  +
                        (if v-ii = 1
                        then '':U
                        else '|') + {&stop-status-name}.

end.
run gbl/d-askw.w ( input "Статус строки стоп-листа"
            ,input  "Подвердите НОВЫЙ статус"
            ,input "|"
            ,input v-status-codes-full + "|" + "Отмена"
            ,input fill("|", num-entries(v-status-codes) )
            ,input 1
            ,input num-entries(v-status-codes) + 1
            ,output choice).
if choice = num-entries(v-status-codes) + 1 then do:
  undo, return error .
end.
v-sel-status-code = integer(entry(choice, v-status-codes)).
case p-chg-option:
  when "one" then do:
    if not (X_stop-list-line.key#_one = INTEGER({&stop-client})
    or   X_stop-list-line.key#_one = INTEGER({&stop-card-and-client}))
    then do:
      message
      substitute("Изменить статус строки стоп-листа можно только&1для строк со статусом <&2> или <&3> и&1только на статус <&3> или <&2> соответственно"
                 ,{&new-line}
                 ,{&stop-client-full}
                 ,{&stop-card-and-client-full}
                 )
      view-as alert-box error .
      undo, return error .
    end.
    v-recid = recid(X_stop-list-line).
    run ref/stop-ll1.p (
                      input {&update}
                    ,input no /*p-silent*/
                    ,input-output v-recid
                    ,input p-stop-list-code
                    ,input X_stop-list-line.charkey_one
                    ,input v-sel-status-code
                    ) no-error.
    if error-status:error then do:

    end.
    else do:
      v-ok = v-ok + 1.
    end.
  end.
  when "selected" then do:
    v-num = num-entries(v-rid-list).
    _v-ii:
    do v-ii = 1 to v-num:
      v-recid = integer(entry(v-ii, v-rid-list)).
      find first buf_stop-list-line no-lock where
                recid(buf_stop-list-line) = v-recid.
      if not (buf_stop-list-line.key#_one = integer({&stop-client})
              or
              buf_stop-list-line.key#_one = integer({&stop-card-and-client})
              )
      then do:
&scop stop-status-code string(v-sel-status-code)
        message
        substitute("Изменить статус строки стоп-листа можно только&1для строк со статусом <&2> и только на статус <&3>"
                  ,{&new-line}
                  ,(if v-sel-status-code = integer({&stop-client})
                    then {&stop-card-and-client-full}
                    else {&stop-client-full})
                  ,{&stop-status-name}
                  )
        view-as alert-box error .
        next _v-ii.
      end.
      run ref/stop-ll1.p (
                        input {&update}
                      ,input no /*p-silent*/
                      ,input-output v-recid
                      ,input p-stop-list-code
                      ,input buf_stop-list-line.charkey_one
                      ,input v-sel-status-code
                      ) no-error.
      if error-status:error then do:

      end.
      else do:
        v-ok = v-ok + 1.
      end.
    end.
  end.
end case.
run openbr in this-procedure ( input yes, input no, input '':U, input rs-cli-type, input frame {&frame-name} sch-cli-code).
if p-chg-option <> "one" and v-ok <> v-num then do:
  message
  substitute("Из выбранных Вами &1 карт удалось изменить &2", v-num, v-ok)
  view-as alert-box warning.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-del Dialog-Frame
PROCEDURE proc-b-del :
DEFINE INPUT PARAMETER p-del-option AS CHARACTER NO-UNDO.
define variable glog as logical no-undo .
define variable v-ii as integer no-undo .
define variable v-ok as integer no-undo .
define variable v-num as integer no-undo .
define variable v-num2 as integer no-undo .
define variable v-recid as recid no-undo .
define variable v-key-rec as character no-undo .
define variable v-stop-list-code as character no-undo .
define variable v-index as integer no-undo .
define buffer buf_stop-list-line for ub.stop-list-line.
define buffer buf_dis-card for ub.dis-card.
case p-del-option:
  when "one" then do:
    if X_stop-list-line.key#_one = INTEGER({&stop-client})
    or X_stop-list-line.key#_one = INTEGER({&stop-card-and-client}) then do:
      message
      substitute("Карты со статусом &2 и &3 не могут быть удалены из стоплиста по отдельности&1" +
                "для удаления таких карт из стоплиста выбирайте опцию ВСЕ ПО КЛИЕНТУ"
                ,{&new-line}
                ,{&stop-client-full}
                ,{&stop-card-and-client-full}
                )
      view-as alert-box ERROR.
      undo, return error .
    end.
    else do:
      message
      "Вы действительно хотите удалить из стоплиста эту карту?"
      view-as alert-box question button yes-no update glog.
      if not glog then undo, return error .
                     v-recid = recid(X_stop-list-line).
      run ref/stop-ll3.p (
                      input no /*p-silent*/
                      ,input v-recid
                      ) no-error.
      if error-status:error then do:

      end.
      else do:
        assign
        v-index = lookup(v-rid-list, string(v-recid)).
        if v-index > 0 then do:
          entry(v-index, v-rid-list) = ''.
          v-rid-list = trim(replace(v-rid-list, {&comma-char} + {&comma-char}, {&comma-char}), {&comma-char}).
        end.
      end.
    end.
  end.
  when "client" then do:
   v-stop-list-code = X_stop-list-line.stop-list-code.
    message
    "Вы действительно хотите удалить из стоплиста ВСЕ карты этого клиента?"
    view-as alert-box question button yes-no update glog.
    for each buf_Dis-card no-lock where
            buf_Dis-card.cli-type = X_clients.obj-type
        and buf_Dis-card.cli-code = X_clients.obj-code:
      run gen-key-rec in this-procedure ( input {&table_clients}
                                         ,input buffer X_clients:handle
                                         ,output v-key-rec).
     run waitfram-show in this-procedure ( input "Ждите..." ).
      for each buf_stop-list-line no-lock where
             buf_stop-list-line.stop-list-code = v-stop-list-code
         AND buf_stop-list-line.classif-type = {&TABLE_dis-card}
         and buf_stop-list-line.resource_id = v-key-rec
      on error  undo , return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
      on stop   undo , return error substitute( "&1. stop", vss-workfile )
      on endkey undo , return error substitute( "&1. endkey", vss-workfile )
      :
        v-recid = recid(buf_stop-list-line).
        v-num = v-num + 1.
        run ref/stop-ll3.p (
                        input no /*p-silent*/
                        ,input v-recid
                        ) no-error.
        if not error-status:error then do:
          v-ok = v-ok + 1.
          assign
          v-index = lookup(v-rid-list, string(v-recid)).
          if v-index > 0 then do:
            entry(v-index, v-rid-list) = ''.
            v-rid-list = trim(replace(v-rid-list, {&comma-char} + {&comma-char}, {&comma-char}), {&comma-char}).
          end.
        end.
      end.
      run waitfram-hide in this-procedure .
    end.
  end.
  when "selected" then do:
    if v-rid-list = '':U then do:
      message
      "Ничего не отмечено"
       view-as alert-box error.
       undo, return error .
    end.
    message
    substitute("Вы действительно хотите удалить из стоплиста отмеченные карты&1"  +
               "(карты в статусе &2 и &3 удалены не будут&1" +
               "для их удаления выбирайте опцию ВСЕ ПО КЛИЕНТУ)"
               ,{&new-line}
               ,{&stop-client-full}
               ,{&stop-card-and-client-full}
               )
    view-as alert-box question button yes-no update glog.
    if not glog then undo, return error .
    v-num = num-entries(v-rid-list).
    v-num2 = num-entries(v-rid-list).
    do v-ii = 1 to v-num2:
      v-recid = integer(entry(v-ii, v-rid-list)).
      find first buf_stop-list-line no-lock where
                recid(buf_stop-list-line) = v-recid.
      run ref/stop-ll3.p (
                       input no /*p-silent*/
                      ,input v-recid
                      ) no-error.
      if error-status:error then do:

      end.
      else do:
        v-ok = v-ok + 1.
        entry(v-ii, v-rid-list) = '':U.
        v-rid-list = trim(replace(v-rid-list, {&comma-char} + {&comma-char}, {&comma-char}), {&comma-char}).
        v-num2 = v-num2 - 1.
        v-ii = v-ii - 1.
      end.
    end.
  end.
end case.
run openbr in this-procedure ( input yes, input no, input '':U, input rs-cli-type, input frame {&frame-name} sch-cli-code).
if p-del-option <> "one" and v-ok <> v-num then do:
  message
  substitute("Из выбранных Вами &1 карт удалось удалить &2", v-num, v-ok)
  view-as alert-box warning.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-print Dialog-Frame
PROCEDURE proc-b-print :
&scop stop-status-code STRING( X_stop-list-line.key#_one)
define variable v-cli-type-code as character no-undo .
define variable line as character no-undo .
define variable startrecid as recid no-undo .
define variable v-stat-flag as character no-undo .
DEFINE VARIABLE v-for-sl-doc-date AS date NO-UNDO.
DEFINE VARIABLE v-for-sl-status AS CHARACTER NO-UNDO.

DEFINE FRAME List
X_stop-list-line.stop-list-code COLUMN-LABEL "№ стоплиста" FORMAT "X(9)"
X_stop-list-line.charkey_one COLUMN-LABEL "№ ДК" FORMAT "X(19)"
v-cli-type-code COLUMN-LABEL "Держатель" FORMAT "X(12)"
X_clients.obj-name COLUMN-LABEL "Наимен.Держателя карты" FORMAT "X(105)"
v-stat-flag COLUMN-LABEL "Флаг" FORMAT "X(20)"
HEADER
cur-time-print() AT 5 format "X(35)"
string( "Страница " + string( PAGE-NUMBER( PrnLibStream ) , ">>>>9") ) AT 56 format "X(15)" SKIP
Line format "X({&A4_LS})" AT 1
with width  {&DOS_CW_2} down use-text stream-io no-box .

DEFINE FRAME List2
X_stop-list-line.stop-list-code COLUMN-LABEL "№ стоплиста" FORMAT "X(9)"
v-for-sl-doc-date COLUMN-LABEL "Дата" FORMAT "99/99/9999"
v-for-sl-status COLUMN-LABEL "Статус" FORMAT "X(8)"
v-stat-flag COLUMN-LABEL "Флаг" FORMAT "X(22)"
HEADER
cur-time-print() AT 5 format "X(35)"
string( "Страница " + string( PAGE-NUMBER( PrnLibStream ) , ">>>>9") ) AT 56 format "X(15)" SKIP
Line format "X({&A4_LS})" AT 1
with width  {&DOS_CW_2} down use-text stream-io no-box .
StartRecid = recid( X_stop-list-line ) .
DO WHILE available X_stop-list-line :
  GET prev br-stop-list-line NO-LOCK .
END.
GET next br-stop-list-line NO-LOCK .
run prn-lib-open-stream  in this-procedure (
                                             input parParentProc
                                            ,input {&LS_PS_A4}
                                            ,input yes /*p-is-stream*/
                                            ,input no /*p-append*/
                                            ).

FORM HEADER
Line format "X(225)" SKIP
"Продолжение - на следующей странице" AT 30 SKIP
with FRAME CliBottomFrame width {&DOS_CW_2} PAGE-BOTTOM NO-LABELS no-box.

VIEW stream PrnLibStream FRAME CliBottomFrame .
PUT stream PrnLibStream space(20)
frame {&frame-name}:title format "X(100)" SKIP(2) .
IF p-d-card = '':U  THEN DO:
  FORM with frame List .
  DO WHILE available X_stop-list-line :
    display stream PrnLibstream
    X_stop-list-line.stop-list-code
    X_stop-list-line.charkey_one
    (X_dis-card.cli-type + string(X_dis-card.cli-code)) @ v-cli-type-code
    X_clients.obj-name
    {&stop-status-name} @ v-stat-flag
    with frame List .
    DOWN stream PrnLibStream
    1 with frame List.
      GET next br-stop-list-line.
    END.
  END.
  ELSE DO:
    FORM with frame List2 .
    DO WHILE available X_stop-list-line :
    display stream PrnLibstream
    X_stop-list-line.stop-list-code
    get-sl-doc-date(X_stop-list-line.stop-list-code) @ v-for-sl-doc-date
    get-sl-status(X_stop-list-line.stop-list-code) @ v-for-sl-status
    {&stop-status-name} @ v-stat-flag
    with frame List2 .
    DOWN stream PrnLibStream
    1 with frame List2.
      GET next br-stop-list-line.
    END.
  END.

PUT stream PrnLibStream Line format "X(136)" SKIP.
HIDE stream PrnLibStream FRAME CliBottomFrame .
output stream PrnLibStream close .
run prn-lib-prn-file in this-procedure (
                                           input parparentproc
                                          ,input 8
                                          ).
reposition br-stop-list-line to recid StartRecid .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-sch Dialog-Frame
PROCEDURE proc-b-sch :
define variable v-ri as recid no-undo.
assign
v-ri = (if avail X_stop-list-line then recid(X_stop-list-line) else ?)
.
assign
tbl = 'stop-list-line'
join-tbl = 'X_stop-list-line'
fld = ""
lab = ""
spr = ""
dim = '0'
.
run fltfield-add in this-procedure('key#_one', 'Флаг стоплиста', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('charkey_one', 'ДК', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
/*
assign
fld = fld
lab = lab
dim = dim + {&comma-char}
.

run fltfield-add in this-procedure('cli-type{&delim-flt}cli-code', 'Клиент', 'cli',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
assign
fld = fld
lab = lab
dim = dim + {&comma-char}
.
*/

DO on stop undo, leave:
    run gbl/filter.w ( INPUT parparentproc
                 ,INPUT (filter-point + {&delim-par} + filter-label)
                 ,INPUT tbl
                 ,INPUT join-tbl
                 ,INPUT fld
                 ,INput lab
                 ,INPUT spr
                 ,INPUT  dim).
    RUN OpenBr IN THIS-PROCEDURE ( INPUT YES, INPUT NO, INPUT '':U, input rs-cli-type, input frame {&frame-name} sch-cli-code).
    if v-ri <> ? then do:
      reposition br-stop-list-line to recid v-ri no-error.
    end.
    APPLY "ENTRY" to br-stop-list-line in frame {&frame-name} .
END .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-find-d-card Dialog-Frame
PROCEDURE proc-find-d-card :
define input parameter p-next as logical no-undo.
define input parameter p-d-card as character no-undo.
display
0 @ sch-cli-code
with frame {&frame-name}.
assign
p-d-card = replace(p-d-card, {&single-quote}, {&single-quote} + {&single-quote})
p-d-card = {&double-quote} + p-d-card + {&double-quote}.

run OpenBr in this-procedure
    (input false /* p-open-query */
    ,input p-next  /* p-find-next  */
    ,input substitute("and X_stop-list-line.charkey_one begins &1 "
      , p-d-card)
    ,INPUT '':U
    ,INPUT 0
    ).
apply "entry":u to sch-d-card in frame {&frame-name} .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-sl-doc-date Dialog-Frame
FUNCTION get-sl-doc-date RETURNS DATE
  ( INPUT p-stop-list-code AS CHARACTER ) :
DEFINE BUFFER buf_stop-list FOR ub.stop-list.
FIND FIRST buf_stop-list NO-LOCK WHERE
            buf_stop-list.stop-list-code = p-stop-list-code
       AND buf_stop-list.classif-type = {&TABLE_dis-card}
        NO-ERROR.
IF AVAILABLE buf_stop-list THEN  RETURN buf_stop-list.doc-date.   /* Function return value. */

  RETURN ?.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-sl-status Dialog-Frame
FUNCTION get-sl-status RETURNS CHARACTER
  ( INPUT p-stop-list-code AS CHARACTER ) :
DEFINE BUFFER buf_stop-list FOR ub.stop-list.
FIND FIRST buf_stop-list NO-LOCK WHERE
            buf_stop-list.stop-list-code = p-stop-list-code
       AND buf_stop-list.classif-type = {&TABLE_dis-card}
        NO-ERROR.
IF AVAILABLE buf_stop-list THEN  RETURN buf_stop-list.status_.   /* Function return value. */

  RETURN {&question-mark}.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME