&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame

/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER locked_delivery-type-subject FOR ub.delivery-type-subject.
DEFINE BUFFER locked_variant-delivery FOR ub.variant-delivery.
DEFINE TEMP-TABLE tt-delivery-type-subject NO-UNDO LIKE ub.delivery-type-subject.
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

Карточка редактирования ВАРИАНТА ДОСТАВКИ

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
DEFINE INPUT PARAMETER p-deliv-type-code LIKE ub.variant-delivery.deliv-type-code NO-UNDO.
DEFINE INPUT PARAMETER p-deliv-subj-code LIKE ub.variant-delivery.deliv-subj-code NO-UNDO.
DEFINE INPUT PARAMETER p-deliv-obj-type  LIKE ub.variant-delivery.obj-type NO-UNDO.
DEFINE INPUT PARAMETER p-deliv-obj-code  LIKE ub.variant-delivery.obj-code NO-UNDO.

define input-output parameter p-doc-rec as recid no-undo.

/* Local Variable Definitions ---                                       */
def var vss-revision    as character no-undo init "$Revision$":U .
def var vss-author      as character no-undo init "$Author$":U .
def var vss-date        as character no-undo init "$Date$":U .
def var vss-workfile    as character no-undo init "$Workfile$":U .
def var vss-archive     as character no-undo init "$Archive$":U .
def var vss-description as character no-undo init "Карточка редактирования ВАРИАНТА ДОСТАВКИ".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/showinf.i  }
{ gbl/getcntxt.i def }
{ gbl/userobjs.i }


define variable v-tab-order as character no-undo.
define variable v-db-num LIKE ub.db.db-num no-undo.

&scop tab-order   "B-exit,b-quit,b-hist,b-help,b-deliv-type,b-deliv-obj,term-delivery,des"

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-variant-delivery tt-delivery-type-subject

/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define FIELDS-IN-QUERY-Dialog-Frame ~
tt-variant-delivery.deliv-type-code tt-variant-delivery.deliv-subj-code ~
tt-variant-delivery.obj-type tt-variant-delivery.obj-code ~
tt-variant-delivery.term-delivery tt-variant-delivery.des
&Scoped-define ENABLED-FIELDS-IN-QUERY-Dialog-Frame ~
tt-variant-delivery.term-delivery tt-variant-delivery.des
&Scoped-define ENABLED-TABLES-IN-QUERY-Dialog-Frame tt-variant-delivery
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-Dialog-Frame tt-variant-delivery
&Scoped-define QUERY-STRING-Dialog-Frame FOR EACH tt-variant-delivery SHARE-LOCK, ~
      EACH tt-delivery-type-subject WHERE TRUE /* Join to tt-variant-delivery incomplete */ SHARE-LOCK
&Scoped-define OPEN-QUERY-Dialog-Frame OPEN QUERY Dialog-Frame FOR EACH tt-variant-delivery SHARE-LOCK, ~
      EACH tt-delivery-type-subject WHERE TRUE /* Join to tt-variant-delivery incomplete */ SHARE-LOCK.
&Scoped-define TABLES-IN-QUERY-Dialog-Frame tt-variant-delivery ~
tt-delivery-type-subject
&Scoped-define FIRST-TABLE-IN-QUERY-Dialog-Frame tt-variant-delivery
&Scoped-define SECOND-TABLE-IN-QUERY-Dialog-Frame tt-delivery-type-subject


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS tt-variant-delivery.term-delivery ~
tt-variant-delivery.des
&Scoped-define ENABLED-TABLES tt-variant-delivery
&Scoped-define FIRST-ENABLED-TABLE tt-variant-delivery
&Scoped-Define ENABLED-OBJECTS B-exit b-quit B-Hist B-Help ~
B-deliv-type-subject b-deliv-obj f-deliv-obj-name
&Scoped-Define DISPLAYED-FIELDS tt-variant-delivery.deliv-type-code ~
tt-variant-delivery.deliv-subj-code tt-variant-delivery.obj-type ~
tt-variant-delivery.obj-code tt-variant-delivery.term-delivery ~
tt-variant-delivery.des
&Scoped-define DISPLAYED-TABLES tt-variant-delivery
&Scoped-define FIRST-DISPLAYED-TABLE tt-variant-delivery
&Scoped-Define DISPLAYED-OBJECTS F-deliv-type-name F-deliv-subj-name ~
f-deliv-obj-name

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-deliv-obj
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 1"
     SIZE 3 BY 1.

DEFINE BUTTON B-deliv-type-subject
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 1"
     SIZE 3 BY 1.

DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-Hist
     LABEL "Ис&тория"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

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

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY Dialog-Frame FOR
      tt-variant-delivery,
      tt-delivery-type-subject SCROLLING.
&ANALYZE-RESUME

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-Hist AT ROW 1 COL 51
     B-Help AT ROW 1 COL 61
     tt-variant-delivery.deliv-type-code AT ROW 3 COL 27.5 COLON-ALIGNED
          LABEL "Внутр.код типа доставки"
          VIEW-AS FILL-IN
          SIZE 11 BY 1
     tt-variant-delivery.deliv-subj-code AT ROW 3 COL 66.5 COLON-ALIGNED
          LABEL "Вн.код субъекта доставки"
          VIEW-AS FILL-IN
          SIZE 11 BY 1
     B-deliv-type-subject AT ROW 3 COL 80
     F-deliv-type-name AT ROW 4.25 COL 27.5 COLON-ALIGNED
     F-deliv-subj-name AT ROW 5.5 COL 27.5 COLON-ALIGNED
     tt-variant-delivery.obj-type AT ROW 6.75 COL 27.5 COLON-ALIGNED
          LABEL "Объект доставки"
          VIEW-AS FILL-IN
          SIZE 6 BY 1
     tt-variant-delivery.obj-code AT ROW 6.75 COL 34 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 10 BY 1
     b-deliv-obj AT ROW 6.75 COL 46.5
     f-deliv-obj-name AT ROW 6.75 COL 48 COLON-ALIGNED NO-LABEL
     tt-variant-delivery.term-delivery AT ROW 8 COL 27.5 COLON-ALIGNED
          LABEL "Срок доставки(дни)"
          VIEW-AS FILL-IN
          SIZE 17 BY 1
     tt-variant-delivery.des AT ROW 11.5 COL 1 NO-LABEL
          VIEW-AS EDITOR SCROLLBAR-VERTICAL
          SIZE 98 BY 3.75
     "Описание" VIEW-AS TEXT
          SIZE 16 BY 1 AT ROW 10 COL 1.5
     SPACE(81.74) SKIP(4.66)
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
      TABLE: locked_delivery-type-subject B "?" ? ub delivery-type-subject
      TABLE: locked_variant-delivery B "?" ? ub variant-delivery
      TABLE: tt-delivery-type-subject T "?" NO-UNDO ub delivery-type-subject
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
                                                                        */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN tt-variant-delivery.deliv-subj-code IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN tt-variant-delivery.deliv-type-code IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN F-deliv-subj-name IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN
       F-deliv-subj-name:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN F-deliv-type-name IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN
       F-deliv-type-name:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN tt-variant-delivery.obj-code IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN tt-variant-delivery.obj-type IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN tt-variant-delivery.term-delivery IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _TblList          = "Temp-Tables.tt-variant-delivery,Temp-Tables.tt-delivery-type-subject WHERE Temp-Tables.tt-variant-delivery ..."
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


&Scoped-define SELF-NAME b-deliv-obj
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-deliv-obj Dialog-Frame
ON CHOOSE OF b-deliv-obj IN FRAME Dialog-Frame /* Btn 1 */
DO:
  define variable v-user-select as logical   no-undo .
  define variable v-host-code   as integer   no-undo .
  define variable v-obj-type    as character no-undo .
  define variable v-obj-code    as integer   no-undo .

  { gbl/stdbtn.i }

  { gbl/hostcode.i
    p-curr-obj-type
    p-curr-obj-code
    v-host-code
  }

  { gbl/uobjsone.i
    parparentproc
    v-cntxt-db-num
    v-cntxt-userid
    v-host-code
    p-curr-obj-type
    p-curr-obj-code
    v-user-select
    v-obj-type
    v-obj-code
  }
  if v-user-select <> true
  then do:
      assign
      tt-variant-delivery.obj-type = "":U
      tt-variant-delivery.obj-code = 0
      f-deliv-obj-name = "":U
      .
  end.
  else do:
    find first x_clients no-lock
      where x_clients.obj-type = v-obj-type
        and x_clients.obj-code = v-obj-code
      .
    assign
      tt-variant-delivery.obj-type = v-obj-type
      tt-variant-delivery.obj-code = v-obj-code
      f-deliv-obj-name             = x_clients.obj-name
    .
  end.

  display
    tt-variant-delivery.obj-type = v-obj-type
    tt-variant-delivery.obj-code = v-obj-code
    f-deliv-obj-name             = X_clients.obj-name
    with frame {&frame-name} .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-deliv-type-subject
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-deliv-type-subject Dialog-Frame
ON CHOOSE OF B-deliv-type-subject IN FRAME Dialog-Frame /* Btn 1 */
DO:
  define variable v-rid-list as character no-undo.
  define variable v-sts as integer no-undo .
{ gbl/stdbtn.i }
if available locked_delivery-type-subject then
assign
v-rid-list = string(recid(locked_delivery-type-subject))
v-sts = locked_delivery-type-subject.sts
.
run ref/dlvtysus.w (input parParentProc
              , p-curr-obj-type
              , p-curr-obj-code
              , "b-sel":U
              , {&all}
              , 0 /*p-deliv-type-code*/
              , 0 /*p-deliv-subj-code*/
              , input-output v-sts
              , input-output v-rid-list ) no-error .

if v-rid-list <> "":U then do:
    FIND FIRST LOCKED_delivery-type-subject WHERE
        recid( LOCKED_delivery-type-subject ) = integer(entry(1, v-rid-list)) NO-LOCK .
    if available LOCKED_delivery-type-subject then do:
      find first X_delivery-type no-lock where
                X_delivery-type.deliv-type-code = locked_delivery-type-subject.deliv-type-code no-error .
      find first X_delivery-subject no-lock where
                X_delivery-subject.deliv-subj-code = locked_delivery-type-subject.deliv-subj-code no-error .
      if available X_delivery-type
      and available X_delivery-subject
      then do:
        assign
        tt-variant-delivery.deliv-type-code = locked_delivery-type-subject.deliv-type-code
        tt-variant-delivery.deliv-subj-code = locked_delivery-type-subject.deliv-subj-code
        f-deliv-type-name = X_delivery-type.deliv-type-name
        f-deliv-subj-name = X_delivery-subject.deliv-subj-name
        .
     end.
     else do:
      assign
      tt-variant-delivery.deliv-type-code = ?
      tt-variant-delivery.deliv-subj-code = ?
      f-deliv-type-name = "":U
      f-deliv-subj-name = "":U
      .
     end.
   end.
   else do:
    assign
    tt-variant-delivery.deliv-type-code = ?
    tt-variant-delivery.deliv-subj-code = ?
    f-deliv-type-name = "":U
    f-deliv-subj-name = "":U
    .
   end.
  display
  tt-variant-delivery.deliv-type-code
  tt-variant-delivery.deliv-subj-code
  f-deliv-type-name
  f-deliv-subj-name
  with frame {&frame-name} .

end.

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
                ,input locked_variant-delivery.deliv-type-code
                ,input locked_variant-delivery.deliv-subj-code
                ,input locked_variant-delivery.obj-type
                ,input locked_variant-delivery.obj-code
                ,input-output v-rid-list
                              )

 .

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
 { gbl/getcntxt.i get }
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
  for each tt-delivery-type-subject:
    delete tt-delivery-type-subject.
  end.
  for each tt-variant-delivery:
    delete tt-variant-delivery.
  end.

IF p-deliv-type-code <> 0  OR p-mode <> {&add-def} THEN DO:
    IF p-mode = {&add-def} OR p-mode = {&UPDATE}  THEN DO:
      FIND FIRST LOCKED_delivery-type-subject EXCLUSIVE-LOCK WHERE
                LOCKED_delivery-type-subject.deliv-type-code = p-deliv-type-code
            AND LOCKED_delivery-type-subject.deliv-subj-code = p-deliv-subj-code  NO-ERROR.
    END.
    IF p-mode = {&LOOKUP} THEN DO:
        FIND FIRST LOCKED_delivery-type-subject no-lock WHERE
                  LOCKED_delivery-type-subject.deliv-type-code = p-deliv-type-code
              AND LOCKED_delivery-type-subject.deliv-subj-code = p-deliv-subj-code  NO-ERROR.
   END.
   IF (p-mode = {&add-def}
    OR p-mode = {&update} )
    AND NOT AVAILABLE LOCKED_delivery-type-subject  THEN DO:
        IF LOCKED(LOCKED_delivery-type-subject) THEN DO:
            message
            vss-workfile vss-revision vss-description skip
             "Запись ТИП ДОСТАВКИ ОТ СУБЪЕКТА занята"
            view-as alert-box error .
            undo, return error.
        END.
   END.
    ELSE DO:
      IF NOT AVAILABLE LOCKED_delivery-type-subject THEN DO:
          message
          vss-workfile vss-revision vss-description skip
          "Неверное значение параметра вызова p-deliv-type-code и/или p-deliv-subj-code" p-deliv-type-code p-deliv-subj-code skip
          view-as alert-box ERROR.
          return error .
        END.
    END.
    CREATE tt-delivery-type-subject.
    BUFFER-COPY LOCKED_delivery-type-subject TO tt-delivery-type-subject.
END.
IF p-deliv-obj-type <> "":U
or p-deliv-obj-code  <> 0
OR p-mode <> {&add-def} THEN DO:
    FIND FIRST X_clients NO-LOCK WHERE
            X_clients.obj-type = p-deliv-obj-type
       AND  X_clients.obj-code = p-deliv-obj-code NO-ERROR.

    IF NOT AVAILABLE X_clients  THEN DO:
        message
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметра вызова p-deliv-obj-type и/или p-deliv-obj-code" p-deliv-obj-type p-deliv-obj-code skip
        view-as alert-box ERROR.
        return error .
    END.
END.
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
if p-mode = {&update}
or p-mode = {&lookup}  then do:
    if p-mode = {&update} then do:
      find first locked_variant-delivery EXclusive-lock where
                   recid(locked_variant-delivery) = p-doc-rec no-wait no-error.
      if locked locked_variant-delivery then do:
        message
        vss-workfile vss-revision vss-description skip
         "Запись ВАРИАНТ ДОСТАВКИ занята"
        view-as alert-box error .
        undo, return error.
      end.
    end.
    else do:
      find first locked_variant-delivery no-lock where
                       recid(locked_variant-delivery) = p-doc-rec no-error .
      if not avail locked_variant-delivery then do:
        find first locked_variant-delivery no-lock where
                   locked_variant-delivery.deliv-type-code = p-deliv-type-code no-error .
      end.
    end.
    if not available locked_variant-delivery then do:
      message
      vss-workfile vss-revision vss-description skip
      "Не найдена запись ВАРИАНТ ДОСТАВКИ ОТ СУБЪЕКТА"
      view-as alert-box error .
      undo, return error.
    end.
    create tt-variant-delivery.
    buffer-copy locked_variant-delivery to tt-variant-delivery.
   end.
   else do:
     create tt-variant-delivery.
     assign
     tt-variant-delivery.deliv-type-code = (IF p-mode = {&add-def} AND p-deliv-type-code <> 0
                                                 THEN p-deliv-type-code
                                                 ELSE tt-variant-delivery.deliv-type-code)
     tt-variant-delivery.deliv-subj-code = (IF p-mode = {&add-def} AND p-deliv-subj-code <> 0
                                                 THEN p-deliv-subj-code
                                                 ELSE tt-variant-delivery.deliv-type-code)
     tt-variant-delivery.obj-type        = (IF p-mode = {&add-def} AND p-deliv-obj-type <> "":U
                                                 THEN p-deliv-obj-type
                                                 ELSE tt-variant-delivery.obj-type)
     tt-variant-delivery.obj-code        = (IF p-mode = {&add-def} AND p-deliv-obj-code <> 0
                                                 THEN p-deliv-obj-code
                                                 ELSE tt-variant-delivery.obj-code)
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
  DISPLAY F-deliv-type-name F-deliv-subj-name f-deliv-obj-name
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-variant-delivery THEN
    DISPLAY tt-variant-delivery.deliv-type-code
          tt-variant-delivery.deliv-subj-code tt-variant-delivery.obj-type
          tt-variant-delivery.obj-code tt-variant-delivery.term-delivery
          tt-variant-delivery.des
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-Hist B-Help B-deliv-type-subject b-deliv-obj
         f-deliv-obj-name tt-variant-delivery.term-delivery
         tt-variant-delivery.des
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
    (IF tt-variant-delivery.deliv-type-code <> 0
     THEN tt-variant-delivery.deliv-type-code
     ELSE ?) @ tt-variant-delivery.deliv-type-code
    (IF tt-variant-delivery.deliv-subj-code <> 0
     THEN tt-variant-delivery.deliv-subj-code
     ELSE ?) @ tt-variant-delivery.deliv-subj-code
    (IF tt-variant-delivery.obj-type <> "":U
     THEN tt-variant-delivery.obj-type
     ELSE ?) @ tt-variant-delivery.obj-type
    (IF tt-variant-delivery.obj-code <> 0
     THEN tt-variant-delivery.obj-code
     ELSE ?) @ tt-variant-delivery.obj-code
    tt-variant-delivery.term-delivery
    (if available X_clients
    then X_clients.obj-name
    else "":U) @ f-deliv-obj-name
    WITH FRAME Dialog-Frame.
  end.
  otherwise do:
    IF AVAILABLE tt-variant-delivery THEN
    DISPLAY
    tt-variant-delivery.deliv-type-code
    tt-variant-delivery.deliv-subj-code
    tt-variant-delivery.obj-type
    tt-variant-delivery.obj-code
    tt-variant-delivery.term-delivery
    X_delivery-type.deliv-type-name @ f-deliv-type-name
    X_delivery-subject.deliv-subj-name @ f-deliv-subj-name
    tt-variant-delivery.des
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
tt-variant-delivery.des when p-mode <> {&lookup}
tt-variant-delivery.term-delivery when p-mode <> {&lookup}
b-deliv-type-subject when (p-mode = {&add-def} and p-deliv-type-code = 0)
b-deliv-obj when (p-mode = {&add-def} and p-deliv-obj-code = 0)
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

if not available tt-variant-delivery then do:
    create tt-variant-delivery.
end.

assign
frame {&frame-name}
tt-variant-delivery.deliv-type-code
tt-variant-delivery.deliv-subj-code
tt-variant-delivery.term-delivery
tt-variant-delivery.des = tt-variant-delivery.des:SCREEN-VALUE
.
 run ref/vardelv1.p (
input-output p-doc-rec
,input p-mode
,input tt-variant-delivery.deliv-type-code
,input tt-variant-delivery.deliv-subj-code
,input tt-variant-delivery.obj-type
,input tt-variant-delivery.obj-code
,input tt-variant-delivery.term-delivery
,input tt-variant-delivery.des
)
no-error.
if error-status:error then do:
 { gbl/reterhnd.i error }
  undo, return error.
end.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME