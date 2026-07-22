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

Оборотная ведомость (без остатков)

Автор: Чернова Светлана Александровна
Дата создания: 03/06/06
Author: Svetlana Chernova
Creation date: 03/06/06

Created: 27/07/01

*/

def var vss-revision    as character no-undo init "$Revision$":U .
def var vss-author      as character no-undo init "$Author$":U .
def var vss-date        as character no-undo init "$Date$":U .
def var vss-workfile    as character no-undo init "$Workfile$":U .
def var vss-archive     as character no-undo init "$Archive$":U .
def var vss-description as character no-undo init "Оборотная ведомость (без остатков)".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/r-page1.i  }
{ rep/gn-extp.i  }
{ rep/rep-bt.i   }
CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

def var State-source as  WIDGET-HANDLE.

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
&Scoped-Define ENABLED-OBJECTS Itog Classify ie ee ep es re rs we vt iv ev ~
rv em wm im RECT-10 RECT-12
&Scoped-Define DISPLAYED-OBJECTS Itog Classify ie ee ep es re rs we vt iv ~
ev rv em wm im ot

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
"НДС по учетной цене", 3,
"НДС по цене документа", 4,
"НсП от цены документа", 5
     SIZE 28.63 BY 4.54 NO-UNDO.

DEFINE RECTANGLE RECT-10
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 30.63 BY 16.83.

DEFINE RECTANGLE RECT-12
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 46.5 BY 16.83.

DEFINE VARIABLE ee AS LOGICAL INITIAL yes
     LABEL "расход внешний":L
     VIEW-AS TOGGLE-BOX
     SIZE 17.63 BY .75 NO-UNDO.

DEFINE VARIABLE em AS LOGICAL INITIAL yes
     LABEL "расход произв.":L
     VIEW-AS TOGGLE-BOX
     SIZE 24 BY .75 NO-UNDO.

DEFINE VARIABLE ep AS LOGICAL INITIAL yes
     LABEL "возврат поставщику"
     VIEW-AS TOGGLE-BOX
     SIZE 23.25 BY .75 NO-UNDO.

DEFINE VARIABLE es AS LOGICAL INITIAL yes
     LABEL "касса продажа":L
     VIEW-AS TOGGLE-BOX
     SIZE 20.38 BY .75 NO-UNDO.

DEFINE VARIABLE ev AS LOGICAL INITIAL yes
     LABEL "расход перемещение":L
     VIEW-AS TOGGLE-BOX
     SIZE 22.63 BY .75 NO-UNDO.

DEFINE VARIABLE ie AS LOGICAL INITIAL yes
     LABEL "приход внешний":L
     VIEW-AS TOGGLE-BOX
     SIZE 22.63 BY .75 NO-UNDO.

DEFINE VARIABLE im AS LOGICAL INITIAL yes
     LABEL "приход произв.":L
     VIEW-AS TOGGLE-BOX
     SIZE 23.25 BY .75 NO-UNDO.

DEFINE VARIABLE Itog AS LOGICAL INITIAL no
     LABEL "Только итоги"
     VIEW-AS TOGGLE-BOX
     SIZE 28.88 BY .83 NO-UNDO.

DEFINE VARIABLE iv AS LOGICAL INITIAL yes
     LABEL "приход перемещение":L
     VIEW-AS TOGGLE-BOX
     SIZE 26.38 BY .75 NO-UNDO.

DEFINE VARIABLE ot AS LOGICAL INITIAL no
     LABEL "переоценка":L
     VIEW-AS TOGGLE-BOX
     SIZE 16.13 BY .75 NO-UNDO.

DEFINE VARIABLE re AS LOGICAL INITIAL yes
     LABEL "возврат внешний":L
     VIEW-AS TOGGLE-BOX
     SIZE 18 BY .75 NO-UNDO.

DEFINE VARIABLE rs AS LOGICAL INITIAL yes
     LABEL "касса возврат":L
     VIEW-AS TOGGLE-BOX
     SIZE 16.13 BY .75 NO-UNDO.

DEFINE VARIABLE rv AS LOGICAL INITIAL yes
     LABEL "возврат перемещение":L
     VIEW-AS TOGGLE-BOX
     SIZE 23.25 BY .75 NO-UNDO.

DEFINE VARIABLE vt AS LOGICAL INITIAL yes
     LABEL "инвентаризация":L
     VIEW-AS TOGGLE-BOX
     SIZE 20.38 BY .75 NO-UNDO.

DEFINE VARIABLE we AS LOGICAL INITIAL yes
     LABEL "списание":L
     VIEW-AS TOGGLE-BOX
     SIZE 23.25 BY .75 NO-UNDO.

DEFINE VARIABLE wm AS LOGICAL INITIAL yes
     LABEL "списан. произв.":L
     VIEW-AS TOGGLE-BOX
     SIZE 23.25 BY .75 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     Itog AT ROW 7.75 COL 3.5
     Classify AT ROW 2.38 COL 3.13 NO-LABEL
     ie AT ROW 2.46 COL 49.63
     ee AT ROW 3.42 COL 49.63
     ep AT ROW 4.33 COL 49.63
     es AT ROW 5.25 COL 49.63
     re AT ROW 6.21 COL 49.63
     rs AT ROW 7.08 COL 49.63
     we AT ROW 8 COL 49.63
     vt AT ROW 8.79 COL 49.63
     iv AT ROW 9.79 COL 49.63
     ev AT ROW 10.75 COL 49.63
     rv AT ROW 11.71 COL 49.63
     em AT ROW 12.63 COL 49.63
     wm AT ROW 13.58 COL 49.63
     im AT ROW 14.5 COL 49.63
     ot AT ROW 15.42 COL 49.63
     "Классификация:":C15 VIEW-AS TEXT
          SIZE 15 BY .75 AT ROW 1.42 COL 11
          FGCOLOR 4
     "Документы:" VIEW-AS TEXT
          SIZE 11 BY .75 AT ROW 1.5 COL 56.38
          FGCOLOR 4
     RECT-10 AT ROW 1.13 COL 47.63
     RECT-12 AT ROW 1.13 COL 1
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
   NOT-VISIBLE Size-to-Fit Custom                                       */
ASSIGN
       FRAME F-Main:SCROLLABLE       = FALSE
       FRAME F-Main:HIDDEN           = TRUE.

/* SETTINGS FOR TOGGLE-BOX ot IN FRAME F-Main
   NO-ENABLE                                                            */
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
  DISPLAY Itog Classify ie ee ep es re rs we vt iv ev rv em wm im ot
      WITH FRAME F-Main.
  ENABLE Itog Classify ie ee ep es re rs we vt iv ev rv em wm im RECT-10
         RECT-12
      WITH FRAME F-Main.
  {&OPEN-BROWSERS-IN-QUERY-F-Main}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-report s-object
PROCEDURE my-report :
/*------------------------------------------------------------------------------
  Purpose:     здесь происходит вызов  процедуры отчета с любыми параметрами
------------------------------------------------------------------------------*/
for each tdedt : delete tdedt. end.
if ie then  do:  { rep/r-mtdedt.i {&tdedt_pri_vnesh}    01 }      end.
if ee then  do:  { rep/r-mtdedt.i {&tdedt_ras_vnesh}    02 }      end.
if ep then  do:  { rep/r-mtdedt.i {&tdedt_ras_vnesh_vp}  03}      end.
if es then  do:  { rep/r-mtdedt.i {&tdedt_ras_vnesh_kass} 04 }    end.
if re then  do:  { rep/r-mtdedt.i {&tdedt_vozvrat_vnesh} 05 }     end.
if rs then  do:  { rep/r-mtdedt.i {&tdedt_vozvrat_vnesh_kass} 06 }end.
if we then  do:  { rep/r-mtdedt.i {&tdedt_spi_vnesh} 07 }         end.
if vt then  do:  { rep/r-mtdedt.i {&tdedt_inv} 08 }
                 { rep/r-mtdedt.i {&tdedt_peresort} 16 }
                 { rep/r-mtdedt.i {&tdedt_corr_minus_parts} 17}   end.
if iv then  do:  { rep/r-mtdedt.i {&tdedt_pri_perem} 09 }         end.
if ev then  do:  { rep/r-mtdedt.i {&tdedt_ras_perem} 10 }         end.
if rv then  do:  { rep/r-mtdedt.i {&tdedt_vozvrat_perem} 11 }     end.
if em then  do:  { rep/r-mtdedt.i {&tdedt_ras_prvo} 12 }          end.
if wm then  do:  { rep/r-mtdedt.i {&tdedt_spi_prvo} 13 }          end.
if im then  do:  { rep/r-mtdedt.i {&tdedt_pri_prvo} 14 }          end.
if ot then  do:  { rep/r-mtdedt.i {&tdedt_overturn} 15 }          end.
  if x-SelectGood = 1 Then DO:
      If x-SET_val_TYPE = 1 /* р_у_б */
        then
      run rep/r-nost1.p
                     (input v-cntxt-obj-code ,
                      input v-cntxt-obj-type ,
                      input base-type ,
                      input base-code ,
                      input Classify,
                      input Itog) .
      Else
      run rep/r-nost2.p
                     (input v-cntxt-obj-code ,
                      input v-cntxt-obj-type ,
                      input base-type ,
                      input base-code ,
                      input Classify,
                      input Itog) .
  End.
  Else DO:
      If x-SET_val_TYPE = 1 /* р_у_б */
        then
      run rep/r-nost3.p
                     (input v-cntxt-obj-code ,
                      input v-cntxt-obj-type ,
                      input base-type ,
                      input base-code ,
                      input Classify,
                      input Itog) .
      Else
      run rep/r-nost4.p
                     (input v-cntxt-obj-code ,
                      input v-cntxt-obj-type ,
                      input base-type ,
                      input base-code ,
                      input Classify,
                      input Itog) .

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
 Classify itog .


ReportHeader =  "По типам документов : "  + chr(10).
ReportHeader = (ReportHeader)               + IF  ie THen      String(ie:label) + ","  else "" .
ReportHeader = (ReportHeader)               + IF  ee then      String(ee:label) + ","  else "".
ReportHeader = (ReportHeader)               + IF  ep then      String(ep:label) + ","  else "".
ReportHeader = (ReportHeader)               + IF  es THen      String(es:label) + ","  else "".
ReportHeader = (ReportHeader)               + IF  re then      String(re:label) + ","  else "".
ReportHeader = (ReportHeader) + chr(10).
ReportHeader = (ReportHeader)               + IF  rs then      String(rs:label) + ","  else "".
ReportHeader = (ReportHeader)               + IF  we THen      String(we:label) + ","  else "".
ReportHeader = (ReportHeader)               + IF  vt then      String(vt:label) + ","  else "".
ReportHeader = (ReportHeader)               + IF  iv then      String(iv:label) + ","  else "".
ReportHeader = (ReportHeader)               + IF  ev THen      String(ev:label) + ","  else "".
ReportHeader = (ReportHeader) + chr(10).
ReportHeader = (ReportHeader)               + IF  rv then      String(rv:label) + ","  else "".
ReportHeader = (ReportHeader)               + IF  em then      String(em:label) + ","  else "" .
ReportHeader = (ReportHeader)               + IF  wm THen      wm:label + ","  else "" .
ReportHeader = (ReportHeader)               + IF  im then      im:label + ","  else "".
ReportHeader = (ReportHeader)               + IF  ot then      ot:label   else "" .

Sheetf.Excel-Column-Lable = "N п\п,Артикул,Название товара,Количество,Учетные цены с НДС,НДС от учетной цены,Учетные цены без НДС" +
   ",Цены документа,В т.ч. скидка,НДС от цены документа,НП от цены документа,Наценка,% торговой наценки,Сумма продажных цен," .
Sheetf.Sizes = "6,16,34,12,13,12,13,13,10,12,12,12,6,12," .
 sheetf.ColFormat = "2=@;3=@;" .
 Sheetf.make-correct = Fill("true,", 14).
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
  END CASE.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME