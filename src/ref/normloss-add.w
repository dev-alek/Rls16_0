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

Связать товары с Меркурием

Автор: Шкляр Елена
Дата создания: 10/10/08
Author: Shklyar Elena
Creation date: 10/10/08

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */
using ibs.th.str.gds.*.
using ibs.th.str.mercury.*.
using ibs.th.gbl.storage.*.
using ibs.th.bge.mercury.*.

/* Parameters Definitions ---                                           */
DEFINE INPUT        PARAMETER parparentproc AS WIDGET-HANDLE  NO-UNDO.
DEFINE INPUT        PARAMETER p-type        AS integer        NO-UNDO.


/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Добавление норм технологических потерь".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }

DEFINE BUFFER buf_norm-loss       for ub.norm-loss .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-exit b-quit B-Help f-clim-grp f-position ~
f-sec-vol f-sec-vol-2 f-oil-grp f-season f-value 
&Scoped-Define DISPLAYED-OBJECTS f-clim-grp f-position f-sec-vol ~
f-sec-vol-2 f-oil-grp f-season f-value 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-exit AUTO-GO 
     LABEL "&Ввод" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-Help 
     LABEL "Помо&щь" 
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-quit AUTO-END-KEY 
     LABEL "&Отмена" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE f-clim-grp AS CHARACTER FORMAT "X(256)":U 
     LABEL "Климатическая группа" 
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEMS "1(1)","1(2)","2(1)","2(3)","3(1)","3(2)" 
     DROP-DOWN-LIST
     SIZE 29 BY 1 NO-UNDO.

DEFINE VARIABLE f-oil-grp AS CHARACTER FORMAT "X(9)":U 
     LABEL "Группа нефтепродуктов" 
     VIEW-AS COMBO-BOX INNER-LINES 4
     LIST-ITEMS "I","II","III","IV" 
     DROP-DOWN-LIST
     SIZE 29 BY 1 NO-UNDO.

DEFINE VARIABLE f-position AS CHARACTER FORMAT "X(256)":U 
     LABEL "Расположение" 
     VIEW-AS COMBO-BOX INNER-LINES 2
     LIST-ITEM-PAIRS "наземный","0",
                     "подземный","1"
     DROP-DOWN-LIST
     SIZE 29 BY 1 NO-UNDO.

DEFINE VARIABLE f-season AS CHARACTER FORMAT "X(256)":U 
     LABEL "Период" 
     VIEW-AS COMBO-BOX INNER-LINES 2
     LIST-ITEM-PAIRS "весенне-летний","0",
                     "осенне-зимний","1"
     DROP-DOWN-LIST
     SIZE 29 BY 1 NO-UNDO.

DEFINE VARIABLE f-sec-vol AS DECIMAL FORMAT "->>,>>9":U INITIAL 0 
     LABEL "Вместительность" 
     VIEW-AS FILL-IN 
     SIZE 6.75 BY 1 TOOLTIP "[Ниж.ур]–[Верх.ур], если верх.ур не определен, то указ. только нижн.ур" NO-UNDO.

DEFINE VARIABLE f-sec-vol-2 AS DECIMAL FORMAT "->>,>>9":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 6.75 BY 1 TOOLTIP "[Ниж.ур]–[Верх.ур], если верх.ур не определен, то указ. только нижн.ур" NO-UNDO.

DEFINE VARIABLE f-value AS DECIMAL FORMAT "->>,>>9.999":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 29 BY 1 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-Help AT ROW 1 COL 52.5
     f-clim-grp AT ROW 3.17 COL 23.25 COLON-ALIGNED WIDGET-ID 40
     f-position AT ROW 4.33 COL 23.25 COLON-ALIGNED WIDGET-ID 42
     f-sec-vol AT ROW 5.5 COL 23.25 COLON-ALIGNED WIDGET-ID 22
     f-sec-vol-2 AT ROW 5.5 COL 33.63 COLON-ALIGNED NO-LABEL WIDGET-ID 58
     f-oil-grp AT ROW 6.67 COL 23.25 COLON-ALIGNED WIDGET-ID 50
     f-season AT ROW 7.83 COL 23.25 COLON-ALIGNED WIDGET-ID 52
     f-value AT ROW 10.42 COL 14.25 NO-LABEL WIDGET-ID 54
     "Значение нормы технологических потерь" VIEW-AS TEXT
          SIZE 38 BY 1 AT ROW 9.17 COL 10.38 WIDGET-ID 56
     "-" VIEW-AS TEXT
          SIZE 2 BY .67 AT ROW 5.71 COL 33.13 WIDGET-ID 60
     SPACE(22.99) SKIP(5.82)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Нормы технологических потерь"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.


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

/* SETTINGS FOR FILL-IN f-value IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Нормы технологических потерь */
DO:
    APPLY "END-ERROR":U TO SELF.
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-exit Dialog-Frame
ON CHOOSE OF B-exit IN FRAME Dialog-Frame /* Ввод */
DO:
    RUN proc-save IN THIS-PROCEDURE NO-ERROR.
    IF ERROR-STATUS:error THEN RETURN NO-APPLY.
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-clim-grp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-clim-grp Dialog-Frame
ON VALUE-CHANGED OF f-clim-grp IN FRAME Dialog-Frame /* Климатическая группа */
DO:
  assign f-clim-grp .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-oil-grp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-oil-grp Dialog-Frame
ON VALUE-CHANGED OF f-oil-grp IN FRAME Dialog-Frame /* Группа нефтепродуктов */
DO:
  assign
  f-oil-grp
  .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-position
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-position Dialog-Frame
ON VALUE-CHANGED OF f-position IN FRAME Dialog-Frame /* Расположение */
DO:
    assign
      f-position
    .  
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-season
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-season Dialog-Frame
ON VALUE-CHANGED OF f-season IN FRAME Dialog-Frame /* Период */
DO:
  assign
  f-season
  .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-sec-vol
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-sec-vol Dialog-Frame
ON LEAVE OF f-sec-vol IN FRAME Dialog-Frame /* Вместительность */
DO:
      assign f-sec-vol .
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-sec-vol-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-sec-vol-2 Dialog-Frame
ON LEAVE OF f-sec-vol-2 IN FRAME Dialog-Frame
DO:
      assign f-sec-vol-2 .
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-value
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-value Dialog-Frame
ON LEAVE OF f-value IN FRAME Dialog-Frame
DO:
  assign f-value .
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
  RUN Myenable IN THIS-PROCEDURE.
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
  DISPLAY f-clim-grp f-position f-sec-vol f-sec-vol-2 f-oil-grp f-season f-value 
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-Help f-clim-grp f-position f-sec-vol f-sec-vol-2 
         f-oil-grp f-season f-value 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI_fill Dialog-Frame 
PROCEDURE enable_UI_fill :
DISPLAY
    f-clim-grp
    f-oil-grp
    f-position
    f-season
    f-sec-vol
    f-sec-vol-2
    f-value
    with frame {&frame-name}.
    
    
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame 
PROCEDURE MyEnable :
enable
      f-clim-grp
      f-oil-grp
      f-position
      f-season
      f-sec-vol
      f-sec-vol-2
      f-value
      B-exit b-quit B-Help
      with frame {&frame-name} .
  VIEW FRAME {&frame-name}.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-save Dialog-Frame 
PROCEDURE proc-save :
define variable ii  as integer no-undo .
  
  find last buf_norm-loss no-lock no-error.
  if available (buf_norm-loss) then do:
    ii = buf_norm-loss.id + 1 .
  end.  
  else ii = 1 .
  
  create buf_norm-loss .
  assign
        buf_norm-loss.id         = ii
        buf_norm-loss.type       = p-type
        buf_norm-loss.clim-grp   = f-clim-grp
        buf_norm-loss.oil-grp    = f-oil-grp
        buf_norm-loss.position   = f-position
        buf_norm-loss.sec-vol1   = f-sec-vol
        buf_norm-loss.sec-vol2   = f-sec-vol-2
        buf_norm-loss.value-loss = decimal(f-value) 
  .
  
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

