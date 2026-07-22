&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER X_order FOR ub.order-doc.
DEFINE BUFFER X_order-line FOR ub.order-line.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*------------------------------------------------------------------------

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Карточка заказа

Автор: Шкляр Елена
Дата создания: 20/04/95
Author: Shklyar Elena
Creation date: 20/04/95
------------------------------------------------------------------------*/
/*          This .W file was created with the Progress AppBuilder.       */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter  parparentproc as widget-handle no-undo .
define input parameter p-doc-code as integer no-undo .
define input parameter par-mode as character no-undo .



define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Карточка заказа".

/*{ cmp/vssrevis.i }        */
{ cmp/str-glbl.i  }
{ cmp/library.i }
{ cmp/mrk-strf.i }
{ gbl/sel-date.i }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
{ rep/tt-date.i }
{ gbl/color.i }


/* Local Variable Definitions ---                                       */
define variable v-rid-list    as character no-undo .
define variable row_order     as rowid     no-undo .
define variable recid_order   as integer   no-undo .
define variable ii            as integer   no-undo .
define variable recid_line    as integer   no-undo .
define variable varschartic   as character initial " " no-undo.
define variable ref-list      as character no-undo.
define variable contract-code as character no-undo .
define variable gds-rec       as integer   no-undo .
define variable title0         as character no-undo .
define variable StatusOrder   as class     ibs.th.str.order.sts.order no-undo .

define variable bcol          as handle    extent no-undo.
define variable hBrowse       as handle    no-undo.
define variable vUndo         as logical   no-undo init no.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br-line

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_order-line X_order

/* Definitions for BROWSE br-line                                      */
&Scoped-define FIELDS-IN-QUERY-br-line X_order-line.gds-code ~
X_order-line.artic X_order-line.order-qnty X_order-line.price ~
X_order-line.order-amount 
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-line X_order-line.order-qnty 
&Scoped-define QUERY-STRING-br-line FOR EACH X_order-line no-lock where X_order-line.doc-code = p-doc-code INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-br-line OPEN QUERY br-line FOR EACH X_order-line no-lock where X_order-line.doc-code = p-doc-code INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-br-line X_order-line
&Scoped-define FIRST-TABLE-IN-QUERY-br-line X_order-line


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-br-line}



/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS X_order.order-date ~
v-doc-date X_order.cli-code X_order.cli-type X_order.cli-name ~
X_order.user-id 
&Scoped-define ENABLED-TABLES X_order
&Scoped-define FIRST-ENABLED-TABLE X_order
&Scoped-Define ENABLED-OBJECTS b-save b-prev b-next b-send b-cancel ~
v-contract r-user b-mark b-add b-chg b-del br-line user-name b-hist
&Scoped-Define DISPLAYED-FIELDS X_order.order-item X_order.order-date ~
v-doc-date X_order.cli-code X_order.cli-type X_order.cli-name ~
X_order.order-date 
&Scoped-define DISPLAYED-TABLES X_order
&Scoped-define FIRST-DISPLAYED-TABLE X_order
&Scoped-Define DISPLAYED-OBJECTS v-contract c-status user-name

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD gds-name Dialog-Frame 
FUNCTION gds-name RETURNS character
    (p-code as integer ) FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD stock Dialog-Frame 
FUNCTION stock RETURNS character
    (p-code as integer ) FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-add 
     LABEL "&Добавить" 
     SIZE 10 BY 1.

DEFINE BUTTON b-cancel AUTO-GO
     LABEL "Выход" 
     SIZE 10 BY 1.

DEFINE BUTTON b-date 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "" 
     SIZE 3 BY .88.

DEFINE BUTTON b-del 
     LABEL "&Удалить" 
     SIZE 10 BY 1.

DEFINE BUTTON b-excel 
     LABEL "Печать" 
     SIZE 10 BY 1.

DEFINE BUTTON b-hist 
     IMAGE-UP FILE "cmp/b-hist.bmp":U
     IMAGE-DOWN FILE "cmp/b-hist.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/b-hist.bmp":U NO-CONVERT-3D-COLORS
     LABEL "&История" 
     SIZE 3 BY 1.

DEFINE BUTTON b-mark 
     LABEL "&*" 
     SIZE 3 BY 1.

DEFINE BUTTON b-next AUTO-GO 
     LABEL "&>>" 
     SIZE 3 BY 1.

DEFINE BUTTON b-notOk 
     LABEL "&Отклонить" 
     SIZE 10 BY 1.

DEFINE BUTTON b-ok 
     LABEL "&Принять" 
     SIZE 10 BY 1.

DEFINE BUTTON b-prev AUTO-GO 
     LABEL "&<<" 
     SIZE 3 BY 1.

DEFINE BUTTON b-save AUTO-GO 
     LABEL "Ввод" 
     SIZE 10 BY 1.

DEFINE BUTTON b-send AUTO-GO 
     LABEL "Отправить" 
     SIZE 10 BY 1.

DEFINE VARIABLE c-status AS CHARACTER FORMAT "X(256)":U 
     LABEL "Статус" 
     VIEW-AS FILL-IN 
     SIZE 44.5 BY 1 NO-UNDO.

DEFINE VARIABLE contract-name AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 72.5 BY 1 NO-UNDO.

DEFINE VARIABLE user-name AS CHARACTER FORMAT "x(256)":U 
     LABEL "Исполнитель" 
     VIEW-AS FILL-IN 
     SIZE 38 BY 1 NO-UNDO.

DEFINE VARIABLE v-doc-code AS CHARACTER FORMAT "X(16)":U 
     LABEL "Номер заказа" 
     VIEW-AS FILL-IN 
     SIZE 29.63 BY 1 NO-UNDO.

DEFINE VARIABLE v-doc-date AS date FORMAT "99/99/9999":U 
          LABEL "Дата создания"
          VIEW-AS FILL-IN 
          SIZE 20 BY 1 NO-UNDO.
     
/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-line FOR 
      X_order-line SCROLLING.

&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-line
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-line Dialog-Frame _STRUCTURED
    QUERY br-line exclusive-lock DISPLAY
    mark-string( input recid(X_order-line), input v-rid-list) column-label "*" format "X(1)":U
    X_order-line.gds-code column-label "Код" FORMAT "9999999999":U
    X_order-line.artic column-label "Артикул" FORMAT "x(16)":U
    gds-name(X_order-line.gds-code) column-label "Наименование" format "X(256)":U WIDTH 50
    X_order-line.order-qnty column-label "Заказ " FORMAT "->>>>>>>>9":U
    X_order-line.fact-qnty column-label "Подтвержденное!количество" FORMAT "->>>>>>>>9":U
    /*    X_order-line.price column-label "Цена" FORMAT "->>>,>>9.99":U                                                   */
    /*    stoim(input X_order-line.order-qnty, input X_order-line.price) column-label "Стоимость" FORMAT "->>>>>,>>9.99":U*/
    X_order-line.rest column-label "Остаток!товара" 
    X_order-line.sales column-label "Продажи за!период"
    X_order-line.average-sales column-label "Среднесуточные!продажи за!период"  
    stock(X_order-line.stock-goods) column-label "Запас!товара"
    X_order-line.volume-goods  column-label "Расчетный объем!заказа с учетом!темпа продаж"
    X_order-line.volume-stock  column-label "Расчетный объем!заказа с учетом!миним. запаса"
    X_order-line.min-stock column-label "Минимальный!запас"    
    X_order-line.garant-stock  column-label "Гарантийный!запас"
    X_order-line.promo     column-label "Товар!участвует в!промоакции"
    
  ENABLE
      X_order-line.order-qnty

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 131 BY 18 fit-last-column.

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-save AT ROW 1 COL 1 WIDGET-ID 2
     b-prev AT ROW 1 COL 11 WIDGET-ID 4
     b-send AT ROW 1 COL 11 WIDGET-ID 8
     b-next AT ROW 1 COL 14 WIDGET-ID 6
     b-excel AT ROW 1 COL 21 WIDGET-ID 208
     b-cancel AT ROW 1 COL 31 WIDGET-ID 10
     b-hist AT ROW 1 COL 128.5 WIDGET-ID 18
     v-doc-code AT ROW 2.33 COL 14.38 COLON-ALIGNED WIDGET-ID 204
     v-doc-date AT ROW 2.33 COL 91.5 COLON-ALIGNED WIDGET-ID 16
     X_order.cli-code AT ROW 3.58 COL 14.38 COLON-ALIGNED WIDGET-ID 18
          LABEL "Поставщик"
          VIEW-AS FILL-IN 
          SIZE 10 BY 1
     X_order.cli-type AT ROW 3.58 COL 22.88 COLON-ALIGNED NO-LABEL WIDGET-ID 20
          VIEW-AS FILL-IN 
          SIZE 4 BY 1
     X_order.cli-name AT ROW 3.58 COL 27.25 COLON-ALIGNED NO-LABEL WIDGET-ID 22
          VIEW-AS FILL-IN 
          SIZE 44.25 BY 1
     X_order.order-date AT ROW 3.58 COL 91.5 COLON-ALIGNED WIDGET-ID 14
          LABEL "Дата поставки"
          VIEW-AS FILL-IN 
          SIZE 11.5 BY 1
     b-date AT ROW 3.63 COL 105 WIDGET-ID 202
     X_order.contract-prn-code AT ROW 4.83 COL 14.38 COLON-ALIGNED WIDGET-ID 24
          LABEL "Договор"
          VIEW-AS FILL-IN 
          SIZE 24 BY 1
     X_order.contract-code AT ROW 4.83 COL 44.88 COLON-ALIGNED WIDGET-ID 264
          LABEL "Вн.№"
          VIEW-AS FILL-IN 
          SIZE 11 BY 1
     contract-name AT ROW 4.83 COL 57 COLON-ALIGNED NO-LABEL WIDGET-ID 266
     c-status AT ROW 6.08 COL 14.38 COLON-ALIGNED WIDGET-ID 206
     user-name AT ROW 6.08 COL 91.5 COLON-ALIGNED WIDGET-ID 28
     X_order.info AT ROW 7.25 COL 16.38 NO-LABEL WIDGET-ID 260
          VIEW-AS EDITOR NO-WORD-WRAP MAX-CHARS 1000 SCROLLBAR-HORIZONTAL SCROLLBAR-VERTICAL
          SIZE 115.13 BY 2.29
     b-mark AT ROW 9.75 COL 1 WIDGET-ID 34
     b-add AT ROW 9.75 COL 4 WIDGET-ID 36
     b-del AT ROW 9.75 COL 14 WIDGET-ID 40
     b-ok AT ROW 9.75 COL 24 WIDGET-ID 254
     b-notOk AT ROW 9.75 COL 34 WIDGET-ID 256
     br-line AT ROW 10.75 COL 1 WIDGET-ID 200
     "Внимание! Справочные данные рассчитаны на момент создания заказа" VIEW-AS TEXT
          SIZE 76.5 BY .67 AT ROW 9.92 COL 40.25 WIDGET-ID 268
          FGCOLOR 12 
     "Информация:" VIEW-AS TEXT
          SIZE 11 BY .67 AT ROW 7.33 COL 4.25 WIDGET-ID 262
     SPACE(116.99) SKIP(20.82)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "" WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   Allow: Basic,Browse,DB-Fields,Query
   Other Settings: COMPILE
   Temp-Tables and Buffers:
      TABLE: X_order T "?" NO-UNDO ub order-doc
      TABLE: X_order-line B "?" ? ub order-line
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB br-line b-notOk Dialog-Frame */
ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN 
       br-line:COLUMN-RESIZABLE IN FRAME Dialog-Frame       = TRUE.

/* SETTINGS FOR FILL-IN X_order.cli-code IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN X_order.contract-code IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN contract-name IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN X_order.contract-prn-code IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN X_order.doc-date IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR EDITOR order-doc.info IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN X_order.order-date IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-line
/* Query rebuild information for BROWSE br-line
     _TblList          = "X_order-line OF Temp-Tables.X_order"
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _FldNameList[1]   = Temp-Tables.X_order.amount
     _FldNameList[2]   = Temp-Tables.X_order.cli-code
     _FldNameList[3]   = Temp-Tables.X_order.cli-name
     _FldNameList[4]   = Temp-Tables.X_order.cli-type
     _FldNameList[5]   = Temp-Tables.X_order.contract-code
     _FldNameList[6]   = Temp-Tables.X_order.contract-prn-code
     _FldNameList[7]   = Temp-Tables.X_order.db-num
     _FldNameList[8]   = Temp-Tables.X_order.doc-code
     _FldNameList[9]   = Temp-Tables.X_order.doc-date
     _FldNameList[10]   = Temp-Tables.X_order.edi-item
     _FldNameList[11]   = Temp-Tables.X_order.obj-code
     _FldNameList[12]   = Temp-Tables.X_order.obj-type
     _FldNameList[13]   = Temp-Tables.X_order.order-date
     _FldNameList[14]   = Temp-Tables.X_order.params
     _FldNameList[15]   = Temp-Tables.X_order.sts
     _Query            is OPENED
*/  /* BROWSE br-line */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _TblList          = "Temp-Tables.X_order"
     _Options          = "SHARE-LOCK"
     _FldNameList[1]   > Temp-Tables.tt-order-line.mark
"tt-order-line.mark" "*" "x(1)" "character" ? ? ? ? ? ? no ? no no "2" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[2]   > Temp-Tables.tt-order-line.line-num
"tt-order-line.line-num" "№" ? "integer" ? ? ? ? ? ? no ? no no "4.5" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[3]   > Temp-Tables.tt-order-line.gds-code
"tt-order-line.gds-code" "Код" ? "integer" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[4]   > Temp-Tables.tt-order-line.artic
"tt-order-line.artic" "Артикль" ? "character" ? ? ? ? ? ? no ? no no "13" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[5]   > Temp-Tables.tt-order-line.gds-name
"tt-order-line.gds-name" "Наименование" "X(256)" "integer" ? ? ? ? ? ? no ? no no "38.5" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[6]   > Temp-Tables.tt-order-line.order-qnty
"tt-order-line.order-qnty" "Кол-во" ? "decimal" ? ? ? ? ? ? yes ? no no "9" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[7]   > Temp-Tables.tt-order-line.price
"tt-order-line.price" ? ? "decimal" ? ? ? ? ? ? no ? no no "10.5" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[8]   > Temp-Tables.tt-order-line.total
"tt-order-line.total" "Стоимость" ? "decimal" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _Query            is OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
        apply "choose":U to b-cancel in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-add Dialog-Frame
ON CHOOSE OF b-add IN FRAME Dialog-Frame /* Добавить */
DO:
        define buffer bf_order-line  for ub.order-line .
        define buffer buF_order-line for ub.order-line .
        define variable line-num as integer no-undo .
  
        empty temp-table gds-list .
        empty temp-table tt-gds-list .
        
        for each buF_order-line no-lock where buF_order-line.doc-code = p-doc-code:
            create tt-gds-list .
            assign
                tt-gds-list.artic     = buF_order-line.artic
                tt-gds-list.gds-code  = buF_order-line.gds-code
                tt-gds-list.prod-code = buF_order-line.prod-code
                tt-gds-list.prod-type = buF_order-line.prod-type
                .
        end.
        RUN str/order_choose.w (
            input  parparentproc,
            input  "b-mark,b-sel",
            input  v-cntxt-host-code-obj,
            input  X_order.contract-code,
            input integer(''),
            input  X_order.params,
            input X_order.doc-code,
            input X_order.db-num,
            input table tt-gds-list,
            output table gds-list
            ).   
            
        find last bf_order-line no-lock where bf_order-line.doc-code = X_order.doc-code no-error .
        if available (bf_order-line) then line-num = bf_order-line.line-num . 
        for each gds-list:
            find first buf_order-line no-lock where buf_order-line.gds-code = gds-list.gds-code 
                and buf_order-line.doc-code = X_order.doc-code no-error .
            if not available (buf_order-line) then 
            do:
                line-num = line-num + 1 .
                create buf_order-line .
                assign
                    buf_order-line.doc-code   = X_order.doc-code
                    buf_order-line.db-num     = X_order.db-num
                    buf_order-line.line-num   = line-num
                    buf_order-line.artic      = gds-list.artic
                    buf_order-line.order-qnty = gds-list.doc-qnty
                    buf_order-line.gds-code   = gds-list.gds-code
                    buf_order-line.prod-code  = gds-list.prod-code
                    buf_order-line.prod-type  = gds-list.prod-type
                    .
            end.
        end.  

        {&OPEN-QUERY-br-line}
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-cancel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-cancel Dialog-Frame
ON CHOOSE OF b-cancel IN FRAME Dialog-Frame /* Отмена */
DO:
        define variable p-ok as logical no-undo .

        find first X_order-line no-lock where X_order-line.db-num = X_order.db-num and X_order-line.doc-code = X_order.doc-code no-error .
        if not available (X_order-line) then do:
         message "Вы уверены, что хотите закрыть заказ без сохранения?" skip
                 "Пустой заказ будет удален"
         view-as alert-box question buttons yes-no update p-ok.
         if p-ok then do:
         delete X_order .
         end.
         else return no-apply .
        end.
        vUndo = yes.
        return.
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-date
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-date Dialog-Frame
ON CHOOSE OF b-date IN FRAME Dialog-Frame
DO:
        if par-mode <> {&lookup} then 
        do:
            run sel-date in this-procedure
                (input X_order.order-date :handle
                ,input ""
                ) .

            if date(X_order.order-date:screen-value) < today then 
            do:
                message "Дата заказа должна быть равна или больше текущей"
                    view-as alert-box.
                display X_order.order-date with frame Dialog-Frame .
                return no-apply .
            end.   
            assign X_order.order-date .
        end.
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-del Dialog-Frame
ON CHOOSE OF b-del IN FRAME Dialog-Frame /* Удалить */
DO:
        define variable ii as integer no-undo .
        define buffer bf_order-line for ub.order-line .
        define variable recid_line as integer no-undo init ?.
        
        if v-rid-list = "" then 
        do:
            if available (X_order-line) then 
            do:
                ii = X_order-line.line-num .
                delete X_order-line .
            end. 
            find first X_order-line where X_order-line.doc-code = X_order.doc-code and
            X_order-line.db-num = X_order.db-num and X_order-line.line-num > ii no-error .
            if available (X_order-line) then do:
                recid_line = recid(X_order-line) .
            end.       
        end.
        else 
        do:
            do ii = 0 to num-entries (v-rid-list):
                find first bf_order-line exclusive-lock where recid(bf_order-line) = integer(entry (ii,v-rid-list)) no-error .
                if available (bf_order-line) then 
                do:
                    delete bf_order-line .
                end.
            end.
        end.    
         {&OPEN-QUERY-br-line}
        if recid_line <> ? then reposition br-line to recid recid_line no-error .    
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-excel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-excel Dialog-Frame
ON CHOOSE OF b-excel IN FRAME Dialog-Frame /* Печать */
DO:
        define variable Log-Res as logical no-undo .

            { gbl/chk-actg.i
                  v-cntxt-db-num
                  v-cntxt-userid
                  {&action-head-code-main}
                  'actn_pmnt-ord-doc_lookup':U
                  {&cntxt-object}
                  v-cntxt-host-code-obj
                  v-cntxt-obj-type
                  v-cntxt-obj-code
                  0
                  0
                  0
                  true
                  log-res
                }  
            if not log-res then return no-apply .    
        run rep/r-order.p(input parparentproc,
            input X_order.doc-code,
            input X_order.db-num,
            input X_order.params)  .
            
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-hist
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-hist Dialog-Frame
ON CHOOSE OF b-hist IN FRAME Dialog-Frame /* История */
DO:
        define variable v-rid-list as character no-undo.
        if available (X_order) then
        do:
            row_order = rowid (X_order) .
            run ref/cordhist.w (
                X_order.db-num,
                X_order.doc-code,
                parparentproc,
                0,
                "",
                0,
                "",
                "one",
                ?,
                "",
                "" ,
                v-cntxt-db-num,
                ?,
                input-output v-rid-list ) .
        end.

    /*    run rep/r-orderHist.p(input parparentproc,*/
    /*    input X_order.doc-code,                   */
    /*    input X_order.db-num)  .                  */
    
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-mark Dialog-Frame
ON CHOOSE OF b-mark IN FRAME Dialog-Frame /* * */
DO:
        define variable loc#log as logical no-undo .
      
        if available X_order-line then 
        do:
            { gbl/markstrn.i X_order-line v-rid-list }
            row_order = rowid(X_order-line).
            loc#log = {&browse-name}:refresh() .
            reposition br-line to rowid row_order.

            if last-event:function <> "MOUSE-SELECT-DBLCLICK" then 
            do:
                loc#log = {&browse-name}:select-next-row ().
                apply "VALUE-CHANGED" to {&browse-name} in frame {&frame-name}.
            end.
        end.
        apply "entry" to {&browse-name} in frame {&frame-name}.

    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-next
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-next Dialog-Frame
ON CHOOSE OF b-next IN FRAME Dialog-Frame /* >> */
DO:
        assign .
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-prev
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-prev Dialog-Frame
ON CHOOSE OF b-prev IN FRAME Dialog-Frame /* << */
DO:
        assign .
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-save
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-save Dialog-Frame
ON CHOOSE OF b-save IN FRAME Dialog-Frame /* Выход */
DO:
    define variable p-ok as logical no-undo .
    find first X_order-line no-lock where X_order-line.db-num = X_order.db-num and X_order-line.doc-code = X_order.doc-code no-error .
        if not available (X_order-line) then do:
         message "Вы уверены, что хотите закрыть заказ?" skip
                 "Пустой заказ будет удален"
         view-as alert-box question buttons yes-no update p-ok.
         if p-ok then do:
         delete X_order .
         return .
         end.
         else return no-apply .
        end.
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-send
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-send Dialog-Frame
ON CHOOSE OF b-send IN FRAME Dialog-Frame /* Отправить */
DO:
        define variable p-ok as logical no-undo .
        find first X_order-line no-lock where X_order-line.doc-code = X_order.doc-code and 
        X_order-line.db-num = X_order.db-num no-error .
        if not available (X_order-line) then do:
            message "Нельзя отправить заказ, т.к. нет товаров по нему"
            view-as alert-box.
            return no-apply .
        end.
        find first X_order-line no-lock where X_order-line.doc-code = X_order.doc-code and 
        X_order-line.db-num = X_order.db-num and X_order-line.order-qnty <= 0 no-error .
        if not available (X_order-line) then 
        do:
            message "Вы уверены, что хотите отправить заказ поставщику?"
                view-as alert-box question buttons yes-no update p-ok.      
            if p-ok then 
            do:          
                run bge\send1cerp.p (parparentproc,
                    this-procedure,
                    this-procedure,
                    "order",
                    (buffer X_order:handle),
                    ?,                       
                    ?) no-error.
                if  error-status:error then 
                do: 
                    message return-value
                        view-as alert-box.  
                    return .
                end.
                X_order.sts = StatusOrder:Sended:KeyIntDB .
                run init_tt . 
            end.
        end.
        else 
        do:
            message "Количество товара в заказе не может быть отрицательным или равным нулю"
            view-as alert-box .
            return no-apply .    
        end.

            
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-line
&Scoped-define SELF-NAME br-line
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-line Dialog-Frame
ON ROW-DISPLAY OF br-line IN FRAME Dialog-Frame
DO:
        if  X_order-line.order-qnty <= 0 then 
        do:
      
            do ii = 1 to extent (bcol):  
                if valid-handle (bcol[ii]) 
                    then 
                do:
                    assign
                        bcol[ii]:fgcolor = red_COLOR.
                end.
            end.
        end.   
        if X_order.sts <> StatusOrder:NewStatus:KeyIntDB and 
           X_order.sts <> StatusOrder:Sended:KeyIntDB then 
        do:
        if  X_order-line.order-qnty <> X_order-line.fact-qnty then 
        do:
      
            do ii = 1 to extent (bcol):  
                if valid-handle (bcol[ii]) 
                    then 
                do:
                    assign
                        bcol[ii]:fgcolor = red_COLOR.
                end.
            end.
        end.            
        end.          
    END .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-line Dialog-Frame
ON row-leave OF br-line IN FRAME Dialog-Frame
DO:
        find current X_order-line exclusive-lock. 
        
        assign
            browse br-line X_order-line.order-qnty 
            .  
            if X_order-line.order-qnty = ? then do:
                return no-apply .
            end.
            X_order-line.fact-qnty = X_order-line.order-qnty .
        find current X_order-line no-lock. 

        br-line:refresh ().
        apply "ROW-DISPLAY" to br-line IN FRAME Dialog-Frame.
    end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME X_order.order-date
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL X_order.order-date Dialog-Frame
ON LEAVE OF X_order.order-date IN FRAME Dialog-Frame /* Дата поставки */
DO:
        apply "TAB":U to self .
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL X_order.order-date Dialog-Frame
ON RETURN OF X_order.order-date IN FRAME Dialog-Frame /* Дата поставки */
DO:
        apply "TAB":U to self .
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL X_order.order-date Dialog-Frame
ON TAB OF X_order.order-date IN FRAME Dialog-Frame /* Дата поставки */
DO:
        date(X_order.order-date:screen-value) no-error.
        if error-status:error then 
        do:
            message "Ошибка ввода даты"
                view-as alert-box.  
            display X_order.order-date with frame Dialog-Frame .
            return no-apply .          
        end.    
        if string(X_order.order-date) <> X_order.order-date:screen-value then 
        do:
            if date(X_order.order-date:screen-value) < today then 
            do:
                message "Дата заказа должна быть равна или больше текущей"
                    view-as alert-box.
                display X_order.order-date with frame Dialog-Frame .
                return no-apply.
            end. 
            assign X_order.order-date .
            display X_order.order-date with frame Dialog-Frame .
        end.
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame 


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
    THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
    ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
    { gbl/ed_date.i v-doc-date }
        { gbl/brwrepos.i
  &line-num= 12
}

StatusOrder =  new ibs.th.str.order.sts.order().
if par-mode = {&lookup} then find first X_order no-lock where X_order.doc-code = p-doc-code no-error .    
else find first X_order exclusive-lock where X_order.doc-code = p-doc-code no-error .   

v-doc-date = X_order.doc-date .
 
extent (bcol) = ?.
hbrowse = browse {&BROWSE-NAME}:handle.
extent (bcol) = hbrowse:num-columns.
bcol[1] = hbrowse:first-column.
do ii = 1 to extent (bcol).  
    bcol[ii] = hbrowse:get-browse-column (ii).
end.
if X_order.order-item <> "" then title0 = "Заказ № " + string(X_order.order-item).  
else title0 = "Заказ". 
run init_tt .
RUN enable_UI .
run enable_tt .
frame {&frame-name}:title = title0 .
   on F9 of frame {&frame-name} anywhere 
      do:
         if not available X_order-line then  return no-apply.
         find first goods no-lock where goods.gds-code = X_order-line.gds-code .
         gds-rec = recid(goods) .
         run ref/gds-form.w
            (input  parParentProc
            ,input  {&lookup}
            ,input  v-cntxt-obj-type
            ,input  v-cntxt-obj-code
            ,input ? /*p-call-handle*/
            ,input-output gds-rec
            ).

         apply "entry" to br-line in frame {&frame-name}.
         return no-apply.
      end.
      
WAIT-FOR GO OF FRAME {&FRAME-NAME} .
if vUndo then
  UNDO MAIN-BLOCK, LEAVE.
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_tt Dialog-Frame  _DEFAULT-ENABLE
PROCEDURE enable_tt :
    if par-mode = {&lookup} or X_order.sts <> StatusOrder:NewStatus:KeyIntDB then 
    do:
        disable
            b-add
            b-del
            b-date
            v-doc-date
            b-send
/*            b-cancel*/
            X_order.order-date
            with frame Dialog-Frame .
            X_order-line.order-qnty:column-read-only in browse br-line = true .
    end.

    if X_order.sts = StatusOrder:NewStatus:KeyIntDB or X_order.sts = StatusOrder:Sended:KeyIntDB or X_order.sts = StatusOrder:Cancelled:KeyIntDB then
    X_order-line.fact-qnty:visible IN BROWSE br-line = false.
    else X_order-line.fact-qnty:visible IN BROWSE br-line = true.

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
    {&OPEN-QUERY-Dialog-Frame}
    DISPLAY c-status user-name 
        WITH FRAME Dialog-Frame.
    IF AVAILABLE X_order THEN 
        DISPLAY X_order.doc-code v-doc-date X_order.cli-code 
            X_order.cli-type X_order.cli-name X_order.order-date user-name contract-name
            v-doc-code X_order.info X_order.contract-code X_order.contract-prn-code
            WITH FRAME Dialog-Frame.
    ENABLE b-save b-send b-next b-excel X_order.order-date b-date 
        b-mark b-add b-del br-line b-hist b-cancel  
        WITH FRAME Dialog-Frame.
    hide b-prev b-next b-prev b-next b-ok b-notOk in frame Dialog-Frame .
    VIEW FRAME Dialog-Frame.
    {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init_tt Dialog-Frame  _DEFAULT-ENABLE
PROCEDURE init_tt :
    v-doc-code = string(X_order.order-item) .
    find first ub.contract no-lock where ub.contract.contract-code = X_order.contract-code no-error .
    if available (ub.contract) then contract-name = ub.contract.contract-name .
    if X_order.user-id <> '' then 
    do:
        find first ub.user-account no-lock where ub.user-account.user-id = X_order.user-id no-error .
        if available (ub.user-account) then 
        do:
            user-name = ub.user-account.last-name + " " + ub.user-account.first-name + " " + ub.user-account.second-name .
        end.
    end.
    
    c-status = StatusOrder:GetLabel(X_order.sts) .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION gds-name Dialog-Frame 
FUNCTION gds-name RETURNS character
    (p-code as integer ):
  
    define variable v-gds-name as character no-undo.
    find first ub.goods no-lock where ub.goods.gds-code = p-code no-error .
    if available (ub.goods) then 
    do:
        v-gds-name = ub.goods.gds-name .
    end.
    return v-gds-name.
  
end function.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION stock Dialog-Frame 
FUNCTION stock RETURNS character
    (p-code as integer ):
    define variable stock-code as character no-undo.
    if p-code = -1 then stock-code = "-" .
    else stock-code = string (p-code) .
    return stock-code.
  
end function.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

