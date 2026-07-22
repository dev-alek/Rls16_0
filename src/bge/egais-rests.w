&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*------------------------------------------------------------------------

  File: bge/egais-goods.w

  Description: Настройки объектов ЕГАИС

  Input Parameters:
      <none>

  Output Parameters:
      <none>

  Author: Slivenko Sergey

  Created: 16.11.2015
------------------------------------------------------------------------*/
/*          This .W file was created with the Progress AppBuilder.       */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

using ibs.th.bge.egais.*.

/* Parameters Definitions ---                                           */

define input parameter parparentproc as widget-handle no-undo .

/* Local Variable Definitions ---                                       */

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Работа с остатками ЕГАИС".

&scop f-l Base2Int64

{ cmp/vssrevis.i }
{ gbl/std-func.i {&f-l} }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ str/lib-trn.i  }
{ cmp/showinf.i  }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
{ gbl/thbjattr.i }
{ gbl/clntattr.i }
{ gbl/color.i    }
{ ref/extclass.i }
{ gbl/key-rec.i  }
{ gbl/attr-lib.i }
{ ref/gds-attr.i }
{ gbl/waitfram.i }
{ cmp/gds-list.i gds-list def "new shared" }

define stream OutStr-html.
{ gbl/prn-lib.i  }


define temp-table tt-gds-rests no-undo
    field gds-code          like ub.goods.gds-code          label "Код товара в TH"
    field gds-name          like ub.goods.gds-name          label "Наименование товара" format "X(100)"
    field alc-code          as character                    label "Алкогольный код"     format "X(21)"
    field ms-base           like ub.goods.ms-base           label "Объем"               format ">>9.9<<"
    field alc-type-code     like ub.alc-type.alc-type-code  label "Код АП"
    field proof             like ub.goods.proof             label "Крепость"            format ">9.9"    
    field fromEgais         as logical
    field egais-name        as character                    label "Наименование ЕГАИС"  format "X(100)"
    field egais-qnty        as decimal                      label "Остаток ЕГАИС"
    field informA_          as character                    label "ID справки А"        format "X(30)"
    field informB_          as character                    label "ID справки Б"        format "X(30)"
    field TH-qnty           as decimal                      label "Остаток TH"   
    field prt-rec           as character  
    field packed            as logical     
    index pi as primary
        gds-code
    index name_ as word-index
        gds-name
    index alc
        alc-code    
.    

define buffer old_tt-gds-rests for tt-gds-rests .

define temp-table tt-gds-rests_shop no-undo
    field gds-code          as character                    label "Код товара в TH"
    field gds-name          like ub.goods.gds-name          label "Наименование товара" format "X(100)"
    field alc-code          as character                    label "Алкогольный код"     format "X(21)"
    field ms-base           like ub.goods.ms-base           label "Объем"               format ">>9.9<<"
    field alc-type-code     like ub.alc-type.alc-type-code  label "Код АП"
    field proof             like ub.goods.proof             label "Крепость"            format ">9.9"    
    field fromEgais         as logical
    field egais-name        as character                    label "Наименование ЕГАИС"  format "X(100)"
    field egais-qnty        as decimal                      label "Остаток маг"
    field TH-qnty           as decimal                      label "Остаток TH"   
    field prt-rec           as character  
    field packed            as logical  
    field egais-qnty_stock  as decimal                      label "Остаток скл"   
    field in-list           as logical
    index pi as primary
        gds-code
    index name_ as word-index
        gds-name
    index alc
        alc-code    
.    

define buffer old_tt-gds-rests_shop for tt-gds-rests_shop .

define temp-table tt-compare-rests no-undo
    field gds-code          as character                    label "Код товара в TH"
    field gds-name          like ub.goods.gds-name          label "Наименование товара" format "X(100)"
    field alc-code          as character                    label "Алкогольный код"     format "X(21)"
    field alc-type-code     like ub.alc-type.alc-type-code  label "Код АП"
    field TH-qnty           as decimal                      label "Остаток TH"
    field shop-qnty         as decimal                      label "Остаток маг"
    field stock-qnty        as decimal                      label "Остаток скл"
    index pi as primary
        alc-code
    index gds
        gds-code    
.

define temp-table tt-marks-compare-rests no-undo
    field gds-code          like ub.goods.gds-code          label "Код товара в TH"
    field gds-name          like ub.goods.gds-name          label "Наименование товара" format "X(100)"
    field alc-code          as character                    label "Алкогольный код"     format "X(21)"
    field alc-type-code     like ub.alc-type.alc-type-code  label "Код АП"
    field TH-qnty           as decimal                      label "Остаток TH"
    field shop-qnty         as decimal                      label "Остаток маг"
    field stock-qnty        as decimal                      label "Остаток скл"
    field marks-qnty        as integer                      label "Кол-во марок"
    field gds-codes         as character
    index pi as primary
        alc-code
    index gds
        gds-code    
.

define temp-table tt-marks-qnty
    field alc-code  as character                    label "Алкогольный код"     format "X(21)"
    field qnty      as integer                      label "Кол-во марок"
    index pi as primary
        alc-code
.

define temp-table tt-gds-list no-undo
    field alc-code      as character
    field gds-code      as character
    index pi as primary unique
        alc-code gds-code
.

define temp-table tt-obj-list no-undo
    field obj-type as character
    field obj-code as integer
    field inn like ub.firm.inn
    index pi as primary unique
        obj-type obj-code
.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

def var rests as class Rests.
def var rests_shop as class Rests_Shop.

def var bh-gds-egais as handle no-undo .
def var qh-gds-egais as handle no-undo .

def var bh-gds-egais_shop as handle no-undo .
def var qh-gds-egais_shop as handle no-undo .


define buffer buf_firm for ub.firm .
define buffer buf_clients for ub.clients .
define buffer buf_clients-attr for ub.clients-attr .
define buffer buf_goods for ub.goods .
define buffer buf_goods-attr for ub.goods-attr .
define buffer buf_parts for ub.parts .
DEFINE BUFFER X_ext-classif FOR ub.ext-classif.

define variable v-section-names as character no-undo.
define variable v-page-current as integer no-undo.
define variable v-page as integer no-undo.
define variable iTemp as integer no-undo.
&SCOP max-labels 2
&SCOP tab-height 25

  DEFINE VARIABLE up-image             AS HANDLE NO-UNDO.  
  DEFINE VARIABLE tab-type          AS INT NO-UNDO. /* 1,2 */
  DEFINE VARIABLE char-hdl             AS CHARACTER NO-UNDO.
  DEFINE VARIABLE page-label           AS HANDLE EXTENT {&max-labels} NO-UNDO.
  DEFINE VARIABLE image-hdl            AS HANDLE EXTENT {&max-labels} NO-UNDO.
  DEFINE VARIABLE page-enabled         AS LOGICAL EXTENT {&max-labels} NO-UNDO.
  
  DEFINE VARIABLE pos-x             AS integer NO-UNDO init 5.
  DEFINE VARIABLE pos-y             AS integer NO-UNDO init 110.

  DEF VAR width-tab-values    AS INT INIT [110,72] EXTENT 2 NO-UNDO.
  DEFINE VARIABLE        number-of-pages    AS INTEGER   NO-UNDO.

define variable select-list as longchar  no-undo .
define variable select-list_shop as longchar  no-undo .
define variable v-sel-entry as character no-undo .
define variable goods-list  as longchar  no-undo .
define variable ref-list    as character no-undo .
define variable ii          as integer   no-undo .
define variable jj          as integer   no-undo .
define variable v-rid       as recid     no-undo .
define variable v-prt-rec   as recid     no-undo .
define variable par-alcohol as character no-undo .
define variable par-egais-name as character no-undo .
define variable par-type    as character no-undo .
define variable v-kpp       as character no-undo .
define variable v-org-inn   as character no-undo .
define variable v-isSent    as logical   no-undo .
define variable v-outId     as character no-undo .
define variable v-ext-sys   as integer   no-undo .
define variable v-replyId   as character no-undo .
/*define variable v-alc-code  as character no-undo .*/

define variable glog        as logical no-undo .

define variable v-gds-uniq-key-rec as character no-undo .

define variable saved as logical no-undo initial no .

define variable gds-rec as recid no-undo .
define variable tt-rec as recid no-undo .
define variable tt-row as rowid no-undo .
define variable tt-row2 as rowid no-undo .

define variable v-value-character  as character no-undo .
define variable v-value-decimal    as decimal   no-undo .
define variable v-value-integer    as integer   no-undo .
define variable v-value-logical    as logical   no-undo .
define variable v-value-type       as character no-undo .
define variable v-value-date       as date      no-undo .

define variable v-org as character no-undo .
define variable v-fs-rar as character no-undo .
define variable v-fs-rar-list as character no-undo .
define variable v-num-loads as integer no-undo .
define variable v-num-objs as integer no-undo .

define variable v-fn-rests as character no-undo .
define variable v-fn-rests_shop as character no-undo .

define variable v-DT-rests as character no-undo 
    view-as text format "X(20)" label "Дата и время" .
define variable v-DT-rests_shop as character no-undo 
    view-as text format "X(20)" label "Дата и время" .

define stream str-err .

define variable bh-act-header  as handle no-undo .
{ibs/th/bge/egais/awo-egais.i proc }
define variable bh-act-header-tts  as handle no-undo .
{ibs/th/bge/egais/tts-egais.i proc -tts }
define buffer x_ext-classif-attr     for ub.ext-classif-attr .
define variable bh-act-header-awos  as handle no-undo .
{ibs/th/bge/egais/awo-egais_shop.i proc " " " " -awos }

FUNCTION get-mark RETURNS CHARACTER
(buffer local-gds for tt-gds-rests ):
if lookup (string (recid (local-gds)), select-list) > 0  then return "*".
                                                           else return "".
end function.

FUNCTION get-mark_shop RETURNS CHARACTER
(buffer local-gds_shop for tt-gds-rests_shop ):
if lookup (string (recid (local-gds_shop)), select-list_shop) > 0  then return "*".
                                                           else return "".
end function.



&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br-rests

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-objs

/* Definitions for BROWSE br-goods                                    */
&Scoped-define SELF-NAME br-goods
&Scoped-define QUERY-STRING-br-goods FOR EACH tt-gds-rest
&Scoped-define OPEN-QUERY-br-goods OPEN QUERY {&SELF-NAME} FOR EACH tt-gds-rests.
&Scoped-define TABLES-IN-QUERY-br-goods tt-gds-rests
&Scoped-define FIRST-TABLE-IN-QUERY-br-goods tt-gds-rests


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-br-goods}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-load b-cancel br-rests b-func

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */
&Scoped-define List-1 b-save b-connect b-del br-rests v-DT-rests b-func

&Scoped-define List-2 br-rests_shop br-rests_all t-negative_rests t-not_eq_rests v-DT-rests_shop b-func_shop
/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */

/*define variable v-prod as character no-undo view-as text format "X(11)" label "Производитель" .*/
/*define variable v-prod-name as character no-undo view-as text format "X(30)" .                 */

define menu m-func
    menu-item m-writeOff label "Сформировать акт о списании"
    menu-item m-tts label "Сформировать акт передачи в торговый зал"
    menu-item m-print label "Печать остатков на складе"
    menu-item m-print_shop label "Печать остатков в магазине"
/*    menu-item m-compare label "Сверка остатков"       */
/*    menu-item m-marks-compare label "Сверка по маркам"*/
/*    menu-item m-list label "Показать по списку"       */
/*    menu-item m-all label "Показать все"              */
    menu-item m-load-all label "Запрос по всем объектам"
    menu-item m-file label "Загрузить из файла"
.    

define menu m-func_shop
    menu-item m-writeOff_shop label "Сформировать акт о списании из торгового зала"
/*    menu-item m-tts label "Сформировать акт о передаче продукции в торговый зал"*/
    menu-item m-print label "Печать остатков на складе"
    menu-item m-print_shop label "Печать остатков в магазине"
    menu-item m-compare label "Сверка остатков"
    menu-item m-marks-compare label "Сверка по маркам"
    menu-item m-list label "Показать по списку"
    menu-item m-all label "Показать все"
    menu-item m-load-all label "Запрос по всем объектам"
    menu-item m-file label "Загрузить из файла"
. 

DEFINE BUTTON b-mark 
     LABEL "&*" 
     SIZE 3 BY 1.14 .
     
DEFINE BUTTON b-cancel AUTO-END-KEY 
     LABEL "Выход" 
     SIZE 15 BY 1.14
     BGCOLOR 8 .

DEFINE BUTTON b-load 
     LABEL "Запрос" 
     tooltip "Отправить запрос в ЕГАИС"
     SIZE 15 BY 1.14
     BGCOLOR 8 .
     
DEFINE BUTTON b-save 
     LABEL "Сохранить" 
     tooltip "Записать данные о справках A/B в партию"
     SIZE 15 BY 1.14
     BGCOLOR 8 .
     
DEFINE BUTTON b-answer 
     LABEL "Получить ответ" 
     SIZE 15 BY 1.14
     BGCOLOR 8 .   
     
     
DEFINE BUTTON b-del
     LABEL "Удалить связку"
     SIZE 15 BY 1.14
     BGCOLOR 8 .
     
DEFINE BUTTON b-connect 
     LABEL "Связать" 
     SIZE 15 BY 1.14
     BGCOLOR 8 . 
     
DEFINE BUTTON b-func 
     LABEL "Функции" 
     SIZE 15 BY 1.14
     BGCOLOR 8 . 

DEFINE BUTTON b-func_shop
     LABEL "Функции"
     SIZE 15 BY 1.14
     BGCOLOR 8 .
     
DEFINE BUTTON b-sel-all
     LABEL "&+":L
     SIZE 3 BY 1.14 TOOLTIP "Отметить все объекты".

DEFINE BUTTON b-unmark
     LABEL "&-":L
     SIZE 3 BY 1.14 TOOLTIP "Снять все отметки". 
     
defin variable t-negative_rests as logical view-as toggle-box label "Отрицательные остатки" initial no no-undo .

defin variable t-not_eq_rests as logical view-as toggle-box label "Расхождения кол-ва" initial no no-undo .

Define variable NameContext as character view-as fill-in size 30 by 1 fgcolor 12 no-undo.
define variable loc-alc  as character view-as fill-in size 25 by 1 fgcolor 12 no-undo format "x(25)":U.
define variable loc-code as character view-as fill-in size 20 by 1 fgcolor 12 no-undo. 

define variable a-n-c as character view-as radio-set horizontal radio-buttons
"Алк. Код","alc",
"Нач.слова","context",
"Код TH","code"
size 30 by 1    fgcolor 0 /* bgcolor 8 */ no-undo.    

     
/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-rests FOR 
      tt-gds-rests SCROLLING.
DEFINE QUERY br-rests_shop FOR 
      tt-gds-list, tt-gds-rests_shop  SCROLLING.
DEFINE QUERY br-rests_all FOR 
      tt-gds-rests SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-rests
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-rests Dialog-Frame _FREEFORM
  QUERY br-rests  DISPLAY
    get-mark(BUFFER tt-gds-rests) COLUMN-LABEL "*"  FORMAT "X(1)":U
    tt-gds-rests.alc-code COLUMN-LABEL "Алкогольный код" FORMAT "X(25)":U
    tt-gds-rests.gds-name COLUMN-LABEL "Наименование товара" FORMAT "X(100)":U width 39
    tt-gds-rests.gds-code COLUMN-LABEL "Код товара в TH" FORMAT ">>>>>>>>9"
/*    tt-gds-rests.ms-base  COLUMN-LABEL "Объем" FORMAT ">>9.9<<"*/
/*    tt-gds-rests.proof    COLUMN-LABEL "Крепость" FORMAT ">9.9"*/
    tt-gds-rests.alc-type-code COLUMN-LABEL "Код АП" FORMAT "X(4)":U
    tt-gds-rests.egais-qnty
    tt-gds-rests.informA_
    tt-gds-rests.informB_
    tt-gds-rests.TH-qnty
/*    tt-gds-rests.egais-name COLUMN-LABEL "Наименование в ЕГАИС" FORMAT "X(100)":U width 39*/
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 105 BY 20 FIT-LAST-COLUMN.
    
