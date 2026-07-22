&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE tt_add-line NO-UNDO LIKE add-line
       field sum-cli as decimal
       field vat-cli as decimal
       .
DEFINE BUFFER X_add-line FOR add-line.
DEFINE BUFFER X_contract FOR contract.
DEFINE BUFFER X_gds-add-charges FOR gds-add-charges.
DEFINE BUFFER X_goods FOR goods.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Строка дополнительных расходов в ПН

Автор: Чернова Светлана Александровна
Дата создания: 11/01/07
Author: Svetlana Chernova
Creation date: 11/01/07


*/
define input  parameter parParentProc as handle no-undo .
define input  parameter p-upper-h     as handle no-undo .
define input  parameter p-mode        as character no-undo .
define input  parameter p-doc-code    as character no-undo .
define input  parameter p-gds-code    as integer   no-undo .
define input-output parameter p-recid as recid no-undo .
define output parameter p-mode-exit   as character no-undo .


define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Строка дополнительных расходов в ПН".
{ cmp/vssrevis.i }

/*------------------------------------------------------------------------*/
/*          This .W file was created with the Progress AppBuilder.       */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */


/* Local Variable Definitions ---                                       */
{ cmp/str-glbl.i }
{ cmp/showinf.i  }
{ cmp/library.i  }
{ str/lib-trn.i  }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
{ gbl/waitfram.i }
{ str/adddocfn.i }
{ gbl/lineattr.i }

define buffer buf_add-line for ub.add-line  .
define variable ref-rec as recid no-undo.
define variable  exch-date as date no-undo.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES TT_add-line X_goods X_gds-add-charges

/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define FIELDS-IN-QUERY-Dialog-Frame tt_add-line.cli-code ~
tt_add-line.cli-type tt_add-line.contract-code tt_add-line.vat-pc ~
X_goods.gds-name tt_add-line.gds-code X_gds-add-charges.algoritm ~
tt_add-line.host-code tt_add-line.sum-base tt_add-line.sum-rubl ~
tt_add-line.vat-base tt_add-line.vat-rubl
&Scoped-define ENABLED-FIELDS-IN-QUERY-Dialog-Frame tt_add-line.cli-code ~
tt_add-line.cli-type tt_add-line.contract-code tt_add-line.vat-pc ~
tt_add-line.host-code tt_add-line.sum-rubl
&Scoped-define ENABLED-TABLES-IN-QUERY-Dialog-Frame tt_add-line
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-Dialog-Frame tt_add-line
&Scoped-define QUERY-STRING-Dialog-Frame FOR EACH TT_add-line SHARE-LOCK, ~
      EACH X_goods WHERE X_goods.gds-code = TT_add-line.gds-code SHARE-LOCK, ~
      EACH X_gds-add-charges WHERE X_gds-add-charges.gds-code = TT_add-line.gds-code SHARE-LOCK
&Scoped-define OPEN-QUERY-Dialog-Frame OPEN QUERY Dialog-Frame FOR EACH TT_add-line SHARE-LOCK, ~
      EACH X_goods WHERE X_goods.gds-code = TT_add-line.gds-code SHARE-LOCK, ~
      EACH X_gds-add-charges WHERE X_gds-add-charges.gds-code = TT_add-line.gds-code SHARE-LOCK.
&Scoped-define TABLES-IN-QUERY-Dialog-Frame TT_add-line X_goods ~
X_gds-add-charges
&Scoped-define FIRST-TABLE-IN-QUERY-Dialog-Frame TT_add-line
&Scoped-define SECOND-TABLE-IN-QUERY-Dialog-Frame X_goods
&Scoped-define THIRD-TABLE-IN-QUERY-Dialog-Frame X_gds-add-charges


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS tt_add-line.cli-code tt_add-line.cli-type ~
tt_add-line.contract-code tt_add-line.vat-pc tt_add-line.host-code ~
tt_add-line.sum-rubl
&Scoped-define ENABLED-TABLES tt_add-line
&Scoped-define FIRST-ENABLED-TABLE tt_add-line
&Scoped-Define ENABLED-OBJECTS B-exit B-quit B-quit-cycle B-History B-Help ~
B-cli r-cli B-contract r-contract exch-code exch-rate exch-scale sum-cli
&Scoped-Define DISPLAYED-FIELDS tt_add-line.cli-code tt_add-line.cli-type ~
tt_add-line.contract-code tt_add-line.vat-pc X_goods.gds-name ~
tt_add-line.gds-code X_gds-add-charges.algoritm tt_add-line.host-code ~
tt_add-line.sum-base tt_add-line.sum-rubl tt_add-line.vat-base ~
tt_add-line.vat-rubl
&Scoped-define DISPLAYED-TABLES tt_add-line X_goods X_gds-add-charges
&Scoped-define FIRST-DISPLAYED-TABLE tt_add-line
&Scoped-define SECOND-DISPLAYED-TABLE X_goods
&Scoped-define THIRD-DISPLAYED-TABLE X_gds-add-charges
&Scoped-Define DISPLAYED-OBJECTS exch-code exch-rate exch-scale sum-cli ~
scr-cli-name scr-contract-name

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-cli
     IMAGE-UP FILE "cmp/btn-fnd.bmp":U
     IMAGE-DOWN FILE "cmp/btn-fnd.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/btn-fnd.bmp":U NO-CONVERT-3D-COLORS
     LABEL ""
     SIZE 3.5 BY 1.13 TOOLTIP "Посмотреть Поставщика".

DEFINE BUTTON B-contract
     IMAGE-UP FILE "cmp/btn-fnd.bmp":U
     IMAGE-DOWN FILE "cmp/btn-fnd.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/btn-fnd.bmp":U NO-CONVERT-3D-COLORS
     LABEL ""
     SIZE 3.5 BY 1.13 TOOLTIP "Посмотреть Договор".

DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-Help
     LABEL "&Help"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-History
     LABEL "&История"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-quit-cycle AUTO-END-KEY
     LABEL "&Стоп-цикл"
     SIZE 11.5 BY 1
     BGCOLOR 8 .

DEFINE BUTTON r-cli
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY .88.

DEFINE BUTTON r-contract
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY .88.

DEFINE BUTTON r-currency
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.

DEFINE VARIABLE exch-code AS INTEGER FORMAT ">>9":U INITIAL 0
     LABEL "Валюта"
     VIEW-AS FILL-IN
     SIZE 4 BY 1 NO-UNDO.

DEFINE VARIABLE exch-rate AS DECIMAL FORMAT "->>,>>9.9999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 10 BY 1 NO-UNDO.

DEFINE VARIABLE exch-scale AS INTEGER FORMAT "->,>>>,>>9":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 3.5 BY 1 NO-UNDO.

DEFINE VARIABLE scr-cli-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 52.13 BY .67
     FGCOLOR 0  NO-UNDO.

DEFINE VARIABLE scr-contract-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 50.5 BY .67 NO-UNDO.

DEFINE VARIABLE scr-curr-abbr AS CHARACTER FORMAT "X(3)":U
      VIEW-AS TEXT
     SIZE 4 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE sum-cli AS DECIMAL FORMAT ">,>>>,>>>,>>9.99":U INITIAL 0
     LABEL "Сумма (в док.)"
     VIEW-AS FILL-IN
     SIZE 24.5 BY 1
     FGCOLOR 4  NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY Dialog-Frame FOR
      TT_add-line,
      X_goods,
      X_gds-add-charges SCROLLING.
&ANALYZE-RESUME

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     B-quit AT ROW 1 COL 11
     B-quit-cycle AT ROW 1 COL 21 WIDGET-ID 4
     B-History AT ROW 1 COL 93.5 WIDGET-ID 2
     B-Help AT ROW 1 COL 96.5
     tt_add-line.cli-code AT ROW 5.54 COL 20 COLON-ALIGNED WIDGET-ID 8
          LABEL "Поставшик услуги"
          VIEW-AS FILL-IN NATIVE
          SIZE 10 BY 1
     tt_add-line.cli-type AT ROW 5.54 COL 31.13 COLON-ALIGNED NO-LABEL WIDGET-ID 74 FORMAT "X(3)"
          VIEW-AS COMBO-BOX INNER-LINES 2
          LIST-ITEMS "орг,чел"
          DROP-DOWN-LIST
          SIZE 5.88 BY 1
     B-cli AT ROW 5.54 COL 41.88 WIDGET-ID 62
     r-cli AT ROW 5.58 COL 39.13 WIDGET-ID 56
     B-contract AT ROW 7.5 COL 40.13 WIDGET-ID 60
     tt_add-line.contract-code AT ROW 7.54 COL 20 COLON-ALIGNED WIDGET-ID 12
          LABEL "Договор" FORMAT ">>>>>>>>>>9"
          VIEW-AS FILL-IN NATIVE
          SIZE 14 BY 1
     r-contract AT ROW 7.54 COL 37.38 WIDGET-ID 58
     exch-code AT ROW 8.75 COL 20 COLON-ALIGNED WIDGET-ID 80
     r-currency AT ROW 8.75 COL 26.38 WIDGET-ID 52
     exch-rate AT ROW 8.75 COL 31.88 COLON-ALIGNED NO-LABEL WIDGET-ID 82
     exch-scale AT ROW 8.75 COL 42.25 COLON-ALIGNED NO-LABEL WIDGET-ID 84
     tt_add-line.vat-pc AT ROW 10.17 COL 20 COLON-ALIGNED WIDGET-ID 24
          VIEW-AS FILL-IN
          SIZE 11 BY 1
     sum-cli AT ROW 11.67 COL 20 COLON-ALIGNED WIDGET-ID 76
     X_goods.gds-name AT ROW 2.83 COL 30.5 COLON-ALIGNED NO-LABEL WIDGET-ID 64
           VIEW-AS TEXT
          SIZE 64.5 BY 1
          BGCOLOR 3 FGCOLOR 15
     tt_add-line.gds-code AT ROW 3 COL 20.13 COLON-ALIGNED WIDGET-ID 14
          LABEL "Код доп.расхода"
           VIEW-AS TEXT
          SIZE 10 BY .67
     X_gds-add-charges.algoritm AT ROW 4.25 COL 46 COLON-ALIGNED WIDGET-ID 66
          LABEL "Алгоритм включения в цену пропорционально" FORMAT "x(40)"
           VIEW-AS TEXT
          SIZE 40 BY .67
          FGCOLOR 4
     scr-cli-name AT ROW 5.71 COL 43.38 COLON-ALIGNED NO-LABEL WIDGET-ID 70
     tt_add-line.host-code AT ROW 6.71 COL 31 COLON-ALIGNED WIDGET-ID 16
          LABEL "Фирма" FORMAT ">>>>9"
           VIEW-AS TEXT
          SIZE 6 BY .67
     scr-contract-name AT ROW 7.71 COL 41.63 COLON-ALIGNED NO-LABEL WIDGET-ID 72
     scr-curr-abbr AT ROW 8.75 COL 27.5 COLON-ALIGNED NO-LABEL WIDGET-ID 78
     tt_add-line.sum-base AT ROW 13.17 COL 20 COLON-ALIGNED WIDGET-ID 18
           VIEW-AS TEXT
          SIZE 16 BY .67
     tt_add-line.sum-rubl AT ROW 14.04 COL 20 COLON-ALIGNED WIDGET-ID 20
          LABEL "Сумма rubl"
           VIEW-AS TEXT
          SIZE 16 BY .67
     tt_add-line.vat-base AT ROW 16.13 COL 20 COLON-ALIGNED WIDGET-ID 22
          LABEL "НДС (баз.вал.)"
           VIEW-AS TEXT
          SIZE 22 BY .67
     tt_add-line.vat-rubl AT ROW 17.13 COL 20 COLON-ALIGNED WIDGET-ID 26
          LABEL "НДС rubl"
           VIEW-AS TEXT
          SIZE 22 BY .67
     SPACE(55.74) SKIP(2.90)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Строка дополнительных расходов"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON B-quit WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: tt_add-line T "?" NO-UNDO ub add-line
      ADDITIONAL-FIELDS:
          field sum-cli as decimal
          field vat-cli as decimal

      END-FIELDS.
      TABLE: X_add-line B "?" ? ub add-line
      TABLE: X_contract B "?" ? ub contract
      TABLE: X_gds-add-charges B "?" ? ub gds-add-charges
      TABLE: X_goods B "?" ? ub goods
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN X_gds-add-charges.algoritm IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL EXP-FORMAT                                       */
ASSIGN
       X_gds-add-charges.algoritm:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN tt_add-line.cli-code IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR COMBO-BOX tt_add-line.cli-type IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* SETTINGS FOR FILL-IN tt_add-line.contract-code IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* SETTINGS FOR FILL-IN tt_add-line.gds-code IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN X_goods.gds-name IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN
       X_goods.gds-name:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN tt_add-line.host-code IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
ASSIGN
       tt_add-line.host-code:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR BUTTON r-currency IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN
       r-currency:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN scr-cli-name IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN
       scr-cli-name:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN scr-contract-name IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN
       scr-contract-name:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN scr-curr-abbr IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       scr-curr-abbr:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN tt_add-line.sum-base IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN
       tt_add-line.sum-base:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN tt_add-line.sum-rubl IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt_add-line.vat-base IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN tt_add-line.vat-rubl IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _TblList          = "Temp-Tables.TT_add-line,Temp-Tables.X_goods WHERE Temp-Tables.TT_add-line ...,Temp-Tables.X_gds-add-charges WHERE Temp-Tables.TT_add-line ..."
     _Options          = "SHARE-LOCK"
     _JoinCode[2]      = "Temp-Tables.X_goods.gds-code = Temp-Tables.TT_add-line.gds-code"
     _JoinCode[3]      = "Temp-Tables.X_gds-add-charges.gds-code = Temp-Tables.TT_add-line.gds-code"
     _Query            is OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Строка дополнительных расходов */
DO:
  run save-proc in this-procedure no-error .
    if error-status :error  then do:
        message
          error-status :get-message(1) skip
          return-value skip
          "Ошибка ввода"
          view-as alert-box error
        .
        return no-apply .

    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Строка дополнительных расходов */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-cli
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-cli Dialog-Frame
ON CHOOSE OF B-cli IN FRAME Dialog-Frame
DO:
assign TT_add-line.cli-code TT_add-line.cli-type .
define buffer buf_clients for ub.clients  .
find first buf_clients no-lock where
           buf_clients.obj-type = TT_add-line.cli-type and
           buf_clients.obj-code = TT_add-line.cli-code no-error .
if not available buf_clients then return .
  run ref/showcli.p (
     input parParentProc
    ,input TT_add-line.cli-type /* p-obj-type */
    ,input TT_add-line.cli-code /* p-obj-code */
    ).

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-contract
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-contract Dialog-Frame
ON CHOOSE OF B-contract IN FRAME Dialog-Frame
DO:
assign TT_add-line.contract-code .
define buffer b_contract for ub.contract.
find first b_contract no-lock  where b_contract.contract-code     = TT_add-line.contract-code and
                                     b_contract.host-code         = TT_add-line.host-code
                                     no-error .
if error-status :error then return .

run str/sh-contr.p (
    input parParentProc ,
    input recid (b_contract))
    .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-exit Dialog-Frame
ON CHOOSE OF B-exit IN FRAME Dialog-Frame /* Ввод */
DO:
  { gbl/stdbtn.i }
  assign
  frame {&frame-name}
  {&ENABLED-FIELDS}
.

  p-mode-exit= "".
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-Help
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-Help Dialog-Frame
ON CHOOSE OF B-Help IN FRAME Dialog-Frame /* Help */
OR HELP OF FRAME {&FRAME-NAME}
DO: /* Call Help Function (or a simple message). */
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-History
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-History Dialog-Frame
ON CHOOSE OF B-History IN FRAME Dialog-Frame /* История */
DO: /* Call Help Function (or a simple message). */
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-quit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-quit Dialog-Frame
ON CHOOSE OF B-quit IN FRAME Dialog-Frame /* Отмена */
DO:
   p-mode-exit= "cancel".
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-quit-cycle
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-quit-cycle Dialog-Frame
ON CHOOSE OF B-quit-cycle IN FRAME Dialog-Frame /* Стоп-цикл */
DO:
   p-mode-exit= "stop-cycle".
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt_add-line.cli-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt_add-line.cli-code Dialog-Frame
ON LEAVE OF tt_add-line.cli-code IN FRAME Dialog-Frame /* Поставшик услуги */
DO:
  run f-cli in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt_add-line.cli-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt_add-line.cli-type Dialog-Frame
ON VALUE-CHANGED OF tt_add-line.cli-type IN FRAME Dialog-Frame /* cli-type */
DO:
  assign TT_add-line.cli-type.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt_add-line.contract-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt_add-line.contract-code Dialog-Frame
ON LEAVE OF tt_add-line.contract-code IN FRAME Dialog-Frame /* Договор */
DO:
run f-con in this-procedure .
run f-spec in this-procedure .
run exch-rate in this-procedure.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME exch-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL exch-code Dialog-Frame
ON LEAVE OF exch-code IN FRAME Dialog-Frame /* Валюта */
or return of exch-code in frame {&frame-name}
do:
  assign exch-code  .
  find ub.currency no-lock where ub.currency.curr-code  = exch-code no-error.
  if not available ub.currency then do:
     return no-apply.
  end.
  display ub.currency.curr-code @ exch-code with frame {&frame-name} .

  RUN exch-rate    in this-procedure.




END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL exch-code Dialog-Frame
ON VALUE-CHANGED OF exch-code IN FRAME Dialog-Frame /* Валюта */
DO:
    assign exch-code  .
  find ub.currency no-lock where ub.currency.curr-code  = exch-code no-error.
  if not available ub.currency then do:
     return no-apply.
  end.
  display ub.currency.curr-code @ exch-code with frame {&frame-name} .

  RUN exch-rate    in this-procedure.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME exch-rate
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL exch-rate Dialog-Frame
ON LEAVE OF exch-rate IN FRAME Dialog-Frame
DO:
  assign exch-rate .
  run recalc(2).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME exch-scale
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL exch-scale Dialog-Frame
ON LEAVE OF exch-scale IN FRAME Dialog-Frame
DO:
  assign exch-scale.
  run recalc(2).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME r-cli
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL r-cli Dialog-Frame
ON CHOOSE OF r-cli IN FRAME Dialog-Frame
DO:
  define variable rid-list as character no-undo.
  define buffer buf_clients for ub.clients.
TT_add-line.cli-code   = 0 .
TT_add-line.cli-type   = "" .
scr-cli-name = "".

  run ref/cli-all.w
      ( input parParentProc,
        input "b-sel",
        input {&cmp},
        input {&all},
        input {&current},
        input ?,
        input ",,,,,,NO,,":U,
        input "without-obj",  /*;lock-cli-type*/
        output rid-list ) .

find first buf_clients no-lock where
     recid (buf_clients) = integer(rid-list) no-error .
    if available buf_clients then do:
        TT_add-line.cli-code  = buf_clients.obj-code .
        TT_add-line.cli-type  = buf_clients.obj-type .
        scr-cli-name = buf_clients.obj-name .
    end.

display TT_add-line.cli-code
        scr-cli-name
        TT_add-line.cli-type
        with frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME r-contract
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL r-contract Dialog-Frame
ON CHOOSE OF r-contract IN FRAME Dialog-Frame
DO:
  /* Договор  */
IF TT_add-line.cli-code = 0  THEN DO:
   message "Не выбран Поставщик услуги !"  view-as alert-box information .
   return no-apply .
END.
define variable   rid-list   as character no-undo . /* recid выбранных договоров */
define buffer buf_contract for ub.contract.

ASSIGN
TT_add-line.cli-code
TT_add-line.contract-code = 0
scr-contract-name     = "" .

run str/cont-all.w (
      input   parParentProc   ,
      input   TT_add-line.host-code  ,
      input   "b-sel"         ,
      input   "contract-type=" + {&contr-addch} ,
      input   TT_add-line.cli-type ,
      input   TT_add-line.cli-code ,
      input   ?               ,
      input   ?               ,
      input   "current"       ,
      input   {&income}       ,
      input-output rid-list )
      .
find first buf_contract no-lock where recid (buf_contract) =  integer(rid-list) no-error .
if available buf_contract then do:
  TT_add-line.contract-code = buf_contract.contract-code .
  scr-contract-name     = buf_contract.contract-prn-code.
  end.

DISPLAY TT_add-line.contract-code
        scr-contract-name
        WITH FRAME {&FRAME-NAME}.

run f-con in this-procedure .
run f-spec in this-procedure .
run exch-rate in this-procedure.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME r-currency
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL r-currency Dialog-Frame
ON CHOOSE OF r-currency IN FRAME Dialog-Frame
DO:
  run r-proc-currency in this-procedure.

  end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME sum-cli
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sum-cli Dialog-Frame
ON LEAVE OF sum-cli IN FRAME Dialog-Frame /* Сумма (в док.) */
DO:
  assign sum-cli .
  TT_add-line.sum-cli = sum-cli .
  run recalc(2).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt_add-line.vat-pc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt_add-line.vat-pc Dialog-Frame
ON LEAVE OF tt_add-line.vat-pc IN FRAME Dialog-Frame /* НДС % */
DO:
  run recalc(1).
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
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  TT_add-line.cli-type:LIST-ITEMS = "{&bef-cmp},{&bef-prs}" .
  TT_add-line.sum-rubl:label      = "Сумма, {&abbr_rub}"    .
  TT_add-line.vat-rubl:label      = "НДС, {&abbr_rub}"      .

  run init-proc in this-procedure .
  if p-mode = {&lookup} then run enable_lkp in this-procedure .
  else run enable_my in this-procedure .

  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE check-exch Dialog-Frame
PROCEDURE check-exch :
find currency where currency.curr-code = exch-code  no-lock no-error.
  if not available currency then do:
    message "Неправильная валюта  - такой валюты нет.".
    apply "entry" to exch-code in frame {&frame-name}.
    return error.
  end.

    if currency.curr-code = 0 then do:
      if (exch-rate <> ? and exch-scale <> ? and
          (exch-rate <> 1 or exch-scale <> 1)) then do:
      end.

      assign
        exch-rate = 1
        exch-scale = 1.
      disable exch-rate exch-scale with frame {&frame-name}.
    end.
    else do:
      find last curr-accnt where curr-accnt.curr-code = currency.curr-code
                             and curr-accnt.exch-date <= today use-index pi no-lock no-error.
      if available curr-accnt then do:
        assign
          exch-rate = curr-accnt.exch-rate
          exch-scale = curr-accnt.exch-scale.
      end.
      else do:
        assign
          exch-rate = ?
          exch-scale = ?.
      end.
      if exch-code = 0 and
        (exch-rate  <> ? and
         exch-scale <> ? and
         (exch-rate <> 1 or exch-scale <> 1)
        ) then do:
      end.
      enable exch-rate exch-scale  with frame {&frame-name}.
    end.

    assign
      exch-code = currency.curr-code
      .
    display exch-code currency.curr-abbr @ scr-curr-abbr
            exch-rate
            exch-scale with frame {&frame-name}.


define variable v-exch-rate   as decimal   no-undo .
define variable v-exch-scale as decimal   no-undo .

    { gbl/exchrate.i
      exch-code
      today
      v-exch-rate
      v-exch-scale
      scr-curr-abbr
    }
     sum-cli:label in frame {&frame-name} = "Сумма, " + scr-curr-abbr .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE check-rate Dialog-Frame
PROCEDURE check-rate :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable varbase-code as integer no-undo.
{ gbl/basecode.i v-cntxt-host-code-obj varbase-code }
define variable flag-recount as logical initial no no-undo.
/*Если курс изменился, то в конце пересчитаем накладную*/
if input frame {&frame-name} exch-rate  <> exch-rate  or
   input frame {&frame-name} exch-scale <> exch-scale then flag-recount = yes.

if input frame {&frame-name} exch-rate = ? or
   input frame {&frame-name} exch-rate = 0 then do:
  message "Не задан курс валюты поставщика.".
  apply "entry" to exch-rate in frame {&frame-name}.
  return error.
end.
if input frame {&frame-name} exch-scale = ? or
   input frame {&frame-name} exch-scale = 0 then do:
  message "Не задан масштаб валюты поставщика.".
  apply "entry" to exch-scale in frame {&frame-name}.
  return error.
end.
assign
  frame {&frame-name}
  exch-rate
  exch-scale.
run waitfram-show in this-procedure  ("ЖДИТЕ.  Пересчет документа ...").
if flag-recount then do:
   run full-recount.
end.
run waitfram-hide in this-procedure  .

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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_lkp Dialog-Frame
PROCEDURE enable_lkp :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  {&OPEN-QUERY-Dialog-Frame}
  GET FIRST Dialog-Frame.
  DISPLAY scr-cli-name scr-contract-name exch-code exch-rate exch-scale scr-curr-abbr
      WITH FRAME Dialog-Frame.
  IF AVAILABLE TT_add-line THEN
    DISPLAY TT_add-line.cli-code TT_add-line.cli-type TT_add-line.contract-code
          TT_add-line.sum-base TT_add-line.sum-rubl TT_add-line.vat-pc
          TT_add-line.gds-code TT_add-line.host-code TT_add-line.vat-base
          TT_add-line.vat-rubl sum-cli
      WITH FRAME Dialog-Frame.
  IF AVAILABLE X_goods THEN
    DISPLAY X_goods.gds-name
      WITH FRAME Dialog-Frame.
  ENABLE B-exit B-quit  B-History B-Help B-cli
         B-contract

      WITH FRAME Dialog-Frame.
  hide B-exit B-quit-cycle in frame {&frame-name} .
  B-quit:label = "Выход" .
  B-quit:column = 1 .
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_my Dialog-Frame
PROCEDURE enable_my :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  {&OPEN-QUERY-Dialog-Frame}
  GET FIRST Dialog-Frame.
  DISPLAY scr-cli-name scr-contract-name exch-code exch-rate exch-scale r-currency scr-curr-abbr
      WITH FRAME Dialog-Frame.
  IF AVAILABLE TT_add-line THEN
    DISPLAY TT_add-line.cli-code TT_add-line.cli-type TT_add-line.contract-code
          TT_add-line.sum-base TT_add-line.sum-rubl TT_add-line.vat-pc
          TT_add-line.gds-code TT_add-line.host-code TT_add-line.vat-base
          TT_add-line.vat-rubl sum-cli
      WITH FRAME Dialog-Frame.
  IF AVAILABLE X_goods THEN
    DISPLAY X_goods.gds-name
      WITH FRAME Dialog-Frame.
  ENABLE B-exit B-quit B-quit-cycle B-History B-Help B-cli TT_add-line.cli-code r-currency
         TT_add-line.cli-type r-cli B-contract TT_add-line.contract-code
         r-contract  sum-cli exch-code exch-rate exch-scale
         TT_add-line.vat-pc TT_add-line.host-code
      WITH FRAME Dialog-Frame.
  if p-mode = {&update} then hide B-quit-cycle in frame {&frame-name} .
  if exch-code = 0 then disable exch-rate exch-scale with frame {&frame-name}.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}

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

  {&OPEN-QUERY-Dialog-Frame}
  GET FIRST Dialog-Frame.
  DISPLAY exch-code exch-rate exch-scale sum-cli scr-cli-name scr-contract-name
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt_add-line THEN
    DISPLAY tt_add-line.cli-code tt_add-line.cli-type tt_add-line.contract-code
          tt_add-line.vat-pc tt_add-line.gds-code tt_add-line.host-code
          tt_add-line.sum-base tt_add-line.sum-rubl tt_add-line.vat-base
          tt_add-line.vat-rubl
      WITH FRAME Dialog-Frame.
  IF AVAILABLE X_gds-add-charges THEN
    DISPLAY X_gds-add-charges.algoritm
      WITH FRAME Dialog-Frame.
  IF AVAILABLE X_goods THEN
    DISPLAY X_goods.gds-name
      WITH FRAME Dialog-Frame.
  ENABLE B-exit B-quit B-quit-cycle B-History B-Help tt_add-line.cli-code
         tt_add-line.cli-type B-cli r-cli B-contract tt_add-line.contract-code
         r-contract exch-code exch-rate exch-scale tt_add-line.vat-pc sum-cli
         tt_add-line.host-code tt_add-line.sum-rubl
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE exch-rate Dialog-Frame
PROCEDURE exch-rate :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
display currency.curr-code @ exch-code with frame {&frame-name}.
do transaction on error   undo, return error :
   run check-exch   in this-procedure.
   run check-rate   in this-procedure.
   run full-recount in this-procedure.
   run recalc(2).
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE f-cli Dialog-Frame
PROCEDURE f-cli :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
assign
  frame {&frame-name}
  TT_add-line.cli-type
  TT_add-line.cli-code
.
define buffer buf_clients for ub.clients  .
scr-cli-name = "" .
find first buf_clients no-lock where
     buf_clients.obj-type = TT_add-line.cli-type and
     buf_clients.obj-code = TT_add-line.cli-code
     no-error .
    if available buf_clients then do:
        scr-cli-name = buf_clients.obj-name .
    end.
display
scr-cli-name
with frame {&frame-name} .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE f-con Dialog-Frame
PROCEDURE f-con :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
assign frame {&frame-name}  TT_add-line.contract-code  .

define buffer buf_contract         for ub.contract  .
define buffer buf_contract-specif for ub.contract-specif  .
define buffer buf1_contract-specif for ub.contract-specif  .

scr-contract-name = "".
find first buf_contract no-lock where
           buf_contract.contract-code = TT_add-line.contract-code   and
           buf_contract.host-code     = TT_add-line.host-code
           no-error .
if available buf_contract then do:
scr-contract-name =   buf_contract.contract-prn-code .
exch-code         =   buf_contract.curr-code         .
end.


if exch-code <> 0 and  p-mode <> {&lookup} then enable exch-rate exch-scale with frame {&frame-name}.
if p-mode <> {&lookup} then do:
   run check-exch .
end.
display
scr-contract-name
exch-code @ exch-code
TT_add-line.vat-pc @  TT_add-line.vat-pc
sum-cli            @  sum-cli
with frame {&frame-name} .
run recalc(2) .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE f-spec Dialog-Frame
PROCEDURE f-spec :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
define buffer buf_contract         for ub.contract  .
define buffer buf_contract-specif  for ub.contract-specif  .
define buffer buf1_contract-specif for ub.contract-specif  .

find first buf_contract no-lock where
           buf_contract.contract-code = TT_add-line.contract-code   and
           buf_contract.host-code     = TT_add-line.host-code
           no-error .
if available buf_contract then do:
exch-code = buf_contract.curr-code  .

    find first buf_contract-specif no-lock where
               buf_contract-specif.contract-num  = buf_contract.contract-code  and
               buf_contract-specif.host-code     = buf_contract.host-code
               no-error .
        if available buf_contract-specif then do:
            find first buf1_contract-specif no-lock where
                      buf1_contract-specif.gds-code      = TT_add-line.gds-code  and
                      buf1_contract-specif.contract-num  = buf_contract.contract-code  and
                      buf1_contract-specif.host-code     = buf_contract.host-code
                      no-error .
             if available buf1_contract-specif then do:
                TT_add-line.vat-pc = buf1_contract-specif.vat-pc   .
                TT_add-line.sum-cli = buf1_contract-specif.sum-cli .
                            sum-cli = buf1_contract-specif.sum-cli .
             end.
       end.
      display
        exch-code          @ exch-code
        tt_add-line.vat-pc @  tt_add-line.vat-pc
        sum-cli            @  sum-cli
        with frame {&frame-name} .
end.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE full-recount Dialog-Frame
PROCEDURE full-recount :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-proc Dialog-Frame
PROCEDURE init-proc :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
define variable v-vat-pc         as decimal   no-undo .
define variable loc-base-rate    as decimal   no-undo .
define variable loc-base-scale   as decimal   no-undo .
define variable vat_type         as character no-undo .
define variable slt_type         as character no-undo .

define variable base-abbr    as character no-undo .
define variable v-exch-code  as integer   no-undo .
define variable v-exch-rate  as decimal   no-undo .
define variable v-exch-scale as decimal   no-undo .
define variable v-sum-cli    as decimal   no-undo .
define variable v-sum-vat    as decimal   no-undo .


define buffer buf_goods for ub.goods  .
 run get-var in p-upper-h (
  output loc-base-rate
 ,output loc-base-scale
 ,output vat_type ).

 run get-var-2 in p-upper-h (
  output base-abbr
  ).

  find first x_goods no-lock where x_goods.gds-code = p-gds-code.
  find first buf_goods no-lock where buf_goods.gds-code = p-gds-code.
   { gbl/pftxvalg.i
     buf_goods.gds-code
    {&vat-tax-code}
    ?
    v-cntxt-host-code-obj
    v-cntxt-obj-type
    v-cntxt-obj-code
    v-vat-pc
    no-error
  }
  if error-status :error then do:
    message
      error-status :get-message(1) skip
      return-value skip
      "Ошибка при определении НДС"
      view-as alert-box error
    .
    return .
  end.

if p-mode = {&add-def} then do:
   create tt_add-line.
   assign
      tt_add-line.cli-code         = 0
      tt_add-line.cli-type         = {&cmp}
      tt_add-line.contract-code    = 0
      tt_add-line.doc-code         = p-doc-code
      tt_add-line.gds-code         = p-gds-code
      tt_add-line.host-code        = v-cntxt-host-code-obj
      tt_add-line.sum-cli          = 0
      tt_add-line.sum-base         = 0
      tt_add-line.sum-rubl         = 0
      tt_add-line.vat-pc           = v-vat-pc
      tt_add-line.vat-base         = 0
      tt_add-line.vat-rubl         = 0
   .
      exch-code = 0 .
    { gbl/exchrate.i
      exch-code
      today
      exch-rate
      exch-scale
      scr-curr-abbr
    }

end.
else do:
   if p-mode = {&lookup} then
       find first buf_add-line no-lock where recid(buf_add-line) = p-recid no-error .
    else
       find first buf_add-line exclusive-lock where recid(buf_add-line) = p-recid no-error .

     run lineattr-value-add-line-cli (
          input  buf_add-line.doc-code     ,
          input  buf_add-line.gds-code     ,
          input  buf_add-line.cli-type     ,
          input  buf_add-line.cli-code     ,
          input  buf_add-line.contract-code,
          input  buf_add-line.host-code    ,
          output v-exch-code    ,
          output v-exch-rate    ,
          output v-exch-scale   ,
          output v-sum-cli      ,
          output v-sum-vat      ) no-error .
          if error-status :error then
          message
            vss-workfile vss-revision vss-description skip
            error-status :get-message(1) skip
            return-value skip
            ""
            view-as alert-box error
          .
      exch-code  = v-exch-code .
      /* нужен только аббр валюты */
    { gbl/exchrate.i
      exch-code
      today
      exch-rate
      exch-scale
      scr-curr-abbr
    }
      exch-rate  = v-exch-rate  .
      exch-scale = v-exch-scale .


    create tt_add-line.
    buffer-copy buf_add-line to tt_add-line
    assign
      tt_add-line.sum-cli = v-sum-cli
    .
    assign
      sum-cli     = v-sum-cli
      exch-code   = v-exch-code
      exch-rate   = v-exch-rate
      exch-scale  = v-exch-scale
    .
end.
if not available X_gds-add-charges then
       find first X_gds-add-charges WHERE X_gds-add-charges.gds-code = TT_add-line.gds-code .


TT_add-line.sum-base:label in frame {&frame-name}  = "Сумма, "  + base-abbr .
TT_add-line.vat-base:label in frame {&frame-name} = "НДС, " + base-abbr .
sum-cli:label in frame {&frame-name} = "Сумма, " + scr-curr-abbr .

display
alg-name( buffer X_gds-add-charges )  @ X_gds-add-charges.algoritm
with frame {&frame-name} .


run f-cli in this-procedure .
run f-con in this-procedure .
run recalc  in this-procedure  (2).


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE r-proc-currency Dialog-Frame
PROCEDURE r-proc-currency :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
run ref/currency.w ( input parparentproc, input "b-sel", input-output ref-rec ).
  if ref-rec = ? then do:
     return no-apply.
  end.
  find ub.currency no-lock where recid( ub.currency ) = ref-rec no-error.
  if not available ub.currency then do:
     return no-apply.
  end.
  if ub.currency.curr-code <> exch-code then do:
   display ub.currency.curr-code @ exch-code with frame {&frame-name} .
  end.
  assign exch-code  .
  RUN exch-rate    in this-procedure.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE recalc Dialog-Frame
PROCEDURE recalc :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input  parameter p-type as integer   no-undo .
define variable     loc-base-rate    as decimal   no-undo .
define variable     loc-base-scale   as decimal   no-undo .
define variable     vat_type         as character no-undo .
define variable     slt_type         as character no-undo .
define variable    varprice-cli-dt            as decimal   no-undo .
define variable    varprice-cli-unit-base-dt  as decimal   no-undo .
define variable    varprice-road-tax-dt       as decimal   no-undo .
define variable    varprice-other-exp-dt      as decimal   no-undo .
define variable     varprice-transport-exp-dt as decimal   no-undo .
define variable     varprice-without-abs-dt   as decimal   no-undo .
define variable     varprice-slt-dt           as decimal   no-undo .
define variable     varprice-no-slt-dt        as decimal   no-undo .
define variable     varprice-vat-dt           as decimal   no-undo .
define variable     varprice-no-vat-slt-dt    as decimal   no-undo .
define variable     varprice-rubl-dt                as decimal   no-undo .
define variable     varprice-road-tax-rubl-dt       as decimal   no-undo .
define variable     varprice-other-exp-rubl-dt      as decimal   no-undo .
define variable     varprice-transport-exp-rubl-dt  as decimal   no-undo .
define variable     varprice-without-abs-rubl-dt    as decimal   no-undo .
define variable     varprice-slt-rubl-dt            as decimal   no-undo .
define variable     varprice-no-slt-rubl-dt         as decimal   no-undo .
define variable     varprice-vat-rubl-dt            as decimal   no-undo .
define variable     varprice-no-vat-slt-rubl-dt     as decimal   no-undo .
define variable     varprice-base-dt                as decimal   no-undo .
define variable     varprice-road-tax-base-dt       as decimal   no-undo .
define variable     varprice-other-exp-base-dt      as decimal   no-undo .
define variable     varprice-transport-exp-base-dt  as decimal   no-undo .
define variable     varprice-without-abs-base-dt    as decimal   no-undo .
define variable     varprice-slt-base-dt            as decimal   no-undo .
define variable     varprice-no-slt-base-dt         as decimal   no-undo .
define variable     varprice-vat-base-dt            as decimal   no-undo .
define variable     varprice-no-vat-slt-base-dt     as decimal   no-undo .

assign
  frame {&frame-name}
  {&ENABLED-FIELDS}
.

 run get-var in p-upper-h (
  output loc-base-rate
 ,output loc-base-scale
 ,output vat_type ).
  if vat_type = {&without-VAT} then tt_add-line.vat-pc = 0.
  slt_type = {&without-SLT} .
/*
1 vat
2 sum-rubl
*/
  /*Расчет поля <<сумма НДС>>*/
    tt_add-line.sum-rubl =  tt_add-line.sum-cli  * exch-rate / exch-scale .

  { str/in-vat.i
    "'zakaz':u"
    loc-base-rate
    loc-base-scale
    exch-rate
    exch-scale
    vat_type
    slt_type
    x_goods.artic
    x_goods.prod-type
    x_goods.prod-code
    tt_add-line.sum-cli
    1
    tt_add-line.sum-rubl
    tt_add-line.vat-pc
    0
    0
    0
    0
    varprice-cli-dt
    varprice-cli-unit-base-dt
    varprice-road-tax-dt
    varprice-other-exp-dt
    varprice-transport-exp-dt
    varprice-without-abs-dt
    varprice-slt-dt
    varprice-no-slt-dt
    varprice-vat-dt
    varprice-no-vat-slt-dt
    varprice-rubl-dt
    varprice-road-tax-rubl-dt
    varprice-other-exp-rubl-dt
    varprice-transport-exp-rubl-dt
    varprice-without-abs-rubl-dt
    varprice-slt-rubl-dt
    varprice-no-slt-rubl-dt
    varprice-vat-rubl-dt
    varprice-no-vat-slt-rubl-dt
    varprice-base-dt
    varprice-road-tax-base-dt
    varprice-other-exp-base-dt
    varprice-transport-exp-base-dt
    varprice-without-abs-base-dt
    varprice-slt-base-dt
    varprice-no-slt-base-dt
    varprice-vat-base-dt
    varprice-no-vat-slt-base-dt
    no-error
    }
    if error-status:error then do:
      message  "Ошибка при пересчете НДС" return-value error-status :get-message(1) view-as alert-box error .
    end.

TT_add-line.sum-base = varprice-base-dt      .
TT_add-line.sum-rubl = varprice-rubl-dt      .
TT_add-line.vat-base = varprice-vat-base-dt  .
TT_add-line.vat-rubl = varprice-vat-rubl-dt  .


display TT_add-line.sum-base
        TT_add-line.sum-rubl
        TT_add-line.vat-base
        TT_add-line.vat-rubl
        tt_add-line.vat-pc
        with frame {&frame-name} .


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE save-proc Dialog-Frame
PROCEDURE save-proc :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
if p-mode = {&lookup} then do:
   p-recid = recid(buf_add-line) .
  return .
End.
 /* Проверки правильности заполнения экрана */

assign
  frame {&frame-name}
  {&ENABLED-FIELDS}
.

define buffer buf_clients  for ub.clients  .
define buffer buf_contract for ub.contract  .
define buffer buf_contract-specif  for ub.contract-specif  .
define buffer buf1_contract-specif for ub.contract-specif  .
define buffer buf_contract-specif-attr for ub.contract-specif-attr .

find first buf_clients no-lock where
     buf_clients.obj-type = TT_add-line.cli-type and
     buf_clients.obj-code = TT_add-line.cli-code
     no-error .
if error-status :error then return error 'Не верно введен Поставщик услуги' .

if TT_add-line.contract-code <> 0 then do:
    find first buf_contract no-lock where
               buf_contract.contract-code = TT_add-line.contract-code   and
               buf_contract.host-code     = TT_add-line.host-code
              no-error .

    if error-status :error
       then return error substitute(" Нет договора с внутренним номером &1 на фирме &2" ,TT_add-line.contract-code,TT_add-line.host-code ) .
    if exch-code <>  buf_contract.curr-code
       then return error substitute(" У договора с внутренним номером &1 на фирме &2 задан код валюты &3" ,TT_add-line.contract-code , TT_add-line.host-code , buf_contract.curr-code ) .
    if ( TT_add-line.cli-type <> buf_contract.cli-type or
         TT_add-line.cli-code <> buf_contract.cli-code ) then do:
            return error substitute(" У договора с внутренним номером &1 на фирме &2 задан другой контрагент &3 &4" ,TT_add-line.contract-code , TT_add-line.host-code , buf_contract.cli-code , buf_contract.cli-type) .
         end.
    find first buf_contract-specif no-lock where
               buf_contract-specif.contract-num  = buf_contract.contract-code  and
               buf_contract-specif.host-code     = buf_contract.host-code
               no-error .
        if available buf_contract-specif then do:
        find first buf1_contract-specif no-lock where
                   buf1_contract-specif.gds-code      = TT_add-line.gds-code  and
                   buf1_contract-specif.contract-num  = buf_contract.contract-code  and
                   buf1_contract-specif.host-code     = buf_contract.host-code
                   no-error .
        if error-status :error then return error
            substitute(" Спецификация договора &1 не содержит услуги &2" ,
                        buf_contract.contract-code,
                        X_goods.gds-name ) .
            else do: /* проверим цены */
               if buf1_contract-specif.sum-cli <> 0 then do:
               if (buf1_contract-specif.sum-cli  + (buf1_contract-specif.sum-cli * buf1_contract-specif.prc / 100) ) < TT_add-line.sum-cli then
                  return error  substitute(" Спецификация договора &1 по услуге &2 имеет цену &3 , цена документа &5 выходит за процент отклонения в большую сторону &4% " ,
                        buf_contract.contract-code,
                        X_goods.gds-name              ,
                        buf1_contract-specif.sum-cli  ,
                        buf1_contract-specif.prc ,
                        TT_add-line.sum-cli
                        ) .
               find first buf_contract-specif-attr no-lock where
                          buf_contract-specif-attr.gds-code      = TT_add-line.gds-code  and
                          buf_contract-specif-attr.contract-num  = buf_contract.contract-code  and
                          buf_contract-specif-attr.host-code     = buf_contract.host-code     and
                          buf_contract-specif-attr.attr-code     = {&contract-specif-prc-min}
                          no-error .
               if (buf1_contract-specif.sum-cli  - (buf1_contract-specif.sum-cli * decimal(buf_contract-specif-attr.attr-value) / 100) ) > TT_add-line.sum-cli then
                  return error  substitute(" Спецификация договора &1 по услуге &2 имеет цену &3 , цена документа &5 выходит за процент отклонения в меньшую сторону &4% " ,
                        buf_contract.contract-code,
                        X_goods.gds-name              ,
                        buf1_contract-specif.sum-cli  ,
                        buf_contract-specif-attr.attr-value ,
                        TT_add-line.sum-cli
                        ) .

               if buf1_contract-specif.VAT-pc <> TT_add-line.vat-pc then
                  return error substitute(" Спецификация договора &1 по услуге &2 имеет НДС &3 % " ,
                              buf_contract.contract-code  ,
                              X_goods.gds-name            ,
                              buf1_contract-specif.vat-pc
                              ) .
               end.
            end.
        end.
end.

if tt_add-line.sum-rubl = 0 or tt_add-line.sum-rubl = ? then return error " Не задана цена услуги".
run recalc  in this-procedure  (2).

if p-mode = {&add-def} then do:
  create buf_add-line.
end.
buffer-copy tt_add-line to buf_add-line no-error .
if error-status :error then return error substitute(" В документе ДопРасхода &1 &6 уже есть строка расходов по услуге &6 Код &2 &6 Контрагент &4 &3 &6 Вн№.договора &5 &6 &7 " ,
                                                      tt_add-line.doc-code ,
                                                      tt_add-line.gds-code      ,
                                                      tt_add-line.cli-code      ,
                                                      tt_add-line.cli-type      ,
                                                      tt_add-line.contract-code ,
                                                      {&new-line}              ,
                                                      return-value
                                                      )  .

    run lineattr-write-add-line-cli (
        tt_add-line.doc-code     ,
        tt_add-line.gds-code     ,
        tt_add-line.cli-type     ,
        tt_add-line.cli-code     ,
        tt_add-line.contract-code,
        tt_add-line.host-code    ,
        exch-code                ,
        exch-rate                ,
        exch-scale               ,
        tt_add-line.sum-cli      ,
        0
        ).

  p-recid = recid(buf_add-line) .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE update-rate-doc Dialog-Frame
PROCEDURE update-rate-doc :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
if input frame {&frame-name} exch-rate  <> exch-rate  or
   input frame {&frame-name} exch-scale <> exch-scale
then
   do transaction on error undo, return error return-value :
     run check-exch   in this-procedure no-error.
     if error-status :error then do: return error return-value. end.
     run check-update in this-procedure no-error.
     if error-status :error then do: return error return-value. end.
     run check-rate   in this-procedure no-error.
     if error-status :error then do: return error return-value. end.
    end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME