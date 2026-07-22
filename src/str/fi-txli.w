&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame

/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER locked_c-fin-ob FOR c-fin-ob.
DEFINE BUFFER locked_fin-ob FOR fin-ob.
DEFINE TEMP-TABLE tt-fin-ob-tax NO-UNDO LIKE fin-ob-tax.
DEFINE TEMP-TABLE tt0-fin-ob-tax NO-UNDO LIKE fin-ob-tax.
DEFINE BUFFER X_clients-host FOR clients.
DEFINE BUFFER X_sysconf FOR sysconf.


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Налоги для финобязательств для записи истории по финоб

Автор: Чернова Светлана Александровна
Дата создания: 03/03/06
Author: Svetlana Chernova
Creation date: 03/03/06

Creation date: 12/03/03 10:37


*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT     PARAMETER parParentProc  AS WIDGET-HANDLE NO-UNDO.
/*текущая фирма*/
define input parameter p-curr-host-code like ub.sysconf.host-code no-undo.

define input parameter p-mode as character no-undo.
/*может быть {&add-def} {&update} {&lookup} ({&lookup} + {&delim-par} + "history")*/

define input parameter p-host-code like ub.fin-ob.host-code no-undo.
define input parameter p-doc-code like ub.fin-ob.doc-code no-undo.
define input parameter p-doc-type as character no-undo .
define input parameter p-sum-doc like ub.fin-ob.sum-doc no-undo .
define input parameter p-curr-code  like ub.fin-ob.curr-code no-undo .
define input parameter p-base-rate  like ub.fin-ob.base-rate no-undo .
define input parameter p-base-scale like ub.fin-ob.base-scale no-undo .
define input parameter p-exch-rate  like ub.fin-ob.exch-rate no-undo .
define input parameter p-exch-scale like ub.fin-ob.exch-scale no-undo .

define input-output parameter   p-slt-pc            like ub.fin-ob-tax.slt-pc             no-undo .
define input-output parameter   p-sum-line-doc      like ub.fin-ob-tax.sum-line-doc       no-undo .
define input-output parameter   p-sum-vat-line-doc  like ub.fin-ob-tax.sum-vat-line-doc   no-undo .
define input-output parameter   p-sum-slt-line-doc  like ub.fin-ob-tax.sum-slt-line-doc   no-undo .
define input-output parameter   p-vat-pc            like ub.fin-ob-tax.vat-pc             no-undo .
define input-output parameter   p-with-slt          like ub.fin-ob-tax.with-slt           no-undo .
define input-output parameter   p-with-vat          like ub.fin-ob-tax.with-vat           no-undo .

DEFINE INPUT PARAMETER TABLE FOR tt-fin-ob-tax .


define input parameter p-recid as recid no-undo .
define input parameter p-chip-num like ub.c-fin-ob.chip-num no-undo .
define output parameter p-res as logical no-undo .

/* Local Variable Definitions ---                                       */
def var vss-revision    as character no-undo init "$Revision$":U .
def var vss-author      as character no-undo init "$Author$":U .
def var vss-date        as character no-undo init "$Date$":U .
def var vss-workfile    as character no-undo init "$Workfile$":U .
def var vss-archive     as character no-undo init "$Archive$":U .
def var vss-description as character no-undo init "Налоги для финобязательства".
{ cmp/vssrevis.i }

define variable v-db-num like ub.db.db-num no-undo.
define variable v-base-code like ub.sysconf.host-code no-undo.
define variable v-add-chg as character no-undo.
define variable v-fin-vat-pc like ub.sysconf.fin-vat-pc no-undo.
define variable v-fin-slt-pc like ub.sysconf.fin-slt-pc no-undo.
define variable v-rest-sum-doc like ub.fin-ob-tax.sum-line-doc no-undo.
define variable last-line like ub.fin-ob-tax.line-num no-undo.
define variable v-change-tab-order as character no-undo .
define buffer X_curr_sysconf for ub.sysconf.
define buffer X_currency for ub.currency.
define buffer X_contract for ub.contract.
{ cmp/trg-def.i }
{ gbl/waitfram.i }
{ cmp/showinf.i }
define temp-table tt-fix no-undo
field line-num as integer
index pi is primary unique
line-num
.
&scop tab-order "b-add,b-chg,b-del," + v-change-tab-order + "b-quit,b-exit"
&scop change-tab-order "f-sum-doc,T-with-vat,T-vatpc,f-vat-pc,T-vatsum,f-sum-vat,T-with-slt,T-sltpc,f-slt-pc,T-sltsum,f-sum-slt"

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-Help B-exit b-quit f-sum-doc T-with-slt ~
f-slt-pc T-sltpc T-with-vat f-vat-pc T-vatpc F-curr-code
&Scoped-Define DISPLAYED-OBJECTS f-all-sum-doc f-sum-doc T-with-slt ~
f-slt-pc f-sum-slt T-sltpc T-sltsum T-with-vat f-vat-pc f-sum-vat T-vatpc ~
T-vatsum f-curr-abbr F-curr-code

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
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE f-all-sum-doc AS DECIMAL FORMAT "->,>>>,>>>,>>>,>>9.99" INITIAL 0
     LABEL "Сумма по документу"
     VIEW-AS FILL-IN
     SIZE 16 BY 1
     FGCOLOR 4 .

DEFINE VARIABLE f-curr-abbr AS CHARACTER FORMAT "X(3)":U
      VIEW-AS TEXT
     SIZE 4 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE F-curr-code AS INTEGER FORMAT ">9" INITIAL 0
     LABEL "Валюта"
      VIEW-AS TEXT
     SIZE 4 BY .67.

DEFINE VARIABLE f-slt-pc AS DECIMAL FORMAT ">9.99":U INITIAL 0
     LABEL " %НП"
     VIEW-AS FILL-IN
     SIZE 6.63 BY 1 NO-UNDO.

DEFINE VARIABLE f-sum-doc AS DECIMAL FORMAT "->,>>>,>>>,>>>,>>9.99" INITIAL 0
     LABEL "Сумма (налоги в т.ч.)"
     VIEW-AS FILL-IN
     SIZE 16 BY 1
     FGCOLOR 4 .

DEFINE VARIABLE f-sum-slt AS DECIMAL FORMAT "->,>>>,>>>,>>>,>>9.99":U INITIAL 0
     LABEL "Сумма  НП"
     VIEW-AS FILL-IN
     SIZE 22.88 BY 1.04
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE f-sum-vat AS DECIMAL FORMAT "->,>>>,>>>,>>>,>>9.99":U INITIAL 0
     LABEL "Сумма НДС"
     VIEW-AS FILL-IN
     SIZE 22.88 BY 1.04
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE f-vat-pc AS DECIMAL FORMAT ">9.99":U INITIAL 0
     LABEL "%НДС"
     VIEW-AS FILL-IN
     SIZE 6.63 BY 1 NO-UNDO.

DEFINE VARIABLE T-sltpc AS LOGICAL INITIAL yes
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2 BY 1 NO-UNDO.

DEFINE VARIABLE T-sltsum AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2 BY 1 NO-UNDO.

DEFINE VARIABLE T-vatpc AS LOGICAL INITIAL yes
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2 BY 1 NO-UNDO.

DEFINE VARIABLE T-vatsum AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2 BY 1 NO-UNDO.

DEFINE VARIABLE T-with-slt AS LOGICAL INITIAL yes
     LABEL "С  НП"
     VIEW-AS TOGGLE-BOX
     SIZE 10.38 BY 1 NO-UNDO.

DEFINE VARIABLE T-with-vat AS LOGICAL INITIAL yes
     LABEL "С НДС"
     VIEW-AS TOGGLE-BOX
     SIZE 10.38 BY 1 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-Help AT ROW 1 COL 89
     B-exit AT ROW 1.04 COL 1
     b-quit AT ROW 1.04 COL 11
     f-all-sum-doc AT ROW 2.88 COL 23.25 COLON-ALIGNED
     f-sum-doc AT ROW 4.08 COL 23.63 COLON-ALIGNED
     T-with-slt AT ROW 5.54 COL 25.38
     f-slt-pc AT ROW 5.54 COL 45 COLON-ALIGNED
     f-sum-slt AT ROW 5.54 COL 73.63 COLON-ALIGNED
     T-sltpc AT ROW 5.58 COL 38.75
     T-sltsum AT ROW 5.58 COL 62.5
     T-with-vat AT ROW 6.79 COL 25.38
     f-vat-pc AT ROW 6.79 COL 45 COLON-ALIGNED
     f-sum-vat AT ROW 6.79 COL 73.63 COLON-ALIGNED
     T-vatpc AT ROW 6.83 COL 38.75
     T-vatsum AT ROW 6.83 COL 62.5
     f-curr-abbr AT ROW 2.92 COL 54.63 COLON-ALIGNED NO-LABEL
     F-curr-code AT ROW 2.96 COL 49.5 COLON-ALIGNED
     SPACE(43.74) SKIP(5.69)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Налоги"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: locked_c-fin-ob B "?" ? ub c-fin-ob
      TABLE: locked_fin-ob B "?" ? ub fin-ob
      TABLE: tt-fin-ob-tax T "?" NO-UNDO ub fin-ob-tax
      TABLE: tt0-fin-ob-tax T "?" NO-UNDO ub fin-ob-tax
      TABLE: X_clients-host B "?" ? ub clients
      TABLE: X_sysconf B "?" ? ub sysconf
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS


/* ***************  Runtime Attributes and UIB Settings  ************** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
                                                                        */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN f-all-sum-doc IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN f-curr-abbr IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN f-sum-slt IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN f-sum-vat IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR TOGGLE-BOX T-sltsum IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR TOGGLE-BOX T-vatsum IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _Options          = "SHARE-LOCK KEEP-EMPTY"
     _Query            is NOT OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME






/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Налоги */
DO:
  run check-sums in this-procedure no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Налоги */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-exit Dialog-Frame
ON CHOOSE OF B-exit IN FRAME Dialog-Frame /* Ввод */
DO:
  assign frame {&frame-name}
  T-with-slt
  T-with-vat
  .

  if f-slt-pc:sensitive then  assign frame {&frame-name}     f-slt-pc.
  if f-vat-pc:sensitive then  assign frame {&frame-name}     f-vat-pc.
  if f-sum-vat:sensitive then  assign frame {&frame-name}    f-sum-vat.
  if f-sum-slt:sensitive then  assign frame {&frame-name}    f-sum-slt.

assign
  p-res = true
  p-slt-pc              = f-slt-pc
  p-sum-line-doc        = f-sum-doc
  p-sum-vat-line-doc    = f-sum-vat
  p-sum-slt-line-doc    = f-sum-slt
  p-vat-pc              = f-vat-pc
  p-with-slt            = T-with-slt
  p-with-vat            =  T-with-vat
.

apply "window-close" to self.
return .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-quit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-quit Dialog-Frame
ON CHOOSE OF b-quit IN FRAME Dialog-Frame /* Отказ */
DO:
 p-res = false  .
/* отказ */

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-slt-pc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-slt-pc Dialog-Frame
ON LEAVE OF f-slt-pc IN FRAME Dialog-Frame /*  %НП */
DO:
  assign
  f-slt-pc.
  run recalc-sums in this-procedure("slt-pc":U).
  run recalc-sums in this-procedure("sum-doc":U).

END.

ON return OF f-slt-pc IN FRAME Dialog-Frame
DO:
  run next-focus in this-procedure  (input  {&SELF-NAME}:handle ) .
  return no-apply .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-sum-doc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-sum-doc Dialog-Frame
ON LEAVE OF f-sum-doc IN FRAME Dialog-Frame /* Сумма (налоги в т.ч.) */
DO:
 /*
  message f-sum-doc
  skip    f-sum-doc:modified .
  */
  if f-sum-doc:modified = true then do:
      assign
        f-sum-doc
      .

      if abs(p-sum-doc) < abs(f-sum-doc) then do:
          message "Сумма налогов в том числе больше чем общая сумма документа" p-sum-doc .
          return no-apply.
      end.
  end.
  run recalc-sums in this-procedure("sum-doc":U).
END.

ON return OF f-sum-doc IN FRAME Dialog-Frame
DO:
  run next-focus in this-procedure  (input  {&SELF-NAME}:handle ) .
  return no-apply .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-sum-slt
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-sum-slt Dialog-Frame
ON LEAVE OF f-sum-slt IN FRAME Dialog-Frame /* Сумма  НП */
DO:
    assign
  f-sum-slt.
  run recalc-sums in this-procedure("sum-slt":U).
  run recalc-sums in this-procedure("sum-doc":U).


END.

ON return OF f-sum-slt IN FRAME Dialog-Frame
DO:
  run next-focus in this-procedure  (input  {&SELF-NAME}:handle ) .
  return no-apply .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-sum-vat
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-sum-vat Dialog-Frame
ON LEAVE OF f-sum-vat IN FRAME Dialog-Frame /* Сумма НДС */
DO:
  assign
  f-sum-vat.
  run recalc-sums in this-procedure("sum-vat":U).
    run recalc-sums in this-procedure("sum-doc":U).

END.

ON return OF f-sum-vat IN FRAME Dialog-Frame
DO:
  run next-focus in this-procedure  (input  {&SELF-NAME}:handle ) .
  return no-apply .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-vat-pc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-vat-pc Dialog-Frame
ON LEAVE OF f-vat-pc IN FRAME Dialog-Frame /* %НДС */
DO:
    assign
  f-vat-pc.
  run recalc-sums in this-procedure("vat-pc":U).
  run recalc-sums in this-procedure("sum-doc":U).


END.

ON return OF f-vat-pc IN FRAME Dialog-Frame
DO:
  run next-focus in this-procedure  (input  {&SELF-NAME}:handle ) .
  return no-apply .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME T-sltpc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL T-sltpc Dialog-Frame
ON VALUE-CHANGED OF T-sltpc IN FRAME Dialog-Frame
DO:
    { gbl/stdbtn.i }
  assign
  t-sltpc.
  run disable-enable in this-procedure("slt-pc":U).


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME T-sltsum
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL T-sltsum Dialog-Frame
ON VALUE-CHANGED OF T-sltsum IN FRAME Dialog-Frame
DO:
    { gbl/stdbtn.i }
  assign
  t-sltsum.
  run disable-enable in this-procedure("slt-sum":U).


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME T-vatpc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL T-vatpc Dialog-Frame
ON VALUE-CHANGED OF T-vatpc IN FRAME Dialog-Frame
DO:
  { gbl/stdbtn.i }
  assign
  t-vatpc.
  run disable-enable in this-procedure("vat-pc":U).

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME T-vatsum
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL T-vatsum Dialog-Frame
ON VALUE-CHANGED OF T-vatsum IN FRAME Dialog-Frame
DO:
    { gbl/stdbtn.i }
  assign
  t-vatsum.
  run disable-enable in this-procedure("vat-sum":U).


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME T-with-slt
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL T-with-slt Dialog-Frame
ON VALUE-CHANGED OF T-with-slt IN FRAME Dialog-Frame /* С  НП */
DO:
  assign
  t-with-slt.
  run with-without in this-procedure ("slt":U, t-with-slt).
  run recalc-sums in this-procedure("sum-doc":U).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME T-with-vat
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL T-with-vat Dialog-Frame
ON VALUE-CHANGED OF T-with-vat IN FRAME Dialog-Frame /* С НДС */
DO:
  assign
  t-with-vat.
  run with-without in this-procedure ("vat":U, t-with-vat).
    run recalc-sums in this-procedure("sum-doc":U).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */
{ gbl/app_help.i }


/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  if p-mode <> {&update}
  and p-mode <> {&lookup}
  and p-mode <> {&add-def}
  and p-mode <> ({&lookup} + {&delim-par} + "history":U)
  then do:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметров вызова p-mode"  p-mode
    view-as alert-box ERROR.
    undo, return error.
  end.

  /* Значения из фирмы НДС И НМП  */
  { gbl/curdbnum.i v-db-num }
  { gbl/basecode.i p-host-code v-base-code }
    find first X_curr_sysconf no-lock where
                    X_curr_sysconf.host-code = p-curr-host-code.
    find first X_sysconf no-lock where
                  X_sysconf.host-code = p-host-code.
   assign
    v-fin-vat-pc = X_sysconf.fin-vat-pc
    v-fin-slt-pc = X_sysconf.fin-slt-pc
    .

    find first X_clients-host no-lock where
              X_clients-host.obj-type = {&cmp}
          AND X_clients-host.obj-code = p-host-code.

  if p-doc-type = {&expense} then do:
      if LOOKUP({&lookup} , p-mode, {&delim-par}) = 0
        then do:
        if X_curr_sysconf.host-code <> p-host-code
        or (v-db-num <> X_sysconf.firm-db-num)
        then do:
          message
          vss-workfile vss-revision vss-description skip
          "Неверное значение параметров вызова p-mode и/или p-host-code и/или p-curr-host-code" p-mode p-host-code  p-curr-host-code skip
          X_sysconf.firm-db-num
          v-db-num
          view-as alert-box ERROR.
          undo, return error.
        end.
      end.
  end.
  if p-mode = ({&lookup} + {&delim-par} + "history":U)

  then do:
  end.
  else do:
    run get-rest-sum in this-procedure(output v-rest-sum-doc).
    run proc-b-add-chg in this-procedure ( p-mode) .

  end.

  find first X_currency no-lock where
               X_currency.curr-code = p-curr-code.


  run myenable.

  WAIT-FOR GO OF FRAME {&FRAME-NAME} FOCUS f-sum-doc.
END.
run disable_ui.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE check-sums Dialog-Frame
PROCEDURE check-sums :
/**/
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable-enable Dialog-Frame
PROCEDURE disable-enable :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-main-widget as character no-undo.
/*сначала все позадизайблим*/
CASE p-main-widget:
  when "vat-sum" then do:
    assign
        T-vatpc = no.
        enable
          t-vatpc
          f-sum-vat
          with frame {&frame-name}.
        disable
          t-vatsum
          f-vat-pc
          with frame {&frame-name}.
  end.
    when "slt-sum" then do:
      assign
        T-sltpc = no.
        enable
          t-sltpc
          f-sum-slt
          with frame {&frame-name}.

        disable
            t-sltsum
            f-slt-pc
            with frame {&frame-name}.

  end.
  when "vat-pc" then do:
    assign
        T-vatsum = no.
        enable
          t-vatsum
          f-vat-pc
          with frame {&frame-name}.
        disable
        t-vatpc
        f-sum-vat
        with frame {&frame-name}.
  end.
  when "slt-pc" then do:
        assign
        T-sltsum = no.
        enable
        t-sltsum
        f-slt-pc
        with frame {&frame-name}.

        disable
        t-sltpc
        f-sum-slt
        with frame {&frame-name}.
  end.

END CASE.
display
T-sltpc
T-sltsum
T-vatpc
T-vatsum
with frame {&frame-name}.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI Dialog-Frame _DEFAULT-DISABLE
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


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI Dialog-Frame _DEFAULT-ENABLE
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
  DISPLAY f-all-sum-doc f-sum-doc T-with-slt f-slt-pc f-sum-slt T-sltpc T-sltsum
          T-with-vat f-vat-pc f-sum-vat T-vatpc T-vatsum f-curr-abbr F-curr-code
      WITH FRAME Dialog-Frame.
  ENABLE B-Help B-exit b-quit f-sum-doc T-with-slt f-slt-pc T-sltpc T-with-vat
         f-vat-pc T-vatpc F-curr-code
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-tables Dialog-Frame
PROCEDURE fill-tables :
define buffer buf_fin-ob-tax for ub.fin-ob-tax.
define buffer buf_c-fin-ob-tax for ub.c-fin-ob-tax.
define buffer buf_tt-fin-ob-tax for tt-fin-ob-tax.
do on error undo, return error:
  if p-mode = {&lookup} + {&delim-par} + "History":U then do:
  end.
  else do:

  end.

  run get-rest-sum in this-procedure ( output v-rest-sum-doc).
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-rest-sum Dialog-Frame
PROCEDURE get-rest-sum :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define output parameter p-rest-sum like ub.fin-ob-tax.sum-line-doc no-undo.
define buffer buf_tt-fin-ob-tax for tt-fin-ob-tax.
for each buf_tt-fin-ob-tax  where  recid(buf_tt-fin-ob-tax) <> p-recid :
    assign
    p-rest-sum = p-rest-sum + buf_tt-fin-ob-tax.sum-line-doc
    .
end.
assign
p-rest-sum = p-sum-doc - p-rest-sum
.
if p-rest-sum < 0 then do : p-rest-sum = 0.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Myenable Dialog-Frame
PROCEDURE Myenable :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
assign
frame {&frame-name}:title = frame {&frame-name}:title + " фирма " + x_clients-host.obj-name + "  - " + caps(p-mode)
b-quit:label = (if lookup({&lookup}, p-mode, {&delim-par}) > 0 then "&Выход" else b-quit:label)
t-with-slt = yes
t-with-vat = yes
t-sltpc = yes
t-vatpc = yes
t-sltsum = no
t-vatsum = no
.
DISPLAY
p-sum-doc @ f-all-sum-doc
p-curr-code @ f-curr-code
X_currency.curr-abbr @ f-curr-abbr
WITH FRAME Dialog-Frame.

ENABLE
b-quit
B-exit when lookup({&lookup}, p-mode, {&delim-par}) = 0
B-Help
WITH FRAME Dialog-Frame.
if lookup({&lookup}, p-mode, {&delim-par}) > 0 then do:
  hide
  b-exit
  in frame {&frame-name} .
end.
VIEW FRAME Dialog-Frame.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE next-focus Dialog-Frame
PROCEDURE next-focus :
do
 on error undo, return error return-value
 :

  define input parameter p-widget-handle as handle no-undo .
  define variable l-apply-entry as logical no-undo .

  assign
    l-apply-entry = /* false */  true
  .

     do with frame {&frame-name} :
          if  f-sum-doc          :handle = p-widget-handle then do:
              if f-slt-pc  :sensitive then do: apply "entry":u to f-slt-pc  .  return . end.
              if f-sum-slt :sensitive then do: apply "entry":u to f-sum-slt .  return . end.
              if f-vat-pc  :sensitive then do: apply "entry":u to f-vat-pc  .  return . end.
              if f-sum-vat :sensitive then do: apply "entry":u to f-sum-vat .  return . end.
              if B-exit    :sensitive then do: apply "entry":u to B-exit    .  return . end.
          end.
          if  f-slt-pc           :handle = p-widget-handle then do:
            if f-sum-slt :sensitive then do: apply "entry":u to f-sum-slt .  return . end.
            if f-vat-pc  :sensitive then do: apply "entry":u to f-vat-pc  .  return . end.
            if f-sum-vat :sensitive then do: apply "entry":u to f-sum-vat .  return . end.
            if B-exit    :sensitive then do: apply "entry":u to B-exit    .  return . end.
          end.
          if  f-sum-slt          :handle = p-widget-handle then do:
              if f-vat-pc  :sensitive then do: apply "entry":u to f-vat-pc  .  return . end.
              if f-sum-vat :sensitive then do: apply "entry":u to f-sum-vat .  return . end.
              if B-exit    :sensitive then do: apply "entry":u to B-exit    .  return . end.
          end.
          if  f-vat-pc           :handle = p-widget-handle then do:
              if f-sum-vat :sensitive then do: apply "entry":u to f-sum-vat .  return . end.
              if B-exit    :sensitive then do: apply "entry":u to B-exit    .  return . end.
          end.
          if  f-sum-vat          :handle = p-widget-handle then do:
              if B-exit    :sensitive then do: apply "entry":u to B-exit    .  return . end.
          end.
    end. /* do with frame */
  end.  /* do */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-add-chg Dialog-Frame
PROCEDURE proc-b-add-chg :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-mode as character no-undo.
if p-mode = {&update} then do:
    assign
    f-slt-pc     =  p-slt-pc
    f-sum-doc    =  p-sum-line-doc
    f-sum-vat    =  p-sum-vat-line-doc
    f-sum-slt    =  p-sum-slt-line-doc
    f-vat-pc     =  p-vat-pc
    T-with-slt   =  p-with-slt
    T-with-vat   =  p-with-vat
    .
end.

if p-mode = {&add-def} then do:
    assign
    f-vat-pc     = v-fin-vat-pc
    f-slt-pc     = v-fin-slt-pc
    f-sum-doc    = v-rest-sum-doc
    T-with-slt   = yes
    T-with-vat   = yes
    f-sum-slt    = f-sum-doc * f-slt-pc / ( 100 + f-slt-pc)
    f-sum-vat    = (f-sum-doc -  f-sum-slt ) * f-vat-pc / ( 100 + f-vat-pc)
    .

end.


display
f-slt-pc
f-sum-doc
f-sum-vat
f-sum-slt
f-vat-pc
T-sltpc
T-sltsum
T-vatpc
T-vatsum
T-with-slt
T-with-vat
with frame {&frame-name}.
disable
b-exit
t-sltpc
t-vatpc
with frame {&frame-name}.
enable
f-sum-doc
f-vat-pc   when T-with-vat = true
f-slt-pc   when T-with-slt = true
T-sltsum   when T-with-slt = true
T-vatsum   when T-with-vat = true
T-with-slt
T-with-vat
with frame {&frame-name}.

APPLY "ENTRY" to f-sum-doc.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE recalc-sums Dialog-Frame
PROCEDURE recalc-sums :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-main-widget as character no-undo.
define variable v-line-num like ub.fin-ob-tax.line-num no-undo.
define buffer buf_tt-fin-ob-tax for tt-fin-ob-tax.
case v-add-chg:
  when {&update} then do:
    assign
    v-line-num = tt-fin-ob-tax.line-num
    .
  end.
  when {&add-def} then do:
    assign
    v-line-num = last-line
    .
  end.
 END CASE.
CASE p-main-widget :
    when "sum-doc":U then do:
      assign
      f-sum-slt = f-sum-doc * f-slt-pc / ( 100 + f-slt-pc)
      f-sum-vat =  (f-sum-doc - f-sum-slt ) * f-vat-pc / ( 100 + f-vat-pc)
      .
    end.
    when "slt-pc":U then do:
      assign
      f-sum-slt = f-sum-doc * f-slt-pc / ( 100 + f-slt-pc)
      .
    end.
    when "vat-pc":U then do:
      assign
      f-sum-vat =  (f-sum-doc - f-sum-slt ) * f-vat-pc / ( 100 + f-vat-pc)
      .
    end.
    when "sum-slt":U then do:
      assign
      f-slt-pc = f-sum-slt / (f-sum-doc - f-sum-slt ) * 100
      f-sum-vat =  (f-sum-doc - f-sum-slt ) * f-vat-pc / (100 + f-vat-pc )
      .
    end.
    when "sum-vat":U then do:
      assign
      f-vat-pc = f-sum-vat / (f-sum-doc - f-sum-slt - f-sum-vat ) * 100
      .
    end.
END CASE.
if abs( f-sum-vat + f-sum-slt) >= abs( f-sum-doc)  then do:
  message
  "Сумма налогов больше налогооблагаемой суммы + налоги!"
  view-as alert-box error .
  return error.
end.

display
f-slt-pc
f-sum-doc
f-sum-vat
f-sum-slt
f-vat-pc
with frame {&frame-name}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE with-without Dialog-Frame
PROCEDURE with-without :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-widget as character no-undo.
define input parameter p-on as logical no-undo.
CASE p-widget:
  when "slt":U then do:
    CASE p-on:
      when yes then do:
        assign
          f-slt-pc     = v-fin-slt-pc
          T-with-slt   = yes
          f-sum-slt    = f-sum-doc * f-slt-pc / 100
          T-sltsum = false
          t-sltpc  = true
        .
        display
          f-slt-pc
          f-sum-slt
          t-with-slt
          T-sltsum
          t-sltpc
        with frame {&frame-name}.

        enable
          f-slt-pc
          T-sltsum
        with frame {&frame-name}.
        disable
          f-sum-slt
          t-sltpc
        with frame {&frame-name}.
      end.

      when no then do:
        assign
        f-slt-pc = 0
        .
        display
        f-slt-pc
        with frame {&frame-name}.
        apply "LEAVE" to f-slt-pc.
        disable
        f-slt-pc
        f-sum-slt
        T-sltpc
        T-sltsum
        with frame {&frame-name}.
      end.
    END CASE.
  end.
  when "vat":U then do:
    CASE p-on:
      when yes then do:
        assign
        f-vat-pc     = v-fin-vat-pc
        T-with-vat   = yes
        f-sum-vat    = (f-sum-doc - f-sum-slt) * f-vat-pc / 100
        T-vatsum = false
        t-vatpc  = true

        .
        display
        f-vat-pc
        f-sum-vat
        t-with-vat
        T-vatsum
        t-vatpc
        with frame {&frame-name}.
        enable
        f-vat-pc
        T-vatsum
        with frame {&frame-name}.
        disable
        f-sum-vat
        t-vatpc
        with frame {&frame-name}.
      end.
      when no then do:
        assign
        f-vat-pc = 0
        .
        display
        f-vat-pc
        with frame {&frame-name}.
        apply "LEAVE" to f-vat-pc.
        disable
        f-vat-pc
        f-sum-vat
        T-vatpc
        T-vatsum
        with frame {&frame-name}.
      end.
    END CASE.
  end.
END CASE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME