&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI ADM2
&ANALYZE-RESUME
/* Connected Databases 
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME gDialog
{adecomm/appserv.i}
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS gDialog 
/*

$Revision: $
$Author$
$Date$
$Workfile$
$Archive$

Настройки по автоматическому удалению маршрутизации ВС, работающих без подтверждения

Автор: Морозов Александр Сергеевич
Дата создания: 12/21/12
Author: Morozov Alexandr
Creation date: 12/21/12

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress AppBuilder.      */
/*----------------------------------------------------------------------*/

/* Create an unnamed pool to store all the widgets created 
     by this procedure. This is a good default which assures
     that this procedure's triggers and internal procedures 
     will execute in this procedure's storage, and that proper
     cleanup will occur on deletion of the procedure. */

CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-curr-host-code like ub.sysconf.host-code no-undo .
define input parameter p-curr-obj-type  like ub.clients.obj-type no-undo .
define input parameter p-curr-obj-code  like ub.clients.obj-code no-undo .
define input PARAMETER p-mode           AS CHARACTER NO-UNDO.
/*вызывается для задания параметров или перед непосредственнно выполнением*/
/*может быть 'shd' или 'run' */
define input parameter p-db-num-char    as character    no-undo.
define input parameter p-task-type      as character    no-undo.
define input parameter p-task-num       as integer      no-undo.

/*при p-mode = 'run'*/
define input parameter p-action         as character    no-undo.
/**/
define output parameter p-cancel        as logical      no-undo.
define output parameter p-params        as character    no-undo.

/* Local Variable Definitions ---                                       */

{src/adm2/widgetprto.i}

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Настройки по автоматическому удалению маршрутизации ВС, работающих без подтверждения".

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/showinf.i  }
{ gbl/getcntxt.i def }
{ ref/shd-attr.i }

define variable mark        as character no-undo.
define variable mark-string as character no-undo .
define variable mark-list   as character no-undo .
define variable g#log       as logical   no-undo .
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE SmartDialog
&Scoped-define DB-AWARE no

&Scoped-define ADM-CONTAINER DIALOG-BOX

&Scoped-define ADM-SUPPORTED-LINKS Data-Target,Data-Source,Page-Target,Update-Source,Update-Target

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME gDialog
&Scoped-define BROWSE-NAME BROWSE-2

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES ext-system

/* Definitions for BROWSE BROWSE-2                                      */
&Scoped-define FIELDS-IN-QUERY-BROWSE-2 ext-system.esys-name ~
ext-system.esys-id ext-system.esys-db-num-exp ext-system.esys-db-num-imp 
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-2 
&Scoped-define QUERY-STRING-BROWSE-2 FOR EACH ext-system ~
      WHERE ext-system.esys-type = 6 ~
 OR ext-system.esys-type = 7 NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-BROWSE-2 OPEN QUERY BROWSE-2 FOR EACH ext-system ~
      WHERE ext-system.esys-type = 6 ~
 OR ext-system.esys-type = 7 NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-BROWSE-2 ext-system
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-2 ext-system


/* Definitions for DIALOG-BOX gDialog                                   */
&Scoped-define OPEN-BROWSERS-IN-QUERY-gDialog ~
    ~{&OPEN-QUERY-BROWSE-2}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-mark b-delmark f-day-shift b-enter B-exit ~
BROWSE-2 
&Scoped-Define DISPLAYED-OBJECTS f-day-shift 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-delmark 
  LABEL "Снять *" 
  SIZE 13.8 BY 1.14.

DEFINE BUTTON b-enter AUTO-GO 
  LABEL "Ввод" 
  SIZE 22.8 BY 1.14.

DEFINE BUTTON B-exit AUTO-END-KEY 
  LABEL "Отмена" 
  SIZE 15 BY 1.14.

DEFINE BUTTON B-mark 
  LABEL "*" 
  SIZE 5 BY 1.14.

DEFINE VARIABLE f-day-shift AS INTEGER INITIAL 10 
  LABEL "Кол. дней хранения" 
  VIEW-AS FILL-IN 
  SIZE 14 BY 1.19 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BROWSE-2 FOR 
  ext-system SCROLLING.
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI gDialog  _DEFAULT-ENABLE
FUNCTION mark-string RETURN CHAR (buffer loc-ext-sys for ext-system , input mark-list as character ).
  if lookup ( string(recid (loc-ext-sys)) , mark-list ) > 0 then RETURN "*".
  else RETURN "".
END FUNCTION.
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BROWSE-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-2 gDialog _STRUCTURED
  QUERY BROWSE-2 NO-LOCK DISPLAY
  mark-string ( buffer ext-system , input mark-list) @ mark COLUMN-LABEL "*" FORMAT "x(1)"
  ext-system.esys-name COLUMN-LABEL "Название ВС" FORMAT "X(30)":U
  WIDTH 72
  ext-system.esys-id FORMAT "->,>>>,>>9":U WIDTH 5.8
  ext-system.esys-db-num-exp COLUMN-LABEL "БД экс" FORMAT ">>>>9":U
  WIDTH 7.6
  ext-system.esys-db-num-imp COLUMN-LABEL "БД имп" FORMAT ">>>>9":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS MULTIPLE SIZE 96 BY 24.05 ROW-HEIGHT-CHARS .67 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME gDialog
  B-mark AT ROW 1.24 COL 2.2 WIDGET-ID 4
  b-delmark AT ROW 1.24 COL 7.8 WIDGET-ID 6
  f-day-shift AT ROW 1.24 COL 40 COLON-ALIGNED WIDGET-ID 8
  b-enter AT ROW 1.24 COL 57 WIDGET-ID 2
  B-exit AT ROW 1.24 COL 80.8
  BROWSE-2 AT ROW 2.91 COL 1 WIDGET-ID 200
  WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
  SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
  TITLE "Настройки по автоматическому удалению маршрутизации ВС, работающих без подтверждения"
  CANCEL-BUTTON B-exit WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: SmartDialog
   Allow: Basic,Browse,DB-Fields,Query,Smart
   Container Links: Data-Target,Data-Source,Page-Target,Update-Source,Update-Target
   Other Settings: APPSERVER
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _INCLUDED-LIB gDialog 
/* ************************* Included-Libraries *********************** */

{src/adm2/containr.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX gDialog
   FRAME-NAME                                                           */
/* BROWSE-TAB BROWSE-2 B-exit gDialog */
ASSIGN 
  FRAME gDialog:SCROLLABLE = FALSE
  FRAME gDialog:HIDDEN     = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-2
/* Query rebuild information for BROWSE BROWSE-2
     _TblList          = "ub.ext-system"
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Where[1]         = "ext-system.esys-type = 6
 OR ext-system.esys-type = 7"
     _FldNameList[1]   > ub.ext-system.esys-name
"ext-system.esys-name" "Название ВС" ? "character" ? ? ? ? ? ? no ? no no "72" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[2]   > ub.ext-system.esys-id
"ext-system.esys-id" ? ? "integer" ? ? ? ? ? ? no ? no no "5.8" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[3]   > ub.ext-system.esys-db-num-exp
"ext-system.esys-db-num-exp" "БД экс" ? "integer" ? ? ? ? ? ? no ? no no "7.6" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[4]   > ub.ext-system.esys-db-num-imp
"ext-system.esys-db-num-imp" "БД имп" ? "integer" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _Query            is OPENED
*/  /* BROWSE BROWSE-2 */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX gDialog
/* Query rebuild information for DIALOG-BOX gDialog
     _Options          = "SHARE-LOCK"
     _Query            is NOT OPENED
*/  /* DIALOG-BOX gDialog */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME gDialog
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL gDialog gDialog
ON WINDOW-CLOSE OF FRAME gDialog /* Настройки по автоматическому удалению маршрутизации ВС, работающих без подтверждения */
  DO:  
    /* Add Trigger to equate WINDOW-CLOSE to END-ERROR. */
    APPLY "END-ERROR":U TO SELF.
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-enter
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-enter gDialog
ON CHOOSE OF b-enter IN FRAME gDialog /* Ввод */
DO:
  define variable v-param-list  as character  no-undo.
  if not (mark-list = "" or mark-list = ?) then do:
    if f-day-shift = ?
    then do:
      message "Количество дней хранения маршрутизации" skip "не должно быть пустым" view-as alert-box.
      return no-apply.
    end.
    else do:
      v-param-list = mark-list + "!" + string(f-day-shift).
      run attach-attr-to-schedule-line in this-procedure ( INPUT v-param-list ).
      message "Параметры сохранены!" view-as alert-box information.
    end.
  end.
  else do:
    message "Заданны пустые параметры, сохранить?"
      view-as alert-box question buttons OK-Cancel
      update g#log.
    if g#log then run attach-attr-to-schedule-line in this-procedure ( INPUT "" ).
      else return no-apply.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME f-day-shift
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-day-shift gDialog
ON LEAVE OF f-day-shift IN FRAME gDialog /* Дата */
DO:
  assign
    f-day-shift.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME b-delmark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-delmark gDialog
ON CHOOSE OF b-delmark IN FRAME gDialog /* Ввод */
DO:
  define variable v-rec as rowid no-undo.
  v-rec = rowid (ext-system) .
  assign
    mark-list = "" .
  {&OPEN-BROWSERS-IN-QUERY-gDialog}
  reposition BROWSE-2 to rowid (v-rec) no-error.
  apply "entry" to BROWSE-2 in frame {&frame-name}.
  apply "iteration-changed" to BROWSE-2 in frame {&frame-name}.
  BROWSE-2:select-focused-row ().
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME b-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-enter gDialog
ON CHOOSE OF b-mark IN FRAME gDialog /* Отметить */
DO:
  define variable n    as integer no-undo.
  define variable l-ok as logical no-undo.
  define variable v-rec as rowid no-undo.
  do n = 1 to BROWSE-2:num-selected-rows :
    l-ok = BROWSE-2:FETCH-SELECTED-ROW ( n ).
    if l-ok then do: 
      run local-mark in this-procedure .
    end.
  end.
  v-rec = rowid (ext-system) .
  {&OPEN-BROWSERS-IN-QUERY-gDialog}
  reposition BROWSE-2 to rowid (v-rec) no-error.
  apply "entry" to BROWSE-2 in frame {&frame-name}.
  apply "iteration-changed" to BROWSE-2 in frame {&frame-name}.
  BROWSE-2:select-focused-row ().
  BROWSE-2:select-next-row ().
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BROWSE-2
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK gDialog 


/* ***************************  Main Block  *************************** */

{src/adm2/dialogmn.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE adm-create-objects gDialog  _ADM-CREATE-OBJECTS
PROCEDURE adm-create-objects :
/*------------------------------------------------------------------------------
  Purpose:     Create handles for all SmartObjects used in this procedure.
               After SmartObjects are initialized, then SmartLinks are added.
  Parameters:  <none>
------------------------------------------------------------------------------*/

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE attach-attr-to-schedule-line gDialog 
PROCEDURE attach-attr-to-schedule-line :
DEFINE INPUT PARAMETER p-param-list AS CHARACTER NO-UNDO.
  define buffer buf_schedule      for schedule.
  define buffer buf_schedule-attr for schedule-attr.
  define buffer lock-batchprocess for ub.batchprocess.


  /*данная конкретная задача может быть ТОЛЬКО ОДНА в одной БД - отследим*/
  /*заблокируем*/
  run gbl/lock-prc.p
    (input {&lock-prc-schd-free}
    ,input 'delrt-auto':U
    ,input 0
    ,input 0
    ,input '':U
    ,input ""
    ,input ""
    ,input (
    "удаление маршрутизации ВС"
    )
    ,input yes
    ,buffer lock-batchprocess
    ) no-error .

  FIND FIRST buf_schedule-attr NO-LOCK WHERE
    buf_schedule-attr.task-type   = p-task-type
    and buf_schedule-attr.cre-db-num = INTEGER(p-db-num-char)
    and buf_schedule-attr.attr-code = ({&attr-schd-free-id} + {&delim-par} + 'delrt-auto') NO-ERROR.
  IF AVAILABLE  buf_schedule-attr
    AND buf_schedule-attr.task-num <> p-task-num
    AND buf_schedule-attr.task-num <> - 1
    and p-task-num <> - 1
    THEN 
  DO:
    MESSAGE
      substitute("Уже есть расписание удаления маршрутизации ВС для БД &1&2" +
      "номер расписания &3"
      ,buf_schedule-attr.cre-db-num
      ,{&NEW-LINE}
      ,buf_schedule-attr.task-num)
      VIEW-AS ALERT-BOX ERROR.
    UNDO, RETURN ERROR.
  END.
  find first buf_schedule no-lock
    where buf_schedule.task-type   = p-task-type
    and buf_schedule.cre-db-num  = INTEGER(p-db-num-char)
    and buf_schedule.task-num    = p-task-num
    no-error.
  if not available buf_schedule
    and (  p-task-type   <> {&btpr-type-autofree}
    or p-db-num-char <> p-db-num-char
    or p-task-num    <> -1 )
    then 
  do:
    message
      vss-workfile vss-revision vss-description
      skip 
      "Не найдена строка расписания."
      skip return-value
      skip trim(error-status :get-message(1))
      trim(error-status :get-message(2))
      trim(error-status :get-message(3))
      view-as alert-box error.
    undo, return error .
  end.

  run schedule-attr-write in this-procedure (
    input INTEGER(p-db-num-char)
    , input p-task-type
    , input p-task-num
    , input {&attr-schedule-param-list-h}
    , input p-param-list
    ).


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI gDialog  _DEFAULT-DISABLE
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
  HIDE FRAME gDialog.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI gDialog  _DEFAULT-ENABLE
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
  ENABLE B-mark b-delmark b-enter B-exit BROWSE-2 
      WITH FRAME gDialog.
  VIEW FRAME gDialog.
  run getschedule .
  {&OPEN-BROWSERS-IN-QUERY-gDialog}
  BROWSE-2:select-focused-row () no-error.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI gDialog  _DEFAULT-ENABLE
PROCEDURE local-mark:

  if not available ext-system then do:
    message "Неправильный выбор строки.".
    return no-apply.
  end.
  { gbl/markstrn.i ext-system mark-list }
   if lookup(string( recid(ext-system) ), mark-list ) = 0
      then display  "" @ mark with browse BROWSE-2.
      else display "*" @ mark with browse BROWSE-2.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI gDialog  _DEFAULT-ENABLE
procedure getschedule:
  define variable v-param-list as character no-undo.
  define variable v-param-type as character no-undo.
  run schedule-attr-value in this-procedure (            /* процедура получания параметров расписания */
    input integer(p-db-num-char)
    , input p-task-type
    , input p-task-num
    , input {&attr-schedule-param-list-h}
    , output v-param-list
    , output v-param-type
    ) no-error.
  if v-param-list <> "" then
  do:
    assign
      mark-list = entry (1, v-param-list, "!")
      f-day-shift = integer(entry (2, v-param-list, "!"))
      f-day-shift:screen-value  in frame {&FRAME-NAME} = entry (2, v-param-list, "!").
  end.



end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
