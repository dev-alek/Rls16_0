&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

РАБОТА с ЗАРЕЗЕРВИРОВАННЫМИ ПАРТИЯМ ПРОДАЖИ ПО ВАРИАНТАМ ЗАКУПКИ

Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/11/05
Author: Bakhtadze Natalya
Creation date: 02/11/05


------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO.
DEFINE PARAMETER BUFFER buf_inkas FOR ub.inkas.
DEFINE INPUT PARAMETER p-parent-handle AS HANDLE NO-UNDO.
define input parameter p-mode as character no-undo .
define input parameter bttns  as char   no-undo .
/*кнопки для нажатия*/
DEFINE INPUT-OUTPUT PARAMETER p-rid-list AS CHARACTER NO-UNDO.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "РАБОТА с ЗАРЕЗЕРВИРОВАННЫМИ ПАРТИЯМ ПРОДАЖИ ПО ВАРИАНТАМ ЗАКУПКИ".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/showinf.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/salevzak.i "SHARED" }
{ gbl/flt-def.i }
{ gbl/fltfield.i }
{ gbl/cur-time.i }
{ cmp/r-pril.i new }
{ gbl/prn-lib.i }
{ gbl/fltopend.i defproc }
define variable filter-point as character no-undo init "salevzaw" .
define variable filter-point0 as character no-undo init "salevzaw" .
define variable filter-label as character no-undo init "Партии продажи по вариантам закупки" .
define variable filter-label0 as character no-undo init "Партии продажи по вариантам закупки" .

define variable sort-column-name as character no-undo .
define variable v-doc-rec as recid no-undo .
DEFINE VARIABLE v-supp AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-supp-name AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-tab-order AS CHARACTER NO-UNDO.
define variable v-curr-r-b as character no-undo .
define variable gds-rec as recid no-undo .
DEFINE NEW SHARED BUFFER X_sj-print FOR sj-print.
define buffer buf_trn-doc for ub.trn-doc.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BR-sj

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_sj-print

/* Definitions for BROWSE BR-sj                                         */
&Scoped-define FIELDS-IN-QUERY-BR-sj X_sj-print.gds-code X_sj-print.gds-name X_sj-print.var-purch (IF X_sj-print.price-flag THEN X_sj-print.sale-sum / X_sj-print.qnty ELSE X_sj-print.price-sale) @ X_sj-print.price-sale X_sj-print.price-flag X_sj-print.is-cash X_sj-print.qnty X_sj-print.sale-sum X_sj-print.artic X_sj-print.prod-name X_sj-print.supp-type + string(X_sj-print.supp-code) @ v-supp get-supp-name(BUFFER X_sj-print) @ v-supp-name
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-sj X_sj-print.sale-sum
&Scoped-define ENABLED-TABLES-IN-QUERY-BR-sj X_sj-print
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-BR-sj X_sj-print
&Scoped-define SELF-NAME BR-sj
&Scoped-define QUERY-STRING-BR-sj FOR EACH X_sj-print NO-LOCK
&Scoped-define OPEN-QUERY-BR-sj OPEN QUERY {&SELF-NAME} FOR EACH X_sj-print NO-LOCK.
&Scoped-define TABLES-IN-QUERY-BR-sj X_sj-print
&Scoped-define FIRST-TABLE-IN-QUERY-BR-sj X_sj-print


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BR-sj}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit B-mark b-sel B-parts B-chk B-print ~
B-sch B-Help rs-r-v rs-vzak rs-cash BR-sj mark-num fvzak-1 fvzakr-1 ~
fvzakv-1 fvzak-2 fvzakr-2 fvzakv-2
&Scoped-Define DISPLAYED-OBJECTS rs-r-v rs-vzak rs-cash mark-num fvzak-1 ~
fvzakr-1 fvzakv-1 fvzak-2 fvzakr-2 fvzakv-2

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-supp-name Dialog-Frame
FUNCTION get-supp-name RETURNS CHARACTER
  ( BUFFER buf_sj-print FOR sj-print )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-chk
     LABEL "&Чеки"
     SIZE 10 BY 1.

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-mark
     LABEL "&*"
     SIZE 3 BY 1.

DEFINE BUTTON B-parts
     LABEL "&Партии"
     SIZE 10 BY 1.

DEFINE BUTTON B-print
     LABEL "Пе&чать"
     SIZE 3 BY 1.

DEFINE BUTTON b-quit AUTO-GO
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-sch
     LABEL "&Фильтр"
     SIZE 3 BY 1.

