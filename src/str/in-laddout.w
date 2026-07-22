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


/* Parameters Definitions ---                                            */
define input        parameter parparentproc       as   handle                no-undo .
define input        parameter p-mode              as   character             no-undo .
define input        parameter p-doc-code          like ub.trn-doc.doc-code   no-undo .
define input        parameter p-gds-code          like ub.goods.gds-code     no-undo .
define input-output parameter p-car-num           as   character             no-undo .
define input-output parameter p-car-vol           as   character             no-undo .
define input-output parameter p-tests             as   character             no-undo .
define input-output parameter p-autoent-obj-type  as   character             no-undo .
define input-output parameter p-autoent-obj-code  as   character             no-undo .
define input-output parameter p-item-pour         as   character             no-undo .
define input-output parameter p-time-pour         as   character             no-undo .
define input-output parameter p-tank-vol          as   character             no-undo .
define input-output parameter p-tank-temp         as   character             no-undo .
define input-output parameter p-tank-water        as   character             no-undo .
define input-output parameter p-tank-density      as   character             no-undo .
define input-output parameter p-tank-weight       as   character             no-undo .
define input-output parameter p-time-income       as   character             no-undo .
define input-output parameter p-date-start        like ub.rvs-line.real-date no-undo .
define input-output parameter p-time-start        like ub.rvs-line.real-time no-undo .
define input-output parameter p-date-end          like ub.rvs-line.real-date no-undo .
define input-output parameter p-time-end          like ub.rvs-line.real-time no-undo .
define input-output parameter p-mouth             as   character             no-undo .
define input-output parameter p-fio               as   character             no-undo .
define input-output parameter p-ptbotype          as   character             no-undo .
define input-output parameter p-ptbocode          as   character             no-undo .
define input-output parameter p-a-b-tarir         as   character             no-undo .
define input-output parameter p-diameter          as   character             no-undo .
define input-output parameter p-place-si          as   character             no-undo .
define input-output parameter p-tank-density-pomi as   character             no-undo .
define input-output parameter p-certif-fuel       as   character             no-undo .
define input-output parameter p-norm-doc          as   character             no-undo .
define input-output parameter p-num-passport      as   character             no-undo .
define input-output parameter p-validity-certif   as   character             no-undo .
define input-output parameter p-passport-plotn    as   character             no-undo .
define input-output parameter p-num-plotn         as   character             no-undo .
define input-output parameter p-date-pov-plotn    like ub.rvs-line.real-date no-undo .
define       output parameter p-was-setting       as   logical               no-undo initial no .


define variable v-log as logical no-undo .
define variable v-autoent-obj-type as character no-undo.
define variable v-autoent-obj-code as integer no-undo.
define variable v-last-gds-code like ub.goods.gds-code no-undo .

define variable pomi-licvalue as character no-undo.
define variable pomi-lictype  as character no-undo.
define stream outstream.



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
&Scoped-Define ENABLED-OBJECTS b-save b-quit b-help RECT-3 RECT-1 ~
f-autoent-obj-code f-autoent-obj-type b-clients f-car-num f-car-vol ~
b-auto-tank f-tests f-fio f-ptbocode f-ptbotype b-ptb f-hour-pour ~
f-min-pour f-item-pour f-tank-water f-mouth f-tank-temp f-tank-density ~
b-calc f-a-b-tarir f-place-si r-sr-izm f-diameter f-tank-density-pomi ~
f-hour-income f-min-income f-date-start f-hour-start f-min-start f-date-end ~
f-hour-end f-min-end
&Scoped-Define DISPLAYED-OBJECTS f-autoent-obj-code f-autoent-obj-type ~
f-autoent-obj-name f-car-num f-car-vol f-tests f-fio f-ptbocode f-ptbotype ~
f-ptboname f-hour-pour f-min-pour f-item-pour f-tank-water f-mouth ~
f-tank-vol f-tank-temp f-tank-density f-tank-weight f-a-b-tarir f-place-si ~
f-diameter f-tank-density-pomi f-hour-income f-min-income f-date-start ~
f-hour-start f-min-start f-date-end f-hour-end f-min-end

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

DEFINE BUTTON b-calc
     LABEL "Рассчитать"
     SIZE 11 BY 1
     BGCOLOR 8 .

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

DEFINE BUTTON r-sr-izm
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "r-sr-izm"
     SIZE 3 BY .88.

DEFINE VARIABLE f-a-b-tarir AS DECIMAL FORMAT "->>>,>>9.99":U INITIAL 0
     LABEL "Уровень цистерны относительно тарировочной планки"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE f-autoent-obj-code AS INTEGER FORMAT ">>>>>>>>9":U INITIAL ?
     LABEL "Автопредприятие"
     VIEW-AS FILL-IN
     SIZE 11 BY 1 NO-UNDO.

DEFINE VARIABLE f-autoent-obj-name AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 43.88 BY 1.04 NO-UNDO.

DEFINE VARIABLE f-autoent-obj-type AS CHARACTER FORMAT "X(3)":U
     VIEW-AS FILL-IN
     SIZE 4 BY 1 NO-UNDO.

DEFINE VARIABLE f-car-num AS CHARACTER FORMAT "X(256)":U
     LABEL "Гос. N автоцистерны"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE f-car-vol AS DECIMAL FORMAT "->>>,>>>,>>>,>>9.999":U INITIAL 0
     LABEL "Объем по паспорту в литрах"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE f-date-end AS DATE FORMAT "99/99/99":U
     LABEL "Дата конца слива"
     VIEW-AS FILL-IN
     SIZE 10 BY .88 NO-UNDO.

DEFINE VARIABLE f-date-start AS DATE FORMAT "99/99/99":U
     LABEL "Дата начала слива"
     VIEW-AS FILL-IN
     SIZE 10 BY .88 NO-UNDO.

DEFINE VARIABLE f-diameter AS DECIMAL FORMAT "->>>,>>9.99":U INITIAL 0
     LABEL "Внутренний диаметр горловины"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE f-fio AS CHARACTER FORMAT "X(256)":U
     LABEL "Ф.И.О. водителя-экспедитора"
     VIEW-AS FILL-IN
     SIZE 49.5 BY 1 NO-UNDO.

DEFINE VARIABLE f-hour-end AS INTEGER FORMAT "99":U INITIAL ?
     LABEL "Время конца слива"
     VIEW-AS FILL-IN
     SIZE 3 BY 1 NO-UNDO.

DEFINE VARIABLE f-hour-income AS INTEGER FORMAT "99":U INITIAL ?
     LABEL "Время прибытия на АЗС"
     VIEW-AS FILL-IN
     SIZE 3 BY 1 NO-UNDO.

DEFINE VARIABLE f-hour-pour AS INTEGER FORMAT "99":U INITIAL ?
     LABEL "Время налива"
     VIEW-AS FILL-IN
     SIZE 3 BY 1 NO-UNDO.

DEFINE VARIABLE f-hour-start AS INTEGER FORMAT "99":U INITIAL ?
     LABEL "Время начала слива"
     VIEW-AS FILL-IN
     SIZE 3 BY 1 NO-UNDO.

DEFINE VARIABLE f-item-pour AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 80 BY 1 NO-UNDO.

DEFINE VARIABLE f-min-end AS INTEGER FORMAT "99":U INITIAL ?
     VIEW-AS FILL-IN
     SIZE 3 BY 1 NO-UNDO.

DEFINE VARIABLE f-min-income AS INTEGER FORMAT "99":U INITIAL ?
     VIEW-AS FILL-IN
     SIZE 3 BY 1 NO-UNDO.

DEFINE VARIABLE f-min-pour AS INTEGER FORMAT "99":U INITIAL ?
     VIEW-AS FILL-IN
     SIZE 3 BY 1 NO-UNDO.

DEFINE VARIABLE f-min-start AS INTEGER FORMAT "99":U INITIAL ?
     VIEW-AS FILL-IN
     SIZE 3 BY 1 NO-UNDO.

DEFINE VARIABLE f-mouth AS DECIMAL FORMAT "->>>,>>>,>>>,>>9.999":U INITIAL 0
     LABEL "Горловина"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE f-ptbocode AS INTEGER FORMAT ">>>>>>>>9":U INITIAL ?
     LABEL "Нефтебаза"
     VIEW-AS FILL-IN
     SIZE 11 BY 1 NO-UNDO.

DEFINE VARIABLE f-ptboname AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 43.5 BY 1 NO-UNDO.

DEFINE VARIABLE f-ptbotype AS CHARACTER FORMAT "X(3)":U
     VIEW-AS FILL-IN
     SIZE 4 BY 1 NO-UNDO.

DEFINE VARIABLE f-tank-density AS DECIMAL FORMAT "9.9999999999":U INITIAL ?
     LABEL "Плотность топлива"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE f-tank-density-pomi AS DECIMAL FORMAT "9.9999999999":U INITIAL ?
     LABEL "Плотность топлива для ПО МИ"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE f-tank-temp AS DECIMAL FORMAT "->9.999":U INITIAL ?
     LABEL "Температура"
     VIEW-AS FILL-IN
     SIZE 7.38 BY 1 NO-UNDO.

DEFINE VARIABLE f-tank-vol AS DECIMAL FORMAT "->>>,>>>,>>>,>>9.999":U INITIAL 0
     LABEL "Объем топлива"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE f-tank-water AS DECIMAL FORMAT "->>>,>>>,>>>,>>9.999":U INITIAL 0
     LABEL "Объем воды"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE f-tank-weight AS DECIMAL FORMAT "->>>,>>>,>>>,>>9.999":U INITIAL 0
     LABEL "Вес топлива"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE f-tests AS CHARACTER FORMAT "X(256)":U
     LABEL "Номер пробы"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE f-place-si AS INTEGER FORMAT ">>>,>>9":U INITIAL 0
     LABEL "Средство измерения"
     VIEW-AS FILL-IN
     SIZE 5.63 BY 1 NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 3 GRAPHIC-EDGE  NO-FILL
     SIZE 80.25 BY 8.25.

DEFINE RECTANGLE RECT-3
     EDGE-PIXELS 3 GRAPHIC-EDGE  NO-FILL
     SIZE 80.13 BY 4.21.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-save AT ROW 1 COL 2
     b-quit AT ROW 1 COL 12
     b-help AT ROW 1 COL 71
     f-autoent-obj-code AT ROW 2.46 COL 16 COLON-ALIGNED
     f-autoent-obj-type AT ROW 2.46 COL 27.75 COLON-ALIGNED NO-LABEL
     f-autoent-obj-name AT ROW 2.46 COL 36 COLON-ALIGNED NO-LABEL
     b-clients AT ROW 2.58 COL 34.5
     f-car-num AT ROW 3.75 COL 20 COLON-ALIGNED
     f-car-vol AT ROW 3.75 COL 65.75 COLON-ALIGNED
     b-auto-tank AT ROW 3.79 COL 36.38
     f-tests AT ROW 4.92 COL 20.13 COLON-ALIGNED
     f-fio AT ROW 6.04 COL 30 COLON-ALIGNED
     f-ptbocode AT ROW 7.25 COL 16 COLON-ALIGNED
     f-ptbotype AT ROW 7.25 COL 27.75 COLON-ALIGNED NO-LABEL
     f-ptboname AT ROW 7.25 COL 36 COLON-ALIGNED NO-LABEL
     b-ptb AT ROW 7.38 COL 34.5
     f-hour-pour AT ROW 8.25 COL 73 COLON-ALIGNED
     f-min-pour AT ROW 8.25 COL 76.5 COLON-ALIGNED NO-LABEL
     f-item-pour AT ROW 9.5 COL 1.5 NO-LABEL
     f-tank-water AT ROW 11.71 COL 64.75 COLON-ALIGNED
     f-mouth AT ROW 11.79 COL 20.75 COLON-ALIGNED
     f-tank-vol AT ROW 12.96 COL 20.63 COLON-ALIGNED
     f-tank-temp AT ROW 12.96 COL 64.75 COLON-ALIGNED
     f-tank-density AT ROW 14.13 COL 20.5 COLON-ALIGNED
     b-calc AT ROW 14.13 COL 37.5 WIDGET-ID 22
     f-tank-weight AT ROW 14.13 COL 64.75 COLON-ALIGNED
     f-a-b-tarir AT ROW 15.13 COL 64.75 COLON-ALIGNED WIDGET-ID 2
     f-place-si AT ROW 16.25 COL 20.5 COLON-ALIGNED WIDGET-ID 16
     r-sr-izm AT ROW 16.25 COL 28.5 WIDGET-ID 18
     f-diameter AT ROW 16.25 COL 64.75 COLON-ALIGNED WIDGET-ID 20
     f-tank-density-pomi AT ROW 17.5 COL 29.5 COLON-ALIGNED WIDGET-ID 24
     f-hour-income AT ROW 19.54 COL 71.75 COLON-ALIGNED
     f-min-income AT ROW 19.54 COL 75.38 COLON-ALIGNED NO-LABEL
     f-date-start AT ROW 21.25 COL 19.75 COLON-ALIGNED
     f-hour-start AT ROW 21.25 COL 71.75 COLON-ALIGNED
     f-min-start AT ROW 21.25 COL 75.38 COLON-ALIGNED NO-LABEL
     f-date-end AT ROW 22.33 COL 19.75 COLON-ALIGNED
     f-hour-end AT ROW 22.33 COL 71.75 COLON-ALIGNED
     f-min-end AT ROW 22.33 COL 75.38 COLON-ALIGNED NO-LABEL
     "Характеристики цистерны" VIEW-AS TEXT
          SIZE 23.63 BY .75 AT ROW 10.75 COL 26.25
     "Примечание к нефтебазе" VIEW-AS TEXT
          SIZE 25.5 BY 1 AT ROW 8.5 COL 1.5
     RECT-3 AT ROW 19.25 COL 1.5
     RECT-1 AT ROW 10.71 COL 1.5
     SPACE(0.12) SKIP(4.74)
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

/* SETTINGS FOR FILL-IN f-autoent-obj-name IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN f-item-pour IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN f-ptboname IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN f-tank-vol IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN f-tank-weight IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
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
      return no-apply .
    end.
    if input frame {&frame-name} f-tank-vol <= 0 or
       input frame {&frame-name} f-tank-vol  = ?
    then do:
      message "Объем топлива должен быть больше 0." view-as alert-box .
      apply "entry" to f-tank-vol in frame {&frame-name} .
      return no-apply .
    end.
    if input frame {&frame-name} f-tank-weight <= 0 or
       input frame {&frame-name} f-tank-weight  = ?
    then do:
      message "Вес топлива должен быть больше 0." view-as alert-box .
      apply "entry" to f-tank-weight in frame {&frame-name} .
      return no-apply .
    end.
    if input frame {&frame-name} f-tank-density = ?
      or Valid-Density( input frame {&frame-name} f-tank-density, (buf_goods.unit-base = buf_goods.unit-cli) ) <> yes
    then do:
      message "Плотность должна быть больше 0 и меньше 1." view-as alert-box .
      apply "entry" to f-tank-density in frame {&frame-name} .
      return no-apply .
    end.
  end.

  if input frame {&frame-name} f-tank-density <> ?
    and Valid-Density( input frame {&frame-name} f-tank-density, (buf_goods.unit-base = buf_goods.unit-cli) ) <> yes
  then do:
    message "Плотность должна быть больше 0 и меньше 1." view-as alert-box .
    apply "entry" to f-tank-density in frame {&frame-name} .
    return no-apply .
  end.
  if input frame {&frame-name} f-hour-pour <> ?
    and input frame {&frame-name} f-hour-pour > 24
  then do:
     message "Неверно заведено поле <<час>>." view-as alert-box .
     apply "entry" to f-hour-pour in frame {&frame-name} .
     return no-apply .
  end.
  if input frame {&frame-name} f-hour-start <> ?
    and input frame {&frame-name} f-hour-start > 24
  then do:
     message "Неверно заведено поле <<час>>." view-as alert-box .
     apply "entry" to f-hour-start in frame {&frame-name} .
     return no-apply .
  end.
  if input frame {&frame-name} f-hour-income > 24
  then do:
     message "Неверно заведено поле <<час>>." view-as alert-box .
     apply "entry" to f-hour-income in frame {&frame-name} .
     return no-apply .
  end.
  if input frame {&frame-name} f-hour-end > 24
  then do:
     message "Неверно заведено поле час." view-as alert-box .
     apply "entry" to f-hour-end in frame {&frame-name} .
     return no-apply .
  end.
  if input frame {&frame-name} f-min-pour > 60
  then do:
     message "Неверно заведено поле <<минуты>>." view-as alert-box .
     apply "entry" to f-min-pour in frame {&frame-name} .
     return no-apply .
  end.
  if input frame {&frame-name} f-min-income > 60
  then do:
     message "Неверно заведено поле <<минуты>>." view-as alert-box .
     apply "entry" to f-min-income in frame {&frame-name} .
     return no-apply .
  end.
  if input frame {&frame-name} f-min-start > 60
  then do:
     message "Неверно заведено поле <<минуты>>." view-as alert-box .
     apply "entry" to f-min-start in frame {&frame-name} .
     return no-apply .
  end.
  if input frame {&frame-name} f-min-end > 60
  then do:
     message "Неверно заведено поле <<минуты>>." view-as alert-box .
     apply "entry" to f-min-end in frame {&frame-name} .
     return no-apply .
  end.
  assign frame {&frame-name} f-car-num f-car-vol f-tests
                             f-autoent-obj-type f-autoent-obj-code
                             f-item-pour f-hour-pour f-min-pour
                             f-hour-income f-min-income
                             f-hour-start f-min-start
                             f-hour-end f-min-end
                             f-date-start f-date-end
                             f-tank-vol f-tank-temp
                             f-tank-water f-tank-density
                             f-mouth f-fio
                             f-ptbocode
                             f-ptbotype
                             f-a-b-tarir
  .
  find clients no-lock where
       clients.obj-type = f-autoent-obj-type and
       clients.obj-code = f-autoent-obj-code no-error .
  if not available clients
  then do:
    assign
      v-log = no
    .
    message "Не найдено автопредприятие " f-autoent-obj-type " " f-autoent-obj-code " ." skip
            "Cохраняемся без ссылки на автопредприятие?"
    view-as alert-box question buttons yes-no update v-log .
    if v-log <> yes
    then do:
      return no-apply .
    end.
    assign
      f-autoent-obj-type = ""
      f-autoent-obj-code = ?
    .
  end.
  find clients no-lock where
       clients.obj-type = f-ptbotype and
       clients.obj-code = f-ptbocode no-error .
  if not available clients
  then do:
    assign
      v-log = no
    .
    message "Не найдена нефтебаза " f-ptbotype " " f-ptbocode " ." skip
            "Cохраняемся без ссылки на нефтебазу?"
    view-as alert-box question buttons yes-no update v-log .
    if v-log <> yes
    then do:
      return no-apply .
    end.
    assign
      f-ptbotype = ""
      f-ptbocode = ?
    .
  end.
  assign
    f-tank-weight = f-tank-vol * f-tank-density
  .
  assign
    p-car-num          = f-car-num
    p-car-vol          = string( f-car-vol )
    p-tests            = f-tests
    p-autoent-obj-type = f-autoent-obj-type
    p-autoent-obj-code = string( f-autoent-obj-code )
    p-item-pour        = f-item-pour
    p-time-pour        = string( f-hour-pour,   "99":U ) + ":" + string( f-min-pour,   "99":U )
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

  no-error .
  assign
    p-was-setting = yes
  .
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

if v-autoent-obj-code <> 0 and v-autoent-obj-code <> ?
and can-find (first auto-tank-attr no-lock where auto-tank-attr.attr-code = "auto-firm"
                                             and auto-tank-attr.attr-value = v-autoent-obj-type + string(v-autoent-obj-code))
then do :
  run str/auto-tn.w (input parparentproc,
                input "b-sel",
                input v-autoent-obj-type,
                input v-autoent-obj-code,
                output v-rec-tank,
                output v-rec-meas) no-error.
end.
else do :
  message
  "Вы не указали автопредприятие или для " skip
  "указанного автопредприятия нет автоцистерн."   skip
  "Справочник будет открыт для всех автоцистерн." skip
  view-as alert-box information.
  run str/auto-tn.w (input parparentproc,
                input "b-sel",
                input "",
                input 0,
                output v-rec-tank,
                output v-rec-meas) no-error.
end.
if v-rec-tank <> ? then do:
  find first auto-tank where recid (auto-tank) = v-rec-tank no-lock.
  assign
      f-car-num    = auto-tank.auto-num
      f-car-vol    = auto-tank.brutto-qnty
      f-tank-vol   = f-car-vol
  .
  display f-car-num f-car-vol with frame {&frame-name}.
  if v-rec-meas <> ? then do:
    find first auto-tank-meas where recid (auto-tank-meas) = v-rec-meas no-lock.
    assign
        f-tank-vol = auto-tank-meas.meas-qnty
    .
  end.
  assign
      f-mouth    = f-tank-vol - f-car-vol
  .
  display
    f-tank-vol
    f-mouth
  with frame {&frame-name}.
end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-calc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-calc Dialog-Frame
ON CHOOSE OF b-calc IN FRAME Dialog-Frame /* Рассчитать */
DO:
  define variable ToolType                as integer no-undo.
  define variable DeltaAbs_R              as decimal no-undo.
  define variable DeltaAbs_Tv             as decimal no-undo.
  define variable DeltaAbs_Tr             as decimal no-undo.
  define variable temp-for-pomi           as integer no-undo.
  define variable error-string            as character no-undo.
  define variable v-mm as com-handle.
  define variable v-proc as character no-undo.
/*  define buffer buf_clob-bind    for ub.clob-bind.*/
  define buffer buf_sr-izmerenia for ub.sr-izmerenia .

  assign
  f-car-vol
  f-tank-vol
  f-a-b-tarir
  f-diameter
  f-tank-temp
  f-tank-density-pomi
  .


  IF pomi-licvalue = "yes" THEN DO :
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
      v-proc = "Rosneft.MethodOfMetering31" .

      RELEASE OBJECT v-mm NO-ERROR.
      v-mm = ?.

      CREATE value("Rosneft.MethodOfMetering31") v-mm no-error.
      IF ERROR-STATUS:ERROR
      OR NOT VALID-HANDLE(v-mm)
      THEN DO:
        RELEASE OBJECT v-mm NO-ERROR.
        v-mm = ?.
        message
          substitute( 'Не удается подключиться к COM-серверу библиотеки для работы с ПО МИ ' ) skip
        view-as alert-box error.
        undo _trpomi, return no-apply .
      END.
      ELSE DO :
        if f-car-vol = ? or f-car-vol = 0 then do :
          message
            "Заполнены не все поля, необходимые " skip
            "для работы библиотеки ПО МИ"         skip
            "Введите Объем по паспорту в литрах"  skip
          view-as alert-box error.
          apply "entry" to f-car-vol in frame {&frame-name} .
          undo _trpomi, return no-apply  .
        end.
        if f-a-b-tarir = ? or f-a-b-tarir = 0 then do :
          message
            "Заполнены не все поля, необходимые " skip
            "для работы библиотеки ПО МИ"         skip
            "Введите Уровень цистерны относительно тарировочной планки"  skip
          view-as alert-box error.
          apply "entry" to f-a-b-tarir in frame {&frame-name} .
          undo _trpomi, return no-apply  .
        end.
        if f-diameter = ? or f-diameter = 0 then do :
          message
            "Заполнены не все поля, необходимые " skip
            "для работы библиотеки ПО МИ"         skip
            "Введите Внутренний диаметр горловины"  skip
          view-as alert-box error.
          apply "entry" to f-diameter in frame {&frame-name} .
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
        if f-tank-density-pomi = ? or f-tank-density-pomi = 0 then do :
          message
            "Заполнены не все поля, необходимые " skip
            "для работы библиотеки ПО МИ"         skip
            "Введите Плотность топлива для ПО МИ"  skip
          view-as alert-box error.
          apply "entry" to f-tank-density-pomi in frame {&frame-name} .
          undo _trpomi, return no-apply  .
        end.
        ASSIGN
          v-mm:V_real                 = f-car-vol
          v-mm:DeltaH                 = f-a-b-tarir
          v-mm:Dgor                   = f-diameter
          v-mm:Tv                     = f-tank-temp
          v-mm:Tr                     = f-tank-temp
          v-mm:R                      = ( f-tank-density-pomi * 1000 )
          v-mm:Tcy                    = temp-for-pomi
          v-mm:ToolType               = ToolType
          v-mm:A_Reservoir            = 0.0000125
          v-mm:DeltaOtn_V             = 0.4
          v-mm:DeltaAbs_R             = DeltaAbs_R
          v-mm:DeltaAbs_Tv            = DeltaAbs_Tv
          v-mm:DeltaAbs_Tr            = DeltaAbs_Tr
        .
        output stream outstream to value ("pomi.log") append.
        put stream outstream
                                     cur-time-string()       skip
          'Процедура'                v-proc                  skip
          'V_real                 =' f-car-vol               skip
          'DeltaH                 =' f-a-b-tarir             skip
          'Dgor                   =' f-diameter              skip
          'Tv                     =' f-tank-temp             skip
          'Tr                     =' f-tank-temp             skip
          'R                      =' ( f-tank-density-pomi * 1000 ) skip
          'Tcy                    =' temp-for-pomi           skip
          'ToolType               =' ToolType                skip
          'A_Reservoir            =' 0.0000125               skip
          'DeltaOtn_V             =' 0.4                     skip
          'DeltaAbs_R             =' DeltaAbs_R              skip
          'DeltaAbs_Tv            =' DeltaAbs_Tv             skip
          'DeltaAbs_Tr            =' DeltaAbs_Tr             skip
        .

        output stream outstream close.

        v-mm:Exec() .

        if v-mm:Result <> 0 then do :
          error-string = v-mm:ResultDetail .
          output stream outstream to value ("pomi.log") append.
            put stream outstream error-string format "x(1024)" skip.
          output stream outstream close.
          RELEASE OBJECT v-mm NO-ERROR.
          v-mm = ?.
          message
            substitute('Ошибка работы библиотеки ПО МИ &1',error-string) skip
          view-as alert-box error.
          undo _trpomi, return no-apply  .
        end.
        else do :
          assign
            f-tank-density    = decimal(v-mm:Rcy) / 1000
            f-tank-vol        = v-mm:Vcy 
            f-tank-weight     = v-mm:Mcy
          .
          display
            f-tank-density
            f-tank-vol
            f-tank-weight
          with frame {&frame-name}.
          output stream outstream to value ("pomi.log") append.
            put stream outstream
            "v-mm:Rcy" f-tank-density      skip
            "v-mm:Vcy" f-tank-vol          skip
            "v-mm:Mcy" f-tank-weight       skip .
          output stream outstream close.
          RELEASE OBJECT v-mm NO-ERROR.
          v-mm = ?.
        end.
      END.
    end.
  END.
  enable
  f-tank-density
  with frame {&frame-name}.
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
  find clients where recid ( clients ) = ref-rec no-lock.
  disp clients.obj-code @ f-autoent-obj-code
       clients.obj-type @ f-autoent-obj-type
       clients.obj-name @ f-autoent-obj-name with frame {&frame-name}.
  assign
    v-autoent-obj-type = clients.obj-type
    v-autoent-obj-code = clients.obj-code
  .
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
  find clients where recid ( clients ) = ref-rec no-lock.
  disp clients.obj-code @ f-ptbocode
       clients.obj-type @ f-ptbotype
       clients.obj-name @ f-ptboname with frame {&frame-name}.
end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-save
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-save Dialog-Frame
ON CHOOSE OF b-save IN FRAME Dialog-Frame /* Сохранить */
DO:
  { gbl/stdbtn.i }
  apply "LEAVE":U to f-car-vol      in frame {&FRAME-NAME} .
  apply "LEAVE":U to f-tank-density in frame {&FRAME-NAME} .
  /* apply "GO":U to frame {&FRAME-NAME} . */
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-autoent-obj-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-autoent-obj-code Dialog-Frame
ON LEAVE OF f-autoent-obj-code IN FRAME Dialog-Frame /* Автопредприятие */
DO:
  run disp-obj-name.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-autoent-obj-code Dialog-Frame
ON RETURN OF f-autoent-obj-code IN FRAME Dialog-Frame /* Автопредприятие */
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
ON return OF f-car-num IN FRAME Dialog-Frame /* Гос. N автоцистерны */
DO:
  apply "entry" to f-car-vol in frame {&frame-name}.
return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-car-vol
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-car-vol Dialog-Frame
ON LEAVE OF f-car-vol IN FRAME Dialog-Frame /* Объем по паспорту в литрах */
DO:
    if pomi-licvalue <> "yes" then do:
        display input frame {&frame-name} f-car-vol + input frame {&frame-name} f-mouth @ f-tank-vol with frame {&frame-name}.
        display input frame {&frame-name} f-tank-vol *
            input frame {&frame-name} f-tank-density @ f-tank-weight with frame {&frame-name}.
    end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-car-vol Dialog-Frame
ON return OF f-car-vol IN FRAME Dialog-Frame /* Объем по паспорту в литрах */
DO:
  apply "entry" to f-tests in frame {&frame-name}.
return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-date-end
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-date-end Dialog-Frame
ON return OF f-date-end IN FRAME Dialog-Frame /* Дата конца слива */
DO:
    apply "entry" to f-hour-end in frame {&frame-name}.
return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-date-start
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-date-start Dialog-Frame
ON return OF f-date-start IN FRAME Dialog-Frame /* Дата начала слива */
DO:
  apply "entry" to f-hour-start in frame {&frame-name}.
return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-hour-end
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-hour-end Dialog-Frame
ON LEAVE OF f-hour-end IN FRAME Dialog-Frame /* Время конца слива */
DO:
  if input frame {&frame-name} f-hour-end > 24
  then do:
     message "Неверно заведено поле час." view-as alert-box .
     apply "entry" to f-hour-end in frame {&frame-name} .
     return no-apply .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-hour-end Dialog-Frame
ON return OF f-hour-end IN FRAME Dialog-Frame /* Время конца слива */
DO:
    apply "entry" to f-min-end in frame {&frame-name}.
return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-hour-income
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-hour-income Dialog-Frame
ON LEAVE OF f-hour-income IN FRAME Dialog-Frame /* Время прибытия на АЗС */
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
ON return OF f-hour-income IN FRAME Dialog-Frame /* Время прибытия на АЗС */
DO:
        apply "entry" to f-min-income in frame {&frame-name}.
return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-hour-pour
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-hour-pour Dialog-Frame
ON LEAVE OF f-hour-pour IN FRAME Dialog-Frame /* Время налива */
DO:
  if input frame {&frame-name} f-hour-pour > 24
  then do:
     message "Неверно заведено поле <<час>>." view-as alert-box .
     apply "entry" to f-hour-pour in frame {&frame-name} .
     return no-apply .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-hour-pour Dialog-Frame
ON return OF f-hour-pour IN FRAME Dialog-Frame /* Время налива */
DO:
      apply "entry" to f-min-pour in frame {&frame-name}.
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
     message "Неверно заведено поле <<час>>." view-as alert-box .
     apply "entry" to f-hour-start in frame {&frame-name} .
     return no-apply .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-hour-start Dialog-Frame
ON return OF f-hour-start IN FRAME Dialog-Frame /* Время начала слива */
DO:
apply "entry" to f-min-start in frame {&frame-name}.
return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-item-pour
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-item-pour Dialog-Frame
ON return OF f-item-pour IN FRAME Dialog-Frame
DO:
    apply "entry" to f-hour-pour in frame {&frame-name}.
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
     apply "entry" to f-min-end in frame {&frame-name} .
     return no-apply .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-min-end Dialog-Frame
ON return OF f-min-end IN FRAME Dialog-Frame
DO:
    apply "entry" to b-save in frame {&frame-name}.
return no-apply.
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
        apply "entry" to f-date-start in frame {&frame-name}.
return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-min-pour
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-min-pour Dialog-Frame
ON LEAVE OF f-min-pour IN FRAME Dialog-Frame
DO:
  if input frame {&frame-name} f-min-pour > 60
  then do:
     message "Неверно заведено поле <<минуты>>." view-as alert-box .
     apply "entry" to f-min-pour in frame {&frame-name} .
     return no-apply .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-min-pour Dialog-Frame
ON return OF f-min-pour IN FRAME Dialog-Frame
DO:
apply "entry" to f-mouth in frame {&frame-name}.
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
     apply "entry" to f-min-start in frame {&frame-name} .
     return no-apply .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-min-start Dialog-Frame
ON return OF f-min-start IN FRAME Dialog-Frame
DO:
  apply "entry" to f-date-end in frame {&frame-name}.
return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-mouth
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-mouth Dialog-Frame
ON LEAVE OF f-mouth IN FRAME Dialog-Frame /* Горловина */
DO:
    display input frame {&frame-name} f-car-vol + input frame {&frame-name} f-mouth @ f-tank-vol with frame {&frame-name}.
    display input frame {&frame-name} f-tank-vol *
          input frame {&frame-name} f-tank-density @ f-tank-weight with frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-mouth Dialog-Frame
ON return OF f-mouth IN FRAME Dialog-Frame /* Горловина */
DO:
apply "entry" to f-tank-density in frame {&frame-name}.
return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-ptbocode
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-ptbocode Dialog-Frame
ON LEAVE OF f-ptbocode IN FRAME Dialog-Frame /* Нефтебаза */
DO:
  run disp-f-ptboname.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-ptbocode Dialog-Frame
ON RETURN OF f-ptbocode IN FRAME Dialog-Frame /* Нефтебаза */
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
    apply "entry" to f-hour-pour in frame {&frame-name}.
return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-tank-density
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-tank-density Dialog-Frame
ON LEAVE OF f-tank-density IN FRAME Dialog-Frame /* Плотность топлива */
DO:
    display input frame {&frame-name} f-tank-vol *
          input frame {&frame-name} f-tank-density @ f-tank-weight with frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-tank-density Dialog-Frame
ON return OF f-tank-density IN FRAME Dialog-Frame /* Плотность топлива */
DO:
      apply "entry" to f-tank-temp in frame {&frame-name}.
return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-tank-temp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-tank-temp Dialog-Frame
ON return OF f-tank-temp IN FRAME Dialog-Frame /* Температура */
DO:
      apply "entry" to f-hour-income in frame {&frame-name}.
return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-tank-vol
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-tank-vol Dialog-Frame
ON return OF f-tank-vol IN FRAME Dialog-Frame /* Объем топлива */
DO:
      apply "entry" to f-tank-water in frame {&frame-name}.
return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-tank-water
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-tank-water Dialog-Frame
ON return OF f-tank-water IN FRAME Dialog-Frame /* Объем воды */
DO:
      apply "entry" to f-tank-density in frame {&frame-name}.
return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-tank-weight
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-tank-weight Dialog-Frame
ON return OF f-tank-weight IN FRAME Dialog-Frame /* Вес топлива */
DO:
      apply "entry" to b-save in frame {&frame-name}.
return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-tests
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-tests Dialog-Frame
ON return OF f-tests IN FRAME Dialog-Frame /* Номер пробы */
DO:
    apply "entry" to f-item-pour in frame {&frame-name}.
return no-apply.



END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME r-sr-izm
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL r-sr-izm Dialog-Frame
ON CHOOSE OF r-sr-izm IN FRAME Dialog-Frame /* r-sr-izm */
DO:
  define variable v-node-code as integer no-undo.
  define variable v-sr-type as character no-undo.
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
  end.
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
  find first buf_goods no-lock
    where buf_goods.gds-code = p-gds-code
    .
  if p-mode = "set-attr":U then do:
    run loc-get-set-attr in this-procedure
      ( input p-mode
      ) no-error .
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при сохранении дополнительной информации" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
    end.
    return .
  end.
  if p-mode = "get-attr":U then do:
    run loc-get-set-attr in this-procedure
      ( input p-mode
      ) no-error .
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при чтении дополнительной информации" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
    end.
    return .
  end.
  if can-find (first ub.doc-line no-lock where ub.doc-line.doc-code = p-doc-code and ub.doc-line.doc-density <> 0) then do:
    find first ub.doc-line no-lock where ub.doc-line.doc-code = p-doc-code
                                     and ub.doc-line.artic = buf_goods.artic
                                     and ub.doc-line.prod-code = buf_goods.prod-code
                                     and ub.doc-line.prod-type = buf_goods.prod-type no-error.
    if ub.doc-line.line-num > 1 then do :
      run loc-get-set-attr in this-procedure
        ( input "get-attr":U
        ) no-error .
      if error-status :error then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при чтении дополнительной информации" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
      end.
      if not ( ( p-car-num <> "" and p-car-num <> "?" ) or
               ( p-tests <> "" and p-tests <> "?" ) or
               ( p-car-vol <> "" and p-car-vol <> "?" ) or
               ( p-autoent-obj-type <> "" and p-autoent-obj-type <> "?" ) or
               ( p-autoent-obj-code <> "" and p-autoent-obj-code <> "?" ) or
               ( p-ptbotype <> "" and p-ptbotype <> "?" ) or
               ( p-ptbocode <> "" and p-ptbocode <> "?" )
               )
      then do :
        find first ub.doc-line no-lock where ub.doc-line.doc-code = p-doc-code
                                        and ub.doc-line.doc-density <> 0
                                        and ub.doc-line.line-num = 1 no-error.
        find first buf_goods where buf_goods.artic     = ub.doc-line.artic
                              and buf_goods.prod-code = ub.doc-line.prod-code
                              and buf_goods.prod-type = ub.doc-line.prod-type no-error.
        assign
        v-last-gds-code = p-gds-code.
        p-gds-code = buf_goods.gds-code
        .

        run loc-get-set-attr in this-procedure
          ( input "get-attr":U
          ) no-error .
        if error-status :error then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при чтении дополнительной информации" skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
        end.
        assign
          p-car-vol      = "0"
          p-item-pour    = ""
          p-time-pour    = ""
          p-time-income  = ""
          p-time-start   = 0
          p-time-end     = 0
          p-date-start   = ?
          p-date-end     = ?
          p-mouth        = ""
          p-tank-vol     = ""
          p-tank-temp    = ""
          p-tank-water   = ""
          p-tank-density = ""
          p-tank-weight  = ""
          p-a-b-tarir    = ""
          p-gds-code     = v-last-gds-code
          p-diameter     = ""
          p-place-si     = ""
          p-tank-density-pomi = ""

          .
      end.
    end.
  end.

  find first buf_goods no-lock
    where buf_goods.gds-code = p-gds-code
    .

  assign
    f-car-num = p-car-num
    f-tests = p-tests
  .
  assign
    f-car-vol = decimal(p-car-vol) no-error
  .
  if error-status:error then
    message "Неверно задан объем автоцистерны по паспорту " p-car-vol " ."
    view-as alert-box error.
  assign
    f-autoent-obj-type = p-autoent-obj-type
  .
  if f-autoent-obj-type = "" then do:
    assign
      f-autoent-obj-type = {&cmp}
    .
  end.
  assign
    f-autoent-obj-code = integer(p-autoent-obj-code) no-error
  .
  if error-status:error then do:
    message
      "Неверно указан код клиента " p-autoent-obj-code " ."
      view-as alert-box error.
  end.
  else do:
    find first clients no-lock
      where clients.obj-type = f-autoent-obj-type
        and clients.obj-code = f-autoent-obj-code
      no-error.
    if available clients then do:
      assign
        f-autoent-obj-name = clients.obj-name
      .
    end.
    else do:
      assign
        f-autoent-obj-name = ?
      .
    end.
  end.
  assign
    f-ptbotype = p-ptbotype
  .
  if f-ptbotype = "" then do:
    assign
      f-ptbotype = {&cmp}
    .
  end.
  assign
    f-ptbocode = integer( p-ptbocode ) no-error
  .
  if error-status:error then do:
    message
      "Неверно указан код нефтебазы " p-ptbocode " ."
      view-as alert-box error.
  end.
  else do:
    find first clients no-lock
      where clients.obj-type = f-ptbotype
        and clients.obj-code = f-ptbocode
      no-error.
    if available clients then assign f-ptboname = clients.obj-name.
    else assign f-ptboname = ?.
  end.
  assign f-item-pour = p-item-pour.
  assign
  f-tank-vol  = decimal(p-tank-vol) no-error.
  if error-status:error then
    message "Неверно определен объем в цистерне " p-tank-vol " . "
    view-as alert-box.
  assign
  f-tank-temp  = decimal(p-tank-temp) no-error.
  if error-status:error then
    message "Неверно определена температура в цистерне " p-tank-temp " . "
    view-as alert-box.
  assign
  f-tank-water  = decimal(p-tank-water) no-error.
  if error-status:error then
    message "Неверно определен объем воды в цистерне " p-tank-water " . "
    view-as alert-box.
  assign
  f-tank-density  = decimal(p-tank-density) no-error.
  if error-status:error then
    message "Неверно определена плотность в цистерне " p-tank-density " . "
    view-as alert-box.
  assign
  f-tank-weight  = decimal(p-tank-weight) no-error.
  if error-status:error then
    message "Неверно определен вес в цистерне " p-tank-weight " . "
    view-as alert-box.
  assign f-hour-pour = integer(substring(p-time-pour, 1, 2)) no-error.
  if error-status:error then do:
    message "Неверное время налива " p-time-pour
    view-as alert-box.
    assign f-hour-pour = 0
            f-min-pour  = 0.
  end.
  else do:
    assign f-min-pour = integer(substring(p-time-pour, 4, 2)) no-error.
    if error-status:error then do:
        message "Неверное время налива " p-time-pour
        view-as alert-box.
        assign f-hour-pour = 0
              f-min-pour  = 0.
    end.
  end.

  assign f-hour-income = integer(substring(p-time-income, 1, 2)) no-error.
  if error-status:error then do:
    message "Неверное время налива " p-time-income
    view-as alert-box.
    assign f-hour-income = 0
            f-min-income  = 0.
  end.
  else do:
    assign f-min-income = integer(substring(p-time-income, 4, 2)) no-error.
    if error-status:error then do:
        message "Неверное время налива " p-time-income
        view-as alert-box.
        assign f-hour-income = 0
              f-min-income  = 0.
    end.
  end.
  assign
  f-date-start = p-date-start
  f-date-end   = p-date-end
  f-hour-start = integer( truncate( p-time-start / 3600 , 0 ) )
  f-min-start  = integer( ( p-time-start - f-hour-start * 3600 ) / 60 )
  f-hour-end   = integer( truncate( p-time-end / 3600 , 0 ) )
  f-min-end    = integer( ( p-time-end - f-hour-end * 3600 ) / 60).
  assign
    f-mouth = decimal (p-mouth) no-error.
  if error-status:error then
    message "Неверно определен объем топлива в горловине " p-mouth " . "
    view-as alert-box.
  assign
    f-fio = p-fio
    f-ptbocode = integer( p-ptbocode )
    f-ptbotype = p-ptbotype
  .
  assign
  f-a-b-tarir  = decimal(p-a-b-tarir) no-error.
  if error-status:error then
    message "Неверно определен уровень цистерны относительно тарировочной планки " p-a-b-tarir " . "
    view-as alert-box.
  assign
  f-diameter = decimal (p-diameter) no-error.
  if error-status:error then
    message "Неверно определен внутренний диаметр горловины" p-diameter " . "
    view-as alert-box.
  assign
  f-place-si = integer(p-place-si) no-error.
  if error-status:error then
    message "Неверно определено средство измерения" p-place-si " . "
    view-as alert-box.
  f-tank-density-pomi = decimal(p-tank-density-pomi) no-error.
  if error-status:error then
    message "Неверно определена плотность топлива для ПО ИМ" p-tank-density-pomi " . "
    view-as alert-box.



  RUN enable_UI.

  display
    f-car-num f-car-vol f-tests f-autoent-obj-type f-autoent-obj-code f-autoent-obj-name
    f-item-pour f-hour-pour f-min-pour
    f-hour-income f-min-income
    f-date-start f-hour-start f-min-start
    f-date-end f-hour-end f-min-end
    f-tank-vol f-tank-temp f-tank-water f-tank-density
    f-tank-weight
    f-mouth    f-fio
    f-ptbocode
    f-ptbotype
    f-a-b-tarir
    with frame {&frame-name}.

  if p-mode <> {&update} then do:
    disable
      f-car-num f-car-vol f-tests f-autoent-obj-type f-autoent-obj-code
      f-item-pour  f-tank-vol f-tank-temp f-tank-water f-tank-density
      f-tank-weight f-hour-pour f-min-pour
      f-hour-income f-min-income
      f-date-start f-hour-start f-min-start
      f-date-end f-hour-end f-min-end
      b-save
      b-clients
      b-auto-tank
      f-mouth f-fio
      f-ptbocode
      f-ptbotype
      f-a-b-tarir
      with frame {&frame-name}.
  end.
  run gbl/conf-rd.p ("pomi-lic", "", "", 0, "", "", "", no, output pomi-licvalue, output pomi-lictype) no-error.
  if not error-status:error and pomi-licvalue = "yes" then do :
    disable
      f-tank-water
      f-mouth
      f-tank-density
      with frame {&frame-name}.
    display
      f-diameter
      f-place-si
      f-tank-density-pomi
      b-calc
      with frame {&frame-name}.
    enable
      f-diameter
      f-place-si
      f-tank-density-pomi
      b-calc
      with frame {&frame-name}.
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
  find clients where clients.obj-code = input frame {&frame-name} f-ptbocode and
                     clients.obj-type = input frame {&frame-name} f-ptbotype no-lock no-error.
  if available clients then
  disp clients.obj-name @ f-ptboname with frame {&frame-name}.
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
  find clients where clients.obj-code = input frame {&frame-name} f-autoent-obj-code and
                     clients.obj-type = input frame {&frame-name} f-autoent-obj-type no-lock no-error.
  if available clients then
  disp clients.obj-name @ f-autoent-obj-name with frame {&frame-name}.
  else do:
      display ? @ f-autoent-obj-name with frame {&frame-name}.
      apply "choose" to b-clients in frame {&frame-name}.
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
  DISPLAY f-autoent-obj-code f-autoent-obj-type f-autoent-obj-name f-car-num
          f-car-vol f-tests f-fio f-ptbocode f-ptbotype f-ptboname f-hour-pour
          f-min-pour f-item-pour f-tank-water f-mouth f-tank-vol f-tank-temp
          f-tank-density f-tank-weight f-a-b-tarir
          f-hour-income f-min-income f-date-start
          f-hour-start f-min-start f-date-end f-hour-end f-min-end
      WITH FRAME Dialog-Frame.
  ENABLE b-save b-quit b-help RECT-3 RECT-1 f-autoent-obj-code
         f-autoent-obj-type b-clients f-car-num f-car-vol b-auto-tank f-tests
         f-fio f-ptbocode f-ptbotype b-ptb f-hour-pour f-min-pour f-item-pour
         f-tank-water f-mouth f-tank-temp f-tank-density f-a-b-tarir
         r-sr-izm f-hour-income
         f-min-income f-date-start f-hour-start f-min-start f-date-end
         f-hour-end f-min-end
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE loc-get-set-attr Dialog-Frame
PROCEDURE loc-get-set-attr :
  define input  parameter p-mode-attr as character no-undo .

  &scop loc-find-attr ~
  find first buf_doc-line-attr ~
    where buf_doc-line-attr.doc-code  = p-doc-code ~
      and buf_doc-line-attr.gds-code  = p-gds-code ~
      and buf_doc-line-attr.attr-code = "~{&attr-name~}" ~
    no-error.

  &scop loc-get-attr ~
    if available buf_doc-line-attr then do: ~
      assign ~
        p-~{&attr-name~} = buf_doc-line-attr.attr-value ~
      . ~
    end.
  &scop loc-get-attr-int ~
    if available buf_doc-line-attr then do: ~
      assign ~
        p-~{&attr-name~} = integer( buf_doc-line-attr.attr-value ) no-error ~
      . ~
    end.
  &scop loc-get-attr-date ~
    if available buf_doc-line-attr then do: ~
      assign ~
        p-~{&attr-name~} = date( buf_doc-line-attr.attr-value ) ~
      . ~
    end.
  &scop loc-create-attr ~
    if not available buf_doc-line-attr then do: ~
      create buf_doc-line-attr . ~
      assign ~
        buf_doc-line-attr.doc-code  = p-doc-code ~
        buf_doc-line-attr.gds-code  = p-gds-code ~
        buf_doc-line-attr.attr-code = "~{&attr-name~}":U ~
      . ~
    end.

  &scop loc-set-attr ~
    assign ~
      buf_doc-line-attr.attr-value = substitute( "&1", p-~{&attr-name~} ) ~
    .
  &scop loc-set-attr-date ~
    assign ~
      buf_doc-line-attr.attr-value = string( p-~{&attr-name~}, "99/99/9999" )~
    .

  do
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1. stop", vss-workfile )
  on endkey undo, return error substitute( "&1. endkey", vss-workfile )
  :
    define buffer buf_doc-line-attr for ub.doc-line-attr .

    &scop attr-name car-num
    {&loc-find-attr}
    if p-mode-attr = "get-attr":U then do:
      {&loc-get-attr}
    end.
    else do:
      {&loc-create-attr}
      {&loc-set-attr}
    end.


    &scop attr-name car-vol
    {&loc-find-attr}
    if p-mode-attr = "get-attr":U then do:
      {&loc-get-attr}
    end.
    else do:
      {&loc-create-attr}
      {&loc-set-attr}
    end.

    &scop attr-name tests
    {&loc-find-attr}
    if p-mode-attr = "get-attr":U then do:
      {&loc-get-attr}
    end.
    else do:
      {&loc-create-attr}
      {&loc-set-attr}
    end.

    &scop attr-name autoent-obj-type
    {&loc-find-attr}
    if p-mode-attr = "get-attr":U then do:
      {&loc-get-attr}
    end.
    else do:
      {&loc-create-attr}
      {&loc-set-attr}
    end.

    &scop attr-name autoent-obj-code
    {&loc-find-attr}
    if p-mode-attr = "get-attr":U then do:
      {&loc-get-attr}
    end.
    else do:
      {&loc-create-attr}
      {&loc-set-attr}
    end.

    &scop attr-name item-pour
    {&loc-find-attr}
    if p-mode-attr = "get-attr":U then do:
      {&loc-get-attr}
    end.
    else do:
      {&loc-create-attr}
      {&loc-set-attr}
    end.

    &scop attr-name time-pour
    {&loc-find-attr}
    if p-mode-attr = "get-attr":U then do:
      {&loc-get-attr}
    end.
    else do:
      {&loc-create-attr}
      {&loc-set-attr}
    end.

    &scop attr-name time-income
    {&loc-find-attr}
    if p-mode-attr = "get-attr":U then do:
      {&loc-get-attr}
    end.
    else do:
      {&loc-create-attr}
      {&loc-set-attr}
    end.

    &scop attr-name date-start
    {&loc-find-attr}
    if p-mode-attr = "get-attr":U then do:
      {&loc-get-attr-date}
    end.
    else do:
      {&loc-create-attr}
      {&loc-set-attr-date}
    end.

    &scop attr-name time-start
    {&loc-find-attr}
    if p-mode-attr = "get-attr":U then do:
      {&loc-get-attr-int}
    end.
    else do:
      {&loc-create-attr}
      {&loc-set-attr}
    end.

    &scop attr-name date-end
    {&loc-find-attr}
    if p-mode-attr = "get-attr":U then do:
      {&loc-get-attr-date}
    end.
    else do:
      {&loc-create-attr}
      {&loc-set-attr-date}
    end.

    &scop attr-name time-end
    {&loc-find-attr}
    if p-mode-attr = "get-attr":U then do:
      {&loc-get-attr-int}
    end.
    else do:
      {&loc-create-attr}
      {&loc-set-attr}
    end.

    &scop attr-name tank-vol
    {&loc-find-attr}
    if p-mode-attr = "get-attr":U then do:
      {&loc-get-attr}
    end.
    else do:
      {&loc-create-attr}
      {&loc-set-attr}
    end.

    &scop attr-name tank-temp
    {&loc-find-attr}
    if p-mode-attr = "get-attr":U then do:
      {&loc-get-attr}
    end.
    else do:
      {&loc-create-attr}
      {&loc-set-attr}
    end.

    &scop attr-name tank-water
    {&loc-find-attr}
    if p-mode-attr = "get-attr":U then do:
      {&loc-get-attr}
    end.
    else do:
      {&loc-create-attr}
      {&loc-set-attr}
    end.

    &scop attr-name tank-density
    {&loc-find-attr}
    if p-mode-attr = "get-attr":U then do:
      {&loc-get-attr}
    end.
    else do:
      {&loc-create-attr}
      {&loc-set-attr}
    end.

    &scop attr-name tank-weight
    {&loc-find-attr}
    if p-mode-attr = "get-attr":U then do:
      {&loc-get-attr}
    end.
    else do:
      {&loc-create-attr}
      {&loc-set-attr}
    end.

    &scop attr-name mouth
    {&loc-find-attr}
    if p-mode-attr = "get-attr":U then do:
      {&loc-get-attr}
    end.
    else do:
      {&loc-create-attr}
      {&loc-set-attr}
    end.

    &scop attr-name fio
    {&loc-find-attr}
    if p-mode-attr = "get-attr":U then do:
      {&loc-get-attr}
    end.
    else do:
      {&loc-create-attr}
      {&loc-set-attr}
    end.

    &scop attr-name ptbotype
    {&loc-find-attr}
    if p-mode-attr = "get-attr":U then do:
      {&loc-get-attr}
    end.
    else do:
      {&loc-create-attr}
      {&loc-set-attr}
    end.

    &scop attr-name ptbocode
    {&loc-find-attr}
    if p-mode-attr = "get-attr":U then do:
      {&loc-get-attr}
    end.
    else do:
      {&loc-create-attr}
      {&loc-set-attr}
    end.

    &scop attr-name a-b-tarir
    {&loc-find-attr}
    if p-mode-attr = "get-attr":U then do:
      {&loc-get-attr}
    end.
    else do:
      {&loc-create-attr}
      {&loc-set-attr}
    end.

    &scop attr-name diameter
    {&loc-find-attr}
    if p-mode-attr = "get-attr":U then do:
      {&loc-get-attr}
    end.
    else do:
      {&loc-create-attr}
      {&loc-set-attr}
    end.

    &scop attr-name place-si
    {&loc-find-attr}
    if p-mode-attr = "get-attr":U then do:
      {&loc-get-attr}
    end.
    else do:
      {&loc-create-attr}
      {&loc-set-attr}
    end.

    &scop attr-name tank-density-pomi
    {&loc-find-attr}
    if p-mode-attr = "get-attr":U then do:
      {&loc-get-attr}
    end.
    else do:
      {&loc-create-attr}
      {&loc-set-attr}
    end.


    return .

  end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME