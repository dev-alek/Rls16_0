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

Прайс-лист с фото товаров (закладка № 2)

Автор: Чернова Светлана Александровна
Дата создания: 20/10/00
Author: Svetlana Chernova
Creation date: 20/10/00

*/

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Прайс-лист с фото товаров (закладка № 2)".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/r-page1.i  }
{ rep/rep-bt.i   }
{ gbl/usr-flt.i  }


CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

define variable State-source as  WIDGET-HANDLE.
define variable g#log as logical   no-undo .
define variable s-ref-rec as character no-undo. /* Список выбранных групп */

define buffer buf_buyer-group for ub.buyer-group.

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
&Scoped-Define ENABLED-OBJECTS RECT-6 IMAGE-1 IMAGE-2 f-name f-dostavka ~
SortType f-orderinfo f-action btn-grp EDITOR-grp f-skidki f-skidki-2 ~
f-skidki-3 t-minpart T-ost f-skidki-4 v-colsize f-skidki-5 f-skidki-6 ~
f-telefon-1 f-skidki-7 f-telefon-2 f-skidki-8 f-hot f-info 
&Scoped-Define DISPLAYED-OBJECTS f-name f-dostavka SortType f-orderinfo ~
f-action EDITOR-grp f-skidki f-skidki-2 f-skidki-3 t-minpart T-ost ~
f-skidki-4 v-colsize f-skidki-5 f-skidki-6 f-telefon-1 f-skidki-7 ~
f-telefon-2 f-skidki-8 f-hot f-info 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */
&Scoped-define List-2 btn-grp 

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */
DEFINE BUTTON btn-grp 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "" 
     SIZE 3 BY .79 TOOLTIP "Выбор из списка".

DEFINE VARIABLE EDITOR-grp AS CHARACTER 
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 37 BY 2.88 NO-UNDO.

DEFINE VARIABLE f-action AS CHARACTER 
     VIEW-AS EDITOR
     SIZE 37.63 BY 1 TOOLTIP "Оптовая цена действует при покупке 1 минимальной партии"
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE f-hot AS CHARACTER 
     VIEW-AS EDITOR
     SIZE 89 BY 1 TOOLTIP "Указывайте степень утепления, если это необходимо!"
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE f-info AS CHARACTER 
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 88.63 BY 2
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE f-orderinfo AS CHARACTER 
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 37.63 BY 1.63 TOOLTIP "Заказы по текущему прайс-листу присылайте не позднее 15-ти"
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE f-skidki AS CHARACTER 
     VIEW-AS EDITOR
     SIZE 25 BY 1 TOOLTIP "Информация по скидкам"
     BGCOLOR 15 FONT 4 NO-UNDO.

DEFINE VARIABLE f-skidki-2 AS CHARACTER 
     VIEW-AS EDITOR
     SIZE 25 BY 1 TOOLTIP "Информация по скидкам"
     BGCOLOR 15 FONT 4 NO-UNDO.

DEFINE VARIABLE f-skidki-3 AS CHARACTER 
     VIEW-AS EDITOR
     SIZE 25 BY 1 TOOLTIP "Информация по скидкам"
     BGCOLOR 15 FONT 4 NO-UNDO.

DEFINE VARIABLE f-skidki-4 AS CHARACTER 
     VIEW-AS EDITOR
     SIZE 25 BY 1 TOOLTIP "Информация по скидкам"
     BGCOLOR 15 FONT 4 NO-UNDO.

DEFINE VARIABLE f-skidki-5 AS CHARACTER 
     VIEW-AS EDITOR
     SIZE 25 BY 1 TOOLTIP "Информация по скидкам"
     BGCOLOR 15 FONT 4 NO-UNDO.

DEFINE VARIABLE f-skidki-6 AS CHARACTER 
     VIEW-AS EDITOR
     SIZE 25 BY 1 TOOLTIP "Информация по скидкам"
     BGCOLOR 15 FONT 4 NO-UNDO.

DEFINE VARIABLE f-skidki-7 AS CHARACTER 
     VIEW-AS EDITOR
     SIZE 25 BY 1 TOOLTIP "Информация по скидкам"
     BGCOLOR 15 FONT 4 NO-UNDO.

DEFINE VARIABLE f-skidki-8 AS CHARACTER 
     VIEW-AS EDITOR
     SIZE 25 BY 1 TOOLTIP "Информация по скидкам"
     BGCOLOR 15 FONT 4 NO-UNDO.

DEFINE VARIABLE f-dostavka AS CHARACTER FORMAT "X(256)":U 
     LABEL "Ожидаемая дата поставки" 
     VIEW-AS FILL-IN 
     SIZE 37.63 BY 1 TOOLTIP "Прибытие, Ожидаемая дата поставки"
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE f-name AS CHARACTER FORMAT "X(256)":U 
     LABEL "Название" 
     VIEW-AS FILL-IN 
     SIZE 63.63 BY 1 TOOLTIP "Название прайс-листа"
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE f-telefon-1 AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 31.63 BY 1 TOOLTIP "Телефон 1"
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE f-telefon-2 AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 31.63 BY 1 TOOLTIP "Телефон 2"
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE v-colsize AS INTEGER FORMAT ">,>>9":U INITIAL 50 
     LABEL "Высота картинок" 
     VIEW-AS FILL-IN 
     SIZE 5.63 BY 1 TOOLTIP "Высота картинок в пиксилях"
     BGCOLOR 15  NO-UNDO.

DEFINE IMAGE IMAGE-1
     FILENAME "exe/own-logo.jpg":U TRANSPARENT
     SIZE 9.63 BY 7.5.

DEFINE IMAGE IMAGE-2
     FILENAME "exe/own-tel.jpg":U TRANSPARENT
     SIZE 26.63 BY 3.38.

DEFINE VARIABLE SortType AS CHARACTER 
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS 
          "по коду", "sort-code":U,
"по артикулу", "sort-artic":U,
"по наименов.", "sort-name":U
     SIZE 14 BY 2.75 NO-UNDO.

DEFINE RECTANGLE RECT-6
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 15.63 BY 4.04.

DEFINE VARIABLE t-minpart AS LOGICAL INITIAL no 
     LABEL "Обязательное наличие мин.партии" 
     VIEW-AS TOGGLE-BOX
     SIZE 38 BY .83 NO-UNDO.

DEFINE VARIABLE T-ost AS LOGICAL INITIAL no 
     LABEL "Свободный остаток больше мин.партии" 
     VIEW-AS TOGGLE-BOX
     SIZE 39 BY .79 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     f-name AT ROW 1.21 COL 26.63 COLON-ALIGNED WIDGET-ID 2
     f-dostavka AT ROW 2.21 COL 42.63 COLON-ALIGNED WIDGET-ID 4
     SortType AT ROW 2.25 COL 3 NO-LABEL
     f-orderinfo AT ROW 3.21 COL 44.63 NO-LABEL WIDGET-ID 26
     f-action AT ROW 5.04 COL 45 NO-LABEL WIDGET-ID 28
     btn-grp AT ROW 6.5 COL 41 WIDGET-ID 76
     EDITOR-grp AT ROW 6.5 COL 45 NO-LABEL WIDGET-ID 70
     f-skidki AT ROW 7.79 COL 3 NO-LABEL WIDGET-ID 22
     f-skidki-2 AT ROW 8.79 COL 3 NO-LABEL WIDGET-ID 34
     f-skidki-3 AT ROW 9.79 COL 3 NO-LABEL WIDGET-ID 36
     t-minpart AT ROW 9.79 COL 29 WIDGET-ID 78
     T-ost AT ROW 10.75 COL 29 WIDGET-ID 68
     f-skidki-4 AT ROW 10.79 COL 3 NO-LABEL WIDGET-ID 38
     v-colsize AT ROW 11.5 COL 83.63 COLON-ALIGNED WIDGET-ID 32
     f-skidki-5 AT ROW 11.79 COL 3 NO-LABEL WIDGET-ID 40
     f-skidki-6 AT ROW 12.79 COL 3 NO-LABEL WIDGET-ID 42
     f-telefon-1 AT ROW 13.21 COL 58 COLON-ALIGNED NO-LABEL WIDGET-ID 6
     f-skidki-7 AT ROW 13.79 COL 3 NO-LABEL WIDGET-ID 44
     f-telefon-2 AT ROW 14.29 COL 58 COLON-ALIGNED NO-LABEL WIDGET-ID 8
     f-skidki-8 AT ROW 14.79 COL 3 NO-LABEL WIDGET-ID 46
     f-hot AT ROW 16.67 COL 3 NO-LABEL WIDGET-ID 30
     f-info AT ROW 17.75 COL 3 NO-LABEL WIDGET-ID 20
     "../exe/own-tel.jpg" VIEW-AS TEXT
          SIZE 19 BY .67 AT ROW 12.21 COL 35 WIDGET-ID 18
     "Условия оформления заказа и оплаты:" VIEW-AS TEXT
          SIZE 25 BY .67 AT ROW 3.5 COL 18.75 WIDGET-ID 54
     "Доп. информация:" VIEW-AS TEXT
          SIZE 20.25 BY .67 AT ROW 15.92 COL 1.75 WIDGET-ID 58
     "Группа" VIEW-AS TEXT
          SIZE 8 BY .63 AT ROW 6.5 COL 32 WIDGET-ID 72
     "Телефоны:" VIEW-AS TEXT
          SIZE 9.63 BY .67 AT ROW 12.38 COL 60.25 WIDGET-ID 50
     "Информация о скидках:" VIEW-AS TEXT
          SIZE 24 BY .67 AT ROW 7.21 COL 1.63 WIDGET-ID 52
     "../exe/own-logo.jpg" VIEW-AS TEXT
          SIZE 19.63 BY .67 AT ROW 10.25 COL 72.63 WIDGET-ID 16
     "и оплаты:" VIEW-AS TEXT
          SIZE 9.63 BY .67 AT ROW 4.13 COL 34.75 WIDGET-ID 56
     "Оптовая цена действует при покупке:" VIEW-AS TEXT
          SIZE 35.63 BY .67 AT ROW 5.29 COL 9 WIDGET-ID 48
     "Покупателей" VIEW-AS TEXT
          SIZE 12 BY .63 AT ROW 7.42 COL 32 WIDGET-ID 74
     "Сортировка :" VIEW-AS TEXT
          SIZE 11.63 BY .75 AT ROW 1.58 COL 4.63
          FGCOLOR 4 
     RECT-6 AT ROW 1.25 COL 2
     IMAGE-1 AT ROW 2.5 COL 83 WIDGET-ID 12
     IMAGE-2 AT ROW 13.13 COL 30 WIDGET-ID 14
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1 SCROLLABLE 
         BGCOLOR 8 FGCOLOR 0 .


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
         HEIGHT             = 18.92
         WIDTH              = 91.75.
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

/* SETTINGS FOR BUTTON btn-grp IN FRAME F-Main
   2                                                                    */
ASSIGN 
       EDITOR-grp:READ-ONLY IN FRAME F-Main        = TRUE.

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

&Scoped-define SELF-NAME btn-grp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btn-grp s-object
ON CHOOSE OF btn-grp IN FRAME F-Main
DO:
  define variable ix        as integer no-undo.
  define variable  lns-cnt      as integer    no-undo .
  define variable v-ref-rec as character no-undo.
  run ref/gr-bupr.w (input  my-handle , "b-sel", input-output v-ref-rec ).
  s-ref-rec = v-ref-rec.
  EDITOR-grp = "".
  for first buf_buyer-group where recid(buf_buyer-group) = int(s-ref-rec):
    if error-status :error then do:
      return no-apply.
    end.
    assign
      EDITOR-grp = EDITOR-grp + buf_buyer-group.name + {&new-line}.
    .
  end.
  display
    EDITOR-grp
    with frame {&frame-name}
  .
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-initialize s-object 
PROCEDURE local-initialize :
/*------------------------------------------------------------------------------
  Purpose:     Override standard ADM method
  Notes:
------------------------------------------------------------------------------*/
define variable v-void-log    as logical   no-undo .
define variable v-naim    as character    no-undo.
define variable v-list    as character    no-undo.


  /* Code placed here will execute PRIOR to standard behavior. */

  /* Dispatch standard ADM method.                             */
  RUN dispatch IN THIS-PROCEDURE ( INPUT 'initialize':U ) .

  /* Code placed here will execute AFTER standard behavior.    */

   run uf-get ( input {&uf-prphoto}
                     , input v-cntxt-userid
                     , output v-list
                     , output v-naim
                     , output v-void-log
                     , output v-void-log
                     , output v-void-log
                     , output v-void-log
                     ) .
 if num-entries(v-list, {&delim-par})  >= 10  then do:
   assign
     f-name        = entry(1,v-list, {&delim-par})
     f-dostavka    = entry(2,v-list, {&delim-par})
     f-telefon-1   = entry(3,v-list, {&delim-par})
     f-telefon-2   = entry(4,v-list, {&delim-par})
     f-info        = entry(5,v-list, {&delim-par})
     f-orderinfo   = entry(6,v-list, {&delim-par})
     f-action      = entry(7,v-list, {&delim-par})
     f-skidki      = entry(8,v-list, {&delim-par})
     f-skidki-2    = entry(9,v-list, {&delim-par})
     f-skidki-3    = entry(10,v-list, {&delim-par})
     f-skidki-4    = entry(11,v-list, {&delim-par})
     f-skidki-5    = entry(12,v-list, {&delim-par})
     f-skidki-6    = entry(13,v-list, {&delim-par})
     f-skidki-7    = entry(14,v-list, {&delim-par})
     f-skidki-8    = entry(15,v-list, {&delim-par})
     v-colsize     = integer(entry(16,v-list, {&delim-par}))
     f-hot         = entry(17,v-list, {&delim-par})
   .
   
    /* Новые параметры (чтобы не падало при первом запуске) */
    assign
    t-minpart = logical(entry(18,v-list, {&delim-par}))
    T-ost = logical(entry(19,v-list, {&delim-par}))
    s-ref-rec = entry(20,v-list, {&delim-par})
    no-error.
    /* Заполним EDITOR-grp, если были выбраны группы покупателей */
    for first buf_buyer-group where recid (buf_buyer-group) = int(s-ref-rec):
        EDITOR-grp = buf_buyer-group.name.
    end.
    
     display
     f-name
     f-dostavka
     f-telefon-1
     f-telefon-2
     f-info
     f-orderinfo
     f-action
     f-skidki
     f-skidki-2
     f-skidki-3
     f-skidki-4
     f-skidki-5
     f-skidki-6
     f-skidki-7
     f-skidki-8
     v-colsize
     f-hot
     t-minpart
     T-ost
     EDITOR-grp
     with frame {&frame-name} .

 end.
 else do:
   assign
     f-name        = "МЯГКАЯ ИГРУШКА производство Швеция"
     f-dostavka    = "- апрель 2010"
     f-telefon-1   = "(495) 980-98-98"
     f-telefon-2   = "(495) 980-98-91"
     f-info        = "Внимание! Компания <Бизнес Букет> оставляет за собой право изменения цен при изменении курса валют более чем на 50 коп. от курса установленного ЦБ."
     f-orderinfo =  "Заказы по текущему прайс-листу присылайте не позднее 15-ти часов в субботу. Растения отпускаются по предоплате."
     f-action    = '1 минимальной партии'
     f-skidki    = 'от 1000 скидка 5%'
     v-colsize   =  50
     f-hot       = "Указывайте степень утепления, если это необходимо!"
   .

     display
     f-name
     f-dostavka
     f-telefon-1
     f-telefon-2
     f-info
     f-orderinfo
     f-action
     f-skidki
     v-colsize
     f-hot
     f-skidki-2
     f-skidki-3
     f-skidki-4
     f-skidki-5
     f-skidki-6
     f-skidki-7
     f-skidki-8
     t-minpart
     T-ost
     EDITOR-grp
     with frame {&frame-name} .

 end.



END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-view s-object 
PROCEDURE local-view :
/*------------------------------------------------------------------------------
  Purpose:     Override standard ADM method
  Notes:
------------------------------------------------------------------------------*/

  /* Code placed here will execute PRIOR to standard behavior. */

  /* Dispatch standard ADM method.                             */
  RUN dispatch IN THIS-PROCEDURE ( INPUT 'view':U ) .

  /* Code placed here will execute AFTER standard behavior.    */




END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-report s-object 
PROCEDURE my-report :
/*------------------------------------------------------------------------------
  Purpose:     здесь происходит вызов  процедуры отчета с любыми пареметрами
------------------------------------------------------------------------------*/
  run rep/r-prphot.p (
   input my-handle,
   input SortType,
   input f-name ,
   input f-dostavka  ,
   input f-telefon-1 ,
   input f-telefon-2 ,
   input f-info ,
   input f-orderinfo  ,
   input f-action     ,
   input f-skidki     ,
   input f-skidki-2   ,
   input f-skidki-3   ,
   input f-skidki-4   ,
   input f-skidki-5   ,
   input f-skidki-6   ,
   input f-skidki-7   ,
   input f-skidki-8   ,
   input v-colsize    ,
   input f-hot        ,
   input t-minpart,
   input T-ost   ,
   input s-ref-rec
   ).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-var s-object 
PROCEDURE my-var :
/*------------------------------------------------------------------------------
  Purpose:     здесь происходит вызов  значений переменных
  например  Название отчета, может быть еще пример шапки???
------------------------------------------------------------------------------*/
assign frame {&frame-name}  SortType
        f-dostavka
        f-name
        f-telefon-1
        f-telefon-2
        f-info
        f-orderinfo
        f-action
        f-skidki
        f-skidki-2
        f-skidki-3
        f-skidki-4
        f-skidki-5
        f-skidki-6
        f-skidki-7
        f-skidki-8
        v-colsize
        f-hot        
        T-ost
        t-minpart
       .

x-date-end = x-date-alone.

 sheetf.Excel-Column-Lable =
           "Артикул"
  + ","  + "Код"
  + ","  + "Название товара"
  + ","  + "Опт. цена {&abbr_rub}"
  + ","  + "Мин.опт. партия шт"
  + ","  + "Фото"
  + ","  + "ВАШ ЗАКАЗ"
  .

 sheetf.make-correct = "".
 sheetf.sizes = "15,10,20,8,8,20,10,".
 Sheetf.Bas-File = "exe/r-prphot.bas" .


define variable v-void-log    as logical   no-undo .
define variable v-naim    as character    no-undo.
define variable v-list    as character    no-undo.

 v-List =
    f-name + {&delim-par} +
    f-dostavka  + {&delim-par} +
    f-telefon-1 + {&delim-par} +
    f-telefon-2 + {&delim-par} +
    f-info      + {&delim-par} +
    f-orderinfo + {&delim-par} +
    f-action    + {&delim-par} +
    f-skidki    + {&delim-par} +
    f-skidki-2  + {&delim-par} +
    f-skidki-3  + {&delim-par} +
    f-skidki-4  + {&delim-par} +
    f-skidki-5  + {&delim-par} +
    f-skidki-6  + {&delim-par} +
    f-skidki-7  + {&delim-par} +
    f-skidki-8  + {&delim-par} +
    string(v-colsize) + {&delim-par} +
    f-hot + {&delim-par} +
    string(t-minpart) + {&delim-par} +
    string(t-ost) + {&delim-par} +
    s-ref-rec.


  run uf-set in this-procedure (
     input  {&uf-prphoto}
    ,input  v-cntxt-userid
    ,input v-List
    ,input v-Naim
    ,input v-void-log
    ,input v-void-log
    ,input v-void-log
    ,input v-void-log
)  no-error .

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

