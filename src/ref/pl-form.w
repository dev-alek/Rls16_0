
&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME d-pl-form


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER locked_place FOR place.
DEFINE TEMP-TABLE tt-place NO-UNDO LIKE place.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS d-pl-form 
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Карточка складского места

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-mode        as character no-undo.
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .
define input parameter p-pl-code like ub.clients.obj-code no-undo .
define input-output parameter p-rep-rec     as recid no-undo .
/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Карточка складского места" .
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/library.i }
{ ref/gds-attr.i }
{ str/is-sug.i }
{ cmp/showinf.i }
{ str/placelib.i }

define variable v-tab-order       as CHARACTER no-undo .
define variable v-code            as character no-undo .
define variable v-value           as character no-undo .
define variable v-ok              as logical   no-undo .
define variable ii                as integer   no-undo .
define variable v-rvd-on          as logical   no-undo init no .
define variable v-rvd-off         as logical   no-undo init no .
define variable v-rvd-dnsty-on    as logical   no-undo .
define variable v-rvd-lvl-on      as logical   no-undo .
define variable v-rvd-temp-on     as logical   no-undo .
define variable v-rvd-is-meas-on  as logical   no-undo .
define variable v-rvd-reason-on   as character no-undo .
define variable v-ITSM-num-on     as character no-undo .
define variable v-oper-fio-on     as character no-undo .
define variable v-rvd-reason-off  as character no-undo .
define variable v-ITSM-num-off    as character no-undo .
define variable v-oper-fio-off    as character no-undo .
define variable v-main-mi-old     as integer   no-undo .
define variable v-dnst-mi-old     as integer   no-undo .
define variable v-tmp-mi-old      as integer   no-undo .
define variable v-lvl-mi-old      as integer   no-undo .
define variable is-main           as logical   no-undo .
define variable v-com-vessel-changed as logical no-undo init no .
define variable v-gate-valve-tanks-changed as logical no-undo init no .
define variable v-old-auto-gate-valve as logical no-undo .
define variable v-not-gas-place   as logical no-undo . /* на месте хранения есть товар и это не СУГ, не Метан и не Пропан. Только бензин и дизель */
define variable v-sug-place       as logical no-undo . /* на месте хранения есть товар и это СУГ */

define buffer com_place for ub.place .
define buffer com_place-attr for ub.place-attr .

define buffer osn_sr-izmerenia for sr-izmerenia .
define buffer dnst_sr-izmerenia for sr-izmerenia .
define buffer tmp_sr-izmerenia for sr-izmerenia .
define buffer lvl_sr-izmerenia for sr-izmerenia .
define buffer dop_sr-izmerenia for sr-izmerenia .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME d-pl-form

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS tt-place.loc1 tt-place.loc2 tt-place.loc3 ~
tt-place.loc4 tt-place.pl-name tt-place.is-meas tt-place.issue-year ~
tt-place.start-date tt-place.add-qnty tt-place.max-qnty tt-place.PS 
&Scoped-define ENABLED-TABLES tt-place
&Scoped-define FIRST-ENABLED-TABLE tt-place
&Scoped-Define ENABLED-OBJECTS b-exit b-quit B-hist b-help t-place-virtual ~
rvd-dnstv rvd-lvl rvd-tmp place-type place-locat error-mass place-si ~
r-sr-izm dead-balance water-level place-diameter place-ratio-error dens-prov ~
place-twice-code tt-place.chk-max-qnty t-ponton ponton-mass ponton-height ~
t-com-vessel com-tanks t-gate-valve gate-valve-tanks
&Scoped-Define DISPLAYED-FIELDS tt-place.loc1 tt-place.loc2 tt-place.loc3 ~
tt-place.loc4 tt-place.pl-name tt-place.is-meas tt-place.pl-code ~
tt-place.issue-year tt-place.start-date tt-place.add-qnty tt-place.max-qnty ~
tt-place.PS 
&Scoped-define DISPLAYED-TABLES tt-place
&Scoped-define FIRST-DISPLAYED-TABLE tt-place
&Scoped-Define DISPLAYED-OBJECTS t-place-virtual t-asi-srtif rvd-dnstv ~
rvd-lvl rvd-tmp place-type place-locat error-mass place-si dead-balance water-level ~
place-diameter place-ratio-error dens-prov place-twice-code tt-place.chk-max-qnty ~
t-ponton ponton-mass ponton-height ~
t-com-vessel com-tanks v-is-main t-gate-valve gate-valve-tanks

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-exit AUTO-GO 
     LABEL "&Ввод" 
     SIZE 10 BY 1.

DEFINE BUTTON b-help 
     LABEL "Помо&щь" 
     SIZE 10 BY 1.

DEFINE BUTTON B-hist 
     LABEL "Ис&тория" 
     SIZE 10 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY 
     LABEL "&Отмена" 
     SIZE 10 BY 1.

DEFINE BUTTON r-sr-izm 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "r-sr-izm" 
     SIZE 3 BY .88.
     
DEFINE BUTTON b-mi-dnst 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "b-mi-dnst" 
     SIZE 3 BY .88.
     
DEFINE BUTTON b-mi-tmp 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "b-mi-tmp" 
     SIZE 3 BY .88.
     
DEFINE BUTTON b-mi-lvl 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "b-mi-lvl" 
     SIZE 3 BY .88.
     
DEFINE BUTTON b-com-tanks 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "b-mi-dnst" 
     SIZE 3 BY .88.    
     
DEFINE BUTTON b-gate-valve-tanks 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "b-mi-dnst" 
     SIZE 3 BY .88. 

DEFINE VARIABLE dead-balance AS DECIMAL FORMAT "->>,>>>,>>9.<<<":U INITIAL 0 
     LABEL "Мертвый остаток(л)" 
     VIEW-AS FILL-IN 
     SIZE 11.63 BY 1 NO-UNDO.
     
DEFINE VARIABLE water-level AS integer FORMAT ">>>>>9":U INITIAL 0 
     LABEL "Допустимый уровень воды(мм)" 
     VIEW-AS FILL-IN 
     SIZE 11.63 BY 1 NO-UNDO.

DEFINE VARIABLE dens-prov AS DECIMAL FORMAT "9.9999999999" INITIAL 0 
     LABEL "Плотность при поверке резервуара(г/см3)" 
     VIEW-AS FILL-IN 
     SIZE 18 BY 1 NO-UNDO.

DEFINE VARIABLE error-mass AS DECIMAL FORMAT "9.99":U INITIAL 0.15 
     LABEL "Погр.изм.массы в трубопр. (%)" 
     VIEW-AS FILL-IN 
     SIZE-PIXELS 93 BY 24 NO-UNDO.

DEFINE VARIABLE place-diameter AS DECIMAL FORMAT ">,>>>,>>9":U INITIAL 0 
     LABEL "Диаметр резервуара(мм)" 
     VIEW-AS FILL-IN 
     SIZE 11.63 BY 1 NO-UNDO.

DEFINE VARIABLE place-ratio-error AS DECIMAL FORMAT "9.99":U INITIAL 0.25 
     LABEL "Относительная погрешность составления калибровочной таблицы" 
     VIEW-AS FILL-IN 
     SIZE 18 BY 1 NO-UNDO.
     
DEFINE VARIABLE place-temp-coef AS DECIMAL FORMAT "9.9999999999":U INITIAL 0.0000125 
     LABEL "Темп. коэф. линейного расширения материала стенки рез-ра(1/°С)" 
     VIEW-AS FILL-IN 
     SIZE 18 BY 1 NO-UNDO.
     
DEFINE VARIABLE place-dead-high AS DECIMAL FORMAT ">,>>>,>>9":U INITIAL 0 
     LABEL "Высота мертвой полости(мм)" 
     VIEW-AS FILL-IN 
     SIZE 11.63 BY 1 NO-UNDO.

DEFINE VARIABLE place-si AS INTEGER FORMAT ">>>>>9":U INITIAL 0 
     LABEL "Основное средство измерения" 
     VIEW-AS FILL-IN 
     SIZE 11 BY 1 NO-UNDO.
     
DEFINE VARIABLE v-mi-dnst AS INTEGER FORMAT ">>>>>9":U INITIAL 0 
     LABEL "" 
     VIEW-AS FILL-IN 
     SIZE 11 BY 1 NO-UNDO.
     
DEFINE VARIABLE v-mi-tmp AS INTEGER FORMAT ">>>>>9":U INITIAL 0 
     LABEL "" 
     VIEW-AS FILL-IN 
     SIZE 11 BY 1 NO-UNDO.
     
DEFINE VARIABLE v-mi-lvl AS INTEGER FORMAT ">>>>>9":U INITIAL 0 
     LABEL "" 
     VIEW-AS FILL-IN 
     SIZE 11 BY 1 NO-UNDO.

DEFINE VARIABLE place-si-name AS character FORMAT "X(10)":U
     LABEL "Основное средство измерения" 
     VIEW-AS FILL-IN 
     SIZE 11 BY 1 NO-UNDO.
     
DEFINE VARIABLE v-mi-lvl-name AS character FORMAT "X(10)":U
     LABEL "" 
     VIEW-AS FILL-IN 
     SIZE 11 BY 1 NO-UNDO.
     
DEFINE VARIABLE v-mi-dnst-name AS character FORMAT "X(10)":U
     LABEL "" 
     VIEW-AS FILL-IN 
     SIZE 11 BY 1 NO-UNDO.
     
DEFINE VARIABLE v-mi-tmp-name AS character FORMAT "X(10)":U
     LABEL "" 
     VIEW-AS FILL-IN 
     SIZE 11 BY 1 NO-UNDO.

DEFINE VARIABLE place-twice-code AS CHARACTER FORMAT "x(8)" 
     LABEL "Коды связанных резервуаров" 
     VIEW-AS FILL-IN 
     SIZE 18 BY 1 NO-UNDO.
     
DEFINE VARIABLE place-passp-num AS CHARACTER FORMAT "x(256)" 
     LABEL "Номер резервуара по паспорту" 
     VIEW-AS FILL-IN 
     SIZE 45 BY 1 NO-UNDO.

DEFINE VARIABLE place-passp-type AS CHARACTER FORMAT "x(256)" 
     LABEL "Тип резервуара по паспорту" 
     VIEW-AS FILL-IN 
     SIZE 45 BY 1 NO-UNDO.

DEFINE VARIABLE place-locat AS INTEGER INITIAL 2 
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS 
          "Наземный", 1,
"Подземный", 2
     SIZE 25.5 BY .92 NO-UNDO.

DEFINE VARIABLE place-type AS INTEGER initial 2
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS 
          "Вертикальный", 1,
"Горизонтальный", 2
     SIZE 34.5 BY .92 NO-UNDO.

DEFINE VARIABLE rvd-dnstv AS LOGICAL INITIAL no 
     LABEL "Плотность" 
     VIEW-AS TOGGLE-BOX
     SIZE 11.13 BY 1 NO-UNDO.

DEFINE VARIABLE rvd-lvl AS LOGICAL INITIAL no 
     LABEL "Уровень" 
     VIEW-AS TOGGLE-BOX
     SIZE 11.13 BY 1 NO-UNDO.

DEFINE VARIABLE rvd-tmp AS LOGICAL INITIAL no 
     LABEL "Температура" 
     VIEW-AS TOGGLE-BOX
     SIZE 13.5 BY 1 NO-UNDO.

DEFINE VARIABLE t-asi-srtif AS LOGICAL INITIAL no 
     LABEL "АСИ сертифицировано" 
     VIEW-AS TOGGLE-BOX
     SIZE 22.13 BY 1 NO-UNDO.

DEFINE VARIABLE t-place-virtual AS LOGICAL INITIAL no 
     LABEL "Виртуальный резервуар" 
     VIEW-AS TOGGLE-BOX
     SIZE 27 BY 1 NO-UNDO.
     
DEFINE VARIABLE t-ponton AS LOGICAL INITIAL no 
     LABEL "Понтон:" 
     VIEW-AS TOGGLE-BOX
     SIZE 15 BY 1 NO-UNDO.     

DEFINE VARIABLE ponton-mass AS DECIMAL FORMAT ">>>>>>9.999":U INITIAL ? decimals 3
     LABEL "Масса понтона(кг)" 
     VIEW-AS FILL-IN 
     SIZE 12 BY 1 NO-UNDO.
     
DEFINE VARIABLE ponton-height AS DECIMAL FORMAT ">>>>>>9.9":U INITIAL ? decimals 1
     LABEL "Высота всплытия(мм)" 
     VIEW-AS FILL-IN 
     SIZE 12 BY 1 NO-UNDO.
     
DEFINE VARIABLE t-com-vessel AS LOGICAL INITIAL no 
     LABEL "Сообщающиеся резервуары:" 
     VIEW-AS TOGGLE-BOX
     SIZE 30 BY 1 NO-UNDO.
     
DEFINE VARIABLE t-gate-valve AS LOGICAL INITIAL no 
     LABEL "Задвижка:" 
     VIEW-AS TOGGLE-BOX
     SIZE 15 BY 1 NO-UNDO.
     
DEFINE VARIABLE com-tanks AS CHARACTER FORMAT "x(15)" 
     LABEL "" 
     VIEW-AS FILL-IN 
     SIZE 15 BY 1 NO-UNDO.       
     
DEFINE VARIABLE gate-valve-tanks AS CHARACTER FORMAT "x(15)" 
     LABEL "" 
     VIEW-AS FILL-IN 
     SIZE 15 BY 1 NO-UNDO.   
     
DEFINE VARIABLE v-is-main AS character FORMAT "x(11)" 
     LABEL "" 
     VIEW-AS fill-in
     SIZE 11 BY 1 NO-UNDO.      

DEFINE VARIABLE t-auto-gate-valve AS LOGICAL INITIAL no 
     LABEL "Автоматическая задвижка" 
     VIEW-AS TOGGLE-BOX
     SIZE 25 BY 1 NO-UNDO.

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME d-pl-form
     b-exit AT ROW 1 COL 2
     b-quit AT ROW 1 COL 12
     B-hist AT ROW 1 COL 66.63
     b-help AT ROW 1 COL 76.63
     tt-place.loc1 AT ROW 3 COL 10 COLON-ALIGNED
          LABEL "Коорд&1"
          VIEW-AS FILL-IN 
          SIZE 11.63 BY 1
     tt-place.loc2 AT ROW 3 COL 30.63 COLON-ALIGNED
          LABEL "Коорд&2"
          VIEW-AS FILL-IN 
          SIZE 11.63 BY 1
     tt-place.loc3 AT ROW 3 COL 52.5 COLON-ALIGNED
          LABEL "Коорд&3"
          VIEW-AS FILL-IN 
          SIZE 11.63 BY 1
     tt-place.loc4 AT ROW 3 COL 88.01 RIGHT-ALIGNED
          LABEL "Коорд&4"
          VIEW-AS FILL-IN 
          SIZE 11.63 BY 1
     tt-place.pl-name AT ROW 4.25 COL 10 COLON-ALIGNED
          LABEL "Название"
          VIEW-AS FILL-IN 
          SIZE 77 BY 1
     t-place-virtual AT ROW 5.46 COL 35.5 WIDGET-ID 28
     t-asi-srtif AT ROW 5.46 COL 66.88 WIDGET-ID 22
     tt-place.is-meas AT ROW 5.5 COL 10
          LABEL "Измеряется приборами"
          VIEW-AS TOGGLE-BOX
          SIZE 23.63 BY 1
     tt-place.pl-code AT ROW 6.75 COL 5.63 COLON-ALIGNED format "99999999999"
          LABEL "Код"
          VIEW-AS FILL-IN 
          SIZE 12.93 BY 1
     rvd-dnstv AT ROW 6.75 COL 35 WIDGET-ID 40
     rvd-lvl AT ROW 6.75 COL 52 WIDGET-ID 44
     rvd-tmp AT ROW 6.75 COL 68 WIDGET-ID 46
     "Доп. средства измерения:" VIEW-AS TEXT
          SIZE 24 BY .75 AT ROW 7.7 COL 7 WIDGET-ID 50
     v-mi-dnst AT ROW 7.7 COL 33 COLON-ALIGNED WIDGET-ID 52 no-label
     v-mi-dnst-name AT ROW 7.7 COL 33 COLON-ALIGNED WIDGET-ID 52 no-label
     b-mi-dnst AT ROW 7.7 COL 48 RIGHT-ALIGNED
     v-mi-lvl AT ROW 7.7 COL 50 COLON-ALIGNED WIDGET-ID 52 no-label
     v-mi-lvl-name AT ROW 7.7 COL 50 COLON-ALIGNED WIDGET-ID 52 no-label
     b-mi-lvl AT ROW 7.7 COL 65 RIGHT-ALIGNED
     v-mi-tmp AT ROW 7.7 COL 66 COLON-ALIGNED WIDGET-ID 52 no-label
     v-mi-tmp-name AT ROW 7.7 COL 66 COLON-ALIGNED WIDGET-ID 52 no-label
     b-mi-tmp AT ROW 7.7 COL 81 RIGHT-ALIGNED
     tt-place.issue-year AT ROW 8.71 COL 21.63 COLON-ALIGNED
          LABEL "Год выпуска"
          VIEW-AS FILL-IN 
          SIZE 11.63 BY 1
     place-type AT ROW 8.71 COL 88 RIGHT-ALIGNED NO-LABEL WIDGET-ID 8
     tt-place.start-date AT ROW 9.71 COL 21.63 COLON-ALIGNED
          LABEL "Ввод в эксплуатацию"
          VIEW-AS FILL-IN 
          SIZE 11.63 BY 1
     place-locat AT ROW 9.71 COL 88 RIGHT-ALIGNED NO-LABEL WIDGET-ID 30
     t-ponton at row 10.81 col 2
     ponton-mass at row 10.81 col 18
     ponton-height  at row 10.81 col 50
     tt-place.add-qnty AT ROW 11.92 COL 30.63 COLON-ALIGNED
          LABEL "Объем трубопровода(л)"
          VIEW-AS FILL-IN 
          SIZE 11.63 BY 1
     error-mass AT ROW 11.92 COL 75.38 COLON-ALIGNED WIDGET-ID 38
     tt-place.max-qnty AT ROW 12.92 COL 30.63 COLON-ALIGNED
          LABEL "Макс. кол-во в резервуаре(л)"
          VIEW-AS FILL-IN 
          SIZE 11.63 BY 1
     place-si AT ROW 12.92 COL 75.38 COLON-ALIGNED WIDGET-ID 16
     r-sr-izm AT ROW 12.92 COL 90 RIGHT-ALIGNED
     place-si-name AT ROW 12.92 COL 75.38 COLON-ALIGNED
     dead-balance AT ROW 13.92 COL 30.63 COLON-ALIGNED WIDGET-ID 18
     water-level AT ROW 14.92 COL 30.63 COLON-ALIGNED WIDGET-ID 58
     place-diameter AT ROW 13.92 COL 75.38 COLON-ALIGNED WIDGET-ID 18
     place-dead-high at row 15.25 COL 88 RIGHT-ALIGNED
     place-temp-coef at row 16.25 COL 88 RIGHT-ALIGNED
/*     place-ratio-error AT ROW 17.25 COL 88 RIGHT-ALIGNED WIDGET-ID 20*/
     dens-prov AT ROW 17.25 COL 88 RIGHT-ALIGNED
     t-auto-gate-valve at row 18.25 col 3
     place-twice-code AT ROW 18.25 COL 88 RIGHT-ALIGNED WIDGET-ID 24
     t-com-vessel at row 19.25 col 20
     com-tanks at row 19.25 col 65 no-label
     b-com-tanks at row 19.25 col 85
     v-is-main at row 19.25 col 5 no-label
     t-gate-valve at row 20.25 col 20
     gate-valve-tanks at row 20.25 col 65 no-label
     b-gate-valve-tanks at row 20.25 col 85
     place-passp-num at row 21.5 col 88 right-aligned
     place-passp-type at row 22.5 col 88 right-aligned
     tt-place.chk-max-qnty AT ROW 24 COL 3 WIDGET-ID 2
          LABEL "Проверять макс. допустимое кол-во товара на месте хранения" 
          VIEW-AS TOGGLE-BOX
          SIZE 62.63 BY .83 
     tt-place.PS AT ROW 25 COL 2 NO-LABEL
          VIEW-AS EDITOR SCROLLBAR-VERTICAL
          SIZE 87 BY 4
     "Тип резервуара:" VIEW-AS TEXT
          SIZE 15.63 BY .75 AT ROW 8.71 COL 37 WIDGET-ID 12
     "РВД:" VIEW-AS TEXT
          SIZE 8 BY 1 AT ROW 6.75 COL 27 WIDGET-ID 42
     "Расположение резервуара:" VIEW-AS TEXT
          SIZE 24.75 BY .92 AT ROW 9.75 COL 37 WIDGET-ID 34
     SPACE(30.12) SKIP(16.65)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Складское место".


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Temp-Tables and Buffers:
      TABLE: locked_place B "?" ? ub place
      TABLE: tt-place T "?" NO-UNDO ub place
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX d-pl-form
   FRAME-NAME                                                           */
ASSIGN 
       FRAME d-pl-form:SCROLLABLE       = FALSE.

/* SETTINGS FOR FILL-IN tt-place.add-qnty IN FRAME d-pl-form
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN dens-prov IN FRAME d-pl-form
   ALIGN-R                                                              */
/* SETTINGS FOR FILL-IN error-mass IN FRAME d-pl-form
   ALIGN-R                                                              */
/* SETTINGS FOR TOGGLE-BOX tt-place.is-meas IN FRAME d-pl-form
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-place.issue-year IN FRAME d-pl-form
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-place.loc1 IN FRAME d-pl-form
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-place.loc2 IN FRAME d-pl-form
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-place.loc3 IN FRAME d-pl-form
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-place.loc4 IN FRAME d-pl-form
   ALIGN-R EXP-LABEL                                                    */
/* SETTINGS FOR FILL-IN tt-place.max-qnty IN FRAME d-pl-form
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-place.pl-code IN FRAME d-pl-form
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN tt-place.pl-name IN FRAME d-pl-form
   EXP-LABEL                                                            */
/* SETTINGS FOR RADIO-SET place-locat IN FRAME d-pl-form
   ALIGN-R                                                              */
/* SETTINGS FOR FILL-IN place-ratio-error IN FRAME d-pl-form
   ALIGN-R                                                              */
/*ASSIGN                                                              */
/*       place-ratio-error:READ-ONLY IN FRAME d-pl-form        = TRUE.*/

/* SETTINGS FOR FILL-IN place-twice-code IN FRAME d-pl-form
   ALIGN-R                                                              */
/* SETTINGS FOR RADIO-SET place-type IN FRAME d-pl-form
   ALIGN-R                                                              */
/* SETTINGS FOR BUTTON r-sr-izm IN FRAME d-pl-form
   ALIGN-R                                                              */
/* SETTINGS FOR FILL-IN tt-place.start-date IN FRAME d-pl-form
   EXP-LABEL                                                            */
/* SETTINGS FOR TOGGLE-BOX t-asi-srtif IN FRAME d-pl-form
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX d-pl-form
/* Query rebuild information for DIALOG-BOX d-pl-form
     _Options          = "SHARE-LOCK KEEP-EMPTY"
     _Query            is NOT OPENED
*/  /* DIALOG-BOX d-pl-form */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit d-pl-form
ON CHOOSE OF b-exit IN FRAME d-pl-form /* Ввод */
DO:
define variable vOk as logical no-undo .

{ gbl/stdbtn.i }
assign
  tt-place.pl-name
  tt-place.loc1
  tt-place.loc2
  tt-place.loc3
  tt-place.loc4
  tt-place.ps
  tt-place.add-qnty
  tt-place.is-meas
  tt-place.max-qnty
  tt-place.start-date
  tt-place.issue-year
  tt-place.chk-max-qnty
  t-place-virtual
  t-asi-srtif
  place-locat
  error-mass
  rvd-dnstv
  rvd-lvl
  rvd-tmp
  place-si
  v-mi-dnst
  v-mi-lvl
  v-mi-tmp
  ponton-mass
  ponton-height
  t-com-vessel
  t-auto-gate-valve
.


if v-mi-dnst = ? then v-mi-dnst = 0 . 
if v-mi-lvl = ?  then v-mi-lvl = 0 . 
if v-mi-tmp = ? then v-mi-tmp = 0 . 

if input frame {&frame-name} dens-prov <> dens-prov then 
do:
  if input frame {&frame-name} dens-prov = ?
    or (  input frame {&frame-name} dens-prov <= 0
    or input frame {&frame-name} dens-prov >= 1
    )
    then 
  do:
    message "Неверно определена плотность при поверке резервуара" view-as alert-box error.
    apply "entry" to dens-prov .
    return no-apply.
  end.

  assign frame {&frame-name} dens-prov.
end.

if place-type:screen-value = "1"
and t-ponton:screen-value = "yes"
then do :
  if ponton-mass = 0
  or ponton-mass = ?
  then do :
    message "Не указана масса понтона для вертикального резервуара с понтоном." skip
            "Сохранение невозможно." skip
            "Укажите массу понтона."
    view-as alert-box error.
    apply "entry" to ponton-mass .
    return no-apply.
  end .
  if ponton-height = 0
  or ponton-height = ?
  then do :
    message "Не указана высота всплытия понтона для вертикального резервуара с понтоном." skip
            "Сохранение невозможно." skip
            "Укажите высоту всплытия понтона."
    view-as alert-box error.
    apply "entry" to ponton-height .
    return no-apply.
  end .
end .

if t-com-vessel:screen-value = "yes"
then do :
  if com-tanks:screen-value = ""
  then do :
    message "Укажите сообщающийся резервуар!" view-as alert-box error.
    return no-apply.
  end .
end .





if rvd-dnstv <> rvd-tmp
and ((available dnst_sr-izmerenia and dnst_sr-izmerenia.sr-type-izm = 0 and dnst_sr-izmerenia.sr-density and dnst_sr-izmerenia.sr-temperature)
  or (available tmp_sr-izmerenia and tmp_sr-izmerenia.sr-type-izm = 0 and tmp_sr-izmerenia.sr-density and tmp_sr-izmerenia.sr-temperature))
then do :
  message "Бизнес-процессом не предусмотрено использование неравнозначных положений разрешения РВД по параметрам температура и плотность, " +
          "если дополнительное автоматизированное СИ предназначено для измерения обоих параметров. " +
          "Сохранение неравнозначных положений разрешения РВД по параметрам температура и плотность запрещено. " +
          "Установите разрешение РВД для температуры и плотности в равнозначные положения."
  view-as alert-box .
  return no-apply.
end .

if available dnst_sr-izmerenia
and available tmp_sr-izmerenia
and dnst_sr-izmerenia.node-code <> tmp_sr-izmerenia.node-code
and ((dnst_sr-izmerenia.sr-density and dnst_sr-izmerenia.sr-temperature)
  or (tmp_sr-izmerenia.sr-density and tmp_sr-izmerenia.sr-temperature))
then do :
  message "Нельзя устанавливать разные дополнительные СИ по плотности и температуре, если одно из них измеряет оба параметра." skip
          "Сохранение невозможно."
  view-as alert-box .
  return no-apply.
end .

if place-si = ? or place-si = 0
then do :
  message "Не указано основное средство измерения! Вы уверены, что хотите закончить настройку складского места?"
  view-as alert-box question buttons yes-no update vOk .
  if not vOk
  then
    return no-apply .
end .
else do :
  find first sr-izmerenia no-lock where sr-izmerenia.node-code = place-si .
  if sr-izmerenia.sr-level
  and sr-izmerenia.sr-density
  and sr-izmerenia.sr-temperature
  and sr-izmerenia.sr-Weight
  then do : end .
  else do :
    message "Выбранное основное средство измерения не настроено на измерение всех параметров! Вы уверены, что хотите закончить настройку складского места?"
    view-as alert-box question buttons yes-no update vOk .
    if not vOk
    then
      return no-apply .
  end .
end .

if rvd-dnstv
then do :
  if v-mi-dnst = ? or v-mi-dnst = 0
  then do :
    message "Не указано вспомогательное средство измерения плотности. Вы уверены, что хотите закончить настройку складского места?"
    view-as alert-box question buttons yes-no update vOk .
    if not vOk
    then
      return no-apply .
  end .
  else do :
    find first sr-izmerenia no-lock where sr-izmerenia.node-code = v-mi-dnst .
    if not sr-izmerenia.sr-density
    then do :
      message "Выбранное дополнительно средство измерения для плотности не настроено на измерение плотности! Вы уверены, что хотите закончить настройку складского места?"
      view-as alert-box question buttons yes-no update vOk .
      if not vOk
      then
        return no-apply .
    end .
  end .
end .

if rvd-tmp
then do :
  if v-mi-tmp = ? or v-mi-tmp = 0
  then do :
    message "Не указано вспомогательное средство измерения температуры. Вы уверены, что хотите закончить настройку складского места?"
    view-as alert-box question buttons yes-no update vOk .
    if not vOk
    then
      return no-apply .
  end .
  else do :
    find first sr-izmerenia no-lock where sr-izmerenia.node-code = v-mi-tmp .
    if not sr-izmerenia.sr-temperature
    then do :
      message "Выбранное дополнительно средство измерения для температуры не настроено на измерение температуры! Вы уверены, что хотите закончить настройку складского места?"
      view-as alert-box question buttons yes-no update vOk .
      if not vOk
      then
        return no-apply .
    end .
  end .
end .

if rvd-lvl
then do :
  if v-mi-lvl = ? or v-mi-lvl = 0
  then do :
    message "Не указано вспомогательное средство измерения уровня. Вы уверены, что хотите закончить настройку складского места?"
    view-as alert-box question buttons yes-no update vOk .
    if not vOk
    then
      return no-apply .
  end .
  else do :
    find first sr-izmerenia no-lock where sr-izmerenia.node-code = v-mi-lvl .
    if not sr-izmerenia.sr-level
    then do :
      message "Выбранное дополнительно средство измерения для уровня не настроено на измерение уровня! Вы уверены, что хотите закончить настройку складского места?"
      view-as alert-box question buttons yes-no update vOk .
      if not vOk
      then
        return no-apply .
    end .
  end .
end .

if p-mode = {&add-def}
then do :
  message "Внимание! После подтверждения завершения работы по вводу данных дальнейшая корректировка контролируемых параметров резервуара будет возможна только в ИС УРТ. Подтвердите завершение работы!"
  view-as alert-box question buttons yes-no update vOk .
  if not vOk
  then
    return no-apply .
end .

run ref/place01.p
  ( input-output p-rep-rec
  , input p-mode
  , input no /*silent*/
  , input tt-place.obj-type
  , input tt-place.obj-code
  , input tt-place.pl-code
  , input tt-place.loc1
  , input tt-place.loc2
  , input tt-place.loc3
  , input tt-place.loc4
  , input tt-place.pl-name
  , input tt-place.ps
  , input tt-place.add-qnty
  , input tt-place.is-meas
  , input tt-place.max-qnty
  , input tt-place.issue-year
  , input tt-place.start-date
  , input tt-place.chk-max-qnty
  ) no-error.
if error-status:error then 
do:
  { gbl/reterhnd.i no-apply }
  undo, return no-apply.
end.
else 
do :
  find first ub.place no-lock where recid(ub.place) = p-rep-rec .
  ii = 0.
  do ii = 1 to num-entries({&list-place-attr},','):
    v-code = entry(ii,{&list-place-attr}) .
    case v-code :
        when {&place-type} then 
            do :
                v-value = place-type:screen-value .
            end.
        when {&place-SI} then 
            do :
                v-value = place-si:screen-value .
            end.
        when {&place-diameter} then 
            do :
                v-value =  place-diameter:screen-value.
            end.
        when {&dead-balance} then 
            do :
                v-value =  dead-balance:screen-value.
            end.
        when {&water-level} then 
            do :
                v-value =  water-level:screen-value.
            end.    
/*          when {&place-ratio-error} then                    */
/*              do :                                          */
/*                  v-value = place-ratio-error:screen-value .*/
/*              end.                                          */
        when {&place-dens-prov} then 
            do :
                v-value = dens-prov:screen-value .
            end.
        when {&place-virtual} then 
            do :
                v-value = t-place-virtual:screen-value .
            end.
        when {&place-twice-code} then 
            do: 
                v-value = place-twice-code:screen-value .
            end.
/*          when {&place-sert-urov} then                */
/*              do:                                     */
/*                  v-value = t-sert-urov:screen-value .*/
/*              end.                                    */
        when {&place-error-mass} then 
            do: 
                v-value = error-mass:screen-value .
            end.
        when {&place-local} then 
            do: 
                v-value = place-locat:screen-value .
            end.
        when {&place-asi-sertif} then 
            do: 
                v-value = t-asi-srtif:screen-value .
            end.       
        when {&place-rvd-dnsty} then 
            do: 
                v-value = rvd-dnstv:screen-value .
            end.       
        when {&place-rvd-lvl} then 
            do: 
                v-value = rvd-lvl:screen-value .
            end.       
        when {&place-rvd-tmp} then 
            do: 
                v-value = rvd-tmp:screen-value .
            end.       
        when {&place-si-dens} then 
            do: 
                v-value = v-mi-dnst:screen-value .
            end.
        when {&place-si-temp} then 
            do: 
                v-value = v-mi-tmp:screen-value .
            end.
        when {&place-si-level} then 
            do: 
                v-value = v-mi-lvl:screen-value .
            end.
        when {&place-passp-num} then 
            do: 
                v-value = place-passp-num:screen-value .
            end.
        when {&place-passp-type} then 
            do: 
                v-value = place-passp-type:screen-value .
            end. 
        when {&place-dead-high} then 
            do: 
                v-value = place-dead-high:screen-value .
            end.
        when {&place-temp-coef} then 
            do: 
                v-value = place-temp-coef:screen-value .
            end.    
        when {&place-ponton} then 
            do: 
                v-value = t-ponton:screen-value .
            end. 
        when {&place-ponton-mass} then 
            do: 
                v-value = ponton-mass:screen-value .
            end.
        when {&place-ponton-height} then 
            do: 
                v-value = ponton-height:screen-value .
            end.
        when {&place-com-vessel} then 
            do: 
                v-value = t-com-vessel:screen-value .
            end. 
        when {&place-com-tanks} then 
            do: 
                v-value = com-tanks .
            end.
        when {&place-gate-valve} then 
            do: 
                v-value = t-gate-valve:screen-value .
            end. 
        when {&place-gate-valve-tanks} then 
            do: 
                v-value = gate-valve-tanks .
            end.
        when {&place-is-main} then 
            do: 
                v-value = if is-main then "yes" else "no" .
            end. 
        when {&place-auto-gate-valve} then 
            do: 
                v-value = t-auto-gate-valve:screen-value .
            end.                                            
    end case.
    run placelib_write-attr  (input v-code
      ,input p-obj-code
      ,input p-obj-type
      ,input ub.place.pl-code
      ,input v-value
      ,output v-ok      ) no-error.

  end.
  
  if (not v-old-auto-gate-valve or v-com-vessel-changed) /* Включаем */
  and t-auto-gate-valve        /* автозадвижку */
  and is-main                  /* на главном резервуаре */
  then do :                    /* ставим на резервуар признак ТЕКУЩИЙ и включаем автозадвижку на всех СР */
    run placelib_write-attr  (input {&place-current}
      ,input p-obj-code
      ,input p-obj-type
      ,input com_place.pl-code
      ,input "yes"
      ,output v-ok      ) no-error.
    if not v-com-vessel-changed /* если связки СР менялись, то автозадвижка проставится ниже */
    then do :
      do ii = 1 to num-entries(com-tanks) :
        for first com_place no-lock where com_place.obj-type = p-obj-type
                                      and com_place.obj-code = p-obj-code
                                      and com_place.loc1 = entry(ii, com-tanks)
                                      and com_place.status_ = ""
        :
          run placelib_write-attr  (input {&place-auto-gate-valve}
            ,input p-obj-code
            ,input p-obj-type
            ,input com_place.pl-code
            ,input "yes"
            ,output v-ok      ) no-error.
          run placelib_write-attr  (input {&place-current}
            ,input p-obj-code
            ,input p-obj-type
            ,input com_place.pl-code
            ,input "no"
            ,output v-ok      ) no-error.
          { gbl/rum-runa.i
            ?
            this-procedure:handle
            ?
            {&thref-proc_ref-event}
            " buffer com_place:handle "
            " buffer com_place:handle "
            ''
            ''
            no-error
          }
        end .
      end .
    end .
  end .
  
  if v-old-auto-gate-valve     /* Выключаем */
  and not t-auto-gate-valve    /* автозадвижку */
  and is-main                  /* на главном резервуаре */
  and not v-com-vessel-changed /* если связки СР менялись, то автозадвижка проставится ниже */
  then do :                    /* снимаем автозадвижку со всех СР */
    run placelib_write-attr  (input {&place-current}
      ,input p-obj-code
      ,input p-obj-type
      ,input com_place.pl-code
      ,input "no"
      ,output v-ok      ) no-error.
    do ii = 1 to num-entries(com-tanks) :
      for first com_place no-lock where com_place.obj-type = p-obj-type
                                    and com_place.obj-code = p-obj-code
                                    and com_place.loc1 = entry(ii, com-tanks)
                                    and com_place.status_ = ""
      :
        run placelib_write-attr  (input {&place-auto-gate-valve}
          ,input p-obj-code
          ,input p-obj-type
          ,input com_place.pl-code
          ,input "no"
          ,output v-ok      ) no-error.
        { gbl/rum-runa.i
          ?
          this-procedure:handle
          ?
          {&thref-proc_ref-event}
          " buffer com_place:handle "
          " buffer com_place:handle "
          ''
          ''
          no-error
        }
      end .
    end .
  end .
  
  define variable v-cv-place as character no-undo .
  define variable v-com-place-attr-changed as logical no-undo .
  if v-com-vessel-changed
  then do :
    for each com_place-attr exclusive-lock where com_place-attr.obj-type = p-obj-type
                                             and com_place-attr.obj-code = p-obj-code
                                             and com_place-attr.attr-code = {&place-com-tanks}
                                             and com_place-attr.attr-value > ""
    :
      v-com-place-attr-changed = no .
      ii_ :
      do ii = 1 to num-entries(com_place-attr.attr-value) :
        if entry(ii, com_place-attr.attr-value) = tt-place.loc1
        then do :
          com_place-attr.attr-value = trim(replace((com_place-attr.attr-value + ","), (tt-place.loc1 + ","), ""), ",") .
          v-com-place-attr-changed = yes .
          leave ii_ .
        end .
      end .
      if com_place-attr.attr-value = "" /* Связка СР полностью разъединена - снимаем все связанные с СР признаки */
      then do :
        run placelib_write-attr  (input {&place-com-vessel}
          ,input p-obj-code
          ,input p-obj-type
          ,input com_place-attr.pl-code
          ,input "no"
          ,output v-ok      ) no-error.
        run placelib_write-attr  (input {&place-is-main}
          ,input p-obj-code
          ,input p-obj-type
          ,input com_place-attr.pl-code
          ,input "no"
          ,output v-ok      ) no-error.
        run placelib_write-attr  (input {&place-auto-gate-valve}
          ,input p-obj-code
          ,input p-obj-type
          ,input com_place-attr.pl-code
          ,input "no"
          ,output v-ok      ) no-error.
        run placelib_write-attr  (input {&place-current}
          ,input p-obj-code
          ,input p-obj-type
          ,input com_place-attr.pl-code
          ,input "no"
          ,output v-ok      ) no-error.
        v-com-place-attr-changed = yes .
      end .
      if v-com-place-attr-changed
      then do :
        for first com_place no-lock where com_place.obj-type = p-obj-type
                                      and com_place.obj-code = p-obj-code
                                      and com_place.pl-code  = com_place-attr.pl-code
        :
          { gbl/rum-runa.i
            ?
            this-procedure:handle
            ?
            {&thref-proc_ref-event}
            " buffer com_place:handle "
            " buffer com_place:handle "
            ''
            ''
            no-error
          }
        end .
      end .
    end .
    if com-tanks > ""
    then do :
      do ii = 1 to num-entries(com-tanks) :
        for first com_place no-lock where com_place.obj-type = p-obj-type
                                      and com_place.obj-code = p-obj-code
                                      and com_place.loc1 = entry(ii, com-tanks)
                                      and com_place.status_ = ""
        :
          run placelib_write-attr  (input {&place-com-vessel}
            ,input p-obj-code
            ,input p-obj-type
            ,input com_place.pl-code
            ,input "yes"
            ,output v-ok      ) no-error.
          v-cv-place = replace(com-tanks, com_place.loc1, tt-place.loc1) .
          run placelib_write-attr  (input {&place-com-tanks}
            ,input p-obj-code
            ,input p-obj-type
            ,input com_place.pl-code
            ,input v-cv-place
            ,output v-ok      ) no-error.
          run placelib_write-attr  (input {&place-is-main}
            ,input p-obj-code
            ,input p-obj-type
            ,input com_place.pl-code
            ,input "no"
            ,output v-ok      ) no-error.
          if is-main
          then do :
            if t-auto-gate-valve
            then do :
              run placelib_write-attr  (input {&place-auto-gate-valve}
                ,input p-obj-code
                ,input p-obj-type
                ,input com_place.pl-code
                ,input "yes"
                ,output v-ok      ) no-error.  
              run placelib_write-attr  (input {&place-current}
                ,input p-obj-code
                ,input p-obj-type
                ,input com_place.pl-code
                ,input "no"
                ,output v-ok      ) no-error. 
            end .
            else do :
              run placelib_write-attr  (input {&place-auto-gate-valve}
                ,input p-obj-code
                ,input p-obj-type
                ,input com_place.pl-code
                ,input "no"
                ,output v-ok      ) no-error.
            end .
          end .
          
          { gbl/rum-runa.i
            ?
            this-procedure:handle
            ?
            {&thref-proc_ref-event}
            " buffer com_place:handle "
            " buffer com_place:handle "
            ''
            ''
            no-error
          }
          if error-status :error
            then
          do:
            message
              error-status:get-message(1) skip
              return-value
              view-as alert-box error .
        
            return no-apply .
        
          end.
        end .                              
      end .
    end .
  end .
  
  define variable v-gv-place as character no-undo .
  if v-gate-valve-tanks-changed
  then do :
    for each com_place-attr exclusive-lock where com_place-attr.obj-type = p-obj-type
                                             and com_place-attr.obj-code = p-obj-code
                                             and com_place-attr.attr-code = {&place-gate-valve-tanks}
                                             and com_place-attr.attr-value > ""
    :
      ii_ :
      do ii = 1 to num-entries(com_place-attr.attr-value) :
        if entry(ii, com_place-attr.attr-value) = tt-place.loc1
        then do :
          com_place-attr.attr-value = trim(replace((com_place-attr.attr-value + ","), (tt-place.loc1 + ","), ""), ",") .
          leave ii_ .
        end .
      end .
      if com_place-attr.attr-value = ""
      then do :
        run placelib_write-attr  (input {&place-gate-valve}
          ,input p-obj-code
          ,input p-obj-type
          ,input com_place-attr.pl-code
          ,input "no"
          ,output v-ok      ) no-error.
      end .
      for first com_place no-lock where com_place.obj-type = p-obj-type
                                    and com_place.obj-code = p-obj-code
                                    and com_place.pl-code  = com_place-attr.pl-code
      :
        { gbl/rum-runa.i
          ?
          this-procedure:handle
          ?
          {&thref-proc_ref-event}
          " buffer com_place:handle "
          " buffer com_place:handle "
          ''
          ''
          no-error
        }
      end .
    end .
    if gate-valve-tanks > ""
    then do :
      do ii = 1 to num-entries(gate-valve-tanks) :
        for first com_place no-lock where com_place.obj-type = p-obj-type
                                      and com_place.obj-code = p-obj-code
                                      and com_place.loc1 = entry(ii, gate-valve-tanks)
                                      and com_place.status_ = ""
        :
          run placelib_write-attr  (input {&place-gate-valve}
            ,input p-obj-code
            ,input p-obj-type
            ,input com_place.pl-code
            ,input "yes"
            ,output v-ok      ) no-error.
          v-gv-place = replace(gate-valve-tanks, com_place.loc1, tt-place.loc1) .
          run placelib_write-attr  (input {&place-gate-valve-tanks}
            ,input p-obj-code
            ,input p-obj-type
            ,input com_place.pl-code
            ,input v-gv-place
            ,output v-ok      ) no-error.
            
          { gbl/rum-runa.i
            ?
            this-procedure:handle
            ?
            {&thref-proc_ref-event}
            " buffer com_place:handle "
            " buffer com_place:handle "
            ''
            ''
            no-error
          }
          if error-status :error
            then
          do:
            message
              error-status:get-message(1) skip
              return-value
              view-as alert-box error .
        
            return no-apply .
        
          end.
        end .                              
      end .
    end .
  end .

  define variable v-rvd-params-on as character no-undo .
  define variable v-rvd-params-off as character no-undo .
  define variable v-shift-num as integer no-undo .
  define variable v-shift-date as date no-undo .
  define buffer buf_shift-obj for ub.shift-obj .
  
  v-rvd-params-on = "" .
  v-rvd-params-off = "" .
  v-shift-num = 0 .
  
  define variable v-mi-par-list as character no-undo .
  define variable v-mi-old-val-list as character no-undo .
  define variable v-mi-new-val-list as character no-undo .
  
  v-mi-par-list = "" .
  v-mi-old-val-list = "" .
  v-mi-new-val-list = "" .
  
  define variable v-userlog-value as character no-undo .
  
  v-shift-date = ? .
  for first buf_shift-obj
      where buf_shift-obj.obj-type = p-obj-type
        and buf_shift-obj.obj-code = p-obj-code
        and buf_shift-obj.status_ = {&sht-current}
      use-index stts :
    assign
      v-shift-date = buf_shift-obj.shift-date
      v-shift-num  = buf_shift-obj.shift-num
    .
  end.
  if v-shift-date = ? then v-shift-date = today .
  
  if v-rvd-dnsty-on = rvd-dnstv
  and v-rvd-lvl-on = rvd-lvl
  and v-rvd-temp-on = rvd-tmp
  and v-rvd-is-meas-on = tt-place.is-meas
  then do :
    if v-main-mi-old = place-si
    and v-dnst-mi-old = v-mi-dnst
    and v-lvl-mi-old = v-mi-lvl
    and v-tmp-mi-old = v-mi-tmp
    then do :
    end .
    else do :
      if v-main-mi-old <> place-si
      then do :
        assign
          v-mi-par-list = "m" + ","
          v-mi-old-val-list = string(v-main-mi-old) + ","
          v-mi-new-val-list = string(place-si) + ","
        .
      end .
      if v-dnst-mi-old <> v-mi-dnst
      then do :
        assign
          v-mi-par-list = v-mi-par-list + "p" + ","
          v-mi-old-val-list = v-mi-old-val-list + string(v-dnst-mi-old) + ","
          v-mi-new-val-list = v-mi-new-val-list + string(v-mi-dnst) + ","
        .
      end .
      if v-lvl-mi-old <> v-mi-lvl
      then do :
        assign
          v-mi-par-list = v-mi-par-list + "l" + ","
          v-mi-old-val-list = v-mi-old-val-list + string(v-lvl-mi-old) + ","
          v-mi-new-val-list = v-mi-new-val-list + string(v-mi-lvl) + ","
        .
      end .
      if v-tmp-mi-old <> v-mi-tmp
      then do :
        assign
          v-mi-par-list = v-mi-par-list + "t"
          v-mi-old-val-list = v-mi-old-val-list + string(v-tmp-mi-old)
          v-mi-new-val-list = v-mi-new-val-list + string(v-mi-tmp)
        .
      end .
      assign
        v-mi-par-list = trim(v-mi-par-list, ",")
        v-mi-old-val-list = trim(v-mi-old-val-list, ",")
        v-mi-new-val-list = trim(v-mi-new-val-list, ",")
      .
      
      run trg/userlog.p (
              input 'mi-change-1C'
            , input ("Изменение средств измерений на объекте " +
                    p-obj-type + string(p-obj-code) +
                    " рез. " + string(p-pl-code) + ": " +
                    v-mi-par-list + ";" + 
                    v-mi-old-val-list + ";" +
                    v-mi-new-val-list +
                    {&delim-key} +
                    p-obj-type + {&delim-cmd} +
                    string(p-obj-code) + {&delim-cmd} +
                    string(v-shift-date) + {&delim-cmd} +
                    string(v-shift-num) + {&delim-cmd} +
                    string(p-pl-code) + {&delim-cmd} +
                    v-mi-par-list + {&delim-cmd} + 
                    v-mi-old-val-list + {&delim-cmd} +
                    v-mi-new-val-list + {&delim-cmd} +                        
                    string(v-main-mi-old) + {&delim-cmd} +
                    string(place-SI) + {&delim-cmd} +
                    string(v-dnst-mi-old) + {&delim-cmd} +
                    string(v-mi-dnst) + {&delim-cmd} +
                    string(v-lvl-mi-old) + {&delim-cmd} +
                    string(v-mi-lvl) + {&delim-cmd} +
                    string(v-tmp-mi-old) + {&delim-cmd} +
                    string(v-mi-tmp)   )
            , input ?
            , input ?
            , input ""
            ) no-error.
      if error-status :error
      then do:
          message return-value + error-status:get-message(1) view-as alert-box title "Ошибка записи истории действий пользователя".
      end.
    end .
  end .
  else do :
    if v-rvd-on
    then do :
      if v-rvd-dnsty-on <> rvd-dnstv
      and rvd-dnstv = yes
      then do :
        v-rvd-params-on = "p" + "," .
      end .
      if v-rvd-temp-on <> rvd-tmp
      and rvd-tmp = yes
      then do :
        v-rvd-params-on = v-rvd-params-on + "T" + "," .
      end .
      if v-rvd-lvl-on <> rvd-lvl
      and rvd-lvl = yes
      then do :
        v-rvd-params-on = v-rvd-params-on + "l" + "," .
      end .
      if v-rvd-is-meas-on <> tt-place.is-meas
      and tt-place.is-meas = no
      then do :
        v-rvd-params-on = v-rvd-params-on + "F" .
      end .
      v-rvd-params-on = trim(v-rvd-params-on, ",") .
      v-rvd-params-on = trim(v-rvd-params-on) .
      if v-rvd-params-on > ""
      then do :
        v-userlog-value = ("Установка РВД на объекте " +
                          p-obj-type + string(p-obj-code) +
                          " рез. " + string(p-pl-code) + ": " +
                          v-rvd-params-on + ";" + 
                          "yes" + ";" +
                          v-rvd-reason-on + ";" +
                          v-ITSM-num-on + ";" +
                          v-oper-fio-on +
                          {&delim-key} +
                          p-obj-type + {&delim-cmd} +
                          string(p-obj-code) + {&delim-cmd} +
                          string(v-shift-date) + {&delim-cmd} +
                          string(v-shift-num) + {&delim-cmd} +
                          string(p-pl-code) + {&delim-cmd} +
                          v-rvd-params-on + {&delim-cmd} + 
                          "yes" + {&delim-cmd} +
                          v-rvd-reason-on + {&delim-cmd} +
                          v-ITSM-num-on + {&delim-cmd} +
                          v-oper-fio-on + {&delim-cmd} +
                          string(rvd-tmp) + {&delim-cmd} +
                          string(rvd-dnstv) + {&delim-cmd} +
                          string(rvd-lvl) + {&delim-cmd} +
                          string(tt-place.is-meas)  )
                          .
        if v-main-mi-old = place-si
        and v-dnst-mi-old = v-mi-dnst
        and v-lvl-mi-old = v-mi-lvl
        and v-tmp-mi-old = v-mi-tmp
        then do :
        end .
        else do :
          if v-main-mi-old <> place-si
          then do :
            assign
              v-mi-par-list = "m" + ","
              v-mi-old-val-list = string(v-main-mi-old) + ","
              v-mi-new-val-list = string(place-si) + ","
            .
          end .
          if v-dnst-mi-old <> v-mi-dnst
          then do :
            assign
              v-mi-par-list = v-mi-par-list + "p" + ","
              v-mi-old-val-list = v-mi-old-val-list + string(v-dnst-mi-old) + ","
              v-mi-new-val-list = v-mi-new-val-list + string(v-mi-dnst) + ","
            .
          end .
          if v-lvl-mi-old <> v-mi-lvl
          then do :
            assign
              v-mi-par-list = v-mi-par-list + "l" + ","
              v-mi-old-val-list = v-mi-old-val-list + string(v-lvl-mi-old) + ","
              v-mi-new-val-list = v-mi-new-val-list + string(v-mi-lvl) + ","
            .
          end .
          if v-tmp-mi-old <> v-mi-tmp
          then do :
            assign
              v-mi-par-list = v-mi-par-list + "t"
              v-mi-old-val-list = v-mi-old-val-list + string(v-tmp-mi-old)
              v-mi-new-val-list = v-mi-new-val-list + string(v-mi-tmp)
            .
          end .
          assign
            v-mi-par-list = trim(v-mi-par-list, ",")
            v-mi-old-val-list = trim(v-mi-old-val-list, ",")
            v-mi-new-val-list = trim(v-mi-new-val-list, ",")
          .
          
          run trg/userlog.p (
                  input 'mi-change'
                , input ("Изменение средств измерений на объекте " +
                        p-obj-type + string(p-obj-code) +
                        " рез. " + string(p-pl-code) + ": " +
                        v-mi-par-list + ";" + 
                        v-mi-old-val-list + ";" +
                        v-mi-new-val-list +
                        {&delim-key} +
                        p-obj-type + {&delim-cmd} +
                        string(p-obj-code) + {&delim-cmd} +
                        string(v-shift-date) + {&delim-cmd} +
                        string(v-shift-num) + {&delim-cmd} +
                        string(p-pl-code) + {&delim-cmd} +
                        v-mi-par-list + {&delim-cmd} + 
                        v-mi-old-val-list + {&delim-cmd} +
                        v-mi-new-val-list   )
                , input ?
                , input ?
                , input ""
                ) no-error.
          if error-status :error
          then do:
              message return-value + error-status:get-message(1) view-as alert-box title "Ошибка записи истории действий пользователя".
          end.
          v-userlog-value = v-userlog-value + {&delim-cmd} +
                            "" + {&delim-cmd} +                        /* rvs-code */
                            string(v-main-mi-old) + {&delim-cmd} +
                            string(place-SI) + {&delim-cmd} +
                            string(v-dnst-mi-old) + {&delim-cmd} +
                            string(v-mi-dnst) + {&delim-cmd} +
                            string(v-lvl-mi-old) + {&delim-cmd} +
                            string(v-mi-lvl) + {&delim-cmd} +
                            string(v-tmp-mi-old) + {&delim-cmd} +
                            string(v-mi-tmp) 
                            .
        end .                  
        run trg/userlog.p (
                input 'rvd-reasons'
              , input v-userlog-value
              , input ?
              , input ?
              , input ""
              ) no-error.
        if error-status :error
        then do:
            message return-value + error-status:get-message(1) view-as alert-box title "Ошибка записи истории действий пользователя".
        end.
           
        run placelib_write-attr  (input {&place-need-RVD-rvs}
                                  ,input p-obj-code
                                  ,input p-obj-type
                                  ,input ub.place.pl-code
                                  ,input string(yes)
                                  ,output v-ok      ) no-error.   
                
      end .
    end .
    if v-rvd-off
    then do :
      if v-rvd-dnsty-on <> rvd-dnstv
      and rvd-dnstv = no
      then do :
        v-rvd-params-off = "p" + "," .
      end .
      if v-rvd-temp-on <> rvd-tmp
      and rvd-tmp = no
      then do :
        v-rvd-params-off = v-rvd-params-off + "T" + "," .
      end .
      if v-rvd-lvl-on <> rvd-lvl
      and rvd-lvl = no
      then do :
        v-rvd-params-off = v-rvd-params-off + "l" + "," .
      end .
      if v-rvd-is-meas-on <> tt-place.is-meas
      and tt-place.is-meas = yes
      then do :
        v-rvd-params-off = v-rvd-params-off + "F" .
      end .
      v-rvd-params-off = trim(v-rvd-params-off, ",") .
      v-rvd-params-off = trim(v-rvd-params-off) .
      if v-rvd-params-off > ""
      then do :
        v-userlog-value = ("Снятие РВД на объекте " +
                          p-obj-type + string(p-obj-code) +
                          " рез. " + string(p-pl-code) + ": " +
                          v-rvd-params-off + ";" + 
                          "no" + ";" +
                          v-rvd-reason-off + ";" +
                          v-ITSM-num-off + ";" +
                          v-oper-fio-off +
                          {&delim-key} +
                          p-obj-type + {&delim-cmd} +
                          string(p-obj-code) + {&delim-cmd} +
                          string(v-shift-date) + {&delim-cmd} +
                          string(v-shift-num) + {&delim-cmd} +
                          string(p-pl-code) + {&delim-cmd} +
                          v-rvd-params-off + {&delim-cmd} + 
                          "no" + {&delim-cmd} +
                          v-rvd-reason-off + {&delim-cmd} +
                          v-ITSM-num-off + {&delim-cmd} +
                          v-oper-fio-off + {&delim-cmd} +
                          string(rvd-tmp) + {&delim-cmd} +
                          string(rvd-dnstv) + {&delim-cmd} +
                          string(rvd-lvl) + {&delim-cmd} +
                          string(tt-place.is-meas)  )
                          .
        if v-main-mi-old = place-si
        and v-dnst-mi-old = v-mi-dnst
        and v-lvl-mi-old = v-mi-lvl
        and v-tmp-mi-old = v-mi-tmp
        then do :
        end .
        else do :
          if v-main-mi-old <> place-si
          then do :
            assign
              v-mi-par-list = "m" + ","
              v-mi-old-val-list = string(v-main-mi-old) + ","
              v-mi-new-val-list = string(place-si) + ","
            .
          end .
          if v-dnst-mi-old <> v-mi-dnst
          then do :
            assign
              v-mi-par-list = v-mi-par-list + "p" + ","
              v-mi-old-val-list = v-mi-old-val-list + string(v-dnst-mi-old) + ","
              v-mi-new-val-list = v-mi-new-val-list + string(v-mi-dnst) + ","
            .
          end .
          if v-lvl-mi-old <> v-mi-lvl
          then do :
            assign
              v-mi-par-list = v-mi-par-list + "l" + ","
              v-mi-old-val-list = v-mi-old-val-list + string(v-lvl-mi-old) + ","
              v-mi-new-val-list = v-mi-new-val-list + string(v-mi-lvl) + ","
            .
          end .
          if v-tmp-mi-old <> v-mi-tmp
          then do :
            assign
              v-mi-par-list = v-mi-par-list + "t"
              v-mi-old-val-list = v-mi-old-val-list + string(v-tmp-mi-old)
              v-mi-new-val-list = v-mi-new-val-list + string(v-mi-tmp)
            .
          end .
          assign
            v-mi-par-list = trim(v-mi-par-list, ",")
            v-mi-old-val-list = trim(v-mi-old-val-list, ",")
            v-mi-new-val-list = trim(v-mi-new-val-list, ",")
          .
          
          run trg/userlog.p (
                  input 'mi-change'
                , input ("Изменение средств измерений на объекте " +
                        p-obj-type + string(p-obj-code) +
                        " рез. " + string(p-pl-code) + ": " +
                        v-mi-par-list + ";" + 
                        v-mi-old-val-list + ";" +
                        v-mi-new-val-list +
                        {&delim-key} +
                        p-obj-type + {&delim-cmd} +
                        string(p-obj-code) + {&delim-cmd} +
                        string(v-shift-date) + {&delim-cmd} +
                        string(v-shift-num) + {&delim-cmd} +
                        string(p-pl-code) + {&delim-cmd} +
                        v-mi-par-list + {&delim-cmd} + 
                        v-mi-old-val-list + {&delim-cmd} +
                        v-mi-new-val-list   )
                , input ?
                , input ?
                , input ""
                ) no-error.
          if error-status :error
          then do:
              message return-value + error-status:get-message(1) view-as alert-box title "Ошибка записи истории действий пользователя".
          end.
          v-userlog-value = v-userlog-value + {&delim-cmd} +
                            "" + {&delim-cmd} +                        /* rvs-code */
                            string(v-main-mi-old) + {&delim-cmd} +
                            string(place-SI) + {&delim-cmd} +
                            string(v-dnst-mi-old) + {&delim-cmd} +
                            string(v-mi-dnst) + {&delim-cmd} +
                            string(v-lvl-mi-old) + {&delim-cmd} +
                            string(v-mi-lvl) + {&delim-cmd} +
                            string(v-tmp-mi-old) + {&delim-cmd} +
                            string(v-mi-tmp) 
                            .
        end .
        run trg/userlog.p (
                input 'rvd-reasons'
              , input v-userlog-value
              , input ?
              , input ?
              , input ""
              ) no-error.
        if error-status :error
        then do:
            message return-value + error-status:get-message(1) view-as alert-box title "Ошибка записи истории действий пользователя".
        end.
      end .
    end .
  end .  

  if tt-place.is-meas
  and not rvd-dnstv
  and not rvd-tmp
  and not rvd-lvl
  then do :
    run placelib_write-attr  (input {&place-need-RVD-rvs}
                              ,input p-obj-code
                              ,input p-obj-type
                              ,input ub.place.pl-code
                              ,input string(no)
                              ,output v-ok      ) no-error.
  end .
    
end.
if AVAILABLE (ub.place) then 
do:
{ gbl/rum-runa.i
    ?
    this-procedure:handle
    ?
    {&thref-proc_ref-event}
    " buffer ub.place:handle "
    " buffer ub.place:handle "
    ''
    ''
    no-error
  }
  if error-status :error
    then
  do:
    message
      error-status:get-message(1) skip
      return-value
      view-as alert-box error .

    return no-apply .

  end.
end.  
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-hist
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-hist d-pl-form
ON CHOOSE OF B-hist IN FRAME d-pl-form /* История */
DO:
    define variable v-rid-list as character no-undo.
    run ref/cplchist.w
      ( input parparentproc
      , input p-obj-type
      , input p-obj-code
      , input "":u /*bttns  */
      , input "one":u /*p-mode*/
      , input tt-place.obj-type
      , input tt-place.obj-code
      , input tt-place.pl-code
      , input 0 /*p-gds-code*/
      , input 0 /*p-pump-code*/
      , input 0 /*p-nozzle-code*/
      , input '':u /*p-subject*/
      , input-output v-rid-list
      ) no-error .

  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-quit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-quit d-pl-form
ON CHOOSE OF b-quit IN FRAME d-pl-form /* Отмена */
DO:
  define variable vlog as logical no-undo .
  message "Все введенные данные будут утеряны. Вы уверены, что хотите отказаться от внесенных изменений?"
  view-as alert-box question buttons yes-no update vlog .
  if not vlog then return no-apply .
  p-rep-rec = ?.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME dens-prov
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL dens-prov d-pl-form
ON LEAVE OF dens-prov IN FRAME d-pl-form /* Плотность при поверке резервуара */
DO:
  if input frame {&frame-name} {&self-name} <> {&self-name} then do:
    if input frame {&frame-name} dens-prov = ?
      or (  input frame {&frame-name} dens-prov <= 0
            or input frame {&frame-name} dens-prov >= 1
              )
    then do:
      message "Неверно определена плотность при поверке резервуара" view-as alert-box error.
      apply "entry" to dens-prov .
      return no-apply.
    end.

    assign frame {&frame-name} dens-prov.
  end.
if AVAILABLE (ub.place) then 
do:
{ gbl/rum-runa.i
    ?
    this-procedure:handle
    ?
    {&thref-proc_ref-event}
    " buffer ub.place:handle "
    " buffer ub.place:handle "
    ''
    ''
    no-error
  }
  if error-status :error
    then
  do:
    message
      error-status:get-message(1) skip
      return-value
      view-as alert-box error .

    return no-apply .

  end.
end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME rvd-dnstv
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rvd-dnstv d-pl-form
ON VALUE-CHANGED OF rvd-dnstv IN FRAME d-pl-form /* Измеряется приборами */
DO:
  define variable vlog as logical no-undo .
  define variable v-tmp-old-val as character no-undo .
  
  v-tmp-old-val = rvd-tmp:screen-value .
  
  if available dnst_sr-izmerenia
  and dnst_sr-izmerenia.sr-type-izm = 0
  and dnst_sr-izmerenia.sr-density
  and dnst_sr-izmerenia.sr-temperature
  and rvd-dnstv:screen-value <> rvd-tmp:screen-value
  then do :
    message "Бизнес-процессом не предусмотрено использование неравнозначных положений разрешения РВД по параметрам температура и плотность, " +
            "если автоматизированное СИ для одного из них предназначено для измерения обоих. " +
            "Сохранение неравнозначных положений разрешения РВД по параметрам температура и плотность запрещено. " +
            "Установить значение " + (if rvd-dnstv:screen-value = "yes" then "'Да'" else "'Нет'") + " для РВД по температуре автоматически?"
    view-as alert-box question buttons yes-no update vlog .
    if vlog
    then do :
      rvd-tmp:screen-value = rvd-dnstv:screen-value .
    end .
  end .
  
  if p-mode =  {&update} then    /* EXPSD-8061 */
  do:
    if rvd-dnstv:screen-value = "yes" then do:
      if not v-rvd-on
      and not v-rvd-dnsty-on
      then do :
        message "Для установки разрешения РВД необходимо указать причину перехода на РВД, номер заявки в ITSM, ФИО инициатора заявки."
        view-as alert-box question buttons ok-cancel update vlog .
        if not vlog
        then do :
          rvd-dnstv:screen-value = "no" .
          rvd-tmp:screen-value = v-tmp-old-val .
          return no-apply .
        end .
        v-rvd-reason-on = ? .
        run ref/rvd-reasons.w (input parparentproc,
                               input 0, /* РГС */
                               output v-rvd-reason-on,
                               output v-ITSM-num-on,
                               output v-oper-fio-on)
                               .
        if v-rvd-reason-on = ?
        then do :
          rvd-dnstv:screen-value = "no" .
          rvd-tmp:screen-value = v-tmp-old-val .
          return no-apply .
        end . 
        v-rvd-on = yes .                     
      end .
    end.  
    else do:
      if not v-rvd-off
      and v-rvd-dnsty-on
      then do :
        message "Для снятия разрешения РВД необходимо указать причину перехода на АВД, номер заявки в ITSM, ФИО инициатора заявки."
        view-as alert-box question buttons ok-cancel update vlog .
        if not vlog 
        then do :
          rvd-dnstv:screen-value = "yes" .
          rvd-tmp:screen-value = v-tmp-old-val .
          return no-apply .
        end .
        v-rvd-reason-off = ? .
        run ref/rvd-reasons.w (input parparentproc,
                               input 0, /* РГС */
                               output v-rvd-reason-off,
                               output v-ITSM-num-off,
                               output v-oper-fio-off)
                               .
        if v-rvd-reason-off = ?
        then do :
          rvd-dnstv:screen-value = "yes" .
          rvd-tmp:screen-value = v-tmp-old-val .
          return no-apply .
        end .
        v-rvd-off = yes .
      end .
    end.  
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME rvd-lvl
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rvd-lvl d-pl-form
ON VALUE-CHANGED OF rvd-lvl IN FRAME d-pl-form /* Измеряется приборами */
DO:
  define variable vlog as logical no-undo .
  
  if p-mode =  {&update} then    /* EXPSD-8061 */
  do:
    if rvd-lvl:screen-value = "yes" then do:
      if not v-rvd-on
      and not v-rvd-lvl-on
      then do :
        message "Для установки разрешения РВД необходимо указать причину перехода на РВД, номер заявки в ITSM, ФИО инициатора заявки."
        view-as alert-box question buttons ok-cancel update vlog .
        if not vlog
        then do :
          rvd-lvl:screen-value = "no" .
          return no-apply .
        end .
        v-rvd-reason-on = ? .
        run ref/rvd-reasons.w (input parparentproc,
                               input 0, /* РГС */
                               output v-rvd-reason-on,
                               output v-ITSM-num-on,
                               output v-oper-fio-on)
                               .
        if v-rvd-reason-on = ?
        then do :
          rvd-lvl:screen-value = "no" .
          return no-apply .
        end . 
        v-rvd-on = yes .                     
      end .
    end.  
    else do:
      if not v-rvd-off
      and v-rvd-lvl-on
      then do :
        message "Для снятия разрешения РВД необходимо указать причину перехода на АВД, номер заявки в ITSM, ФИО инициатора заявки."
        view-as alert-box question buttons ok-cancel update vlog .
        if not vlog
        then do :
          rvd-lvl:screen-value = "yes" .
          return no-apply .
        end .
        v-rvd-reason-off = ? .
        run ref/rvd-reasons.w (input parparentproc,
                               input 0, /* РГС */
                               output v-rvd-reason-off,
                               output v-ITSM-num-off,
                               output v-oper-fio-off)
                               .
        if v-rvd-reason-off = ?
        then do :
          rvd-lvl:screen-value = "yes" .
          return no-apply .
        end .
        v-rvd-off = yes .
      end .
    end.
  end.  
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME rvd-tmp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rvd-tmp d-pl-form
ON VALUE-CHANGED OF rvd-tmp IN FRAME d-pl-form /* Измеряется приборами */
DO:
  define variable vlog as logical no-undo .
  define variable v-dnst-old-val as character no-undo .
  
  v-dnst-old-val = rvd-dnstv:screen-value .
  
  if available tmp_sr-izmerenia
  and tmp_sr-izmerenia.sr-type-izm = 0
  and tmp_sr-izmerenia.sr-temperature
  and tmp_sr-izmerenia.sr-density
  and rvd-tmp:screen-value <> rvd-dnstv:screen-value
  then do :
    message "Бизнес-процессом не предусмотрено использование неравнозначных положений разрешения РВД по параметрам температура и плотность, " +
            "если автоматизированное СИ для одного из них предназначено для измерения обоих. " +
            "Сохранение неравнозначных положений разрешения РВД по параметрам температура и плотность запрещено. " +
            "Установить значение " + (if rvd-tmp:screen-value = "yes" then "'Да'" else "'Нет'") + " для РВД по плотности автоматически?"
    view-as alert-box question buttons yes-no update vlog .
    if vlog
    then do :
      rvd-dnstv:screen-value = rvd-tmp:screen-value .
    end .
  end .
  
  if p-mode =  {&update} then    /* EXPSD-8061 */
  do:
    if rvd-tmp:screen-value = "yes" then do:
      if not v-rvd-on
      and not v-rvd-temp-on
      then do :
        message "Для установки разрешения РВД необходимо указать причину перехода на РВД, номер заявки в ITSM, ФИО инициатора заявки."
        view-as alert-box question buttons ok-cancel update vlog .
        if not vlog 
        then do :
          rvd-tmp:screen-value = "no" .
          rvd-dnstv:screen-value = v-dnst-old-val .
          return no-apply .
        end .
        v-rvd-reason-on = ? .
        run ref/rvd-reasons.w (input parparentproc,
                               input 0, /* РГС */
                               output v-rvd-reason-on,
                               output v-ITSM-num-on,
                               output v-oper-fio-on)
                               .
        if v-rvd-reason-on = ?
        then do :
          rvd-tmp:screen-value = "no" .
          rvd-dnstv:screen-value = v-dnst-old-val .
          return no-apply .
        end .        
        v-rvd-on = yes .              
      end .
    end.  
    else do:
      if not v-rvd-off
      and v-rvd-temp-on
      then do :
        message "Для снятия разрешения РВД необходимо указать причину перехода на АВД, номер заявки в ITSM, ФИО инициатора заявки."
        view-as alert-box question buttons ok-cancel update vlog .
        if not vlog
        then do :
          rvd-tmp:screen-value = "yes" .
          rvd-dnstv:screen-value = v-dnst-old-val .
          return no-apply .
        end .
        v-rvd-reason-off = ? .
        run ref/rvd-reasons.w (input parparentproc,
                               input 0, /* РГС */
                               output v-rvd-reason-off,
                               output v-ITSM-num-off,
                               output v-oper-fio-off)
                               .
        if v-rvd-reason-off = ?
        then do :
          rvd-tmp:screen-value = "yes" .
          rvd-dnstv:screen-value = v-dnst-old-val .
          return no-apply .
        end .
        v-rvd-off = yes .
      end .
    end.  
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME 
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-place.is-meas d-pl-form
ON VALUE-CHANGED OF tt-place.is-meas IN FRAME d-pl-form /* Измеряется приборами */
DO:
  define variable vlog as logical no-undo .
  
    if tt-place.is-meas:screen-value = "yes" then do:
      if not v-rvd-off
      and not v-rvd-is-meas-on
      and p-mode = {&update}   /* EXPSD-8061 */
      then do :
        message "Для снятия разрешения РВД необходимо указать причину перехода на АВД, номер заявки в ITSM, ФИО инициатора заявки."
        view-as alert-box question buttons ok-cancel update vlog .
        if not vlog 
        then do :
          tt-place.is-meas:screen-value = "no" .
          return no-apply .
        end .
        v-rvd-reason-off = ? .
        run ref/rvd-reasons.w (input parparentproc,
                               input 0, /* РГС */
                               output v-rvd-reason-off,
                               output v-ITSM-num-off,
                               output v-oper-fio-off)
                               .
        if v-rvd-reason-off = ?
        then do :
          tt-place.is-meas:screen-value = "no" .
          return no-apply .
        end .
        v-rvd-off = yes .
      end .
      enable t-asi-srtif with frame {&frame-name} .
    end.  
    else do:
      if not v-rvd-on
      and v-rvd-is-meas-on
      and p-mode = {&update}   /* EXPSD-8061 */
      then do :
        message "Для установки разрешения РВД необходимо указать причину перехода на РВД, номер заявки в ITSM, ФИО инициатора заявки."
        view-as alert-box question buttons ok-cancel update vlog .
        if not vlog
        then do :
          tt-place.is-meas:screen-value = "yes" .
          return no-apply .
        end .
        v-rvd-reason-on = ? .
        run ref/rvd-reasons.w (input parparentproc,
                               input 0, /* РГС */
                               output v-rvd-reason-on,
                               output v-ITSM-num-on,
                               output v-oper-fio-on)
                               .
        if v-rvd-reason-on = ?
        then do :
          tt-place.is-meas:screen-value = "yes" .
          return no-apply .
        end . 
        v-rvd-on = yes .                     
      end .
      disable t-asi-srtif with frame {&frame-name} .
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME place-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL place-type d-pl-form
ON value-changed OF place-type IN FRAME d-pl-form
DO:
  if place-type:screen-value = "1"
  then do :
    if p-mode = {&add-def}
    then do :
      enable t-ponton with frame {&frame-name} .
      if t-ponton:screen-value = "yes"
      then do :
        enable ponton-mass ponton-height with frame {&frame-name} .
      end .
      else do :
        disable ponton-mass ponton-height with frame {&frame-name} .
      end .
    end .
  end .
  if place-type:screen-value = "2"
  then do :
    disable t-ponton ponton-mass ponton-height with frame {&frame-name} .
  end .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME t-ponton
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL t-ponton d-pl-form
ON value-changed OF t-ponton IN FRAME d-pl-form
DO:
  if t-ponton:screen-value = "yes"
  then do :
    enable ponton-mass ponton-height with frame {&frame-name} .
  end .
  else do :
    disable ponton-mass ponton-height with frame {&frame-name} .
  end .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME t-com-vessel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL t-com-vessel d-pl-form
ON value-changed OF t-com-vessel IN FRAME d-pl-form
DO:
  if t-com-vessel:screen-value = "yes"
  then do :
    enable b-com-tanks with frame {&frame-name} .
    disable t-gate-valve b-gate-valve-tanks with frame {&frame-name} .
    if v-not-gas-place
    then do :
      display t-auto-gate-valve with frame {&frame-name}.
      if is-main
      then do :
        enable t-auto-gate-valve with frame {&frame-name}.
      end .
    end .
  end .
  else do :
    if is-main
    and num-entries(com-tanks) > 1
    then do :
      message substitute('Резервуар №&1 отмечен как "Главный", изменение связки сообщающихся резервуаров невозможно! Исключите из связки все "Не главные" резервуары!', tt-place.loc1)
      view-as alert-box .
      t-com-vessel:screen-value = "yes" .
      return no-apply .
    end .
    if com-tanks > ""
    then do :
      message "Сообщающиеся резервуары будут разъединены! Вы уверены?" view-as alert-box question buttons yes-no update v-ok .
      if v-ok
      then do :
        com-tanks = "" .
        display com-tanks with frame {&frame-name} .
        disable b-com-tanks with frame {&frame-name} .
        hide v-is-main in frame {&frame-name} .
      end .
      else do :
        t-com-vessel:screen-value = "yes" .
        return no-apply .
      end .
    end .
    if v-sug-place
    then do :
      enable t-gate-valve b-gate-valve-tanks with frame {&frame-name} .
    end .
    hide t-auto-gate-valve in frame {&frame-name}.
  end .
  v-com-vessel-changed = yes .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME t-auto-gate-valve
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL t-auto-gate-valve d-pl-form
ON value-changed OF t-auto-gate-valve IN FRAME d-pl-form
DO:
  if t-auto-gate-valve:screen-value = "no"
  then do :
    message "Чек-бокс «Автоматическая задвижка» будет выключен. Расчет плотности не будет рассчитываться на основании анализа убыли объема в резервуаре! Вы уверены?" view-as alert-box question buttons yes-no update v-ok .
    if not v-ok
    then do :
      t-auto-gate-valve:screen-value = "yes" .
      return no-apply .
    end .
  end .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME t-gate-valve
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL t-gate-valve d-pl-form
ON value-changed OF t-gate-valve IN FRAME d-pl-form
DO:
  if t-gate-valve:screen-value = "yes"
  then do :
    enable b-gate-valve-tanks with frame {&frame-name} .
    disable t-com-vessel b-com-tanks with frame {&frame-name} .
  end .
  else do :
    if gate-valve-tanks > ""
    then do :
      gate-valve-tanks = "" .
      display gate-valve-tanks with frame {&frame-name} .
      disable b-gate-valve-tanks with frame {&frame-name} .
    end .
    enable t-com-vessel b-com-tanks with frame {&frame-name} .
  end .
  v-gate-valve-tanks-changed = yes .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME r-sr-izm
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL r-sr-izm d-pl-form
ON CHOOSE OF r-sr-izm IN FRAME d-pl-form /* r-sr-izm */
DO:
  define variable v-node-code as integer no-undo.
  define variable v-sr-type as character no-undo.
  v-node-code = 0 .
  run ref/sr-izm.w (input parparentproc ,
                    input "b-sel"       ,
                    input {&lookup}     ,
                    input ""            ,
                    input ""            ,
                    input-output v-node-code,
                    output v-sr-type) no-error.
  if v-node-code <> 0 and v-node-code <> ? then do :
    place-si = v-node-code.
    place-si:screen-value = string(v-node-code).
    find first osn_sr-izmerenia no-lock where osn_sr-izmerenia.node-code = place-si .
    apply "leave" to place-si in frame d-pl-form .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

on entry of place-si-name IN FRAME d-pl-form 
do:
  apply "entry" to place-si in frame d-pl-form.
end .

on entry of place-si IN FRAME d-pl-form 
do:
  hide place-si-name in frame d-pl-form.
end .

on return of place-si IN FRAME d-pl-form 
do:
  apply "leave" to place-si IN FRAME d-pl-form .
end .

on del of place-si in frame d-pl-form
do :
  place-si = ? .
  place-si:screen-value = "?" .
end .

on leave of place-si IN FRAME d-pl-form 
do:
  define variable v-old-val as character no-undo .
  
  v-old-val = string(place-si) .
  find first osn_sr-izmerenia no-lock where osn_sr-izmerenia.node-code = integer(place-si:screen-value) no-error .
  if not available osn_sr-izmerenia
  then do :
    if place-si:screen-value <> "?"
    and place-si:screen-value <> "0"
    then do :
      message ("Не найдено средство измерения с кодом " + place-si:screen-value) view-as alert-box .
      place-si:screen-value = v-old-val .
    end .
/*    apply "choose" to b-mi-dnst in frame {&frame-name}.*/
    return .
  end .
  place-si-name = osn_sr-izmerenia.sr-model .
  display place-si-name with frame {&frame-name}.
  enable place-si-name with frame {&frame-name}.
  assign place-si .
end .

&Scoped-define SELF-NAME b-mi-dnst
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-mi-dnst d-pl-form
ON CHOOSE OF b-mi-dnst IN FRAME d-pl-form /* r-sr-izm */
DO:
  define variable v-node-code as integer no-undo.
  define variable v-sr-type-id as character no-undo.
  define variable v-sr-type-izm as character no-undo .
  v-node-code = 0 .
  
/*  if available tmp_sr-izmerenia                           */
/*  then do :                                               */
/*    v-sr-type-izm = string(tmp_sr-izmerenia.sr-type-izm) .*/
/*  end .                                                   */
/*  else do :                                               */
    v-sr-type-izm = "0,1" .
/*  end .*/
  run ref/sr-izm.w (input parparentproc ,
                    input "b-sel"       ,
                    input {&lookup}     ,
                    input v-sr-type-izm ,
                    input "dnst"        ,
                    input-output v-node-code,
                    output v-sr-type-id) no-error.
  if v-node-code <> 0 and v-node-code <> ? then do :
    v-mi-dnst = v-node-code.
    v-mi-dnst:screen-value = string(v-node-code).
    find first dnst_sr-izmerenia no-lock where dnst_sr-izmerenia.node-code = v-mi-dnst .
    apply "leave" to v-mi-dnst in frame d-pl-form .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

on entry of v-mi-dnst-name IN FRAME d-pl-form 
do:
  apply "entry" to v-mi-dnst in frame d-pl-form.
end .

on entry of v-mi-dnst IN FRAME d-pl-form 
do:
  hide v-mi-dnst-name in frame d-pl-form.
end .

on return of v-mi-dnst IN FRAME d-pl-form 
do:
  apply "leave" to v-mi-dnst IN FRAME d-pl-form .
end .

on del of v-mi-dnst in frame d-pl-form
do :
  v-mi-dnst = 0 .
  v-mi-dnst:screen-value = "0" .
end .

on leave of v-mi-dnst IN FRAME d-pl-form 
do:
  define variable vlog as logical no-undo .
  define variable v-old-val as character no-undo .
  v-old-val = string(v-mi-dnst) .
  if v-mi-dnst:screen-value = "?" then v-mi-dnst:screen-value = "0" .
  find first dnst_sr-izmerenia no-lock where dnst_sr-izmerenia.node-code = integer(v-mi-dnst:screen-value) no-error .
  if not available dnst_sr-izmerenia
  then do :
    if v-mi-dnst:screen-value <> "?"
    and v-mi-dnst:screen-value <> "0"
    then do :
      message ("Не найдено средство измерения с кодом " + v-mi-dnst:screen-value) view-as alert-box .
      v-mi-dnst:screen-value = v-old-val .
    end .
/*    apply "choose" to b-mi-dnst in frame {&frame-name}.*/
    return .
  end .
  else do :
    if dnst_sr-izmerenia.sr-type-izm = 2
    then do :
      message "Средство измерения является Измерительной Системой!" view-as alert-box .
      v-mi-dnst:screen-value = v-old-val .
/*      apply "choose" to b-mi-dnst in frame {&frame-name}.*/
      return .
    end .
    if not dnst_sr-izmerenia.sr-density
    then do :
      message "Средство измерения НЕ измеряет плотность!" view-as alert-box .
      v-mi-dnst:screen-value = v-old-val .
/*      apply "choose" to b-mi-dnst in frame {&frame-name}.*/
      return .
    end .
    if dnst_sr-izmerenia.sr-type-izm = 0
    and dnst_sr-izmerenia.sr-density
    and dnst_sr-izmerenia.sr-temperature
    and rvd-dnstv:screen-value <> rvd-tmp:screen-value
    then do :
      message "Бизнес-процессом не предусмотрено использование неравнозначных положений разрешения РВД по параметрам температура и плотность, " +
              "если автоматизированное СИ для одного из них предназначено для измерения обоих. " +
              "Сохранение неравнозначных положений разрешения РВД по параметрам температура и плотность запрещено. " +
              "Установить значение " + (if rvd-dnstv:screen-value = "yes" then "'Да'" else "'Нет'") + " для РВД по температуре автоматически?"
      view-as alert-box question buttons yes-no update vlog .
      if vlog
      then do :
        rvd-tmp:screen-value = rvd-dnstv:screen-value .
      end .
    end .
  end .
  v-mi-dnst-name = dnst_sr-izmerenia.sr-model .
  display v-mi-dnst-name with frame {&frame-name}.
  enable v-mi-dnst-name with frame {&frame-name}.
  assign v-mi-dnst .
  
  if dnst_sr-izmerenia.sr-temperature
/*  and v-mi-dnst <> v-mi-tmp*/
  then do :
/*    message "Для измерения плотности выбрано дополнительное СИ " + v-mi-dnst-name + ". Установить данное СИ для измерения температуры автоматически?"*/
/*    view-as alert-box buttons yes-no update vlog .                                                                                                   */
/*    if vlog                                                                                                                                          */
/*    then do :                                                                                                                                        */
      v-mi-tmp = v-mi-dnst .
      v-mi-tmp:screen-value = v-mi-dnst:screen-value .
      v-mi-tmp-name = v-mi-dnst-name .
      find first tmp_sr-izmerenia no-lock where tmp_sr-izmerenia.node-code = v-mi-tmp .
      display v-mi-tmp-name with frame {&frame-name}.
      enable v-mi-tmp-name with frame {&frame-name}.
/*    end .*/
  end .
  
end .

&Scoped-define SELF-NAME b-mi-lvl
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-mi-lvl d-pl-form
ON CHOOSE OF b-mi-lvl IN FRAME d-pl-form /* r-sr-izm */
DO:
  define variable v-node-code as integer no-undo.
  define variable v-sr-type as character no-undo.
  v-node-code = 0 .
  run ref/sr-izm.w (input parparentproc ,
                    input "b-sel"       ,
                    input {&lookup}     ,
                    input "0,1"         ,
                    input "lvl"         ,
                    input-output v-node-code,
                    output v-sr-type) no-error.
  if v-node-code <> 0 and v-node-code <> ? then do :
    v-mi-lvl = v-node-code.
    v-mi-lvl:screen-value = string(v-node-code).
    find first lvl_sr-izmerenia no-lock where lvl_sr-izmerenia.node-code = v-mi-lvl .
    apply "leave" to v-mi-lvl in frame d-pl-form .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

on entry of v-mi-lvl-name IN FRAME d-pl-form 
do:
  apply "entry" to v-mi-lvl in frame d-pl-form.
end .

on entry of v-mi-lvl IN FRAME d-pl-form 
do:
  hide v-mi-lvl-name in frame d-pl-form.
end .

on return of v-mi-lvl IN FRAME d-pl-form 
do:
  apply "leave" to v-mi-lvl IN FRAME d-pl-form .
end . 

on del of v-mi-lvl in frame d-pl-form
do :
  v-mi-lvl = 0 .
  v-mi-lvl:screen-value = "0" .
end . 
  
on leave of v-mi-lvl IN FRAME d-pl-form 
do:
  define variable v-old-val as character no-undo .
  
  v-old-val = string(v-mi-lvl) .
  if v-mi-lvl:screen-value = "?" then v-mi-lvl:screen-value = "0".
  find first lvl_sr-izmerenia no-lock where lvl_sr-izmerenia.node-code = integer(v-mi-lvl:screen-value) no-error .
  if not available lvl_sr-izmerenia
  then do :
    if v-mi-lvl:screen-value <> "?"
    and v-mi-lvl:screen-value <> "0"
    then do :
      message ("Не найдено средтсво измерения с кодом " + v-mi-lvl:screen-value) view-as alert-box .
      v-mi-lvl:screen-value = v-old-val .
    end .
/*    apply "choose" to b-mi-lvl in frame {&frame-name}.*/
    return .
  end .
  else do :
    if lvl_sr-izmerenia.sr-type-izm = 2
    then do :
      message "Средство измерения является Измерительной Системой!" view-as alert-box .
      v-mi-lvl:screen-value = v-old-val .
/*      apply "choose" to b-mi-lvl in frame {&frame-name}.*/
      return .
    end .
    if not lvl_sr-izmerenia.sr-level
    then do :
      message "Средство измерения НЕ измеряет уровень!" view-as alert-box .
      v-mi-lvl:screen-value = v-old-val .
/*      apply "choose" to b-mi-lvl in frame {&frame-name}.*/
      return .
    end .
  end .
  v-mi-lvl-name = lvl_sr-izmerenia.sr-model .
  display v-mi-lvl-name with frame {&frame-name}.
  enable v-mi-lvl-name with frame {&frame-name}.
  assign v-mi-lvl .
end .

&Scoped-define SELF-NAME b-mi-tmp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-mi-tmp d-pl-form
ON CHOOSE OF b-mi-tmp IN FRAME d-pl-form /* r-sr-izm */
DO:
  define variable v-node-code as integer no-undo.
  define variable v-sr-type-id as character no-undo.
  define variable v-sr-type-izm as character no-undo .
  v-node-code = 0 .
  
/*  if available dnst_sr-izmerenia                           */
/*  then do :                                                */
/*    v-sr-type-izm = string(dnst_sr-izmerenia.sr-type-izm) .*/
/*  end .                                                    */
/*  else do :                                                */
    v-sr-type-izm = "0,1" .
/*  end .*/
  run ref/sr-izm.w (input parparentproc ,
                    input "b-sel"       ,
                    input {&lookup}     ,
                    input v-sr-type-izm ,
                    input "tmp"         ,
                    input-output v-node-code,
                    output v-sr-type-id) no-error.
  if v-node-code <> 0 and v-node-code <> ? then do :
    v-mi-tmp = v-node-code.
    v-mi-tmp:screen-value = string(v-node-code).
    find first tmp_sr-izmerenia no-lock where tmp_sr-izmerenia.node-code = v-mi-tmp .
    apply "leave" to v-mi-tmp in frame d-pl-form .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

on entry of v-mi-tmp-name IN FRAME d-pl-form 
do:
  apply "entry" to v-mi-tmp in frame d-pl-form.
end .

on entry of v-mi-tmp IN FRAME d-pl-form 
do:
  hide v-mi-tmp-name in frame d-pl-form.
end .

on return of v-mi-tmp IN FRAME d-pl-form 
do:
  apply "leave" to v-mi-tmp IN FRAME d-pl-form .
end .

on del of v-mi-tmp in frame d-pl-form
do :
  v-mi-tmp = 0	 .
  v-mi-tmp:screen-value = "0" .
end .

on del of v-mi-dnst in frame d-pl-form
do :
  v-mi-dnst = 0	 .
  v-mi-dnst:screen-value = "0" .
end .

on del of v-mi-lvl in frame d-pl-form
do :
  v-mi-lvl = 0	 .
  v-mi-lvl:screen-value = "0" .
end .

on leave of v-mi-tmp IN FRAME d-pl-form 
do:
  define variable vlog as logical no-undo .
  define variable v-old-val as character no-undo .
  
  v-old-val = string(v-mi-tmp) .
  if v-mi-tmp:screen-value =  "?" then v-mi-tmp:screen-value = "0" .
  find first tmp_sr-izmerenia no-lock where tmp_sr-izmerenia.node-code = integer(v-mi-tmp:screen-value) no-error .
  if not available tmp_sr-izmerenia
  then do :
    if v-mi-tmp:screen-value <> "?"
    and v-mi-tmp:screen-value <> "0"
    then do :
      message ("Не найдено средтсво измерения с кодом " + v-mi-tmp:screen-value) view-as alert-box .
      v-mi-tmp:screen-value = v-old-val .
    end .
/*    apply "choose" to b-mi-tmp in frame {&frame-name}.*/
    return .
  end .
  else do :
    if tmp_sr-izmerenia.sr-type-izm = 2
    then do :
      message "Средство измерения является Измерительной Системой!" view-as alert-box .
      v-mi-tmp:screen-value = v-old-val .
/*      apply "choose" to b-mi-tmp in frame {&frame-name}.*/
      return .
    end .
    if not tmp_sr-izmerenia.sr-temperature
    then do :
      message "Средство измерения НЕ измеряет температуру!" view-as alert-box .
      v-mi-tmp:screen-value = v-old-val .
/*      apply "choose" to b-mi-tmp in frame {&frame-name}.*/
      return .
    end .
    if tmp_sr-izmerenia.sr-type-izm = 0
    and tmp_sr-izmerenia.sr-temperature
    and tmp_sr-izmerenia.sr-density
    and rvd-tmp:screen-value <> rvd-dnstv:screen-value
    then do :
      message "Бизнес-процессом не предусмотрено использование неравнозначных положений разрешения РВД по параметрам температура и плотность, " +
              "если автоматизированное СИ для одного из них предназначено для измерения обоих. " +
              "Сохранение неравнозначных положений разрешения РВД по параметрам температура и плотность запрещено. " +
              "Установить значение " + (if rvd-tmp:screen-value = "yes" then "'Да'" else "'Нет'") + " для РВД по плотности автоматически?"
      view-as alert-box question buttons yes-no update vlog .
      if vlog
      then do :
        rvd-dnstv:screen-value = rvd-tmp:screen-value .
      end .
    end .
  end .
  v-mi-tmp-name = tmp_sr-izmerenia.sr-model .
  display v-mi-tmp-name with frame {&frame-name}.
  enable v-mi-tmp-name with frame {&frame-name}.
  assign v-mi-tmp .
  
  if tmp_sr-izmerenia.sr-density
/*  and v-mi-tmp <> v-mi-dnst*/
  then do :
/*    message "Для измерения температуры выбрано дополнительное СИ " + v-mi-dnst-name + ". Установить данное СИ для измерения плотности автоматически?"*/
/*    view-as alert-box buttons yes-no update vlog .                                                                                                   */
/*    if vlog                                                                                                                                          */
/*    then do :                                                                                                                                        */
      v-mi-dnst = v-mi-tmp .
      v-mi-dnst:screen-value = v-mi-tmp:screen-value .
      v-mi-dnst-name = v-mi-tmp-name .
      find first dnst_sr-izmerenia no-lock where dnst_sr-izmerenia.node-code = v-mi-dnst .
      display v-mi-dnst-name with frame {&frame-name}.
      enable v-mi-dnst-name with frame {&frame-name}.
/*    end .*/
  end .
end .

&Scoped-define SELF-NAME b-com-tanks
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-com-tanks d-pl-form
ON CHOOSE OF b-com-tanks IN FRAME d-pl-form /* b-com-tanks */
DO:
  define variable place-list as character no-undo .
  define buffer cv_place for ub.place .
  define buffer cv_place-attr for ub.place-attr .
  define buffer buf_pl-gds for ub.pl-gds .
  define buffer cv_pl-gds for ub.pl-gds .
  
  find first buf_pl-gds no-lock where buf_pl-gds.obj-type = tt-place.obj-type
                                  and buf_pl-gds.obj-code = tt-place.obj-code
                                  and buf_pl-gds.pl-code = tt-place.pl-code
                                  no-error .
  if not available buf_pl-gds
  then do :
    return no-apply .
  end . 
  
  run ref/pl-list.w (
                 input parparentproc
                ,input "b-sel,b-mark"
                ,input p-obj-type
                ,input p-obj-code
                ,input {&g___object}
               , input-output place-list).
  if place-list = "cancel"
  then do :
    place-list = '' .
  end .
  if place-list <> '':U then do:
    com-tanks = "" .
    do ii = 1 to num-entries(place-list) :
      find first cv_place no-lock where recid(cv_place) = integer(entry(ii, place-list)) .
      if cv_place.obj-type = tt-place.obj-type
      and cv_place.obj-code = tt-place.obj-code
      and cv_place.pl-code = tt-place.pl-code
      then do :
        message "Нельзя связать резервуар с самим собой!" view-as alert-box .
        next .
      end .
      find first cv_pl-gds no-lock where cv_pl-gds.obj-type = cv_place.obj-type
                                     and cv_pl-gds.obj-code = cv_place.obj-code
                                     and cv_pl-gds.pl-code = cv_place.pl-code
                                     no-error .
      if not available cv_pl-gds
      then do :
        message "Нельзя связать резервуар с резервуаром, на котором нет товара!" view-as alert-box .
        next .
      end .
      if cv_pl-gds.gds-code <> buf_pl-gds.gds-code
      then do :
        message substitute("В сообщающихся резервуарах должен быть указан один товар! Связь с резервуаром №&1 не установлена!", cv_place.loc1) view-as alert-box .
        next .
      end .
      if cv_pl-gds.fact-qnty <> 0
      or cv_pl-gds.free-qnty <> 0  
      or cv_pl-gds.cli-free-qnty <> 0 
      or cv_pl-gds.cli-fact-qnty <> 0
      then do :
        message substitute("На резервуаре №&1 имеются расчетно-книжные остатки! Связь сообщающихся резервуаров не установлена!", cv_place.loc1) view-as alert-box .
        next .
      end .
      find first cv_place-attr no-lock where cv_place-attr.obj-type = cv_place.obj-type
                                         and cv_place-attr.obj-code = cv_place.obj-code
                                         and cv_place-attr.pl-code  = cv_place.pl-code
                                         and cv_place-attr.attr-code = {&place-com-tanks}
                                         no-error .
      if available cv_place-attr
      and cv_place-attr.attr-value > ""
      then do :
        message substitute("Резервуар №&1 уже привязан к резервуару №&2. Связь сообщающихся резервуаров не установлена!", cv_place.loc1, cv_place-attr.attr-value) view-as alert-box .
        next .
      end .
      find first cv_place-attr no-lock where cv_place-attr.obj-type = cv_place.obj-type
                                         and cv_place-attr.obj-code = cv_place.obj-code
                                         and cv_place-attr.pl-code  = cv_place.pl-code
                                         and cv_place-attr.attr-code = {&place-gate-valve}
                                         no-error .
      if available cv_place-attr
      and logical(cv_place-attr.attr-value)
      then do :
        message substitute("Резервуар №&1 имеет задвижку. Связь сообщающихся резервуаров не установлена!", cv_place.loc1) view-as alert-box .
        next .
      end .
      if can-find(first pl-pump-nozzle no-lock where pl-pump-nozzle.obj-type = cv_pl-gds.obj-type
                                                 and pl-pump-nozzle.obj-code = cv_pl-gds.obj-code
                                                 and pl-pump-nozzle.pl-code  = cv_pl-gds.pl-code )
      then do :
        message "В сообщающихся резервуарах должна быть одна связка Резервуар – ТРК – Пистолеты по объекту! Связь сообщающихся резервуаров не установлена!" view-as alert-box .
        next .
      end .
      com-tanks = com-tanks + cv_place.loc1 + "," .
    end .
    com-tanks = trim(com-tanks, ",") .
    display com-tanks with frame {&frame-name} .
    
    if com-tanks > ""
    then do :
      is-main = yes .
      v-is-main = "Главный" .
      display v-is-main with frame {&frame-name} .
      if v-not-gas-place
      then do :
        enable t-auto-gate-valve with frame {&frame-name} .
      end .
    end .
  end.
  v-com-vessel-changed = yes .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-gate-valve-tanks
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-gate-valve-tanks d-pl-form
ON CHOOSE OF b-gate-valve-tanks IN FRAME d-pl-form /* b-com-tanks */
DO:
  define variable place-list as character no-undo .
  define buffer gv_place for ub.place .
  define buffer gv_place-attr for ub.place-attr .
  define buffer buf_pl-gds for ub.pl-gds .
  define buffer gv_pl-gds for ub.pl-gds .
  
  find first buf_pl-gds no-lock where buf_pl-gds.obj-type = tt-place.obj-type
                                  and buf_pl-gds.obj-code = tt-place.obj-code
                                  and buf_pl-gds.pl-code = tt-place.pl-code
                                  no-error .
  if not available buf_pl-gds
  then do :
    return no-apply .
  end . 
  
  run ref/pl-list.w (
                 input parparentproc
                ,input "b-sel,b-mark"
                ,input p-obj-type
                ,input p-obj-code
                ,input {&g___object}
               , input-output place-list).
  if place-list = "cancel"
  then do :
    place-list = '' .
  end .
  if place-list <> '':U then do:
    gate-valve-tanks = "" .
    do ii = 1 to num-entries(place-list) :
      find first gv_place no-lock where recid(gv_place) = integer(entry(ii, place-list)) .
      if gv_place.obj-type = tt-place.obj-type
      and gv_place.obj-code = tt-place.obj-code
      and gv_place.pl-code = tt-place.pl-code
      then do :
        message "Нельзя связать резервуар с самим собой!" view-as alert-box .
        next .
      end .
      find first gv_pl-gds no-lock where gv_pl-gds.obj-type = gv_place.obj-type
                                     and gv_pl-gds.obj-code = gv_place.obj-code
                                     and gv_pl-gds.pl-code = gv_place.pl-code
                                     no-error .
      if not available gv_pl-gds
      then do :
        message "Нельзя связать резервуар с резервуаром, на котором нет товара!" view-as alert-box .
        next .
      end .
      if gv_pl-gds.gds-code <> buf_pl-gds.gds-code
      then do :
        message substitute("В резервуарах должен быть указан один товар! Связь с резервуаром №&1 не установлена!", gv_place.loc1) view-as alert-box .
        next .
      end .
      find first gv_place-attr no-lock where gv_place-attr.obj-type = gv_place.obj-type
                                         and gv_place-attr.obj-code = gv_place.obj-code
                                         and gv_place-attr.pl-code  = gv_place.pl-code
                                         and gv_place-attr.attr-code = {&place-gate-valve-tanks}
                                         no-error .
      if available gv_place-attr
      and gv_place-attr.attr-value > ""
      then do :
        message substitute("Резервуар №&1 уже привязан к резервуару №&2. Связь задвижкой не установлена!", gv_place.loc1, gv_place-attr.attr-value) view-as alert-box .
        next .
      end .
      find first gv_place-attr no-lock where gv_place-attr.obj-type = gv_place.obj-type
                                         and gv_place-attr.obj-code = gv_place.obj-code
                                         and gv_place-attr.pl-code  = gv_place.pl-code
                                         and gv_place-attr.attr-code = {&place-com-tanks}
                                         no-error .
      if available gv_place-attr
      and gv_place-attr.attr-value > ""
      then do :
        message substitute("Резервуар №&1 сообщающийся с резервуаром №&2. Связь задвижкой не установлена!", gv_place.loc1, gv_place-attr.attr-value) view-as alert-box .
        next .
      end .
      gate-valve-tanks = gate-valve-tanks + gv_place.loc1 + "," .
    end .
    gate-valve-tanks = trim(gate-valve-tanks, ",") .
    display gate-valve-tanks with frame {&frame-name} .
  end.
  v-gate-valve-tanks-changed = yes .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK d-pl-form 


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
  THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.
{ gbl/app_help.i }
/* Add Trigger to equate WINDOW-CLOSE to END-ERROR                      */
ON WINDOW-CLOSE OF FRAME {&FRAME-NAME} do :
  define variable vlog as logical no-undo .
  message "Все введенные данные будут утеряны. Вы уверены, что хотите отказаться от внесенных изменений?"
  view-as alert-box question buttons yes-no update vlog .
  if not vlog then return no-apply .
  p-rep-rec = ?.
  APPLY "END-ERROR":U TO SELF.
end .

on "F2" ANYWHERE do:
  define variable vlog as logical no-undo .
  message "Все введенные данные будут утеряны. Вы уверены, что хотите отказаться от внесенных изменений?"
  view-as alert-box question buttons yes-no update vlog .
  if not vlog then return no-apply .
  p-rep-rec = ?.
end .

on "ESC" ANYWHERE do:
  define variable vlog as logical no-undo .
  message "Все введенные данные будут утеряны. Вы уверены, что хотите отказаться от внесенных изменений?"
  view-as alert-box question buttons yes-no update vlog .
  if not vlog then return no-apply .
  p-rep-rec = ?.
end .

{ ref/tabhndmv.i v-tab-order underline-tb }
{ gbl/rethndmv.i v-tab-order underline-tb "APPLY 'CHOOSE' TO b-exit in frame {&frame-name}." }


MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
  ON STOP    UNDO MAIN-BLOCK,  LEAVE MAIN-BLOCK
  ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  if p-mode <> {&update}
    and p-mode <> {&add-def}
    and p-mode <> {&lookup} then 
  do:
    message
      vss-workfile vss-revision vss-description skip
      "Неверный параметр вызова p-mode" p-mode
      view-as alert-box ERROR.
    return error.
  end.

  case p-mode:
    when {&update} then do:
      find first locked_place exclusive-lock
        where recid (locked_place) = p-rep-rec
        no-error .
    end.
    when {&lookup} then do:
      find first locked_place no-lock
        where recid( locked_place ) = p-rep-rec
        no-error .
      if not available locked_place then do:
        find first locked_place no-lock
          where locked_place.obj-type = p-obj-type
            and locked_place.obj-code = p-obj-code
            and locked_place.pl-code  = p-pl-code
          no-error .
      end.
    end.
  end case.
  if not available locked_place
    and  p-mode <> {&add-def}
    then 
  do:
    message
      vss-workfile vss-revision vss-description skip
      substitute ("Не найдена запись СКЛАДСКОГО МЕСТА &1 &2&3", p-pl-code, p-obj-type, p-obj-code ) skip
      view-as alert-box error .
    undo, return error.
  end.

  for each tt-place:
    delete tt-place.
  end.
  create tt-place.
  if p-mode = {&add-def} then 
  do:
    assign
      tt-place.obj-type = p-obj-type
      tt-place.obj-code = p-obj-code
      .
  end.
  else 
  do:
    buffer-copy locked_place to tt-place.
  end.
  v-rvd-is-meas-on = tt-place.is-meas .
  if p-mode <> {&lookup} then 
  do :
    if ( tt-place.max-qnty = 0
      or tt-place.max-qnty = ?
      )
      then 
    do:
      assign
        tt-place.chk-max-qnty = false
        .
    end.
/*    else                                                                                  */
/*    do:                                                                                   */
/*      assign                                                                              */
/*        tt-place.chk-max-qnty = (if locked_place.whole-send-news = 0 then true else false)*/
/*        .                                                                                 */
/*    end.                                                                                  */
  end.
  ii = 0.
  do ii = 1 to num-entries({&list-place-attr},','):
    v-code = entry(ii,{&list-place-attr}) .
    run placelib_get-attr  ( input v-code
      ,input p-obj-code
      ,input p-obj-type
      ,input locked_place.pl-code
      ,output v-value
      ,output v-ok      ) no-error.
    case v-code :
      when {&place-type} then do :
        if v-ok then place-type = integer(v-value) .
      end.
      when {&place-SI} then do :
        if v-ok
        then do :
          place-si = integer(v-value) .
          v-main-mi-old = place-si .
          if v-main-mi-old = ? then v-main-mi-old = 0 .
        end .
      end.
      when {&place-diameter} then do :
        if v-ok then place-diameter = decimal(v-value) .
      end.
      when {&dead-balance} then do :
        if v-ok then dead-balance = decimal(v-value) .
      end.
      when {&water-level} then do :
        if v-ok then water-level = integer(v-value) .
      end.
/*      when {&place-ratio-error} then do :                  */
/*        if v-ok then place-ratio-error = decimal(v-value) .*/
/*      end.                                                 */
      when {&place-dens-prov} then do :
        if v-ok then dens-prov = decimal(v-value) .
      end.
      when {&place-virtual} then do :
        if v-ok then t-place-virtual = logical(v-value) .
      end.
      when {&place-twice-code} then do: 
        if v-ok then place-twice-code = v-value .
      end.
/*      when {&place-sert-urov} then do :              */
/*        if v-ok then t-sert-urov = logical(v-value) .*/
/*      end.                                           */
      when {&place-local} then do :
        if v-ok then place-locat = integer(v-value) .
      end.  
      when {&place-error-mass} then do :
        if v-value = "" then 
        do:
          v-value = "0.15" .
          run placelib_write-attr  (input v-code
            ,input p-obj-code
            ,input p-obj-type
            ,input locked_place.pl-code
            ,input v-value
            ,output v-ok      ) no-error.
        end.  
        if v-ok then error-mass = decimal(v-value) . 
      end.  
      when {&place-asi-sertif} then do :
        if v-value = "" then v-value = "no" .
        if v-ok then t-asi-srtif = logical(v-value) .
      end.              
      when {&place-rvd-dnsty} then do :
        if v-ok
        then do :
          rvd-dnstv = logical(v-value) .
          v-rvd-dnsty-on = rvd-dnstv .
        end .
      end.
      when {&place-rvd-lvl} then do :
        if v-ok
        then do :
          rvd-lvl = logical(v-value) .
          v-rvd-lvl-on = rvd-lvl .
        end.
      end.        
      when {&place-rvd-tmp} then do :
        if v-ok
        then do :
          rvd-tmp = logical(v-value) .
          v-rvd-temp-on = rvd-tmp .
        end .
      end.  
      when {&place-si-dens} then do :
        if v-ok
        then do :
          v-mi-dnst = integer(v-value) .
          v-dnst-mi-old = v-mi-dnst .
          if v-dnst-mi-old = ? then v-dnst-mi-old = 0 .
          find first dnst_sr-izmerenia no-lock where dnst_sr-izmerenia.node-code = v-mi-dnst no-error .
        end .
      end.
      when {&place-si-level} then do :
        if v-ok
        then do :
          v-mi-lvl = integer(v-value) .
          v-lvl-mi-old = v-mi-lvl .
          if v-lvl-mi-old = ? then v-lvl-mi-old = 0 .
          find first lvl_sr-izmerenia no-lock where lvl_sr-izmerenia.node-code = v-mi-lvl no-error .
        end .
      end.
      when {&place-si-temp} then do :
        if v-ok
        then do :
          v-mi-tmp = integer(v-value) .
          v-tmp-mi-old = v-mi-tmp .
          if v-tmp-mi-old = ? then v-tmp-mi-old = 0 .
          find first tmp_sr-izmerenia no-lock where tmp_sr-izmerenia.node-code = v-mi-tmp no-error .
        end .
      end.
      when {&place-passp-num} then do: 
        if v-ok then place-passp-num = v-value .
      end.  
      when {&place-passp-type} then do: 
        if v-ok then place-passp-type = v-value .
      end.
      when {&place-dead-high} then do: 
        if v-ok then place-dead-high = decimal(v-value) .
      end.  
      when {&place-temp-coef} then do: 
        if v-ok then place-temp-coef = decimal(v-value) .
      end.  
      when {&place-ponton} then do :
        if v-ok then t-ponton = logical(v-value) .
      end.
      when {&place-ponton-mass} then do: 
        if v-ok then ponton-mass = decimal(v-value) no-error .
      end.  
      when {&place-ponton-height} then do: 
        if v-ok then ponton-height = decimal(v-value) no-error .
      end.  
      when {&place-com-vessel} then do :
        if v-ok then t-com-vessel = logical(v-value) .
      end.
      when {&place-com-tanks} then do: 
        if v-ok then com-tanks = v-value no-error .
      end.  
      when {&place-is-main} then do: 
        if v-ok then is-main = logical(v-value) no-error .
      end.        
      when {&place-gate-valve} then do :
        if v-ok then t-gate-valve = logical(v-value) .
      end.
      when {&place-gate-valve-tanks} then do: 
        if v-ok then gate-valve-tanks = v-value no-error .
      end. 
      when {&place-auto-gate-valve} then do :
        if v-ok
        then do :
          t-auto-gate-valve = logical(v-value) .
          v-old-auto-gate-valve = t-auto-gate-valve .
        end .
      end.
    end case.
  end.
  run Myenable in this-procedure .
  wait-for go of frame {&frame-name}.
end.
run disable_UI in this-procedure .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI d-pl-form  _DEFAULT-DISABLE
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
  HIDE FRAME d-pl-form.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI d-pl-form  _DEFAULT-ENABLE
PROCEDURE enable_UI :
/*------------------------------------------------------------------------------
  Purpose:     ENABLE the User Interface
  Parameters:  <none>
  Notes:       Here we display/view/enable the widgets in the
               user-interface.  In addition, OPEN all queries
               associated with each FRAME and BROWSE.
               These statements here are based on the "Other 
               Settings" section of the widget Property Sheets.
------------------------------------------------------------------------------*/
  DISPLAY t-place-virtual t-asi-srtif rvd-dnstv rvd-lvl rvd-tmp place-type 
          place-locat error-mass place-si dead-balance water-level place-diameter 
          dens-prov place-twice-code v-mi-dnst
          v-mi-lvl v-mi-tmp place-passp-num place-passp-type
          place-dead-high place-temp-coef
          t-ponton ponton-mass ponton-height
      WITH FRAME d-pl-form.
  IF AVAILABLE tt-place THEN 
    DISPLAY tt-place.loc1 tt-place.loc2 tt-place.loc3 tt-place.loc4 
          tt-place.pl-name tt-place.is-meas tt-place.pl-code tt-place.issue-year 
          tt-place.start-date tt-place.add-qnty tt-place.max-qnty tt-place.PS tt-place.chk-max-qnty 
      WITH FRAME d-pl-form.
  ENABLE b-exit b-quit B-hist b-help tt-place.loc1 tt-place.loc2 tt-place.loc3 
         tt-place.loc4 tt-place.pl-name t-place-virtual tt-place.is-meas 
         rvd-dnstv rvd-lvl rvd-tmp tt-place.issue-year place-type 
         tt-place.start-date place-locat tt-place.add-qnty error-mass 
         tt-place.max-qnty place-si r-sr-izm dead-balance water-level place-diameter 
         dens-prov place-twice-code tt-place.chk-max-qnty 
         tt-place.PS place-passp-num place-passp-type place-dead-high place-temp-coef
         t-ponton ponton-mass ponton-height
      WITH FRAME d-pl-form.
  {&OPEN-BROWSERS-IN-QUERY-d-pl-form}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Myenable d-pl-form 
PROCEDURE Myenable :
/* */
  run enable_UI in this-procedure .
  assign
    v-tab-order = "loc1,loc2,loc3,loc4,pl-name,is-meas,"
                  + "issue-year,start-date,add-qnty,max-qnty,"
                  + "ps,place-type,place-SI,r-sr-izm,v-mi-dnst,b-mi-dnst,v-mi-lvl,b-mi-lvl,v-mi-tmp,b-mi-tmp,"
                  + "place-diameter,dead-balance,place-dead-high,place-temp-coef,dens-prov,t-place-virtual,place-twice-code,t-sert-urov,place-passp-num,place-passp-type".
  if p-mode = {&lookup} then do:
    disable
      all
      with frame {&frame-name} .
    hide
      b-exit
      in frame {&frame-name} .
    assign
      b-quit:label  = "&Выход"
      b-quit:column = 1
      .
  end.
  if p-mode = {&add-def} then 
  do:
    hide
      tt-place.pl-code
      in frame {&frame-name} .
  end.
  assign
    frame {&frame-name}:title = substitute("Складское место &1 на объекте : &2&3 &4", tt-place.pl-code, p-obj-type, p-obj-code, p-mode)
    .
  if tt-place.is-meas then do:
    enable t-asi-srtif with frame {&frame-name} .
  end.  
  enable v-mi-dnst b-mi-dnst with frame {&frame-name} .
  enable v-mi-lvl b-mi-lvl with frame {&frame-name} .
  enable v-mi-tmp b-mi-tmp with frame {&frame-name} .
  
  for first dop_sr-izmerenia no-lock where dop_sr-izmerenia.node-code = v-mi-lvl :
    v-mi-lvl-name = dop_sr-izmerenia.sr-model .
    display v-mi-lvl-name with frame {&frame-name}.
  end .
  if p-mode <> {&lookup} then enable v-mi-lvl-name with frame {&frame-name}.
  if v-mi-lvl = 0 then v-mi-lvl = ? .
  
  for first dop_sr-izmerenia no-lock where dop_sr-izmerenia.node-code = v-mi-dnst :
    v-mi-dnst-name = dop_sr-izmerenia.sr-model .
    display v-mi-dnst-name with frame {&frame-name}.
  end .
  if p-mode <> {&lookup} then enable v-mi-dnst-name with frame {&frame-name}.
  if v-mi-dnst = 0 then v-mi-dnst = ? .
  
  for first dop_sr-izmerenia no-lock where dop_sr-izmerenia.node-code = v-mi-tmp :
    v-mi-tmp-name = dop_sr-izmerenia.sr-model .
    display v-mi-tmp-name with frame {&frame-name}.
  end .
  if p-mode <> {&lookup} then enable v-mi-tmp-name with frame {&frame-name}.
  if v-mi-tmp = 0 then v-mi-tmp = ? .
  
  for first sr-izmerenia no-lock where sr-izmerenia.node-code = place-si :
    place-si-name = sr-izmerenia.sr-model .
    display place-si-name with frame {&frame-name}.
  end .
  if p-mode <> {&lookup} then enable place-si-name with frame {&frame-name}.
  if place-si = 0 then place-si = ? .
  
  apply "value-changed" to place-type .
  
  hide t-com-vessel com-tanks b-com-tanks v-is-main gate-valve-tanks t-gate-valve b-gate-valve-tanks t-auto-gate-valve in frame {&frame-name} .
  
  if p-mode = {&update}
  then do :
    disable
      place-locat
      tt-place.max-qnty
      dead-balance
      place-si
      place-si-name
      r-sr-izm
      place-diameter
      place-dead-high
      place-temp-coef
      dens-prov
    with frame {&frame-name} .
    if place-type = 1
    then do :
      disable
        t-ponton
        ponton-mass
        ponton-height
      with frame {&frame-name} .
    end .
  end .
  
  run check-sug-NP-par .
  
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Myenable d-pl-form 
PROCEDURE check-sug-NP-par :
  define buffer buf_pl-gds for ub.pl-gds .
  define variable c-value as character no-undo .
  define variable c-type  as character no-undo .
  
  v-not-gas-place = no .
  v-sug-place = no .
  
  find first buf_pl-gds no-lock where buf_pl-gds.obj-type = tt-place.obj-type
                                  and buf_pl-gds.obj-code = tt-place.obj-code
                                  and buf_pl-gds.pl-code = tt-place.pl-code
                                  no-error .
  if not available buf_pl-gds
  then do :
    return .
  end . 
  &scop proc-name gds-attr-value
  {&run_proc_attr-lib}
    (input  buf_pl-gds.gds-code
    ,input  {&attr-fuel-type}
    ,output c-value
    ,output c-type)
  no-error.
  if c-value = 'lgas':U /* СУГ */
  then do :
    v-sug-place = yes .
    
    display t-com-vessel com-tanks b-com-tanks v-is-main gate-valve-tanks t-gate-valve b-gate-valve-tanks with frame {&frame-name}.
    enable t-com-vessel t-gate-valve with frame {&frame-name}.
    if t-com-vessel
    then do :
      if is-main then v-is-main = "Главный" . else v-is-main = "Не главный" .
      display v-is-main with frame {&frame-name}.
      enable com-tanks b-com-tanks with frame {&frame-name}.
      com-tanks:read-only in frame {&frame-name} = yes.
      if com-tanks > "" then disable b-com-tanks with frame {&frame-name}.
      disable t-gate-valve b-gate-valve-tanks with frame {&frame-name}.
    end .
    if t-gate-valve
    then do :
      enable b-gate-valve-tanks with frame {&frame-name}.
      disable t-com-vessel b-com-tanks with frame {&frame-name}.
    end .
  end .
  else
  if c-value = 'metan':U
  or c-value = 'propan':U
  then do :
  end .
  else do : /* Бензин и дизель */
    v-not-gas-place = yes .
  
    display t-com-vessel com-tanks b-com-tanks v-is-main with frame {&frame-name}.
    enable t-com-vessel with frame {&frame-name}.
    if t-com-vessel
    then do :
      if is-main then v-is-main = "Главный" . else v-is-main = "Не главный" .
      display v-is-main with frame {&frame-name}.
      enable com-tanks b-com-tanks with frame {&frame-name}.
      com-tanks:read-only in frame {&frame-name} = yes.
      if com-tanks > "" then disable b-com-tanks with frame {&frame-name}.
      
      display t-auto-gate-valve with frame {&frame-name}.
      if is-main
      then do :
        enable t-auto-gate-valve with frame {&frame-name}.
      end .
      else do :
        disable t-auto-gate-valve with frame {&frame-name}.
      end .
    end .
  end .
                     
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

