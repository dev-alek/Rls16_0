&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI ADM1
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS F-Frame-Win 
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/07/05
Author: Bakhtadze Natalya
Creation date: 09/07/05

*/

CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Состояние режимов измерения резервуаров" .
{ cmp/vssrevis.i }
{ cmp/str-glbl.i  }
{ cmp/library.i }
{ cmp/r-page1.i  }
{ rep/rep-bt.i }
{ gbl/cur-time.i }
{ cmp/r-pril.i new }
{ str/out-vatp.i def}
{ gbl/prn-lib.i }
{ cmp/operlist.i }
{ cmp/breakstr.i }
{ str/lib-calc.i }
{ str/clcprtsl.i }
{ gbl/waitfram.i }
define variable parparentproc as widget-handle no-undo .
{ str/getctxtp.i def }


DEFINE SHARED VAR      objects     as integer   no-undo.
DEFINE SHARED VAR      FRAME-TITLE as char      no-undo.


/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE SmartObject
&Scoped-define DB-AWARE no

&Scoped-define ADM-CONTAINER FRAME

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME F-Main

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS RECT-6 RS-Method 
&Scoped-Define DISPLAYED-OBJECTS RS-Method 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */
DEFINE VARIABLE RS-Method   AS integer 
  VIEW-AS RADIO-SET VERTICAL
  RADIO-BUTTONS 
  "Стандартный", 1,
  "Расширенный", 2
  SIZE 15 BY 2 NO-UNDO.

DEFINE VARIABLE t-dens AS LOGICAL INITIAL yes 
     LABEL "Плотность" 
     VIEW-AS TOGGLE-BOX
     SIZE 11.13 BY 1 NO-UNDO.

DEFINE VARIABLE t-level AS LOGICAL INITIAL yes 
     LABEL "Уровень" 
     VIEW-AS TOGGLE-BOX
     SIZE 11.13 BY 1 NO-UNDO.

DEFINE VARIABLE t-temp AS LOGICAL INITIAL yes 
     LABEL "Температура" 
     VIEW-AS TOGGLE-BOX
     SIZE 13.5 BY 1 NO-UNDO.
     
DEFINE VARIABLE t-rvd-on AS LOGICAL INITIAL yes 
     LABEL "Включено" 
     VIEW-AS TOGGLE-BOX
     SIZE 11 BY 1 NO-UNDO.

DEFINE VARIABLE t-rvd-off AS LOGICAL INITIAL yes 
     LABEL "Выключено" 
     VIEW-AS TOGGLE-BOX
     SIZE 11 BY 1 NO-UNDO.

DEFINE VARIABLE RS-rvd-reason   AS integer 
  VIEW-AS RADIO-SET VERTICAL
  RADIO-BUTTONS 
  "Все", 1,
  "Выборочно", 2
  SIZE 15 BY 2 NO-UNDO.

DEFINE BUTTON r-select-rvd-reason 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "r-rvd-reason" 
     SIZE 3 BY .88.

define variable v-rvd-reasons-list  as character 
  label ""
  view-as fill-in
  size 40 by 1 no-undo .
     
DEFINE RECTANGLE RECT-6
  EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
  SIZE 55 BY 15.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
  RS-Method AT ROW 2.5 COL 5 label "Тип отчета"
  "Параметры РВД:" view-as text size 15 by 1 at row 5 col 5
  t-dens at row 6 col 5
  t-level at row 6 col 17
  t-temp at row 6 col 29
  "Состояние РВД:" view-as text size 15 by 1 at row 7.5 col 5
  t-rvd-on at row 8.5 col 5
  t-rvd-off at row 8.5 col 17
  "Причины перехода на РВД:" view-as text size 25 by 1 at row 10 col 5
  RS-rvd-reason at row 11 col 5 no-label
  r-select-rvd-reason at row 12 col 20 
  v-rvd-reasons-list at row 13 col 5 no-label
  RECT-6 AT ROW 1.25 COL 2.25
  WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
  SIDE-LABELS NO-UNDERLINE THREE-D 
  AT COL 1 ROW 1
  SIZE 60 BY 18.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: SmartObject
   Allow: Basic,Browse,DB-Fields,Smart,Query
   Container Links: 
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
/* DESIGN Window definition (used by the UIB) 
  CREATE WINDOW F-Frame-Win ASSIGN
         HEIGHT             = 15
         WIDTH              = 47.63.
/* END WINDOW DEFINITION */
                                                                        */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _INCLUDED-LIB F-Frame-Win 
/* ************************* Included-Libraries *********************** */

{src/adm/method/containr.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW F-Frame-Win
  VISIBLE,,                                               */
/* SETTINGS FOR FRAME F-Main
   NOT-VISIBLE FRAME-NAME                                               */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK FRAME F-Main
/* Query rebuild information for FRAME F-Main
     _Options          = ""
     _Query            is NOT OPENED
*/  /* FRAME F-Main */
&ANALYZE-RESUME

 
&Scoped-define SELF-NAME r-select-rvd-reason
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame F-Main
on choose of r-select-rvd-reason IN FRAME F-Main
do:
  define variable v-rec as character no-undo .
  define variable ii  as integer no-undo .
  
  define buffer buf_ext-classif for ub.ext-classif .
  
  run ref/rvd-reason.w (input parparentproc,
                        input "b-sel,b-mark",
                        input {&all},
                        input 0, /* РГС */
                        output v-rec ) .
  if v-rec > ""
  then do :  
    v-rvd-reasons-list = "" .                    
    do ii = 1 to num-entries(v-rec) :
      for first buf_ext-classif no-lock where recid(buf_ext-classif) = integer(entry(ii, v-rec)) :
        v-rvd-reasons-list = v-rvd-reasons-list + buf_ext-classif.CharKey_One + "," .
      end .                                  
    end . 
    v-rvd-reasons-list = trim(v-rvd-reasons-list, ",") .
    display v-rvd-reasons-list WITH FRAME F-Main.
  end .                   
end .
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME RS-rvd-reason
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL RS-rvd-reason F-Main
ON VALUE-CHANGED OF RS-rvd-reason IN FRAME F-Main 
DO:
   assign FRAME F-Main RS-rvd-reason .
   if RS-rvd-reason = 2
   then do :
     enable r-select-rvd-reason WITH FRAME F-Main.
   end .
   else do :
     disable r-select-rvd-reason WITH FRAME F-Main.
     v-rvd-reasons-list = "" .
     display v-rvd-reasons-list WITH FRAME F-Main.
   end .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK F-Frame-Win 


/* ***************************  Main Block  *************************** */
  { gbl/personly.i }
parparentproc = my-handle.
{ str/getctxtp.i get }
&IF DEFINED(UIB_IS_RUNNING) <> 0 &THEN
/* Now enable the interface  if in test mode - otherwise this happens when
   the object is explicitly initialized from its container. */
RUN dispatch IN THIS-PROCEDURE ('initialize':U).
&ENDIF

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI F-Frame-Win  _DEFAULT-DISABLE
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
  
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI F-Frame-Win  _DEFAULT-ENABLE
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
  DISPLAY RS-Method RS-rvd-reason t-dens t-level t-temp t-rvd-on t-rvd-off
    WITH FRAME F-Main.
  ENABLE RECT-6 RS-Method RS-rvd-reason t-dens t-level t-temp t-rvd-on t-rvd-off
    WITH FRAME F-Main.
  {&OPEN-BROWSERS-IN-QUERY-F-Main}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE My-report F-Frame-Win 
PROCEDURE My-report :
  /*------------------------------------------------------------------------------
    Purpose:
    Parameters:  <none>
    Notes:
  ------------------------------------------------------------------------------*/
  
  assign
    frame {&frame-name} RS-Method
    frame {&frame-name} t-dens
    frame {&frame-name} t-level
    frame {&frame-name} t-temp
    frame {&frame-name} t-rvd-on
    frame {&frame-name} t-rvd-off
    frame {&frame-name} RS-rvd-reason
  .
  
  if not t-dens
  and not t-level
  and not t-temp
  then do :
    message "Выберите хотя бы один параметр РВД." view-as alert-box .
    return .
  end .
  
  if not t-rvd-off
  and not t-rvd-on
  then do :
    message "Выберите хотя бы одно состояние РВД." view-as alert-box .
    return .
  end .

  run rep/r-RVD-state.p (input RS-Method,
                         input t-dens,
                         input t-level,
                         input t-temp,
                         input t-rvd-off,
                         input t-rvd-on,
                         input v-rvd-reasons-list) .
  
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE My-var F-Frame-Win 
PROCEDURE My-var :
  /*------------------------------------------------------------------------------
    Purpose:
    Parameters:  <none>
    Notes:
  ------------------------------------------------------------------------------*/
  assign
    ReportHeader = "Состояние изменения режима ввода данных по резервуарам".
  
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




