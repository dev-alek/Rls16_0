&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER locked_group-period-validity FOR ub.group-period-validity.
DEFINE BUFFER locked_var-deliv-gr-per-val FOR ub.var-deliv-gr-per-val.
DEFINE BUFFER locked_variant-delivery FOR ub.variant-delivery.
DEFINE TEMP-TABLE tt-group-period-validity NO-UNDO LIKE ub.group-period-validity.
DEFINE TEMP-TABLE tt-var-deliv-gr-per-val NO-UNDO LIKE ub.var-deliv-gr-per-val.
DEFINE TEMP-TABLE tt-variant-delivery NO-UNDO LIKE ub.variant-delivery.
DEFINE BUFFER X_clients FOR ub.clients.
DEFINE BUFFER X_curr_clients FOR ub.clients.
DEFINE BUFFER X_delivery-subject FOR ub.delivery-subject.
DEFINE BUFFER X_delivery-type FOR ub.delivery-type.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Карточка редактирования ВАРИАНТА ДОСТАВКИ  ПО ГРУППЕ СРОКОВ ГОДНОСТИ

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/25/04
Author: Bakhtadze Natalya
Creation date: 03/25/04

*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT     PARAMETER parParentProc  AS WIDGET-HANDLE NO-UNDO.
define input parameter p-curr-obj-type like ub.clients.obj-type no-undo.
define input parameter p-curr-obj-code like ub.clients.obj-code no-undo.
define input parameter p-mode as character no-undo.
/*может быть {&add-def} {&update} {&lookup}*/
DEFINE INPUT PARAMETER p-deliv-type-code LIKE ub.var-deliv-gr-per-val.deliv-type-code NO-UNDO.
DEFINE INPUT PARAMETER p-deliv-subj-code LIKE ub.var-deliv-gr-per-val.deliv-subj-code NO-UNDO.
DEFINE INPUT PARAMETER p-deliv-obj-type  LIKE ub.var-deliv-gr-per-val.obj-type NO-UNDO.
DEFINE INPUT PARAMETER p-deliv-obj-code  LIKE ub.var-deliv-gr-per-val.obj-code NO-UNDO.
define input parameter p-gr-per-val-code  LIKE ub.var-deliv-gr-per-val.gr-per-val-code no-undo .
define input-output parameter p-doc-rec as recid no-undo.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Карточка редактирования ВАРИАНТА ДОСТАВКИ ПО ГРУППЕ СРОКОВ ГОДНОСТИ".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/showinf.i }


define variable v-tab-order as character no-undo.
define variable v-db-num LIKE ub.db.db-num no-undo.

&scop tab-order   "B-exit,b-quit,b-hist,b-help,B-variant-delivery,B-exit,B-gr-per-val,des"

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-var-deliv-gr-per-val tt-variant-delivery

/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define FIELDS-IN-QUERY-Dialog-Frame ~
tt-var-deliv-gr-per-val.deliv-type-code ~
tt-var-deliv-gr-per-val.deliv-subj-code tt-var-deliv-gr-per-val.obj-type ~
tt-var-deliv-gr-per-val.obj-code tt-var-deliv-gr-per-val.gr-per-val-code ~
tt-var-deliv-gr-per-val.des 
&Scoped-define ENABLED-FIELDS-IN-QUERY-Dialog-Frame ~
tt-var-deliv-gr-per-val.gr-per-val-code tt-var-deliv-gr-per-val.des 
&Scoped-define ENABLED-TABLES-IN-QUERY-Dialog-Frame tt-var-deliv-gr-per-val
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-Dialog-Frame tt-var-deliv-gr-per-val
&Scoped-define QUERY-STRING-Dialog-Frame FOR EACH tt-var-deliv-gr-per-val SHARE-LOCK, ~
      EACH tt-variant-delivery WHERE TRUE /* Join to tt-var-deliv-gr-per-val incomplete */ SHARE-LOCK
&Scoped-define OPEN-QUERY-Dialog-Frame OPEN QUERY Dialog-Frame FOR EACH tt-var-deliv-gr-per-val SHARE-LOCK, ~
      EACH tt-variant-delivery WHERE TRUE /* Join to tt-var-deliv-gr-per-val incomplete */ SHARE-LOCK.
&Scoped-define TABLES-IN-QUERY-Dialog-Frame tt-var-deliv-gr-per-val ~
tt-variant-delivery
&Scoped-define FIRST-TABLE-IN-QUERY-Dialog-Frame tt-var-deliv-gr-per-val
&Scoped-define SECOND-TABLE-IN-QUERY-Dialog-Frame tt-variant-delivery


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS tt-var-deliv-gr-per-val.gr-per-val-code ~
tt-var-deliv-gr-per-val.des 
&Scoped-define ENABLED-TABLES tt-var-deliv-gr-per-val
&Scoped-define FIRST-ENABLED-TABLE tt-var-deliv-gr-per-val
&Scoped-Define ENABLED-OBJECTS B-exit b-quit B-Hist B-Help ~
B-variant-delivery f-deliv-obj-name B-gr-per-val 
&Scoped-Define DISPLAYED-FIELDS tt-var-deliv-gr-per-val.deliv-type-code ~
tt-var-deliv-gr-per-val.deliv-subj-code tt-var-deliv-gr-per-val.obj-type ~
tt-var-deliv-gr-per-val.obj-code tt-var-deliv-gr-per-val.gr-per-val-code ~
tt-var-deliv-gr-per-val.des 
&Scoped-define DISPLAYED-TABLES tt-var-deliv-gr-per-val
&Scoped-define FIRST-DISPLAYED-TABLE tt-var-deliv-gr-per-val
&Scoped-Define DISPLAYED-OBJECTS F-deliv-type-name F-deliv-subj-name ~
f-deliv-obj-name F-term-delivery F-gr-per-val-name f-gr-per-from ~
f-gr-per-to 

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

DEFINE BUTTON B-gr-per-val 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 1" 
     SIZE 3 BY 1.

DEFINE BUTTON B-Help 
     LABEL "Помо&щь" 
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-Hist 
     LABEL "Ис&тория" 
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-quit AUTO-END-KEY 
     LABEL "&Отмена" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-variant-delivery 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 1" 
     SIZE 3 BY 1.

DEFINE VARIABLE f-deliv-obj-name AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 42.5 BY 1 NO-UNDO.

DEFINE VARIABLE F-deliv-subj-name AS CHARACTER FORMAT "X(50)" 
     LABEL "Название субъекта доставки" 
     VIEW-AS FILL-IN 
     SIZE 63 BY 1 NO-UNDO.

DEFINE VARIABLE F-deliv-type-name AS CHARACTER FORMAT "X(50)" 
     LABEL "Название типа доставки" 
     VIEW-AS FILL-IN 
     SIZE 63 BY 1.

DEFINE VARIABLE f-gr-per-from AS INTEGER FORMAT ">,>>9":U INITIAL 0 
     LABEL "Срок хранения(дни) от" 
     VIEW-AS FILL-IN 
     SIZE 9.5 BY 1 NO-UNDO.

DEFINE VARIABLE f-gr-per-to AS INTEGER FORMAT ">,>>9":U INITIAL 0 
     LABEL "до" 
     VIEW-AS FILL-IN 
     SIZE 9.5 BY 1 NO-UNDO.

DEFINE VARIABLE F-gr-per-val-name AS CHARACTER FORMAT "X(256)":U 
     LABEL "Назв. группы сроков хран." 
     VIEW-AS FILL-IN 
     SIZE 63 BY 1 NO-UNDO.

DEFINE VARIABLE F-term-delivery AS INTEGER FORMAT ">,>>9" INITIAL 0 
     LABEL "Срок доставки(дни)" 
     VIEW-AS FILL-IN 
     SIZE 17 BY 1.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY Dialog-Frame FOR 
      tt-var-deliv-gr-per-val, 
      tt-variant-delivery SCROLLING.
&ANALYZE-RESUME

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-Hist AT ROW 1 COL 92
     B-Help AT ROW 1 COL 95
     tt-var-deliv-gr-per-val.deliv-type-code AT ROW 3 COL 27.5 COLON-ALIGNED
          LABEL "Внутр.код типа доставки"
          VIEW-AS FILL-IN 
          SIZE 11 BY 1
     tt-var-deliv-gr-per-val.deliv-subj-code AT ROW 3 COL 66.5 COLON-ALIGNED
          LABEL "Вн.код субъекта доставки"
          VIEW-AS FILL-IN 
          SIZE 11 BY 1
     B-variant-delivery AT ROW 3 COL 80
     F-deliv-type-name AT ROW 4.27 COL 27.5 COLON-ALIGNED
     F-deliv-subj-name AT ROW 5.5 COL 27.5 COLON-ALIGNED
     tt-var-deliv-gr-per-val.obj-type AT ROW 6.77 COL 27.5 COLON-ALIGNED
          LABEL "Объект доставки"
          VIEW-AS FILL-IN 
          SIZE 6 BY 1
     tt-var-deliv-gr-per-val.obj-code AT ROW 6.77 COL 34 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 10 BY 1
     f-deliv-obj-name AT ROW 6.77 COL 48 COLON-ALIGNED NO-LABEL
     F-term-delivery AT ROW 8 COL 27.5 COLON-ALIGNED
     tt-var-deliv-gr-per-val.gr-per-val-code AT ROW 9.27 COL 33.5 COLON-ALIGNED
          LABEL "Внутр.код группы сроков хранения"
          VIEW-AS FILL-IN 
          SIZE 11 BY 1
     B-gr-per-val AT ROW 9.27 COL 47.5
     F-gr-per-val-name AT ROW 10.5 COL 28 COLON-ALIGNED
     f-gr-per-from AT ROW 11.77 COL 28 COLON-ALIGNED
     f-gr-per-to AT ROW 11.77 COL 42.5 COLON-ALIGNED
     tt-var-deliv-gr-per-val.des AT ROW 14.5 COL 1 NO-LABEL
          VIEW-AS EDITOR SCROLLBAR-VERTICAL
          SIZE 98 BY 3.77
     "Описание" VIEW-AS TEXT
          SIZE 16 BY 1 AT ROW 13 COL 1.5
     SPACE(81.74) SKIP(4.45)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Тип доставки от субъекта"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: locked_group-period-validity B "?" ? ub group-period-validity
      TABLE: locked_var-deliv-gr-per-val B "?" ? ub var-deliv-gr-per-val
      TABLE: locked_variant-delivery B "?" ? ub variant-delivery
      TABLE: tt-group-period-validity T "?" NO-UNDO ub group-period-validity
      TABLE: tt-var-deliv-gr-per-val T "?" NO-UNDO ub var-deliv-gr-per-val
      TABLE: tt-variant-delivery T "?" NO-UNDO ub variant-delivery
      TABLE: X_clients B "?" ? ub clients
      TABLE: X_curr_clients B "?" ? ub clients
      TABLE: X_delivery-subject B "?" ? ub delivery-subject
      TABLE: X_delivery-type B "?" ? ub delivery-type
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

/* SETTINGS FOR FILL-IN tt-var-deliv-gr-per-val.deliv-subj-code IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN tt-var-deliv-gr-per-val.deliv-type-code IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN F-deliv-subj-name IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN 
       F-deliv-subj-name:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN F-deliv-type-name IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN 
       F-deliv-type-name:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN f-gr-per-from IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN f-gr-per-to IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN F-gr-per-val-name IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN F-term-delivery IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN tt-var-deliv-gr-per-val.gr-per-val-code IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-var-deliv-gr-per-val.obj-code IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN tt-var-deliv-gr-per-val.obj-type IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _TblList          = "Temp-Tables.tt-var-deliv-gr-per-val,Temp-Tables.tt-variant-delivery WHERE Temp-Tables.tt-var-deliv-gr-per-val ..."
     _Options          = "SHARE-LOCK"
     _Query            is OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Тип доставки от субъекта */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-exit Dialog-Frame
ON CHOOSE OF B-exit IN FRAME Dialog-Frame /* Ввод */
DO:
    run proc-save in this-procedure no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-gr-per-val
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-gr-per-val Dialog-Frame
ON CHOOSE OF B-gr-per-val IN FRAME Dialog-Frame /* Btn 1 */
DO:
  define variable v-rid-list as character no-undo.
  define variable v-sts as integer no-undo .
{ gbl/stdbtn.i }
if available locked_group-period-validity then v-rid-list = string(recid(locked_group-period-validity)).
run ref/gpervals.w (input parParentProc
              , p-curr-obj-type
              , p-curr-obj-code
              , "b-sel":U
              , {&all}
              , input-output v-sts
              , input-output v-rid-list ) no-error .

if v-rid-list <> "":U then do:
FIND FIRST LOCKED_group-period-validity WHERE
    recid( LOCKED_group-period-validity ) = integer(entry(1, v-rid-list)) NO-LOCK .
if available LOCKED_group-period-validity then do:
    assign
    tt-var-deliv-gr-per-val.gr-per-val-code = locked_group-period-validity.gr-per-val-code
    f-gr-per-val-name = locked_group-period-validity.gr-per-val-name
    f-gr-per-from     = locked_group-period-validity.gr-per-from
    f-gr-per-to     = locked_group-period-validity.gr-per-to
    .
  end.
  else do:
  assign
  tt-var-deliv-gr-per-val.gr-per-val-code = ?
  f-gr-per-val-name = "":U
  f-gr-per-from = ?
  f-gr-per-to = ?
  .
  end.
  display
  tt-var-deliv-gr-per-val.gr-per-val-code
  f-gr-per-val-name
  f-gr-per-from
  f-gr-per-to
  with frame {&frame-name} .
end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-Hist
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-Hist Dialog-Frame
ON CHOOSE OF B-Hist IN FRAME Dialog-Frame /* История */
DO:
  define variable v-rid-list as character no-undo.
    run ref/varcdlvs.w
                (
                 input parParentProc
                ,INPUT p-curr-obj-type
                ,INPUT p-curr-obj-code
                ,input "":U /*bttns*/
                ,input "one":U
                ,input locked_var-deliv-gr-per-val.deliv-type-code
                ,input locked_var-deliv-gr-per-val.deliv-subj-code
                ,input locked_var-deliv-gr-per-val.obj-type
                ,input locked_var-deliv-gr-per-val.obj-code
                ,input-output v-rid-list
                              )

 .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-variant-delivery
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-variant-delivery Dialog-Frame
ON CHOOSE OF B-variant-delivery IN FRAME Dialog-Frame /* Btn 1 */
DO:
  define variable v-rid-list as character no-undo.
  define variable v-sts as integer no-undo . .
{ gbl/stdbtn.i }
if available locked_variant-delivery then
assign
v-rid-list = string(recid(locked_variant-delivery))
v-sts = locked_variant-delivery.sts
.
run ref/vardelvs.w (input parParentProc
              , p-curr-obj-type
              , p-curr-obj-code
              , "b-sel":U
              , {&all}
              , p-deliv-type-code
              , p-deliv-subj-code
              , p-deliv-obj-type
              , p-deliv-obj-code
              , input-output v-sts
              , input-output v-rid-list ) no-error .

if v-rid-list <> "":U then do:
    FIND FIRST LOCKED_variant-delivery  WHERE
        recid( LOCKED_variant-delivery  ) = integer(entry(1, v-rid-list)) NO-LOCK .
    if available LOCKED_variant-delivery  then do:
      find first X_delivery-type no-lock where
                X_delivery-type.deliv-type-code = locked_variant-delivery .deliv-type-code no-error .
      find first X_delivery-subject no-lock where
                X_delivery-subject.deliv-subj-code = locked_variant-delivery .deliv-subj-code no-error .
      find first X_clients no-lock where
                X_clients.obj-type = locked_variant-delivery.obj-type
           AND  X_clients.obj-code = locked_variant-delivery.obj-code   no-error .

      if available X_delivery-type
      and available X_delivery-subject
      and available X_clients
      then do:
        assign
        tt-var-deliv-gr-per-val.deliv-type-code = locked_variant-delivery.deliv-type-code
        tt-var-deliv-gr-per-val.deliv-subj-code = locked_variant-delivery.deliv-subj-code
        tt-var-deliv-gr-per-val.obj-type        = locked_variant-delivery.obj-type
        tt-var-deliv-gr-per-val.obj-code        = locked_variant-delivery.obj-code
        f-deliv-type-name = X_delivery-type.deliv-type-name
        f-deliv-subj-name = X_delivery-subject.deliv-subj-name
        f-deliv-obj-name = X_clients.obj-name
        .
     end.
     else do:
      assign
      tt-var-deliv-gr-per-val.deliv-type-code = ?
      tt-var-deliv-gr-per-val.deliv-subj-code = ?
      tt-var-deliv-gr-per-val.obj-type        = "":U
      tt-var-deliv-gr-per-val.obj-code        = ?
      f-deliv-type-name = "":U
      f-deliv-subj-name = "":U
      f-deliv-obj-name = "":U
      .
     end.
   end.
   else do:
    assign
    tt-var-deliv-gr-per-val.deliv-type-code = ?
    tt-var-deliv-gr-per-val.deliv-subj-code = ?
    tt-var-deliv-gr-per-val.obj-type        = "":U
    tt-var-deliv-gr-per-val.obj-code        = ?
    f-deliv-type-name = "":U
    f-deliv-subj-name = "":U
    f-deliv-obj-name = "":U
    .
   end.
  display
  tt-var-deliv-gr-per-val.deliv-type-code
  tt-var-deliv-gr-per-val.deliv-subj-code
  tt-var-deliv-gr-per-val.obj-type
  tt-var-deliv-gr-per-val.obj-code
  f-deliv-type-name
  f-deliv-subj-name
  f-deliv-obj-name
  with frame {&frame-name} .

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
{ ref/tabhndmv.i v-tab-order }
{ gbl/rethndmv.i v-tab-order underline-tb "APPLY 'CHOOSE' TO b-exit in frame {&frame-name}." }

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
 if p-mode  <> {&add-def}
 and p-mode <> {&update}
 and p-mode <> {&lookup}
 then do:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметров вызова p-mode"  p-mode
    view-as alert-box ERROR.
    undo, return error.
 end.
   find first X_curr_clients no-lock where
            X_curr_clients.obj-type = p-curr-obj-type
       AND X_curr_clients.obj-code = p-curr-obj-code no-error.
  if not available X_curr_clients then do:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметра вызова p-curr-obj-type p-curr-obj-code"
    p-curr-obj-type p-curr-obj-code
    view-as alert-box ERROR.
    return error .
  end.

 { gbl/curdbnum.i v-db-num }
IF v-db-num <> 0
AND (p-mode = {&add-def}
     OR p-mode = {&UPDATE} ) THEN DO:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметра вызова p-mode" p-mode skip
    "Нельзя редактировать запись ВАРИАНТ ДОСТАВКИ в УБД"
    view-as alert-box ERROR.
    return error .
END.
for each tt-variant-delivery:
  delete tt-variant-delivery.
end.
for each tt-var-deliv-gr-per-val:
  delete tt-var-deliv-gr-per-val.
end.
if p-deliv-obj-type <> "":U
or p-deliv-obj-code <> 0 then do:
   find first X_clients no-lock where
            X_clients.obj-type = p-deliv-obj-type
       AND X_clients.obj-code = p-deliv-obj-code no-error.
  if not available X_clients then do:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметра вызова p-deliv-obj-type p-deliv-obj-code"
    p-deliv-obj-type p-deliv-obj-code
    view-as alert-box ERROR.
    return error .
  end.
end.
if p-mode = {&update}
or p-mode = {&lookup}
or p-deliv-type-code  <> 0 then do:
  find first X_delivery-type no-lock where
              X_delivery-type.deliv-type-code = p-deliv-type-code no-error .
    if not avail X_delivery-type then do:
      message
      vss-workfile vss-revision vss-description skip
      "Неверное значение параметра вызова p-deliv-type-code" p-deliv-type-code skip
      view-as alert-box ERROR.
      return error .
    end.
end.
if p-mode = {&update}
or p-mode = {&lookup}
or p-deliv-subj-code  <> 0 then do:

    find first X_delivery-subject no-lock where
              X_delivery-subject.deliv-subj-code = p-deliv-subj-code no-error .
    if not avail X_delivery-subject then do:
      message
      vss-workfile vss-revision vss-description skip
      "Неверное значение параметра вызова p-deliv-subj-code" p-deliv-subj-code skip
      view-as alert-box ERROR.
      return error .
    end.
end.


IF (
    (p-deliv-type-code <> 0
      OR
    p-deliv-subj-code <> 0)
AND (p-deliv-obj-type <> "":U
     or p-deliv-obj-code <> 0)
   )
OR p-mode <> {&add-def}
THEN DO:
    IF p-mode = {&add-def} OR p-mode = {&UPDATE}  THEN DO:
      FIND FIRST LOCKED_variant-delivery EXCLUSIVE-LOCK WHERE
                LOCKED_variant-delivery.deliv-type-code = p-deliv-type-code
            AND LOCKED_variant-delivery.deliv-subj-code = p-deliv-subj-code
            AND LOCKED_variant-delivery.obj-type = p-deliv-obj-type
            AND LOCKED_variant-delivery.obj-code = p-deliv-obj-code
          NO-ERROR.
    END.
    IF p-mode = {&LOOKUP} THEN DO:
        FIND FIRST LOCKED_variant-delivery no-lock WHERE
                LOCKED_variant-delivery.deliv-type-code = p-deliv-type-code
            AND LOCKED_variant-delivery.deliv-subj-code = p-deliv-subj-code
            AND LOCKED_variant-delivery.obj-type = p-deliv-obj-type
            AND LOCKED_variant-delivery.obj-code = p-deliv-obj-code
          NO-ERROR.

   END.
   IF (p-mode = {&add-def}
    OR p-mode = {&update} )
    AND NOT AVAILABLE LOCKED_variant-delivery  THEN DO:
        IF LOCKED(LOCKED_variant-delivery) THEN DO:
            message
            vss-workfile vss-revision vss-description skip
             "Запись ВАРИАНТ ДОСТАВКИ занята"
            view-as alert-box error .
            undo, return error.
        END.
   END.
    ELSE DO:
      IF NOT AVAILABLE LOCKED_variant-delivery THEN DO:
          message
          vss-workfile vss-revision vss-description skip
          "Неверное значение параметра вызова p-deliv-type-code"  skip
          "и/или p-deliv-subj-code" skip
          "и/или p-deliv-obj-type p-deliv-obj-code"
          p-deliv-type-code p-deliv-subj-code p-deliv-obj-type p-deliv-obj-code skip
          view-as alert-box ERROR.
          return error .
     END.
    END.
    CREATE tt-variant-delivery.
    BUFFER-COPY LOCKED_variant-delivery TO tt-variant-delivery.
END.
if p-gr-per-val-code <> 0
or p-mode <> {&add-def} then do:
     IF p-mode = {&add-def} OR p-mode = {&UPDATE}  THEN DO:
        find first locked_group-period-validity exclusive-lock where
                  locked_group-period-validity.gr-per-val-code = p-gr-per-val-code  no-error .
    END.
    IF p-mode = {&LOOKUP} THEN DO:
        find first locked_group-period-validity no-lock where
                  locked_group-period-validity.gr-per-val-code = p-gr-per-val-code  no-error .

    END.
    IF (p-mode = {&add-def}
    OR p-mode = {&update} )
    AND NOT AVAILABLE LOCKED_group-period-validity  THEN DO:
        IF LOCKED(LOCKED_group-period-validity) THEN DO:
            message
            vss-workfile vss-revision vss-description skip
             "Запись ГРУППЫ СРОКОВ ХРАНЕНИЯ занята"
            view-as alert-box error .
            undo, return error.
        END.
   END.
   ELSE DO:
     if not avail locked_group-period-validity then do:
      message
      vss-workfile vss-revision vss-description skip
      "Неверное значение параметра вызова p-gr-per-val-code" p-gr-per-val-code skip
      view-as alert-box ERROR.
      return error .
    end.
  END.
  CREATE tt-group-period-validity.
  BUFFER-COPY LOCKED_group-period-validity TO tt-group-period-validity.
end.

if p-mode = {&update}
  or p-mode = {&lookup} then do:

    if p-mode = {&update} then do:
      find first locked_var-deliv-gr-per-val EXclusive-lock where
                   recid(locked_var-deliv-gr-per-val) = p-doc-rec no-wait no-error.
      if locked locked_var-deliv-gr-per-val then do:
        message
        vss-workfile vss-revision vss-description skip
         "Запись ВАРИАНТ ДОСТАВКИ ПО ГРУППЕ СРОКОВ ГОДНОСТИ занята"
        view-as alert-box error .
        undo, return error.
      end.
    end.
    else do:
      find first locked_var-deliv-gr-per-val no-lock where
                       recid(locked_var-deliv-gr-per-val) = p-doc-rec no-error .
      if not avail locked_var-deliv-gr-per-val then do:
        find first locked_var-deliv-gr-per-val no-lock where
                   locked_var-deliv-gr-per-val.deliv-type-code = p-deliv-type-code no-error .
      end.
    end.
    if not available locked_var-deliv-gr-per-val then do:
      message
      vss-workfile vss-revision vss-description skip
      "Не найдена запись ВАРИАНТ ДОСТАВКИ ПО ГРУППЕ СРОКОВ ГОДНОСТИ"
      view-as alert-box error .
      undo, return error.
    end.
    create tt-var-deliv-gr-per-val.
    buffer-copy locked_var-deliv-gr-per-val to tt-var-deliv-gr-per-val.
   end.
   else do:
     create tt-var-deliv-gr-per-val.
     assign
     tt-var-deliv-gr-per-val.deliv-type-code = (IF p-mode = {&add-def} AND p-deliv-type-code <> 0
                                                 THEN p-deliv-type-code
                                                 ELSE tt-var-deliv-gr-per-val.deliv-type-code)
     tt-var-deliv-gr-per-val.deliv-subj-code = (IF p-mode = {&add-def} AND p-deliv-subj-code <> 0
                                                 THEN p-deliv-subj-code
                                                 ELSE tt-var-deliv-gr-per-val.deliv-type-code)
     tt-var-deliv-gr-per-val.obj-type        = (IF p-mode = {&add-def} AND p-deliv-obj-type <> "":U
                                                 THEN p-deliv-obj-type
                                                 ELSE tt-var-deliv-gr-per-val.obj-type)
     tt-var-deliv-gr-per-val.obj-code        = (IF p-mode = {&add-def} AND p-deliv-obj-code <> 0
                                                 THEN p-deliv-obj-code
                                                 ELSE tt-var-deliv-gr-per-val.obj-code)
     tt-var-deliv-gr-per-val.gr-per-val-code  = (IF p-mode = {&add-def} AND p-gr-per-val-code <> 0
                                                 THEN p-gr-per-val-code
                                                 ELSE tt-var-deliv-gr-per-val.gr-per-val-code)

    .
   end.
  RUN Myenable.
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

  {&OPEN-QUERY-Dialog-Frame}
  GET FIRST Dialog-Frame.
  DISPLAY F-deliv-type-name F-deliv-subj-name f-deliv-obj-name F-term-delivery 
          F-gr-per-val-name f-gr-per-from f-gr-per-to 
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-var-deliv-gr-per-val THEN 
    DISPLAY tt-var-deliv-gr-per-val.deliv-type-code 
          tt-var-deliv-gr-per-val.deliv-subj-code 
          tt-var-deliv-gr-per-val.obj-type tt-var-deliv-gr-per-val.obj-code 
          tt-var-deliv-gr-per-val.gr-per-val-code tt-var-deliv-gr-per-val.des 
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-Hist B-Help B-variant-delivery f-deliv-obj-name 
         tt-var-deliv-gr-per-val.gr-per-val-code B-gr-per-val 
         tt-var-deliv-gr-per-val.des 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyENable Dialog-Frame 
PROCEDURE MyENable :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
case p-mode:
  when {&add-def} then do:
    display
    (IF tt-var-deliv-gr-per-val.deliv-type-code <> 0
     THEN tt-var-deliv-gr-per-val.deliv-type-code
     ELSE ?) @ tt-var-deliv-gr-per-val.deliv-type-code
    (IF tt-var-deliv-gr-per-val.deliv-subj-code <> 0
     THEN tt-var-deliv-gr-per-val.deliv-subj-code
     ELSE ?) @ tt-var-deliv-gr-per-val.deliv-subj-code
    (IF tt-var-deliv-gr-per-val.obj-type <> "":U
     THEN tt-var-deliv-gr-per-val.obj-type
     ELSE ?) @ tt-var-deliv-gr-per-val.obj-type
    (IF tt-var-deliv-gr-per-val.obj-code <> 0
     THEN tt-var-deliv-gr-per-val.obj-code
     ELSE ?) @ tt-var-deliv-gr-per-val.obj-code
     (if available locked_variant-delivery
     then locked_variant-delivery.term-delivery
     else ?) @ F-term-delivery
    (if available X_clients
    then X_clients.obj-name
    else "":U) @ f-deliv-obj-name
    (IF AVAILABLE X_delivery-type
     THEN X_delivery-type.deliv-type-name
     ELSE "":U) @ F-deliv-type-name
     (IF AVAILABLE X_delivery-subject
     THEN X_delivery-subject.deliv-subj-name
     ELSE "":U) @ F-deliv-subj-name
    WITH FRAME Dialog-Frame.
  end.
  otherwise do:
    IF AVAILABLE tt-var-deliv-gr-per-val THEN
    DISPLAY
    tt-var-deliv-gr-per-val.deliv-type-code
    tt-var-deliv-gr-per-val.deliv-subj-code
    tt-var-deliv-gr-per-val.obj-type
    tt-var-deliv-gr-per-val.obj-code
    tt-variant-delivery.term-delivery
    (if available  X_delivery-type then X_delivery-type.deliv-type-name else "":U) @ f-deliv-type-name
    (if available X_delivery-subject then X_delivery-subject.deliv-subj-name else "":U) @ f-deliv-subj-name
    locked_group-period-validity.gr-per-val-name @ f-gr-per-val-name
    locked_group-period-validity.gr-per-from @ f-gr-per-from
    locked_group-period-validity.gr-per-to @ f-gr-per-to
    tt-var-deliv-gr-per-val.des
    WITH FRAME Dialog-Frame.
  end.
END CASE.
if p-mode = {&lookup} then do:
assign
b-quit:label = "&Выход"
.
hide
b-exit in frame {&frame-name}.
end.


ENABLE
B-exit when p-mode <> {&lookup}
b-quit
B-Hist when p-mode <> {&add-def}
B-Help
tt-var-deliv-gr-per-val.des when p-mode <> {&lookup}
b-variant-delivery when (p-mode = {&add-def}
                         and
                         (p-deliv-type-code = 0 and p-deliv-subj-code = 0 and p-deliv-obj-code = 0))
b-gr-per-val WHEN (p-mode = {&add-def} AND p-gr-per-val-code = 0)
WITH FRAME Dialog-Frame.
VIEW FRAME Dialog-Frame.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Proc-save Dialog-Frame 
PROCEDURE Proc-save :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
if p-mode = {&lookup} then do:
    return error.
end.

if not available tt-var-deliv-gr-per-val then do:
    create tt-var-deliv-gr-per-val.
end.

assign
frame {&frame-name}
tt-var-deliv-gr-per-val.deliv-type-code
tt-var-deliv-gr-per-val.deliv-subj-code
tt-var-deliv-gr-per-val.des = tt-var-deliv-gr-per-val.des:SCREEN-VALUE
.
 run ref/vrdlgrp1.p (
input-output p-doc-rec
,input p-mode
,input tt-var-deliv-gr-per-val.deliv-type-code
,input tt-var-deliv-gr-per-val.deliv-subj-code
,input tt-var-deliv-gr-per-val.obj-type
,input tt-var-deliv-gr-per-val.obj-code
,input tt-var-deliv-gr-per-val.gr-per-val-code
,input tt-var-deliv-gr-per-val.des
)
no-error.
if error-status:error then do:
 { gbl/reterhnd.i error }
  undo, return error.
end.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

