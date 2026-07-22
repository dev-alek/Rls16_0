&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME DIALOG-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS DIALOG-1
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Выбор объекта или списка объектов из доступных пользователю объектов

Автор: Белоусов Илья Александрович
Дата создания: 05/08/07
Author: Ilia Belousov
Creation date: 05/08/07

Автор1: Перваков Михаил Сергеевич
Дата создания: 04/05/06

todo - усовершенствовать сохранение в файл, загрузку из файла
todo - добавить кнопку очистить все, выделить все

!!! ВНИМАНИЕ !!!
при сохранении в UIB необходимо вручную изменить описание query
заменить
DEFINE QUERY br-obj FOR
      temp-obj-info SCROLLING.
на код

DEFINE {&NEW} SHARED BUFFER buf_temp-obj-info FOR temp-obj-info .
DEFINE {&NEW} SHARED QUERY br-obj FOR
      buf_temp-obj-info SCROLLING.

*/

/* ***************************  Definitions  ************************** */
define input  parameter parparentproc        as widget-handle no-undo .
define input  parameter p-callback-handle    as handle    no-undo .
define input  parameter p-db-num             as integer   no-undo .
define input  parameter p-user-id            as character no-undo .
define input  parameter p-curr-host-code-obj as integer   no-undo .
define input  parameter p-curr-obj-type      as character no-undo .
define input  parameter p-curr-obj-code      as integer   no-undo .
DEFINE INPUT  PARAMETER p-bttns              AS CHARACTER NO-UNDO.
define output parameter p-user-select        as logical   no-undo .
define output parameter p-select-obj-type    as character no-undo .
define output parameter p-select-obj-code    as integer   no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Выбор объекта или списка объектов из доступных пользователю объектов".
{ cmp/vssrevis.i "substitute('&1|&2':u,parparentproc,p-callback-handle,p-curr-obj-type,p-curr-obj-code,p-curr-host-code-obj,p-user-id)"}
{ cmp/str-glbl.i     }
{ cmp/library.i      }
{ cmp/showinf.i      }
{ gbl/waitfram.i     }
{ gbl/colwidth.i     }
{ gbl/usrfulnf.i     }
{ gbl/usrnickf.i     }
{ gbl/getcntxt.i def }
{ gbl/fltopend.i defproc }

define variable v-list-option      as character no-undo .
define variable v-sort-column-name as character no-undo .

define variable v-brws-mark      as character no-undo COLUMN-LABEL "*"        FORMAT "X(1)":U  .
define variable v-brws-db-num    as character no-undo COLUMN-LABEL "БД"       FORMAT "X(5)":U  .
define variable v-brws-host-code as character no-undo COLUMN-LABEL "Фирма"    FORMAT "X(5)":U  .
define variable v-brws-host-name as character no-undo COLUMN-LABEL "Название" FORMAT "x(30)":U .

define variable v-total-select-num as integer   no-undo .
DEFINE VARIABLE g#log AS  LOGICAL NO-UNDO.
define temp-table temp-user-obj no-undo
  field obj-type as character
  field obj-code as integer

  index xpk is primary unique obj-type obj-code
  .

&scoped-define NEW NEW

&scoped-define define-temp-obj-info define ~{&new~} shared temp-table temp-obj-info no-undo ~
  field obj-type       as character ~
  field obj-code       as integer ~
  field db-num         as integer ~
  field brws-obj-name  as character ~
  field brws-db-num    as character ~
  field brws-host-code as character ~
  field brws-host-name as character ~
  field brws-curr-code as integer ~
  index xpk is primary unique obj-type obj-code ~
  index xie1 brws-obj-name obj-type obj-code ~
  index xie2 brws-db-num obj-type obj-code ~
  index xie3 brws-host-code obj-type obj-code ~
  index xie4 brws-host-name obj-type obj-code ~
  index xie5 brws-curr-code obj-type obj-code ~
  .
{&define-temp-obj-info}

DEFINE BUFFER buf_temp-obj-info FOR temp-obj-info .

define stream sout .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME DIALOG-1
&Scoped-define BROWSE-NAME br-obj

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES buf_temp-obj-info

/* Definitions for BROWSE br-obj                                        */
&Scoped-define FIELDS-IN-QUERY-br-obj mark-string(buf_temp-obj-info.obj-type, buf_temp-obj-info.obj-code) @ v-brws-mark buf_temp-obj-info.obj-type buf_temp-obj-info.obj-code buf_temp-obj-info.brws-obj-name buf_temp-obj-info.brws-db-num buf_temp-obj-info.brws-host-code buf_temp-obj-info.brws-host-name brws-curr-code
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-obj buf_temp-obj-info.obj-type
&Scoped-define ENABLED-TABLES-IN-QUERY-br-obj buf_temp-obj-info
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-br-obj buf_temp-obj-info
&Scoped-define SELF-NAME br-obj
&Scoped-define OPEN-QUERY-br-obj /* OPEN QUERY {&SELF-NAME} FOR EACH buf_temp-obj-info NO-LOCK. */ run local-open-query in this-procedure   (input true   , ~
      input true   , ~
      input '':U   ) .
&Scoped-define TABLES-IN-QUERY-br-obj buf_temp-obj-info
&Scoped-define FIRST-TABLE-IN-QUERY-br-obj buf_temp-obj-info


/* Definitions for DIALOG-BOX DIALOG-1                                  */
&Scoped-define OPEN-BROWSERS-IN-QUERY-DIALOG-1 ~
    ~{&OPEN-QUERY-br-obj}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-sel b-show-obj b-show-host B-list ~
b-action b-menu b-help b-add-sh b-add-st b-add-all b-del b-del-all flt-code ~
br-obj
&Scoped-Define DISPLAYED-OBJECTS mark-num flt-code

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD mark-string DIALOG-1
FUNCTION mark-string RETURNS CHARACTER
  ( p-obj-type as character, p-obj-code as integer )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Menu Definitions                                                     */
DEFINE MENU MENU-B-list
       MENU-ITEM m_list-export  LABEL "Сохранить"
       MENU-ITEM m_list-import  LABEL "Загрузить"     .


/* Definitions of the field level widgets                               */
DEFINE BUTTON b-action
     LABEL "Права"
     SIZE 10 BY 1 TOOLTIP "Права, доступные пользователю на этом объекте".

DEFINE BUTTON b-add-all
     LABEL "Доб.&все"
     SIZE 10 BY 1.

DEFINE BUTTON b-add-sh
     LABEL "Доб.&маг."
     SIZE 10 BY 1.

DEFINE BUTTON b-add-st
     LABEL "Доб.&скл."
     SIZE 10 BY 1.

DEFINE BUTTON b-del
     LABEL "&Удалить"
     SIZE 10 BY 1.

DEFINE BUTTON b-del-all
     LABEL "Удал. все"
     SIZE 10 BY 1.

DEFINE BUTTON b-exit AUTO-END-KEY DEFAULT
     LABEL "&Выход ":L
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-help DEFAULT
     LABEL "Помо&щь"
     SIZE 8.5 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-list
     LABEL "С&писок"
     SIZE 10 BY 1.

DEFINE BUTTON b-mark
     LABEL "*"
     SIZE 3 BY 1.

DEFINE BUTTON b-select-all
     LABEL "+"
     SIZE 3 BY 1 TOOLTIP "Выбрать все".

DEFINE BUTTON b-deselect-all
     LABEL "-"
     SIZE 3 BY 1 TOOLTIP "Отменить выбор".

DEFINE BUTTON b-menu
     LABEL "Меню"
     SIZE 10 BY 1 TOOLTIP "Группы меню, доступные пользователю на этом объекте".

DEFINE BUTTON b-sel AUTO-GO DEFAULT
     LABEL "Вы&бор ":L
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-show-host
     LABEL "&Фирма"
     SIZE 10 BY 1.

DEFINE BUTTON b-show-obj
     LABEL "&Объект"
     SIZE 10 BY 1.

DEFINE VARIABLE flt-code AS INTEGER FORMAT "99999":U INITIAL 0
     LABEL "Фильтр код"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE mark-num AS INTEGER FORMAT ">>>9":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 6 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-obj FOR
      buf_temp-obj-info SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-obj
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-obj DIALOG-1 _FREEFORM
  QUERY br-obj NO-LOCK DISPLAY
      mark-string(buf_temp-obj-info.obj-type, buf_temp-obj-info.obj-code) @ v-brws-mark
      buf_temp-obj-info.obj-type       format 'X(3)':U  column-label "Тип"
      buf_temp-obj-info.obj-code       format '>>>>>>>>9':U column-label "Код"
      buf_temp-obj-info.brws-obj-name  format 'X(60)':U column-label "Название"
      buf_temp-obj-info.brws-db-num    format 'X(9)':U  column-label "БД"
      buf_temp-obj-info.brws-host-code format 'X(9)':U  column-label "Фирма"
      buf_temp-obj-info.brws-host-name format 'X(40)':U column-label "Название фирмы"
      buf_temp-obj-info.brws-curr-code format '>>>>9':U  column-label "Валюта"
ENABLE
      buf_temp-obj-info.obj-type
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 97 BY 15.25 ROW-HEIGHT-CHARS .67.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME DIALOG-1
     b-exit AT ROW 1 COL 1
     mark-num AT ROW 1 COL 9.5 COLON-ALIGNED NO-LABEL
     b-mark AT ROW 1 COL 18
     b-select-all AT ROW 1 COL 21
     b-deselect-all AT ROW 1 COL 24
     b-sel AT ROW 1 COL 27
     b-show-obj AT ROW 1 COL 37
     b-show-host AT ROW 1 COL 47
     B-list AT ROW 1 COL 57
     b-action AT ROW 1 COL 67 WIDGET-ID 4
     b-menu AT ROW 1 COL 77 WIDGET-ID 6
     b-help AT ROW 1 COL 91
     b-add-sh AT ROW 2.08 COL 31
     b-add-st AT ROW 2.08 COL 41
     b-add-all AT ROW 2.08 COL 51
     b-del AT ROW 2.08 COL 61
     b-del-all AT ROW 2.08 COL 71 WIDGET-ID 2
     flt-code AT ROW 2.5 COL 12 COLON-ALIGNED
     br-obj AT ROW 3.75 COL 2
     SPACE(0.99) SKIP(0.62)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Объекты пользователя":L.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX DIALOG-1
   FRAME-NAME                                                           */
/* BROWSE-TAB br-obj flt-code DIALOG-1 */
ASSIGN
       FRAME DIALOG-1:SCROLLABLE       = FALSE.

ASSIGN
       B-list:POPUP-MENU IN FRAME DIALOG-1       = MENU MENU-B-list:HANDLE.

/* SETTINGS FOR BUTTON b-mark IN FRAME DIALOG-1
   NO-ENABLE                                                            */
ASSIGN
       br-obj:NUM-LOCKED-COLUMNS IN FRAME DIALOG-1     = 3.

/* SETTINGS FOR FILL-IN mark-num IN FRAME DIALOG-1
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-obj
/* Query rebuild information for BROWSE br-obj
     _START_FREEFORM
/* OPEN QUERY {&SELF-NAME} FOR EACH buf_temp-obj-info NO-LOCK. */
run local-open-query in this-procedure
  (input true
  ,input true
  ,input '':U
  ) .
     _END_FREEFORM
     _Options          = "NO-LOCK"
     _Query            is OPENED
*/  /* BROWSE br-obj */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME DIALOG-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL DIALOG-1 DIALOG-1
ON GO OF FRAME DIALOG-1 /* Объекты пользователя */
DO:
  run choose-select in this-procedure
    no-error .
  if error-status :error
  then do:
    undo, return no-apply .
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-action
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-action DIALOG-1
ON CHOOSE OF b-action IN FRAME DIALOG-1 /* Права */
DO:
   if available buf_temp-obj-info
   then do:
        run str/usractn1.w ( INPUT parparentproc
                           , INPUT p-user-id
                           , INPUT p-db-num
                           , INPUT buf_temp-obj-info.obj-type
                           , INPUT buf_temp-obj-info.obj-code
                           ) NO-ERROR.
        if error-status :error
        then do:
               message
                     vss-workfile vss-revision vss-description
                  skip(1)
                  skip "Ошибка при изменении прав пользователя на объекте"
                  skip return-value
                  skip trim( error-status :get-message( 1 ) )
                     trim( error-status :get-message( 2 ) )
                     trim( error-status :get-message( 3 ) )
               view-as alert-box error.
           return no-apply.
        end .
   end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-add-all
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-add-all DIALOG-1
ON CHOOSE OF b-add-all IN FRAME DIALOG-1 /* Доб.все */
DO:
  define variable rid as recid no-undo.
  define buffer buf_user-obj     for ub.user-obj.
  define buffer buf_clients      for ub.clients.

  define variable lok as logical   no-undo .
    message
    substitute( "Добавить пользователю &1 все объекты?"
              , usrnickf( p-user-id )
              )
    view-as alert-box question
    buttons OK-Cancel update g#log.

    if not g#log then return no-apply.

    if p-db-num <> 0 then do:
       FOR EACH buf_clients
           where buf_clients.db-num = p-db-num
           and ( buf_clients.obj-type = {&shop}
              OR buf_clients.obj-type = {&stock}
               )
           NO-LOCK:
          IF CAN-FIND (buf_user-obj where buf_user-obj.obj-type = buf_clients.obj-type
                                  and buf_user-obj.obj-code     = buf_clients.obj-code
                                  and buf_user-obj.user-id      = p-user-id
                                  AND buf_user-obj.db-num       = p-db-num
                                no-lock)
                                then next.

          run enbl-obj (buf_clients.obj-type, buf_clients.obj-code).
       end.
    end.
    else do:
       FOR EACH buf_clients
           where
               ( buf_clients.obj-type = {&shop}
              OR buf_clients.obj-type = {&stock}
               )
           NO-LOCK:
          IF CAN-FIND (buf_user-obj where buf_user-obj.obj-type = buf_clients.obj-type
                                  and buf_user-obj.obj-code     = buf_clients.obj-code
                                  and buf_user-obj.user-id      = p-user-id
                                  AND buf_user-obj.db-num       = p-db-num
                                no-lock)
                                then next.

          run enbl-obj (buf_clients.obj-type, buf_clients.obj-code).
       end.
    end.
    run enable_UI.
    run post_enable_UI in this-procedure.
    message
    substitute( "Пользователю &1 добавлены все объекты"
              , usrnickf( p-user-id )
              )
    view-as alert-box.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-add-sh
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-add-sh DIALOG-1
ON CHOOSE OF b-add-sh IN FRAME DIALOG-1 /* Доб.маг. */
DO:
  run ass-obj ({&shop}).
  run enable_UI.
  run post_enable_UI in this-procedure.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-add-st
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-add-st DIALOG-1
ON CHOOSE OF b-add-st IN FRAME DIALOG-1 /* Доб.скл. */
DO:
   run ass-obj ({&stock}).
   run enable_UI.
   run post_enable_UI in this-procedure.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-del DIALOG-1
ON CHOOSE OF b-del IN FRAME DIALOG-1 /* Удалить */
DO:
   define variable v-ok                    as logical      no-undo .
   define variable v-message-text          as character    no-undo .
   define variable v-object-is-current     as logical      no-undo.

   define variable v-cntxt-valid           as logical      no-undo .
   define variable v-cntxt-menu-code       as integer      no-undo .
   define variable v-cntxt-menu-group-code as integer      no-undo .
   define variable v-cntxt-level           as character    no-undo .
   define variable v-cntxt-host-code-obj   as integer      no-undo .
   define variable v-cntxt-obj-type        as character    no-undo .
   define variable v-cntxt-obj-code        as integer      no-undo .

   define buffer buf_user-menu-group      for ub.user-menu-group.

   if available buf_temp-obj-info /*???*/
   then do:
      assign
         v-ok = no
      .
      run gbl/cntxtget.p (
           INPUT  p-db-num
         , INPUT  p-user-id
         , OUTPUT v-cntxt-valid
         , OUTPUT v-cntxt-menu-code
         , OUTPUT v-cntxt-menu-group-code
         , OUTPUT v-cntxt-level
         , OUTPUT v-cntxt-host-code-obj
         , OUTPUT v-cntxt-obj-type
         , OUTPUT v-cntxt-obj-code
      ).
      if  v-cntxt-obj-type = buf_temp-obj-info.obj-type
      and v-cntxt-obj-code = buf_temp-obj-info.obj-code
      then do:
         assign
               v-message-text = "Удаляемый объект - текущий для данного пользователя.~n".
               v-object-is-current = yes
         .
      end.
      else do:
         assign
               v-object-is-current = no
         .
      end.
      assign
         v-message-text = v-message-text + "Удалить объект (сделать его недоступным для данного пользователя) ?"
      .
      message
         v-message-text
      view-as alert-box question
      buttons ok-cancel
      update v-ok.
      if v-ok = yes
      then do:
         run delete-record in this-procedure (
                 input buf_temp-obj-info.db-num
               , input buf_temp-obj-info.obj-type
               , input buf_temp-obj-info.obj-code
         ) no-error.
         if error-status :error
         then do:
               message
                     vss-workfile vss-revision vss-description
                  skip(1)
                  skip "Ошибка удаления записи."
                  skip return-value
                  skip trim( error-status :get-message( 1 ) )
                     trim( error-status :get-message( 2 ) )
                     trim( error-status :get-message( 3 ) )
               view-as alert-box error.
               undo, return no-apply.
         end.
         /*
         if v-object-is-current = yes
         then do:
               find first buf_user-menu-group
                    where buf_user-menu-group.db-num
                      and buf_user-menu-group.user-id
                      and buf_user-menu-group

                    no-lock
                    no-error
                    .
               run gbl/cntxtstr.p (
                  input  p-db-num
                  , input  p-user-id
                  , input  v-cntxt-menu-code
                  , input  v-cntxt-menu-group-code
                  , input  {&cntxt-firm}
                  , input  v-cntxt-host-code-obj
                  , input  ""
                  , input  ""
               ).
               message "Удален текущий объект для данного пользователя." skip (2)
                     "Пользователю по умолчанию выставлен контекст фирмы"
               view-as alert-box information.
         end. /* v-object-is-current = yes */
         */
         run enable_UI.
         run post_enable_UI in this-procedure.
      end. /* v-ok */
   end. /* available buf_temp-obj-info */
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-del-all
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-del-all DIALOG-1
ON CHOOSE OF b-del-all IN FRAME DIALOG-1 /* Удал. все */
DO:
   define buffer buf_user-obj    for ub.user-obj.

   define variable v-ok                    as logical      no-undo .
   define variable v-message-text          as character    no-undo .

   define variable v-cntxt-valid           as logical      no-undo .
   define variable v-cntxt-menu-code       as integer      no-undo .
   define variable v-cntxt-menu-group-code as integer      no-undo .
   define variable v-cntxt-level           as character    no-undo .
   define variable v-cntxt-host-code-obj   as integer      no-undo .
   define variable v-cntxt-obj-type        as character    no-undo .
   define variable v-cntxt-obj-code        as integer      no-undo .
   assign
      v-message-text = v-message-text + "Удалить объект (сделать его недоступным для данного пользователя) ?"
   .
   message
      v-message-text
   view-as alert-box question
   buttons ok-cancel
   update v-ok.
   if v-ok = yes
   then do:
      for each  buf_user-obj
         where buf_user-obj.db-num = p-db-num
            and buf_user-obj.user-id = p-user-id
         no-lock
         :

         run delete-record in this-procedure (
               input buf_user-obj.db-num
               , input buf_user-obj.obj-type
               , input buf_user-obj.obj-code
         ) no-error.
         if error-status :error
         then do:
               message
                     vss-workfile vss-revision vss-description
                  skip(1)
                  skip "Ошибка удаления записи."
                  skip return-value
                  skip trim( error-status :get-message( 1 ) )
                     trim( error-status :get-message( 2 ) )
                     trim( error-status :get-message( 3 ) )
               view-as alert-box error.
               undo, return no-apply.
         end.
         run enable_UI.
         run post_enable_UI in this-procedure.
      end. /* for each buf_user-obj */
      /*
      run gbl/cntxtstr.p (
         input  p-db-num
         , input  p-user-id
         , input  v-cntxt-menu-code
         , input  v-cntxt-menu-group-code
         , input  {&cntxt-firm}
         , input  v-cntxt-host-code-obj
         , input  ""
         , input  ""
      ).
      message "Удален текущий объект для данного пользователя." skip (2)
            "Пользователю по умолчанию выставлен контекст фирмы"
      view-as alert-box information.
      */
   end. /* v-ok */
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit DIALOG-1
ON CHOOSE OF b-exit IN FRAME DIALOG-1 /* Выход  */
DO:
  run check-selection in this-procedure
    no-error .
  if error-status :error
  then do:
    return no-apply.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-list
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-list DIALOG-1
ON CHOOSE OF B-list IN FRAME DIALOG-1 /* Список */
DO:
  if v-list-option = ""
  then do:
    run gbl/pop-up.p (self:handle, no) no-error.
    if error-status:error then return no-apply.
  end.
  if v-list-option = ""
  then do:
    return no-apply.
  end.
  run proc-b-list in this-procedure
    (input v-list-option
    ) no-error.
  if error-status :error
  then do:
    return no-apply.
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-mark DIALOG-1
ON CHOOSE OF b-mark IN FRAME DIALOG-1 /* * */
DO:
  run choose-mark in this-procedure
    no-error .
  if error-status :error
  then do:
    return no-apply .
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME b-select-all
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-select-all DIALOG-1
ON CHOOSE OF b-select-all IN FRAME DIALOG-1 /* * */
DO:
  run choose-all in this-procedure
    no-error .
  if error-status :error
  then do:
    return no-apply .
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-deselect-all
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-deselect-all DIALOG-1
ON CHOOSE OF b-deselect-all IN FRAME DIALOG-1 /* * */
DO:
  run de-choose-all in this-procedure
    no-error .
  if error-status :error
  then do:
    return no-apply .
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME b-menu
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-menu DIALOG-1
ON CHOOSE OF b-menu IN FRAME DIALOG-1 /* Меню */
DO:
   if available buf_temp-obj-info
   then do:
        run str/usrmngr1.w ( INPUT parparentproc
                           , INPUT p-db-num
                           , INPUT p-user-id
                           , INPUT buf_temp-obj-info.obj-type
                           , INPUT buf_temp-obj-info.obj-code
                           ) NO-ERROR.
        if error-status :error
        then do:
               message
                     vss-workfile vss-revision vss-description
                  skip(1)
                  skip "Ошибка при изменении групп меню пользователя на объекте"
                  skip return-value
                  skip trim( error-status :get-message( 1 ) )
                     trim( error-status :get-message( 2 ) )
                     trim( error-status :get-message( 3 ) )
               view-as alert-box error.
           return no-apply.
        end .
   end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-show-host
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-show-host DIALOG-1
ON CHOOSE OF b-show-host IN FRAME DIALOG-1 /* Фирма */
DO:
  define variable v-host-code as integer   no-undo .
  if available buf_temp-obj-info
  then do:
    { gbl/hostcode.i
      buf_temp-obj-info.obj-type
      buf_temp-obj-info.obj-code
      v-host-code
    }
    run ref/showcli.p
      (input  parparentproc
      ,input  {&cmp}
      ,input  v-host-code
      ) .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-show-obj
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-show-obj DIALOG-1
ON CHOOSE OF b-show-obj IN FRAME DIALOG-1 /* Объект */
DO:
  if available buf_temp-obj-info
  then do:
    run ref/showcli.p
      (input  parparentproc
      ,input  buf_temp-obj-info.obj-type
      ,input  buf_temp-obj-info.obj-code
      ) .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-obj
&Scoped-define SELF-NAME br-obj
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-obj DIALOG-1
ON VALUE-CHANGED OF br-obj IN FRAME DIALOG-1
DO:
  run update-br-obj-dependent in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME flt-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL flt-code DIALOG-1
ON CTRL-J OF flt-code IN FRAME DIALOG-1 /* Фильтр код */
DO:
  define variable v-find-next as logical   no-undo .

  if flt-code <> input frame {&frame-name} flt-code
  then do:
    assign
      v-find-next = false
    .
  end.
  else do:
    assign
      v-find-next = true
    .
  end.

  do with frame {&frame-name}:
    assign
      flt-code
    .
  end. /* do with frame */

  run local-open-query in this-procedure
    (input false /* p-open-query */
    ,input v-find-next  /* p-find-next  */
    ,input substitute('and buf_temp-obj-info.obj-code = &1':U
                      ,flt-code
                      )
    ).
  apply "entry":u to self .
  return no-apply .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL flt-code DIALOG-1
ON RETURN OF flt-code IN FRAME DIALOG-1 /* Фильтр код */
DO:
  assign
    flt-code
  .
  run local-open-query in this-procedure
    (input false /* p-open-query */
    ,input false  /* p-find-next  */
    ,input substitute('and buf_temp-obj-info.obj-code = &1':U
                      ,flt-code
                      )
    ).
  apply "entry" to self .
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_list-export
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_list-export DIALOG-1
ON CHOOSE OF MENU-ITEM m_list-export /* Сохранить */
DO:
  assign
    v-list-option = "save":U
  .
  run proc-b-list
    (input v-list-option
    ) no-error.
  if error-status :error
  then do:
    return no-apply.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_list-import
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_list-import DIALOG-1
ON CHOOSE OF MENU-ITEM m_list-import /* Загрузить */
DO:
  assign
    v-list-option = "load":U
  .
  run proc-b-list in this-procedure
    (input v-list-option
    ) no-error.
  if error-status :error
  then do:
    return no-apply.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK DIALOG-1


/* ***************************  Main Block  *************************** */

IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

{ gbl/app_help.i }

{ gbl/brwrepos.i
  &line-num=6
}
{ gbl/brwrefre.i }
{ gbl/hot-key.i b-mark }
{ gbl/hot-key.i b-del }

{ gbl/mv-clmn.i
  &frame-name = "{&frame-name}"
  &browse-name = "{&browse-name}"
  &table-name = "{&first-table-in-query-{&browse-name}}"
  &start-column = 4
  &ext-col = 7
}

{ gbl/srt-clmd.i
  &browse-name       = "{&browse-name}"
  &frame-name        = "{&frame-name}"
  &table-name        = "{&first-table-in-query-{&browse-name}}"
  &sort-clmn_1       = "v-brws-mark"
  &dyn_sort-clmn_1   = "v-brws-mark"
  &sort-clmn_2       = "buf_temp-obj-info.brws-obj-name"
  &sort-clmn_3       = "buf_temp-obj-info.brws-db-num"
  &sort-clmn_4       = "buf_temp-obj-info.brws-host-code"
  &sort-clmn_5       = "buf_temp-obj-info.brws-host-name"
  &sort-clmn_6       = "buf_temp-obj-info.brws-curr-code"
  &open-query        = "{&OPEN-BROWSERS-IN-QUERY-DIALOG-1}"
  &open-query-otherwise = "{&OPEN-BROWSERS-IN-QUERY-DIALOG-1}"
  &sort-column-name = "v-sort-column-name"
  &re-move-clmn   = "no"
  &mv-brw-default = "no"
}
{ gbl/getcntxt.i get }


on any-printable of browse {&browse-name}
do:
  define variable v-number as integer   no-undo .
  assign
    v-number =  lookup(string(lastkey), string(keycode("0"))
                      + {&comma-char} + string(keycode("1"))
                      + {&comma-char} + string(keycode("2"))
                      + {&comma-char} + string(keycode("3"))
                      + {&comma-char} + string(keycode("4"))
                      + {&comma-char} + string(keycode("5"))
                      + {&comma-char} + string(keycode("6"))
                      + {&comma-char} + string(keycode("7"))
                      + {&comma-char} + string(keycode("8"))
                      + {&comma-char} + string(keycode("9"))
                      ) - 1
  .
  if v-number >= 0
  then do:
    do with frame {&frame-name}
    :
      assign
        flt-code :screen-value = string(v-number)
      .
    end.
    apply "entry":u to flt-code .
    apply "end":u to flt-code .
  end.
end.

define variable v-ok as logical   no-undo .
assign
  v-ok = browse {&browse-name} :set-repositioned-row(5, 'CONDITIONAL':U)
.

ON WINDOW-CLOSE OF FRAME {&FRAME-NAME} APPLY "END-ERROR":U TO SELF.

on return, MOUSE-SELECT-DBLCLICK of br-obj in frame {&frame-name}
do:
  if b-mark:sensitive
  then do:
    apply "choose" to b-mark in frame {&frame-name}.
  end.
  else do:
     if b-sel:sensitive
     then do:
       apply "choose" to b-sel in frame {&frame-name}.
     end.
  end.
end.

{ gbl/hot-key.i b-sel }
{ gbl/hot-key.i b-mark }

MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
:
   ASSIGN
      FRAME {&frame-name}:TITLE = SUBSTITUTE ( "Объекты пользователя &1", usrnickf( p-user-id ) )
   .
  assign
    buf_temp-obj-info.obj-type :read-only in browse {&BROWSE-NAME} = true
  .

  run check-input-parameters in this-procedure
    no-error .
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "База данных" p-db-num skip
      "Идентификатор пользователя" p-user-id skip
      "Код фирмы" p-curr-host-code-obj skip
      "Объект" p-curr-obj-type p-curr-obj-code skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return error return-value .
  end.

  assign
    p-user-select = false
  .

  run fill-temp-table in this-procedure .

  assign
    buf_temp-obj-info.brws-obj-name  :resizable in browse br-obj = true
    buf_temp-obj-info.brws-host-name :resizable in browse br-obj = true
  .

  define variable v-colwidth-data-exist as logical   no-undo .

  { gbl/colw_rd.i
    p-db-num
    p-user-id
    'gbl/userobjs.w':U
    v-colwidth-data-exist
  }
  if v-colwidth-data-exist = true
  then do:
    assign
      buf_temp-obj-info.brws-obj-name  :width in browse br-obj = 30
      buf_temp-obj-info.brws-host-name :width in browse br-obj = 35
    .
  end.
  else do:
    assign
      buf_temp-obj-info.brws-obj-name  :width in browse br-obj = 30
      buf_temp-obj-info.brws-host-name :width in browse br-obj = 35
    .
  end.

  RUN enable_UI .
  run post_enable_UI in this-procedure.

  /* запрашиваем список объектов */
  if can-do ( p-bttns, "b-mark")
  then do:
    run userobjs_transfer in p-callback-handle
      (input this-procedure :handle
      ) .

    run display-select-num in this-procedure .
  end.
  else do:
    hide mark-num in frame {&frame-name}.
  end.

  /* todo проверяем правильность переданного списка объектов */

/*  if v-error-rid-list <> ""*/
/*  then do:*/
/*    message*/
/*      vss-workfile vss-revision vss-description skip*/
/*      "Ошибка задания входных параметров" skip*/
/*      "Передан ошибочный код записи" v-error-rid-list skip*/
/*      "Список вызывающих программ" skip*/
/*      "" program-name(1) skip*/
/*      "" program-name(2) skip*/
/*      "" program-name(3) skip*/
/*      "" skip*/
/*      "Сохраните изображение ошибки и сообщите информацию об ошибке в службу поддержки" skip*/
/*      "Работа продолжит свою программу" skip*/
/*      view-as alert-box error .*/
/*    undo, return error return-value .*/
/*  end.*/

  assign
    b-list:menu-mouse in frame {&frame-name} = 1
  .


  if p-curr-obj-type = "":U
  or p-curr-obj-type = ?
  or p-curr-obj-code = 0
  or p-curr-obj-code = ?
  then do:
    reposition {&browse-name} to row 1 no-error .
  end.
  else do:
    define buffer buf_select_temp-obj-info for temp-obj-info .

    find first buf_select_temp-obj-info no-lock
      where buf_select_temp-obj-info.obj-type = p-curr-obj-type
        and buf_select_temp-obj-info.obj-code = p-curr-obj-code
      no-error .
    if available buf_select_temp-obj-info
    then do:
      reposition {&browse-name} to rowid rowid(buf_select_temp-obj-info) no-error .
      if error-status :error
      then do:
        reposition {&browse-name} to row 1 no-error .
      end.
    end.
  end.

  run update-br-obj-dependent in this-procedure .

  apply "entry" to br-obj in frame {&frame-name}.

  wait-for go of frame {&frame-name} focus br-obj.
END.

assign
  v-colwidth-width-01 = buf_temp-obj-info.brws-obj-name  :width in browse br-obj
  v-colwidth-width-02 = buf_temp-obj-info.brws-host-name :width in browse br-obj
.

{ gbl/colw_wr.i }

RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ass-obj DIALOG-1
PROCEDURE ass-obj :
/* -----------------------------------------------------------------------------------------------------------------------------
  Purpose:     добавление объектов заданного типа
-------------------------------------------------------------------------------------------------------------------------------- */
  define input param o-type like ub.clients.obj-type no-undo.

  define variable rid-list as char init "" no-undo.
  define variable rid as recid no-undo.
  define variable num-rec as integer init 0 no-undo.
  define variable lok as logical   no-undo .
  define buffer buf_clients      for ub.clients .
  define buffer buf_user-obj     for ub.user-obj .
  define buffer buf_shop      for ub.shop .
  define buffer buf_store     for ub.store .
  define variable v-first-ubd    as logical      no-undo.

DO
ON ERROR   UNDO, RETURN ERROR
:

  /* !!!
  r u n chk-acta.p
    ( input yes            /* fict     */
     ,input 'назначение-прав':U /* obj      */
     ,input 'ИЗМЕНЕНИЕ':U        /* action   */
     ,input yes            /* show-msg */
     ,output lok           /* OK       */
    ).
  if lok <> true
  then do:
    return . /* Отсутствуют права на установку прав" */
  end.
  */

  case o-type :
    when {&stock} then run adm/stores.w ( parparentproc
                                       , "b-sel,b-mark"
                                       , input-output rid-list
                                       , (if v-cntxt-db-num = 0 then no else yes)
                                       ) .
    when {&shop} then run adm/shops.w  ( parparentproc
                                       , "b-sel,b-mark"
                                       , input-output rid-list
                                       , (if v-cntxt-db-num = 0 then no else yes)).
  end case.
  if rid-list <> ""
  then do :
    /* !!!
    message "Выберите группу прав для этих объектов." view-as alert-box.
    r u n grpa.p ("b-sel", 'объ':U, output rid).
    if rid = ?
    then do:
      message "Группа прав не выбрана." view-as alert-box.
      return.
    end.
    */
    _shop:
    do num-rec = 1 to num-entries (rid-list):
      if o-type = {&shop}
      then do:
        find buf_shop where recid (buf_shop) = integer (entry (num-rec, rid-list)) no-lock.
        find first buf_clients
             where buf_clients.obj-type = {&shop}
               and buf_clients.obj-code = buf_shop.obj-code
        no-lock
        no-error
        .
        IF NOT AVAILABLE buf_clients THEN DO:
           NEXT _shop.
        END.

        IF  p-db-num  <> 0
        AND  buf_clients.db-num <> p-db-num
        then do:
         IF NOT v-first-ubd
         then do:
               assign
                  v-first-ubd = TRUE
               .
               message
                  "Будут добавлены только объекты текущей БД."
                  skip "Объекты других БД возможно добавлять только в ГБД."
               view-as alert-box information.
         end.
         next _shop.
        end.

        IF CAN-FIND (buf_user-obj where buf_user-obj.obj-type = buf_clients.obj-type
                                 and buf_user-obj.obj-code     = buf_clients.obj-code
                                 and buf_user-obj.user-id      = p-user-id
                                 AND buf_user-obj.db-num       = p-db-num
                              no-lock)
                              then next _shop.
        run enbl-obj (o-type, buf_shop.obj-code).
      end.
      else do:
        find buf_store where recid (buf_store) = integer (entry (num-rec, rid-list)) no-lock.
        find first buf_clients
             where buf_clients.obj-type = {&stock}
               and buf_clients.obj-code = buf_store.obj-code
        no-lock
        no-error
        .
        IF NOT AVAILABLE buf_clients THEN DO:
           NEXT _shop.
        END.

        IF  p-db-num  <> 0
        AND  buf_clients.db-num <> p-db-num
        then do:
         IF NOT v-first-ubd
         then do:
               assign
                  v-first-ubd = TRUE
               .
               message
                  "Будут добавлены только объекты текущей БД."
                  skip "Объекты других БД возможно добавлять только в ГБД."
               view-as alert-box information.
         end.
         next _shop.
        end.

        IF CAN-FIND (buf_user-obj where buf_user-obj.obj-type = buf_clients.obj-type
                                 and buf_user-obj.obj-code     = buf_clients.obj-code
                                 and buf_user-obj.user-id      = p-user-id
                                 AND buf_user-obj.db-num       = p-db-num
                              no-lock)
                              then next _shop.
        run enbl-obj (o-type, buf_store.obj-code).
      end.
    end.

  end.
END. /* DO ON ERROR */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE check-input-parameters DIALOG-1
PROCEDURE check-input-parameters :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/

  define buffer buf_user-login for ub.user-login .

  do
  on error undo, return error return-value
  :
    if p-db-num = ?
    then do:
      undo, return error "Не задан номер базы данных" .
    end.

    if p-user-id = ?
    or p-user-id = ""
    then do:
      undo, return error "Не задан идентификтор пользователя" .
    end.

    find first buf_user-login no-lock
      where buf_user-login.db-num  = p-db-num
        and buf_user-login.user-id = p-user-id
      no-error .
    if not available buf_user-login
    then do:
      undo, return error substitute("Не найден логин пользователя &1 &2"
                                   ,p-db-num
                                   ,p-user-id
                                   ) .
    end.

/*      "База данных" p-db-num skip*/
/*      "Идентификатор пользователя" p-user-id skip*/
/*      "Код фирмы" p-curr-host-code-obj skip*/
/*      "Объект" p-curr-obj-type p-curr-obj-code skip*/
/*      "Выбор одного объекта" p-select-one skip*/


  end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE check-selection DIALOG-1
PROCEDURE check-selection :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define variable v-ok as logical   no-undo .

  define buffer buf_temp-user-obj for temp-user-obj .

  do
  on error undo, return error return-value
  :
    do with frame {&frame-name}
    :
      if can-do (p-bttns, "b-mark")
      then do:
        find first buf_temp-user-obj
          no-error .

        if available buf_temp-user-obj
        then do:
          message
            "Информация о выбранных элементах будет потеряна" Skip
            "Продолжить?" Skip
            view-as alert-box question buttons yes-no update v-ok .
          if v-ok = true
          then do:
            for each buf_temp-user-obj
            on error undo, return error return-value
            :
              delete buf_temp-user-obj .
            end.
          end.
          else do:
            undo, return error return-value .
          end.
        end.
      end.
    end.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE choose-mark DIALOG-1
PROCEDURE choose-mark :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define variable v-log as logical no-undo .

  define buffer buf_temp-user-obj for temp-user-obj .

  do
  on error undo, return error return-value
  :
    if available buf_temp-obj-info
    then do:
      find first buf_temp-user-obj
        where buf_temp-user-obj.obj-type = buf_temp-obj-info.obj-type
          and buf_temp-user-obj.obj-code = buf_temp-obj-info.obj-code
        no-error .
      if available buf_temp-user-obj
      then do:
        run userobjs_delete in this-procedure
          (input  buf_temp-obj-info.obj-type
          ,input  buf_temp-obj-info.obj-code
          ) .
      end.
      else do:
        run userobjs_append in this-procedure
          (input  buf_temp-obj-info.obj-type
          ,input  buf_temp-obj-info.obj-code
          ) .
      end.

      v-log = br-obj:refresh() in frame {&frame-name}.
      if last-event :function <> "MOUSE-SELECT-DBLCLICK"
      then do:
        v-log = br-obj:select-next-row ().
        apply "iteration-changed" to br-obj in frame {&frame-name}.
      end.

      run display-select-num in this-procedure .

      apply "entry" to br-obj in frame {&frame-name}.
    end.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE choose-all DIALOG-1
PROCEDURE choose-all :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define variable v-log as logical no-undo .

  define buffer buf_temp-user-obj for temp-user-obj .

  do
  on error undo, return error return-value
  :
    if available buf_temp-obj-info
    then do:
      for each buf_temp-obj-info no-lock :
        find first buf_temp-user-obj
          where buf_temp-user-obj.obj-type = buf_temp-obj-info.obj-type
            and buf_temp-user-obj.obj-code = buf_temp-obj-info.obj-code
          no-error .
        if not available buf_temp-user-obj
        then do:
          run userobjs_append in this-procedure
            (input  buf_temp-obj-info.obj-type
            ,input  buf_temp-obj-info.obj-code
            ) .
        end.
      end.
        v-log = br-obj:refresh() in frame {&frame-name}.

        run display-select-num in this-procedure .

        apply "entry" to br-obj in frame {&frame-name}.
    end.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE de-choose-all DIALOG-1
PROCEDURE de-choose-all :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define variable v-log as logical no-undo .

  define buffer buf_temp-user-obj for temp-user-obj .

  do
  on error undo, return error return-value
  :
    if available buf_temp-obj-info
    then do:
      for each buf_temp-obj-info no-lock :
        find first buf_temp-user-obj
          where buf_temp-user-obj.obj-type = buf_temp-obj-info.obj-type
            and buf_temp-user-obj.obj-code = buf_temp-obj-info.obj-code
          no-error .
        if available buf_temp-user-obj
        then do:
          run userobjs_delete in this-procedure
            (input  buf_temp-obj-info.obj-type
            ,input  buf_temp-obj-info.obj-code
            ) .
        end.
      end.
        v-log = br-obj:refresh() in frame {&frame-name}.

        run display-select-num in this-procedure .

        apply "entry" to br-obj in frame {&frame-name}.
    end.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE choose-select DIALOG-1
PROCEDURE choose-select :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/

  define buffer buf_temp-user-obj for temp-user-obj .

  do
  on error undo, return error return-value
  :
    do with frame {&frame-name}
    :
      if available buf_temp-obj-info
      then do:
        if NOT can-do (p-bttns, "b-mark")
        then do:
          assign
            p-select-obj-type = buf_temp-obj-info.obj-type
            p-select-obj-code = buf_temp-obj-info.obj-code
          .
        end.
        else do:
          find first buf_temp-user-obj
            no-error .
          if not available buf_temp-user-obj
          then do:
            run userobjs_append in this-procedure
              (input  buf_temp-obj-info.obj-type
              ,input  buf_temp-obj-info.obj-code
              ) .
          end.

          run userobjs_clear in p-callback-handle .

          for each buf_temp-user-obj
          on error undo, return error return-value
          :
            run userobjs_append in p-callback-handle
              (input  buf_temp-user-obj.obj-type
              ,input  buf_temp-user-obj.obj-code
              ) .
          end.
        end.
      end.
    end.

    assign
      p-user-select = true
    .
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE delete-record DIALOG-1
PROCEDURE delete-record :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-db-num     as integer          no-undo.
define input parameter p-obj-type   as character        no-undo.
define input parameter p-obj-code   as integer          no-undo.

    define buffer buf_user-obj      for ub.user-obj.
    define buffer buf_temp-obj-info for temp-obj-info.
do
for buf_user-obj
  , buf_temp-obj-info
on error undo, return error
:
   find first buf_user-obj exclusive-lock
         WHERE buf_user-obj.db-num   = p-db-num
         AND buf_user-obj.user-id  = p-user-id
         AND buf_user-obj.obj-type = p-obj-type
         AND buf_user-obj.obj-code = p-obj-code
   no-error.
   if available buf_user-obj
   then do:
      delete buf_user-obj.
      find first buf_temp-obj-info
            where buf_temp-obj-info.obj-type = p-obj-type
               and buf_temp-obj-info.obj-code = p-obj-code
      .
      delete buf_temp-obj-info.
   end.
end.
END PROCEDURE. /* delete-record */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI DIALOG-1  _DEFAULT-DISABLE
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
  HIDE FRAME DIALOG-1.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE display-select-num DIALOG-1
PROCEDURE display-select-num :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  do
  on error undo, return error return-value
  :
    assign
      mark-num = v-total-select-num
    .

    if v-total-select-num = 0
    then do:
      hide
        mark-num
        in frame {&frame-name}.
    end.
    else do:
      display
        mark-num
        with frame {&frame-name}.
    end.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI DIALOG-1  _DEFAULT-ENABLE
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
  DISPLAY mark-num flt-code
      WITH FRAME DIALOG-1.
  ENABLE b-exit b-sel b-show-obj b-show-host B-list b-action b-menu b-help
         b-add-sh b-add-st b-add-all b-del b-del-all flt-code br-obj
      WITH FRAME DIALOG-1.
  {&OPEN-BROWSERS-IN-QUERY-DIALOG-1}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enbl-obj DIALOG-1
PROCEDURE enbl-obj :
/* -----------------------------------------------------------
  Purpose:     добавление 1 объекта
-------------------------------------------------------------*/
define input param o-type   as char no-undo.
define input param o-code   as integer no-undo.

    define variable v-host-code    as integer      no-undo.
    define variable v-host-name    as character    no-undo.
    define variable v-base-code    as integer      no-undo.

    define buffer buf_user-obj      for ub.user-obj.
    define buffer buf_user-host     for ub.user-host.
    define buffer buf_clients       for ub.clients.
do
for buf_user-obj
  , buf_user-host
  , buf_clients
on error undo, return error
:
    find first buf_user-obj exclusive-lock
         where buf_user-obj.db-num    = p-db-num
           and buf_user-obj.user-id   = p-user-id
           and buf_user-obj.obj-type  = o-type
           and buf_user-obj.obj-code  = o-code
    no-error.
    if not available buf_user-obj
    then do:
        find first buf_clients no-lock
             where buf_clients.obj-type = o-type
               and buf_clients.obj-code = o-code
        .
        { gbl/hostname.i
            o-type
            o-code
            v-host-code
            v-host-name
        }
         { gbl/basecode.i
            v-host-code
            v-base-code
         }

        create buf_user-obj.
        assign
            buf_user-obj.db-num    = p-db-num
            buf_user-obj.user-id   = p-user-id
            buf_user-obj.obj-type  = o-type
            buf_user-obj.obj-code  = o-code
            buf_user-obj.host-code = v-host-code
        .
        create buf_temp-obj-info .
        assign
            buf_temp-obj-info.obj-type        = o-type
            buf_temp-obj-info.obj-code        = o-code
            buf_temp-obj-info.db-num          = p-db-num
            buf_temp-obj-info.brws-obj-name   = buf_clients.obj-name
            buf_temp-obj-info.brws-db-num     = string(buf_clients.db-num)
            buf_temp-obj-info.brws-host-code  = string(buf_clients.host-code)
            buf_temp-obj-info.brws-host-name  = v-host-name
            buf_temp-obj-info.brws-curr-code  = v-base-code
        .
        find first buf_user-host exclusive-lock
             where buf_user-host.db-num    = p-db-num
               and buf_user-host.user-id   = p-user-id
               and buf_user-host.host-code = v-host-code
        no-error.
        if not available buf_user-host
        then do:
            create buf_user-host.
            assign
                buf_user-host.db-num    = p-db-num
                buf_user-host.user-id   = p-user-id
                buf_user-host.host-code = v-host-code
            .
        end.
   end.     /* not available buf_user-obj */
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-temp-table DIALOG-1
PROCEDURE fill-temp-table :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/

  define buffer buf_user-obj               for ub.user-obj .
  define buffer buf_action-post            for ub.action-post .
  define buffer buf_action-post-obj        for ub.action-post-obj .
  define buffer buf_action-post-user-login for ub.action-post-user-login .
  define buffer buf_temp-obj-info          for temp-obj-info .

  define variable v-check-db-num        as integer   no-undo .
  define variable v-check-user-id       as character no-undo .
  define variable v-check-administrator as logical   no-undo .

  do
  on error undo, return error return-value
  :
    { gbl/usercred.i
      p-db-num
      p-user-id
      v-check-db-num
      v-check-user-id
      v-check-administrator
      no-error
    }
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры gbl/usercred.i" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.


    for each buf_user-obj no-lock
      where buf_user-obj.db-num  = v-check-db-num
        and buf_user-obj.user-id = p-user-id
    on error undo, return error return-value
    :
      run temp-obj-info-append in this-procedure
        ( input buf_user-obj.obj-type
        , input buf_user-obj.obj-code
        , input buf_user-obj.db-num
        ) .
    end.

    for each buf_action-post-user-login no-lock
      where buf_action-post-user-login.db-num           = v-check-db-num
        and buf_action-post-user-login.action-head-code = {&action-head-code-main}
        and buf_action-post-user-login.user-id          = p-user-id
    on error undo, return error return-value
    :
      for each buf_action-post-obj no-lock
        where buf_action-post-obj.db-num           = buf_action-post-user-login.db-num
          and buf_action-post-obj.action-head-code = buf_action-post-user-login.action-head-code
          and buf_action-post-obj.action-post-code = buf_action-post-user-login.action-post-code
      on error undo, return error return-value
      :
        run temp-obj-info-append in this-procedure
          ( input buf_user-obj.obj-type
          , input buf_user-obj.obj-code
          , input buf_user-obj.db-num
          ) .
      end.
    end.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-mark-string DIALOG-1
PROCEDURE get-mark-string :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define input  parameter p-obj-type    as character no-undo .
  define input  parameter p-obj-code    as integer   no-undo .
  define output parameter p-mark-string as character no-undo .

  define buffer buf_temp-user-obj for temp-user-obj .

  do
  on error undo, return error return-value
  :
    find first buf_temp-user-obj
      where buf_temp-user-obj.obj-type = p-obj-type
        and buf_temp-user-obj.obj-code = p-obj-code
      no-error .
    if available buf_temp-user-obj
    then do:
      assign
        p-mark-string = '*':U
      .
    end.
    else do:
      assign
        p-mark-string = '':U
      .
    end.

  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-open-query DIALOG-1
PROCEDURE local-open-query :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define input  parameter p-open-query     as logical   no-undo .
  define input  parameter p-find-next      as logical   no-undo .
  define input  parameter p-find-condition as character no-undo .

  define variable v-restore-position   as logical   no-undo .
  define variable v-current-obj-type   as character no-undo .
  define variable v-current-obj-code   as integer   no-undo .
  define variable v-prt-rec            as recid     no-undo .
  define variable v-sort-column-phrase as character no-undo .

  define buffer buf_reposition_temp-obj-info for temp-obj-info .

  do
  on error undo, return error return-value
  :
    if available buf_temp-obj-info
    then do:
      assign
        v-restore-position = true
        v-current-obj-type = buf_temp-obj-info.obj-type
        v-current-obj-code = buf_temp-obj-info.obj-code
      .
    end.
    else do:
      assign
        v-restore-position = false
        v-current-obj-type = '':U
        v-current-obj-code = 0
      .
    end.

    if v-sort-column-name <> '':U
    then do:
      case v-sort-column-name
      :
        when 'v-brws-mark':U
        then do:
          assign
            v-sort-column-phrase = 'by mark-string(buf_temp-obj-info.obj-type, buf_temp-obj-info.obj-code) by buf_temp-obj-info.obj-type by buf_temp-obj-info.obj-code':U
          .
        end.
        when 'temp-obj-info.brws-obj-name':U
        then do:
          assign
            v-sort-column-phrase = 'by buf_temp-obj-info.brws-obj-name by buf_temp-obj-info.obj-type by buf_temp-obj-info.obj-code':U
          .
        end.
        when 'temp-obj-info.brws-db-num':U
        then do:
          assign
            v-sort-column-phrase = 'by buf_temp-obj-info.brws-db-num by buf_temp-obj-info.obj-type by buf_temp-obj-info.obj-code':U
          .
        end.
        when 'temp-obj-info.brws-host-code':U
        then do:
          assign
            v-sort-column-phrase = 'by buf_temp-obj-info.brws-host-code by buf_temp-obj-info.obj-type by buf_temp-obj-info.obj-code':U
          .
        end.
        when 'temp-obj-info.brws-host-name':U
        then do:
          assign
            v-sort-column-phrase = 'by buf_temp-obj-info.brws-host-name by buf_temp-obj-info.obj-type by buf_temp-obj-info.obj-code':U
          .
        end.
        otherwise do:
          assign
            v-sort-column-phrase = substitute('by &1':U
                                             ,v-sort-column-name
                                             )
          .
        end.
      end case.
    end.
    else do:
      assign
        v-sort-column-phrase = '':U
      .
    end.

&scoped-define NEW

&scop flt-open-open-query           open query br-obj for each buf_temp-obj-info
&scop flt-open-query-handle         query br-obj:handle
&scop flt-open-dyn_open-query       for each buf_temp-obj-info
&scop flt-open-open-query-tail
&scop flt-open-query-was-opened     v-query-was-opened
&scop flt-open-sort-column-phrase   v-sort-column-phrase
&scop flt-open-call-point           'userobjs':U
&scop flt-open-set-filter-name
&scop flt-open-indexed-reposition   indexed-reposition
&scop flt-open-debug-file
&scop flt-open-query                p-open-query
&scop flt-open-table-name           buf_temp-obj-info
&scop flt-open-search-option        no-lock

&scop flt-open-find-debug-file
&scop flt-open-find-next            p-find-next
&scop flt-open-find-recid           v-prt-rec
&scop flt-open-find-condition       p-find-condition
&scop flt-open-find-buffer-name     buf_temp-obj-info
&scop flt-open-waitfram             true

    define variable v-query-was-opened as logical   no-undo .

    { gbl/fltopend.i
          &where-cond = " yes "
          &dyn_where-cond = " Substitute('&1', yes ) "
          &use-ind    = "  "
          &by         = "  "
    }

    if p-open-query = true
    then do:
      if v-restore-position = true
      then do:
        find first buf_reposition_temp-obj-info
          where buf_reposition_temp-obj-info.obj-type = v-current-obj-type
            and buf_reposition_temp-obj-info.obj-code = v-current-obj-code
          no-error .
        if available buf_reposition_temp-obj-info
        then do:
          reposition {&browse-name} to rowid rowid(buf_reposition_temp-obj-info) no-error .
          if error-status :error
          then do:
            reposition {&browse-name} to row 1 no-error .
          end.
        end.
      end.
    end.
    else do:
      if v-prt-rec <> ?
      then do:
        reposition {&browse-name} to recid v-prt-rec no-error .
        if error-status :error
        then do:
          reposition {&browse-name} to row 1 no-error .
        end.
      end.
    end.

  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE post_enable_ui DIALOG-1
PROCEDURE post_enable_ui :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
  disable all
  with frame {&frame-name}.
  ENABLE
    b-exit
    b-help
    br-obj
    b-show-obj
    b-show-host
    b-action
    b-menu
    b-mark          when can-do (p-bttns, "b-mark")
    b-select-all    when can-do (p-bttns, "b-mark")
    b-deselect-all  when can-do (p-bttns, "b-mark")
    b-list          when can-do (p-bttns, "b-mark")
    mark-num        when can-do (p-bttns, "b-mark")
    b-add-sh        when can-do (p-bttns, "b-add")
    b-add-st        when can-do (p-bttns, "b-add")
    b-add-all       when can-do (p-bttns, "b-add")
    b-del           when can-do (p-bttns, "b-add")
    b-sel           when can-do (p-bttns, "b-sel")
    flt-code
    with frame {&frame-name}.

end.
END PROCEDURE. /* post_enable_ui */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-list DIALOG-1
PROCEDURE proc-b-list :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  define input parameter loc-list-option as character no-undo.

  define variable f-name as char init "default.cli" no-undo.
  define variable imp-type like ub.goods.prod-type no-undo.
  define variable imp-code like ub.goods.prod-code no-undo.
  define variable v-ok as logical no-undo .

  define buffer buf_temp-user-obj for temp-user-obj .
  define buffer buf_temp-obj-info for temp-obj-info .

  do
  on error undo, return error return-value
  :
    case loc-list-option:
      when "save":U
      then do:
        assign
          v-ok = true
        .
        message
          "Сохранить все отмеченные объекты в файле списка" skip
          "Продолжить?" skip
          view-as alert-box question buttons OK-Cancel update v-ok .
        if v-ok <> true
        then do:
          assign
            v-list-option = "":U
          .
          return .
        end.
        assign
          f-name = "default.cli"
          v-ok   = true
        .
        system-dialog get-file f-name
          filters "Списки клиентов *.cli" "*.cli"
          ask-overwrite
          save-as
          use-filename
          update v-ok
          default-extension "cli".
        if v-ok <> true
        then do:
          assign
            v-list-option = "":U
          .
          return .
        end.

        output stream sout to value (f-name).

        for each buf_temp-user-obj
        on error undo, return error return-value
        :
          export stream sout
            buf_temp-user-obj.obj-type
            buf_temp-user-obj.obj-code
          .
        end.

        output stream sout close.
      end.
      when "load":U
      then do:
        assign
          v-ok = yes
        .
        message
          "Отметить все объекты из ранее сохраненного в файле списка." skip
          "Продложить?" skip
          view-as alert-box question buttons ok-cancel update v-ok .
        if v-ok <> true
        then do:
          assign
            v-list-option = "":U
          .
          return.
        end.
        system-dialog get-file f-name
          filters "Списки клиентов *.cli" "*.cli"
          title "Выберите файл списка"
          initial-dir "."
          return-to-start-dir
          must-exist
          /* use-filename */
          update v-ok
          default-extension "cli".
        if v-ok <> true
        then do:
          assign
            v-list-option = "":U
          .
          return.
        end.

        input stream sout from value (f-name).
        repeat
        :
          assign
            imp-type = '':U
            imp-code = 0
          .
          import stream sout imp-type imp-code .
          find first buf_temp-obj-info no-lock
            where buf_temp-obj-info.obj-type = imp-type
              and buf_temp-obj-info.obj-code = imp-code
            no-error .
          if available buf_temp-obj-info
          then do:
            run userobjs_append in this-procedure
              (input  buf_temp-obj-info.obj-type
              ,input  buf_temp-obj-info.obj-code
              ) .
          end.
        end.
        input stream sout close.

        run display-select-num in this-procedure .
        apply "entry" to br-obj in frame {&frame-name}.
      end.
      otherwise do:

      end.
    END CASE.
    loc-list-option = "":U.

  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE temp-obj-info-append DIALOG-1
PROCEDURE temp-obj-info-append :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .
  define input  parameter p-db-num   as integer   no-undo .

  define buffer buf_temp-obj-info for temp-obj-info .
  define buffer buf_obj_clients   for ub.clients .

  do
  on error undo, return error return-value
  :
    find first buf_temp-obj-info
      where buf_temp-obj-info.obj-type = p-obj-type
        and buf_temp-obj-info.obj-code = p-obj-code
      no-error .
    if not available buf_temp-obj-info
    then do:
      find first buf_obj_clients no-lock
        where buf_obj_clients.obj-type = p-obj-type
          and buf_obj_clients.obj-code = p-obj-code
        .

      define variable v-host-code as integer   no-undo .
      define variable v-host-name as character no-undo .
      define variable v-base-code as integer no-undo .

      { gbl/hostname.i
        p-obj-type
        p-obj-code
        v-host-code
        v-host-name
      }
      { gbl/basecode.i
         v-host-code
         v-base-code
      }

      create buf_temp-obj-info .
      assign
        buf_temp-obj-info.obj-type        = p-obj-type
        buf_temp-obj-info.obj-code        = p-obj-code
        buf_temp-obj-info.db-num          = p-db-num
        buf_temp-obj-info.brws-obj-name   = buf_obj_clients.obj-name
        buf_temp-obj-info.brws-db-num     = string(buf_obj_clients.db-num)
        buf_temp-obj-info.brws-host-code  = string(v-host-code)
        buf_temp-obj-info.brws-host-name  = v-host-name
        buf_temp-obj-info.brws-curr-code  = v-base-code
      .
    end.
  end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE update-br-obj-dependent DIALOG-1
PROCEDURE update-br-obj-dependent :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  do
  on error undo, return error return-value
  :
    do with frame {&frame-name}
    :
      if available buf_temp-obj-info
      then do:
        display
          buf_temp-obj-info.obj-code @ flt-code
          with frame {&frame-name}.
      end.
    end.
  end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE userobjs_append DIALOG-1
PROCEDURE userobjs_append :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .

  define buffer buf_temp-user-obj for temp-user-obj .

  do
  on error undo, return error return-value
  :
    find first buf_temp-user-obj
      where buf_temp-user-obj.obj-type = p-obj-type
        and buf_temp-user-obj.obj-code = p-obj-code
      no-error .
    if not available buf_temp-user-obj
    then do:
      create buf_temp-user-obj .
      assign
        buf_temp-user-obj.obj-type = p-obj-type
        buf_temp-user-obj.obj-code = p-obj-code
      .
      assign
        v-total-select-num = v-total-select-num + 1
      .
    end.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE userobjs_delete DIALOG-1
PROCEDURE userobjs_delete :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .

  define buffer buf_temp-user-obj for temp-user-obj .

  do
  on error undo, return error return-value
  :
    find first buf_temp-user-obj
      where buf_temp-user-obj.obj-type = p-obj-type
        and buf_temp-user-obj.obj-code = p-obj-code
      no-error .
    if available buf_temp-user-obj
    then do:
      delete buf_temp-user-obj .
      assign
        v-total-select-num = v-total-select-num - 1
      .
    end.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION mark-string DIALOG-1
FUNCTION mark-string RETURNS CHARACTER
  ( p-obj-type as character, p-obj-code as integer ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/
  define variable v-mark-string as character no-undo .

  run get-mark-string in this-procedure
    (input  p-obj-type
    ,input  p-obj-code
    ,output v-mark-string
    ) .
  return v-mark-string .

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME