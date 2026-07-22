&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v9r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE NEW SHARED BUFFER buf_buyer-group FOR ub.buyer-group.
DEFINE BUFFER buf_buyer-in-buyer-group FOR ub.buyer-in-buyer-group.
DEFINE BUFFER buf_clients FOR ub.clients.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Справочник групп покупателей

Автор: Чернова Светлана Александровна
Дата создания: 11/10/05
Author: Svetlana Chernova
Creation date: 11/10/05

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input  parameter parParentProc as handle no-undo .
define input  parameter p-bttns       as character no-undo .
define input-output parameter p-rec-list    as character no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Справочник групп покупателей для ценообразованиЯ ".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i  }
{ cmp/library.i }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
{ gbl/waitfram.i }
{ ref/bib-ad.i   }
{ gbl/usrfulnf.i }

/* Local Variable Definitions ---                                       */
define variable v-sec          as integer   no-undo .
define variable v-rec-list-cli as character no-undo .
define variable g-log          as logical   no-undo .
define variable g-find         as logical   no-undo init false .
define variable v-obj-type     as character no-undo .
define variable v-obj-code     as integer   no-undo .
define variable  tt-buyer-group as character no-undo .
define variable r-find  as logical   no-undo init false .
define variable find-id as integer   no-undo .
define variable find-db as integer   no-undo .


function mark-string returns character
  ( buffer loc-table for ub.buyer-group, input mark-list as character  ) :
  return ( if lookup( string( recid( loc-table ) ), mark-list ) > 0 then "*" else "":U ).
end function.

function mark-string-2 returns character
  ( buffer loc-table for ub.buyer-in-buyer-group , input mark-list as character  ) :
  return ( if lookup( string( recid( loc-table ) ), mark-list ) > 0 then "*" else "":U ).
end function.

function stts-string-2 returns character
  ( buffer loc-table for ub.buyer-in-buyer-group   ) :
&scop status-code string(loc-table.stts)
return {&status-int-name} .
end function.

function stts-string returns character
  ( buffer loc-table for ub.buyer-group   ) :
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
&Scoped-define EXTERNAL-TABLES buf_buyer-group
&Scoped-define FIRST-EXTERNAL-TABLE buf_buyer-group


/* Need to scope the external tables to this procedure                  */
DEFINE QUERY external_tables FOR buf_buyer-group.
/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES buf_buyer-group buf_buyer-in-buyer-group ~
buf_clients

/* Definitions for BROWSE BROWSE-1grp                                   */
&Scoped-define FIELDS-IN-QUERY-BROWSE-1grp mark-string(buffer buf_buyer-group, p-rec-list) stts-string(buffer buf_buyer-group) buf_buyer-group.name buf_buyer-group.oborot "Оборот перехода!в другую группу" IF buf_buyer-group.gop-id > 0 THEN String(buf_buyer-group.gop-id) + "(" + string(buf_buyer-group.gop-db-num) + ")" ELSE "" String(buf_buyer-group.bgr-id) + "(" + string(buf_buyer-group.bgr-db-num) + ")" buf_buyer-group.sys-date buf_buyer-group.sys-time-chr usrfulnf(buf_buyer-group.who) buf_buyer-group.db-num-chg
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-1grp
&Scoped-define SELF-NAME BROWSE-1grp
&Scoped-define QUERY-STRING-BROWSE-1grp FOR EACH buf_buyer-group WHERE     ( r-status = 2 OR buf_buyer-group.stts =  r-status )      AND    ( g-find = NO OR      LOOKUP (STRING (buf_buyer-group.bgr-id) + ";"  + string(buf_buyer-group.bgr-db-num)  , ~
       tt-buyer-group ) > 0 )      and      ( r-find = no or (buf_buyer-group.bgr-db-num = find-db and      buf_buyer-group.bgr-id = find-id ))       BY buf_buyer-group.oborot BY buf_buyer-group.NAME
&Scoped-define OPEN-QUERY-BROWSE-1grp OPEN QUERY {&SELF-NAME} FOR EACH buf_buyer-group WHERE     ( r-status = 2 OR buf_buyer-group.stts =  r-status )      AND    ( g-find = NO OR      LOOKUP (STRING (buf_buyer-group.bgr-id) + ";"  + string(buf_buyer-group.bgr-db-num)  , ~
       tt-buyer-group ) > 0 )      and      ( r-find = no or (buf_buyer-group.bgr-db-num = find-db and      buf_buyer-group.bgr-id = find-id ))       BY buf_buyer-group.oborot BY buf_buyer-group.NAME .
&Scoped-define TABLES-IN-QUERY-BROWSE-1grp buf_buyer-group
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-1grp buf_buyer-group


/* Definitions for BROWSE BROWSE-2cli                                   */
&Scoped-define FIELDS-IN-QUERY-BROWSE-2cli mark-string-2(buffer buf_buyer-in-buyer-group, v-rec-list-cli) stts-string-2(buffer buf_buyer-in-buyer-group) buf_buyer-in-buyer-group.bbg-obj-code buf_buyer-in-buyer-group.bbg-obj-type buf_clients.obj-name buf_buyer-in-buyer-group.sys-date buf_buyer-in-buyer-group.sys-time-chr usrfulnf(buf_buyer-in-buyer-group.who) buf_buyer-in-buyer-group.db-num-chg buf_clients.grp-name
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-2cli
&Scoped-define SELF-NAME BROWSE-2cli
&Scoped-define QUERY-STRING-BROWSE-2cli FOR EACH buf_buyer-in-buyer-group OF buf_buyer-group      WHERE ( r-status = 2 OR buf_buyer-in-buyer-group.stts =  r-status )       NO-LOCK , ~
             EACH buf_clients WHERE buf_clients.obj-code = buf_buyer-in-buyer-group.bbg-obj-code                          AND buf_clients.obj-type = buf_buyer-in-buyer-group.bbg-obj-type                              NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-BROWSE-2cli OPEN QUERY {&SELF-NAME} FOR EACH buf_buyer-in-buyer-group OF buf_buyer-group      WHERE ( r-status = 2 OR buf_buyer-in-buyer-group.stts =  r-status )       NO-LOCK , ~
             EACH buf_clients WHERE buf_clients.obj-code = buf_buyer-in-buyer-group.bbg-obj-code                          AND buf_clients.obj-type = buf_buyer-in-buyer-group.bbg-obj-type                              NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-BROWSE-2cli buf_buyer-in-buyer-group ~
buf_clients
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-2cli buf_buyer-in-buyer-group
&Scoped-define SECOND-TABLE-IN-QUERY-BROWSE-2cli buf_clients


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BROWSE-1grp}~
    ~{&OPEN-QUERY-BROWSE-2cli}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-Cancel B-sel B-add B-chg B-del ~
B-price-type B-history B-print B-Help R-status B-mark-2 B-add-2 B-del-2 ~
B-mark B-find-obj B-all BROWSE-1grp BROWSE-2cli FILL-IN-1 F-obj
&Scoped-Define DISPLAYED-OBJECTS R-status FILL-IN-1 F-obj

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-add
     LABEL "Добавить"
     SIZE 10 BY 1 TOOLTIP "Добавить группу"
     BGCOLOR 8 .

DEFINE BUTTON B-add-2
     LABEL "Добавить"
     SIZE 10 BY 1 TOOLTIP "Добавить покупателя"
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

DEFINE BUTTON B-chg
     LABEL "Изменить"
     SIZE 10 BY 1 TOOLTIP "Изменить группу"
     BGCOLOR 8 .

DEFINE BUTTON B-del
     LABEL "Удалить"
     SIZE 10 BY 1 TOOLTIP "Удалить группу"
     BGCOLOR 8 .

DEFINE BUTTON B-del-2
     LABEL "Удалить"
     SIZE 10 BY 1 TOOLTIP "Удалить покупателя"
     BGCOLOR 8 .

DEFINE BUTTON B-find-obj
     IMAGE-UP FILE "cmp/select.bmp":U
     LABEL ""
     SIZE 3 BY 1 TOOLTIP "Поиск по Покупателю".

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
     SIZE 3.25 BY 1 TOOLTIP "Отметить группу"
     BGCOLOR 8 .

DEFINE BUTTON B-mark-2
     LABEL "*"
     SIZE 3.25 BY 1 TOOLTIP "Отметить покупателя"
     BGCOLOR 8 .

DEFINE BUTTON B-price-type
     LABEL "&ТПЛ"
     SIZE 6 BY 1 TOOLTIP "Список типов ПЛ по группе покупателей".

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

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BROWSE-1grp FOR
      buf_buyer-group SCROLLING.

DEFINE QUERY BROWSE-2cli FOR
      buf_buyer-in-buyer-group,
      buf_clients SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BROWSE-1grp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-1grp Dialog-Frame _FREEFORM
  QUERY BROWSE-1grp NO-LOCK DISPLAY
      mark-string(buffer buf_buyer-group, p-rec-list) COLUMN-LABEL "*! " FORMAT "x(1)":U
      stts-string(buffer buf_buyer-group) COLUMN-LABEL "Ста!тус" FORMAT "x(3)":U
      buf_buyer-group.name COLUMN-LABEL "Название группы!покупателей" FORMAT "X(80)":U
      buf_buyer-group.oborot   COLUMN-LABEL   "Оборот перехода!в другую группу" FORMAT "->>>,>>>,>>>,>>9.99":U
      IF buf_buyer-group.gop-id > 0 THEN String(buf_buyer-group.gop-id) + "(" + string(buf_buyer-group.gop-db-num) + ")" ELSE "" COLUMN-LABEL "Переходит!в группу" FORMAT "x(13)":U
      String(buf_buyer-group.bgr-id) + "(" + string(buf_buyer-group.bgr-db-num) + ")" COLUMN-LABEL "Код группы" FORMAT "x(10)":U
      buf_buyer-group.sys-date COLUMN-LABEL "Дата!изменения" FORMAT "99/99/99":U
      buf_buyer-group.sys-time-chr COLUMN-LABEL "Время!изменения" FORMAT "X(5)":U
      usrfulnf(buf_buyer-group.who) COLUMN-LABEL "Кто!изменял" FORMAT "X(15)":U
      buf_buyer-group.db-num-chg COLUMN-LABEL "БД!изм" FORMAT ">>>>9":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 48.13 BY 19
         TITLE "Группы покупателей" FIT-LAST-COLUMN.

DEFINE BROWSE BROWSE-2cli
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-2cli Dialog-Frame _FREEFORM
  QUERY BROWSE-2cli NO-LOCK DISPLAY
      mark-string-2(buffer buf_buyer-in-buyer-group, v-rec-list-cli) COLUMN-LABEL "*! " FORMAT "x(1)":U
      stts-string-2(buffer buf_buyer-in-buyer-group) COLUMN-LABEL "Ста!тус" FORMAT "x(3)":U
      buf_buyer-in-buyer-group.bbg-obj-code COLUMN-LABEL "Код" FORMAT ">>>>>>>>9":U
      buf_buyer-in-buyer-group.bbg-obj-type COLUMN-LABEL "Тип" FORMAT "X(3)":U
      buf_clients.obj-name COLUMN-LABEL "Наименование " FORMAT "X(40)":U  WIDTH 20
      buf_buyer-in-buyer-group.sys-date COLUMN-LABEL "Дата!изменения" FORMAT "99/99/99":U
      buf_buyer-in-buyer-group.sys-time-chr COLUMN-LABEL "Время!изм" FORMAT "X(5)":U
      usrfulnf(buf_buyer-in-buyer-group.who) COLUMN-LABEL "Кто!изменял" FORMAT "X(15)":U
      buf_buyer-in-buyer-group.db-num-chg COLUMN-LABEL "БД!изм" FORMAT ">>>>9":U
      buf_clients.grp-name COLUMN-LABEL "Название группы клиентов" FORMAT "X(40)":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 50.5 BY 19
         TITLE "Покупатели в группе" FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-Cancel AT ROW 1 COL 1
     B-sel AT ROW 1 COL 11
     B-add AT ROW 1 COL 21
     B-chg AT ROW 1 COL 31 WIDGET-ID 2
     B-del AT ROW 1 COL 41
     B-price-type AT ROW 1 COL 51
     B-history AT ROW 1 COL 69.75
     B-print AT ROW 1 COL 79.75
     B-Help AT ROW 1 COL 90
     R-status AT ROW 2.29 COL 9.63 NO-LABEL
     B-mark-2 AT ROW 2.92 COL 49.75
     B-add-2 AT ROW 2.92 COL 53
     B-del-2 AT ROW 2.92 COL 63
     B-mark AT ROW 3 COL 1.75
     B-find-obj AT ROW 3.04 COL 5.13
     B-all AT ROW 3.04 COL 8.25
     BROWSE-1grp AT ROW 4 COL 1.38
     BROWSE-2cli AT ROW 4 COL 49.5
     FILL-IN-1 AT ROW 2.25 COL 2 NO-LABEL
     F-obj AT ROW 3.29 COL 9.5 COLON-ALIGNED NO-LABEL
     SPACE(74.88) SKIP(19.30)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Группы покупателей для ценообразования"
         DEFAULT-BUTTON B-sel CANCEL-BUTTON B-Cancel.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   External Tables: Temp-Tables.buf_buyer-group
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: buf_buyer-group B "NEW SHARED" ? ub ub.buyer-group
      TABLE: buf_buyer-in-buyer-group B "?" ? ub ub.buyer-in-buyer-group
      TABLE: buf_clients B "?" ? ub ub.clients
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BROWSE-1grp B-all Dialog-Frame */
/* BROWSE-TAB BROWSE-2cli BROWSE-1grp Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN FILL-IN-1 IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-1grp
/* Query rebuild information for BROWSE BROWSE-1grp
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH buf_buyer-group WHERE
    ( r-status = 2 OR buf_buyer-group.stts =  r-status )
     AND
   ( g-find = NO OR
     LOOKUP (STRING (buf_buyer-group.bgr-id) + ";"  + string(buf_buyer-group.bgr-db-num)  , tt-buyer-group ) > 0 )
     and
     ( r-find = no or (buf_buyer-group.bgr-db-num = find-db and
     buf_buyer-group.bgr-id = find-id ))


    BY buf_buyer-group.oborot BY buf_buyer-group.NAME .
     _END_FREEFORM
     _Options          = "NO-LOCK"
     _Query            is OPENED
*/  /* BROWSE BROWSE-1grp */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-2cli
/* Query rebuild information for BROWSE BROWSE-2cli
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH buf_buyer-in-buyer-group OF buf_buyer-group
     WHERE ( r-status = 2 OR buf_buyer-in-buyer-group.stts =  r-status )
      NO-LOCK ,
      EACH buf_clients WHERE buf_clients.obj-code = buf_buyer-in-buyer-group.bbg-obj-code
                         AND buf_clients.obj-type = buf_buyer-in-buyer-group.bbg-obj-type
                             NO-LOCK INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _TblOptList       = ","
     _JoinCode[2]      = "buf_clients.obj-code = buf_buyer-in-buyer-group.bbg-obj-code
  AND buf_clients.obj-type = buf_buyer-in-buyer-group.bbg-obj-type"
     _Query            is OPENED
*/  /* BROWSE BROWSE-2cli */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Группы покупателей для ценообразования */
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
  run ref/gr-bupra.w (input parparentproc,input {&add-def} , input-output v-rec-id) .
  {&OPEN-QUERY-BROWSE-1grp}
  reposition BROWSE-1grp to recid v-rec-id no-error .
  apply "VALUE-CHANGED" to browse-1grp in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-add-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-add-2 Dialog-Frame
ON CHOOSE OF B-add-2 IN FRAME Dialog-Frame /* Добавить */
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
if not available buf_buyer-group then return .
if buf_buyer-group.stts <> 0 then do:
   message "В эту группу добавлять покупателей нельзя!" view-as alert-box error .
   return .
end.
if v-cntxt-db-num <> 0 then do :
   if buf_buyer-group.bgr-db-num <> v-cntxt-db-num then do:
      message substitute(" Группа создана в другой БД (&1) , корректировать ее в текущей БД нельзя !" , buf_buyer-group.bgr-db-num ) .
      return .
   end.
end.

  run ref/gr-buprb.p (
      input parparentproc ,
      input buf_buyer-group.bgr-db-num ,
      input buf_buyer-group.bgr-id      ,
      output v-rec-id) .

  {&OPEN-QUERY-BROWSE-2cli}
  reposition BROWSE-2cli to recid v-rec-id no-error .
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
  {&OPEN-QUERY-BROWSE-2cli}

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

IF NOT AVAILABLE buf_buyer-group THEN RETURN.
  if buf_buyer-group.stts <> 0 then do:
     message "Группа удалена!" view-as alert-box information .
     return.
  end.

if v-cntxt-db-num <> 0 then do :
   if buf_buyer-group.bgr-db-num <> v-cntxt-db-num then do:
      message substitute(" Группа создана в другой БД (&1) , корректировать ее в текущей БД нельзя !" , buf_buyer-group.bgr-db-num ) .
      return .
   end.
end.

define variable v-rec-id as recid no-undo .
v-rec-id = RECID( buf_buyer-group ).
  run ref/gr-bupra.w (input parparentproc,input {&UPDATE} , input-output v-rec-id) .
  {&OPEN-QUERY-BROWSE-1grp}
  reposition BROWSE-1grp to recid v-rec-id no-error .
  apply "VALUE-CHANGED" to browse-1grp in frame {&frame-name}.
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

  if not available buf_buyer-group then return .
  if buf_buyer-group.stts <> 0 then do:
     message "Группа уже удалена" view-as alert-box information .
     return.
  end.
  message "Удалять группу " buf_buyer-group.name "?"
          view-as alert-box question
          buttons yes-no update g-ok as log.
  if not g-ok then return .
  run ref/gr-budel.p (
      input parparentproc ,
      input buf_buyer-group.bgr-db-num ,
      input buf_buyer-group.bgr-id      )
      no-error .
 if error-status :error then return no-apply .

 {&OPEN-QUERY-BROWSE-1grp}
 {&OPEN-QUERY-BROWSE-2cli}


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-del-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-del-2 Dialog-Frame
ON CHOOSE OF B-del-2 IN FRAME Dialog-Frame /* Удалить */
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

  if not available buf_buyer-in-buyer-group then return .
  if buf_buyer-in-buyer-group.stts <> 0 then do:
     message "Покупатель уже исключен из Группы" view-as alert-box information .
     return.
  end.
  run bib-del (
     input   buf_buyer-in-buyer-group.bgr-db-num
    ,input   buf_buyer-in-buyer-group.bgr-id
    ,input   buf_buyer-in-buyer-group.bbg-obj-code
    ,input   buf_buyer-in-buyer-group.bbg-obj-type
    ,input   v-cntxt-db-num
    ,input   v-cntxt-userid
    ,input-output   v-sec
    ) .
  {&OPEN-QUERY-BROWSE-2cli}


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-find-obj
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-find-obj Dialog-Frame
ON CHOOSE OF B-find-obj IN FRAME Dialog-Frame
DO:
  g-find = true  .
  run m-tt in this-procedure .
  F-obj = v-obj-type + " " +  string(v-obj-code) .
  display F-obj  with frame {&frame-name} .
  {&OPEN-QUERY-BROWSE-1grp}
  {&OPEN-QUERY-BROWSE-2cli}

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-history
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-history Dialog-Frame
ON CHOOSE OF B-history IN FRAME Dialog-Frame /* История */
DO:

  if not available buf_buyer-group then return .
  run ref/cgr-buy.w (
      parParentProc ,
      buf_buyer-group.bgr-id ,
      buf_buyer-group.bgr-db-num ) .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mark Dialog-Frame
ON CHOOSE OF B-mark IN FRAME Dialog-Frame /* * */
DO:
    if available buf_buyer-group then do:
      { gbl/markstrn.i buf_buyer-group p-rec-list }
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

    if available buf_buyer-in-buyer-group then do:
      { gbl/markstrn.i buf_buyer-in-buyer-group v-rec-list-cli }
        g-log = browse-2cli:refresh() .
      if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
          g-log = browse-2cli:select-next-row ().
          apply "VALUE-CHANGED" to browse-2cli in frame {&frame-name}.
      end.
    end.

    apply "entry" to browse-2cli in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-price-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-price-type Dialog-Frame
ON CHOOSE OF B-price-type IN FRAME Dialog-Frame /* ТПЛ */
DO:
  define variable v-recid as character no-undo .
  v-recid = string(RECID (buf_buyer-group)) .
  run ref/typepric.w (
          input parParentProc     ,
          input "mode=bgr-id,b-del,b-chg" ,
          input-output v-recid
          ) no-error .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-print Dialog-Frame
ON CHOOSE OF B-print IN FRAME Dialog-Frame /* Печать */
DO:
if not available buf_buyer-group then return .
  run rep/g-prcus.p
  ( parParentProc ,
    recid( buf_buyer-group )
  ).

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-sel Dialog-Frame
ON CHOOSE OF B-sel IN FRAME Dialog-Frame /* Выбор */
DO:
  /**/
    if ( available buf_buyer-group ) AND ( p-rec-list = "" ) then
    p-rec-list = string( recid( buf_buyer-group ) ) .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BROWSE-1grp
&Scoped-define SELF-NAME BROWSE-1grp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BROWSE-1grp Dialog-Frame
ON VALUE-CHANGED OF BROWSE-1grp IN FRAME Dialog-Frame /* Группы покупателей */
DO:
  {&OPEN-QUERY-BROWSE-2cli}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME R-status
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL R-status Dialog-Frame
ON VALUE-CHANGED OF R-status IN FRAME Dialog-Frame
DO:
    ASSIGN R-status .
  {&OPEN-QUERY-BROWSE-1grp}
  {&OPEN-QUERY-BROWSE-2cli}
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
{ gbl/diasize.i  &browse-name="browse-1grp" }
run diasize_add_browse in this-procedure
  (input  'HEIGHT':U
  ,input  browse browse-2cli :handle
  ) .
run diasize_init in this-procedure .

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
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

   buf_buyer-group.name:resizable in browse browse-1grp = true .
   buf_buyer-group.oborot:resizable in browse browse-1grp = true .
   buf_clients.obj-name:resizable in browse browse-2cli = true .
   buf_buyer-group.name:width  in browse browse-1grp = 20 .
   buf_buyer-group.oborot:width  in browse browse-1grp = 15 .
   buf_clients.obj-name:width in browse browse-2cli = 20 .

  if p-rec-list <> "" and p-rec-list <> ? then run select_one .

  RUN enable_UI.

  disable
     B-sel    when LOOKUP ("b-sel":U,      p-bttns) = 0
     B-add    when LOOKUP ("b-add":U,      p-bttns) = 0
     B-chg    when LOOKUP ("b-chg":U,      p-bttns) = 0
     B-del    when LOOKUP ("b-del":U,      p-bttns) = 0
     B-add-2  when LOOKUP ("b-add":U,      p-bttns) = 0
     B-del-2  when LOOKUP ("b-del":U,      p-bttns) = 0
     B-mark-2 when LOOKUP ("b-mark-2":U,   p-bttns) = 0
     B-mark   when LOOKUP ("b-mark":U,     p-bttns) = 0
  with frame {&frame-name} .
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
  ENABLE B-Cancel B-sel B-add B-chg B-del B-price-type B-history B-print B-Help
         R-status B-mark-2 B-add-2 B-del-2 B-mark B-find-obj B-all BROWSE-1grp
         BROWSE-2cli FILL-IN-1 F-obj
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
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
define variable v-rid-list as character no-undo .
     run ref/cli-all.w
   ( input parparentproc,
     input "b-sel",
     input {&cmp} ,
     input ?      ,
     input ?      ,
     input ?      ,
     input ?      ,
     input ?      ,
     output v-rid-list ).
define buffer buf_clients for ub.clients  .
find first buf_clients no-lock where recid (buf_clients) = integer( v-rid-list) no-error .
if error-status :error then
assign
      v-obj-type = ""
      v-obj-code = ?
.
else
assign
      v-obj-type = buf_clients.obj-type
      v-obj-code = buf_clients.obj-code
.

define buffer b_buyer-in-buyer-group for ub.buyer-in-buyer-group  .
define buffer b_buyer-group          for ub.buyer-group  .

  tt-buyer-group = "".
  for each b_buyer-in-buyer-group  where
          /* b_buyer-in-buyer-group.stts = 0 and*/
           b_buyer-in-buyer-group.bbg-obj-type = v-obj-type and
           b_buyer-in-buyer-group.bbg-obj-code = v-obj-code ,
           first b_buyer-group  no-lock where
                 /*b_buyer-group.stts = 0 and*/
                 b_buyer-group.bgr-id     = b_buyer-in-buyer-group.bgr-id and
                 b_buyer-group.bgr-db-num = b_buyer-in-buyer-group.bgr-db-num
           :
           tt-buyer-group = tt-buyer-group + string ( b_buyer-in-buyer-group.bgr-id ) + ";"  + string ( b_buyer-in-buyer-group.bgr-db-num ) + "," .
  end.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE select_one Dialog-Frame
PROCEDURE select_one :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
define buffer bufl_buyer-group for ub.buyer-group  .

find first bufl_buyer-group no-lock where recid(bufl_buyer-group) = int(p-rec-list) no-error .
if error-status :error then return .
r-find = true .
find-db = bufl_buyer-group.bgr-db-num  .
find-id = bufl_buyer-group.bgr-id      .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME