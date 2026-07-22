&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
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

Экран просмотра дополнительной информации по приемке топлива на всю накладную

Автор: Морозов Александр Сергеевич
Дата создания: 07/03/14
Author: Alexandr Morozov
Creation date: 07/03/14

*/
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Экран просмотра дополнительной информации по приемке топлива".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ str/trdcalib.i }
{ cmp/showinf.i  }
{ str/attrlist.i }
{ gbl/cur-time.i }
{ gbl/ptrlprop.i def}
{ gbl/getsect.i def }
{ gbl/color.i    }

/* Parameters Definitions ---                                            */
define input parameter parparentproc as handle no-undo .
define input parameter p-mode as character no-undo.
define input parameter p-doc-code like ub.trn-doc.doc-code   no-undo .
define input parameter table for tt-upd-attr-fuel .

define variable v-log as logical no-undo .
define variable v-autoent-obj-type as character no-undo.
define variable v-autoent-obj-code as integer no-undo.
define variable v-last-gds-code like ub.goods.gds-code no-undo .
define variable varrec-id as recid no-undo.
define variable v-no-news as logical   no-undo init false .

define variable pomi-licvalue   as character no-undo.
define variable pomi-lictype    as character no-undo.
define variable v-avai-acc-ship as logical no-undo.
define stream outstream.

define variable rdc-dnstvalue as character no-undo.
define variable rdc-dnsttype  as character no-undo.
   
define variable v-dop-info as character  no-undo .
define variable varvalue as character no-undo.
define variable vartype  as character no-undo.
define variable v-is-lgas as logical no-undo.

define buffer buf_trn-doc for ub.trn-doc .
/* Local Variable Definitions ---                                       */
{ str/valddnst.i def }

define buffer buf_goods for ub.goods .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-save b-quit b-help f-autoent-obj-code ~
f-autoent-obj-type b-clients f-car-num b-auto-tank f-condition ~
f-seals-condition f-insp-cert f-seals-condition-2 f-date-cert f-num-pasport ~
f-date-pasport f-fio f-ptbocode f-ptbotype b-ptb f-date-pour f-hour-pour ~
f-min-pour f-date-income f-hour-income f-min-income f-item-pour f-acc-ship ~
b-doc t-clear f-date-start f-date-end f-hour-start f-min-start f-hour-end ~
f-min-end 
&Scoped-Define DISPLAYED-OBJECTS f-autoent f-autoent-obj-code ~
f-autoent-obj-type f-autoent-obj-name f-car f-car-num f-condition-name ~
f-condition f-seals-1 f-seals-condition f-insp f-insp-cert f-seals-2 ~
f-seals-condition-2 f-insp-2 f-date-cert f-pasport f-num-pasport ~
f-pasport-num f-date-pasport f-fio-name f-fio f-ptbocode-1 f-ptbocode ~
f-ptbotype f-ptboname f-date-pour-1 f-date-pour f-hour-pour-2 f-hour-pour ~
f-min-pour f-date-income-2 f-date-income f-hour-income-2 f-hour-income ~
f-min-income f-item-pour-2 f-item-pour f-acc-ship-2 f-acc-ship f-doc b-doc ~
t-clear f-item-doc f-date-start f-date-end f-hour-start f-min-start ~
f-hour-end f-min-end 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-auto-tank 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "" 
     SIZE 3 BY .88.

DEFINE BUTTON b-clients 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "b-clients" 
     SIZE 3 BY .88.

DEFINE BUTTON b-help 
     LABEL "&Помощь" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-ptb 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "b-ptb" 
     SIZE 3 BY .88.

DEFINE BUTTON b-quit AUTO-END-KEY 
     LABEL "&Отмена" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-save AUTO-GO 
     LABEL "&Сохранить" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE f-acc-ship AS DECIMAL FORMAT ">>,>>9.99":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 7.25 BY 1 NO-UNDO.

DEFINE VARIABLE f-acc-ship-2 AS CHARACTER FORMAT "X(256)":U INITIAL "Допустимый % погрешности поставщика:" 
     VIEW-AS FILL-IN 
     SIZE 36.5 BY 1 NO-UNDO.

DEFINE VARIABLE f-autoent AS CHARACTER FORMAT "X(256)":U INITIAL "Автопредприятие:" 
     VIEW-AS FILL-IN 
     SIZE 16.5 BY 1 NO-UNDO.

DEFINE VARIABLE f-autoent-obj-code AS INTEGER FORMAT ">>>>>>>>9":U INITIAL ? 
     VIEW-AS FILL-IN 
     SIZE 11 BY 1 NO-UNDO.

DEFINE VARIABLE f-autoent-obj-name AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 45.5 BY 1.04 NO-UNDO.

DEFINE VARIABLE f-autoent-obj-type AS CHARACTER FORMAT "X(3)":U 
     VIEW-AS FILL-IN 
     SIZE 4 BY 1 NO-UNDO.

DEFINE VARIABLE f-car AS CHARACTER FORMAT "X(256)":U INITIAL "Гос. N автоцистерны:" 
     VIEW-AS FILL-IN 
     SIZE 20.5 BY 1 NO-UNDO.

DEFINE VARIABLE f-car-num AS CHARACTER FORMAT "X(256)":U INITIAL "?" 
     VIEW-AS FILL-IN 
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE f-condition AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 59.38 BY 1 NO-UNDO.

DEFINE VARIABLE f-condition-name AS CHARACTER FORMAT "X(256)":U INITIAL "Техническое состояние:" 
     VIEW-AS FILL-IN 
     SIZE 22.5 BY 1 NO-UNDO.

DEFINE VARIABLE f-date-cert AS DATE FORMAT "99/99/99":U 
     VIEW-AS FILL-IN 
     SIZE 13.5 BY 1 NO-UNDO.

DEFINE VARIABLE f-date-end AS DATE FORMAT "99/99/99":U 
     LABEL "Дата конца слива" 
     VIEW-AS FILL-IN 
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE f-date-income AS DATE FORMAT "99/99/99":U 
     VIEW-AS FILL-IN 
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE f-date-income-2 AS CHARACTER FORMAT "X(256)":U INITIAL "Дата прибытия на АЗС:" 
     VIEW-AS FILL-IN 
     SIZE 21.5 BY 1 NO-UNDO.

DEFINE VARIABLE f-date-pasport AS DATE FORMAT "99/99/99":U 
     VIEW-AS FILL-IN 
     SIZE 13.5 BY 1 NO-UNDO.

DEFINE VARIABLE f-date-pour AS DATE FORMAT "99/99/99":U 
     VIEW-AS FILL-IN 
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE f-date-pour-1 AS CHARACTER FORMAT "X(256)":U INITIAL "Дата налива:" 
     VIEW-AS FILL-IN 
     SIZE 21.63 BY 1 NO-UNDO.

DEFINE VARIABLE f-date-start AS DATE FORMAT "99/99/99":U 
     LABEL "Дата начала слива" 
     VIEW-AS FILL-IN 
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE f-doc AS CHARACTER FORMAT "X(256)":U INITIAL "Документы НЕ предоставлены" 
     VIEW-AS FILL-IN 
     SIZE 36.5 BY 1 NO-UNDO.

DEFINE VARIABLE f-fio AS CHARACTER FORMAT "X(256)":U INITIAL "?" 
     VIEW-AS FILL-IN 
     SIZE 53 BY 1 NO-UNDO.

DEFINE VARIABLE f-fio-name AS CHARACTER FORMAT "X(256)":U INITIAL "Ф.И.О. водителя-экспедитора:" 
     VIEW-AS FILL-IN 
     SIZE 29 BY 1 NO-UNDO.

DEFINE VARIABLE f-hour-end AS INTEGER FORMAT "99":U INITIAL 0 
     LABEL "Время конца слива" 
     VIEW-AS FILL-IN 
     SIZE 4 BY 1 NO-UNDO.

DEFINE VARIABLE f-hour-income AS INTEGER FORMAT "99":U INITIAL ? 
     VIEW-AS FILL-IN 
     SIZE 3 BY 1 NO-UNDO.

DEFINE VARIABLE f-hour-income-2 AS CHARACTER FORMAT "X(256)":U INITIAL "Время прибытия на АЗС:" 
     VIEW-AS FILL-IN 
     SIZE 23 BY 1 NO-UNDO.

DEFINE VARIABLE f-hour-pour AS INTEGER FORMAT "99":U INITIAL ? 
     VIEW-AS FILL-IN 
     SIZE 3 BY 1 NO-UNDO.

DEFINE VARIABLE f-hour-pour-2 AS CHARACTER FORMAT "X(256)":U INITIAL "Время налива:" 
     VIEW-AS FILL-IN 
     SIZE 14.13 BY 1 NO-UNDO.

DEFINE VARIABLE f-hour-start AS INTEGER FORMAT "99":U INITIAL 0 
     LABEL "Время начала слива" 
     VIEW-AS FILL-IN 
     SIZE 4 BY 1 NO-UNDO.

DEFINE VARIABLE f-insp AS CHARACTER FORMAT "X(256)":U INITIAL "Свидетельство о поверке:" 
     VIEW-AS FILL-IN 
     SIZE 24.5 BY 1 NO-UNDO.

DEFINE VARIABLE f-insp-2 AS CHARACTER FORMAT "X(256)":U INITIAL "Дата свидет. о поверке:" 
     VIEW-AS FILL-IN 
     SIZE 24.5 BY 1 NO-UNDO.

DEFINE VARIABLE f-insp-cert AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 13.5 BY 1 NO-UNDO.

DEFINE VARIABLE f-item-doc AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 82 BY 1 NO-UNDO.

DEFINE VARIABLE f-item-pour AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 82 BY 1 NO-UNDO.

DEFINE VARIABLE f-item-pour-2 AS CHARACTER FORMAT "X(256)":U INITIAL "Примечание к нефтебазе:" 
     VIEW-AS FILL-IN 
     SIZE 26 BY 1 NO-UNDO.

DEFINE VARIABLE f-min-end AS INTEGER FORMAT "99":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 4 BY 1 NO-UNDO.

DEFINE VARIABLE f-min-income AS INTEGER FORMAT "99":U INITIAL ? 
     VIEW-AS FILL-IN 
     SIZE 3 BY 1 NO-UNDO.

DEFINE VARIABLE f-min-pour AS INTEGER FORMAT "99":U INITIAL ? 
     VIEW-AS FILL-IN 
     SIZE 3 BY 1 NO-UNDO.

DEFINE VARIABLE f-min-start AS INTEGER FORMAT "99":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 4 BY 1 NO-UNDO.

DEFINE VARIABLE f-num-pasport AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 7 BY 1 NO-UNDO.

DEFINE VARIABLE f-pasport AS CHARACTER FORMAT "X(256)":U INITIAL "Паспорт качества №, дата:" 
     VIEW-AS FILL-IN 
     SIZE 25.5 BY 1 NO-UNDO.

DEFINE VARIABLE f-pasport-num AS CHARACTER FORMAT "X(256)":U INITIAL " от" 
     VIEW-AS FILL-IN 
     SIZE 5 BY 1 NO-UNDO.

DEFINE VARIABLE f-ptbocode AS INTEGER FORMAT ">>>>>>>>9":U INITIAL ? 
     VIEW-AS FILL-IN 
     SIZE 11 BY 1 NO-UNDO.

DEFINE VARIABLE f-ptbocode-1 AS CHARACTER FORMAT "X(256)":U INITIAL "Нефтебаза:" 
     VIEW-AS FILL-IN 
     SIZE 16.5 BY 1 NO-UNDO.

DEFINE VARIABLE f-ptboname AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 45.38 BY 1 NO-UNDO.

DEFINE VARIABLE f-ptbotype AS CHARACTER FORMAT "X(3)":U 
     VIEW-AS FILL-IN 
     SIZE 4 BY 1 NO-UNDO.

DEFINE VARIABLE f-seals-1 AS CHARACTER FORMAT "X(256)":U INITIAL "Пломбы:" 
     VIEW-AS FILL-IN 
     SIZE 7.5 BY 1 NO-UNDO.

DEFINE VARIABLE f-seals-2 AS CHARACTER FORMAT "X(256)":U INITIAL "Состояние пломб:" 
     VIEW-AS FILL-IN 
     SIZE 16.5 BY 1 NO-UNDO.

DEFINE VARIABLE f-seals-condition AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 33.5 BY 1 NO-UNDO.

DEFINE VARIABLE f-seals-condition-2 AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 24.5 BY 1 NO-UNDO.

DEFINE VARIABLE b-doc AS LOGICAL INITIAL no 
     LABEL "" 
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .83 NO-UNDO.

DEFINE VARIABLE t-clear AS LOGICAL INITIAL no 
     LABEL "Произведена зачистка АЦ перед наполнением на ГНС" 
     VIEW-AS TOGGLE-BOX
     SIZE 50 BY .83 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-save AT ROW 1 COL 2.13
     b-quit AT ROW 1 COL 12.13
     b-help AT ROW 1 COL 73.63
     f-autoent AT ROW 2.46 COL 1.5 NO-LABEL WIDGET-ID 80
     f-autoent-obj-code AT ROW 2.46 COL 16.13 COLON-ALIGNED NO-LABEL
     f-autoent-obj-type AT ROW 2.46 COL 27.88 COLON-ALIGNED NO-LABEL
     f-autoent-obj-name AT ROW 2.46 COL 36 COLON-ALIGNED NO-LABEL
     b-clients AT ROW 2.58 COL 34.63
     f-car AT ROW 3.75 COL 1.5 NO-LABEL WIDGET-ID 82
     f-car-num AT ROW 3.75 COL 20 COLON-ALIGNED NO-LABEL
     b-auto-tank AT ROW 3.79 COL 36.75
     f-condition-name AT ROW 5 COL 1.5 NO-LABEL WIDGET-ID 84
     f-condition AT ROW 5 COL 82.51 RIGHT-ALIGNED NO-LABEL WIDGET-ID 30
     f-seals-1 AT ROW 6.25 COL 1.5 NO-LABEL WIDGET-ID 86
     f-seals-condition AT ROW 6.25 COL 7 COLON-ALIGNED NO-LABEL
     f-insp AT ROW 6.25 COL 45.5 NO-LABEL WIDGET-ID 88
     f-insp-cert AT ROW 6.25 COL 82.5 RIGHT-ALIGNED NO-LABEL WIDGET-ID 26
     f-seals-2 AT ROW 7.38 COL 1.5 NO-LABEL WIDGET-ID 90
     f-seals-condition-2 AT ROW 7.38 COL 16 COLON-ALIGNED NO-LABEL WIDGET-ID 44
     f-insp-2 AT ROW 7.46 COL 45.5 NO-LABEL WIDGET-ID 92
     f-date-cert AT ROW 7.46 COL 82.5 RIGHT-ALIGNED NO-LABEL WIDGET-ID 34
     f-pasport AT ROW 8.63 COL 32.63 NO-LABEL WIDGET-ID 156
     f-num-pasport AT ROW 8.63 COL 64.13 RIGHT-ALIGNED NO-LABEL WIDGET-ID 154
     f-pasport-num AT ROW 8.63 COL 65 NO-LABEL WIDGET-ID 152
     f-date-pasport AT ROW 8.63 COL 82.5 RIGHT-ALIGNED NO-LABEL WIDGET-ID 150
     f-fio-name AT ROW 9.75 COL 1.38 NO-LABEL WIDGET-ID 94
     f-fio AT ROW 9.75 COL 82.38 RIGHT-ALIGNED NO-LABEL
     f-ptbocode-1 AT ROW 11 COL 1.38 NO-LABEL WIDGET-ID 96
     f-ptbocode AT ROW 11 COL 16 COLON-ALIGNED NO-LABEL
     f-ptbotype AT ROW 11 COL 27.75 COLON-ALIGNED NO-LABEL
     f-ptboname AT ROW 11 COL 82.38 RIGHT-ALIGNED NO-LABEL
     b-ptb AT ROW 11.08 COL 34.5
     f-date-pour-1 AT ROW 12.17 COL 1.38 NO-LABEL WIDGET-ID 98
     f-date-pour AT ROW 12.17 COL 20.88 COLON-ALIGNED NO-LABEL WIDGET-ID 40
     f-hour-pour-2 AT ROW 12.25 COL 38.13 NO-LABEL WIDGET-ID 100
     f-hour-pour AT ROW 12.25 COL 59.63 COLON-ALIGNED NO-LABEL WIDGET-ID 38
     f-min-pour AT ROW 12.25 COL 63.13 COLON-ALIGNED NO-LABEL WIDGET-ID 36
     f-date-income-2 AT ROW 13.5 COL 1.5 NO-LABEL WIDGET-ID 160
     f-date-income AT ROW 13.5 COL 21 COLON-ALIGNED NO-LABEL WIDGET-ID 158
     f-hour-income-2 AT ROW 13.5 COL 38.13 NO-LABEL WIDGET-ID 102
     f-hour-income AT ROW 13.5 COL 59.75 COLON-ALIGNED NO-LABEL
     f-min-income AT ROW 13.5 COL 67.13 RIGHT-ALIGNED NO-LABEL
     f-item-pour-2 AT ROW 15.5 COL 1.38 NO-LABEL WIDGET-ID 104
     f-item-pour AT ROW 16.63 COL 82.38 RIGHT-ALIGNED NO-LABEL
     f-acc-ship-2 AT ROW 17.79 COL 1.38 NO-LABEL WIDGET-ID 106
     f-acc-ship AT ROW 17.79 COL 38 NO-LABEL WIDGET-ID 42
     f-doc AT ROW 18 COL 4.38 NO-LABEL WIDGET-ID 108
     b-doc AT ROW 18.08 COL 1.88 WIDGET-ID 48
     t-clear AT ROW 18.08 COL 31.88 WIDGET-ID 148
     f-item-doc AT ROW 19.17 COL 82.38 RIGHT-ALIGNED NO-LABEL WIDGET-ID 46
     f-date-start AT ROW 20.33 COL 19.13 COLON-ALIGNED WIDGET-ID 60
     f-date-end AT ROW 20.33 COL 59.38 COLON-ALIGNED WIDGET-ID 58
     f-hour-start AT ROW 21.5 COL 19 COLON-ALIGNED WIDGET-ID 50
     f-min-start AT ROW 21.5 COL 23.5 COLON-ALIGNED NO-LABEL WIDGET-ID 54
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         DEFAULT-BUTTON b-save CANCEL-BUTTON b-quit.

/* DEFINE FRAME statement is approaching 4K Bytes.  Breaking it up   */
DEFINE FRAME Dialog-Frame
     f-hour-end AT ROW 21.5 COL 59.5 COLON-ALIGNED WIDGET-ID 52
     f-min-end AT ROW 21.5 COL 64.13 COLON-ALIGNED NO-LABEL WIDGET-ID 56
     "Примечание к нефтебазе" VIEW-AS TEXT
          SIZE 25.5 BY 1 AT ROW 15.5 COL 1
     SPACE(57.12) SKIP(7.03)
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

/* SETTINGS FOR FILL-IN f-acc-ship IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN f-acc-ship-2 IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN f-autoent IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN f-autoent-obj-name IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN f-car IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN f-condition IN FRAME Dialog-Frame
   ALIGN-R                                                              */
/* SETTINGS FOR FILL-IN f-condition-name IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN f-date-cert IN FRAME Dialog-Frame
   ALIGN-R                                                              */
/* SETTINGS FOR FILL-IN f-date-income-2 IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN f-date-pasport IN FRAME Dialog-Frame
   ALIGN-R                                                              */
/* SETTINGS FOR FILL-IN f-date-pour-1 IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN f-doc IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN f-fio IN FRAME Dialog-Frame
   ALIGN-R                                                              */
/* SETTINGS FOR FILL-IN f-fio-name IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN f-hour-income-2 IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN f-hour-pour-2 IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN f-insp IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN f-insp-2 IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN f-insp-cert IN FRAME Dialog-Frame
   ALIGN-R                                                              */
/* SETTINGS FOR FILL-IN f-item-doc IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-R                                                    */
/* SETTINGS FOR FILL-IN f-item-pour IN FRAME Dialog-Frame
   ALIGN-R                                                              */
/* SETTINGS FOR FILL-IN f-item-pour-2 IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN f-min-income IN FRAME Dialog-Frame
   ALIGN-R                                                              */
/* SETTINGS FOR FILL-IN f-num-pasport IN FRAME Dialog-Frame
   ALIGN-R                                                              */
/* SETTINGS FOR FILL-IN f-pasport IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN f-pasport-num IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN f-ptbocode-1 IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN f-ptboname IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-R                                                    */
/* SETTINGS FOR FILL-IN f-seals-1 IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN f-seals-2 IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Дополнительная информация по приемке топлива */
DO: 
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



  assign frame {&frame-name}  f-autoent-obj-code
                              f-autoent-obj-name
                              f-autoent-obj-type
                              f-car-num
                              f-condition
                              f-seals-condition
                              f-seals-condition-2
                              f-insp-cert
                              f-date-cert
                              f-pasport
                              f-pasport-num
                              f-date-pasport
                              f-num-pasport
                              f-fio
                              f-ptbocode
                              f-ptbotype
                              f-ptboname
                              f-hour-income
                              f-min-income
                              f-item-pour
                              f-hour-pour
                              f-min-pour
                              f-date-pour
                              f-date-income
                              f-acc-ship
                              b-doc
                              f-item-doc
                              f-hour-start
                              f-min-start
                              f-hour-end
                              f-min-end
                              f-date-start
                              f-date-end
                              t-clear
  .
 
  if input frame {&frame-name} f-hour-income <> ?
    and input frame {&frame-name} f-hour-income > 24
  then do:
     message "Неверно заведено поле <<час>>." view-as alert-box .
     apply "entry" to f-hour-income in frame {&frame-name} .
     return no-apply .
  end.

  
  
  if input frame {&frame-name} f-min-income > 60
  then do:
     message "Неверно заведено поле <<минуты>>." view-as alert-box .
     apply "entry" to f-min-income in frame {&frame-name} .
     return no-apply .
  end.
  
  /*find ub.clients no-lock where
       ub.clients.obj-type = f-ptbocode and
       ub.clients.obj-code = f-ptbotype no-error .
  
  
  find ub.clients no-lock where
       ub.clients.obj-type = f-autoent-obj-type and
       ub.clients.obj-code = f-autoent-obj-code no-error .
  if not available ub.clients
  then do:
    assign
      v-log = no
    .
    message "Автопредприятие " f-autoent-obj-type " " f-autoent-obj-code " " f-autoent-obj-name  
    "не является перевозчиком для Нефтебазы "  "." 
    skip
    "Cохранить?"
    view-as alert-box question buttons yes-no update v-log .
    if v-log <> yes
    then do:
      return no-apply .
    end.
    assign
      f-autoent-obj-type = ""
      f-autoent-obj-code = ?
    .
  end.*/
  
/*  if f-car-num:SCREEN-VALUE = "" or f-car-num:SCREEN-VALUE = "?" then do:*/
/*    MESSAGE "Введите Гос.№ автоцистерны."                                */
/*    VIEW-AS ALERT-BOX.                                                   */
/*      return no-apply .                                                  */
/*  end.                                                                   */
  
/*  if f-insp-cert:screen-value = "" then do:  */
/*    MESSAGE "Введите свидетельство о поверке"*/
/*    VIEW-AS ALERT-BOX.                       */
/*    return no-apply.                         */
/*  end.                                       */
  
/*  if input frame {&frame-name} f-date-cert = ""                          */
/*    then do:                                                             */
/*      message "Введите дату свидетельства о поверке." view-as alert-box .*/
/*      apply "entry" to f-date-cert in frame {&frame-name} .              */
/*      return no-apply .                                                  */
/*    end.                                                                 */
  
/*  if f-fio:SCREEN-VALUE = "" or f-fio:SCREEN-VALUE = "?" then do:*/
/*    MESSAGE "Введите Ф.И.О. водителя-экспедитора"                */
/*    VIEW-AS ALERT-BOX.                                           */
/*    return no-apply.                                             */
/*  end.                                                           */
/*                                                                 */
/*  if f-min-income = ? or f-hour-income = ? then do:              */
/*    MESSAGE "Введите время прибытия на АЗС"                      */
/*    VIEW-AS ALERT-BOX.                                           */
/*    return no-apply.                                             */
/*  end.                                                           */
  
/*  if f-min-pour = ? or f-hour-pour = ? then do:*/
/*    MESSAGE "Введите время налива"             */
/*    VIEW-AS ALERT-BOX.                         */
/*    return no-apply.                           */
/*  end.                                         */
  
  find ub.clients no-lock where
       ub.clients.obj-type = f-ptbotype and
       ub.clients.obj-code = f-ptbocode no-error .
  if not available ub.clients
  then do:
/*    assign                                                             */
/*      v-log = no                                                       */
/*    .                                                                  */
/*    message "Не найдена нефтебаза " f-ptbotype " " f-ptbocode " ." skip*/
/*            "Cохраняемся без ссылки на нефтебазу?"                     */
/*    view-as alert-box question buttons yes-no update v-log .           */
/*    if v-log <> yes                                                    */
/*    then do:                                                           */
/*      return no-apply .                                                */
/*    end.                                                               */
    assign
      f-ptbotype = ""
      f-ptbocode = ?
    .
  end.
  
  run save-attr.



/*  assign
    p-car-num          = f-car-num
    p-car-vol          = string( f-car-vol )
    p-tests            = f-insp-cert
    p-autoent-obj-type = f-autoent-obj-type
    p-autoent-obj-code = string( f-autoent-obj-code )
    p-item-pour        = f-item-pour
    p-time-pour        = string( f-hour-income,   "99":U ) + ":" + string( f-min-income,   "99":U )
    p-time-income      = string( f-hour-income, "99":U ) + ":" + string( f-min-income, "99":U )
    p-time-start       = f-hour-start * 3600 + f-min-start * 60
    p-time-end         = f-hour-end   * 3600 + f-min-end   * 60
    p-date-start       = f-date-start
    p-date-end         = f-date-end
    p-mouth            = string( f-mouth )
    p-fio              = f-fio
    p-ptbotype         = f-ptbotype
    p-ptbocode         = string( f-ptbocode     )
    p-tank-vol         = string( f-tank-vol     )
    p-tank-temp        = string( f-tank-temp    )
    p-tank-water       = string( f-tank-water   )
    p-tank-density     = string( f-tank-density )
    p-tank-weight      = string( f-tank-weight  )
    p-a-b-tarir        = string( f-a-b-tarir    )
    p-diameter         = string( f-diameter     )
    p-place-si         = string( f-place-si     )
    p-tank-density-pomi = string( f-tank-density-pomi )

  no-error .*/
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Дополнительная информация по приемке топлива */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-auto-tank
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-auto-tank Dialog-Frame
ON CHOOSE OF b-auto-tank IN FRAME Dialog-Frame
DO:
  define variable v-rec-tank as recid     no-undo.
  define variable v-rec-meas as recid     no-undo.
  assign v-rec-tank = ?
         v-rec-meas = ?.
  
  run str/auto-tn.w (input parparentproc,
              input "b-sel",
              input v-autoent-obj-type,
              input v-autoent-obj-code,
              output v-rec-tank,
              output v-rec-meas) no-error.
  
/*  if v-autoent-obj-code <> 0 and v-autoent-obj-code <> ?                                                                             */
/*  and can-find (first auto-tank-attr no-lock where auto-tank-attr.attr-code = "auto-firm"                                            */
/*                                               and (auto-tank-attr.attr-value = v-autoent-obj-type + string(v-autoent-obj-code)      */
/*                                               or auto-tank-attr.attr-value = v-autoent-obj-type + " " + string(v-autoent-obj-code)))*/
/*  then do :                                                                                                                          */
/*    run str/auto-tn.w (input parparentproc,                                                                                          */
/*                  input "b-sel",                                                                                                     */
/*                  input v-autoent-obj-type,                                                                                          */
/*                  input v-autoent-obj-code,                                                                                          */
/*                  output v-rec-tank,                                                                                                 */
/*                  output v-rec-meas) no-error.                                                                                       */
/*  end.                                                                                                                               */
/*  do :                                                                                                                               */
/*    message                                                                                                                          */
/*    "Вы не указали автопредприятие или для " skip                                                                                    */
/*    "указанного автопредприятия нет автоцистерн."   skip                                                                             */
/*    "Справочник будет открыт для всех автоцистерн." skip                                                                             */
/*    view-as alert-box information.                                                                                                   */
/*    run str/auto-tn.w (input parparentproc,                                                                                          */
/*                  input "b-sel",                                                                                                     */
/*                  input "",                                                                                                          */
/*                  input 0,                                                                                                           */
/*                  output v-rec-tank,                                                                                                 */
/*                  output v-rec-meas) no-error.                                                                                       */
/*  end.                                                                                                                               */
  if v-rec-tank <> ? then do:
    find first auto-tank where recid (auto-tank) = v-rec-tank no-lock.
    assign
        f-car-num    = auto-tank.auto-num
    .
/*    find first auto-tank-attr where auto-tank-attr.attr-code = "auto-firm" and auto-tank-attr.auto-num = auto-tank.auto-num no-error.*/
/*    if available (auto-tank-attr)                                                                                                    */
/*    then do:                                                                                                                         */
    assign
      f-autoent-obj-type = auto-tank.firm-type
      f-autoent-obj-code = integer (auto-tank.firm-code).
      f-autoent-obj-type:screen-value = f-autoent-obj-type.
      f-autoent-obj-code:screen-value = string (f-autoent-obj-code).
    assign
      v-autoent-obj-type = f-autoent-obj-type
      v-autoent-obj-code =  f-autoent-obj-code
    .
/*    end.*/
          
    display f-car-num with frame {&frame-name}.
  end.
  apply "leave" to f-car-num in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-clients
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-clients Dialog-Frame
ON CHOOSE OF b-clients IN FRAME Dialog-Frame /* b-clients */
DO:
define variable ref-list as character no-undo.
define variable ref-rec  as recid     no-undo.

find first ub.trn-doc no-lock where ub.trn-doc.doc-code = p-doc-code no-error.
   run ref/cli-all.w (parparentproc
                , "b-sel"
                , {&cmp}
                , ?
                , ?
                , ?
                , ?
                , substitute("auto-tank-for-supp=&1&2",ub.trn-doc.cli-type,ub.trn-doc.cli-code)
                , output ref-list) .
if ref-list <> "" then do:
  ref-rec = integer (ref-list).
  find ub.clients where recid ( ub.clients ) = ref-rec no-lock.
  disp ub.clients.obj-code @ f-autoent-obj-code
       ub.clients.obj-type @ f-autoent-obj-type
       ub.clients.obj-name @ f-autoent-obj-name with frame {&frame-name}.
  assign
    v-autoent-obj-type = ub.clients.obj-type
    v-autoent-obj-code = ub.clients.obj-code
  .
end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-doc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-doc Dialog-Frame
ON VALUE-CHANGED OF b-doc IN FRAME Dialog-Frame
DO:
  if b-doc:SCREEN-VALUE = "yes" then do:
    enable 
    f-item-doc 
    with frame Dialog-Frame .
  end.
  else do:
    HIDE 
    f-item-doc 
    in frame Dialog-Frame .
  end.    
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-ptb
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-ptb Dialog-Frame
ON CHOOSE OF b-ptb IN FRAME Dialog-Frame /* b-ptb */
DO:
define variable ref-list as character no-undo.
define variable ref-rec  as recid     no-undo.

  find first ub.trn-doc no-lock where ub.trn-doc.doc-code = p-doc-code no-error.
     run ref/cli-all.w (parparentproc
                  , "b-sel"
                  , {&cmp}
                  , ?
                  , ?
                  , ?
                  , ?
                  , substitute("tank-farm-for-supp=&1&2",ub.trn-doc.cli-type,ub.trn-doc.cli-code)
                  , output ref-list) .
  if ref-list <> "" then do:
    ref-rec = integer (ref-list).
    find ub.clients where recid ( ub.clients ) = ref-rec no-lock.
    disp ub.clients.obj-code @ f-ptbocode
         ub.clients.obj-type @ f-ptbotype
         ub.clients.obj-name @ f-ptboname with frame {&frame-name}.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-acc-ship
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-acc-ship Dialog-Frame
ON return OF f-acc-ship IN FRAME Dialog-Frame
DO:
    apply "entry" to f-hour-income in frame {&frame-name}.
return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-autoent-obj-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-autoent-obj-code Dialog-Frame
ON LEAVE OF f-autoent-obj-code IN FRAME Dialog-Frame
DO:
  run disp-obj-name.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-autoent-obj-code Dialog-Frame
ON RETURN OF f-autoent-obj-code IN FRAME Dialog-Frame
DO:
run disp-obj-name.
apply "entry" to f-autoent-obj-code in frame {&frame-name}.
return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-autoent-obj-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-autoent-obj-type Dialog-Frame
ON LEAVE OF f-autoent-obj-type IN FRAME Dialog-Frame
DO:
    run disp-obj-name.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-autoent-obj-type Dialog-Frame
ON return OF f-autoent-obj-type IN FRAME Dialog-Frame
DO:
  run disp-obj-name.
  apply "entry" to f-car-num in frame {&frame-name}.
return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-car-num
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-car-num Dialog-Frame
ON leave OF f-car-num IN FRAME Dialog-Frame
DO:
  assign
    f-car-num.
  find first auto-tank where auto-tank.auto-num = f-car-num no-lock no-error.
  if not available (auto-tank) and not (f-car-num = ? or f-car-num = "" or f-car-num = "?")
  then do:
   message "АЦ с таким гос. номером не найдена. Введите корректный номер АЦ или выберите из справочника." view-as alert-box information title "Сообщение".
   apply "entry" to f-car-num in frame {&frame-name} .
   return no-apply .
  end.
   if available auto-tank
      then 
   do :
      if auto-tank.firm-type <> "" then 
      do:
         assign
            f-autoent-obj-type = auto-tank.firm-type
            f-autoent-obj-code = integer (auto-tank.firm-code).
      end.
      else 
      do:
         find first auto-tank-attr where auto-tank-attr.attr-code = "auto-firm" and auto-tank-attr.auto-num = auto-tank.auto-num no-error.
         if available (auto-tank-attr)
            then 
         do:
            assign
               f-autoent-obj-type = substring (auto-tank-attr.attr-value, 1, 3)
               f-autoent-obj-code = integer (substring (auto-tank-attr.attr-value, 4)).
         end.       
      end.     
      f-autoent-obj-type:screen-value = f-autoent-obj-type.
      f-autoent-obj-code:screen-value = string (f-autoent-obj-code).
      assign
         v-autoent-obj-type = f-autoent-obj-type
         v-autoent-obj-code = f-autoent-obj-code
         .
      run disp-obj-name.
   end .
  
/*  apply "entry" to f-car-vol in frame {&frame-name}.*/

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-car-num Dialog-Frame
ON return OF f-car-num IN FRAME Dialog-Frame
DO:
  
  apply "leave" to f-car-num in frame {&frame-name} .
  
/*  apply "entry" to f-car-vol in frame {&frame-name}.*/

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-condition
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-condition Dialog-Frame
ON return OF f-condition IN FRAME Dialog-Frame
DO:
    apply "entry" to f-item-pour in frame {&frame-name}.
return no-apply.



END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-date-cert
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-date-cert Dialog-Frame
ON return OF f-date-cert IN FRAME Dialog-Frame
DO:
/*  apply "entry" to f-car-vol in frame {&frame-name}.*/
return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-date-pasport
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-date-pasport Dialog-Frame
ON return OF f-date-pasport IN FRAME Dialog-Frame
DO:
/*  apply "entry" to f-car-vol in frame {&frame-name}.*/
return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-hour-income
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-hour-income Dialog-Frame
ON LEAVE OF f-hour-income IN FRAME Dialog-Frame
DO:
  if input frame {&frame-name} f-hour-income > 24
  then do:
     message "Неверно заведено поле <<час>>." view-as alert-box .
     apply "entry" to f-hour-income in frame {&frame-name} .
     return no-apply .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-hour-income Dialog-Frame
ON return OF f-hour-income IN FRAME Dialog-Frame
DO:
      apply "entry" to f-min-income in frame {&frame-name}.
return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-hour-pour
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-hour-pour Dialog-Frame
ON LEAVE OF f-hour-pour IN FRAME Dialog-Frame
DO:
  if input frame {&frame-name} f-hour-income > 24
  then do:
     message "Неверно заведено поле <<час>>." view-as alert-box .
     apply "entry" to f-hour-income in frame {&frame-name} .
     return no-apply .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-hour-pour Dialog-Frame
ON return OF f-hour-pour IN FRAME Dialog-Frame
DO:
      apply "entry" to f-min-income in frame {&frame-name}.
return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-hour-start
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-hour-start Dialog-Frame
ON LEAVE OF f-hour-start IN FRAME Dialog-Frame /* Время начала слива */
DO:
  if input frame {&frame-name} f-hour-start > 24
  then do:
     message "Неверно заведено поле <<минуты>>." view-as alert-box .
     apply "entry" to f-hour-start in frame {&frame-name} .
     return no-apply .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-insp-cert
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-insp-cert Dialog-Frame
ON return OF f-insp-cert IN FRAME Dialog-Frame
DO:
    apply "entry" to f-item-pour in frame {&frame-name}.
return no-apply.



END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-item-doc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-item-doc Dialog-Frame
ON return OF f-item-doc IN FRAME Dialog-Frame
DO:
/*    apply "entry" to f-hour-income in frame {&frame-name}.*/
return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-item-pour
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-item-pour Dialog-Frame
ON return OF f-item-pour IN FRAME Dialog-Frame
DO:
    apply "entry" to f-hour-income in frame {&frame-name}.
return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-min-end
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-min-end Dialog-Frame
ON LEAVE OF f-min-end IN FRAME Dialog-Frame
DO:
  if input frame {&frame-name} f-min-end > 60
  then do:
     message "Неверно заведено поле <<минуты>>." view-as alert-box .
     apply "entry" to f-hour-start in frame {&frame-name} .
     return no-apply .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-min-income
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-min-income Dialog-Frame
ON LEAVE OF f-min-income IN FRAME Dialog-Frame
DO:
  if input frame {&frame-name} f-min-income > 60
  then do:
     message "Неверно заведено поле <<минуты>>." view-as alert-box .
     apply "entry" to f-min-income in frame {&frame-name} .
     return no-apply .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-min-income Dialog-Frame
ON return OF f-min-income IN FRAME Dialog-Frame
DO:

return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-min-pour
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-min-pour Dialog-Frame
ON LEAVE OF f-min-pour IN FRAME Dialog-Frame
DO:
  if input frame {&frame-name} f-min-income > 60
  then do:
     message "Неверно заведено поле <<минуты>>." view-as alert-box .
     apply "entry" to f-min-income in frame {&frame-name} .
     return no-apply .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-min-pour Dialog-Frame
ON return OF f-min-pour IN FRAME Dialog-Frame
DO:

return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-min-start
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-min-start Dialog-Frame
ON LEAVE OF f-min-start IN FRAME Dialog-Frame
DO:
  if input frame {&frame-name} f-min-start > 60
  then do:
     message "Неверно заведено поле <<минуты>>." view-as alert-box .
     apply "entry" to f-hour-start in frame {&frame-name} .
     return no-apply .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-num-pasport
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-num-pasport Dialog-Frame
ON return OF f-num-pasport IN FRAME Dialog-Frame
DO:
/*  apply "entry" to f-car-vol in frame {&frame-name}.*/
return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-ptbocode
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-ptbocode Dialog-Frame
ON LEAVE OF f-ptbocode IN FRAME Dialog-Frame
DO:
  run disp-f-ptboname.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-ptbocode Dialog-Frame
ON RETURN OF f-ptbocode IN FRAME Dialog-Frame
DO:
    run disp-f-ptboname.
apply "entry" to f-ptbocode in frame {&frame-name}.
return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-ptbotype
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-ptbotype Dialog-Frame
ON LEAVE OF f-ptbotype IN FRAME Dialog-Frame
DO:
    run disp-f-ptboname.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-ptbotype Dialog-Frame
ON return OF f-ptbotype IN FRAME Dialog-Frame
DO:
    run disp-f-ptboname.
    apply "entry" to f-hour-income in frame {&frame-name}.
return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-seals-condition
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-seals-condition Dialog-Frame
ON return OF f-seals-condition IN FRAME Dialog-Frame
DO:
    apply "entry" to f-item-pour in frame {&frame-name}.
return no-apply.



END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-seals-condition-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-seals-condition-2 Dialog-Frame
ON return OF f-seals-condition-2 IN FRAME Dialog-Frame
DO:
    apply "entry" to f-item-pour in frame {&frame-name}.
return no-apply.



END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame 


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.
{ gbl/app_help.i }
/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  
  define buffer buf_doc-attr for ub.doc-attr.
  

  
  { str/tdat-val.i
     p-doc-code
     {&trdcattr-trn-lgas-corr}
     varvalue
     vartype
     no-error
  }

  if not varvalue = ""
    then frame {&frame-name}:title = "Дополнительная информация по корр. накладной СУГ. Исх.накл. - " + varvalue.
    
  { str/tdat-val.i
     p-doc-code
     {&trdcattr-is-lgas}
     varvalue
     vartype
     no-error
   }
   
   if varvalue = "yes" then do:
     assign
       v-is-lgas = true.

   end.
   
   { str/tdat-val.i
     p-doc-code
     {&trdcattr-is-lgas-corr}
     varvalue
     vartype
     no-error
   }

  if varvalue = "yes" then do:
     assign
       v-is-lgas = true.

  end.
  
  for each tt-upd-attr-fuel no-lock:

    find first buf_doc-attr no-lock
      where buf_doc-attr.doc-code  = p-doc-code
        and buf_doc-attr.attr-code = tt-upd-attr-fuel.code
      no-error .
    
    if available buf_doc-attr then do:  
      case tt-upd-attr-fuel.code:
        when {&trdcattr-ptbobj} then do:
            assign
              f-ptbotype = entry (1, buf_doc-attr.attr-value, ";")
              f-ptbocode = integer (entry (2, buf_doc-attr.attr-value, ";"))
            no-error.
            find first clients no-lock
              where clients.obj-type = f-ptbotype
                and clients.obj-code = f-ptbocode
              no-error.
            if available clients 
              then assign f-ptboname = clients.obj-name.
              else 
                assign f-ptboname = ""
                f-ptbotype = ""
                f-ptbotype = ?.
  
        end.
        when {&trdcattr-ptb-item-pour} then do:
            assign
              f-item-pour = buf_doc-attr.attr-value
            .
        end.
        when {&trdcattr-autoent} then do:
            assign
              f-autoent-obj-type = entry (1, buf_doc-attr.attr-value, ";")
              f-autoent-obj-code = integer (entry (2, buf_doc-attr.attr-value, ";"))
            no-error.
            assign
              v-autoent-obj-type = f-autoent-obj-type
              v-autoent-obj-code = f-autoent-obj-code
            .
            find first ub.clients no-lock
              where ub.clients.obj-type = f-autoent-obj-type
                and ub.clients.obj-code = f-autoent-obj-code
              no-error.
            if available ub.clients then do:
              assign
                f-autoent-obj-name = ub.clients.obj-name
              .
            end.
            else do:
              assign
                f-autoent-obj-name = ?
                f-autoent-obj-code = ?
                f-autoent-obj-type = ""
              .
            end.
        end.
        when {&trdcattr-car-num} then do:
            assign
              f-car-num = buf_doc-attr.attr-value
            .
        end.
        when {&trdcattr-fio-driver} then do:
            assign
              f-fio = buf_doc-attr.attr-value
            .
        end.
        when {&trdcattr-time-income} then do:
  
          assign f-hour-income = integer(substring(buf_doc-attr.attr-value, 1, 2)) no-error.
          if error-status:error then do:
            message "Неверное время прибытия " buf_doc-attr.attr-value
            view-as alert-box.
            assign f-hour-income = 0
                    f-min-income  = 0.
          end.
          else do:
            assign f-min-income = integer(substring(buf_doc-attr.attr-value, 4, 2)) no-error.
            if error-status:error then do:
                message "Неверное время прибытия " buf_doc-attr.attr-value
                view-as alert-box.
                assign f-hour-income = 0
                      f-min-income  = 0.
            end.
          end.
        end.
        when {&trdcattr-time-pour} then do:
            assign f-hour-pour = integer(substring(buf_doc-attr.attr-value, 1, 2)) no-error.
          if error-status:error then do:
            message "Неверное время налива " buf_doc-attr.attr-value
            view-as alert-box.
            assign f-hour-pour = 0
                    f-min-pour  = 0.
          end.
          else do:
            assign f-min-pour = integer(substring(buf_doc-attr.attr-value, 4, 2)) no-error.
            if error-status:error then do:
                message "Неверное время налива " buf_doc-attr.attr-value
                view-as alert-box.
                assign f-hour-pour = 0
                      f-min-pour  = 0.
            end.
          end.
        end.
        when {&trdcattr-time-start} then do:
            assign f-hour-start = integer(substring(buf_doc-attr.attr-value, 1, 2)) no-error.
          if error-status:error then do:
            message "Неверное время начала слива " buf_doc-attr.attr-value
            view-as alert-box.
            assign f-hour-start = 0
                    f-min-start  = 0.
          end.
          else do:
            assign f-min-start = integer(substring(buf_doc-attr.attr-value, 4, 2)) no-error.
            if error-status:error then do:
                message "Неверное время начала слива " buf_doc-attr.attr-value
                view-as alert-box.
                assign f-hour-start = 0
                      f-min-start  = 0.
            end.
          end.
        end.
        when {&trdcattr-time-end} then do:
            assign f-hour-end = integer(substring(buf_doc-attr.attr-value, 1, 2)) no-error.
          if error-status:error then do:
            message "Неверное время конца слива " buf_doc-attr.attr-value
            view-as alert-box.
            assign f-hour-end = 0
                    f-min-end  = 0.
          end.
          else do:
            assign f-min-end = integer(substring(buf_doc-attr.attr-value, 4, 2)) no-error.
            if error-status:error then do:
                message "Неверное время конца слива " buf_doc-attr.attr-value
                view-as alert-box.
                assign f-hour-end = 0
                      f-min-end = 0.
            end.
          end.
        end.
        when {&trdcattr-date-pour} then do:
            assign
              f-date-pour = date(buf_doc-attr.attr-value).
        end.
        when {&trdcattr-date-income} then do:
            assign
              f-date-income = date(buf_doc-attr.attr-value).
        end.
        when {&trdcattr-inspection-cert} then do:
            assign
              f-insp-cert = buf_doc-attr.attr-value.
        end.
        when {&trdcattr-date-cert} then do:
            assign
              f-date-cert = date(buf_doc-attr.attr-value).
        end.
        when {&trdcattr-date-pasport} then do:
            assign
              f-date-pasport = date(buf_doc-attr.attr-value).
        end.
        when {&trdcattr-num-pasport} then do:
            assign
              f-num-pasport = buf_doc-attr.attr-value.
        end.
        when {&trdcattr-condition} then do:
            assign
              f-condition = buf_doc-attr.attr-value.
        end.
        when {&trdcattr-seals-condition} then do:
            if num-entries (buf_doc-attr.attr-value, {&delim-par}) = 2
            then do:
              assign
                f-seals-condition = entry (1, buf_doc-attr.attr-value, {&delim-par})
                f-seals-condition-2 = entry (2, buf_doc-attr.attr-value, {&delim-par})
              .              
            end.
            else
              assign
                f-seals-condition = buf_doc-attr.attr-value.
        end.
/*        when {&trdcattr-acc-ship} then do:                            */
/*            assign                                                    */
/*              f-acc-ship = decimal (buf_doc-attr.attr-value) no-error.*/
/*              v-avai-acc-ship = true.                                 */
/*        end.                                                          */
        when {&trdcattr-doc-not} then do:
            assign
              b-doc =  logical(buf_doc-attr.attr-value) no-error.
        end.     
        when {&trdcattr-clear-ac} then do:
            assign
              t-clear =  logical(buf_doc-attr.attr-value) no-error.
        end.    
        when {&trdcattr-spisok-not-doc} then do:
            assign
              f-item-doc =  buf_doc-attr.attr-value no-error.
        end.
        when {&trdcattr-date-start} then do:
            assign
              f-date-start = date(buf_doc-attr.attr-value).
        end.
        when {&trdcattr-date-end} then do:
            assign
              f-date-end = date(buf_doc-attr.attr-value).
        end.
      end case.
    end.

    
    /*assign
      f-car-vol = decimal(p-car-vol) no-error
    .
    if error-status:error then
      message "Неверно задан объем автоцистерны по паспорту " p-car-vol " ."
      view-as alert-box error.*/
    


/*    assign
    f-tank-vol  = decimal(p-tank-vol) no-error.
    if error-status:error then
      message "Неверно определен объем в цистерне " p-tank-vol " . "
      view-as alert-box.
    assign.*/

  end.
  
  if not v-avai-acc-ship
    then f-acc-ship = 0.25.
  
  RUN enable_UI.
  run gbl/conf-rd.p ("rdc-dnst", "", "", 0, "", "", "", no, output rdc-dnstvalue, output rdc-dnsttype) no-error.  
  display
      f-autoent-obj-code
      f-autoent-obj-name
      f-autoent-obj-type
      f-car-num
      b-clients
      b-ptb
      b-auto-tank
      f-condition
      f-seals-condition
      f-seals-condition-2
      f-insp-cert
      f-date-cert
      f-num-pasport
      f-date-pasport
      f-fio
      f-ptbocode
      f-ptbotype
      f-ptboname
      f-hour-income
      f-min-income
      f-item-pour
      f-hour-pour
      f-min-pour
      f-date-pour
      f-date-income
      f-hour-pour
      f-min-pour
      b-save
      f-acc-ship
      b-doc
      f-date-start
      f-date-end
    with frame {&frame-name}.
    if b-doc = no then do:
        hide
            f-item-doc
        in frame {&frame-name} . 
    end.
    
    hide
        f-hour-start
        f-hour-end
        f-min-end
        f-min-start
        f-date-start
        f-date-end
        t-clear
    in frame Dialog-Frame . 

   
    if v-is-lgas then do:
      display
        f-hour-start
        f-hour-end
        f-min-end
        f-min-start
        f-date-start
        f-date-end
        t-clear
      with frame Dialog-Frame .
    end. 
    hide 
    f-acc-ship-2 f-acc-ship
    in frame Dialog-Frame .

    
  find first ub.trn-doc no-lock where ub.trn-doc.doc-code = p-doc-code no-error.
  { gbl/ptrlprop.i
    run
    ub.trn-doc.obj-type
    ub.trn-doc.obj-code
  }
  if ptrlprop-mand-choice-autocar
  then do:
    disable f-car-num with frame {&frame-name}.
  end. 
  
  if p-mode <> {&update} and  p-mode <> {&add-def} then do:
    disable
      f-autoent-obj-code
      f-autoent-obj-name
      f-autoent-obj-type
      f-car-num
      b-clients
      b-ptb
      b-auto-tank
      f-condition
      f-seals-condition
      f-seals-condition-2
      f-insp-cert
      f-date-cert
      f-num-pasport
      f-date-pasport
      f-fio
      f-ptbocode
      f-ptbotype
      f-ptboname
      f-hour-income
      f-min-income
      f-item-pour
      f-date-pour
      f-date-income
      f-hour-pour
      f-min-pour
      b-save
      f-acc-ship
      b-doc
      f-hour-start
      f-hour-end
      f-min-end
      f-min-start
      f-date-start
      f-date-end
      t-clear
      with frame {&frame-name}.
  end.
/*  assign                      */
/*    f-car-num:fgcolor = 12    */
/*    f-fio:fgcolor = 12        */
/*    f-min-income:fgcolor = 12 */
/*    f-hour-income:fgcolor = 12*/
/*  .                           */

find first buf_trn-doc no-lock where buf_trn-doc.doc-code = p-doc-code .
  v-dop-info = "".
        { gbl/getsect.i run buf_trn-doc.obj-type buf_trn-doc.obj-code {&attr-petrol} }
        for each thbjattr_thbj-attr :
            if thbjattr_thbj-attr.prop-code = 'dop-info' then v-dop-info =  thbjattr_thbj-attr.property-value-character .
        end.

      for each tt-upd-attr-fuel no-lock where lookup (tt-upd-attr-fuel.code, v-dop-info) > 0:
      case tt-upd-attr-fuel.code:
        when {&trdcattr-ptbobj} then do:
            assign
              f-ptbotype:fgcolor  = 12
              f-ptbocode:fgcolor  = 12
              f-ptboname:fgcolor  = 12
              f-ptbocode-1:fgcolor  = 12
              .
        end.
        when {&trdcattr-ptb-item-pour} then do:
            assign
              f-item-pour:fgcolor   = 12
              f-item-pour-2:fgcolor = 12
              .
        end.
        when {&trdcattr-autoent} then do:
            assign
              f-autoent-obj-type:fgcolor  = 12
              f-autoent-obj-code:fgcolor  = 12
              f-autoent-obj-name:fgcolor  = 12
              f-autoent:fgcolor           = 12
              .
        end.
        when {&trdcattr-car-num} then do:
            assign
              f-car-num:fgcolor = 12
              f-car:fgcolor     = 12
              .
        end.
        when {&trdcattr-fio-driver} then do:
            assign
              f-fio:fgcolor = 12
              f-fio-name:fgcolor  = 12
              .
        end.
        when {&trdcattr-time-income} then do:
            assign
              f-hour-income:fgcolor = 12
              f-min-income:fgcolor  = 12
              f-hour-income-2:fgcolor = 12
              .
        end.
        when {&trdcattr-time-pour} then do:
            assign
              f-hour-pour:fgcolor = 12
              f-min-pour:fgcolor  = 12
              f-hour-pour-2:fgcolor = 12
              .
        end.
        when {&trdcattr-date-pour} then do:
            assign
              f-date-pour:fgcolor = 12
              f-date-pour-1:fgcolor = 12
              .
        end.
        when {&trdcattr-date-income} then do:
            assign
              f-date-income:fgcolor = 12
              f-date-income-2:fgcolor = 12
              .
        end.
        when {&trdcattr-inspection-cert} then do:
            assign
              f-insp-cert:fgcolor = 12
              f-insp:fgcolor  = 12
              .
        end.
        when {&trdcattr-date-cert} then do:
            assign
              f-date-cert:fgcolor = 12
              f-insp-2:fgcolor  = 12
              .
        end.
        when {&trdcattr-date-pasport} then do:
            assign
              f-date-pasport:fgcolor = 12
              f-pasport-num:fgcolor  = 12
              .
        end.
        when {&trdcattr-num-pasport} then do:
            assign
              f-num-pasport:fgcolor = 12
              f-pasport:fgcolor  = 12
              .
        end.        
        when {&trdcattr-condition} then do:
            assign
              f-condition:fgcolor = 12
              f-condition-name:fgcolor  = 12
              .
        end.
        when {&trdcattr-seals-condition} then do:
            assign
              f-seals-condition:fgcolor = 12
              f-seals-1:fgcolor = 12
              f-seals-2:fgcolor = 12
              f-seals-condition-2:fgcolor = 12
              .
        end.
/*        when {&trdcattr-acc-ship} then do:
            assign
              f-acc-ship:fgcolor  = 12
              f-acc-ship-2:fgcolor  = 12
              .
        end.*/
        when {&trdcattr-doc-not} then do:
            assign
              b-doc:fgcolor = 12
              f-doc:fgcolor = 12
              .
        end.
        when {&trdcattr-spisok-not-doc} then do:
            assign
              f-item-doc:bgcolor  = 12
              .
        end.
      end case.
      end.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disp-f-ptboname Dialog-Frame 
PROCEDURE disp-f-ptboname :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  find ub.clients where ub.clients.obj-code = input frame {&frame-name} f-ptbocode and
                     ub.clients.obj-type = input frame {&frame-name} f-ptbotype no-lock no-error.
  if available ub.clients then
  disp ub.clients.obj-name @ f-ptboname with frame {&frame-name}.
  else do:
      display ? @ f-ptboname with frame {&frame-name}.
      apply "choose" to b-ptb in frame {&frame-name}.
  end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disp-obj-name Dialog-Frame 
PROCEDURE disp-obj-name :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  find ub.clients where ub.clients.obj-code = input frame {&frame-name} f-autoent-obj-code and
                     ub.clients.obj-type = input frame {&frame-name} f-autoent-obj-type no-lock no-error.
  if available ub.clients
  then do :
    assign
      v-autoent-obj-type = ub.clients.obj-type
      v-autoent-obj-code = ub.clients.obj-code
    .
    disp ub.clients.obj-name @ f-autoent-obj-name with frame {&frame-name}.
  end .
  else do:
      display ? @ f-autoent-obj-name with frame {&frame-name}.
/*      apply "choose" to b-clients in frame {&frame-name}.*/
  end.

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
  DISPLAY f-autoent f-autoent-obj-code f-autoent-obj-type f-autoent-obj-name 
          f-car f-car-num f-condition-name f-condition f-seals-1 
          f-seals-condition f-insp f-insp-cert f-seals-2 f-seals-condition-2 
          f-insp-2 f-date-cert f-pasport f-num-pasport f-pasport-num 
          f-date-pasport f-fio-name f-fio f-ptbocode-1 f-ptbocode f-ptbotype 
          f-ptboname f-date-pour-1 f-date-pour f-hour-pour-2 f-hour-pour 
          f-min-pour f-date-income-2 f-date-income f-hour-income-2 f-hour-income 
          f-min-income f-item-pour-2 f-item-pour f-acc-ship-2 f-acc-ship f-doc 
          b-doc t-clear f-item-doc f-date-start f-date-end f-hour-start 
          f-min-start f-hour-end f-min-end 
      WITH FRAME Dialog-Frame.
  ENABLE b-save b-quit b-help f-autoent-obj-code f-autoent-obj-type b-clients 
         f-car-num b-auto-tank f-condition f-seals-condition f-insp-cert 
         f-seals-condition-2 f-date-cert f-num-pasport f-date-pasport f-fio 
         f-ptbocode f-ptbotype b-ptb f-date-pour f-hour-pour f-min-pour 
         f-date-income f-hour-income f-min-income f-item-pour f-acc-ship b-doc 
         t-clear f-date-start f-date-end f-hour-start f-min-start f-hour-end 
         f-min-end 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE save-attr Dialog-Frame 
PROCEDURE save-attr :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define variable v-attr-value as character no-undo.
  define buffer buf_doc-attr for ub.doc-attr.
  
  do transaction:
    _LABEL_FOR:
    for each tt-upd-attr-fuel no-lock:
      assign 
        v-attr-value = ? .
      case tt-upd-attr-fuel.code:
        when {&trdcattr-ptbobj} then do:
            assign
              v-attr-value = f-ptbotype + ";" + string (f-ptbocode) when f-ptbotype <> "" and f-ptbocode <> ?.
        end.
        when {&trdcattr-ptb-item-pour} then do:
            assign
              v-attr-value = f-item-pour when f-item-pour <> "".
        end.
        when {&trdcattr-autoent} then do:
            assign
              v-attr-value = f-autoent-obj-type + ";" + string (f-autoent-obj-code) when f-autoent-obj-code <> ? and f-autoent-obj-type <> "".
        end.
        when {&trdcattr-car-num} then do:
            assign
              v-attr-value = f-car-num when f-car-num <> "".
        end.
        when {&trdcattr-fio-driver} then do:
            assign
              v-attr-value = f-fio when f-fio <> "".
        end.
        when {&trdcattr-date-income} then do:
            assign
              v-attr-value = string(f-date-income) when string(f-date-income) <> "".
        end.
        when {&trdcattr-time-income} then do:
            assign
              v-attr-value = string( f-hour-income,   "99":U ) + ":" + string( f-min-income,   "99":U ) when f-hour-income <> ? and f-min-income <> ?.
        end.
        when {&trdcattr-time-pour} then do:
            assign
              v-attr-value = string( f-hour-pour,   "99":U ) + ":" + string( f-min-pour,   "99":U ) when f-hour-pour <> ? and f-min-pour <> ?.
        end.
        when {&trdcattr-time-start} then do:
            assign
              v-attr-value = string( f-hour-start,   "99":U ) + ":" + string( f-min-start,   "99":U ) when f-hour-start <> ? and f-min-start <> ?.
        end.
        when {&trdcattr-time-end} then do:
            assign
              v-attr-value = string( f-hour-end,   "99":U ) + ":" + string( f-min-end,   "99":U ) when f-hour-end <> ? and f-min-end <> ?.
        end.
        when {&trdcattr-date-pour} then do:
            assign
              v-attr-value = string(f-date-pour) when string(f-date-pour) <> "".
        end.
        when {&trdcattr-inspection-cert} then do:
            assign
              v-attr-value = f-insp-cert when f-insp-cert <> "".
        end.
        when {&trdcattr-date-cert} then do:
            assign
              v-attr-value = string(f-date-cert) when string(f-date-cert) <> "".
        end.
        when {&trdcattr-date-pasport} then do:
            assign
              v-attr-value = string(f-date-pasport) when string(f-date-pasport) <> "".
        end.
        when {&trdcattr-num-pasport} then do:
            assign
              v-attr-value = string(f-num-pasport) when string(f-num-pasport) <> "".
        end.
        when {&trdcattr-condition} then do:
            assign
              v-attr-value = f-condition when f-condition <> "".
        end.
        when {&trdcattr-seals-condition} then do:
            assign
              v-attr-value = f-seals-condition when f-seals-condition <> "".
            assign
              v-attr-value = (if v-attr-value = ? then "" else v-attr-value) + {&delim-par} + f-seals-condition-2 when f-seals-condition-2 <> "".
        end.
/*        when {&trdcattr-acc-ship} then do:                                      */
/*            assign                                                              */
/*              v-attr-value = string (f-acc-ship) when string (f-acc-ship) <> "".*/
/*        end.                                                                    */
        when {&trdcattr-doc-not} then do:
            assign
              v-attr-value = string (b-doc) when string (b-doc) <> "".
        end.
        when {&trdcattr-clear-ac} then do:
          if v-is-lgas
          then
            assign
              v-attr-value = string (t-clear) when string (t-clear) <> "".
        end.
        when {&trdcattr-spisok-not-doc} then do:
        if b-doc = yes then do:
            assign
              v-attr-value = string (f-item-doc) when string (f-item-doc) <> "".
        end.
        else v-attr-value = "".
        end.
        when {&trdcattr-date-start} then do:
            assign
              v-attr-value = string(f-date-start) when string(f-date-start) <> "".
        end.
        when {&trdcattr-date-end} then do:
            assign
              v-attr-value = string(f-date-end) when string(f-date-end) <> "".
        end.
/*          infoSectionTotal:GetInfoSectionProp(v-page-current):TimeStart = f-hour-start * 3600 + f-min-start * 60*/
/*        infoSectionTotal:GetInfoSectionProp(v-page-current):TimeEnd = f-hour-end   * 3600 + f-min-end   * 60*/
        otherwise
          next _LABEL_FOR.            
      end case.
      
      find first buf_doc-attr
        where buf_doc-attr.doc-code  = p-doc-code
          and buf_doc-attr.attr-code = tt-upd-attr-fuel.code
        no-error .
      if v-attr-value <> ? 
      then do:
        if not available buf_doc-attr
            then do:
              create buf_doc-attr.
              assign
                buf_doc-attr.doc-code   = p-doc-code
                buf_doc-attr.attr-code = tt-upd-attr-fuel.code.
            end.
        
        { str/tdat-wrt.i
            buf_doc-attr.doc-code
            buf_doc-attr.attr-code
            v-attr-value
            no-error
        }
        if error-status :error then do:
            message "Ошибка при сохранении атрибута." view-as alert-box.
            undo, return no-apply.
        end.
      end.
      else do:
        if available buf_doc-attr then delete buf_doc-attr.
      end.
      
    end.
      
    
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