DEFINE BUTTON b-sel AUTO-GO
     LABEL "Вы&бор"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE fvzak-1 AS DECIMAL FORMAT "->>9.999":U INITIAL 0
     LABEL "ВСЕГО По варианту закупки 1 в %"
      VIEW-AS TEXT
     SIZE 8 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fvzak-2 AS DECIMAL FORMAT "->>9.999":U INITIAL 0
     LABEL "ВСЕГО По варианту закупки 2 в %"
      VIEW-AS TEXT
     SIZE 8 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fvzakr-1 AS DECIMAL FORMAT "->>9.999":U INITIAL 0
     LABEL "р"
      VIEW-AS TEXT
     SIZE 8 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fvzakr-2 AS DECIMAL FORMAT "->>9.999":U INITIAL 0
     LABEL "р"
      VIEW-AS TEXT
     SIZE 8 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fvzakv-1 AS DECIMAL FORMAT "->>9.999":U INITIAL 0
     LABEL "в"
      VIEW-AS TEXT
     SIZE 8 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fvzakv-2 AS DECIMAL FORMAT "->>9.999":U INITIAL 0
     LABEL "в"
      VIEW-AS TEXT
     SIZE 8 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE mark-num AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 6 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE rs-cash AS LOGICAL
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Все", ?,
"Наличные", yes,
"Безналичные", no
     SIZE 33.5 BY 1 NO-UNDO.

DEFINE VARIABLE rs-r-v AS LOGICAL
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Все", ?,
"Расход", yes,
"Возврат", no
     SIZE 33.5 BY 1 NO-UNDO.

DEFINE VARIABLE rs-vzak AS INTEGER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Все", 0,
"Вариант закупки 1", 1,
"Вариант закупки 2", 2
     SIZE 52.5 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-sj FOR
      X_sj-print SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-sj
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-sj Dialog-Frame _FREEFORM
  QUERY BR-sj DISPLAY
      X_sj-print.gds-code     column-label "Код товара"
X_sj-print.gds-name     column-label "Название товара" format "X(30)"
X_sj-print.var-purch    column-label "Вар.!закуп"   format "9"
(IF X_sj-print.price-flag
 THEN  X_sj-print.sale-sum / X_sj-print.qnty
 ELSE X_sj-print.price-sale)
@ X_sj-print.price-sale   column-label "Цена нетто"
X_sj-print.price-flag   column-label "При!веден."         format "+/"
X_sj-print.is-cash      column-label "Нал"                format "+/"
X_sj-print.qnty         column-label "Количество"
X_sj-print.sale-sum     column-label "Сумма нетто"
X_sj-print.artic        column-label "Артикул"
X_sj-print.prod-name    column-label "Производитель"   format "X(30)"
X_sj-print.supp-type + string(X_sj-print.supp-code) @ v-supp                column-label "Поставщик"       format "X(12)"
get-supp-name(BUFFER X_sj-print)  @ v-supp-name           column-label "Поставщик-название" format "X(30)"
ENABLE
X_sj-print.sale-sum
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 17 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-mark AT ROW 1 COL 11
     b-sel AT ROW 1 COL 21
     B-parts AT ROW 1 COL 41
     B-chk AT ROW 1 COL 51
     B-print AT ROW 1 COL 89
     B-sch AT ROW 1 COL 92
     B-Help AT ROW 1 COL 95
     rs-r-v AT ROW 2 COL 1.5 NO-LABEL
     rs-vzak AT ROW 2 COL 39.5 NO-LABEL
     rs-cash AT ROW 3 COL 1.5 NO-LABEL
     BR-sj AT ROW 5 COL 1
     mark-num AT ROW 1 COL 12.5 COLON-ALIGNED NO-LABEL
     fvzak-1 AT ROW 3 COL 67 COLON-ALIGNED
     fvzakr-1 AT ROW 3 COL 78 COLON-ALIGNED
     fvzakv-1 AT ROW 3 COL 89 COLON-ALIGNED
     fvzak-2 AT ROW 4 COL 67 COLON-ALIGNED
     fvzakr-2 AT ROW 4 COL 78 COLON-ALIGNED
     fvzakv-2 AT ROW 4 COL 89 COLON-ALIGNED
     SPACE(0.24) SKIP(17.36)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Зарезервированные партии продажи по вариантам закупки"
         DEFAULT-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BR-sj rs-cash Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-sj
/* Query rebuild information for BROWSE BR-sj
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH X_sj-print NO-LOCK.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE BR-sj */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Зарезервированные партии продажи по вариантам закупки */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-chk
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-chk Dialog-Frame
ON CHOOSE OF B-chk IN FRAME Dialog-Frame /* Чеки */
DO:
  if not available X_sj-print then return no-apply.

  RUN proc-check-tovar IN THIS-PROCEDURE (X_sj-print.is-out, X_sj-print.gds-code) NO-ERROR.
  IF ERROR-STATUS:error THEN RETURN NO-APPLY.
  apply "entry" to br-sj in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mark Dialog-Frame
ON CHOOSE OF B-mark IN FRAME Dialog-Frame /* * */
DO:
define variable loc#log as logical no-undo .
  if available sj-print then do:
    { gbl/markstrn.i sj-print p-rid-list }
    loc#log = br-sj:refresh() .

    if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
        loc#log = br-sj:select-next-row ().
        apply "VALUE-CHANGED" to br-sj in frame {&frame-name}.
    end.
    if num-entries( p-rid-list ) = 0
    then
        hide mark-num in frame {&frame-name}.
    else
        disp num-entries( p-rid-list ) @ mark-num with frame {&frame-name}.
  end.
  apply "entry" to br-sj in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-parts
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-parts Dialog-Frame
ON CHOOSE OF B-parts IN FRAME Dialog-Frame /* Партии */
DO:
  DEFINE variable v-doc-qnty LIKE ub.doc-line.doc-qnty NO-UNDO.
  define variable what-mode as logical no-undo init yes.
  define variable v-prt-rec as recid no-undo .
  define buffer buf_doc-line for ub.doc-line.
  if not available X_sj-print then return no-apply.

  FIND FIRST buf_doc-line No-LOCK WHERE
            buf_doc-line.doc-code = (if X_sj-print.is-out then buf_trn-doc.doc-code else buf_trn-doc.out-code)
      AND  buf_doc-line.artic = X_sj-print.artic
      AND  buf_doc-line.prod-type = X_sj-print.prod-type
      AND  buf_doc-line.prod-code = X_sj-print.prod-code No-ERROR.

 assign
 v-doc-qnty = buf_doc-line.doc-qnty

 .
  if can-find(first ub.doc-prts where
                ub.doc-prts.gds-code = X_sj-print.gds-code AND
                ub.doc-prts.out-code = buf_doc-line.doc-code) OR
  can-find(first ub.doc-pl where
                ub.doc-pl.gds-code = X_sj-print.gds-code AND
                ub.doc-pl.out-code = buf_doc-line.doc-code) OR
  can-find(first ub.doc-pl-pump where
                ub.doc-pl-pump.gds-code = X_sj-print.gds-code AND
                ub.doc-pl-pump.out-code = buf_doc-line.doc-code) or
  can-find(first ub.doc-fbr-gds where
                ub.doc-fbr-gds.gds-code = X_sj-print.gds-code AND
                ub.doc-fbr-gds.out-code = buf_doc-line.doc-code) then
  what-mode = no.
  if what-mode = no
  and p-mode = {&update} then do:
    message
    substitute("Для строки накладной продажи &1 &2&3 (код товара &4) НЕВОЗМОЖНО РУЧНОЕ ПЕРЕЗЕРВИРОВАНИЕ партий:&5" +
               "в строке проводилось резерирование по партиям и/или по складским местам и/или с учетом дальнейшего автопроизводства,&5" +
               "список партий будет доступен ТОЛЬКО ДЛЯ ПРОСМОТРА"
               , X_sj-print.artic
               , X_sj-print.prod-type
               , X_sj-print.prod-code
               , X_sj-print.gds-code
               , {&new-line})
    view-as alert-box WARNING.
  end.
  run str/parts-l.w
    (input parparentproc
    ,input buf_inkas.obj-type          /* v-obj-type   */
    ,input buf_inkas.obj-code          /* v-obj-code   */
    ,input X_sj-print.gds-code                /* p-gds-code   */
    ,input buf_doc-line.doc-code       /* p-doc-code   */
    ,input (if  (p-mode = {&update} /* p-edit-mode  */
                  and what-mode
                  )
            then {&update}
            else {&lookup}
            )
    ,input (if buf_inkas.status_ = {&fact} /* p-r-parts    */
            then {&parts-l_parts-all}
            else {&parts-l_parts-document}
            )
    ,input {&parts-l_object-current} /* p-one-all    */
    ,input {&parts-l_call-document}  /* p-call-point */
    ,output v-prt-rec                  /* part-recid   */
    ).
  apply "entry" to br-sj in frame {&frame-name}.
  FIND FIRST buf_doc-line No-LOCK WHERE
            buf_doc-line.doc-code = (if X_sj-print.is-out then buf_trn-doc.doc-code else buf_trn-doc.out-code)
      AND  buf_doc-line.artic = X_sj-print.artic
      AND  buf_doc-line.prod-type = X_sj-print.prod-type
      AND  buf_doc-line.prod-code = X_sj-print.prod-code No-ERROR.

  assign
  v-doc-rec = recid(X_sj-print).
  if  (p-mode = {&update} /* p-edit-mode  */
                  and what-mode
                  ) then do:
    run cre-sj in p-parent-handle (
                                  input v-curr-r-b
                                , buf_inkas.inkas-code
                                , input X_sj-print.gds-code  /*p-gds-code*/
                                , input X_sj-print.artic  /*p-artic*/
                                , input X_sj-print.prod-type /*pprod-type*/
                                , input X_sj-print.prod-code    /*pprod-code*/
                                , input X_sj-print.is-out     /*p-is-out*/
                                , input recid(buf_doc-line)    /*p-doc-line-rec*/
                                /*для всех doc-lin*/  ).
    run process-two-tables in p-parent-handle (X_sj-print.gds-code, X_sj-print.is-out) /*все*/ .
    run openbr in this-procedure ( input yes, input no, input '':U).
    run display-pcnt in this-procedure .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-print Dialog-Frame
ON CHOOSE OF B-print IN FRAME Dialog-Frame /* Печать */
DO:
  if not avail X_sj-print then return no-apply.
  run proc-b-print in this-procedure  no-error.
  if error-status:error then do:
     return no-apply.
  end.
  APPLY "ENTRY" to br-sj.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-sch
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-sch Dialog-Frame
ON CHOOSE OF B-sch IN FRAME Dialog-Frame /* Фильтр */
DO:
  run proc-b-sch in this-procedure no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sel Dialog-Frame
ON CHOOSE OF b-sel IN FRAME Dialog-Frame /* Выбор */
DO:
  if ( available sj-print ) then do:
    if ( p-rid-list = "" ) or b-mark:sensitive = no then
    p-rid-list = string( recid( sj-print ) ) .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME rs-cash
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rs-cash Dialog-Frame
ON VALUE-CHANGED OF rs-cash IN FRAME Dialog-Frame
DO:
  ASSIGN
  rs-cash
  .
  RUN openbr IN THIS-PROCEDURE ( input YES, input NO, input '':U) NO-ERROR.
  IF ERROR-STATUS:ERROR  THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME rs-r-v
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rs-r-v Dialog-Frame
ON VALUE-CHANGED OF rs-r-v IN FRAME Dialog-Frame
DO:
  ASSIGN
  rs-r-v
  .
  RUN openbr IN THIS-PROCEDURE ( input YES, input NO, input '':U) NO-ERROR.
  IF ERROR-STATUS:ERROR  THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME rs-vzak
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rs-vzak Dialog-Frame
ON VALUE-CHANGED OF rs-vzak IN FRAME Dialog-Frame
DO:
  ASSIGN
  rs-vzak
  .
  RUN openbr IN  THIS-PROCEDURE ( input YES, input NO, input '':U) NO-ERROR.
  IF ERROR-STATUS:ERROR  THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-sj
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.
{ gbl/app_help.i }
{ gbl/setfltnm.i }
{ gbl/f2.i br-sj goods-recid get-gds-recid parparentproc }
{ ref/tabhndmv.i v-tab-order underline-tb }
{ gbl/rethndmv.i v-tab-order underline-tb "APPLY 'CHOOSE' TO b-quit in frame {&frame-name}." }

{ gbl/srt-clmd.i
  &browse-name    = "{&browse-name}"
  &frame-name     = "{&frame-name}"
  &table-name     = "{&first-table-in-query-{&browse-name}}"
  &sort-clmn_1    = "X_sj-print.gds-code"
  &sort-clmn_2    = "X_sj-print.artic"
  &sort-clmn_3    = "X_sj-print.gds-name"
  &sort-clmn_4    = "X_sj-print.prod-name"
  &sort-clmn_5    = "X_sj-print.is-cash"
  &sort-clmn_6    = "X_sj-print.sale-sum"
  &open-query     = "run OpenBr in this-procedure ( input yes, input no, input '':U)."
  &open-query-otherwise = "run OpenBr in this-procedure ( input yes, input no, input '':U)."
  &sort-column-name = "sort-column-name"
  &re-move-clmn   = "yes"
  &mv-brw-default = "yes"
}

{ gbl/brwrepos.i
  &line-num=5
}

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  { gbl/curr-r-b.i
    v-curr-r-b
  }

  find first buf_trn-doc no-lock where
            buf_trn-doc.doc-code = buf_inkas.inkas-code.
  RUN MyEnable.
  RUn OpenBR in this-procedure ( input yes, input no, input '':U).
  HIDE mark-num in frame {&frame-name} .
  if p-rid-list <> "":U then
  REPOSITION br-sj to recid integer(entry(1, p-rid-list)) No-ERROR.
  { gbl/mv-clmn.i
    &browse-name = "br-sj"
    &frame-name = "{&frame-name}"
    &ext-col = 12
    &start-column = 1
    &prev-order-column_1 = "'1,2,3,4,5,6,7,8,9,10,11,12'"
    &prev-order-column-condition_1 = " true "
    }
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE display-pcnt Dialog-Frame
PROCEDURE display-pcnt :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DEFINE VARIABLE sale-sum1 AS DECIMAL NO-UNDO.
DEFINE VARIABLE sale-sum2 AS DECIMAL NO-UNDO.
DEFINE VARIABLE sale-sumr AS DECIMAL NO-UNDO.
DEFINE VARIABLE sale-sumv AS DECIMAL NO-UNDO.

DEFINE BUFFER sj-goods00 FOR sj-goods.
DEFINE BUFFER sj-goods01 FOR sj-goods.
DEFINE BUFFER sj-goods02 FOR sj-goods.

  find first sj-goods00 no-lock where
            sj-goods00.gds-code = 0
         AND SJ-GOODS00.IS-OUT  = ?
         and sj-goods00.var-purch = 0 .

  FOR each sj-goods01 no-lock where
            sj-goods01.gds-code = 0
         AND (SJ-GOODS01.IS-OUT  = NO OR SJ-GOODS01.IS-OUt = yes)
         and sj-goods01.var-purch = 1 :
    IF sj-goods01.is-out THEN
    ASSIGN
    fvzakr-1 = sj-goods01.sale-sum
    sale-sumr = sale-sumr + sj-goods01.sale-sum
    .
    IF NOT sj-goods01.is-out
    THEN
    assign
    fvzakv-1 = sj-goods01.sale-sum
    sale-sumv = sale-sumv + sj-goods01.sale-sum
    .
    ASSIGN
    sale-sum1 = sale-sum1 + sj-goods01.sale-sum.
  END.
  FOR each sj-goods02 no-lock where
            sj-goods02.gds-code = 0
         AND (SJ-GOODS02.IS-OUT  = NO OR SJ-GOODS02.IS-OUt = yes)
         and sj-goods02.var-purch = 2 :
    IF sj-goods02.is-out
    THEN
    assign
    fvzakr-2 = sj-goods02.sale-sum
    sale-sumr = sale-sumr + sj-goods02.sale-sum
    .
    IF NOT sj-goods02.is-out
    THEN
    assign
    fvzakv-2 = sj-goods02.sale-sum
    sale-sumv = sale-sumv + sj-goods02.sale-sum.
    .
    ASSIGN
    sale-sum2 = sale-sum2 + sj-goods02.sale-sum.
  END.
  ASSIGN
  fvzakr-1 = fvzakr-1 / sale-sumr * 100
  fvzakr-2 = fvzakr-2 / sale-sumr * 100
  fvzakv-1 = fvzakv-1 / sale-sumv * 100
  fvzakv-2 = fvzakv-2 / sale-sumv * 100
  .
  DISPLAY
  sale-sum1 / sj-goods00.sale-sum * 100 @ fvzak-1
  sale-sum2 / sj-goods00.sale-sum * 100 @ fvzak-2
  fvzakr-1
  fvzakr-2
  fvzakv-1
  fvzakv-2
  WITH FRAME {&FRAME-NAME}.

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
  DISPLAY rs-r-v rs-vzak rs-cash mark-num fvzak-1 fvzakr-1 fvzakv-1 fvzak-2
          fvzakr-2 fvzakv-2
      WITH FRAME Dialog-Frame.
  ENABLE b-quit B-mark b-sel B-parts B-chk B-print B-sch B-Help rs-r-v rs-vzak
         rs-cash BR-sj mark-num fvzak-1 fvzakr-1 fvzakv-1 fvzak-2 fvzakr-2
         fvzakv-2
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-gds-recid Dialog-Frame
PROCEDURE get-gds-recid :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DEFINE BUFFER buf_goods FOR ub.goods.
IF NOT AVAILABLE X_sj-print THEN DO:
    gds-rec = ?.
    RETURN.
END.
FIND FIRST buf_goods NO-LOCK WHERE
        buf_goods.gds-code = X_sj-print.gds-code NO-ERROR.
IF NOT AVAILABLE X_sj-print THEN DO:
    gds-rec = ?.
    RETURN.
END.
gds-rec = RECID(buf_goods).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyENABLE Dialog-Frame
PROCEDURE MyENABLE :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
ASSIGN
FRAME {&frame-name}:TITLE = FRAME {&frame-name}:TITLE + {&space-char} + buf_inkas.inkas-code
v-tab-order = "b-quit,b-mark,b-sel,b-parts,b-chk,b-sch,b-print,b-help,rs-r-v,rs-vzak,rs-cash,br-sh"
rs-r-v = ?
rs-vzak = 0
rs-cash = ?
.

DISPLAY rs-r-v rs-vzak rs-cash mark-num
WITH FRAME {&frame-name}.
ASSIGN
X_sj-print.sale-sum:READ-ONLY in BROWSE br-sj = YES .
  ENABLE
  b-quit
  B-mark WHEN lookup("b-mark", bttns) > 0
  b-sel  WHEN lookup("b-sel", bttns) > 0
  B-sch
  b-chk
  b-parts
  B-print
  B-Help
  rs-r-v
  rs-vzak
  rs-cash
  BR-sj
  mark-num
  WITH FRAME {&frame-name}.
  VIEW FRAME {&frame-name}.
ASSIGN
FRAME {&frame-name}
rs-cash
rs-r-v
rs-vzak
.
RUN DISPLAY-pcnt IN THIS-PROCEDURE NO-ERROR.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Openbr Dialog-Frame
PROCEDURE Openbr :
define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .

define variable l-query-was-opened as logical no-undo .
define variable title0 as character no-undo.
title0 = "Зарезервированные партии продажи по вариантам закупки" + {&space-char}.
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


&scop flt-open-open-query OPEN QUERY br-sj FOR EACH X_sj-print

&scop flt-open-dyn_open-query FOR EACH X_sj-print

&scop flt-open-query-handle QUERY br-sj:handle

&scop flt-open-query-was-opened  l-query-was-opened

&scop flt-open-sort-column-phrase sort-column-phrase

&scop flt-open-call-point filter-point

&scop flt-open-set-filter-name set-filter-name

&scop flt-open-indexed-reposition indexed-reposition

&scop flt-open-query p-open-query

&scop flt-open-table-name X_sj-print

&scop flt-open-search-option no-lock

&scop flt-open-find-next p-find-next

&scop flt-open-find-recid v-doc-rec

&scop flt-open-find-condition p-find-condition

&scop flt-open-find-buffer-name X_sj-print

&scop flt-open-open-query-tail


&scop flt-open-debug-file

&scop flt-open-waitfram yes

define variable l-open-query as logical   no-undo .


     assign
     filter-point = filter-point0
     frame {&frame-name}:TITLE = title0 + {&space-char} + buf_inkas.inkas-code
     filter-label = substitute("&1", filter-label0)
     .
  case rs-r-v:
    when ? then do:
      case rs-cash:
        when ? then do:
        { gbl/fltopend.i
          &where-cond = " (rs-vzak = 0 or X_sj-print.var-purch = rs-vzak) "
          &dyn_where-cond = " substitute('(&1 = 0 or X_sj-print.var-purch = &1) ', rs-vzak)"
          &use-ind    = "  "
          &by         = "  "
          }

        end.
        otherwise do:
        { gbl/fltopend.i
          &where-cond = " (rs-vzak = 0 or X_sj-print.var-purch = rs-vzak) AND ~
                          X_sj-print.is-cash = rs-cash "
          &dyn_where-cond = " substitute('(&1 = 0 or X_sj-print.var-purch = &1) AND ~
                                X_sj-print.is-cash = &2', rs-vzak, rs-cash)"

          &use-ind    = "  "
          &by         = "  "
          }
        end.
      end case.
    end.
    otherwise do:
      case rs-cash:
        when ? then do:
        { gbl/fltopend.i
          &where-cond = " X_sj-print.is-out  = rs-r-v AND ~
                          (rs-vzak = 0 or X_sj-print.var-purch = rs-vzak) "
          &dyn_where-cond = " substitute('X_sj-print.is-out  = &1 AND ~
                          (&2 = 0 or X_sj-print.var-purch = &2)', rs-r-v, rs-vzak)"

          &use-ind    = "  "
          &by         = "  "
          }

        end.
        otherwise do:
          { gbl/fltopend.i
            &where-cond = " X_sj-print.is-out  = rs-r-v AND ~
                            (rs-vzak = 0 or X_sj-print.var-purch = rs-vzak) AND ~
                            X_sj-print.is-cash = rs-cash "
            &dyn_where-cond = " substitute('X_sj-print.is-out  = &1 AND ~
                            (&2 = 0 or X_sj-print.var-purch = &2) AND ~
                            X_sj-print.is-cash = &3 ', rs-r-v, rs-vzak, rs-cash)"
            &use-ind    = "  "
            &by         = "  "
            }
        end.
      end case.
    end.
  end case.

if not p-open-query and v-doc-rec <> ? then
REPOSITION br-sj to recid v-doc-rec No-ERROR.
if not p-open-query and v-fltopend-rowid[1] <> ? then
query br-sj:handle:reposition-to-rowid(v-fltopend-rowid) No-ERROR.
run waitfram-hide in this-procedure .
APPLY "VALUE-CHANGED" TO br-sj in frame {&frame-name}.
APPLY "ENTRY" TO br-sj.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-print Dialog-Frame
PROCEDURE proc-b-print :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable v-r-b-abbr as character no-undo .
define variable date_string as character no-undo.
define variable v-header-base-curr as character no-undo .
DEFINE VARIABLE Line                as character                    no-undo .

&scop underline-FRAME ~
  UNDERLINE stream PrnLibStream  ~
  X_sj-print.gds-code              ~
  X_sj-print.artic                 ~
  X_sj-print.gds-name              ~
  X_sj-print.prod-name             ~
  X_sj-print.var-purch             ~
  v-supp                         ~
  v-supp-name                    ~
  X_sj-print.price-sale            ~
  X_sj-print.qnty                  ~
  X_sj-print.sale-sum              ~
  with frame Purch-Frame


DEFINE VARIABLE var-sale-sum AS DECIMAL NO-UNDO.
DEFINE VARIABLE var-qnty AS DECIMAL NO-UNDO.
DEFINE FRAME Purch-frame
X_sj-print.gds-code     column-label "Код товара"
X_sj-print.gds-name     column-label "Название товара" format "X(30)"
X_sj-print.var-purch    column-label "Вар!закуп"   format "9"
X_sj-print.price-sale   column-label "Цена нетто"
X_sj-print.price-flag   column-label "При-!веден"            format "+/"
X_sj-print.is-cash      column-label "Нал"                format "+/"
X_sj-print.qnty         column-label "Количество"
X_sj-print.sale-sum     column-label "Сумма нетто"
X_sj-print.artic        column-label "Артикул"
X_sj-print.prod-name    column-label "Производитель"   format "X(30)"
v-supp                column-label "Поставщик"       format "X(12)"
v-supp-name           column-label "Поставщик-название" format "X(30)"
HEADER  date_string AT 5 format "X(35)"
v-header-base-curr        format "X(20)" AT 42
string( "Страница " ) format "X(9)" AT 115 PAGE-NUMBER(PrnLibStream) AT 125 FORMAT ">>9" SKIP
Line format "X(177)" AT 1
with width {&DOS_CW_2} down stream-io use-text    .

  { gbl/r-b-abbr.i
   buf_inkas.host-code
   v-r-b-abbr }


  date_string = cur-time-print() .
  if v-curr-r-b = {&r-b-base} then do:
    assign
    v-header-base-curr = string( "( Б.Вал. - " + caps( v-r-b-abbr ) + " )" )
    .
  end.
  run prn-lib-open-stream  in this-procedure (
                                              input parParentProc
                                              ,input {&LS_PS_A4}
                                              ,input yes /*p-is-stream*/
                                              ,input no /*p-append*/
                                              ).
  PUT  STREAM PrnLibStream
  SPACE(25) ( substitute("Отчет по зарезервированным партиям продажи &1 по вариантам закупки", buf_inkas.inkas-code) )
  format "x(90)" SKIP(2) .
  PUT  STREAM PrnLibStream unformatted
  SPACE(25) (IF rs-r-v  THEN "РАСХОД" ELSE (IF rs-r-v =  no THEN "ВОЗВРАТ" ELSE "РАСХОД+ВОЗВРАТ"))
  SPACE(25) (IF rs-vzak = 1 THEN "Вариант закупки 1" ELSE (IF rs-vzak = 1 THEN "Вариант закупки 2" ELSE "Все варианты закупки")) SKIP(0)
  SPACE(25) (IF rs-cash THEN "НАЛИЧНЫЕ" ELSE (IF rs-cash = NO THEN "БЕЗНАЛИЧНЫЕ" ELSE "НАЛИЧНЫЕ+БЕЗНАЛИЧНЫЕ")) SKIP(0)
 .

  Line = fill("-", integer(frame Purch-frame:width-chars)).
  FORM HEADER
  string(Line, "X(" + string(frame Purch-frame:width-chars) + ")") AT 1 SKIP
  "Продолжение - на следующей странице" AT 30 SKIP
  with FRAME BottomFrame width {&DOS_CW_2} PAGE-BOTTOM NO-LABELS NO-BOX .
  VIEW  STREAM PrnLibStream FRAME BottomFrame .

  FORM with FRAME Purch-frame .

  run waitfram-show in this-procedure ("Ждите...").

  v-doc-rec = recid(X_sj-print).
DO WHILE available X_sj-print :
  GET prev br-sj.
END.
GET next br-sj.
DO WHILE available X_sj-print :

    Display STREAM PrnLibStream
    X_sj-print.gds-code
    X_sj-print.artic
    X_sj-print.gds-name
    X_sj-print.prod-name
    X_sj-print.var-purch
    (X_sj-print.supp-type + string(X_sj-print.supp-code)) @ v-supp
    get-supp-name(BUFFER X_sj-print) @ v-supp-name
    (if X_sj-print.price-flag
    then X_sj-print.price-sale
    else X_sj-print.sale-sum / X_sj-print.qnty) @ X_sj-print.price-sale
    (X_sj-print.price-flag = no) @ X_sj-print.price-flag
    X_sj-print.is-cash
    X_sj-print.qnty
    X_sj-print.sale-sum
    with FRAME Purch-Frame .
    DOWN STREAM PrnLibStream 1 with FRAME Purch-Frame.
    assign
    var-sale-sum = var-sale-sum + X_sj-print.sale-sum
    var-qnty = var-qnty + X_sj-print.qnty
    .
    GET next br-sj.
  END.
  {&underline-FRAME}.
  display stream PrnLibStream
  "ИТОГО ПО ВСЕМ" @ X_sj-print.gds-name
  var-qnty @ X_sj-print.qnty
  var-sale-sum @ X_sj-print.sale-sum
  with frame Purch-Frame.
  DOWN STREAM PrnLibStream 1 with FRAME Purch-Frame.
  {&underline-FRAME}.
HIDE  STREAM PrnLibStream FRAME BottomFrame .
output  STREAM PrnLibStream CLOSE.
run waitfram-hide in this-procedure .
REPOSITION br-sj to recid v-doc-rec no-error.
APPLY "entry" to br-sj in frame {&frame-name} .
run prn-lib-prn-file in this-procedure (
                                          input parParentProc
                                          ,input 8
                                          ).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-sch Dialog-Frame
PROCEDURE proc-b-sch :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/

assign
  tbl = 'parts'
  join-tbl = 'X_sj-print'
  fld = ""
  lab = ""
  spr = ""
  dim = '0'
  .
run fltfield-add in this-procedure('gds-code', 'Код товара', 'function_integer',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('artic', 'Артикул', 'function_character',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('prod-type{&delim-flt}prod-code', 'Производитель', 'cli',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('supp-type{&delim-flt}supp-code', 'Поставщик', 'cli',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.

run fltfield-add in this-procedure('gds-name', 'Название товара', 'function_character',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('prod-name', 'Название производителя', 'function_character',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('qnty', 'Количество', 'function_decimal',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('sale-sum', 'Сумма', 'function_decimal',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('price-sale', 'Цена', 'function_decimal',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('var-purch', 'Вариант закупки', 'function_integer',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('is-cash', 'Наличные', 'function_logical',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('is-out', 'Расход?', 'function_logical',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.

Filter-Block:
DO ON STOP    UNDO Filter-Block, LEAVE Filter-Block
    ON ERROR   UNDO Filter-Block, LEAVE Filter-Block
    ON END-KEY UNDO Filter-Block, LEAVE Filter-Block :
  run gbl/filter.w ( INPUT parparentproc
                   , INPUT (filter-point + {&delim-par} + filter-label)
                   , INPUT tbl
                   , INPUT join-tbl
                   , INPUT fld
                   , INPUT lab
                   , INPUT spr
                   , INPUT dim ).
  RUN OpenBr in this-procedure ( input yes, input no, input '':U).
END. /* Filter-Block */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-check-tovar Dialog-Frame
PROCEDURE proc-check-tovar :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DEFINE INPUT PARAMETER p-is-out AS LOGICAL NO-UNDO.
DEFINE INPUT PARAMETER p-gds-code LIKE UB.GOODS.GDS-CODE NO-UNDO.
DEFINE VARIABLE rid-list as character no-undo .
DEFINE BUFFER buf_GOODS FOR ub.GOODS.
find FIRST buf_goods NO-LOCK WHERE buf_goods.gds-code = p-gds-code .

 run ref/gds-chks.w (
                 input parparentproc
                ,input RECID(buf_GOODS)
                ,input "":U /*bttns*/
                ,input {&sale}
                ,input ? /*pardoc-rec*/
                ,input buf_inkas.obj-type
                ,input buf_inkas.obj-code
                ,input buf_inkas.inkas-code
                ,input "":U /*d-card*/
                ,output rid-list
                 ).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-supp-name Dialog-Frame
FUNCTION get-supp-name RETURNS CHARACTER
  ( BUFFER buf_sj-print FOR sj-print ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/
DEFINE BUFFER buf_clients FOR ub.clients.
    find first buf_clients no-lock where
              buf_clients.obj-type = buf_sj-print.supp-type
          AND buf_clients.obj-code = buf_sj-print.supp-code no-error .
IF NOT AVAILABLE buf_clients THEN
RETURN "Неизвестен".   /* Function return value. */
RETURN buf_clients.obj-name.

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME