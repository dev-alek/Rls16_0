&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME d-prod-cds


/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE prod-cds NO-UNDO LIKE ub.prod-bc
       field cli-base-rate like ub.bar-code.cli-base-rate
       field unit-cli like ub.bar-code.unit-cli
       field in-code like ub.bar-code.in-code
       field part-code like ub.bar-code.part-code
       field price-sale like ub.price-list.price-sale
       field d-pcnt like ub.price-list.d-pcnt
       field dtl-name as char
       field rid as recid
       field doc-num like ub.price-doc.doc-num
       field is-global as logical
       field is-prod-bc as logical
       index pi is unique primary
       b-code b-str cr-db-num
       .



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS d-prod-cds
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Список дополнительных кодов

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/09/05
Author: Bakhtadze Natalya
Creation date: 09/09/05

Author: Андрей Исаков
Created: 11.05.2001

Input Parameters:

  mode:

  code-all        - все дополнительные коды по собственному коду
                    Если base-bc соответствует:
                    - основному (главному) коду, то по всем собственным, ссылающимся на тот же товар/признак/партию
                    - неосновному, то только по этому коду

  scl-gds-all     - все дополнительные коды по собственным по признакам по товару
  par-gds-all     - все дополнительные коды по собственным по партиям   по товару
  gds-all         - все дополнительные коды по собственным              по товару
  all-no-part     - все основные и неосновные коды не по партии

  g-code          - код товара
  base-bc         - основной код

  Output Parameters:

  rec-list - список выбранных prod-bc (по recid)


*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT  PARAMETER parParentProc  AS WIDGET-HANDLE NO-UNDO.
define input  parameter p-obj-type like ub.clients.obj-type no-undo .
define input  parameter p-obj-code like ub.clients.obj-code no-undo .
define input  parameter mode     as char             no-undo.
define input  parameter g-code  like ub.goods.gds-code  no-undo.
define input  parameter base-bc like ub.bar-code.b-code no-undo.
define output parameter p-rec-list as char             no-undo.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Список дополнительных кодов".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/showinf.i }
{ trg/new-bcod.i }
{ cmp/lcssshbl.i }
{ gbl/getcntxt.i def }
{ gbl/thbj-def.i }

define buffer base-bar-code for ub.bar-code.
define variable mark as character  no-undo.
define variable rid  as recid no-undo.
define variable v-show-db-num as logical no-undo .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME d-prod-cds
&Scoped-define BROWSE-NAME br-cds

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES prod-cds

/* Definitions for BROWSE br-cds                                        */
&Scoped-define FIELDS-IN-QUERY-br-cds get-mark (prod-cds.rid) @ mark prod-cds.bc-on prod-cds.b-str prod-cds.is-global prod-cds.cr-db-num prod-cds.b-code prod-cds.cli-base-rate prod-cds.d-pcnt prod-cds.price-sale prod-cds.unit-cli prod-cds.dtl-name prod-cds.doc-num
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-cds
&Scoped-define SELF-NAME br-cds
&Scoped-define QUERY-STRING-br-cds FOR EACH prod-cds NO-LOCK
&Scoped-define OPEN-QUERY-br-cds OPEN QUERY {&SELF-NAME} FOR EACH prod-cds NO-LOCK.
&Scoped-define TABLES-IN-QUERY-br-cds prod-cds
&Scoped-define FIRST-TABLE-IN-QUERY-br-cds prod-cds


/* Definitions for DIALOG-BOX d-prod-cds                                */
&Scoped-define FIELDS-IN-QUERY-d-prod-cds prod-cds.b-str
&Scoped-define OPEN-BROWSERS-IN-QUERY-d-prod-cds ~
    ~{&OPEN-QUERY-br-cds}
&Scoped-define QUERY-STRING-d-prod-cds FOR EACH prod-cds SHARE-LOCK
&Scoped-define OPEN-QUERY-d-prod-cds OPEN QUERY d-prod-cds FOR EACH prod-cds SHARE-LOCK.
&Scoped-define TABLES-IN-QUERY-d-prod-cds prod-cds
&Scoped-define FIRST-TABLE-IN-QUERY-d-prod-cds prod-cds


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS br-cds b-print b-quit b-sel b-mark b-add ~
b-help
&Scoped-Define DISPLAYED-FIELDS prod-cds.b-str
&Scoped-define DISPLAYED-TABLES prod-cds
&Scoped-define FIRST-DISPLAYED-TABLE prod-cds


/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-mark d-prod-cds
FUNCTION get-mark RETURNS CHARACTER
  (local-rid as recid)  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-add
     LABEL "&Добавить"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-mark
     LABEL "&*"
     SIZE 3 BY 1.

DEFINE BUTTON b-print
     LABEL "Пе&чать"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-quit AUTO-GO
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-sel AUTO-GO
     LABEL "Вы&бор"
     SIZE 10 BY 1
     BGCOLOR 8 .

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-cds FOR
      prod-cds SCROLLING.

DEFINE QUERY d-prod-cds FOR
      prod-cds SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-cds
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-cds d-prod-cds _FREEFORM
  QUERY br-cds DISPLAY
      get-mark (prod-cds.rid) @ mark format "x(1)"  column-label "*"
      prod-cds.bc-on                   format "+/"  column-label "+"
      prod-cds.b-str                                column-label "Доп. код"
      prod-cds.is-global               FORMAT "+/-" column-label "Глоб"
      prod-cds.cr-db-num             FORMAT ">>>>9" column-label "Создан(БД)"
      prod-cds.b-code                               column-label "Соб. код"
      prod-cds.cli-base-rate                        column-label "Коэф"
      prod-cds.d-pcnt                               column-label "Скидка"
      prod-cds.price-sale                           column-label "Цена"
      prod-cds.unit-cli                             column-label "Изм"
      prod-cds.dtl-name              format "x(20)" column-label "Привязка"
      prod-cds.doc-num                              column-label "Переоценка"
      /* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98.3 BY 14.13.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME d-prod-cds
     br-cds AT ROW 2.37 COL 1.1
     b-print AT ROW 1 COL 92
     b-quit AT ROW 1 COL 1
     b-sel AT ROW 1 COL 11
     b-mark AT ROW 1 COL 21
     b-add AT ROW 1 COL 24
     b-help AT ROW 1 COL 95
     prod-cds.b-str AT ROW 16.77 COL 1.1 NO-LABEL FORMAT "X(256)"
          VIEW-AS FILL-IN
          SIZE 98.3 BY 1
          FGCOLOR 4
     SPACE(0.09) SKIP(0.22)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Список дополнительных кодов"
         DEFAULT-BUTTON b-quit CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: prod-cds T "?" NO-UNDO ub prod-bc
      ADDITIONAL-FIELDS:
          field cli-base-rate like bar-code.cli-base-rate
          field unit-cli like bar-code.unit-cli
          field in-code like bar-code.in-code
          field part-code like bar-code.part-code
          field price-sale like price-list.price-sale
          field d-pcnt like price-list.d-pcnt
          field dtl-name as char
          field rid as recid
          field doc-num like price-doc.doc-num
          field is-global as logical
          field is-prod-bc as logical

      END-FIELDS.
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX d-prod-cds
   FRAME-NAME Custom                                                    */
/* BROWSE-TAB br-cds 1 d-prod-cds */
ASSIGN
       FRAME d-prod-cds:SCROLLABLE       = FALSE
       FRAME d-prod-cds:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN prod-cds.b-str IN FRAME d-prod-cds
   NO-ENABLE ALIGN-L EXP-FORMAT                                         */
ASSIGN
       br-cds:NUM-LOCKED-COLUMNS IN FRAME d-prod-cds     = 3.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-cds
/* Query rebuild information for BROWSE br-cds
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH prod-cds NO-LOCK.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE br-cds */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX d-prod-cds
/* Query rebuild information for DIALOG-BOX d-prod-cds
     _TblList          = "Temp-Tables.prod-cds"
     _Options          = "SHARE-LOCK"
     _Query            is NOT OPENED
*/  /* DIALOG-BOX d-prod-cds */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME d-prod-cds
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL d-prod-cds d-prod-cds
ON END-ERROR OF FRAME d-prod-cds /* Список дополнительных кодов */
OR ENDKEY OF FRAME {&frame-name} DO:
   run gbl/markqwa.p (
                           input b-mark:sensitive
                          , input p-rec-list) no-error.
    if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL d-prod-cds d-prod-cds
ON WINDOW-CLOSE OF FRAME d-prod-cds /* Список дополнительных кодов */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-add d-prod-cds
ON CHOOSE OF b-add IN FRAME d-prod-cds /* Добавить */
DO:
define variable sc-code like ub.bar-code.b-code no-undo .
DEFINE VARIABLE case-num as integer no-undo .
DEFINE VARIABLE vattr-codes as character no-undo .
DEFINE VARIABLE vattr-labels as character no-undo .
DEFINE VARIABLE voutput as character no-undo .
DEFINE VARIABLE is-ean as logical no-undo init yes.
DEFINE VARIABLE v-on as logical no-undo .
DEFINE VARIABLE v-b-str like ub.prod-bc.b-str no-undo .
define variable glog as logical no-undo .
define variable glog2 as logical no-undo .
define variable glog3 as logical no-undo .
define variable v-main-b-code as integer   no-undo .
define variable conf-par as character no-undo .
define variable par-type as character no-undo .
define variable unq-artc as logical no-undo .
define variable v-prt-rec as recid no-undo .
define variable v-cdrg-type as character no-undo .
define variable v-rid as recid no-undo .
define variable v-param-type as character no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-tth as handle no-undo .
define buffer buf_code-range for ub.code-range.
define buffer goods_units for ub.units.
define buffer buf_goods for ub.goods.
assign
v-tth = buffer thbjattr_thbj-attr:table-handle .

