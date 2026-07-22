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

Количественная оборотная ведомость по 2х-уровневой шкале

Автор: Чернова Светлана Александровна
Дата создания: 03/02/06
Author: Svetlana Chernova
Creation date: 03/02/06

Created: 02/08/01
*/

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Оборотная ведомость с учетом признаков".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i  }
{ cmp/r-page1.i  }
{ gbl/cur-time.i }
{ rep/gn-extp.i  }
{ rep/rep-bt.i   }

&scop run-param  (input v-cntxt-obj-code ,~
  input v-cntxt-obj-type ,~
  input base-type ,~
  input base-code ,~
  input Classify,~
  input Itog, ~
  input tog-zero,~
  input ost-1,  ~
  input ost-2   ).

CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

define variable State-source    as  WIDGET-HANDLE  no-undo.
define variable v-today         as date            no-undo.
define variable v-time          as integer         no-undo.

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
&Scoped-Define ENABLED-OBJECTS RECT-10 RECT-12 RECT-14 RECT-15 RECT-13 ie ~
Classify ep ee re es rs Itog we vt iv ev rv em wm im ost-1 ost-2
&Scoped-Define DISPLAYED-OBJECTS ie Classify ep ee re es rs Itog we vt iv ~
ev rv em wm im ost-1 ost-2

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */
DEFINE VARIABLE Classify AS INTEGER INITIAL 1
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Без классификации", 1,
"По производителю", 2,
"По группам товаров", 3
     SIZE 28.63 BY 3 NO-UNDO.

DEFINE RECTANGLE RECT-10
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 30.25 BY 16.83.

DEFINE RECTANGLE RECT-12
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 32.38 BY 8.71.

DEFINE RECTANGLE RECT-13
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 30.25 BY 1.75.

DEFINE RECTANGLE RECT-14
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 30.25 BY 1.75.

DEFINE RECTANGLE RECT-15
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 30.25 BY 5.04.

DEFINE VARIABLE ee AS LOGICAL INITIAL yes
     LABEL "расход внешний":L
     VIEW-AS TOGGLE-BOX
     SIZE 27.63 BY .75 NO-UNDO.

DEFINE VARIABLE em AS LOGICAL INITIAL yes
     LABEL "расход произв.":L
     VIEW-AS TOGGLE-BOX
     SIZE 27.63 BY .75 NO-UNDO.

DEFINE VARIABLE ep AS LOGICAL INITIAL yes
     LABEL "возврат поставщику"
     VIEW-AS TOGGLE-BOX
     SIZE 27.63 BY .75 NO-UNDO.

DEFINE VARIABLE es AS LOGICAL INITIAL yes
     LABEL "касса продажа":L
     VIEW-AS TOGGLE-BOX
     SIZE 27.63 BY .75 NO-UNDO.

DEFINE VARIABLE ev AS LOGICAL INITIAL yes
     LABEL "расход перемещение":L
     VIEW-AS TOGGLE-BOX
     SIZE 27.63 BY .75 NO-UNDO.

DEFINE VARIABLE ie AS LOGICAL INITIAL yes
     LABEL "приход внешний":L
     VIEW-AS TOGGLE-BOX
     SIZE 27.63 BY .75 NO-UNDO.

DEFINE VARIABLE im AS LOGICAL INITIAL yes
     LABEL "приход произв.":L
     VIEW-AS TOGGLE-BOX
     SIZE 27.63 BY .75 NO-UNDO.

DEFINE VARIABLE Itog AS LOGICAL INITIAL no
     LABEL "Только итоги"
     VIEW-AS TOGGLE-BOX
     SIZE 28.88 BY .83 NO-UNDO.

DEFINE VARIABLE iv AS LOGICAL INITIAL yes
     LABEL "приход перемещение":L
     VIEW-AS TOGGLE-BOX
     SIZE 27.63 BY .75 NO-UNDO.

DEFINE VARIABLE ost-1 AS LOGICAL INITIAL no
     LABEL "остаток на начало":L27
     VIEW-AS TOGGLE-BOX
     SIZE 27.63 BY .75 NO-UNDO.

DEFINE VARIABLE ost-2 AS LOGICAL INITIAL no
     LABEL "остаток на конец":L27
     VIEW-AS TOGGLE-BOX
     SIZE 27.63 BY .75 NO-UNDO.

DEFINE VARIABLE ot AS LOGICAL INITIAL no
     LABEL "переоценка":L27
     VIEW-AS TOGGLE-BOX
     SIZE 27.63 BY .75 NO-UNDO.

DEFINE VARIABLE re AS LOGICAL INITIAL yes
     LABEL "возврат внешний":L
     VIEW-AS TOGGLE-BOX
     SIZE 27.63 BY .75 NO-UNDO.

DEFINE VARIABLE rs AS LOGICAL INITIAL yes
     LABEL "касса возврат":L
     VIEW-AS TOGGLE-BOX
     SIZE 27.63 BY .75 NO-UNDO.

DEFINE VARIABLE rv AS LOGICAL INITIAL yes
     LABEL "возврат перемещение":L
     VIEW-AS TOGGLE-BOX
     SIZE 27.63 BY .75 NO-UNDO.

DEFINE VARIABLE tog-zero AS LOGICAL INITIAL no
     LABEL "Нулевые обороты"
     VIEW-AS TOGGLE-BOX
     SIZE 28.88 BY .83 NO-UNDO.

DEFINE VARIABLE vt AS LOGICAL INITIAL yes
     LABEL "инвентаризация":L
     VIEW-AS TOGGLE-BOX
     SIZE 27.63 BY .75 NO-UNDO.

DEFINE VARIABLE we AS LOGICAL INITIAL yes
     LABEL "списание":L
     VIEW-AS TOGGLE-BOX
     SIZE 27.63 BY .75 NO-UNDO.

DEFINE VARIABLE wm AS LOGICAL INITIAL yes
     LABEL "списан. произв.":L
     VIEW-AS TOGGLE-BOX
     SIZE 27.63 BY .75 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     ie AT ROW 2 COL 48.88
     Classify AT ROW 2.38 COL 3 NO-LABEL
     ep AT ROW 2.92 COL 48.88
     ee AT ROW 4.42 COL 48.88
     re AT ROW 5.08 COL 48.88
     es AT ROW 6.63 COL 48.88
     rs AT ROW 7.29 COL 48.88
     Itog AT ROW 7.75 COL 3
     tog-zero AT ROW 8.67 COL 3
     we AT ROW 8.75 COL 48.88
     vt AT ROW 9.54 COL 48.88
     ot AT ROW 10.63 COL 3.5
     iv AT ROW 11.13 COL 48.88
     ev AT ROW 11.92 COL 48.88
     rv AT ROW 12.54 COL 48.88
     em AT ROW 13.17 COL 48.88
     wm AT ROW 13.88 COL 48.88
     im AT ROW 14.67 COL 48.88
     ost-1 AT ROW 16.08 COL 48.88
     ost-2 AT ROW 16.96 COL 48.88
     " Остатки" VIEW-AS TEXT
          SIZE 8.88 BY .75 AT ROW 15.42 COL 58.25
          FGCOLOR 4
     "Показать:":C28 VIEW-AS TEXT
          SIZE 28.75 BY .75 AT ROW 6.79 COL 3
          FGCOLOR 4
     " Расход" VIEW-AS TEXT
          SIZE 8.25 BY .75 AT ROW 3.79 COL 58.75
          FGCOLOR 4
     " Касса" VIEW-AS TEXT
          SIZE 7.13 BY .75 AT ROW 6.04 COL 59.38
          FGCOLOR 4
     "Классификация:":C28 VIEW-AS TEXT
          SIZE 28.75 BY .75 AT ROW 1.42 COL 3
          FGCOLOR 4
     "Обороты (выборочно):":C27 VIEW-AS TEXT
          SIZE 27.63 BY .75 AT ROW 1 COL 49.13
          FGCOLOR 4
     " Перемещение" VIEW-AS TEXT
          SIZE 12.88 BY .75 AT ROW 10.29 COL 56.5
          FGCOLOR 4
     RECT-10 AT ROW 1.13 COL 47.63
     RECT-12 AT ROW 1.13 COL 1
     RECT-14 AT ROW 6.38 COL 47.63
     RECT-15 AT ROW 10.54 COL 47.63
     RECT-13 AT ROW 4.17 COL 47.63
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
         HEIGHT             = 17.25
         WIDTH              = 77.88.
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
       FRAME F-Main:HIDDEN           = TRUE.

/* SETTINGS FOR TOGGLE-BOX ot IN FRAME F-Main
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       ot:HIDDEN IN FRAME F-Main           = TRUE.

/* SETTINGS FOR TOGGLE-BOX tog-zero IN FRAME F-Main
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       tog-zero:HIDDEN IN FRAME F-Main           = TRUE.

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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI s-object  _DEFAULT-ENABLE
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
  DISPLAY ie Classify ep ee re es rs Itog we vt iv ev rv em wm im ost-1 ost-2
      WITH FRAME F-Main.
  ENABLE RECT-10 RECT-12 RECT-14 RECT-15 RECT-13 ie Classify ep ee re es rs
         Itog we vt iv ev rv em wm im ost-1 ost-2
      WITH FRAME F-Main.
  {&OPEN-BROWSERS-IN-QUERY-F-Main}
END PROCEDURE.

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
/*------------------------------------------------------------------------------
  Purpose:     здесь происходит вызов  процедуры отчета с любыми параметрами
------------------------------------------------------------------------------*/
fOR EACH tdedt SHARE-LOCK: DELETE tdedt. eND.
IF ie then  do:  { rep/r-mtdedt.i {&TDEDT_Pri_Vnesh}    01 }                END.
IF ee then  do:  { rep/r-mtdedt.i {&TDEDT_Ras_Vnesh}    02 }                END.
IF ep then  do:  { rep/r-mtdedt.i {&TDEDT_RAS_Vnesh_VP}  03}                END.
IF es then  do:  { rep/r-mtdedt.i {&TDEDT_Ras_Vnesh_Kass} 04 }              END.
IF re then  do:  { rep/r-mtdedt.i {&TDEDT_Vozvrat_Vnesh} 05 }               END.
IF rs then  do:  { rep/r-mtdedt.i {&TDEDT_Vozvrat_Vnesh_Kass} 06 }          END.
IF we then  do:  { rep/r-mtdedt.i {&TDEDT_Spi_Vnesh} 07 }                   END.
IF vt then  do:
                 { rep/r-mtdedt.i {&TDEDT_Inv} 08 }
                 { rep/r-mtdedt.i {&TDEDT_Peresort} 17 }
                 { rep/r-mtdedt.i {&TDEDT_Corr_minus_parts} 18 }
                 END.
IF iv then  do:  { rep/r-mtdedt.i {&TDEDT_Pri_Perem} 09 }                   END.
IF ev then  do:  { rep/r-mtdedt.i {&TDEDT_Ras_Perem} 10 }                   END.
IF rv then  do:  { rep/r-mtdedt.i {&TDEDT_Vozvrat_Perem} 11 }               END.
IF em then  do:  { rep/r-mtdedt.i {&TDEDT_Ras_Prvo} 12 }                    END.
IF wm then  do:  { rep/r-mtdedt.i {&TDEDT_Spi_Prvo} 13 }                    END.
IF im then  do:  { rep/r-mtdedt.i {&TDEDT_Pri_Prvo} 14 }                    END.
IF ot then  do:  { rep/r-mtdedt.i {&TDEDT_Overturn} 15 }                    END.

run cur-time in this-procedure ( output v-today
                               , output v-time
                               ).
  if x-SelectGood = 1 Then DO:
            run rep/r-2-prt1.p
                   {&run-param}
  End.
  Else DO:
            run rep/r-2-prt3.p
                   {&run-param}
  End.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-var s-object
PROCEDURE my-var :
/*------------------------------------------------------------------------------
  Purpose:     здесь происходит вызов  значений переменных
  например  Название отчета, может быть еще пример шапки???
------------------------------------------------------------------------------*/
assign frame {&frame-name}
 ie
 ee
 ep
 es
 re
 rs
 we
 vt
 iv
 ev
 rv
 em
 wm
 im
 ot
 Classify itog tog-zero
 ost-1 ost-2
 .

define variable t-class as char no-undo.
  CASE Classify:
    WHEN 1    THEN t-class =   "Без классификации" .
    WHEN 2    THEN t-class =   "Производители"   .
    WHEN 3    THEN t-class =   "Группы товаров"  .
 End case.

ReportHeader = "Классификация : " + t-Class.
ReportHeader = (ReportHeader) + "Оборот (выборочно) по типам документов : "  + chr(10).
ReportHeader = (ReportHeader) + IF  ie THen      String(ie:label) + ","  else "" .
ReportHeader = (ReportHeader) + IF  ee then      String(ee:label) + ","  else "".
ReportHeader = (ReportHeader) + IF  ep then      String(ep:label) + ","  else "".
ReportHeader = (ReportHeader) + IF  es THen      String(es:label) + ","  else "".
ReportHeader = (ReportHeader) + IF  re then      String(re:label) + ","  else "".
ReportHeader = (ReportHeader) + IF  rs then      String(rs:label) + ","  else "".
ReportHeader = (ReportHeader) + IF  we THen      String(we:label) + ","  else "".
ReportHeader = (ReportHeader) + IF  vt then      String(vt:label) + ","  else "".
ReportHeader = (ReportHeader) + IF  iv then      String(iv:label) + ","  else "".
ReportHeader = (ReportHeader) + IF  ev THen      String(ev:label) + ","  else "".
ReportHeader = (ReportHeader) + chr(10).
ReportHeader = (ReportHeader) + IF  rv then      String(rv:label) + ","  else "".
ReportHeader = (ReportHeader) + IF  em then      String(em:label) + ","  else "" .
ReportHeader = (ReportHeader) + IF  wm THen      wm:label + ","  else "" .
ReportHeader = (ReportHeader) + IF  im then      im:label + ","  else "".
ReportHeader = (ReportHeader) + IF  ot then      ot:label        else "" .
ReportHeader = (ReportHeader)  + chr(10)  + IF  ost-1 then      ost-1:label        else "" .
ReportHeader = (ReportHeader)  + IF  ost-2 then      ost-2:label        else "" .

if tog-zero then ReportHeader = (ReportHeader)+  chr(10) + 'с нулевыми оборотами '.
if itog then ReportHeader = (ReportHeader)+  chr(10) + 'только итоги'.

 ReportHeader = (ReportHeader) +  {&new-line} + '*** ТОЛЬКО товары со шкалами и со вложенностью до 2го уровня *** '.

Sheetf.Excel-Column-Lable =
     "N п\п,Артикул,Код,Название товара,".

Sheetf.Sizes = "6,10,16,25,".

 make-correct = Fill("true,", 4).
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
  if  x-date-end <> today then do:
    tog-zero = false .
    disable  tog-zero with frame {&frame-name}.
  end.

  CASE p-state:
      /* Object instance CASEs can go here to replace standard behavior
         or add new cases. */
  END CASE.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
