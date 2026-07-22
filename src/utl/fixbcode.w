&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI ADM1
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME D-Dialog
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS D-Dialog
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Просмотр и изменение диапазонов кодов

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/23/00
Author: Dmitry Ukhanov
Creation date: 03/23/00

*/

/* Create an unnamed pool to store all the widgets created
     by this procedure. This is a good default which assures
     that this procedure's triggers and internal procedures
     will execute in this procedure's storage, and that proper
     cleanup will occur on deletion of the procedure. */

CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Просмотр и изменение диапазонов кодов".
define variable conf-par as character no-undo.
define variable mode-erprn as logical no-undo.
define variable par-type as character no-undo.

{ cmp/vssrevis.i }
{ cmp/showinf.i  }
{ cmp/trg-def.i  }
{ trg/new-bcod.i }
{ cmp/getmcode.i ub }

define variable v-curr-db-num    like ub.db.db-num             no-undo .
define variable v-curr-type-cdrg like ub.code-range.range-type no-undo .

define temp-table temp-b-code-info no-undo
  field db-num            like ub.db.db-num
  field curr-value-seq    as integer format ">>>>>>>>>>>>9" column-label "Текущее значение кода"
  field active-exist      as logical format "yes/no"    column-label "Активный"
  field active-first-code like ub.code-range.first-code column-label "Активный c"
  field active-last-code  like ub.code-range.last-code  column-label "Активный по"
  field active-b-code     like ub.bar-code.b-code format ">>>>>>>>>>>>9"
  field free-exist        as logical format "yes/no"    column-label "Свободный"
  field free-first-code   like ub.code-range.first-code column-label "Свободный c"
  field free-last-code    like ub.code-range.last-code  column-label "Свободный по"
  field free-b-code       like ub.bar-code.b-code
  field error-message     as character
  index xpk is primary unique db-num
.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE SmartDialog
&Scoped-define DB-AWARE no

&Scoped-define ADM-CONTAINER DIALOG-BOX

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME D-Dialog
&Scoped-define BROWSE-NAME BROWSE-1

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES temp-b-code-info

/* Definitions for BROWSE BROWSE-1                                      */
&Scoped-define FIELDS-IN-QUERY-BROWSE-1 db-num curr-value-seq active-exist active-first-code active-last-code active-b-code free-exist free-first-code free-last-code free-b-code error-message
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-1
&Scoped-define SELF-NAME BROWSE-1
&Scoped-define OPEN-QUERY-BROWSE-1 /* OPEN QUERY {&SELF-NAME} FOR EACH temp-b-code-info . */ run reopen-query in this-procedure .
&Scoped-define TABLES-IN-QUERY-BROWSE-1 temp-b-code-info
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-1 temp-b-code-info


/* Definitions for DIALOG-BOX D-Dialog                                  */
&Scoped-define OPEN-BROWSERS-IN-QUERY-D-Dialog ~
    ~{&OPEN-QUERY-BROWSE-1}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-gen-free b-active b-f-u b-coderg ~
b-help sel-type-code-range BROWSE-1 EDITOR-error-message
&Scoped-Define DISPLAYED-OBJECTS sel-type-code-range EDITOR-error-message

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-active DEFAULT
     LABEL "Активн."
     SIZE 10 BY 1.

DEFINE BUTTON b-coderg DEFAULT
     LABEL "Детально"
     SIZE 10 BY 1.

DEFINE BUTTON b-exit AUTO-END-KEY DEFAULT
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-f-u DEFAULT
     LABEL "Использ."
     SIZE 10 BY 1.

DEFINE BUTTON b-gen-free DEFAULT
     LABEL "Свободн."
     SIZE 10 BY 1.

DEFINE BUTTON b-help DEFAULT
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE sel-type-code-range AS CHARACTER FORMAT "X(45)":U INITIAL "глобальных собственных кодов"
     LABEL "Диапазоны"
     VIEW-AS COMBO-BOX INNER-LINES 11
     LIST-ITEM-PAIRS "1","1",
                     "2","2",
                     "3","3",
                     "4","4",
                     "5","5",
                     "6","6",
                     "7","7",
                     "8","8",
                     "9","9",
                     "10","10",
                     "11","11"
     DROP-DOWN-LIST
     SIZE 52.5 BY 1 NO-UNDO.

DEFINE VARIABLE EDITOR-error-message AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 84.5 BY 2.83
     BGCOLOR 15  NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BROWSE-1 FOR
      temp-b-code-info SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BROWSE-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-1 D-Dialog _FREEFORM
  QUERY BROWSE-1 DISPLAY
      db-num
        curr-value-seq
        active-exist
        active-first-code
        active-last-code
        active-b-code
        free-exist
        free-first-code
        free-last-code
        free-b-code
        error-message
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 84.5 BY 11.58
         BGCOLOR 15 .


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME D-Dialog
     b-exit AT ROW 1.17 COL 2
     b-gen-free AT ROW 1.17 COL 12
     b-active AT ROW 1.17 COL 22
     b-f-u AT ROW 1.17 COL 32
     b-coderg AT ROW 1.17 COL 42
     b-help AT ROW 1.17 COL 76.5
     sel-type-code-range AT ROW 2.5 COL 1.13
     BROWSE-1 AT ROW 4 COL 2
     EDITOR-error-message AT ROW 15.75 COL 2 NO-LABEL
     SPACE(0.99) SKIP(0.29)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Диапазоны кодов"
         CANCEL-BUTTON b-exit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: SmartDialog
   Allow: Basic,Browse,DB-Fields,Query,Smart
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _INCLUDED-LIB D-Dialog
/* ************************* Included-Libraries *********************** */

{src/adm/method/containr.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX D-Dialog
                                                                        */
/* BROWSE-TAB BROWSE-1 sel-type-code-range D-Dialog */
ASSIGN
       FRAME D-Dialog:SCROLLABLE       = FALSE
       FRAME D-Dialog:HIDDEN           = TRUE.

ASSIGN
       BROWSE-1:NUM-LOCKED-COLUMNS IN FRAME D-Dialog     = 1.

ASSIGN
       EDITOR-error-message:READ-ONLY IN FRAME D-Dialog        = TRUE.

/* SETTINGS FOR COMBO-BOX sel-type-code-range IN FRAME D-Dialog
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-1
/* Query rebuild information for BROWSE BROWSE-1
     _START_FREEFORM
/* OPEN QUERY {&SELF-NAME} FOR EACH temp-b-code-info . */
run reopen-query in this-procedure .
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE BROWSE-1 */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX D-Dialog
/* Query rebuild information for DIALOG-BOX D-Dialog
     _Options          = "SHARE-LOCK"
     _Query            is NOT OPENED
*/  /* DIALOG-BOX D-Dialog */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME D-Dialog
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL D-Dialog D-Dialog
ON WINDOW-CLOSE OF FRAME D-Dialog /* Диапазоны кодов */
DO:
  /* Add Trigger to equate WINDOW-CLOSE to END-ERROR. */
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-active
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-active D-Dialog
ON CHOOSE OF b-active IN FRAME D-Dialog /* Активн. */
DO:
  { gbl/stdbtn.i }

  if available temp-b-code-info then do:

    if v-curr-type-cdrg = {&loc-ss-code}
    or v-curr-type-cdrg = {&gbl-ss-code}
    then do:
      message
        "Текущее значение sequence" skip
        "для диапазона взвешиваемых кодов задавать нельзя." skip
        view-as alert-box information .
      return no-apply.

    end.

    if temp-b-code-info.db-num <> v-curr-db-num
      and v-curr-type-cdrg <> {&loc-sc-code}
      and v-curr-type-cdrg <> {&loc-ss-code}
      and v-curr-type-cdrg <> {&gbl-ss-code}
      and v-curr-type-cdrg <> {&loc-pg-code}
    then do:
      message
        "Текущее значение sequence можно задавать только для текущей базы данных" skip
        "Текущая база данных" v-curr-db-num skip
        "Выбрана база данных" temp-b-code-info.db-num skip
        view-as alert-box information .
      return no-apply.
    end.

    run put-into-active in this-procedure
      (input temp-b-code-info.db-num
      ) .

    run reopen-query in this-procedure .
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-coderg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-coderg D-Dialog
ON CHOOSE OF b-coderg IN FRAME D-Dialog /* Детально */
DO:

  { gbl/stdbtn.i }

  define variable v-db-num as integer no-undo.

  if available temp-b-code-info then do:

    if v-curr-type-cdrg = {&loc-ss-code}
      or v-curr-type-cdrg = {&loc-sc-code}
    or v-curr-type-cdrg = {&loc-pg-code}
    then do:
      assign
        v-db-num = ?
      .
    end.
    else do:
      assign
        v-db-num = temp-b-code-info.db-num
      .
    end.

    run utl/v-coderg.w ( input v-db-num
                   ,input v-curr-type-cdrg
                   ,input sel-type-code-range
                  ).

    run reopen-query in this-procedure .
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-f-u
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-f-u D-Dialog
ON CHOOSE OF b-f-u IN FRAME D-Dialog /* Использ. */
DO:
/* Помечает диапазон "f" как "u", если есть хоть один код внутри этого диапазона */
  { gbl/stdbtn.i }

  define variable v-b-code         like ub.bar-code.b-code no-undo .

  if available temp-b-code-info then do:

    if v-curr-type-cdrg = {&loc-ss-code}
    or v-curr-type-cdrg = {&gbl-ss-code}
    then do:
      message
        "Помечать свободный диапазон как использованный" skip
        "для диапазона взвешиваемых кодов нельзя." skip
        view-as alert-box information .
      return no-apply.
    end.

    if temp-b-code-info.db-num <> v-curr-db-num
      and v-curr-type-cdrg <> {&loc-sc-code}
      and v-curr-type-cdrg <> {&loc-pg-code}
    then do:
      message
        "Помечать свободный диапазон как использованный," skip
        "если есть хоть один код внутри этого диапазона," skip
        "можно только для текущей базы данных" skip
        "Текущая база данных" v-curr-db-num skip
        "Выбрана база данных" temp-b-code-info.db-num skip
        view-as alert-box information .
      return no-apply.
    end.

    run get-max-code in this-procedure
      ( input "f-u":U
       ,input v-curr-db-num
       ,input v-curr-type-cdrg
       ,input ?
       ,input ?
       ,input TRUE
       ,output v-b-code
      ).
    message
      "Просмотр окончен." skip
      "Исправлено статусов диапазонов" v-b-code
      view-as alert-box information
    .
    run reopen-query in this-procedure .
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-gen-free
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-gen-free D-Dialog
ON CHOOSE OF b-gen-free IN FRAME D-Dialog /* Свободн. */
DO:
  { gbl/stdbtn.i }

  if available temp-b-code-info then do:
    run gen-free-code-range in this-procedure
      (input temp-b-code-info.db-num
      ) .
    run reopen-query in this-procedure .

  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BROWSE-1
&Scoped-define SELF-NAME BROWSE-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BROWSE-1 D-Dialog
ON VALUE-CHANGED OF BROWSE-1 IN FRAME D-Dialog
DO:
  run display-dependent-info in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME sel-type-code-range
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sel-type-code-range D-Dialog
ON VALUE-CHANGED OF sel-type-code-range IN FRAME D-Dialog /* Диапазоны */
DO:
  assign sel-type-code-range .
  if mode-erprn 
     and can-do("{&bef-gbl-bc-code},{&bef-gbl-fm-code},{&bef-gbl-pn-code},{&bef-gbl-fd-code},{&bef-gbl-ct-code},{&bef-gbl-dr-code},{&bef-loc-sc-code},{&bef-loc-ss-code},{&bef-loc-pg-code},{&bef-gbl-ca-code}",sel-type-code-range)
  then do:
     if sel-type-code-range = {&gbl-ca-code} then 
     enable 
     b-active
     b-gen-free
     b-f-u
     b-coderg
     with frame {&frame-name} .

     else
     disable 
     b-active
     b-gen-free
     b-f-u
     b-coderg
     with frame {&frame-name} .

  end.   
  else
     assign
        b-active:SENSITIVE = yes
        b-gen-free:SENSITIVE = yes
        b-f-u:SENSITIVE = yes
        b-coderg:SENSITIVE = yes

     .
  assign
  v-curr-type-cdrg = sel-type-code-range .
  run fill-temp-b-code-info .
  run reopen-query in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK D-Dialog


/* ***************************  Main Block  *************************** */

{ gbl/app_help.i }
       { gbl/conf-rd.i
         "'is-erpRN'"
          0
          "''"
          0
          "''"
          "''"
          "''"
          NO
          conf-par
          par-type
          no-error
          }
          if not error-status:error and conf-par = "yes":U then mode-erprn = yes.
          else mode-erprn = no.
       
define buffer buf_sys-ctrl for ub.sys-ctrl .
assign
  sel-type-code-range:list-item-pairs  in frame {&frame-name} =
  "глобальных собственных кодов" + {&comma-char} + {&gbl-bc-code} + {&comma-char} +
  "глобальных весовых кодов" + {&comma-char} + {&gbl-sc-code}  + {&comma-char} +
  "локальных весовых кодов" + {&comma-char} + {&loc-sc-code} + {&comma-char} +
  "локальных штучных кодов для весов" + {&comma-char} + {&loc-pg-code} + {&comma-char} +
  "глобальных взвешиваемых кодов" + {&comma-char} + {&gbl-ss-code} + {&comma-char} +
  "локальных взвешиваемых кодов" + {&comma-char} + {&loc-ss-code} + {&comma-char} +
  "глобальных кодов правил скидок и расписаний" + {&comma-char} + {&gbl-dr-code} + {&comma-char} +
  "внутренних кодов дисконтных карт" + {&comma-char} +  {&gbl-dc-code} + {&comma-char} +
  "глобальных кодов организаций" + {&comma-char} +  {&gbl-fm-code} + {&comma-char} +
  "глобальных кодов физ.лиц" + {&comma-char} + {&gbl-pn-code} + {&comma-char} +
  "глобальных кодов договоров" + {&comma-char} + {&gbl-ct-code} + {&comma-char} +
  "глобальных кодов точек привязки" + {&comma-char} + {&gbl-ca-code} + {&comma-char} +
  "глобальных кодов фин.документов" + {&comma-char} + {&gbl-fd-code}
.
assign
  sel-type-code-range = {&gbl-bc-code}
  sel-type-code-range:screen-value = {&gbl-bc-code}
.

do:
  browse {&browse-name} :set-repositioned-row( 5, "conditional" ) .
end.

apply "value-changed" to sel-type-code-range in frame {&frame-name} .

find first buf_sys-ctrl no-lock .
assign
  frame {&frame-name}:title = frame {&frame-name}:title + {&space-char} + substitute( "(БД &1)", buf_sys-ctrl.db-num )
.

{src/adm/template/dialogmn.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE adm-create-objects D-Dialog  _ADM-CREATE-OBJECTS
PROCEDURE adm-create-objects :
/*------------------------------------------------------------------------------
  Purpose:     Create handles for all SmartObjects used in this procedure.
               After SmartObjects are initialized, then SmartLinks are added.
  Parameters:  <none>
------------------------------------------------------------------------------*/

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE adm-row-available D-Dialog  _ADM-ROW-AVAILABLE
PROCEDURE adm-row-available :
/*------------------------------------------------------------------------------
  Purpose:     Dispatched to this procedure when the Record-
               Source has a new row available.  This procedure
               tries to get the new row (or foriegn keys) from
               the Record-Source and process it.
  Parameters:  <none>
------------------------------------------------------------------------------*/

  /* Define variables needed by this internal procedure.             */
  {src/adm/template/row-head.i}

  /* Process the newly available records (i.e. display fields,
     open queries, and/or pass records on to any RECORD-TARGETS).    */
  {src/adm/template/row-end.i}

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI D-Dialog  _DEFAULT-DISABLE
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
  HIDE FRAME D-Dialog.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE display-dependent-info D-Dialog
PROCEDURE display-dependent-info :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  do
  on error undo, return error
  :
    if available temp-b-code-info then do:
      do with frame {&frame-name}
      :
        assign
          editor-error-message :screen-value = temp-b-code-info.error-message
        .
      end. /* do with frame */
    end.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI D-Dialog  _DEFAULT-ENABLE
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
  DISPLAY sel-type-code-range EDITOR-error-message
      WITH FRAME D-Dialog.
  ENABLE b-exit b-gen-free b-active b-f-u b-coderg b-help sel-type-code-range
         BROWSE-1 EDITOR-error-message
      WITH FRAME D-Dialog.
  VIEW FRAME D-Dialog.
  {&OPEN-BROWSERS-IN-QUERY-D-Dialog}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-temp-b-code-info D-Dialog
PROCEDURE fill-temp-b-code-info :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  do
  on error undo, return error
  :
    define buffer buf_temp-b-code-info for temp-b-code-info .
    define buffer buf_db               for ub.db .
    define buffer buf_code-range       for ub.code-range .
    define buffer buf_bar-code         for ub.bar-code .
    define buffer buf_dis-card         for ub.dis-card.
    define buffer buf_dis-rule         for ub.dis-rule.
    define buffer buf_dis-time-rule    for ub.dis-time-rule.
    define buffer buf_clients          for ub.clients.
    define buffer buf_contract         for ub.contract.
    define buffer buf_rule-by-call     for ub.rule-by-call.
    define buffer buf_sysconf          for ub.sysconf.
    define buffer buf_fin-doc          for ub.fin-doc.
    define variable v-code-1           as integer no-undo .
    define variable v-code-2           as integer no-undo .

    define buffer buf_sys-ctrl for ub.sys-ctrl .

    find first buf_sys-ctrl no-lock .
    assign
      v-curr-db-num = buf_sys-ctrl.db-num
    .

    for each buf_temp-b-code-info
    :
      delete buf_temp-b-code-info .
    end.

    for each buf_db
          by buf_db.db-num
    on error undo, return error
    :
      /* показать информацию по базе данных */

      create buf_temp-b-code-info .
      assign
        buf_temp-b-code-info.db-num = buf_db.db-num
      .

      if buf_db.db-num = v-curr-db-num
         or v-curr-type-cdrg = {&loc-sc-code}
         or v-curr-type-cdrg = {&loc-pg-code}
         or v-curr-type-cdrg = {&loc-ss-code}
      then do:
        case v-curr-type-cdrg:
          when {&gbl-bc-code} then do:
            assign
              buf_temp-b-code-info.curr-value-seq = current-value(s-bcgb-code, {&db-name_schema})
            .
          end.
          when {&gbl-sc-code} then do:
            assign
              buf_temp-b-code-info.curr-value-seq = current-value(s-scgb-code, {&db-name_schema})
            .
          end.
          when {&loc-sc-code} then do:
            assign
              buf_temp-b-code-info.curr-value-seq = current-value(s-sclc-code, {&db-name_schema})
            .
          end.
          when {&loc-pg-code} then do:
            assign
              buf_temp-b-code-info.curr-value-seq = current-value(s-pglc-code, {&db-name_schema})
            .
          end.
          when {&gbl-ss-code} then do:
            assign
              buf_temp-b-code-info.curr-value-seq = ?
            .
          end.
          when {&loc-ss-code} then do:
            assign
              buf_temp-b-code-info.curr-value-seq = ?
            .
          end.
          when {&gbl-fm-code} then do:
            assign
              buf_temp-b-code-info.curr-value-seq = current-value(s-fmgb-code, {&db-name_schema})
            .
          end.
          when {&gbl-pn-code} then do:
            assign
              buf_temp-b-code-info.curr-value-seq = current-value(s-pngb-code, {&db-name_schema})
            .
          end.
          when {&gbl-dr-code} then do:
            assign
              buf_temp-b-code-info.curr-value-seq = current-value(s-drgb-code, {&db-name_schema})
            .
          end.
          when {&gbl-dc-code} then do:
            assign
              buf_temp-b-code-info.curr-value-seq = current-value(s-dcgb-code, {&db-name_schema})
            .
          end.
          when {&gbl-ct-code} then do:
            assign
              buf_temp-b-code-info.curr-value-seq = current-value(s-ctgb-code, {&db-name_schema})
            .
          end.
          when {&gbl-ca-code} then do:
            assign
              buf_temp-b-code-info.curr-value-seq = current-value(s-cagb-code, {&db-name_schema})
            .
          end.
          when {&gbl-fd-code} then do:
            assign
              buf_temp-b-code-info.curr-value-seq = current-value(s-fin-doc, {&db-name_schema})
            .
          end.
        end case.
      end.
      else do:
        assign
          buf_temp-b-code-info.curr-value-seq = ?
        .
      end.

      find first buf_code-range no-lock
        where buf_code-range.db-num     = buf_db.db-num
          and buf_code-range.range-type = v-curr-type-cdrg
          and buf_code-range.stts       = "a"
        no-error .
      if available buf_code-range then do:
        assign
          buf_temp-b-code-info.active-exist      = true
          buf_temp-b-code-info.active-first-code = buf_code-range.first-code
          buf_temp-b-code-info.active-last-code  = buf_code-range.last-code
          buf_temp-b-code-info.active-b-code = ?
          v-code-1 = 0
          v-code-2 = 0
        .
        case v-curr-type-cdrg:
          when {&gbl-bc-code} then do:

            for each buf_bar-code no-lock
              where buf_bar-code.b-code >= buf_code-range.first-code
                and buf_bar-code.b-code <= buf_code-range.last-code
            by buf_bar-code.b-code descending
            :
              assign
                buf_temp-b-code-info.active-b-code = buf_bar-code.b-code
              .
              leave . /* --->>>--- */
            end.
          end. /*{&gbl-bc-code}*/
          when {&gbl-dc-code} then do:
            for each buf_dis-card no-lock
              where buf_dis-card.card-num >= buf_code-range.first-code
                and buf_dis-card.card-num <= buf_code-range.last-code
            by buf_dis-card.card-num descending
            :
              assign
                buf_temp-b-code-info.active-b-code = buf_dis-card.card-num
              .
              leave . /* --->>>--- */
            end.
          end.
          when {&gbl-fm-code}
          or
          when {&gbl-pn-code}
          then do:
            for each buf_clients no-lock
              where buf_clients.obj-type = (if v-curr-type-cdrg = {&gbl-fm-code} then {&cmp} else {&prs})
                and buf_clients.obj-code >= buf_code-range.first-code
                and buf_clients.obj-code <= buf_code-range.last-code
            by buf_clients.obj-code descending
            :
              assign
                buf_temp-b-code-info.active-b-code = buf_clients.obj-code
              .
              leave . /* --->>>--- */
            end.
          end.
          when {&gbl-dr-code} then do:
            for each buf_dis-rule no-lock
              where buf_dis-rule.rule-num >= buf_code-range.first-code
                and buf_dis-rule.rule-num <= buf_code-range.last-code
            by buf_dis-rule.rule-num descending
            :
              assign
                v-code-1 = buf_dis-rule.rule-num
              .
              leave . /* --->>>--- */
            end.
            for each buf_dis-time-rule no-lock
              where buf_dis-time-rule.time-rule-num >= buf_code-range.first-code
                and buf_dis-time-rule.time-rule-num <= buf_code-range.last-code
            by buf_dis-time-rule.time-rule-num descending
            :
              assign
              v-code-2 = buf_dis-time-rule.time-rule-num
              .
              leave . /* --->>>--- */
            end.
            assign
              buf_temp-b-code-info.active-b-code = maximum (v-code-1, v-code-2)
            .

          end.
          when {&loc-sc-code} then do:

          end.
          when {&loc-pg-code} then do:

          end.
          when {&gbl-ct-code} then do:
            for each buf_contract no-lock
              where buf_contract.contract-code >= buf_code-range.first-code
                and buf_contract.contract-code <= buf_code-range.last-code
            by buf_contract.contract-code descending
            :
              assign
                buf_temp-b-code-info.active-b-code = buf_contract.contract-code
              .
              leave . /* --->>>--- */
            end.
          end.
          when {&gbl-ca-code} then do:
            for each buf_rule-by-call no-lock
              where buf_rule-by-call.call#_id >= buf_code-range.first-code
                and buf_rule-by-call.call#_id <= buf_code-range.last-code
            by buf_rule-by-call.call#_id descending
            :
              assign
                buf_temp-b-code-info.active-b-code = buf_rule-by-call.call#_id
              .
              leave . /* --->>>--- */
            end.
          end.
          when {&gbl-fd-code} then do:
            for each buf_sysconf no-lock:
              _fin-doc:
              for each buf_fin-doc no-lock
              where buf_fin-doc.host-code = buf_sysconf.host-code
                and buf_fin-doc.fin-doc-code >= buf_code-range.first-code
                and buf_fin-doc.fin-doc-code <= buf_code-range.last-code
              by buf_fin-doc.fin-doc-code descending
              :
                if buf_fin-doc.fin-doc-code > buf_temp-b-code-info.active-b-code then do:
                  assign
                    buf_temp-b-code-info.active-b-code = buf_fin-doc.fin-doc-code
                  .
                  leave _fin-doc. /* --->>>--- */
                end. /*if buf_fin-doc.fin-doc-code > buf_temp-b-code-info.active-b-code then do:*/
                if buf_fin-doc.fin-doc-code <= buf_temp-b-code-info.active-b-code then do:
                  leave _fin-doc. /* --->>>--- */
                end. /*if buf_fin-doc.fin-doc-code > buf_temp-b-code-info.active-b-code then do:*/
              end. /*              for each buf_fin-doc no-lock*/
            end. /*            for each buf_sysconf no-lock:*/
          end. /*when {&gbl-fd-code} then do:*/
        END CASE.
      end. /*if available buf_code-range then do:*/
      find first buf_code-range no-lock
        where buf_code-range.db-num     = buf_db.db-num
          and buf_code-range.range-type = v-curr-type-cdrg
          and buf_code-range.stts       = "f"
        no-error .
      if available buf_code-range then do:
        assign
          buf_temp-b-code-info.free-exist      = true
          buf_temp-b-code-info.free-first-code = buf_code-range.first-code
          buf_temp-b-code-info.free-last-code  = buf_code-range.last-code
        .
        for each buf_bar-code no-lock
          where buf_bar-code.b-code >= buf_code-range.first-code
            and buf_bar-code.b-code <= buf_code-range.last-code
        by buf_bar-code.b-code descending
        :
          assign
            buf_temp-b-code-info.free-b-code = buf_bar-code.b-code
          .
          leave . /* --->>>--- */
        end.
      end.

      assign
        buf_temp-b-code-info.error-message
          = "База данных " + string(buf_temp-b-code-info.db-num)
      .

      if  buf_temp-b-code-info.active-exist = false
      and buf_temp-b-code-info.free-exist   = false then do:
        assign
          buf_temp-b-code-info.error-message
            = buf_temp-b-code-info.error-message
            + {&new-line}
            + "У базы отсутствуют активный и свободные диапазоны"
        .
      end.

      if  buf_temp-b-code-info.active-exist = true
      and buf_temp-b-code-info.db-num = v-curr-db-num
      and buf_temp-b-code-info.curr-value-seq > ( buf_temp-b-code-info.active-first
                                            + buf_temp-b-code-info.active-last ) / 2
      and buf_temp-b-code-info.free-exist   = false
      then do:
        assign
          buf_temp-b-code-info.error-message
            = buf_temp-b-code-info.error-message
            + {&new-line}
            + "Текущее значение sequence превышает середину активного диапазона "
            + "и не создан свободный диапазон"
            + (if   buf_temp-b-code-info.db-num <> 0
               then {&new-line} + "Для удаленной базы данных это может быть вызвано "
                + "задержкой передачи информации по новостям"
               else ""
              )
        .
      end.
      if v-curr-type-cdrg = {&loc-sc-code}
         or v-curr-type-cdrg = {&loc-ss-code}
         or v-curr-type-cdrg = {&loc-pg-code}
      then do:
        leave.
      end.
    end.

  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE gen-free-code-range D-Dialog
PROCEDURE gen-free-code-range :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/

  do
  on error undo, return error
  :
    define input parameter p-db-num like ub.db.db-num no-undo .

    define buffer buf_temp-b-code-info for temp-b-code-info .

    define variable lok as logical   no-undo .

    find first buf_temp-b-code-info
      where buf_temp-b-code-info.db-num = p-db-num
      no-error .
    if buf_temp-b-code-info.free-exist then do:
      assign
        lok = false
      .
      message
        "Для базы данных уже существует свободный диапазон." skip
        "База данных" p-db-num skip
        "Вы уверены, что хотите сгенерировать ЕЩЕ ОДИН свободный диапазон?" skip
        view-as alert-box question buttons yes-no update lok .
      if lok <> true then do:
        return . /* --->>>-- */
      end.
    end.
    else do:
      assign
        lok = false
      .
      message
        "База данных" p-db-num skip
        "Вы хотите сгенерировать свободный диапазон?" skip
        view-as alert-box question buttons yes-no update lok .
      if lok <> true then do:
        return . /* --->>>-- */
      end.
    end.

    run new-bcod-gen-code-range in this-procedure
      (input p-db-num,  /* p-db-num */
       input v-curr-type-cdrg
      ) no-error .
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при создании нового свободного диапазона" skip
        "База данных" p-db-num skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.
    else do:
      message
        return-value skip
        "База данных" p-db-num skip
        view-as alert-box information .
    end.

  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE put-into-active D-Dialog
PROCEDURE put-into-active :
/* устанавливает sequences внутрь активного диапазона */

  do
  on error undo, return error
  :
    define input parameter p-db-num like ub.db.db-num no-undo .

    define variable v-b-code         like ub.bar-code.b-code no-undo .
    define variable v-old-value      as integer              no-undo .
    define variable v-new-value      as integer              no-undo .
    define variable lok              as logical              no-undo .

    define buffer buf_code-range for ub.code-range .
    define buffer buf_bar-code   for ub.bar-code .

    find first buf_code-range no-lock
      where buf_code-range.db-num     = p-db-num
        and buf_code-range.range-type = v-curr-type-cdrg
        and buf_code-range.stts       = "a":U
      no-error .
    if not available buf_code-range then do:
      message
        "Отсутствует активный диапазон" skip
        "Невозможно установить значение sequence внутрь активного диапазона" skip
        "База данных" p-db-num skip
        view-as alert-box information .
      return . /* --->>>--- */
    end.
    else do:
      run get-max-code ( input "get-m-code":U
                        ,input buf_code-range.db-num
                        ,input buf_code-range.range-type
                        ,input buf_code-range.first-code
                        ,input buf_code-range.last-code
                        ,input TRUE
                        ,output v-b-code
                       ).

      if v-b-code <= buf_code-range.last-code then do:
        /* устанавливаем */
        case v-curr-type-cdrg:
          when {&gbl-bc-code} then do:
            { utl/fixbcode.i s-bcgb-code}
          end.
          when {&gbl-sc-code} then do:
            { utl/fixbcode.i s-scgb-code}
          end.
          when {&loc-sc-code} then do:
            { utl/fixbcode.i s-sclc-code}
          end.
          when {&loc-pg-code} then do:
            { utl/fixbcode.i s-pglc-code}
          end.
          when {&gbl-dr-code} then do:
            { utl/fixbcode.i s-drgb-code}
          end.
          when {&gbl-fm-code} then do:
            { utl/fixbcode.i s-fmgb-code}
          end.
          when {&gbl-pn-code} then do:
            { utl/fixbcode.i s-pngb-code}
          end.
          when {&gbl-dc-code} then do:
            { utl/fixbcode.i s-dcgb-code}
          end.
          when {&gbl-ct-code} then do:
            { utl/fixbcode.i s-ctgb-code }
          end.
          when {&gbl-ca-code} then do:
            { utl/fixbcode.i s-cagb-code }
          end.
          when {&gbl-fd-code} then do:
             { utl/fixbcode.i s-fin-doc }
          end.
        end case.
      end.

    end.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE reopen-query D-Dialog
PROCEDURE reopen-query :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/

  do
  on error undo, return error
  :
    define buffer buf_temp-b-code-info for temp-b-code-info .

    define variable v-reposition-db-num like ub.db.db-num no-undo .

    if available temp-b-code-info then do:
      assign
        v-reposition-db-num = temp-b-code-info.db-num
      .
    end.

    run fill-temp-b-code-info in this-procedure .
    OPEN QUERY {&BROWSE-NAME} FOR EACH temp-b-code-info .

    if v-reposition-db-num <> 0 then do:
      find first buf_temp-b-code-info
        where buf_temp-b-code-info.db-num = v-reposition-db-num
        no-error .
      if available buf_temp-b-code-info then do:
        reposition {&browse-name} to rowid rowid(buf_temp-b-code-info) no-error .
      end.
    end.

    run display-dependent-info in this-procedure .

  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE send-records D-Dialog  _ADM-SEND-RECORDS
PROCEDURE send-records :
/*------------------------------------------------------------------------------
  Purpose:     Send record ROWID's for all tables used by
               this file.
  Parameters:  see template/snd-head.i
------------------------------------------------------------------------------*/

  /* Define variables needed by this internal procedure.               */
  {src/adm/template/snd-head.i}

  /* For each requested table, put it's ROWID in the output list.      */
  {src/adm/template/snd-list.i "temp-b-code-info"}

  /* Deal with any unexpected table requests before closing.           */
  {src/adm/template/snd-end.i}

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE state-changed D-Dialog
PROCEDURE state-changed :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  DEFINE INPUT PARAMETER p-issuer-hdl AS HANDLE NO-UNDO.
  DEFINE INPUT PARAMETER p-state AS CHARACTER NO-UNDO.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME