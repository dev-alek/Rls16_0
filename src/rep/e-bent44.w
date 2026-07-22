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

Отчет о реализации (EXCEL)

Автор: Демин Алексей Сергеевич
Дата создания: 09/14/05
Author: Alexey Demin
Creation date: 09/14/05

*/

def var vss-revision    as character no-undo init "$Revision$":U .
def var vss-author      as character no-undo init "$Author$":U .
def var vss-date        as character no-undo init "$Date$":U .
def var vss-workfile    as character no-undo init "$Workfile$":U .
def var vss-archive     as character no-undo init "$Archive$":U .
def var vss-description as character no-undo init "Отчет о реализации (EXCEL)".
{ cmp/vssrevis.i }


CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */
def var fo0    like ot-tot.fact-order no-undo.
def var fo02   like ot-tot.fact-order no-undo.
def var fo1    like ot-tot.fact-order no-undo.
def var fo12   like ot-tot.fact-order no-undo.
def var fo2    like ot-tot.fact-order no-undo.
def var fo22   like ot-tot.fact-order no-undo.
def var fo3    like ot-tot.fact-order no-undo.
def var fo32   like ot-tot.fact-order no-undo.
def var fo4    like ot-tot.fact-order no-undo.
def var fo42   like ot-tot.fact-order no-undo.
def var fo5    like ot-tot.fact-order no-undo.
def var fo52   like ot-tot.fact-order no-undo.

def var State-source as  WIDGET-HANDLE.
{ cmp/str-glbl.i }
{ cmp/r-page1.i }
{ rep/rep-bt.i  }

 &scop par-proc (input v-cntxt-obj-code,~
input v-cntxt-obj-type,~
input base-type, ~
input base-code, ~
input Classify, ~
input SortType, ~
input false, ~
input false, ~
input Tog-obj, ~
input tog-lavel, ~
input var-lavel, ~
input radio-set-1,~
input max-amount, ~
input max-amount-2,~
input min-sum, ~
input tog-kass,~
input tog-ras, ~
input tog-voz, ~
input fo1,~
input fo12, ~
input fo2,~
input fo22,~
input fo3,~
input fo32,~
input fo4,~
input fo42,~
input fo5,~
input fo52,~
input tog-1 ~
).

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
&Scoped-Define ENABLED-OBJECTS RECT-5 RECT-6 RECT-8 Tog-obj SortType ~
Classify RADIO-SET-1 tog-kass tog-ras tog-voz Tog-1 week-1 week-12 week-2 ~
week-22 week-3 week-32 week-4 week-42 week-5 week-52 
&Scoped-Define DISPLAYED-OBJECTS Tog-obj SortType Classify RADIO-SET-1 ~
tog-kass tog-ras tog-voz Tog-1 week-1 week-12 week-2 week-22 week-3 week-32 ~
week-4 week-42 week-5 week-52 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */
DEFINE VARIABLE max-amount AS INTEGER FORMAT ">>9":U INITIAL 20 
     VIEW-AS FILL-IN NATIVE 
     SIZE 5 BY 1 NO-UNDO.

DEFINE VARIABLE max-amount-2 AS INTEGER FORMAT ">>9":U INITIAL 20 
     VIEW-AS FILL-IN NATIVE 
     SIZE 5 BY 1 NO-UNDO.

DEFINE VARIABLE min-sum AS DECIMAL FORMAT "->,>>>,>>>,>>>,>>9.99":U INITIAL 0 
     VIEW-AS FILL-IN NATIVE 
     SIZE 12.5 BY 1 NO-UNDO.

DEFINE VARIABLE var-lavel AS INTEGER FORMAT ">>9":U INITIAL 1 
     VIEW-AS FILL-IN NATIVE 
     SIZE 5 BY 1 NO-UNDO.

DEFINE VARIABLE week-1 AS DATE FORMAT "99/99/9999":U 
     LABEL "Неделя 1 с" 
     VIEW-AS FILL-IN NATIVE 
     SIZE 11 BY 1 NO-UNDO.

DEFINE VARIABLE week-12 AS DATE FORMAT "99/99/9999":U 
     LABEL "по" 
     VIEW-AS FILL-IN NATIVE 
     SIZE 11 BY 1 NO-UNDO.

DEFINE VARIABLE week-2 AS DATE FORMAT "99/99/9999":U 
     LABEL "Неделя 2 с" 
     VIEW-AS FILL-IN NATIVE 
     SIZE 11 BY 1 NO-UNDO.

DEFINE VARIABLE week-22 AS DATE FORMAT "99/99/9999":U 
     LABEL "по" 
     VIEW-AS FILL-IN NATIVE 
     SIZE 11 BY 1 NO-UNDO.

DEFINE VARIABLE week-3 AS DATE FORMAT "99/99/9999":U 
     LABEL "Неделя 3 с" 
     VIEW-AS FILL-IN NATIVE 
     SIZE 11 BY 1 NO-UNDO.

DEFINE VARIABLE week-32 AS DATE FORMAT "99/99/9999":U 
     LABEL "по" 
     VIEW-AS FILL-IN NATIVE 
     SIZE 11 BY 1 NO-UNDO.

DEFINE VARIABLE week-4 AS DATE FORMAT "99/99/9999":U 
     LABEL "Неделя 4 c" 
     VIEW-AS FILL-IN NATIVE 
     SIZE 11 BY 1 NO-UNDO.

DEFINE VARIABLE week-42 AS DATE FORMAT "99/99/9999":U 
     LABEL "по" 
     VIEW-AS FILL-IN NATIVE 
     SIZE 11 BY 1 NO-UNDO.

DEFINE VARIABLE week-5 AS DATE FORMAT "99/99/9999":U 
     LABEL "Неделя 5 с" 
     VIEW-AS FILL-IN NATIVE 
     SIZE 11 BY 1 NO-UNDO.

DEFINE VARIABLE week-52 AS DATE FORMAT "99/99/9999":U 
     LABEL "по" 
     VIEW-AS FILL-IN NATIVE 
     SIZE 11 BY 1 NO-UNDO.

DEFINE VARIABLE Classify AS CHARACTER 
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS 
          "Без классификации", "no-classify":U,
"Группы товаров", "grp-goods":U
     SIZE 30.88 BY 1.67
     FGCOLOR 0  NO-UNDO.

DEFINE VARIABLE RADIO-SET-1 AS INTEGER INITIAL 1 
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS 
          "все", 1,
"Показать с MAX реализацией", 2,
"Показать с MIN реализацией", 3
     SIZE 29.13 BY 3.04 NO-UNDO.

DEFINE VARIABLE SortType AS CHARACTER 
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS 
          "по коду", "sort-code":U,
"по артикулу", "sort-artic":U,
"по реализации", "sort-qunty":U,
"по наименованию", "sort-name":U
     SIZE 20.75 BY 3.88
     FGCOLOR 0  NO-UNDO.

DEFINE RECTANGLE RECT-5
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 43.75 BY 8.96.

DEFINE RECTANGLE RECT-6
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 23.13 BY 8.92.

DEFINE RECTANGLE RECT-8
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 67.75 BY 7.21.

DEFINE VARIABLE Tog-1 AS LOGICAL INITIAL yes 
     LABEL "Понедельная расшифровка" 
     VIEW-AS TOGGLE-BOX
     SIZE 28.63 BY .83 NO-UNDO.

DEFINE VARIABLE tog-kass AS LOGICAL INITIAL yes 
     LABEL "Касса" 
     VIEW-AS TOGGLE-BOX
     SIZE 19 BY .83 NO-UNDO.

DEFINE VARIABLE Tog-lavel AS LOGICAL INITIAL no 
     LABEL "с уровня":L 
     VIEW-AS TOGGLE-BOX
     SIZE 12.63 BY 1
     FGCOLOR 0  NO-UNDO.

DEFINE VARIABLE Tog-obj AS LOGICAL INITIAL yes 
     LABEL "Раздельно по объектам":L 
     VIEW-AS TOGGLE-BOX
     SIZE 31 BY 1
     FGCOLOR 0  NO-UNDO.

DEFINE VARIABLE tog-ras AS LOGICAL INITIAL yes 
     LABEL "Расход внешний" 
     VIEW-AS TOGGLE-BOX
     SIZE 19 BY .83
     FGCOLOR 0  NO-UNDO.

DEFINE VARIABLE tog-voz AS LOGICAL INITIAL yes 
     LABEL "Возврат внешний" 
     VIEW-AS TOGGLE-BOX
     SIZE 19 BY .83
     FGCOLOR 0  NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     Tog-obj AT ROW 2.13 COL 2.38
     SortType AT ROW 2.5 COL 47.63 NO-LABEL
     Classify AT ROW 3.17 COL 2 NO-LABEL
     Tog-lavel AT ROW 3.96 COL 19.25
     var-lavel AT ROW 3.96 COL 30.5 COLON-ALIGNED NO-LABEL
     RADIO-SET-1 AT ROW 5.92 COL 2.63 NO-LABEL
     max-amount AT ROW 6.92 COL 29.63 COLON-ALIGNED NO-LABEL
     tog-kass AT ROW 7.33 COL 47.5
     tog-ras AT ROW 8.13 COL 47.5
     max-amount-2 AT ROW 8.88 COL 6.38 COLON-ALIGNED NO-LABEL
     min-sum AT ROW 8.88 COL 26 COLON-ALIGNED NO-LABEL
     tog-voz AT ROW 8.88 COL 47.5
     Tog-1 AT ROW 10.63 COL 3.25
     week-1 AT ROW 11.83 COL 38.13 COLON-ALIGNED
     week-12 AT ROW 11.88 COL 55.13 COLON-ALIGNED
     week-2 AT ROW 12.88 COL 38.13 COLON-ALIGNED
     week-22 AT ROW 12.92 COL 55.13 COLON-ALIGNED
     week-3 AT ROW 13.92 COL 38.13 COLON-ALIGNED
     week-32 AT ROW 13.96 COL 55.13 COLON-ALIGNED
     week-4 AT ROW 14.88 COL 38.13 COLON-ALIGNED
     week-42 AT ROW 14.92 COL 55.13 COLON-ALIGNED
     week-5 AT ROW 15.96 COL 38.13 COLON-ALIGNED
     week-52 AT ROW 16 COL 55.13 COLON-ALIGNED
     "товаров,но >=" VIEW-AS TEXT
          SIZE 13.5 BY 1 AT ROW 8.88 COL 13.88
     "Сортировка :":C20 VIEW-AS TEXT
          SIZE 20.63 BY .75 AT ROW 1.46 COL 47.63
          FGCOLOR 4 
     "Показать :" VIEW-AS TEXT
          SIZE 11.5 BY .75 AT ROW 4.88 COL 2.63
          FGCOLOR 4 
     "Виды продаж :":C20 VIEW-AS TEXT
          SIZE 20.75 BY .67 AT ROW 6.54 COL 47.63
          FGCOLOR 4 
     "товаров" VIEW-AS TEXT
          SIZE 8 BY 1 AT ROW 6.92 COL 37.13
     "Классификация :" VIEW-AS TEXT
          SIZE 15 BY .75 AT ROW 1.46 COL 12
          FGCOLOR 4 
     "Интервалы просмотра реализации:" VIEW-AS TEXT
          SIZE 32.75 BY .67 AT ROW 10.5 COL 34.75
          FGCOLOR 4 
     "" VIEW-AS TEXT
          SIZE 3.75 BY 1 AT ROW 8.88 COL 41.25
     RECT-5 AT ROW 1.21 COL 1.75
     RECT-6 AT ROW 1.21 COL 46.13
     RECT-8 AT ROW 10.21 COL 1.75
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
         WIDTH              = 68.63.
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
/* SETTINGS FOR FRAME F-Main
   NOT-VISIBLE FRAME-NAME Size-to-Fit                                   */
ASSIGN 
       FRAME F-Main:SCROLLABLE       = FALSE
       FRAME F-Main:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN max-amount IN FRAME F-Main
   NO-DISPLAY NO-ENABLE                                                 */
/* SETTINGS FOR FILL-IN max-amount-2 IN FRAME F-Main
   NO-DISPLAY NO-ENABLE                                                 */
/* SETTINGS FOR FILL-IN min-sum IN FRAME F-Main
   NO-DISPLAY NO-ENABLE                                                 */
/* SETTINGS FOR TOGGLE-BOX Tog-lavel IN FRAME F-Main
   NO-DISPLAY NO-ENABLE                                                 */
/* SETTINGS FOR FILL-IN var-lavel IN FRAME F-Main
   NO-DISPLAY NO-ENABLE                                                 */
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

&Scoped-define SELF-NAME Classify
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Classify s-object
ON VALUE-CHANGED OF Classify IN FRAME F-Main
DO:
  Assign Classify.
   if Classify = "grp-goods":U
         Then do:
            display TOG-lavel   with frame {&FRAME-NAME} .
            enable  TOG-lavel   with frame {&FRAME-NAME} .
        end.
         Else do:
            TOG-lavel = false.
            display  TOG-lavel  var-Lavel with frame {&FRAME-NAME} .
            disable  TOG-lavel  var-Lavel with frame {&FRAME-NAME} .
        end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME RADIO-SET-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL RADIO-SET-1 s-object
ON VALUE-CHANGED OF RADIO-SET-1 IN FRAME F-Main
DO:
  Assign radio-set-1.
  case radio-set-1 :
  when 1 then DO:
          disable max-amount max-amount-2 min-sum with frame {&frame-name} .
         end.
  when 2 then DO:
          enable max-amount with frame {&frame-name} .
          disable max-amount-2 min-sum with frame {&frame-name} .
         end.
  when 3 then DO:
          disable max-amount with frame {&frame-name} .
          enable max-amount-2 min-sum with frame {&frame-name} .
           end.
  End case.
     display max-amount max-amount-2 min-sum with frame {&frame-name} .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Tog-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Tog-1 s-object
ON VALUE-CHANGED OF Tog-1 IN FRAME F-Main /* Понедельная расшифровка */
DO:
  assign tog-1 .
  if tog-1 then
  enable week-1 week-12 week-2 week-22 week-3 week-32 week-4 week-42 week-5 week-52 with frame {&frame-name}.
  else
  disable week-1 week-12 week-2 week-22 week-3 week-32 week-4 week-42 week-5 week-52 with frame {&frame-name}.
  display week-1 week-12 week-2 week-22 week-3 week-32 week-4 week-42 week-5 week-52 with frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Tog-lavel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Tog-lavel s-object
ON VALUE-CHANGED OF Tog-lavel IN FRAME F-Main /* с уровня */
DO:
  Assign tog-lavel.
  if tog-lavel =TRUE
        Then do:
            display  var-Lavel  with frame {&FRAME-NAME} .
            enable   var-Lavel  with frame {&FRAME-NAME} .
        end.
         Else do:
            display    var-Lavel with frame {&FRAME-NAME} .
            disable    var-Lavel with frame {&FRAME-NAME} .
        end.

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


{ gbl/ed_date.i week-1 }.
{ gbl/ed_date.i week-12}.
{ gbl/ed_date.i week-2 } .
{ gbl/ed_date.i week-22}.
{ gbl/ed_date.i week-3 } .
{ gbl/ed_date.i week-32}.
{ gbl/ed_date.i week-4 }  .

{ gbl/ed_date.i week-42} .
/*{ gbl/ed_date.i week-5 }  .
{ gbl/ed_date.i week-52} .
  */

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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE find-fo s-object 
PROCEDURE find-fo :
def input  parameter date1 as date no-undo.
def input  parameter date2 as date no-undo.
def output parameter f-1   like ot-line.fact-order no-undo.
def output parameter f-2   like ot-line.fact-order no-undo.

   Assign f-1 = Integer(date1 - 1 ) + 0.99  f-2 = Integer(date2) + 0.99 .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-initialize s-object 
PROCEDURE local-initialize :
/*------------------------------------------------------------------------------
  Purpose:     Override standard ADM method
  Notes:
------------------------------------------------------------------------------*/

  /* Code placed here will execute PRIOR to standard behavior. */

  /* Dispatch standard ADM method.                             */
  RUN dispatch IN THIS-PROCEDURE ( INPUT 'initialize':U ) .

  /* Code placed here will execute AFTER standard behavior.    */
   disable max-amount-2 min-sum with frame {&frame-name} .
   RAdio-set-1:screen-value      in frame {&frame-name} = '1'.
   Tog-obj:screen-value      in frame {&frame-name} = 'yes'.
   Tog-1:screen-value      in frame {&frame-name} = 'yes'.
   Tog-kass:screen-value      in frame {&frame-name} = 'yes'.
   Tog-ras:screen-value      in frame {&frame-name} = 'yes'.
   Tog-voz:screen-value      in frame {&frame-name} = 'yes'.
   Tog-lavel:screen-value      in frame {&frame-name} = 'no'.
   var-lavel:screen-value    in frame {&frame-name} = '1'.
   min-sum:screen-value      in frame {&frame-name} = '0'.
   max-amount:screen-value   in frame {&frame-name} = '20'.
   max-amount-2:screen-value in frame {&frame-name} = '20'.
   max-amount   = 20.
   max-amount-2 = 20.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-report s-object 
PROCEDURE my-report :
/*------------------------------------------------------------------------------
  Purpose:     здесь происходит вызов  процедуры отчета с любыми параметрами
------------------------------------------------------------------------------*/
if tog-obj = true  then do:
      run cus/r-benet4.p {&par-proc} .
end.

Else do:
        run cus/r-bene4n.p {&par-proc} .

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
def var M as int no-undo.

  define variable v-check-date as date      no-undo .
  define variable v-archive-ok as logical   no-undo .
  define variable v-comment    as character no-undo .
  define variable v-can-print  as logical   no-undo .

assign frame {&frame-name}
tog-obj tog-lavel var-lavel tog-1
Classify SortType
max-amount
max-amount-2
min-sum
tog-kass
tog-ras
tog-voz
radio-set-1
week-1
week-12
week-2
week-22
week-3
week-32
week-4
week-42
week-5
week-52
.
if
week-1  = ? OR
week-12 = ? OR
week-2  = ? OR
week-22 = ? OR
week-3  = ? OR
week-32 = ? OR
week-4  = ? OR
week-42 = ? OR
week-5  = ? OR
week-52 = ?  THEN DO:
     MEssage 'Не заданы интервалы просмотра реализации ! ' view-as alert-box error.
     RETURN 'Second-page':U  . End.


/* строки в которых содержатся выбранные объекты */
Assign
 STR-obj-type = ''
 STR-obj-code = ''
 STR-obj-name = ''
 STR-obj      = ''.

For each obj-list no-lock:
 Assign
 STR-obj-type = STR-obj-type + obj-list.obj-type + ','
 STR-obj-code = STR-obj-code + String(obj-list.obj-code) + ','
 STR-obj-name = STR-obj-name + obj-list.obj-name + ','
 STR-obj = STR-obj +  obj-list.obj-type + '#' + string(obj-list.obj-code)  + ',' .
End.


ReportNAme = "О Т Ч Е Т   П О   Р Е А Л И З А Ц И И   В  М А Г А З И Н Е".
{ rep/claslabl.i }
ReportHeader = "Классификация : " + t-Class.
ReportHeader = ReportHeader +
               (if tog-lavel  then "    Итоги с уровня  "  + String(var-lavel)  else " "    ).
ReportHeader = ReportHeader + chr(10) +
               "Сортировка " + (t-Sort)  + chr(10) .

case radio-set-1 :
When 2 then
    ReportHeader = ReportHeader + string(max-amount) + ' с наибольшей реализацией ' + chr(10).
When 3 then
    ReportHeader = ReportHeader + string(max-amount-2) + ' с наименьшей реализацией, но большей ' + string(min-sum) + ' {&abbr_rub}.' + chr(10).
End case.

ReportHeader = ReportHeader +
               "Виды продаж : " + if (tog-kass) then {&TDEDT_Ras_Vnesh_Kass-full} Else ""   .
ReportHeader = ReportHeader +  " , " +
                if (tog-ras) then {&TDEDT_Ras_Vnesh-full} Else ""   .
ReportHeader = ReportHeader +  " , " +
                if (tog-voz) then {&TDEDT_Vozvrat_Vnesh-full} Else ""   .
   if tog-1 then DO:
    ReportHeader = ReportHeader  + chr(10) + if week-1  <> DATE('')   THEN  " 1я неделя " + String(week-1,"99/99/9999")          ELSE ""  .
    ReportHeader = ReportHeader  + if week-12 <> DATE('')   THEN  " по " + String(week-12,"99/99/9999")      + chr(10) ELSE ""  .
    ReportHeader = ReportHeader  + if week-2  <> DATE('')   THEN  " 2я неделя " + String(week-2,"99/99/9999")          ELSE ""  .
    ReportHeader = ReportHeader  + if week-22 <> DATE('')   THEN  " по " + String(week-22,"99/99/9999")      + chr(10) ELSE ""  .
    ReportHeader = ReportHeader  + if week-3  <> DATE('')   THEN  " 3я неделя " + String(week-3,"99/99/9999")          ELSE ""  .
    ReportHeader = ReportHeader  + if week-32 <> DATE('')   THEN  " по " + String(week-32,"99/99/9999")      + chr(10) ELSE ""  .
    ReportHeader = ReportHeader  + if week-4  <> DATE('')   THEN  " 4я неделя " + String(week-4,"99/99/9999")          ELSE ""  .
    ReportHeader = ReportHeader  + if week-42 <> DATE('')   THEN  " по " + String(week-42,"99/99/9999")      + chr(10) ELSE ""  .
    ReportHeader = ReportHeader  + if week-5  <> DATE('')   THEN  " 5я неделя " + String(week-5,"99/99/9999")          ELSE ""  .
    ReportHeader = ReportHeader  + if week-52 <> DATE('')   THEN  " по " + String(week-52,"99/99/9999")      + chr(10) ELSE "" .

  assign
    v-check-date = maximum( week-1  ,
                      week-12 ,
                      week-2  ,
                      week-22 ,
                      week-3  ,
                      week-32 ,
                      week-4  ,
                      week-42 ,
                      week-5  ,
                      week-52 )
  .

  for each obj-list no-lock
  :
    run rep/chk-ahz.p
      (input        obj-list.obj-type /* p-obj-type          */
      ,input        obj-list.obj-code /* p-obj-code          */
      ,input        true              /* p-verify-detail     */
      ,input        true              /* p-verify-arh        */
      ,input        false             /* p-verify-ahsp       */
      ,input        false             /* p-verify-aht        */
      ,input        true              /* p-check-act         */
      ,input        v-cntxt-db-num    /* p-check-act-db-num  */
      ,input        v-cntxt-userid    /* p-check-act-user-id */
      ,input-output v-check-date      /* p-date-start        */
      ,input-output v-check-date      /* p-date-end          */
      ,output       v-archive-ok      /* p-archive-ok        */
      ,output       v-comment         /* p-comment           */
      ,output       v-can-print       /* p-can-print         */
      ) .
  end.

  run find-fo in this-procedure
    (input  week-1
    ,input  week-12
    ,output fo1
    ,output fo12
    ).
  run find-fo in this-procedure
    (input  week-2
    ,input  week-22
    ,output fo2
    ,output fo22
    ).
  run find-fo in this-procedure
    (input  week-3
    ,input  week-32
    ,output fo3
    ,output fo32
    ).
  run find-fo in this-procedure
    (input  week-4
    ,input  week-42
    ,output fo4
    ,output fo42
    ).
  run find-fo in this-procedure
    (input  week-5
    ,input  week-52
    ,output fo5
    ,output fo52
    ).

 sheetf.Excel-Column-Lable = "Артикул,Наименование,Процент (%),Реализация,,Среднесут.реализация,, " +
 "Реализация 1 неделя " + ",," +
 "Реализация 2 неделя " + ",," +
 "Реализация 3 неделя " + ",," +
 "Реализация 4 неделя " + ",," +
 "Реализация 5 неделя " + ",," +
 chr(10) .

 sheetf.Excel-Column-Lable = sheetf.Excel-Column-Lable + ",,,Количество,Сумма,Количество,Сумма" +
   ",Количество,Сумма" +
   ",Количество,Сумма" +
   ",Количество,Сумма" +
   ",Количество,Сумма" +
   ",Количество,Сумма" .

 sheetf.Sizes = '16,60,12,13,13,13,13,13,13,13,13,13,13,13,13,13,13,' .
 End.
 Else DO:
 sheetf.Excel-Column-Lable = "Артикул,Наименование,Процент (%),Реализация,,Среднесут.реализация,, " +
 chr(10) .

 sheetf.Excel-Column-Lable = sheetf.Excel-Column-Lable + ",,,Количество,Сумма,Количество,Сумма" .

 sheetf.Sizes = '16,60,12,13,13,13,13,' .

 End.
 str2=''.
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
  def var month-1 as date no-undo .
  def var month-2 as date no-undo .
  def var nn as int no-undo.
  def var ret# as log no-undo.

  CASE p-state:
      /* Object instance CASEs can go here to replace standard behavior
         or add new cases. */
    when "link-changed" then  DO:
         End.

  END CASE.
  if month-1 = ? THEN   month-1 = DAte(month(x-Date-Start ),1,year(x-Date-Start )).
if month-2 = ? THEN   DO:
    month-2 = x-Date-Start  .
    run gbl/lastdate.p
      (input  month-2
      ,output month-2  ).
    End.
NN = Weekday(DAte(month(month-1 ),1,year(month-1)))  . /*ближайший понедельник*/

if week-1  = ? THEN   week-1  = month-1 + (2 - NN)                             .
if week-12 = ? THEN   week-12 = week-1 +  6                                  .
if week-2  = ? THEN   week-2  = week-12 + 1                                  .
if week-22 = ? THEN   week-22 = week-2  + 6                                  .
if week-3  = ? THEN   week-3  = week-22 + 1                                  .
if week-32 = ? THEN   week-32 = week-3  + 6                                  .
if week-4  = ? THEN   week-4  = week-32 + 1                                  .
if week-42 = ? THEN   week-42 = week-4  + 6                                  .
if week-5  = ? THEN   week-5  = week-42 + 1                                  .
if week-52 = ? THEN   week-52 = week-5 + 6                                   .

if date(week-1:screen-value in frame {&frame-name}) <> ? then
 assign frame {&frame-name}
week-1
week-12
week-2
week-22
week-3
week-32
week-4
week-42
week-5
week-52
.

display  week-1 week-12 week-2 week-22 week-3 week-32 week-4 week-42 week-5 week-52 with frame {&frame-name}.



END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

