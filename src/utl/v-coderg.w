&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME v-coderg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS v-coderg 
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Список диапазонов кодов

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/23/01
Author: Dmitry Ukhanov
Creation date: 03/23/01

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter p-db-num     like ub.code-range.db-num     no-undo .
define input parameter p-range-type like ub.code-range.range-type no-undo .
define input parameter p-type-code  as   character                no-undo .

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Список диапазонов кодов".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i  }
{ gbl/key-rec.i  }
{ nws/db-rec.i }

define variable v-curr-db as integer no-undo .
define variable v-Ok      as logical no-undo .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME v-coderg
&Scoped-define BROWSE-NAME BROWSE-1

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES ub.code-range

/* Definitions for BROWSE BROWSE-1                                      */
&Scoped-define FIELDS-IN-QUERY-BROWSE-1 ub.code-range.first-code ~
ub.code-range.last-code ub.code-range.stts ub.code-range.PS 
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-1 
&Scoped-define QUERY-STRING-BROWSE-1 FOR EACH ub.code-range ~
      WHERE code-range.db-num = p-db-num ~
 AND code-range.range-type = p-range-type NO-LOCK ~
    BY ub.code-range.first-code
&Scoped-define OPEN-QUERY-BROWSE-1 OPEN QUERY BROWSE-1 FOR EACH ub.code-range ~
      WHERE code-range.db-num = p-db-num ~
 AND code-range.range-type = p-range-type NO-LOCK ~
    BY ub.code-range.first-code.
&Scoped-define TABLES-IN-QUERY-BROWSE-1 ub.code-range
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-1 ub.code-range


/* Definitions for DIALOG-BOX v-coderg                                  */
&Scoped-define OPEN-BROWSERS-IN-QUERY-v-coderg ~
    ~{&OPEN-QUERY-BROWSE-1}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit b-viewcode b-crush b-del b-help ~
BROWSE-1 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-crush DEFAULT 
     LABEL "&Разбить" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-del 
     LABEL "&Удалить" 
     SIZE 10 BY 1.

DEFINE BUTTON b-help DEFAULT 
     LABEL "Помо&щь" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-quit AUTO-GO DEFAULT 
     LABEL "&Выход" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-viewcode DEFAULT 
     LABEL "&Коды" 
     SIZE 10 BY 1
     BGCOLOR 8 .

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BROWSE-1 FOR 
      ub.code-range SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BROWSE-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-1 v-coderg _STRUCTURED
  QUERY BROWSE-1 DISPLAY
      ub.code-range.first-code FORMAT ">,>>>,>>>,>>9":U
      ub.code-range.last-code FORMAT ">,>>>,>>>,>>9":U
      ub.code-range.stts COLUMN-LABEL "Ст." FORMAT "X(3)":U
      ub.code-range.PS FORMAT "X(50)":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 83.8 BY 17.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME v-coderg
     b-quit AT ROW 1.27 COL 2
     b-viewcode AT ROW 1.27 COL 12
     b-crush AT ROW 1.27 COL 22
     b-del AT ROW 1.27 COL 32 WIDGET-ID 2
     b-help AT ROW 1.27 COL 75.8
     BROWSE-1 AT ROW 2.57 COL 2
     SPACE(1.69) SKIP(0.42)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Диапазоны кодов"
         CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX v-coderg
   FRAME-NAME                                                           */
/* BROWSE-TAB BROWSE-1 b-help v-coderg */
ASSIGN 
       FRAME v-coderg:SCROLLABLE       = FALSE
       FRAME v-coderg:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-1
/* Query rebuild information for BROWSE BROWSE-1
     _TblList          = "ub.code-range"
     _OrdList          = "ub.code-range.first-code|yes"
     _Where[1]         = "code-range.db-num = p-db-num
 AND code-range.range-type = p-range-type"
     _FldNameList[1]   = ub.code-range.first-code
     _FldNameList[2]   = ub.code-range.last-code
     _FldNameList[3]   > ub.code-range.stts
"code-range.stts" "Ст." "X(3)" "character" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[4]   = ub.code-range.PS
     _Query            is OPENED
*/  /* BROWSE BROWSE-1 */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX v-coderg
/* Query rebuild information for DIALOG-BOX v-coderg
     _Options          = "SHARE-LOCK"
     _Query            is NOT OPENED
*/  /* DIALOG-BOX v-coderg */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME v-coderg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-coderg v-coderg
ON WINDOW-CLOSE OF FRAME v-coderg /* Диапазоны кодов */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-crush
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-crush v-coderg
ON CHOOSE OF b-crush IN FRAME v-coderg /* Разбить */
DO:

  define variable v-log            as logical   no-undo .
  define variable v-cfg-param-code as character no-undo .
  define variable v-length-new     as integer   no-undo .
  define variable v-key-rec        as character no-undo .
  define variable v-param          as character no-undo .
  define variable v-rowid          as rowid     no-undo .
  define variable v-param-type{&vssseq} as character no-undo .
  define variable v-value-character{&vssseq} as INTEGER no-undo .
  define variable v-value-date{&vssseq} as date no-undo .
  define variable v-value-decimal{&vssseq} as decimal no-undo .
  define variable v-value-logical{&vssseq} AS LOGICAL no-undo .
  define variable v-tth{&vssseq} as handle no-undo .


  if not available ub.code-range then do:
    message
      "Необходимо выбрать диапазон!"
      view-as alert-box error.
    return no-apply.
  end.

  if ub.code-range.stts = "a":U then do:
    message
      "Нельзя дробить активный диапазон!"
      view-as alert-box error.
    return no-apply.
  end.

  message
    "Вы действительно хотите разбить диапазон" skip
    substitute( "c &1 по &2", ub.code-range.first-code, ub.code-range.last-code )
    view-as alert-box question buttons yes-no update v-log.
  if v-log <> true then do:
    return no-apply.
  end.


  assign
    v-cfg-param-code = "":U
  .

  run trg/getpcode.p ( input  ub.code-range.range-type
                 ,output v-cfg-param-code
                ) no-error .
  if error-status :error
    or v-cfg-param-code = "":U
    or v-cfg-param-code = ?
  then do:
    message
      vss-workfile vss-revision vss-description skip
      substitute( "Ошибка при определении имени параметра для диапазона &1", ub.code-range.range-type ) skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    return no-apply .
  end.
  run adm/shattri.p (
      input "get":U
      ,input  {&db}
      ,input  ub.code-range.db-num
      ,input  {&attr-code-range}
      ,input  v-cfg-param-code /*p-param-code*/
      ,output v-value-character{&vssseq}
      ,output v-value-date{&vssseq}
      ,output v-value-decimal{&vssseq}
      ,output v-length-new
      ,output v-value-logical{&vssseq}
      ,output v-param-type{&vssseq}
      ,INPUT-OUTPUT table-handle v-tth{&vssseq}
      ) no-error .
  if error-status :error then do:
    delete object v-tth{&vssseq}.
    message
    vss-workfile vss-revision vss-description skip
    substitute( "Ошибка при чтении значения параметра &1", v-cfg-param-code ) skip
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
    return no-apply .
  end.
  delete object v-tth{&vssseq}.

  if v-length-new >= ( ub.code-range.last-code - ub.code-range.first-code + 1 )
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Новая длина диапазона(ов) должна быть меньше текущей" skip
      substitute( "новая длина (из конфигурационного параметра): &1", v-length-new ) skip
      substitute( "текущая длина диапазона: &1", ( ub.code-range.last-code - ub.code-range.first-code + 1 ) )
      view-as alert-box error .
    return no-apply.
  end.

  run gen-key-rec( input {&table_code-range}
                  ,input (buffer ub.code-range:handle )
                  ,output v-key-rec
                 ) no-error.
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при генерации уникального ключа для диапазона" skip
      substitute( "тип &1", ub.code-range.range-type ) skip
      substitute( "начало диапазона &1", ub.code-range.first-code ) skip
      return-value
      view-as alert-box error .
    return no-apply.
  end.

  assign
    v-Ok    = {&browse-name} :set-repositioned-row( {&browse-name} :focused-row, 'CONDITIONAL':u)
    v-rowid = rowid( ub.code-range )
    v-param = ub.code-range.range-type + {&delim-par}
              + string( ub.code-range.first-code ) + {&delim-par}
              + string( ub.code-range.last-code ) + {&delim-par}
              + string( v-length-new )
  .
  run nws/db-rec.p ( input "crush_code-range":U
                ,input v-key-rec
                ,input v-param
               ) no-error .
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при разбиении диапазона" skip
      substitute( "Тип &1", ub.code-range.range-type ) skip
      substitute( "Начало диапазона &1", ub.code-range.first-code ) skip
      return-value skip
      error-status :get-message(1)
      view-as alert-box error .
    return no-apply.
  end.
  if return-value <> "":U then do:
    message
      return-value
      view-as alert-box error .
    return no-apply.
  end.
  message
    "Операция разбиения диапазона начата" skip
    "Направлен запрос во все БД" skip
    "После получения положительного ответа диапазон будет разбит"
    view-as alert-box information.

  {&OPEN-BROWSERS-IN-QUERY-v-coderg}

  reposition {&browse-name} to rowid v-rowid .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-del v-coderg
ON CHOOSE OF b-del IN FRAME v-coderg /* Удалить */
DO:
  RUN proc-b-del IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-viewcode
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-viewcode v-coderg
ON CHOOSE OF b-viewcode IN FRAME v-coderg /* Коды */
DO:
  if not available ub.code-range then do:
    message
      "Необходимо выбрать диапазон!"
      view-as alert-box error.
    return no-apply.
  end.

  run utl/v-codes.w ( input ub.code-range.range-type
                 ,input ub.code-range.first-code
                 ,input p-type-code
                ) .

/*  {&OPEN-BROWSERS-IN-QUERY-v-coderg}*/

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BROWSE-1
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK v-coderg 


/* ***************************  Main Block  *************************** */

{ gbl/app_help.i }

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

  define buffer buf_sys-ctrl for ub.sys-ctrl .

  find first buf_sys-ctrl no-lock .
  assign
    v-curr-db = buf_sys-ctrl.db-num
  .

  if p-db-num = ? then do:
    assign
      p-db-num = 0
    .
    assign
      FRAME {&FRAME-NAME}:title = substitute( "Диапазоны &1 в БД &2", p-type-code, v-curr-db )
    .
  end.
  else do:
    assign
      FRAME {&FRAME-NAME}:title = substitute( "Диапазоны &1 для БД &2 в БД &3", p-type-code, p-db-num, v-curr-db )
    .
  end.

  RUN enable_UI.
  case p-range-type:
    when {&loc-sc-code}
    or when {&loc-pg-code} then do:
      if v-curr-db = 0 then do:
        enable
        b-del
        with frame {&frame-name} .
      end.
      else do:
        disable
        b-del
        with frame {&frame-name} .
      end.
    end.
    otherwise do:
      disable
      b-del
      with frame {&frame-name} .
    end.
  end case.

  WAIT-FOR GO OF FRAME {&FRAME-NAME} focus browse {&browse-name}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI v-coderg  _DEFAULT-DISABLE
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
  HIDE FRAME v-coderg.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI v-coderg  _DEFAULT-ENABLE
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
  ENABLE b-quit b-viewcode b-crush b-del b-help BROWSE-1 
      WITH FRAME v-coderg.
  VIEW FRAME v-coderg.
  {&OPEN-BROWSERS-IN-QUERY-v-coderg}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-del v-coderg
PROCEDURE proc-b-del :
define variable v-key-rec as character no-undo .
define variable glog as logical no-undo .
define variable v-param as character no-undo .
define variable v-rowid as rowid no-undo .
define buffer buf_code-range for ub.code-range.
define buffer buf_route for ub.route.
if not available ub.code-range then do:
  message
  "Не определен диапазон!"
  view-as alert-box error .
  undo, return error .
end.
v-rowid = rowid(ub.code-range).
find first buf_code-range share-lock where
      buf_code-range.first-code = ub.code-range.first-code no-error.
if not available buf_code-range then do:
  message
  substitute("Диапазон кодов с типом &1 для БД &2 (&3-&4) уже недоступен&5ОБНОВИТЕ ДАННЫЕ (выберите тип диапазона еще раз)"
             ,p-range-type
             ,ub.code-range.db-num
             ,ub.code-range.first-code
             ,ub.code-range.last-code
             , {&new-line}
             )
  view-as alert-box error .
  undo, return error .
end.
if not (p-db-num = buf_code-range.db-num
        and
        integer(ub.code-range.last-code:screen-value in browse browse-1) = buf_code-range.last-code) then do:
  message
  substitute("Диапазон кодов с типом &1 для БД &2 (&3-&4) уже изменился&5ОБНОВИТЕ ДАННЫЕ (выберите тип диапазона еще раз)"
             ,p-range-type
             ,ub.code-range.db-num
             ,ub.code-range.first-code
             ,ub.code-range.last-code
             , {&new-line}
             )
  view-as alert-box error .
  undo, return error .
end.

case p-range-type :
  when {&loc-sc-code}
  or when {&loc-pg-code} then do:
    run gen-key-rec in this-procedure  ( input {&table_code-range}
                                          ,input ( buffer buf_code-range:handle )
                                          ,output v-key-rec
                                        ) no-error.

    assign
    v-param = buf_code-range.range-type + {&delim-par}  +
              string(buf_code-range.first-code) + {&delim-par} +
              string(buf_code-range.last-code) + {&delim-par} +
              buf_code-range.stts + {&delim-par} +
              string(buf_code-range.db-num) + {&delim-par} +
              buf_code-range.ps
  .
  if v-curr-db > 0 then do:
      /*на всякий случай проверим нет ли уже команды на запуск two-commit*/
      find first buf_route no-lock where
                buf_route.name-rec = ("command":U + {&delim-nws}
                                      + "inquiry-two-commit":U + {&delim-nws}
                                      + {&delete_code-range} + {&delim-nws}
                                      + v-key-rec + {&delim-nws}
                                      + v-param) no-error.
      if available buf_route then do:
        message
        substitute("Команда <Запуск удаления диапазона с типом &1 для БД &2 (&3-&4) из ГБД> уже отослана"
                  , buf_code-range.range-type
                  , buf_code-range.db-num
                  , buf_code-range.first-code
                  , buf_code-range.last-code
                  )
        view-as alert-box warning.
        return .
      end.
    end.
    message
    substitute("Удалить диапазон с типом &1 для БД &2 (&3-&4)?"
                  , buf_code-range.range-type
                  , buf_code-range.db-num
                  , buf_code-range.first-code
                  , buf_code-range.last-code
                  ) skip(0)
  (if v-curr-db = 0
   then  substitute("(удаление будет проведено только после подтверждения от всех БД)")
   else  substitute("(Будет отослана в ГБД команда <Запуск удаления диапазона из ГБД>)")
   ) skip(0)
    view-as alert-box question buttons OK-Cancel update glog.
    if not glog then return.
    if can-find(first ub.db no-lock where ub.db.db-num > 0 ) then do:
      /*Теперь здесб будет стоять two-commit удаление*/
      run nws/db-rec.p ( input {&delete_code-range}
                    ,input v-key-rec
                    ,input v-param
                  ) no-error .
      if not error-status:error
      and return-value = "":U
      then do:
      end.
      else do:
        message
        "Не удается послать на все БД команду удаления диапазона" skip
        string(if error-status:error
        then (error-status:get-message(1) + {&new-line} + return-value )
        else return-value )
        view-as alert-box error .
      end.
    end. /*    if can-find(first ub.db no-lock where ub.db.db-num > 0 ) then do:*/
  end.
  otherwise do:
    message
    "НЕ РАЗРЕШЕНО УДАЛЕНИЕ ТАКИХ ДИАПАЗОНОВ!!!"
    view-as alert-box error .
    undo, return error .
  end.
end case.
{&OPEN-BROWSERS-IN-QUERY-v-coderg}

reposition {&browse-name} to rowid v-rowid .


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
