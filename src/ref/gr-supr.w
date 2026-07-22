&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v9r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE NEW SHARED BUFFER buf_sum-group FOR ub.sum-group.
DEFINE BUFFER buf_sum-in-sum-group FOR ub.sum-in-sum-group.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Справочник суммовых групп

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
define variable vss-description as character no-undo init "Справочник суммовых групп для ценообразования".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i  }
{ cmp/library.i  }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
{ gbl/waitfram.i }
{ ref/sis-ad.i   }
{ gbl/usrfulnf.i }

/* Local Variable Definitions ---                                       */
define variable r-find  as logical   no-undo init false .
define variable find-id as integer   no-undo .
define variable find-db as integer   no-undo .


define variable v-rec-list-cli as character no-undo .

define variable g-log as logical   no-undo .
function mark-string returns character
  ( buffer loc-table for ub.sum-group, input mark-list as character  ) :
  return ( if lookup( string( recid( loc-table ) ), mark-list ) > 0 then "*" else "":U ).
end function.

function mark-string-2 returns character
  ( buffer loc-table for ub.sum-in-sum-group , input mark-list as character  ) :
  return ( if lookup( string( recid( loc-table ) ), mark-list ) > 0 then "*" else "":U ).
end function.

function stts-string-2 returns character
  ( buffer loc-table for ub.sum-in-sum-group   ) :
&scop status-code string(loc-table.stts)
return {&status-int-name} .
end function.
function stts-string returns character
  ( buffer loc-table for ub.sum-group   ) :
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
&Scoped-define EXTERNAL-TABLES buf_sum-group
&Scoped-define FIRST-EXTERNAL-TABLE buf_sum-group


/* Need to scope the external tables to this procedure                  */
DEFINE QUERY external_tables FOR buf_sum-group.
/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES buf_sum-group buf_sum-in-sum-group

/* Definitions for BROWSE BROWSE-1grp                                   */
&Scoped-define FIELDS-IN-QUERY-BROWSE-1grp mark-string(buffer buf_sum-group, p-rec-list) stts-string(buffer buf_sum-group) buf_sum-group.sgr-id buf_sum-group.name usrfulnf(buf_sum-group.who) buf_sum-group.sys-date buf_sum-group.sys-time-chr buf_sum-group.db-num-chg buf_sum-group.sgr-db-num
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-1grp
&Scoped-define SELF-NAME BROWSE-1grp
&Scoped-define QUERY-STRING-BROWSE-1grp FOR EACH buf_sum-group WHERE ( r-status = 2 OR buf_sum-group.stts =  r-status ) and   ( r-find = no or (buf_sum-group.sgr-db-num = find-db and                         buf_sum-group.sgr-id = find-id ))
&Scoped-define OPEN-QUERY-BROWSE-1grp OPEN QUERY {&SELF-NAME} FOR EACH buf_sum-group WHERE ( r-status = 2 OR buf_sum-group.stts =  r-status ) and   ( r-find = no or (buf_sum-group.sgr-db-num = find-db and                         buf_sum-group.sgr-id = find-id ))  .
&Scoped-define TABLES-IN-QUERY-BROWSE-1grp buf_sum-group
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-1grp buf_sum-group


/* Definitions for BROWSE BROWSE-2cli                                   */
&Scoped-define FIELDS-IN-QUERY-BROWSE-2cli mark-string-2(buffer buf_sum-in-sum-group, v-rec-list-cli) stts-string-2(buffer buf_sum-in-sum-group) buf_sum-in-sum-group.ssg-summa buf_sum-in-sum-group.discnt-pc usrfulnf(buf_sum-in-sum-group.who) buf_sum-in-sum-group.sys-date buf_sum-in-sum-group.sys-time-chr buf_sum-in-sum-group.db-num-chg buf_sum-in-sum-group.sgr-id buf_sum-in-sum-group.sgr-db-num
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-2cli
&Scoped-define SELF-NAME BROWSE-2cli
&Scoped-define QUERY-STRING-BROWSE-2cli FOR EACH buf_sum-in-sum-group OF buf_sum-group      WHERE ( r-status = 2 OR buf_sum-in-sum-group.stts =  r-status )       NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-BROWSE-2cli OPEN QUERY {&SELF-NAME} FOR EACH buf_sum-in-sum-group OF buf_sum-group      WHERE ( r-status = 2 OR buf_sum-in-sum-group.stts =  r-status )       NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-BROWSE-2cli buf_sum-in-sum-group
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-2cli buf_sum-in-sum-group


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BROWSE-1grp}~
    ~{&OPEN-QUERY-BROWSE-2cli}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-Cancel B-sel B-chg B-add B-del B-history ~
B-Help B-print R-status B-mark-2 B-add-2 B-chg2 B-del-2 B-mark BROWSE-1grp ~
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
     SIZE 10 BY 1 TOOLTIP "Добавить сумму"
     BGCOLOR 8 .

DEFINE BUTTON B-Cancel AUTO-END-KEY
     LABEL "Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-chg
     LABEL "Изменить"
     SIZE 10 BY 1 TOOLTIP "Изменить название группы"
     BGCOLOR 8 .

DEFINE BUTTON B-chg2
     LABEL "Изменить"
     SIZE 10 BY 1 TOOLTIP "Изменить сумму и процент скидки"
     BGCOLOR 8 .

DEFINE BUTTON B-del
     LABEL "Удалить"
     SIZE 10 BY 1 TOOLTIP "Удалить группу"
     BGCOLOR 8 .

DEFINE BUTTON B-del-2
     LABEL "Удалить"
     SIZE 10 BY 1 TOOLTIP "Удалить сумму"
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
     SIZE 3.25 BY 1 TOOLTIP "Отметить сумму"
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
      buf_sum-group SCROLLING.

DEFINE QUERY BROWSE-2cli FOR
      buf_sum-in-sum-group SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BROWSE-1grp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-1grp Dialog-Frame _FREEFORM
  QUERY BROWSE-1grp NO-LOCK DISPLAY
      mark-string(buffer buf_sum-group, p-rec-list) COLUMN-LABEL "*! " FORMAT "x(1)":U
      stts-string(buffer buf_sum-group) COLUMN-LABEL "Ста!тус" FORMAT "x(3)":U
      buf_sum-group.sgr-id COLUMN-LABEL "Код! " FORMAT ">>9":U
      buf_sum-group.name COLUMN-LABEL "Название!группы" FORMAT "X(80)":U
      usrfulnf(buf_sum-group.who) COLUMN-LABEL "Кто!изменял" FORMAT "X(15)":U
      buf_sum-group.sys-date COLUMN-LABEL "Дата!изм" FORMAT "99/99/99":U
      buf_sum-group.sys-time-chr COLUMN-LABEL "Время!изм" FORMAT "X(5)":U
      buf_sum-group.db-num-chg COLUMN-LABEL "БД!изм" FORMAT ">>9":U
      buf_sum-group.sgr-db-num FORMAT ">9":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 48.13 BY 19
         TITLE "Cуммовые группы" FIT-LAST-COLUMN.

DEFINE BROWSE BROWSE-2cli
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-2cli Dialog-Frame _FREEFORM
  QUERY BROWSE-2cli NO-LOCK DISPLAY
      mark-string-2(buffer buf_sum-in-sum-group, v-rec-list-cli) COLUMN-LABEL "*! " FORMAT "x(1)":U
      stts-string-2(buffer buf_sum-in-sum-group) COLUMN-LABEL "Ста!тус" FORMAT "x(3)":U
      buf_sum-in-sum-group.ssg-summa COLUMN-LABEL "Сумма! " FORMAT "->,>>>,>>>,>>>,>>9.99":U
      buf_sum-in-sum-group.discnt-pc COLUMN-LABEL "Скидка!% " FORMAT ">>9.99":U
      usrfulnf(buf_sum-in-sum-group.who) COLUMN-LABEL "Кто!изменял" FORMAT "X(15)":U
      buf_sum-in-sum-group.sys-date COLUMN-LABEL "Дата!изм" FORMAT "99/99/99":U
      buf_sum-in-sum-group.sys-time-chr COLUMN-LABEL "Время!изм" FORMAT "X(5)":U
      buf_sum-in-sum-group.db-num-chg COLUMN-LABEL "БД!изм" FORMAT ">>>>9":U
      buf_sum-in-sum-group.sgr-id COLUMN-LABEL "Гру!ппа" FORMAT ">>9":U
      buf_sum-in-sum-group.sgr-db-num FORMAT ">>>>9":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 50.5 BY 19
         TITLE "Суммы в группе" FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-Cancel AT ROW 1 COL 1
     B-sel AT ROW 1 COL 11
     B-chg AT ROW 1 COL 21 WIDGET-ID 2
     B-add AT ROW 1 COL 31
     B-del AT ROW 1 COL 41
     B-history AT ROW 1 COL 79.88
     B-Help AT ROW 1 COL 90
     B-print AT ROW 2 COL 90
     R-status AT ROW 2.29 COL 9.63 NO-LABEL
     B-mark-2 AT ROW 2.92 COL 49.75
     B-add-2 AT ROW 2.92 COL 53
     B-chg2 AT ROW 2.92 COL 63.13
     B-del-2 AT ROW 2.92 COL 73.13
     B-mark AT ROW 3 COL 1.75
     BROWSE-1grp AT ROW 4 COL 1.38
     BROWSE-2cli AT ROW 4 COL 49.5
     FILL-IN-1 AT ROW 2.25 COL 2 NO-LABEL
     SPACE(90.88) SKIP(20.21)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Суммовые группы для ценообразования"
         DEFAULT-BUTTON B-sel CANCEL-BUTTON B-Cancel.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   External Tables: Temp-Tables.buf_sum-group
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: buf_sum-group B "NEW SHARED" ? ub ub.sum-group
      TABLE: buf_sum-in-sum-group B "?" ? ub ub.sum-in-sum-group
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
OPEN QUERY {&SELF-NAME} FOR EACH buf_sum-group WHERE
( r-status = 2 OR buf_sum-group.stts =  r-status )
and   ( r-find = no or (buf_sum-group.sgr-db-num = find-db and
                        buf_sum-group.sgr-id = find-id ))

.
     _END_FREEFORM
     _Options          = "NO-LOCK"
     _Query            is OPENED
*/  /* BROWSE BROWSE-1grp */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-2cli
/* Query rebuild information for BROWSE BROWSE-2cli
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH buf_sum-in-sum-group OF buf_sum-group
     WHERE ( r-status = 2 OR buf_sum-in-sum-group.stts =  r-status )
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
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Суммовые группы для ценообразования */
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
  run ref/gr-supra.w (input parparentproc,input {&add-def} , input-output v-rec-id) .
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
if not available buf_sum-group then return .
if buf_sum-group.stts <> 0 then do:
   message "В эту группу добавлять сумму нельзя!" view-as alert-box error .
   return .
end.
if v-cntxt-db-num <> 0 then do :
   if buf_sum-group.sgr-db-num <> v-cntxt-db-num then do:
      message substitute(" Группа создана в другой БД (&1) , корректировать ее в текущей БД нельзя !" , buf_sum-group.sgr-db-num ) .
      return .
   end.
end.

  run ref/gr-suprb.w (
      input parparentproc ,
      input {&add-def} ,
      input buf_sum-group.sgr-db-num ,
      input buf_sum-group.sgr-id     ,
      input buf_sum-group.name ,
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
IF NOT AVAILABLE buf_sum-group THEN RETURN.
   if buf_sum-group.stts <> 0 then do:
      message " Группа удалена " .
      return .
   end.

if v-cntxt-db-num <> 0 then do :
   if buf_sum-group.sgr-db-num <> v-cntxt-db-num then do:
      message substitute(" Группа создана в другой БД (&1) , корректировать ее в текущей БД нельзя !" , buf_sum-group.sgr-db-num ) .
      return .
   end.
end.

  v-rec-id = RECID(buf_sum-group) .
  run ref/gr-supra.w (input parparentproc,input {&update} , input-output v-rec-id) .
  {&OPEN-QUERY-BROWSE-1grp}
  reposition BROWSE-1grp to recid v-rec-id no-error .
  apply "VALUE-CHANGED" to browse-1grp in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-chg2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-chg2 Dialog-Frame
ON CHOOSE OF B-chg2 IN FRAME Dialog-Frame /* Изменить */
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
if not available buf_sum-group then return .
if not available buf_sum-in-sum-group then return .
if v-cntxt-db-num <> 0 then do :
   if buf_sum-group.sgr-db-num <> v-cntxt-db-num then do:
      message substitute(" Группа создана в другой БД (&1) , корректировать ее в текущей БД нельзя !" , buf_sum-group.sgr-db-num ) .
      return .
   end.
end.

if buf_sum-group.stts <> 0 then do:
   message "В этой группе изменять сумму нельзя!" view-as alert-box error .
   return .
end.
if buf_sum-in-sum-group.stts <> 0 then do:
   message "Изменять сумму нельзя!" view-as alert-box error .
   return .
end.


v-rec-id = RECID (buf_sum-in-sum-group )  .
  run ref/gr-suprb.w (
      input parparentproc ,
      input {&update} ,
      input buf_sum-group.sgr-db-num ,
      input buf_sum-group.sgr-id     ,
      input buf_sum-group.name ,
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

  if not available buf_sum-group then return .
   if buf_sum-group.stts <> 0 then do:
      message " Группа удалена " .
      return .
   end.

  message "Удалять группу " buf_sum-group.name "?"
          view-as alert-box question
          buttons yes-no update g-ok as log.
  if not g-ok then return .
  run ref/gr-sudel.p (
      input parparentproc ,
      input buf_sum-group.sgr-db-num ,
      input buf_sum-group.sgr-id      )
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

  if not available buf_sum-in-sum-group then return .
if v-cntxt-db-num <> 0 then do :
   if buf_sum-group.sgr-db-num <> v-cntxt-db-num then do:
      message substitute(" Группа создана в другой БД (&1) , корректировать ее в текущей БД нельзя !" , buf_sum-group.sgr-db-num ) .
      return .
   end.
end.

  if buf_sum-in-sum-group.stts = 0 then do:
      message
      "Сумма " buf_sum-in-sum-group.ssg-summa
      "Удалять ?"
      view-as alert-box question
      buttons yes-no
      update v-ok as logical
      .
      if v-ok then
            run sis-del in this-procedure (
              input   buf_sum-in-sum-group.sgr-db-num
              ,input   buf_sum-in-sum-group.sgr-id
              ,input   buf_sum-in-sum-group.ssg-summa
              ,input   v-cntxt-db-num
              ,input   v-cntxt-userid
              ) .
  end.
  else do:
  /*
      if buf_sum-group.stts = 1 then return .
      message
          "Сумма " buf_sum-in-sum-group.ssg-summa  "уже удалена , "
          "" skip
          "" skip
          "ВОССТАНОВИТЬ ?"
          view-as alert-box question
          buttons yes-no
          update v-ok1 as logical
      .
      if v-ok1 then
        run sis-update
          (  input  recid ( buf_sum-in-sum-group )
          ,  input  buf_sum-in-sum-group.sgr-db-num
          ,  input  buf_sum-in-sum-group.sgr-id
          ,  input  buf_sum-in-sum-group.ssg-summa
          ,  input  buf_sum-in-sum-group.use-discnt
          ,  input  buf_sum-in-sum-group.discnt-pc
          ,  input  buf_sum-in-sum-group.discnt-method-round
          ,  input  0
          ,  input  v-cntxt-db-num
          ,  input  v-cntxt-userid
          ) .
     */
  end.

  {&OPEN-QUERY-BROWSE-2cli}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-history
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-history Dialog-Frame
ON CHOOSE OF B-history IN FRAME Dialog-Frame /* История */
DO:
  if not available buf_sum-group then return .
  run ref/cgr-sgr.w (
      parParentProc ,
      buf_sum-group.sgr-id ,
      buf_sum-group.sgr-db-num ) .


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mark Dialog-Frame
ON CHOOSE OF B-mark IN FRAME Dialog-Frame /* * */
DO:
    if available buf_sum-group then do:
      { gbl/markstrn.i buf_sum-group p-rec-list }
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

    if available buf_sum-in-sum-group then do:
      { gbl/markstrn.i buf_sum-in-sum-group v-rec-list-cli }
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
if not available buf_sum-group then return .
  run rep/g-prsum.p
  ( parParentProc ,
    recid( buf_sum-group )
  ).

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-sel Dialog-Frame
ON CHOOSE OF B-sel IN FRAME Dialog-Frame /* Выбор */
DO:
  /**/
    if ( available buf_sum-group ) AND ( p-rec-list = "" ) then
    p-rec-list = string( recid( buf_sum-group ) ) .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BROWSE-1grp
&Scoped-define SELF-NAME BROWSE-1grp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BROWSE-1grp Dialog-Frame
ON VALUE-CHANGED OF BROWSE-1grp IN FRAME Dialog-Frame /* Cуммовые группы */
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

   buf_sum-group.NAME:resizable in browse browse-1grp = true .
   buf_sum-group.NAME:width  in browse browse-1grp = 20 .
   if p-rec-list <> "" and p-rec-list <> ? then run select_one .
  run enable_ui in this-procedure .
  disable
     B-sel      when LOOKUP ("b-sel":U,    p-bttns) = 0
     B-add      when LOOKUP ("b-add":U,    p-bttns) = 0
     B-chg      when LOOKUP ("b-chg":U,    p-bttns) = 0
     B-del      when LOOKUP ("b-del":U,    p-bttns) = 0
     B-add-2    when LOOKUP ("b-add":U,    p-bttns) = 0
     B-del-2    when LOOKUP ("b-del":U,    p-bttns) = 0
     B-mark     when LOOKUP ("b-mark":U,   p-bttns) = 0
     B-mark-2   when LOOKUP ("b-mark-2":U, p-bttns) = 0
    with frame {&frame-name} .

  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
run disable_UI in this-procedure .

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
  ENABLE B-Cancel B-sel B-chg B-add B-del B-history B-Help B-print R-status
         B-mark-2 B-add-2 B-chg2 B-del-2 B-mark BROWSE-1grp BROWSE-2cli
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
define buffer bufl_sum-group for ub.sum-group  .

find first bufl_sum-group no-lock where recid(bufl_sum-group) = int(p-rec-list) no-error .
if error-status :error then return .
r-find = true .
find-db = bufl_sum-group.sgr-db-num  .
find-id = bufl_sum-group.sgr-id      .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME