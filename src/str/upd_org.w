&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER utd FOR utd.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
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
define input parameter parparentproc as widget-handle no-undo .
define input parameter iDiadocConnection as component-handle no-undo.
define input parameter i-db-num as integer   no-undo .
define input parameter i-doc-id as integer no-undo .
define input parameter i-mode as character no-undo .

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Форма данных для возврата".
{ cmp/vssrevis.i }
{ cmp/showinf.i }
{ str/utd-attr.i }
{ cmp/str-glbl.i }
{ gbl/objsrv.i }
define variable mPublishHand as handle no-undo.
define variable mDiadocApi as component-handle no-undo.
define stream File-stream.
define variable mdebug as logical no-undo.
mdebug= session:debug-alert.
{ str/edo-log.i }
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES utd

/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define QUERY-STRING-Dialog-Frame FOR EACH utd SHARE-LOCK
&Scoped-define OPEN-QUERY-Dialog-Frame OPEN QUERY Dialog-Frame FOR EACH utd where utd.db-num eq i-db-num and utd.doc-id eq i-doc-id  SHARE-LOCK.
&Scoped-define TABLES-IN-QUERY-Dialog-Frame utd
&Scoped-define FIRST-TABLE-IN-QUERY-Dialog-Frame utd


/* Definitions for FRAME FRAME-ORG                                      */
&Scoped-define QUERY-STRING-FRAME-ORG FOR EACH utd SHARE-LOCK
&Scoped-define OPEN-QUERY-FRAME-ORG OPEN QUERY FRAME-ORG FOR EACH utd where utd.db-num eq i-db-num and utd.doc-id eq i-doc-id SHARE-LOCK.
&Scoped-define TABLES-IN-QUERY-FRAME-ORG utd
&Scoped-define FIRST-TABLE-IN-QUERY-FRAME-ORG utd


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS Btn_OK Btn_Cancel 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON Btn_Cancel AUTO-END-KEY 
     LABEL "&Отмена" 
     SIZE 15 BY 1.14
     BGCOLOR 8 .

DEFINE BUTTON btn_GetOrgFNs 
     LABEL "Обновить" 
     SIZE 15 BY 1.14.

DEFINE BUTTON Btn_OK AUTO-GO 
     LABEL "&Ввод" 
     SIZE 15 BY 1.14
     BGCOLOR 8 .

DEFINE BUTTON Btn_guid_cont 
     IMAGE-UP FILE "cmp/btn-fnd.bmp":U
     IMAGE-DOWN FILE "cmp/btn-fnd.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/btn-fnd.bmp":U
     LABEL "" 
     SIZE 5 BY 1.

DEFINE BUTTON Btn_guid_org 
     IMAGE-UP FILE "cmp/btn-fnd.bmp":U
     IMAGE-DOWN FILE "cmp/btn-fnd.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/btn-fnd.bmp":U
     LABEL "" 
     SIZE 5 BY 1.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY Dialog-Frame FOR 
      utd SCROLLING.

DEFINE QUERY FRAME-ORG FOR 
      utd SCROLLING.
&ANALYZE-RESUME

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     Btn_OK AT ROW 1.24 COL 3
     Btn_Cancel AT ROW 1.24 COL 19
     btn_GetOrgFNs AT ROW 1.24 COL 35 WIDGET-ID 2
     SPACE(85.79) SKIP(12.71)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Данные организаций"
         DEFAULT-BUTTON Btn_OK CANCEL-BUTTON Btn_Cancel WIDGET-ID 100.

DEFINE FRAME FRAME-ORG
     utd.OrganizationExt AT ROW 2.19 COL 32 COLON-ALIGNED WIDGET-ID 2
          LABEL "GUID" FORMAT "x(255)"
          VIEW-AS FILL-IN 
          SIZE 90 BY 1
     Btn_guid_org AT ROW 2.19 COL 125 WIDGET-ID 6
     utd.obj-FnsParticipantId AT ROW 3.86 COL 32 COLON-ALIGNED WIDGET-ID 4
          LABEL "Ид. орг.-уч. документооборота" FORMAT "x(255)"
          VIEW-AS FILL-IN 
          SIZE 90 BY 1
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 3 ROW 3.62
         SIZE 130 BY 5.71
         TITLE "Наша организация" WIDGET-ID 200.

DEFINE FRAME FRAME-Conrt
     utd.CounteragentId AT ROW 1.24 COL 32 COLON-ALIGNED WIDGET-ID 2
          LABEL "GUID" FORMAT "x(255)"
          VIEW-AS FILL-IN 
          SIZE 90 BY 1
     btn_guid_cont AT ROW 1.24 COL 125 WIDGET-ID 6
     utd.cli-FnsParticipantId AT ROW 2.91 COL 32 COLON-ALIGNED WIDGET-ID 4
          LABEL "Ид. орг.-уч. документооборота" FORMAT "x(255)"
          VIEW-AS FILL-IN 
          SIZE 90 BY 1
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 3 ROW 9.81
         SIZE 130 BY 4.52
         TITLE "Контрагент" WIDGET-ID 300.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   Allow: Basic,Browse,DB-Fields,Query
   Other Settings: COMPILE
   Temp-Tables and Buffers:
      TABLE: utd B "?" ? ub utd
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* REPARENT FRAME */
ASSIGN FRAME FRAME-Conrt:FRAME = FRAME Dialog-Frame:HANDLE
       FRAME FRAME-ORG:FRAME = FRAME Dialog-Frame:HANDLE.

/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */

DEFINE VARIABLE XXTABVALXX AS LOGICAL NO-UNDO.

ASSIGN XXTABVALXX = FRAME FRAME-ORG:MOVE-AFTER-TAB-ITEM (btn_GetOrgFNs:HANDLE IN FRAME Dialog-Frame)
       XXTABVALXX = FRAME FRAME-ORG:MOVE-BEFORE-TAB-ITEM (FRAME FRAME-Conrt:HANDLE)
/* END-ASSIGN-TABS */.

ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR BUTTON btn_GetOrgFNs IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR BUTTON btn_ok IN FRAME Dialog-Frame
   NO-ENABLE                                                            */

/* SETTINGS FOR FRAME FRAME-Conrt
                                                                        */
/* SETTINGS FOR FILL-IN utd.cli-FnsParticipantId IN FRAME FRAME-Conrt
   NO-ENABLE EXP-LABEL EXP-FORMAT                                       */
/* SETTINGS FOR FILL-IN utd.CounteragentId IN FRAME FRAME-Conrt
   NO-ENABLE EXP-LABEL EXP-FORMAT                                       */
/* SETTINGS FOR FRAME FRAME-ORG
                                                                        */
/* SETTINGS FOR FILL-IN utd.obj-FnsParticipantId IN FRAME FRAME-ORG
   NO-ENABLE EXP-LABEL EXP-FORMAT                                       */
/* SETTINGS FOR FILL-IN utd.OrganizationExt IN FRAME FRAME-ORG
   NO-ENABLE EXP-LABEL EXP-FORMAT                                       */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _TblList          = "Temp-Tables.utd"
     _Options          = "SHARE-LOCK"
     _Query            is OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK FRAME FRAME-ORG
/* Query rebuild information for FRAME FRAME-ORG
     _TblList          = "Temp-Tables.utd"
     _Query            is OPENED
*/  /* FRAME FRAME-ORG */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Данные организаций */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME FRAME-ORG
&Scoped-define SELF-NAME Btn_guid_org
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_guid_org Dialog-Frame
ON CHOOSE OF Btn_guid_org IN FRAME FRAME-ORG
DO:
  run getguidorg no-error.
  if error-status:error
  then do:
     message return-value
     view-as alert-box.
     return no-apply.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define SELF-NAME btn_GetOrgFNs
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btn_GetOrgFNs Dialog-Frame
ON CHOOSE OF btn_GetOrgFNs IN FRAME Dialog-Frame /* Обновить */
DO:
  run GetFNS (utd.OrganizationExt:screen-value in frame FRAME-ORG,
              utd.CounterAgentID:screen-value in frame FRAME-Conrt) no-error.
  if error-status:error
  then do:
     message return-value
     view-as alert-box.
     return no-apply.
  end.
  Btn_OK:sensitive in FRAME Dialog-Frame = yes.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME FRAME-Conrt
&Scoped-define SELF-NAME btn_guid_cont
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btn_guid_cont Dialog-Frame
ON CHOOSE OF btn_guid_cont IN FRAME FRAME-Conrt
DO:
  run getguidcontr no-error.
  if error-status:error
  then do:
     message return-value
     view-as alert-box.
     return no-apply.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define SELF-NAME Btn_OK
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_OK Dialog-Frame
ON CHOOSE OF Btn_OK IN FRAME Dialog-Frame /* Ввод */
DO:
   do with FRAME FRAME-ORG:
   assign
   utd.OrganizationExt
   utd.obj-FnsParticipantId    
   .
   end. 
   do with FRAME FRAME-Conrt:
   assign   
   utd.cli-FnsParticipantId 
   utd.CounteragentId 
   .
   end.
  run save_proc.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME FRAME-Conrt
&Scoped-define SELF-NAME utd.CounteragentId
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL utd.CounteragentId Dialog-Frame
ON VALUE-CHANGED OF utd.CounteragentId IN FRAME FRAME-Conrt /* CounteragentId */
DO:
  Btn_OK:sensitive in FRAME Dialog-Frame = no.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME FRAME-ORG
&Scoped-define SELF-NAME utd.OrganizationExt
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL utd.OrganizationExt Dialog-Frame
ON VALUE-CHANGED OF utd.OrganizationExt IN FRAME FRAME-ORG /* GUID */
DO:
  Btn_OK:sensitive in FRAME Dialog-Frame = no.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME Dialog-Frame
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame 


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  find first utd where utd.db-num eq i-db-num
                   and utd.doc-id eq i-doc-id
  no-lock no-error.
  if not avail utd
  then  do:
      message "Документ не найден." 
      view-as alert-box.
      return.
  end.
  run Init_proc.
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
  HIDE FRAME FRAME-Conrt.
  HIDE FRAME FRAME-ORG.
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

  {&OPEN-QUERY-Dialog-Frame}
  GET FIRST Dialog-Frame.
  ENABLE Btn_Cancel
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}

  {&OPEN-QUERY-FRAME-ORG}
  GET FIRST FRAME-ORG.
  IF AVAILABLE utd THEN 
    DISPLAY utd.OrganizationExt utd.obj-FnsParticipantId 
      WITH FRAME FRAME-ORG.
  {&OPEN-BROWSERS-IN-QUERY-FRAME-ORG}
  IF AVAILABLE utd THEN 
    DISPLAY utd.CounteragentId utd.cli-FnsParticipantId 
      WITH FRAME FRAME-Conrt.
  {&OPEN-BROWSERS-IN-QUERY-FRAME-Conrt}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE GetFNS Dialog-Frame 
PROCEDURE GetFNS :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define input  parameter iORGGuid  as character no-undo.
    define input  parameter iContGuid as character no-undo.
    define variable vOrganization as component-handle no-undo.
    define variable vCounteragent as component-handle no-undo.
    vOrganization = iDiadocConnection:GetOrganizationById(iORGGuid) no-error.
    if vOrganization eq ?
    then do:
       return error "Нет доступа к организации".
    end.
    utd.OrganizationExt:screen-value in frame FRAME-ORG = vOrganization:guid.
    utd.obj-FnsParticipantId:screen-value in frame FRAME-ORG = vOrganization:FnsParticipantId. 
    vCounteragent = vOrganization:GetCounteragentById(iContGuid).
    release object vOrganization.
    
    if vCounteragent eq ?
    then do:
       return error "Не найден контрагент".
    end.
    utd.CounterAgentId      :screen-value in frame frame-conrt = vCounteragent:Guid.
    utd.cli-FnsParticipantId:screen-value in frame frame-conrt = vCounteragent:FnsParticipantId.
    release object vCounteragent.
    
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getGuidOrg Dialog-Frame 
PROCEDURE getGuidOrg :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
/*  define variable vCliType as character no-undo.*/
/*  define variable vCliCode as integer   no-undo.*/
  define variable vFNS     as character no-undo.
  define variable vguid as character no-undo.
    
  do
  on error undo, return error return-value
  :
    run str/upd_org_brow.w (iDiadocConnection:GetOrganizationList(),
                            output vguid,
                            output vFNS).
    if vguid ne "" then
    do:
       utd.OrganizationExt:screen-value in frame FRAME-ORG = vguid.
       utd.obj-FnsParticipantId:screen-value in frame FRAME-ORG = vfns.
       Btn_OK:sensitive in FRAME Dialog-Frame = no.
    end.
    else do:
       Btn_OK:sensitive in FRAME Dialog-Frame = no.
    end.
    
  end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getGuidContr Dialog-Frame 
PROCEDURE getGuidContr :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
  define variable vFNS     as character no-undo.
  do
  on error undo, return error return-value
  :
    
    define variable vGuid as character no-undo.
    define variable vOrganization as component-handle no-undo.
    vOrganization = iDiadocConnection:GetOrganizationById(utd.OrganizationExt:screen-value in frame frame-org) no-error.
    if vOrganization eq ?
    then do:
       
       puterr( "ERROR Для выбора контр агента нужно правильно заполнить свою организацию.").
       return.
    end.
    
    define variable vOrganizationContr as component-handle no-undo.
    vOrganizationContr = vOrganization:GetCounteragentListByStatus("IsMyCounteragent") no-error.
    if vOrganizationContr eq ?
    then do:
       release object vOrganization.
       puterr( "ERROR Не удается получить список котр агентов ").
       return.
    end.
    run str/upd_org_brow.w (vOrganizationContr,
                            output vguid,
                            output vfns).
    release object vOrganizationContr no-error.
    release object vOrganization no-error.
       
    if vGuid ne "" then
    do:
       utd.CounteragentId:screen-value in frame frame-conrt = vguid.
       utd.cli-FnsParticipantId:screen-value in frame frame-conrt = vfns.
       Btn_OK:sensitive in FRAME Dialog-Frame = yes.
    end.
    else do:
       Btn_OK:sensitive in FRAME Dialog-Frame = no.
    end.
/*    run waitfram-hide.*/
    
  end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Init_proc Dialog-Frame 
PROCEDURE Init_proc :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
   if     i-mode            eq {&update}
      and iDiadocConnection ne ?
   then do:
      btn_GetOrgFNs       :visible   in frame Dialog-Frame  = yes.
      btn_GetOrgFNs       :sensitive in frame Dialog-Frame  = yes.
      utd.CounterAgentId  :sensitive in FRAME FRAME-Conrt   = yes.
      utd.OrganizationExt :sensitive in FRAME FRAME-ORG     = yes.
      Btn_guid_cont       :visible   in frame FRAME-Conrt   = yes.
      Btn_guid_org        :visible   in frame FRAME-ORG     = yes.
      Btn_guid_cont       :sensitive in frame FRAME-Conrt   = yes.
      Btn_guid_org        :sensitive in frame FRAME-ORG     = yes.
      
     
   end.
   else do:
      btn_GetOrgFNs       :visible   in frame Dialog-Frame  = no.
      Btn_guid_cont       :visible   in frame FRAME-Conrt   = no.
      Btn_guid_org        :visible   in frame FRAME-ORG     = no.
   end.    
/*   btn_ok :sensitive in frame Dialog-Frame     = yes.             */
/*   utd.CounterAgentId  :sensitive in FRAME FRAME-Conrt   = yes.   */
/*      utd.OrganizationExt :sensitive in FRAME FRAME-ORG     = yes.*/
      
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE seve_proc Dialog-Frame 
PROCEDURE save_proc :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
  
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