DEFINE BROWSE br-rests_shop
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-rests_shop Dialog-Frame _FREEFORM
  QUERY br-rests_shop  DISPLAY
    get-mark_shop(BUFFER tt-gds-rests_shop) COLUMN-LABEL "*"  FORMAT "X(1)":U
    tt-gds-rests_shop.alc-code COLUMN-LABEL "Алкогольный код" FORMAT "X(25)":U
    tt-gds-rests_shop.gds-name COLUMN-LABEL "Наименование товара" FORMAT "X(100)":U width 39
    tt-gds-rests_shop.gds-code COLUMN-LABEL "Код товара в TH" FORMAT "X(25)"
/*    tt-gds-rests.ms-base  COLUMN-LABEL "Объем" FORMAT ">>9.9<<"*/
/*    tt-gds-rests.proof    COLUMN-LABEL "Крепость" FORMAT ">9.9"*/
    tt-gds-rests_shop.alc-type-code COLUMN-LABEL "Код АП" FORMAT "X(4)":U
    tt-gds-rests_shop.egais-qnty
    tt-gds-rests_shop.egais-qnty_stock
    tt-gds-rests_shop.TH-qnty
/*    tt-gds-rests.egais-name COLUMN-LABEL "Наименование в ЕГАИС" FORMAT "X(100)":U width 39*/
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 105 BY 12 .
    
DEFINE BROWSE br-rests_all
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-rests_all Dialog-Frame _FREEFORM
  QUERY br-rests_all  DISPLAY
    tt-gds-rests.alc-code COLUMN-LABEL "Алкогольный код" FORMAT "X(25)":U
    tt-gds-rests.gds-name COLUMN-LABEL "Наименование товара" FORMAT "X(100)":U width 39
    tt-gds-rests.gds-code COLUMN-LABEL "Код товара в TH" FORMAT ">>>>>>>>9"
/*    tt-gds-rests.ms-base  COLUMN-LABEL "Объем" FORMAT ">>9.9<<"*/
/*    tt-gds-rests.proof    COLUMN-LABEL "Крепость" FORMAT ">9.9"*/
    tt-gds-rests.alc-type-code COLUMN-LABEL "Код АП" FORMAT "X(4)":U
    tt-gds-rests.egais-qnty
    tt-gds-rests.informB_
/*    tt-gds-rests.egais-name COLUMN-LABEL "Наименование в ЕГАИС" FORMAT "X(100)":U width 39*/
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 105 BY 8 title "Остатки на складе по алкокоду в разрезе справок Б" .

DEFINE RECTANGLE Rect-Bottom
     EDGE-PIXELS 0    
     SIZE 1 BY 1
     BGCOLOR 7 .

DEFINE RECTANGLE Rect-Left
     EDGE-PIXELS 0    
     SIZE 1 BY 1
     BGCOLOR 15 .

DEFINE RECTANGLE Rect-Main
     EDGE-PIXELS 1 GRAPHIC-EDGE    
     SIZE 1 BY 1
     BGCOLOR 8 FGCOLOR 0 .

DEFINE RECTANGLE Rect-Right
     EDGE-PIXELS 0    
     SIZE 1 BY 1
     BGCOLOR 7 .

DEFINE RECTANGLE Rect-Top
     EDGE-PIXELS 0    
     SIZE 1 BY 1
     BGCOLOR 15 .
     
/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-mark AT ROW 2.5 COL 2
     b-sel-all AT ROW 2.5 COL 5
     b-unmark AT ROW 2.5 COL 8
     b-load AT ROW 1.24 COL 32
     b-answer AT ROW 1.24 COL 47
     b-save AT ROW 1.24 COL 17
     b-cancel AT ROW 1.24 COL 2
     v-fs-rar at row 2.7 col 17 label "ФСРАР ID"
     b-connect AT ROW 1.24 COL 62
     b-del at row 1.24 col 77 
     b-func at row 1.24 col 92
     b-func_shop at row 1.24 col 92
     t-negative_rests at row 5.3 col 83
     t-not_eq_rests at row 5.3 col 60
     a-n-c at row 4 col 2 label "Поиск по"
     NameContext at row 4 col 50 label "Контекст"
     loc-alc at row 4 col 50 no-label
     loc-code at row 4 col 50 label "Код(весь)"
     v-DT-rests at row 2.8 col 48
     v-DT-rests_shop at row 2.8 col 48
     br-rests AT ROW 6.5 COL 2.2 WIDGET-ID 200
     br-rests_shop AT ROW 6.5 COL 2.2 WIDGET-ID 220
     br-rests_all AT ROW 18.5 COL 2.2 WIDGET-ID 240
     Rect-Main AT ROW 5 COL 5.75
     Rect-Bottom AT ROW 5 COL 3.5
     Rect-Left AT ROW 1 COL 1.25
     Rect-Right AT ROW 1 COL 34.25
     Rect-Top AT ROW 1 COL 1.25
     SPACE(106) SKIP(24.8)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Остатки ЕГАИС"
         DEFAULT-BUTTON b-load CANCEL-BUTTON b-cancel WIDGET-ID 100.

assign br-rests:NUM-LOCKED-COLUMNS IN FRAME Dialog-Frame = 1 .
assign br-rests_shop:NUM-LOCKED-COLUMNS IN FRAME Dialog-Frame = 1 .
assign br-rests_all:NUM-LOCKED-COLUMNS IN FRAME Dialog-Frame = 0 .

/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   Allow: Basic,Browse,DB-Fields,Query
   Other Settings: COMPILE
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB br-goods b-cancel Dialog-Frame */
ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-goods
/* Query rebuild information for BROWSE br-goods
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt-gds.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE br-goods */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

on F9 of frame {&frame-name} anywhere do:
  if not available tt-gds-rests then  return no-apply.
  if tt-gds-rests.gds-code = 0  then  return no-apply.
  find first goods no-lock where goods.gds-code = tt-gds-rests.gds-code .
  gds-rec = recid(goods) .
  run ref/gds-form.w
    (input  parParentProc
    ,input  {&lookup}
    ,input  v-cntxt-obj-type
    ,input  v-cntxt-obj-code
    ,input ? /*p-call-handle*/
    ,input-output gds-rec
    ).

/*  apply "entry" to spec-List in frame {&frame-name}.*/
/*  return no-apply.                                  */
end.

/*&Scoped-define SELF-NAME b-good                              */
/*&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-good Dialog-Frame*/
/*ON CHOOSE OF b-good IN FRAME Dialog-Frame /* * */            */
/*DO:                                                          */
/*    apply "F9" to frame Dialog-Frame .                       */
/*END.                                                         */
/*                                                             */
/*/* _UIB-CODE-BLOCK-END */                                    */
/*&ANALYZE-RESUME                                              */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Объекты ЕГАИС */
DO:
    delete object Rests no-error .
    delete object Rests_shop no-error .
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME t-negative_rests
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL t-negative_rests Dialog-Frame
ON value-changed OF t-negative_rests in FRAME Dialog-Frame /* Объекты ЕГАИС */
DO:
    assign t-negative_rests.
    if t-not_eq_rests
    then do :
        t-not_eq_rests = false.
        display t-not_eq_rests with frame {&frame-name}.
    end.
    if t-negative_rests
    then do :
        empty temp-table tt-gds-list .
        for each tt-gds-rests_shop no-lock where tt-gds-rests_shop.alc-code <> "" and tt-gds-rests_shop.egais-qnty < 0 :
            find first tt-gds-list where tt-gds-list.alc-code = tt-gds-rests_shop.alc-code
                                     and tt-gds-list.gds-code = tt-gds-rests_shop.gds-code
                                     no-error.
            if not available tt-gds-list
            then do :
                create tt-gds-list.
                assign
                    tt-gds-list.alc-code = tt-gds-rests_shop.alc-code
                    tt-gds-list.gds-code = tt-gds-rests_shop.gds-code
                .
            end.
        end.
        open query br-rests_shop for each tt-gds-list, each tt-gds-rests_shop where tt-gds-rests_shop.alc-code = tt-gds-list.alc-code
                                                                                and tt-gds-rests_shop.gds-code = tt-gds-list.gds-code
                                                                                and tt-gds-rests_shop.egais-qnty < 0 .
    end.
    else do :
        empty temp-table tt-gds-list .
        for each tt-gds-rests_shop no-lock where tt-gds-rests_shop.alc-code <> "" :
            find first tt-gds-list where tt-gds-list.alc-code = tt-gds-rests_shop.alc-code
                                     and tt-gds-list.gds-code = tt-gds-rests_shop.gds-code
                                     no-error.
            if not available tt-gds-list
            then do :
                create tt-gds-list.
                assign
                    tt-gds-list.alc-code = tt-gds-rests_shop.alc-code
                    tt-gds-list.gds-code = tt-gds-rests_shop.gds-code
                .
            end.
        end.
        open query br-rests_shop for each tt-gds-list, each tt-gds-rests_shop where tt-gds-rests_shop.alc-code <> ""
                                                                              and tt-gds-rests_shop.alc-code = tt-gds-list.alc-code
                                                                              and tt-gds-rests_shop.gds-code = tt-gds-list.gds-code
                                                                              and tt-gds-rests_shop.egais-qnty <> 0 .
    end.
END.
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME t-not_eq_rests
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL t-not_eq_rests Dialog-Frame
ON value-changed OF t-not_eq_rests in FRAME Dialog-Frame /* Объекты ЕГАИС */
DO:
    assign t-not_eq_rests.
    if t-negative_rests
    then do :
        t-negative_rests = false.
        display t-negative_rests with frame {&frame-name}. 
    end.
    if t-not_eq_rests
    then do :
        empty temp-table tt-gds-list .
        for each tt-gds-rests_shop no-lock where tt-gds-rests_shop.alc-code <> "" and (tt-gds-rests_shop.egais-qnty <> tt-gds-rests_shop.TH-qnty)  :
            find first tt-gds-list where tt-gds-list.alc-code = tt-gds-rests_shop.alc-code
                                     and tt-gds-list.gds-code = tt-gds-rests_shop.gds-code
                                     no-error.
            if not available tt-gds-list
            then do :
                create tt-gds-list.
                assign
                    tt-gds-list.alc-code = tt-gds-rests_shop.alc-code
                    tt-gds-list.gds-code = tt-gds-rests_shop.gds-code
                .
            end.
        end.
        open query br-rests_shop for each tt-gds-list, each tt-gds-rests_shop where tt-gds-rests_shop.alc-code = tt-gds-list.alc-code
                                                                                and tt-gds-rests_shop.gds-code = tt-gds-list.gds-code
                                                                                and tt-gds-rests_shop.egais-qnty <> tt-gds-rests_shop.TH-qnty .
    end.
    else do :
        empty temp-table tt-gds-list .
        for each tt-gds-rests_shop no-lock where tt-gds-rests_shop.alc-code <> "" :
            find first tt-gds-list where tt-gds-list.alc-code = tt-gds-rests_shop.alc-code
                                     and tt-gds-list.gds-code = tt-gds-rests_shop.gds-code
                                     no-error.
            if not available tt-gds-list
            then do :
                create tt-gds-list.
                assign
                    tt-gds-list.alc-code = tt-gds-rests_shop.alc-code
                    tt-gds-list.gds-code = tt-gds-rests_shop.gds-code
                .
            end.
        end.
        open query br-rests_shop for each tt-gds-list, each tt-gds-rests_shop where tt-gds-rests_shop.alc-code <> ""
                                                                              and tt-gds-rests_shop.alc-code = tt-gds-list.alc-code
                                                                              and tt-gds-rests_shop.gds-code = tt-gds-list.gds-code
                                                                              and tt-gds-rests_shop.egais-qnty <> 0 .
    end.
END.
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME a-n-c
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL a-n-c Dialog-Frame
ON value-changed OF a-n-c in FRAME Dialog-Frame /* Объекты ЕГАИС */
DO:
    assign a-n-c .
    assign NameContext = "" loc-code = "" loc-alc = "" loc-alc:screen-value = "" .
    case a-n-c :
        when "alc" then do :
            if v-page-current = 1
            then do :
                OPEN QUERY {&browse-name} FOR EACH tt-gds-rests .
                hide NameContext loc-code in frame Dialog-Frame .
                display loc-alc with frame Dialog-Frame .
                apply "entry" to br-rests in frame Dialog-Frame .
            end.
            else do :
                open query br-rests_shop for each tt-gds-list, each tt-gds-rests_shop where tt-gds-rests_shop.alc-code <> ""
                                                                              and tt-gds-rests_shop.alc-code = tt-gds-list.alc-code
                                                                              and tt-gds-rests_shop.gds-code = tt-gds-list.gds-code
                                                                              and tt-gds-rests_shop.egais-qnty <> 0 .
                hide NameContext loc-code in frame Dialog-Frame .
                display loc-alc with frame Dialog-Frame .
                apply "entry" to br-rests_shop in frame Dialog-Frame .
            end.
        end.
        when "context" then do :
            hide loc-alc loc-code in frame Dialog-Frame .
            enable NameContext with frame Dialog-Frame .
            apply "entry" to NameContext in frame Dialog-Frame .
        end.
        when "code" then do :
            OPEN QUERY {&browse-name} FOR EACH tt-gds-rests .
            hide loc-alc NameContext in frame Dialog-Frame .
            enable loc-code with frame Dialog-Frame .
            apply "entry" to loc-code in frame Dialog-Frame .
        end.
    end case.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME NameContext
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL NameContext Dialog-Frame
ON return OF NameContext IN FRAME {&frame-name} do:
    define variable letter as character no-undo .
    assign NameContext.
    if trim(NameContext) = "" then do :
        OPEN QUERY {&browse-name} FOR EACH tt-gds-rests .
    end.
    else do :
        letter = substring(NameContext, length(NameContext), 1) .
        if letter = 'н'
        or letter = 'о'
        or letter = 'э'
        or letter = 'ю'
        or letter = 'я'
        then do :
            if v-page-current = 1
            then
                OPEN QUERY {&browse-name} FOR EACH tt-gds-rests where tt-gds-rests.gds-name contains (trim(NameContext)) INDEXED-REPOSITION .
            else
                OPEN QUERY br-rests_shop FOR EACH tt-gds-list, each tt-gds-rests_shop where tt-gds-rests_shop.gds-name contains (trim(NameContext))
                                                                                        and tt-gds-rests_shop.alc-code <> ""
                                                                                        and tt-gds-rests_shop.alc-code = tt-gds-list.alc-code
                                                                                        and tt-gds-rests_shop.gds-code = tt-gds-list.gds-code
                                                                                        and tt-gds-rests_shop.egais-qnty <> 0 INDEXED-REPOSITION .
        end.
        else do :
            if v-page-current = 1
            then
                OPEN QUERY {&browse-name} FOR EACH tt-gds-rests where tt-gds-rests.gds-name contains (trim(NameContext) + "*") INDEXED-REPOSITION .
            else
                OPEN QUERY br-rests_shop FOR EACH tt-gds-list, each tt-gds-rests_shop where tt-gds-rests_shop.gds-name contains (trim(NameContext) + "*")
                                                                                        and tt-gds-rests_shop.alc-code <> ""
                                                                                        and tt-gds-rests_shop.alc-code = tt-gds-list.alc-code
                                                                                        and tt-gds-rests_shop.gds-code = tt-gds-list.gds-code
                                                                                        and tt-gds-rests_shop.egais-qnty <> 0 INDEXED-REPOSITION .
        end.
    end.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME loc-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL loc-code Dialog-Frame
ON return OF loc-code IN FRAME {&frame-name} do:
    assign loc-code.
    if v-page-current = 1
    then do :
        find first tt-gds-rests no-lock where tt-gds-rests.gds-code = integer(loc-code) no-error.
        if not available tt-gds-rests then do :
            message "Не найден товар с кодом " + loc-code view-as alert-box warning .
        end.
        else do :
            assign tt-rec = recid(tt-gds-rests) .
            reposition br-rests to recid tt-rec .
        end.
    end.
    else do :
        find first tt-gds-rests_shop no-lock where tt-gds-rests_shop.gds-code matches ("*" + loc-code + "*") no-error.
        if not available tt-gds-rests_shop then do :
            message "Не найден товар с кодом " + loc-code view-as alert-box warning .
        end.
        else do :
            assign tt-row2 = rowid(tt-gds-rests_shop) .
            find first tt-gds-list no-lock where tt-gds-list.alc-code = tt-gds-rests_shop.alc-code
                                             and tt-gds-list.gds-code = tt-gds-rests_shop.gds-code no-error.
            if not available tt-gds-list
            then do :
                message "В данной выборке не найден товар с кодом " + loc-code view-as alert-box warning .
            end.
            else do :                                 
                assign tt-row = rowid(tt-gds-list) .
                reposition br-rests_shop to rowid tt-row, tt-row2 .
            end.    
        end.
    end.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME br-rests
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-rests Dialog-Frame
ON any-printable OF br-rests IN FRAME {&frame-name} do:
    if input frame {&frame-name} a-n-c = "alc" then do:
        if last-event:label = " " and
           loc-alc = "" then
        return no-apply.
        find first tt-gds-rests no-lock where tt-gds-rests.alc-code begins (loc-alc + last-event:label) no-error.
        if available tt-gds-rests then do :
            loc-alc = loc-alc + last-event:label.
            disp loc-alc with frame {&frame-name}.
            assign tt-rec = recid(tt-gds-rests) .
            reposition br-rests to recid tt-rec .
        end.
        else bell.
    end.
end.

ON backspace OF br-rests IN FRAME {&frame-name} do:
    if input frame {&frame-name} a-n-c = "alc" then do:
        if loc-alc = "" then
          return no-apply.
        loc-alc = substr (loc-alc, 1, length (loc-alc) - 1).
        find first tt-gds-rests no-lock where tt-gds-rests.alc-code begins loc-alc no-error.
        if available tt-gds-rests then do :
            disp loc-alc with frame {&frame-name}.
            assign tt-rec = recid(tt-gds-rests) .
            reposition br-rests to recid tt-rec .
        end.
    end.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME br-rests_shop
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-rests_shop Dialog-Frame
ON any-printable OF br-rests_shop IN FRAME {&frame-name} do:
    if input frame {&frame-name} a-n-c = "alc" then do:
        if last-event:label = " " and
           loc-alc = "" then
        return no-apply.
        find first tt-gds-rests_shop no-lock where tt-gds-rests_shop.alc-code begins (loc-alc + last-event:label) no-error.
        if available tt-gds-rests_shop then do :
            assign tt-row2 = rowid(tt-gds-rests_shop) .
            find first tt-gds-list no-lock where tt-gds-list.alc-code = tt-gds-rests_shop.alc-code
                                             and tt-gds-list.gds-code = tt-gds-rests_shop.gds-code .
            loc-alc = loc-alc + last-event:label.
            disp loc-alc with frame {&frame-name}.
            assign tt-row = rowid(tt-gds-list) .
            reposition br-rests_shop to rowid tt-row, tt-row2 .
        end.
        else bell.
    end.
end.

ON backspace OF br-rests_shop IN FRAME {&frame-name} do:
    if input frame {&frame-name} a-n-c = "alc" then do:
        if loc-alc = "" then
          return no-apply.
        loc-alc = substr (loc-alc, 1, length (loc-alc) - 1).
        find first tt-gds-rests_shop no-lock where tt-gds-rests_shop.alc-code begins loc-alc no-error.
        if available tt-gds-rests_shop then do :
            assign tt-row2 = rowid(tt-gds-rests_shop) .
            find first tt-gds-list no-lock where tt-gds-list.alc-code = tt-gds-rests_shop.alc-code
                                             and tt-gds-list.gds-code = tt-gds-rests_shop.gds-code .
            disp loc-alc with frame {&frame-name}.
            assign tt-row = rowid(tt-gds-list) .
            reposition br-rests_shop to rowid tt-row, tt-row2 .
        end.
    end.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-mark Dialog-Frame
ON CHOOSE OF b-mark IN FRAME Dialog-Frame /* * */
DO:
/*  {&stdbtn}*/
  if v-page-current = 1
  then do : 
    run proc-b-mark in this-procedure no-error.
  end.  
  else do :
    run proc-b-mark_shop in this-procedure no-error.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME b-sel-all
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sel-all Dialog-Frame
ON CHOOSE OF b-sel-all IN FRAME Dialog-Frame /* + */
DO:
  if v-page-current = 1
  then do : 
      assign select-list = "".
      if not available tt-gds-rests then return.
      for each tt-gds-rests no-lock :
        { gbl/markstrn.i tt-gds-rests select-list }
      end.
      {&browse-name}:refresh() in frame {&frame-name} .
  end.
  else do :
      assign select-list_shop = "".
      if not available tt-gds-rests_shop then return.
      for each tt-gds-rests_shop no-lock :
        { gbl/markstrn.i tt-gds-rests_shop select-list_shop }
      end.
      br-rests_shop:refresh() in frame {&frame-name} .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME b-unmark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-unmark Dialog-Frame
ON CHOOSE OF b-unmark IN FRAME Dialog-Frame /* - */
DO:
  if v-page-current = 1
  then do :
      if not available tt-gds-rests then return.
      select-list  = "".
      {&browse-name}:refresh() in frame {&frame-name} .
  end.
  else do :
      if not available tt-gds-rests_shop then return.
      select-list_shop  = "".
      br-rests_shop:refresh() in frame {&frame-name} .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME b-cancel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-cancel Dialog-Frame
ON CHOOSE OF b-cancel IN FRAME Dialog-Frame /* - */
DO:
    message "Все несохранённые данные будут потеряны. Вы уверены, что хотите выйти?"
    view-as alert-box question buttons yes-no update glog.
    if not glog then return no-apply . 
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME



&Scoped-define SELF-NAME b-connect
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-connect Dialog-Frame
ON CHOOSE OF b-connect IN FRAME Dialog-Frame /* - */
DO:
    if not available tt-gds-rests then return no-apply.
    if tt-gds-rests.gds-code = 0 or tt-gds-rests.gds-code = ? then do :
        message "Данный товар не синхронизирован с ЕГАИС" view-as alert-box .
        return no-apply .
    end.
    assign v-rid = recid(tt-gds-rests) .
    run str/parts-l.w
     (
        input parparentproc
     ,  input v-cntxt-obj-type                /* v-obj-type   */
     ,  input v-cntxt-obj-code                /* v-obj-code   */
     ,  input tt-gds-rests.gds-code      /* p-gds-code   */
     ,  input "":U                      /* p-doc-code   */
     ,  input {&lookup}                 /* p-edit-mode  */
     ,  input {&parts-l_parts-free}     /* p-r-parts    */
     ,  input {&parts-l_object-current} /* p-one-all    */
     ,  input {&choose}                 /* p-call-point */
     , output v-prt-rec                   /* part-recid   */
     ) .
    for first buf_parts no-lock where recid(buf_parts) = v-prt-rec :
        if not can-do(tt-gds-rests.prt-rec,string(recid(buf_parts))) then
        assign
            tt-gds-rests.prt-rec = if tt-gds-rests.prt-rec = "" then string(recid(buf_parts)) else tt-gds-rests.prt-rec + ',' + string(recid(buf_parts))
            tt-gds-rests.TH-qnty = tt-gds-rests.TH-qnty + buf_parts.fact-qnty
        .
    end.
    OPEN QUERY {&browse-name} FOR EACH tt-gds-rests .
    reposition br-rests to recid v-rid .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-save
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-save Dialog-Frame
ON CHOOSE OF b-save IN FRAME Dialog-Frame /* - */
DO:
    if select-list = "" then do :
        message "Не выбрано ни одной строки" view-as alert-box .
        return no-apply.
    end.
    do ii = 1 to num-entries(select-list) :
        v-sel-entry = entry(ii, select-list) .
        for first tt-gds-rests exclusive-lock where recid(tt-gds-rests) = integer(v-sel-entry)
                                                and tt-gds-rests.gds-code > 0
                                                and tt-gds-rests.prt-rec <> ? :
            do jj = 1 to num-entries(tt-gds-rests.prt-rec) :                                        
                for first parts no-lock where recid(parts) = integer(entry(jj,tt-gds-rests.prt-rec)) :                                        
                    run trg/partps.p ( input tt-gds-rests.gds-code
                                   , input parts.in-code
                                   , input {&free-code}
                                   , input parts.part-code
                                   , input v-cntxt-db-num-obj
                                   , input parts.mark-code
                                   , input parts.alc-bottling-date
                                   , input tt-gds-rests.informA_ + ',' + tt-gds-rests.informB_ + ',' + tt-gds-rests.alc-code + ',' + tt-gds-rests.alc-type-code
                                   , input parts.alc-quality-certif-path
                                   , input parts.alc-certif-path
                                   , input parts.alc-imp-type
                                   , input parts.alc-imp-code
                                   ) no-error .  
                end. 
            end.                                
        end. /* for first tt-gds-rests */
    end. /* do ii = 1 to num-entries(select-list) */
    message "Сохранение завершено" view-as alert-box.
    br-rests:refresh () .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME b-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-del Dialog-Frame
ON CHOOSE OF b-del IN FRAME Dialog-Frame /* - */
DO:
    if not available tt-gds-rests then return no-apply.
    message "Вы уверены?"
    view-as alert-box question buttons yes-no update glog.
    if not glog then return no-apply .
    do jj = 1 to num-entries(tt-gds-rests.prt-rec) :                                        
        for first parts no-lock where recid(parts) = integer(entry(jj,tt-gds-rests.prt-rec)) :                                        
            run trg/partps.p ( input tt-gds-rests.gds-code
                           , input parts.in-code
                           , input {&free-code}
                           , input parts.part-code
                           , input v-cntxt-db-num-obj
                           , input parts.mark-code
                           , input parts.alc-bottling-date
                           , input ""
                           , input parts.alc-quality-certif-path
                           , input parts.alc-certif-path
                           , input parts.alc-imp-type
                           , input parts.alc-imp-code
                           ) no-error .  
        end. 
    end.
    assign
        tt-gds-rests.prt-rec = ""
        tt-gds-rests.TH-qnty = 0
    .
    br-rests:refresh () .
END.
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME b-load
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-load Dialog-Frame
ON CHOOSE OF b-load IN FRAME Dialog-Frame /* - */
DO:

    rests:SendRequestUTM() .
    rests_shop:SendRequestUTM() .
    glog = rests_shop:IsSent .
    if glog then enable b-answer WITH FRAME Dialog-Frame.
    else disable b-answer WITH FRAME Dialog-Frame .
    glog = rests_shop:StatusErr .
    if glog then do :
        message rests_shop:Msg view-as alert-box.
        return no-apply.
    end.
/*    else do :                     */
/*        v-replyId = rests:ReplyId.*/
/*    end.                          */
        
    
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME b-answer
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-answer Dialog-Frame
ON CHOOSE OF b-answer IN FRAME Dialog-Frame /* - */
DO:
    run waitfram-show in this-procedure ("Ждите...") .
    
    bh-gds-egais = rests:GetHndlTable() .
    glog = rests:StatusErr .
    if glog then do :
        run waitfram-hide in this-procedure no-error .
        message rests:Msg view-as alert-box.
        return no-apply.
    end.
    if not valid-handle(bh-gds-egais) then do :
        run waitfram-hide in this-procedure no-error .
        message "Ошибка при получении ответа от ЕГАИС" view-as alert-box error .
        return no-apply .
    end.
    empty temp-table tt-gds-rests .
    create query qh-gds-egais .
    qh-gds-egais:set-buffers (bh-gds-egais) .
    qh-gds-egais:query-prepare ("for each tt-gds-rests-eg").
    qh-gds-egais:query-open.
    _repeat:
    repeat:
        qh-gds-egais:get-next ().
        if qh-gds-egais:query-off-end then leave _repeat.
        create tt-gds-rests.
        buffer tt-gds-rests:handle:buffer-copy (bh-gds-egais) .
        assign tt-gds-rests.fromEgais = yes no-error.
        find first X_ext-classif no-lock where X_ext-classif.classif-subject = {&table_goods}
                                           and X_ext-classif.classif-name = {&extclass_goods_esys}
                                           AND X_ext-classif.db-num = 0
                                           and X_ext-classif.key#_two = v-ext-sys
                                           and X_ext-classif.key#_three = 0
                                           and X_ext-classif.charkey_one = tt-gds-rests.alc-code
                                           and X_ext-classif.charkey_two = ""
                                           and X_ext-classif.charkey_three = ""
                                           and X_ext-classif.nonunique = 0
                                           no-error.
        if available X_ext-classif then do :
            find first buf_goods no-lock where buf_goods.gds-code = X_ext-classif.key#_one .
            assign
                tt-gds-rests.gds-code   = buf_goods.gds-code
                tt-gds-rests.gds-name   = buf_goods.gds-name
            no-error .
        end.
        if available buf_goods then do :
            if (not tt-gds-rests.packed and buf_goods.unit-cli <> buf_goods.unit-base and buf_goods.cli-base-rate <> 1.0)
            then assign tt-gds-rests.egais-qnty = tt-gds-rests.egais-qnty * buf_goods.cli-base-rate .
            for each buf_parts no-lock where buf_parts.artic      = buf_goods.artic
                                           and buf_parts.prod-type  = buf_goods.prod-type
                                           and buf_parts.prod-code  = buf_goods.prod-code
                                           and buf_parts.obj-type   = v-cntxt-obj-type
                                           and buf_parts.obj-code   = v-cntxt-obj-code
                                           and buf_parts.out-code   = {&free-code}
                                           and num-entries(buf_parts.alc-ref-ab-path) = 4
                                           and entry(1, buf_parts.alc-ref-ab-path) = tt-gds-rests.informA_
                                           and entry(2, buf_parts.alc-ref-ab-path) = tt-gds-rests.informB_ :

                assign tt-gds-rests.TH-qnty = tt-gds-rests.TH-qnty + buf_parts.fact-qnty no-error .
                assign tt-gds-rests.prt-rec = if tt-gds-rests.prt-rec = "" then string(recid(buf_parts)) else tt-gds-rests.prt-rec + ',' + string(recid(buf_parts)) no-error .
            end.
        end.
    end.
    OPEN QUERY {&browse-name} FOR EACH tt-gds-rests .
    apply "value-changed" to br-rests .
    enable a-n-c with FRAME {&FRAME-NAME}.
    apply "value-changed" to a-n-c in FRAME {&FRAME-NAME}.
/*    run waitfram-hide in this-procedure no-error .*/
    v-DT-rests = substring(replace(rests:v-date-time, "T", " "), 1, length(rests:v-date-time) - 4) .
    if v-page-current = 1 then display v-DT-rests with FRAME {&FRAME-NAME}.
    
    
    bh-gds-egais_shop = rests_shop:GetHndlTable() .
    glog = rests_shop:StatusErr .
    if glog then do :
        run waitfram-hide in this-procedure no-error .
        message rests_shop:Msg view-as alert-box.
        return no-apply.
    end.
    if not valid-handle(bh-gds-egais_shop) then do :
        run waitfram-hide in this-procedure no-error .
        message "Ошибка при получении ответа от ЕГАИС" view-as alert-box error .
        return no-apply .
    end.
    empty temp-table tt-gds-rests_shop .
    empty temp-table tt-gds-list .
    create query qh-gds-egais_shop .
    qh-gds-egais_shop:set-buffers (bh-gds-egais_shop) .
    qh-gds-egais_shop:query-prepare ("for each tt-gds-rests-eg_shop").
    qh-gds-egais_shop:query-open.
    _repeat_shop:
    repeat:
        qh-gds-egais_shop:get-next ().
        if qh-gds-egais_shop:query-off-end then leave _repeat_shop.
        create tt-gds-rests_shop.
        buffer tt-gds-rests_shop:handle:buffer-copy (bh-gds-egais_shop) .
        assign tt-gds-rests_shop.fromEgais = yes .
        for each X_ext-classif no-lock where X_ext-classif.classif-subject = {&table_goods} 
                                           and X_ext-classif.classif-name = {&extclass_goods_esys} 
                                           AND X_ext-classif.db-num = 0
                                           and X_ext-classif.key#_two = v-ext-sys
                                           and X_ext-classif.key#_three = 0
                                           and X_ext-classif.charkey_one = tt-gds-rests_shop.alc-code
                                           and X_ext-classif.charkey_two = ""
                                           and X_ext-classif.charkey_three = ""
                                           and X_ext-classif.nonunique = 0 :
            find first buf_goods no-lock where buf_goods.gds-code = X_ext-classif.key#_one .
            assign
                tt-gds-rests_shop.gds-code   = if tt-gds-rests_shop.gds-code = "" then string(buf_goods.gds-code) else tt-gds-rests_shop.gds-code + ", " + string(buf_goods.gds-code)
                tt-gds-rests_shop.gds-name   = buf_goods.gds-name
            .
            
            if (not tt-gds-rests_shop.packed and buf_goods.unit-cli <> buf_goods.unit-base and buf_goods.cli-base-rate <> 1.0)
            then assign tt-gds-rests_shop.egais-qnty = tt-gds-rests_shop.egais-qnty * buf_goods.cli-base-rate .
            for each buf_parts no-lock where buf_parts.artic      = buf_goods.artic
                                           and buf_parts.prod-type  = buf_goods.prod-type
                                           and buf_parts.prod-code  = buf_goods.prod-code
                                           and buf_parts.obj-type   = v-cntxt-obj-type
                                           and buf_parts.obj-code   = v-cntxt-obj-code
                                           and buf_parts.out-code   = {&free-code}
                                           and num-entries(buf_parts.alc-ref-ab-path) = 4
                                           and entry(3, buf_parts.alc-ref-ab-path) = tt-gds-rests_shop.alc-code :
/*                                           and entry(1, buf_parts.alc-ref-ab-path) = tt-gds-rests.informA_  */
/*                                           and entry(2, buf_parts.alc-ref-ab-path) = tt-gds-rests.informB_ :*/
                                           
                assign tt-gds-rests_shop.TH-qnty = tt-gds-rests_shop.TH-qnty + buf_parts.fact-qnty .
/*                assign tt-gds-rests.prt-rec = if tt-gds-rests.prt-rec = "" then string(recid(buf_parts)) else tt-gds-rests.prt-rec + ',' + string(recid(buf_parts)) .*/
            end.
        end. 
        for each tt-gds-rests no-lock where tt-gds-rests.alc-code = tt-gds-rests_shop.alc-code :
            assign tt-gds-rests_shop.egais-qnty_stock = tt-gds-rests_shop.egais-qnty_stock + tt-gds-rests.egais-qnty . 
        end.
        find first tt-gds-list where tt-gds-list.alc-code = tt-gds-rests_shop.alc-code
                                 and tt-gds-list.gds-code = tt-gds-rests_shop.gds-code
                                 no-error.
        if not available tt-gds-list
        then do :
            create tt-gds-list.
            assign
                tt-gds-list.alc-code = tt-gds-rests_shop.alc-code
                tt-gds-list.gds-code = tt-gds-rests_shop.gds-code
            .
        end.
    end.
    OPEN QUERY br-rests_shop FOR each tt-gds-list, EACH tt-gds-rests_shop where tt-gds-rests_shop.alc-code = tt-gds-list.alc-code
                                                                            and tt-gds-rests_shop.gds-code = tt-gds-list.gds-code .
    apply "value-changed" to br-rests_shop .
    run waitfram-hide in this-procedure no-error .
    v-DT-rests_shop = substring(replace(rests_shop:v-date-time, "T", " "), 1, length(rests_shop:v-date-time) - 4) .
    if v-page-current = 2 then display v-DT-rests_shop with FRAME {&FRAME-NAME}.
        
    run waitfram-hide in this-procedure .
/*    enable a-n-c with FRAME {&FRAME-NAME}.                */
/*    apply "value-changed" to a-n-c in FRAME {&FRAME-NAME}.*/
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME m-writeOff
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m-witeOff Dialog-Frame
ON CHOOSE OF menu-item m-writeOff in menu m-func /* - */
DO:
    define variable v-awo-num as character no-undo .
    define variable v-awo-date as date no-undo .
    define variable v-awo-type as character no-undo .
    define variable v-ok as logical no-undo .
    define variable v-position as integer no-undo .
    define variable v-part-num    as integer   no-undo .
    define variable v-clob-db-num as integer   no-undo .
    define variable v-int64-id    as int64     no-undo .
    define variable v-info        as character no-undo .
    
    if select-list = "" then do :
        message "Не выбрано ни одной строки" view-as alert-box .
        return no-apply.
    end.  
    empty temp-table tt-gds-act .
    run bge/egais-makeWriteOff.w  (input parparentproc, 
                                   output v-awo-num,
                                   output v-awo-date,
                                   output v-awo-type,
                                   output v-ok) .
    if not v-ok then return no-apply .
    create tt-act-header.
    assign
        tt-act-header.num   = v-awo-num
        tt-act-header.date_ = v-awo-date
        tt-act-header.type_ = v-awo-type
        tt-act-header.is-sent = no
        v-position = 0
    .
    
    do ii = 1 to num-entries(select-list) :
        v-sel-entry = entry(ii, select-list) .
        for first tt-gds-rests exclusive-lock where recid(tt-gds-rests) = integer(v-sel-entry) :
            assign v-position = v-position + 1 .
            create tt-gds-act.
            assign
                tt-gds-act.num          = tt-act-header.num
                tt-gds-act.position_    = v-position
                tt-gds-act.alc-code     = tt-gds-rests.alc-code
                tt-gds-act.gds-code     = tt-gds-rests.gds-code
                tt-gds-act.gds-name     = tt-gds-rests.gds-name
                tt-gds-act.inform-B     = tt-gds-rests.informB_
                tt-gds-act.qnty         = tt-gds-rests.egais-qnty - tt-gds-rests.TH-qnty
            . 
            find first buf_goods no-lock where buf_goods.gds-code = tt-gds-rests.gds-code no-error .
            if available buf_goods
            and (not tt-gds-rests.packed and buf_goods.unit-cli <> buf_goods.unit-base and buf_goods.cli-base-rate <> 1.0)
            then do :
                tt-gds-act.qnty = tt-gds-act.qnty / buf_goods.cli-base-rate .
            end. 
        end.
    end.
    
    run makeXML in this-procedure .
    assign
        v-clob-db-num = ?
        v-int64-id = 0
        v-info = tt-act-header.num + {&delim-par} + string(tt-act-header.date_) + {&delim-par} + tt-act-header.type_ + {&delim-par} + string(tt-act-header.is-sent) + {&delim-par} + tt-act-header.answer_
    .
    run gbl/file2clb.p ( input {&add-def}
                          ,input ",yes"
                          ,input ? /*p-bh*/
                          ,input tt-act-header.num /*p-uniq-key-rec*/
                          ,input {&lob-egais-awo} /*p-field-*/
                          ,input v-info /*p-descr*/
                          ,input-output v-part-num
                          ,input {&lob-egais-awo}
                          ,input-output v-clob-db-num
                          ,input-output v-int64-id
                          ,input search (v-file)
                          ,input '' /*p-src-encoding*/
                          ) no-error .
    message "Акт сформирован. Вы можете отправить его или изменить количества из интерфейса 'Акты о списании товаров'" view-as alert-box .                      
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME m-writeOff
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m-witeOff Dialog-Frame
ON CHOOSE OF menu-item m-writeOff_shop in menu m-func_shop /* - */
DO:
    define variable v-awos-num as character no-undo .
    define variable v-awos-date as date no-undo .
    define variable v-awos-type as character no-undo .
    define variable v-ok as logical no-undo .
    define variable v-position as integer no-undo .
    define variable v-part-num    as integer   no-undo .
    define variable v-clob-db-num as integer   no-undo .
    define variable v-int64-id    as int64     no-undo .
    define variable v-info        as character no-undo .
    
    if select-list_shop = "" then do :
        message "Не выбрано ни одной строки" view-as alert-box .
        return no-apply.
    end.  
    empty temp-table tt-gds-act-awos .
    run bge/egais-makeWriteOff.w  (input parparentproc, 
                                   output v-awos-num,
                                   output v-awos-date,
                                   output v-awos-type,
                                   output v-ok) .
    if not v-ok then return no-apply .
    create tt-act-header-awos.
    assign
        tt-act-header-awos.num   = substring(v-awos-num, 1, 3) + "S" + substring(v-awos-num, 4)
        tt-act-header-awos.date_ = v-awos-date
        tt-act-header-awos.type_ = v-awos-type
        tt-act-header-awos.is-sent = no
        v-position = 0
    .
    
    do ii = 1 to num-entries(select-list_shop) :
        v-sel-entry = entry(ii, select-list_shop) .
        for first tt-gds-rests_shop exclusive-lock where recid(tt-gds-rests_shop) = integer(v-sel-entry) :
            assign v-position = v-position + 1 .
            create tt-gds-act-awos.
            assign
                tt-gds-act-awos.num          = tt-act-header-awos.num
                tt-gds-act-awos.position_    = v-position
                tt-gds-act-awos.alc-code     = tt-gds-rests_shop.alc-code
                tt-gds-act-awos.gds-name     = tt-gds-rests_shop.gds-name
                tt-gds-act-awos.qnty         = tt-gds-rests_shop.egais-qnty - tt-gds-rests_shop.TH-qnty
            .  
            tt-gds-act-awos.gds-code     = integer(tt-gds-rests_shop.gds-code) no-error .
            find first buf_goods no-lock where buf_goods.gds-code = integer(tt-gds-rests_shop.gds-code) no-error .
            if available buf_goods
            and (not tt-gds-rests_shop.packed and buf_goods.unit-cli <> buf_goods.unit-base and buf_goods.cli-base-rate <> 1.0)
            then do :
                tt-gds-act-awos.qnty = tt-gds-act-awos.qnty / buf_goods.cli-base-rate .
            end.
        end.
    end.
    
    run makeXML-awos in this-procedure .
    assign
        v-clob-db-num = ?
        v-int64-id = 0
        v-info = tt-act-header-awos.num + {&delim-par} + string(tt-act-header-awos.date_) + {&delim-par} + tt-act-header-awos.type_ + {&delim-par} + string(tt-act-header-awos.is-sent) + {&delim-par} + tt-act-header-awos.answer_
    .
    run gbl/file2clb.p ( input {&add-def}
                          ,input ",yes"
                          ,input ? /*p-bh*/
                          ,input tt-act-header-awos.num /*p-uniq-key-rec*/
                          ,input {&lob-egais-awo_shop} /*p-field-*/
                          ,input v-info /*p-descr*/
                          ,input-output v-part-num
                          ,input {&lob-egais-awo_shop}
                          ,input-output v-clob-db-num
                          ,input-output v-int64-id
                          ,input search (v-file-awos)
                          ,input '' /*p-src-encoding*/
                          ) no-error .
    message "Акт сформирован. Вы можете отправить его или изменить количества из интерфейса 'Акты о списании товаров из торгового зала'" view-as alert-box .                      
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME m-tts
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m-tts Dialog-Frame
ON CHOOSE OF menu-item m-tts in menu m-func /* - */
DO:
    define variable v-tts-num as character no-undo .
    define variable v-tts-date as date no-undo .
    define variable v-tts-type as character no-undo .
    define variable v-ok as logical no-undo .
    define variable v-position as integer no-undo .
    define variable v-part-num    as integer   no-undo .
    define variable v-clob-db-num as integer   no-undo .
    define variable v-int64-id    as int64     no-undo .
    define variable v-info        as character no-undo .
    
    empty temp-table tt-gds-act-tts .
    if select-list = "" then do :
        message "Не выбрано ни одной строки" view-as alert-box .
        return no-apply.
    end.  
    run bge/egais-makeTTS.w  (input parparentproc,
                               output v-tts-num,
                               output v-tts-date,
                               output v-ok) .
    if not v-ok then return no-apply .
    create tt-act-header-tts.
    assign
        tt-act-header-tts.num   = v-tts-num
        tt-act-header-tts.date_ = v-tts-date
        tt-act-header-tts.is-sent = no
        v-position = 0
    .
    
    do ii = 1 to num-entries(select-list) :
        v-sel-entry = entry(ii, select-list) .
        for first tt-gds-rests exclusive-lock where recid(tt-gds-rests) = integer(v-sel-entry) :
            assign v-position = v-position + 1 .
            create tt-gds-act-tts.
            assign
                tt-gds-act-tts.num          = tt-act-header-tts.num
                tt-gds-act-tts.position_    = v-position
                tt-gds-act-tts.alc-code     = tt-gds-rests.alc-code
                tt-gds-act-tts.gds-code     = tt-gds-rests.gds-code
                tt-gds-act-tts.gds-name     = tt-gds-rests.gds-name
                tt-gds-act-tts.inform-B     = tt-gds-rests.informB_
                tt-gds-act-tts.qnty         = tt-gds-rests.egais-qnty
            . 
            find first buf_goods no-lock where buf_goods.gds-code = tt-gds-rests.gds-code no-error .
            if available buf_goods
            and (not tt-gds-rests.packed and buf_goods.unit-cli <> buf_goods.unit-base and buf_goods.cli-base-rate <> 1.0)
            then do :
                tt-gds-act-tts.qnty = tt-gds-act-tts.qnty / buf_goods.cli-base-rate .
            end.
        end.
    end.
    
    run makeXML-tts in this-procedure .
    assign
        v-clob-db-num = ?
        v-int64-id = 0
        v-info = tt-act-header-tts.num + {&delim-par} + string(tt-act-header-tts.date_) + {&delim-par} + string(tt-act-header-tts.is-sent) + {&delim-par} + tt-act-header-tts.answer_
    .
    run gbl/file2clb.p ( input {&add-def}
                          ,input ",yes"
                          ,input ? /*p-bh*/
                          ,input tt-act-header-tts.num /*p-uniq-key-rec*/
                          ,input {&lob-egais-tts} /*p-field-*/
                          ,input v-info /*p-descr*/
                          ,input-output v-part-num
                          ,input {&lob-egais-tts}
                          ,input-output v-clob-db-num
                          ,input-output v-int64-id
                          ,input search (v-file-tts)
                          ,input '' /*p-src-encoding*/
                          ) no-error .
    message "Акт сформирован. Вы можете отправить его или изменить количества из интерфейса 'Передача продукции в торговый зал'" view-as alert-box .                      
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME m-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m-print Dialog-Frame
ON CHOOSE OF menu-item m-print in menu m-func /* - */
OR CHOOSE OF menu-item m-print in menu m-func_shop
DO:
    find first tt-gds-rests no-lock no-error .
    if not available tt-gds-rests
    then do :
        message "Сначала получите остатки из ЕГАИС" view-as alert-box .
        return no-apply .
    end.
    run PrintRests.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME    

&Scoped-define SELF-NAME m-print_shop
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m-print_shop Dialog-Frame
ON CHOOSE OF menu-item m-print_shop in menu m-func /* - */
OR CHOOSE OF menu-item m-print_shop in menu m-func_shop
DO:
    find first tt-gds-rests no-lock no-error .
    find first tt-gds-rests_shop no-lock no-error .
    if not available tt-gds-rests_shop and available tt-gds-rests
    then do :
        message "Нет остатков по второму регистру (магазину)" view-as alert-box .
        return no-apply .
    end.
    if not available tt-gds-rests_shop and not available tt-gds-rests
    then do :
        message "Сначала получите остатки из ЕГАИС" view-as alert-box .
        return no-apply .
    end.
    run PrintRests_shop.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME   

&Scoped-define SELF-NAME m-compare
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m-compare Dialog-Frame
ON CHOOSE OF menu-item m-compare in menu m-func_shop
DO:
    find first tt-gds-rests_shop no-lock no-error .
    if not available tt-gds-rests_shop
    then do :
        message "Сначала получите остатки из ЕГАИС" view-as alert-box .
        return no-apply .
    end.
    run CompareRests.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME 

&Scoped-define SELF-NAME m-marks-compare
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m-marks-compare Dialog-Frame
ON CHOOSE OF menu-item m-marks-compare in menu m-func_shop /* - */
DO:
    find first tt-gds-rests_shop no-lock no-error .
    if not available tt-gds-rests_shop
    then do :
        message "Сначала получите остатки из ЕГАИС" view-as alert-box .
        return no-apply .
    end.
    run MarksCompareRests.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME 

&Scoped-define SELF-NAME m-list
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m-list Dialog-Frame
ON CHOOSE OF menu-item m-list in menu m-func_shop /* - */
DO:
    find first tt-gds-rests_shop no-lock no-error .
    if not available tt-gds-rests_shop
    then do :
        message "Сначала получите остатки из ЕГАИС" view-as alert-box .
        return no-apply .
    end.
/*    run gbl/inidebug.p .*/
    run ListView.
    OPEN QUERY br-rests_shop FOR EACH tt-gds-list, each tt-gds-rests_shop where tt-gds-rests_shop.alc-code = tt-gds-list.alc-code
                                                                            and tt-gds-rests_shop.gds-code = tt-gds-list.gds-code .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME 

&Scoped-define SELF-NAME m-all
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m-all Dialog-Frame
ON CHOOSE OF menu-item m-all in menu m-func_shop /* - */
DO:
    find first tt-gds-rests_shop no-lock no-error .
    if available tt-gds-rests_shop
    then do :
        message "Сначала получите остатки из ЕГАИС" view-as alert-box .
        return no-apply .
    end.
    empty temp-table tt-gds-list .
    for each tt-gds-rests_shop no-lock where tt-gds-rests_shop.alc-code <> "" :
        find first tt-gds-list where tt-gds-list.alc-code = tt-gds-rests_shop.alc-code
                                 and tt-gds-list.gds-code = tt-gds-rests_shop.gds-code
                                 no-error.
        if not available tt-gds-list
        then do :
            create tt-gds-list.
            assign
                tt-gds-list.alc-code = tt-gds-rests_shop.alc-code
                tt-gds-list.gds-code = tt-gds-rests_shop.gds-code
            .
        end.
    end.
    OPEN QUERY br-rests_shop FOR EACH tt-gds-list, each tt-gds-rests_shop where tt-gds-rests_shop.alc-code = tt-gds-list.alc-code
                                                                            and tt-gds-rests_shop.gds-code = tt-gds-list.gds-code
                                                                            and tt-gds-rests_shop.egais-qnty <> 0 .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME 

&Scoped-define SELF-NAME m-load-all
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m-load-all Dialog-Frame
ON CHOOSE OF menu-item m-load-all in menu m-func /* - */
OR CHOOSE OF menu-item m-load-all in menu m-func_shop
DO:
    v-num-objs = 0 .
    empty temp-table tt-obj-list .
    for each thbj-attr no-lock where thbj-attr.upper-prop-code = {&attr-egais-host}
                                 and thbj-attr.prop-code = {&attr-egais-host_egais-fsrar} :
        if thbj-attr.obj-code <> 0
        then do :
            create tt-obj-list .
            assign 
                tt-obj-list.obj-type = thbj-attr.obj-type
                tt-obj-list.obj-code = thbj-attr.obj-code
            .
            find first buf_clients no-lock where buf_clients.obj-type = tt-obj-list.obj-type and buf_clients.obj-code = tt-obj-list.obj-code.
            find first buf_firm no-lock where buf_firm.firm-code = buf_clients.host-code .
            assign tt-obj-list.inn = buf_firm.inn .
            v-num-objs = v-num-objs + 1 .
        end.                             
    end.
    v-num-loads = 0 .
    for each tt-obj-list no-lock :
          empty temp-table thbjattr_thbj-attr .
          run adm/shattri.p (
               input "get":U
              ,input tt-obj-list.obj-type
              ,input tt-obj-list.obj-code
              ,input {&attr-egais-host}
              ,input {&attr-egais-host_egais-fsrar}
              ,output v-value-character
              ,output v-value-date
              ,output v-value-decimal
              ,output v-value-integer
              ,output v-value-logical
              ,output v-value-type
              ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
              ) no-error .
          assign
            v-fs-rar-list = v-value-character
          .
          
          rests = new Rests(tt-obj-list.obj-type, tt-obj-list.obj-code, v-fs-rar-list, tt-obj-list.inn) .
          rests:DbNum = v-cntxt-db-num .
          rests:User_Id = v-cntxt-userid .
          
          rests_shop = new Rests_shop(tt-obj-list.obj-type, tt-obj-list.obj-code, v-fs-rar-list, tt-obj-list.inn) .
          rests_shop:DbNum = v-cntxt-db-num .
          rests_shop:User_Id = v-cntxt-userid .
          
          rests:SendRequestUTM() .
          rests_shop:SendRequestUTM() .
          glog = rests_shop:IsSent .
          if glog and v-cntxt-obj-type = tt-obj-list.obj-type
                  and v-cntxt-obj-code = tt-obj-list.obj-code
          then enable b-answer WITH FRAME Dialog-Frame.
          else disable b-answer WITH FRAME Dialog-Frame .
          glog = rests_shop:StatusErr .
          if glog then do :
              message tt-obj-list.obj-type string(tt-obj-list.obj-code) skip rests_shop:Msg view-as alert-box.
              next.
          end.
          v-num-loads = v-num-loads + 1 .
    end.
    
    rests = new Rests(v-cntxt-obj-type, v-cntxt-obj-code, v-fs-rar, v-org-inn) .
    rests:DbNum = v-cntxt-db-num .
    rests:User_Id = v-cntxt-userid .
     
    rests_shop = new Rests_shop(v-cntxt-obj-type, v-cntxt-obj-code, v-fs-rar, v-org-inn) .
    rests_shop:DbNum = v-cntxt-db-num .
    rests_shop:User_Id = v-cntxt-userid .
    
    message "Отправлен запрос остатков на " string(v-num-loads) " из " string(v-num-objs) " объектах" view-as alert-box.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME 

&Scoped-define SELF-NAME m-file
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m-file Dialog-Frame
ON CHOOSE OF menu-item m-file in menu m-func /* - */
OR CHOOSE OF menu-item m-file in menu m-func_shop
DO:
    if search(v-fn-rests) = ? and search(v-fn-rests_shop) = ?
    then do :
        message "Не найдены файлы с последними остатками из ЕГАИС" view-as alert-box .
        return no-apply.
    end.
    else if search(v-fn-rests) = ?
    then do :
        message "Не найден файл с последними остатками на Складе из ЕГАИС" skip
                "Будут загружены остатки в Магазине" view-as alert-box .
    end.
    else if search(v-fn-rests_shop) = ?
    then do :
        message "Не найден файл с последними остатками в Магазине из ЕГАИС" skip
                "Будут загружены остатки на Складе" view-as alert-box .
    end.
    
    if search(v-fn-rests) <> ?
    then do :
        run waitfram-show in this-procedure ("Ждите...") .
        empty temp-table tt-gds-rests .
        bh-gds-egais = rests:ParseResponse(v-fn-rests) .
        glog = rests:StatusErr .
        if glog then do :
            run waitfram-hide in this-procedure no-error .
            message rests:Msg view-as alert-box.
            return no-apply.
        end.
        if not valid-handle(bh-gds-egais) then do :
            run waitfram-hide in this-procedure no-error .
            message "Ошибка при загрузке остатков на Складе ЕГАИС" view-as alert-box error .
            return no-apply .
        end.
        create query qh-gds-egais .
        qh-gds-egais:set-buffers (bh-gds-egais) .
        qh-gds-egais:query-prepare ("for each tt-gds-rests-eg").
        qh-gds-egais:query-open.
        _repeat:
        repeat:
            qh-gds-egais:get-next ().
            if qh-gds-egais:query-off-end then leave _repeat.
            create tt-gds-rests.
            buffer tt-gds-rests:handle:buffer-copy (bh-gds-egais) .
            assign tt-gds-rests.fromEgais = yes no-error.
            find first X_ext-classif no-lock where X_ext-classif.classif-subject = {&table_goods}
                                               and X_ext-classif.classif-name = {&extclass_goods_esys}
                                               AND X_ext-classif.db-num = 0
                                               and X_ext-classif.key#_two = v-ext-sys
                                               and X_ext-classif.key#_three = 0
                                               and X_ext-classif.charkey_one = tt-gds-rests.alc-code
                                               and X_ext-classif.charkey_two = ""
                                               and X_ext-classif.charkey_three = ""
                                               and X_ext-classif.nonunique = 0
                                               no-error.
            if available X_ext-classif then do :
                find first buf_goods no-lock where buf_goods.gds-code = X_ext-classif.key#_one .
                assign
                    tt-gds-rests.gds-code   = buf_goods.gds-code
                    tt-gds-rests.gds-name   = buf_goods.gds-name
                no-error .
            end.
            if available buf_goods then do :
                if (not tt-gds-rests.packed and buf_goods.unit-cli <> buf_goods.unit-base and buf_goods.cli-base-rate <> 1.0)
                then assign tt-gds-rests.egais-qnty = tt-gds-rests.egais-qnty * buf_goods.cli-base-rate .
                for each buf_parts no-lock where buf_parts.artic      = buf_goods.artic
                                               and buf_parts.prod-type  = buf_goods.prod-type
                                               and buf_parts.prod-code  = buf_goods.prod-code
                                               and buf_parts.obj-type   = v-cntxt-obj-type
                                               and buf_parts.obj-code   = v-cntxt-obj-code
                                               and buf_parts.out-code   = {&free-code}
                                               and num-entries(buf_parts.alc-ref-ab-path) = 4
                                               and entry(1, buf_parts.alc-ref-ab-path) = tt-gds-rests.informA_
                                               and entry(2, buf_parts.alc-ref-ab-path) = tt-gds-rests.informB_ :
    
                    assign tt-gds-rests.TH-qnty = tt-gds-rests.TH-qnty + buf_parts.fact-qnty no-error .
                    assign tt-gds-rests.prt-rec = if tt-gds-rests.prt-rec = "" then string(recid(buf_parts)) else tt-gds-rests.prt-rec + ',' + string(recid(buf_parts)) no-error .
                end.
            end.
        end.
        OPEN QUERY {&browse-name} FOR EACH tt-gds-rests .
        apply "value-changed" to br-rests in FRAME {&FRAME-NAME}.
        enable a-n-c with FRAME {&FRAME-NAME}.
        apply "value-changed" to a-n-c in FRAME {&FRAME-NAME}.
/*        run waitfram-hide in this-procedure no-error .*/
        v-DT-rests = substring(replace(rests:v-date-time, "T", " "), 1, length(rests:v-date-time) - 4) .
        if v-page-current = 1 then display v-DT-rests with FRAME {&FRAME-NAME}.
    end.
    
    if search(v-fn-rests_shop) <> ?
    then do :
        empty temp-table tt-gds-rests_shop .
        empty temp-table tt-gds-list .
        bh-gds-egais_shop = rests_shop:ParseResponse(v-fn-rests_shop) .
        glog = rests_shop:StatusErr .
        if glog then do :
            run waitfram-hide in this-procedure no-error .
            message rests_shop:Msg view-as alert-box.
            return no-apply.
        end.
        if not valid-handle(bh-gds-egais_shop) then do :
            run waitfram-hide in this-procedure no-error .
            message "Ошибка при получении ответа от ЕГАИС" view-as alert-box error .
            return no-apply .
        end.
        create query qh-gds-egais_shop .
        qh-gds-egais_shop:set-buffers (bh-gds-egais_shop) .
        qh-gds-egais_shop:query-prepare ("for each tt-gds-rests-eg_shop").
        qh-gds-egais_shop:query-open.
        _repeat_shop:
        repeat:
            qh-gds-egais_shop:get-next ().
            if qh-gds-egais_shop:query-off-end then leave _repeat_shop.
            create tt-gds-rests_shop.
            buffer tt-gds-rests_shop:handle:buffer-copy (bh-gds-egais_shop) .
            assign tt-gds-rests_shop.fromEgais = yes .
            for each X_ext-classif no-lock where X_ext-classif.classif-subject = {&table_goods} 
                                               and X_ext-classif.classif-name = {&extclass_goods_esys} 
                                               AND X_ext-classif.db-num = 0
                                               and X_ext-classif.key#_two = v-ext-sys
                                               and X_ext-classif.key#_three = 0
                                               and X_ext-classif.charkey_one = tt-gds-rests_shop.alc-code
                                               and X_ext-classif.charkey_two = ""
                                               and X_ext-classif.charkey_three = ""
                                               and X_ext-classif.nonunique = 0 :
                find first buf_goods no-lock where buf_goods.gds-code = X_ext-classif.key#_one .
                assign
                    tt-gds-rests_shop.gds-code   = if tt-gds-rests_shop.gds-code = "" then string(buf_goods.gds-code) else tt-gds-rests_shop.gds-code + ", " + string(buf_goods.gds-code)
                    tt-gds-rests_shop.gds-name   = buf_goods.gds-name
                .
                
                if (not tt-gds-rests_shop.packed and buf_goods.unit-cli <> buf_goods.unit-base and buf_goods.cli-base-rate <> 1.0)
                then assign tt-gds-rests_shop.egais-qnty = tt-gds-rests_shop.egais-qnty * buf_goods.cli-base-rate .
                for each buf_parts no-lock where buf_parts.artic      = buf_goods.artic
                                               and buf_parts.prod-type  = buf_goods.prod-type
                                               and buf_parts.prod-code  = buf_goods.prod-code
                                               and buf_parts.obj-type   = v-cntxt-obj-type
                                               and buf_parts.obj-code   = v-cntxt-obj-code
                                               and buf_parts.out-code   = {&free-code}
                                               and num-entries(buf_parts.alc-ref-ab-path) = 4
                                               and entry(3, buf_parts.alc-ref-ab-path) = tt-gds-rests_shop.alc-code :
    /*                                           and entry(1, buf_parts.alc-ref-ab-path) = tt-gds-rests.informA_  */
    /*                                           and entry(2, buf_parts.alc-ref-ab-path) = tt-gds-rests.informB_ :*/
                                               
                    assign tt-gds-rests_shop.TH-qnty = tt-gds-rests_shop.TH-qnty + buf_parts.fact-qnty .
    /*                assign tt-gds-rests.prt-rec = if tt-gds-rests.prt-rec = "" then string(recid(buf_parts)) else tt-gds-rests.prt-rec + ',' + string(recid(buf_parts)) .*/
                end.
            end. 
            for each tt-gds-rests no-lock where tt-gds-rests.alc-code = tt-gds-rests_shop.alc-code :
                assign tt-gds-rests_shop.egais-qnty_stock = tt-gds-rests_shop.egais-qnty_stock + tt-gds-rests.egais-qnty . 
            end.
            find first tt-gds-list where tt-gds-list.alc-code = tt-gds-rests_shop.alc-code
                                     and tt-gds-list.gds-code = tt-gds-rests_shop.gds-code
                                     no-error.
            if not available tt-gds-list
            then do :
                create tt-gds-list.
                assign
                    tt-gds-list.alc-code = tt-gds-rests_shop.alc-code
                    tt-gds-list.gds-code = tt-gds-rests_shop.gds-code
                .
            end.
        end.
        OPEN QUERY br-rests_shop FOR each tt-gds-list, EACH tt-gds-rests_shop where tt-gds-rests_shop.alc-code = tt-gds-list.alc-code
                                                                                and tt-gds-rests_shop.gds-code = tt-gds-list.gds-code .
        apply "value-changed" to br-rests_shop in FRAME {&FRAME-NAME}.
        run waitfram-hide in this-procedure no-error .
        v-DT-rests_shop = substring(replace(rests_shop:v-date-time, "T", " "), 1, length(rests_shop:v-date-time) - 4) .
        if v-page-current = 2 then display v-DT-rests_shop with FRAME {&FRAME-NAME}.
    end.
    
    run waitfram-hide in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME 

ON 'right-mouse-down':U of br-rests_all
DO:
    RUN set_focus (SELF).
    IF SELF:TYPE = 'BROWSE' THEN DO:
        RETURN NO-APPLY.
    END.
    ELSE DO:
        APPLY 'menu-drop' TO SELF.
    END.
END.

ON 'right-mouse-down':U of br-rests
DO:
    RUN set_focus (SELF).
    IF SELF:TYPE = 'BROWSE' THEN DO:
        RETURN NO-APPLY.
    END.
    ELSE DO:
        APPLY 'menu-drop' TO SELF.
    END.
END.

PROCEDURE set_focus.
DEF INPUT PARAM i_object            AS HANDLE   NO-UNDO.
DEF VAR l_was_row_one_selected      AS LOG      NO-UNDO.
DEF VAR l_header_y                  AS DEC      NO-UNDO.
DEF VAR w_browse_title_bar_height   AS DEC      NO-UNDO INITIAL 19. /* determine this for your UI */
DEF VAR o_labels                    AS CHAR     NO-UNDO.
DEF VAR o_procedures                AS CHAR     NO-UNDO.
DEF VAR h_menu                      AS HANDLE   NO-UNDO.
DEF VAR h_menu_item                 AS HANDLE   NO-UNDO.
DEF VAR l_count                     AS INT      NO-UNDO.
/* given an object ... */
    IF i_object:TYPE = 'browse' THEN DO:
        IF i_object:NUM-SELECTED-ROWS = 0
            THEN ASSIGN l_was_row_one_selected = FALSE.
            ELSE ASSIGN l_was_row_one_selected = i_object:IS-ROW-SELECTED(1) NO-ERROR.
        i_object:SELECT-ROW(1) NO-ERROR.
        IF ERROR-STATUS:ERROR THEN RETURN.
        l_header_y = MAX(1,i_object:FIRST-COLUMN:Y). /* in case there are no column headers */
        IF i_object:TITLE <> ? THEN l_header_y = l_header_y - w_browse_title_bar_height.
        IF l_was_row_one_selected = FALSE THEN i_object:DESELECT-SELECTED-ROW(1) NO-ERROR.
        /* this section selects the correct row, based on where it was clicked, minus the height of the headers divided by row height */
        i_object:SELECT-ROW(
            INT(
                1 + 
                TRUNC(
                      (LAST-EVENT:Y - l_header_y) / i_object:FIRST-COLUMN:HEIGHT-PIXELS
                     ,0)
                )
            )
            NO-ERROR.
        APPLY 'ENTRY':u TO i_object. /* to get focus properly */
        APPLY 'VALUE-CHANGED':u TO i_object.
        /* use some rule to find associated dynamic menu items, e.g. maintenance options, finding related data*/
/*        RUN find_menu_stuff (i_object:NAME, OUTPUT o_labels, OUTPUT o_procedures).*/
/*        IF o_labels = '' THEN RETURN.                                             */
        o_labels = "Добавить в акт о передаче продукции в торговый зал" .
        /* this finds a popup menu, if any */
        h_menu = i_object:POPUP-MENU NO-ERROR.

        IF VALID-HANDLE(h_menu) THEN RETURN. /* already created previously */
        /* create a popup menu */
        CREATE MENU h_menu.
        ASSIGN
            h_menu:POPUP-ONLY   = TRUE
            i_object:POPUP-MENU = h_menu
            .
        /* add the standard maintenance options (they still may not be supported though) */
        CREATE MENU-ITEM h_menu_item
            ASSIGN
                PARENT      = h_menu
                LABEL       = o_labels
                SENSITIVE   = TRUE
            TRIGGERS:
                ON CHOOSE PERSISTENT RUN make-TTS IN THIS-PROCEDURE.
            END TRIGGERS.
    END.
    IF VALID-HANDLE(h_menu)
        THEN APPLY 'menu-drop' TO h_menu.
    /* MENU-DROP - Supported only when the POPUP-ONLY attribute is set to TRUE and the
                   menu is set as a popup for some other widget */
END PROCEDURE.


on value-changed of br-rests IN FRAME Dialog-Frame /* - */
DO:
    if available tt-gds-rests then do :
        if trim(tt-gds-rests.prt-rec) = "" then disable b-del with frame {&FRAME-NAME} .
        else enable b-del with frame {&FRAME-NAME} .
    end.
    if not available tt-gds-rests or recid(tt-gds-rests) <> tt-rec then do :
        hide loc-alc in frame {&frame-name}.
        loc-alc = "".
    end.
end.

on value-changed of br-rests_shop IN FRAME Dialog-Frame /* - */
DO:
    if available tt-gds-rests_shop then do :
        OPEN QUERY br-rests_all FOR EACH tt-gds-rests where tt-gds-rests.alc-code = tt-gds-rests_shop.alc-code .
    end.
END.

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
/*  { gbl/chk-actg.i          */
/*    v-cntxt-db-num          */
/*    v-cntxt-userid          */
/*    {&action-head-code-main}*/
/*    'actn_egais-ref':U      */
/*    {&cntxt-object}         */
/*    v-cntxt-host-code-obj   */
/*    v-cntxt-obj-type        */
/*    v-cntxt-obj-code        */
/*    0                       */
/*    0                       */
/*    0                       */
/*    true                    */
/*    glog                    */
/*  }                         */
/*  if not glog then  return .*/
/*  assign                    */
/*      rs-sort = 1           */
/*  .                         */

  v-page-current = 1.
  v-section-names = "Склад|Магазин".

  assign
    b-func:popup-menu in frame {&FRAME-NAME} = menu m-func:handle
    b-func:menu-mouse = 1
    b-func_shop:popup-menu in frame {&FRAME-NAME} = menu m-func_shop:handle
    b-func_shop:menu-mouse = 1
  .

  find first buf_clients no-lock where buf_clients.obj-type = {&cmp} and buf_clients.obj-code = v-cntxt-host-code-obj.
  find first buf_firm no-lock where buf_firm.firm-code = v-cntxt-host-code-obj.
  if valid-handle(bh-gds-egais) then do :
      delete object bh-gds-egais .
  end.
  if valid-handle(qh-gds-egais) then do :
      delete object qh-gds-egais .
  end.
    if valid-handle(bh-gds-egais_shop) then do :
      delete object bh-gds-egais_shop .
  end.
  if valid-handle(qh-gds-egais_shop) then do :
      delete object qh-gds-egais_shop .
  end.
  empty temp-table thbjattr_thbj-attr .
  run adm/shattri.p (
       input "get":U
      ,input v-cntxt-obj-type
      ,input v-cntxt-obj-code
      ,input {&attr-egais-host}
      ,input {&attr-egais-host_egais-fsrar}
      ,output v-value-character
      ,output v-value-date
      ,output v-value-decimal
      ,output v-value-integer
      ,output v-value-logical
      ,output v-value-type
      ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
      ) no-error .
  assign
    v-org = buf_clients.obj-name
    v-fs-rar = v-value-character
    v-org-inn = buf_firm.inn
  .
  display v-fs-rar format "X(30)" with frame {&FRAME-NAME}.
  run adm/shattri.p (
       input "get":U
      ,input '':U
      ,input 0
      ,input {&attr-egais-host}
      ,input {&attr-egais-host_egais-exsys}
      ,output v-value-character
      ,output v-value-date
      ,output v-value-decimal
      ,output v-value-integer
      ,output v-value-logical
      ,output v-value-type
      ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
      ) no-error .
  assign v-ext-sys = v-value-integer .
  release buf_clients .
  
  rests = new Rests(v-cntxt-obj-type, v-cntxt-obj-code, v-fs-rar, v-org-inn) .
  rests:DbNum = v-cntxt-db-num .
  rests:User_Id = v-cntxt-userid .
  
  rests_shop = new Rests_shop(v-cntxt-obj-type, v-cntxt-obj-code, v-fs-rar, v-org-inn) .
  rests_shop:DbNum = v-cntxt-db-num .
  rests_shop:User_Id = v-cntxt-userid .
/*  run fill-tt.*/

  run set-size(input frame {&FRAME-NAME}:height-pixels - 182, input frame {&FRAME-NAME}:width-pixels - 40).
  run initialize-folder (v-section-names).
  run show-current-page(input v-page-current).
  { gbl/diasize.i &browse-name=br-rests }
  run diasize_add_browse in this-procedure
  (input  'width':u
  ,input  browse br-rests_shop :handle
  ) .
  run diasize_add_browse in this-procedure
  (input  'width':u
  ,input  browse br-rests_all :handle
  ) .
  run diasize_init in this-procedure .
  RUN enable_UI.
  hide {&list-2} in frame {&frame-name}.
  
  v-fn-rests = "Rests-" + v-fs-rar + ".xml" .
  v-fn-rests_shop = "Rests_Shop-" + v-fs-rar + ".xml" .
  

  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-mark Dialog-Frame
PROCEDURE proc-b-mark :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define variable varlog as logical   no-undo .
  if not available tt-gds-rests then return.
  run local-mark in this-procedure.
  assign varlog = {&browse-name} :select-next-row( ) in frame {&frame-name}.
  apply "ENTRY":U to {&browse-name} in frame {&frame-name}.
  {&browse-name}:refresh() in frame {&frame-name} .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-mark_shop Dialog-Frame
PROCEDURE proc-b-mark_shop :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define variable varlog as logical   no-undo .
  if not available tt-gds-rests_shop then return.
  run local-mark_shop in this-procedure.
  assign varlog = br-rests_shop :select-next-row( ) in frame {&frame-name}.
  apply "ENTRY":U to br-rests_shop in frame {&frame-name}.
  br-rests_shop:refresh() in frame {&frame-name} .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-mark Dialog-Frame
PROCEDURE local-mark :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  if not available tt-gds-rests then do:
    message "Неправильный выбор строки.".
    return no-apply.
  end.
  { gbl/markstrn.i tt-gds-rests select-list }
  {&browse-name}:refresh() in frame {&frame-name} .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-mark Dialog-Frame
PROCEDURE local-mark_shop :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  if not available tt-gds-rests_shop then do:
    message "Неправильный выбор строки.".
    return no-apply.
  end.
  { gbl/markstrn.i tt-gds-rests_shop select-list_shop }
  br-rests_shop:refresh() in frame {&frame-name} .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK folder-block Dialog-Frame
{adm/folder.i trg-folder v-page}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE trg-folder Dialog-Frame 
PROCEDURE trg-folder :

  v-page-current = v-page.
  assign NameContext = "" loc-code = "" loc-alc = ""  .
  loc-alc:screen-value in frame {&frame-name} = ""  .
  if v-page-current = 1 then do :
    display {&list-1} with frame {&frame-name}.
    hide {&list-2} in frame {&frame-name}.
  end.
  else
  if v-page-current = 2 then do :
    display {&list-2} with frame {&frame-name}.
    hide {&list-1} in frame {&frame-name}.  
  end.
/*  run initialize-section.*/
  
end.

procedure make-tts.
    define variable v-tts-num as character no-undo .
    define variable v-tts-date as date no-undo .
    define variable v-ok as logical no-undo .
    define variable v-position as integer no-undo .
    define variable v-part-num    as integer   no-undo .
    define variable v-clob-db-num as integer   no-undo .
    define variable v-int64-id    as int64     no-undo .
    define variable v-info        as character no-undo .
    define variable v-sent as character no-undo .
    define variable v-rec-clob as recid no-undo .
    
    define buffer buf_clob-bind for ub.clob-bind.
    define buffer buf_clob-data for ub.clob-data.
/*run gbl/inidebug.p .*/
/*    if select-list = "" then do :                               */
/*        message "Не выбрано ни одной строки" view-as alert-box .*/
/*        return no-apply.                                        */
/*    end.                                                        */
    if not available tt-gds-rests then do :
        message "Ошибка при выборе строки" view-as alert-box.
        return no-apply.
    end.
    clob_ :
    for each buf_clob-bind where buf_clob-bind.field-name_ = {&lob-egais-tts}
                             and buf_clob-bind.part-num = 1 and entry(1, buf_clob-bind.descr, {&delim-par}) matches "*" + substring(v-cntxt-obj-type,1,1) + string(v-cntxt-obj-code) + "*"
                             break by sys-date descending by sys-time descending :
        v-sent =  entry(3, buf_clob-bind.descr, {&delim-par}).                    
        if not logical(v-sent)
        then do :
            v-rec-clob = recid(buf_clob-bind) .
            leave clob_ . 
        end.         
    end.
    find first buf_clob-bind where recid(buf_clob-bind) = v-rec-clob no-error .
    if not available buf_clob-bind
        then do :
        run bge/egais-makeTTS.w  (input parparentproc,
                                       output v-tts-num,
                                       output v-tts-date,
                                       output v-ok) .
        if not v-ok then return no-apply .
        create tt-act-header-tts.
        assign
            tt-act-header-tts.num   = v-tts-num
            tt-act-header-tts.date_ = v-tts-date
            tt-act-header-tts.is-sent = no
            v-position = 0
        .
    
    /*    do ii = 1 to num-entries(select-list) :                                                                */
    /*        for first tt-gds-rests exclusive-lock where recid(tt-gds-rests) = integer(entry(ii, select-list)) :*/
        assign v-position = v-position + 1 .
        create tt-gds-act-tts.
        assign
            tt-gds-act-tts.num          = tt-act-header-tts.num
            tt-gds-act-tts.position_    = v-position
            tt-gds-act-tts.alc-code     = tt-gds-rests.alc-code
            tt-gds-act-tts.gds-code     = tt-gds-rests.gds-code
            tt-gds-act-tts.gds-name     = tt-gds-rests.gds-name
            tt-gds-act-tts.inform-B     = tt-gds-rests.informB_
            tt-gds-act-tts.qnty         = tt-gds-rests.egais-qnty
        .
    /*        end.*/
    /*    end.    */
    
        run makeXML-tts in this-procedure .
        assign
            v-clob-db-num = ?
            v-int64-id = 0
            v-info = tt-act-header-tts.num + {&delim-par} + string(tt-act-header-tts.date_) + {&delim-par} + string(tt-act-header-tts.is-sent) + {&delim-par} + tt-act-header-tts.answer_
        .
        run gbl/file2clb.p ( input {&add-def}
                              ,input ",yes"
                              ,input ? /*p-bh*/
                              ,input tt-act-header-tts.num /*p-uniq-key-rec*/
                              ,input {&lob-egais-tts} /*p-field-*/
                              ,input v-info /*p-descr*/
                              ,input-output v-part-num
                              ,input {&lob-egais-tts}
                              ,input-output v-clob-db-num
                              ,input-output v-int64-id
                              ,input search (v-file-tts)
                              ,input '' /*p-src-encoding*/
                              ) no-error .
        message "Акт сформирован. Вы можете отправить его или изменить количества из интерфейса 'Передача продукции в торговый зал'" view-as alert-box .
    end.
    else do :
        find first buf_clob-data no-lock where buf_clob-data.db-num = buf_clob-bind.db-num and buf_clob-data.int64-id = buf_clob-bind.int64-id.
        copy-lob
        from  object buf_clob-data.cdata
        to  file 'temp-tts.xml'
        no-convert
        no-error .
        run parseXML-tts in this-procedure (input "temp-tts.xml") .
        v-position = 1 .
        for each tt-gds-act-tts no-lock :
            v-position = v-position + 1 .
        end.
        create tt-gds-act-tts . 
        assign
            tt-gds-act-tts.num          = tt-act-header-tts.num
            tt-gds-act-tts.position_    = v-position
            tt-gds-act-tts.alc-code     = tt-gds-rests.alc-code
            tt-gds-act-tts.gds-code     = tt-gds-rests.gds-code
            tt-gds-act-tts.gds-name     = tt-gds-rests.gds-name
            tt-gds-act-tts.inform-B     = tt-gds-rests.informB_
            tt-gds-act-tts.qnty         = tt-gds-rests.egais-qnty
        .  
        run makeXML-tts in this-procedure .
        assign
            v-clob-db-num = buf_clob-bind.db-num
            v-int64-id = buf_clob-bind.int64-id
            v-part-num = buf_clob-bind.part-num
            v-info = tt-act-header-tts.num + {&delim-par} + string(tt-act-header-tts.date_) + {&delim-par} + string(tt-act-header-tts.is-sent) + {&delim-par} + tt-act-header-tts.answer_
        .
        run gbl/file2clb.p ( input {&update}
                  ,input "add-new,yes"
                  ,input ? /*p-bh*/
                  ,input tt-act-header-tts.num /*p-uniq-key-rec*/
                  ,input {&lob-egais-tts} /*p-field-*/
                  ,input v-info /*p-descr*/
                  ,input-output v-part-num
                  ,input {&lob-egais-tts}
                  ,input-output v-clob-db-num
                  ,input-output v-int64-id
                  ,input search (v-file-tts)
                  ,input '' /*p-src-encoding*/
                  ) no-error .
         if error-status:error then message return-value view-as alert-box. 
         message "Строка добавлена" view-as alert-box.
    end.
end.

procedure PrintRests_shop :
    define var v-act-file as char no-undo.
    v-act-file  = session:temp-directory + {&DF_Name} +  "egais-rests_shop.html".
    
    run waitfram-show in this-procedure ( input "Ждите...").
    output stream OutStr-html to value(v-act-file) convert target 'UTF-8'/*no-convert*/.
    put stream OutStr-html unformatted
        substitute(

        '<!doctype html>
                 <html>
              <head>
              <meta charset="UTF-8">
                 <!-- Стили документа -->
              <style>
                table ~{border-collapse: collapse; ~}
                tbody td, th ~{border: 1px solid black;~}
                #myid ~{font-weight: bold;~}
                .class1 ~{font-style: italic;~}
                .class2 ~{font-family: Arial;~}
              </style>
              </head>
                  <body>
                  <table orientation="landscape" name="лист1" repeat_rows="1:1" hide_zero="True">
                  <thead>
                  <!-- Обязательно создаётся строка таблицы, в которой находятся размеры колонок в px-->
                  <tr class="set_columns">
                        <td style="width:210px"></td>
                        <td style="width:250px"></td>
                        <td style="width:150px"></td>
                        <td style="width:60px"></td>
                        <td style="width:110px"></td>
                        <td style="width:110px"></td>
                        <td style="width:110px"></td>
                  </tr>
                  <tr>
                        <td colspan="7" style="front-weight: bold; text-align: center;">Остатки ЕГАИС торговый зал</td>
                  </tr>
        </thead>
            <tbody>
                <tr>
                <th>Алкогольный код</th>
                <th>Наименование товара</th>
                <th>Код товара в TH</th>
                <th>Код АП</th>
                <th>Остаток ЕГАИС торговый зал</th>
                <th>Остаток ЕГАИС склад</th>
                <th>Остаток TH</th>
                </tr>').

    for each tt-gds-rests_shop no-lock :

        put stream OutStr-html unformatted
            substitute(
            '<tr style="height: 50px;">
             <td text_wrap="true"> &1 </td>
             <td text_wrap="true"> &2 </td>
             <td text_wrap="true"> &3 </td>
             <td text_wrap="true"> &4 </td>
             <td text_wrap="true"> &5 </td>
             <td text_wrap="true"> &6 </td>
             <td text_wrap="true"> &7 </td>
             </tr>
             </tbody>',

            tt-gds-rests_shop.alc-code,
            tt-gds-rests_shop.gds-name,
            tt-gds-rests_shop.gds-code,
            tt-gds-rests_shop.alc-type-code,
            tt-gds-rests_shop.egais-qnty,
            tt-gds-rests_shop.egais-qnty_stock,
            tt-gds-rests_shop.TH-qnty
            ).

    end.
    


    run waitfram-hide in this-procedure.

    output stream OutStr-html close.
    run prn-lib-reportviewer-report-name in this-procedure (
        input parParentProc
        ,input v-act-file
        ).
    
end.

procedure PrintRests :
    define var v-act-file as char no-undo.
    v-act-file  = session:temp-directory + {&DF_Name} +  "egais-rests.html".
    
    run waitfram-show in this-procedure ( input "Ждите...").
    output stream OutStr-html to value(v-act-file) convert target 'UTF-8'/*no-convert*/.
    put stream OutStr-html unformatted
        substitute(

        '<!doctype html>
                 <html>
              <head>
              <meta charset="UTF-8">
                 <!-- Стили документа -->
              <style>
                table ~{border-collapse: collapse; ~}
                tbody td, th ~{border: 1px solid black;~}
                #myid ~{font-weight: bold;~}
                .class1 ~{font-style: italic;~}
                .class2 ~{font-family: Arial;~}
              </style>
              </head>
                  <body>
                  <table orientation="landscape" name="лист1" repeat_rows="1:1" hide_zero="True">
                  <thead>
                  <!-- Обязательно создаётся строка таблицы, в которой находятся размеры колонок в px-->
                  <tr class="set_columns">
                        <td style="width:210px"></td>
                        <td style="width:250px"></td>
                        <td style="width:150px"></td>
                        <td style="width:60px"></td>
                        <td style="width:110px"></td>
                        <td style="width:210px"></td>
                        <td style="width:210px"></td>
                        <td style="width:110px"></td>
                  </tr>
                  <tr>
                        <td colspan="8" style="front-weight: bold; text-align: center;">Остатки ЕГАИС склад</td>
                  </tr>
        </thead>
            <tbody>
                <tr>
                <th>Алкогольный код</th>
                <th>Наименование товара</th>
                <th>Код товара в TH</th>
                <th>Код АП</th>
                <th>Остаток ЕГАИС</th>
                <th>ID справки А</th>
                <th>ID справки Б</th>
                <th>Остаток TH</th>
                </tr>').

       
    for each tt-gds-rests no-lock:

        put stream OutStr-html unformatted
            substitute(
            '<tr style="height: 50px;">
             <td text_wrap="true"> &1 </td>
             <td text_wrap="true"> &2 </td>
             <td text_wrap="true"> &3 </td>
             <td text_wrap="true"> &4 </td>
             <td text_wrap="true"> &5 </td>
             <td text_wrap="true"> &6 </td>
             <td text_wrap="true"> &7 </td>
             <td text_wrap="true"> &8 </td>
             </tr>
             </tbody>',

            tt-gds-rests.alc-code,
            tt-gds-rests.gds-name,
            tt-gds-rests.gds-code,
            tt-gds-rests.alc-type-code,
            tt-gds-rests.egais-qnty,
            tt-gds-rests.informA_,
            tt-gds-rests.informB_,
            tt-gds-rests.TH-qnty
            ).
        


    end.
    


    run waitfram-hide in this-procedure.

    output stream OutStr-html close.
    run prn-lib-reportviewer-report-name in this-procedure (
        input parParentProc
        ,input v-act-file
        ).
    
end.

procedure CompareRests :
    define variable v-gds-entry as character no-undo .
    define var v-act-file as char no-undo.
    v-act-file  = session:temp-directory + {&DF_Name} +  "egais-rests_compare.html".
    empty temp-table tt-compare-rests .
    empty temp-table gds-list .
    goods-list = "" .
    
    run str/gds-list.w ( input parparentproc, v-cntxt-host-code-obj, v-cntxt-obj-type, v-cntxt-obj-code).
    for each gds-list no-lock :
        find goods where
             goods.gds-code = gds-list.gds-code
             no-lock no-error.
        if available goods then do:
            { gbl/markstrn.i goods goods-list }
        end.
    end.
    empty temp-table tt-compare-rests .
    run waitfram-show(INPUT "Ждите...") .
    _ii_ :
    do ii = 1 to num-entries(goods-list) :
    v-gds-entry = entry(ii, goods-list) .
    for first buf_goods no-lock where recid(buf_goods) = integer(v-gds-entry) :
        run gds-attr-value(
          buf_goods.gds-code,
          {&attr-alcohol-prod},
          output par-alcohol,
          output par-type
        ).
        if par-alcohol = "" or par-alcohol = "no" then next _ii_ .  
        _parts_ :  
        for each buf_parts no-lock where buf_parts.artic = buf_goods.artic 
                                    and buf_parts.prod-type = buf_goods.prod-type 
                                    and buf_parts.prod-code = buf_goods.prod-code 
                                    and buf_parts.obj-type = v-cntxt-obj-type 
                                    and buf_parts.obj-code = v-cntxt-obj-code 
                                    and buf_parts.out-code = {&free-code} :
/*            if buf_parts.qnty < 1 then next _parts_ .*/
            if num-entries(buf_parts.alc-ref-ab-path) = 4 and entry(3, buf_parts.alc-ref-ab-path) <> "" then do :
                find first tt-compare-rests exclusive-lock where tt-compare-rests.alc-code = entry(3, buf_parts.alc-ref-ab-path) no-error.
                if not available tt-compare-rests then do :
                    create tt-compare-rests .
                    assign
                        tt-compare-rests.alc-code   = entry(3, buf_parts.alc-ref-ab-path)
                        tt-compare-rests.gds-code   = string(buf_goods.gds-code)
                        tt-compare-rests.gds-name   = buf_goods.gds-name
                    .
                    if entry(4, buf_parts.alc-ref-ab-path) <> "" then tt-compare-rests.alc-type-code = entry(4, buf_parts.alc-ref-ab-path) .
                end.
                assign tt-compare-rests.TH-qnty = tt-compare-rests.TH-qnty + buf_parts.qnty .
            end.
            else do :
                find first tt-compare-rests exclusive-lock where tt-compare-rests.gds-code = string(buf_goods.gds-code)
                                                             and tt-compare-rests.alc-code = "" no-error.
                if not available tt-compare-rests then do :
                    create tt-compare-rests .
                    assign
                        tt-compare-rests.alc-code   = ""
                        tt-compare-rests.gds-code   = string(buf_goods.gds-code)
                        tt-compare-rests.gds-name   = buf_goods.gds-name
                    .
                end.
                assign tt-compare-rests.TH-qnty = tt-compare-rests.TH-qnty + buf_parts.qnty .
            end.    
        end.  /* buf_parts */
        for each tt-gds-rests_shop no-lock where tt-gds-rests_shop.gds-code = string(buf_goods.gds-code)
                                              or num-entries(tt-gds-rests_shop.gds-code) > 1 :
            find first tt-compare-rests exclusive-lock where tt-compare-rests.alc-code = tt-gds-rests_shop.alc-code no-error .
            if not available tt-compare-rests then do :
                create tt-compare-rests .
                assign
                    tt-compare-rests.alc-code   = tt-gds-rests_shop.alc-code
                    tt-compare-rests.gds-code   = tt-gds-rests_shop.gds-code
                    tt-compare-rests.gds-name   = tt-gds-rests_shop.gds-name
                    tt-compare-rests.alc-type-code = tt-gds-rests_shop.alc-type-code
                .
            end.
            assign tt-compare-rests.shop-qnty = tt-gds-rests_shop.egais-qnty .
/*            assign tt-compare-rests.stock-qnty = tt-gds-rests_shop.egais-qnty_stock .*/
        end. /* tt-gds-rests_shop */
        for each tt-gds-rests no-lock where tt-gds-rests.gds-code = buf_goods.gds-code :
            find first tt-compare-rests exclusive-lock where tt-compare-rests.alc-code = tt-gds-rests.alc-code no-error .
            if not available tt-compare-rests then do :
                create tt-compare-rests .
                assign
                    tt-compare-rests.alc-code   = tt-gds-rests.alc-code
                    tt-compare-rests.gds-code   = string(tt-gds-rests.gds-code)
                    tt-compare-rests.gds-name   = tt-gds-rests.gds-name
                    tt-compare-rests.alc-type-code = tt-gds-rests.alc-type-code
                .
            end.
            assign tt-compare-rests.stock-qnty = tt-compare-rests.stock-qnty + tt-gds-rests.egais-qnty .
        end. /* tt-gds-rests */
    end.  /* for first buf_goods */  
    end. /* _ii_ */
    
    output stream OutStr-html to value(v-act-file) convert target 'UTF-8'/*no-convert*/.
    put stream OutStr-html unformatted
        substitute(

        '<!doctype html>
                 <html>
              <head>
              <meta charset="UTF-8">
                 <!-- Стили документа -->
              <style>
                table ~{border-collapse: collapse; ~}
                tbody td, th ~{border: 1px solid black;~}
                #myid ~{font-weight: bold;~}
                .class1 ~{font-style: italic;~}
                .class2 ~{font-family: Arial;~}
              </style>
              </head>
                  <body>
                  <table orientation="landscape" name="лист1" repeat_rows="1:1" hide_zero="True">
                  <thead>
                  <!-- Обязательно создаётся строка таблицы, в которой находятся размеры колонок в px-->
                  <tr class="set_columns">
                        <td style="width:210px"></td>
                        <td style="width:250px"></td>
                        <td style="width:150px"></td>
                        <td style="width:60px"></td>
                        <td style="width:110px"></td>
                        <td style="width:110px"></td>
                        <td style="width:110px"></td>
                  </tr>
                  <tr>
                        <td colspan="7" style="front-weight: bold; text-align: center;">Сверка остатков ЕГАИС</td>
                  </tr>
        </thead>
            <tbody>
                <tr>
                <th>Алкогольный код</th>
                <th>Наименование товара</th>
                <th>Код товара в TH</th>
                <th>Код АП</th>
                <th>Остаток ЕГАИС торговый зал</th>
                <th>Остаток ЕГАИС склад</th>
                <th>Остаток TH</th>
                </tr>').

    for each tt-compare-rests :

        put stream OutStr-html unformatted
            substitute(
            '<tr style="height: 50px;">
             <td text_wrap="true"> &1 </td>
             <td text_wrap="true"> &2 </td>
             <td text_wrap="true"> &3 </td>
             <td text_wrap="true"> &4 </td>
             <td text_wrap="true"> &5 </td>
             <td text_wrap="true"> &6 </td>
             <td text_wrap="true"> &7 </td>
             </tr>
             </tbody>',

            tt-compare-rests.alc-code,
            tt-compare-rests.gds-name,
            tt-compare-rests.gds-code,
            tt-compare-rests.alc-type-code,
            tt-compare-rests.shop-qnty,
            tt-compare-rests.stock-qnty,
            tt-compare-rests.TH-qnty
            ).

    end.
    


    run waitfram-hide in this-procedure.

    output stream OutStr-html close.
    run prn-lib-reportviewer-report-name in this-procedure (
        input parParentProc
        ,input v-act-file
        ).
end.

procedure MarksCompareRests :
    define variable v-gds-entry as character no-undo .
    define variable v-mark      as character no-undo .
    define variable v-alc-code    as character    no-undo .
    define variable v-error-lang  as logical      no-undo . 
    define variable l-error         as logical   no-undo INIT NO. /* Есть ли ошибки */
    define variable v-user-action   as character no-undo.
    define variable v-printed       as logical   no-undo.
    define var v-act-file as char no-undo.
    define variable v_os-file   AS CHAR NO-UNDO INIT "".
    define variable ll_commit AS LOG    NO-UNDO INIT NO.
    define variable v-proc-name-err as character no-undo initial 'imp_mark.err'. /* Имя лога */
    
    
    if search (v-proc-name-err) <> ? then 
    do:
      os-delete value(v-proc-name-err).
    end.
    v-act-file  = session:temp-directory + {&DF_Name} +  "egais-rests_marks-compare.html".
    empty temp-table tt-marks-compare-rests .
    empty temp-table tt-marks-qnty .
    empty temp-table gds-list .
    goods-list = "" .
    
    run str/gds-list.w ( input parparentproc, v-cntxt-host-code-obj, v-cntxt-obj-type, v-cntxt-obj-code).
    for each gds-list no-lock :
        find goods where
             goods.gds-code = gds-list.gds-code
             no-lock no-error.
        if available goods then do:
            { gbl/markstrn.i goods goods-list }
        end.
    end.
    
    SYSTEM-DIALOG GET-FILE v_os-file
        TITLE "Выберите файл с марками"
        FILTERS
          " Все текстовые файлы (*.txt) " "*.txt",
          " Все файлы (*.*) "                      "*.*"
        INITIAL-FILTER 1
        DEFAULT-EXTENSION ".txt"
        USE-FILENAME
        MUST-EXIST
        UPDATE ll_commit
        .

    IF ll_commit <> YES THEN do:
       RETURN NO-APPLY.
    end.
    IF v_os-file = PROGRAM-NAME( 1 ) THEN DO:
        BELL.
        MESSAGE "Рекурсия!" VIEW-AS ALERT-BOX ERROR.
        RETURN NO-APPLY.
    END.
    
    run waitfram-show(INPUT "Ждите...") .
    
    output stream str-err to value(v-proc-name-err) .
    INPUT FROM value(v_os-file).
    REPEAT: 
        IMPORT v-mark.
        v-mark = trim(v-mark) .
        run ProcAlcCode  IN THIS-PROCEDURE (input v-mark, output v-alc-code, output l-error, output v-error-lang ) no-error.
        if v-error-lang then 
        do:
          put stream str-err unformatted
            "Не корректно считана акцизная марка " v-mark ", акцизная марка содержит не допустимые символы или русские буквы."
            skip .
          v-alc-code = "".
          l-error = yes .
        end.  
        else 
        do:
            find first tt-marks-qnty exclusive-lock where tt-marks-qnty.alc-code = v-alc-code no-error.
            if not available tt-marks-qnty
            then do :
                create tt-marks-qnty .
                assign
                    tt-marks-qnty.alc-code = v-alc-code
                    tt-marks-qnty.qnty = 0
                .
            end.
            tt-marks-qnty.qnty = tt-marks-qnty.qnty + 1 .
        end.
    end. 
    INPUT CLOSE. 
    output stream str-err close.
    
    if l-error then 
    do: 
      if search (v-proc-name-err) <> ? then 
      do:
        run gbl/prnfilen.w
          (input  substitute ("Не все марки были загружены")
          ,input  0
          ,input  v-proc-name-err
          ,input  7
          ,output v-user-action
          ,output v-printed
          ).
      end.
    end.   
            
    _ii_ :
    do ii = 1 to num-entries(goods-list) :
    v-gds-entry = entry(ii, goods-list) .
    for first buf_goods no-lock where recid(buf_goods) = integer(v-gds-entry) :
        run gds-attr-value(
          buf_goods.gds-code,
          {&attr-alcohol-prod},
          output par-alcohol,
          output par-type
        ).
        if par-alcohol = "" or par-alcohol = "no" then next _ii_ .  
        _parts_ :  
        for each buf_parts no-lock where buf_parts.artic = buf_goods.artic 
                                    and buf_parts.prod-type = buf_goods.prod-type 
                                    and buf_parts.prod-code = buf_goods.prod-code 
                                    and buf_parts.obj-type = v-cntxt-obj-type 
                                    and buf_parts.obj-code = v-cntxt-obj-code 
                                    and buf_parts.out-code = {&free-code} :
/*            if buf_parts.qnty < 1 then next _parts_ .*/
            if num-entries(buf_parts.alc-ref-ab-path) = 4 and entry(3, buf_parts.alc-ref-ab-path) <> "" then do :
                find first tt-marks-compare-rests exclusive-lock where tt-marks-compare-rests.alc-code = entry(3, buf_parts.alc-ref-ab-path) no-error.
                if not available tt-marks-compare-rests then do :
                    create tt-marks-compare-rests .
                    assign
                        tt-marks-compare-rests.alc-code   = entry(3, buf_parts.alc-ref-ab-path)
                        tt-marks-compare-rests.gds-code   = buf_goods.gds-code
                        tt-marks-compare-rests.gds-name   = buf_goods.gds-name
                    .
                    if entry(4, buf_parts.alc-ref-ab-path) <> "" then tt-marks-compare-rests.alc-type-code = entry(4, buf_parts.alc-ref-ab-path) .
                end.
                assign tt-marks-compare-rests.TH-qnty = tt-marks-compare-rests.TH-qnty + buf_parts.qnty .
            end.
            else do :
                find first tt-marks-compare-rests exclusive-lock where tt-marks-compare-rests.gds-code = buf_goods.gds-code
                                                             and tt-marks-compare-rests.alc-code = "" no-error.
                if not available tt-marks-compare-rests then do :
                    create tt-marks-compare-rests .
                    assign
                        tt-marks-compare-rests.alc-code   = ""
                        tt-marks-compare-rests.gds-code   = buf_goods.gds-code
                        tt-marks-compare-rests.gds-name   = buf_goods.gds-name
                    .
                end.
                assign tt-marks-compare-rests.TH-qnty = tt-marks-compare-rests.TH-qnty + buf_parts.qnty .
            end.    
        end.  /* buf_parts */
        
    end.  /* for first buf_goods */  
    end. /* _ii_ */
    
    for each tt-marks-qnty no-lock :
        find first tt-marks-compare-rests exclusive-lock where tt-marks-compare-rests.alc-code = tt-marks-qnty.alc-code no-error .
        if not available tt-marks-compare-rests then do :
            create tt-marks-compare-rests .
            assign
                tt-marks-compare-rests.alc-code   = tt-marks-qnty.alc-code
                tt-marks-compare-rests.gds-code   = 0
                tt-marks-compare-rests.gds-name   = ""
                tt-marks-compare-rests.alc-type-code = ""
            .
            for each X_ext-classif no-lock where X_ext-classif.classif-subject = {&table_goods} 
                                           and X_ext-classif.classif-name = {&extclass_goods_esys} 
                                           AND X_ext-classif.db-num = 0
                                           and X_ext-classif.key#_two = v-ext-sys
                                           and X_ext-classif.key#_three = 0
                                           and X_ext-classif.charkey_one = tt-marks-compare-rests.alc-code
                                           and X_ext-classif.charkey_two = ""
                                           and X_ext-classif.charkey_three = ""
                                           and X_ext-classif.nonunique = 0 : 
                tt-marks-compare-rests.gds-codes = tt-marks-compare-rests.gds-codes + (if tt-marks-compare-rests.gds-codes = "" then "" else ",") + string(X_ext-classif.key#_one) .                                 
            end.                                   
        end.
        assign tt-marks-compare-rests.marks-qnty = tt-marks-qnty.qnty .
    end.
    
    for each tt-marks-compare-rests exclusive-lock :
        find first tt-gds-rests_shop no-lock where tt-gds-rests_shop.alc-code = tt-marks-compare-rests.alc-code no-error.
        if available tt-gds-rests_shop
        then do :
            assign tt-marks-compare-rests.shop-qnty = tt-gds-rests_shop.egais-qnty .
            assign tt-marks-compare-rests.stock-qnty = tt-gds-rests_shop.egais-qnty_stock .
        end.
    end.
    
    output stream OutStr-html to value(v-act-file) convert target 'UTF-8'/*no-convert*/.
    put stream OutStr-html unformatted
        substitute(

        '<!doctype html>
                 <html>
              <head>
              <meta charset="UTF-8">
                 <!-- Стили документа -->
              <style>
                table ~{border-collapse: collapse; ~}
                tbody td, th ~{border: 1px solid black;~}
                #myid ~{font-weight: bold;~}
                .class1 ~{font-style: italic;~}
                .class2 ~{font-family: Arial;~}
              </style>
              </head>
                  <body>
                  <table orientation="landscape" name="лист1" repeat_rows="1:1" hide_zero="True">
                  <thead>
                  <!-- Обязательно создаётся строка таблицы, в которой находятся размеры колонок в px-->
                  <tr class="set_columns">
                        <td style="width:210px"></td>
                        <td style="width:250px"></td>
                        <td style="width:150px"></td>
                        <td style="width:60px"></td>
                        <td style="width:110px"></td>
                        <td style="width:110px"></td>
                        <td style="width:110px"></td>
                        <td style="width:110px"></td>
                  </tr>
                  <tr>
                        <td colspan="8" style="front-weight: bold; text-align: center;">Сверка остатков по маркам ЕГАИС</td>
                  </tr>
        </thead>
            <tbody>
                <tr>
                <th>Алкогольный код</th>
                <th>Наименование товара</th>
                <th>Код товара в TH</th>
                <th>Код АП</th>
                <th>Остаток ЕГАИС торговый зал</th>
                <th>Остаток ЕГАИС склад</th>
                <th>Остаток TH</th>
                <th>Кол-во марок</th>
                </tr>').

    for each tt-marks-compare-rests :
         
        put stream OutStr-html unformatted
            substitute(
            '<tr style="height: 50px;">
             <td text_wrap="true"> &1 </td>
             <td text_wrap="true"> &2 </td>
             <td text_wrap="true"> &3 </td>
             <td text_wrap="true"> &4 </td>
             <td text_wrap="true"> &5 </td>
             <td text_wrap="true"> &6 </td>
             <td text_wrap="true"> &7 </td>
             <td text_wrap="true"> &8 </td>
             </tr>
             </tbody>',

            tt-marks-compare-rests.alc-code,
            tt-marks-compare-rests.gds-name,
            (if tt-marks-compare-rests.gds-code <> 0 then string(tt-marks-compare-rests.gds-code) else tt-marks-compare-rests.gds-codes),
            tt-marks-compare-rests.alc-type-code,
            tt-marks-compare-rests.shop-qnty,
            tt-marks-compare-rests.stock-qnty,
            tt-marks-compare-rests.TH-qnty,
            tt-marks-compare-rests.marks-qnty
            ).

    end.
    


    run waitfram-hide in this-procedure.

    output stream OutStr-html close.
    run prn-lib-reportviewer-report-name in this-procedure (
        input parParentProc
        ,input v-act-file
        ).
end.

/*Процедура извличения алкокода из акцизной марки и перевод в 10 систему*/
PROCEDURE ProcAlcCode :
  define input  parameter p-mark-alc as character  no-undo .
  define output parameter p-alc-code as character  no-undo initial ''.
  define output parameter p-error as logical no-undo initial no.
  define output parameter p-error-lang as logical no-undo initial no.
  define variable v-kol              as integer    no-undo .
  define variable v-alc-code as character no-undo .
  define variable v-result as character no-undo .
  define variable ii as integer no-undo .  
  DEFINE VARIABLE v_list AS CHARACTER NO-UNDO INITIAL '':U.
  ASSIGN 
    v_list = '0,1,2,3,4,5,6,7,8,9,A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z,':U .

  v-alc-code = SUBSTRing (p-mark-alc, 8, 12) .
  /*проверка на русские буквы*/
  do ii = 1 to length (v-alc-code):
    if LOOKUP( SUBSTRING( v-alc-code, ii, 1 ), v_list )  < 1 then
    do:
      p-error-lang = yes .
      leave .
      
    end.
  end.
  p-alc-code = string (Base2Int64 (v-alc-code, 36) ) no-error.
  if (Base2Int64 (v-alc-code, 36) ) < 0 then 
  do:
    p-error = yes.
  end.
  else 
  do:
    if length(p-alc-code) < 20 then 
    do:
      p-alc-code = fill('0', 19 - length(p-alc-code)) + p-alc-code.
    end.  
  end.
  
    
END PROCEDURE.

procedure ListView :
    define variable v-gds-entry as character no-undo .
    empty temp-table tt-gds-list .
    empty temp-table gds-list .
    goods-list = "" .
    
    run str/gds-list.w ( input parparentproc, v-cntxt-host-code-obj, v-cntxt-obj-type, v-cntxt-obj-code).
    for each gds-list no-lock :
        find goods where
             goods.gds-code = gds-list.gds-code
             no-lock no-error.
        if available goods then do:
            { gbl/markstrn.i goods goods-list }
        end.
    end.
    _ii_ :
    do ii = 1 to num-entries(goods-list) :
    v-gds-entry = entry(ii, goods-list) .
    for first buf_goods no-lock where recid(buf_goods) = integer(v-gds-entry) :
        run gds-attr-value(
          buf_goods.gds-code,
          {&attr-alcohol-prod},
          output par-alcohol,
          output par-type
        ).
        if par-alcohol = "" or par-alcohol = "no" then next _ii_ . 
        _parts_ :  
        for each buf_parts no-lock where buf_parts.artic = buf_goods.artic 
                                    and buf_parts.prod-type = buf_goods.prod-type 
                                    and buf_parts.prod-code = buf_goods.prod-code 
                                    and buf_parts.obj-type = v-cntxt-obj-type 
                                    and buf_parts.obj-code = v-cntxt-obj-code 
                                    and buf_parts.out-code = {&free-code} :
/*            if buf_parts.qnty < 1 then next _parts_ .*/
            if num-entries(buf_parts.alc-ref-ab-path) = 4 and entry(3, buf_parts.alc-ref-ab-path) <> "" then do :
                find first tt-gds-list exclusive-lock where tt-gds-list.alc-code = entry(3, buf_parts.alc-ref-ab-path)
                                                        and tt-gds-list.gds-code = string(buf_goods.gds-code) no-error .
                if not available tt-gds-list
                then do :
                    create tt-gds-list.
                    assign
                        tt-gds-list.alc-code = entry(3, buf_parts.alc-ref-ab-path)
                        tt-gds-list.gds-code = string(buf_goods.gds-code)
                    .
                end.
                find first tt-gds-rests_shop exclusive-lock where tt-gds-rests_shop.alc-code = tt-gds-list.alc-code 
                                                              and tt-gds-rests_shop.in-list <> true no-error.
                if not available tt-gds-rests_shop then do :
                    create tt-gds-rests_shop .
                    assign
                        tt-gds-rests_shop.alc-code   = tt-gds-list.alc-code
                        tt-gds-rests_shop.gds-code   = string(buf_goods.gds-code)
                        tt-gds-rests_shop.gds-name   = buf_goods.gds-name
                        tt-gds-rests_shop.egais-qnty = 0
                        tt-gds-rests_shop.in-list    = true
                    .
                    if entry(4, buf_parts.alc-ref-ab-path) <> "" then tt-gds-rests_shop.alc-type-code = entry(4, buf_parts.alc-ref-ab-path) .
                    for each tt-gds-rests no-lock where tt-gds-rests.alc-code = tt-gds-rests_shop.alc-code :
                        tt-gds-rests_shop.egais-qnty_stock = tt-gds-rests_shop.egais-qnty_stock + tt-gds-rests.egais-qnty .
                    end.
                end.
                find first tt-gds-rests_shop exclusive-lock where tt-gds-rests_shop.alc-code = tt-gds-list.alc-code 
                                                              and tt-gds-rests_shop.in-list  = true no-error.
                if available tt-gds-rests_shop
                then do :
                    tt-gds-rests_shop.TH-qnty = tt-gds-rests_shop.TH-qnty + buf_parts.qnty .
                end.
            end.
            else do :
                find first tt-gds-list exclusive-lock where tt-gds-list.alc-code = ""
                                                        and tt-gds-list.gds-code = string(buf_goods.gds-code) no-error .
                if not available tt-gds-list
                then do :
                    create tt-gds-list.
                    assign
                        tt-gds-list.alc-code = ""
                        tt-gds-list.gds-code = string(buf_goods.gds-code)
                    .
                end.
                find first tt-gds-rests_shop exclusive-lock where tt-gds-rests_shop.alc-code = "" 
                                                              and tt-gds-rests_shop.gds-code = tt-gds-list.gds-code no-error.
                if not available tt-gds-rests_shop
                then do :
                    create tt-gds-rests_shop .
                    assign
                        tt-gds-rests_shop.alc-code   = ""
                        tt-gds-rests_shop.gds-code   = string(buf_goods.gds-code)
                        tt-gds-rests_shop.gds-name   = buf_goods.gds-name
                        tt-gds-rests_shop.egais-qnty = 0
                        tt-gds-rests_shop.egais-qnty_stock = 0
                        tt-gds-rests_shop.in-list    = true
                    .
                end.  
                tt-gds-rests_shop.TH-qnty = tt-gds-rests_shop.TH-qnty + buf_parts.qnty .                                            
            end.    
        end.  /* buf_parts */
    end.
    end.
end.

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
    
  ENABLE b-mark b-sel-all b-unmark b-load b-func b-save b-cancel br-rests br-rests_shop br-rests_all
         b-connect b-del b-func t-negative_rests t-not_eq_rests b-func_shop
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  hide NameContext loc-alc loc-code in FRAME Dialog-Frame.
  br-rests:column-resizable in FRAME Dialog-Frame = true .
  br-rests_shop:column-resizable in FRAME Dialog-Frame = true .
  br-rests_all:column-resizable in FRAME Dialog-Frame = true .
  glog = rests:IsSent .
  if glog then enable b-answer WITH FRAME Dialog-Frame.
/*  if egais:IsSent then enable b-answer WITH FRAME Dialog-Frame.*/
/*  else disable b-answer WITH FRAME Dialog-Frame .              */
  OPEN QUERY {&browse-name} FOR EACH tt-gds-rests .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

