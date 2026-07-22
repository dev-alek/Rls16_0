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

Оборотная ведомость по контрагентам (закладка № 2)

Автор: Чернова Светлана Александровна
Дата создания: 09/08/05
Author: Svetlana Chernova
Creation date: 09/08/05

Created: 14/03/01

*/

def var vss-revision    as character no-undo init "$Revision$":U .
def var vss-author      as character no-undo init "$Author$":U .
def var vss-date        as character no-undo init "$Date$":U .
def var vss-workfile    as character no-undo init "$Workfile$":U .
def var vss-archive     as character no-undo init "$Archive$":U .
def var vss-description as character no-undo init "Оборотная ведомость по контрагентам (закладка № 2)".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/r-page1.i  }
{ rep/rep-bt.i   }

CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

def var State-source as  WIDGET-HANDLE.
def buffer cli-post for clients .
def New SHARED temp-table g#post NO-UNDO
    field obj-type like ub.clients.obj-type
    field obj-code like ub.clients.obj-code
    field obj-name like ub.clients.obj-name
    INDEX pi IS UNIQUE PRIMARY obj-type obj-code.
def var  post-grp_recids as character no-undo .
def var ii as integer no-undo .

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
&Scoped-Define ENABLED-OBJECTS RECT-7 RECT-6 RECT-5 RECT-9 RECT-8 RADPost ~
PostName SortType Tog-obj Classify serv Show-discnt ShowZero
&Scoped-Define DISPLAYED-OBJECTS RADPost PostName SortType Tog-obj Classify ~
serv Show-discnt ShowZero SumsOnly

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */
DEFINE VARIABLE PostName AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 31 BY 2.17 TOOLTIP "Список выбранных Поставщиков" NO-UNDO.

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
"Группы контрагентов", "post":U,
"Группы товаров", "grp-goods":U,
"Группы контрагентов/Группы товаров", "post/grp-goods":U,
"Группы товаров/Группы контрагентов", "grp-goods/post":U
     size 37.38 by 4.63 NO-UNDO.

DEFINE VARIABLE RADPost AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "все", 1,
"Выборочно", 2
     SIZE 12 BY 2.17 NO-UNDO.

DEFINE VARIABLE serv AS CHARACTER INITIAL "all"
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Все", "all":U,
"Товары", "goods":U,
"Услуги  ", "office":U
     SIZE 12 BY 2.29 NO-UNDO.

DEFINE VARIABLE SortType AS CHARACTER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "по коду", "sort-code":U,
"по артикулу", "sort-article":U
     size 14 by 2.17
     BGCOLOR 8 FGCOLOR 0  NO-UNDO.

DEFINE RECTANGLE RECT-5
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 45.75 BY 6.96.

DEFINE RECTANGLE RECT-6
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 22.75 BY 4.42.

DEFINE RECTANGLE RECT-7
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 45.5 BY 3.42.

DEFINE RECTANGLE RECT-8
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 45.75 BY 5.92.

DEFINE RECTANGLE RECT-9
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 22.75 BY 12.08.

DEFINE VARIABLE Show-discnt AS LOGICAL INITIAL yes
     LABEL "Скидки":L
     VIEW-AS TOGGLE-BOX
     size 10.88 by 0.83 NO-UNDO.

DEFINE VARIABLE ShowZero AS LOGICAL INITIAL no
     LABEL "Нулевые остатки":L
     VIEW-AS TOGGLE-BOX
     size 19 by 0.83 NO-UNDO.

DEFINE VARIABLE SumsOnly AS LOGICAL INITIAL no
     LABEL "Только итоги":L
     VIEW-AS TOGGLE-BOX
     SIZE 19 BY .83 NO-UNDO.

DEFINE VARIABLE Tog-lavel AS LOGICAL INITIAL no
     LABEL "с уровня":L
     VIEW-AS TOGGLE-BOX
     size 12.63 by 0.79
     BGCOLOR 8 FGCOLOR 0  NO-UNDO.

DEFINE VARIABLE Tog-lavel-2 AS LOGICAL INITIAL no
     LABEL "с уровня":L
     VIEW-AS TOGGLE-BOX
     size 12.63 by 0.79
     BGCOLOR 8 FGCOLOR 0  NO-UNDO.

DEFINE VARIABLE Tog-obj AS LOGICAL INITIAL yes
     LABEL "Раздельно по объектам":L
     VIEW-AS TOGGLE-BOX
     size 31 by 1
     BGCOLOR 8 FGCOLOR 0  NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     RADPost AT ROW 2 COL 3.25 NO-LABEL
     PostName AT ROW 2 COL 15.38 NO-LABEL
     SortType at row 2.5 col 51.88 NO-LABEL
     Tog-obj at row 5.54 col 3.38
     Classify at row 6.79 col 3.25 NO-LABEL
     Tog-lavel-2 at row 7.75 col 28.25
     var-lavel-2 AT ROW 7.75 COL 39.13 COLON-ALIGNED NO-LABEL
     var-lavel AT ROW 8.58 COL 39.13 COLON-ALIGNED NO-LABEL
     Tog-lavel at row 8.63 col 28.25
     serv AT ROW 13.21 COL 3.25 NO-LABEL
     Show-discnt at row 13.21 col 26.5
     ShowZero at row 15.58 col 3.25
     SumsOnly AT ROW 16.46 COL 3.25
     "Выбор контрагента:" VIEW-AS TEXT
          SIZE 19.38 BY .67 AT ROW 1.25 COL 7.13
          FGCOLOR 4
     "Показать :" VIEW-AS TEXT
          size 11.5 by 0.75 at row 11.83 col 7.25
          FGCOLOR 4
     "Классификация :" VIEW-AS TEXT
          size 15 by 0.75 at row 4.83 col 7.13
          FGCOLOR 4
     "Сортировка :" VIEW-AS TEXT
          size 13.63 by 0.75 at row 1.42 col 51.88
          FGCOLOR 4
     RECT-7 AT ROW 1.04 COL 1.75
     RECT-6 AT ROW 1.04 COL 48.13
     RECT-5 AT ROW 4.63 COL 1.75
     RECT-9 AT ROW 5.5 COL 48.13
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
       PostName:READ-ONLY IN FRAME F-Main        = TRUE.

/* SETTINGS FOR TOGGLE-BOX SumsOnly IN FRAME F-Main
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
    if Classify  Begins "post":U OR
       Classify  Begins "grp-goods":U         then
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
    show-discnt:screen-value in frame {&frame-name} = 'yes'.
  { cmp/cr-objls.i v-cntxt-obj-type v-cntxt-obj-code }


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-report s-object
PROCEDURE my-report :
/*------------------------------------------------------------------------------
  Purpose:     здесь происходит вызов  процедуры отчета с любыми параметрами
------------------------------------------------------------------------------*/
 run rep/r-obcl.p
                 (input v-cntxt-obj-code ,
                  input v-cntxt-obj-type ,
                  input base-type  ,
                  input base-code  ,
                  serv, ? , ? ,PostName, ?, rADPost, Show-discnt  ,? ,
                  input Classify   ,
                  input SortType   ,
                  input SumsOnly   ,
                  input ShowZero   ,
                  input tog-obj    ,
                  ?   ,
                  ?   ,
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
PostName  RADPost
 ShowZero Classify  SortType  SumsOnly Tog-obj serv
Tog-lavel  var-lavel Tog-lavel-2  Var-lavel-2 Show-discnt .

ReportNAme = "Оборотная ведомость по контрагентам " .
{ rep/claslabl.i }
ReportHeader = "Контрагенты : " + PostName + chr(10).

ReportHeader = ReportHeader + "Классификация : " + t-Class.

ReportHeader = ReportHeader +
               (if tog-lavel  then "    Итоги с уровня товаров "  + String(var-lavel)  else " "    ).
ReportHeader = ReportHeader +
               (if tog-lavel-2  then "    Итоги с уровня контрагентов "  + String(var-lavel-2)  else " "    ).

ReportHeader = ReportHeader  + chr(10).

ReportHeader = ReportHeader +
               "Сортировка " + t-Sort + chr(10) +
               "Показать : " +
               (if SumsOnly     then "Только итоги, "  else " "             ) +
               (if Show-Cost     then "Суммы в учетных ценах, "  else " "    ) +
               (if Show-Crsa     then "Суммы в продажных ценах, "  else " "  ) +
               (if Show-Sale then "Суммы в ценах документа, "  else " " ) +
               (if Show-discnt then " + Скидки "  else " " ) +
               (if ShowZero     then "Показывать нулевые остатки "  else "Не показывать нулевые остатки" ) .

 sheetf.Excel-Column-Lable = "Код,Артикул,Название товара ,Ед.изм,т/у,Приход,,Расход,,Возврат,,Возврат поставщику,, " + chr(10).
 sheetf.Excel-Column-Lable = sheetf.Excel-Column-Lable + ",,,,,количество,сумма,количество,сумма,количество,сумма,количество,сумма,".
 sheetf.Sizes = "10,16,60,7,3,13,13,13,13,13,13,13,13,".

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