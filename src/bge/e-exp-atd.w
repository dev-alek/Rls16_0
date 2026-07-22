&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*------------------------------------------------------------------------

  File: 

  Description: 

  Author: 

  Created: 
------------------------------------------------------------------------*/
/*          This .W file was created with the Progress AppBuilder.       */
/*----------------------------------------------------------------------*/

/* VSS */

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Выгрузка в систему АТД".

/* Includes */

{cmp/vssrevis.i}
{cmp/trg-def.i}
{cmp/showinf.i}
{gbl/getcntxt.i def}
{gbl/userobjs.i}
{gbl/cur-time.i}
{ ref/shd-attr.i }
{ gbl/waitfram.i }

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */


DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO .
DEFINE INPUT PARAMETER p-curr-host-code LIKE ub.sysconf.host-code NO-UNDO .
DEFINE INPUT PARAMETER p-curr-obj-type  LIKE ub.clients.obj-type NO-UNDO .
DEFINE INPUT PARAMETER p-curr-obj-code  LIKE ub.clients.obj-code NO-UNDO .
define input parameter p_mode as character no-undo.
define input parameter p_cre-db-num as integer no-undo.  /* Для schedule-attr */
define input parameter p_task-type as character no-undo. /* Для schedule-attr */
define input parameter p_task-num as integer no-undo.    /* Для schedule-attr */
DEFINE INPUT PARAMETER p-action         AS CHARACTER    NO-UNDO.
DEFINE OUTPUT PARAMETER p-cancel        AS LOGICAL      NO-UNDO.
DEFINE OUTPUT PARAMETER p-params        AS CHARACTER    NO-UNDO.

/* Buffers */

define buffer buf_clients   for ub.clients.
define buffer buf_shift-obj for ub.shift-obj.

/* Local Variable Definitions ---                                       */


define variable d_sht-start    as date      no-undo.
define variable i_sht-start    as integer   no-undo.
define variable d_sht-end      as date      no-undo.
define variable i_sht-end      as integer   no-undo.
define variable p-region       as character no-undo.


      
define variable c-dir          as character no-undo. /* Директория для сохранения файла */
define variable dir_crt        as logical. /* Для ответа на создание директории */
define variable v-host-name    as character no-undo.
define variable v-obj-list     as character no-undo.
define variable v-param-type   as character no-undo.
define variable v-param-list   as character no-undo.
define variable ii             as integer   no-undo.
define variable v-entry        as character no-undo.
define variable c_sel_esys     as character no-undo.
define variable l_ok           as logical   no-undo.
define variable c_shift-list   as character no-undo.
define variable par-type       as character no-undo.
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
&Scoped-Define ENABLED-OBJECTS RECT-2 RECT-5 Btn_Save Btn_Start Btn_Cancel ~
FILL-IN-sht-from-d FILL-IN-sht-from-n Btn_sht-from FILL-IN-sht-to-d ~
FILL-IN-sht-to-n Btn_sht-to EDITOR-obj RADIO-SET-Objects Btn_Obj ~
FILL-IN-Dir b-dir
&Scoped-Define DISPLAYED-OBJECTS FILL-IN-sht-from-d FILL-IN-sht-from-n ~
FILL-IN-sht-to-d FILL-IN-sht-to-n EDITOR-obj RADIO-SET-Objects FILL-IN-Dir 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON Btn_Cancel AUTO-END-KEY 
     LABEL "Отмена" 
     SIZE 15 BY 1.14
     BGCOLOR 8 .

DEFINE BUTTON Btn_Obj 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "" 
     SIZE 3 BY .86.

DEFINE BUTTON Btn_Save 
     LABEL "Сохранить" 
     SIZE 15 BY 1.14
     BGCOLOR 8 .

DEFINE BUTTON Btn_sht-from 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "" 
     SIZE 3 BY .86.

DEFINE BUTTON Btn_sht-to 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "" 
     SIZE 3 BY .86.

DEFINE BUTTON Btn_Start 
     LABEL "Запустить" 
     SIZE 15 BY 1.14.

DEFINE VARIABLE EDITOR-obj AS CHARACTER 
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 36 BY 3.76 NO-UNDO.

DEFINE VARIABLE FILL-IN-Dir AS CHARACTER FORMAT "X(256)":U 
     LABEL "Директория" 
     VIEW-AS FILL-IN 
     SIZE 40.4 BY 1 NO-UNDO.
     
DEFINE BUTTON b-dir 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "" 
     SIZE 3 BY .86.     

DEFINE VARIABLE FILL-IN-sht-from-d AS DATE FORMAT "99/99/99":U 
     LABEL "Смены с" 
     VIEW-AS FILL-IN 
     SIZE 10 BY 1 NO-UNDO.

DEFINE VARIABLE FILL-IN-sht-from-n AS INTEGER FORMAT "->9":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 3 BY 1 NO-UNDO.

DEFINE VARIABLE FILL-IN-sht-to-d AS DATE FORMAT "99/99/99":U 
     LABEL "По" 
     VIEW-AS FILL-IN 
     SIZE 10 BY 1 NO-UNDO.

DEFINE VARIABLE FILL-IN-sht-to-n AS INTEGER FORMAT "->9":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 3 BY 1 NO-UNDO.

DEFINE VARIABLE RADIO-SET-Objects AS INTEGER 
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS 
          "По фирме", 1,
"По объектам", 2
     SIZE 14.6 BY 2.62 NO-UNDO.

DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 59.4 BY 4.24.

DEFINE RECTANGLE RECT-5
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 59.4 BY 2.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     Btn_Save AT ROW 1.52 COL 2
     Btn_Start AT ROW 1.52 COL 2 WIDGET-ID 2
     Btn_Cancel AT ROW 1.52 COL 46.2
     FILL-IN-sht-from-d AT ROW 3 COL 10.4 COLON-ALIGNED WIDGET-ID 30
     FILL-IN-sht-from-n AT ROW 3 COL 21.8 COLON-ALIGNED NO-LABEL WIDGET-ID 38
     Btn_sht-from AT ROW 3 COL 28.4 WIDGET-ID 34
     FILL-IN-sht-to-d AT ROW 3 COL 38.8 COLON-ALIGNED WIDGET-ID 32
     FILL-IN-sht-to-n AT ROW 3 COL 50.4 COLON-ALIGNED NO-LABEL WIDGET-ID 42
     Btn_sht-to AT ROW 3 COL 56.8 WIDGET-ID 36
     EDITOR-obj AT ROW 5 COL 25 NO-LABEL WIDGET-ID 8
     RADIO-SET-Objects AT ROW 5.24 COL 4.6 NO-LABEL WIDGET-ID 4
     Btn_Obj AT ROW 6.76 COL 19 WIDGET-ID 24
     FILL-IN-Dir AT ROW 9.86 COL 14.6 COLON-ALIGNED WIDGET-ID 16
     b-dir AT ROW 9.86 COL 58 WIDGET-ID 22
     RECT-2 AT ROW 4.76 COL 2.6 WIDGET-ID 50
     RECT-5 AT ROW 9.38 COL 2.6 WIDGET-ID 56
     SPACE(0.59) SKIP(0.28)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Выгрузка в систему анализов треков данных"
         DEFAULT-BUTTON Btn_Save CANCEL-BUTTON Btn_Cancel WIDGET-ID 100.


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

ASSIGN 
       EDITOR-obj:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Выгрузка СТ в SAP (Сургутнефтегаз) */
DO:
    APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME b-dir
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-dir gDialog
ON CHOOSE OF b-dir IN FRAME Dialog-Frame
DO:
  /* Выбор директории */
  system-dialog get-dir c-dir.
  FILL-IN-Dir:screen-value in frame Dialog-Frame = c-dir.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME Btn_Obj
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_Obj Dialog-Frame
ON CHOOSE OF Btn_Obj IN FRAME Dialog-Frame
DO:
    define variable v-exclude-obj-list as character no-undo.
    define variable v-user-select      as logical   no-undo.
    define variable v-object-available as logical   no-undo.



    RADIO-SET-Objects:screen-value = "2".

    {gbl/uobjclr.i}

    {gbl/usobjava.i
     v-cntxt-db-num
     {&action-head-code-main}
     v-cntxt-userid
     v-cntxt-obj-type
     v-cntxt-obj-code
     v-object-available
     no-error}
 
    if error-status :error then 
    do:
        message vss-workfile vss-revision vss-description skip
            "Ошибка при вызове процедуры gbl/usobjava.i" skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error.
        undo, return no-apply.
    end. /* if error-status */

    if v-object-available = true then 
    do:
        {gbl/uobjapnd.i
     v-cntxt-obj-type
     v-cntxt-obj-code}
    end.

    {gbl/uobjsman.i
     parparentproc
     v-cntxt-db-num
     v-cntxt-userid
     v-cntxt-host-code-obj
     v-cntxt-obj-type
     v-cntxt-obj-code
     v-user-select}
 
    if v-user-select <> true then 
    do:
        message "Объект не выбран" view-as alert-box information.
        return no-apply.
    end.
    
    v-obj-list = "".
    EDITOR-obj:screen-value = "".

    for each userobjs_temp-user-obj:
        v-obj-list = v-obj-list + userobjs_temp-user-obj.obj-type + {&comma-char} +
            string(userobjs_temp-user-obj.obj-code) + {&delim-par}.
        find first buf_clients where buf_clients.obj-code = userobjs_temp-user-obj.obj-code
            and buf_clients.obj-type = userobjs_temp-user-obj.obj-type no-lock no-error.
        EDITOR-obj:screen-value = EDITOR-obj:screen-value + 
            (if buf_clients.obj-name <> '' then buf_clients.obj-name
            else userobjs_temp-user-obj.obj-type + string(userobjs_temp-user-obj.obj-code))
            + "," + chr(13).
    end. /* for each userobjs_temp-user-obj */

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_Save
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_Save Dialog-Frame
ON CHOOSE OF Btn_Save IN FRAME Dialog-Frame /* Сохранить */
DO:
    assign 
        FILL-IN-Dir
        RADIO-SET-Objects
        FILL-IN-sht-from-d
        FILL-IN-sht-from-n
        FILL-IN-sht-to-d
        FILL-IN-sht-to-n
        .
        
    if FILL-IN-sht-from-d > FILL-IN-sht-to-d
    or (FILL-IN-sht-from-d = FILL-IN-sht-to-d and FILL-IN-sht-from-n > FILL-IN-sht-to-n)
    then do :
        message "Смены выбраны не верно!" view-as alert-box.
        return no-apply .
    end.
 

    FILL-IN-Dir = right-trim(FILL-IN-Dir,'/\') + '\'.  

    /* Проверим каталог */
    file-info:file-name = FILL-IN-Dir.

    if file-info:file-type = ? then 
    do:
        message substitute("Директории &1 не существует.",FILL-IN-Dir) skip
            "Создать?" view-as alert-box warning buttons yes-no update dir_crt.
        if dir_crt then 
        do:
            os-create-dir value(FILL-IN-Dir).
            if os-error <> 0 then 
            do:
                message substitute("Невозможно создать директорию &1",FILL-IN-Dir) view-as alert-box error.
                leave.
            end. /* if os-error <> 0 */
        end. /* if dir_crt */
        else leave.
    end. /* if file-info:file-type = ? */
    else 
    do:
        if not (file-info:file-type begins "D":U) then 
        do:
            message substitute("&1 не является директорией.",FILL-IN-Dir) view-as alert-box error.
            leave.
        end. /*if not */
    end. /* else */

    v-param-list = FILL-IN-Dir  + {&delim-par}  + 
                   string(RADIO-SET-Objects)  + {&delim-par}  +
                   p-region .

    run attach-attr-to-schedule-line in this-procedure ( INPUT v-param-list ).

    run schedule-attr-write in this-procedure (input p_cre-db-num, 
        input p_task-type,
        input p_task-num,
        input {&attr-schedule-param-list-h},
        input v-param-list).

    run schedule-attr-write in this-procedure (input p_cre-db-num, 
        input p_task-type,
        input p_task-num,
        input {&attr-schedule-obj-list-h},
        input v-obj-list).
/*        apply "go".*/
        message "Параметры сохранены!" view-as alert-box information.

    apply "go".
    
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_sht-from
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_sht-from Dialog-Frame
ON CHOOSE OF Btn_sht-from IN FRAME Dialog-Frame
DO:
    run str/sht-all.w (parparentproc, 
        v-cntxt-obj-type,
        v-cntxt-obj-code,
        "b-sel",
        "obj",
        v-cntxt-obj-type,
        v-cntxt-obj-code,
        "",
        input-output c_shift-list) no-error.
    if error-status:error then 
    do:
        message
            vss-workfile vss-revision vss-description skip
            "Ошибка при выборе смены"  skip
            error-status :get-message( 1 ) skip
            return-value skip
            view-as alert-box error .
        return no-apply.
    end.
    if c_shift-list =  "":U then 
    do:
        return no-apply.
    end.
    find first buf_shift-obj where recid (buf_shift-obj) = integer (c_shift-list) no-lock.
    FILL-IN-sht-from-d:screen-value = string(buf_shift-obj.shift-date) no-error.
    FILL-IN-sht-from-n:screen-value = string(buf_shift-obj.shift-num) no-error.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_sht-to
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_sht-to Dialog-Frame
ON CHOOSE OF Btn_sht-to IN FRAME Dialog-Frame
DO:
    run str/sht-all.w (parparentproc, 
        v-cntxt-obj-type,
        v-cntxt-obj-code,
        "b-sel",
        "obj",
        v-cntxt-obj-type,
        v-cntxt-obj-code,
        "",
        input-output c_shift-list) no-error.
    if error-status:error then 
    do:
        message
            vss-workfile vss-revision vss-description skip
            "Ошибка при выборе смены"  skip
            error-status :get-message( 1 ) skip
            return-value skip
            view-as alert-box error .
        return no-apply.
    end.
    if c_shift-list =  "":U then 
    do:
        return no-apply.
    end.
    find first buf_shift-obj where recid (buf_shift-obj) = integer (c_shift-list) no-lock.
    FILL-IN-sht-to-d:screen-value = string(buf_shift-obj.shift-date) no-error.
    FILL-IN-sht-to-n:screen-value = string(buf_shift-obj.shift-num) no-error.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_Start
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_Start Dialog-Frame
ON CHOOSE OF Btn_Start IN FRAME Dialog-Frame /* Запустить */
DO: 
    
    assign 
        FILL-IN-Dir
        RADIO-SET-Objects
        FILL-IN-sht-from-d
        FILL-IN-sht-from-n
        FILL-IN-sht-to-d
        FILL-IN-sht-to-n
    .

    if FILL-IN-sht-from-d > FILL-IN-sht-to-d
    or (FILL-IN-sht-from-d = FILL-IN-sht-to-d and FILL-IN-sht-from-n > FILL-IN-sht-to-n)
    then do :
        message "Смены выбраны не верно!" view-as alert-box.
        return no-apply .
    end.

    FILL-IN-Dir = right-trim(FILL-IN-Dir,'/\') + '\'. 

    /* Проверим каталог */
    file-info:file-name = FILL-IN-Dir.

    if file-info:file-type = ? then 
    do:
        message substitute("Директории &1 не существует.",FILL-IN-Dir) skip
            "Создать?" view-as alert-box warning buttons yes-no update dir_crt.
        if dir_crt then 
        do:
            os-create-dir value(FILL-IN-Dir).
            if os-error <> 0 then 
            do:
                message substitute("Невозможно создать директорию &1",FILL-IN-Dir) view-as alert-box error.
                leave.
            end. /* if os-error <> 0 */
        end. /* if dir_crt */
        else leave.
    end. /* if file-info:file-type = ? */

    else 
    do:
        if not (file-info:file-type begins "D":U) then 
        do:
            message substitute("&1 не является директорией.",FILL-IN-Dir) view-as alert-box error.
            leave.
        end. /*if not */
    end. /* else */

    /* Составим список объектов для выгрузки, если "По фирме" */
    if RADIO-SET-Objects = 1 then
    do:

        for each buf_clients no-lock where buf_clients.host-code = v-cntxt-host-code-obj:
            /* Пропустим удаленные */
            if buf_clients.stts <> 0 then next.
            find first userobjs_temp-user-obj where  userobjs_temp-user-obj.obj-code = buf_clients.obj-code and   userobjs_temp-user-obj.obj-type = buf_clients.obj-type no-lock no-error.
            if not available userobjs_temp-user-obj
            then do: 
                create userobjs_temp-user-obj.
                assign
                    userobjs_temp-user-obj.obj-code = buf_clients.obj-code
                    userobjs_temp-user-obj.obj-type = buf_clients.obj-type.

            end. 
        end. /* for each buf_clients */
    end. /* if RADIO-SET-Objects = 1 */
    /* Теперь запустим процедуру экспорта */

    assign
        d_sht-start = date(FILL-IN-sht-from-d)
        i_sht-start = integer(FILL-IN-sht-from-n)
        d_sht-end   = date(FILL-IN-sht-to-d)
        i_sht-end   = integer(FILL-IN-sht-to-n)
    .
    
    run waitfram-show in this-procedure ( input "Идет выгрузка в систему анализа треков данных. Ждите..." ).

    run bge/bge-exp-ATD.p (input table userobjs_temp-user-obj,
        input FILL-IN-Dir,
        input this-procedure:handle,
        input d_sht-start,
        input i_sht-start,
        input d_sht-end,
        input i_sht-end,
        input p-region,
        input "run"
        ) no-error.
    if error-status:error then
    do:
        message return-value + error-status:get-message(1).
    end.
    
    run waitfram-hide in this-procedure .
    
    message "Выгрузка завершена" view-as alert-box .
    apply "go".
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME RADIO-SET-Objects
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL RADIO-SET-Objects Dialog-Frame
ON VALUE-CHANGED OF RADIO-SET-Objects IN FRAME Dialog-Frame
DO:
        
         
        for each userobjs_temp-user-obj: 
            delete userobjs_temp-user-obj.
        end.
    
        
        case RADIO-SET-Objects :screen-value in frame Dialog-frame:

            when "1" then 
                do:
            
                    EDITOR-obj:screen-value = v-host-name.
                    hide Btn_Obj in frame Dialog-Frame.
            
                    for each userobjs_temp-user-obj:
                        delete userobjs_temp-user-obj.
                    end.
            
                    v-obj-list = {&cmp} + {&comma-char} + string(v-cntxt-host-code-obj).
            
                end. /* when "1" then */
        
            when "2" then 
                do:
            
                    display Btn_Obj with frame Dialog-Frame.
            
                    create userobjs_temp-user-obj.
                    assign 
                        userobjs_temp-user-obj.obj-code = v-cntxt-obj-code
                        userobjs_temp-user-obj.obj-type = v-cntxt-obj-type.
            
                    v-obj-list = userobjs_temp-user-obj.obj-type + {&comma-char} + string(userobjs_temp-user-obj.obj-code) + {&delim-par}.
            
                    find first buf_clients where buf_clients.obj-type = userobjs_temp-user-obj.obj-type
                        and buf_clients.obj-code = userobjs_temp-user-obj.obj-code no-lock no-error.
            
                    EDITOR-obj:screen-value in frame Dialog-frame = if buf_clients.obj-name <> '' then buf_clients.obj-name
                    else userobjs_temp-user-obj.obj-type + string(userobjs_temp-user-obj.obj-code).
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


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
    ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  
    {gbl/getcntxt.i get}
  
  { gbl/conf-rd.i
     "'atd-reg'"
     "''":U
     "''":U
     "''":U
     "''":U
     "''":U
     "''":U
     Yes
     p-region
     par-type
     NO-ERROR
     }
    if error-status:error or trim(p-region) = "" then  return error .

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
  DISPLAY FILL-IN-sht-from-d FILL-IN-sht-from-n FILL-IN-sht-to-d 
          FILL-IN-sht-to-n EDITOR-obj RADIO-SET-Objects FILL-IN-Dir 
      WITH FRAME Dialog-Frame.
  ENABLE RECT-2 RECT-5 Btn_Save Btn_Start Btn_Cancel FILL-IN-sht-from-d 
         FILL-IN-sht-from-n Btn_sht-from FILL-IN-sht-to-d FILL-IN-sht-to-n 
         Btn_sht-to EDITOR-obj RADIO-SET-Objects Btn_Obj FILL-IN-Dir  b-dir
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-enable Dialog-Frame 
PROCEDURE my-enable :
/*------------------------------------------------------------------------------
                                        Purpose: Изменение заголовка и кнопок в зависимости от параметров запуска
                                        Notes:
                        ------------------------------------------------------------------------------*/

    /* Определим, это ручная выгрузка или задание параметров для произвольного задания */

define variable i as integer init 0 no-undo.
define variable ii as integer  init 0 no-undo.
    define variable v-name-nom as char      no-undo.
    define variable v-name-pit as char      no-undo.

    case p_mode:
        when "run" then 
            do:

                hide Btn_Save in frame Dialog-Frame.
    
            end. /* when "run" */
    
        when "shd" then 
            do:
        
                hide Btn_Start FILL-IN-sht-from-d FILL-IN-sht-from-n FILL-IN-sht-to-d 
                    FILL-IN-sht-to-n Btn_sht-from Btn_sht-to in frame Dialog-Frame.
                /* Прочитаем атрибуты выгрузки */
        
                run schedule-attr-value in this-procedure (input p_cre-db-num,
                    input p_task-type,
                    input p_task-num,
                    input {&attr-schedule-param-list-h},
                    output v-param-list,
                    output v-param-type).


                /* Если у нас уже были атрибуты - отобразим их */
                if v-param-list <> "" then 
                do: 
                    FILL-IN-Dir = entry(1,v-param-list,{&delim-par}) .
                    RADIO-SET-Objects = integer(entry(2,v-param-list,{&delim-par}) ).
                    p-region    = entry(3,v-param-list,{&delim-par}) .

                    
                    display FILL-IN-Dir 
                        RADIO-SET-Objects
                         with frame Dialog-Frame .
              
                end. /* if v-param-list <> '' */
        
                run schedule-attr-value in this-procedure (input p_cre-db-num,
                    input p_task-type,
                    input p_task-num,
                    input {&attr-schedule-obj-list-h},
                    output v-obj-list,
                    output v-param-type).
        
                /* Если уже есть список объектов */
                if v-obj-list <> "" then 
                do:
                    for each userobjs_temp-user-obj:
                        delete userobjs_temp-user-obj.
                    end.
                    /* Если по фирме */
                    if v-obj-list begins {&cmp} then 
                    do:
    
                        find first buf_clients where buf_clients.obj-type = entry(1, v-obj-list, {&comma-char})
                            and buf_clients.obj-code = integer(entry(2, v-obj-list, {&comma-char})) no-lock no-error.
                
                        if available(buf_clients) then
                            EDITOR-obj:screen-value = if buf_clients.obj-name <> '' then buf_clients.obj-name
                            else buf_clients.obj-type + string(buf_clients.obj-code).
                
                        RADIO-SET-Objects = 1.
                        display RADIO-SET-Objects with frame Dialog-Frame.
                
                    end. /* if v-obj-list begins {&cmp} */
            
                    /* Если список объектов */
                    else 
                    do:
                        EDITOR-obj:screen-value = "".
                        do ii = 1 to num-entries(v-obj-list, {&delim-par}) on error undo, next:
                            v-entry = entry(ii, v-obj-list, {&delim-par}).
                            /* Проверим, что они существуют */
                            find first buf_clients where buf_clients.obj-type = entry(1, v-entry, {&comma-char})
                                and buf_clients.obj-code = integer(entry(2, v-entry, {&comma-char})) no-lock no-error.
                      
                            if available buf_clients then 
                            do:
                                EDITOR-obj:screen-value = EDITOR-obj:screen-value + 
                                    (if buf_clients.obj-name <> '' then buf_clients.obj-name
                                    else buf_clients.obj-type + string(buf_clients.obj-code))
                                    + "," + chr(13).
                            end. /* if available buf_clients */
                     
                        end. /* do ii = 1 to num-entries(v-obj-list) */
            
                        RADIO-SET-Objects = 2.
                        display RADIO-SET-Objects with frame Dialog-Frame.
                
                    end. /* if v-obj-list begins {&shop} */
                end. /* if v-obj-list <> "" */
            end. /* when "shd" */
    
    end case.

end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE write-log-and-file Dialog-Frame 
PROCEDURE write-log-and-file :
/*------------------------------------------------------------------------------
                  Purpose: Запись лога в файл
                  Parameters:
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
end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

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

    /*данная конкретная задача может быть ТОЛЬКО ОДНА в одной БД - отследим*/
    /*заблокируем*/
    run gbl/lock-prc.p
        (input {&lock-prc-schd-free}
        ,input 'exp-atd':U
        ,input 0
        ,input 0
        ,input '':U
        ,input ""
        ,input ""
        ,input (
        "Сохранение параметров выгрузки в систему АТД "
        )
        ,input yes
        ,buffer lock-batchprocess
        ) no-error .


    find first buf_schedule no-lock
        where buf_schedule.task-type   = p_task-type
        and buf_schedule.cre-db-num  = INTEGER(p_cre-db-num)
        and buf_schedule.task-num    = p_task-num
        no-error.
    if not available buf_schedule
        and (  p_task-type   <> {&btpr-type-autofree}
        or p_cre-db-num <> p_cre-db-num
        or p_task-num    <> -1 )
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
    /*message p-task-type "task" p-task-num "db" p-db-num-char view-as alert-box.*/
    run schedule-attr-write in this-procedure (
        input INTEGER(p_cre-db-num)
        , input p_task-type
        , input p_task-num
        , input {&attr-schedule-param-list-h}
        , input p-param-list
        ).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