find first buf_goods no-lock
     where buf_goods.gds-code = g-code no-error.
{ gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_alt-barcode_preparation':U
  {&cntxt-object}
  0
  '':U
  0
  0
  buf_goods.grp-code
  0
  true
  glog
}
if not glog then return no-apply.
/*проверим не является ли этот товар весовым ? */
find first ub.units no-lock where
            ub.units.unit-name = base-bar-code.unit-cli No-ERROR.
if not avail ub.units then return no-apply.
find first goods_units no-lock where
            goods_units.unit-name = ub.goods.unit-base No-ERROR.
if not avail goods_units then return no-apply.
if lookup({&weight}, units.type) > 0 then do:
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_alt-barcode_gbl-sc-code':U
    {&cntxt-object}
    0
    '':U
    0
    0
    buf_goods.grp-code
    0
    true
    glog
  }
  if not glog then case-num = 2.
  else do:
    run gbl/d-askw.w
    (input "Создание дополнительного кода" /* Заголовок окна */
    ,input "Вы действительно хотите создать дополнительный код?" + {&new-line} /* Общее сообщение */
      + "(для весового товара здесь можно ввести только ГЛОБАЛЬНЫЙ ВЕСОВОЙ КОД)" + {&new-line}
    ,input "|^" /* Символы разделители для кодирования двух следующих параметров */
                /* первый символ - разделитель списков названий кнопок и описаний кнопок */
                /* второй символ - разделитель атрибутов в описании кнопок */
    ,input "Глоб.вес. код|Отказ" /* список названий кнопок  */
                                    /* каждая кнопка может иметь необязательный */
                                    /* список атрибутов, влияющих на поведение кнопки */
    ,input "Весовой код, который будет передан по СПН во все БД - ИХ КОЛИЧЕСТВО ОГРАНИЧЕНО|" /* список описаний кнопок */
        + "Отказ от выполнения операции"
    ,input 1 /* значение возвращаемое при нажатии enter */
    ,input 2 /* значение возвращаемое при нажатии escape */
    ,output case-num /* выбор пользователя */
    ).
    if case-num = 2 then return no-apply.
    if case-num = 1 then do:
      v-cdrg-type = {&gbl-sc-code}.
      v-rid = ?.
      run trg/prod-bc1.p ( input parparentproc
                          ,input no /*p-silent*/
                          ,input ? /* dif-pdbc */
                          ,input ? /*pbc-veto*/
                          ,input no /*send-ref*/
                          ,input {&gbl-sc-code}
                          ,input "" /*p-ean-type*/
                          ,buffer goods
                          ,input base-bc
                          ,input-output v-b-str /*p-b-str*/
                          ,output v-rid
                          ) no-error.
      if error-status :error
      or v-rid = ?
      then do:
        undo, return no-apply.
      end.
      else do:
        run UI-on.
        apply "entry" to br-cds in frame {&frame-name}.
        apply "value-changed" to br-cds.
        return no-apply.
      end.
    end. /*case-num = 1 */
  end. /*case-num <> 2 */
end. /*товар весовой*/
{ gbl/gdsbcode.i goods.gds-code ? v-main-b-code }
if lookup({&pieces}, goods_units.type) > 0
and units.type = {&pieces}
and base-bc = v-main-b-code
then do:
  find first buf_code-range no-lock where
            buf_code-range.range-type = {&loc-pg-code}
        and buf_code-range.db-num = 0  no-error.
  if available buf_code-range then do:
    /*предполагается что штучный */
    { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_alt-barcode_loc-pg-code':U
    {&cntxt-global}
    0
    '':U
    0
    0
    buf_goods.grp-code
    0
    true
    glog3
    }
  end.
  if glog3 then do:
    for each thbjattr_thbj-attr:
      delete thbjattr_thbj-attr.
    end.

    run adm/shattri.p (
          input "get":U
        ,input  '':U
        ,input  0
        ,input  {&attr-gds-ref}
        ,input  "":U /*p-param-code*/
        ,output v-value-character
        ,output v-value-date
        ,output v-value-decimal
        ,output v-value-integer
        ,output v-value-logical
        ,output v-param-type
        ,INPUT-OUTPUT table-handle v-tth
        ) no-error .

    IF error-status:error then do:
      delete object v-tth.
      message
      substitute("Ошибка при получении опций работы со справочником товаров:&1&2 &3"
                , {&new-line}
                , error-status:get-message(1)
                , return-value )
      view-as alert-box error .
      undo, return no-apply .
    end.
    for each thbjattr_thbj-attr  where
            thbjattr_thbj-attr.obj-type = '':U
        and thbjattr_thbj-attr.obj-code = 0
        and thbjattr_thbj-attr.upper-prop-code = {&attr-gds-ref}
    :
      case thbjattr_thbj-attr.prop-code:
        when {&attr-gds-ref_unq-artc} then do :
          unq-artc = thbjattr_thbj-attr.property-value-logical.
        end.
      end case.
    end.
    if unq-artc then do:
      message
      substitute("В Вашей конфигурации диапазон штучных кодов для весов&1" +
                  "уже используется несовместимым образом,&1"  +
                  "поэтому ввод таких кодов ЗАПРЕЩЕН!"
                  , {&new-line})
      view-as alert-box error .
      undo, return no-apply.
    end.
    run gbl/d-askw.w
    (input "Создание дополнительного кода" /* Заголовок окна */
    ,input substitute("Вы действительно хотите создать дополнительный код?&1" + /* Общее сообщение */
                      "(для штучного товара здесь можно ввести обычный Доп. БК&1" +
                      "или ЛОКАЛЬНЫЙ ШТУЧНЫЙ КОД ДЛЯ ВЕСОВ)", {&new-line})
    ,input "|^" /* Символы разделители для кодирования двух следующих параметров */
                /* первый символ - разделитель списков названий кнопок и описаний кнопок */
                /* второй символ - разделитель атрибутов в описании кнопок */
    ,input substitute("Обычный Доп.БК|Лок.штучный|Отказ"
                      )
                      /* список названий кнопок  */
                                    /* каждая кнопка может иметь необязательный */
                                    /* список атрибутов, влияющих на поведение кнопки */
    ,input ("Обычный Доп.БК производителя товара|" /* список описаний кнопок */
        +  "Локальный Код, по которому для товара будет печататься на весах этикетка с указанием количества - ИХ КОЛИЧЕСТВО ОГРАНИЧЕНО|" /* список описаний кнопок */
        + "Отказ от выполнения операции")
    ,input 1 /* значение возвращаемое при нажатии enter */
    ,input 3 /* значение возвращаемое при нажатии escape */
    ,output case-num /* выбор пользователя */
    ).
    if case-num = 3 then return no-apply.
    if case-num = 2 then do:
      v-rid = ?.
      run trg/prod-bc1.p ( input parparentproc
                          ,input no /*p-silent*/
                          ,input ? /* dif-pdbc */
                          ,input ? /*pbc-veto*/
                          ,input no /*send-ref*/
                          ,input {&loc-pg-code}
                          ,input "" /*p-ean-type*/
                          ,buffer goods
                          ,input base-bc
                          ,input-output v-b-str /*p-b-str*/
                          ,output v-rid
                          ) no-error.
      if error-status :error
      or v-rid = ?
      then do:
        undo, return no-apply.
      end.
      else do:
        run UI-on.
        apply "entry" to br-cds in frame {&frame-name}.
        apply "value-changed" to br-cds.
        return no-apply.
      end. /*удалось создать код*/
    end. /*case-num = 2*/
  end. /*if glog3*/
end. /*if units.type = {&pieces} then do:*/
if lookup({&weight}, goods_units.type) > 0 and units.type = {&divisional} then do:
/*предполагается что взвешиваемый*/
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_alt-barcode_loc-ss-code':U
    {&cntxt-object}
    0
    '':U
    0
    0
    buf_goods.grp-code
    0
    true
    glog
  }
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_alt-barcode_gbl-ss-code':U
    {&cntxt-object}
    0
    '':U
    0
    0
    buf_goods.grp-code
    0
    true
    glog2
  }

  if not glog and not glog2 then case-num = 3.
  else do:
    run gbl/d-askw.w
    (input "Создание дополнительного кода" /* Заголовок окна */
    ,input "Вы действительно хотите создать дополнительный код?" + {&new-line} /* Общее сообщение */
      + "(для весового товара здесь можно ввести только ЛОКАЛЬНЫЙ ИЛИ ГЛОБАЛЬНЫЙ КОД ВЗВЕШИВАЕМОГО ТОВАРА)" + {&new-line}
    ,input "|^" /* Символы разделители для кодирования двух следующих параметров */
                /* первый символ - разделитель списков названий кнопок и описаний кнопок */
                /* второй символ - разделитель атрибутов в описании кнопок */
    ,input substitute("Лок.взвеш.код&1|Глоб.взвеш.код&2|Отказ"
                      , (if glog then "" else "^disable")
                      , (if glog2 then "" else "^disable"))
                        /* список названий кнопок  */
                                    /* каждая кнопка может иметь необязательный */
                                    /* список атрибутов, влияющих на поведение кнопки */
    ,input ("Локальный Код, по которому товар будет взвешиваться на сканер-весах кассы - ИХ КОЛИЧЕСТВО ОГРАНИЧЕНО|"
        +  "Глобальный Код, по которому товар будет взвешиваться на сканер-весах кассы - ИХ КОЛИЧЕСТВО ОГРАНИЧЕНО|" /* список описаний кнопок */
        + "Отказ от выполнения операции")
    ,input 1 /* значение возвращаемое при нажатии enter */
    ,input 3 /* значение возвращаемое при нажатии escape */
    ,output case-num /* выбор пользователя */
    ).
  end.
  if case-num = 3 then return no-apply.
  if case-num = 1
  or case-num = 2
  then do:
    /*вывести перечень всех дипазонов*/
    if case-num = 1 then v-cdrg-type = {&loc-ss-code}.
    if case-num = 2 then v-cdrg-type = {&gbl-ss-code}.

    FOR EACH ub.code-range No-LOCK WHERE
        ub.code-range.range-type = (if case-num = 1 then {&loc-ss-code} else {&gbl-ss-code})
        and ub.code-range.db-num = (if case-num = 1 then 0 else v-cntxt-db-num)
    :
      assign
      vattr-labels = vattr-labels +
                     (if vattr-labels = "":U
                      then "":U
                      else {&comma-char}) +
                      string(ub.code-range.first-code, "999999999") + "-":U + string(ub.code-range.last-code, "999999999") +
                      fill({&space-char}, 5) + "----->":U +
                      fill({&space-char}, 5) +
                      MakeShbl(ub.code-range.first-code , ub.code-range.last-code)
      vattr-codes =  vattr-codes +
                     (if vattr-codes = "":U
                      then "":U
                      else {&comma-char}) +
                      {&space-char} +
                      MakeShbl(ub.code-range.first-code , ub.code-range.last-code)
      .
    end.
    run gbl/d-list.w (
                  INPUT "b-sel":U
                  ,INPUT (if case-num = 1
                          then "Диапазоны и шаблоны локальных взвешиваемых кодов"
                          else "Диапазоны и шаблоны глобальных взвешиваемых кодов")
                  ,INPUT vattr-codes
                  ,INPUT vattr-labels
                  ,INPUT {&comma-char}
                  ,INPUT "":U
                  ,output voutput).
    IF voutput = "":u THEN RETURN NO-APPLY.
    is-ean = no.
  end.
end.
case mode:
  when "code-all"
  then do:
    run ref/pbc-form.w
      (input parparentproc
      ,input base-bc
      ,input trim(voutput)
      ,input is-ean
      ,input v-cdrg-type
      ,input-output rid
      ).
  end.
  when "scl-gds-all"
  then do:
    define variable v-sel-node-code as integer   no-undo .
    run str/prt-ref.w
      (input parparentproc
      ,input  goods.gds-code  /* p-gds-code      */
      ,input  {&lookup}       /* p-mode          */
      ,input  p-obj-type      /* p-obj-type      */
      ,input  p-obj-code      /* p-obj-code      */
      ,input  ""              /* p-doc-code      */
      ,input  ""              /* p-search-code   */
      ,output v-sel-node-code /* p-sel-node-code */
      ) .
  end.
  when "par-gds-all"
  then do:
    define variable v-chk-act-host-code as integer   no-undo .
    { gbl/hostcode.i
      p-obj-type
      p-obj-code
      v-chk-act-host-code
    }
    { gbl/chk-actg.i
      v-cntxt-db-num
      v-cntxt-userid
      {&action-head-code-main}
      'actn_archive_cost':U
      {&cntxt-object}
      v-chk-act-host-code
      p-obj-type
      p-obj-code
      0
      0
      0
      true
      glog
    }
    if NOT glog then
      return no-apply .
    run str/parts-l.w
      (
       input parparentproc
      ,input p-obj-type                /* v-obj-type   */
      ,input p-obj-code                /* v-obj-code   */
      ,input goods.gds-code            /* p-gds-code   */
      ,input ""                        /* p-doc-code   */
      ,input {&lookup}                 /* p-edit-mode  */
      ,input {&parts-l_parts-rest}     /* p-r-parts    */
      ,input {&parts-l_object-current} /* p-one-all    */
      ,input {&parts-l_call-reference} /* p-call-point */
      ,output v-prt-rec                  /* part-recid   */
      ) .
  end.
  otherwise do:
    message
      "Для данного режима добавление не работает."
      view-as alert-box.
    return no-apply.
  end.
end case.
run UI-on.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-mark d-prod-cds
ON CHOOSE OF b-mark IN FRAME d-prod-cds /* * */
DO:
if not available prod-cds then  return no-apply.
define variable v-num-entry{&seq} as integer no-undo .
if prod-cds.is-prod-bc = no
and prod-cds.cr-db-num <> v-cntxt-db-num
and not(prod-cds.is-global)
then do:
  message
  "Нельзя выбрать неглобальный ДопБК другой БД!"
  view-as alert-box error .
  return no-apply.
end.
if prod-cds.rid = ? then do:
  message
  "Нельзя выбрать ДопБК другой БД!"
  view-as alert-box error .
  return no-apply.
end.
assign
v-num-entry = lookup(string( prod-cds.rid ), p-rec-list ).
if v-num-entry > 0 then do:
  assign
    entry(v-num-entry, p-rec-list) = "":U
    p-rec-list = replace( p-rec-list, {&comma-char} + {&comma-char}, {&comma-char}) .
    p-rec-list = trim(p-rec-list, {&comma-char}).
end.
else do:
  assign
    p-rec-list = p-rec-list + ( if p-rec-list = "":U then "":U else {&comma-char} ) + string( prod-cds.rid ) .
end.
br-cds :refresh ().
if last-event :function <> "mouse-select-dblclick" then
  br-cds :select-next-row ().
apply "entry" to br-cds in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-print d-prod-cds
ON CHOOSE OF b-print IN FRAME d-prod-cds /* Печать */
DO:
  if available (prod-cds) then do:
   run print-label in this-procedure(prod-cds.rid) no-error.
   if error-status:error then do:
    return no-apply.
   end.
   end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-quit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-quit d-prod-cds
ON CHOOSE OF b-quit IN FRAME d-prod-cds /* Выход */
DO:
  p-rec-list= ''.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sel d-prod-cds
ON CHOOSE OF b-sel IN FRAME d-prod-cds /* Выбор */
DO:
if p-rec-list = "" and
   available prod-cds then
  p-rec-list = string (prod-cds.rid).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-cds
&Scoped-define SELF-NAME br-cds
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-cds d-prod-cds
ON MOUSE-SELECT-DBLCLICK OF br-cds IN FRAME d-prod-cds
DO:
apply "choose" to b-mark in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-cds d-prod-cds
ON RETURN OF br-cds IN FRAME d-prod-cds
DO:
apply "choose" to b-mark in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-cds d-prod-cds
ON VALUE-CHANGED OF br-cds IN FRAME d-prod-cds
DO:
if available prod-cds then
  /* выводим полный длинный бар-код внизу */
  disp prod-cds.b-str with frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK d-prod-cds


{ gbl/hot-key.i b-mark }
{ gbl/hot-key.i b-add }

/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

{ gbl/app_help.i }

{ gbl/mv-clmn.i
  &frame-name = "{&frame-name}"
  &browse-name = "{&browse-name}"
  &table-name = "{&first-table-in-query-{&browse-name}}"
  &start-column = 4
  &ext-col = 10
}


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

  { gbl/getcntxt.i get }

  find ub.goods no-lock where
       ub.goods.gds-code = g-code.
  find first ub.gds-prt no-lock where
             ub.gds-prt.upper-code = ub.goods.prt-root.
  find base-bar-code no-lock where
       base-bar-code.b-code  = base-bc.
  if base-bar-code.gds-code <> ub.goods.gds-code then do:
    message
      "Ошибка параметров prod-cds.w"
      view-as alert-box.
    return error.
  end.
  RUN UI-on.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE cre-prod d-prod-cds
PROCEDURE cre-prod :
define input parameter bc like ub.bar-code.b-code.

define buffer buf-bar-code for ub.bar-code.
define buffer buf-prod-bc  for ub.prod-bc.
define buffer buf_prod-bc-db  for ub.prod-bc-db.
define buffer buf-gds-prt  for ub.gds-prt.
define buffer buf_Units    for ub.units.

define variable local-dtl-name as character                     no-undo.
define variable pr-rec         as recid                    no-undo.
define variable pr-c-b-r       like ub.bar-code.cli-base-rate no-undo.
define variable v-is-scales-code as logical no-undo .

find buf-bar-code no-lock where
     buf-bar-code.b-code = bc.
find buf-gds-prt no-lock where
     buf-gds-prt.node-code = buf-bar-code.node-code.
/* промежуточные отфильтровываем */
if not buf-gds-prt.root and
   not buf-gds-prt.is-term then
  return.
/* привязка */
if buf-gds-prt.upper-code = ub.goods.prt-root then
  if buf-bar-code.in-code = "" then
    local-dtl-name = "".
  else
    if buf-bar-code.part-code = "" then
      local-dtl-name = buf-bar-code.in-code.
    else
      local-dtl-name = buf-bar-code.in-code + " (" + buf-bar-code.part-code + ")".
else
  local-dtl-name = buf-gds-prt.f-name.
/* ищем предыдущую цену кода по текущему объекту */
{ gbl/bcodepls.i
  p-obj-type
  p-obj-code
  buf-bar-code.b-code
  0
  0
  pr-rec
  pr-c-b-r }
if v-cntxt-db-num-obj <> v-cntxt-db-num then do:
  /*найдем невесовой ли это код*/
  find first buf_units no-lock where
            buf_units.unit-name = buf-bar-code.unit-cli .
  if lookup({&weight}, buf_units.type) > 0 then do:
    v-is-scales-code = yes.
  end.
end.
find  ub.price-list no-lock where
      recid (ub.price-list) = pr-rec no-error.
   v-show-db-num = no.
  _buf-prod-bc:
  for each buf-prod-bc no-lock where
          buf-prod-bc.b-code = bc
  :
    create prod-cds.
    buffer-copy buf-prod-bc to prod-cds
      assign
        prod-cds.cli-base-rate = buf-bar-code.cli-base-rate
        prod-cds.unit-cli      = buf-bar-code.unit-cli
        prod-cds.in-code       = buf-bar-code.in-code
        prod-cds.part-code     = buf-bar-code.part-code
        prod-cds.rid           = recid (buf-prod-bc)
        prod-cds.dtl-name      = local-dtl-name
    prod-cds.is-prod-bc    = yes
        .
    { gbl/prodbctv.i
      prod-cds.b-str
      prod-cds.unit-cli
      goods.unit-base
      "'global=request'"
      prod-cds.is-global
      no-error
      }
      if error-status:error then do:
        prod-cds.is-global = ?.
      end.
    if available price-list and
      price-list.b-code = buf-bar-code.b-code then
      /* нашли цену именно на этот неосновной код */
      assign
        prod-cds.price-sale = price-list.price-sale
        prod-cds.d-pcnt     = price-list.d-pcnt
        prod-cds.doc-num    = price-list.doc-num
        .
    else
      if available price-list then
        /* цену вычисляем из главной или специальной */
        assign
          prod-cds.price-sale = price-list.price-sale * buf-bar-code.cli-base-rate
          prod-cds.d-pcnt     = 0
          /* скобочками показываем, что цена унаследована */
          prod-cds.doc-num    = "-"
          .
      else
        /* цены нет никакой */
        assign
          prod-cds.price-sale = ?
          prod-cds.d-pcnt     = ?
          prod-cds.doc-num    = ?
          .
  end.
if v-cntxt-db-num-obj = v-cntxt-db-num
or v-is-scales-code = no
then do:
end.
else do:
   v-show-db-num = yes.
  _buf-prod-bc:
  for each buf_prod-bc-db no-lock where
          buf_prod-bc-db.b-code = bc
  :
    find first prod-cds no-lock where
              prod-cds.b-code = bc
          and prod-cds.b-str  = buf_prod-bc-db.b-str
          and prod-cds.cr-db-num = buf_prod-bc-db.db-num no-error.
    if not available prod-cds then do:
    create prod-cds.
    buffer-copy buf_prod-bc-db to prod-cds
      assign
        prod-cds.cli-base-rate = buf-bar-code.cli-base-rate
        prod-cds.unit-cli      = buf-bar-code.unit-cli
        prod-cds.in-code       = buf-bar-code.in-code
        prod-cds.part-code     = buf-bar-code.part-code
        prod-cds.dtl-name      = local-dtl-name
    prod-cds.cr-db-num     = buf_prod-bc-db.db-num
        .
    { gbl/prodbctv.i
      prod-cds.b-str
      prod-cds.unit-cli
      goods.unit-base
      "'global=request'"
      prod-cds.is-global
      no-error
      }
    if error-status:error then do:
      prod-cds.is-global = ?.
    end.
    if v-is-scales-code
    and (prod-cds.is-global
    or prod-cds.is-global = ?
    or prod-cds.cr-db-num = v-cntxt-db-num
    )
    then do:
      define buffer buf_prod-bc for ub.prod-bc.
      find first buf_prod-bc no-lock where
                buf_prod-bc.b-str = prod-cds.b-str
            and buf_prod-bc.b-code = prod-cds.b-code no-error.
      if available buf_prod-bc then do:
        prod-cds.rid           = recid (buf_prod-bc).
      end.
    end.

    if available price-list and
      price-list.b-code = buf-bar-code.b-code then
      /* нашли цену именно на этот неосновной код */
      assign
        prod-cds.price-sale = price-list.price-sale
        prod-cds.d-pcnt     = price-list.d-pcnt
        prod-cds.doc-num    = price-list.doc-num
        .
    else
      if available price-list then
        /* цену вычисляем из главной или специальной */
        assign
          prod-cds.price-sale = price-list.price-sale * buf-bar-code.cli-base-rate
          prod-cds.d-pcnt     = 0
          /* скобочками показываем, что цена унаследована */
          prod-cds.doc-num    = "-"
          .
      else
        /* цены нет никакой */
        assign
          prod-cds.price-sale = ?
          prod-cds.d-pcnt     = ?
            prod-cds.doc-num    = ?.

    end. /*if not available prod-cds then do:*/
  end.

end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI d-prod-cds  _DEFAULT-DISABLE
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
  HIDE FRAME d-prod-cds.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI d-prod-cds  _DEFAULT-ENABLE
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
  IF AVAILABLE prod-cds THEN
    DISPLAY prod-cds.b-str
      WITH FRAME d-prod-cds.
  ENABLE br-cds b-print b-quit b-sel b-mark b-add b-help
      WITH FRAME d-prod-cds.
  VIEW FRAME d-prod-cds.
  {&OPEN-BROWSERS-IN-QUERY-d-prod-cds}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE print-label d-prod-cds
PROCEDURE print-label :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-rid as recid no-undo.

define variable loc#log as logical no-undo.
define buffer buf_prod-bc for ub.prod-bc .

find first buf_prod-bc no-lock where
            recid(buf_prod-bc) = p-rid no-error.
if not available buf_prod-bc then return error.
if buf_prod-bc.bc-on = no then do:
    message
    "Данный ДопБК выключен" skip
    "Вы действительно хотите напечать этикетку на него?"
    view-as alert-box QUestion buttons YEs-No update loc#log.
    if not loc#log then return error.
end.
    run rep/tick-pbc.p (      input parparentproc
                        ,input p-obj-type
                        ,input p-obj-code
                        ,input recid(buf_prod-bc)
                        ,input buf_prod-bc.b-code
                        ) no-error.
    if error-status:error then return error.



END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE UI-on d-prod-cds
PROCEDURE UI-on :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
ENABLE b-quit b-sel b-mark b-help br-cds b-print WITH FRAME {&frame-name}.
VIEW FRAME {&frame-name}.
for each prod-cds
:
  delete prod-cds.
end.
case mode:
  when "all-no-part" then do:
    frame {&frame-name} :title = "Все ДопБК на все имеющиеся основные и неосновные бар-коды:   " +
                                 "Основной код: " + string (base-bc, ">>>>>>>>9")
                                 .
    for each ub.bar-code no-lock where
             ub.bar-code.gds-code  = base-bar-code.gds-code:
      if ub.bar-code.in-code   = base-bar-code.in-code and
      ub.bar-code.part-code = base-bar-code.part-code then do:
        run cre-prod (ub.bar-code.b-code).
      end.
    end.
  end.
  when "code-all" then do:
    if base-bar-code.unit-cli = ub.goods.unit-cli then do:
      /* основной код */
      frame {&frame-name} :title = "Все дополнительные коды:   Основной код: " + string (base-bc, "999999999") +
                                  "   Товар: " + ub.goods.artic + "  " + ub.goods.gds-name
                                  .
      for each ub.bar-code no-lock where
              ub.bar-code.gds-code  = base-bar-code.gds-code and
              ub.bar-code.node-code = base-bar-code.node-code and
              ub.bar-code.in-code   = base-bar-code.in-code and
              ub.bar-code.part-code = base-bar-code.part-code
      :
        run cre-prod (ub.bar-code.b-code).
      end.
    end.
    else do:
      /* неосновной код */
      frame {&frame-name} :title = "Все дополнительные коды:   Неосновной код: " + string (base-bc, "999999999") +
                                  "   Товар: " + goods.artic + "  " + goods.gds-name
                                  .
      run cre-prod (base-bar-code.b-code).
    end.
    ENABLE b-add WITH FRAME {&frame-name}.
  end.
  when "scl-gds-all" then do:
    frame {&frame-name} :title = "Все дополнительные коды по признакам:   " +
                                 "Товар: " + ub.goods.artic + "  " + ub.goods.gds-name
                                 .
    for each ub.bar-code no-lock where
             ub.bar-code.gds-code  = base-bar-code.gds-code and
             ub.bar-code.in-code   = ""
    :
      run cre-prod (ub.bar-code.b-code).
    end.
    ENABLE b-add WITH FRAME {&frame-name}.
  end.
  when "par-gds-all" then do:
    frame {&frame-name} :title = "Все дополнительные коды по партиям:   " +
                                 "Товар: " + ub.goods.artic + "  " + ub.goods.gds-name
                                 .
    for each ub.bar-code no-lock where
             ub.bar-code.gds-code  = base-bar-code.gds-code and
             ub.bar-code.in-code  <> ""
    :
      run cre-prod (ub.bar-code.b-code).
    end.
    ENABLE b-add WITH FRAME {&frame-name}.
  end.
  when "gds-all" then do:
    frame {&frame-name} :title = "Все дополнительные коды по товару:   " +
                                 "Товар: " + ub.goods.artic + "  " + ub.goods.gds-name
                                 .
    for each ub.bar-code no-lock where
             ub.bar-code.gds-code  = base-bar-code.gds-code
    :
      run cre-prod (ub.bar-code.b-code).
    end.
  end.
  when "code-current" then do:
    frame {&frame-name} :title = "Все дополнительные коды по товару:   Код: " + string (base-bc, "999999999") +
                                 "  Товар: " + ub.goods.artic + "  " + ub.goods.gds-name
                                 .
    run cre-prod (base-bar-code.b-code).
  end.
  when "code-current-other-db-scale" then do:
    frame {&frame-name} :title = "Все дополнительные коды по товару:   Код: " + string (base-bc, "999999999") +
                                 "  Товар: " + ub.goods.artic + "  " + ub.goods.gds-name
                                 .
    run cre-prod (base-bar-code.b-code).
  end.
end case.
frame {&frame-name} :title = frame {&frame-name} :title +
                             "      Текущий объект: " + string (p-obj-type, "x(3)") +
                             " " + string (p-obj-code, ">>>>9").
open query br-cds
  for each prod-cds no-lock.

apply "value-changed" to br-cds in frame {&frame-name}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-mark d-prod-cds
FUNCTION get-mark RETURNS CHARACTER
  (local-rid as recid) :
if local-rid = ? then return "".
if lookup (string (local-rid), p-rec-list) > 0 then
  return "*".
else
  return "".
END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME