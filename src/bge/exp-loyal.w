&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
{adecomm/appserv.i}

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

/* ***************************  Definitions  ************************** */

          /* VSS */
                               

define variable vss-revision    as character no-undo init "$Revision: ":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date: $":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Выгрузка товарного классификатора. Лояльность".
/* Includes */

{cmp/vssrevis.i}
{cmp/trg-def.i}
{cmp/showinf.i}
{gbl/getcntxt.i def}
{gbl/userobjs.i}
{gbl/cur-time.i}
{ ref/shd-attr.i }

/* Parameters Definitions ---                                           */
DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO .
DEFINE INPUT PARAMETER p-curr-host-code LIKE ub.sysconf.host-code NO-UNDO .
DEFINE INPUT PARAMETER p-curr-obj-type  LIKE ub.clients.obj-type NO-UNDO .
DEFINE INPUT PARAMETER p-curr-obj-code  LIKE ub.clients.obj-code NO-UNDO .
DEFINE INPUT PARAMETER p-mode           AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-db-num-char    AS CHARACTER    NO-UNDO.
DEFINE INPUT PARAMETER p-task-type      AS CHARACTER    NO-UNDO.
DEFINE INPUT PARAMETER p-task-num       AS INTEGER      NO-UNDO.
DEFINE INPUT PARAMETER p-action         AS CHARACTER    NO-UNDO.
DEFINE OUTPUT PARAMETER p-cancel        AS LOGICAL      NO-UNDO.
DEFINE OUTPUT PARAMETER p-params        AS CHARACTER    NO-UNDO.
/* Local Variable Definitions ---                                       */

define variable par-type as character no-undo.
define variable  lty as character no-undo.
define variable c-dir as character no-undo. /* Директория для сохранения файла */
define variable v-host-name as character no-undo.
define variable v-obj-list as character no-undo.
define variable v-param-list as character no-undo.
define variable v-param-type as character no-undo.
define variable ii as integer no-undo.
define variable v-entry as character no-undo.
define stream StreamLog.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS RECT-3 RECT-4 RECT-5 RECT-6 RECT-7 RECT-8 ~
btn_start btn_save Btn_close code_pool v-long-code cb-spl-ptrl  type-exp ~
per-izm v-place v-ftp-address v-login v-password v-directory 
&Scoped-Define DISPLAYED-OBJECTS code_pool v-long-code cb-spl-ptrl  type-exp ~
per-izm v-place v-ftp-address v-login v-password v-directory 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON Btn_close AUTO-END-KEY 
     LABEL "Отменить" 
     SIZE 15 BY 1.13
     BGCOLOR 8 .

DEFINE BUTTON btn_save 
     LABEL "Сохранить" 
     SIZE 15 BY 1.13
     BGCOLOR 8 .

DEFINE BUTTON btn_start 
     LABEL "Запустить" 
     SIZE 15 BY 1.13
     BGCOLOR 8 .

DEFINE VARIABLE cb-spl-ptrl AS CHARACTER FORMAT "X(256)":U 
     LABEL "Код системы-отправителя" 
     VIEW-AS COMBO-BOX INNER-LINES 5
     DROP-DOWN-LIST
     SIZE 27.5 BY 1 NO-UNDO.

DEFINE VARIABLE code_pool AS CHARACTER FORMAT "X(256)":U 
     LABEL "Код пула кодировок" 
     VIEW-AS FILL-IN 
     SIZE 30.5 BY 1 NO-UNDO.

DEFINE VARIABLE per-izm AS CHARACTER FORMAT "X(256)":U 
     LABEL "Период изменения" 
     VIEW-AS FILL-IN 
     SIZE 30.5 BY 1 NO-UNDO.

DEFINE VARIABLE v-directory AS CHARACTER FORMAT "X(256)":U 
     LABEL "Путь к локальной директории" 
     VIEW-AS FILL-IN 
     SIZE 30.5 BY 1
     FONT 4 NO-UNDO.

DEFINE VARIABLE v-ftp-address AS CHARACTER FORMAT "X(256)":U 
     LABEL "FTP" 
     VIEW-AS FILL-IN 
     SIZE 30.5 BY 1 NO-UNDO.

DEFINE VARIABLE v-login AS CHARACTER FORMAT "X(256)":U 
     LABEL "Логин" 
     VIEW-AS FILL-IN 
     SIZE 30.5 BY 1 NO-UNDO.

DEFINE VARIABLE v-long-code AS INTEGER FORMAT "->,>>>,>>9" INITIAL 8 
     LABEL "Длина кода товара" 
     VIEW-AS FILL-IN 
     SIZE 30.5 BY 1 NO-UNDO.

DEFINE VARIABLE v-password AS CHARACTER FORMAT "X(256)":U 
     LABEL "Пароль" 
     VIEW-AS FILL-IN 
     SIZE 30.5 BY 1 NO-UNDO.

DEFINE VARIABLE type-exp AS INTEGER 
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS 
          "Полная", 1,
"Инкремент", 2
     SIZE 14 BY 2 NO-UNDO.

DEFINE VARIABLE v-place AS INTEGER 
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS 
          "Локальная директория", 1,
"FTP адрес", 2
     SIZE 24 BY 3 NO-UNDO.

DEFINE RECTANGLE RECT-3
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 74.5 BY 8.5.

DEFINE RECTANGLE RECT-4
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 74.5 BY 4.5.

DEFINE RECTANGLE RECT-5
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 27 BY 4.75.

DEFINE RECTANGLE RECT-6
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 16.5 BY 4.

DEFINE RECTANGLE RECT-7
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 74.5 BY 2.

DEFINE RECTANGLE RECT-8
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 74.5 BY 2.75.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     btn_start AT ROW 2 COL 3.5
     btn_save AT ROW 2 COL 31
     Btn_close AT ROW 2 COL 61
     code_pool AT ROW 3.75 COL 29 COLON-ALIGNED WIDGET-ID 2
     v-long-code AT ROW 5 COL 29 COLON-ALIGNED WIDGET-ID 22
     cb-spl-ptrl  AT ROW 7 COL 28.5 COLON-ALIGNED WIDGET-ID 24
     type-exp AT ROW 10.5 COL 6.5 NO-LABEL WIDGET-ID 16
     per-izm AT ROW 11 COL 42.5 COLON-ALIGNED WIDGET-ID 4
     v-place AT ROW 15.5 COL 6.5 NO-LABEL WIDGET-ID 8
     v-ftp-address AT ROW 15.5 COL 42.5 COLON-ALIGNED WIDGET-ID 14
     v-login AT ROW 16.75 COL 42.5 COLON-ALIGNED WIDGET-ID 16
     v-password AT ROW 18 COL 42.5 COLON-ALIGNED WIDGET-ID 18
     v-directory AT ROW 20.25 COL 42.5 COLON-ALIGNED WIDGET-ID 12
      "Путь выгрузки:" VIEW-AS TEXT
          SIZE 14 BY 1.25 AT ROW 14.25 COL 6.5 WIDGET-ID 20
    "Тип выгрузки:" VIEW-AS TEXT
          SIZE 13.5 BY 1 AT ROW 9.25 COL 6 WIDGET-ID 20
     RECT-3 AT ROW 13.5 COL 3 WIDGET-ID 30
     RECT-4 AT ROW 8.75 COL 3 WIDGET-ID 32
     RECT-5 AT ROW 14 COL 5 WIDGET-ID 34
     RECT-6 AT ROW 9 COL 5 WIDGET-ID 36
     RECT-7 AT ROW 6.5 COL 3 WIDGET-ID 38
     RECT-8 AT ROW 3.5 COL 3 WIDGET-ID 40
     SPACE(2.37) SKIP(17.07)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Выгрузка товарного классификатора. Лояльность"
         DEFAULT-BUTTON btn_start CANCEL-BUTTON Btn_close WIDGET-ID 100.


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
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Выгрузка товарного классификатора. Лояльность */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




&Scoped-define SELF-NAME btn-start
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btn-start gDialog
ON CHOOSE OF btn_start IN FRAME {&FRAME-NAME} /* Запустить */
DO:
    assign 
        v-long-code.
   
    if v-long-code < 8 then 
    do: 
        message substitute("Неправильно задан параметр, 'Длина кода товара' ") view-as alert-box error.
        leave.
    end.
    
  run proc-start.
        
    if v-place = 1 then 
    
        run bge\exp-loyal-p.p ( this-procedure:handle,
            v-directory,
            v-place ,
            "",
            "", 
             per-izm,     
            code_pool,
            type-exp,
            v-long-code,
            cb-spl-ptrl
       
            ) .
    if v-place = 2 then    run bge\exp-loyal-p.p ( this-procedure:handle,
            v-ftp-address,
            v-place,
            v-login,
            v-password,
              per-izm,     
            code_pool,
            type-exp,
            v-long-code,
            cb-spl-ptrl
           
            ) .
    apply "go".
    
    
    end.
    /* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    



&Scoped-define SELF-NAME btn_save
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btn_save Dialog-Frame
ON CHOOSE OF btn_save IN FRAME Dialog-Frame /* Сохранить */
DO:
    
    DEFINE VARIABLE l-dircrt AS LOGICAL. /* Для ответа на создание директории */
    
run check-param no-error.
    If error-status:error then return no-apply.
    ASSIGN 
        cb-spl-ptrl
         v-place
         v-ftp-address
        type-exp
        v-directory 
        per-izm
        code_pool
        v-long-code
        .
 
  if v-long-code < 8 then do: message substitute("Неправильно задан параметр, 'Длина кода товара' ") view-as alert-box error.
 leave.
 end.
 
   v-directory = right-trim(v-directory,'/\') + '\'.
   
       /* Проверим каталог */
    file-info:file-name = v-directory.
    
    if file-info:file-type = ? then do:
        message substitute("Директории &1 не существует.",v-directory) skip
        "Создать?" view-as alert-box warning buttons yes-no update l-dircrt.
        if l-dircrt then do:
            os-create-dir value(v-directory).
            if os-error <> 0 then do:
                message substitute("Невозможно создать директорию &1",v-directory) view-as alert-box error.
                leave.
            end. /* if os-error <> 0 */
        end. /* if dir_crt */
        else leave.
    end. /* if file-info:file-type = ? */
    
    else do:
        if not (file-info:file-type begins "D":U) then do:
            message substitute("&1 не является директорией.",v-directory) view-as alert-box error.
            leave.
        end. /*if not */
    end. /* else */
if v-place = 1 then   v-param-list =  v-directory + {&delim-par} + string(v-place) + {&delim-par} + v-login + {&delim-par} + v-password  + {&delim-par} + string(type-exp) + {&delim-par} + string(code_pool) + {&delim-par} + per-izm + {&delim-par} +  string(v-long-code) + {&delim-par} +  cb-spl-ptrl.
if v-place = 2 then do:
     v-ftp-address = trim(trim(replace(v-ftp-address,'ftp:',""),{&slash-char}),{&back-slash-char}).
      v-param-list = v-ftp-address + {&delim-par} + string(v-place) + {&delim-par} + v-login + {&delim-par} + v-password + {&delim-par} + string(type-exp) + {&delim-par} +  string(code_pool) + {&delim-par} + per-izm  + {&delim-par} +  string(v-long-code) + {&delim-par} +  cb-spl-ptrl.
                     end.
   

    run attach-attr-to-schedule-line in this-procedure ( INPUT v-param-list ).

    run schedule-attr-write in this-procedure (input p-db-num-char, 
                                               input p-task-type,
                                               input p-task-num,
                                               input {&attr-schedule-obj-list-h},
                                               input v-obj-list).
   
    

    message "Параметры сохранены!" view-as alert-box information.

    apply "go".
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

    
&Scoped-define SELF-NAME per-izm
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL per-izm Dialog-Frame
ON VALUE-CHANGED OF per-izm IN FRAME Dialog-Frame /* Период изменения */
DO:

    assign per-izm.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME cb-spl-ptrl
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL cb-spl-ptrl Dialog-Frame
ON VALUE-CHANGED OF cb-spl-ptrl IN FRAME Dialog-Frame /* Код системы-отправителя */
DO:
  assign cb-spl-ptrl.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME type-exp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL type-exp Dialog-Frame
ON VALUE-CHANGED OF type-exp IN FRAME Dialog-Frame
DO:

    assign type-exp.
 
  CASE type-exp:
      WHEN 2
      THEN DO:
        ENABLE
           per-izm
        WITH FRAME Dialog-Frame.
          DISPLAY
             per-izm
          WITH FRAME Dialog-Frame.
      END.
      OTHERWISE DO:
          DISABLE
             per-izm
          WITH FRAME Dialog-Frame.
      END.
  END CASE.

    
/*    if type-exp = 1 then do :                      */
/*    hide per-izm in frame  {&FRAME-NAME}.          */
/*    end.                                           */
/*    else do:                                       */
/*        display  per-izm with frame  {&FRAME-NAME}.*/
/*        end.                                       */

    
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    

&Scoped-define SELF-NAME v-place
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-place Dialog-Frame
ON VALUE-CHANGED OF v-place IN FRAME Dialog-Frame
DO:
  ASSIGN
   v-place
  .
  CASE v-place:
      WHEN 2
      THEN DO:
           DISABLE v-directory WITH FRAME Dialog-Frame.
        ENABLE
            v-ftp-address
            v-login
            v-password
        WITH FRAME Dialog-Frame.
          DISPLAY
             v-ftp-address
             v-login
             v-password
          WITH FRAME Dialog-Frame.
      END.
      OTHERWISE DO:
          DISABLE
              v-ftp-address
              v-login
              v-password
              
          WITH FRAME Dialog-Frame.
         enable v-directory WITH FRAME Dialog-Frame.
         display v-directory WITH FRAME Dialog-Frame.
      END.
  END CASE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame 


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

          { gbl/conf-rd.i
 "'spl-lty'"
 "''":U
 "''":U
 "''":U
 "''":U
 "''":U
 "''":U
 NO
 lty
 par-type
 NO-ERROR
 }


 if error-status:error or lty = "" then  return error .
cb-spl-ptrl:LIST-ITEMS = lty.

 
/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  RUN enable_UI.
  RUN my-enable.
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
  DISPLAY code_pool v-long-code cb-spl-ptrl  type-exp per-izm v-place 
          v-ftp-address v-login v-password v-directory 
      WITH FRAME Dialog-Frame.
  ENABLE RECT-3 RECT-4 RECT-5 RECT-6 RECT-7 RECT-8 btn_start btn_save Btn_close 
         code_pool v-long-code cb-spl-ptrl  type-exp per-izm v-place 
         v-ftp-address v-login v-password v-directory 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-enable Dialog-Frame 
PROCEDURE my-enable :
    
   
    v-directory:screen-value in frame {&FRAME-NAME} = session:temp-directory.
    /* v-ftp-address:screen-value in frame {&FRAME-NAME} = "ftp://".*/
    assign
        v-directory.
     
     
     
    case p-mode:
        when "run" then 
            do:

                hide btn_save in frame {&FRAME-NAME}.

            end. /* when "run" */
    
        when "shd" then 
            do:
        
                hide btn_start in frame {&FRAME-NAME}.
                /* Прочитаем атрибуты выгрузки */
                run schedule-attr-value in this-procedure (input p-db-num-char 
                    , input p-task-type
                    , input p-task-num 
                    , input {&attr-schedule-param-list-h}
                    ,output v-param-list
                    ,output v-param-type).
                    
                /* Если у нас уже были атрибуты - отобразим их */
                if v-param-list <> "" then 
                do:
                
                    v-place  = integer(entry(2,v-param-list,{&delim-par}) ) no-error.
                    
                    if  v-place = 1 then 
                    do:
          
          
                        assign
                            v-directory = entry(1,v-param-list,{&delim-par}) 
                  
                            v-login     = entry(3,v-param-list,{&delim-par}) 
                            v-password  = entry(4,v-param-list,{&delim-par})
                            type-exp    = integer(entry(5,v-param-list,{&delim-par}))
                            code_pool   = entry(6,v-param-list,{&delim-par})
                            per-izm     = entry(7,v-param-list,{&delim-par})
                           v-long-code = integer(entry(8,v-param-list,{&delim-par}))
                           cb-spl-ptrl = entry(9,v-param-list,{&delim-par})
   NO-ERROR.
          
                        display v-directory  
                            type-exp 
                            per-izm  
                            v-place
                            code_pool
                            cb-spl-ptrl 
                             v-long-code with frame {&FRAME-NAME}.
                        
                        disable v-ftp-address v-login v-password with frame {&FRAME-NAME}.
                        if type-exp = 2 then display per-izm  with frame {&FRAME-NAME}.
                        else disable per-izm  with frame {&FRAME-NAME}.
    
                    end.
                
                    if  v-place = 2 then 
                    do:
                        assign
                            v-ftp-address = ENTRY(1, v-param-list, {&delim-par})
                        
                            /*                    v-place  = integer(entry(2,v-param-list,{&delim-par}) )*/
                            v-login       = entry(3,v-param-list,{&delim-par}) 
                            v-password    = entry(4,v-param-list,{&delim-par})
                            type-exp      = integer(entry(5,v-param-list,{&delim-par}))
                            code_pool     = entry(6,v-param-list,{&delim-par})
                            per-izm       = entry(7,v-param-list,{&delim-par})
                        v-long-code = integer(entry(8,v-param-list,{&delim-par}))
                       cb-spl-ptrl = entry(9,v-param-list,{&delim-par}) 
                          no-error.
                        
                        DISPLAY
                            v-ftp-address
                            v-login
                            v-password
                            type-exp 
                            per-izm  
                            v-place
                            code_pool 
                            cb-spl-ptrl
                              v-long-code with frame {&FRAME-NAME}.
                        
                        disable v-directory with frame {&FRAME-NAME}.
                    
                        if type-exp = 2 then display per-izm  with frame {&FRAME-NAME}.
                        else disable per-izm  with frame {&FRAME-NAME}.
                    end.
                end.
            end. /* when "shd" */
    
        
    end case.
    
end procedure.
    /* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
     
     &ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE check-param dialog-frame
PROCEDURE check-param :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
  DEFINE VARIABLE l-dircrt AS LOGICAL NO-UNDO. /* Для ответа на создание директории */
  define variable h-par as widget-handle  no-undo.
  DEFINE variable loghandle AS HANDLE no-undo.

    ASSIGN frame {&frame-name}
        v-directory 
        type-exp
        per-izm 
        v-ftp-address
        v-login
        v-password.
        
       case v-place:
   WHEN 2
   then do:
      IF trim(v-ftp-address) = '':U
      THEN DO:
         message
         "Не задано FTP адрес"
         view-as alert-box error .
         return error.
      END.
   end.
   OTHERWISE do:
        v-directory = right-trim(v-directory,'/\') + '\'.
      ASSIGN
         v-ftp-address = "":U
         v-directory
         v-login
         v-password
      .
   end.
   END CASE.
   
   
    
    /* Проверим каталог */
    file-info:file-name = v-directory.
    
    if file-info:file-type = ? then do:
        message substitute("Директории &1 не существует.",v-directory) skip
        "Создать?" view-as alert-box warning buttons yes-no update l-dircrt.
        if l-dircrt then do:
            os-create-dir value(v-directory).
            if os-error <> 0 then do:
                message substitute("Невозможно создать директорию &1",v-directory) view-as alert-box error.
                leave.
            end. /* if os-error <> 0 */
        end. /* if dir_crt */
        else leave.
    end. /* if file-info:file-type = ? */
    end procedure.
    /* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
     
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE write-log-and-file gDialog
PROCEDURE write-log-and-file :
    /*------------------------------------------------------------------------------
      Purpose:
      Parameters:  <none>
      Notes:
    ------------------------------------------------------------------------------*/
    define input parameter p-tab-position as integer no-undo.
    define input parameter p-file-name as char no-undo.
    define input parameter p-log-level as integer no-undo.
    define input parameter p-log-string as char no-undo.

    output stream StreamLog to value(p-file-name) append.
    put stream StreamLog unformatted {&new-line}.

    put stream StreamLog unformatted cur-time-string-sec() " " p-log-string.

    output stream StreamLog close.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
     
 procedure proc-start.
      DEFINE VARIABLE l-dircrt AS LOGICAL NO-UNDO. /* Для ответа на создание директории */
  define variable h-par as widget-handle  no-undo.
  DEFINE variable loghandle AS HANDLE no-undo.
  DEFINE VARIABLE v-objects AS CHARACTER NO-UNDO.
    
    ASSIGN
             FRAME {&frame-name}
             v-ftp-address
             v-login
             v-password
             v-place
             v-directory
              per-izm
             code_pool
             type-exp
             .
      
      
    case v-place:
        WHEN 2
        then 
            do:
                IF trim(v-ftp-address) = '':U
                    THEN 
                DO:
                    message
                        "Не задано FTP адрес"
                        view-as alert-box error .
                    return error.
                END.
            end.
        OTHERWISE 
        do:
            
               
    v-directory = right-trim(v-directory,'/\') + '\'.
    
    /* Проверим каталог */
    file-info:file-name = v-directory.
            
            IF FILE-INFO:FILE-TYPE = ? THEN 
            DO:
                MESSAGE SUBSTITUTE("Директории &1 не существует.",v-directory) SKIP
                    "Создать?" VIEW-AS ALERT-BOX WARNING BUTTONS YES-NO UPDATE l-dircrt.
                IF l-dircrt THEN 
                DO:
                    OS-CREATE-DIR VALUE(v-directory).
                    IF OS-ERROR <> 0 THEN 
                    DO:
                        MESSAGE SUBSTITUTE("Невозможно создать директорию &1",v-directory) VIEW-AS ALERT-BOX ERROR.
                        LEAVE.
                    END. /* if os-error <> 0 */
                END. /* if dir_crt */
                ELSE LEAVE.
            END. /* if file-info:file-type = ? */
            ELSE 
            DO:
                IF NOT (FILE-INFO:FILE-TYPE BEGINS "D":U) THEN 
                DO:
                    MESSAGE SUBSTITUTE("&1 не является директорией.",v-directory) VIEW-AS ALERT-BOX ERROR.
                    LEAVE.
                END. /*if not */
            END. /* else */
       
       
            ASSIGN
                v-ftp-address = "":U
                .
        end.
    END CASE. 
     
    
    FILE-INFO:FILE-NAME = v-directory.
/*    run v-dir no-error.*/
end procedure .
     
     
     
     
       &ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE attach-attr-to-schedule-line dialog-frame
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

  /*данная конкретная задача может быть ТОЛЬКО ОДНА в одной БД - отследим*/
  /*заблокируем*/
  run gbl/lock-prc.p
    (input {&lock-prc-schd-free}
    ,input 'exp-loyal':U
    ,input 0
    ,input 0
    ,input '':U
    ,input ""
    ,input ""
    ,input (
    "Сохранение параметров выгрузки товарного классификатора в L7 "
    )
    ,input yes
    ,buffer lock-batchprocess
    ) no-error .

/*  FIND FIRST buf_schedule-attr NO-LOCK WHERE                                                                      */
/*    buf_schedule-attr.task-type   = p-task-type                                                                   */
/*    and buf_schedule-attr.cre-db-num = INTEGER(p-db-num-char)                                                     */
/*    and buf_schedule-attr.attr-code = ({&attr-schd-free-id} + {&delim-par} + 'exp-loyal') NO-ERROR.               */
/*  IF AVAILABLE  buf_schedule-attr                                                                                 */
/*    AND buf_schedule-attr.task-num <> p-task-num                                                                  */
/*    AND buf_schedule-attr.task-num <> - 1                                                                         */
/*    and p-task-num <> - 1                                                                                         */
/*    THEN                                                                                                          */
/*  DO:                                                                                                             */
/*    MESSAGE                                                                                                       */
/*      substitute("Уже есть расписание сохранения параметров выгрузки товарного классификатора в L7  для БД &1&2" +*/
/*      "номер расписания &3"                                                                                       */
/*      ,buf_schedule-attr.cre-db-num                                                                               */
/*      ,{&NEW-LINE}                                                                                                */
/*      ,buf_schedule-attr.task-num)                                                                                */
/*      VIEW-AS ALERT-BOX ERROR.                                                                                    */
/*    UNDO, RETURN ERROR.                                                                                           */
/*  END.                                                                                                            */
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
     
     