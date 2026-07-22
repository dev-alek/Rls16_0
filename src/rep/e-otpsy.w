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

Оборотная ведомость отчет ТПСИ (по типу приобретения )

Автор: Чернова Светлана Александровна
Дата создания: 03/02/06
Author: Svetlana Chernova
Creation date: 03/02/06

Creation date: 11/20/02 3:00

*/
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init " Оборотная ведомость отчет ТПСИ (по типу приобретения )   ".
DEFINE VARIABLE  type-pr  AS WIDGET-HANDLE.
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/r-page1.i }
{ gbl/waitfram.i }
{ cmp/gds-list.i gds-list-my   def }
{ cmp/gds-list.i gds-list-nomy def }
{ rep/rep-bt.i }
define variable v-log as logical   no-undo .
CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

define variable State-source as  WIDGET-HANDLE.


&scop run-param    ( input type-pr:screen-value , input v-cntxt-obj-code , input v-cntxt-obj-type , input base-type  , input base-code  ,input Classify ,input SortType ,~
                    input SumsOnly  ,  input ShowZero  ,  input ShowZero-2 , input tog-obj    ,input tog-lavel,input var-lavel,~
                    input vat-cost, input vat-crsa , input vat-sale , input true , input r-gds ) .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE SmartObject

&Scoped-define ADM-SUPPORTED-LINKS   Record-Source,Record-Target,TableIO-Target

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME F-Main

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS RECT-6 RECT-8 RECT-9 RECT-5 Tog-obj Classify ~
r-gds ShowZero-2 VAT-Cost ShowZero VAT-CRSA VAT-sale SortType
&Scoped-Define DISPLAYED-OBJECTS Tog-obj Classify r-gds ShowZero-2 VAT-Cost ~
ShowZero VAT-CRSA SumsOnly VAT-sale SortType

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */
&Scoped-define List-6 r-gds VAT-Cost VAT-CRSA VAT-sale

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */
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
     size 32 by 5.67 NO-UNDO.

DEFINE VARIABLE r-gds AS INTEGER INITIAL 1
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Все товары", 2,
"Только свои", 3
     SIZE 35.38 BY .88 NO-UNDO.

DEFINE VARIABLE SortType AS CHARACTER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "по коду", "sort-code":U,
"по артикулу", "sort-artic":U,
"по наимен.", "sort-name":U
     size 16.88 by 1.96 NO-UNDO.

DEFINE RECTANGLE RECT-5
     edge-chars 0.25 GRAPHIC-EDGE  NO-FILL
     SIZE 47.63 BY 8.63.

DEFINE RECTANGLE RECT-6
     edge-chars 0.25 GRAPHIC-EDGE  NO-FILL
     SIZE 47.63 BY 3.13.

DEFINE RECTANGLE RECT-8
     edge-chars 0.25 GRAPHIC-EDGE  NO-FILL
     SIZE 47.63 BY 4.38.

DEFINE RECTANGLE RECT-9
     edge-chars 0.25 GRAPHIC-EDGE  NO-FILL
     SIZE 30.63 BY 17.08.

DEFINE VARIABLE ShowZero AS LOGICAL INITIAL no
     LABEL "Нулевые остатки":L
     VIEW-AS TOGGLE-BOX
     size 19 by 0.83 NO-UNDO.

DEFINE VARIABLE ShowZero-2 AS LOGICAL INITIAL no
     LABEL "Нулевые обороты":L
     VIEW-AS TOGGLE-BOX
     size 19 by 0.83 NO-UNDO.

DEFINE VARIABLE SumsOnly AS LOGICAL INITIAL no
     LABEL "Только итоги":L
     VIEW-AS TOGGLE-BOX
     SIZE 19 BY .83 NO-UNDO.

DEFINE VARIABLE Tog-lavel AS LOGICAL INITIAL no
     LABEL "с уровня":L
     VIEW-AS TOGGLE-BOX
     size 12.63 by 1 NO-UNDO.

DEFINE VARIABLE Tog-obj AS LOGICAL INITIAL yes
     LABEL "Раздельно по объектам":L
     VIEW-AS TOGGLE-BOX
     size 39.38 by 1 NO-UNDO.

DEFINE VARIABLE VAT-Cost AS LOGICAL INITIAL no
     LABEL "НДС в учетных ценах":L
     VIEW-AS TOGGLE-BOX
     size 25.63 by 0.83 NO-UNDO.

DEFINE VARIABLE VAT-CRSA AS LOGICAL INITIAL no
     LABEL "НДС в продажных ценах":L
     VIEW-AS TOGGLE-BOX
     size 25.63 by 0.83 NO-UNDO.

DEFINE VARIABLE VAT-sale AS LOGICAL INITIAL no
     LABEL "НДС в ценах документа":L
     VIEW-AS TOGGLE-BOX
     size 25.63 by 0.83 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     Tog-obj at row 2.54 col 32.75
     Classify at row 3.79 col 32.75 NO-LABEL
     Tog-lavel at row 5.63 col 52
     var-lavel AT ROW 5.63 COL 63.38 COLON-ALIGNED NO-LABEL
     r-gds AT ROW 9.75 COL 43.25 NO-LABEL
     ShowZero-2 at row 12.04 col 33
     VAT-Cost at row 12.04 col 53.13
     ShowZero at row 12.92 col 33
     VAT-CRSA at row 12.92 col 53.13
     SumsOnly AT ROW 13.83 COL 33
     VAT-sale at row 13.83 col 53.13
     SortType at row 16.04 col 32.5 NO-LABEL
     "Товары :" VIEW-AS TEXT
          size 9 by 0.75 at row 9.75 col 32.75
          FGCOLOR 4
     "Сортировка :" VIEW-AS TEXT
          size 46.5 by 0.75 at row 15.17 col 32.63
          FGCOLOR 4
     RECT-6 AT ROW 15.08 COL 31.38
     "Классификация :" VIEW-AS TEXT
          size 46 by 0.75 at row 1.28 col 33
          FGCOLOR 4
     RECT-8 AT ROW 10.79 COL 31.38
     "Показать :" VIEW-AS TEXT
          size 46.13 by 0.75 at row 11 col 33
          FGCOLOR 4
     "Тип приобретения:" VIEW-AS TEXT
          SIZE 28.88 BY .67 AT ROW 1.38 COL 1.88
          FGCOLOR 4
     RECT-9 AT ROW 1.08 COL 1
     RECT-5 AT ROW 1 COL 31.38
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
         HEIGHT             = 17.21
         WIDTH              = 78.13.
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

/* SETTINGS FOR RADIO-SET r-gds IN FRAME F-Main
   6                                                                    */
/* SETTINGS FOR TOGGLE-BOX SumsOnly IN FRAME F-Main
   NO-ENABLE                                                            */
/* SETTINGS FOR TOGGLE-BOX Tog-lavel IN FRAME F-Main
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       Tog-lavel:HIDDEN IN FRAME F-Main           = TRUE.

/* SETTINGS FOR FILL-IN var-lavel IN FRAME F-Main
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       var-lavel:HIDDEN IN FRAME F-Main           = TRUE.

/* SETTINGS FOR TOGGLE-BOX VAT-Cost IN FRAME F-Main
   6                                                                    */
/* SETTINGS FOR TOGGLE-BOX VAT-CRSA IN FRAME F-Main
   6                                                                    */
/* SETTINGS FOR TOGGLE-BOX VAT-sale IN FRAME F-Main
   6                                                                    */
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

&Scoped-define SELF-NAME Classify
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Classify s-object
ON VALUE-CHANGED OF Classify IN FRAME F-Main
DO:
    Assign Classify.
    if Classify  Begins "prod":U OR
       Classify  Begins "grp-goods":U OR
       Classify  Begins "vat-ps":U
        then
        enable SumsOnly with frame {&FRAME-NAME} .

   if Classify = "no-classify":U
      Then do:
            SumsOnly = FALSE .
            display SumsOnly with frame {&FRAME-NAME} .
            disable SumsOnly with frame {&FRAME-NAME} .
        end.

  /* if Classify = "grp-goods":U
         Then do:
            display TOG-lavel   with frame {&FRAME-NAME} .
            enable  TOG-lavel   with frame {&FRAME-NAME} .
        end.
         Else do:
            display  TOG-lavel  var-Lavel with frame {&FRAME-NAME} .
            disable  TOG-lavel  var-Lavel with frame {&FRAME-NAME} .
        end.
*/

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

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

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
   Tog-obj:screen-value in frame {&frame-name} = 'yes':U.
   var-lavel:screen-value in frame {&frame-name} = '1'.

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
    v-log
  }
 if not v-log then
    disable vat-Cost with frame {&frame-name}.

  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_reports_lookup-crsa':U
    {&cntxt-object}
    v-cntxt-host-code-obj
    v-cntxt-obj-type
    v-cntxt-obj-code
    0
    0
    0
    false
    v-log
  }
 if not v-log then
    disable vat-crsa with frame {&frame-name}.

  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_reports_lookup-sale':U
    {&cntxt-object}
    v-cntxt-host-code-obj
    v-cntxt-obj-type
    v-cntxt-obj-code
    0
    0
    0
    false
    v-log
  }
 if not v-log then
    disable vat-sale with frame {&frame-name}.
 run cr-ob in this-procedure
    ( 3 , 3 ,
    'Все,Выкуп,Консигнация,Ответственное хранение,Старая консигнация':L ,
    'all,r,cb,s,' + {&aht-old_cons}).


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-report s-object
PROCEDURE my-report :
/*
if not can-find(first gds-list) then do:
   message "Не выбран ни один товар !!!!" view-as alert-box error .
   return 'First-page':U.
end.


run waitfram-show "Разбор товаров....".
run waitfram-hide .
*/
/* Проверка на host-code */
for each obj-list :
   find first clients no-lock where
              clients.obj-code  = obj-list.obj-code  and
              clients.obj-type  = obj-list.obj-type  and
              clients.host-code = v-cntxt-host-code-obj no-error .
  if not available clients then do:
     message "Объект "
     obj-list.obj-code
     obj-list.obj-type
     obj-list.obj-name
     " не принадлежит фирме " v-cntxt-host-code-obj v-cntxt-host-name-obj
              "Определите список объектов , принадлежащих одной фирмы"
              view-as alert-box information .
     return error .
  end.

end.
run run-p in this-procedure  .



END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-var s-object
PROCEDURE my-var :
/*------------------------------------------------------------------------------
  Purpose:     здесь происходит вызов  значений переменных
  например  Название отчета, может быть еще пример шапки???
------------------------------------------------------------------------------*/
if VALID-HANDLE(type-pr) = false  then do:
    message "Нет архивов по типу приобретения !!!" skip
    view-as alert-box information .
    return 'First-page':U.
 end.

assign frame {&frame-name} SumsOnly ShowZero tog-obj ShowZero-2
tog-lavel var-lavel Classify SortType {&List-6}  .

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


ReportNAme = "О Т Ч Е Т  ТПСИ   по типу приобретения - "
                           + Caps ( entry( (lookup(type-pr:screen-value ,type-pr:RADIO-BUTTONS) - 1), type-pr:RADIO-BUTTONS )   )
                           .
{ rep/claslabl.i }
ReportHeader = "Классификация : " + t-Class.
ReportHeader = ReportHeader +
               (if tog-lavel  then "    Итоги с уровня  "  + String(var-lavel)  else " "    ).
ReportHeader = ReportHeader  + chr(10).

ReportHeader = ReportHeader +
               "Сортировка " + t-Sort + chr(10) +
               "Показать : " +
               (if SumsOnly     then "Только итоги, "  else " "            ) +
               (if Show-Cost    then "Суммы в учетных ценах, "  else " "   ) +
               (if Show-Crsa    then "Суммы в продажных ценах, "  else " " ) +
               (if Show-Sale    then "Суммы в продажных ценах документа , "  else " " ) +
               (if vat-Cost     then "НДС в учетных ценах, "  else " "   ) +
               (if vat-Crsa     then "НДС в продажных ценах, "  else " " ) +
               (if vat-Sale     then "НДС в продажных ценах документа , "  else " " ) +
               (if ShowZero     then " Показывать нулевые остатки "  else " Не показывать нулевые остатки" ) +
               (if ShowZero-2   then " Показывать нулевые обороты "  else " Не показывать нулевые обороты" ) .

if type-pr:screen-value = "all" then ReportHeader =  ReportHeader  +    chr(10) + "Итоги по типам приобретения показываются , если типов приобретения больше одного." .

Sheetf.Excel-Column-Lable = "Код,Артикул,Название товара ,Ед.изм,т/у,Скидка,Остаток на  начало,,,,,,,Приход,,,,,,,Расход,,,,,,,Касса,,,,,,,Инвентаризация|Смена типа приобретения,,,,,,,Переоценка,,,,,,,Остаток на конец,,,,,,,, "  + chr(10).
Sheetf.Excel-Column-Lable = Excel-Column-Lable + ",,,,,, " +
      Fill ( "кол-во ,учет.сумма ,прод.сумма ,в ценах док-та ,учет.НДС,прод.НДС,НДС в ценах док-та ," , 7) .
Sheetf.Sizes = "10,16,60,7,3,13," + Fill("13,", 49) .
Sheetf.make-correct = fill("false,", 55) .
Sheetf.ColFOrmat = "2=@;3=@"  .

END PROCEDURE.
{ rep/tpcrr-b.i }

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE run-p s-object
PROCEDURE run-p :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/


    if type-pr:screen-value = "all" then do:
    case SortType :
      when "sort-artic" then do:
        run proc-a in this-procedure .
      end.
      when "sort-code" then do:
        run proc-s in this-procedure .
      end.
      when "sort-name" then do:
        run proc-t in this-procedure .
      end.
    end case.

    end.
    else do:
      case SortType :
        when "sort-artic" then do:
          run proc-r in this-procedure .
        end.
        when "sort-code" then do:
          run proc-c in this-procedure .
        end.
        when "sort-name" then do:
          run proc-n in this-procedure .
        end.
      end case.
    end.

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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-a W-Win
PROCEDURE proc-a :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
case Classify :
  when "no-classify" then do:
     if tog-obj = true then
        run rep/tpoba-1y.p {&run-param}
      else
        run rep/tpoba-1n.p {&run-param}
  end.

  when "prod" then do:
     if tog-obj = true then
        run rep/tpoba-3y.p {&run-param}
      else
        run rep/tpoba-3n.p {&run-param}
  end.
  when "grp-goods" then do:
     if tog-obj = true then
        run rep/tpoba-2y.p {&run-param}
      else
        run rep/tpoba-2n.p {&run-param}
  end.
  when "prod/grp-goods" then do:
     if tog-obj = true then
        run rep/tpoba-4y.p {&run-param}
      else
        run rep/tpoba-4n.p {&run-param}
  end.
  when "grp-goods/prod" then do:
     if tog-obj = true then
        run rep/tpoba-5y.p {&run-param}
      else
        run rep/tpoba-5n.p {&run-param}
  end.
  when "vat-ps" then do:
     if tog-obj = true then
        run rep/tpoba-6y.p {&run-param}
      else
        run rep/tpoba-6n.p {&run-param}
  end.
end case.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-s W-Win
PROCEDURE proc-s :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
case Classify :
  when "no-classify" then do:
     if tog-obj = true then
        run rep/tpobs-1y.p {&run-param}
      else
        run rep/tpobs-1n.p {&run-param}
  end.

  when "prod" then do:
     if tog-obj = true then
        run rep/tpobs-3y.p {&run-param}
      else
        run rep/tpobs-3n.p {&run-param}
  end.
  when "grp-goods" then do:
     if tog-obj = true then
        run rep/tpobs-2y.p {&run-param}
      else
        run rep/tpobs-2n.p {&run-param}
  end.
  when "prod/grp-goods" then do:
     if tog-obj = true then
        run rep/tpobs-4y.p {&run-param}
      else
        run rep/tpobs-4n.p {&run-param}
  end.
  when "grp-goods/prod" then do:
     if tog-obj = true then
        run rep/tpobs-5y.p {&run-param}
      else
        run rep/tpobs-5n.p {&run-param}
  end.
  when "vat-ps" then do:
     if tog-obj = true then
        run rep/tpobs-6y.p {&run-param}
      else
        run rep/tpobs-6n.p {&run-param}
  end.
end case.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-t W-Win
PROCEDURE proc-t :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
case Classify :
  when "no-classify" then do:
     if tog-obj = true then
        run rep/tpobt-1y.p {&run-param}
      else
        run rep/tpobt-1n.p {&run-param}
  end.

  when "prod" then do:
     if tog-obj = true then
        run rep/tpobt-3y.p {&run-param}
      else
        run rep/tpobt-3n.p {&run-param}
  end.
  when "grp-goods" then do:
     if tog-obj = true then
        run rep/tpobt-2y.p {&run-param}
      else
        run rep/tpobt-2n.p {&run-param}
  end.
  when "prod/grp-goods" then do:
     if tog-obj = true then
        run rep/tpobt-4y.p {&run-param}
      else
        run rep/tpobt-4n.p {&run-param}
  end.
  when "grp-goods/prod" then do:
     if tog-obj = true then
        run rep/tpobt-5y.p {&run-param}
      else
        run rep/tpobt-5n.p {&run-param}
  end.
  when "vat-ps" then do:
     if tog-obj = true then
        run rep/tpobt-6y.p {&run-param}
      else
        run rep/tpobt-6n.p {&run-param}
  end.
end case.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-r W-Win
PROCEDURE proc-r :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
case Classify :
  when "no-classify" then do:
     if tog-obj = true then
        run rep/tpobr-1y.p {&run-param}
      else
        run rep/tpobr-1n.p {&run-param}
  end.

  when "prod" then do:
     if tog-obj = true then
        run rep/tpobr-3y.p {&run-param}
      else
        run rep/tpobr-3n.p {&run-param}
  end.
  when "grp-goods" then do:
     if tog-obj = true then
        run rep/tpobr-2y.p {&run-param}
      else
        run rep/tpobr-2n.p {&run-param}
  end.
  when "prod/grp-goods" then do:
     if tog-obj = true then
        run rep/tpobr-4y.p {&run-param}
      else
        run rep/tpobr-4n.p {&run-param}
  end.
  when "grp-goods/prod" then do:
     if tog-obj = true then
        run rep/tpobr-5y.p {&run-param}
      else
        run rep/tpobr-5n.p {&run-param}
  end.
  when "vat-ps" then do:
     if tog-obj = true then
        run rep/tpobr-6y.p {&run-param}
      else
        run rep/tpobr-6n.p {&run-param}
  end.
end case.

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
case Classify :
  when "no-classify" then do:
     if tog-obj = true then
        run rep/tpobc-1y.p {&run-param}
      else
        run rep/tpobc-1n.p {&run-param}
  end.

  when "prod" then do:
     if tog-obj = true then
        run rep/tpobc-3y.p {&run-param}
      else
        run rep/tpobc-3n.p {&run-param}
  end.
  when "grp-goods" then do:
     if tog-obj = true then
        run rep/tpobc-2y.p {&run-param}
      else
        run rep/tpobc-2n.p {&run-param}
  end.
  when "prod/grp-goods" then do:
     if tog-obj = true then
        run rep/tpobc-4y.p {&run-param}
      else
        run rep/tpobc-4n.p {&run-param}
  end.
  when "grp-goods/prod" then do:
     if tog-obj = true then
        run rep/tpobc-5y.p {&run-param}
      else
        run rep/tpobc-5n.p {&run-param}
  end.
  when "vat-ps" then do:
     if tog-obj = true then
        run rep/tpobc-6y.p {&run-param}
      else
        run rep/tpobc-6n.p {&run-param}
  end.
end case.

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
case Classify :
  when "no-classify" then do:
     if tog-obj = true then
        run rep/tpobn-1y.p {&run-param}
      else
        run rep/tpobn-1n.p {&run-param}
  end.

  when "prod" then do:
     if tog-obj = true then
        run rep/tpobn-3y.p {&run-param}
      else
        run rep/tpobn-3n.p {&run-param}
  end.
  when "grp-goods" then do:
     if tog-obj = true then
        run rep/tpobn-2y.p {&run-param}
      else
        run rep/tpobn-2n.p {&run-param}
  end.
  when "prod/grp-goods" then do:
     if tog-obj = true then
        run rep/tpobn-4y.p {&run-param}
      else
        run rep/tpobn-4n.p {&run-param}
  end.
  when "grp-goods/prod" then do:
     if tog-obj = true then
        run rep/tpobn-5y.p {&run-param}
      else
        run rep/tpobn-5n.p {&run-param}
  end.
  when "vat-ps" then do:
     if tog-obj = true then
        run rep/tpobn-6y.p {&run-param}
      else
        run rep/tpobn-6n.p {&run-param}
  end.
end case.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME