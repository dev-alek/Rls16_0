&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI ADM1
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS sObject 
/*------------------------------------------------------------------------

  File:

  Description: from SMART.W - Template for basic ADM2 SmartObject

  Author:
  Created:

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress AppBuilder.      */
/*----------------------------------------------------------------------*/

/* Create an unnamed pool to store all the widgets created 
     by this procedure. This is a good default which assures
     that this procedure's triggers and internal procedures 
     will execute in this procedure's storage, and that proper
     cleanup will occur on deletion of the procedure. */
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Отчет ВСД

Автор: Рубан Дмитрий Андреевич
Дата создания: 31/05/2018
Author: Ruban Dmitriy
Creation date: 31/05/18

Ruban

*/
DEFINE VARIABLE vss-revision    AS CHARACTER NO-UNDO INIT "$Revision$":U .
DEFINE VARIABLE vss-author      AS CHARACTER NO-UNDO INIT "$Author$":U .
DEFINE VARIABLE vss-date        AS CHARACTER NO-UNDO INIT "$Date$":U .
DEFINE VARIABLE vss-workfile    AS CHARACTER NO-UNDO INIT "$Workfile$":U .
DEFINE VARIABLE vss-archive     AS CHARACTER NO-UNDO INIT "$Archive$":U .
DEFINE VARIABLE vss-description AS CHARACTER NO-UNDO INIT "Отчет по среднему чеку".
{ cmp/vssrevis.i  }
{ cmp/str-glbl.i  }
{ cmp/r-page1.i   } 
{ cmp/operlist.i  }
{ rep/rep-bt.i    }
{ gbl/twowin.i   }
{ gbl/usr-flt.i }
{ gbl/getcntxt.i get " " my-handle }
CREATE WIDGET-POOL.
{ gbl/key-rec.i   }

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE SmartObject
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME F-Main

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS vTime vReqVerif vFalVerif vToExtin ~
vFalExting vRep vSent 
&Scoped-Define DISPLAYED-OBJECTS vTime vReqVerif vFalVerif vToExtin ~
vFalExting vRep vSent vToRegi vFalRegis vRegis 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */
DEFINE VARIABLE vTime AS INTEGER FORMAT ">>>9":U INITIAL 0 
     LABEL "Время гашения" 
     VIEW-AS FILL-IN 
     SIZE 14 BY 1 NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 35 BY 10.48 TOOLTIP "Статус ВСД"
     FGCOLOR 0 .

DEFINE VARIABLE vSent AS LOGICAL INITIAL yes 
     LABEL "Отправлен" 
     VIEW-AS TOGGLE-BOX
     SIZE 22 BY .81 NO-UNDO.

DEFINE VARIABLE vFalExting AS LOGICAL INITIAL yes 
     LABEL "Ошибка гашения" 
     VIEW-AS TOGGLE-BOX
     SIZE 30 BY 1 NO-UNDO.

DEFINE VARIABLE vFalRegis AS LOGICAL INITIAL no 
     LABEL "Ошибка регистрации" 
     VIEW-AS TOGGLE-BOX
     SIZE 30 BY 1 NO-UNDO.

DEFINE VARIABLE vFalVerif AS LOGICAL INITIAL yes 
     LABEL "Ошибка проверки ВСД" 
     VIEW-AS TOGGLE-BOX
     SIZE 30 BY 1 NO-UNDO.

DEFINE VARIABLE vRegis AS LOGICAL INITIAL no 
     LABEL "Зарегистрирован" 
     VIEW-AS TOGGLE-BOX
     SIZE 30 BY 1 NO-UNDO.

DEFINE VARIABLE vRep AS LOGICAL INITIAL yes 
     LABEL "Погашен" 
     VIEW-AS TOGGLE-BOX
     SIZE 30 BY 1 NO-UNDO.

DEFINE VARIABLE vReqVerif AS LOGICAL INITIAL yes 
     LABEL "Требует проверки" 
     VIEW-AS TOGGLE-BOX
     SIZE 30 BY 1 NO-UNDO.

DEFINE VARIABLE vToExtin AS LOGICAL INITIAL yes 
     LABEL "К гашению" 
     VIEW-AS TOGGLE-BOX
     SIZE 30 BY 1 NO-UNDO.

DEFINE VARIABLE vToRegi AS LOGICAL INITIAL no 
     LABEL "К регистрации" 
     VIEW-AS TOGGLE-BOX
     SIZE 30 BY 1 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     vTime AT ROW 1.95 COL 22 COLON-ALIGNED WIDGET-ID 22
     vReqVerif AT ROW 4.29 COL 5.6 WIDGET-ID 2
     vFalVerif AT ROW 5.29 COL 5.6 WIDGET-ID 4
     vToExtin AT ROW 6.29 COL 5.6 WIDGET-ID 6
     vFalExting AT ROW 7.29 COL 5.6 WIDGET-ID 8
     vRep AT ROW 8.29 COL 5.6 WIDGET-ID 10
     vSent AT ROW 9.29 COL 5.6 WIDGET-ID 24
     vToRegi AT ROW 10.29 COL 5.6 WIDGET-ID 12
     vFalRegis AT ROW 11.29 COL 5.6 WIDGET-ID 14
     vRegis AT ROW 12.29 COL 5.6 WIDGET-ID 16
     "[ Статус ВСД ]" VIEW-AS TEXT
          SIZE 15 BY .62 AT ROW 3.38 COL 13 WIDGET-ID 20
     RECT-1 AT ROW 3.62 COL 4 WIDGET-ID 18
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1 SCROLLABLE  WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: SmartObject
   Allow: Basic
   Frames: 1
   Add Fields to: Neither
   Other Settings: PERSISTENT-ONLY COMPILE
 */

/* This procedure should always be RUN PERSISTENT.  Report the error,  */
/* then cleanup and return.                                            */
IF NOT THIS-PROCEDURE:PERSISTENT THEN DO:
  MESSAGE "{&FILE-NAME} should only be RUN PERSISTENT.":U
          VIEW-AS ALERT-BOX ERROR BUTTONS OK.
  RETURN.
END.

&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
/* DESIGN Window definition (used by the UIB) 
  CREATE WINDOW sObject ASSIGN
         HEIGHT             = 15.52
         WIDTH              = 41.2.
/* END WINDOW DEFINITION */
                                                                        */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _INCLUDED-LIB sObject 
/* ************************* Included-Libraries *********************** */

{ src/adm/method/viewer.i }

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW sObject
  VISIBLE,,RUN-PERSISTENT                                               */
/* SETTINGS FOR FRAME F-Main
   NOT-VISIBLE FRAME-NAME Size-to-Fit                                   */
ASSIGN 
       FRAME F-Main:SCROLLABLE       = FALSE
       FRAME F-Main:HIDDEN           = TRUE.

/* SETTINGS FOR RECTANGLE RECT-1 IN FRAME F-Main
   NO-ENABLE                                                            */
/* SETTINGS FOR TOGGLE-BOX vFalRegis IN FRAME F-Main
   NO-ENABLE                                                            */
ASSIGN 
       vFalRegis:HIDDEN IN FRAME F-Main           = TRUE.

/* SETTINGS FOR TOGGLE-BOX vRegis IN FRAME F-Main
   NO-ENABLE                                                            */
ASSIGN 
       vRegis:HIDDEN IN FRAME F-Main           = TRUE.

/* SETTINGS FOR TOGGLE-BOX vToRegi IN FRAME F-Main
   NO-ENABLE                                                            */
ASSIGN 
       vToRegi:HIDDEN IN FRAME F-Main           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK FRAME F-Main
/* Query rebuild information for FRAME F-Main
     _Options          = "NO-LOCK"
     _Query            is NOT OPENED
*/  /* FRAME F-Main */
&ANALYZE-RESUME

 


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK sObject 


/* ***************************  Main Block  *************************** */
/*{ gbl/personly.i }*/
/* If testing in the UIB, initialize the SmartObject. */  
&IF DEFINED(UIB_IS_RUNNING) <> 0 &THEN          
  RUN dispatch IN THIS-PROCEDURE ('initialize':U).
&ENDIF

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI sObject  _DEFAULT-DISABLE
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-initialize sObject 
PROCEDURE local-initialize :
/*------------------------------------------------------------------------------
      Purpose:     Override standard ADM method
      Notes:
    ------------------------------------------------------------------------------*/

    /* Code placed here will execute PRIOR to standard behavior. */

    /* Dispatch standard ADM method.                             */
    RUN dispatch IN THIS-PROCEDURE ( INPUT 'initialize':U ) .
    DO WITH FRAME F-Main:
        ASSIGN 
            vTime       :SCREEN-VALUE = "0"
            vReqVerif   :SCREEN-VALUE = "yes"
            vFalVerif   :SCREEN-VALUE = "yes"
            vToExtin    :SCREEN-VALUE = "yes"
            vFalExting  :SCREEN-VALUE = "yes"
            vRep        :SCREEN-VALUE = "yes"
            vSent       :SCREEN-VALUE = "yes"
            .
    END.

/* Code placed here will execute AFTER standard behavior.    */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-report sObject 
PROCEDURE my-report :
DO WITH FRAME F-Main:
   ASSIGN
      vTime 
      vReqVerif
      vFalVerif
      vToExtin
      vFalExting
      vRep
      vSent
   .
   END.
   DEFINE VARIABLE vStatus AS CHARACTER NO-UNDO.
    IF vReqVerif THEN 
        vStatus = vStatus + ",0".
    IF vFalVerif THEN 
        vStatus = vStatus + ",1".
    IF vToExtin THEN 
        vStatus = vStatus + ",2".
    IF vFalExting THEN 
        vStatus = vStatus + ",3".
    IF vRep THEN 
        vStatus = vStatus + ",4".
    IF vSent THEN 
        vStatus = vStatus + ",5".
    vStatus =SUBSTRING(vStatus,2).    
                  
   RUN rep/r-statusvsd.p( my-handle,vTime,vStatus).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE My-var sObject 
PROCEDURE My-var :
ASSIGN
    ReportHeader = "Отчет для получения информации по статусу ВСД".
    
    
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

