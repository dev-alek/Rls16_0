&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v9r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER buf_price-doc FOR ub.price-doc.
DEFINE BUFFER buf_price-doc-forming FOR ub.price-doc-forming.
DEFINE NEW SHARED BUFFER buf_price-list-type FOR ub.price-list-type.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Список документов назначения цены

Автор: Чернова Светлана Александровна
Дата создания: 11/10/05
Author: Svetlana Chernova
Creation date: 11/10/05

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input  parameter parParentProc as handle no-undo .
define input  parameter p-mode  as character no-undo . /* all ; pl-type */
define input  parameter p-plt-id as int no-undo .
define input  parameter p-plt-db-num as int no-undo .
define input  parameter p-bttns as character no-undo .
define input-output parameter  p-rec-list as character no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Список документов назначения цены".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i  }
{ cmp/library.i  }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
{ gbl/waitfram.i }
{ ref/xobjgrp.i  }
{ str/dfpl-ad.i  }
{ gbl/fltopend.i defproc }
{ gbl/flt-def.i  }
{ gbl/fltfield.i }
{ gbl/color.i    }
{ str/prcreate.i }

/* Local Variable Definitions ---                                       */

define variable v-rec-list-cli as character no-undo .
define variable g-log          as logical   no-undo .
define variable br-handle      as handle    no-undo .
define variable buffer-handle  as handle    no-undo .
define variable next-prev      as logical   no-undo .
define variable v-rec-list     as character no-undo .
define variable ref-rec        as recid     no-undo .
define variable loc_gop-db-num as integer   no-undo .
define variable loc_gop-id     as integer   no-undo .
define variable var-paket      as logical   no-undo init false .
define variable filter-point   as character no-undo init "pdf-list" .
define variable filter-label   as character no-undo init "Список всех ДНЦ" .
define variable v-title-0      as character no-undo .

define variable sort-column-name    as character no-undo .
define variable v-flt-rec           as character no-undo .
define variable v-filter-name       as character no-undo .
define variable v-where-phrase      as character no-undo .
define variable v-sort-phrase       as character no-undo .
define variable v-where-phrase-rus  as character no-undo .
define variable v-sort-phrase-rus   as character no-undo .

function mark-string returns character
  ( buffer loc-table for ub.price-doc-forming, input mark-list as character  ) :
  return ( if lookup( string( recid( loc-table ) ), mark-list ) > 0 then "*" else "":U ).
end function.

function stts-string returns character
  ( buffer loc-table for ub.price-doc-forming   ) :
 case loc-table.stts :
    when 0 then return {&g___new} .
    when 1 then return {&deleted-status} .
    when 3 then return {&fact} .
    when 4 then return {&ready} .
 end case.
end function.

function activ-pr returns character
  ( buffer loc-table for ub.price-doc-forming  ) :

define buffer buf_price-all  for ub.price-all .
define buffer buf2_price-all for ub.price-all .

  find first buf_price-all no-lock where
             buf_price-all.pdf-db = loc-table.pdf-db  and
             buf_price-all.pdf-id = loc-table.pdf-id  and
             buf_price-all.plt-db-num = loc-table.plt-db-num and
             buf_price-all.plt-id     = loc-table.plt-id and
             buf_price-all.status_    = {&act-overvalue}
             no-error .
   if available buf_price-all then do:
            find first buf2_price-all no-lock where
                      buf2_price-all.pdf-db = loc-table.pdf-db  and
                      buf2_price-all.pdf-id = loc-table.pdf-id  and
                      buf2_price-all.plt-db-num = loc-table.plt-db-num and
                      buf2_price-all.plt-id     = loc-table.plt-id and
                      buf2_price-all.status_    <> {&act-overvalue}
                      no-error .
             if available buf2_price-all then return "не все" .
             else return "все +" .
      end.

   else do: /*  нет */
      return "".
   end.
end function.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BROWSE-1grp

/* External Tables                                                      */
&Scoped-define EXTERNAL-TABLES buf_price-list-type
&Scoped-define FIRST-EXTERNAL-TABLE buf_price-list-type


/* Need to scope the external tables to this procedure                  */
DEFINE QUERY external_tables FOR buf_price-list-type.
/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES buf_price-doc-forming buf_price-list-type ~
buf_price-doc

/* Definitions for BROWSE BROWSE-1grp                                   */
&Scoped-define FIELDS-IN-QUERY-BROWSE-1grp mark-string ( buffer buf_price-doc-forming, p-rec-list ) buf_price-list-type.priority stts-string ( buffer buf_price-doc-forming ) activ-pr ( buffer buf_price-doc-forming ) buf_price-doc-forming.pdf-id buf_price-doc-forming.sys-date buf_price-doc-forming.sys-time-chr buf_price-doc-forming.name buf_price-list-type.plt-id buf_price-list-type.main buf_price-doc-forming.db-num-chg buf_price-doc-forming.pdf-db buf_price-list-type.plt-db-num buf_price-doc-forming.out-code buf_price-doc-forming.start-date buf_price-doc-forming.end-date buf_price-doc-forming.start-sys-date string(buf_price-doc-forming.start-sys-time,"hh:mm:ss") buf_price-doc-forming.end-sys-date string(buf_price-doc-forming.end-sys-time,"hh:mm:ss") buf_price-doc-forming.start-shift-date buf_price-doc-forming.start-shift-num buf_price-doc-forming.end-shift-date buf_price-doc-forming.end-shift-num
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-1grp buf_price-doc-forming.name
&Scoped-define ENABLED-TABLES-IN-QUERY-BROWSE-1grp buf_price-doc-forming
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-BROWSE-1grp buf_price-doc-forming
&Scoped-define SELF-NAME BROWSE-1grp
&Scoped-define QUERY-STRING-BROWSE-1grp FOR     EACH buf_price-doc-forming WHERE     ( r-status = 2 OR buf_price-doc-forming.stts =  r-status ) AND     ( p-mode = "all" OR (buf_price-doc-forming.plt-id = p-plt-id AND buf_price-doc-forming.plt-db-num = p-plt-db-num))     USE-INDEX spis , ~
           FIRST buf_price-list-type  WHERE           buf_price-list-type.plt-id = buf_price-doc-forming.plt-id AND           buf_price-list-type.plt-db-num = buf_price-doc-forming.plt-db-num AND        ( r-obj = 2 OR        ( buf_price-list-type.gop-id     = loc_gop-id AND          buf_price-list-type.gop-db-num = loc_gop-db-num ))
&Scoped-define OPEN-QUERY-BROWSE-1grp OPEN QUERY {&SELF-NAME} FOR     EACH buf_price-doc-forming WHERE     ( r-status = 2 OR buf_price-doc-forming.stts =  r-status ) AND     ( p-mode = "all" OR (buf_price-doc-forming.plt-id = p-plt-id AND buf_price-doc-forming.plt-db-num = p-plt-db-num))     USE-INDEX spis , ~
           FIRST buf_price-list-type  WHERE           buf_price-list-type.plt-id = buf_price-doc-forming.plt-id AND           buf_price-list-type.plt-db-num = buf_price-doc-forming.plt-db-num AND        ( r-obj = 2 OR        ( buf_price-list-type.gop-id     = loc_gop-id AND          buf_price-list-type.gop-db-num = loc_gop-db-num )).
&Scoped-define TABLES-IN-QUERY-BROWSE-1grp buf_price-doc-forming ~
buf_price-list-type
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-1grp buf_price-doc-forming
&Scoped-define SECOND-TABLE-IN-QUERY-BROWSE-1grp buf_price-list-type


/* Definitions for BROWSE BROWSE-2-pr                                   */
&Scoped-define FIELDS-IN-QUERY-BROWSE-2-pr buf_price-doc.status_ buf_price-doc.doc-num buf_price-doc.doc-date buf_price-doc.fact-date (trim (buf_price-doc.obj-type) + " " + string (buf_price-doc.obj-code, ">>>>9")) buf_price-doc.rest-qnty buf_price-doc.sale-base buf_price-doc.rest-sale buf_price-doc.out-code
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-2-pr
&Scoped-define SELF-NAME BROWSE-2-pr
&Scoped-define QUERY-STRING-BROWSE-2-pr FOR EACH buf_price-doc NO-LOCK WHERE       buf_price-doc.pdf-id = buf_price-doc-forming.pdf-id AND       buf_price-doc.pdf-db = buf_price-doc-forming.pdf-db AND       buf_price-doc.plt-id = buf_price-doc-forming.plt-id AND       buf_price-doc.plt-db-num = buf_price-doc-forming.plt-db-num INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-BROWSE-2-pr OPEN QUERY {&SELF-NAME} FOR EACH buf_price-doc NO-LOCK WHERE       buf_price-doc.pdf-id = buf_price-doc-forming.pdf-id AND       buf_price-doc.pdf-db = buf_price-doc-forming.pdf-db AND       buf_price-doc.plt-id = buf_price-doc-forming.plt-id AND       buf_price-doc.plt-db-num = buf_price-doc-forming.plt-db-num INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-BROWSE-2-pr buf_price-doc
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-2-pr buf_price-doc


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BROWSE-1grp}~
    ~{&OPEN-QUERY-BROWSE-2-pr}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-Cancel B-mark B-sel B-add B-lkp B-chg ~
B-del B-close B-ftpl B-sch B-print B-history B-Help i-schTPL B-price-doc ~
B-del-pr B-copy i-copy loc-pdf-id R-status R-obj T-paket BROWSE-1grp ~
b-lkp-pd BROWSE-2-pr FILL-IN-6 FILL-IN-1 FILL-IN-2 loc_gop_name v-user-name
&Scoped-Define DISPLAYED-OBJECTS loc-pdf-id R-status R-obj T-paket ~
FILL-IN-6 FILL-IN-1 FILL-IN-2 loc_gop_name v-user-name

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-add
     LABEL "&Добавить"
     SIZE 10 BY 1 TOOLTIP "Добавить новый ДНЦ"
     BGCOLOR 8 .

DEFINE BUTTON B-Cancel AUTO-END-KEY
     LABEL "Вы&ход"
     SIZE 10 BY 1 TOOLTIP "Выход из режима"
     BGCOLOR 8 .

DEFINE BUTTON B-chg
     LABEL "&Изменить"
     SIZE 10 BY 1 TOOLTIP "Изменение ДНЦ"
     BGCOLOR 8 .

DEFINE BUTTON B-close
     LABEL "&Закрыть"
     SIZE 10 BY 1 TOOLTIP "Закрыть ДНЦ"
     BGCOLOR 8 .

DEFINE BUTTON B-copy
     LABEL ". Скопировать"
     SIZE 15 BY 1 TOOLTIP "Скопировать ДНЦ на другие ТПЛ"
     BGCOLOR 8 .

DEFINE BUTTON B-del
     LABEL "&Удалить"
     SIZE 10 BY 1 TOOLTIP "Удалить ДНЦ"
     BGCOLOR 8 .

DEFINE BUTTON B-del-pr
     LABEL "Удалить цены"
     SIZE 15 BY 1 TOOLTIP "Удаление цен по ДНЦ не главного ТПЛ"
     BGCOLOR 8 .

DEFINE BUTTON B-ftpl
     LABEL "_  по &ТПЛ"
     SIZE 10 BY 1 TOOLTIP "Фильтр по ТПЛ"
     BGCOLOR 8 .

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 2.88 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-history
     LABEL "История"
     SIZE 3 BY 1 TOOLTIP "История изменения документа"
     BGCOLOR 8 .

DEFINE BUTTON B-lkp
     LABEL "&Просмотр"
     SIZE 10 BY 1 TOOLTIP "Просмотр ДНЦ"
     BGCOLOR 8 .

DEFINE BUTTON b-lkp-pd
     LABEL "&Просмотр"
     SIZE 10 BY 1 TOOLTIP "Просмотр переоценки".

DEFINE BUTTON B-mark
     LABEL "*"
     SIZE 3.25 BY 1 TOOLTIP "Отметить строки"
     BGCOLOR 8 .

DEFINE BUTTON B-price-doc
     LABEL "Перео&ценки"
     SIZE 13 BY 1 TOOLTIP "Список переоценок по ДНЦ"
     BGCOLOR 8 .

DEFINE BUTTON B-print
     LABEL "Печать"
     SIZE 2.5 BY 1 TOOLTIP "Печать ДНЦ"
     BGCOLOR 8 .

DEFINE BUTTON B-sch
     LABEL "&Фильт"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-sel AUTO-GO
     LABEL "Выбор"
     SIZE 10 BY 1 TOOLTIP "Выбрать ДНЦ"
     BGCOLOR 8 .

DEFINE BUTTON i-copy
     IMAGE-UP FILE "cmp/btn-copy.bmp":U
     IMAGE-DOWN FILE "cmp/btn-copy.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/btn-copy.bmp":U
     LABEL "Button 1"
     SIZE 3 BY .75.

DEFINE BUTTON i-schTPL
     IMAGE-UP FILE "cmp/b-sch.bmp":U
     IMAGE-DOWN FILE "cmp/b-sch.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/b-sch.bmp":U
     LABEL ""
     SIZE 2.88 BY .92.

DEFINE VARIABLE FILL-IN-1 AS CHARACTER FORMAT "X(256)":U INITIAL "Статус:"
      VIEW-AS TEXT
     SIZE 7.5 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE FILL-IN-2 AS CHARACTER FORMAT "X(256)":U INITIAL "Объекты:"
      VIEW-AS TEXT
     SIZE 8.5 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE FILL-IN-6 AS CHARACTER FORMAT "X(256)":U INITIAL "№ ДНЦ:"
      VIEW-AS TEXT
     SIZE 6 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE loc-pdf-id AS INTEGER FORMAT ">>>>>>>>>>":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 14 BY 1 TOOLTIP "Поиск" NO-UNDO.

DEFINE VARIABLE loc_gop_name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 33 BY .67
     FGCOLOR 1 FONT 4 NO-UNDO.

DEFINE VARIABLE v-user-name AS CHARACTER FORMAT "X(256)":U
     LABEL "Опер"
      VIEW-AS TEXT
     SIZE 15 BY .67 TOOLTIP "Кто изменял"
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE R-obj AS INTEGER INITIAL 2
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Все", 2,
"Группа", 1
     SIZE 16 BY .67 TOOLTIP "Выбор по группам объектов" NO-UNDO.

DEFINE VARIABLE R-status AS INTEGER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Новые", 0,
"Все", 2,
"Закрытые", 3,
"Готовые", 4,
"Удаленные", 1
     SIZE 45 BY .67 TOOLTIP "Условие отбора записей" NO-UNDO.

DEFINE VARIABLE T-paket AS LOGICAL INITIAL no
     LABEL "пакетный режим"
     VIEW-AS TOGGLE-BOX
     SIZE 17 BY .83 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BROWSE-1grp FOR
      buf_price-doc-forming,
      buf_price-list-type SCROLLING.

DEFINE QUERY BROWSE-2-pr FOR
      buf_price-doc SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BROWSE-1grp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-1grp Dialog-Frame _FREEFORM
  QUERY BROWSE-1grp NO-LOCK DISPLAY
      mark-string ( buffer buf_price-doc-forming, p-rec-list ) COLUMN-LABEL "*! " FORMAT "x(1)":U
      buf_price-list-type.priority              COLUMN-LABEL "Прио-!ритет" FORMAT ">>>>9":U
      stts-string ( buffer buf_price-doc-forming )             COLUMN-LABEL "Ста-!тус" FORMAT "x(4)":U
      activ-pr ( buffer buf_price-doc-forming ) COLUMN-LABEL "Есть акт!цены"            FORMAT "x(8)":U
      buf_price-doc-forming.pdf-id   COLUMN-LABEL "Код ДНЦ! " FORMAT ">>>>>>>>>9":U
      buf_price-doc-forming.sys-date         COLUMN-LABEL "Дата!изм"  FORMAT "99/99/99":U
      buf_price-doc-forming.sys-time-chr     COLUMN-LABEL "Время!изм" FORMAT "X(5)":U
      buf_price-doc-forming.name   COLUMN-LABEL "Название документа! " FORMAT "X(100)":U WIDTH 30
      buf_price-list-type.plt-id   COLUMN-LABEL "Код!типа" FORMAT ">>>>>9":U
      buf_price-list-type.main     COLUMN-LABEL "Г! " FORMAT "+/ ":U
      buf_price-list-type.name               COLUMN-LABEL "Тип прайс-листа! " FORMAT "X(100)":U WIDTH 30
      buf_price-doc-forming.db-num-chg       COLUMN-LABEL "БД!изм"    FORMAT ">>>>9":U
      buf_price-doc-forming.pdf-db           COLUMN-LABEL "БД!док" FORMAT ">>>>9":U
      buf_price-list-type.plt-db-num         COLUMN-LABEL "БД!ТПЛ" FORMAT ">>>>9":U
      buf_price-doc-forming.out-code         COLUMN-LABEL "№!накл" FORMAT "X(16)":U
      buf_price-doc-forming.start-date         COLUMN-LABEL "Дата объекта!c"  FORMAT "99/99/99":U
      buf_price-doc-forming.end-date           COLUMN-LABEL "Дата объекта!по"  FORMAT "99/99/99":U
      buf_price-doc-forming.start-sys-date         COLUMN-LABEL "Дата sys!c"  FORMAT "99/99/99":U
      string(buf_price-doc-forming.start-sys-time,"hh:mm:ss")         COLUMN-LABEL "Время sys!c"  FORMAT "x(8)":U
      buf_price-doc-forming.end-sys-date           COLUMN-LABEL "Дата sys!по"  FORMAT "99/99/99":U
      string(buf_price-doc-forming.end-sys-time,"hh:mm:ss")           COLUMN-LABEL "Время sys!по"  FORMAT "x(8)":U
      buf_price-doc-forming.start-shift-date         COLUMN-LABEL "Дата смены!c"  FORMAT "99/99/99":U
      buf_price-doc-forming.start-shift-num          COLUMN-LABEL "№ смены!c"
      buf_price-doc-forming.end-shift-date           COLUMN-LABEL "Дата смены!по"  FORMAT "99/99/99":U
      buf_price-doc-forming.end-shift-num            COLUMN-LABEL "№ смены!по"


  ENABLE
      buf_price-doc-forming.name
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98.63 BY 11.5 ROW-HEIGHT-CHARS .6 FIT-LAST-COLUMN.

DEFINE BROWSE BROWSE-2-pr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-2-pr Dialog-Frame _FREEFORM
  QUERY BROWSE-2-pr NO-LOCK DISPLAY
      buf_price-doc.status_ COLUMN-LABEL "Статус"
      buf_price-doc.doc-num format "x(16)"
      buf_price-doc.doc-date  column-label "Дата"
      buf_price-doc.fact-date COLUMN-LABEL "Факт"
      (trim (buf_price-doc.obj-type) + " " + string (buf_price-doc.obj-code, ">>>>9")) COLUMN-LABEL "Объект" FORMAT "x(9)"
      buf_price-doc.rest-qnty column-label "Кол-во"
      buf_price-doc.sale-base COLUMN-LABEL "Сумма "
      buf_price-doc.rest-sale COLUMN-LABEL "Было "
      buf_price-doc.out-code  COLUMN-LABEL "Накладная"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98.5 BY 5.5 ROW-HEIGHT-CHARS .58.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-Cancel AT ROW 1 COL 1
     B-mark AT ROW 1 COL 11
     B-sel AT ROW 1 COL 14.25
     B-add AT ROW 1 COL 24.25
     B-lkp AT ROW 1 COL 34.25
     B-chg AT ROW 1 COL 44.25
     B-del AT ROW 1 COL 54.25
     B-close AT ROW 1 COL 64.25
     B-ftpl AT ROW 1 COL 74.25 WIDGET-ID 8
     B-sch AT ROW 1 COL 88.5 WIDGET-ID 6
     B-print AT ROW 1 COL 91.5
     B-history AT ROW 1 COL 94
     B-Help AT ROW 1 COL 97
     i-schTPL AT ROW 1.04 COL 74.25 WIDGET-ID 12 NO-TAB-STOP
     B-price-doc AT ROW 2 COL 1
     B-del-pr AT ROW 2 COL 14.13
     B-copy AT ROW 2 COL 29.25 WIDGET-ID 18
     i-copy AT ROW 2.08 COL 29.38 WIDGET-ID 20 NO-TAB-STOP
     loc-pdf-id AT ROW 3 COL 83 COLON-ALIGNED NO-LABEL
     R-status AT ROW 3.25 COL 10.63 NO-LABEL
     R-obj AT ROW 4.13 COL 10.63 NO-LABEL
     T-paket AT ROW 4.13 COL 82.13 WIDGET-ID 4
     BROWSE-1grp AT ROW 5 COL 1.38
     b-lkp-pd AT ROW 16.5 COL 12.38
     BROWSE-2-pr AT ROW 17.5 COL 1.5
     FILL-IN-6 AT ROW 3.17 COL 78.5 NO-LABEL
     FILL-IN-1 AT ROW 3.21 COL 1.88 NO-LABEL
     FILL-IN-2 AT ROW 4.13 COL 1.75 NO-LABEL
     loc_gop_name AT ROW 4.13 COL 24.25 COLON-ALIGNED NO-LABEL
     v-user-name AT ROW 16.5 COL 82 COLON-ALIGNED WIDGET-ID 2
     "ПЕРЕОЦЕНКИ" VIEW-AS TEXT
          SIZE 10.5 BY .67 AT ROW 16.63 COL 1.5
          FGCOLOR 4
     SPACE(88.38) SKIP(5.83)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Список документов назначения цены"
         DEFAULT-BUTTON B-sel CANCEL-BUTTON B-Cancel.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   External Tables: Temp-Tables.buf_price-list-type
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: buf_price-doc B "?" ? ub price-doc
      TABLE: buf_price-doc-forming B "?" ? ub price-doc-forming
      TABLE: buf_price-list-type B "NEW SHARED" ? ub price-list-type
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BROWSE-1grp T-paket Dialog-Frame */
/* BROWSE-TAB BROWSE-2-pr b-lkp-pd Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN FILL-IN-1 IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN FILL-IN-2 IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN FILL-IN-6 IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-1grp
/* Query rebuild information for BROWSE BROWSE-1grp
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR
    EACH buf_price-doc-forming WHERE
    ( r-status = 2 OR buf_price-doc-forming.stts =  r-status ) AND
    ( p-mode = "all" OR (buf_price-doc-forming.plt-id = p-plt-id AND buf_price-doc-forming.plt-db-num = p-plt-db-num))
    USE-INDEX spis ,
    FIRST buf_price-list-type  WHERE
          buf_price-list-type.plt-id = buf_price-doc-forming.plt-id AND
          buf_price-list-type.plt-db-num = buf_price-doc-forming.plt-db-num AND
       ( r-obj = 2 OR
       ( buf_price-list-type.gop-id     = loc_gop-id AND
         buf_price-list-type.gop-db-num = loc_gop-db-num )).
     _END_FREEFORM
     _Options          = "NO-LOCK"
     _Query            is OPENED
*/  /* BROWSE BROWSE-1grp */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-2-pr
/* Query rebuild information for BROWSE BROWSE-2-pr
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH buf_price-doc NO-LOCK WHERE
      buf_price-doc.pdf-id = buf_price-doc-forming.pdf-id AND
      buf_price-doc.pdf-db = buf_price-doc-forming.pdf-db AND
      buf_price-doc.plt-id = buf_price-doc-forming.plt-id AND
      buf_price-doc.plt-db-num = buf_price-doc-forming.plt-db-num INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is OPENED
*/  /* BROWSE BROWSE-2-pr */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Список документов назначения цены */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-add Dialog-Frame
ON CHOOSE OF B-add IN FRAME Dialog-Frame /* Добавить */
DO:
   define variable g#log as logical   no-undo .
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_pdf_update':U
    {&cntxt-global}
    v-cntxt-host-code-obj
    v-cntxt-obj-type
    v-cntxt-obj-code
    0
    0
    0
    true
    g#log
  }
  if not g#log then return .

  define variable v-rec-id as recid no-undo .
  define variable v-recid as character no-undo .
  define buffer buf1_price-list-type for ub.price-list-type  .
  define variable v-only-main  as logical   no-undo .
  define variable v-plt-id     as integer   no-undo .
  define variable v-plt-db-num as integer   no-undo .
  next-prev = false .
  { gbl/glstmain.i v-only-main }
  if v-only-main = false then do:
      /* сложные ТПЛ */
      run ref/typepric.w (
          input parParentProc     ,
          input "b-sel"           ,
          input-output v-recid
          ) no-error .
      find first buf1_price-list-type no-lock where recid(buf1_price-list-type) = int(v-recid) no-error .
  end.
  else do:
      /* только ГТПЛ - простой случай для текущего объекта */
      { gbl/gtplobj.i
        parparentproc
        v-cntxt-obj-type
        v-cntxt-obj-code
        no
        v-plt-id
        v-plt-db-num
        no-error }
     find first buf1_price-list-type no-lock where
                buf1_price-list-type.plt-id = v-plt-id and
                buf1_price-list-type.plt-db-num = v-plt-db-num
                no-error .
  end.


  if available buf1_price-list-type then do:
      if buf1_price-list-type.stts <> integer({&pdf-new}) then do:
         message "ДНЦ можно создать только с текущим типом прайс-листов !" view-as alert-box information  .
         return .
      end.

      if buf1_price-list-type.under-type-list <> 0 then do:
         message "Нельзя выбирать подчиненный прайс-лист !" view-as alert-box information  .
         return .
      end.

      run str/df-price.w
        ( input parparentproc,
          input {&add-def} ,
          input buf1_price-list-type.plt-id,
          input buf1_price-list-type.plt-db-num ,
          input ? ,
          output v-rec-list ,
          input-output v-rec-id ,
          input-output br-handle ,
          input-output buffer-handle ,
          input-output next-prev
          ) .

      run openbr in this-procedure .
      reposition BROWSE-1grp to recid v-rec-id no-error .
      apply "VALUE-CHANGED" to browse-1grp in frame {&frame-name}.
    end.
    else do:
      message "Не выбран ТПЛ !!!" view-as alert-box .
      return no-apply .
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-chg Dialog-Frame
ON CHOOSE OF B-chg IN FRAME Dialog-Frame /* Изменить */
DO:
   define variable g#log as logical   no-undo .
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_pdf_update':U
    {&cntxt-global}
    v-cntxt-host-code-obj
    v-cntxt-obj-type
    v-cntxt-obj-code
    0
    0
    0
    true
    g#log
  }
  if not g#log then return .

  next-prev = false .
  if not available buf_price-doc-forming then return .
  if buf_price-doc-forming.stts <> integer({&pdf-new}) then do:
   message "Закрытые или удаленные ДНЦ корректировать нельзя! "
         view-as alert-box information .
   return .
   end.
  define variable v-rec-id as recid no-undo .
  define variable v-recid as character no-undo .

  if available buf_price-doc-forming then do:
      v-rec-id = recid (buf_price-doc-forming) .

      run str/df-price.w
      ( input parparentproc,
        input {&update} ,
        input buf_price-doc-forming.plt-id,
        input buf_price-doc-forming.plt-db-num ,
        input ? ,
        output v-rec-list ,
        input-output v-rec-id ,
        input-output br-handle ,
        input-output buffer-handle ,
        input-output next-prev

        ) .
      run openbr in this-procedure .
      reposition BROWSE-1grp to recid v-rec-id no-error .
      apply "VALUE-CHANGED" to browse-1grp in frame {&frame-name}.
    end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-close
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-close Dialog-Frame
ON CHOOSE OF B-close IN FRAME Dialog-Frame /* Закрыть */
DO:
   define variable g#log as logical   no-undo .
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_pdf_close':U
    {&cntxt-global}
    v-cntxt-host-code-obj
    v-cntxt-obj-type
    v-cntxt-obj-code
    0
    0
    0
    true
    g#log
  }
  if not g#log then return .

define variable v-rec-id as recid no-undo .
define variable v-mode as character no-undo .
define variable v-ask-pr as logical   no-undo .

 if var-paket = false then do:
  if not available buf_price-doc-forming then return .
  if buf_price-doc-forming.stts <> integer({&pdf-new}) then do:
   message "Закрытые или удаленные ДНЦ закрывать нельзя! "
            view-as alert-box information .
   return .
   end.
  v-rec-id = recid(buf_price-doc-forming) .
  if buf_price-list-type.main = true  then do:
     run str/pdf-cask.w ( input parparentproc , input recid( buf_price-doc-forming ) , output v-mode , output v-ask-pr ) .
     if v-mode = "" or  v-ask-pr = ? then return no-apply.
  end.
  else do:
  message "Закрывать ДНЦ" buf_price-doc-forming.pdf-id "?"
      view-as alert-box question
      buttons yes-no
      update var-ok as logical
      .
  if var-ok =  false then return .
  end.
    run str/diallog.w
        (parparentproc
        , this-procedure
        , 'str/pdf-clos.p':U
        , ( string(v-rec-id) + {&delim-par} +
           'no' + {&delim-par} +
           'no' + {&delim-par} +
           '?' + {&delim-par} +
           '?' + {&delim-par} +
           string(v-mode) + {&delim-par} +
           '?' + {&delim-par} +
           string(v-ask-pr)  )
        , yes /*p-auto-go*/
        , '':U
        , 'Закрытие ДНЦ') no-error .

    if error-status :error then
    message
      error-status :get-message(1) skip
      return-value skip
      "Ошибка закрытия ДНЦ"
      view-as alert-box error
    .
  end.
  else do:
      define variable nn as integer   no-undo .
      define variable v-recid as recid no-undo .
      define buffer cl_price-doc-forming for ub.price-doc-forming  .
      define buffer cl_price-list-type   for ub.price-list-type  .
      define variable i as integer   no-undo .
      nn = num-entries(p-rec-list) .
          if nn = 0 then do:
              message "Не выбрано ни одной строки для закрытия! "  view-as alert-box information .
              return .
          end.
          message substitute("Закрыть &1 отмеченных ДНЦ ?  " , nn)
            view-as alert-box question
            buttons yes-no
            update v-ok as logical.
          if v-ok then do:
            repeat i = 1 to nn :
                v-recid = int(entry( i , p-rec-list )) .
                find first cl_price-doc-forming no-lock where
                    recid(cl_price-doc-forming) = v-recid no-error .
                    if available cl_price-doc-forming then do:
                        find first cl_price-list-type no-lock where
                                  cl_price-list-type.plt-id = cl_price-doc-forming.plt-id and
                                  cl_price-list-type.plt-db-num = cl_price-doc-forming.plt-db-num
                                  no-error .
                             if cl_price-doc-forming.stts <> integer({&pdf-new})   then do:
                                message substitute("ДНЦ &1 закрыть уже нельзя !" , cl_price-doc-forming.pdf-id) view-as alert-box information .
                              end.
                              else do:
                                  if cl_price-list-type.main = true  then do:
                                      if v-mode = "" or  v-ask-pr = ? then
                                      run str/pdf-cask.w ( input parparentproc , input recid(cl_price-doc-forming ) , output v-mode , output v-ask-pr ) .
                                          if v-mode = "" or  v-ask-pr = ? then do:
                                              next.
                                          end.
                                  end.
                                    run str/diallog.w
                                        (parparentproc
                                        , this-procedure
                                        , 'str/pdf-clos.p':U
                                        , ( string(recid(cl_price-doc-forming )) + {&delim-par} +
                                          'no' + {&delim-par} +
                                          'no' + {&delim-par} +
                                          '?' + {&delim-par} +
                                          '?' + {&delim-par} +
                                          string(v-mode) + {&delim-par} +
                                          '?' + {&delim-par} +
                                          string(v-ask-pr)  )
                                        , yes /*p-auto-go*/
                                        , '':U
                                        , 'Закрытие ДНЦ') no-error .
                          end.
                    end.
            end.
          end.
  end.

  run openbr in this-procedure .
  reposition BROWSE-1grp to recid v-rec-id no-error .
  apply "VALUE-CHANGED" to browse-1grp in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-copy
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-copy Dialog-Frame
ON CHOOSE OF B-copy IN FRAME Dialog-Frame /* . Скопировать */
DO:
/* 888888 */
  define variable g#log as logical   no-undo .
{ gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_pdf_update':U
  {&cntxt-global}
  v-cntxt-host-code-obj
  v-cntxt-obj-type
  v-cntxt-obj-code
  0
  0
  0
  true
  g#log
}
if not g#log then return .

define variable v-rec-id     as recid     no-undo .
define variable v-plt-db-num as integer   no-undo .
define variable v-plt-id     as integer   no-undo .
define variable v-pdf-db-num as integer   no-undo .
define variable v-pdf-id     as integer   no-undo .
define variable v-ok1        as integer   no-undo .


if not available buf_price-doc-forming then return.
v-rec-id = recid (buf_price-doc-forming) .

  message "Копировать ДНЦ №" buf_price-doc-forming.pdf-id skip
          "БД:"              buf_price-doc-forming.pdf-db skip
          "на другой ТПЛ ?"                               skip

  "При копировании из текущего ДНЦ в новый ДНЦ перенесутся все баркоды с ценами КАК ЕСТЬ, " skip
  "При этом не проверяются НИ КАКИЕ настройки !!! " skip
  "(ни проверка наличия спец цен (шкал,партий и другой единицы измерения), ни проверка наличия свободной зоны, "
  " ни ограничения нового ТПЛ)"

  view-as alert-box question
  button yes-no
  update v-ok as logical .

  if not v-ok then return .

define variable v-spis-recid as character no-undo .
define variable i as integer   no-undo .
define variable v-kol as integer   no-undo .

define buffer bufc_price-list-type for ub.price-list-type  .


v-spis-recid = "" .
run ref/typepric.w (
    input parParentProc     ,
    input "mode=all,b-mark,b-sel,title=ВЫБИРИТЕ Типы Прайс-листов для копирования endtitle" ,
    input-output v-spis-recid
    ) no-error .
    v-kol = num-entries(v-spis-recid).
    v-ok1 = 0.
    repeat i = 1 to v-kol :
       find first bufc_price-list-type no-lock  where recid(bufc_price-list-type) = int(entry(i,v-spis-recid)) no-error .
       if bufc_price-list-type.stts <> 0 then next.

       v-plt-db-num = bufc_price-list-type.plt-db-num .
       v-plt-id     = bufc_price-list-type.plt-id     .

       run copy_new_price-doc-forming (
           input v-rec-id  ,
           input-output v-plt-db-num  ,
           input-output v-plt-id      ,
           output v-pdf-db-num  ,
           output v-pdf-id
           ) no-error .
           if not error-status :error then do:
              v-ok1 = v-ok1 + 1 .
           end.

    end.

  run openbr in this-procedure .
  reposition BROWSE-1grp to recid v-rec-id no-error .
  apply "VALUE-CHANGED" to browse-1grp in frame {&frame-name}.

  message substitute ( "Создано &1 копий ДНЦ" , v-ok1 ) view-as alert-box information .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-del Dialog-Frame
ON CHOOSE OF B-del IN FRAME Dialog-Frame /* Удалить */
DO:
define variable v-rec-id as integer   no-undo .
if not available buf_price-doc-forming then return .
   define variable g#log as logical   no-undo .
   if buf_price-doc-forming.stts = integer({&pdf-fact}) then do:
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_pdf_delete-fact':U
    {&cntxt-global}
    v-cntxt-host-code-obj
    v-cntxt-obj-type
    v-cntxt-obj-code
    0
    0
    0
    true
    g#log
  }

   end.
   else do:
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_pdf_delete':U
    {&cntxt-global}
    v-cntxt-host-code-obj
    v-cntxt-obj-type
    v-cntxt-obj-code
    0
    0
    0
    true
    g#log
  }
  end.
  if not g#log then return .

 v-rec-id = recid (buf_price-doc-forming) no-error .
if var-paket = false  then do:
  if not available buf_price-doc-forming then return .
  if buf_price-list-type.main = true  and
     buf_price-doc-forming.stts = integer({&pdf-fact})
     then do:
      message "ДНЦ :" buf_price-doc-forming.name skip
              "№" buf_price-doc-forming.pdf-id
              "главного типа  - удалять нельзя !!!"
              view-as alert-box error
              title "Внимание !" .
              return.
  end.
  message "Удалять ДНЦ : " buf_price-doc-forming.name skip
          "№" buf_price-doc-forming.pdf-id "?"
          view-as alert-box question
          buttons yes-no update g-ok as log.
  if not g-ok then return .

  run price-doc-forming-delete (
      buf_price-doc-forming.plt-db-num ,
      buf_price-doc-forming.plt-id     ,
      buf_price-doc-forming.pdf-db     ,
      buf_price-doc-forming.pdf-id     ,
      v-cntxt-db-num                   ,
      v-cntxt-userid                   )
      no-error .
 end.
 else do:
 define variable nn as integer   no-undo .
 define variable v-recid as recid no-undo .
 define buffer del_price-doc-forming for ub.price-doc-forming  .
 define buffer del_price-list-type for ub.price-list-type  .
 define variable i as integer   no-undo .
 nn = num-entries(p-rec-list) .
    if nn = 0 then do:
        message "Не выбрано ни одной строки для удаления! "  view-as alert-box information .
        return .
    end.
    message substitute("Удалить &1 отмеченных ДНЦ ?  " , nn)
      view-as alert-box question
      buttons yes-no
      update v-ok as logical.
    if v-ok then do:
       repeat i = 1 to nn :
          v-recid = int(entry( i , p-rec-list )) .
          find first del_price-doc-forming no-lock where
               recid(del_price-doc-forming) = v-recid no-error .
               if available del_price-doc-forming then do:
                  find first del_price-list-type no-lock where
                             del_price-list-type.plt-id = del_price-doc-forming.plt-id and
                             del_price-list-type.plt-db-num = del_price-doc-forming.plt-db-num
                             no-error .
                    if  del_price-list-type.main = true  and
                        del_price-doc-forming.stts = integer({&pdf-fact})   then do:
                          message substitute("Удалять ДНЦ &1 нельзя !" , del_price-doc-forming.pdf-id) view-as alert-box information .
                        end.
                        else do:
                        run price-doc-forming-delete (
                            del_price-doc-forming.plt-db-num ,
                            del_price-doc-forming.plt-id     ,
                            del_price-doc-forming.pdf-db     ,
                            del_price-doc-forming.pdf-id     ,
                            v-cntxt-db-num                   ,
                            v-cntxt-userid                   )
                            no-error .
                    end.
               end.
       end.
    end.
 end.
 p-rec-list = "" .
 if error-status :error then return no-apply .
 run openbr in this-procedure .
 reposition browse-1grp to recid v-rec-id no-error .
 apply "VALUE-CHANGED" to browse-1grp in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-del-pr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-del-pr Dialog-Frame
ON CHOOSE OF B-del-pr IN FRAME Dialog-Frame /* Удалить цены */
DO:

define variable v-rec-id as recid no-undo .
if not available buf_price-doc-forming then return.
  message "Удалить цены по прайс-листу ?"
  view-as alert-box question
  button yes-no
  update v-ok as logical .

  if v-ok then do:
        v-rec-id = recid (buf_price-doc-forming) .
        for each ub.price-all exclusive-lock where
                ub.price-all.pdf-db        = buf_price-doc-forming.pdf-db      and
                ub.price-all.pdf-id        = buf_price-doc-forming.pdf-id      and
                ub.price-all.plt-db-num    = buf_price-doc-forming.plt-db-num  and
                ub.price-all.plt-id        = buf_price-doc-forming.plt-id
                :
                delete ub.price-all.
        end.
        run openbr in this-procedure .
        reposition BROWSE-1grp to recid v-rec-id no-error .
        apply "VALUE-CHANGED" to browse-1grp in frame {&frame-name}.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-ftpl
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-ftpl Dialog-Frame
ON CHOOSE OF B-ftpl IN FRAME Dialog-Frame /* _  по ТПЛ */
DO:
  run ini-flt-tpl in this-procedure .
  apply "VALUE-CHANGED" to browse-1grp in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-history
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-history Dialog-Frame
ON CHOOSE OF B-history IN FRAME Dialog-Frame /* История */
DO:
  if not available buf_price-doc-forming then return .
  run ref/cpr-form.w ( parParentProc ,
        buf_price-doc-forming.plt-id    ,
        buf_price-doc-forming.plt-db-num ,
        buf_price-doc-forming.pdf-id    ,
        buf_price-doc-forming.pdf-db      ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-lkp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-lkp Dialog-Frame
ON CHOOSE OF B-lkp IN FRAME Dialog-Frame /* Просмотр */
DO:

   define variable g#log as logical   no-undo .
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_pdf_lookup':U
    {&cntxt-global}
    v-cntxt-host-code-obj
    v-cntxt-obj-type
    v-cntxt-obj-code
    0
    0
    0
    true
    g#log
  }
  if not g#log then return .

if not available buf_price-doc-forming then return .

define variable v-rec-id as recid no-undo .
define variable v-recid as character no-undo .

  assign
    v-rec-id      = recid (buf_price-doc-forming)
    next-prev     = yes
    br-handle     = BROWSE-1grp:handle
    buffer-handle = buffer buf_price-doc-forming :handle .
    .
  do while next-prev = yes :
      if not available buf_price-doc-forming then do:
        message "Неправильно выбран документ ДНЦ." view-as alert-box error.
        return no-apply.
      end.
      run str/df-price.w
        ( input parparentproc,
          input {&lookup} ,
          input buf_price-doc-forming.plt-id ,
          input buf_price-doc-forming.plt-db-num ,
          input ? ,
          output v-rec-list  ,
          input-output v-rec-id  ,
          input-output br-handle ,
          input-output buffer-handle ,
          input-output next-prev
          ) .
  end.

  run openbr in this-procedure .
  reposition browse-1grp to recid v-rec-id no-error .
  apply "VALUE-CHANGED" to browse-1grp in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-lkp-pd
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-lkp-pd Dialog-Frame
ON CHOOSE OF b-lkp-pd IN FRAME Dialog-Frame /* Просмотр */
DO:
DEFINE VARIABLE g#log AS LOGICAL NO-UNDO.
DEFINE VARIABLE v-doc-rec AS recid NO-UNDO.
if not available buf_price-doc then return .
v-doc-rec = recid(buf_price-doc) .
{ gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_overvalue_lookup':U
  {&cntxt-object}
  buf_price-doc.host-code
  buf_price-doc.obj-type
  buf_price-doc.obj-code
  0
  0
  0
  true
  g#log
}
if g#log <> yes then return no-apply.
run str/pr-lkp.p ( input parParentProc    ,
                   input v-doc-rec
                   ) .

reposition BROWSE-2-pr to recid v-doc-rec no-error.
apply "entry" to BROWSE-2-pr in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mark Dialog-Frame
ON CHOOSE OF B-mark IN FRAME Dialog-Frame /* * */
DO:

    if available buf_price-doc-forming then do:
      { gbl/markstrn.i buf_price-doc-forming p-rec-list }
        g-log = browse-1grp:refresh() .
      if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
          g-log = browse-1grp:select-next-row ().
          apply "VALUE-CHANGED" to browse-1grp in frame {&frame-name}.
      end.
    end.

    apply "display" to browse-1grp in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-price-doc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-price-doc Dialog-Frame
ON CHOOSE OF B-price-doc IN FRAME Dialog-Frame /* Переоценки */
DO:
  /**/
  define variable loc-ref-list as character no-undo .
  define variable p-list-mode as character no-undo .
  define variable v-rec-id as recid no-undo .
  p-list-mode = "pricedocforming":U .
  if not available buf_price-doc-forming then return .
  v-rec-id = recid(buf_price-doc-forming) .

  run str/pr-docs.w
    (input parparentproc
    ,input "b-mark":U
    ,input p-list-mode
    ,input ""
    ,input v-cntxt-obj-type
    ,input v-cntxt-obj-code
    ,input string( v-rec-id )
    ,output loc-ref-list
    ) .
  run openbr in this-procedure .
  reposition BROWSE-1grp to recid v-rec-id no-error .
  apply "VALUE-CHANGED" to browse-1grp in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-print Dialog-Frame
ON CHOOSE OF B-print IN FRAME Dialog-Frame /* Печать */
DO:
  run rep/g-dfc.p
     ( parParentProc,
       recid(buf_price-doc-forming)
       ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-sch
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-sch Dialog-Frame
ON CHOOSE OF B-sch IN FRAME Dialog-Frame /* Фильт */
DO:
  /*фильтр*/
  run init-flt in this-procedure no-error.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-sel Dialog-Frame
ON CHOOSE OF B-sel IN FRAME Dialog-Frame /* Выбор */
DO:
  if ( available buf_price-doc-forming ) AND ( p-rec-list = "" ) THEN
                  p-rec-list = string( recid ( buf_price-doc-forming )) .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BROWSE-1grp
&Scoped-define SELF-NAME BROWSE-1grp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BROWSE-1grp Dialog-Frame
ON MOUSE-SELECT-DBLCLICK OF BROWSE-1grp IN FRAME Dialog-Frame
DO:
  apply  "CHOOSE":U to b-lkp.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BROWSE-1grp Dialog-Frame
ON ROW-DISPLAY OF BROWSE-1grp IN FRAME Dialog-Frame
DO:
  if available buf_price-doc-forming then do:
     if buf_price-list-type.ban-discnt > 0 then do:
        run color-all ( 5 ) .
     end.
     else do:
       run color-all ( ? ) .
     end.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BROWSE-1grp Dialog-Frame
ON VALUE-CHANGED OF BROWSE-1grp IN FRAME Dialog-Frame
DO:
  {&OPEN-QUERY-BROWSE-2-pr}
  if available buf_price-doc-forming then do:
  { gbl/usrfulnm.i
  buf_price-doc-forming.who
  v-user-name
  }
  end.
  display  v-user-name with frame {&frame-name} .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME i-copy
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL i-copy Dialog-Frame
ON CHOOSE OF i-copy IN FRAME Dialog-Frame /* Button 1 */
DO:
  APPLY "choose" TO B-copy.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME i-schTPL
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL i-schTPL Dialog-Frame
ON CHOOSE OF i-schTPL IN FRAME Dialog-Frame
DO:
  APPLY "choose" TO B-ftpl.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME loc-pdf-id
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL loc-pdf-id Dialog-Frame
ON LEAVE OF loc-pdf-id IN FRAME Dialog-Frame
DO:

END.

ON CTRL-J OF loc-pdf-id IN FRAME {&frame-name}
DO:
  assign loc-pdf-id .
  run seach-pdf-id in this-procedure ( loc-pdf-id , true  ) no-error .
  if error-status:error then return no-apply.
END.

ON RETURN OF loc-pdf-id IN FRAME {&frame-name}
DO:
assign loc-pdf-id no-error .
  if error-status:error then return no-apply.
  run seach-pdf-id in this-procedure ( loc-pdf-id , false  ) no-error .
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME R-obj
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL R-obj Dialog-Frame
ON VALUE-CHANGED OF R-obj IN FRAME Dialog-Frame
DO:
loc_gop_name      = "" .
loc_gop-db-num    = 0 .
loc_gop-id        = 0 .
define variable s-ref as character no-undo .
   assign r-obj .
   if r-obj = 1 then do:
        run ref/gr-objpr.w ( input  parparentproc ,"b-sel" , input-output s-ref ) .
        if s-ref = ? or s-ref = '' then do:
           r-obj = 2.
           display r-obj with frame {&frame-name}.
           return no-apply.
        end.
        find ub.grp-obj-price where recid ( ub.grp-obj-price ) = int(s-ref) no-lock .
        if available ub.grp-obj-price then do:
            loc_gop_name      = ub.grp-obj-price.name  .
            loc_gop-db-num    = ub.grp-obj-price.gop-db-num .
            loc_gop-id        = ub.grp-obj-price.gop-id  .
        end.
   end.

   display loc_gop_name with frame {&frame-name}.
  run openbr in this-procedure .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME R-status
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL R-status Dialog-Frame
ON VALUE-CHANGED OF R-status IN FRAME Dialog-Frame
DO:
  ASSIGN R-status .
  run openbr in this-procedure .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME T-paket
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL T-paket Dialog-Frame
ON VALUE-CHANGED OF T-paket IN FRAME Dialog-Frame /* пакетный режим */
DO:
   assign T-paket .
   var-paket = t-paket .
   if T-paket then do:
      enable  b-close b-del b-mark with frame {&frame-name} .
      disable b-add b-chg b-copy i-copy  with frame {&frame-name} .
   end.
   else do:
      if LOOKUP ("b-add":U,    p-bttns) <> 0 then
         enable  b-add b-copy i-copy  with frame {&frame-name} .
      if LOOKUP ("b-chg":U,    p-bttns) <> 0 then
         enable  b-chg with frame {&frame-name} .
      if LOOKUP ("b-mark":U,    p-bttns) = 0 then
         disable  b-mark with frame {&frame-name} .


   end.
  /* 777 */
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

{ gbl/app_help.i &disable_diasize=true }

{ gbl/diasize.i &browse-name=BROWSE-1grp }

run diasize_add_browse in this-procedure
  (input  'width':u
  ,input  browse BROWSE-2-pr:handle
  ) .
run diasize_init in this-procedure .

{ gbl/brwrefre.i  "run openbr in this-procedure . "}

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  buf_price-list-type.name:resizable in browse {&browse-name}   = true .
  buf_price-doc-forming.name:resizable in browse {&browse-name}   = true .
  buf_price-doc-forming.name:read-only in browse {&browse-name}   = true .

  frame {&frame-name}:TITLE = ( if p-mode = "pl-type":U  then ("ДНЦ по ТИПУ прайс-листа № " + string( p-plt-id) + " БД " + string( p-plt-db-num))
                                                        else "Документы назначения цены" )   .
  v-title-0 = frame {&frame-name}:TITLE .
  R-status = 2.
  run my_en in this-procedure .

  apply "VALUE-CHANGED" to BROWSE-1grp IN FRAME {&frame-name} .
  disable
     B-sel      when LOOKUP ("b-sel":U,    p-bttns) = 0
     B-add      when LOOKUP ("b-add":U,    p-bttns) = 0
     B-copy     when LOOKUP ("b-add":U,    p-bttns) = 0
     i-copy     when LOOKUP ("b-add":U,    p-bttns) = 0
     B-chg      when LOOKUP ("b-chg":U,    p-bttns) = 0
     B-del      when LOOKUP ("b-del":U,    p-bttns) = 0
     B-del-pr   when LOOKUP ("b-del":U,    p-bttns) = 0
     B-mark     when LOOKUP ("b-mark":U,   p-bttns) = 0
    with frame {&frame-name} .
  hide B-del-pr in frame {&frame-name} .
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
run disable_ui in this-procedure .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE color-all Dialog-Frame
PROCEDURE color-all :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input  parameter p-color as integer   no-undo .
  buf_price-doc-forming.pdf-id:fgcolor  in browse {&browse-name} =  p-color.
  buf_price-doc-forming.name:fgcolor    in browse {&browse-name} =  p-color.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

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
  DISPLAY loc-pdf-id R-status R-obj T-paket FILL-IN-6 FILL-IN-1 FILL-IN-2
          loc_gop_name v-user-name
      WITH FRAME Dialog-Frame.
  ENABLE B-Cancel B-mark B-sel B-add B-lkp B-chg B-del B-close B-ftpl B-sch
         B-print B-history B-Help i-schTPL B-price-doc B-del-pr B-copy i-copy
         loc-pdf-id R-status R-obj T-paket BROWSE-1grp b-lkp-pd BROWSE-2-pr
         FILL-IN-6 FILL-IN-1 FILL-IN-2 loc_gop_name v-user-name
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ini-flt-tpl Dialog-Frame
PROCEDURE ini-flt-tpl :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
define variable v-point as character no-undo .
define variable v-label as character no-undo .
  assign
  tbl = "price-list-type"
  join-tbl = "buf_price-list-type"
  fld = ""
  lab = ""
  spr = ""
  dim = '0'
  v-point = "tpl-pdf-obj"
  v-label = "Типы прайс-листов"
  .
  run fltfield-add in this-procedure('main'        , 'Главный тип (ГТПЛ)',    '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('only-gbd'    , 'Автопереоценки', '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('priority'    , 'Приоритет ТПЛ',  '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('ban-discnt'  , 'Шаблон Скидки',  '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('gop-db-num{&delim-flt}gop-id'  , 'Группа объектов ценообразования','gop', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('name'        , 'Название ТПЛ',   '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('stts'        , 'Статус',         '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('sys-date'    , 'Дата изменения', '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('sys-time'    , 'Время изменения', 'time', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('who'         , 'Кто', 'usr', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.

Filter-Block:
DO  ON STOP    UNDO Filter-Block, LEAVE Filter-Block
    ON ERROR   UNDO Filter-Block, LEAVE Filter-Block
    ON END-KEY UNDO Filter-Block, LEAVE Filter-Block :
  run gbl/filter.w ( INPUT parparentproc,
  INPUT v-point + {&delim-par} + v-label + {&delim-par} + "yes",
  INPUT tbl, INPUT join-tbl, INPUT fld, INPUT lab, INPUT spr, INPUT dim ).
  run gbl/flt-get.p
      (input v-point
      ,output v-flt-rec
      ,output v-filter-name
      ,output v-where-phrase
      ,output v-sort-phrase
      ,output v-where-phrase-rus
      ,output v-sort-phrase-rus
      ).

  B-ftpl:tooltip in frame {&frame-name}  = v-filter-name .
  if v-flt-rec = ? then do:
     i-schTPL:LOAD-IMAGE ("cmp/b-sch.bmp") .
     v-filter-name  = 'Фильтр по ТПЛ не установлен' .
  end.
  else do:
     i-schTPL:LOAD-IMAGE ("cmp/b-sche.bmp") .
  end.
  B-ftpl:tooltip in frame {&frame-name}  = v-filter-name .
  i-schTPL:tooltip in frame {&frame-name}  = v-filter-name .

  run openbr in this-procedure .
END. /* Filter-Block */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-flt Dialog-Frame
PROCEDURE init-flt :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  assign
  tbl = "price-doc-forming"
  join-tbl = "buf_price-doc-forming"
  fld = ""
  lab = ""
  spr = ""
  dim = '0'
  .
  run fltfield-add in this-procedure('pdf-id', '№ ДНЦ', '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('pdf-db', 'БД создания ДНЦ', '',input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('plt-id', '№ ТПЛ', '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('plt-db-num', 'БД создания ТПЛ', '',input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('name', 'Название ДНЦ', '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('out-code', 'Накладная', '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('stts', 'Статус', '',  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('des', 'Описание', '',input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('end-date', 'Дата конца', '',input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('end-shift-date', 'Сменная дата конца', '',input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('end-shift-name', 'Номер конца смены', '',input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('end-shift-num', '№ смены конца', '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('end-sys-date', 'Системная дата конца', '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('end-sys-time', 'Системное время конца', 'time', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('have-end-period', 'Есть конец периода', '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('have-start-period', 'Есть начало периода', '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('main-pdf-db', 'БД главного ДНЦ', '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('main-pdf-id', '№ главного ДНЦ', '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('start-date', 'Дата начала', '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('start-shift-date', 'Сменная дата начала', '',input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('start-shift-name', 'Номер начала смены', '',input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('start-shift-num', '№ смены начала', '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('start-sys-date' , 'Системная дата начала', '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('start-sys-time' , 'Системное время начала', 'time', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('sys-date', 'Дата изменения', '',input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('sys-time', 'Время изменения', 'time',input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('db-num-chg', 'БД изменения', '',input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('who' , 'Правил', 'usr',input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
Filter-Block:
DO ON STOP    UNDO Filter-Block, LEAVE Filter-Block
    ON ERROR   UNDO Filter-Block, LEAVE Filter-Block
    ON END-KEY UNDO Filter-Block, LEAVE Filter-Block :
  run gbl/filter.w (
  INPUT parparentproc,
  INPUT filter-point + {&delim-par} + filter-label + {&delim-par} + "yes",
  INPUT tbl,
  INPUT join-tbl,
  INPUT fld,
  INPUT lab,
  INPUT spr,
  INPUT dim ).
  run openbr in this-procedure .
END. /* Filter-Block */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my_en Dialog-Frame
PROCEDURE my_en :
/*------------------------------------------------------------------------------
  Purpose:     ENABLE the User Interface
  Parameters:  <none>
  Notes:       Here we display/view/enable the widgets in the
               user-interface.  In addition, OPEN all queries
               associated with each FRAME and BROWSE.
               These statements here are based on the "Other
               Settings" section of the widget Property Sheets.
------------------------------------------------------------------------------*/
  DISPLAY loc-pdf-id R-status R-obj T-paket FILL-IN-6 FILL-IN-1 FILL-IN-2
          loc_gop_name v-user-name
      WITH FRAME Dialog-Frame.
  ENABLE B-Cancel B-mark B-sel B-add B-lkp B-chg B-del B-close B-print B-sch B-sch B-ftpl
         B-history B-Help B-price-doc B-del-pr loc-pdf-id R-status R-obj
         T-paket BROWSE-1grp b-lkp-pd BROWSE-2-pr FILL-IN-6 FILL-IN-1 FILL-IN-2
         loc_gop_name v-user-name i-schTPL b-copy i-copy
      WITH FRAME Dialog-Frame.
  DISPLAY i-schTPL   WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
   run openbr  in this-procedure .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE openbr Dialog-Frame
PROCEDURE openbr :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
define variable p-open-query       as logical no-undo init true .
define variable l-query-was-opened as logical no-undo .
define variable doc-rec  as recid     no-undo .
define variable p-find-next      as logical   no-undo .
define variable p-find-condition as character no-undo .

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

define variable title0 as character no-undo init "Список ДНЦ" .

&scop flt-open-open-query OPEN QUERY BROWSE-1grp FOR EACH buf_price-doc-forming no-lock

&scop flt-open-dyn_open-query  FOR EACH buf_price-doc-forming

&scop flt-open-query-handle query BROWSE-1grp:handle

&scop flt-open-find-buffer-name  buf_price-doc-forming

&scop flt-open-open-query-tail , ~
    FIRST buf_price-list-type  WHERE ~
          buf_price-list-type.plt-id = buf_price-doc-forming.plt-id AND   ~
          buf_price-list-type.plt-db-num = buf_price-doc-forming.plt-db-num AND ~
          ( r-obj = 2 OR  ( buf_price-list-type.gop-id     = loc_gop-id AND  ~
                            buf_price-list-type.gop-db-num = loc_gop-db-num ))


&scop flt-open-dyn_open-query-tail   substitute(' , ~
    FIRST buf_price-list-type  WHERE  ~
          buf_price-list-type.plt-id = buf_price-doc-forming.plt-id AND ~
          buf_price-list-type.plt-db-num = buf_price-doc-forming.plt-db-num &5 AND  ~
          ( &4 = 2 OR  ( buf_price-list-type.gop-id     = &2 AND ~
                            buf_price-list-type.gop-db-num = &3 )) &6 ', ~{&double-quote~} , loc_gop-id , loc_gop-db-num , r-obj  ,v-where-phrase , v-sort-phrase)






&scop flt-open-query-was-opened     l-query-was-opened

&scop flt-open-sort-column-phrase   sort-column-phrase

&scop flt-open-call-point           filter-point

&scop flt-open-set-filter-name      set-filter-name

&scop flt-open-indexed-reposition

&scop flt-open-query               p-open-query

&scop flt-open-table-name          buf_price-doc-forming

&scop flt-open-search-option       no-lock

&scop flt-open-find-next           p-find-next

&scop flt-open-find-recid          doc-rec

&scop flt-open-find-condition       p-find-condition

&scop flt-open-find-buffer-def      define buffer buf_price-doc-forming for price-doc-forming.

&scop flt-open-debug-file

&scop flt-open-waitfram             true


  { gbl/fltopend.i
    &where-cond = "( r-status = 2 OR buf_price-doc-forming.stts =  r-status ) AND ~
                   ( p-mode = 'all' OR ~
                   ( buf_price-doc-forming.plt-id = p-plt-id AND buf_price-doc-forming.plt-db-num = p-plt-db-num )) "

   &dyn_where-cond = " substitute('( &1 = 2 OR buf_price-doc-forming.stts =  &1 ) AND    ~
                      ( &5&2&5 = &5all&5 OR ~
                      ( buf_price-doc-forming.plt-id = &3 AND  ~
                        buf_price-doc-forming.plt-db-num = &4 )) ' , ~
                        r-status, p-mode, p-plt-id, p-plt-db-num , ~{&double-quote~} ~
                        ) "
    &use-indFIRST  = " "
    &by         = "  "
}

APPLY "VALUE-CHANGED" TO {&BROWSE-NAME} in frame {&frame-name}.
APPLY "ENTRY" TO {&BROWSE-NAME}.

  {&OPEN-QUERY-BROWSE-2-pr}

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE seach-pdf-id Dialog-Frame
PROCEDURE seach-pdf-id :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input  parameter p-id as INTEGER no-undo .
define input  parameter p-next as logical   no-undo .
if p-next = true then do:
   find next buf_price-doc-forming no-lock where
      buf_price-doc-forming.pdf-id     = p-id no-error .
      if not available buf_price-doc-forming then do:
        message "Еще запись не найдена ! " view-as alert-box information .
        return .
      end.
end.
else do:
  find first buf_price-doc-forming no-lock where
             buf_price-doc-forming.pdf-id     = p-id
 no-error .
              if not available buf_price-doc-forming then do:
                message "Запись не найдена !" view-as alert-box information .
                return .
              end.
end.
reposition {&browse-name} to rowid rowid(buf_price-doc-forming) no-error .
apply "value-changed" to {&browse-name} in frame {&frame-name}.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE set-filter-name Dialog-Frame
PROCEDURE set-filter-name :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define input parameter p-filter-name as character no-undo .

  do with frame {&frame-name}:
    if p-filter-name > "" then do:
      assign
        frame {&frame-name}:title
          = v-title-0  + "   ФИЛЬТР: " + p-filter-name.
      .
      assign
        b-sch :TOOLTIP = "Установлен фильтр " + p-filter-name
      .
    end.
    else do:
      assign
        b-sch :TOOLTIP = ""
        frame {&frame-name}:title = v-title-0 .
      .
    end.
  end. /* do with frame */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME