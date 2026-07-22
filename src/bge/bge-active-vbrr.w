&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*------------------------------------------------------------------------

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Выгрузка информации по пополнениям и активации для с верки с ВБРР

Автор: Шаланин Сергей
Дата создания: 22/04/2016
Author: Shalanin Sergey
Creation date: 22/04/2016

*/



DEFINE VARIABLE vss-revision    AS CHARACTER NO-UNDO INIT "$Revision$":U .
DEFINE VARIABLE vss-author      AS CHARACTER NO-UNDO INIT "$Author$":U .
DEFINE VARIABLE vss-date        AS CHARACTER NO-UNDO INIT "$Date$":U .
DEFINE VARIABLE vss-workfile    AS CHARACTER NO-UNDO INIT "$Workfile$":U .
DEFINE VARIABLE vss-archive     AS CHARACTER NO-UNDO INIT "$Archive$":U .
define variable vss-description as character no-undo init "Выгрузка информации по пополнениям и активации для сверки с ВБРР ".
/* Includes */
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{cmp/showinf.i}
{gbl/cur-time.i}
{ gbl/userobjs.i }
{ gbl/usr-flt.i  }
{ gbl/getcntxt.i def }
{ ref/shd-attr.i }
{ cmp/library.i  }
{ gbl/cur-time.i }

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

define variable v-today             as date      no-undo.
define variable p-obj-list          as character no-undo.

define variable par-type            as character no-undo.
define variable ptrl                as character no-undo.
define variable c-dir               as character no-undo. /* Директория для сохранения файла */
define variable v-host-name         as character no-undo.
define variable v-obj-list          as character no-undo.
define variable v-param-list        as character no-undo.
define variable v-param-type        as character no-undo.
define variable ii                  as integer   no-undo.
define variable v-entry             as character no-undo.
define variable ref-list            as character no-undo.
define variable v-user-select       as logical   no-undo .
define variable i                   as integer   init 1 no-undo.
define variable v-gds-active        as char      no-undo.
define variable v-gds-rec           as integer   no-undo.


define variable v-gds-inf           as char      no-undo.
define variable v-gds-rec-inf       as integer   no-undo.

DEFINE VARIABLE v-rid-list          AS CHARACTER NO-UNDO.
define variable v-rid               as recid     no-undo .
DEFINE VARIABLE v-ok                AS logical   NO-UNDO.
define variable v-esys-id           as integer   no-undo .
define variable v-value-character   as character no-undo init "".
define variable v-uniq-key-rec      as character no-undo .
define variable v-esys-uniq-key-rec as character no-undo .
define variable v-tbl-row           as rowid     no-undo .
define variable v-tbl-name          as character no-undo .


define temp-table temp_obj-list no-undo
    field obj-type as character
    field obj-code as integer
    index pi is primary unique obj-type obj-code
    .


/*          This .W file was created with the Progress AppBuilder.       */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS RECT-1 Btn_OK Btn_Cancel v-per time-days ~
date-from date-to code_pnpo v-directory ed-object rs-1 bt-sel-obj ~
bge-inf-po gds-inf-po bt-v-inf-pop bge-active gds-active bt-v-active 
&Scoped-Define DISPLAYED-OBJECTS v-per time-days date-from date-to ~
code_pnpo v-directory ed-object rs-1 bge-inf-po gds-inf-po bge-active ~
gds-active 

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
     SIZE 3.6 BY 1.05.

DEFINE BUTTON bt-v-active 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "..." 
     SIZE 3.6 BY 1.05.

DEFINE BUTTON bt-v-inf-pop 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "..." 
     SIZE 3.6 BY 1.05.

DEFINE BUTTON Btn_Cancel AUTO-END-KEY 
     LABEL "Отмена" 
     SIZE 15 BY 1.14.

DEFINE BUTTON Btn_OK AUTO-GO 
     LABEL "Запустить" 
     SIZE 15 BY 1.14.

DEFINE VARIABLE ed-object AS CHARACTER 
     VIEW-AS EDITOR NO-BOX
     SIZE 43 BY 2.71
     FGCOLOR 1  NO-UNDO.

DEFINE VARIABLE time-days AS CHARACTER INITIAL "дней" 
     VIEW-AS EDITOR NO-BOX
     SIZE 10 BY 1 NO-UNDO.

DEFINE VARIABLE code_pnpo AS CHARACTER FORMAT "X(256)":U 
     LABEL "ПНПО" 
     VIEW-AS FILL-IN 
     SIZE 19 BY 1 NO-UNDO.

DEFINE VARIABLE date-from AS DATE FORMAT "99/99/9999":U 
     LABEL "Дата с" 
     VIEW-AS FILL-IN 
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE date-to AS DATE FORMAT "99/99/9999":U 
     LABEL "по" 
     VIEW-AS FILL-IN 
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE gds-active AS INTEGER FORMAT "->>>>>>>>>>>>9" INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 20.6 BY 1 NO-UNDO.

DEFINE VARIABLE gds-inf-po AS INTEGER FORMAT "->>>>>>>>>>9" INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 20.6 BY 1 NO-UNDO.

DEFINE VARIABLE v-directory AS CHARACTER FORMAT "X(256)":U 
     LABEL "Директория" 
     VIEW-AS FILL-IN 
     SIZE 19 BY 1 NO-UNDO.

DEFINE VARIABLE v-per AS INTEGER FORMAT "->>>>>>9" INITIAL 0 
     LABEL "За последние" 
     VIEW-AS FILL-IN 
     SIZE 13 BY 1 NO-UNDO.

DEFINE VARIABLE rs-1 AS INTEGER 
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS 
          "по фирме", 2,
"по объектам", 3
     SIZE 19 BY 2.52 NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 72 BY 3.81.

DEFINE VARIABLE bge-active AS LOGICAL INITIAL no 
     LABEL "Выгружать данные по активации" 
     VIEW-AS TOGGLE-BOX
     SIZE 39 BY .81 NO-UNDO.

DEFINE VARIABLE bge-inf-po AS LOGICAL INITIAL no 
     LABEL "Выгружать информацию по пополнениям" 
     VIEW-AS TOGGLE-BOX
     SIZE 39 BY .81 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     Btn_OK AT ROW 2 COL 3
     Btn_Cancel AT ROW 2 COL 43.6
     v-per AT ROW 3.76 COL 20.6 COLON-ALIGNED WIDGET-ID 20
     time-days AT ROW 3.76 COL 36.6 NO-LABEL WIDGET-ID 52
     date-from AT ROW 4 COL 14.6 COLON-ALIGNED
     date-to AT ROW 4 COL 35 COLON-ALIGNED
     code_pnpo AT ROW 5.52 COL 14.6 COLON-ALIGNED WIDGET-ID 2
     v-directory AT ROW 7 COL 14.6 COLON-ALIGNED WIDGET-ID 12
     ed-object AT ROW 8.76 COL 30 NO-LABEL
     rs-1 AT ROW 8.86 COL 4 NO-LABEL WIDGET-ID 62
     bt-sel-obj AT ROW 10.29 COL 25 WIDGET-ID 6
     bge-inf-po AT ROW 12.67 COL 5 WIDGET-ID 8
     gds-inf-po AT ROW 12.67 COL 44 COLON-ALIGNED NO-LABEL WIDGET-ID 14
     bt-v-inf-pop AT ROW 12.67 COL 68 WIDGET-ID 54
     bge-active AT ROW 13.91 COL 5 WIDGET-ID 10
     gds-active AT ROW 13.91 COL 44 COLON-ALIGNED NO-LABEL WIDGET-ID 16
     bt-v-active AT ROW 13.91 COL 68 WIDGET-ID 56
     RECT-1 AT ROW 8.38 COL 3 WIDGET-ID 60
     SPACE(1.99) SKIP(3.38)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Выгрузка информации по пополнениям и активации для сверки с ВБРР"
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
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Выгрузка информации по пополнениям и активации для сверки с ВБРР */
DO:
  APPLY "END-ERROR":U TO SELF.
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bge-active
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bge-active Dialog-Frame
ON VALUE-CHANGED OF bge-active IN FRAME Dialog-Frame /* Выгружать данные по активации */
DO:
        assign bge-active.
        if bge-active = no then 
        do: 
            disable gds-active  with frame {&frame-name} .
            disable bt-v-active  with frame {&frame-name} .
        end.
        else 
        do: 
            enable gds-active bt-v-active   with frame {&frame-name} .
                    
        end.

    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bge-inf-po
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bge-inf-po Dialog-Frame
ON VALUE-CHANGED OF bge-inf-po IN FRAME Dialog-Frame /* Выгружать информацию по пополнениям */
DO:
        assign bge-inf-po.
        if bge-inf-po then 
        do: 
            enable gds-inf-po bt-v-inf-pop   with frame {&frame-name} .
        
        end.
        
        else 
        do: 
            disable gds-inf-po  with frame {&frame-name} .
            disable     bt-v-inf-pop  with frame {&frame-name} .
        end.
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-sel-obj
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-sel-obj Dialog-Frame
ON choose OF bt-sel-obj IN FRAME Dialog-Frame /* ... */
DO:
   
        define variable v-host-code        like ub.sysconf.host-code no-undo .
     assign
        rs-1 :screen-value  = "3"
    .
   
        define variable v-object-available as logical no-undo .
        { gbl/uobjclr.i }

        { gbl/usobjava.i
         v-cntxt-db-num
         {&action-head-code-main}
         v-cntxt-userid
         v-cntxt-obj-type
         v-cntxt-obj-code
         v-object-available
         no-error
    }
        if error-status :error
            then 
        do:
            message
                vss-workfile vss-revision vss-description skip
                "Ошибка при вызове процедуры gbl/usobjava.i" skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
            undo, return no-apply .
        end.

        if v-object-available = true
            then 
        do:
            { gbl/uobjapnd.i
       v-cntxt-obj-type
     v-cntxt-obj-code
      }
        end.

        define variable v-user-select as logical no-undo .
        { gbl/uobjsman.i
      parparentproc
      v-cntxt-db-num
      v-cntxt-userid
      v-cntxt-host-code-obj
      v-cntxt-obj-type
      v-cntxt-obj-code
      v-user-select
    }
        if v-user-select <> true
            then 
        do:
            message
                "Объект не выбран"
                view-as alert-box information .
            return no-apply .
        end.
        define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
        for each temp_obj-list:
            delete temp_obj-list.
        end.

        for each buf_userobjs_temp-user-obj
            on error undo, return no-apply
            :
            create temp_obj-list.
            assign
                temp_obj-list.obj-type = buf_userobjs_temp-user-obj.obj-type
                temp_obj-list.obj-code = buf_userobjs_temp-user-obj.obj-code
                .
        end.

        assign  
            p-obj-list = ""
            .
        for each temp_obj-list
            :
            assign 
                p-obj-list = p-obj-list 
                                    + temp_obj-list.obj-type + "," + string( temp_obj-list.obj-code ) + ",".
        end.
        assign
        p-obj-list = right-trim(p-obj-list, ",").
        
            ed-object :screen-value = p-obj-list
            .
   
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-v-active
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-v-active Dialog-Frame
ON CHOOSE OF bt-v-active IN FRAME Dialog-Frame /* ... */
DO:
        if bge-active = yes then 
        do: 
    
    
            run ref/gds-ref.p
                ( input parparentproc
                ,input "b-sel"
                ,input {&current}
                ,input {&all}
                ,input {&all}
                ,input ?
                ,input ?
                ,input ?
                ,input ?
                ,input ?
                ,input ?
                ,input ?
                ,output ref-list).
      
            if ref-list = ? OR ref-list = "" then return.
    
            find first ub.goods no-lock  
                where recid(ub.goods) = int(ref-list).
    
            assign
                v-gds-active = ub.goods.gds-name
                v-gds-rec    = ub.goods.gds-code.
                
   
        end.

        gds-active:screen-value   = string(v-gds-rec).
               
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-v-inf-pop
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-v-inf-pop Dialog-Frame
ON CHOOSE OF bt-v-inf-pop IN FRAME Dialog-Frame /* ... */
DO:
        define variable ref-list-inf as char no-undo.
    
        assign bge-inf-po.
    
        if bge-inf-po = yes then 
        do:
            run ref/gds-ref.p
                ( input parparentproc
                ,input "b-sel"
                ,input {&current}
                ,input {&all}
                ,input {&all}
                ,input ?
                ,input ?
                ,input ?
                ,input ?
                ,input ?
                ,input ?
                ,input ?
                ,output ref-list-inf).
      
            if ref-list-inf = ? OR ref-list-inf = "" then return.
    
            find first ub.goods no-lock
                where recid(ub.goods) = int(ref-list-inf).
    
            assign
                v-gds-inf     = ub.goods.gds-name
                v-gds-rec-inf = ub.goods.gds-code.

        end.
        
        gds-inf-po:screen-value  = string(v-gds-rec-inf).
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_Cancel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_Cancel Dialog-Frame
ON CHOOSE OF Btn_Cancel IN FRAME Dialog-Frame /* Отмена */
DO:
        assign
            p-cancel = yes
            .
        apply "window-close" to frame {&frame-name}.
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_OK
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_OK Dialog-Frame
ON CHOOSE OF Btn_OK IN FRAME Dialog-Frame /* Запустить */
DO:
define variable v-obj-range as integer no-undo . /* Диапазон: 1 - глобально, 2 - по фирме, 3 - список объектов */
define variable v-host-code as integer no-undo . /* Код текущей фирмы для p-range = 2 */


assign 
date-from
date-to
.

        if date-from > date-to then 
        do:
            message
                "Даты интервала заданы неверно. "
                skip 
                " Нижняя дата интервала должна быть меньше верхней."
                skip(1) "Задайте интервал дат правильно или отмените экспорт."
                view-as alert-box information.
            apply "entry" to date-from.
            undo, return no-apply.
        end.
     

        DEFINE VARIABLE l-dircrt  AS LOGICAL       NO-UNDO. /* Для ответа на создание директории */
        define variable h-par     as widget-handle no-undo.
        DEFINE variable loghandle AS HANDLE        no-undo.
        DEFINE VARIABLE v-objects AS CHARACTER     NO-UNDO.
        ASSIGN
            FRAME {&frame-name}
     
            v-directory
       
            .
 
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
       
       
        FILE-INFO:FILE-NAME = v-directory.
            
        assign
            rs-1
            code_pnpo
            bge-active 
            bge-inf-po
            v-per
            gds-inf-po
            gds-active
            .
            
      case rs-1 :screen-value :
        when "2" then do:
          assign
            v-obj-range = 2
            v-host-code = p-curr-host-code
            p-obj-list  = string(p-curr-host-code)
          .
        end.
        when "3" then do:
          assign
            v-obj-range = 3
            p-obj-list  = ""
          .
          for each temp_obj-list :
            p-obj-list = p-obj-list + "," + temp_obj-list.obj-type + "," + string( temp_obj-list.obj-code ) .
          end.
          p-obj-list = substring(p-obj-list, 2).
        end.
        otherwise assign
          v-obj-range = 2
          v-host-code = p-curr-host-code
          p-obj-list  = string(p-curr-host-code)
        .
      end case.
        

        if p-mode = "shd" then 
        do:
            v-param-list =
                string(gds-inf-po) + {&delim-par} +
                string(gds-active) + {&delim-par} +
                v-directory + {&delim-par} +
                code_pnpo + {&delim-par} +
                string(bge-active) + {&delim-par} +
                string(bge-inf-po) + {&delim-par} +
                string(v-per)
            .
            run attach-attr-to-schedule-line in this-procedure ( INPUT v-param-list ).

define variable v-list as character no-undo .
                
            v-list = substitute( "&1:&2"
                             , v-obj-range
                             , p-obj-list
                             ).
                
            run schedule-attr-write in this-procedure (input p-db-num-char, 
                input p-task-type,
                input p-task-num,
                input {&attr-schedule-obj-list-h},
                input v-list).
   
    
            message "Параметры сохранены!" view-as alert-box information.

            apply "go".
        end.
        if p-mode = "run" then 
        do: 
    
            run bge/active-vbrr.p (input parparentproc
                ,input v-obj-range
                ,input v-host-code
                ,input p-obj-list
                ,input date-to
                ,input date-from
                ,input gds-inf-po
                ,input gds-active
                ,input v-directory
                ,input code_pnpo
                ,input bge-active 
                ,input bge-inf-po
                ,input v-per
        
                ) no-error .
                
            if error-status :error then 
            do: 
                message
         return-value skip
            error-status:get-message(1) view-as alert-box error.
            end.
run flt-save in this-procedure . 
                
end.
   
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME date-to
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL date-to Dialog-Frame
ON RETURN OF date-to IN FRAME Dialog-Frame /* по */
DO:
        APPLY "ENTRY" TO btn_ok IN FRAME {&FRAME-NAME}.
        RETURN NO-APPLY.
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME rs-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rs-1 Dialog-Frame
ON VALUE-CHANGED OF rs-1 IN FRAME Dialog-Frame
DO:
run object-select in this-procedure no-error .
if error-status :error
then do:
    undo, return no-apply.
end.
assign
    rs-1
.
bt-sel-obj:SENSITIVE = ( rs-1 = 3 ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame 


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

{ gbl/ed_date.i date-from }
{ gbl/ed_date.i date-to   }

ASSIGN
    date-from = v-today
    date-to   = v-today
    v-directory = ""
    code_pnpo   = ""
    bge-active  = false
    bge-inf-po  = false
.
    
{ gbl/getcntxt.i get }
/*
 v-cntxt-db-num используется в триггере on choose OF bt-sel-obj
 
 в режиме shd на вход не передаются значения p-curr-host-code, p-curr-obj-type, p-curr-obj-code;
 берём их из output v-cntxt-host-code-obj, output v-cntxt-obj-type, output v-cntxt-obj-code
  
*/
if p-curr-obj-code = 0 then assign
  p-curr-host-code = v-cntxt-host-code-obj
  p-curr-obj-type  = v-cntxt-obj-type
  p-curr-obj-code  = v-cntxt-obj-code
.

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  RUN enable_UI.

    run get-host-name in this-procedure ( output v-host-name ) no-error .
    if error-status :error
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Ошибка при определении имени фирмы"
          skip "Код фирмы:" p-curr-host-code
          skip "Имя фирмы будет отображаться как '" + {&cmp} + string( p-curr-host-code ) + "'"
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
               trim(error-status :get-message(4))
               trim(error-status :get-message(5))
        view-as alert-box warning.
        assign
            v-host-name = {&cmp} + string( p-curr-host-code )
        .
    end.
    
    assign
        rs-1 :screen-value in frame dialog-frame = "2"
        ed-object :screen-value in frame Dialog-frame = {&cmp} + string( p-curr-host-code ) + " " + v-host-name
    .
    assign
        rs-1
    .
    
    if p-mode = "run" then 
    do:
        run flt-load in this-procedure .
    end.

    if rs-1 <> 3 then 
    do: 
        disable bt-sel-obj with frame {&frame-name} .
    end.
    
    if bge-active = no then 
    do: 
        disable gds-active  with frame {&frame-name} .
        disable bt-v-active  with frame {&frame-name} .
    end.

    if bge-inf-po = no then 
    do: 
        disable gds-inf-po  with frame {&frame-name} .
        disable     bt-v-inf-pop  with frame {&frame-name} .
    end.

    if p-mode = "shd" then
    do:
        Btn_OK:LABEL = "Сохранить".
        display    Btn_OK    with frame {&frame-name}.
        enable Btn_OK with frame {&frame-name}.

    end.
    else
    do:
        Btn_OK:LABEL = "Запустить".
    end.

            
    run myenable .
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
  DISPLAY v-per time-days date-from date-to code_pnpo v-directory ed-object rs-1 
          bge-inf-po gds-inf-po bge-active gds-active 
      WITH FRAME Dialog-Frame.
  ENABLE RECT-1 Btn_OK Btn_Cancel v-per time-days date-from date-to code_pnpo 
         v-directory ed-object rs-1 bt-sel-obj bge-inf-po gds-inf-po 
         bt-v-inf-pop bge-active gds-active bt-v-active 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE myenable Dialog-Frame 
PROCEDURE myenable :
/*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
  
    
    case p-mode:

        when "run" then 
            do:
                hide  v-per in frame {&frame-name}.
                hide time-days in frame  {&frame-name}.
                
                disable   v-per  time-days with  frame  {&FRAME-NAME}.
            end. /* when "run" */
        when "shd" then 
            do:
                hide date-from in frame  {&FRAME-NAME}.
                hide date-to in frame {&Frame-name}.
                /*                hide btn_ok in frame {&FRAME-NAME}.*/
                disable  date-to  date-from with  frame  {&FRAME-NAME}.
                
                /* Прочитаем атрибуты выгрузки */
                run schedule-attr-value in this-procedure (input p-db-num-char
                    , input p-task-type
                    , input p-task-num
                    , input {&attr-schedule-param-list-h}
                    ,output v-param-list
                    ,output v-param-type).
                
                /*                 Если у нас уже были атрибуты - отобразим их*/
                
                if v-param-list <> ?  then
                do:
                    assign

                        gds-inf-po  = integer(entry (1, v-param-list, {&delim-par}))
                        gds-active  = integer(entry (2, v-param-list, {&delim-par}))
                        v-directory = entry (3, v-param-list, {&delim-par})
                        code_pnpo   = entry (4, v-param-list, {&delim-par})
                        bge-active  = logical(entry (5, v-param-list, {&delim-par}))
                        bge-inf-po  = logical(entry (6, v-param-list, {&delim-par}))
                        v-per       = integer(ENTRY(7, v-param-list, {&delim-par}))
                        p-obj-list  = (ENTRY(8, v-param-list, {&delim-par}))
                        no-error
                        .
                                
                end.
                    
                display gds-inf-po v-directory gds-active  code_pnpo   bge-active bge-inf-po v-per  with frame {&FRAME-NAME}.
                    
                ed-object :SCREEN-VALUE = p-obj-list.

            end.
            
            
    end case.
END PROCEDURE.



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
        ,input 'exp-active-vbrr':U
        ,input 0
        ,input 0
        ,input '':U
        ,input ""
        ,input ""
        ,input (
        "Сохранение параметров выгрузки чеков "
        )
        ,input yes
        ,buffer lock-batchprocess
        ) no-error .

/*    FIND FIRST buf_schedule-attr NO-LOCK WHERE                                                               */
/*        buf_schedule-attr.task-type   = p-task-type                                                          */
/*        and buf_schedule-attr.cre-db-num = INTEGER(p-db-num-char)                                            */
/*        and buf_schedule-attr.attr-code = ({&attr-schd-free-id} + {&delim-par} + 'exp-active-vbrr') NO-ERROR.*/
/*    IF AVAILABLE  buf_schedule-attr                                                            */
/*        AND buf_schedule-attr.task-num <> p-task-num                                           */
/*        AND buf_schedule-attr.task-num <> - 1                                                  */
/*        and p-task-num <> - 1                                                                  */
/*        THEN                                                                                   */
/*    DO:                                                                                        */
/*        MESSAGE                                                                                */
/*            substitute("Уже есть расписание сохранения параметров выгрузки чеков для БД &1&2" +*/
/*            "номер расписания &3"                                                              */
/*            ,buf_schedule-attr.cre-db-num                                                      */
/*            ,{&NEW-LINE}                                                                       */
/*            ,buf_schedule-attr.task-num)                                                       */
/*            VIEW-AS ALERT-BOX ERROR.                                                           */
/*        UNDO, RETURN ERROR.                                                                    */
/*    END.                                                                                       */
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
    /*message p-task-type "task" p-task-num "db" p-db-num-char view-as alert-box.*/
    run schedule-attr-write in this-procedure (
        input INTEGER(p-db-num-char)
        , input p-task-type
        , input p-task-num
        , input {&attr-schedule-param-list-h}
        , input p-param-list
        ).

END PROCEDURE.

PROCEDURE object-select :
do on error undo, return error :

case rs-1 :screen-value in frame Dialog-frame:
    when "2" then do:
        assign
          ed-object :screen-value in frame Dialog-frame = {&cmp} + string( p-curr-host-code ) + " " + v-host-name
        .
    end.
    when "3" then do:
        for each temp_obj-list :
            delete temp_obj-list.
        end.
        create temp_obj-list.
        assign
            temp_obj-list.obj-type  = p-curr-obj-type
            temp_obj-list.obj-code  = p-curr-obj-code
            ed-object :screen-value = p-curr-obj-type + string( p-curr-obj-code )
        .
    end.
    otherwise ed-object :screen-value = "".
    
end case.

end.
END PROCEDURE.

PROCEDURE get-host-name :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define output parameter p-host-name as character    no-undo.

define buffer buf_clients   for ub.clients.

    find first buf_clients no-lock
/*         where buf_clients.obj-type = p-curr-obj-type*/
/*           and buf_clients.obj-code = p-curr-obj-code*/
         where buf_clients.obj-type = {&cmp}
           and buf_clients.obj-code = p-curr-host-code
    no-error.
    if not available buf_clients
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Не удалось найти текущую фирму"
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
               trim(error-status :get-message(4))
               trim(error-status :get-message(5))
        view-as alert-box error.
        undo, return error .
    end.
    else assign
            p-host-name = buf_clients.obj-name
    .
end.
END PROCEDURE. /* get-host-name */


PROCEDURE flt-save :
    /*------------------------------------------------------------------------------
              Purpose:
              Parameters:  <none>
              Notes:
            ------------------------------------------------------------------------------*/
    define variable v-obj-range   as integer   no-undo .
    define variable v-obj-list    as character no-undo .
    define variable v-doc-range   as integer   no-undo .
    define variable v-doc-list    as character no-undo .
    define variable v-userid      as character no-undo .
    define variable v-naim        as character no-undo .
    define variable v-list        as character no-undo .
    define variable v-print-graft as logical   no-undo .
    define variable v-sort-gr     as logical   no-undo .
    define variable v-type-price  as logical   no-undo .
    define variable v-type-val    as logical   no-undo .
    v-naim ="".
    do
        on error undo, return error return-value
        :
            
        assign frame {&frame-name}
            date-to
            date-from
            gds-inf-po
            gds-active
            v-directory
            code_pnpo
            rs-1
            bge-active 
            bge-inf-po
            .
  case rs-1 :screen-value  :
  when "2"  then assign
          v-obj-range = 2
          v-obj-list = string(p-curr-host-code)
      .
  when "3"  then do:
      assign
          v-obj-range = 3
          v-obj-list = ""
      .
      for each temp_obj-list :
        v-obj-list = v-obj-list + "," + temp_obj-list.obj-type + "," + string( temp_obj-list.obj-code ) .
      end.
      v-obj-list = substring(v-obj-list, 2).
  end.
  otherwise assign
          v-obj-range = 2
          v-obj-list = string(p-curr-host-code)
  .
  end case.
    
        v-naim = string(date-to) + "," 
            + string(date-from) + "," 
            + string(gds-inf-po) + ","
            + string(gds-active) + ","
            + v-directory + ","
            + code_pnpo + ","
            + string(bge-active) + ","
            + string(bge-inf-po)
            .
        v-list = substitute( "&1:&2"
                             , v-obj-range
                             , v-obj-list
                             )
        .
        run uf-set ( input {&uf-bge-active-vbrr}
            , input v-cntxt-userid
            , input v-list
            , input v-naim
            , input v-print-graft
            , input v-sort-gr
            , input v-type-price
            , input v-type-val
            ) .
    end.
end procedure.
    
PROCEDURE flt-load :
  define variable v-obj-range      as integer   no-undo .
  define variable v-obj-list       as character no-undo .
  define variable v-obj-type       as character no-undo .
  define variable v-obj-code       as integer   no-undo .
  define variable v-i              as integer   no-undo .
    define variable v-naim        as character no-undo .
    define variable v-list        as character no-undo .
    define variable v-print-graft as logical   no-undo .
    define variable v-sort-gr     as logical   no-undo .
    define variable v-type-price  as logical   no-undo .
    define variable v-type-val    as logical   no-undo .
    define variable v-found       as logical   no-undo .
    define variable v-obj-tot     as integer   no-undo .
    define variable v-ed-object   as char      no-undo.
    
    p-obj-list = "".
    
    do
    
        on error undo, return error return-value
        :
            
        run uf-get (
            input   {&uf-bge-active-vbrr}
            , input   v-cntxt-userid
            , output  v-list
            , output  v-naim
            , output  v-print-graft
            , output  v-sort-gr
            , output  v-type-price
            , output  v-type-val
            ) .
        if num-entries(v-naim) = 8 then 
        do: 
            assign
                date-to     = date( entry( 1, v-naim ) )
                date-from   = date(  entry( 2, v-naim ) )
                gds-inf-po  = integer(entry( 3, v-naim )) 
                gds-active  = integer(entry( 4, v-naim ))
                v-directory = entry( 5, v-naim )  
                code_pnpo   = entry( 6, v-naim ) 
                bge-active  = logical(entry( 7, v-naim ) )
                bge-inf-po  = logical(entry( 8, v-naim ) )
                no-error
                .
        end.
        date-from = date-to + 1. 
        date-to = today.
        date-from = minimum(date-from, date-to). 
        ed-object = "".
        display
            date-to
            date-from
            gds-inf-po
            gds-active
            v-directory
            code_pnpo
            bge-active 
            bge-inf-po
            ed-object
            with frame {&frame-name}.

    if num-entries(v-list,':') = 2
    then do:
      assign
        rs-1        = integer(entry(1, v-list, ':'))
        v-obj-list  = entry(2, v-list, ':')
        v-obj-tot   = num-entries(v-obj-list)
      .
      display
        rs-1
      with frame {&frame-name}.
      for each temp_obj-list :
        delete temp_obj-list.
      end.
      case rs-1:
        when 2 then do:
          ed-object :screen-value in frame Dialog-frame = {&cmp} + v-obj-list.
        end.
        when 3 then do:
          if v-obj-tot modulo 2 = 0
          then do:
            do v-i = 1 to v-obj-tot / 2 :
              assign
                v-obj-type =          entry( v-i * 2 - 1, v-obj-list )
                v-obj-code = integer( entry( v-i * 2,     v-obj-list ) )
              .
              find first temp_obj-list no-lock
                where temp_obj-list.obj-type = v-obj-type
                  and temp_obj-list.obj-code = v-obj-code no-error .
              if available temp_obj-list then next.
              create temp_obj-list.
              assign
                temp_obj-list.obj-type = v-obj-type
                temp_obj-list.obj-code = v-obj-code
              .
            end. /* do v-i = 1 to v-obj-tot / 2 */
            assign
              ed-object :screen-value in frame {&frame-name} = v-obj-list
            .
          end. /* if v-obj-tot modulo 2 = 0 */
        end. /* when 3 */
      end case.
    end. /* if num-entries(v-str,':') = 2 */


p-obj-list = v-obj-list.
            
    end.
end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

