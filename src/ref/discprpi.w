&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER locked_dis-card FOR ub.dis-card.
DEFINE TEMP-TABLE tt0-dis-card-property NO-UNDO LIKE ub.dis-card-property.
DEFINE BUFFER X_prop-map FOR ub.prop-map.
DEFINE BUFFER X_prop-ref FOR ub.prop-ref.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Редактирование и просмотр свойств ДК

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/12/05
Author: Bakhtadze Natalya
Creation date: 12/12/05

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-mode as char no-undo.
define input parameter pard-card like ub.dis-card.d-card no-undo.
define input parameter p-emitent-host-code like ub.dis-card.emitent-host-code no-undo .
define input parameter p-type like ub.dis-card.type no-undo .
define input parameter p-host-code like ub.sysconf.host-code no-undo.
define input parameter p-obj-type like ub.clients.obj-type no-undo.
define input parameter p-obj-code like ub.clients.obj-code no-undo.
define input parameter p-update-instantly as logical no-undo .
define output parameter p-updated AS LOGICAL no-undo.
define INPUT-OUTPUT parameter table for tt0-dis-card-property.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Свойства дисконтной карты ".
{ cmp/vssrevis.i }

{ cmp/trg-def.i }
{ cmp/showinf.i }
{ gbl/getcntxt.i def }
{ cmp/bitoper.i }
{ gbl/get-regf.i }
{ gbl/cur-time.i }
{ str/defc-cli.i "NEW SHARED" }
{ ref/discprop.i }
{ cmp/dc-list.i dc-list def "new shared" }
{ cmp/dcp-list.i dcp-list def "new SHARED" }
{ ref/attr-pop.i def }
{ ref/attr-pop.i proc }
{ gbl/color.i }
{ ref/temp-dcp.i DEF }
{ ref/proprefd.i }
DEFINE VARIABLE v-ch AS WIDGET-HANDLE NO-UNDO EXTENT 5.
define variable updated as logical no-undo.
define variable dtm-node-option as character no-undo.
define variable dtm-option as integer no-undo.
define variable node-code-option as integer no-undo .
define variable temp-doc-rec as recid no-undo.
DEFINE VARIABLE added  as logical no-undo .
define variable v-host-code like ub.sysconf.host-code no-undo.
define variable v-obj-type like ub.clients.obj-type no-undo.
define variable v-obj-code like ub.clients.obj-code no-undo.
define variable v-card-num like ub.dis-card.card-num no-undo .

DEFINE BUFFER buf_clients FOR ub.clients.
&scoped-define  dcattr-type-get-error message "Ошибка при определении названия и типа свойства дисконтной карты!" ~
        "Обратитесь к администратору системы" skip error-status:get-message(1) skip ~
        return-value skip view-as alert-box ERROR.
&scoped-define  dcproperty-value-character-get-error message "Ошибка при определении значения свойства дисконтной карты!" ~
        "Обратитесь к администратору системы" skip error-status:get-message(1) skip ~
        return-value skip view-as alert-box ERROR.

DEFINE MENU MENU-b-ins .

&scoped-define label-clmn_character "Значение!(строковое)"
&scoped-define label-clmn_date "Значение!(Дата)"
&scoped-define label-clmn_decimal "Значение!(Десятичное)"
&scoped-define label-clmn_integer "Значение!(Целое)"
&scoped-define label-clmn_logical "Значение!(Логическое)"

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br-prop

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES temp-dis-card-property X_prop-map X_prop-ref

/* Definitions for BROWSE br-prop                                       */
&Scoped-define FIELDS-IN-QUERY-br-prop substitute("&1:&2", temp-dis-card-property.prop-label, temp-dis-card-property.node-label) proprefd_sum-id-des2(temp-dis-card-property.sum-id, X_prop-ref.ref-type) get-region( temp-dis-card-property.host-code, temp-dis-card-property.obj-type, temp-dis-card-property.obj-code) get-prop-value( X_prop-map.node-value-type ,temp-dis-card-property.property-value-character ,temp-dis-card-property.property-value-date ,temp-dis-card-property.property-value-decimal ,temp-dis-card-property.property-value-integer ,temp-dis-card-property.property-value-logical) substitute("&1:&2", temp-dis-card-property.dtm-code, temp-dis-card-property.node-code) temp-dis-card-property.dt-code
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-prop
&Scoped-define SELF-NAME br-prop
&Scoped-define QUERY-STRING-br-prop FOR EACH temp-dis-card-property, ~
           FIRST X_prop-map NO-LOCK WHERE         X_prop-map.dtm-code = temp-dis-card-property.dtm-code     AND X_prop-map.node-code = temp-dis-card-property.node-code, ~
          FIRST X_prop-ref  NO-LOCK outer-join WHERE         X_prop-ref.dt-code = temp-dis-card-property.dt-code by temp-dis-card-property.dtm-code by temp-dis-card-property.dt-code by temp-dis-card-property.node-code      INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-br-prop OPEN QUERY {&SELF-NAME} FOR EACH temp-dis-card-property, ~
           FIRST X_prop-map NO-LOCK WHERE         X_prop-map.dtm-code = temp-dis-card-property.dtm-code     AND X_prop-map.node-code = temp-dis-card-property.node-code, ~
          FIRST X_prop-ref  NO-LOCK outer-join WHERE         X_prop-ref.dt-code = temp-dis-card-property.dt-code by temp-dis-card-property.dtm-code by temp-dis-card-property.dt-code by temp-dis-card-property.node-code      INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-br-prop temp-dis-card-property X_prop-map ~
X_prop-ref
&Scoped-define FIRST-TABLE-IN-QUERY-br-prop temp-dis-card-property
&Scoped-define SECOND-TABLE-IN-QUERY-br-prop X_prop-map
&Scoped-define THIRD-TABLE-IN-QUERY-br-prop X_prop-ref


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-br-prop}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit B-quit b-ins b-lkp b-chg b-del b-hist ~
b-help rs-view br-prop vard-card v-first-main-card v-cli-name v-first-card ~
v-main-card
&Scoped-Define DISPLAYED-OBJECTS rs-view vard-card v-first-main-card ~
v-cli-name v-first-card v-main-card

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD display-character Dialog-Frame
FUNCTION display-character RETURNS CHARACTER
  ( INPUT p-character AS CHARACTER, INPUT p-format AS CHARACTER)  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-prop-value Dialog-Frame
FUNCTION get-prop-value RETURNS CHARACTER
     ( INPUT p-data-type AS CHARACTER
   ,INPUT p-value-character AS CHARACTER
   ,INPUT p-value-date AS DATE
   ,INPUT p-value-decimal AS DECIMAL
   ,INPUT p-value-integer AS INTEGER
   ,INPUT p-value-logical AS LOGICAL
 )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-chg
     LABEL "&Изменить":L
     SIZE 10 BY 1 TOOLTIP "Изменить свойство ДК".

DEFINE BUTTON b-del
     LABEL "&Удалить":L
     SIZE 10 BY 1 TOOLTIP "Удалить свойство ДК".

DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Ввод":L
     SIZE 10 BY 1 TOOLTIP "Выход с сохранением".

DEFINE BUTTON b-help
     LABEL "Помо&щь":L
     SIZE 3 BY 1.

DEFINE BUTTON b-hist
     LABEL "Btn 2"
     SIZE 3 BY 1.

DEFINE BUTTON b-ins
     LABEL "&Добавить":L
     SIZE 10 BY 1 TOOLTIP "Добавить свойство ДК".

DEFINE BUTTON b-lkp
     LABEL "&Просмотр":L
     SIZE 10 BY 1 TOOLTIP "Просмотр свойства ДК".

DEFINE BUTTON B-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1.

DEFINE VARIABLE v-cli-name AS CHARACTER FORMAT "X(256)":U
     LABEL "Держатель карты"
      VIEW-AS TEXT
     SIZE 41.5 BY .67
     BGCOLOR 3  NO-UNDO.

DEFINE VARIABLE v-first-card AS CHARACTER FORMAT "X(19)":U
     LABEL "Первая карта"
      VIEW-AS TEXT
     SIZE 21 BY .67
     BGCOLOR 3  NO-UNDO.

DEFINE VARIABLE v-first-main-card AS CHARACTER FORMAT "X(19)":U
     LABEL "Первая основная карта"
      VIEW-AS TEXT
     SIZE 21 BY .67
     BGCOLOR 3  NO-UNDO.

DEFINE VARIABLE v-main-card AS CHARACTER FORMAT "X(19)":U
     LABEL "Основная карта"
      VIEW-AS TEXT
     SIZE 21 BY .67
     BGCOLOR 3  NO-UNDO.

DEFINE VARIABLE vard-card AS CHARACTER FORMAT "X(16)":U
     LABEL "Дисконтная карта"
      VIEW-AS TEXT
     SIZE 20.63 BY .67
     BGCOLOR 3  NO-UNDO.

DEFINE VARIABLE rs-view AS INTEGER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Только по своему объекту/фирме/глобально", 0,
"Все", 1
     SIZE 49 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-prop FOR
      temp-dis-card-property,
      X_prop-map,
      X_prop-ref SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-prop
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-prop Dialog-Frame _FREEFORM
  QUERY br-prop DISPLAY
      substitute("&1:&2", temp-dis-card-property.prop-label, temp-dis-card-property.node-label) COLUMN-LABEL "Свойство" FORMAT "X(60)" WIDTH 25
proprefd_sum-id-des2(temp-dis-card-property.sum-id, X_prop-ref.ref-type) COLUMN-LABEL "Идентификатор/!Описание" FORMAT "X(255)" WIDTH 15
get-region( temp-dis-card-property.host-code, temp-dis-card-property.obj-type, temp-dis-card-property.obj-code) COLUMN-LABEL "Область!действия" FORMAT "X(14)":U
get-prop-value( X_prop-map.node-value-type
               ,temp-dis-card-property.property-value-character
                ,temp-dis-card-property.property-value-date
                ,temp-dis-card-property.property-value-decimal
                ,temp-dis-card-property.property-value-integer
                ,temp-dis-card-property.property-value-logical) COLUMN-LABEL "Значение" FORMAT "X(255)"
          WIDTH 45
substitute("&1:&2", temp-dis-card-property.dtm-code, temp-dis-card-property.node-code) COLUMN-LABEL "Объект!-операнд:!свойство"
temp-dis-card-property.dt-code COLUMN-LABEL "Код среза"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 15
         FONT 4.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     B-quit AT ROW 1 COL 11
     b-ins AT ROW 1 COL 31
     b-lkp AT ROW 1 COL 41
     b-chg AT ROW 1 COL 51
     b-del AT ROW 1 COL 61
     b-hist AT ROW 1 COL 92 WIDGET-ID 10
     b-help AT ROW 1 COL 95
     rs-view AT ROW 4 COL 12 NO-LABEL WIDGET-ID 12
     br-prop AT ROW 5 COL 1
     vard-card AT ROW 2 COL 18.5 COLON-ALIGNED
     v-first-main-card AT ROW 2 COL 75.5 COLON-ALIGNED WIDGET-ID 4
     v-cli-name AT ROW 3 COL 18.5 COLON-ALIGNED WIDGET-ID 2
     v-first-card AT ROW 3 COL 75.5 COLON-ALIGNED WIDGET-ID 6
     v-main-card AT ROW 4 COL 75.5 COLON-ALIGNED WIDGET-ID 8
     "Показывать:" VIEW-AS TEXT
          SIZE 10.5 BY 1 AT ROW 4 COL 1 WIDGET-ID 16
     SPACE(87.50) SKIP(15.22)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Свойства дисконтной карты"
         CANCEL-BUTTON B-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: locked_dis-card B "?" ? ub dis-card
      TABLE: tt0-dis-card-property T "?" NO-UNDO ub dis-card-property
      TABLE: X_prop-map B "?" ? ub prop-map
      TABLE: X_prop-ref B "?" ? ub prop-ref
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB br-prop rs-view Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-prop
/* Query rebuild information for BROWSE br-prop
     _START_FREEFORM
OPEN QUERY {&SELF-NAME}
FOR EACH temp-dis-card-property,
    FIRST X_prop-map NO-LOCK WHERE
        X_prop-map.dtm-code = temp-dis-card-property.dtm-code
    AND X_prop-map.node-code = temp-dis-card-property.node-code,
   FIRST X_prop-ref  NO-LOCK outer-join WHERE
        X_prop-ref.dt-code = temp-dis-card-property.dt-code
by temp-dis-card-property.dtm-code
by temp-dis-card-property.dt-code
by temp-dis-card-property.node-code

    INDEXED-REPOSITION.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE br-prop */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Свойства дисконтной карты */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-chg Dialog-Frame
ON CHOOSE OF b-chg IN FRAME Dialog-Frame /* Изменить */
DO:
  if not avail temp-dis-card-property then return no-apply.
  run proc-add-chg in this-procedure ( input no ) no-error .
  if error-status:error then return no-apply.
  run Openbr in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-del Dialog-Frame
ON CHOOSE OF b-del IN FRAME Dialog-Frame /* Удалить */
DO:
define variable loc#log as logical no-undo.
define variable v-data-type as character no-undo . /*тип */
define variable v-format as character no-undo .  /* формат */
define variable v-label as character no-undo .         /*лабел  */
define variable v-range as integer no-undo .
define variable v-rw-option as character no-undo .  /*пользователь может изменять в броусе*/
define variable glog as logical no-undo .
define variable v-dtm-code as integer no-undo .
define variable v-host-code as integer no-undo .
define variable v-obj-type as character no-undo .
define variable v-obj-code as integer no-undo .
define variable v-dt-code as integer no-undo .
define variable v-node-code as integer   no-undo .
define variable v-num as integer   no-undo .
define buffer buf_attr-prop for ub.attr-prop.
define buffer buf_temp-dis-card-property for temp-dis-card-property.

if not avail temp-dis-card-property then return no-apply.

run discprop-node-code in this-procedure (
                                     input  temp-dis-card-property.dtm-code
                                    ,input  temp-dis-card-property.node-code
                                    ,output v-data-type
                                    ,output v-format
                                    ,output v-label
                                    ,output v-range
                                    ,output v-rw-option
                                    ).
if index(v-rw-option, "W") = 0
then do:
    message
    "Свойство нельзя удалить вручную"
    view-as alert-box error .
    return no-apply.
end.
  if discprop-usercanedit( input temp-dis-card-property.dtm-code, input v-cntxt-db-num) = no then do:
    message
    "Свойство нельзя удалить в данной БД"
    view-as alert-box error .
    return no-apply.
  end.
  glog = no.
/*mojno udalit po odinochke*/
run gbl/d-askw.w (
  input "Удаление свойства ДК"
,input substitute("Вы уверены, что хотите удалить свойство &1 (срез &2) для дисконтной карты &3"
              ,temp-dis-card-property.prop-label
              ,temp-dis-card-property.sum-id
              ,vard-card
           )
,input "|^" /* Символы разделители для кодирования двух следующих параметров */
            /* первый символ - разделитель списков названий кнопок и описаний кнопок */
            /* второй символ - разделитель атрибутов в описании кнопок */
,input substitute("Полностью^confirm|Элемент&1|Отказ"
                  ,(if index(v-rw-option, "O") > 0
                    then ""
                    else "^disable"))
,input "Все элементы свойства|"
      + v-label + "|"
      + "Отказ "
,input 2 /* значение возвращаемое при нажатии enter */
,input 3 /* значение возвращаемое при нажатии escape */
,output v-num /* выбор пользователя */
).

if v-num = 3 then do:
  return no-apply.
end.
  assign
  v-dtm-code =  temp-dis-card-property.dtm-code
  v-host-code = temp-dis-card-property.host-code
  v-obj-type = temp-dis-card-property.obj-type
  v-obj-code = temp-dis-card-property.obj-code
  v-dt-code = temp-dis-card-property.dt-code
v-node-code = temp-dis-card-property.node-code
  .
  for each buf_temp-dis-card-property where
          buf_temp-dis-card-property.dtm-code = v-dtm-code
      and buf_temp-dis-card-property.host-code = v-host-code
      and buf_temp-dis-card-property.obj-type = v-obj-type
      and buf_temp-dis-card-property.obj-code = v-obj-code
      and buf_temp-dis-card-property.dt-code = v-dt-code
  :
  if v-num = 2 and buf_temp-dis-card-property.node-code <> v-node-code then next.
   delete buf_temp-dis-card-property.
  end.
  updated = yes.
run Openbr in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit Dialog-Frame
ON CHOOSE OF b-exit IN FRAME Dialog-Frame /* Ввод */
DO:
  RUN proc-save IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
     RETURN NO-APPLY.
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-hist
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-hist Dialog-Frame
ON CHOOSE OF b-hist IN FRAME Dialog-Frame /* Btn 2 */
DO:
 DEFINE VARIABLE v-ref-list AS CHARACTER NO-UNDO.
 IF NOT AVAILABLE temp-dis-card-property THEN RETURN NO-APPLY.
run ref/cdchist.w (
                INPUT parparentproc
                ,input p-host-code
                ,input p-obj-type
                ,input p-obj-code
                ,input "":U
                ,input "subject":U
                ,input temp-dis-card-property.d-card
                ,input ? /*dis-card.card-num*/
                ,input temp-dis-card-property.obj-type
                ,input temp-dis-card-property.obj-code
                ,input temp-dis-card-property.host-code
                ,input ? /*p-corr-user-db-num */
                ,input "":U /*p-corr-user-name */
                ,input {&table_dis-card-property} /*p-subject*/
                ,input ? /*p-db-num */
                /*записи в выборке*/
                ,input-output v-ref-list
            ) no-error .
  APPLY "entry" TO br-prop.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-ins
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-ins Dialog-Frame
ON CHOOSE OF b-ins IN FRAME Dialog-Frame /* Добавить */
DO:
define buffer buf_temp-dis-card-property for temp-dis-card-property.

if dtm-node-option = '':U then do:
  run gbl/pop-up.p ( input self:handle, input no) no-error.
end.
if dtm-node-option = '':U then return no-apply.
run proc-add-chg in this-procedure ( input yes) no-error .
if error-status:error then do:
  assign
  dtm-node-option = ''
  dtm-option = 0
  node-code-option = 0
  .
  return no-apply.
end.
Run Openbr in this-procedure .
find first buf_temp-dis-card-property no-lock where
           buf_temp-dis-card-property.dtm-code = dtm-option
       and buf_temp-dis-card-property.node-code = node-code-option
       and buf_temp-dis-card-property.host-code = v-host-code
      and buf_temp-dis-card-property.obj-type = v-obj-type
      and buf_temp-dis-card-property.obj-code = v-obj-code
                  no-error.
assign
dtm-node-option = '':U
dtm-option = 0
node-code-option = 0
.
if avail buf_temp-dis-card-property then
    temp-doc-rec = recid(buf_temp-dis-card-property).
    else temp-doc-rec = ?.
reposition br-prop to recid temp-doc-rec no-error.
if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-lkp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-lkp Dialog-Frame
ON CHOOSE OF b-lkp IN FRAME Dialog-Frame /* Просмотр */
DO:
  if not avail temp-dis-card-property then return no-apply.
  RUN proc-b-lkp IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-prop
&Scoped-define SELF-NAME br-prop
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-prop Dialog-Frame
ON MOUSE-SELECT-DBLCLICK OF br-prop IN FRAME Dialog-Frame
DO:
  if not avail temp-dis-card-property then return no-apply.
  RUN proc-b-lkp IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-prop Dialog-Frame
ON RETURN OF br-prop IN FRAME Dialog-Frame
DO:
  if not avail temp-dis-card-property then return no-apply.
  RUN proc-b-lkp IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-prop Dialog-Frame
ON VALUE-CHANGED OF br-prop IN FRAME Dialog-Frame
DO:
  DEFINE BUFFER buf_attr-prop FOR ub.attr-prop.
  IF NOT AVAILABLE temp-dis-card-property THEN do:
     DISABLE
     b-lkp
     WITH frame {&frame-name}.
     RETURN NO-APPLY.
  END.
  FIND FIRST buf_attr-prop NO-LOCK WHERE
            buf_attr-prop.TABLE-name = {&TABLE_dis-card-property}
       AND buf_attr-prop.templ-rl-root  = temp-dis-card-property.dtm-code
      AND buf_attr-prop.upper-prop-code = "InputForm":U
      AND buf_attr-prop.prop-code = "FormName" no-error.
  IF AVAILABLE buf_attr-prop THEN DO:
     ENABLE
     b-lkp
     WITH FRAME {&FRAME-NAME}.
  END.
  ELSE DO:
    DISABLE
    b-lkp
    WITH frame {&frame-name}.
  END.
  if p-mode <> {&lookup} then do:
    enable
    b-del
    with frame {&frame-name} .
    if g#db-num  > 0
    and (temp-dis-card-property.obj-type = ''
    or temp-dis-card-property.obj-code =0
    or temp-dis-card-property.host-code = 0) then do:
      disable
      b-del
      with frame {&frame-name} .
    end.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME rs-view
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rs-view Dialog-Frame
ON VALUE-CHANGED OF rs-view IN FRAME Dialog-Frame
DO:
  ASSIGN
  rs-view.
  RUN Openbr IN THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */
 { gbl/app_help.i }
{ gbl/brwrepos.i
&line-num=5
}

 frame {&frame-name}:TITLE = frame {&frame-name}:TITLE.
/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

ON ROW-DISPLAY OF br-prop IN frame {&frame-name}
DO:
  IF AVAIL temp-dis-card-property THEN DO:
    /*RUN set-row-color IN THIS-PROCEDURE ( INPUT X_prop-map.node-value-type).*/
  END.
END.

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */

MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  { gbl/getcntxt.i get }
  if NOT (p-mode = {&lookup}
        or p-mode = {&update}
        or p-mode = {&add-def}
        ) then do:
    message
    vss-workfile vss-revision vss-description skip
    "Неверный параметр вызова p-mode"
    view-as alert-box ERROR.
    return error.
  end.
  find first locked_dis-card no-lock where
              locked_dis-card.d-card = pard-card No-ERROR.
  IF NOT avail locked_dis-card  and p-mode <> {&add-def} then do:
    message
    vss-workfile vss-revision vss-description skip
    "Не найдена дисконтная карта" pard-card
    view-as alert-box.
    return error.
  END .
  IF AVAIL locked_dis-card THEN
  DO:
      assign
      v-card-num = locked_dis-card.card-num
      .
  END.

  IF p-mode <> {&add-def} THEN DO:
      FIND FIRST buf_clients NO-LOCK WHERE
                buf_clients.obj-type = LOCKED_dis-card.cli-type
          AND    buf_clients.obj-code = LOCKED_dis-card.cli-code.

  END.

    find first ub.sysconf No-LOCK WHERE
                     ub.sysconf.host-code = p-host-code No-ERROR.
    if not avail ub.sysconf then do:
        message vss-workfile vss-revision vss-description skip
                        "Неверный параметр вызова p-host-code"
            view-as alert-box ERROR.
            return error.
    end.
    find first ub.clients No-LOCK WHERE
                ub.clients.obj-type = p-obj-type AND
                ub.clients.obj-code = p-obj-code No-ERROR.
    if not avail ub.clients then do:
        message vss-workfile vss-revision vss-description skip
         "Неверный параметр вызова p-obj-type/p-obj-code"
        p-obj-type p-obj-code
        view-as alert-box ERROR.
        return error.
    end.
  { ref/attr-pop.i prepare }
  RUN MyEnable in this-procedure .
  Run init-proc in this-procedure .
  {&OPEN-query-br-prop}
  APPLY "ENTRY" TO br-prop in frame {&frame-name} .
  APPLY "VALUE-CHANGED" TO br-prop in frame {&frame-name} .
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI in this-procedure .
run attr-pop-clean-up in this-procedure ( input {&table_dis-card-property} ).
if updated then return {&update}.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE choose-to-edit Dialog-Frame
PROCEDURE choose-to-edit :
define input parameter p-dtm-code as integer no-undo .
assign
dtm-node-option = string(p-dtm-code) + {&delim-par} + string(0)
dtm-option = p-dtm-code
.
APPLY "CHOOSE" to b-ins in frame {&frame-name} .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE choose-to-edit-2 Dialog-Frame
PROCEDURE choose-to-edit-2 :
define input parameter p-dtm-code as integer no-undo .
define input parameter p-node-code-option as integer no-undo .
assign
dtm-node-option = string(p-dtm-code) + {&delim-par} + string(p-node-code-option)
.
APPLY "CHOOSE" to b-ins in frame {&frame-name} .
END PROCEDURE.

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
  DISPLAY rs-view vard-card v-first-main-card v-cli-name v-first-card
          v-main-card
      WITH FRAME Dialog-Frame.
  ENABLE b-exit B-quit b-ins b-lkp b-chg b-del b-hist b-help rs-view br-prop
         vard-card v-first-main-card v-cli-name v-first-card v-main-card
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-proc Dialog-Frame
PROCEDURE init-proc :
define variable v-data-type as character no-undo .          /* тип */
define variable v-format as character no-undo .        /* формат */
define variable v-label as character no-undo .         /* лабел  */
define variable v-property-value-character as character no-undo .         /* значение dis-card-propertyта */
define variable v-rw-option as character no-undo .   /* пользователь может изменять в броусе */
define variable v-range as integer no-undo .           /*  область действия */
define variable v-node-code-label as character no-undo .
define variable v-entry as character no-undo .
define variable ii as integer no-undo .
define variable v-entry2 as character no-undo .
define buffer buf_prop-head for ub.prop-head.

for each  Temp-dis-card-property share-lock:
  delete Temp-dis-card-property.
end.
assign
dtm-node-option = '':U
dtm-option = 0
node-code-option = 0
.
if p-mode <> {&add-def} then
Assign
vard-card = locked_dis-card.d-card
.
for each temp-dis-card-property:
  delete temp-dis-card-property.
end.
display vard-card
with frame {&frame-name}  .

For each tt0-dis-card-property where
        tt0-dis-card-property.d-card = pard-card
        no-lock :
  find first buf_prop-head no-lock where
            buf_prop-head.dtm-code = tt0-dis-card-property.dtm-code no-error .
  run discprop-node-code (
                       input tt0-dis-card-property.dtm-code
                      ,input tt0-dis-card-property.node-code
                      ,output v-data-type
                      ,output v-format
                      ,output v-label
                      ,output v-range
                      ,output v-rw-option
                       ).

    create temp-dis-card-property.
    assign
    temp-dis-card-property.d-card    = tt0-dis-card-property.d-card
    temp-dis-card-property.dt-code   = tt0-dis-card-property.dt-code
    temp-dis-card-property.sum-id    = tt0-dis-card-property.sum-id
    temp-dis-card-property.dtm-code = tt0-dis-card-property.dtm-code
    temp-dis-card-property.data-type  = v-data-type
    temp-dis-card-property.range      = v-range
    temp-dis-card-property.node-label = v-label
    temp-dis-card-property.prop-label = (if available buf_prop-head
                                         then buf_prop-head.prop-label
                                         else '':U)
    temp-dis-card-property.property-value-character = tt0-dis-card-property.property-value-character
    temp-dis-card-property.property-value-date = tt0-dis-card-property.property-value-date
    temp-dis-card-property.property-value-decimal = tt0-dis-card-property.property-value-decimal
    temp-dis-card-property.property-value-integer = tt0-dis-card-property.property-value-integer
    temp-dis-card-property.rw-option = v-rw-option
    temp-dis-card-property.node-code = tt0-dis-card-property.node-code
    temp-dis-card-property.host-code = tt0-dis-card-property.host-code
    temp-dis-card-property.obj-type = tt0-dis-card-property.obj-type
    temp-dis-card-property.obj-code = tt0-dis-card-property.obj-code
    .
End.   /* FOR EACH */
Run Openbr in this-procedure .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
define variable v-db-edit-prop-code as character no-undo .
define variable v-list as character no-undo .
define buffer buf_prop-head for ub.prop-head.
define buffer buf_prop-map for ub.prop-map.
define buffer buf_attr-prop for ub.attr-prop.
define buffer buf2_attr-prop for ub.attr-prop.
DEFINE VARIABLE v-h AS handle NO-UNDO.

v-h = br-prop:FIRST-COLUMN IN FRAME {&FRAME-NAME}.
DO while valid-handle(v-h) :
  if v-h:LABEL = "Свойство" then do:
    v-h:RESIZABLE = YES.
   end.
   IF v-h:LABEL =  "Идентификатор/!Описание" THEN DO:
      v-h:RESIZABLE = YES.
   END.
   IF v-h:LABEL = {&label-clmn_character} THEN
   v-ch[1] = v-h.
   IF v-h:LABEL = {&label-clmn_date} THEN
   v-ch[2] = v-h.
   IF v-h:LABEL = {&label-clmn_decimal} THEN
   v-ch[3] = v-h.
   IF v-h:LABEL = {&label-clmn_integer} THEN
   v-ch[4] = v-h.
   IF v-h:LABEL = {&label-clmn_logical} THEN
   v-ch[5] = v-h.
   v-h = v-h:NEXT-COLUMN.

END.

assign
b-ins:POPUP-MENU IN FRAME {&frame-name} = MENU MENU-b-ins:HANDLE
b-ins:MENU-MOUSE = 1
.
if p-mode <> {&lookup} then do:
  if v-cntxt-db-num = 0 then do:
   v-db-edit-prop-code = 'DB0Edit':U.
  end.
  else do:
   v-db-edit-prop-code = 'DBREdit':U.
  end.
  for each buf_prop-head where
          buf_prop-head.storage-place = {&table_dis-card-property}
      or  buf_prop-head.storage-place-host = {&table_dis-card-property}
      or  buf_prop-head.storage-place-obj = {&table_dis-card-property}:
    if discprop-usercanedit ( input buf_prop-head.dtm-code, input v-cntxt-db-num) = yes then do:
      v-list = v-list + (if v-list = '' then '' else {&comma-char}) + (string(buf_prop-head.dtm-code) + {&delim-par} + '':U).
    end.
  end. /*for each buf_prop-head where*/
  run attr-pop-create-items in this-procedure  (
                                            input {&table_dis-card-property}
                                            ,input 'discprop-edit'   /*p-get-section-num-proc-name*/
                                            ,input 'discprop-node-name'
                                            ,input 'choose-to-edit'
                                            ,input menu menu-b-ins:handle
                                            ,input v-list
                                          ).

end. /*if p-mode <> {&lookup} then do:*/
IF p-mode <> {&add-def} THEN DO:
  DISPLAY
  buf_clients.obj-name @ v-cli-name
  locked_dis-card.first-main-card @ v-first-main-card
  locked_dis-card.main-card @ v-main-card
  locked_dis-card.first-card @ v-first-card
  WITH FRAME {&FRAME-NAME}.
END.
ELSE do:
   HIDE
   v-cli-name
   v-first-main-card
   v-first-card
   v-main-card
   IN FRAME {&frame-name}.
END.
ENABLE
rs-view
b-exit when p-mode <> {&lookup}
b-quit
b-del when p-mode <> {&lookup}
b-ins when (p-mode <> {&lookup} and  can-find( first tt-attr-property where
                                                    tt-attr-property.table-name = {&table_dis-card-property}
                                                and tt-attr-property.edit-menu-section-num > 0))
b-chg when p-mode <> {&lookup}
b-help
br-prop
b-hist WHEN p-mode <> {&add-def}
WITH FRAME {&frame-name} .
VIEW FRAME {&frame-name} .
rs-view = 0.
run Openbr in this-procedure .
if p-mode = {&lookup} then do:
  hide
  b-exit
  in frame {&frame-name} .
  assign
  b-quit:label = "&Выход"
  b-quit:col    = 1
  .
end.
APPLY "ENTRY" TO br-prop.
APPLY "VALUE-CHANGED" TO br-prop.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Openbr Dialog-Frame
PROCEDURE Openbr :
CASE rs-view:
  WHEN 1  THEN DO:
      OPEN QUERY br-prop
      FOR EACH temp-dis-card-property,
          FIRST X_prop-map NO-LOCK WHERE
              X_prop-map.dtm-code = temp-dis-card-property.dtm-code
          AND X_prop-map.node-code = temp-dis-card-property.node-code,
          FIRST X_prop-ref NO-LOCK OUTER-JOIN WHERE
              X_prop-ref.dt-code = temp-dis-card-property.dt-code
      by temp-dis-card-property.dtm-code
      by temp-dis-card-property.dt-code
      by temp-dis-card-property.node-code
          INDEXED-REPOSITION.

  END.
  WHEN 0  THEN DO:
      OPEN QUERY br-prop
      FOR EACH temp-dis-card-property
      WHERE temp-dis-card-property.host-code = 0
      OR (temp-dis-card-property.host-code = p-host-code AND
          temp-dis-card-property.obj-type = '')
      OR (temp-dis-card-property.host-code = p-host-code AND
          temp-dis-card-property.obj-type = p-obj-type AND
          temp-dis-card-property.obj-code = p-obj-code
           ),
          FIRST X_prop-map NO-LOCK WHERE
              X_prop-map.dtm-code = temp-dis-card-property.dtm-code
          AND X_prop-map.node-code = temp-dis-card-property.node-code,
          FIRST X_prop-ref NO-LOCK OUTER-JOIN WHERE
              X_prop-ref.dt-code = temp-dis-card-property.dt-code
      by temp-dis-card-property.dtm-code
      by temp-dis-card-property.dt-code
      by temp-dis-card-property.node-code
          INDEXED-REPOSITION.

  END.
END CASE.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-add-chg Dialog-Frame
PROCEDURE proc-add-chg :
define input parameter p-add as logical no-undo .
define variable v-data-type as character no-undo . /*тип */
define variable v-format as character no-undo .  /* формат */
define variable v-label as character no-undo .         /*лабел */
define variable v-range as integer no-undo .
define variable v-rw-option as character no-undo .  /*пользователь может изменять в броусе*/
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as integer no-undo .
define variable v-value-logical as logical no-undo .
define variable loc#log as logical no-undo.
define variable var-region  as character no-undo.
DEFINE VARIABLE v-sel-vals as character no-undo .
DEFINE VARIABLE v-sel-labels as character no-undo .
DEFINE VARIABLE jj as integer no-undo .
DEFINE VARIABLE v-dtm-option as integer no-undo .
define variable v-spr as character no-undo .
define variable v-spr-param as character no-undo .
DEFINE VARIABLE v-deleted as logical no-undo .
define variable v-check as character no-undo .
define variable v-error-code as character no-undo .
define variable v-correct as logical no-undo .
define variable v-setted as logical no-undo .
define variable v-ok as logical no-undo .
define variable v-old-kat like ub.dis-card-property.property-value-character no-undo .
define buffer buf_attr-prop for ub.attr-prop.
if  discprop-usercanedit ( if p-add
                           then dtm-option
                           else temp-dis-card-property.dtm-code
                           , v-cntxt-db-num)  = no then do:
   message
  "Нельзя редактировать Данное свойство в данной БД"
  view-as alert-box .
  undo, return error .
end.
case p-add:
  when yes then do:
     run discprop-node-code in this-procedure (
                                         input  dtm-option          /* p-dtm-code           */
                                        ,input  node-code-option         /*p-node-code           */
                                        ,output v-data-type           /* p-data-type           */
                                        ,output v-format         /* p-format         */
                                        ,output v-label          /* p-label          */
                                        ,output v-range          /* p-range          */
                                        ,output v-rw-option /* p-user-can-edit  */
                                        ) no-error .
    if error-status :error then do:
      return error .
    end.
    if v-range > 4 then do:
      assign
      v-sel-vals =  if p-emitent-host-code = 0 and BinMask(integer(v-range), "XXX1":U)
                    then  ("1" + {&comma-char} )
                    else ''
      v-sel-labels = if p-emitent-host-code = 0 and BinMask(integer(v-range), "XXX1":U)
                    then  ("Глобально" + {&comma-char} )
                    else ''
      .
      assign
      v-sel-vals = v-sel-vals +
                   if p-emitent-host-code <> 0 and BinMask(integer(v-range), "XX1X":U)
                   then ("1":U + {&comma-char})
                   else "":U
      v-sel-labels = v-sel-labels +
                   if p-emitent-host-code <> 0 and BinMask(integer(v-range), "XX1X":U)
                   then ( substitute("Эмитент (фирма &1)", p-emitent-host-code) + {&comma-char})
                   else "":U
      .
      assign
      v-sel-vals = v-sel-vals +
                   if p-emitent-host-code = 0 and  BinMask(integer(v-range), "X1XX":U)
                   then ("2":U + {&comma-char})
                   else "":U
      v-sel-labels = v-sel-labels +
                   if p-emitent-host-code = 0 and  BinMask(integer(v-range), "X1XX":U)
                   then ( substitute("Фирма &1", p-host-code) + {&comma-char})
                   else "":U
      .
      assign
      v-sel-vals = v-sel-vals +
                   if BinMask(integer(v-range), "1XXX":U)
                   then ("4":U + {&comma-char})
                   else "":U
      v-sel-labels = v-sel-labels +
                   if BinMask(integer(v-range), "1XXX":U)
                   then ( substitute("&1&2", p-obj-type, p-obj-code) + {&comma-char})
                   else "":U
      .
        assign
      v-sel-labels = trim(v-sel-labels, {&comma-char})
      v-sel-vals   = trim(v-sel-vals, {&comma-char})
        .
      run gbl/d-list.w (
                          input "b-sel":U
                          ,input "Выберите область действия"
                          ,v-sel-vals
                          ,v-sel-labels
                          ,{&comma-char}
                          ,"":U
                          ,output var-region) no-error.
      if error-status:error then do:
        assign
        dtm-node-option = '':U
        dtm-option = 0
        node-code-option = 0
        .
        return error.
      end.
    end.
    else do:
      assign
      var-region = string(v-range)
      .
    end.
    CASE var-region:
        when "0":U then do:
            assign
            v-host-code = 0
            v-obj-type = "":U
            v-obj-code = 0
            .
        end.
        when "1":U then do:
            assign
            v-host-code = (if p-emitent-host-code = 0 then 0 else p-emitent-host-code)
            v-obj-type = "":U
            v-obj-code = 0
            .
        end.
        when "2":U then do:
            assign
            v-host-code = p-host-code
            v-obj-type = "":U
            v-obj-code = 0
            .
        end.
        when "4":U then do:
            assign
            v-host-code = p-host-code
            v-obj-type = p-obj-type
            v-obj-code = p-obj-code
            .
        end.
    END CASE.
    /*выберем dt-code*/
    define variable v-ref-list as character no-undo .
    define buffer buf_prop-ref for ub.prop-ref.
    define buffer buf_dis-card-type for ub.dis-card-type.
    find first buf_dis-card-type no-lock where
              buf_Dis-card-type.type = p-type
          and buf_Dis-card-type.emitent-host-code = p-emitent-host-code
          and buf_Dis-card-type.host-code = 0
          and buf_Dis-card-type.obj-type = '':U
          and buf_Dis-card-type.obj-code = 0 .
    run ref/proprefs.w (
                    input parparentproc
                  ,input 'b-sel'
                  ,input "dtm-code"
                  ,input dtm-option
                  ,input '':U
                  ,input buf_Dis-card-type.uniq-key-rec
                  ,input-output  v-ref-list) no-error.
    find first buf_prop-ref no-lock where
              recid(buf_prop-ref) = integer(v-ref-list) no-error .
    if not available buf_prop-ref then return no-apply.
    run temp-dc-prop-exist in this-procedure (
                                               input pard-card
                                              ,input v-host-code
                                              ,input v-obj-type
                                              ,input v-obj-code
                                              ,input dtm-option
                                              ,input node-code-option
                                              ,input buf_prop-ref.dt-code
                                              ,output loc#log)  no-error.
    if error-status:error or loc#log then do:
      if loc#log then do:
        message
        "Уже есть такое свойство"
        view-as alert-box error .
      end.
      return error.
    end.
    assign
    v-dtm-option = dtm-option
    .
    if node-code-option > 0 then do:
      run discprop-initial in this-procedure (
                                              input  dtm-option
                                              ,input  node-code-option
                                              ,output v-value-character
                                              ,output v-value-date
                                              ,output v-value-decimal
                                              ,output v-value-integer
                                              ,output v-value-logical ) no-error .
    if error-status:error then do:
      message error-status:error error-status:get-message(1)  return-value
      view-as alert-box error .
      undo, return error .
    end.
   end.
  end. /*whne add*/
  when no then do:
    run discprop-node-code in this-procedure (
                                     input TEMP-dis-card-property.dtm-code
                                    ,input TEMP-dis-card-property.node-code
                                    ,output v-data-type
                                    ,output v-format
                                    ,output v-label
                                    ,output v-range
                                    ,output v-rw-option
                                    ) no-error.
    IF ERROR-STATUS:ERROR THEN DO:
        {&dcattr-type-get-error}
        return error.
    END.
    assign
    v-value-character  = temp-dis-card-property.property-value-character
    v-value-date       = temp-dis-card-property.property-value-date
    v-value-decimal    = temp-dis-card-property.property-value-decimal
    v-value-integer    = temp-dis-card-property.property-value-integer
    v-value-logical    = temp-dis-card-property.property-value-logical
    .
  end. /*when chg*/
END CASE.
if node-code-option > 0 then do:
  IF index(v-rw-option, "W") > 0
  Then DO:
    case v-data-type:
      when {&abl-datatype-integer} then do:
        run gbl/d-integer.w (
              input ? /*callback             */
              ,input (
              'title=':u + substitute("Изменение свойства &1", v-label) + '\':u
            + 'text1=':u  + v-label + '\':u
            + 'format=' + v-format + '\':u
            + 'fillin_row=2\':u
            + 'fillin_col=4\':u
            + 'fillin_width=20\':u
            + 'fillin_height=1\':u
            + 'max-chars=70\':u     /*- максимальное количество символов для редактора*/
            + 'readonly=' + (if p-mode <> {&update} then 'yes':u else 'no':u) + '\':u)
            , input-output v-value-integer
            , output v-ok
                ).
            if not v-ok then return error.
        assign
        temp-dis-card-property.property-value-integer = v-value-integer.
      end.
      when {&abl-datatype-decimal} then do:
        run gbl/d-decimal.w (
              input ? /*callback*/
              ,input (
              'title=':u + substitute("Изменение свойства &1", v-label) + '\':u
            + 'text1=':u  + v-label + '\':u
            + 'format=' + v-format + '\':u
            + 'fillin_row=2\':u
            + 'fillin_col=4\':u
            + 'fillin_width=20\':u
            + 'fillin_height=1\':u
            + 'max-chars=70\':u     /*- максимальное количество символов для редактора*/
            + 'readonly=' + (if p-mode <> {&update} then 'yes':u else 'no':u) + '\':u)
            , input-output v-value-integer
            , output v-ok
                ).
            if not v-ok then return error.
        assign
        temp-dis-card-property.property-value-decimal = v-value-decimal.
      end.
      when {&abl-datatype-character} then do:
        run gbl/d-character.w (
              input ? /*callback*/
              ,input (
              'title=':u + substitute("Изменение свойства &1", v-label) + '\':u
            + 'text1=':u + v-label + '\':u
            + 'format=' + v-format + '\':u
            + 'fillin_row=2\':u
            + 'fillin_col=4\':u
            + 'fillin_width=20\':u
            + 'fillin_height=1\':u
            + 'max-chars=70\':u     /*- максимальное количество символов для редактора*/
            + 'readonly=' + (if p-mode <> {&update} then 'yes':u else 'no':u) + '\':u)
            , input-output v-value-character
            , output v-ok
                ).
            if not v-ok then return error.
        assign
        temp-dis-card-property.property-value-character = v-value-character.
      end.
      when {&abl-datatype-logical} then do:
        run gbl/d-logical.w (
              input ? /*callback*/
              ,input ('title=':u + substitute("Изменение свойства &1", v-label) + '\':u
            + 'text1=':u + v-label + '\':u
            + 'format=' + v-format + '\':u
            + 'fillin_row=2\':u
            + 'fillin_col=4\':u
            + 'fillin_width=20\':u
            + 'fillin_height=1\':u
            + 'max-chars=70\':u     /*- максимальное количество символов для редактора*/
            + 'readonly=' + (if p-mode <> {&update} then 'yes':u else 'no':u) + '\':u)
            , input-output v-value-logical
            , output v-ok
                ).
            if not v-ok then return error.

        assign
        temp-dis-card-property.property-value-logical = v-value-logical.
      end.
    end case.
  end.
  Else do:
    message "Изменение свойства невозможно !" view-as alert-box error.
    return error.
  end.
  run temp-dc-prop-write in this-procedure (
                  input pard-card
                  ,input (if p-add then v-host-code else temp-dis-card-property.host-code)
                  ,input (if p-add then v-obj-type else temp-dis-card-property.OBJ-TYPE)
                  ,input (if p-add then v-obj-code else temp-dis-card-property.obj-code)
                  ,input (if p-add then dtm-option else  temp-dis-card-property.dtm-code)
                  ,input (if p-add then node-code-option else  temp-dis-card-property.node-code)
                  ,input (if p-add then buf_prop-ref.dt-code else  temp-dis-card-property.dt-code)
                  ,input (if p-add then buf_prop-ref.sum-id else  temp-dis-card-property.sum-id)
                  ,input property-value-character
                  ,input property-value-date
                  ,input property-value-decimal
                  ,input property-value-integer
                  ,input property-value-logical
                  ) no-error.
  IF not error-status:error then do:
    assign
    updated = yes
    .
    br-prop:refresh() in frame {&frame-name} no-error .
  END.
  else do:
    message
    substitute("Ошибка при сохранении свойства ДК&1" +
                "ДК &2&1" +
                "Свойство  &3.&4 &5"
                , {&new-line}
                , pard-card
                ,(if p-add then dtm-option else  temp-dis-card-property.dtm-code)
                ,(if p-add then node-code-option else  temp-dis-card-property.node-code)
                ,(if p-add then buf_prop-ref.sum-id else  temp-dis-card-property.sum-id)
                )
    return-value view-as alert-box .
    return error .
  end.
end. /*if node-code-option > 0 then do:*/
else do:
  find first buf_attr-prop no-lock where
            buf_attr-prop.table-name = {&table_dis-card-property}
        and buf_attr-prop.templ-rl-root = (if p-add then dtm-option else temp-dis-card-property.dtm-code)
        and buf_attr-prop.upper-prop-code = "InputForm":U
        and buf_attr-prop.prop-code = "FormName":U no-error.
  if not available buf_attr-prop then do:
  end.
  else do:
     run value ( buf_attr-prop.property-value) (
                                               INPUT parparentproc
                                              ,INPUT (if p-add then {&add-def} else {&update})
                                              ,INPUT (if p-add then dtm-option else temp-dis-card-property.dtm-code)
                                              ,INPUT (if p-add then buf_prop-ref.sum-id else temp-dis-card-property.sum-id)
                                              ,INPUT (if p-add then buf_prop-ref.dt-code else temp-dis-card-property.dt-code)
                                              ,INPUT (if p-add then 0 else temp-dis-card-property.node-code)
                                              ,INPUT p-emitent-host-code
                                              ,INPUT p-type
                                              ,INPUT pard-card
                                              ,INPUT (if p-add then v-host-code else temp-dis-card-property.host-code)
                                              ,INPUT (if p-add then v-obj-type else temp-dis-card-property.obj-type)
                                              ,INPUT (if p-add then v-obj-code else temp-dis-card-property.obj-code)
                                              ,INPUT-OUTPUT TABLE temp-dis-card-property
                                              ,OUTPUT v-ok
                                                ) no-error .
      IF not error-status:error then do:
        if v-ok then do:
          assign
          updated = yes
          .
          br-prop:refresh() in frame {&frame-name} no-error .
        end.
      END.
      else do:
        message
        substitute("Ошибка при сохранении свойства ДК&1" +
                    "ДК &2&1" +
                    "Свойство  &3 срез &4"
                    , {&new-line}
                    , pard-card
                    ,(if p-add then dtm-option else  temp-dis-card-property.dtm-code)
                    ,(if p-add then buf_prop-ref.sum-id else  temp-dis-card-property.sum-id)
                    )
        return-value view-as alert-box .
        return error .
      end.
  end.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-lkp Dialog-Frame
PROCEDURE proc-b-lkp :
define variable v-type as character no-undo . /*тип */
define variable v-format as character no-undo .  /* формат */
define variable v-label as character no-undo .         /*лабел  */
define variable v-rw-option as character no-undo .  /*пользователь может изменять в броусе*/
define variable property-value-character as character no-undo .              /*для знач по умолч*/
define variable property-value-date as date no-undo .              /*для знач по умолч*/
define variable property-value-decimal as decimal no-undo .              /*для знач по умолч*/
define variable property-value-integer as integer no-undo .              /*для знач по умолч*/
define variable property-value-logical as logical no-undo .              /*для знач по умолч*/
define variable v-range as integer no-undo .              /*для области действия*/
define variable v-run-name as character no-undo .
define variable jj as integer no-undo .
define variable v-ok as logical no-undo .
define buffer buf_attr-prop for ub.attr-prop.
  run discprop-node-code (
                       input temp-dis-card-property.dtm-code
                      ,input temp-dis-card-property.node-code
                      ,output v-type
                      ,output v-format
                      ,output v-label
                      ,output v-range
                      ,output v-rw-option
                      ) NO-ERROR.

IF ERROR-STATUS:ERROR THEN DO:
    {&dcattr-type-get-error}
    return error.
END.
find first buf_attr-prop no-lock where
          buf_attr-prop.table-name = {&table_dis-card-property}
      and buf_attr-prop.templ-rl-root = temp-dis-card-property.dtm-code
      and buf_attr-prop.upper-prop-code = "InputForm":U
      and buf_attr-prop.prop-code = "FormName":U no-error.
if not available buf_attr-prop then do:
end.
else do:
  run value ( buf_attr-prop.property-value) (
                                           INPUT parparentproc
                                          ,INPUT {&lookup}
                                          ,INPUT temp-dis-card-property.dtm-code
                                          ,INPUT temp-dis-card-property.sum-id
                                          ,INPUT temp-dis-card-property.dt-code
                                          ,INPUT temp-dis-card-property.node-code
                                          ,INPUT p-emitent-host-code
                                          ,INPUT p-type
                                          ,INPUT pard-card
                                          ,INPUT temp-dis-card-property.host-code
                                          ,INPUT temp-dis-card-property.obj-type
                                          ,INPUT temp-dis-card-property.obj-code
                                          ,INPUT-OUTPUT TABLE temp-dis-card-property
                                          ,OUTPUT v-ok
                                            ) no-error .
  apply "entry" to br-prop in frame {&frame-name} .
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-save Dialog-Frame
PROCEDURE proc-save :
DEFINE VARIABLE v-updated AS LOGICAL NO-UNDO.
define variable v-created as logical no-undo .
define variable v-deleted as logical no-undo .
define variable v-updated-str as character no-undo .
define variable v-type as character no-undo .
define variable v-issue-host-code like ub.sysconf.host-code no-undo .
define variable v-chip-num as integer no-undo init 0.
define variable v-corr-date as date init ?.
define variable v-corr-time as integer no-undo init ?.
for each temp-dis-card-property NO-LOCK
break
by temp-dis-card-property.dt-code
:
   find first tt0-dis-card-property NO-LOCK WHERE
          tt0-dis-card-property.d-card = temp-dis-card-property.d-card
    AND   tt0-dis-card-property.host-code = temp-dis-card-property.host-code
    AND   tt0-dis-card-property.obj-type = temp-dis-card-property.obj-type
    AND   tt0-dis-card-property.obj-code = temp-dis-card-property.obj-code
    AND   tt0-dis-card-property.node-code = temp-dis-card-property.node-code
    AND   tt0-dis-card-property.dt-code = temp-dis-card-property.dt-code  no-error.
  assign
  v-updated = no.
  if available  tt0-dis-card-property then do:
    BUFFER-COMPARE temp-dis-card-property
    except card-num main-card first-card first-main-card
    TO tt0-dis-card-property
    case-sensitive
    SAVE result IN v-updated-str.
    assign
    v-created = yes
    v-updated = (v-updated-str <> "":U)
    .
  end.
  else do:
    assign
    v-updated = yes.
  end.
  if v-updated then do:
    CASE p-update-instantly:
      when no then do:
        run tt0-dc-prop-write in this-procedure(
                                                   input PARd-card
                                                  ,input temp-dis-card-property.host-code
                                                  ,input temp-dis-card-property.obj-type
                                                  ,input temp-dis-card-property.obj-code
                                                  ,input temp-dis-card-property.dtm-code
                                                  ,input temp-dis-card-property.node-code
                                                  ,input temp-dis-card-property.dt-code
                                                  ,input temp-dis-card-property.sum-id
                                                  ,input temp-dis-card-property.property-value-character
                                                  ,input temp-dis-card-property.property-value-date
                                                  ,input temp-dis-card-property.property-value-decimal
                                                  ,input temp-dis-card-property.property-value-integer
                                                  ,input temp-dis-card-property.property-value-logical
                                                  )  no-error.
        if error-status:error then do:
          message
          substitute("Ошибка при сохранении свойства ДК&1" +
                     "ДК &2&1" +
                     "Свойство &3.&4 срез &5" +
                     "&6&1&7"
                    ,{&new-line}
                    ,pard-card
                    ,temp-dis-card-property.dtm-code
                    ,temp-dis-card-property.node-code
                    ,temp-dis-card-property.dt-code
                    ,error-status:get-message(1)
                    ,return-value
                    )
          view-as alert-box  error .
          undo, return error  .
        end.
        updated = yes.
      end. /*when no*/
      when yes then do:
        if first-of(temp-dis-card-property.dt-code) then do:
          assign
          v-chip-num = 0
          v-corr-date = ?
          v-corr-time = ?
          .
        end.
        run discprop-write in this-procedure (
                                             input PARd-card
                                            ,input temp-dis-card-property.host-code
                                            ,input temp-dis-card-property.obj-type
                                            ,input temp-dis-card-property.obj-code
                                            ,input temp-dis-card-property.dtm-code
                                            ,input temp-dis-card-property.node-code
                                            ,input temp-dis-card-property.dt-code
                                            ,input temp-dis-card-property.sum-id
                                            ,input temp-dis-card-property.property-value-character
                                            ,input temp-dis-card-property.property-value-date
                                            ,input temp-dis-card-property.property-value-decimal
                                            ,input temp-dis-card-property.property-value-integer
                                            ,input temp-dis-card-property.property-value-logical
                                            ,input '':U /*p-source-type*/
                                            ,input '':U /*p-source-ref*/
                                            ,input-output v-chip-num
                                            ,input-output v-corr-date
                                            ,input-output v-corr-time
                                            )  no-error.
        if error-status:error then do:
          message
          substitute("Ошибка при сохранении свойства ДК&1" +
                     "ДК &2&1"  +
                     "Свойство &3.&4 срез &5" +
                     "&6&1&7"
                    ,{&new-line}
                    ,pard-card
                    ,temp-dis-card-property.dtm-code
                    ,temp-dis-card-property.node-code
                    ,temp-dis-card-property.dt-code
                    ,error-status:get-message(1)
                    ,return-value
                    )
          view-as alert-box error .
          undo, return error  .
        end.
        updated = yes.
      end.
    END CASE.
  end.
  ASSIGN
  p-updated = v-updated OR p-updated.
End.
FOR EACH tt0-dis-card-property
break by tt0-dis-card-property.dt-code
:
  if first-of(tt0-dis-card-property.dt-code) then do:
    assign
    v-chip-num = 0
    v-corr-date = ?
    v-corr-time = ?
    .
  end.
  FIND FIRST temp-dis-card-property NO-LOCK WHERE
            temp-dis-card-property.d-card = tt0-dis-card-property.d-card
        AND temp-dis-card-property.host-code = tt0-dis-card-property.host-code
        AND temp-dis-card-property.obj-type = tt0-dis-card-property.obj-type
        AND temp-dis-card-property.obj-code = tt0-dis-card-property.obj-code
        AND temp-dis-card-property.dtm-code = tt0-dis-card-property.dtm-code
        AND temp-dis-card-property.node-code = tt0-dis-card-property.node-code
        AND temp-dis-card-property.dt-code = tt0-dis-card-property.dt-code    NO-ERROR.
    IF NOT AVAILABLE temp-dis-card-property THEN DO:
      CASE p-update-instantly:
        when no then do:
          DELETE tt0-dis-card-property.
          assign
          v-deleted = yes.
        end.
        when yes then do:
          v-deleted = no.
          run discprop-delete in this-procedure(
                                                 input PARd-card
                                                ,input tt0-dis-card-property.host-code
                                                ,input tt0-dis-card-property.OBJ-TYPE
                                                ,input tt0-dis-card-property.obj-code
                                                ,input tt0-dis-card-property.dtm-code
                                                ,input tt0-dis-card-property.node-code
                                                ,input tt0-dis-card-property.dt-code
                                                ,input '':U /*p-source-type*/
                                                ,input '':U /*p-source-ref*/
                                                ,output v-deleted
                                                ,input-output v-chip-num
                                                ,input-output v-corr-date
                                                ,input-output v-corr-time
                                                ) no-error   .
          if error-status:error or not v-deleted then do:
            message
            substitute("Ошибка при удалении свойства ДК&1" +
                       "ДК &2&1" +
                       "Свойство &3.&4 срез &5"
                      ,{&new-line}
                      ,pard-card
                      ,tt0-dis-card-property.dtm-code
                      ,tt0-dis-card-property.node-code
                      ,tt0-dis-card-property.dt-code
                    ,error-status:get-message(1)
                    ,return-value
                      )
            return-value view-as alert-box .
            undo, return error.
          end.
        end.
      END CASE.
      ASSIGN
      p-updated = (v-deleted OR p-updated).
    END.
END.
if can-find(first dcp-list) then do:
  /*отошлем один раз на магазин выпустивший карту с флагом экспорт-импорт*/
  run str/diallog.w (
                  input parparentproc
                , input this-procedure
                , input 'str/sendclia.p':U
                , input(string(g#db-num) + {&delim-par} + "shop=" + string(locked_Dis-card.issue-code) + {&delim-par} + "no":U + {&delim-par} + "E":U)
                , input yes /*p-auto-go*/
                , input '':U
                , input 'Отправка информации по клиентским картам на кассу ЭКСПОРТА') no-error .

end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE set-row-color Dialog-Frame
PROCEDURE set-row-color :
DEFINE INPUT PARAMETER p-data-type AS CHARACTER NO-UNDO.
ASSIGN
v-ch[1]:FGCOLOR = GREY_COLOR
v-ch[1]:BGCOLOR = GREY_Color
v-ch[1]:PFCOLOR = GREY_Color
v-ch[2]:FGCOLOR = GREY_COLOR
v-ch[2]:BGCOLOR = GREY_Color
v-ch[2]:PFCOLOR = GREY_Color
v-ch[3]:FGCOLOR = GREY_COLOR
v-ch[3]:BGCOLOR = GREY_Color
v-ch[3]:PFCOLOR = GREY_Color
v-ch[4]:FGCOLOR = GREY_COLOR
v-ch[4]:BGCOLOR = GREY_Color
v-ch[4]:PFCOLOR = GREY_Color
v-ch[5]:FGCOLOR = GREY_COLOR
v-ch[5]:BGCOLOR = GREY_Color
v-ch[5]:PFCOLOR = GREY_Color
.
CASE entry(1, p-data-type):
     WHEN {&ABL-datatype-character} THEN DO:
      ASSIGN
      v-ch[1]:FGCOLOR = BLACK_COLOR
      v-ch[1]:BGCOLOR = WHITE_Color.
    END.
    WHEN {&ABL-datatype-decimal} THEN DO:
      ASSIGN
      v-ch[3]:FGCOLOR = BLACK_COLOR
      v-ch[3]:BGCOLOR = WHITE_Color.
    END.
    WHEN {&ABL-datatype-integer} THEN DO:
      ASSIGN
      v-ch[4]:FGCOLOR = BLACK_COLOR
      v-ch[4]:BGCOLOR = WHITE_Color.
    END.
    WHEN {&ABL-datatype-date} THEN DO:
      ASSIGN
      v-ch[2]:FGCOLOR = BLACK_COLOR
      v-ch[2]:BGCOLOR = WHITE_Color.
     END.
     WHEN {&ABL-datatype-logical} THEN DO:
       ASSIGN
       v-ch[5]:FGCOLOR = BLACK_COLOR
       v-ch[5]:BGCOLOR = WHITE_Color.
     END.
END CASE.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE temp-dc-prop-exist Dialog-Frame
PROCEDURE temp-dc-prop-exist :
do
  on error undo, return error
  :
    define input parameter p-d-card     like ub.dis-card-property.d-card     no-undo .
    define input parameter p-host-code  like ub.dis-card-property.host-code  no-undo .
    define input parameter p-obj-type   like ub.dis-card-property.obj-type   no-undo .
    define input parameter p-obj-code   like ub.dis-card-property.obj-code   no-undo .
    define input parameter p-dtm-code   like ub.dis-card-property.dtm-code  no-undo .
    define input parameter p-node-code  like ub.dis-card-property.node-code  no-undo .
    define input parameter p-dt-code    like ub.dis-card-property.dt-code  no-undo .
    define output parameter p-exist      as logical  no-undo .

    define buffer buf_temp-dis-card-property for temp-dis-card-property .

    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable V-RANGE          as integer   no-undo .
    define variable v-rw-option      as character no-undo .

    run discprop-node-code in this-procedure (
       input  p-dtm-code           /* p-code           */
      ,input  p-node-code           /* p-code           */
      ,output v-type           /* p-type           */
      ,output v-format         /* p-format         */
      ,output v-label          /* p-label          */
      ,OUTPUT V-RANGE          /* P-RANGE          */
      ,output v-rw-option      /* p-user-can-edit  */
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.

    find first buf_temp-dis-card-property no-lock
      where buf_temp-dis-card-property.d-card    = p-d-card
        and buf_temp-dis-card-property.host-code = p-host-code
        and buf_temp-dis-card-property.obj-type  = p-obj-type
        and buf_temp-dis-card-property.obj-code  = p-obj-code
        and buf_temp-dis-card-property.dtm-code = p-dtm-code
        and buf_temp-dis-card-property.node-code = p-node-code
        and buf_temp-dis-card-property.dt-code = p-dt-code
      no-error .
    if  available buf_temp-dis-card-property then do:
      p-exist = yes.
    end.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE temp-dc-prop-write Dialog-Frame
PROCEDURE temp-dc-prop-write :
do
  on error undo, return error
  :
    define input parameter p-d-card    like ub.dis-card-property.d-card     no-undo .
    define input parameter p-host-code like ub.dis-card-property.host-code  no-undo .
    define input parameter p-obj-type  like ub.dis-card-property.obj-type   no-undo .
    define input parameter p-obj-code  like ub.dis-card-property.obj-code   no-undo .
    define input parameter p-dtm-code  like ub.dis-card-property.dtm-code   no-undo .
    define input parameter p-node-code like ub.dis-card-property.node-code  no-undo .
    define input parameter p-dt-code   like ub.dis-card-property.dt-code    no-undo .
    define input parameter p-sum-id    like ub.dis-card-property.sum-id     no-undo .
    define input parameter p-value-character like ub.dis-card-property.property-value-character no-undo .
    define input parameter p-value-date      like ub.dis-card-property.property-value-date no-undo .
    define input parameter p-value-decimal   like ub.dis-card-property.property-value-decimal no-undo .
    define input parameter p-value-integer   like ub.dis-card-property.property-value-integer no-undo .
    define input parameter p-value-logical   like ub.dis-card-property.property-value-logical no-undo .

    define buffer buf_temp-dis-card-property for temp-dis-card-property .
    define buffer buf_dis-card for ub.dis-card.

    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-range          as integer   no-undo .
    define variable v-rw-option      as character no-undo .

    run discprop-node-code in this-procedure (
       input  p-dtm-code           /* p-dtm-code           */
      ,input  p-node-code          /* p-node-code           */
      ,output v-type           /* p-type           */
      ,output v-format         /* p-format         */
      ,output v-label          /* p-label       */
      ,output v-range          /* p-range      */
      ,output v-rw-option     /* p-rw-option  */
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    if p-mode <> {&add-def} then do:
      run discprop-check in this-procedure  (
                       input v-range
                      ,input p-d-card
                      ,input p-host-code
                      ,input p-obj-type
                      ,input p-obj-code
                      ,input p-dtm-code
                      ,input p-node-code
                      ,input p-dt-code
                    ) no-error .
      if error-status:error then undo,  return error return-value .
    end.
    find first buf_temp-dis-card-property exclusive-lock
      where buf_temp-dis-card-property.d-card    = p-d-card
        and buf_temp-dis-card-property.host-code = p-host-code
        and buf_temp-dis-card-property.obj-type  = p-obj-type
        and buf_temp-dis-card-property.obj-code  = p-obj-code
        and buf_temp-dis-card-property.dtm-code = p-dtm-code
        and buf_temp-dis-card-property.node-code = p-node-code
        and buf_temp-dis-card-property.dt-code = p-dt-code
      no-error .
    if not available buf_temp-dis-card-property then do:
      create buf_temp-dis-card-property .
      assign
      buf_temp-dis-card-property.d-card    = p-d-card
      buf_temp-dis-card-property.host-code = p-host-code
      buf_temp-dis-card-property.obj-type  = p-obj-type
      buf_temp-dis-card-property.obj-code  = p-obj-code
      buf_temp-dis-card-property.dtm-code = p-dtm-code
      buf_temp-dis-card-property.dt-code = p-dt-code
      buf_temp-dis-card-property.sum-id = p-sum-id
      buf_temp-dis-card-property.node-code = p-node-code
      buf_temp-dis-card-property.node-label = v-label
      buf_temp-dis-card-property.card-num  = 0
      .
    end.
    else do:
      if (v-type = {&abl-datatype-character}
      and buf_temp-dis-card-property.property-value-character = p-value-character)
      or  (v-type = {&abl-datatype-date}
          and buf_temp-dis-card-property.property-value-date = p-value-date)
      or  (v-type = {&abl-datatype-decimal}
          and buf_temp-dis-card-property.property-value-decimal = p-value-decimal)
      or  (v-type = {&abl-datatype-integer}
          and buf_temp-dis-card-property.property-value-integer = p-value-integer)
      or  (v-type = {&abl-datatype-logical}
          and buf_temp-dis-card-property.property-value-logical = p-value-logical)
      then return.
    end.
    assign
    buf_temp-dis-card-property.property-value-character = p-value-character
    buf_temp-dis-card-property.property-value-date = p-value-date
    buf_temp-dis-card-property.property-value-decimal = p-value-decimal
    buf_temp-dis-card-property.property-value-integer = p-value-integer
    buf_temp-dis-card-property.property-value-logical = p-value-logical
    .
    release buf_temp-dis-card-property no-error .
    if error-status:error then do:
      return error return-value .
    end.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE tt0-dc-prop-write Dialog-Frame
PROCEDURE tt0-dc-prop-write :
do
  on error undo, return error
  :
    define input parameter p-d-card          like ub.dis-card-property.d-card     no-undo .
    define input parameter p-host-code       like ub.dis-card-property.host-code  no-undo .
    define input parameter p-obj-type        like ub.dis-card-property.obj-type   no-undo .
    define input parameter p-obj-code        like ub.dis-card-property.obj-code   no-undo .
    define input parameter p-dtm-code        like ub.dis-card-property.dtm-code  no-undo .
    define input parameter p-node-code       like ub.dis-card-property.node-code  no-undo .
    define input parameter p-dt-code         like ub.dis-card-property.dt-code  no-undo .
    define input parameter p-sum-id          like ub.dis-card-property.sum-id  no-undo .
    define input parameter p-value-character like ub.dis-card-property.property-value-character no-undo .
    define input parameter p-value-date      like ub.dis-card-property.property-value-date no-undo .
    define input parameter p-value-decimal   like ub.dis-card-property.property-value-decimal no-undo .
    define input parameter p-value-integer   like ub.dis-card-property.property-value-integer no-undo .
    define input parameter p-value-logical   like ub.dis-card-property.property-value-logical no-undo .

    define buffer buf_tt0-dis-card-property for tt0-dis-card-property .
    define buffer buf_dis-card for ub.dis-card.

    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-range          as integer no-undo .
    define variable v-rw-option      as character  no-undo .

    run discprop-node-code in this-procedure (
                                         input  p-dtm-code       /* p-dtm-code        */
                                        ,input  p-node-code      /* p-node-code      */
                                        ,output v-type           /* p-type           */
                                        ,output v-format         /* p-format         */
                                        ,output v-label          /* p-label          */
                                        ,output v-range          /* p-range          */
                                        ,output v-rw-option      /* p-rw-option      */
                                        ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    if p-mode <> {&add-def} then do:
      run trg/dc-prop2.p (
                             input v-range
                            ,input p-d-card
                            ,input p-host-code
                            ,input p-obj-type
                            ,input p-obj-code
                            ,input p-dtm-code
                            ,input p-node-code
                            ,input p-dt-code
                          ) no-error .
      if error-status:error then undo,  return error return-value .
    end.
    find first buf_tt0-dis-card-property exclusive-lock
      where buf_tt0-dis-card-property.d-card    = p-d-card
        and buf_tt0-dis-card-property.host-code = p-host-code
        and buf_tt0-dis-card-property.obj-type  = p-obj-type
        and buf_tt0-dis-card-property.obj-code  = p-obj-code
        and buf_tt0-dis-card-property.dt-code = p-dt-code
        and buf_tt0-dis-card-property.node-code = p-node-code
      no-error .
    if not available buf_tt0-dis-card-property then do:
      create buf_tt0-dis-card-property .
      assign
        buf_tt0-dis-card-property.d-card    = p-d-card
        buf_tt0-dis-card-property.host-code = p-host-code
        buf_tt0-dis-card-property.obj-type  = p-obj-type
        buf_tt0-dis-card-property.obj-code  = p-obj-code
        buf_tt0-dis-card-property.dtm-code = p-dtm-code
        buf_tt0-dis-card-property.node-code = p-node-code
        buf_tt0-dis-card-property.dt-code = p-dt-code
        buf_tt0-dis-card-property.sum-id = p-sum-id
        buf_tt0-dis-card-property.card-num  = 0
      .
    end.
    else do:
      if (v-type = {&abl-datatype-character}
      and buf_tt0-dis-card-property.property-value-character = p-value-character)
      or  (v-type = {&abl-datatype-date}
          and buf_tt0-dis-card-property.property-value-date = p-value-date)
      or  (v-type = {&abl-datatype-decimal}
          and buf_tt0-dis-card-property.property-value-decimal = p-value-decimal)
      or  (v-type = {&abl-datatype-integer}
          and buf_tt0-dis-card-property.property-value-integer = p-value-integer)
      or  (v-type = {&abl-datatype-logical}
          and buf_tt0-dis-card-property.property-value-logical = p-value-logical)
      then return.
    end.
    assign
    buf_tt0-dis-card-property.property-value-character = p-value-character
    buf_tt0-dis-card-property.property-value-date = p-value-date
    buf_tt0-dis-card-property.property-value-decimal = p-value-decimal
    buf_tt0-dis-card-property.property-value-integer = p-value-integer
    buf_tt0-dis-card-property.property-value-logical = p-value-logical
    .
    release buf_tt0-dis-card-property no-error .
    if error-status:error then do:
      return error return-value .
    end.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION display-character Dialog-Frame
FUNCTION display-character RETURNS CHARACTER
  ( INPUT p-character AS CHARACTER, INPUT p-format AS CHARACTER) :
DEFINE VARIABLE v-string AS CHARACTER NO-UNDO.

IF trim(p-format, "*") = "" THEN
  v-string = string(p-character, p-format).
ELSE DO:
  v-string = p-character.
END.

RETURN v-string.
END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-prop-value Dialog-Frame
FUNCTION get-prop-value RETURNS CHARACTER
     ( INPUT p-data-type AS CHARACTER
   ,INPUT p-value-character AS CHARACTER
   ,INPUT p-value-date AS DATE
   ,INPUT p-value-decimal AS DECIMAL
   ,INPUT p-value-integer AS INTEGER
   ,INPUT p-value-logical AS LOGICAL
 ) :

define buffer buf_cash-pay for ub.cash-pay.
case trim(p-data-type, {&comma-char}):
  when {&abl-datatype-character} then do:
    return p-value-character.
  end.
  when {&abl-datatype-date} then do:
    return string(p-value-date, "99/99/9999").
  end.
  when {&abl-datatype-decimal} then do:
    return string(p-value-decimal).
  end.
  when {&abl-datatype-integer} then do:
    return string(p-value-integer).
  end.
  when {&abl-datatype-logical} then do:
    return string(p-value-logical).
  end.
end.
END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
