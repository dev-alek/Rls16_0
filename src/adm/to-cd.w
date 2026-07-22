&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
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

Экран настройки параметров отвечающих за отсылку товаров на кассу

Автор: Бахтадзе Наталья Викторовна
Дата создания: 22/02/00
Author: Bakhtadze Natalya
Creation date: 22/02/00

используется в настройках фирмы и настройках магазина

  Input Parameters:
    refmode
    hostcode
    objcode
    all-prt
    cd-bc-alt cd-bc-base cd-loc-alt cd-loc-base
    cd-parts-all cd-parts-not-blank cd-parts-ser
    cd-pb-alt cd-pb-base cd-sc-base

  Output Parameters:
    all-prt
    cd-bc-alt cd-bc-base cd-loc-alt cd-loc-base
    cd-parts-all cd-parts-not-blank cd-parts-ser
    cd-pb-alt cd-pb-base cd-sc-base

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT PARAMETER   ref-mode   as   char  no-undo.   /* {&add-def}, {&update}, {&lookup} */
DEFINE INPUT PARAMETER hostcode like ub.shop.host-code no-undo.
DEFINE INPUT PARAMETER objtype like ub.clients.obj-type no-undo.
DEFINE INPUT PARAMETER objcode like ub.shop.obj-code no-undo.
define input parameter p-frame-title as character no-undo .
DEFINE INPUT-OUTPUT PARAMETER all-prt like ub.shop.all-prt no-undo.
DEFINE INPUT-OUTPUT PARAMETER cd-bc-alt like ub.shop.cd-bc-alt no-undo.
DEFINE INPUT-OUTPUT PARAMETER cd-bc-base like ub.shop.cd-bc-base no-undo.
DEFINE INPUT-OUTPUT PARAMETER cd-loc-alt like ub.shop.cd-loc-alt no-undo.
DEFINE INPUT-OUTPUT PARAMETER cd-loc-base like ub.shop.cd-loc-base no-undo.
DEFINE INPUT-OUTPUT PARAMETER cd-parts-all like ub.shop.cd-parts-all no-undo.
DEFINE INPUT-OUTPUT PARAMETER cd-parts-not-blank like ub.shop.cd-parts-not-blank no-undo.
DEFINE INPUT-OUTPUT PARAMETER cd-parts-ser like ub.shop.cd-parts-ser no-undo.
DEFINE INPUT-OUTPUT PARAMETER cd-pb-alt like ub.shop.cd-pb-alt no-undo.
DEFINE INPUT-OUTPUT PARAMETER cd-pb-base like ub.shop.cd-pb-base no-undo.
DEFINE INPUT-OUTPUT PARAMETER cd-sc-base like ub.shop.cd-sc-base no-undo.

/* Local Variable Definitions ---                                       */

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "".
{ cmp/vssrevis.i }

{ cmp/trg-def.i }
{ cmp/showinf.i }

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS RECT-bc RECT-pb RECT-part B-exit B-quit ~
B-default B-help T-loc-base T-pb-base T-loc-alt T-pb-alt T-bc-base ~
T-sc-base T-bc-alt T-all-prt T-parts-ser T-parts-not-blank T-parts-all
&Scoped-Define DISPLAYED-OBJECTS T-loc-base T-pb-base T-loc-alt T-pb-alt ~
T-bc-base T-sc-base T-bc-alt T-all-prt T-parts-ser T-parts-not-blank ~
T-parts-all

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-default
     LABEL "По &умолчанию"
     SIZE 16 BY 1.

DEFINE BUTTON B-exit AUTO-GO
     LABEL "Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE RECTANGLE RECT-bc
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 31.38 BY 6.29.

DEFINE RECTANGLE RECT-part
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 31.38 BY 6.29.

DEFINE RECTANGLE RECT-pb
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 31.38 BY 6.29.

DEFINE VARIABLE T-all-prt AS LOGICAL INITIAL no
     LABEL "Отсылать все коды признаков"
     VIEW-AS TOGGLE-BOX
     SIZE 30.13 BY .79 NO-UNDO.

DEFINE VARIABLE T-bc-alt AS LOGICAL INITIAL no
     LABEL "неосновые бар-коды (EAN)"
     VIEW-AS TOGGLE-BOX
     SIZE 28.88 BY .79 NO-UNDO.

DEFINE VARIABLE T-bc-base AS LOGICAL INITIAL no
     LABEL "основные бар-коды (EAN)"
     VIEW-AS TOGGLE-BOX
     SIZE 28.88 BY .79 NO-UNDO.

DEFINE VARIABLE T-loc-alt AS LOGICAL INITIAL no
     LABEL "неосновные коды"
     VIEW-AS TOGGLE-BOX
     SIZE 28.88 BY .79 NO-UNDO.

DEFINE VARIABLE T-loc-base AS LOGICAL INITIAL no
     LABEL "основные коды"
     VIEW-AS TOGGLE-BOX
     SIZE 28.88 BY .79 NO-UNDO.

DEFINE VARIABLE T-parts-all AS LOGICAL INITIAL no
     LABEL "на весь товар"
     VIEW-AS TOGGLE-BOX
     SIZE 20.38 BY .79 NO-UNDO.

DEFINE VARIABLE T-parts-not-blank AS LOGICAL INITIAL no
     LABEL "на товар с непуст. N партий"
     VIEW-AS TOGGLE-BOX
     SIZE 29.63 BY .79 NO-UNDO.

DEFINE VARIABLE T-parts-ser AS LOGICAL INITIAL no
     LABEL "на серийный товар"
     VIEW-AS TOGGLE-BOX
     SIZE 21.13 BY .79 NO-UNDO.

DEFINE VARIABLE T-pb-alt AS LOGICAL INITIAL no
     LABEL "неосновн. ед.изм"
     VIEW-AS TOGGLE-BOX
     SIZE 21.88 BY .79 NO-UNDO.

DEFINE VARIABLE T-pb-base AS LOGICAL INITIAL no
     LABEL "основн. ед.изм"
     VIEW-AS TOGGLE-BOX
     SIZE 22 BY .79 NO-UNDO.

DEFINE VARIABLE T-sc-base AS LOGICAL INITIAL no
     LABEL "весовые и топливные"
     VIEW-AS TOGGLE-BOX
     SIZE 22.25 BY .79 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1.29 COL 1.63
     B-quit AT ROW 1.29 COL 11.63
     B-default AT ROW 1.29 COL 21.63
     B-help AT ROW 1.29 COL 49.75
     T-loc-base AT ROW 4.29 COL 2.5
     T-pb-base AT ROW 4.33 COL 34.5
     T-loc-alt AT ROW 5.42 COL 2.5
     T-pb-alt AT ROW 5.46 COL 34.5
     T-bc-base AT ROW 6.54 COL 2.5
     T-sc-base AT ROW 6.58 COL 34.5
     T-bc-alt AT ROW 7.79 COL 2.5
     T-all-prt AT ROW 9.63 COL 2.25
     T-parts-ser AT ROW 11.08 COL 35
     T-parts-not-blank AT ROW 12.21 COL 35
     T-parts-all AT ROW 13.33 COL 35
     RECT-bc AT ROW 2.75 COL 1.75
     RECT-pb AT ROW 2.79 COL 33.75
     "Отсылать собственные коды:" VIEW-AS TEXT
          SIZE 26.5 BY .71 AT ROW 3.13 COL 2.38
     "Отсылать ДОП.БК:" VIEW-AS TEXT
          SIZE 22.13 BY .71 AT ROW 3.17 COL 34.25
     RECT-part AT ROW 9.33 COL 33.75
     "Отсылать коды партий:" VIEW-AS TEXT
          SIZE 20.88 BY .71 AT ROW 9.92 COL 35.5
     SPACE(9.49) SKIP(5.36)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Настройка параметров отсылки товаров на кассу"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON B-quit.


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

ASSIGN
       B-default:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME






/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Настройка параметров отсылки товаров на кассу */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-default
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-default Dialog-Frame
ON CHOOSE OF B-default IN FRAME Dialog-Frame /* По умолчанию */
DO:
  FIND FIRST ub.sysconf NO-LOCK WHERE ub.sysconf.host-code = hostcode NO-ERROR.
  IF NOT AVAIL ub.sysconf then return no-apply.
   assign
   T-all-prt = ub.sysconf.all-prt
   T-bc-alt = ub.sysconf.cd-bc-alt
   T-bc-base = ub.sysconf.cd-bc-base
   T-loc-alt = ub.sysconf.cd-loc-alt
   T-loc-base = ub.sysconf.cd-loc-base
   T-parts-all = ub.sysconf.cd-parts-all
   T-parts-not-blank = ub.sysconf.cd-parts-not-blank
   T-parts-ser = ub.sysconf.cd-parts-ser
   T-pb-alt = ub.sysconf.cd-pb-alt
   T-pb-base = ub.sysconf.cd-pb-base
   T-sc-base = ub.sysconf.cd-sc-base.
   DISPLAY
   T-all-prt
   T-bc-alt T-bc-base T-loc-alt T-loc-base
   T-parts-all T-parts-not-blank T-parts-ser
   T-pb-alt T-pb-base T-sc-base
   WITH FRAME {&FRAME-NAME}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-exit Dialog-Frame
ON CHOOSE OF B-exit IN FRAME Dialog-Frame /* Ввод */
DO:
  assign
  T-all-prt
  T-bc-alt T-bc-base T-loc-alt T-loc-base
  T-parts-all T-parts-not-blank T-parts-ser
  T-pb-alt T-pb-base T-sc-base.
  assign
  all-prt = T-all-prt
  cd-bc-alt = T-bc-alt
  cd-bc-base = T-bc-base
  cd-loc-alt = T-loc-alt
  cd-loc-base = T-loc-base
  cd-parts-all = T-parts-all
  cd-parts-not-blank = T-parts-not-blank
  cd-parts-ser = T-parts-ser
  cd-pb-alt = T-pb-alt
  cd-pb-base = T-pb-base
  cd-sc-base = T-sc-base .

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
   assign
   T-all-prt = all-prt
   T-bc-alt = cd-bc-alt
   T-bc-base = cd-bc-base
   T-loc-alt = cd-loc-alt
   T-loc-base = cd-loc-base
   T-parts-all = cd-parts-all
   T-parts-not-blank = cd-parts-not-blank
   T-parts-ser = cd-parts-ser
   T-pb-alt = cd-pb-alt
   T-pb-base = cd-pb-base
   T-sc-base = cd-sc-base.



  RUN enable_UI.
  assign
  FRAME {&frame-name}:title = p-frame-title.
  IF ref-mode = {&lookup} then do:
    b-quit:label = "&Выход ".
    DISPLAY b-exit with FRAME {&FRAME-NAME}.
    DISABLE
    B-default B-exit
    T-all-prt
    T-bc-alt T-bc-base T-loc-alt T-loc-base
    T-parts-all T-parts-not-blank T-parts-ser
    T-pb-alt T-pb-base T-sc-base
    WITH FRAME {&FRAME-NAME}.
  end.
  if objcode = 0 then do:
      DISABLE
      B-default
      WITH FRAME {&FRAME-NAME}.
      HIDE
      B-default
      IN FRAME {&FRAME-NAME}.
  end.
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
  DISPLAY T-loc-base T-pb-base T-loc-alt T-pb-alt T-bc-base T-sc-base T-bc-alt
          T-all-prt T-parts-ser T-parts-not-blank T-parts-all
      WITH FRAME Dialog-Frame.
  ENABLE RECT-bc RECT-pb RECT-part B-exit B-quit B-default B-help T-loc-base
         T-pb-base T-loc-alt T-pb-alt T-bc-base T-sc-base T-bc-alt T-all-prt
         T-parts-ser T-parts-not-blank T-parts-all
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME