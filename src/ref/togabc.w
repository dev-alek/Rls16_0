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

Выбор групп ABC

Автор: Чернова Светлана Александровна
Дата создания: 03/03/06
Author: Svetlana Chernova
Creation date: 03/03/06

Дата создания: 07/07/05
*/
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

define input  parameter p-type as character no-undo .
define output parameter p-list as character no-undo .

/* Local Variable Definitions ---                                       */

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Выбор групп".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/showinf.i  }
{ gbl/thbjattr.i }
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit B-quit B-Help T-AX T-AY T-AZ T-BX ~
T-BY T-BZ T-CX  T-CY T-CZ T-DX T-DY T-DZ T-EX T-EY T-EZ T-FX  T-FY ~
T-FZ X Y Z A B C D E F
&Scoped-Define DISPLAYED-OBJECTS T-AX T-AY T-AZ T-BX T-BY T-BZ T-CX  ~
T-CY T-CZ T-DX T-DY T-DZ T-EX T-EY T-EZ T-FX  T-FY T-FZ X Y Z A B C D E ~
F

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-Help
     LABEL "Помощь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE A AS CHARACTER FORMAT "X(256)":U INITIAL "A"
      VIEW-AS TEXT
     SIZE 1.5 BY .67 NO-UNDO.

DEFINE VARIABLE B AS CHARACTER FORMAT "X(256)":U INITIAL "B"
      VIEW-AS TEXT
     SIZE 1.5 BY .67 NO-UNDO.

DEFINE VARIABLE C AS CHARACTER FORMAT "X(256)":U INITIAL "C"
      VIEW-AS TEXT
     SIZE 1.5 BY .67 NO-UNDO.

DEFINE VARIABLE D AS CHARACTER FORMAT "X(256)":U INITIAL "D"
      VIEW-AS TEXT
     SIZE 1.5 BY .67 NO-UNDO.

DEFINE VARIABLE E AS CHARACTER FORMAT "X(256)":U INITIAL "E"
      VIEW-AS TEXT
     SIZE 1.5 BY .67 NO-UNDO.

DEFINE VARIABLE F AS CHARACTER FORMAT "X(256)":U INITIAL "F"
      VIEW-AS TEXT
     SIZE 1.5 BY .67 NO-UNDO.

DEFINE VARIABLE X AS CHARACTER FORMAT "X(256)":U INITIAL "X"
      VIEW-AS TEXT
     SIZE 1.5 BY .67 NO-UNDO.

DEFINE VARIABLE Y AS CHARACTER FORMAT "X(256)":U INITIAL "Y"
      VIEW-AS TEXT
     SIZE 1.5 BY .67 NO-UNDO.

DEFINE VARIABLE Z AS CHARACTER FORMAT "X(256)":U INITIAL "Z"
      VIEW-AS TEXT
     SIZE 1.5 BY .67 NO-UNDO.

DEFINE VARIABLE T-AX AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .83 NO-UNDO.

DEFINE VARIABLE T-AY AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .83 NO-UNDO.

DEFINE VARIABLE T-AZ AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .83 NO-UNDO.

DEFINE VARIABLE T-BX AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .83 NO-UNDO.

DEFINE VARIABLE T-BY AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .83 NO-UNDO.

DEFINE VARIABLE T-BZ AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .83 NO-UNDO.

DEFINE VARIABLE T-CY AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .83 NO-UNDO.

DEFINE VARIABLE T-CZ AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .83 NO-UNDO.

DEFINE VARIABLE T-DX AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .83 NO-UNDO.

DEFINE VARIABLE T-DY AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .83 NO-UNDO.

DEFINE VARIABLE T-DZ AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .83 NO-UNDO.

DEFINE VARIABLE T-EX AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .83 NO-UNDO.

DEFINE VARIABLE T-EY AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .83 NO-UNDO.

DEFINE VARIABLE T-EZ AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .83 NO-UNDO.

DEFINE VARIABLE T-FY AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .83 NO-UNDO.

DEFINE VARIABLE T-FZ AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .83 NO-UNDO.

DEFINE VARIABLE T-CX  AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .83 NO-UNDO.

DEFINE VARIABLE T-FX  AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .83 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     B-quit AT ROW 1 COL 11
     B-Help AT ROW 1 COL 21
     T-AX AT ROW 4.25 COL 11
     T-AY AT ROW 4.25 COL 16
     T-AZ AT ROW 4.25 COL 21
     T-BX AT ROW 6.25 COL 11
     T-BY AT ROW 6.25 COL 16
     T-BZ AT ROW 6.25 COL 21
     T-CX  AT ROW 8.25 COL 11
     T-CY AT ROW 8.25 COL 16
     T-CZ AT ROW 8.25 COL 21
     T-DX AT ROW 10.25 COL 11
     T-DY AT ROW 10.25 COL 16
     T-DZ AT ROW 10.25 COL 21
     T-EX AT ROW 12.25 COL 11
     T-EY AT ROW 12.25 COL 16
     T-EZ AT ROW 12.25 COL 21
     T-FX  AT ROW 14.25 COL 11
     T-FY AT ROW 14.25 COL 16
     T-FZ AT ROW 14.25 COL 21
     X AT ROW 3 COL 11 NO-LABEL
     Y AT ROW 3 COL 16.5 NO-LABEL
     Z AT ROW 3 COL 21.5 NO-LABEL
     A AT ROW 4.25 COL 8 NO-LABEL
     B AT ROW 6.25 COL 8 NO-LABEL
     C AT ROW 8.25 COL 8 NO-LABEL
     D AT ROW 10.25 COL 8 NO-LABEL
     E AT ROW 12.25 COL 8 NO-LABEL
     F AT ROW 14.25 COL 8 NO-LABEL
     SPACE(21.87) SKIP(2.20)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Выбор групп"
         DEFAULT-BUTTON b-exit CANCEL-BUTTON B-quit.


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

/* SETTINGS FOR FILL-IN A IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN B IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN C IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN D IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN E IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN F IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN X IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN Y IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN Z IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Выбор групп */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-quit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-quit Dialog-Frame
ON CHOOSE OF B-quit IN FRAME Dialog-Frame /* Cancel */
DO:
  p-list = "".
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit Dialog-Frame
ON CHOOSE OF b-exit IN FRAME Dialog-Frame /* OK */
DO:
p-list = "" .
assign
t-ax
T-AY
T-AZ
T-BX
T-BY
T-BZ
T-CX
T-CY
T-CZ
T-DX
T-DY
T-DZ
T-EX
T-EY
T-EZ
T-FX
T-FY
T-FZ
.
case caps(p-type) :
when "ABCXYZ" then do:
  if t-ax = true then p-list = p-list + "AX," .
  if T-AY = true then p-list = p-list + "AY," .
  if T-AZ = true then p-list = p-list + "AZ," .
  if T-BX = true then p-list = p-list + "BX," .
  if T-BY = true then p-list = p-list + "BY," .
  if T-BZ = true then p-list = p-list + "BZ," .
  if T-CX = true then p-list = p-list + "CX," .
  if T-CY = true then p-list = p-list + "CY," .
  if T-CZ = true then p-list = p-list + "CZ," .
  if T-DX = true then p-list = p-list + "DX," .
  if T-DY = true then p-list = p-list + "DY," .
  if T-DZ = true then p-list = p-list + "DZ," .
  if T-EX = true then p-list = p-list + "EX," .
  if T-EY = true then p-list = p-list + "EY," .
  if T-EZ = true then p-list = p-list + "EZ," .
  if T-FX = true then p-list = p-list + "FX," .
  if T-FY = true then p-list = p-list + "FY," .
  if T-FZ = true then p-list = p-list + "FZ," .
end.
when "ABC" then do:
  if t-ax = true then p-list = p-list + "A," .
  if T-BX = true then p-list = p-list + "B," .
  if T-CX = true then p-list = p-list + "C," .
  if T-DX = true then p-list = p-list + "D," .
  if T-EX = true then p-list = p-list + "E," .
  if T-FX = true then p-list = p-list + "F," .
end.
when "XYZ" then do:
  if t-ax = true then p-list = p-list + "X," .
  if T-AY = true then p-list = p-list + "Y," .
  if T-AZ = true then p-list = p-list + "Z," .
end.

end case.

 p-list = trim(p-list, ",").
 if p-list = ""  then do:
    message "Ни чего не выбрано !" .
    return no-apply.
 end.
 message "выбраны группы" p-list .
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
  run my-enable.

  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
run disable_ui.

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
  DISPLAY T-AX T-AY T-AZ T-BX T-BY T-BZ T-CX  T-CY T-CZ T-DX T-DY T-DZ T-EX T-EY T-EZ T-FX  T-FY T-FZ X Y Z A B C D E F
      WITH FRAME Dialog-Frame.
  ENABLE b-exit B-quit B-Help T-AX T-AY T-AZ T-BX T-BY T-BZ T-CX  T-CY
         T-CZ T-DX T-DY T-DZ T-EX T-EY T-EZ T-FX  T-FY T-FZ X Y Z A B C D E
         F
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-enable Dialog-Frame
PROCEDURE my-enable :

 ENABLE b-exit B-quit B-Help WITH FRAME Dialog-Frame.

    CASE caps(p-type):
        WHEN "ABC" THEN DO:
            DISPLAY T-AX  T-BX T-CX  T-DX T-EX T-FX  A B C D E F WITH FRAME Dialog-Frame.
            ENABLE  T-AX  T-BX T-CX  T-DX T-EX T-FX  A B C D E F WITH FRAME Dialog-Frame.
        END.
        WHEN "XYZ" THEN DO:
            DISPLAY T-AX T-AY T-AZ X Y Z  WITH FRAME Dialog-Frame.
            ENABLE  T-AX T-AY T-AZ X Y Z  WITH FRAME Dialog-Frame.
        END.
        WHEN "ABCXYZ" THEN DO:
            DISPLAY T-AX T-AY T-AZ T-BX T-BY T-BZ T-CX  T-CY T-CZ T-DX T-DY T-DZ T-EX
            T-EY T-EZ T-FX  T-FY T-FZ X Y Z A B C D E F
            WITH FRAME Dialog-Frame.
            ENABLE  T-AX T-AY T-AZ T-BX T-BY T-BZ T-CX  T-CY
            T-CZ T-DX T-DY T-DZ T-EX T-EY T-EZ T-FX  T-FY T-FZ X Y Z A B C D E
            F WITH FRAME Dialog-Frame.
        END.
    END CASE.

define variable par-type as character no-undo .
define variable par-abc-type as character no-undo .
define variable  v-value-date    as date   no-undo .
define variable  v-value-decimal as decimal   no-undo .
define variable  v-value-integer as integer   no-undo .
define variable  v-value-logical as logical   no-undo .
define variable v-found as logical   no-undo .
run thbjattr_value in this-procedure  (
  input   "",
  input   0 ,
  input   {&attr-abc-global} ,
  input   'abc-type'  ,
  output  par-abc-type ,
  output  v-value-date      ,
  output  v-value-decimal   ,
  output  v-value-integer   ,
  output  v-value-logical   ,
  output  par-type            ,
  output  v-found
  ) no-error
  .
  if error-status :error or v-found = false then do:
      message "Нет настроек Ассортиментной политики !!!." view-as alert-box information .
      return error return-value .
  end.


   case par-abc-type :
      when 'ABC':U  then do:
         hide T-DX T-EX T-FX
              T-DY T-EY T-FY
              T-DZ T-EZ T-FZ
              D E F in frame dialog-frame.
      end.

      when 'ABCD':U  then do:
         hide T-EX T-FX T-EY T-FY T-EZ T-FZ E F in frame dialog-frame.
      end.

      when 'ABCDE':U  then do:
         hide  T-FX  T-FY T-FZ F in frame dialog-frame.
      end.

   end case.

  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME