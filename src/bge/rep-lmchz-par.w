&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Параметры для выгрузки статуса ЛМ ЧЗ

Автор: Белова Марина Михайловна
Дата создания: 26/09/24
Author: Belova Marina
Creation date: 26/09/24

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-curr-host-code like ub.sysconf.host-code no-undo .
define input parameter p-curr-obj-type  like ub.clients.obj-type no-undo .
define input parameter p-curr-obj-code  like ub.clients.obj-code no-undo .
define input PARAMETER p-mode           AS CHARACTER NO-UNDO.
/*вызывается для задания параметров или перед непосредственнно выполнением*/
/*может быть 'shd' или 'run' */
define input parameter p-cre-db-num     as integer      no-undo .
define input parameter p-task-type      as character    no-undo.
define input parameter p-task-num       as integer      no-undo.

/*при p-mode = 'run'*/
define input parameter p-action         as character    no-undo.
/**/
define output parameter p-cancel        as logical      no-undo.
define output parameter p-params        as character    no-undo.


/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Параметры выгрузки статуса ЛМ ЧЗ".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/trg-def.i  }
{ cmp/library.i  }
{ cmp/showinf.i  }
{ ref/shd-attr.i }
{ gbl/cur-time.i }
{ cmp/ini-lib.i  }
{ gbl/getcntxt.i def }
{ gbl/key-rec.i }
{ rul/calldscr.i }
DEFINE VARIABLE v-dir-save AS CHARACTER NO-UNDO.
DEFINE VARIABLE l-dircrt AS LOGICAL NO-UNDO.

DEFINE VARIABLE v-rid-list          AS CHARACTER NO-UNDO.
define variable v-rid               as recid     no-undo .
DEFINE VARIABLE v-ok                AS logical   NO-UNDO.
define variable v-esys-id           as integer   no-undo .

define variable ref-list as character no-undo.
define variable ref-rec as recid no-undo.
define buffer buf_clients for ub.clients.

DEFINE VARIABLE glog AS LOGICAL NO-UNDO.


/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Internal Tables (found by Frame, Query & Browse Queries)             */

/* Definitions for DIALOG-BOX Dialog-Frame                              */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */

DEFINE BUTTON b-dir-sel
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "..."
     SIZE 3.63 BY 1.04.

DEFINE BUTTON b-save 
     LABEL "Сохранить" 
     SIZE 12 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 12 BY 1
     BGCOLOR 8 .


DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 12 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE v-directory AS CHARACTER FORMAT "X(256)":U
     LABEL "Директория"
     VIEW-AS FILL-IN
     SIZE 62.5 BY 1
     BGCOLOR 8 FGCOLOR 4  NO-UNDO.

     

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-save AT ROW 1 COL 2
     b-quit AT ROW 1 COL 14
     B-Help AT ROW 1 COL 54.8
     v-directory AT ROW 2.52 COL 14.6 COLON-ALIGNED
     b-dir-sel AT ROW 2.52 COL 78
     SPACE(0.03) SKIP(0.93)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Параметры выгрузки статуса ЛМ ЧЗ в xml"
         DEFAULT-BUTTON b-save CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: temp-obj T "?" NO-UNDO ub inkas
      ADDITIONAL-FIELDS:
          field fact-order as decimal
          field c-inkas-code like ub.c-inkas.inkas-code
          field chip-num like ub.c-inkas.chip-num
      END-FIELDS.
      TABLE: tt0-rp-by-call T "?" NO-UNDO ub rp-by-call
      TABLE: tt0-rule-by-call T "?" NO-UNDO ub rule-by-call
      TABLE: tt0-rule-call-param T "?" NO-UNDO ub rule-call-param
      TABLE: X_dis-card-type B "?" ? ub dis-card-type
      TABLE: X_rp-by-call B "?" ? ub rp-by-call
      TABLE: X_rule B "?" ? ub rule
      TABLE: X_rule-by-call B "?" ? ub rule-by-call
      TABLE: X_rule-by-profile B "?" ? ub rule-by-profile
      TABLE: X_rule-profile B "?" ? ub rule-profile
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN X_dis-card-type.emitent-host-code IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN f-dc-type-label IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN f-file-name-label IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN f-rs-dir-label IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN f-rs-file-rule-label IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN file-name-1 IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN X_rule-profile.name IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN X_dis-card-type.type IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L EXP-LABEL                                          */
/* SETTINGS FOR FILL-IN v-directory IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _TblList          = "Temp-Tables.X_rule-profile,ub.rule WHERE Temp-Tables.X_rule-profile ...,Temp-Tables.X_dis-card-type WHERE Temp-Tables.X_rule-profile ..."
     _Options          = "SHARE-LOCK"
     _Query            is OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Параметры импорта данных по продажам по ДК из текстового файл */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME b-dir-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-dir-sel Dialog-Frame
ON CHOOSE OF b-dir-sel IN FRAME Dialog-Frame /* ... */
DO:
  define variable c-dir-name  as character no-undo.
  define variable c-dir-type  as character no-undo.
  define variable l-can-write as logical   no-undo.

  { gbl/stdbtn.i }
  run gbl/dir-sel.p ( output c-dir-name, output c-dir-type, output l-can-write ).
  if c-dir-name = '':U or c-dir-name = ? or
     c-dir-type = '':U or c-dir-type = ? then do:
    return no-apply.
  end.
  if l-can-write <> yes then do:
    message 'Вы не имеете права писать в выбранную директорию:' c-dir-name view-as alert-box error.
    return no-apply.
  end.
  assign  v-directory = c-dir-name.
  display v-directory with frame {&FRAME-NAME}.

    .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME B-save
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-save Dialog-Frame
ON CHOOSE OF B-save IN FRAME Dialog-Frame /* Сохранить */
DO:
  ASSIGN
    v-directory
  .
  RUN proc-save IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
  APPLY "GO" TO FRAME {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-quit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-quit Dialog-Frame
ON CHOOSE OF b-quit IN FRAME Dialog-Frame /* Отмена */
DO:
      assign
        p-cancel = yes
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

{ gbl/app_help.i }

{ gbl/getcntxt.i get }

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  if p-mode = 'shd':U then do:
    assign
    frame {&frame-name} :title = frame {&frame-name} :title +
                      substitute(". &1: Задача номер &2"
                      , p-task-type
                      , p-task-num )
    .
  end.
  run init-param-values in this-procedure  no-error .
  if error-status :error then undo, return error .
/*  RUN init-fields in this-procedure no-error.     */
/*  if error-status :error then undo, return error .*/
  RUN Myenable.
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

  /*данная конкретная задача может быть ТОЛЬКО ОДНА в одной БД - отследим*/
  /*заблокируем*/
  run gbl/lock-prc.p
    (input {&lock-prc-schd-free}
    ,input 'rep-lmchz':U
    ,input 0
    ,input 0
    ,input '':U
    ,input ""
    ,input ""
    ,input (
    "Сохранение параметров выгрузки статуса ЛМ ЧЗ "
    )
    ,input yes
    ,buffer lock-batchprocess
    ) no-error .

  FIND FIRST buf_schedule-attr NO-LOCK WHERE
    buf_schedule-attr.task-type   = p-task-type
    and buf_schedule-attr.cre-db-num = INTEGER(p-cre-db-num)
    and buf_schedule-attr.attr-code = ({&attr-schd-free-id} + {&delim-par} + 'rep-lmchz') NO-ERROR.
  IF AVAILABLE  buf_schedule-attr
    AND buf_schedule-attr.task-num <> p-task-num
    AND buf_schedule-attr.task-num <> - 1
    and p-task-num <> - 1
    THEN 
  DO:
    MESSAGE
      substitute("Уже есть расписание сохранения параметров выгрузки статуса ЛМ ЧЗ для БД &1&2" +
      "номер расписания &3"
      ,buf_schedule-attr.cre-db-num
      ,{&NEW-LINE}
      ,buf_schedule-attr.task-num)
      VIEW-AS ALERT-BOX ERROR.
    UNDO, RETURN ERROR.
  END.
  find first buf_schedule no-lock
    where buf_schedule.task-type   = p-task-type
    and buf_schedule.cre-db-num  = INTEGER(p-cre-db-num)
    and buf_schedule.task-num    = p-task-num
    no-error.
  if not available buf_schedule
    and (  p-task-type   <> {&btpr-type-autofree}
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
    input INTEGER(p-cre-db-num)
    , input p-task-type
    , input p-task-num
    , input {&attr-schedule-param-list-h}
    , input p-param-list
    ).

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

  DISPLAY v-directory 
      WITH FRAME Dialog-Frame.
  ENABLE B-save b-quit B-Help b-dir-sel v-directory 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-param-values Dialog-Frame
PROCEDURE init-param-values :
do
on error undo, return error
:
define variable v-param-list    as character     no-undo.
define variable v-param-type    as character     no-undo.
define variable v-entry  as character no-undo .
define variable v-task-num as integer   no-undo .
  
  v-directory:screen-value in frame {&FRAME-NAME} = "".
  assign v-directory.
     
  case p-mode:
/*    when "run"                           */
/*    then do:                             */
/*      hide b-save in frame {&FRAME-NAME}.*/
/*      ENABLE                             */
/*      Btn_start                          */
/*      b-system                           */
/*      b-quit                             */
/*      B-Help                             */
/*      b-dir-sel                          */
/*      v-directory                        */
/*      b-rko-cli                          */
/*      WITH FRAME {&frame-name}.          */
/*    end. /* when "run" */                */
    when "shd"
    then do:
      /* Прочитаем атрибуты выгрузки */
      run schedule-attr-value in this-procedure (input p-cre-db-num  
          , input p-task-type
          , input p-task-num 
          , input {&attr-schedule-param-list-h}
          ,output v-param-list
          ,output v-param-type).
 
          
      /*                 Если у нас уже были атрибуты - отобразим их*/
      if v-param-list <> ""  then 
      do:
        v-directory  = v-param-list no-error.
      end.  
      display v-directory  with frame {&FRAME-NAME}.  
      ENABLE
      B-save
      b-quit
      B-Help
      b-dir-sel
      v-directory
      WITH FRAME {&frame-name}.  
    end. /* when "shd" */
  end case.
END. /*doe*/
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :

VIEW FRAME {&frame-name}.
END PROCEDURE.

procedure wri-log-and-file :
    define input parameter p-log-string     as char       no-undo.

end procedure .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-save Dialog-Frame
PROCEDURE proc-save :

DEFINE VARIABLE v-param-list AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-file-name AS CHARACTER NO-UNDO.
define variable v-dop-file-name as character no-undo .
define variable v-obj-list as character no-undo .
define variable ii as integer   no-undo .
define variable c-dir-type as character no-undo .
define variable l-can-write as logical no-undo .
DEFINE VARIABLE v-other-param AS CHARACTER NO-UNDO.


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
    
RUN verify-file in this-procedure
                                  ( input v-directory
                                  , input substitute("Не найден каталог &1"
                                                , v-directory)
                                  ,input no
                                  ,output glog) no-error.
if error-status:error or not glog then return error return-value .
/*проверим save*/

if index( file-info:file-type, "W" ) = 0  then do:
  message
  'Вы не имеете права писать в выбранную директорию: '
  v-directory view-as alert-box error.
  return error.
end.


  v-param-list = v-directory.

  run attach-attr-to-schedule-line in this-procedure ( INPUT v-param-list ).

  run schedule-attr-write in this-procedure (input p-cre-db-num, 
                                             input p-task-type,
                                             input p-task-num,
                                             input {&attr-schedule-obj-list-h},
                                             input v-obj-list).
 
  

  message "Параметры сохранены!" view-as alert-box information.



END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

