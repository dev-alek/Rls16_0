&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Справочник серий материальных ценностей

Автор: Гридчина Полина Дмитриевна
Дата создания: 09/04/07
Author: Polina Gridchina
Creation date: 09/04/07

Input:

Output:

*/


DEFINE buffer X_wth-ser for ub.wth-ser.
DEFINE buffer X_wealth  for ub.wealth.
DEFINE buffer X_wth-par for ub.wth-par.
DEFINE buffer X_wth-gds for ub.wth-gds.
DEFINE buffer X_goods   for ub.goods.

/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .
define input parameter bttns as char no-undo.
define input parameter p-curr-host-code like ub.sysconf.host-code no-undo .
define input parameter p-curr-obj-type  like ub.clients.obj-type no-undo .
define input parameter p-curr-obj-code  like ub.clients.obj-code no-undo .
define input parameter p-list-mode      as character no-undo .
define input parameter pwth-code as integer no-undo.
define input parameter ppar-code as integer no-undo.
define input-output param rid-list as char no-undo.

/* define VAR parparentproc as widget-handle no-undo .          */
/* define VAR bttns as char no-undo.                            */
/* define VAR p-curr-host-code like sysconf.host-code no-undo . */
/* define VAR p-curr-obj-type  like clients.obj-type no-undo .  */
/* define VAR p-curr-obj-code  like clients.obj-code no-undo .  */
/* define VAR p-list-mode      as character no-undo .           */
/* define VAR pwth-code as integer no-undo.                     */
/* DEFINE VAR rid-list as char no-undo.                         */


/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Справочник серий материальных ценностей ".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/showinf.i }
{ gbl/cur-time.i }
{ gbl/flt-def.i  }
{ gbl/fltfield.i }
{ cmp/r-pril.i new }
{ gbl/prn-lib.i }
{ gbl/waitfram.i }
{ gbl/getcntxt.i def }
{ gbl/fltopend.i defproc }
{ gbl/usr-flt.i }
define buffer b-wealth for ub.wealth.
define buffer b-wth-par for ub.wth-par.
define variable filter-point as character no-undo init "Серии_МЦ" .
define variable sort-column-name as character no-undo .
define variable ri          as      recid   no-undo     init ? .
define variable choice as log no-undo.
define variable mark as char no-undo.
define variable v-doc-rec as recid no-undo .
DEFINE VARIABLE v-serDb AS CHAR NO-UNDO.


define variable v-db-num as integer   no-undo .
{ gbl/curdbnum.i v-db-num }

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BR-wths

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_wth-ser X_wealth X_wth-par X_wth-gds ~
X_goods

/* Definitions for BROWSE BR-wths                                       */
&Scoped-define FIELDS-IN-QUERY-BR-wths mark-string(recid(X_wth-ser), rid-list) substitute('&1-&2',X_wth-ser.ser-code,X_wth-ser.db-num) @ v-SerDb (if X_wth-ser.stts = 0 then X_wth-ser.series else substring (X_wth-ser.series, 1, 15) + {&deleted-stat_}) X_wealth.wth-code X_wth-par.par-val (if X_wealth.stts = 0 then X_wealth.wth-name else substring (X_wealth.wth-name, 1, 15) + {&deleted-stat_}) X_goods.artic X_goods.gds-name X_wth-ser.stts   
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-wths   
&Scoped-define SELF-NAME BR-wths
&Scoped-define QUERY-STRING-BR-wths FOR EACH X_wth-ser       WHERE IF rsfl-par = 0 THEN X_wth-ser.stts = 0 ELSE (IF rsfl-par = 1 THEN (X_wth-ser.stts = 0 AND X_wth-ser.qnty > 0) ELSE (IF rsfl-par = 2 THEN X_wth-ser.stts > 0 ELSE TRUE) ) NO-LOCK, ~
             FIRST X_wealth WHERE X_wealth.wth-code = X_wth-ser.wth-code NO-LOCK, ~
             EACH X_wth-par WHERE X_wth-par.par-code = X_wth-ser.par-code NO-LOCK, ~
             EACH X_wth-gds WHERE X_wth-gds.wth-code = X_wealth.wth-code NO-LOCK, ~
             EACH X_goods WHERE X_goods.gds-code = X_wth-gds.gds-code NO-LOCK
&Scoped-define OPEN-QUERY-BR-wths OPEN QUERY {&SELF-NAME} FOR EACH X_wth-ser       WHERE IF rsfl-par = 0 THEN X_wth-ser.stts = 0 ELSE (IF rsfl-par = 1 THEN (X_wth-ser.stts = 0 AND X_wth-ser.qnty > 0) ELSE (IF rsfl-par = 2 THEN X_wth-ser.stts > 0 ELSE TRUE) ) NO-LOCK, ~
             FIRST X_wealth WHERE X_wealth.wth-code = X_wth-ser.wth-code NO-LOCK, ~
             EACH X_wth-par WHERE X_wth-par.par-code = X_wth-ser.par-code NO-LOCK, ~
             EACH X_wth-gds WHERE X_wth-gds.wth-code = X_wealth.wth-code NO-LOCK, ~
             EACH X_goods WHERE X_goods.gds-code = X_wth-gds.gds-code NO-LOCK.
&Scoped-define TABLES-IN-QUERY-BR-wths X_wth-ser X_wealth X_wth-par ~
X_wth-gds X_goods
&Scoped-define FIRST-TABLE-IN-QUERY-BR-wths X_wth-ser
&Scoped-define SECOND-TABLE-IN-QUERY-BR-wths X_wealth
&Scoped-define THIRD-TABLE-IN-QUERY-BR-wths X_wth-par
&Scoped-define FOURTH-TABLE-IN-QUERY-BR-wths X_wth-gds
&Scoped-define FIFTH-TABLE-IN-QUERY-BR-wths X_goods


/* Definitions for DIALOG-BOX Dialog-Frame                              */

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit B-mark B-sel B-add B-chg b-lkp B-del ~
B-print B-hist B-sch B-Help rsfl-par BR-wths mark-num 
&Scoped-Define DISPLAYED-OBJECTS rsfl-par mark-num 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-curr Dialog-Frame 
FUNCTION get-curr RETURNS CHARACTER
  ( buffer loc-X_wealth for X_wealth )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD mark-string Dialog-Frame 
FUNCTION mark-string RETURNS CHARACTER
  ( input par-recid as recid, input mark-list as character )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-add 
     LABEL "&Добавить" 
     SIZE 10 BY 1.

DEFINE BUTTON B-chg 
     LABEL "&Изменить" 
     SIZE 10 BY 1.

DEFINE BUTTON B-del 
     LABEL "&Удалить" 
     SIZE 10 BY 1.

DEFINE BUTTON B-Help 
     LABEL "Помо&щь" 
     SIZE 5 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-hist 
     LABEL "Ис&тория" 
     SIZE 5.5 BY 1.

DEFINE BUTTON b-lkp 
     LABEL "&Просмотр" 
     SIZE 10 BY 1.

DEFINE BUTTON B-mark 
     LABEL "&*" 
     SIZE 3 BY 1.

DEFINE BUTTON B-parts 
     LABEL "&Партии" 
     SIZE 10 BY 1.

DEFINE BUTTON B-print 
     LABEL "Пе&чать" 
     SIZE 5 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY 
     LABEL "&Выход" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-sch 
     LABEL "&Фильтр" 
     SIZE 5 BY 1.

DEFINE BUTTON B-sel AUTO-GO 
     LABEL "Вы&бор" 
     SIZE 10 BY 1.

DEFINE VARIABLE mark-num AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 4.63 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE rsfl-par AS INTEGER INITIAL 1 
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS 
          "Текущие", 0,
"Все", 3,
"Удаленные", 2
     SIZE 29 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-wths FOR 
      X_wth-ser, 
      X_wealth, 
      X_wth-par, 
      X_wth-gds, 
      X_goods SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-wths
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-wths Dialog-Frame _FREEFORM
  QUERY BR-wths NO-LOCK DISPLAY
      mark-string(recid(X_wth-ser), rid-list) COLUMN-LABEL "*" FORMAT "x(1)":U
      substitute('&1-&2',X_wth-ser.ser-code,X_wth-ser.db-num) @ v-SerDb COLUMN-LABEL "Код"
            (if X_wth-ser.stts = 0
 then X_wth-ser.series
 else substring (X_wth-ser.series, 1, 15) + {&deleted-stat_}) COLUMN-LABEL "Серия" FORMAT "x(18)":U
            WIDTH 15.5
      X_wealth.wth-code COLUMN-LABEL "Код МЦ"
      X_wth-par.par-val
      (if X_wealth.stts = 0
 then X_wealth.wth-name
 else substring (X_wealth.wth-name, 1, 15) + {&deleted-stat_}) COLUMN-LABEL "Название" FORMAT "X(40)":U
            WIDTH 25.5
      X_goods.artic WIDTH 9.5
      X_goods.gds-name COLUMN-LABEL "Название товара" WIDTH 33.5
      X_wth-ser.stts
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 16 ROW-HEIGHT-CHARS .67.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-mark AT ROW 1 COL 16
     B-sel AT ROW 1 COL 19
     B-add AT ROW 1 COL 29
     B-chg AT ROW 1 COL 39
     b-lkp AT ROW 1 COL 49 WIDGET-ID 10
     B-del AT ROW 1 COL 59
     B-parts AT ROW 1 COL 69 WIDGET-ID 8
     B-print AT ROW 1 COL 79
     B-hist AT ROW 1 COL 84
     B-sch AT ROW 1 COL 89.5
     B-Help AT ROW 1 COL 94
     rsfl-par AT ROW 2.25 COL 11 NO-LABEL WIDGET-ID 2
     BR-wths AT ROW 3.5 COL 1
     mark-num AT ROW 1 COL 11 NO-LABEL
     "Статус" VIEW-AS TEXT
          SIZE 7 BY .67 AT ROW 2.42 COL 3 WIDGET-ID 12
          FGCOLOR 4 
     SPACE(89.37) SKIP(16.73)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Справочник серий материальных ценностей"
         CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BR-wths rsfl-par Dialog-Frame */
ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR BUTTON B-parts IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN 
       B-parts:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN mark-num IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-wths
/* Query rebuild information for BROWSE BR-wths
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH X_wth-ser
      WHERE IF rsfl-par = 0 THEN X_wth-ser.stts = 0 ELSE (IF rsfl-par = 1 THEN (X_wth-ser.stts = 0 AND X_wth-ser.qnty > 0) ELSE (IF rsfl-par = 2 THEN X_wth-ser.stts > 0 ELSE TRUE) ) NO-LOCK,
      FIRST X_wealth WHERE X_wealth.wth-code = X_wth-ser.wth-code NO-LOCK,
      EACH X_wth-par WHERE X_wth-par.par-code = X_wth-ser.par-code NO-LOCK,
      EACH X_wth-gds WHERE X_wth-gds.wth-code = X_wealth.wth-code NO-LOCK,
      EACH X_goods WHERE X_goods.gds-code = X_wth-gds.gds-code NO-LOCK.
     _END_FREEFORM
     _Options          = "NO-LOCK"
     _TblOptList       = ", FIRST,,,"
     _Where[1]         = "IF rsfl-par = 0 THEN X_wth-ser.stts = 0 ELSE (IF rsfl-par = 1 THEN (X_wth-ser.stts = 0 AND X_wth-ser.qnty > 0) ELSE (IF rsfl-par = 2 THEN X_wth-ser.stts > 0 ELSE TRUE) )"
     _JoinCode[2]      = "X_wealth.wth-code = X_wth-ser.wth-code"
     _JoinCode[3]      = "X_wth-par.par-code = X_wth-ser.par-code"
     _JoinCode[4]      = "X_wth-gds.wth-code = X_wealth.wth-code"
     _JoinCode[5]      = "X_goods.gds-code = X_wth-gds.gds-code"
     _Query            is NOT OPENED
*/  /* BROWSE BR-wths */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Справочник серий материальных ценностей */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-add Dialog-Frame
ON CHOOSE OF B-add IN FRAME Dialog-Frame /* Добавить */
DO:

define variable glog as logical no-undo .
define variable rep-rec as recid no-undo .
{ gbl/chk-actg.i
v-cntxt-db-num
v-cntxt-userid
{&action-head-code-main}
'actn_wth-ser':U
{&cntxt-global}
0
'':U
0
0
0
0
true
glog
}
if NOT glog then return no-apply.
run ref/wthsform.w (
                 input parparentproc
                ,input p-curr-host-code
                ,input p-curr-obj-type
                ,input p-curr-obj-code
                , 0 /*ser-code*/
                , 0 /*db-num*/
                ,input (if (p-list-mode = {&wealth} or p-list-mode = {&wth-par}) and avail b-wealth then b-wealth.wth-code else 0)
                ,INPUT (if p-list-mode = {&wth-par} and avail b-wth-par then b-wth-par.par-code else 0) /*par-code*/
                ,input {&add-def}
                ,output rep-rec).
if rep-rec <> ? then do:
  v-doc-rec = rep-rec.
  RUn OpenBr in this-procedure .
  apply "entry" to BR-wths in frame {&frame-name}.
end.
else do:
  apply "entry" to BR-wths in frame {&frame-name}.
  return no-apply.
end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-chg Dialog-Frame
ON CHOOSE OF B-chg IN FRAME Dialog-Frame /* Изменить */
DO:
IF NOT AVAILABLE X_wth-ser THEN RETURN.
define variable glog as logical no-undo .
define variable rep-rec as recid no-undo .
if not available X_wth-ser then do:
  message "Неправильно выбрана строка.".
  return no-apply.
end.
if X_wth-ser.stts = 1 then do:
  message substitute("Изменение записи со статусом &1 невозможно!",{&deleted-stat_}).
  return no-apply.
end.
{ gbl/chk-actg.i
v-cntxt-db-num
v-cntxt-userid
{&action-head-code-main}
'actn_wth-ser':U
{&cntxt-global}
0
'':U
0
0
0
0
true
glog
}
if NOT glog then return no-apply.
run ref/wthsform.w (
                 input parparentproc
                ,input p-curr-host-code
                ,input p-curr-obj-type
                ,input p-curr-obj-code
                ,INPUT X_wth-ser.ser-code
                ,input X_wth-ser.db-num
                ,input X_wth-ser.wth-code
                ,INPUT X_wth-ser.par-code /*par-code*/
                ,input  {&update}
                ,output rep-rec).

if rep-rec <> ? then do:
  v-doc-rec = rep-rec.
  RUn OpenBr in this-procedure .
  apply "entry" to BR-wths in frame {&frame-name}.
end.
else do:
  apply "entry" to BR-wths in frame {&frame-name}.
  return no-apply.
end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-del Dialog-Frame
ON CHOOSE OF B-del IN FRAME Dialog-Frame /* Удалить */
DO:
define variable del-rec as recid no-undo.
define variable glog as logical no-undo .
define variable rep-rec as recid no-undo .

if not available X_wth-ser then do:
  message "Неправильно выбрана строка.".
  return no-apply.
end.


{ gbl/chk-actg.i
v-cntxt-db-num
v-cntxt-userid
{&action-head-code-main}
'actn_wth-ser':U
{&cntxt-global}
0
'':U
0
0
0
0
true
glog
}
if NOT glog then return no-apply.
rep-rec = recid (X_wealth).
glog = no.
      message
        substitute("Удалить серию &1 (код: &2)~nВы уверены?",X_wth-ser.series ,X_wth-ser.ser-code)
      view-as alert-box question buttons OK-Cancel update glog.
      if not glog then do:
        apply "entry" to {&BROWSE-NAME} in frame {&frame-name}.
        return no-apply.
      end.
      run waitfram-show in this-procedure (  input "Ждите...").
      run ref/wth-ser2.p (
                         INPUT RECID(X_wth-ser)
                        ,INPUT yes
                        ,1
                        ) NO-ERROR.
      IF ERROR-STATUS:ERROR THEN DO:
        run waitfram-hide in this-procedure .
        message return-value + error-status:get-message(1) view-as alert-box error.
      END.
      ELSE DO:
        RUN OpenBr.
      END.
 END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-hist
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-hist Dialog-Frame
ON CHOOSE OF B-hist IN FRAME Dialog-Frame /* История */
DO:
  IF NOT AVAILABLE X_wth-ser THEN RETURN NO-APPLY.
  define variable v-rid-list  as   character            no-undo .
  define variable v-host-code like ub.sysconf.host-code no-undo .
  run ref/cwthhist.w (
                   input parparentproc
                 , input p-curr-host-code
                 , input p-curr-obj-type
                 , input p-curr-obj-code
                 , input "":U          /* bttns */
                 , input "subject":U       /* p-mode */
                 , input X_wth-ser.wth-code /*p-wth-code*/
                 , INPUT X_wth-ser.par-code             /*p-par-code*/
                 , input ?             /* p-host-code */
                 , input ?             /* p-obj-type*/
                 , input ?             /* p-obj-code*/
                 , input ?             /* p-corr-user-db-num */
                 , input "":U          /* p-corr-user-name */
                 , input {&table_wth-ser}   /* p-subject */
                 , input g#db-num      /* p-db-num */
                 , input X_wth-ser.ser-code
                 , input X_wth-ser.db-num
                 , input-output v-rid-list
                 ) no-error .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-lkp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-lkp Dialog-Frame
ON CHOOSE OF b-lkp IN FRAME Dialog-Frame /* Просмотр */
DO:
    define variable rep-rec as recid no-undo .
    if not available X_wth-ser then do:
      message "Неправильно выбрана строка.".
      return no-apply.
    end.
    rep-rec = recid (X_wth-ser).

run ref/wthsform.w (
                 input parparentproc
                ,input p-curr-host-code
                ,input p-curr-obj-type
                ,input p-curr-obj-code
                ,INPUT X_wth-ser.ser-code
                ,input X_wth-ser.db-num
                ,input X_wth-ser.wth-code
                ,INPUT X_wth-ser.par-code /*par-code*/
                ,input  {&LOOKUP}
                ,output rep-rec).
     apply "entry" to br-wths in frame {&frame-name}.
     return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mark Dialog-Frame
ON CHOOSE OF B-mark IN FRAME Dialog-Frame /* * */
DO:
define variable glog as logical no-undo .
  if available X_wth-ser then do:
    { gbl/markstrn.i X_wth-ser rid-list }
    br-wths:refresh().
    if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
            glog = br-wths:select-next-row ().
            apply "iteration-changed" to br-wths in frame {&frame-name}.
        end.
    if num-entries( rid-list ) = 0 then
        hide mark-num in frame {&frame-name}.
    else
        disp num-entries( rid-list ) @ mark-num with frame {&frame-name}.
  end.
  apply "entry" to br-wths in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-parts
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-parts Dialog-Frame
ON CHOOSE OF B-parts IN FRAME Dialog-Frame /* Партии */
DO:
define variable glog as logical no-undo .
define variable rep-rec as recid no-undo .
if not available X_wth-ser then return.
run str/wthparts.w (
                 input parparentproc
                ,input p-curr-host-code
                ,input p-curr-obj-type
                ,input p-curr-obj-code
                ,input {&wth-ser}
                ,input {&LOOKUP}
                ,input X_wth-ser.wth-code
                ,input X_wth-ser.par-code
                ,input X_wth-ser.ser-code
                ,INPUT X_wth-ser.db-num
                ,input 0
                ,INPUT '':U
                ,INPUT '':U
                ,input 0
                ,input '':U).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-print Dialog-Frame
ON CHOOSE OF B-print IN FRAME Dialog-Frame /* Печать */
DO:
define variable doc-rec as recid no-undo .
    doc-rec = recid( X_wth-ser ).
    DO WHILE available X_wth-ser :
          GET prev br-wths.
    END.
  run PrintProc in this-procedure no-error.
  reposition br-wths to recid doc-rec no-error.
  apply "entry" to br-wths in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-quit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-quit Dialog-Frame
ON CHOOSE OF b-quit IN FRAME Dialog-Frame /* Выход */
DO:
  assign rid-list = ''
  .
  RUN save-position IN THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-sch
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-sch Dialog-Frame
ON CHOOSE OF B-sch IN FRAME Dialog-Frame /* Фильтр */
DO:
  assign
  tbl = 'wth-ser'
  join-tbl = 'X_wth-ser'
  dim = '0':U
  fld = '':U
  lab = '':U
  spr = '':U
  .
  run fltfield-add in this-procedure('wth-code', 'Код МЦ', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('ser-code', '', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('series', '', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('maska', '', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
/*   run fltfield-add in this-procedure('par-rate', '', '',                             */
/*   input-output fld, input-output lab, input-output spr, input-output dim)  no-error. */
/*   run fltfield-add in this-procedure('par-feat', '', '',                             */
/*   input-output fld, input-output lab, input-output spr, input-output dim)  no-error. */

    DO on stop undo, leave:
        run gbl/filter.w ( input parparentproc
                         , input filter-point
                         , input tbl
                         , input join-tbl
                         , input  fld
                         , input lab
                         , input spr
                         , input dim).
        RUN OpenBr in this-procedure .
    END .


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-sel Dialog-Frame
ON CHOOSE OF B-sel IN FRAME Dialog-Frame /* Выбор */
DO:
    if ( available X_wth-ser AND rid-list = "" ) then
        rid-list = string( recid( X_wth-ser ) ) .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-wths
&Scoped-define SELF-NAME BR-wths
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-wths Dialog-Frame
ON MOUSE-SELECT-DBLCLICK OF BR-wths IN FRAME Dialog-Frame
DO:
    if lookup("b-sel", bttns) > 0 then APPLY "CHOOSE" to b-sel.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-wths Dialog-Frame
ON RETURN OF BR-wths IN FRAME Dialog-Frame
DO:
    if lookup("b-sel", bttns) > 0 then APPLY "CHOOSE" to b-sel.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME rsfl-par
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rsfl-par Dialog-Frame
ON VALUE-CHANGED OF rsfl-par IN FRAME Dialog-Frame
DO:
  RUN OpenBr.
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
{ gbl/setfltnm.i }
{ gbl/hot-key.i b-mark }
{ gbl/hot-key.i b-add }
{ gbl/hot-key.i b-chg }
{ gbl/hot-key.i b-del }
{ gbl/hot-key.i b-sel }
&scop b-quit ~{&b-exit~}
{ gbl/hot-key.i b-quit }
{ gbl/hot-key.i b-print }
{ gbl/brwrepos.i
&browse-name = "BR-wths"
&line-num=5
}
/* { gbl/brwrefre.i " v-doc-rec = ?. if available X_wth-par then assign v-doc-rec = recid(X_wth-par). run openbr in this-procedure . ~  */
/*                reposition BR-wths to recid v-doc-rec no-error. APPLY 'ENTRY' to BR-wths. APPLY 'VALUe-CHANGED' to BR-wths. " }   */


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  { gbl/getcntxt.i get }

  if p-list-mode = {&wealth} OR p-list-mode = {&wth-par} then do:
    FIND FIRST b-wealth No-LOCK where
                b-wealth.wth-code = pwth-code No-ERROR.
    IF NOT AVAIL b-wealth then do:
      message vss-workfile vss-revision vss-description skip
      "Не найдена материальная ценность с кодом " pwth-code
      view-as alert-box.
      return error.
    end.
  end.
  if p-list-mode = {&wth-par} then do:
    FIND FIRST b-wth-par No-LOCK where
                 b-wth-par.wth-code = pwth-code AND
                 b-wth-par.par-code = ppar-code No-ERROR.
    IF NOT AVAIL  b-wth-par then do:
      message vss-workfile vss-revision vss-description skip
      substitute("Не найдена номинал материальной ценности.~nКод МЦ &1~nКод номинала &2",pwth-code,ppar-code)
      view-as alert-box.
      return error.
    end.
  end.

  if rid-list <> '':U then do:
    assign
    v-doc-rec = integer(rid-list)
    no-error .
  end.
  RUN Myenable in this-procedure .
  RUN OpenBR in this-procedure .
  APPLY "ENTRY" to BR-wths.

  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI in this-procedure .

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
  DISPLAY rsfl-par mark-num 
      WITH FRAME Dialog-Frame.
  ENABLE b-quit B-mark B-sel B-add B-chg b-lkp B-del B-print B-hist B-sch 
         B-Help rsfl-par BR-wths mark-num 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE load-position Dialog-Frame 
PROCEDURE load-position :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable v-current-stts-string       as character    no-undo.
define variable v-void-logical              as logical      no-undo.
define variable v-void-character            as character    no-undo.
define variable v-found                     as logical      no-undo.

do   with frame {&frame-name}
on error undo, return error
:
    run uf-get (
          input {&current-position-stts}
        , input v-cntxt-userid
        , output v-current-stts-string
        , output v-void-character
        , output v-void-logical
        , output v-void-logical
        , output v-void-logical
        , output v-void-logical
    ) no-error.
    if not error-status :error then rsfl-par:screen-value =  v-current-stts-string.
 end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame 
PROCEDURE MyEnable :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable glog as logical no-undo .
    ENABLE
      BR-wths
      b-quit
      b-parts
      b-mark WHEN LOOKUP("b-mark":U, bttns) > 0
      b-sel  WHEN LOOKUP("b-sel":U, bttns) > 0
      b-print
      b-sch
      b-lkp
      b-help
      b-add WHEN (LOOKUP("b-add":U, bttns) > 0 )    AND g#db-num = 0
      b-del WHEN (LOOKUP("b-del":U, bttns) > 0 )    AND g#db-num = 0
      b-chg WHEN (LOOKUP("b-chg":U, bttns) > 0 )    AND g#db-num = 0
      b-hist
      rsfl-par
      WITH FRAME {&frame-name}.
      run load-position in this-procedure.
      VIEW FRAME {&frame-name}.
      if available X_wth-par then
      glog = BR-wths:select-focused-row( ).
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OpenBr Dialog-Frame 
PROCEDURE OpenBr :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable l-query-was-opened as logical no-undo .
ASSIGN FRAME {&FRAME-NAME} rsfl-par.


run waitfram-show in this-procedure (  input "Ждите...").

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

&scop flt-open-debug-file
&scop flt-open-query-handle query BR-wths:handle
&scop flt-open-dyn_open-query  FOR EACH X_wth-ser


&scop flt-open-open-query OPEN QUERY BR-wths FOR EACH X_wth-ser
/* OPEN QUERY BR-wths FOR EACH X_wth-ser WHERE IF rsfl-par = 0 THEN X_wth-ser.stts = 0 ELSE (IF rsfl-par = 1 THEN (X_wth-ser.stts = 0 AND X_wth-ser.qnty > 0) ELSE (IF rsfl-par = 2 THEN X_wth-ser.stts > 0 ELSE TRUE) ) */

&scop flt-open-open-query-tail  ,       FIRST X_wealth WHERE X_wealth.wth-code = X_wth-ser.wth-code NO-LOCK, ~
      FIRST X_wth-par WHERE X_wth-par.par-code = X_wth-ser.par-code NO-LOCK, ~
      FIRST X_wth-gds WHERE X_wth-gds.wth-code = X_wealth.wth-code NO-LOCK, ~
      FIRST X_goods WHERE X_goods.gds-code = X_wth-gds.gds-code NO-LOCK

/* where X_wealth.wth-code = X_wth-ser.wth-code */

&scop flt-open-query-was-opened  l-query-was-opened

&scop flt-open-sort-column-phrase sort-column-phrase

&scop flt-open-call-point filter-point

&scop flt-open-set-filter-name set-filter-name

&scop flt-open-indexed-reposition

&scop flt-open-waitfram yes

CASE p-list-mode:
    when {&all} then do:
        ASSIGN frame {&frame-name}:TITLE = "Серии материальных ценностей "
        filter-point = "Серии материальных ценностей " + p-list-mode.
          { gbl/fltopend.i
           &where-cond = " (IF rsfl-par = 0 THEN X_wth-ser.stts = 0    ~
                           ELSE (IF rsfl-par = 1 THEN (X_wth-ser.stts = 0 AND X_wth-ser.qnty > 0) ~
                                 ELSE (IF rsfl-par = 2 THEN X_wth-ser.stts > 0 ELSE TRUE) )) "
            &use-ind = "  "
            &by = "   "
            &dyn_where-cond = " substitute(' (IF &1 = 0 THEN X_wth-ser.stts = 0 ~
                           ELSE (IF &1 = 1 THEN (X_wth-ser.stts = 0 AND X_wth-ser.qnty > 0) ~
                                 ELSE (IF &1 = 2 THEN X_wth-ser.stts > 0 ELSE TRUE) )) ',    ~
                                 rsfl-par) "

          }
    end.
    when {&wealth} then do:
        ASSIGN frame {&frame-name}:TITLE = "Серии материальной ценности " + b-wealth.wth-name
        filter-point = "Серии материальных ценностей " + p-list-mode.
          { gbl/fltopend.i
            &where-cond = " (IF rsfl-par = 0 THEN X_wth-ser.stts = 0 ELSE (IF rsfl-par = 1 THEN (X_wth-ser.stts = 0 AND X_wth-ser.qnty > 0) ELSE (IF rsfl-par = 2 THEN X_wth-ser.stts > 0 ELSE TRUE) )) and X_wth-ser.wth-code = pwth-code "
            &use-ind = "  "
            &by = "  "
           &dyn_where-cond = " substitute(' (IF &1 = 0 THEN X_wth-ser.stts = 0 ELSE (IF &1 = 1 THEN (X_wth-ser.stts = 0 AND X_wth-ser.qnty > 0) ELSE (IF &1 = 2 THEN X_wth-ser.stts > 0 ELSE TRUE) )) and X_wth-ser.wth-code = pwth-code ', rsfl-par ) "
          }
    end.
    when {&wth-par} then do:
        ASSIGN frame {&frame-name}:TITLE = substitute("Серии номинала &2 &3 материальной ценности &1" ,b-wealth.wth-name,b-wth-par.par-val,b-wth-par.par-unit)
        filter-point = "Серии материальных ценностей " + p-list-mode.
          { gbl/fltopend.i
            &where-cond = " (IF rsfl-par = 0 THEN X_wth-ser.stts = 0 ELSE (IF rsfl-par = 1 THEN (X_wth-ser.stts = 0 AND X_wth-ser.qnty > 0) ELSE (IF rsfl-par = 2 THEN X_wth-ser.stts > 0 ELSE TRUE) )) and X_wth-ser.wth-code = pwth-code and X_wth-ser.par-code = ppar-code "
            &use-ind = "  "
            &by = "  "
            &dyn_where-cond = " substitute(' (IF &1 = 0 THEN X_wth-ser.stts = 0 ELSE (IF &1 = 1 THEN (X_wth-ser.stts = 0 AND X_wth-ser.qnty > 0) ELSE (IF &1 = 2 THEN X_wth-ser.stts > 0 ELSE TRUE) )) and X_wth-ser.wth-code = pwth-code and X_wth-ser.par-code = ppar-code ',~
                                  rsfl-par  ) "
          }
    end.

END CASE.

if v-doc-rec <> ? then reposition BR-wths to recid v-doc-rec no-error.
apply "entry" to BR-wths in frame {&frame-name}.
run waitfram-hide in this-procedure .

if avail X_wth-ser then
APPLY "VALUE-CHANGED":U to BR-wths.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE PrintProc Dialog-Frame 
PROCEDURE PrintProc :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable date_string     as      char    no-undo.
define variable Line                as      char    no-undo.
define variable for-time as char.

DEFINE FRAME Wth-List
X_wth-ser.ser-code    column-label "Код"
X_wth-ser.db-num      column-label "№ БД"
X_wth-ser.series      column-label "Серия"    format 'x(10)'
X_wth-ser.maska       column-label "Маска"
X_wealth.wth-code     column-label "Код МЦ"
X_wealth.wth-name     column-label "Название"  format 'x(15)'
X_wth-par.par-val     column-label "Номинал"
X_goods.artic         column-label "Артикул"
X_goods.gds-name      column-label "Товар"     format 'x(15)'
X_wth-ser.stts        column-label "Статус"
HEADER  date_string AT 5 format "X(35)"
string( "Страница " ) format "X(9)" AT 100 PAGE-NUMBER(PrnLibStream) AT 110 FORMAT ">>9" SKIP
Line format "X(138)" AT 1
with width {&A4_CW} down stream-io use-text    .
Line = fill("-", 122).
date_string = cur-time-print() .

run prn-lib-open-stream  in this-procedure (
                                             input parParentProc
                                            ,input {&Cs_PS}
                                            ,input yes /*p-is-stream*/
                                            ,input no /*p-append*/
                                            ).

PUT  STREAM PrnLibStream
SPACE(25) ( frame {&frame-name}:title )
format "x(90)" SKIP(1) .
FORM HEADER
Line AT 1 SKIP
"Продолжение - на следующей странице" AT 30 SKIP
with FRAME BottomFrame width {&A4_CW} PAGE-BOTTOM NO-LABELS NO-BOX .
VIEW  STREAM PrnLibStream FRAME BottomFrame .

FORM with FRAME Wth-List  .
run waitfram-show in this-procedure ( input "Ждите...").
GET next BR-wths.
DO WHILE available X_wth-ser :
  Display STREAM PrnLibStream
  X_wth-ser.ser-code
  X_wth-ser.db-num
  X_wth-ser.series
  X_wth-ser.maska
  X_wealth.wth-code
  X_wealth.wth-name
  X_wth-par.par-val
  X_goods.artic
  X_goods.gds-name
  X_wth-ser.stts
  with FRAME Wth-List .
  DOWN STREAM PrnLibStream 1 with FRAME Wth-List  .
  GET next BR-wths.
END.
UNDERLINE  STREAM PrnLibStream
  X_wth-ser.ser-code
  X_wth-ser.db-num
  X_wth-ser.series
  X_wth-ser.maska
  X_wealth.wth-code
  X_wealth.wth-name
  X_wth-par.par-val
  X_goods.artic
  X_goods.gds-name
  X_wth-ser.stts
with FRAME Wth-List .
HIDE  STREAM PrnLibStream FRAME BottomFrame .
HIDE  STREAM PrnLibStream FRAME CheckList.
output  STREAM PrnLibStream CLOSE.
run waitfram-hide in this-procedure .

run prn-lib-prn-file in this-procedure (
                                          input parParentProc
                                          ,input 0
                                          ).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE save-position Dialog-Frame 
PROCEDURE save-position :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
 do
with frame {&frame-name}
on error undo, return error
:
assign rsfl-par.
        run uf-set (
              input {&current-position-stts}
            , input v-cntxt-userid
            , input string( rsfl-par )
            , input {&current-position-stts}
            , input no
            , input no
            , input no
            , input no
        ) no-error.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-curr Dialog-Frame 
FUNCTION get-curr RETURNS CHARACTER
  ( buffer loc-X_wealth for X_wealth ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/

if loc-X_wealth.curr-code = ? then
return loc-X_wealth.unit-base.
FIND FIRST ub.currency no-lock where ub.currency.curr-code = loc-X_wealth.curr-code No-ERROR.

if avail ub.currency then
  RETURN ub.currency.curr-abbr.   /* Function return value. */
else return "".


END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION mark-string Dialog-Frame 
FUNCTION mark-string RETURNS CHARACTER
  ( input par-recid as recid, input mark-list as character ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/

    RETURN ( IF LOOKUP( STRING( par-recid ), mark-list ) > 0 THEN "*" ELSE "":U ).

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

