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

Просмотр и редактирование группы блюд

Автор: Белоусов Илья Александрович
Дата создания: 04/12/06
Author: Ilia Belousov
Creation date: 04/12/06

Input:

Output:

*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle   no-undo.
define input parameter p-mode       as character    no-undo.
define input parameter p-store-type as character    no-undo.
define input parameter p-store-code as integer      no-undo.
define input parameter p-grp-code   as integer      no-undo.
define input parameter p-upper-code as integer      no-undo.
define input parameter p-in-name    as character    no-undo.
define input parameter p-in-code    as integer      no-undo.
define output parameter p-out-name  as character    no-undo.
define output parameter p-out-code  as integer      no-undo.
define output parameter p-cancel    as logical initial yes no-undo.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Просмотр и редактирование группы блюд".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i  }

define variable dflt-cd as character no-undo .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-cancel B-hist b-help fi-name ~
fi-out-code 
&Scoped-Define DISPLAYED-OBJECTS fi-name fi-out-code 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-cancel 
     LABEL "&Отмена" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-exit 
     LABEL "&Ввод" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-help 
     LABEL "Помощ&ь" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-hist 
     LABEL "Ис&тория" 
     SIZE 10 BY 1.

DEFINE VARIABLE fi-name AS CHARACTER FORMAT "X(256)":U 
     LABEL "Наименование" 
     VIEW-AS FILL-IN 
     SIZE 46.63 BY 1 NO-UNDO.

DEFINE VARIABLE fi-out-code AS INTEGER FORMAT ">>9":U INITIAL 0 
     LABEL "Код кассы" 
     VIEW-AS FILL-IN 
     SIZE 11.38 BY 1 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     b-cancel AT ROW 1 COL 11
     B-hist AT ROW 1 COL 41
     b-help AT ROW 1 COL 51
     fi-name AT ROW 3.13 COL 1.63
     fi-out-code AT ROW 4.5 COL 13.63 COLON-ALIGNED
     SPACE(36.23) SKIP(0.53)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Группа блюд"
         DEFAULT-BUTTON b-exit CANCEL-BUTTON b-cancel.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
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

/* SETTINGS FOR FILL-IN fi-name IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Группа блюд */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-cancel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-cancel Dialog-Frame
ON CHOOSE OF b-cancel IN FRAME Dialog-Frame /* Отмена */
DO:
    assign
        p-cancel   = yes
    .
    apply "WINDOW-CLOSE" TO FRAME {&FRAME-NAME} .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit Dialog-Frame
ON CHOOSE OF b-exit IN FRAME Dialog-Frame /* Ввод */
DO:
    assign
        fi-name
        fi-out-code
    .
    run check-output in this-procedure (
          input fi-name
        , input fi-out-code
    ).
    assign
        p-out-name = fi-name
        p-out-code = fi-out-code
        p-cancel   = no
    .
    apply "WINDOW-CLOSE" TO FRAME {&FRAME-NAME} .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-hist
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-hist Dialog-Frame
ON CHOOSE OF B-hist IN FRAME Dialog-Frame /* История */
DO:
 DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
 run ref/cfggrphi.w (
                  input parparentproc
                 ,INPUT '':U /*bttns*/
                 ,INPUT 'one'
                 ,INPUT p-store-type
                 ,INPUT p-store-code
                 ,INPUT p-grp-code
                 ,INPUT '':U /*p-attr-code*/
                 ,INPUT NO /*p-is-del*/
                 ,INPUT '':U /*p-subject*/
                 ,OUTPUT v-rid-list) NO-ERROR.
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
    run init-fields in this-procedure.
    RUN Myenable.
    if p-mode = {&lookup}
    then do:
        apply "entry" to b-exit in frame {&frame-name} .
        disable
            fi-name
        with frame {&frame-name} .
        assign
            fi-name :fgcolor = 4
        .
    end.
    else do:
        apply "entry" to fi-name in frame {&frame-name} .
    end.
    WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE check-output Dialog-Frame 
PROCEDURE check-output :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define input parameter p-name       as character    no-undo.
define input parameter p-out-code   as integer      no-undo.

define variable v-rezerved-out-code like ub.fbr-gds-grp.out-code no-undo .

    define buffer buf_fbr-gds-grp       for ub.fbr-gds-grp.

    if p-name = '' then do:
      message
      "Название группы не может быть пустым!"
      view-as alert-box error .
      undo, return error .
    end.


    find first buf_fbr-gds-grp no-lock
         where buf_fbr-gds-grp.obj-type   = p-store-type
           and buf_fbr-gds-grp.obj-code   = p-store-code
           and buf_fbr-gds-grp.upper-code = p-upper-code
           and buf_fbr-gds-grp.node-name  = p-name
           and buf_fbr-gds-grp.node-code  <> p-grp-code
    no-error.
    if available buf_fbr-gds-grp
    then do:
        message
            skip "Есть другая группа блюд с таким именем."
            skip(1)
            skip "Измените имя группы."
        view-as alert-box error
        title "Проверка введенных значений".
        undo, return error .
    end.
    /*надем последнее значение кода на кассе*/
    find last buf_fbr-gds-grp no-lock where
              buf_fbr-gds-grp.obj-type = "":U
          AND buf_fbr-gds-grp.obj-code = 0
          use-index pi .
    assign
    v-rezerved-out-code = buf_fbr-gds-grp.out-code
    .
    if p-out-code > 65535
    then do:
        message
                "Код группы на кассе может быть числом от 0 до 65535."
            skip(1)
            skip "Измените код группы на кассе."
        view-as alert-box error
        title "Проверка введенных значений".
        undo, return error .
    end.
    if p-out-code <> 0
    and p-out-code < 9998
    then do:
        find first buf_fbr-gds-grp no-lock
             where buf_fbr-gds-grp.obj-type   = p-store-type
               and buf_fbr-gds-grp.obj-code   = p-store-code
               and buf_fbr-gds-grp.out-code   = p-out-code
               and buf_fbr-gds-grp.node-code  <> p-grp-code
        no-error.
        if available buf_fbr-gds-grp
        then do:
            message
                skip "Есть другая группа блюд с таким кодом на кассе."
                skip(1)
                skip "Измените код на кассе."
            view-as alert-box error
            title "Проверка введенных значений".
            undo, return error .
        end.
    end.
    if  p-out-code <> p-in-code
    and p-out-code <= v-rezerved-out-code
    and dflt-cd = {&cd-type-magia-xml}
    then do:
        message
            skip substitute("Коды групп на кассе со значением менее &1 зарезервированы.",  v-rezerved-out-code)
            skip(1)
            skip "Измените код на кассе."
        view-as alert-box error
        title "Проверка введенных значений".
        undo, return error .
    end.
end.
END PROCEDURE. /* check-output */

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
  DISPLAY fi-name fi-out-code 
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-cancel B-hist b-help fi-name fi-out-code 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-fields Dialog-Frame 
PROCEDURE init-fields :
do
on error undo, return error
:
    assign
        fi-name     = p-in-name
        fi-out-code = p-in-code
    .
  { gbl/dflt-cd.i p-store-type p-store-code dflt-cd }

end.
END PROCEDURE. /* init-fields */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame 
PROCEDURE MyEnable :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/

  DISPLAY
  fi-name
  fi-out-code
  WITH FRAME {&FRAME-NAME}.
  ENABLE
  b-exit
  b-cancel
  B-hist
  b-help WHEN p-mode <> {&ADD-DEF}
  fi-name
  fi-out-code
  WITH FRAME {&FRAME-NAME}.
  VIEW FRAME {&FRAME-NAME}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

