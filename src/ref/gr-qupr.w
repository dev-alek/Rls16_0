&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v9r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE NEW SHARED BUFFER buf_qnty-group FOR ub.qnty-group.
DEFINE BUFFER buf_qnty-in-qnty-group FOR ub.qnty-in-qnty-group.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Справочник количественных групп

Автор: Чернова Светлана Александровна
Дата создания: 11/10/05
Author: Svetlana Chernova
Creation date: 11/10/05

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input  parameter parParentProc as handle no-undo .
define input  parameter p-bttns as character no-undo .
define input-output parameter p-rec-list as character no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Справочник количественных групп для ценообразования".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i  }
{ cmp/library.i  }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
{ gbl/waitfram.i }
{ ref/qiq-ad.i   }
{ gbl/usrfulnf.i }

/* Local Variable Definitions ---                                       */
define variable r-find  as logical   no-undo init false .
define variable find-id as integer   no-undo .
define variable find-db as integer   no-undo .

define variable v-rec-list-cli as character no-undo .
define variable g-log as logical   no-undo .
function mark-string returns character
  ( buffer loc-table for ub.qnty-group, input mark-list as character  ) :
  return ( if lookup( string( recid( loc-table ) ), mark-list ) > 0 then "*" else "":U ).
end function.

function mark-string-2 returns character
  ( buffer loc-table for ub.qnty-in-qnty-group , input mark-list as character  ) :
  return ( if lookup( string( recid( loc-table ) ), mark-list ) > 0 then "*" else "":U ).
end function.

function stts-string-2 returns character
  ( buffer loc-table for ub.qnty-in-qnty-group   ) :
&scop status-code string(loc-table.stts)
return {&status-int-name} .
end function.
function stts-string returns character
  ( buffer loc-table for ub.qnty-group   ) :
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
&Scoped-define EXTERNAL-TABLES buf_qnty-group
&Scoped-define FIRST-EXTERNAL-TABLE buf_qnty-group


/* Need to scope the external tables to this procedure                  */
DEFINE QUERY external_tables FOR buf_qnty-group.
/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES buf_qnty-group buf_qnty-in-qnty-group

/* Definitions for BROWSE BROWSE-1grp                                   */
&Scoped-define FIELDS-IN-QUERY-BROWSE-1grp mark-string(buffer buf_qnty-group, p-rec-list) stts-string(buffer buf_qnty-group) buf_qnty-group.qgr-id buf_qnty-group.name usrfulnf(buf_qnty-group.who) buf_qnty-group.sys-date buf_qnty-group.sys-time-chr buf_qnty-group.db-num-chg buf_qnty-group.qgr-db-num
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-1grp
&Scoped-define SELF-NAME BROWSE-1grp
&Scoped-define QUERY-STRING-BROWSE-1grp FOR EACH buf_qnty-group WHERE   ( r-status = 2 OR buf_qnty-group.stts =  r-status ) and   ( r-find = no or (buf_qnty-group.qgr-db-num = find-db and                     buf_qnty-group.qgr-id = find-id ))
&Scoped-define OPEN-QUERY-BROWSE-1grp OPEN QUERY {&SELF-NAME} FOR EACH buf_qnty-group WHERE   ( r-status = 2 OR buf_qnty-group.stts =  r-status ) and   ( r-find = no or (buf_qnty-group.qgr-db-num = find-db and                     buf_qnty-group.qgr-id = find-id )).
&Scoped-define TABLES-IN-QUERY-BROWSE-1grp buf_qnty-group
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-1grp buf_qnty-group


/* Definitions for BROWSE BROWSE-2cli                                   */
&Scoped-define FIELDS-IN-QUERY-BROWSE-2cli mark-string-2(buffer buf_qnty-in-qnty-group, v-rec-list-cli) stts-string-2(buffer buf_qnty-in-qnty-group) buf_qnty-in-qnty-group.ggr-qnty buf_qnty-in-qnty-group.discnt-pc usrfulnf(buf_qnty-in-qnty-group.who) buf_qnty-in-qnty-group.sys-date buf_qnty-in-qnty-group.sys-time-chr buf_qnty-in-qnty-group.db-num-chg buf_qnty-in-qnty-group.qgr-id buf_qnty-in-qnty-group.qgr-db-num
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-2cli
&Scoped-define SELF-NAME BROWSE-2cli
&Scoped-define QUERY-STRING-BROWSE-2cli FOR EACH buf_qnty-in-qnty-group OF buf_qnty-group      WHERE ( r-status = 2 OR buf_qnty-in-qnty-group.stts =  r-status )       NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-BROWSE-2cli OPEN QUERY {&SELF-NAME} FOR EACH buf_qnty-in-qnty-group OF buf_qnty-group      WHERE ( r-status = 2 OR buf_qnty-in-qnty-group.stts =  r-status )       NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-BROWSE-2cli buf_qnty-in-qnty-group
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-2cli buf_qnty-in-qnty-group


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BROWSE-1grp}~
    ~{&OPEN-QUERY-BROWSE-2cli}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-Cancel B-sel B-add B-chg B-del B-history ~
B-Help B-print R-status B-mark-2 B-add-2 B-chg-2 B-del-2 B-mark BROWSE-1grp ~
BROWSE-2cli FILL-IN-1
&Scoped-Define DISPLAYED-OBJECTS R-status FILL-IN-1

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
     SIZE 10 BY 1 TOOLTIP "Добавить количество"
     BGCOLOR 8 .

DEFINE BUTTON B-Cancel AUTO-END-KEY
     LABEL "Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-chg
     LABEL "Изменить"
     SIZE 10 BY 1 TOOLTIP "Изменить название группы"
     BGCOLOR 8 .

DEFINE BUTTON B-chg-2
     LABEL "Изменить"
     SIZE 10 BY 1 TOOLTIP "Изменить скидку"
     BGCOLOR 8 .

DEFINE BUTTON B-del
     LABEL "Удалить"
     SIZE 10 BY 1 TOOLTIP "Удалить группу"
     BGCOLOR 8 .

DEFINE BUTTON B-del-2
     LABEL "Удалить"
     SIZE 10 BY 1 TOOLTIP "Удалить количество"
     BGCOLOR 8 .

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
     SIZE 3.25 BY 1 TOOLTIP "Отметить количество"
     BGCOLOR 8 .

DEFINE BUTTON B-print
     LABEL "Печать"
     SIZE 10 BY 1 TOOLTIP "Печать справочника"
     BGCOLOR 8 .

DEFINE BUTTON B-sel AUTO-GO
     LABEL "Выбор"
     SIZE 10 BY 1
     BGCOLOR 8 .

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
      buf_qnty-group SCROLLING.

DEFINE QUERY BROWSE-2cli FOR
      buf_qnty-in-qnty-group SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BROWSE-1grp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-1grp Dialog-Frame _FREEFORM
  QUERY BROWSE-1grp NO-LOCK DISPLAY
      mark-string(buffer buf_qnty-group, p-rec-list) COLUMN-LABEL "*! " FORMAT "x(1)":U
      stts-string(buffer buf_qnty-group) COLUMN-LABEL "Ста!тус" FORMAT "x(3)":U
      buf_qnty-group.qgr-id COLUMN-LABEL "Код! " FORMAT ">>9":U
      buf_qnty-group.name COLUMN-LABEL "Название!группы" FORMAT "X(80)":U
      usrfulnf(buf_qnty-group.who) COLUMN-LABEL "Кто!изменял" FORMAT "X(12)":U
      buf_qnty-group.sys-date COLUMN-LABEL "Дата!изменения" FORMAT "99/99/99":U
      buf_qnty-group.sys-time-chr COLUMN-LABEL "Время!изм" FORMAT "X(5)":U
      buf_qnty-group.db-num-chg COLUMN-LABEL "БД!изм" FORMAT ">>>>9":U
      buf_qnty-group.qgr-db-num COLUMN-LABEL "БД!соз" FORMAT ">>>>9":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 48.13 BY 19
         TITLE "Количественные группы" FIT-LAST-COLUMN.

DEFINE BROWSE BROWSE-2cli
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-2cli Dialog-Frame _FREEFORM
  QUERY BROWSE-2cli NO-LOCK DISPLAY
      mark-string-2(buffer buf_qnty-in-qnty-group, v-rec-list-cli) COLUMN-LABEL "*! " FORMAT "x(1)":U
stts-string-2(buffer buf_qnty-in-qnty-group) COLUMN-LABEL "Ста!тус" FORMAT "x(3)":U
buf_qnty-in-qnty-group.ggr-qnty COLUMN-LABEL "Количество! " FORMAT "->,>>>,>>>,>>>,>>9.99":U
buf_qnty-in-qnty-group.discnt-pc COLUMN-LABEL "Скидка!% " FORMAT ">>9.99":U
usrfulnf(buf_qnty-in-qnty-group.who) COLUMN-LABEL "Кто!изменял" FORMAT "X(12)":U
buf_qnty-in-qnty-group.sys-date COLUMN-LABEL "Дата!изм" FORMAT "99/99/99":U
buf_qnty-in-qnty-group.sys-time-chr COLUMN-LABEL "Время!изм" FORMAT "X(5)":U
buf_qnty-in-qnty-group.db-num-chg COLUMN-LABEL "БД!изм" FORMAT ">>>>9":U
buf_qnty-in-qnty-group.qgr-id COLUMN-LABEL "Гру!ппа" FORMAT ">>>>9":U
buf_qnty-in-qnty-group.qgr-db-num FORMAT ">>>>9":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 50.5 BY 19
         TITLE "Количества в группе" FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-Cancel AT ROW 1 COL 1
     B-sel AT ROW 1 COL 11
     B-add AT ROW 1 COL 21
     B-chg AT ROW 1 COL 31 WIDGET-ID 2
     B-del AT ROW 1 COL 41
     B-history AT ROW 1 COL 79.88
     B-Help AT ROW 1 COL 90
     B-print AT ROW 2 COL 90
     R-status AT ROW 2.29 COL 9.63 NO-LABEL
     B-mark-2 AT ROW 2.92 COL 49.75
     B-add-2 AT ROW 2.92 COL 53
     B-chg-2 AT ROW 2.92 COL 63.13
     B-del-2 AT ROW 2.92 COL 73.25
     B-mark AT ROW 3 COL 1.75
     BROWSE-1grp AT ROW 4 COL 1.38
     BROWSE-2cli AT ROW 4 COL 49.5
     FILL-IN-1 AT ROW 2.25 COL 2 NO-LABEL
     SPACE(90.88) SKIP(20.21)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Количественные группы для ценообразования"
         DEFAULT-BUTTON B-sel CANCEL-BUTTON B-Cancel.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   External Tables: Temp-Tables.buf_qnty-group
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: buf_qnty-group B "NEW SHARED" ? ub ub.qnty-group
      TABLE: buf_qnty-in-qnty-group B "?" ? ub ub.qnty-in-qnty-group
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BROWSE-1grp B-mark Dialog-Frame */
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
OPEN QUERY {&SELF-NAME} FOR EACH buf_qnty-group WHERE
  ( r-status = 2 OR buf_qnty-group.stts =  r-status ) and
  ( r-find = no or (buf_qnty-group.qgr-db-num = find-db and
                    buf_qnty-group.qgr-id = find-id )).
     _END_FREEFORM
     _Options          = "NO-LOCK"
     _Query            is OPENED
*/  /* BROWSE BROWSE-1grp */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-2cli
/* Query rebuild information for BROWSE BROWSE-2cli
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH buf_qnty-in-qnty-group OF buf_qnty-group
     WHERE ( r-status = 2 OR buf_qnty-in-qnty-group.stts =  r-status )
      NO-LOCK INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _TblOptList       = ","
     _Query            is OPENED
*/  /* BROWSE BROWSE-2cli */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Количественные группы для ценообразования */
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
  run ref/gr-qupra.w (input parparentproc,input {&add-def} , input-output v-rec-id) .
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
if not available buf_qnty-group then return .
if v-cntxt-db-num <> 0 then do :
   if buf_qnty-group.qgr-db-num <> v-cntxt-db-num then do:
      message substitute(" Группа создана в другой БД (&1) , корректировать ее в текущей БД нельзя !" , buf_qnty-group.qgr-db-num ) .
      return .
   end.
end.


if buf_qnty-group.stts <> 0 then do:
   message "В эту группу добавлять количества нельзя!" view-as alert-box error .
   return .
end.
  run ref/gr-quprb.w (
      input parparentproc ,
      input {&add-def} ,
      input buf_qnty-group.qgr-db-num ,
      input buf_qnty-group.qgr-id     ,
      input buf_qnty-group.name ,
      input-output v-rec-id ) .
  {&OPEN-QUERY-BROWSE-2cli}
  reposition BROWSE-2cli to recid v-rec-id no-error .

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

define variable v-rec-id as recid no-undo .
IF NOT AVAILABLE buf_qnty-group THEN RETURN.
   if buf_qnty-group.stts <> 0 then do:
      message " Группа удалена " .
      return .
   end.

v-rec-id = RECID(buf_qnty-group) .
if v-cntxt-db-num <> 0 then do :
   if buf_qnty-group.qgr-db-num <> v-cntxt-db-num then do:
      message substitute(" Группа создана в другой БД (&1) , корректировать ее в текущей БД нельзя !" , buf_qnty-group.qgr-db-num ) .
      return .
   end.
end.

  run ref/gr-qupra.w (input parparentproc,input {&update} , input-output v-rec-id) .
  {&OPEN-QUERY-BROWSE-1grp}
  reposition BROWSE-1grp to recid v-rec-id no-error .
  apply "VALUE-CHANGED" to browse-1grp in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-chg-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-chg-2 Dialog-Frame
ON CHOOSE OF B-chg-2 IN FRAME Dialog-Frame /* Изменить */
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
if not available buf_qnty-group then return .
IF NOT AVAILABLE buf_qnty-in-qnty-group THEN RETURN.
if v-cntxt-db-num <> 0 then do :
   if buf_qnty-group.qgr-db-num <> v-cntxt-db-num then do:
      message substitute(" Группа создана в другой БД (&1) , корректировать ее в текущей БД нельзя !" , buf_qnty-group.qgr-db-num ) .
      return .
   end.
end.

if buf_qnty-group.stts <> 0 then do:
   message "В этой группе изменять количества нельзя!" view-as alert-box error .
   return .
end.
if buf_qnty-in-qnty-group.stts <> 0 then do:
   message "Изменять количества нельзя!" view-as alert-box error .
   return .
end.

v-rec-id = RECID(buf_qnty-in-qnty-group) .
  run ref/gr-quprb.w (
      input parparentproc ,
      input {&UPDATE} ,
      input buf_qnty-group.qgr-db-num ,
      input buf_qnty-group.qgr-id     ,
      input buf_qnty-group.name ,
      input-output v-rec-id ) .
  {&OPEN-QUERY-BROWSE-2cli}
  reposition BROWSE-2cli to recid v-rec-id no-error .

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

   if buf_qnty-group.stts <> 0 then do:
      message " Группа удалена " .
      return .
   end.

  if not available buf_qnty-group then return .
  message "Удалять группу " buf_qnty-group.name "?"
          view-as alert-box question
          buttons yes-no update g-ok as log.
  if not g-ok then return .
  run ref/gr-qudel.p (
      input parparentproc ,
      input buf_qnty-group.qgr-db-num ,
      input buf_qnty-group.qgr-id      )
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

  if not available buf_qnty-in-qnty-group then return .
  if v-cntxt-db-num <> 0 then do :
   if buf_qnty-group.qgr-db-num <> v-cntxt-db-num then do:
      message substitute(" Группа создана в другой БД (&1) , корректировать ее в текущей БД нельзя !" , buf_qnty-group.qgr-db-num ) .
      return .
   end.
end.

        run qiq-del (
           input   buf_qnty-in-qnty-group.qgr-db-num
          ,input   buf_qnty-in-qnty-group.qgr-id
          ,input   buf_qnty-in-qnty-group.ggr-qnty
          ,input   v-cntxt-db-num
          ,input   v-cntxt-userid ) .

   {&OPEN-QUERY-BROWSE-2cli}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-history
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-history Dialog-Frame
ON CHOOSE OF B-history IN FRAME Dialog-Frame /* История */
DO:
  if not available buf_qnty-group then return .
  run ref/cgr-sqr.w (
      parParentProc ,
      buf_qnty-group.qgr-id ,
      buf_qnty-group.qgr-db-num ) .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mark Dialog-Frame
ON CHOOSE OF B-mark IN FRAME Dialog-Frame /* * */
DO:
    if available buf_qnty-group then do:
      { gbl/markstrn.i buf_qnty-group p-rec-list }
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

    if available buf_qnty-in-qnty-group then do:
      { gbl/markstrn.i buf_qnty-in-qnty-group v-rec-list-cli }
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


&Scoped-define SELF-NAME B-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-print Dialog-Frame
ON CHOOSE OF B-print IN FRAME Dialog-Frame /* Печать */
DO:
if not available buf_qnty-group then return .
  run rep/g-prqnty.p
  ( parParentProc ,
    recid( buf_qnty-group )
  ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-sel Dialog-Frame
ON CHOOSE OF B-sel IN FRAME Dialog-Frame /* Выбор */
DO:
    if ( available buf_qnty-group ) AND ( p-rec-list = "" ) then
    p-rec-list = string( recid( buf_qnty-group ) ) .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BROWSE-1grp
&Scoped-define SELF-NAME BROWSE-1grp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BROWSE-1grp Dialog-Frame
ON VALUE-CHANGED OF BROWSE-1grp IN FRAME Dialog-Frame /* Количественные группы */
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

   buf_qnty-group.name:resizable in browse browse-1grp = true .
   buf_qnty-group.name:width  in browse browse-1grp = 20 .
  if p-rec-list <> "" and p-rec-list <> ? then run select_one .
  RUN enable_UI.
  disable
     B-sel      when LOOKUP ("b-sel":U,    p-bttns) = 0
     B-add      when LOOKUP ("b-add":U,    p-bttns) = 0
     B-chg      when LOOKUP ("b-chg":U,    p-bttns) = 0
     B-del      when LOOKUP ("b-del":U,    p-bttns) = 0
     B-add-2    when LOOKUP ("b-add":U,    p-bttns) = 0
     B-chg-2    when LOOKUP ("b-chg":U,    p-bttns) = 0
     B-del-2    when LOOKUP ("b-del":U,    p-bttns) = 0
     B-mark     when LOOKUP ("b-mark":U,   p-bttns) = 0
     B-mark-2   when LOOKUP ("b-mark-2":U, p-bttns) = 0
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
  DISPLAY R-status FILL-IN-1
      WITH FRAME Dialog-Frame.
  ENABLE B-Cancel B-sel B-add B-chg B-del B-history B-Help B-print R-status
         B-mark-2 B-add-2 B-chg-2 B-del-2 B-mark BROWSE-1grp BROWSE-2cli
         FILL-IN-1
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
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
define buffer bufl_qnty-group for ub.qnty-group  .

find first bufl_qnty-group no-lock where recid(bufl_qnty-group) = int(p-rec-list) no-error .
if error-status :error then return .
r-find = true .
find-db = bufl_qnty-group.qgr-db-num  .
find-id = bufl_qnty-group.qgr-id      .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME