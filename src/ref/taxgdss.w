&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER LAST_tax-rate-gds FOR ub.tax-rate-gds.
DEFINE NEW SHARED BUFFER X_goods FOR ub.goods.
DEFINE BUFFER X_tax-rate-gds FOR ub.tax-rate-gds.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Справочник ставки-товары

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/14/05
Author: Bakhtadze Natalya
Creation date: 09/14/05

*/

/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .
DEFINE INPUT PARAMETER BTTNS AS CHAR NO-UNDO.
define input parameter p-list-mode as character no-undo .
define input parameter p-tax-code as integer no-undo .
define input parameter p-rate-code as integer no-undo .
DEFINE INPUT-OUTPUT PARAMETER p-rid-list As character NO-UNDO. /* фиктивный параметр для вызовов процедур*/

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Справочник ставки-товары по налогу" .
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/showinf.i }
{ gbl/flt-def.i }
{ gbl/cur-time.i }
{ trg/factord.i }
{ gbl/fltfield.i }
{ gbl/waitfram.i }
{ gbl/fltopend.i defproc }

define variable ri as recid no-undo.

define variable v-rid-list as character no-undo .
define variable filter-label as character no-undo init "Товары по ставкам налога" .
define variable filter-label0 as character no-undo init "Товары по ставкам налога" .
define variable filter-point as character no-undo init "taxgdss" .
define variable filter-point0 as character no-undo init "taxgdss".

define variable my-fact-order like ub.tax-rate-gds.fact-order no-undo.
define variable gds-rec as recid no-undo .
define variable lns-cnt as integer no-undo .
define variable line-rec as recid no-undo .
{ cmp/gds-list.i gds-list def "new shared" }

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
&Scoped-define INTERNAL-TABLES X_goods X_tax-rate-gds LAST_tax-rate-gds

/* Definitions for BROWSE BR-tax-rate-gds                               */
&Scoped-define FIELDS-IN-QUERY-BR-tax-rate-gds X_tax-rate-gds.gds-code X_goods.artic X_goods.prod-code X_goods.prod-type X_goods.gds-name X_tax-rate-gds.fact-date X_tax-rate-gds.rate-code X_tax-rate-gds.tax-code
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-tax-rate-gds
&Scoped-define SELF-NAME BR-tax-rate-gds
&Scoped-define QUERY-STRING-BR-tax-rate-gds FOR EACH X_goods NO-LOCK, ~
             FIRST X_tax-rate-gds OF X_goods NO-LOCK, ~
             FIRST LAST_tax-rate-gds OF X_goods NO-LOCK
&Scoped-define OPEN-QUERY-BR-tax-rate-gds OPEN QUERY {&SELF-NAME} FOR EACH X_goods NO-LOCK, ~
             FIRST X_tax-rate-gds OF X_goods NO-LOCK, ~
             FIRST LAST_tax-rate-gds OF X_goods NO-LOCK.
&Scoped-define TABLES-IN-QUERY-BR-tax-rate-gds X_goods X_tax-rate-gds ~
LAST_tax-rate-gds
&Scoped-define FIRST-TABLE-IN-QUERY-BR-tax-rate-gds X_goods
&Scoped-define SECOND-TABLE-IN-QUERY-BR-tax-rate-gds X_tax-rate-gds
&Scoped-define THIRD-TABLE-IN-QUERY-BR-tax-rate-gds LAST_tax-rate-gds


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BR-tax-rate-gds}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit B-sel B-save B-sch B-Help ~
BR-tax-rate-gds

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

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Выход "
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-save
     LABEL "&Список"
     SIZE 10 BY 1.

DEFINE BUTTON B-sch
     LABEL "&Фильтр"
     SIZE 3 BY 1.

DEFINE BUTTON B-sel AUTO-GO
     LABEL "Вы&бор "
     SIZE 10 BY 1.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-tax-rate-gds FOR
      X_goods,
      X_tax-rate-gds,
      LAST_tax-rate-gds SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-tax-rate-gds
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-tax-rate-gds Dialog-Frame _FREEFORM
  QUERY BR-tax-rate-gds NO-LOCK DISPLAY
      X_tax-rate-gds.gds-code FORMAT "999999999":U
X_goods.artic FORMAT "X(16)":U
X_goods.prod-code FORMAT ">>>>>>>>9":U
X_goods.prod-type FORMAT "X(3)":U
X_goods.gds-name FORMAT "X(48)":U
X_tax-rate-gds.fact-date FORMAT "99/99/9999":U
X_tax-rate-gds.rate-code COLUMN-LABEL "Код!ставки" FORMAT ">>9":U
X_tax-rate-gds.tax-code COLUMN-LABEL "Код!налога" FORMAT "9":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 17.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-sel AT ROW 1 COL 11
     B-save AT ROW 1 COL 21
     B-sch AT ROW 1 COL 92
     B-Help AT ROW 1 COL 95
     BR-tax-rate-gds AT ROW 3.5 COL 1
     SPACE(0.00) SKIP(0.09)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Товары по ставкам налогов"
         DEFAULT-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: LAST_tax-rate-gds B "?" ? ub tax-rate-gds
      TABLE: X_goods B "NEW SHARED" ? ub goods
      TABLE: X_tax-rate-gds B "?" ? ub tax-rate-gds
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

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-tax-rate-gds
/* Query rebuild information for BROWSE BR-tax-rate-gds
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH X_goods NO-LOCK,
      FIRST X_tax-rate-gds OF X_goods NO-LOCK,
      FIRST LAST_tax-rate-gds OF X_goods NO-LOCK.
     _END_FREEFORM
     _Options          = "NO-LOCK"
     _TblOptList       = ", FIRST, FIRST"
     _Query            is OPENED
*/  /* BROWSE BR-tax-rate-gds */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Товары по ставкам налогов */
DO:
  p-rid-list = v-rid-list.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Товары по ставкам налогов */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-save
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-save Dialog-Frame
ON CHOOSE OF B-save IN FRAME Dialog-Frame /* Список */
DO:
  run proc-b-list in this-procedure no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-sch
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-sch Dialog-Frame
ON CHOOSE OF B-sch IN FRAME Dialog-Frame /* Фильтр */
DO:
  assign
  tbl = "goods"
  join-tbl = "X_goods"
  fld = '':U
  lab = '':U
  spr = '':U
  dim = '0':U
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
  DO on stop undo, leave:
      run gbl/filter.w ( input parparentproc
                        ,input (filter-point + {&delim-par} + filter-label)
                        ,input tbl
                        ,input join-tbl
                        ,input fld
                        ,input lab
                        ,input spr
                        ,input dim).
      RUN OpenBr in this-procedure  ( input yes, input no, input '':U).
  END .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-sel Dialog-Frame
ON CHOOSE OF B-sel IN FRAME Dialog-Frame /* Выбор  */
DO:
  v-rid-list = string(RECID(X_goods)).
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
{ gbl/f2.i br-tax-rate-gds " " " "  parparentproc X_goods }

{ gbl/hot-key.i b-sel }
&scop b-quit ~{&b-exit~}
{ gbl/hot-key.i b-quit }



{ gbl/setfltnm.i }


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  v-rid-list = p-rid-list.
  RUN MyEnable in this-procedure .
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
  ENABLE b-quit B-sel B-save B-sch B-Help BR-tax-rate-gds
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
CASE p-list-mode:
    when "TAX":U then do:
        FIND FIRST ub.tax NO-LOCK where ub.tax.tax-code = p-tax-code NO-ERROR.
    END.
    when "TAX-RATE":U then do:
        FIND FIRST ub.tax-rate NO-LOCK
                 where ub.tax-rate.rate-code = p-rate-code
                 and ub.tax-rate.tax-code = p-tax-code
                 NO-ERROR.
    END.
END case.
ENABLE
b-quit
B-sel when can-do(bttns, "b-sel")
B-Help
b-sch
b-save
BR-tax-rate-gds
WITH FRAME {&frame-name}.
VIEW FRAME {&frame-name}.
Run OpenBr in this-procedure  ( input yes, input no, input '':U).
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Openbr Dialog-Frame
PROCEDURE Openbr :
define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
run cur-time in this-procedure(output v-today, output v-time).
run factord-end-day in this-procedure (input v-today, output my-fact-order).

define variable l-query-was-opened as logical no-undo .

run waitfram-show in this-procedure ( input "Ждите...").


&scop flt-open-open-query  OPEN QUERY br-tax-rate-gds FOR EACH X_goods

&scop flt-open-dyn_open-query  FOR EACH X_goods

&scop flt-open-query-handle  QUERY br-tax-rate-gds:handle

&scop flt-open-query-was-opened  l-query-was-opened

&scop flt-open-sort-column-phrase

&scop flt-open-call-point filter-point

&scop flt-open-set-filter-name set-filter-name

&scop flt-open-indexed-reposition

&scop flt-open-waitfram yes

CASE p-list-mode:
    when "TAX":U then do:
        ASSIGN
        frame {&frame-name}:TITLE = substitute("Товары по налогу с кодом &1 (&2)"
                                               ,p-tax-code
                                               ,ub.tax.tax-name)
        filter-point = " " + p-list-mode
        filter-label = substitute("&1 Один налог", filter-label0)
        .
          { gbl/fltopend.i
            &flt-open-open-query-tail = " NO-LOCK,  LAST X_tax-rate-gds NO-LOCK where ~
                                                    X_tax-rate-gds.gds-code = X_goods.gds-code AND ~
                                                    X_tax-rate-gds.tax-code = p-tax-code AND ~
                                                    X_tax-rate-gds.fact-order <= my-fact-order, ~
                                                    FIRST LAST_tax-rate-gds No-LOCK where ~
                                                    recid(LAST_tax-rate-gds) = recid(X_tax-rate-gds) "
            &flt-open-dyn_open-query-tail = " substitute(' NO-LOCK,  LAST X_tax-rate-gds NO-LOCK where ~
                                                    X_tax-rate-gds.gds-code = X_goods.gds-code AND ~
                                                    X_tax-rate-gds.tax-code = &1 AND ~
                                                    X_tax-rate-gds.fact-order <= &2, ~
                                                    FIRST LAST_tax-rate-gds No-LOCK where ~
                                                    recid(LAST_tax-rate-gds) = recid(X_tax-rate-gds) ', p-tax-code, my-fact-order)"


            &where-cond = " TRUE "
            &use-ind = "  "
            &by = " BY X_goods.gds-code BY X_tax-rate-gds.rate-code "
          }
    end.
    when "TAX-RATE":U then do:
        ASSIGN
        frame {&frame-name}:TITLE = substitute("Товары по ставке налога с кодом &1 (&2) - налог &3"
                                                ,p-rate-code
                                                ,ub.tax-rate.rate-name
                                                ,p-tax-code)
        filter-point = " " + p-list-mode
        filter-label = substitute("&1 Одна ставка", filter-label0)
        .
          { gbl/fltopend.i

            &flt-open-open-query-tail = " NO-LOCK,  LAST X_tax-rate-gds NO-LOCK where ~
                                                    X_tax-rate-gds.gds-code = X_goods.gds-code AND ~
                                                    X_tax-rate-gds.tax-code = p-tax-code AND ~
                                                    X_tax-rate-gds.fact-order <= my-fact-order, ~
                                                    FIRST LAST_tax-rate-gds No-LOCK where ~
                                                    recid(LAST_tax-rate-gds) = recid(X_tax-rate-gds) AND ~
                                                    LAST_tax-rate-gds.rate-code = p-rate-code "
            &flt-open-dyn_open-query-tail = " substitute('NO-LOCK,  LAST X_tax-rate-gds NO-LOCK where ~
                                                    X_tax-rate-gds.gds-code = X_goods.gds-code AND ~
                                                    X_tax-rate-gds.tax-code = &1 AND ~
                                                    X_tax-rate-gds.fact-order <= &2, ~
                                                    FIRST LAST_tax-rate-gds No-LOCK where ~
                                                    recid(LAST_tax-rate-gds) = recid(X_tax-rate-gds) AND ~
                                                    LAST_tax-rate-gds.rate-code = &3 ', p-tax-code, my-fact-order, p-rate-code)"

            &where-cond = " TRUE "
            &use-ind = "  "
            &by = " BY X_goods.gds-code "
          }
    end.
END CASE.
run waitfram-hide in this-procedure .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-list Dialog-Frame
PROCEDURE proc-b-list :
define variable f-name as character no-undo.
define variable v-gds-rec as recid no-undo.
define variable glog as logical no-undo .
define buffer buf_goods for ub.goods.
message
"Сохранить список товаров в файл в формате списка товаров?"
view-as alert-box question buttons YEs-NO update glog.
if not glog then return error.
assign
v-gds-rec = recid(X_tax-rate-gds).
assign
  f-name = "default.gds"
  glog = yes
  .
system-dialog get-file f-name
  filters "Списки товаров *.gds" "*.gds"
  ask-overwrite
  save-as
  use-filename
  update glog
  default-extension "gds".
if not glog then do:
  return.
end.
run waitfram-show in this-procedure ("Ждите...").
DO WHILE available X_tax-rate-gds :
    GET prev br-tax-rate-gds.
END.
GET next br-tax-rate-gds.
output to value (f-name).
output close.
DO WHILE available X_tax-rate-gds :
    find first buf_goods no-lock where
                 buf_goods.gds-code = X_tax-rate-gds.gds-code no-error.
    if available buf_goods then do:
      { cmp/gds-list.i gds-list assign " " buf_goods }
      output to value (f-name) append.
      export
      gds-list.prod-type
      gds-list.prod-code
      gds-list.artic
      .
      output close.
      delete gds-list.
    end.
  GET next br-tax-rate-gds.
END.
run waitfram-hide in this-procedure .
reposition br-tax-rate-gds to recid v-gds-rec no-error .
APPLY "ENTRY" to br-tax-rate-gds in frame {&frame-name}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME