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

Представленность матрицы товаров на объекте (закладка № 2)

Автор: Демин Алексей Сергеевич
Дата создания: 02/06/06
Author: Alexey Demin
Creation date: 02/06/06

*/

def var vss-revision    as character no-undo init "$Revision$":U .
def var vss-author      as character no-undo init "$Author$":U .
def var vss-date        as character no-undo init "$Date$":U .
def var vss-workfile    as character no-undo init "$Workfile$":U .
def var vss-archive     as character no-undo init "$Archive$":U .
def var vss-description as character no-undo init "Представленность матрицы товаров на объекте (закладка № 2)".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i  }
{ cmp/r-page1.i  }

CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

def var State-source as  WIDGET-HANDLE.
/*def buffer cli-post for clients .*/
/*def New SHARED temp-table g#post NO-UNDO*/
/*    field obj-type like ub.clients.obj-type*/
/*    field obj-code like ub.clients.obj-code*/
/*    field obj-name like ub.clients.obj-name*/
/*    INDEX pi IS UNIQUE PRIMARY obj-type obj-code.*/
/*def var  post-grp_recids as character no-undo .*/
def var ii as integer no-undo .
define variable cli-list as character no-undo .

define buffer buf_clients for clients .

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
&Scoped-Define ENABLED-OBJECTS RECT-8 RECT-5 RECT-7 RECT-9 Rad-Inter ~
FILL-date1 FILL-date2 FILL-date FILL-time cli-code cli-type BUTTON-cli ~
cli-code-2 cli-type-2 BUTTON-cli-2 ShowGoods Classify Rad-Goods SortType
&Scoped-Define DISPLAYED-OBJECTS Rad-Inter FILL-date1 FILL-date2 FILL-date ~
FILL-time cli-code cli-type cli-code-2 cli-type-2 ShowGoods Classify ~
Rad-Goods SortType cli-name cli-name-2

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */
DEFINE BUTTON BUTTON-cli
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "2"
     SIZE 2.88 BY 1.

DEFINE BUTTON BUTTON-cli-2
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "2"
     SIZE 2.88 BY 1.

DEFINE VARIABLE cli-type AS CHARACTER FORMAT "X(256)":U
     VIEW-AS COMBO-BOX INNER-LINES 2
     DROP-DOWN-LIST
     SIZE 6 BY 1 NO-UNDO.

DEFINE VARIABLE cli-type-2 AS CHARACTER FORMAT "X(256)":U
     VIEW-AS COMBO-BOX INNER-LINES 2
     DROP-DOWN-LIST
     SIZE 6 BY 1 NO-UNDO.

DEFINE VARIABLE cli-code AS INTEGER FORMAT ">>>>>>>>>>>9" INITIAL 0
     LABEL "1"
     VIEW-AS FILL-IN
     SIZE 6 BY 1.

DEFINE VARIABLE cli-code-2 AS INTEGER FORMAT ">>>>>>>>>>>9" INITIAL 0
     LABEL "2"
     VIEW-AS FILL-IN
     SIZE 6 BY 1.

DEFINE VARIABLE cli-name AS CHARACTER FORMAT "X(40)"
      VIEW-AS TEXT
     SIZE 47.5 BY 1.

DEFINE VARIABLE cli-name-2 AS CHARACTER FORMAT "X(40)"
      VIEW-AS TEXT
     SIZE 47 BY 1.

DEFINE VARIABLE FILL-date AS DATE FORMAT "99/99/99":U
     VIEW-AS FILL-IN
     SIZE 9 BY 1 NO-UNDO.

DEFINE VARIABLE FILL-date1 AS DATE FORMAT "99/99/99":U
     LABEL "c"
     VIEW-AS FILL-IN
     SIZE 9 BY 1 NO-UNDO.

DEFINE VARIABLE FILL-date2 AS DATE FORMAT "99/99/99":U
     LABEL "по"
     VIEW-AS FILL-IN
     SIZE 9 BY 1 NO-UNDO.

DEFINE VARIABLE FILL-time AS INTEGER FORMAT ">9":U INITIAL 0
     LABEL "время (часы)"
     VIEW-AS FILL-IN
     SIZE 3 BY 1 NO-UNDO.

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
/*,*/
/*"Временные интервалы", "time":U,*/
/*"Временные интервалы/Группы товаров", "time/grp-goods":U*/
     SIZE 38.5 BY 5
     FGCOLOR 0  NO-UNDO.

DEFINE VARIABLE Rad-Goods AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "все", 1,
"только 0", 2
     SIZE 13 BY 2.29
     FGCOLOR 0  NO-UNDO.

DEFINE VARIABLE Rad-Inter AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "за период", 1,
"на дату", 2
     SIZE 12 BY 2.17 NO-UNDO.

DEFINE VARIABLE SortType AS CHARACTER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "по артикулу", "sort-article":U,
"по наимен.", "sort-name":U
     SIZE 14 BY 2.25
     FGCOLOR 0  NO-UNDO.

DEFINE RECTANGLE RECT-5
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 45.75 BY 8.

DEFINE RECTANGLE RECT-7
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 42.25 BY 3.42.

DEFINE RECTANGLE RECT-8
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 23 BY 8.

DEFINE RECTANGLE RECT-9
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 69.5 BY 3.42.

DEFINE VARIABLE ShowGoods AS LOGICAL INITIAL no
     LABEL "Показать товары":L
     VIEW-AS TOGGLE-BOX
     SIZE 19 BY .83
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE Tog-lavel AS LOGICAL INITIAL no
     LABEL "с уровня":L
     VIEW-AS TOGGLE-BOX
     SIZE 12.63 BY .79
     FGCOLOR 0  NO-UNDO.

DEFINE VARIABLE Tog-lavel-2 AS LOGICAL INITIAL no
     LABEL "с уровня":L
     VIEW-AS TOGGLE-BOX
     SIZE 12.63 BY .79
     FGCOLOR 0  NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     Rad-Inter AT ROW 2 COL 3 NO-LABEL
     FILL-date1 AT ROW 2 COL 17.25 COLON-ALIGNED
     FILL-date2 AT ROW 2 COL 31.63 COLON-ALIGNED
     FILL-date AT ROW 3.08 COL 13.75 COLON-ALIGNED NO-LABEL
     FILL-time AT ROW 3.13 COL 37.63 COLON-ALIGNED
     cli-code AT ROW 5.5 COL 4 COLON-ALIGNED
     cli-type AT ROW 5.5 COL 10.5 COLON-ALIGNED NO-LABEL
     BUTTON-cli AT ROW 5.5 COL 18.5
     cli-code-2 AT ROW 6.75 COL 4 COLON-ALIGNED
     cli-type-2 AT ROW 6.75 COL 10.5 COLON-ALIGNED NO-LABEL
     BUTTON-cli-2 AT ROW 6.75 COL 18.5
     ShowGoods AT ROW 8.75 COL 49.5
     Classify AT ROW 9.5 COL 2.75 NO-LABEL
     Rad-Goods AT ROW 9.71 COL 51 NO-LABEL
     Tog-lavel-2 AT ROW 10.46 COL 28.25
     var-lavel-2 AT ROW 10.46 COL 39.13 COLON-ALIGNED NO-LABEL
     var-lavel AT ROW 11.29 COL 39.13 COLON-ALIGNED NO-LABEL
     Tog-lavel AT ROW 11.33 COL 28.25
     SortType AT ROW 13.75 COL 50.5 NO-LABEL
     cli-name AT ROW 5.5 COL 21 NO-LABEL
     cli-name-2 AT ROW 6.75 COL 21.5 NO-LABEL
     "Классификация :" VIEW-AS TEXT
          SIZE 15 BY .75 AT ROW 8.63 COL 7.13
          FGCOLOR 4
     "Сортировка :" VIEW-AS TEXT
          SIZE 13.63 BY .75 AT ROW 12.79 COL 50.13
          FGCOLOR 4
     "Выбор отчета:" VIEW-AS TEXT
          SIZE 19.38 BY .67 AT ROW 1.25 COL 3
          FGCOLOR 4
     "Объекты для анализа:" VIEW-AS TEXT
          SIZE 22.25 BY .67 AT ROW 4.88 COL 2.75
          FGCOLOR 4
     RECT-8 AT ROW 8.5 COL 48
     RECT-5 AT ROW 8.46 COL 1.75
     RECT-7 AT ROW 1.04 COL 1.75
     RECT-9 AT ROW 4.75 COL 1.5
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
         HEIGHT             = 15.96
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

/* SETTINGS FOR FILL-IN cli-name IN FRAME F-Main
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN cli-name-2 IN FRAME F-Main
   NO-ENABLE ALIGN-L                                                    */
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

&Scoped-define SELF-NAME BUTTON-cli
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BUTTON-cli s-object
ON CHOOSE OF BUTTON-cli IN FRAME F-Main /* 2 */
DO:
  run ref/cli-all.w ( my-handle, "b-sel", {&g___object}, {&all}, {&current}, ?, ",,,,,,NO,,":u, "without-obj":U, output cli-list ) .
  if cli-list <> "" then do:
    find first buf_clients no-lock where RECID(buf_clients) = int (cli-list) no-error.
/*    if clients.obj-type <> {&s} and clients.obj-type <> {&cmp} then do:*/
/*      message*/
/*        "Контрагент может быть только " {&cmp} " или " {&prs}*/
/*        view-as alert-box ERROR .*/
/*      return no-apply.*/
/*    end.*/
    assign cli-type = buf_clients.obj-type  cli-code = buf_clients.obj-code  cli-name = buf_clients.obj-name .
  end.
  else assign cli-name = ""   cli-code = ?  .
  display cli-name    cli-code   with frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME BUTTON-cli-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BUTTON-cli-2 s-object
ON CHOOSE OF BUTTON-cli-2 IN FRAME F-Main /* 2 */
DO:
  run ref/cli-all.w ( my-handle, "b-sel", {&g___object}, {&all}, {&current}, ?, ",,,,,,NO,,":u, "without-obj":U, output cli-list ) .
  if cli-list <> "" then do:
    find first buf_clients no-lock where RECID(buf_clients) = int (cli-list) no-error.
    assign cli-type-2 = buf_clients.obj-type  cli-code-2 = buf_clients.obj-code  cli-name-2 = buf_clients.obj-name .
  end.
  else assign cli-name-2 = ""   cli-code-2 = ?  .
  display cli-name-2    cli-code-2   with frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Classify
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Classify s-object
ON VALUE-CHANGED OF Classify IN FRAME F-Main
DO:
  Assign Classify.
  if Classify = "grp-goods":U  Then do:
    display TOG-lavel   with frame {&FRAME-NAME} .
    enable  TOG-lavel   with frame {&FRAME-NAME} .
  end.
  Else do:
    assign TOG-lavel = no .
    display  TOG-lavel  var-Lavel with frame {&FRAME-NAME} .
    disable  TOG-lavel  var-Lavel with frame {&FRAME-NAME} .
  end.
  if Classify = "post":U Then do:
    display TOG-lavel-2   with frame {&FRAME-NAME} .
    enable  TOG-lavel-2   with frame {&FRAME-NAME} .
  end.
  Else do:
    assign TOG-lavel-2 = no .
    display  TOG-lavel-2  var-Lavel-2 with frame {&FRAME-NAME} .
    disable  TOG-lavel-2  var-Lavel-2 with frame {&FRAME-NAME} .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME cli-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL cli-code s-object
ON LEAVE OF cli-code IN FRAME F-Main /* 1 */
DO:
  if cli-code = int ( cli-code:screen-value ) then return.
  assign cli-code.
  find first buf_clients no-lock where buf_clients.obj-type = cli-type and buf_clients.obj-code = cli-code no-error.
  if not available buf_clients then apply "CHOOSE" to BUTTON-cli IN FRAME F-Main .
  else do:
    assign cli-name = buf_clients.obj-name   cli-code = buf_clients.obj-code .
    display cli-name  cli-code  with frame {&frame-name}.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL cli-code s-object
ON RETURN OF cli-code IN FRAME F-Main /* 1 */
DO:
  if cli-code = int ( cli-code:screen-value ) then return.
  assign cli-code.
  find first buf_clients no-lock where buf_clients.obj-type = cli-type and buf_clients.obj-code = cli-code no-error.
  if not available buf_clients then apply "CHOOSE" to BUTTON-cli IN FRAME F-Main .
  else do:
    assign cli-name = buf_clients.obj-name   cli-code = buf_clients.obj-code .
    display cli-name  cli-code  with frame {&frame-name}.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME cli-code-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL cli-code-2 s-object
ON LEAVE OF cli-code-2 IN FRAME F-Main /* 2 */
DO:
  if cli-code-2 = int ( cli-code-2:screen-value ) then return.
  assign cli-code-2.
  find first buf_clients no-lock where buf_clients.obj-type = cli-type-2 and buf_clients.obj-code = cli-code-2 no-error.
  if not available buf_clients then apply "CHOOSE" to BUTTON-cli-2 IN FRAME F-Main .
  else do:
    assign cli-name-2 = buf_clients.obj-name   cli-code-2 = buf_clients.obj-code .
    display cli-name-2  cli-code-2  with frame {&frame-name}.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL cli-code-2 s-object
ON RETURN OF cli-code-2 IN FRAME F-Main /* 2 */
DO:
  if cli-code-2 = int ( cli-code-2:screen-value ) then return.
  assign cli-code-2.
  find first buf_clients no-lock where buf_clients.obj-type = cli-type-2 and buf_clients.obj-code = cli-code-2 no-error.
  if not available buf_clients then apply "CHOOSE" to BUTTON-cli-2 IN FRAME F-Main .
  else do:
    assign cli-name-2 = buf_clients.obj-name   cli-code-2 = buf_clients.obj-code .
    display cli-name-2  cli-code-2  with frame {&frame-name}.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME cli-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL cli-type s-object
ON VALUE-CHANGED OF cli-type IN FRAME F-Main
DO:
  assign cli-type .
  if cli-code <> 0 and cli-code <> ? then do:
    find first buf_clients no-lock where buf_clients.obj-type = cli-type and buf_clients.obj-code = cli-code no-error.
    if not available buf_clients then assign cli-name = ""                     cli-code = ? .
    else                              assign cli-name = buf_clients.obj-name   cli-code = buf_clients.obj-code .
  end.
  display cli-name  cli-code  with frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME cli-type-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL cli-type-2 s-object
ON VALUE-CHANGED OF cli-type-2 IN FRAME F-Main
DO:
  assign cli-type-2 .
  if cli-code-2 <> 0 and cli-code-2 <> ? then do:
    find first buf_clients no-lock where buf_clients.obj-type = cli-type-2 and buf_clients.obj-code = cli-code-2 no-error.
    if not available buf_clients then assign cli-name-2 = ""                     cli-code-2 = ? .
    else                              assign cli-name-2 = buf_clients.obj-name   cli-code-2 = buf_clients.obj-code .
  end.
  display cli-name-2  cli-code-2  with frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Rad-Inter
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Rad-Inter s-object
ON VALUE-CHANGED OF Rad-Inter IN FRAME F-Main
DO:
   Assign Rad-Inter.
   if Rad-Inter = 1 Then do:
     enable   FILL-date1  FILL-date2   with frame {&FRAME-NAME} .
     disable  FILL-date   FILL-time    with frame {&FRAME-NAME} .
   end.
   Else do:
     disable  FILL-date1  FILL-date2   with frame {&FRAME-NAME} .
     enable   FILL-date   FILL-time    with frame {&FRAME-NAME} .
   end.
   display  FILL-date  FILL-date1  FILL-date2  FILL-time  with frame {&FRAME-NAME} .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME



&Scoped-define SELF-NAME ShowGoods
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ShowGoods s-object
ON VALUE-CHANGED OF ShowGoods IN FRAME F-Main /* Показать товары */
DO:
  assign ShowGoods .
  if ShowGoods = yes then do:
    enable   Rad-Goods SortType with frame {&FRAME-NAME} .
/*    display  var-Lavel  with frame {&FRAME-NAME} .*/
  end.
  else do:
    disable   Rad-Goods SortType with frame {&FRAME-NAME} .
/*    display  var-Lavel  with frame {&FRAME-NAME} .*/
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Tog-lavel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Tog-lavel s-object
ON VALUE-CHANGED OF Tog-lavel IN FRAME F-Main /* с уровня */
DO:
  Assign tog-lavel.
  if tog-lavel =TRUE Then do:
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
   if tog-lavel-2 = TRUE Then do:
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
/*   ShowParts:screen-value in frame {&frame-name} = 'yes':U.*/

   /* Tog-obj:hidden in frame {&frame-name} = true . */
    var-lavel:screen-value in frame {&frame-name} = '1'.
    var-lavel-2:screen-value in frame {&frame-name} = '1'.

    cli-type:list-items     = {&stock} + "," + {&shop} .
    cli-type:screen-value   = {&shop} .
    cli-type-2:list-items   = {&stock} + "," + {&shop} .
    cli-type-2:screen-value = {&stock} .
    assign cli-type cli-type-2 .

    apply "VALUE-CHANGED" to ShowGoods IN FRAME F-Main .
    apply "VALUE-CHANGED" to Rad-Inter IN FRAME F-Main .

/*    disable ShowZero with frame {&frame-name}.*/

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-report s-object
PROCEDURE my-report :
/*------------------------------------------------------------------------------
  Purpose:     здесь происходит вызов  процедуры отчета с любыми параметрами
------------------------------------------------------------------------------*/

  if Rad-Inter = 1 then do:
    if FILL-date1 = ? THEN DO:
      message "Не задана дата начала интервала!" view-as alert-box ERROR.
      return.
    end.
    if FILL-date2 = ? THEN DO:
      message "Не задана дата окончания интервала!" view-as alert-box ERROR.
      return.
    end.
    if FILL-date1 > FILL-date2 THEN DO:
      message "Дата начала интервала больше даты окончания!" view-as alert-box ERROR.
      return.
    end.
  end.
  else do:
    if FILL-date = ? THEN DO:
      message "Не задана дата отчета!" view-as alert-box ERROR.
      return.
    end.
    if FILL-time > 23 then do:
      message "Время отчета должно быть от 0 до 23 часов!" view-as alert-box ERROR.
      return.
    end.
    assign
      FILL-date1 = FILL-date
      FILL-date2 = FILL-date
    .
  end.

  if cli-code = ? or cli-code = 0 then do:
    message "Не задан 1 объект для отчета!" view-as alert-box ERROR.
    return.
  end.
  if cli-code-2 = ? or cli-code-2 = 0 then do:
    message "Не задан 2 объект для отчета!" view-as alert-box ERROR.
    return.
  end.

   run rep/r-mattov.p  (
                  input Rad-Inter   ,
                  input FILL-date1  ,
                  input FILL-date2  ,
                  input FILL-time   ,
                  input cli-code    ,
                  input cli-type    ,
                  input cli-code-2  ,
                  input cli-type-2  ,
                  input ShowGoods   ,
                  input Rad-Goods   ,
                  input Classify    ,
                  input SortType    ,
                  input tog-lavel   ,
                  input var-lavel   ,
                  input tog-lavel-2 ,
                  input var-lavel-2) .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-var s-object
PROCEDURE my-var :
/*------------------------------------------------------------------------------
  Purpose:     здесь происходит вызов  значений переменных
  например  Название отчета, может быть еще пример шапки???
------------------------------------------------------------------------------*/
assign frame {&frame-name}  Classify SortType  Tog-lavel  var-lavel Tog-lavel-2  Var-lavel-2
                            Rad-Inter FILL-date1 FILL-date2 FILL-date FILL-time cli-code cli-type
                            cli-code-2 cli-type-2 ShowGoods Rad-Goods  .

{ rep/claslabl.i }
if Classify = "time":U THEN t-class =   "Временные интервалы" .
if Classify = "time/grp-goods":U THEN t-class =   "Временные интервалы/Группы товаров" .

ReportNAme = "Представленность матрицы товаров на объекте" .
if Rad-Inter = 1 then ReportNAme = ReportNAme + " c " + string(FILL-date1,"99/99/99") + " по " + string(FILL-date2,"99/99/99") .
else                  ReportNAme = ReportNAme + " на " + string(FILL-time,"99") + " ч. " + string(FILL-date,"99/99/99") .

/*ReportHeader = "Поставщики : " + PostName  + chr(10).*/
ReportHeader = "Классификация : " + t-Class .
ReportHeader = ReportHeader + (if tog-lavel  then "    Итоги с уровня товаров "  + String(var-lavel)  else " "    ).
ReportHeader = ReportHeader + (if tog-lavel-2  then "    Итоги с уровня поставщиков "  + String(var-lavel-2)  else " "    ).
/*ReportHeader = ReportHeader  + chr(10) + "Сортировка " + t-Sort*/
/*               + chr(10) +  "Показать : " + (if SumsOnly     then "Только итоги, "  else " "             ) +*/
/*               (if ShowZero     then "Показывать нулевые остатки "  else "Не показывать нулевые остатки" )*/
 assign
   str1 = cli-name
   str2 = cli-name-2
 .

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