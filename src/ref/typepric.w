&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v9r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE NEW SHARED BUFFER buf_price-list-type FOR price-list-type.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Справочник Типов прайс-листов

Автор: Чернова Светлана Александровна
Дата создания: 11/10/05
Author: Svetlana Chernova
Creation date: 11/10/05

bttn + mode=gop-id ---> grp-obj-price /* по группе объектов */
     + mode=bgr-id ---> buyer-group
     + mode=tog-id ---> turnover-group
     + mode=twotpl ---> раскрасить двойников по ТПЛ
     + mode=ban-discnt ---> с Шаблонами скидок

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input  parameter parParentProc as handle no-undo .
define input  parameter p-bttns as character no-undo .
define input-output parameter  p-rec-list as character no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Справочник Типов прайс-листов".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i  }
{ cmp/library.i  }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
{ gbl/waitfram.i }
{ gbl/color.i    }
{ gbl/usr-flt.i  }
{ ref/typl-ad.i  }
{ ref/xobjgrp.i  }
&scop column-prioritet  'Прио!ритет'

/* Local Variable Definitions ---                                       */

define variable v-rec-list-cli as character no-undo .
define variable g-log  as logical   no-undo .
define variable v-name as character no-undo .
define variable v-a    as logical   no-undo .
define variable varlog as logical   no-undo .

define buffer ch_price-list-type for ub.price-list-type  .
define variable r-plt        as integer   no-undo init 2 .
define variable r-ban-discnt as integer   no-undo init 0.
define variable v-bg-color   as integer   no-undo .
define variable v-fg-color   as integer   no-undo .

function mark-string returns character
  ( buffer loc-table for ub.price-list-type, input mark-list as character  ) :
  return ( if lookup( string( recid( loc-table ) ), mark-list ) > 0 then "*" else "":U ).
end function.

function stts-string returns character
  ( buffer loc-table for ub.price-list-type   ) :
&scop status-code string(loc-table.stts)
return {&status-int-name} .
end function.

function activ-pr returns character
  ( buffer loc-table for ub.price-list-type  ) :
  define buffer b_price-all for ub.price-all  .
  find first b_price-all no-lock where
             b_price-all.plt-db-num = loc-table.plt-db-num and
             b_price-all.plt-id     = loc-table.plt-id and
             b_price-all.status_    = {&act-overvalue}
             no-error .
  if available b_price-all then return "+".
  else return "".
end function.


function name-pl returns character
  ( buffer loc-table for ub.price-list-type  ) :
  case loc-table.under-type-list :
      when ? then do:
        return ( loc-table.NAME ) .
      end.
      when 0 then do:
        return ( loc-table.name ) .
      end.
      when 1 then do:
        return (  "-> " + loc-table.name ) .
      end.
  end case.
end function.



define variable ref-rec as recid no-undo.

define variable loc_gop-id     as integer   no-undo .
define variable loc_tog-id     as integer   no-undo .
define variable loc_bgr-id     as integer   no-undo .
define variable loc_gop-db-num as integer   no-undo .
define variable loc_tog-db-num as integer   no-undo .
define variable loc_bgr-db-num as integer   no-undo .
define variable loc_plt-recid  as character no-undo .

define buffer buf_buyer-group    for ub.buyer-group  .
define buffer buf_turnover-group for ub.turnover-group  .
define buffer buf_grp-obj-price  for ub.grp-obj-price  .

define variable is-color as logical   no-undo .

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
&Scoped-define INTERNAL-TABLES buf_price-list-type

/* Definitions for BROWSE BROWSE-1grp                                   */
&Scoped-define FIELDS-IN-QUERY-BROWSE-1grp mark-string(buffer buf_price-list-type, p-rec-list) stts-string(buffer buf_price-list-type) buf_price-list-type.plt-id buf_price-list-type.main activ-pr(buffer buf_price-list-type) buf_price-list-type.priority buf_price-list-type.sys-date buf_price-list-type.sys-time-chr buf_price-list-type.db-num-chg buf_price-list-type.plt-db-num buf_price-list-type.plt-main-id buf_price-list-type.plt-main-db-num
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-1grp buf_price-list-type.plt-id
&Scoped-define ENABLED-TABLES-IN-QUERY-BROWSE-1grp buf_price-list-type
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-BROWSE-1grp buf_price-list-type
&Scoped-define SELF-NAME BROWSE-1grp
&Scoped-define QUERY-STRING-BROWSE-1grp FOR EACH buf_price-list-type WHERE     ( r-status = 2 OR buf_price-list-type.stts =  r-status ) AND     ( r-main = 2 OR buf_price-list-type.main =  logical(r-main) ) AND     ( r-avtop = 2 OR buf_price-list-type.only-gbd =  r-avtop ) AND     ( r-obj = 2 OR        ( buf_price-list-type.gop-id     = loc_gop-id AND          buf_price-list-type.gop-db-num = loc_gop-db-num )     ) AND     ( R-buyer = 2 OR    ( buf_price-list-type.bgr-id     = loc_bgr-id AND      buf_price-list-type.bgr-db-num = loc_bgr-db-num )     ) AND      ( R-tog = 2 OR    ( buf_price-list-type.tog-id     = loc_tog-id AND      buf_price-list-type.tog-db-num = loc_tog-db-num )     ) AND     ( R-plt = 2 OR       LOOKUP (string( RECID (buf_price-list-type)) , ~
       loc_plt-recid ) > 0 )         BY buf_price-list-type.plt-main-id DESC       BY buf_price-list-type.plt-main-db-num DESC       BY buf_price-list-type.under-type-list       BY buf_price-list-type.sys-date DESC       BY buf_price-list-type.sys-time DESC
&Scoped-define OPEN-QUERY-BROWSE-1grp OPEN QUERY {&SELF-NAME}     FOR EACH buf_price-list-type WHERE     ( r-status = 2 OR buf_price-list-type.stts =  r-status ) AND     ( r-main = 2 OR buf_price-list-type.main =  logical(r-main) ) AND     ( r-avtop = 2 OR buf_price-list-type.only-gbd =  r-avtop ) AND     ( r-obj = 2 OR        ( buf_price-list-type.gop-id     = loc_gop-id AND          buf_price-list-type.gop-db-num = loc_gop-db-num )     ) AND     ( R-buyer = 2 OR    ( buf_price-list-type.bgr-id     = loc_bgr-id AND      buf_price-list-type.bgr-db-num = loc_bgr-db-num )     ) AND      ( R-tog = 2 OR    ( buf_price-list-type.tog-id     = loc_tog-id AND      buf_price-list-type.tog-db-num = loc_tog-db-num )     ) AND     ( R-plt = 2 OR       LOOKUP (string( RECID (buf_price-list-type)) , ~
       loc_plt-recid ) > 0 )         BY buf_price-list-type.plt-main-id DESC       BY buf_price-list-type.plt-main-db-num DESC       BY buf_price-list-type.under-type-list       BY buf_price-list-type.sys-date DESC       BY buf_price-list-type.sys-time DESC.
&Scoped-define TABLES-IN-QUERY-BROWSE-1grp buf_price-list-type
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-1grp buf_price-list-type


/* Definitions for DIALOG-BOX Dialog-Frame                              */

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-Cancel B-mark B-sel B-add-M B-add B-lkp ~
B-chg B-del B-print B-history B-Help B-price-doc B-price-lists B-del-pr ~
B-color R-status R-obj R-buyer R-main R-avtop R-tog v-id BROWSE-1grp ~
FILL-IN-8 FILL-IN-2 FILL-IN-1 loc_gop_name FILL-IN-buy FILL-IN-7 ~
loc_bgr_name FILL-IN-tog loc_tog_name FILL-IN-6 v-user-name
&Scoped-Define DISPLAYED-OBJECTS R-status R-obj R-buyer R-main R-avtop ~
R-tog v-id FILL-IN-8 FILL-IN-2 FILL-IN-1 loc_gop_name FILL-IN-buy FILL-IN-7 ~
loc_bgr_name FILL-IN-tog loc_tog_name FILL-IN-6 v-user-name

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-add
     LABEL "Добавить"
     SIZE 10 BY 1 TOOLTIP "Добавить тип ПЛ"
     BGCOLOR 8 .

DEFINE BUTTON B-add-M
     IMAGE-UP FILE "cmp/add-gtpl.bmp":U
     LABEL "Добавить ГТПЛ"
     SIZE 20 BY 1 TOOLTIP "Добавить главный тип прайс-листа"
     BGCOLOR 4 FGCOLOR 15 .

DEFINE BUTTON B-Cancel AUTO-END-KEY
     LABEL "Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-chg
     LABEL "Изменить"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-color
     IMAGE-UP FILE "cmp/color.bmp":U
     IMAGE-DOWN FILE "cmp/color.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/color.bmp":U
     LABEL ""
     SIZE 3 BY 1 TOOLTIP "Цветовое выделение на экране".

DEFINE BUTTON B-del
     LABEL "Удалить"
     SIZE 10 BY 1 TOOLTIP "Удалить ТПЛ"
     BGCOLOR 8 .

DEFINE BUTTON B-del-pr
     LABEL "Удалить цены"
     SIZE 15 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-history
     LABEL "История"
     SIZE 3 BY 1 TOOLTIP "История изменения справочника"
     BGCOLOR 8 .

DEFINE BUTTON B-lkp
     LABEL "Просмотр"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-mark
     LABEL "*"
     SIZE 3.25 BY 1 TOOLTIP "Отметить ТПЛ"
     BGCOLOR 8 .

DEFINE BUTTON B-price-doc
     LABEL "ДНЦ"
     SIZE 13.5 BY 1 TOOLTIP "Документы назначения цены"
     BGCOLOR 8 .

DEFINE BUTTON B-price-lists
     LABEL "Переоценки"
     SIZE 15 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-print
     LABEL "Печать"
     SIZE 3 BY 1 TOOLTIP "Печать справочника"
     BGCOLOR 8 .

DEFINE BUTTON B-sel AUTO-GO
     LABEL "Выбор"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE FILL-IN-1 AS CHARACTER FORMAT "X(256)":U INITIAL "Статус:"
      VIEW-AS TEXT
     SIZE 7.5 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE FILL-IN-2 AS CHARACTER FORMAT "X(256)":U INITIAL "Объекты:"
      VIEW-AS TEXT
     SIZE 8.5 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE FILL-IN-6 AS CHARACTER FORMAT "X(256)":U INITIAL "Поиск Код ТПЛ:"
      VIEW-AS TEXT
     SIZE 14.5 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE FILL-IN-7 AS CHARACTER FORMAT "X(256)":U INITIAL "Тип:"
      VIEW-AS TEXT
     SIZE 4 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE FILL-IN-8 AS CHARACTER FORMAT "X(256)":U INITIAL "Распространение"
      VIEW-AS TEXT
     SIZE 16 BY .67
     FGCOLOR 1  NO-UNDO.

DEFINE VARIABLE FILL-IN-buy AS CHARACTER FORMAT "X(256)":U INITIAL "Покупатели:"
      VIEW-AS TEXT
     SIZE 11 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE FILL-IN-tog AS CHARACTER FORMAT "X(256)":U INITIAL "Обороты:"
      VIEW-AS TEXT
     SIZE 8.5 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE loc_bgr_name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 33 BY .67
     FGCOLOR 1 FONT 4 NO-UNDO.

DEFINE VARIABLE loc_gop_name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 28.5 BY .67
     FGCOLOR 1 FONT 4 NO-UNDO.

DEFINE VARIABLE loc_tog_name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 33 BY .67
     FGCOLOR 1 FONT 4 NO-UNDO.

DEFINE VARIABLE v-id AS INTEGER FORMAT ">>>>>>>>>9":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 14 BY 1 TOOLTIP "Поиск по коду типа прайс-листа" NO-UNDO.

DEFINE VARIABLE v-user-name AS CHARACTER FORMAT "X(256)":U
     LABEL "Опер"
      VIEW-AS TEXT
     SIZE 15 BY .67 TOOLTIP "Последний корректировал"
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE R-avtop AS INTEGER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Все", 2,
"Автопереоценки", 1,
"Ручные", 0
     SIZE 33 BY .67 NO-UNDO.

DEFINE VARIABLE R-buyer AS INTEGER INITIAL 2
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Все", 2,
"Группа", 1
     SIZE 16 BY .67 TOOLTIP "Выбор по группам покупателей" NO-UNDO.

DEFINE VARIABLE R-main AS INTEGER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Все", 2,
"Главный", 1,
"Неглавный", 0
     SIZE 29 BY .67 NO-UNDO.

DEFINE VARIABLE R-obj AS INTEGER INITIAL 2
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Все", 2,
"Тек", 3,
"Группа", 1
     SIZE 19.63 BY .67 TOOLTIP "Выбор по группам объектов" NO-UNDO.

DEFINE VARIABLE R-status AS INTEGER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Текущие", 0,
"Все", 2,
"Удаленные", 1
     SIZE 30.5 BY .67 TOOLTIP "Условие отбора записей" NO-UNDO.

DEFINE VARIABLE R-tog AS INTEGER INITIAL 2
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Все", 2,
"Группа", 1
     SIZE 16 BY .67 TOOLTIP "Выбор по группам оборотов покупателей" NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BROWSE-1grp FOR
             buf_price-list-type ,
             x_grp-obj-price
             SCROLLING.

&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BROWSE-1grp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-1grp Dialog-Frame _FREEFORM
  QUERY BROWSE-1grp NO-LOCK DISPLAY
      mark-string(buffer buf_price-list-type, p-rec-list) COLUMN-LABEL "*! " FORMAT "x(1)":U
      stts-string(buffer buf_price-list-type) COLUMN-LABEL "Ста!тус" FORMAT "x(3)":U
      buf_price-list-type.plt-id COLUMN-LABEL "Код! " FORMAT ">>>>>9":U
      buf_price-list-type.main COLUMN-LABEL "Г! "  FORMAT "+/ ":U
      logical(buf_price-list-type.only-gbd) @ v-a COLUMN-LABEL "А! " FORMAT "+/ ":U
      name-pl(buffer buf_price-list-type) @ v-name COLUMN-LABEL "Название типа прайс-листа! " FORMAT "X(100)":U
      WIDTH 36
      activ-pr(buffer buf_price-list-type) COLUMN-LABEL "Есть!цены"            FORMAT "x(4)":U
      buf_price-list-type.priority  COLUMN-LABEL {&column-prioritet}  FORMAT ">>9":U
      buf_price-list-type.sys-date     COLUMN-LABEL "Дата!изм"  FORMAT "99/99/99":U
      buf_price-list-type.sys-time-chr COLUMN-LABEL "Время!изм" FORMAT "X(5)":U
      buf_price-list-type.db-num-chg   COLUMN-LABEL "БД!изм"    FORMAT ">>>>9":U
      buf_price-list-type.plt-db-num FORMAT ">>>>9":U
      buf_price-list-type.plt-main-id  COLUMN-LABEL "Родитель!  " FORMAT ">>>>>9":U
      buf_price-list-type.plt-main-db-num COLUMN-LABEL "БД!РПЛ"    FORMAT ">>>>9":U
      buf_price-list-type.ban-discnt COLUMN-LABEL "Шаблон!скидки"  FORMAT ">>>>>9":U
  ENABLE
      buf_price-list-type.plt-id
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98.63 BY 16 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-Cancel AT ROW 1 COL 1
     B-mark AT ROW 1 COL 11
     B-sel AT ROW 1 COL 14.25
     B-add-M AT ROW 1 COL 24.25
     B-add AT ROW 1 COL 44.25
     B-lkp AT ROW 1 COL 54.25
     B-chg AT ROW 1 COL 64.25
     B-del AT ROW 1 COL 74.25
     B-print AT ROW 1 COL 91
     B-history AT ROW 1 COL 94
     B-Help AT ROW 1 COL 97
     B-price-doc AT ROW 2 COL 1
     B-price-lists AT ROW 2 COL 14.5
     B-del-pr AT ROW 2 COL 29.5
     B-color AT ROW 2 COL 97
     R-status AT ROW 3.17 COL 9.5 NO-LABEL
     R-obj AT ROW 3.17 COL 50.88 NO-LABEL
     R-buyer AT ROW 3.83 COL 50.88 NO-LABEL
     R-main AT ROW 3.88 COL 9.5 NO-LABEL
     R-avtop AT ROW 4.54 COL 5.5 NO-LABEL WIDGET-ID 6
     R-tog AT ROW 4.58 COL 50.88 NO-LABEL
     v-id AT ROW 5.21 COL 14.13 COLON-ALIGNED NO-LABEL
     BROWSE-1grp AT ROW 6.25 COL 1.5
     FILL-IN-8 AT ROW 2.46 COL 49 COLON-ALIGNED NO-LABEL WIDGET-ID 4
     FILL-IN-2 AT ROW 3.13 COL 42.13 NO-LABEL
     FILL-IN-1 AT ROW 3.17 COL 1.88 NO-LABEL
     loc_gop_name AT ROW 3.17 COL 69 COLON-ALIGNED NO-LABEL
     FILL-IN-buy AT ROW 3.79 COL 39.13 NO-LABEL
     FILL-IN-7 AT ROW 3.88 COL 4.88 NO-LABEL
     loc_bgr_name AT ROW 3.92 COL 64.5 COLON-ALIGNED NO-LABEL
     FILL-IN-tog AT ROW 4.54 COL 42 NO-LABEL
     loc_tog_name AT ROW 4.63 COL 64.5 COLON-ALIGNED NO-LABEL
     FILL-IN-6 AT ROW 5.13 COL 1.5 NO-LABEL
     v-user-name AT ROW 22.33 COL 5.75 COLON-ALIGNED WIDGET-ID 2
     SPACE(77.63) SKIP(0.13)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Справочник Типов прайс-листов"
         DEFAULT-BUTTON B-sel CANCEL-BUTTON B-Cancel.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   External Tables: Temp-Tables.buf_price-list-type
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: buf_price-list-type B "NEW SHARED" ? ub price-list-type
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BROWSE-1grp v-id Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN FILL-IN-1 IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN FILL-IN-2 IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN FILL-IN-6 IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN FILL-IN-7 IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN FILL-IN-buy IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN FILL-IN-tog IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-1grp
/* Query rebuild information for BROWSE BROWSE-1grp
     _START_FREEFORM
OPEN QUERY {&SELF-NAME}
    FOR EACH buf_price-list-type WHERE
    ( r-status = 2 OR buf_price-list-type.stts =  r-status ) AND
    ( r-main = 2 OR buf_price-list-type.main =  logical(r-main) ) AND
    ( r-avtop = 2 OR buf_price-list-type.only-gbd =  r-avtop ) AND
    ( r-obj = 2 OR
       ( buf_price-list-type.gop-id     = loc_gop-id AND
         buf_price-list-type.gop-db-num = loc_gop-db-num )
    ) AND
    ( R-buyer = 2 OR
   ( buf_price-list-type.bgr-id     = loc_bgr-id AND
     buf_price-list-type.bgr-db-num = loc_bgr-db-num )
    ) AND

    ( R-tog = 2 OR
   ( buf_price-list-type.tog-id     = loc_tog-id AND
     buf_price-list-type.tog-db-num = loc_tog-db-num )
    ) AND
    ( R-plt = 2 OR
      LOOKUP (string( RECID (buf_price-list-type)) , loc_plt-recid ) > 0 )


      BY buf_price-list-type.plt-main-id DESC
      BY buf_price-list-type.plt-main-db-num DESC
      BY buf_price-list-type.under-type-list
      BY buf_price-list-type.sys-date DESC
      BY buf_price-list-type.sys-time DESC.
     _END_FREEFORM
     _START_FREEFORM_DEFINE
DEFINE QUERY BROWSE-1grp FOR
             buf_price-list-type ,
             x_grp-obj-price
             SCROLLING.
     _END_FREEFORM_DEFINE
     _Options          = "NO-LOCK"
     _Query            is NOT OPENED
*/  /* BROWSE BROWSE-1grp */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _Options          = "SHARE-LOCK"
     _Query            is NOT OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Справочник Типов прайс-листов */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-add Dialog-Frame
ON CHOOSE OF B-add IN FRAME Dialog-Frame /* Добавить */
DO:
  define variable v-rec-id as recid no-undo .
  run ref/tp-price.w ( input parparentproc , false ,  input {&add-def} , input-output v-rec-id ) .
  run openbr .
  reposition BROWSE-1grp to recid v-rec-id no-error .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-add-M
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-add-M Dialog-Frame
ON CHOOSE OF B-add-M IN FRAME Dialog-Frame /* Добавить ГТПЛ */
DO:

  define variable v-rec-id as recid no-undo .
  run ref/tp-price.w ( input parparentproc, input TRUE ,  input {&add-def} , input-output v-rec-id ) .
  run openbr .
  reposition BROWSE-1grp to recid v-rec-id no-error .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-Cancel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-Cancel Dialog-Frame
ON CHOOSE OF B-Cancel IN FRAME Dialog-Frame /* Выход */
DO:





  run uf-set in this-procedure(
   input {&uf-color}
  ,input v-cntxt-userid
  ,input string(is-color)
  ,input v-uf-Naim
  ,input v-uf-print-graft
  ,input v-uf-sort-gr
  ,input v-uf-type-price
  ,input v-uf-type-val
  ) no-error    .
  if error-status :error then .
  run uf-set in this-procedure(
   input {&uf-tpl-mode}
  ,input v-cntxt-userid
  ,input string(r-main) + {&delim-par} + string(r-obj) + {&delim-par} + string(r-avtop) + {&delim-par}
  ,input v-uf-Naim
  ,input v-uf-print-graft
  ,input v-uf-sort-gr
  ,input v-uf-type-price
  ,input v-uf-type-val
  ) no-error    .
  if error-status :error then .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-chg Dialog-Frame
ON CHOOSE OF B-chg IN FRAME Dialog-Frame /* Изменить */
DO:
  if not available buf_price-list-type then return .
  if buf_price-list-type.stts <> integer({&pdf-new}) then do:
     message "Статус УДАЛЕН - изменять нельзя " view-as alert-box information .
     return .
  end.

  if buf_price-list-type.plt-db-num <>  v-cntxt-db-num then do:
     message "Нельзя изменять прайс-лист чужой БД!" view-as alert-box information .
     return .
  end.

  define variable v-rec-id as recid no-undo .
  v-rec-id = recid(buf_price-list-type) .
  run ref/tp-price.w (input parparentproc, buf_price-list-type.main , input {&update} , input-output v-rec-id) .
  run openbr .
  reposition BROWSE-1grp to recid v-rec-id no-error .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-color
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-color Dialog-Frame
ON CHOOSE OF B-color IN FRAME Dialog-Frame
DO:
  if B-color:IMAGE  = "cmp/nocol.bmp" then
  do:
    B-color:LOAD-IMAGE-UP("cmp/color.bmp") in frame {&frame-name}  . /* покрасим */
    is-color = true .

    run openbr .
  end.
  else do:
     B-color:LOAD-IMAGE-UP("cmp/nocol.bmp") in frame {&frame-name}  . /* снимим цвет */
     is-color = false  .

     run openbr .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-del Dialog-Frame
ON CHOOSE OF B-del IN FRAME Dialog-Frame /* Удалить */
DO:

if not available buf_price-list-type then return .
define variable g#log as logical   no-undo .

   if buf_price-list-type.main then do:
      { gbl/chk-actg.i
        v-cntxt-db-num
        v-cntxt-userid
        {&action-head-code-main}
        'actn_global-tpl-mpl_delete':U
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
        'actn_tpl-mpl_delete':U
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

  /*
  if buf_price-list-type.main and activ-pr(buffer buf_price-list-type)  = "+" then do:
     message "Удалять главный тип прайс-листов нельзя . Уже есть цены !!! " view-as alert-box error .
     return .
  end.
  */
  if buf_price-list-type.stts <> integer({&pdf-new}) then do:
     message "Уже удален!" view-as alert-box information .
     /* find current buf_price-list-type exclusive-lock. */
     /* buf_price-list-type.stts  = integer({&pdf-new}).  */
     return .
  end.

  if buf_price-list-type.plt-db-num <>  v-cntxt-db-num then do:
     message "Нельзя удалять прайс-лист чужой БД!" view-as alert-box information .
     return .
  end.

  message "Удалять тип прайс-листов: " buf_price-list-type.name "?"
          view-as alert-box question
          buttons yes-no update g-ok as log.
  if not g-ok then return .

run type-price-list-DELETE (
      buf_price-list-type.plt-db-num ,
      buf_price-list-type.plt-id     ,
      v-cntxt-db-num                 ,
      v-cntxt-userid                 )
      no-error .
 if error-status :error then return no-apply .
 run openbr .


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-del-pr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-del-pr Dialog-Frame
ON CHOOSE OF B-del-pr IN FRAME Dialog-Frame /* Удалить цены */
DO:
   define variable g#log as logical   no-undo .
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_mpl-price_delete':U
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

  if not available buf_price-list-type then return .
  if buf_price-list-type.main then do:
     message "Удалять цены по главному типу прайс-листов нельзя !" view-as alert-box error .
     return .
  end.
  if buf_price-list-type.plt-db-num <>  v-cntxt-db-num then do:
     message "Нельзя удалять прайс-лист чужой БД!" view-as alert-box information .
     return .
  end.
  message "Удалять цены по типу прайс-листов: " buf_price-list-type.name "?"
          view-as alert-box question
          buttons yes-no update g-ok as log.
  if not g-ok then return .
  run ref/del-pdf.p ( parparentproc , buf_price-list-type.plt-id, buf_price-list-type.plt-db-num ) .
  g-log = browse-1grp:refresh() .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-history
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-history Dialog-Frame
ON CHOOSE OF B-history IN FRAME Dialog-Frame /* История */
DO:
  if not available buf_price-list-type then return .
  run ref/c-tp-pl.w (
      parParentProc ,
      buf_price-list-type.plt-id ,
      buf_price-list-type.plt-db-num ) .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-lkp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-lkp Dialog-Frame
ON CHOOSE OF B-lkp IN FRAME Dialog-Frame /* Просмотр */
DO:
  if not available buf_price-list-type then return .

  define variable v-rec-id as recid no-undo .
  v-rec-id = recid(buf_price-list-type) .
  run ref/tp-price.w (input parparentproc ,buf_price-list-type.main , input {&LOOKUP} , input-output v-rec-id) .

  run openbr .
  reposition BROWSE-1grp to recid v-rec-id no-error .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mark Dialog-Frame
ON CHOOSE OF B-mark IN FRAME Dialog-Frame /* * */
DO:

    if available buf_price-list-type then do:
      { gbl/markstrn.i buf_price-list-type p-rec-list }
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
ON CHOOSE OF B-price-doc IN FRAME Dialog-Frame /* ДНЦ */
DO:
  if not available buf_price-list-type then return .
  define variable v-rec-list as character no-undo .
  run str/docsprls.w ( parparentproc , "pl-type" , buf_price-list-type.plt-id  , buf_price-list-type.plt-db-num  , "b-del" , input-output v-rec-list) .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-price-lists
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-price-lists Dialog-Frame
ON CHOOSE OF B-price-lists IN FRAME Dialog-Frame /* Переоценки */
DO:
  define variable loc-ref-list as character no-undo .
  define variable p-list-mode as character no-undo .
  p-list-mode = "typepricelist":U .
  if not available buf_price-list-type then return .

  run str/pr-docs.w
    (input parparentproc
    ,input "":U
    ,input p-list-mode
    ,input ""
    ,input v-cntxt-obj-type
    ,input v-cntxt-obj-code
    ,input string(recid(buf_price-list-type))
    ,output loc-ref-list
    ) .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-print Dialog-Frame
ON CHOOSE OF B-print IN FRAME Dialog-Frame /* Печать */
DO:
  /* */
    MESSAGE "Не реализовано".
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-sel Dialog-Frame
ON CHOOSE OF B-sel IN FRAME Dialog-Frame /* Выбор */
DO:

   if ( available buf_price-list-type ) AND ( p-rec-list = "" ) THEN p-rec-list = string( recid( buf_price-list-type ) ) .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BROWSE-1grp
&Scoped-define SELF-NAME BROWSE-1grp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BROWSE-1grp Dialog-Frame
ON MOUSE-SELECT-DBLCLICK OF BROWSE-1grp IN FRAME Dialog-Frame
DO:
  if b-sel:SENSITIVE then apply  "CHOOSE":U to b-sel.
     else apply  "CHOOSE":U to b-lkp.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BROWSE-1grp Dialog-Frame
ON ROW-DISPLAY OF BROWSE-1grp IN FRAME Dialog-Frame
DO:
  if LOOKUP ("mode=twotpl":U,    p-bttns) > 0 then do:
    if mark-string(buffer buf_price-list-type, p-rec-list) = '*' then do:
       buf_price-list-type.priority  :bgcolor in browse {&BROWSE-name}   = RED_COLOR .
    end.
  end.

  if is-color = false then return .
  if buf_price-list-type.ban-discnt > 0 then do:
     v-fg-color = 5  .
  end.
  else do:
     v-fg-color = ?  .
  end.

  if buf_price-list-type.under-type-list = 1 then do:
     run recolor in this-procedure (GRAY_COLOR , v-fg-color ) .
  end.
  else do:
     if can-find (first ch_price-list-type no-lock where
                        ch_price-list-type.under-type-list = 1 and
                        ch_price-list-type.stts            = integer({&pdf-new}) and
                        ch_price-list-type.plt-main-id     = buf_price-list-type.plt-id and
                        ch_price-list-type.plt-main-db-num = buf_price-list-type.plt-db-num )
        then do:
          run recolor in this-procedure (DARK_GRAY_COLOR, v-fg-color ) .
        end.
        else do:
          v-bg-color = ? .
          if buf_price-list-type.qgr-id > 0 then do:
             v-bg-color = 11 .
          end.
          if buf_price-list-type.sgr-id > 0 then do:
             v-bg-color = 10 .
          end.
          if buf_price-list-type.have-tog-id > 0 then do:
             v-bg-color = 14 .
          end.
          run recolor in this-procedure (v-bg-color , v-fg-color ) .
        end.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BROWSE-1grp Dialog-Frame
ON START-SEARCH OF BROWSE-1grp IN FRAME Dialog-Frame
DO:
   run sort-proc in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BROWSE-1grp Dialog-Frame
ON VALUE-CHANGED OF BROWSE-1grp IN FRAME Dialog-Frame
DO:
  if available buf_price-list-type then do:
  { gbl/usrfulnm.i
    buf_price-list-type.who
    v-user-name }
   DISPLAY v-user-name WITH FRAME {&FRAME-NAME}.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME R-avtop
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL R-avtop Dialog-Frame
ON VALUE-CHANGED OF R-avtop IN FRAME Dialog-Frame
DO:
    ASSIGN R-avtop .
       run openbr .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME R-buyer
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL R-buyer Dialog-Frame
ON VALUE-CHANGED OF R-buyer IN FRAME Dialog-Frame
DO:
define variable vref-rec as character no-undo .

assign
  loc_bgr_name      = ""
  loc_bgr-db-num    = 0
  loc_bgr-id        = 0
.

   assign r-buyer .
   if r-buyer = 1 then do:
        run ref/gr-bupr.w ( input  parparentproc ,"b-sel" , input-output vref-rec ) .
        if vref-rec = ? or vref-rec = '' then do:
           r-buyer = 2.
           display r-buyer with frame {&frame-name}.
           return no-apply.
        end.
        find ub.buyer-group where recid ( ub.buyer-group ) = int(vref-rec) no-lock .
        if available ub.buyer-group then do:
            assign
              loc_bgr_name      = ub.buyer-group.name
              loc_bgr-db-num    = ub.buyer-group.bgr-db-num
              loc_bgr-id        = ub.buyer-group.bgr-id
            .
        end.
   end.

  display loc_bgr_name with frame {&frame-name}.
  run openbr .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME R-main
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL R-main Dialog-Frame
ON VALUE-CHANGED OF R-main IN FRAME Dialog-Frame
DO:
    ASSIGN R-main .
       run openbr .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME R-obj
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL R-obj Dialog-Frame
ON VALUE-CHANGED OF R-obj IN FRAME Dialog-Frame
DO:
define variable v-spis as character no-undo .

assign
  loc_gop_name      = ""
  loc_gop-db-num    = 0
  loc_gop-id        = 0
.

   assign r-obj .

   if r-obj = 2 or r-obj = 1 then do:
    { gbl/chk-actg.i
      v-cntxt-db-num
      v-cntxt-userid
      {&action-head-code-main}
      'actn_documents_all':U
      {&cntxt-object}
      0
      '':U
      0
      0
      0
      0
      true
      varlog
    }
    if varlog = false then r-obj = 3.
    display r-obj loc_gop_name with frame {&frame-name}.
   end.

   if r-obj = 1 then do:
        run ref/gr-objpr.w ( input  parparentproc , input "b-sel" , input-output v-spis ) .
        if v-spis = ? or v-spis = '' then do:
            r-obj = 2.
            loc_gop_name = '' .
            display r-obj loc_gop_name with frame {&frame-name}.
            run openbr .
            return no-apply.
        end.
        else do:
          find ub.grp-obj-price where recid ( ub.grp-obj-price ) = int(v-spis) no-lock no-error.
          if available ub.grp-obj-price then do:
              assign
                loc_gop_name      = ub.grp-obj-price.name
                loc_gop-db-num    = ub.grp-obj-price.gop-db-num
                loc_gop-id        = ub.grp-obj-price.gop-id
              .
          end.
        end.
   end.

   if r-obj = 3 then do:
        if ( v-cntxt-obj-type = ? or v-cntxt-obj-type = "" ) and varlog = true then do:
           r-obj = 2.
           loc_gop_name = '' .
           display r-obj loc_gop_name with frame {&frame-name}.
           run openbr .
           return no-apply.
        end.


        find first x_grp-obj-price no-error  .
        if available x_grp-obj-price then do:
            assign
              loc_gop_name      = x_grp-obj-price.name
              loc_gop-db-num    = x_grp-obj-price.gop-db-num
              loc_gop-id        = x_grp-obj-price.gop-id
            .
        end.
        define buffer buf_clients for ub.clients  .
        find first buf_clients no-lock where
                    buf_clients.obj-type   = v-cntxt-obj-type and
                    buf_clients.obj-code   = v-cntxt-obj-code no-error .
        loc_gop_name  = buf_clients.obj-name  .
   end.

   display loc_gop_name with frame {&frame-name}.
   run openbr .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME R-status
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL R-status Dialog-Frame
ON VALUE-CHANGED OF R-status IN FRAME Dialog-Frame
DO:
   ASSIGN R-status .
  run openbr .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME R-tog
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL R-tog Dialog-Frame
ON VALUE-CHANGED OF R-tog IN FRAME Dialog-Frame
DO:
define variable v-ref-rec as recid no-undo .
define variable s-ref-rec as character no-undo .
assign
  loc_tog_name      = ""
  loc_tog-db-num    = 0
  loc_tog-id        = 0
.

   assign r-tog .
   if r-tog = 1 then do:
        run ref/gr-obupr.w ( input  parparentproc ,"b-sel" , input-output s-ref-rec ) .
        v-ref-rec = int(s-ref-rec) .
        if v-ref-rec = ? or v-ref-rec = 0 then do:
           r-tog = 2.
           display r-tog with frame {&frame-name}.
           return no-apply.
        end.
        find ub.turnover-group where recid ( ub.turnover-group ) = v-ref-rec no-lock .
        if available ub.turnover-group then do:
            assign
              loc_tog_name      = ub.turnover-group.name
              loc_tog-db-num    = ub.turnover-group.tog-db-num
              loc_tog-id        = ub.turnover-group.tog-id
            .
        end.
   end.

  display loc_tog_name with frame {&frame-name}.
  run openbr .


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME v-id
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-id Dialog-Frame
ON CTRL-J OF v-id IN FRAME Dialog-Frame
DO:
 run proc-code in this-procedure ( YES , input frame {&frame-name} v-id ) no-error.
 if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-id Dialog-Frame
ON RETURN OF v-id IN FRAME Dialog-Frame
DO:
  run proc-code in this-procedure ( no, input frame {&frame-name} v-id ) no-error.
  return no-apply.

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
/* { gbl/brwrefre.i  run openbr . } */
/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  v-name:resizable in browse {&browse-name}   = true .
  buf_price-list-type.plt-id:read-only in browse {&browse-name}   = true .
  run init-proc in this-procedure .
  r-ban-discnt = 0 .
  if LOOKUP ("mode=ban-discnt":U,    p-bttns) > 0 then do:
     r-ban-discnt = integer(p-rec-list) no-error .
     p-rec-list = "".
  end.
  if LOOKUP ("mode=gop-id":U,    p-bttns) > 0 then do:
    find buf_grp-obj-price no-lock where recid (buf_grp-obj-price) = integer (p-rec-list) no-error .

    if available buf_grp-obj-price then do:
      assign
        p-rec-list     = ""
        r-obj          = 1
        loc_gop_name   = buf_grp-obj-price.name
        loc_gop-db-num = buf_grp-obj-price.gop-db-num
        loc_gop-id     = buf_grp-obj-price.gop-id
      .
    end.
    else return error "Ошибка поиска по группе объектов" .
  end.
  if LOOKUP ("mode=bgr-id":U,    p-bttns) > 0 then do:
    find buf_buyer-group no-lock where recid (buf_buyer-group) = integer (p-rec-list) no-error .
    if available buf_buyer-group then do:
      assign
        p-rec-list     = ""
        r-buyer        = 1
        loc_bgr_name   = buf_buyer-group.name
        loc_bgr-db-num = buf_buyer-group.bgr-db-num
        loc_bgr-id     = buf_buyer-group.bgr-id
      .
    end.
    else return error "Ошибка поиска по группе покупателей" .
  end.
  if LOOKUP ("mode=tog-id":U,    p-bttns) > 0 then do:
    find buf_turnover-group no-lock where recid (buf_turnover-group) = integer (p-rec-list) no-error .
    if available buf_turnover-group then do:
      assign
        p-rec-list     = ""
        r-tog          = 1
        loc_tog_name   = buf_turnover-group.name
        loc_tog-db-num = buf_turnover-group.tog-db-num
        loc_tog-id     = buf_turnover-group.tog-id
      .
    end.
    else return error "Ошибка поиска по группе оборотов покупателей" .
  end.
  if LOOKUP ("mode=plt-id":U,    p-bttns) > 0 then do:
    r-plt = 1 .
    loc_plt-recid      = p-rec-list  .
    p-rec-list = ""  .
  end.
  if index (p-bttns , "title=":U ) > 0 then do:
    define variable v-end-pos as integer   no-undo .
    define variable v-start-pos as integer   no-undo .
    define variable v-str-1 as character no-undo .
    v-start-pos = index ( p-bttns ,"title=":U) + 6 .
    v-end-pos = index ( p-bttns,"endtitle":U).
    v-str-1 = SUBSTRING ( p-bttns, v-start-pos , v-end-pos -  v-start-pos) .
    frame {&frame-name}:TITLE = v-str-1 .
  end.
  if LOOKUP ("mode=twotpl":U,    p-bttns) > 0 then do:
    r-plt = 1 .
    loc_plt-recid      = p-rec-list  .
  end.
  if LOOKUP ("mode=all":U,    p-bttns) > 0 then do:
    assign
      r-status   = 0
      r-main     = 2
      r-avtop    = 2
      r-obj      = 2
      p-rec-list = ""
    .
  end.

  RUN enable_UI.


  disable
  B-price-doc   when LOOKUP ("b-sel":U,    p-bttns) > 0
  B-price-lists when LOOKUP ("b-sel":U,    p-bttns) > 0
  B-sel         when LOOKUP ("b-sel":U,    p-bttns) = 0
  B-add         when LOOKUP ("b-add":U,    p-bttns) = 0
  B-add-m       when LOOKUP ("b-add":U,    p-bttns) = 0
  B-chg         when LOOKUP ("b-chg":U,    p-bttns) = 0
  B-del         when LOOKUP ("b-del":U,    p-bttns) = 0
  B-del-pr      when LOOKUP ("b-del":U,    p-bttns) = 0
  B-mark        when LOOKUP ("b-mark":U,   p-bttns) = 0
  with frame {&frame-name} .

  define variable v-main-tpl              as logical   no-undo .
  define variable v-use-grp-buy           as logical   no-undo .
  define variable v-use-oborot-buy        as logical   no-undo .
  define variable v-use-qnty-group        as logical   no-undo .
  define variable v-use-sum-group         as logical   no-undo .
  define variable v-use-add-code          as logical   no-undo .
  define variable v-use-sys-date-time     as logical   no-undo .
  define variable v-use-shift-date-num    as logical   no-undo .
  define variable v-use-cassa             as logical   no-undo .
  define variable v-use-val               as logical   no-undo .
  define variable v-use-pay-type          as logical   no-undo .
  define variable v-use-cash-pay          as logical   no-undo .
  define variable v-use-child             as logical   no-undo .
  { gbl/glstmain.i v-main-tpl }
  { gbl/glstall.i
    v-use-grp-buy
    v-use-oborot-buy
    v-use-qnty-group
    v-use-sum-group
    v-use-add-code
    v-use-sys-date-time
    v-use-shift-date-num
    v-use-cassa
    v-use-val
    v-use-pay-type
    v-use-cash-pay
    v-use-child
    }

  if v-use-child = false then do:
    assign
      buf_price-list-type.plt-main-id:visible in browse {&browse-name} = false .
      buf_price-list-type.plt-main-db-num:visible in browse {&browse-name} = false .
    .
  end.
  if v-main-tpl then hide  FILL-IN-buy FILL-IN-tog  B-add R-buyer R-tog B-del-pr in frame {&frame-name} .
  if v-use-grp-buy     = false then hide FILL-IN-buy R-buyer in frame {&frame-name} .
  if v-use-oborot-buy  = false then hide FILL-IN-tog R-tog   in frame {&frame-name} .

  run openbr in this-procedure .
  WAIT-FOR GO OF FRAME {&FRAME-NAME} FOCUS BROWSE-1grp.
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
  DISPLAY R-status R-obj R-buyer R-main R-avtop R-tog v-id FILL-IN-8 FILL-IN-2
          FILL-IN-1 loc_gop_name FILL-IN-buy FILL-IN-7 loc_bgr_name FILL-IN-tog
          loc_tog_name FILL-IN-6 v-user-name
      WITH FRAME Dialog-Frame.
  ENABLE B-Cancel B-mark B-sel B-add-M B-add B-lkp B-chg B-del B-print
         B-history B-Help B-price-doc B-price-lists B-del-pr B-color R-status
         R-obj R-buyer R-main R-avtop R-tog v-id BROWSE-1grp FILL-IN-8
         FILL-IN-2 FILL-IN-1 loc_gop_name FILL-IN-buy FILL-IN-7 loc_bgr_name
         FILL-IN-tog loc_tog_name FILL-IN-6 v-user-name
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-proc Dialog-Frame
PROCEDURE init-proc :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
run uf-get in this-procedure(
     input  {&uf-color}
    ,input  v-cntxt-userid
    ,output v-uf-List_
    ,output v-uf-Naim
    ,output v-uf-print-graft
    ,output v-uf-sort-gr
    ,output v-uf-type-price
    ,output v-uf-type-val
)  no-error.
if v-uf-List_ = "yes"  then is-color = true .
if is-color = true  then B-color:LOAD-IMAGE-UP("cmp/color.bmp") in frame {&frame-name}  .
if is-color = false then B-color:LOAD-IMAGE-UP("cmp/nocol.bmp") in frame {&frame-name}  .
run uf-get in this-procedure(
     input  {&uf-tpl-mode}
    ,input  v-cntxt-userid
    ,output v-uf-List_
    ,output v-uf-Naim
    ,output v-uf-print-graft
    ,output v-uf-sort-gr
    ,output v-uf-type-price
    ,output v-uf-type-val
    ) no-error.
if error-status :error then
assign
  r-main   = 2
  r-obj    = 3
  r-avtop  = 2
.
else  do:
  r-main   = int (entry (1,v-uf-List_,{&delim-par})) no-error . if r-main   = ? then  r-main   = 2 .
  r-obj    = int (entry (2,v-uf-List_,{&delim-par})) no-error . if r-obj    = ? then  r-obj    = 3 .
  r-avtop  = int (entry (3,v-uf-List_,{&delim-par})) no-error . if r-avtop  = ? then  r-avtop  = 2 .
end.
{ gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_documents_all':U
  {&cntxt-object}
  0
  '':U
  0
  0
  0
  0
  false
  varlog
}
if (r-obj = 2 or r-obj = 1) and varlog = false then r-obj = 3.

/* найти группЫ текущего объекта */
run metod-obj-in-gop (
    v-cntxt-db-num ,
    v-cntxt-obj-type ,
    v-cntxt-obj-code ) .
run openbr in this-procedure .
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
   run sort-proc in this-procedure .
   apply "VALUE-CHANGED" to BROWSE-1grp IN FRAME {&frame-name} .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-code Dialog-Frame
PROCEDURE proc-code :
define input parameter par-next as logical no-undo.
define input parameter pardoc-code as INTEGER no-undo.
DEFINE VARIABLE doc-rec AS RECID NO-UNDO.

  doc-rec = ? .
  find first  buf_price-list-type no-lock where  buf_price-list-type.plt-id = pardoc-code no-error  .
  if available buf_price-list-type then
    doc-rec = recid(buf_price-list-type) .

  reposition {&browse-name} to recid doc-rec no-error .
  if not error-status :error then apply "VALUE-CHANGED" to {&browse-name} in frame {&frame-name}.
  else do:
      message " Запись не найдена " view-as alert-box information .
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE recolor Dialog-Frame
PROCEDURE recolor :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
define input  parameter p-color_bg as integer   no-undo .
define input  parameter p-color_fg as integer   no-undo .
  assign
    buf_price-list-type.plt-id:bgcolor in browse {&BROWSE-name} = p-color_bg
    buf_price-list-type.main:bgcolor in browse {&BROWSE-name} = p-color_bg
    v-name:bgcolor in browse {&BROWSE-name} = p-color_bg
    v-a:bgcolor in browse {&BROWSE-name} = p-color_bg
  .
  assign
    buf_price-list-type.plt-id:fgcolor in browse {&BROWSE-name} = p-color_fg
    buf_price-list-type.main:fgcolor in browse {&BROWSE-name} = p-color_fg
    v-name:fgcolor in browse {&BROWSE-name} = p-color_fg
    v-a:fgcolor in browse {&BROWSE-name} = p-color_fg
  .



END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE sort-proc Dialog-Frame
PROCEDURE sort-proc :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
define variable column-handle as handle no-undo .
define variable v-type-sort as character no-undo .
column-handle = {&browse-name}:CURRENT-COLUMN  in frame {&frame-name} no-error .

if not error-status :error  and valid-handle(column-handle) then do:
    if column-handle:label = {&column-prioritet} then do:
      case column-handle:column-fgcolor:
        when 0 or when ? then
        assign
          column-handle:column-fgcolor = 4
          v-type-sort = "+"
        .
        when 4  then
        assign
          column-handle:column-fgcolor = 5
          v-type-sort = "-"
        .
        when 5  then
        assign
          column-handle:column-fgcolor = 0
          v-type-sort = "def"
        .
      end case.
    end.
end.
else do:
assign
  buf_price-list-type.priority:COLUMN-fgcolor in browse {&browse-name}   = 0
  v-type-sort = "def"
.
end.

if R-obj = 3 then do:  /* По текущему объекту */
    case v-type-sort :
    when "+" then do:
    OPEN QUERY {&browse-name}
      FOR EACH buf_price-list-type WHERE
      ( r-ban-discnt = 0 OR buf_price-list-type.ban-discnt = r-ban-discnt ) AND
      ( r-status = 2 OR buf_price-list-type.stts =  r-status ) AND
      ( r-main  = 2 OR buf_price-list-type.main =  logical(r-main) ) AND
      ( r-avtop = 2 OR buf_price-list-type.only-gbd =  r-avtop ) AND
      ( R-buyer = 2 OR ( buf_price-list-type.bgr-id     = loc_bgr-id AND
                         buf_price-list-type.bgr-db-num = loc_bgr-db-num )     ) AND
      ( R-tog = 2 OR   ( buf_price-list-type.tog-id     = loc_tog-id AND
                         buf_price-list-type.tog-db-num = loc_tog-db-num )     ) AND
      ( R-plt = 2 OR  LOOKUP (string( RECID (buf_price-list-type)) , loc_plt-recid ) > 0 )
      , each x_grp-obj-price where
             x_grp-obj-price.gop-id        = buf_price-list-type.gop-id     and
             x_grp-obj-price.gop-db-num    = buf_price-list-type.gop-db-num

          BY buf_price-list-type.priority
          BY buf_price-list-type.plt-main-id DESC
          BY buf_price-list-type.plt-main-db-num DESC
          BY buf_price-list-type.under-type-list
          BY buf_price-list-type.sys-date DESC
          BY buf_price-list-type.sys-time DESC .
    end.
    when "-" then do:
    OPEN QUERY {&browse-name}
      FOR EACH buf_price-list-type WHERE
      ( r-ban-discnt = 0 OR buf_price-list-type.ban-discnt = r-ban-discnt ) AND
      ( r-status = 2 OR buf_price-list-type.stts =  r-status ) AND
      ( r-main = 2 OR buf_price-list-type.main =  logical(r-main) ) AND
      ( r-avtop = 2 OR buf_price-list-type.only-gbd = r-avtop ) AND
      ( R-buyer = 2 OR    ( buf_price-list-type.bgr-id     = loc_bgr-id AND
                            buf_price-list-type.bgr-db-num = loc_bgr-db-num )     ) AND
      ( R-tog = 2 OR    ( buf_price-list-type.tog-id     = loc_tog-id AND
                          buf_price-list-type.tog-db-num = loc_tog-db-num )     ) AND
      ( R-plt = 2 OR       LOOKUP (string( RECID (buf_price-list-type)) , loc_plt-recid ) > 0 )
      , each x_grp-obj-price where
             x_grp-obj-price.gop-id        = buf_price-list-type.gop-id     and
             x_grp-obj-price.gop-db-num    = buf_price-list-type.gop-db-num

          BY buf_price-list-type.priority DESC
          BY buf_price-list-type.plt-main-id DESC
          BY buf_price-list-type.plt-main-db-num DESC
          BY buf_price-list-type.under-type-list
          BY buf_price-list-type.sys-date DESC
          BY buf_price-list-type.sys-time DESC .
    end.

    when "def" then do:
    buf_price-list-type.priority:COLUMN-fgcolor in browse {&browse-name}   = 0.
    OPEN QUERY {&browse-name}
      FOR EACH buf_price-list-type WHERE
      ( r-ban-discnt = 0 OR buf_price-list-type.ban-discnt = r-ban-discnt ) AND
      ( r-status = 2 OR buf_price-list-type.stts      =  r-status ) AND
      ( r-main = 2 OR  buf_price-list-type.main       =  logical(r-main) ) AND
      ( r-avtop = 2 OR buf_price-list-type.only-gbd =  r-avtop ) AND
      ( R-buyer = 2 OR ( buf_price-list-type.bgr-id   = loc_bgr-id AND
                      buf_price-list-type.bgr-db-num = loc_bgr-db-num )     ) AND
      ( R-tog = 2 OR   ( buf_price-list-type.tog-id   = loc_tog-id AND
                      buf_price-list-type.tog-db-num = loc_tog-db-num )     ) AND
      ( R-plt = 2 OR   LOOKUP (string( RECID (buf_price-list-type)) , loc_plt-recid ) > 0 )
      , each x_grp-obj-price where
             x_grp-obj-price.gop-id        = buf_price-list-type.gop-id     and
             x_grp-obj-price.gop-db-num    = buf_price-list-type.gop-db-num

          BY buf_price-list-type.plt-main-id DESC
          BY buf_price-list-type.plt-main-db-num DESC
          BY buf_price-list-type.under-type-list
          BY buf_price-list-type.sys-date DESC
          BY buf_price-list-type.sys-time DESC .
    end.
    end case .

end.
else do:
case v-type-sort :
when "+" then do:
OPEN QUERY {&browse-name}
  FOR EACH buf_price-list-type WHERE
  ( r-ban-discnt = 0 OR buf_price-list-type.ban-discnt = r-ban-discnt ) AND
  ( r-status = 2 OR buf_price-list-type.stts =  r-status ) AND
  ( r-main  = 2 OR buf_price-list-type.main =  logical(r-main) ) AND
  ( r-avtop = 2 OR buf_price-list-type.only-gbd =  r-avtop ) AND
  ( r-obj   = 2 OR ( buf_price-list-type.gop-id     = loc_gop-id AND
                     buf_price-list-type.gop-db-num = loc_gop-db-num )     ) AND
  ( R-buyer = 2 OR ( buf_price-list-type.bgr-id     = loc_bgr-id AND
                     buf_price-list-type.bgr-db-num = loc_bgr-db-num )     ) AND
  ( R-tog = 2 OR   ( buf_price-list-type.tog-id     = loc_tog-id AND
                     buf_price-list-type.tog-db-num = loc_tog-db-num )     ) AND
  ( R-plt = 2 OR  LOOKUP (string( RECID (buf_price-list-type)) , loc_plt-recid ) > 0 )
  , FIRST x_grp-obj-price OUTER-JOIN
       BY buf_price-list-type.priority
       BY buf_price-list-type.plt-main-id DESC
       BY buf_price-list-type.plt-main-db-num DESC
       BY buf_price-list-type.under-type-list
       BY buf_price-list-type.sys-date DESC
       BY buf_price-list-type.sys-time DESC .
end.
when "-" then do:
OPEN QUERY {&browse-name}
  FOR EACH buf_price-list-type WHERE
  ( r-ban-discnt = 0 OR buf_price-list-type.ban-discnt = r-ban-discnt ) AND
  ( r-status = 2 OR buf_price-list-type.stts =  r-status ) AND
  ( r-main = 2 OR buf_price-list-type.main =  logical(r-main) ) AND
  ( r-avtop = 2 OR buf_price-list-type.only-gbd = r-avtop ) AND
  ( r-obj = 2 OR        ( buf_price-list-type.gop-id     = loc_gop-id AND
                          buf_price-list-type.gop-db-num = loc_gop-db-num )     ) AND
  ( R-buyer = 2 OR    ( buf_price-list-type.bgr-id     = loc_bgr-id AND
                        buf_price-list-type.bgr-db-num = loc_bgr-db-num )     ) AND
  ( R-tog = 2 OR    ( buf_price-list-type.tog-id     = loc_tog-id AND
                      buf_price-list-type.tog-db-num = loc_tog-db-num )     ) AND
   ( R-plt = 2 OR       LOOKUP (string( RECID (buf_price-list-type)) , loc_plt-recid ) > 0 )
   , FIRST x_grp-obj-price OUTER-JOIN
       BY buf_price-list-type.priority DESC
       BY buf_price-list-type.plt-main-id DESC
       BY buf_price-list-type.plt-main-db-num DESC
       BY buf_price-list-type.under-type-list
       BY buf_price-list-type.sys-date DESC
       BY buf_price-list-type.sys-time DESC .
end.

when "def" then do:
buf_price-list-type.priority:COLUMN-fgcolor in browse {&browse-name}   = 0.
OPEN QUERY {&browse-name}
  FOR EACH buf_price-list-type WHERE
  ( r-ban-discnt = 0 OR buf_price-list-type.ban-discnt = r-ban-discnt ) AND
  ( r-status = 2 OR buf_price-list-type.stts      =  r-status ) AND
  ( r-main = 2 OR  buf_price-list-type.main       =  logical(r-main) ) AND
  ( r-avtop = 2 OR buf_price-list-type.only-gbd =  r-avtop ) AND
  ( r-obj = 2 OR   ( buf_price-list-type.gop-id   = loc_gop-id AND
                   buf_price-list-type.gop-db-num = loc_gop-db-num )     ) AND
  ( R-buyer = 2 OR ( buf_price-list-type.bgr-id   = loc_bgr-id AND
                   buf_price-list-type.bgr-db-num = loc_bgr-db-num )     ) AND
  ( R-tog = 2 OR   ( buf_price-list-type.tog-id   = loc_tog-id AND
                   buf_price-list-type.tog-db-num = loc_tog-db-num )     ) AND
  ( R-plt = 2 OR   LOOKUP (string( RECID (buf_price-list-type)) , loc_plt-recid ) > 0 )
  , FIRST x_grp-obj-price OUTER-JOIN
       BY buf_price-list-type.plt-main-id DESC
       BY buf_price-list-type.plt-main-db-num DESC
       BY buf_price-list-type.under-type-list
       BY buf_price-list-type.sys-date DESC
       BY buf_price-list-type.sys-time DESC .
end.
end case .
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME