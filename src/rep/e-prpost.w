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

Оборот приходных партий товаров поставщика
Автор: Чернова Светлана Александровна
Дата создания: 18/03/01
Author: Svetlana Chernova
Creation date: 18/03/01

*/

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Оборот приходных партий товаров поставщика (закладка № 2)".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/r-page1.i  }
{ rep/rep-bt.i   }


CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */
define variable v-nn as integer   no-undo .
define variable State-source as  WIDGET-HANDLE.
define variable g#log as logical   no-undo .

define buffer cli-post for clients .
define new shared temp-table g#post no-undo
    field obj-type like ub.clients.obj-type
    field obj-code like ub.clients.obj-code
    field obj-name like ub.clients.obj-name
    INDEX pi IS UNIQUE PRIMARY obj-type obj-code.
define variable  post-grp_recids as character no-undo .
define variable ii as integer no-undo .

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
&Scoped-Define ENABLED-OBJECTS RECT-9 RECT-5 RECT-6 RECT-7 RECT-8 RADPost ~
PostName SortType Tog-obj Classify date1Rash date2Rash Showcost ~
Show-cost-Vat Showsale type-stor Cli-art SumsOnly Str
&Scoped-Define DISPLAYED-OBJECTS RADPost PostName SortType Tog-obj Classify ~
date1Rash date2Rash Showcost Show-cost-Vat Showsale Show-sale-Vat type-stor ~
Cli-art SumsOnly Str

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */
DEFINE VARIABLE PostName AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 31 BY 2.17 TOOLTIP "Список выбранных Поставщиков" NO-UNDO.

DEFINE VARIABLE date1Rash AS DATE FORMAT "99/99/9999":U
     LABEL "c"
     VIEW-AS FILL-IN
     SIZE 11.88 BY 1 NO-UNDO.

DEFINE VARIABLE date2Rash AS DATE FORMAT "99/99/9999":U
     LABEL "по"
     VIEW-AS FILL-IN
     SIZE 11.88 BY 1 NO-UNDO.

DEFINE VARIABLE Str AS CHARACTER FORMAT "X(256)":U INITIAL "Период для РН"
      VIEW-AS TEXT
     SIZE 14 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE var-lavel AS INTEGER FORMAT ">>9":U INITIAL 1
     VIEW-AS FILL-IN NATIVE
     SIZE 5 BY .79 NO-UNDO.

DEFINE VARIABLE var-lavel-2 AS INTEGER FORMAT ">>9":U INITIAL 1
     VIEW-AS FILL-IN NATIVE
     SIZE 5 BY .79 NO-UNDO.

DEFINE VARIABLE Classify AS CHARACTER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Без классификации", "no-classify":U,
"Группы поставщиков", "post":U,
"Группы товаров", "grp-goods":U,
"Группы поставщиков/Группы товаров", "post/grp-goods":U,
"Группы товаров/Группы поставщиков", "grp-goods/post":U
     SIZE 37.38 BY 4.63
     BGCOLOR 8 FGCOLOR 0  NO-UNDO.

DEFINE VARIABLE RADPost AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "все", 1,
"Выборочно", 2
     SIZE 12 BY 2.17 NO-UNDO.

DEFINE VARIABLE SortType AS CHARACTER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "по коду", "sort-code":U,
"по артикулу", "sort-article":U
     SIZE 14 BY 2.17
     BGCOLOR 8 FGCOLOR 0  NO-UNDO.

DEFINE VARIABLE type-stor AS INTEGER INITIAL 1
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "все", 1,
"выкуп", 2,
"консигнация", 3,
"мат.хранение", 4
     SIZE 16.25 BY 3.13 NO-UNDO.

DEFINE RECTANGLE RECT-5
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 48.38 BY 7.04.

DEFINE RECTANGLE RECT-6
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 19.63 BY 4.42.

DEFINE RECTANGLE RECT-7
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 48.38 BY 3.42.

DEFINE RECTANGLE RECT-8
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 48.38 BY 5.92.

DEFINE RECTANGLE RECT-9
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 19.63 BY 12.08.

DEFINE VARIABLE Cli-art AS LOGICAL INITIAL no
     LABEL "артикул поставщика":L
     VIEW-AS TOGGLE-BOX
     SIZE 21 BY .83 NO-UNDO.

DEFINE VARIABLE Show-cost-Vat AS LOGICAL INITIAL no
     LABEL "НДС в учетных ценах":L
     VIEW-AS TOGGLE-BOX
     SIZE 22.88 BY .83 NO-UNDO.

DEFINE VARIABLE Show-sale-Vat AS LOGICAL INITIAL no
     LABEL "НДС в ценах док-та":L
     VIEW-AS TOGGLE-BOX
     SIZE 22.88 BY .83 NO-UNDO.

DEFINE VARIABLE Showcost AS LOGICAL INITIAL yes
     LABEL "Учетные цены"
     VIEW-AS TOGGLE-BOX
     SIZE 15.38 BY .83 TOOLTIP "Показать суммы в учетных ценах" NO-UNDO.

DEFINE VARIABLE Showsale AS LOGICAL INITIAL no
     LABEL "Цены документа"
     VIEW-AS TOGGLE-BOX
     SIZE 17.38 BY .83 TOOLTIP "Показать суммы в ценах документа" NO-UNDO.

DEFINE VARIABLE SumsOnly AS LOGICAL INITIAL no
     LABEL "Только итоги":L
     VIEW-AS TOGGLE-BOX
     SIZE 19 BY .83 NO-UNDO.

DEFINE VARIABLE Tog-lavel AS LOGICAL INITIAL no
     LABEL "с уровня":L
     VIEW-AS TOGGLE-BOX
     SIZE 12.63 BY .79
     BGCOLOR 8 FGCOLOR 0  NO-UNDO.

DEFINE VARIABLE Tog-lavel-2 AS LOGICAL INITIAL no
     LABEL "с уровня":L
     VIEW-AS TOGGLE-BOX
     SIZE 12.63 BY .79
     BGCOLOR 8 FGCOLOR 0  NO-UNDO.

DEFINE VARIABLE Tog-obj AS LOGICAL INITIAL yes
     LABEL "Раздельно по объектам":L
     VIEW-AS TOGGLE-BOX
     SIZE 31 BY 1
     BGCOLOR 8 FGCOLOR 0  NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     RADPost AT ROW 2 COL 3 NO-LABEL
     PostName AT ROW 2 COL 15.38 NO-LABEL
     SortType AT ROW 2.54 COL 53 NO-LABEL
     Tog-obj AT ROW 5.54 COL 3
     Classify AT ROW 6.79 COL 3 NO-LABEL
     date1Rash AT ROW 7.29 COL 54 COLON-ALIGNED
     Tog-lavel-2 AT ROW 7.75 COL 28.25
     var-lavel-2 AT ROW 7.75 COL 39.13 COLON-ALIGNED NO-LABEL
     date2Rash AT ROW 8.46 COL 54 COLON-ALIGNED
     var-lavel AT ROW 8.58 COL 39.13 COLON-ALIGNED NO-LABEL
     Tog-lavel AT ROW 8.63 COL 28.25
     Showcost AT ROW 12.5 COL 30.13
     Show-cost-Vat AT ROW 12.67 COL 2.63
     Showsale AT ROW 13.33 COL 30.13
     Show-sale-Vat AT ROW 13.54 COL 2.63
     type-stor AT ROW 14.29 COL 30.13 NO-LABEL
     Cli-art AT ROW 15.42 COL 2.63
     SumsOnly AT ROW 16.33 COL 2.63
     Str AT ROW 6.33 COL 51.63 COLON-ALIGNED NO-LABEL
     "Выбор поставщика:" VIEW-AS TEXT
          SIZE 19.38 BY .67 AT ROW 1.25 COL 7.25
          FGCOLOR 4
     "Сортировка :" VIEW-AS TEXT
          SIZE 13.63 BY .75 AT ROW 1.46 COL 53
          FGCOLOR 4
     "Классификация :" VIEW-AS TEXT
          SIZE 15 BY .75 AT ROW 4.83 COL 7.25
          FGCOLOR 4
     "Показать :" VIEW-AS TEXT
          SIZE 11.5 BY .75 AT ROW 11.83 COL 7.25
          FGCOLOR 4
     RECT-9 AT ROW 5.5 COL 50.75
     RECT-5 AT ROW 4.54 COL 1.75
     RECT-6 AT ROW 1.04 COL 50.75
     RECT-7 AT ROW 1.04 COL 1.75
     RECT-8 AT ROW 11.63 COL 1.75
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
         WIDTH              = 70.38.
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

ASSIGN
       Cli-art:HIDDEN IN FRAME F-Main           = TRUE.

ASSIGN
       PostName:READ-ONLY IN FRAME F-Main        = TRUE.

/* SETTINGS FOR TOGGLE-BOX Show-sale-Vat IN FRAME F-Main
   NO-ENABLE                                                            */
/* SETTINGS FOR TOGGLE-BOX Tog-lavel IN FRAME F-Main
   NO-DISPLAY NO-ENABLE                                                 */
/* SETTINGS FOR TOGGLE-BOX Tog-lavel-2 IN FRAME F-Main
   NO-DISPLAY NO-ENABLE                                                 */
/* SETTINGS FOR FILL-IN var-lavel IN FRAME F-Main
   NO-DISPLAY NO-ENABLE                                                 */
/* SETTINGS FOR FILL-IN var-lavel-2 IN FRAME F-Main
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
  /*  if Classify  Begins "post":U OR
       Classify  Begins "grp-goods":U         then
        enable SumsOnly with frame {&FRAME-NAME} .

   if Classify = "no-classify":U
      Then do:
            SumsOnly = FALSE .
            display SumsOnly with frame {&FRAME-NAME} .
            disable SumsOnly with frame {&FRAME-NAME} .
        end.
*/
   if Classify = "grp-goods":U
         Then do:
            display TOG-lavel   with frame {&FRAME-NAME} .
            enable  TOG-lavel   with frame {&FRAME-NAME} .
        end.
         Else do:
            display  TOG-lavel  var-Lavel with frame {&FRAME-NAME} .
            disable  TOG-lavel  var-Lavel with frame {&FRAME-NAME} .
        end.
 if Classify = "post":U
         Then do:
            display TOG-lavel-2   with frame {&FRAME-NAME} .
            enable  TOG-lavel-2   with frame {&FRAME-NAME} .
        end.
         Else do:
            display  TOG-lavel-2  var-Lavel-2 with frame {&FRAME-NAME} .
            disable  TOG-lavel-2  var-Lavel-2 with frame {&FRAME-NAME} .
        end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME RADPost
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL RADPost s-object
ON VALUE-CHANGED OF RADPost IN FRAME F-Main
DO:
  Assign RadPost.
  for each g#post share-lock : delete g#post. end.
  Case RAdPost :
  when 1 then DO:
          Assign  Postname = {&all}.
          Display PostName with frame {&FRAME-NAME} .
       END.
  when 2 then
        do:
            run ref/cli-all.w
                ( my-handle
                , "b-sel,b-mark"
                , {&pro}
                , {&all}
                , {&current}
                , ?
                , ",,,,,,NO,,"
                , ?
                , output post-grp_recids ) .
            if post-grp_recids = "" then do:
                 Assign  Postname = {&all} radpost = 1.
                 Display PostName radpost with frame {&FRAME-NAME} .
            end.
            else do:
                Assign  Postname = ''.
                v-nn = num-entries( post-grp_recids ) .
                DO ii = 1 TO num-entries( post-grp_recids ) :
                    FIND cli-post WHERE recid( cli-post ) = int(entry( ii, post-grp_recids )) NO-LOCK.
                    create g#post.
                    assign
                    g#post.obj-type = cli-post.obj-type
                    g#post.obj-code = cli-post.obj-code
                    g#post.obj-name = cli-post.obj-name
                    Postname = PostName + cli-post.obj-name + chr(10).
                END.
                 Display PostName with frame {&FRAME-NAME} .
            end.
        end.
  End case.
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Showsale
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Showsale s-object
ON VALUE-CHANGED OF Showsale IN FRAME F-Main /* Цены документа */
DO:
assign Showsale.
  if showsale then DO:
                  type-stor = 1 .
                  type-stor:screen-value = '1' .

                  disable  type-stor with frame {&frame-name}.
                  enable Show-sale-Vat  with frame {&frame-name}.
                  End.
              else do:
                                     Show-sale-Vat = no.
                   enable  type-stor with frame {&frame-name}.
                   disable Show-Sale-vat  with frame {&frame-name} .
                    display Show-Sale-vat  with frame {&frame-name}.

                   end.
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


&Scoped-define SELF-NAME Tog-lavel-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Tog-lavel-2 s-object
ON VALUE-CHANGED OF Tog-lavel-2 IN FRAME F-Main /* с уровня */
DO:
   Assign tog-lavel-2.
  if tog-lavel-2 = TRUE
        Then do:
            display  var-Lavel-2  with frame {&FRAME-NAME} .
            enable   var-Lavel-2  with frame {&FRAME-NAME} .
        end.
         Else do:
            display    var-Lavel-2 with frame {&FRAME-NAME} .
            disable    var-Lavel-2 with frame {&FRAME-NAME} .
        end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Tog-obj
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Tog-obj s-object
ON VALUE-CHANGED OF Tog-obj IN FRAME F-Main /* Раздельно по объектам */
DO:
      assign Tog-obj.
  if tog-obj = false then do:
    assign
      Classify    = "no-classify"
      SumsOnly    = true
      type-stor   = 1
      tog-Lavel-2 = false
      tog-Lavel   = false
      .

      display Classify SumsOnly type-stor   var-Lavel-2 var-Lavel tog-Lavel-2 tog-Lavel with frame {&frame-name}.
      disable Classify SumsOnly type-stor  var-Lavel-2 var-Lavel tog-Lavel-2 tog-Lavel  with frame {&frame-name}.
  End.
  Else do:
    display Classify SumsOnly type-stor with frame {&frame-name}.
    enable Classify SumsOnly type-stor  with frame {&frame-name}.
  End.

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
   Tog-obj:screen-value in frame {&frame-name} = 'yes':U.
    var-lavel:screen-value in frame {&frame-name} = '1'.
    var-lavel-2:screen-value in frame {&frame-name} = '1'.
    { cmp/cr-objls.i v-cntxt-obj-type v-cntxt-obj-code }


str:screen-value in frame {&frame-name}       = 'Период для РН'.
date1Rash:screen-value in frame {&frame-name} = string(x-Date-Start,"99/99/99").
date2Rash:screen-value in frame {&frame-name} = string(x-Date-End,"99/99/99")   .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-report s-object
PROCEDURE my-report :
/*------------------------------------------------------------------------------
  Purpose:     здесь происходит вызов  процедуры отчета с любыми параметрами
------------------------------------------------------------------------------*/
define variable  g#ok as logical no-undo .
 g#ok = true .
message "Запускать утилиту <<СОЗДАНИЕ АТРИБУТОВ ПАРТИЙ>>  ?"  view-as alert-box question
   buttons yes-no
   update g#ok.
 if   g#ok then
      run utl/objprtat.p ( my-handle,  false  ).

 run rep/r-prpost.p
    (input v-cntxt-obj-code ,
    input v-cntxt-obj-type ,
    input base-type  ,
    input base-code  ,
    Cli-art,
    date1Rash ,
    date2Rash ,
    PostName,
    type-stor ,
    Show-cost-VAt ,
    Show-sale-VAt ,
    input Classify   ,
    input SortType   ,
    input SumsOnly   ,
    input tog-obj    ,
    input tog-lavel  ,
    input var-lavel  ,
    input tog-lavel-2  ,
    input var-lavel-2  ) .

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
Cli-art date1Rash date2Rash PostName  RADPost Show-cost-VAt Show-sale-VAt
Classify  SortType Str SumsOnly Tog-obj type-stor showcost  showsale
Tog-lavel  var-lavel Tog-lavel-2  Var-lavel-2 .
show-cost =  showcost .
show-sale =  showsale .


ReportNAme = "ОБОРОТ ПРИХОДНЫХ ПАРТИЙ ТОВАРОВ ПОСТАВЩИКА" .
{ rep/claslabl.i }
ReportHeader = "Поставщики : " + PostName + chr(10).

ReportHeader = ReportHeader + "Классификация : " + t-Class.

ReportHeader = ReportHeader +
               (if tog-lavel  then "    Итоги с уровня товаров "  + String(var-lavel)  else " "    ).
ReportHeader = ReportHeader +
               (if tog-lavel-2  then "    Итоги с уровня поставщиков "  + String(var-lavel-2)  else " "    ).

ReportHeader = ReportHeader  + chr(10).

ReportHeader = ReportHeader +
               "Сортировка " + t-Sort + chr(10) +
               "Показать : " +
               (if SumsOnly      then "Только итоги, "  else " "             ) +
               (if Show-Cost     then "Суммы в учетных ценах, "  else " "    ) +
               (if Show-Cost-vat then "НДС в учетных ценах, "  else " "      ) +
               (if Show-Sale     then "Суммы в ценах документа, "  else " "  ) +
               (if Show-Sale-vat then "НДС в ценах документа, "  else " "    ) +
               (if Cli-art       then "Артиклы поставщика, "  else " "       ) .
ReportHeader =  ReportHeader  + chr(10) + Entry(((type-stor * 2) - 1), type-stor:RADIO-BUTTONS) .
ReportHeader =  ReportHeader  + chr(10) + "Период расхода с " + string(date1Rash,"99/99/9999") + ' по ' + string( date2Rash,"99/99/9999").

 sheetf.Excel-Column-Lable = "
 Код,
 Артикул,
 Название товара,
 Ед.изм,
 т/у,
 Приход внешний,,,,,
 Расход внешний,,,,,
 Касса,,,,,
 Возврат внешний,,,,,
 Возврат поставщику,,,,,
 Инвентаризация,,,,,
 Переоценка,,,,,
 Списание,,,,,
 "  + chr(10).
 sheetf.Excel-Column-Lable = sheetf.Excel-Column-Lable + ",,,,,
 кол-во,учет.сумма,учет.НДС,док-т.сумма ,док-т.НДС,
 кол-во,учет.сумма,учет.НДС,док-т.сумма ,док-т.НДС,
 кол-во,учет.сумма,учет.НДС,док-т.сумма ,док-т.НДС,
 кол-во,учет.сумма,учет.НДС,док-т.сумма ,док-т.НДС,
 кол-во,учет.сумма,учет.НДС,док-т.сумма ,док-т.НДС,
 кол-во,учет.сумма,учет.НДС,док-т.сумма ,док-т.НДС,
 кол-во,учет.сумма,учет.НДС,док-т.сумма ,док-т.НДС,
 кол-во,учет.сумма,учет.НДС,док-т.сумма ,док-т.НДС, ".

 sheetf.Sizes = "10,16,60,7,3," + fill('13,',40).
 Sheetf.ColFOrmat = "2=@;3=@"  .
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