&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v9r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE NEW SHARED BUFFER buf_matrix FOR ub.assortment-matrix.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Список ассортиментных матриц

Автор: Чернова Светлана Александровна
Дата создания: 03/23/05
Author: Svetlana Chernova
Creation date: 03/23/05


*/

/*------------------------------------------------------------------------*/
/*          This .W file was created with the Progress AppBuilder.       */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */
/* Parameters Definitions ---                                           */
define input parameter parParentProc AS WIDGET-HANDLE NO-UNDO.
define input parameter bttns             as character   no-undo . /*кнопки для нажатия*/
define input parameter p-curr-obj-type   like ub.clients.obj-type no-undo .
define input parameter p-curr-obj-code   like ub.clients.obj-code no-undo .
define input parameter p-mode            as character   no-undo .
define input parameter p-sts             as integer   no-undo .
define input-output param p-rid-list     as character no-undo .


/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Список ассортиментных матриц".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/showinf.i  }
{ cmp/r-pril.i new }
{ gbl/waitfram.i }
{ gbl/prn-lib.i  }
{ gbl/cur-time.i }
{ gbl/color.i    }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
{ gbl/fltopend.i defproc }
{ cmp/mrk-strf.i }
{ gbl/assmatat.i }

define variable mark-str  AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-doc-rec AS RECID NO-UNDO.
define variable filter-point as character no-undo init "Список Асортиментных матриц" .
define variable filter-point0 as character no-undo init "Асортиментные_матрицы" .
define variable sort-column-name as character no-undo .
define variable v-db-num LIKE ub.db.db-num no-undo.
define variable v-type as character no-undo .
define variable p-mark     as character no-undo .
define variable p-shablon     as character no-undo .

define variable p-obj      as character no-undo .
define variable p-time-upd as character no-undo .
define variable p-time-cr  as character no-undo .
define variable p-status   as character no-undo .
define variable v-type-s as character no-undo .
define variable v-type-o as character no-undo .
define variable p-asmt-type  as character no-undo .


&SCOPED-DEFINE status-code STRING(buf_Matrix.asmt-status)
&scop cop-l1       mark-string(recid( buf_Matrix) , p-rid-list)
&scop dyn_cop-l1   substitute('dynamic-function(&1mark-string&1, recid(buf_Matrix), &1&2&1)', ~{&double-quote~}, p-rid-list)
&scop cop-l2       buf_Matrix.asmt-name
&scop cop-l3       buf_Matrix.asmt-type
&scop cop-l4       buf_Matrix.obj-type + ' ' + string(buf_Matrix.obj-code,'>>>>>>>>>')
&scop cop-l5       buf_Matrix.asmt-date-update
&scop cop-l6       STRING (buf_Matrix.asmt-time-update,'HH:MM')
&scop cop-l7       buf_Matrix.asmt-who-update
&scop cop-l8       buf_Matrix.asmt-db-num-update
&scop cop-l9       buf_Matrix.asmt-date-create
&scop cop-l10      STRING (buf_Matrix.asmt-time-create,'HH:MM')
&scop cop-l11      buf_Matrix.asmt-who-create
&scop cop-l12      buf_Matrix.asmt-db-num-create
&scop cop-l13      {&status-int-name}
&scop cop-l14       attrRootShablon(recid(buf_Matrix))
&scop dyn_cop-l14   substitute('dynamic-function(&1attrRootShablon&1, recid(buf_Matrix))', ~{&double-quote~})


&scop col-l1       '*'
&scop col-l2       'Название'
&scop col-l3       'Тип'
&scop col-l4       'Объект'
&scop col-l5       'Дата!изменения'
&scop col-l6       'Время'
&scop col-l7       'Кто!изменил'
&scop col-l8       'БД!изм'
&scop col-l9       'Дата!создания'
&scop col-l10      'Время'
&scop col-l11      'Кто!создал'
&scop col-l12      'БД!соз'
&scop col-l13      'Статус'
&scop col-l14      'Связка с!шаблоном'


define buffer pos_assortment-matrix for ub.assortment-matrix.

&scop cant-positioning   if error-status:error then do: ~
                          find first pos_assortment-matrix no-lock where ~
                                  recid(pos_assortment-matrix) = loc-doc-rec no-error . ~
                            message ~
                            "Невозможно позиционироваться на записи AM" skip~
                            string(if avail pos_assortment-matrix ~
                                    then  substitute("Вн код AM: &1" ~
                                                    , pos_assortment-matrix.asmt-id) ~
                                    else "":U) skip ~
                            "Запись была добавлена (или изменена или удалена) -" skip ~
                            "и теперь не попадает в текущую выборку" ~
                            view-as alert-box WARNING. ~
                          end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BROWSE-AM

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES buf_matrix

/* Definitions for BROWSE BROWSE-AM                                     */
&Scoped-define FIELDS-IN-QUERY-BROWSE-AM ~
mark-string(recid( buf_Matrix ), p-rid-list) @ p-mark buf_matrix.asmt-name ~
buf_matrix.asmt-type + shablon-type (recid ( buf_Matrix )) @ p-asmt-type ~
IF (buf_Matrix.obj-code <> 0 ) THEN (buf_Matrix.obj-type + ' ' + string(buf_Matrix.obj-code)) ELSE ("")  @ p-obj ~
{&status-int-name} @ p-status buf_matrix.asmt-date-update ~
STRING (buf_Matrix.asmt-time-update,"HH:MM") @ p-time-upd ~
buf_matrix.asmt-db-num-update buf_matrix.asmt-date-create ~
STRING (buf_Matrix.asmt-time-create,"HH:MM") @ p-time-cr ~
attrRootShablon ( recid ( buf_Matrix ) ) @ p-shablon ~
buf_matrix.asmt-db-num-create
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-AM buf_matrix.asmt-name
&Scoped-define ENABLED-TABLES-IN-QUERY-BROWSE-AM buf_matrix
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-BROWSE-AM buf_matrix
&Scoped-define QUERY-STRING-BROWSE-AM FOR EACH buf_matrix NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-BROWSE-AM OPEN QUERY BROWSE-AM FOR EACH buf_matrix NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-BROWSE-AM buf_matrix
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-AM buf_matrix


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define BUFFER-FIELDS-IN-QUERY-Dialog-Frame buf_matrix.asmt-des ~

&Scoped-define ENABLED-BUFFER-FIELDS-IN-QUERY-Dialog-Frame buf_matrix.asmt-des ~

&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BROWSE-AM}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS ub.buf_matrix.asmt-des
&Scoped-define ENABLED-TABLES ub.buf_matrix
&Scoped-define FIRST-ENABLED-TABLE ub.buf_matrix
&Scoped-Define ENABLED-OBJECTS b-quit I-link B-mark B-sel B-add B-lookup ~
B-chg B-del B-Help B-mark-all B-demark-all B-goods B-print RS-sts B-hist ~
RS-type RS-object BROWSE-AM mark-num FILL-IN-1 FILL-IN-2 v-text_object-bd ~
v-user-name-create name-link v-user-name-corr
&Scoped-Define DISPLAYED-FIELDS ub.buf_matrix.asmt-des
&Scoped-define DISPLAYED-TABLES ub.buf_matrix
&Scoped-define FIRST-DISPLAYED-TABLE ub.buf_matrix
&Scoped-Define DISPLAYED-OBJECTS RS-sts RS-type RS-object mark-num ~
FILL-IN-1 FILL-IN-2 v-text_object-bd v-user-name-create name-link ~
v-user-name-corr

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD attrRootShablon Dialog-Frame
FUNCTION attrRootShablon RETURNS CHARACTER
  ( p-recid as recid )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD f-name-link Dialog-Frame
FUNCTION f-name-link RETURNS CHARACTER
  ( p-recid as recid )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD shablon-type Dialog-Frame
FUNCTION shablon-type RETURNS CHARACTER
  ( p-recid as recid )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-add
     LABEL "&Добавить"
     SIZE 10 BY 1.

DEFINE BUTTON B-chg
     LABEL "&Изменить"
     SIZE 10 BY 1 TOOLTIP "Изменить название матрицы".

DEFINE BUTTON B-del
     LABEL "&Удалить"
     SIZE 10 BY 1.

DEFINE BUTTON B-demark-all
     LABEL "-"
     SIZE 3 BY 1 TOOLTIP "Снять все отметки".

DEFINE BUTTON B-goods AUTO-GO
     LABEL "&Товары"
     SIZE 10 BY 1 TOOLTIP "Состав матрицы".

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-hist
     LABEL "Ис&тория"
     SIZE 10 BY 1.

DEFINE BUTTON B-lookup
     LABEL "&Просмотр"
     SIZE 10 BY 1.

DEFINE BUTTON B-mark
     LABEL "&*"
     SIZE 3 BY 1 TOOLTIP "Отметить".

DEFINE BUTTON B-mark-all
     LABEL "&+"
     SIZE 3 BY 1 TOOLTIP "Отметить все".

DEFINE BUTTON B-print
     LABEL "Пе&чать"
     SIZE 10 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-sel AUTO-GO
     LABEL "Вы&бор"
     SIZE 10 BY 1.

DEFINE VARIABLE FILL-IN-1 AS CHARACTER FORMAT "X(256)":U INITIAL "Статус:"
      VIEW-AS TEXT
     SIZE 7.5 BY 1 NO-UNDO.

DEFINE VARIABLE FILL-IN-2 AS CHARACTER FORMAT "X(256)":U INITIAL "Тип:"
      VIEW-AS TEXT
     SIZE 4.5 BY 1 NO-UNDO.

DEFINE VARIABLE mark-num AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 3 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE name-link AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 32 BY 1.25 TOOLTIP "Привязан к Шаблону"
     BGCOLOR 8 FGCOLOR 1  NO-UNDO.

DEFINE VARIABLE v-text_object-bd AS CHARACTER FORMAT "X(256)":U INITIAL "ОбъектыБД:"
      VIEW-AS TEXT
     SIZE 10 BY 1 NO-UNDO.

DEFINE VARIABLE v-user-name-corr AS CHARACTER FORMAT "X(256)":U
     LABEL "Изменил"
      VIEW-AS TEXT
     SIZE 15 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE v-user-name-create AS CHARACTER FORMAT "X(256)":U
     LABEL "Создал"
      VIEW-AS TEXT
     SIZE 15 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE IMAGE I-link
     FILENAME "cmp/link.bmp":U
     SIZE 4.5 BY 1.25 TOOLTIP "Привязан к Шаблону".

DEFINE VARIABLE RS-object AS CHARACTER
     VIEW-AS RADIO-SET HORIZONTAL EXPAND
     RADIO-BUTTONS
          "Item 1", "1",
"Item 2", "2"
     SIZE 22.5 BY 1 NO-UNDO.

DEFINE VARIABLE RS-sts AS CHARACTER
     VIEW-AS RADIO-SET HORIZONTAL EXPAND
     RADIO-BUTTONS
          "Item 1", "1",
"Item 2", "2",
"Item 3", "3"
     SIZE 33.5 BY 1 NO-UNDO.

DEFINE VARIABLE RS-type AS CHARACTER
     VIEW-AS RADIO-SET HORIZONTAL EXPAND
     RADIO-BUTTONS
          "Item 1", "1",
"Item 2", "2",
"Item 3", "3"
     SIZE 33.5 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BROWSE-AM FOR
      buf_matrix SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BROWSE-AM
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-AM Dialog-Frame _STRUCTURED
  QUERY BROWSE-AM NO-LOCK DISPLAY
      mark-string(recid( buf_Matrix ), p-rid-list) @ p-mark COLUMN-LABEL "*" FORMAT "x(1)":U
      buf_matrix.asmt-name COLUMN-LABEL "Название" FORMAT "X(20)":U
      buf_matrix.asmt-type + shablon-type (recid ( buf_Matrix )) @ p-asmt-type COLUMN-LABEL "Тип" FORMAT "X(7)":U
      IF (buf_Matrix.obj-code <> 0 ) THEN (buf_Matrix.obj-type + ' ' + string(buf_Matrix.obj-code)) ELSE ("")  @ p-obj COLUMN-LABEL "Объект" FORMAT "x(11)":U
      {&status-int-name} @ p-status COLUMN-LABEL "Статус" FORMAT "x(6)":U
      buf_matrix.asmt-date-update COLUMN-LABEL "Дата!изменения" FORMAT "99/99/99":U
      STRING (buf_Matrix.asmt-time-update,"HH:MM") @ p-time-upd COLUMN-LABEL "Время" FORMAT "x(5)":U
      buf_matrix.asmt-db-num-update COLUMN-LABEL "БД!изм" FORMAT ">>>>9":U
      buf_matrix.asmt-date-create COLUMN-LABEL "Дата!создания" FORMAT "99/99/99":U
      STRING (buf_Matrix.asmt-time-create,"HH:MM") @ p-time-cr COLUMN-LABEL "Время" FORMAT "x(5)":U
      attrRootShablon ( recid ( buf_Matrix ) ) @ p-shablon COLUMN-LABEL "Связка с!шаблоном"
      buf_matrix.asmt-db-num-create COLUMN-LABEL "БД!соз" FORMAT ">>>>9":U
  ENABLE
      buf_matrix.asmt-name
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 96 BY 11.75 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-mark AT ROW 1 COL 11
     B-sel AT ROW 1 COL 17.5
     B-add AT ROW 1 COL 27.5
     B-lookup AT ROW 1 COL 37.5
     B-chg AT ROW 1 COL 47.5
     B-del AT ROW 1 COL 57.5
     B-Help AT ROW 1 COL 87.5
     B-mark-all AT ROW 2 COL 11.13 WIDGET-ID 6
     B-demark-all AT ROW 2 COL 14.25 WIDGET-ID 8
     B-goods AT ROW 2 COL 17.5
     B-print AT ROW 2 COL 87.5
     RS-sts AT ROW 3 COL 11.5 NO-LABEL
     B-hist AT ROW 3 COL 87.5
     RS-type AT ROW 4 COL 11.5 NO-LABEL
     RS-object AT ROW 5 COL 11.5 NO-LABEL
     BROWSE-AM AT ROW 6.08 COL 1.5
     ub.buf_matrix.asmt-des AT ROW 19.42 COL 1.5 NO-LABEL
          VIEW-AS EDITOR SCROLLBAR-VERTICAL
          SIZE 94 BY 2.5
     mark-num AT ROW 1 COL 12 COLON-ALIGNED NO-LABEL
     FILL-IN-1 AT ROW 3 COL 3.5 NO-LABEL
     FILL-IN-2 AT ROW 4 COL 6.5 NO-LABEL
     v-text_object-bd AT ROW 5 COL 1 NO-LABEL
     v-user-name-create AT ROW 17.96 COL 9.5 COLON-ALIGNED WIDGET-ID 2
     name-link AT ROW 18 COL 30.5 COLON-ALIGNED NO-LABEL WIDGET-ID 12
     v-user-name-corr AT ROW 18.75 COL 9.5 COLON-ALIGNED WIDGET-ID 4
     I-link AT ROW 18 COL 28.5 WIDGET-ID 10
     SPACE(64.74) SKIP(2.91)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Список Ассортиментных матриц".


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: buf_matrix B "NEW SHARED" ? ub assortment-matrix
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BROWSE-AM RS-object Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN
       buf_matrix.asmt-name:COLUMN-READ-ONLY IN BROWSE BROWSE-AM = TRUE.

/* SETTINGS FOR FILL-IN FILL-IN-1 IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN FILL-IN-2 IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN v-text_object-bd IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-AM
/* Query rebuild information for BROWSE BROWSE-AM
     _TblList          = "buf_matrix"
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _FldNameList[1]   > "_<CALC>"
"mark-string(recid( buf_Matrix ), p-rid-list) @ p-mark" "*" "x(1)" ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[2]   > Temp-Tables.buf_matrix.asmt-name
"asmt-name" "Название" "X(20)" "character" ? ? ? ? ? ? yes ? no no ? yes no yes "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[3]   > "_<CALC>"
"buf_matrix.asmt-type + shablon-type (recid ( buf_Matrix )) @ p-asmt-type" "Тип" "X(7)" ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[4]   > "_<CALC>"
"IF (buf_Matrix.obj-code <> 0 ) THEN (buf_Matrix.obj-type + ' ' + string(buf_Matrix.obj-code)) ELSE ("""")  @ p-obj" "Объект" "x(11)" ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[5]   > "_<CALC>"
"{&status-int-name} @ p-status" "Статус" "x(6)" ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[6]   > Temp-Tables.buf_matrix.asmt-date-update
"asmt-date-update" "Дата!изменения" ? "date" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[7]   > "_<CALC>"
"STRING (buf_Matrix.asmt-time-update,""HH:MM"") @ p-time-upd" "Время" "x(5)" ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[8]   > Temp-Tables.buf_matrix.asmt-db-num-update
"asmt-db-num-update" "БД!изм" ? "integer" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[9]   > Temp-Tables.buf_matrix.asmt-date-create
"asmt-date-create" "Дата!создания" ? "date" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[10]   > "_<CALC>"
"STRING (buf_Matrix.asmt-time-create,""HH:MM"") @ p-time-cr" "Время" "x(5)" ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[11]   > "_<CALC>"
"attrRootShablon ( recid ( buf_Matrix ) ) @ p-shablon" "Связка с!шаблоном" ? ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[12]   > Temp-Tables.buf_matrix.asmt-db-num-create
"asmt-db-num-create" "БД!соз" ? "integer" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _Query            is OPENED
*/  /* BROWSE BROWSE-AM */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Список Ассортиментных матриц */
OR ENDKEY OF FRAME Dialog-Frame DO:
    run gbl/markqwa.p
    (    input b-mark:sensitive
       , input p-rid-list) no-error.
    if error-status:error then return no-apply.
    else p-rid-list = "" .
    APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-add Dialog-Frame
ON CHOOSE OF B-add IN FRAME Dialog-Frame /* Добавить */
DO:
  define variable loc#log as logical no-undo.
  define variable loc-doc-rec as recid no-undo .

/* Проверка прав */
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_assort-matr_add-def':U
    {&cntxt-global}
    v-cntxt-host-code-obj
    v-cntxt-obj-type
    v-cntxt-obj-code
    0
    0
    0
    true
    loc#log
  }
  if loc#log <> yes then do: return no-apply. end.
  run ref/assmatri.w
                (
                   input parParentProc
                  ,input p-curr-obj-type
                  ,input p-curr-obj-code
                  ,input {&add-def}
                  ,input 0
                  ,input-output loc-doc-rec
                              ) no-error
  .
  if loc-doc-rec <> ? THEN DO:
      run OpenBR in this-procedure .
      reposition {&BROWSE-NAME} to recid loc-doc-rec no-error.
      {&cant-positioning}
  END.

  apply "entry" to {&BROWSE-NAME} in frame {&frame-name}.
  apply "value-changed" to {&BROWSE-NAME} in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-chg Dialog-Frame
ON CHOOSE OF B-chg IN FRAME Dialog-Frame /* Изменить */
DO:
define variable loc#log as logical no-undo.
define variable loc-doc-rec as recid no-undo .
if not available {&first-TABLE-IN-QUERY-{&BROWSE-NAME}} then return no-apply.

if  {&first-TABLE-IN-QUERY-{&BROWSE-NAME}}.asmt-status = 1  then do:
    message "Корректировать можно только запись в статусе  ТЕК."
    view-as alert-box information .
    return no-apply.
end.
assign
loc-doc-rec = recid({&FIRST-TABLE-IN-QUERY-{&BROWSE-NAME}}).

 /* Проверка прав */
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_assort-matr_update':U
    {&cntxt-global}
    v-cntxt-host-code-obj
    v-cntxt-obj-type
    v-cntxt-obj-code
    0
    0
    0
    true
    loc#log
  }
   if loc#log <> yes then do: return no-apply. end.

if {&FIRST-TABLE-IN-QUERY-{&BROWSE-NAME}}.asmt-type = {&type-assmatr-shablon} then do:
if v-cntxt-db-num <> 0 and  v-cntxt-db-num <> {&FIRST-TABLE-IN-QUERY-{&BROWSE-NAME}}.asmt-db-num-create then do:
   message
    "Нельзя редактировать ШАБЛОН Ассортиментная матрица созданный в чужой УБД"
    view-as alert-box error.
    return  no-apply.
end.

end.
else do:
define variable obj-db-num as integer   no-undo .
  { gbl/objdbnum.i
  {&FIRST-TABLE-IN-QUERY-{&BROWSE-NAME}}.obj-type
  {&FIRST-TABLE-IN-QUERY-{&BROWSE-NAME}}.obj-code
   obj-db-num
    }

if v-cntxt-db-num <> 0 and  v-cntxt-db-num <> obj-db-num  then do:
   message
    "Нельзя редактировать запись Ассортиментная матрица чужой УБД"
    view-as alert-box error.
    return  no-apply.
end.

end.


   run ref/assmatri.w
                 (
                    input parParentProc
                   ,input p-curr-obj-type
                   ,input p-curr-obj-code
                   ,input {&update}
                   ,input {&FIRST-TABLE-IN-QUERY-{&BROWSE-NAME}}.asmt-id
                   ,input-output loc-doc-rec
                               ) no-error
   .
   if loc-doc-rec <> ? THEN DO:
       run OpenBR in this-procedure .
       reposition {&BROWSE-NAME} to recid loc-doc-rec no-error.
       {&cant-positioning}
   END.

   apply "entry" to {&BROWSE-NAME} in frame {&frame-name}.
   apply "value-changed" to {&BROWSE-NAME} in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-del Dialog-Frame
ON CHOOSE OF B-del IN FRAME Dialog-Frame /* Удалить */
DO:
if not available buf_matrix then return no-apply.
if {&FIRST-TABLE-IN-QUERY-{&BROWSE-NAME}}.asmt-type = {&type-assmatr-shablon} then do:
if v-cntxt-db-num <> 0 and  v-cntxt-db-num <> {&FIRST-TABLE-IN-QUERY-{&BROWSE-NAME}}.asmt-db-num-create then do:
   message
    "Нельзя удалять ШАБЛОН Ассортиментная матрица созданный в чужой УБД"
    view-as alert-box error.
    return  no-apply.
end.

end.
else do:
define variable obj-db-num as integer   no-undo .
  { gbl/objdbnum.i
  {&FIRST-TABLE-IN-QUERY-{&BROWSE-NAME}}.obj-type
  {&FIRST-TABLE-IN-QUERY-{&BROWSE-NAME}}.obj-code
   obj-db-num
    }

if v-cntxt-db-num <> 0 and  v-cntxt-db-num <> obj-db-num  then do:
   message
    "Нельзя удалять запись Ассортиментная матрица чужой УБД"
    view-as alert-box error.
    return  no-apply.
end.

end.

run proc-b-del in this-procedure no-error.
if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-demark-all
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-demark-all Dialog-Frame
ON ALT-- OF B-demark-all IN FRAME Dialog-Frame /* - */
DO:
  apply "CHOOSE":U to b-demark-all in frame {&frame-name} .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-demark-all Dialog-Frame
ON CHOOSE OF B-demark-all IN FRAME Dialog-Frame /* - */
DO:
  p-rid-list = "".
  run OpenBR in this-procedure .
  apply "entry" to {&BROWSE-NAME} in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-goods
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-goods Dialog-Frame
ON CHOOSE OF B-goods IN FRAME Dialog-Frame /* Товары */
DO:
if not available buf_matrix then return no-apply.
define variable loc#log as logical   no-undo .
define variable loc-doc-rec as recid no-undo .

/* Проверка прав */
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_assort-matr-gds_lookup':U
    {&cntxt-global}
    v-cntxt-host-code-obj
    v-cntxt-obj-type
    v-cntxt-obj-code
    0
    0
    0
    true
    loc#log
  }
  if loc#log <> yes then do: return no-apply. end.

 loc-doc-rec = recid({&FIRST-TABLE-IN-QUERY-{&BROWSE-NAME}}).

  /* Если статус матрицы не 0 (тек) - вызываем в режиме no-button */
  run ref/gds-matr.w ( parParentProc ,
                   buf_matrix.asmt-id ,
                   buf_matrix.db-num  ,
                   p-curr-obj-type   ,
                   p-curr-obj-code ,
                   (IF buf_matrix.asmt-status = 0 THEN "all" ELSE "no-button")
                   ) NO-ERROR.
if error-status :error  then do:
  message error-status :get-message(1) return-value .
  return no-apply.
end.

  run OpenBR in this-procedure .
  reposition {&BROWSE-NAME} to recid loc-doc-rec no-error.
  {&cant-positioning}

  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-hist
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-hist Dialog-Frame
ON CHOOSE OF B-hist IN FRAME Dialog-Frame /* История */
DO:
  define variable pp-rid-list as character no-undo .
if not available buf_matrix then return no-apply.
 run str/cassmatr.w (
  input  parparentproc ,
  input  buf_Matrix.asmt-id ,
  input  buf_Matrix.db-num ,
  input-output pp-rid-list    ).

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-lookup
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-lookup Dialog-Frame
ON CHOOSE OF B-lookup IN FRAME Dialog-Frame /* Просмотр */
DO:
define variable loc#log as logical no-undo.
define variable loc-doc-rec as recid no-undo .
if not available {&FIRST-TABLE-IN-QUERY-{&BROWSE-NAME}} then return no-apply.

assign
loc-doc-rec = recid({&FIRST-TABLE-IN-QUERY-{&BROWSE-NAME}}).

 /* Проверка прав */
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_assort-matr_lookup':U
    {&cntxt-global}
    v-cntxt-host-code-obj
    v-cntxt-obj-type
    v-cntxt-obj-code
    0
    0
    0
    true
    loc#log
  }
   if loc#log <> yes then do: return no-apply. end.
   run ref/assmatri.w
                 (
                    input parParentProc
                   ,input p-curr-obj-type
                   ,input p-curr-obj-code
                   ,input {&LOOKUP}
                   ,input {&FIRST-TABLE-IN-QUERY-{&BROWSE-NAME}}.asmt-id
                   ,input-output loc-doc-rec
                   ) no-error   .
   apply "entry" to {&BROWSE-NAME} in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mark Dialog-Frame
ON CHOOSE OF B-mark IN FRAME Dialog-Frame /* * */
DO:
  define variable loc#log as logical no-undo .
  if AVAILABLE {&FIRST-TABLE-IN-QUERY-{&BROWSE-NAME}}  then do:
    { gbl/markstrn.i {&FIRST-TABLE-IN-QUERY-{&BROWSE-NAME}} p-rid-list }
    loc#log = {&BROWSE-NAME}:refresh() .

    if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
        loc#log = {&BROWSE-NAME}:select-next-row ().
        apply "VALUE-CHANGED" to {&BROWSE-NAME} in frame {&frame-name}.
    end.
    if num-entries( p-rid-list ) = 0
    then
        hide mark-num in frame {&frame-name}.
    else
        disp num-entries( p-rid-list ) @ mark-num with frame {&frame-name}.
  end.
  apply "entry" to {&BROWSE-NAME} in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-mark-all
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mark-all Dialog-Frame
ON CHOOSE OF B-mark-all IN FRAME Dialog-Frame /* + */
DO:
define variable loc#log as logical no-undo .
     run OpenBR in this-procedure .
        DO WHILE available {&FIRST-TABLE-IN-QUERY-{&BROWSE-NAME}}  :
          if available {&FIRST-TABLE-IN-QUERY-{&BROWSE-NAME}} then do:
          { gbl/markstrn.i {&FIRST-TABLE-IN-QUERY-{&BROWSE-NAME}} p-rid-list }
        end.
        GET next {&browse-name}.
    end.
  run OpenBR in this-procedure .
  apply "entry" to {&BROWSE-NAME} in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-print Dialog-Frame
ON CHOOSE OF B-print IN FRAME Dialog-Frame /* Печать */
DO:
  run proc-b-print in this-procedure no-error.
  if error-status:error then do:
    return no-apply.
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-sel Dialog-Frame
ON CHOOSE OF B-sel IN FRAME Dialog-Frame /* Выбор */
DO:
  IF  p-rid-list = "" THEN DO:
      IF AVAILABLE buf_matrix THEN p-rid-list = string(RECID(buf_matrix)).
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BROWSE-AM
&Scoped-define SELF-NAME BROWSE-AM
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BROWSE-AM Dialog-Frame
ON ROW-DISPLAY OF BROWSE-AM IN FRAME Dialog-Frame
DO:
  IF can-find (first  assortment-matrix-goods no-lock where
                      assortment-matrix-goods.db-num  = buf_matrix.db-num and
                      assortment-matrix-goods.asmg-status  = 0 and
                      assortment-matrix-goods.asmt-id = buf_matrix.asmt-id )  THEN DO:
      buf_matrix.asmt-date-create   :fgcolor in browse {&browse-name} = ?.
      buf_matrix.asmt-date-update   :fgcolor in browse {&browse-name} = ?.
      buf_matrix.asmt-db-num-create :fgcolor in browse {&browse-name} = ?.
      buf_matrix.asmt-db-num-update :fgcolor in browse {&browse-name} = ?.
      buf_matrix.asmt-name         :fgcolor in browse {&browse-name} = ? .
      p-asmt-type         :fgcolor in browse {&browse-name} = ? .
      p-mark                       :fgcolor in browse {&browse-name} = ? .
      p-obj                        :fgcolor in browse {&browse-name} = ? .
      p-time-upd                   :fgcolor in browse {&browse-name} = ? .
      p-time-cr                    :fgcolor in browse {&browse-name} = ? .
      p-status                     :fgcolor in browse {&browse-name} = ? .


  END.
  ELSE DO:
      buf_matrix.asmt-date-create   :fgcolor in browse {&browse-name} = DARK_GRAY_COLOR.
      buf_matrix.asmt-date-update   :fgcolor in browse {&browse-name} = DARK_GRAY_COLOR.
      buf_matrix.asmt-db-num-create :fgcolor in browse {&browse-name} = DARK_GRAY_COLOR.
      buf_matrix.asmt-db-num-update :fgcolor in browse {&browse-name} = DARK_GRAY_COLOR.
      buf_matrix.asmt-name         :fgcolor in browse {&browse-name}  = DARK_GRAY_COLOR.
      p-asmt-type         :fgcolor in browse {&browse-name}  = DARK_GRAY_COLOR.
      p-mark                       :fgcolor in browse {&browse-name}  = DARK_GRAY_COLOR.
      p-obj                        :fgcolor in browse {&browse-name}  = DARK_GRAY_COLOR.
      p-time-upd                   :fgcolor in browse {&browse-name}  = DARK_GRAY_COLOR.
      p-time-cr                    :fgcolor in browse {&browse-name}  = DARK_GRAY_COLOR.
      p-status                     :fgcolor in browse {&browse-name}  = DARK_GRAY_COLOR.
  END.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BROWSE-AM Dialog-Frame
ON VALUE-CHANGED OF BROWSE-AM IN FRAME Dialog-Frame
DO:

    IF AVAILABLE buf_Matrix THEN DO:
       { gbl/usrfulnm.i
        buf_matrix.asmt-who-create
        v-user-name-create
        }
        { gbl/usrfulnm.i
         buf_matrix.asmt-who-update
        v-user-name-corr
        }
        DISPLAY buf_Matrix.asmt-des
                v-user-name-corr
                v-user-name-create
        WITH FRAME {&FRAME-NAME}.

        name-link = f-name-link(recid(buf_Matrix)).
       if name-link <> "" then do:
          display i-link name-link with frame {&FRAME-NAME} .

       end.
       else do:
         hide i-link name-link in frame {&FRAME-NAME} .

       end.
    END.
    else do:
      hide i-link name-link in frame {&FRAME-NAME} .
    end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME RS-object
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL RS-object Dialog-Frame
ON VALUE-CHANGED OF RS-object IN FRAME Dialog-Frame
DO:

  run openbr in this-procedure no-error.
  IF ERROR-STATUS:ERROR  THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME RS-sts
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL RS-sts Dialog-Frame
ON VALUE-CHANGED OF RS-sts IN FRAME Dialog-Frame
DO:

  RUN openbr IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR  THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME RS-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL RS-type Dialog-Frame
ON VALUE-CHANGED OF RS-type IN FRAME Dialog-Frame
DO:


  RUN openbr IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR  THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.
{ gbl/setfltnm.i no-button }
{ gbl/app_help.i }
{ gbl/srt-clmd.i
  &browse-name    = "{&browse-name}"
  &frame-name     = "{&frame-name}"
  &table-name     = buf_Matrix
  &label-clmn_1     =   "{&col-l1}"
  &label-clmn_2     =   "{&col-l2}"
  &label-clmn_3     =   "{&col-l3}"
  &label-clmn_4     =   "{&col-l4}"
  &label-clmn_5     =   "{&col-l5}"
  &label-clmn_6     =   "{&col-l6}"
  &label-clmn_7     =   "{&col-l7}"
  &label-clmn_8     =   "{&col-l8}"
  &label-clmn_9     =   "{&col-l9}"
  &label-clmn_10    =   "{&col-l10}"
  &label-clmn_11    =   "{&col-l11}"
  &label-clmn_12    =   "{&col-l12}"
  &label-clmn_13    =   "{&col-l13}"
  &label-clmn_14    =   "{&col-l14}"
  &sort-clmn_1    =   "{&cop-l1}"
  &dyn_sort-clmn_1    =   "{&dyn_cop-l1}"
  &sort-clmn_2    =   "{&cop-l2}"
  &sort-clmn_3    =   "{&cop-l3}"
  &sort-clmn_4    =   "{&cop-l4}"
  &sort-clmn_5    =   "{&cop-l5}"
  &sort-clmn_6    =   "{&cop-l6}"
  &sort-clmn_7    =   "{&cop-l7}"
  &sort-clmn_8    =   "{&cop-l8}"
  &sort-clmn_9    =   "{&cop-l9}"
  &sort-clmn_10   =   "{&cop-l10}"
  &sort-clmn_11   =   "{&cop-l11}"
  &sort-clmn_12   =   "{&cop-l12}"
  &sort-clmn_13    =  "{&cop-l13}"
  &sort-clmn_14    =   "{&cop-l14}"
  &dyn_sort-clmn_14    =   "{&dyn_cop-l14}"
  &open-query     = "run OpenBr."
  &open-query-otherwise = "run OpenBr."
  &sort-column-name = "sort-column-name"
  &re-move-clmn   = "no"
  &mv-brw-default = "no"
}


{ gbl/brwrepos.i
  &line-num=5
}

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  { gbl/curdbnum.i v-db-num }
  run my_enable in this-procedure .
  hide mark-num in frame {&frame-name} .
  if v-doc-rec <> ? then
  reposition {&browse-name} to recid v-doc-rec no-error.

  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
run disable_ui in this-procedure .

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
  DISPLAY RS-sts RS-type RS-object mark-num FILL-IN-1 FILL-IN-2 v-text_object-bd
          v-user-name-create name-link v-user-name-corr
      WITH FRAME Dialog-Frame.
  IF AVAILABLE buf_matrix THEN
    DISPLAY buf_matrix.asmt-des
      WITH FRAME Dialog-Frame.
  ENABLE b-quit I-link B-mark B-sel B-add B-lookup B-chg B-del B-Help
         B-mark-all B-demark-all B-goods B-print RS-sts B-hist RS-type
         RS-object BROWSE-AM buf_matrix.asmt-des mark-num FILL-IN-1 FILL-IN-2
         v-text_object-bd v-user-name-create name-link v-user-name-corr
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my_enable Dialog-Frame
PROCEDURE my_enable :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable v-db-num like ub.db.db-num no-undo .
{ gbl/curdbnum.i v-db-num }

buf_Matrix.asmt-name:read-only in browse {&browse-name} = true .
buf_Matrix.asmt-name:resizable in browse {&browse-name} = true .

ASSIGN
rs-sts:RADIO-BUTTONS IN FRAME {&FRAME-NAME}
              = "Текущие&+" + {&comma-char} +  {&current-status-int} + {&comma-char} +
              "Все&!" + {&comma-char} + {&all} + {&comma-char} +
              "Удаленные&-" + {&comma-char} + {&deleted-status-int}
rs-sts = (IF p-sts = ? THEN {&current-status-int} ELSE string(p-sts))

rs-type:RADIO-BUTTONS IN FRAME {&FRAME-NAME}
                = "Все" + {&comma-char} +  "1" + {&comma-char} +
                "Объект" + {&comma-char} + "2" + {&comma-char} +
                "Шаблон" + {&comma-char} + "3"
rs-object:RADIO-BUTTONS IN FRAME {&FRAME-NAME}
                = "Своя БД" + {&comma-char} +  "1" + {&comma-char} +
                  "Все БД" + {&comma-char} + "2"
.



if v-db-num = 0 then
      assign
        rs-object = "2"
        rs-type = "1"
      .
    else
      assign
        rs-object = "1"
        rs-type = "1"
      .

if p-mode = {&type-assmatr-shablon} then do:
   rs-type = "3" .
   rs-type:RADIO-BUTTONS IN FRAME {&FRAME-NAME} =   "Шаблон" + {&comma-char} + "3" .
   display rs-type with frame {&frame-name} .
end.

v-type-s  = {&type-assmatr-shablon}  .
v-type-o  = {&type-assmatr-obj} .

if rs-type = "3" then v-type = {&type-assmatr-shablon} .
if rs-type = "2" then v-type = {&type-assmatr-obj} .
rs-sts = {&current-status-int} .
DISPLAY mark-num
FILL-IN-1
FILL-IN-2
v-text_object-bd
RS-sts
RS-type
RS-object
WITH FRAME Dialog-Frame.

ENABLE
b-quit
B-mark when LOOKUP("b-mark":U, bttns) > 0
B-mark-all when LOOKUP("b-mark":U, bttns) > 0
B-demark-all when LOOKUP("b-mark":U, bttns) > 0
B-sel when LOOKUP("b-sel":U, bttns) > 0
B-add when LOOKUP("b-add":U, bttns) > 0 /* and v-db-num = 0 */
B-lookup
B-chg when LOOKUP("b-add":U, bttns) > 0 /* and v-db-num = 0 */
B-del when LOOKUP("b-add":U, bttns) > 0 /* and v-db-num = 0 */
B-print
B-Help
B-hist
{&browse-name}
mark-num
RS-sts
RS-type
RS-object
b-goods
buf_matrix.asmt-des
with FRAME Dialog-Frame.
VIEW FRAME Dialog-Frame.

buf_matrix.asmt-des:READ-ONLY = TRUE.
run openbr in this-procedure no-error.
IF ERROR-STATUS:ERROR  THEN RETURN error.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE openBr Dialog-Frame
PROCEDURE openBr :
define variable p-open-query     as logical   no-undo init true .
define variable l-query-was-opened as logical no-undo .
define variable doc-rec  as recid     no-undo .
define variable  p-find-next      as logical   no-undo .
define variable  p-find-condition as character no-undo .

ASSIGN  FRAME {&FRAME-NAME}
  rs-sts
  rs-object
  rs-type
    .
ASSIGN
  p-sts = (IF rs-sts = {&all} THEN ? ELSE INTEGER(rs-sts))
  .


  if rs-type = "3" then v-type = {&type-assmatr-shablon} .
  if rs-type = "2" then v-type = {&type-assmatr-obj} .
  if rs-type = "1" then v-type = "" .
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
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

define variable title0 as character no-undo init "Список Ассортиментных матриц".


&scop flt-open-open-query OPEN QUERY BROWSE-AM FOR EACH buf_Matrix

&scop flt-open-dyn_open-query  FOR EACH buf_Matrix

&scop flt-open-query-handle query BROWSE-AM:handle

&scop flt-open-find-buffer-name buf_Matrix

&scop flt-open-open-query-tail

&scop flt-open-query-was-opened     l-query-was-opened

&scop flt-open-sort-column-phrase   sort-column-phrase

&scop flt-open-call-point           filter-point

&scop flt-open-set-filter-name      set-filter-name

&scop flt-open-indexed-reposition  indexed-reposition

&scop flt-open-query               p-open-query

&scop flt-open-table-name          buf_matrix

&scop flt-open-search-option       no-lock

&scop flt-open-find-next           p-find-next

&scop flt-open-find-recid          doc-rec

&scop flt-open-find-condition       p-find-condition

&scop flt-open-find-buffer-def      define buffer buf_Matrix for assortment-matrix.

&scop flt-open-debug-file

&scop flt-open-waitfram             true



IF p-sts = ? THEN DO:
    frame {&frame-name}:TITLE = title0  .

    if rs-type = "1" or rs-type = "" then do:
        if rs-object = "2" then do:
            { gbl/fltopend.i
              &where-cond = " true "
              &dyn_where-cond = " 'true' "
              &use-ind    = " USE-INDEX asmt-name "
              &by         = " " }

        end.
        else do:
            { gbl/fltopend.i
              &where-cond     = " ( buf_Matrix.db-num-obj = v-db-num  and  buf_Matrix.asmt-type = v-type-o) or ( buf_Matrix.asmt-type = v-type-s )"
              &dyn_where-cond =  " substitute(' ( buf_Matrix.db-num-obj = &2 and  buf_Matrix.asmt-type = &1&3&1 ) or ( buf_Matrix.asmt-type = &1&4&1  ) ' , ~{&double-quote~} ,v-db-num  , v-type-o , v-type-s ) "
              &use-ind    = " USE-INDEX asmt-name "
              &by         = " " }

        end.
    end.
    else do:
        if rs-object = "2" then do:
            { gbl/fltopend.i
              &where-cond = " buf_Matrix.asmt-type = v-type  "
              &dyn_where-cond =  " substitute(' buf_Matrix.asmt-type = &1&2&1  ' , ~{&double-quote~} , v-type ) "
              &use-ind    = " USE-INDEX  asmt-name "
              &by         = " " }

        end.
        else do:
            if v-type = {&type-assmatr-shablon} then do:
            { gbl/fltopend.i
              &where-cond = " buf_Matrix.asmt-type = v-type  "
              &dyn_where-cond =  " substitute(' buf_Matrix.asmt-type = &1&2&1  ' , ~{&double-quote~} , v-type ) "
              &use-ind    = " USE-INDEX  asmt-name "
              &by         = " " }
            end.
            else do:
            { gbl/fltopend.i
              &where-cond = " buf_Matrix.asmt-type = v-type and buf_Matrix.db-num-obj = v-db-num "
              &dyn_where-cond =  " substitute(' buf_Matrix.asmt-type = &1&2&1 and buf_Matrix.db-num-obj = &3 ' , ~{&double-quote~} , v-type , v-db-num ) "
              &use-ind    = " USE-INDEX  asmt-name "
              &by         = " " }
            end.
        end.
    end.

END.
ELSE DO:
&SCOPED-DEFINE status-code STRING(p-sts)
    frame {&frame-name}:TITLE = title0 + {&space-char} + {&status-int-name}.

    if rs-type = "1" or rs-type = "" then do:
        if rs-object = "2" then do:
            { gbl/fltopend.i
              &where-cond = " buf_Matrix.asmt-status = p-sts "
              &dyn_where-cond =  " substitute(' buf_Matrix.asmt-status = &1 ' , p-sts ) "
              &use-ind    = " USE-INDEX  asmt-name "
              &by         = " " }

        end.
        else do:
            { gbl/fltopend.i
              &where-cond = " buf_Matrix.asmt-status = p-sts and TRUE and ((buf_Matrix.db-num-obj = v-db-num  and  buf_Matrix.asmt-type = v-type-o) or ( buf_Matrix.asmt-type = v-type-s )) "
              &dyn_where-cond =  " substitute(' buf_Matrix.asmt-status = &5 and TRUE and (( buf_Matrix.db-num-obj = &2 and  buf_Matrix.asmt-type = &1&3&1 ) or ( buf_Matrix.asmt-type = &1&4&1  )) ' , ~{&double-quote~} ,v-db-num  , v-type-o , v-type-s ,p-sts) "
              &use-ind    = " USE-INDEX  asmt-name "
              &by         = " " }

        end.
    end.
    else do:
        if rs-object = "2" then do:
            { gbl/fltopend.i
              &where-cond = " buf_Matrix.asmt-status = p-sts and TRUE and buf_Matrix.asmt-type = v-type "
              &dyn_where-cond =  " substitute(' buf_matrix.asmt-status = &2 and true and buf_matrix.asmt-type = &1&3&1 ' , ~{&double-quote~} , p-sts , v-type ) "
              &use-ind    = " USE-INDEX  asmt-name "
              &by         = " " }

        end.
        else do:
            if v-type = {&type-assmatr-shablon} then do:
            { gbl/fltopend.i
              &where-cond = " buf_Matrix.asmt-status = p-sts and TRUE and buf_Matrix.asmt-type = v-type "
              &dyn_where-cond =  " substitute(' buf_matrix.asmt-status = &2 and true and buf_matrix.asmt-type = &1&3&1  ' , ~{&double-quote~} , p-sts , v-type ) "
              &use-ind    = " USE-INDEX  asmt-name "
              &by         = " " }

            end.
            else do:
            { gbl/fltopend.i
              &where-cond = " buf_Matrix.asmt-status = p-sts and TRUE and buf_Matrix.asmt-type = v-type  and buf_Matrix.db-num-obj = v-db-num"
              &dyn_where-cond =  " substitute(' buf_matrix.asmt-status = &2 and true and buf_matrix.asmt-type = &1&3&1 and buf_Matrix.db-num-obj = &4 ' , ~{&double-quote~} , p-sts , v-type  , v-db-num) "
              &use-ind    = " USE-INDEX  asmt-name "
              &by         = " " }
            end.
        end.
    end.
END.



APPLY "VALUE-CHANGED" TO {&BROWSE-NAME} in frame {&frame-name}.
APPLY "ENTRY" TO {&BROWSE-NAME}.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-del Dialog-Frame
PROCEDURE proc-b-del :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable loc#log as logical no-undo.
define variable v-sts like ub.assortment-matrix.asmt-status no-undo .
DEFINE VARIABLE loc-doc-rec AS RECID NO-UNDO.
if not available buf_Matrix then return error.

do
on error undo, return error
on stop undo, return error

:
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_assort-matr_deletion':U
    {&cntxt-global}
    v-cntxt-host-code-obj
    v-cntxt-obj-type
    v-cntxt-obj-code
    0
    0
    0
    true
    loc#log
  }
  if loc#log <> yes then do: return error. end.
  assign
  v-sts = ?
  loc-doc-rec = RECID(buf_Matrix)
  .
  run ref/assmatr2.p (
       input recid ( buf_Matrix )
      ,input-output v-sts )
       no-error .

  if error-status:error then undo, return error.
  run openbr in this-procedure .
  REPOSITION {&browse-name} to recid loc-doc-rec No-error.
  {&cant-positioning}
  if available buf_Matrix then do:
    loc#log = {&browse-name}:select-focused-row( ) IN FRAME {&FRAME-NAME}.
  end.
  apply "ENTRY" to {&browse-name}.
end.

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

define variable v-doc-rec as recid no-undo .
define variable accum-count as integer.
define variable date_string     as      char    no-undo.
define variable Line            as      char    no-undo.
define variable v-time-cr as character no-undo .
define variable v-time-up as character no-undo .
define variable v-st      as character no-undo .

DEFINE FRAME buf_Matrix-list
      buf_Matrix.asmt-name COLUMN-LABEL "Название" FORMAT "X(30)":U
      buf_Matrix.asmt-type COLUMN-LABEL "Тип" FORMAT "X(6)":U
      buf_Matrix.obj-type  COLUMN-LABEL "Объект"
      buf_Matrix.obj-code
      buf_Matrix.asmt-date-update COLUMN-LABEL "Дата!изменения" FORMAT "99/99/99":U
      v-time-up COLUMN-LABEL "Время" FORMAT "x(5)":U
      buf_Matrix.asmt-who-update COLUMN-LABEL "Кто!изменил" FORMAT "X(8)":U
      buf_Matrix.asmt-db-num-update COLUMN-LABEL "БД!изм" FORMAT ">>>>9":U
      buf_Matrix.asmt-date-create COLUMN-LABEL "Дата!создания" FORMAT "99/99/99":U
      v-time-cr  COLUMN-LABEL "Время" FORMAT "x(5)":U
      buf_Matrix.asmt-who-create COLUMN-LABEL "Кто!создал" FORMAT "X(8)":U
      buf_Matrix.asmt-db-num-create COLUMN-LABEL "БД!соз" FORMAT ">>>>9":U
HEADER  date_string AT 5 format "X(35)"
 string( "Страница " ) format "X(9)" AT 115 PAGE-NUMBER(PrnLibStream) AT 125 FORMAT ">>9" SKIP
Line format "X(195)" AT 1
with width {&DOS_CW_2} down stream-io use-text    .

Line = fill("-", 195).
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
Line format "X(195)" AT 1 SKIP
"Продолжение - на следующей странице" AT 30 SKIP
with FRAME BottomFrame width {&DOS_CW_2} PAGE-BOTTOM NO-LABELS NO-BOX .
VIEW  STREAM PrnLibStream FRAME BottomFrame .

FORM with FRAME buf_Matrix-list  .
run waitfram-show in this-procedure ("Ждите...").
v-doc-rec = recid(buf_Matrix).
DO WHILE available buf_Matrix :
  GET prev {&browse-name}.
END.
GET next {&browse-name}.
DO WHILE available buf_Matrix :
  Display STREAM PrnLibStream
      buf_Matrix.asmt-name
      buf_Matrix.asmt-type
      buf_Matrix.obj-type
      buf_Matrix.obj-code
      buf_Matrix.asmt-date-update
      STRING (buf_Matrix.asmt-time-update,"HH:MM") @ v-time-up
      buf_Matrix.asmt-who-update
      buf_Matrix.asmt-db-num-update
      buf_Matrix.asmt-date-create
      STRING (buf_Matrix.asmt-time-create,"HH:MM") @ v-time-cr
      buf_Matrix.asmt-who-create
      buf_Matrix.asmt-db-num-create
with FRAME buf_Matrix-list .
  DOWN STREAM PrnLibStream 1
  with FRAME buf_Matrix-list  .
  assign
  accum-count = accum-count + 1
  .
  GET next {&browse-name}.
END.
UNDERLINE  STREAM PrnLibStream
      buf_Matrix.asmt-name
      buf_Matrix.asmt-type
      buf_Matrix.obj-type
      buf_Matrix.obj-code
      buf_Matrix.asmt-date-update
      buf_Matrix.asmt-who-update
      buf_Matrix.asmt-db-num-update
      buf_Matrix.asmt-date-create
      buf_Matrix.asmt-who-create
      buf_Matrix.asmt-db-num-create
      v-time-cr
      v-time-up
with FRAME buf_Matrix-list .
DISPLAY STREAM PrnLibStream
"ИТОГО" @ buf_Matrix.asmt-name
accum-count @ buf_Matrix.asmt-type
with frame buf_Matrix-list.
HIDE  STREAM PrnLibStream FRAME BottomFrame .
HIDE  STREAM PrnLibStream FRAME buf_Matrix-List.
output  STREAM PrnLibStream CLOSE.
REPOSITION {&browse-name} to recid v-doc-rec no-error.
APPLY "entry" to {&browse-name}.
run waitfram-hide in this-procedure .
run prn-lib-prn-file in this-procedure (
                                          input parParentProc
                                          ,input 8
                                          ).


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-br Dialog-Frame
PROCEDURE proc-br :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
{ ref/brwsretr.i }

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION attrRootShablon Dialog-Frame
FUNCTION attrRootShablon RETURNS CHARACTER
  ( p-recid as recid ) :

define buffer bufs_matrix for ub.assortment-matrix.
define variable v-type as character no-undo .
define variable v-value as character no-undo .

find first bufs_matrix no-lock  where recid(bufs_matrix) = p-recid no-error .
if error-status :error then return "" .
if bufs_matrix.asmt-type = {&type-assmatr-shablon}  then
   return substitute("&1&3&2" ,bufs_matrix.asmt-id ,bufs_matrix.db-num, {&delim-nws}  ) .
else do:
  run assmatat-value (
       input bufs_matrix.asmt-id
      ,input bufs_matrix.db-num
      ,input {&assmatat-RootShablon}
      ,output v-value
      ,output v-type
      ) .
   return  v-value .
 end.

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION f-name-link Dialog-Frame
FUNCTION f-name-link RETURNS CHARACTER
  ( p-recid as recid ) :

define buffer bufs_matrix for ub.assortment-matrix.
define buffer bufr_assortment-matrix for ub.assortment-matrix.

define variable v-type as character no-undo .
define variable v-value as character no-undo .

find first bufs_matrix no-lock  where recid(bufs_matrix) = p-recid no-error .
if error-status :error then return "" .
if bufs_matrix.asmt-type = {&type-assmatr-shablon}  then
   return "".
else do:
  run assmatat-value (
       input bufs_matrix.asmt-id
      ,input bufs_matrix.db-num
      ,input {&assmatat-RootShablon}
      ,output v-value
      ,output v-type
      ) .
     find first bufr_assortment-matrix no-lock where
                bufr_assortment-matrix.asmt-id = int(entry(1,v-value,{&delim-par})) and
                bufr_assortment-matrix.db-num  = int(entry(2,v-value,{&delim-par})) no-error .
    if not available bufr_assortment-matrix then do:
       return  "" .
    end.
    else do:
      return  bufr_assortment-matrix.asmt-name.
    end.
 end.
END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION shablon-type Dialog-Frame
FUNCTION shablon-type RETURNS CHARACTER
  ( p-recid as recid ) :

define buffer bufs_matrix for ub.assortment-matrix.
define buffer obj_assortment-matrix for ub.assortment-matrix  .

define variable v-type as character no-undo .
define variable v-value as character no-undo .

find first bufs_matrix no-lock  where recid(bufs_matrix) = p-recid no-error .
if error-status :error then return "" .

if bufs_matrix.asmt-type <> {&type-assmatr-shablon}  then do:
   return "".
end.
else do:
   for each obj_assortment-matrix no-lock where
            obj_assortment-matrix.asmt-status = 0 and
            obj_assortment-matrix.asmt-type   =   {&type-assmatr-obj} ,
      first ub.assortment-matrix-attr no-lock where
            ub.assortment-matrix-attr.asmt-id    = obj_assortment-matrix.asmt-id and
            ub.assortment-matrix-attr.db-num     = obj_assortment-matrix.db-num  and
            ub.assortment-matrix-attr.attr-code  = {&assmatat-RootShablon} and
            ub.assortment-matrix-attr.attr-value = substitute("&1&3&2" , bufs_matrix.asmt-id,bufs_matrix.db-num,{&delim-par})
            :
            return chr(135) .
   end.
end.
RETURN "".   /* Function return value. */
END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME