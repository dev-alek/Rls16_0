&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v9r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame

/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER buy-clients FOR ub.clients.
DEFINE BUFFER obj-clients FOR ub.clients.
DEFINE TEMP-TABLE tt-turnover-buyer NO-UNDO LIKE ub.turnover-buyer.


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Корректировка Оборота ПОКУПАТЕЛЯ

Автор: Чернова Светлана Александровна
Дата создания: 11/10/05
Author: Svetlana Chernova
Creation date: 11/10/05

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input  parameter parparentproc as handle no-undo .
define input  parameter p-mode as character no-undo .
define input  parameter p-cli-type as character no-undo .
define input  parameter p-cli-code as integer   no-undo .
define input-output parameter p-recid as recid no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Корректировка Оборота ПОКУПАТЕЛЯ".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i  }
{ cmp/library.i  }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
{ gbl/userobjs.i }
{ trg/factord.i  }

/* Local Variable Definitions ---                                       */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-turnover-buyer buy-clients obj-clients

/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define SELF-NAME Dialog-Frame
&Scoped-define QUERY-STRING-Dialog-Frame FOR EACH tt-turnover-buyer NO-LOCK, ~
             EACH buy-clients WHERE buy-clients.obj-code =  tt-turnover-buyer.cli-code                          AND buy-clients.obj-type = tt-turnover-buyer.cli-type                          NO-LOCK, ~
             EACH obj-clients WHERE obj-clients.obj-code = tt-turnover-buyer.obj-code                          AND obj-clients.obj-type = tt-turnover-buyer.obj-type                          OUTER-JOIN NO-LOCK
&Scoped-define OPEN-QUERY-Dialog-Frame OPEN QUERY {&SELF-NAME} FOR EACH tt-turnover-buyer NO-LOCK, ~
             EACH buy-clients WHERE buy-clients.obj-code =  tt-turnover-buyer.cli-code                          AND buy-clients.obj-type = tt-turnover-buyer.cli-type                          NO-LOCK, ~
             EACH obj-clients WHERE obj-clients.obj-code = tt-turnover-buyer.obj-code                          AND obj-clients.obj-type = tt-turnover-buyer.obj-type                          OUTER-JOIN NO-LOCK.
&Scoped-define TABLES-IN-QUERY-Dialog-Frame tt-turnover-buyer buy-clients ~
obj-clients
&Scoped-define FIRST-TABLE-IN-QUERY-Dialog-Frame tt-turnover-buyer
&Scoped-define SECOND-TABLE-IN-QUERY-Dialog-Frame buy-clients
&Scoped-define THIRD-TABLE-IN-QUERY-Dialog-Frame obj-clients


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS tt-turnover-buyer.des ~
tt-turnover-buyer.fact-date tt-turnover-buyer.sum-doc-rubl ~
tt-turnover-buyer.sum-doc-base tt-turnover-buyer.sum-acc-rubl ~
tt-turnover-buyer.sum-acc-base tt-turnover-buyer.sum-vat-doc-rubl ~
tt-turnover-buyer.sum-vat-doc-base tt-turnover-buyer.sum-vat-acc-rubl ~
tt-turnover-buyer.sum-vat-acc-base tt-turnover-buyer.cli-code ~
tt-turnover-buyer.cli-type buy-clients.obj-name tt-turnover-buyer.obj-code ~
tt-turnover-buyer.obj-type obj-clients.obj-name
&Scoped-define ENABLED-TABLES tt-turnover-buyer buy-clients obj-clients
&Scoped-define FIRST-ENABLED-TABLE tt-turnover-buyer
&Scoped-define SECOND-ENABLED-TABLE buy-clients
&Scoped-define THIRD-ENABLED-TABLE obj-clients
&Scoped-Define ENABLED-OBJECTS B-Cancel B-save B-Help RECT-1 r-cli B-r-b ~
B-b-r v-rubl-abbr v-base-abbr v-base-rate v-base-scale
&Scoped-Define DISPLAYED-FIELDS tt-turnover-buyer.des ~
tt-turnover-buyer.fact-date tt-turnover-buyer.shift-date ~
tt-turnover-buyer.shift-num tt-turnover-buyer.shift-name ~
tt-turnover-buyer.sum-doc-rubl tt-turnover-buyer.sum-doc-base ~
tt-turnover-buyer.sum-acc-rubl tt-turnover-buyer.sum-acc-base ~
tt-turnover-buyer.sum-vat-doc-rubl tt-turnover-buyer.sum-vat-doc-base ~
tt-turnover-buyer.sum-vat-acc-rubl tt-turnover-buyer.sum-vat-acc-base ~
tt-turnover-buyer.cli-code tt-turnover-buyer.cli-type buy-clients.obj-name ~
tt-turnover-buyer.obj-code tt-turnover-buyer.obj-type obj-clients.obj-name
&Scoped-define DISPLAYED-TABLES tt-turnover-buyer buy-clients obj-clients
&Scoped-define FIRST-DISPLAYED-TABLE tt-turnover-buyer
&Scoped-define SECOND-DISPLAYED-TABLE buy-clients
&Scoped-define THIRD-DISPLAYED-TABLE obj-clients
&Scoped-Define DISPLAYED-OBJECTS v-rubl-abbr v-base-abbr v-base-rate ~
v-base-scale

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-b-r
     LABEL "<<"
     SIZE 4 BY 1.13 TOOLTIP "Пересчитать из базовой валюты в национальную".

DEFINE BUTTON B-Cancel AUTO-END-KEY
     LABEL "Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-r-b
     LABEL ">>"
     SIZE 4 BY 1.13 TOOLTIP "Пересчитать в базовую валюту".

DEFINE BUTTON B-save AUTO-GO
     LABEL "Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON r-cli
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "r-cli"
     SIZE 3 BY .88 TOOLTIP "Выбор из списка".

DEFINE BUTTON r-shift
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY .88 TOOLTIP "Список смен".

DEFINE VARIABLE v-base-abbr AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 4 BY .67 TOOLTIP "Базовая валюта"
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE v-base-rate AS DECIMAL FORMAT "->>,>>9.99":U INITIAL 0
     LABEL "Курс"
      VIEW-AS TEXT
     SIZE 14 BY .67 TOOLTIP "Базовая валюта" NO-UNDO.

DEFINE VARIABLE v-base-scale AS INTEGER FORMAT ">>9":U INITIAL 0
      VIEW-AS TEXT
     SIZE 3 BY .67 TOOLTIP "М-б" NO-UNDO.

DEFINE VARIABLE v-rubl-abbr AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 4 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 87.5 BY 6.25.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY Dialog-Frame FOR
      tt-turnover-buyer,
      buy-clients,
      obj-clients SCROLLING.
&ANALYZE-RESUME

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-save AT ROW 1 COL 1
     B-Cancel AT ROW 1 COL 11
          B-Help AT ROW 1 COL 77.88
     tt-turnover-buyer.des AT ROW 3.04 COL 13.13 COLON-ALIGNED HELP
          ""
          LABEL "Обоснование" FORMAT "X(256)"
          VIEW-AS FILL-IN
          SIZE 72.5 BY 1 TOOLTIP "Обоснование оборота"
     r-cli AT ROW 4 COL 29.5
     tt-turnover-buyer.fact-date AT ROW 4.96 COL 13.13 COLON-ALIGNED
          LABEL "Дата оборота"
          VIEW-AS FILL-IN
          SIZE 11 BY 1
     tt-turnover-buyer.shift-date AT ROW 4.96 COL 37.63 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 9 BY 1
     tt-turnover-buyer.shift-num AT ROW 4.96 COL 56.38 COLON-ALIGNED
          LABEL "П"
          VIEW-AS FILL-IN
          SIZE 3 BY 1
     tt-turnover-buyer.shift-name AT ROW 5 COL 50 COLON-ALIGNED
          LABEL "№"
          VIEW-AS FILL-IN
          SIZE 3 BY 1
     r-shift AT ROW 5 COL 61.5
     tt-turnover-buyer.sum-doc-rubl AT ROW 7.92 COL 30 COLON-ALIGNED
          LABEL "Сумма в ценах реализации"
          VIEW-AS FILL-IN
          SIZE 17 BY 1
     tt-turnover-buyer.sum-doc-base AT ROW 7.92 COL 61.63 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 17 BY 1
     B-r-b AT ROW 8.25 COL 54.5
     tt-turnover-buyer.sum-acc-rubl AT ROW 8.96 COL 30 COLON-ALIGNED
          LABEL "Сумма в учетных ценах"
          VIEW-AS FILL-IN
          SIZE 17 BY 1
     tt-turnover-buyer.sum-acc-base AT ROW 8.96 COL 61.63 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 17 BY 1
     B-b-r AT ROW 9.75 COL 54.5
     tt-turnover-buyer.sum-vat-doc-rubl AT ROW 10 COL 30 COLON-ALIGNED
          LABEL "Сумма НДС в ценах реализации"
          VIEW-AS FILL-IN
          SIZE 17 BY 1
     tt-turnover-buyer.sum-vat-doc-base AT ROW 10 COL 61.63 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 17 BY 1
     tt-turnover-buyer.sum-vat-acc-rubl AT ROW 11.04 COL 30 COLON-ALIGNED
          LABEL "Сумма НДС в учетных ценах"
          VIEW-AS FILL-IN
          SIZE 17 BY 1
     tt-turnover-buyer.sum-vat-acc-base AT ROW 11.04 COL 61.63 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 17 BY 1
     tt-turnover-buyer.cli-code AT ROW 2.25 COL 13 COLON-ALIGNED
          LABEL "Покупатель"
           VIEW-AS TEXT
          SIZE 10 BY .67
          FGCOLOR 1
     tt-turnover-buyer.cli-type AT ROW 2.25 COL 22 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT
          SIZE 4 BY .67
          FGCOLOR 1
     buy-clients.obj-name AT ROW 2.25 COL 27.5 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT
          SIZE 41 BY .67
          FGCOLOR 1
     tt-turnover-buyer.obj-code AT ROW 4.13 COL 13 COLON-ALIGNED
          LABEL "Объект"
           VIEW-AS TEXT
          SIZE 10 BY .67
     tt-turnover-buyer.obj-type AT ROW 4.13 COL 23 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT
          SIZE 4 BY .67
     obj-clients.obj-name AT ROW 4.21 COL 31 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT
          SIZE 41 BY .67
     v-rubl-abbr AT ROW 6.25 COL 30 COLON-ALIGNED NO-LABEL
     v-base-abbr AT ROW 6.25 COL 62 COLON-ALIGNED NO-LABEL
     v-base-rate AT ROW 7.25 COL 62.13 COLON-ALIGNED
     v-base-scale AT ROW 7.25 COL 77.63 COLON-ALIGNED NO-LABEL
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         DEFAULT-BUTTON B-save CANCEL-BUTTON B-Cancel.

/* DEFINE FRAME statement is approaching 4K Bytes.  Breaking it up   */
DEFINE FRAME Dialog-Frame
     RECT-1 AT ROW 6 COL 1
     SPACE(0.00) SKIP(0.37)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Добавление оборотов покупателю"
         DEFAULT-BUTTON B-save CANCEL-BUTTON B-Cancel.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: buy-clients B "?" ? ub clients
      TABLE: obj-clients B "?" ? ub clients
      TABLE: tt-turnover-buyer T "?" NO-UNDO ub turnover-buyer
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
                                                                        */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN tt-turnover-buyer.cli-code IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-turnover-buyer.des IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT EXP-HELP                                        */
/* SETTINGS FOR FILL-IN tt-turnover-buyer.fact-date IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-turnover-buyer.obj-code IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR BUTTON r-shift IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN
       r-shift:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN tt-turnover-buyer.shift-date IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN tt-turnover-buyer.shift-name IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN tt-turnover-buyer.shift-num IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN tt-turnover-buyer.sum-acc-rubl IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-turnover-buyer.sum-doc-rubl IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-turnover-buyer.sum-vat-acc-rubl IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-turnover-buyer.sum-vat-doc-base IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-turnover-buyer.sum-vat-doc-rubl IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt-turnover-buyer NO-LOCK,
      EACH buy-clients WHERE buy-clients.obj-code =  tt-turnover-buyer.cli-code
                         AND buy-clients.obj-type = tt-turnover-buyer.cli-type
                         NO-LOCK,
      EACH obj-clients WHERE obj-clients.obj-code = tt-turnover-buyer.obj-code
                         AND obj-clients.obj-type = tt-turnover-buyer.obj-type
                         OUTER-JOIN NO-LOCK.
     _END_FREEFORM
     _Options          = "SHARE-LOCK"
     _TblOptList       = ",,,,"
     _JoinCode[2]      = "buy-clients.obj-code =  Temp-Tables.tt-turnover-buyer.cli-code
  AND buy-clients.obj-type = Temp-Tables.tt-turnover-buyer.cli-type"
     _JoinCode[3]      = "obj-clients.obj-code = Temp-Tables.tt-turnover-buyer.obj-code
  AND obj-clients.obj-type = Temp-Tables.tt-turnover-buyer.obj-type"
     _Query            is OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Добавление оборотов покупателю */
DO:
  RUN save-proc no-error .
  if error-status :error then do:
  message
    error-status :get-message(1) skip
    return-value skip
    "Ошибка"
    view-as alert-box error
  .
  return no-apply .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Добавление оборотов покупателю */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-b-r
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-b-r Dialog-Frame
ON CHOOSE OF B-b-r IN FRAME Dialog-Frame /* << */
DO:

assign
tt-turnover-buyer.sum-acc-base
tt-turnover-buyer.sum-doc-base
tt-turnover-buyer.sum-vat-acc-base
tt-turnover-buyer.sum-vat-doc-base


  tt-turnover-buyer.sum-acc-rubl     =  tt-turnover-buyer.sum-acc-base       / v-base-scale * v-base-rate
  tt-turnover-buyer.sum-doc-rubl     =  tt-turnover-buyer.sum-doc-base       / v-base-scale * v-base-rate
  tt-turnover-buyer.sum-vat-acc-rubl =  tt-turnover-buyer.sum-vat-acc-base   / v-base-scale * v-base-rate
  tt-turnover-buyer.sum-vat-doc-rubl =  tt-turnover-buyer.sum-vat-doc-base   / v-base-scale * v-base-rate
.

  display tt-turnover-buyer.sum-acc-rubl
          tt-turnover-buyer.sum-doc-rubl
          tt-turnover-buyer.sum-vat-acc-rubl
          tt-turnover-buyer.sum-vat-doc-rubl
          with frame {&frame-name} .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-r-b
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-r-b Dialog-Frame
ON CHOOSE OF B-r-b IN FRAME Dialog-Frame /* >> */
DO:





assign
  tt-turnover-buyer.sum-acc-rubl
  tt-turnover-buyer.sum-doc-rubl
  tt-turnover-buyer.sum-vat-acc-rubl
  tt-turnover-buyer.sum-vat-doc-rubl
  tt-turnover-buyer.sum-acc-base     =  tt-turnover-buyer.sum-acc-rubl       / v-base-rate * v-base-scale
  tt-turnover-buyer.sum-doc-base     =  tt-turnover-buyer.sum-doc-rubl       / v-base-rate * v-base-scale
  tt-turnover-buyer.sum-vat-acc-base =  tt-turnover-buyer.sum-vat-acc-rubl   / v-base-rate * v-base-scale
  tt-turnover-buyer.sum-vat-doc-base =  tt-turnover-buyer.sum-vat-doc-rubl   / v-base-rate * v-base-scale
.

  display tt-turnover-buyer.sum-acc-base
          tt-turnover-buyer.sum-doc-base
          tt-turnover-buyer.sum-vat-acc-base
          tt-turnover-buyer.sum-vat-doc-base
          with frame {&frame-name} .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME r-cli
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL r-cli Dialog-Frame
ON CHOOSE OF r-cli IN FRAME Dialog-Frame /* r-cli */
DO:

  define variable rep-rec2      as recid     no-undo .
  define variable v-host-code   as integer   no-undo .
  define variable v-base-code   as integer   no-undo .
  define variable v-fact-date   as date      no-undo .
  define variable v-shift-date  as date      no-undo .
  define variable v-shift-num   as integer   no-undo .
  define variable v-shift-name  as character no-undo .
  define variable v-user-select as logical   no-undo .
  define variable v-obj-type    as character no-undo .
  define variable v-obj-code    as integer   no-undo .

  assign
    v-base-rate  =  ?
    v-base-scale =  ?
    v-base-abbr  =  ""
  .

  { gbl/uobjsone.i
    parparentproc
    v-cntxt-db-num
    v-cntxt-userid
    v-cntxt-host-code-obj
    v-cntxt-obj-type
    v-cntxt-obj-code
    v-user-select
    v-obj-type
    v-obj-code
  }
  if v-user-select <> true
  then do:
    return no-apply .
  end.

  define buffer buf_obj-clients for ub.clients  .
  find first buf_obj-clients no-lock
    where buf_obj-clients.obj-type = v-obj-type
      and buf_obj-clients.obj-code = v-obj-code
    no-error .
  if available buf_obj-clients then do :
    { gbl/hostcode.i buf_obj-clients.obj-type buf_obj-clients.obj-code v-host-code no-error }
    { gbl/basecode.i v-host-code v-base-code no-error }
    { gbl/curobjdt.i buf_obj-clients.obj-type buf_obj-clients.obj-code v-fact-date no-error }
    { gbl/curshift.i buf_obj-clients.obj-type buf_obj-clients.obj-code v-shift-date v-shift-num v-shift-name no-error }
    if error-status :error then
       hide tt-turnover-buyer.shift-date  tt-turnover-buyer.shift-num  tt-turnover-buyer.shift-name r-shift in frame {&frame-name} .
    { gbl/exchrate.i
      v-base-code
      today
      v-base-rate
      v-base-scale
      v-base-abbr no-error }
  end.

  {&OPEN-QUERY-Dialog-Frame}
  GET FIRST Dialog-Frame.

  Display buf_obj-clients.obj-code @ tt-turnover-buyer.obj-code
          buf_obj-clients.obj-type @ tt-turnover-buyer.obj-type
          buf_obj-clients.obj-name @ obj-clients.obj-name
          v-base-rate
          v-base-scale
          v-base-abbr
          v-fact-date   @ tt-turnover-buyer.fact-date
          v-shift-date  @ tt-turnover-buyer.shift-date
          v-shift-num   @ tt-turnover-buyer.shift-num
          v-shift-name  @ tt-turnover-buyer.shift-name
          r-shift   when v-shift-date <> ?
          with frame {&frame-name} .

    { gbl/curshift.i buf_obj-clients.obj-type buf_obj-clients.obj-code v-shift-date v-shift-num v-shift-name no-error }
    if error-status :error then
       hide tt-turnover-buyer.shift-date  tt-turnover-buyer.shift-num  tt-turnover-buyer.shift-name r-shift in frame {&frame-name} .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME r-shift
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL r-shift Dialog-Frame
ON CHOOSE OF r-shift IN FRAME Dialog-Frame
DO:
{ gbl/stdbtn.i }
  define buffer bf_shift-obj   for ub.shift-obj.
  define variable varrid-list as character no-undo.
  define variable varrecid    as recid     no-undo.
  assign
    varrid-list = "".
    assign tt-turnover-buyer.obj-type tt-turnover-buyer.obj-code .
  run str/sht-all.w
   ( input parparentproc,
     input v-cntxt-obj-type,
     input v-cntxt-obj-code,
     input 'b-sel',
     input 'obj',
     input tt-turnover-buyer.obj-type,
     input tt-turnover-buyer.obj-code,
     input '':U,
     input-output varrid-list)
     no-error.
  if error-status:error or varrid-list = "":u then do:
    return no-apply.
  end.
  else do:
    assign
      varrecid = integer (entry(1, varrid-list)).
    find first bf_shift-obj where recid(bf_shift-obj) = varrecid no-lock no-error.
    if available bf_shift-obj then do:
      assign
        tt-turnover-buyer.fact-date  = bf_shift-obj.shift-date
        tt-turnover-buyer.shift-date = bf_shift-obj.shift-date
        tt-turnover-buyer.shift-num  = bf_shift-obj.shift-num
        tt-turnover-buyer.shift-name = bf_shift-obj.shift-name.
      display tt-turnover-buyer.fact-date tt-turnover-buyer.shift-date tt-turnover-buyer.shift-num tt-turnover-buyer.shift-name with frame {&frame-name}.
     end.
END.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.
{ gbl/app_help.i }
{ gbl/ed_date.i tt-turnover-buyer.fact-date }
/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

  if p-mode = {&add-def}  then  run my-enable-add .
                          else run my-enable .
  WAIT-FOR GO OF FRAME {&FRAME-NAME} FOCUS tt-turnover-buyer.des.
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

  {&OPEN-QUERY-Dialog-Frame}
  GET FIRST Dialog-Frame.
  DISPLAY v-rubl-abbr v-base-abbr v-base-rate v-base-scale
      WITH FRAME Dialog-Frame.
  IF AVAILABLE buy-clients THEN
    DISPLAY buy-clients.obj-name
      WITH FRAME Dialog-Frame.
  IF AVAILABLE obj-clients THEN
    DISPLAY obj-clients.obj-name
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-turnover-buyer THEN
    DISPLAY tt-turnover-buyer.des tt-turnover-buyer.fact-date
          tt-turnover-buyer.shift-date tt-turnover-buyer.shift-num
          tt-turnover-buyer.shift-name tt-turnover-buyer.sum-doc-rubl
          tt-turnover-buyer.sum-doc-base tt-turnover-buyer.sum-acc-rubl
          tt-turnover-buyer.sum-acc-base tt-turnover-buyer.sum-vat-doc-rubl
          tt-turnover-buyer.sum-vat-doc-base tt-turnover-buyer.sum-vat-acc-rubl
          tt-turnover-buyer.sum-vat-acc-base tt-turnover-buyer.cli-code
          tt-turnover-buyer.cli-type tt-turnover-buyer.obj-code
          tt-turnover-buyer.obj-type
      WITH FRAME Dialog-Frame.
  ENABLE B-Cancel B-save B-Help RECT-1 tt-turnover-buyer.des r-cli
         tt-turnover-buyer.fact-date tt-turnover-buyer.sum-doc-rubl
         tt-turnover-buyer.sum-doc-base B-r-b tt-turnover-buyer.sum-acc-rubl
         tt-turnover-buyer.sum-acc-base B-b-r
         tt-turnover-buyer.sum-vat-doc-rubl tt-turnover-buyer.sum-vat-doc-base
         tt-turnover-buyer.sum-vat-acc-rubl tt-turnover-buyer.sum-vat-acc-base
         tt-turnover-buyer.cli-code tt-turnover-buyer.cli-type
         buy-clients.obj-name tt-turnover-buyer.obj-code
         tt-turnover-buyer.obj-type obj-clients.obj-name v-rubl-abbr
         v-base-abbr v-base-rate v-base-scale
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-enable Dialog-Frame
PROCEDURE my-enable :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
define variable g-log as logical   no-undo .
define buffer buf_turnover-buyer for ub.turnover-buyer  .
define variable v-shift-date  as date     no-undo .
define variable v-shift-num   as integer  no-undo .
define variable v-shift-name as character no-undo.

  define variable v-use-grp-buy           as logical   no-undo .
  define variable v-use-oborot-buy        as logical   no-undo .
  define variable v-use-qnty-group        as logical   no-undo .
  define variable v-use-sum-group         as logical   no-undo .
  define variable v-use-add-code          as logical   no-undo .
  define variable v-use-sys-date-time     as logical   no-undo .
  define variable v-use-shift-date-num    as logical   no-undo .
  define variable v-use-cassa             as logical   no-undo .
  define variable v-use-val               as logical   no-undo .
  define variable v-use-pay-type          as logical   no-undo .
  define variable v-use-cash-pay          as logical   no-undo .
  define variable v-use-child as logical   no-undo .
  { gbl/glstall.i
    v-use-grp-buy
    v-use-oborot-buy
    v-use-qnty-group
    v-use-sum-group
    v-use-add-code
    v-use-sys-date-time
    v-use-shift-date-num
    v-use-cassa
    v-use-val
    v-use-pay-type
    v-use-cash-pay
    v-use-child
    }
/* А надо ли ?*/
if not ( v-use-grp-buy or v-use-oborot-buy )  then do:
       message "Не заданы глобальные настройки ценообразования !!!" view-as alert-box error .
       return error return-value .
    end.


  for each tt-turnover-buyer : delete tt-turnover-buyer . end.
  if p-mode = {&lookup}
    then  find first buf_turnover-buyer no-lock where        recid(buf_turnover-buyer) = p-recid no-error .
    else  find first buf_turnover-buyer exclusive-lock where recid(buf_turnover-buyer) = p-recid no-error .


  create tt-turnover-buyer.
     BUFFER-COPY buf_turnover-buyer TO tt-turnover-buyer
  .
define variable v-host-code as integer   no-undo .
define variable v-base-code as integer   no-undo .
v-rubl-abbr = "{&abbr_rub_allshift}" .
{ gbl/hostcode.i  tt-turnover-buyer.obj-type tt-turnover-buyer.obj-code v-host-code }
{ gbl/basecode.i v-host-code v-base-code }
{ gbl/exchrate.i
  v-base-code
  today
  v-base-rate
  v-base-scale
  v-base-abbr }

  {&OPEN-QUERY-Dialog-Frame}
  GET FIRST Dialog-Frame.
  DISPLAY v-rubl-abbr v-base-abbr v-base-rate v-base-scale
      WITH FRAME Dialog-Frame.
  IF AVAILABLE buy-clients THEN
    DISPLAY buy-clients.obj-name
      WITH FRAME Dialog-Frame.
  IF AVAILABLE obj-clients THEN
    DISPLAY obj-clients.obj-name
      WITH FRAME Dialog-Frame.




  IF AVAILABLE tt-turnover-buyer THEN do:
    DISPLAY tt-turnover-buyer.des tt-turnover-buyer.fact-date
          tt-turnover-buyer.shift-date tt-turnover-buyer.shift-num
          tt-turnover-buyer.shift-name
          tt-turnover-buyer.sum-acc-rubl tt-turnover-buyer.sum-acc-base
          tt-turnover-buyer.sum-doc-rubl tt-turnover-buyer.sum-doc-base
          tt-turnover-buyer.sum-vat-acc-rubl tt-turnover-buyer.sum-vat-acc-base
          tt-turnover-buyer.sum-vat-doc-base tt-turnover-buyer.sum-vat-doc-rubl
          tt-turnover-buyer.cli-code tt-turnover-buyer.cli-type
          tt-turnover-buyer.obj-code tt-turnover-buyer.obj-type
      WITH FRAME Dialog-Frame.

  end.
  if p-mode = {&update}  then
  ENABLE B-Cancel RECT-1 B-save B-Help tt-turnover-buyer.des
         tt-turnover-buyer.sum-acc-rubl
         tt-turnover-buyer.sum-acc-base tt-turnover-buyer.sum-doc-rubl
         tt-turnover-buyer.sum-doc-base tt-turnover-buyer.sum-vat-acc-rubl
         tt-turnover-buyer.sum-vat-acc-base tt-turnover-buyer.sum-vat-doc-base
         tt-turnover-buyer.sum-vat-doc-rubl
         v-rubl-abbr v-base-abbr v-base-rate v-base-scale
      b-r-b b-b-r
      WITH FRAME Dialog-Frame.
      else do:
  ENABLE B-Cancel B-Help
      WITH FRAME Dialog-Frame.
      B-Cancel:label = "&Выход" .
      hide B-save in frame {&frame-name} .
      end.

  if tt-turnover-buyer.shift-date <> ? then do:
     display
     tt-turnover-buyer.shift-date
     tt-turnover-buyer.shift-num
     tt-turnover-buyer.shift-name
     with frame {&frame-name} .
  end.
  else do:
     hide
     tt-turnover-buyer.shift-date
     tt-turnover-buyer.shift-num
     tt-turnover-buyer.shift-name
     in frame {&frame-name} .
  end.


   ASSIGN frame {&frame-name}:TITLE = "Обороты покупателя  "   + buy-clients.obj-name
   + " - " + caps(p-mode).

  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-enable-add Dialog-Frame
PROCEDURE my-enable-add :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
define buffer buf_global-state for ub.global-state  .
define variable g-log as logical   no-undo .
define buffer buf_turnover-buyer for ub.turnover-buyer  .

find last buf_global-state no-lock  no-error .
    if error-status :error then do:
       message "Не заданы глобальные настройки ценообразования !!!" view-as alert-box error .
       return error return-value .
    end.

   find first buf_turnover-buyer no-lock where recid(buf_turnover-buyer) = p-recid no-error .



for each tt-turnover-buyer : delete tt-turnover-buyer . end.
  create tt-turnover-buyer.
     assign
        tt-turnover-buyer.cli-code  = p-cli-code
        tt-turnover-buyer.cli-type  = p-cli-type
        tt-turnover-buyer.sum-type   = ""
        tt-turnover-buyer.type       = 1
     .

  {&OPEN-QUERY-Dialog-Frame}
  GET FIRST Dialog-Frame.

define variable v-host-code as integer   no-undo .
define variable v-base-code as integer   no-undo .
v-rubl-abbr = "{&abbr_rub_allshift}" .
/*
{ gbl/hostcode.i  tt-turnover-buyer.obj-type tt-turnover-buyer.obj-code v-host-code }
{ gbl/basecode.i v-host-code v-base-code }
{ gbl/exchrate.i
  v-base-code
  today
  v-base-rate
  v-base-scale
  v-base-abbr }
  */

  DISPLAY v-rubl-abbr v-base-abbr v-base-rate v-base-scale
      WITH FRAME Dialog-Frame.
  IF AVAILABLE buy-clients THEN
    DISPLAY buy-clients.obj-name
      WITH FRAME Dialog-Frame.
  IF AVAILABLE obj-clients THEN
    DISPLAY obj-clients.obj-name
      WITH FRAME Dialog-Frame.

  IF AVAILABLE tt-turnover-buyer THEN do:
    DISPLAY tt-turnover-buyer.des tt-turnover-buyer.fact-date
          tt-turnover-buyer.shift-date tt-turnover-buyer.shift-num
          tt-turnover-buyer.shift-name
          tt-turnover-buyer.sum-acc-rubl tt-turnover-buyer.sum-acc-base
          tt-turnover-buyer.sum-doc-rubl tt-turnover-buyer.sum-doc-base
          tt-turnover-buyer.sum-vat-acc-rubl tt-turnover-buyer.sum-vat-acc-base
          tt-turnover-buyer.sum-vat-doc-base tt-turnover-buyer.sum-vat-doc-rubl
          tt-turnover-buyer.cli-code tt-turnover-buyer.cli-type
          tt-turnover-buyer.obj-code tt-turnover-buyer.obj-type
      WITH FRAME Dialog-Frame.

  end.
  ENABLE B-Cancel RECT-1 B-save B-Help tt-turnover-buyer.des r-shift
         tt-turnover-buyer.fact-date
         r-cli tt-turnover-buyer.sum-acc-rubl
         tt-turnover-buyer.sum-acc-base tt-turnover-buyer.sum-doc-rubl
         tt-turnover-buyer.sum-doc-base tt-turnover-buyer.sum-vat-acc-rubl
         tt-turnover-buyer.sum-vat-acc-base tt-turnover-buyer.sum-vat-doc-base
         tt-turnover-buyer.sum-vat-doc-rubl tt-turnover-buyer.cli-code
         tt-turnover-buyer.cli-type buy-clients.obj-name
         tt-turnover-buyer.obj-code tt-turnover-buyer.obj-type
          b-r-b b-b-r
         obj-clients.obj-name v-rubl-abbr v-base-abbr v-base-rate v-base-scale
      WITH FRAME Dialog-Frame.

  if buf_global-state.pl-use-shift-date-num  = false then do:
     tt-turnover-buyer.shift-date = ? .
     tt-turnover-buyer.shift-num  = ? .
     tt-turnover-buyer.shift-name = ? .

     hide
     tt-turnover-buyer.shift-date
     tt-turnover-buyer.shift-num
     tt-turnover-buyer.shift-name
      r-shift
     in frame {&frame-name} .

  end.

   ASSIGN frame {&frame-name}:TITLE = "Обороты покупателя  "   + buy-clients.obj-name
   + " - " + caps(p-mode).

  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}

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

ASSIGN frame {&frame-name}
 tt-turnover-buyer.des tt-turnover-buyer.fact-date tt-turnover-buyer.obj-code tt-turnover-buyer.obj-type tt-turnover-buyer.shift-date tt-turnover-buyer.shift-num tt-turnover-buyer.sum-acc-base tt-turnover-buyer.sum-acc-rubl tt-turnover-buyer.sum-doc-base tt-turnover-buyer.sum-doc-rubl tt-turnover-buyer.sum-vat-acc-base tt-turnover-buyer.sum-vat-acc-rubl tt-turnover-buyer.sum-vat-doc-base tt-turnover-buyer.sum-vat-doc-rubl
 tt-turnover-buyer.shift-name
 .

   define variable v-fact-order  as decimal   no-undo .
   define variable v-fact-time as decimal   no-undo .
   define variable v-shift-end-fact-order as decimal   no-undo .
   define variable v-day-end-fact-order  as decimal   no-undo .
   define variable l-shift-on as logical   no-undo .
    { gbl/objat.i
      tt-turnover-buyer.obj-type
      tt-turnover-buyer.obj-code
      "'shift-on=request'"
      l-shift-on
      no-error
      }
      if error-status :error then return error "Неопределена дата на объекте " + return-value .
      v-fact-time = time .

      run factord in this-procedure
        (input  tt-turnover-buyer.fact-date            /* p-fact-date            */
        ,input  v-fact-time            /* p-fact-time            */
        ,input  1                      /* p-fact-num     вместо номера документа время запроса  */
        ,input  tt-turnover-buyer.shift-date             /* p-shift-date           */
        ,input  tt-turnover-buyer.shift-num              /* p-shift-num            */
        ,input  l-shift-on             /* p-shift-on             */
        ,output v-fact-order           /* p-fact-order           */
        ,output v-shift-end-fact-order /* p-shift-end-fact-order */
        ,output v-day-end-fact-order   /* p-day-end-fact-order   */
        ) no-error .

    if p-mode = {&add-def}  then do:
          find first ub.shift-obj where ub.shift-obj.obj-type   = tt-turnover-buyer.obj-type   and
                                        ub.shift-obj.obj-code   = tt-turnover-buyer.obj-code   and
                                        ub.shift-obj.shift-date = tt-turnover-buyer.shift-date and
                                        ub.shift-obj.shift-num  = tt-turnover-buyer.shift-num  no-lock no-error .

       find first ub.turnover-buyer no-lock WHERE
              ub.turnover-buyer.cli-code    = tt-turnover-buyer.cli-code AND
              ub.turnover-buyer.cli-type    = tt-turnover-buyer.cli-type AND
              ub.turnover-buyer.obj-code    = tt-turnover-buyer.obj-code and
              ub.turnover-buyer.obj-type    = tt-turnover-buyer.obj-type and
              ub.turnover-buyer.fact-order  = v-fact-order  no-error .

         if available ub.turnover-buyer then do:
            if l-shift-on then return error "На начало смены " + string(ub.turnover-buyer.shift-date) + "№ " + string(ub.turnover-buyer.shift-name) +  " уже есть оборот " .
            else return error "На начало дня  " + string(ub.turnover-buyer.fact-date) + " уже есть оборот " .
         end.
          create ub.turnover-buyer.
          assign
              ub.turnover-buyer.cli-code    = tt-turnover-buyer.cli-code
              ub.turnover-buyer.cli-type    = tt-turnover-buyer.cli-type
              ub.turnover-buyer.fact-date   = tt-turnover-buyer.fact-date
              ub.turnover-buyer.fact-order  = v-fact-order
              ub.turnover-buyer.obj-code    = tt-turnover-buyer.obj-code
              ub.turnover-buyer.obj-type    = tt-turnover-buyer.obj-type
              ub.turnover-buyer.shift-date  = tt-turnover-buyer.shift-date
              ub.turnover-buyer.shift-num   = tt-turnover-buyer.shift-num
              ub.turnover-buyer.shift-name  = if available ub.shift-obj then ub.shift-obj.shift-name else ""
              ub.turnover-buyer.type        = 1
              ub.turnover-buyer.qnty-check  = 0
              ub.turnover-buyer.qnty-check-itog  = 0
              ub.turnover-buyer.qnty-doc-itog  = 0
              ub.turnover-buyer.d-card    = ""
              ub.turnover-buyer.inkas-code = ""
          .
    end.
    else do:
      find first ub.turnover-buyer exclusive-lock where recid(ub.turnover-buyer) = p-recid no-error .
      if error-status :error then message
        vss-workfile vss-revision vss-description skip
        error-status :get-message(1) skip
        return-value skip
        ""
        view-as alert-box error
      .
    end.

assign
  ub.turnover-buyer.sum-acc-base     = tt-turnover-buyer.sum-acc-base
  ub.turnover-buyer.sum-acc-rubl     = tt-turnover-buyer.sum-acc-rubl
  ub.turnover-buyer.sum-doc-base     = tt-turnover-buyer.sum-doc-base
  ub.turnover-buyer.sum-doc-rubl     = tt-turnover-buyer.sum-doc-rubl
  ub.turnover-buyer.sum-vat-acc-base = tt-turnover-buyer.sum-vat-acc-base
  ub.turnover-buyer.sum-vat-acc-rubl = tt-turnover-buyer.sum-vat-acc-rubl
  ub.turnover-buyer.sum-vat-doc-base = tt-turnover-buyer.sum-vat-doc-base
  ub.turnover-buyer.sum-vat-doc-rubl = tt-turnover-buyer.sum-vat-doc-rubl
  ub.turnover-buyer.sys-date         = today
  ub.turnover-buyer.sys-time         = time
  ub.turnover-buyer.sys-time-char    = string ( ub.turnover-buyer.sys-time,"hh:mm" )
  ub.turnover-buyer.des              = tt-turnover-buyer.des
  p-recid                            = recid ( ub.turnover-buyer )
.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME