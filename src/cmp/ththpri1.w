&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE tt_obj-list NO-UNDO LIKE ub.clients.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Выбор объектов для запуска ИМПОРТА ПН из старой версии TH в 16.0 ( перенос остатков )

Автор: Чернова Светлана Александровна
Дата создания: 01/13/09
Author: Svetlana Chernova
Creation date: 01/13/09

*/

/*------------------------------------------------------------------------*/
/*          This .W file was created with the Progress AppBuilder.       */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-from-version   as character no-undo .

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Выбор объектов для запуска ИМПОРТА ПН из старой версии TH в 16.0 ( перенос остатков )".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/obj-list.i new }
{ ref/extclass.i }
{ gbl/key-rec.i  }
{ cmp/thth150.i }
{ cmp/thth14.i }

define variable v-log as logical   no-undo .
define variable p-var as integer   no-undo .
define variable passwd as character no-undo.

define variable v-cli-classif-name as character no-undo .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br-obj

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt_obj-list

/* Definitions for BROWSE br-obj                                      */
&Scoped-define FIELDS-IN-QUERY-br-obj tt_obj-list.buy-cons tt_obj-list.obj-code tt_obj-list.obj-name
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-obj
&Scoped-define SELF-NAME br-obj
&Scoped-define QUERY-STRING-br-obj FOR EACH tt_obj-list NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-br-obj OPEN QUERY {&SELF-NAME} FOR EACH tt_obj-list NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-br-obj tt_obj-list
&Scoped-define FIRST-TABLE-IN-QUERY-br-obj tt_obj-list


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-br-obj}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-Cancel B-mark B-OK B-Help br-obj

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-Cancel AUTO-END-KEY
     LABEL "Вы&ход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-Help
     LABEL "&Help"
     SIZE 3.25 BY 1.13
     BGCOLOR 8 .

DEFINE BUTTON B-mark
     LABEL "&*"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-OK AUTO-GO
     LABEL "&Создать"
     SIZE 10 BY 1
     BGCOLOR 8 .

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-obj FOR
      tt_obj-list SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-obj
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-obj Dialog-Frame _FREEFORM
  QUERY br-obj NO-LOCK DISPLAY
      tt_obj-list.buy-cons FORMAT "*/ ":U column-label "*"
      tt_obj-list.obj-type FORMAT "X(3)":U
      tt_obj-list.obj-code FORMAT ">>>>>>>>9":U
      tt_obj-list.db-num FORMAT ">>>>9":U    column-label "БД"
      tt_obj-list.obj-name FORMAT "X(30)":U  column-label "Наименование"
      tt_obj-list.grp-name FORMAT "X(40)":U  column-label "Наименование16.0"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 87 BY 16.83 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-Cancel AT ROW 1 COL 2
     B-mark AT ROW 1 COL 16 WIDGET-ID 2
     B-OK AT ROW 1 COL 19.13
     B-Help AT ROW 1 COL 85
     br-obj AT ROW 2.17 COL 1.75 WIDGET-ID 200
     SPACE(0.49) SKIP(0.03)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Приходные Накладные по объектам"
         DEFAULT-BUTTON B-OK CANCEL-BUTTON B-Cancel WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: tt_obj-list T "?" NO-UNDO ub clients
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB br-obj B-Help Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-obj
/* Query rebuild information for BROWSE br-obj
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt_obj-list NO-LOCK INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is OPENED
*/  /* BROWSE br-obj */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Переоценки по объектам */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-Help
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-Help Dialog-Frame
ON CHOOSE OF B-Help IN FRAME Dialog-Frame /* Help */
OR HELP OF FRAME {&FRAME-NAME}
DO: /* Call Help Function (or a simple message). */

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mark Dialog-Frame
ON CHOOSE OF B-mark IN FRAME Dialog-Frame /* * */
DO:
if   tt_obj-list.buy-cons then  tt_obj-list.buy-cons = no.  /*  *   */
     else  tt_obj-list.buy-cons = yes.
     v-log = {&BROWSE-NAME}:refresh() .
     v-log = {&BROWSE-NAME}:select-next-row() .
     apply "VALUE-CHANGED" to {&BROWSE-NAME} in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-OK
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-OK Dialog-Frame
ON CHOOSE OF B-OK IN FRAME Dialog-Frame /* Создать */
DO:
  run proc-exec in this-procedure no-error .
  if error-status :error then return no-apply .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-obj
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


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
  case p-from-version:
    when {&thth150-from-version} then do:
      v-cli-classif-name = {&extclass_clients_th-th150}.
    end.
    when {&thth14-from-version} then do:
      v-cli-classif-name = {&extclass_clients_th-th14}.
    end.
    otherwise do:
      message
      substitute("Неверное значение параметра p-from-version=&1", p-from-version)
      view-as alert-box error .
      undo main-block, return error .
    end.
  end case. /*case p-from-version:*/

  run init-proc in this-procedure .
  RUN enable_UI in this-procedure .
  assign
  tt_obj-list.obj-name:column-label in browse br-obj = substitute("& &2"
                                                                  , tt_obj-list.obj-name:column-label in browse br-obj
                                                                  , p-from-version).

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
  ENABLE B-Cancel B-mark B-OK B-Help br-obj
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-proc Dialog-Frame
PROCEDURE init-proc :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
empty temp-table tt_obj-list.

define buffer new_clients for ub.clients  .
for each new_clients no-lock where
         new_clients.obj-type = {&shop} or
         new_clients.obj-type = {&stock}
         :
  if new_clients.stts <> 0 then next.
  create  tt_obj-list.
  buffer-copy new_clients  to tt_obj-list
  assign
  tt_obj-list.grp-name = ""
  tt_obj-list.buy-cons = false
  .
end.
define buffer new_ext-classif for ub.ext-classif  .
define buffer buf_clients for ub.clients  .
define variable v-key-rec as character no-undo .

for each tt_obj-list  :
  find first buf_clients no-lock where
             buf_clients.obj-type = tt_obj-list.obj-type and
             buf_clients.obj-code = tt_obj-list.obj-code no-error .
  if error-status :error then next.

  run gen-key-rec in this-procedure (  input {&table_clients}
                                     , input (buffer buf_clients:handle)
                                     , output v-key-rec).

  /*Найдем старое значение obj-code */
  find first new_ext-classif no-lock where
                 /*new_ext-classif.classif-subject = {&table_clients}           and*/
                 new_ext-classif.classif-name    = v-cli-classif-name
             and new_ext-classif.db-num          = - 1
             and new_ext-classif.uniq-key-rec    = v-key-rec no-error .
  if available new_ext-classif then do:
    tt_obj-list.grp-name = substitute("БД&4  &1&2 - &3"
                                      , buf_clients.obj-type
                                      , buf_clients.obj-code
                                      , buf_clients.obj-name
                                      , buf_clients.db-num)
    .
  end.
end. /*for each tt_obj-list  :*/


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-exec Dialog-Frame
PROCEDURE proc-exec :
define variable v-ok as logical   no-undo .
message
"Для перевода порожденных партий  необходимо создать ОРГ в справочнике клиента , на которого будут переведены эти партии"  skip (2)
"Продолжать ?"
view-as alert-box information
buttons yes-no
update v-ok.
if not v-ok then return error.

run gbl/d-prompt.w (
    'title=':u + "Выбор фиктивного контрагена " + '\':u
  + 'text1=':u + "Выбор фиктивного контрагена для порожденных партий" + '\':u
  + 'text2=':u + "ВВЕДИТЕ код контрагента" + '\':u
  + 'type=integer\':u
  + 'format=>>>>>>>>>>>>>>9\':u
  + 'fillin_row=4\':u
  + 'fillin_col=4\':u
  + 'fillin_width=20\':u
  ,input-output passwd
  ).
if return-value = 'false':u
then do:
  return error.
end.

find first ub.clients no-lock where
           ub.clients.obj-code = int(passwd)  and
           ub.clients.obj-type = {&cmp}
           no-error .
if error-status :error then do:
  message
  vss-workfile vss-revision vss-description skip
  error-status :get-message(1) skip
  return-value skip
  "Ошибка"
  view-as alert-box error
  .
  return error.
end.

if not ( ub.clients.obj-type = {&cmp}  )then do:
  message
  "Выбран неправильный Контрагент !"
  view-as alert-box error .
  return .
end.
message
ub.clients.obj-type ub.clients.obj-code ub.clients.obj-name skip
"Будет фиктивным контрагентом для порожденных партий" skip (2)
"Продолжать ?"
view-as alert-box information
buttons yes-no
title "Внимание"
update v-ok
  .
if not v-ok then return error.

define buffer new_ext-classif for ub.ext-classif  .
define buffer buf_clients for ub.clients  .
define variable v-key-rec as character no-undo .

for each tt_obj-list where
         tt_obj-list.buy-cons = true :
  find first buf_clients no-lock where
             buf_clients.obj-type = tt_obj-list.obj-type and
             buf_clients.obj-code = tt_obj-list.obj-code no-error .
  if error-status :error then next.

  run gen-key-rec in this-procedure (  input {&table_clients}
                                     , input (buffer buf_clients:handle)
                                     , output v-key-rec).

    /*Найдем старое значение obj-code */
  find first new_ext-classif no-lock where
              new_ext-classif.classif-subject = {&table_clients}
          and new_ext-classif.classif-name    = v-cli-classif-name
          and new_ext-classif.db-num          = - 1
          and new_ext-classif.uniq-key-rec    = v-key-rec no-error .
  if available new_ext-classif then do:
    define buffer buf_obj-list for obj-list .

    find last buf_obj-list  use-index pi no-error .
    if available buf_obj-list then do:
      p-var = buf_obj-list.obj-id + 1.
    end.
    else do:
      p-var = 1.
    end.

    create obj-list .
    assign
    obj-list.obj-id   = p-var
    obj-list.obj-type = new_ext-classif.charkey_one
    obj-list.obj-code = new_ext-classif.Key#_One
    /*obj-list.obj-name =
    substitute("&1&2 - &1" , buf_clients.obj-type , buf_clients.obj-code, buf_clients.obj-name )
    */
    .
  end.
end. /*for each tt_obj-list where*/
define variable v-okk as logical   no-undo .

if  can-find( first obj-list)  = false  then do:
  message
  "Не выбрано ни одного объекта !"
  view-as alert-box error .
  return error.
end.




run cmp/upg-conn.p ( input "connect"
                    ,input p-from-version
                    ,output v-ok )
                    no-error.
if not v-ok then do:
  message
  substitute("Ошибка при подключении к ЧУЖОЙ БД TH&1&2&1&3"
             , {&new-line}
             , error-status:get-message(1)
             , return-value )
  view-as alert-box error .
  return error .
end.

v-okk = false  .
run str/diallog.w ( input parparentproc
          , input this-procedure:handle
          , input 'cmp/ththpri.p':U
          , input (passwd + {&delim-par} + p-from-version)
          , input yes /*p-auto-go*/
          , input ''
          , input substitute('Импорт остатков из &1 БД в 16.0', P-FROM-VERSION)) no-error .
if not error-status :error then do:
   v-okk = true .
end.
else do:
  v-okk = false .
end.

if connected ("src") then do:
   disconnect src.
end.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME