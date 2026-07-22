&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Сертификаты клиента

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/27/05
Author: Bakhtadze Natalya
Creation date: 09/27/05


*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-curr-obj-type like ub.clients.obj-type no-undo .
define input parameter p-curr-obj-code like ub.clients.obj-code no-undo .
define input parameter i-point as char no-undo.
define input parameter i-type like ub.clients.obj-type no-undo.
define input parameter i-code like ub.clients.obj-code no-undo.
define input parameter i-b-code like ub.bar-code.b-code no-undo.
/* Local Variable Definitions ---                                       */

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Сертификаты клиента".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i  }
{ cmp/library.i }
{ cmp/showinf.i }
{ cmp/gds-list.i gds-list def "new shared" }
{ cmp/operlist.i }
{ gbl/cur-time.i }
{ gbl/getcntxt.i def }

define variable rid as recid no-undo.
define variable i-days as integer no-undo.
define variable s-point as char no-undo.
define variable s-type as char no-undo.
define variable s-code as integer no-undo.
define variable s-b-code like ub.bar-code.b-code no-undo.
define variable v-doc-rec as recid no-undo .

&SCOPED-DEFINE r-b-sort-all 1
&SCOPED-DEFINE r-b-sort-sert 2
&SCOPED-DEFINE r-b-sort-cli 3
&SCOPED-DEFINE r-b-sort-true 4
&SCOPED-DEFINE r-b-sort-over 5
&SCOPED-DEFINE r-b-sort-day-off 6

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br-sert

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES sert

/* Definitions for BROWSE br-sert                                       */
&Scoped-define FIELDS-IN-QUERY-br-sert sert.sert-code sert.first-date sert.last-date get-status (buffer sert) sert.sert-org sert.blank-num sert.PS
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-sert
&Scoped-define SELF-NAME br-sert
&Scoped-define QUERY-STRING-br-sert FOR EACH ub.sert       WHERE ub.sert.cli-type = i-type and ub.sert.cli-code = i-code NO-LOCK     BY sert.last-date DESCENDING
&Scoped-define OPEN-QUERY-br-sert OPEN QUERY {&SELF-NAME} FOR EACH ub.sert       WHERE ub.sert.cli-type = i-type and ub.sert.cli-code = i-code NO-LOCK     BY sert.last-date DESCENDING.
&Scoped-define TABLES-IN-QUERY-br-sert sert
&Scoped-define FIRST-TABLE-IN-QUERY-br-sert sert


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-br-sert}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit B-add b-chg b-gds b-incl b-del B-hist ~
B-Help v-type br-sert v-days r-b-sort
&Scoped-Define DISPLAYED-OBJECTS v-code v-type v-name v-days r-b-sort

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-status Dialog-Frame
FUNCTION get-status RETURNS CHARACTER
  (buffer buf-sert for ub.sert )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-add
     LABEL "&Добавить"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-chg
     LABEL "&Измeнить"
     SIZE 10 BY 1.

DEFINE BUTTON b-del
     LABEL "&Удалить"
     SIZE 10 BY 1.

DEFINE BUTTON b-exit AUTO-END-KEY
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-gds
     LABEL "&Товары"
     SIZE 10 BY 1.

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-hist
     LABEL "Ис&тория"
     SIZE 10 BY 1.

DEFINE BUTTON b-incl
     LABEL "В&ключить"
     SIZE 10 BY 1.

DEFINE VARIABLE sert-num AS CHARACTER FORMAT "X(35)":U INITIAL "12345678901234567890123456789012345"
     VIEW-AS FILL-IN
     SIZE 37 BY 1 NO-UNDO.

DEFINE VARIABLE v-code AS INTEGER FORMAT ">>>>>>>>9" INITIAL 0
     LABEL "Код"
     VIEW-AS FILL-IN
     SIZE 13.38 BY 1
     FGCOLOR 12  NO-UNDO.

DEFINE VARIABLE v-days AS INTEGER FORMAT ">>9":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 10 BY 1 NO-UNDO.

DEFINE VARIABLE v-name AS CHARACTER FORMAT "X(30)"
     LABEL "Название"
     VIEW-AS FILL-IN
     SIZE 55.25 BY 1
     FGCOLOR 12  NO-UNDO.

DEFINE VARIABLE v-type AS CHARACTER FORMAT "X(3)":U
     VIEW-AS FILL-IN
     SIZE 3.88 BY 1 NO-UNDO.

DEFINE VARIABLE r-b-sort AS INTEGER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Все", 1,
"Сертификат", 2,
"Код Контрагента", 3,
"Действ.", 4,
"Просроч.", 5,
"Истекающ.", 6
     SIZE 72.63 BY .88 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-sert FOR
      ub.sert SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-sert
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-sert Dialog-Frame _FREEFORM
  QUERY br-sert NO-LOCK DISPLAY
      ub.sert.sert-code format "x(20)"
      ub.sert.first-date
      ub.sert.last-date
      get-status (buffer ub.sert) COLUMN-LABEL "Статус" FORMAT "X(7)"
      ub.sert.sert-org
      ub.sert.blank-num
      ub.sert.PS
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 97.5 BY 10.25.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     B-add AT ROW 1 COL 11
     b-chg AT ROW 1 COL 21
     b-gds AT ROW 1 COL 31
     b-incl AT ROW 1 COL 41
     b-del AT ROW 1 COL 51
     B-hist AT ROW 1 COL 71
     B-Help AT ROW 1 COL 81.13
     v-code AT ROW 2.92 COL 4 COLON-ALIGNED
     v-type AT ROW 2.92 COL 17.75 COLON-ALIGNED NO-LABEL
     v-name AT ROW 2.92 COL 33.75 COLON-ALIGNED
     br-sert AT ROW 3.96 COL 1
     v-days AT ROW 14.46 COL 83 COLON-ALIGNED NO-LABEL
     r-b-sort AT ROW 14.63 COL 10.25 NO-LABEL
     sert-num AT ROW 15.5 COL 56 COLON-ALIGNED NO-LABEL
     "Фильтр :" VIEW-AS TEXT
          SIZE 8.38 BY .88 AT ROW 14.67 COL 1
     SPACE(89.86) SKIP(1.08)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE " Сертификаты"
         DEFAULT-BUTTON B-add CANCEL-BUTTON b-exit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
                                                                        */
/* BROWSE-TAB br-sert v-name Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN sert-num IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
/* SETTINGS FOR FILL-IN v-code IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN v-name IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-sert
/* Query rebuild information for BROWSE br-sert
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH sert
      WHERE sert.cli-type = i-type and sert.cli-code = i-code NO-LOCK
    BY sert.last-date DESCENDING.
     _END_FREEFORM
     _Options          = "NO-LOCK"
     _OrdList          = "ub.sert.last-date|no"
     _Where[1]         = "sert.cli-type = i-type and sert.cli-code = i-code"
     _Query            is OPENED
*/  /* BROWSE br-sert */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /*  Сертификаты */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-add Dialog-Frame
ON CHOOSE OF B-add IN FRAME Dialog-Frame /* Добавить */
DO:
  rid = ?.
  run ref/add-sert.w ( input parparentproc
                      ,input p-curr-obj-type
                      ,input p-curr-obj-code
                      ,input {&add-def}
                      ,input-output rid
                      ,input i-type
                      ,input i-code).
  if rid = ? then return no-apply.
  {&open-query-br-sert}
  reposition br-sert to recid rid.
  apply "ENTRY" to br-sert.
  apply "VALUE-CHANGED":U to br-sert.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-chg Dialog-Frame
ON CHOOSE OF b-chg IN FRAME Dialog-Frame /* Измeнить */
DO:
  if not available ub.sert then do:
    message "Неправильно выбрана строка.".
    return no-apply.
  end.
  rid = recid (ub.sert).
  run ref/add-sert.w ( input parparentproc
                      ,input p-curr-obj-type
                      ,input p-curr-obj-code
                      ,input {&update}
                      ,input-output rid
                      ,input i-type
                      ,input i-code).
  if rid = ? then return no-apply.
  {&open-query-br-sert}
  reposition br-sert to recid rid.
  apply "ENTRY" to br-sert.
  apply "VALUE-CHANGED":U to br-sert.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-del Dialog-Frame
ON CHOOSE OF b-del IN FRAME Dialog-Frame /* Удалить */
DO:
  define variable ri as recid no-undo.
  define variable rr as recid no-undo.
  DEFINE VARIABLE v-today as date no-undo .
  DEFINE VARIABLE v-time as integer no-undo .

  if not available ub.sert THEN return no-apply.
  message "Удалить сертификат " ub.sert.sert-code " ?"
                   view-as alert-box  warning buttons  yes-no set OK as log .
  if OK   then do:
    run cur-time in this-procedure ( output v-today, output v-time).
      if ub.sert.last-date >= v-today and can-find( first ub.sert-join where ub.sert.sert-code = ub.sert-join.sert-code) then do:
            message "По этому сертификату есть товары и сертификат не просрочен. Удаление невозможно."
            view-as alert-box error.
            return no-apply.
      end.
      ri = recid( ub.sert ).
      get prev br-sert .
      if available ub.sert
          then   rr = recid( ub.sert ).
          else do:
              get next br-sert.
              get next br-sert.
              rr = recid( sert ).
          end.
      find ub.sert where recid( ub.sert ) = ri.
      for each ub.sert-join where ub.sert-join.sert-code = ub.sert.sert-code:
        delete ub.sert-join.
      end.
      delete sert.
      run openbr in this-procedure .
      reposition br-sert to recid rr no-error.
      apply "ENTRY":U to br-sert.
      apply "VALUE-CHANGED":U to br-sert.
   end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-gds
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-gds Dialog-Frame
ON CHOOSE OF b-gds IN FRAME Dialog-Frame /* Товары */
DO:
  if avail ub.sert then
  run ref/gds-sert.w (
                 input parparentproc
               , input p-curr-obj-type
               , input p-curr-obj-code
               , input (if ub.db.add-goods then {&update} else {&lookup})
               , input "sert":U
               , input ?
               , input ub.sert.cli-type
               , input ub.sert.cli-code
               , input ub.sert.sert-code) no-error.
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-hist
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-hist Dialog-Frame
ON CHOOSE OF B-hist IN FRAME Dialog-Frame /* История */
DO:
  DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
  IF NOT AVAILABLE ub.sert THEN RETURN.
  run ref/c-serts.w (
                INPut parParentProc
               ,INPUT '':U /* bttns  */
               ,INPUT 'one' /*p-mode*/
               ,INPUT ub.sert.cli-type
               ,INPUT ub.sert.cli-code
               ,INPUT ub.sert.sert-code
               ,INPUT 0
               ,INPUT '':U
               ,INPUT-OUTPUT v-rid-list) NO-ERROR.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-incl
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-incl Dialog-Frame
ON CHOOSE OF b-incl IN FRAME Dialog-Frame /* Включить */
DO:
    find ub.bar-code where ub.bar-code.b-code = i-b-code no-lock.
    find ub.goods where ub.goods.gds-code = ub.bar-code.gds-code no-lock.
    find ub.sert-join where
            ub.sert-join.cli-type = ub.sert.cli-type    and
            ub.sert-join.cli-code = ub.sert.cli-code    and
            ub.sert-join.sert-code = ub.sert.sert-code  and
            ub.sert-join.b-code = i-b-code no-error.
    if available ub.sert-join then do:
      message "Такой сертификат для данного товара уже включен" view-as alert-box error.
      return no-apply.
    end.
    message "Вы действительно хотите включить этот сертификат для товара " ub.goods.gds-name
        view-as alert-box question buttons Yes-No update g-log as log.
    if g-log then do:
      create ub.sert-join.
      assign
      ub.sert-join.sert-code = ub.sert.sert-code
      ub.sert-join.cli-code = ub.sert.cli-code
      ub.sert-join.cli-type = ub.sert.cli-type
      ub.sert-join.b-code = i-b-code.
      release ub.sert-join no-error .
      if error-status:error then do:
        message
        "Не удалось включить сертификат для товара" skip
        error-status:get-message(1) return-value
        view-as alert-box .
      end.
   end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-sert
&Scoped-define SELF-NAME br-sert
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-sert Dialog-Frame
ON VALUE-CHANGED OF br-sert IN FRAME Dialog-Frame
DO:
     find ub.clients where ub.clients.obj-type = ub.sert.cli-type and
                                  ub.clients.obj-code = ub.sert.cli-code no-lock no-error.
     if available ub.clients then
        assign
           v-code = ub.clients.obj-code
           v-type = ub.clients.obj-type
           v-name = ub.clients.obj-name.
     else if i-code <> ? and i-type <> ? then do:
         find ub.clients where ub.clients.obj-type = i-type and
                                  ub.clients.obj-code = i-code no-lock no-error.
        assign
           v-code = i-code
           v-type = i-type
           v-name = ub.clients.obj-name.
     end.
     disp v-code v-type v-name with frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME r-b-sort
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL r-b-sort Dialog-Frame
ON VALUE-CHANGED OF r-b-sort IN FRAME Dialog-Frame
DO:
  assign r-b-sort.
  case r-b-sort:
    when {&r-b-sort-sert} then do:
        disable v-code v-type with frame {&frame-name}.
        view sert-num .
        enable sert-num with frame {&frame-name}.
        apply "entry" to sert-num.
        return no-apply.
    end.
    when {&r-b-sort-cli} then do:
        disable sert-num with frame {&frame-name}.
        hide sert-num .
        if i-point = "cli":U then do:
            message "Сортировка итак по одному клиенту" view-as alert-box warning.
            r-b-sort = {&r-b-sort-all}.
            disp r-b-sort with frame {&frame-name}.
            apply "VALUE-CHANGED":U to r-b-sort.
        end.
        else do:
            enable v-code v-type with frame {&frame-name}.
            apply "entry" to v-code.
            return no-apply.
        end.
    end.
    when {&r-b-sort-over} then do:
        disable v-type v-code sert-num v-days with frame {&frame-name}.
        hide v-type v-code v-days sert-num.
        if i-point = "over":U then do:
            message "Сортировка итак по просроченным" view-as alert-box warning.
            r-b-sort = {&r-b-sort-all}.
            disp r-b-sort with frame {&frame-name}.
            apply "VALUE-CHANGED":U to r-b-sort.
        end.
        i-point = "over":U.
        RUN OpenBr in this-procedure .
    end.
    when {&r-b-sort-true} then do:
        disable v-type v-code sert-num v-days with frame {&frame-name}.
        hide v-type v-code sert-num v-days.
        if i-point = "true":U then do:
            message "Сортировка итак по действующим" view-as alert-box warning.
            r-b-sort = {&r-b-sort-all}.
            disp r-b-sort with frame {&frame-name}.
            apply "VALUE-CHANGED":U to r-b-sort.
        end.
        i-point = "true":U.
        RUN OpenBr in this-procedure .
    end.
    when {&r-b-sort-day-off} then do:
        disable v-type v-code sert-num with frame {&frame-name}.
        hide v-type v-code sert-num .
        enable v-days with frame {&frame-name}.
        apply "entry" to v-days.
        return no-apply.
    end.
    otherwise do:
        disable sert-num v-code v-type v-days with frame {&frame-name}.
        hide sert-num v-days.
        i-point = "all":U.
        run OpenBr in this-procedure .
     end.
  end case.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME sert-num
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sert-num Dialog-Frame
ON RETURN OF sert-num IN FRAME Dialog-Frame
DO:
  def buffer buf-s for ub.sert.
  assign sert-num.
  if sert-num <> "" then do:
      find first buf-s where buf-s.sert-code = sert-num no-lock no-error.
      if available buf-s then do:
        reposition br-sert to recid recid(buf-s).
        apply "ENTRY" to br-sert.
        apply "VALUE-CHANGED":U to br-sert.
      end.
      else
        message "Сертификат не найден" view-as alert-box warning.
  end.
/*
  r-b-sort = 1.
  disp r-b-sort with frame {&frame-name}.
  apply "VALUE-CHANGED":U to r-b-sort.
  return no-apply.
*/
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME v-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-code Dialog-Frame
ON RETURN OF v-code IN FRAME Dialog-Frame /* Код */
DO:
  assign v-code .
  if v-code <> 0 then do:
        apply "ENTRY" to v-type.
        return no-apply.
/*
        apply "VALUE-CHANGED":U to br-sert.
*/
  end.
  else do:
            r-b-sort = 1.
            disp r-b-sort with frame {&frame-name}.
            apply "VALUE-CHANGED":U to r-b-sort.
            return no-apply.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME v-days
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-days Dialog-Frame
ON RETURN OF v-days IN FRAME Dialog-Frame
DO:
     assign
      v-days
      i-days = v-days
      i-point = "day-off":U.
      run Openbr in this-procedure .
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME v-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-type Dialog-Frame
ON RETURN OF v-type IN FRAME Dialog-Frame
DO:
  assign
  v-code v-type
  i-code = v-code
  i-type = v-type
  i-point = "cli":U.
  if can-find(first ub.clients where ub.clients.obj-type = i-type and ub.clients.obj-code = i-code) then
      run OpenBr in this-procedure .
  else
    message "НЕт такого контрагента" view-as alert-box warning.
  i-point = "all":U.
  return no-apply.

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
{ gbl/brwrepos.i
&line-num=5 }
{ gbl/brwrefre.i "v-doc-rec = recid(ub.sert). run openbr in this-procedure. reposition br-sert to recid(v-doc-rec). v-doc-rec = ? . " }

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

 { gbl/getcntxt.i get }
  RUN MYenable in this-procedure .
  run openbr in this-procedure .

  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI in this-procedure .

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
  DISPLAY v-code v-type v-name v-days r-b-sort
      WITH FRAME Dialog-Frame.
  ENABLE b-exit B-add b-chg b-gds b-incl b-del B-hist B-Help v-type br-sert
         v-days r-b-sort
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
define variable loc#log as logical no-undo.
define variable disablevar as integer no-undo.

assign
s-point = i-point
s-b-code = i-b-code
s-type = i-type
s-code = i-code
i-point = "all":U
.
    FIND FIRST ub.db WHERE ub.db.db-num = v-cntxt-db-num NO-LOCK .
    DISPLAY v-code v-type v-name r-b-sort
        WITH FRAME Dialog-Frame.
    ENABLE b-exit B-add b-chg b-gds b-hist B-Help br-sert b-del r-b-sort
        WITH FRAME Dialog-Frame.
    VIEW FRAME Dialog-Frame.
if s-point = "cli":U then do:
  disablevar = {&r-b-sort-cli}.
  assign
  loc#log = r-b-sort:disable(radio-label(string(disablevar), r-b-sort:radio-buttons)).
end.
    if s-point = "all":U then do:
        DISABLE b-add b-chg b-del WITH FRAME Dialog-Frame.
        ENABLE b-incl         WITH FRAME Dialog-Frame.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Openbr Dialog-Frame
PROCEDURE Openbr :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
run cur-time in this-procedure ( output v-today, output v-time).
case i-point:
  when "cli":U then dO:
    CASE s-point:
      when "ALL":U then
      OPEN QUERY br-sert
      FOR EACH ub.sert WHERE
                ub.sert.cli-type = i-type and
                ub.sert.cli-code = i-code NO-LOCK
      BY ub.sert.last-date DESCENDING.
      when "cli":U then return.
    END CASE.
  end.
  when "all":U then do:
    CASE s-point:
      when "all":U then
      OPEN QUERY br-sert
      FOR EACH ub.sert  NO-LOCK
      BY ub.sert.last-date DESCENDING.
      when "cli":U then
      OPEN QUERY br-sert
      FOR EACH ub.sert  NO-LOCK where
                (ub.sert.cli-type = s-type or s-type = ?) and
                (ub.sert.cli-code = s-code or s-code = ?)
      BY ub.sert.last-date DESCENDING.
    END CASE.
  END.
  when "true":U then do:
    CASE s-point:
      when "all":U then do:
        OPEN QUERY br-sert
        FOR EACH ub.sert  NO-LOCK WHERE
                ub.sert.last-date >= v-today
            BY ub.sert.last-date DESCENDING.
      end.
      when "cli":U then dO:
        OPEN QUERY br-sert
        FOR EACH ub.sert WHERE
                  (ub.sert.cli-type = s-type or s-type = ?) and
                  (ub.sert.cli-code = s-code or s-code = ?) AND
                  ub.sert.last-date >= v-today
            BY ub.sert.last-date DESCENDING.
      end.
    END CASE.
  end.
  when "over":U then do:
    CASE s-point:
      when "all":U then do:
        OPEN QUERY br-sert
        FOR EACH ub.sert  NO-LOCK WHERE
                ub.sert.last-date < v-today
            BY ub.sert.last-date DESCENDING.
      end.
      when "cli":U then do:
          OPEN QUERY br-sert
          FOR EACH ub.sert WHERE
                    (ub.sert.cli-type = s-type or s-type = ?) and
                    (ub.sert.cli-code = s-code or s-code = ?) AND
                    ub.sert.last-date < v-today
              BY ub.sert.last-date DESCENDING.
      end.
    END CASE.
  end.
  when "day-off":U then do:
    CASE s-point:
      when "all":U then do:
        OPEN QUERY br-sert
        FOR EACH ub.sert  NO-LOCK WHERE
                  (ub.sert.last-date > v-today AND (ub.sert.last-date - v-today) <= i-days)
            BY ub.sert.last-date DESCENDING.
      end.
      when "cli":U then do:
        OPEN QUERY br-sert
        FOR EACH ub.sert WHERE
                  (ub.sert.cli-type = s-type or s-type = ?) and
                  (ub.sert.cli-code = s-code or s-code = ?) AND
              (ub.sert.last-date > v-today AND (ub.sert.last-date - v-today) <= i-days)
            BY ub.sert.last-date DESCENDING.
      end.
    END CASE.
  end.
end case.
APPLY "VALUE-CHANGED" TO BR-SERT in frame {&frame-name}.
APPLY "ENTRY" TO BR-SERT in frame {&frame-name}.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-status Dialog-Frame
FUNCTION get-status RETURNS CHARACTER
  (buffer buf-sert for sert ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define variable stt as char .
run cur-time in this-procedure ( output v-today, output v-time).
    if buf-sert.first-date > v-today then stt = "Будущие".
    else do:
        if buf-sert.last-date > v-today then stt = "Действ".
        else
            stt =  "Просроч".
    end.
  RETURN stt.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME