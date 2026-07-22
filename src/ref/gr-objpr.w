&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v9r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER buf_clients FOR ub.clients.
DEFINE BUFFER buf_db-grp-obj-price FOR ub.db-grp-obj-price.
DEFINE NEW SHARED BUFFER buf_grp-obj-price FOR ub.grp-obj-price.
DEFINE BUFFER Buf_host-grp-obj-price FOR ub.host-grp-obj-price.
DEFINE BUFFER buf_obj-grp-obj-price FOR ub.obj-grp-obj-price.
DEFINE BUFFER buf_obj-name FOR ub.clients.
DEFINE BUFFER host-name FOR ub.clients.
DEFINE TEMP-TABLE x_obj-grp-obj-price NO-UNDO LIKE ub.obj-grp-obj-price.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision: d47c064bc860, 1107, rls $
$Author: SMMolotkov $
$Date: Thu Dec 14 02:13:53 2017 +0300 $
$Workfile: gr-objpr.w $
$Archive: ref/gr-objpr.w $

Справочник групп объектов для ценообразовани

Автор: Чернова Светлана Александровна
Дата создания: 11/17/05
Author: Svetlana Chernova
Creation date: 11/17/05


*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input  parameter parParentProc as handle no-undo .
define input  parameter p-bttns    as character no-undo .
define input-output parameter p-rec-list as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: d47c064bc860, 1107, rls $":U .
define variable vss-author      as character no-undo init "$Author: SMMolotkov $":U .
define variable vss-date        as character no-undo init "$Date: Thu Dec 14 02:13:53 2017 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: gr-objpr.w $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/gr-objpr.w $":U .
define variable vss-description as character no-undo init "Справочник групп объектов для ценообразования ".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i  }
{ cmp/library.i  }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
{ gbl/userobjs.i }
{ gbl/waitfram.i }
{ ref/obji-ad.i  }
{ gbl/usrfulnf.i }
/* Local Variable Definitions ---                                       */

define variable v-full as logical   no-undo .
define variable v-rec-list-cli as character no-undo .
define variable g-log as logical   no-undo .
define variable sort-column-name as character no-undo .
define variable v-obj-type as character no-undo .
define variable v-obj-code as integer   no-undo .
define variable g-find as logical   no-undo init false .

define variable  tt-grp-obj as character no-undo .

function mark-string returns character
  ( buffer loc-table for ub.grp-obj-price, input mark-list as character  ) :
  return ( if lookup( string( recid( loc-table ) ), mark-list ) > 0 then "*" else "":U ).
end function.

function mark-string-2 returns character
  ( buffer loc-table for ub.db-grp-obj-price , input mark-list as character  ) :
  return ( if lookup( string( recid( loc-table ) ), mark-list ) > 0 then "*" else "":U ).
end function.

function stts-string-2 returns character
  ( buffer loc-table for ub.db-grp-obj-price   ) :
&scop status-code string(loc-table.stts)
return {&status-int-name} .
end function.

function stts-string-5 returns character
  ( buffer loc-table for x_obj-grp-obj-price  ) :
&scop status-code string(loc-table.stts)
return {&status-int-name} .
end function.


function stts-string returns character
  ( buffer loc-table for ub.grp-obj-price   ) :
&scop status-code string(loc-table.stts)
return {&status-int-name} .
end function.

function mark-string-3 returns character
  ( buffer loc-table for ub.host-grp-obj-price , input mark-list as character  ) :
  return ( if lookup( string( recid( loc-table ) ), mark-list ) > 0 then "*" else "":U ).
end function.

function stts-string-3 returns character
  ( buffer loc-table for ub.host-grp-obj-price   ) :
&scop status-code string(loc-table.stts)
return {&status-int-name} .
end function.


function mark-string-4 returns character
  ( buffer loc-table for ub.obj-grp-obj-price , input mark-list as character  ) :
  return ( if lookup( string( recid( loc-table ) ), mark-list ) > 0 then "*" else "":U ).
end function.

function stts-string-4 returns character
  ( buffer loc-table for ub.obj-grp-obj-price ) :
&scop status-code string(loc-table.stts)
return {&status-int-name} .
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
&Scoped-define EXTERNAL-TABLES buf_grp-obj-price
&Scoped-define FIRST-EXTERNAL-TABLE buf_grp-obj-price


/* Need to scope the external tables to this procedure                  */
DEFINE QUERY external_tables FOR buf_grp-obj-price.
/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES buf_grp-obj-price buf_db-grp-obj-price ~
buf_host-grp-obj-price host-name buf_obj-grp-obj-price buf_obj-name ~
x_obj-grp-obj-price buf_clients

/* Definitions for BROWSE BROWSE-1grp                                   */
&Scoped-define FIELDS-IN-QUERY-BROWSE-1grp mark-string(buffer buf_grp-obj-price, p-rec-list) buf_grp-obj-price.gop-id stts-string(buffer buf_grp-obj-price) buf_grp-obj-price.name-group usrfulnf( buf_grp-obj-price.who) buf_grp-obj-price.sys-date buf_grp-obj-price.sys-time-chr buf_grp-obj-price.db-num-chg buf_grp-obj-price.gop-db-num
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-1grp buf_grp-obj-price.name
&Scoped-define ENABLED-TABLES-IN-QUERY-BROWSE-1grp buf_grp-obj-price
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-BROWSE-1grp buf_grp-obj-price
&Scoped-define SELF-NAME BROWSE-1grp
&Scoped-define QUERY-STRING-BROWSE-1grp FOR EACH buf_grp-obj-price WHERE     ( r-status = 2 OR buf_grp-obj-price.stts =  r-status ) AND     ( g-find = NO OR       LOOKUP (string(buf_grp-obj-price.gop-id) + ";"  + string(buf_grp-obj-price.gop-db-num)  , ~
       tt-grp-obj ) > 0 )         /*(CAN-FIND (tt-grp-obj-price WHERE       tt-grp-obj-price.gop-id     = buf_grp-obj-price.gop-id AND       tt-grp-obj-price.gop-db-num = buf_grp-obj-price.gop-db-num )))       */
&Scoped-define OPEN-QUERY-BROWSE-1grp OPEN QUERY {&SELF-NAME} FOR EACH buf_grp-obj-price WHERE     ( r-status = 2 OR buf_grp-obj-price.stts =  r-status ) AND     ( g-find = NO OR       LOOKUP (string(buf_grp-obj-price.gop-id) + ";"  + string(buf_grp-obj-price.gop-db-num)  , ~
       tt-grp-obj ) > 0 )         /*(CAN-FIND (tt-grp-obj-price WHERE       tt-grp-obj-price.gop-id     = buf_grp-obj-price.gop-id AND       tt-grp-obj-price.gop-db-num = buf_grp-obj-price.gop-db-num )))       */       .
&Scoped-define TABLES-IN-QUERY-BROWSE-1grp buf_grp-obj-price
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-1grp buf_grp-obj-price


/* Definitions for BROWSE BROWSE-2db                                    */
&Scoped-define FIELDS-IN-QUERY-BROWSE-2db mark-string-2(buffer buf_db-grp-obj-price, v-rec-list-cli) buf_db-grp-obj-price.dgo-db-num usrfulnf(buf_db-grp-obj-price.who) buf_db-grp-obj-price.sys-date buf_db-grp-obj-price.sys-time-chr buf_db-grp-obj-price.num-chg stts-string-2(buffer buf_db-grp-obj-price) buf_db-grp-obj-price.gop-id buf_db-grp-obj-price.gop-db-num
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-2db
&Scoped-define SELF-NAME BROWSE-2db
&Scoped-define QUERY-STRING-BROWSE-2db FOR EACH buf_db-grp-obj-price OF buf_grp-obj-price      WHERE ( r-status = 2 OR buf_db-grp-obj-price.stts =  r-status )       NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-BROWSE-2db OPEN QUERY {&SELF-NAME} FOR EACH buf_db-grp-obj-price OF buf_grp-obj-price      WHERE ( r-status = 2 OR buf_db-grp-obj-price.stts =  r-status )       NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-BROWSE-2db buf_db-grp-obj-price
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-2db buf_db-grp-obj-price


/* Definitions for BROWSE BROWSE-3frm                                   */
&Scoped-define FIELDS-IN-QUERY-BROWSE-3frm mark-string-3(buffer buf_host-grp-obj-price, v-rec-list-cli) buf_host-grp-obj-price.host-code host-name.obj-name usrfulnf(buf_host-grp-obj-price.who) buf_host-grp-obj-price.sys-date buf_host-grp-obj-price.sys-time-chr buf_host-grp-obj-price.db-num-chg stts-string-3(buffer buf_host-grp-obj-price) buf_host-grp-obj-price.gop-id buf_host-grp-obj-price.gop-db-num
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-3frm
&Scoped-define SELF-NAME BROWSE-3frm
&Scoped-define QUERY-STRING-BROWSE-3frm FOR EACH buf_host-grp-obj-price OF buf_grp-obj-price      WHERE ( r-status = 2 OR buf_host-grp-obj-price.stts =  r-status )       NO-LOCK , ~
           FIRST host-name NO-LOCK WHERE       host-name.obj-code = buf_host-grp-obj-price.host-code AND       host-name.obj-type = {&cmp}     INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-BROWSE-3frm OPEN QUERY {&SELF-NAME} FOR EACH buf_host-grp-obj-price OF buf_grp-obj-price      WHERE ( r-status = 2 OR buf_host-grp-obj-price.stts =  r-status )       NO-LOCK , ~
           FIRST host-name NO-LOCK WHERE       host-name.obj-code = buf_host-grp-obj-price.host-code AND       host-name.obj-type = {&cmp}     INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-BROWSE-3frm buf_host-grp-obj-price host-name
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-3frm buf_host-grp-obj-price
&Scoped-define SECOND-TABLE-IN-QUERY-BROWSE-3frm host-name


/* Definitions for BROWSE BROWSE-4obj                                   */
&Scoped-define FIELDS-IN-QUERY-BROWSE-4obj mark-string-4(buffer buf_obj-grp-obj-price, v-rec-list-cli) buf_obj-grp-obj-price.obj-type + " " + STRING( buf_obj-grp-obj-price.obj-code) buf_obj-name.obj-name usrfulnf(buf_obj-grp-obj-price.who) buf_obj-grp-obj-price.sys-date buf_obj-grp-obj-price.sys-time-chr buf_obj-grp-obj-price.db-num-chg stts-string-4(buffer buf_obj-grp-obj-price) buf_obj-grp-obj-price.gop-id buf_obj-grp-obj-price.gop-db-num
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-4obj
&Scoped-define SELF-NAME BROWSE-4obj
&Scoped-define QUERY-STRING-BROWSE-4obj FOR EACH buf_obj-grp-obj-price OF buf_grp-obj-price      WHERE ( r-status = 2 OR buf_obj-grp-obj-price.stts =  r-status )       NO-LOCK, ~
           FIRST buf_obj-name NO-LOCK WHERE       buf_obj-name.obj-code = buf_obj-grp-obj-price.obj-code AND       buf_obj-name.obj-type = buf_obj-grp-obj-price.obj-type     INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-BROWSE-4obj OPEN QUERY {&SELF-NAME} FOR EACH buf_obj-grp-obj-price OF buf_grp-obj-price      WHERE ( r-status = 2 OR buf_obj-grp-obj-price.stts =  r-status )       NO-LOCK, ~
           FIRST buf_obj-name NO-LOCK WHERE       buf_obj-name.obj-code = buf_obj-grp-obj-price.obj-code AND       buf_obj-name.obj-type = buf_obj-grp-obj-price.obj-type     INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-BROWSE-4obj buf_obj-grp-obj-price ~
buf_obj-name
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-4obj buf_obj-grp-obj-price
&Scoped-define SECOND-TABLE-IN-QUERY-BROWSE-4obj buf_obj-name


/* Definitions for BROWSE BROWSE-5all                                   */
&Scoped-define FIELDS-IN-QUERY-BROWSE-5all buf_clients.obj-type + " " + STRING( buf_clients.obj-code ) buf_clients.obj-name buf_clients.host-code buf_clients.db-num stts-string-5(buffer x_obj-grp-obj-price )
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-5all buf_clients.db-num
&Scoped-define ENABLED-TABLES-IN-QUERY-BROWSE-5all buf_clients
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-BROWSE-5all buf_clients
&Scoped-define SELF-NAME BROWSE-5all
&Scoped-define QUERY-STRING-BROWSE-5all FOR EACH x_obj-grp-obj-price OF buf_grp-obj-price      WHERE ( r-status = 2 OR x_obj-grp-obj-price.stts =  r-status )       NO-LOCK , ~
           FIRST buf_clients NO-LOCK WHERE       buf_clients.obj-code = x_obj-grp-obj-price.obj-code AND       buf_clients.obj-type = x_obj-grp-obj-price.obj-type
&Scoped-define OPEN-QUERY-BROWSE-5all OPEN QUERY {&SELF-NAME} FOR EACH x_obj-grp-obj-price OF buf_grp-obj-price      WHERE ( r-status = 2 OR x_obj-grp-obj-price.stts =  r-status )       NO-LOCK , ~
           FIRST buf_clients NO-LOCK WHERE       buf_clients.obj-code = x_obj-grp-obj-price.obj-code AND       buf_clients.obj-type = x_obj-grp-obj-price.obj-type        .
&Scoped-define TABLES-IN-QUERY-BROWSE-5all x_obj-grp-obj-price buf_clients
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-5all x_obj-grp-obj-price
&Scoped-define SECOND-TABLE-IN-QUERY-BROWSE-5all buf_clients


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BROWSE-1grp}~
    ~{&OPEN-QUERY-BROWSE-2db}~
    ~{&OPEN-QUERY-BROWSE-3frm}~
    ~{&OPEN-QUERY-BROWSE-4obj}~
    ~{&OPEN-QUERY-BROWSE-5all}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-Cancel RECT-1 B-sel B-add B-del ~
B-price-type b-more B-history B-print B-Help R-status B-mark B-find-obj ~
B-all B-mark-2 B-add-DB B-del-DB B-mark-3 B-add-frm B-del-frm BROWSE-1grp ~
BROWSE-2db BROWSE-3frm BROWSE-5all B-mark-4 B-add-obj B-del-obj BROWSE-4obj ~
FILL-IN-1 F-obj
&Scoped-Define DISPLAYED-OBJECTS R-status FILL-IN-1 F-obj

/* Custom List Definitions                                              */
/* hide-list,List-2,List-3,List-4,List-5,List-6                         */
&Scoped-define hide-list B-history B-print B-Help B-mark-2 B-add-DB ~
B-del-DB B-mark-3 B-add-frm B-del-frm BROWSE-2db BROWSE-3frm B-mark-4 ~
B-add-obj B-del-obj BROWSE-4obj

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-add
     LABEL "Добавить"
     SIZE 10 BY 1 TOOLTIP "Добавить группу"
     BGCOLOR 8 .

DEFINE BUTTON B-add-DB
     IMAGE-UP FILE "cmp/add.bmp":U
     LABEL "+"
     SIZE 3 BY 1 TOOLTIP "Добавить БД"
     BGCOLOR 8 .

DEFINE BUTTON B-add-frm
     IMAGE-UP FILE "cmp/add.bmp":U
     LABEL "Добавить Фирму"
     SIZE 3 BY 1 TOOLTIP "Добавить Фирму"
     BGCOLOR 8 .

DEFINE BUTTON B-add-obj
     IMAGE-UP FILE "cmp/add.bmp":U
     LABEL "Добавить объект"
     SIZE 3 BY 1 TOOLTIP "Добавить объект"
     BGCOLOR 8 .

DEFINE BUTTON B-all
     IMAGE-UP FILE "cmp/cancel.bmp":U
     LABEL "все"
     SIZE 3 BY 1 TOOLTIP "Показать все"
     FONT 4.

DEFINE BUTTON B-Cancel AUTO-END-KEY
     LABEL "Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-del
     LABEL "Удалить"
     SIZE 10 BY 1 TOOLTIP "Удалить группу"
     BGCOLOR 8 .

DEFINE BUTTON B-del-DB
     IMAGE-UP FILE "cmp/deleterec.bmp":U
     LABEL "-"
     SIZE 3 BY 1 TOOLTIP "Удалить БД"
     BGCOLOR 8 .

DEFINE BUTTON B-del-frm
     IMAGE-UP FILE "cmp/deleterec.bmp":U
     LABEL "Удалить"
     SIZE 3 BY 1 TOOLTIP "Удалить Фирму"
     BGCOLOR 8 .

DEFINE BUTTON B-del-obj
     IMAGE-UP FILE "cmp/deleterec.bmp":U
     LABEL "Удалить"
     SIZE 3 BY 1 TOOLTIP "Удалить Объект"
     BGCOLOR 8 .

DEFINE BUTTON B-find-obj
     IMAGE-UP FILE "cmp/select.bmp":U
     LABEL ""
     SIZE 3 BY 1 TOOLTIP "Поиск по объекту".

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-history
     LABEL "История"
     SIZE 10 BY 1 TOOLTIP "История изменения справочника"
     BGCOLOR 8 .

DEFINE BUTTON B-mark
     LABEL "*"
     SIZE 2.88 BY .92 TOOLTIP "Отметить группу"
     BGCOLOR 8 .

DEFINE BUTTON B-mark-2
     LABEL "*"
     SIZE 3 BY 1 TOOLTIP "Отметить БД"
     BGCOLOR 8 .

DEFINE BUTTON B-mark-3
     LABEL "*"
     SIZE 3.25 BY 1 TOOLTIP "Отметить фирму"
     BGCOLOR 8 .

DEFINE BUTTON B-mark-4
     LABEL "*"
     SIZE 3.25 BY 1 TOOLTIP "Отметить объект"
     BGCOLOR 8 .

DEFINE BUTTON b-more
     IMAGE-UP FILE "cmp/last.bmp":U
     LABEL ">>"
     SIZE 3 BY 1 TOOLTIP "Подробный или сокращенный режим".

DEFINE BUTTON B-price-type
     LABEL "&ТПЛ"
     SIZE 6 BY 1 TOOLTIP "Список типов ПЛ по группе объектов".

DEFINE BUTTON B-print
     LABEL "Печать"
     SIZE 10 BY 1 TOOLTIP "Печать справочника"
     BGCOLOR 8 .

DEFINE BUTTON B-sel AUTO-GO
     LABEL "Выбор"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE F-obj AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 14 BY .54
     FGCOLOR 1 FONT 4 NO-UNDO.

DEFINE VARIABLE FILL-IN-1 AS CHARACTER FORMAT "X(256)":U INITIAL "Статус:"
      VIEW-AS TEXT
     SIZE 7.5 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE R-status AS INTEGER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Текущие", 0,
"Все", 2,
"Удаленные", 1
     SIZE 30.5 BY .67 TOOLTIP "Условие отбора записей" NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE 50.5 BY 19.42
     BGCOLOR 1 .

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BROWSE-1grp FOR
      buf_grp-obj-price SCROLLING.

DEFINE QUERY BROWSE-2db FOR
      buf_db-grp-obj-price SCROLLING.

DEFINE QUERY BROWSE-3frm FOR
      buf_host-grp-obj-price,
      host-name SCROLLING.

DEFINE QUERY BROWSE-4obj FOR
      buf_obj-grp-obj-price,
      buf_obj-name SCROLLING.

DEFINE QUERY BROWSE-5all FOR
      x_obj-grp-obj-price,
      buf_clients SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BROWSE-1grp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-1grp Dialog-Frame _FREEFORM
  QUERY BROWSE-1grp NO-LOCK DISPLAY
      mark-string(buffer buf_grp-obj-price, p-rec-list) COLUMN-LABEL "*! " FORMAT "x(1)":U
      buf_grp-obj-price.gop-id COLUMN-LABEL "Код! " FORMAT ">>>>>9":U
      stts-string(buffer buf_grp-obj-price) COLUMN-LABEL "Ста!тус" FORMAT "x(3)":U
      buf_grp-obj-price.name-group COLUMN-LABEL "Название!группы" FORMAT "X(30)":U
      usrfulnf( buf_grp-obj-price.who) COLUMN-LABEL "Кто!изменял" FORMAT "X(15)":U
      buf_grp-obj-price.sys-date COLUMN-LABEL "Дата!изм" FORMAT "99/99/99":U
      buf_grp-obj-price.sys-time-chr COLUMN-LABEL "Время!изм" FORMAT "X(5)":U
      buf_grp-obj-price.db-num-chg COLUMN-LABEL "БД!изм" FORMAT ">>>>9":U
      buf_grp-obj-price.gop-db-num FORMAT ">>>>9":U COLUMN-LABEL "БД!созд"
  ENABLE
      buf_grp-obj-price.name
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 49.13 BY 8
         TITLE "Группы объектов" ROW-HEIGHT-CHARS .6 FIT-LAST-COLUMN.

DEFINE BROWSE BROWSE-2db
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-2db Dialog-Frame _FREEFORM
  QUERY BROWSE-2db NO-LOCK DISPLAY
      mark-string-2(buffer buf_db-grp-obj-price, v-rec-list-cli) COLUMN-LABEL "*! " FORMAT "x(1)":U
      buf_db-grp-obj-price.dgo-db-num COLUMN-LABEL "БД! " FORMAT ">>>>9":U
      usrfulnf(buf_db-grp-obj-price.who) COLUMN-LABEL "Кто!изменял" FORMAT "X(20)":U
            WIDTH 10
      buf_db-grp-obj-price.sys-date COLUMN-LABEL "Дата!изм" FORMAT "99/99/99":U
            WIDTH 12
      buf_db-grp-obj-price.sys-time-chr COLUMN-LABEL "Время!изм" FORMAT "X(5)":U
            WIDTH 12
      buf_db-grp-obj-price.num-chg COLUMN-LABEL "БД!изм" FORMAT ">>>>9":U
      stts-string-2(buffer buf_db-grp-obj-price) COLUMN-LABEL "Ста!тус" FORMAT "x(6)":U
      buf_db-grp-obj-price.gop-id COLUMN-LABEL "Гру!ппа" FORMAT ">>>>>9":U

      buf_db-grp-obj-price.gop-db-num FORMAT ">>>>9":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 11 BY 7.75
         TITLE "БД в группе" ROW-HEIGHT-CHARS .6 FIT-LAST-COLUMN.

DEFINE BROWSE BROWSE-3frm
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-3frm Dialog-Frame _FREEFORM
  QUERY BROWSE-3frm NO-LOCK DISPLAY
      mark-string-3(buffer buf_host-grp-obj-price, v-rec-list-cli) COLUMN-LABEL "*! " FORMAT "x(1)":U
      buf_host-grp-obj-price.host-code COLUMN-LABEL "Код!фирмы" FORMAT ">>>>>>>>9":U
      host-name.obj-name COLUMN-LABEL "Имя!фирмы" FORMAT  "X(20)":U
      usrfulnf(buf_host-grp-obj-price.who) COLUMN-LABEL "Кто!изменял" FORMAT "X(20)":U
            WIDTH 10
      buf_host-grp-obj-price.sys-date COLUMN-LABEL "Дата!изм" FORMAT "99/99/99":U
            WIDTH 12
      buf_host-grp-obj-price.sys-time-chr COLUMN-LABEL "Время!изм" FORMAT "X(5)":U
            WIDTH 12
      buf_host-grp-obj-price.db-num-chg COLUMN-LABEL "БД!изм" FORMAT ">>>>9":U
            WIDTH 3
      stts-string-3(buffer buf_host-grp-obj-price) COLUMN-LABEL "Ста!тус" FORMAT "x(6)":U
      buf_host-grp-obj-price.gop-id COLUMN-LABEL "Гру!ппа" FORMAT ">>>>>9":U
      buf_host-grp-obj-price.gop-db-num FORMAT ">>>>9":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 38.5 BY 7.75
         TITLE "Фирмы в группе" ROW-HEIGHT-CHARS .6 FIT-LAST-COLUMN.

DEFINE BROWSE BROWSE-4obj
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-4obj Dialog-Frame _FREEFORM
  QUERY BROWSE-4obj NO-LOCK DISPLAY
      mark-string-4(buffer buf_obj-grp-obj-price, v-rec-list-cli) COLUMN-LABEL "*! " FORMAT "x(1)":U
      buf_obj-grp-obj-price.obj-type + " "  + STRING( buf_obj-grp-obj-price.obj-code)  COLUMN-LABEL "Объект! " FORMAT "x(11)":U
      buf_obj-name.obj-name COLUMN-LABEL "Имя!объекта" FORMAT  "X(20)":U
      usrfulnf(buf_obj-grp-obj-price.who) COLUMN-LABEL "Кто!изменял" FORMAT "X(20)":U
            WIDTH 10
      buf_obj-grp-obj-price.sys-date COLUMN-LABEL "Дата!изм" FORMAT "99/99/99":U
            WIDTH 12
      buf_obj-grp-obj-price.sys-time-chr COLUMN-LABEL "Время!изм" FORMAT "X(5)":U
            WIDTH 12
      buf_obj-grp-obj-price.db-num-chg COLUMN-LABEL "БД!изм" FORMAT ">>>>9":U
            WIDTH 3
      stts-string-4(buffer buf_obj-grp-obj-price) COLUMN-LABEL "Ста!тус" FORMAT "x(3)":U
      buf_obj-grp-obj-price.gop-id COLUMN-LABEL "Гру!ппа" FORMAT ">>>>>9":U
           buf_obj-grp-obj-price.gop-db-num FORMAT ">>>>9":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 49.5 BY 10
         TITLE "Объекты в группе" ROW-HEIGHT-CHARS .6 FIT-LAST-COLUMN.

DEFINE BROWSE BROWSE-5all
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-5all Dialog-Frame _FREEFORM
  QUERY BROWSE-5all NO-LOCK DISPLAY
      buf_clients.obj-type + " "  + STRING( buf_clients.obj-code )  COLUMN-LABEL "Объект" FORMAT "X(11)":U
      buf_clients.obj-name  COLUMN-LABEL "Имя объекта" FORMAT  "X(20)":U
      buf_clients.host-code COLUMN-LABEL "Фирма" FORMAT  ">>>>>>>>9":U
      buf_clients.db-num    COLUMN-LABEL "БД" FORMAT  ">>>>>>>>9":U
      stts-string-5(buffer x_obj-grp-obj-price ) COLUMN-LABEL "Статус" FORMAT  "X(6)":U
      ENABLE
      buf_clients.db-num
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 49.13 BY 11
         TITLE "Совокупность объектов в группе" ROW-HEIGHT-CHARS .6 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-Cancel AT ROW 1 COL 1
     B-sel AT ROW 1 COL 11
     B-add AT ROW 1 COL 21
     B-del AT ROW 1 COL 31
     B-price-type AT ROW 1 COL 41
     b-more AT ROW 1 COL 47.13
     B-history AT ROW 1 COL 66.5
     B-print AT ROW 1 COL 76.5
     B-Help AT ROW 1 COL 86.75
     R-status AT ROW 2.13 COL 9.63 NO-LABEL
     B-mark AT ROW 2.83 COL 1.63
     B-find-obj AT ROW 2.83 COL 4.63
     B-all AT ROW 2.83 COL 7.75
     B-mark-2 AT ROW 3 COL 51.5
     B-add-DB AT ROW 3 COL 54.63
     B-del-DB AT ROW 3 COL 57.75
     B-mark-3 AT ROW 3 COL 62.38
     B-add-frm AT ROW 3 COL 65.75
     B-del-frm AT ROW 3 COL 68.88
     BROWSE-1grp AT ROW 4 COL 1.75
     BROWSE-2db AT ROW 4 COL 51.5
     BROWSE-3frm AT ROW 4 COL 62.38
     BROWSE-5all AT ROW 12 COL 1.75
     B-mark-4 AT ROW 12 COL 51.5
     B-add-obj AT ROW 12 COL 54.88
     B-del-obj AT ROW 12 COL 58
     BROWSE-4obj AT ROW 13 COL 51.5
     FILL-IN-1 AT ROW 2.13 COL 2 NO-LABEL
     F-obj AT ROW 3.04 COL 8.88 COLON-ALIGNED NO-LABEL
     RECT-1 AT ROW 3.75 COL 1
     SPACE(49.99) SKIP(0.00)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Группы объектов для ценообразования"
         DEFAULT-BUTTON B-sel CANCEL-BUTTON B-Cancel.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   External Tables: Temp-Tables.buf_grp-obj-price
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: buf_clients B "?" ? ub ub.clients
      TABLE: buf_db-grp-obj-price B "?" ? ub ub.db-grp-obj-price
      TABLE: buf_grp-obj-price B "NEW SHARED" ? ub ub.grp-obj-price
      TABLE: Buf_host-grp-obj-price B "?" ? ub ub.host-grp-obj-price
      TABLE: buf_obj-grp-obj-price B "?" ? ub ub.obj-grp-obj-price
      TABLE: buf_obj-name B "?" ? ub ub.clients
      TABLE: host-name B "?" ? ub ub.clients
      TABLE: x_obj-grp-obj-price T "?" NO-UNDO ub ub.obj-grp-obj-price
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BROWSE-1grp B-del-frm Dialog-Frame */
/* BROWSE-TAB BROWSE-2db BROWSE-1grp Dialog-Frame */
/* BROWSE-TAB BROWSE-3frm BROWSE-2db Dialog-Frame */
/* BROWSE-TAB BROWSE-5all BROWSE-3frm Dialog-Frame */
/* BROWSE-TAB BROWSE-4obj B-del-obj Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR BUTTON B-add-DB IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR BUTTON B-add-frm IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR BUTTON B-add-obj IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR BUTTON B-del-DB IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR BUTTON B-del-frm IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR BUTTON B-del-obj IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR BUTTON B-Help IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR BUTTON B-history IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR BUTTON B-mark-2 IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR BUTTON B-mark-3 IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR BUTTON B-mark-4 IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR BUTTON B-print IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR BROWSE BROWSE-2db IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR BROWSE BROWSE-3frm IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR BROWSE BROWSE-4obj IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR FILL-IN FILL-IN-1 IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-1grp
/* Query rebuild information for BROWSE BROWSE-1grp
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH buf_grp-obj-price WHERE
    ( r-status = 2 OR buf_grp-obj-price.stts =  r-status ) AND
    ( g-find = NO OR
      LOOKUP (string(buf_grp-obj-price.gop-id) + ";"  + string(buf_grp-obj-price.gop-db-num)  , tt-grp-obj ) > 0 )


      /*(CAN-FIND (tt-grp-obj-price WHERE
      tt-grp-obj-price.gop-id     = buf_grp-obj-price.gop-id AND
      tt-grp-obj-price.gop-db-num = buf_grp-obj-price.gop-db-num )))
      */
      .
     _END_FREEFORM
     _Options          = "NO-LOCK"
     _Query            is OPENED
*/  /* BROWSE BROWSE-1grp */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-2db
/* Query rebuild information for BROWSE BROWSE-2db
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH buf_db-grp-obj-price OF buf_grp-obj-price
     WHERE ( r-status = 2 OR buf_db-grp-obj-price.stts =  r-status )
      NO-LOCK INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _TblOptList       = ","
     _Query            is OPENED
*/  /* BROWSE BROWSE-2db */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-3frm
/* Query rebuild information for BROWSE BROWSE-3frm
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH buf_host-grp-obj-price OF buf_grp-obj-price
     WHERE ( r-status = 2 OR buf_host-grp-obj-price.stts =  r-status )
      NO-LOCK ,
    FIRST host-name NO-LOCK WHERE
      host-name.obj-code = buf_host-grp-obj-price.host-code AND
      host-name.obj-type = {&cmp}
    INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _TblOptList       = ","
     _Query            is OPENED
*/  /* BROWSE BROWSE-3frm */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-4obj
/* Query rebuild information for BROWSE BROWSE-4obj
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH buf_obj-grp-obj-price OF buf_grp-obj-price
     WHERE ( r-status = 2 OR buf_obj-grp-obj-price.stts =  r-status )
      NO-LOCK,
    FIRST buf_obj-name NO-LOCK WHERE
      buf_obj-name.obj-code = buf_obj-grp-obj-price.obj-code AND
      buf_obj-name.obj-type = buf_obj-grp-obj-price.obj-type
    INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _TblOptList       = ","
     _Query            is OPENED
*/  /* BROWSE BROWSE-4obj */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-5all
/* Query rebuild information for BROWSE BROWSE-5all
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH x_obj-grp-obj-price OF buf_grp-obj-price
     WHERE ( r-status = 2 OR x_obj-grp-obj-price.stts =  r-status )
      NO-LOCK ,
    FIRST buf_clients NO-LOCK WHERE
      buf_clients.obj-code = x_obj-grp-obj-price.obj-code AND
      buf_clients.obj-type = x_obj-grp-obj-price.obj-type

      .
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _TblOptList       = ","
     _Query            is OPENED
*/  /* BROWSE BROWSE-5all */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Группы объектов для ценообразования */
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
    'actn_ref-mpl_update':U
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
  run ref/gr-ogr.w (input parparentproc,input {&add-def} , input-output v-rec-id) .
  {&OPEN-QUERY-BROWSE-1grp}
  reposition BROWSE-1grp to recid v-rec-id no-error .
  {&OPEN-QUERY-BROWSE-2db}
  {&OPEN-QUERY-BROWSE-3frm}
  {&OPEN-QUERY-BROWSE-4obj}
  {&OPEN-QUERY-BROWSE-5all}


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-add-DB
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-add-DB Dialog-Frame
ON CHOOSE OF B-add-DB IN FRAME Dialog-Frame /* + */
DO:
   define variable g#log as logical   no-undo .
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_ref-mpl_update':U
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
if not available buf_grp-obj-price then return .
  if v-cntxt-db-num <> 0 then do :
    if buf_grp-obj-price.gop-db-num <> v-cntxt-db-num then do:
      message substitute(" Группа создана в другой БД (&1) , корректировать ее в текущей БД нельзя !" , buf_grp-obj-price.gop-db-num ) .
      return .
    end.
  end.

if buf_grp-obj-price.stts <> 0 then do:
   message "В эту группу добавлять БД нельзя!" view-as alert-box error .
   return .
end.

DEFINE VARIABLE p-db-recid AS RECID NO-UNDO.

run adm/dbs.w (
              input parparentproc
             ,input {&lookup}
             ,OUTPUT p-db-recid) .
if p-db-recid = ? then return no-apply .
run proc-add-db (
      input p-db-recid   ,
      input buf_grp-obj-price.gop-db-num ,
      input buf_grp-obj-price.gop-id     ,
      input buf_grp-obj-price.name-group ,
      input-output v-rec-id ) .
run init-5obj.

  {&OPEN-QUERY-BROWSE-2db}
  reposition BROWSE-2db to recid v-rec-id no-error .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-add-frm
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-add-frm Dialog-Frame
ON CHOOSE OF B-add-frm IN FRAME Dialog-Frame /* Добавить Фирму */
DO:
   define variable g#log as logical   no-undo .
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_ref-mpl_update':U
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
if not available buf_grp-obj-price then return .
  if v-cntxt-db-num <> 0 then do :
    if buf_grp-obj-price.gop-db-num <> v-cntxt-db-num then do:
      message substitute(" Группа создана в другой БД (&1) , корректировать ее в текущей БД нельзя !" , buf_grp-obj-price.gop-db-num ) .
      return .
    end.
  end.

if buf_grp-obj-price.stts <> 0 then do:
   message "В эту группу добавлять фирму нельзя!" view-as alert-box error .
   return .
end.

  DEFINE VARIABLE p-rid-list as character no-undo.
  DEFINE VARIABLE out-host-code AS INTEGER  no-undo.

run adm/sconfs.w (
    INPUT parParentProc ,
    INPUT "b-sel,b-mark,CONVERt" ,
    INPUT no ,
    INPUT v-cntxt-host-code-obj ,
    output out-host-code ,
    input-output  p-rid-list ) .

if  p-rid-list = ? or p-rid-list = ""  then return no-apply .
run proc-add-firm (
      input p-rid-list   ,
      input buf_grp-obj-price.gop-db-num ,
      input buf_grp-obj-price.gop-id     ,
      input buf_grp-obj-price.name-group ,
      input-output v-rec-id ) .

run init-5obj.
  {&OPEN-QUERY-BROWSE-3frm}

  reposition BROWSE-3frm to recid v-rec-id no-error .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-add-obj
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-add-obj Dialog-Frame
ON CHOOSE OF B-add-obj IN FRAME Dialog-Frame /* Добавить объект */
DO:
   define variable g#log as logical   no-undo .
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_ref-mpl_update':U
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

  if not available buf_grp-obj-price then return .
  if v-cntxt-db-num <> 0 then do :
    if buf_grp-obj-price.gop-db-num <> v-cntxt-db-num then do:
      message substitute(" Группа создана в другой БД (&1) , корректировать ее в текущей БД нельзя !" , buf_grp-obj-price.gop-db-num ) .
      return .
    end.
  end.

  if buf_grp-obj-price.stts <> 0 then do:
    message "В эту группу добавлять объект нельзя!" view-as alert-box error .
    return .
  end.

  { gbl/uobjclr.i  }

  define variable v-user-select as logical   no-undo .
  { gbl/uobjsman.i
    parparentproc
    v-cntxt-db-num
    v-cntxt-userid
    v-cntxt-host-code-obj
    v-cntxt-obj-type
    v-cntxt-obj-code
    v-user-select
  }
  if v-user-select <> true
  then do:
    return no-apply .
  end.

  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .

  for each buf_userobjs_temp-user-obj
  on error undo, return no-apply
  :
    run objo-ADD
      (input  buf_grp-obj-price.gop-db-num
      ,input  buf_grp-obj-price.gop-id
      ,input  buf_userobjs_temp-user-obj.obj-type
      ,input  buf_userobjs_temp-user-obj.obj-code
      ,input  0
      ,input  v-cntxt-db-num
      ,input  v-cntxt-userid
      ,output v-rec-id
      ) .
  end.

  run init-5obj .
  {&OPEN-QUERY-BROWSE-4obj}
  reposition BROWSE-4obj to recid v-rec-id no-error .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-all
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-all Dialog-Frame
ON CHOOSE OF B-all IN FRAME Dialog-Frame /* все */
DO:
  g-find = false .
  F-obj = " "  .
  display F-obj  with frame {&frame-name} .
  {&OPEN-QUERY-BROWSE-1grp}
  {&OPEN-QUERY-BROWSE-2db}
  {&OPEN-QUERY-BROWSE-3frm}
  {&OPEN-QUERY-BROWSE-4obj}
  {&OPEN-QUERY-BROWSE-5all}

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-del Dialog-Frame
ON CHOOSE OF B-del IN FRAME Dialog-Frame /* Удалить */
DO:
   define variable g#log as logical   no-undo .
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_ref-mpl_update':U
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

  if not available buf_grp-obj-price then return .
   if buf_grp-obj-price.stts <> 0 then do:
      message " Группа удалена " .
      return .
   end.

  if v-cntxt-db-num <> 0 then do :
    if buf_grp-obj-price.gop-db-num <> v-cntxt-db-num then do:
      message substitute(" Группа создана в другой БД (&1) , корректировать ее в текущей БД нельзя !" , buf_grp-obj-price.gop-db-num ) .
      return .
    end.
  end.

  message "Удалять группу " buf_grp-obj-price.name-group "?"
          view-as alert-box question
          buttons yes-no update g-ok as log.
  if not g-ok then return .
  run ref/gr-odpr.p (
      input parparentproc ,
      input buf_grp-obj-price.gop-db-num ,
      input buf_grp-obj-price.gop-id      )
      no-error .
 if error-status :error then return no-apply .

 {&OPEN-QUERY-BROWSE-1grp}
 {&OPEN-QUERY-BROWSE-2db}
 {&OPEN-QUERY-BROWSE-3frm}
 {&OPEN-QUERY-BROWSE-4obj}
 {&OPEN-QUERY-BROWSE-5all}


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-del-DB
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-del-DB Dialog-Frame
ON CHOOSE OF B-del-DB IN FRAME Dialog-Frame /* - */
DO:
   define variable g#log as logical   no-undo .
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_ref-mpl_update':U
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

  if not available buf_db-grp-obj-price then return .
  if v-cntxt-db-num <> 0 then do :
    if buf_grp-obj-price.gop-db-num <> v-cntxt-db-num then do:
      message substitute(" Группа создана в другой БД (&1) , корректировать ее в текущей БД нельзя !" , buf_grp-obj-price.gop-db-num ) .
      return .
    end.
  end.

        run obji-del (
           input   buf_db-grp-obj-price.gop-db-num
          ,input   buf_db-grp-obj-price.gop-id
          ,input   buf_db-grp-obj-price.dgo-db-num
          ,input   v-cntxt-db-num
          ,input   v-cntxt-userid ) .
  run init-5obj.
   {&OPEN-QUERY-BROWSE-2db}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-del-frm
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-del-frm Dialog-Frame
ON CHOOSE OF B-del-frm IN FRAME Dialog-Frame /* Удалить */
DO:
   define variable g#log as logical   no-undo .
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_ref-mpl_update':U
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

  if not available buf_host-grp-obj-price then return .
  if v-cntxt-db-num <> 0 then do :
    if buf_grp-obj-price.gop-db-num <> v-cntxt-db-num then do:
      message substitute(" Группа создана в другой БД (&1) , корректировать ее в текущей БД нельзя !" , buf_grp-obj-price.gop-db-num ) .
      return .
    end.
  end.

        run objf-del (
           input   buf_host-grp-obj-price.gop-db-num
          ,input   buf_host-grp-obj-price.gop-id
          ,input   buf_host-grp-obj-price.host-code
          ,input   v-cntxt-db-num
          ,input   v-cntxt-userid ) .
        run init-5obj.
  {&OPEN-QUERY-BROWSE-3frm}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-del-obj
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-del-obj Dialog-Frame
ON CHOOSE OF B-del-obj IN FRAME Dialog-Frame /* Удалить */
DO:
   define variable g#log as logical   no-undo .
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_ref-mpl_update':U
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

  if not available buf_obj-grp-obj-price then return .
  if v-cntxt-db-num <> 0 then do :
    if buf_grp-obj-price.gop-db-num <> v-cntxt-db-num then do:
      message substitute(" Группа создана в другой БД (&1) , корректировать ее в текущей БД нельзя !" , buf_grp-obj-price.gop-db-num ) .
      return .
    end.
  end.

        run objo-del (
            input buf_obj-grp-obj-price.gop-db-num
          , input buf_obj-grp-obj-price.gop-id
          , input buf_obj-grp-obj-price.obj-type
          , input buf_obj-grp-obj-price.obj-code
          , input v-cntxt-db-num
          , input v-cntxt-userid ) .
 run init-5obj.
   {&OPEN-QUERY-BROWSE-4obj}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-find-obj
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-find-obj Dialog-Frame
ON CHOOSE OF B-find-obj IN FRAME Dialog-Frame
DO:
  g-find = true  .
  RUN m-tt .
  F-obj = v-obj-type + " " +  string(v-obj-code) .
  display F-obj  with frame {&frame-name} .
  {&OPEN-QUERY-BROWSE-1grp}
  {&OPEN-QUERY-BROWSE-2db}
  {&OPEN-QUERY-BROWSE-3frm}
  {&OPEN-QUERY-BROWSE-4obj}
  {&OPEN-QUERY-BROWSE-5all}

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-history
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-history Dialog-Frame
ON CHOOSE OF B-history IN FRAME Dialog-Frame /* История */
DO:

  if not available buf_grp-obj-price then return .
  run ref/cgr-obj.w (
      parParentProc ,
      buf_grp-obj-price.gop-id ,
      buf_grp-obj-price.gop-db-num ) .


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mark Dialog-Frame
ON CHOOSE OF B-mark IN FRAME Dialog-Frame /* * */
DO:
    if available buf_grp-obj-price then do:
      { gbl/markstrn.i buf_grp-obj-price p-rec-list }
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


&Scoped-define SELF-NAME B-mark-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mark-2 Dialog-Frame
ON CHOOSE OF B-mark-2 IN FRAME Dialog-Frame /* * */
DO:
  /**/

    if available buf_db-grp-obj-price then do:
      { gbl/markstrn.i buf_db-grp-obj-price v-rec-list-cli }
        g-log = browse-2db:refresh() .
      if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
          g-log = browse-2db:select-next-row ().
          apply "VALUE-CHANGED" to browse-2db in frame {&frame-name}.
      end.
    end.

    apply "entry" to browse-2db in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-mark-3
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mark-3 Dialog-Frame
ON CHOOSE OF B-mark-3 IN FRAME Dialog-Frame /* * */
DO:
  /**/

    if available buf_db-grp-obj-price then do:
      { gbl/markstrn.i buf_db-grp-obj-price v-rec-list-cli }
        g-log = browse-2db:refresh() .
      if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
          g-log = browse-2db:select-next-row ().
          apply "VALUE-CHANGED" to browse-2db in frame {&frame-name}.
      end.
    end.

    apply "entry" to browse-2db in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-mark-4
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mark-4 Dialog-Frame
ON CHOOSE OF B-mark-4 IN FRAME Dialog-Frame /* * */
DO:
  /**/

    if available buf_db-grp-obj-price then do:
      { gbl/markstrn.i buf_db-grp-obj-price v-rec-list-cli }
        g-log = browse-2db:refresh() .
      if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
          g-log = browse-2db:select-next-row ().
          apply "VALUE-CHANGED" to browse-2db in frame {&frame-name}.
      end.
    end.

    apply "entry" to browse-2db in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-more
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-more Dialog-Frame
ON CHOOSE OF b-more IN FRAME Dialog-Frame /* >> */
DO:
    if v-full = false then do:
    ASSIGN frame {&frame-name}:WIDTH   = 101.50 .
    display {&hide-list} with FRAME {&frame-name} no-error .

      v-full = true .
    end.
    else do:
    HIDE {&hide-list} IN FRAME {&frame-name} .
    ASSIGN frame {&frame-name}:WIDTH   = 51.50 .
    v-full = false  .
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-price-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-price-type Dialog-Frame
ON CHOOSE OF B-price-type IN FRAME Dialog-Frame /* ТПЛ */
DO:
  define variable g#log   as logical   no-undo .
  define variable v-recid as character no-undo .

      assign v-recid = string(RECID (buf_grp-obj-price)) .

      find first buf_obj-grp-obj-price
      where buf_obj-grp-obj-price.gop-id     = buf_grp-obj-price.gop-id
        and buf_obj-grp-obj-price.gop-db-num = buf_grp-obj-price.gop-db-num
        and buf_obj-grp-obj-price.obj-type   = v-cntxt-obj-type
        and buf_obj-grp-obj-price.obj-code   = v-cntxt-obj-code
        and buf_obj-grp-obj-price.stts       = 0
        no-error.
      if available buf_obj-grp-obj-price then do:
        run ref/typepric.w (
                input parParentProc     ,
                input "mode=gop-id,b-del,b-chg" ,
                input-output v-recid
                ) no-error .
      end.
      else do:
        { gbl/chk-actg.i
          v-cntxt-db-num
          v-cntxt-userid
          {&action-head-code-main}
          'actn_documents_all':U
          {&cntxt-global}
          0
          '':U
          0
          0
          0
          0
          true
          g#log
        }
        if g#log = true
        then do:
          run ref/typepric.w (
                  input parParentProc     ,
                  input "mode=gop-id,b-del,b-chg" ,
                  input-output v-recid
                  ) no-error .
        end.
      end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-print Dialog-Frame
ON CHOOSE OF B-print IN FRAME Dialog-Frame /* Печать */
DO:
  /* */
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-sel Dialog-Frame
ON CHOOSE OF B-sel IN FRAME Dialog-Frame /* Выбор */
DO:
  /**/
    if ( available buf_grp-obj-price ) AND ( p-rec-list = "" ) then
    p-rec-list = string( recid( buf_grp-obj-price ) ) .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BROWSE-1grp
&Scoped-define SELF-NAME BROWSE-1grp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BROWSE-1grp Dialog-Frame
ON ROW-entry OF BROWSE-1grp IN FRAME Dialog-Frame /* Группы объектов */
DO:

  if v-cntxt-db-num <> 0 then do :
    if buf_grp-obj-price.gop-db-num <> v-cntxt-db-num then do:
     /* message substitute(" Группа создана в другой БД (&1) , корректировать ее в текущей БД нельзя !" , buf_grp-obj-price.gop-db-num ) .*/
      return no-apply.
    end.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BROWSE-1grp Dialog-Frame
ON VALUE-CHANGED OF BROWSE-1grp IN FRAME Dialog-Frame /* Группы объектов */
DO:
  {&OPEN-QUERY-BROWSE-2db}
  {&OPEN-QUERY-BROWSE-3frm}
  {&OPEN-QUERY-BROWSE-4obj}
  {&OPEN-QUERY-BROWSE-5all}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME R-status
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL R-status Dialog-Frame
ON VALUE-CHANGED OF R-status IN FRAME Dialog-Frame
DO:
   ASSIGN R-status .
  {&OPEN-QUERY-BROWSE-1grp}
  {&OPEN-QUERY-BROWSE-2db}
  {&OPEN-QUERY-BROWSE-3frm}
  {&OPEN-QUERY-BROWSE-4obj}
  {&OPEN-QUERY-BROWSE-5all}

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
/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
{ gbl/srt-clmn.i
  &browse-name          = "BROWSE-5all"
  &frame-name           = "{&frame-name}"
  &table-name           = "x_obj-grp-obj-price"
  &label-clmn_1         = "'Объект'"
  &label-clmn_2         = "'Имя объекта'"
  &label-clmn_3         = "'Фирма'"
  &label-clmn_4         = "'БД'"
  &label-clmn_5         = "'Статус'"
  &sort-clmn_1          = "buf_clients.obj-code"
  &sort-clmn_2          = "buf_clients.obj-name"
  &sort-clmn_3          = "buf_clients.host-code"
  &sort-clmn_4          = "buf_clients.db-num"
  &sort-clmn_5          = "x_obj-grp-obj-price.stts"
  &open-query           = "run open-5all ."
  &open-query-otherwise = "run open-5all . "
  &sort-column-name     = "sort-column-name"
  &re-move-clmn         = "no"
  &mv-brw-default       = "no" }

 buf_clients.db-num:read-only           in browse BROWSE-5all = true .
 buf_grp-obj-price.name-group:resizable in browse BROWSE-1grp   = true .
 buf_clients.obj-name:resizable         in browse BROWSE-5all   = true .
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
   define variable g#log as logical   no-undo .
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_ref-mpl_lookup':U
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
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_ref-mpl_update':U
    {&cntxt-global}
    v-cntxt-host-code-obj
    v-cntxt-obj-type
    v-cntxt-obj-code
    0
    0
    0
    false
    g#log
  }
  if not g#log then buf_grp-obj-price.name:read-only in browse BROWSE-1grp .

  run init-5obj.
  if p-rec-list <> "" and p-rec-list <> ? then run select_one.
  RUN enable_UI.
  disable
     B-sel      when LOOKUP ("b-sel":U,   p-bttns) = 0
     B-add      when LOOKUP ("b-add":U,   p-bttns) = 0
     B-del      when LOOKUP ("b-del":U,   p-bttns) = 0
     B-mark     when LOOKUP ("b-mark":U,  p-bttns) = 0
     B-mark-2   when LOOKUP ("b-mark-2":U,p-bttns) = 0
     B-add-DB   when LOOKUP ("b-add":U,   p-bttns) = 0
     B-del-DB   when LOOKUP ("b-del":U,   p-bttns) = 0
     B-mark-3   when LOOKUP ("b-mark-3":U,p-bttns) = 0
     B-add-frm  when LOOKUP ("b-add":U,   p-bttns) = 0
     B-del-frm  when LOOKUP ("b-del":U,   p-bttns) = 0
     B-mark-4   when LOOKUP ("b-mark-4":U,p-bttns) = 0
     B-add-obj  when LOOKUP ("b-add":U,   p-bttns) = 0
     B-del-obj  when LOOKUP ("b-del":U,   p-bttns) = 0

  with frame {&frame-name} .

  if lookup ("b-add":U,   p-bttns) = 0 then v-full = true  .
                                       else v-full = false  .
  apply "CHOOSE" to b-more IN FRAME Dialog-Frame .
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
  DISPLAY R-status FILL-IN-1 F-obj
      WITH FRAME Dialog-Frame.
  ENABLE B-Cancel RECT-1 B-sel B-add B-del B-price-type b-more B-history
         B-print B-Help R-status B-mark B-find-obj B-all B-mark-2 B-add-DB
         B-del-DB B-mark-3 B-add-frm B-del-frm BROWSE-1grp BROWSE-2db
         BROWSE-3frm BROWSE-5all B-mark-4 B-add-obj B-del-obj BROWSE-4obj
         FILL-IN-1 F-obj
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-5obj Dialog-Frame
PROCEDURE init-5obj :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
run waitfram-show in this-procedure  ( "Сбор объектов по группам...." ) .
define buffer buf1_clients for ub.clients  .

for each  x_obj-grp-obj-price : delete x_obj-grp-obj-price. end.


for each buf_db-grp-obj-price  no-lock :

  for each buf1_clients no-lock where
           buf1_clients.db-num = buf_db-grp-obj-price.dgo-db-num and
           buf1_clients.stts = 0 :
    create x_obj-grp-obj-price .
    assign
      x_obj-grp-obj-price.gop-db-num = buf_db-grp-obj-price.gop-db-num
      x_obj-grp-obj-price.gop-id     = buf_db-grp-obj-price.gop-id
      x_obj-grp-obj-price.obj-code   = buf1_clients.obj-code
      x_obj-grp-obj-price.obj-type   = buf1_clients.obj-type
      x_obj-grp-obj-price.stts       = buf_db-grp-obj-price.stts
    .
  end.
end.


for each buf_host-grp-obj-price no-lock :
  for each buf1_clients no-lock where
           buf1_clients.host-code = buf_host-grp-obj-price.host-code and
           buf1_clients.stts      = 0 :
      find first x_obj-grp-obj-price no-lock  where
                 x_obj-grp-obj-price.gop-db-num = buf_host-grp-obj-price.gop-db-num and
                 x_obj-grp-obj-price.gop-id     = buf_host-grp-obj-price.gop-id and
                 x_obj-grp-obj-price.obj-code   = buf1_clients.obj-code and
                 x_obj-grp-obj-price.obj-type   = buf1_clients.obj-type no-error .
      if not available  x_obj-grp-obj-price then   create x_obj-grp-obj-price .
      assign
        x_obj-grp-obj-price.gop-db-num = buf_host-grp-obj-price.gop-db-num
        x_obj-grp-obj-price.gop-id     = buf_host-grp-obj-price.gop-id
        x_obj-grp-obj-price.obj-code   = buf1_clients.obj-code
        x_obj-grp-obj-price.obj-type   = buf1_clients.obj-type
      .
  end.
end.

for each buf_obj-grp-obj-price no-lock :
  for each buf1_clients no-lock where
            buf1_clients.obj-type = buf_obj-grp-obj-price.obj-type and
            buf1_clients.obj-code = buf_obj-grp-obj-price.obj-code and
            buf1_clients.stts = 0:
      find first  x_obj-grp-obj-price no-lock  where
                  x_obj-grp-obj-price.gop-db-num = buf_obj-grp-obj-price.gop-db-num and
                  x_obj-grp-obj-price.gop-id     = buf_obj-grp-obj-price.gop-id and
                  x_obj-grp-obj-price.obj-code   = buf1_clients.obj-code and
                  x_obj-grp-obj-price.obj-type   = buf1_clients.obj-type no-error .
      if not available  x_obj-grp-obj-price then   create x_obj-grp-obj-price .
      assign
        x_obj-grp-obj-price.gop-db-num = buf_obj-grp-obj-price.gop-db-num
        x_obj-grp-obj-price.gop-id     = buf_obj-grp-obj-price.gop-id
        x_obj-grp-obj-price.obj-code   = buf1_clients.obj-code
        x_obj-grp-obj-price.obj-type   = buf1_clients.obj-type
      .
  end.
end.

for each x_obj-grp-obj-price :
  run ver-stts in this-procedure (
    input x_obj-grp-obj-price.gop-db-num ,
    input x_obj-grp-obj-price.gop-id     ,
    input x_obj-grp-obj-price.obj-code   ,
    input x_obj-grp-obj-price.obj-type   ,
    output x_obj-grp-obj-price.stts
    ).
end.

run open-5all in this-procedure .
run waitfram-hide in this-procedure .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE m-tt Dialog-Frame
PROCEDURE m-tt :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
 define variable v-user-select as logical   no-undo .

    { gbl/uobjsone.i
      parparentproc
      v-cntxt-db-num
      v-cntxt-userid
      v-cntxt-host-code-obj
      v-cntxt-obj-type
      v-cntxt-obj-code
      v-user-select
      v-obj-type
      v-obj-code
       }
    if v-user-select = false
    then do:
      v-obj-type = ""  .
      v-obj-code = ?   .

    end.

  tt-grp-obj = "".
  for each x_obj-grp-obj-price  where
           x_obj-grp-obj-price.stts = 0 and
           x_obj-grp-obj-price.obj-type = v-obj-type and
           x_obj-grp-obj-price.obj-code = v-obj-code :
           tt-grp-obj = tt-grp-obj + string(x_obj-grp-obj-price.gop-id ) + ";"  + string (x_obj-grp-obj-price.gop-db-num) + "," .
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE open-5all Dialog-Frame
PROCEDURE open-5all :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/

 case sort-column-name :
  when ""  then do:
    OPEN QUERY BROWSE-5all  {&QUERY-STRING-BROWSE-5all} .
  end.
  when "buf_clients.obj-code"  then do:
    OPEN QUERY BROWSE-5all  {&QUERY-STRING-BROWSE-5all} by buf_clients.obj-code.
  end.
  when "buf_clients.obj-name"  then do:
    OPEN QUERY BROWSE-5all  {&QUERY-STRING-BROWSE-5all} by buf_clients.obj-name.
  end.
  when "buf_clients.host-code"  then do:
    OPEN QUERY BROWSE-5all  {&QUERY-STRING-BROWSE-5all} by buf_clients.host-code.
  end.
  when "buf_clients.db-num"  then do:
    OPEN QUERY BROWSE-5all  {&QUERY-STRING-BROWSE-5all} by buf_clients.db-num.
  end.
  when "x_obj-grp-obj-price.stts"  then do:
    OPEN QUERY BROWSE-5all  {&QUERY-STRING-BROWSE-5all} by x_obj-grp-obj-price.stts.
  end.
 end case.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-add-db Dialog-Frame
PROCEDURE proc-add-db :
define input  parameter p-recid-db as recid no-undo .
define input  parameter p-db-num  as integer   no-undo .
define input  parameter p-id     as integer   no-undo .
define input  parameter p-name as character no-undo .
define input-output parameter p-recid as recid no-undo .

define buffer buf_db for ub.db  .

find buf_db no-lock where recid(buf_db) = p-recid-db no-error .

run obji-ADD (
 input  p-db-num        ,
 input  p-id            ,
 input  buf_db.db-num    ,
 input  0               ,
 input  v-cntxt-db-num  ,
 input  v-cntxt-userid  ,
 output p-recid ) .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-add-firm Dialog-Frame
PROCEDURE proc-add-firm :
define input  parameter p-firm as CHAR no-undo .
define input  parameter p-db-num  as integer   no-undo .
define input  parameter p-id     as integer   no-undo .
define input  parameter p-name as character no-undo .
define input-output parameter p-recid as recid no-undo .

define variable v-i as integer   no-undo .
define variable v-nn as integer   no-undo .
v-nn = num-entries(p-firm) .
repeat v-i = 1 to v-nn :
    run objf-ADD (
    input  p-db-num        ,
    input  p-id            ,
    input  integer(entry(v-i , p-firm ))   ,
    input  0               ,
    input  v-cntxt-db-num  ,
    input  v-cntxt-userid  ,
    output p-recid ) .
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ver-stts Dialog-Frame
PROCEDURE ver-stts :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
define input  parameter p-gop-db-num as integer   no-undo .
define input  parameter p-gop-id     as integer   no-undo .
define input  parameter p-obj-code   as integer   no-undo .
define input  parameter p-obj-type   as character no-undo .
define output parameter p-stts       as integer   no-undo .

define variable v-1 as logical   no-undo init false .
define variable v-2 as logical   no-undo init false.
define variable v-3 as logical   no-undo init false.
define buffer buf_CLIENTS for ub.clients  .

find first buf_clients no-lock where
            buf_clients.obj-type = p-obj-type and
            buf_clients.obj-code = p-obj-code
             no-error .

define buffer buf_db-grp-obj-price for ub.db-grp-obj-price  .
  find first buf_db-grp-obj-price no-lock where
             buf_db-grp-obj-price.gop-db-num = p-gop-db-num  and
             buf_db-grp-obj-price.gop-id     = p-gop-id      and
             buf_db-grp-obj-price.dgo-db-num    = buf_clients.db-num   and
             buf_db-grp-obj-price.stts       = {&bef-current-status-int}  no-error .
if available buf_db-grp-obj-price then v-1 = true .


define buffer buf_host-grp-obj-price for ub.host-grp-obj-price  .
   find first buf_host-grp-obj-price no-lock where
              buf_host-grp-obj-price.gop-db-num = p-gop-db-num  and
              buf_host-grp-obj-price.gop-id     = p-gop-id      and
              buf_host-grp-obj-price.host-code  = buf_clients.host-code  and
              buf_host-grp-obj-price.stts       = {&bef-current-status-int}  no-error .
 if available buf_host-grp-obj-price then v-2 = true .

define buffer buf_obj-grp-obj-price for ub.obj-grp-obj-price  .
  find first buf_obj-grp-obj-price no-lock where
             buf_obj-grp-obj-price.gop-db-num = p-gop-db-num  and
             buf_obj-grp-obj-price.gop-id     = p-gop-id      and
             buf_obj-grp-obj-price.obj-code   = buf_clients.obj-code    and
             buf_obj-grp-obj-price.obj-type   = buf_clients.obj-type    and
             buf_obj-grp-obj-price.stts       = {&bef-current-status-int}  no-error .
if available buf_obj-grp-obj-price then v-3 = true .


if v-1 or v-2 or  v-3  then p-stts = {&bef-current-status-int} .
                       else p-stts = {&bef-deleted-status-int} .


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE select_one W-Win
PROCEDURE select_one :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
define buffer bufl_grp-obj-price for ub.grp-obj-price  .
find first bufl_grp-obj-price no-lock  where recid(bufl_grp-obj-price) = int(p-rec-list) no-error .
if error-status :error then return .
  g-find = true  .
  F-obj = bufl_grp-obj-price.name-group .
  tt-grp-obj = string(bufl_grp-obj-price.gop-id ) + ";"  + string (bufl_grp-obj-price.gop-db-num) .
  display F-obj  with frame {&frame-name} .
  {&OPEN-QUERY-BROWSE-1grp}
  {&OPEN-QUERY-BROWSE-2db}
  {&OPEN-QUERY-BROWSE-3frm}
  {&OPEN-QUERY-BROWSE-4obj}
  {&OPEN-QUERY-BROWSE-5all}

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME