&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v9r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame

/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE tt-temp NO-UNDO LIKE ub.tmp-sale
       field artic         as character
       field prod-code     as integer
       field prod-type     as character
       field gds-name      as character
       field gds-code      as integer
       field trn-doc-code  as char
       field trn-doc-type  as character
       field trn-fact-date as date
       field contract-code as integer
       field uslov         as character
       field cli-type      as character
       field cli-code      as integer
       field cli-name      as character
       field str           as character
       index pi trn-doc-code.
DEFINE TEMP-TABLE tt-trn NO-UNDO LIKE ub.tmp-sale
       field trn-doc-code  as char
       field trn-doc-type  as character
       field trn-fact-date as date
       field cli-type      as character
       field cli-code      as integer
       field cli-name      as character
       index pi trn-doc-code.


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Проверка корректности БД по ФО и НАКЛ на основе партий

Автор: Чернова Светлана Александровна
Дата создания: 04/06/06
Author: Svetlana Chernova
Creation date: 04/06/06


*/

define input parameter parparentproc as handle no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Проверка корректности БД по ФО и НАКЛ на основе партий".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i  }
{ cmp/library.i  }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
{ gbl/waitfram.i }


define variable v-date     as date   no-undo .
define variable v-date2    as date   no-undo .
define variable v-time     as integer no-undo .
define variable v-time2    as integer no-undo .
define variable v-ok as logical no-undo .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BROWSE-3

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-temp tt-trn

/* Definitions for BROWSE BROWSE-3                                      */
&Scoped-define FIELDS-IN-QUERY-BROWSE-3 tt-temp.trn-doc-code tt-temp.contract-code tt-temp.artic tt-temp.gds-name tt-temp.gds-code tt-temp.trn-doc-type tt-temp.uslov tt-temp.str
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-3
&Scoped-define SELF-NAME BROWSE-3
&Scoped-define QUERY-STRING-BROWSE-3 FOR EACH tt-temp NO-LOCK WHERE tt-temp.trn-doc-code =     tt-trn.trn-doc-code INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-BROWSE-3 OPEN QUERY {&SELF-NAME} FOR EACH tt-temp NO-LOCK WHERE tt-temp.trn-doc-code =     tt-trn.trn-doc-code INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-BROWSE-3 tt-temp
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-3 tt-temp


/* Definitions for BROWSE BROWSE-4                                      */
&Scoped-define FIELDS-IN-QUERY-BROWSE-4 tt-trn.trn-doc-code tt-trn.trn-fact-date tt-trn.trn-doc-type tt-trn.cli-type tt-trn.cli-code tt-trn.cli-name
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-4
&Scoped-define SELF-NAME BROWSE-4
&Scoped-define QUERY-STRING-BROWSE-4 FOR EACH tt-trn NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-BROWSE-4 OPEN QUERY {&SELF-NAME} FOR EACH tt-trn NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-BROWSE-4 tt-trn
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-4 tt-trn


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BROWSE-3}~
    ~{&OPEN-QUERY-BROWSE-4}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-Cancel B-fo B-Help BROWSE-4 BROWSE-3

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-Cancel AUTO-END-KEY
     LABEL "Выход"
     SIZE 15 BY 1.13
     BGCOLOR 8 .

DEFINE BUTTON B-fo
     LABEL "ФО"
     SIZE 15 BY 1.13.

DEFINE BUTTON B-Help
     LABEL "&Помощь"
     SIZE 15 BY 1.13
     BGCOLOR 8 .

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BROWSE-3 FOR
      tt-temp SCROLLING.

DEFINE QUERY BROWSE-4 FOR
      tt-trn SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BROWSE-3
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-3 Dialog-Frame _FREEFORM
  QUERY BROWSE-3 NO-LOCK DISPLAY
      tt-temp.artic           FORMAT "X(16)":U        column-label "артикул"
      tt-temp.gds-name        FORMAT "X(20)":U        column-label "Наименование!товара"
      tt-temp.trn-doc-type    FORMAT "X(3)":U         column-label "тип!накл"
      tt-temp.uslov           FORMAT "X(25)":U        column-label "Условие!генерации ФО"
      tt-temp.str             FORMAT "X(60)":U        column-label "Сообщение"
      tt-temp.contract-code   FORMAT ">>>>>>>>>9":U   column-label "№ договора вн."
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 100.5 BY 12.5 EXPANDABLE.

DEFINE BROWSE BROWSE-4
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-4 Dialog-Frame _FREEFORM
  QUERY BROWSE-4 NO-LOCK DISPLAY
      tt-trn.trn-doc-code    FORMAT "X(10)":U        column-label "№ накладной"
      tt-trn.trn-fact-date   FORMAT "99/99/9999":U   column-label "дата!факт"
      tt-trn.trn-doc-type    FORMAT "X(3)":U         column-label "тип!накл"
      tt-trn.cli-type        FORMAT "X(3)":U         column-label "Тип"
      tt-trn.cli-code        FORMAT ">>>>9":U        column-label "Код"
      tt-trn.cli-name        FORMAT "X(20)":U        column-label "Поставщика"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 100 BY 6.75 EXPANDABLE.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-Cancel AT ROW 1.04 COL 1
     B-fo AT ROW 1.04 COL 16.5
     B-Help AT ROW 1.04 COL 86.5
     BROWSE-4 AT ROW 2.25 COL 1
     BROWSE-3 AT ROW 9.46 COL 1
     SPACE(0.37) SKIP(0.16)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Накладные по сгенеренным ФО для разбора"
         CANCEL-BUTTON B-Cancel.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: tt-temp T "?" NO-UNDO ub tmp-sale
      ADDITIONAL-FIELDS:
          field artic         as character
          field prod-code     as integer
          field prod-type     as character
          field gds-name      as character
          field gds-code      as integer
          field trn-doc-code  as char
          field trn-doc-type  as character
          field trn-fact-date as date
          field contract-code as integer
          field uslov         as character
          field cli-type      as character
          field cli-code      as integer
          field cli-name      as character
          field str           as character
          index pi trn-doc-code
      END-FIELDS.
      TABLE: tt-trn T "?" NO-UNDO ub tmp-sale
      ADDITIONAL-FIELDS:
          field trn-doc-code  as char
          field trn-doc-type  as character
          field trn-fact-date as date
          field cli-type      as character
          field cli-code      as integer
          field cli-name      as character
          index pi trn-doc-code
      END-FIELDS.
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
                                                                        */
/* BROWSE-TAB BROWSE-4 B-Help Dialog-Frame */
/* BROWSE-TAB BROWSE-3 BROWSE-4 Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-3
/* Query rebuild information for BROWSE BROWSE-3
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt-temp NO-LOCK WHERE tt-temp.trn-doc-code =
    tt-trn.trn-doc-code INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is OPENED
*/  /* BROWSE BROWSE-3 */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-4
/* Query rebuild information for BROWSE BROWSE-4
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt-trn NO-LOCK INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is OPENED
*/  /* BROWSE BROWSE-4 */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Накладные по сгенеренным ФО для разбора */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-fo
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-fo Dialog-Frame
ON CHOOSE OF B-fo IN FRAME Dialog-Frame /* ФО */
DO:
  if available tt-trn then
  run str/fi-trns.w (
    input parparentproc,
    input v-cntxt-host-code-obj ,
    input ?              ,
    input tt-trn.trn-doc-code ,
    input "trn-doc":U
    ) .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-Help
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-Help Dialog-Frame
ON CHOOSE OF B-Help IN FRAME Dialog-Frame /* Помощь */
OR HELP OF FRAME {&FRAME-NAME}
DO: /* Call Help Function (or a simple message). */

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BROWSE-4
&Scoped-define SELF-NAME BROWSE-4
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BROWSE-4 Dialog-Frame
ON VALUE-CHANGED OF BROWSE-4 IN FRAME Dialog-Frame
DO:
  {&OPEN-QUERY-BROWSE-3}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BROWSE-3
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
  run gbl/d-time.w (
    input "Введите период для обработки накладных"
  , input ?
  , input 2
  , input-output v-date
  , input-output v-date2
  , input-output v-time
  , input-output v-time2
  , output       v-ok
  ) no-error .
if v-ok = false then return .
  ASSIGN frame {&frame-name}:TITLE = "Накладные по сгенеренным ФО для разбора "  + string( v-date , "99/99/9999" ) + " - " + string( v-date2 , "99/99/9999" ) .
  run proc-calc in this-procedure .
  tt-temp.artic        :resizable in browse browse-3 = true .
  tt-temp.gds-name     :resizable in browse browse-3 = true .
  tt-temp.trn-doc-type :resizable in browse browse-3 = true .
  tt-temp.uslov        :resizable in browse browse-3 = true .
  tt-temp.str          :resizable in browse browse-3 = true .

  run enable_ui in this-procedure .
  wait-for go of frame {&frame-name}.
end.
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
  ENABLE B-Cancel B-fo B-Help BROWSE-4 BROWSE-3
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-calc Dialog-Frame
PROCEDURE proc-calc :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/

  do
  on error undo, return error return-value
  :
  define buffer buf_trn-doc for ub.trn-doc .
  define buffer buf_parts   for ub.parts   .
  define buffer fin_parts   for ub.fin-gds-part   .
  define buffer buf_goods   for ub.goods  .
  define buffer buf_fin-ob  for ub.fin-ob  .

run waitfram-show in this-procedure (" Проверка накладных ") .
define variable v-sum as decimal   no-undo .
define variable v-q as integer   no-undo .

  for each buf_trn-doc no-lock where
           buf_trn-doc.host-code  = v-cntxt-host-code-obj and
           buf_trn-doc.fact-date >= v-date and
           buf_trn-doc.fact-date <= v-date2 and
           buf_trn-doc.cr-incorexpfo = true
           :
          for each buf_parts no-lock where
              buf_parts.out-code = buf_trn-doc.doc-code and
              buf_parts.status_  = true  and
              buf_parts.contract-code > 0
              :
              find first ub.contract where
                         ub.contract.host-code     = buf_trn-doc.host-code  and
                         ub.contract.contract-code = buf_parts.contract-code no-error .
              /* соответствие типа документа и типа генерации */
                           if not ((
                            lookup ( ub.contract.usl-opl , {&o-postavka} ) > 0 and
                            lookup ( buf_trn-doc.ext-doc-type , {&in-fo-tdedt}  ) > 0
                            ) OR
                          /* если это по реализации */
                            ( lookup ( ub.contract.usl-opl , {&o-realiz} ) > 0   and
                              lookup ( buf_trn-doc.ext-doc-type , {&ex-fo-tdedt} + {&inv-fo-tdedt} ) > 0
                              ) ) then next.


              find first buf_goods no-lock where
                         buf_goods.artic     = buf_parts.artic        and
                         buf_goods.prod-type = buf_parts.prod-type    and
                         buf_goods.prod-code = buf_parts.prod-code    no-error .
              v-sum = 0.
              v-q = 0.
                 /*      message 333
                       buf_parts.obj-type
                       buf_parts.obj-code
                       buf_parts.out-code
                       buf_goods.gds-code
                       buf_parts.in-code
                       buf_parts.part-code
                       buf_parts.contract-code
                       .
                   */
                    for each  fin_parts no-lock where
                              fin_parts.obj-type  = buf_parts.obj-type   and
                              fin_parts.obj-code  = buf_parts.obj-code   and
                              fin_parts.out-code  = buf_parts.out-code   and
                              fin_parts.gds-code  = buf_goods.gds-code   and
                              fin_parts.in-code   = buf_parts.in-code    and
                              fin_parts.part-code = buf_parts.part-code :
                              /*message "QQ"
                                      buf_trn-doc.host-code
                                      fin_parts.fin-ob-code
                                      .
                                      */
                              find first buf_fin-ob no-lock where
                                        buf_fin-ob.host-code = buf_trn-doc.host-code  and
                                        buf_fin-ob.doc-code  = fin_parts.fin-ob-code /* and
                                        buf_fin-ob.status_   = {&fact}                 */
                                        no-error .
                          /*  message 123
                            buf_parts.obj-type
                            buf_parts.obj-code
                            buf_parts.out-code
                            buf_goods.gds-code
                            buf_parts.in-code
                            buf_parts.part-code
                            .
                            */
                            v-sum = v-sum  + (fin_parts.fact-qnty * ( fin_parts.sum-rubl / abs(fin_parts.sum-rubl))) .
                            v-q = v-q + 1.
                    end.

              if abs ( v-sum ) <> abs ( buf_parts.fact-qnty )  then do:
               /*  message
                 "нет ФО для " skip
                 buf_goods.artic
                 buf_goods.gds-name  skip
                 buf_trn-doc.doc-code buf_trn-doc.doc-type buf_trn-doc.fact-date skip
                 v-sum  buf_parts.fact-qnty        skip
                 "По договору "
                 buf_parts.contract-code
                 ub.contract.str-uslov-oplat
                 ub.contract.usl-opl
                 .  */
                 create tt-temp.
                 assign
                   tt-temp.artic          = buf_goods.artic
                   tt-temp.prod-code      = buf_goods.prod-code
                   tt-temp.prod-type      = buf_goods.prod-type
                   tt-temp.gds-name       = buf_goods.gds-name
                   tt-temp.gds-code       = buf_goods.gds-code
                   tt-temp.trn-doc-code   = buf_trn-doc.doc-code
                   tt-temp.trn-doc-type   = buf_trn-doc.doc-type
                   tt-temp.trn-fact-date  = buf_trn-doc.fact-date
                   tt-temp.contract-code  = buf_parts.contract-code
                   tt-temp.uslov          = ub.contract.usl-opl
                   tt-temp.cli-type       = buf_trn-doc.cli-type
                   tt-temp.cli-code       = buf_trn-doc.cli-code
                   tt-temp.cli-name       = buf_trn-doc.cli-name
                   tt-temp.str            = ( if v-q = 0 then    "нет ФО для партии in-code = " + buf_parts.in-code
                                                         else    "ФО есть, но проверте сумму . Создано ФО: " + string( v-q ) + " штук")
                 .

                 find first tt-trn where tt-trn.trn-doc-code   = buf_trn-doc.doc-code no-error .
                          if not available tt-trn then do:
                              create tt-trn.
                              assign
                                tt-trn.trn-doc-code   = buf_trn-doc.doc-code
                                tt-trn.trn-doc-type   = buf_trn-doc.doc-type
                                tt-trn.trn-fact-date  = buf_trn-doc.fact-date
                                tt-trn.cli-type       = buf_trn-doc.cli-type
                                tt-trn.cli-code       = buf_trn-doc.cli-code
                                tt-trn.cli-name       = buf_trn-doc.cli-name
                                .
                          end.
              end.
          end.
  end.
  end.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
