&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME f-pl-level-mm


/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE tt-code NO-UNDO LIKE Code
       field status-name as character.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS f-pl-level-mm 
/*

$Revision: $
$Author: $
$Date: $
$Workfile: $
$Archive: $

Код сезонов ДТ

Автор: Ростовцев Александр
Дата создания: 08/02/24
Author: Rostovtsev Aleksandr
Creation date: 08/02/24

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter Parparentproc as handle    no-undo.
define input parameter p-obj-type  like ub.pl-level-mm.obj-type no-undo.
define input parameter p-obj-code  like ub.pl-level-mm.obj-code no-undo.
define input parameter p-pl-code   like ub.pl-level-mm.pl-code  no-undo.
define input parameter imode         as character               no-undo.

define variable vss-revision    as character no-undo init "$Revision: $":U .
define variable vss-author      as character no-undo init "$Author: $":U .
define variable vss-date        as character no-undo init "$Date: $":U .
define variable vss-workfile    as character no-undo init "$Workfile: $":U .
define variable vss-archive     as character no-undo init "$Archive: $":U .
define variable vss-description as character no-undo init "Код сезонов ДТ".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ adm/auto-def.i new}
{ str/auto2dia.i }
{ cmp/showinf.i }
{ cmp/r-pril.i new }
{ gbl/cur-time.i }
{ gbl/sys-time.i }
{ gbl/getcntxt.i def }
{ gbl/prn-lib.i }
{ gbl/waitfram.i }
{ cmp/mrk-strf.i }

/* Local Variable Definitions ---                                       */

define variable isUpdate            as logical no-undo init no.
define variable v-chk-act-host-code as integer no-undo.
define variable ri                  as recid   no-undo.
define variable isRights            as logical no-undo.
define variable v-new               as logical no-undo init no .
define variable v-ok                as logical no-undo .
define buffer buf_pl-level-mm for ub.pl-level-mm.
define buffer buf_place       for ub.place.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME f-pl-level-mm
&Scoped-define BROWSE-NAME br-pl-level-mm

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES buf_pl-level-mm

/* Definitions for BROWSE br-pl-level-mm                                */
&Scoped-define FIELDS-IN-QUERY-br-pl-level-mm buf_pl-level-mm.zone buf_pl-level-mm.min-level buf_pl-level-mm.max-level buf_pl-level-mm.level buf_pl-level-mm.capacity   
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-pl-level-mm   
&Scoped-define SELF-NAME br-pl-level-mm
&Scoped-define QUERY-STRING-br-pl-level-mm FOR EACH buf_pl-level-mm NO-LOCK   WHERE buf_pl-level-mm.obj-type = p-obj-type     and buf_pl-level-mm.obj-code = p-obj-code     and buf_pl-level-mm.pl-code = p-pl-code   BY buf_pl-level-mm.zone BY buf_pl-level-mm.level
&Scoped-define OPEN-QUERY-br-pl-level-mm OPEN QUERY {&SELF-NAME} FOR EACH buf_pl-level-mm NO-LOCK   WHERE buf_pl-level-mm.obj-type = p-obj-type     and buf_pl-level-mm.obj-code = p-obj-code     and buf_pl-level-mm.pl-code = p-pl-code   BY buf_pl-level-mm.zone BY buf_pl-level-mm.level.
&Scoped-define TABLES-IN-QUERY-br-pl-level-mm buf_pl-level-mm
&Scoped-define FIRST-TABLE-IN-QUERY-br-pl-level-mm buf_pl-level-mm


/* Definitions for DIALOG-BOX f-pl-level-mm                             */
&Scoped-define OPEN-BROWSERS-IN-QUERY-f-pl-level-mm ~
    ~{&OPEN-QUERY-br-pl-level-mm}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-add b-upd b-del b-load b-clear ~
b-help br-pl-level-mm 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-add 
     LABEL "&Добавить":L 
     SIZE 12 BY 1.

DEFINE BUTTON b-clear 
     LABEL "&Очистить":L 
     SIZE 12 BY .95.

DEFINE BUTTON b-del 
     LABEL "&Удалить":L 
     SIZE 12 BY 1.

DEFINE BUTTON b-exit AUTO-GO 
     LABEL "&Выход ":L 
     SIZE 10 BY 1.

DEFINE BUTTON b-help 
     LABEL "Помо&щь" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-load 
     LABEL "&Загрузить":L 
     SIZE 12 BY 1.

DEFINE BUTTON b-upd 
     LABEL "&Изменить":L 
     SIZE 12 BY 1.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-pl-level-mm FOR 
      buf_pl-level-mm SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-pl-level-mm
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-pl-level-mm f-pl-level-mm _FREEFORM
  QUERY br-pl-level-mm DISPLAY
      buf_pl-level-mm.zone COLUMN-LABEL "Номер пояса" FORMAT ">>>>>>9":U
  buf_pl-level-mm.min-level COLUMN-LABEL "Нижний уровень,см" FORMAT ">>>>>>9":U
  buf_pl-level-mm.max-level COLUMN-LABEL "Верхний уровень,см" FORMAT ">>>>>>9":U
  buf_pl-level-mm.level COLUMN-LABEL "Уровень,мм" FORMAT ">>>>>>9":U
  buf_pl-level-mm.capacity COLUMN-LABEL "Поясная вместимость, л" FORMAT ">>>>>>9":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH SEPARATORS SIZE 83 BY 14.38 ROW-HEIGHT-CHARS .62.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME f-pl-level-mm
     b-exit AT ROW 1.24 COL 2.6
     b-add AT ROW 1.24 COL 13.6
     b-upd AT ROW 1.24 COL 25.6
     b-del AT ROW 1.24 COL 37.6 WIDGET-ID 2
     b-load AT ROW 1.24 COL 49.6 WIDGET-ID 22
     b-clear AT ROW 1.24 COL 61.6 WIDGET-ID 6
     b-help AT ROW 1.24 COL 75.6 WIDGET-ID 24
     br-pl-level-mm AT ROW 2.43 COL 1
     SPACE(1.99) SKIP(0.80)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Таблица поясов для резервуара":L.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Temp-Tables and Buffers:
      TABLE: tt-code T "?" NO-UNDO ub Code
      ADDITIONAL-FIELDS:
          field status-name as character
      END-FIELDS.
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX f-pl-level-mm
   FRAME-NAME                                                           */
/* BROWSE-TAB br-pl-level-mm b-help f-pl-level-mm */
ASSIGN 
       FRAME f-pl-level-mm:SCROLLABLE       = FALSE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-pl-level-mm
/* Query rebuild information for BROWSE br-pl-level-mm
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH buf_pl-level-mm NO-LOCK
  WHERE buf_pl-level-mm.obj-type = p-obj-type
    and buf_pl-level-mm.obj-code = p-obj-code
    and buf_pl-level-mm.pl-code = p-pl-code
  BY buf_pl-level-mm.zone BY buf_pl-level-mm.level.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE br-pl-level-mm */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */


&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit Dialog-Frame
ON CHOOSE OF b-exit IN FRAME f-pl-level-mm /* Выход */
    DO:
        if AVAILABLE (buf_pl-level-mm) and isUpdate then
        do:
          if v-new
          then do :
            message "Внимание! После подтверждения завершения работы по вводу данных дальнейшая корректировка таблицы поясов резервуара будет возможна только в ИС УРТ. Подтвердите завершение работы!"
            view-as alert-box question buttons yes-no update v-ok .
            if not v-ok
            then do :
              return no-apply .
            end .
          end .
          
          /*запуск машины правил для выгрузки резервуара*/
            { gbl/rum-runa.i
            ?
            this-procedure:handle
            ?
            {&thref-proc_ref-event}
            " buffer buf_pl-level-mm:handle "
            " buffer buf_pl-level-mm:handle "
            ''
            ''
            no-error
            }
            if error-status :error
                then
            do:
                message
                    error-status:get-message(1) skip
                    return-value
                    view-as alert-box error .

                return no-apply .
            end.
        end.
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-add f-pl-level-mm
ON CHOOSE OF b-add IN FRAME f-pl-level-mm /* Добавить */
DO:
   ri = ?.
   run ref/pl-level-mm-frm.w (input parparentproc
                            , p-obj-type
                            , p-obj-code
                            , p-pl-code
                            , buf_place.loc1
                            , input {&add-def}
                            , input-output ri).
   run refreshbrowse.
   isUpdate = yes.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-clear
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-clear f-pl-level-mm
ON CHOOSE OF b-clear IN FRAME f-pl-level-mm /* Очистить */
DO:
  define buffer b_pl-level-mm for ub.pl-level-mm.
  define variable v-ok as logical no-undo.
   
  if not avail buf_pl-level-mm then return no-apply.
   
  message 
    "Удалить все записи для выбранного резервуара?"
    view-as alert-box question
    BUTTONS yes-no
    TITLE "Подтвердить"
    UPDATE v-ok .
  if not v-ok then return no-apply.
  _DEL:
  do transaction 
     on error undo _DEL, return
     on stop undo _DEL, return:
    for each b_pl-level-mm where 
             b_pl-level-mm.obj-type = p-obj-type
         and b_pl-level-mm.obj-code = p-obj-code
         and b_pl-level-mm.pl-code = p-pl-code
         exclusive-lock:
      delete b_pl-level-mm no-error.
      if error-status:error then
      do:
        message
           return-value skip
           "Очищение отменено."
           view-as alert-box.
        undo _DEL, return.         
      end.
    end.
    run refreshbrowse.
    isUpdate = yes.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-del f-pl-level-mm
ON CHOOSE OF b-del IN FRAME f-pl-level-mm /* Удалить */
DO:
  define buffer b_pl-level-mm for ub.pl-level-mm.
  define variable v-ok as logical no-undo.
   
  if not avail buf_pl-level-mm then return no-apply.
   
  message 
    "Удалить запись?"
    view-as alert-box question
    BUTTONS yes-no
    TITLE "Подтвердить"
    UPDATE v-ok .
  if not v-ok then return no-apply.
  do on error undo, return
  on stop undo, return:
    find first b_pl-level-mm where recid(b_pl-level-mm) = recid(buf_pl-level-mm) exclusive-lock no-error.
    if avail b_pl-level-mm then
    do:
      delete b_pl-level-mm no-error.
      if error-status:error then
      do:
      message
         return-value
         view-as alert-box.
         return no-apply.
      end.
      ri = ?.
      run refreshbrowse.
      isUpdate = yes.
    end.
    else do:
      message
        "Запись занята другим пользователем?" skip
        "Попробуйте позже."
         view-as alert-box.
    end.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-load
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-load f-pl-level-mm
ON CHOOSE OF b-load IN FRAME f-pl-level-mm /* Загрузить */
DO:
  define variable fileImport as character no-undo .
  define variable isOk       as logical   no-undo .
  
  define buffer bf_pl-level-mm for ub.pl-level-mm.
  
  if can-find(first bf_pl-level-mm where 
                  bf_pl-level-mm.obj-type = p-obj-type
              and bf_pl-level-mm.obj-code = p-obj-code
              and bf_pl-level-mm.pl-code  = p-pl-code) then
  do:
    message "Для резервуара уже есть данные поясной вместимости." skip
            "Для загрузки новых данных очистите таблицу."
            view-as alert-box message
            buttons ok
            title "Ошибка импорта".
    return no-apply.  
  end.
  
  system-dialog get-file fileImport
    filters "Файл импорта (*.txt,*.xlsx)" "*.txt;*.xlsx"
    title "Выберите имя файла для импорта"
    update isOk
  .
  
  if isOk and fileImport <> "" then 
  do: 
    case entry(num-entries(fileImport,"."),fileImport,"."):
      when "txt" then
      do:
        run importTxt in this-procedure (fileImport) no-error.
      end.
      when "xlsx" then
      do:
        run importExcel in this-procedure (fileImport) no-error.
      end.
      otherwise 
      do:
        return-value = "Неизвестный формат файла!". 
      end.
    end case.

    if error-status:error or return-value <> "" then
    do:
      message error-status:get-message(1)
              return-value
              view-as alert-box message
              buttons ok
              title "Ошибка импорта".
      return no-apply.
    end.
  end.
  else do:
    return no-apply. 
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-upd
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-upd f-pl-level-mm
ON CHOOSE OF b-upd IN FRAME f-pl-level-mm /* Изменить */
DO:
   ri = recid(buf_pl-level-mm).
   run ref/pl-level-mm-frm.w (
                            input parparentproc
                            , p-obj-type
                            , p-obj-code
                            , p-pl-code
                            , buf_place.loc1
                            , input if replace(b-upd:label,"&","") = "Изменить" 
                                    then {&update} else {&lookup}
                            , input-output ri).

   run refreshbrowse.
   isUpdate = yes.
   
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-pl-level-mm
&Scoped-define SELF-NAME br-pl-level-mm
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-pl-level-mm f-pl-level-mm
ON RETURN OF br-pl-level-mm IN FRAME f-pl-level-mm
DO:
    apply "DEFAULT-ACTION":U to self.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK f-pl-level-mm 


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
  THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

{ gbl/app_help.i }

/* Add Trigger to equate WINDOW-CLOSE to END-ERROR                      */
ON WINDOW-CLOSE OF FRAME {&frame-name} /* Градуировочная таблица */
DO:
  if AVAILABLE (buf_pl-level-mm) and isUpdate then
  do:
    if v-new
    then do :
      message "Внимание! После подтверждения завершения работы по вводу данных дальнейшая корректировка таблицы поясов резервуара будет возможна только в ИС УРТ. Подтвердите завершение работы!"
      view-as alert-box question buttons yes-no update v-ok .
      if not v-ok
      then do :
        return no-apply .
      end .
    end .
    
    /*запуск машины правил для выгрузки резервуара*/
      { gbl/rum-runa.i
      ?
      this-procedure:handle
      ?
      {&thref-proc_ref-event}
      " buffer buf_pl-level-mm:handle "
      " buffer buf_pl-level-mm:handle "
      ''
      ''
      no-error
      }
      if error-status :error
          then
      do:
          message
              error-status:get-message(1) skip
              return-value
              view-as alert-box error .

          return no-apply .
      end.
  end.
  APPLY "END-ERROR":U TO SELF.
END.

on "ESC" ANYWHERE do:
  if AVAILABLE (buf_pl-level-mm) and isUpdate then
  do:
    if v-new
    then do :
      message "Внимание! После подтверждения завершения работы по вводу данных дальнейшая корректировка таблицы поясов резервуара будет возможна только в ИС УРТ. Подтвердите завершение работы!"
      view-as alert-box question buttons yes-no update v-ok .
      if not v-ok
      then do :
        return no-apply .
      end .
    end .
    
    /*запуск машины правил для выгрузки резервуара*/
      { gbl/rum-runa.i
      ?
      this-procedure:handle
      ?
      {&thref-proc_ref-event}
      " buffer buf_pl-level-mm:handle "
      " buffer buf_pl-level-mm:handle "
      ''
      ''
      no-error
      }
      if error-status :error
          then
      do:
          message
              error-status:get-message(1) skip
              return-value
              view-as alert-box error .

          return no-apply .
      end.
  end.
end.

on "F2" ANYWHERE do:
  if AVAILABLE (buf_pl-level-mm) and isUpdate then
  do:
    if v-new
    then do :
      message "Внимание! После подтверждения завершения работы по вводу данных дальнейшая корректировка таблицы поясов резервуара будет возможна только в ИС УРТ. Подтвердите завершение работы!"
      view-as alert-box question buttons yes-no update v-ok .
      if not v-ok
      then do :
        return no-apply .
      end .
    end .
    
    /*запуск машины правил для выгрузки резервуара*/
      { gbl/rum-runa.i
      ?
      this-procedure:handle
      ?
      {&thref-proc_ref-event}
      " buffer buf_pl-level-mm:handle "
      " buffer buf_pl-level-mm:handle "
      ''
      ''
      no-error
      }
      if error-status :error
          then
      do:
          message
              error-status:get-message(1) skip
              return-value
              view-as alert-box error .

          return no-apply .
      end.
  end.
end.
/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
  ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

  { gbl/getcntxt.i get }

  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_place-reference_work':U
    {&cntxt-object}
    v-chk-act-host-code
    p-obj-type
    p-obj-code
    0
    0
    0
    false
    isRights
  }

   find first buf_place where 
              buf_place.obj-type = p-obj-type
          and buf_place.obj-code = p-obj-code
          and buf_place.pl-code  = p-pl-code
        no-lock no-error.
   FRAME f-pl-level-mm:TITLE = SUBSTITUTE  ( "&1 &2 (&3) &4 &5"
                                             , FRAME f-pl-level-mm:TITLE
                                             , p-pl-code
                                             , buf_place.loc1
                                             , p-obj-code
                                             , p-obj-type
                                             ).

  run enable_UI in this-procedure .
  
  find first buf_pl-level-mm where 
             buf_pl-level-mm.obj-type = p-obj-type
         and buf_pl-level-mm.obj-code = p-obj-code
         and buf_pl-level-mm.pl-code = p-pl-code
       no-lock no-error.
  if available buf_pl-level-mm
  then do :
    disable
      b-load b-add b-upd b-del b-clear
    WITH FRAME {&frame-name} .
  end .

  WAIT-FOR GO OF FRAME {&FRAME-NAME} focus {&browse-name}.
END.
run disable_UI in this-procedure .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI f-pl-level-mm  _DEFAULT-DISABLE
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
  HIDE FRAME f-pl-level-mm.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI f-pl-level-mm 
PROCEDURE enable_UI :
/* --------------------------------------------------------------------
        Purpose:     ENABLE the User Interface
        Parameters:  <none>
        Notes:       Here we display/view/enable the widgets in the
                     user-interface.  In addition, OPEN all queries
                     associated with each FRAME and BROWSE.
                     These statements here are based on the "Other
                     Settings" section of the widget Property Sheets.
         -------------------------------------------------------------------- */
  define buffer b_pl-level-mm for ub.pl-level-mm.

  find first b_pl-level-mm where 
             b_pl-level-mm.obj-type = p-obj-type
         and b_pl-level-mm.obj-code = p-obj-code
         and b_pl-level-mm.pl-code = p-pl-code
       no-lock no-error.
  
  ENABLE
    br-pl-level-mm
    b-exit
    b-help
    b-load WHEN imode eq {&update} and isRights
    b-add WHEN imode eq {&update} and isRights
    b-upd when avail b_pl-level-mm
    b-del when imode eq {&update} and isRights
    b-clear when imode eq {&update} and isRights
    WITH FRAME {&frame-name}
  .

  if not avail b_pl-level-mm then do:
    disable
      b-upd
      b-del
      b-clear WITH FRAME {&frame-name}
    .
    assign v-new = yes .
    ri = ?.
  end.
  
  if imode = {&lookup} or not isRights then do:
    b-upd:label = "Просмотр".
  end.
  
  {&OPEN-BROWSERS-IN-QUERY-f-pl-level-mm}
  
  if ri <> ? then
    reposition br-pl-level-mm to recid ri.
  else if avail b_pl-level-mm then 
    reposition br-pl-level-mm to row 1.
  
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE importExcel f-pl-level-mm 
PROCEDURE importExcel :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
define input parameter fileImport as character no-undo.

define variable mExcelApplication as component-handle no-undo. /* ССЫЛКА НА ПРИЛОЖЕНИЕ */
define variable mWorkBook         as component-handle no-undo. /* ССЫЛКА НА РАБОЧУЮ КНИГУ */
define variable mWorkSheet        as component-handle no-undo. /* ССЫЛКА НА РАБОЧИЙ ЛИСТ */

define variable cntLine           as integer   no-undo.
define variable vLine             as character no-undo.
define variable vErr              as character no-undo.

define variable vZone             like ub.pl-level-mm.zone no-undo.
define variable vMinLevel         like ub.pl-level-mm.min-level no-undo.
define variable vMaxLevel         like ub.pl-level-mm.max-level no-undo.
define variable vLevel            like ub.pl-level-mm.level no-undo.
define variable vCapacity         as   decimal              no-undo extent 9.

define buffer b_pl-level-mm for ub.pl-level-mm.

create "Excel.Application":U mExcelApplication no-error.
if error-status :error then 
do:
 return error "Ошибка при запуске Excel".
end.    

ASSIGN
 mExcelApplication:DisplayAlerts = NO
 mWorkbook                       = mExcelApplication:WorkBooks:Add(fileImport)
 mWorkSheet                      = mWorkbook:Sheets:Item(1)
.

if trim(mWorkSheet:Range("A1"):VALUE) <> "№ пояса" or
   trim(mWorkSheet:Range("A2"):VALUE) = "" then
do:
  return error "В выбранном файле нет таблиц поясов.~nТаблицы не загружены.".
end.

cntLine = 2.
IMP:
do transaction on error undo IMP, leave IMP:
  repeat:
    assign
      vLine        = string(cntLine)
      vZone        = mWorkSheet:Range("A" + vLine):VALUE
      vMinLevel    = mWorkSheet:Range("B" + vLine):VALUE
      vMaxLevel    = mWorkSheet:Range("C" + vLine):VALUE
      vCapacity[1] = mWorkSheet:Range("D" + vLine):VALUE
      vCapacity[2] = mWorkSheet:Range("E" + vLine):VALUE
      vCapacity[3] = mWorkSheet:Range("F" + vLine):VALUE
      vCapacity[4] = mWorkSheet:Range("G" + vLine):VALUE
      vCapacity[5] = mWorkSheet:Range("H" + vLine):VALUE
      vCapacity[6] = mWorkSheet:Range("I" + vLine):VALUE
      vCapacity[7] = mWorkSheet:Range("J" + vLine):VALUE
      vCapacity[8] = mWorkSheet:Range("K" + vLine):VALUE
      vCapacity[9] = mWorkSheet:Range("L" + vLine):VALUE
    no-error.
  
    if error-status:error then
    do:
      vErr = "Ошибка при чтении строки: " + error-status:get-message(1).
      undo IMP, leave IMP.
    end.

   find first b_pl-level-mm where 
              b_pl-level-mm.obj-type  = p-obj-type
          and b_pl-level-mm.obj-code  = p-obj-code
          and b_pl-level-mm.pl-code   = p-pl-code
          and ((b_pl-level-mm.min-level = vMinLevel and
                b_pl-level-mm.max-level = vMaxLevel) or
               (b_pl-level-mm.min-level <= vMinLevel and
                b_pl-level-mm.max-level >= vMinLevel and
                b_pl-level-mm.zone <> vZone) or
               (b_pl-level-mm.min-level <= vMaxLevel and
                b_pl-level-mm.max-level >= vMaxLevel and
                b_pl-level-mm.zone <> vZone))
        no-lock no-error.
    if avail b_pl-level-mm then
    do:
      vErr = substitute(
        "Найдено пересечение поясов № &1 и № &2 по уровню пояса &3. Сохранение невозможно!~n",
        b_pl-level-mm.zone, vZone, b_pl-level-mm.max-level)
      .
      undo IMP, leave IMP.
    end.  

  
    if vZone = ? and vMinLevel = ? and vMaxLevel = ? then
      leave IMP.
  
    do vLevel = 1 to 9:
      create b_pl-level-mm.
      assign
        b_pl-level-mm.obj-type  = p-obj-type
        b_pl-level-mm.obj-code  = p-obj-code
        b_pl-level-mm.pl-code   = p-pl-code
        b_pl-level-mm.zone      = vZone
        b_pl-level-mm.min-level = vMinLevel
        b_pl-level-mm.max-level = vMaxLevel
        b_pl-level-mm.level     = vLevel
        b_pl-level-mm.capacity  = round(vCapacity[vLevel] * 1000, 0)
      no-error.
  
      if not error-status:error then
        validate b_pl-level-mm no-error.
      if error-status:error then
      do:
        vErr = "Ошибка при записи в БД: " + error-status:get-message(1).
        undo IMP, leave IMP.
      end.
    end.
    cntLine = cntLine + 1.
  end.
end.

mExcelApplication:Quit().
release object mExcelApplication.

if vErr = "" then 
do:
  run refreshbrowse in this-procedure.
  isUpdate = yes.
end.
else
  return error vErr.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE importTxt f-pl-level-mm 
PROCEDURE importTxt :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
  define input parameter fileImport as character no-undo.
  define variable cnt       as integer   no-undo.
  define variable strImp    as character no-undo.
  define variable strErr    as character no-undo.
  define variable delim     as character no-undo.
  define buffer buf_pl-level-mm for ub.pl-level-mm.
  define buffer buf_place       for ub.place .

  define variable v-user-name            as character no-undo .
  define variable v-computer-name        as character no-undo .
  define variable v-computer-login-name  as character no-undo .
  define variable v-computer-process-pid as integer   no-undo .
  define variable v-list-rates           as character no-undo.
  define variable v-exist-pl-code        as logical   no-undo init no.

  find first buf_place where 
             buf_place.obj-type = p-obj-type
         and buf_place.obj-code = p-obj-code
         and buf_place.pl-code  = p-pl-code
       no-lock no-error.
  
  input from value(search(fileImport)).
  IMP:
  do transaction on error undo IMP, leave IMP:
    repeat:
      strErr = "".
      import unformatted strImp no-error.
      if strImp = "" then next.
      if delim = "" then
      do:
        if index(strImp," ") > 0 then
          delim = " ".
        else if index(strImp,{&tabulation}) > 0 then
          delim = {&tabulation}.
      end.
      if delim = "" or num-entries(strImp,delim) <> 6 then 
        strErr = "Неверный формат строки. Должно быть 6 атрибутов~n".
  
      if strErr = "" and buf_place.loc1 = entry(1,strImp,delim) then
      do:
          v-exist-pl-code = yes.
          find first buf_pl-level-mm where 
                     buf_pl-level-mm.obj-type  = p-obj-type
                 and buf_pl-level-mm.obj-code  = p-obj-code
                 and buf_pl-level-mm.pl-code   = p-pl-code
                 and ((buf_pl-level-mm.min-level = dec(entry(3,strImp,delim)) and
                       buf_pl-level-mm.max-level = dec(entry(4,strImp,delim)) and
                       buf_pl-level-mm.level     = int(entry(5,strImp,delim))) or
                      (buf_pl-level-mm.min-level <= dec(entry(3,strImp,delim)) and
                       buf_pl-level-mm.max-level >= dec(entry(3,strImp,delim)) and
                       buf_pl-level-mm.zone <> int(entry(2,strImp,delim))) or
                      (buf_pl-level-mm.min-level <= dec(entry(4,strImp,delim)) and
                       buf_pl-level-mm.max-level >= dec(entry(4,strImp,delim)) and
                       buf_pl-level-mm.zone <> int(entry(2,strImp,delim))))
               no-lock no-error.
          if avail buf_pl-level-mm then
          do:
            strErr = strErr + substitute(
              "Найдено пересечение поясов № &1 и № &2 по уровню пояса &3. Сохранение невозможно!~n",
              buf_pl-level-mm.zone, entry(2,strImp,delim), buf_pl-level-mm.max-level)
            .
          end.
      
          if strErr = "" then 
          do:
            create buf_pl-level-mm.
            assign
              buf_pl-level-mm.obj-type  = p-obj-type
              buf_pl-level-mm.obj-code  = p-obj-code
              buf_pl-level-mm.pl-code   = p-pl-code
              buf_pl-level-mm.zone      = int(entry(2,strImp,delim))
              buf_pl-level-mm.min-level = dec(entry(3,strImp,delim))
              buf_pl-level-mm.max-level = dec(entry(4,strImp,delim))
              buf_pl-level-mm.level     = int(entry(5,strImp,delim))
              buf_pl-level-mm.capacity = dec(entry(6,strImp,delim)) * 1000
            no-error.
            if error-status:error then
              strErr = error-status:get-message(1).
            validate buf_pl-level-mm no-error.
            if error-status:error then
              strErr = error-status:get-message(1).
          end. 
      end.
  
      if strErr <> "" then do:
        undo IMP, leave IMP.
      end.
    end.
  end.
  input close.
  
  strErr = right-trim(StrErr,"~n").
  if strErr = "" then
  do:
    if v-exist-pl-code then
    do:   /* есть данные для выбранного резервуара и загрузили */
        run refreshbrowse in this-procedure.
        isUpdate = yes.
    end.
    else 
    do:
      strErr = substitute("В файле нет таблицы поясов для резервуара &1 &2 &3 (&4).~nТаблицы не загружены"
                          , p-obj-type
                          , p-obj-code
                          , p-pl-code
                          , buf_place.loc1).
      return error strErr.
    end.
  end.
  else
    return error strErr.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE refreshbrowse f-pl-level-mm 
PROCEDURE refreshbrowse :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
   run enable_UI.
   if avail buf_pl-level-mm then
     apply "ENTRY" to br-pl-level-mm in frame {&frame-name}.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

