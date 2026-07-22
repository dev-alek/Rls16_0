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

OpenXML. Просмотр и редактирование типа данных внешней подсистемы

Автор: Хныкин Павел Андреевич
Дата создания: 04/12/06
Author: Pavel Khnykin
Creation date: 04/12/06

Input:
    p-mainmenu-handle   - handle главного окна
    p-mode              - режим вызова:
                            0 - доступна только кнопка Выход
                            1 - возможно редактирование
    p-impexp-type       - {&openxml-import} или {&openxml-export}, для чего вызывается форма
    p-esys-id           - код внешней системы
    p-db-num            - БД внешней системы

Output:

*/

/* ***************************  Definitions  ************************** */


/* Parameters Definitions ---                                           */
define input parameter p-mainmenu-handle    as widget-handle    no-undo.
define input parameter p-mode               as integer          no-undo.
define input parameter p-impexp-type        as character        no-undo.
define input parameter p-esys-id            as integer          no-undo.
define input parameter p-db-num             as integer          no-undo.
define input parameter p-id                 as integer          no-undo.

/* Local Variable Definitions ---                                       */

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "OpenXML. Просмотр и редактирование типа данных внешней подсистемы".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i  }

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-quit b-help fi-esys-name ~
fi-type-name tg-confirmation fi-status ed-des
&Scoped-Define DISPLAYED-OBJECTS fi-esys-name fi-type-name tg-confirmation ~
fi-status ed-des

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE ed-des AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 62 BY 4.25 NO-UNDO.

DEFINE VARIABLE fi-esys-name AS CHARACTER FORMAT "X(256)":U
     LABEL "Внешняя подсистема"
     VIEW-AS FILL-IN
     SIZE 40 BY 1 NO-UNDO.

DEFINE VARIABLE fi-status AS INTEGER FORMAT "->>9" INITIAL 0
     LABEL "Статус"
     VIEW-AS FILL-IN
     SIZE 6 BY 1.

DEFINE VARIABLE fi-type-name AS CHARACTER FORMAT "X(256)":U
     LABEL "Тип данных"
     VIEW-AS FILL-IN
     SIZE 40 BY 1 NO-UNDO.

DEFINE VARIABLE tg-confirmation AS LOGICAL INITIAL no
     LABEL "Подтверждение"
     VIEW-AS TOGGLE-BOX
     SIZE 23 BY .83 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     b-help AT ROW 1 COL 55
     fi-esys-name AT ROW 2.25 COL 22 COLON-ALIGNED
     fi-type-name AT ROW 3.5 COL 22 COLON-ALIGNED
     tg-confirmation AT ROW 5 COL 23.5
     fi-status AT ROW 6 COL 21.5 COLON-ALIGNED
     ed-des AT ROW 7.5 COL 2 NO-LABEL
     SPACE(1.13) SKIP(0.53)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Тип данных для внешней системы"
         DEFAULT-BUTTON b-exit CANCEL-BUTTON b-quit.


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
                                                                        */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN
       fi-esys-name:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

ASSIGN
       fi-type-name:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Тип данных для внешней системы */
DO:
    run check-data in this-procedure.
    assign
        tg-confirmation
        fi-status
        ed-des
    .
    run assign-data in this-procedure.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Тип данных для внешней системы */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit Dialog-Frame
ON CHOOSE OF b-exit IN FRAME Dialog-Frame /* Ввод */
DO:
{ gbl/stdbtn.i }

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-quit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-quit Dialog-Frame
ON CHOOSE OF b-quit IN FRAME Dialog-Frame /* Отмена */
DO:
{ gbl/stdbtn.i }
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
    run init-fields in this-procedure.
    RUN enable_UI.
    run ui-disable-all in this-procedure.
    run ui-enable in this-procedure.
    WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE assign-data Dialog-Frame
PROCEDURE assign-data :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define buffer buf_esys-datatype-exp     for ub.esys-datatype-exp.
    define buffer buf_esys-datatype-imp     for ub.esys-datatype-imp.
do
for buf_esys-datatype-exp
  , buf_esys-datatype-imp
on error undo, return error
:
    case p-impexp-type
    :
        when {&openxml-import}
        then do:
            find first buf_esys-datatype-imp exclusive-lock
                 where buf_esys-datatype-imp.esys-id = p-esys-id
                   and buf_esys-datatype-imp.db-num  = p-db-num
                   and buf_esys-datatype-imp.tdi-id  = p-id
            no-error.
            if not available buf_esys-datatype-imp
            then do:
                message
                         vss-workfile vss-revision vss-description
                    skip(1)
                    skip "Не найден тип данных внешней системы для редактирования."
                view-as alert-box error.
                undo, return error .
            end.
            assign
                buf_esys-datatype-imp.edi-confirmation = tg-confirmation
                buf_esys-datatype-imp.edi-status       = fi-status
                buf_esys-datatype-imp.edi-des          = ed-des
            .
        end.        /* when {&openxml-import} */
        when {&openxml-export}
        then do:
            find first buf_esys-datatype-exp exclusive-lock
                 where buf_esys-datatype-exp.esys-id = p-esys-id
                   and buf_esys-datatype-exp.db-num  = p-db-num
                   and buf_esys-datatype-exp.dte-id  = p-id
            no-error.
            if not available buf_esys-datatype-exp
            then do:
                message
                         vss-workfile vss-revision vss-description
                    skip(1)
                    skip "Не найден тип данных внешней системы для редактирования."
                view-as alert-box error.
                undo, return error .
            end.
            assign
                buf_esys-datatype-exp.ede-confirmation  = tg-confirmation
                buf_esys-datatype-exp.ede-status        = fi-status
                buf_esys-datatype-exp.ede-des           = ed-des
            .
        end.        /* when {&openxml-export} */
    end case.       /* case p-impexp-type */
end.
END PROCEDURE. /* assign-data */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE check-data Dialog-Frame
PROCEDURE check-data :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:

end.
END PROCEDURE. /* check-data */

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
  DISPLAY fi-esys-name fi-type-name tg-confirmation fi-status ed-des
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-quit b-help fi-esys-name fi-type-name tg-confirmation
         fi-status ed-des
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
    define buffer buf_esys-datatype-exp     for ub.esys-datatype-exp.
    define buffer buf_esys-datatype-imp     for ub.esys-datatype-imp.
    define buffer buf_ext-system            for ub.ext-system.
    define buffer buf_datatype-exp          for ub.datatype-exp.
    define buffer buf_datatype-imp          for ub.datatype-imp.
do
for buf_esys-datatype-exp
  , buf_esys-datatype-imp
  , buf_ext-system
  , buf_datatype-exp
  , buf_datatype-imp
with frame {&frame-name}
on error undo, return error
:
    find first buf_ext-system no-lock
         where buf_ext-system.esys-id = p-esys-id
           and buf_ext-system.db-num  = p-db-num
    .
    case p-impexp-type
    :
        when {&openxml-import}
        then do:
            assign
                frame {&frame-name} :title = frame {&frame-name} :title + " (импорт)"
            .
            find first buf_esys-datatype-imp exclusive-lock
                 where buf_esys-datatype-imp.esys-id = p-esys-id
                   and buf_esys-datatype-imp.db-num  = p-db-num
                   and buf_esys-datatype-imp.tdi-id  = p-id
            no-error.
            if not available buf_esys-datatype-imp
            then do:
                message
                         vss-workfile vss-revision vss-description
                    skip(1)
                    skip "Не найден тип данных внешней системы для редактирования."
                view-as alert-box error.
                undo, return error .
            end.
            find first buf_datatype-imp no-lock
                 where buf_datatype-imp.dti-id = p-id
            .
            assign
                fi-esys-name    = buf_ext-system.esys-name
                fi-type-name    = buf_datatype-imp.dti-name
                tg-confirmation = buf_esys-datatype-imp.edi-confirmation
                fi-status       = buf_esys-datatype-imp.edi-status
                ed-des          = buf_esys-datatype-imp.edi-des
            .
        end.        /* when {&openxml-import} */
        when {&openxml-export}
        then do:
            assign
                frame {&frame-name} :title = frame {&frame-name} :title + " (экспорт)"
            .
            find first buf_esys-datatype-exp exclusive-lock
                 where buf_esys-datatype-exp.esys-id = p-esys-id
                   and buf_esys-datatype-exp.db-num  = p-db-num
                   and buf_esys-datatype-exp.dte-id  = p-id
            no-error.
            if not available buf_esys-datatype-exp
            then do:
                message
                         vss-workfile vss-revision vss-description
                    skip(1)
                    skip "Не найден тип данных внешней системы для редактирования."
                view-as alert-box error.
                undo, return error .
            end.
            find first buf_datatype-exp no-lock
                 where buf_datatype-exp.dte-id = p-id
            .
            assign
                fi-esys-name    = buf_ext-system.esys-name
                fi-type-name    = buf_datatype-exp.dte-name
                tg-confirmation = buf_esys-datatype-exp.ede-confirmation
                fi-status       = buf_esys-datatype-exp.ede-status
                ed-des          = buf_esys-datatype-exp.ede-des
            .
        end.        /* when {&openxml-export} */
        otherwise do:
            message
                     vss-workfile vss-revision vss-description
                skip(1)
                skip "Неверно задан тип (может быть только импорт или экспорт)."
                skip return-value
                skip trim(error-status :get-message(1))
                     trim(error-status :get-message(2))
                     trim(error-status :get-message(3))
            view-as alert-box error.
            undo, return error .
        end.        /* otherwise */
    end case.       /* case p-impexp-type */

end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ui-disable-all Dialog-Frame
PROCEDURE ui-disable-all :
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
            b-quit
            b-help
    .
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
    if p-mode = 1
    then do:
        enable
            tg-confirmation
            fi-status
            ed-des
        .
    end.
    if p-mode = 0
    then do:
        hide
            b-quit
        .
        assign
            b-exit :label = "В&ыход"
        .

    end.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
