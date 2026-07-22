&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI ADM1
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME gDialog
{adecomm/appserv.i}
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS gDialog 
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Форма выгрузки информации в систему Малина

Автор: Кривошеин Александр Николаевич
Дата создания: 02/09/14
Author: Krivoshein Alexander
Creation date: 02/09/14

*/

/* ***************************  Definitions  ************************** */

/* VSS */

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date: $":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Выгрузка информации в систему Малина".

/* Includes */

{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ cmp/showinf.i }
{ gbl/getcntxt.i def }
{ gbl/userobjs.i }
{ gbl/cur-time.i }
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

define buffer buf_clients for ub.clients.

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

&Scoped-define PROCEDURE-TYPE SmartDialog
&Scoped-define DB-AWARE no

&Scoped-define ADM-CONTAINER DIALOG-BOX

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME gDialog

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS RECT-2 b-start b-save b-close v-company ~
v-goods v-chk v-category t-location v-category-2 v-diapmin v-diapmax ~
v-directory b-dir v-prefix rs-obj b-obj e-obj 
&Scoped-Define DISPLAYED-OBJECTS v-company v-goods v-chk v-category ~
t-location v-category-2 v-diapmin v-diapmax v-directory v-prefix rs-obj ~
e-obj 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-close AUTO-END-KEY 
     LABEL "Отменить" 
     SIZE 15 BY 1.13.

DEFINE BUTTON b-dir 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "" 
     SIZE 3 BY .88.

DEFINE BUTTON b-obj 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "" 
     SIZE 3 BY .88.

DEFINE BUTTON b-save 
     LABEL "Сохранить" 
     SIZE 15 BY 1.13.

DEFINE BUTTON b-start 
     LABEL "Запустить" 
     SIZE 15 BY 1.13.

DEFINE VARIABLE e-obj AS CHARACTER 
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 42.5 BY 4.71 NO-UNDO.

DEFINE VARIABLE v-category AS INTEGER FORMAT ">>>>9":U INITIAL 0 
     LABEL "Категория тов.класс-ра" 
     VIEW-AS FILL-IN 
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE v-category-2 AS CHARACTER FORMAT "X(256)":U 
     LABEL "Категория для локаций" 
     VIEW-AS FILL-IN 
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE v-company AS INTEGER FORMAT "999":U INITIAL 9 
     LABEL "Идентификатор компании" 
     VIEW-AS FILL-IN 
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE v-diapmax AS INTEGER FORMAT "999":U INITIAL 99 
     VIEW-AS FILL-IN 
     SIZE 5.5 BY 1 NO-UNDO.

DEFINE VARIABLE v-diapmin AS INTEGER FORMAT "999":U INITIAL 0 
     LABEL "Диапазон пакетов" 
     VIEW-AS FILL-IN 
     SIZE 5.5 BY 1 NO-UNDO.

DEFINE VARIABLE v-directory AS CHARACTER FORMAT "X(256)":U 
     LABEL "Директория" 
     VIEW-AS FILL-IN 
     SIZE 40 BY 1 NO-UNDO.

DEFINE VARIABLE v-prefix AS CHARACTER FORMAT "X(256)":U INITIAL "639300,275" 
     LABEL "Префикс для карт Малина" 
     VIEW-AS FILL-IN 
     SIZE 42.5 BY 1 NO-UNDO.

DEFINE VARIABLE rs-obj AS INTEGER 
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS 
          "По фирме", 1,
"По объектам", 2
     SIZE 17 BY 2.13 NO-UNDO.

DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 26.5 BY 3.75.

DEFINE VARIABLE t-location AS LOGICAL INITIAL yes 
     LABEL "Локации" 
     VIEW-AS TOGGLE-BOX
     SIZE 11.13 BY .83 NO-UNDO.

DEFINE VARIABLE v-chk AS LOGICAL INITIAL no 
     LABEL "Чеки" 
     VIEW-AS TOGGLE-BOX
     SIZE 11.13 BY .83 NO-UNDO.

DEFINE VARIABLE v-goods AS LOGICAL INITIAL yes 
     LABEL "Товарный классификатор" 
     VIEW-AS TOGGLE-BOX
     SIZE 25 BY .83 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME gDialog
     b-start AT ROW 1.25 COL 2 WIDGET-ID 8
     b-save AT ROW 1.25 COL 38
     b-close AT ROW 1.25 COL 54.5
     v-company AT ROW 3.25 COL 25 COLON-ALIGNED WIDGET-ID 10
     v-goods AT ROW 3.25 COL 44 WIDGET-ID 28
     v-chk AT ROW 4.42 COL 44 WIDGET-ID 30
     v-category AT ROW 4.5 COL 25 COLON-ALIGNED WIDGET-ID 38
     t-location AT ROW 5.5 COL 44 WIDGET-ID 46
     v-category-2 AT ROW 5.75 COL 25 COLON-ALIGNED WIDGET-ID 48
     v-diapmin AT ROW 7.25 COL 25 COLON-ALIGNED WIDGET-ID 40
     v-diapmax AT ROW 7.25 COL 33.5 COLON-ALIGNED NO-LABEL WIDGET-ID 42
     v-directory AT ROW 8.5 COL 25 COLON-ALIGNED WIDGET-ID 12
     b-dir AT ROW 8.5 COL 67 WIDGET-ID 22
     v-prefix AT ROW 9.75 COL 25 COLON-ALIGNED WIDGET-ID 6
     rs-obj AT ROW 12.5 COL 2 NO-LABEL WIDGET-ID 34
     b-obj AT ROW 12.5 COL 19.5 WIDGET-ID 24
     e-obj AT ROW 12.5 COL 27 NO-LABEL WIDGET-ID 32
     "-" VIEW-AS TEXT
          SIZE 1.5 BY .67 AT ROW 7.5 COL 33.25 WIDGET-ID 44
     RECT-2 AT ROW 3 COL 43 WIDGET-ID 14
     SPACE(0.87) SKIP(11.24)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Выгрузка информации в систему ~"Малина~""
         DEFAULT-BUTTON b-save CANCEL-BUTTON b-close WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: SmartDialog
   Allow: Basic,Browse,DB-Fields,Query,Smart
   Other Settings: APPSERVER
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _INCLUDED-LIB gDialog 
/* ************************* Included-Libraries *********************** */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX gDialog
   FRAME-NAME                                                           */
ASSIGN 
       FRAME gDialog:SCROLLABLE       = FALSE
       FRAME gDialog:HIDDEN           = TRUE.

ASSIGN 
       e-obj:READ-ONLY IN FRAME gDialog        = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX gDialog
/* Query rebuild information for DIALOG-BOX gDialog
     _Options          = "SHARE-LOCK"
     _Query            is NOT OPENED
*/  /* DIALOG-BOX gDialog */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME gDialog
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL gDialog gDialog
ON WINDOW-CLOSE OF FRAME gDialog /* Выгрузка информации в систему "Малина" */
DO:  
  /* Add Trigger to equate WINDOW-CLOSE to END-ERROR. */
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-dir
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-dir gDialog
ON CHOOSE OF b-dir IN FRAME gDialog
DO:
  /* Выбор директории */
  system-dialog get-dir c-dir.
  v-directory:screen-value in frame gDialog = c-dir.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-obj
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-obj gDialog
ON CHOOSE OF b-obj IN FRAME gDialog
DO:
    define variable v-exclude-obj-list as character no-undo.
    define variable v-user-select as logical no-undo.
    define variable v-object-available as logical no-undo.

    rs-obj:screen-value = "2".
    
   /* { gbl/uobjclr.i }  */
    
    { gbl/usobjava.i
     v-cntxt-db-num
     {&action-head-code-main}
     v-cntxt-userid
     v-cntxt-obj-type
     v-cntxt-obj-code
     v-object-available
     no-error }
     
    if error-status :error then do:
        message vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры gbl/usobjava.i" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error.
        undo, return no-apply.
    end. /* if error-status */

    if v-object-available = true then do:
        { gbl/uobjapnd.i
         v-cntxt-obj-type
         v-cntxt-obj-code }
    end.

    { gbl/uobjsman.i
     parparentproc
     v-cntxt-db-num
     v-cntxt-userid
     v-cntxt-host-code-obj
     v-cntxt-obj-type
     v-cntxt-obj-code
     v-user-select
      }
     
    if v-user-select <> true then do:
      message "Объект не выбран" view-as alert-box information.
      return no-apply.
    end.
        
    v-obj-list = "".
    e-obj:screen-value = "".
    
    for each userobjs_temp-user-obj:
        v-obj-list = v-obj-list + userobjs_temp-user-obj.obj-type + {&comma-char} +
            string(userobjs_temp-user-obj.obj-code) + {&delim-par}.
            find first buf_clients where buf_clients.obj-code = userobjs_temp-user-obj.obj-code
                and buf_clients.obj-type = userobjs_temp-user-obj.obj-type no-lock no-error.
            e-obj:screen-value = e-obj:screen-value + 
                (if buf_clients.obj-name <> '' then buf_clients.obj-name
                else userobjs_temp-user-obj.obj-type + string(userobjs_temp-user-obj.obj-code))
                + "," + chr(13).
    end. /* for each userobjs_temp-user-obj */

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-save
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-save gDialog
ON CHOOSE OF b-save IN FRAME gDialog /* Сохранить */
DO:

    DEFINE VARIABLE l-dircrt AS LOGICAL. /* Для ответа на создание директории */

    ASSIGN 
        v-company
        v-category
        v-category-2
        v-diapmin
        v-diapmax
        v-directory
        v-prefix
        v-goods
        v-chk
        rs-obj
        t-location.
    
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

    if v-diapmin >= v-diapmax then do:
        message "Неверно указаны границы диапазона пакетов" view-as alert-box error.
        leave.
    end. /*if v-diapmin >= v-diapmax*/


    v-param-list = string(v-company) + {&delim-par} + 
                   v-directory + {&delim-par} + 
                   v-prefix + {&delim-par} + 
                   string(v-goods:CHECKED) + {&delim-par} + 
                   string(v-chk)  + {&delim-par} + 
                   string(v-category) + {&delim-par} + 
                   string(v-diapmin) + {&delim-par} + 
                   string(v-diapmax) + {&delim-par} + 
                   string(t-location) + {&delim-par} + string(v-category-2) +
                   {&delim-par}.

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


&Scoped-define SELF-NAME b-start
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-start gDialog
ON CHOOSE OF b-start IN FRAME gDialog /* Запустить */
DO:

  DEFINE VARIABLE l-dircrt AS LOGICAL NO-UNDO. /* Для ответа на создание директории */
  define variable h-par as widget-handle  no-undo.
  DEFINE variable loghandle AS HANDLE no-undo.
  DEFINE VARIABLE v-objects AS CHARACTER NO-UNDO.

  ASSIGN 
    v-company
    v-directory
    v-prefix
    v-category
    v-category-2
    v-diapmin
    v-diapmax
    .
    
  v-directory = RIGHT-TRIM(v-directory,'/\') + '\'.
    
    /* Проверим каталог */
  FILE-INFO:FILE-NAME = v-directory.
    
  IF FILE-INFO:FILE-TYPE = ? THEN DO:
    MESSAGE SUBSTITUTE("Директории &1 не существует.",v-directory) SKIP
        "Создать?" VIEW-AS ALERT-BOX WARNING BUTTONS YES-NO UPDATE l-dircrt.
        IF l-dircrt THEN DO:
            OS-CREATE-DIR VALUE(v-directory).
            IF OS-ERROR <> 0 THEN DO:
                MESSAGE SUBSTITUTE("Невозможно создать директорию &1",v-directory) VIEW-AS ALERT-BOX ERROR.
                LEAVE.
            END. /* if os-error <> 0 */
        END. /* if dir_crt */
        ELSE LEAVE.
    END. /* if file-info:file-type = ? */
    ELSE DO:
        IF NOT (FILE-INFO:FILE-TYPE BEGINS "D":U) THEN DO:
            MESSAGE SUBSTITUTE("&1 не является директорией.",v-directory) VIEW-AS ALERT-BOX ERROR.
            LEAVE.
        END. /*if not */
    END. /* else */

    /* Составим список объектов для выгрузки, если "По фирме" */
    if rs-obj = 1 then do:
        
        for each buf_clients no-lock where buf_clients.host-code = v-cntxt-host-code-obj:
            
            /* Пропустим удаенные */
            if buf_clients.stts <> 0 then next.
            
            create userobjs_temp-user-obj.
            assign
                userobjs_temp-user-obj.obj-code = buf_clients.obj-code
                userobjs_temp-user-obj.obj-type = buf_clients.obj-type.
            
        end. /* for each buf_clients */
        
    end. /* if rs-obj = 1 */

    if v-diapmin >= v-diapmax then do:
        message "Неверно указаны границы диапазона пакетов" view-as alert-box error.
        leave.
    end. /*if v-diapmin >= v-diapmax*/

    run bge\exp-malinap.p ( table userobjs_temp-user-obj,
                            v-company,
                            v-directory,
                            v-prefix,
                            v-goods:CHECKED,
                            v-chk:CHECKED,
                            v-category,
                            v-diapmin,
                            v-diapmax,
                            this-procedure:handle,
                            t-location:CHECKED,
                            v-category-2
                       ) .

    apply "go".

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME rs-obj
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rs-obj gDialog
ON VALUE-CHANGED OF rs-obj IN FRAME gDialog
DO:
    case rs-obj :screen-value in frame gDialog:

        when "1" then do:
            
            e-obj:screen-value = v-host-name.
            hide b-obj in frame gDialog.
            
            for each userobjs_temp-user-obj:
                delete userobjs_temp-user-obj.
            end.
            
            v-obj-list = {&cmp} + {&comma-char} + string(v-cntxt-host-code-obj).
            
        end. /* when "1" then */
        
        when "2" then do:
            
            display b-obj with frame gDialog.
            
            create userobjs_temp-user-obj.
            assign 
            userobjs_temp-user-obj.obj-code = v-cntxt-obj-code
            userobjs_temp-user-obj.obj-type = v-cntxt-obj-type.
            
            v-obj-list = userobjs_temp-user-obj.obj-type + {&comma-char} + string(userobjs_temp-user-obj.obj-code) + {&delim-par}.
            
            find first buf_clients where buf_clients.obj-type = userobjs_temp-user-obj.obj-type
                                     and buf_clients.obj-code = userobjs_temp-user-obj.obj-code no-lock no-error.
            
            e-obj:screen-value in frame gDialog = if buf_clients.obj-name <> '' then buf_clients.obj-name
                                                  else userobjs_temp-user-obj.obj-type + string(userobjs_temp-user-obj.obj-code).
        end. /* when "2" then do */
        
    end case.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK gDialog 


/* ***************************  Main Block  *************************** */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.


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

  RUN enable_UI.
  RUN my-enable.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

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
    ,input 'exp-malina':U
    ,input 0
    ,input 0
    ,input '':U
    ,input ""
    ,input ""
    ,input (
    "Сохранение параметров Малина"
    )
    ,input yes
    ,buffer lock-batchprocess
    ) no-error .

  FIND FIRST buf_schedule-attr NO-LOCK WHERE
    buf_schedule-attr.task-type   = p-task-type
    and buf_schedule-attr.cre-db-num = INTEGER(p-db-num-char)
    and buf_schedule-attr.attr-code = ({&attr-schd-free-id} + {&delim-par} + 'exp-malina') NO-ERROR.
  IF AVAILABLE  buf_schedule-attr
    AND buf_schedule-attr.task-num <> p-task-num
    AND buf_schedule-attr.task-num <> - 1
    and p-task-num <> - 1
    THEN 
  DO:
    MESSAGE
      substitute("Уже есть расписание сохранения параметров Малина для БД &1&2" +
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
  DISPLAY v-company v-goods v-chk v-category t-location v-category-2 v-diapmin 
          v-diapmax v-directory v-prefix rs-obj e-obj 
      WITH FRAME gDialog.
  ENABLE RECT-2 b-start b-save b-close v-company v-goods v-chk v-category 
         t-location v-category-2 v-diapmin v-diapmax v-directory b-dir v-prefix 
         rs-obj b-obj e-obj 
      WITH FRAME gDialog.
  VIEW FRAME gDialog.
  {&OPEN-BROWSERS-IN-QUERY-gDialog}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-host-name gDialog 
PROCEDURE get-host-name :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
do on error undo, return error:

define output parameter p-host-name as character no-undo.

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
END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-enable gDialog 
PROCEDURE my-enable :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
/* Первоначально в окне будет выбран текущий объект */

ASSIGN 
    rs-obj:screen-value in frame gDialog = "2"
    v-directory:screen-value in frame gDialog = session:temp-directory.



/* Определим, это ручная выгрузка или задание параметров для произвольного задания */

case p-mode:
    when "run" then do:
        create userobjs_temp-user-obj.

    assign 
        userobjs_temp-user-obj.obj-code = v-cntxt-obj-code
        userobjs_temp-user-obj.obj-type = v-cntxt-obj-type.
    
    v-obj-list = userobjs_temp-user-obj.obj-type + {&comma-char} + string(userobjs_temp-user-obj.obj-code) + {&delim-par}.
    
    find first buf_clients where buf_clients.obj-type = userobjs_temp-user-obj.obj-type
                             and buf_clients.obj-code = userobjs_temp-user-obj.obj-code no-lock no-error.
    
    e-obj:screen-value in frame gDialog = if buf_clients.obj-name <> '' then buf_clients.obj-name
                                          else userobjs_temp-user-obj.obj-type + string(userobjs_temp-user-obj.obj-code).

        hide b-save in frame gDialog.

    end. /* when "run" */
    
    when "shd" then do:
        
        hide b-start in frame gDialog.
        /* Прочитаем атрибуты выгрузки */

        run schedule-attr-value in this-procedure (input p-db-num-char,
                                                   input p-task-type,
                                                   input p-task-num,
                                                   input {&attr-schedule-param-list-h},
                                                   output v-param-list,
                                                   output v-param-type).


        /* Если у нас уже были атрибуты - отобразим их */
        if v-param-list <> "" then do:

            ASSIGN
                v-company = integer(entry(1,v-param-list,{&delim-par}))
                v-directory = entry(2,v-param-list,{&delim-par}) 
                v-prefix = entry(3,v-param-list,{&delim-par}) 
                v-goods = logical(entry(4,v-param-list,{&delim-par}))
                v-chk = logical(entry(5,v-param-list,{&delim-par}))
                v-category = integer(entry(6,v-param-list,{&delim-par}))
                v-diapmin = integer(entry(7,v-param-list,{&delim-par}))
                v-diapmax = integer(entry(8,v-param-list,{&delim-par}))
                t-location = logical(entry(9,v-param-list,{&delim-par}))
                v-category-2 = entry(10,v-param-list,{&delim-par})
            /*    v-bonus-pay = entry(11,v-param-list,{&delim-par})*/
                NO-ERROR.

            DISPLAY v-company WITH FRAME gDialog.
            DISPLAY v-directory WITH FRAME gDialog.
            DISPLAY v-prefix WITH FRAME gDialog.
            DISPLAY v-goods WITH FRAME gDialog.
            DISPLAY v-chk WITH FRAME gDialog.
            DISPLAY v-category WITH FRAME gDialog.
            DISPLAY v-category-2 WITH FRAME gDialog.
            DISPLAY v-diapmin WITH FRAME gDialog.
            DISPLAY v-diapmax 
                    t-location

            WITH FRAME gDialog.

            
        end. /* if v-param-list <> '' */
        
        run schedule-attr-value in this-procedure (input p-db-num-char,
                                                   input p-task-type,
                                                   input p-task-num,
                                                   input {&attr-schedule-obj-list-h},
                                                   output v-obj-list,
                                                   output v-param-type).
        
        /* Если уже есть список объектов */
        if v-obj-list <> "" then do:
            for each userobjs_temp-user-obj:
                delete userobjs_temp-user-obj.
            end.
            /* Если по фирме */
            if v-obj-list begins {&cmp} then do:
    
                find first buf_clients where buf_clients.obj-type = entry(1, v-obj-list, {&comma-char})
                    and buf_clients.obj-code = integer(entry(2, v-obj-list, {&comma-char})) no-lock no-error.
                
                if available(buf_clients) then
                e-obj:screen-value = if buf_clients.obj-name <> '' then buf_clients.obj-name
                                     else buf_clients.obj-type + string(buf_clients.obj-code).
                
                rs-obj = 1.
                display rs-obj with frame gDialog.
                
            end. /* if v-obj-list begins {&cmp} */
            
            /* Если список объектов */
            else do:
                e-obj:screen-value = "".
                do ii = 1 to num-entries(v-obj-list, {&delim-par}) on error undo, next:
                    v-entry = entry(ii, v-obj-list, {&delim-par}).
                    /* Проверим, что они существуют */
                    find first buf_clients where buf_clients.obj-type = entry(1, v-entry, {&comma-char})
                        and buf_clients.obj-code = integer(entry(2, v-entry, {&comma-char})) no-lock no-error.
                      
                     if available buf_clients then do:
                         e-obj:screen-value = e-obj:screen-value + 
                         (if buf_clients.obj-name <> '' then buf_clients.obj-name
                         else buf_clients.obj-type + string(buf_clients.obj-code))
                         + "," + chr(13).
                         create userobjs_temp-user-obj.
                         assign 
                         userobjs_temp-user-obj.obj-type = buf_clients.obj-type
                         userobjs_temp-user-obj.obj-code = buf_clients.obj-code.
                         
                     end. /* if available buf_clients */
                     
                end. /* do ii = 1 to num-entries(v-obj-list) */
            
                rs-obj = 2.
                display rs-obj with frame gDialog.
                
            end. /* if v-obj-list begins {&shop} */
        end. /* if v-obj-list <> "" */
    end. /* when "shd" */
    
end case.
assign
    e-obj
    rs-obj
    v-directory.
END PROCEDURE.

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

