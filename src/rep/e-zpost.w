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

Состояние запаса по поставщикам (закладка № 2)

Автор: Чернова Светлана Александровна
Дата создания: 09/08/05
Author: Svetlana Chernova
Creation date: 09/08/05

Created: 14/03/01

*/

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Состояние запаса по поставщикам (закладка № 2)".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/r-page1.i  }
{ rep/rep-bt.i   }
{ gbl/getsect.i def }

CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

define variable State-source as  WIDGET-HANDLE.
def buffer cli-post for clients .
def New SHARED temp-table g#post NO-UNDO
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

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME F-Main

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS RECT-8 RECT-9 RECT-5 RECT-7 RECT-6 PostName ~
RADPost SortType Tog-obj type-stor Classify ShowZero SumsOnly
&Scoped-Define DISPLAYED-OBJECTS PostName RADPost SortType Tog-obj ~
type-stor Classify ShowZero SumsOnly

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */
DEFINE VARIABLE PostName AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 31 BY 2.46 TOOLTIP "Список выбранных Поставщиков"
     FONT 4 NO-UNDO.

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
"Группы товаров/Группы поставщиков", "grp-goods/post":U,
"Производители", "prod":U
     SIZE 38.5 BY 5.17 NO-UNDO.

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
"по артикулу", "sort-article":U,
"по наимен.", "sort-name":U
     SIZE 14 BY 2.17 NO-UNDO.

DEFINE VARIABLE type-stor AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "все", 1,
"выкуп", 2,
"консигнация", 3,
"мат.хранение", 4,
"cтарая консигнация", 5
     SIZE 21.88 BY 4.17 NO-UNDO.

DEFINE RECTANGLE RECT-5
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 45.75 BY 7.63.

DEFINE RECTANGLE RECT-6
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 23.13 BY 4.42.

DEFINE RECTANGLE RECT-7
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 45.75 BY 3.42.

DEFINE RECTANGLE RECT-8
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 45.75 BY 5.42.

DEFINE RECTANGLE RECT-9
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 23.13 BY 12.08.

DEFINE VARIABLE ShowZero AS LOGICAL INITIAL no
     LABEL "Нулевые остатки":L
     VIEW-AS TOGGLE-BOX
     SIZE 23.25 BY .83 NO-UNDO.

DEFINE VARIABLE SumsOnly AS LOGICAL INITIAL no
     LABEL "Только итоги":L
     VIEW-AS TOGGLE-BOX
     SIZE 19 BY .83 NO-UNDO.

DEFINE VARIABLE Tog-lavel AS LOGICAL INITIAL no
     LABEL "с уровня":L
     VIEW-AS TOGGLE-BOX
     SIZE 12.63 BY .79 NO-UNDO.

DEFINE VARIABLE Tog-lavel-2 AS LOGICAL INITIAL no
     LABEL "с уровня":L
     VIEW-AS TOGGLE-BOX
     SIZE 12.63 BY .79 NO-UNDO.

DEFINE VARIABLE Tog-obj AS LOGICAL INITIAL yes
     LABEL "Раздельно по объектам":L
     VIEW-AS TOGGLE-BOX
     SIZE 38.25 BY 1 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     PostName AT ROW 1.92 COL 15.38 NO-LABEL
     RADPost AT ROW 2 COL 2.75 NO-LABEL
     SortType AT ROW 2.5 COL 51.88 NO-LABEL
     Tog-obj AT ROW 5.54 COL 2.75
     type-stor AT ROW 5.92 COL 48.13 NO-LABEL
     Classify AT ROW 6.79 COL 2.75 NO-LABEL
     Tog-lavel-2 AT ROW 7.75 COL 28.25
     var-lavel-2 AT ROW 7.75 COL 39.13 COLON-ALIGNED NO-LABEL
     var-lavel AT ROW 8.58 COL 39.13 COLON-ALIGNED NO-LABEL
     Tog-lavel AT ROW 8.63 COL 28.25
     ShowZero AT ROW 16.58 COL 2.75
     SumsOnly AT ROW 16.58 COL 27
     "Классификация :" VIEW-AS TEXT
          SIZE 15 BY .75 AT ROW 4.83 COL 7.13
          FGCOLOR 4
     "Сортировка :" VIEW-AS TEXT
          SIZE 13.63 BY .75 AT ROW 1.42 COL 51.88
          FGCOLOR 4
     "Показать :" VIEW-AS TEXT
          SIZE 11.5 BY .75 AT ROW 12.33 COL 7
          FGCOLOR 4
     "Выбор поставщика:" VIEW-AS TEXT
          SIZE 19.38 BY .67 AT ROW 1.25 COL 7.13
          FGCOLOR 4
     RECT-8 AT ROW 12.13 COL 1.75
     RECT-9 AT ROW 5.5 COL 47.75
     RECT-5 AT ROW 4.5 COL 1.75
     RECT-7 AT ROW 1.04 COL 1.75
     RECT-6 AT ROW 1.04 COL 47.75
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
   NOT-VISIBLE FRAME-NAME Size-to-Fit                                   */
ASSIGN
       FRAME F-Main:SCROLLABLE       = FALSE
       FRAME F-Main:HIDDEN           = TRUE.

ASSIGN
       PostName:READ-ONLY IN FRAME F-Main        = TRUE.

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
            , {&all}
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
      ShowZero    = false
      tog-Lavel-2 = false
      tog-Lavel   = false
      .

      display Classify SumsOnly type-stor ShowZero  var-Lavel-2 var-Lavel tog-Lavel-2 tog-Lavel with frame {&frame-name}.
      disable Classify SumsOnly type-stor  ShowZero var-Lavel-2 var-Lavel tog-Lavel-2 tog-Lavel  with frame {&frame-name}.
  End.
  Else do:
    display Classify SumsOnly type-stor ShowZero  with frame {&frame-name}.
    enable Classify SumsOnly type-stor ShowZero  with frame {&frame-name}.
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
   /* Tog-obj:hidden in frame {&frame-name} = true . */
    var-lavel:screen-value in frame {&frame-name} = '1'.
    var-lavel-2:screen-value in frame {&frame-name} = '1'.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-report s-object
PROCEDURE my-report :
/*------------------------------------------------------------------------------
  Purpose:     здесь происходит вызов  процедуры отчета с любыми параметрами
------------------------------------------------------------------------------*/
define variable par-val as character no-undo .

{ gbl/getsect.i run v-cntxt-obj-type v-cntxt-obj-code  {&attr-rezerv-obj} }
for each thbjattr_thbj-attr :
    if thbjattr_thbj-attr.prop-code = 'negparts'  then par-val  = thbjattr_thbj-attr.property-value-character.
end.

if CAPS(par-val) <> "DISABLE" Then do:
 BELL.
 Message
    "В системе разрешена работа с отрицательными партиями, "
    "поэтому отчет по товарам поставщика может выдать сумму "
    "остатка большую, чем состояние запаса по этому товару. " skip
    "Разница отнесена на текущую фирму, поскольку поставщиком "
    "в партиях отрицательных остатков считается текущая фирма. " skip
    "Отрицательные партии товара могут быть скомпенсированы "
    "в документе инвентаризации операцией пересортицы по партиям. "
    view-as alert-box information.
End.
 run rep/r-zpost.p
    (input v-cntxt-obj-code ,
    input v-cntxt-obj-type ,
    input base-type  ,
    input base-code  ,
    ?, ? , ? ,PostName, ? , RADPost, ?  ,? ,
    input Classify   ,
    input SortType   ,
    input SumsOnly   ,
    input ShowZero   ,
    input tog-obj    ,
    input ? ,
    input type-stor ,
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
PostName  RADPost type-stor
ShowZero Classify  SortType
SumsOnly Tog-obj
Tog-lavel  var-lavel Tog-lavel-2  Var-lavel-2 .

{ rep/claslabl.i }

ReportNAme = "Состояние запаса по поставщикам " + str1 .

ReportHeader = "Поставщики : " + PostName  + chr(10).

ReportHeader = ReportHeader + "Классификация : " + t-Class .

ReportHeader = ReportHeader +
               (if tog-lavel  then "    Итоги с уровня товаров "  + String(var-lavel)  else " "    ).
ReportHeader = ReportHeader +
               (if tog-lavel-2  then "    Итоги с уровня поставщиков "  + String(var-lavel-2)  else " "    ).


ReportHeader = ReportHeader  + chr(10) +
               "Сортировка " + t-Sort
               + chr(10) +
               "Показать : " +
               (if SumsOnly     then "Только итоги, "  else " "             ) +
               (if ShowZero     then "Показывать нулевые остатки "  else "Не показывать нулевые остатки" ) .

ReportHeader =  ReportHeader  + chr(10) + Entry(((type-stor * 2) - 1), type-stor:RADIO-BUTTONS) .

ReportHeader = ReportHeader  + chr(10) .

if X-SET_PAY_TYPE <> 2 then str3 =  "в ценах РЕАЛИЗАЦИИ".



 sheetf.Excel-Column-Lable =  "Код,Артикул,Артикул поставщика,Название товара,Ед.изм,Количество,Цена,Стоимость,НДС,НП,Стоимость без НДС,".
 sheetf.Sizes = "10,16,16,60,7,13,13,13,13,13,13,".
 Sheetf.ColFOrmat = "2=@;3=@;4=@"  .
  str1 = ' '  .
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
