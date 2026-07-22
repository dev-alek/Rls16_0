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

Оболочка для запуска процедур импорта экспорта артикулов поставщиков

Автор: Хныкин Павел Андреевич
Дата создания: 03/25/08
Author: Pavel Khnykin
Creation date: 03/25/08

*/
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Оболочка для запуска процедур импорта экспорта артикулов поставщиков".
{ cmp/vssrevis.i }

/* ***************************  Definitions  ************************** */
/* Parameters Definitions ---                                           */
define input  parameter parparentproc  as handle no-undo .

/* Local Variable Definitions ---                                       */
{ cmp/str-glbl.i }
{ cmp/showinf.i  }
{ cmp/library.i  }
{ gbl/getcntxt.i def }
{ gbl/usr-flt.i }

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-imp b-exp B-help fi-filename ~
b-sel-file
&Scoped-Define DISPLAYED-OBJECTS fi-filename

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-exp
     LABEL "&Экспорт"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-imp
     LABEL "&Импорт"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-sel-file DEFAULT
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "":L
     size 2.5 by 1.08.

DEFINE VARIABLE fi-filename AS CHARACTER FORMAT "X(256)":U
     LABEL "Файл"
     VIEW-AS FILL-IN
     SIZE 49 BY 1 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     b-imp AT ROW 1 COL 11
     b-exp AT ROW 1 COL 21
     B-help AT ROW 1 COL 51
     fi-filename AT ROW 3 COL 7 COLON-ALIGNED
     b-sel-file at row 3 col 58.5
     SPACE(4.12) SKIP(1.79)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Импорт / Экспорт артикулов поставщика".


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

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Импорт / Экспорт артикулов поставщика */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-exit
&Scoped-define SELF-NAME b-exp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exp Dialog-Frame
ON CHOOSE OF b-exp IN FRAME Dialog-Frame /* Экспорт */
DO:
  assign
    fi-filename
  .
  if trim(fi-filename) = ""
  then do:
    message
      "Введите имя файла"
    view-as alert-box error.
    return no-apply.
  end.
  run proc-export in this-procedure no-error .
  if error-status :error
  then do:
    message
      "Ошибка экспорта!" skip
      trim( return-value ) skip
      trim( error-status :get-message(1) )
    view-as alert-box information.
    return no-apply.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-imp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-imp Dialog-Frame
ON CHOOSE OF b-imp IN FRAME Dialog-Frame /* Импорт */
DO:
  assign
    fi-filename
  .
  if trim(fi-filename) = ""
  then do:
    message
      "Введите имя файла"
    view-as alert-box error.
    return no-apply.
  end.
  run proc-import in this-procedure no-error .
  if error-status :error
  then do:
    message
      "Ошибка импорта!" skip
      trim( return-value ) skip
      trim( error-status :get-message(1) )
    view-as alert-box information.
    return no-apply.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sel-file
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sel-file Dialog-Frame
ON CHOOSE OF b-sel-file IN FRAME Dialog-Frame
DO:

  define variable v-filename as character no-undo.
  define variable v-log as logical no-undo.

  SYSTEM-DIALOG GET-FILE v-filename
                TITLE   "Файл"
                FILTERS "Все файлы (*.*)"    "*.*"
                USE-FILENAME
                UPDATE v-log.
  if not v-log then do:
    return no-apply .
  end.
  else do:
    assign
      fi-filename = v-filename
    .
    display
      fi-filename
    with frame {&frame-name}.
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

{ gbl/app_help.i }
{ gbl/hot-key.i b-exit }

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  RUN my-enable in this-procedure .
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
  DISPLAY fi-filename
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-imp b-exp B-help fi-filename b-sel-file
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-disable Dialog-Frame
PROCEDURE my-disable :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-enable Dialog-Frame
PROCEDURE my-enable :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  define variable v-naim          as character        no-undo.
  define variable v-list          as character        no-undo.
  define variable v-print-graft   as logical          no-undo.
  define variable v-sort-gr       as logical          no-undo.
  define variable v-type-price    as logical          no-undo.
  define variable v-type-val      as logical          no-undo.
  define variable v-found         as logical          no-undo.
  define variable v-filename      as character        no-undo .

  { gbl/getcntxt.i get }
  run uf-get ( input {&uf-iecliart}
                , input  v-cntxt-userid
                , output v-list
                , output v-naim
                , output v-print-graft
                , output v-sort-gr
                , output v-type-price
                , output v-type-val
                ).
    assign
      fi-filename = v-list
    .

  display
    fi-filename
  with frame {&frame-name}.
  enable
    b-exit
    b-imp
    b-exp
    b-help
    fi-filename
    b-sel-file
  with frame {&frame-name}.
  view frame {&frame-name}.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-export Dialog-Frame
PROCEDURE proc-export :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error return-value
:
  run proc-fltsave in this-procedure .
  run utl/expclia.p ( input parparentproc
                    , input fi-filename
                    ) .
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-import Dialog-Frame
PROCEDURE proc-import :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error return-value
:
  run proc-fltsave in this-procedure .
  run utl/impclia.p ( input parparentproc
                    , input fi-filename
                    ) .
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-fltsave Dialog-Frame
PROCEDURE proc-fltsave :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
do
on error undo, return error return-value
:
  define variable v-naim          as character        no-undo.
  define variable v-list          as character        no-undo.
  define variable v-print-graft   as logical          no-undo.
  define variable v-sort-gr       as logical          no-undo.
  define variable v-type-price    as logical          no-undo.
  define variable v-type-val      as logical          no-undo.
  define variable v-found         as logical          no-undo.

  assign
    v-list = trim( fi-filename )
  .
  run uf-set ( input {&uf-iecliart}
                , input v-cntxt-userid
                , input v-list
                , input v-naim
                , input v-print-graft
                , input v-sort-gr
                , input v-type-price
                , input v-type-val
                ) .
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME