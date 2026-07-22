&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER X_wth-place FOR ub.wth-place.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Справочник мест хранения материальных ценностей

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
define input parameter bttns as character no-undo .
define input parameter parhost-code like ub.sysconf.host-code no-undo .
define input parameter parobj-type like ub.clients.obj-type no-undo .
define input parameter parobj-code like ub.clients.obj-code no-undo .
define input parameter p-list-mode as character no-undo .
define input-output parameter p-rid-list as char no-undo .

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Справочник мест хранения материальных ценностей ".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/showinf.i }
{ gbl/cur-time.i }
{ gbl/flt-def.i  }
{ cmp/r-pril.i new }
{ gbl/prn-lib.i }
{ str/wth-lib.i  }
{ gbl/fltfield.i }
{ gbl/waitfram.i }
{ gbl/getcntxt.i def }
{ cmp/mrk-strf.i }
{ gbl/fltopend.i defproc }

define variable filter-label0 as character no-undo init "Места_хранения_МЦ" .
define variable filter-label as character no-undo init "Места_хранения_МЦ" .
define variable filter-point0 as character no-undo init "wthplref" .
define variable filter-point as character no-undo init "wthplref" .

define variable sort-column-name as character no-undo .
define variable ri          as      recid   no-undo     init ? .
define variable choice as log no-undo.
define variable mark as char no-undo.
define variable v-doc-rec as recid no-undo .
define variable v-rid-list as character no-undo .
define variable ser-wth  as logical   no-undo. /* для чтения параметра конфигурации */
define variable conf-par as character no-undo.
define variable par-type as character no-undo.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BR-wthpl

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_wth-place

/* Definitions for BROWSE BR-wthpl                                      */
&Scoped-define FIELDS-IN-QUERY-BR-wthpl mark-string(recid(X_wth-place), v-rid-list) X_wth-place.w-p-code X_wth-place.w-p-name X_wth-place.status_ X_wth-place.obj-type X_wth-place.obj-code X_wth-place.host-code X_wth-place.main-cash-desk X_wth-place.cash-desk get-all-on-place(buffer X_wth-place)
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-wthpl
&Scoped-define SELF-NAME BR-wthpl
&Scoped-define QUERY-STRING-BR-wthpl FOR EACH X_wth-place NO-LOCK
&Scoped-define OPEN-QUERY-BR-wthpl OPEN QUERY {&SELF-NAME} FOR EACH X_wth-place NO-LOCK.
&Scoped-define TABLES-IN-QUERY-BR-wthpl X_wth-place
&Scoped-define FIRST-TABLE-IN-QUERY-BR-wthpl X_wth-place


/* Definitions for DIALOG-BOX Dialog-Frame                              */

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit B-mark B-sel B-add B-chg B-del ~
B-wthpobj B-wthparts B-print B-hist B-sch B-Help BR-wthpl E-PS mark-num
&Scoped-Define DISPLAYED-OBJECTS E-PS mark-num

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-all-on-place Dialog-Frame
FUNCTION get-all-on-place RETURNS DECIMAL
  ( buffer loc-wth-place for ub.wth-place)  FORWARD.

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
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-hist
     LABEL "Ис&тория"
     SIZE 3 BY 1.

DEFINE BUTTON B-mark
     LABEL "&*"
     SIZE 3 BY 1.

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

DEFINE BUTTON B-wthparts
     LABEL "&Партии"
     SIZE 10 BY 1 TOOLTIP "Партии серийных МЦ".

DEFINE BUTTON B-wthpobj
     LABEL "&Остатки"
     SIZE 10 BY 1.

DEFINE VARIABLE E-PS AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 97.13 BY 2.88 NO-UNDO.

DEFINE VARIABLE mark-num AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 4.25 BY 1
     FGCOLOR 4  NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-wthpl FOR
      X_wth-place SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-wthpl
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-wthpl Dialog-Frame _FREEFORM
  QUERY BR-wthpl DISPLAY
      mark-string(recid(X_wth-place), v-rid-list) COLUMN-LABEL "*" FORMAT "X(1)":U
X_wth-place.w-p-code FORMAT ">>>>>>>>9":U
X_wth-place.w-p-name COLUMN-LABEL "Название" FORMAT "X(21)":U
X_wth-place.status_ COLUMN-LABEL "Статус" FORMAT "X(10)":U
X_wth-place.obj-type FORMAT "X(3)":U
X_wth-place.obj-code FORMAT "999999999":U
X_wth-place.host-code COLUMN-LABEL "Фирма" FORMAT "999999999":U
X_wth-place.main-cash-desk COLUMN-LABEL "Гл.!касса" FORMAT "+/":U
X_wth-place.cash-desk COLUMN-LABEL "Номер!кассы" FORMAT ">>>9":U
get-all-on-place(buffer X_wth-place) COLUMN-LABEL "Всего на месте!МЦ, имеющих!ден.эквив.!на сумму" FORMAT "->>>,>>>,>>9.99":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 97.38 BY 16.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-mark AT ROW 1 COL 16
     B-sel AT ROW 1 COL 19
     B-add AT ROW 1 COL 29
     B-chg AT ROW 1 COL 39
     B-del AT ROW 1 COL 49
     B-wthpobj AT ROW 1 COL 59
     B-wthparts AT ROW 1 COL 69 WIDGET-ID 2
     B-print AT ROW 1 COL 86
     B-hist AT ROW 1 COL 89
     B-sch AT ROW 1 COL 92
     B-Help AT ROW 1 COL 95
     BR-wthpl AT ROW 2.5 COL 1.13
     E-PS AT ROW 18.92 COL 1.38 NO-LABEL
     mark-num AT ROW 1 COL 11 NO-LABEL
     SPACE(83.26) SKIP(20.07)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Места хранения материальных ценностей"
         CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: X_wth-place B "?" ? ub wth-place
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BR-wthpl B-Help Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN
       E-PS:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN mark-num IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-wthpl
/* Query rebuild information for BROWSE BR-wthpl
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH X_wth-place NO-LOCK.
     _END_FREEFORM
     _Query            is NOT OPENED
*/  /* BROWSE BR-wthpl */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Места хранения материальных ценностей */
DO:
  p-rid-list = v-rid-list.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Места хранения материальных ценностей */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-add Dialog-Frame
ON CHOOSE OF B-add IN FRAME Dialog-Frame /* Добавить */
DO:
define variable rep-rec as recid no-undo .
define variable glog as logical no-undo .
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_wth-place-reference_work':U
    {&cntxt-object}
    parhost-code
    parobj-type
    parobj-code
    0
    0
    0
    true
    glog
  }

if NOT glog then return no-apply.
rep-rec = ?.
run ref/wthplfrm.w (
                   input parparentproc
                 , input {&add-def}
                 , input parhost-code
                 , input parobj-type
                 , input parobj-code
                 , input-output rep-rec).
if rep-rec <> ? then do:
   v-doc-rec = rep-rec.
   RUn OpenBr in this-procedure ( input yes, input no, input '':U).
  apply "entry" to br-wthpl in frame {&frame-name}.
end.
else do:
  apply "entry" to br-wthpl in frame {&frame-name}.
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
    if not available X_wth-place then do:
  message "Неправильно выбрана строка.".
  return no-apply.
end.
rep-rec = recid ( X_wth-place).
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_wth-place-reference_work':U
    {&cntxt-object}
    parhost-code
    parobj-type
    parobj-code
    0
    0
    0
    true
    glog
  }
if NOT glog then return no-apply.
run ref/wthplfrm.w (
                 input parparentproc
                ,input  {&update}
                ,input parhost-code
                ,input parobj-type
                ,input parobj-code
                ,input-output rep-rec).
if rep-rec <> ? then do:
   v-doc-rec = rep-rec .
   RUn OpenBr in this-procedure ( input yes, input no, input '':U).
   apply "entry" to br-wthpl in frame {&frame-name}.
end.
else do:
  apply "entry" to br-wthpl in frame {&frame-name}.
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
 define variable rep-rec as recid no-undo .
 define variable glog as logical no-undo .

if not available X_wth-place then do:
  message "Неправильно выбрана строка.".
  return no-apply.
end.
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_wth-place-reference_work':U
    {&cntxt-object}
    parhost-code
    parobj-type
    parobj-code
    0
    0
    0
    true
    glog
  }
if NOT glog then return no-apply.
rep-rec = recid ( X_wth-place).
glog = no.
message
"Удалить место хранения материальной ценности ?   Вы уверены ?"
view-as alert-box question buttons OK-Cancel update glog.
if glog <> yes then return no-apply.
glog = br-wthpl:select-next-row().
if not glog then glog = br-wthpl:select-prev-row().
del-rec = recid ( X_wth-place).
find X_wth-place where recid ( X_wth-place) = rep-rec.
_deletion:
do on stop undo _deletion, return no-apply:
  /*поскольку в настоящий момент удаление МХ МЦ невозможно - то  нет и программы которая это обрабатывает
  если будет удаление =- программу приедтся написать

  r u n   w t h p l d v . p ( input X_wth-place.w-p-code,
                             output glog) no-error.

  if error-status:error then return no-apply.
  if not glog then do:
    if return-value <> "" then
    message return-value view-as alert-box ERROR.
    return no-apply.
  end.
  if glog = yes then
  delete X_wth-place.
  */
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
  DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
  IF AVAILABLE X_wth-place THEN DO:

  run ref/wthc-pls.w (
                    INPUT parParentProc
                   ,input '':U /*bttns*/
                   ,input 'one':U /*p-mode*/
                   ,input X_wth-place.obj-type
                   ,input X_wth-place.obj-code
                   ,INPUT X_wth-place.w-p-code
                   ,INPUT-OUTPUT v-rid-list) NO-ERROR.

  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mark Dialog-Frame
ON CHOOSE OF B-mark IN FRAME Dialog-Frame /* * */
DO:
define variable glog as logical no-undo .
  if available X_wth-place then do:
    { gbl/markstrn.i X_wth-place v-rid-list }
    br-wthpl:refresh().
    if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
            glog = br-wthpl:select-next-row ().
            apply "iteration-changed" to br-wthpl in frame {&frame-name}.
        end.
    if num-entries( v-rid-list ) = 0 then
        hide mark-num in frame {&frame-name}.
    else
        disp num-entries( v-rid-list ) @ mark-num with frame {&frame-name}.
  end.
  apply "entry" to br-wthpl in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-print Dialog-Frame
ON CHOOSE OF B-print IN FRAME Dialog-Frame /* Печать */
DO:
define variable doc-rec as recid no-undo .
    doc-rec = recid( X_wth-place ).
    DO WHILE available X_wth-place :
          GET prev br-wthpl.
    END.
    run PrintProc.

    reposition br-wthpl to recid doc-rec no-error.
    apply "entry" to br-wthpl in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-sch
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-sch Dialog-Frame
ON CHOOSE OF B-sch IN FRAME Dialog-Frame /* Фильтр */
DO:
  run proc-b-sch no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-sel Dialog-Frame
ON CHOOSE OF B-sel IN FRAME Dialog-Frame /* Выбор */
DO:
      if ( available X_wth-place
      AND (v-rid-list = ""
         or b-mark:sensitive = no
      )) then
        v-rid-list = string( recid( X_wth-place ) ) .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-wthparts
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-wthparts Dialog-Frame
ON CHOOSE OF B-wthparts IN FRAME Dialog-Frame /* Партии */
DO:
if not available X_wth-place then do:
  message "Неправильно выбрана строка.".
  return no-apply.
end.

run str/wthparts.w (
                 input parparentproc
                ,input parhost-code
                ,input parobj-type
                ,input parobj-code
                ,input {&wth-place}
                ,input {&LOOKUP}
                ,input 0
                ,input 0
                ,INPUT 0
                ,INPUT 0
                ,INPUT '':U
                ,input X_wth-place.w-p-code
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


&Scoped-define SELF-NAME B-wthpobj
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-wthpobj Dialog-Frame
ON CHOOSE OF B-wthpobj IN FRAME Dialog-Frame /* Остатки */
DO:
define variable v-rid-list as character no-undo .
  if avail X_wth-place then do:
    run ref/wthpobjr.w (
                    input parparentproc
                   ,input {&wth-place}
                   ,input ?
                   ,input X_wth-place.w-p-code
                   ,input X_wth-place.obj-type
                   ,input X_wth-place.obj-code
                   ,input-output v-rid-list
                   ) .


  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-wthpl
&Scoped-define SELF-NAME BR-wthpl
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-wthpl Dialog-Frame
ON MOUSE-SELECT-DBLCLICK OF BR-wthpl IN FRAME Dialog-Frame
DO:
  if lookup("b-sel", bttns) > 0 then APPLY "CHOOSE" to b-sel.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-wthpl Dialog-Frame
ON RETURN OF BR-wthpl IN FRAME Dialog-Frame
DO:
  if lookup("b-sel", bttns) > 0 then APPLY "CHOOSE" to b-sel.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-wthpl Dialog-Frame
ON VALUE-CHANGED OF BR-wthpl IN FRAME Dialog-Frame
DO:
    if avail X_wth-place then
  E-PS:screen-value = X_wth-place.PS  .
  else
  E-PS:screen-value = "".

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
&browse-name = "br-wthpl"
&line-num=5
}
{ gbl/brwrefre.i " v-doc-rec = ?. if available X_wth-place then assign v-doc-rec = recid( X_wth-place). run openbr in this-procedure ( input yes, input no, input '':U). ~
               reposition br-wthpl to recid v-doc-rec no-error. APPLY 'ENTRY' to br-wthpl. APPLY 'VALUe-CHANGED' to br-wthpl. " }



/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

  { gbl/getcntxt.i get }
  v-rid-list = p-rid-list.
  RUN Myenable.
  if v-rid-list <> "":U then do:
    assign
    v-doc-rec = integer(entry(1,v-rid-list))
    no-error .
  end.
  RUN OpenBR in this-procedure ( input yes, input no, input '':U).
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
  DISPLAY E-PS mark-num
      WITH FRAME Dialog-Frame.
  ENABLE b-quit B-mark B-sel B-add B-chg B-del B-wthpobj B-wthparts B-print
         B-hist B-sch B-Help BR-wthpl E-PS mark-num
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
{ gbl/conf-rd.i
  "'ser-wth'"
  0
  "''"
  0
  "''"
  "''"
  "''"
  NO
  conf-par
  par-type
  no-error
  }
  IF not error-status:error then
  assign
  ser-wth = (conf-par = "yes":U).

ENABLE b-quit b-help br-wthpl E-PS
b-sel when lookup ("b-sel", bttns) > 0
b-mark when lookup ("b-mark", bttns) > 0
b-add when lookup ("b-add", bttns) > 0   and v-cntxt-db-num = v-cntxt-db-num-obj
b-chg when lookup ("b-add", bttns) > 0  and v-cntxt-db-num = v-cntxt-db-num-obj
b-print
b-wthpobj
b-hist
b-wthparts when ser-wth
/*   b-del when can-do ("b-add", bttns)*/
b-sch
WITH FRAME {&frame-name}.
VIEW FRAME {&frame-name}.
HIDE
b-del
in frame {&frame-name}.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OpenBr Dialog-Frame
PROCEDURE OpenBr :
define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .

define variable l-query-was-opened as logical no-undo .
define buffer buf_clients for ub.clients.

run waitfram-show in this-procedure ("Ждите...").

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

&scop flt-open-open-query OPEN QUERY br-wthpl FOR EACH X_wth-place

&scop flt-open-dyn_open-query FOR EACH X_wth-place

&scop flt-open-query-handle  QUERY br-wthpl:handle

&scop flt-open-open-query-tail

&scop flt-open-query-was-opened  l-query-was-opened

&scop flt-open-sort-column-phrase sort-column-phrase

&scop flt-open-call-point filter-point

&scop flt-open-set-filter-name set-filter-name

&scop flt-open-indexed-reposition

&scop flt-open-waitfram yes

CASE p-list-mode:
    when {&all} then do:
        ASSIGN frame {&frame-name}:TITLE = "Места хранения МЦ "
        filter-point = "Места хранения МЦ " + p-list-mode
        filter-label = substitute("&1", filter-label0)
        .
          { gbl/fltopend.i
            &where-cond = " TRUE "
            &use-ind = "  "
            &by = "  "
          }
    end.
    when {&g___object} then do:
        find first ub.clients No-LOCK WHERE
                   ub.clients.obj-type = parobj-type AND
                   ub.clients.obj-code = parobj-code No-ERROR.
        ASSIGN frame {&frame-name}:TITLE = "Места хранения МЦ " +
                                           (if avail clients
                                            then ub.clients.obj-name
                                            else (parobj-type + string(parobj-code)))
        filter-point = "Места хранения МЦ " + p-list-mode
        filter-label = substitute("&1 Один объект", filter-label0)
        .
          { gbl/fltopend.i
            &where-cond = " X_wth-place.obj-type = parobj-type AND X_wth-place.obj-code = parobj-code "
            &dyn_where-cond = " substitute('X_wth-place.obj-type = &1&2&1 AND X_wth-place.obj-code = &3 ', ~{&double-quote~}, parobj-type, parobj-code)"
            &use-ind = "  "
            &by = "  "
          }
    end.
    when {&company} then do:
       find first buf_clients no-lock where
                  buf_Clients.obj-type = {&cmp}
              AND buf_Clients.obj-code = parhost-code no-error .

        ASSIGN frame {&frame-name}:TITLE = "Места хранения МЦ " + (if available buf_clients
                                                                   then buf_clients.obj-name
                                                                   else (buf_clients.obj-type + string(buf_clients.obj-code))
                                                                  )
        filter-point = "Места хранения МЦ " + p-list-mode
        filter-label = substitute("&1 Одна фирма", filter-label0)
        .
          { gbl/fltopend.i
            &where-cond = " X_wth-place.host-code = parhost-code "
            &dyn_where-cond = " substitute('X_wth-place.host-code = &1', parhost-code )"
            &use-ind = "  "
            &by = "  "
          }
    end.


END CASE.

if v-doc-rec <> ? then reposition br-wthpl to recid v-doc-rec no-error.
if not p-open-query and v-fltopend-rowid[1] <> ? then
query br-wthpl:handle:reposition-to-rowid(v-fltopend-rowid) No-ERROR.
if error-status:error then do:
  reposition br-wthpl to row 1 no-error.
end.
apply "entry" to br-wthpl in frame {&frame-name}.
run waitfram-hide in this-procedure .
if avail X_wth-place then
APPLY "VALUE-CHANGED":U to br-wthpl.
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
define variable var-on-obj as decimal no-undo.

DEFINE FRAME Wthpl-List
X_wth-place.w-p-code     column-label "Код места"
X_wth-place.w-p-name     column-label "Название"
X_wth-place.status_      column-label "Статус"
X_wth-place.obj-type     column-label "Объект"
X_wth-place.obj-code     column-label "Код!объекта"
X_wth-place.host-code    column-label "Код!фирмы"
var-on-obj             column-label "Всего на месте!MЦ, имеющих!ден.эквив.!на сумму" format "->>>,>>>,>>9.99"
HEADER  date_string AT 5 format "X(35)"
string( "Страница " ) format "X(9)" AT 100 PAGE-NUMBER(PrnLibStream) AT 110 FORMAT ">>9" SKIP
Line format "X(138)" AT 1
with width {&A4_CW} down stream-io use-text    .
Line = fill("-", 90).
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

    FORM with FRAME Wthpl-List  .
    run waitfram-show in this-procedure ("Ждите...").
    GET next br-wthpl.
     DO WHILE available X_wth-place :
        var-on-obj = get-all-on-place(buffer X_wth-place).
        Display STREAM PrnLibStream
        X_wth-place.w-p-code
        X_wth-place.w-p-name
        X_wth-place.status_
        X_wth-place.obj-type
        X_wth-place.obj-code
        X_wth-place.host-code
        var-on-obj
        with FRAME Wthpl-List .
        DOWN STREAM PrnLibStream 1 with FRAME Wthpl-List  .
        GET next br-wthpl.
      END.
      UNDERLINE  STREAM PrnLibStream
        X_wth-place.w-p-code
        X_wth-place.w-p-name
        X_wth-place.status_
        X_wth-place.obj-type
        X_wth-place.obj-code
        X_wth-place.host-code
        var-on-obj
        with FRAME Wthpl-List .
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-sch Dialog-Frame
PROCEDURE proc-b-sch :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
assign
tbl = 'wth-place'
join-tbl = 'X_wth-place'
fld = ""
lab = ""
spr = ""
dim = '0'
.
run fltfield-add in this-procedure('w-p-code', 'Код места хранения', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('w-p-name', 'Название', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('host-code', 'Код фирмы', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('obj-code', 'Код объект', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('obj-type', 'Тип объекта', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('status_', 'Статус', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('cash-desk', 'Номер кассы', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('main-cash-desk', 'Главная касса', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('PS', 'Примечание', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.

    DO on stop undo, leave:
        run gbl/filter.w ( input parparentproc
                         , input (filter-point + {&delim-par} + filter-label)
                         , input tbl
                         , input join-tbl
                         , input fld
                         , input lab
                         , input spr
                         , input dim).
        RUN OpenBr in this-procedure ( input yes, input no, input '':U).
    END .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-all-on-place Dialog-Frame
FUNCTION get-all-on-place RETURNS DECIMAL
  ( buffer loc-wth-place for ub.wth-place) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/

def buffer loc-wealth for ub.wealth.
define variable parstock as decimal no-undo.
define variable varstock as decimal no-undo.
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .

  FOR EACH ub.wth-pobj No-LOCK WHERE
           ub.wth-pobj.obj-type = loc-wth-place.obj-type AND
           ub.wth-pobj.obj-code = loc-wth-place.obj-code AND
           ub.wth-pobj.w-p-code = loc-wth-place.w-p-code:
    FIND FIRST loc-wealth No-LOCK WHERE
               loc-wealth.wth-code = ub.wth-pobj.wth-code No-ERROR.
    if not avail loc-wealth then do:
        parstock = ?.
    end.
    else do:
        if loc-wealth.is-money then do:
            RUN wth-lib_cur-stock-place(
                                        input  loc-wth-place.obj-type,
                                        input  loc-wth-place.obj-code,
                                        input  loc-wth-place.w-p-code,
                                        input  ub.wth-pobj.wth-code,
                                        output parstock) no-error.
            if error-status:error then do:
                parstock = ?.
            end.
            if loc-wealth.curr-code <> 0 then do:
                { gbl/curobjdt.i loc-wth-place.obj-type loc-wth-place.obj-code v-today }
                FIND FIRST ub.curr-bank NO-LOCK WHERE
                          curr-bank.curr-code = loc-wealth.curr-code and
                          curr-bank.exch-date <= v-today use-index i1 no-error .
                if avail curr-bank then
                parstock = parstock * curr-bank.exch-rate / exch-scale.

                else do:
                    parstock = ?.
                end.

            end.
        end.
        else parstock = 0.
    end.
    varstock = varstock + parstock.
  END.

  RETURN varstock.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
