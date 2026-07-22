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

Процент торговой наценки

Автор: Чернова Светлана Александровна
Дата создания: 03/11/08
Author: Svetlana Chernova
Creation date: 03/11/08

Автор1: Суслов Алексей Юрьевич
Дата создания: 03/27/06

Creation date: 09/10/04 11:17

*/
/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                          */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Процент торговой наценки".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i }
{ gbl/color.i }
define input  parameter parwith-tax    as integer no-undo.
define output parameter parpc          as decimal no-undo.
define output parameter parflag-return as logical no-undo.
define output parameter round-base     as decimal no-undo. /* база для округления / коэффициент */
define output parameter round-method   as char    no-undo. /* способ округления */


/* Local Variable Definitions ---                                       */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-ok b-cancel b-help varpc
&Scoped-Define DISPLAYED-OBJECTS EDITOR-1 varpc

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

DEFINE BUTTON b-help
     LABEL "&Помощь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-ok AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE EDITOR-1 AS CHARACTER
     VIEW-AS EDITOR
     SIZE 31.25 BY 2.33 NO-UNDO.

DEFINE VARIABLE varpc AS DECIMAL FORMAT "->>>9.99%":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 8.63 BY 1.04 NO-UNDO.
define variable par-pr-rndmt as character no-undo.
define variable par-type     as character no-undo.
define variable par-pr-rndbs as character no-undo.

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-ok AT ROW 1.17 COL 1.38
     b-cancel AT ROW 1.17 COL 11.75
     b-help AT ROW 1.17 COL 22.13
     EDITOR-1 AT ROW 2.46 COL 4 NO-LABEL
     varpc AT ROW 5.08 COL 15.5 COLON-ALIGNED NO-LABEL
     round-method  AT ROW 6.2 COL 13 COLON-ALIGNED LABEL "Окру&гление"
        format "x(15)" VIEW-AS COMBO-BOX INNER-LINES 7 LIST-ITEMS
        {&pr-round-9end},
        {&pr-round-9-99end},
        {&pr-round-integer},
        {&pr-round-select},
        {&pr-round-up},
        {&pr-round-coef},
        {&pr-round-off}
        SIZE 15 BY 1 bgcolor WHITE_COLOR
     round-base    AT ROW 7.2  COL 15 COLON-ALIGNED no-LABEL
        format "->>,>>9.99" VIEW-AS FILL-IN SIZE 10 BY 1 bgcolor WHITE_COLOR
     SPACE(13.11) SKIP(0.33)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Процент торг.наценки"
         DEFAULT-BUTTON b-ok CANCEL-BUTTON b-cancel.


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

/* SETTINGS FOR EDITOR EDITOR-1 IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME






/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Процент торг.наценки */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

ON LEAVE OF round-base IN FRAME {&frame-name} DO:
if input frame {&frame-name} round-base = 0 then do:
  if input frame {&frame-name} round-method = {&pr-round-select} then
    message "Такое округление невозможно - деление на 0."
            view-as alert-box error.
  else
    message "Пересчет по нулевому коэффициенту невозможен - получится 0."
            view-as alert-box error.
end.
else
  assign
    round-base.
disp round-base with frame {&frame-name}.
END.

ON value-changed OF round-method IN FRAME {&frame-name} DO:
if lookup( input frame {&frame-name} round-method, {&pr-rounds-need-coef} ) > 0 then do:
    enable round-base with frame {&frame-name}.
    disp round-base with frame {&frame-name}.
  end.
  else
    hide round-base in frame {&frame-name}.
assign frame {&frame-name} round-method.
END.


&Scoped-define SELF-NAME b-ok
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-ok Dialog-Frame
ON CHOOSE OF b-ok IN FRAME Dialog-Frame /* Ввод */
DO:

  assign parpc = input frame {&frame-name} varpc
        parflag-return = yes.
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
  run gbl/conf-rd.p ("pr-rndmt", 0, "", 0, "", "", "", no, output par-pr-rndmt, output par-type) no-error.
  run gbl/conf-rd.p ("pr-rndbs", 0, "", 0, "", "", "", no, output par-pr-rndbs, output par-type) no-error.
  assign
    round-method = par-pr-rndmt
    round-base   = decimal (par-pr-rndbs)
    no-error.
  case par-pr-rndmt:
    when "pr-round-9end" then
      round-method = {&pr-round-9end}.
    when "pr-round-9-99end" then
      round-method = {&pr-round-9-99end}.
    when "pr-round-integer" then
      round-method = {&pr-round-integer}.
    when "pr-round-select" then
      round-method = {&pr-round-select}.
    when "pr-round-up" then
      round-method = {&pr-round-up}.
    when "pr-round-coef" then
      round-method = {&pr-round-coef}.
    when "pr-round-off" then
      round-method = {&pr-round-off}.
    otherwise
      round-method = {&pr-round-off}.
  end case.
  case parwith-tax:
  when 1 then do:
    assign editor-1 = "Оптовый(без НП) процент наценки/скидки к учетной цене без НДС поставщика".
  end.
  when 2 then do:
    assign editor-1 = "Оптовый(без НП) процент наценки/скидки к учетной цене c НДС поставщика".
  end.
  when 3 then do:
    assign editor-1 = "Безналоговый процент наценки/скидки к учетной цене без НДС и НП поставщика".
  end.
  end case.
  RUN enable_UI.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

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
  DISPLAY EDITOR-1 varpc
      WITH FRAME Dialog-Frame.
  ENABLE b-ok b-cancel b-help varpc
         round-method
         WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  if input frame {&frame-name} round-method = "" then do:
    round-method = {&pr-round-off}.
    disp round-method with frame {&frame-name}.
  end.
  if lookup( input frame {&frame-name} round-method, {&pr-rounds-need-coef} ) > 0 then do:
    enable round-base with frame {&frame-name}.
    disp round-base with frame {&frame-name}.
  end.
  else
    hide round-base in frame {&frame-name}.

  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME