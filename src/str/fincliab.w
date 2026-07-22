&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

История финансовых обязательств

Автор: Чернова Светлана Александровна
Дата создания: 03/03/06
Author: Svetlana Chernova
Creation date: 03/03/06

Creation date: 10/31/03 1:51

*/
define input parameter parparentproc  as widget-handle no-undo.
define input parameter bttns     as character   no-undo .
define input parameter par-mode  as character   no-undo .
define input parameter par-host-code like ub.clients.obj-code no-undo.
define input parameter par-doc-code as character no-undo .
define output parameter rid-list        as character no-undo . /* список recid'ов выбранных */

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "История финансовых обязательств".
{ cmp/vssrevis.i }
/*кнопки для нажатия*/

define variable  p-doc-type   as character no-undo .
define variable  p-status_   as character no-undo .
define variable  p-char      as character no-undo .

define variable g-log as logical no-undo .
define variable doc-rec as recid no-undo .
define variable g#report-num as integer no-undo .

define variable p-base-code as integer no-undo .

/* Local Variable Definitions ---                                       */

{ cmp/trg-def.i      }
{ cmp/showinf.i      }
{ gbl/flt-def.i      }
{ gbl/cur-time.i     }
{ cmp/r-pril.i new   }
{ gbl/fltfield.i     }
{ gbl/prn-lib.i      }
{ gbl/waitfram.i     }
{ gbl/getcntxt.i def }
{ gbl/usrfulnf.i     }
{ gbl/fltopend.i defproc }
{ cmp/mrk-strf.i }

&Scoped-Define main-file c-fin-ob

&scop col-l0   '*'
&scop col-l1  'Т'
&scop col-l2  'Статус'
&scop col-l3  '№ док-та'
&scop col-l4  'Создан'
&scop col-l5  'Закрыт'
&scop col-l6  'Договор'
&scop col-l7  'Получатель'
&scop col-l8  'Плательщик'
&scop col-l9  'Платеж'
&scop col-l10 'Вал'
&scop col-l11 'Сумма в валюте док-та'
&scop col-l13 'Внутр.№'
&scop col-l14 'Дата изменения'
&scop col-l15 'Документ изменения'
&scop col-l16 'Время изменения '
&scop col-l17 'Изменение с БД №'
&scop col-l18 'Изменил'

&scop cop-l0      mark-string(recid( buf_c-fin-liab), rid-list)
&scop dyn_cop-l0  substitute('dynamic-function(&1mark-string&1, recid(buf_c-fin-liab), &1&2&1)', ~{&double-quote~}, rid-list)
&scop cop-l1  buf_c-fin-liab.doc-type
&scop cop-l2  buf_c-fin-liab.status_
&scop cop-l3  buf_c-fin-liab.prn-doc-code
&scop cop-l4  substring(string(buf_c-fin-liab.doc-date),1,5)
&scop cop-l5  buf_c-fin-liab.fact-date
&scop cop-l6  buf_c-fin-liab.contract-code
&scop cop-l7  buf_c-fin-liab.receiver-type + " " + string(buf_c-fin-liab.receiver-code)
&scop cop-l8  buf_c-fin-liab.payer-type + " " + string(buf_c-fin-liab.payer-code)
&scop cop-l9  buf_c-fin-liab.pay-date
&scop cop-l10      val-abbr-type(recid( buf_c-fin-liab))
&scop dyn_cop-l10  substitute('dynamic-function(&1val-abbr-type&1, recid(buf_c-fin-liab))', ~{&double-quote~})
&scop cop-l11 buf_c-fin-liab.sum-doc
&scop cop-l13 buf_c-fin-liab.doc-code
&scop cop-l14 buf_c-fin-liab.corr-date
&scop cop-l15 buf_c-fin-liab.corr-doc-code
&scop cop-l16 string(buf_c-fin-liab.corr-time,'hh:mm:ss')
&scop cop-l17 buf_c-fin-liab.corr-user-db-num
&scop cop-l18 buf_c-fin-liab.corr-user-name

define variable filter-point as character no-undo init "Список финобязательства" .
define variable filter-point0 as character no-undo init "Фин_обязательства_" .
define variable sort-column-name as character no-undo .
define variable print-type as character no-undo.
define variable del-type as character no-undo.
define variable deleted as logical no-undo init no.
DEFINE VARIABLE change-type as character init "" no-undo .

DEFINE /* NEW SHARED  */ var br-handle as handle no-undo.

define buffer find_code for c-fin-ob .
DEFINE NEW SHARED BUFFER buf_c-fin-liab FOR c-fin-ob .

define temp-table temp-changes no-undo
field f_name as character
field l_name as character
field v_old as character
field v_new as character
index pi is unique primary
f_name.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BR-changes

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES temp-changes buf_c-fin-liab c-fin-ob

/* Definitions for BROWSE BR-changes                                    */
&Scoped-define FIELDS-IN-QUERY-BR-changes temp-changes.l_name temp-changes.v_old temp-changes.v_new
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-changes
&Scoped-define FIELD-PAIRS-IN-QUERY-BR-changes
&Scoped-define SELF-NAME BR-changes
&Scoped-define OPEN-QUERY-BR-changes OPEN QUERY {&SELF-NAME} FOR EACH temp-changes.
&Scoped-define TABLES-IN-QUERY-BR-changes temp-changes
&Scoped-define FIRST-TABLE-IN-QUERY-BR-changes temp-changes


/* Definitions for BROWSE BR-docs                                       */
&Scoped-define FIELDS-IN-QUERY-BR-docs {&cop-l0} {&cop-l1} {&cop-l2} {&cop-l3} {&cop-l4} {&cop-l5} {&cop-l6} {&cop-l7} {&cop-l8} {&cop-l9} {&cop-l10} {&cop-l11} {&cop-l12} {&cop-l13} {&cop-l14} {&cop-l15} {&cop-l16} {&cop-l17} {&cop-l18}
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-docs {&cop-l1}
&Scoped-define FIELD-PAIRS-IN-QUERY-BR-docs~
 ~{&FP1}{&cop-l1} ~{&FP2}{&cop-l1} ~{&FP3}
&Scoped-define SELF-NAME BR-docs
&Scoped-define OPEN-QUERY-BR-docs OPEN QUERY {&SELF-NAME} FOR EACH buf_c-fin-liab no-lock.
&Scoped-define TABLES-IN-QUERY-BR-docs buf_c-fin-liab
&Scoped-define FIRST-TABLE-IN-QUERY-BR-docs buf_c-fin-liab


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BR-docs}
&Scoped-define OPEN-QUERY-Dialog-Frame OPEN QUERY Dialog-Frame FOR EACH c-fin-ob SHARE-LOCK.
&Scoped-define TABLES-IN-QUERY-Dialog-Frame c-fin-ob
&Scoped-define FIRST-TABLE-IN-QUERY-Dialog-Frame c-fin-ob


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-Cancel B-mark B-sel B-Help BR-docs ~
BR-changes mark-num loc_receiver-name loc_sum-doc d-abbr loc_payer-name ~
loc_sum-rubl r-abbr loc_sum-base v-abbr
&Scoped-Define DISPLAYED-OBJECTS mark-num loc_receiver-name loc_sum-doc ~
d-abbr loc_payer-name loc_sum-rubl r-abbr loc_sum-base v-abbr

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD sel-abbr Dialog-Frame
FUNCTION sel-abbr RETURNS CHARACTER
 ( p-curr-code as int )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD val-abbr-type Dialog-Frame
FUNCTION val-abbr-type RETURNS CHARACTER
  ( p-recid as recid  )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-Cancel AUTO-END-KEY
     LABEL "Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-Help
     LABEL "Помощь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-lookup
     LABEL "&Просмотр"
     SIZE 10 BY 1 TOOLTIP "Просмотр записи".

DEFINE BUTTON B-mark
     LABEL "&*"
     SIZE 3 BY 1 TOOLTIP "Отметить строки списка"
     BGCOLOR 8 .

DEFINE BUTTON B-parts
     LABEL "Партии"
     SIZE 10 BY 1 TOOLTIP "Просмотр складского документа"
     BGCOLOR 8 .

DEFINE BUTTON B-sch
     LABEL "Фильтр"
     SIZE 10 BY 1 TOOLTIP "Фильтрация списка"
     BGCOLOR 8 .

DEFINE BUTTON B-sel AUTO-GO
     LABEL "Выбор"
     SIZE 10 BY 1 TOOLTIP "Выбор отмеченных или текущей записи"
     BGCOLOR 8 .

DEFINE VARIABLE d-abbr AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 3.88 BY .67
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE loc_payer-name AS CHARACTER FORMAT "X(40)"
     LABEL "Плательщик"
      VIEW-AS TEXT
     SIZE 21.13 BY .67 NO-UNDO.

DEFINE VARIABLE loc_receiver-name AS CHARACTER FORMAT "X(40)"
     LABEL "Получатель"
      VIEW-AS TEXT
     SIZE 21.13 BY .67 NO-UNDO.

DEFINE VARIABLE loc_sum-base AS DECIMAL FORMAT "->>>,>>>,>>9.99" INITIAL 0
     LABEL "Сумма б.в."
      VIEW-AS TEXT
     SIZE 14 BY .67 NO-UNDO.

DEFINE VARIABLE loc_sum-doc AS DECIMAL FORMAT "->>>,>>>,>>9.99" INITIAL 0
     LABEL "Сумма док."
      VIEW-AS TEXT
     SIZE 14 BY .67 NO-UNDO.

DEFINE VARIABLE loc_sum-rubl AS DECIMAL FORMAT "->>>,>>>,>>9.99" INITIAL 0
     LABEL "Сумма "
      VIEW-AS TEXT
     SIZE 14 BY .67 NO-UNDO.

DEFINE VARIABLE mark-num AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 6 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE r-abbr AS CHARACTER FORMAT "X(256)":U INITIAL "{&abbr_rub_allshift}"
      VIEW-AS TEXT
     SIZE 3.88 BY .67
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE v-abbr AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 3.88 BY .67
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-changes FOR
      temp-changes SCROLLING.

DEFINE new shared QUERY BR-docs FOR
      buf_c-fin-liab SCROLLING.

DEFINE QUERY Dialog-Frame FOR
      c-fin-ob SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-changes
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-changes Dialog-Frame _FREEFORM
  QUERY BR-changes DISPLAY
      temp-changes.l_name COLUMn-LABEL "Изменилось" format "X(25)"
      temp-changes.v_old COLUMn-LABEL "Было" format "X(35)"
      temp-changes.v_new COLUMn-LABEL "Стало" format "X(35)"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 90.75 BY 9.67.

DEFINE BROWSE BR-docs
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-docs Dialog-Frame _FREEFORM
  QUERY BR-docs DISPLAY
     {&cop-l0}    COLUMN-LABEL {&col-l0}  FORMAT "x(1)"
     {&cop-l1}    COLUMN-LABEL {&col-l1}  Format "x(1)"
     {&cop-l2}    COLUMN-LABEL {&col-l2}  Format "x(6)"
     {&cop-l3}    COLUMN-LABEL {&col-l3}  Format "x(10)"
     {&cop-l4}    COLUMN-LABEL {&col-l4}  format "x(5)"
     {&cop-l5}    COLUMN-LABEL {&col-l5}  format "99/99/99"
     {&cop-l6}    COLUMN-LABEL {&col-l6}
     {&cop-l7}    COLUMN-LABEL {&col-l7}  Format "x(10)"
     {&cop-l8}    COLUMN-LABEL {&col-l8}  Format "x(10)"
     {&cop-l9}    COLUMN-LABEL {&col-l9}  format "99/99/99"
     {&cop-l10}   COLUMN-LABEL {&col-l10} Format "x(3)"
     {&cop-l11}   COLUMN-LABEL {&col-l11}
     {&cop-l13}   COLUMN-LABEL {&col-l13} Format "99999999"
     {&cop-l14}   COLUMN-LABEL {&col-l14}
     {&cop-l15}   COLUMN-LABEL {&col-l15}
     {&cop-l16}   COLUMN-LABEL {&col-l16}  LABEL-FGCOLOR 15 LABEL-BGCOLOR 3
     {&cop-l17}   COLUMN-LABEL {&col-l17}  format ">>>>9" LABEL-FGCOLOR 15 LABEL-BGCOLOR 3
     {&cop-l18}   COLUMN-LABEL {&col-l18} LABEL-FGCOLOR 15 LABEL-BGCOLOR 3
      usrfulnf({&cop-l18}) COLUMN-LABEL "Кто изменил!ФИО" Format "x(15)" LABEL-FGCOLOR 15 LABEL-BGCOLOR 3
      buf_c-fin-liab.chip-num
      buf_c-fin-liab.sum-base
      buf_c-fin-liab.sum-rubl
      buf_c-fin-liab.sum-contract
      buf_c-fin-liab.con-stat
      buf_c-fin-liab.con-sum-base
      buf_c-fin-liab.con-sum-rubl
      buf_c-fin-liab.con-sum-base
      buf_c-fin-liab.con-sum-rubl
      buf_c-fin-liab.con-sum-contr
      buf_c-fin-liab.contract-curr     COLUMN-LABEL  "вал.договора"
      buf_c-fin-liab.contract-rate     COLUMN-LABEL  "вал.дог м"
      buf_c-fin-liab.contract-scale    COLUMN-LABEL  "вал.дог ш"
      buf_c-fin-liab.base-rate         COLUMN-LABEL  "баз.вал. м"
      buf_c-fin-liab.base-scale        COLUMN-LABEL  "баз.вал. ш"
      buf_c-fin-liab.curr-code         COLUMN-LABEL  "вал.платежа"
      buf_c-fin-liab.exch-rate         COLUMN-LABEL  "баз.пл. м"
      buf_c-fin-liab.exch-scale        COLUMN-LABEL  "баз.пл. ш"
      buf_c-fin-liab.corr-doc
      buf_c-fin-liab.is-back-date
      buf_c-fin-liab.is-corr
      buf_c-fin-liab.is-del
      buf_c-fin-liab.is-doc-del

     enable {&cop-l1}
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS NO-COLUMN-SCROLLING SEPARATORS SIZE 90 BY 8.92.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-Cancel AT ROW 1 COL 1
     B-mark AT ROW 1 COL 11.5
     B-sel AT ROW 1 COL 21
     B-lookup AT ROW 1 COL 31.13
     B-sch AT ROW 1 COL 41.25
     B-parts AT ROW 1 COL 51.25
     B-Help AT ROW 1 COL 81.5
     BR-docs AT ROW 2.21 COL 1.25
     BR-changes AT ROW 13.92 COL 1
     mark-num AT ROW 1 COL 14.88 NO-LABEL
     loc_receiver-name AT ROW 11.21 COL 2.88
     loc_sum-doc AT ROW 11.21 COL 50 COLON-ALIGNED
     d-abbr AT ROW 11.21 COL 64.63 COLON-ALIGNED NO-LABEL
     loc_payer-name AT ROW 12.04 COL 2.88
     loc_sum-rubl AT ROW 12.04 COL 49.88 COLON-ALIGNED
     r-abbr AT ROW 12.04 COL 64.63 COLON-ALIGNED NO-LABEL
     loc_sum-base AT ROW 12.88 COL 50 COLON-ALIGNED
     v-abbr AT ROW 12.88 COL 64.63 COLON-ALIGNED NO-LABEL
     SPACE(21.24) SKIP(10.03)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Финансовые обязательства"
         DEFAULT-BUTTON B-sel CANCEL-BUTTON B-Cancel.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS


/* ***************  Runtime Attributes and UIB Settings  ************** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
                                                                        */
/* BROWSE-TAB BR-docs B-Help Dialog-Frame */
/* BROWSE-TAB BR-changes BR-docs Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR BUTTON B-lookup IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN
       B-lookup:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR BUTTON B-parts IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN
       B-parts:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR BUTTON B-sch IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN
       BR-docs:NUM-LOCKED-COLUMNS IN FRAME Dialog-Frame = 4.

/* SETTINGS FOR FILL-IN loc_payer-name IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN loc_receiver-name IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN mark-num IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-changes
/* Query rebuild information for BROWSE BR-changes
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH temp-changes.
     _END_FREEFORM
     _Query            is NOT OPENED
*/  /* BROWSE BR-changes */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-docs
/* Query rebuild information for BROWSE BR-docs
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH buf_c-fin-liab no-lock.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE BR-docs */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _TblList          = "ub.c-fin-ob"
     _Options          = "SHARE-LOCK"
     _Query            is OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME






/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Финансовые обязательства */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-lookup
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-lookup Dialog-Frame
ON CHOOSE OF B-lookup IN FRAME Dialog-Frame /* Просмотр */
DO:
{ gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_fin-liability_lookup':U
  {&cntxt-firm}
  par-host-code
  '':U
  0
  0
  0
  0
  true
  g-log
}
if not g-log then  return .
define variable rr as recid no-undo .
    if available buf_c-fin-liab then do:
        rr = recid( buf_c-fin-liab ).
        p-doc-type = buf_c-fin-liab.doc-type .
        p-status_  = buf_c-fin-liab.status_  .
        run str/fi-liabi.w
        ( input parparentproc ,
          input {&lookup} ,
          input-output rr ,
          input par-host-code  ,
          input p-doc-type,
          input p-status_
          ).
     end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mark Dialog-Frame
ON CHOOSE OF B-mark IN FRAME Dialog-Frame /* * */
DO:
      if available buf_c-fin-liab then do:
        { gbl/markstrn.i buf_c-fin-liab rid-list }
        g-log = br-docs:refresh() .

        if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
            g-log = br-docs:select-next-row ().
            apply "VALUE-CHANGED" to br-docs in frame {&frame-name}.
        end.

        if num-entries( rid-list ) = 0
        then
            hide mark-num in frame {&frame-name}.
        else do:
            mark-num:screen-value in frame {&frame-name}  = string (num-entries( rid-list )) .
            enable mark-num with frame {&frame-name}.
            end.
    end.
    apply "entry" to br-docs in frame {&frame-name}.



END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-parts
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-parts Dialog-Frame
ON CHOOSE OF B-parts IN FRAME Dialog-Frame /* Партии */
DO:
    run str/fi-parts.w
      ( input parParentProc ,
        input buf_c-fin-liab.doc-code ,
        input par-host-code  ) .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-sch
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-sch Dialog-Frame
ON CHOOSE OF B-sch IN FRAME Dialog-Frame /* Фильтр */
DO:
  run proc-b-sch in this-procedure no-error.
  /*
  message error-status :get-message(1) return-value .

  if error-status:error then return no-apply.
  */
  if not available buf_c-fin-liab then run OpenBr in this-procedure (yes, no, '':U).

/*  run proc-view-changes in this-procedure no-error.*/
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-sel Dialog-Frame
ON CHOOSE OF B-sel IN FRAME Dialog-Frame /* Выбор */
DO:
    if ( available buf_c-fin-liab ) AND ( rid-list = "" ) then
    rid-list = string( recid( buf_c-fin-liab ) ) .
    /* message "выбрано" rid-list .*/

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-docs
&Scoped-define SELF-NAME BR-docs
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-docs Dialog-Frame
ON DELETE-CHARACTER OF BR-docs IN FRAME Dialog-Frame
DO:
   if b-mark:sensitive in frame {&frame-name} then
  APPLY "CHOOSE" to b-mark.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-docs Dialog-Frame
ON INSERT-MODE OF BR-docs IN FRAME Dialog-Frame
DO:
    if b-mark:sensitive in frame {&frame-name} then
  APPLY "CHOOSE" to b-mark.
    else do:
      if b-sel:sensitive in frame {&frame-name} then
      APPLY "CHOOSE" to b-sel.
    end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-docs Dialog-Frame
ON RETURN OF BR-docs IN FRAME Dialog-Frame
OR MOUSE-SELECT-DBLCLICK OF {&self-name} IN FRAME {&frame-name}
DO:
      if b-sel:sensitive in frame {&frame-name}  = yes then
        apply "choose" to b-sel in frame {&frame-name}.
    else
        apply "choose" to b-lookup in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-docs Dialog-Frame
ON VALUE-CHANGED OF BR-docs IN FRAME Dialog-Frame
DO:
if available buf_c-fin-liab then do:
assign
    loc_receiver-name  = buf_c-fin-liab.receiver-name

    loc_payer-name  = buf_c-fin-liab.payer-name
    loc_sum-base  = buf_c-fin-liab.sum-base
    loc_sum-doc   = buf_c-fin-liab.sum-doc
    loc_sum-rubl  = buf_c-fin-liab.sum-rubl
    d-abbr        = sel-abbr(buf_c-fin-liab.curr-code)
    v-abbr        = sel-abbr(p-base-code)
    .

end.

else
 assign
   loc_receiver-name  = ""

   loc_payer-name  = ""
   loc_sum-base  = 0
   loc_sum-doc   = 0
   loc_sum-rubl  = 0
   d-abbr = ""
    .

  display
  loc_receiver-name loc_payer-name loc_sum-base loc_sum-doc loc_sum-rubl
  r-abbr v-abbr  d-abbr
  with frame {&frame-name}.
  run proc-view-changes in this-procedure no-error.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-changes
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */
 { str/crfinob.i  c-fin-ob }

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.
{ gbl/app_help.i }
{ gbl/mv-clmn.i
 &ext-col = 13
 &start-column = 4
 &frame-name = {&frame-name}
 &browse-name = {&browse-name}
}

{ gbl/srt-clmd.i
  &browse-name    = "{&browse-name}"
  &frame-name     = "{&frame-name}"
  &table-name     = "c-fin-ob"
  &label-clmn_1     =   "{&col-l0}"
  &label-clmn_2     =   "{&col-l1}"
  &label-clmn_3     =   "{&col-l2}"
  &label-clmn_4     =   "{&col-l3}"
  &label-clmn_5     =   "{&col-l4}"
  &label-clmn_6     =   "{&col-l5}"
  &label-clmn_7     =   "{&col-l6}"
  &label-clmn_8     =   "{&col-l7}"
  &label-clmn_9     =   "{&col-l8}"
  &label-clmn_10    =   "{&col-l9}"
  &label-clmn_11    =   "{&col-l10}"
  &label-clmn_12    =   "{&col-l11}"
  &label-clmn_13    =   "{&col-l13}"
  &sort-clmn_1    =   "{&cop-l0}"
  &dyn_sort-clmn_1    =   "{&dyn_cop-l0}"
  &sort-clmn_2    =   "{&cop-l1}"
  &sort-clmn_3    =   "{&cop-l2}"
  &sort-clmn_4    =   "{&cop-l3}"
  &sort-clmn_5    =   "{&cop-l4}"
  &sort-clmn_6    =   "{&cop-l5}"
  &sort-clmn_7    =   "{&cop-l6}"
  &sort-clmn_8    =   "{&cop-l7}"
  &sort-clmn_9    =   "{&cop-l8}"
  &sort-clmn_10   =   "{&cop-l9}"
  &sort-clmn_11   =   "{&cop-l10}"
  &dyn_sort-clmn_11   =   "{&dyn_cop-l10}"
  &sort-clmn_12   =   "{&cop-l11}"
  &sort-clmn_13    =  "{&cop-l13}"
&open-query     = "run OpenBr (yes, no, '':U)."
&open-query-otherwise = "run OpenBr (yes, no, '':U)."
&sort-column-name     = "sort-column-name"
&re-move-clmn         = "yes"
&mv-brw-default       = "yes" }

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

  { gbl/getcntxt.i get }

{&cop-l1}:read-only in browse br-docs = true .

loc_sum-rubl:LABEL = "Сумма {&abbr_rub}." .

/* Нaзвание таблицы */
define variable p-file-label as character no-undo .

p-file-label =  "Финансовые обязательства - история".

define buffer buf_clients for  ub.clients .
CASE par-mode:
    WHEN {&company} THEN DO:
      find first buf_clients no-lock where buf_clients.obj-code = par-host-code and buf_clients.obj-type = {&cmp} no-error .
      if not available buf_clients then  return .
    END.
    WHEN "doc-type":U THEN DO:
      find first buf_clients no-lock where buf_clients.obj-code = par-host-code and buf_clients.obj-type = {&cmp} no-error .
      if not available buf_clients then  return .
    END.
    WHEN "status":U THEN DO:
      find first buf_clients no-lock where buf_clients.obj-code = par-host-code and buf_clients.obj-type = {&cmp} no-error .
      if not available buf_clients then  return .
    END.
    otherwise do:
      message vss-workfile vss-revision vss-description skip
      "Неверный вызов - par-mode=" par-mode
      view-as alert-box ERROR.
      return.
    end.
  end CASE.
  run my-enable_ui.
  run openbr (yes, no, '':u).
  hide mark-num in frame {&frame-name} .
  apply "VALUE-CHANGED" to br-docs in frame {&frame-name}.
  wait-for go of frame {&frame-name}.
END.
run disable_ui.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE add-proc Dialog-Frame
PROCEDURE add-proc :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable v-doc-rec as recid no-undo .
if  p-doc-type = ?   then do:
  message  "Добавление финансовых обязательств возможно только  по типам !" view-as alert-box information .
  return .
end.
{ gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_fin-liability_add-def':U
  {&cntxt-firm}
  par-host-code
  '':U
  0
  0
  0
  0
  true
  g-log
}
if not g-log then  return .
define variable rr as recid no-undo .
  run str/fi-liabi.w
    ( input parparentproc,
      input {&add-def} ,
      input-output rr ,
      input par-host-code  ,
      input p-doc-type,
      input p-status_
      ).
  v-doc-rec = rr .
  run openbr (yes, no, '':u).
  reposition br-docs to recid v-doc-rec no-error .
  apply "VALUE-CHANGED" TO BR-docs IN FRAME Dialog-Frame.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI Dialog-Frame _DEFAULT-DISABLE
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


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI Dialog-Frame _DEFAULT-ENABLE
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

  {&OPEN-QUERY-Dialog-Frame}
  GET FIRST Dialog-Frame.
  DISPLAY mark-num loc_receiver-name loc_sum-doc d-abbr loc_payer-name
          loc_sum-rubl r-abbr loc_sum-base v-abbr
      WITH FRAME Dialog-Frame.
  ENABLE B-Cancel B-mark B-sel B-Help BR-docs BR-changes mark-num
         loc_receiver-name loc_sum-doc d-abbr loc_payer-name loc_sum-rubl
         r-abbr loc_sum-base v-abbr
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-enable_UI Dialog-Frame
PROCEDURE my-enable_UI :
{ gbl/basecode.i par-host-code p-base-code }
DISPLAY   mark-num
      WITH FRAME Dialog-Frame.
  ENABLE B-Cancel
         /* B-lookup
         b-parts */
         B-sch
         B-Help
         b-sel       when LOOKUP("b-sel":U,  bttns) > 0
         b-mark      when LOOKUP("b-mark":U, bttns) > 0
         BR-docs   mark-num
         BR-changes
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OpenBr Dialog-Frame
PROCEDURE OpenBr :
define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .
def var l-query-was-opened as logical no-undo .
define variable title0 as character no-undo.

title0 = caps(p-file-label) + {&space-char}.

{&SetCursorWait}
def var sort-column-phrase as character no-undo .

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

&scop flt-open-open-query OPEN QUERY br-docs FOR EACH buf_c-fin-liab

&scop flt-open-dyn_open-query  FOR EACH buf_c-fin-liab

&scop flt-open-query-handle query br-docs:handle

&scop flt-open-find-buffer-name buf_c-fin-liab


&scop flt-open-open-query-tail


&scop flt-open-query-was-opened  l-query-was-opened

&scop flt-open-sort-column-phrase sort-column-phrase

&scop flt-open-call-point filter-point

&scop flt-open-set-filter-name set-filter-name

&scop flt-open-indexed-reposition  indexed-reposition

&scop flt-open-query p-open-query

&scop flt-open-table-name buf_c-fin-liab

&scop flt-open-search-option no-lock

&scop flt-open-find-next p-find-next

&scop flt-open-find-recid doc-rec

&scop flt-open-find-condition p-find-condition

&scop flt-open-find-buffer-def define buffer buf_c-fin-liab for c-fin-ob.

&scop flt-open-debug-file

define variable l-open-query as logical   no-undo .
       find first buf_clients no-lock where buf_clients.obj-code = par-host-code and buf_clients.obj-type = {&cmp} no-error .
       if not available buf_clients then return .
       filter-point = filter-point0 + par-mode.


  CASE par-mode :
    WHEN {&company} THEN DO:
       ASSIGN frame {&frame-name}:TITLE = title0 + "   ФИРМА: " + buf_clients.obj-name  + " Код фирмы " +  string(par-host-code).
      { gbl/fltopend.i
        &where-cond = " buf_c-fin-liab.doc-code = par-doc-code and  buf_c-fin-liab.host-code =  par-host-code  "
        &dyn_where-cond = "  substitute(' buf_c-fin-liab.host-code = &2  and  buf_c-fin-liab.doc-code = &1&3&1' ~
                           , ~{&double-quote~} , par-host-code , par-doc-code ) "
        &use-ind    = "  "
        &by         = "  " }
    END.

END CASE.
if not p-open-query then
REPOSITION br-docs to recid doc-rec No-ERROR.
if not p-open-query and v-fltopend-rowid[1] <> ? then
query br-docs:handle:reposition-to-rowid(v-fltopend-rowid) no-error.

{&SetCursorNo}
APPLY "VALUE-CHANGED" TO br-docs in frame {&frame-name}.
APPLY "ENTRY" TO br-docs.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-sch Dialog-Frame
PROCEDURE proc-b-sch :
assign
  tbl = 'c-fin-ob'
  join-tbl = 'buf_c-fin-liab'
  fld = ""
  lab = ""
  spr = ""
  dim = '0'
  .
run fltfield-add in this-procedure('doc-code', 'Внутр.№', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('prn-doc-code', '№ документа ', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('status_', 'Статус', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('host-code', 'Код фирмы', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('curr-code', 'Код валюты', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('fact-date', 'Закрыт', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('pay-date', 'Дата Платежа', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('trn-doc-code', 'Накладная', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('user-name-doc', 'Создал', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('user-name-fact', 'Закрыл на факт', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.

run fltfield-add in this-procedure('payer-type{&delim-flt}payer-code', 'Плательщик', 'cli',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('receiver-type{&delim-flt}receiver-code', 'Получатель', 'cli',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('corr-doc', 'Корр ФО', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.


Filter-Block:
DO ON STOP    UNDO Filter-Block, LEAVE Filter-Block
    ON ERROR   UNDO Filter-Block, LEAVE Filter-Block
    ON END-KEY UNDO Filter-Block, LEAVE Filter-Block :
  run gbl/filter.w ( INPUT parparentproc, INPUT filter-point, INPUT tbl, INPUT join-tbl, INPUT fld, INPUT lab, INPUT spr, INPUT dim ).
  run openbr (yes, no, '':u).
END. /* Filter-Block */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-find-code Dialog-Frame
PROCEDURE proc-find-code :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter par-next as logical no-undo.
define input parameter pardoc-code as char no-undo.
assign
  pardoc-code = {&double-quote} + pardoc-code + {&double-quote} .

run OpenBr in this-procedure
    (input false /* p-open-query */
    ,input par-next  /* p-find-next  */
    ,input substitute("and buf_c-fin-liab.prn-doc-code = &1 "
      , pardoc-code)
    ).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-view-changes Dialog-Frame
PROCEDURE proc-view-changes :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define buffer new_c-fin-ob for ub.c-fin-ob.
define buffer current_fin-ob for ub.fin-ob.
define variable v-chg-fields as character no-undo.
define variable v-old-fields as character no-undo.
define variable v-new-fields as character no-undo.
define variable ii as integer no-undo.
for each temp-changes:
    delete temp-changes.
END.
if not available buf_c-fin-liab then do:
  Open QUery br-changes for each temp-changes.
  return.
end.

find first new_c-fin-ob no-lock where
            new_c-fin-ob.host-code = buf_c-fin-liab.host-code
       AND new_c-fin-ob.doc-code  = buf_c-fin-liab.doc-code
       AND new_c-fin-ob.chip-num  > buf_c-fin-liab.chip-num no-error.

if not available new_c-fin-ob then do:
    find first current_fin-ob no-lock where
               current_fin-ob.host-code = buf_c-fin-liab.host-code
           AND current_fin-ob.doc-code  = buf_c-fin-liab.doc-code no-error.
         if not available current_fin-ob then do:
         return error.
    end.
    buffer-compare current_fin-ob to buf_c-fin-liab
    save result in v-chg-fields.
end.
else do:
    buffer-compare new_c-fin-ob except chip-num corr-date corr-user-name corr-user-db-num to buf_c-fin-liab
    save result in v-chg-fields.
end.
&scop  disp-field ~
  when "~{&field-name~}":U then do: ~
    create temp-changes. ~
    assign ~
    temp-changes.f_name = "~{&field-name~}":U ~
    temp-changes.l_name = ~{&field-label~} ~
    temp-changes.v_old = string(buf_c-fin-liab.~{&field-name~}) ~
    temp-changes.v_new = (if available new_c-fin-ob  ~
                             then string(new_c-fin-ob.~{&field-name~})  ~
                             else string(current_fin-ob.~{&field-name~})) ~
    . ~
  end. ~

define variable v-nn as integer   no-undo .
v-nn = num-entries(v-chg-fields) .
do ii = 1 to v-nn :
CASE entry(ii, v-chg-fields):


&scop field-name  base-rate
&scop field-label "м-б баз.ва."
{&disp-field}

&scop field-name  base-scale
&scop field-label "шкала баз.вал."
{&disp-field}

&scop field-name  receiver-code
&scop field-label "Код получателя"
{&disp-field}

&scop field-name  receiver-name
&scop field-label "Наименование получателя"
{&disp-field}

&scop field-name  receiver-type
&scop field-label  "Тип получателя"
{&disp-field}

&scop field-name  contract-code
&scop field-label "Номер договора"
{&disp-field}

&scop field-name  curr-code
&scop field-label "Код валюты"
{&disp-field}

&scop field-name  doc-code
&scop field-label "вн Номер фин.об."
{&disp-field}

&scop field-name  doc-date
&scop field-label "Дата создания"
{&disp-field}

&scop field-name  doc-type
&scop field-label "Тип фин.обяз-ва."
{&disp-field}

&scop field-name  exch-rate
&scop field-label "м-б валюты платежа"
{&disp-field}

&scop field-name  exch-scale
&scop field-label "шкала валюты платежа"
{&disp-field}

&scop field-name  fact-date
&scop field-label "Дата факт"
{&disp-field}

&scop field-name  fact-order
&scop field-label "факт-ордер"
{&disp-field}

&scop field-name  host-code
&scop field-label "Код фирмы"
{&disp-field}

&scop field-name  payer-code
&scop field-label "Код плательщика"
{&disp-field}

&scop field-name  payer-name
&scop field-label "Наименование плательщика"
{&disp-field}

&scop field-name  payer-type
&scop field-label "Тип плательщика"
{&disp-field}

&scop field-name  pay-date
&scop field-label "Дата платежа"
{&disp-field}

&scop field-name  prn-doc-code
&scop field-label "Номер фин.обяз"
{&disp-field}


&scop field-name  status_
&scop field-label "Статус"
{&disp-field}

&scop field-name  sum-base-orig
&scop field-label "Сумма в б.в. начальная"
{&disp-field}

&scop field-name  sum-rubl-orig
&scop field-label "Сумма в {&abbr_rub}. начальная"
{&disp-field}


&scop field-name  sum-doc-orig
&scop field-label "Сумма в в.д. начальная"
{&disp-field}


&scop field-name  sum-base
&scop field-label "Сумма в б.в. "
{&disp-field}

&scop field-name  sum-doc
&scop field-label "Сумма в в.д."
{&disp-field}

&scop field-name  sum-rubl
&scop field-label "Сумма в {&abbr_rub}."
{&disp-field}

&scop field-name  sum-contract
&scop field-label "Сумма в в.дог."
{&disp-field}


&scop field-name  sum-tax-doc
&scop field-label "Сумма налогов в в.д."
{&disp-field}

&scop field-name  sum-tax-base
&scop field-label "Сумма налогов в б.в. "
{&disp-field}


&scop field-name  sum-tax-rubl
&scop field-label "Сумма налога в {&abbr_rub}."
{&disp-field}

&scop field-name  sum-tax-contract
&scop field-label "Сумма налога в в.дог."
{&disp-field}

&scop field-name  corr-doc
&scop field-label "Корр ФО"
{&disp-field}


&scop field-name  trn-doc-code
&scop field-label "№ складского документа"
{&disp-field}
END CASE.
end.
Open QUery br-changes for each temp-changes.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE set-filter-name Dialog-Frame
PROCEDURE set-filter-name :
define input parameter p-filter-name as character no-undo .

  do with frame {&frame-name}:
    if p-filter-name > "" then do:
      assign
        frame {&frame-name}:title
          = frame {&frame-name}:title + "   ФИЛЬТР: " + p-filter-name.
      .
      assign
        b-sch :TOOLTIP = "Установлен фильтр " + p-filter-name
      .
    end.
    else do:
      assign
        b-sch :TOOLTIP = ""
      .
    end.

  end. /* do with frame */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Implementations ***************** */


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION sel-abbr Dialog-Frame
FUNCTION sel-abbr RETURNS CHARACTER
 ( p-curr-code as int ) :
  define variable rr as character no-undo .
  find first currency no-lock where  currency.curr-code  = p-curr-code no-error.
  rr = currency.curr-abbr .
  RETURN rr.
END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION val-abbr-type Dialog-Frame
FUNCTION val-abbr-type RETURNS CHARACTER
( input p-rec as recid ) :
define  BUFFER loc-fin-liab FOR c-fin-ob .
find first loc-fin-liab no-lock where recid (loc-fin-liab) = p-rec no-error .
if error-status :error then return '' .

  define variable rr as character no-undo .
     find first currency no-lock where  currency.curr-code  = loc-fin-liab.curr-code no-error.
/*      if error-status then return "". */
  rr = currency.curr-abbr .
if available currency then  rr = currency.curr-abbr .
else rr = ""   .

  RETURN rr.
END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME