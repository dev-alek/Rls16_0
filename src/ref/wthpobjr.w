&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER X_wealth FOR ub.wealth.
DEFINE BUFFER X_wth-place FOR ub.wth-place.
DEFINE BUFFER X_wth-pobj FOR ub.wth-pobj.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Остатки МЦ на месте хранени

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/

/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-list-mode as character no-undo .
define input parameter pwth-code like ub.wth-pobj.wth-code no-undo.
define input parameter pw-p-code like ub.wth-pobj.w-p-code no-undo.
define input parameter p-obj-type like ub.wth-pobj.obj-type no-undo.
define input parameter p-obj-code like ub.wth-pobj.obj-code no-undo.
define input-output parameter p-rid-list as character no-undo .

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Остатки МЦ на месте хранения".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i  }
{ cmp/library.i }
{ cmp/showinf.i }
{ gbl/cur-time.i }
{ gbl/flt-def.i  }
{ cmp/r-pril.i new }
{ gbl/prn-lib.i }
{ str/wth-lib.i  }
{ gbl/fltfield.i }
{ gbl/waitfram.i }
{ gbl/fltopend.i defproc }

define variable filter-point as character no-undo init "wthpobjr" .
define variable filter-point0 as character no-undo init "wthpobjr" .
define variable filter-label as character no-undo init "МЦ_на_месте_хранения" .
define variable filter-label0 as character no-undo init "МЦ_на_месте_хранения" .

define variable sort-column-name as character no-undo .
define variable ri          as      recid   no-undo     init ? .
define variable v-doc-rec as recid no-undo .
DEFINE BUFFER b-clients   FOR ub.clients.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BR-wthpobj

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_wth-pobj X_wealth X_wth-place

/* Definitions for BROWSE BR-wthpobj                                    */
&Scoped-define FIELDS-IN-QUERY-BR-wthpobj X_wth-pobj.w-p-code X_wth-place.w-p-name /*X_wth-pobj.obj-type */ X_wth-pobj.obj-type + ' ' + string(X_wth-pobj.obj-code) get-cli-name(X_wth-pobj.obj-type,X_wth-pobj.obj-code) X_wth-pobj.wth-code X_wealth.wth-name X_wealth.is-money get-curr(buffer X_wealth) get-one-on-place(buffer X_wth-pobj)
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-wthpobj
&Scoped-define SELF-NAME BR-wthpobj
&Scoped-define QUERY-STRING-BR-wthpobj FOR EACH X_wth-pobj NO-LOCK, ~
             EACH X_wealth WHERE X_wealth.wth-code = X_wth-pobj.wth-code, ~
       EACH X_wth-place WHERE X_wth-place.w-p-code = X_wth-pobj.w-p-code NO-LOCK
&Scoped-define OPEN-QUERY-BR-wthpobj OPEN QUERY {&SELF-NAME} FOR EACH X_wth-pobj NO-LOCK, ~
             EACH X_wealth WHERE X_wealth.wth-code = X_wth-pobj.wth-code, ~
       EACH X_wth-place WHERE X_wth-place.w-p-code = X_wth-pobj.w-p-code NO-LOCK.
&Scoped-define TABLES-IN-QUERY-BR-wthpobj X_wth-pobj X_wealth X_wth-place
&Scoped-define FIRST-TABLE-IN-QUERY-BR-wthpobj X_wth-pobj
&Scoped-define SECOND-TABLE-IN-QUERY-BR-wthpobj X_wealth
&Scoped-define THIRD-TABLE-IN-QUERY-BR-wthpobj X_wth-place


/* Definitions for DIALOG-BOX Dialog-Frame                              */

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit B-print b-sch B-Help BR-wthpobj

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-cli-name Dialog-Frame
FUNCTION get-cli-name RETURNS CHARACTER
  ( f-cli-type AS CHAR, f-cli-code as int  )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-one-on-place Dialog-Frame
FUNCTION get-one-on-place RETURNS DECIMAL
  ( buffer loc-wth-pobj for Ub.wth-pobj)  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-print
     LABEL "Пе&чать"
     SIZE 3 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-sch
     LABEL "&Фильтр"
     SIZE 3 BY 1.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-wthpobj FOR
      X_wth-pobj,
      X_wealth,
      X_wth-place SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-wthpobj
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-wthpobj Dialog-Frame _FREEFORM
  QUERY BR-wthpobj NO-LOCK DISPLAY
      X_wth-pobj.w-p-code FORMAT ">>>>>>9":U
X_wth-place.w-p-name format "x(18)":U
/*X_wth-pobj.obj-type FORMAT "X(3)":U */
X_wth-pobj.obj-type + ' ' + string(X_wth-pobj.obj-code)  COLUMN-LABEL "Код!объекта" FORMAT "X(8)":U
get-cli-name(X_wth-pobj.obj-type,X_wth-pobj.obj-code)  COLUMN-LABEL "Объект" FORMAT "X(12)":U
X_wth-pobj.wth-code COLUMN-LABEL "Код МЦ" FORMAT " >>>>>>9":U
X_wealth.wth-name FORMAT "X(30)":U
X_wealth.is-money COLUMN-LABEL "Ден.!экв." FORMAT "+/":U
get-curr(buffer X_wealth) COLUMN-LABEL "Валюта/!Ед.изм."
get-one-on-place(buffer X_wth-pobj) COLUMN-LABEL "Остаток!на месте хран" FORMAT "->>>,>>>,>>9.99":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 20.96.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-print AT ROW 1 COL 89
     b-sch AT ROW 1 COL 92
     B-Help AT ROW 1 COL 95
     BR-wthpobj AT ROW 2.79 COL 1
     SPACE(0.24) SKIP(0.03)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Остатки МЦ на месте хранения"
         CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: X_wealth B "?" ? ub wealth
      TABLE: X_wth-place B "?" ? ub wth-place
      TABLE: X_wth-pobj B "?" ? ub wth-pobj
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BR-wthpobj B-Help Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-wthpobj
/* Query rebuild information for BROWSE BR-wthpobj
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH X_wth-pobj NO-LOCK,
      EACH X_wealth WHERE X_wealth.wth-code = X_wth-pobj.wth-code, EACH X_wth-place WHERE X_wth-place.w-p-code = X_wth-pobj.w-p-code NO-LOCK.
     _END_FREEFORM
     _Options          = "NO-LOCK"
     _JoinCode[2]      = "wealth.wth-code = wth-pobj.wth-code"
     _Query            is NOT OPENED
*/  /* BROWSE BR-wthpobj */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Остатки МЦ на месте хранения */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-print Dialog-Frame
ON CHOOSE OF B-print IN FRAME Dialog-Frame /* Печать */
DO:
  define variable doc-rec as recid no-undo .
    doc-rec = recid( X_wth-pobj ).
    DO WHILE available X_wth-pobj :
          GET prev br-wthpobj.
    END.
    run PrintProc.

     reposition br-wthpobj to recid doc-rec no-error.
    apply "entry" to br-wthpobj in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sch
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sch Dialog-Frame
ON CHOOSE OF b-sch IN FRAME Dialog-Frame /* Фильтр */
DO:
  run proc-b-sch in this-procedure no-error.
   if error-status:error then return no-apply.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-wthpobj
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.
{ gbl/app_help.i }
{ gbl/setfltnm.i }

&scop b-quit ~{&b-exit~}
{ gbl/hot-key.i b-quit }
{ gbl/hot-key.i b-print }
{ gbl/brwrepos.i
&browse-name = "br-wthpobj"
&line-num=5
}
{ gbl/brwrefre.i " v-doc-rec = ?. if available X_wth-pobj then assign v-doc-rec = recid( X_wth-pobj). run openbr in this-procedure ( input yes, input no, input '':U). ~
               reposition br-wthpobj to recid v-doc-rec no-error. APPLY 'ENTRY' to br-wthpobj. APPLY 'VALUe-CHANGED' to br-wthpobj. " }



/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  if p-rid-list <> "":u then do:
    assign
    v-doc-rec = integer(p-rid-list)
    no-error .
  end.
  RUN Myenable in this-procedure .
  RUn OpenBR in this-procedure ( input yes, input no, input '':U).
/*  { gbl/mv-clmn.i
  &ext-col = 8
  &frame-name = "{&frame-name}"
  &browse-name = "br-wthpobj"
  &start-column = "{&num-locked-columns-br-list} + 1"
  &prev-order-column_1 = "'4,5,6,7,8,1,2,3'"
  &prev-order-column-condition_1 = " p-list-mode = {&wth-place} "
  &prev-order-column_2 = "'1,2,3,8,4,5,6,7'"
  &prev-order-column-condition_2 = " p-list-mode = {&wealth} "
  &prev-order-column_3 = "'1,8,4,5,6,7,2,3,'"
  &prev-order-column-condition_3 = " p-list-mode = {&wealth} + {&comma-char} + {&g___object} "
   }*/
      { gbl/mv-clmn.i
  &ext-col = 9
  &frame-name = "{&frame-name}"
  &browse-name = "br-wthpobj"
  &start-column = "{&num-locked-columns-br-list} + 1"
  &prev-order-column_1 = "'1,2,5,6,7,9,8,3,4'"
  &prev-order-column-condition_1 = " p-list-mode = {&wth-place} "
  &prev-order-column_2 = "'1,2,3,4,9,5,6,7,8'"
  &prev-order-column-condition_2 = " p-list-mode = {&wealth} "
  &prev-order-column_3 = "'1,2,5,6,7,9,8,3,4'"
  &prev-order-column-condition_3 = " p-list-mode = {&wealth} + {&slash-char} + {&g___object} "
   }


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
  ENABLE b-quit B-print b-sch B-Help BR-wthpobj
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
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
ENABLE b-quit b-sch b-print B-Help BR-wthpobj
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OpenBr Dialog-Frame
PROCEDURE OpenBr :
define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .
define variable l-query-was-opened as logical no-undo .


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

&scop flt-open-open-query OPEN QUERY br-wthpobj FOR EACH X_wth-pobj

&scop flt-open-dyn_open-query FOR EACH X_wth-pobj

&scop flt-open-query-handle  QUERY br-wthpobj:handle

&scop flt-open-open-query-tail   , FIRST X_wealth No-LOCK WHERE X_wealth.wth-code = X_wth-pobj.wth-code ~
,first X_wth-place WHERE X_wth-place.w-p-code = X_wth-pobj.w-p-code and X_wth-place.obj-code = X_wth-pobj.obj-code and X_wth-place.obj-type = X_wth-pobj.obj-type


&scop flt-open-query-was-opened  l-query-was-opened

&scop flt-open-sort-column-phrase sort-column-phrase

&scop flt-open-call-point filter-point

&scop flt-open-set-filter-name set-filter-name

&scop flt-open-indexed-reposition

&scop flt-open-waitfram yes

CASE p-list-mode:
    when {&wth-place} then do:
        ASSIGN
        frame {&frame-name}:TITLE = "Остатки МЦ на месте хранения " + string(pw-p-code)
        filter-point = "Остатки МЦ на месте хранения" + p-list-mode
        filter-label = substitute("&1 Один объект", filter-label0)
        .
          { gbl/fltopend.i
            &where-cond = " X_wth-pobj.w-p-code = pw-p-code ~
                           AND X_wth-pobj.obj-type = p-obj-type ~
                           and X_wth-pobj.obj-code = p-obj-code"
            &dyn_where-cond = " substitute('X_wth-pobj.w-p-code = &1 ~
                           AND X_wth-pobj.obj-type = &2&3&2 ~
                           and X_wth-pobj.obj-code = &4 ', pw-p-code, ~{&double-quote~}, p-obj-type, p-obj-code)"

            &use-ind = "  "
            &by = "  "
          }
    end.
    when ({&wealth} + {&slash-char} + {&g___object}) then do:
        ASSIGN frame {&frame-name}:TITLE = "Остатки МЦ " + string(pwth-code) + " на местах хранения объекта " + p-obj-type + {&space-char} + string(p-obj-code)
        filter-point = "Остатки МЦ на месте хранения" + p-list-mode
        filter-label = substitute("&1 Один объект, одна МЦ", filter-label0)
        .
          { gbl/fltopend.i
            &where-cond = " X_wth-pobj.wth-code = pwth-code ~
                            AND X_wth-pobj.obj-type = p-obj-type ~
                            and X_wth-pobj.obj-code = p-obj-code"
            &dyn_where-cond = " substitute('X_wth-pobj.wth-code = &1 ~
                            AND X_wth-pobj.obj-type = &2&3&2 ~
                            and X_wth-pobj.obj-code = &4', pwth-code, ~{&double-quote~}, p-obj-type, p-obj-code)"

            &use-ind = "  "
            &by = "  "
          }
    end.
    when {&wealth} then do:
        ASSIGN
        frame {&frame-name}:TITLE = "Остатки МЦ " + string(pwth-code) + " на местах хранения"
        filter-point = "Остатки МЦ на месте хранения" + p-list-mode
        filter-label = substitute("&1 Одна МЦ", filter-label0)
        .
          { gbl/fltopend.i
            &where-cond = " X_wth-pobj.wth-code = pwth-code "
            &dyn_where-cond = " substitute('X_wth-pobj.wth-code = &1', pwth-code )"
            &use-ind = "  "
            &by = "  "
          }
    end.



END CASE.

if v-doc-rec <> ? then reposition br-wthpobj to recid v-doc-rec no-error.
if not p-open-query and v-fltopend-rowid[1] <> ? then
query br-wthpobj:handle:reposition-to-rowid(v-fltopend-rowid) No-ERROR.
apply "entry" to br-wthpobj in frame {&frame-name}.
run waitfram-hide in this-procedure .
if avail X_wth-pobj then
apply "value-changed" to br-wthpobj in frame {&frame-name}.

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

DEFINE FRAME Wth-List
X_wth-pobj.w-p-code     column-label "Код места!хранения"
X_wth-pobj.obj-type     column-label "Объект"
X_wth-pobj.obj-code     column-label "Код!объекта"
X_wth-pobj.wth-code     column-label "Код МЦ"
X_wealth.wth-name     column-label "Название"
X_wealth.is-money     column-label "Денежн.!эквив." format "+/"
X_wealth.curr-code    column-label "Код!валюты"
X_wealth.unit-base    column-label "Валюта/!Ед.изм."
var-on-obj          column-label "Остаток на!месте хранения" format "->>>,>>>,>>9.99"
HEADER  date_string AT 5 format "X(35)"
string( "Страница " ) format "X(9)" AT 100 PAGE-NUMBER(PrnLibStream) AT 110 FORMAT ">>9" SKIP
Line format "X(138)" AT 1
with width {&A4_CW} down stream-io use-text    .
Line = fill("-", 116).
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
    run waitfram-show in this-procedure ("Ждите...").
    GET next br-wthpobj.
     DO WHILE available X_wth-pobj :
        var-on-obj = get-one-on-place(buffer X_wth-pobj).
        Display STREAM PrnLibStream
        X_wth-pobj.w-p-code
        X_wth-pobj.obj-type
        X_wth-pobj.obj-code
        X_wth-pobj.wth-code
        X_wealth.wth-name
        X_wealth.is-money
        X_wealth.curr-code
        X_wealth.unit-base
        var-on-obj
        with FRAME Wth-List .
        DOWN STREAM PrnLibStream 1 with FRAME Wth-List  .
        GET next br-wthpobj.
      END.
      PUT STREAM PrnLibStream line format "X(138)" at 1.
/*      UNDERLINE*/
/*      STREAM PrnLibStream*/
/*        X_wth-pobj.w-p-code*/
/*        X_wth-pobj.obj-type*/
/*        X_wth-pobj.obj-code*/
/*        X_wth-pobj.wth-code*/
/*        X_wealth.wth-name*/
/*        X_wealth.is-money*/
/*        X_wealth.curr-code*/
/*        X_wealth.unit-base*/
/*        var-on-obj*/
/*        with FRAME Wth-List .*/

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
tbl = 'wth-pobj'
join-tbl = 'X_wth-pobj'
fld = ""
lab = ""
spr = ""
dim = '0'
.
run fltfield-add in this-procedure('wth-code', 'Код МЦ', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('w-p-code', 'Код места хранения', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('obj-type', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('obj-code', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('income-pl', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('income-cassa-pl', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('income-other-pl', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('incass-pl', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('incass-bank-pl', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('incass-cassa-pl', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('incass-other-pl', '', '',
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-cli-name Dialog-Frame
FUNCTION get-cli-name RETURNS CHARACTER
  ( f-cli-type AS CHAR, f-cli-code as int  ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/

For FIRST b-clients WHERE b-clients.obj-type = f-cli-type AND
                       b-clients.obj-code = f-cli-code NO-LOCK:
  return   b-clients.obj-name.
end.
RETURN "".   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-one-on-place Dialog-Frame
FUNCTION get-one-on-place RETURNS DECIMAL
  ( buffer loc-wth-pobj for Ub.wth-pobj) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/
define variable parstock as decimal no-undo.
RUN wth-lib_cur-stock-place(
                            input  loc-wth-pobj.obj-type,
                            input loc-wth-pobj.obj-code,
                            input loc-wth-pobj.w-p-code,
                            input loc-wth-pobj.wth-code,
                            output parstock) no-error.
if error-status:error then parstock = ?.
RETURN parstock.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
