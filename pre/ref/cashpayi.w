DEFINE BUFFER buf_currency FOR currency.
DEFINE BUFFER buf_pay-type      FOR pay-type.
DEFINE BUFFER buf_wealth        FOR wealth.
DEFINE BUFFER locked_cash-pay   FOR cash-pay.
DEFINE BUFFER buf_cash-pay-attr FOR ub.cash-pay-attr.
DEFINE TEMP-TABLE tt-cash-pay NO-UNDO LIKE cash-pay.
define input parameter parparentproc as widget-handle no-undo .
define input parameter               par-mode as character no-undo.
define input parameter p-host-code like ub.sysconf.host-code no-undo.
define input parameter p-obj-type like ub.clients.obj-type no-undo.
define input parameter p-obj-code like ub.clients.obj-code no-undo.
define input-output parameter par-ri   as recid no-undo.
define variable vss-revision    as character no-undo init "$Revision: 537a1f69ef2b, 3262, rls $":u .
define variable vss-author      as character no-undo init "$Author: EShklyar $":u .
define variable vss-date        as character no-undo init "$Date: 2023/02/10 14:22:49 $":u .
define variable vss-workfile    as character no-undo init "$Workfile: cashpayi.w $":u .
define variable vss-archive     as character no-undo init "$Archive: ref/cashpayi.w $":u .
define variable vss-description as character no-undo init "Карточка кассового вида платежа" .
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
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
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
define variable is-wth   as logical   no-undo.
define variable conf-par as character no-undo.
define variable par-type as character no-undo.
define variable tcode    like ub.cash-pay.cdpay-code no-undo.
DEFINE BUTTON B-attr
   LABEL "&Атрибуты"
   SIZE 10 BY 1.
DEFINE BUTTON b-curr
   IMAGE-UP FILE "btn-down-arrow":U
   IMAGE-DOWN FILE "btn-down-arrow":U
   IMAGE-INSENSITIVE FILE "btn-down-arrow":U
   LABEL "":L
   SIZE 3 BY 1
   BGCOLOR 8 FGCOLOR 0 .
DEFINE BUTTON B-exit AUTO-GO
   LABEL "&Ввод"
   SIZE 10 BY 1
   BGCOLOR 8 .
DEFINE BUTTON B-Help
   LABEL "Помо&щь"
   SIZE 3 BY 1
   BGCOLOR 8 .
DEFINE BUTTON B-hist
   LABEL "Ис&тория"
   SIZE 3 BY 1.
DEFINE BUTTON b-pay
   IMAGE-UP FILE "btn-down-arrow":U
   IMAGE-DOWN FILE "btn-down-arrow":U
   IMAGE-INSENSITIVE FILE "btn-down-arrow":U
   LABEL "":L
   SIZE 3 BY 1
   BGCOLOR 8 FGCOLOR 0 .
DEFINE BUTTON b-quit AUTO-END-KEY
   LABEL "&Отмена"
   SIZE 10 BY 1
   BGCOLOR 8 .
DEFINE BUTTON b-wealth
   IMAGE-UP FILE "btn-down-arrow":U
   IMAGE-DOWN FILE "btn-down-arrow":U
   IMAGE-INSENSITIVE FILE "btn-down-arrow":U
   LABEL "":L
   SIZE 3 BY 1
   BGCOLOR 8 FGCOLOR 0 .
DEFINE VARIABLE cb-card-type-bank AS CHARACTER FORMAT "X(256)":U
   LABEL "Тип карты"
   VIEW-AS COMBO-BOX INNER-LINES 5
   LIST-ITEM-PAIRS "Сбербанк", "sberbank",
   "ВБРР", "vbrr"
   DROP-DOWN-LIST
   SIZE 16 BY 1 NO-UNDO.
DEFINE VARIABLE cb-card-type      AS CHARACTER FORMAT "X(256)":U
   LABEL "Тип карты"
   VIEW-AS COMBO-BOX INNER-LINES 5
   LIST-ITEM-PAIRS "","off-line",
   "Гамаюн","gamayun",
   "Премиум","premium",
   "Unipos","unipos"
   DROP-DOWN-LIST
   SIZE 16 BY 1 NO-UNDO.
DEFINE VARIABLE cb-prop           AS CHARACTER FORMAT "X(256)":U INITIAL "0"
   LABEL "Тип"
   VIEW-AS COMBO-BOX INNER-LINES 8
   LIST-ITEM-PAIRS "Тип не определен","0",
   "Наличные","1",
   "Наличные (сторонние)","16",
   "Банковская карта","2",
   "Банковская карта оффлайн","3",
   "Топливная карта","4",
   "Талоны","5",
   "QR-код","6",
   "Предоплата (Аванс)","7",
   "Топливные купоны","13",
   "Виртуальная топливная карта","14",
   "Бонусная карта","15",
   "Кошелек Элекснет","17"
   DROP-DOWN-LIST
   SIZE 44.88 BY 1
   BGCOLOR 15 NO-UNDO.
DEFINE VARIABLE cb-type-pay-fr    AS CHARACTER FORMAT "x(200)"
   LABEL "Тип платежа ФР"
   VIEW-AS COMBO-BOX INNER-LINES 7
   LIST-ITEM-PAIRS 'Наличный':U,"1",
                     'Электронный':U,"2",
                     'Аванс':U,"3",
                     'Кредит':U,"4",
                     'Нефискальный платеж':U,"-1"
     DROP-DOWN-LIST
     SIZE 24.5 BY 1 NO-UNDO.
DEFINE VARIABLE for-curr-name     AS CHARACTER FORMAT "X(256)":U
   VIEW-AS TEXT
   SIZE 25.75 BY .67
   FGCOLOR 4 NO-UNDO.
DEFINE VARIABLE for-pay-name      AS CHARACTER FORMAT "X(256)":U
   VIEW-AS TEXT
   SIZE 25.75 BY .67
   FGCOLOR 4 NO-UNDO.
DEFINE VARIABLE for-wth-name      AS CHARACTER FORMAT "X(256)":U
   VIEW-AS TEXT
   SIZE 25.75 BY .67
   FGCOLOR 4 NO-UNDO.
DEFINE RECTANGLE RECT-3
   EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
   SIZE 96.5 BY 17.97.
DEFINE VARIABLE T-can-mix     AS LOGICAL INITIAL no
   LABEL "Разрешена смеш.оплата"
   VIEW-AS TOGGLE-BOX
   SIZE 45 BY .79 NO-UNDO.
DEFINE VARIABLE T-has-overpay AS LOGICAL INITIAL no
   LABEL "Разрешена переплата"
   VIEW-AS TOGGLE-BOX
   SIZE 45 BY .79 NO-UNDO.
DEFINE VARIABLE T-has-return  AS LOGICAL INITIAL no
   LABEL "Разрешен возврат"
   VIEW-AS TOGGLE-BOX
   SIZE 45 BY .79 NO-UNDO.
DEFINE VARIABLE T-kbo         AS LOGICAL INITIAL no
   LABEL "КБО"
   VIEW-AS TOGGLE-BOX
   SIZE 45 BY .79 TOOLTIP "Косвенная безналичная оплата" NO-UNDO.
DEFINE VARIABLE qr-mir AS LOGICAL INITIAL no
     LABEL "QR-мир"
     VIEW-AS TOGGLE-BOX
     SIZE 11.13 BY .83 NO-UNDO.
DEFINE VARIABLE T-lnr         AS LOGICAL INITIAL no
   LABEL "ЛНР"
   VIEW-AS TOGGLE-BOX
   SIZE 45 BY .79 TOOLTIP "Лояльность за наличный расчет" NO-UNDO.
DEFINE VARIABLE T-register    AS LOGICAL INITIAL no
   LABEL "Ведомость"
   VIEW-AS TOGGLE-BOX
   SIZE 45 BY 1.08 NO-UNDO.
DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-attr AT ROW 1 COL 51
     B-hist AT ROW 1 COL 92
     B-Help AT ROW 1 COL 95
     tt-cash-pay.cdpay-code AT ROW 2.25 COL 19 COLON-ALIGNED
          LABEL "Код типа платежа" FORMAT "9999"
          VIEW-AS FILL-IN
          SIZE 11.5 BY 1
     tt-cash-pay.obj-name AT ROW 2.25 COL 45.5 COLON-ALIGNED
          LABEL "Название"
          VIEW-AS FILL-IN
          SIZE 45.38 BY 1
     tt-cash-pay.curr-code AT ROW 3.75 COL 19 COLON-ALIGNED
          LABEL "Код валюты платежа"
          VIEW-AS FILL-IN
          SIZE 3.75 BY .96
     b-curr AT ROW 3.75 COL 26
     cb-type-pay-fr AT ROW 3.75 COL 72.5 COLON-ALIGNED
     tt-cash-pay.pay-code AT ROW 5 COL 9 COLON-ALIGNED
          LABEL "Оплата"
          VIEW-AS FILL-IN
          SIZE 8.13 BY 1
     b-pay AT ROW 5 COL 20
     tt-cash-pay.wth-code AT ROW 5 COL 56 COLON-ALIGNED
          LABEL "Код МЦ"
          VIEW-AS FILL-IN
          SIZE 10.63 BY 1
     b-wealth AT ROW 5 COL 69
     tt-cash-pay.pay-limit AT ROW 6.58 COL 23.63 COLON-ALIGNED
          LABEL "Предел без авторизации"
          VIEW-AS FILL-IN
          SIZE 15.63 BY 1
     cb-prop AT ROW 6.58 COL 48.63 COLON-ALIGNED WIDGET-ID 4
     cb-card-type-bank AT ROW 7.88 COL 48.75 COLON-ALIGNED WIDGET-ID 8
     cb-card-type AT ROW 7.88 COL 48.75 COLON-ALIGNED WIDGET-ID 8
     tt-cash-pay.slip-file-name AT ROW 9.17 COL 17.13 COLON-ALIGNED
          LABEL "Имя файла слипа"
          VIEW-AS FILL-IN
          SIZE 22 BY .96
     tt-cash-pay.rule-file-name AT ROW 9.17 COL 71.63 COLON-ALIGNED
          LABEL "Имя файла правил обработки"
          VIEW-AS FILL-IN
          SIZE 22 BY 1
     tt-cash-pay.is-cash AT ROW 11.5 COL 2.5
          LABEL "Платеж наличными"
          VIEW-AS TOGGLE-BOX
          SIZE 45 BY 1
     tt-cash-pay.atr128 AT ROW 11.5 COL 49
          LABEL "Платеж по топливной карте"
          VIEW-AS TOGGLE-BOX
          SIZE 45 BY 1
     tt-cash-pay.atr1 AT ROW 12.5 COL 2.5
          LABEL "Разрешается сдача и возврат"
          VIEW-AS TOGGLE-BOX
          SIZE 45 BY 1
     tt-cash-pay.is-credit-card AT ROW 12.5 COL 49
          LABEL "Кредитная карта"
          VIEW-AS TOGGLE-BOX
          SIZE 45.38 BY .92
     tt-cash-pay.atr2 AT ROW 13.5 COL 2.5
          LABEL "Разрешен перевод оплаты на платеж"
          VIEW-AS TOGGLE-BOX
          SIZE 45 BY 1
     tt-cash-pay.is-debet-card AT ROW 13.5 COL 49
          LABEL "Расчетная (дебетовая) карта"
          VIEW-AS TOGGLE-BOX
          SIZE 45.38 BY .92
     tt-cash-pay.atr4 AT ROW 14.5 COL 2.5
          LABEL "Принудительная печать слипа по платежу"
          VIEW-AS TOGGLE-BOX
          SIZE 45 BY 1
     tt-cash-pay.is-goods-pay AT ROW 14.5 COL 49
          LABEL "Платеж за товары"
          VIEW-AS TOGGLE-BOX
          SIZE 45.38 BY .92
     tt-cash-pay.atr8 AT ROW 15.5 COL 2.5
          LABEL "Принудительная печать фактуры по платежу"
          VIEW-AS TOGGLE-BOX
          SIZE 45 BY 1
     tt-cash-pay.is-service-pay AT ROW 15.5 COL 49.13
          LABEL "Сервисный платеж"
          VIEW-AS TOGGLE-BOX
          SIZE 45.38 BY .92
     tt-cash-pay.atr16 AT ROW 16.5 COL 2.5
          LABEL "Необходима on-line авторизация"
          VIEW-AS TOGGLE-BOX
          SIZE 45 BY 1
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.
DEFINE FRAME Dialog-Frame
     tt-cash-pay.is-all-pay AT ROW 16.5 COL 49.13
          LABEL "'Общий' платеж"
          VIEW-AS TOGGLE-BOX
          SIZE 45.38 BY .92
     tt-cash-pay.atr32 AT ROW 17.5 COL 2.5
          LABEL "Обязателен ввод PIN-кода"
          VIEW-AS TOGGLE-BOX
          SIZE 45 BY 1
     tt-cash-pay.is-card-swap AT ROW 17.5 COL 49.25
          LABEL "Запрос ввода карты"
          VIEW-AS TOGGLE-BOX
          SIZE 45.38 BY .92
     tt-cash-pay.atr64 AT ROW 18.5 COL 2.5
          LABEL "Топливный платеж"
          VIEW-AS TOGGLE-BOX
          SIZE 45 BY 1
     tt-cash-pay.is-bar-read AT ROW 18.5 COL 49.25
          LABEL "Запрашивать сканирование баркода талона для платежа"
          VIEW-AS TOGGLE-BOX
          SIZE 48.75 BY .92
     tt-cash-pay.is-credit AT ROW 19.5 COL 2.5
          LABEL "Платеж <В кредит>"
          VIEW-AS TOGGLE-BOX
          SIZE 45 BY 1 TOOLTIP "Не кредитная карта!!!!"
     tt-cash-pay.is-advance AT ROW 19.5 COL 49.25
          LABEL "Учет авансового платежа"
          VIEW-AS TOGGLE-BOX
          SIZE 45 BY 1
     T-register AT ROW 20.42 COL 2.5 WIDGET-ID 2
     T-kbo AT ROW 20.5 COL 49.25 WIDGET-ID 4
     T-can-mix AT ROW 21.5 COL 2.5 WIDGET-ID 6
     T-lnr AT ROW 21.5 COL 49.25 WIDGET-ID 8
     T-has-overpay AT ROW 22.42 COL 49.13 WIDGET-ID 12
     T-has-return AT ROW 22.5 COL 2.5 WIDGET-ID 10
     qr-mir AT ROW 23.25 COL 49.13 WIDGET-ID 10
     tt-cash-pay.pay-card-view AT ROW 24.46 COL 1.38
          LABEL "Префиксы N плат.карт для просмотра"
          VIEW-AS FILL-IN
          SIZE 52.25 BY 1 TOOLTIP "Список префикс номеров платежных карт, которые будут видны в BO"
     for-curr-name AT ROW 3.75 COL 28.5 COLON-ALIGNED NO-LABEL
     for-pay-name AT ROW 5 COL 21 COLON-ALIGNED NO-LABEL
     for-wth-name AT ROW 5 COL 70 COLON-ALIGNED NO-LABEL
     "Свойства платежа :" VIEW-AS TEXT
          SIZE 18 BY .75 AT ROW 10.75 COL 38.38
          BGCOLOR 8 FGCOLOR 4
     RECT-3 AT ROW 6.33 COL 1.5
     SPACE(0.99) SKIP(1.32)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Параметры типа кассового платежа"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.
ASSIGN
   FRAME Dialog-Frame:SCROLLABLE = FALSE
   FRAME Dialog-Frame:HIDDEN     = TRUE.
ASSIGN
   cb-card-type:HIDDEN IN FRAME Dialog-Frame = TRUE.
cb-card-type-bank:HIDDEN IN FRAME Dialog-Frame           = TRUE.
assign
       qr-mir:hidden in frame Dialog-Frame = true .
ON GO OF FRAME Dialog-Frame
   DO:
      run proc-save-record in this-procedure No-ERROR.
      if error-status:error then return no-apply.
   END.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
   DO:
      APPLY "END-ERROR":U TO SELF.
   END.
ON CHOOSE OF B-attr IN FRAME Dialog-Frame
   DO:
      run ref/cp-atti.w ( input parparentproc
         ,input 'ПРОСМОТР':U
         ,input tt-cash-pay.cdpay-code
         ,input tt-cash-pay.curr-code
         ,input p-host-code
         ,input p-obj-type
         ,input p-obj-code
         ) NO-ERROR.
   END.
ON CHOOSE OF b-curr IN FRAME Dialog-Frame
   DO:
      define variable rr as recid no-undo.
      rr = ? .
      run ref/currency.w (parparentproc, "b-sel", input-output rr ).
      if rr <> ? then
      do:
         FIND FIRST buf_currency WHERE
            recid( buf_currency ) = rr NO-LOCK .
         DISPLAY
            buf_currency.curr-code @ tt-cash-pay.curr-code
            buf_currency.curr-name @ for-curr-name
            with frame Dialog-Frame .
      end.
   END.
ON CHOOSE OF B-hist IN FRAME Dialog-Frame
   DO:
      define variable rid-list as character no-undo.
      run ref/ccashpay.w (
         input parparentproc
         , INPUT "":U
         , INPUT "one":U
         , OUTPUT  rid-list
         , INPUT tt-cash-pay.cdpay-code
         , INPUT tt-cash-pay.curr-code
         , input "":U
         ) no-error .
   END.
ON CHOOSE OF b-pay IN FRAME Dialog-Frame
   DO:
      DEFINE VARIABLE rr as character no-undo .
      rr = ? .
      run ref/paytype.w (parparentproc,  "b-sel":U, output rr ).
      if rr <> '' then
      do:
         FIND FIRST buf_pay-type WHERE
            recid( buf_pay-type ) = integer(rr) NO-LOCK .
         DISPLAY
            buf_pay-type.obj-code @ tt-cash-pay.pay-code
            buf_pay-type.obj-name @ for-pay-name
            with frame Dialog-Frame .
      end.
   END.
ON CHOOSE OF b-wealth IN FRAME Dialog-Frame
   DO:
      define variable rstr as character no-undo.
      run ref/wth-ref.w (
         input parparentproc
         , input "b-sel":U
         , input p-host-code
         , input p-obj-type
         , input p-obj-code
         , input 'все':U
         , input-output rstr ).
      if rstr <> '':U then
      do:
         FIND FIRST buf_wealth WHERE
            recid(buf_wealth) = integer(entry(1, rstr)) NO-LOCK .
         DISPLAY
            buf_wealth.wth-code @ tt-cash-pay.wth-code
            buf_wealth.wth-name @ for-wth-name
            with frame Dialog-Frame .
      end.
   END.
ON VALUE-CHANGED OF cb-card-type IN FRAME Dialog-Frame
   DO:
      assign
         cb-card-type.
   END.
ON VALUE-CHANGED OF cb-card-type-bank IN FRAME Dialog-Frame
   DO:
      assign
         cb-card-type-bank.
   END.
ON VALUE-CHANGED OF cb-type-pay-fr IN FRAME Dialog-Frame
   DO:
      assign
         cb-type-pay-fr.
   END.
ON VALUE-CHANGED OF cb-prop IN FRAME Dialog-Frame
   DO:
      assign cb-prop .
      if cb-prop = "4" then
      do:
         enable
            cb-card-type
            with frame Dialog-Frame
            .
         APPLY "value-change" to cb-card-type in FRAME Dialog-Frame .
      end.
      else
      do:
         HIDE
            cb-card-type
            in frame Dialog-Frame .
      end.
      if cb-prop = "2" or cb-prop = "3" then
      do:
         enable
            cb-card-type-bank
            with frame Dialog-Frame
            .
         APPLY "value-change" to cb-card-type-bank in FRAME Dialog-Frame .
      end.
      else
      do:
         HIDE
            cb-card-type-bank
            in frame Dialog-Frame .
      end.
     if cb-prop = "2" then
     do:
       enable
         qr-mir
         with frame Dialog-Frame
         .
         APPLY "value-change" to qr-mir in FRAME Dialog-Frame .
     end.
     else
     do:
       qr-mir = false .
       HIDE
         qr-mir
         in frame Dialog-Frame .
     end.
   END.
ON VALUE-CHANGED OF cb-type-pay-fr IN FRAME Dialog-Frame
   DO:
      assign
         cb-type-pay-fr.
   END.
ON LEAVE OF tt-cash-pay.cdpay-code IN FRAME Dialog-Frame
   DO:
   END.
ON LEAVE OF tt-cash-pay.curr-code IN FRAME Dialog-Frame
   DO:
      FIND FIRST buf_currency NO-LOCK WHERE
         buf_currency.curr-code = INPUT FRAME Dialog-Frame tt-cash-pay.curr-code NO-ERROR.
      IF AVAIL buf_currency THEN
      DO:
         DISPLAY
            buf_currency.curr-name @ for-curr-name
            WITH FRAME Dialog-Frame.
      END.
   END.
ON LEAVE OF tt-cash-pay.pay-code IN FRAME Dialog-Frame
   DO:
      FIND FIRST buf_pay-type NO-LOCK WHERE
         buf_pay-type.obj-code = INPUT FRAME Dialog-Frame tt-cash-pay.pay-code NO-ERROR.
      IF AVAIL buf_pay-type THEN
      DO:
         DISPLAY
            buf_pay-type.obj-name @ for-pay-name
            WITH FRAME Dialog-Frame.
      END.
   END.
ON VALUE-CHANGED OF qr-mir IN FRAME Dialog-Frame
DO:
  assign qr-mir.
END.
ON LEAVE OF tt-cash-pay.wth-code IN FRAME Dialog-Frame
   DO:
      FIND FIRST buf_wealth NO-LOCK WHERE
         buf_wealth.wth-code = INPUT FRAME Dialog-Frame tt-cash-pay.wth-code NO-ERROR.
      IF AVAIL buf_wealth THEN
      DO:
         DISPLAY
            buf_wealth.wth-name @ for-wth-name
            WITH FRAME Dialog-Frame.
      END.
   END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
   THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
   if par-mode <> 'ИЗМЕНЕНИЕ':U and par-mode <> 'ДОБАВЛЕНИЕ':U and par-mode <> 'ПРОСМОТР':U then
   do:
      message vss-workfile vss-revision vss-description skip
         "Неверный параметр вызова par-mode"
         view-as alert-box ERROR.
      return error.
   end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-wth'
  ,input  0
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  yes
  ,output conf-par
  ,output par-type
  ) no-error .
   IF not error-status:error then
      assign
         is-wth = (conf-par = "yes":U).
   Run fill-tables in this-procedure no-error.
   if error-status:error then return error.
   RUN Myenable.
   WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
   HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
   DISPLAY cb-type-pay-fr cb-prop T-register T-kbo T-can-mix T-lnr T-has-return
      T-has-overpay for-curr-name for-pay-name for-wth-name qr-mir
      WITH FRAME Dialog-Frame.
   IF AVAILABLE tt-cash-pay THEN
      DISPLAY tt-cash-pay.cdpay-code tt-cash-pay.obj-name tt-cash-pay.curr-code
         tt-cash-pay.pay-code tt-cash-pay.wth-code tt-cash-pay.pay-limit
         tt-cash-pay.slip-file-name tt-cash-pay.rule-file-name
         tt-cash-pay.is-cash tt-cash-pay.atr128 tt-cash-pay.atr1
         tt-cash-pay.is-credit-card tt-cash-pay.atr2 tt-cash-pay.is-debet-card
         tt-cash-pay.atr4 tt-cash-pay.is-goods-pay tt-cash-pay.atr8
         tt-cash-pay.is-service-pay tt-cash-pay.atr16 tt-cash-pay.is-all-pay
         tt-cash-pay.atr32 tt-cash-pay.is-card-swap tt-cash-pay.atr64
         tt-cash-pay.is-bar-read tt-cash-pay.is-credit tt-cash-pay.is-advance
         tt-cash-pay.pay-card-view
         WITH FRAME Dialog-Frame.
   ENABLE B-exit b-quit B-attr B-hist B-Help RECT-3 tt-cash-pay.cdpay-code
      tt-cash-pay.obj-name tt-cash-pay.curr-code b-curr cb-type-pay-fr
      tt-cash-pay.pay-code b-pay tt-cash-pay.wth-code b-wealth
      tt-cash-pay.pay-limit cb-prop tt-cash-pay.slip-file-name
      tt-cash-pay.rule-file-name tt-cash-pay.is-cash tt-cash-pay.atr128
      tt-cash-pay.atr1 tt-cash-pay.is-credit-card tt-cash-pay.atr2
      tt-cash-pay.is-debet-card tt-cash-pay.atr4 tt-cash-pay.is-goods-pay
      tt-cash-pay.atr8 tt-cash-pay.is-service-pay tt-cash-pay.atr16
      tt-cash-pay.is-all-pay tt-cash-pay.atr32 tt-cash-pay.is-card-swap
      tt-cash-pay.atr64 tt-cash-pay.is-bar-read tt-cash-pay.is-credit
      tt-cash-pay.is-advance T-register T-kbo T-can-mix T-lnr T-has-return
      T-has-overpay tt-cash-pay.pay-card-view for-curr-name for-pay-name
      for-wth-name qr-mir
      WITH FRAME Dialog-Frame.
   VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE fill-tables :
   for each tt-cash-pay:
      delete tt-cash-pay.
   end.
   VIEW FRAME Dialog-Frame.
   IF par-mode = 'ДОБАВЛЕНИЕ':U then
   do:
      FIND LAST ub.cash-pay NO-LOCK  use-index pi NO-ERROR .
      if available ub.cash-pay then
         tcode = ub.cash-pay.cdpay-code + 1.
      else
         tcode = 1.
      DO TRANSACTION ON ERROR UNDO, RETURN ERROR:
         create tt-cash-pay.
         assign
            tt-cash-pay.cdpay-code = tcode
            .
      END.
   end.
   else
   do:
      if par-mode = 'ПРОСМОТР':U then
      do:
         FIND FIRST locked_cash-pay NO-LOCK WHERE
            recid(locked_cash-pay) = par-ri.
      end.
      ELSE
      do:
         DO TRANSACTION
            ON ERROR UNDO, RETURN ERROR:
            FIND FIRST locked_cash-pay EXCLUSIVE-LOCK WHERE
               recid(locked_cash-pay) = par-ri.
         END.
      END.
      IF NOT AVAIL locked_cash-pay then
         return error.
      create tt-cash-pay.
      buffer-copy locked_cash-pay to tt-cash-pay.
      FIND FIRST buf_currency No-LOCK WHERe
         buf_currency.curr-code = tt-cash-pay.curr-code No-ERROR.
      if not avail buf_currency then
      do:
         message "Тип кассового платежа" locked_cash-pay.cdpay-code  skip
            "Неверная валюта" locked_cash-pay.curr-code
            view-as alert-box ERROR.
         return error.
      end.
      FIND FIRST buf_pay-type No-LOCK WHERe
         buf_pay-type.obj-code = tt-cash-pay.pay-code No-ERROR.
      if not avail buf_pay-type then
      do:
         message "Тип кассового платежа" locked_cash-pay.cdpay-code  skip
            "Неверная оплата" locked_cash-pay.pay-code
            view-as alert-box ERROR.
         return error.
      end.
      if tt-cash-pay.wth-code > 0 then
      do:
         FIND FIRST buf_wealth No-LOCK WHERe
            buf_wealth.wth-code = tt-cash-pay.wth-code No-ERROR.
         if not avail buf_wealth then
         do:
            message "Тип кассового платежа" locked_cash-pay.cdpay-code  skip
               "Неверный код МЦ" locked_cash-pay.wth-code
               view-as alert-box ERROR.
            return error.
         end.
      end.
   end.
   find first buf_cash-pay-attr where buf_cash-pay-attr.cdpay-code = tt-cash-pay.cdpay-code
      and buf_cash-pay-attr.curr-code = tt-cash-pay.curr-code
      and buf_cash-pay-attr.attr-code = "cash-prop" no-error .
   if AVAILABLE buf_cash-pay-attr then
   do:
      cb-prop = buf_cash-pay-attr.attr-value .
   end.
   find first buf_cash-pay-attr where buf_cash-pay-attr.cdpay-code = tt-cash-pay.cdpay-code
      and buf_cash-pay-attr.curr-code = tt-cash-pay.curr-code
      and buf_cash-pay-attr.attr-code = "cash-card-type" no-error .
   if AVAILABLE buf_cash-pay-attr then
   do:
      cb-card-type = buf_cash-pay-attr.attr-value .
   end.
   find first buf_cash-pay-attr where buf_cash-pay-attr.cdpay-code = tt-cash-pay.cdpay-code
      and buf_cash-pay-attr.curr-code = tt-cash-pay.curr-code
      and buf_cash-pay-attr.attr-code = "cash-card-type-bank" no-error .
   if AVAILABLE buf_cash-pay-attr then
   do:
      cb-card-type-bank = buf_cash-pay-attr.attr-value .
   end.
   find first buf_cash-pay-attr where buf_cash-pay-attr.cdpay-code = tt-cash-pay.cdpay-code
      and buf_cash-pay-attr.curr-code = tt-cash-pay.curr-code
      and buf_cash-pay-attr.attr-code = "cash-type-pay-fr" no-error .
   if AVAILABLE buf_cash-pay-attr then
   do:
      cb-type-pay-fr = buf_cash-pay-attr.attr-value .
   end.
   find first buf_cash-pay-attr where buf_cash-pay-attr.cdpay-code = tt-cash-pay.cdpay-code
                                 and buf_cash-pay-attr.curr-code = tt-cash-pay.curr-code
                                 and buf_cash-pay-attr.attr-code = "qr-mir" no-error .
    if AVAILABLE buf_cash-pay-attr then do:
    qr-mir = logical(buf_cash-pay-attr.attr-value) .
    end.
END PROCEDURE.
PROCEDURE Myenable :
   DISPLAY
      for-curr-name
      for-pay-name
      for-wth-name
      WITH FRAME Dialog-Frame.
   IF AVAILABLE tt-cash-pay THEN
   DO:
      ASSIGN
         t-register    = (tt-cash-pay.register > 0)
         t-kbo         = (tt-cash-pay.is-kbo > 0)
         t-lnr         = (tt-cash-pay.is-lnr > 0)
         t-can-mix     = (tt-cash-pay.can-mix > 0)
         t-has-return  = (tt-cash-pay.has-return > 0)
         t-has-overpay = (tt-cash-pay.has-overpay > 0)
         .
      DISPLAY
         tt-cash-pay.cdpay-code
         tt-cash-pay.obj-name
         tt-cash-pay.curr-code
         tt-cash-pay.pay-code
         tt-cash-pay.wth-code
         tt-cash-pay.pay-limit
         tt-cash-pay.is-cash
         tt-cash-pay.atr1
         tt-cash-pay.atr2
         tt-cash-pay.atr4
         tt-cash-pay.atr8
         tt-cash-pay.atr16
         tt-cash-pay.atr32
         tt-cash-pay.atr64
         tt-cash-pay.atr128
         tt-cash-pay.is-debet-card
         tt-cash-pay.is-advance
         tt-cash-pay.is-credit
         tt-cash-pay.is-credit-card
         tt-cash-pay.pay-card-view
         tt-cash-pay.is-all-pay
         tt-cash-pay.is-bar-read
         tt-cash-pay.is-card-swap
         tt-cash-pay.is-goods-pay
         tt-cash-pay.is-service-pay
         tt-cash-pay.rule-file-name
         tt-cash-pay.slip-file-name
         t-register
         cb-prop
         t-kbo
         t-lnr
         t-can-mix
         t-has-return
         t-has-overpay
         cb-type-pay-fr
         WITH FRAME Dialog-Frame.
   END.
   if cb-prop = "4" then
   do:
      display cb-card-type
         WITH FRAME Dialog-Frame.
   end.
   if cb-prop = "2" or cb-prop = "3" then
   do:
      display cb-card-type-bank
         WITH FRAME Dialog-Frame.
   end.
   if cb-prop = "2" then
   do:
      display qr-mir
         WITH FRAME Dialog-Frame.
   end.
   if available buf_currency then
      display
         buf_currency.curr-name @ for-curr-name
         WITH FRAME Dialog-Frame.
   if available buf_pay-type then
      display
         buf_pay-type.obj-name @ for-pay-name
         WITH FRAME Dialog-Frame.
   if available buf_wealth then
      display
         buf_wealth.wth-name @ for-wth-name
         WITH FRAME Dialog-Frame.
   CASE par-mode:
      when 'ДОБАВЛЕНИЕ':U then
         do:
            ENABLE
               B-exit
               tt-cash-pay.cdpay-code
               tt-cash-pay.obj-name
               b-curr
               tt-cash-pay.curr-code
               tt-cash-pay.pay-code
               b-pay
               tt-cash-pay.wth-code
               b-wealth
               tt-cash-pay.pay-limit
               tt-cash-pay.is-cash
               tt-cash-pay.atr1
               tt-cash-pay.atr2
               tt-cash-pay.atr4
               tt-cash-pay.atr8
               tt-cash-pay.atr16
               tt-cash-pay.atr32
               tt-cash-pay.atr64
               tt-cash-pay.atr128
               tt-cash-pay.is-advance
               tt-cash-pay.is-debet-card
               tt-cash-pay.is-credit
               tt-cash-pay.is-credit-card
               tt-cash-pay.pay-card-view
               tt-cash-pay.is-all-pay
               tt-cash-pay.is-bar-read
               tt-cash-pay.is-card-swap
               tt-cash-pay.is-goods-pay
               tt-cash-pay.is-service-pay
               tt-cash-pay.rule-file-name
               tt-cash-pay.slip-file-name
               t-register
               cb-prop
               t-kbo
               t-lnr
               t-can-mix
               t-has-return
               t-has-overpay
               cb-type-pay-fr
               WITH FRAME Dialog-Frame.
            if cb-prop = "4" then
            do:
               enable cb-card-type with frame Dialog-Frame .
            end.
            if cb-prop = "2" or cb-prop = "3" then
            do:
               enable cb-card-type-bank with frame Dialog-Frame .
            end.
           if cb-prop = "2" then
           do:
             display qr-mir
               WITH FRAME Dialog-Frame.
           end.
         end.
      when 'ИЗМЕНЕНИЕ':U then
         do:
            find first ub.db No-LOCK where ub.db.db-num > 0 No-ERROR.
            if not avail ub.db then
            do:
               FIND FIRST ub.chk-pay No-LOCK WHERE
                  ub.chk-pay.pay-code = tt-cash-pay.cdpay-code  AND
                  ub.chk-pay.curr-code = tt-cash-pay.curr-code No-ERROR.
            end.
            ENABLE
               B-exit
               tt-cash-pay.cdpay-code
               when (not available ub.db and not available chk-pay)
               tt-cash-pay.curr-code
               when (not available ub.db and not available chk-pay)
               tt-cash-pay.obj-name
               tt-cash-pay.pay-code
               b-pay
               b-hist
               tt-cash-pay.wth-code
               b-wealth
               tt-cash-pay.pay-limit
               tt-cash-pay.is-cash
               tt-cash-pay.atr1
               tt-cash-pay.atr2
               tt-cash-pay.atr4
               tt-cash-pay.atr8
               tt-cash-pay.atr16
               tt-cash-pay.atr32
               tt-cash-pay.atr64
               tt-cash-pay.atr128
               tt-cash-pay.is-advance
               tt-cash-pay.is-debet-card
               tt-cash-pay.is-credit
               tt-cash-pay.is-credit-card
               tt-cash-pay.pay-card-view
               tt-cash-pay.is-all-pay
               tt-cash-pay.is-bar-read
               tt-cash-pay.is-card-swap
               tt-cash-pay.is-goods-pay
               tt-cash-pay.is-service-pay
               tt-cash-pay.rule-file-name
               tt-cash-pay.slip-file-name
               t-register
               cb-prop
               t-kbo
               t-lnr
               t-can-mix
               t-has-return
               t-has-overpay
               cb-type-pay-fr
               WITH FRAME Dialog-Frame.
            if cb-prop = "4" then
            do:
               enable cb-card-type with frame Dialog-Frame .
            end.
            if cb-prop = "2" or cb-prop = "3" then
            do:
               enable cb-card-type-bank with frame Dialog-Frame .
            end.
            if cb-prop = "2" then do:
               enable
                 qr-mir with frame Dialog-Frame .
            end.
         end.
      when 'ПРОСМОТР':U then
         do:
            assign
               b-quit:label = "&Выход".
            HIDE
               b-exit in frame Dialog-Frame.
         end.
   END CASE.
   ENABLE
      RECT-3
      b-quit
      B-Help
      b-attr
      WHEN par-mode <> 'ДОБАВЛЕНИЕ':U
      WITH FRAME Dialog-Frame.
   VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE proc-save-record :
   IF par-mode = 'ПРОСМОТР':U THEN
   DO:
      RETURN error.
   END.
   assign
      tt-cash-pay.cdpay-code frame Dialog-Frame
      tt-cash-pay.obj-name
      tt-cash-pay.curr-code
      tt-cash-pay.pay-code
      tt-cash-pay.wth-code
      tt-cash-pay.pay-limit
      tt-cash-pay.is-cash
      tt-cash-pay.atr1
      tt-cash-pay.atr2
      tt-cash-pay.atr4
      tt-cash-pay.atr8
      tt-cash-pay.atr16
      tt-cash-pay.atr32
      tt-cash-pay.atr64
      tt-cash-pay.atr128
      tt-cash-pay.pay-card-view
      tt-cash-pay.is-debet-card
      tt-cash-pay.is-advance
      tt-cash-pay.is-credit
      tt-cash-pay.is-credit-card
      tt-cash-pay.is-all-pay
      tt-cash-pay.is-bar-read
      tt-cash-pay.is-card-swap
      tt-cash-pay.is-goods-pay
      tt-cash-pay.is-service-pay
      tt-cash-pay.rule-file-name
      tt-cash-pay.slip-file-name
      t-register
      tt-cash-pay.register    = (IF t-register THEN 1 ELSE 0)
      cb-prop
      cb-card-type-bank
      cb-card-type
      cb-type-pay-fr
      t-kbo
      tt-cash-pay.is-kbo      = (IF t-kbo THEN 1 ELSE 0)
      t-lnr
      tt-cash-pay.is-lnr      = (IF t-lnr THEN 1 ELSE 0)
      t-has-return
      tt-cash-pay.has-return  = (IF t-has-return THEN 1 ELSE 0)
      t-has-overpay
      tt-cash-pay.has-overpay = (IF t-has-overpay THEN 1 ELSE 0)
      t-can-mix
      tt-cash-pay.can-mix     = (IF t-can-mix THEN 1 ELSE 0)
      .
   if par-mode <> 'ДОБАВЛЕНИЕ':U then
      par-ri = recid(locked_cash-pay).
   else par-ri = ?.
   run ref/cashpay1.p (
      input parparentproc
      ,input no
      ,input-output par-ri
      ,input        par-mode
      ,input tt-cash-pay.cdpay-code
      ,input tt-cash-pay.obj-name
      ,input tt-cash-pay.curr-code
      ,input tt-cash-pay.pay-code
      ,input tt-cash-pay.wth-code
      ,input tt-cash-pay.pay-limit
      ,input tt-cash-pay.is-cash
      ,input tt-cash-pay.atr1
      ,input tt-cash-pay.atr2
      ,input tt-cash-pay.atr4
      ,input tt-cash-pay.atr8
      ,input tt-cash-pay.atr16
      ,input tt-cash-pay.atr32
      ,input tt-cash-pay.atr64
      ,input tt-cash-pay.atr128
      ,input tt-cash-pay.pay-card-view
      ,input tt-cash-pay.is-advance
      ,input tt-cash-pay.is-credit
      ,input tt-cash-pay.is-credit-card
      ,input tt-cash-pay.is-debet-card
      ,input tt-cash-pay.is-all-pay
      ,input tt-cash-pay.is-bar-read
      ,input tt-cash-pay.is-card-swap
      ,input tt-cash-pay.is-goods-pay
      ,input tt-cash-pay.is-service-pay
      ,input tt-cash-pay.is-kbo
      ,input tt-cash-pay.is-lnr
      ,input tt-cash-pay.can-mix
      ,input tt-cash-pay.has-return
      ,input tt-cash-pay.has-overpay
      ,input tt-cash-pay.rule-file-name
      ,input tt-cash-pay.slip-file-name
      ,input tt-cash-pay.register
      ) no-error .
   IF ERROR-STATUS:ERROR THEN
   DO:
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable fh as widget-handle no-undo .
define variable hh as widget-handle no-undo .
define variable rv as character no-undo .
assign
rv = entry(1, return-value , chr(4)).
if rv <> "":U then do:
  assign
  fh = frame Dialog-Frame:first-child
  hh = fh:first-child
  .
  do while valid-handle(hh):
    if hh:name = rv then do:
      APPLY "ENTRY" to hh.
      undo ,
      return error.
    end.
    hh = hh:next-sibling.
  end.
end.
      undo, return error.
   END.
   find first buf_cash-pay-attr where
      buf_cash-pay-attr.cdpay-code = tt-cash-pay.cdpay-code
      and buf_cash-pay-attr.curr-code = tt-cash-pay.curr-code
      and buf_cash-pay-attr.attr-code = "cash-prop" no-error .
   if not AVAILABLE buf_cash-pay-attr then
   do:
      create buf_cash-pay-attr .
      assign
         buf_cash-pay-attr.cdpay-code = tt-cash-pay.cdpay-code
         buf_cash-pay-attr.curr-code  = tt-cash-pay.curr-code
         buf_cash-pay-attr.attr-code  = "cash-prop"
         buf_cash-pay-attr.attr-value = cb-prop
         .
   end.
   else
   do:
      buf_cash-pay-attr.attr-value = cb-prop .
   end.
   find first buf_cash-pay-attr where
      buf_cash-pay-attr.cdpay-code = tt-cash-pay.cdpay-code
      and buf_cash-pay-attr.curr-code = tt-cash-pay.curr-code
      and buf_cash-pay-attr.attr-code = "cash-type-pay-fr" no-error .
   if not AVAILABLE buf_cash-pay-attr then
   do:
      create buf_cash-pay-attr .
      assign
         buf_cash-pay-attr.cdpay-code = tt-cash-pay.cdpay-code
         buf_cash-pay-attr.curr-code  = tt-cash-pay.curr-code
         buf_cash-pay-attr.attr-code  = "cash-type-pay-fr"
         buf_cash-pay-attr.attr-value = cb-type-pay-fr
         .
   end.
   else
   do:
      buf_cash-pay-attr.attr-value = cb-type-pay-fr .
   end.
   find first buf_cash-pay-attr where buf_cash-pay-attr.cdpay-code = tt-cash-pay.cdpay-code
      and buf_cash-pay-attr.curr-code = tt-cash-pay.curr-code
      and buf_cash-pay-attr.attr-code = "cash-card-type" no-error .
   if not AVAILABLE buf_cash-pay-attr then
   do:
      if cb-prop = "4" then
      do:
         create buf_cash-pay-attr .
         assign
            buf_cash-pay-attr.cdpay-code = tt-cash-pay.cdpay-code
            buf_cash-pay-attr.curr-code  = tt-cash-pay.curr-code
            buf_cash-pay-attr.attr-code  = "cash-card-type"
            buf_cash-pay-attr.attr-value = cb-card-type
            .
      end.
      else
      do:
         cb-card-type = "" .
      end.
   end.
   else
   do:
      if cb-prop = "4" then
      do:
         buf_cash-pay-attr.attr-value = cb-card-type .
      end.
      else
      do:
         delete buf_cash-pay-attr .
         cb-card-type = "" .
      end.
   end.
   find first buf_cash-pay-attr where buf_cash-pay-attr.cdpay-code = tt-cash-pay.cdpay-code
      and buf_cash-pay-attr.curr-code = tt-cash-pay.curr-code
      and buf_cash-pay-attr.attr-code = "cash-card-type-bank" no-error .
   if not AVAILABLE buf_cash-pay-attr then
   do:
      if cb-prop = "2" or cb-prop = "3" then
      do:
         create buf_cash-pay-attr .
         assign
            buf_cash-pay-attr.cdpay-code = tt-cash-pay.cdpay-code
            buf_cash-pay-attr.curr-code  = tt-cash-pay.curr-code
            buf_cash-pay-attr.attr-code  = "cash-card-type-bank"
            buf_cash-pay-attr.attr-value = cb-card-type-bank
            .
      end.
      else
      do:
         cb-card-type-bank = "" .
      end.
   end.
   else
   do:
      if cb-prop = "2" or cb-prop = "3" then
      do:
         buf_cash-pay-attr.attr-value = cb-card-type-bank .
      end.
      else
      do:
         delete buf_cash-pay-attr .
         cb-card-type-bank = "" .
      end.
   end.
   find first buf_cash-pay-attr where
      buf_cash-pay-attr.cdpay-code = tt-cash-pay.cdpay-code
      and buf_cash-pay-attr.curr-code = tt-cash-pay.curr-code
      and buf_cash-pay-attr.attr-code = "cash-type-pay-fr" no-error .
   if not AVAILABLE buf_cash-pay-attr then
   do:
      create buf_cash-pay-attr .
      assign
         buf_cash-pay-attr.cdpay-code = tt-cash-pay.cdpay-code
         buf_cash-pay-attr.curr-code  = tt-cash-pay.curr-code
         buf_cash-pay-attr.attr-code  = "cash-type-pay-fr"
         buf_cash-pay-attr.attr-value = cb-type-pay-fr
         .
   end.
   else
   do:
      buf_cash-pay-attr.attr-value = cb-type-pay-fr .
   end.
     find first buf_cash-pay-attr where
        buf_cash-pay-attr.cdpay-code = tt-cash-pay.cdpay-code
    and buf_cash-pay-attr.curr-code = tt-cash-pay.curr-code
    and buf_cash-pay-attr.attr-code = "qr-mir" no-error .
  if not AVAILABLE buf_cash-pay-attr then
  do:
    create buf_cash-pay-attr .
    assign
      buf_cash-pay-attr.cdpay-code = tt-cash-pay.cdpay-code
      buf_cash-pay-attr.curr-code  = tt-cash-pay.curr-code
      buf_cash-pay-attr.attr-code  = "qr-mir"
      buf_cash-pay-attr.attr-value = string(qr-mir)
      .
  end.
  else
  do:
    buf_cash-pay-attr.attr-value = string(qr-mir) .
  end.
END PROCEDURE.
