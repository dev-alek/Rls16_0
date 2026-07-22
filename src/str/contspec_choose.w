&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Товарная спецификация к договору

Автор: Чернова Светлана Александровна
Дата создания: 03/20/09
Author: Svetlana Chernova
Creation date: 09/14/05


*/

/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */
{ rep/tt-date.i }
/* Parameters Definitions ---                                           */
define input  parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
define input  parameter bttns          as char      no-undo . /* список доступных кнопок */
define input  parameter ref-mode       as character no-undo .   /* {&add-def}, {&update}, {&lookup}, "history" */
define input  parameter p-host-code    as integer   no-undo . /* надо передавать фирму */
define input  parameter p-doc-num      as character   no-undo .
define input  parameter recid_client   as integer no-undo .
define output parameter table for gds-list .
/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Товарная спецификация к договору" .
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }

{ gbl/waitfram.i }
{ cmp/library.i  }
{ gbl/cur-time.i }
{ cmp/r-pril.i   }
{ gbl/prn-lib.i  }
{ str/libbcrcn.i }
{ gbl/integerm.i }
{ gbl/usr-flt.i  }
{ gbl/getcntxt.i def }
{ gbl/fltopend.i defproc }
{ cmp/gds-list.i gds-list-flt def "new shared" }
{ str/contrcth.i }
{ str/libbcrcn.i }   /* Библиотека поиска по бар коду !!! */
{ str/sclspref.i }   /* Снять префиксы и форматы бар кодов, (нужно для инклудника str/bc-rcnz.i) */
{ gbl/thbj-def.i }

define buffer buf_contract-specif for ub.contract-specif .
define buffer buf_contract        for ub.contract .
define buffer buf_ext-artic       for ub.ext-artic  .
define buffer buf_goods           for ub.goods.
define buffer buf_contract-attr   for ub.contract-attr .


define variable v-doc-rec        as recid     no-undo .
DEFINE VARIABLE v-doc-rec-tmp    as RECID     NO-UNDO .
define variable sort-column-name as character no-undo .
define variable f-name           as character no-undo .
define variable is-new           as logical   no-undo initial no .
define variable is-new1          as logical   no-undo initial no .
define variable v-res            as logical   no-undo initial no .
define variable g-log            as logical   no-undo .
define variable b-code           as integer   no-undo .
define variable gds-rec          as recid     no-undo .
define variable v-price          as decimal   no-undo .
define variable v-prc            as decimal   no-undo .
define variable v-prc-2          as decimal   no-undo .
define variable v-VAT-type       as character no-undo .
define variable v-qnty           as decimal   no-undo .
define variable v-cli-base-rate  as decimal   no-undo .
define variable v-unit-cli       as character no-undo .
define variable v-vat-pc         as decimal   no-undo .
define variable v-bonus          as decimal   no-undo .
define variable old-bonus        as decimal   no-undo .
define variable old-prc-min      as decimal   no-undo .
define variable v-contr-type     as character no-undo .
define variable filter-point     as character no-undo init "Товарная спецификация к договору" .
define variable filter-point0    as character no-undo init "Товарная спецификация к договору" .
define variable p-ask            as logical   no-undo .
define variable v-ask            as logical   no-undo .
define variable v-list-mat       as character no-undo .
define variable head-col         as character no-undo .
define variable v-order-column   as character no-undo .
define variable v-spis-size      as character no-undo .
define variable v-spis-vis       as character no-undo .
define variable hcolumn          as handle    extent 100 no-undo.
define variable v-retro-bonus    as character no-undo .
define variable old-retro-bonus  as character no-undo .
define variable v-change-fields  as character no-undo .
define variable v-rid-list       as character no-undo .
define variable row_spec         as rowid     no-undo .
/*v-err-ext = false  .*/
/*v-longchar = "".*/
{ ref/clearlm.i }


/*define new shared buffer temp-trn-doc for gds-list-flt  .*/
define variable r-2                 as integer   no-undo init 1 .
define variable v-mark-seq          as integer   no-undo.
define variable p-bcode             as character no-undo .
define variable p-prod              as character no-undo .
define variable p-grp               as character no-undo .
define variable p-bonus             as decimal   no-undo .
define variable v-cli-base-rate-ord as decimal   no-undo .
define variable v-unit-cli-ord      as character no-undo .
define variable v-cli-base-rate-rcv as decimal   no-undo .
define variable v-unit-cli-rcv      as character no-undo .

create gds-list-flt.
gds-list-flt.gds-code = 0 .
release gds-list-flt .

define temp-table temp-conn no-undo
  field ri       as recid
  field mark-seq as integer
  index pi is primary ri
  .

define temp-table tt_contract-specif like ub.contract-specif
  field bonus     as decimal
  field line-num  as integer
  field have-prod as logical
  index pi is primary unique
  artic
  prod-type
  prod-code
  .

define stream slog.
define stream stream-err.

&scop col-l0  '*'
&scop col-l1  'Код'
&scop col-l2  'Артикул'
&scop col-l3  'Произво-!дитель'
&scop col-l4  'Наименование'
&scop col-l5  'Цена!поставщика'
&scop col-l6  '% Отклон в!большую сторону'
&scop col-l7  '% Отклон в!меньшую сторону'
&scop col-l8  'Ед.!изм'
&scop col-l9  'Количество'
&scop col-l10  'Коэф.'
&scop col-l11 'Сумма'
&scop col-l12 'НДС'
&scop col-l13 'тип!НДС'
&scop col-l14 'Принято'
&scop col-l15 'Группа товара'
&scop col-l16  'Ед.!изм!пост'
&scop col-l17  'Ед.изм!пост в!заказе'
&scop col-l18  'Коэф.!в!заказе'
&scop col-l19  'Ед.изм!пост в!поставке'
&scop col-l20  'Коэф.!в!поставке'
&scop col-l21  '%!Бонус'
&scop col-l22 'Внешний!Артикул'

head-col =
  {&col-l0}     + '#' +
  {&col-l1}     + '#' +
  {&col-l2}     + '#' +
  {&col-l3}     + '#' +
  {&col-l4}     + '#' +
  {&col-l5}     + '#' +
  {&col-l6}     + '#' +
  {&col-l7}     + '#' +
  {&col-l8}     + '#' +
  {&col-l9}     + '#' +
  {&col-l10}    + '#' +
  {&col-l11}    + '#' +
  {&col-l12}    + '#' +
  {&col-l13}    + '#' +
  {&col-l14}    + '#' +
  {&col-l15}    + '#' +
  {&col-l16}    + '#' +
  {&col-l17}    + '#' +
  {&col-l18}    + '#' +
  {&col-l19}    + '#' +
  {&col-l20}    + '#' +
  {&col-l21}    + '#' +
  {&col-l22}
  .



&scop cop-l1  get-b-code(tt_contract-specif.gds-code)
&scop dyn_cop-l1 substitute('dynamic-function(&1get-b-code&1, &2)', ~{&double-quote~}, tt_contract-specif.gds-code)
&scop cop-l2  tt_contract-specif.artic
&scop cop-l3  string (tt_contract-specif.prod-type + ' ' + string(tt_contract-specif.prod-code))
&scop cop-l4  tt_contract-specif.gds-name
&scop cop-l5  tt_contract-specif.price-cli
&scop cop-l6  tt_contract-specif.prc
&scop cop-l7  f-prc-min(recid(tt_contract-specif))
&scop dyn_cop-l7 substitute('dynamic-function(&1f-prc-min&1, recid(tt_contract-specif))', ~{&double-quote~} )
&scop cop-l8  tt_contract-specif.unit-base
&scop cop-l9  tt_contract-specif.qnty
&scop cop-l10 tt_contract-specif.cli-base-rate
&scop cop-l11 tt_contract-specif.sum-cli
&scop cop-l12 tt_contract-specif.vat-pc
&scop cop-l13 tt_contract-specif.vat-type
&scop cop-l14 tt_contract-specif.income-qnty
&scop cop-l15  get-grp(tt_contract-specif.gds-code)
&scop dyn_cop-l15 substitute('dynamic-function(&1get-grp&1, &2)', ~{&double-quote~}, tt_contract-specif.gds-code)
&scop cop-l16  tt_contract-specif.unit-cli
&scop cop-l17  tt_contract-specif.unit-cli-ord
&scop cop-l18  tt_contract-specif.cli-base-rate-ord
&scop cop-l19  tt_contract-specif.unit-cli-rcv
&scop cop-l20  tt_contract-specif.cli-base-rate-rcv
&scop cop-l21  f-bonus(recid(tt_contract-specif))
&scop dyn_cop-l21 substitute('dynamic-function(&1f-bonus&1, &2)', ~{&double-quote~}, recid(tt_contract-specif))
&scop cop-l22  get-ext-artic(recid(tt_contract-specif))
&scop dyn_cop-l22 substitute('dynamic-function(&1get-ext-artic&1, recid(tt_contract-specif))', ~{&double-quote~} )

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME spec-List

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt_contract-specif 

/* Definitions for BROWSE spec-List                                     */
&Scoped-define FIELDS-IN-QUERY-spec-List {&cop-l0} {&cop-l1} @ p-bcode {&cop-l2} {&cop-l3} @ p-prod {&cop-l4} {&cop-l5} {&cop-l6} {&cop-l7} {&cop-l8} {&cop-l9} {&cop-l10} {&cop-l11} {&cop-l12} {&cop-l13} {&cop-l14} {&cop-l15} @ p-grp {&cop-l16} {&cop-l17} {&cop-l18} {&cop-l19} {&cop-l20} {&cop-l21} {&cop-l22}   
&Scoped-define ENABLED-FIELDS-IN-QUERY-spec-List {&cop-l2}   
&Scoped-define SELF-NAME spec-List
&Scoped-define QUERY-STRING-spec-List FOR EACH tt_contract-specif no-lock indexed-reposition
&Scoped-define OPEN-QUERY-spec-List OPEN QUERY {&SELF-NAME} FOR EACH tt_contract-specif NO-LOCK indexed-reposition.
&Scoped-define TABLES-IN-QUERY-spec-List tt_contract-specif
&Scoped-define FIRST-TABLE-IN-QUERY-spec-List tt_contract-specif


/* Definitions for DIALOG-BOX Dialog-Frame                              */

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit B-mark b-sel B-Help B-allmark ~
B-unmark RADIO-find sch-str spec-List mark-num 
&Scoped-Define DISPLAYED-OBJECTS RADIO-find sch-str mark-num 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD f-bonus Dialog-Frame 
FUNCTION f-bonus RETURNS DECIMAL
  ( input par-recid as recid )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD f-prc-min Dialog-Frame 
FUNCTION f-prc-min RETURNS DECIMAL
  ( input par-recid as recid )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-b-code Dialog-Frame 
FUNCTION get-b-code RETURNS CHARACTER
  ( input gds-code as integer )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-ext-artic Dialog-Frame 
FUNCTION get-ext-artic RETURNS CHARACTER
  ( input p-recid as recid )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-gds-name Dialog-Frame 
FUNCTION get-gds-name RETURNS CHARACTER
  ( input p-gds-code as integer )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-grp Dialog-Frame 
FUNCTION get-grp RETURNS CHARACTER
  ( input gds-code as integer )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD mark-string Dialog-Frame 
FUNCTION mark-string RETURNS CHARACTER
  ( input p-recid as recid, input mark-list as character  ) :

  RETURN ( IF LOOKUP( STRING( p-recid), mark-list ) > 0 THEN '*' ELSE '':U ).

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-allmark 
  LABEL "&+" 
  SIZE 3 BY 1 TOOLTIP "Отметить все".

DEFINE BUTTON B-Help 
  LABEL "Помо&щь" 
  SIZE 3 BY 1
  BGCOLOR 8 .

DEFINE BUTTON B-mark 
  LABEL "&*" 
  SIZE 3 BY 1.

DEFINE BUTTON b-quit AUTO-GO 
  LABEL "&Выход" 
  SIZE 10 BY 1
  BGCOLOR 8 .

DEFINE BUTTON b-sel AUTO-GO 
  LABEL "Вы&бор" 
  SIZE 10 BY 1
  BGCOLOR 8 .

DEFINE BUTTON B-unmark 
  LABEL "-" 
  SIZE 3 BY 1 TOOLTIP "Снять все *".

DEFINE VARIABLE mark-num   AS INTEGER   FORMAT ">>>>9":U INITIAL 0 
  VIEW-AS TEXT 
  SIZE 5.5 BY 1 NO-UNDO.

DEFINE VARIABLE sch-str    AS CHARACTER FORMAT "X(256)" 
  VIEW-AS FILL-IN 
  SIZE 44.38 BY 1 TOOLTIP "Поиск первой записи - <ВВОД>; поиск следующей - <CTRL-J>" NO-UNDO.

DEFINE VARIABLE RADIO-find AS INTEGER 
  VIEW-AS RADIO-SET HORIZONTAL
  RADIO-BUTTONS 
  "коду", 1,
  "артикулу", 2,
  "названию", 3
  /*  ,"началу слова", 4*/
  SIZE 44 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY spec-List FOR 
  tt_contract-specif SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE spec-List
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS spec-List Dialog-Frame _FREEFORM
  QUERY spec-List DISPLAY
  mark-string( input recid(tt_contract-specif), input v-rid-list) column-label "*" format "X(1)":U
  {&cop-l1} @ p-bcode  COLUMN-LABEL {&col-l1}  Format "X(16)"
     {&cop-l2}    COLUMN-LABEL {&col-l2}  Format "x(16)"
     {&cop-l3} @ p-prod  COLUMN-LABEL {&col-l3}  Format "x(18)"
     {&cop-l4}    COLUMN-LABEL {&col-l4}  format "x(50)"
     {&cop-l5}    COLUMN-LABEL {&col-l5}  format ">,>>>,>>>,>>9.99"
     {&cop-l6}    COLUMN-LABEL {&col-l6}  Format "->>>>9.99"
     {&cop-l7}    COLUMN-LABEL {&col-l7}  Format "->>>>9.99"
     {&cop-l8}    COLUMN-LABEL {&col-l8}
     {&cop-l9}    COLUMN-LABEL {&col-l9}
     {&cop-l10}    COLUMN-LABEL {&col-l0}
     {&cop-l11}   COLUMN-LABEL {&col-l11}
     {&cop-l12}   COLUMN-LABEL {&col-l12} Format ">>9.9"
     {&cop-l13}   COLUMN-LABEL {&col-l13}
     {&cop-l14}   COLUMN-LABEL {&col-l14}
     {&cop-l15} @ p-grp COLUMN-LABEL {&col-l15}  Format "x(100)"
     {&cop-l16}   COLUMN-LABEL {&col-l16}
     {&cop-l17}   COLUMN-LABEL {&col-l17}
     {&cop-l18}   COLUMN-LABEL {&col-l18}
     {&cop-l19}   COLUMN-LABEL {&col-l19}
     {&cop-l20}   COLUMN-LABEL {&col-l20}
     {&cop-l21}   COLUMN-LABEL {&col-l21} Format "->>9.99"
     {&cop-l22}   COLUMN-LABEL {&col-l22} Format "X(16)"

     enable {&cop-l2}
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 99 BY 17.25.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
  b-quit AT ROW 1 COL 1
  B-mark AT ROW 1 COL 11
  b-sel AT ROW 1 COL 20
  B-Help AT ROW 1 COL 97.88
  B-allmark AT ROW 2 COL 11
  B-unmark AT ROW 2 COL 14.13
  RADIO-find AT ROW 3.38 COL 12 NO-LABEL
  sch-str AT ROW 3.38 COL 54.5 COLON-ALIGNED NO-LABEL
  spec-List AT ROW 4.54 COL 1
  mark-num AT ROW 1 COL 12.5 COLON-ALIGNED NO-LABEL
  "Поиск по" VIEW-AS TEXT
  SIZE 9 BY 1 AT ROW 3.38 COL 1
  FGCOLOR 4 
  SPACE(91.37) SKIP(18.95)
  WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
  SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
  TITLE "Товарная спецификация к договору"
  DEFAULT-BUTTON b-quit CANCEL-BUTTON b-quit.


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
/* BROWSE-TAB spec-List sch-str Dialog-Frame */
ASSIGN 
  FRAME Dialog-Frame:SCROLLABLE = FALSE
  FRAME Dialog-Frame:HIDDEN     = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE spec-List
/* Query rebuild information for BROWSE spec-List
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH buf_contract-specif NO-LOCK
indexed-reposition.
     _END_FREEFORM
     _Query            is NOT OPENED
*/  /* BROWSE spec-List */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Товарная спецификация к договору */
  DO:
    APPLY "END-ERROR":U TO SELF.
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-allmark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-allmark Dialog-Frame
ON CHOOSE OF B-allmark IN FRAME Dialog-Frame /* + */
  DO:
    define variable loc#log as logical no-undo .

    if available tt_contract-specif then 
    do:
      v-rid-list = "" .
      for each tt_contract-specif no-lock:
        { gbl/markstrn.i tt_contract-specif v-rid-list }
        loc#log = {&browse-name}:refresh() .
      end.
    end.
    if num-entries( v-rid-list ) <> 0 then 
    do:
      display
        num-entries( v-rid-list ) @ mark-num
        with frame {&frame-name}.
    end.

  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mark Dialog-Frame
ON CHOOSE OF B-mark IN FRAME Dialog-Frame /* * */
  DO:
    define variable loc#log as logical no-undo .
      
    if available tt_contract-specif then 
    do:
      { gbl/markstrn.i tt_contract-specif v-rid-list }
      row_spec = rowid(tt_contract-specif).
      loc#log = {&browse-name}:refresh() .
      reposition spec-List to rowid row_spec.

      if last-event:function <> "MOUSE-SELECT-DBLCLICK" then 
      do:
        loc#log = {&browse-name}:select-next-row ().
        apply "VALUE-CHANGED" to {&browse-name} in frame {&frame-name}.
      end.
      if num-entries( v-rid-list ) = 0 then 
      do:
        hide mark-num in frame {&frame-name}.
      end.
      else 
      do:
        display
          num-entries( v-rid-list ) @ mark-num
          with frame {&frame-name}.
      end.
    end.
    apply "entry" to {&browse-name} in frame {&frame-name}.

  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-quit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-quit Dialog-Frame
ON CHOOSE OF b-quit IN FRAME Dialog-Frame /* Выход */
  DO:  /* отказ - выход  */

    /* Выдаем предупреждение, если есть отмеченные записи и доступна кнопка выбора */
    find first temp-conn no-error.
    if available temp-conn then 
    do:
      run gbl/markqwa.p ( input b-sel:sensitive, input string(temp-conn.ri)) no-error.
      if error-status:error then 
      do:
        apply "entry" to spec-List .
        return no-apply.
      end.
    end.

  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sel Dialog-Frame
ON CHOOSE OF b-sel IN FRAME Dialog-Frame /* Выбор */
  DO:
    define variable kk as integer no-undo .
    define buffer buf_goods for ub.goods .
    define variable ii as integer no-undo .
      
    empty temp-table gds-list .    
    if ( v-rid-list = "" ) and ( available tt_contract-specif ) then 
    do:
      find first buf_goods no-lock where buf_goods.gds-code = tt_contract-specif.gds-code no-error .
      if available (buf_goods) then 
      do:
        for first buf_contract-specif no-lock where buf_contract-specif.contract-num = tt_contract-specif.contract-num and buf_contract-specif.gds-code = tt_contract-specif.gds-code:
          find first ub.contract no-lock where ub.contract.contract-code = buf_contract-specif.contract-num and ub.contract.status_ = {&current-contr} no-error .
          create gds-list .
          buffer-copy buf_goods to gds-list .
          gds-list.contract = ub.contract.contract-prn-code .
          gds-list.contract-code = ub.contract.contract-code .
        end.

      end.
    end.
    else 
    do:
      if v-rid-list <> "" then 
      do:
        do kk = 1 to num-entries (v-rid-list):
          find first tt_contract-specif where recid (tt_contract-specif) = integer(entry (kk,v-rid-list,",")) no-error .
          if available (tt_contract-specif) then 
          do:
            find first buf_goods no-lock where buf_goods.gds-code = tt_contract-specif.gds-code no-error .
            if available (buf_goods) then 
            do:
                  find first ub.contract no-lock where ub.contract.contract-code = tt_contract-specif.contract-num no-error .
                  find first gds-list where gds-list.gds-code = buf_goods.gds-code and gds-list.contract = ub.contract.contract-prn-code no-error .
                  if not available (gds-list) then 
                  do:
                    create gds-list .
                    buffer-copy buf_goods to gds-list .
                    gds-list.contract = ub.contract.contract-prn-code .
                    gds-list.contract-code = ub.contract.contract-code .
                  end.
                end.
            end.
          end.
      end.
    end.
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-unmark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-unmark Dialog-Frame
ON CHOOSE OF B-unmark IN FRAME Dialog-Frame /* - */
  DO:
    define variable loc#log as logical no-undo .

    v-rid-list = "" .
    loc#log = {&browse-name}:refresh() .
    hide mark-num in frame {&frame-name}.
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME RADIO-find
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL RADIO-find Dialog-Frame
ON VALUE-CHANGED OF RADIO-find IN FRAME Dialog-Frame
  DO:
    assign RADIO-find .
    if sch-str <> "" then 
    do:
      run proc-find-code in this-procedure ( input no, input sch-str) no-error.
      if error-status:error then return no-apply.
    end.
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME sch-str
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-str Dialog-Frame
ON CTRL-J OF sch-str IN FRAME Dialog-Frame
  DO:
    assign sch-str .
    assign RADIO-find .
    run proc-find-code in this-procedure ( input yes, input sch-str) no-error.
    if error-status:error then return no-apply.
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-str Dialog-Frame
ON RETURN OF sch-str IN FRAME Dialog-Frame
  DO:
    assign sch-str .
    assign RADIO-find .
    run proc-find-code in this-procedure ( input no, input sch-str) no-error.
    if error-status:error then return no-apply.
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME spec-List
&Scoped-define SELF-NAME spec-List
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL spec-List Dialog-Frame
ON RETURN OF spec-List IN FRAME Dialog-Frame
  or MOUSE-SELECT-DBLCLICK OF spec-List IN FRAME Dialog-Frame
  DO:
    if b-mark:sensitive then apply "choose" to b-mark in frame {&frame-name}.
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame 


/* ***************************  Main Block  *************************** */

{ gbl/app_help.i }
{ gbl/getcntxt.i get }
{ gbl/brwrefre.i "run OpenBr  in this-procedure ( input yes, input no, input '':U)." }

on F9 of frame {&frame-name} anywhere 
  do:
    if not available buf_contract-specif then  return no-apply.
    find first ub.goods no-lock where ub.goods.gds-code = buf_contract-specif.gds-code .
    gds-rec = recid (ub.goods) .
    run ref/gds-form.w
      (input  parParentProc
      ,input  {&lookup}
      ,input  v-cntxt-obj-type
      ,input  v-cntxt-obj-code
      ,input ? /*p-call-handle*/
      ,input-output gds-rec
      ).

    apply "entry" to spec-List in frame {&frame-name}.
    return no-apply.
  end.

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */

IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
  THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

{ gbl/brwrepos.i  &line-num=16 }

/*{ gbl/f2.i spec-List goods-recid init-gds-rec parParentProc }*/


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
  ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

  assign
    spec-List:num-locked-columns            = 1
    {&cop-l2}:read-only in browse spec-List = yes
    .

  find first ub.clients no-lock where
    ub.clients.obj-type = {&cmp}
    and ub.clients.obj-code = p-host-code .
  assign 
    frame {&frame-name}:title = substitute(" Фирма: (&1) &2 Товарная спецификация к договорам"
                                                  ,p-host-code
                                                  ,ub.clients.obj-name).

  /*
    Подключили возможность изменять спецификации в УБД
    if v-cntxt-db-num > 0 then assign ref-mode = {&lookup} .
  */
  run init-browse-p  in this-procedure  no-error .
  run myenable in this-procedure no-error .
  if error-status:error then  return .
  {&OPEN-QUERY-spec-List}

  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
run disable_ui in this-procedure .

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
  DISPLAY RADIO-find sch-str mark-num 
    WITH FRAME Dialog-Frame.
  ENABLE b-quit B-mark b-sel B-Help B-allmark B-unmark RADIO-find sch-str 
    spec-List mark-num 
    WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-browse-p Dialog-Frame 
PROCEDURE init-browse-p :
  define buffer buf_contract-specif for ub.contract-specif .
  define buffer buf_trn-doc         for ub.trn-doc .
  define buffer buf_clients         for ub.clients .
  define buffer buf_doc-line        for ub.doc-line .
  define buffer buf_goods           for ub.goods .  
  define variable ii as integer no-undo .
  
  empty temp-table tt_contract-specif .
  if p-doc-num <> "" then 
  do:
    do ii = 1 to num-entries (p-doc-num):
      for each ub.contract-specif no-lock where ub.contract-specif.contract-num = integer(entry(ii,p-doc-num,",")):
        find first tt_contract-specif where tt_contract-specif.gds-code = ub.contract-specif.gds-code no-error .
        if not available (tt_contract-specif) then 
        do:
          create tt_contract-specif .
          buffer-copy ub.contract-specif to tt_contract-specif .
        end.
        else tt_contract-specif.qnty = tt_contract-specif.qnty + ub.contract-specif.qnty .
      end.
    end.
  end.
  else 
  do:
    find first buf_clients no-lock where recid(buf_clients) = recid_client no-error .
    if available (buf_clients) then 
    do:
      for each buf_trn-doc no-lock where buf_trn-doc.obj-code = v-cntxt-obj-code and
        buf_trn-doc.obj-type = v-cntxt-obj-type and
        buf_trn-doc.cli-code = buf_clients.obj-code and
        buf_trn-doc.cli-type = buf_clients.obj-type and
        buf_trn-doc.ext-doc-type = {&tdedt_pri_vnesh} and
        buf_trn-doc.status_ = {&fact}:
        for each buf_doc-line no-lock where buf_doc-line.doc-code = buf_trn-doc.doc-code and
          buf_doc-line.obj-code = buf_trn-doc.obj-code and
          buf_doc-line.obj-type = buf_trn-doc.obj-type,
          first buf_goods no-lock where buf_goods.artic = buf_doc-line.artic and
          buf_goods.prod-code = buf_doc-line.prod-code and
          buf_goods.prod-type = buf_doc-line.prod-type:
          find first tt_contract-specif where tt_contract-specif.gds-code = buf_goods.gds-code no-error .
          if not available (tt_contract-specif) then 
          do:
            create tt_contract-specif .
            assign
              tt_contract-specif.gds-code  = buf_goods.gds-code
              tt_contract-specif.artic     = buf_goods.artic
              tt_contract-specif.prod-code = buf_goods.prod-code
              tt_contract-specif.prod-type = buf_goods.prod-type
              tt_contract-specif.gds-name  = buf_goods.gds-name
              tt_contract-specif.unit-base = buf_goods.unit-base
              .            
          end.
        end.
      end.
    end.    
  end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame 
PROCEDURE MyEnable :
  /*------------------------------------------------------------------------------
      Purpose:
      Parameters:  <none>
      Notes:
    ------------------------------------------------------------------------------*/
  DISPLAY
    sch-str
    RADIO-find
    mark-num
    WITH FRAME {&frame-name} .
  ENABLE
    b-quit
    B-mark     
    when (lookup("B-mark":U, bttns) > 0)
    B-unmark   
    when (lookup("B-mark":U, bttns) > 0)
    B-allmark  
    when (lookup("B-mark":U, bttns) > 0)
    b-sel      
    when (lookup("b-sel":U, bttns) > 0)
    B-Help
    sch-str
    RADIO-find
    spec-List
    mark-num
    WITH FRAME {&frame-name} .
  VIEW FRAME {&frame-name} .
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OpenBr Dialog-Frame 
PROCEDURE OpenBr :
  /*------------------------------------------------------------------------------
      Purpose:
      Parameters:  <none>
      Notes:
    ------------------------------------------------------------------------------*/
  define input  parameter p-open-query     as logical   no-undo .
  define input  parameter p-find-next      as logical   no-undo .
  define input  parameter p-find-condition as character no-undo .

  define variable l-query-was-opened as logical no-undo .
  {&SetCursorWait}

  define variable sort-column-phrase as character no-undo .

  case sort-column-name :
    when "" then 
      assign  
        sort-column-phrase = ""  .
    otherwise    
    assign  
      sort-column-phrase = "by " + sort-column-name .
  end case.

  /* определяем здесь общие параметры для процедуры открытия query fltopend.i */
  &scop flt-open-open-query           OPEN QUERY spec-List FOR EACH tt_contract-specif NO-LOCK
  &scop flt-open-dyn_open-query       FOR EACH tt_contract-specif
  &scop flt-open-query-handle         query spec-List:handle

  &scop flt-open-waitfram            true
  &scop flt-open-query-was-opened    l-query-was-opened
  &scop flt-open-sort-column-phrase  sort-column-phrase
  &scop flt-open-call-point          filter-point
  &scop flt-open-query               p-open-query
  &scop flt-open-table-name          tt_contract-specif
  &scop flt-open-search-option       no-lock
  &scop flt-open-find-next           p-find-next
  &scop flt-open-find-recid          v-doc-rec
  &scop flt-open-find-condition      p-find-condition
  &scop flt-open-find-buffer-name    tt_contract-specif
  &scop flt-open-debug-file

  define variable l-open-query as logical no-undo .

  filter-point = filter-point0 .

  IF AVAILABLE tt_contract-specif THEN 
  DO:
    ASSIGN
      v-doc-rec = recid (tt_contract-specif) .
  END.

  { gbl/fltopend.i
      &where-cond = " tt_contract-specif.host-code = p-host-code "
      &DYN_where-cond = " substitute(' tt_contract-specif.host-code = &1 ', p-host-code ) "
      &use-ind = "  "
      &by = " "
    }

  IF v-doc-rec <> ? THEN 
  DO:
    /* Позиционируем куда надо !!! */
    REPOSITION spec-List to RECID v-doc-rec NO-ERROR.
  END.
  /* */
  APPLY
    "entry" to spec-List in frame {&frame-name}.
/*  */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-add-ass Dialog-Frame 
PROCEDURE proc-add-ass :
  /* -----------------------------------------------------------
      Purpose:
      Parameters:  <none>
      Notes:
    -------------------------------------------------------------*/
  define buffer bb_contract-specif for ub.contract-specif  .
  define variable v-ass-m    as logical   no-undo init false .
  define variable v-log      as logical   no-undo .
  define variable p-rid-list as character no-undo .


  if not can-find( first temp-conn) then 
  do:
    message "Не выделено ни одного товара !" view-as alert-box .
    return .
  end.

  if v-cntxt-db-num <> 0 then 
  do :
    if can-find ( first ub.assortment-matrix no-lock where  ub.assortment-matrix.asmt-status = integer ({&current-status-int}) and
      ub.assortment-matrix.db-num = v-cntxt-db-num )  then v-ass-m = true  .
  end.
  else 
  do:
    if can-find ( first ub.assortment-matrix no-lock where  ub.assortment-matrix.asmt-status = integer ({&current-status-int}))  then v-ass-m = true  .
  end.

  if v-ass-m = false  then return .

  /* Проверка прав */
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_assort-matr-gds_add-def':U
    {&cntxt-global}
    0
    '':U
    0
    0
    0
    0
    true
    v-log
  }
  if not v-log then return  .


  message "Добавить выбранные товары спецификации в Ассортиментные матрицы ?"
    "Если ДА , укажите в какие."
    view-as alert-box question
    buttons yes-no
    update v-okk as logical
    .
  if not v-okk then return .
  run ref/assmatr.w (
    input parParentProc
    ,input "b-sel,b-mark"
    ,input v-cntxt-obj-type
    ,input v-cntxt-obj-code
    ,input ?
    ,input ?
    ,input-output p-rid-list
    ) no-error  .
  if error-status :error then message
      vss-workfile vss-revision vss-description skip
      error-status :get-message(1) skip
      return-value skip
      ""
      view-as alert-box error
      .

  run waitfram-show in this-procedure ( input "Добавление в Ассортиментные матрицы")  .
  /*  v-err-ext = false  .*/
  /*  v-longchar = "" .   */
  for each temp-conn,
    first bb_contract-specif no-lock  where
    recid(bb_contract-specif) = temp-conn.ri :
    run add-assmatr in this-procedure ( input bb_contract-specif.gds-code
      ,input p-rid-list) .
  end.
  run waitfram-hide in this-procedure .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-export-excel Dialog-Frame 
PROCEDURE proc-export-excel :
  run str/diallog.w (
    input parParentProc
    , input this-procedure
    , input ("utl/thbjrumr.w":U + {&delim-par}
    + {&delim-par}   /*error-message-option*/
    + string(2)       + {&delim-par}   /*auto-go-option*/
    )
    , input ({&edoc} + {&delim-par} +
    /*parameter - второй элемент списка - это radio-buttons rs-ruleset d thbjrumr*/
    {&edoc-proc_excel-export_specif} + {&delim-par} +
    string(buf_contract.contract-code)
    )     /*parameter - второй элемент списка - это radio-buttons rs-ruleset d thbjrumr*/
    , input no /*p-auto-go*/
    , input ""
    , input substitute("Экспорт спецификации в EXCEL") ) no-error .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-export-text Dialog-Frame 
PROCEDURE proc-export-text :
  run str/diallog.w (
    input parParentProc
    , input this-procedure
    , input ("utl/thbjrumr.w":U + {&delim-par}
    + {&delim-par}   /*error-message-option*/
    + string(2)       + {&delim-par}   /*auto-go-option*/
    )
    , input ({&edoc} + {&delim-par} +
    /*parameter - второй элемент списка - это radio-buttons rs-ruleset d thbjrumr*/
    {&edoc-proc_text-export_specif} + {&delim-par} +
    string(buf_contract.contract-code)
    )     /*parameter - второй элемент списка - это radio-buttons rs-ruleset d thbjrumr*/
    , input no /*p-auto-go*/
    , input "&Стоп"
    , input substitute("Экспорт спецификации в текстовый файл") ) no-error .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-find-code Dialog-Frame 
PROCEDURE proc-find-code :
  /*------------------------------------------------------------------------------
      Purpose:
      Parameters:  <none>
      Notes:
    ------------------------------------------------------------------------------*/
  define input parameter p-next as logical no-undo.
  define input parameter p-code as character no-undo .
  
  define buffer buf_contract-specif for tt_contract-specif .
  define variable row_spec as rowid   no-undo .
  define variable loc#log  as logical no-undo .
  assign 
    p-code = replace(p-code, {&single-quote}, {&single-quote} + {&single-quote}) .
  case RADIO-find :
    when 1 then 
      do:
        find first buf_contract-specif no-lock where string(buf_contract-specif.gds-code) begins p-code no-error .  
        if not available (buf_contract-specif) then message "Не найден код начинающийся с " + p-code
            view-as alert-box.
        if available buf_contract-specif then 
        do:
          row_spec = rowid(buf_contract-specif).
          loc#log = {&browse-name}:select-next-row () in frame {&frame-name}.
          reposition {&browse-name} to rowid row_spec.
        end.
        apply "entry" to {&browse-name} in frame {&frame-name}.
      end.
    when 2 then 
      do:
        find first buf_contract-specif no-lock where string(buf_contract-specif.artic) begins p-code no-error .  
        if not available (buf_contract-specif) then message "Не найден артикул начинающийся с " + p-code
            view-as alert-box.
        if available buf_contract-specif then 
        do:
          row_spec = rowid(buf_contract-specif).
          loc#log = {&browse-name}:select-next-row () in frame {&frame-name}.
          reposition {&browse-name} to rowid row_spec.
        end.
        apply "entry" to {&browse-name} in frame {&frame-name}.
      end.
    when 3 then 
      do:
        find first buf_contract-specif no-lock where string(buf_contract-specif.gds-name) begins p-code no-error .  
        if not available (buf_contract-specif) then message "Не найден товар начинающийся с " + p-code
            view-as alert-box.
        if available buf_contract-specif then 
        do:
          row_spec = rowid(buf_contract-specif).
          loc#log = {&browse-name}:select-next-row () in frame {&frame-name}.
          reposition {&browse-name} to rowid row_spec.
        end.
        apply "entry" to {&browse-name} in frame {&frame-name}.
      end.
    when 4 then 
      do:
      end.
  end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-import-excel Dialog-Frame 
PROCEDURE proc-import-excel :
  /*------------------------------------------------------------------------------
      Purpose:
      Parameters:  <none>
      Notes:
    ------------------------------------------------------------------------------*/
  { gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_fin-contract_modernization':U
  {&cntxt-firm}
  p-host-code
  '':U
  0
  0
  0
  0
  true
  g-log
}
  if not g-log then  return .
  run str/diallog.w (
    input parParentProc
    , input this-procedure
    , input ("utl/thbjrumr.w":U + {&delim-par}
    + {&delim-par}   /*error-message-option*/
    + string(2)       + {&delim-par}   /*auto-go-option*/
    )
    , input ({&edoc} + {&delim-par} +
    /*parameter - второй элемент списка - это radio-buttons rs-ruleset d thbjrumr*/
    {&edoc-proc_excel-import_specif} + {&delim-par} +
    string(buf_contract.contract-code)
    )     /*parameter - второй элемент списка - это radio-buttons rs-ruleset d thbjrumr*/
    , input no /*p-auto-go*/
    , input "&Стоп"
    , input substitute("Импорт спецификации из EXCEL") ) no-error .
  run proc-sum in this-procedure .
  run openbr in this-procedure ( input yes, input no, input '':u).
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-import-text Dialog-Frame 
PROCEDURE proc-import-text :
  { gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_fin-contract_modernization':U
  {&cntxt-firm}
  p-host-code
  '':U
  0
  0
  0
  0
  true
  g-log
}
  if not g-log then  return .
  run str/diallog.w (
    input parParentProc
    , input this-procedure
    , input ("utl/thbjrumr.w":U + {&delim-par}
    + {&delim-par}   /*error-message-option*/
    + string(2)       + {&delim-par}   /*auto-go-option*/
    )
    , input ({&edoc} + {&delim-par} +
    /*parameter - второй элемент списка - это radio-buttons rs-ruleset d thbjrumr*/
    {&edoc-proc_text-import_specif} + {&delim-par} +
    string(buf_contract.contract-code)
    )     /*parameter - второй элемент списка - это radio-buttons rs-ruleset d thbjrumr*/
    , input no /*p-auto-go*/
    , input "&Стоп"
    , input substitute("Импорт спецификации из текстового файла") ) no-error .
  run proc-sum in this-procedure .
  run openbr in this-procedure ( input yes, input no, input '':u).
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION f-bonus Dialog-Frame 
FUNCTION f-bonus RETURNS DECIMAL
  ( input par-recid as recid ) :
  define buffer buf_contract-specif for ub.contract-specif  .
  define variable v-bonus as decimal no-undo .
  find first buf_contract-specif no-lock where
    recid(buf_contract-specif) = par-recid no-error .
  if error-status :error then return 0.0 .
  v-bonus = 0.0 .
  run read-bonus in this-procedure
    ( buf_contract-specif.contract-num,
    buf_contract-specif.host-code ,
    buf_contract-specif.gds-code ,
    output v-bonus
    ) no-error .
  return v-bonus .   /* Function return value. */
END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION f-prc-min Dialog-Frame 
FUNCTION f-prc-min RETURNS DECIMAL
  ( input par-recid as recid ) :
  define buffer buf_contract-specif for ub.contract-specif  .
  define variable v-prc-min as decimal no-undo .
  find first buf_contract-specif no-lock where
    recid(buf_contract-specif) = par-recid no-error .
  if error-status :error then return 0.0 .
  v-prc-min = 0.0 .
  run read-prc-min in this-procedure
    ( buf_contract-specif.contract-num,
    buf_contract-specif.host-code ,
    buf_contract-specif.gds-code ,
    output v-prc-min
    ) no-error .
  return v-prc-min .   /* Function return value. */
END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-b-code Dialog-Frame 
FUNCTION get-b-code RETURNS CHARACTER
  ( input gds-code as integer ) :
  /*------------------------------------------------------------------------------
    Purpose:
      Notes:
  ------------------------------------------------------------------------------*/
  define variable ret    as character no-undo .
  define variable b-code as integer   no-undo .

  assign 
    ret = "" .

  { gbl/gdsbcode.i  gds-code  ?  b-code  no-error }
  if error-status :error then 
  do:
  end.
  else assign ret = string(b-code) .

  RETURN ret .
END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-ext-artic Dialog-Frame 
FUNCTION get-ext-artic RETURNS CHARACTER
  ( input p-recid as recid ) :
  /*------------------------------------------------------------------------------
    Purpose:
      Notes:
  ------------------------------------------------------------------------------*/
  define variable ret as character no-undo .
  define buffer bf_contract-specif for ub.contract-specif  .
  define buffer bf_contract        for ub.contract  .
  define buffer bf_ext-artic       for ub.ext-artic  .

  define buffer bf_goods           for ub.goods  .

  assign 
    ret = "" .
  find first tt_contract-specif no-lock  where recid(tt_contract-specif)  =  p-recid no-error .
  if error-status :error then 
  do:
    message
      vss-workfile vss-revision vss-description skip
      error-status :get-message(1) skip
      return-value skip
      ""
      view-as alert-box error
      .
  end.

  find first bf_ext-artic where bf_ext-artic.gds-code   = tt_contract-specif.gds-code
    and bf_ext-artic.status_    <> {&deleted-status}
    no-error .
  if error-status :error then 
  do:
    ret = ''  .
  end.
  else 
  do:
    assign
      ret = string(bf_ext-artic.gds-code)
      .
    if ret = ? then ret = "".
  end.

  RETURN ret .
END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-gds-name Dialog-Frame 
FUNCTION get-gds-name RETURNS CHARACTER
  ( input p-gds-code as integer ) :
  /*------------------------------------------------------------------------------
    Purpose:
      Notes:
  ------------------------------------------------------------------------------*/
  define variable ret as character no-undo .
  define buffer bf_goods for ub.goods  .

  assign 
    ret = "" .
  find first bf_goods no-lock where
    bf_goods.gds-code = p-gds-code no-error  .
  if error-status :error then 
  do:
  end.
  else assign ret = bf_goods.gds-name  .

  RETURN ret .
END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-grp Dialog-Frame 
FUNCTION get-grp RETURNS CHARACTER
  ( input gds-code as integer ) :
  /*------------------------------------------------------------------------------
    Purpose:
      Notes:
  ------------------------------------------------------------------------------*/
  define buffer buf_goods for ub.goods.
  find first buf_goods no-lock where buf_goods.gds-code = gds-code .
  RETURN buf_goods.grp-name .
END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME



