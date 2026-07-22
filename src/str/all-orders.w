&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME d-order


/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE X_order NO-UNDO LIKE order-doc.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS d-order 
/*------------------------------------------------------------------------

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Список заказов

Автор: Шкляр Елена
Дата создания: 20/04/95
Author: Shklyar Elena
Creation date: 20/04/95

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress AppBuilder.       */
/*----------------------------------------------------------------------*/


/* ***************************  Definitions  ************************** */
{ rep/tt-date.i }
/* Parameters Definitions ---                                           */
define input parameter  parparentproc as widget-handle no-undo .
define input parameter p-mode as character no-undo .
define output parameter rec-order as character no-undo .


define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Список Заказов".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i  }
{ cmp/library.i }
{ cmp/showinf.i }
{ gbl/waitfram.i }
{ cmp/mrk-strf.i }
{ gbl/color.i }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
{ gbl/sel-date.i }
{ rep/tt-zakaz.i new }
{ str/edo.i }
/* Local Variable Definitions ---                                       */
define variable v-rid-list      as character no-undo .
define variable row_order       as rowid     no-undo .
define variable recid_order     as integer   no-undo .
define variable ii              as integer   no-undo .
define variable v-cli           as logical   no-undo .
define variable filter-point    as character no-undo.
define variable Status_         as character no-undo .
DEFINE buffer buf_order for ub.order-doc.
define buffer buf_goods for ub.goods .
define variable bcol    as handle extent no-undo.
define variable hBrowse as handle no-undo.
define buffer db-attr for ub.db-attr .
define variable StatusOrder as class ibs.th.str.order.sts.order no-undo .
{ rep/crt-orderLine.i }

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME d-order
&Scoped-define BROWSE-NAME br-order

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_order

/* Definitions for BROWSE br-order                                      */
&Scoped-define FIELDS-IN-QUERY-br-order X_order.order-item ~
X_order.order-date X_order.doc-date X_order.cli-code X_order.cli-type ~
X_order.cli-name X_order.order-amount X_order.sts X_order.user-id 
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-order 
&Scoped-define QUERY-STRING-br-order FOR EACH X_order NO-LOCK by X_order.doc-code desc INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-br-order OPEN QUERY br-order FOR EACH X_order no-lock by X_order.doc-code desc INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-br-order X_order
&Scoped-define FIRST-TABLE-IN-QUERY-br-order X_order


/* Definitions for DIALOG-BOX d-order                                   */
&Scoped-define OPEN-BROWSERS-IN-QUERY-d-order ~
    ~{&OPEN-QUERY-br-order}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS X_order.cli-code X_order.cli-type ~
X_order.cli-name 
&Scoped-define ENABLED-TABLES X_order
&Scoped-define FIRST-ENABLED-TABLE X_order
&Scoped-Define ENABLED-OBJECTS b-exit b-update b-sel b-add b-lookup b-copy ~
b-del b-send b-sch b-help b-hist b-date-Start date-Start Date-End ~
b-date-End c-status cli-code cli-type b-cli cli-name num-order b-mark ~
br-order mark-num 
&Scoped-Define DISPLAYED-OBJECTS date-Start Date-End c-status cli-code ~
cli-type cli-name num-order num-contract r-goods f-mark mark-num 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD num-doc d-order 
FUNCTION num-doc RETURNS character
    (p-doc-code as integer, p-db-num as integer) FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD user-name d-order 
FUNCTION user-name RETURNS character
    (p-user-id as character ) FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-sts d-order 
FUNCTION get-sts RETURNS character
    (p-sts as integer ) FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD cli-name d-order 
FUNCTION cli-name RETURNS character
    (cli-code as integer, cli-type as character ) FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD prep-nameorcode d-order
FUNCTION prep-nameorcode RETURNS CHARACTER
    ( input p-nameorcode as character )  FORWARD.
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

   
/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-add 
    LABEL "&Добавить" 
    SIZE 10 BY 1.

DEFINE BUTTON b-cli 
    IMAGE-UP FILE "btn-down-arrow":U
    IMAGE-DOWN FILE "btn-down-arrow":U
    IMAGE-INSENSITIVE FILE "btn-down-arrow":U
    LABEL "..." 
    SIZE 3.5 BY 1.04.

DEFINE BUTTON b-copy 
    LABEL "&Копия" 
    SIZE 10 BY 1.

DEFINE VARIABLE statusNotif AS LOGICAL INITIAL true 
    LABEL "Уведомления о статусах" 
    VIEW-AS TOGGLE-BOX
    SIZE 27.5 BY 1
    FONT 1 NO-UNDO.
     
DEFINE BUTTON b-date-End 
    IMAGE-UP FILE "btn-down-arrow":U
    IMAGE-DOWN FILE "btn-down-arrow":U
    IMAGE-INSENSITIVE FILE "btn-down-arrow":U
    LABEL "..." 
    SIZE 3.5 BY 1.04.

DEFINE BUTTON b-date-Start 
    IMAGE-UP FILE "btn-down-arrow":U
    IMAGE-DOWN FILE "btn-down-arrow":U
    IMAGE-INSENSITIVE FILE "btn-down-arrow":U
    LABEL "..." 
    SIZE 3.5 BY 1.04.

DEFINE BUTTON b-del 
    LABEL "&Удалить" 
    SIZE 10 BY 1.

DEFINE BUTTON b-exit AUTO-GO 
    LABEL "&Выход" 
    SIZE 10 BY 1.

DEFINE BUTTON b-help 
    LABEL "Помощь":L 
    SIZE 7 BY 1.

DEFINE BUTTON b-hist 
    IMAGE-UP FILE "cmp/b-hist.bmp":U
    IMAGE-DOWN FILE "cmp/b-hist.bmp":U
    IMAGE-INSENSITIVE FILE "cmp/b-hist.bmp":U NO-CONVERT-3D-COLORS
    LABEL "&История" 
    SIZE 3 BY 1.

DEFINE BUTTON b-lookup 
    LABEL "&Просмотр" 
    SIZE 10 BY 1.

DEFINE BUTTON b-mark 
    LABEL "&*" 
    SIZE 3 BY 1.

DEFINE BUTTON b-markGoods 
    LABEL "&Сбросить" 
    SIZE 10 BY 1 TOOLTIP "Сбросить фильтры".

DEFINE BUTTON b-reset 
    LABEL "&Обновить" 
    SIZE 10 BY 1 TOOLTIP "Сбросить фильтры".

DEFINE BUTTON b-sch 
    LABEL "&Фильтр" 
    SIZE 7 BY 1.

DEFINE BUTTON b-sel 
    LABEL "&Выбор" 
    SIZE 10 BY 1.

DEFINE BUTTON b-send 
    LABEL "&Отправить" 
    SIZE 10 BY 1.

DEFINE BUTTON b-update 
    LABEL "&Изменить" 
    SIZE 10 BY 1.

DEFINE BUTTON bt-no-sel-all 
    LABEL "+" 
    SIZE 3 BY 1.

DEFINE BUTTON bt-not-sel-desel-all 
    LABEL "-" 
    SIZE 3 BY 1.

DEFINE VARIABLE c-status     AS CHARACTER FORMAT "X(256)":U INITIAL "0" 
    LABEL "Статус" 
    VIEW-AS COMBO-BOX INNER-LINES 5
    LIST-ITEM-PAIRS "Все","0",
    "Новый","1",
    "Отправлен","2",
    "Подтверждено без изменений","3",
    "Есть изменения","4",
    "Отклонен","5",
    "Ожидает поставку","6",
    "Поставка принята","7",
    "Получено поставщиком","8"
    DROP-DOWN-LIST
    SIZE 32 BY 1 NO-UNDO.

DEFINE VARIABLE cli-code     AS CHARACTER FORMAT "x(20)" 
    LABEL "Поставщик" 
    VIEW-AS FILL-IN 
    SIZE 10.88 BY 1.

DEFINE VARIABLE cli-name     AS CHARACTER FORMAT "x(40)" 
    VIEW-AS FILL-IN 
    SIZE 47 BY 1.

DEFINE VARIABLE cli-type     AS CHARACTER FORMAT "x(3)" 
    VIEW-AS FILL-IN 
    SIZE 4 BY 1.

DEFINE VARIABLE Date-End     AS DATE      FORMAT "99/99/9999":U 
    LABEL "по" 
    VIEW-AS FILL-IN 
    SIZE 10.88 BY 1 NO-UNDO.

DEFINE VARIABLE date-Start   AS DATE      FORMAT "99/99/9999":U 
    LABEL "За период с" 
    VIEW-AS FILL-IN 
    SIZE 10.88 BY 1 NO-UNDO.

DEFINE VARIABLE f-mark       AS CHARACTER FORMAT "X(256)":U 
    VIEW-AS FILL-IN 
    SIZE 56.38 BY 1 NO-UNDO.

DEFINE VARIABLE mark-num     AS INTEGER   FORMAT "->>>9":U INITIAL 0 
    VIEW-AS TEXT 
    SIZE 4 BY 1 NO-UNDO.

DEFINE VARIABLE num-contract AS CHARACTER FORMAT "X(256)":U 
    LABEL "Номер договора" 
    VIEW-AS FILL-IN 
    SIZE 32 BY 1 NO-UNDO.

DEFINE VARIABLE num-order    AS CHARACTER FORMAT "X(256)":U 
    LABEL "Номер заказа" 
    VIEW-AS FILL-IN 
    SIZE 32 BY 1 NO-UNDO.

DEFINE VARIABLE r-goods      AS INTEGER 
    VIEW-AS RADIO-SET HORIZONTAL
    RADIO-BUTTONS 
    "Код товара", 0,
    "Название товара", 1
    SIZE 35 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-order FOR 
    X_order SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-order
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-order d-order _STRUCTURED
    QUERY br-order NO-LOCK DISPLAY
    mark-string( input recid(X_order), input v-rid-list) column-label "*" format "X(1)":U 
    X_order.order-item column-label "№ заказа" FORMAT "X(12)":U width 12
    /*      X_order.edi-item column-label "Номер EDI" FORMAT "x(16)":U width 15*/
    get-sts(X_order.sts) column-label "Статус" FORMAT "X(256)":U width 15
    X_order.order-date column-label "Дата поставки" FORMAT "99/99/9999":U width 15
    X_order.doc-date column-label "Дата создания" FORMAT "99/99/9999":U width 15
    X_order.cli-code column-label "Код пост-ка" format ">>>999":U width 12
    cli-name(X_order.cli-code, X_order.cli-type) column-label "Поставщик" FORMAT "x(256)":U width 30
    X_order.contract-prn-code column-label "Номер договора" FORMAT "x(256)":U width 30
    user-name(X_order.user-id) column-label "Исполнитель" FORMAT "x(256)":U width 30
    X_order.doc-code column-label "№ заказа в ТН" FORMAT ">>>>>>>>>9":U width 15
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 130 BY 23.08 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME d-order
    b-exit AT ROW 1 COL 1.5 WIDGET-ID 4
    b-add AT ROW 1 COL 11.5 WIDGET-ID 28
    b-sel AT ROW 1 COL 11.5 WIDGET-ID 8
    b-update AT ROW 1 COL 21.5 WIDGET-ID 6
    b-lookup AT ROW 1 COL 31.5 WIDGET-ID 10
    b-copy AT ROW 1 COL 41.5 WIDGET-ID 12
    b-del AT ROW 1 COL 51.5 WIDGET-ID 14
    b-send AT ROW 1 COL 61.5 WIDGET-ID 30
    b-reset AT ROW 1 COL 71.5 WIDGET-ID 30
    b-sch AT ROW 1 COL 114 WIDGET-ID 16
    b-help AT ROW 1 COL 121 WIDGET-ID 18
    b-hist AT ROW 1 COL 128 WIDGET-ID 18
    b-date-Start AT ROW 2.46 COL 26.13 WIDGET-ID 252
    date-Start AT ROW 2.5 COL 13.13 COLON-ALIGNED WIDGET-ID 238
    Date-End AT ROW 2.5 COL 32.5 COLON-ALIGNED WIDGET-ID 36
    b-date-End AT ROW 2.5 COL 45.75 WIDGET-ID 250
    c-status AT ROW 2.5 COL 97 COLON-ALIGNED WIDGET-ID 228
    b-cli AT ROW 3.61 COL 26.13 WIDGET-ID 240
    statusNotif AT ROW 1 COL 99 WIDGET-ID 240
    cli-code AT ROW 3.67 COL 13.13 COLON-ALIGNED WIDGET-ID 244
    cli-type AT ROW 3.67 COL 27.75 COLON-ALIGNED NO-LABEL WIDGET-ID 248
    cli-name AT ROW 3.67 COL 80.5 RIGHT-ALIGNED NO-LABEL WIDGET-ID 246
    num-order AT ROW 3.67 COL 97 COLON-ALIGNED WIDGET-ID 254
    num-contract AT ROW 4.79 COL 97 COLON-ALIGNED WIDGET-ID 256
    r-goods AT ROW 4.96 COL 15.38 NO-LABEL WIDGET-ID 260
    bt-no-sel-all AT ROW 6 COL 5 WIDGET-ID 22 NO-TAB-STOP 
    bt-not-sel-desel-all AT ROW 6 COL 8 WIDGET-ID 24 NO-TAB-STOP 
    b-mark AT ROW 6 COL 11 WIDGET-ID 26 NO-TAB-STOP 
    f-mark AT ROW 6 COL 13.13 COLON-ALIGNED NO-LABEL WIDGET-ID 258
    b-markGoods AT ROW 6 COL 71.5 WIDGET-ID 266
    br-order AT ROW 7 COL 1.5 WIDGET-ID 200
    mark-num AT ROW 6 COL 1 NO-LABEL WIDGET-ID 20
    SPACE(127.12) SKIP(23.10)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
    SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
    TITLE "Реестр заказов" WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   Allow: Basic,Browse,DB-Fields,Query
   Other Settings: COMPILE
   Temp-Tables and Buffers:
      TABLE: X_order T "?" NO-UNDO ub order-doc
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX d-order
   FRAME-NAME                                                           */
/* BROWSE-TAB br-order b-markGoods d-order */
ASSIGN 
    FRAME d-order:SCROLLABLE = FALSE
    FRAME d-order:HIDDEN     = TRUE.

ASSIGN 
    br-order:COLUMN-RESIZABLE IN FRAME d-order = TRUE.

/* SETTINGS FOR BUTTON bt-no-sel-all IN FRAME d-order
   NO-ENABLE                                                            */
/* SETTINGS FOR BUTTON bt-not-sel-desel-all IN FRAME d-order
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN cli-name IN FRAME d-order
   ALIGN-R                                                              */
/* SETTINGS FOR FILL-IN mark-num IN FRAME d-order
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-order
/* Query rebuild information for BROWSE br-order
     _TblList          = "Temp-Tables.X_order"
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _FldNameList[1]   = Temp-Tables.X_order.cli-name
     _FldNameList[2]   = Temp-Tables.X_order.cli-type
     _FldNameList[3]   = Temp-Tables.X_order.contract-code
     _FldNameList[4]   = Temp-Tables.X_order.contract-prn-code
     _Query            is OPENED
*/  /* BROWSE br-order */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME d-order
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL d-order d-order
ON WINDOW-CLOSE OF FRAME d-order /* Список заказов */
    DO:
        APPLY "END-ERROR":U TO SELF.
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-add d-order
ON CHOOSE OF b-add IN FRAME d-order /* Добавить */
    DO:
        define variable varlog as logical no-undo .
        { gbl/chk-actg.i
                  v-cntxt-db-num
                  v-cntxt-userid
                  {&action-head-code-main}
                  'actn_pmnt-ord-doc_add-def':U
                  {&cntxt-object}
                  v-cntxt-host-code-obj
                  v-cntxt-obj-type
                  v-cntxt-obj-code
                  0
                  0
                  0
                  true
                  varlog
                } 
        if not varlog then return no-apply .         
        run rep/g-rsrvPlan.p (parparentproc, yes) no-error . 
        run init-sort .
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-cli
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-cli d-order
ON CHOOSE OF b-cli IN FRAME d-order /* ... */
    DO:
        define variable v-types   as character no-undo .
        define variable ref-list  as character no-undo .
        define variable ref-rec   as integer   no-undo .
        def    var      supp-type as character no-undo.

        run ref/cli-all.w (parparentproc
            , "b-sel,b-add"
            , ?
            , ?
            , ?
            , ?
            , ?
            , ?
            , output ref-list) .

        if ref-list <> "" then 
        do:
            ref-rec = integer (ref-list).
            find ub.clients where recid ( ub.clients ) = ref-rec no-lock.
            assign
                cli-code = string(ub.clients.obj-code)
                cli-type = ub.clients.obj-type
                cli-name = ub.clients.obj-name
                .
            display cli-code with frame {&frame-name}.
            display ub.clients.obj-type @ cli-type with frame {&frame-name}.
            display ub.clients.obj-name @ cli-name with frame {&frame-name} . 
            v-cli = true .
            run init-sort .
        end.
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-copy
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-copy d-order
ON CHOOSE OF b-copy IN FRAME d-order /* Копия */
    DO:
        define variable Log-Res as logical no-undo .
        define buffer bf_order           for ub.order-doc .
        define buffer bf_order-line      for ub.order-line .
        define buffer bf_order-attr      for ub.order-doc-attr .
        define buffer bf_order-line-attr for ub.order-line-attr .
        define buffer buf_X_order        for X_order.

        if num-entries(v-rid-list) = 1 then
            find first buf_X_order no-lock where
                recid(buf_X_order) = int(v-rid-list) no-error.
        else if available (X_order) then 
                find first buf_X_order no-lock where
                    recid(buf_X_order) = recid(X_order) no-error.

        if available (buf_X_order) then 
        do:
            { gbl/chk-actg.i
                  v-cntxt-db-num
                  v-cntxt-userid
                  {&action-head-code-main}
                  'actn_pmnt-ord-doc_add-def':U
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
            empty temp-table tt-zakaz .
            create bf_order .
            assign 
                bf_order.doc-code = next-value (s-order-code, {&db-name_schema}) 
                bf_order.db-num   = v-cntxt-db-num.

            buffer-copy buf_X_order except doc-code db-num order-item to bf_order .
            assign
                bf_order.user-id    = v-cntxt-userid
                bf_order.sts        = 1
                bf_order.doc-date   = now
                bf_order.order-date = today + 1
                .
            date(entry(1,bf_order.params,{&delim-par})) = today .
            empty temp-table gds-list.
            for each ub.order-line no-lock where 
                ub.order-line.db-num = buf_X_order.db-num and
                ub.order-line.doc-code = buf_X_order.doc-code:
                find first buf_goods no-lock where buf_goods.gds-code = ub.order-line.gds-code no-error .
                if available (buf_goods) then 
                do:
                    find first gds-list where gds-list.gds-code = buf_goods.gds-code and gds-list.contract = buf_X_order.contract-prn-code no-error .
                    if not available (gds-list) then
                    do:
                        create gds-list .
                        buffer-copy buf_goods to gds-list .
                        gds-list.contract = buf_X_order.contract-prn-code .
                        gds-list.contract-code = buf_X_order.contract-code .
                    end.                    
                end.
                
            end.
                
            /* Применение параметров */
            if bf_order.params <> "" then
                run crt-orderLine (
                    input bf_order.params,
                    input bf_order.doc-code,
                    input bf_order.db-num,
                    input table tt-gds-list) no-error .
            
            for each ub.order-doc-attr no-lock where 
                ub.order-doc-attr.db-num = buf_X_order.db-num and 
                ub.order-doc-attr.doc-code = buf_X_order.doc-code and 
                ub.order-doc-attr.attr-code <> "copyOrder":
                create bf_order-attr .
                bf_order-attr.doc-code = bf_order.doc-code .
                buffer-copy ub.order-doc-attr except doc-code to bf_order-attr .
                
            end.
            for each ub.order-line-attr no-lock where 
                ub.order-line-attr.db-num   = buf_X_order.db-num and
                ub.order-line-attr.doc-code = buf_X_order.doc-code:
                create bf_order-line-attr .
                bf_order-line-attr.doc-code = bf_order.doc-code .
                buffer-copy ub.order-line-attr except doc-code to bf_order-line-attr .
            end. 
            create bf_order-attr .
            assign
                bf_order-attr.doc-code   = bf_order.doc-code
                bf_order-attr.db-num     = bf_order.db-num
                bf_order-attr.attr-code  = "copyOrder"
                bf_order-attr.attr-value = string(buf_X_order.doc-code)
                .        
            {&OPEN-QUERY-br-order}

            release bf_order .  
            release bf_order-line .  
            release bf_order-attr .
            release X_order.
            run init-sort . 
        end.
        else 
        do:
            message "Не выбран заказ для копирования"
                view-as alert-box.            
        end. 
        
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-date-End
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-date-End d-order
ON CHOOSE OF b-date-End IN FRAME d-order /* ... */
    DO:
        run sel-date in this-procedure
            (input Date-End :handle
            ,input ""
            ) .
      
        if date(Date-End:screen-value) < Date-Start then 
        do:
            message "Дата начала не может быть больше конечной даты"
                view-as alert-box.
            display Date-End with frame d-order .    
        end.
        assign Date-End .  
        if Date-Start <> ? then 
        do:
            run init-sort .
        end.
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-date-Start
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-date-Start d-order
ON CHOOSE OF b-date-Start IN FRAME d-order /* ... */
    DO:
        run sel-date in this-procedure
            (input Date-Start :handle
            ,input ""
            ) .
      
        if Date-End < date(Date-Start:screen-value) then 
        do:
            message "Дата начала не может быть больше конечной даты"
                view-as alert-box.
            display Date-Start with frame d-order .    
        end.
        assign Date-Start .  
        if Date-End <> ? then 
        do:
            run init-sort .
        end.
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-del d-order
ON CHOOSE OF b-del IN FRAME d-order /* Удалить */
    DO:
        define buffer bf_order for ub.order-doc .

        define variable Log-Res  as logical   no-undo init yes.
        define variable undelete as logical   no-undo .
        define variable zakazNum as character no-undo .
        
        { gbl/chk-actg.i
                  v-cntxt-db-num
                  v-cntxt-userid
                  {&action-head-code-main}
                  'actn_pmnt-ord-doc_update':U
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
        if v-rid-list = "" then 
        do:
            if AVAILABLE (X_order) then 
            do:
                if X_order.sts = 1 then
                do:
                    message "Удалить заказ с кодом ТН №" + string (X_order.doc-code) + "?"
                        view-as alert-box question buttons yes-no update undelete.
                    if undelete then
                    do:
                        find first bf_order exclusive-lock where bf_order.doc-code = X_order.doc-code and 
                            bf_order.db-num = X_order.db-num no-error .
                        delete bf_order .
                        delete X_order .
                    end. /*if undelete then*/
                end.
                else
                do:
                    message "Заказ №" + string (X_order.order-item) + " не может быть удален"
                        view-as alert-box.
                end.
            end.

            else
            do:
                message "Не выбран заказ для удаления"
                    view-as alert-box.
            end.
        end.
        if v-rid-list <> "" then 
        do:
            do ii = 0 to num-entries (v-rid-list):
                find first X_order where recid(X_order) = integer(entry (ii,v-rid-list)) and 
                    X_order.sts = StatusOrder:NewStatus:KeyIntDB no-error .    
                if available (X_order) then 
                do:   
                    if zakazNum = "" then zakazNum = string(X_order.doc-code) .
                    else zakazNum = zakazNum + ", " + string(X_order.doc-code) .     

                end.   
            end .               
            message "Удалить заказы с кодом ТН №" + zakazNum + "?"
                view-as alert-box question buttons yes-no update undelete.
            if not undelete then return .
         
        end.
        do ii = 0 to num-entries (v-rid-list):
            find first X_order where recid(X_order) = integer(entry (ii,v-rid-list)) and 
                X_order.sts = StatusOrder:NewStatus:KeyIntDB no-error .    
            if available (X_order) then 
            do:        
                find first bf_order exclusive-lock where bf_order.doc-code = X_order.doc-code and
                    bf_order.db-num = X_order.db-num no-error .
                delete bf_order .
            end.   
        end .    
        v-rid-list = "" .
        run init-sort .
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-hist
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-hist d-order
ON CHOOSE OF b-hist IN FRAME d-order /* История */
    DO:
        define variable v-rid-list as character no-undo.
        if available (X_order) then
        do:
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
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-lookup
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-lookup d-order
ON CHOOSE OF b-lookup IN FRAME d-order /* Просмотр */
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
            
        if available (X_order) then 
        do:
     
            run str/order-doc.w (input parparentproc,
                input X_order.doc-code,
                input {&lookup}
                )  .
        end.
        else 
        do: 
            message "Не выбран заказ"
                view-as alert-box.  
            return no-apply .
        end.
        if X_order.sts = StatusOrder:NewStatus:KeyIntDB then 
        do:
            enable b-del with frame {&frame-name} .
        end.
        else disable b-del with frame {&frame-name} .
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-mark d-order
ON CHOOSE OF b-mark IN FRAME d-order /* * */
    DO:
        define variable loc#log as logical no-undo .
      
        if available X_order then 
        do:
            { gbl/markstrn.i X_order v-rid-list }
            row_order = rowid(X_order).
            loc#log = {&browse-name}:refresh() .
            reposition br-order to rowid row_order.

            if last-event:function <> "MOUSE-SELECT-DBLCLICK" then 
            do:
                loc#log = {&browse-name}:select-next-row ().
                apply "VALUE-CHANGED" to {&browse-name} in frame {&frame-name}.
            end.
            if num-entries( v-rid-list ) = 0 then 
            do:
                hide mark-num in frame {&frame-name}.
                enable b-copy with frame {&frame-name} .
            end.
            else 
            do:
                if num-entries (v-rid-list) > 1 then disable b-copy with frame {&frame-name} .
                else enable b-copy with frame {&frame-name} .
                display
                    num-entries( v-rid-list ) @ mark-num
                    with frame {&frame-name}.
            end.
        end.
        apply "entry" to {&browse-name} in frame {&frame-name}.
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME b-reset
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-reset d-order
ON CHOOSE OF b-reset IN FRAME d-order /* Обновить */
    DO:
        Date-Start = today - 14 .
        Date-End = today .
        cli-code = "" .
        cli-type = "" .
        cli-name = "" .
        c-status = "-1" .
        num-order = "" .
        v-cli = false .
        f-mark = "" .
        r-goods = 0 .
        num-contract = "" .
        b-markGoods:visible = false .
        r-goods:sensitive = true . 
        f-mark:sensitive = true .
        display Date-Start Date-End cli-code
            cli-type cli-name c-status num-order f-mark num-contract with frame d-order .
        run init-sort .
        if X_order.sts = StatusOrder:NewStatus:KeyIntDB then 
        do:
            enable b-del with frame {&frame-name} .
        end.
        else disable b-del with frame {&frame-name} .
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sel d-order
ON CHOOSE OF b-sel IN FRAME d-order /* Выбор */
    DO:
        define buffer buf_order for ub.order-doc .
        if v-rid-list = "" then 
        do:
            if available (X_order) then 
            do:
                find first buf_order no-lock where buf_order.doc-code = X_order.doc-code no-error .
                v-rid-list = string(recid(buf_order)) .
            end.  
        end.  
        rec-order = v-rid-list .
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-send
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-send d-order
ON CHOOSE OF b-send IN FRAME d-order /* Отправить */
    DO:
        define variable ii           as integer   no-undo .
        define variable log-res      as logical   no-undo .
        define variable p-ok         as logical   no-undo .
        define variable qntyNew      as integer   no-undo .
        define variable qntyNull     as integer   no-undo .
        define variable errorRidList as character no-undo .
        define variable ridList      as character no-undo .
        
        define buffer bf_order     for ub.order-doc .
        define buffer buf_X_order  for X_order .    
        define buffer X_order-line for ub.order-line .    
    
        { gbl/chk-actg.i
          v-cntxt-db-num
          v-cntxt-userid
          {&action-head-code-main}
          'actn_pmnt-ord-doc_update':U
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

        if v-rid-list = "" then 
        do:
            if X_order.sts <> StatusOrder:NewStatus:KeyIntDB then 
            do:
                message "Заказ уже был отправлен."
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
                    find first bf_order exclusive-lock where bf_order.doc-code = X_order.doc-code and
                        bf_order.db-num = X_order.db-num no-error .
                    if available (bf_order) then
                    do:
                        bf_order.sts = X_order.sts .
                        release bf_order.
                    end.  
                end.
                else return no-apply.
            end.
            else 
            do:
                message "Количество товара в заказе не может быть отрицательным или равным нулю"
                    view-as alert-box .
                return no-apply . 
            end.
        end.
        else 
        do:
            do ii = 1 to num-entries (v-rid-list):
                find first buf_X_order no-lock where recid(buf_X_order) = integer(entry (ii,v-rid-list)) no-error .
                if buf_X_order.sts <> StatusOrder:NewStatus:KeyIntDB then
                do:
                    qntyNew = qntyNew + 1 .
                    next .
                end.

                find first X_order-line no-lock where
                    X_order-line.db-num = buf_X_order.db-num and
                    X_order-line.doc-code = buf_X_order.doc-code and
                    X_order-line.order-qnty <= 0 no-error .
                if available (X_order-line) then
                do:
                    qntyNull = qntyNull + 1 .
                    if errorRidList = "" then errorRidList = string(recid(buf_X_order)) .
                    else errorRidList = errorRidList + "," + string(recid(buf_X_order)) .
                    next .
                end.
                    if ridList = "" then ridList = string(recid(buf_X_order)) .
                    else ridList = ridList + "," + string(recid(buf_X_order)) .
            end.
 
            if qntyNull = (ii - 1) then 
            do:
                message "Отправлять можно заказы только c положительным количеством товара."
                    view-as alert-box.
                return no-apply .
            end. 
            if qntyNew = (ii - 1) then 
            do:
                message "Отправлять можно только новые заказы."
                    view-as alert-box. 
                return no-apply .               
            end. 
            if (qntyNew + qntyNull) = (ii - 1) then 
            do:
                message "Отправлять можно заказы только c положительным количеством товара."
                    view-as alert-box.     
                message "Отправлять можно только новые заказы."
                    view-as alert-box. 
                return no-apply .                                   
            end.     
            if errorRidList <> "" then do:
                do ii = 1 to num-entries (errorRidList):
                    find first buf_X_order no-lock where recid(buf_X_order) = integer(entry (ii,errorRidList)) no-error .
                   message "В заказе c кодом ТН " + string(buf_X_order.doc-code) + " не должно быть строк с количеством <= 0"
                    view-as alert-box. 
                end.                    
            end. 
            if qntyNew > 0 then do:
                message "Отправлять можно только новые заказы."
                    view-as alert-box.                 
            end.
            if ridList <> "" then do:    
            message "Вы уверены, что хотите отправить выбранные заказы поставщику?"
                view-as alert-box question buttons yes-no update p-ok.     
            end.
            if p-ok then 
            do: 
                do ii = 1 to num-entries (ridList):
                    find first buf_X_order no-lock where recid(buf_X_order) = integer(entry (ii,ridList)) no-error .
                find first X_order-line no-lock where
                    X_order-line.db-num = buf_X_order.db-num and
                    X_order-line.doc-code = buf_X_order.doc-code and
                    X_order-line.order-qnty <= 0 no-error .
                if available (X_order-line) then
                do:
                    qntyNull = qntyNull + 1 .
                    next .
                end.  
                    run bge\send1cerp.p (parparentproc,
                        this-procedure,
                        this-procedure,
                        "order",
                        (buffer buf_X_order:handle),
                        ?,                       
                        ?) no-error.
                    if  error-status:error then 
                    do: 
                        message return-value
                            view-as alert-box.  
                        next .
                    end.
                    buf_X_order.sts = StatusOrder:Sended:KeyIntDB .      
                    find first bf_order exclusive-lock where bf_order.doc-code = buf_X_order.doc-code and
                        bf_order.db-num = buf_X_order.db-num no-error .
                    if available (bf_order) then 
                    do:
                        bf_order.sts = buf_X_order.sts .
                        release bf_order.
                    end.              
                end.
            end.
            else return no-apply.
        end.
        v-rid-list = "" .
        disable b-del with frame {&frame-name} .
        run init-sort .
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-update
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-update d-order
ON CHOOSE OF b-update IN FRAME d-order /* Изменить */
    DO:
        define variable Log-Res as logical no-undo init "true".
        
        if available (X_order) then 
        do:
            { gbl/chk-actg.i
                  v-cntxt-db-num
                  v-cntxt-userid
                  {&action-head-code-main}
                  'actn_pmnt-ord-doc_update':U
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

            if X_order.sts = StatusOrder:NewStatus:KeyIntDB then 
            do:
                run str/order-doc.w (input parparentproc,
                    input X_order.doc-code,
                    input {&update}
                    )  .
                run init-sort . 
            end.
            else 
            do:
                message "Редактировать заказ можно только в статусе: 'Новый'"
                    view-as alert-box.
                return .
            end. 
  
        end.
        else 
        do: 
            message "Не выбран заказ"
                view-as alert-box.  
            return no-apply .
        end.
        if X_order.sts = StatusOrder:NewStatus:KeyIntDB then 
        do:
            enable b-del with frame {&frame-name} .
        end.
        else disable b-del with frame {&frame-name} .
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-order
&Scoped-define SELF-NAME br-order
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-order d-order
ON ROW-DISPLAY OF br-order IN FRAME d-order
    DO:
        if  X_order.sts = StatusOrder:DeliveryCompleted:KeyIntDB then 
        do:
      
            do ii = 1 to extent (bcol):  
                if valid-handle (bcol[ii]) 
                    then 
                do:
                    assign
                        bcol[ii]:fgcolor = 8.
                end.
            end.
        end.   
        if  X_order.sts = StatusOrder:Corrected:KeyIntDB then 
        do:
      
            do ii = 1 to extent (bcol):  
                if valid-handle (bcol[ii]) 
                    then 
                do:
                    assign
                        bcol[ii]:fgcolor = 5.
                end.
            end.
        end.        
        if  X_order.sts = StatusOrder:Cancelled:KeyIntDB then 
        do:
      
            do ii = 1 to extent (bcol):  
                if valid-handle (bcol[ii]) 
                    then 
                do:
                    assign
                        bcol[ii]:fgcolor = 12.
                end.
            end.
        end. 
    END .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-order d-order
on value-changed OF {&BROWSE-name} IN FRAME d-order
    DO:
        if X_order.sts = StatusOrder:NewStatus:KeyIntDB then 
        do:
            enable b-del with frame {&frame-name} .
        end.
        else disable b-del with frame {&frame-name} .
    END .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME bt-no-sel-all
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-no-sel-all d-order
ON CHOOSE OF bt-no-sel-all IN FRAME d-order /* + */
    DO:
        define variable loc#log as logical no-undo .

        if available X_order then 
        do:
            v-rid-list = "" .
            for each X_order no-lock:
                { gbl/markstrn.i X_order v-rid-list }
                loc#log = {&browse-name}:refresh() .
            end.
        end.
        if num-entries( v-rid-list ) <> 0 then 
        do:
            if num-entries (v-rid-list) > 1 then disable b-copy with frame {&frame-name} .
            display
                num-entries( v-rid-list ) @ mark-num
                with frame {&frame-name}.
        end.
    /*        v-rid-list = "" .*/
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-not-sel-desel-all
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-not-sel-desel-all d-order
ON CHOOSE OF bt-not-sel-desel-all IN FRAME d-order /* - */
    DO:
        define variable loc#log as logical no-undo .
        v-rid-list = "" .
        loc#log = {&browse-name}:refresh() no-error .
        enable b-copy with frame {&frame-name} .
        hide mark-num in frame {&frame-name}.
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME c-status
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL c-status d-order
ON VALUE-CHANGED OF c-status IN FRAME d-order /* Статус */
    DO:
        assign c-status .
        run init-sort .
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME statusNotif
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL statusNotif d-order
ON VALUE-CHANGED OF statusNotif IN FRAME d-order /* Уведомления о статусе */
    DO:

        assign statusNotif .

        find first db-attr exclusive-lock where db-attr.db-num = v-cntxt-db-num and
            db-attr.attr-code = "orderStatusNitif" no-error .
        if not available (db-attr) then 
        do:
            create db-attr .
            assign
                db-attr.db-num    = v-cntxt-db-num
                db-attr.attr-code = "orderStatusNitif"
                .
        end.       
        db-attr.attr-value = string(statusNotif) .

    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME cli-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL cli-code d-order
ON LEAVE OF cli-code IN FRAME d-order /* Поставщик */
    DO:
        apply "TAB":U to self .
        return no-apply .
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL cli-code d-order
ON RETURN OF cli-code IN FRAME d-order /* Поставщик */
    DO:
        apply "TAB":U to self .
        return no-apply .
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL cli-code d-order
ON TAB OF cli-code IN FRAME d-order /* Поставщик */
    DO:
        define variable ref-list as character no-undo .
        define variable ref-rec  as integer   no-undo .

        v-cli = false .
        assign cli-code .
        run init-sort .
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME cli-name
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL cli-name d-order
ON LEAVE OF cli-name IN FRAME d-order
    DO:
        apply "TAB":U to self .
        return no-apply .
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL cli-name d-order
ON RETURN OF cli-name IN FRAME d-order
    DO:
        apply "TAB":U to self .
        return no-apply .
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL cli-name d-order
ON TAB OF cli-name IN FRAME d-order
    DO:
        v-cli = false .
        assign cli-name .
        run init-sort .
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Date-End
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Date-End d-order
ON return,LEAVE OF Date-End IN FRAME d-order /* по */
    DO:
        apply "TAB":U to self .
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Date-End d-order
ON TAB OF Date-End IN FRAME d-order /* по */
    DO:
        date(Date-End:screen-value) no-error.
        if error-status:error then 
        do:
            message "Ошибка ввода даты"
                view-as alert-box.      
            display Date-End with frame d-order .
            return no-apply .  
        end.
        if string(Date-End) <> Date-End:screen-value then 
        do:
            if date(Date-End:screen-value) < Date-Start then 
            do:
                message "Дата начала не может быть больше конечной даты"
                    view-as alert-box.
                return no-apply .       
            end.
            /*      if date(Date-End:screen-value) >= today then                        */
            /*      do:                                                                 */
            /*        message "Дата окончания периода продаж должна быть меньше текущей"*/
            /*          view-as alert-box.                                              */
            /*        display Date-End with frame Dialog-Frame .                        */
            /*        return no-apply.                                                  */
            /*      end.                                                                */
            assign Date-End .
            display Date-End with frame d-order .
            if Date-Start <> ? then 
            do:
                run init-sort .
            end. 
        end.

    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME date-Start
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL date-Start d-order
ON return,LEAVE OF date-Start IN FRAME d-order /* За период с */
    DO:
        apply "TAB":U to self .
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL date-Start d-order
ON TAB OF date-Start IN FRAME d-order /* За период с */
    DO:
        date(Date-Start:screen-value) no-error.
        if error-status:error then 
        do:
            message "Ошибка ввода даты"
                view-as alert-box.     
            display Date-Start with frame d-order .
            return no-apply . 
        end.
        if string(Date-Start) <> Date-Start:screen-value then 
        do:
            if Date-End < date(Date-Start:screen-value) then 
            do:
                message "Дата начала не может быть больше конечной даты"
                    view-as alert-box.
                return no-apply .       
            end.
            /*      if date(Date-Start:screen-value) >= today then                   */
            /*      do:                                                              */
            /*        message "Дата начала периода продаж должна быть меньше текущей"*/
            /*          view-as alert-box.                                           */
            /*        display Date-Start with frame Dialog-Frame .                   */
            /*        return no-apply.                                               */
            /*      end.                                                             */
            assign Date-Start .
            display Date-Start with frame d-order .
            if Date-End <> ? then 
            do: 
                run init-sort .
            end.
        end.
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-mark d-order
ON LEAVE,return,tab OF f-mark IN FRAME d-order
    DO:
        if f-mark = f-mark:screen-value
            then
            return .
        assign
            f-mark
            .
        f-mark:sensitive    = f-mark = "".
        b-markGoods:visible   = f-mark <> "".
        b-markGoods:sensitive = b-markGoods:visible.
        r-goods:sensitive = false . 
        apply "entry" to b-markGoods IN FRAME d-order .
        run init-sort .
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME b-markGoods
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-markGoods IN FRAME d-order
ON CHOOSE OF b-markGoods  IN FRAME d-order /* Сбросить */
    DO:
        f-mark:screen-value = "".
        assign
            f-mark
            .
        f-mark:sensitive    = f-mark = "".
        b-markGoods:visible   = f-mark <> "".
        b-markGoods:sensitive = b-markGoods:visible.
        r-goods:sensitive = true . 
        apply "entry" to f-mark IN FRAME d-order .
        run init-sort .
   
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME num-contract
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL num-contract d-order
ON leave OF num-contract IN FRAME d-order /* Номер договора */
    DO:
        apply "TAB":U to self .
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL num-contract d-order
ON RETURN OF num-contract IN FRAME d-order /* Номер договора */
    DO:
        apply "TAB":U to self .
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL num-contract d-order
ON TAB OF num-contract IN FRAME d-order /* Номер договора */
    DO:
        assign num-contract .
        run init-sort .
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME num-order
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL num-order d-order
ON leave OF num-order IN FRAME d-order /* Номер заказа */
    DO:
        apply "TAB":U to self .
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL num-order d-order
ON RETURN OF num-order IN FRAME d-order /* Номер заказа */
    DO:
        apply "TAB":U to self .
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-order d-order
ON mouse-select-dblclick OF br-order IN FRAME d-order
    DO:
        if AVAILABLE (X_order) then 
        do:     
            if X_order.sts = StatusOrder:NewStatus:KeyIntDB then apply "Choose" to b-update in frame {&frame-name}. 
            else    apply "Choose" to b-lookup in frame {&frame-name}.
        end.  
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL num-order d-order
ON TAB OF num-order IN FRAME d-order /* Номер заказа */
    DO:
        assign num-order .
        run init-sort .
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME r-goods
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL r-goods d-order
ON VALUE-CHANGED OF r-goods IN FRAME d-order
    DO:
        assign r-goods .
  
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK d-order 


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
    THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.
{ gbl/app_help.i }

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
    ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
    { gbl/ed_date.i Date-Start }  
{ gbl/ed_date.i Date-End }

{ gbl/brwrepos.i
  &line-num= 9
}
/*run init-temp .*/
find first db-attr no-lock where db-attr.db-num = v-cntxt-db-num and
    db-attr.attr-code = "orderStatusNitif" no-error .
if not available (db-attr) then statusNotif = true .
else statusNotif = logical (db-attr.attr-value) .
    
StatusOrder =  new ibs.th.str.order.sts.order().

Date-Start = today - 14 .
Date-End = today .
for each buf_order exclusive-lock where buf_order.obj-code = v-cntxt-obj-code and 
    buf_order.obj-type = v-cntxt-obj-type and
    buf_order.db-num = v-cntxt-db-num and 
    buf_order.sts = StatusOrder:NewStatus:KeyIntDB and
    buf_order.doc-date < datetime (today - 1):
    delete buf_order .
end.    
    
for each buf_order no-lock where buf_order.obj-code = v-cntxt-obj-code and 
    buf_order.obj-type = v-cntxt-obj-type and
    buf_order.db-num = v-cntxt-db-num:
    create X_order .
    buffer-copy buf_order to X_order .
end.
extent (bcol) = ?.
hbrowse = browse {&BROWSE-NAME}:handle.
extent (bcol) = hbrowse:num-columns.
bcol[1] = hbrowse:first-column.
do ii = 1 to extent (bcol).  
    bcol[ii] = hbrowse:get-browse-column (ii).
end.

run init-temp .
RUN enable_UI.
run init-sort .
WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-temp d-order 
PROCEDURE init-temp :

    define variable ii         as integer   no-undo .
    define variable Status_    as character no-undo .
    define variable Status_EDI as character no-undo .
    define variable Edoc_type  as character no-undo .

    Status_ = "Все" + {&comma-char} + '-1':U .

    do ii = 1 to StatusOrder:mapType:GetItemByLab(ii):
        if StatusOrder:CurrProp:KeyIntDB >= 50
            and StatusOrder:CurrProp:KeyIntDB < 60
            then next . /* Вывод из оборота */
        Status_ = Status_ + {&comma-char} + StatusOrder:CurrProp:Label_ + {&comma-char} + string(StatusOrder:CurrProp:KeyIntDB) .
    end.

    ASSIGN
        c-status:LIST-ITEM-PAIRS  in frame {&frame-name} = Status_ .

    c-status = "-1" .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI d-order  _DEFAULT-DISABLE
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
    HIDE FRAME d-order.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI d-order  _DEFAULT-ENABLE
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
    DISPLAY date-Start Date-End c-status cli-code cli-type cli-name num-order 
        num-contract r-goods f-mark mark-num statusNotif
        WITH FRAME d-order.
    ENABLE b-exit b-add b-update b-lookup b-copy b-del b-send b-reset b-sch 
        b-help b-hist b-date-Start date-Start Date-End b-date-End c-status statusNotif
        b-cli cli-code cli-type cli-name num-order num-contract r-goods b-mark 
        f-mark b-markGoods br-order mark-num bt-not-sel-desel-all bt-no-sel-all
        WITH FRAME d-order.
    hide b-markGoods b-sch b-sel in frame d-order .    
    VIEW FRAME d-order.
  
    {&OPEN-BROWSERS-IN-QUERY-d-order}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-sort d-order 
PROCEDURE init-sort :
    define variable vInt      as logical   no-undo.
    define variable vi        as integer   no-undo.
    define variable vGdsCode  as integer   no-undo.
    define variable vGtin     as character no-undo.
    define variable vMark     as character no-undo.
    define variable vMarkGtin as character no-undo.
    define variable vGdsName  as character no-undo .
    define variable vOkGoods  as logical   no-undo .
    define variable vDbNumCur as integer   no-undo.
    define variable vCodeCur  as integer   no-undo.
    
    define buffer goods       for ub.goods.
    define buffer bar-code    for ub.bar-code.
    define buffer prod-bc     for ub.prod-bc.
    define buffer marking     for ub.marking .    
    define buffer order-line  for ub.order-line .
    define buffer buf_X_order for X_order .
    
    if avail X_order then
        assign
            vDbNumCur = X_order.db-num
            vCodeCur  = X_order.doc-code
            .
    for each X_order:
        delete X_order .
    end.
    /*if AVAILABLE (X_order) then empty temp-table X_order .*/

    mark-num = 0.
    display mark-num with frame {&frame-name}.
    hide mark-num in frame {&frame-name}.
    
    for each buf_order no-lock where buf_order.obj-code = v-cntxt-obj-code and 
        buf_order.obj-type = v-cntxt-obj-type and
        buf_order.db-num = v-cntxt-db-num:
        create X_order .
        buffer-copy buf_order to X_order .
    end.
    if f-mark <> "" then 
    do:
        case r-goods:
            when 0 then 
                do:
                    int(f-mark) no-error.
                    vInt = not error-status:error.
                    if vInt
                        then
                        find first goods where goods.gds-code eq int(f-mark) no-lock no-error.
                    if available goods
                        then 
                    do:
                        vGdsCode  = goods.gds-code.
                    end.
                    else 
                    do:
                        if vInt
                            then
                            find first bar-code where bar-code.b-code eq int(f-mark) no-lock no-error.
                        if available bar-code
                            then 
                        do:
                            vGdsCode  = bar-code.gds-code.
                        end.
                        else 
                        do:
                            block-fill:
                            do vi = 0 to 10:
                                find first prod-bc where prod-bc.b-str eq fill("0",vi) + f-mark no-lock no-error.
                                if available prod-bc
                                    then
                                    leave block-fill.
                            end. 
                            if available prod-bc
                                then 
                            do:    
                                if prod-bc.bc-on-type = {&gtin}
                                    then
                                    vGdsCode = prod-bc.b-code.
                                else 
                                do:
                                    find first bar-code where bar-code.b-code eq prod-bc.b-code no-lock no-error.
                                    if available bar-code
                                        then
                                        vGdsCode  = bar-code.gds-code.
                                end.
                            end.
                            else 
                            do:
                                vMark     = getcodeident(f-mark).
                                vMarkGtin = getGtinByDM (f-mark).
  
                                if vMark = ? and vMarkGtin = "" then 
                                do:
                                    for each X_order:
                                        delete X_order .
                                    end.
                                end.
                            end.
                        end.
                    end.
            
                end.
            otherwise 
            do:
                vGdsName = prep-nameorcode(f-mark) .
            end.
        end case .
    end.

    if vMark <> ""
        then 
    do:
        find first marking where marking.mark     begins vMark
            no-lock no-error.
        if not available marking
            then
            find first marking where marking.mark     begins "02" + vMarkGtin + "37"
                no-lock no-error.
           
        if available marking
            then 
        do :
            vGdsCode = marking.gds-code .
        end .
    end.
    if vGdsCode <> 0 then 
    do:
        for each X_order:
            find first order-line where order-line.db-num  = X_order.db-num
                and order-line.doc-code   = X_order.doc-code
                and order-line.gds-code = vGdsCode
                no-lock no-error.
            if available (order-line) then next .
            else delete X_order .    
        end.       
    end.
    if vGdsName <> "" then 
    do:
        for each X_order:
            vOkGoods = false .    
            for each order-line where order-line.db-num  = X_order.db-num
                and order-line.doc-code   = X_order.doc-code no-lock,
                first goods where goods.gds-code = order-line.gds-code and 
                goods.gds-name contains vGdsName no-lock :
                vOkGoods = true .    
                leave .
 
            end.
            if not vOkGoods then delete X_order .  
        end.               
    end.
    if num-contract <> "" then 
    do:
        for each X_order :
            if X_order.contract-prn-code begins num-contract then next .
            else delete X_order .
        end.         
    end.
    if c-status <> "-1" then 
    do:
        for each X_order where X_order.sts <> integer(c-status):
            delete X_order .
        end.  
    end.    
    
    if date-Start <> ? and Date-End <> ? then
    do:
        for each X_order where date-Start > date(X_order.doc-date) or Date-End < date(X_order.doc-date):
            delete X_order .
        end.
    end.
    
    if v-cli then
    do:
        for each X_order where X_order.cli-code <> integer(cli-code) and X_order.cli-type = cli-type :
            delete X_order .
        end.
    end.
    else  
    do:
        if cli-code <> "" then 
        do:
            for each X_order where X_order.cli-code <> integer(cli-code):
                delete X_order .
            end.            
        end.
   
        if cli-name <> "" then 
        do:
            for each X_order :
                if X_order.cli-name begins cli-name then next .
                else delete X_order .
            end.            
        end.           
    end.
    
    
    if num-order <> "" then 
    do:
        for each X_order:
            if string(X_order.order-item) begins num-order then next .
            else delete X_order .
        end.
    end.
    v-cli = false .
    
    apply "CHOOSE":U to bt-not-sel-desel-all IN FRAME {&frame-name}. /* для снятия выделения и обнуления счетчика */
    {&OPEN-QUERY-br-order} 
    br-order:refresh () in frame d-order no-error .
    if vCodeCur <> 0 then
        find first buf_X_order no-lock where
            buf_X_order.db-num   = vDbNumCur
            and buf_X_order.doc-code = vCodeCur
            no-error.
    if avail buf_X_order then do:
        reposition {&browse-name} to rowid rowid(buf_X_order).
        if buf_X_order.sts = StatusOrder:NewStatus:KeyIntDB then 
        do:
            enable b-del with frame {&frame-name} .
        end.
        else disable b-del with frame {&frame-name} .
    end .    
    else do:        
        reposition {&browse-name} to row 1.
        enable b-del with frame {&frame-name} .
    end.    
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION cli-name d-order 
FUNCTION cli-name RETURNS character
    (cli-code as integer, cli-type as character ):
  
    define variable v-cli-name as character no-undo.
    find first ub.clients no-lock where ub.clients.obj-code = cli-code and
        ub.clients.obj-type = cli-type no-error .
    if available (ub.clients) then 
    do:
        v-cli-name = ub.clients.obj-name .
    end.
    return v-cli-name.
  
end function.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-sts d-order 
FUNCTION get-sts RETURNS character
    (p-sts as integer ):
  
    define variable v-sts as character no-undo.
    v-sts = StatusOrder:GetLabel(p-sts) .
    return v-sts.
  
end function.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION num-doc d-order 
FUNCTION num-doc RETURNS character
    (p-doc-code as integer, p-db-num as integer):
  
    return string(p-doc-code).
  
end function.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION user-name d-order 
FUNCTION user-name RETURNS character
    (p-user-id as character ):
  
    define variable v-user-name as character no-undo.
    find first ub.user-account no-lock where ub.user-account.user-id = p-user-id no-error .
    if available (ub.user-account) then 
    do:
        v-user-name = ub.user-account.last-name + " " + ub.user-account.first-name + " " + ub.user-account.second-name .
    end.
    return v-user-name.
  
end function.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION prep-nameorcode d-order 
FUNCTION prep-nameorcode RETURNS CHARACTER
    ( input p-nameorcode as character ) :
    define variable v-nameorcode as character no-undo .
    define variable nameorcode   as character no-undo .

    if trim(p-nameorcode) = '' then  return ''.
    v-nameorcode = trim( trim( p-NameOrCode) , "*" ) .
    if index(v-NameOrCode, {&double-quote} ,1 ) = 1
        and R-index(v-NameOrCode, {&double-quote} ,1 ) = 1 then 
    do:
        assign
            v-NameOrCode = trim(v-NameOrCode, {&double-quote})
            .
        nameorcode = v-nameorcode.
/*        display NameOrCode with frame {&frame-name}.*/
    end.
    /*
    v-NameOrCode = right-trim( v-NameOrCode, "o" ) .    /* lat "o" */
    v-NameOrCode = right-trim( v-NameOrCode , "о" ) /* rus "о" */ + "*" .
    */
    define variable v-dopi as character no-undo .
    assign
        v-dopi = substring(v-NameOrCode, length(v-NameOrCode), 1)
        .
    if index("abcdefghijklmnopqrstuvwxyzабвгдеёжзийклмнопрстуфхцчшщъыьэюя", v-dopi) > 0
        or index("1234567890", v-dopi) > 0
        then 
    do:
        v-NameOrCode = v-NameOrCOde + "*".
    end.
    v-NameOrCode = LC(v-NameOrCode).

    RETURN v-nameorcode.   /* Function return value. */

END FUNCTION.
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME