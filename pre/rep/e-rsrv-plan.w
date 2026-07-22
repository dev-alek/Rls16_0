DEFINE INPUT PARAMETER  parParentProc  AS WIDGET-HANDLE NO-UNDO.
define input parameter p-ok as logical no-undo .
define variable fl              as character no-undo .
define variable post-grp_recids as character no-undo .
define variable v-cli-type      as character no-undo .
define variable v-cli-code      as integer   no-undo .
define variable v-cli-name      as character no-undo .
define variable list-dogovor    as character no-undo .
define variable v-rid-list      as character no-undo .
define variable v-dog-edi       as character no-undo .
define variable vOk             as logical   no-undo .
define variable glog            as logical   no-undo .
define variable listDogovor as character no-undo .
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure sel-date :
  define input  parameter p-date-handle as handle    no-undo .
  define input  parameter p-description as character no-undo .
  do
  on error undo, return error return-value
  :
    if (can-query (p-date-handle, "sensitive")
      and
      p-date-handle :sensitive = true
      )
    or (can-query (p-date-handle, "read-only")
      and
      p-date-handle :read-only = false
      )
    then do:
      if p-date-handle :handle <> focus :handle
      then do:
        apply "entry":u to p-date-handle .
      end.
      define variable v-ok            as logical no-undo .
      define variable v-curr-sv-date as date no-undo .
      assign
        v-curr-sv-date = date(p-date-handle :screen-value) no-error
      .
      if v-curr-sv-date = ?
      then do:
        run gbl/getcurdt.p
          (output v-curr-sv-date
          ) .
      end.
      if v-curr-sv-date <> ?
      then do:
        run gbl/d-inpday.w
          (input ?
          ,input "Выбор даты"
          ,input p-description
          ,input ""
          ,input-output v-curr-sv-date
          ,output v-ok
          ).
        if v-ok = true
        then do:
          assign
            p-date-handle :screen-value = string(v-curr-sv-date) .
          .
        end.
      end.
    end.
  end.
end procedure.
procedure check-contract-code :
  define input  parameter parmode           as   character                     no-undo.
  define input  parameter parhost-code      like ub.trn-doc.host-code          no-undo.
  define input  parameter parcli-type       like ub.trn-doc.cli-type           no-undo.
  define input  parameter parcli-code       like ub.trn-doc.cli-code           no-undo.
  define input  parameter parframe-value    as   character                     no-undo.
  define input  parameter parmenu-handle    as   handle                        no-undo.
  define input  parameter parobj-date       as   date                          no-undo.
  define input  parameter partype-contract  as   character                     no-undo .
  define output parameter parcontract-code  as   character                     no-undo.
  define buffer bf_contract     for ub.contract.
  define buffer bf-oth_contract for ub.contract.
  define variable varrid-list      as character no-undo.
  define variable varrecid         as recid     no-undo.
  define variable varlog           as logical   no-undo.
  define variable var-args         as char      no-undo.
  define variable var-ext-doc-type as char      no-undo.
  define variable jj               as integer   no-undo .
  do on error undo, return error return-value :
    var-args = parmode.
    parmode = entry(1, parmode).
    run cntrcode-get-arg-val(var-args, "doc-type", output var-ext-doc-type).
    if partype-contract = "" or partype-contract = ? then
      partype-contract = 'при':U .
    assign
      parcontract-code = ""
      .
    if parmode = "input":u
      then
    do:
      if parframe-value = ""
        then
      do:
        assign
          parcontract-code = ""
          .
      end.
      else
      do:
        find first bf_contract no-lock
          where bf_contract.host-code         = parhost-code
          and bf_contract.cli-type          = parcli-type
          and bf_contract.cli-code          = parcli-code
          and bf_contract.contract-prn-code = parframe-value
          no-error.
        if available bf_contract
          then
        do:
          find first bf-oth_contract no-lock
            where bf-oth_contract.host-code          = parhost-code
            and bf-oth_contract.contract-prn-code  = parframe-value
            and bf-oth_contract.cli-type           = parcli-type
            and bf-oth_contract.cli-code           = parcli-code
            and rowid(bf_contract)                 <> rowid(bf-oth_contract)
            no-error .
          if available bf-oth_contract
            then
          do:
            message
              "На фирме " parhost-code skip
              "у контрагента" parcli-type parcli-code skip
              "имеются два контракта с номером" parframe-value skip
              view-as alert-box .
          end.
          else
          do:
            assign
              parcontract-code = string(bf_contract.contract-code)
              .
          end.
        end.
      end.
    end.
    if parmode <> "input":u
      or parcontract-code = ""
      then
    do:
      run str/cont-all.w (input parmenu-handle,
        input parhost-code,
        input "b-sel,b-mark",
        input "firm-curr" ,
        input parcli-type,
        input parcli-code,
        input ?,
        input ?,
        input "current":u,
        input partype-contract,
        input-output varrid-list ) no-error.
      if error-status:error then
      do:
        message "Ошибка при вызове справочника договоров." skip
          return-value                skip
          error-status:get-message(1) skip
          error-status:get-message(2)
          view-as alert-box error.
        return error.
      end.
      do jj = 1 to num-entries (varrid-list):
        assign
          varrecid = integer(entry(jj, varrid-list)).
        find first bf_contract where recid(bf_contract) = varrecid no-lock no-error.
        if available bf_contract then
        do:
          assign
            parcontract-code = parcontract-code + "," + string(bf_contract.contract-code).
        end.
      end.
    end.
  end.
end procedure.
procedure check-contract-code-attr :
  define input  parameter parmode           as   character                     no-undo.
  define input  parameter parhost-code      like ub.trn-doc.host-code          no-undo.
  define input  parameter parcli-type       like ub.trn-doc.cli-type           no-undo.
  define input  parameter parcli-code       like ub.trn-doc.cli-code           no-undo.
  define input  parameter parframe-value    as   character                     no-undo.
  define input  parameter parmenu-handle    as   handle                        no-undo.
  define input  parameter parobj-date       as   date                          no-undo.
  define input  parameter partype-contract  as   character                     no-undo .
  define input  parameter parattr-code      as   character                     no-undo .
  define output parameter parcontract-code  as   character                     no-undo.
  define buffer bf_contract     for ub.contract.
  define buffer bf-oth_contract for ub.contract.
  define variable varrid-list      as character no-undo.
  define variable varrecid         as recid     no-undo.
  define variable varlog           as logical   no-undo.
  define variable var-args         as char      no-undo.
  define variable var-ext-doc-type as char      no-undo.
  define variable jj               as integer   no-undo .
  do on error undo, return error return-value :
    var-args = parmode.
    parmode = entry(1, parmode).
    run cntrcode-get-arg-val(var-args, "doc-type", output var-ext-doc-type).
    if partype-contract = "" or partype-contract = ? then
      partype-contract = 'при':U .
    assign
      parcontract-code = ""
      .
    if parmode = "input":u
      then
    do:
      if parframe-value = ""
        then
      do:
        assign
          parcontract-code = ""
          .
      end.
      else
      do:
        find first bf_contract no-lock
          where bf_contract.host-code         = parhost-code
          and bf_contract.cli-type          = parcli-type
          and bf_contract.cli-code          = parcli-code
          and bf_contract.contract-prn-code = parframe-value
          no-error.
        if available bf_contract
          then
        do:
          find first bf-oth_contract no-lock
            where bf-oth_contract.host-code          = parhost-code
            and bf-oth_contract.contract-prn-code  = parframe-value
            and bf-oth_contract.cli-type           = parcli-type
            and bf-oth_contract.cli-code           = parcli-code
            and rowid(bf_contract)                 <> rowid(bf-oth_contract)
            no-error .
          if available bf-oth_contract
            then
          do:
            message
              "На фирме " parhost-code skip
              "у контрагента" parcli-type parcli-code skip
              "имеются два контракта с номером" parframe-value skip
              view-as alert-box .
          end.
          else
          do:
            assign
              parcontract-code = string(bf_contract.contract-code)
              .
          end.
        end.
      end.
    end.
    if parmode <> "input":u
      or parcontract-code = ""
      then
    do:
      run str/cont-all-attr.w (input parmenu-handle,
        input parhost-code,
        input "b-sel,b-mark",
        input "firm-curr" ,
        input parcli-type,
        input parcli-code,
        input ?,
        input ?,
        input "current":u,
        input partype-contract,
        input parattr-code,
        input-output varrid-list ) no-error.
      if error-status:error then
      do:
        message "Ошибка при вызове справочника договоров." skip
          return-value                skip
          error-status:get-message(1) skip
          error-status:get-message(2)
          view-as alert-box error.
        return error.
      end.
      do jj = 1 to num-entries (varrid-list):
        assign
          varrecid = integer(entry(jj, varrid-list)).
        find first bf_contract where recid(bf_contract) = varrecid no-lock no-error.
        if available bf_contract then
        do:
          assign
            parcontract-code = parcontract-code + "," + string(bf_contract.contract-code).
        end.
      end.
    end.
  end.
end procedure.
procedure cntrcode-get-arg-val:
  def input param p-args as char no-undo.
  def input param p-key as char no-undo.
  def output param p-val as char no-undo.
  def var i       as int  no-undo.
  def var nums    as int  no-undo.
  def var key-val as char no-undo.
  nums = num-entries(p-args).
  do i = 1 to nums:
    key-val = entry(i, p-args).
    if key-val begins (p-key + "=") then
    do:
      p-val = entry(2, key-val, "=").
      return.
    end.
  end.
  p-val = "".
end.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run mainmenu_getcntxt in parparentproc
    (output v-cntxt-db-num
    ,output v-cntxt-userid
    ,output v-cntxt-level
    ,output v-cntxt-host-code-obj
    ,output v-cntxt-obj-type
    ,output v-cntxt-obj-code
    ,output v-cntxt-db-num-obj
    ,output v-cntxt-is-admin
    ) .
define temp-table  tt-dateZakaz     no-undo
field id as integer
field dateStart as date
field dateEnd as date
index pi id
    .
DEFINE TEMP-TABLE tt-typeDocChoose NO-UNDO
  field type-code as character
  field typeName  as character.
define temp-table gds-list like ub.goods
  field minZapas as decimal
  field contract as character
  field contract-code as integer
  field price as decimal
  field doc-qnty as decimal
  index pi contract gds-code.
 define temp-table choose-gds-list like ub.goods
  field minZapas as decimal
  field contract as character
  field contract-code as integer
  field price as decimal
  field doc-qnty as decimal
  index pi contract gds-code.
  define temp-table tt-gds-list like ub.goods
  field contract-code as integer
  field price as decimal
  field doc-qnty as decimal
  index pi gds-code.
FUNCTION customerName RETURNS CHARACTER
    ( p-dogovor as character)  FORWARD.
DEFINE BUTTON b-chooseContract
    IMAGE-UP FILE "btn-down-arrow":U
    IMAGE-DOWN FILE "btn-down-arrow":U
    IMAGE-INSENSITIVE FILE "btn-down-arrow":U
    LABEL ""
    SIZE 3 BY .88 TOOLTIP "Выбрать договоры".
DEFINE BUTTON b-chooseGoods
    IMAGE-UP FILE "btn-down-arrow":U
    IMAGE-DOWN FILE "btn-down-arrow":U
    IMAGE-INSENSITIVE FILE "btn-down-arrow":U
    LABEL ""
    SIZE 3 BY .88 TOOLTIP "Выбрать товары".
DEFINE BUTTON b-clients
    IMAGE-UP FILE "btn-down-arrow":U
    IMAGE-DOWN FILE "btn-down-arrow":U
    IMAGE-INSENSITIVE FILE "btn-down-arrow":U
    LABEL ""
    SIZE 3 BY .88 TOOLTIP "Выбрать контрагента".
DEFINE BUTTON b-contract
    IMAGE-UP FILE "btn-down-arrow":U
    IMAGE-DOWN FILE "btn-down-arrow":U
    IMAGE-INSENSITIVE FILE "btn-down-arrow":U
    LABEL ""
    SIZE 3 BY .88 TOOLTIP "Выбрать договоры".
DEFINE BUTTON b-date
    IMAGE-UP FILE "btn-down-arrow":U
    IMAGE-DOWN FILE "btn-down-arrow":U
    IMAGE-INSENSITIVE FILE "btn-down-arrow":U
    LABEL ""
    SIZE 3 BY .88.
DEFINE BUTTON b-date-Start
    IMAGE-UP FILE "btn-down-arrow":U
    IMAGE-DOWN FILE "btn-down-arrow":U
    IMAGE-INSENSITIVE FILE "btn-down-arrow":U
    LABEL ""
    SIZE 3 BY .88.
DEFINE BUTTON b-date-End
    IMAGE-UP FILE "btn-down-arrow":U
    IMAGE-DOWN FILE "btn-down-arrow":U
    IMAGE-INSENSITIVE FILE "btn-down-arrow":U
    LABEL ""
    SIZE 3 BY .88.
DEFINE BUTTON b-exit AUTO-END-KEY
    LABEL "&Выход"
    SIZE 10 BY 1
    BGCOLOR 8 .
DEFINE BUTTON b-type-doc
    IMAGE-UP FILE "btn-down-arrow":U
    IMAGE-DOWN FILE "btn-down-arrow":U
    IMAGE-INSENSITIVE FILE "btn-down-arrow":U
    LABEL "Типы документов"
    SIZE 3 BY .88 TOOLTIP "Типы документов"
    FONT 1.
DEFINE BUTTON bt-not-sel-all
    LABEL "+"
    SIZE 3 BY 1 TOOLTIP "Выбрать все".
DEFINE BUTTON bt-not-sel-desel-all
    LABEL "-"
    SIZE 3 BY 1 TOOLTIP "Отменить выбор".
DEFINE BUTTON Btn_OK AUTO-GO
    LABEL "_ В&ыполнить"
    SIZE 12 BY 1
    BGCOLOR 8 .
DEFINE BUTTON BUTTON-1
    IMAGE-UP FILE "adeicon\ts-up":U
    IMAGE-DOWN FILE "adeicon\ts-down":U
    IMAGE-INSENSITIVE FILE "adeicon\ts-up":U NO-FOCUS
    LABEL "&1.Параметры"
    SIZE 15 BY 1.17 TOOLTIP "Параметры".
DEFINE BUTTON BUTTON-2
    IMAGE-UP FILE "adeicon\ts-up":U
    IMAGE-DOWN FILE "adeicon\ts-down":U
    IMAGE-INSENSITIVE FILE "adeicon\ts-up":U NO-FOCUS
    LABEL "&2.Продолжение"
    SIZE 15 BY 1.17 TOOLTIP "Продолжение".
DEFINE BUTTON i-exit
    IMAGE-UP FILE "cmp/i-run.bmp":U
    IMAGE-DOWN FILE "cmp/i-run.bmp":U
    IMAGE-INSENSITIVE FILE "cmp/i-rund.bmp":U
    LABEL ""
    SIZE 2.5 BY .75.
DEFINE VARIABLE customer-name       AS CHARACTER
    VIEW-AS EDITOR SCROLLBAR-VERTICAL
    SIZE 34 BY 2 TOOLTIP "Список выбранных Поставщиков"
    FONT 4 NO-UNDO.
DEFINE VARIABLE Goods-Editor        AS CHARACTER
    VIEW-AS EDITOR MAX-CHARS 32000 SCROLLBAR-VERTICAL
    SIZE 34 BY 2
    FONT 4 NO-UNDO.
DEFINE VARIABLE Date-order          AS DATE      FORMAT "99/99/9999":U
    LABEL "Дата заказа"
    VIEW-AS FILL-IN
    SIZE 11 BY 1
    BGCOLOR 15 NO-UNDO.
DEFINE VARIABLE Date-End            AS DATE      FORMAT "99/99/9999":U
    LABEL "по"
    VIEW-AS FILL-IN NATIVE
    SIZE 13 BY 1
    BGCOLOR 15 NO-UNDO.
DEFINE VARIABLE Date-Start          AS DATE      FORMAT "99/99/9999":U
    LABEL "с"
    VIEW-AS FILL-IN NATIVE
    SIZE 13 BY 1
    BGCOLOR 15 NO-UNDO.
DEFINE VARIABLE F-button-1          AS CHARACTER FORMAT "X(256)":U INITIAL "Параметры"
    VIEW-AS TEXT
    SIZE 13 BY .67 TOOLTIP "Параметры" NO-UNDO.
DEFINE VARIABLE F-button-2          AS CHARACTER FORMAT "X(256)":U INITIAL "Продолжение"
    VIEW-AS TEXT
    SIZE 13 BY .71 TOOLTIP "Продолжение" NO-UNDO.
DEFINE VARIABLE f-typedoc-desc      AS CHARACTER
    VIEW-AS EDITOR SCROLLBAR-VERTICAL
    SIZE 50 BY 2 NO-UNDO.
DEFINE VARIABLE text-cliname        AS CHARACTER FORMAT "X(256)":U
    VIEW-AS FILL-IN
    SIZE 50 BY 1 NO-UNDO.
DEFINE VARIABLE garant_day          AS INTEGER   FORMAT ">>>9":U INITIAL 7
    LABEL "Гарантийный запас в днях"
    VIEW-AS FILL-IN
    SIZE 5 BY 1 NO-UNDO.
DEFINE VARIABLE sale_day            AS INTEGER   FORMAT ">>9":U INITIAL ?
    VIEW-AS FILL-IN
    SIZE 5 BY 1 NO-UNDO.
DEFINE VARIABLE text-client         AS CHARACTER FORMAT "X(256)":U INITIAL "Контрагент:"
    VIEW-AS FILL-IN
    SIZE 14 BY 1 NO-UNDO.
DEFINE VARIABLE text-dogovor        AS CHARACTER FORMAT "X(256)":U INITIAL "Договор:"
    VIEW-AS FILL-IN
    SIZE 14 BY 1 NO-UNDO.
DEFINE VARIABLE text-googs          AS CHARACTER FORMAT "X(256)":U INITIAL "Товары:"
    VIEW-AS FILL-IN
    SIZE 14 BY 1 NO-UNDO.
DEFINE VARIABLE text-period_list2   AS CHARACTER FORMAT "X(256)":U INITIAL "Период продаж для анализа:"
    VIEW-AS FILL-IN
    SIZE 27.5 BY 1
    FONT 1 NO-UNDO.
DEFINE VARIABLE text-sale-list1     AS CHARACTER FORMAT "X(256)":U INITIAL "Обеспечение продаж на период в днях:"
    VIEW-AS FILL-IN
    SIZE 37.5 BY 1 NO-UNDO.
DEFINE VARIABLE text-typedoc_list-2 AS CHARACTER FORMAT "X(256)":U INITIAL "Типы документов:"
    VIEW-AS FILL-IN
    SIZE 17 BY 1
    FONT 1 NO-UNDO.
DEFINE VARIABLE RADIO-SET-1         AS INTEGER
    VIEW-AS RADIO-SET HORIZONTAL
    RADIO-BUTTONS
    "7", 1,
    "14", 2,
    "21", 3,
    "28", 4,
    "", 5
    SIZE 29 BY 1.25 NO-UNDO.
DEFINE VARIABLE rs_period           AS INTEGER
    VIEW-AS RADIO-SET VERTICAL
    RADIO-BUTTONS
    ".", 1,
    "", 2
    SIZE 2 BY 3 NO-UNDO.
DEFINE VARIABLE SelectGood          AS INTEGER
    VIEW-AS RADIO-SET VERTICAL
    RADIO-BUTTONS
    "Все по поставщику", 1,
    "Все по договору", 2,
    "Выборочно", 3
    SIZE 29.75 BY 3.25
    FGCOLOR 0 NO-UNDO.
DEFINE RECTANGLE RECT-5
    EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
    SIZE 93 BY 6.25.
DEFINE RECTANGLE RECT-6
    EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
    SIZE 93 BY 1.5.
DEFINE RECTANGLE RECT-7
    EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
    SIZE 93 BY 10.5.
DEFINE VARIABLE t-daygoods AS LOGICAL   INITIAL true
    LABEL "Исключить дни без товара на остатке"
    VIEW-AS TOGGLE-BOX
    SIZE 40 BY .83
    FONT 1 NO-UNDO.
define variable v-title    as character no-undo .
DEFINE QUERY br_date FOR
    tt-dateZakaz SCROLLING.
DEFINE BROWSE br_date
    QUERY br_date NO-LOCK DISPLAY
    tt-dateZakaz.dateStart COLUMN-LABEL "Начало" FORMAT "99/99/9999":U WIDTH 14
    tt-dateZakaz.dateEnd COLUMN-LABEL "Конец" FORMAT "99/99/9999":U
    WITH NO-ROW-MARKERS SEPARATORS NO-SCROLLBAR-VERTICAL SIZE 30 BY 7.71
         TITLE "Интервалы анализа" ROW-HEIGHT-CHARS 1 FIT-LAST-COLUMN.
DEFINE FRAME Dialog-Frame
    b-exit AT ROW 1 COL 1 WIDGET-ID 4
    Btn_OK AT ROW 1 COL 11 WIDGET-ID 10
    i-exit AT ROW 1.08 COL 11.13 WIDGET-ID 12 NO-TAB-STOP
    BUTTON-1 AT ROW 2.5 COL 2 WIDGET-ID 14
    BUTTON-2 AT ROW 2.5 COL 17 WIDGET-ID 16
    Date-order AT ROW 4.25 COL 46 RIGHT-ALIGNED WIDGET-ID 50
    b-date AT ROW 4.29 COL 49.38 RIGHT-ALIGNED WIDGET-ID 374
    rs_period AT ROW 5.75 COL 44.30 NO-LABEL WIDGET-ID 40
    text-sale-list1 AT ROW 5.83 COL 2.63 NO-LABEL WIDGET-ID 84
    text-period_list2 AT ROW 6 COL 11.75 COLON-ALIGNED NO-LABEL WIDGET-ID 94
    Date-Start AT ROW 6 COL 47.75 COLON-ALIGNED WIDGET-ID 34
    b-date-Start AT ROW 6 COL 65 RIGHT-ALIGNED WIDGET-ID 374
    Date-End AT ROW 6 COL 83.38 RIGHT-ALIGNED WIDGET-ID 32
    b-date-End AT ROW 6 COL 86.63 RIGHT-ALIGNED WIDGET-ID 374
    RADIO-SET-1 AT ROW 7 COL 6.38 NO-LABEL WIDGET-ID 56
    sale_day AT ROW 7.13 COL 37.88 RIGHT-ALIGNED NO-LABEL WIDGET-ID 66
    bt-not-sel-all AT ROW 7.54 COL 51.75 WIDGET-ID 86 NO-TAB-STOP
    bt-not-sel-desel-all AT ROW 7.54 COL 54.75 WIDGET-ID 88 NO-TAB-STOP
    br_date AT ROW 7.54 COL 86.75 RIGHT-ALIGNED WIDGET-ID 200
    garant_day AT ROW 8.46 COL 37.88 RIGHT-ALIGNED WIDGET-ID 52
    text-client AT ROW 10.25 COL 2.5 NO-LABEL WIDGET-ID 80
    b-clients AT ROW 10.25 COL 35.63 RIGHT-ALIGNED WIDGET-ID 46
    text-dogovor AT ROW 11.75 COL 2.5 NO-LABEL WIDGET-ID 376
    customer-name AT ROW 12.83 COL 35.5 RIGHT-ALIGNED NO-LABEL WIDGET-ID 48
    text-googs AT ROW 15.08 COL 2.5 NO-LABEL WIDGET-ID 82
    text-typedoc_list-2 AT ROW 15.5 COL 11.75 COLON-ALIGNED NO-LABEL WIDGET-ID 96
    b-type-doc AT ROW 15.5 COL 31.75 WIDGET-ID 36
    f-typedoc-desc AT ROW 15.5 COL 35.75 COLON-ALIGNED NO-LABEL WIDGET-ID 90
    text-cliname AT ROW 10.25 COL 36.75 COLON-ALIGNED NO-LABEL WIDGET-ID 90
    SelectGood AT ROW 16.08 COL 2.5 NO-LABEL WIDGET-ID 68
    b-contract AT ROW 17.21 COL 35.63 RIGHT-ALIGNED WIDGET-ID 384
    t-daygoods AT ROW 18 COL 14 WIDGET-ID 92
    b-chooseContract AT ROW 18.38 COL 35.63 RIGHT-ALIGNED WIDGET-ID 386
    b-chooseGoods AT ROW 18.38 COL 38.75 RIGHT-ALIGNED WIDGET-ID 388
    Goods-Editor AT ROW 19.63 COL 2.5 NO-LABEL WIDGET-ID 54
    F-button-1 AT ROW 2.75 COL 1 COLON-ALIGNED NO-LABEL WIDGET-ID 372
    F-button-2 AT ROW 2.75 COL 16 COLON-ALIGNED NO-LABEL WIDGET-ID 348
    RECT-5 AT ROW 3.75 COL 2 WIDGET-ID 378
    RECT-6 AT ROW 10 COL 2 WIDGET-ID 380
    RECT-7 AT ROW 11.5 COL 2 WIDGET-ID 382
    SPACE(1.24) SKIP(0.57)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
    SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
    TITLE v-title WIDGET-ID 100.
ASSIGN
    FRAME Dialog-Frame:SCROLLABLE = FALSE
    FRAME Dialog-Frame:HIDDEN     = TRUE.
ASSIGN
    b-chooseContract:HIDDEN IN FRAME Dialog-Frame = TRUE.
ASSIGN
    b-chooseGoods:HIDDEN IN FRAME Dialog-Frame = TRUE.
ASSIGN
    b-clients:HIDDEN IN FRAME Dialog-Frame = TRUE.
ASSIGN
    b-contract:HIDDEN IN FRAME Dialog-Frame = TRUE.
ASSIGN
    b-date:HIDDEN IN FRAME Dialog-Frame = TRUE.
ASSIGN
    b-date-Start:HIDDEN IN FRAME Dialog-Frame = TRUE.
ASSIGN
    b-date-End:HIDDEN IN FRAME Dialog-Frame = TRUE.
ASSIGN
    tt-dateZakaz.dateStart:AUTO-RESIZE IN BROWSE br_date = TRUE.
ASSIGN
    customer-name:READ-ONLY IN FRAME Dialog-Frame = TRUE.
ASSIGN
    f-typedoc-desc:READ-ONLY IN FRAME Dialog-Frame = TRUE.
ASSIGN
    text-cliname:READ-ONLY IN FRAME Dialog-Frame = TRUE.
ASSIGN
    Goods-Editor:READ-ONLY IN FRAME Dialog-Frame = TRUE.
ASSIGN
    text-client:READ-ONLY IN FRAME Dialog-Frame = TRUE.
ASSIGN
    text-dogovor:READ-ONLY IN FRAME Dialog-Frame = TRUE.
ASSIGN
    text-googs:READ-ONLY IN FRAME Dialog-Frame = TRUE.
ASSIGN
    text-period_list2:READ-ONLY IN FRAME Dialog-Frame = TRUE.
ASSIGN
    text-sale-list1:READ-ONLY IN FRAME Dialog-Frame = TRUE.
ASSIGN
    text-typedoc_list-2:READ-ONLY IN FRAME Dialog-Frame = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
    DO:
        APPLY "END-ERROR":U TO SELF.
    END.
ON CHOOSE OF b-chooseContract IN FRAME Dialog-Frame
    DO:
        define buffer buf_clients for ub.clients .
        APPLY "choose" TO b-contract .
        if list-dogovor = "" then
        do:
            list-dogovor = customer-name .
            empty temp-table gds-list .
            SelectGood = 2 .
            Goods-Editor = "" .
            display SelectGood Goods-Editor with frame Dialog-Frame .
            hide b-chooseContract b-chooseGoods in frame Dialog-Frame .
            enable b-contract with frame Dialog-Frame .
            return no-apply .
        end.
        if listDogovor <> "" then
            APPLY "choose" TO b-chooseGoods .
    END.
ON CHOOSE OF b-contract IN FRAME Dialog-Frame
    DO:
        define buffer buf_clients for ub.clients .
        if p-ok then
        do:
            run check-contract-code-attr in this-procedure (input  substitute("&1,&2", "choose":u, "doc-type"),
                input  v-cntxt-host-code-obj,
                input  v-cli-type,
                input  v-cli-code,
                input  ?,
                input  parparentproc,
                input  today,
                input  "" ,
                input  "contract-edi_orders",
                output listDogovor) .
        end.
        else
        do:
            run check-contract-code in this-procedure (input  substitute("&1,&2", "choose":u, "doc-type"),
                input  v-cntxt-host-code-obj,
                input  v-cli-type,
                input  v-cli-code,
                input  ?,
                input  parparentproc,
                input  today,
                input  "" ,
                output listDogovor) no-error.
        end.
        if listDogovor <> "" then do:
            listDogovor =  trim (listDogovor,",") .
            list-dogovor = listDogovor .
            empty temp-table gds-list .
            customer-name = customerName(list-dogovor) .
            display customer-name with frame Dialog-Frame .
            find first buf_clients no-lock where recid(buf_clients) = integer(post-grp_recids) no-error .
            if available (buf_clients) then
            run getGoods(list-dogovor, buf_clients.obj-code, buf_clients.obj-type) .
        end.
    END.
ON choose OF bt-not-sel-all IN FRAME Dialog-Frame
    DO:
        run rep/choose_date.w (input parParentProc,
            input-output table tt-dateZakaz by-reference) .
        OPEN QUERY br_date FOR EACH tt-dateZakaz NO-LOCK INDEXED-REPOSITION.
    END.
ON CHOOSE OF b-chooseGoods IN FRAME Dialog-Frame
    DO:
        if list-dogovor = "" then
        do:
            message "Для выбора товара необходимо выбрать договор(ы)" view-as alert-box.
            SelectGood = 1 .
            display SelectGood with frame Dialog-Frame .
            hide b-chooseContract b-chooseGoods b-contract in frame Dialog-Frame .
            return no-apply.
        end.
        RUN str/contspec_choose.w (
            input  parparentproc,
            input  "b-mark,b-sel",
            input  'ПРОСМОТР':U,
            input  v-cntxt-host-code-obj,
            input  list-dogovor,
            input integer(post-grp_recids),
            output table choose-gds-list
            ).
        find first gds-list no-error .
        if available (gds-list) then
        do:
            find first choose-gds-list no-error .
            if available (choose-gds-list) then
            do:
                v-rid-list = "" .
                Goods-Editor = "" .
                empty temp-table gds-list .
                for each choose-gds-list:
                    create gds-list.
                    buffer-copy choose-gds-list to gds-list .
                end.
            end.
            else
            do:
                return no-apply .
            end.
        end.
        else
        do:
            find first choose-gds-list no-error .
            if not available (choose-gds-list) then
            do:
                SelectGood = 2 .
                Goods-Editor = "" .
                display SelectGood Goods-Editor with frame Dialog-Frame .
                hide b-chooseContract b-chooseGoods in frame Dialog-Frame .
                enable b-contract with frame Dialog-Frame .
                return no-apply .
            end.
            else
            do:
                v-rid-list = "" .
                Goods-Editor = "" .
                empty temp-table gds-list .
                for each choose-gds-list:
                    create gds-list.
                    buffer-copy choose-gds-list to gds-list .
                end.
            end.
        end.
        for each gds-list:
            if lookup(string(gds-list.gds-code),v-rid-list,", ") > 0 then next .
            v-rid-list = v-rid-list + "," + string(gds-list.gds-code) .
        end.
        v-rid-list = trim(v-rid-list,",") .
        Goods-Editor = v-rid-list .
        display Goods-Editor with frame Dialog-Frame .
    END.
ON choose OF bt-not-sel-desel-all IN FRAME Dialog-Frame
    DO:
        if available (tt-dateZakaz) then
        do:
            delete tt-dateZakaz .
        end.
        else
        do:
            message "Не выбран интервал анализа для удаления"
                view-as alert-box.
        end.
        OPEN QUERY br_date FOR EACH tt-dateZakaz NO-LOCK INDEXED-REPOSITION.
    END.
ON LEAVE OF Date-End IN FRAME Dialog-Frame
    DO:
        if date(Date-End:screen-value) >= today then
        do:
            message "Дата окончания периода продаж должна быть меньше текущей"
                view-as alert-box.
            display Date-End with frame Dialog-Frame .
            return no-apply .
        end.
        Assign  Date-End no-error.
        display Date-End with frame Dialog-Frame .
    END.
ON LEAVE OF Date-Start IN FRAME Dialog-Frame
    DO:
        if date(Date-Start:screen-value) >= today then
        do:
            message "Дата начала периода продаж должна быть меньше текущей"
                view-as alert-box.
            display Date-Start with frame Dialog-Frame .
            return no-apply .
        end.
        Assign  Date-Start no-error.
        display Date-Start with frame Dialog-Frame .
    END.
ON CHOOSE OF btn_ok IN FRAME Dialog-Frame
    DO:
        define buffer buf_clients for ub.clients .
            define buffer buf_trn-doc         for ub.trn-doc .
    define buffer buf_doc-line        for ub.doc-line .
    define buffer buf_goods           for ub.goods .
    define buffer buf_contract-specif for ub.contract-specif .
        if text-cliname = "" then
        do:
            message "Выберите контрагента!"
                view-as alert-box.
            return no-apply .
        end.
        if SelectGood = 3 and Goods-Editor = "" then
        do:
            message "Товар не выбран!"
                view-as alert-box.
            return no-apply .
        end.
        if fl = "" then
        do:
            message "Необходимо сходить на вкладку 'Продолжение...'"
                view-as alert-box.
            APPLY "choose" TO BUTTON-2 .
            return no-apply .
        end.
        vOk = true .
        case SelectGood:
            when 0 or
            when 1 then
                do:
                    glog = yes .
                    find first buf_clients no-lock where recid(buf_clients) = integer(post-grp_recids) no-error .
                    if available (buf_clients) then
                        run getGoods(list-dogovor, buf_clients.obj-code, buf_clients.obj-type) .
                    if not glog then return no-apply .
                end.
        end case .
        find first gds-list no-error .
        if not available (gds-list) then
        do:
            if p-ok then
            do:
                message "Не найдены товары для создания заказа."
                    view-as alert-box.
                return no-apply .
            end.
            else run getGoods(list-dogovor, buf_clients.obj-code, buf_clients.obj-type) .
        end.
        assign
            t-daygoods
            RADIO-SET-1
            rs_period
            .
        if not p-ok and (SelectGood = 0 or SelectGood = 1) then
        do:
           block-trn-doc:
           for each buf_trn-doc no-lock where buf_trn-doc.obj-code = v-cntxt-obj-code and
                buf_trn-doc.obj-type = v-cntxt-obj-type and
                buf_trn-doc.cli-code = buf_clients.obj-code and
                buf_trn-doc.cli-type = buf_clients.obj-type and
                buf_trn-doc.ext-doc-type = 'ie':U and
                buf_trn-doc.status_ = 'факт':U:
                   if buf_trn-doc.contract-code <> 0 then do:
                      find first ub.contract no-lock where ub.contract.host-code = buf_trn-doc.host-code and
                            ub.contract.cli-code = buf_trn-doc.cli-code and
                            ub.contract.cli-type = buf_trn-doc.cli-type and
                            ub.contract.status_ = 'тек':U and
                            ub.contract.contract-code = buf_trn-doc.contract-code no-error.
                            if available ub.contract and
                            (ub.contract.contract-date-end > today or ub.contract.contract-date-end = ?) and
                                ub.contract.contract-date-beg <= today then
                            do:
                            end.
                            else
                               next block-trn-doc.
                   end.
                   else release ub.contract .
                for each buf_doc-line no-lock where buf_doc-line.doc-code = buf_trn-doc.doc-code,
                    first buf_goods no-lock where buf_goods.artic = buf_doc-line.artic and
                    buf_goods.prod-code = buf_doc-line.prod-code and
                    buf_goods.prod-type = buf_doc-line.prod-type:
                    if available ub.contract then
                    do:
                            for first buf_contract-specif no-lock where
                            buf_contract-specif.host-code = ub.contract.host-code and
                            buf_contract-specif.contract-num = ub.contract.contract-code and
                            buf_contract-specif.gds-code = buf_goods.gds-code:
                                find first gds-list where gds-list.gds-code = buf_contract-specif.gds-code and
                                    gds-list.contract = ub.contract.contract-prn-code and
                                    gds-list.contract-code = buf_contract-specif.contract-num no-error .
                                if not available (gds-list) then
                                do:
                                    create gds-list .
                                    buffer-copy buf_goods to gds-list
                                        assign
                                        gds-list.contract-code = ub.contract.contract-code
                                        gds-list.contract      = ub.contract.contract-prn-code
                                        .
                                end.
                        end.
                    end.
                    else
                    do:
                        find first gds-list where gds-list.gds-code = buf_goods.gds-code no-error .
                        if not available (gds-list) then
                        do:
                            create gds-list .
                            buffer-copy buf_goods to gds-list .
                        end.
                    end.
                end.
            end.
        end .
        if p-ok and customer-name = "БЕЗ ДОГОВОРА" then
        do:
            message "Внимание! Формирование заказа невозможно, выберите договор(-ы)"
                view-as alert-box.
            return no-apply .
        end.
        run rep/r-rsrv-plan.p(input parParentProc,
            input p-ok,
            input post-grp_recids,
            input Date-order,
            input rs_period,
            input Date-Start,
            input Date-End,
            input RADIO-SET-1,
            input sale_day,
            input garant_day,
            input t-daygoods,
            input table tt-typeDocChoose,
            input table tt-dateZakaz,
            input table gds-list
            ) .
    END.
ON CHOOSE OF i-exit IN FRAME Dialog-Frame
    DO:
        APPLY "choose" TO btn_ok.
    END.
ON CHOOSE OF b-type-doc IN FRAME Dialog-Frame
    DO:
        f-typedoc-desc = "" .
        run ref/type_doc.w (input parParentProc, input-output table tt-typeDocChoose ) .
        for each tt-typeDocChoose:
            f-typedoc-desc = f-typedoc-desc + ", " + tt-typeDocChoose.typeName .
        end.
        f-typedoc-desc = trim(f-typedoc-desc,", ") .
        display f-typedoc-desc with frame Dialog-Frame .
    END.
ON CHOOSE OF b-clients IN FRAME Dialog-Frame
    DO:
        define buffer bf_contract  for ub.contract .
        define buffer cli-post     for ub.clients .
        define buffer buf_contract for ub.contract .
        define variable v-nn             as integer   no-undo .
        define variable ii               as integer   no-undo .
        define variable vIsChange        as logical   no-undo init no.
        define variable old-list-dogovor as character no-undo .
        if p-ok then
        do:
            run ref/cli-all.w
                ( parParentProc
                , "b-sel"
                , 'все':U
                , 'все':U
                , 'текущие':U
                , ?
                , ?
                , "contract-edi_orders"
                , output post-grp_recids ) .
        end.
        else
        do:
            run ref/cli-all.w
                ( parParentProc
                , "b-sel"
                , 'все':U
                , 'все':U
                , 'текущие':U
                , ?
                , ?
                , ""
                , output post-grp_recids ) .
        end.
        if post-grp_recids <> "" then
        do:
            Assign
                text-cliname  = ''
                customer-name = "".
            v-nn = num-entries( post-grp_recids ) .
            DO ii = 1 TO v-nn :
                FIND cli-post WHERE recid( cli-post ) = int(entry( ii, post-grp_recids )) NO-LOCK.
                if v-cli-code <> cli-post.obj-code or v-cli-type <> cli-post.obj-type then
                    vIsChange = yes.
                assign
                    v-cli-code   = cli-post.obj-code
                    v-cli-type   = cli-post.obj-type
                    v-cli-name   = cli-post.obj-name
                    text-cliname = cli-post.obj-type + " " + string(cli-post.obj-code) + " " + cli-post.obj-name .
            END.
            if p-ok then customer-name = "Все действующие договоры с EDI" .
            else customer-name = "Все действующие договоры" .
            SelectGood = 1 .
            if p-ok then customer-name = "Все действующие договоры с EDI" .
            else customer-name = "Все действующие договоры" .
            list-dogovor = "" .
            v-rid-list = "" .
            Goods-Editor = "" .
            empty temp-table gds-list .
            Display text-cliname customer-name SelectGood Goods-Editor with frame Dialog-Frame .
            hide b-chooseContract b-chooseGoods b-contract in frame Dialog-Frame .
        end.
        else
        do:
            if v-cli-code <> ? and v-cli-code <> 0 then
            do:
                find cli-post where cli-post.obj-code = v-cli-code and
                    cli-post.obj-type = v-cli-type no-lock .
                post-grp_recids = string(recid (cli-post)) .
            end.
        end.
    END.
ON VALUE-CHANGED OF RADIO-SET-1 IN FRAME Dialog-Frame
    DO:
        assign RADIO-SET-1 .
        case RADIO-SET-1:
            when 5 then
                do:
                    enable sale_day with frame Dialog-Frame .
                end.
            otherwise
            do:
                disable sale_day with frame Dialog-Frame .
            end.
        end case .
    END.
ON leave OF sale_day IN FRAME Dialog-Frame
    DO:
        assign sale_day .
    END.
ON LEAVE OF Date-End IN FRAME Dialog-Frame
    DO:
        apply "TAB":U to self .
    END.
ON LEAVE OF Date-Start IN FRAME Dialog-Frame
    DO:
        apply "TAB":U to self .
    END.
ON leave OF garant_day IN FRAME Dialog-Frame
    DO:
        assign garant_day .
        if garant_day = ? then return no-apply .
    END.
ON VALUE-CHANGED OF rs_period IN FRAME Dialog-Frame
    DO:
        assign rs_period .
        case rs_period:
            when 1 then
                do:
                    enable Date-End Date-Start b-date-End b-date-Start with frame Dialog-Frame .
                    disable bt-not-sel-all bt-not-sel-desel-all br_date with frame Dialog-Frame .
                    empty temp-table tt-dateZakaz .
                    OPEN QUERY br_date FOR EACH tt-dateZakaz NO-LOCK INDEXED-REPOSITION.
                end.
            otherwise
            do:
                disable Date-End Date-Start b-date-End b-date-Start with frame Dialog-Frame .
                enable bt-not-sel-all bt-not-sel-desel-all br_date with frame Dialog-Frame .
            end.
        end case .
    END.
ON VALUE-CHANGED OF SelectGood IN FRAME Dialog-Frame
    DO:
        define buffer buf_clients    for ub.clients .
        define buffer buf_goods-attr for ub.gds-obj-attr .
        define buffer bf_contract    for ub.contract .
        define buffer cli-post       for ub.clients .
        define buffer buf_contract   for ub.contract .
        define variable ii               as integer   no-undo .
        define variable v-nn             as integer   no-undo .
        define variable vIsChange        as logical   no-undo init no.
        define variable old-list-dogovor as character no-undo .
        assign SelectGood .
        find first buf_clients no-lock where recid(buf_clients) = integer(post-grp_recids) no-error .
        if available (buf_clients) then
        do:
            case SelectGood:
                when 1 or
                when 0 then
                    do:
                        v-rid-list = "" .
                        list-dogovor = "" .
                        empty temp-table gds-list .
                        if p-ok then customer-name = "Все действующие договоры с EDI" .
                        else customer-name = "Все действующие договоры" .
                        hide b-chooseContract b-chooseGoods b-contract in frame Dialog-Frame .
                        run getGoods(list-dogovor, buf_clients.obj-code, buf_clients.obj-type) .
                    end.
                when 2 then
                    do:
                        hide b-chooseContract b-chooseGoods in frame Dialog-Frame .
                        enable b-contract with frame Dialog-Frame .
                        list-dogovor = "" .
                        Goods-Editor = "" .
                        v-rid-list = "" .
                        empty temp-table gds-list .
                        APPLY "choose" TO b-contract .
                        list-dogovor =  trim (list-dogovor,",") .
                        if list-dogovor = "" then
                        do:
                            SelectGood = 1 .
                            if p-ok then customer-name = "Все действующие договоры с EDI" .
                            else customer-name = "Все действующие договоры" .
                            display SelectGood customer-name with frame Dialog-Frame .
                            hide b-chooseContract b-chooseGoods b-contract in frame Dialog-Frame .
                        end.
                    end.
                when 3 then
                    do:
                        enable b-chooseContract b-chooseGoods with frame Dialog-Frame .
                        hide b-contract in frame Dialog-Frame .
                        list-dogovor = "" .
                        empty temp-table gds-list .
                        APPLY "choose" TO b-contract .
                       if list-dogovor = "" then
                        do:
                            SelectGood = 1 .
                            if p-ok then customer-name = "Все действующие договоры с EDI" .
                            else customer-name = "Все действующие договоры" .
                            display SelectGood customer-name with frame Dialog-Frame .
                            hide b-chooseContract b-chooseGoods b-contract in frame Dialog-Frame .
                            return no-apply .
                        end.
                        APPLY "choose" TO b-chooseGoods .
                        find first gds-list no-error .
                        if not available (gds-list) then
                        do:
                            SelectGood = 2 .
                            hide b-chooseContract b-chooseGoods in frame Dialog-Frame .
                            enable b-contract with frame Dialog-Frame .
                            display SelectGood with frame Dialog-Frame .
                            run getGoods(list-dogovor, buf_clients.obj-code, buf_clients.obj-type) .
                            return no-apply .
                        end.
                    end .
            end case.
        end.
        else
        do:
            message "Выберите контрагента!"
                view-as alert-box.
            SelectGood = 1 .
            hide b-chooseContract b-chooseGoods b-contract in frame Dialog-Frame .
            display SelectGood with frame Dialog-Frame .
        end.
        Goods-Editor = v-rid-list .
        if not vOk then display Goods-Editor with frame Dialog-Frame .
        for each gds-list:
            for first buf_goods-attr no-lock where buf_goods-attr.gds-code = gds-list.gds-code and
                buf_goods-attr.attr-code = 'min-zapas':U:
                gds-list.minZapas = decimal (buf_goods-attr.attr-value) .
            end.
        end.
        find first gds-list where gds-list.minZapas = 0 no-error .
        if available (gds-list) then
        do:
            if vOk then
            do:
                if p-ok then
                do:
                    message "Внимание! Не у всех выбранных товаров установлен атрибут «Минимальный запас»" skip
                        "Создать заказ?"
                        view-as alert-box question buttons YES-NO update glog .
                end.
                else
                do:
                    message "Внимание! Не у всех выбранных товаров установлен атрибут «Минимальный запас»" skip
                        "Вывести отчет?"
                        view-as alert-box question buttons YES-NO update glog .
                end.
                if not glog then
                do:
                    APPLY "choose" TO BUTTON-1 .
                end.
            end.
            else
            do:
                message "Внимание! Не у всех выбранных товаров установлен атрибут «Минимальный запас»"
                    view-as alert-box.
            end.
        end.
        display SelectGood customer-name Goods-Editor with frame Dialog-Frame .
    END.
ON CHOOSE OF BUTTON-1 IN FRAME Dialog-Frame
    DO:
        DISPLAY RECT-5 RECT-6 RECT-7 Date-order b-date RADIO-SET-1 sale_day garant_day b-clients customer-name SelectGood Goods-Editor text-client text-dogovor text-googs text-sale-list1 text-cliname b-contract b-chooseContract b-chooseGoods with FRAME Dialog-Frame.
        case SelectGood:
            when 1 or
            when 0 then
                do:
                    hide b-chooseContract b-chooseGoods b-contract in frame Dialog-Frame .
                end.
            when 2 then
                do:
                    hide b-chooseContract b-chooseGoods in frame Dialog-Frame .
                    enable b-contract with frame Dialog-Frame .
                end.
            when 3 then
                do:
                    hide b-contract in frame Dialog-Frame .
                    enable b-chooseContract b-chooseGoods with frame Dialog-Frame .
                end.
        end case .
        HIDE Date-Start Date-End rs_period text-period_list2 br_date bt-not-sel-all bt-not-sel-desel-all t-daygoods b-date-Start b-date-End IN FRAME Dialog-Frame.
        button-1:LOAD-IMAGE-UP("adeicon\ts-up":U)        in frame Dialog-Frame .
        button-2:LOAD-IMAGE-Up("adeicon\ts-down":U)      in frame Dialog-Frame .
        F-button-1:fgcolor = 1 .
        f-button-2:fgcolor = ? .
    END.
ON CHOOSE OF BUTTON-2 IN FRAME Dialog-Frame
    DO:
        assign
            garant_day
            Date-order
            .
        if text-cliname = "" then
        do:
            message "Выберите контрагента!"
                view-as alert-box.
            return no-apply .
        end.
        if SelectGood = 3 and Goods-Editor = "" then
        do:
            message "Товар не выбран!"
                view-as alert-box.
            return no-apply .
        end.
        DISPLAY Date-Start Date-End rs_period text-period_list2 br_date bt-not-sel-all bt-not-sel-desel-all t-daygoods b-date-Start b-date-End with FRAME Dialog-Frame.
        HIDE RECT-5 RECT-6 RECT-7 Date-order b-date RADIO-SET-1 sale_day garant_day b-clients customer-name SelectGood Goods-Editor text-client text-dogovor text-googs text-sale-list1 text-cliname b-contract b-chooseContract b-chooseGoods IN FRAME Dialog-Frame.
        button-2:LOAD-IMAGE-UP("adeicon\ts-up":U)        in frame Dialog-Frame .
        button-1:LOAD-IMAGE-Up("adeicon\ts-down":U)      in frame Dialog-Frame .
        F-button-2:fgcolor = 1 .
        f-button-1:fgcolor = ? .
        fl = "2" .
    END.
ON CHOOSE OF b-date IN FRAME Dialog-Frame
    DO:
        run sel-date in this-procedure
            (input Date-order :handle
            ,input ""
            ) .
        if date(Date-order:screen-value) < today then
        do:
            message "Дата заказа должна быть равна или больше текущей"
                view-as alert-box.
            display Date-order with frame Dialog-Frame .
            return no-apply .
        end.
        assign Date-order .
    END.
ON LEAVE OF Date-order IN FRAME Dialog-Frame
    DO:
        apply "TAB":U to self .
    END.
ON RETURN OF Date-order IN FRAME Dialog-Frame
    DO:
        apply "TAB":U to self .
    END.
ON TAB OF Date-order IN FRAME Dialog-Frame
    DO:
        date(Date-order:screen-value) no-error.
        if error-status:error then
        do:
            message "Ошибка ввода даты"
                view-as alert-box.
            display Date-order with frame Dialog-Frame .
            return no-apply .
        end.
        if string(Date-order) <> Date-order:screen-value then
        do:
            if date(Date-order:screen-value) < today then
            do:
                message "Дата заказа должна быть равна или больше текущей"
                    view-as alert-box.
                display Date-order with frame Dialog-Frame .
                return no-apply.
            end.
            assign Date-order .
            display Date-order with frame Dialog-Frame .
        end.
    END.
ON CHOOSE OF b-date-Start IN FRAME Dialog-Frame
    DO:
        run sel-date in this-procedure
            (input Date-Start :handle
            ,input ""
            ) .
        if Date-End < date(Date-Start:screen-value) then
        do:
            message "Дата начала не может быть больше конечной даты"
                view-as alert-box.
            display Date-Start with frame Dialog-Frame .
        end.
        if date(Date-Start:screen-value) >= today then
        do:
            message "Дата начала периода продаж должна быть меньше текущей"
                view-as alert-box.
            display Date-Start with frame Dialog-Frame .
            return no-apply .
        end.
    END.
ON CHOOSE OF b-date-End IN FRAME Dialog-Frame
    DO:
        run sel-date in this-procedure
            (input Date-End :handle
            ,input ""
            ) .
        if date(Date-End:screen-value) < Date-Start then
        do:
            message "Дата начала не может быть больше конечной даты"
                view-as alert-box.
            display Date-End with frame Dialog-Frame .
        end.
        if date(Date-End:screen-value) >= today then
        do:
            message "Дата окончания периода продаж должна быть меньше текущей"
                view-as alert-box.
            display Date-End with frame Dialog-Frame .
            return no-apply .
        end.
    END.
ON RETURN OF Date-End IN FRAME Dialog-Frame
    DO:
        apply "TAB":U to self .
    END.
ON TAB OF Date-End IN FRAME Dialog-Frame
    DO:
        date(Date-End:screen-value) no-error.
        if error-status:error then
        do:
            message "Ошибка ввода даты"
                view-as alert-box.
            display Date-End with frame Dialog-Frame .
            return no-apply .
        end.
        if string(Date-End) <> Date-End:screen-value then
        do:
            if date(Date-End:screen-value) < Date-Start then
            do:
                message "Дата начала не может быть больше конечной даты"
                    view-as alert-box.
                return no-apply .
            end.
            if date(Date-End:screen-value) >= today then
            do:
                message "Дата окончания периода продаж должна быть меньше текущей"
                    view-as alert-box.
                display Date-End with frame Dialog-Frame .
                return no-apply.
            end.
            assign Date-End .
            display Date-End with frame Dialog-Frame .
        end.
    END.
ON RETURN OF Date-Start IN FRAME Dialog-Frame
    DO:
        apply "TAB":U to self .
    END.
ON TAB OF Date-Start IN FRAME Dialog-Frame
    DO:
        date(Date-Start:screen-value) no-error.
        if error-status:error then
        do:
            message "Ошибка ввода даты"
                view-as alert-box.
            display Date-Start with frame Dialog-Frame .
            return no-apply .
        end.
        if string(Date-Start) <> Date-Start:screen-value then
        do:
            if Date-End < date(Date-Start:screen-value) then
            do:
                message "Дата начала не может быть больше конечной даты"
                    view-as alert-box.
                return no-apply .
            end.
            if date(Date-Start:screen-value) >= today then
            do:
                message "Дата начала периода продаж должна быть меньше текущей"
                    view-as alert-box.
                display Date-Start with frame Dialog-Frame .
                return no-apply.
            end.
            assign Date-Start .
            display Date-Start with frame Dialog-Frame .
        end.
    END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
    THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
    ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on ' ' of Date-order in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.
on delete-character of Date-order in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.
on ctrl-d of Date-order in frame Dialog-Frame
do:
  define variable v-curr-sv-date as date no-undo .
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    run gbl/getcurdt.p
      (output v-curr-sv-date
      ) .
    assign
      self :screen-value = string(v-curr-sv-date) .
    .
  end.
  return no-apply.
end.
on ctrl-b of Date-order in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      assign
        v-new-sv-date = date( month(v-curr-sv-date), 1, year(v-curr-sv-date))
      .
      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.
  return no-apply .
end.
on ctrl-e of Date-order in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      run gbl/lastdate.p
        (input  v-curr-sv-date
        ,output v-new-sv-date
        ).
      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.
  return no-apply .
end.
on ctrl-f of Date-order in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-ok            as logical   no-undo .
    define variable v-curr-sv-date  as date      no-undo .
    define variable v-description   as character no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      run gbl/d-inpday.w
        (input ?
        ,input "Выбор даты"
        ,input v-description
        ,input ""
        ,input-output v-curr-sv-date
        ,output v-ok
        ).
      if v-ok = true
      then do:
        assign
          self :screen-value = string(v-curr-sv-date) .
        .
      end.
    end.
  end.
  return no-apply .
end.
  define MENU m-ed-date4
    MENU-ITEM m-ed-date4-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date4-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date4-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date4-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if Date-order :POPUP-MENU in frame Dialog-Frame = ?
  then do:
    ASSIGN
      Date-order :POPUP-MENU in frame Dialog-Frame = MENU m-ed-date4 :HANDLE
      Date-order :MENU-MOUSE in frame Dialog-Frame = 3
    .
  end.
  define variable v-label-handle4 as handle no-undo .
  assign
    v-label-handle4 = Date-order :side-label-handle in frame Dialog-Frame
  .
  if valid-handle (v-label-handle4)
  then do:
    if v-label-handle4 :tooltip = ""
    or v-label-handle4 :tooltip = ?
    then do:
      assign
        v-label-handle4 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date4-1 in menu m-ed-date4 DO:
    apply "ctrl-b":U to Date-order in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date4-2 in menu m-ed-date4 DO:
    apply "ctrl-d":U to Date-order in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date4-3 in menu m-ed-date4 DO:
    apply "ctrl-e":U to Date-order in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date4-4 in menu m-ed-date4 DO:
    apply "ctrl-f":U to Date-order in frame Dialog-Frame .
  END.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on ' ' of Date-Start in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.
on delete-character of Date-Start in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.
on ctrl-d of Date-Start in frame Dialog-Frame
do:
  define variable v-curr-sv-date as date no-undo .
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    run gbl/getcurdt.p
      (output v-curr-sv-date
      ) .
    assign
      self :screen-value = string(v-curr-sv-date) .
    .
  end.
  return no-apply.
end.
on ctrl-b of Date-Start in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      assign
        v-new-sv-date = date( month(v-curr-sv-date), 1, year(v-curr-sv-date))
      .
      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.
  return no-apply .
end.
on ctrl-e of Date-Start in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      run gbl/lastdate.p
        (input  v-curr-sv-date
        ,output v-new-sv-date
        ).
      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.
  return no-apply .
end.
on ctrl-f of Date-Start in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-ok            as logical   no-undo .
    define variable v-curr-sv-date  as date      no-undo .
    define variable v-description   as character no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      run gbl/d-inpday.w
        (input ?
        ,input "Выбор даты"
        ,input v-description
        ,input ""
        ,input-output v-curr-sv-date
        ,output v-ok
        ).
      if v-ok = true
      then do:
        assign
          self :screen-value = string(v-curr-sv-date) .
        .
      end.
    end.
  end.
  return no-apply .
end.
  define MENU m-ed-date6
    MENU-ITEM m-ed-date6-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date6-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date6-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date6-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if Date-Start :POPUP-MENU in frame Dialog-Frame = ?
  then do:
    ASSIGN
      Date-Start :POPUP-MENU in frame Dialog-Frame = MENU m-ed-date6 :HANDLE
      Date-Start :MENU-MOUSE in frame Dialog-Frame = 3
    .
  end.
  define variable v-label-handle6 as handle no-undo .
  assign
    v-label-handle6 = Date-Start :side-label-handle in frame Dialog-Frame
  .
  if valid-handle (v-label-handle6)
  then do:
    if v-label-handle6 :tooltip = ""
    or v-label-handle6 :tooltip = ?
    then do:
      assign
        v-label-handle6 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date6-1 in menu m-ed-date6 DO:
    apply "ctrl-b":U to Date-Start in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date6-2 in menu m-ed-date6 DO:
    apply "ctrl-d":U to Date-Start in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date6-3 in menu m-ed-date6 DO:
    apply "ctrl-e":U to Date-Start in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date6-4 in menu m-ed-date6 DO:
    apply "ctrl-f":U to Date-Start in frame Dialog-Frame .
  END.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on ' ' of Date-End in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.
on delete-character of Date-End in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.
on ctrl-d of Date-End in frame Dialog-Frame
do:
  define variable v-curr-sv-date as date no-undo .
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    run gbl/getcurdt.p
      (output v-curr-sv-date
      ) .
    assign
      self :screen-value = string(v-curr-sv-date) .
    .
  end.
  return no-apply.
end.
on ctrl-b of Date-End in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      assign
        v-new-sv-date = date( month(v-curr-sv-date), 1, year(v-curr-sv-date))
      .
      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.
  return no-apply .
end.
on ctrl-e of Date-End in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      run gbl/lastdate.p
        (input  v-curr-sv-date
        ,output v-new-sv-date
        ).
      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.
  return no-apply .
end.
on ctrl-f of Date-End in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-ok            as logical   no-undo .
    define variable v-curr-sv-date  as date      no-undo .
    define variable v-description   as character no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      run gbl/d-inpday.w
        (input ?
        ,input "Выбор даты"
        ,input v-description
        ,input ""
        ,input-output v-curr-sv-date
        ,output v-ok
        ).
      if v-ok = true
      then do:
        assign
          self :screen-value = string(v-curr-sv-date) .
        .
      end.
    end.
  end.
  return no-apply .
end.
  define MENU m-ed-date8
    MENU-ITEM m-ed-date8-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date8-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date8-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date8-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if Date-End :POPUP-MENU in frame Dialog-Frame = ?
  then do:
    ASSIGN
      Date-End :POPUP-MENU in frame Dialog-Frame = MENU m-ed-date8 :HANDLE
      Date-End :MENU-MOUSE in frame Dialog-Frame = 3
    .
  end.
  define variable v-label-handle8 as handle no-undo .
  assign
    v-label-handle8 = Date-End :side-label-handle in frame Dialog-Frame
  .
  if valid-handle (v-label-handle8)
  then do:
    if v-label-handle8 :tooltip = ""
    or v-label-handle8 :tooltip = ?
    then do:
      assign
        v-label-handle8 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date8-1 in menu m-ed-date8 DO:
    apply "ctrl-b":U to Date-End in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date8-2 in menu m-ed-date8 DO:
    apply "ctrl-d":U to Date-End in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date8-3 in menu m-ed-date8 DO:
    apply "ctrl-e":U to Date-End in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date8-4 in menu m-ed-date8 DO:
    apply "ctrl-f":U to Date-End in frame Dialog-Frame .
  END.
if p-ok then v-title = "Заказ товаров Магазина" .
else v-title = "Отчет по планированию заказа товаров Магазина и готовой продукции Кафе" .
Date-order = today .
Date-End = today - 1 .
Date-Start = today - 28 .
find first tt-typeDocChoose no-error .
if not available (tt-typeDocChoose) then
do:
    create tt-typeDocChoose .
    assign
        tt-typeDocChoose.type-code = 'es':U
        tt-typeDocChoose.typeName  = "расход внешний касса"
        .
    create tt-typeDocChoose .
    assign
        tt-typeDocChoose.type-code = 'rs':U
        tt-typeDocChoose.typeName  = "возврат внешний касса"
        .
end.
for each tt-typeDocChoose:
    f-typedoc-desc = f-typedoc-desc + ", " + tt-typeDocChoose.typeName .
end.
f-typedoc-desc = trim(f-typedoc-desc,", ") .
display f-typedoc-desc with frame Dialog-Frame .
RUN enable_UI.
apply  "CHOOSE":U   to  button-1 in frame Dialog-Frame .
WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
    HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
    DISPLAY Date-order rs_period text-sale-list1 text-period_list2 Date-Start
        Date-End RADIO-SET-1 sale_day garant_day text-client text-dogovor
        customer-name text-googs SelectGood
        t-daygoods Goods-Editor F-button-1 F-button-2 text-cliname
        WITH FRAME Dialog-Frame.
    ENABLE b-exit Btn_OK i-exit BUTTON-1 RECT-5 RECT-6 BUTTON-2
        RECT-7 Date-order b-date rs_period Date-Start Date-End RADIO-SET-1
        br_date garant_day b-clients customer-name SelectGood b-chooseContract b-chooseGoods
        t-daygoods Goods-Editor F-button-1 F-button-2 b-date-End b-date-Start b-contract
        WITH FRAME Dialog-Frame.
    VIEW FRAME Dialog-Frame.
    hide b-type-doc text-typedoc_list-2 f-typedoc-desc in frame Dialog-Frame .
    OPEN QUERY br_date FOR EACH tt-dateZakaz NO-LOCK INDEXED-REPOSITION.
END PROCEDURE.
PROCEDURE getGoods :
    define input parameter p-list-dogovor as character no-undo .
    define input parameter p-obj-code as integer no-undo .
    define input parameter p-obj-type as character no-undo .
    define variable ii as integer no-undo .
    define buffer buf_trn-doc         for ub.trn-doc .
    define buffer buf_doc-line        for ub.doc-line .
    define buffer buf_goods           for ub.goods .
    define buffer buf_contract-specif for ub.contract-specif .
    case SelectGood:
        when 1 or
        when 0 then
            do:
                if not p-ok then
                do:
                    if list-dogovor <> "" then
                    do:
                        list-dogovor = "".
                        customer-name = "БЕЗ ДОГОВОРА" .
                        display customer-name with frame Dialog-Frame .
                    end.
                end.
                else
                do:
                    for each ub.contract no-lock where ub.contract.cli-code = p-obj-code and
                        ub.contract.cli-type = p-obj-type and
                        (ub.contract.contract-date-end > today or ub.contract.contract-date-end = ?) and
                        ub.contract.contract-date-beg <= today and
                        ub.contract.status_ = 'тек':U:
                        find first ub.contract-attr no-lock where ub.contract-attr.contract-code = ub.contract.contract-code and
                            ub.contract-attr.host-code = ub.contract.host-code and
                            ub.contract-attr.attr-code = "contract-edi_orders" and
                            ub.contract-attr.attr-value = string (true) no-error .
                        if not available (ub.contract-attr) then next .
                        for each buf_contract-specif no-lock where
                            buf_contract-specif.contract-num = ub.contract.contract-code :
                            find first gds-list where gds-list.gds-code = ub.contract-specif.gds-code and
                                gds-list.contract = ub.contract.contract-prn-code no-error .
                            if not available (gds-list) then
                            do:
                                find first buf_goods no-lock where buf_goods.gds-code = buf_contract-specif.gds-code no-error .
                                if available (buf_goods) then
                                do:
                                    create gds-list .
                                    buffer-copy buf_goods to gds-list assign
                                        gds-list.contract-code = ub.contract.contract-code
                                        gds-list.contract      = ub.contract.contract-prn-code
                                        .
                                end.
                            end.
                        end.
                    end.
                end.
            end.
        when 2 then
            do:
                do ii = 1 to num-entries (list-dogovor):
                    find first ub.contract no-lock where ub.contract.contract-code = integer(entry(ii,list-dogovor,",")) no-error .
                    for each buf_contract-specif no-lock where buf_contract-specif.contract-num = ub.contract.contract-code:
                        find first gds-list where gds-list.gds-code = buf_contract-specif.gds-code and
                            gds-list.contract-code = buf_contract-specif.contract-num no-error .
                        if not available (gds-list) then
                        do:
                            find first buf_goods no-lock where buf_goods.gds-code = buf_contract-specif.gds-code no-error .
                            if available (buf_goods) then
                            do:
                                create gds-list .
                                buffer-copy buf_goods to gds-list assign
                                    gds-list.contract-code = ub.contract.contract-code
                                    gds-list.contract = ub.contract.contract-prn-code
                                    .
                            end.
                        end.
                    end.
                end.
            end.
    end case .
END PROCEDURE.
FUNCTION customerName RETURNS CHARACTER
    ( p-dogovor as character) :
    define variable ii    as integer   no-undo .
    define variable name_ as character no-undo .
    define buffer buf_contract for ub.contract .
    do ii = 1 to num-entries(p-dogovor):
        find first buf_contract no-lock where buf_contract.contract-code = integer(entry(ii,p-dogovor,",")) no-error .
        if available (buf_contract) then
        do:
            name_ = name_ + ", " + buf_contract.contract-prn-code .
        end.
    end.
    if name_ <> "" then name_ = trim(name_,",") .
    RETURN name_ .
END FUNCTION.
