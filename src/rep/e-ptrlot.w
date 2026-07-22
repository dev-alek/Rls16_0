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

Оборотная ведомость по топливу

Автор: Чернова Светлана Александровна
Дата создания: 03/02/06
Author: Svetlana Chernova
Creation date: 03/02/06

*/

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Оборотная ведомость по топливу (закладка № 2)".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/r-page1.i  }
{ rep/rep-bt.i   }

define variable v-nn as integer   no-undo .
define variable is-petrl as logical   no-undo init true .
CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

define variable State-source as  WIDGET-HANDLE.
define variable rserv as char init "all" no-undo .
define variable print-o as char init "" no-undo .
define variable g#log as logical   no-undo .

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
&Scoped-Define ENABLED-OBJECTS RECT-8 RECT-9 RECT-5 RECT-6 RECT-10 Tog-obj ~
SortType Classify tog-wt tog-dens ShowZero-2 ShowCost ShowCostNDS ~
ShowCost-2 EDITOR-1 ShowSale ShowSaleNDS ShowSale-2 ShowSaleNDS-2 ~
ShowSaleSLT ShowMediator Tog-Excel B-columns 
&Scoped-Define DISPLAYED-OBJECTS Tog-obj SortType Classify tog-wt tog-dens ~
ShowZero-2 ShowCost ShowCostNDS ShowZero ShowCost-2 EDITOR-1 ShowSale ~
ShowSaleNDS ShowZero-3 ShowSale-2 ShowSaleNDS-2 ShowSaleSLT SumsOnly ~
ShowMediator Tog-Excel 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */
DEFINE BUTTON B-columns 
     LABEL "Выбор колонок для печати" 
     SIZE 28.75 BY 1 TOOLTIP "Выбор колонок для печати".

DEFINE VARIABLE EDITOR-1 AS CHARACTER INITIAL "В отчет попадают только те товары, у которых есть документы после даты начала интервала" 
     VIEW-AS EDITOR NO-BOX
     SIZE 30.5 BY 1.25
     FGCOLOR 4 FONT 4 NO-UNDO.

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
     SIZE 46.75 BY 6.29 NO-UNDO.

DEFINE VARIABLE SortType AS CHARACTER 
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS 
          "по коду", "sort-code":U,
"по артикулу", "sort-artic":U,
"по наименованию", "sort-name":U
     SIZE 19 BY 2.5 NO-UNDO.

DEFINE RECTANGLE RECT-10
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 26.63 BY 5.

DEFINE RECTANGLE RECT-5
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 48.5 BY 9.29.

DEFINE RECTANGLE RECT-6
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 26.63 BY 4.04.

DEFINE RECTANGLE RECT-8
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 75.5 BY 8.58.

DEFINE RECTANGLE RECT-9
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 31.75 BY 6.17.

DEFINE VARIABLE Long-name AS LOGICAL INITIAL no 
     LABEL "В Excel-> (Английское назв.+Назв.на этикетке)":L 
     VIEW-AS TOGGLE-BOX
     SIZE 47.63 BY 1 TOOLTIP "В Excel вместо колонки название выводить длинное название товара" NO-UNDO.

DEFINE VARIABLE ShowCost AS LOGICAL INITIAL no 
     LABEL "Суммы в учетных ценах":L 
     VIEW-AS TOGGLE-BOX
     SIZE 26 BY .79 TOOLTIP "Показывать суммы в учетных ценах" NO-UNDO.

DEFINE VARIABLE ShowCost-2 AS LOGICAL INITIAL no 
     LABEL "Учетные цены без НДС":L 
     VIEW-AS TOGGLE-BOX
     SIZE 29 BY .79 TOOLTIP "Если показывать учетные цены , то без НДС" NO-UNDO.

DEFINE VARIABLE ShowCostNDS AS LOGICAL INITIAL no 
     LABEL "НДС":L 
     VIEW-AS TOGGLE-BOX
     SIZE 11 BY .79 TOOLTIP "Показывать НДС в учетных ценах" NO-UNDO.

DEFINE VARIABLE ShowMediator AS LOGICAL INITIAL no 
     LABEL "Суммы в ценах посредника":L 
     VIEW-AS TOGGLE-BOX
     SIZE 40 BY .79 TOOLTIP "Показывать суммы в ценах фирмы посредника" NO-UNDO.

DEFINE VARIABLE ShowSale AS LOGICAL INITIAL no 
     LABEL "Суммы в продажных ценах":L 
     VIEW-AS TOGGLE-BOX
     SIZE 26 BY .79 TOOLTIP "Показывать суммы в продажных ценах" NO-UNDO.

DEFINE VARIABLE ShowSale-2 AS LOGICAL INITIAL no 
     LABEL "Суммы в ценах документа":L 
     VIEW-AS TOGGLE-BOX
     SIZE 26 BY .79 TOOLTIP "Показывать суммы в ценах документа" NO-UNDO.

DEFINE VARIABLE ShowSaleNDS AS LOGICAL INITIAL no 
     LABEL "НДС":L 
     VIEW-AS TOGGLE-BOX
     SIZE 12 BY .79 TOOLTIP "Показывать НДС в продажных ценах" NO-UNDO.

DEFINE VARIABLE ShowSaleNDS-2 AS LOGICAL INITIAL no 
     LABEL "НДС":L 
     VIEW-AS TOGGLE-BOX
     SIZE 12.5 BY .79 TOOLTIP "Показывать НДС в ценах документа" NO-UNDO.

DEFINE VARIABLE ShowSaleSLT AS LOGICAL INITIAL no 
     LABEL "НсП":L 
     VIEW-AS TOGGLE-BOX
     SIZE 6.5 BY .79 TOOLTIP "Показывать Налог с продаж в ценах документа" NO-UNDO.

DEFINE VARIABLE ShowZero AS LOGICAL INITIAL no 
     LABEL "Нулевые остатки":L 
     VIEW-AS TOGGLE-BOX
     SIZE 28.63 BY .79 TOOLTIP "Показать товары с нулевым оборотом и нулевыми остатками" NO-UNDO.

DEFINE VARIABLE ShowZero-2 AS LOGICAL INITIAL no 
     LABEL "Нулевые обороты":L 
     VIEW-AS TOGGLE-BOX
     SIZE 28.63 BY 1 TOOLTIP "Показать товары с нулевым оборотом" NO-UNDO.

DEFINE VARIABLE ShowZero-3 AS LOGICAL INITIAL no 
     LABEL "Все товары":L 
     VIEW-AS TOGGLE-BOX
     SIZE 28.63 BY .79 TOOLTIP "Показать все выбранные товары" NO-UNDO.

DEFINE VARIABLE SumsOnly AS LOGICAL INITIAL no 
     LABEL "Только итоги" 
     VIEW-AS TOGGLE-BOX
     SIZE 19 BY 1 TOOLTIP "Показывать итоги без товаров" NO-UNDO.

DEFINE VARIABLE tog-dens AS LOGICAL INITIAL yes 
     LABEL "Плотность":L 
     VIEW-AS TOGGLE-BOX
     SIZE 19 BY .75 NO-UNDO.

DEFINE VARIABLE Tog-Excel AS LOGICAL INITIAL no 
     LABEL "Только в Excel" 
     VIEW-AS TOGGLE-BOX
     SIZE 19 BY .96
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE Tog-lavel AS LOGICAL INITIAL no 
     LABEL "с уровня":L 
     VIEW-AS TOGGLE-BOX
     SIZE 11.38 BY 1 NO-UNDO.

DEFINE VARIABLE tog-ms AS LOGICAL INITIAL no 
     LABEL "Объем" 
     VIEW-AS TOGGLE-BOX
     SIZE 11.25 BY .79 NO-UNDO.

DEFINE VARIABLE Tog-obj AS LOGICAL INITIAL yes 
     LABEL "Раздельно по объектам":L 
     VIEW-AS TOGGLE-BOX
     SIZE 47.25 BY 1 NO-UNDO.

DEFINE VARIABLE Tog-tree AS LOGICAL INITIAL no 
     LABEL "дерево":L 
     VIEW-AS TOGGLE-BOX
     SIZE 9.25 BY 1 NO-UNDO.

DEFINE VARIABLE tog-wt AS LOGICAL INITIAL yes 
     LABEL "Вес" 
     VIEW-AS TOGGLE-BOX
     SIZE 11.25 BY .79 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     Tog-obj AT ROW 2.5 COL 2.25
     SortType AT ROW 2.5 COL 51.75 NO-LABEL
     Classify AT ROW 3.79 COL 2.25 NO-LABEL
     Tog-lavel AT ROW 6 COL 21.38
     var-lavel AT ROW 6 COL 31 COLON-ALIGNED NO-LABEL
     Tog-tree AT ROW 6 COL 40
     tog-wt AT ROW 6.75 COL 52 WIDGET-ID 6
     tog-dens AT ROW 7.75 COL 52
     tog-ms AT ROW 8.75 COL 52 WIDGET-ID 8
     ShowZero-2 AT ROW 11.04 COL 45
     ShowCost AT ROW 11.96 COL 3
     ShowCostNDS AT ROW 11.96 COL 31
     ShowZero AT ROW 11.96 COL 45
     ShowCost-2 AT ROW 12.92 COL 3
     EDITOR-1 AT ROW 13 COL 45 NO-LABEL
     ShowSale AT ROW 13.88 COL 3
     ShowSaleNDS AT ROW 13.88 COL 31
     ShowZero-3 AT ROW 14.25 COL 45
     ShowSale-2 AT ROW 14.79 COL 3
     ShowSaleNDS-2 AT ROW 14.79 COL 31
     ShowSaleSLT AT ROW 14.79 COL 37
     SumsOnly AT ROW 15 COL 45
     ShowMediator AT ROW 15.75 COL 3
     Tog-Excel AT ROW 15.75 COL 45
     B-columns AT ROW 16.96 COL 3
     Long-name AT ROW 18 COL 17
     "Показать :" VIEW-AS TEXT
          SIZE 11.5 BY .67 AT ROW 11 COL 21 WIDGET-ID 12
          FGCOLOR 4 
     "Сортировка товара :" VIEW-AS TEXT
          SIZE 24.25 BY .67 AT ROW 1.42 COL 51.63
          FGCOLOR 4 
     "Классификация :":C47 VIEW-AS TEXT
          SIZE 46.25 BY .75 AT ROW 1.42 COL 2.63
          FGCOLOR 4 
     "Выводить колонки :" VIEW-AS TEXT
          SIZE 24.25 BY .67 AT ROW 5.75 COL 51 WIDGET-ID 10
          FGCOLOR 4 
     RECT-8 AT ROW 10.75 COL 1.5
     RECT-9 AT ROW 11 COL 44.25
     RECT-5 AT ROW 1.21 COL 1.5
     RECT-6 AT ROW 1.21 COL 50.38
     RECT-10 AT ROW 5.5 COL 50.38 WIDGET-ID 2
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
         HEIGHT             = 18.38
         WIDTH              = 76.75.
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

ASSIGN 
       EDITOR-1:READ-ONLY IN FRAME F-Main        = TRUE.

/* SETTINGS FOR TOGGLE-BOX Long-name IN FRAME F-Main
   NO-DISPLAY NO-ENABLE                                                 */
/* SETTINGS FOR TOGGLE-BOX ShowZero IN FRAME F-Main
   NO-ENABLE                                                            */
/* SETTINGS FOR TOGGLE-BOX ShowZero-3 IN FRAME F-Main
   NO-ENABLE                                                            */
/* SETTINGS FOR TOGGLE-BOX SumsOnly IN FRAME F-Main
   NO-ENABLE                                                            */
/* SETTINGS FOR TOGGLE-BOX Tog-lavel IN FRAME F-Main
   NO-DISPLAY NO-ENABLE                                                 */
/* SETTINGS FOR TOGGLE-BOX tog-ms IN FRAME F-Main
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN 
       tog-ms:HIDDEN IN FRAME F-Main           = TRUE.

/* SETTINGS FOR TOGGLE-BOX Tog-tree IN FRAME F-Main
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN 
       Tog-tree:HIDDEN IN FRAME F-Main           = TRUE.

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

&Scoped-define SELF-NAME B-columns
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-columns s-object
ON CHOOSE OF B-columns IN FRAME F-Main /* Выбор колонок для печати */
DO:
  /* Процедура задания колонок в отчете */
  run rep/askfield.w ( input "r-oborot":U, output print-o ) .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


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

   if Classify = "grp-goods":U
         Then do:
            display TOG-lavel   with frame {&FRAME-NAME} .
            enable  TOG-lavel   with frame {&FRAME-NAME} .
        end.
         Else do:
            display  TOG-lavel  var-Lavel  with frame {&FRAME-NAME} .
            disable  TOG-lavel  var-Lavel with frame {&FRAME-NAME} .
        end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Long-name
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Long-name s-object
ON VALUE-CHANGED OF Long-name IN FRAME F-Main /* В Excel-> (Английское назв.+Назв.на этикетке) */
DO:
  ASSIGN long-name .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME ShowCost
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ShowCost s-object
ON VALUE-CHANGED OF ShowCost IN FRAME F-Main /* Суммы в учетных ценах */
DO:
  assign ShowCost.
  if ShowCost then
   enable   ShowCost-2 with frame {&frame-name} .
  else  do:
  ShowCost-2 = false .
  disable ShowCost-2  with frame {&frame-name} .
  end.

display  ShowCost-2 with frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME ShowZero
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ShowZero s-object
ON VALUE-CHANGED OF ShowZero IN FRAME F-Main /* Нулевые остатки */
DO:
   assign ShowZero.
  if ShowZero = no then do:

     ShowZero-3 = no .
     display ShowZero-3 with frame {&frame-name} .
     disable ShowZero-3 with frame {&frame-name} .
  end.
  else enable ShowZero-3 with frame {&frame-name} .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME ShowZero-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ShowZero-2 s-object
ON VALUE-CHANGED OF ShowZero-2 IN FRAME F-Main /* Нулевые обороты */
DO:
  assign ShowZero-2.
  if ShowZero-2 = no then do:
     ShowZero = no .
     ShowZero-3 = no .
     display ShowZero ShowZero-3 with frame {&frame-name} .
     disable ShowZero ShowZero-3 with frame {&frame-name} .
  end.
  else enable ShowZero with frame {&frame-name} .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME ShowZero-3
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ShowZero-3 s-object
ON VALUE-CHANGED OF ShowZero-3 IN FRAME F-Main /* Все товары */
DO:
  assign showzero-3.
      if showzero-3 = no then do:
         display EDITOR-1 with frame {&frame-name} .
      end.
      else hide EDITOR-1 in frame {&frame-name} .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tog-dens
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tog-dens s-object
ON VALUE-CHANGED OF tog-dens IN FRAME F-Main /* Плотность */
DO:
  assign tog-dens.
  display  tog-dens with frame {&frame-name}.
  run excel-yes in this-procedure.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Tog-Excel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Tog-Excel s-object
ON VALUE-CHANGED OF Tog-Excel IN FRAME F-Main /* Только в Excel */
DO:
    ASSIGN Tog-Excel .
  IF Tog-Excel THEN ENABLE Long-name WITH FRAME {&FRAME-NAME}.
      ELSE
    DISABLE Long-name WITH FRAME {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Tog-lavel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Tog-lavel s-object
ON VALUE-CHANGED OF Tog-lavel IN FRAME F-Main /* с уровня */
DO:
  if tog-lavel:screen-value = string(TRUE)
        Then do:
            display  var-Lavel with frame {&FRAME-NAME} .
            enable   var-Lavel  with frame {&FRAME-NAME} .
        end.
         Else do:
            display    var-Lavel  with frame {&FRAME-NAME} .
            disable    var-Lavel  with frame {&FRAME-NAME} .
        end.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Tog-tree
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Tog-tree s-object
ON VALUE-CHANGED OF Tog-tree IN FRAME F-Main /* дерево */
DO:
  if tog-tree:screen-value=string(TRUE)
        Then do:
            assign
                SumsOnly = true
                tog-wt   = false
                tog-ms   = false
            .
            display
                SumsOnly
                tog-wt
                tog-ms
            with frame {&FRAME-NAME} .
            disable
                SumsOnly
                tog-wt
                tog-ms
            with frame {&FRAME-NAME} .

        end.
         Else do:
            display
                SumsOnly
                tog-wt
                tog-ms
            with frame {&FRAME-NAME} .
            enable
                SumsOnly
                tog-wt
                tog-ms
            with frame {&FRAME-NAME} .
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE excel-yes s-object 
PROCEDURE excel-yes :
do
on error undo, return error
:
   IF ShowCost
   OR ShowCost-2
   OR ShowCostNDS
   OR ShowMediator
   OR ShowSale
   OR ShowSale-2
   OR ShowSaleNDS
   OR ShowSaleNDS-2
   OR ShowSaleSLT
   OR Tog-Dens
   THEN DO:
      ASSIGN
         Tog-Excel = YES
      .
      DISPLAY  Tog-Excel WITH FRAME {&FRAME-NAME}.
   END.
   /*
   ELSE DO:
      ASSIGN
         Tog-Excel = NO
      .
      DISPLAY  Tog-Excel WITH FRAME {&FRAME-NAME}.
   END.
   */
end. /* do on error */
end procedure. /* excel-yes */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-apply-layout s-object 
PROCEDURE local-apply-layout :
/*------------------------------------------------------------------------------
  Purpose:     Override standard ADM method
  Notes:
------------------------------------------------------------------------------*/
disable ShowCost-2 with frame {&frame-name}.
display  ShowCost-2 with frame {&frame-name}.
run excel-yes in this-procedure.

IF tog-excel = NO THEN
   DISABLE long-name with frame {&frame-name}.
ELSE enable long-name with frame {&frame-name}.

  /* Code placed here will execute PRIOR to standard behavior. */

  /* Dispatch standard ADM method.                             */
  RUN dispatch IN THIS-PROCEDURE ( INPUT 'apply-layout':U ) .

  /* Code placed here will execute AFTER standard behavior.    */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-initialize s-object 
PROCEDURE local-initialize :
&scop max-col 28
define variable l-ind as integer no-undo .
define buffer   buf_usr-flt for ubflt.usr-flt  .

  RUN dispatch IN THIS-PROCEDURE ( INPUT 'initialize':U ) .
   Tog-obj:screen-value in frame {&frame-name} = string(True).
   var-lavel:screen-value in frame {&frame-name} = '1'.

    repeat l-ind = 1 to {&max-col} :
          use-column[ l-ind ] =  false  .
    End.

 find first buf_usr-flt no-lock  where
            buf_usr-flt.user-name  = v-cntxt-userid and
            buf_usr-flt.call-point = "r-oborot":U
            no-error .
     if not available buf_usr-flt then do:
        run rep/askfield.w ( input "r-oborot":U, output print-o ).
     end.

     if available  buf_usr-flt then  DO:
          v-nn = num-entries(buf_usr-flt.list_) .
          repeat l-ind = 1 to v-nn :
            if index ( entry(l-ind,buf_usr-flt.list_),"=") = 0 THEN DO :
                if int(entry(l-ind,buf_usr-flt.list_)) > 0 and
                   int(entry(l-ind,buf_usr-flt.list_)) <= {&max-col}
                   then
                   use-column[int(entry(l-ind,buf_usr-flt.list_)) ] =  true  .


            end.
            else do :
                if entry(1,entry(l-ind,buf_usr-flt.list_),"=")  = "print-o":U then
                    print-o = entry(2,entry(l-ind,buf_usr-flt.list_),"=") no-error .
                if error-status :error Or print-o = "" then DO:
                  run rep/askfield.w ( input "r-oborot":U, output print-o ).
                  return no-apply.
                end.
            end.
          end.
      end.

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
 if not g#log then
    disable ShowCost ShowCostNDS with frame {&frame-name}.

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
    g#log
  }
 if not g#log then
    disable ShowSAle ShowSaleNDS with frame {&frame-name}.

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
    g#log
  }
 if not g#log then
    disable ShowSAle-2 ShowSaleNDS-2 ShowSaleSlt with frame {&frame-name}.

display editor-1 with frame {&frame-name}.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-report s-object 
PROCEDURE my-report :
define buffer buf_goods for ub.goods  .
define buffer buf_units for ub.units  .

/*x-TOG-Shift = true .*/
/*tog-obj     = true .*/
/*Tog-tree = false  .*/

for each gds-list :
  delete gds-list.
end.

for each buf_units no-lock where
      lookup( {&petrolium}, buf_units.type) > 0,
  each buf_goods no-lock where
        buf_goods.unit-base = buf_units.unit-name
        :
  create gds-list.
  buffer-copy buf_goods to  gds-list .
end.

case sorttype :
  when "sort-artic" then do:
     run proc-e-obor3-r in this-procedure .
  end.
  when "sort-code" then do:
     run proc-e-obor3-c in this-procedure .
  end.
  when "sort-name" then do:
     run proc-e-obor3-n in this-procedure .
  end.
end case.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-var s-object 
PROCEDURE my-var :
/*------------------------------------------------------------------------------
  Purpose:     здесь происходит вызов  значений переменных
  например  Название отчета, может быть еще пример шапки???
------------------------------------------------------------------------------*/
Assign frame {&frame-name} SumsOnly ShowZero tog-obj Classify SortType
       ShowCost ShowCostNDS ShowSale ShowSaleNDS  ShowSale-2 ShowSaleNDS-2
       TOG-excel ShowZero-2 tog-lavel var-lavel tog-tree ShowMediator
       ShowSaleSLT ShowCost-2 ShowZero-3 long-name tog-wt tog-ms tog-dens .
v-show-all-goods  = ShowZero-3 .
/*строки в которых содержатся выбранные объекты */
Assign
 STR-obj-type = ''
 STR-obj-code = ''
 STR-obj-name = ''
 STR-obj      = '' .

For each obj-list no-lock:
 Assign
 STR-obj-type = STR-obj-type + obj-list.obj-type + ','
 STR-obj-code = STR-obj-code + String(obj-list.obj-code) + ','
 STR-obj-name = STR-obj-name + obj-list.obj-name + ','
 STR-obj = STR-obj +  obj-list.obj-type + '#' + string(obj-list.obj-code)  + ',' .
End.


ReportNAme = "О Т Ч Е Т   О   С О С Т О Я Н И И   З А П А С А   И   П Р О Д А Ж А Х   ( О Б О Р О Т Н А Я   В Е Д О М О С Т Ь ) по типам документов".
{ rep/claslabl.i }
ReportHeader = "Классификация : " + t-Class.
ReportHeader = ReportHeader +
               (if tog-lavel  then "    Итоги с уровня  "  + String(var-lavel)  else " "    ).
ReportHeader = ReportHeader  + chr(10).

ASSIGN ReportHeader = "Классификация : " + t-Class +
                        ( IF Tog-Lavel = YES THEN "    Итоги с уровня  " + STRING( Var-Lavel ) ELSE " ":U ) + {&new-line} +
                        "Сортировка " + t-Sort + {&new-line} + "Показать : " +
                        ( IF SumsOnly      = YES THEN " Только итоги, "                  ELSE " ":U ) +
                        ( IF ShowCost      = YES THEN " Суммы в учетных ценах, "         ELSE " ":U ) +
                        ( IF ShowCost-2    = YES THEN " Суммы в учетных ценах без НДС, " ELSE " ":U ) +
                        ( IF ShowCostNDS   = YES THEN " НДС в учетных ценах, "           ELSE " ":U ) +
                        ( IF ShowSale      = YES THEN " Суммы в продажных ценах, "       ELSE " ":U ) +
                        ( IF ShowSaleNDS   = YES THEN " НДС в продажных ценах "          ELSE " ":U ) +
                        ( IF ShowSale-2    = YES THEN " Суммы в ценах документа, "       ELSE " ":U ) +
                        ( IF ShowSaleNDS-2 = YES THEN " НДС в ценах документа"           ELSE " ":U ) +
                        ( IF ShowSaleSLT   = YES THEN " НсП в ценах документа"           ELSE " ":U ) +
                        ( IF ShowMediator  = YES THEN " Суммы в ценах посредника"        ELSE " ":U ) + {&new-line} +
                        ( IF Tog-Tree      = YES THEN " группировка ввиде дерева"        ELSE " ":U ) + {&new-line} +
                        ( IF Tog-Dens      = YES THEN " Плотность"                       ELSE " ":U ) +
                        ( IF ShowZero      = YES THEN " Показывать нулевые остатки "     ELSE " Не показывать нулевые остатки" ) +
                        ( IF ShowZero-2    = YES THEN " Показывать нулевые обороты "     ELSE " Не показывать нулевые обороты" ) +
                        ( IF RServ <> {&all} THEN {&new-line} + "Только " + RServ ELSE " ":U ).
ReportHeader = ReportHeader + (if Rserv <> {&all}     then  chr(10) + "Только " + Rserv  else " "  ) .

if tog-tree and (use-column [1] = false OR use-column [2] = false  ) then  do:
   message "Для получения отчета с группировкой по дереву должны быть выбраны колонки  Код и Артикул !" view-as alert-box .
return error.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-e-obor3-c s-object 
PROCEDURE proc-e-obor3-c :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
IF TOG-excel = false  then do:
  case Classify :
    when "no-classify" then do:
      if tog-obj = true then
        run rep/r-oboc1y.p { rep/e-oborot.i 1 }
        else
        run rep/r-oboc1n.p { rep/e-oborot.i 1 }
    end.

    when "prod" then do:
      if tog-obj = true then
        run rep/r-oboc3y.p { rep/e-oborot.i 1 }
        else
        run rep/r-oboc3n.p { rep/e-oborot.i 1 }
    end.
    when "grp-goods" then do:
      if tog-tree = true then DO:
          if tog-obj = true then
            run rep/r-oboc2g.p { rep/e-oborot.i 1 }
            else
            run rep/r-oboc2d.p { rep/e-oborot.i 1 }
    end.
    else do:
      if Tog-lavel then do:
              if tog-obj = true then
                      run rep/r-oboc2l.p { rep/e-oborot.i 1 }
                      else
                      run rep/r-oboc2k.p { rep/e-oborot.i 1 }
                end.
                else do:
          if tog-obj = true then
            run rep/r-oboc2y.p { rep/e-oborot.i 1 }
            else
            run rep/r-oboc2n.p { rep/e-oborot.i 1 }
          end.
    End.
    end.
    when "prod/grp-goods" then do:
      if tog-obj = true then
        run rep/r-oboc4y.p { rep/e-oborot.i 1 }
        else
        run rep/r-oboc4n.p { rep/e-oborot.i 1 }
    end.
    when "grp-goods/prod" then do:
      if tog-obj = true then
        run rep/r-oboc5y.p { rep/e-oborot.i 1 }
        else
        run rep/r-oboc5n.p { rep/e-oborot.i 1 }
    end.
    when "vat-ps" then do:
      if tog-obj = true then
        run rep/r-oboc6y.p { rep/e-oborot.i 1 }
        else
        run rep/r-oboc6n.p { rep/e-oborot.i 1 }
    end.
  end case.
End.

/*Вывод в  excel   */

IF TOG-excel = TRUE then do:
  case Classify :
    when "no-classify" then do:
      if tog-obj = true then
        run rep/xloboc1y.p { rep/e-oborot.i 2 }
        else
          run rep/xloboc1n.p { rep/e-oborot.i 2 }
    end.

    when "prod" then do:
      if tog-obj = true then
        run rep/xloboc3y.p { rep/e-oborot.i 2 }
        else
        run rep/xloboc3n.p { rep/e-oborot.i 2 }
    end.
    when "grp-goods" then do:
      if tog-tree = true then DO:
          if tog-obj = true then
            run rep/xloboc2g.p { rep/e-oborot.i 2 }
            else
            run rep/xloboc2d.p { rep/e-oborot.i 2 }
    end.
    else do:
      if Tog-lavel then do:
              if tog-obj = true then
                      run rep/xloboc2l.p { rep/e-oborot.i 2 }
                      else
                      run rep/xloboc2k.p { rep/e-oborot.i 2 }
                end.
                else do:
          if tog-obj = true then
            run rep/xloboc2y.p { rep/e-oborot.i 2 }
            else
            run rep/xloboc2n.p { rep/e-oborot.i 2 }
          end.
    End.
    end.
    when "prod/grp-goods" then do:
      if tog-obj = true then
        run rep/xloboc4y.p { rep/e-oborot.i 2 }
        else
        run rep/xloboc4n.p { rep/e-oborot.i 2 }
    end.
    when "grp-goods/prod" then do:
      if tog-obj = true then
        run rep/xloboc5y.p { rep/e-oborot.i 2 }
        else
        run rep/xloboc5n.p { rep/e-oborot.i 2 }
    end.
    when "vat-ps" then do:
      if tog-obj = true then
        run rep/xloboc6y.p { rep/e-oborot.i 2 }
        else
        run rep/xloboc6n.p { rep/e-oborot.i 2 }
    end.
  end case.
End.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-e-obor3-n s-object 
PROCEDURE proc-e-obor3-n :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
IF TOG-excel = false  then do:
  case Classify :
    when "no-classify" then do:
      if tog-obj = true then
        run rep/r-obon1y.p { rep/e-oborot.i 1 }
        else
        run rep/r-obon1n.p { rep/e-oborot.i 1 }
    end.

    when "prod" then do:
      if tog-obj = true then
        run rep/r-obon3y.p { rep/e-oborot.i 1 }
        else
        run rep/r-obon3n.p { rep/e-oborot.i 1 }
    end.
    when "grp-goods" then do:
      if tog-tree = true then DO:
          if tog-obj = true then
            run rep/r-obon2g.p { rep/e-oborot.i 1 }
            else
            run rep/r-obon2d.p { rep/e-oborot.i 1 }
    end.
    else do:
      if Tog-lavel then do:
              if tog-obj = true then
                      run rep/r-obon2l.p { rep/e-oborot.i 1 }
                      else
                      run rep/r-obon2k.p { rep/e-oborot.i 1 }
                end.
                else do:
          if tog-obj = true then
            run rep/r-obon2y.p { rep/e-oborot.i 1 }
            else
            run rep/r-obon2n.p { rep/e-oborot.i 1 }
          end.
    End.
    end.
    when "prod/grp-goods" then do:
      if tog-obj = true then
        run rep/r-obon4y.p { rep/e-oborot.i 1 }
        else
        run rep/r-obon4n.p { rep/e-oborot.i 1 }
    end.
    when "grp-goods/prod" then do:
      if tog-obj = true then
        run rep/r-obon5y.p { rep/e-oborot.i 1 }
        else
        run rep/r-obon5n.p { rep/e-oborot.i 1 }
    end.
    when "vat-ps" then do:
      if tog-obj = true then
        run rep/r-obon6y.p { rep/e-oborot.i 1 }
        else
        run rep/r-obon6n.p { rep/e-oborot.i 1 }
    end.
  end case.
End.

/*Вывод в  excel   */

IF TOG-excel = TRUE then do:
  case Classify :
    when "no-classify" then do:
      if tog-obj = true then
        run rep/xlobon1y.p { rep/e-oborot.i 2 }
        else
          run rep/xlobon1n.p { rep/e-oborot.i 2 }
    end.

    when "prod" then do:
      if tog-obj = true then
        run rep/xlobon3y.p { rep/e-oborot.i 2 }
        else
        run rep/xlobon3n.p { rep/e-oborot.i 2 }
    end.
    when "grp-goods" then do:
      if tog-tree = true then DO:
          if tog-obj = true then
            run rep/xlobon2g.p { rep/e-oborot.i 2 }
            else
            run rep/xlobon2d.p { rep/e-oborot.i 2 }
    end.
    else do:
      if Tog-lavel then do:
              if tog-obj = true then
                      run rep/xlobon2l.p { rep/e-oborot.i 2 }
                      else
                      run rep/xlobon2k.p { rep/e-oborot.i 2 }
                end.
                else do:
          if tog-obj = true then
            run rep/xlobon2y.p { rep/e-oborot.i 2 }
            else
            run rep/xlobon2n.p { rep/e-oborot.i 2 }
          end.
    End.
    end.
    when "prod/grp-goods" then do:
      if tog-obj = true then
        run rep/xlobon4y.p { rep/e-oborot.i 2 }
        else
        run rep/xlobon4n.p { rep/e-oborot.i 2 }
    end.
    when "grp-goods/prod" then do:
      if tog-obj = true then
        run rep/xlobon5y.p { rep/e-oborot.i 2 }
        else
        run rep/xlobon5n.p { rep/e-oborot.i 2 }
    end.
    when "vat-ps" then do:
      if tog-obj = true then
        run rep/xlobon6y.p { rep/e-oborot.i 2 }
        else
        run rep/xlobon6n.p { rep/e-oborot.i 2 }
    end.
  end case.
End.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-e-obor3-r s-object 
PROCEDURE proc-e-obor3-r :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
IF TOG-excel = false  then do:
  case Classify :
    when "no-classify" then do:
      if tog-obj = true then
        run rep/r-obor1y.p { rep/e-oborot.i 1 }
        else
        run rep/r-obor1n.p { rep/e-oborot.i 1 }
    end.

    when "prod" then do:
      if tog-obj = true then
        run rep/r-obor3y.p { rep/e-oborot.i 1 }
        else
        run rep/r-obor3n.p { rep/e-oborot.i 1 }
    end.
    when "grp-goods" then do:
      if tog-tree = true then DO:
          if tog-obj = true then
            run rep/r-obor2g.p { rep/e-oborot.i 1 }
            else
            run rep/r-obor2d.p { rep/e-oborot.i 1 }
    end.
    else do:
      if Tog-lavel then do:
              if tog-obj = true then
                      run rep/r-obor2l.p { rep/e-oborot.i 1 }
                      else
                      run rep/r-obor2k.p { rep/e-oborot.i 1 }
                end.
                else do:
          if tog-obj = true then
            run rep/r-obor2y.p { rep/e-oborot.i 1 }
            else
            run rep/r-obor2n.p { rep/e-oborot.i 1 }
          end.
    End.
    end.
    when "prod/grp-goods" then do:
      if tog-obj = true then
        run rep/r-obor4y.p { rep/e-oborot.i 1 }
        else
        run rep/r-obor4n.p { rep/e-oborot.i 1 }
    end.
    when "grp-goods/prod" then do:
      if tog-obj = true then
        run rep/r-obor5y.p { rep/e-oborot.i 1 }
        else
        run rep/r-obor5n.p { rep/e-oborot.i 1 }
    end.
    when "vat-ps" then do:
      if tog-obj = true then
        run rep/r-obor6y.p { rep/e-oborot.i 1 }
        else
        run rep/r-obor6n.p { rep/e-oborot.i 1 }
    end.
  end case.
End.

/*Вывод в  excel   */

IF TOG-excel = TRUE then do:
  case Classify :
    when "no-classify" then do:
      if tog-obj = true then
        run rep/xlobor1y.p { rep/e-oborot.i 2 }
        else
          run rep/xlobor1n.p { rep/e-oborot.i 2 }
    end.

    when "prod" then do:
      if tog-obj = true then
        run rep/xlobor3y.p { rep/e-oborot.i 2 }
        else
        run rep/xlobor3n.p { rep/e-oborot.i 2 }
    end.
    when "grp-goods" then do:
      if tog-tree = true then DO:
          if tog-obj = true then
            run rep/xlobor2g.p { rep/e-oborot.i 2 }
            else
            run rep/xlobor2d.p { rep/e-oborot.i 2 }
      end.
      else do:
        if Tog-lavel then do:
                if tog-obj = true then
                     run rep/xlobor2l.p { rep/e-oborot.i 2 }
                else
                     run rep/xlobor2k.p { rep/e-oborot.i 2 }
          end.
          else do:
            if tog-obj = true then
                run rep/xlobor2y.p { rep/e-oborot.i 2 }
            else
                 run rep/xlobor2n.p { rep/e-oborot.i 2 }
          end.
      End.
    end.
    when "prod/grp-goods" then do:
      if tog-obj = true then
        run rep/xlobor4y.p { rep/e-oborot.i 2 }
        else
        run rep/xlobor4n.p { rep/e-oborot.i 2 }
    end.
    when "grp-goods/prod" then do:
      if tog-obj = true then
        run rep/xlobor5y.p { rep/e-oborot.i 2 }
        else
        run rep/xlobor5n.p { rep/e-oborot.i 2 }
    end.
    when "vat-ps" then do:
      if tog-obj = true then
        run rep/xlobor6y.p { rep/e-oborot.i 2 }
        else
        run rep/xlobor6n.p { rep/e-oborot.i 2 }
    end.
  end case.
End.

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
         run my-var in this-procedure .
         End.

  END CASE.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

