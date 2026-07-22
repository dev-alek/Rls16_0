&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME DLGOKCAN


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER X_condition-keeping FOR condition-keeping.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS DLGOKCAN 
/*------------------------------------------------------------------------

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Карточка товара - дополнительная информаци

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/15/05
Author: Bakhtadze Natalya
Creation date: 12/15/05

----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-curr-obj-type LIKE ub.clients.obj-type no-undo .
define input parameter p-curr-obj-code LIKE ub.clients.obj-code no-undo .
define input parameter mode as char no-undo .
define input parameter goodsname as char no-undo .
define input parameter prodname as char no-undo .
define input parameter prodaddress as char no-undo .
define input parameter goods-unit-base like ub.goods.unit-base.

define input-output parameter destin_ like ub.goods.destin no-undo .
define input-output parameter attrib_ like ub.goods.attrib no-undo .
define input-output parameter user-rule_ like ub.goods.user-rule no-undo .
define input-output parameter sert_ like ub.goods.sert no-undo .
define input-output parameter struct_ like ub.goods.struct no-undo .
/*
define input-output parameter prod-date_ like ub.goods.prod-date no-undo .
*/
define input-output parameter deadline_ like ub.goods.deadline no-undo .
define input-output parameter sort_ like ub.goods.sort no-undo .
define input-output parameter tnved_ like ub.goods.tnved format "x(10)" no-undo .
define input-output parameter unit-cst_ like ub.goods.unit-cst no-undo .
define input-output parameter cst-base-rate_ like ub.goods.cst-base-rate no-undo .
define input-output parameter nationality_ like ub.goods.nationality no-undo .
define input-output parameter normal-wastage_ like ub.goods.normal-wastage no-undo .
define input-output parameter normal-waste_ like ub.goods.normal-waste no-undo .
define input-output parameter cond-keep-code_ like ub.goods.cond-keep-code no-undo .
define input-output parameter proof_ like ub.goods.proof no-undo .
define input-output parameter is-alc_ as logical no-undo .
define input-output parameter is-alc-mark_ as logical no-undo .
define input-output parameter alc-type-inner-code as integer no-undo .

/* Local Variable Definitions ---                                       */

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Карточка товара - дополнительная информация".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ cmp/t-tnved.i  }
{ cmp/showinf.i }
{ cmp/operlist.i }
{ gbl/getcntxt.i def }
{ ref/gds-attr.i }

define variable rid-tnved as recid no-undo.
define variable custvalue      as char initial ? no-undo.
define variable custtype       as char initial ? no-undo.
define variable alcvalue      as char initial ? no-undo.
define variable alctype       as char initial ? no-undo.
DEFINE VARIABLE old-frame-height AS DECIMAL NO-UNDO.
DEFINE VARIABLE old-rect-height AS DECIMAL NO-UNDO.
DEFINE VARIABLE v-expand AS logical NO-UNDO.
DEFINE VARIABLE v-downed AS character NO-UNDO.
DEFINE VARIABLE sh AS WIDGET-HANDLE NO-UNDO EXTENT 15.
DEFINE VARIABLE v-question-mode AS LOGICAL NO-UNDO.
DEFINE VARIABLE v-start-scales-type AS CHARACTER NO-UNDO.
define variable v-tab-order as character no-undo .
DEFINE BUFFER buf_units FOR ub.units.

&scop DIGI 'DIGI-SM':U
&Scop cas_lp 'CAS_lp-16x'

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME DLGOKCAN

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit RECT-11 RECT-12 b-quit b-help G-Name ~
P-Name P-Address TNVED r-tnved UNIT-CST CST-BASE-RATE g-unit-base r-cst ~
NATIONALITY Destin Attrib UserRule Sert Struct DeadLine Sort normal-wastage ~
normal-waste cond-keep-code r-cnd-keep is-alc is-alc-mark r-choose-alc-prod ~
choose-alc-prod struct-length l-struct 
&Scoped-Define DISPLAYED-OBJECTS G-Name P-Name P-Address TNVED tnved-name ~
UNIT-CST CST-BASE-RATE g-unit-base NATIONALITY Destin Attrib UserRule Sert ~
Struct DeadLine Sort normal-wastage normal-waste cond-keep-code proof ~
is-alc is-alc-mark choose-alc-prod struct-length l-struct cond-keep-name ~
choose-alc-prod-name 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-exit AUTO-GO 
     LABEL "Ввод":L 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-help 
     LABEL "&Помощь":L 
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-quit AUTO-END-KEY 
     LABEL "&Отмена":L 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON r-choose-alc-prod 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "" 
     SIZE 3 BY .83.

DEFINE BUTTON r-cnd-keep 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "" 
     SIZE 3 BY .83.

DEFINE BUTTON r-cst 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "r-cst" 
     SIZE 3 BY .83.

DEFINE BUTTON r-tnved 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "r-tnved" 
     SIZE 3 BY .83.

DEFINE VARIABLE NATIONALITY AS CHARACTER FORMAT "X(20)":U 
     LABEL "Статус товара (национальность)" 
     VIEW-AS COMBO-BOX INNER-LINES 2
     LIST-ITEMS "Российский","Иностранный" 
     DROP-DOWN-LIST
     SIZE 37.25 BY 1
     BGCOLOR 15 FGCOLOR 0  NO-UNDO.

DEFINE VARIABLE Struct AS CHARACTER 
     VIEW-AS EDITOR MAX-CHARS 1000 SCROLLBAR-VERTICAL
     SIZE 85 BY 3.46 NO-UNDO.

DEFINE VARIABLE Attrib AS CHARACTER FORMAT "X(100)":U 
     LABEL "Характеристики" 
     VIEW-AS FILL-IN 
     SIZE 55 BY 1
     BGCOLOR 15 FGCOLOR 0  NO-UNDO.

DEFINE VARIABLE choose-alc-prod AS INTEGER FORMAT "->,>>>,>>9":U INITIAL 0 
     LABEL "Выбор вида алкогольной продукции" 
     VIEW-AS FILL-IN 
     SIZE 10 BY .79
     BGCOLOR 15 FGCOLOR 0  NO-UNDO.

DEFINE VARIABLE choose-alc-prod-name AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 44.5 BY .67 NO-UNDO.

DEFINE VARIABLE cond-keep-code AS INTEGER FORMAT ">>9":U INITIAL 0 
     LABEL "Код усл. хран." 
     VIEW-AS FILL-IN 
     SIZE 5 BY 1
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE cond-keep-name AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 44.5 BY .67 NO-UNDO.

DEFINE VARIABLE CST-BASE-RATE AS DECIMAL FORMAT ">>,>>9.9999999999":U INITIAL 0 
     LABEL "Коэффициент" 
     VIEW-AS FILL-IN 
     SIZE 13.75 BY 1
     BGCOLOR 15 FGCOLOR 0  NO-UNDO.

DEFINE VARIABLE DeadLine AS INTEGER FORMAT ">>>>>>>9":U INITIAL 0 
     LABEL "Срок хранения" 
     VIEW-AS FILL-IN 
     SIZE 9.75 BY .92
     BGCOLOR 12 FGCOLOR 0  NO-UNDO.

DEFINE VARIABLE Destin AS CHARACTER FORMAT "X(100)":U 
     LABEL "Назначение" 
     VIEW-AS FILL-IN 
     SIZE 57.63 BY 1
     BGCOLOR 15 FGCOLOR 0  NO-UNDO.

DEFINE VARIABLE G-Name AS CHARACTER FORMAT "X(100)":U 
     LABEL "Название товара" 
     VIEW-AS FILL-IN 
     SIZE 53 BY 1
     BGCOLOR 8 FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE g-unit-base AS CHARACTER FORMAT "X(3)":U 
     LABEL "Учет.ед.изм" 
     VIEW-AS FILL-IN 
     SIZE 4.75 BY 1
     BGCOLOR 8 FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE l-struct AS CHARACTER FORMAT "X(256)":U INITIAL "Состав" 
      VIEW-AS TEXT 
     SIZE 10 BY .67 NO-UNDO.

DEFINE VARIABLE normal-wastage AS DECIMAL FORMAT "->9.99%":U INITIAL 0 
     LABEL "Норма ест. убыли" 
     VIEW-AS FILL-IN 
     SIZE 7.88 BY 1 NO-UNDO.

DEFINE VARIABLE normal-waste AS DECIMAL FORMAT "->9.99%":U INITIAL 0 
     LABEL "Норма отходов" 
     VIEW-AS FILL-IN 
     SIZE 7.88 BY 1 NO-UNDO.

DEFINE VARIABLE P-Address AS CHARACTER FORMAT "X(100)":U 
     LABEL "Адрес произв-ля" 
     VIEW-AS FILL-IN 
     SIZE 53 BY 1
     BGCOLOR 8 FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE P-Name AS CHARACTER FORMAT "X(100)":U 
     LABEL "Прозводитель" 
     VIEW-AS FILL-IN 
     SIZE 53 BY 1
     BGCOLOR 8 FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE proof AS DECIMAL FORMAT ">9.99%":U INITIAL 0 
     LABEL "Алкоголь" 
     VIEW-AS FILL-IN 
     SIZE 7.5 BY 1
     BGCOLOR 15 FGCOLOR 0  NO-UNDO.

DEFINE VARIABLE Sert AS CHARACTER FORMAT "X(100)":U 
     LABEL "Сертификат" 
     VIEW-AS FILL-IN 
     SIZE 56.5 BY 1
     BGCOLOR 15 FGCOLOR 0  NO-UNDO.

DEFINE VARIABLE Sort AS CHARACTER FORMAT "X(30)":U 
     LABEL "Сорт/проба" 
     VIEW-AS FILL-IN 
     SIZE 10.25 BY 1
     BGCOLOR 15 FGCOLOR 0  NO-UNDO.

DEFINE VARIABLE struct-length AS INTEGER FORMAT ">,>>9":U INITIAL 0 
     LABEL "Символов" 
      VIEW-AS TEXT 
     SIZE 6.5 BY .67
     FGCOLOR 12  NO-UNDO.

DEFINE VARIABLE TNVED AS CHARACTER FORMAT "x(10)" 
     LABEL "Код ТНВЭД" 
     VIEW-AS FILL-IN 
     SIZE 11.88 BY 1
     BGCOLOR 15 FGCOLOR 0  NO-UNDO.

DEFINE VARIABLE tnved-name AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 42.63 BY 1 NO-UNDO.

DEFINE VARIABLE UNIT-CST AS CHARACTER FORMAT "X(3)":U 
     LABEL "Тамож.ед.изм" 
     VIEW-AS FILL-IN 
     SIZE 6.25 BY 1
     BGCOLOR 15 FGCOLOR 0  NO-UNDO.

DEFINE VARIABLE UserRule AS CHARACTER FORMAT "X(100)":U 
     LABEL "Правила экпл-ции" 
     VIEW-AS FILL-IN 
     SIZE 53.25 BY 1
     BGCOLOR 15 FGCOLOR 0  NO-UNDO.

DEFINE RECTANGLE RECT-10
     EDGE-PIXELS 3 GRAPHIC-EDGE  NO-FILL   
     SIZE 97.5 BY 3.5
     BGCOLOR 8 FGCOLOR 0 .

DEFINE RECTANGLE RECT-11
     EDGE-PIXELS 3 GRAPHIC-EDGE  NO-FILL   
     SIZE 97.5 BY 4.83
     BGCOLOR 0 FGCOLOR 0 .

DEFINE RECTANGLE RECT-12
     EDGE-PIXELS 3 GRAPHIC-EDGE  NO-FILL   
     SIZE 97.5 BY 4.17.

DEFINE RECTANGLE RECT-9
     EDGE-PIXELS 3 GRAPHIC-EDGE  NO-FILL   
     SIZE 97.5 BY 12.46
     BGCOLOR 0 FGCOLOR 0 .

DEFINE VARIABLE is-alc AS LOGICAL INITIAL no 
     LABEL "Алкогольная продукция" 
     VIEW-AS TOGGLE-BOX
     SIZE 36 BY .83 NO-UNDO.

DEFINE VARIABLE is-alc-mark AS LOGICAL INITIAL no 
     LABEL "требует маркировки" 
     VIEW-AS TOGGLE-BOX
     SIZE 36 BY .83 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME DLGOKCAN
     b-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     b-help AT ROW 1 COL 95
     G-Name AT ROW 2.46 COL 20 COLON-ALIGNED
     P-Name AT ROW 3.5 COL 20 COLON-ALIGNED
     P-Address AT ROW 4.5 COL 20 COLON-ALIGNED
     TNVED AT ROW 6.5 COL 14.5 COLON-ALIGNED
     tnved-name AT ROW 6.54 COL 31.75 COLON-ALIGNED NO-LABEL
     r-tnved AT ROW 6.63 COL 28.63
     UNIT-CST AT ROW 7.92 COL 17.25 COLON-ALIGNED
     CST-BASE-RATE AT ROW 7.96 COL 42.88 COLON-ALIGNED
     g-unit-base AT ROW 7.96 COL 70.38 COLON-ALIGNED
     r-cst AT ROW 8.04 COL 28.63
     NATIONALITY AT ROW 9.5 COL 36.5 COLON-ALIGNED
     Destin AT ROW 11.42 COL 15.38 COLON-ALIGNED
     Attrib AT ROW 12.67 COL 18 COLON-ALIGNED
     UserRule AT ROW 13.92 COL 19.75 COLON-ALIGNED
     Sert AT ROW 15.17 COL 16.5 COLON-ALIGNED
     Struct AT ROW 16.46 COL 13 NO-LABEL WIDGET-ID 2
     DeadLine AT ROW 19.92 COL 39 COLON-ALIGNED
     Sort AT ROW 19.92 COL 63.38 COLON-ALIGNED
     normal-wastage AT ROW 21.13 COL 22.88 COLON-ALIGNED
     normal-waste AT ROW 21.13 COL 50.13 COLON-ALIGNED
     cond-keep-code AT ROW 22.25 COL 19 COLON-ALIGNED
     r-cnd-keep AT ROW 22.25 COL 27
     proof AT ROW 24.71 COL 87.5 COLON-ALIGNED WIDGET-ID 6
     is-alc AT ROW 24.83 COL 6 WIDGET-ID 12
     is-alc-mark AT ROW 24.83 COL 42.5 WIDGET-ID 16
     r-choose-alc-prod AT ROW 26.08 COL 46.38
     choose-alc-prod AT ROW 26.17 COL 34 COLON-ALIGNED
     struct-length AT ROW 15.42 COL 90 COLON-ALIGNED WIDGET-ID 8
     l-struct AT ROW 16.5 COL 2.5 NO-LABEL WIDGET-ID 4
     cond-keep-name AT ROW 22.25 COL 30 COLON-ALIGNED NO-LABEL
     choose-alc-prod-name AT ROW 26.25 COL 49 COLON-ALIGNED NO-LABEL WIDGET-ID 14
     "(Комплектность)" VIEW-AS TEXT
          SIZE 11 BY 1 AT ROW 17.5 COL 2
          FONT 4
     "Атрибуты алкогольной продукции" VIEW-AS TEXT
          SIZE 30.75 BY .71 AT ROW 23.54 COL 27 WIDGET-ID 12
     "Таможенные характеристики" VIEW-AS TEXT
          SIZE 25.75 BY .71 AT ROW 5.79 COL 27
          BGCOLOR 3 FGCOLOR 14 
     "Таможенные характеристики" VIEW-AS TEXT
          SIZE 25.75 BY .71 AT ROW 5.79 COL 27 WIDGET-ID 12
          BGCOLOR 3 FGCOLOR 14 
     RECT-10 AT ROW 2.21 COL 1.5
     RECT-11 AT ROW 6 COL 1.5
     RECT-9 AT ROW 11 COL 1.5
     RECT-12 AT ROW 23.83 COL 1.5 WIDGET-ID 10
     SPACE(0.12) SKIP(0.99)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS THREE-D  SCROLLABLE 
         BGCOLOR 8 FGCOLOR 0 
         TITLE BGCOLOR 8 FGCOLOR 1 "Доп.инфо по карточке товара":L
         DEFAULT-BUTTON b-exit CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Temp-Tables and Buffers:
      TABLE: X_condition-keeping B "?" ? ub condition-keeping
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX DLGOKCAN
   FRAME-NAME UNDERLINE                                                 */
ASSIGN 
       FRAME DLGOKCAN:SCROLLABLE       = FALSE.

/* SETTINGS FOR FILL-IN choose-alc-prod-name IN FRAME DLGOKCAN
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN cond-keep-name IN FRAME DLGOKCAN
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN l-struct IN FRAME DLGOKCAN
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN proof IN FRAME DLGOKCAN
   NO-ENABLE                                                            */
ASSIGN 
       proof:HIDDEN IN FRAME DLGOKCAN           = TRUE.
/* SETTINGS FOR RECTANGLE RECT-10 IN FRAME DLGOKCAN
   NO-ENABLE                                                            */
/* SETTINGS FOR RECTANGLE RECT-12 IN FRAME DLGOKCAN
   NO-ENABLE                                                            */
/* SETTINGS FOR RECTANGLE RECT-9 IN FRAME DLGOKCAN
   NO-ENABLE                                                            */
ASSIGN 
       Struct:RETURN-INSERTED IN FRAME DLGOKCAN  = TRUE.

/* SETTINGS FOR FILL-IN tnved-name IN FRAME DLGOKCAN
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit DLGOKCAN
ON CHOOSE OF b-exit IN FRAME DLGOKCAN /* Ввод */
DO:
define variable loc#log as log no-undo .

    if mode <> {&lookup} THEN do:

  ASSIGN
  Struct_ = Struct:screen-value
  .
  if is-alc = true and (choose-alc-prod-name = ? or choose-alc-prod-name = "") then do:
     message 
     "Не выбран вид алкогольной продукции"
     VIEW-AS ALERT-BOX .
     RETURN NO-APPLY. 
  end.   
assign
Destin    Attrib    UserRule    Sert        /* ProdDate */   DeadLine    Sort    Proof
TNVED UNIT-CST CST-BASE-RATE NATIONALITY normal-wastage normal-waste cond-keep-code.
  if is-alc = true and proof = 0 then do:
     message 
     "Не указан % содержания алкоголя"
     VIEW-AS ALERT-BOX .
     RETURN NO-APPLY. 
  end.  
assign
  destin_ = Destin
  attrib_ = Attrib
  user-rule_ = UserRule
  sert_ = Sert

  deadline_ = DeadLine
  sort_ = Sort
  proof_ = Proof
  tnved_ = TNVED
  unit-cst_ = UNIT-CST
  cst-base-rate_ = CST-BASE-RATE
  nationality_ = NATIONALITY
  normal-waste_ = normal-waste
  cond-keep-code_ = cond-keep-code
  is-alc_ = is-alc
  is-alc-mark_ = is-alc-mark
  .
  if normal-wastage <> normal-wastage_ then do:
    assign
    normal-wastage_ = normal-wastage
    .
  end.
end.
else
    return "отказ" .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-quit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-quit DLGOKCAN
ON CHOOSE OF b-quit IN FRAME DLGOKCAN /* Отмена */
DO:
    return "отказ" .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME choose-alc-prod
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL choose-alc-prod DLGOKCAN
ON LEAVE OF choose-alc-prod IN FRAME DLGOKCAN /* Выбор вида алкогольной продукции */
DO:
  FIND FIRST ub.alc-type WHERE ub.alc-type.alc-type-code = choose-alc-prod:SCREEN-VALUE NO-LOCK NO-error.
    if not available ub.alc-type then do:
            ASSIGN 
                choose-alc-prod = ?
                choose-alc-prod:SCREEN-VALUE = ?.
    end.
            
    else do:
        DISPLAY ub.alc-type.alc-type-code @ choose-alc-prod with frame {&frame-name}.
        DISPLAY ub.alc-type.alc-type-name @ choose-alc-prod-name with frame {&frame-name}.
    end.         
         assign 
         choose-alc-prod
         choose-alc-prod-name
         alc-type-inner-code = ub.alc-type.alc-type-inner-code 
         .
end.




/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME cond-keep-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL cond-keep-code DLGOKCAN
ON LEAVE OF cond-keep-code IN FRAME DLGOKCAN /* Код усл. хран. */
DO:
    RUN proc-leave-cond-keep-code IN THIS-PROCEDURE (INPUT LASTKEY) NO-ERROR.
    IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME CST-BASE-RATE
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL CST-BASE-RATE DLGOKCAN
ON RETURN OF CST-BASE-RATE IN FRAME DLGOKCAN /* Коэффициент */
DO:
    RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME is-alc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL is-alc DLGOKCAN
ON VALUE-CHANGED OF is-alc IN FRAME DLGOKCAN /* Алкогольная продукция */
DO:
  IF is-alc:checked and alcvalue = "yes" then do:
  if mode <> {&lookup} and alcvalue = "yes" then
  enable is-alc-mark
         choose-alc-prod
         r-choose-alc-prod
         proof
         choose-alc-prod-name
         with frame {&frame-name}   
  .
  else
  display choose-alc-prod
          r-choose-alc-prod
          is-alc-mark
          proof
          choose-alc-prod-name
          with frame {&frame-name}
          .
  end.
  else hide
         choose-alc-prod
         r-choose-alc-prod
         is-alc-mark
         proof
         choose-alc-prod-name
         in frame {&frame-name} 
  .
  assign is-alc.      
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME is-alc-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL is-alc-mark DLGOKCAN
ON VALUE-CHANGED OF is-alc-mark IN FRAME DLGOKCAN /* требует маркировки */
DO:
  assign is-alc-mark.      
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME normal-wastage
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL normal-wastage DLGOKCAN
ON ENTRY OF normal-wastage IN FRAME DLGOKCAN /* Норма ест. убыли */
DO:
  assign
  normal-wastage:private-data = normal-wastage:screen-value.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME r-choose-alc-prod
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL r-choose-alc-prod DLGOKCAN
ON CHOOSE OF r-choose-alc-prod IN FRAME DLGOKCAN
DO:
  run ch-choose-alc-prod in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME r-cnd-keep
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL r-cnd-keep DLGOKCAN
ON CHOOSE OF r-cnd-keep IN FRAME DLGOKCAN
do:
  RUN proc-b-cond-keep-code IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME r-cst
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL r-cst DLGOKCAN
ON CHOOSE OF r-cst IN FRAME DLGOKCAN /* r-cst */
do:
    run ch-units in this-procedure .
    apply "entry" to UNIT-CST in frame {&frame-name}.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME r-tnved
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL r-tnved DLGOKCAN
ON CHOOSE OF r-tnved IN FRAME DLGOKCAN /* r-tnved */
DO:
  run ch-tnved in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Struct
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Struct DLGOKCAN
ON VALUE-CHANGED OF Struct IN FRAME DLGOKCAN
DO:
   ASSIGN
  STRUCT-LENGTH = STRUCT:LENGTH.
  DISPLAY STRUCT-LENGTH
  WITH FRAME {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME struct-length
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL struct-length DLGOKCAN
ON ANY-PRINTABLE OF struct-length IN FRAME DLGOKCAN /* Символов */
DO:
  ASSIGN
  struct-length = struct:LENGTH.
  DISPLAY
  struct-length
  WITH FRAME {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME TNVED
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL TNVED DLGOKCAN
ON RETURN OF TNVED IN FRAME DLGOKCAN /* Код ТНВЭД */
DO:
  FIND FIRST TT-tnved WHERE TT-tnved.tnved = input frame {&frame-name} tnved no-error.
  if not available TT-tnved then do:
    message "Код ТНВЭД не найден в справочнике." view-as alert-box error.
    display ? @ tnved with frame {&frame-name}.
    run ch-tnved in this-procedure .
    return no-apply.
  end.
  else
  if length(trim(input frame {&frame-name} tnved)) <> 10 then do:
     message "Код ТНВЭД привязки к товару должен быть 10-ти символьный." view-as alert-box error.
     display ? @ tnved with frame {&frame-name}.
     run ch-tnved in this-procedure .
     return no-apply.
   end.
  else
  display TT-tnved.f-name @ tnved-name with frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME UNIT-CST
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL UNIT-CST DLGOKCAN
ON RETURN OF UNIT-CST IN FRAME DLGOKCAN /* Тамож.ед.изм */
DO:
    if not can-FIND( ub.units where ub.units.unit-name = input frame {&frame-name} UNIT-CST )
       then do:
       UNIT-CST = "?".
       DISPLAY UNIT-CST WITH FRAME {&Frame-name}.
       run ch-units in this-procedure .
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK DLGOKCAN 


IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

{ gbl/app_help.i }
{ ref/tabhndmv.i  v-tab-order }
{ gbl/rethndmv.i  v-tab-order underline-tb "APPLY 'CHOOSE' TO b-exit in frame {&frame-name}." }


/* Add Trigger to equate WINDOW-CLOSE to END-ERROR                      */
ON WINDOW-CLOSE OF FRAME {&FRAME-NAME} APPLY "END-ERROR":U TO SELF.
assign
G-Name = goodsname
P-Name = prodname
P-Address = prodaddress
g-unit-base = (IF goods-unit-base = "" THEN "?" ELSE goods-unit-base)
Destin = destin_
Attrib = attrib_
UserRule = user-rule_
Sert = sert_
Struct:SCREEN-VALUE = struct_
TNVED = tnved_
/*
ProdDate = prod-date_
*/
DeadLine = deadline_
Sort = sort_
Proof = Proof_
UNIT-CST = unit-cst_
CST-BASE-RATE = cst-base-rate_
NATIONALITY = nationality_
normal-wastage = normal-wastage_
normal-waste = normal-waste_
cond-keep-code = cond-keep-code_
is-alc = is-alc_
is-alc-mark = is-alc-mark_
.

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
   { gbl/getcntxt.i get }

    RUN enable_UI in this-procedure .
    if mode = {&lookup} then do:
      HIDE
      b-quit in frame {&frame-name} .
      b-exit:label = "Выход " .
    end.

    WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ch-choose-alc-prod DLGOKCAN 
PROCEDURE ch-choose-alc-prod :                      /*вызов справочника вида влкогольной продукции*/
define variable v-rec as char no-undo .
define variable v-ok  as logical no-undo .

run ref/alc-type.w (
          input parparentproc
          , input 'b-sel':U /*bttns*/
          , input-output v-rec
          , output v-ok ).
   
if v-rec = ? then  do:
  apply "entry" to r-choose-alc-prod in frame {&frame-name}.
  return error.
end.
FIND ub.alc-type WHERE recid (alc-type) = int(v-rec) no-error.
if available ub.alc-type then do:
    DISPLAY ub.alc-type.alc-type-code @ choose-alc-prod with frame {&frame-name}.
    DISPLAY ub.alc-type.alc-type-name @ choose-alc-prod-name with frame {&frame-name}.
    assign 
        choose-alc-prod
        choose-alc-prod-name
        alc-type-inner-code = ub.alc-type.alc-type-inner-code 
        
    .
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ch-tnved DLGOKCAN 
PROCEDURE ch-tnved :
run ref/t-tnved.w (yes, output rid-tnved).
find first tt-tnved where RECID(tt-tnved) = rid-tnved no-lock no-error.
if available tt-tnved then disp tt-tnved.tnved @ tnved
                                tt-tnved.f-name @ tnved-name with frame {&frame-name}.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ch-units DLGOKCAN 
PROCEDURE ch-units :
define variable v-rec as recid no-undo .
run ref/units.w (
            input parparentproc
          , input yes
          , output v-rec ).
if v-rec = ? then  do:
  apply "entry" to r-cst in frame {&frame-name}.
  return error.
end.
FIND ub.units WHERE recid (ub.units) = v-rec NO-LOCK.
DISPLAY ub.units.unit-name @ UNIT-CST with frame {&frame-name}.
if input frame {&frame-name} UNIT-CST = g-unit-base then  do:
  DISPLAY 1 @ CST-BASE-RATE with frame {&frame-name}.
  DISABLE CST-BASE-RATE with frame {&frame-name}.
end.
else do:
  ENABLE CST-BASE-RATE with frame {&frame-name}.
end.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI DLGOKCAN  _DEFAULT-DISABLE
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
  HIDE FRAME DLGOKCAN.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI DLGOKCAN 
PROCEDURE enable_UI :
define variable v-scales-type as character no-undo .
define variable v-ii as integer no-undo .
v-tab-order = 'b-ezit,b-quit,b-help,g-name,p-name,p-address,tnved,r-tnved,tnved-name,unit-cst,' +
               'r-cst,cst-base-rate,nationality,destin,attrib,userrule,sert,struct,' +
               'deadline,sort,is-alc,proof,is-alc-mark,choose-alc-prod,normal-wastage,normal-waste,cond-keep-code,r-cnd-keep'.

IF goods-unit-base <> '':U THEN DO:
  FIND FIRST buf_units NO-LOCK WHERE
            buf_units.unit-name = goods-unit-base NO-ERROR.
END.
ASSIGN
struct = struct_
.
DISPLAY
TNVED UNIT-CST CST-BASE-RATE r-cst g-unit-base
Destin Attrib UserRule Sert l-struct Struct /* ProdDate */ DeadLine Sort Proof
UNIT-CST CST-BASE-RATE TNVED
G-Name P-Name P-Address NATIONALITY normal-wastage normal-waste cond-keep-code is-alc is-alc-mark choose-alc-prod
WITH FRAME {&frame-name} .
{ gbl/conf-rd.i
"'is-custm'"
0
"''"
0
"''"
"''"
"''"
no
custvalue
custtype
no-error
}
if custvalue = "yes" and
 can-find(first tt-tnved where tt-tnved.tnved = input frame dlgokcan tnved no-lock) then do:
 find first tt-tnved where tt-tnved.tnved = input frame dlgokcan tnved no-lock.
 display tt-tnved.f-name @ tnved-name with frame dlgokcan.
end.
IF cond-keep-code <> 0
AND cond-keep-code <> ?
THEN DO:
  FIND FIRST X_condition-keeping NO-LOCK WHERE
            X_condition-keeping.cond-keep-code = cond-keep-code NO-ERROR.
  IF AVAILABLE X_condition-keeping THEN DO:
      ASSIGN
      cond-keep-name = X_condition-keeping.cond-keep-name
      .
      DISPLAY
      cond-keep-name
      WITH FRAME {&FRAME-NAME}.
  END.
END.
{ gbl/conf-rd.i
"'alcohol'"
0
"''"
0
"''"
"''"
"''"
no
alcvalue
alctype
no-error
}

if alcvalue = "yes" then do:
  display is-alc with frame {&FRAME-NAME}.
end.

if choose-alc-prod >= 0 and choose-alc-prod <> ? then do:
  find first ub.alc-type no-lock where ub.alc-type.alc-type-inner-code = alc-type-inner-code no-error.
  if available ub.alc-type then do:
    assign 
        choose-alc-prod = integer(ub.alc-type.alc-type-code)
        choose-alc-prod-name = ub.alc-type.alc-type-name
        .
        
    DISPLAY 
    choose-alc-prod
    choose-alc-prod-name with frame {&frame-name}.
    
  end. 
end.

ENABLE
TNVED when mode <> {&lookup} and custvalue = "yes"
CST-BASE-RATE when mode <> {&lookup} and custvalue = "yes"
UNIT-CST when mode <> {&lookup} and custvalue = "yes"
r-cst when mode <> {&lookup} and custvalue = "yes"
r-tnved when mode <> {&lookup} and custvalue = "yes"
Destin when mode <> {&lookup}
Attrib when mode <> {&lookup}
UserRule when mode <> {&lookup}
Sert when mode <> {&lookup}
Struct
r-cnd-keep when mode <> {&lookup}
cond-keep-code WHEN mode <> {&LOOKUP}
is-alc WHEN mode <> {&LOOKUP} and alcvalue = "yes"
is-alc-mark WHEN mode <> {&LOOKUP} and alcvalue = "yes"
choose-alc-prod when mode <> {&LOOKUP} and alcvalue = "yes"
/*
ProdDate when mode <> {&lookup}
*/
DeadLine when mode <> {&lookup}
Sort when mode <> {&lookup}
Proof when mode <> {&lookup}
Nationality when mode <> {&lookup}  and custvalue = "yes"
normal-wastage when mode <> {&lookup}
normal-waste when mode <> {&lookup}
b-help b-exit b-quit
WITH FRAME {&frame-name} .
apply "VALUE-CHANGED":U to is-alc.
IF mode = {&LOOKUP} THEN DO:
  struct:READ-ONLY IN FRAME {&FRAME-NAME} = YES.
END.
{&OPEN-BROWSERS-IN-QUERY-DLGOKCAN}
APPLY "VALUE-CHANGED" TO STRUCT.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-cond-keep-code DLGOKCAN 
PROCEDURE proc-b-cond-keep-code :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable v-rid-list as character no-undo.
define variable v-sts as integer no-undo.
define variable v-cond-keep-code like ub.condition-keeping.cond-keep-code no-undo.
DEFINE BUFFER buf_condition-keeping FOR ub.condition-keeping.
{ gbl/stdbtn.i }
assign
v-cond-keep-code = FRAME {&FRAME-NAME} cond-keep-code
cond-keep-code
v-sts = INTEGER({&current-status-int})
    .
IF available X_condition-keeping THEN v-rid-list = string(RECID(X_condition-keeping)) .
run ref/cndkeeps.w (
                INPUT parParentProc
               ,input p-curr-obj-type
               ,input p-curr-obj-code
               ,input "b-sel":U /* bttns*/
               ,input {&all}
               ,input-output v-sts
               ,input-output v-rid-list).

    if v-rid-list <> "":U then do:
        FIND FIRST buf_condition-keeping WHERE
             recid( buf_condition-keeping ) = integer(v-rid-list) NO-LOCK .
        FIND FIRST X_condition-keeping WHERE
        RECID(X_condition-keeping) = RECID(buf_condition-keeping).
        assign
        cond-keep-code = buf_condition-keeping.cond-keep-code
        cond-keep-name = buf_condition-keeping.cond-keep-name
               .
        DISPLAY
        cond-keep-code
        cond-keep-name
        with frame {&frame-name} .
        RETURN.
    end.
    IF v-cond-keep-code = ? THEN DO:
       ASSIGN
       cond-keep-code = v-cond-keep-code
       cond-keep-name = "":U
       .
       RELEASE X_condition-keeping.
       DISPLAY
       cond-keep-code
       cond-keep-name
       with frame {&frame-name} .
    END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-leave-cond-keep-code DLGOKCAN 
PROCEDURE proc-leave-cond-keep-code :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DEFINE INPUT PARAMETER p-lastkey AS integer NO-UNDO.
{ gbl/stdbtn.i }
define variable v-cond-keep-code like ub.condition-keeping.cond-keep-code no-undo.
DEFINE BUFFER buf_condition-keeping FOR ub.condition-keeping.

ASSIGN
v-cond-keep-code = FRAME {&frame-name} cond-keep-code
cond-keep-code.
FIND FIRST buf_condition-keeping WHERE
 buf_condition-keeping.cond-keep-code = cond-keep-code NO-LOCK NO-error.

if not available buf_condition-keeping then do:
    IF v-cond-keep-code <> ? THEN DO:
        MESSAGE
        "Нет условий хранения с кодом" cond-keep-code
        VIEW-AS ALERT-BOX ERROR.

        IF LASTKEY = KEYCODE("return") THEN DO:
            RUN proc-b-cond-keep-code IN THIS-PROCEDURE NO-error.
            RETURN NO-APPLY.
        END.
        ELSE DO:
            assign
            cond-keep-code = v-cond-keep-code.

        END.
    END.
    ELSE DO:
      IF p-LASTKEY = KEYCODE("return") THEN DO:
            MESSAGE
         "Нет условий хранения с кодом" cond-keep-code
         VIEW-AS ALERT-BOX ERROR.
      END.

    END.
    ASSIGN
    cond-keep-code = ?
    cond-keep-name = "":U
    .
    display
    cond-keep-code
    cond-keep-name
    with frame {&frame-name}.
    IF p-LASTKEY = KEYCODE("return") THEN DO:
      RUN proc-b-cond-keep-code IN THIS-PROCEDURE NO-error.
      IF ERROR-STATUS:ERROR THEN RETURN error.
    END.
end.
else do:
  FIND FIRST X_condition-keeping NO-LOCK WHERE
            recid(X_condition-keeping) = RECID(buf_condition-keeping).
  assign
  cond-keep-name = buf_condition-keeping.cond-keep-name
  .
    display
    cond-keep-name
    cond-keep-code
    with frame {&frame-name}.
    .
END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

