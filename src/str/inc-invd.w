&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME d-chk

/* Temp-Table and Buffer definitions                                    */
DEFINE NEW SHARED BUFFER X_chk-doc FOR ub.chk-doc.


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS d-chk
/*------------------------------------------------------------------------

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Закачка чеков в инвентаризацию

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/17/05
Author: Bakhtadze Natalya
Creation date: 09/17/05


         ! ! !  В Н И М А Н И Е  ! ! !
   не забудь: после исправления файла в UIB

   САМОЕ ГЛАВНОЕ - подставить new shared в DEFINE QUERY query-chk-doc !!!!!!!


------------------------------------------------------------------------ */

/* ***************************  Definitions  ************************** */
define input parameter parparentproc AS WIDGET-HANDLE no-undo.
define input parameter p-mode as character no-undo .
/*update для закачки чеков delete для показа после удаления чеков*/
define input parameter p-rid-list as character no-undo .
/*список recid выбранных чеков*/
define input parameter p-chk-gds-rid-list  as character no-undo .
/*recid  chk-gds который надо посчитать - если ? - то все*/
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .
define parameter buffer t-doc for ub.trn-doc.

define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Закачка чеков в документ инвентаризации и/или обсчет строк" .
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/showinf.i }
{ cmp/operlist.i }
{ str/trdcalib.i }
{ str/lib-def.i }

/*использовать смены на кассе для данного объекта*/
define variable cas-shft as logical no-undo init no.
/*использовать смены для данного объекта*/
define variable l-shift-on as logical no-undo init no.
define variable conf-attr as char no-undo.                  /* для чтения параметра конфигурации */
define variable conf-par as char no-undo.                  /* для чтения параметра конфигурации */
define variable par-type as char no-undo.
define variable glog as logical no-undo .
define variable v-rid-list as character no-undo .
define variable is-all as logical no-undo .
define variable v-chk-date as date no-undo .
define variable v-chk-time as integer no-undo .
define variable v-shift-date as date no-undo .
define variable v-shift-num as integer no-undo .
define variable v-shift-name               as character no-undo.
define variable v-shift-name-num           as character no-undo.
define buffer buf_chk-doc for ub.chk-doc.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME d-chk
&Scoped-define QUERY-NAME QUERY-chk-doc

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_chk-doc

/* Definitions for QUERY QUERY-chk-doc                                  */
&Scoped-define QUERY-STRING-QUERY-chk-doc FOR EACH X_chk-doc ~
      WHERE X_chk-doc.obj-type = p-obj-type ~
 AND X_chk-doc.obj-code = p-obj-code ~
 AND X_chk-doc.out-code = ? NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-QUERY-chk-doc OPEN QUERY QUERY-chk-doc FOR EACH X_chk-doc ~
      WHERE X_chk-doc.obj-type = p-obj-type ~
 AND X_chk-doc.obj-code = p-obj-code ~
 AND X_chk-doc.out-code = ? NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-QUERY-chk-doc X_chk-doc
&Scoped-define FIRST-TABLE-IN-QUERY-QUERY-chk-doc X_chk-doc


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS ub.chk-doc.shift-date ub.chk-doc.chk-num ~
ub.chk-doc.pay-desk ub.chk-doc.cashier ub.chk-doc.doc-code
&Scoped-define ENABLED-TABLES ub.chk-doc
&Scoped-define FIRST-ENABLED-TABLE ub.chk-doc
&Scoped-Define ENABLED-OBJECTS b-exit RECT-1 b-quit b-help RS-get-method ~
chk-amount f-processed f-processed-ok E-message f-shift-name f-shift-num ~
time_
&Scoped-Define DISPLAYED-FIELDS ub.chk-doc.shift-date ub.chk-doc.chk-num ~
ub.chk-doc.pay-desk ub.chk-doc.cashier ub.chk-doc.doc-code
&Scoped-define DISPLAYED-TABLES ub.chk-doc
&Scoped-define FIRST-DISPLAYED-TABLE ub.chk-doc
&Scoped-Define DISPLAYED-OBJECTS RS-get-method chk-amount f-processed ~
f-processed-ok E-message f-shift-name f-shift-num time_

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Ввод "
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-quit AUTO-GO
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE E-message AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 98 BY 2.13
     BGCOLOR 8  NO-UNDO.

DEFINE VARIABLE chk-amount AS INTEGER FORMAT "->>>9":U INITIAL 0
     LABEL "ВСЕГО Чеков по инвентар."
     VIEW-AS FILL-IN
     SIZE 5 BY 1
     BGCOLOR 3 FGCOLOR 14  NO-UNDO.

DEFINE VARIABLE f-processed AS INTEGER FORMAT ">,>>>,>>9":U INITIAL 0
     LABEL "Просмотрено строк"
     VIEW-AS FILL-IN
     SIZE 11 BY 1
     BGCOLOR 3  NO-UNDO.

DEFINE VARIABLE f-processed-ok AS INTEGER FORMAT ">,>>>,>>9":U INITIAL 0
     LABEL "Обработано строк"
     VIEW-AS FILL-IN
     SIZE 11 BY 1
     BGCOLOR 3  NO-UNDO.

DEFINE VARIABLE f-shift-name AS CHARACTER FORMAT "X(3)":U
     LABEL "№ смены"
     VIEW-AS FILL-IN
     SIZE 3 BY 1
     BGCOLOR 8 FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE f-shift-num AS INTEGER FORMAT ">9":U INITIAL 1
     LABEL "Пор. смены"
     VIEW-AS FILL-IN
     SIZE 5 BY 1
     BGCOLOR 8 FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE time_ AS CHARACTER FORMAT "x(8)"
     LABEL "Время"
     VIEW-AS FILL-IN
     SIZE 10.3 BY 1
     BGCOLOR 8 FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE RS-get-method AS CHARACTER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Все свободные чеки по объекту с заданными условиями", "inc-invr",
"Чеки выборочно", "chk-docs"
     SIZE 70.5 BY 1.77 NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE 98 BY 1.87
     BGCOLOR 8 FGCOLOR 0 .

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE NEW SHARED QUERY QUERY-chk-doc FOR
      X_chk-doc SCROLLING.
&ANALYZE-RESUME

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME d-chk
     b-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     b-help AT ROW 1 COL 81
     RS-get-method AT ROW 2.27 COL 7 NO-LABEL
     chk-amount AT ROW 4.97 COL 26 COLON-ALIGNED
     f-processed AT ROW 4.97 COL 51.5 COLON-ALIGNED
     f-processed-ok AT ROW 4.97 COL 83.5 COLON-ALIGNED
     E-message AT ROW 6.6 COL 1 NO-LABEL
     ub.chk-doc.shift-date AT ROW 9 COL 43.5 COLON-ALIGNED FORMAT "99/99/9999"
          VIEW-AS FILL-IN
          SIZE 11 BY 1
          BGCOLOR 8 FGCOLOR 4
     f-shift-name AT ROW 9 COL 65.5 COLON-ALIGNED
     f-shift-num AT ROW 9 COL 83 COLON-ALIGNED
     ub.chk-doc.chk-num AT ROW 10.2 COL 8.3 COLON-ALIGNED FORMAT "->>>>>>9"
          VIEW-AS FILL-IN
          SIZE 7.3 BY 1
          BGCOLOR 8 FGCOLOR 4
     time_ AT ROW 10.2 COL 40.5 COLON-ALIGNED
     ub.chk-doc.pay-desk AT ROW 11.43 COL 8.3 COLON-ALIGNED FORMAT ">>>9"
          VIEW-AS FILL-IN
          SIZE 6 BY 1
          BGCOLOR 8 FGCOLOR 4
     ub.chk-doc.cashier AT ROW 11.43 COL 22.3 COLON-ALIGNED FORMAT ">>>>9"
          VIEW-AS FILL-IN
          SIZE 6.3 BY 1
          BGCOLOR 8 FGCOLOR 4
     ub.chk-doc.doc-code AT ROW 11.43 COL 54.4 COLON-ALIGNED
          LABEL "Номер" FORMAT "X(20)"
          VIEW-AS FILL-IN
          SIZE 19.3 BY 1
          BGCOLOR 8 FGCOLOR 4
     RECT-1 AT ROW 4.47 COL 1
     SPACE(0.24) SKIP(6.57)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Заполнение и/или обсчет документа инвентаризации по чекам инвентаризации":L.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: X_chk-doc B "NEW SHARED" ? ub chk-doc
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX d-chk
                                                                        */
ASSIGN
       FRAME d-chk:SCROLLABLE       = FALSE.

/* SETTINGS FOR FILL-IN ub.chk-doc.cashier IN FRAME d-chk
   EXP-FORMAT                                                           */
/* SETTINGS FOR FILL-IN ub.chk-doc.chk-num IN FRAME d-chk
   EXP-FORMAT                                                           */
/* SETTINGS FOR FILL-IN ub.chk-doc.doc-code IN FRAME d-chk
   EXP-LABEL EXP-FORMAT                                                 */
ASSIGN
       E-message:READ-ONLY IN FRAME d-chk        = TRUE.

/* SETTINGS FOR FILL-IN ub.chk-doc.pay-desk IN FRAME d-chk
   EXP-FORMAT                                                           */
/* SETTINGS FOR FILL-IN ub.chk-doc.shift-date IN FRAME d-chk
   EXP-FORMAT                                                           */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX d-chk
/* Query rebuild information for DIALOG-BOX d-chk
     _Options          = "SHARE-LOCK"
     _Query            is NOT OPENED
*/  /* DIALOG-BOX d-chk */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK QUERY QUERY-chk-doc
/* Query rebuild information for QUERY QUERY-chk-doc
     _TblList          = "X_chk-doc"
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Where[1]         = "X_chk-doc.obj-type = p-obj-type
 AND X_chk-doc.obj-code = p-obj-code
 AND X_chk-doc.out-code = ?"
     _Design-Parent    is DIALOG-BOX d-chk @ ( 2.43 , 3.3 )
*/  /* QUERY QUERY-chk-doc */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME d-chk
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL d-chk d-chk
ON END-ERROR OF FRAME d-chk /* Заполнение документа инвентаризации по чекам инвентаризации */
DO:
    apply "choose" to b-quit .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit d-chk
ON CHOOSE OF b-exit IN FRAME d-chk /* Ввод  */
DO:
  run proc-b-run IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-quit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-quit d-chk
ON CHOOSE OF b-quit IN FRAME d-chk /* Отмена */
DO:
  if p-mode = {&add-def}
  then return "cancell":U .
  else return '':U.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-shift-name
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-shift-name d-chk
ON LEAVE OF f-shift-name IN FRAME d-chk /* № смены */
DO:
  /*проверка на интерегер - случая когда l-shift-on = no cash-shft = yes*/
  run proc-shift-name in this-procedure no-error .
  if error-status:error then do:
    return no-apply.
  end.
  display
  integer(f-shift-name) @ f-shift-num
  with frame {&frame-name} .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME RS-get-method
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL RS-get-method d-chk
ON VALUE-CHANGED OF RS-get-method IN FRAME d-chk
DO:
   run IncProcStart in this-procedure ( input no).
   ASSIGN
   rs-get-method.
   CASE rs-get-method:
     WHEN "chk-docs" THEN DO:
        ASSIGN
        v-rid-list = "":U.
        run str/chk-docs.w (
                         input parparentproc
                        ,INPUT ('b-sel,b-mark':U )
                        ,INPUT "to-inv"
                        ,INPUT ?
                        ,INPUT t-doc.obj-type
                        ,INPUT t-doc.obj-code
                        ,INPUT t-doc.doc-code
                        ,INPUT '':U
                        ,input 0 /*p-pay-desk*/
                        ,INPUT ?
                        ,INPUT ?
                        ,input 0
                        ,output v-rid-list) no-error.
         IF v-rid-list = "":U  THEN DO:
             ASSIGN
             rs-get-method = "inc-invr".
             DISPLAY rs-get-method
             with frame {&frame-name}
             .
             RETURN NO-APPLY.
         END.
       END.
       WHEN "inc-invr":U THEN DO:
           v-rid-list = "":U.
      END.
   END CASE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME ub.chk-doc.shift-date
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ub.chk-doc.shift-date d-chk
ON RETURN OF ub.chk-doc.shift-date IN FRAME d-chk /* Дата смены */
DO:
  apply "CHOOSE" to b-exit in frame {&frame-name}.
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK d-chk


/* ***************************  Main Block  *************************** */

IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

{ gbl/app_help.i }
ON WINDOW-CLOSE OF FRAME {&FRAME-NAME} APPLY "END-ERROR":U TO SELF.

MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
      ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  if p-mode = {&update}
  or p-mode = {&add-def}
  then do:
  /*найдем параметр - использовать смены на кассе или нет*/
    { gbl/cas-shft.i p-obj-type p-obj-code cas-shft }
    .
    { gbl/objat.i
      p-obj-type
      p-obj-code
      "'shift-on=request'"
      l-shift-on
    }

    if l-shift-on and not cas-shft then do:
      message
      "Внимание! На текущем объекте требуется использование смен" skip
      "а настройка СМЕНЫ НА КАССЕ ( cas-shft ) выключена - это недопустимо." skip (2)
      view-as alert-box ERROR.
      return ERROR.
    end.
  end. /*if p-mode = {&update}*/
  else do:
    { gbl/objat.i
      p-obj-type
      p-obj-code
      "'shift-on=request'"
      l-shift-on
    }
  end.
/* t-doc already available */
  if p-mode = {&update}
  or p-mode = {&add-def}
  then do:
    FIND FIRST ub.shop WHERE ub.shop.obj-code = p-obj-code NO-LOCK .
    FIND FIRST ub.trn-doc WHERE ub.trn-doc.doc-code = t-doc.doc-code exclusive.
    for each buf_Chk-doc no-lock where
            buf_Chk-doc.out-code = t-doc.doc-code:
      assign
      chk-amount = chk-amount + 1
      .
    end.
  end. /*if p-mode = {&update}*/
  if p-mode = {&lookup} then do:
    FIND FIRST shop WHERE shop.obj-code = p-obj-code NO-LOCK .
    FIND FIRST trn-doc no-lock WHERE trn-doc.doc-code = t-doc.doc-code.
  end.
  if l-shift-on then do:
    run gbl/factdate.p (
                       INPUT        t-doc.obj-type
                      ,INPUT        t-doc.obj-code
                      ,INPUT-OUTPUT v-chk-date
                      ,INPUT-OUTPUT v-chk-time
                      ,INPUT-OUTPUT v-shift-date
                      ,INPUT-OUTPUT v-shift-num
                      ,input-output v-shift-name
                      ,INPUT        YES
                        ) NO-ERROR.
    IF ERROR-STATUS:ERROR THEN DO:
       message
       error-status:get-message(1) SKIP
       return-value
       view-as alert-box error .
       UNDO MAIN-BLOCK, return error .
    END.
  end.
  else do:
    assign
    v-shift-date = t-doc.doc-date
    v-shift-num = 0
    .
  end.
  if can-find( FIRST ub.chk-doc WHERE ub.chk-doc.out-code = t-doc.doc-code ) then do:
    FIND FIRST ub.chk-doc WHERE ub.chk-doc.out-code = t-doc.doc-code use-index sale
    NO-LOCK .
    assign
    time_ = string( ub.chk-doc.chk-time, "HH:MM" )
    .
  end.
  run Myenable in this-procedure .
  if return-value = "cancell" then return "cancell".
  if p-mode = {&update} then do:
    run proc-b-run in this-procedure no-error.
    if error-status:error then do:
      message
      substitute("Ошибка при подсчете количеств по строкам чеков инвентаризации&1&2&1&3"
                , {&new-line}
                , error-status:error
                , return-value )
      view-as alert-box error .
    end.
  end.
  else do:
    WAIT-FOR GO OF FRAME {&FRAME-NAME} focus chk-doc.shift-date .
  end.
END.
run disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI d-chk  _DEFAULT-DISABLE
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
  HIDE FRAME d-chk.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE display-chk d-chk
PROCEDURE display-chk :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DEFINE INPUT PARAMETER p-chk-amount AS INTEGER NO-UNDO.
DISPLAY
p-chk-amount @ chk-amount
with frame {&frame-name}.
if available X_chk-doc then
DISPLAY
X_chk-doc.cashier @ ub.chk-doc.cashier
X_chk-doc.shift-date @ ub.chk-doc.shift-date
X_chk-doc.chk-num    @ ub.chk-doc.chk-num
string( X_chk-doc.chk-time, "HH:MM" ) @ time_
X_chk-doc.office  @ ub.chk-doc.office
X_chk-doc.doc-code  @ ub.chk-doc.doc-code
X_chk-doc.pay-desk  @ ub.chk-doc.pay-desk
with frame {&frame-name}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE display-message d-chk
PROCEDURE display-message :
DEFINE INPUT PARAMETER p-message AS CHARACTER NO-UNDO.
e-message:SCREEN-VALUE IN FRAME {&FRAME-NAME} = p-message.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE display-processed d-chk
PROCEDURE display-processed :
DEFINE INPUT PARAMETER p-processed AS INTEGER NO-UNDO.
DISPLAY
p-processed @ f-processed
WITH FRAME {&FRAME-NAME}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE display-processed-ok d-chk
PROCEDURE display-processed-ok :
DEFINE INPUT PARAMETER p-processed-ok AS INTEGER NO-UNDO.
DISPLAY
p-processed-ok @ f-processed-ok
WITH FRAME {&FRAME-NAME}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Enable_UI d-chk  _DEFAULT-ENABLE
PROCEDURE Enable_UI :
/*------------------------------------------------------------------------------
  Purpose:     ENABLE the User Interface
  Parameters:  <none>
  Notes:       Here we display/view/enable the widgets in the
               user-interface.  In addition, OPEN all queries
               associated with each FRAME and BROWSE.
               These statements here are based on the "Other
               Settings" section of the widget Property Sheets.
------------------------------------------------------------------------------*/
  DISPLAY RS-get-method chk-amount f-processed f-processed-ok E-message
          f-shift-name f-shift-num time_
      WITH FRAME d-chk.
  IF AVAILABLE ub.chk-doc THEN
    DISPLAY ub.chk-doc.shift-date ub.chk-doc.chk-num ub.chk-doc.pay-desk
          ub.chk-doc.cashier ub.chk-doc.doc-code
      WITH FRAME d-chk.
  ENABLE b-exit RECT-1 b-quit b-help RS-get-method chk-amount f-processed
         f-processed-ok E-message ub.chk-doc.shift-date f-shift-name
         f-shift-num ub.chk-doc.chk-num time_ ub.chk-doc.pay-desk
         ub.chk-doc.cashier ub.chk-doc.doc-code
      WITH FRAME d-chk.
  {&OPEN-BROWSERS-IN-QUERY-d-chk}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE IncProc d-chk
PROCEDURE IncProc :
define input parameter p-is-all as logical no-undo .
define variable v-ii     as integer no-undo .
define variable v-ii-ok  as integer no-undo .
define variable v-rc-ii as integer no-undo .
define variable v-rc-max as integer no-undo .
DEFINE VARIABLE v-query-prepare AS CHARACTER NO-UNDO.
define variable v-error-status as logical no-undo .
define variable v-error-status-message as character no-undo .
if rs-get-method = "inc-invr":U
then do:
  if p-mode = {&add-def} then do:
    ASSIGN
    v-query-prepare = substitute("for each X_chk-doc no-lock where ":U +
                              "X_chk-doc.obj-type = '&1'":U +
                              " AND X_chk-doc.obj-code = &2":U +
                              " AND X_chk-doc.out-code = ? and X_chk-doc.chk-type = &3", p-obj-type, p-obj-code, integer({&rcpt-inventory})).
    if l-shift-on then do:
      ASSIGN
      v-query-prepare = v-query-prepare +
                      substitute(" AND X_chk-doc.shift-date = &1 AND X_chk-doc.shift-num = &2"
                                , string(v-shift-date, "99/99/9999")
                                , v-shift-num).
      /* пропускаем, если не та дата */
    end. /*cas-shft*/
    else do:
      if ub.shop.day-only then do:
          ASSIGN
          v-query-prepare = v-query-prepare +
                          substitute(" AND X_chk-doc.shift-date = &1", string(v-shift-date, "99/99/9999")).
                          .
        /* пропускаем, если не та дата */
      end.
      else do:
          ASSIGN
          v-query-prepare = v-query-prepare +
                          substitute(" AND X_chk-doc.shift-date <= &1", string(v-shift-date, "99/99/9999")).
        /* пропускаем, если не та дата */
      end.
    end. /*not cas-shft*/
  end.
  if p-mode = {&update} then do:
    ASSIGN
    v-query-prepare = substitute("for each X_chk-doc no-lock where ":U +
                              "X_chk-doc.out-code = '&1'":U, t-doc.doc-code  ).
  end.
  if rs-get-method = "chk-docs":U then do:
    assign
    v-query-prepare = v-query-prepare + substitute(" AND lookup(string(recid(X_chk-doc)), '&1') > 0 ", v-rid-list)
    .
  end.
  assign
  glog =
  QUERY query-chk-doc:QUERY-PREPARE(v-query-prepare) No-error.
  IF not glog
  THEN DO:
    MESSAGE
    error-status:get-message(1) skip
    VIEW-AS ALERT-BOX ERROR.
    UNDO, RETURN ERROR.

  END.

  assign
  glog = QUERY query-chk-doc:query-OPEN() NO-ERROR.
  IF not glog
  THEN DO:
      MESSAGE
      "Неверно выбран или построен ФИЛЬТР"
      VIEW-AS ALERT-BOX ERROR.
      UNDO, RETURN ERROR.
  END.
  ASSIGN
  glog = QUERY query-chk-doc:GET-FIRST(no-LOCK) NO-ERROR.
  IF not glog THEN DO:
    if p-mode = {&add-def} then do:
      message
      "Нет чеков, удовлетворяющих условиям закачки в документ" skip
      view-as alert-box WARNING .
    end.
    if p-mode = {&update} then do:
      message
      "Нет чеков, в документе" skip
      view-as alert-box WARNING .
    end.
    RETURN.
  END.
  ASSIGN
  glog = QUERY query-chk-doc:GET-FIRST(exclusive-LOCK, no-wait) NO-ERROR.
  do while locked (X_chk-doc ) and available X_chk-doc:
    glog = QUERY query-chk-doc:GET-NEXT(exclusive-LOCK, no-wait) NO-ERROR.
  end.
end.
else do:
  assign
  v-rc-max = num-entries(v-rid-list).
  _v-rc:
  do while v-rc-ii < v-rc-max:
    assign
    v-rc-ii = v-rc-ii + 1
    .
    find first X_chk-doc exclusive-lock where
              recid(X_chk-doc) = integer(entry(v-rc-ii, v-rid-list))  no-wait no-error.
    if locked X_chk-doc or not available X_chk-doc then do:
      next _v-rc.
    end.
    else leave _v-rc.
  end.
  if not available X_chk-doc
  or locked(X_chk-doc) then do:
    if p-mode = {&add-def} then do:
      message
      "Ни один из выбранных Вами чеков не может быть сейчас закачан в документ" skip
      "Возможно они заняты другим пользователем"
      view-as alert-box Warning.
    end.
    else do:
      message
      "Ни один из выбранных Вами чеков не может быть сейчас обсчитан" skip
      "Возможно они заняты другим пользователем"
      view-as alert-box Warning.
    end.
    return.
  end.
end.
run str/inc-invr.p (
                    input parparentproc
                  ,input this-procedure:handle
                  ,input p-is-all
                  ,input-output v-ii
                  ,input-output v-ii-ok
                  ,INPUT (IF rs-get-method = "chk-docs":U THEN v-rid-list ELSE "":U)
                  ,input p-chk-gds-rid-list /*строчки*/
                  ,INPUT (IF p-mode = {&add-def} THEN 0 ELSE 1) /*p-direction*/
                  ,input cas-shft
                  ,input chk-amount
                  ,input ub.shop.day-only
                  ,buffer t-doc
                  ) no-error.
assign
v-error-status = error-status:error
v-error-status-message = error-status:get-message(1)
.
if v-ii-ok <> 0 then do:
end.
if v-ii = 0 AND p-mode = {&add-def} then do:
  if v-error-status then
  message
  "Произошла ошибка при закачке чеков в инвентаризацию" skip
  v-error-status-message skip
  return-value
  view-as alert-box .
  else
  message
  "Нет чеков, удовлетворяющих условиям закачки в инвентаризацию" skip
  view-as alert-box WARNING .
end.
else do:
  if p-mode = {&add-def} then do:
    message
    substitute("Просмотрено &1 чеков, успешно закачано в инвентаризацию &2", v-ii, v-ii-ok)
    view-as alert-box WARNING .
  end.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE IncProcStart d-chk
PROCEDURE IncProcStart :
define input parameter p-run as logical no-undo .
if p-mode <> {&update}
and p-mode <> {&add-def}
then return.
define variable v-deleted as logical no-undo .
define variable v-dopi as integer no-undo .
define buffer buf_trn-doc for ub.trn-doc.
IF p-mode = {&add-def} THEN DO:
  if ub.shop.day-only then do:
    if can-find( first ub.chk-doc where
                     ub.chk-doc.obj-type = p-obj-type
                 and ub.chk-doc.obj-code = p-obj-code
                 and ub.chk-doc.out-code = ?
                 and ub.chk-doc.shift-date < t-doc.doc-date
                 and ub.chk-doc.chk-type = integer({&rcpt-inventory})
                 ) then  do:
      glog = yes.
      message substitute("Имеются чеки инвентаризации за более раннюю дату,&1" +
                         "не включенные ни в один документ.&1" +
                         "Не забудьте создать документ инвентаризации&1" +
                         "и включить в него эти чеки.&1&1" +
                         "Продолжать ?"
                         ,{&new-line})
      view-as alert-box question buttons YES-NO update glog.
      if NOT glog then return error .
    end.
  end. /*if shop.day-only then do:*/
  else do:
    if can-find( first ub.trn-doc where ub.trn-doc.obj-type = p-obj-type and
                                 ub.trn-doc.obj-code = p-obj-code and
                                 ub.trn-doc.status_ = {&fact} and
                                 ub.trn-doc.doc-date > t-doc.doc-date ) then do:
      glog = yes.
      message substitute("Уже имеется инвентаризация, содержащая чеки,&1"  +
                         "дата которых БОЛЬШЕ указанной Вами.&1"  +
                         "Вы уверены, что в базе появились новые чеки инвентаризации?&1"
                        , {&new-line})
        view-as alert-box question buttons YES-NO update glog.
      if NOT glog then  return error .
    end.
  end.
/*в отчете нет чеков*/
END.
if p-run then
run IncProc in this-procedure ( input is-all).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable d-chk
PROCEDURE MyEnable :
ASSIGN
rs-get-method = "inc-invr".
view frame {&frame-name} .
DISPLAY
f-shift-num
f-shift-name
chk-amount
time_
rs-get-method
WITH FRAME {&frame-name} .

IF AVAILABLE ub.chk-doc and p-mode <> {&lookup} THEN
DISPLAY
ub.chk-doc.shift-date
ub.chk-doc.pay-desk
ub.chk-doc.cashier
ub.chk-doc.chk-num
ub.chk-doc.doc-code
WITH FRAME {&FRAME-NAME}.
if p-mode <> {&update}
and p-mode <> {&add-def}
then do:
  assign
  b-quit:label = "&Выход"
  b-quit:column = 1
  .
end.
ENABLE
RECT-1
b-help
b-exit when (p-mode= {&update} or p-mode = {&add-def})
b-quit
rs-get-method when p-mode = {&add-def}
WITH FRAME {&frame-name} .
if p-mode <> {&update}
and p-mode <> {&add-def}
then do:
  hide
  b-exit in frame {&frame-name} .
end.
{&OPEN-BROWSERS-IN-QUERY-d-chk}
assign

f-shift-num = if cas-shft or p-mode = {&lookup} then v-shift-num else 0
f-shift-name = if cas-shft or p-mode = {&lookup} then v-shift-name else '':U
.
if p-mode = {&update} then do:
end. /*update*/

DISPLAY
f-shift-num when (cas-shft or (p-mode = {&lookup} and v-shift-num <> 0))
f-shift-name when (cas-shft or (p-mode = {&lookup} and v-shift-name <> '':U))
v-shift-date @ chk-doc.shift-date
with frame {&frame-name}.
DISABLE
chk-amount
WITH frame {&frame-name}.
if p-mode = {&update}
or p-mode = {&add-def}
then do:
  DISABLE
  chk-doc.cashier
  chk-doc.chk-num
  chk-doc.doc-code
  time_
  chk-doc.pay-desk
  WITH frame {&frame-name}.
  if not cas-shft then
  HIDE
  f-shift-num
  f-shift-name
  in frame {&frame-name}.
end.
else do:
  HIDE
  rs-get-method
  chk-doc.cashier
  chk-doc.chk-num
  chk-doc.doc-code
  time_
  chk-doc.pay-desk
  in frame {&frame-name}.
end.
if p-mode = {&update} then do:
  if p-rid-list <> '':U then do:
    v-rid-list = p-rid-list.
    assign
    rs-get-method = "chk-docs":U.
  end.
  else do:
    assign
    rs-get-method = "inc-invr":U.
  end.
  DISABLE
  rs-get-method
  b-exit b-quit
  WITH FRAME {&FRAME-NAME}.
  HIDE
  b-exit b-quit
  rs-get-method
  IN FRAME {&FRAME-NAME}.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-run d-chk
PROCEDURE proc-b-run :
define variable v-num as integer no-undo .
 if t-doc.status_ = {&permitted} then do:
  DO /*TRANSACTION*/ on ERROR
  undo, return no-apply
  on STOP undo, return no-apply  :
      run gbl/d-askw.w (
         input "Вопрос"
        ,input "Выберите режим работы для обработки чеков." + {&new-line}
        ,input "|^"
        ,input "Переписать|Прибавить|Спрашивать|Отмена"
        ,input "Переписать количество из чеков для всех товаров|"
            + "Прибавить количество из чеков для всех товаров|"
            + "Cпрашивать для каждого товара|"
            + "Отменить"
        ,input 1
        ,input 4
      ,output v-num
      ).
      case v-num :
        when 1 then do:
          assign is-all = yes.
        end.
        when 2 then do:
          assign is-all = no.
        end.
        when 3 then do:
          assign is-all = ?.
        end.
        otherwise do:
          if p-mode = {&update} then return "cancell".
          return.
        end.
      end case.
    END.
  end.
  run IncProcStart IN THIS-PROCEDURE ( input yes) .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-shift-name d-chk
PROCEDURE proc-shift-name :
define variable v-dopi as integer no-undo .
assign
v-dopi = integer(f-shift-name:screen-value in frame {&frame-name} )
no-error .
if error-status:error
or v-dopi <= 0
or v-dopi > 99 then do:
  message "Неверный номер смены!" view-as alert-box ERROR.
  return no-apply.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME