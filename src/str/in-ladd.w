&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Экран просмотра дополнительной информации по приемке топлива

Автор: Уханов Дмитрий Юрьевич
Дата создания: 07/23/07
Author: Dmitry Ukhanov
Creation date: 07/23/07

Автор1: Суслов Алексей Юрьевич
Дата создания1: 09/12/05

*/
using ibs.th.str.*.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Экран просмотра дополнительной информации по приемке топлива".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/showinf.i }
{ str/lib-calc.i }
/*{ ref/sr-izm.i sr-izmerenia ds}*/
/*{ ref/sr-izm.i " " proc }*/
{ gbl/ptrlprop.i def}
{ gbl/cur-time.i }
{ ref/gds-attr.i }
{ gbl/godendo.i}
{ gbl/sel-date.i}


   
/* Parameters Definitions ---                                            */
define input        parameter parparentproc       as   handle                no-undo .
define input        parameter p-mode              as   character             no-undo .
define input        parameter p-doc-code          like ub.trn-doc.doc-code   no-undo .
define input        parameter p-gds-code          like ub.goods.gds-code     no-undo .
define input-output parameter infoSectionTotal as class InfoSectionsTotal    no-undo .
define       output parameter p-was-setting       as   logical               no-undo initial no .

define variable v-section-names as character no-undo.
define variable v-page-current as integer no-undo.
define variable ii as integer no-undo.

define variable rdcvalue      as char initial ? no-undo.
define variable rdctype       as char initial ? no-undo.
define variable v-log as logical no-undo .
define variable v-autoent-obj-type as character no-undo.
define variable v-autoent-obj-code as integer no-undo.
define variable v-last-gds-code like ub.goods.gds-code no-undo .
define variable v-fuel-type as character no-undo.
define variable v-gds-attr-value as character no-undo .
define variable v-gds-attr-type  as character no-undo .
define variable v-sr-type as integer no-undo.  
define variable rdc-dnstvalue as character no-undo.
define variable rdc-dnsttype  as character no-undo.
define variable temp-for-pomi           as integer no-undo.
define buffer buf_clob-bind for ub.clob-bind.
define variable v-page as integer no-undo.
define variable iTemp as integer no-undo.
define variable maxSec as integer no-undo init 6.
define stream outstream.

&SCOP max-labels 20
&SCOP tab-height 25

  DEFINE VARIABLE up-image             AS HANDLE NO-UNDO.  
  DEFINE VARIABLE tab-type             AS INT NO-UNDO. /* 1,2 */
  DEFINE VARIABLE char-hdl             AS CHARACTER NO-UNDO.
  DEFINE VARIABLE page-label           AS HANDLE EXTENT {&max-labels} NO-UNDO.
  DEFINE VARIABLE image-hdl            AS HANDLE EXTENT {&max-labels} NO-UNDO.
  DEFINE VARIABLE page-enabled         AS LOGICAL EXTENT {&max-labels} NO-UNDO.
  
  DEFINE VARIABLE pos-x             AS integer NO-UNDO init 5.
  DEFINE VARIABLE pos-y             AS integer NO-UNDO init 30.

  DEF VAR width-tab-values    AS INT INIT [110,72] EXTENT 2 NO-UNDO.
  DEFINE VARIABLE        number-of-pages    AS INTEGER   NO-UNDO.

/* Local Variable Definitions ---                                       */
{ str/valddnst.i def }

define buffer buf_goods for ub.goods .
define buffer buf_parts for ub.parts.
define buffer buf_doc-line for ub.doc-line.
define buffer buf_doc-pl for ub.doc-pl.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS Rect-Main Rect-Bottom Rect-Left Rect-Right ~
Rect-Top RECT-3 RECT-1 RECT-4 RECT-5 RECT-6 RECT-8 RECT-7 b-save b-quit ~
b-del-sec b-help f-sec-num f-ttn-temp f-doc-qnty f-doc-dens f-acc-ship ~
f-cli-qnty f-size f-car-vol f-num-passport f-norm-doc f-certif-fuel ~
f-validity-certif f-a-b-tarir f-mouth f-tank-water f-tank-temp ~
f-tank-density f-dens-temp f-EU-weight f-list-tank r-list-tank f-loss-norm ~
f-num-plotn f-date-pov-plotn f-date-start f-hour-start f-min-start ~
f-date-end f-hour-end f-min-end f-tests f-num-print-prob f-kol-prob ~
f-hour-prob f-min-prob f-date-prob 
&Scoped-Define DISPLAYED-OBJECTS f-sec-num f-ttn-temp f-doc-qnty f-doc-dens ~
f-acc-ship f-cli-qnty f-size f-car-vol f-num-passport f-text1 f-norm-doc ~
f-text2 f-certif-fuel f-text3 f-validity-certif f-a-b-tarir f-mouth ~
f-tank-water f-tank-vol f-tank-temp f-tank-density f-dens-temp f-EU-weight ~
f-list-tank f-loss-norm f-place-si f-num-plotn f-date-pov-plotn ~
f-tank-weight f-tank-density-pomi f-acc-weight f-tank-vol-pomi f-date-start ~
f-hour-start f-min-start f-date-end f-hour-end f-min-end f-tests ~
f-num-print-prob f-kol-prob f-hour-prob f-min-prob f-date-prob ~
f-place-si-name 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */
&Scoped-define List-1 RECT-3 RECT-1 RECT-4 RECT-5 RECT-6 RECT-8 RECT-7 ~
f-sec-num f-ttn-temp f-doc-qnty f-doc-dens f-cli-qnty f-size f-car-vol ~
f-num-passport f-text1 f-norm-doc f-text2 f-certif-fuel f-text3 ~
f-validity-certif b-copy-pass f-a-b-tarir f-mouth f-tank-water f-tank-vol ~
f-tank-temp f-tank-density f-dens-temp f-list-tank r-list-tank f-place-si ~
r-sr-izm f-num-plotn f-date-pov-plotn b-copy-iz b-choose-date-pov-plotn ~
f-passport-plotn f-tank-weight f-tank-density-pomi b-calc f-acc-weight ~
f-tank-vol-pomi f-date-start f-hour-start f-min-start f-date-end f-hour-end ~
f-min-end f-tests f-num-print-prob f-kol-prob f-hour-prob f-min-prob ~
f-date-prob f-place-si-name f-EU-weight f-acc-ship f-loss-norm
&Scoped-define List-2 f-car-vol-total f-tank-weight-total f-tank-vol-total ~
f-doc-qnty-total 

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-calc 
     LABEL "Рассчитать" 
     SIZE 15 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-choose-date-pov-plotn 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "b-choose-date-pov-plotn" 
     SIZE 3 BY 1.

DEFINE BUTTON b-copy-iz 
     LABEL "Копировать" 
     SIZE 10.75 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-copy-pass 
     LABEL "Копировать в секции" 
     SIZE 20 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-del-sec 
     LABEL "Удалить секцию" 
     SIZE 15 BY 1.

DEFINE BUTTON b-help 
     LABEL "&Помощь" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-quit AUTO-END-KEY 
     LABEL "&Отмена" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-save AUTO-GO 
     LABEL "&Сохранить" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON r-list-tank 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "r-list-tank" 
     SIZE 3 BY 1.

DEFINE BUTTON r-sr-izm 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "r-sr-izm" 
     SIZE 3 BY 1.

DEFINE VARIABLE f-a-b-tarir AS DECIMAL FORMAT "->>>,>>9.99":U INITIAL 0 
     LABEL "Уровень цистерны относительно тарировочной планки" 
     VIEW-AS FILL-IN 
     SIZE 14.5 BY 1 NO-UNDO.

DEFINE VARIABLE f-acc-ship AS DECIMAL FORMAT "->>>,>>9.99":U INITIAL 0 
     LABEL "Погр.изм.пост." 
     VIEW-AS FILL-IN 
     SIZE 8.5 BY 1 NO-UNDO.

DEFINE VARIABLE f-acc-weight AS DECIMAL FORMAT "->>>,>>>,>>>,>>9.999":U INITIAL ? 
     LABEL "Погр. изм. массы" 
     VIEW-AS FILL-IN 
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE f-car-vol AS DECIMAL FORMAT "->>>,>>>,>>>,>>9.999":U INITIAL 0 
     LABEL "Объем по паспорту в литрах" 
     VIEW-AS FILL-IN 
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE f-car-vol-total AS DECIMAL FORMAT "->>>,>>>,>>>,>>9.999":U INITIAL 0 
     LABEL "Объем по паспорту в литрах" 
     VIEW-AS FILL-IN 
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE f-certif-fuel AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 92.63 BY 1 NO-UNDO.

DEFINE VARIABLE f-cli-qnty AS DECIMAL FORMAT "->>>,>>>,>>>,>>9.999":U INITIAL 0 
     LABEL "   Масса по док." 
     VIEW-AS FILL-IN 
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE f-date-end AS DATE FORMAT "99/99/99":U 
     LABEL " Дата конца слива" 
     VIEW-AS FILL-IN 
     SIZE 10 BY 1 NO-UNDO.

DEFINE VARIABLE f-date-pov-plotn AS DATE FORMAT "99/99/99":U 
     LABEL "Дата поверки" 
     VIEW-AS FILL-IN 
     SIZE 10.75 BY 1 NO-UNDO.

DEFINE VARIABLE f-date-prob AS DATE FORMAT "99/99/99":U 
     LABEL "Дата отбора пробы" 
     VIEW-AS FILL-IN 
     SIZE 10 BY 1 NO-UNDO.

DEFINE VARIABLE f-date-start AS DATE FORMAT "99/99/99":U 
     LABEL "Дата начала слива" 
     VIEW-AS FILL-IN 
     SIZE 10 BY 1 NO-UNDO.

DEFINE VARIABLE f-dens-temp AS DECIMAL FORMAT "->9":U INITIAL ? 
     LABEL "Температура замера плотности" 
     VIEW-AS FILL-IN 
     SIZE 14.5 BY 1 NO-UNDO.

DEFINE VARIABLE f-doc-dens AS DECIMAL FORMAT ">>9.9999999999":U INITIAL 0 
     LABEL "Плотность по док." 
     VIEW-AS FILL-IN 
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE f-doc-qnty AS DECIMAL FORMAT "->>>,>>>,>>>,>>9.999":U INITIAL 0 
     LABEL "  Кол-во по док." 
     VIEW-AS FILL-IN 
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE f-doc-qnty-total AS DECIMAL FORMAT "->>>,>>>,>>>,>>9.999":U INITIAL 0 
     LABEL "Количество по документу" 
     VIEW-AS FILL-IN 
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE f-EU-weight AS DECIMAL FORMAT "->>>,>>>,>>>,>>9.999":U INITIAL 0 
     LABEL "          Масса ЕУ" 
     VIEW-AS FILL-IN 
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE f-hour-end AS INTEGER FORMAT "99":U INITIAL ? 
     LABEL " Время конца слива" 
     VIEW-AS FILL-IN 
     SIZE 3 BY 1 NO-UNDO.

DEFINE VARIABLE f-hour-prob AS INTEGER FORMAT "99":U INITIAL ? 
     LABEL "Время отбора пробы" 
     VIEW-AS FILL-IN 
     SIZE 3 BY 1 NO-UNDO.

DEFINE VARIABLE f-hour-start AS INTEGER FORMAT "99":U INITIAL ? 
     LABEL "Время начала слива" 
     VIEW-AS FILL-IN 
     SIZE 3 BY 1 NO-UNDO.

DEFINE VARIABLE f-kol-prob AS DECIMAL FORMAT "->>>,>>>,>>>,>>9.99":U INITIAL 0 
     LABEL "Кол-во пробы (л)" 
     VIEW-AS FILL-IN 
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE f-list-tank AS CHARACTER FORMAT "X(256)":U 
     LABEL "Резервуары" 
     VIEW-AS FILL-IN 
     SIZE 42.5 BY 1 NO-UNDO.

DEFINE VARIABLE f-loss-norm AS DECIMAL FORMAT "->>>,>>>,>>>,>>9.999":U INITIAL 0 
     LABEL "Тех. потери по нормам, кг" 
     VIEW-AS FILL-IN 
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE f-min-end AS INTEGER FORMAT "99":U INITIAL ? 
     VIEW-AS FILL-IN 
     SIZE 3 BY 1 NO-UNDO.

DEFINE VARIABLE f-min-prob AS INTEGER FORMAT "99":U INITIAL ? 
     VIEW-AS FILL-IN 
     SIZE 3 BY 1 NO-UNDO.

DEFINE VARIABLE f-min-start AS INTEGER FORMAT "99":U INITIAL ? 
     VIEW-AS FILL-IN 
     SIZE 3 BY 1 NO-UNDO.

DEFINE VARIABLE f-mouth AS DECIMAL FORMAT "->>>,>>>,>>>,>>9.99":U INITIAL 0 
     LABEL "   Объем горловины" 
     VIEW-AS FILL-IN 
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE f-norm-doc AS CHARACTER FORMAT "X(256)":U 
     LABEL "из паспорта качества" 
     VIEW-AS FILL-IN 
     SIZE 70.5 BY 1 NO-UNDO.

DEFINE VARIABLE f-num-passport AS CHARACTER FORMAT "X(256)":U 
     LABEL "Паспорт качества №" 
     VIEW-AS FILL-IN 
     SIZE 72.5 BY .88 NO-UNDO.

DEFINE VARIABLE f-num-plotn AS CHARACTER FORMAT "X(256)":U 
     LABEL "Номер" 
     VIEW-AS FILL-IN 
     SIZE 85.75 BY 1 NO-UNDO.

DEFINE VARIABLE f-num-print-prob AS CHARACTER FORMAT "X(256)":U 
     LABEL "Номер печати (пробы)" 
     VIEW-AS FILL-IN 
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE f-passport-plotn AS CHARACTER FORMAT "X(256)":U 
     LABEL "Паспорт плотномера №" 
     VIEW-AS FILL-IN 
     SIZE 20.75 BY 1 NO-UNDO.

DEFINE VARIABLE f-place-si AS INTEGER FORMAT ">>>,>>9":U INITIAL 0 
     LABEL "Средство измерения" 
     VIEW-AS FILL-IN 
     SIZE 5.63 BY 1 NO-UNDO.

DEFINE VARIABLE f-place-si-name AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 28.88 BY 1 NO-UNDO.

DEFINE VARIABLE f-sec-num AS CHARACTER FORMAT "x(256)":U 
     LABEL "Номер секции" 
     VIEW-AS FILL-IN 
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE f-size AS CHARACTER FORMAT "x(8)" INITIAL "0" 
     LABEL "Размер горловины" 
     VIEW-AS FILL-IN 
     SIZE 14 BY 1 TOOLTIP "Длина/Ширина" NO-UNDO.

DEFINE VARIABLE f-tank-density AS DECIMAL FORMAT ">>9.9999":U INITIAL ? 
     LABEL " Плотность топлива" 
     VIEW-AS FILL-IN 
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE f-tank-density-pomi AS DECIMAL FORMAT ">>9.9999":U INITIAL ? 
     LABEL "    Плотность приведенная" 
     VIEW-AS FILL-IN 
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE f-tank-temp AS DECIMAL FORMAT "->9":U INITIAL ? 
     LABEL "Температура замера объема" 
     VIEW-AS FILL-IN 
     SIZE 14.5 BY 1 NO-UNDO.

DEFINE VARIABLE f-tank-vol AS DECIMAL FORMAT "->>>,>>>,>>>,>>9.999":U INITIAL 0 
     LABEL "     Объем топлива" 
     VIEW-AS FILL-IN 
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE f-tank-vol-pomi AS DECIMAL FORMAT "->>>,>>>,>>>,>>9.999":U INITIAL ? 
     LABEL "Объем топлива приведенный" 
     VIEW-AS FILL-IN 
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE f-tank-vol-total AS DECIMAL FORMAT "->>>,>>>,>>>,>>9.999":U INITIAL 0 
     LABEL "Объем топлива" 
     VIEW-AS FILL-IN 
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE f-tank-water AS DECIMAL FORMAT "->>>,>>>,>>>,>>9.99":U INITIAL 0 
     LABEL "Объем воды" 
     VIEW-AS FILL-IN 
     SIZE 14.5 BY 1 NO-UNDO.

DEFINE VARIABLE f-tank-weight AS DECIMAL FORMAT "->>>,>>>,>>>,>>9.999":U INITIAL ? 
     LABEL "   Масса топлива" 
     VIEW-AS FILL-IN 
     SIZE 14 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE f-tank-weight-total AS DECIMAL FORMAT "->>>,>>>,>>>,>>9.999":U INITIAL 0 
     LABEL "Вес топлива" 
     VIEW-AS FILL-IN 
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE f-tests AS CHARACTER FORMAT "X(256)":U 
     LABEL "Номер пробы" 
     VIEW-AS FILL-IN 
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE f-text1 AS CHARACTER FORMAT "X(256)":U INITIAL "Нормативный документ завода-изготовителя (ГОСТ, ТУ на марку моторного топлива)" 
     VIEW-AS FILL-IN 
     SIZE 92.63 BY 1 NO-UNDO.

DEFINE VARIABLE f-text2 AS CHARACTER FORMAT "X(256)":U INITIAL "Сертификат соответствия завода-изготовителя (на марку моторного топлива) № :" 
     VIEW-AS FILL-IN 
     SIZE 92.63 BY 1 NO-UNDO.

DEFINE VARIABLE f-text3 AS CHARACTER FORMAT "X(256)":U INITIAL "Срок действия сертификата соответствия завода-изготовителя (на марку моторного" 
     VIEW-AS FILL-IN 
     SIZE 92.63 BY 1 NO-UNDO.

DEFINE VARIABLE f-ttn-temp AS DECIMAL FORMAT "->9":U INITIAL ? 
     LABEL "Температура по ТТН" 
     VIEW-AS FILL-IN 
     SIZE 8.5 BY 1 NO-UNDO.

DEFINE VARIABLE f-validity-certif AS CHARACTER FORMAT "X(256)":U 
     LABEL "топлива) из паспорта качества" 
     VIEW-AS FILL-IN 
     SIZE 17 BY 1 NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 94 BY 3.75
     BGCOLOR 17 .

DEFINE RECTANGLE RECT-3
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 94 BY 3.58
     BGCOLOR 17 .

DEFINE RECTANGLE RECT-4
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 94 BY 6.83
     BGCOLOR 17 .

DEFINE RECTANGLE RECT-5
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 94 BY 2.5
     BGCOLOR 17 .

DEFINE RECTANGLE RECT-6
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 94 BY 7.42
     BGCOLOR 17 .

DEFINE RECTANGLE RECT-7
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 94 BY 3.5
     BGCOLOR 17 .

DEFINE RECTANGLE RECT-8
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 94 BY 2.58
     BGCOLOR 17 .

DEFINE RECTANGLE Rect-Bottom
     EDGE-PIXELS 0    
     SIZE 33.63 BY .17
     BGCOLOR 7 .

DEFINE RECTANGLE Rect-Left
     EDGE-PIXELS 0    
     SIZE .63 BY 4.25
     BGCOLOR 15 .

DEFINE RECTANGLE Rect-Main
     EDGE-PIXELS 1 GRAPHIC-EDGE    
     SIZE 33.75 BY 4.33
     BGCOLOR 8 FGCOLOR 0 .

DEFINE RECTANGLE Rect-Right
     EDGE-PIXELS 0    
     SIZE .63 BY 4.33
     BGCOLOR 7 .

DEFINE RECTANGLE Rect-Top
     EDGE-PIXELS 0    
     SIZE 33.63 BY .17
     BGCOLOR 15 .


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-save AT ROW 1 COL 2
     b-quit AT ROW 1 COL 12
     b-del-sec AT ROW 1 COL 21.88 WIDGET-ID 88
     b-help AT ROW 1 COL 87.38
     f-sec-num AT ROW 3.75 COL 16.25 COLON-ALIGNED WIDGET-ID 84
     f-car-vol-total AT ROW 3.75 COL 31.13 COLON-ALIGNED WIDGET-ID 90
     f-ttn-temp AT ROW 3.79 COL 53.5 COLON-ALIGNED WIDGET-ID 132
     f-doc-qnty AT ROW 3.79 COL 80.5 COLON-ALIGNED WIDGET-ID 86
     f-doc-dens AT ROW 4.96 COL 21.25 COLON-ALIGNED WIDGET-ID 106
     f-tank-weight-total AT ROW 4.96 COL 31.13 COLON-ALIGNED WIDGET-ID 92
     f-acc-ship AT ROW 4.96 COL 53.5 COLON-ALIGNED WIDGET-ID 140
     f-cli-qnty AT ROW 4.96 COL 80.5 COLON-ALIGNED WIDGET-ID 108
     f-size AT ROW 6.13 COL 80.5 COLON-ALIGNED WIDGET-ID 20
     f-car-vol AT ROW 6.17 COL 30.25 COLON-ALIGNED
     f-tank-vol-total AT ROW 6.17 COL 31.13 COLON-ALIGNED WIDGET-ID 94
     f-doc-qnty-total AT ROW 7.29 COL 31.13 COLON-ALIGNED WIDGET-ID 98
     f-num-passport AT ROW 7.38 COL 22 COLON-ALIGNED WIDGET-ID 36
     f-text1 AT ROW 8.29 COL 1.88 COLON-ALIGNED NO-LABEL WIDGET-ID 100 DISABLE-AUTO-ZAP 
     f-norm-doc AT ROW 9.33 COL 4 WIDGET-ID 38
     f-text2 AT ROW 10.38 COL 1.88 COLON-ALIGNED NO-LABEL WIDGET-ID 102 DISABLE-AUTO-ZAP 
     f-certif-fuel AT ROW 11.46 COL 3.88 NO-LABEL WIDGET-ID 44
     f-text3 AT ROW 12.42 COL 1.88 COLON-ALIGNED NO-LABEL WIDGET-ID 104 DISABLE-AUTO-ZAP 
     f-validity-certif AT ROW 13.5 COL 4 WIDGET-ID 50
     b-copy-pass AT ROW 13.5 COL 76.75 WIDGET-ID 130
     f-a-b-tarir AT ROW 14.83 COL 80 COLON-ALIGNED WIDGET-ID 2
     f-mouth AT ROW 15.92 COL 22 COLON-ALIGNED
     f-tank-water AT ROW 15.92 COL 80 COLON-ALIGNED
     f-tank-vol AT ROW 17 COL 22 COLON-ALIGNED
     f-tank-temp AT ROW 17 COL 80 COLON-ALIGNED
     f-tank-density AT ROW 18.08 COL 22 COLON-ALIGNED
     f-dens-temp AT ROW 18.08 COL 80 COLON-ALIGNED WIDGET-ID 26
     f-EU-weight AT ROW 19.17 COL 22 COLON-ALIGNED WIDGET-ID 136
     f-list-tank AT ROW 19.21 COL 48.5 COLON-ALIGNED WIDGET-ID 124
     r-list-tank AT ROW 19.21 COL 93.25 WIDGET-ID 126
     f-loss-norm AT ROW 20.25 COL 29 COLON-ALIGNED WIDGET-ID 138
     f-place-si AT ROW 21.92 COL 22 COLON-ALIGNED WIDGET-ID 16
     r-sr-izm AT ROW 21.92 COL 28.5 WIDGET-ID 18
     f-num-plotn AT ROW 23.04 COL 9 COLON-ALIGNED WIDGET-ID 76
     f-date-pov-plotn AT ROW 24.13 COL 16.13 COLON-ALIGNED WIDGET-ID 64
     b-copy-iz AT ROW 24.13 COL 86 WIDGET-ID 22
     b-choose-date-pov-plotn AT ROW 24.17 COL 29.13 WIDGET-ID 72
     f-passport-plotn AT ROW 24.17 COL 52.63 COLON-ALIGNED WIDGET-ID 68
     f-tank-weight AT ROW 25.5 COL 63.25 COLON-ALIGNED
     f-tank-density-pomi AT ROW 25.54 COL 29 COLON-ALIGNED WIDGET-ID 24
     b-calc AT ROW 26.17 COL 81.63 WIDGET-ID 80
     f-acc-weight AT ROW 26.71 COL 63.25 COLON-ALIGNED WIDGET-ID 134
     f-tank-vol-pomi AT ROW 26.75 COL 30 COLON-ALIGNED WIDGET-ID 28
     f-date-start AT ROW 28.21 COL 21 COLON-ALIGNED
     f-hour-start AT ROW 28.21 COL 88 COLON-ALIGNED
     f-min-start AT ROW 28.21 COL 91.63 COLON-ALIGNED NO-LABEL
     f-date-end AT ROW 29.29 COL 21 COLON-ALIGNED
     f-hour-end AT ROW 29.29 COL 88 COLON-ALIGNED
     f-min-end AT ROW 29.29 COL 91.63 COLON-ALIGNED NO-LABEL
     f-tests AT ROW 30.83 COL 20.88 COLON-ALIGNED WIDGET-ID 118
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         DEFAULT-BUTTON b-save CANCEL-BUTTON b-quit.

/* DEFINE FRAME statement is approaching 4K Bytes.  Breaking it up   */
DEFINE FRAME Dialog-Frame
     f-num-print-prob AT ROW 30.83 COL 80.5 COLON-ALIGNED WIDGET-ID 120
     f-kol-prob AT ROW 31.83 COL 20.88 COLON-ALIGNED WIDGET-ID 122
     f-hour-prob AT ROW 31.96 COL 87.75 COLON-ALIGNED WIDGET-ID 114
     f-min-prob AT ROW 31.96 COL 91.38 COLON-ALIGNED NO-LABEL WIDGET-ID 116
     f-date-prob AT ROW 32.83 COL 20.88 COLON-ALIGNED WIDGET-ID 112
     f-place-si-name AT ROW 21.92 COL 30.13 COLON-ALIGNED NO-LABEL WIDGET-ID 14
     Rect-Main AT ROW 8.17 COL 5.75
     Rect-Bottom AT ROW 8.08 COL 3.5
     Rect-Left AT ROW 1.75 COL 1.25
     Rect-Right AT ROW 1.88 COL 34.25
     Rect-Top AT ROW 1.71 COL 1.25
     RECT-3 AT ROW 21.75 COL 3.5
     RECT-1 AT ROW 3.54 COL 3.5
     RECT-4 AT ROW 14.67 COL 3.5 WIDGET-ID 30
     RECT-5 AT ROW 28 COL 3.5 WIDGET-ID 32
     RECT-6 AT ROW 7.25 COL 3.5 WIDGET-ID 34
     RECT-8 AT ROW 25.38 COL 3.5 WIDGET-ID 82
     RECT-7 AT ROW 30.58 COL 3.5 WIDGET-ID 110
     SPACE(1.87) SKIP(0.58)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Дополнительная информация по приемке топлива"
         DEFAULT-BUTTON b-save CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR BUTTON b-calc IN FRAME Dialog-Frame
   NO-ENABLE 1                                                          */
/* SETTINGS FOR BUTTON b-choose-date-pov-plotn IN FRAME Dialog-Frame
   NO-ENABLE 1                                                          */
ASSIGN 
       b-choose-date-pov-plotn:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR BUTTON b-copy-iz IN FRAME Dialog-Frame
   NO-ENABLE 1                                                          */
/* SETTINGS FOR BUTTON b-copy-pass IN FRAME Dialog-Frame
   NO-ENABLE 1                                                          */
/* SETTINGS FOR FILL-IN f-a-b-tarir IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR FILL-IN f-acc-weight IN FRAME Dialog-Frame
   NO-ENABLE 1                                                          */
/* SETTINGS FOR FILL-IN f-car-vol IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR FILL-IN f-car-vol-total IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE 2                                               */
/* SETTINGS FOR FILL-IN f-certif-fuel IN FRAME Dialog-Frame
   ALIGN-L 1                                                            */
/* SETTINGS FOR FILL-IN f-cli-qnty IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR FILL-IN f-date-end IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR FILL-IN f-date-pov-plotn IN FRAME Dialog-Frame
   1                                                                    */
ASSIGN 
       f-date-pov-plotn:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN f-date-prob IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR FILL-IN f-date-start IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR FILL-IN f-dens-temp IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR FILL-IN f-doc-dens IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR FILL-IN f-doc-qnty IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR FILL-IN f-doc-qnty-total IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE 2                                               */
/* SETTINGS FOR FILL-IN f-hour-end IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR FILL-IN f-hour-prob IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR FILL-IN f-hour-start IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR FILL-IN f-kol-prob IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR FILL-IN f-list-tank IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR FILL-IN f-min-end IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR FILL-IN f-min-prob IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR FILL-IN f-min-start IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR FILL-IN f-mouth IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR FILL-IN f-norm-doc IN FRAME Dialog-Frame
   ALIGN-L 1                                                            */
/* SETTINGS FOR FILL-IN f-num-passport IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR FILL-IN f-num-plotn IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR FILL-IN f-num-print-prob IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR FILL-IN f-passport-plotn IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE 1                                               */
ASSIGN 
       f-passport-plotn:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN f-place-si IN FRAME Dialog-Frame
   NO-ENABLE 1                                                          */
/* SETTINGS FOR FILL-IN f-place-si-name IN FRAME Dialog-Frame
   NO-ENABLE 1                                                          */
/* SETTINGS FOR FILL-IN f-sec-num IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR FILL-IN f-size IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR FILL-IN f-tank-density IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR FILL-IN f-tank-density-pomi IN FRAME Dialog-Frame
   NO-ENABLE 1                                                          */
/* SETTINGS FOR FILL-IN f-tank-temp IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR FILL-IN f-tank-vol IN FRAME Dialog-Frame
   NO-ENABLE 1                                                          */
/* SETTINGS FOR FILL-IN f-tank-vol-pomi IN FRAME Dialog-Frame
   NO-ENABLE 1                                                          */
/* SETTINGS FOR FILL-IN f-tank-vol-total IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE 2                                               */
/* SETTINGS FOR FILL-IN f-tank-water IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR FILL-IN f-tank-weight IN FRAME Dialog-Frame
   NO-ENABLE 1                                                          */
/* SETTINGS FOR FILL-IN f-tank-weight-total IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE 2                                               */
/* SETTINGS FOR FILL-IN f-tests IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR FILL-IN f-text1 IN FRAME Dialog-Frame
   NO-ENABLE 1                                                          */
ASSIGN 
       f-text1:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN f-text2 IN FRAME Dialog-Frame
   NO-ENABLE 1                                                          */
ASSIGN 
       f-text2:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN f-text3 IN FRAME Dialog-Frame
   NO-ENABLE 1                                                          */
ASSIGN 
       f-text3:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN f-ttn-temp IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR FILL-IN f-validity-certif IN FRAME Dialog-Frame
   ALIGN-L 1                                                            */
/* SETTINGS FOR BUTTON r-list-tank IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR BUTTON r-sr-izm IN FRAME Dialog-Frame
   NO-ENABLE 1                                                          */
/* SETTINGS FOR RECTANGLE RECT-1 IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR RECTANGLE RECT-3 IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR RECTANGLE RECT-4 IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR RECTANGLE RECT-5 IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR RECTANGLE RECT-6 IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR RECTANGLE RECT-7 IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR RECTANGLE RECT-8 IN FRAME Dialog-Frame
   1                                                                    */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON go OF FRAME Dialog-Frame /* Дополнительная информация по приемке топлива */
do: 

  assign frame {&frame-name} 
    f-sec-num f-tests f-doc-qnty f-doc-dens f-cli-qnty f-car-vol f-size
    f-num-passport f-norm-doc f-text2 f-certif-fuel f-validity-certif
    f-a-b-tarir f-mouth f-tank-water f-tank-temp f-tank-density f-dens-temp
    f-num-plotn f-date-pov-plotn f-date-start f-hour-start f-min-start
    f-date-end f-hour-end f-min-end 
    f-doc-qnty f-doc-dens f-cli-qnty
    f-num-print-prob f-kol-prob f-date-prob f-hour-prob f-min-prob f-list-tank f-ttn-temp f-acc-ship f-EU-weight
  .
  if v-page-current <= infoSectionTotal:SectionNum 
  then do:
    run check-page no-error.
    if error-status:error then do:
      return no-apply.
    end.
    run save-page.
  end.
  if p-mode <> {&add-def} then infoSectionTotal:SaveDB().  
  assign
    p-was-setting = yes
  .
  
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON window-close OF FRAME Dialog-Frame /* Дополнительная информация по приемке топлива */
do:
  apply "END-ERROR":U to self.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-calc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-calc Dialog-Frame
ON choose OF b-calc IN FRAME Dialog-Frame /* Рассчитать */
do:
  define variable ToolType                as integer no-undo.
  define variable DeltaAbs_R              as decimal no-undo.
  define variable DeltaAbs_Tv             as decimal no-undo.
  define variable DeltaAbs_Tr             as decimal no-undo.
  define variable NeckType                as integer no-undo.
  define variable Dgor                    as decimal no-undo.
  define variable NeckWidth               as decimal no-undo.
  define variable NeckHeight              as decimal no-undo.
  define variable error-string            as character no-undo.
  define variable v-mm as com-handle.
  define variable v-proc as character no-undo.
/*  define buffer buf_clob-bind    for ub.clob-bind.*/
  define buffer buf_sr-izmerenia    for ub.sr-izmerenia .
  run save-page.
  assign
  f-car-vol
  f-tank-vol
  f-a-b-tarir
  f-size
  f-tank-temp
  f-tank-density
  f-dens-temp
  f-place-si
  .


  case rdc-dnstvalue:
    when "pomi-rn" then do:
      _trpomi :
        do on error undo, return no-apply :
  

          /*данные по средству измерения резервуара для ПО МИ*/
        find first buf_sr-izmerenia no-lock where buf_sr-izmerenia.node-code = f-place-si no-error.
        if not available buf_sr-izmerenia then do :
          message
            substitute( 'Не найдено средство измерения с кодом &1', f-place-si ) skip
          view-as alert-box error.
          undo _trpomi, return no-apply  .
        end.
        else do :
          assign
            ToolType               = buf_sr-izmerenia.sr-type-id
            DeltaAbs_R             = buf_sr-izmerenia.sr-abs-err-dens
            DeltaAbs_Tv            = buf_sr-izmerenia.sr-abs-err-temp-vol
            DeltaAbs_Tr            = buf_sr-izmerenia.sr-abs-err-temp-dens
            .
        end.
        /*..........................................*/
        v-proc = "Rosneft.MethodOfMetering31" .
  
        release object v-mm no-error.
        v-mm = ?.
  
        create value("Rosneft.MethodOfMetering31") v-mm no-error.
        if error-status:error
        or not VALID-HANDLE(v-mm)
        then do:
          release object v-mm no-error.
          v-mm = ?.
          message
            substitute( 'Не удается подключиться к COM-серверу библиотеки для работы с ПО МИ ' ) skip
          view-as alert-box error.
          undo _trpomi, return no-apply .
        end.
        else do :
          if f-car-vol = ? or f-car-vol = 0 then do :
            message
              "Заполнены не все поля, необходимые " skip
              "для работы библиотеки ПО МИ"         skip
              "Введите Объем по паспорту в литрах"  skip
            view-as alert-box error.
            apply "entry" to f-car-vol in frame {&frame-name} .
            undo _trpomi, return no-apply  .
          end.
          
          if f-a-b-tarir = ? then do :
            message
              "Заполнены не все поля, необходимые " skip
              "для работы библиотеки ПО МИ"         skip
              "Введите Уровень цистерны относительно тарировочной планки"  skip
            view-as alert-box error.
            apply "entry" to f-a-b-tarir in frame {&frame-name} .
            undo _trpomi, return no-apply  .
          end.
            assign
            f-size              = string (decimal (f-size))
            f-size:screen-value = string (decimal (f-size)) 
            no-error.
          if error-status:error then 
          do:
            assign
              NeckType = 1
              NeckWidth = decimal (entry (1,f-size, "/")) 
              NeckHeight = decimal (entry (2,f-size, "/"))
              Dgor = 0
              no-error.
          end.
          else do: 
          assign 
            NeckType = 0 
            Dgor = decimal (f-size).
          end.  
          if f-size = ? or f-size = "0" then do :
            message
              "Заполнены не все поля, необходимые " skip
              "для работы библиотеки ПО МИ"         skip
              "Введите Внутренний диаметр горловины"  skip
            view-as alert-box error.
            apply "entry" to f-size in frame {&frame-name} .
            undo _trpomi, return no-apply  .
          end.
          if f-tank-temp = ? then do :
            message
              "Заполнены не все поля, необходимые " skip
              "для работы библиотеки ПО МИ"         skip
              "Введите Температуру"  skip
            view-as alert-box error.
            apply "entry" to f-tank-temp in frame {&frame-name} .
            undo _trpomi, return no-apply  .
          end.
          if f-tank-density = ? or f-tank-density = 0 then do :
            message
              "Заполнены не все поля, необходимые " skip
              "для работы библиотеки ПО МИ"         skip
              "Введите Плотность топлива для ПО МИ"  skip
            view-as alert-box error.
            apply "entry" to f-tank-density in frame {&frame-name} .
            undo _trpomi, return no-apply  .
          end.
          assign
            v-mm:V_real                 = f-car-vol
            v-mm:DeltaH                 = f-a-b-tarir
            v-mm:Dgor                   = Dgor
            v-mm:NeckType               = NeckType 
            v-mm:NeckWidth              = NeckWidth  
            v-mm:NeckHeight             = NeckHeight  
            v-mm:Tv                     = f-tank-temp
            v-mm:Tr                     = f-dens-temp
            v-mm:R                      = ( f-tank-density * 1000 )
            v-mm:Tcy                    = temp-for-pomi
            v-mm:ToolType               = ToolType
            v-mm:A_Reservoir            = 0.0000125
            v-mm:DeltaOtn_V             = 0.4
            v-mm:DeltaAbs_R             = DeltaAbs_R
            v-mm:DeltaAbs_Tv            = DeltaAbs_Tv
            v-mm:DeltaAbs_Tr            = DeltaAbs_Tr
          .
          v-mm:Exec() .
          output stream outstream to value ("pomi.log") append.
          put stream outstream
            {&new-line}
            "-----------------------------------------------"
            {&new-line}
                                       now                     skip
            'Номер документа:'         p-doc-code              skip
            'Секция:'                  v-section-names         skip
            'Процедура'                v-proc                  skip
            'V_real                 =' f-car-vol               skip
            'DeltaH                 =' f-a-b-tarir             skip
            'Dgor                   =' Dgor                    skip
            'NeckType               =' NeckType                skip 
            'NeckWidth              =' NeckWidth               skip
            'NeckHeight             =' NeckHeight              skip
            'Tv                     =' f-tank-temp             skip
            'Tr                     =' f-dens-temp             skip
            'R                      =' ( f-tank-density * 1000 ) skip
            'Tcy                    =' temp-for-pomi           skip
            'ToolType               =' ToolType                skip
            'A_Reservoir            =' string (0.0000125)      skip
            'DeltaOtn_V             =' 0.4                     skip
            'DeltaAbs_R             =' DeltaAbs_R              skip
            'DeltaAbs_Tv            =' DeltaAbs_Tv             skip
            'DeltaAbs_Tr            =' DeltaAbs_Tr             skip
            'Vcy                    =' v-mm:Vcy               skip 
            'Rcy                    =' v-mm:Rcy               skip
            'V                      =' v-mm:V                 skip
            'CTL_base_alt           =' v-mm:CTL_base_alt      skip 
            'CPL_base_alt           =' v-mm:CPL_base_alt      skip 
            'CTPL_base_alt          =' v-mm:CTPL_base_alt     skip
            'Fp_base_alt            =' v-mm:Fp_base_alt       skip
            'CTL_obs_base           =' v-mm:CTL_obs_base      skip
            'CPL_obs_base           =' v-mm:CPL_obs_base      skip
            'CTPL_obs_base          =' v-mm:CTPL_obs_base     skip
            'Fp_obs_base            =' v-mm:Fp_obs_base       skip
            'Rv                     =' v-mm:Rv                skip
            'DeltaOtn_Vcy           =' v-mm:DeltaOtn_Vcy      skip 
            'M                      =' v-mm:M                 skip
            'Mcy                    =' v-mm:Mcy               skip
            'DeltaOtn_M             =' v-mm:DeltaOtn_M        skip
          .
          output stream outstream close.
          if v-mm:Result <> 0 then do :
            error-string = v-mm:ResultDetail .
            output stream outstream to value ("pomi.log") append.
              put stream outstream error-string format "x(1024)" skip.
            output stream outstream close.
            release object v-mm no-error.
            v-mm = ?.
            message
              substitute('Ошибка работы библиотеки ПО МИ &1',error-string) skip
            view-as alert-box error.
            undo _trpomi, return no-apply  .
          end.
          else do :
            assign
              f-tank-density-pomi    = decimal(v-mm:Rcy) / 1000
              f-tank-vol-pomi        = v-mm:Vcy 
              f-tank-weight     = v-mm:Mcy
              f-acc-weight = round (v-mm:DeltaOtn_M, 3)
            .
            display
              f-tank-density-pomi
              f-tank-vol-pomi
              f-tank-weight
              f-acc-weight
            with frame {&frame-name}.
            output stream outstream to value ("pomi.log") append.
              put stream outstream
              "v-mm:Rcy" f-tank-density-pomi      skip
              "v-mm:Vcy" f-tank-vol-pomi          skip
              "v-mm:Mcy" f-tank-weight            skip 
              "v-mm:v-mm:DeltaOtn_M" f-acc-weight skip .
            output stream outstream close.
            release object v-mm no-error.
            v-mm = ?.
          end.
        end.
      end.
    end.
    when "th" then do:
      run gds-attr-value in this-procedure
        (  input p-gds-code
        ,  input {&attr-fuel-type}
        , output v-gds-attr-value
        , output v-gds-attr-type
        ) no-error .
      if not error-status:error and lookup (v-gds-attr-value, "petrol,diesel-sum,diesel-wint") > 0 then do:
        assign
          v-fuel-type = v-gds-attr-value.
        run str/rdcdnst.p (input f-tank-density * 1000
                      ,input f-dens-temp
                      ,input f-tank-vol
                      ,input f-tank-temp
                      ,input v-fuel-type
                      ,output f-tank-density-pomi 
                      ,output f-tank-vol-pomi)
        no-error.
        if not error-status:error then do:
          assign
            f-tank-weight     = f-tank-density-pomi * f-tank-vol-pomi
          .
          display
            f-tank-vol-pomi
            f-tank-density-pomi
            f-tank-weight
          with frame {&frame-name}.
        end.
        else do:
          message
            substitute('Ошибка при рассчете приведенных значений плотности и объема: &1', return-value) 
          view-as alert-box error.
          undo, return no-apply  .
        end.
      end.
      else do:
        message
          substitute('Ошибка определения типа топлива &1 или не верный тип товлива &2', return-value, v-gds-attr-value) 
        view-as alert-box error.
        undo, return no-apply  .
      end.
    end.
    
  end case.

  if rdc-dnstvalue = "pomi-rn" then do :

  end.
  
  if infoSectionTotal:IsRNAlgo
  then do:
    infoSectionTotal:InfoSectionCurr:TankWeight = f-tank-weight.
    def var v-m as decimal no-undo.
    infoSectionTotal:RNAlgo(v-page-current, output v-m, yes).
    f-EU-weight:screen-value = string (infoSectionTotal:InfoSectionCurr:NaturalLoss).
    f-loss-norm:screen-value = string (infoSectionTotal:InfoSectionCurr:TPNorm).
  end.
  
  
  enable
  f-tank-density
  with frame {&frame-name}.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-choose-date-pov-plotn
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-choose-date-pov-plotn Dialog-Frame
ON choose OF b-choose-date-pov-plotn IN FRAME Dialog-Frame /* b-choose-date-pov-plotn */
do:
  { gbl/stdbtn.i }

  run sel-date in this-procedure
    ( input f-date-pov-plotn :handle
    , input "Дата поверки плотномера"
    ) .
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-copy-iz
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-copy-iz Dialog-Frame
ON choose OF b-copy-iz IN FRAME Dialog-Frame /* Копировать */
do:

    define variable v-place-si as integer no-undo.
    define variable v-num-plotn as character no-undo.
    define variable v-date-pov-plotn as date no-undo.
    define variable v-passport-plotn as character no-undo.
    define buffer buf_sr-izmerenia for ub.sr-izmerenia .    
    
    run str/in-copy-iz.w
      ( input        parParentProc
       ,input        p-mode
       ,input        p-gds-code
       ,output       v-place-si
       ,output       v-num-plotn
       ,output       v-passport-plotn
       ,output       v-date-pov-plotn       
      ) no-error.
  
  infoSectionTotal:GetInfoSectionProp(v-page-current):NumPlotn = v-num-plotn.
  infoSectionTotal:GetInfoSectionProp(v-page-current):PlaceSi = v-place-si.
  infoSectionTotal:GetInfoSectionProp(v-page-current):DatePovPlotn = v-date-pov-plotn.
  infoSectionTotal:GetInfoSectionProp(v-page-current):PassportPlotn = v-passport-plotn.


  f-place-si:screen-value = string(infoSectionTotal:GetInfoSectionProp(v-page-current):PlaceSi).
    find first buf_sr-izmerenia where buf_sr-izmerenia.node-code = integer (f-place-si:screen-value) no-error.
    if available buf_sr-izmerenia then do:
      assign
        f-place-si-name:screen-value = buf_sr-izmerenia.sr-model
        v-sr-type = buf_sr-izmerenia.sr-type-id.
    end.
    else
      assign
        f-place-si-name:screen-value = ""
        v-sr-type = 0.

  apply "leave" to f-place-si.

  
  f-num-plotn:SCREEN-VALUE = string(infoSectionTotal:GetInfoSectionProp(v-page-current):NumPlotn).
  f-passport-plotn:SCREEN-VALUE = string(infoSectionTotal:GetInfoSectionProp(v-page-current):PassportPlotn).
  f-date-pov-plotn:SCREEN-VALUE = string(infoSectionTotal:GetInfoSectionProp(v-page-current):DatePovPlotn).
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-copy-pass
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-copy-pass Dialog-Frame
ON choose OF b-copy-pass IN FRAME Dialog-Frame /* Копировать в секции */
do:

  do ii = 1 to infoSectionTotal:SectionNum:

    
    
    if ii = v-page-current 
      then next.      
    infoSectionTotal:GetInfoSectionProp(ii):NumPassport = f-num-passport:screen-value.
    infoSectionTotal:GetInfoSectionProp(ii):NormDoc = f-norm-doc:screen-value.
    infoSectionTotal:GetInfoSectionProp(ii):CertifFuel = f-certif-fuel:screen-value.
    infoSectionTotal:GetInfoSectionProp(ii):ValidityCertif = f-validity-certif:screen-value.  
  
  
  end.
  
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-del-sec
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-del-sec Dialog-Frame
ON choose OF b-del-sec IN FRAME Dialog-Frame /* Удалить секцию */
do:
  { gbl/stdbtn.i }
  if infoSectionTotal:SectionNum = 1
  then do:
    message "Нельзя удалять одну единственную секцию." view-as alert-box.
    return.
  end.
  infoSectionTotal:DeleteSection(v-page-current).
  v-page-current = if v-page-current = 1 then 1 else v-page-current - 1.
  v-section-names = "".
  do ii = 1 to infoSectionTotal:SectionNum:
    v-section-names = v-section-names + "|" + 'Секция - ' + if infoSectionTotal:GetInfoSectionProp(ii):SectionName = "" then string (ii) else infoSectionTotal:GetInfoSectionProp(ii):SectionName.
  end.
  v-section-names = trim (v-section-names, "|") + "|         +" + if infoSectionTotal:FlagTrn then "|Сумма" else "".
  run initialize-folder (v-section-names).
  run show-current-page(input v-page-current).
  run initialize-section.

end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-save
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-save Dialog-Frame
ON choose OF b-save IN FRAME Dialog-Frame /* Сохранить */
do:
  { gbl/stdbtn.i }
  run check-data no-error.
  if error-status:error 
    then return no-apply .
  apply "LEAVE":U to f-car-vol      in frame {&FRAME-NAME} . 
  apply "LEAVE":U to f-tank-density in frame {&FRAME-NAME} .

/*  apply "GO":U to frame {&FRAME-NAME} .*/
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-a-b-tarir
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-a-b-tarir Dialog-Frame
ON leave OF f-a-b-tarir IN FRAME Dialog-Frame /* Уровень цистерны относительно тарировочной планки */
do:

    run calc-weight-vol in this-procedure.

end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-acc-weight
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-acc-weight Dialog-Frame
ON return OF f-acc-weight IN FRAME Dialog-Frame /* Погр. изм. массы */
do:
      apply "entry" to b-save in frame {&frame-name}.
return no-apply.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-car-vol
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-car-vol Dialog-Frame
ON leave OF f-car-vol IN FRAME Dialog-Frame /* Объем по паспорту в литрах */
do:

    run calc-weight-vol in this-procedure.

end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-car-vol Dialog-Frame
ON return OF f-car-vol IN FRAME Dialog-Frame /* Объем по паспорту в литрах */
do:
  apply "entry" to f-tests in frame {&frame-name}.
  return no-apply.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-car-vol Dialog-Frame
ON value-changed OF f-car-vol IN FRAME Dialog-Frame /* Объем по паспорту в литрах */
do:
  assign
    f-tank-vol-pomi = ?
  .
  
  f-tank-vol-pomi:screen-value in frame {&frame-name} = ?.
  
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-car-vol-total
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-car-vol-total Dialog-Frame
ON leave OF f-car-vol-total IN FRAME Dialog-Frame /* Объем по паспорту в литрах */
do:

    run calc-weight-vol in this-procedure.

end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-car-vol-total Dialog-Frame
ON return OF f-car-vol-total IN FRAME Dialog-Frame /* Объем по паспорту в литрах */
do:
  apply "entry" to f-tests in frame {&frame-name}.
  return no-apply.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-car-vol-total Dialog-Frame
ON value-changed OF f-car-vol-total IN FRAME Dialog-Frame /* Объем по паспорту в литрах */
do:
  assign
    f-tank-vol-pomi = ?
  .
  display
    f-tank-vol-pomi with frame {&frame-name}
  .
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-certif-fuel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-certif-fuel Dialog-Frame
ON return OF f-certif-fuel IN FRAME Dialog-Frame
do:

return no-apply.



end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-cli-qnty
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-cli-qnty Dialog-Frame
ON leave OF f-cli-qnty IN FRAME Dialog-Frame /*    Масса по док. */
do:

    run calc-doc in this-procedure.

end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-date-end
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-date-end Dialog-Frame
ON return OF f-date-end IN FRAME Dialog-Frame /*  Дата конца слива */
do:
    apply "entry" to f-hour-end in frame {&frame-name}.
return no-apply.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-date-prob
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-date-prob Dialog-Frame
ON return OF f-date-prob IN FRAME Dialog-Frame /* Дата отбора пробы */
do:
  apply "entry" to f-hour-prob in frame {&frame-name}.
return no-apply.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-date-start
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-date-start Dialog-Frame
ON return OF f-date-start IN FRAME Dialog-Frame /* Дата начала слива */
do:
  apply "entry" to f-hour-start in frame {&frame-name}.
return no-apply.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-dens-temp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-dens-temp Dialog-Frame
ON return OF f-dens-temp IN FRAME Dialog-Frame /* Температура замера плотности */
do:
  return no-apply.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-dens-temp Dialog-Frame
ON value-changed OF f-dens-temp IN FRAME Dialog-Frame /* Температура замера плотности */
do:
  assign
    f-tank-density-pomi = ?
  .
  display
    f-tank-density-pomi with frame {&frame-name}
  .
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-doc-dens
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-doc-dens Dialog-Frame
ON leave OF f-doc-dens IN FRAME Dialog-Frame /* Плотность по док. */
do:

    run calc-doc in this-procedure.

end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-doc-qnty
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-doc-qnty Dialog-Frame
ON leave OF f-doc-qnty IN FRAME Dialog-Frame /*   Кол-во по док. */
do:

    run calc-doc in this-procedure.

end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-hour-end
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-hour-end Dialog-Frame
ON leave OF f-hour-end IN FRAME Dialog-Frame /*  Время конца слива */
do:
  if input frame {&frame-name} f-hour-end > 24
  then do:
     message "Неверно заведено поле час." view-as alert-box .
     apply "entry" to f-hour-end in frame {&frame-name} .
     return no-apply .
  end.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-hour-end Dialog-Frame
ON return OF f-hour-end IN FRAME Dialog-Frame /*  Время конца слива */
do:
    apply "entry" to f-min-end in frame {&frame-name}.
return no-apply.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-hour-prob
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-hour-prob Dialog-Frame
ON leave OF f-hour-prob IN FRAME Dialog-Frame /* Время отбора пробы */
do:
  if input frame {&frame-name} f-hour-prob > 24
  then do:
     message "Неверно заведено поле <<час>>." view-as alert-box .
     apply "entry" to f-hour-prob in frame {&frame-name} .
     return no-apply .
  end.

end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-hour-prob Dialog-Frame
ON return OF f-hour-prob IN FRAME Dialog-Frame /* Время отбора пробы */
do:
apply "entry" to f-min-prob in frame {&frame-name}.
return no-apply.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-hour-start
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-hour-start Dialog-Frame
ON leave OF f-hour-start IN FRAME Dialog-Frame /* Время начала слива */
do:
  if input frame {&frame-name} f-hour-start > 24
  then do:
     message "Неверно заведено поле <<час>>." view-as alert-box .
     apply "entry" to f-hour-start in frame {&frame-name} .
     return no-apply .
  end.

end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-hour-start Dialog-Frame
ON return OF f-hour-start IN FRAME Dialog-Frame /* Время начала слива */
do:
apply "entry" to f-min-start in frame {&frame-name}.
return no-apply.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-kol-prob
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-kol-prob Dialog-Frame
ON return OF f-kol-prob IN FRAME Dialog-Frame /* Кол-во пробы (л) */
do:
      apply "entry" to f-date-prob in frame {&frame-name}.
return no-apply.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-list-tank
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-list-tank Dialog-Frame
ON return OF f-list-tank IN FRAME Dialog-Frame /* Резервуары */
do:
      apply "entry" to b-save in frame {&frame-name}.
return no-apply.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-min-end
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-min-end Dialog-Frame
ON leave OF f-min-end IN FRAME Dialog-Frame
do:
  if input frame {&frame-name} f-min-end > 60
  then do:
     message "Неверно заведено поле <<минуты>>." view-as alert-box .
     apply "entry" to f-min-end in frame {&frame-name} .
     return no-apply .
  end.

end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-min-end Dialog-Frame
ON return OF f-min-end IN FRAME Dialog-Frame
do:
    apply "entry" to b-save in frame {&frame-name}.
return no-apply.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-min-prob
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-min-prob Dialog-Frame
ON leave OF f-min-prob IN FRAME Dialog-Frame
do:
  if input frame {&frame-name} f-min-prob > 60
  then do:
     message "Неверно заведено поле <<минуты>>." view-as alert-box .
     apply "entry" to f-min-prob in frame {&frame-name} .
     return no-apply .
  end.

end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-min-prob Dialog-Frame
ON return OF f-min-prob IN FRAME Dialog-Frame
do:
  apply "entry" to f-date-end in frame {&frame-name}.
return no-apply.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-min-start
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-min-start Dialog-Frame
ON leave OF f-min-start IN FRAME Dialog-Frame
do:
  if input frame {&frame-name} f-min-start > 60
  then do:
     message "Неверно заведено поле <<минуты>>." view-as alert-box .
     apply "entry" to f-min-start in frame {&frame-name} .
     return no-apply .
  end.

end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-min-start Dialog-Frame
ON return OF f-min-start IN FRAME Dialog-Frame
do:
  apply "entry" to f-date-end in frame {&frame-name}.
return no-apply.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-mouth
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-mouth Dialog-Frame
ON leave OF f-mouth IN FRAME Dialog-Frame /*    Объем горловины */
do:
    
    run calc-weight-vol in this-procedure.

end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-mouth Dialog-Frame
ON return OF f-mouth IN FRAME Dialog-Frame /*    Объем горловины */
do:
apply "entry" to f-tank-density in frame {&frame-name}.
return no-apply.

end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-mouth Dialog-Frame
ON value-changed OF f-mouth IN FRAME Dialog-Frame /*    Объем горловины */
do:
  assign
    f-tank-vol-pomi = ?
  .
  display
    f-tank-vol-pomi with frame {&frame-name}
  .
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-norm-doc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-norm-doc Dialog-Frame
ON return OF f-norm-doc IN FRAME Dialog-Frame /* из паспорта качества */
do:

return no-apply.



end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-num-passport
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-num-passport Dialog-Frame
ON return OF f-num-passport IN FRAME Dialog-Frame /* Паспорт качества № */
do:

return no-apply.



end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-num-plotn
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-num-plotn Dialog-Frame
ON return OF f-num-plotn IN FRAME Dialog-Frame /* Номер */
do:

return no-apply.



end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-num-print-prob
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-num-print-prob Dialog-Frame
ON return OF f-num-print-prob IN FRAME Dialog-Frame /* Номер печати (пробы) */
do:
      apply "entry" to f-kol-prob in frame {&frame-name}.
return no-apply.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-place-si
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-place-si Dialog-Frame
ON leave OF f-place-si IN FRAME Dialog-Frame /* Средство измерения */
do:
define variable v-node-code as integer no-undo.
define buffer buf_sr-izmerenia for ub.sr-izmerenia .  

  assign f-place-si.

  if f-place-si <> 0 and v-node-code <> ? then do :
    find first buf_sr-izmerenia where buf_sr-izmerenia.node-code = f-place-si no-error.
    if not available (buf_sr-izmerenia) then do:
      message "Не найдено средство измерения с кодом " f-place-si view-as alert-box.
      f-place-si = 0.
      f-place-si:screen-value = "0".
      f-place-si-name:screen-value = "".
      assign 
        f-num-plotn:screen-value = ""
        f-date-pov-plotn:screen-value = ""
        f-passport-plotn:screen-value = "".
      assign
        f-num-plotn
        f-date-pov-plotn
        f-passport-plotn
      .  
      hide
        f-num-plotn
        f-date-pov-plotn 
        f-passport-plotn
        b-choose-date-pov-plotn
        in frame {&frame-name}.
      return.
    end.
    v-node-code = f-place-si.
    f-place-si-name:screen-value = buf_sr-izmerenia.sr-model.
    v-sr-type = buf_sr-izmerenia.sr-type-id.
  end.


  if v-sr-type = 2 or v-sr-type = 1 then do:
      enable f-num-plotn
             f-date-pov-plotn 
             b-choose-date-pov-plotn
      with frame {&frame-name}.
      hide f-passport-plotn
           in frame {&frame-name}.
      f-passport-plotn:screen-value = "".
      assign f-passport-plotn.
  end.
  if v-sr-type = 3 or v-sr-type = 4 then do:
      enable f-num-plotn
             f-date-pov-plotn 
             f-passport-plotn
             b-choose-date-pov-plotn
      with frame {&frame-name}.
  end.

end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-place-si Dialog-Frame
ON return OF f-place-si IN FRAME Dialog-Frame /* Средство измерения */
do:

  return no-apply.

end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-sec-num
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-sec-num Dialog-Frame
ON leave OF f-sec-num IN FRAME Dialog-Frame /* Номер секции */
do:
  if f-sec-num:screen-value = f-sec-num then return.

  
  find first ub.auto-tank where ub.auto-tank.auto-num = infoSectionTotal:CarNum + "#" + f-sec-num:screen-value no-error.
  if available (ub.auto-tank) and (f-size = "0" or f-size = ? or f-size = "" or not infoSectionTotal:FlagTrn )
  then do: 
    assign
      f-size:screen-value = entry(3, auto-tank.name, {&delim-par})
      f-car-vol:screen-value = string (ub.auto-tank.brutto-qnty)
      f-doc-qnty:screen-value = string (ub.auto-tank.brutto-qnty)
      f-size = if entry (3, auto-tank.name, {&delim-par}) = "" or entry (3, auto-tank.name, {&delim-par}) = ? then "0" else entry (3, auto-tank.name, {&delim-par})
      f-doc-qnty = ub.auto-tank.brutto-qnty
      f-car-vol = ub.auto-tank.brutto-qnty.
  end.

  run save-page.  
  v-section-names = "".
  do ii = 1 to infoSectionTotal:SectionNum:
    v-section-names = v-section-names + "|" + "Секция - " + if infoSectionTotal:GetInfoSectionProp(ii):SectionName = "" then string (ii) else infoSectionTotal:GetInfoSectionProp(ii):SectionName.
  end. 
  v-section-names = trim (v-section-names, "|") + (if (p-mode = {&update} or p-mode = {&add-def}) and infoSectionTotal:SectionNum < maxSec then "|         +" else "") + if infoSectionTotal:FlagTrn then "|Сумма" else "".
  run initialize-folder (v-section-names).
  run show-current-page(input v-page-current).

end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-size
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-size Dialog-Frame
ON leave OF f-size IN FRAME Dialog-Frame /* Размер горловины */
do:
    decimal (f-size:screen-value) no-error.
/*    if error-status:error                                           */
/*    and rdc-dnstvalue = "pomi-rn"                                   */
/*    then do:                                                        */
/*      message "Не верно указан диаметр горловины" view-as alert-box.*/
/*      return no-apply.                                              */
/*    end.                                                            */
    run calc-weight-vol in this-procedure.

end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-tank-density
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-tank-density Dialog-Frame
ON leave OF f-tank-density IN FRAME Dialog-Frame /*  Плотность топлива */
do:
  
    run calc-weight-vol in this-procedure.

end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-tank-density Dialog-Frame
ON return OF f-tank-density IN FRAME Dialog-Frame /*  Плотность топлива */
do:
      apply "entry" to f-tank-temp in frame {&frame-name}.
return no-apply.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-tank-density Dialog-Frame
ON value-changed OF f-tank-density IN FRAME Dialog-Frame /*  Плотность топлива */
do:
  assign
    f-tank-density-pomi = ?
  .
  display
    f-tank-density-pomi with frame {&frame-name}
  .
  run calc-weight-vol in this-procedure.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-tank-density-pomi
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-tank-density-pomi Dialog-Frame
ON leave OF f-tank-density-pomi IN FRAME Dialog-Frame /*     Плотность приведенная */
do:
  
    run calc-weight-vol in this-procedure.

end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-tank-temp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-tank-temp Dialog-Frame
ON return OF f-tank-temp IN FRAME Dialog-Frame /* Температура замера объема */
do:
  return no-apply.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-tank-temp Dialog-Frame
ON value-changed OF f-tank-temp IN FRAME Dialog-Frame /* Температура замера объема */
do:
  assign
    f-tank-vol-pomi = ?
  .
  display
    f-tank-vol-pomi with frame {&frame-name}
  .
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-tank-vol
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-tank-vol Dialog-Frame
ON return OF f-tank-vol IN FRAME Dialog-Frame /*      Объем топлива */
do:
      apply "entry" to f-tank-water in frame {&frame-name}.
return no-apply.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-tank-vol-pomi
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-tank-vol-pomi Dialog-Frame
ON leave OF f-tank-vol-pomi IN FRAME Dialog-Frame /* Объем топлива приведенный */
do:
  
    run calc-weight-vol in this-procedure.

end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-tank-vol-pomi Dialog-Frame
ON return OF f-tank-vol-pomi IN FRAME Dialog-Frame /* Объем топлива приведенный */
do:
      apply "entry" to f-tank-water in frame {&frame-name}.
return no-apply.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-tank-vol-total
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-tank-vol-total Dialog-Frame
ON return OF f-tank-vol-total IN FRAME Dialog-Frame /* Объем топлива */
do:
      apply "entry" to f-tank-water in frame {&frame-name}.
return no-apply.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-tank-water
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-tank-water Dialog-Frame
ON leave OF f-tank-water IN FRAME Dialog-Frame /* Объем воды */
do:
  assign
    f-tank-vol-pomi = ?
  .
  display
    f-tank-vol-pomi with frame {&frame-name}
  .
  run calc-weight-vol in this-procedure.

end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-tank-water Dialog-Frame
ON return OF f-tank-water IN FRAME Dialog-Frame /* Объем воды */
do:
      apply "entry" to f-tank-density in frame {&frame-name}.
return no-apply.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-tank-weight
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-tank-weight Dialog-Frame
ON return OF f-tank-weight IN FRAME Dialog-Frame /*    Масса топлива */
do:
      apply "entry" to b-save in frame {&frame-name}.
return no-apply.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-tank-weight-total
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-tank-weight-total Dialog-Frame
ON leave OF f-tank-weight-total IN FRAME Dialog-Frame /* Вес топлива */
do:

    run calc-weight-vol in this-procedure.

end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-tank-weight-total Dialog-Frame
ON return OF f-tank-weight-total IN FRAME Dialog-Frame /* Вес топлива */
do:
  apply "entry" to f-tests in frame {&frame-name}.
  return no-apply.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-tank-weight-total Dialog-Frame
ON value-changed OF f-tank-weight-total IN FRAME Dialog-Frame /* Вес топлива */
do:
  assign
    f-tank-vol-pomi = ?
  .
  display
    f-tank-vol-pomi with frame {&frame-name}
  .
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-tests
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-tests Dialog-Frame
ON return OF f-tests IN FRAME Dialog-Frame /* Номер пробы */
do:

  return no-apply.

end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-ttn-temp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-ttn-temp Dialog-Frame
ON return OF f-ttn-temp IN FRAME Dialog-Frame /* Температура по ТТН */
do:
  return no-apply.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-validity-certif
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-validity-certif Dialog-Frame
ON return OF f-validity-certif IN FRAME Dialog-Frame /* топлива) из паспорта качества */
do:

return no-apply.



end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME r-list-tank
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL r-list-tank Dialog-Frame
ON CHOOSE OF r-list-tank IN FRAME Dialog-Frame /* r-list-tank */
DO:
  
  assign f-list-tank.
  run str/place-list.w 
  ( input p-doc-code,
    input p-gds-code,
    input-output f-list-tank
  ).
  f-list-tank:screen-value = f-list-tank.
  
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME r-sr-izm
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL r-sr-izm Dialog-Frame
ON choose OF r-sr-izm IN FRAME Dialog-Frame /* r-sr-izm */
do:
  define variable v-node-code as integer no-undo.
  define buffer buf_sr-izmerenia for ub.sr-izmerenia .
  
  v-node-code = 0 .
  run ref/sr-izm.w (input parparentproc ,
                    input ""            ,
                    input {&lookup}     ,
                    input ""            ,
                    input ""            ,
                    input-output v-node-code,
                    output v-sr-type) no-error.
  if v-node-code <> 0 and v-node-code <> ? then do :
    f-place-si = v-node-code.
    f-place-si:screen-value = string(v-node-code).
  find first buf_sr-izmerenia where buf_sr-izmerenia.node-code = v-node-code no-error.
  if not available buf_sr-izmerenia then do:
    message "Введено неизвестное стредство измерения" view-as alert-box.
    return no-apply.
  end.
  f-place-si-name:screen-value = buf_sr-izmerenia.sr-model.
  end.
  apply "leave" to f-place-si.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame 


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
if valid-handle(active-window) and frame {&FRAME-NAME}:PARENT eq ?
then frame {&FRAME-NAME}:PARENT = active-window.
{ gbl/app_help.i }
/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
do on error   undo MAIN-BLOCK, leave MAIN-BLOCK
   on end-key undo MAIN-BLOCK, leave MAIN-BLOCK:
  
  
/*  def var tanksecs as class ibs.th.str.ptrl.tanksecsproc no-undo.*/
/*                                                                 */
/*                                                                 */
/*  tanksecs = new ibs.th.str.ptrl.tanksecsproc (infoSectionTotal).*/
/*                                                                 */
/*  tanksecs:Show().                                               */
  
  run gbl/conf-rd.p ("rdc-dnst", "", "", 0, "", "", "", no, output rdc-dnstvalue, output rdc-dnsttype) no-error.
  run gds-attr-value in this-procedure
    (  input p-gds-code
    ,  input {&attr-fuel-type}
    , output v-gds-attr-value
    , output v-gds-attr-type
    ) no-error .
  if error-status:error or lookup (v-gds-attr-value, "metan,propan") > 0 then 
  do:
    rdc-dnstvalue = "not".
  end.
  infoSectionTotal:RdcDnstvalue = rdc-dnstvalue.
  v-page-current = 1.
  v-section-names = "".
  if infoSectionTotal:SectionNum = 1 then do:
    infoSectionTotal:GetInfoSectionProp(1):DocQnty = infoSectionTotal:DocQntyLine.
    infoSectionTotal:GetInfoSectionProp(1):DocDensity = infoSectionTotal:DocDensLine.
    infoSectionTotal:GetInfoSectionProp(1):CliQnty = infoSectionTotal:DocCliLine.
  end.
  do ii = 1 to infoSectionTotal:SectionNum:
    v-section-names = v-section-names + "|" + 'Секция - ' + if infoSectionTotal:GetInfoSectionProp(ii):SectionName = "" then string (ii) else infoSectionTotal:GetInfoSectionProp(ii):SectionName.
  end.
  if infoSectionTotal:FlagTrn 
    then v-section-names = trim (v-section-names, "|") + (if (p-mode = {&update} or p-mode = {&add-def}) and infoSectionTotal:SectionNum < maxSec then "|         +" else "") + "|Сумма".
    else v-section-names = trim (v-section-names, "|") + (if (p-mode = {&update} or p-mode = {&add-def}) and infoSectionTotal:SectionNum < maxSec then "|         +" else "").
  run set-size(input frame {&FRAME-NAME}:height-pixels - 73, input frame {&FRAME-NAME}:width-pixels - 20).
  run initialize-folder (v-section-names).
  run show-current-page(input v-page-current).
  find first buf_goods no-lock
    where buf_goods.gds-code = p-gds-code
    .
  run enable_UI.
  run initialize-section.
  
  find first ub.trn-doc no-lock where ub.trn-doc.doc-code = p-doc-code no-error.
  { gbl/ptrlprop.i
    run
    trn-doc.obj-type
    trn-doc.obj-code
  }
  if not error-status :error then do:
    if ptrlprop-temp-for-pomi = 1 then temp-for-pomi = 15 .
                                  else temp-for-pomi = 20 .
  end.
  assign
    infoSectionTotal:IsRNAlgo = if ptrlprop-algoincome = 2 then true else false
  .
  if not infoSectionTotal:IsRnAlgo 
    then
      hide
        f-acc-weight
      in frame Dialog-Frame .

  wait-for go of frame {&FRAME-NAME} focus f-sec-num.
end.
run disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE calc-doc Dialog-Frame 
PROCEDURE calc-doc :
run save-page.
  case false:
    when infoSectionTotal:DocQntyInput then do:
      infoSectionTotal:GetInfoSectionProp(v-page-current):DocQnty = infoSectionTotal:GetInfoSectionProp(v-page-current):CliQnty / infoSectionTotal:GetInfoSectionProp(v-page-current):DocDensity no-error.
    end.
    when infoSectionTotal:DensityInput then do:
      infoSectionTotal:GetInfoSectionProp(v-page-current):DocDensity = infoSectionTotal:GetInfoSectionProp(v-page-current):CliQnty / infoSectionTotal:GetInfoSectionProp(v-page-current):DocQnty no-error.
    end.
    when infoSectionTotal:CliQntyInput then do:
      infoSectionTotal:GetInfoSectionProp(v-page-current):CliQnty = infoSectionTotal:GetInfoSectionProp(v-page-current):DocQnty * infoSectionTotal:GetInfoSectionProp(v-page-current):DocDensity no-error.      
    end.
  end.
  do with frame {&frame-name}:
  assign
    f-doc-qnty:screen-value = string (infoSectionTotal:GetInfoSectionProp(v-page-current):DocQnty)
    f-doc-dens:screen-value = string (infoSectionTotal:GetInfoSectionProp(v-page-current):DocDensity)
    f-cli-qnty:screen-value = string (infoSectionTotal:GetInfoSectionProp(v-page-current):CliQnty).
  end.
  assign frame {&frame-name}
    f-doc-qnty
    f-doc-dens
    f-cli-qnty
  .
    
end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE calc-weight-vol Dialog-Frame 
PROCEDURE calc-weight-vol :
define variable v-area as decimal no-undo.

  if v-page-current > infoSectionTotal:SectionNum or not infoSectionTotal:FlagTrn 
    then return.

  assign frame {&frame-name}
    f-mouth
    f-a-b-tarir
    f-size
    f-tank-density
    f-tank-weight
    f-tank-vol
    f-tank-vol-pomi
    f-tank-density-pomi
    f-car-vol
    f-tank-water
    .
    
  assign
    f-size              = string (decimal (f-size))
    f-size:screen-value = string (decimal (f-size)) 
    no-error.
  if error-status:error then 
  do:
    assign
      v-area = decimal (entry (1,f-size, "/")) * decimal (entry (2,f-size, "/")) * 0.000001
      no-error.
    if error-status:error then 
    do:
      message "Неверно указан размер горловины (либо значение диаметра, либо значение сторон для прямоугольной горловины в виде a/b). Берется по умолчанию 0" view-as alert-box.
      f-size:screen-value in frame {&frame-name} = "0".
      v-area = 0.
    end.
  end.
  else 
  do:
    v-area = 3.14159 * decimal (f-size) * decimal (f-size) * 0.000001 / 4 no-error.
  end.
     
  f-mouth = round (f-a-b-tarir * v-area, 2) .
    
  if f-mouth <> decimal (f-mouth:screen-value) then 
    apply "value-changed" to f-mouth in frame {&FRAME-NAME}.
      
  f-tank-vol = f-car-vol + f-mouth - f-tank-water.

  if rdc-dnstvalue = "not" then 
  do:
    display input frame {&frame-name} f-tank-vol *
      input frame {&frame-name} f-tank-density @ f-tank-weight with frame {&frame-name}.
  end.
  else 
  do:
    if rdc-dnstvalue = "pomi-rn" or rdc-dnstvalue = "th" then do :
      display input frame {&frame-name} f-tank-weight /
        input frame {&frame-name} f-tank-vol-pomi @ f-tank-density-pomi with frame {&frame-name}.      
      assign
        f-tank-density-pomi = f-tank-weight / f-tank-vol-pomi.
    end.
    else do:
    display input frame {&frame-name} f-tank-vol-pomi *
      input frame {&frame-name} f-tank-density-pomi @ f-tank-weight with frame {&frame-name}.
    end.
  end.
  assign
    f-tank-weight.
    
  do with frame {&frame-name}:
    assign
      f-mouth:screen-value in frame {&frame-name} = string (f-mouth)
      f-tank-vol:screen-value                     = string (f-tank-vol).
    .
  end.

end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE check-data Dialog-Frame 
PROCEDURE check-data :
define variable ii as integer no-undo.
  define variable v-list-tank as character no-undo.
  
  if p-mode = {&lookup} or not infoSectionTotal:FlagTrn 
      then return.
  
  infoSectionTotal:CalculateTotal().
  case false: 
  when 0.01 > abs (infoSectionTotal:DocQntyTotal - infoSectionTotal:DocQntyLine) then 
  do:
    message substitute ("Количество по документу - &1 не совпадает с суммой количества по документу - &2 по секциям", infoSectionTotal:DocQntyLine, infoSectionTotal:DocQntyTotal) view-as alert-box error.
    return error.
  end.
  when 0.01 > abs (infoSectionTotal:DocDensityAvg - infoSectionTotal:DocDensLine) then 
  do:
    message substitute ("Плотность по документу - &1 не совпадает со средней плотностью по документу - &2 по секциям", infoSectionTotal:DocDensLine, infoSectionTotal:DocDensityAvg) view-as alert-box error.
    return error.
  end.
  when 0.01 > abs (infoSectionTotal:DocDensityAvg * infoSectionTotal:DocQntyTotal - infoSectionTotal:DocCliLine) then 
  do:
    message substitute ("Масса по документу - &1 не совпадает с суммой масс по документу - &2 по секциям", infoSectionTotal:DocCliLine, infoSectionTotal:DocDensityAvg * infoSectionTotal:DocQntyTotal) view-as alert-box error.
    return error.
  end.
  end case.

  assign
    f-list-tank = f-list-tank:screen-value in frame {&frame-name}.

  for each buf_doc-pl where buf_doc-pl.out-code = p-doc-code and buf_doc-pl.gds-code = p-gds-code:
    find first ub.place no-lock where ub.place.pl-code = buf_doc-pl.pl-code no-error.
    v-list-tank = v-list-tank + "," + ub.place.loc1.
  end.
  v-list-tank = left-trim (v-list-tank, ",").
  
  do ii = 1 to num-entries (f-list-tank):
    if lookup (entry (ii, f-list-tank), v-list-tank) = 0
    then do:
      message substitute ("Неверно указаны резервуары") view-as alert-box error.
      return error.
    end. 
  end.
  
end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE check-page Dialog-Frame 
PROCEDURE check-page :
define variable v-list-tank as character no-undo.
  
  
  if p-mode <> {&update} and p-mode <> {&add-def} then return.

  integer (replace (f-sec-num, ".", "-")) no-error.
  if error-status:error or f-sec-num matches "*,*"
    then 
  do:
    message "Номер секции должен иметь числовое значение" view-as alert-box .
    apply "entry" to f-sec-num in frame {&frame-name} .
    return error .
  end.
  
  do ii = 1 to infoSectionTotal:SectionNum:
    if ii <> v-page-current and input frame {&frame-name} f-sec-num = infoSectionTotal:GetInfoSectionProp(ii):SectionName and infoSectionTotal:SectionNum >= v-page-current 
    then do:
      message "Такой номер секции уже был" view-as alert-box .
      apply "entry" to f-sec-num in frame {&frame-name} .
      return error .
    end.   
  end.
  
  if not infoSectionTotal:FlagTrn then return.
  
  define variable stfactplvalue as character no-undo initial ? .
  define variable stfactpltype  as character no-undo initial ? .
  define variable v-update      as logical   no-undo initial true .
  define variable v-revision    as logical   no-undo initial false .
  define variable v-percrev     as decimal   no-undo initial ? .
  define variable v-auto-tank   as logical   no-undo initial false .
  define variable v-percauto    as decimal   no-undo initial ? .
  define variable v-inv         as logical   no-undo initial false .
  define variable v-percinv     as decimal   no-undo initial ? .
  define variable v-inv-set     as logical   no-undo initial false .
  
  { gbl/conf-rd.i
    "'stfactpl'"
    "''"
    "''"
    0
    "''"
    "''"
    "''"
    no
    stfactplvalue
    stfactpltype
    no-error
  }
  if error-status :error then do:
    /*да просто ничего не надо */
  end.
  if stfactplvalue <> "":U then do:
    { str/chkqtpl.i
      stfactplvalue
      v-update
      v-revision
      v-percrev
      v-auto-tank
      v-percauto
      v-inv
      v-percinv
      v-inv-set
    }
  end.
  if v-auto-tank = true
    or v-inv = true
  then do:
    if input frame {&frame-name} f-car-vol <= 0 or
       input frame {&frame-name} f-car-vol = ?
    then do:
      message "Объем по паспорту в литрах должен быть больше 0." view-as alert-box .
      apply "entry" to f-car-vol in frame {&frame-name} .
      return error .
    end.
    if rdc-dnstvalue = "pomi-rn"  then do:
        if f-place-si:screen-value <> "" and input frame {&frame-name} f-place-si <> 0 then do: 
           if v-sr-type = 1 or v-sr-type = 2 then do:
/*            if input frame {&frame-name} f-num-plotn = ""
            then do:
              message "Введите номер измерения." view-as alert-box .
              apply "entry" to f-num-plotn in frame {&frame-name} .
              return error .
            end.
            if input frame {&frame-name} f-date-pov-plotn = ""
            then do:
              message "Введите дату поверки ." view-as alert-box .
              apply "entry" to f-date-pov-plotn in frame {&frame-name} .
              return error .
            end. */
           end. 
        end.
        if f-place-si:screen-value <> "" then do:
           if v-sr-type = 3 or v-sr-type = 4 then do:
          /*  if input frame {&frame-name} f-num-plotn = ""
            then do:
              message "Введите номер измерения." view-as alert-box .
              apply "entry" to f-num-plotn in frame {&frame-name} .
              return error .
            end.
            if input frame {&frame-name} f-date-pov-plotn = ""
            then do:
              message "Введите дату поверки." view-as alert-box .
              apply "entry" to f-date-pov-plotn in frame {&frame-name} .
              return error .
            end.
            if input frame {&frame-name} f-passport-plotn = ""
            then do:
              message "Введите номер паспорта плотномера." view-as alert-box .
              apply "entry" to f-passport-plotn in frame {&frame-name} .
              return error .
            end. */
          end.
        end.
    end.
    if rdc-dnstvalue = "pomi-rn" then do:
/*        if input frame {&frame-name} f-certif-fuel = ""                                                                      */
/*        then do:                                                                                                             */
/*          message "Не заполнен Сертификат соответствия завода-изготовителя (на марку моторного топлива)." view-as alert-box .*/
/*          apply "entry" to f-certif-fuel in frame {&frame-name} .                                                            */
/*          return error .                                                                                                     */
/*        end.                                                                                                                 */
/*        if input frame {&frame-name} f-norm-doc = ""                                         */
/*        then do:                                                                             */
/*          message "Не заполнен Нормативный документ завода-изготовителя." view-as alert-box .*/
/*          apply "entry" to f-norm-doc in frame {&frame-name} .                               */
/*          return error .                                                                     */
/*        end.                                                                                 */
/*        if input frame {&frame-name} f-num-passport = ""                                     */
/*        then do:                                                                             */
/*          message "Не заполнен Номер паспорта качества." view-as alert-box .                 */
/*          apply "entry" to f-num-passport in frame {&frame-name} .                           */
/*          return error .                                                                     */
/*        end.                                                                                 */
/*        if input frame {&frame-name} f-validity-certif = ""                                                  */
/*        then do:                                                                                             */
/*          message "Не указан Срок действия сертификата соответствия завода-изготовителя." view-as alert-box .*/
/*          apply "entry" to f-validity-certif in frame {&frame-name} .                                        */
/*          return error .                                                                                     */
/*        end.                                                                                                 */
        if input frame {&frame-name} f-tank-vol <= 0 or
           input frame {&frame-name} f-tank-vol  = ?
        then do:
          message "Объем топлива должен быть больше 0." view-as alert-box .
          apply "entry" to f-tank-vol in frame {&frame-name} .
          return error .
        end.
        if input frame {&frame-name} f-tank-weight <= 0 or
           input frame {&frame-name} f-tank-weight  = ?
        then do:
          message "Вес топлива должен быть больше 0." view-as alert-box .
          apply "entry" to f-tank-weight in frame {&frame-name} .
          return error .
        end.
        if input frame {&frame-name} f-tank-density = ?
          or Valid-Density( input frame {&frame-name} f-tank-density, (buf_goods.unit-base = buf_goods.unit-cli) ) <> yes
        then do:
          message "Плотность должна быть больше 0 и меньше 1." view-as alert-box .
          apply "entry" to f-tank-density in frame {&frame-name} .
          return error .
        end.
        if input frame {&frame-name} f-place-si = 0
        then do:
          message "Введите средство измерения." view-as alert-box .
          apply "entry" to f-place-si in frame {&frame-name} .
          return error .
        end.    
/*        if input frame {&frame-name} f-date-start = ""            */
/*        then do:                                                  */
/*          message "Введите дату начала слива." view-as alert-box .*/
/*          return error .                                          */
/*        end.                                                      */
/*        if input frame {&frame-name} f-date-end = ""              */
/*        then do:                                                  */
/*          message "Введите дату конца слива." view-as alert-box . */
/*          apply "entry" to f-date-end in frame {&frame-name} .    */
/*          return error .                                          */
        end.
        /*if input frame {&frame-name} f-hour-start = ? or
           input frame {&frame-name} f-min-start = ?
        then do:
          message "Введите время начала слива." view-as alert-box .
          apply "entry" to f-hour-start in frame {&frame-name} .
          return error .
        end.    
        if input frame {&frame-name} f-hour-end = ? or 
           input frame {&frame-name} f-min-end = ?
        then do:
          message "Введите время конца слива." view-as alert-box .
          apply "entry" to f-hour-end in frame {&frame-name} .
          return error .
        end. */
        
        
/*        if input frame {&frame-name} f-place-si = 0                */
/*        then do:                                                   */
/*          message "Введите средство измерения." view-as alert-box .*/
/*          apply "entry" to f-place-si in frame {&frame-name} .     */
/*          return error .                                           */
/*        end.                                                       */
/*                                                                   */
/*                                                                   */
/*        if input frame {&frame-name} f-hour-prob = ? or            */
/*           input frame {&frame-name} f-min-prob = ?                */
/*        then do:                                                   */
/*          message "Введите время отбора проб." view-as alert-box . */
/*          apply "entry" to f-hour-prob in frame {&frame-name} .    */
/*          return error .                                           */
/*        end.                                                       */
            
/*      end.*/
  end.
/*    if input frame {&frame-name} f-tank-density <> ?                                                                  */
/*      and Valid-Density( input frame {&frame-name} f-tank-density, (buf_goods.unit-base = buf_goods.unit-cli) ) <> yes*/
/*    then do:                                                                                                          */
/*      message "Плотность должна быть больше 0 и меньше 1." view-as alert-box .                                        */
/*      apply "entry" to f-tank-density in frame {&frame-name} .                                                        */
/*      return error .                                                                                               */
/*    end.                                                                                                              */
  if input frame {&frame-name} f-hour-start <> ?
    and input frame {&frame-name} f-hour-start > 24
  then do:
     message "Неверно заведено поле <<час>>." view-as alert-box .
     apply "entry" to f-hour-start in frame {&frame-name} .
     return error .
  end.
  if input frame {&frame-name} f-hour-end > 24
  then do:
     message "Неверно заведено поле час." view-as alert-box .
     apply "entry" to f-hour-end in frame {&frame-name} .
     return error .
  end.
  if input frame {&frame-name} f-min-start > 60
  then do:
     message "Неверно заведено поле <<минуты>>." view-as alert-box .
     apply "entry" to f-min-start in frame {&frame-name} .
     return error .
  end.
  if input frame {&frame-name} f-min-end > 60
  then do:
     message "Неверно заведено поле <<минуты>>." view-as alert-box .
     apply "entry" to f-min-end in frame {&frame-name} .
     return error .
  end.
  if input frame {&frame-name} f-sec-num = ""
  then do:
     message "Не указан номер секции" view-as alert-box .
     apply "entry" to f-sec-num in frame {&frame-name} .
     return error .
  end.
if input frame {&frame-name} f-hour-prob > 24
  then do:
     message "Неверно заведено поле час." view-as alert-box .
     apply "entry" to f-hour-end in frame {&frame-name} .
     return error .
  end.
  if input frame {&frame-name} f-min-start > 60
  then do:
     message "Неверно заведено поле <<минуты>>." view-as alert-box .
     apply "entry" to f-min-start in frame {&frame-name} .
     return error .
  end.
  
  assign
    f-list-tank = f-list-tank:screen-value in frame {&frame-name}.

  for each buf_doc-pl where buf_doc-pl.out-code = p-doc-code and buf_doc-pl.gds-code = p-gds-code:
    find first ub.place no-lock where ub.place.pl-code = buf_doc-pl.pl-code no-error.
    v-list-tank = v-list-tank + "," + ub.place.loc1.
  end.
  v-list-tank = left-trim (v-list-tank, ",").
  
  do ii = 1 to num-entries (f-list-tank):
    if lookup (entry (ii, f-list-tank), v-list-tank) = 0
    then do:
      message substitute ("Неверно указаны резервуары") view-as alert-box.
      apply "entry" to f-list-tank in frame {&frame-name} .
      return error.
    end. 
  end.

  
end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI Dialog-Frame  _DEFAULT-DISABLE
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
  HIDE FRAME Dialog-Frame.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI Dialog-Frame  _DEFAULT-ENABLE
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
  DISPLAY f-sec-num f-ttn-temp f-doc-qnty f-doc-dens f-acc-ship f-cli-qnty 
          f-size f-car-vol f-num-passport f-text1 f-norm-doc f-text2 
          f-certif-fuel f-text3 f-validity-certif f-a-b-tarir f-mouth 
          f-tank-water f-tank-vol f-tank-temp f-tank-density f-dens-temp 
          f-EU-weight f-list-tank f-loss-norm f-place-si f-num-plotn 
          f-date-pov-plotn f-tank-weight f-tank-density-pomi f-acc-weight 
          f-tank-vol-pomi f-date-start f-hour-start f-min-start f-date-end 
          f-hour-end f-min-end f-tests f-num-print-prob f-kol-prob f-hour-prob 
          f-min-prob f-date-prob f-place-si-name 
      WITH FRAME Dialog-Frame.
  ENABLE Rect-Main Rect-Bottom Rect-Left Rect-Right Rect-Top RECT-3 RECT-1 
         RECT-4 RECT-5 RECT-6 RECT-8 RECT-7 b-save b-quit b-del-sec b-help 
         f-sec-num f-ttn-temp f-doc-qnty f-doc-dens f-cli-qnty f-size f-car-vol 
         f-num-passport f-norm-doc f-certif-fuel f-validity-certif f-a-b-tarir 
         f-mouth f-tank-water f-tank-temp f-tank-density f-dens-temp 
         f-list-tank r-list-tank f-acc-ship f-num-plotn 
         f-date-pov-plotn f-date-start f-hour-start f-min-start f-date-end 
         f-hour-end f-min-end f-tests f-num-print-prob f-kol-prob f-hour-prob 
         f-min-prob f-date-prob
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE hide-disp-page Dialog-Frame 
PROCEDURE hide-disp-page :
define buffer buf_sr-izmerenia for ub.sr-izmerenia .

  if not infoSectionTotal:FlagTrn and (p-mode = {&update} or p-mode = {&add-def}) then do:
    enable {&list-1} with frame {&frame-name}.
    hide {&list-1} in frame {&frame-name}.
    display f-doc-qnty f-acc-ship f-doc-dens f-cli-qnty f-sec-num f-ttn-temp with frame {&frame-name}.
    enable f-doc-qnty f-acc-ship f-doc-dens f-cli-qnty f-sec-num f-ttn-temp with frame {&frame-name}.
    if infoSectionTotal:CliQntyInput and (p-mode = {&update} or p-mode = {&add-def})
      then enable f-cli-qnty with frame {&frame-name}.
    else disable f-cli-qnty with frame {&frame-name}.
    if infoSectionTotal:DocQntyInput and (p-mode = {&update} or p-mode = {&add-def})
      then enable f-doc-qnty with frame {&frame-name}.
    else disable f-doc-qnty with frame {&frame-name}.
    if infoSectionTotal:DensityInput and (p-mode = {&update} or p-mode = {&add-def})
      then enable f-doc-dens with frame {&frame-name}.
    else disable f-doc-dens with frame {&frame-name}.
    return.
  end.

  display {&list-1} with frame {&frame-name}.

  define variable IsKPPageCurrent as logical no-undo.
  IsKPPageCurrent = infoSectionTotal:GetInfoSectionProp(v-page-current):IsKP.

  iTemp = infoSectionTotal:GetInfoSectionProp(v-page-current):PlaceSi.
  find first buf_sr-izmerenia no-lock where buf_sr-izmerenia.node-code = iTemp no-error.
  if available buf_sr-izmerenia then do:
    assign
      f-place-si-name:screen-value = buf_sr-izmerenia.sr-model
      v-sr-type = buf_sr-izmerenia.sr-type-id.                           
  end.
  else
    assign
      f-place-si-name:screen-value = ""
      v-sr-type = 0.
     
  find first buf_goods no-lock
    where buf_goods.gds-code = p-gds-code
    .

  if v-sr-type = 0 then 
  do: 
    hide 
      f-num-plotn
      f-date-pov-plotn
      b-choose-date-pov-plotn
      f-passport-plotn
      in frame {&frame-name}.
  end.
  else 
  do:
    if v-sr-type = 1 or v-sr-type = 2 then 
    do:
      enable
        f-num-plotn
        f-date-pov-plotn
        b-choose-date-pov-plotn
        with frame {&frame-name}.
      hide 
        f-passport-plotn
        in frame {&frame-name}.
    end.
    if v-sr-type = 3 or v-sr-type = 4 then 
    do:
      enable
        f-num-plotn
        f-date-pov-plotn
        b-choose-date-pov-plotn
        f-passport-plotn
        with frame {&frame-name}.
    end.
  end.
  display
    f-car-vol f-tests f-sec-num f-doc-qnty
    f-date-start f-hour-start f-min-start
    f-date-end f-hour-end f-min-end
    f-tank-vol f-tank-temp f-tank-water f-tank-density
    f-tank-weight
    f-mouth
    f-a-b-tarir
    f-tank-vol-pomi f-dens-temp
    f-certif-fuel f-norm-doc 
    f-num-passport f-validity-certif f-list-tank r-list-tank
    f-kol-prob f-num-print-prob f-date-prob f-hour-prob f-min-prob f-ttn-temp f-size f-acc-ship f-EU-weight f-loss-norm
    with frame {&frame-name}.
  if rdc-dnstvalue <> "not" and p-mode <> {&lookup}  then 
  do :
    disable
      f-mouth
      f-tank-density-pomi
      with frame {&frame-name}.
    display
      f-size
      f-place-si
      r-sr-izm
      f-tank-density-pomi
      b-calc
      b-copy-iz
      b-copy-pass
      with frame {&frame-name}.
    enable
      f-size
      f-place-si
      r-sr-izm
      b-calc
      b-copy-iz
      b-copy-pass
      with frame {&frame-name}.
  end.
  if rdc-dnstvalue = "manual"
    then 
  do:
    disable
      b-calc
      with frame {&frame-name}.
    enable
      f-tank-vol-pomi
      f-tank-density-pomi
      with frame {&frame-name}.
  
  end.
  if rdc-dnstvalue = "" or rdc-dnstvalue = ? or rdc-dnstvalue = "not" then 
  do:
    rdc-dnstvalue = "not".
    disable
      f-tank-vol 
      f-tank-temp 
      f-tank-water
      f-tank-weight
      with frame {&frame-name}.
    enable
      f-mouth
      f-a-b-tarir
      f-dens-temp
      f-tank-density
      f-car-vol f-tests f-sec-num f-doc-qnty
      f-date-start f-hour-start f-min-start
      f-date-end f-hour-end f-min-end
      f-kol-prob f-num-print-prob f-date-prob f-hour-prob f-min-prob f-ttn-temp f-acc-ship
      with frame {&frame-name}.
    hide
      f-tank-vol-pomi
      f-tank-density-pomi
      in frame {&frame-name}.
  end.
  if rdc-dnstvalue <> "pomi-rn" then do:
      HIDE
        f-tests f-num-print-prob f-kol-prob f-hour-prob 
        f-min-prob f-date-prob f-acc-weight
      in frame Dialog-Frame . 
  end.
  if infoSectionTotal:CliQntyInput and p-mode = {&update}
    then
      assign 
        f-cli-qnty:sensitive = true
        f-cli-qnty:fgcolor = 12
      .
  else disable f-cli-qnty with frame {&frame-name}.
  if infoSectionTotal:DocQntyInput and p-mode = {&update} 
    then
      assign 
        f-doc-qnty:sensitive = true
        f-doc-qnty:fgcolor = 12.
  else disable f-doc-qnty with frame {&frame-name}.
  if infoSectionTotal:DensityInput and p-mode = {&update} 
    then
      assign 
        f-doc-dens:sensitive = true
        f-doc-dens:fgcolor = 12.
  else disable f-doc-dens with frame {&frame-name}.
  if p-mode <> {&update} then 
  do:
    disable
      f-car-vol f-tests f-sec-num f-doc-qnty
      f-tank-vol f-tank-temp f-tank-water f-tank-density
      f-tank-weight
      f-date-start f-hour-start f-min-start
      f-date-end f-hour-end f-min-end
      f-tank-vol-pomi f-dens-temp
      f-tank-density-pomi
      f-size
      f-place-si
      r-sr-izm
      b-calc
      b-copy-iz
      b-copy-pass
      b-save
      b-del-sec
      f-mouth
      f-a-b-tarir
      f-certif-fuel f-norm-doc f-num-passport f-validity-certif f-list-tank r-list-tank
      f-date-pov-plotn b-choose-date-pov-plotn f-passport-plotn f-num-plotn
      f-cli-qnty
      f-doc-qnty
      f-doc-dens
      f-kol-prob
      f-num-print-prob
      f-date-prob
      f-hour-prob
      f-min-prob
      f-ttn-temp
      f-acc-ship
      f-EU-weight
      f-loss-norm
      with frame {&frame-name}.
  end.
  
  assign
    f-size:fgcolor = 12 when f-size:sensitive
    f-doc-dens:fgcolor = 12 when f-doc-dens:sensitive
    f-tank-vol:fgcolor = 12 when f-tank-vol:sensitive
    f-car-vol:fgcolor = 12 when f-car-vol:sensitive
    f-tank-density:fgcolor = 12 when f-tank-density:sensitive
    f-tank-weight:fgcolor = 12 when f-tank-weight:sensitive
    f-sec-num:fgcolor = 12 when f-sec-num:sensitive  
    f-place-si:fgcolor = 12 when f-place-si:sensitive and rdc-dnstvalue = "pomi-rn"
    f-tank-temp:fgcolor = 12 when f-tank-temp:sensitive and rdc-dnstvalue = "pomi-rn"
    f-dens-temp:fgcolor = 12 when f-dens-temp:sensitive and rdc-dnstvalue = "pomi-rn"
    
/*    f-num-plotn:fgcolor = 12 when f-num-plotn:sensitive and rdc-dnstvalue = "pomi-rn"    */
/*    f-num-plotn:screen-value = ? when f-num-plotn:sensitive and rdc-dnstvalue = "pomi-rn"*/
    
/*    f-date-pov-plotn:fgcolor = 12 when f-date-pov-plotn:sensitive and rdc-dnstvalue = "pomi-rn"    */
/*    f-date-pov-plotn:screen-value = ? when f-date-pov-plotn:sensitive and rdc-dnstvalue = "pomi-rn"*/
/*                                                                                                  */
/*    f-passport-plotn:fgcolor = 12 when f-passport-plotn:sensitive and rdc-dnstvalue = "pomi-rn"    */
/*    f-passport-plotn:screen-value = ? when f-passport-plotn:sensitive and rdc-dnstvalue = "pomi-rn"*/
    
    f-tank-density-pomi:fgcolor = 12 when f-tank-density-pomi:sensitive  
    f-tank-vol-pomi:fgcolor = 12 when f-tank-vol-pomi:sensitive  
    
  .
  
  assign
    f-size:screen-value = "0" when f-size:screen-value = "".    

end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE initialize-section Dialog-Frame 
PROCEDURE initialize-section :
define buffer buf_sr-izmerenia for ub.sr-izmerenia .
display {&list-1} with frame {&frame-name}.
  hide {&list-2} in frame {&frame-name}.
  
  if v-page-current  = infoSectionTotal:SectionNum + 1 and (p-mode = {&update} or p-mode = {&add-def}) and infoSectionTotal:SectionNum < maxSec then do: /*новая секция*/
    v-section-names = "".
    infoSectionTotal:NewSection().
    do ii = 1 to infoSectionTotal:SectionNum:
      v-section-names = v-section-names + "|" + 'Секция - ' + if infoSectionTotal:GetInfoSectionProp(ii):SectionName = "" then string (ii) else infoSectionTotal:GetInfoSectionProp(ii):SectionName.
    end.
    if infoSectionTotal:FlagTrn 
      then v-section-names = trim (v-section-names, "|") + (if (p-mode = {&update} or p-mode = {&add-def}) and infoSectionTotal:SectionNum < maxSec then "|         +" else "") + "|Сумма".
      else v-section-names = trim (v-section-names, "|") + (if (p-mode = {&update} or p-mode = {&add-def}) and infoSectionTotal:SectionNum < maxSec then "|         +" else "").
    run initialize-folder (v-section-names).
    run show-current-page(input infoSectionTotal:SectionNum).
    run hide-disp-page.
  end.

  if v-page-current  = (infoSectionTotal:SectionNum + 2 - (if (p-mode = {&update} or p-mode = {&add-def}) and infoSectionTotal:SectionNum < maxSec then 0 else 1)) then do: /*сводная по всем секциям*/

    hide {&list-1} in frame {&frame-name}.

    infoSectionTotal:CalculateTotal().
    run check-data no-error.

    assign
      f-car-vol-total = infoSectionTotal:CarVolTotal
      f-tank-vol-total = infoSectionTotal:TankVolTotal
      f-tank-weight-total = infoSectionTotal:TankWeightTotal
      f-doc-qnty-total = infoSectionTotal:DocQntyTotal.
    
    display {&list-2} with frame {&frame-name}.

  end.
  else do:
    assign
      f-tests = infoSectionTotal:GetInfoSectionProp(v-page-current):Tests
      f-sec-num = infoSectionTotal:GetInfoSectionProp(v-page-current):SectionName
      f-ttn-temp = infoSectionTotal:GetInfoSectionProp(v-page-current):TTNTemp
      f-num-print-prob = infoSectionTotal:GetInfoSectionProp(v-page-current):NumPrintProb
      f-kol-prob = infoSectionTotal:GetInfoSectionProp(v-page-current):KolProb
      f-date-prob = infoSectionTotal:GetInfoSectionProp(v-page-current):DateProb
      f-hour-prob = infoSectionTotal:GetInfoSectionProp(v-page-current):HourProb
      f-min-prob = infoSectionTotal:GetInfoSectionProp(v-page-current):MinProb
      f-EU-weight = infoSectionTotal:GetInfoSectionProp(v-page-current):NaturalLoss
    .
    assign
      f-car-vol = decimal(infoSectionTotal:GetInfoSectionProp(v-page-current):CarVol) no-error
    .
    f-car-vol:screen-value = string (infoSectionTotal:GetInfoSectionProp(v-page-current):CarVol) no-error.
    assign
      f-certif-fuel = infoSectionTotal:GetInfoSectionProp(v-page-current):CertifFuel
      f-norm-doc = infoSectionTotal:GetInfoSectionProp(v-page-current):NormDoc
      f-num-passport = infoSectionTotal:GetInfoSectionProp(v-page-current):NumPassport
      f-validity-certif = infoSectionTotal:GetInfoSectionProp(v-page-current):ValidityCertif
      f-list-tank = infoSectionTotal:GetInfoSectionProp(v-page-current):ListTank
      f-num-plotn = infoSectionTotal:GetInfoSectionProp(v-page-current):NumPlotn
      f-date-pov-plotn = infoSectionTotal:GetInfoSectionProp(v-page-current):DatePovPlotn
      f-passport-plotn = infoSectionTotal:GetInfoSectionProp(v-page-current):PassportPlotn
      f-validity-certif = infoSectionTotal:GetInfoSectionProp(v-page-current):ValidityCertif 
      f-acc-ship = infoSectionTotal:GetInfoSectionProp(v-page-current):AccShip
      f-loss-norm = infoSectionTotal:GetInfoSectionProp(v-page-current):TPNorm
    .

  
    if error-status:error then
      message "Неверно задан объем автоцистерны по паспорту " infoSectionTotal:GetInfoSectionProp(v-page-current):CarVol " ."
      view-as alert-box error.
    assign
    f-tank-vol  = decimal(infoSectionTotal:GetInfoSectionProp(v-page-current):TankVol) no-error.
    if error-status:error then
      message "Неверно определен объем в цистерне " infoSectionTotal:GetInfoSectionProp(v-page-current):TankVol " . "
      view-as alert-box.
    assign
    f-tank-temp  = decimal(infoSectionTotal:GetInfoSectionProp(v-page-current):TankTemp) no-error.
    if error-status:error then
      message "Неверно определена температура в цистерне " infoSectionTotal:GetInfoSectionProp(v-page-current):TankTemp " . "
      view-as alert-box.
    assign
    f-tank-water  = decimal(infoSectionTotal:GetInfoSectionProp(v-page-current):TankWater) no-error.
    if error-status:error then
      message "Неверно определен объем воды в цистерне " infoSectionTotal:GetInfoSectionProp(v-page-current):TankWater " . "
      view-as alert-box.
    assign
    f-tank-density  = decimal(infoSectionTotal:GetInfoSectionProp(v-page-current):TankDensity) no-error.
    if error-status:error then
      message "Неверно определена плотность в цистерне " infoSectionTotal:GetInfoSectionProp(v-page-current):TankDensity " . "
      view-as alert-box.
    assign
    f-tank-weight  = decimal(infoSectionTotal:GetInfoSectionProp(v-page-current):TankWeight) no-error.
    if error-status:error then
      message "Неверно определен вес в цистерне " infoSectionTotal:GetInfoSectionProp(v-page-current):TankWeight " . "
      view-as alert-box.
    if rdc-dnstvalue = "pomi-rn"
    then do:
      f-acc-weight  = round (decimal(infoSectionTotal:GetInfoSectionProp(v-page-current):AccPomi), 3) no-error.
      if error-status:error then
        message "Неверно определена погрешнность измерения массы в библиотекие для работы с ПО МИ " infoSectionTotal:GetInfoSectionProp(v-page-current):AccPomi " . "
        view-as alert-box.
    end.
    if infoSectionTotal:GetInfoSectionProp(v-page-current):DateStart = ? then f-date-start = infoSectionTotal:GetInfoSectionProp(1):DateStart . 
    else f-date-start = infoSectionTotal:GetInfoSectionProp(v-page-current):DateStart .
    if infoSectionTotal:GetInfoSectionProp(v-page-current):DateEnd = ? then f-date-end = infoSectionTotal:GetInfoSectionProp(1):DateEnd . 
    else f-date-end = infoSectionTotal:GetInfoSectionProp(v-page-current):DateEnd .
    if infoSectionTotal:GetInfoSectionProp(v-page-current):TimeStart = 0 then 
    do:
        f-hour-start = integer( truncate( infoSectionTotal:GetInfoSectionProp(1):TimeStart / 3600 , 0 ) ).
        f-min-start  = integer( ( infoSectionTotal:GetInfoSectionProp(1):TimeStart - f-hour-start * 3600 ) / 60 ).
    end.
    else 
    do:
        f-hour-start = integer( truncate( infoSectionTotal:GetInfoSectionProp(1):TimeStart / 3600 , 0 ) ).
        f-min-start  = integer( ( infoSectionTotal:GetInfoSectionProp(1):TimeStart - f-hour-start * 3600 ) / 60 ).
    end.    
    if infoSectionTotal:GetInfoSectionProp(v-page-current):TimeEnd = 0 then 
    do:
        f-hour-end   = integer( truncate( infoSectionTotal:GetInfoSectionProp(1):TimeEnd / 3600 , 0 ) ).
        f-min-end    = integer( ( infoSectionTotal:GetInfoSectionProp(1):TimeEnd - f-hour-end * 3600 ) / 60).
    end.
    else 
    do:
        f-hour-end   = integer( truncate( infoSectionTotal:GetInfoSectionProp(1):TimeEnd / 3600 , 0 ) ).
        f-min-end    = integer( ( infoSectionTotal:GetInfoSectionProp(1):TimeEnd - f-hour-end * 3600 ) / 60).
    end.        
    assign
      f-mouth = decimal (infoSectionTotal:GetInfoSectionProp(v-page-current):Mouth) no-error.
    if error-status:error then
      message "Неверно определен объем топлива в горловине " infoSectionTotal:GetInfoSectionProp(v-page-current):Mouth " . "
      view-as alert-box.
    assign
    f-a-b-tarir  = decimal(infoSectionTotal:GetInfoSectionProp(v-page-current):ABTarir) no-error.
    if error-status:error then
      message "Неверно определен уровень цистерны относительно тарировочной планки " infoSectionTotal:GetInfoSectionProp(v-page-current):ABTarir " . "
      view-as alert-box.
    assign
    f-size = infoSectionTotal:GetInfoSectionProp(v-page-current):Diameter no-error.
    if error-status:error then
      message "Неверно определен внутренний диаметр горловины" infoSectionTotal:GetInfoSectionProp(v-page-current):Diameter " . "
      view-as alert-box.
    f-size:screen-value = string (infoSectionTotal:GetInfoSectionProp(v-page-current):Diameter) no-error.
    assign
    f-place-si = integer(infoSectionTotal:GetInfoSectionProp(v-page-current):PlaceSi) no-error.
    if error-status:error then
      message "Неверно определено средство измерения" infoSectionTotal:GetInfoSectionProp(v-page-current):PlaceSi " . "
      view-as alert-box.
    f-tank-density-pomi = decimal(infoSectionTotal:GetInfoSectionProp(v-page-current):TankDensityPomi) no-error.
    if error-status:error then
      message "Неверно определена приведенная плотность" infoSectionTotal:GetInfoSectionProp(v-page-current):TankDensityPomi " . "
      view-as alert-box.
    assign
    f-tank-vol-pomi  = decimal(infoSectionTotal:GetInfoSectionProp(v-page-current):TankVolPomi) no-error.
    if error-status:error then
      message "Неверно определен объем в цистерне " infoSectionTotal:GetInfoSectionProp(v-page-current):TankVolPomi " . "
      view-as alert-box.
    assign
    f-dens-temp  = decimal(infoSectionTotal:GetInfoSectionProp(v-page-current):DensTemp) no-error.
    if error-status:error then
      message "Неверно определена температура в цистерне " infoSectionTotal:GetInfoSectionProp(v-page-current):TankTemp " . "
      view-as alert-box.
    assign
      f-doc-qnty = infoSectionTotal:GetInfoSectionProp(v-page-current):DocQnty
      f-doc-dens = infoSectionTotal:GetInfoSectionProp(v-page-current):DocDensity
      f-cli-qnty = infoSectionTotal:GetInfoSectionProp(v-page-current):CliQnty
    no-error.
    find first buf_sr-izmerenia where buf_sr-izmerenia.node-code = f-place-si no-error.
    if available buf_sr-izmerenia then do:
      assign
        f-place-si-name:screen-value = buf_sr-izmerenia.sr-model
        v-sr-type = buf_sr-izmerenia.sr-type-id.
    end.
    else
      assign
        f-place-si-name:screen-value = ""
        v-sr-type = 0.

    run hide-disp-page.
  end.

end.

&ANALYZE-SUSPEND _UIB-CODE-BLOCK folder-block Dialog-Frame
{adm/folder.i trg-folder v-page}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE trg-folder Dialog-Frame 
PROCEDURE trg-folder :
apply "leave" to f-sec-num in frame {&frame-name}.

  if v-page-current <= infoSectionTotal:SectionNum 
  then do:
    run check-page no-error.
    if error-status:error then do:
      return error.
    end.
    run save-page.
    apply "LEAVE":U to f-car-vol      in frame {&FRAME-NAME} . 
    apply "LEAVE":U to f-tank-density in frame {&FRAME-NAME} .
    run calc-doc.
  end.
  v-page-current = v-page.
  run initialize-section.
  
end.

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE save-page Dialog-Frame
procedure save-page:
  if v-page-current > infoSectionTotal:SectionNum then return.
  assign frame {&frame-name}     
    f-sec-num f-tests f-doc-qnty f-doc-dens f-cli-qnty f-car-vol f-size
    f-num-passport f-norm-doc f-certif-fuel f-validity-certif f-list-tank
    f-a-b-tarir f-mouth f-tank-water f-tank-temp f-tank-density f-dens-temp
    f-num-plotn f-date-pov-plotn f-date-start f-hour-start f-min-start
    f-date-end f-hour-end f-min-end 
    f-doc-qnty f-doc-dens f-cli-qnty
    f-passport-plotn f-num-plotn f-place-si 
    f-num-print-prob f-kol-prob f-date-prob f-hour-prob f-min-prob f-ttn-temp f-acc-ship f-EU-weight f-loss-norm
    
  .
 
  assign
    infoSectionTotal:GetInfoSectionProp(v-page-current):CarVol = f-car-vol
    infoSectionTotal:GetInfoSectionProp(v-page-current):Tests  = f-tests
    infoSectionTotal:GetInfoSectionProp(v-page-current):SectionName  = f-sec-num
    infoSectionTotal:GetInfoSectionProp(v-page-current):DocQnty  = f-doc-qnty
    infoSectionTotal:GetInfoSectionProp(v-page-current):CliQnty  = f-cli-qnty
    infoSectionTotal:GetInfoSectionProp(v-page-current):DocDensity  = f-doc-dens
    infoSectionTotal:GetInfoSectionProp(v-page-current):TimeStart = f-hour-start * 3600 + f-min-start * 60
    infoSectionTotal:GetInfoSectionProp(v-page-current):TimeEnd = f-hour-end   * 3600 + f-min-end   * 60
    infoSectionTotal:GetInfoSectionProp(v-page-current):DateStart = f-date-start
    infoSectionTotal:GetInfoSectionProp(v-page-current):DateEnd = f-date-end
    infoSectionTotal:GetInfoSectionProp(v-page-current):Mouth =  f-mouth 
    infoSectionTotal:GetInfoSectionProp(v-page-current):TankVol = f-tank-vol 
    infoSectionTotal:GetInfoSectionProp(v-page-current):TankTemp = f-tank-temp 
    infoSectionTotal:GetInfoSectionProp(v-page-current):TankVolPomi = f-tank-vol-pomi
    infoSectionTotal:GetInfoSectionProp(v-page-current):DensTemp =  f-dens-temp    
    infoSectionTotal:GetInfoSectionProp(v-page-current):TankWater = f-tank-water  
    infoSectionTotal:GetInfoSectionProp(v-page-current):TankDensity = f-tank-density
    infoSectionTotal:GetInfoSectionProp(v-page-current):TankWeight =  f-tank-weight
    infoSectionTotal:GetInfoSectionProp(v-page-current):AccPomi =  f-acc-weight when rdc-dnstvalue = "pomi-rn"
    infoSectionTotal:GetInfoSectionProp(v-page-current):ABTarir = f-a-b-tarir
    infoSectionTotal:GetInfoSectionProp(v-page-current):AccShip = f-acc-ship 
    infoSectionTotal:GetInfoSectionProp(v-page-current):Diameter =  f-size    
    infoSectionTotal:GetInfoSectionProp(v-page-current):PlaceSi = f-place-si  
    infoSectionTotal:GetInfoSectionProp(v-page-current):TankDensityPomi = f-tank-density-pomi
    infoSectionTotal:GetInfoSectionProp(v-page-current):CertifFuel = string (f-certif-fuel)
    infoSectionTotal:GetInfoSectionProp(v-page-current):NormDoc = string (f-norm-doc)
    infoSectionTotal:GetInfoSectionProp(v-page-current):NumPassport = string (f-num-passport)
    infoSectionTotal:GetInfoSectionProp(v-page-current):ValidityCertif = string (f-validity-certif)
    infoSectionTotal:GetInfoSectionProp(v-page-current):ListTank = string (f-list-tank)
    infoSectionTotal:GetInfoSectionProp(v-page-current):PassportPlotn = f-passport-plotn
    infoSectionTotal:GetInfoSectionProp(v-page-current):DatePovPlotn = f-date-pov-plotn
    infoSectionTotal:GetInfoSectionProp(v-page-current):NumPlotn = f-num-plotn
    infoSectionTotal:GetInfoSectionProp(v-page-current):NumPrintProb = f-num-print-prob
    infoSectionTotal:GetInfoSectionProp(v-page-current):KolProb = f-kol-prob
    infoSectionTotal:GetInfoSectionProp(v-page-current):DateProb = f-date-prob
    infoSectionTotal:GetInfoSectionProp(v-page-current):HourProb = f-hour-prob
    infoSectionTotal:GetInfoSectionProp(v-page-current):MinProb = f-min-prob
    infoSectionTotal:GetInfoSectionProp(v-page-current):TTNTemp  = f-ttn-temp
    
  no-error.
  if infoSectionTotal:GetInfoSectionProp(v-page-current):PlaceSi <> 0 then do:
    if v-sr-type = 1 or v-sr-type = 2 then do:
      assign
      infoSectionTotal:GetInfoSectionProp(v-page-current):NumPlotn = f-num-plotn
      infoSectionTotal:GetInfoSectionProp(v-page-current):PassportPlotn = ""
      infoSectionTotal:GetInfoSectionProp(v-page-current):DatePovPlotn = f-date-pov-plotn.
    end.
    if v-sr-type = 3 or v-sr-type = 4 then do:
      assign
      infoSectionTotal:GetInfoSectionProp(v-page-current):NumPlotn = f-num-plotn
      infoSectionTotal:GetInfoSectionProp(v-page-current):PassportPlotn = f-passport-plotn
      infoSectionTotal:GetInfoSectionProp(v-page-current):DatePovPlotn = f-date-pov-plotn.
    end.
  end.
  
end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

