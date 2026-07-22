&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v9r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER x-gds-obj FOR gds-obj.
DEFINE BUFFER x-gds-obj-prop FOR gds-obj-prop.
DEFINE BUFFER x-goods FOR goods.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Ассортиментный минимум

Автор: Чернова Светлана Александровна
Дата создания: 03/03/06
Author: Svetlana Chernova
Creation date: 03/03/06

Дата создания: 03/29/05
*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parParentProc AS WIDGET-HANDLE NO-UNDO.
define input  parameter p-obj-type like ub.clients.obj-type no-undo .
define input  parameter p-obj-code like ub.clients.obj-code no-undo .
define input  parameter p-mode as character no-undo .

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Ассортиментный минимум".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ cmp/showinf.i }
{ cmp/r-pril.i new }
{ gbl/waitfram.i }
{ gbl/prn-lib.i }
{ gbl/cur-time.i }
{ gbl/fltopend.i defproc }

define variable filter-point as character no-undo init "Ассортиментный минимум" .
define variable filter-point0 as character no-undo init "Ассортиментный минимум" .
define variable sort-column-name as character no-undo .
define variable gds-rec as recid no-undo .

&scop cop-l1       x-goods.artic
&scop cop-l2       x-goods.gds-name
&scop cop-l3       x-gds-obj-prop.gdop-min-stock
&scop cop-l4       x-gds-obj.fact-qnty
&scop cop-l5       x-gds-obj.free-qnty
&scop cop-l6       x-gds-obj-prop.grop-max-stock
&scop cop-l7       x-gds-obj-prop.gdop-igt
&scop cop-l8       x-goods.prod-type + STRING (x-goods.prod-code)
&scop cop-l9       x-goods.unit-base

&scop col-l1       'Артикул'
&scop col-l2       'Наименование'
&scop col-l3       'MIN!остаток'
&scop col-l4       'Факт!(кол-во)'
&scop col-l5       'Свободно!(кол-во)'
&scop col-l6       'MAX!остаток'
&scop col-l7       'ИЖТ'
&scop col-l8       'Производитель'
&scop col-l9       'Ед.!изм.'

define buffer X_curr_clients for ub.clients.
  find first X_curr_clients no-lock where
            X_curr_clients.obj-type = p-obj-type
       AND X_curr_clients.obj-code = p-obj-code no-error.
  if not available X_curr_clients then do:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметра вызова p-obj-type p-obj-code"
    p-obj-type p-obj-code
    view-as alert-box ERROR.
    return error .
  end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME AMin

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES x-gds-obj-prop x-gds-obj x-goods

/* Definitions for BROWSE AMin                                          */
&Scoped-define FIELDS-IN-QUERY-AMin x-goods.artic x-goods.gds-name x-gds-obj-prop.gdop-min-stock x-gds-obj.fact-qnty x-gds-obj.free-qnty x-gds-obj-prop.grop-max-stock x-gds-obj-prop.gdop-igt x-goods.prod-type + " " + STRING (x-goods.prod-code) x-goods.unit-base
&Scoped-define ENABLED-FIELDS-IN-QUERY-AMin x-goods.artic
&Scoped-define ENABLED-TABLES-IN-QUERY-AMin x-goods
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-AMin x-goods
&Scoped-define SELF-NAME AMin
&Scoped-define QUERY-STRING-AMin FOR     EACH x-gds-obj-prop WHERE             x-gds-obj-prop.gdop-assort-min = YES AND             x-gds-obj-prop.obj-code = p-obj-code AND             x-gds-obj-prop.obj-type = p-obj-type NO-LOCK, ~
             EACH x-gds-obj WHERE            x-gds-obj.gds-code = x-gds-obj-prop.gds-code AND            x-gds-obj.obj-code = x-gds-obj-prop.obj-code AND            x-gds-obj.obj-type = x-gds-obj-prop.obj-type OUTER-JOIN  NO-LOCK, ~
             EACH x-goods OF x-gds-obj-prop NO-LOCK
&Scoped-define OPEN-QUERY-AMin OPEN QUERY AMin FOR     EACH x-gds-obj-prop WHERE             x-gds-obj-prop.gdop-assort-min = YES AND             x-gds-obj-prop.obj-code = p-obj-code AND             x-gds-obj-prop.obj-type = p-obj-type NO-LOCK, ~
             EACH x-gds-obj WHERE            x-gds-obj.gds-code = x-gds-obj-prop.gds-code AND            x-gds-obj.obj-code = x-gds-obj-prop.obj-code AND            x-gds-obj.obj-type = x-gds-obj-prop.obj-type OUTER-JOIN  NO-LOCK, ~
             EACH x-goods OF x-gds-obj-prop NO-LOCK.
&Scoped-define TABLES-IN-QUERY-AMin x-gds-obj-prop x-gds-obj x-goods
&Scoped-define FIRST-TABLE-IN-QUERY-AMin x-gds-obj-prop
&Scoped-define SECOND-TABLE-IN-QUERY-AMin x-gds-obj
&Scoped-define THIRD-TABLE-IN-QUERY-AMin x-goods


/* Definitions for DIALOG-BOX Dialog-Frame                              */

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit B-print B-Help RS-hard AMin ~
ED_asmg-des f-name
&Scoped-Define DISPLAYED-OBJECTS RS-hard ED_asmg-des f-name

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

DEFINE BUTTON B-print
     LABEL "Пе&чать"
     SIZE 10 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE ED_asmg-des AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 98 BY 2.54 NO-UNDO.

DEFINE VARIABLE f-name LIKE assortment-matrix.asmt-name
     LABEL "Ассортиментная матрица"
      VIEW-AS TEXT
     SIZE 72 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE RS-hard AS CHARACTER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Все", "all",
"Ниже минимального остатка", "min"
     SIZE 36 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY AMin FOR
                x-gds-obj-prop,
                x-gds-obj,
                x-goods SCROLLING.

&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE AMin
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS AMin Dialog-Frame _FREEFORM
  QUERY AMin NO-LOCK DISPLAY
      x-goods.artic FORMAT "X(16)":U
      x-goods.gds-name  COLUMN-LABEL {&col-l2}    FORMAT "X(30)":U
      x-gds-obj-prop.gdop-min-stock COLUMN-LABEL "MIN!остаток" FORMAT "->>>>>>>9.<<<":U
      x-gds-obj.fact-qnty COLUMN-LABEL "Факт!(кол-во)" FORMAT "->>>>>>>9.<<<":U
      x-gds-obj.free-qnty COLUMN-LABEL "Свободно!(кол-во)" FORMAT "->>>>>>>9.<<<":U
      x-gds-obj-prop.grop-max-stock COLUMN-LABEL "MAX!остаток" FORMAT "->>>>>>>9.<<<":U
      x-gds-obj-prop.gdop-igt COLUMN-LABEL "ИЖТ" FORMAT "x(20)":U        WIDTH 8
     (x-goods.prod-type + ' ' + STRING (x-goods.prod-code)) COLUMN-LABEL "Производитель" FORMAT "x(13)":U
      x-goods.unit-base COLUMN-LABEL "Ед.!изм." FORMAT "X(3)":U
      ENABLE
      x-goods.artic
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98.38 BY 17 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-print AT ROW 1 COL 79
     B-Help AT ROW 1 COL 89
     RS-hard AT ROW 2 COL 11.5 NO-LABEL
     AMin AT ROW 3 COL 1
     ED_asmg-des AT ROW 21 COL 1 NO-LABEL
     f-name AT ROW 20.25 COL 23.5 COLON-ALIGNED HELP
          ""
          LABEL "Ассортиментная матрица"
          FGCOLOR 4
     SPACE(1.88) SKIP(2.62)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Ассортиментный минимум".


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: x-gds-obj B "?" ? ub gds-obj
      TABLE: x-gds-obj-prop B "?" ? ub gds-obj-prop
      TABLE: x-goods B "?" ? ub goods
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB AMin RS-hard Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN
       ED_asmg-des:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN f-name IN FRAME Dialog-Frame
   LIKE = ub.assortment-matrix.asmt-name EXP-LABEL                      */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE AMin
/* Query rebuild information for BROWSE AMin
     _START_FREEFORM
OPEN QUERY AMin FOR
    EACH x-gds-obj-prop WHERE
            x-gds-obj-prop.gdop-assort-min = YES AND
            x-gds-obj-prop.obj-code = p-obj-code AND
            x-gds-obj-prop.obj-type = p-obj-type NO-LOCK,
      EACH x-gds-obj WHERE
           x-gds-obj.gds-code = x-gds-obj-prop.gds-code AND
           x-gds-obj.obj-code = x-gds-obj-prop.obj-code AND
           x-gds-obj.obj-type = x-gds-obj-prop.obj-type OUTER-JOIN  NO-LOCK,
      EACH x-goods OF x-gds-obj-prop NO-LOCK.
     _END_FREEFORM
     _START_FREEFORM_DEFINE
DEFINE QUERY AMin FOR
                x-gds-obj-prop,
                x-gds-obj,
                x-goods SCROLLING.
     _END_FREEFORM_DEFINE
     _Options          = "NO-LOCK"
     _Query            is NOT OPENED
*/  /* BROWSE AMin */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _Options          = "SHARE-LOCK"
     _Query            is NOT OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Ассортиментный минимум */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME AMin
&Scoped-define SELF-NAME AMin
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL AMin Dialog-Frame
ON ROW-DISPLAY OF AMin IN FRAME Dialog-Frame
DO:
      if available x-gds-obj-prop then do:
        case x-gds-obj-prop.gdop-igt :
            when {&ass-izd-new} then do:
              x-gds-obj-prop.gdop-igt:bgcolor  in browse {&browse-name}   = 14 . /* желтый */
            end.
            when {&ass-izd-del} then do:
              x-gds-obj-prop.gdop-igt:bgcolor  in browse {&browse-name}   = 12 . /* красный */
            end.
            when {&ass-izd-spec} then do:
              x-gds-obj-prop.gdop-igt:bgcolor  in browse {&browse-name}   = 8  .  /* серый  */
            end.

        end case.
        if x-goods.stts <> 0 then x-gds-obj-prop.gdop-igt:fgcolor  in browse {&browse-name}   = 12 .  /* ??????? */
    end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL AMin Dialog-Frame
ON VALUE-CHANGED OF AMin IN FRAME Dialog-Frame
DO:
define buffer buf_Matrix-goods for ub.assortment-matrix-goods.
define buffer buf_Matrix       for ub.assortment-Matrix .
         f-name = " " .
         ED_asmg-des = " " .

    IF AVAILABLE {&FIRST-TABLE-IN-QUERY-{&BROWSE-NAME}} THEN DO:
       find first buf_Matrix no-lock where
                  buf_Matrix.asmt-status   = 0 and
                  buf_Matrix.obj-type = {&FIRST-TABLE-IN-QUERY-{&BROWSE-NAME}}.obj-type and
                  buf_Matrix.obj-code = {&FIRST-TABLE-IN-QUERY-{&BROWSE-NAME}}.obj-code
                  no-error .
         if available buf_Matrix then do:
              find first  buf_Matrix-goods no-lock  where
                         buf_Matrix-goods.asmt-id   = buf_Matrix.asmt-id and
                         buf_Matrix-goods.db-num    = buf_Matrix.db-num and
                         buf_Matrix-goods.asmg-status   = 0 and
                         buf_Matrix-goods.gds-code  = {&FIRST-TABLE-IN-QUERY-{&BROWSE-NAME}}.gds-code no-error .
               if available buf_Matrix-goods then do:
                  f-name = buf_Matrix.asmt-name .
                  ED_asmg-des = buf_Matrix-goods.asmg-des .
               end.
         end.
     END.
     DISPLAY ED_asmg-des f-name WITH FRAME {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-print Dialog-Frame
ON CHOOSE OF B-print IN FRAME Dialog-Frame /* Печать */
DO:
  run proc-b-print in this-procedure no-error.
  if error-status:error then do:
    return no-apply.
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME RS-hard
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL RS-hard Dialog-Frame
ON VALUE-CHANGED OF RS-hard IN FRAME Dialog-Frame
DO:

  run openbr in this-procedure no-error.
  IF ERROR-STATUS:ERROR  THEN RETURN NO-APPLY.
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
{ gbl/srt-clmn.i
  &browse-name    = "{&browse-name}"
  &frame-name     = "{&frame-name}"
  &table-name     = x-gds-obj-prop
  &label-clmn_1   =   "{&col-l1}"
  &label-clmn_2   =   "{&col-l2}"
  &label-clmn_3   =   "{&col-l3}"
  &label-clmn_4   =   "{&col-l4}"
  &label-clmn_5   =   "{&col-l5}"
  &label-clmn_6   =   "{&col-l6}"
  &label-clmn_7   =   "{&col-l7}"
  &label-clmn_8   =   "{&col-l8}"
  &label-clmn_9   =   "{&col-l9}"
  &sort-clmn_1    =   "{&cop-l1}"
  &sort-clmn_2    =   "{&cop-l2}"
  &sort-clmn_3    =   "{&cop-l3}"
  &sort-clmn_4    =   "{&cop-l4}"
  &sort-clmn_5    =   "{&cop-l5}"
  &sort-clmn_6    =   "{&cop-l6}"
  &sort-clmn_7    =   "{&cop-l7}"
  &sort-clmn_8    =   "{&cop-l8}"
  &sort-clmn_9    =   "{&cop-l9}"
  &open-query     = "run OpenBr."
  &open-query-otherwise = "run OpenBr."
  &sort-column-name = "sort-column-name"
  &re-move-clmn   = "yes"
  &mv-brw-default = "yes"
}

{ gbl/brwrepos.i
  &line-num=5
}
{ gbl/f2.i {&BROWSE-name} goods-recid init-gds-rec parParentProc }


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

  run enable_ui.
    { gbl/mv-clmn.i
    &browse-name = "{&browse-name}"
    &frame-name = "{&frame-name}"
    &ext-col = 9
    &start-column = 2
    }
  if p-mode = "min" then do:
     rs-hard = "min".
    display  rs-hard with frame {&frame-name} .
    disable  rs-hard with frame {&frame-name} .
  end.
  x-gds-obj-prop.gdop-igt:resizable in browse {&browse-name}  = true .
  x-goods.gds-name:resizable in browse {&browse-name}  = true .
  x-goods.artic:read-only in browse {&browse-name}  = true .

  run openbr in this-procedure no-error.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
run disable_ui.

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
  DISPLAY RS-hard ED_asmg-des f-name
      WITH FRAME Dialog-Frame.
  ENABLE b-quit B-print B-Help RS-hard AMin ED_asmg-des f-name
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-gds-rec Dialog-Frame
PROCEDURE init-gds-rec :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
if available x-goods then do:
   gds-rec = recid (x-goods) .
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE openBr Dialog-Frame
PROCEDURE openBr :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
define variable p-open-query     as logical   no-undo init true .
define variable l-query-was-opened as logical no-undo .
define variable doc-rec  as recid     no-undo .
define variable  p-find-next      as logical   no-undo .
define variable  p-find-condition as character no-undo .

ASSIGN  FRAME {&FRAME-NAME}
  rs-hard
    .
if p-mode = "min" then rs-hard = "min" .
def var sort-column-phrase as character no-undo .

case sort-column-name :
  when "" then do:
    assign
      sort-column-phrase = ""
    .
  end.
  otherwise do:
    assign
      sort-column-phrase = "by " + sort-column-name
    .
  end.
end case.

define variable title0 as character no-undo init "Ассортиментный минимум" .
 title0 = "Ассортиментный минимум по объекту " + X_curr_clients.obj-type + " " + string(X_curr_clients.obj-code)
                                              + " " + X_curr_clients.obj-name.

&scop flt-open-open-query OPEN QUERY AMin FOR EACH x-gds-obj-prop  no-lock

&scop flt-open-dyn_open-query  FOR EACH x-gds-obj-prop

&scop flt-open-query-handle query AMin:handle

&scop flt-open-find-buffer-name x-gds-obj-prop

&scop flt-open-open-query-tail  , ~
 EACH x-gds-obj WHERE ~
      x-gds-obj.gds-code = x-gds-obj-prop.gds-code AND            ~
      x-gds-obj.obj-code = x-gds-obj-prop.obj-code AND            ~
      x-gds-obj.obj-type = x-gds-obj-prop.obj-type OUTER-JOIN   NO-LOCK, ~
 EACH x-goods OF x-gds-obj-prop NO-LOCK


&scop flt-open-query-was-opened     l-query-was-opened

&scop flt-open-sort-column-phrase   sort-column-phrase

&scop flt-open-call-point           filter-point

&scop flt-open-set-filter-name

&scop flt-open-indexed-reposition  indexed-reposition

&scop flt-open-query               p-open-query

&scop flt-open-table-name          x-gds-obj-prop

&scop flt-open-search-option       no-lock

&scop flt-open-find-next           p-find-next

&scop flt-open-find-recid          doc-rec

&scop flt-open-find-condition       p-find-condition

&scop flt-open-find-buffer-def      define buffer x-gds-obj-prop for gds-obj-props.

&scop flt-open-debug-file

&scop flt-open-waitfram             true



IF rs-hard = "all" THEN DO:
    frame {&frame-name}:TITLE = title0  .
      &scop flt-open-open-query-tail  , ~
      EACH x-gds-obj WHERE ~
            x-gds-obj.gds-code = x-gds-obj-prop.gds-code AND            ~
            x-gds-obj.obj-code = x-gds-obj-prop.obj-code AND            ~
            x-gds-obj.obj-type = x-gds-obj-prop.obj-type OUTER-JOIN   NO-LOCK, ~
      EACH x-goods OF x-gds-obj-prop NO-LOCK

    { gbl/fltopend.i
    &where-cond = " ~
       x-gds-obj-prop.gdop-assort-min = YES and ~
       x-gds-obj-prop.obj-code = p-obj-code AND ~
       x-gds-obj-prop.obj-type = p-obj-type ~
       "
    &dyn_where-cond = " substitute('x-gds-obj-prop.gdop-assort-min = YES and ~
                                    x-gds-obj-prop.obj-code = &2 AND ~
                                    x-gds-obj-prop.obj-type = &1&3&1 ~
                                  ' ,  ~{&double-quote~}, p-obj-code , p-obj-type) "
    &use-ind    = "  "
    &by         = " " }


END.
ELSE DO:
    frame {&frame-name}:TITLE = title0 + {&space-char} + "Остаток на объекте < min остатка".
      &scop flt-open-open-query-tail  , ~
      EACH x-gds-obj WHERE ~
            x-gds-obj.gds-code = x-gds-obj-prop.gds-code AND ~
            x-gds-obj.obj-code = x-gds-obj-prop.obj-code AND ~
            x-gds-obj.obj-type = x-gds-obj-prop.obj-type and ~
            x-gds-obj.fact-qnty < x-gds-obj-prop.gdop-min-stock ~
            NO-LOCK, ~
      EACH x-goods OF x-gds-obj-prop NO-LOCK

            { gbl/fltopend.i
              &where-cond = " ~
                x-gds-obj-prop.gdop-assort-min = YES and ~
                x-gds-obj-prop.obj-code = p-obj-code AND ~
                x-gds-obj-prop.obj-type = p-obj-type ~
                "
              &dyn_where-cond = " substitute('x-gds-obj-prop.gdop-assort-min = YES and ~
                                              x-gds-obj-prop.obj-code = &2 AND ~
                                              x-gds-obj-prop.obj-type = &1&3&1 ~
                                            ' ,  ~{&double-quote~}, p-obj-code , p-obj-type) "

              &where-cond = "  "
              &use-ind    = " "
              &by         = " " }

END.


APPLY "VALUE-CHANGED" TO {&BROWSE-NAME} in frame {&frame-name}.
APPLY "ENTRY" TO {&BROWSE-NAME}.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-print Dialog-Frame
PROCEDURE proc-b-print :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
define variable v-doc-rec as recid no-undo .
define variable accum-count as integer.
define variable date_string     as      char    no-undo.
define variable Line            as      char    no-undo.
define variable v-time-cr as character no-undo .

DEFINE FRAME buf_Matrix-list
      x-goods.artic FORMAT "X(16)":U
      x-goods.gds-name FORMAT "X(30)":U
      x-gds-obj-prop.gdop-min-stock COLUMN-LABEL "MIN!остаток" FORMAT "->>>>>>>9.<<<":U
      x-gds-obj.fact-qnty COLUMN-LABEL "Факт!(кол-во)" FORMAT "->>>>>>>9.<<<":U
      x-gds-obj.free-qnty COLUMN-LABEL "Свободно!(кол-во)" FORMAT "->>>>>>>9.<<<":U
      x-gds-obj-prop.grop-max-stock COLUMN-LABEL "MAX!остаток" FORMAT "->>>>>>>9.<<<":U
      x-gds-obj-prop.gdop-igt COLUMN-LABEL "ИЖТ" FORMAT "X(8)":U
      v-time-cr COLUMN-LABEL "Производитель" FORMAT "x(13)":U
      x-goods.unit-base COLUMN-LABEL "Ед.!изм." FORMAT "X(3)":U
HEADER  date_string AT 5 format "X(35)"
 string( "Страница " ) format "X(9)" AT 115 PAGE-NUMBER(PrnLibStream) AT 125 FORMAT ">>9" SKIP
Line format "X(195)" AT 1
with width {&DOS_CW_2} down stream-io use-text    .

Line = fill("-", 195).
date_string = cur-time-print() .

run prn-lib-open-stream  in this-procedure (
                                             input parParentProc
                                            ,input {&LS_PS_A4}
                                            ,input yes /*p-is-stream*/
                                            ,input no /*p-append*/
                                            ).
PUT  STREAM PrnLibStream
SPACE(25) ( frame {&frame-name}:title )
format "x(90)" SKIP(1) .
FORM HEADER
Line format "X(195)" AT 1 SKIP
"Продолжение - на следующей странице" AT 30 SKIP
with FRAME BottomFrame width {&DOS_CW_2} PAGE-BOTTOM NO-LABELS NO-BOX .
VIEW  STREAM PrnLibStream FRAME BottomFrame .

FORM with FRAME buf_Matrix-list  .
run waitfram-show in this-procedure ("Ждите...").
v-doc-rec = recid(x-gds-obj-prop).
DO WHILE available x-gds-obj-prop :
  GET prev {&browse-name}.
END.
GET next {&browse-name}.
DO WHILE available x-gds-obj-prop :
  Display STREAM PrnLibStream
      x-goods.artic
      x-goods.gds-name
      x-gds-obj-prop.gdop-min-stock
      x-gds-obj.fact-qnty
      x-gds-obj.free-qnty
      x-gds-obj-prop.grop-max-stock
      x-gds-obj-prop.gdop-igt
      x-goods.prod-type +  " "  +  STRING (x-goods.prod-code) @ v-time-cr
      x-goods.unit-base
 with FRAME buf_Matrix-list .
  DOWN STREAM PrnLibStream 1
  with FRAME buf_Matrix-list  .
  assign
  accum-count = accum-count + 1
  .
  GET next {&browse-name}.
END.
UNDERLINE  STREAM PrnLibStream
      x-goods.artic
      x-goods.gds-name
      x-gds-obj-prop.gdop-min-stock
      x-gds-obj.fact-qnty
      x-gds-obj.free-qnty
      x-gds-obj-prop.grop-max-stock
      x-gds-obj-prop.gdop-igt
      v-time-cr
      x-goods.unit-base
with FRAME buf_Matrix-list .

DISPLAY STREAM PrnLibStream
"ИТОГО"     @ x-goods.artic
accum-count @ x-goods.gds-name
with frame buf_Matrix-list.
HIDE  STREAM PrnLibStream FRAME BottomFrame .
HIDE  STREAM PrnLibStream FRAME buf_Matrix-List.
output  STREAM PrnLibStream CLOSE.
REPOSITION {&browse-name} to recid v-doc-rec no-error.
APPLY "entry" to {&browse-name}.
run waitfram-hide in this-procedure .
run prn-lib-prn-file in this-procedure (
                                          input parParentProc
                                          ,input 8
                                          ).



END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME