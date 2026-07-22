&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame

/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER x_c-assortment-matrix FOR c-assortment-matrix.
DEFINE BUFFER X_curr_clients FOR clients.
DEFINE BUFFER x_assortment-matrix FOR assortment-matrix.


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

История ассортиментной матрицы

Автор: Чернова Светлана Александровна
Дата создания: 03/28/05
Author: Svetlana Chernova
Creation date: 03/28/05


*/

/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc  as widget-handle no-undo.
define input parameter p-asmt-id like ub.assortment-matrix.asmt-id no-undo .
define input parameter p-db-num like ub.assortment-matrix.db-num no-undo.
define input-output param p-rid-list    as  character  no-undo .
define variable bttns  as character    no-undo .

/* local variable definitions ---                                       */
define variable vss-revision    as character  no-undo init "$revision: 9 $":u.
define variable vss-author      as character  no-undo init "$author: nvb $":u.
define variable vss-date        as character  no-undo init "$date: 24.01.07 13:49 $":u.
define variable vss-workfile    as character  no-undo init "$workfile: cassmatr.w $":u.
define variable vss-archive     as character  no-undo init "$archive: /ver15_0/str/cassmatr.w $":u.
define variable vss-description as character  no-undo init "Список истории ассортиментной матрицы":u.
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/showinf.i  }
{ cmp/r-pril.i new }
{ gbl/waitfram.i }
{ gbl/prn-lib.i  }
{ gbl/cur-time.i }
{ gbl/usrfulnf.i }
define variable v-doc-rec as recid no-undo.
define variable sort-column-name as character no-undo .
define variable v-db-num LIKE ub.db.db-num no-undo.

{ ref/tmpchgs.i }

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BR-changes

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES temp-changes x_c-assortment-matrix

/* Definitions for BROWSE BR-changes                                    */
&Scoped-define FIELDS-IN-QUERY-BR-changes temp-changes.l_name temp-changes.v_old temp-changes.v_new
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-changes
&Scoped-define SELF-NAME BR-changes
&Scoped-define QUERY-STRING-BR-changes FOR EACH temp-changes
&Scoped-define OPEN-QUERY-BR-changes OPEN QUERY {&SELF-NAME} FOR EACH temp-changes.
&Scoped-define TABLES-IN-QUERY-BR-changes temp-changes
&Scoped-define FIRST-TABLE-IN-QUERY-BR-changes temp-changes


/* Definitions for BROWSE br-condkeep                                   */
&Scoped-define FIELDS-IN-QUERY-br-condkeep x_c-assortment-matrix.casm-igt ~
x_c-assortment-matrix.casm-assort-min x_c-assortment-matrix.grop-date-update ~
string(x_c-assortment-matrix.grop-time-update, "HH:MM") ~
x_c-assortment-matrix.grop-db-num-update x_c-assortment-matrix.grop-who-update ~
x_c-assortment-matrix.casm-date-his ~
string(x_c-assortment-matrix.casm-time-his, "HH:MM") ~
x_c-assortment-matrix.corr-user-db-num x_c-assortment-matrix.corr-user-name
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-condkeep
&Scoped-define QUERY-STRING-br-condkeep FOR EACH x_c-assortment-matrix NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-br-condkeep OPEN QUERY br-condkeep FOR EACH x_c-assortment-matrix NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-br-condkeep x_c-assortment-matrix
&Scoped-define FIRST-TABLE-IN-QUERY-br-condkeep x_c-assortment-matrix


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-br-condkeep}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit B-Help br-condkeep BR-changes

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD mark-string Dialog-Frame
FUNCTION mark-string RETURNS CHARACTER
  ( BUFFER loc-c-assortment-matrix FOR c-assortment-matrix, input mark-list as character )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-lookup
     LABEL "&Просмотр"
     SIZE 1 BY 1.

DEFINE BUTTON B-mark
     LABEL "&Просмотр"
     SIZE 1 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-sel
     LABEL "&Просмотр"
     SIZE 1 BY 1.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-changes FOR
      temp-changes SCROLLING.

DEFINE QUERY br-condkeep FOR
      x_c-assortment-matrix SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-changes
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-changes Dialog-Frame _FREEFORM
  QUERY BR-changes DISPLAY
      temp-changes.l_name COLUMn-LABEL "Изменилось" format "X(15)"
temp-changes.v_old COLUMn-LABEL "Было" format "X(40)"
temp-changes.v_new COLUMn-LABEL "Стало" format "X(40)"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 9.54.

DEFINE BROWSE br-condkeep
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-condkeep Dialog-Frame _STRUCTURED
  QUERY br-condkeep NO-LOCK DISPLAY
      x_c-assortment-matrix.asmt-name
      x_c-assortment-matrix.asmt-type
      x_c-assortment-matrix.obj-type
      x_c-assortment-matrix.obj-code
      x_c-assortment-matrix.asmt-date-update COLUMN-LABEL "Дата посл.!изменения" FORMAT "99/99/99":U
            WIDTH 11
      string(x_c-assortment-matrix.asmt-time-update, "HH:MM") COLUMN-LABEL "Время!измен" FORMAT "X(5)":U
      x_c-assortment-matrix.asmt-db-num-update COLUMN-LABEL "БД!изм" FORMAT ">>>>9":U
            WIDTH 3
      x_c-assortment-matrix.asmt-who-update COLUMN-LABEL "Кто!изменил" FORMAT "X(8)":U
      usrfulnf(x_c-assortment-matrix.asmt-who-update) COLUMN-LABEL "Кто изменил!ФИО" FORMAT "X(18)":U
      x_c-assortment-matrix.casm-date-his COLUMN-LABEL "Создание!истории" FORMAT "99/99/99":U
            WIDTH 11
      string(x_c-assortment-matrix.casm-time-his, "HH:MM") COLUMN-LABEL "Время!созд" FORMAT "x(5)":U
      x_c-assortment-matrix.corr-user-db-num COLUMN-LABEL "БД!соз" FORMAT ">>>>9":U
            WIDTH 3
      x_c-assortment-matrix.corr-user-name COLUMN-LABEL "Кто!создал" FORMAT "X(8)":U
      usrfulnf(x_c-assortment-matrix.corr-user-name) COLUMN-LABEL "Кто создал!ФИО" FORMAT "X(18)":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 10 ROW-HEIGHT-CHARS .75 EXPANDABLE.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-lookup AT ROW 1 COL 20.5
     B-sel AT ROW 1 COL 21.5
     B-mark AT ROW 1 COL 22.5
     B-Help AT ROW 1 COL 89
     br-condkeep AT ROW 2.25 COL 1
     BR-changes AT ROW 12.5 COL 1
     SPACE(0.12) SKIP(0.00)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "История ассортиментной матрицы"
         CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: x_c-assortment-matrix B "?" ? ub c-assortment-matrix
      TABLE: X_curr_clients B "?" ? ub clients
      TABLE: x_assortment-matrix B "?" ? ub assortment-matrix
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
                                                                        */
/* BROWSE-TAB br-condkeep B-Help Dialog-Frame */
/* BROWSE-TAB BR-changes br-condkeep Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR BUTTON B-lookup IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN
       B-lookup:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR BUTTON B-mark IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN
       B-mark:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR BUTTON B-sel IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN
       B-sel:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-changes
/* Query rebuild information for BROWSE BR-changes
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH temp-changes.
     _END_FREEFORM
     _Query            is NOT OPENED
*/  /* BROWSE BR-changes */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-condkeep
/* Query rebuild information for BROWSE br-condkeep
     _TblList          = "x_c-assortment-matrix"
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _FldNameList[1]   > Temp-Tables.x_c-assortment-matrix.casm-igt
"x_c-assortment-matrix.casm-igt" "ИЖТ" "X(8)" "character" ? ? ? ? ? ? no ? no no ? yes no no "U" "" ""
     _FldNameList[2]   > Temp-Tables.x_c-assortment-matrix.casm-assort-min
"x_c-assortment-matrix.casm-assort-min" "Ассортим.!minimum" ? "logical" ? ? ? ? ? ? no ? no no ? yes no no "U" "" ""
     _FldNameList[3]   > Temp-Tables.x_c-assortment-matrix.grop-date-update
"x_c-assortment-matrix.grop-date-update" "Дата посл.!изменения" ? "date" ? ? ? ? ? ? no ? no no "11" yes no no "U" "" ""
     _FldNameList[4]   > "_<CALC>"
"string(x_c-assortment-matrix.grop-time-update, ""HH:MM"")" "Время!измен" "X(5)" ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" ""
     _FldNameList[5]   > Temp-Tables.x_c-assortment-matrix.grop-db-num-update
"x_c-assortment-matrix.grop-db-num-update" "БД!изм" ? "integer" ? ? ? ? ? ? no ? no no "3" yes no no "U" "" ""
     _FldNameList[6]   > Temp-Tables.x_c-assortment-matrix.grop-who-update
"x_c-assortment-matrix.grop-who-update" "Кто!изменил" ? "character" ? ? ? ? ? ? no ? no no ? yes no no "U" "" ""
     _FldNameList[7]   > Temp-Tables.x_c-assortment-matrix.casm-date-his
"x_c-assortment-matrix.casm-date-his" "Создание!истории" ? "date" ? ? ? ? ? ? no ? no no "11" yes no no "U" "" ""
     _FldNameList[8]   > "_<CALC>"
"string(x_c-assortment-matrix.casm-time-his, ""HH:MM"")" "Время!созд" "x(5)" ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" ""
     _FldNameList[9]   > Temp-Tables.x_c-assortment-matrix.corr-user-db-num
"x_c-assortment-matrix.corr-user-db-num" "БД!соз" ? "integer" ? ? ? ? ? ? no ? no no "3" yes no no "U" "" ""
     _FldNameList[10]   > Temp-Tables.x_c-assortment-matrix.corr-user-name
"x_c-assortment-matrix.corr-user-name" "Кто!создал" ? "character" ? ? ? ? ? ? no ? no no "29.75" yes no no "U" "" ""
     _Query            is OPENED
*/  /* BROWSE br-condkeep */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* История ассортиментной матрицы */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-condkeep
&Scoped-define SELF-NAME br-condkeep
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-condkeep Dialog-Frame
ON RETURN OF br-condkeep IN FRAME Dialog-Frame
or MOUSE-SELECT-DBLCLICK OF br-condkeep IN FRAME Dialog-Frame
    DO:
    run proc-br-condkeep in this-procedure no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-condkeep Dialog-Frame
ON VALUE-CHANGED OF br-condkeep IN FRAME Dialog-Frame
DO:
  run proc-view-changes in this-procedure no-error.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-changes
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.
{ gbl/app_help.i }

{ gbl/brwrepos.i
  &line-num=5
}

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

  find first X_assortment-matrix no-lock where
             X_assortment-matrix.db-num = p-db-num and
             X_assortment-matrix.asmt-id = p-asmt-id
             no-error.
    if not available X_assortment-matrix then do:
        message
        "Нет истории по товару asmt-id "  p-asmt-id skip
          p-db-num
        view-as alert-box ERROR.
        return.
    end.

 { gbl/curdbnum.i v-db-num }
  run myenable in this-procedure .
  run openbr in this-procedure .
  if v-doc-rec <> ? then
  reposition br-condkeep to recid v-doc-rec no-error.

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
  ENABLE b-quit B-Help br-condkeep BR-changes
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
ENABLE
b-quit
B-Help
br-condkeep
with FRAME Dialog-Frame.
VIEW FRAME Dialog-Frame.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OpenBr Dialog-Frame
PROCEDURE OpenBr :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
OPEN QUERY br-condkeep FOR EACH X_c-assortment-matrix NO-LOCK where
                                X_c-assortment-matrix.asmt-id = p-asmt-id and
                                X_c-assortment-matrix.db-num  = p-db-num
                              INDEXED-REPOSITION.
APPLY "VALUE-CHANGED" TO br-condkeep in frame {&frame-name}.
APPLY "ENTRY" TO br-condkeep.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-br-condkeep Dialog-Frame
PROCEDURE proc-br-condkeep :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
{ ref/brwsretr.i }
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-view-changes Dialog-Frame
PROCEDURE proc-view-changes :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define buffer new_c-assortment-matrix for ub.c-assortment-matrix.
define buffer current_assortment-matrix for ub.assortment-matrix.
define variable v-chg-fields as character no-undo.
define variable v-old-fields as character no-undo.
define variable v-new-fields as character no-undo.
define variable ii as integer no-undo.

for each temp-changes:
    delete temp-changes.
END.
if not available X_c-assortment-matrix then do:
  Open QUery br-changes for each temp-changes.
  return.
end.
find first new_c-assortment-matrix no-lock where
            new_c-assortment-matrix.asmt-id = X_c-assortment-matrix.asmt-id
        and new_c-assortment-matrix.db-num = X_c-assortment-matrix.db-num
        AND new_c-assortment-matrix.chip-num > X_c-assortment-matrix.chip-num
        AND new_c-assortment-matrix.corr-user-db-num >= X_c-assortment-matrix.corr-user-db-num
    no-error.

if not available new_c-assortment-matrix then do:
    find first current_assortment-matrix no-lock where
               current_assortment-matrix.asmt-id = X_c-assortment-matrix.asmt-id
           and current_assortment-matrix.db-num = X_c-assortment-matrix.db-num
           no-error.
    if not available current_assortment-matrix then do:
         return error.
    end.
    buffer-compare current_assortment-matrix to X_c-assortment-matrix
    save result in v-chg-fields.
end.
else do:
    buffer-compare new_c-assortment-matrix except chip-num casm-date-his corr-user-db-num casm-time-his corr-user-name to X_c-assortment-matrix
    save result in v-chg-fields.
end.
&scop  disp-field ~
  when "~{&field-name~}":U then do: ~
    create temp-changes. ~
    assign ~
    temp-changes.f_name = "~{&field-name~}":U ~
    temp-changes.l_name = ~{&field-label~} ~
    temp-changes.v_old = string(X_c-assortment-matrix.~{&field-name~}) ~
    temp-changes.v_new = (if available new_c-assortment-matrix  ~
                             then string(new_c-assortment-matrix.~{&field-name~})  ~
                             else string(current_assortment-matrix.~{&field-name~})) ~
    . ~
  end. ~


define variable v-nn as integer   no-undo .
v-nn = num-entries(v-chg-fields).
do ii = 1 to v-nn :
CASE entry(ii, v-chg-fields):

&scop field-name     asmt-date-update
&scop field-label     "Дата изменения"
{&disp-field}
&scop field-name     asmt-db-num-update
&scop field-label     "БД изм"
{&disp-field}
&scop field-name     asmt-time-update
&scop field-label    "Время изменения"
{&disp-field}
&scop field-name     asmt-who-update
&scop field-label    "Кто"
{&disp-field}
&scop field-name     asmt-type
&scop field-label    "Тип"
{&disp-field}
&scop field-name     obj-type
&scop field-label    "Тип объекта"
{&disp-field}
&scop field-name     obj-code
&scop field-label    "Код объекта"
{&disp-field}
&scop field-name     asmt-name
&scop field-label    "Наименование"
{&disp-field}
&scop field-name     asmt-status
&scop field-label    "Статус"
{&disp-field}
&scop field-name     asmt-des
&scop field-label    "Комментарий"
{&disp-field}
END CASE.
end.

Open QUery br-changes for each temp-changes.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION mark-string Dialog-Frame
FUNCTION mark-string RETURNS CHARACTER
  ( BUFFER loc-c-assortment-matrix FOR c-assortment-matrix, input mark-list as character ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/
RETURN ( IF LOOKUP( STRING( RECID( loc-c-assortment-matrix ) ), mark-list ) > 0 THEN "*" ELSE "":U ).

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME