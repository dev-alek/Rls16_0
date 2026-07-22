&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Состояние заказа

Автор: Чернова Светлана Александровна
Дата создания: 07/04/07
Author: Svetlana Chernova
Creation date: 07/04/07


This .W file was created with the Progress AppBuilder.

*/
define input parameter parparentproc   as widget-handle no-undo.
define input parameter p-mode          as character no-undo.
define input parameter p-doc-code      as character no-undo .
define input parameter br-handle       as handle no-undo.
define input parameter bf-handle       as handle no-undo.
define input-output parameter parnext-prev    as logical no-undo.
define input-output parameter v-doc-rec       as recid no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-Workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Состояние заказа" .
{ cmp/vssrevis.i }
{ cmp/str-glbl.i  }
{ cmp/library.i  }
{ cmp/showinf.i  }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
{ gbl/usr-flt.i  }
define buffer buf_goods for ub.goods.
define temp-table tt_doc-line no-undo like ub.doc-line.
define temp-table tt_ord-line-rcv no-undo like ub.ord-line-rcv.
define temp-table tt_ord-line no-undo like ub.ord-line
field type-str as character
field qnty-rcv as decimal
field qnty-trn as decimal
.
define variable vi-total-rcv as decimal   no-undo init 0.
define variable vi-total-trn as decimal   no-undo init 0.
define variable vi-total-ord as decimal   no-undo init 0.
define buffer buf_ord-doc for ub.ord-doc  .
define buffer buf_ord-line for ub.ord-line  .
define buffer buf_ord-doc-rcv for ub.ord-doc-rcv  .
define buffer buf_ord-line-rcv for ub.ord-line-rcv  .
define buffer buf_trn-doc for ub.trn-doc  .
define buffer buf_doc-line for ub.doc-line  .
define variable v-total-rcv as decimal   no-undo .
define variable v-total-trn as decimal   no-undo .
define variable varlog as logical   no-undo .

define variable v-size-col1 as decimal   no-undo .
define variable v-size-col2 as decimal   no-undo .
define variable v-size-col3 as decimal   no-undo .

run uf-get in this-procedure (
     input  {&uf-ord-sost}
    ,input  v-cntxt-userid
    ,output v-uf-List_
    ,output v-uf-Naim
    ,output v-uf-print-graft
    ,output v-uf-sort-gr
    ,output v-uf-type-price
    ,output v-uf-type-val
)  .


v-size-col1  = decimal (entry(1, v-uf-List_ ,{&delim-par})) no-error.
v-size-col2  = decimal (entry(2, v-uf-List_ ,{&delim-par})) no-error.
v-size-col3   = decimal (entry(3, v-uf-List_ ,{&delim-par})) no-error.

if v-size-col1 = 0  or v-size-col1 = ? then v-size-col1 = 16 .
if v-size-col2 = 0  or v-size-col2 = ? then v-size-col2 = 20 .
if v-size-col3 = 0  or v-size-col3 = ? then v-size-col3 = 12 .


if v-cntxt-db-num <> 0 then p-mode = {&lookup} .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BROWSE-3

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt_ord-line buf_goods

/* Definitions for BROWSE BROWSE-3                                      */
&Scoped-define FIELDS-IN-QUERY-BROWSE-3 tt_ord-line.gds-code tt_ord-line.artic buf_goods.gds-name buf_goods.unit-base tt_ord-line.qnty tt_ord-line.qnty-rcv tt_ord-line.qnty-trn
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-3
&Scoped-define SELF-NAME BROWSE-3
&Scoped-define QUERY-STRING-BROWSE-3 FOR EACH tt_ord-line NO-LOCK, ~
             EACH buf_goods WHERE buf_goods.gds-code = tt_ord-line.gds-code NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-BROWSE-3 OPEN QUERY {&SELF-NAME} FOR EACH tt_ord-line NO-LOCK, ~
             EACH buf_goods WHERE buf_goods.gds-code = tt_ord-line.gds-code NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-BROWSE-3 tt_ord-line buf_goods
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-3 tt_ord-line
&Scoped-define SECOND-TABLE-IN-QUERY-BROWSE-3 buf_goods


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BROWSE-3}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-exit B-quit B-rcv B-trn B-print B-Help ~
B-prev B-next BROWSE-3 i-ord i-rcv i-trn v-status
&Scoped-Define DISPLAYED-OBJECTS COMBO-status i-ord i-rcv i-trn v-status

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-Help
     LABEL "&Help"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-next AUTO-GO
     LABEL "&>>"
     SIZE 5 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-prev AUTO-GO
     LABEL "&<<"
     SIZE 5 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-print
     LABEL "&Печать"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-rcv
     LABEL "&Поставки"
     SIZE 10 BY 1 TOOLTIP "Поставки по товару"
     BGCOLOR 8 .

DEFINE BUTTON B-trn
     LABEL "&Накладные"
     SIZE 12 BY 1 TOOLTIP "Накладные по товару"
     BGCOLOR 8 .

DEFINE VARIABLE COMBO-status AS INTEGER FORMAT "9":U INITIAL 0
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEM-PAIRS "Поставка = заказу",0,
                     "Перепоставка",1,
                     "Недопоставка",2,
                     "Несоответствие",3
     DROP-DOWN-LIST
     SIZE 20.5 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE i-ord AS DECIMAL FORMAT ">>>,>>>,>>>,>>9.999":U INITIAL 0
      VIEW-AS TEXT
     SIZE 19.5 BY 1 TOOLTIP "Итого по заказам"
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE i-rcv AS DECIMAL FORMAT ">>>,>>>,>>>,>>9.999":U INITIAL 0
      VIEW-AS TEXT
     SIZE 19.5 BY 1 TOOLTIP "Итого по поставкам"
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE i-trn AS DECIMAL FORMAT ">>>,>>>,>>>,>>9.999":U INITIAL 0
      VIEW-AS TEXT
     SIZE 19.5 BY 1 TOOLTIP "Итого по накладным"
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE v-status AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 34.5 BY .67
     FGCOLOR 4  NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BROWSE-3 FOR
      tt_ord-line,
      buf_goods SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BROWSE-3
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-3 Dialog-Frame _FREEFORM
  QUERY BROWSE-3 NO-LOCK DISPLAY
      tt_ord-line.gds-code COLUMN-LABEL "Код" FORMAT "999999999":U
      tt_ord-line.artic
      buf_goods.gds-name
      buf_goods.unit-base COLUMN-LABEL "Е.И" FORMAT "X(3)":U WIDTH 3
      tt_ord-line.qnty      COLUMN-LABEL "Заказано" FORMAT ">>>,>>>,>>>,>>9.999":U
      tt_ord-line.qnty-rcv  COLUMN-LABEL "По поставкам"
      tt_ord-line.qnty-trn  COLUMN-LABEL "По накладным" FORMAT "->>>,>>>,>>>,>>9.999":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 99.25 BY 18 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     B-quit AT ROW 1 COL 11
     B-rcv AT ROW 1 COL 21 WIDGET-ID 52
     B-trn AT ROW 1 COL 31 WIDGET-ID 54
     B-print AT ROW 1 COL 80 WIDGET-ID 56
     B-Help AT ROW 1 COL 90
     B-prev AT ROW 2 COL 1 WIDGET-ID 66
     B-next AT ROW 2 COL 6 WIDGET-ID 68
     BROWSE-3 AT ROW 3 COL 1 WIDGET-ID 200
     COMBO-status AT ROW 21.25 COL 7 COLON-ALIGNED NO-LABEL WIDGET-ID 50
     i-ord AT ROW 21.25 COL 36.5 COLON-ALIGNED NO-LABEL WIDGET-ID 58
     i-rcv AT ROW 21.25 COL 57.38 COLON-ALIGNED NO-LABEL WIDGET-ID 60
     i-trn AT ROW 21.25 COL 78 COLON-ALIGNED NO-LABEL WIDGET-ID 62
     v-status AT ROW 22.25 COL 2 NO-LABEL WIDGET-ID 64
     "ИТОГО:" VIEW-AS TEXT
          SIZE 6.5 BY 1 AT ROW 21.25 COL 2 WIDGET-ID 48
          FGCOLOR 4
     SPACE(91.75) SKIP(0.78)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Состояние заказа"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON B-quit WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   Allow: Basic,Browse,DB-Fields,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BROWSE-3 B-next Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR COMBO-BOX COMBO-status IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN v-status IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-3
/* Query rebuild information for BROWSE BROWSE-3
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt_ord-line NO-LOCK,
      EACH buf_goods WHERE buf_goods.gds-code = tt_ord-line.gds-code NO-LOCK INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is OPENED
*/  /* BROWSE BROWSE-3 */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Состояние заказа */
DO:
  run save-proc in this-procedure no-error.
  if error-status :error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Состояние заказа */
OR ENDKEY OF FRAME Dialog-Frame DO:
  parnext-prev = ?.
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-exit Dialog-Frame
ON CHOOSE OF B-exit IN FRAME Dialog-Frame /* Ввод */
DO:
  parnext-prev = ?.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-next
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-next Dialog-Frame
ON CHOOSE OF B-next IN FRAME Dialog-Frame /* >> */
DO:
  RUN step-next in this-procedure .

  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-prev
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-prev Dialog-Frame
ON CHOOSE OF B-prev IN FRAME Dialog-Frame /* << */
DO:
  run step-prev in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-print Dialog-Frame
ON CHOOSE OF B-print IN FRAME Dialog-Frame /* Печать */
DO:
  if not available tt_ord-line then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-quit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-quit Dialog-Frame
ON CHOOSE OF B-quit IN FRAME Dialog-Frame /* Отмена */
DO:
  parnext-prev = ?.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-rcv
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-rcv Dialog-Frame
ON CHOOSE OF B-rcv IN FRAME Dialog-Frame /* Поставки */
DO:
  if not available tt_ord-line then return no-apply.
  run cus/ord-sosr.w
     ( input parparentproc,
     input {&lookup},
     input p-doc-code,
     input tt_ord-line.gds-code,
     input table tt_ord-line-rcv
     ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-trn
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-trn Dialog-Frame
ON CHOOSE OF B-trn IN FRAME Dialog-Frame /* Накладные */
DO:
  if not available tt_ord-line then return no-apply.
  run cus/ord-sosn.w
     ( input parparentproc,
     input {&lookup},
     input p-doc-code,
     input tt_ord-line.gds-code,
     input table tt_doc-line
     ).

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BROWSE-3
&Scoped-define SELF-NAME BROWSE-3
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BROWSE-3 Dialog-Frame
ON ROW-DISPLAY OF BROWSE-3 IN FRAME Dialog-Frame
DO:
  if not available tt_ord-line then return no-apply.
     case tt_ord-line.type-str :
        when "ord" then do:
           run bg-col (?) .
           if tt_ord-line.qnty <> tt_ord-line.qnty-rcv
              then tt_ord-line.qnty-rcv:fgcolor in browse {&browse-name}      = 12.
              else tt_ord-line.qnty-rcv:fgcolor = ?.
           if tt_ord-line.qnty <> tt_ord-line.qnty-trn
              then tt_ord-line.qnty-trn:fgcolor in browse {&browse-name}      = 12.
              else tt_ord-line.qnty-trn:fgcolor = ?.

        end.
        when "rcv" then do:
        run bg-col (11) .
        end.
        when "trn" then do:
        run bg-col (13) .
        end.

     end.
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
/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
/* зацикливание формы */
assign
  parnext-prev = yes

.
n-p:
do while parnext-prev :

MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

define variable loc#log as logical   no-undo .
/* Проверка прав на просмотр заказа */
  /*{ gbl/chk-actg.i
    g#db-num
    g#userid
    {&action-head-code-main}
    'actn_global-trn_lookup':U
    {&cntxt-global}
    0
    '':U
    0
    0
    0
    0
    true
    loc#log
  }
  if loc#log <> yes then do: return error. end.
  */
find first buf_ord-doc no-lock where recid(buf_ord-doc) = v-doc-rec no-error .
if error-status :error then message
  vss-workfile vss-revision vss-description skip
  error-status :get-message(1) skip
  return-value skip
  "Ошибка нет заказа с №"
  p-doc-code
  view-as alert-box error
.

p-doc-code = buf_ord-doc.doc-code .

 if not ( buf_ord-doc.doc-type = {&o-p} or
      buf_ord-doc.doc-type = {&p-o} or
      buf_ord-doc.doc-type = {&f-p} ) then do:
     message "Для заказов типа " buf_ord-doc.doc-type
            "Этот режим не работает"
            view-as alert-box information .
            parnext-prev = ? .
     return .
    end.
    RUN init-tt.
    RUN enable_UI.
    RUN init-proc.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
end. /* do while */
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE bg-col Dialog-Frame
PROCEDURE bg-col :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
define input  parameter p-color as integer   no-undo .
assign
  tt_ord-line.gds-code :bgcolor in browse {&browse-name} = p-color
  tt_ord-line.artic    :bgcolor in browse {&browse-name} = p-color
  buf_goods.gds-name   :bgcolor in browse {&browse-name} = p-color
  buf_goods.unit-base  :bgcolor in browse {&browse-name} = p-color
  tt_ord-line.qnty:bgcolor in browse {&browse-name} = p-color
  tt_ord-line.qnty-rcv:bgcolor in browse {&browse-name} = p-color
  tt_ord-line.qnty-trn:bgcolor in browse {&browse-name} = p-color

.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

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
  DISPLAY COMBO-status i-ord i-rcv i-trn v-status
      WITH FRAME Dialog-Frame.
  ENABLE B-exit B-quit B-rcv B-trn B-print B-Help B-prev B-next BROWSE-3 i-ord
         i-rcv i-trn v-status
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-widgets Dialog-Frame
PROCEDURE fill-widgets :
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-proc Dialog-Frame
PROCEDURE init-proc :
  buf_goods.gds-name  :resizable in browse {&browse-name} = true .
  tt_ord-line.artic   :resizable in browse {&browse-name} = true .
  tt_ord-line.qnty-rcv:resizable in browse {&browse-name} = true .
  buf_goods.gds-name  :width     in browse {&browse-name}   = v-size-col2 .
  tt_ord-line.artic   :width     in browse {&browse-name}   = v-size-col1 .
  tt_ord-line.qnty-rcv  :width     in browse {&browse-name}   = v-size-col3 .
  frame {&frame-name}:title = "Состояние заказа № " + buf_ord-doc.doc-code .
  if p-mode <> {&update} then do:
     B-exit:label in frame {&frame-name}  = "Вы&ход"  .
     hide B-quit in frame {&frame-name} .
  END.
 hide b-print  in frame {&frame-name} .
end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-tt Dialog-Frame
PROCEDURE init-tt :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
empty temp-table tt_ord-line.
empty temp-table tt_doc-line.
empty temp-table tt_ord-line-rcv.
vi-total-ord = 0.
vi-total-rcv = 0.
vi-total-trn = 0.

for each buf_ord-line no-lock where
         buf_ord-line.doc-code = buf_ord-doc.doc-code
         :
        find first buf_goods no-lock where
                  buf_goods.artic     = buf_ord-line.artic and
                  buf_goods.prod-type = buf_ord-line.prod-type and
                  buf_goods.prod-code = buf_ord-line.prod-code no-error .

         create  tt_ord-line.
         buffer-copy buf_ord-line to tt_ord-line
         assign
           tt_ord-line.type-str = "ord"
           tt_ord-line.gds-code = buf_goods.gds-code
         .
      v-total-rcv = 0 .

     /* по всем поставкам по заказу */
     for each  buf_ord-doc-rcv no-lock where
               buf_ord-doc-rcv.doc-code = buf_ord-line.doc-code :
          for each buf_ord-line-rcv no-lock where
                   buf_ord-line-rcv.doc-code = buf_ord-doc-rcv.doc-code and
                   buf_ord-line-rcv.rcv-code = buf_ord-doc-rcv.rcv-code and
                   buf_ord-line-rcv.artic    = buf_ord-line.artic and
                   buf_ord-line-rcv.prod-type= buf_ord-line.prod-type and
                   buf_ord-line-rcv.prod-code= buf_ord-line.prod-code :

                  create  tt_ord-line-rcv.
                  buffer-copy buf_ord-line-rcv to tt_ord-line-rcv
                   assign
                     tt_ord-line-rcv.gds-code = buf_goods.gds-code
                  .
                  v-total-rcv = v-total-rcv + buf_ord-line-rcv.qnty .
                  vi-total-rcv = vi-total-rcv + buf_ord-line-rcv.qnty .
          end.
     end.
      assign
        tt_ord-line.qnty-rcv = v-total-rcv
      .
      vi-total-ord = vi-total-ord + buf_ord-line.qnty .
end.

/* По поставкам не вошедшим в заказ*/
define buffer bufn_ord-line-rcv for ub.ord-line-rcv  .

for each bufn_ord-line-rcv no-lock where
         bufn_ord-line-rcv.doc-code = buf_ord-doc.doc-code
         :

        find first buf_goods no-lock where
                  buf_goods.artic     = bufn_ord-line-rcv.artic     and
                  buf_goods.prod-type = bufn_ord-line-rcv.prod-type and
                  buf_goods.prod-code = bufn_ord-line-rcv.prod-code
                  no-error .

         find first tt_ord-line where
                    tt_ord-line.artic     =  buf_goods.artic      and
                    tt_ord-line.prod-type =  buf_goods.prod-type  and
                    tt_ord-line.prod-code =  buf_goods.prod-code
                    no-error .

   if not available tt_ord-line then do:
         create  tt_ord-line.
         buffer-copy bufn_ord-line-rcv to tt_ord-line
         assign
           tt_ord-line.qnty = 0
           tt_ord-line.type-str = "rcv"
           tt_ord-line.gds-code = buf_goods.gds-code
         .
      v-total-rcv = 0 .

     /* по всем поставкам по заказу */
     for each  buf_ord-doc-rcv no-lock where
               buf_ord-doc-rcv.doc-code = buf_ord-doc.doc-code :
          for each buf_ord-line-rcv no-lock where
                   buf_ord-line-rcv.doc-code = buf_ord-doc-rcv.doc-code and
                   buf_ord-line-rcv.rcv-code = buf_ord-doc-rcv.rcv-code and
                   buf_ord-line-rcv.artic    = bufn_ord-line-rcv.artic and
                   buf_ord-line-rcv.prod-type= bufn_ord-line-rcv.prod-type and
                   buf_ord-line-rcv.prod-code= bufn_ord-line-rcv.prod-code :
                  create  tt_ord-line-rcv.
                  buffer-copy buf_ord-line-rcv to tt_ord-line-rcv
                   assign
                     tt_ord-line-rcv.gds-code = buf_goods.gds-code
                  .
                  v-total-rcv  = v-total-rcv  + buf_ord-line-rcv.qnty .
                  vi-total-rcv = vi-total-rcv + buf_ord-line-rcv.qnty .
          end.
     end.
      assign
        tt_ord-line.qnty-rcv = v-total-rcv
      .
end.
end.



/* по всем накладным по заказу */
for each buf_ord-doc-rcv no-lock where
         buf_ord-doc-rcv.doc-code = p-doc-code :
   for each ub.ord-chain no-lock where
            ub.ord-chain.doc-code = buf_ord-doc-rcv.rcv-code and
            ub.ord-chain.doc-type = 'rcv'                  and
            ub.ord-chain.rel-doc-type = 'trn'
            :
     for each buf_trn-doc no-lock where
              buf_trn-doc.doc-code = ub.ord-chain.rel-doc-code :
         for each buf_doc-line no-lock where
                  buf_doc-line.doc-code = buf_trn-doc.doc-code :
                  if not can-find ( first tt_doc-line where
                   tt_doc-line.doc-code = buf_doc-line.doc-code  and
                   tt_doc-line.artic    = buf_doc-line.artic and
                   tt_doc-line.prod-type= buf_doc-line.prod-type and
                   tt_doc-line.prod-code= buf_doc-line.prod-code ) then do:
                      create  tt_doc-line.
                      buffer-copy buf_doc-line to tt_doc-line.
                      vi-total-trn = vi-total-trn + buf_doc-line.fact-qnty .
                      find first tt_ord-line where
                                 tt_ord-line.doc-code  = p-doc-code and
                                 tt_ord-line.artic     = buf_doc-line.artic and
                                 tt_ord-line.prod-type = buf_doc-line.prod-type and
                                 tt_ord-line.prod-code = buf_doc-line.prod-code no-error .
                      if available tt_ord-line then do:
                         tt_ord-line.qnty-trn = tt_ord-line.qnty-trn + buf_doc-line.fact-qnty.
                      end.
                      else do:
                        find first buf_goods no-lock where
                                 buf_goods.artic     = buf_doc-line.artic and
                                 buf_goods.prod-type = buf_doc-line.prod-type and
                                 buf_goods.prod-code = buf_doc-line.prod-code no-error .

                        create  tt_ord-line.
                        buffer-copy buf_doc-line to tt_ord-line
                        assign
                          tt_ord-line.doc-code = p-doc-code
                          tt_ord-line.gds-code = buf_goods.gds-code
                          tt_ord-line.type-str = "trn"
                          tt_ord-line.qnty     = 0
                          tt_ord-line.qnty-trn = buf_doc-line.fact-qnty
                        .
                      end.
                   end.
         end.
     end.
     end.
end.
i-ord = vi-total-ord .
i-rcv = vi-total-rcv .
i-trn = vi-total-trn .
v-status = buf_ord-doc.status_ + string( buf_ord-doc.flag_,"+/-" ) .
if i-ord = i-rcv and
   i-rcv = i-trn then COMBO-status = 0 .
else COMBO-status = 3.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE save-proc Dialog-Frame
PROCEDURE save-proc :
define variable v-list-new as character no-undo .
assign

   v-list-new =  string(decimal( tt_ord-line.artic  :width in browse {&browse-name})) +  {&delim-par}
               + string(decimal( buf_goods.gds-name :width  in browse {&browse-name}))  +  {&delim-par}
               + string(decimal( tt_ord-line.qnty-rcv :width  in browse {&browse-name}))  +  {&delim-par} .

run uf-set in this-procedure(
    input  {&uf-ord-sost}
    ,input v-cntxt-userid
    ,input v-list-new
    ,input v-uf-Naim
    ,input v-uf-print-graft
    ,input v-uf-sort-gr
    ,input v-uf-type-price
    ,input v-uf-type-val
)  no-error   .


END PROCEDURE.

procedure step-next :
define buffer new_ord-doc for ub.ord-doc  .
if bf-handle = ? then return .
if valid-handle (br-handle) then do:
  varlog = br-handle:select-next-row().
  find first new_ord-doc no-lock where  recid( new_ord-doc ) = bf-handle:recid no-error .
  if not varlog then message "Это последний заказ списка.".
end.
assign
    v-doc-rec   = bf-handle:recid
    parnext-prev = true
     .
end procedure.

procedure step-prev :
define buffer new_ord-doc for ub.ord-doc  .
if bf-handle = ? then return .

if valid-handle (br-handle) then do:
  varlog = br-handle:select-prev-row().
  find first new_ord-doc no-lock where  recid( new_ord-doc ) = bf-handle:recid no-error .
  if not varlog then message "Это первый заказ списка.".
end.

assign
  v-doc-rec    = bf-handle:recid
  parnext-prev = true
.
end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME