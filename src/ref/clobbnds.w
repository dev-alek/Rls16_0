&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER X_clob-bind FOR ub.clob-bind.
DEFINE BUFFER X_clob-data FOR ub.clob-data.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Список CLOB-DATA

Автор: Бахтадзе Наталья Викторовна
Дата создания: 07/11/09
Author: Bakhtadze Natalya
Creation date: 07/11/09

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO.
DEFINE INPUT PARAMETER p-parent-handle AS WIDGET-HANDLE NO-UNDO.
define input parameter bttns as character no-undo .
define input parameter p-list-mode as character no-undo.
/*бывает {&all} или "uniq-key-rec"*/
define input parameter p-mode as character no-undo.
/*бывает ""} или {&Update} - только для списков*/

define input parameter p-resource-type as character no-undo.
/*бывает {&lob-res-report} или {&lob-res-report-xml} или {&lob-res-list} или {&lob-res-list-macro} */
define input parameter p-uniq-key-rec as character no-undo.
/*бывает "" - для ответов или "gds-list"  или "cli-list" или "dc-list" или "obj-list" */

define input parameter p-db-num as integer no-undo.
define input-output  parameter p-rid-list as character no-undo .


/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Список CLOB-DATA".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/trg-def.i }
{ cmp/showinf.i }
{ gbl/getcntxt.i def }
{ cmp/tblfname.i }
{ gbl/cur-time.i }
{ nws/db-rec.i   }
{ gbl/usrfulnf.i }
{ trg/clbdattd.i }
{ gbl/key-rec.i }
{ cmp/mrk-strf.i }
{ gbl/flt-def.i  }
{ gbl/fltfield.i }
{ gbl/fltopend.i defproc }
{ cmp/cli-list.i cli-list def "new shared" }
{ cmp/dc-list.i dc-list def "new shared" }
{ cmp/gds-list.i gds-list def "new shared" }



define variable glog as logical no-undo .
define variable del-option as character no-undo.
define variable chg-option as character no-undo.
define variable v-start as logical no-undo init yes.
define variable v-rid-list as character no-undo .
define variable filter-point0 as character no-undo init "clobbnds" .
define variable filter-point as character no-undo INIT "clobbnds".
define variable filter-label as character no-undo INIT "".
define variable filter-label0 as character no-undo init "" .
define variable sort-column-name as character no-undo .
define variable v-rec as recid no-undo .
define variable v-list-proc-handle as handle no-undo .


&SCOPED-DEFINE sort-clmn_7 usrfulnf(X_clob-bind.user-name)
&SCOPED-DEFINE dyn_sort-clmn_7 substitute('dynamic-function(&1usrfulnf&1, X_clob-bind.user-name)', ~{&double-quote~})
&scoped-define label-clmn_7 'Создал'
&SCOPED-DEFINE sort-clmn_8 usrfulnf(X_clob-data.user-name)
&SCOPED-DEFINE dyn_sort-clmn_8 substitute('dynamic-function(&1usrfulnf&1, X_clob-data.user-name)', ~{&double-quote~})
&scoped-define label-clmn_8 'Изменил'

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br-clobs

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_clob-bind X_clob-data

/* Definitions for BROWSE br-clobs                                      */
&Scoped-define FIELDS-IN-QUERY-br-clobs mark-string( recid(X_clob-bind), v-rid-list ) X_clob-data.is-cs X_clob-bind.uniq-key-rec X_clob-bind.field-name_ X_clob-bind.descr X_clob-bind.part-num X_clob-bind.sys-date X_clob-bind.sys-time {&sort-clmn_7} X_clob-data.int64-id X_clob-data.file-size X_clob-data.sys-date X_clob-data.sys-time {&sort-clmn_8}
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-clobs X_clob-bind.descr
&Scoped-define ENABLED-TABLES-IN-QUERY-br-clobs X_clob-bind
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-br-clobs X_clob-bind
&Scoped-define SELF-NAME br-clobs
&Scoped-define QUERY-STRING-br-clobs FOR EACH X_clob-bind NO-LOCK where       X_clob-bind.resource-type = p-resource-type and       (p-db-num = -1 or X_clob-bind.db-num = p-db-num) and       X_clob-bind.int64-id > 0       , ~
             first X_clob-data NO-LOCK where       (X_clob-data.db-num = X_clob-bind.db-num   and X_clob-data.int64-id = X_clob-bind.int64-id )       INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-br-clobs OPEN QUERY {&SELF-NAME} FOR EACH X_clob-bind NO-LOCK where       X_clob-bind.resource-type = p-resource-type and       (p-db-num = -1 or X_clob-bind.db-num = p-db-num) and       X_clob-bind.int64-id > 0       , ~
             first X_clob-data NO-LOCK where       (X_clob-data.db-num = X_clob-bind.db-num   and X_clob-data.int64-id = X_clob-bind.int64-id )       INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-br-clobs X_clob-bind X_clob-data
&Scoped-define FIRST-TABLE-IN-QUERY-br-clobs X_clob-bind
&Scoped-define SECOND-TABLE-IN-QUERY-br-clobs X_clob-data


/* Definitions for DIALOG-BOX Dialog-Frame                              */

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit B-mark b-sel b-add b-chg b-lkp b-del ~
b-send B-sch B-Help mark-num br-clobs E-descr
&Scoped-Define DISPLAYED-OBJECTS mark-num E-descr

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Menu Definitions                                                     */
DEFINE MENU MENU-b-chg
       MENU-ITEM m_descr        LABEL "Описание"
       MENU-ITEM m_data         LABEL "Данные"        .


/* Definitions of the field level widgets                               */
DEFINE BUTTON b-add
     LABEL "&Добавить"
     SIZE 10 BY 1.

DEFINE BUTTON b-chg
     LABEL "&Изменить"
     SIZE 10 BY 1.

DEFINE BUTTON b-del
     LABEL "&Удалить"
     SIZE 10 BY 1.

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-lkp
     LABEL "Просмотр"
     SIZE 10 BY 1.

DEFINE BUTTON B-mark
     LABEL "&*"
     SIZE 3 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-sch
     LABEL "&Фильтр"
     SIZE 3 BY 1.

DEFINE BUTTON b-sel AUTO-GO
     LABEL "Вы&бор"
     SIZE 10 BY 1.

DEFINE BUTTON b-send
     LABEL "&Глоб."
     SIZE 10 BY 1 TOOLTIP "Пересылка по СПН - из ГБД во все УБД, из УБД в ГБД".

DEFINE VARIABLE E-descr AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 98 BY 2 NO-UNDO.

DEFINE VARIABLE mark-num AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 9 BY 1
     FGCOLOR 4  NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-clobs FOR
      X_clob-bind,
      X_clob-data SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-clobs
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-clobs Dialog-Frame _FREEFORM
  QUERY br-clobs NO-LOCK DISPLAY
      mark-string( recid(X_clob-bind), v-rid-list ) COLUMN-LABEL "*" FORMAT "X(1)":U
X_clob-data.is-cs column-label "Глоб" format "+/"
X_clob-bind.uniq-key-rec column-label "Тип" format "X(40)" width 20
X_clob-bind.field-name_ column-label "ID" format "X(22)"
X_clob-bind.descr column-label "Описание" format "X(255)" width 45
X_clob-bind.part-num column-label "№!файла" format ">9"
X_clob-bind.sys-date column-label "Дата" format "99/99/9999"
X_clob-bind.sys-time column-label "Время" format "X(8)"
{&sort-clmn_7} column-label {&label-clmn_7} format "X(8)"
X_clob-data.int64-id column-label "ID данных"
X_clob-data.file-size column-label "Длина файла"
X_clob-data.sys-date column-label "Дата!данных" format "99/99/9999"
X_clob-data.sys-time column-label "Время!данных" format "X(8)"
{&sort-clmn_8} column-label {&label-clmn_8} format "X(8)"
enable
X_clob-bind.descr
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 18.27 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-mark AT ROW 1 COL 11 WIDGET-ID 14
     b-sel AT ROW 1 COL 14 WIDGET-ID 16
     b-add AT ROW 1 COL 31 WIDGET-ID 2
     b-chg AT ROW 1 COL 41 WIDGET-ID 4
     b-lkp AT ROW 1 COL 51 WIDGET-ID 12
     b-del AT ROW 1 COL 61 WIDGET-ID 6
     b-send AT ROW 1 COL 71 WIDGET-ID 22
     B-sch AT ROW 1 COL 92 WIDGET-ID 20
     B-Help AT ROW 1 COL 95
     mark-num AT ROW 2 COL 1 NO-LABEL WIDGET-ID 18
     br-clobs AT ROW 3 COL 1 WIDGET-ID 100
     E-descr AT ROW 21.27 COL 1 NO-LABEL WIDGET-ID 10
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Список"
         CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: X_clob-bind B "?" ? ub clob-bind
      TABLE: X_clob-data B "?" ? ub clob-data
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB br-clobs mark-num Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN
       b-chg:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-b-chg:HANDLE.

/* SETTINGS FOR FILL-IN mark-num IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-clobs
/* Query rebuild information for BROWSE br-clobs
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH X_clob-bind NO-LOCK where
      X_clob-bind.resource-type = p-resource-type and
      (p-db-num = -1 or X_clob-bind.db-num = p-db-num) and
      X_clob-bind.int64-id > 0
      ,
      first X_clob-data NO-LOCK where
      (X_clob-data.db-num = X_clob-bind.db-num
  and X_clob-data.int64-id = X_clob-bind.int64-id )
      INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is NOT OPENED
*/  /* BROWSE br-clobs */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Список */
DO:
  p-rid-list = v-rid-list.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Список */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-add Dialog-Frame
ON CHOOSE OF b-add IN FRAME Dialog-Frame /* Добавить */
DO:
define variable glog as logical   no-undo .
define variable v-list-type as character no-undo .
define variable v-list-types as character no-undo .
define variable v-list-labels as character no-undo .
define variable v-title as character no-undo .
 if not (p-resource-type = {&lob-res-list}
 or p-resource-type = {&lob-res-list-macro})
 then do:
   message
   "Нельзя добавлять ресурсы типа" p-resource-type
   view-as alert-box error .
   undo, return no-apply.
 end.
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_clob-list_work':U
    {&cntxt-object}
    0
    '':U
    0
    0
    0
    0
    true
    glog
  }
  if not glog then undo, return no-apply.
  if p-uniq-key-rec = ''
  and lookup("managed", bttns) > 0 then do:
    /*надо выбрать тип листа*/
    assign
    v-list-types = "gds-list" + {&comma-char} +
                  "cli-list" + {&comma-char} +
                  "dc-list"
    .
    if p-resource-type = {&lob-res-list} then do:
      assign
      v-title = "Выберите тип хранимого списка"
      v-list-labels  = "Хранимый список товаров" + {&comma-char} +
                      "Хранимый список клиентов" + {&comma-char} +
                      "Хранимый список ДК"
                      .
    end.
    else do:
      assign
      v-title = "Выберите тип хранимого макроса формирования списка"
      v-list-labels  = "Хранимый макрос формирования списка товаров" + {&comma-char} +
                      "Хранимый макрос формирования списка клиентов" + {&comma-char} +
                      "Хранимый макрос формирования списка ДК"
                      .
    end.

    run gbl/d-list.w ( input "b-sel"
                      ,input v-title
                      ,input v-list-types
                      ,input v-list-labels
                      ,input {&comma-char}
                      ,input '' /*ppresel-codes*/
                      ,output v-list-type) no-error.
    if error-status:error
    or v-list-type = ''
    then do:
      return .
    end.
  end.
  else do:
    v-list-type = p-uniq-key-rec.
  end.
  message
  "По умолчанию список/макрос сохраняется ТОЛЬКО в текущей БД"
  "Для доступности в других БД - выберите опцию ГЛОБАЛЬНЫЙ"
  view-as alert-box warning.
  if not v-start
  and p-mode = {&update} then do:
    message
    "Вы уже сохраняли текущий список/макрос в БД" skip
    "Вы действительно хотите это сделать еще раз??"
    view-as alert-box question buttons yes-no update glog.
    if not glog then return no-apply.
  end.
  if lookup("managed", bttns) > 0 then do:
    case v-list-type:
      when "gds-list" then do:
         run str/gdslistp.w ( input parparentproc
                             ,input this-procedure:handle
                             ,input v-cntxt-host-code-obj
                             ,input v-cntxt-obj-type
                             ,input v-cntxt-obj-code
                             ,input p-resource-type + {&comma-char} + "clobbnds_add"
                             ,input substitute("СПИСОК ТОВАРОВ - добавление/изменение &1"
                                               , (if p-resource-type = {&lob-res-list}
                                                  then "хранимого списка"
                                                  else "хранимого макроса формирования списка")
                                                  )
                             ,input no).
      end.
      when "cli-list" then do:
         run str/clilistp.w ( input parparentproc
                             ,input this-procedure:handle
                             ,input v-cntxt-host-code-obj
                             ,input v-cntxt-obj-type
                             ,input v-cntxt-obj-code
                             ,input p-resource-type + {&comma-char} +  "clobbnds_add"
                             ,input substitute("СПИСОК КЛИЕНТОВ - добавление/изменение &1"
                                               , (if p-resource-type = {&lob-res-list}
                                                  then "хранимого списка"
                                                  else "хранимого макроса формирования списка")
                                                 )
                             ,input no).

      end.
      when "dc-list" then do:
         run str/dc-listp.w ( input parparentproc
                             ,input this-procedure:handle
                             ,input v-cntxt-host-code-obj
                             ,input v-cntxt-obj-type
                             ,input v-cntxt-obj-code
                             ,input p-resource-type + {&comma-char} + "clobbnds_add"
                             ,input substitute("СПИСОК ДК - добавление/изменение &1"
                                               , (if p-resource-type = {&lob-res-list}
                                                  then "хранимого списка"
                                                  else "хранимого макроса формирования списка")
                                                )
                             ,input no).

      end.
    end case.
  end.
  else do:
    run clobbnds_add in this-procedure ( input ? /*p-list-handle*/
                                      ,input p-resource-type
                                      ,input v-list-type
                                      ) no-error.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-chg Dialog-Frame
ON CHOOSE OF b-chg IN FRAME Dialog-Frame /* Изменить */
DO:
  if not available X_clob-bind then undo, return no-apply.
 IF chg-option = '':U THEN DO:
    run gbl/pop-up.p ( INPUT SELF :handle, input no ) no-error.
    if error-status :error then do: return no-apply. end.
  end.
  if chg-option = "":U then do:
      return no-apply.
  end.
 if not (p-resource-type = {&lob-res-list}
 or p-resource-type = {&lob-res-list-macro})
 then do:
   message
   "Нельзя изменять ресурсы типа" p-resource-type
   view-as alert-box error .
   undo, return no-apply.
 end.

define variable glog as logical   no-undo .
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_clob-list_work':U
    {&cntxt-object}
    0
    '':U
    0
    0
    0
    0
    true
    glog
  }
  if not glog then undo, return no-apply.
  if not v-start
  and chg-option = "data"
  and p-mode = {&update} then do:
    message
    "Вы уже сохраняли текущий список/макрос в БД" skip
    "Вы действительно хотите это сделать еще раз??"
    view-as alert-box question buttons yes-no update glog.
    if not glog then return no-apply.
  end.
  run proc-b-chg in this-procedure (
                                      input chg-option
                                      ) no-error.
  chg-option = ''.
  if error-status:error then do:
    undo, return no-apply.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-del Dialog-Frame
ON CHOOSE OF b-del IN FRAME Dialog-Frame /* Удалить */
DO:
  define variable v-rec as recid no-undo.
  if not available X_clob-bind
  and not available X_clob-data
  then undo, return no-apply.
 if not (p-resource-type = {&lob-res-list}
 or p-resource-type = {&lob-res-list-macro})
 then do:
   message
   "Нельзя удалять ресурсы типа" p-resource-type
   view-as alert-box error .
   undo, return no-apply.
 end.

define variable glog as logical   no-undo .
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_clob-list_work':U
    {&cntxt-object}
    0
    '':U
    0
    0
    0
    0
    true
    glog
  }
  if not glog then undo, return no-apply.
  message
  "Вы действительно хотите удалить хранимый файл?"
  view-as alert-box question buttons yes-no update glog.
  if not glog then return no-apply.
  run proc-b-del in this-procedure  no-error.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-lkp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-lkp Dialog-Frame
ON CHOOSE OF b-lkp IN FRAME Dialog-Frame /* Просмотр */
DO:
    define variable v-longchar as longchar no-undo .
    define variable v-ok as logical no-undo .
    if not available X_clob-data then return no-apply.
  case X_clob-bind.resource-type:
    when {&lob-res-report-xml} then do:
      run gbl/clbxmlvw.p (  input parparentproc
                           ,input rowid(X_clob-data)
                           ,input X_clob-bind.descr
                           ) no-error.
    end.
    otherwise do:
    v-longchar = X_clob-data.cdata.
    run gbl/d-longchar.w (
                           input ? /*r h-callback  */
                          ,input (
                                      'title=':u + X_clob-bind.descr + '\':u
                                  + 'Editor_row=2\':u
                                  + 'Editor_col=1\':u
                                  + 'Editor_width=96\':u
                                  + 'Editor_height=15\':u
                                    + 'readonly=yes\':u
                                    + 'resource-type=' + X_clob-bind.resource-type + '\':u
                                    )
                          ,input-output v-longchar
                          ,output v-ok ) no-error .
    assign
    v-longchar = '':U.
    end.
  end case.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mark Dialog-Frame
ON CHOOSE OF B-mark IN FRAME Dialog-Frame /* * */
DO:
  if not available X_clob-bind then return no-apply.
  { gbl/markstrn.i X_clob-bind v-rid-list }
  glog = br-clobs  :refresh( ) in frame {&frame-name}.
  if not can-do ("MOUSE-SELECT-DBLCLICK,Return", last-event:function) then do:
          glog = br-clobs:select-next-row () in frame {&frame-name}.
          apply "value-changed" to br-clobs in frame {&frame-name}.
  end.
  if num-entries (v-rid-list) = 0 then
      hide mark-num in frame {&frame-name}.
  else
  disp num-entries (v-rid-list) @ mark-num
  with frame {&frame-name}.
  apply "entry" to br-clobs in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-sch
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-sch Dialog-Frame
ON CHOOSE OF B-sch IN FRAME Dialog-Frame /* Фильтр */
DO:
  run proc-b-sch in this-procedure no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sel Dialog-Frame
ON CHOOSE OF b-sel IN FRAME Dialog-Frame /* Выбор */
DO:
    if ( available X_clob-bind ) AND ( v-rid-list = "" ) then
        v-rid-list = string( recid( X_clob-bind ) ) .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-send
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-send Dialog-Frame
ON CHOOSE OF b-send IN FRAME Dialog-Frame /* Глобальный */
DO:
  if not available X_clob-bind then return no-apply.
 if not (p-resource-type = {&lob-res-list}
 or p-resource-type = {&lob-res-list-macro})
 then do:
   message
   "Нельзя добавлять ресурсы типа" p-resource-type
   view-as alert-box error .
   undo, return no-apply.
 end.

define variable glog as logical   no-undo .
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_clob-list_send':U
    {&cntxt-object}
    0
    '':U
    0
    0
    0
    0
    true
    glog
  }
  if not glog then undo, return no-apply.


  run proc-b-send in this-procedure no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-clobs
&Scoped-define SELF-NAME br-clobs
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-clobs Dialog-Frame
ON VALUE-CHANGED OF br-clobs IN FRAME Dialog-Frame
DO:
  if available X_clob-bind then do:
    e-descr:screen-value = X_clob-bind.descr.
  end.
  else do:
    e-descr:screen-value = "".
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_data
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_data Dialog-Frame
ON CHOOSE OF MENU-ITEM m_data /* Данные */
DO:
   ASSIGN
  chg-option = "data".
  apply "CHOOSE" to b-chg in frame {&frame-name} .
  ASSIGN
  chg-option = '':U.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_descr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_descr Dialog-Frame
ON CHOOSE OF MENU-ITEM m_descr /* Описание */
DO:
   ASSIGN
  chg-option = "descr".
  apply "CHOOSE" to b-chg in frame {&frame-name} .
  ASSIGN
  chg-option = '':U.
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
{ gbl/setfltnm.i }
{ gbl/srt-clmd.i
  &browse-name    = "br-clobs"
  &frame-name     = "{&frame-name}"
  &table-name     = "X_clob-bind"
  &sort-clmn_1    = "X_clob-bind.field-name_"
  &sort-clmn_2    = "X_clob-bind.descr"
  &sort-clmn_3    = "X_clob-bind.sys-date"
  &sort-clmn_4    = "X_clob-bind.sys-time"
  &label-clmn_7  = "{&label-clmn_7}"
  &sort-clmn_7   = "{&sort-clmn_7}"
  &label-clmn_8  = "{&label-clmn_8}"
  &sort-clmn_8   = "{&sort-clmn_8}"
  &open-query     = "run OpenBr in this-procedure ( input yes, input no, input no)."
  &open-query-otherwise = "run OpenBr in this-procedure ( input yes, input no, input no)."
  &sort-column-name = "sort-column-name"
  &re-move-clmn   = "no"
  &mv-brw-default = "no"
}


{ gbl/brwrepos.i
&browse-name=br-clobs
&line-num=5
}

{ gbl/brwrefre.i " if available X_clob-bind then v-rec = recid(X_clob-bind). Run openbr in this-procedure  ( input yes, input no, input '':U). " }


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  { gbl/getcntxt.i get }
   if lookup(p-resource-type, {&lob-res-report} + {&comma-char} +
                            {&lob-res-report-xml} + {&comma-char} +
                            {&lob-res-list} + {&comma-char} +
                            {&lob-res-list-macro}
                            ) = 0 then do:
    message
    substitute("Неверный тип параметра p-resource-type=&1", p-resource-type)
    view-as alert-box error.
    undo main-block, return error.
  end.
  if lookup(p-uniq-key-rec , "gds-list,cli-list,dc-list,obj-list,,") = 0 then do:
    message
    substitute("Неверный тип параметра p-uniq-key-rec=&1", p-uniq-key-rec)
    view-as alert-box error.
    undo main-block, return error.
  end.
   if lookup(p-resource-type, {&lob-res-report} + {&comma-char} +
                            {&lob-res-report-xml}
                            ) > 0
   and p-uniq-key-rec >  ""
   then do:
    message
    substitute("Неверный тип параметра p-resource-type=&1 или p-uniq-key-rec=&2"
             , p-resource-type
             , p-uniq-key-rec)
    view-as alert-box error.
    undo main-block, return error.
  end.
  if lookup(p-uniq-key-rec, "gds-list,cli-list,dc-list,obj-list") = 0
  and p-mode <> ''
  then do:
    message
    substitute("Неверный тип параметра p-mode=&1 или p-uniq-key-rec=&2"
             , p-mode
             , p-uniq-key-rec)
    view-as alert-box error.
    undo main-block, return error.

  end.
  if lookup(p-uniq-key-rec, "gds-list,cli-list,dc-list,obj-list") > 0
  and not (p-mode = '' or p-mode = {&update})
  then do:
    message
    substitute("Неверный тип параметра p-mode=&1 или p-uniq-key-rec=&2"
             , p-mode
             , p-uniq-key-rec)
    view-as alert-box error.
    undo main-block, return error.

  end.
  v-rid-list = p-rid-list.
  if p-rid-list <> '' then do:
  end.
  v-rec = integer(entry(1, p-rid-list)).
  if lookup("managed", bttns) > 0 then do:
    v-list-proc-handle = ?.
  end.
  else do:
    v-list-proc-handle = p-parent-handle.
  end.
  RUN Myenable.
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
  DISPLAY mark-num E-descr
      WITH FRAME Dialog-Frame.
  ENABLE b-quit B-mark b-sel b-add b-chg b-lkp b-del b-send B-sch B-Help
         mark-num br-clobs E-descr
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
define variable v-res-title as character no-undo.
define variable v-mode-title as character no-undo.
define variable v-db-title as character no-undo.
case p-resource-type:
  when {&lob-res-report} then do:
     assign
     v-res-title = "Хранимые отчеты".
  end.
  when {&lob-res-report-xml} then do:
     assign
     v-res-title  = "Хранимые отчеты-XML".
  end.
  when {&lob-res-list} then do:
     assign
     v-res-title  = "Хранимые списки".
  end.
  when {&lob-res-list-macro} then do:
     assign
     v-res-title  = "Хранимые макросы формирования списков".
  end.
end case.
filter-label = v-res-title.
filter-label0 = v-res-title .
case p-list-mode:
   when {&all} then do:
   end.
   when "uniq-key-rec" then do:
      case p-uniq-key-rec:
         when "gds-list" then do:
            assign
            v-mode-title = "Список товаров".
         end.
         when "cli-list" then do:
            assign
            v-mode-title = "Список клиентов".

         end.
         when "dc-list" then do:
            assign
            v-mode-title = "Список карт".

         end.
         when "obj-list" then do:
            assign
            v-mode-title = "Список объектов".

         end.

      end.
   end.
end case.
case p-db-num:
   when -1 then do:
     v-db-title = "".
   end.
   otherwise do:
      v-db-title = substitute("БД &1", p-db-num).
   end.
end case.
assign
frame {&frame-name}:title = substitute("&1, &2&3 &4"
                                     , v-res-title
                                     , v-mode-title
                                     , (if v-db-title = '' then '' else {&comma-char})
                                     , v-db-title).

assign
b-del:menu-mouse in frame {&frame-name}  = 1
E-descr:read-only in frame {&frame-name} = yes
X_clob-bind.uniq-key-rec:visible in browse br-clobs = (if ((p-resource-type = {&lob-res-list}
                                                       or p-resource-type = {&lob-res-list-macro})
                                                          and p-uniq-key-rec <> '')
                                                       then no else yes)
X_clob-bind.descr:read-only in browse br-clobs = yes
X_clob-bind.descr:resizable in browse br-clobs = yes
X_clob-bind.field-name_:resizable in browse br-clobs = yes
b-chg:menu-mouse in frame {&frame-name} = 1
menu-item m_descr:sensitive in menu menu-b-chg = (not (p-resource-type = {&lob-res-report} or p-resource-type = {&lob-res-report-xml}) and not transaction)
menu-item m_data:sensitive in menu menu-b-chg = (lookup("b-add", bttns ) > 0
                                                 and not (p-resource-type = {&lob-res-report} or p-resource-type = {&lob-res-report-xml})
                                                 and not transaction)
X_clob-bind.uniq-key-rec:width in browse br-clobs = (if p-resource-type = {&lob-res-list}
                                                      or p-resource-type = {&lob-res-list-macro}
                                                      then 8
                                                      else (X_clob-bind.uniq-key-rec:width in browse br-clobs))
.

ENABLE
b-quit
b-add when lookup("b-add", bttns ) > 0
                  and not (p-resource-type = {&lob-res-report} or p-resource-type = {&lob-res-report-xml}
                  and not transaction
                  )
b-chg when (not (p-resource-type = {&lob-res-report} or p-resource-type = {&lob-res-report-xml})
           and not transaction)
b-del when (lookup("b-add", bttns ) > 0
            and not (p-resource-type = {&lob-res-report} or p-resource-type = {&lob-res-report-xml})
            and not transaction)
b-sel when (lookup("b-sel", bttns) > 0)
/*             and not transaction)*/ /*не понятно что это такое и для чего*/ 
b-mark when (lookup("b-mark", bttns) > 0
             and not transaction)
b-lkp
b-sch
B-Help
b-send when /*( can-find(first ub.db where ub.db.db-num > 0)) разрешим
              ставить галки и для системы без БД, а то список не сохраняется в параметры RUM
             and*/  not (p-resource-type = {&lob-res-report} or p-resource-type = {&lob-res-report-xml}
             and lookup("b-add", bttns ) > 0
             and not transaction
              )
br-clobs
E-descr
WITH FRAME {&frame-name}.
VIEW FRAME {&frame-name}.
Run openbr in this-procedure  ( input yes, input no, input '':U).
apply "value-changed" to br-clobs.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OpenBr Dialog-Frame
PROCEDURE OpenBr :
define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .

define variable l-query-was-opened as logical no-undo .


define variable sort-column-phrase as character no-undo .

case sort-column-name :
  when "" then do:
    assign
      sort-column-phrase = ""
    .
  end.
  otherwise do:
    assign
      sort-column-phrase = "by " + sort-column-name
    .
  end.
end case.

&scop flt-open-debug-file

&scop flt-open-open-query OPEN QUERY br-clobs FOR EACH X_clob-bind no-lock

&scop flt-open-dyn_open-query  FOR EACH X_clob-bind no-lock

&scop flt-open-query-handle query br-clobs:handle

&scop flt-open-open-query-tail      , first X_clob-data NO-LOCK where ~
      (X_clob-data.db-num = X_clob-bind.db-num ~
  and X_clob-data.int64-id = X_clob-bind.int64-id )

&scop flt-open-query-was-opened  l-query-was-opened

&scop flt-open-sort-column-phrase sort-column-phrase

&scop flt-open-call-point filter-point

&scop flt-open-set-filter-name set-filter-name

&scop flt-open-indexed-reposition

&scop flt-open-find-buffer-name X_clob-bind

&scop flt-open-waitfram yes

filter-point = filter-point0 + p-resource-type.

CASE p-list-mode:
  when {&all} then do:

    { gbl/fltopend.i
      &where-cond = " X_clob-bind.resource-type = p-resource-type and ~
                      (p-db-num = -1 or X_clob-bind.db-num = p-db-num) "
      &dyn_where-cond = " substitute(' X_clob-bind.resource-type = &1&2&1 and ~
                         ( &3 = -1 or X_clob-bind.db-num = &3)', ~{&double-quote~}, p-resource-type, p-db-num) "
      &use-ind = "  "
      &by = " "
    }
  END.
  when "uniq-key-rec" then do:
    { gbl/fltopend.i
      &where-cond = " X_clob-bind.resource-type = p-resource-type and ~
                    X_clob-bind.uniq-key-rec = p-uniq-key-rec and ~
      (p-db-num = -1 or X_clob-bind.db-num = p-db-num)  "
      &dyn_where-cond = " substitute(' X_clob-bind.resource-type = &1&2&1 and ~
                                      X_clob-bind.uniq-key-rec = &1&3&1 and ~
      (&4 = -1 or X_clob-bind.db-num = &4)', ~{&double-quote~}, p-resource-type, p-uniq-key-rec, p-db-num) "
      &use-ind = "  "
      &by = "  "
    }
  END.
END CASE.


apply "entry" to br-clobs in frame {&frame-name}.
if v-rec <> ? then reposition br-clobs to recid v-rec no-error.
if error-status:error then do:
  reposition br-clobs to row 1 no-error.
end.
run waitfram-hide in this-procedure .
if avail X_clob-data then
APPLY "VALUE-CHANGED":U to br-clobs.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-add Dialog-Frame
PROCEDURE clobbnds_add :
define input parameter p-list-handle as handle no-undo .
define input parameter p-resource-type as character no-undo .
define input parameter p-list-type as character no-undo .
define variable v-part-num as integer   no-undo .
define variable v-clob-db-num as integer   no-undo init ?.
define variable v-int64-id as int64 no-undo .
define variable v-descr                   as character                no-undo .
define variable v-path                    as character                no-undo .
DEFINE VARIABLE v-full-path               as character                no-undo .
DEFINE VARIABLE v-file-name               as character                no-undo .
DEFINE VARIABLE v-file-name-no-ext        as character                no-undo .
DEFINE VARIABLE v-file-name-ext           as character                no-undo .
define buffer buf_clob-bind for ub.clob-bind.

run gbl/d-prompt.w (
    'title=':u + "Добавление списка/макроса" + '\':u
  + 'text1=':u + "Введите описание" + '\':u
  + 'format=X(90)\':u
  + 'type=char\':u
  + 'fillin_row=1\':u
  + 'fillin_col=1\':u
  + 'fillin_width=92\':u
  + 'fillin_height=1\':u
  + 'max-chars=90\':u
  ,input-output v-descr
  ).
if return-value = 'false':u
then do:
  return 'quit'.
end.
run gbl/_tmpfile.p ( input ""
                    ,input "tmp"
                    ,output v-file-name) .
output to value(v-file-name).
put 1 skip.
output close.
run gbl/filename.p (
              input v-file-name
              ,output v-full-path
              ,output v-path
              ,output v-file-name
              ,output v-file-name-no-ext
              ,output v-file-name-ext
              ) no-error .
if error-status:error then do:
  undo, return error .
end.
if p-list-handle = ? then do:
  p-list-handle = p-parent-handle.
end.
case p-resource-type:
  when {&lob-res-list} then do:
    run cb_fill-lob-res-list in p-list-handle ( input v-full-path) no-error.
  end.
  when {&lob-res-list-macro} then do:
    run cb_fill-lob-res-list-macro in p-list-handle ( input v-full-path) no-error.
  end.
end case.

if error-status:error then do:
  os-delete value(v-full-path) no-error.
  return no-apply.
end.
run gbl/file2clb.p ( input {&add-def}
                    ,input ",no" /*p-clob-mode - в новости не слать*/
                    ,input ? /*p-bh*/
                    ,input p-list-type
                    ,input '':U /*p-field-*/
                    ,input v-descr
                    ,input-output v-part-num
                    ,input p-resource-type
                    ,input-output v-clob-db-num
                    ,input-output v-int64-id
                    ,input v-full-path
                    ,input ? /*p-src-encoding*/
                    ) no-error .
if error-status:error then do:
  message error-status :error  skip
  return-value
  view-as alert-box error .
  undo, return error  .
end.
v-start = no.
find first buf_clob-bind no-lock where
          buf_clob-bind.db-num = v-clob-db-num
      and buf_clob-bind.int64-id = v-int64-id no-error.
if available buf_clob-bind then do:
  v-rec = recid(buf_clob-bind).
end.
run OpenBr in this-procedure  ( input yes, input no, input '':U).
apply "value-changed" to br-clobs in frame {&frame-name} .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-chg Dialog-Frame
PROCEDURE proc-b-chg :
define input parameter p-chg-option as character no-undo.
define variable v-part-num as integer   no-undo .
define variable v-clob-db-num as integer   no-undo .
define variable v-int64-id as int64 no-undo .
define variable v-old-clob-db-num as integer   no-undo .
define variable v-old-int64-id as int64 no-undo .
define variable lns-cnt as integer no-undo .
define variable line-rec as recid no-undo .

define variable v-longchar as longchar no-undo.
define variable v-str as character no-undo.
define variable v-prod-type like ub.goods.prod-type.
define variable v-prod-code like ub.goods.prod-code.
define variable v-artic     like ub.goods.artic.
define variable v-obj-type  like ub.clients.obj-type.
define variable v-obj-code  like ub.clients.obj-code.
define variable v-cli-type  like ub.clients.obj-type.
define variable v-cli-code  like ub.clients.obj-code.
define variable v-d-card    like ub.dis-card.d-card.

define variable v-descr as character no-undo .
define variable v-file-name0 as character no-undo .
define variable v-ok as logical   no-undo .
define variable v-path                    as character                no-undo .
DEFINE VARIABLE v-full-path               as character                no-undo .
DEFINE VARIABLE v-file-name               as character                no-undo .
DEFINE VARIABLE v-file-name-no-ext        as character                no-undo .
DEFINE VARIABLE v-file-name-ext           as character                no-undo .
define buffer buf_clob-data for ub.clob-data.
define buffer buf_clob-bind for ub.clob-bind.
define buffer buf_goods for ub.goods.

assign
v-old-clob-db-num = X_clob-bind.db-num
v-old-int64-id = X_clob-bind.int64-id
v-clob-db-num = X_clob-bind.db-num
v-int64-id = X_clob-bind.int64-id
v-part-num = X_clob-bind.part-num
v-descr = X_clob-bind.descr
v-rec = recid(X_clob-bind)
.
if (g#db-num > 0 and X_clob-bind.db-num <> g#db-num)
or (g#db-num = 0 and X_clob-bind.db-num > 0 and can-find( first ub.db where ub.db.db-num = X_clob-bind.db-num))
then do:
  message
  "Нельзя изменить список или отчет, созданный в другой БД!"
  view-as alert-box error  .
  undo, return error .
end.
find first buf_clob-data share-lock where
          buf_clob-data.db-num = X_clob-bind.db-num
      and buf_clob-data.int64-id = X_clob-bind.int64-id .
if buf_clob-data.crc-field = '' then do:
    message
    "В настоящий момент работает распределенная команда УДАЛЕНИЯ данного файла" skip
    "Изменение невозможно"
    view-as alert-box error .
    undo, return error .
end.
case p-chg-option:
when "descr" then do:
    run gbl/d-prompt.w (
        'title=':u + "Изменение описания списка макроса" + '\':u
      + 'text1=':u + "Можете изменить описание" + '\':u
      + 'format=X(90)\':u
      + 'type=char\':u
      + 'fillin_row=1\':u
      + 'fillin_col=1\':u
      + 'fillin_width=92\':u
      + 'fillin_height=1\':u
      + 'max-chars=90\':u
      ,input-output v-descr
      ).
    if return-value = 'false':u
    then do:
      return 'quit'.
    end.
    find first buf_clob-bind where
                recid(buf_clob-bind) = recid(X_clob-bind).
    assign
    buf_clob-bind.descr = v-descr.
    release buf_clob-bind.
end.
when "data" then do:
    define variable v-list-type as character no-undo .
    if p-uniq-key-rec = '' then do:
      v-list-type = X_clob-bind.uniq-key-rec.
    end.
    else do:
      v-list-type = p-uniq-key-rec.
    end.
    v-longchar = X_clob-data.cdata.
    if lookup("managed", bttns) > 0 then do:
      case v-list-type:
        when "gds-list" then do:
          run gbl/_tmpfile.p ( input ""
                              ,input "txt"
                              ,output v-file-name) .
          output to value(v-file-name).
          put 1 skip.
          output close.
          run gbl/filename.p (
                        input v-file-name
                        ,output v-full-path
                        ,output v-path
                        ,output v-file-name
                        ,output v-file-name-no-ext
                        ,output v-file-name-ext
                        ) no-error .
          if error-status:error then do:
            undo, return error .
          end.
          copy-lob
          FROM object v-longchar
          to FILE v-full-path
          no-convert
          NO-ERROR.
          input from value(v-full-path) .
            repeat :
              import  v-prod-type v-prod-code v-artic   .
              find buf_goods where buf_goods.prod-type = v-prod-type
                                and buf_goods.prod-code = v-prod-code
                                and buf_goods.artic     = v-artic no-error.
              if available buf_goods then do :
                { cmp/gds-list.i gds-list assign " " buf_goods }
              end.
            end.
          input close.
          os-delete value(v-full-path).
          run str/gdslistp.w ( input parparentproc
                              ,input this-procedure:handle
                              ,input v-cntxt-host-code-obj
                              ,input v-cntxt-obj-type
                              ,input v-cntxt-obj-code
                              ,input p-resource-type + {&comma-char} + "clobbnds_chg"
                              ,input "HH"
                              ,input no).
          for each gds-list :
            delete gds-list.
          end.
        end.
        when "cli-list" then do:
          run gbl/_tmpfile.p ( input ""
                              ,input "txt"
                              ,output v-file-name) .
          output to value(v-file-name).
          put 1 skip.
          output close.
          run gbl/filename.p (
                        input v-file-name
                        ,output v-full-path
                        ,output v-path
                        ,output v-file-name
                        ,output v-file-name-no-ext
                        ,output v-file-name-ext
                        ) no-error .
          if error-status:error then do:
            undo, return error .
          end.
          copy-lob
          FROM object v-longchar
          to FILE v-full-path
          no-convert
          NO-ERROR.
          input from value(v-full-path) .
            repeat :
              import  v-obj-type v-obj-code .
              find clients where clients.obj-type = v-obj-type
                             and clients.obj-code = v-obj-code no-lock.
              if available clients then do :
                { cmp/cli-list.i cli-list assign }
              end.
            end.
          input close.
          os-delete value(v-full-path).
          run str/clilistp.w ( input parparentproc
                              ,input this-procedure:handle
                              ,input v-cntxt-host-code-obj
                              ,input v-cntxt-obj-type
                              ,input v-cntxt-obj-code
                              ,input p-resource-type + {&comma-char} + "clobbnds_chg"
                              ,input "HH"
                              ,input no).
          for each cli-list :
            delete cli-list.
          end.
        end.
        when "dc-list" then do:
          run gbl/_tmpfile.p ( input ""
                              ,input "txt"
                              ,output v-file-name) .
          output to value(v-file-name).
          put 1 skip.
          output close.
          run gbl/filename.p (
                        input v-file-name
                        ,output v-full-path
                        ,output v-path
                        ,output v-file-name
                        ,output v-file-name-no-ext
                        ,output v-file-name-ext
                        ) no-error .
          if error-status:error then do:
            undo, return error .
          end.
          copy-lob
          FROM object v-longchar
          to FILE v-full-path
          no-convert
          NO-ERROR.
          input from value(v-full-path) .
            repeat :
              import  v-d-card v-cli-type v-cli-code .
              find dis-card where dis-card.d-card   = v-d-card
                              and dis-card.cli-type = v-cli-type
                              and dis-card.cli-code = v-cli-code no-lock.
              if available dis-card then do :
                { cmp/dc-list.i dc-list assign }
              end.
            end.
          input close.
          os-delete value(v-full-path).
          run str/dc-listp.w ( input parparentproc
                              ,input this-procedure:handle
                              ,input v-cntxt-host-code-obj
                              ,input v-cntxt-obj-type
                              ,input v-cntxt-obj-code
                              ,input p-resource-type + {&comma-char} + "clobbnds_chg"
                              ,input "HH"
                              ,input no).
          for each dc-list :
            delete dc-list.
          end.
        end.
      end case.
    end.
    else do:
      run clobbnds_chg in this-procedure ( input ?).
    end.
  end.
end case.
v-longchar = '':U.
run OpenBr in this-procedure  ( input yes, input no, input '':U).

apply "value-changed" to br-clobs in frame {&frame-name} .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE clobbnds_chg Dialog-Frame
PROCEDURE clobbnds_chg :
define input parameter p-list-handle as handle no-undo .
define variable v-part-num as integer   no-undo .
define variable v-clob-db-num as integer   no-undo .
define variable v-int64-id as int64 no-undo .
define variable v-old-clob-db-num as integer   no-undo .
define variable v-old-int64-id as int64 no-undo .

define variable v-descr as character no-undo .
define variable v-file-name0 as character no-undo .
define variable v-ok as logical   no-undo .
define variable v-path                    as character                no-undo .
DEFINE VARIABLE v-full-path               as character                no-undo .
DEFINE VARIABLE v-file-name               as character                no-undo .
DEFINE VARIABLE v-file-name-no-ext        as character                no-undo .
DEFINE VARIABLE v-file-name-ext           as character                no-undo .
define buffer buf_clob-data for ub.clob-data.
define buffer buf_clob-bind for ub.clob-bind.


assign
v-old-clob-db-num = X_clob-bind.db-num
v-old-int64-id = X_clob-bind.int64-id
v-clob-db-num = X_clob-bind.db-num
v-int64-id = X_clob-bind.int64-id
v-part-num = X_clob-bind.part-num
v-descr = X_clob-bind.descr
v-rec = recid(X_clob-bind)
.
    run gbl/_tmpfile.p ( input ""
                        ,input "tmp"
                        ,output v-file-name) .
    output to value(v-file-name).
    put 1 skip.
    output close.
    run gbl/filename.p (
                  input v-file-name
                  ,output v-full-path
                  ,output v-path
                  ,output v-file-name
                  ,output v-file-name-no-ext
                  ,output v-file-name-ext
                  ) no-error .
    if error-status:error then do:
      undo, return error .
    end.
if p-list-handle = ? then do:
  p-list-handle = p-parent-handle.
end.
    case p-resource-type:
      when {&lob-res-list} then do:
    run cb_fill-lob-res-list in p-list-handle ( input v-full-path) no-error.
      end.
      when {&lob-res-list-macro} then do:
    run cb_fill-lob-res-list-macro in p-list-handle ( input v-full-path) no-error.
      end.
    end case.
    if error-status:error then do:
      os-delete value(v-full-path) no-error.
      return no-apply.
    end.
    run gbl/file2clb.p ( input {&update}
                        ,input "add-new,no" /*p-clob-mode в новости не слать*/
                        ,input ? /*p-bh*/
                    ,input X_clob-bind.uniq-key-rec
                        ,input X_clob-bind.field-name_ /*p-field-*/
                        ,input v-descr
                        ,input-output v-part-num
                        ,input p-resource-type
                        ,input-output v-clob-db-num
                        ,input-output v-int64-id
                        ,input v-full-path
                        ,input ? /*p-src-encoding*/
                        ) no-error .
    if error-status:error then do:
      message error-status :error  skip
      return-value
      view-as alert-box error .
      undo, return error  .
    end.
    find first buf_clob-data no-lock where
              buf_clob-data.db-num = v-old-clob-db-num
          and buf_clob-data.int64-id = v-old-int64-id no-error.
    if available buf_clob-data then do:
      run clbdattd_two-commit-del in this-procedure ( buffer buf_clob-data, input 1) no-error.
      if error-status :error then do:
        undo , return error substitute("Ошибка при попытке запустить удаление неиспользуемых clob-data &1 (&2&3)(2)&4&5&4&6"
                                                  ,buf_clob-data.file-name_
                                                  ,buf_clob-data.db-num
                                                  ,buf_clob-data.int64-id
                                                  ,{&new-line}
                                                  , error-status:get-message(1)
                                                  , return-value ).
      end.
    end.
    v-start = no.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-del Dialog-Frame
PROCEDURE proc-b-del :
define variable v-clob-db-num as integer   no-undo .
define variable v-int64-id as int64 no-undo .
define variable v-part-num as integer   no-undo .
define buffer buf_clob-data for ub.clob-data.
if (g#db-num > 0 and X_clob-bind.db-num <> g#db-num)
or (g#db-num = 0 and X_clob-bind.db-num > 0 and can-find( first ub.db where ub.db.db-num = X_clob-bind.db-num))
then do:
  message
  "Нельзя удалить список или отчет, созданный в другой БД!"
  view-as alert-box error
  .
  undo, return error .
end.


find first buf_clob-data share-lock where
        buf_clob-data.db-num = X_clob-bind.db-num
    and buf_clob-data.int64-id = X_clob-bind.int64-id no-error.
if buf_clob-data.crc-field = '' then do:
  message
  "В настоящий момент УЖЕ работает распределенная команда УДАЛЕНИЯ данного файла" skip
  view-as alert-box error .
  undo, return error .
end.
assign
v-clob-db-num = X_clob-bind.db-num
v-int64-id = X_clob-bind.int64-id
v-part-num = X_clob-bind.part-num
.

run gbl/file2clb.p ( input {&deletion}
                    ,input "delete" /*p-clob-mode*/
                    ,input ? /*p-bh*/
                    ,input X_clob-bind.uniq-key-rec
                    ,input X_clob-bind.field-name
                    ,input '':U
                    ,input-output v-part-num
                    ,input p-resource-type
                    ,input-output v-clob-db-num
                    ,input-output v-int64-id
                    ,input X_clob-bind.uniq-key-rec
                    ,input ? /*p-src-encoding*/
                    ) no-error .
if error-status :error then do:
  message
  error-status:get-message(1) skip
  return-value
  view-as alert-box error .
  undo , return error return-value .
end.
if available buf_clob-data then do:
  run clbdattd_two-commit-del in this-procedure ( buffer buf_clob-data, input 1) no-error.
  if error-status :error then do:
    undo , return error substitute("Ошибка при попытке запустить удаление неиспользуемых хранимых данных &1 (&2&3)(2)&4&5&4&6"
                                              ,buf_clob-data.file-name_
                                              ,buf_clob-data.db-num
                                              ,buf_clob-data.int64-id
                                              ,{&new-line}
                                              , error-status:get-message(1)
                                              , return-value ).
  end.
end.
v-rec = ?.
run OpenBr in this-procedure  ( input yes, input no, input '':U).
apply "value-changed" to br-clobs in frame {&frame-name} .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-sch Dialog-Frame
PROCEDURE proc-b-sch :
assign
tbl = 'clob-bind'
join-tbl = 'X_clob-bind'
fld = ""
lab = ""
spr = ""
dim = '0'
.
run fltfield-add in this-procedure('uniq-key-rec', 'Тип', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('field-name_', 'ID', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('db-num', 'БД', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('user-name', 'Создал', 'usr',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.

DO on stop undo, leave:
    run gbl/filter.w ( input parparentproc
                      ,input (filter-point + {&delim-par} +
                         filter-label  + {&delim-par} +
                         string(yes))
                      ,input tbl
                      ,input join-tbl
                      ,input fld
                      ,input lab
                      ,input spr
                      ,input dim).
    RUN OpenBr in this-procedure ( input yes, input no, input '':U).
END .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-send Dialog-Frame
PROCEDURE proc-b-send :
define variable v-old-is-cs as logical no-undo .
define buffer buf_clob-data for ub.clob-data.
main-block:
do transaction:
  find first buf_clob-data share-lock where
            recid(buf_clob-data) = recid(X_clob-data).
    if buf_clob-data.crc-field = '' then do:
      message
      "В настоящий момент работает распределенная команда УДАЛЕНИЯ данного файла" skip
      "Отсылка невозможна"
      view-as alert-box error .
      undo, return error .
    end.
  assign
  v-old-is-cs = buf_clob-data.is-cs
  buf_clob-data.is-cs = yes.
  if v-old-is-cs = no then do:
     run str/callnews.p ( input {&table_clob-bind}
                        ,input (buffer X_clob-bind:handle)
                        ) no-error .
    if error-status:error then do:
      if error-status :get-message(1) <> ""
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при вызове callnews.p" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
      end.
      undo,  return error return-value .
    end.
    release buf_clob-data.
    find first buf_clob-data share-lock where
              recid(buf_clob-data) = recid(X_clob-data).
   run str/callnews.p ( input {&table_clob-bind}
                        ,input (buffer X_clob-bind:handle)
                        ) no-error .
    if error-status:error then do:
      if error-status :get-message(1) <> ""
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при вызове callnews.p" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
      end.
      undo main-block,  return error return-value .
    end.
    end.
  br-clobs:refresh() in frame {&frame-name} .
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME