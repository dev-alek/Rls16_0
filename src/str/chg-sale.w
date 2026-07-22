&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME DIALOG-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS DIALOG-1
/*------------------------------------------------------------------------

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

История изменения цен товара по объекту

Автор: Чернова Светлана Александровна
Дата создания: 09/14/05
Author: Svetlana Chernova
Creation date: 09/14/05


Список АКТОВ переоценок по объекту


 Андрей Исаков  Created: 05/13/96 -  6:10 pm

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-curr-obj-type like ub.clients.obj-type no-undo .
define input parameter p-curr-obj-code like ub.clients.obj-code no-undo .
define parameter buffer goods for goods.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "История изменения цен товара по объекту".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i }


/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME DIALOG-1
&Scoped-define BROWSE-NAME br-pr

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES price-list price-doc

/* Definitions for BROWSE br-pr                                         */
&Scoped-define FIELDS-IN-QUERY-br-pr price-doc.fact-date price-list.doc-num ~
price-list.price-sale price-list.doc-qnty
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-pr
&Scoped-define FIELD-PAIRS-IN-QUERY-br-pr
&Scoped-define OPEN-QUERY-br-pr OPEN QUERY br-pr FOR EACH price-list ~
      WHERE price-list.obj-type = p-curr-obj-type and ~
price-list.obj-code = p-curr-obj-code and ~
price-list.b-code = bar-code.b-code and ~
price-list.fact-order <> 0 and ~
price-list.main-price = yes NO-LOCK, ~
      EACH price-doc WHERE price-doc.doc-num = price-list.doc-num NO-LOCK ~
    BY price-list.fact-order DESCENDING.
&Scoped-define TABLES-IN-QUERY-br-pr price-list price-doc
&Scoped-define FIRST-TABLE-IN-QUERY-br-pr price-list


/* Definitions for DIALOG-BOX DIALOG-1                                  */
&Scoped-define OPEN-BROWSERS-IN-QUERY-DIALOG-1 ~
    ~{&OPEN-QUERY-br-pr}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit b-lkp b-help br-pr

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-help
     LABEL "&Помощь"
     SIZE 8.75 BY 1.17.

DEFINE BUTTON b-lkp
     LABEL "&Акт"
     SIZE 8.75 BY 1.17.

DEFINE BUTTON b-quit AUTO-END-KEY DEFAULT
     LABEL "&Выход "
     SIZE 10 BY 1.17
     BGCOLOR 8 .

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-pr FOR
      price-list,
      price-doc SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-pr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-pr DIALOG-1 _STRUCTURED
  QUERY br-pr NO-LOCK DISPLAY
      price-doc.fact-date
      price-list.doc-num
      price-list.price-sale
      price-list.doc-qnty
      string (price-doc.plt-id ) + "." +
      string (price-doc.plt-db-num ) + "." +
      string (price-doc.pdf-id ) + "." +
      string (price-doc.pdf-db ) COLUMN-LABEL "Номер ТПЛ и ДНЦ"  format "x(100)"

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH SEPARATORS SIZE 93 BY 15.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME DIALOG-1
     b-quit AT ROW 1.5 COL 1
     b-lkp AT ROW 1.5 COL 11
     b-help AT ROW 1.5 COL 81
     br-pr AT ROW 3.5 COL 1
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE ""
         CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS


/* ***************  Runtime Attributes and UIB Settings  ************** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX DIALOG-1
                                                                        */
/* BROWSE-TAB br-pr b-help DIALOG-1 */
ASSIGN
       FRAME DIALOG-1:SCROLLABLE       = FALSE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-pr
/* Query rebuild information for BROWSE br-pr
     _TblList          = "ub.price-list,ub.price-doc WHERE ub.price-list ... ..."
     _Options          = "NO-LOCK"
     _OrdList          = "ub.price-list.fact-order|no"
     _Where[1]         = "price-list.obj-type = p-curr-obj-type and
price-list.obj-code = p-curr-obj-code and
price-list.b-code = bar-code.b-code and
price-list.fact-order <> 0 and
price-list.main-price = yes"
     _JoinCode[2]      = "price-doc.doc-num = price-list.doc-num"
     _FldNameList[1]   = ub.price-doc.fact-date
     _FldNameList[2]   = ub.price-list.doc-num
     _FldNameList[3]   = ub.price-list.price-sale
     _FldNameList[4]   = ub.price-list.doc-qnty
     _Query            is OPENED
*/  /* BROWSE br-pr */
&ANALYZE-RESUME






/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME b-lkp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-lkp DIALOG-1
ON CHOOSE OF b-lkp IN FRAME DIALOG-1 /* Акт */
DO:
find price-doc where price-doc.doc-num = price-list.doc-num no-error.
if available price-doc then run str/pr-lkp.p ( parparentproc , recid(price-doc)).
apply "entry" to br-pr.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-pr
&Scoped-define SELF-NAME br-pr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-pr DIALOG-1
ON MOUSE-SELECT-DBLCLICK OF br-pr IN FRAME DIALOG-1
DO:
find price-doc where price-doc.doc-num = price-list.doc-num.
run str/pr-lkp.p ( parparentproc , recid(price-doc)).
apply "entry" to br-pr.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-pr DIALOG-1
ON RETURN OF br-pr IN FRAME DIALOG-1
DO:
find price-doc where price-doc.doc-num = price-list.doc-num.
run str/pr-lkp.p ( parparentproc , recid(price-doc)).
apply "entry" to br-pr.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK DIALOG-1


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

{ gbl/app_help.i }

/* Add Trigger to equate WINDOW-CLOSE to END-ERROR                      */
ON WINDOW-CLOSE OF FRAME {&FRAME-NAME} APPLY "END-ERROR":U TO SELF.

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  frame {&frame-name}:title = "Цены на объекте : " + p-curr-obj-type + " "  + string (p-curr-obj-code) +
                                "   для товара : " + goods.artic     + " " + goods.gds-name.
  find first gds-prt no-lock where
             gds-prt.upper-code = goods.prt-root.
  find bar-code no-lock where
       bar-code.gds-code = goods.gds-code and
       bar-code.unit-cli = goods.unit-base and
       bar-code.node-code = gds-prt.node-code and
       bar-code.in-code  = "" and
       bar-code.part-code = "".

  RUN enable_UI.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI DIALOG-1 _DEFAULT-DISABLE
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
  HIDE FRAME DIALOG-1.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI DIALOG-1 _DEFAULT-ENABLE
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
  ENABLE b-quit b-lkp b-help br-pr
      WITH FRAME DIALOG-1.
  {&OPEN-BROWSERS-IN-QUERY-DIALOG-1}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME