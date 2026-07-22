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

Форма выгрузки информации в систему Карбон

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
&Scoped-Define ENABLED-OBJECTS b-start b-save b-close v-company v-directory ~
b-dir v-prefix f-grp-fuel f-grp-spec 
&Scoped-Define DISPLAYED-OBJECTS v-company v-directory v-prefix f-grp-fuel ~
f-grp-spec 

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

DEFINE BUTTON b-save 
     LABEL "Сохранить" 
     SIZE 15 BY 1.13.

DEFINE BUTTON b-start 
     LABEL "Запустить" 
     SIZE 15 BY 1.13.

DEFINE VARIABLE f-grp-fuel AS INTEGER FORMAT "->>>>>>9":U INITIAL 0 
     LABEL "Код группы для топлива" 
     VIEW-AS FILL-IN 
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE f-grp-spec AS INTEGER FORMAT ">>>>>>>>9":U INITIAL 0 
     LABEL "Код группы для товаров, запрещенных к начислению" 
     VIEW-AS FILL-IN 
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE v-company AS INTEGER FORMAT ">>>>>>>>9":U INITIAL 39069 
     LABEL "Идентификатор компании" 
     VIEW-AS FILL-IN 
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE v-directory AS CHARACTER FORMAT "X(256)":U 
     LABEL "Директория" 
     VIEW-AS FILL-IN 
     SIZE 22.5 BY 1 NO-UNDO.

DEFINE VARIABLE v-prefix AS CHARACTER FORMAT "X(256)":U 
     LABEL "Код региона~\Префикс для кодов" 
     VIEW-AS FILL-IN 
     SIZE 25.5 BY 1 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME gDialog
     b-start AT ROW 1.25 COL 2 WIDGET-ID 8
     b-save AT ROW 1.25 COL 49
     b-close AT ROW 1.25 COL 65
     v-company AT ROW 3.25 COL 30.5 COLON-ALIGNED WIDGET-ID 10
     v-directory AT ROW 4.5 COL 30.5 COLON-ALIGNED WIDGET-ID 12
     b-dir AT ROW 4.5 COL 55.13 WIDGET-ID 22
     v-prefix AT ROW 5.75 COL 30.5 COLON-ALIGNED WIDGET-ID 6
     f-grp-fuel AT ROW 7.5 COL 50 COLON-ALIGNED WIDGET-ID 38
     f-grp-spec AT ROW 9.04 COL 50 COLON-ALIGNED WIDGET-ID 40
     SPACE(14.37) SKIP(3.74)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Выгрузка информации в систему ~"Карбон~""
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
ON WINDOW-CLOSE OF FRAME gDialog /* Выгрузка информации в систему "Карбон" */
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


&Scoped-define SELF-NAME b-save
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-save gDialog
ON CHOOSE OF b-save IN FRAME gDialog /* Сохранить */
DO:

    DEFINE VARIABLE l-dircrt AS LOGICAL. /* Для ответа на создание директории */
    
run check-param no-error.
If error-status:error then return no-apply.
    ASSIGN 
        v-company
        v-directory
        v-prefix
        f-grp-fuel
        f-grp-spec.
    
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

    v-param-list = string(v-company) + {&delim-par} + v-directory + {&delim-par} + v-prefix + {&delim-par} + string(f-grp-fuel) + {&delim-par} + string(f-grp-spec).

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

run check-param no-error.
If error-status:error then return no-apply.
  ASSIGN 
    v-company
    v-directory
    v-prefix
    f-grp-fuel
    f-grp-spec.
    
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
    run bge\exp-carbon.p ( this-procedure:handle,
                            v-company,
                            v-directory,
                            v-prefix,
                            f-grp-fuel,
                            f-grp-spec                      
                       ) .

    apply "go".

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
    ,input 'exp-carbon':U
    ,input 0
    ,input 0
    ,input '':U
    ,input ""
    ,input ""
    ,input (
    "Сохранение параметров Карбон"
    )
    ,input yes
    ,buffer lock-batchprocess
    ) no-error .

  FIND FIRST buf_schedule-attr NO-LOCK WHERE
    buf_schedule-attr.task-type   = p-task-type
    and buf_schedule-attr.cre-db-num = INTEGER(p-db-num-char)
    and buf_schedule-attr.attr-code = ({&attr-schd-free-id} + {&delim-par} + 'exp-carbon') NO-ERROR.
  IF AVAILABLE  buf_schedule-attr
    AND buf_schedule-attr.task-num <> p-task-num
    AND buf_schedule-attr.task-num <> - 1
    and p-task-num <> - 1
    THEN 
  DO:
    MESSAGE
      substitute("Уже есть расписание сохранения параметров Карбон для БД &1&2" +
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE check-param gDialog 
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
        v-company
        v-directory
        v-prefix
        f-grp-fuel
        f-grp-spec
        .
    
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
    if v-prefix = ? or v-prefix = '' then do:
        message 'Не указано значение Кода региона' view-as alert-box error.
        apply 'entry':U to v-prefix.
        return error.
    end.
        if f-grp-fuel > 0 then.
        else do:
            message 'Не указано значение Кода группы для топлива' view-as alert-box error.
            apply 'entry':U to f-grp-fuel.
        return error. 
        end.
        if f-grp-spec > 0 then. 
        else do:
            message 'Не указано значение Кода группы для товаров, на которые не начисляются бонусы' view-as alert-box error.
            apply 'entry':U to f-grp-spec.            
        return error.
        end.
    

    
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
  DISPLAY v-company v-directory v-prefix f-grp-fuel f-grp-spec 
      WITH FRAME gDialog.
  ENABLE b-start b-save b-close v-company v-directory b-dir v-prefix f-grp-fuel 
         f-grp-spec 
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
    v-directory:screen-value in frame gDialog = session:temp-directory.

assign
    v-directory.

/* Определим, это ручная выгрузка или задание параметров для произвольного задания */

case p-mode:
    when "run" then do:

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
                f-grp-fuel = int(entry(4,v-param-list,{&delim-par}))
                f-grp-spec = int(entry(5,v-param-list,{&delim-par}))
                NO-ERROR.

            DISPLAY v-company WITH FRAME gDialog.
            DISPLAY v-directory WITH FRAME gDialog.
            DISPLAY v-prefix WITH FRAME gDialog.
            DISPLAY f-grp-fuel WITH FRAME gDialog.
            DISPLAY f-grp-spec WITH FRAME gDialog.

            
        end. /* if v-param-list <> '' */
        
    end. /* when "shd" */
    
end case.

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

