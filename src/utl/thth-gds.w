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

Соответствие товаров в разных TH

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
define variable vss-description as character no-undo init "Соответствие товаров в разных TH".
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
{ cmp/r-page1.i new }
{ gbl/prn-lib.i }
{ gbl/fltopend.i defproc }
{ gbl/color.i }
{ cmp/ththgdst.i "NEW SHARED" }
{ cmp/thth150.i }
{ cmp/thth14.i }
{ cmp/ththgdsr.i "new shared" }
define variable g#report-num as integer no-undo .
{ rep/opclexcl.i }
define variable sort-column-name as character no-undo.
define variable filter-point     as character NO-UNDO INIT "thth-gds".
define variable filter-label     as character NO-UNDO INIT "Соответствие товаров в разных TH".
define variable filter-point0     as character NO-UNDO INIT "thth-gds".
define variable filter-label0     as character NO-UNDO INIT "Соответствие товаров в разных TH".
DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
define variable v-doc-rec as recid no-undo .
DEFINE VARIABLE copy-option AS CHARACTER NO-UNDO.
define variable v-closed as character no-undo .
define variable v-type as character no-undo .
define variable v-attr-code as character no-undo .
define variable print-option as character no-undo .
define variable v-classif-name as character no-undo .
define variable v-cli-classif-name as character no-undo .

&scop prod-label "ПРОЗВ-ЛЬ ТОВАРА!"

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br-goods

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_ext-classif

/* Definitions for BROWSE br-goods                                      */
&Scoped-define FIELDS-IN-QUERY-br-goods mark-string(recid(X_ext-classif), v-rid-list) (X_ext-classif.KEY#_three = 1) (IF X_ext-classif.uniq-key-rec BEGINS {&table_goods} THEN string(integer(entry(2, X_ext-classif.uniq-key-rec, {&delim-key})), ">>>>>>>>9") ELSE '' ) X_ext-classif.KEY#_one X_ext-classif.charkey_one (X_ext-classif.charkey_two + string(X_ext-classif.KEY#_two)) X_ext-classif.charkey_three
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-goods
&Scoped-define SELF-NAME br-goods
&Scoped-define QUERY-STRING-br-goods FOR EACH X_ext-classif NO-LOCK OUTER-JOIN INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-br-goods OPEN QUERY {&SELF-NAME} FOR EACH X_ext-classif NO-LOCK OUTER-JOIN INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-br-goods X_ext-classif
&Scoped-define FIRST-TABLE-IN-QUERY-br-goods X_ext-classif


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-br-goods}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit B-mark B-sel b-tie b-copy b-imp ~
b-close b-sch b-print B-Help rs-key#_three b-convert b-imp-2 sch-old-code ~
b-untie sch-self-code br-goods f-gds-name mark-num
&Scoped-Define DISPLAYED-OBJECTS rs-key#_three sch-old-code sch-self-code ~
f-gds-name mark-num

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-gds Dialog-Frame
FUNCTION get-gds RETURNS LOGICAL ( INPUT p-uniq-key-rec AS character
    ,OUTPUT p-artic AS CHARACTER
    ,OUTPUT p-prodtypecode AS CHARACTER
    ,OUTPUT p-gds-name AS CHARACTER )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Menu Definitions                                                     */
DEFINE MENU MENU-b-copy
       MENU-ITEM m_one          LABEL "Текущий"
       MENU-ITEM m_list         LABEL "Отмеченные (только без соответствия)"
       MENU-ITEM m_all          LABEL "ВСЕ (только без соответствия)".

DEFINE MENU MENU-b-print
       MENU-ITEM m_print-list   LABEL "Список соответствий"
       MENU-ITEM m_print-report LABEL "Детализированный отчет (ТОЛЬКО EXCEL)".


/* Definitions of the field level widgets                               */
DEFINE BUTTON b-close
     LABEL "Закр"
     SIZE 8 BY 1.

DEFINE BUTTON b-convert
     LABEL "Конвертация списка БАР-КОД~;ЦЕНА"
     SIZE 37 BY 1.

DEFINE BUTTON b-copy
     LABEL "Копировать из"
     SIZE 20 BY 1.

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-imp
     LABEL "Получ.соответствие"
     SIZE 20 BY 1 TOOLTIP "Получение соответствия данных по товарам системы TH".

DEFINE BUTTON b-imp-2
     LABEL "Подбор без проверки на производителя"
     SIZE 16.5 BY 1 TOOLTIP "Получение соответствия данных по товарам системы TH".

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

DEFINE BUTTON b-untie
     LABEL "Развязать"
     SIZE 10 BY 1.

DEFINE VARIABLE f-gds-name AS CHARACTER FORMAT "X(256)":U
     LABEL "Назв.в БД"
     VIEW-AS FILL-IN
     SIZE 75 BY .93 NO-UNDO.

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
DEFINE QUERY br-goods FOR X_ext-classif SCROLLING.

&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-goods
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-goods Dialog-Frame _FREEFORM
  QUERY br-goods NO-LOCK DISPLAY
      mark-string(recid(X_ext-classif), v-rid-list) COLUMN-LABEL "" FORMAT "X(1)"
(X_ext-classif.KEY#_three  = 1) COLUMN-LABEL "До upg" FORMAT "+/"
(IF X_ext-classif.uniq-key-rec BEGINS {&table_goods}
 THEN string(integer(entry(2, X_ext-classif.uniq-key-rec, {&delim-key})), ">>>>>>>>9")
ELSE ''
    ) COLUMN-LABEL "КОД ТОВАРА!v16.0" FORMAT "X(9)"
X_ext-classif.KEY#_one  COLUMN-LABEL "КОД ТОВАРА!" FORMAT ">>>>>>>>9"
X_ext-classif.charkey_one COLUMN-LABEL "Артикул!ТОВАРА" FORMAT "X(16)"
(X_ext-classif.charkey_two + string(X_ext-classif.KEY#_two))  COLUMN-LABEL {&prod-label} FORMAT "X(12)"
X_ext-classif.charkey_three COLUMN-LABEL "Название ТОВАРА в БД|Ед.изм" FORMAT "X(60)"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 18.4 FIT-LAST-COLUMN.


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
     b-convert AT ROW 2 COL 61 WIDGET-ID 42
     b-imp-2 AT ROW 2 COL 81 WIDGET-ID 28
     sch-old-code AT ROW 3 COL 28 COLON-ALIGNED WIDGET-ID 36
     b-untie AT ROW 3 COL 42.5 WIDGET-ID 40
     sch-self-code AT ROW 3 COL 75 COLON-ALIGNED WIDGET-ID 38
     br-goods AT ROW 4 COL 1 WIDGET-ID 100
     f-gds-name AT ROW 22.33 COL 8 WIDGET-ID 24
     mark-num AT ROW 1 COL 12.5 COLON-ALIGNED NO-LABEL WIDGET-ID 8
     SPACE(79.30) SKIP(21.33)
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
/* BROWSE-TAB br-goods sch-self-code Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN
       b-copy:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-b-copy:HANDLE.

ASSIGN
       b-print:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-b-print:HANDLE.

/* SETTINGS FOR FILL-IN f-gds-name IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-goods
/* Query rebuild information for BROWSE br-goods
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH X_ext-classif NO-LOCK
OUTER-JOIN INDEXED-REPOSITION.
     _END_FREEFORM
     _START_FREEFORM_DEFINE
DEFINE QUERY br-goods FOR X_ext-classif SCROLLING.
     _END_FREEFORM_DEFINE
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is OPENED
*/  /* BROWSE br-goods */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
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


&Scoped-define SELF-NAME b-convert
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-convert Dialog-Frame
ON CHOOSE OF b-convert IN FRAME Dialog-Frame /* Конвертация списка БАР-КОД;ЦЕНА */
DO:
  RUN proc-convert-mob-scan IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR  THEN RETURN NO-APPLY.
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
  APPLY "entry" TO br-goods.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-imp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-imp Dialog-Frame
ON CHOOSE OF b-imp IN FRAME Dialog-Frame /* Получ.соответствие */
DO:
  RUN proc-imp IN THIS-PROCEDURE ( INPUT 1) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-imp-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-imp-2 Dialog-Frame
ON CHOOSE OF b-imp-2 IN FRAME Dialog-Frame /* Подбор без проверки на производителя */
DO:
  RUN proc-imp IN THIS-PROCEDURE ( INPUT 2) NO-ERROR.
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
    loc#log = br-goods:refresh() .

    if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
        loc#log = br-goods:select-next-row ().
        apply "VALUE-CHANGED" to br-goods in frame {&frame-name}.
    end.
    if num-entries( v-rid-list ) = 0
    then
        hide mark-num in frame {&frame-name}.
    else
        disp num-entries( v-rid-list ) @ mark-num with frame {&frame-name}.
  end.
  apply "entry" to br-goods in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-print Dialog-Frame
ON CHOOSE OF b-print IN FRAME Dialog-Frame /* Печать */
DO:
  if print-option = '':U then do:
    run gbl/pop-up.p ( input self:handle, input no) no-error.
  end.
  if print-option = '':U then return no-apply.
  CASE Print-OPTION:
    WHEN "REPORT" THEN DO:
      RUN PROC-REPORT IN THIS-PROCEDURE NO-ERROR.
    END.
    WHEN "LIST" THEN DO:
      run proc-b-print in this-procedure no-error.
    END.
  END CASE.
  print-option = "".
  APPLY "ENTRY" to br-goods.
  return no-apply.
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


&Scoped-define SELF-NAME b-untie
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-untie Dialog-Frame
ON CHOOSE OF b-untie IN FRAME Dialog-Frame /* Развязать */
DO:
  if not available X_ext-classif then return no-apply.
  RUN proc-b-untie IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-goods
&Scoped-define SELF-NAME br-goods
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-goods Dialog-Frame
ON VALUE-CHANGED OF br-goods IN FRAME Dialog-Frame
DO:
 DEFINE VARIABLE v-gds-name AS CHARACTER NO-UNDO.
 DEFINE VARIABLE v-artic AS CHARACTER NO-UNDO.
 DEFINE VARIABLE v-prodtypecode AS CHARACTER NO-UNDO.
 DEFINE VARIABLE glog AS logical NO-UNDO.
 IF AVAILABLE X_ext-classif
 and X_ext-classif.uniq-key-rec <> ''
 THEN DO:
    glog = get-gds (INPUT X_ext-classif.uniq-key-rec, OUTPUT v-artic, OUTPUT v-prodtypecode, OUTPUT v-gds-name ) .
  END.
  ELSE DO:
     v-gds-name = ''.
  END.
  f-gds-name:SCREEN-VALUE = v-gds-name.

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


&Scoped-define SELF-NAME m_print-list
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_print-list Dialog-Frame
ON CHOOSE OF MENU-ITEM m_print-list /* Список соответствий */
DO:
  assign
  print-option = 'LIST':U.
  APPLY "CHOOSE" to b-print  in frame {&frame-name}.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_print-report
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_print-report Dialog-Frame
ON CHOOSE OF MENU-ITEM m_print-report /* Детализированный отчет (ТОЛЬКО EXCEL) */
DO:
  assign
  print-option = 'report':U.
  APPLY "CHOOSE" to b-print  in frame {&frame-name}.


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
  reposition br-goods to recid(v-doc-rec) no-error.
  APPLy 'ENTRY' to br-goods .
  APPLY "VALUE-CHANGED" to br-goods.
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

ON ROW-DISPLAY OF br-goods IN frame {&frame-name}
DO:
  IF AVAIL X_ext-classif THEN DO:
    RUN set-row-color.
  END.
END.

{ gbl/brwrefre.i "if available X_ext-classif then v-doc-rec = recid(X_ext-classif). ~
run openbr in this-procedure ( INPUT YES, INPUT NO, INPUT '':U) no-error. reposition br-goods to recid(v-doc-rec) no-error. APPLy 'ENTRY' to br-goods ." }


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
 { gbl/getcntxt.i get }
  v-rid-list = p-rid-list.
  case p-from-version:
    when {&thth150-from-version} then do:
      v-classif-name = {&extclass_goods_th-th150}.
      v-cli-classif-name = {&extclass_clients_th-th150}.
      v-attr-code = {&attr-thth150-goods}.
      run thth150-db-attr-value in this-procedure ( input g#db-num
                                                ,input v-attr-code
                                                ,output v-closed
                                                ,output v-type) .
    end.
    when {&thth14-from-version} then do:
      v-classif-name = {&extclass_goods_th-th14}.
      v-cli-classif-name = {&extclass_clients_th-th14}.
      v-attr-code = {&attr-thth14-goods}.
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
  DISPLAY rs-key#_three sch-old-code sch-self-code f-gds-name mark-num
      WITH FRAME Dialog-Frame.
  ENABLE b-quit B-mark B-sel b-tie b-copy b-imp b-close b-sch b-print B-Help
         rs-key#_three b-convert b-imp-2 sch-old-code b-untie sch-self-code
         br-goods f-gds-name mark-num
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
define variable v-prod-h as handle no-undo .
/*установим лейблы*/
v-prod-h = br-goods:FIRST-COLUMN IN FRAME {&FRAME-NAME}.
DO while valid-handle(v-prod-h) :
  if v-prod-h:LABEL = {&prod-label} then do:
    leave.
  end.
  ELSE DO:
    v-prod-h = v-prod-h:NEXT-COLUMN.
  END.
END.

assign
b-copy:label in frame {&frame-name} = substitute("&1 &2"
                                                  , b-copy:label in frame {&frame-name}
                                                  , p-from-version)
b-imp:tooltip in frame {&frame-name} = substitute("&1 &2"
                                                  , b-imp:tooltip in frame {&frame-name}
                                                  , p-from-version)
b-imp-2:tooltip in frame {&frame-name} = substitute("&1 &2"
                                                  , b-imp-2:tooltip in frame {&frame-name}
                                                  , p-from-version)
f-gds-name:label in frame {&frame-name} = substitute("&1 &2"
                                                  , f-gds-name:label in frame {&frame-name}
                                                  , p-from-version)
sch-old-code:label in frame {&frame-name} = substitute("&1 &2"
                                                  , sch-old-code:label in frame {&frame-name}
                                                  , p-from-version)
X_ext-classif.KEY#_one:LABEL  in browse br-goods = substitute("&1 &2"
                                                            , X_ext-classif.KEY#_one:LABEL  in browse br-goods
                                                            ,p-from-version)
X_ext-classif.charkey_one:LABEL  in browse br-goods = substitute("&1 &2"
                                                            , X_ext-classif.charKEY_one:LABEL  in browse br-goods
                                                            ,p-from-version)
X_ext-classif.charkey_three:LABEL  in browse br-goods = substitute("&1 &2"
                                                            , X_ext-classif.charKEY_three:LABEL  in browse br-goods
                                                            ,p-from-version)
v-prod-h:label  = substitute("&1 &2"
                                    , v-prod-h:label
                                    , p-from-version)
.

assign
b-copy:menu-mouse in frame {&frame-name} = 1
b-print:menu-mouse in frame {&frame-name} = 1
rs-key#_three = 0
X_ext-classif.charkey_three:resizable in browse br-goods = yes
.
display
rs-key#_three
with frame {&frame-name} .
ENABLE
b-quit
b-print
b-mark
b-imp when (v-cntxt-db-num = 0 and lookup("b-add", bttns) > 0 and not transaction and logical(v-closed) = no)
/*b-imp-2 when (v-cntxt-db-num = 0 and lookup("b-add", bttns) > 0 and not transaction and logical(v-closed) = no)*/
b-tie when (v-cntxt-db-num = 0 and lookup("b-add", bttns) > 0 and not transaction and logical(v-closed) = no)
b-untie when (v-cntxt-db-num = 0 and lookup("b-add", bttns) > 0 and not transaction and logical(v-closed) = no)
/*b-copy when (v-cntxt-db-num = 0 and lookup("b-add", bttns) > 0 and not transaction and logical(v-closed) = no)*/
b-close when (v-cntxt-db-num = 0 and lookup("b-add", bttns) > 0 and not transaction and logical(v-closed) = no )
b-convert when v-cntxt-db-num = 0
b-sch
B-Help
br-goods
rs-key#_three
sch-old-code
sch-self-code
WITH FRAME {&frame-name}.
VIEW FRAME {&frame-name}.
hide
b-imp-2
in frame {&frame-name} .
RUN Openbr IN THIS-PROCEDURE ( INPUT YES, INPUT NO, INPUT '':U).
APPLy "entry" to br-goods.
APPLY "VALUE-CHANGED" to br-goods.
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

&scop flt-open-open-query         OPEN QUERY br-goods FOR EACH X_ext-classif no-lock

&scop flt-open-dyn_open-query     FOR EACH X_ext-classif no-lock


&scop flt-open-query-handle      QUERY br-goods:handle

&scop flt-open-open-query-tail

&scop flt-open-query-was-opened   l-query-was-opened

&scop flt-open-sort-column-phrase sort-column-phrase

&scop flt-open-call-point         filter-point

&scop flt-open-set-filter-name    set-filter-name

&scop flt-open-indexed-reposition INDEXED-REPOSITION

&scop flt-open-waitfram yes

&scop flt-open-search-option no-lock

&scop flt-open-find-next p-find-next

&scop flt-open-find-recid v-doc-rec

&scop flt-open-find-condition p-find-condition

&scop flt-open-find-buffer-name X_ext-classif

&scop flt-open-query p-open-query

&scop flt-open-table-name X_ext-classif


filter-point = filter-point0 + p-list-mode .

title0 = "Соответствие товаров в разных системах TH".


ASSIGN
frame {&frame-name}:title = substitute("&1", title0)
filter-label = SUBSTITUTE("&1"
                          , frame {&frame-name}:title
                          )
.
{ gbl/fltopend.i
        &where-cond = " X_ext-classif.classif-subject = ~{&table_goods~} ~
                        and X_ext-classif.classif-name = v-classif-name ~
                        AND X_ext-classif.db-num = - 1 ~
                        and (rs-key#_three = -1  or X_ext-classif.key#_three = rs-key#_three) ~
                        "
        &dyn_where-cond = " substitute('X_ext-classif.classif-subject = &1&2&1 ~
                        and X_ext-classif.classif-name = &1&3&1 ~
                        AND X_ext-classif.db-num = - 1 ~
                       and (&4 = -1  or X_ext-classif.key#_three = &4) ~
                        ', {&double-quote}, ~{&table_goods~}, v-classif-name, rs-key#_three)"

        &use-ind    = "  "
        &by         = " BY X_ext-classif.charkey_three " }

if not p-open-query and v-doc-rec <> ? then
REPOSITION br-goods to recid v-doc-rec No-ERROR.
if not p-open-query and v-fltopend-rowid[1] <> ? then
query br-goods:handle:reposition-to-rowid(v-fltopend-rowid) No-ERROR.
run waitfram-hide in this-procedure .
APPLY "VALUE-CHANGED" TO br-goods in frame {&frame-name}.
APPLY "ENTRY" TO br-goods.

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
define variable v-self-gds-code as character no-undo .
define variable v-self-gds-name as character no-undo .
define variable v-self-artic as character no-undo .
define variable v-self-prodtypecode as character no-undo .
define variable v-alien-prodtypecode as character no-undo .
define variable glog as logical no-undo .
define variable v-old-good as logical no-undo .


DEFINE FRAME list1
v-self-gds-code COLUMN-LABEL "Код ТОВАРА!v16.0" FORMAT "X(9)"
v-self-artic COLUMN-LABEL "Артикул ТОВАРА!v16.0" FORMAT "X(16)"
v-self-prodtypecode COLUMN-LABEL "Произв-ль ТОВАРА!v16.0" FORMAT "X(12)"
v-self-gds-name COLUMN-LABEL "НАЗВАНИЕ ТОВАРА!v16.0" FORMAT "X(60)"
v-old-good COLUMN-LABEL "До upg" FORMAT "+/-"
X_ext-classif.key#_one COLUMN-LABEL "Код ТОВАРА!старой версии" FORMAT ">>>>>>>>9"
X_ext-classif.charkey_one COLUMN-LABEL "Артикул ТОВАРА!старой версии" FORMAT "X(16)"
v-alien-prodtypecode COLUMN-LABEL "Произв-ль ТОВАРА!старой версии" FORMAT "X(12)"
X_ext-classif.charkey_three COLUMN-LABEL "Название ТОВАРА|Ед.изм!старой версии" FORMAT "X(60)"
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
   GET prev br-goods.
END.
GET next br-goods.
DO WHILE available X_ext-classif :
  if X_ext-classif.uniq-key-rec BEGINS {&TABLE_goods} then do:
    glog = get-gds(X_ext-classif.uniq-key-rec, output v-self-artic, output v-self-prodtypecode, output v-self-gds-name).
  end.
  if not glog then do:
    assign
    v-self-artic = ''
    v-self-prodtypecode = ''
    v-self-gds-name = ''
  v-self-gds-code = ''
    .
  end.
  Display STREAM PrnLibStream
  (if X_ext-classif.uniq-key-rec BEGINS {&TABLE_goods}
  then entry(2, X_ext-classif.uniq-key-rec, {&delim-key})
  else '') @ v-self-gds-code
  (X_ext-classif.key#_three = 1) @ v-old-good
  v-self-artic
  v-self-prodtypecode
  v-self-gds-name
  X_ext-classif.key#_one
  X_ext-classif.charkey_one
  (X_ext-classif.charkey_two + string(X_ext-classif.key#_two)) @ v-alien-prodtypecode
  X_ext-classif.charkey_three
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
  GET next br-goods.
END.
UNDERLINE  STREAM PrnLibStream
v-self-gds-code
X_ext-classif.key#_one
with FRAME List1.
DISPLAY STREAM PrnLibStream
accum-count2 @ v-self-gds-code
accum-count @ X_ext-classif.key#_one
with frame List1.
HIDE  STREAM PrnLibStream FRAME BottomFrame .
HIDE  STREAM PrnLibStream FRAME List1.
output  STREAM PrnLibStream CLOSE.
reposition br-goods to recid v-rid no-error .
apply "ENTRY" to br-goods in frame {&frame-name} .
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
run fltfield-add in this-procedure('key#_one', substitute('Код товара &1', p-from-version), '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('charkey_two', substitute('Тип Производителя товара &1', p-from-version), '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('key#_two', substitute('Код Производителя товара &1', p-from-version), '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('charkey_one', substitute("Артикул товара &1", p-from-version), '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('charkey_three', substitute('Название товара|Ед.изм!&1', p-from-version), '',
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
      reposition br-goods to recid v-ri no-error.
    end.
    APPLY "ENTRY" to br-goods in frame {&frame-name} .
    APPLY "VALUE-CHANGED" to br-goods.
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
define variable v-clients-uniq-key-rec as character no-undo .
define variable v-recid as recid  no-undo .
define variable v-ok as logical no-undo .
define variable v-old-uniq-key-rec as character no-undo .

define buffer buf_goods for ub.goods.
define buffer clients_ext-classif for ub.ext-classif.
define buffer buf_clients for ub.clients.
DEFINE BUFFER buf_ext-classif FOR ub.ext-classif.

if X_ext-classif.uniq-key-rec <> ''
and X_ext-classif.key#_three = 1
then do:
  message
  "Данное соответствие установлено в процессе upgrade - ТОВАР ССЫЛАЕТСЯ САМ НА СЕБЯ - перепривязать НЕВОЗМОЖНО"
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
  v-old-uniq-key-rec = X_ext-classif.uniq-key-rec.
  message
  substitute("Уже есть соответствие  между данными товара &1 в БД v16.0 и этим же товаром в БД &3&2" +
            "Вы УВЕРЕНЫ, что хотите их изменить?"
            , entry(2, X_ext-classif.uniq-key-rec, {&delim-key})
            , {&new-line}
            , p-from-version)
  view-as alert-box question buttons yes-no update glog.
  if not glog then return no-apply.
  find first buf_goods no-lock where
          buf_goods.gds-code = integer(entry(2, X_ext-classif.uniq-key-rec, {&delim-key}))   .
  v-rid-list = string(recid(buf_goods)).
end.
find first clients_ext-classif share-lock where
          clients_ext-classif.classif-subject  = {&table_clients}
      and  clients_ext-classif.classif-name  = v-cli-classif-name
      and clients_ext-classif.db-num = -1
      and clients_ext-classif.charkey_one = X_ext-classif.charkey_two
      and clients_ext-classif.key#_one = X_ext-classif.key#_two     no-error .
if not available clients_ext-classif then do:
  message
  substitute("Не НАЙДЕНА запись соответствия для производителя  &1&2 товара с кодом &3 в БД &5&4" +
            "Связать НЕВОЗМОЖНО"
            ,X_ext-classif.charkey_two
            ,X_ext-classif.key#_two
            ,X_ext-classif.key#_one
            ,{&new-line}
            , p-from-version
            )
  view-as alert-box error .
  undo, return error .
end.
DEFINE VARIABLE v-rowid AS ROWID NO-UNDO.
DEFINE VARIABLE v-tbl-name AS character NO-UNDO.
RUN gen-row-keyr IN THIS-PROCEDURE ( INPUT clients_ext-classif.uniq-key-rec
                                    ,input ?
                                    ,INPUT "ub"
                                    ,INPUT ? /*p-bh-handle*/
                                    ,INPUT NO-LOCK
                                    ,OUTPUT v-rowid
                                    ,OUTPUT v-tbl-name) no-error.
if error-status:error then do:
  message
  substitute("Ошибка при определении записи соответствия для производителя  &1&2 товара с кодом &3 в БД &5&4" +
            "Связать НЕВОЗМОЖНО"
            ,X_ext-classif.charkey_two
            ,X_ext-classif.key#_two
            ,X_ext-classif.key#_one
            ,{&new-line}
            , p-from-version
            )
  view-as alert-box error .
  undo, return error .
end.
find first buf_clients no-lock where rowid(buf_clients) = v-rowid.
run ref/gds-ref.p (
                 input parparentproc
                ,input "b-sel,b-add"
                ,input ?             /*p-stat */
                ,input {&producer}   /*p-list  */
                ,input ?             /*p-cond  */
                ,input (if available buf_goods then recid(buf_goods) else ?) /*p-rec   */
                ,input ?             /*p-grp   */
                ,input buf_clients.obj-type  /*p-cli-type */
                ,input buf_clients.obj-code  /*p-cli-code  */
                ,input v-cntxt-obj-type    /*p-obj-type  */
                ,input v-cntxt-obj-code   /*p-obj-code  */
                ,input ?             /*p-other     */
                ,output v-rID-list).
if v-rid-list = '':U then return no-apply.
find first buf_goods where recid (buf_goods) = integer (v-rid-list) no-lock no-error.
/*заполним временные таблицу параметрами вызова сохранения клиентов*/
run cmp/upg-conn.p ( input "connect"
                    ,input p-from-version
                    ,output v-ok) no-error.
if not v-ok then do:
  message
  substitute("Ошибка при подключении к БД TH &4&1&2&1&3"
             , {&new-line}
             , error-status:get-message(1)
             , return-value
             , p-from-version)
  view-as alert-box error .
  return error .
end.
run str/diallog.w ( input parparentproc
          , input this-procedure
          , input 'cmp/ththgdse.p':U
          , input (string(buf_goods.gds-code) + {&delim-par} +
                   string(X_ext-classif.key#_one) + {&delim-par} +
                   p-from-version
                   )
          , input no /*p-auto-go*/
          , input ''
          , input 'Связывание данных по товарам') no-error .
if connected ("src") then do:
  disconnect src.
end.
find first buf_ext-classif no-lock where
          recid(buf_ext-classif) = recid(X_ext-classif).
if X_ext-classif.uniq-key-rec <> v-old-uniq-key-rec then do:
  assign
  v-recid = recid(X_ext-classif).
  run Openbr in this-procedure ( INPUT YES, INPUT NO, INPUT '':U).
  reposition  br-goods to recid v-recid no-error.
  APPLY "entry" to br-goods in frame {&frame-name} .
  apply "value-changed" to br-goods.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-untie Dialog-Frame
PROCEDURE proc-b-untie :
define variable glog as logical no-undo .
define variable v-recid as recid no-undo .
define variable v-tbl-row as rowid no-undo .
define variable v-tbl-name as character no-undo .
DEFINE buffer buf_goods for ub.goods.
DEFINE BUFFER buf_ext-classif FOR ub.ext-classif.
FIND FIRST buf_ext-classif EXCLUSIVE-LOCK WHERE
          recid(buf_ext-classif) = RECID(X_ext-classif) .
IF buf_ext-classif.uniq-key-rec = '' THEN DO:
   MESSAGE
   substitute("товаром с кодом &1 (&2 &3 &4) в &5 версии НЕ ИМЕЕТ СООТВЕТСТВИЯ ТОВАРУ 16.0 версии&6" +
              "Нечего отвязывать!!!"
              ,buf_ext-classif.key#_one
              ,buf_ext-classif.charkey_one
              ,(buf_ext-classif.charkey_two + STRING(buf_ext-classif.key#_two))
              ,buf_ext-classif.charkey_three
              ,p-from-version
              ,{&new-line}
               )
  VIEW-AS ALERT-BOX warning.
  return "return".
END.
if buf_ext-classif.key#_three <> 0 then do:  message
  "Данный товар был уже сведен ранее/или до upgrade" skip
  "Удалить соответствие невозможно "
  view-as alert-box error .
  undo, return error.
end.
run gen-row-keyr in this-procedure (
  input  buf_ext-classif.uniq-key-rec
  ,input  ? /*p-key-handle */
  ,input  "ub"
  ,input  ? /*p-tt-handle  */
  ,input  no-lock
  ,output v-tbl-row
  ,output v-tbl-name   ).
find first buf_goods no-lock where
          rowid(buf_goods) = v-tbl-row.
MESSAGE
substitute("Вы уверены, что хотите удалить соответствие между &5" +
           "товаром с кодом &1 (&2 &3 &4) в старой версии&5" +
           "товаром с кодом &6 (&7 &8 &9) в 16.0 версии&5"  +
           "?????"
           ,buf_ext-classif.key#_one
           ,buf_ext-classif.charkey_one
           ,(buf_ext-classif.charkey_two + STRING(buf_ext-classif.key#_two))
            ,buf_ext-classif.charkey_three
             ,{&NEW-LINE}
            ,buf_goods.gds-code
            ,buf_goods.artic
            ,buf_goods.prod-type + STRING(buf_goods.prod-code)
            ,buf_goods.gds-name + {&delim-par} + buf_goods.unit-base
             )
VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE glog.
IF NOT glog THEN RETURN 'return'.
assign
buf_ext-classif.uniq-key-rec = ''.
v-recid = recid(buf_ext-classif).
run Openbr in this-procedure ( INPUT YES, INPUT NO, INPUT '':U).
reposition  br-goods to recid v-recid no-error.
APPLY "entry" to br-goods in frame {&frame-name} .
apply "value-changed" to br-goods.
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
  message
  "Уже завершен этап УСТАНОВКИ СООТВЕТСТВИЯ ДАННЫХ ПО ТОВАРАМ в разных системах IBS TH"
  view-as alert-box error .
  undo, return error .
end.
message
"Вы уверены, что Вы полностью установили СООТВЕТСТВИЕ ДАННЫХ ПО ТОВАРАМ в разных системах IBS TH?"
view-as alert-box question buttons yes-no update glog.
if not glog then undo, return .
find first buf_ext-classif no-lock where
          buf_ext-classif.classif-subject = {&table_goods}
      and buf_ext-classif.classif-name = v-classif-name
      AND buf_ext-classif.db-num = - 1
      and buf_ext-classif.uniq-key-rec = ''
      no-error.
if available buf_ext-classif then do:
  message
  substitute("ИМЕЕТСЯ запись по товару в БД &1, которой не соответствует ни один ТОВАР БД v16.0", p-from-version) skip
  "Закрытие этапа НЕВОЗМОЖНО"
  view-as alert-box error .
  undo, return error .
end.
main-block:
do transaction:
  for each buf_ext-classif where
          buf_ext-classif.classif-subject = {&table_goods}
      and buf_ext-classif.classif-name = v-classif-name
      AND buf_ext-classif.db-num = - 1
      AND buf_ext-classif.key#_three = 0
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
  on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
  :
    assign
    buf_ext-classif.key#_three = 2
    .
  end.
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
  end case.
end.
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
end case.
if logical(v-loc-closed) = yes then do:
  disable
  b-close
  with frame {&frame-name} .
  if available X_ext-classif then v-doc-rec = recid(X_ext-classif).
  run openbr in this-procedure ( INPUT YES, INPUT NO, INPUT '':U) no-error.
  reposition br-goods to recid(v-doc-rec) no-error. APPLy 'ENTRY' to br-goods .
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-convert-mob-scan Dialog-Frame 
PROCEDURE proc-convert-mob-scan :
DEFINE VARIABLE glog AS LOGICAL NO-UNDO.
DEFINE VARIABLE v-ok AS LOGICAL NO-UNDO.
run cmp/upg-conn.p ( input "connect"
                    ,input p-from-version
                    ,output v-ok) no-error.
if not v-ok then do:
  message
  substitute("Ошибка при подключении к БД TH &4&1&2&1&3"
             , {&new-line}
             , error-status:get-message(1)
             , return-value
             , p-from-version)
  view-as alert-box error .
  return error .
end.
run str/diallog.w ( input parparentproc
          , input this-procedure
          , input 'cmp/ththgdsc.p':U
          , input p-from-version
          , input no /*p-auto-go*/
          , input ''
          , input substitute('Конвертация файла БАР-КОД;ЦЕНА с кодами из &1', p-from-version)) no-error .
if connected ("src") then do:
  disconnect src.
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
          , input 'cmp/ththgdst.p':U
          , input (p-copy-option + {&delim-par} +
                  (if p-copy-option = 'one'
                  then string(X_ext-classif.key#_one)
                  else '') + {&delim-par} +
                  (if p-copy-option = 'list'
                  then v-rid-list
                  else '') + {&delim-par} +
                  p-from-version)
          , input yes /*p-auto-go*/
          , input ''
          , input substitute('Копирование данных по товарам из БД &1 во временную таблицу', p-from-version)) no-error .
if connected ("src") then do:
  disconnect src.
end.
if can-find (first goods-01) then do:
  run str/diallog.w ( input parparentproc
            , input this-procedure
            , input 'cmp/ththgdss.p':U
            , input p-from-version
            , input no /*p-auto-go*/
            , input ''
            , input 'Сохранение данных по товарам в БД v16.0') no-error .
end.
else do:
  message
  "Нет записей во временной таблице - НЕЧЕГО СОХРАНЯТЬ"
  view-as alert-box .
end.
assign
v-recid = recid(X_ext-classif).
run Openbr in this-procedure ( INPUT YES, INPUT NO, INPUT '':U).
reposition  br-goods to recid v-recid no-error.
APPLY "entry" to br-goods in frame {&frame-name} .
apply "value-changed" to br-goods.
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
    ,input substitute(" and X_ext-classif.key#_one = &1 "
      , v-old-code)
    ).
apply "entry":u to sch-old-code in frame {&frame-name} .


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
    ,input substitute(" and X_ext-classif.uniq-key-rec = &1&2&3&4&1 "
                      , {&double-quote}
                      , {&TABLE_goods}
                      , {&delim-KEY}
                      , p-self-code)
    ).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-imp Dialog-Frame 
PROCEDURE proc-imp :
DEFINE INPUT PARAMETER p-imp-version AS INTEGER NO-UNDO.
DEFINE VARIABLE glog AS LOGICAL NO-UNDO.
DEFINE VARIABLE v-ok AS LOGICAL NO-UNDO.
DEFINE BUFFER buf_ext-classif FOR ub.ext-classif.
CASE p-imp-version:
    WHEN 1 THEN DO:
        FIND FIRST buf_ext-classif NO-LOCK WHERE
                buf_ext-classif.classif-subject = {&table_goods}
            and buf_ext-classif.classif-name = v-classif-name
            AND buf_ext-classif.db-num = - 1
            and buf_ext-classif.key#_three = 0
            NO-ERROR.
        IF NOT AVAILABLE buf_ext-classif THEN DO:
          MESSAGE
          substitute("Вы действительно хотите получить соответствие данных по товарам системы TH &1?", p-from-version)
           VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE glog.
          IF NOT glog  THEN RETURN NO-APPLY.

        END.
        ELSE DO:
          MESSAGE
          substitute("У Вас уже есть закачанные соответствия по товарам системы TH &1", p-from-version) SKIP
          "Повторный импорт УНИЧТОЖИТ ВСЕ СООТВЕТСТВИЕ УСТАНОВЛЕННЫЕ ПОСЛЕ upgrade" SKIP
          substitute("Вы действительно хотите вкачать соответствия по товарам системы TH &1?", p-from-version)
           VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE glog.
          IF NOT glog  THEN RETURN NO-APPLY.
        END.

    END.
    WHEN 2 THEN DO:
        FIND FIRST buf_ext-classif NO-LOCK WHERE
                buf_ext-classif.classif-subject = {&table_goods}
            and buf_ext-classif.classif-name = v-classif-name
            AND buf_ext-classif.db-num = - 1
            and buf_ext-classif.key#_three = 0
            NO-ERROR.
        IF NOT AVAILABLE buf_ext-classif THEN DO:
            MESSAGE
            "Сначала надо получить соответствия!!!"
            VIEW-AS ALERT-BOX ERROR.
            UNDO, RETURN ERROR.
        END.
        MESSAGE
        "А ВЫ НАЖИМАЛИ КНОПКУ <ПОЛУЧИТЬ СООТВЕТСТВИЯ>?"
         VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE glog.
        IF NOT glog  THEN RETURN.
    END.
END CASE.
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
          , input 'cmp/ththgdsi.p':U
          , input string(p-imp-version) + {&delim-par} + p-from-version
          , input no /*p-auto-go*/
          , input ''
          , input substitute('Закачка соответствий по товарам БД &1', p-from-version)) no-error .
if connected ("src") then do:
  disconnect src.
end.
RUN Openbr IN THIS-PROCEDURE ( INPUT YES, INPUT NO, INPUT '':U).
APPLY "entry" TO br-goods in frame {&frame-name} .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-report Dialog-Frame 
PROCEDURE proc-report :
/*надо задать параметря что печатать*/
DEFINE VARIABLE glog AS LOGICAL NO-UNDO.
DEFINE VARIABLE v-ok AS LOGICAL NO-UNDO.
DEFINE BUFFER buf_ext-classif FOR ub.ext-classif.
message
substitute("Просматривать УДАЛЕННЫЕ товары &1?", p-from-version)
view-as alert-box question buttons yes-no update glog.
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
          , input 'cmp/ththgdsr.p':U
          , input string(glog)
          , input no /*p-auto-go*/
          , input ''
          , input substitute('Детальный отчет по имеющимся и отсутствующим  соответствиям по товарам БД &1 и v16.0', p-from-version)) no-error .
if connected ("src") then do:
  disconnect src.
end.
define variable ii-excel as integer no-undo .
define variable ii-page as integer no-undo init 1.
define variable v-correct-bind as character no-undo .
define variable v-report-name as character no-undo .
define buffer buf1_sheetf for sheetf.
define buffer buf_sheetf for sheetf.
define buffer buf_temp-bind for temp-bind.
make-excel = yes.
run get-report-num in parparentproc ( output g#report-num).
run prn-lib-get-report-name  in this-procedure (
                                                  input parParentProc
                                                  ,output v-report-name
                                                ).
run OpenForExcel in this-procedure  .

&scop   page-excel-block  if ii-excel > 32000 then do:                                    ~
                           {&pageExcel}                                               ~
                           find first buf_sheetf where                                ~
                                     buf_sheetf.sheet-num = ii-page + 1 no-error.     ~
                           if not available buf_sheetf then do:                       ~
                             create buf_sheetf.                                       ~
                           end.                                                       ~
                           buffer-copy buf1_sheetf except sheet-num                   ~
                           to buf_sheetf                                              ~
                           assign                                                     ~
                           buf_sheetf.sheet-num = ii-page + 1                         ~
                           .                                                          ~
                           run rep/extitle.p (ii-page + 1) .                              ~
                           find first buf_sheetf where                                ~
                                     buf_sheetf.sheet-num = ii-page + 1.              ~
                           buf_sheetf.Bas-Params = string(buf_Sheetf.Excel-Row-Heder /*количество строк в назв колонок*/ ) . ~
                           assign                                                     ~
                           ii-page = ii-page + 1                                      ~
                           ii-excel = 0                                               ~
                           .                                                          ~
                         end

assign
sheetf.Excel-Column-Lable = substitute("Проблемы,&1 Код товара/ДопБК,v16.0 Код товара,&1 Артикул,v16.0 Артикул,"
                                       , p-from-version)
                            +
                            substitute("&1 Пр-ль,v16.0 Пр-ль,&1 Название,v16.0 Название,&1 ед.изм,v16.0 ед.изм,"
                                       , p-from-version)
                            +
                            substitute("&1Статус,v16.0Статус,&1Группа,v16.0Группа,&1Назв.Пр-ля,v16.0Назв.пр-ля,тип строки"
                                       , p-from-version)
sheetf.colformat = "1=@;2=0;3=0;4=@;5=@;6=@;7=@;8=@;9=@;10=@;11=@;12=@;13=@;14=@;15=@;16=@;17=@;18=@"
sheetf.sizes = "12,13,9,16,16,12,12,48,48,3,3,4,4,45,45,45,45,3"
sheetf.Bas-File = "exe/ththgdsr.bas"
.
my-handle = parparentproc.
run waitfram-show in this-procedure ("Ждите..." ).
assign
Reportname = substitute("Подробный отчет о проблемах в соответствиях товаров &1 и v16.0", p-from-version)
Reportheader = substitute("Удаленные товары - &1", (if glog then "Включены" else "не включены"))
str1 = "Расшифровка для строк товаров (<голубые> строки: -1 -  запись соответствия не заполнена; 0 - нет записи соответствия; А - проблемы с артикулом, Н - проблемы с названием; Г - проблемы с группой; П - проблемы с производителем, У - проблемы со статусом; И - проблемы с осн.ед.изм; Д - проблемы с ДопБК "
str2 = substitute("    если данные в таблице соответствия отличаются от данныъ в БД &1 на текущий момент: а - отличается артикул; п - отличается производитель; н - отличается название; и- отличается ед.изм", p-from-version)
str3 = "Расшифровка для строк ДопБК (<белые> строки: '-' -  не найден ДопБК; Т - проблема с товаром (например, ДопБК привязан к товару, который  НЕСВЯЗАН с его товаром); У - проблемы с ВКл/ВЫКЛ; И - проблемы с ед.изм; К - проблемы с коэфф"
.

run rep/extitle.p ( input 1).
sheetf.Bas-Params = string(Sheetf.Excel-Row-Heder /*количество строк в назв колонок*/ ) .
run waitfram-show in this-procedure ("Ждите..." ).
find first buf1_sheetf no-lock where
          buf1_sheetf.sheet-num = 1 or buf1_sheetf.sheet-num = 0.
v-correct-bind = fill( {&space-char}, 13) .
for each temp-bind where
        temp-bind.correct-bind > v-correct-bind
by temp-bind.src-gds-code:
  {&PutExcel}
  temp-bind.correct-bind {&tabulation}
  temp-bind.src-gds-code {&tabulation}
  temp-bind.trg-gds-code {&tabulation}
  temp-bind.src-artic    {&tabulation}
  temp-bind.trg-artic    {&tabulation}
  (temp-bind.src-prod-type + string(temp-bind.src-prod-code))  {&tabulation}
  (temp-bind.trg-prod-type + string(temp-bind.trg-prod-code))  {&tabulation}
  temp-bind.src-gds-name {&tabulation}
  temp-bind.trg-gds-name {&tabulation}
  temp-bind.src-unit-base {&tabulation}
  temp-bind.trg-unit-base {&tabulation}
&scop status-code  string(temp-bind.src-stts)
  {&status-int-name}  {&tabulation}
&scop status-code  string(temp-bind.trg-stts)
  {&status-int-name} {&tabulation}
  temp-bind.src-grp-name {&tabulation}
  temp-bind.trg-grp-name {&tabulation}
  temp-bind.src-prod-name {&tabulation}
  temp-bind.trg-prod-name {&tabulation}
  "gds"
  skip
  .
  ii-excel = ii-excel + 1.
  for each temp-prod-bc where
          (temp-prod-bc.src-gds-code > 0
          and temp-prod-bc.old-gds-code = temp-bind.src-gds-code)
    or  (temp-prod-bc.src-gds-code   = 0
         and temp-prod-bc.v151-gds-code > 0
       and temp-prod-bc.v151-gds-code = temp-bind.trg-gds-code)
          :
    if temp-prod-bc.v151-gds-code <> 0
    and temp-prod-bc.v151-gds-code <> temp-bind.trg-gds-code
    and temp-prod-bc.src-gds-code <> 0
    then do:
      find first buf_temp-bind where
                buf_temp-bind.trg-gds-code = temp-prod-bc.v151-gds-code no-error.
    end.
    else do:
      release buf_temp-bind.
    end.
    {&PutExcel}
    temp-prod-bc.correct-pbc-bind {&tabulation}
    temp-prod-bc.src-b-str {&tabulation}
    temp-prod-bc.v151-gds-code {&tabulation}
    {&tabulation}
    (if available buf_temp-bind then buf_temp-bind.trg-artic else '') {&tabulation}
    {&tabulation}
    (if available buf_temp-bind then (buf_temp-bind.trg-prod-type + string(buf_temp-bind.trg-prod-code)) else '') {&tabulation}
    {&tabulation}
    (if available buf_temp-bind then buf_temp-bind.trg-gds-name else '') {&tabulation}
    {&tabulation}
    (if available buf_temp-bind then buf_temp-bind.trg-unit-base else '') {&tabulation}
    {&tabulation}
&scop status-code  string(buf_temp-bind.trg-stts)
    (if available buf_temp-bind then {&status-int-name} else '') {&tabulation}
    {&tabulation}
    (if available buf_temp-bind then buf_temp-bind.trg-grp-name else '')  {&tabulation}
    {&tabulation}
    (if available buf_temp-bind then buf_temp-bind.trg-prod-name else '') {&tabulation}
    "pbc"
    skip
    .
    ii-excel = ii-excel + 1.
  end.
  {&page-excel-block}.
end.
{&CloseExcel}
run waitfram-hide in this-procedure .
find first buf_sheetf where
         buf_sheetf.sheet-num = 1.
assign
buf_sheetf.file-name = v-report-name
.
release buf_sheetf.
run rep/runexcel.p ( input (v-report-name + ".txt")) no-error.
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-gds Dialog-Frame 
FUNCTION get-gds RETURNS LOGICAL ( INPUT p-uniq-key-rec AS character
    ,OUTPUT p-artic AS CHARACTER
    ,OUTPUT p-prodtypecode AS CHARACTER
    ,OUTPUT p-gds-name AS CHARACTER ) :
DEFINE VARIABLE v-rowid AS ROWID NO-UNDO.
DEFINE VARIABLE v-tbl-name AS character NO-UNDO.
DEFINE BUFFER buf_goods FOR ub.goods.
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
IF v-rowid = ? THEN RETURN no.

FIND FIRST buf_goods NO-LOCK WHERE ROWID(buf_goods) = v-rowid.
IF AVAILABLE buf_goods THEN DO:
    ASSIGN
    p-artic = buf_goods.artic
    p-prodtypecode = buf_goods.prod-type + STRING(buf_goods.prod-code)
    p-gds-name = buf_goods.gds-name.
    RETURN yes.   /* Function return value. */
END.
RETURN NO.
END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

