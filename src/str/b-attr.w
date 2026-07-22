&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v9r12 GUI
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

Выбор атрибута

Автор: Чернова Светлана Александровна
Дата создания: 11/25/08
Author: Svetlana Chernova
Creation date: 11/25/08


*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Выбор атрибута".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i  }
{ str/attrlist.i }
{ gbl/color.i    }

/* Parameters Definitions ---                                           */
define input parameter table for tt-upd-attr .
define output parameter parcode like tt-upd-attr.code no-undo.

define variable varis-ok as logical initial no no-undo.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME b-attr

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-upd-attr

/* Definitions for BROWSE b-attr                                        */
&Scoped-define FIELDS-IN-QUERY-b-attr tt-upd-attr.label-attr tt-upd-attr.hot-key
&Scoped-define ENABLED-FIELDS-IN-QUERY-b-attr
&Scoped-define SELF-NAME b-attr
&Scoped-define QUERY-STRING-b-attr FOR EACH tt-upd-attr where tt-upd-attr.output-display = yes  by tt-upd-attr.sort
&Scoped-define OPEN-QUERY-b-attr OPEN QUERY {&SELF-NAME} FOR EACH tt-upd-attr where tt-upd-attr.output-display = yes  by tt-upd-attr.sort .
&Scoped-define TABLES-IN-QUERY-b-attr tt-upd-attr
&Scoped-define FIRST-TABLE-IN-QUERY-b-attr tt-upd-attr


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-b-attr}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-chg b-quit b-help b-attr

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-chg AUTO-GO
     LABEL "&Выбор"
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

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY b-attr FOR
      tt-upd-attr SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE b-attr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS b-attr Dialog-Frame _FREEFORM
  QUERY b-attr DISPLAY
      tt-upd-attr.label-attr format "x(40)" label "Атрибут"
      tt-upd-attr.hot-key    format "x(8)"  label "Выбор"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-LABELS NO-ROW-MARKERS NO-COLUMN-SCROLLING SEPARATORS SIZE 51.88 BY 19.08.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-chg AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     b-help AT ROW 1 COL 21
     b-attr AT ROW 2.17 COL 1.13
     SPACE(2.36) SKIP(0.57)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Заголовок диалога"
         DEFAULT-BUTTON b-chg CANCEL-BUTTON b-quit.


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
/* BROWSE-TAB b-attr b-help Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE b-attr
/* Query rebuild information for BROWSE b-attr
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt-upd-attr where tt-upd-attr.output-display = yes.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE b-attr */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Заголовок диалога */
DO:
  if available tt-upd-attr
  then do:
    if  tt-upd-attr.can-select    = true
    and tt-upd-attr.user-can-edit = true
    then do:
      assign
        parcode = tt-upd-attr.code
      .
    end.
    else do:
      message
        "Атрибут" tt-upd-attr.label-attr skip
        "Атрибут нельзя выбрать для добавления" skip
        "так как он уже есть у документа или его нельзя редактировать" skip
        "в данном интерфейсе" skip
        view-as alert-box information .
      return no-apply .
    end.
  end.
  else do:
    message
      "Атрибут не выбран" skip
      view-as alert-box error .
    return no-apply.
  end.
  assign
    varis-ok = yes
  .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Заголовок диалога */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME b-attr
&Scoped-define SELF-NAME b-attr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-attr Dialog-Frame
ON DEFAULT-ACTION OF b-attr IN FRAME Dialog-Frame
DO:
  apply 'choose':u to b-chg .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-attr Dialog-Frame
ON ROW-DISPLAY OF b-attr IN FRAME Dialog-Frame
DO:
  if available tt-upd-attr
  then do:
    if  tt-upd-attr.can-select    = true
    and tt-upd-attr.user-can-edit = true
    then do:
      assign
        tt-upd-attr.label-attr :fgcolor in browse {&browse-name} = black_color
        tt-upd-attr.hot-key    :fgcolor in browse {&browse-name} = black_color
      .
    end.
    else do:
      /* если атрибут нельзя выбирать и редактировать */
      /* помечаем его серым цветом */
      assign
        tt-upd-attr.label-attr :fgcolor in browse {&browse-name} = grey_color
        tt-upd-attr.hot-key    :fgcolor in browse {&browse-name} = grey_color
      .
    end.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

do with frame {&frame-name}
:
  assign
    browse {&browse-name} :labels = no
  .
end.

{ gbl/app_help.i }
{ gbl/brwrefre.i }

run assign-hot-key in this-procedure .

on 'F3':U
  , 'F4':U
  , 'F5':U
  , 'F6':U
  , 'F7':U
  , 'F8':U
  , 'F9':U
  , 'F10':U
  , 'F11':U
  , 'F12':U
  , 'SHIFT-F1':U
  , 'SHIFT-F2':U
  , 'SHIFT-F3':U
  , 'SHIFT-F4':U
  , 'SHIFT-F5':U
  , 'SHIFT-F6':U
  , 'SHIFT-F7':U
  , 'SHIFT-F8':U
  , 'SHIFT-F9':U
  , 'SHIFT-F10':U
  , 'SHIFT-F11':U
  , 'SHIFT-F12':U
  , 'CTRL-F1':U
  , 'CTRL-F2':U
  , 'CTRL-F3':U
  , 'CTRL-F4':U
  , 'CTRL-F5':U
  , 'CTRL-F6':U
  , 'CTRL-F7':U
  , 'CTRL-F8':U
  , 'CTRL-F9':U
  , 'CTRL-F10':U
  , 'CTRL-F11':U
  , 'CTRL-F12':U
  , 'ALT-F1':U
  , 'ALT-F2':U
  , 'ALT-F3':U
  , 'ALT-F4':U
  , 'ALT-F5':U
  , 'ALT-F6':U
  , 'ALT-F7':U
  , 'ALT-F8':U
  , 'ALT-F9':U
  , 'ALT-F10':U
  , 'ALT-F11':U
  , 'ALT-F12':U
of frame {&frame-name} anywhere
do:
  run select-by-hot-key in this-procedure
    (input last-event :label
    ) .
end.


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  RUN enable_UI.

  apply 'entry':u to browse {&browse-name} .

  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

if varis-ok <> yes then do:
  return error.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE assign-hot-key Dialog-Frame
PROCEDURE assign-hot-key :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/

  define buffer buf_tt-upd-attr for tt-upd-attr .

  define variable v-hot-key-list as character no-undo .
  define variable v-key-number   as integer   no-undo .
  define variable v-max-number   as integer   no-undo .

  do
  on error undo, return error return-value
  :

    assign
      v-hot-key-list = 'F3':U
                     + {&comma-char} + 'F4':U
                     + {&comma-char} + 'F5':U
                     + {&comma-char} + 'F6':U
                     + {&comma-char} + 'F7':U
                     + {&comma-char} + 'F8':U
                     + {&comma-char} + 'F9':U
                     + {&comma-char} + 'F10':U
                     + {&comma-char} + 'F11':U
                     + {&comma-char} + 'F12':U
                     + {&comma-char} + 'SHIFT-F1':U
                     + {&comma-char} + 'SHIFT-F2':U
                     + {&comma-char} + 'SHIFT-F3':U
                     + {&comma-char} + 'SHIFT-F4':U
                     + {&comma-char} + 'SHIFT-F5':U
                     + {&comma-char} + 'SHIFT-F6':U
                     + {&comma-char} + 'SHIFT-F7':U
                     + {&comma-char} + 'SHIFT-F8':U
                     + {&comma-char} + 'SHIFT-F9':U
                     + {&comma-char} + 'SHIFT-F10':U
                     + {&comma-char} + 'SHIFT-F11':U
                     + {&comma-char} + 'SHIFT-F12':U
                     + {&comma-char} + 'CTRL-F1':U
                     + {&comma-char} + 'CTRL-F2':U
                     + {&comma-char} + 'CTRL-F3':U
                     + {&comma-char} + 'CTRL-F4':U
                     + {&comma-char} + 'CTRL-F5':U
                     + {&comma-char} + 'CTRL-F6':U
                     + {&comma-char} + 'CTRL-F7':U
                     + {&comma-char} + 'CTRL-F8':U
                     + {&comma-char} + 'CTRL-F9':U
                     + {&comma-char} + 'CTRL-F10':U
                     + {&comma-char} + 'CTRL-F11':U
                     + {&comma-char} + 'CTRL-F12':U
                     + {&comma-char} + 'ALT-F1':U
                     + {&comma-char} + 'ALT-F2':U
                     + {&comma-char} + 'ALT-F3':U
                     + {&comma-char} + 'ALT-F4':U
                     + {&comma-char} + 'ALT-F5':U
                     + {&comma-char} + 'ALT-F6':U
                     + {&comma-char} + 'ALT-F7':U
                     + {&comma-char} + 'ALT-F8':U
                     + {&comma-char} + 'ALT-F9':U
                     + {&comma-char} + 'ALT-F10':U
                     + {&comma-char} + 'ALT-F11':U
                     + {&comma-char} + 'ALT-F12':U
    .

    assign
      v-key-number = 0
      v-max-number = num-entries(v-hot-key-list, {&comma-char})
    .

    for each buf_tt-upd-attr
    on error undo, return error return-value
    :
      assign
        v-key-number = v-key-number + 1
      .
      if v-key-number > v-max-number
      then do:
        leave . /* --->>>--- */
      end.

      assign
        buf_tt-upd-attr.hot-key = entry(v-key-number, v-hot-key-list, {&comma-char})
      .

    end.
  end.



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
  ENABLE b-chg b-quit b-help b-attr
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE select-by-hot-key Dialog-Frame
PROCEDURE select-by-hot-key :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define input  parameter p-hot-key as character no-undo .

  define buffer buf_tt-upd-attr for tt-upd-attr .

  do
  on error undo, return error return-value
  :
    find first buf_tt-upd-attr
      where buf_tt-upd-attr.hot-key = p-hot-key
      no-error .
    if available buf_tt-upd-attr
    then do:
      reposition {&browse-name} to rowid rowid(buf_tt-upd-attr) .
      apply 'go':u to frame {&frame-name} .
    end.
  end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME