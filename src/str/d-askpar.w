&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v9r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*------------------------------------------------------------------------

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Выбор редактируемого параметра для утилиты изменения параметров прихода

Автор: Хныкин Павел Андреевич
Дата создания: 07/04/07
Author: Pavel Khnykin
Creation date: 07/04/07

Автор1: Степанов Федор Владимирович
Дата создания: 01/27/06

------------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input  parameter p-doc-line-recid as recid no-undo.
define input  parameter p-single-db      as logical no-undo.
define input  parameter p-alcohol-prod   as logical no-undo.
define output parameter p-par-type       as integer no-undo.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Выбор редактируемого параметра для утилиты изменения параметров прихода".
{ cmp/vssrevis.i }
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
&Scoped-Define ENABLED-OBJECTS rs-par-type b-ok b-cansel b-help
&Scoped-Define DISPLAYED-OBJECTS rs-par-type fi-doc-name fi-artic

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-cansel AUTO-END-KEY
     LABEL "Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-help
     LABEL "Помощь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-ok AUTO-GO
     LABEL "Выбор"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE fi-artic AS CHARACTER FORMAT "X(256)":U INITIAL "1511947 орг 1313"
     LABEL "Артикул"
      VIEW-AS TEXT
     SIZE 29 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fi-doc-name AS CHARACTER FORMAT "X(256)":U INITIAL "491153-"
     LABEL "Документ"
      VIEW-AS TEXT
     SIZE 24 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE rs-par-type AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "НДС поставщика", 1,
"ГТД партии", 2,
"Срок годности", 3,
"Атрибуты алкогольной продукции", 4
     SIZE 45.5 BY 4.27 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     rs-par-type AT ROW 4.47 COL 4 NO-LABEL
     b-ok AT ROW 10.87 COL 4.5
     b-cansel AT ROW 10.87 COL 15.5
     b-help AT ROW 10.87 COL 50.5
     fi-doc-name AT ROW 1.27 COL 10 COLON-ALIGNED
     fi-artic AT ROW 2.07 COL 10 COLON-ALIGNED
     " Доступные для изменения параметры" VIEW-AS TEXT
          SIZE 61.5 BY .67 AT ROW 3.67 COL 1.5
          BGCOLOR 3 FGCOLOR 15
     SPACE(0.99) SKIP(8.18)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Изменение параметров прихода"
         DEFAULT-BUTTON b-ok CANCEL-BUTTON b-cansel.


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

/* SETTINGS FOR FILL-IN fi-artic IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN fi-doc-name IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN
       rs-par-type:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _Options          = "SHARE-LOCK"
     _Query            is NOT OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Изменение параметров прихода */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-ok
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-ok Dialog-Frame
ON CHOOSE OF b-ok IN FRAME Dialog-Frame /* Выбор */
DO:
  assign frame {&frame-name} rs-par-type.
  p-par-type = rs-par-type.
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

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

  run MyEnable.

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
  DISPLAY rs-par-type fi-doc-name fi-artic
      WITH FRAME Dialog-Frame.
  ENABLE rs-par-type b-ok b-cansel b-help
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  define variable v-radio-buttons as character no-undo.
  define variable v-num-buttons   as integer   no-undo.

  define buffer buf_doc-line for ub.doc-line.

  find buf_doc-line no-lock where recid (buf_doc-line) = p-doc-line-recid no-error.
  if available buf_doc-line then do:
    assign
      fi-doc-name = buf_doc-line.doc-code
      fi-artic    = buf_doc-line.artic + " "
                  + buf_doc-line.prod-type + " "
                  + string(buf_doc-line.prod-code)
    .
  end.

  /* Формируем список радиокнопок */
  assign
    v-radio-buttons = (if p-single-db
                         then substitute ("&1,1":u, "НДС поставщика") + ","
                         else "")
                    + substitute ("&1,2":u, "ГТД партии") + ","
                    + substitute ("&1,3":u, "Срок годности")
                    + (if p-alcohol-prod
                         then "," + substitute ("&1,4":u, "Атрибуты алкогольной продукции")
                         else "")
    rs-par-type :radio-buttons in frame {&frame-name} = v-radio-buttons
    v-num-buttons = rs-par-type :num-buttons in frame {&frame-name}
    rs-par-type :height-chars  in frame {&frame-name} = 1.07 * v-num-buttons
    .

  display fi-doc-name fi-artic rs-par-type
      with frame {&frame-name}.
  enable rs-par-type b-ok b-cansel b-help
      with frame {&frame-name}.
  view frame {&frame-name}.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME