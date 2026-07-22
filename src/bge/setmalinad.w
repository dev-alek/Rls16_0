&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Изменение даты выгрузки данных в Малину

Автор: Гридчина Полина
Дата создания: 22/09/14
Author: Polina Gridchina
Creation date: 22/09/14

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

define input parameter parparentproc as handle no-undo.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Изменение даты выгрузки данных в Малину".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/showinf.i  }
{ gbl/getcntxt.i def }
{ gbl/userobjs.i }
{ gbl/clntattr.i }

define buffer buf_clients for ub.clients.

define variable v-host-name as character no-undo.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS RECT-1 RECT-2 Btn_OK Btn_save cb-type d_date ~
i_shift i_op-id RADIO-SET_objects bt-sel-obj 
&Scoped-Define DISPLAYED-OBJECTS cb-type d_date i_shift i_op-id ~
EDITOR-objects RADIO-SET_objects 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON bt-sel-obj 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "..." 
     SIZE 3.63 BY 1.04.

DEFINE BUTTON Btn_OK AUTO-GO 
     LABEL "&Выход" 
     SIZE 15 BY 1.13
     BGCOLOR 8 .

DEFINE BUTTON Btn_save 
     LABEL "Сохранить" 
     SIZE 15 BY 1.13.

DEFINE VARIABLE cb-type AS CHARACTER FORMAT "X(256)":U 
    LABEL "Тип выгрузки" 
    VIEW-AS COMBO-BOX INNER-LINES 3
    LIST-ITEM-PAIRS "Малина ","mal ",
    "Система АТД", "atd"
    DROP-DOWN-LIST
    SIZE 16 BY 1 NO-UNDO.

DEFINE VARIABLE EDITOR-objects AS CHARACTER 
     VIEW-AS EDITOR NO-BOX
     SIZE 45 BY 3.38
     FGCOLOR 1  NO-UNDO.

DEFINE VARIABLE d_date AS DATE FORMAT "99/99/9999":U 
     LABEL "Дата" 
     VIEW-AS FILL-IN 
     SIZE 12 BY .96 NO-UNDO.

DEFINE VARIABLE i_op-id AS INTEGER FORMAT "->,>>>,>>9" INITIAL 1 
     LABEL "№ пакета" 
     VIEW-AS FILL-IN 
     SIZE 11 BY .96 NO-UNDO.

DEFINE VARIABLE i_shift AS INTEGER FORMAT ">9":U INITIAL 0 
     LABEL "Порядок смены" 
     VIEW-AS FILL-IN 
     SIZE 5 BY .96 NO-UNDO.

DEFINE VARIABLE RADIO-SET_objects AS INTEGER 
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS 
          "по фирме", 1,
"по объектам", 2
     SIZE 18 BY 3 NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 69 BY 4.04.

DEFINE RECTANGLE RECT-2
    EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
    SIZE 69 BY 2.

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
    Btn_OK AT ROW 1.25 COL 2
    Btn_save AT ROW 1.25 COL 18 WIDGET-ID 2
    cb-type AT ROW 4.25 COL 16.5 COLON-ALIGNED WIDGET-ID 22
    d_date AT ROW 7 COL 7.5 COLON-ALIGNED WIDGET-ID 4
    i_shift AT ROW 7 COL 38 COLON-ALIGNED WIDGET-ID 6
    i_op-id AT ROW 7 COL 58 COLON-ALIGNED WIDGET-ID 20
    EDITOR-objects AT ROW 9.25 COL 26 NO-LABEL WIDGET-ID 14
    RADIO-SET_objects AT ROW 9.5 COL 4 NO-LABEL WIDGET-ID 8
    bt-sel-obj AT ROW 11.25 COL 22 WIDGET-ID 18
    RECT-1 AT ROW 9 COL 2.5 WIDGET-ID 12
    RECT-2 AT ROW 3.75 COL 2.5 WIDGET-ID 24
    SPACE(2.12) SKIP(7.74)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
    SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
    TITLE "Изменение даты выгрузки данных "
    DEFAULT-BUTTON Btn_OK WIDGET-ID 100.


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

/* SETTINGS FOR EDITOR EDITOR-objects IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Изменение даты выгрузки данных в систему Малина */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-sel-obj
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-sel-obj Dialog-Frame
ON CHOOSE OF bt-sel-obj IN FRAME Dialog-Frame /* ... */
DO:
    define variable v-obj-list as character no-undo.
    define variable v-exclude-obj-list as character no-undo.

    define variable v-object-available as logical no-undo.

    RADIO-SET_objects:screen-value = "2".
    
    {gbl/uobjclr.i}
    
    {gbl/usobjava.i
     v-cntxt-db-num
     {&action-head-code-main}
     v-cntxt-userid
     v-cntxt-obj-type
     v-cntxt-obj-code
     v-object-available
     no-error}
     
    if error-status :error then do:
        message vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры gbl/usobjava.i" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error.
        undo, return no-apply.
    end. /* if error-status */

    if v-object-available then do:
        {gbl/uobjapnd.i
         v-cntxt-obj-type
         v-cntxt-obj-code}
    end.

    define variable v-user-select as logical no-undo.
    {gbl/uobjsman.i
     parparentproc
     v-cntxt-db-num
     v-cntxt-userid
     v-cntxt-host-code-obj
     v-cntxt-obj-type
     v-cntxt-obj-code
     v-user-select}
     
    if v-user-select <> true then do:
      message "Объект не выбран" view-as alert-box information.
      return no-apply.
    end.
        
    v-obj-list = "".
        
    for each userobjs_temp-user-obj:
        v-obj-list = v-obj-list + (if v-obj-list <> "" then ", " else "")
                   + userobjs_temp-user-obj.obj-type + string( userobjs_temp-user-obj.obj-code).
    end. /* for each userobjs_temp-user-obj */
    
    EDITOR-objects :screen-value = v-obj-list.
    
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_OK
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_OK Dialog-Frame
ON CHOOSE OF Btn_OK IN FRAME Dialog-Frame /* Выход */
DO:
    APPLY "GO" TO FRAME {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_save
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_save Dialog-Frame
ON CHOOSE OF Btn_save IN FRAME Dialog-Frame /* Сохранить */
DO:
    ASSIGN
    d_date
    i_shift
    i_op-id
    RADIO-SET_objects
    cb-type.

    if d_date = ? then do:
        message "Введите дату." view-as alert-box.
        return.
    end.
    
    case cb-type:
      when "mal" then do:
        if RADIO-SET_objects = 1 then do: /* 1 = по фирме */

            for each buf_clients no-lock where buf_clients.host-code = v-cntxt-host-code-obj:
                run clntattr-write in this-procedure (input buf_clients.obj-type
                                                     ,input buf_clients.obj-code
                                                     ,input {&attr-bge-exp-malina-last-shift}
                                                     ,input substitute ("&1,&2,&3",d_date ,i_shift,i_op-id)).
            end.

        end.
        else do: /* 2 = по объектам */

            for each userobjs_temp-user-obj no-lock:
                run clntattr-write in this-procedure (input userobjs_temp-user-obj.obj-type
                                                     ,input userobjs_temp-user-obj.obj-code
                                                     ,input {&attr-bge-exp-malina-last-shift}
                                                     ,input substitute ("&1,&2,&3",d_date ,i_shift,i_op-id)).
            end.

        end.
      end. /* end_of mal'ина */
      when 'atd' then do:
        if RADIO-SET_objects = 1 then do: /* 1 = по фирме */

            for each buf_clients no-lock where buf_clients.host-code = v-cntxt-host-code-obj:
              run clntattr-write in this-procedure (input buf_clients.obj-type
                                ,input buf_clients.obj-code
                                ,input {&attr-bge-exp-last-atd}
                                ,input substitute ("&1,&2",d_date ,(i_shift))).
            end.

        end.
        else do: /* 2 = по объектам */

            for each userobjs_temp-user-obj no-lock:
              run clntattr-write in this-procedure (input userobjs_temp-user-obj.obj-type
                                ,input userobjs_temp-user-obj.obj-code
                                ,input {&attr-bge-exp-last-atd}
                                ,input substitute ("&1,&2",d_date ,(i_shift))).
            end.

        end.
      end. /* end_of atd - анализ треков данных */
      otherwise .
    end case.

APPLY "GO" TO FRAME {&FRAME-NAME}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME cb-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL cb-type Dialog-Frame
ON VALUE-CHANGED OF cb-type IN FRAME Dialog-Frame /* Тип выгрузки */
    DO:

        assign cb-type.

        if cb-type = "mal" then assign
                i_shift:label  = "Порядок смены" 
                i_shift:format = "x(1)"
                .

        run get-values in this-procedure.
    end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME RADIO-SET_objects
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL RADIO-SET_objects Dialog-Frame
ON VALUE-CHANGED OF RADIO-SET_objects IN FRAME Dialog-Frame
DO:
    case RADIO-SET_objects :screen-value in frame Dialog-frame:

        when "1" then do:
            
            EDITOR-objects:screen-value = v-host-name.
            hide bt-sel-obj in frame Dialog-Frame.
        
        end. /* when "1" then */
        
        when "2" then do:
            
            display bt-sel-obj with frame Dialog-Frame.
            
            for each userobjs_temp-user-obj:
                delete userobjs_temp-user-obj.
            end.
            
            create userobjs_temp-user-obj.
            assign
                userobjs_temp-user-obj.obj-type = v-cntxt-obj-type
                userobjs_temp-user-obj.obj-code = v-cntxt-obj-code
                EDITOR-objects:screen-value = v-cntxt-obj-type + string(v-cntxt-obj-code).
        
        end. /* when "2" then do */
        
    end case.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame 


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

{gbl/ed_date.i d_date}

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
       
  {gbl/getcntxt.i get}

  run get-host-name in this-procedure ( output v-host-name ) no-error .
  if error-status :error
  then do:
      message
        vss-workfile vss-revision vss-description
        skip "Ошибка при определении имени фирмы"
        skip "Код фирмы:" v-cntxt-host-code-obj
        skip "Имя фирмы будет отображаться как '" + {&cmp} + string( v-cntxt-host-code-obj ) + "'"
        skip return-value
        skip trim(error-status :get-message(1))
             trim(error-status :get-message(2))
             trim(error-status :get-message(3))
             trim(error-status :get-message(4))
             trim(error-status :get-message(5))
      view-as alert-box warning.
      assign
          v-host-name = {&cmp} + string(v-cntxt-host-code-obj).
    end.
    
  run get-values in this-procedure.
  RUN enable_UI.
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
    DISPLAY cb-type d_date i_shift i_op-id EDITOR-objects RADIO-SET_objects 
        WITH FRAME Dialog-Frame.
    ENABLE RECT-1 RECT-2 Btn_OK Btn_save cb-type d_date i_shift i_op-id 
        RADIO-SET_objects bt-sel-obj 
        WITH FRAME Dialog-Frame.
    VIEW FRAME Dialog-Frame.
    {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-host-name Dialog-Frame 
PROCEDURE get-host-name :
/*------------------------------------------------------------------------------
  Purpose: Определение названия организации
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do on error undo, return error:

define output parameter p-host-name as character no-undo.

define buffer buf_clients for ub.clients.

    find first buf_clients no-lock where buf_clients.obj-type = {&cmp}
                                     and buf_clients.obj-code = v-cntxt-host-code-obj no-error.
    
    if not available buf_clients then do:
        message vss-workfile vss-revision vss-description skip
          "Не удалось найти текущую фирму" skip
          return-value skip
          trim(error-status :get-message(1))
          trim(error-status :get-message(2))
          trim(error-status :get-message(3))
          trim(error-status :get-message(4))
          trim(error-status :get-message(5))
        view-as alert-box error.
        undo, return error.
    end.
    
    else do:
        p-host-name = buf_clients.obj-name.
    end.
end.
END PROCEDURE. /* get-host-name */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-values Dialog-Frame 
PROCEDURE get-values :
/*------------------------------------------------------------------------------
      Purpose: Получим значения атрибута, если он был заведен.
      Parameters:  <none>
      Notes:
------------------------------------------------------------------------------*/
define variable c_value as character no-undo.
define variable c_type as character no-undo.


    case cb-type:
      when "mal" then do:

        run clntattr-value in this-procedure (input v-cntxt-obj-type,
                                      input v-cntxt-obj-code,
                                      input {&attr-bge-exp-malina-last-shift},
                                      output c_value,
                                      output c_type) no-error.
        if num-entries(c_value,",") = 3 then do:
          assign
            RADIO-SET_objects:screen-value in frame dialog-frame = "2"
            EDITOR-objects :screen-value in frame Dialog-frame = v-cntxt-obj-type + string( v-cntxt-obj-code )
          .
          assign
            EDITOR-objects
            RADIO-SET_objects
            d_date = date(entry(1,c_value,","))
            i_shift = integer(entry(2,c_value,",")) 
            i_op-id = integer(entry(3,c_value,","))
          no-error.
          display d_date i_shift i_op-id with frame {&frame-name}.

          create userobjs_temp-user-obj.
          assign
            userobjs_temp-user-obj.obj-code = v-cntxt-obj-code
            userobjs_temp-user-obj.obj-type = v-cntxt-obj-type
          .
        end. /* if num-entries(c_value,",") */

      end. /* end_of mal'ина */
      when 'atd' then do:

        run clntattr-value in this-procedure (input v-cntxt-obj-type,
                                      input v-cntxt-obj-code,
                                      input {&attr-bge-exp-last-atd},
                                      output c_value,
                                      output c_type) no-error.
        if num-entries(c_value,",") = 2 then do:
          assign
            RADIO-SET_objects:screen-value in frame dialog-frame = "2"
            EDITOR-objects :screen-value in frame Dialog-frame = v-cntxt-obj-type + string( v-cntxt-obj-code )
          .
          assign
            EDITOR-objects
            RADIO-SET_objects
            d_date = date(entry(1,c_value,","))
            i_shift = integer(entry(2,c_value,",")) 
            i_op-id = ?
          no-error.
          display d_date i_shift i_op-id with frame {&frame-name}.

          create userobjs_temp-user-obj.
          assign
            userobjs_temp-user-obj.obj-code = v-cntxt-obj-code
            userobjs_temp-user-obj.obj-type = v-cntxt-obj-type
          .
        end. /* if num-entries(c_value,",") */

      end. /* end_of atd - анализ треков данных */
      otherwise .
    end case.


END PROCEDURE. /* get-values */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

