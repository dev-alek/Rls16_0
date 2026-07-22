&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v9r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Open XML. Редактирование записи внешней подсистемы

Автор: Хныкин Павел Андреевич
Дата создания: 04/12/06
Author: Pavel Khnykin
Creation date: 04/12/06

Input:

Output:

*/
/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter p-mainmenu-handle    as handle           no-undo.
define input parameter p-parent-handle      as handle           no-undo.
define input parameter p-mode               as character        no-undo.
define input parameter p-esys-id            as integer          no-undo.
define input parameter p-db-num             as integer          no-undo.
define input parameter p-current-db-num     as integer          no-undo.
define output parameter p-success           as logical          no-undo.

/* Local Variable Definitions ---                                       */

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Open XML. Редактирование записи внешней подсистемы".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ bge/oxmlext.i  }
{ cmp/showinf.i  }

define variable v-oxmlextd-can-change-db-imp    as logical      no-undo.
define variable v-oxmlextd-can-change-db-exp    as logical      no-undo.
define variable v-oxmlextd-can-change-imp       as logical      no-undo.
define variable v-oxmlextd-can-change-exp       as logical      no-undo.
define variable v-oxmlextd-have-import          as logical      no-undo.
define variable v-oxmlextd-have-export          as logical      no-undo.
define variable v-oxmlextd-has-import               as logical      no-undo.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-cancel b-help RECT-1 RECT-2 fi-name ~
ed-des tg-spec tg-have-export fi-db-num-exp tg-send-news-exp ~
fi-num-days-keep-exp bt-types-exp tg-have-import
&Scoped-Define DISPLAYED-OBJECTS fi-name fi-des-label ed-des tg-spec ~
tg-have-export fi-db-num-exp tg-send-news-exp fi-num-days-keep-exp ~
tg-have-import fi-esys-id

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-cancel AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON bt-types-exp
     LABEL "Типы данных"
     SIZE 14.5 BY 1.

DEFINE VARIABLE ed-des AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 29 BY 3.75 NO-UNDO.

DEFINE VARIABLE fi-db-num-exp AS INTEGER FORMAT "->>>>9" INITIAL 0
     LABEL "БД"
     VIEW-AS FILL-IN
     SIZE 5.5 BY 1.

DEFINE VARIABLE fi-des-label AS CHARACTER FORMAT "X(256)":U INITIAL "Описание:"
     VIEW-AS FILL-IN
     SIZE 10 BY 1 NO-UNDO.

DEFINE VARIABLE fi-esys-id AS INTEGER FORMAT ">>>>>9":U INITIAL 0
     LABEL "Номер"
      VIEW-AS TEXT
     SIZE 9.5 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fi-name AS CHARACTER FORMAT "X(256)":U
     LABEL "Название"
     VIEW-AS FILL-IN
     SIZE 29 BY 1 NO-UNDO.

DEFINE VARIABLE fi-num-days-keep-exp AS INTEGER FORMAT "->,>>>,>>9" INITIAL 0
     LABEL "Дней хранения пакетов"
     VIEW-AS FILL-IN
     SIZE 7.5 BY 1.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 40 BY 5.5.

DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE 12.5 BY 1.25
     BGCOLOR 8 FGCOLOR 8 .

DEFINE VARIABLE tg-have-export AS LOGICAL INITIAL no
     LABEL "Экспорт"
     VIEW-AS TOGGLE-BOX
     SIZE 10.5 BY .83 NO-UNDO.

DEFINE VARIABLE tg-have-import AS LOGICAL INITIAL no
     LABEL "Импорт"
     VIEW-AS TOGGLE-BOX
     SIZE 10.5 BY .83 NO-UNDO.

DEFINE VARIABLE tg-send-news-exp AS LOGICAL INITIAL no
     LABEL "Отправлять в новости"
     VIEW-AS TOGGLE-BOX
     SIZE 24 BY .83 NO-UNDO.

DEFINE VARIABLE tg-spec AS LOGICAL INITIAL no
     LABEL "Спецсистема"
     VIEW-AS TOGGLE-BOX
     SIZE 17 BY .83 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     b-cancel AT ROW 1 COL 11
     b-help AT ROW 1 COL 32
     fi-name AT ROW 3.5 COL 11 COLON-ALIGNED
     fi-des-label AT ROW 5 COL 2.5 NO-LABEL
     ed-des AT ROW 5 COL 13 NO-LABEL
     tg-spec AT ROW 9.25 COL 4.5 WIDGET-ID 2
     tg-have-export AT ROW 10.5 COL 4.5
     fi-db-num-exp AT ROW 11.75 COL 6.5 COLON-ALIGNED
     tg-send-news-exp AT ROW 11.75 COL 16.5
     fi-num-days-keep-exp AT ROW 13 COL 25.5 COLON-ALIGNED
     bt-types-exp AT ROW 14.75 COL 4
     tg-have-import AT ROW 16.75 COL 4.5 WIDGET-ID 6
     fi-esys-id AT ROW 2.25 COL 11 COLON-ALIGNED WIDGET-ID 4
     RECT-1 AT ROW 10.75 COL 2
     RECT-2 AT ROW 10.25 COL 3.5
     SPACE(27.24) SKIP(6.45)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Внешняя подсистема Open XML"
         DEFAULT-BUTTON b-exit CANCEL-BUTTON b-cancel.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   Allow: Basic,Browse,DB-Fields,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN fi-des-label IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN fi-esys-id IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Внешняя подсистема Open XML */
DO:
/* Действия после нажатия кнопки Ввод */
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Внешняя подсистема Open XML */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-cancel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-cancel Dialog-Frame
ON CHOOSE OF b-cancel IN FRAME Dialog-Frame /* Отмена */
DO:
{ gbl/stdbtn.i }
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit Dialog-Frame
ON CHOOSE OF b-exit IN FRAME Dialog-Frame /* Ввод */
DO:
{ gbl/stdbtn.i }
    define variable v-err-desc      as character    no-undo.
    define variable v-err           as logical      no-undo.
    define variable v-yesno         as logical      no-undo.

    if p-mode <> {&lookup}
    then do:
        assign
            tg-have-import
        .
        run check-data in this-procedure (
              output v-err-desc
            , output v-err
        ).
        if v-err = yes
        then do:
            message
                "Ошибка ввода данных."
                skip (1)
                skip v-err-desc
                skip (1)
                skip "Исправьте данные или отмените ввод."
            view-as alert-box warning.
            undo, return no-apply.
        end.
        if v-oxmlextd-have-import = yes
        and v-oxmlextd-has-import = yes
        and tg-have-import        = no
        then do:
            message
                     "Для сохранения выбранных параметров"
                skip "необходимо остановить импорт из внешней подсистемы."
                skip "Будут удалены все данные по импорту из этой подсистемы."
                skip (1)
                skip "Внешняя подсистема:"
                skip "  номер   " p-esys-id
                skip "  БД номер" p-db-num
                skip "  имя     " fi-name :screen-value
                skip (1)
                skip "Остановить импорт?"
            view-as alert-box information
            buttons yes-no
            title "Остановка импорта"
            update v-yesno.
            if v-yesno = yes
            then do:
                run oxmlext-stop-import in this-procedure (
                      input p-esys-id
                    , input p-db-num
                ).
            end.
            else do:
                undo, return no-apply.
            end.
        end.
        if v-oxmlextd-have-export = yes
        and tg-have-export :screen-value = "no"
        then do:
            message
                     "Для сохранения выбранных параметров"
                skip "необходимо остановить экспорт во внешнюю подсистему."
                skip "Будут удалены все данные по экспорту в эту подсистему."
                skip (1)
                skip "Внешняя подсистема:"
                skip "  номер   " p-esys-id
                skip "  БД номер" p-db-num
                skip "  имя     " fi-name :screen-value
                skip (1)
                skip "Остановить экспорт?"
            view-as alert-box information
            buttons yes-no
            title "Остановка экспорта"
            update v-yesno.
            if v-yesno = yes
            then do:
                run oxmlext-stop-export in this-procedure (
                      input p-esys-id
                    , input p-db-num
                ).
            end.
            else do:
                undo, return no-apply.
            end.
        end.
        assign
            fi-name
            ed-des
            tg-have-export
            tg-have-import
            fi-db-num-exp
            tg-send-news-exp
            fi-num-days-keep-exp
            tg-spec
        .
        run assign-fields in this-procedure .
    end.
    assign
        p-success = yes
    .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-types-exp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-types-exp Dialog-Frame
ON CHOOSE OF bt-types-exp IN FRAME Dialog-Frame /* Типы данных */
DO:
    run bge/oxmlexty.w (
          input p-mainmenu-handle
        , input ( if p-mode = {&lookup} then 0 else 1 )
        , input {&openxml-export}
        , input p-esys-id
        , input p-db-num
    ) no-error.
    if error-status :error
    then do:
        message
                 vss-workfile vss-revision vss-description
            skip(1)
            skip "Ошибка списка типов экспорта."
            skip return-value
            skip trim(error-status :get-message(1))
                 trim(error-status :get-message(2))
                 trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return no-apply .
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tg-have-export
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tg-have-export Dialog-Frame
ON VALUE-CHANGED OF tg-have-export IN FRAME Dialog-Frame /* Экспорт */
DO:
    assign
        tg-have-export
    .
    run manage-export in this-procedure (
        input tg-have-export
    ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tg-have-import
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tg-have-import Dialog-Frame
ON VALUE-CHANGED OF tg-have-import IN FRAME Dialog-Frame /* Импорт */
DO:
    assign
        tg-have-import
    .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tg-spec
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tg-spec Dialog-Frame
ON VALUE-CHANGED OF tg-spec IN FRAME Dialog-Frame /* Спецсистема */
DO:
    assign
        tg-spec
    .
    run manage-spec in this-procedure (
        input tg-spec
    ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */
{ gbl/hot-key.i b-exit  }


/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

{ gbl/app_help.i }

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
    run init-fields in this-procedure .
    RUN enable_UI.
    run disable-all in this-procedure .
    run ui-enable in this-procedure .
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE assign-fields Dialog-Frame
PROCEDURE assign-fields :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define buffer buf_ext-system        for ub.ext-system.
do
for buf_ext-system
on error undo, return error
:
    find first buf_ext-system exclusive-lock
         where buf_ext-system.esys-id = p-esys-id
    .
    assign
        buf_ext-system.esys-name                       = fi-name
        buf_ext-system.esys-des                        = ed-des
        buf_ext-system.esys-have-export                = tg-have-export
        buf_ext-system.esys-have-import                = tg-have-import
        buf_ext-system.esys-db-num-exp                 = fi-db-num-exp
        buf_ext-system.esys-send-news-exp              = tg-send-news-exp
        buf_ext-system.esys-num-days-keep-exp          = fi-num-days-keep-exp
    .
    if p-mode = {&add-def}
    then do:
        if tg-spec = yes
        then do:
            assign
                buf_ext-system.esys-type = integer({&openxml-type-special})
            .
        end.
        else do:
            assign
                buf_ext-system.esys-type = integer({&openxml-type-ordinal})
            .
        end.
    end.
end.
END PROCEDURE. /* assign-fields */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE check-data Dialog-Frame
PROCEDURE check-data :
define output parameter p-error-desc    as character        no-undo.
define output parameter p-error         as logical          no-undo.
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
with frame {&frame-name}
on error undo, return error
:
    if p-current-db-num <> 0
    then do:
        if fi-db-num-exp :sensitive = yes
        and integer( fi-db-num-exp ) <> p-current-db-num
        then do:
            assign
                p-error      = yes
                p-error-desc = substitute( "&2&1&3"
                                , {&new-line}
                                , "Номер базы данных для экспорта"
                                , "не равен номеру текущей базы данных." )
            .
        end.
    end.
end.
END PROCEDURE. /* check-data */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable-all Dialog-Frame
PROCEDURE disable-all :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
with frame {&frame-name}
on error undo, return error
:
    disable
        all
        except
            b-exit
            b-help
    .

end.
END PROCEDURE. /* disable-all */

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
  DISPLAY fi-name fi-des-label ed-des tg-spec tg-have-export fi-db-num-exp
          tg-send-news-exp fi-num-days-keep-exp tg-have-import fi-esys-id
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-cancel b-help RECT-1 RECT-2 fi-name ed-des tg-spec
         tg-have-export fi-db-num-exp tg-send-news-exp fi-num-days-keep-exp
         bt-types-exp tg-have-import
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-fields Dialog-Frame
PROCEDURE init-fields :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define buffer buf_ext-system        for ub.ext-system.
do
for buf_ext-system
on error undo, return error
:
    assign
        fi-esys-id = p-esys-id
    .
    assign
        p-success = no
    .
    find first buf_ext-system exclusive-lock
         where buf_ext-system.esys-id = p-esys-id
           and buf_ext-system.db-num  = p-db-num
    no-error.
    if not available buf_ext-system
    then do:
        message
                 vss-workfile vss-revision vss-description
            skip(1)
            skip "Не удаётся получить запись внешней подсистемы"
            skip "для изменения."
        view-as alert-box error.
        undo, return error .
    end.
    assign
        fi-name                        = buf_ext-system.esys-name
        ed-des                         = buf_ext-system.esys-des
        tg-have-export                 = buf_ext-system.esys-have-export
        tg-have-import                 = buf_ext-system.esys-have-import
        fi-db-num-exp                  = buf_ext-system.esys-db-num-exp
        tg-send-news-exp               = buf_ext-system.esys-send-news-exp
        fi-num-days-keep-exp           = buf_ext-system.esys-num-days-keep-exp
        tg-spec                        = ( buf_ext-system.esys-type = 1 )
        v-oxmlextd-has-import              = buf_ext-system.esys-have-import
    .
    if tg-spec = yes
    then do:
        assign
            v-oxmlextd-can-change-exp   = no
            v-oxmlextd-have-export      = no
            tg-have-export              = no
        .
        if p-current-db-num = 0
        then do:
            assign
                v-oxmlextd-have-import      = buf_ext-system.esys-have-import
                v-oxmlextd-can-change-imp   = yes
            .
        end.
        else do:        /* Импорт включён только в ГБД */
            assign
                v-oxmlextd-have-import      = no
                v-oxmlextd-can-change-imp   = no
            .
        end.
    end.
    else do:
        assign
            v-oxmlextd-have-export      = tg-have-export
            v-oxmlextd-have-import      = no
            v-oxmlextd-can-change-imp   = no
        .
        assign
            v-oxmlextd-can-change-exp       = no
            v-oxmlextd-can-change-db-exp    = no
        .
        if p-current-db-num = 0
        then do:
            assign
                v-oxmlextd-can-change-exp       = yes
                v-oxmlextd-can-change-db-exp    = yes
            .
        end.
        else do:
            assign
                v-oxmlextd-can-change-db-exp    = no
            .
            if buf_ext-system.esys-db-num-exp = p-current-db-num
            then do:
                assign
                    v-oxmlextd-can-change-exp       = yes
                .
            end.
            else do:
                assign
                    v-oxmlextd-can-change-exp       = no
                .
            end.
        end.
    end.
end.
END PROCEDURE. /* init-fields */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE manage-export Dialog-Frame
PROCEDURE manage-export :
define input parameter p-have-export    as logical          no-undo.
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
with frame {&frame-name}
on error undo, return error
:
    if p-have-export = yes
    then do:
        if v-oxmlextd-can-change-db-exp = yes
        then do:
            enable
                fi-db-num-exp
            .
        end.
        else do:
            disable
                fi-db-num-exp
            .
        end.
        enable
            tg-send-news-exp
            fi-num-days-keep-exp
            bt-types-exp
        .
    end.
    else do:
        disable
            fi-db-num-exp
            tg-send-news-exp
            fi-num-days-keep-exp
            bt-types-exp
        .
    end.
end.
END PROCEDURE. /* manage-export */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE manage-spec Dialog-Frame
PROCEDURE manage-spec :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-spec   as logical     no-undo.

do
with frame {&frame-name}
on error undo, return error
:
    if p-spec = yes
    then do:
        disable
            tg-have-export
            fi-db-num-exp
            tg-send-news-exp
            tg-send-news-exp
            fi-num-days-keep-exp
            bt-types-exp
        .
        enable
            fi-num-days-keep-exp
        .
    end.
    else do:
        enable
            tg-have-export
            fi-db-num-exp
            tg-send-news-exp
            tg-send-news-exp
            fi-num-days-keep-exp
            bt-types-exp
        .
        run manage-export in this-procedure (
            input tg-have-export
        ).
    end.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ui-enable Dialog-Frame
PROCEDURE ui-enable :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
with frame {&frame-name}
on error undo, return error
:
    if tg-spec = yes
    then do:
        display
            tg-have-import
        .
        if p-mode = {&add-def}
        or p-mode = {&update}
        then do:
            enable
                tg-have-import
            .
        end.
        else do:
            disable
                tg-have-import
            .
        end.
    end.
    else do:
        hide
            tg-have-import
        .
    end.
    case p-mode
    :
        when {&add-def}
        then do:
            enable
                b-cancel
                fi-name
                ed-des
                fi-num-days-keep-exp
            .
            if v-oxmlextd-can-change-exp = yes
            then do:
                enable
                    tg-have-export
                .
                run manage-export in this-procedure (
                    input tg-have-export
                ).
            end.
        end.        /* when {&add-def} */
        when {&update}
        then do:
            enable
                b-cancel
                fi-name
                ed-des
                fi-num-days-keep-exp
            .
            if v-oxmlextd-can-change-exp    = yes
            and tg-spec                     = no
            then do:
                enable
                    tg-have-export
                .
                run manage-export in this-procedure (
                    input tg-have-export
                ).
            end.
        end.        /* when {&update} */
        when {&lookup}
        then do:
            assign
                b-exit   :label     = "В&ыход"
                b-cancel :visible   = no
            .
            if tg-have-export   = yes
            and tg-spec         = no
            then do:
                enable
                    bt-types-exp
                .
            end.
        end.        /* when {&lookup} */
        otherwise do:
            message
                "Указанный режим просмотра записи некорректен."
            view-as alert-box error
            title vss-description.
            undo, return error.
        end.        /* otherwise */
    end case.       /* case p-mode */
end.
END PROCEDURE. /* ui-enable */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME