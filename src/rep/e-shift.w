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

Сменный отчет (закладка № 2)

Автор: Уханов Дмитрий Юрьевич
Дата создания: 08/06/07
Author: Dmitry Ukhanov
Creation date: 08/06/07

Автор1: Бахтадзе Наталья Викторовна
Дата создания1: 10/11/00

*/

CREATE WIDGET-POOL.

DEFINE VARIABLE vss-revision    AS CHARACTER NO-UNDO INITIAL "$Revision$":U .
DEFINE VARIABLE vss-author      AS CHARACTER NO-UNDO INITIAL "$Author$":U .
DEFINE VARIABLE vss-date        AS CHARACTER NO-UNDO INITIAL "$Date$":U .
DEFINE VARIABLE vss-workfile    AS CHARACTER NO-UNDO INITIAL "$Workfile$":U .
DEFINE VARIABLE vss-archive     AS CHARACTER NO-UNDO INITIAL "$Archive$":U .
DEFINE VARIABLE vss-description AS CHARACTER NO-UNDO INITIAL "Сменный отчет (закладка № 2)".

{ cmp/vssrevis.i }
{ cmp/str-glbl.i  }
{ cmp/library.i }
{ cmp/showinf.i }
{ cmp/r-page1.i  }
{ gbl/usr-flt.i }
{ cmp/r-pril.i }
{ gbl/getcntxt.i def " " my-handle }
{ gbl/key-rec.i   }
{ rul/tempcxml.i }
{ trg/factord.i }
{ gbl/cur-time.i }


/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

DEFINE VARIABLE State-source AS WIDGET-HANDLE.
DEFINE VARIABLE is-wth       AS LOGICAL   NO-UNDO.
DEFINE VARIABLE is-elved     AS LOGICAL   NO-UNDO.
DEFINE VARIABLE dops         AS CHARACTER NO-UNDO .
DEFINE VARIABLE dopst        AS CHARACTER NO-UNDO .
define variable v-profile-id as integer   no-undo .
DEFINE VARIABLE v-esys-id    AS integer   NO-UNDO.
define variable v-shift-days-to-report as integer no-undo .
define variable v-tog        as logical   extent 10.
define variable v-weight     as logical   no-undo .
define variable v-classify   as character no-undo .
define variable v-sorttype   as character no-undo .
define variable v-level      as integer   no-undo .
define variable v-pump-one   as logical   no-undo .
define variable v-whole-gds  as logical   no-undo .
define variable v-el-icnt    as logical   no-undo .
define variable v-cp-grp     as logical   no-undo .
define variable v-output-type  as character no-undo .
define variable v-line-of-page as integer no-undo .

define temp-table last-shift no-undo
field obj-type   as character
field obj-code   as integer
field fact-order as decimal
index pi is unique primary
obj-type
obj-code
.

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
&Scoped-Define ENABLED-OBJECTS RECT-9 tog-weight f-line-of-page ~
tog-1-out-pump-with-icnt TOG-1 tog-1-pump-one tog-1-whole-gds TOG-2 ~
tog-2-cp-grp TOG-3 Classify SortType TOG-4 TOG-5 f-shift-days-to-report ~
TOG-6 b-esys TOG-7 TOG-8 TOG-81 TOG-82 tog-9 tog-10 B-staff t-excel t-TEXT 
&Scoped-Define DISPLAYED-OBJECTS tog-weight f-line-of-page ~
tog-1-out-pump-with-icnt TOG-1 tog-1-pump-one tog-1-whole-gds TOG-2 ~
tog-2-cp-grp TOG-3 Classify SortType TOG-4 TOG-5 f-shift-days-to-report ~
TOG-6 TOG-7 TOG-8 TOG-81 TOG-82 tog-9 tog-10 t-excel t-TEXT f-esys-id f-esys-name 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-esys 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 1" 
     SIZE 4 BY 1.

DEFINE BUTTON B-staff 
     LABEL "Персонал  смены " 
     SIZE 45 BY 1
     BGCOLOR 8 FGCOLOR 0 .

DEFINE VARIABLE f-esys-id AS INTEGER FORMAT ">>>>>>9":U INITIAL 0 
     LABEL "Код Внеш.системы, в которую идет выгрузка" 
      VIEW-AS TEXT 
     SIZE 10 BY .67 NO-UNDO.

DEFINE VARIABLE f-esys-name AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 68.5 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE f-line-of-page AS INTEGER FORMAT ">>9":U INITIAL 0 
     LABEL "Строк на cтранице" 
     VIEW-AS FILL-IN 
     SIZE 4 BY .78 NO-UNDO.

DEFINE VARIABLE f-shift-days-to-report AS INTEGER FORMAT ">>9":U INITIAL 0 
     LABEL "Кол-во дней для расчета ни разу нерассчитанных  объектов" 
     VIEW-AS FILL-IN 
     SIZE 6 BY 1.07 NO-UNDO.

DEFINE VARIABLE var-level AS INTEGER FORMAT ">>9":U INITIAL 1 
     VIEW-AS FILL-IN NATIVE 
     SIZE 5 BY .78
     BGCOLOR 8 FGCOLOR 0  NO-UNDO.

DEFINE VARIABLE Classify AS CHARACTER 
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS 
          "Группы 1-го уровня", "no-classify":U,
"Группы с n-уровнeм вложенности", "n-level":U,
"Терминальные группы", "t-level":U,
"Только итоги", "totals":U
     SIZE 33 BY 3.44
     BGCOLOR 8 FGCOLOR 0  NO-UNDO.

DEFINE VARIABLE SortType AS CHARACTER 
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS 
          "по коду", "sort-code":U,
"по артикулу", "sort-article":U
     SIZE 14 BY 2
     BGCOLOR 8 FGCOLOR 0  NO-UNDO.

DEFINE RECTANGLE RECT-9
     EDGE-PIXELS 3 GRAPHIC-EDGE  NO-FILL   
     SIZE 91 BY 16.26.

DEFINE VARIABLE t-excel AS LOGICAL INITIAL no 
     LABEL "Excel" 
     VIEW-AS TOGGLE-BOX
     SIZE 13 BY 1 NO-UNDO.

DEFINE VARIABLE t-TEXT AS LOGICAL INITIAL no 
     LABEL "TEXT" 
     VIEW-AS TOGGLE-BOX
     SIZE 13 BY 1 NO-UNDO.

DEFINE VARIABLE TOG-1 AS LOGICAL INITIAL no 
     LABEL "Часть 1 - Движение Нефтепродуктов по количеству" 
     VIEW-AS TOGGLE-BOX
     SIZE 57.38 BY .78 TOOLTIP "Лист отчета ~"Движение Нефтепродуктов по количеству~""
     BGCOLOR 8 FGCOLOR 0  NO-UNDO.

DEFINE VARIABLE tog-1-out-pump-with-icnt AS LOGICAL INITIAL no 
     LABEL "Колонка ~"расход~"/~"оборот~" по показаниям электронного счетчика (части 1/9)" 
     VIEW-AS TOGGLE-BOX
     SIZE 77.5 BY .78 TOOLTIP "Колонка ~"расход~" по показаниям электронного счетчика" NO-UNDO.

DEFINE VARIABLE tog-1-pump-one AS LOGICAL INITIAL no 
     LABEL "Счетчики ТРК в одной строке" 
     VIEW-AS TOGGLE-BOX
     SIZE 30.5 BY .78 TOOLTIP "Один ТРК несколько резервуаров, показания в одной строке" NO-UNDO.

DEFINE VARIABLE tog-1-whole-gds AS LOGICAL INITIAL no 
     LABEL "Товар на одной странице" 
     VIEW-AS TOGGLE-BOX
     SIZE 27 BY .78 TOOLTIP "Все строки по товару выводятся без разбиения на одной странице" NO-UNDO.

DEFINE VARIABLE tog-10 AS LOGICAL INITIAL no 
     LABEL "Часть 10 - Топливо по типам платежей" 
     VIEW-AS TOGGLE-BOX
     SIZE 61.5 BY .78 NO-UNDO.

DEFINE VARIABLE TOG-2 AS LOGICAL INITIAL no 
     LABEL "Часть 2 - Движение Нефтепродуктов по количеству и суммам" 
     VIEW-AS TOGGLE-BOX
     SIZE 60.75 BY .78 TOOLTIP "Лист отчета ~"Движение Нефтепродуктов по количеству и суммам~""
     BGCOLOR 8 FGCOLOR 0  NO-UNDO.

DEFINE VARIABLE tog-2-cp-grp AS LOGICAL INITIAL no 
     LABEL "Итоги по группам платежей" 
     VIEW-AS TOGGLE-BOX
     SIZE 29 BY .78 NO-UNDO.

DEFINE VARIABLE TOG-3 AS LOGICAL INITIAL no 
     LABEL "Часть 3 - Движение ТНП по количеству и суммам" 
     VIEW-AS TOGGLE-BOX
     SIZE 60.75 BY .78 TOOLTIP "Лист отчета ~"Движение ТНП по количеству и суммам~""
     BGCOLOR 8 FGCOLOR 0  NO-UNDO.

DEFINE VARIABLE TOG-4 AS LOGICAL INITIAL no 
     LABEL "Часть 4 - Реализация услуг" 
     VIEW-AS TOGGLE-BOX
     SIZE 60.75 BY .78 TOOLTIP "Лист отчета ~"Реализация услуг по кол-ву и сумме~""
     BGCOLOR 8 FGCOLOR 0  NO-UNDO.

DEFINE VARIABLE TOG-5 AS LOGICAL INITIAL no 
     LABEL "Часть 5 - Движение материальных ценностей" 
     VIEW-AS TOGGLE-BOX
     SIZE 60.75 BY .78 TOOLTIP "Лист отчета ~"Движение материальных ценностей~""
     BGCOLOR 8 FGCOLOR 0  NO-UNDO.

DEFINE VARIABLE TOG-5-1 AS LOGICAL INITIAL no 
     LABEL "Часть 5 - Движение денежных средств" 
     VIEW-AS TOGGLE-BOX
     SIZE 60.75 BY .78 TOOLTIP "Лист отчета ~"Движение денежных средств~""
     BGCOLOR 8 FGCOLOR 0  NO-UNDO.

DEFINE VARIABLE TOG-6 AS LOGICAL INITIAL no 
     LABEL "Часть 6 - Простои АЗК" 
     VIEW-AS TOGGLE-BOX
     SIZE 60.75 BY .78 TOOLTIP "Лист отчета ~"Простои АЗК~""
     BGCOLOR 8 FGCOLOR 0  NO-UNDO.

DEFINE VARIABLE TOG-7 AS LOGICAL INITIAL no 
     LABEL "Часть 7 - Погрешности объемомеров ТРК" 
     VIEW-AS TOGGLE-BOX
     SIZE 60.75 BY .78 TOOLTIP "Лист отчета ~"Погрешности объемомеров ТРК~""
     BGCOLOR 8 FGCOLOR 0  NO-UNDO.

DEFINE VARIABLE TOG-8 AS LOGICAL INITIAL no 
     LABEL "Часть 8 - Статистика реализации по ведомостям" 
     VIEW-AS TOGGLE-BOX
     SIZE 60.75 BY .78 TOOLTIP "Лист отчета ~"Статистика реализации по ведомостям~""
     BGCOLOR 8 FGCOLOR 0  NO-UNDO.

DEFINE VARIABLE TOG-81 AS LOGICAL INITIAL no 
     LABEL "Часть 8 - Возвраты по сопутствующим товарам и топливу" 
     VIEW-AS TOGGLE-BOX
     SIZE 60.75 BY .78 TOOLTIP "Лист отчета ~"Статистика реализации по ведомостям~""
     BGCOLOR 8 FGCOLOR 0  NO-UNDO.

DEFINE VARIABLE TOG-82 AS LOGICAL INITIAL no 
     LABEL "Отображать частичные возвраты" 
     VIEW-AS TOGGLE-BOX
     SIZE 60.75 BY .78 TOOLTIP "Лист отчета ~"Статистика реализации по ведомостям~""
     BGCOLOR 8 FGCOLOR 0  NO-UNDO.

DEFINE VARIABLE tog-9 AS LOGICAL INITIAL no 
     LABEL "Часть 9 - Сбросы, переливы и переводы транзакций" 
     VIEW-AS TOGGLE-BOX
     SIZE 61.5 BY .78 NO-UNDO.

DEFINE VARIABLE Tog-level AS LOGICAL INITIAL no 
     LABEL "с уровня":L 
     VIEW-AS TOGGLE-BOX
     SIZE 12.63 BY .78
     BGCOLOR 8 FGCOLOR 0  NO-UNDO.

DEFINE VARIABLE tog-weight AS LOGICAL INITIAL no 
     LABEL "Весовой учет топлива" 
     VIEW-AS TOGGLE-BOX
     SIZE 24 BY .82 TOOLTIP "Весовой учет топлива"
     BGCOLOR 8 FGCOLOR 0  NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     tog-weight AT ROW 1.26 COL 2.5
     f-line-of-page AT ROW 1.26 COL 86 COLON-ALIGNED
     tog-1-out-pump-with-icnt AT ROW 2.52 COL 14 WIDGET-ID 4
     TOG-1 AT ROW 3.52 COL 14
     tog-1-pump-one AT ROW 4.26 COL 20
     tog-1-whole-gds AT ROW 4.26 COL 52
     TOG-2 AT ROW 5 COL 14
     tog-2-cp-grp AT ROW 5.8 COL 20
     TOG-3 AT ROW 6.6 COL 14
     Classify AT ROW 7.2 COL 20 NO-LABEL
     SortType AT ROW 7.8 COL 24 NO-LABEL
     Tog-level AT ROW 9 COL 73.5
     var-level AT ROW 9 COL 84 COLON-ALIGNED NO-LABEL
     TOG-4 AT ROW 10.5 COL 14
     TOG-5 AT ROW 11.3 COL 14
     TOG-5-1 AT ROW 11.3 COL 14 WIDGET-ID 22
     f-shift-days-to-report AT ROW 13.19 COL 68 COLON-ALIGNED WIDGET-ID 6
     TOG-6 AT ROW 12.1 COL 14
     b-esys AT ROW 13.41 COL 63 WIDGET-ID 16
     TOG-7 AT ROW 12.9 COL 14
     TOG-8 AT ROW 13.6 COL 14
     TOG-81 AT ROW 13.7 COL 14
     TOG-82 AT ROW 14.5 COL 20
     tog-9 AT ROW 15.3 COL 14 WIDGET-ID 2
     tog-10 AT ROW 16.1 COL 14
     B-staff AT ROW 17.4 COL 2
     t-excel AT ROW 17.4 COL 50.5 WIDGET-ID 20
     t-TEXT AT ROW 18.59 COL 71 WIDGET-ID 8
     f-esys-id AT ROW 14.41 COL 48 COLON-ALIGNED WIDGET-ID 14
     f-esys-name AT ROW 16.52 COL 2 COLON-ALIGNED NO-LABEL WIDGET-ID 18
     "Показать :" VIEW-AS TEXT
          SIZE 11.5 BY .78 AT ROW 2.52 COL 2.5
          FGCOLOR 4 
     RECT-9 AT ROW 2.26 COL 1.5
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
         HEIGHT             = 18.67
         WIDTH              = 92.13.
/* END WINDOW DEFINITION */
                                                                        */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _INCLUDED-LIB s-object 
/* ************************* Included-Libraries *********************** */

{ src/adm/method/viewer.i }

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW s-object
  VISIBLE,,RUN-PERSISTENT                                               */
/* SETTINGS FOR FRAME F-Main
   NOT-VISIBLE FRAME-NAME Size-to-Fit                                   */
ASSIGN 
       FRAME F-Main:HEIGHT           = 18.67
       FRAME F-Main:WIDTH            = 92.13.

/* SETTINGS FOR FILL-IN f-esys-id IN FRAME F-Main
   NO-ENABLE                                                            */
ASSIGN 
       f-esys-id:READ-ONLY IN FRAME F-Main        = TRUE.

/* SETTINGS FOR FILL-IN f-esys-name IN FRAME F-Main
   NO-ENABLE                                                            */
ASSIGN 
       SortType:HIDDEN IN FRAME F-Main           = TRUE.

/* SETTINGS FOR TOGGLE-BOX TOG-5-1 IN FRAME F-Main
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN 
       TOG-5-1:HIDDEN IN FRAME F-Main           = TRUE.

/* SETTINGS FOR TOGGLE-BOX Tog-level IN FRAME F-Main
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN 
       Tog-level:HIDDEN IN FRAME F-Main           = TRUE.

/* SETTINGS FOR FILL-IN var-level IN FRAME F-Main
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN 
       var-level:HIDDEN IN FRAME F-Main           = TRUE.

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

&Scoped-define SELF-NAME b-esys
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-esys s-object
ON CHOOSE OF b-esys IN FRAME F-Main /* Btn 1 */
DO:
RUN get-ext-system IN THIS-PROCEDURE  ( INPUT YES).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-staff
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-staff s-object
ON CHOOSE OF B-staff IN FRAME F-Main /* Персонал  смены  */
DO:
    RUN my-var IN THIS-PROCEDURE.
    if X-date-start <> X-date-end or X-Shift-start <> X-Shift-end then
      message "При выборе нескольких смен показывается только персонал последней"  view-as alert-box INFORMATION .
    run ref/shftpers.w ( input my-handle,
                     INPUT v-cntxt-obj-type,
                     INPUT v-cntxt-obj-code,
                     INPUT X-date-end,
                     INPUT X-Shift-end,
                     INPUT "b-add-next":U,
                     INPUT "":U            ) NO-ERROR.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Classify
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Classify s-object
ON VALUE-CHANGED OF Classify IN FRAME F-Main
DO:

  ASSIGN Classify.
  if place-call = "'new-rep'" then do:
      DISABLE
         tog-6
      with frame {&frame-name} .

      HIDE 
            tog-8
            in frame {&frame-name}.
       ENABLE
            tog-81
            tog-82
         with frame {&frame-name} .

     if is-wth = true then do:
         ENABLE
            tog-5
         with frame {&frame-name} .
         HIDE 
            tog-5-1
         in frame {&frame-name}.
     end.

     else do:
         ENABLE
            tog-5-1
         with frame {&frame-name} .    
         HIDE 
            tog-5
         in frame {&frame-name}.
     end.
  end.
     
  if classify = "n-level":u
    and tog-3 = true
  then do:
    enable  tog-level  var-level with frame {&frame-name} .
    display tog-level  var-level with frame {&frame-name} .
  end.
  else do:
/*    disable tog-level  var-level with frame {&frame-name} .
*/
    hide    tog-level  var-level   in frame {&frame-name} .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME TOG-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL TOG-1 s-object
ON VALUE-CHANGED OF TOG-1 IN FRAME F-Main /* Часть 1 - Движение Нефтепродуктов по количеству */
DO:
  assign tog-1.
  if tog-1 = true then do:
    enable
      tog-1-whole-gds
      tog-1-pump-one
      tog-1-out-pump-with-icnt
      with frame {&frame-name} .
  end.
  else do:
    disable
      tog-1-whole-gds
      tog-1-pump-one
      tog-1-out-pump-with-icnt
      with frame {&frame-name} .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME TOG-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL TOG-2 s-object
ON VALUE-CHANGED OF TOG-2 IN FRAME F-Main /* Часть 2 - Движение Нефтепродуктов по количеству и суммам */
DO:
  assign tog-2.
  if tog-2 = true then do:
    enable  tog-2-cp-grp with frame {&frame-name} .
  end.
  else do:
    disable tog-2-cp-grp with frame {&frame-name} .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME TOG-3
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL TOG-3 s-object
ON VALUE-CHANGED OF TOG-3 IN FRAME F-Main /* Часть 3 - Движение ТНП по количеству и суммам */
DO:
  assign tog-3.
  if tog-3 = true then  do:
    enable  classify /* sorttype */ with frame {&frame-name} .
  end.
  else do:
    disable classify /* sorttype */ with frame {&frame-name} .
  end.
  display classify /* sorttype */ with frame {&frame-name} .

  apply "value-changed":u to classify in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME TOG-5
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL TOG-5 s-object
ON VALUE-CHANGED OF TOG-5 IN FRAME F-Main /* Часть 5 - Движение материальных ценностей */
DO:
  assign tog-5.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME TOG-5-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL TOG-5-1 s-object
ON VALUE-CHANGED OF TOG-5-1 IN FRAME F-Main /* Часть 5 - Движение денежных средств */
DO:
  assign tog-5-1.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME TOG-81
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL TOG-81 s-object
ON VALUE-CHANGED OF TOG-81 IN FRAME F-Main 
DO:
  assign TOG-81.
  if TOG-81 = true then do:
    enable
      TOG-82
      with frame {&frame-name} .
  end.
  else do:
    TOG-82 = false.
    disable
      TOG-82
      with frame {&frame-name} .
      
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME





&Scoped-define SELF-NAME Tog-level
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Tog-level s-object
ON VALUE-CHANGED OF Tog-level IN FRAME F-Main /* с уровня */
DO:
  assign tog-level.
  if tog-level = true then do:
    display var-level with frame {&frame-name} .
    enable  var-level with frame {&frame-name} .
  end.
  else do:
    display var-level with frame {&frame-name} .
    disable var-level with frame {&frame-name} .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK s-object 


/* ***************************  Main Block  *************************** */
{ gbl/personly.i }
/* If testing in the UIB, initialize the SmartObject. */
{ gbl/getcntxt.i get " " my-handle }

&IF DEFINED(UIB_IS_RUNNING) <> 0 &THEN
  RUN dispatch IN THIS-PROCEDURE ( INPUT 'initialize':U ).
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-ext-system s-object 
PROCEDURE get-ext-system :
DEFINE INPUT PARAMETER p-interface AS LOGICAL NO-UNDO.
DEFINE VARIABLE v-ok AS LOGICAL NO-UNDO.
DEFINE VARIABLE v-int AS integer NO-UNDO.
DEFINE VARIABLE v-uniq-key-rec AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-tbl-row AS rowid NO-UNDO.
DEFINE VARIABLE v-tbl-name AS CHARACTER NO-UNDO.
DEFINE BUFFER buf_ext-system FOR ub.ext-system.
IF f-esys-id <> 0  THEN DO:
   FIND FIRST buf_ext-system NO-LOCK WHERE
                buf_ext-system.esys-id = f-esys-id
         AND buf_ext-system.db-num = 0 NO-ERROR.
   IF AVAILABLE buf_ext-system THEN DO:
       RUN gen-key-rec IN THIS-PROCEDURE ( INPUT {&TABLE_ext-system}
                                          ,INPUT (BUFFER buf_ext-system:HANDLE)
                                          ,OUTPUT v-uniq-key-rec) NO-ERROR.
   END.
END.
 IF p-interface THEN DO:
      run bge/oxmlexts.p (
            input my-handle
          , input 2                         /* 2- Единичный выбор - 0. Множественный - 1*/
          , input substitute("esys-type > &1", {&openxml-type-ordinal}) /*p-where-string*/
          , input v-uniq-key-rec        /* То, что уже выбрано (список) */
          , output v-rid-list          /* Список выбранных подсистем ( string( db-num ) + chr(6) + string( esys-id ) )*/
          , output v-ok               /* yes, если выбор был сделан. no - Если был отказ от выбора */
      ).

     IF NOT v-ok  THEN RETURN ERROR.

          run gen-row-keyr in this-procedure
          ( input v-rid-list
           ,input ?
           ,input "ub"
           ,input ?
           ,input no-lock
           ,output v-tbl-row
           ,output v-tbl-name
         ).
        find first buf_ext-system no-lock where
                  rowid(buf_ext-system) = v-tbl-row.

  END.
  IF AVAILABLE buf_ext-system
  AND (buf_ext-system.esys-id   <> f-esys-id
  OR NOT p-interface) THEN DO:
    f-esys-id = buf_ext-system.esys-id.
    f-esys-name = buf_ext-system.esys-NAME.
    DISPLAY
    f-esys-id
    f-esys-name
    WITH FRAME {&FRAME-NAME}.

  END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ini-from-selgds s-object 
PROCEDURE ini-from-selgds :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  CASE X-SelectGood :
    WHEN {&g-all} THEN DO:
      ASSIGN Classify :RADIO-BUTTONS IN FRAME {&FRAME-NAME} =
         "Группы 1-го уровня,"             + "no-classify":U +
        ",Группы с n-уровнeм вложенности," + "n-level":U     +
        ",Терминальные группы,"            + "t-level":U     +
        ",Только итоги,"                   + "totals":U .
    END. /* {&g-all} */
    WHEN {&g-grp} THEN DO:
      ASSIGN Classify :RADIO-BUTTONS IN FRAME {&FRAME-NAME} =
         "Выбранные группы,"                            + "no-classify":U +
        ",Выбранные группы -> с n-уровнeм вложенности," + "n-level":U     +
        ",Выбранные группы -> терминальные группы,"     + "t-level":U     +
        ",Только итоги по выбранным группам,"           + "totals":U .
    END. /* {&g-grp} */
  END CASE. /* X-SelectGood */
END PROCEDURE. /* ini-from-selgds */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-initialize s-object 
PROCEDURE local-initialize :
/*------------------------------------------------------------------------------
  Purpose:     Override standard ADM method
  Notes:
------------------------------------------------------------------------------*/
  define variable v-init as logical   no-undo .
  /* Code placed here will execute PRIOR to standard behavior. */

  /* Dispatch standard ADM method.                             */
  RUN dispatch IN THIS-PROCEDURE ( INPUT 'initialize':U ) .

  /* Code placed here will execute AFTER standard behavior.    */
    { gbl/conf-rd.i
        "'is-wth'"
        "''"
        "''"
        0
        "''"
        "''"
        "''"
        NO
        dops
        dopst
        NO-ERROR
    }
  if not error-status :error
    and dops = "yes":u
  then do:
    assign
      is-wth = true
    .
  end.
  else do:
    assign
      is-wth = false
    .
  end.
  /*проверим конф параметр is-elved*/
  { gbl/conf-rd.i
  "'is-elved'"
  "''"
  "''"
  0
  "''"
  "''"
  "''"
  no
  dops
  dopst
  no-error
  }
  if not error-status :error
    and dops = "yes":u
  then do:
    assign
      is-elved = true
    .
  end.
  else do:
    assign
      is-elved = false
    .
  end.

  assign
    v-init = false
  .
CASE place-call:
  WHEN {&TABLE_schedule}
  or
  when {&TABLE_rp-by-call}
  THEN DO:
    RUN rcps_get-profile-id IN parent-handle ( OUTPUT v-profile-id).
    CASE v-profile-id:
      WHEN 53 THEN DO:
       assign
       tog-weight :screen-value in frame {&frame-name} = 'no'
       tog-1 :screen-value in frame {&frame-name} = 'yes'
       tog-1-whole-gds :screen-value in frame {&frame-name} = 'no'
       tog-1-pump-one :screen-value in frame {&frame-name} = 'no'
       tog-2 :screen-value in frame {&frame-name} = 'yes'
       tog-2-cp-grp :screen-value in frame {&frame-name} = 'no'
       tog-3 :screen-value in frame {&frame-name} = 'yes'
       tog-4 :screen-value in frame {&frame-name} = 'no'
       tog-5 :screen-value in frame {&frame-name} = 'no'
       tog-6 :screen-value in frame {&frame-name} = 'no'
       tog-7 :screen-value in frame {&frame-name} = 'no'
       tog-8 :screen-value in frame {&frame-name} = 'no'
       tog-81 :screen-value in frame {&frame-name} = 'no'
       tog-82 :screen-value in frame {&frame-name} = 'no'
       tog-9 :screen-value in frame {&frame-name} = 'no'
       tog-10 :screen-value in frame {&frame-name} = 'no'
       f-line-of-page:screen-value in frame {&frame-name}  = string({&LS_PS_A4})
       tog-1-out-pump-with-icnt :screen-value in frame {&frame-name} = 'no'
       classify = "no-classify":u
       var-level :screen-value in frame {&frame-name} = '1':U
       .
        RUN ini-from-selgds IN THIS-PROCEDURE.

        apply "value-changed":u to tog-1 in frame {&frame-name}.
        apply "value-changed":u to tog-2 in frame {&frame-name}.
        apply "value-changed":u to tog-3 in frame {&frame-name}.
        f-esys-id = v-esys-id.
        f-shift-days-to-report = v-shift-days-to-report.
        RUN get-ext-system IN THIS-PROCEDURE ( INPUT NO).

        disable
        tog-1-whole-gds
        tog-1-pump-one
        tog-1-out-pump-with-icnt
        tog-2-cp-grp
        classify
        tog-weight
        tog-1
        tog-2
        tog-3
        tog-4
        tog-5
        tog-6
        tog-7
        tog-8
        tog-82
        tog-9
        tog-10
        f-line-of-page
        b-staff
        t-excel
        t-text
        with frame {&frame-name} .
        hide
        tog-weight
        tog-1-whole-gds
        tog-1-pump-one
        tog-1-out-pump-with-icnt
        tog-2-cp-grp
        tog-4
        tog-5
        tog-6
        tog-7
        tog-8
        tog-82
        tog-9
        tog-10
        f-line-of-page
        b-staff
        t-excel
        t-text
        in frame {&frame-name} .
        display
        f-shift-days-to-report
        f-esys-name
        f-esys-id
        with frame {&frame-name} .
        enable
        b-esys
        f-esys-name
        f-shift-days-to-report
        with frame {&frame-name} .
      end.
      when 68 then do:
        assign
        tog-weight :screen-value in frame {&frame-name} = string(v-weight)
        tog-1 :screen-value in frame {&frame-name} = string(v-tog[1])
        tog-1-whole-gds :screen-value in frame {&frame-name} = string(v-whole-gds)
        tog-1-pump-one :screen-value in frame {&frame-name} = string(v-pump-one)
        tog-2 :screen-value in frame {&frame-name} = string(v-tog[2])
        tog-2-cp-grp :screen-value in frame {&frame-name} = string(v-cp-grp)
        tog-3 :screen-value in frame {&frame-name} = string(v-tog[3])
        tog-4 :screen-value in frame {&frame-name} = string(v-tog[4])
        tog-5 :screen-value in frame {&frame-name} = string(v-tog[5])
        tog-6 :screen-value in frame {&frame-name} = string(v-tog[6])
        tog-7 :screen-value in frame {&frame-name} = string(v-tog[7])
        tog-8 :screen-value in frame {&frame-name} = string(v-tog[8])
        tog-9 :screen-value in frame {&frame-name} = string(v-tog[9])
        tog-10 :screen-value in frame {&frame-name} = string(v-tog[10])
        f-line-of-page:screen-value in frame {&frame-name} = string(v-line-of-page)
        tog-1-out-pump-with-icnt :screen-value in frame {&frame-name} = string(v-el-icnt)
        classify:screen-value in frame {&frame-name}  = v-classify
        var-level :screen-value in frame {&frame-name} = string(v-level)
        sorttype:screen-value in frame {&frame-name}  = v-sorttype
        t-excel:screen-value in frame {&frame-name} =  string(lookup({&output-type-excel}, v-output-type) > 0)
        t-text:screen-value in frame {&frame-name} = string(lookup({&output-type-plain-text}, v-output-type) > 0)
        .
        RUN ini-from-selgds IN THIS-PROCEDURE.
        apply "value-changed":u to tog-1 in frame {&frame-name}.
        apply "value-changed":u to tog-2 in frame {&frame-name}.
        apply "value-changed":u to tog-3 in frame {&frame-name}.
        disable
        b-staff
        b-esys
        f-esys-name
        f-shift-days-to-report
        with frame {&frame-name} .
        hide
        b-staff
        f-shift-days-to-report
        f-esys-name
        f-esys-id
        in frame {&frame-name} .
      end.
    end case. /*CASE v-profile-id:*/
  end.
  otherwise do:
    disable
    b-esys
    f-esys-id
    f-esys-name
    f-shift-days-to-report
    t-excel
    t-text
    with frame {&frame-name} .
    hide
    b-esys
    f-esys-id
    f-esys-name
    f-shift-days-to-report
    t-excel
    t-text
    in frame {&frame-name} .


    run uf-get in this-procedure(
        input  {&uf-e-shift}
        ,input  v-cntxt-userid
        ,output v-uf-List_
        ,output v-uf-Naim
        ,output v-uf-print-graft
        ,output v-uf-sort-gr
        ,output v-uf-type-price
        ,output v-uf-type-val
    )  no-error.

    if not error-status:error then do:
        
      if num-entries(v-uf-List_, {&delim-par}) >= 17 then do:
        assign
          tog-weight                :screen-value in frame {&frame-name} = entry(1, v-uf-List_, {&delim-par})
          tog-1-whole-gds           :screen-value in frame {&frame-name} = entry(2, v-uf-List_, {&delim-par})
          tog-1-pump-one            :screen-value in frame {&frame-name} = entry(3, v-uf-List_, {&delim-par})
          tog-2-cp-grp              :screen-value in frame {&frame-name} = entry(4, v-uf-List_, {&delim-par})
  /*        tog-2-cp-grp              :screen-value in frame {&frame-name} = entry(5, v-uf-List_, {&delim-par})*/
  /*        tog-2-cp-grp              :screen-value in frame {&frame-name} = entry(6, v-uf-List_, {&delim-par})*/
          tog-1                     :screen-value in frame {&frame-name} = entry(7, v-uf-List_, {&delim-par})
          tog-2                     :screen-value in frame {&frame-name} = entry(8, v-uf-List_, {&delim-par})
          tog-3                     :screen-value in frame {&frame-name} = entry(9, v-uf-List_, {&delim-par})
          tog-4                     :screen-value in frame {&frame-name} = entry(10, v-uf-List_, {&delim-par})
          tog-5                     :screen-value in frame {&frame-name} = entry(11, v-uf-List_, {&delim-par})
          tog-6                     :screen-value in frame {&frame-name} = entry(12, v-uf-List_, {&delim-par})
          tog-7                     :screen-value in frame {&frame-name} = entry(13, v-uf-List_, {&delim-par})
          tog-8                     :screen-value in frame {&frame-name} = entry(14, v-uf-List_, {&delim-par})
          f-line-of-page            :screen-value in frame {&frame-name} = entry(15, v-uf-List_, {&delim-par})
          tog-9                     :screen-value in frame {&frame-name} = entry(16, v-uf-List_, {&delim-par})
          tog-10                    :screen-value in frame {&frame-name} = entry(17, v-uf-List_, {&delim-par})
        .
      end.
/*      if num-entries(v-uf-List_, {&delim-par}) >= 18 then do:
        assign
          tog-1-out-pump-with-icnt  :screen-value in frame {&frame-name} = entry(18, v-uf-List_, {&delim-par})
        .
      end. */

      if num-entries(v-uf-List_, {&delim-par}) >= 20 then do:
        assign
          tog-81  :screen-value in frame {&frame-name} = entry(19, v-uf-List_, {&delim-par})
          tog-82  :screen-value in frame {&frame-name} = entry(20, v-uf-List_, {&delim-par})
        .
      end.



      assign
        v-init = true
      .
    end.
    if v-init = false then do:
      assign
        tog-1     :screen-value in frame {&frame-name} = 'yes':u
        tog-2     :screen-value in frame {&frame-name} = 'yes':u
        tog-3     :screen-value in frame {&frame-name} = 'yes':u
        tog-4     :screen-value in frame {&frame-name} = 'yes':u
        tog-5     :screen-value in frame {&frame-name} = 'yes':u
        tog-6     :screen-value in frame {&frame-name} = 'yes':u
        tog-7     :screen-value in frame {&frame-name} = 'yes':u
        tog-8     :screen-value in frame {&frame-name} = 'yes':u
        tog-9     :screen-value in frame {&frame-name} = 'yes':u
        tog-10    :screen-value in frame {&frame-name} = 'yes':u
        tog-81    :screen-value in frame {&frame-name} = 'yes':u
        tog-82    :screen-value in frame {&frame-name} = 'yes':u
      .
    end.
    if integer( f-line-of-page :screen-value in frame {&frame-name} ) = 0
      or integer( f-line-of-page :screen-value in frame {&frame-name} ) = ?
    then do:
      assign
        f-line-of-page :screen-value in frame {&frame-name} = '{&LS_PS_A4}':U
      .
    end.
    assign
      classify = "no-classify":u
      var-level :screen-value in frame {&frame-name} = '1':U
    .

    if is-wth = false then do:
      assign
        TOG-5 :screen-value in frame {&frame-name} = 'no':u
        
      .
      hide tog-5 in frame {&frame-name}.
      enable TOG-5-1 with frame {&frame-name}.
    end.
    if is-elved = false then do:
      assign
        tog-8 :screen-value in frame {&frame-name} = 'no':u
      .
      hide tog-8 in frame {&frame-name}.
    end.

    IF NOT CAN-FIND( FIRST obj-list WHERE obj-list.obj-code = v-cntxt-obj-code AND obj-list.obj-type = v-cntxt-obj-type ) THEN DO:
      { cmp/cr-objls.i v-cntxt-obj-type v-cntxt-obj-code }
    END.
    RUN ini-from-selgds IN THIS-PROCEDURE.

    apply "value-changed":u to tog-1 in frame {&frame-name}.
    apply "value-changed":u to tog-2 in frame {&frame-name}.
    apply "value-changed":u to tog-3 in frame {&frame-name}.
    apply "value-changed":u to tog-81 in frame {&frame-name}.
  end. /*otherwise do:*/
end case.

/* disable   TOG-82  with frame {&frame-name} . */



END PROCEDURE. /* local-initialize */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-params s-object 
PROCEDURE my-params :
define input parameter p-action as character no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define variable v-obj-str as character no-undo .
define variable v-index-id as integer no-undo .
define variable v2-index-id as integer no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as integer no-undo .
define variable v-value-logical as logical no-undo .
define variable v-last-shift as decimal no-undo .
define variable v-fact-order  as decimal no-undo .
define variable v-shift-end-fact-order as decimal no-undo .
define variable v-day-end-fact-order as decimal no-undo .
define variable v-rv as character no-undo .

CASE p-action :
  WHEN 'get' THEN DO:
    IF v-profile-id = 53  THEN DO:
       v-index-id = 0.
       RUN rcps_get-value IN parent-handle (
                                          input "p-esys-id"
                                         ,INPUT-output v-index-id
                                         ,output v-value-character /*p-value-character*/
                                         ,output v-value-date /*p-value-date*/
                                         ,output v-value-decimal /*p-value-decimal*/
                                         ,output v-esys-id /*p-value-integer*/
                                         ,output v-value-logical /*p-value-logical*/
                                         ) no-error .
       v-index-id = 0.
       RUN rcps_get-value IN parent-handle (
                                          input "p-shift-days-to-report"
                                         ,INPUT-output v-index-id
                                         ,output v-value-character /*p-value-character*/
                                         ,output v-value-date /*p-value-date*/
                                         ,output v-value-decimal /*p-value-decimal*/
                                         ,output v-shift-days-to-report /*p-value-integer*/
                                         ,output v-value-logical /*p-value-logical*/
                                         ) no-error .
      empty temp-table X-init_obj-list.
      v-index-id = 1.
      v2-index-id = 1.
      do while v-index-id >= 1 :
        RUN rcps_get-value IN parent-handle (
                                        input "p-objects"
                                        ,INPUT-output v-index-id
                                        ,output v-obj-str /*p-value-character*/
                                        ,output v-value-date /*p-value-date*/
                                        ,output v-value-decimal /*p-value-decimal*/
                                        ,output v-value-integer /*p-value-integer*/
                                        ,output v-value-logical /*p-value-logical*/
                                        ) no-error .
        if error-status:error then leave.
        if v-obj-str = '' then leave.
        find first X-init_obj-list where
                  X-init_obj-list.obj-type = substring(v-obj-str, 1, 3)
              and  X-init_obj-list.obj-code = integer(substring(v-obj-str, 4)) no-error.
        if not available X-init_obj-list then do:
          create X-init_obj-list.
          assign
          X-init_obj-list.obj-type = substring(v-obj-str, 1, 3)
          X-init_obj-list.obj-code = integer(substring(v-obj-str, 4))
          .
          release X-init_obj-list.
        end.
        create last-shift.
        assign
        last-shift.obj-type = substring(v-obj-str, 1, 3)
        last-shift.obj-code = integer(substring(v-obj-str, 4))
        .
        run cur-time in this-procedure ( output v-today, output v-time).
        run factord in this-procedure
          (input  (v-today - v-shift-days-to-report)   /* p-fact-date            */
          ,input  v-time  /* p-fact-time            */
          ,input  1                         /* p-fact-num             */
          ,input  (v-today - v-shift-days-to-report)   /* p-shift-date           */
          ,input  1  /* p-shift-num            */
          ,input  yes                /* p-shift-on             */
          ,output v-fact-order              /* p-fact-order           */
          ,output v-shift-end-fact-order    /* p-shift-end-fact-order */
          ,output v-day-end-fact-order      /* p-day-end-fact-order   */
          ) no-error .
        RUN rcps_get-value IN parent-handle (
                                        input "last-shift"
                                        ,INPUT-output v2-index-id
                                        ,output v-value-character /*p-value-character*/
                                        ,output v-value-date /*p-value-date*/
                                        ,output v-last-shift /*p-value-decimal*/
                                        ,output v-value-integer /*p-value-integer*/
                                        ,output v-value-logical /*p-value-logical*/
                                        ) no-error .

        if error-status:error
        and v-last-shift > 0
        then do:
          last-shift.fact-order = v-last-shift .
        end.
        else do:
          last-shift.fact-order = v-shift-end-fact-order.
        end.
        release last-shift.
        if v-index-id < 1
        then do:
          leave.
        end.
      end. /*      do while v-index-id >= 1 :*/
      X-selectobject =  {&obj-choice}.

    END. /*IF v-profile-id = 53  THEN DO:*/
    IF v-profile-id = 68  THEN DO:
      define variable v-ii as integer no-undo .
      v-index-id = 0.
      do v-ii = 1 to 9 :
        v-index-id = v-ii.
        RUN rcps_get-value IN parent-handle (
                                        input "p-tog"
                                        ,INPUT-output v-index-id
                                        ,output v-value-character /*p-value-character*/
                                        ,output v-value-date /*p-value-date*/
                                        ,output v-value-decimal /*p-value-decimal*/
                                        ,output v-value-integer /*p-value-integer*/
                                        ,output v-tog[v-ii] /*p-value-logical*/
                                        ) no-error .
        if error-status:error then leave.
      end.
      v-index-id = 0.
      RUN rcps_get-value IN parent-handle (
                                          input "p-weight"
                                         ,INPUT-output v-index-id
                                         ,output v-value-character /*p-value-character*/
                                         ,output v-value-date /*p-value-date*/
                                         ,output v-value-decimal /*p-value-decimal*/
                                         ,output v-value-integer /*p-value-integer*/
                                         ,output v-weight /*p-value-logical*/
                                         ) no-error .
       v-index-id = 0.
       RUN rcps_get-value IN parent-handle (
                                          input "p-classify"
                                         ,INPUT-output v-index-id
                                         ,output v-classify /*p-value-character*/
                                         ,output v-value-date /*p-value-date*/
                                         ,output v-value-decimal /*p-value-decimal*/
                                         ,output v-value-integer /*p-value-integer*/
                                         ,output v-value-logical /*p-value-logical*/
                                         ) no-error .
       v-index-id = 0.
       RUN rcps_get-value IN parent-handle (
                                          input "p-sorttype"
                                         ,INPUT-output v-index-id
                                         ,output v-sorttype /*p-value-character*/
                                         ,output v-value-date /*p-value-date*/
                                         ,output v-value-decimal /*p-value-decimal*/
                                         ,output v-value-integer /*p-value-integer*/
                                         ,output v-value-logical /*p-value-logical*/
                                         ) no-error .
       v-index-id = 0.
       RUN rcps_get-value IN parent-handle (
                                          input "p-level"
                                         ,INPUT-output v-index-id
                                         ,output v-value-character /*p-value-character*/
                                         ,output v-value-date /*p-value-date*/
                                         ,output v-value-decimal /*p-value-decimal*/
                                         ,output v-level /*p-value-integer*/
                                         ,output v-value-logical /*p-value-logical*/
                                         ) no-error .
       v-index-id = 0.
       RUN rcps_get-value IN parent-handle (
                                          input "p-pump-one"
                                         ,INPUT-output v-index-id
                                         ,output v-value-character /*p-value-character*/
                                         ,output v-value-date /*p-value-date*/
                                         ,output v-value-decimal /*p-value-decimal*/
                                         ,output v-value-integer /*p-value-integer*/
                                         ,output v-pump-one /*p-value-logical*/
                                         ) no-error .
       v-index-id = 0.
       RUN rcps_get-value IN parent-handle (
                                          input "p-whole-gds"
                                         ,INPUT-output v-index-id
                                         ,output v-value-character /*p-value-character*/
                                         ,output v-value-date /*p-value-date*/
                                         ,output v-value-decimal /*p-value-decimal*/
                                         ,output v-value-integer /*p-value-integer*/
                                         ,output v-whole-gds /*p-value-logical*/
                                         ) no-error .
       v-index-id = 0.
       RUN rcps_get-value IN parent-handle (
                                          input "p-el-cnt"
                                         ,INPUT-output v-index-id
                                         ,output v-value-character /*p-value-character*/
                                         ,output v-value-date /*p-value-date*/
                                         ,output v-value-decimal /*p-value-decimal*/
                                         ,output v-value-integer /*p-value-integer*/
                                         ,output v-el-icnt /*p-value-logical*/
                                         ) no-error .
       v-index-id = 0.
       RUN rcps_get-value IN parent-handle (
                                          input "p-cp-grp"
                                         ,INPUT-output v-index-id
                                         ,output v-value-character /*p-value-character*/
                                         ,output v-value-date /*p-value-date*/
                                         ,output v-value-decimal /*p-value-decimal*/
                                         ,output v-value-integer /*p-value-integer*/
                                         ,output v-cp-grp /*p-value-logical*/
                                         ) no-error .
       v-index-id = 0.
       RUN rcps_get-value IN parent-handle (
                                          input "p-output-type"
                                         ,INPUT-output v-index-id
                                         ,output v-output-type /*p-value-character*/
                                         ,output v-value-date /*p-value-date*/
                                         ,output v-value-decimal /*p-value-decimal*/
                                         ,output v-value-integer /*p-value-integer*/
                                         ,output v-value-logical /*p-value-logical*/
                                         ) no-error .
       v-index-id = 0.
       RUN rcps_get-value IN parent-handle (
                                          input "p-line-of-page"
                                         ,INPUT-output v-index-id
                                         ,output v-value-character /*p-value-character*/
                                         ,output v-value-date /*p-value-date*/
                                         ,output v-value-decimal /*p-value-decimal*/
                                         ,output v-line-of-page /*p-value-integer*/
                                         ,output v-value-logical /*p-value-logical*/
                                         ) no-error .

    END. /*IF v-profile-id = 68  THEN DO:*/
    RUN local-initialize IN THIS-PROCEDURE.
  END.
  WHEN 'set' THEN DO:
    IF v-profile-id = 53 THEN DO:
      ASSIGN
      FRAME {&FRAME-NAME}
      f-esys-id
      f-shift-days-to-report
      .
      RUN rcps_set-value IN parent-handle (
                                        input "p-esys-id"
                                      ,INPUT 0
                                      ,input '' /*p-value-character*/
                                      ,input ?  /*p-value-date*/
                                      ,input 0.0 /*p-value-decimal*/
                                      ,input f-esys-id /*p-value-integer*/
                                      ,input no /*p-value-logical*/
                                      ) no-error .
      RUN rcps_set-value IN parent-handle (
                                        input "p-shift-days-to-report"
                                      ,INPUT 0
                                      ,input '' /*p-value-character*/
                                      ,input ?  /*p-value-date*/
                                      ,input 0.0 /*p-value-decimal*/
                                      ,input f-shift-days-to-report /*p-value-integer*/
                                      ,input no /*p-value-logical*/
                                      ) no-error .

      v-index-id = 0.
      for each obj-list :
        v-index-id = v-index-id + 1.
        RUN rcps_set-value IN parent-handle (
                                        input "p-objects"
                                        ,INPUT v-index-id
                                        ,input substitute("&1&2", obj-list.obj-type, obj-list.obj-code) /*p-value-character*/
                                        ,input ?  /*p-value-date*/
                                        ,input 0.0 /*p-value-decimal*/
                                        ,input 0 /*p-value-integer*/
                                        ,input no /*p-value-logical*/
                                        ) no-error .
        if error-status:error then do:
          message
          error-status:get-message(1) return-value
          view-as alert-box .
          undo, return error .
        end.
        find first last-shift where
                  last-shift.obj-type = obj-list.obj-type
              and last-shift.obj-code = obj-list.obj-code no-error.
        if available last-shift then do:
          RUN rcps_set-value IN parent-handle (
                                          input "p-last-shift"
                                          ,INPUT v-index-id
                                          ,input '' /*p-value-character*/
                                          ,input ?  /*p-value-date*/
                                          ,input last-shift.fact-order /*p-value-decimal*/
                                          ,input 0 /*p-value-integer*/
                                          ,input no /*p-value-logical*/
                                          ) no-error .
        end.
      end. /*    for each obj-list :*/
      v-index-id = v-index-id + 1.
      do while true:
        run rcps_proc-b-del in parent-handle (
                                                input "p-objects"
                                              ,input v-index-id) no-error.
        v-rv = return-value .
        if error-status:error
        or v-rv = "not-found" then leave.
        run rcps_proc-b-del in parent-handle (
                                                input "p-last-shift"
                                              ,input v-index-id) no-error.
        v-index-id = v-index-id + 1.
      end.
      if error-status:error then do:
        message
        error-status:get-message(1) return-value
        view-as alert-box .
        undo, return error .
      end.
    END. /*IF v-profile-id = 53 THEN DO:*/
    IF v-profile-id = 68 THEN DO:
      ASSIGN
      FRAME {&FRAME-NAME}
      tog-weight
      tog-1
      tog-1-whole-gds
      tog-1-pump-one
      tog-2
      tog-2-cp-grp
      tog-3
      tog-4
      tog-5
      tog-6
      tog-7
      tog-8
      tog-9
      tog-10
      f-line-of-page
      tog-1-out-pump-with-icnt
      classify
      var-level
      t-excel
      t-text
      v-tog[1] = tog-1
      v-tog[2] = tog-2
      v-tog[3] = tog-3
      v-tog[4] = tog-4
      v-tog[5] = tog-5
      v-tog[6] = tog-6
      v-tog[7] = tog-7
      v-tog[8] = tog-8
      v-tog[9] = tog-9
      v-tog[10] = tog-10
      v-output-type = ","
      ENTRY(1, v-output-type) = (IF t-excel THEN {&output-type-excel} ELSE '')
      ENTRY(2, v-output-type) = (IF t-text THEN {&output-type-plain-text} ELSE '')
      v-output-type = TRIM(v-output-type, {&comma-char})
      .
      if not t-excel
      and not t-text then do:
        define variable glog as logical no-undo .
        message
        "Внимание!! Вы не выбрали ни вывод в текстовый файл, ни вывод в Excel!" skip
        "Продолжить?"
        view-as alert-box question buttons yes-no update glog.
        if not glog then return error.
      end.
      do v-ii = 1 to 9 :
        RUN rcps_set-value IN parent-handle (
                                        input "p-tog"
                                        ,INPUT v-ii
                                        ,input '' /*p-value-character*/
                                        ,input ?  /*p-value-date*/
                                        ,input 0.0 /*p-value-decimal*/
                                        ,input 0 /*p-value-integer*/
                                        ,input v-tog[v-ii] /*p-value-logical*/
                                        ) no-error .
        if error-status:error then do:
          message
          error-status:get-message(1) return-value
          view-as alert-box .
          undo, return error .
        end.
      end. /*    do v-ii :*/
      RUN rcps_set-value IN parent-handle (
                                        input "p-weight"
                                      ,INPUT 0
                                      ,input '' /*p-value-character*/
                                      ,input ?  /*p-value-date*/
                                      ,input 0.0 /*p-value-decimal*/
                                      ,input 0 /*p-value-integer*/
                                      ,input tog-weight /*p-value-logical*/
                                      ) no-error .
      RUN rcps_set-value IN parent-handle (
                                        input "p-weight"
                                      ,INPUT 0
                                      ,input classify /*p-value-character*/
                                      ,input ?  /*p-value-date*/
                                      ,input 0.0 /*p-value-decimal*/
                                      ,input 0 /*p-value-integer*/
                                      ,input no /*p-value-logical*/
                                      ) no-error .
      RUN rcps_set-value IN parent-handle (
                                        input "p-sorttype"
                                      ,INPUT 0
                                      ,input sorttype /*p-value-character*/
                                      ,input ?  /*p-value-date*/
                                      ,input 0.0 /*p-value-decimal*/
                                      ,input 0 /*p-value-integer*/
                                      ,input no /*p-value-logical*/
                                      ) no-error .
      RUN rcps_set-value IN parent-handle (
                                        input "p-level"
                                      ,INPUT 0
                                      ,input '' /*p-value-character*/
                                      ,input ?  /*p-value-date*/
                                      ,input 0.0 /*p-value-decimal*/
                                      ,input var-level /*p-value-integer*/
                                      ,input no /*p-value-logical*/
                                      ) no-error .

      RUN rcps_set-value IN parent-handle (
                                        input "p-pump-one"
                                      ,INPUT 0
                                      ,input '' /*p-value-character*/
                                      ,input ?  /*p-value-date*/
                                      ,input 0.0 /*p-value-decimal*/
                                      ,input 0 /*p-value-integer*/
                                      ,input tog-1-pump-one /*p-value-logical*/
                                      ) no-error .
      RUN rcps_set-value IN parent-handle (
                                        input "p-whole-gds"
                                      ,INPUT 0
                                      ,input '' /*p-value-character*/
                                      ,input ?  /*p-value-date*/
                                      ,input 0.0 /*p-value-decimal*/
                                      ,input 0 /*p-value-integer*/
                                      ,input tog-1-whole-gds /*p-value-logical*/
                                      ) no-error .
      RUN rcps_set-value IN parent-handle (
                                        input "p-el-cnt"
                                      ,INPUT 0
                                      ,input '' /*p-value-character*/
                                      ,input ?  /*p-value-date*/
                                      ,input 0.0 /*p-value-decimal*/
                                      ,input 0 /*p-value-integer*/
                                      ,input tog-1-out-pump-with-icnt /*p-value-logical*/
                                      ) no-error .

      RUN rcps_set-value IN parent-handle (
                                        input "p-cp-grp"
                                      ,INPUT 0
                                      ,input '' /*p-value-character*/
                                      ,input ?  /*p-value-date*/
                                      ,input 0.0 /*p-value-decimal*/
                                      ,input 0 /*p-value-integer*/
                                      ,input tog-2-cp-grp /*p-value-logical*/
                                      ) no-error .
      RUN rcps_set-value IN parent-handle (
                                        input "p-output-type"
                                      ,INPUT 0
                                      ,input v-output-type /*p-value-character*/
                                      ,input ?  /*p-value-date*/
                                      ,input 0.0 /*p-value-decimal*/
                                      ,input 0 /*p-value-integer*/
                                      ,input no /*p-value-logical*/
                                      ) no-error .

      RUN rcps_set-value IN parent-handle (
                                        input "p-line-of-page"
                                      ,INPUT 0
                                      ,input '' /*p-value-character*/
                                      ,input ?  /*p-value-date*/
                                      ,input 0.0 /*p-value-decimal*/
                                      ,input f-line-of-page /*p-value-integer*/
                                      ,input no /*p-value-logical*/
                                      ) no-error .

    END. /*IF v-profile-68 = 68 THEN DO:*/
  END.
END CASE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-report s-object 
PROCEDURE my-report :
define variable v-base-code like ub.sysconf.base-code no-undo .
define buffer buf_currency for ub.currency.
define variable v_dataseth as handle no-undo .
define variable v-xmlh as handle no-undo .

  { gbl/basecode.i v-cntxt-host-code-obj v-base-code }
  find first buf_currency no-lock
    where buf_currency.curr-code = v-base-code
  .
  
  if place-call = "'new-rep'" then do:
    run rep/r-new-shift.p
      ( input my-handle
       ,input this-procedure:handle /*p-parent-handle*/
       ,input this-procedure:handle /*      p-log-handle*/
       ,input this-procedure:handle /*   p-cont-handle*/
       ,input this-procedure:handle /*p-call-handle*/
       ,input ? /*p-rebh*/
       ,input ? /*p-redbh*/
       ,input '' /*p-report-id*/
       ,input '' /*p-xsd-file*/
       ,input "" /*p-log-file-name*/
       ,input integer({&repcalc-type-operator}) /*p-batch*/
       ,input 0 /*p-codex-id*/
       ,input 0 /*p-ruleset-id*/
       ,INPUT v-cntxt-obj-code
       ,INPUT v-cntxt-obj-type
       ,INPUT buf_currency.curr-abbr
       ,INPUT v-base-code
       ,input f-line-of-page
       ,input tog-weight
       ,INPUT Classify
       ,INPUT SortType
       ,input tog-level
       ,input var-level
       ,INPUT tog-1
       ,INPUT tog-2
       ,input tog-3
       ,input tog-4
       ,input tog-5
       ,INPUT TOG-5-1
       ,input tog-6
       ,input tog-7
       ,input tog-81
       ,input tog-82
       ,input tog-9
       ,input tog-10
       ,input tog-1-pump-one
       ,input tog-1-whole-gds
       ,input tog-1-out-pump-with-icnt
       ,input tog-2-cp-grp
       ,input yes /*p-plain-text*/
       ,input yes /*p-xls*/
       ,input '' /*p-output-dir - выбираем внутри*/
       ,input-output v_dataseth /*если не batch ничего не возвращается*/
       ,input table temp-xml-tables
      ) .    
  end. /*place-call = "'new-rep'"*/
  else
    run rep/r-shift.p
      ( input my-handle
       ,input this-procedure:handle /*p-parent-handle*/
       ,input this-procedure:handle /*      p-log-handle*/
       ,input this-procedure:handle /*   p-cont-handle*/
       ,input this-procedure:handle /*p-call-handle*/
       ,input ? /*p-rebh*/
       ,input ? /*p-redbh*/
       ,input '' /*p-report-id*/
       ,input '' /*p-xsd-file*/
       ,input "" /*p-log-file-name*/
       ,input integer({&repcalc-type-operator}) /*p-batch*/
       ,input 0 /*p-codex-id*/
       ,input 0 /*p-ruleset-id*/
       ,INPUT v-cntxt-obj-code
       ,INPUT v-cntxt-obj-type
       ,INPUT buf_currency.curr-abbr
       ,INPUT v-base-code
       ,input f-line-of-page
       ,input tog-weight
       ,INPUT Classify
       ,INPUT SortType
       ,input tog-level
       ,input var-level
       ,INPUT tog-1
       ,INPUT tog-2
       ,input tog-3
       ,input tog-4
       ,input tog-5
       ,input tog-6
       ,input tog-7
       ,input tog-8
       ,input tog-9
       ,input tog-10
       ,input tog-1-pump-one
       ,input tog-1-whole-gds
       ,input tog-1-out-pump-with-icnt
       ,input tog-2-cp-grp
       ,input yes /*p-plain-text*/
       ,input yes /*p-xls*/
       ,input '' /*p-output-dir - выбираем внутри*/
       ,input-output v_dataseth /*если не batch ничего не возвращается*/
       ,input table temp-xml-tables
      ) .
      
END PROCEDURE. /* my-report */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-var s-object 
PROCEDURE my-var :
/*------------------------------------------------------------------------------
  Purpose:     здесь происходит вызов  значений переменных
  например  Название отчета, может быть еще пример шапки???
------------------------------------------------------------------------------*/
case v-profile-id:
  when 53 THEN DO:

    ASSIGN FRAME {&FRAME-NAME}
    f-esys-id
    f-shift-days-to-report
    .
    /* строки в которых содержатся выбранные обекты */
    ASSIGN STR-obj-type = ''
          STR-obj-code = ''
          STR-obj-name = ''
          STR-obj      = ''.

    FOR EACH obj-list NO-LOCK :
      ASSIGN STR-obj-type = STR-obj-type + obj-list.obj-type + ','
            STR-obj-code = STR-obj-code + String(obj-list.obj-code) + ','
            STR-obj-name = STR-obj-name + obj-list.obj-name + ','
            STR-obj      = STR-obj      +         obj-list.obj-type   + '#'
                                        + STRING( obj-list.obj-code ) + ',' .
    END.

    ASSIGN ReportHeader = substitute("&1Кол-во дней для расчета ни разу нерассчитанных  объектов: &2&1" +
                                      "Маршрутизация во ВС: &3 &4"
                                      , {&new-line}
                                      , f-shift-days-to-report
                                      , F-ESYS-ID
                                      , f-esys-name).
    .
  end.
  when 68 or
  when 0
  then do:
    ASSIGN FRAME {&FRAME-NAME}
      f-line-of-page tog-weight
      tog-level var-level Classify /* SortType */
      tog-1 tog-2 tog-3 tog-4 tog-6 tog-7 tog-8 tog-81 tog-82 tog-9 tog-10
      tog-1-whole-gds tog-1-pump-one tog-1-out-pump-with-icnt tog-2-cp-grp
      .
    if is-wth then do:
      assign
        tog-5
      .
    end.
    ELSE TOG-5-1.
    /* строки в которых содержатся выбранные обекты */
    ASSIGN STR-obj-type = ''
          STR-obj-code = ''
          STR-obj-name = ''
          STR-obj      = ''.

    FOR EACH obj-list NO-LOCK :
      ASSIGN STR-obj-type = STR-obj-type + obj-list.obj-type + ','
            STR-obj-code = STR-obj-code + String(obj-list.obj-code) + ','
            STR-obj-name = STR-obj-name + obj-list.obj-name + ','
            STR-obj      = STR-obj      +         obj-list.obj-type   + '#'
                                        + STRING( obj-list.obj-code ) + ',' .
    END.

    { rep/claslabl.i }
    ASSIGN ReportHeader = "Классификация : " + t-Class +
                          ( IF tog-3 = YES AND Classify = "n-level":U THEN STRING( var-level ) ELSE " " ) + {&new-line} +
                          "Сортировка " + t-Sort + {&new-line} /*+ "Показать : " +
                          ( IF tog-3 = YES AND Show-Cost = YES THEN "Суммы в учетных ценах, "              ELSE " ":U ) +
                          ( IF tog-3 = YES AND Show-Crsa = YES THEN "Суммы в продажных ценах, "            ELSE " ":U ) +
                          ( IF tog-3 = YES AND Show-Sale = YES THEN "Суммы в продажных ценах документа , " ELSE " ":U ) +
                          ( IF tog-3 = YES AND ShowZero  = YES THEN "Показывать нулевые остатки "          ELSE
                                                                    "Не показывать нулевые остатки" ) */
    .

  end.
end case.

if not (place-call = {&table_schedule}
        or
        place-call = {&table_rp-by-call}) then do:
  assign
    v-uf-list_ = string( tog-weight )                 + {&delim-par}
                + string( tog-1-whole-gds )          + {&delim-par}
                + string( tog-1-pump-one )           + {&delim-par}
                + string( tog-2-cp-grp )             + {&delim-par}
                + /*string( classify )                 +*/ {&delim-par}
                + /*string( tog-level )                +*/ {&delim-par}
                + string( tog-1 )                    + {&delim-par}
                + string( tog-2 )                    + {&delim-par}
                + string( tog-3 )                    + {&delim-par}
                + string( tog-4 )                    + {&delim-par}
                + string( tog-5 )                    + {&delim-par}
                + string( tog-6 )                    + {&delim-par}
                + string( tog-7 )                    + {&delim-par}
                + string( tog-8 )                    + {&delim-par}
                + string( f-line-of-page )           + {&delim-par}
                + string( tog-9 )                    + {&delim-par}
                + string( tog-10 )                   + {&delim-par}
                + string( tog-1-out-pump-with-icnt )  + {&delim-par}
                + string( tog-81 )                    + {&delim-par}
                + string( tog-82 )                    
  .
  run uf-set in this-procedure
    ( input {&uf-e-shift}
    ,input v-cntxt-userid
    ,input v-uf-List_
    ,input v-uf-Naim
    ,input v-uf-print-graft
    ,input v-uf-sort-gr
    ,input v-uf-type-price
    ,input v-uf-type-val
    ) no-error .
end .
END PROCEDURE. /* my-var */

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

  CASE p-state :
      /* Object instance CASEs can go here to replace standard behavior
         or add new cases. */
      /* link-changed */
    WHEN "link-changed" THEN DO:
        RUN ini-from-selgds IN THIS-PROCEDURE.
    END. /* link-changed */
  END CASE. /* p-state */
END PROCEDURE. /* state-changed */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE write-to-log s-object 
PROCEDURE write-to-log :
define input param p-str as char no-undo.

do
on error undo, return error
:
   message
      p-str
      skip
   view-as alert-box error.

end. /* do on error */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

