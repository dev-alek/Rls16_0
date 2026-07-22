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

Кассовые книги

Автор: Комаров Иван Сергеевич
Дата создания: 04/29/10
Author: Ivan Komarov
Creation date: 04/29/10

*/
define variable parParentProc  as widget-handle no-undo.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Кассовые книги".
{ cmp/vssrevis.i  }
{ cmp/str-glbl.i  }
{ cmp/r-page1.i   }
{ cmp/operlist.i  }
{ rep/rep-bt.i    }
{ gbl/twowin.i   }
/*{ gbl/usr-flt.i }*/
/* { rep/varfpage.i p-customer }
  { rep/rvarpage.i }*/
{ gbl/key-rec.i   }

define variable v-profile-id as integer no-undo .
define variable v-output-type as character no-undo .

CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */
define variable v-nn as integer   no-undo .
define variable State-source as  WIDGET-HANDLE.
define variable g#log as logical   no-undo .

define variable v-curr-r-b               as character no-undo .
define variable v-print-rubl             as logical   no-undo .

define variable p-customer as integer .
define variable v-res as character .

define variable ii as integer no-undo .
DEFINE VARIABLE v-detobj AS logical NO-UNDO.

define variable f-cashbook_id as character no-undo .
DEFINE VARIABLE v-printform AS integer NO-UNDO.

define temp-table tt-cashbook
field id as integer
field name as character
.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE SmartObject
&Scoped-define DB-AWARE no

&Scoped-define ADM-SUPPORTED-LINKS Record-Source,Record-Target,TableIO-Target

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME F-Main

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS RECT-13 f-cashbook B-cashbook p-titul ~
l-cashbook 
&Scoped-Define DISPLAYED-OBJECTS f-cashbook p-titul l-cashbook 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */
DEFINE BUTTON B-cashbook 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "" 
     SIZE 3 BY 1
     FGCOLOR 4 .

DEFINE VARIABLE f-cashbook AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 40 BY 1 NO-UNDO.

DEFINE VARIABLE l-cashbook AS CHARACTER FORMAT "X(256)":U INITIAL "Кассовая книга:" 
      VIEW-AS TEXT 
     SIZE 15 BY .67 NO-UNDO.

DEFINE RECTANGLE RECT-13
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 69 BY 3.71.

DEFINE VARIABLE p-titul AS LOGICAL INITIAL no 
     LABEL "Печать титульного листа" 
     VIEW-AS TOGGLE-BOX
     SIZE 40 BY .83 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     f-cashbook AT ROW 2 COL 21.5 COLON-ALIGNED NO-LABEL WIDGET-ID 34
     B-cashbook AT ROW 2 COL 65.5 WIDGET-ID 32
     p-titul AT ROW 3.42 COL 23.5 WIDGET-ID 38
     l-cashbook AT ROW 2.33 COL 5.5 NO-LABEL WIDGET-ID 36
     RECT-13 AT ROW 1.29 COL 2 WIDGET-ID 18
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
         HEIGHT             = 16.75
         WIDTH              = 75.
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
   NOT-VISIBLE FRAME-NAME Size-to-Fit                                   */
ASSIGN 
       FRAME F-Main:SCROLLABLE       = FALSE
       FRAME F-Main:HIDDEN           = TRUE
       FRAME F-Main:PRIVATE-DATA     = 
                "DLGCLOSE".

/* SETTINGS FOR FILL-IN l-cashbook IN FRAME F-Main
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK FRAME F-Main
/* Query rebuild information for FRAME F-Main
     _Options          = "NO-LOCK"
     _Query            is NOT OPENED
*/  /* FRAME F-Main */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME B-cashbook
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-cashbook s-object
ON CHOOSE OF B-cashbook IN FRAME F-Main
DO:
  define variable v-cb-brw as class ibs.th.ref.cashbookbrw no-undo .
  define variable ii  as integer no-undo .
  
  parParentProc = my-handle .
  v-cb-brw = new ibs.th.ref.cashbookbrw ( "multiselect", parParentProc ).

  wait-for  v-cb-brw:ShowDialog() .
  
  if v-cb-brw:out-list-id > ""
  then do :
    do ii = 1 to num-entries (v-cb-brw:out-list-id, {&delim-cmd}):
  
    find first ub.cashbook no-lock where ub.cashbook.id = int64(entry(ii,v-cb-brw:out-list-id,{&delim-cmd})) no-error.
    if ii = 1 then
    assign
    f-cashbook = ub.CashBook.CashBookName
    f-cashbook_id = string(ub.CashBook.id)
    .
    else
    assign
    f-cashbook = f-cashbook + {&delim-cmd} + ub.CashBook.CashBookName
    f-cashbook_id = f-cashbook_id + {&delim-cmd} + string(ub.CashBook.id)
    .
  end.
    display
    f-cashbook
    with frame {&frame-name} .

  end.
    
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME p-titul
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL p-titul s-object
ON VALUE-CHANGED OF p-titul IN FRAME F-Main /* Печать титульного листа */
DO:
  assign p-titul .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK s-object 


/* ***************************  Main Block  *************************** */
{ gbl/personly.i }
/* If testing in the UIB, initialize the SmartObject. */
 run Enable_UI .
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Enable_UI s-object 
PROCEDURE Enable_UI :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    display
    l-cashbook
    with frame {&frame-name} .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-report s-object 
PROCEDURE my-report :
/*------------------------------------------------------------------------------
  Purpose:     здесь происходит вызов  процедуры отчета с любыми параметрами
------------------------------------------------------------------------------*/

run rep/r-cashbk.p
    (
     input my-handle
    ,input this-procedure:handle /*p-parent-handle*/
    ,input this-procedure:handle /*      p-log-handle*/
    ,input this-procedure:handle /*   p-cont-handle*/
    ,input this-procedure:handle /*p-call-handle*/
    ,input ? /*p-rebh*/
    ,input ? /*p-redbh*/
    ,input '' /*p-report-id*/
    ,input ''
    ,input integer({&repcalc-type-operator}) /*p-batch*/
    ,input 0 /*p-codex-id*/
    ,input 0 /*p-ruleset-id*/
    ,input f-cashbook_id
    ,input yes /*t-text*/
    ,input yes /*t-excel*/
    ,input '' /*p-dir-name*/
    ,input p-titul
     ) .
     
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-var s-object 
PROCEDURE my-var :
/*------------------------------------------------------------------------------
  Purpose:     здесь происходит вызов  значений переменных
  например  Название отчета, может быть еще пример шапки???
------------------------------------------------------------------------------*/
assign frame {&frame-name} f-cashbook
.
  assign
    ReportHeader = "Кассовые книги"
  .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE write-to-log s-object 
PROCEDURE write-to-log :
define input param p-str as char no-undo.

do
on error undo, return error
:
   message
      p-str
      skip
   view-as alert-box error.

end. /* do on error */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

