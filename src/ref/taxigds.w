&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER X_goods FOR ub.goods.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Справочник товаров по индивидуальным налогам

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/14/05
Author: Bakhtadze Natalya
Creation date: 09/14/05

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .
DEFINE INPUT PARAMETER BTTNS AS CHAR NO-UNDO.
define input parameter p-list-mode as character no-undo .
define input parameter p-tax-code as integer no-undo .
DEFINE INPUT-OUTPUT PARAMETER p-rid-list As character NO-UNDO. /* фиктивный параметр для вызовов процедур */

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Справочник товаров по индивидуальным налогам" .
{ cmp/vssrevis.i }
{ cmp/str-glbl.i  }
{ cmp/showinf.i }
{ cmp/library.i }
{ gbl/flt-def.i  }
{ cmp/croslist.i }
{ gbl/fltfield.i }
{ gbl/waitfram.i }
{ gbl/fltopend.i defproc }

define variable gds-rec as recid no-undo .
DEFINE TEMP-TABLE tt-units no-undo
LIKE ub.units
.
define variable v-rid-list as character no-undo .
DEFINE BUFFER t-units for tt-units.

define variable filter-label as character no-undo init "Товары по индивидуальному налогу" .
define variable filter-label0 as character no-undo init "Товары по индивидуальному налогу" .
define variable filter-point as character no-undo init "taxigds".
define variable filter-point0 as character no-undo init "taxigds".

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BR-tax-rate-gds

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES t-units X_goods

/* Definitions for BROWSE BR-tax-rate-gds                               */
&Scoped-define FIELDS-IN-QUERY-BR-tax-rate-gds X_goods.gds-code X_goods.artic X_goods.prod-type X_goods.prod-code X_goods.gds-name t-units.unit-name
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-tax-rate-gds
&Scoped-define SELF-NAME BR-tax-rate-gds
&Scoped-define QUERY-STRING-BR-tax-rate-gds FOR EACH t-units NO-LOCK, ~
             EACH X_goods WHERE TRUE /* Join to units incomplete */       AND X_goods.unit-base = t-units.unit-name NO-LOCK
&Scoped-define OPEN-QUERY-BR-tax-rate-gds OPEN QUERY {&SELF-NAME} FOR EACH t-units NO-LOCK, ~
             EACH X_goods WHERE TRUE /* Join to units incomplete */       AND X_goods.unit-base = t-units.unit-name NO-LOCK.
&Scoped-define TABLES-IN-QUERY-BR-tax-rate-gds t-units X_goods
&Scoped-define FIRST-TABLE-IN-QUERY-BR-tax-rate-gds t-units
&Scoped-define SECOND-TABLE-IN-QUERY-BR-tax-rate-gds X_goods


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BR-tax-rate-gds}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-quit B-sch B-Help BR-tax-rate-gds

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-quit AUTO-END-KEY
     LABEL "&Выход "
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-sch
     LABEL "&Фильтр"
     SIZE 3 BY 1.

DEFINE BUTTON B-sel AUTO-GO
     LABEL "Вы&бор "
     SIZE 10 BY 1.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-tax-rate-gds FOR
      t-units,
      X_goods SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-tax-rate-gds
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-tax-rate-gds Dialog-Frame _FREEFORM
  QUERY BR-tax-rate-gds NO-LOCK DISPLAY
      X_goods.gds-code
X_goods.artic
X_goods.prod-type
X_goods.prod-code
X_goods.gds-name
t-units.unit-name column-label "Ед.!изм"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 97.63 BY 19.92.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-quit AT ROW 1 COL 1
     B-sel AT ROW 1 COL 11
     B-sch AT ROW 1 COL 92
     B-Help AT ROW 1 COL 95
     BR-tax-rate-gds AT ROW 3 COL 1
     SPACE(0.06) SKIP(0.01)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Товары, привязанные к индивидуальному налогу с кодом"
         DEFAULT-BUTTON B-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: X_goods B "?" ? ub goods
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BR-tax-rate-gds B-Help Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR BUTTON B-sel IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-tax-rate-gds
/* Query rebuild information for BROWSE BR-tax-rate-gds
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH t-units NO-LOCK,
      EACH X_goods WHERE TRUE /* Join to units incomplete */
      AND X_goods.unit-base = t-units.unit-name NO-LOCK.
     _END_FREEFORM
     _Options          = "NO-LOCK"
     _Where[2]         = "goods.unit-base = units.unit-name"
     _Query            is OPENED
*/  /* BROWSE BR-tax-rate-gds */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Товары, привязанные к индивидуальному налогу с кодом */
DO:
  p-rid-list = v-rid-list.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Товары, привязанные к индивидуальному налогу с кодом */
DO:
  APPLY "END-ERROR":U TO SELF.
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
ON CHOOSE OF B-sel IN FRAME Dialog-Frame /* Выбор  */
DO:
  v-rid-list = STRING(RECID(X_goods)).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-tax-rate-gds
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.
{ gbl/app_help.i }
{ gbl/setfltnm.i }
{ gbl/f2.i br-tax-rate-gds  " " " " parparentproc X_goods }

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  v-rid-list = p-rid-list.
  RUN MyEnable.
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
  ENABLE B-quit B-sch B-Help BR-tax-rate-gds
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
define buffer buf_units for ub.units.
  CASE p-list-mode:
      when "TAX" then do:
          FIND FIRST ub.tax NO-LOCK where ub.tax.tax-code = p-tax-code NO-ERROR.
      END.
  END case.
  ENABLE
  B-quit
  B-sel when lookup("b-sel", bttns) > 0
  B-Help
  b-sch
  BR-tax-rate-gds
  WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  for each buf_units No-LOCK,
          first ub.tax-units No-LOCK WHERE
                   LOOKUP(ub.tax-units.type, buf_units.type) > 0  AND
                   ub.tax-units.tax-code = p-tax-code:
    create tt-units.
    buffer-copy buf_units to tt-units.
  end.
  Run OpenBr in this-procedure  ( input yes, input no, input '':U).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OpenBr Dialog-Frame
PROCEDURE OpenBr :
define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .

define variable l-query-was-opened as logical no-undo .


run waitfram-show in this-procedure ( input "Ждите...").


&scop flt-open-open-query OPEN QUERY br-tax-rate-gds FOR EACH t-units NO-LOCK, EACH X_goods NO-LOCK

&scop flt-open-dyn_open-query FOR EACH t-units NO-LOCK, EACH X_goods NO-LOCK

&scop flt-open-query-handle  QUERY br-tax-rate-gds:handle

&scop flt-open-open-query-tail

&scop flt-open-query-was-opened  l-query-was-opened

&scop flt-open-sort-column-phrase

&scop flt-open-call-point filter-point

&scop flt-open-set-filter-name set-filter-name

&scop flt-open-indexed-reposition

&scop flt-open-waitfram yes

CASE p-list-mode:
    when "TAX" then do:
        ASSIGN
        frame {&frame-name}:TITLE = substitute("Товары, привязанные к индивидуальному налогу с кодом &1 (&2)"
                                             ,p-tax-code
                                             ,ub.tax.tax-name)
        filter-point = filter-point0 + {&comma-char} + p-list-mode
        filter-label = substitute("&1", filter-label0)
        .
          { gbl/fltopend.i
            &where-cond = " X_goods.unit-base = t-units.unit-name  "
            &use-ind = "  "
            &by = " BY X_goods.artic BY X_goods.prod-type BY X_goods.prod-code "
          }
    end.
END CASE.
run waitfram-hide in this-procedure .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-sch Dialog-Frame
PROCEDURE proc-b-sch :
assign
  tbl = 'goods'
  join-tbl = 'X_goods'
  fld = ""
  lab = ""
  spr = ""
  dim = '0'
  .

run fltfield-add in this-procedure('artic', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('gds-name', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('engl-name', 'Название по-английски', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('prod-type{&delim-flt}prod-code', 'Производитель', 'cli',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('unit-base', '', 'unit',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('unit-cli', '', 'unit',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('grp-name', '', 'gdsgrp',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('prt-root', 'Шкала', 'prt',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('increase-pc', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('qnty-cart', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('wt-cart', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('okdp', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('destin', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('sert', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('struct', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('sort', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('deadline', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('negative-rest', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('cost-calc', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('gds-type', 'Услуга-товар', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('tnved', 'Код ТНВЭД', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('nationality', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('unit-cst', 'Таможенная единица', 'unit',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('alpha1', 'Код страны изготовления', 'country',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('normal-wastage', 'Норма естест.убыли', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('normal-waste', 'Норма отходов', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('min-rate', 'Min кол-во в штуке', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('max-rate', 'Max кол-во в штуке', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.

   DO on stop undo, leave:
        run gbl/filter.w ( input parparentproc
                          ,input (filter-point + {&delim-par} + filter-label)
                          ,input tbl
                          ,input join-tbl
                          ,input fld
                          ,input lab
                          ,input spr
                          ,input dim).
        RUN OpenBr in this-procedure ( input yes, input no, input '':U).
    END .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
