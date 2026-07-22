&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame

/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE tt-goods NO-UNDO LIKE goods.


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Просмотр партий по удаленному документу фин.обязательств

Автор: Чернова Светлана Александровна
Дата создания: 04/14/06
Author: Svetlana Chernova
Creation date: 04/14/06



*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */
DEFINE INPUT PARAMETER parParentProc  AS WIDGET-HANDLE NO-UNDO.
define input parameter p-fin-doc-code like ub.c-fin-ob.doc-code no-undo.
define input parameter p-host-code    like ub.c-fin-ob.host-code no-undo.

/* Parameters Definitions ---                                           */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Просмотр партий по удаленному документу фин.обязательств ".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/showinf.i  }
{ cmp/r-pril.i new }
{ gbl/prn-lib.i  }
{ gbl/cur-time.i }
{ gbl/waitfram.i }
{ gbl/getcntxt.i def }


/* Local Variable Definitions ---                                       */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BR-goods

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-goods clients c-fin-gds-part

/* Definitions for BROWSE BR-goods                                      */
&Scoped-define FIELDS-IN-QUERY-BR-goods tt-goods.gds-type tt-goods.gds-code ~
tt-goods.artic tt-goods.unit-base tt-goods.unit-cli tt-goods.gds-name ~
clients.obj-name tt-goods.grp-name
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-goods tt-goods.gds-type
&Scoped-define ENABLED-TABLES-IN-QUERY-BR-goods tt-goods
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-BR-goods tt-goods
&Scoped-define QUERY-STRING-BR-goods FOR EACH tt-goods NO-LOCK, ~
      EACH clients WHERE clients.obj-code = tt-goods.prod-code ~
  AND clients.obj-type = tt-goods.prod-type NO-LOCK
&Scoped-define OPEN-QUERY-BR-goods OPEN QUERY BR-goods FOR EACH tt-goods NO-LOCK, ~
      EACH clients WHERE clients.obj-code = tt-goods.prod-code ~
  AND clients.obj-type = tt-goods.prod-type NO-LOCK.
&Scoped-define TABLES-IN-QUERY-BR-goods tt-goods clients
&Scoped-define FIRST-TABLE-IN-QUERY-BR-goods tt-goods
&Scoped-define SECOND-TABLE-IN-QUERY-BR-goods clients


/* Definitions for BROWSE BR-parts                                      */
&Scoped-define FIELDS-IN-QUERY-BR-parts c-fin-gds-part.out-code ~
c-fin-gds-part.fact-date c-fin-gds-part.fact-qnty c-fin-gds-part.sum-rubl ~
c-fin-gds-part.vat-pc c-fin-gds-part.vat-type c-fin-gds-part.SLT-pc ~
c-fin-gds-part.SLT-type c-fin-gds-part.in-code c-fin-gds-part.obj-code ~
c-fin-gds-part.obj-type c-fin-gds-part.sum-base c-fin-gds-part.part-code ~
c-fin-gds-part.user-name
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-parts c-fin-gds-part.part-code
&Scoped-define ENABLED-TABLES-IN-QUERY-BR-parts c-fin-gds-part
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-BR-parts c-fin-gds-part
&Scoped-define QUERY-STRING-BR-parts FOR EACH c-fin-gds-part ~
      WHERE c-fin-gds-part.fin-ob-code = p-fin-doc-code and ~
ub.c-fin-gds-part.host-code   = p-host-code and ~
ub.c-fin-gds-part.gds-code    = tt-goods.gds-code NO-LOCK
&Scoped-define OPEN-QUERY-BR-parts OPEN QUERY BR-parts FOR EACH c-fin-gds-part ~
      WHERE c-fin-gds-part.fin-ob-code = p-fin-doc-code and ~
ub.c-fin-gds-part.host-code   = p-host-code and ~
ub.c-fin-gds-part.gds-code    = tt-goods.gds-code NO-LOCK.
&Scoped-define TABLES-IN-QUERY-BR-parts c-fin-gds-part
&Scoped-define FIRST-TABLE-IN-QUERY-BR-parts c-fin-gds-part


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BR-goods}~
    ~{&OPEN-QUERY-BR-parts}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-ok B-print B-help BR-goods BR-parts B-trn ~
B-trn-2

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-help DEFAULT
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-ok AUTO-END-KEY
     LABEL "&Выход"
     SIZE 10 BY 1.

DEFINE BUTTON B-print DEFAULT
     LABEL "&Печать"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-trn DEFAULT
     LABEL "&Накл."
     SIZE 10 BY 1 TOOLTIP "Просмотр накладной"
     BGCOLOR 8 .

DEFINE BUTTON B-trn-2 DEFAULT
     LABEL "&Исх накл."
     SIZE 10 BY 1 TOOLTIP "Просмотр порождающей  накладной"
     BGCOLOR 8 .

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-goods FOR
      tt-goods,
      clients SCROLLING.

DEFINE QUERY BR-parts FOR
      c-fin-gds-part SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-goods
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-goods Dialog-Frame _STRUCTURED
  QUERY BR-goods NO-LOCK DISPLAY
      tt-goods.gds-type COLUMN-LABEL "Т" FORMAT "X(1)":U
      tt-goods.gds-code COLUMN-LABEL "Код!товара" FORMAT "999999999":U
      tt-goods.artic FORMAT "X(16)":U
      tt-goods.unit-base COLUMN-LABEL "Ед.!изм." FORMAT "X(3)":U
      tt-goods.unit-cli COLUMN-LABEL "Ед.из!пост." FORMAT "X(3)":U
      tt-goods.gds-name FORMAT "X(48)":U
      clients.obj-name COLUMN-LABEL "Производитель" FORMAT "X(20)":U
      tt-goods.grp-name FORMAT "X(40)":U
  ENABLE
      tt-goods.gds-type
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 97.13 BY 7.33.

DEFINE BROWSE BR-parts
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-parts Dialog-Frame _STRUCTURED
  QUERY BR-parts NO-LOCK DISPLAY
      c-fin-gds-part.out-code COLUMN-LABEL "№ накл" FORMAT "X(14)":U
      c-fin-gds-part.fact-date COLUMN-LABEL "Дата!закрытия" FORMAT "99/99/99":U
      c-fin-gds-part.fact-qnty COLUMN-LABEL "Факт!кол-во" FORMAT "->>,>>>,>>9.999":U
      c-fin-gds-part.sum-rubl COLUMN-LABEL "Сумма({&abbr_rub})" FORMAT "->,>>>,>>>,>>>,>>9.99":U
      c-fin-gds-part.vat-pc FORMAT ">9.9<%":U
      c-fin-gds-part.vat-type FORMAT "X(8)":U
      c-fin-gds-part.SLT-pc FORMAT ">9.9<%":U
      c-fin-gds-part.SLT-type FORMAT "X(8)":U
      c-fin-gds-part.in-code FORMAT "X(14)":U
      c-fin-gds-part.obj-code FORMAT "99999":U
      c-fin-gds-part.obj-type FORMAT "X(3)":U
      c-fin-gds-part.sum-base COLUMN-LABEL "Сумма(б.в.)" FORMAT "->,>>>,>>>,>>>,>>9.99":U
      c-fin-gds-part.part-code COLUMN-LABEL "№ партии" FORMAT "X(5)":U
      c-fin-gds-part.user-name COLUMN-LABEL "Создал" FORMAT "X(8)":U
  ENABLE
      c-fin-gds-part.part-code
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 97.13 BY 8.92
         TITLE "Партии товара".


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-ok AT ROW 1 COL 1
     B-print AT ROW 1 COL 78
     B-help AT ROW 1 COL 88
     BR-goods AT ROW 2.04 COL 1
     BR-parts AT ROW 10.33 COL 1
     B-trn AT ROW 19.46 COL 1.25
     B-trn-2 AT ROW 19.58 COL 87.63
     SPACE(0.62) SKIP(0.58)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Партии документа".


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: tt-goods T "?" NO-UNDO ub goods
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
                                                                        */
/* BROWSE-TAB BR-goods B-help Dialog-Frame */
/* BROWSE-TAB BR-parts BR-goods Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-goods
/* Query rebuild information for BROWSE BR-goods
     _TblList          = "Temp-Tables.tt-goods,ub.clients WHERE Temp-Tables.tt-goods ..."
     _Options          = "NO-LOCK"
     _JoinCode[2]      = "ub.clients.obj-code = Temp-Tables.tt-goods.prod-code
  AND ub.clients.obj-type = Temp-Tables.tt-goods.prod-type"
     _FldNameList[1]   > Temp-Tables.tt-goods.gds-type
"tt-goods.gds-type" "Т" ? "character" ? ? ? ? ? ? yes ? no no ? yes no no "U" "" ""
     _FldNameList[2]   > Temp-Tables.tt-goods.gds-code
"tt-goods.gds-code" "Код!товара" ? "integer" ? ? ? ? ? ? no ? no no ? yes no no "U" "" ""
     _FldNameList[3]   = Temp-Tables.tt-goods.artic
     _FldNameList[4]   > Temp-Tables.tt-goods.unit-base
"tt-goods.unit-base" "Ед.!изм." ? "character" ? ? ? ? ? ? no ? no no ? yes no no "U" "" ""
     _FldNameList[5]   > Temp-Tables.tt-goods.unit-cli
"tt-goods.unit-cli" "Ед.из!пост." ? "character" ? ? ? ? ? ? no ? no no ? yes no no "U" "" ""
     _FldNameList[6]   = Temp-Tables.tt-goods.gds-name
     _FldNameList[7]   > ub.clients.obj-name
"clients.obj-name" "Производитель" "X(20)" "character" ? ? ? ? ? ? no ? no no ? yes no no "U" "" ""
     _FldNameList[8]   = Temp-Tables.tt-goods.grp-name
     _Query            is OPENED
*/  /* BROWSE BR-goods */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-parts
/* Query rebuild information for BROWSE BR-parts
     _TblList          = "ub.c-fin-gds-part"
     _Options          = "NO-LOCK"
     _TblOptList       = ","
     _Where[1]         = "ub.c-fin-gds-part.fin-ob-code = p-fin-doc-code and
ub.c-fin-gds-part.host-code   = p-host-code and
ub.c-fin-gds-part.gds-code    = tt-goods.gds-code"
     _FldNameList[1]   > ub.c-fin-gds-part.out-code
"out-code" "№ накл" ? "character" ? ? ? ? ? ? no ? no no ? yes no no "U" "" ""
     _FldNameList[2]   > ub.c-fin-gds-part.fact-date
"fact-date" "Дата!закрытия" "99/99/99" "date" ? ? ? ? ? ? no ? no no ? yes no no "U" "" ""
     _FldNameList[3]   > ub.c-fin-gds-part.fact-qnty
"fact-qnty" "Факт!кол-во" ? "decimal" ? ? ? ? ? ? no ? no no ? yes no no "U" "" ""
     _FldNameList[4]   > ub.c-fin-gds-part.sum-rubl
"sum-rubl" "Сумма({&abbr_rub})" ? "decimal" ? ? ? ? ? ? no ? no no ? yes no no "U" "" ""
     _FldNameList[5]   = ub.c-fin-gds-part.vat-pc
     _FldNameList[6]   = ub.c-fin-gds-part.vat-type
     _FldNameList[7]   = ub.c-fin-gds-part.SLT-pc
     _FldNameList[8]   = ub.c-fin-gds-part.SLT-type
     _FldNameList[9]   = ub.c-fin-gds-part.in-code
     _FldNameList[10]   = ub.c-fin-gds-part.obj-code
     _FldNameList[11]   = ub.c-fin-gds-part.obj-type
     _FldNameList[12]   > ub.c-fin-gds-part.sum-base
"sum-base" "Сумма(б.в.)" ? "decimal" ? ? ? ? ? ? no ? no no ? yes no no "U" "" ""
     _FldNameList[13]   > ub.c-fin-gds-part.part-code
"part-code" "№ партии" "X(5)" "character" ? ? ? ? ? ? yes ? no no ? yes no no "U" "" ""
     _FldNameList[14]   > ub.c-fin-gds-part.user-name
"user-name" "Создал" ? "character" ? ? ? ? ? ? no ? no no ? yes no no "U" "" ""
     _Query            is OPENED
*/  /* BROWSE BR-parts */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Партии документа */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-print Dialog-Frame
ON CHOOSE OF B-print IN FRAME Dialog-Frame /* Печать */
DO:
  run proc-print in this-procedure .
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-trn
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-trn Dialog-Frame
ON CHOOSE OF B-trn IN FRAME Dialog-Frame /* Накл. */
DO:
  if available c-fin-gds-part and  c-fin-gds-part.out-code <> "" then do:
      run str/fishdoc.p (
                input parParentProc ,
                input c-fin-gds-part.host-code ,
                input c-fin-gds-part.obj-type,
                input c-fin-gds-part.obj-code,
                input c-fin-gds-part.out-code ,
                input c-fin-gds-part.gds-code ) .

end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-trn-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-trn-2 Dialog-Frame
ON CHOOSE OF B-trn-2 IN FRAME Dialog-Frame /* Исх накл. */
DO:
define buffer buf_parts-attr for ub.parts-attr.

  if available c-fin-gds-part and  c-fin-gds-part.in-code <> "" then do:
     find first buf_parts-attr no-lock where
                buf_parts-attr.in-code      = c-fin-gds-part.in-code  and
                buf_parts-attr.part-code    = c-fin-gds-part.part-code and
                buf_parts-attr.gds-code     = c-fin-gds-part.gds-code
                no-error .
                if available buf_parts-attr then
                    run str/fishdoc.p (
                     input  parparentproc ,
                     input  c-fin-gds-part.host-code ,
                     input  c-fin-gds-part.obj-type,
                     input  c-fin-gds-part.obj-code,
                     input  buf_parts-attr.income-in-code ,
                     input  c-fin-gds-part.gds-code
                          ) .
                    else
                    run str/fishdoc.p (
                    input parparentproc ,
                    input c-fin-gds-part.host-code ,
                    input c-fin-gds-part.obj-type,
                    input c-fin-gds-part.obj-code,
                    input c-fin-gds-part.in-code ,
                    input c-fin-gds-part.gds-code
                          ) .
end.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-goods
&Scoped-define SELF-NAME BR-goods
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-goods Dialog-Frame
ON VALUE-CHANGED OF BR-goods IN FRAME Dialog-Frame
DO:
  {&OPEN-QUERY-br-parts}
END.
on F9 of frame dialog-frame anywhere do:
  run show-gds in this-procedure .
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */
 { gbl/app_help.i &disable_diasize_init=true &browse-name="br-goods"}

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

  { gbl/getcntxt.i get }

  run make-tt-goods in this-procedure .
  run enable_ui in this-procedure .

run diasize_add_browse in this-procedure
    (input  'width':u
    ,input  browse br-parts :handle
    ) .

run diasize_init in this-procedure .
tt-goods.gds-name:resizable in browse {&browse-name}   = true .
clients.obj-name:resizable in browse {&browse-name}   = true .
tt-goods.grp-name:resizable in browse {&browse-name}   = true .


  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
run disable_ui in this-procedure .

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
  ENABLE b-ok B-print B-help BR-goods BR-parts B-trn B-trn-2
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE make-tt-goods Dialog-Frame
PROCEDURE make-tt-goods :
ASSIGN frame {&frame-name}:TITLE =
 "Партии по документу Внутр.№ " + string(p-fin-doc-code)  +
 "   ФИРМА: "  +  string(p-host-code)
 .
define buffer buf_c-fin-gds-part for ub.c-fin-gds-part .
define buffer buf_goods for ub.goods .

for each tt-goods : delete tt-goods. end.

for each buf_c-fin-gds-part no-lock where
    buf_c-fin-gds-part.host-code = p-host-code and
    buf_c-fin-gds-part.fin-ob-code  = p-fin-doc-code :
    if not can-find (first tt-goods where tt-goods.gds-code = buf_c-fin-gds-part.gds-code ) then do:
      find first buf_goods where buf_goods.gds-code = buf_c-fin-gds-part.gds-code no-lock no-error .
      if available buf_goods then do:
          create tt-goods.
          BUFFER-COPY buf_goods TO tt-goods .
          /* message tt-goods.artic view-as alert-box . */
      end.
    end.
end.
  {&ENABLED-FIELDS-IN-QUERY-BR-goods} :read-only in browse br-goods = true .
  {&ENABLED-FIELDS-IN-QUERY-BR-parts} :read-only in browse br-parts = true .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-print Dialog-Frame
PROCEDURE proc-print :
do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :
define variable g-log as logical no-undo .
{ gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_fin-liability_print':U
  {&cntxt-firm}
  p-host-code
  '':U
  0
  0
  0
  0
  true
  g-log
}

if not g-log then  return .

define variable date_string     as      char    no-undo.
define variable Line                as      char    no-undo.
define variable for-time as char.


DEFINE FRAME prt-frame
      tt-goods.gds-code      COLUMN-LABEL "Код!товара" FORMAT "999999999":U
      tt-goods.unit-base     COLUMN-LABEL "Ед.!изм." FORMAT "X(3)":U
      tt-goods.gds-name      FORMAT "X(25)":U
      c-fin-gds-part.status_dop   FORMAT "X(6)":U
      c-fin-gds-part.out-code  COLUMN-LABEL "№ накл" FORMAT "X(14)":U
      c-fin-gds-part.fact-date COLUMN-LABEL "Дата!закрытия" FORMAT "99/99/99":U
      c-fin-gds-part.fact-qnty COLUMN-LABEL "Факт!кол-во" FORMAT "->>,>>>,>>9.999":U
      c-fin-gds-part.sum-rubl  COLUMN-LABEL "Сумма({&abbr_rub})" FORMAT "->,>>>,>>>,>>>,>>9.99":U
      c-fin-gds-part.vat-pc    FORMAT ">9.9<%":U
      c-fin-gds-part.SLT-pc    FORMAT ">9.9<%":U
      c-fin-gds-part.obj-code  FORMAT "99999":U
      c-fin-gds-part.obj-type  FORMAT "X(3)":U
      c-fin-gds-part.in-code   FORMAT "X(14)":U COLUMN-LABEL "№ док.в парт."
      c-fin-gds-part.part-code COLUMN-LABEL "№ партии" FORMAT "X(5)":U
      c-fin-gds-part.user-name COLUMN-LABEL "Создал" FORMAT "X(8)":U
        HEADER  date_string AT 5 format "X(35)"
                    string( "Страница " ) format "X(9)" AT 50 PAGE-NUMBER( PrnLibStream) AT 70 FORMAT ">>>>9" SKIP
                    Line format "X(165)" AT 1
    with width {&DOS_CW_2} down stream-io use-text    .

    Line = fill("-", 225).
    date_string = cur-time-print() .
    run prn-lib-open-stream in this-procedure (
       input parParentProc
      ,input {&LS_PS_A4}
      ,input yes /*p-is-stream*/
      ,input no /*p-append*/
      ).
    PUT  STREAM PrnLibStream
    SPACE(25) ( frame {&frame-name}:title )
    format "x(116)" SKIP(1) .
    FORM HEADER
            Line format "X(177)" AT 1 SKIP
            "Продолжение - на следующей странице" AT 30 SKIP
            with FRAME BottomFrame width {&DOS_CW_2} PAGE-BOTTOM NO-LABELS NO-BOX .
    VIEW  STREAM PrnLibStream FRAME BottomFrame .

    FORM with FRAME prt-frame  .
    run waitfram-show in this-procedure ("Ждите...").
    find first tt-goods no-lock no-error .
     for each tt-goods
         on error undo, return error :
            {&OPEN-QUERY-BR-parts}
            DO WHILE available c-fin-gds-part :
                Display STREAM PrnLibStream
                  tt-goods.gds-code
                  tt-goods.unit-base
                  tt-goods.gds-name
                  c-fin-gds-part.status_dop
                  c-fin-gds-part.out-code
                  c-fin-gds-part.fact-date
                  c-fin-gds-part.fact-qnty
                  c-fin-gds-part.sum-rubl
                  c-fin-gds-part.vat-pc
                  c-fin-gds-part.SLT-pc
                  c-fin-gds-part.obj-code
                  c-fin-gds-part.obj-type
                  c-fin-gds-part.in-code
                  c-fin-gds-part.part-code
                  c-fin-gds-part.user-name
                    with FRAME prt-frame .
                    DOWN STREAM PrnLibStream 1 with FRAME prt-frame  .
                    GET next br-parts.
              END.
     end. /* for each */
      UNDERLINE  STREAM PrnLibStream
           tt-goods.gds-code
           tt-goods.unit-base
           tt-goods.gds-name
           c-fin-gds-part.status_dop
           c-fin-gds-part.out-code
           c-fin-gds-part.fact-date
           c-fin-gds-part.fact-qnty
           c-fin-gds-part.sum-rubl
           c-fin-gds-part.vat-pc
           c-fin-gds-part.SLT-pc
           c-fin-gds-part.obj-code
           c-fin-gds-part.obj-type
           c-fin-gds-part.in-code
           c-fin-gds-part.part-code
           c-fin-gds-part.user-name
    with FRAME prt-frame .

    HIDE  STREAM PrnLibStream FRAME BottomFrame .
    HIDE  STREAM PrnLibStream FRAME CheckList.
    output  STREAM PrnLibStream CLOSE.
    run waitfram-hide in this-procedure .
    run prn-lib-prn-file in this-procedure (
        input parParentProc
       ,input 8
        ).
 end. /* do */
end procedure. /* proc-print */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE show-gds Dialog-Frame
PROCEDURE show-gds :
do
 on error undo, return error return-value
 :

  define buffer buf_goods for ub.goods.
  define variable gds-rec as recid no-undo.
  if not available tt-goods then  return no-apply.

  find first buf_goods where buf_goods.gds-code = tt-goods.gds-code no-lock no-error .
  if not available buf_goods then  return no-apply.
  gds-rec = recid (Buf_goods).

  find first shop where shop.host-code = p-host-code  no-lock no-error .

  if available shop then
     run str/showgds.p ( input parParentProc
                        ,input ? /*p-call-handle*/
                        ,input buf_goods.gds-code
                        ,input {&lookup} ) .

  apply "entry" to br-goods in frame Dialog-Frame.

end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME