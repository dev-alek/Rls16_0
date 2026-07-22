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

Оборотная ведомость по одному типу

Автор: Чернова Светлана Александровна
Дата создания: 09/08/01
Author: Svetlana Chernova
Creation date: 09/08/01

*/

def var vss-revision    as character no-undo init "$Revision$":U .
def var vss-author      as character no-undo init "$Author$":U .
def var vss-date        as character no-undo init "$Date$":U .
def var vss-workfile    as character no-undo init "$Workfile$":U .
def var vss-archive     as character no-undo init "$Archive$":U .
def var vss-description as character no-undo init "Оборотная ведомость по 1 типу документа (закладка № 2)".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/r-page1.i  }
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
&Scoped-Define ENABLED-OBJECTS RECT-9 RECT-6 RECT-5 RECT-8 SortType Tog-obj ~
Classify COMBO-node ShowZero
&Scoped-Define DISPLAYED-OBJECTS SortType Tog-obj Classify COMBO-node ~
ShowZero SumsOnly

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */
DEFINE VARIABLE COMBO-node AS CHARACTER FORMAT "X(40)":U INITIAL "касса"
     LABEL "Типы документов"
     VIEW-AS COMBO-BOX INNER-LINES 6
     LIST-ITEMS "касса"
     DROP-DOWN-LIST
     SIZE 40.75 BY 1
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE var-lavel AS INTEGER FORMAT ">>9":U INITIAL 1
     VIEW-AS FILL-IN NATIVE
     SIZE 5 BY 1 NO-UNDO.

DEFINE VARIABLE Classify AS CHARACTER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Без классификации", "no-classify":U,
"Производители", "prod":U,
"Группы товаров", "grp-goods":U,
"Производители/Группы товаров", "prod/grp-goods":U,
"Группы товаров/Производители", "grp-goods/prod":U,
"Ставка НДС", "vat-ps":U
     SIZE 30.88 BY 6.29 NO-UNDO.

DEFINE VARIABLE SortType AS CHARACTER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "по коду", "sort-code":U,
"по артикулу", "sort-artic":U,
"по наименованию", "sort-name":U
     SIZE 19 BY 2.54 NO-UNDO.

DEFINE RECTANGLE RECT-5
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 44.5 BY 9.33.

DEFINE RECTANGLE RECT-6
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 22.5 BY 9.33.

DEFINE RECTANGLE RECT-8
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 67.75 BY 3.33.

DEFINE RECTANGLE RECT-9
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 67.75 BY 3.33.

DEFINE VARIABLE ShowZero AS LOGICAL INITIAL no
     LABEL "Нулевые остатки":L
     VIEW-AS TOGGLE-BOX
     SIZE 19 BY .83 NO-UNDO.

DEFINE VARIABLE SumsOnly AS LOGICAL INITIAL no
     LABEL "Только итоги"
     VIEW-AS TOGGLE-BOX
     SIZE 19 BY .83 NO-UNDO.

DEFINE VARIABLE Tog-lavel AS LOGICAL INITIAL no
     LABEL "с уровня":L
     VIEW-AS TOGGLE-BOX
     SIZE 12.63 BY 1 NO-UNDO.

DEFINE VARIABLE Tog-obj AS LOGICAL INITIAL yes
     LABEL "Раздельно по объектам":L
     VIEW-AS TOGGLE-BOX
     SIZE 31 BY 1 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     SortType AT ROW 2.5 COL 47.63 NO-LABEL
     Tog-obj AT ROW 2.54 COL 2.13
     Classify AT ROW 3.79 COL 2.13 NO-LABEL
     Tog-lavel AT ROW 5.96 COL 21.38
     var-lavel AT ROW 6 COL 32.63 COLON-ALIGNED NO-LABEL
     COMBO-node AT ROW 10.92 COL 5.88
     ShowZero AT ROW 15.54 COL 2.63
     SumsOnly AT ROW 16.42 COL 2.63
     "Сортировка товара :" VIEW-AS TEXT
          SIZE 19.38 BY .67 AT ROW 1.46 COL 47.63
          FGCOLOR 4
     "Классификация :" VIEW-AS TEXT
          SIZE 15 BY .75 AT ROW 1.46 COL 12
          FGCOLOR 4
     "Показать :" VIEW-AS TEXT
          SIZE 11.5 BY .75 AT ROW 14.29 COL 3.13
          FGCOLOR 4
     RECT-9 AT ROW 10.58 COL 1.63
     RECT-6 AT ROW 1.21 COL 46.75
     RECT-5 AT ROW 1.21 COL 1.75
     RECT-8 AT ROW 14.08 COL 1.75
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
/* SETTINGS FOR WINDOW s-object
  VISIBLE,,RUN-PERSISTENT                                               */
/* SETTINGS FOR FRAME F-Main
   NOT-VISIBLE Size-to-Fit                                              */
ASSIGN
       FRAME F-Main:SCROLLABLE       = FALSE
       FRAME F-Main:HIDDEN           = TRUE
       FRAME F-Main:PRIVATE-DATA     =
                "DLGCLOSE".

/* SETTINGS FOR COMBO-BOX COMBO-node IN FRAME F-Main
   ALIGN-L                                                              */
/* SETTINGS FOR TOGGLE-BOX SumsOnly IN FRAME F-Main
   NO-ENABLE                                                            */
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
    if Classify:screen-value  Begins "prod":U OR
       Classify:screen-value  Begins "grp-goods":U OR
       Classify:screen-value  Begins "vat-ps":U
        then
        enable SumsOnly with frame {&FRAME-NAME} .

   if Classify:screen-value = "no-classify":U
      Then do:
            SumsOnly = FALSE .
            display SumsOnly with frame {&FRAME-NAME} .
            disable SumsOnly with frame {&FRAME-NAME} .
        end.

   if Classify:screen-value = "grp-goods":U
         Then do:
            display TOG-lavel   with frame {&FRAME-NAME} .
            enable  TOG-lavel   with frame {&FRAME-NAME} .
        end.
         Else do:
            display  TOG-lavel  var-Lavel with frame {&FRAME-NAME} .
            disable  TOG-lavel  var-Lavel with frame {&FRAME-NAME} .
        end.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Tog-lavel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Tog-lavel s-object
ON VALUE-CHANGED OF Tog-lavel IN FRAME F-Main /* с уровня */
DO:

  if tog-lavel:screen-value="yes"
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
   Tog-obj:screen-value in frame {&frame-name} = 'yes'.
   var-lavel:screen-value in frame {&frame-name} = '1'.

    Combo-node:list-items = Combo-node:list-items + ',' + {&TDEDT_Ras_Vnesh_Kass-full}      .
    Combo-node:list-items = Combo-node:list-items + ',' + {&TDEDT_Vozvrat_Vnesh_Kass-full}  .

    Combo-node:list-items = Combo-node:list-items + ',' + {&TDEDT_Pri_Vnesh-full}           .
    Combo-node:list-items = Combo-node:list-items + ',' + {&TDEDT_Pri_Perem-full}           .
    Combo-node:list-items = Combo-node:list-items + ',' + {&TDEDT_Vozvrat_Vnesh-full}       .
    Combo-node:list-items = Combo-node:list-items + ',' + {&TDEDT_Vozvrat_Perem-full}       .
    Combo-node:list-items = Combo-node:list-items + ',' + {&TDEDT_Pri_Prvo-full}            .

    Combo-node:list-items = Combo-node:list-items + ',' + {&TDEDT_Ras_Vnesh-full}           .
    Combo-node:list-items = Combo-node:list-items + ',' + {&TDEDT_Ras_Vnesh_VP-full}        .
    Combo-node:list-items = Combo-node:list-items + ',' + {&TDEDT_Spi_Vnesh-full}           .
    Combo-node:list-items = Combo-node:list-items + ',' + {&TDEDT_Ras_Perem-full}           .
    Combo-node:list-items = Combo-node:list-items + ',' + {&TDEDT_Ras_Prvo-full}            .
    Combo-node:list-items = Combo-node:list-items + ',' + {&TDEDT_Spi_Prvo-full}            .

    Combo-node:list-items = Combo-node:list-items + ',' + {&TDEDT_Inv-full}                 .
    Combo-node:list-items = Combo-node:list-items + ',' + {&TDEDT_Overturn-full}            .
    Combo-node:list-items = Combo-node:list-items + ',' + {&TDEDT_Corr_Minus_Parts-full}            .
    Combo-node:list-items = Combo-node:list-items + ',' + {&TDEDT_Peresort-full}            .
    Combo-node:screen-value in frame {&frame-name} = 'касса'.

    display Combo-node  with frame {&FRAME-NAME} .


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-report s-object
PROCEDURE my-report :
/*------------------------------------------------------------------------------
  Purpose:     здесь происходит вызов  процедуры отчета с любыми параметрами
------------------------------------------------------------------------------*/


case SortType :
  when "sort-artic" then do:
    run proc-x in this-procedure .
  end.
  when "sort-code" then do:
    run proc-c in this-procedure .
  end.
  when "sort-name" then do:
    run proc-n in this-procedure .
  end.
end case.



END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-var s-object
PROCEDURE my-var :
/*------------------------------------------------------------------------------
  Purpose:     здесь происходит вызов  значений переменных
  например  Название отчета, может быть еще пример шапки ???
------------------------------------------------------------------------------*/
assign frame {&frame-name} SumsOnly ShowZero tog-obj
tog-lavel var-lavel COMBO-node Classify sorttype.
if x-SelectObject = {&obj-currency} and tog-obj = false then tog-obj = true .
/*строки в которых содержатся выбранные объекты */
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


ReportNAme = "О Т Ч Е Т   О   С О С Т О Я Н И И   З А П А С А   И   П Р О Д А Ж А Х   ( по одному типу документа)".
{ rep/claslabl.i }
ReportHeader = "Классификация : " + t-Class .
ReportHeader = ReportHeader +
               (if tog-lavel  then "    Итоги с уровня  "  + String(var-lavel)  else " "    ).
ReportHeader = ReportHeader  + " Тип документов : " + COMBO-node + chr(10).

ReportHeader = ReportHeader +
               "Сортировка " + t-Sort  + chr(10) +
               "Показать : " +
               (if SumsOnly     then "Только итоги, "  else " "            ) +
               (if ShowZero     then "Показывать нулевые остатки "  else "Не показывать нулевые остатки" ) .

            Case COMBO-node:
                when  {&TDEDT_Pri_Vnesh-full}             then   COMBO-node = {&TDEDT_Pri_Vnesh}          .
                when  {&TDEDT_Ras_Vnesh-full}             then   COMBO-node = {&TDEDT_Ras_Vnesh}          .
                when  {&TDEDT_Ras_Vnesh_VP-full}          then   COMBO-node = {&TDEDT_RAS_Vnesh_VP}       .
                when  {&TDEDT_Ras_Vnesh_Kass-full}        then   COMBO-node = {&TDEDT_Ras_Vnesh_Kass}     .
                when  {&TDEDT_Vozvrat_Vnesh-full}         then   COMBO-node = {&TDEDT_Vozvrat_Vnesh}      .
                when  {&TDEDT_Vozvrat_Vnesh_Kass-full}    then   COMBO-node = {&TDEDT_Vozvrat_Vnesh_Kass} .
                when  {&TDEDT_Spi_Vnesh-full}             then   COMBO-node = {&TDEDT_Spi_Vnesh}          .
                when  {&TDEDT_Inv-full}                   then   COMBO-node = {&TDEDT_Inv}                .
                when  {&TDEDT_Pri_Perem-full}             then   COMBO-node = {&TDEDT_Pri_Perem}          .
                when  {&TDEDT_Ras_Perem-full}             then   COMBO-node = {&TDEDT_Ras_Perem}          .
                when  {&TDEDT_Vozvrat_Perem-full}         then   COMBO-node = {&TDEDT_Vozvrat_Perem}       .
                when  {&TDEDT_Ras_Prvo-full}              then   COMBO-node = {&TDEDT_Ras_Prvo}            .
                when  {&TDEDT_Spi_Prvo-full}              then   COMBO-node = {&TDEDT_Spi_Prvo}            .
                when  {&TDEDT_Pri_Prvo-full}              then   COMBO-node = {&TDEDT_Pri_Prvo}            .
                when  {&TDEDT_Overturn-full}              then   COMBO-node = {&TDEDT_Overturn}            .
                when  {&TDEDT_Peresort-full}              then   COMBO-node = {&TDEDT_Peresort}            .
                when  {&TDEDT_Corr_Minus_Parts-full}              then   COMBO-node = {&TDEDT_Corr_Minus_Parts}            .
                when  'касса'                             then   COMBO-node = {&TDEDT_Vozvrat_Vnesh_Kass} + ',' + {&TDEDT_Ras_Vnesh_Kass}.
            End case.

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
      /* link-changed */
  END CASE.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-x W-Win
PROCEDURE proc-x :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
if tog-obj = true then DO:
   if lookup (classify,"no-classify,prod,grp-goods":u) > 0 then do:
      run rep/r-o-ex1y.p
                ( input v-cntxt-obj-code ,
                  input v-cntxt-obj-type ,
                  input base-type  ,
                  input base-code  ,
                  input classify:screen-value in frame {&frame-name} ,
                  input sorttype                                      ,
                  input sumsonly  ,
                  input showzero  ,
                  input combo-node ,
                  input tog-obj      ,
                  input tog-lavel,
                  input var-lavel ) .
   end.
   else do:
      run rep/r-o-ex2y.p
                ( input v-cntxt-obj-code ,
                  input v-cntxt-obj-type ,
                  input base-type  ,
                  input base-code  ,
                  input classify:screen-value in frame {&frame-name} ,
                  input sorttype:screen-value in frame {&frame-name} ,
                  input sumsonly  ,
                  input showzero  ,
                  input combo-node ,
                  input tog-obj      ,
                  input tog-lavel,
                  input var-lavel ) .
       end.

end.
else do:
   if lookup (classify,"no-classify,prod,grp-goods":u) > 0 then do:
      run rep/r-o-ex1n.p
                ( input v-cntxt-obj-code ,
                  input v-cntxt-obj-type ,
                  input base-type  ,
                  input base-code  ,
                  input classify:screen-value in frame {&frame-name} ,
                  input sorttype:screen-value in frame {&frame-name} ,
                  input sumsonly  ,
                  input showzero  ,
                  input combo-node ,
                  input tog-obj      ,
                  input tog-lavel,
                  input var-lavel ) . end.
   else do:
      run rep/r-o-ex2n.p
                ( input v-cntxt-obj-code ,
                  input v-cntxt-obj-type ,
                  input base-type  ,
                  input base-code  ,
                  input classify:screen-value in frame {&frame-name} ,
                  input sorttype:screen-value in frame {&frame-name} ,
                  input sumsonly  ,
                  input showzero  ,
                  input combo-node ,
                  input tog-obj      ,
                  input tog-lavel,
                  input var-lavel ) . end.

end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-c W-Win
PROCEDURE proc-c :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
if tog-obj = true then DO:
   if lookup (classify,"no-classify,prod,grp-goods":u) > 0 then do:
      run rep/r-o-ec1y.p
                ( input v-cntxt-obj-code ,
                  input v-cntxt-obj-type ,
                  input base-type  ,
                  input base-code  ,
                  input classify:screen-value in frame {&frame-name} ,
                  input sorttype                                      ,
                  input sumsonly  ,
                  input showzero  ,
                  input combo-node ,
                  input tog-obj      ,
                  input tog-lavel,
                  input var-lavel ) .
   end.
   else do:
      run rep/r-o-ec2y.p
                ( input v-cntxt-obj-code ,
                  input v-cntxt-obj-type ,
                  input base-type  ,
                  input base-code  ,
                  input classify:screen-value in frame {&frame-name} ,
                  input sorttype:screen-value in frame {&frame-name} ,
                  input sumsonly  ,
                  input showzero  ,
                  input combo-node ,
                  input tog-obj      ,
                  input tog-lavel,
                  input var-lavel ) .
       end.

end.
else do:
   if lookup (classify,"no-classify,prod,grp-goods":u) > 0 then do:
      run rep/r-o-ec1n.p
                ( input v-cntxt-obj-code ,
                  input v-cntxt-obj-type ,
                  input base-type  ,
                  input base-code  ,
                  input classify:screen-value in frame {&frame-name} ,
                  input sorttype:screen-value in frame {&frame-name} ,
                  input sumsonly  ,
                  input showzero  ,
                  input combo-node ,
                  input tog-obj      ,
                  input tog-lavel,
                  input var-lavel ) . end.
   else do:
      run rep/r-o-ec2n.p
                ( input v-cntxt-obj-code ,
                  input v-cntxt-obj-type ,
                  input base-type  ,
                  input base-code  ,
                  input classify:screen-value in frame {&frame-name} ,
                  input sorttype:screen-value in frame {&frame-name} ,
                  input sumsonly  ,
                  input showzero  ,
                  input combo-node ,
                  input tog-obj      ,
                  input tog-lavel,
                  input var-lavel ) . end.

end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-n W-Win
PROCEDURE proc-n :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
if tog-obj = true then DO:
   if lookup (classify,"no-classify,prod,grp-goods":u) > 0 then do:
      run rep/r-o-en1y.p
                ( input v-cntxt-obj-code ,
                  input v-cntxt-obj-type ,
                  input base-type  ,
                  input base-code  ,
                  input classify:screen-value in frame {&frame-name} ,
                  input sorttype                                      ,
                  input sumsonly  ,
                  input showzero  ,
                  input combo-node ,
                  input tog-obj      ,
                  input tog-lavel,
                  input var-lavel ) .
   end.
   else do:
      run rep/r-o-en2y.p
                ( input v-cntxt-obj-code ,
                  input v-cntxt-obj-type ,
                  input base-type  ,
                  input base-code  ,
                  input classify:screen-value in frame {&frame-name} ,
                  input sorttype:screen-value in frame {&frame-name} ,
                  input sumsonly  ,
                  input showzero  ,
                  input combo-node ,
                  input tog-obj      ,
                  input tog-lavel,
                  input var-lavel ) .
       end.

end.
else do:
   if lookup (classify,"no-classify,prod,grp-goods":u) > 0 then do:
      run rep/r-o-en1n.p
                ( input v-cntxt-obj-code ,
                  input v-cntxt-obj-type ,
                  input base-type  ,
                  input base-code  ,
                  input classify:screen-value in frame {&frame-name} ,
                  input sorttype:screen-value in frame {&frame-name} ,
                  input sumsonly  ,
                  input showzero  ,
                  input combo-node ,
                  input tog-obj      ,
                  input tog-lavel,
                  input var-lavel ) . end.
   else do:
      run rep/r-o-en2n.p
                ( input v-cntxt-obj-code ,
                  input v-cntxt-obj-type ,
                  input base-type  ,
                  input base-code  ,
                  input classify:screen-value in frame {&frame-name} ,
                  input sorttype:screen-value in frame {&frame-name} ,
                  input sumsonly  ,
                  input showzero  ,
                  input combo-node ,
                  input tog-obj      ,
                  input tog-lavel,
                  input var-lavel ) . end.

end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME