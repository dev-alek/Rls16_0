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

Отчет Итоги по дисконтным картам

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/07/05
Author: Bakhtadze Natalya
Creation date: 09/07/05

*/

/* Create an unnamed pool to store all the widgets created
     by this procedure. This is a good default which assures
     that this procedure's triggers and internal procedures
     will execute in this procedure's storage, and that proper
     cleanup will occur on deletion of the procedure. */

CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Отчет Итоги по дисконтным картам" .
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/r-page1.i  }
{ rep/rep-bt.i   }
{ gbl/cur-time.i }
{ cmp/dc-list.i dc-list def "new shared" }

define variable     dcard-mode as integer      no-undo init 0.     /* переменная выбора по ДК */

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
&Scoped-Define ENABLED-OBJECTS rect-3 rect-5 rect-7 SelectDC chk-obj chk-dc ~
chk-dc-num chk-dc-cli fill-days 
&Scoped-Define DISPLAYED-OBJECTS SelectDC chk-obj chk-dc chk-dc-num ~
chk-dc-cli fill-days 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */
DEFINE VARIABLE fill-days AS INTEGER FORMAT ">>>>>9":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE SelectDC AS CHARACTER 
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS 
          "Все", "all":U,
"Выборочно по картам", "card":U
     SIZE 30.6 BY 1.67 NO-UNDO.

DEFINE RECTANGLE rect-3
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 46 BY 3.38.

DEFINE RECTANGLE rect-5
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 46 BY 5.

DEFINE RECTANGLE rect-7
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 46 BY 4.52.

DEFINE VARIABLE chk-dc AS LOGICAL INITIAL no 
     LABEL "Детализация по ДК" 
     VIEW-AS TOGGLE-BOX
     SIZE 25.2 BY 1 NO-UNDO.

DEFINE VARIABLE chk-dc-cli AS LOGICAL INITIAL no 
     LABEL "ФИО клиента" 
     VIEW-AS TOGGLE-BOX
     SIZE 20.8 BY .81 NO-UNDO.

DEFINE VARIABLE chk-dc-num AS LOGICAL INITIAL no 
     LABEL "Выводить номера ДК" 
     VIEW-AS TOGGLE-BOX
     SIZE 26.8 BY .81 NO-UNDO.

DEFINE VARIABLE chk-obj AS LOGICAL INITIAL no 
     LABEL "Детализация по объектам" 
     VIEW-AS TOGGLE-BOX
     SIZE 33.2 BY .81 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     SelectDC AT ROW 2.52 COL 3.8 NO-LABEL
     chk-obj AT ROW 6 COL 3.8 WIDGET-ID 2
     chk-dc AT ROW 6.76 COL 3.8
     chk-dc-num AT ROW 7.67 COL 7.2 WIDGET-ID 28
     chk-dc-cli AT ROW 8.52 COL 7.2 WIDGET-ID 30
     fill-days AT ROW 13.1 COL 4.2 NO-LABEL WIDGET-ID 40
     "Количество дней от начала периода," VIEW-AS TEXT
          SIZE 42 BY .71 AT ROW 11.48 COL 4 WIDGET-ID 36
     "Представление" VIEW-AS TEXT
          SIZE 26.8 BY .95 AT ROW 4.95 COL 3.6
          FGCOLOR 4 
     "Мертвый период" VIEW-AS TEXT
          SIZE 19.4 BY .95 AT ROW 10.19 COL 3.6 WIDGET-ID 34
          FGCOLOR 4 
     "Выбор по ДК" VIEW-AS TEXT
          SIZE 31.2 BY .81 AT ROW 1.43 COL 3.6
          FGCOLOR 4 
     "по которому считать отток клиентов:" VIEW-AS TEXT
          SIZE 40 BY .62 AT ROW 12.19 COL 4 WIDGET-ID 38
     rect-3 AT ROW 1.19 COL 2.2
     rect-5 AT ROW 4.81 COL 2.2
     rect-7 AT ROW 10.05 COL 2.2 WIDGET-ID 32
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 49.4 BY 14.05.


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
         HEIGHT             = 14.05
         WIDTH              = 49.4.
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
  VISIBLE,,RUN-PERSISTENT                                               */
/* SETTINGS FOR FRAME F-Main
   NOT-VISIBLE FRAME-NAME                                               */
/* SETTINGS FOR FILL-IN fill-days IN FRAME F-Main
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK FRAME F-Main
/* Query rebuild information for FRAME F-Main
     _Options          = ""
     _Query            is NOT OPENED
*/  /* FRAME F-Main */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME chk-dc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL chk-dc F-Frame-Win
ON VALUE-CHANGED OF chk-dc IN FRAME F-Main /* Детализация по ДК */
DO:
  assign chk-dc-cli.
  assign chk-dc-num.
  assign chk-dc.
chk-dc-num:screen-value = chk-dc:screen-value.
chk-dc-cli:screen-value = chk-dc:screen-value.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME chk-dc-cli
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL chk-dc-cli F-Frame-Win
ON VALUE-CHANGED OF chk-dc-cli IN FRAME F-Main /* ФИО клиента */
DO:
  assign chk-dc-cli.
  assign chk-dc-num.
  assign chk-dc.
  case chk-dc-cli:
      when yes then do:
          if chk-dc = no then chk-dc:screen-value = "yes".
      end.
      when no then do:
          if chk-dc and chk-dc-num = no then chk-dc:screen-value = "no".
      end.
  end case. 
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME chk-dc-num
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL chk-dc-num F-Frame-Win
ON VALUE-CHANGED OF chk-dc-num IN FRAME F-Main /* Выводить номера ДК */
DO:
  assign chk-dc-cli.
  assign chk-dc-num.
  assign chk-dc.
  case chk-dc-num:
      when yes then do:
          if not chk-dc then chk-dc:screen-value = "yes".
      end.
      when no then do:
          if chk-dc and not chk-dc-cli then chk-dc:screen-value = "no".
      end.
  end case.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME chk-obj
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL chk-obj F-Frame-Win
ON VALUE-CHANGED OF chk-obj IN FRAME F-Main /* Детализация по объектам */
DO:
  assign chk-obj.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME



&Scoped-define SELF-NAME SelectDC
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL SelectDC F-Frame-Win
ON VALUE-CHANGED OF SelectDC IN FRAME F-Main
DO:
 assign SelectDC.
 case SelectDC:
     when "card":u then do:
         run str/dc-list.w (my-handle, v-cntxt-host-code-obj, v-cntxt-obj-type, v-cntxt-obj-code).
         dcard-mode = 1.
         find first dc-list no-lock no-error .
          if not available dc-list then do:
            message
            "В списке карт нет ни одной карты"
            view-as alert-box WARNING.
            dcard-mode = 0.
            end.
     end.
     when "all":u then do:
         assign
         dcard-mode = 0
         SelectDC = "all":U
         .
     end.
 end case.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK F-Frame-Win 


&IF DEFINED(UIB_IS_RUNNING) <> 0 &THEN
   /* Now enable the interface  if in test mode - otherwise this happens when
      the object is explicitly initialized from its container. */
   run dispatch in this-procedure ('initialize':u).
&ENDIF

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE adm-create-objects F-Frame-Win  _ADM-CREATE-OBJECTS
PROCEDURE adm-create-objects :
/*------------------------------------------------------------------------------
  Purpose:     Create handles for all SmartObjects used in this procedure.
               After SmartObjects are initialized, then SmartLinks are added.
  Parameters:  <none>
------------------------------------------------------------------------------*/

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE adm-row-available F-Frame-Win  _ADM-ROW-AVAILABLE
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

  /* Process the newly available records (i.e. display fields,
     open queries, and/or pass records on to any RECORD-TARGETS).    */
  {src/adm/template/row-end.i}

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

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
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
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
  DISPLAY SelectDC chk-obj chk-dc chk-dc-num chk-dc-cli fill-days 
      WITH FRAME F-Main.
  ENABLE rect-3 rect-5 rect-7 SelectDC chk-obj chk-dc chk-dc-num chk-dc-cli 
         fill-days 
      WITH FRAME F-Main.
  {&OPEN-BROWSERS-IN-QUERY-F-Main}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-initialize F-Frame-Win 
PROCEDURE local-initialize :
/*------------------------------------------------------------------------------
  Purpose:     Override standard ADM method
  Notes:
------------------------------------------------------------------------------*/
  /* Code placed here will execute PRIOR to standard behavior. */
  /* Dispatch standard ADM method.                             */
  run dispatch in this-procedure ( input 'initialize':u ) .
  /* Code placed here will execute AFTER standard behavior.    */
end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE My-report F-Frame-Win 
PROCEDURE My-report :
define variable     det-mode            as integer      no-undo init 0.
    assign frame f-main fill-days chk-dc chk-dc-cli chk-dc-num.  
    if chk-dc-num and chk-dc-cli then det-mode = 1.
    if chk-dc-num and not chk-dc-cli then det-mode = 2.
    if not chk-dc-num and chk-dc-cli then det-mode = 3.
    if not chk-dc-num and not chk-dc-cli then det-mode = 0.
    
    
    do:
        run rep/r-activ.p (
                            input my-handle,
                            input det-mode,
                            input chk-obj,
                            input dcard-mode,
                            input fill-days
                            ).
    end.
end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-var F-Frame-Win 
PROCEDURE my-var :
.
end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE state-changed F-Frame-Win 
PROCEDURE state-changed :
define input parameter p-issuer-hdl as handle no-undo.
  define input parameter p-state as character no-undo.
end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

