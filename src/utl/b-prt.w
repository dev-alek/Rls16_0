&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI ADM1
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS B-table-Win
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Просмотр партий по строке документа

Автор: Суслов Алексей Юрьевич
Дата создания: 04/11/06
Author: Alexey Suslov
Creation date: 04/11/06

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
define variable vss-description as character no-undo init "Просмотр партий по строке документа".
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

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME F-Main
&Scoped-define BROWSE-NAME br_table

/* External Tables                                                      */
&Scoped-define EXTERNAL-TABLES doc-line
&Scoped-define FIRST-EXTERNAL-TABLE doc-line


/* Need to scope the external tables to this procedure                  */
DEFINE QUERY external_tables FOR doc-line.
/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES parts

/* Define KEY-PHRASE in case it is used by any query. */
&Scoped-define KEY-PHRASE TRUE

/* Definitions for BROWSE br_table                                      */
&Scoped-define FIELDS-IN-QUERY-br_table parts.part-code parts.pay-code ~
parts.cli-qnty parts.cli-base-rate parts.qnty parts.fact-qnty ~
parts.price-cli parts.price-base parts.price-rubl parts.VAT-type ~
parts.VAT-pc parts.SLT-type parts.SLT-pc parts.other-base parts.other-rubl ~
parts.road-tax-base parts.road-tax-rubl parts.transport-base ~
parts.transport-rubl parts.artic parts.cst-code parts.doc-type ~
parts.exch-code parts.fact-date parts.fact-num parts.host-code ~
parts.in-code parts.is-supp parts.last-date parts.obj-code parts.obj-type ~
parts.out-code parts.pl-code parts.prod-code parts.prod-type parts.PS ~
parts.real-qnty parts.rsrv-free parts.status_ parts.supp-code ~
parts.supp-type
&Scoped-define ENABLED-FIELDS-IN-QUERY-br_table
&Scoped-define QUERY-STRING-br_table FOR EACH parts WHERE parts.obj-type = doc-line.obj-type ~
  AND parts.obj-code = doc-line.obj-code ~
  AND parts.out-code = doc-line.doc-code ~
  AND parts.artic = doc-line.artic ~
  AND parts.prod-type = doc-line.prod-type ~
  AND parts.prod-code = doc-line.prod-code NO-LOCK ~
    ~{&SORTBY-PHRASE}
&Scoped-define OPEN-QUERY-br_table OPEN QUERY br_table FOR EACH parts WHERE parts.obj-type = doc-line.obj-type ~
  AND parts.obj-code = doc-line.obj-code ~
  AND parts.out-code = doc-line.doc-code ~
  AND parts.artic = doc-line.artic ~
  AND parts.prod-type = doc-line.prod-type ~
  AND parts.prod-code = doc-line.prod-code NO-LOCK ~
    ~{&SORTBY-PHRASE}.
&Scoped-define TABLES-IN-QUERY-br_table parts
&Scoped-define FIRST-TABLE-IN-QUERY-br_table parts


/* Definitions for FRAME F-Main                                         */

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS br_table

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _XFTR "Foreign Keys" B-table-Win _INLINE
/* Actions: ? adm/support/keyedit.w ? ? ? */
/* STRUCTURED-DATA
<KEY-OBJECT>
&BROWSE-NAME
</KEY-OBJECT>
<FOREIGN-KEYS></FOREIGN-KEYS>
<EXECUTING-CODE>
**************************
* Set attributes related to FOREIGN KEYS
*/
RUN set-attribute-list (
    'Keys-Accepted = ,
     Keys-Supplied = ':U).

/* Tell the ADM to use the OPEN-QUERY-CASES. */
&Scoped-define OPEN-QUERY-CASES RUN dispatch ('open-query-cases':U).
/**************************
</EXECUTING-CODE> */
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _XFTR "Advanced Query Options" B-table-Win _INLINE
/* Actions: ? adm/support/advqedit.w ? ? ? */
/* STRUCTURED-DATA
<KEY-OBJECT>
&BROWSE-NAME
</KEY-OBJECT>
<SORTBY-OPTIONS>
</SORTBY-OPTIONS>
<SORTBY-RUN-CODE>
************************
* Set attributes related to SORTBY-OPTIONS */
RUN set-attribute-list (
    'SortBy-Options = ""':U).
/************************
</SORTBY-RUN-CODE>
<FILTER-ATTRIBUTES>
</FILTER-ATTRIBUTES> */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */
/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br_table FOR
      parts SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br_table
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br_table B-table-Win _STRUCTURED
  QUERY br_table NO-LOCK DISPLAY
      parts.part-code FORMAT "X(20)":U
      parts.pay-code FORMAT "99999":U
      parts.cli-qnty FORMAT "->>,>>>,>>9.999":U
      parts.cli-base-rate FORMAT ">>,>>9.<<<<":U
      parts.qnty FORMAT "->>,>>>,>>9.999":U
      parts.fact-qnty FORMAT "->>,>>>,>>9.999":U
      parts.price-cli FORMAT "->>,>>>,>>>,>>9.999":U
      parts.price-base FORMAT "->>,>>9.99":U
      parts.price-rubl FORMAT "->>,>>>,>>9.99":U
      parts.VAT-type FORMAT "X(8)":U
      parts.VAT-pc FORMAT ">9.9<%":U
      parts.SLT-type FORMAT "X(8)":U
      parts.SLT-pc FORMAT ">9.9<%":U
      parts.other-base FORMAT "->,>>>,>>9.99":U
      parts.other-rubl FORMAT "->,>>>,>>9.99":U
      parts.road-tax-base FORMAT "->,>>>,>>9.99":U
      parts.road-tax-rubl FORMAT "->,>>>,>>9.99":U
      parts.transport-base FORMAT "->,>>>,>>9.99":U
      parts.transport-rubl FORMAT "->,>>>,>>9.99":U
      parts.artic FORMAT "X(16)":U
      parts.cst-code FORMAT "X(31)":U
      parts.doc-type FORMAT "X(8)":U
      parts.exch-code FORMAT ">>9":U
      parts.fact-date FORMAT "99/99/99":U
      parts.fact-num FORMAT "->,>>>,>>9":U
      parts.host-code FORMAT "99999":U
      parts.in-code FORMAT "X(14)":U
      parts.is-supp FORMAT "yes/no":U
      parts.last-date FORMAT "99/99/9999":U
      parts.obj-code FORMAT "99999":U
      parts.obj-type FORMAT "X(3)":U
      parts.out-code FORMAT "X(14)":U
      parts.pl-code FORMAT "999999999":U
      parts.prod-code FORMAT ">>>>>>>>9":U
      parts.prod-type FORMAT "X(8)":U
      parts.PS FORMAT "X(50)":U
      parts.real-qnty FORMAT "->>,>>>,>>9.999":U
      parts.rsrv-free FORMAT "yes/no":U
      parts.status_ FORMAT "yes/no":U
      parts.supp-code FORMAT ">>>>>>>>9":U
      parts.supp-type FORMAT "X(3)":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ASSIGN SEPARATORS SIZE 97.63 BY 6.71.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     br_table AT ROW 1 COL 1
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY
         SIDE-LABELS NO-UNDERLINE THREE-D
         AT COL 1 ROW 1 SCROLLABLE
         BGCOLOR 8 FGCOLOR 0 .


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: SmartObject
   External Tables: ub.doc-line
   Allow: Basic,Browse
   Frames: 1
   Add Fields to: External-Tables
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
/* DESIGN Window definition (used by the UIB)
  CREATE WINDOW B-table-Win ASSIGN
         HEIGHT             = 6.88
         WIDTH              = 97.75.
/* END WINDOW DEFINITION */
                                                                        */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _INCLUDED-LIB B-table-Win
/* ************************* Included-Libraries *********************** */

{src/adm/method/browser.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW B-table-Win
  NOT-VISIBLE,,RUN-PERSISTENT                                           */
/* SETTINGS FOR FRAME F-Main
   NOT-VISIBLE Size-to-Fit                                              */
/* BROWSE-TAB br_table 1 F-Main */
ASSIGN
       FRAME F-Main:SCROLLABLE       = FALSE
       FRAME F-Main:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br_table
/* Query rebuild information for BROWSE br_table
     _TblList          = "ub.parts WHERE ub.doc-line <external> ..."
     _Options          = "NO-LOCK KEY-PHRASE SORTBY-PHRASE"
     _JoinCode[1]      = "parts.obj-type = doc-line.obj-type
  AND parts.obj-code = doc-line.obj-code
  AND parts.out-code = doc-line.doc-code
  AND parts.artic = doc-line.artic
  AND parts.prod-type = doc-line.prod-type
  AND parts.prod-code = doc-line.prod-code"
     _FldNameList[1]   = ub.parts.part-code
     _FldNameList[2]   = ub.parts.pay-code
     _FldNameList[3]   = ub.parts.cli-qnty
     _FldNameList[4]   = ub.parts.cli-base-rate
     _FldNameList[5]   = ub.parts.qnty
     _FldNameList[6]   = ub.parts.fact-qnty
     _FldNameList[7]   = ub.parts.price-cli
     _FldNameList[8]   = ub.parts.price-base
     _FldNameList[9]   = ub.parts.price-rubl
     _FldNameList[10]   = ub.parts.VAT-type
     _FldNameList[11]   = ub.parts.VAT-pc
     _FldNameList[12]   = ub.parts.SLT-type
     _FldNameList[13]   = ub.parts.SLT-pc
     _FldNameList[14]   = ub.parts.other-base
     _FldNameList[15]   = ub.parts.other-rubl
     _FldNameList[16]   = ub.parts.road-tax-base
     _FldNameList[17]   = ub.parts.road-tax-rubl
     _FldNameList[18]   = ub.parts.transport-base
     _FldNameList[19]   = ub.parts.transport-rubl
     _FldNameList[20]   = ub.parts.artic
     _FldNameList[21]   = ub.parts.cst-code
     _FldNameList[22]   = ub.parts.doc-type
     _FldNameList[23]   = ub.parts.exch-code
     _FldNameList[24]   = ub.parts.fact-date
     _FldNameList[25]   = ub.parts.fact-num
     _FldNameList[26]   = ub.parts.host-code
     _FldNameList[27]   = ub.parts.in-code
     _FldNameList[28]   = ub.parts.is-supp
     _FldNameList[29]   = ub.parts.last-date
     _FldNameList[30]   = ub.parts.obj-code
     _FldNameList[31]   = ub.parts.obj-type
     _FldNameList[32]   = ub.parts.out-code
     _FldNameList[33]   = ub.parts.pl-code
     _FldNameList[34]   = ub.parts.prod-code
     _FldNameList[35]   = ub.parts.prod-type
     _FldNameList[36]   = ub.parts.PS
     _FldNameList[37]   = ub.parts.real-qnty
     _FldNameList[38]   = ub.parts.rsrv-free
     _FldNameList[39]   = ub.parts.status_
     _FldNameList[40]   = ub.parts.supp-code
     _FldNameList[41]   = ub.parts.supp-type
     _Query            is NOT OPENED
*/  /* BROWSE br_table */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK FRAME F-Main
/* Query rebuild information for FRAME F-Main
     _Options          = "NO-LOCK"
     _Query            is NOT OPENED
*/  /* FRAME F-Main */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define BROWSE-NAME br_table
&Scoped-define SELF-NAME br_table
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br_table B-table-Win
ON ROW-ENTRY OF br_table IN FRAME F-Main
DO:
  /* This code displays initial values for newly added or copied rows. */
  {src/adm/template/brsentry.i}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br_table B-table-Win
ON ROW-LEAVE OF br_table IN FRAME F-Main
DO:
    /* Do not disable this code or no updates will take place except
     by pressing the Save button on an Update SmartPanel. */
   {src/adm/template/brsleave.i}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br_table B-table-Win
ON VALUE-CHANGED OF br_table IN FRAME F-Main
DO:
  /* This ADM trigger code must be preserved in order to notify other
     objects when the browser's current row changes. */
  {src/adm/template/brschnge.i}

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK B-table-Win


/* ***************************  Main Block  *************************** */
/* no_app_help.i */
{ gbl/personly.i }

&IF DEFINED(UIB_IS_RUNNING) <> 0 &THEN
RUN dispatch IN THIS-PROCEDURE ('initialize':U).
&ENDIF

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE adm-open-query-cases B-table-Win  adm/support/_adm-opn.p
PROCEDURE adm-open-query-cases :
/*------------------------------------------------------------------------------
  Purpose:     Opens different cases of the query based on attributes
               such as the 'Key-Name', or 'SortBy-Case'
  Parameters:  <none>
------------------------------------------------------------------------------*/

  /* No Foreign keys are accepted by this SmartObject. */

  {&OPEN-QUERY-{&BROWSE-NAME}}

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE adm-row-available B-table-Win  _ADM-ROW-AVAILABLE
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
  {src/adm/template/row-list.i "doc-line"}

  /* Get the record ROWID's from the RECORD-SOURCE.                  */
  {src/adm/template/row-get.i}

  /* FIND each record specified by the RECORD-SOURCE.                */
  {src/adm/template/row-find.i "doc-line"}

  /* Process the newly available records (i.e. display fields,
     open queries, and/or pass records on to any RECORD-TARGETS).    */
  {src/adm/template/row-end.i}

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI B-table-Win  _DEFAULT-DISABLE
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE send-key B-table-Win  adm/support/_key-snd.p
PROCEDURE send-key :
/*------------------------------------------------------------------------------
  Purpose:     Sends a requested KEY value back to the calling
               SmartObject.
  Parameters:  <see adm/template/sndkytop.i>
------------------------------------------------------------------------------*/

  /* There are no foreign keys supplied by this SmartObject. */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE send-records B-table-Win  _ADM-SEND-RECORDS
PROCEDURE send-records :
/*------------------------------------------------------------------------------
  Purpose:     Send record ROWID's for all tables used by
               this file.
  Parameters:  see template/snd-head.i
------------------------------------------------------------------------------*/

  /* Define variables needed by this internal procedure.               */
  {src/adm/template/snd-head.i}

  /* For each requested table, put it's ROWID in the output list.      */
  {src/adm/template/snd-list.i "doc-line"}
  {src/adm/template/snd-list.i "parts"}

  /* Deal with any unexpected table requests before closing.           */
  {src/adm/template/snd-end.i}

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE state-changed B-table-Win
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
      {src/adm/template/bstates.i}
  END CASE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME