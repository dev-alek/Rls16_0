&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*------------------------------------------------------------------------

  File: 

  Description: Установка причин РВД в интерфейсе настройки резервуара (Складского места)

  Input Parameters:
      <none>

  Output Parameters:
      <none>

  Author: 

  Created: 
------------------------------------------------------------------------*/
/*          This .W file was created with the Progress AppBuilder.       */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */
define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Выбор причины установки РВД" .
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i }
{ ref/extclass.i }
{ gbl/getcntxt.i def }
/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-type as integer no-undo .
define output parameter p-rvd-reason as character no-undo .
define output parameter p-ITSM-num as character no-undo .
define output parameter p-oper-fio as character no-undo .
/* Local Variable Definitions ---                                       */


define buffer buf_ext-classif for ub.ext-classif .
define buffer buf_user-account for ub.user-account .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS Btn_OK Btn_Cancel f-rvd-reason r-select-rvd-reason f-ITSM-num ~
f-oper-fio 
&Scoped-Define DISPLAYED-OBJECTS f-rvd-reason r-select-rvd-reason f-ITSM-num f-oper-fio 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON Btn_Cancel AUTO-END-KEY 
     LABEL "Отмена" 
     SIZE 15 BY 1
     BGCOLOR 8 .

DEFINE BUTTON Btn_OK AUTO-GO 
     LABEL "Ввод" 
     SIZE 15 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE f-ITSM-num AS CHARACTER FORMAT "X(256)":U 
     LABEL "Номер заявки в ITSM" 
     VIEW-AS FILL-IN 
     SIZE 50 BY 1 NO-UNDO.

DEFINE VARIABLE f-oper-fio AS CHARACTER FORMAT "X(256)":U 
     LABEL "ФИО инициатора заявки" 
     VIEW-AS FILL-IN 
     SIZE 50 BY 1 NO-UNDO.
     
DEFINE VARIABLE f-inv-fio AS CHARACTER FORMAT "X(256)":U 
     LABEL "ФИО сотрудника инвентаризационной комиссии" 
     VIEW-AS FILL-IN 
     SIZE 29 BY 1 NO-UNDO.

DEFINE VARIABLE f-rvd-reason AS character FORMAT "X(64)":U INITIAL "" 
     LABEL "Основание/причина разрешения РВД" 
     VIEW-AS FILL-IN 
     SIZE 15 BY 1 NO-UNDO.
     
DEFINE VARIABLE v-reason-name AS CHARACTER FORMAT "X(256)":U 
    VIEW-AS FILL-IN 
    SIZE 20 BY 1 NO-UNDO.

DEFINE BUTTON r-select-rvd-reason 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "r-sr-izm" 
     SIZE 3 BY .88.

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     Btn_OK AT ROW 1.2 COL 2
     Btn_Cancel AT ROW 1.2 COL 17
     f-rvd-reason AT ROW 3 COL 41 COLON-ALIGNED WIDGET-ID 2
     v-reason-name at row 3 col 60 no-label
     r-select-rvd-reason at row 3 col 80
     f-ITSM-num AT ROW 4.5 COL 25 COLON-ALIGNED WIDGET-ID 4
     f-oper-fio AT ROW 6 COL 25 COLON-ALIGNED WIDGET-ID 6
     f-inv-fio AT ROW 6 COL 4 WIDGET-ID 6
     SPACE(2) SKIP(1)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Причины установки РВД"
         DEFAULT-BUTTON Btn_OK CANCEL-BUTTON Btn_Cancel WIDGET-ID 100.


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

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Причины установки РВД */
DO:
  p-rvd-reason = ? .
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME Btn_Cancel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON choose of Btn_Cancel in FRAME Dialog-Frame /* Причины установки РВД */
DO:
  p-rvd-reason = ? .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME  

on F2 of frame Dialog-Frame anywhere do:
 return no-apply.
end.

&Scoped-define SELF-NAME Btn_OK
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON choose of Btn_OK in FRAME Dialog-Frame /* Причины установки РВД */
DO:
  assign
    f-rvd-reason
    f-ITSM-num
    f-oper-fio
    f-inv-fio
  .
  if f-rvd-reason = "" or f-rvd-reason = ?
  then do :
    message 'Не заполнено поле "Основание/причина разрешения РВД". Все поля формы обязательны для заполнения. Для отказа установки разрешения РВД необходимо нажать "Отмена"'
    view-as alert-box .
    return no-apply .
  end .
  find first buf_ext-classif no-lock where buf_ext-classif.CharKey_One = f-rvd-reason
                                       and buf_ext-classif.classif-subject = {&extclass_rvd-reason} 
                                       and buf_ext-classif.classif-name = {&extclass_rvd-reason}
                                       no-error .
  if not available buf_ext-classif
  then do :
    v-reason-name:screen-value = "" .
    message "Не заполнено основание для перехода на РВД" view-as alert-box .
    return no-apply .
  end .
  if trim(f-ITSM-num) = ""
  then do :
    if f-ITSM-num:label = "Номер приказа"
    then do :
      message 'Не заполнено поле "Номер приказа". Все поля формы обязательны для заполнения. Для отказа установки разрешения РВД необходимо нажать "Отмена"'
      view-as alert-box .
    end .
    else do :
      message 'Не заполнено поле "Номер заявки в ITSM". Все поля формы обязательны для заполнения. Для отказа установки разрешения РВД необходимо нажать "Отмена"'
      view-as alert-box .
    end .
    return no-apply .
  end .
  if f-oper-fio:visible
  and trim(f-oper-fio) = ""
  then do :
    message 'Не заполнено поле "ФИО инициатора заявки". Все поля формы обязательны для заполнения. Для отказа установки разрешения РВД необходимо нажать "Отмена"'
    view-as alert-box .
    return no-apply .
  end .
  if f-inv-fio:visible
  and trim(f-inv-fio) = ""
  then do :
    message 'Не заполнено поле "ФИО сотрудника инвентаризационной комиссии". Все поля формы обязательны для заполнения. Для отказа установки разрешения РВД необходимо нажать "Отмена"'
    view-as alert-box .
    return no-apply .
  end .
  assign
    p-rvd-reason  = f-rvd-reason
    p-ITSM-num    = f-ITSM-num
    p-oper-fio    = f-oper-fio
  .
  if f-inv-fio:visible then p-oper-fio = f-inv-fio .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME f-rvd-reason
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
on leave OF f-rvd-reason IN FRAME Dialog-Frame
DO:
  find first buf_ext-classif no-lock where buf_ext-classif.CharKey_One = f-rvd-reason:screen-value
                                       and buf_ext-classif.classif-subject = {&extclass_rvd-reason} 
                                       and buf_ext-classif.classif-name = {&extclass_rvd-reason}
                                       no-error .
  if not available buf_ext-classif
  then do :
    v-reason-name:screen-value = "" .
  end .
  else do :  
    if buf_ext-classif.Key#_Two <> 0
    then do :
      message "Выбранное основание для перехода на РВД предназначено НЕ для РГС!" view-as alert-box .
      f-rvd-reason:screen-value = "0" .
    end .
    else
    if buf_ext-classif.nonuniq = 1
    then do :
      message "Выбранное основание для перехода на РВД удалено!" view-as alert-box .
      f-rvd-reason:screen-value = "0" .
    end .
    else
      v-reason-name:screen-value = buf_ext-classif.CharKey_Two .    
  end .                            
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME r-select-rvd-reason
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
on choose of r-select-rvd-reason IN FRAME Dialog-Frame
do:
  define variable v-rec as character no-undo .
  run ref/rvd-reason.w (input parparentproc,
                        input "b-sel",
                        input {&current},
                        input p-type,
                        output v-rec ) .
  find first buf_ext-classif no-lock where recid(buf_ext-classif) = integer(v-rec) no-error .
  if not available buf_ext-classif
  then do :
    message "Не заполнено основание для перехода на РВД" view-as alert-box .
    return no-apply .
  end .  
  v-reason-name:screen-value = buf_ext-classif.CharKey_Two .
  f-rvd-reason:screen-value = buf_ext-classif.CharKey_One .                    
end .
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
  
  f-inv-fio:visible = false .
  RUN enable_UI.
  if p-type = -1
  then do :
    p-type = 0 .
    f-ITSM-num:label = "Номер приказа" .
    hide f-oper-fio in FRAME Dialog-Frame.
    for first buf_user-account no-lock where buf_user-account.user-id = v-cntxt-userid :
      f-inv-fio = buf_user-account.last-name + " " + buf_user-account.first-name + " " + buf_user-account.second-name .
    end .
    DISPLAY f-ITSM-num f-inv-fio 
      WITH FRAME Dialog-Frame.
    ENABLE f-inv-fio 
      WITH FRAME Dialog-Frame.
  end .
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
  DISPLAY f-rvd-reason f-ITSM-num f-oper-fio r-select-rvd-reason 
      WITH FRAME Dialog-Frame.
  ENABLE Btn_OK Btn_Cancel f-rvd-reason f-ITSM-num f-oper-fio r-select-rvd-reason 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

