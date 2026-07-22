&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame

/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER del_cshr-month FOR ub.cshr-month.
DEFINE BUFFER sum_cshr-month FOR ub.cshr-month.


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Архивы по кассирам

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/13/05
Author: Bakhtadze Natalya
Creation date: 09/13/05

Author: Черных В.Г.
Created: 29/01/99

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-cashier-code like ub.cshr-month.cshr-code no-undo.
define input parameter p-psn-code like ub.cshr-month.cshr-code no-undo.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Архивы по кассирам".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/showinf.i }
{ gbl/cur-time.i }
{ cmp/r-pril.i new }
{ gbl/prn-lib.i }
{ gbl/waitfram.i }


/* Local Variable Definitions ---                                       */

define variable print-option as character no-undo.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BR-cshr-del

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES del_cshr-month sum_cshr-month

/* Definitions for BROWSE BR-cshr-del                                   */
&Scoped-define FIELDS-IN-QUERY-BR-cshr-del del_cshr-month.cashier-psn-code del_cshr-month.obj-code del_cshr-month.month_ del_cshr-month.year_ del_cshr-month.out-count del_cshr-month.out-qnty del_cshr-month.out-sum del_cshr-month.ret-count del_cshr-month.ret-qnty del_cshr-month.ret-sum
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-cshr-del
&Scoped-define SELF-NAME BR-cshr-del
&Scoped-define QUERY-STRING-BR-cshr-del FOR EACH del_cshr-month       WHERE del_cshr-month.cshr-code = p-cashier-code AND ( del_cshr-month.cashier-psn-code = p-psn-code or del_cshr-month.cashier-psn-code = 0)  AND ( del_cshr-month.out-count <> 0  OR del_cshr-month.ret-count <> 0 )  SHARE-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-BR-cshr-del OPEN QUERY {&SELF-NAME} FOR EACH del_cshr-month       WHERE del_cshr-month.cshr-code = p-cashier-code AND ( del_cshr-month.cashier-psn-code = p-psn-code or del_cshr-month.cashier-psn-code = 0)  AND ( del_cshr-month.out-count <> 0  OR del_cshr-month.ret-count <> 0 )  SHARE-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-BR-cshr-del del_cshr-month
&Scoped-define FIRST-TABLE-IN-QUERY-BR-cshr-del del_cshr-month


/* Definitions for BROWSE BR-cshr-sum                                   */
&Scoped-define FIELDS-IN-QUERY-BR-cshr-sum sum_cshr-month.cashier-psn-code sum_cshr-month.obj-code sum_cshr-month.month_ sum_cshr-month.year_ sum_cshr-month.out-totchk + sum_cshr-month.ret-totchk sum_cshr-month.out-totchk sum_cshr-month.out-totsum + sum_cshr-month.ret-totsum sum_cshr-month.out-totsum sum_cshr-month.ret-totchk sum_cshr-month.ret-totsum
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-cshr-sum
&Scoped-define SELF-NAME BR-cshr-sum
&Scoped-define QUERY-STRING-BR-cshr-sum FOR EACH sum_cshr-month       WHERE sum_cshr-month.cshr-code = p-cashier-code and ( sum_cshr-month.cashier-psn-code = p-psn-code or sum_cshr-month.cashier-psn-code = 0) SHARE-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-BR-cshr-sum OPEN QUERY {&SELF-NAME} FOR EACH sum_cshr-month       WHERE sum_cshr-month.cshr-code = p-cashier-code and ( sum_cshr-month.cashier-psn-code = p-psn-code or sum_cshr-month.cashier-psn-code = 0) SHARE-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-BR-cshr-sum sum_cshr-month
&Scoped-define FIRST-TABLE-IN-QUERY-BR-cshr-sum sum_cshr-month


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BR-cshr-del}~
    ~{&OPEN-QUERY-BR-cshr-sum}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS Btn_Cancel b-print b-help BR-cshr-del ~
BR-cshr-sum

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Menu Definitions                                                     */
DEFINE MENU MENU-b-print
       MENU-ITEM m_cshr-del     LABEL "Отмененные/аннулированные строки чеков"
       MENU-ITEM m_cshr-sum     LABEL "Итоги продаж/возвратов".


/* Definitions of the field level widgets                               */
DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-print
     LABEL "Пе&чать"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON Btn_Cancel AUTO-END-KEY
     LABEL "Выход "
     SIZE 10 BY 1
     BGCOLOR 8 .

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-cshr-del FOR
      del_cshr-month SCROLLING.

DEFINE QUERY BR-cshr-sum FOR
      sum_cshr-month SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-cshr-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-cshr-del Dialog-Frame _FREEFORM
  QUERY BR-cshr-del SHARE-LOCK NO-WAIT DISPLAY
      del_cshr-month.cashier-psn-code COLUMN-LABEL "Код!физ.лица" FORMAT ">>>>>>>>9":U
      del_cshr-month.obj-code COLUMN-LABEL "Маг-н" FORMAT "99999":U
      del_cshr-month.month_ COLUMN-LABEL "Ме!сяц" FORMAT "99":U
      del_cshr-month.year_ FORMAT "9999":U
      del_cshr-month.out-count COLUMN-LABEL "Продажа!(строк)" FORMAT "->>>>>>>":U
      del_cshr-month.out-qnty FORMAT "->>,>>>,>>>.<<<":U
      del_cshr-month.out-sum FORMAT "->>,>>>,>>>,>>>.<<":U
      del_cshr-month.ret-count COLUMN-LABEL "Возврат!(строк)" FORMAT "->>>>>>>":U
      del_cshr-month.ret-qnty FORMAT "->>,>>>,>>>.<<<":U
      del_cshr-month.ret-sum FORMAT "->>,>>>,>>>,>>>.<<":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 8.33
         BGCOLOR 15 FGCOLOR 0
         TITLE BGCOLOR 15 FGCOLOR 0 "Отмененные/аннулированные строки чеков".

DEFINE BROWSE BR-cshr-sum
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-cshr-sum Dialog-Frame _FREEFORM
  QUERY BR-cshr-sum SHARE-LOCK NO-WAIT DISPLAY
      sum_cshr-month.cashier-psn-code COLUMN-LABEL "Код!физ.лица" FORMAT ">>>>>>>>9":U
      sum_cshr-month.obj-code COLUMN-LABEL "Маг-н" FORMAT "99999":U
      sum_cshr-month.month_ COLUMN-LABEL "Ме!сяц" FORMAT "99":U
      sum_cshr-month.year_ FORMAT "9999":U
      sum_cshr-month.out-totchk + sum_cshr-month.ret-totchk COLUMN-LABEL "Всего!чеков" FORMAT ">>>>>>>":U
      sum_cshr-month.out-totchk COLUMN-LABEL "Чеков!продаж" FORMAT ">>>>>>>":U
      sum_cshr-month.out-totsum + sum_cshr-month.ret-totsum COLUMN-LABEL "Выручка" FORMAT "->>,>>>,>>>,>>9.99":U
      sum_cshr-month.out-totsum FORMAT "->>,>>>,>>>,>>9.99":U
      sum_cshr-month.ret-totchk COLUMN-LABEL "Чеков!возвратов" FORMAT ">>>>>>>":U
      sum_cshr-month.ret-totsum FORMAT "->>,>>>,>>>,>>>.<<":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 8.33
         BGCOLOR 15 FGCOLOR 0
         TITLE BGCOLOR 15 FGCOLOR 0 "Итоги продаж/возвратов".


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     Btn_Cancel AT ROW 1 COL 1
     b-print AT ROW 1 COL 51
     b-help AT ROW 1 COL 61
     BR-cshr-del AT ROW 2.46 COL 1
     BR-cshr-sum AT ROW 11.17 COL 1
     SPACE(0.23) SKIP(0.32)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Архив по кассиру"
         CANCEL-BUTTON Btn_Cancel.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: del_cshr-month B "?" ? ub cshr-month
      TABLE: sum_cshr-month B "?" ? ub cshr-month
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
                                                                        */
/* BROWSE-TAB BR-cshr-del b-help Dialog-Frame */
/* BROWSE-TAB BR-cshr-sum BR-cshr-del Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN
       b-print:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-b-print:HANDLE.

ASSIGN
       BR-cshr-del:NUM-LOCKED-COLUMNS IN FRAME Dialog-Frame     = 2.

ASSIGN
       BR-cshr-sum:NUM-LOCKED-COLUMNS IN FRAME Dialog-Frame     = 2.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-cshr-del
/* Query rebuild information for BROWSE BR-cshr-del
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH del_cshr-month
      WHERE del_cshr-month.cshr-code = p-cashier-code AND
(
del_cshr-month.cashier-psn-code = p-psn-code or del_cshr-month.cashier-psn-code = 0)
 AND ( del_cshr-month.out-count <> 0
 OR del_cshr-month.ret-count <> 0 )  SHARE-LOCK INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "SHARE-LOCK INDEXED-REPOSITION"
     _Where[1]         = "del_cshr-month.cshr-code = p-cashier-code AND
(
del_cshr-month.cashier-psn-code = p-psn-code or del_cshr-month.cashier-psn-code = 0)
 AND ( del_cshr-month.out-count <> 0
 OR del_cshr-month.ret-count <> 0 ) "
     _Query            is OPENED
*/  /* BROWSE BR-cshr-del */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-cshr-sum
/* Query rebuild information for BROWSE BR-cshr-sum
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH sum_cshr-month
      WHERE sum_cshr-month.cshr-code = p-cashier-code and (
sum_cshr-month.cashier-psn-code = p-psn-code or sum_cshr-month.cashier-psn-code = 0) SHARE-LOCK INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "SHARE-LOCK INDEXED-REPOSITION"
     _Where[1]         = "sum_cshr-month.cshr-code = p-cashier-code and (
sum_cshr-month.cashier-psn-code = p-psn-code or sum_cshr-month.cashier-psn-code = 0)"
     _Query            is OPENED
*/  /* BROWSE BR-cshr-sum */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Архив по кассиру */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-print Dialog-Frame
ON CHOOSE OF b-print IN FRAME Dialog-Frame /* Печать */
DO:
   if print-option = "" then do:
     run gbl/pop-up.p ( input self:handle, input no) no-error.
   end.
   if print-option = "":U then return no-apply.
   run proc-b-print in this-procedure ( input-output print-option) no-error.
   if error-status:error then do:
    assign
    print-option = "":U.
    return no-apply.
   end.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_cshr-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_cshr-del Dialog-Frame
ON CHOOSE OF MENU-ITEM m_cshr-del /* Отмененные/аннулированные строки чеков */
DO:
  assign
  print-option = "cshr-del":U
  .
  run proc-b-print in this-procedure ( input-output print-option) no-error.
  if error-status:error then do:
    assign
    print-option = "":U
    .
    return no-apply.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_cshr-sum
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_cshr-sum Dialog-Frame
ON CHOOSE OF MENU-ITEM m_cshr-sum /* Итоги продаж/возвратов */
DO:
    assign
  print-option = "cshr-sum":U
  .
  run proc-b-print in this-procedure ( input-output print-option) no-error.
  if error-status:error then do:
    assign
    print-option = "":U
    .
    return no-apply.
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-cshr-del
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.
{ gbl/app_help.i &disable_diasize_init=true &browse-name="br-cshr-sum" }
{ gbl/brwrepos.i
  &line-num=5
}

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

    FIND FIRST ub.person WHERE ub.person.psn-code = p-psn-code NO-LOCK .
    FIND ub.clients WHERE ub.clients.obj-type = {&prs} AND
                                       ub.clients.obj-code = ub.person.psn-code NO-LOCK .
    FRAME {&FRAME-NAME}:title = substitute("Архивы по кассиру ( код &1 )   &2"
                                          , p-cashier-code
                                          , clients.obj-name).
    RUN MYenable in this-procedure .
    apply "entry" to BR-cshr-sum in FRAME {&FRAME-NAME}.
    run diasize_add_browse in this-procedure
        (input  'width':u
        ,input  browse br-cshr-del:handle
        ) .
      run diasize_init in this-procedure .

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
  ENABLE Btn_Cancel b-print b-help BR-cshr-del BR-cshr-sum
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
assign
b-print:MENU-MOUSE in frame {&frame-name} = 1
.
ENABLE
b-print
Btn_Cancel
b-help
BR-cshr-sum
BR-cshr-del
WITH FRAME {&frame-name} .
VIEW FRAME {&frame-name} .
{&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-print Dialog-Frame
PROCEDURE proc-b-print :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DEFINE INPUT-output  PARAMETER p-print-option as character no-undo.
define variable v-doc-rec as recid no-undo.
DEFINE VARIABLE date_string  as character no-undo.
DEFINE VARIABLE Line as character no-undo .
DEFINE VARIABLE for-all-totchk  like ub.cshr-month.out-totchk no-undo .
DEFINE VARIABLE for-all-totsum  like ub.cshr-month.out-totsum no-undo .
DEFINE VARIABLE accum-out-count like ub.cshr-month.out-count no-undo.
DEFINE VARIABLE accum-out-qnty like ub.cshr-month.out-qnty no-undo .
DEFINE VARIABLE accum-out-sum like ub.cshr-month.out-sum no-undo .
DEFINE VARIABLE accum-ret-count  like ub.cshr-month.ret-count no-undo .
DEFINE VARIABLE accum-ret-qnty like ub.cshr-month.ret-qnty no-undo .
DEFINE VARIABLE accum-ret-sum  like ub.cshr-month.ret-sum no-undo .
DEFINE VARIABLE accum-all-totchk like ub.cshr-month.out-totchk no-undo .
DEFINE VARIABLE accum-out-totchk like ub.cshr-month.out-totchk no-undo .
DEFINE VARIABLE accum-all-totsum like ub.cshr-month.out-totsum no-undo .
DEFINE VARIABLE accum-out-totsum like ub.cshr-month.out-totsum no-undo .
DEFINE VARIABLE accum-ret-totchk like ub.cshr-month.ret-totchk no-undo .
DEFINE VARIABLE accum-ret-totsum like ub.cshr-month.ret-totsum no-undo .

define variable v-header-base-curr as character no-undo .
define variable v-curr-r-b as character no-undo .
{ gbl/curr-r-b.i
  v-curr-r-b
}
if v-curr-r-b = {&r-b-base} then do:
  assign
  v-header-base-curr = string( "( Баз.Вал. )" )
  .
end.

DEFINE FRAME del-List
del_cshr-month.cashier-psn-code COLUMN-LABEL "Код!физ.лица"
del_cshr-month.obj-code COLUMN-LABEL "Маг-н"
del_cshr-month.month_ COLUMN-LABEL "Ме!сяц"
del_cshr-month.year_
del_cshr-month.out-count COLUMN-LABEL "Продажа!(строк)" FORMAT "->>>>>>9"
del_cshr-month.out-qnty FORMAT "->>,>>>,>>9.999"
del_cshr-month.out-sum FORMAT "->>,>>>,>>>,>>9.99"
del_cshr-month.ret-count COLUMN-LABEL "Возврат!(строк)" FORMAT "->>>>>>9"
del_cshr-month.ret-qnty FORMAT "->>,>>>,>>9.999"
del_cshr-month.ret-sum FORMAT "->>,>>>,>>>,>>9.99"
HEADER  date_string AT 5 format "X(35)"
v-header-base-curr       format "X(20)"
string( "Страница " ) format "X(9)" AT 90 PAGE-NUMBER(PrnLibStream) AT 100 FORMAT ">>9" SKIP
Line format "X(114)" AT 1
with width {&DOS_CW_2} down stream-io use-text    .

DEFINE FRAME sum-List
sum_cshr-month.cashier-psn-code COLUMN-LABEL "Код!физ.лица"
sum_cshr-month.obj-code COLUMN-LABEL "Маг-н"
sum_cshr-month.month_ COLUMN-LABEL "Ме!сяц"
sum_cshr-month.year_
for-all-totchk  /*sum_cshr-month.out-totchk + sum_cshr-month.ret-totchk*/ COLUMN-LABEL "Всего!чеков" FORMAT ">>>>>>9"
sum_cshr-month.out-totchk COLUMN-LABEL "Чеков!продаж" FORMAT ">>>>>>9"
for-all-totsum /*sum_cshr-month.out-totsum + sum_cshr-month.ret-totsum */ COLUMN-LABEL "Выручка" FORMAT "->>,>>>,>>>,>>9.99"
sum_cshr-month.out-totsum FORMAT "->>,>>>,>>>,>>9.99"
sum_cshr-month.ret-totchk COLUMN-LABEL "Чеков!возвратов" FORMAT ">>>>>>9"
sum_cshr-month.ret-totsum FORMAT "->>,>>>,>>>,>>9.99"
HEADER  date_string AT 5 format "X(35)"
v-header-base-curr       format "X(20)"
string( "Страница " ) format "X(9)" AT 90 PAGE-NUMBER(PrnLibStream) AT 100 FORMAT ">>9" SKIP
Line format "X(105)" AT 1
with width {&DOS_CW_2} down stream-io use-text    .

date_string = cur-time-print() .
case p-print-option:
  when "cshr-del":U then do:
      assign
      v-doc-rec = recid(del_cshr-month)
      .
    DO WHILE available del_cshr-month :
          GET prev BR-cshr-del.
    END.
    Line = fill("-", 114).
    run prn-lib-open-stream  in this-procedure (
                                                input parParentProc
                                                ,input {&CS_PS}
                                                ,input yes /*p-is-stream*/
                                                ,input no /*p-append*/
                                                ).
    PUT  STREAM PrnLibStream
    SPACE(25) ( frame {&frame-name}:title ) format "x(90)" skip
    space(25) br-cshr-del:title  format "x(90)" SKIP(1) .
    FORM HEADER
    Line format "X(114)" AT 1 SKIP
    "Продолжение - на следующей странице" AT 30 SKIP
    with FRAME BottomFrame width {&DOS_CW_2} PAGE-BOTTOM NO-LABELS NO-BOX .
    VIEW  STREAM PrnLibStream FRAME BottomFrame .
    FORM with FRAME Del-List  .
    run waitfram-show in this-procedure ("Ждите...").
    GET next br-cshr-del.
    DO WHILE available del_cshr-month :
      Display STREAM PrnLibStream
      del_cshr-month.cashier-psn-code
      del_cshr-month.obj-code
      del_cshr-month.month_
      del_cshr-month.year_
      del_cshr-month.out-count
      del_cshr-month.out-qnty
      del_cshr-month.out-sum
      del_cshr-month.ret-count
      del_cshr-month.ret-qnty
      del_cshr-month.ret-sum
      with FRAME Del-List .
      DOWN STREAM PrnLibStream 1 with FRAME Del-List  .
      assign
      accum-out-count = accum-out-count + del_cshr-month.out-count
      accum-out-qnty = accum-out-qnty + del_cshr-month.out-qnty
      accum-out-sum = accum-out-sum + del_cshr-month.out-sum
      accum-ret-count  = accum-ret-sum + del_cshr-month.ret-count
      accum-ret-qnty = accum-ret-qnty + del_cshr-month.ret-qnty
      accum-ret-sum = accum-ret-sum + del_cshr-month.ret-sum
      .
      GET next br-cshr-del.
    END.
    UNDERLINE  STREAM PrnLibStream
    del_cshr-month.cashier-psn-code
    del_cshr-month.obj-code
    del_cshr-month.month_
    del_cshr-month.year_
    del_cshr-month.out-count
    del_cshr-month.out-qnty
    del_cshr-month.out-sum
    del_cshr-month.ret-count
    del_cshr-month.ret-qnty
    del_cshr-month.ret-sum
    with FRAME Del-List .
    DISPLAY STREAM PrnLibStream
    "ИТОГО" @ del_cshr-month.obj-code
    accum-out-count @ del_cshr-month.out-count
    accum-out-qnty @  del_cshr-month.out-qnty
    accum-out-sum @   del_cshr-month.out-sum
    accum-ret-count @  del_cshr-month.ret-count
    accum-ret-qnty  @ del_cshr-month.ret-qnty
    accum-ret-sum @ del_cshr-month.ret-sum
    with frame Del-List.
    HIDE  STREAM PrnLibStream FRAME BottomFrame .
    HIDE  STREAM PrnLibStream FRAME CheckList.
    output  STREAM PrnLibStream CLOSE.
    run waitfram-hide in this-procedure .
    run prn-lib-prn-file in this-procedure (
                                              input parParentProc
                                              ,input 0
                                              ).
    reposition br-cshr-del to recid v-doc-rec no-error.
    apply "entry" to br-cshr-del in frame {&frame-name}.
  end.
  when "cshr-sum":U then do:
      assign
      v-doc-rec = recid(sum_cshr-month)
      .
    DO WHILE available sum_cshr-month :
          GET prev BR-cshr-sum.
    END.

    Line = fill("-", 105).
    run prn-lib-open-stream  in this-procedure (
                                                input parParentProc
                                                ,input {&CS_PS}
                                                ,input yes /*p-is-stream*/
                                                ,input no /*p-append*/
                                                ).

    PUT  STREAM PrnLibStream
    SPACE(25) ( frame {&frame-name}:title ) format "x(90)"  skip
    space(25) br-cshr-sum:title  format "x(90)"
    SKIP(1) .
    FORM HEADER
    Line format "X(105)" AT 1 SKIP
    "Продолжение - на следующей странице" AT 30 SKIP
    with FRAME BottomFrame width {&DOS_CW_2} PAGE-BOTTOM NO-LABELS NO-BOX .
    VIEW  STREAM PrnLibStream FRAME BottomFrame .
    FORM with FRAME SUm-List  .
    run waitfram-show in this-procedure ("Ждите...").
    GET next br-cshr-sum.
    DO WHILE available sum_cshr-month :
      Display STREAM PrnLibStream
      sum_cshr-month.cashier-psn-code
      sum_cshr-month.obj-code
      sum_cshr-month.month_
      sum_cshr-month.year_
      (sum_cshr-month.out-totchk + sum_cshr-month.ret-totchk) @  for-all-totchk
      sum_cshr-month.out-totchk
      (sum_cshr-month.out-totsum + sum_cshr-month.ret-totsum ) @ for-all-totsum
      sum_cshr-month.out-totsum
      sum_cshr-month.ret-totchk
      sum_cshr-month.ret-totsum
      with FRAME sum-List .
      DOWN STREAM PrnLibStream 1 with FRAME sum-List  .
      assign
      accum-all-totchk = accum-all-totchk + sum_cshr-month.out-totchk + sum_cshr-month.ret-totchk
      accum-out-totchk = accum-out-totchk + sum_cshr-month.out-totchk
      accum-all-totsum = accum-all-totsum + sum_cshr-month.out-totsum + sum_cshr-month.ret-totsum
      accum-out-totsum = accum-out-totsum + sum_cshr-month.out-totsum
      accum-ret-totchk = accum-ret-totchk + sum_cshr-month.ret-totchk
      accum-ret-totsum = accum-ret-totsum + sum_cshr-month.ret-totsum
      .
      GET next br-cshr-sum.
    END.
    UNDERLINE  STREAM PrnLibStream
    sum_cshr-month.cashier-psn-code
    sum_cshr-month.obj-code
    sum_cshr-month.month_
    sum_cshr-month.year_
    for-all-totchk
    sum_cshr-month.out-totchk
    for-all-totsum
    sum_cshr-month.out-totsum
    sum_cshr-month.ret-totchk
    sum_cshr-month.ret-totsum
    with FRAME sum-List .
    DISPLAY STREAM PrnLibStream
    "ИТОГО" @ sum_cshr-month.obj-code
    accum-all-totchk @ for-all-totchk
    accum-out-totchk @ sum_cshr-month.out-totchk
    accum-all-totsum @ for-all-totsum
    accum-out-totsum @ sum_cshr-month.out-totsum
    accum-ret-totchk @ sum_cshr-month.ret-totchk
    accum-ret-totsum @ sum_cshr-month.ret-totsum
    with frame sum-List.
    HIDE  STREAM PrnLibStream FRAME BottomFrame .
    HIDE  STREAM PrnLibStream FRAME CheckList.
    output  STREAM PrnLibStream CLOSE.
    run waitfram-hide in this-procedure .
    run prn-lib-prn-file in this-procedure (
                                              input parParentProc
                                              ,input 0
                                              ).
    reposition br-cshr-sum to recid v-doc-rec no-error.
    apply "entry" to br-cshr-sum in frame {&frame-name}.
  end.
END CASE.
assign
p-print-option = ""
.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
