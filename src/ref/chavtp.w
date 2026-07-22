&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
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

Параметры настройки автопереоценки

Автор: Чернова Светлана Александровна
Дата создания: 03/30/09
Author: Svetlana Chernova
Creation date: 03/30/09

*/

define input-output  parameter p-gen-marg    as character   no-undo .
define input-output  parameter p-gen-marg-parts  as character   no-undo .
define input-output  parameter p-objfirst    as integer     no-undo .
define input-output  parameter p-objsecond   as integer     no-undo .
define input-output  parameter p-pr-nakl     as logical     no-undo .
define input  parameter p-ext-doc-type as character no-undo .


define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Параметры настройки автопереоценки".

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i }

/*------------------------------------------------------------------------

  File:

  Description:

  Input Parameters:
      <none>

  Output Parameters:
      <none>

  Author:

  Created:
------------------------------------------------------------------------*/
/*          This .W file was created with the Progress AppBuilder.       */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

/*


*/

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-OK B-Cancel B-Help gen-marg gen-marg-parts ~
objfirst objsecond pr-nakl
&Scoped-Define DISPLAYED-OBJECTS gen-marg gen-marg-parts objfirst objsecond ~
pr-nakl

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-Cancel AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-Help
     LABEL "&Help"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-OK AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE gen-marg AS CHARACTER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Нет           (No-margin)", "No-margin",
"До прихода    (Before-margin)", "Before-margin",
"После прихода (After-margin)", "After-margin"
     SIZE 32.75 BY 2.5 NO-UNDO.

DEFINE VARIABLE gen-marg-parts AS CHARACTER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Нет           (No-margin)", "No-margin",
"После прихода (After-margin)", "After-margin"
     SIZE 32.75 BY 1.5 NO-UNDO.

DEFINE VARIABLE objfirst AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "только по текущему объекту", 0,
"по всей группе распространения", 1
     SIZE 50 BY 1.96 NO-UNDO.

DEFINE VARIABLE objsecond AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "только по текущему объекту", 0,
"по всей группе распространения", 1
     SIZE 50 BY 1.63 NO-UNDO.

DEFINE VARIABLE pr-nakl AS LOGICAL INITIAL no
     LABEL "Назначать продажную цену прямо в документе прихода"
     VIEW-AS TOGGLE-BOX
     SIZE 56 BY .83 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-OK AT ROW 1 COL 1
     B-Cancel AT ROW 1 COL 11
     B-Help AT ROW 1 COL 56
     gen-marg AT ROW 3 COL 3.38 NO-LABEL WIDGET-ID 2
     gen-marg-parts AT ROW 6.75 COL 3.38 NO-LABEL WIDGET-ID 22
     objfirst AT ROW 9.29 COL 3.38 NO-LABEL WIDGET-ID 10
     objsecond AT ROW 12.88 COL 3.38 NO-LABEL WIDGET-ID 14
     pr-nakl AT ROW 15.92 COL 3.38 WIDGET-ID 20
     "Тип автопереоценки" VIEW-AS TEXT
          SIZE 19 BY .67 AT ROW 2.25 COL 2 WIDGET-ID 6
          FGCOLOR 4
     "Способ формирования автопереоценки по новому товару" VIEW-AS TEXT
          SIZE 52 BY .67 AT ROW 8.54 COL 2 WIDGET-ID 8
          FGCOLOR 4
     "Способ формирования автопереоценки по НЕ новому товару" VIEW-AS TEXT
          SIZE 59 BY .67 AT ROW 12.13 COL 2 WIDGET-ID 18
          FGCOLOR 4
     "Автопереоценка по ПАРТИЯМ " VIEW-AS TEXT
          SIZE 28.5 BY .67 AT ROW 6 COL 2 WIDGET-ID 26
          FGCOLOR 4
     SPACE(36.99) SKIP(12.86)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "<insert dialog title>"
         DEFAULT-BUTTON B-OK CANCEL-BUTTON B-Cancel WIDGET-ID 100.


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

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* <insert dialog title> */
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


&Scoped-define SELF-NAME B-OK
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-OK Dialog-Frame
ON CHOOSE OF B-OK IN FRAME Dialog-Frame /* Ввод */
DO:
  assign
    gen-marg
    gen-marg-parts
    objfirst
    objsecond
    pr-nakl
    .

  assign
    p-gen-marg       = gen-marg
    p-gen-marg-parts = gen-marg-parts
    p-objfirst       = objfirst
    p-objsecond      = objsecond
    p-pr-nakl        = pr-nakl
    .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME gen-marg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL gen-marg Dialog-Frame
ON VALUE-CHANGED OF gen-marg IN FRAME Dialog-Frame
DO:
assign gen-marg .
  if gen-marg <> {&typeprice_Before-margin} then do:
    hide pr-nakl .
  end.
  else do:
    display pr-nakl with frame {&frame-name}.
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

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK :
   assign
   gen-marg:radio-buttons in frame {&frame-name} =
   "Нет           (No-margin)" + {&comma-char} +  {&typeprice_No-margin} + {&comma-char} +
   "До прихода    (Before-margin)" + {&comma-char} +  {&typeprice_Before-margin} + {&comma-char} +
   "После прихода (After-margin)"  + {&comma-char} +  {&typeprice_After-margin}
   .
   assign
   gen-marg-parts:radio-buttons in frame {&frame-name} =
   "Нет           (No-margin)" + {&comma-char} + {&typeprice_No-margin} + {&comma-char} +
   "После прихода (After-margin)" + {&comma-char} + {&typeprice_After-margin}
   .
    assign
      gen-marg       = p-gen-marg
      gen-marg-parts = p-gen-marg-parts
      objfirst       = p-objfirst
      objsecond      = p-objsecond
      pr-nakl        = p-pr-nakl
      .
   assign frame {&frame-name}:title = "Параметры настройки автопереоценки по " +
          entry( lookup( p-ext-doc-type, {&TDEDT_List} ), {&TDEDT_list-full} )
          .
  RUN enable_UI.

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
  DISPLAY gen-marg gen-marg-parts objfirst objsecond pr-nakl
      WITH FRAME Dialog-Frame.
  ENABLE B-OK B-Cancel B-Help gen-marg gen-marg-parts objfirst objsecond
         pr-nakl
      WITH FRAME Dialog-Frame.
  assign gen-marg.
  if gen-marg <> {&typeprice_Before-margin} then do:
    hide pr-nakl .
  end.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME