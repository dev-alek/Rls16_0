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

Реестр документов по типу приобретени (закладка № 2)

Автор: Чернова Светлана Александровна
Дата создания: 03/06/06
Author: Svetlana Chernova
Creation date: 03/06/06

Created: 20/10/00

*/

def var vss-revision    as character no-undo init "$Revision$":U .
def var vss-author      as character no-undo init "$Author$":U .
def var vss-date        as character no-undo init "$Date$":U .
def var vss-workfile    as character no-undo init "$Workfile$":U .
def var vss-archive     as character no-undo init "$Archive$":U .
def var vss-description as character no-undo init "Реестр документов по типу приобретения(закладка № 2)".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/r-page1.i }
{ rep/rep-bt.i }
{ rep/gn-extp.i }

DEFINE VARIABLE  type-pr  AS WIDGET-HANDLE.
define variable g#log as logical   no-undo .
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
&Scoped-Define ENABLED-OBJECTS RECT-10 RECT-12 RECT-16 RECT-15 ie CostSum ~
ee DispUpFact ep es re rs NullPer we vt iv CalcRest ev rv em wm im ot ap pc
&Scoped-Define DISPLAYED-OBJECTS ie CostSum ee DispUpFact ep es re rs ~
NullPer we vt iv CalcRest ev rv em wm im ot ap pc

/* Custom List Definitions                                              */
/* list-tdedt,List-2,List-3,List-4,List-5,List-6                        */
&Scoped-define list-tdedt ie ee ep es re rs we vt iv ev rv em wm im ot ap ~
pc

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */
DEFINE RECTANGLE RECT-10
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 30.13 BY 4.83.

DEFINE RECTANGLE RECT-12
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 35 BY 4.83.

DEFINE RECTANGLE RECT-15
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 35 BY 1.42.

DEFINE RECTANGLE RECT-16
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 35 BY 1.67.

DEFINE VARIABLE ap AS LOGICAL INITIAL yes
     LABEL "переоценка":L
     VIEW-AS TOGGLE-BOX
     SIZE 26.38 BY .75 NO-UNDO.

DEFINE VARIABLE CalcRest AS LOGICAL INITIAL yes
     LABEL "Расчет остатков"
     VIEW-AS TOGGLE-BOX
     SIZE 32 BY .75 NO-UNDO.

DEFINE VARIABLE CostSum AS LOGICAL INITIAL no
     LABEL "Учетные цены"
     VIEW-AS TOGGLE-BOX
     SIZE 32 BY .75 NO-UNDO.

DEFINE VARIABLE DispUpFact AS LOGICAL INITIAL no
     LABEL "Наценка"
     VIEW-AS TOGGLE-BOX
     SIZE 32 BY .75 NO-UNDO.

DEFINE VARIABLE ee AS LOGICAL INITIAL yes
     LABEL "расход внешний":L
     VIEW-AS TOGGLE-BOX
     SIZE 26.38 BY .75 NO-UNDO.

DEFINE VARIABLE em AS LOGICAL INITIAL yes
     LABEL "расход произв.":L
     VIEW-AS TOGGLE-BOX
     SIZE 26.38 BY .75 NO-UNDO.

DEFINE VARIABLE ep AS LOGICAL INITIAL yes
     LABEL "возврат поставщику"
     VIEW-AS TOGGLE-BOX
     SIZE 26.38 BY .75 NO-UNDO.

DEFINE VARIABLE es AS LOGICAL INITIAL yes
     LABEL "касса продажа":L
     VIEW-AS TOGGLE-BOX
     SIZE 26.38 BY .75 NO-UNDO.

DEFINE VARIABLE ev AS LOGICAL INITIAL yes
     LABEL "расход перемещение":L
     VIEW-AS TOGGLE-BOX
     SIZE 26.38 BY .75 NO-UNDO.

DEFINE VARIABLE ie AS LOGICAL INITIAL yes
     LABEL "приход внешний":L
     VIEW-AS TOGGLE-BOX
     SIZE 26.38 BY .75 NO-UNDO.

DEFINE VARIABLE im AS LOGICAL INITIAL yes
     LABEL "приход произв.":L
     VIEW-AS TOGGLE-BOX
     SIZE 26.38 BY .75 NO-UNDO.

DEFINE VARIABLE iv AS LOGICAL INITIAL yes
     LABEL "приход перемещение":L
     VIEW-AS TOGGLE-BOX
     SIZE 26.38 BY .75 NO-UNDO.

DEFINE VARIABLE NullPer AS LOGICAL INITIAL no
     LABEL "не удалять нулевые переоценки"
     VIEW-AS TOGGLE-BOX
     SIZE 32 BY .75 NO-UNDO.

DEFINE VARIABLE ot AS LOGICAL INITIAL yes
     LABEL "переоценка":L
     VIEW-AS TOGGLE-BOX
     SIZE 26.38 BY .75 NO-UNDO.

DEFINE VARIABLE pc AS LOGICAL INITIAL yes
     LABEL "переоценка":L
     VIEW-AS TOGGLE-BOX
     SIZE 26.38 BY .75 NO-UNDO.

DEFINE VARIABLE re AS LOGICAL INITIAL yes
     LABEL "возврат внешний":L
     VIEW-AS TOGGLE-BOX
     SIZE 26.38 BY .75 NO-UNDO.

DEFINE VARIABLE rs AS LOGICAL INITIAL yes
     LABEL "касса возврат":L
     VIEW-AS TOGGLE-BOX
     SIZE 26.38 BY .75 NO-UNDO.

DEFINE VARIABLE rv AS LOGICAL INITIAL yes
     LABEL "возврат перемещение":L
     VIEW-AS TOGGLE-BOX
     SIZE 26.38 BY .75 NO-UNDO.

DEFINE VARIABLE vt AS LOGICAL INITIAL yes
     LABEL "инвентаризация":L
     VIEW-AS TOGGLE-BOX
     SIZE 26.38 BY .75 NO-UNDO.

DEFINE VARIABLE we AS LOGICAL INITIAL yes
     LABEL "списание":L
     VIEW-AS TOGGLE-BOX
     SIZE 26.38 BY .75 NO-UNDO.

DEFINE VARIABLE wm AS LOGICAL INITIAL yes
     LABEL "списан. произв.":L
     VIEW-AS TOGGLE-BOX
     SIZE 26.38 BY .75 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     ie AT ROW 2.29 COL 38.38
     CostSum AT ROW 2.75 COL 2
     ee AT ROW 3.33 COL 38.38
     DispUpFact AT ROW 3.67 COL 2
     ep AT ROW 4.25 COL 38.38
     es AT ROW 5.17 COL 38.38
     re AT ROW 6.13 COL 38.38
     rs AT ROW 7 COL 38.38
     NullPer AT ROW 7.88 COL 2.38
     we AT ROW 7.92 COL 38.38
     vt AT ROW 8.71 COL 38.38
     iv AT ROW 9.71 COL 38.38
     CalcRest AT ROW 9.75 COL 2.38
     ev AT ROW 10.5 COL 38.38
     rv AT ROW 11.46 COL 38.38
     em AT ROW 12.29 COL 38.38
     wm AT ROW 13.13 COL 38.38
     im AT ROW 13.92 COL 38.38
     ot AT ROW 14.83 COL 38.38
     ap AT ROW 15.75 COL 38.38
     pc AT ROW 16.71 COL 38.38
     "Документы:" VIEW-AS TEXT
          SIZE 11 BY .75 AT ROW 1.42 COL 45.38
          FGCOLOR 4
     "Показать:" VIEW-AS TEXT
          SIZE 11 BY .75 AT ROW 1.42 COL 12
          FGCOLOR 4
     "Тип приобретения:" VIEW-AS TEXT
          SIZE 28.88 BY .67 AT ROW 11 COL 2
          FGCOLOR 4
     RECT-10 AT ROW 11.75 COL 1
     RECT-12 AT ROW 1.17 COL 1
     RECT-16 AT ROW 7.5 COL 1
     RECT-15 AT ROW 9.33 COL 1
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
         HEIGHT             = 16.58
         WIDTH              = 65.63.
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

/* SETTINGS FOR TOGGLE-BOX ap IN FRAME F-Main
   1                                                                    */
/* SETTINGS FOR TOGGLE-BOX ee IN FRAME F-Main
   1                                                                    */
/* SETTINGS FOR TOGGLE-BOX em IN FRAME F-Main
   1                                                                    */
/* SETTINGS FOR TOGGLE-BOX ep IN FRAME F-Main
   1                                                                    */
/* SETTINGS FOR TOGGLE-BOX es IN FRAME F-Main
   1                                                                    */
/* SETTINGS FOR TOGGLE-BOX ev IN FRAME F-Main
   1                                                                    */
/* SETTINGS FOR TOGGLE-BOX ie IN FRAME F-Main
   1                                                                    */
/* SETTINGS FOR TOGGLE-BOX im IN FRAME F-Main
   1                                                                    */
/* SETTINGS FOR TOGGLE-BOX iv IN FRAME F-Main
   1                                                                    */
/* SETTINGS FOR TOGGLE-BOX ot IN FRAME F-Main
   1                                                                    */
/* SETTINGS FOR TOGGLE-BOX pc IN FRAME F-Main
   1                                                                    */
/* SETTINGS FOR TOGGLE-BOX re IN FRAME F-Main
   1                                                                    */
/* SETTINGS FOR TOGGLE-BOX rs IN FRAME F-Main
   1                                                                    */
/* SETTINGS FOR TOGGLE-BOX rv IN FRAME F-Main
   1                                                                    */
/* SETTINGS FOR TOGGLE-BOX vt IN FRAME F-Main
   1                                                                    */
/* SETTINGS FOR TOGGLE-BOX we IN FRAME F-Main
   1                                                                    */
/* SETTINGS FOR TOGGLE-BOX wm IN FRAME F-Main
   1                                                                    */
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

&Scoped-define SELF-NAME ap
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ap s-object
ON VALUE-CHANGED OF ap IN FRAME F-Main /* переоценка */
DO:
  run calc-rest.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME ee
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ee s-object
ON VALUE-CHANGED OF ee IN FRAME F-Main /* расход внешний */
DO:
  run calc-rest.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME em
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL em s-object
ON VALUE-CHANGED OF em IN FRAME F-Main /* расход произв. */
DO:
  run calc-rest.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME ep
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ep s-object
ON VALUE-CHANGED OF ep IN FRAME F-Main /* возврат поставщику */
DO:
  run calc-rest.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME es
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL es s-object
ON VALUE-CHANGED OF es IN FRAME F-Main /* касса продажа */
DO:
    run calc-rest.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME ev
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ev s-object
ON VALUE-CHANGED OF ev IN FRAME F-Main /* расход перемещение */
DO:
  run calc-rest.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME ie
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ie s-object
ON VALUE-CHANGED OF ie IN FRAME F-Main /* приход внешний */
DO:
  run calc-rest.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME im
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL im s-object
ON VALUE-CHANGED OF im IN FRAME F-Main /* приход произв. */
DO:
  run calc-rest.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME iv
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL iv s-object
ON VALUE-CHANGED OF iv IN FRAME F-Main /* приход перемещение */
DO:
  run calc-rest.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME ot
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ot s-object
ON VALUE-CHANGED OF ot IN FRAME F-Main /* переоценка */
DO:
  run calc-rest.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME pc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL pc s-object
ON VALUE-CHANGED OF pc IN FRAME F-Main /* переоценка */
DO:
  run calc-rest.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME re
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL re s-object
ON VALUE-CHANGED OF re IN FRAME F-Main /* возврат внешний */
DO:
  run calc-rest.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME rs
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rs s-object
ON VALUE-CHANGED OF rs IN FRAME F-Main /* касса возврат */
DO:
  run calc-rest.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME rv
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rv s-object
ON VALUE-CHANGED OF rv IN FRAME F-Main /* возврат перемещение */
DO:
  run calc-rest.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME vt
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL vt s-object
ON VALUE-CHANGED OF vt IN FRAME F-Main /* инвентаризация */
DO:
    run calc-rest.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME we
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL we s-object
ON VALUE-CHANGED OF we IN FRAME F-Main /* списание */
DO:
  run calc-rest.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME wm
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL wm s-object
ON VALUE-CHANGED OF wm IN FRAME F-Main /* списан. произв. */
DO:
  run calc-rest.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK s-object


/* ***************************  Main Block  *************************** */
{ gbl/personly.i }
/* If testing in the UIB, initialize the SmartObject. */
&IF DEFINED(UIB_IS_RUNNING) <> 0 &THEN
  RUN dispatch IN THIS-PROCEDURE ('initialize':U).
&ENDIF
define variable  list-com-hand as character no-undo .
list-com-hand = "" .
&scop v-str        list-com-hand = list-com-hand + string(~{&v-tt}:handle) + "," .
&scop v-tt  ie
{&v-str}
&scop v-tt  ee
{&v-str}
&scop v-tt  ep
{&v-str}
&scop v-tt  es
{&v-str}
&scop v-tt  re
{&v-str}
&scop v-tt  rs
{&v-str}
&scop v-tt  we
{&v-str}
&scop v-tt  vt
{&v-str}
&scop v-tt  iv
{&v-str}
&scop v-tt  ev
{&v-str}
&scop v-tt  rv
{&v-str}
&scop v-tt  em
{&v-str}
&scop v-tt  wm
{&v-str}
&scop v-tt  im
{&v-str}
&scop v-tt  ot
{&v-str}
&scop v-tt  ap
{&v-str}
&scop v-tt  pc
{&v-str}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE calc-rest s-object
PROCEDURE calc-rest :
assign FRAME {&FRAME-NAME} {&list-tdedt}    .
if  ie
AND ee
AND  ep
AND  es
AND  re
AND  rs
AND  we
AND  vt
AND  iv
AND  ev
AND  rv
AND  em
AND  wm
AND  im
AND  ot
AND  ap
AND  pc
   then
    do:
        assign CalcRest = yes.
        DISPLAY CalcRest WITH FRAME {&FRAME-NAME}.
        ENABLE CalcRest WITH FRAME {&FRAME-NAME}.
    end.
else
    do:
        assign CalcRest = no.
        DISPLAY CalcRest WITH FRAME {&FRAME-NAME}.
        DISABLE CalcRest WITH FRAME {&FRAME-NAME}.
    end.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

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
  DISPLAY ie CostSum ee DispUpFact ep es re rs NullPer we vt iv CalcRest ev rv
          em wm im ot ap pc
      WITH FRAME F-Main.
  ENABLE RECT-10 RECT-12 RECT-16 RECT-15 ie CostSum ee DispUpFact ep es re rs
         NullPer we vt iv CalcRest ev rv em wm im ot ap pc
      WITH FRAME F-Main.
  {&OPEN-BROWSERS-IN-QUERY-F-Main}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-initialize s-object
PROCEDURE local-initialize :
/*------------------------------------------------------------------------------
  Purpose:     Override standard ADM method
  Notes:
------------------------------------------------------------------------------------------------------------------------------*/


  RUN dispatch IN THIS-PROCEDURE ( INPUT 'initialize':U ) .

  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_reports_lookup-cost':U
    {&cntxt-object}
    v-cntxt-host-code-obj
    v-cntxt-obj-type
    v-cntxt-obj-code
    0
    0
    0
    false
    g#log
  }
   if not  g#log then do :
   CostSum = false .
   DispUpFact = false .
   disable CostSum DispUpFact  with frame {&frame-name} .
   display CostSum  DispUpFact with frame {&frame-name} .
 end.

/* Проставим названия Документов на экране */
define variable lab-handle as handle no-undo .
define variable i as integer no-undo .
define variable v-code as character no-undo .

do i = 1 to num-entries (list-com-hand) :
 lab-handle = widget-handle (entry( i , list-com-hand) ) no-error .
 if valid-handle(lab-handle) = true and  error-status :error = false   then do:
    v-code = lab-handle:name.
    lab-handle:label = func-get-name-from-ext-type ( v-code, true  ) .
    end.
end.

run cr-ob (2 , 12 ,
  'Выкуп,Консигнация закупка,Консигнация выгода,Ответственное хранение,Старая консигнация ':L,
   {&aht-repayment} + "," + {&aht-cons_acc} + "," + {&aht-cons_benf} + "," + {&aht-resp_stor} + "," + {&aht-old_cons} ).

END PROCEDURE.
{ rep/tpcrr-b.i }

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-report s-object
PROCEDURE my-report :
/*------------------------------------------------------------------------------
  Purpose:     здесь происходит вызов  процедуры отчета с любыми параметрами
------------------------------------------------------------------------------*/
fOR EACH tdedt: DELETE tdedt. eND.
IF ie then  do:  { rep/r-mtdedt.i {&TDEDT_Pri_Vnesh}    01 }                      END.
IF ee then  do:  { rep/r-mtdedt.i {&TDEDT_Ras_Vnesh}    02 }                      END.
IF ep then  do:  { rep/r-mtdedt.i {&TDEDT_RAS_Vnesh_VP}  03}                END.
IF es then  do:  { rep/r-mtdedt.i {&TDEDT_Ras_Vnesh_Kass} 04 }            END.
IF re then  do:  { rep/r-mtdedt.i {&TDEDT_Vozvrat_Vnesh} 05 }              END.
IF rs then  do:  { rep/r-mtdedt.i {&TDEDT_Vozvrat_Vnesh_Kass} 06 }    END.
IF we then  do:  { rep/r-mtdedt.i {&TDEDT_Spi_Vnesh} 07 }                      END.
IF vt then  do:  { rep/r-mtdedt.i {&TDEDT_Inv} 08 }                                  END.
IF iv then  do:  { rep/r-mtdedt.i {&TDEDT_Pri_Perem} 09 }                      END.
IF ev then  do:  { rep/r-mtdedt.i {&TDEDT_Ras_Perem} 10 }                      END.
IF rv then  do:  { rep/r-mtdedt.i {&TDEDT_Vozvrat_Perem} 11 }              END.
IF em then  do:  { rep/r-mtdedt.i {&TDEDT_Ras_Prvo} 12 }                        END.
IF wm then  do:  { rep/r-mtdedt.i {&TDEDT_Spi_Prvo} 13 }                        END.
IF im then  do:  { rep/r-mtdedt.i {&TDEDT_Pri_Prvo} 14 }                        END.
IF ot then  do:  { rep/r-mtdedt.i {&TDEDT_Overturn} 15 }                        END.
IF ap then  do:  { rep/r-mtdedt.i {&TDEDT_Corr_Acc_Price} 16 }                  END.
IF pc then  do:  { rep/r-mtdedt.i {&TDEDT_Chg_Purch_Code} 17 }                  END.


 run rep/r-tprees.p
                 ( input type-pr:screen-value ,
                   input v-cntxt-obj-code ,
                   input v-cntxt-obj-type ,
                   input base-type ,
                   input base-code ,
                   input ?,
                   input ?,
                   input CostSum,
                   input DispUpFact  ,
                   input ?,
                   input ?,
                   input NullPer,
                   input CalcRest) .


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-var s-object
PROCEDURE my-var :
/*------------------------------------------------------------------------------
  Purpose:     здесь происходит вызов  значений переменных
  например  Название отчета, может быть еще пример шапки???
------------------------------------------------------------------------------*/
assign frame {&frame-name} {&list-tdedt}
 CostSum DispUpFact
 NullPer CalcRest.
 ReportNAme = "Р Е Е С Т Р   Д О К У М Е Н Т О В   П О   Т И П У   П Р И О Б Р Е Т Е Н И Я - "
 + Caps ( entry( (lookup(type-pr:screen-value ,type-pr:RADIO-BUTTONS) - 1), type-pr:RADIO-BUTTONS )   )
.


ReportHeader = IF CostSum     THEN CostSum:label + chr(10) Else "".
ReportHeader = (ReportHeader) + IF DispUpFact  THEN DispUpFact:label + chr(10) Else "" .
ReportHeader = (ReportHeader) + IF  NullPer    THEN NullPer:label + chr(10) Else "без нулевых остатков по переоценке" + chr(10) .
ReportHeader = (ReportHeader) + IF  CalcRest   THEN CalcRest:label + chr(10) Else ""  .
ReportHeader = (ReportHeader) + "документы : "  + chr(10).

ReportHeader = (ReportHeader)               + IF  ie THen      (ie:label) + ","  else " " .
ReportHeader = (ReportHeader)               + IF  ee then      (ee:label) + ","  else " ".
ReportHeader = (ReportHeader)               + IF  ep then      (ep:label) + ","  else " ".
ReportHeader = (ReportHeader)               + IF  es THen      (es:label) + ","  else " ".
ReportHeader = (ReportHeader)               + IF  re then      (re:label) + ","  else " ".
ReportHeader = (ReportHeader) +  chr(10).
ReportHeader = (ReportHeader)               + IF  rs then      (rs:label) + ","  else " ".
ReportHeader = (ReportHeader)               + IF  we THen      (we:label) + ","  else " ".
ReportHeader = (ReportHeader)               + IF  vt then      (vt:label) + ","  else " ".
ReportHeader = (ReportHeader)               + IF  iv then      (iv:label) + ","  else " ".
ReportHeader = (ReportHeader)               + IF  ev THen      (ev:label) + ","  else " ".
ReportHeader = (ReportHeader) +  chr(10).
ReportHeader = (ReportHeader)               + IF  rv then      (rv:label) + ","  else " ".
ReportHeader = (ReportHeader)               + IF  em then      (em:label) + ","  else " " .
ReportHeader = (ReportHeader)               + IF  wm THen      wm:label + ","  else " " .
ReportHeader = (ReportHeader)               + IF  im then      im:label + ","  else " ".
ReportHeader = (ReportHeader)               + IF  ap then      ap:label + ","  else " ".
ReportHeader = (ReportHeader)               + IF  pc then      pc:label + ","  else " ".
ReportHeader = (ReportHeader)               + IF  ot then      ot:label        else " " .

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