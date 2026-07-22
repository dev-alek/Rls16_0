&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
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

Импорт данных из РКС - диалог настройки объектов.

Автор: Гюнтнер Виктор Арнольдович
Дата создания: 04/12/06
Author: Victor Guntner
Creation date: 04/12/06

Input:

Output:

*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter p-mode               as character    no-undo.
define input parameter p-id  as character    no-undo.
/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Импорт данных из РКС - диалог настройки объектов.".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i  }

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-help fi-id fi-name rs-obj-type ~
fi-obj-code
&Scoped-Define DISPLAYED-OBJECTS fi-id fi-name rs-obj-type fi-obj-code

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-exit
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-help
     LABEL "Помощ&ь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE fi-id AS CHARACTER FORMAT "X(22)"
     LABEL "Идентификатор"
     VIEW-AS FILL-IN
     SIZE 29 BY 1.

DEFINE VARIABLE fi-name AS CHARACTER FORMAT "X(30)"
     LABEL "Имя объекта"
     VIEW-AS FILL-IN
     SIZE 29.13 BY 1.

DEFINE VARIABLE fi-obj-code AS DECIMAL FORMAT ">>>>>>9" INITIAL 0
     LABEL "Код объекта"
     VIEW-AS FILL-IN
     SIZE 13.88 BY 1.

DEFINE VARIABLE rs-obj-type AS INTEGER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Магазин", 1,
"Склад", 2
     SIZE 29.25 BY 1 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1.17 COL 2
     b-help AT ROW 1.17 COL 35.5
     fi-id AT ROW 2.5 COL 1.13
     fi-name AT ROW 4 COL 3.13
     rs-obj-type AT ROW 5.5 COL 16.13 NO-LABEL
     fi-obj-code AT ROW 7 COL 3.13
     "Тип объекта:" VIEW-AS TEXT
          SIZE 12.5 BY 1.17 AT ROW 5.38 COL 2.88
     SPACE(31.49) SKIP(2.11)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Объекты"
         DEFAULT-BUTTON b-exit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS


/* ***************  Runtime Attributes and UIB Settings  ************** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
                                                                        */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN fi-id IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN fi-name IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN fi-obj-code IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME






/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Объекты */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit Dialog-Frame
ON CHOOSE OF b-exit IN FRAME Dialog-Frame /* Выход */
DO:
    define variable v-obj-type     as character         no-undo.
    assign
        rs-obj-type
        v-obj-type  = ( if rs-obj-type = 1 then {&shop} else {&stock} )
    .
    run assign-fields in this-procedure(
          input fi-id :screen-value
        , input fi-name :screen-value
        , input v-obj-type
        , input fi-obj-code :screen-value
        , input recid( rcs-shops )
    ) no-error.
    if error-status :error
    then do:
        message
        "Ошибка записи: " + return-value
        view-as alert-box warning.
        undo, return no-apply.
    end.
    apply "WINDOW-CLOSE" TO FRAME {&FRAME-NAME} .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


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
    if p-mode = {&add-nodes}
    then do:
        do transaction:
            create rcs-shops.
            assign
                p-id         = "<Новый идентификатор>"
                rcs-shops.id    = p-id
                rcs-shops.obj-type = {&shop}
                                rcs-shops.obj-code = 0
            .
        end.
    end.
    else do:
        find first rcs-shops no-lock
             where rcs-shops.id = p-id
        no-error.
        if not available rcs-shops
        then do:
            undo, return error "Неверно выбрана запись для изменения." + {&new-line} + return-value.
        end.
    end.
    RUN enable_UI.
    assign
        fi-id           = rcs-shops.id
        rs-obj-type     = ( if rcs-shops.obj-type = {&shop} then 1 else 2 )
        fi-obj-code     = rcs-shops.obj-code
    .
    if p-mode <> {&add-nodes}
    then do:
        assign
            fi-name         = rcs-shops.name
        .
    end.
    display
        fi-id
        fi-name
        rs-obj-type
        fi-obj-code
    with frame {&frame-name}.
    apply "entry" to fi-id.
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
do
on error undo, return error
:
define input parameter p-id                 as character    no-undo.
define input parameter p-name               as character    no-undo.
define input parameter p-obj-type           as character    no-undo.
define input parameter p-obj-code           as integer      no-undo.
define input parameter p-current-recid      as recid        no-undo.

    define buffer buf_rcs-shops         for rcs-shops.
    define buffer buf_current_rcs-shops for rcs-shops.

    find first buf_current_rcs-shops exclusive-lock
         where recid( buf_current_rcs-shops )    = p-current-recid
    no-error .
    if not available buf_current_rcs-shops
    then do:
        undo, return error "Ошибка поиска текущей записи" + {&new-line} + return-value.
    end.
    find first buf_rcs-shops no-lock
         where buf_rcs-shops.id    = p-id
           and recid( buf_rcs-shops ) <> recid( buf_current_rcs-shops )
    no-error .
    if available buf_rcs-shops
    then do:
        undo, return error "Уже есть запись с таким идентификатором." + {&new-line} + return-value.
    end.
    find first buf_rcs-shops no-lock
         where buf_rcs-shops.obj-type   = p-obj-type
           and buf_rcs-shops.obj-code   = p-obj-code
           and recid( buf_rcs-shops ) <> recid( buf_current_rcs-shops )
    no-error .
    if available buf_rcs-shops
    then do:
        undo, return error "Уже есть запись для такого объекта." + {&new-line} + return-value.
    end.
    assign
        buf_current_rcs-shops.id        = p-id
        buf_current_rcs-shops.name      = p-name
        buf_current_rcs-shops.obj-type  = p-obj-type
        buf_current_rcs-shops.obj-code  = p-obj-code
    .
end.
END PROCEDURE. /* assign-fields */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI Dialog-Frame _DEFAULT-DISABLE
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


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI Dialog-Frame _DEFAULT-ENABLE
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
  DISPLAY fi-id fi-name rs-obj-type fi-obj-code 
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-help fi-id fi-name rs-obj-type fi-obj-code 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


