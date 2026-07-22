
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

Оборотно - сальдовая ведомость  с покупателями (закладка № 2)

Автор: Демин Алексей Сергеевич
Дата создания: 03/27/06
Author: Alexey Demin
Creation date: 03/27/06

*/

def var vss-revision    as character no-undo init "$Revision$":U .
def var vss-author      as character no-undo init "$Author$":U .
def var vss-date        as character no-undo init "$Date$":U .
def var vss-workfile    as character no-undo init "$Workfile$":U .
def var vss-archive     as character no-undo init "$Archive$":U .
def var vss-description as character no-undo init "Оборотно - сальдовая ведомость за период  с покупателями (закладка № 2)".
{ cmp/vssrevis.i }


CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */
{ cmp/str-glbl.i }
{ cmp/r-page1.i }
 { cmp/showinf.i }

DEFINE VARIABLE parParentProc     AS WIDGET-HANDLE NO-UNDO.
def var contr-list as char no-undo.

ASSIGN parParentProc =  my-handle .

{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }

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
&Scoped-Define ENABLED-OBJECTS RECT-6 RECT-7 RECT-8 contr-code BUTTON-contr ~
is-real snum is-fo itog-contract is-fin itog-only is-date
&Scoped-Define DISPLAYED-OBJECTS contr-code is-real snum is-fo ~
itog-contract is-fin itog-only is-date

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */
DEFINE BUTTON BUTTON-contr
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "2"
     SIZE 2.88 BY 1.

DEFINE VARIABLE contr-code AS INTEGER FORMAT ">>>>>>>>>9":U INITIAL 0
     LABEL "Вн.№"
     VIEW-AS FILL-IN
     SIZE 24.5 BY 1 NO-UNDO.

DEFINE VARIABLE snum AS CHARACTER FORMAT "X(256)":U
     LABEL "№"
     VIEW-AS FILL-IN
     SIZE 30.5 BY 1 NO-UNDO.

DEFINE RECTANGLE RECT-6
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 27.5 BY 4.17.

DEFINE RECTANGLE RECT-7
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 36 BY 5.75.

DEFINE RECTANGLE RECT-8
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 23 BY 5.75.

DEFINE VARIABLE is-date AS LOGICAL INITIAL no
     LABEL "с разбивкой по датам"
     VIEW-AS TOGGLE-BOX
     SIZE 22.88 BY .83 NO-UNDO.

DEFINE VARIABLE is-fin AS LOGICAL INITIAL yes
     LABEL "платежи"
     VIEW-AS TOGGLE-BOX
     SIZE 19 BY .83 NO-UNDO.

DEFINE VARIABLE is-fo AS LOGICAL INITIAL yes
     LABEL "фин.обязательства"
     VIEW-AS TOGGLE-BOX
     SIZE 20.5 BY .83 NO-UNDO.

DEFINE VARIABLE is-real AS LOGICAL INITIAL yes
     LABEL "реализация"
     VIEW-AS TOGGLE-BOX
     SIZE 19 BY .83 NO-UNDO.

DEFINE VARIABLE itog-contract AS LOGICAL INITIAL no
     LABEL "Показать все док-ты договору"
     VIEW-AS TOGGLE-BOX
     SIZE 33.5 BY .83 NO-UNDO.

DEFINE VARIABLE itog-only AS LOGICAL INITIAL no
     LABEL "только итоги"
     VIEW-AS TOGGLE-BOX
     SIZE 22.88 BY .83 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     contr-code AT ROW 3 COL 6.5 COLON-ALIGNED
     BUTTON-contr AT ROW 3 COL 33.5
     is-real AT ROW 3 COL 40
     snum AT ROW 4.5 COL 3.5 COLON-ALIGNED
     is-fo AT ROW 4.5 COL 40
     itog-contract AT ROW 5.75 COL 3
     is-fin AT ROW 6 COL 40
     itog-only AT ROW 9.08 COL 3.5
     is-date AT ROW 10.33 COL 3.5
     "Договор:" VIEW-AS TEXT
          SIZE 10 BY 1 AT ROW 1.5 COL 2.5
          FGCOLOR 4
     "Показать:" VIEW-AS TEXT
          SIZE 18 BY 1 AT ROW 7.83 COL 2.5
          FGCOLOR 4
     "Данные:" VIEW-AS TEXT
          SIZE 13.5 BY 1 AT ROW 1.5 COL 40.5
          FGCOLOR 4
     RECT-6 AT ROW 7.33 COL 1.5
     RECT-7 AT ROW 1.25 COL 1.5
     RECT-8 AT ROW 1.25 COL 38.5
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
         HEIGHT             = 14.54
         WIDTH              = 63.63.
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
       FRAME F-Main:HIDDEN           = TRUE.

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

&Scoped-define SELF-NAME BUTTON-contr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BUTTON-contr s-object
ON CHOOSE OF BUTTON-contr IN FRAME F-Main /* 2 */
DO:
  run str/cont-all.w (input parParentProc, input v-cntxt-host-code-obj, input "b-sel", input {&company}, input ?,
                  input ?, input ?, input ?, input "current":u, input {&expense}, input-output contr-list).
  if contr-list <> "" then do:
    find first contract no-lock where RECID(contract) = int (contr-list) no-error .
    if available contract then do:
      assign
        contr-code = contract.contract-code
        snum    = contract.contract-prn-code + " от " + string(contract.contract-date,"99/99/9999")
      .
    end.
    else assign  contr-code = 0   snum = "" .
  end.
  display contr-code snum with frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME contr-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL contr-code s-object
ON LEAVE OF contr-code IN FRAME F-Main /* Вн.№ */
DO:
  assign contr-code.
  run  FindRec in this-procedure  ( input 0 ) .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL contr-code s-object
ON RETURN OF contr-code IN FRAME F-Main /* Вн.№ */
DO:
  assign contr-code.
  run FindRec in this-procedure  ( input 0 ) .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME snum
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL snum s-object
ON LEAVE OF snum IN FRAME F-Main /* № */
DO:
  assign snum.
  run FindRec in this-procedure (input 1) .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME itog-contract
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL itog-contract s-object
ON VALUE-CHANGED OF itog-contract IN FRAME F-Main /* Показать все док-ты по договору */
DO:
  assign itog-contract .
  if itog-contract then do:
    disable itog-only with frame {&frame-name}.
  end.
  else do:
    enable itog-only with frame {&frame-name}.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL snum s-object
ON RETURN OF snum IN FRAME F-Main /* № */
DO:
  assign snum.
  run FindRec in this-procedure (input 1) .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK s-object


/* ***************************  Main Block  *************************** */
{ gbl/personly.i }
/* If testing in the UIB, initialize the SmartObject. */
  assign  frame {&frame-name}  is-real is-fin is-fo .
  display is-real is-fin is-fo with frame {&frame-name}.
  enable itog-contract with frame {&frame-name}.
  
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE FindRec s-object
PROCEDURE FindRec :
define input  parameter typ as integer   no-undo .
  do on error undo, return error return-value :
      if typ = 0 then find first contract no-lock where contract.contract-code = contr-code  and contract.host-code = v-cntxt-host-code-obj no-error .
      else            find first contract no-lock where contract.contract-prn-code = snum and contract.host-code = v-cntxt-host-code-obj no-error .
      if available contract then do:
        assign
          contr-code = contract.contract-code
          snum    = contract.contract-prn-code + " от " + string(contract.contract-date,"99/99/9999")
        .
      end.
      else assign  contr-code = 0    snum = "" .
      display contr-code snum with frame {&frame-name}.
  end.
end procedure. /* FindRec */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-apply-layout s-object
PROCEDURE local-apply-layout :
/*------------------------------------------------------------------------------
  Purpose:     Override standard ADM method
  Notes:
------------------------------------------------------------------------------*/

  /* Code placed here will execute PRIOR to standard behavior. */

  /* Dispatch standard ADM method.                             */
  RUN dispatch IN THIS-PROCEDURE ( INPUT 'apply-layout':U ) .

  /* Code placed here will execute AFTER standard behavior.    */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-report s-object
PROCEDURE my-report :
if is-fin or is-fo or is-real then
    run rep/r-obsal2.p ( itog-only, itog-contract, contr-code, is-date, is-fin, is-fo, is-real ) .
  else message
    "Не выбраны данные для печати"
    view-as alert-box.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-var s-object
PROCEDURE my-var :
/*------------------------------------------------------------------------------
  Purpose:     здесь происходит вызов  значений переменных
  например  Название отчета, может быть еще пример шапки???
------------------------------------------------------------------------------*/

  Assign frame {&frame-name} itog-only itog-contract is-date is-fin is-fo is-real .

  find first clients no-lock where clients.obj-type = {&cmp} and clients.obj-code = v-cntxt-host-code-obj .
  assign str1 = "Фирма: " + clients.obj-name +  chr(10) .

  if contr-code > 0 and itog-contract then  assign ReportNAme = "Оборотно-сальдовая ведомость по договору " + snum .
  else assign ReportNAme = "Оборотно-сальдовая ведомость по поставщикам с: " + string(x-date-start,"99/99/9999") + "г. по: "  + string(x-date-end, "99/99/9999") + "г." .

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
    when "link-changed":U then  DO:
         Run my-var.
         End.

  END CASE.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME