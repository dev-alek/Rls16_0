&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v9r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DECLARATIONS Dialog-Frame 
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Отчет по версиям RC на УБД

Автор: Белоусов Илья Александрович
Дата создания: 04/16/09
Author: Ilia Belousov
Creation date: 04/16/09

*/


/*          This .W file was created with the Progress AppBuilder.       */
/*----------------------------------------------------------------------*/
/* ***************************  Definitions  ************************** */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Отчет по версиям RC на УБД".

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/showinf.i  }
{ gbl/getcntxt.i def }
{ ref/shd-attr.i }

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

define variable v-text         as character no-undo .
define variable v-text-oss     as character no-undo .
define variable v-text-gds     as character no-undo .
define variable v-today        as date      no-undo .

/* Local Variable Definitions ---                                       */
define variable v-db-list     as character no-undo.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*------------------------------------------------------------------------

  File: 

  Description: 

  Input Parameters:
      <none>

  Output Parameters:
      <none>

  Author: 

  Created: 28/12/18 -  1:23 pm

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress AppBuilder.       */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

define variable c-dir          as character no-undo. /* Директория для сохранения файла */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-quit RECT-3 num-days 
&Scoped-Define DISPLAYED-OBJECTS num-days sel-dbs 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-exit AUTO-GO 
     LABEL "&Ввод" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-quit AUTO-END-KEY 
     LABEL "&Отмена" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE num-days AS INTEGER FORMAT ">>>9":U INITIAL 0 
     LABEL "За последние" 
     VIEW-AS FILL-IN 
     SIZE 14 BY 1 NO-UNDO.

DEFINE RECTANGLE RECT-3
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 43.5 BY 10.25.

DEFINE VARIABLE sel-dbs AS CHARACTER 
     VIEW-AS SELECTION-LIST MULTIPLE SCROLLBAR-VERTICAL 
     SIZE 9.5 BY 8.63 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 2.63
     b-quit AT ROW 1 COL 12.63
     num-days AT ROW 2.5 COL 19.5 COLON-ALIGNED WIDGET-ID 22
     sel-dbs AT ROW 4.38 COL 22.5 NO-LABEL WIDGET-ID 50
     "дней" VIEW-AS TEXT
          SIZE 8 BY 1 AT ROW 2.5 COL 36 WIDGET-ID 32
     "БД для выбора:" VIEW-AS TEXT
          SIZE 16 BY 1 AT ROW 4.25 COL 3.5 WIDGET-ID 48
          FGCOLOR 4 
     RECT-3 AT ROW 3.75 COL 2.5 WIDGET-ID 20
     SPACE(3.87) SKIP(1.20)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Параметры отчета по версиям RC"
         DEFAULT-BUTTON b-exit CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   Allow: Basic,Browse,DB-Fields,Query
   Other Settings: COMPILE
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR SELECTION-LIST sel-dbs IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Параметры отчета по версиям RC */
DO:
    APPLY "END-ERROR":U TO SELF.
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit Dialog-Frame
ON CHOOSE OF b-exit IN FRAME Dialog-Frame /* Ввод */
DO:
    RUN proc-save IN THIS-PROCEDURE .
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME sel-dbs
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sel-dbs Dialog-Frame
ON VALUE-CHANGED OF sel-dbs IN FRAME Dialog-Frame
DO:
  assign
  sel-dbs
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


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
  ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

{ gbl/getcntxt.i get }

  run init-fields in this-procedure .
if p-mode = 'shd':U then 
do:
  assign
    frame {&frame-name} :title = frame {&frame-name} :title +
                        substitute(". &1: БД &2, Задача номер &3"
                        , p-task-type
                        , p-db-num-char
                        , p-task-num )
    .
end.
run init-param-values in this-procedure ( input p-task-type
  , input p-db-num-char
  , input p-task-num
  /*                                          , OUTPUT v-dir-name*/
  ) .

RUN enable_UI.

WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE attach-attr-to-schedule-line Dialog-Frame 
PROCEDURE attach-attr-to-schedule-line :
/*------------------------------------------------------------------------------
            Purpose:
            Parameters:  <none>
            Notes:
          ------------------------------------------------------------------------------*/
  DEFINE INPUT PARAMETER p-param-list AS CHARACTER NO-UNDO.
  define buffer buf_schedule      for schedule.
  define buffer buf_schedule-attr for schedule-attr.
  define buffer lock-batchprocess for ub.batchprocess.

  CASE p-mode:
    when 'shd':U then 
      do:
        /*данная конкретная задача может быть ТОЛЬКО ОДНА в одной БД - отследим*/
        /*заблокируем*/
        run gbl/lock-prc.p
          (input {&lock-prc-schd-free}
          ,input 'rep-RC':U
          ,input 0
          ,input 0
          ,input '':U
          ,input ""
          ,input ""
          ,input (
          "Отчет по версиям RC"
          )
          ,input yes
          ,buffer lock-batchprocess
          ) no-error .

        FIND FIRST buf_schedule-attr NO-LOCK WHERE
          buf_schedule-attr.task-type   = p-task-type
          and buf_schedule-attr.cre-db-num = INTEGER(p-db-num-char)
          and buf_schedule-attr.attr-code = ({&attr-schd-free-id} + {&delim-par} + 'rep-RC') NO-ERROR.
        IF AVAILABLE  buf_schedule-attr
          AND buf_schedule-attr.task-num <> p-task-num
          AND buf_schedule-attr.task-num <> - 1
          and p-task-num <> - 1
          THEN 
        DO:
          MESSAGE
            substitute("Уже есть расписание для отчета по версиям RC &1&2" +
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
      end.
    when 'run':U then 
      do:
        p-params = p-param-list.
      end.
  END CASE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE check-host-list Dialog-Frame 
PROCEDURE check-host-list :
/* -----------------------------------------------------------
            Purpose:
            Parameters:  <none>
            Notes:
          -------------------------------------------------------------*/
  define input-output parameter pHost-code-list as character no-undo.

  define variable iCount        as integer   no-undo.
  define variable cTemp         as character no-undo.
  define variable iTempHostCode as integer   no-undo.
  define variable cNewHostList  as character no-undo.
  define variable lOk           as logical   no-undo.

  do iCount = 1 to num-entries( pHost-code-list ):
    cTemp = entry( iCount, pHost-code-list ).
    assign
      iTempHostCode = integer( cTemp ) no-error
      .
    run validate-host( iTempHostCode, no, no, output lOk ).
    if lOk and lookup( string( iTempHostCode ), cNewHostList ) = 0
      then 
    do:
      assign
        cNewHostList = cNewHostList + ',' + string( iTempHostCode )
        .
    end.
  end.
  pHost-code-list = trim( cNewHostList, ',' ).

  return.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE convert Dialog-Frame 
PROCEDURE convert :
/*------------------------------------------------------------------------------
            Purpose:
            Parameters:  <none>
            Notes:
          ------------------------------------------------------------------------------*/
  define input-output parameter v-rid-list as character no-undo.

  define variable v-list as character no-undo .
  define variable v-ind  as integer   no-undo .

  define buffer buf_sysconf for ub.sysconf.

  do
    on error undo, return error return-value
    :
    do v-ind = 1 to num-entries(v-rid-list)
      :
      find first buf_sysconf no-lock
        where recid(buf_sysconf) = integer(entry(v-ind, v-rid-list))
        no-error .
      if available buf_sysconf
        then 
      do:
        assign
          v-list = v-list
                  + (if v-list = '':U
                    then '':U
                    else {&comma-char}
                    )
                  + string(buf_sysconf.host-code)
          .
      end.
    end.
    assign
      v-rid-list = v-list
      .
  end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

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
  DISPLAY num-days sel-dbs 
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-quit RECT-3 num-days sel-dbs
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-param-values Dialog-Frame 
PROCEDURE init-param-values :
/*------------------------------------------------------------------------------
            Purpose:
            Parameters:  <none>
            Notes:
          ------------------------------------------------------------------------------*/
  do
    on error undo, return error
    :
    define input parameter p-task-type              as character    no-undo.
    define input parameter p-db-num-char            as character    no-undo.
    define input parameter p-task-num               as integer      no-undo.
    /*define output parameter p-dir                   as character    no-undo.*/
  
    define variable v-param-list as character no-undo.
    define variable v-param-type as character no-undo.
    define variable v-obj-list   as character no-undo .
    define variable v-gds-list   as character no-undo .
    define variable v-oss-list   as character no-undo .
    define variable ii           as integer   no-undo .
    define variable v-entry-1    as character no-undo .
    define variable v-entry-2    as character no-undo .
    define variable v-entry-3    as character no-undo .
    define variable v-task-num   as integer   no-undo .
    define variable v-ii1        as integer   no-undo.
    define variable v-text       as character no-undo.
    define variable v-ii2        as integer   no-undo.
  
 
    define buffer buf_schedule      for ub.schedule.
    define buffer buf_schedule-attr for ub.schedule-attr.
    
    DO WITH FRAME Dialog-Frame:

      CASE p-mode:
        when 'shd':U then 
          do:
  
            if p-task-num > 0
              then 
            do:
              v-task-num = p-task-num.
            end.
            else 
            do:
              for each buf_schedule
                where buf_schedule.task-type     = p-task-type
                AND buf_schedule.cre-db-num    = INTEGER(p-db-num-char)
                no-lock
                ,
                first buf_schedule-attr
                where buf_schedule-attr.task-type   = p-task-type
                AND buf_schedule-attr.cre-db-num  = INTEGER(p-db-num-char)
                AND buf_schedule-attr.task-num    = buf_schedule.task-num
                AND buf_schedule-attr.attr-code   = ({&attr-schd-free-id} + {&delim-par} + 'help-road')
                no-lock
                :
                ASSIGN
                  v-task-num = buf_schedule.task-num
                  .
                leave .
              end.
            end.
            if v-task-num > 0
              then 
            do:
              run schedule-attr-value in this-procedure  ( input p-db-num-char
                , input p-task-type
                , input v-task-num
                , input {&attr-schedule-param-list-h}
                , output v-param-list
                , output v-param-type
                ) .
              run schedule-attr-value in this-procedure  ( input p-db-num-char
                , input p-task-type
                , input v-task-num
                , input {&attr-schedule-obj-list-h}
                , output v-obj-list
                , output v-param-type
                ) .
              run schedule-attr-value in this-procedure  ( input p-db-num-char
                , input p-task-type
                , input v-task-num
                , input {&attr-schedule-oss-list-h}
                , output v-oss-list
                , output v-param-type
                ) .
              run schedule-attr-value in this-procedure  ( input p-db-num-char
                , input p-task-type
                , input v-task-num
                , input {&attr-schedule-gds-list-h}
                , output v-gds-list
                , output v-param-type
                ) .                                                                                                          
            end.
            v-ii2 = num-entries( v-param-list, {&delim-par} ).
            if v-ii2 < 7 THEN 
            do:
              do v-ii1 = v-ii2 to 2:
                v-param-list = v-param-list
                  + '':U
                  + {&delim-par}.
              end.
            end.
              
            ASSIGN
              sel-dbs     = ENTRY(2, v-param-list, {&delim-par})
              num-days    = INTEGER( ENTRY(1, v-param-list, {&delim-par}) )
              .
            DISPLAY
              num-days
              sel-dbs              
              .
        end.
        WHEN 'run'
        THEN 
          DO:
            v-param-list = '':U
              + {&delim-par}
              + '':U
              + {&delim-par}
              + '':U
              + {&delim-par}
              + '':U
              + {&delim-par}
              + '':U
              + {&delim-par}.
          END.
  
      END CASE.
    END. /*DO WITH FRAME Dialog-Frame*/ 
  END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-save Dialog-Frame 
PROCEDURE proc-save :
/*------------------------------------------------------------------------------
            Purpose:
            Parameters:  <none>
            Notes:
          ------------------------------------------------------------------------------*/
  DEFINE VARIABLE glog             AS LOGICAL   NO-UNDO.
  DEFINE VARIABLE v-param-list     AS CHARACTER NO-UNDO.
  define variable ii               as integer   no-undo .
 

  ASSIGN
    FRAME {&frame-name}
    num-days
    sel-dbs
    .
  if num-days < 0 then 
  do:
    message
      "Кол-во дней задан неверно. "
      skip "Задайте интервал правильно или отмените экспорт."
      view-as alert-box information.
    apply "entry" to num-days.
    undo, return no-apply.
  end.    

    assign
      v-db-list = sel-dbs . 
      .

  ASSIGN
  
    v-param-list = string(if num-days <> ? then string(num-days) else "") + {&delim-par} +
    v-db-list + {&delim-par} 
    .
    
  IF p-mode = 'shd' THEN 
  DO:
    run attach-attr-to-schedule-line in this-procedure ( INPUT v-param-list
      ) .
  END.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-fields Dialog-Frame 
PROCEDURE init-fields :
/*------------------------------------------------------------------------------
    Purpose:
    Parameters:  <none>
    Notes:
  ------------------------------------------------------------------------------*/
  define buffer buf_sys-ctrl for ub.sys-ctrl .
  define buffer buf_db       for db .
  define variable v-db-list as character no-undo .
  do
    with frame {&frame-name}
    on error undo, return error
    :
    FIND FIRST buf_sys-ctrl No-LOCK.
      For each buf_db no-LOCK:
        assign
          v-db-list = substitute( "&1&2&3", v-db-list, {&comma-char}, buf_db.db-num )
          .
      end.

    assign
      sel-dbs :list-items in frame {&frame-name} = v-db-list  .
    .
  end.
END PROCEDURE. /* init-fields */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME