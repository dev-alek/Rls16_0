&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER X_wealth FOR ub.wealth.
DEFINE BUFFER X_wth-par FOR ub.wth-par.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Справочник номиналов материальных ценностей

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/21/06
Author: Bakhtadze Natalya
Creation date: 03/21/06

*/


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
define input-output param p-rid-list as char no-undo.



/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Справочник номиналов материальных ценностей ".
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
{ cmp/mrk-strf.i }
{ str/wth-lib.i  }
{ gbl/fltopend.i defproc }

define buffer b-wealth for ub.wealth.
define variable filter-label as character no-undo init "Номиналы_МЦ" .
define variable filter-label0 as character no-undo init "Номиналы_МЦ" .
define variable filter-point as character no-undo init "wthp-ref" .
define variable filter-point0 as character no-undo init "wth-pref" .

define variable sort-column-name as character no-undo .
define variable ri          as      recid   no-undo     init ? .
define variable choice as log no-undo.
define variable mark as char no-undo.
define variable v-doc-rec as recid no-undo .
define variable v-rid-list as character no-undo .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BR-wthp

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_wth-par X_wealth

/* Definitions for BROWSE BR-wthp                                       */
&Scoped-define FIELDS-IN-QUERY-BR-wthp mark-string(recid(X_wth-par), v-rid-list) X_wth-par.par-code (if X_wealth.stts = 0 then X_wealth.wth-name else substring (X_wealth.wth-name, 1, 15) + {&deleted-stat_}) X_wth-par.par-val X_wth-par.par-unit X_wth-par.par-rate X_wealth.curr-code get-curr(buffer X_wealth) X_wth-par.par-feat
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-wthp
&Scoped-define SELF-NAME BR-wthp
&Scoped-define QUERY-STRING-BR-wthp FOR EACH X_wth-par NO-LOCK, ~
             FIRST X_wealth WHERE X_wealth.wth-code = X_wth-par.wth-code NO-LOCK
&Scoped-define OPEN-QUERY-BR-wthp OPEN QUERY {&SELF-NAME} FOR EACH X_wth-par NO-LOCK, ~
             FIRST X_wealth WHERE X_wealth.wth-code = X_wth-par.wth-code NO-LOCK.
&Scoped-define TABLES-IN-QUERY-BR-wthp X_wth-par X_wealth
&Scoped-define FIRST-TABLE-IN-QUERY-BR-wthp X_wth-par
&Scoped-define SECOND-TABLE-IN-QUERY-BR-wthp X_wealth


/* Definitions for DIALOG-BOX Dialog-Frame                              */

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit B-mark B-sel B-add B-chg B-del ~
B-print B-hist B-sch B-Help BR-wthp mark-num
&Scoped-Define DISPLAYED-OBJECTS mark-num

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
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
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-hist
     LABEL "Ис&тория"
     SIZE 3 BY 1.

DEFINE BUTTON B-mark
     LABEL "&*"
     SIZE 3 BY 1.

DEFINE BUTTON B-parts
     LABEL "&Партии"
     SIZE 10 BY 1.

DEFINE BUTTON B-print
     LABEL "Пе&чать"
     SIZE 3 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-sch
     LABEL "&Фильтр"
     SIZE 3 BY 1.

DEFINE BUTTON B-sel AUTO-GO
     LABEL "Вы&бор"
     SIZE 10 BY 1.

DEFINE BUTTON B-series
     LABEL "&Серии"
     SIZE 10 BY 1.

DEFINE VARIABLE mark-num AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 4.63 BY 1
     FGCOLOR 4  NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-wthp FOR
      X_wth-par,
      X_wealth SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-wthp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-wthp Dialog-Frame _FREEFORM
  QUERY BR-wthp NO-LOCK DISPLAY
      mark-string(recid(X_wth-par), v-rid-list) COLUMN-LABEL "*" FORMAT "X(1)":U
X_wth-par.par-code COLUMN-LABEL "Код!номинала" FORMAT "999999999":U
(if X_wealth.stts = 0
then X_wealth.wth-name
else substring (X_wealth.wth-name, 1, 15) + {&deleted-stat_}) COLUMN-LABEL "Название" FORMAT "X(42)":U
X_wth-par.par-val FORMAT ">>>>>>9":U
X_wth-par.par-unit COLUMN-LABEL "Ед изм!номинала" FORMAT "X(10)":U
X_wth-par.par-rate FORMAT ">>,>>9.<<<<":U
X_wealth.curr-code COLUMN-LABEL "Код!вал" FORMAT ">>9":U
get-curr(buffer X_wealth) COLUMN-LABEL "Валюта/!Ед.изм."
X_wth-par.par-feat FORMAT "X(10)":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 97.5 BY 20.88.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-mark AT ROW 1 COL 16
     B-sel AT ROW 1 COL 19
     B-add AT ROW 1 COL 29
     B-chg AT ROW 1 COL 39
     B-del AT ROW 1 COL 49
     B-parts AT ROW 1 COL 59 WIDGET-ID 4
     B-series AT ROW 1 COL 69 WIDGET-ID 6
     B-print AT ROW 1 COL 86
     B-hist AT ROW 1 COL 89
     B-sch AT ROW 1 COL 92
     B-Help AT ROW 1 COL 95
     BR-wthp AT ROW 2.75 COL 1
     mark-num AT ROW 1 COL 11 NO-LABEL
     SPACE(83.11) SKIP(21.70)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Справочник номиналов материальных ценностей"
         CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: X_wealth B "?" ? ub wealth
      TABLE: X_wth-par B "?" ? ub wth-par
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BR-wthp B-Help Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR BUTTON B-parts IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN
       B-parts:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR BUTTON B-series IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN
       B-series:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN mark-num IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-wthp
/* Query rebuild information for BROWSE BR-wthp
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH X_wth-par NO-LOCK,
      FIRST X_wealth WHERE X_wealth.wth-code = X_wth-par.wth-code NO-LOCK.
     _END_FREEFORM
     _Options          = "NO-LOCK"
     _TblOptList       = ", FIRST"
     _JoinCode[2]      = "wealth.wth-code = wth-par.wth-code"
     _Query            is NOT OPENED
*/  /* BROWSE BR-wthp */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Справочник номиналов материальных ценностей */
DO:
  p-rid-list = v-rid-list.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Справочник номиналов материальных ценностей */
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
'actn_wealth_work':U
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
run ref/wthpform.w (
                 input parparentproc
                ,input p-curr-host-code
                ,input p-curr-obj-type
                ,input p-curr-obj-code
                ,input (if p-list-mode = {&wealth} and avail b-wealth then b-wealth.wth-code else 0)
                ,input 0
                ,input {&add-def}
                ,output rep-rec).
if rep-rec <> ? then do:
   v-doc-rec = rep-rec.
   RUn OpenBr in this-procedure ( input yes, input no, input '':U).
  apply "entry" to BR-wthp in frame {&frame-name}.
end.
else do:
  apply "entry" to BR-wthp in frame {&frame-name}.
  return no-apply.
end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-chg Dialog-Frame
ON CHOOSE OF B-chg IN FRAME Dialog-Frame /* Изменить */
DO:
define variable rep-rec as recid no-undo .
define variable glog as logical no-undo .
  if not available X_wth-par then do:
  message "Неправильно выбрана строка.".
  return no-apply.
end.
rep-rec = recid ( X_wth-par).
{ gbl/chk-actg.i
v-cntxt-db-num
v-cntxt-userid
{&action-head-code-main}
'actn_wealth_work':U
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
run ref/wthpform.w (
                 input parparentproc
                ,input p-curr-host-code
                ,input p-curr-obj-type
                ,input p-curr-obj-code
                ,input X_wth-par.wth-code
                ,input  X_wth-par.par-code
                ,input {&update}
                ,output rep-rec).
if rep-rec <> ? then do:
   v-doc-rec = rep-rec.
   RUn OpenBr in this-procedure ( input yes, input no, input '':U).
   apply "entry" to br-wthp in frame {&frame-name}.
end.
else do:
  apply "entry" to br-wthp in frame {&frame-name}.
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

if not available X_wth-par then do:
  message "Неправильно выбрана строка.".
  return no-apply.
end.
{ gbl/chk-actg.i
v-cntxt-db-num
v-cntxt-userid
{&action-head-code-main}
'actn_wealth_work':U
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
rep-rec = recid (X_wth-par).
glog = no.
message
"Удалить номинал ?   Вы уверены ?"
view-as alert-box question buttons OK-Cancel update glog.
if glog <> yes then return no-apply.
glog = br-wthp:select-next-row().
if not glog then glog = br-wthp:select-prev-row().
del-rec = recid ( X_wth-par).
_deletion:
do on stop undo _deletion, return no-apply:
  /*поскольку в настоящий момент удаление номинала МЦ невозможно - то  нет и программы которая это обрабатывает
  если будет удаление =- программу придется написать

  r u n   w t h - p d v . p ( input X_wth-par.wth-code,
                              input X_wth-par.par-code,
                              output glog) no-error.

  if error-status:error then return no-apply.
  if not glog then do:
    if return-value <> "" then
    message return-value view-as alert-box ERROR.
    return no-apply.
  end.
  */
  if glog = yes then
  delete X_wth-par.
end.
rep-rec = del-rec.
run OpenBr in this-procedure ( input yes, input no, input '':U).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-hist
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-hist Dialog-Frame
ON CHOOSE OF B-hist IN FRAME Dialog-Frame /* История */
DO:
  IF NOT AVAILABLE X_wth-par THEN RETURN NO-APPLY.
  define variable v-rid-list  as   character            no-undo .
  define variable v-host-code like ub.sysconf.host-code no-undo .
  run ref/cwthhist.w (
                   input        parparentproc
                 , input        p-curr-host-code
                 , input        p-curr-obj-type
                 , input        p-curr-obj-code
                 , input        "":U          /* bttns */
                 , input        "subject":U       /* p-mode */
                 , input        X_wth-par.wth-code /*p-wth-code*/
                 , INPUT        X_wth-par.par-code  /*p-par-code*/
                 , input        ?             /* p-host-code */
                 , input        ?             /* p-obj-type*/
                 , input        ?             /* p-obj-code*/
                 , input        ?             /* p-corr-user-db-num */
                 , input        "":U          /* p-corr-user-name */
                 , input        {&table_wth-par}          /* p-subject */
                 , input        g#db-num      /* p-db-num */
                 , input        ?
                 , input        ?
                 , input-output v-rid-list
                 ) no-error .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mark Dialog-Frame
ON CHOOSE OF B-mark IN FRAME Dialog-Frame /* * */
DO:
define variable glog as logical no-undo .
 if available X_wth-par then do:
    { gbl/markstrn.i X_wth-par v-rid-list }
    br-wthp:refresh().
    if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
            glog = br-wthp:select-next-row ().
            apply "iteration-changed" to br-wthp in frame {&frame-name}.
        end.
    if num-entries( v-rid-list ) = 0 then
        hide mark-num in frame {&frame-name}.
    else
        disp num-entries( v-rid-list ) @ mark-num with frame {&frame-name}.
  end.
  apply "entry" to br-wthp in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-parts
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-parts Dialog-Frame
ON CHOOSE OF B-parts IN FRAME Dialog-Frame /* Партии */
DO:

if not available X_wth-par then do:
  message "Неправильно выбрана строка.".
  return no-apply.
end.

run str/wthparts.w (
                 input parparentproc
                ,input p-curr-host-code
                ,input p-curr-obj-type
                ,input p-curr-obj-code
                ,input {&wth-par}
                ,input {&LOOKUP}
                ,input X_wth-par.wth-code
                ,input X_wth-par.par-code
                ,INPUT 0
                ,INPUT 0
                ,INPUT '':U
                ,input 0
                ,INPUT '':U
                ,INPUT 0
                ,INPUT '':U )  no-error.
if error-status:error then do:
  message return-value
          skip error-status:get-message(1)
  view-as alert-box.
end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-print Dialog-Frame
ON CHOOSE OF B-print IN FRAME Dialog-Frame /* Печать */
DO:
define variable doc-rec as recid no-undo .
    doc-rec = recid( X_wth-par ).

    DO WHILE available X_wth-par :
          GET prev br-wthp.
    END.
  run PrintProc in this-procedure no-error.
  reposition br-wthp to recid doc-rec no-error.
  apply "entry" to br-wthp in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-sch
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-sch Dialog-Frame
ON CHOOSE OF B-sch IN FRAME Dialog-Frame /* Фильтр */
DO:
  assign
  tbl = 'wth-par'
  join-tbl = 'X_wth-par'
  dim = '0':U
  fld = '':U
  lab = '':U
  spr = '':U
  .
  run fltfield-add in this-procedure('wth-code', '', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('par-code', '', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('par-val', '', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('par-unit', '', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('par-rate', '', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('par-feat', '', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.

    DO on stop undo, leave:
        run gbl/filter.w ( input parparentproc
                         , input (filter-point + {&delim-par} + filter-label)
                         , input tbl
                         , input join-tbl
                         , input  fld
                         , input lab
                         , input spr
                         , input dim).
        RUN OpenBr in this-procedure ( input yes, input no, input '':U).
    END .


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-sel Dialog-Frame
ON CHOOSE OF B-sel IN FRAME Dialog-Frame /* Выбор */
DO:
    if ( available X_wth-par AND
    (v-rid-list = ""
    or
    b-mark:sensitive = no)
    ) then
        v-rid-list = string( recid( X_wth-par ) ) .


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-series
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-series Dialog-Frame
ON CHOOSE OF B-series IN FRAME Dialog-Frame /* Серии */
DO:

define variable rep-rec as CHAR no-undo .
if not available X_wth-par then do:
  message "Неправильно выбрана строка.".
  return no-apply.
end.

      run ref/wths-ref.w
        (input parparentproc
        ,input (if p-list-mode = {&lookup} then "":U else 'b-add,b-chg,b-del':u )
        ,input v-cntxt-host-code-obj
        ,input v-cntxt-obj-type
        ,input v-cntxt-obj-code
        ,input {&wth-par}
        ,input X_wth-par.wth-code
        ,input X_wth-par.par-code
        ,input-output rep-rec
        ) .


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-wthp
&Scoped-define SELF-NAME BR-wthp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-wthp Dialog-Frame
ON MOUSE-SELECT-DBLCLICK OF BR-wthp IN FRAME Dialog-Frame
DO:
    if lookup("b-sel", bttns) > 0 then APPLY "CHOOSE" to b-sel.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-wthp Dialog-Frame
ON RETURN OF BR-wthp IN FRAME Dialog-Frame
DO:
    if lookup("b-sel", bttns) > 0 then APPLY "CHOOSE" to b-sel.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-wthp Dialog-Frame
ON VALUE-CHANGED OF BR-wthp IN FRAME Dialog-Frame
DO:
  IF AVAILABLE X_wealth AND X_wealth.is-ser <> 0 THEN DO:
      ENABLE b-parts b-series WITH FRAME {&FRAME-NAME}.
  END.
  ELSE DO:
    DISABLE b-parts b-series WITH FRAME {&FRAME-NAME}.
  END.
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
&browse-name = "br-wthp"
&line-num=5
}
{ gbl/brwrefre.i " v-doc-rec = ?. if available X_wth-par then assign v-doc-rec = recid( X_wth-par). run openbr in this-procedure ( input yes, input no, input '':U). ~
               reposition br-wthp to recid v-doc-rec no-error. APPLY 'ENTRY' to br-wthp. APPLY 'VALUe-CHANGED' to br-wthp. " }


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  { gbl/getcntxt.i get }
  if p-list-mode = {&wealth} then do:
    FIND FIRST b-wealth No-LOCK where
                b-wealth.wth-code = pwth-code No-ERROR.
    IF NOT AVAIL b-wealth then do:
      message vss-workfile vss-revision vss-description skip
      "Не найдена материальная ценность с кодом " pwth-code
      view-as alert-box.
      return error.
    end.
  end.
  v-rid-list = p-rid-list.
  if v-rid-list <> '':U then do:
    assign
    v-doc-rec = integer(v-rid-list)
    no-error .
  end.
  RUN Myenable in this-procedure .
  RUN OpenBR in this-procedure ( input yes, input no, input '':U).
  APPLY "ENTRY" to br-wthp.

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
  DISPLAY mark-num
      WITH FRAME Dialog-Frame.
  ENABLE b-quit B-mark B-sel B-add B-chg B-del B-print B-hist B-sch B-Help
         BR-wthp mark-num
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
define variable glog as logical no-undo .
ENABLE
br-wthp
b-quit
b-mark WHEN LOOKUP("b-mark":U, bttns) > 0
b-sel  WHEN LOOKUP("b-sel":U, bttns) > 0
b-print
b-sch
b-help
b-parts
b-series
b-add WHEN (LOOKUP("b-add":U, bttns) > 0 AND g#db-num = 0)
/*      b-del WHEN (LOOKUP("b-add":U, bttns) > 0 AND LOOKUP({&office}, to-ARM) > 0)*/
b-chg WHEN (LOOKUP("b-add":U, bttns) > 0 AND g#db-num = 0)
b-hist
WITH FRAME {&frame-name}.
VIEW FRAME {&frame-name}.
HIDE
b-del in FRAME {&frame-name}.
if available X_wth-par then
glog = br-wthp:select-focused-row( ).
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OpenBr Dialog-Frame
PROCEDURE OpenBr :
define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .
define variable l-query-was-opened as logical no-undo .

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

&scop flt-open-open-query OPEN QUERY br-wthp FOR EACH X_wth-par

&scop flt-open-dyn_open-query FOR EACH X_wth-par

&scop flt-open-query-handle QUERY br-wthp:handle

&scop flt-open-open-query-tail  , FIRST X_wealth NO-LOCK where X_wealth.wth-code = X_wth-par.wth-code



&scop flt-open-query-was-opened  l-query-was-opened

&scop flt-open-sort-column-phrase sort-column-phrase

&scop flt-open-call-point filter-point

&scop flt-open-set-filter-name set-filter-name

&scop flt-open-indexed-reposition

&scop flt-open-waitfram yes

CASE p-list-mode:
    when {&all} then do:
        ASSIGN
        frame {&frame-name}:TITLE = "Номиналы материальных ценностей "
        filter-point = "Номиналы материальных ценностей " + p-list-mode
        filter-label = substitute("&1", filter-label0)
        .
          { gbl/fltopend.i
            &where-cond = " true "
            &use-ind = "  "
            &by = "  "
          }
    end.
    when 'ser_wealth':U then do:
                ASSIGN
        frame {&frame-name}:TITLE = "Номиналы серийных МЦ "
        filter-point = "Номиналы серийных МЦ " + p-list-mode
        filter-label = substitute("&1 Одна МЦ", filter-label0)
        .
          { gbl/fltopend.i
            &where-cond = " "
            &use-ind = " and x_wealth.is-ser = 1  "
            &by = "  "
          }

    end.
    when {&wealth} then do:
        ASSIGN
        frame {&frame-name}:TITLE = "Номиналы материальной ценности " + b-wealth.wth-name
        filter-point = "Номиналы материальных ценностей " + p-list-mode
        filter-label = substitute("&1 Одна МЦ", filter-label0)
        .
          { gbl/fltopend.i
            &where-cond = " X_wth-par.wth-code = pwth-code "
            &dyn_where-cond = " substitute('X_wth-par.wth-code = &1', pwth-code) "
            &use-ind = "  "
            &by = "  "
          }
    end.
END CASE.

if v-doc-rec <> ? then reposition br-wthp to recid v-doc-rec no-error.
if not p-open-query and v-fltopend-rowid[1] <> ? then
query br-wthp:handle:reposition-to-rowid(v-fltopend-rowid) No-ERROR.

apply "entry" to br-wthp in frame {&frame-name}.
run waitfram-hide in this-procedure .

if avail X_wth-par then
APPLY "VALUE-CHANGED":U to br-wthp.
apply "value-changed" to br-wthp in frame {&frame-name}.
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
X_wealth.wth-code     column-label "Код"
X_wealth.wth-name     column-label "Название"
X_wealth.is-money     column-label "Денежн.!эквив."
X_wealth.curr-code    column-label "Код!валюты"
X_wealth.unit-base    column-label "Валюта/!Ед.изм."
X_wth-par.par-code     column-label "Код!номинала"
X_wth-par.par-val     column-label "Номинал"
X_wth-par.par-unit     column-label "Ед.изм.!номинала"
X_wth-par.par-rate     column-label "Коэфф."
X_wth-par.par-feat     column-label "Доп. признак"
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
GET next br-wthp.
DO WHILE available X_wth-par :
  Display STREAM PrnLibStream
  X_wealth.wth-code
  X_wealth.wth-name
  X_wealth.is-money
  X_wealth.curr-code
  X_wealth.unit-base
  X_wth-par.par-code
  X_wth-par.par-val
  X_wth-par.par-unit
  X_wth-par.par-rate
  X_wth-par.par-feat
  with FRAME Wth-List .
  DOWN STREAM PrnLibStream 1 with FRAME Wth-List  .
  GET next br-wthp.
END.
UNDERLINE  STREAM PrnLibStream
X_wealth.wth-code
X_wealth.wth-name
X_wealth.is-money
X_wealth.curr-code
X_wealth.unit-base
X_wth-par.par-code
X_wth-par.par-val
X_wth-par.par-unit
X_wth-par.par-rate
X_wth-par.par-feat
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