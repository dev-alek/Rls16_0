&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS s-object
/*
$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Товарный отчет по форме ОП-14

Автор: Чернова Светлана Александровна
Дата создания: 03/02/06
Author: Svetlana Chernova
Creation date: 03/02/06

Created: 20/10/00
*/

def var vss-revision    as character no-undo init "$Revision$":U .
def var vss-author      as character no-undo init "$Author$":U .
def var vss-date        as character no-undo init "$Date$":U .
def var vss-workfile    as character no-undo init "$Workfile$":U .
def var vss-archive     as character no-undo init "$Archive$":U .
def var vss-description as character no-undo init "Реестр документов (Товарный отчет)(закладка № 2)".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/r-page1.i  }
{ rep/rep-bt.i   }
{ rep/gn-extp.i  }
{ rep/par-actu.i }

CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

def var State-source as  WIDGET-HANDLE.
define variable g#log as logical   no-undo .
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE SmartObject

&Scoped-define ADM-SUPPORTED-LINKS Record-Source,Record-Target,TableIO-Target

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME F-Main

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS im em wm ie ep ee es iv re rs we ev rv
&Scoped-Define DISPLAYED-OBJECTS im em wm ie ep ee es iv re rs we ev rv

/* Custom List Definitions                                              */
/* list-tdedt,List-prihod,List-rashod,List-4,List-5,List-6              */
&Scoped-define list-tdedt im em wm ie ep ee es iv re rs we ev rv vt ot ap ~
pc
&Scoped-define List-prihod im ie ep iv

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */
DEFINE VARIABLE ap AS LOGICAL INITIAL yes
     LABEL "переоценка":L
     VIEW-AS TOGGLE-BOX
     size 26.38 by 0.75 NO-UNDO.

DEFINE VARIABLE ee AS LOGICAL INITIAL no
     LABEL "расход внешний":L
     VIEW-AS TOGGLE-BOX
     size 26.38 by 0.75 NO-UNDO.

DEFINE VARIABLE em AS LOGICAL INITIAL yes
     LABEL "расход произв.":L
     VIEW-AS TOGGLE-BOX
     size 26.38 by 0.75 NO-UNDO.

DEFINE VARIABLE ep AS LOGICAL INITIAL no
     LABEL "возврат поставщику"
     VIEW-AS TOGGLE-BOX
     size 26.38 by 0.75 NO-UNDO.

DEFINE VARIABLE es AS LOGICAL INITIAL no
     LABEL "касса продажа":L
     VIEW-AS TOGGLE-BOX
     size 26.38 by 0.75 NO-UNDO.

DEFINE VARIABLE ev AS LOGICAL INITIAL no
     LABEL "расход перемещение":L
     VIEW-AS TOGGLE-BOX
     size 26.38 by 0.75 NO-UNDO.

DEFINE VARIABLE ie AS LOGICAL INITIAL no
     LABEL "приход внешний":L
     VIEW-AS TOGGLE-BOX
     size 26.38 by 0.75 NO-UNDO.

DEFINE VARIABLE im AS LOGICAL INITIAL yes
     LABEL "приход произв.":L
     VIEW-AS TOGGLE-BOX
     size 26.38 by 0.75 NO-UNDO.

DEFINE VARIABLE iv AS LOGICAL INITIAL no
     LABEL "приход перемещение":L
     VIEW-AS TOGGLE-BOX
     size 26.38 by 0.75 NO-UNDO.

DEFINE VARIABLE ot AS LOGICAL INITIAL yes
     LABEL "переоценка":L
     VIEW-AS TOGGLE-BOX
     size 26.38 by 0.75 NO-UNDO.

DEFINE VARIABLE pc AS LOGICAL INITIAL yes
     LABEL "переоценка":L
     VIEW-AS TOGGLE-BOX
     size 26.38 by 0.75 NO-UNDO.

DEFINE VARIABLE re AS LOGICAL INITIAL no
     LABEL "возврат внешний":L
     VIEW-AS TOGGLE-BOX
     size 26.38 by 0.75 NO-UNDO.

DEFINE VARIABLE rs AS LOGICAL INITIAL no
     LABEL "касса возврат":L
     VIEW-AS TOGGLE-BOX
     size 26.38 by 0.75 NO-UNDO.

DEFINE VARIABLE rv AS LOGICAL INITIAL no
     LABEL "возврат перемещение":L
     VIEW-AS TOGGLE-BOX
     size 26.38 by 0.75 NO-UNDO.

DEFINE VARIABLE vt AS LOGICAL INITIAL yes
     LABEL "инвентаризация":L
     VIEW-AS TOGGLE-BOX
     size 26.38 by 0.75 NO-UNDO.

DEFINE VARIABLE we AS LOGICAL INITIAL no
     LABEL "списание":L
     VIEW-AS TOGGLE-BOX
     size 26.38 by 0.75 NO-UNDO.

DEFINE VARIABLE wm AS LOGICAL INITIAL yes
     LABEL "списан. произв.":L
     VIEW-AS TOGGLE-BOX
     size 26.38 by 0.75 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     im at row 3.28 col 3
     em at row 3.28 col 33.25
     wm at row 4.13 col 33.25
     ie at row 4.25 col 3
     ep at row 5.04 col 3
     ee at row 5.04 col 33.38
     es at row 5.83 col 33.13
     iv at row 5.92 col 3
     re at row 6.79 col 33.13
     rs at row 7.67 col 33.13
     we at row 8.58 col 33.13
     ev at row 9.28 col 33.13
     rv at row 10.33 col 33.13
     vt at row 13.29 col 33.88
     ot at row 14.25 col 33.5
     ap at row 15.17 col 33.5
     pc at row 16.13 col 33.5
     "ПРИХОД" VIEW-AS TEXT
          SIZE 6.88 BY .67 AT ROW 2.13 COL 9.88
          FGCOLOR 4
     "РАСХОД" VIEW-AS TEXT
          SIZE 6.5 BY .67 AT ROW 2.13 COL 39.75
          FGCOLOR 4
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


/* ***************  Runtime Attributes and UIB Settings  ************** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW s-object
  VISIBLE,,RUN-PERSISTENT                                               */
/* SETTINGS FOR FRAME F-Main
   NOT-VISIBLE Size-to-Fit                                              */
ASSIGN
       FRAME F-Main:SCROLLABLE       = FALSE
       FRAME F-Main:HIDDEN           = TRUE.

/* SETTINGS FOR TOGGLE-BOX ap IN FRAME F-Main
   NO-DISPLAY NO-ENABLE 1                                               */
ASSIGN
       ap:HIDDEN IN FRAME F-Main           = TRUE.

/* SETTINGS FOR TOGGLE-BOX ee IN FRAME F-Main
   1                                                                    */
/* SETTINGS FOR TOGGLE-BOX em IN FRAME F-Main
   1                                                                    */
/* SETTINGS FOR TOGGLE-BOX ep IN FRAME F-Main
   1 2                                                                  */
/* SETTINGS FOR TOGGLE-BOX es IN FRAME F-Main
   1                                                                    */
/* SETTINGS FOR TOGGLE-BOX ev IN FRAME F-Main
   1                                                                    */
/* SETTINGS FOR TOGGLE-BOX ie IN FRAME F-Main
   1 2                                                                  */
/* SETTINGS FOR TOGGLE-BOX im IN FRAME F-Main
   1 2                                                                  */
/* SETTINGS FOR TOGGLE-BOX iv IN FRAME F-Main
   1 2                                                                  */
/* SETTINGS FOR TOGGLE-BOX ot IN FRAME F-Main
   NO-DISPLAY NO-ENABLE 1                                               */
ASSIGN
       ot:HIDDEN IN FRAME F-Main           = TRUE.

/* SETTINGS FOR TOGGLE-BOX pc IN FRAME F-Main
   NO-DISPLAY NO-ENABLE 1                                               */
ASSIGN
       pc:HIDDEN IN FRAME F-Main           = TRUE.

/* SETTINGS FOR TOGGLE-BOX re IN FRAME F-Main
   1                                                                    */
/* SETTINGS FOR TOGGLE-BOX rs IN FRAME F-Main
   1                                                                    */
/* SETTINGS FOR TOGGLE-BOX rv IN FRAME F-Main
   1                                                                    */
/* SETTINGS FOR TOGGLE-BOX vt IN FRAME F-Main
   NO-DISPLAY NO-ENABLE 1                                               */
ASSIGN
       vt:HIDDEN IN FRAME F-Main           = TRUE.

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




&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _INCLUDED-LIB s-object
/* ************************* Included-Libraries *********************** */

{src/adm/method/viewer.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME ap
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ap s-object
ON VALUE-CHANGED OF ap IN FRAME F-Main /* переоценка */
DO:
  RUN calc-rest in this-procedure.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME ee
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ee s-object
ON VALUE-CHANGED OF ee IN FRAME F-Main /* расход внешний */
DO:
  RUN calc-rest in this-procedure.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME em
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL em s-object
ON VALUE-CHANGED OF em IN FRAME F-Main /* расход произв. */
DO:
  RUN calc-rest in this-procedure.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME ep
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ep s-object
ON VALUE-CHANGED OF ep IN FRAME F-Main /* возврат поставщику */
DO:
  RUN calc-rest in this-procedure.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME es
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL es s-object
ON VALUE-CHANGED OF es IN FRAME F-Main /* касса продажа */
DO:
    RUN calc-rest in this-procedure.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME ev
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ev s-object
ON VALUE-CHANGED OF ev IN FRAME F-Main /* расход перемещение */
DO:
  RUN calc-rest in this-procedure.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME ie
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ie s-object
ON VALUE-CHANGED OF ie IN FRAME F-Main /* приход внешний */
DO:
  RUN calc-rest in this-procedure.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME im
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL im s-object
ON VALUE-CHANGED OF im IN FRAME F-Main /* приход произв. */
DO:
  RUN calc-rest in this-procedure.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME iv
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL iv s-object
ON VALUE-CHANGED OF iv IN FRAME F-Main /* приход перемещение */
DO:
  RUN calc-rest in this-procedure.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME ot
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ot s-object
ON VALUE-CHANGED OF ot IN FRAME F-Main /* переоценка */
DO:
  RUN calc-rest in this-procedure.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME pc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL pc s-object
ON VALUE-CHANGED OF pc IN FRAME F-Main /* переоценка */
DO:
  RUN calc-rest in this-procedure.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME re
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL re s-object
ON VALUE-CHANGED OF re IN FRAME F-Main /* возврат внешний */
DO:
  RUN calc-rest in this-procedure.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME rs
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rs s-object
ON VALUE-CHANGED OF rs IN FRAME F-Main /* касса возврат */
DO:
  RUN calc-rest in this-procedure.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME rv
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rv s-object
ON VALUE-CHANGED OF rv IN FRAME F-Main /* возврат перемещение */
DO:
  RUN calc-rest in this-procedure.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME vt
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL vt s-object
ON VALUE-CHANGED OF vt IN FRAME F-Main /* инвентаризация */
DO:
    RUN calc-rest in this-procedure.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME we
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL we s-object
ON VALUE-CHANGED OF we IN FRAME F-Main /* списание */
DO:
  RUN calc-rest in this-procedure.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME wm
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL wm s-object
ON VALUE-CHANGED OF wm IN FRAME F-Main /* списан. произв. */
DO:
  RUN calc-rest in this-procedure.
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


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI s-object _DEFAULT-DISABLE
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


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI s-object _DEFAULT-ENABLE
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
  DISPLAY im em wm ie ep ee es iv re rs we ev rv
      WITH FRAME F-Main.
  ENABLE im em wm ie ep ee es iv re rs we ev rv
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

 end.

/* Проставим названия Документов на экране */
define variable lab-handle as handle no-undo .
define variable i as integer no-undo .
define variable v-code as character no-undo .
define variable v-nn as integer   no-undo .
v-nn = num-entries (list-com-hand) .
do i = 1 to v-nn :
 lab-handle = widget-handle (entry( i , list-com-hand) ) no-error .
 if valid-handle(lab-handle) = true and  error-status :error = false   then do:
    v-code = lab-handle:name.
    lab-handle:label = func-get-name-from-ext-type ( v-code, true  ) .
    end.
end.


END PROCEDURE.

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
IF iv then  do:  { rep/r-mtdedt.i {&TDEDT_Pri_Perem} 09 }                      END.
IF ev then  do:  { rep/r-mtdedt.i {&TDEDT_Ras_Perem} 10 }                      END.
IF rv then  do:  { rep/r-mtdedt.i {&TDEDT_Vozvrat_Perem} 11 }              END.
IF em then  do:  { rep/r-mtdedt.i {&TDEDT_Ras_Prvo} 12 }                        END.
IF wm then  do:  { rep/r-mtdedt.i {&TDEDT_Spi_Prvo} 13 }                        END.
IF im then  do:  { rep/r-mtdedt.i {&TDEDT_Pri_Prvo} 14 }                        END.
/*
IF vt then  do:  { rep/r-mtdedt.i {&TDEDT_Inv} 08 }                             END.
IF ot then  do:  { rep/r-mtdedt.i {&TDEDT_Overturn} 15 }                        END.
IF ap then  do:  { rep/r-mtdedt.i {&TDEDT_Corr_Acc_Price} 16 }                  END.
IF pc then  do:  { rep/r-mtdedt.i {&TDEDT_Chg_Purch_Code} 17 }                  END.
 */

 run rep/r-op14.p .

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

ReportHeader = "документы : "  + chr(10).

ReportHeader = (ReportHeader)               + IF  ie THen      (ie:label) + ","  else " " .
ReportHeader = (ReportHeader)               + IF  ee then      (ee:label) + ","  else " ".
ReportHeader = (ReportHeader)               + IF  ep then      (ep:label) + ","  else " ".
ReportHeader = (ReportHeader)               + IF  es THen      (es:label) + ","  else " ".
ReportHeader = (ReportHeader)               + IF  re then      (re:label) + ","  else " ".
ReportHeader = (ReportHeader) +  chr(10).
ReportHeader = (ReportHeader)               + IF  rs then      (rs:label) + ","  else " ".
ReportHeader = (ReportHeader)               + IF  we THen      (we:label) + ","  else " ".
ReportHeader = (ReportHeader)               + IF  iv then      (iv:label) + ","  else " ".
ReportHeader = (ReportHeader)               + IF  ev THen      (ev:label) + ","  else " ".
ReportHeader = (ReportHeader) +  chr(10).
ReportHeader = (ReportHeader)               + IF  rv then      (rv:label) + ","  else " ".
ReportHeader = (ReportHeader)               + IF  em then      (em:label) + ","  else " " .
ReportHeader = (ReportHeader)               + IF  wm THen      wm:label + ","  else " " .
ReportHeader = (ReportHeader)               + IF  im then      im:label + ","  else " ".

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