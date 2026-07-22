&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME d-shifts


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER X_shift-obj FOR shift-obj.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS d-shifts 
/*------------------------------------------------------------------------

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Смены по текущему объекту или все

Автор: Уханов Дмитрий Юрьевич
Дата создания: 08/21/07
Author: Dmitry Ukhanov
Creation date: 08/21/07

Автор1: Суслов Алексей Юрьевич
Дата создания1: 09/19/05

  sht-mode: obj  - по объекту
            host - по фирме
            all - все
------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc    as widget-handle no-undo .
define input parameter p-curr-obj-type  like ub.clients.obj-type no-undo .
define input parameter p-curr-obj-code  like ub.clients.obj-code no-undo .
define input parameter bttns            as character no-undo.
define input parameter sht-mode         as character no-undo.                   /* obj, all */
define input parameter p-obj-type  like ub.clients.obj-type no-undo .
define input parameter p-obj-code  like ub.clients.obj-code no-undo .
define input parameter parcall-point    as character no-undo .
define input-output parameter p-rid-list        as character no-undo.
/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Список смен".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/showinf.i }
{ gbl/waitfram.i }
{ gbl/getcntxt.i def }
{ gbl/usrfulnf.i }
define variable is-super    as logical      no-undo.    /* является ли пользователь менеджером */
define variable s-date      as date         no-undo.    /* дата начала смены для документа */
define variable e-date      as date         no-undo.    /* дата закрытия смены */
define variable s-time      as integer      no-undo.    /* время начала смены для документа */
define variable e-time      as integer      no-undo.    /* время конца смены */
define variable s-num       as integer      no-undo.    /* порядок смены для документа */
define variable s-name      as character    no-undo.    /* номер смены для документа */
define variable rep-name    as character    no-undo.    /* название вызываемого отчета */
define variable obj-db-num  as integer      no-undo.    /*номер БД для объекта*/
define variable v-cancel    as logical      no-undo.
define variable v-host-code like ub.sysconf.host-code no-undo .
define variable glog        as logical no-undo .
define variable l-shift-on  as logical no-undo .
define variable v-doc-rec as recid no-undo .
define variable v-curr-db-num like ub.db.db-num no-undo .
define variable v-sys-key as character no-undo.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION mark-string d-all-r-docs 
FUNCTION mark-string RETURNS CHARACTER
    ( p-rec as recid ) :
  def buffer loc-shift-obj for ub.shift-obj  .
  find first loc-shift-obj no-lock where  recid ( loc-shift-obj ) = p-rec no-error  .
  if error-status :error then return '' .

  if can-do (p-rid-list, string (recid (loc-shift-obj))) then RETURN "*".
  else RETURN "".
END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME d-shifts
&Scoped-define BROWSE-NAME br-shift

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_shift-obj

/* Definitions for BROWSE br-shift                                      */
&Scoped-define FIELDS-IN-QUERY-br-shift X_shift-obj.obj-type + " " + string (X_shift-obj.obj-code, ">>>>9") X_shift-obj.shift-date X_shift-obj.shift-name X_shift-obj.shift-num X_shift-obj.status_ X_shift-obj.open-date STRING (X_shift-obj.open-time, "HH:MM") usrfulnf(X_shift-obj.open-id) X_shift-obj.close-date string (X_shift-obj.close-time, "HH:MM") usrfulnf(X_shift-obj.close-id)
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-shift
&Scoped-define SELF-NAME br-shift
&Scoped-define QUERY-STRING-br-shift FOR EACH X_shift-obj       WHERE X_shift-obj.obj-type = p-obj-type and X_shift-obj.obj-code = p-obj-code NO-LOCK
&Scoped-define OPEN-QUERY-br-shift OPEN QUERY {&SELF-NAME} FOR EACH X_shift-obj       WHERE X_shift-obj.obj-type = p-obj-type and X_shift-obj.obj-code = p-obj-code NO-LOCK.
&Scoped-define TABLES-IN-QUERY-br-shift X_shift-obj
&Scoped-define FIRST-TABLE-IN-QUERY-br-shift X_shift-obj


/* Definitions for DIALOG-BOX d-shifts                                  */
&Scoped-define OPEN-BROWSERS-IN-QUERY-d-shifts ~
    ~{&OPEN-QUERY-br-shift}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit B-sel b-add b-chg b-del B-staff B-rep ~
B-param B-hist b-help br-shift 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Menu Definitions                                                     */
DEFINE MENU MENU-B-rep 
       MENU-ITEM mi-petrol      LABEL "Сменный отчет" 
       MENU-ITEM mi-ptrlch      LABEL "Технологический отчет по ТРК"
       MENU-ITEM mi-closeShift  LABEL "Чек-лист по закрытию смены".


/* Definitions of the field level widgets                               */
DEFINE BUTTON b-add 
     LABEL "&Добавить" 
     SIZE 10 BY 1 TOOLTIP "Добавить ожидаемую смену"
     BGCOLOR 8 .

DEFINE BUTTON b-chg 
     LABEL "&Изменить" 
     SIZE 10 BY 1 TOOLTIP "Изменить ожидаемую смену"
     BGCOLOR 8 .

DEFINE BUTTON b-del 
     LABEL "&Удалить" 
     SIZE 10 BY 1 TOOLTIP "Удалить ожидаемую смену"
     BGCOLOR 8 .

DEFINE BUTTON b-help 
     LABEL "Помо&щь" 
     SIZE 3 BY 1 TOOLTIP "Помощь"
     BGCOLOR 8 .

DEFINE BUTTON B-hist 
     LABEL "Ис&тория" 
     SIZE 3 BY 1.

DEFINE BUTTON b-mark 
     LABEL "*":L 
     SIZE 3 BY 1.

DEFINE BUTTON B-param 
     LABEL "&Параметры" 
     SIZE 10 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY 
     LABEL "&Выход" 
     SIZE 10 BY 1 TOOLTIP "Выход из списка смен"
     BGCOLOR 8 .

DEFINE BUTTON B-rep 
     LABEL "&Отчеты" 
     SIZE 10 BY 1.

DEFINE BUTTON B-sel AUTO-GO 
     LABEL "Вы&бор" 
     SIZE 10 BY 1.

DEFINE BUTTON B-staff 
     LABEL "&Персонал" 
     SIZE 10 BY 1.
     
/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-shift FOR 
      X_shift-obj SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-shift
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-shift d-shifts _FREEFORM
  QUERY br-shift DISPLAY
      mark-string(recid(X_shift-obj)) column-label "*" format "X(1)":U
      X_shift-obj.obj-type + " " + string (X_shift-obj.obj-code, ">>>>9") COLUMN-LABEL "Объект" FORMAT "x(9)":U
      X_shift-obj.shift-date COLUMN-LABEL "Дата смены" FORMAT "99/99/9999":U
      X_shift-obj.shift-name COLUMN-LABEL "№" FORMAT "X(2)":U WIDTH 3
      X_shift-obj.shift-num COLUMN-LABEL "Пр" FORMAT ">9":U
      X_shift-obj.status_ COLUMN-LABEL "Статус" FORMAT "X(3)":U
      X_shift-obj.open-date COLUMN-LABEL "Открыта" FORMAT "99/99/9999":U
      STRING (X_shift-obj.open-time, "HH:MM") COLUMN-LABEL "Время" FORMAT "x(5)":U
      usrfulnf(X_shift-obj.open-id) COLUMN-LABEL "Открыл" FORMAT "X(14)":U
      X_shift-obj.close-date COLUMN-LABEL "Закрыта" FORMAT "99/99/9999":U
      string (X_shift-obj.close-time, "HH:MM") COLUMN-LABEL "Время" FORMAT "x(5)":U
      usrfulnf(X_shift-obj.close-id) COLUMN-LABEL "Закрыл" FORMAT "X(14)":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 19.08.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME d-shifts
     b-quit AT ROW 1 COL 1
     B-sel AT ROW 1 COL 11
     b-add AT ROW 1 COL 21
     b-chg AT ROW 1 COL 31
     b-del AT ROW 1 COL 41
     B-staff AT ROW 1 COL 51
     B-rep AT ROW 1 COL 61
     B-param AT ROW 1 COL 71 WIDGET-ID 2
     B-hist AT ROW 1 COL 92
     b-help AT ROW 1 COL 95
     b-mark AT ROW 2 COL 1
     br-shift AT ROW 3 COL 1
     SPACE(0.00) SKIP(0.04)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Смены на объекте"
         DEFAULT-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: X_shift-obj B "?" ? ub shift-obj
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX d-shifts
   FRAME-NAME                                                           */
/* BROWSE-TAB br-shift b-help d-shifts */
ASSIGN
       FRAME d-shifts:SCROLLABLE       = FALSE
       FRAME d-shifts:HIDDEN           = TRUE.

ASSIGN
       B-rep:POPUP-MENU IN FRAME d-shifts       = MENU MENU-B-rep:HANDLE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-shift
/* Query rebuild information for BROWSE br-shift
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH X_shift-obj
      WHERE X_shift-obj.obj-type = p-obj-type and X_shift-obj.obj-code = p-obj-code NO-LOCK.
     _END_FREEFORM
     _Where[1]         = "shift-obj.obj-type = p-obj-type and shift-obj.obj-code = p-obj-code"
     _Query            is OPENED
*/  /* BROWSE br-shift */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX d-shifts
/* Query rebuild information for DIALOG-BOX d-shifts
     _Options          = "SHARE-LOCK"
     _Query            is NOT OPENED
*/  /* DIALOG-BOX d-shifts */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME d-shifts
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL d-shifts d-shifts
ON WINDOW-CLOSE OF FRAME d-shifts /* Смены на объекте */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-add d-shifts
ON CHOOSE OF b-add IN FRAME d-shifts /* Добавить */
DO:
RUN proc-b-add IN THIS-PROCEDURE NO-ERROR.
IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-chg d-shifts
ON CHOOSE OF b-chg IN FRAME d-shifts /* Изменить */
DO:
/* только ожидаемая */
    if not available X_shift-obj
    then do:
      message
        "Не выбрана смена."
        view-as alert-box error.
      return no-apply.
    end.
    
    
    if X_shift-obj.status_ <> {&sht-expected}        
      and X_shift-obj.status_ <> {&sht-closed}
      then do:
          message "Можно редактировать только ожидаемую или закрытую смену"
          view-as alert-box.
          return no-apply.
      end.
    
    assign
      v-doc-rec = recid(X_shift-obj)
    .
    if X_shift-obj.status_ = {&sht-expected} then do:
    run change-planned-shift in this-procedure
      ( input X_shift-obj.shift-date
       ,input X_shift-obj.shift-num
       ,input X_shift-obj.shift-name
       ,INPUT v-doc-rec
      ) no-error .
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description
        skip "Ошибка изменения запланированной смены."
        skip return-value
        skip trim(error-status :get-message(1))
            trim(error-status :get-message(2))
            trim(error-status :get-message(3))
            trim(error-status :get-message(4))
            trim(error-status :get-message(5))
        view-as alert-box error.
      undo, return no-apply .
    end.
    END.
    else do: /* X_shift-obj.status_ = {&sht-closed} */
        run change-close-shift-time(input v-doc-rec) no-error.
        if error-status:error then do:
          message
            vss-workfile vss-revision vss-description
            skip "Ошибка изменения запланированной смены."
            skip return-value
            skip trim(error-status :get-message(1))
                trim(error-status :get-message(2))
                trim(error-status :get-message(3))
                trim(error-status :get-message(4))
                trim(error-status :get-message(5))
            view-as alert-box error.
          undo, return no-apply .
        end.
    end.        
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-del d-shifts
ON CHOOSE OF b-del IN FRAME d-shifts /* Удалить */
DO:
/* только ожидаемая */
if not available X_shift-obj or
   X_shift-obj.status_ <> {&sht-expected} then do:
  message
    "Можно удалить только ожидаемую смену."
    view-as alert-box error.
  return no-apply.
end.
run gbl/shtwaidl.p ( INPUT NO /*p-sielnt*/
                    ,INPUT recid(X_shift-obj)
                   ) NO-ERROR.
IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
v-doc-rec = ?.
run UI-on IN THIS-PROCEDURE NO-ERROR.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-hist
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-hist d-shifts
ON CHOOSE OF B-hist IN FRAME d-shifts /* История */
DO:
  DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
  IF NOT AVAILABLE X_shift-obj THEN RETURN NO-APPLY.
    run ref/cshthist.w (
                  INPUT parParentProc
                 ,input p-curr-obj-type
                 ,input p-curr-obj-code
                 ,input '':U /* bttns  */
                 ,input 'one':U /*p-mode  */
                 ,INPUT X_shift-obj.obj-type
                 ,INPUT X_shift-obj.obj-code
                 ,INPUT X_shift-obj.shift-date
                 ,INPUT X_shift-obj.shift-num
                 ,INPUT '':U /*p-subject*/
                 ,INPUT-OUTPUT v-rid-list) NO-ERROR.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-mark d-shifts
ON CHOOSE OF b-mark IN FRAME d-shifts /* * */
DO:
    define variable varlog as logical no-undo .
    run local-mark in this-procedure .
    assign
        varlog = {&browse-name}:select-next-row ()
        .
    apply "entry" to {&browse-name} in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-param
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-param d-shifts
ON CHOOSE OF B-param IN FRAME d-shifts /* Параметры */
DO:
 run str/shift-params.w(
 input X_shift-obj.obj-type,
 input X_shift-obj.obj-code,
 input X_shift-obj.shift-date,
 input X_shift-obj.shift-num,
 input X_shift-obj.shift-name)  .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-rep
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-rep d-shifts
ON CHOOSE OF B-rep IN FRAME d-shifts /* Отчеты */
DO:
 if rep-name = "" then do:
    run gbl/pop-up.p (self:handle, no) no-error.
    if error-status:error then return no-apply.
  end.
 if rep-name = "" then return no-apply.
 run proc-b-rep(input-output rep-name) no-error.
 if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-sel d-shifts
ON CHOOSE OF B-sel IN FRAME d-shifts /* Выбор */
DO:
    if ( available X_shift-obj AND p-rid-list = "" ) then
        p-rid-list = string( recid( X_shift-obj) ) .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-staff
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-staff d-shifts
ON CHOOSE OF B-staff IN FRAME d-shifts /* Персонал */
DO:
  def buffer buf_shift-obj for ub.shift-obj.
  if avail X_shift-obj then do:
    find first buf_shift-obj where
               recid(buf_shift-obj) = recid(X_shift-obj) no-error.
    if buf_shift-obj.status_ = {&sht-expected} then do:
        run ref/shftpers.w (
                        input parparentproc
                       ,input buf_shift-obj.obj-type
                       ,input buf_shift-obj.obj-code
                       ,input buf_shift-obj.shift-date
                       ,input buf_shift-obj.shift-num
                       ,input (if v-curr-db-num = obj-db-num
                               and lookup("b-add", bttns) > 0
                               then "b-add,b-add-next":U else "")
                       ,input {&obj-shift-open}) no-error.
    end.
    else if buf_shift-obj.status_ <> {&sht-closed} then do:
      if sht-mode = "obj" and
      is-super then
        run ref/shftpers.w (
                        input parparentproc
                       ,input buf_shift-obj.obj-type
                       ,input buf_shift-obj.obj-code
                       ,input buf_shift-obj.shift-date
                       ,input buf_shift-obj.shift-num
                       ,input (if v-curr-db-num = obj-db-num
                               and lookup("b-add", bttns) > 0
                               then  "b-add,b-add-next":U else "")
                       ,input "") no-error.
      else
        run ref/shftpers.w (
                        input parparentproc
                       ,input buf_shift-obj.obj-type
                       ,input buf_shift-obj.obj-code
                       ,input buf_shift-obj.shift-date
                       ,input buf_shift-obj.shift-num
                       ,input ""
                       ,input "") no-error.
    end.
    else do:
        if sht-mode = "obj" and
        is-super then
        run ref/shftpers.w (
                        input parparentproc
                       ,input buf_shift-obj.obj-type
                       ,input buf_shift-obj.obj-code
                       ,input buf_shift-obj.shift-date
                       ,input buf_shift-obj.shift-num
                       ,input (if v-curr-db-num = obj-db-num
                              and lookup("b-add", bttns) > 0
                              then "b-add-next" else "")
                       ,input "") no-error.
        else
        run ref/shftpers.w (
                        input parparentproc
                       ,input buf_shift-obj.obj-type
                       ,input buf_shift-obj.obj-code
                       ,input buf_shift-obj.shift-date
                       ,input buf_shift-obj.shift-num
                       ,input ""
                       ,input "") no-error.
    end.

  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-shift
&Scoped-define SELF-NAME br-shift
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-shift d-shifts
ON MOUSE-SELECT-DBLCLICK OF br-shift IN FRAME d-shifts
DO:
  IF      b-sel :SENSITIVE IN FRAME {&FRAME-NAME} THEN DO:
    APPLY "CHOOSE":U to b-sel IN FRAME {&FRAME-NAME}.
  END.
  ELSE IF b-chg :SENSITIVE IN FRAME {&FRAME-NAME} THEN DO:
     APPLY "CHOOSE":U to b-chg IN FRAME {&FRAME-NAME}.
  END.
  ELSE IF b-rep :SENSITIVE IN FRAME {&FRAME-NAME} THEN DO:
    APPLY "CHOOSE":U to b-rep IN FRAME {&FRAME-NAME}.
  END.
  ELSE DO:
    RETURN NO-APPLY.
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME mi-petrol
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL mi-petrol d-shifts
ON CHOOSE OF MENU-ITEM mi-petrol /* Сменный отчет */
DO:
  rep-name = "g-shift":U.
  run proc-b-rep in this-procedure ( input-output rep-name) no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME mi-petrol
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL mi-petrol d-shifts
ON CHOOSE OF MENU-ITEM mi-closeShift /* Чек-лист по закрытию смены */
DO:
  rep-name = "g-shiftClose":U.
  run proc-b-rep in this-procedure ( input-output rep-name) no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME mi-ptrlch
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL mi-ptrlch d-shifts
ON CHOOSE OF MENU-ITEM mi-ptrlch /* Технологический отчет по ТРК */
DO:
  rep-name = "g-ptrlch":U.
  run proc-b-rep in this-procedure ( input-output rep-name) no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK d-shifts 


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

{ gbl/brwrefre.i " if available X_shift-obj then v-doc-rec = recid(X_shift-obj).  RUn OpenBr in this-procedure.  REPOSITION br-shift to recid v-doc-rec No-ERROR. " }
{ gbl/brwrepos.i
  &line-num=5
}


{ gbl/app_help.i }
/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

  { gbl/getcntxt.i get }

  { gbl/curdbnum.i v-curr-db-num }

if sht-mode = 'obj':U then do:
  /* проверяем, что на объекте включены смены */
  { gbl/objat.i
    p-obj-type
    p-obj-code
    "'shift-on=request'"
    l-shift-on
    no-error
  }
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при запуске процедуры objat" skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    return.
  end.

  if not l-shift-on then do:
    message
      vss-workfile vss-revision vss-description skip
      "На объекте выключены смены." skip
      "Работа со сменами невозможна." skip
      "Объект:" p-obj-type p-obj-code skip
      view-as alert-box error .
    return.
  end.
  { gbl/currsysk.i
    v-sys-key
    no-error
  }
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при чтении параметра конфигурации" '"sys-key"' skip
      error-status :get-message( 1 ) skip
      return-value skip
    view-as alert-box error .
    return.
  end.

  /* проверяем права на работу со сменами */
  /* менеджер */
  is-super = no.
  define variable v-chk-act-host-code as integer   no-undo .
  { gbl/hostcode.i
    p-obj-type
    p-obj-code
    v-chk-act-host-code
  }

  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_shift_super':U
    {&cntxt-object}
    v-chk-act-host-code
    p-obj-type
    p-obj-code
    0
    0
    0
    false
    glog
  }
  if glog then do:
    is-super = yes.
  end.
  else do:
    /* обычный пользователь */
    { gbl/chk-actg.i
      v-cntxt-db-num
      v-cntxt-userid
      {&action-head-code-main}
      'actn_shift_regular':U
      {&cntxt-object}
      v-chk-act-host-code
      p-obj-type
      p-obj-code
      0
      0
      0
      false
      glog
    }
  end.
  if not glog then do:
    message
      "Вы не имеете прав для работы со сменами." skip
      "Объект:" p-obj-type p-obj-code
      view-as alert-box.
    return.
  end.
end.

/* Оставляем только менеджера */
if not is-super
and lookup("b-sel", bttns) = 0
and lookup("b-add", bttns) > 0
then do:
  message
    "Отменить смену может только менеджер." skip
    "Объект:" p-obj-type p-obj-code
    view-as alert-box.
  return.
end.

if p-rid-list <> '':U
and p-rid-list <> ? then do:
  assign
  v-doc-rec = integer(entry(1, p-rid-list))
  p-rid-list = '':U
  no-error .
end.
RUN UI-on no-error.
if error-status:error then return error.

WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.

RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE change-planned-shift d-shifts
PROCEDURE change-planned-shift :
define input parameter p-shift-date like ub.shift-obj.shift-date no-undo .
define input parameter p-shift-num  like ub.shift-obj.shift-num  no-undo .
define input parameter p-shift-name like ub.shift-obj.shift-name no-undo .
define input parameter p-rec AS RECID NO-UNDO .
DEFINE VARIABLE v-loc-doc-rec AS RECID NO-UNDO.
  do
  on error undo, return error
  :
    define buffer buf_shift-obj     for ub.shift-obj.

    assign
      s-date = p-shift-date
      s-num  = p-shift-num
      s-name = p-shift-name
    .
    run gbl/shift.w
      ( input parparentproc
       ,input p-curr-obj-type
       ,input p-curr-obj-code
       ,input-output s-date /* дата начала смены для документа */
       ,input-output e-date
       ,input-output s-time /* время начала смены для документа */
       ,input-output e-time
       ,input-output s-num  /* порядок смены для документа */
       ,input-output s-name /* номер смены для документа */
       ,input "no-time"
       ,output v-cancel
      ) no-error.
    if error-status:error
      or v-cancel = yes
    then do:
      if v-cancel = yes then do:
        undo, return.
      end.
      else do:
        undo, return error "change-planned-shift: Ошибка получения данных для изменения смены." + {&new-line} + return-value.
      end.
    end.
    if s-name <> p-shift-name then do:
     run gbl/shtwaicr.p ( INPUT {&UPDATE}
                        ,INPUT NO /*p-silent*/
                        ,INPUT-OUTPUT p-rec
                        ,INPUT p-curr-obj-type
                        ,INPUT p-curr-obj-code
                        ,INPUT p-shift-date
                        ,INPUT p-shift-num
                        ,INPUT s-name) NO-ERROR.
        IF NOT ERROR-STATUS:ERROR
        AND p-rec  <> ? THEN DO:
           v-doc-rec = p-rec.
           run UI-on IN THIS-PROCEDURE NO-ERROR.
        END.
      end.
  end.
END PROCEDURE. /* change-planned-shift */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

 
&IF DEFINED(EXCLUDE-change-close-shift-time) = 0 &THEN
		
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE change-close-shift-time d-shifts
procedure change-close-shift-time:
define input parameter p-rec as recid no-undo.
define buffer bf_shift-obj for ub.shift-obj.

find first bf_shift-obj no-lock where recid(bf_shift-obj) = p-rec.

assign
    s-date = bf_shift-obj.shift-date
    e-date = bf_shift-obj.close-date
    s-time = bf_shift-obj.open-time
    e-time = bf_shift-obj.close-time
    s-num = bf_shift-obj.shift-num
    s-name = bf_shift-obj.shift-name
.

run gbl/shift.w
  ( input parparentproc
   ,input p-curr-obj-type
   ,input p-curr-obj-code
   ,input-output s-date /* дата начала смены для документа */
   ,input-output e-date
   ,input-output s-time /* время начала смены для документа */
   ,input-output e-time
   ,input-output s-num  /* порядок смены для документа */
   ,input-output s-name /* номер смены для документа */
   ,input "edit-time"
   ,output v-cancel
  ) no-error.
  if error-status:error
    or v-cancel = yes
  then do:
    if v-cancel = yes then do:
      undo, return.
    end.
    else do:
      undo, return error "change-closed-shift: Ошибка получения данных для изменения смены." + {&new-line} + return-value + {&new-line} + error-status:get-message (1).
    end.
  end.

run gbl/sht-set-time.p(
    bf_shift-obj.shift-date,
    bf_shift-obj.shift-num,
    bf_shift-obj.obj-type,
    bf_shift-obj.obj-code,
    e-time,
    s-time
) no-error.
if error-status:error then
    undo, return error "change-closed-shift: Ошибка при изменение времени смены" + {&new-line} + return-value + {&new-line} + error-status:get-message (1).
    
run UI-on IN THIS-PROCEDURE NO-ERROR.

end procedure.
	
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI d-shifts  _DEFAULT-DISABLE
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
  HIDE FRAME d-shifts.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI d-shifts  _DEFAULT-ENABLE
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
  ENABLE b-quit B-sel b-add b-chg b-del B-staff B-rep B-param B-hist b-help 
         b-mark br-shift 
      WITH FRAME d-shifts.
  VIEW FRAME d-shifts.
  {&OPEN-BROWSERS-IN-QUERY-d-shifts}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OpenBr d-shifts
PROCEDURE OpenBr :
run waitfram-show in this-procedure ("Заполняется список. ЖДИТЕ...").
case sht-mode :
  when "all" then do:
    ENABLE b-staff
    WITH FRAME {&frame-name}.
    frame {&frame-name} :title = "Все смены системы".
    OPEN QUERY br-shift
      FOR EACH X_shift-obj NO-LOCK
          by X_shift-obj.shift-date descending
          by X_shift-obj.shift-num descending.
  end.
  when "host" then do:
  end.
  when "obj" then do:
    { gbl/hostcode.i p-obj-type p-obj-code v-host-code }
    { gbl/objdbnum.i p-obj-type p-obj-code obj-db-num }
    if is-super then
      ENABLE
      b-add when ((v-curr-db-num = obj-db-num) AND lookup("b-add":U, bttns) > 0)
      b-chg when ((v-curr-db-num = obj-db-num) AND lookup("b-add":U, bttns) > 0)
      b-del when ((v-curr-db-num = obj-db-num) AND lookup("b-add":U, bttns) > 0)
      b-staff
      B-sel when lookup("b-sel":U, bttns) > 0
      WITH FRAME {&frame-name}.
    else
    ENABLE
    b-staff WITH FRAME {&frame-name}.
    frame {&frame-name} :title = substitute("Смены по объекту: &1&2"
                                            , p-obj-type
                                            ,p-obj-code).
    OPEN QUERY br-shift
      FOR EACH X_shift-obj WHERE
              X_shift-obj.obj-type = p-obj-type and
              X_shift-obj.obj-code = p-obj-code NO-LOCK
          by X_shift-obj.shift-date descending
          by X_shift-obj.shift-num descending.
  end.
end case.
if v-doc-rec <> ? then reposition br-shift to recid v-doc-rec No-ERROR.
run waitfram-hide in this-procedure .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-add d-shifts 
PROCEDURE proc-b-add :
DEFINE buffer buf_shift-obj for ub.shift-obj.
DEFINE VARIABLE v-loc-doc-rec AS RECID NO-UNDO.
assign
  s-date = ?
  s-time = ?
  s-num  = ?
  s-name = ?.
/* только ожидаемая */
run gbl/shift.w (  input parparentproc
             , input p-curr-obj-type
             , input p-curr-obj-code
             , input-output s-date  /* дата начала смены для документа */
             , input-output e-date
             , input-output s-time  /* время начала смены для документа */
             , input-output e-time
             , input-output s-num   /* порядок смены для документа */
             , input-output s-name  /* номер смены для документа*/
             , input "no-time"
             , output v-cancel
            ) no-error.
if error-status:error
then do:
    message
      vss-workfile vss-revision vss-description
      skip "Ошибка добавления смены."
      skip return-value
      skip trim(error-status :get-message(1))
           trim(error-status :get-message(2))
           trim(error-status :get-message(3))
           trim(error-status :get-message(4))
           trim(error-status :get-message(5))
    view-as alert-box error.
    undo, return no-apply .
end.
if v-cancel = yes
then do:
    undo, return.
end.
run gbl/shtwaicr.p ( INPUT {&add-def}
                    ,INPUT NO /*p-silent*/
                    ,INPUT-OUTPUT v-loc-doc-rec
                    ,INPUT p-curr-obj-type
                    ,INPUT p-curr-obj-code
                    ,INPUT s-date
                    ,INPUT s-num
                    ,INPUT s-name) NO-ERROR.
IF NOT ERROR-STATUS:ERROR
AND v-loc-doc-rec  <> ? THEN DO:
   v-doc-rec = v-loc-doc-rec.
   run UI-on IN THIS-PROCEDURE NO-ERROR.
END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-rep d-shifts 
PROCEDURE proc-b-rep :
DEFINE INPUT-OUTPUT PARAMETER prep-name as character no-undo.
DEFINE variable mypar as CHARACTER no-undo.
define variable check-html as character no-undo .
define buffer t-shift-obj for ub.shift-obj.
IF NOT AVAIL X_shift-obj then do:
    bell.
    prep-name = "".
    return.
end.
  case prep-name:
    WHEN "g-shift":U
    or
    when "g-ptrlch":U
    or
    when "g-shiftClose":U
    or
    when "g-zmzvit"
    then do:
        IF sht-mode <> "obj" then do:
            message
            "Отчет можно сделать только находясь в списке смен по текущему объекту"
            view-as alert-box ERROR.
            prep-name = "".
            return.
        end.
        FIND FIRST t-shift-obj No-LOCK WHERE
                   recid(t-shift-obj) = recid(X_shift-obj) No-ERROR.
        IF NOT AVAIL t-shift-obj then do:
            message
            substitute("Не найдена смена:&1" +
                       "объект &2&3 смена от &4 номер &5 порядок &6"
                       , {&NEW-LINE}
                       ,X_shift-obj.obj-type
                       ,X_shift-obj.obj-code
                       ,string(X_shift-obj.shift-date, "99/99/9999")
                       ,X_shift-obj.shift-name
                       ,X_shift-obj.shift-num)
            view-as alert-box ERROR.
            prep-name = "".
            return.
        end.
        if prep-name = "g-shiftClose"
        and t-shift-obj.status_ <>  {&sht-closed} then do:
            Message
            SUBSTITUTE("На объекте &1&2 смена № &3 порядок &4 от &5&6еще не закрыта&6Чек-лист не сформирован!"
                       ,t-shift-obj.obj-type
                       ,t-shift-obj.obj-code
                       ,t-shift-obj.shift-name
                       ,t-shift-obj.shift-num
                       ,string(t-shift-obj.shift-date,"99/99/9999")
                       ,{&new-line}
                       )
            prep-name = "".
            return.
        end.
        if   ( prep-name = "g-shift"
        or   prep-name = "g-zmzvit" )
        and t-shift-obj.status_ <>  {&sht-closed} then do:
            Message
            SUBSTITUTE("На объекте &1&2 смена № &3 порядок &4 от &5&6еще не закрыта&6Сменный отчет сделать нельзя!"
                       ,t-shift-obj.obj-type
                       ,t-shift-obj.obj-code
                       ,t-shift-obj.shift-name
                       ,t-shift-obj.shift-num
                       ,string(t-shift-obj.shift-date,"99/99/9999")
                       ,{&new-line}
                       )
            prep-name = "".
            return.
        end.        
        mypar =
            "X-DATE-START = " + string(X_shift-obj.shift-date, "99/99/9999") + {&comma-char} +
            "X-SHIFT-START = " + string(X_shift-obj.shift-num) + {&comma-char} +
            "X-OBJ-CODE = " + string(X_shift-obj.obj-code) + {&comma-char} +
            "X-OBJ-TYPE = " + string(X_shift-obj.obj-type) .
       if prep-name = "g-shift"
       then do:
          run rep/g-new-shift.p
            (input parparentproc
            ,input mypar
            ) .
       end.
      if prep-name = "g-shiftClose" then do:
    define variable vRas as logical no-undo .
    find first shift-param no-lock where shift-param.obj-code = t-shift-obj.obj-code and
        shift-param.obj-type = t-shift-obj.obj-type and
        shift-param.shift-date = t-shift-obj.shift-date and
        shift-param.shift-name = t-shift-obj.shift-name and
        shift-param.shift-num = t-shift-obj.shift-num and (shift-param.error-mass or
        shift-param.error-paid-trans) no-error .
        if available (shift-param) then vRas = true .
             
          run rep/r-shiftClose.p
            (input X_shift-obj.host-code
            ,input mypar
            ,input false
            ,input vRas
            ,input true
            ,output check-html
            ) .
      end.
       if prep-name = "g-ptrlch"
       then do:
        run rep/g-ptrlch.p
          (input parparentproc
          ,input mypar
          ) .
       end.
       if prep-name = "g-zmzvit"
       then do:
         run rep/g-zmzvit.p
           (input parparentproc
           ) no-error .
       end.
    END.
  end case.
  prep-name = "".
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE UI-on d-shifts 
PROCEDURE UI-on :
ASSIGN b-rep:POPUP-MENU IN FRAME {&frame-name} = MENU menu-b-rep:HANDLE.
ASSIGN b-rep:MENU-MOUSE = 1.


if parcall-point = "rep/e-shift.w":U
or parcall-point = "rep/r-ptrlch.p":U
or parcall-point = "e-zmzvit.w":U
then
assign
menu-item mi-petrol:sensitive  in menu menu-b-rep = no
menu-item mi-ptrlch:sensitive  in menu menu-b-rep = no
menu-item mi-closeShift:sensitive  in menu menu-b-rep = no
.
else do:
   if lookup( v-sys-key, "Astral_UKR,Lila_UKR," + {&SuperSysKey}  ) > 0 
   then do:
      define variable h_menu_item as handle no-undo.
      create menu-item h_menu_item
      assign
         parent      = menu menu-b-rep:handle
         label       = "Сменный отчет АЗС (Украина)"
         sensitive   = TRUE
         triggers :
            ON choose PERSISTENT RUN smenUcr IN THIS-PROCEDURE.
                    
         end triggers.
   end.
end.

ENABLE
b-quit
b-help
b-rep
br-shift
b-hist
b-param
B-sel when lookup("b-sel":U, bttns) > 0
WITH FRAME {&frame-name}.
VIEW FRAME {&frame-name}.
if lookup("b-mark":U, bttns) > 0
then do :
  display b-mark WITH FRAME {&frame-name}.
  enable b-mark WITH FRAME {&frame-name}.
end .
else do :
  disable b-mark WITH FRAME {&frame-name}.
  hide b-mark in FRAME {&frame-name}.
end .
RUN OpenBr IN THIS-PROCEDURE.
END PROCEDURE.

procedure smenUcr:
   rep-name = "g-zmzvit":U.
   run proc-b-rep in this-procedure ( input-output rep-name ) no-error .
   if error-status :error then do: return no-apply. end.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-mark d-shifts
PROCEDURE local-mark :
if not available X_shift-obj then 
do:
    message "Неправильный выбор строки.".
    return .
end.
{ gbl/markstrn.i X_shift-obj p-rid-list }
{&browse-name}:refresh() in frame {&frame-name} .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

