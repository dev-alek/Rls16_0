&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI ADM1
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS s-object
/*
$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Отчет по заказам ОРЦ на РЦ

Автор: Чернова Светлана Александровна
Дата создания: 04/20/06
Author: Svetlana Chernova
Creation date: 04/20/06

*/

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "ОТЧЕТ ПО ЗАКАЗАМ ОРЦ на РЦ".

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/r-page1.i  }
{ rep/rep-bt.i   }

define variable p-mode as character no-undo .

CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

define variable State-source as  WIDGET-HANDLE.



if reportname begins "2." then
    assign
      p-mode = "RC":U
      reportname = "ОТЧЕТ ПО ЗАКАЗАМ ОРЦ на РЦ"
    .
  else assign
    p-mode = ""
    reportname = "ОТЧЕТ ПО ЗАКАЗАМ ОРЦ на объекте"
  .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE SmartObject
&Scoped-define DB-AWARE no

&Scoped-define ADM-SUPPORTED-LINKS Record-Source,Record-Target,TableIO-Target

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME F-Main

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS RECT-5 RECT-7 T-new OrdDate T-req T-per ~
T-ship T-fact
&Scoped-Define DISPLAYED-OBJECTS T-new OrdDate T-req T-per T-ship T-fact

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */
DEFINE VARIABLE OrdDate AS CHARACTER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "дате создания заказа", "doc-date":U,
"дате поставки", "ship-date":U
     SIZE 26 BY 2.52 NO-UNDO.

DEFINE RECTANGLE RECT-5
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 15.8 BY 6.81.

DEFINE RECTANGLE RECT-7
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 30 BY 6.67.

DEFINE VARIABLE T-fact AS LOGICAL INITIAL yes
     LABEL "Факт"
     VIEW-AS TOGGLE-BOX
     SIZE 11.6 BY .81 NO-UNDO.

DEFINE VARIABLE T-new AS LOGICAL INITIAL yes
     LABEL "Новый"
     VIEW-AS TOGGLE-BOX
     SIZE 8.6 BY .81 NO-UNDO.

DEFINE VARIABLE T-per AS LOGICAL INITIAL yes
     LABEL "Разрешено"
     VIEW-AS TOGGLE-BOX
     SIZE 14 BY .81 NO-UNDO.

DEFINE VARIABLE T-req AS LOGICAL INITIAL yes
     LABEL "Запрос"
     VIEW-AS TOGGLE-BOX
     SIZE 8.6 BY .81 NO-UNDO.

DEFINE VARIABLE T-ship AS LOGICAL INITIAL yes
     LABEL "Отгружено"
     VIEW-AS TOGGLE-BOX
     SIZE 14 BY .81 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     T-new AT ROW 2.95 COL 2.6
     OrdDate AT ROW 3.24 COL 19.2 NO-LABEL WIDGET-ID 10
     T-req AT ROW 3.71 COL 2.6
     T-per AT ROW 4.52 COL 2.6
     T-ship AT ROW 5.24 COL 2.6
     T-fact AT ROW 6.1 COL 2.6
     "Формировать отчет по :" VIEW-AS TEXT
          SIZE 31 BY .67 AT ROW 1.95 COL 19 WIDGET-ID 16
          FGCOLOR 4
     "Статус" VIEW-AS TEXT
          SIZE 7 BY .67 AT ROW 2 COL 3
          FGCOLOR 4
     RECT-5 AT ROW 1.19 COL 1.8
     RECT-7 AT ROW 1.24 COL 18 WIDGET-ID 14
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY
         SIDE-LABELS NO-UNDERLINE THREE-D
         AT COL 1 ROW 1 SCROLLABLE .


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: SmartObject
   Allow: Basic,DB-Fields
   Frames: 1
   Add Fields to: External-Tables
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
/* DESIGN Window definition (used by the UIB)
  CREATE WINDOW s-object ASSIGN
         HEIGHT             = 7.19
         WIDTH              = 70.8.
/* END WINDOW DEFINITION */
                                                                        */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _INCLUDED-LIB s-object
/* ************************* Included-Libraries *********************** */

{src/adm/method/viewer.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW s-object
  VISIBLE,,RUN-PERSISTENT                                               */
/* SETTINGS FOR FRAME F-Main
   NOT-VISIBLE Size-to-Fit                                              */
ASSIGN
       FRAME F-Main:SCROLLABLE       = FALSE
       FRAME F-Main:HIDDEN           = TRUE
       FRAME F-Main:PRIVATE-DATA     =
                "DLGCLOSE".

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK FRAME F-Main
/* Query rebuild information for FRAME F-Main
     _Options          = "NO-LOCK"
     _Query            is NOT OPENED
*/  /* FRAME F-Main */
&ANALYZE-RESUME




&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK s-object


/* ***************************  Main Block  *************************** */
{ gbl/personly.i }

/* If testing in the UIB, initialize the SmartObject. */

&IF DEFINED(UIB_IS_RUNNING) <> 0 &THEN
  RUN dispatch IN THIS-PROCEDURE ('initialize':U).
&ENDIF

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI s-object  _DEFAULT-DISABLE
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
  HIDE FRAME F-Main.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-initialize s-object
PROCEDURE local-initialize :
/*------------------------------------------------------------------------------
  Purpose:     Override standard ADM method
  Notes:
------------------------------------------------------------------------------*/

  /* Code placed here will execute PRIOR to standard behavior. */

  /* Dispatch standard ADM method.                             */
  RUN dispatch IN THIS-PROCEDURE ( INPUT 'initialize':U ) .

  /* Code placed here will execute AFTER standard behavior.    */
   T-fact:screen-value in frame {&frame-name} = 'yes'.
   T-new:screen-value in frame {&frame-name} = 'yes'.
   T-per:screen-value in frame {&frame-name} = 'yes'.
   T-req:screen-value in frame {&frame-name} = 'yes'.
   T-ship:screen-value in frame {&frame-name} = 'yes'.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-report s-object
PROCEDURE my-report :
/*------------------------------------------------------------------------------
  Purpose:     здесь происходит вызов  процедуры отчета с любыми параметрами
------------------------------------------------------------------------------*/

run cus/r-ordrc2.p
 ( input t-fact,
   input t-new ,
   input t-per,
   input t-req,
   input t-ship ,
   input p-mode,
   input OrdDate ) .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-var s-object
PROCEDURE my-var :
/*------------------------------------------------------------------------------
  Purpose:     здесь происходит вызов  значений переменных
  например  Название отчета, может быть еще пример шапки ???
------------------------------------------------------------------------------*/
define variable t-OrdDate as character no-undo .

assign frame {&frame-name} T-fact T-new T-per T-req T-ship OrdDate.


if X-SelectGood =  1 then do:
   empty TEMP-TABLE gds-list.
end.

case OrdDate :
 when "doc-date" then t-OrdDate = "дате создания заказа" .
 when "ship-date" then t-OrdDate = "дате поставки" .
end case.


ReportHeader = "Статусы: " .


 if T-new:screen-value  in frame {&frame-name} = 'yes' then ReportHeader =  ReportHeader  + T-new:label + {&new-line} .
 if T-req:screen-value  in frame {&frame-name} = 'yes'  then ReportHeader =  ReportHeader + T-req:label + {&new-line} .
 if T-per:screen-value  in frame {&frame-name} = 'yes'  then ReportHeader =  ReportHeader + T-per:label + {&new-line} .
 if T-ship:screen-value in frame {&frame-name} = 'yes'  then ReportHeader =  ReportHeader + T-ship:label + {&new-line} .
 if T-fact:screen-value in frame {&frame-name} = 'yes'  then ReportHeader =  ReportHeader + T-fact:label + {&new-line} .

ReportHeader = ReportHeader + {&new-line} + "Формировать отчет по " + t-OrdDate .


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE state-changed s-object
PROCEDURE state-changed :
/* -----------------------------------------------------------
  Purpose:     Receive and process 'state-changed' methods
               (issued by 'new-state' event).
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  DEFINE INPUT PARAMETER p-issuer-hdl AS HANDLE    NO-UNDO.
  DEFINE INPUT PARAMETER p-state      AS CHARACTER NO-UNDO.

  CASE p-state:
      /* Object instance CASEs can go here to replace standard behavior
         or add new cases. */
      /* link-changed */
  END CASE.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME