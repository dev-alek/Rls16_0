&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*------------------------------------------------------------------------

  File: 

  Description: 

  Input Parameters:
      <none>

  Output Parameters:
      <none>

  Author: 

  Created: 
------------------------------------------------------------------------*/
/*          This .W file was created with the Progress AppBuilder.       */
/*----------------------------------------------------------------------*/
using ibs.th.bge.is_PM.*.
/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .

/* Local Variable Definitions ---                                       */
define variable log-file-name     as character no-undo initial "OB-to-PM.log" .
define variable is_PM         as class is_PM no-undo .
define variable curr-exec-date as date no-undo .
define variable v-pid as int64 no-undo .

{ cmp/trg-def.i  }
{ cmp/str-glbl.i }
{ gbl/sel-date.i }
{ cmp/showinf.i  }
{ gbl/waitfram.i }
{ gbl/prn-lib.i  }
{ gbl/getcntxt.i def }
{ gbl/cur-time.i }

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-ok b-cancel b-date f-rep-date f-timediff 
&Scoped-Define DISPLAYED-OBJECTS f-rep-date f-timediff 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-cancel AUTO-END-KEY 
     LABEL "Отмена" 
     SIZE 15 BY 1.14
     BGCOLOR 8 .

DEFINE BUTTON b-date1 
     image-up          file "btn-down-arrow"
     image-down        file "btn-down-arrow"
     image-insensitive file "btn-down-arrow"
     size 3 by .88.
     
DEFINE BUTTON b-date2 
     image-up          file "btn-down-arrow"
     image-down        file "btn-down-arrow"
     image-insensitive file "btn-down-arrow"
     size 3 by .88.     

DEFINE BUTTON b-ok AUTO-GO 
     LABEL "Выполнить" 
     SIZE 15 BY 1.14
     BGCOLOR 8 .

DEFINE VARIABLE f-rep-date1 AS DATE FORMAT "99/99/9999":U INITIAL ? 
     LABEL "Период С" 
     VIEW-AS FILL-IN 
     SIZE 12 BY 1 NO-UNDO.
     
DEFINE VARIABLE f-rep-date2 AS DATE FORMAT "99/99/9999":U INITIAL ? 
     LABEL "По" 
     VIEW-AS FILL-IN 
     SIZE 12 BY 1 NO-UNDO.

DEFINE VARIABLE f-timediff AS INTEGER FORMAT "->>>9":U INITIAL 0 
     LABEL "Разница с московским часовым поясом, ч." 
     VIEW-AS FILL-IN 
     SIZE 7.2 BY 1 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-ok AT ROW 1.24 COL 2
     b-cancel AT ROW 1.24 COL 17
     b-date1 AT ROW 2.95 COL 24 WIDGET-ID 6
     b-date2 AT ROW 2.95 COL 44 WIDGET-ID 6
     f-rep-date1 AT ROW 3 COL 10 COLON-ALIGNED WIDGET-ID 2
     f-rep-date2 AT ROW 3 COL 30 COLON-ALIGNED WIDGET-ID 8
     f-timediff AT ROW 4.4 COL 2 WIDGET-ID 4
     SPACE(0.39) SKIP(0.52)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Выгрузка данных ПМ в 1С"
         DEFAULT-BUTTON b-ok CANCEL-BUTTON b-cancel WIDGET-ID 100.


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

/* SETTINGS FOR FILL-IN f-timediff IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Ежедневный отчет по движению топлива */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME b-date
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-date Dialog-Frame
ON CHOOSE OF b-date1 IN FRAME Dialog-Frame 
DO:
  run sel-date in this-procedure
    (input f-rep-date1 :handle
    ,input ""
    ) .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME b-date
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-date Dialog-Frame
ON CHOOSE OF b-date2 IN FRAME Dialog-Frame 
DO:
  run sel-date in this-procedure
    (input f-rep-date2 :handle
    ,input ""
    ) .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME b-ok
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-ok Dialog-Frame
ON CHOOSE OF b-ok IN FRAME Dialog-Frame 
DO:
  assign
    f-rep-date1
    f-rep-date2
    f-timediff
  .
  if f-rep-date1 > f-rep-date2
  or f-rep-date1 > today
  then do :
    message "Даты введены неверно!" view-as alert-box .
    return no-apply .
  end .
  run waitfram-show in this-procedure ( input "Ждите..." ).  
  curr-exec-date = f-rep-date1 .
  do while curr-exec-date <= f-rep-date2 :
    run waitfram-show in this-procedure ( input ("Формирование данных за "  + string(curr-exec-date) )).
    is_PM = new is_PM (input v-cntxt-db-num,
                       input v-cntxt-obj-code,
                       input (string(f-timediff) + ",10,10"),
                       input parparentproc,
                       input this-procedure,
                       input curr-exec-date)
                      .
    is_PM:exec_1c() .
    run str/send1C-some-data.p (input parparentproc,
                                input this-procedure,
                                input parparentproc,
                                input is_PM:Data,
                                input "operating-balances") 
                                no-error .
    if error-status:error
    then do :
      delete object is_PM .
      run write-to-log( "Ошибка при отправке в 1С данных за " + string(curr-exec-date) + ".   " + return-value ).
      curr-exec-date = curr-exec-date + 1 .
    end .   
    delete object is_PM .
    curr-exec-date = curr-exec-date + 1 .
  end .
  run waitfram-hide in this-procedure.
  message "Данные для 1С успешно сформированы" view-as alert-box .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame 


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

{ gbl/ed_date.i f-rep-date1 }
{ gbl/ed_date.i f-rep-date2 }

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  { gbl/getcntxt.i get }
  
  run GetCurrentProcessID (output v-pid) .
  
  f-timediff = (timezone - 180) / 60 .
  f-rep-date1 = today - 1 .
  f-rep-date2 = today - 1 .
  RUN enable_UI.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

procedure write-to-log :
  define input param p-str as character no-undo .
  
  assign
    p-str = substitute( "&1 (pid: &2) &3 &4&5", g#userid, v-pid, cur-time-string-sec(), p-str, {&new-line} )
  .
  output to value(log-file-name) append .
  put unformatted p-str .
  output close .
  
end procedure .

PROCEDURE write-log-and-file :
  define input parameter p-tab-position   as integer   no-undo.
  define input parameter p-file-name      as character no-undo .
  define input parameter p-log-level      as integer   no-undo .
  define input parameter p-log-string     AS CHARacter NO-UNDO.
  define variable v-jj as integer   no-undo .
  run write-to-log (input p-log-string) .
end procedure .

PROCEDURE GetCurrentProcessId EXTERNAL "kernel32.dll" :
  DEFINE RETURN PARAMETER RetVal          AS LONG.
END PROCEDURE.

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
  DISPLAY f-rep-date1  f-rep-date2 f-timediff 
      WITH FRAME Dialog-Frame.
  ENABLE b-ok b-cancel b-date1 b-date2 f-rep-date1  f-rep-date2 f-timediff 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

