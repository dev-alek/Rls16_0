&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME pack-inf
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS pack-inf
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Информация по пакету

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/23/03
Author: Dmitry Ukhanov
Creation date: 03/23/03

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter p-action   as character no-undo .
define input parameter p-db-num   like ub.pck-sent.db-num   no-undo.
define input parameter p-pack-num like ub.pck-sent.pack-num no-undo.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Информация по пакету".
{ cmp/vssrevis.i }
{ cmp/showinf.i  }

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME pack-inf

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-help b-exit RECT-1 RECT-2 RECT-3
&Scoped-Define DISPLAYED-OBJECTS f_db-num f_pack-num f_CreDate f_CreTime ~
f_CreNum f_SendTxtDate f_SendTxtTime f_RcvdDate f_RcvdTime

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-exit AUTO-END-KEY DEFAULT
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE f_CreDate AS DATE FORMAT "99/99/9999"
     LABEL "Дата создания"
     VIEW-AS FILL-IN
     SIZE 11 BY 1.

DEFINE VARIABLE f_CreNum AS INTEGER FORMAT "->,>>>,>>9" INITIAL 0
     LABEL "Кол-во формирований"
     VIEW-AS FILL-IN
     SIZE 11 BY 1.

DEFINE VARIABLE f_CreTime AS CHARACTER FORMAT "X(8)"
     LABEL "Время создания"
     VIEW-AS FILL-IN
     SIZE 9 BY 1.

DEFINE VARIABLE f_db-num AS INTEGER FORMAT ">>>>9" INITIAL ?
     LABEL "Номер БД"
     VIEW-AS FILL-IN
     SIZE 6 BY 1.

DEFINE VARIABLE f_pack-num AS INTEGER FORMAT ">>>>>>>>>9" INITIAL ?
     LABEL "Номер пакета"
     VIEW-AS FILL-IN
     SIZE 11 BY 1.

DEFINE VARIABLE f_RcvdDate AS DATE FORMAT "99/99/9999"
     LABEL "Дата"
     VIEW-AS FILL-IN
     SIZE 11 BY 1.

DEFINE VARIABLE f_RcvdTime AS CHARACTER FORMAT "X(8)"
     LABEL "Время"
     VIEW-AS FILL-IN
     SIZE 9 BY 1.

DEFINE VARIABLE f_SendTxtDate AS DATE FORMAT "99/99/9999"
     LABEL "Дата последнего"
     VIEW-AS FILL-IN
     SIZE 11 BY 1.

DEFINE VARIABLE f_SendTxtTime AS CHARACTER FORMAT "X(8)"
     LABEL "Время последнего"
     VIEW-AS FILL-IN
     SIZE 9 BY 1.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 3 GRAPHIC-EDGE  NO-FILL
     SIZE 35 BY 4.5.

DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 3 GRAPHIC-EDGE  NO-FILL
     SIZE 35 BY 4.54.

DEFINE RECTANGLE RECT-3
     EDGE-PIXELS 3 GRAPHIC-EDGE  NO-FILL
     SIZE 35 BY 3.5.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME pack-inf
     b-help AT ROW 1.17 COL 27
     b-exit AT ROW 1.25 COL 1.75
     f_db-num AT ROW 2.67 COL 21.5 COLON-ALIGNED
     f_pack-num AT ROW 3.67 COL 21.5 COLON-ALIGNED
     f_CreDate AT ROW 4.67 COL 21.5 COLON-ALIGNED
     f_CreTime AT ROW 5.67 COL 21.5 COLON-ALIGNED
     f_CreNum AT ROW 8.17 COL 21.5 COLON-ALIGNED
     f_SendTxtDate AT ROW 9.17 COL 21.5 COLON-ALIGNED
     f_SendTxtTime AT ROW 10.17 COL 21.5 COLON-ALIGNED
     f_RcvdDate AT ROW 12.67 COL 21.5 COLON-ALIGNED
     f_RcvdTime AT ROW 13.67 COL 21.5 COLON-ALIGNED
     "Создание файла пакета" VIEW-AS TEXT
          SIZE 22.75 BY .71 AT ROW 7.17 COL 3
     "Получение подтверждения" VIEW-AS TEXT
          SIZE 25.13 BY .79 AT ROW 11.67 COL 3
     RECT-1 AT ROW 2.38 COL 1.88
     RECT-2 AT ROW 6.88 COL 1.88
     RECT-3 AT ROW 11.42 COL 1.88
     SPACE(0.49) SKIP(0.28)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Дополнительная информация о пакете"
         DEFAULT-BUTTON b-exit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX pack-inf
   FRAME-NAME                                                           */
ASSIGN
       FRAME pack-inf:SCROLLABLE       = FALSE
       FRAME pack-inf:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN f_CreDate IN FRAME pack-inf
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN f_CreNum IN FRAME pack-inf
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN f_CreTime IN FRAME pack-inf
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN f_db-num IN FRAME pack-inf
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN f_pack-num IN FRAME pack-inf
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN f_RcvdDate IN FRAME pack-inf
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN f_RcvdTime IN FRAME pack-inf
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN f_SendTxtDate IN FRAME pack-inf
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN f_SendTxtTime IN FRAME pack-inf
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX pack-inf
/* Query rebuild information for DIALOG-BOX pack-inf
     _Options          = "SHARE-LOCK KEEP-EMPTY"
     _Query            is NOT OPENED
*/  /* DIALOG-BOX pack-inf */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME pack-inf
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL pack-inf pack-inf
ON WINDOW-CLOSE OF FRAME pack-inf /* Дополнительная информация о пакете */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK pack-inf


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

    define buffer buf_pck-sent for ub.pck-sent .
    define buffer buf_pck-rcvd for ub.pck-rcvd .

    case p-action :
      when "send":U then do:
        find first buf_pck-sent no-lock
          where buf_pck-sent.db-num   = p-db-num
            and buf_pck-sent.pack-num = p-pack-num
          no-error
        .
        if not available buf_pck-sent then do:
          message
            vss-workfile vss-revision vss-description skip
            substitute( "Пакет N &1 для БД &2 не найден.", p-pack-num, p-db-num )
            view-as alert-box error
          .
          return error .
        end.
        assign
          f_db-num      = p-db-num
          f_pack-num    = p-pack-num
          f_CreDate     = buf_pck-sent.CreDate
          f_CreTime     = buf_pck-sent.CreTime
          f_CreNum      = buf_pck-sent.CreNum
          f_SendTxtDate = buf_pck-sent.SendTxtDate
          f_SendTxtTime = buf_pck-sent.SendTxtTime
          f_RcvdDate    = buf_pck-sent.RcvdDate
          f_RcvdTime    = buf_pck-sent.RcvdTime
        .
      end.
      when "rcvd":U then do:
        find first buf_pck-rcvd no-lock
          where buf_pck-rcvd.db-num   = p-db-num
            and buf_pck-rcvd.pack-num = p-pack-num
          no-error
        .
        if not available buf_pck-rcvd then do:
          message
            vss-workfile vss-revision vss-description skip
            substitute( "Пакет N &1 от БД &2 не найден.", p-pack-num, p-db-num )
            view-as alert-box error
          .
          return error .
        end.
        assign
          f_db-num      = p-db-num
          f_pack-num    = p-pack-num
          f_CreDate     = buf_pck-rcvd.CreDate
          f_CreTime     = buf_pck-rcvd.CreTime
          f_CreNum      = buf_pck-rcvd.CreNum
          f_SendTxtDate = buf_pck-rcvd.SendTxtDate
          f_SendTxtTime = buf_pck-rcvd.SendTxtTime
          f_RcvdDate    = buf_pck-rcvd.RcvdDate
          f_RcvdTime    = buf_pck-rcvd.RcvdTime
        .
      end.

    end case.
  RUN enable_UI.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI pack-inf  _DEFAULT-DISABLE
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
  HIDE FRAME pack-inf.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI pack-inf  _DEFAULT-ENABLE
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
  DISPLAY f_db-num f_pack-num f_CreDate f_CreTime f_CreNum f_SendTxtDate
          f_SendTxtTime f_RcvdDate f_RcvdTime
      WITH FRAME pack-inf.
  ENABLE b-help b-exit RECT-1 RECT-2 RECT-3
      WITH FRAME pack-inf.
  VIEW FRAME pack-inf.
  {&OPEN-BROWSERS-IN-QUERY-pack-inf}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
