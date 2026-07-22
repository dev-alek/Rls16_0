&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame

/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER X_gds-obj FOR ub.gds-obj.
DEFINE BUFFER X_gds-prt FOR ub.gds-prt.
DEFINE BUFFER X_goods FOR ub.goods.


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Отрицательные остатки по строкам продажи

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/04/05
Author: Bakhtadze Natalya
Creation date: 10/04/05

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-mode  AS CHARACTER NO-UNDO.
define input parameter p-inkas-code  like ub.inkas.inkas-code no-undo .
define input parameter p-auto-fbr as logical no-undo .
define input parameter p-is-tpsi-obj as logical no-undo .
define input parameter p-neg-tpsi-oper as logical no-undo .


/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Отрицательные остатки по строкам продажи".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/showinf.i }
{ str/lib-def.i }
{ str/trdcalib.i }
{ str/tpsidoc.i "shared" }
{ str/dtl-rest.i " " "DEF" }
{ cmp/r-pril.i new }
{ gbl/prn-lib.i }
{ gbl/cur-time.i }
{ gbl/waitfram.i }

define buffer buf_sale-doc for ub.sale-doc.
define buffer buf_inkas for ub.inkas.
DEFINE VARIABLE var-rec as recid no-undo.
define buffer buf_doc-line for ub.doc-line.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BROWSE-dtl-rests

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES dtl-rests X_goods X_gds-obj X_gds-prt

/* Definitions for BROWSE BROWSE-dtl-rests                              */
&Scoped-define FIELDS-IN-QUERY-BROWSE-dtl-rests if dtl-rests.prt-code < 0 then "партии" else "шкале" dtl-rests.artic dtl-rests.b-code X_goods.gds-name (if dtl-rests.prt-code < 0 then "" else ( IF X_gds-prt.node-name <> {&empty-scale} and X_gds-prt.upper-code <> X_goods.prt-root then X_gds-prt.node-name else {&empty-scale}) ) X_goods.unit-base dtl-rests.fbr > 0 dtl-rests.prop > 0 dtl-rests.is-neg-tpsi-weight dtl-rests.is-neg-tpsi-qnty dtl-rests.is-neg-tpsi-oper dtl-rests.ok-prop if dtl-rests.prt-code < 0 then dtl-rests.rest-fact-qnty else 0 if dtl-rests.prt-code < 0 then dtl-rests.maybe-qnty else 0 if dtl-rests.prt-code < 0 then X_gds-obj.fact-qnty else 0 if dtl-rests.prt-code < 0 then X_gds-obj.free-qnty else 0 if dtl-rests.prt-code >= 0 then dtl-rests.maybe-qnty else dtl-rests.prt-qnty if dtl-rests.prt-code >= 0 then dtl-rests.free-qnty else 0 if dtl-rests.prt-code >= 0 then dtl-rests.prt-qnty else 0
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-dtl-rests
&Scoped-define SELF-NAME BROWSE-dtl-rests
&Scoped-define QUERY-STRING-BROWSE-dtl-rests FOR EACH dtl-rests NO-LOCK WHERE dtl-rests.to-view = YES, ~
             FIRST X_goods NO-LOCK, ~
             FIRST X_gds-obj NO-LOCK, ~
             FIRST X_gds-prt NO-LOCK
&Scoped-define OPEN-QUERY-BROWSE-dtl-rests OPEN QUERY browse-dtl-rests FOR EACH dtl-rests NO-LOCK WHERE dtl-rests.to-view = YES, ~
             FIRST X_goods NO-LOCK, ~
             FIRST X_gds-obj NO-LOCK, ~
             FIRST X_gds-prt NO-LOCK .
&Scoped-define TABLES-IN-QUERY-BROWSE-dtl-rests dtl-rests X_goods X_gds-obj ~
X_gds-prt
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-dtl-rests dtl-rests
&Scoped-define SECOND-TABLE-IN-QUERY-BROWSE-dtl-rests X_goods
&Scoped-define THIRD-TABLE-IN-QUERY-BROWSE-dtl-rests X_gds-obj
&Scoped-define FOURTH-TABLE-IN-QUERY-BROWSE-dtl-rests X_gds-prt


/* Definitions for DIALOG-BOX Dialog-Frame                              */

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit B-mark b-print B-Help ~
BROWSE-dtl-rests fill-info prod-name
&Scoped-Define DISPLAYED-OBJECTS fill-info prod-name

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-mark
     LABEL "&*"
     SIZE 4 BY 1.

DEFINE BUTTON b-print
     LABEL "Пе&чать"
     SIZE 10 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE fill-info AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 95.5 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE prod-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 50 BY .67 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BROWSE-dtl-rests FOR
      dtl-rests,
      X_goods,
      X_gds-obj,
      X_gds-prt SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BROWSE-dtl-rests
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-dtl-rests Dialog-Frame _FREEFORM
  QUERY BROWSE-dtl-rests NO-LOCK DISPLAY
      if dtl-rests.prt-code < 0 then "партии" else "шкале"
                                   column-label "Ошибки по" format "X(7)"
dtl-rests.artic COLUMN-LABEL "Артикул" dtl-rests.b-code format ">>>>>>>>>>" COLUMn-LABEL "Бар-код"
X_goods.gds-name COLUMN-LABEL "Название" format "x(35)"
(if dtl-rests.prt-code < 0 then "" else
    ( IF X_gds-prt.node-name <> {&empty-scale} and X_gds-prt.upper-code <> X_goods.prt-root
      then X_gds-prt.node-name else {&empty-scale}) ) COLUMN-LABEL "Партия/шкала"
      FORMAT "X(16)"
X_goods.unit-base  COLUMN-LABEL "Ед.!изм"
dtl-rests.fbr > 0 COLUMN-LABEL "Товар!пр-ва" FORMAT "+/"
dtl-rests.prop > 0 COLUMN-LABEL "Чуж" FORMAT "+/"
dtl-rests.is-neg-tpsi-weight COLUMN-LABEL "Чуж.!вес.!OK" FORMAT "+/"
dtl-rests.is-neg-tpsi-qnty COLUMN-LABEL "Чуж!Кол <!OK" FORMAT "+/"
dtl-rests.is-neg-tpsi-oper COLUMN-LABEL "Чуж!Опер-р!Да?" FORMAT "+/"
dtl-rests.ok-prop COLUMN-LABEL "Чуж!OK" FORMAT "+/"
if dtl-rests.prt-code < 0 then dtl-rests.rest-fact-qnty else 0 COLUMN-LABEL "Рез.(расход)!(партии)" format "->>,>>>.<<<"
if dtl-rests.prt-code < 0 then dtl-rests.maybe-qnty else 0  COLUMN-LABEL "Рез.(возврат)!(партии)" format "->>,>>>.<<<"
if dtl-rests.prt-code < 0 then X_gds-obj.fact-qnty else 0 format "->>>,>>>,>>>.<<<" COLUMn-LABEL "Факт(партии)"
if dtl-rests.prt-code < 0 then X_gds-obj.free-qnty else 0 COLUMN-LABEL "Своб.(партии)" format "->>>,>>>,>>>.<<<"
if dtl-rests.prt-code >= 0 then dtl-rests.maybe-qnty else dtl-rests.prt-qnty COLUMN-LABEL "Еще!требуется" format "->>,>>>.<<<"
if dtl-rests.prt-code >= 0 then dtl-rests.free-qnty else 0 COLUMN-LABEL "Своб.(шкалa)" format  "->>>,>>>,>>>.<<<"
if dtl-rests.prt-code >= 0 then dtl-rests.prt-qnty else 0 COLUMN-LABEL "Факт.(шкалa)" format "->>>,>>>,>>>.<<<"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 13.5 EXPANDABLE.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-mark AT ROW 1 COL 21
     b-print AT ROW 1 COL 51
     B-Help AT ROW 1 COL 61
     BROWSE-dtl-rests AT ROW 4.5 COL 1
     fill-info AT ROW 2.25 COL 1 COLON-ALIGNED NO-LABEL
     prod-name AT ROW 3.5 COL 1 COLON-ALIGNED NO-LABEL
     SPACE(46.62) SKIP(14.07)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE ""
         CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: X_gds-obj B "?" ? ub gds-obj
      TABLE: X_gds-prt B "?" ? ub gds-prt
      TABLE: X_goods B "?" ? ub goods
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
                                                                        */
/* BROWSE-TAB BROWSE-dtl-rests B-Help Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-dtl-rests
/* Query rebuild information for BROWSE BROWSE-dtl-rests
     _START_FREEFORM
OPEN QUERY browse-dtl-rests
FOR EACH dtl-rests NO-LOCK WHERE dtl-rests.to-view = YES,
      FIRST X_goods NO-LOCK,
      FIRST X_gds-obj NO-LOCK,
      FIRST X_gds-prt NO-LOCK .
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is NOT OPENED
*/  /* BROWSE BROWSE-dtl-rests */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mark Dialog-Frame
ON CHOOSE OF B-mark IN FRAME Dialog-Frame /* * */
OR return, MOUSE-SELECT-DBLCLICK of {&BROWSE-NAME} in frame {&FRAME-NAME} do:

DEFINE BUFFER buf_dtl-rests FOR dtl-rests.
if NOT available dtl-rests then   do:
RETURN NO-APPLY.
end.
if dtl-rests.prop = 0 then do:
  message
  "Отметить можно только ЧУЖИЕ ТОВАРЫ"
  view-as alert-box error .
  return no-apply.
end.
FIND FIRST buf_dtl-rests WHERE RECID(buf_dtl-rests) = recid(dtl-rests).
ASSIGN
buf_dtl-rests.is-neg-tpsi-oper = NOT buf_dtl-rests.is-neg-tpsi-oper
buf_dtl-rests.ok-prop = (buf_dtl-rests.is-neg-tpsi-weight
                       OR
                       buf_dtl-rests.is-neg-tpsi-qnty
                       OR
                       buf_dtl-rests.is-neg-tpsi-oper)
.
browse-dtl-rests:REFRESH().
if LOOKUP(last-event:function,  "MOUSE-SELECT-DBLCLICK, RETURN":U) = 0  then  do:
    browse-dtl-rests:SELECT-NEXT-ROW().
    APPLY "value-changed" TO browse-dtl-rests.
end.
APPLY "entry" TO browse-dtl-rests.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-print Dialog-Frame
ON CHOOSE OF b-print IN FRAME Dialog-Frame /* Печать */
DO:
    var-rec = recid( dtl-rests ).
  DO WHILE available dtl-rests :
    GET prev browse-dtl-rests.
  END.
  run printproc in this-procedure.
  reposition browse-dtl-rests to recid var-rec no-error.
  apply "entry" to browse-dtl-rests in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BROWSE-dtl-rests
&Scoped-define SELF-NAME BROWSE-dtl-rests
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BROWSE-dtl-rests Dialog-Frame
ON VALUE-CHANGED OF BROWSE-dtl-rests IN FRAME Dialog-Frame
DO:
DEFINE BUFFER buf_clients FOR ub.clients.
if not available X_goods then do:
    return no-apply.
end.
FIND FIRST buf_clients where
         buf_clients.obj-type = X_goods.prod-type
     AND buf_clients.obj-code = X_goods.prod-code
NO-LOCK NO-ERROR.
IF AVAILABLE buf_clients then assign
 prod-name = substitute("Пр-ль: &1", buf_clients.obj-name)
.
else prod-name = "".
display
prod-name with frame {&frame-name}.

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

{ gbl/mv-clmn.i
&browse-name = "browse-dtl-rests"
&frame-name = "{&frame-name}"
&ext-col = 13
&start-column = 4 }

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  find first buf_Inkas no-lock where
           buf_inkas.inkas-code = p-inkas-code.
  RUN Myenable IN THIS-PROCEDURE.
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
  DISPLAY fill-info prod-name
      WITH FRAME Dialog-Frame.
  ENABLE b-quit B-mark b-print B-Help BROWSE-dtl-rests fill-info prod-name
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
DEFINE VARIABLE ii AS INTEGER NO-UNDO.
DEFINE VARIABLE cur-column-h AS WIDGET-HANDLE no-undo.
DEFINE BUFFER buf_doc-line FOR ub.doc-line .
browse-dtl-rests:num-locked-columns in frame {&frame-name} = 2.
DISPLAY FILL-INFO
WITH FRAME {&frame-name}.
ENABLE
B-quit
b-help
b-print
b-mark WHEN p-mode = {&UPDATE} and p-neg-tpsi-oper
browse-dtl-rests
FILL-INFO prod-name
WITH FRAME {&frame-name}.
VIEW FRAME {&frame-name}.
ASSIGN
    cur-column-h = BROWSE browse-dtl-rests:first-column .
DO ii = 1 TO BROWSE browse-dtl-rests:NUM-COLUMNS:
    IF  index(cur-column-h:LABEL, "пр-ва") > 0
    AND NOT (p-auto-fbr) THEN DO:
        cur-column-h:VISIBLE  = NO.
    END.
    IF  index(cur-column-h:label, "Чуж" ) > 0
    AND NOT (p-is-tpsi-obj) THEN DO:
        cur-column-h:VISIBLE  = NO.
    END.
    IF  index(cur-column-h:label, "Чуж" ) > 0
    AND index(cur-column-h:label, "!" ) > 0
    AND p-mode <> {&update}  THEN DO:
        cur-column-h:VISIBLE  = NO.
    END.
END.

run waitfram-show in this-procedure ( input "Ждите...").
RUN OpenBR IN THIS-PROCEDURE .
APPLY "ENTRY" TO browse-dtl-rests.
APPLY "VALUE-CHANGED" TO browse-dtl-rests.
run waitfram-hide in this-procedure .
run waitfram-show in this-procedure ( input "Ждите....").
  for each buf_sale-doc where
         buf_sale-doc.inkas-code = p-inkas-code
     and buf_sale-doc.order > 0 :
    if buf_sale-doc.doc-kind = {&sale-add-return-write-off} then NEXT.
    if buf_sale-doc.doc-kind = {&TDEDT_Ras_Vnesh_Kass}
    and p-is-tpsi-obj
    then do:
      for each buf_Doc-line no-lock where
              buf_doc-line.doc-code = buf_sale-doc.doc-code:
        find first tt0-doc-line no-lock where
              tt0-doc-line.artic     = buf_doc-line.artic
          AND tt0-doc-line.prod-type = buf_doc-line.prod-type
          AND tt0-doc-line.prod-code = buf_doc-line.prod-code no-error .
        if  buf_doc-line.fact-qnty <> buf_doc-line.doc-qnty + (if available tt0-doc-line
                                                                then tt0-doc-line.doc-qnty
                                                                else 0) then do:
          run waitfram-hide in this-procedure .
          FILL-INFO = "Данные неполные - не на весь проданный товар выделен резерв!!!".
          leave.
        end.
      end. /*должны пробежать по всем товарам и сравнить количества по заререзвированным у нас и на объектах ТПСИ*/
    end.
    else do:
      IF CAN-FIND(First ub.doc-line where ub.doc-line.doc-code = buf_sale-doc.doc-code AND
                                        ub.doc-line.doc-qnty < ub.doc-line.fact-qnty) then do:
        run waitfram-hide in this-procedure .
        FILL-INFO = "Данные неполные - не на весь проданный товар выделен резерв!!!".
        leave.
      end.
    end.
  end.
  run waitfram-hide in this-procedure .
  DISPLAY FILL-INFO with frame {&Frame-name}.
  frame {&frame-name}:title = substitute("&1&2 продажа &3 Ошибки для товаров, по которым запрещены отриц. остатки"
                                         , buf_inkas.obj-type
                                         , buf_inkas.obj-code
                                         , p-inkas-code).


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OpenBr Dialog-Frame
PROCEDURE OpenBr :
OPEN QUERY browse-dtl-rests
FOR EACH dtl-rests NO-LOCK,
      FIRST X_goods No-LOCK where X_goods.gds-code = dtl-rests.gds-code,
      FIRST X_gds-obj NO-LOCK WHERE
            X_gds-obj.artic = dtl-rests.artic
        AND X_gds-obj.prod-type = dtl-rests.prod-type
        AND X_gds-obj.prod-code = dtl-rests.prod-code
        AND X_gds-obj.obj-type = buf_inkas.obj-type
        AND X_gds-obj.obj-code = buf_inkas.obj-code,
      FIRST X_gds-prt NO-LOCK WHERE
           (X_gds-prt.node-code = dtl-rests.prt-code
            or dtl-rests.prt-code < 0).


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE PrintProc Dialog-Frame
PROCEDURE PrintProc :
define variable date_string     as      char    no-undo.
define variable Line                as      char    no-undo.
define variable for-time as char.
define variable accum-count as integer.
DEFINE VARIABLE v-last-price like ub.gds-obj.last-rubl no-undo .
DEFINE VARIABLE v-need-qnty like dtl-rests.maybe-qnty no-undo .
DEFINE VARIABLE v-doc-num like ub.price-doc.doc-num no-undo .
DEFINE VARIABLE v-root-b-code like ub.bar-code.b-code no-undo .
DEFINE VARIABLE v-prod as character no-undo .
DEFINE VARIABLE v-last-VAT-PC like ub.doc-line.vat-pc no-undo .
define variable v-curr-r-b as character no-undo .
{ gbl/curr-r-b.i
  v-curr-r-b
}

DEFINE buffer buf_doc-line for ub.doc-line .
DEFINE buffer buf_gds-obj for ub.gds-obj .

DEFINE FRAME dtl-List
dtl-rests.b-code  column-label "Бар-код"
dtl-rests.artic
v-prod column-label "Производитель" format "X(12)"
dtl-rests.gds-name
dtl-rests.maybe-qnty column-label "Количество" FORMAT "->>>,>>>,>>9.999"
v-last-price column-label "Посл.цена!прихода"
v-last-VAT-PC column-label "Посл.НДС!прихода!"
HEADER  date_string AT 5 format "X(35)"
string( "Страница " ) format "X(9)" AT 50 PAGE-NUMBER(PrnLibStream) AT 60 FORMAT ">>9" SKIP
Line format "X(123)" AT 1
with width {&A4_CW0} down stream-io use-text    .
assign
Line = fill("-", 123)
date_string = cur-time-print()
.


run prn-lib-open-stream  in this-procedure (
                                             input parParentProc
                                            ,input {&LS_PS_A4}
                                            ,input yes /*p-is-stream*/
                                            ,input no /*p-append*/
                                            ).


PUT  STREAM PrnLibStream SPACE(25) ( frame {&frame-name}:title )
format "x(90)" SKIP(1) .
FORM HEADER
Line format "X(123)" AT 1 SKIP
"Продолжение - на следующей странице" AT 30 SKIP
with FRAME BottomFrame width {&A4_CW0} PAGE-BOTTOM NO-LABELS NO-BOX .
VIEW  STREAM PrnLibStream FRAME BottomFrame .

FORM with FRAME Dtl-List  .
run waitfram-show in this-procedure ( "Ждите...").
GET next browse-dtl-rests.
DO WHILE available dtl-rests :
  assign
  v-last-price = ?
  v-root-b-code = ?
  .
  { gbl/gdsbcode.i
   dtl-rests.gds-code
   ?
   v-root-b-code
   no-error

   }
  if error-status:error then do:
    message
    vss-workfile vss-revision vss-description skip
    return-value
    view-as alert-box error .
    run waitfram-hide in this-procedure .
    return error .
  end.
  find first buf_gds-obj no-lock where
             buf_gds-obj.artic = dtl-rests.artic and
            buf_gds-obj.prod-type = dtl-rests.prod-type and
            buf_gds-obj.prod-code = dtl-rests.prod-code and
            buf_gds-obj.obj-type = buf_inkas.obj-type and
            buf_gds-obj.obj-code = buf_inkas.obj-code no-error .
  if not avail buf_gds-obj then do:
    assign
    v-last-price = ?
    .
  end.
  else do:
    assign
    v-last-price = (if v-curr-r-b = {&r-b-base} then buf_gds-obj.last-base else buf_gds-obj.last-rubl)
    .
  end.
  find last buf_doc-line no-lock where
            buf_doc-line.obj-type =  buf_inkas.obj-type
       AND  buf_doc-line.obj-code = buf_inkas.obj-code
       AND  buf_doc-line.artic = dtl-rests.artic
       AND  buf_doc-line.prod-type = dtl-rests.prod-type
       AND  buf_doc-line.prod-code = dtl-rests.prod-code
       AND  buf_doc-line.ext-doc-type = {&TDEDT_Pri_Vnesh}
       AND  buf_doc-line.status_ = {&fact} use-index  dt-fo no-error .
  if avail buf_doc-line then do:
    assign
    v-last-VAT-pc = buf_doc-line.vat-pc
    .
  end.
  else do:
    assign
    v-last-vat-pc = ?
    .
  end.


  Display STREAM PrnLibStream
  (if dtl-rests.b-code <> 0 then dtl-rests.b-code else v-root-b-code) @ dtl-rests.b-code
  dtl-rests.artic
 ( dtl-rests.prod-type + string(dtl-rests.prod-code)) @ v-prod
  X_goods.gds-name @ dtl-rests.gds-name
  (if dtl-rests.prt-code >= 0 then dtl-rests.maybe-qnty else dtl-rests.prt-qnty)  @ dtl-rests.maybe-qnty
  v-last-price
  v-last-vat-pc
  with FRAME dtl-List .
  DOWN STREAM PrnLibStream 1
  with FRAME dtl-List  .
  assign
  accum-count = accum-count + 1
  .
  GET next browse-dtl-rests.
END.
UNDERLINE  STREAM PrnLibStream
dtl-rests.b-code
dtl-rests.artic
v-prod
dtl-rests.gds-name
dtl-rests.maybe-qnty
v-last-price
v-last-vat-pc
with FRAME dtl-List .
DISPLAY STREAM PrnLibStream
"ИТОГО"  @ dtl-rests.b-code
accum-count @ dtl-rests.artic
with frame dtl-List.
HIDE  STREAM PrnLibStream FRAME BottomFrame .
HIDE  STREAM PrnLibStream FRAME dtl-List.
output  STREAM PrnLibStream CLOSE.

run waitfram-hide in this-procedure .
run prn-lib-prn-file in this-procedure (
                                          input parParentProc
                                          ,input 0
                                          ).



END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME