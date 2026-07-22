&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI ADM1
&ANALYZE-RESUME
/* Connected Databases 
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS V-table-Win 
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Просмотр шапки документа

Автор: Суслов Алексей Юрьевич
Дата создания: 03/27/06
Author: Alexey Suslov
Creation date: 03/27/06

*/

/* Create an unnamed pool to store all the widgets created
     by this procedure. This is a good default which assures
     that this procedure's triggers and internal procedures
     will execute in this procedure's storage, and that proper
     cleanup will occur on deletion of the procedure. */

CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Просмотр шапки документа".
{ cmp/vssrevis.i }
{ cmp/showinf.i }

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE SmartObject
&Scoped-define DB-AWARE no

&Scoped-define ADM-SUPPORTED-LINKS Record-Source,Record-Target,TableIO-Target

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME F-Main

/* External Tables                                                      */
&Scoped-define EXTERNAL-TABLES ub.trn-doc
&Scoped-define FIRST-EXTERNAL-TABLE ub.trn-doc


/* Need to scope the external tables to this procedure                  */
DEFINE QUERY external_tables FOR ub.trn-doc.
/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS ub.trn-doc.tot-rubl ub.trn-doc.tot-other ~
ub.trn-doc.fact-qnty ub.trn-doc.tot-sale ub.trn-doc.fact-base ~
ub.trn-doc.doc-qnty ub.trn-doc.tot-transp ub.trn-doc.fact-rubl ~
ub.trn-doc.discnt-type ub.trn-doc.exch-code ub.trn-doc.VAT-base ~
ub.trn-doc.print-rubl ub.trn-doc.exch-date ub.trn-doc.VAT-rubl ~
ub.trn-doc.shift-date ub.trn-doc.exch-rate ub.trn-doc.VAT-type ~
ub.trn-doc.shift-num ub.trn-doc.exch-scale ub.trn-doc.SLT-base ~
ub.trn-doc.ship-date ub.trn-doc.pay-code ub.trn-doc.SLT-rubl ~
ub.trn-doc.tot-ov ub.trn-doc.tot-calc ub.trn-doc.SLT-type ~
ub.trn-doc.base-rate ub.trn-doc.road-tax ub.trn-doc.tot-cli ~
ub.trn-doc.base-scale ub.trn-doc.excise ub.trn-doc.tot-doc ~
ub.trn-doc.discnt-pc ub.trn-doc.tot-fact ub.trn-doc.discnt-rubl 
&Scoped-define ENABLED-TABLES ub.trn-doc
&Scoped-define FIRST-ENABLED-TABLE ub.trn-doc
&Scoped-Define DISPLAYED-FIELDS ub.trn-doc.tot-rubl ub.trn-doc.tot-other ~
ub.trn-doc.fact-qnty ub.trn-doc.tot-sale ub.trn-doc.fact-base ~
ub.trn-doc.doc-qnty ub.trn-doc.tot-transp ub.trn-doc.fact-rubl ~
ub.trn-doc.discnt-type ub.trn-doc.exch-code ub.trn-doc.VAT-base ~
ub.trn-doc.print-rubl ub.trn-doc.exch-date ub.trn-doc.VAT-rubl ~
ub.trn-doc.shift-date ub.trn-doc.exch-rate ub.trn-doc.VAT-type ~
ub.trn-doc.shift-num ub.trn-doc.exch-scale ub.trn-doc.SLT-base ~
ub.trn-doc.ship-date ub.trn-doc.pay-code ub.trn-doc.SLT-rubl ~
ub.trn-doc.tot-ov ub.trn-doc.tot-calc ub.trn-doc.SLT-type ~
ub.trn-doc.base-rate ub.trn-doc.road-tax ub.trn-doc.tot-cli ~
ub.trn-doc.base-scale ub.trn-doc.excise ub.trn-doc.tot-doc ~
ub.trn-doc.discnt-pc ub.trn-doc.tot-fact ub.trn-doc.discnt-rubl 
&Scoped-define DISPLAYED-TABLES ub.trn-doc
&Scoped-define FIRST-DISPLAYED-TABLE ub.trn-doc


/* Custom List Definitions                                              */
/* ADM-CREATE-FIELDS,ADM-ASSIGN-FIELDS,List-3,List-4,List-5,List-6      */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _XFTR "Foreign Keys" V-table-Win _INLINE
/* Actions: ? adm/support/keyedit.w ? ? ? */
/* STRUCTURED-DATA
<KEY-OBJECT>
THIS-PROCEDURE
</KEY-OBJECT>
<FOREIGN-KEYS>
</FOREIGN-KEYS>
<EXECUTING-CODE>
**************************
* Set attributes related to FOREIGN KEYS
*/
RUN set-attribute-list (
    'Keys-Accepted = "",
     Keys-Supplied = ""':U).
/**************************
</EXECUTING-CODE> */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     ub.trn-doc.tot-rubl AT ROW 1.17 COL 72.5 COLON-ALIGNED
          LABEL "tot-rubl"
          VIEW-AS FILL-IN 
          SIZE 22 BY 1
     ub.trn-doc.tot-other AT ROW 1.2 COL 38 COLON-ALIGNED
          LABEL "tot-other"
          VIEW-AS FILL-IN 
          SIZE 16 BY 1
     ub.trn-doc.fact-qnty AT ROW 1.3 COL 12 COLON-ALIGNED
          LABEL "fact-qnty"
          VIEW-AS FILL-IN 
          SIZE 13 BY 1
     ub.trn-doc.tot-sale AT ROW 2.3 COL 72.5 COLON-ALIGNED
          LABEL "tot-sale"
          VIEW-AS FILL-IN 
          SIZE 16 BY 1
     ub.trn-doc.fact-base AT ROW 2.37 COL 38 COLON-ALIGNED
          LABEL "fact-base"
          VIEW-AS FILL-IN 
          SIZE 16 BY 1
     ub.trn-doc.doc-qnty AT ROW 2.5 COL 12 COLON-ALIGNED
          LABEL "doc-qnty"
          VIEW-AS FILL-IN 
          SIZE 13 BY 1
     ub.trn-doc.tot-transp AT ROW 3.5 COL 72.5 COLON-ALIGNED
          LABEL "tot-transp"
          VIEW-AS FILL-IN 
          SIZE 16 BY 1
     ub.trn-doc.fact-rubl AT ROW 3.53 COL 38 COLON-ALIGNED
          LABEL "fact-rubl"
          VIEW-AS FILL-IN 
          SIZE 22 BY 1
     ub.trn-doc.discnt-type AT ROW 3.67 COL 12 COLON-ALIGNED
          LABEL "discnt-type"
          VIEW-AS FILL-IN 
          SIZE 9 BY 1
     ub.trn-doc.exch-code AT ROW 4.57 COL 38 COLON-ALIGNED
          LABEL "exch-code"
          VIEW-AS FILL-IN 
          SIZE 4 BY 1
     ub.trn-doc.VAT-base AT ROW 4.67 COL 72.5 COLON-ALIGNED
          LABEL "VAT-base"
          VIEW-AS FILL-IN 
          SIZE 16 BY 1
     ub.trn-doc.print-rubl AT ROW 4.7 COL 12 COLON-ALIGNED
          LABEL "print-rubl"
          VIEW-AS FILL-IN 
          SIZE 4 BY 1
     ub.trn-doc.exch-date AT ROW 5.7 COL 38 COLON-ALIGNED
          LABEL "exch-date"
          VIEW-AS FILL-IN 
          SIZE 9 BY 1
     ub.trn-doc.VAT-rubl AT ROW 5.77 COL 72.5 COLON-ALIGNED
          LABEL "VAT-rubl"
          VIEW-AS FILL-IN 
          SIZE 22 BY 1
     ub.trn-doc.shift-date AT ROW 5.97 COL 12 COLON-ALIGNED
          LABEL "shift-date"
          VIEW-AS FILL-IN 
          SIZE 9 BY 1
     ub.trn-doc.exch-rate AT ROW 6.8 COL 38 COLON-ALIGNED
          LABEL "exch-rate"
          VIEW-AS FILL-IN 
          SIZE 12 BY 1
     ub.trn-doc.VAT-type AT ROW 6.93 COL 72.5 COLON-ALIGNED
          LABEL "VAT-type"
          VIEW-AS FILL-IN 
          SIZE 9 BY 1
     ub.trn-doc.shift-num AT ROW 7.2 COL 12 COLON-ALIGNED
          LABEL "shift-num"
          VIEW-AS FILL-IN 
          SIZE 4 BY 1
     ub.trn-doc.exch-scale AT ROW 7.87 COL 38 COLON-ALIGNED
          LABEL "exch-scale"
          VIEW-AS FILL-IN 
          SIZE 5 BY 1
     ub.trn-doc.SLT-base AT ROW 8 COL 72.5 COLON-ALIGNED
          LABEL "SLT-base"
          VIEW-AS FILL-IN 
          SIZE 16 BY 1
     ub.trn-doc.ship-date AT ROW 8.33 COL 12 COLON-ALIGNED
          LABEL "ship-date"
          VIEW-AS FILL-IN 
          SIZE 9 BY 1
     ub.trn-doc.pay-code AT ROW 8.87 COL 38 COLON-ALIGNED
          LABEL "pay-code"
          VIEW-AS FILL-IN 
          SIZE 6 BY 1
     ub.trn-doc.SLT-rubl AT ROW 9.17 COL 72.5 COLON-ALIGNED
          LABEL "SLT-rubl"
          VIEW-AS FILL-IN 
          SIZE 22 BY 1
     ub.trn-doc.tot-ov AT ROW 9.53 COL 12 COLON-ALIGNED
          LABEL "tot-ov"
          VIEW-AS FILL-IN 
          SIZE 16 BY 1
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1 SCROLLABLE .

/* DEFINE FRAME statement is approaching 4K Bytes.  Breaking it up   */
DEFINE FRAME F-Main
     ub.trn-doc.tot-calc AT ROW 10.03 COL 38 COLON-ALIGNED
          LABEL "tot-calc"
          VIEW-AS FILL-IN 
          SIZE 16 BY 1
     ub.trn-doc.SLT-type AT ROW 10.3 COL 72.5 COLON-ALIGNED
          LABEL "SLT-type"
          VIEW-AS FILL-IN 
          SIZE 9 BY 1
     ub.trn-doc.base-rate AT ROW 10.8 COL 12 COLON-ALIGNED
          LABEL "base-rate"
          VIEW-AS FILL-IN 
          SIZE 12 BY 1
     ub.trn-doc.road-tax AT ROW 11.27 COL 72.5 COLON-ALIGNED
          LABEL "road-tax"
          VIEW-AS FILL-IN 
          SIZE 17 BY 1
     ub.trn-doc.tot-cli AT ROW 11.33 COL 38 COLON-ALIGNED
          LABEL "tot-cli"
          VIEW-AS FILL-IN 
          SIZE 16 BY 1
     ub.trn-doc.base-scale AT ROW 11.97 COL 12 COLON-ALIGNED
          LABEL "base-scale"
          VIEW-AS FILL-IN 
          SIZE 5 BY 1
     ub.trn-doc.excise AT ROW 12.37 COL 72.5 COLON-ALIGNED
          LABEL "excise"
          VIEW-AS FILL-IN 
          SIZE 17 BY 1
     ub.trn-doc.tot-doc AT ROW 12.5 COL 38 COLON-ALIGNED
          LABEL "tot-doc"
          VIEW-AS FILL-IN 
          SIZE 16 BY 1
     ub.trn-doc.discnt-pc AT ROW 13.27 COL 12 COLON-ALIGNED
          LABEL "discnt-pc"
          VIEW-AS FILL-IN 
          SIZE 7 BY 1
     ub.trn-doc.tot-fact AT ROW 13.53 COL 38 COLON-ALIGNED
          LABEL "tot-fact"
          VIEW-AS FILL-IN 
          SIZE 16 BY 1
     ub.trn-doc.discnt-rubl AT ROW 13.53 COL 72.5 COLON-ALIGNED
          LABEL "discnt-rubl"
          VIEW-AS FILL-IN 
          SIZE 22 BY 1
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1 SCROLLABLE .


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: SmartObject
   External Tables: ub.trn-doc
   Allow: Basic,DB-Fields
   Frames: 1
   Add Fields to: External-Tables
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
/* DESIGN Window definition (used by the UIB) 
  CREATE WINDOW V-table-Win ASSIGN
         HEIGHT             = 13.53
         WIDTH              = 95.9.
/* END WINDOW DEFINITION */
                                                                        */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _INCLUDED-LIB V-table-Win 
/* ************************* Included-Libraries *********************** */

{src/adm/method/viewer.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW V-table-Win
  VISIBLE,,RUN-PERSISTENT                                               */
/* SETTINGS FOR FRAME F-Main
   NOT-VISIBLE FRAME-NAME Size-to-Fit                                   */
ASSIGN 
       FRAME F-Main:SCROLLABLE       = FALSE
       FRAME F-Main:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN ub.trn-doc.base-rate IN FRAME F-Main
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN ub.trn-doc.base-scale IN FRAME F-Main
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN ub.trn-doc.discnt-pc IN FRAME F-Main
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN ub.trn-doc.discnt-rubl IN FRAME F-Main
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN ub.trn-doc.discnt-type IN FRAME F-Main
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN ub.trn-doc.doc-qnty IN FRAME F-Main
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN ub.trn-doc.exch-code IN FRAME F-Main
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN ub.trn-doc.exch-date IN FRAME F-Main
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN ub.trn-doc.exch-rate IN FRAME F-Main
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN ub.trn-doc.exch-scale IN FRAME F-Main
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN ub.trn-doc.excise IN FRAME F-Main
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN ub.trn-doc.fact-base IN FRAME F-Main
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN ub.trn-doc.fact-qnty IN FRAME F-Main
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN ub.trn-doc.fact-rubl IN FRAME F-Main
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN ub.trn-doc.pay-code IN FRAME F-Main
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN ub.trn-doc.print-rubl IN FRAME F-Main
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN ub.trn-doc.road-tax IN FRAME F-Main
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN ub.trn-doc.shift-date IN FRAME F-Main
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN ub.trn-doc.shift-num IN FRAME F-Main
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN ub.trn-doc.ship-date IN FRAME F-Main
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN ub.trn-doc.SLT-base IN FRAME F-Main
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN ub.trn-doc.SLT-rubl IN FRAME F-Main
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN ub.trn-doc.SLT-type IN FRAME F-Main
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN ub.trn-doc.tot-calc IN FRAME F-Main
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN ub.trn-doc.tot-cli IN FRAME F-Main
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN ub.trn-doc.tot-doc IN FRAME F-Main
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN ub.trn-doc.tot-fact IN FRAME F-Main
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN ub.trn-doc.tot-other IN FRAME F-Main
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN ub.trn-doc.tot-ov IN FRAME F-Main
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN ub.trn-doc.tot-rubl IN FRAME F-Main
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN ub.trn-doc.tot-sale IN FRAME F-Main
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN ub.trn-doc.tot-transp IN FRAME F-Main
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN ub.trn-doc.VAT-base IN FRAME F-Main
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN ub.trn-doc.VAT-rubl IN FRAME F-Main
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN ub.trn-doc.VAT-type IN FRAME F-Main
   EXP-LABEL                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK FRAME F-Main
/* Query rebuild information for FRAME F-Main
     _Options          = "NO-LOCK"
     _Query            is NOT OPENED
*/  /* FRAME F-Main */
&ANALYZE-RESUME

 


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK V-table-Win 


/* ***************************  Main Block  *************************** */
/* no_app_help.i */
{ gbl/personly.i }

  &IF DEFINED(UIB_IS_RUNNING) <> 0 &THEN
    RUN dispatch IN THIS-PROCEDURE ('initialize':U).
  &ENDIF

  /************************ INTERNAL PROCEDURES ********************/

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE adm-row-available V-table-Win  _ADM-ROW-AVAILABLE
PROCEDURE adm-row-available :
/*------------------------------------------------------------------------------
  Purpose:     Dispatched to this procedure when the Record-
               Source has a new row available.  This procedure
               tries to get the new row (or foriegn keys) from
               the Record-Source and process it.
  Parameters:  <none>
------------------------------------------------------------------------------*/

  /* Define variables needed by this internal procedure.             */
  {src/adm/template/row-head.i}

  /* Create a list of all the tables that we need to get.            */
  {src/adm/template/row-list.i "ub.trn-doc"}

  /* Get the record ROWID's from the RECORD-SOURCE.                  */
  {src/adm/template/row-get.i}

  /* FIND each record specified by the RECORD-SOURCE.                */
  {src/adm/template/row-find.i "ub.trn-doc"}

  /* Process the newly available records (i.e. display fields,
     open queries, and/or pass records on to any RECORD-TARGETS).    */
  {src/adm/template/row-end.i}

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI V-table-Win  _DEFAULT-DISABLE
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE send-records V-table-Win  _ADM-SEND-RECORDS
PROCEDURE send-records :
/*------------------------------------------------------------------------------
  Purpose:     Send record ROWID's for all tables used by
               this file.
  Parameters:  see template/snd-head.i
------------------------------------------------------------------------------*/

  /* Define variables needed by this internal procedure.               */
  {src/adm/template/snd-head.i}

  /* For each requested table, put it's ROWID in the output list.      */
  {src/adm/template/snd-list.i "ub.trn-doc"}

  /* Deal with any unexpected table requests before closing.           */
  {src/adm/template/snd-end.i}

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE state-changed V-table-Win 
PROCEDURE state-changed :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  DEFINE INPUT PARAMETER p-issuer-hdl AS HANDLE    NO-UNDO.
  DEFINE INPUT PARAMETER p-state      AS CHARACTER NO-UNDO.

  CASE p-state:
      /* Object instance CASEs can go here to replace standard behavior
         or add new cases. */
      {src/adm/template/vstates.i}
  END CASE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

