define input  parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
define input  parameter p-mode  as character no-undo .
define input  parameter p-gds   as integer no-undo .
define input  parameter p-artic as character no-undo .
define input  parameter p-prod  as character no-undo .
define input  parameter p-NAME  as character no-undo .
define input  parameter p-unit-base as character no-undo .
define input-output parameter p-price as decimal   no-undo .
define input-output parameter p-prc   as decimal   no-undo .
define input-output parameter p-prc-2   as decimal   no-undo .
define input-output parameter p-vat-type   as character   no-undo .
define input-output parameter p-qnty   as decimal   no-undo .
define input-output parameter p-cli-base-rate as decimal   no-undo .
define input-output parameter p-vat-pc   as decimal   no-undo .
define input-output parameter p-unit-cli  as character no-undo .
define input-output parameter p-unit-cli-ord  as character no-undo .
define input-output parameter p-cli-base-rate-ord as decimal   no-undo .
define input-output parameter p-unit-cli-rcv  as character no-undo .
define input-output parameter p-cli-base-rate-rcv as decimal   no-undo .
define input-output parameter p-bonus        as decimal   no-undo .
define input-output parameter p-retro-bonus   as character no-undo .
define output parameter p-res   as logical   no-undo .
define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Изменение Товарной спецификации к договору" .
procedure vss-get-info :
  define output parameter p-vss-revision    like vss-revision    no-undo .
  define output parameter p-vss-author      like vss-author      no-undo .
  define output parameter p-vss-date        like vss-date        no-undo .
  define output parameter p-vss-workfile    like vss-workfile    no-undo .
  define output parameter p-vss-archive     like vss-archive     no-undo .
  define output parameter p-vss-description like vss-description no-undo .
  assign
    p-vss-revision    = vss-revision
    p-vss-author      = vss-author
    p-vss-date        = vss-date
    p-vss-workfile    = vss-workfile
    p-vss-archive     = vss-archive
    p-vss-description = vss-description
  .
end procedure.
procedure vss-get-parameters :
  define output parameter p-vss-parameters as character no-undo .
end procedure.
define new global shared variable g#vssrevis-logger as handle    no-undo .
define variable v-vssrevis-logevent                 as logical   no-undo init false .
define variable v-vssrevis-logger                   as handle    no-undo .
procedure vss-logevent :
  define input  parameter p-extra-paramters as character no-undo .
  define variable v-vssrevis-parameters as character no-undo .
  do
  on error undo, return error return-value
  :
    if  valid-handle(v-vssrevis-logger)
    and v-vssrevis-logger :get-signature("logevent") <> ""
    then do:
      run vss-get-parameters in this-procedure
        (output v-vssrevis-parameters
        ).
      run logevent in v-vssrevis-logger
        (input vss-workfile
        ,input vss-revision
        ,input v-vssrevis-parameters
        ,input p-extra-paramters
        ).
    end.
  end.
end procedure.
assign
  v-vssrevis-logger = g#vssrevis-logger
.
if  valid-handle(v-vssrevis-logger)
and v-vssrevis-logger :get-signature("logevent") <> ""
then do:
  assign
    v-vssrevis-logevent = true
  .
  run vss-logevent in this-procedure (input vss-description) .
end.
procedure proc-alt-shift-f2:
  if not ibs.th.gbl.gbl-var:rcode
then
  run gbl\inidebug.p .
end.
procedure proc-alt-shift-f3:
  run gbl/prvssinf.p
    ( input this-procedure
    ) .
end.
define variable v-inform-launched as logical no-undo initial false .
procedure proc-alt-shift-f4:
  define variable v-action as character no-undo .
  if v-inform-launched = false then do:
    assign
      v-inform-launched = true
    .
    run gbl/d-inform.w
      (  input self
      ,  input this-procedure
      , output v-action
      ) no-error .
    run gbl/infrmact.p (input self, input this-procedure, input v-action) no-error .
    assign
      v-inform-launched = false
    .
  end.
end.
procedure proc-alt-f1:
  run gbl/corrhelp.p
    (input this-procedure
    ) .
end .
on alt-shift-f2 anywhere do:
  run proc-alt-shift-f2.
end.
on alt-shift-f3 anywhere do:
  run proc-alt-shift-f3 in this-procedure .
end.
on alt-shift-f4 anywhere do:
  run proc-alt-shift-f4 in this-procedure.
end.
on alt-f1 anywhere do:
  run proc-alt-f1 in this-procedure .
end.
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define variable g-log      as logical   no-undo .
define buffer buf_goods for ub.goods  .
assign p-res = no .
DEFINE BUTTON b-bonus
     LABEL "&Бонусы"
     SIZE 10 BY 1 TOOLTIP "Параметры расчета ретро-бонусов"
     BGCOLOR 8 .
DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-units
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "b-units"
     SIZE 3 BY 1.
DEFINE BUTTON b-units-ord
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "b-units"
     SIZE 3 BY 1.
DEFINE BUTTON b-units-rcv
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "b-units"
     SIZE 3 BY 1.
DEFINE VARIABLE vat-type AS CHARACTER FORMAT "x(8)"
     VIEW-AS COMBO-BOX INNER-LINES 3
     LIST-ITEMS "нет НДС","с НДС","без НДС"
     DROP-DOWN-LIST
     SIZE 10 BY 1 NO-UNDO.
DEFINE VARIABLE fi-cli-base-rate-ord LIKE ext-artic.cli-base-rate
     VIEW-AS FILL-IN
     SIZE 8 BY 1 NO-UNDO.
DEFINE VARIABLE fi-cli-base-rate-rcv LIKE ext-artic.cli-base-rate
     VIEW-AS FILL-IN
     SIZE 8 BY 1 NO-UNDO.
DEFINE VARIABLE fi-unit-cli AS CHARACTER FORMAT "X(3)"
     LABEL "Ед.изм в накладной"
     VIEW-AS FILL-IN
     SIZE 7 BY 1
     FGCOLOR 4 .
DEFINE VARIABLE fi-unit-cli-ord AS CHARACTER FORMAT "X(3)"
     LABEL "Ед.изм в заказе"
     VIEW-AS FILL-IN
     SIZE 7 BY 1
     FGCOLOR 4 .
DEFINE VARIABLE fi-unit-cli-rcv AS CHARACTER FORMAT "X(3)"
     LABEL "Ед.изм в поставке"
     VIEW-AS FILL-IN
     SIZE 7 BY 1
     FGCOLOR 4 .
DEFINE VARIABLE FILL-1 AS CHARACTER FORMAT "X(256)":U
     LABEL "Артикул"
      VIEW-AS TEXT
     SIZE 15.5 BY .67 NO-UNDO.
DEFINE VARIABLE FILL-2 AS CHARACTER FORMAT "X(256)":U
     LABEL "Производитель"
      VIEW-AS TEXT
     SIZE 40 BY .67 NO-UNDO.
DEFINE VARIABLE FILL-3 AS CHARACTER FORMAT "X(256)":U
     LABEL "Наименование"
      VIEW-AS TEXT
     SIZE 65.38 BY .83 NO-UNDO.
DEFINE VARIABLE FILL-bonus AS DECIMAL FORMAT "->>9.99":U INITIAL 0
     LABEL "Бонус %"
     VIEW-AS FILL-IN
     SIZE 13.25 BY 1 TOOLTIP "Бонус - для ценообразования по Контрагенту" NO-UNDO.
DEFINE VARIABLE FILL-cli-base-rate AS DECIMAL FORMAT ">>,>>9.<<<<":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 8 BY 1 TOOLTIP "Коэффициент" NO-UNDO.
DEFINE VARIABLE FILL-prc AS DECIMAL FORMAT "->>9.99":U INITIAL 0
     LABEL "Допустиммый % отклонения от спецификации в большую сторону"
     VIEW-AS FILL-IN
     SIZE 13.25 BY 1 TOOLTIP "Допустиммый % отклонения от суммы спецификации" NO-UNDO.
DEFINE VARIABLE FILL-prc-2 AS DECIMAL FORMAT "->>9.99":U INITIAL 0
     LABEL "Допустиммый % отклонения от спецификации в меньшую сторону"
     VIEW-AS FILL-IN
     SIZE 13.25 BY 1 TOOLTIP "Допустиммый % отклонения от суммы спецификации" NO-UNDO.
DEFINE VARIABLE FILL-price AS DECIMAL FORMAT ">,>>>,>>>,>>9.99":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 21 BY 1 TOOLTIP "Цена поставщика за ед.изм.накладной в валюте договора" NO-UNDO.
DEFINE VARIABLE FILL-qnty AS DECIMAL FORMAT ">>>,>>>,>>9.<<<":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 18.5 BY 1 TOOLTIP "Количество по накладной в едизм Поставщика" NO-UNDO.
DEFINE VARIABLE FILL-unit-base AS CHARACTER FORMAT "X(3)":U
     LABEL "Базовая"
      VIEW-AS TEXT
     SIZE 7 BY .67 TOOLTIP "Единица измерения из карточки товара"
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE FILL-VAT-pc AS DECIMAL FORMAT ">9.9":U INITIAL 0
     LABEL "НДС"
     VIEW-AS FILL-IN
     SIZE 7 BY 1 NO-UNDO.
DEFINE VARIABLE v-price-cli-ord AS DECIMAL FORMAT ">,>>>,>>>,>>9.99":U INITIAL 0
      VIEW-AS TEXT
     SIZE 21 BY .67 TOOLTIP "Цена поставщика за ед.изм. в заказе в валюте договора" NO-UNDO.
DEFINE VARIABLE v-price-cli-rcv AS DECIMAL FORMAT ">,>>>,>>>,>>9.99":U INITIAL 0
      VIEW-AS TEXT
     SIZE 21 BY .67 TOOLTIP "Цена поставщика за ед.изм. в поставке в валюте договора" NO-UNDO.
DEFINE VARIABLE v-qnty-ord AS DECIMAL FORMAT ">>>,>>>,>>9.<<<":U INITIAL 0
      VIEW-AS TEXT
     SIZE 18.5 BY .67 TOOLTIP "Количество в заказе в едизм Поставщика" NO-UNDO.
DEFINE VARIABLE v-qnty-rcv AS DECIMAL FORMAT ">>>,>>>,>>9.<<<":U INITIAL 0
      VIEW-AS TEXT
     SIZE 18.5 BY .67 TOOLTIP "Количество в поставке в едизм Поставщика" NO-UNDO.
DEFINE QUERY Dialog-Frame FOR
      ext-artic SCROLLING.
DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     b-bonus AT ROW 1 COL 21 WIDGET-ID 10
     b-help AT ROW 1 COL 73
     FILL-prc AT ROW 4.5 COL 1
     FILL-prc-2 AT ROW 6 COL 1 WIDGET-ID 74
     FILL-bonus AT ROW 7 COL 1.88 WIDGET-ID 72
     vat-type AT ROW 8.21 COL 14.88 COLON-ALIGNED NO-LABEL
     FILL-VAT-pc AT ROW 8.25 COL 5.13 COLON-ALIGNED
     fi-unit-cli AT ROW 11.92 COL 20.38 COLON-ALIGNED WIDGET-ID 32
     b-units AT ROW 11.92 COL 29.5 WIDGET-ID 30
     FILL-cli-base-rate AT ROW 11.92 COL 30.63 COLON-ALIGNED NO-LABEL
     FILL-price AT ROW 11.92 COL 39.13 COLON-ALIGNED NO-LABEL
     FILL-qnty AT ROW 11.92 COL 61.63 COLON-ALIGNED NO-LABEL
     fi-unit-cli-ord AT ROW 13.04 COL 20.38 COLON-ALIGNED WIDGET-ID 44
     b-units-ord AT ROW 13.04 COL 29.5 WIDGET-ID 40
     fi-cli-base-rate-ord AT ROW 13.04 COL 30.63 COLON-ALIGNED HELP
          "" NO-LABEL WIDGET-ID 42
     fi-unit-cli-rcv AT ROW 14.21 COL 20.38 COLON-ALIGNED WIDGET-ID 54
     b-units-rcv AT ROW 14.21 COL 29.5 WIDGET-ID 50
     fi-cli-base-rate-rcv AT ROW 14.21 COL 30.63 COLON-ALIGNED HELP
          "" NO-LABEL WIDGET-ID 52
     FILL-1 AT ROW 2.21 COL 8.88 COLON-ALIGNED
     FILL-2 AT ROW 2.21 COL 27
     FILL-3 AT ROW 3.42 COL 14.63 COLON-ALIGNED
     FILL-unit-base AT ROW 10.92 COL 20.38 COLON-ALIGNED WIDGET-ID 6
     v-qnty-ord AT ROW 13.13 COL 61.75 COLON-ALIGNED NO-LABEL WIDGET-ID 66
     v-price-cli-ord AT ROW 13.17 COL 39.25 COLON-ALIGNED NO-LABEL WIDGET-ID 64
     v-qnty-rcv AT ROW 14.25 COL 61.75 COLON-ALIGNED NO-LABEL WIDGET-ID 70
     v-price-cli-rcv AT ROW 14.29 COL 39.25 COLON-ALIGNED NO-LABEL WIDGET-ID 68
     "%" VIEW-AS TEXT
          SIZE 1.75 BY .67 AT ROW 8.38 COL 14.63
     "Единицы измерения                      Цена                  Количество" VIEW-AS TEXT
          SIZE 79 BY 1 AT ROW 9.58 COL 3 WIDGET-ID 4
          BGCOLOR 3 FGCOLOR 15
     SPACE(2.12) SKIP(7.54)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Изменение спецификации"
         DEFAULT-BUTTON b-exit CANCEL-BUTTON b-quit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       FILL-unit-base:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-exit IN FRAME Dialog-Frame
DO:
  if p-mode = 'ИЗМЕНЕНИЕ':U then do:
    assign FILL-price FILL-prc FILL-prc-2 vat-type FILL-qnty FILL-vat-pc FILL-cli-base-rate fi-unit-cli  fi-unit-cli-ord fi-unit-cli-rcv fi-cli-base-rate-ord fi-cli-base-rate-rcv  FILL-bonus .
    assign
      p-res   = yes
      p-price = FILL-price
      p-prc   = FILL-prc
      p-prc-2   = FILL-prc-2
      p-vat-type = vat-type
      p-qnty     = FILL-qnty
      p-cli-base-rate = FILL-cli-base-rate
      p-vat-pc = FILL-vat-pc
      p-unit-cli = fi-unit-cli
      p-unit-cli-ord      = fi-unit-cli-ord
      p-unit-cli-rcv      = fi-unit-cli-rcv
      p-cli-base-rate-ord = fi-cli-base-rate-ord
      p-cli-base-rate-rcv = fi-cli-base-rate-rcv
      p-bonus = FILL-bonus
    .
  end.
END.
ON choose OF b-units IN FRAME Dialog-Frame
do:
define variable vss-include-info1 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
  define buffer buf_units for ub.units.
  define variable v-ret-unit-name  as character no-undo .
  define variable v-ret-unit-coeff as decimal no-undo .
  run ref/alt-units.w (input parparentproc,
                       input 'ВЫБОР':U,
                       input p-gds,
                       input "",
                       output v-ret-unit-name,
                       output v-ret-unit-coeff) .
  if v-ret-unit-name > "" then do :
    if can-find (first buf_units where buf_units.unit-name = v-ret-unit-name) then do :
      assign
      fi-unit-cli        = v-ret-unit-name
      FILL-cli-base-rate = v-ret-unit-coeff
      .
      display fi-unit-cli FILL-cli-base-rate with FRAME Dialog-Frame.
      apply "entry":U to FILL-cli-base-rate .
    end .
  end .
  else return no-apply .
end.
ON choose OF b-units-ord IN FRAME Dialog-Frame
do:
define variable vss-include-info2 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
  define buffer buf_units for ub.units.
  define variable ref-rec as recid no-undo.
  run ref/units.w (input parparentproc, input yes, output ref-rec).
  if ref-rec = ? then return no-apply.
  find buf_units where recid (buf_units) = ref-rec no-lock.
  assign fi-unit-cli-ord  = buf_units.unit-name.
  display fi-unit-cli-ord with FRAME Dialog-Frame.
  apply "entry":U to fi-cli-base-rate-ord .
end.
ON choose OF b-units-rcv IN FRAME Dialog-Frame
do:
define variable vss-include-info3 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
  define buffer buf_units for ub.units.
  define variable ref-rec as recid no-undo.
  run ref/units.w (input parparentproc, input yes, output ref-rec).
  if ref-rec = ? then return no-apply.
  find buf_units where recid (buf_units) = ref-rec no-lock.
  assign fi-unit-cli-rcv  = buf_units.unit-name.
  display fi-unit-cli-rcv with FRAME Dialog-Frame.
  apply "entry":U to fi-cli-base-rate-rcv .
end.
ON leave OF fi-unit-cli IN FRAME Dialog-Frame
do:
find ub.units where ub.units.unit-name = input frame Dialog-Frame fi-unit-cli no-lock no-error.
  if not available ub.units then do:
    message "Неправильная единица измерения поставщика." view-as alert-box.
    display fi-unit-cli with FRAME Dialog-Frame.
    apply "choose" to b-units.
    return no-apply.
  end.
  assign frame Dialog-Frame fi-unit-cli.
end.
ON return OF fi-unit-cli IN FRAME Dialog-Frame
do:
  apply "entry" to FILL-cli-base-rate in frame Dialog-Frame.
  return no-apply.
end.
ON leave OF fi-unit-cli-ord IN FRAME Dialog-Frame
do:
  find ub.units where ub.units.unit-name = input frame Dialog-Frame fi-unit-cli-ord no-lock no-error.
  if not available ub.units then do:
    message "Неправильная единица измерения поставщика." view-as alert-box.
    display fi-unit-cli-ord with FRAME Dialog-Frame.
    apply "choose" to b-units-ord.
    return no-apply.
  end.
  assign frame Dialog-Frame fi-unit-cli-ord.
end.
ON return OF fi-unit-cli-ord IN FRAME Dialog-Frame
do:
  apply "entry" to fi-cli-base-rate-ord in frame Dialog-Frame.
  return no-apply.
end.
ON CHOOSE OF b-bonus IN FRAME Dialog-Frame
DO:
   run str\cont-bns.w
     ( input parParentProc,
       input 0,
       input 0,
       input 0,
       input-output p-retro-bonus
       ).
END.
ON leave OF fi-unit-cli-rcv IN FRAME Dialog-Frame
do:
  find ub.units where ub.units.unit-name = input frame Dialog-Frame fi-unit-cli-rcv no-lock no-error.
  if not available ub.units then do:
    message "Неправильная единица измерения поставщика." view-as alert-box.
    display fi-unit-cli-rcv with FRAME Dialog-Frame.
    apply "choose" to b-units-rcv.
    return no-apply.
  end.
  assign frame Dialog-Frame fi-unit-cli-rcv.
end.
ON return OF fi-unit-cli-rcv IN FRAME Dialog-Frame
do:
  apply "entry" to fi-cli-base-rate-rcv in frame Dialog-Frame.
  return no-apply.
end.
ON VALUE-CHANGED OF vat-type IN FRAME Dialog-Frame
DO:
  assign vat-type .
  if vat-type = 'без':U then do:
    assign FILL-vat-pc = 0 .
    DISABLE FILL-VAT-pc WITH FRAME Dialog-Frame.
    display FILL-vat-pc WITH FRAME Dialog-Frame.
  end.
  else do:
    ENABLE FILL-VAT-pc WITH FRAME Dialog-Frame.
    display FILL-vat-pc WITH FRAME Dialog-Frame.
  end.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame Dialog-Frame
do:
  run gbl/app_help.p
    (input this-procedure :file-name
    ,input ''
    ,input ?
    ) no-error.
  if error-status :error then do:
    message
      "Ошибка при вызове помощи"
      error-status :get-message(1)
      view-as alert-box .
  end.
end.
run minbtn-set in this-procedure .
on choose of b-help in frame Dialog-Frame
do:
  apply "help":u to frame Dialog-Frame .
end.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure minbtn-set :
    do
        on error undo, return error return-value
        :
        define variable ii              as integer       no-undo .
        define variable fh              as widget-handle no-undo .
        define variable hh              as widget-handle no-undo .
        define variable v-h             as handle        extent 4 no-undo .
        define variable v-name-button   as character     no-undo .
        define variable v-help-old-x    as decimal       no-undo .
        define variable v-help-old-y    as decimal       no-undo .
        define variable v-help-old-size as decimal       no-undo .
        define variable v-frame-width   as decimal       no-undo .
        define variable jj              as integer       no-undo .
        do
            on error undo, return error
            :
            assign
                v-frame-width = frame Dialog-Frame:width - 0.3
                fh            = frame Dialog-Frame:first-child
                hh            = fh:first-child
                ii            = 1
                .
            do while valid-handle(hh):
                if LOOKUP(lc(hh:name), "b-help,b-print,b-history,b-hist,b-hist-user,b-sch") > 0  then
                do:
                    case lc(hh:name) :
                        when "b-help" then
                            do:
                                hh:load-image-up("cmp/b-help.bmp":u) .
                                hh:load-image-down("cmp/b-help.bmp":u) .
                                hh:load-image-insensitive("cmp/b-help.bmp":u) .
                                hh:TOOLTIP = "Помощь" .
                                v-help-old-x = hh:column .
                                v-help-old-y = hh:row    .
                                v-help-old-size = hh:width .
                                hh:width-chars = 2.5 .
                            end.
                        when "b-print" then
                            do:
                                hh:load-image("cmp/b-print.bmp":u) .
                                hh:TOOLTIP = "Печать" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-history" or
                        when "b-hist" then
                            do:
                                hh:load-image("cmp/b-hist.bmp":u) .
                                hh:TOOLTIP = "История" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-sch" then
                            do:
                                hh:load-image("cmp/b-sch.bmp":u) .
                                hh:TOOLTIP = "Установка Фильтра" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-hist-user" then
                            do:
                                hh:load-image("cmp/b-hist.bmp":u) .
                                hh:TOOLTIP = "История пользователя" .
                                ii = ii + 1 .
                            end.
                    end case.
                end.
                hh = hh:next-sibling.
            end.
            b-help:column = v-frame-width - b-help:width-chars.
            jj = 0.
            repeat ii = 4 to 1 by -1 :
                if valid-handle (v-h[ii] ) then
                do:
                    jj  = jj + 1 .
                    v-h[ii]:column = v-frame-width - b-help:width-chars - ( 3 * jj ).
                    v-h[ii]:row    = v-help-old-y .
                end.
            end.
        end.
    end.
end procedure.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
   VAT-type:LIST-ITEMS in frame Dialog-Frame =  'нет':U + "," + 'в т. ч.':U + "," + 'без':U .
  assign
     FILL-price = p-price
     FILL-prc   = p-prc
     FILL-prc-2   = p-prc-2
     FILL-1     = p-artic
     FILL-2     = p-prod
     FILL-3     = p-NAME
     vat-type   = p-vat-type
     FILL-qnty  = p-qnty
     FILL-cli-base-rate = p-cli-base-rate
     FILL-vat-pc = p-vat-pc
     FILL-bonus = p-bonus
     fi-unit-cli = p-unit-cli
     FILL-unit-base = p-unit-base
     fi-unit-cli-ord = p-unit-cli-ord
     fi-unit-cli-rcv = p-unit-cli-rcv
     fi-cli-base-rate-ord = p-cli-base-rate-ord
     fi-cli-base-rate-rcv = p-cli-base-rate-rcv
  .
  RUN my_enable_UI.
  if vat-type = 'без':U then  DISABLE FILL-VAT-pc WITH FRAME Dialog-Frame.
  WAIT-FOR GO OF FRAME Dialog-Frame FOCUS FILL-price .
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE my_enable_UI :
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info7 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_fin-bonus_work':U
    ,input  'firm':U
    ,input  v-cntxt-host-code-obj
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output g-log
    )  .
end.
  if g-log then enable b-bonus WITH FRAME Dialog-Frame.
  else hide b-bonus in FRAME Dialog-Frame.
  b-units:visible = (p-gds > 0) .
  OPEN QUERY Dialog-Frame FOR EACH ext-artic SHARE-LOCK.
  GET FIRST Dialog-Frame.
  DISPLAY FILL-prc FILL-prc-2 FILL-bonus vat-type FILL-VAT-pc fi-unit-cli
          FILL-cli-base-rate FILL-price FILL-qnty fi-unit-cli-ord
          fi-cli-base-rate-ord fi-unit-cli-rcv fi-cli-base-rate-rcv FILL-1
          FILL-2 FILL-3 FILL-unit-base v-qnty-ord v-price-cli-ord v-qnty-rcv
          v-price-cli-rcv
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-quit b-help FILL-prc FILL-prc-2 FILL-bonus vat-type
         FILL-VAT-pc FILL-cli-base-rate FILL-price
         FILL-qnty
         fi-unit-cli when b-units:visible
         b-units     when b-units:visible
         fi-unit-cli-ord b-units-ord fi-cli-base-rate-ord
         fi-unit-cli-rcv b-units-rcv fi-cli-base-rate-rcv FILL-1 FILL-2 FILL-3
         FILL-unit-base
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE PROC-DISP :
END PROCEDURE.
