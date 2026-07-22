block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: dctypei1.p $
$Archive: ref/dctypei1.p $

Сохранение изменений в карточке типа дисконтной карты

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/09/05
Author: Bakhtadze Natalya
Creation date: 12/09/05

*/

/*
Мастеръ Гамбсъ этимъ полукресломъ
начинаетъ новую партiю мебели.
1865 г.
Санктъ-Петербургъ.

ОТДЕЛЕНИЕ БИЗНЕС-ЛОГИКИ ОТ ИНТЕРФЕЙСА!!!!!

*/

define temp-table tt0-root-dis-card-type no-undo like ub.dis-card-type.
define temp-table tt0-dis-dct-rule no-undo like ub.dis-dct-rule.
define temp-table tt0-hist-nws-option no-undo like ub.hist-nws-option.
define temp-table tt0-rp-by-call no-undo like ub.rp-by-call.
define temp-table tt0-rule-by-call no-undo like ub.rule-by-call.
define temp-table tt0-rule-call-param no-undo like ub.rule-call-param.

define input-output parameter par-rid as recid no-undo .
define input parameter par-mode as character no-undo .

define input parameter p-emitent-host-code like ub.dis-card-type.emitent-host-code no-undo .
define input parameter p-type like ub.dis-card-type.type no-undo .
define input parameter p-uniq-key-rec as character no-undo .
define input parameter parhost-code like ub.dis-card-type.host-code no-undo .
define input parameter parobj-type like ub.dis-card-type.obj-type no-undo .
define input parameter parobj-code like ub.dis-card-type.obj-code no-undo .
define input parameter pard-pcnt-byshop  like ub.dis-card-type.d-pcnt-byshop no-undo .
define input parameter pardflt-d-pcnt-method like ub.dis-card-type.dflt-d-pcnt-method no-undo .
define input parameter pardflt-credit-card like ub.dis-card-type.dflt-credit-card no-undo .
define input parameter parlim-kr like ub.dis-card-type.lim-kr no-undo .
define input parameter pardflt-debet-card like  ub.dis-card-type.dflt-debet-card  no-undo .
define input parameter pardflt-staff-card like  ub.dis-card-type.dflt-staff-card  no-undo .
define input parameter parfiscal-pay      like  ub.dis-card-type.fiscal-pay       no-undo .
define input parameter parmixed-pay       like  ub.dis-card-type.mixed-pay        no-undo .
define input parameter parpay-code        like  ub.dis-card-type.pay-code         no-undo .
define input parameter parcard-media      like  ub.dis-card-type.card-media       no-undo .
define input parameter parcardname-sent   like  ub.dis-card-type.cardname-sent    no-undo .
define input parameter parcustom-sent     like  ub.dis-card-type.custom-sent      no-undo .
define input parameter pardcbyshop like ub.dis-card-type.dcbyshop no-undo .
define input parameter pardc-pfx like ub.dis-card-type.dc-pfx no-undo .
define input parameter parcheck-by-mask    as logical no-undo .
define input parameter parho-join          as logical no-undo .
/*привязка масок к фирмам объектам*/
define input parameter table for tt0-dis-dct-rule.
define input parameter table for tt0-hist-nws-option.
define input parameter table for tt0-rp-by-call.
define input parameter table for tt0-rule-by-call.
define input parameter table for tt0-rule-call-param.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: dctypei1.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/dctypei1.p $":U .
define variable vss-description as character no-undo init "Сохранение изменений в карточке типа дисконтной карты".
{ cmp/vssrevis.i }

{ cmp/trg-def.i }
{ cmp/library.i }
{ gbl/1bascur.i }
{ ref/chdctmsk.i }
{ gbl/key-rec.i }
{ gbl/dct-algo.i }

&glob add-dump ~
run add-dump in v-cmd-proc-handle                                                                            ~
  (input v-cmd-code                                                                                          ~
  ,input ~{&table__~}                                                                                        ~
  ,input ~{&action__~}                                                                                       ~
  ,input ~{&buffer-handle~}                                                                                  ~
  ,input '':U                                                                                                ~
  ,output v-rec-ord                                                                                          ~
  ) no-error .                                                                                               ~
if error-status :error                                                                                       ~
then do:                                                                                                     ~
delete procedure v-cmd-proc-handle .                                                                         ~
  undo _main, return error substitute("&1 &2 &3&4Ошибка при добавлении записи &5 в команду с кодом &6&4&8&4&9&4" ~
                                      ,vss-workfile                                                          ~
                                      ,vss-revision                                                          ~
                                      ,vss-description                                                       ~
                                      ,~{&new-line~}                                                         ~
                                      ,~{&table__~}                                                          ~
                                      ,v-cmd-code                                                            ~
                                      ,error-status:get-message(1)                                           ~
                                      ,return-value                                                          ~
                                      ) .                                                                    ~
end


DEFINE VARIABLE loc#log as logical no-undo .
DEFINE VARIABLE VAR-ENTRY as character no-undo .
DEFINE VARIABLE jj as integer no-undo .
define variable v-r-b-code like ub.currency.curr-code.
define variable v-curr-r-b as character no-undo .
define variable v-glob-curr-code like ub.currency.curr-code no-undo .
define variable glob-val as logical no-undo .
define variable vardeleted   as logical   no-undo.
define variable conf-par as character no-undo .
define variable par-type as character no-undo .
define variable v-ok as logical no-undo .
define variable v-cmd-code as integer no-undo .
define variable v-cmd-proc-handle as handle no-undo .
define variable v-command as character no-undo .
define variable v-cmp as logical no-undo .
define variable v-cmp-loc as logical no-undo .
define variable v-last as integer no-undo .
define variable v-rec-ord as integer no-undo .
define buffer buf_Dis-card-type for ub.dis-card-type.
define buffer buf_cash-pay for ub.cash-pay.
define buffer buf_db for ub.db.
define buffer buf_hist-nws-option for ub.hist-nws-option.
define buffer buf0_hist-nws-option for ub.hist-nws-option.
define buffer last_hist-nws-option for ub.hist-nws-option.
define buffer buf_dis-dct-rule for ub.dis-dct-rule.
define buffer buf_tt0-dis-dct-rule for tt0-dis-dct-rule.
define buffer term_dis-card-type for ub.dis-card-type.
define buffer buf_dis-card for ub.dis-card.


if g#db-num > 0  then do:
  message  vss-workfile vss-revision vss-description skip
          "Вызов процедуры в УБД запрещен"
  view-as alert-box ERROR.
  return error '':u.
end.

if par-mode <> {&add-def} AND par-mode <> {&update} then do:
  message vss-workfile vss-revision vss-description skip
          "Неверный параметр par-mode - " par-mode
  view-as alert-box error .
  return error '':u.
end.

if p-type = "" then do:
  message "Тип дисконтной карты не может быть пустым"
  view-as alert-box error .
  var-entry = "type":U.
  return error VAR-ENTRY.
end.
if p-type begins '@' then do:
  message "Тип дисконтной карты не может начинаться с символа @"
  view-as alert-box error .
  var-entry = "type":U.
  return error VAR-ENTRY.
end.


if p-emitent-host-code <> 0 and not can-find( first ub.sysconf No-LOCK WHERE
                       ub.sysconf.host-code = p-emitent-host-code) then do:
  message "Нет фирмы-эмитента дисконтной карты" p-emitent-host-code
  view-as alert-box error .
  var-entry = "emitent-host-code":U.
  return error var-entry.
end.

if pardflt-credit-card AND p-emitent-host-code = 0 then do:
  message
  "Глобальная дисконтная карта не может быть кредитной"
  view-as alert-box error .
  var-entry = "dflt-credit-card":U.
  return error var-entry.
end.


if pardflt-credit-card and parlim-kr <= 0 then do:
  message "Если дисконтная карта кредитная, лимит кредита должен быть положительным"
  view-as alert-box error .
  var-entry = "lim-kr":U.
  return error var-entry.
end.

if pardflt-credit-card and pardflt-debet-card then do:
  message "Карта не может быть одновременно и кредитной и дебетовой" skip
  view-as alert-box error .
  var-entry = "dflt-credit-card":U.
  return error var-entry.
end.
if not pardflt-credit-card
AND not pardflt-debet-card
and (parfiscal-pay
     or
     parmixed-pay)
then do:
  message "Свойста <Фискальный платеж> и <Разрешена смешанная оплата> имеют смысл только для кредитной или дебетовой карты" skip
  view-as alert-box error .
  var-entry = (if parfiscal-pay then "fiscal-pay":U else "mixed-pay":U).
  return error var-entry.
end.

if not pardflt-credit-card
AND not pardflt-debet-card
and parpay-code <> 0  then do:
  message "Свойство <Тип кассового платежа> имеет смысл только для кредитной или дебетовой карты" skip
  view-as alert-box error .
  var-entry = "pay-code":U.
  return error var-entry.
end.
if (pardflt-credit-card
or pardflt-debet-card)
and parpay-code = 0  then do:
  message "Для кредитной или дебетовой карты надо ввести код платежа" skip
  view-as alert-box error .
  var-entry = "pay-code":U.
  return error var-entry.
end.

if parpay-code <> 0 then do:
   run get-r-b in this-procedure (input p-emitent-host-code, output v-r-b-code) no-error .
  find first  buf_cash-pay no-lock where
            buf_cash-pay.cdpay-code = parpay-code
        AND buf_cash-pay.curr-code = v-r-b-code no-error .
  if not available buf_cash-pay then do:
    message substitute("Не найден тип кассового платежа с кодом &1 и кодом валюты &2", parpay-code, v-r-b-code) skip
    view-as alert-box error .
    var-entry = "pay-code":U.
    return error var-entry.
  end.
  if buf_Cash-pay.is-debet-card = no then do:
    message substitute("Тип кассового платежа для кредитной или дебетовой карты должен иметь свойство <РАСЧЕТНАЯ КАРТА>: тип кассового платежа с кодом &1 и кодом валюты &2", parpay-code, v-r-b-code) skip
    view-as alert-box error .
    var-entry = "pay-code":U.
    return error var-entry.
  end.
  if pardflt-credit-card = yes and buf_Cash-pay.is-credit = no then do:
    message substitute("Тип кассового платежа для кредитной карты должен иметь свойство <В КРЕДИТ>: тип кассового платежа с кодом &1 и кодом валюты &2", parpay-code, v-r-b-code) skip
    view-as alert-box error .
    var-entry = "pay-code":U.
    return error var-entry.
  end.
end.


if parcardname-sent <> {&dc-cn-sent-card}
and parcardname-sent <> {&dc-cn-sent-name} then do:
  message
  substitute("Неверное значение свойства карты <ДЕРЖАТЕЛЬ КАРТЫ на кассе>: &1, может быть только &2 или &3"
             ,parcardname-sent
             ,{&dc-cn-sent-name-full}
             ,{&dc-cn-sent-card-full}
             ) skip
  view-as alert-box error .
  var-entry = "cardname-sent":U.
  return error var-entry.
end.
define variable V-VALUE-CHARACTER as character no-undo .
define variable v-ii as integer no-undo .
define variable V-STORAGE-PLACE as character no-undo .
define variable v-dtm-code as integer no-undo .
define variable V-SUM-ID as character no-undo .
define variable V-CALLER-ID as character no-undo .
define variable glog as logical no-undo .
do v-ii = 1 to num-entries(PARCUSTOM-SENT):
  assign
  v-value-character = entry(v-ii, PARCUSTOM-SENT)
  v-storage-place = entry(1, v-value-character, {&delim-par})
  v-dtm-code = integer(entry(2, v-value-character, {&delim-par}))
  no-error .
  if v-value-character = {&question-mark} then next.
  find first TT0-HIST-NWS-OPTION WHERE
            TT0-HIST-NWS-OPTION.db-num = 0
        and tt0-hist-nws-option.table-name = v-STORAGE-PLACE
        and tt0-hist-nws-option.obj-type = '':U
        and tt0-hist-nws-option.obj-code = 0
        and tt0-hist-nws-option.key#_one = V-dtm-code
        and tt0-hist-nws-option.subject-group = {&table_c-dc-hist} NO-ERROR.
  IF AVAILABLE TT0-HIST-NWS-OPTION
  AND TT0-HIST-NWS-OPTION.SMART-NWS >= 0 THEN DO:
    message
    substitute("Для пересылки на кассу выбран срез/итог объекта-операнда&1&2&1" +
               "Однако для этого операнда включена настройка смарт-пересылки через СПН:&1" +
               "в нескольких или во всех УБД данные обновляться не будут&1" +
               "Вы уверены, что хотите пересылать на кассу данный срез/итог?"
               , {&new-line}
               ,dct-algo_custom-sent-description(v-value-character)
                 )
    view-as alert-box question buttons yes-no
    update glog.
    if not glog then do:
      undo, return error ''.
    end.
  END.
END.

&scop dc-cm-type-code string(parcard-media)
if {&dc-cm-type-name} = "":U then do:
  message
  substitute("Неверный носитель для карты: &1"
             ,parcard-media
             ) skip
  view-as alert-box error .
  var-entry = "card-media":U.
  return error var-entry.

end.
if parcard-media = integer({&dc-cm-ef}) then do:
define variable is-ef-chr as character no-undo .
define variable conf-type as character no-undo .
  /*проверим конф параметр is-ef*/
  { gbl/conf-rd.i
  "'is-ef'"
  "''"
  "''"
  0
  "''"
  "''"
  "''"
  no
  is-ef-chr
  conf-type
  no-error
  }
  if error-status:error
  or logical(is-ef-chr) = no then do:
    message
    substitute("В Вашей конфигурации нельзя ввести тип ДК с типом носителя &1,&2" +
              "так как не включен конфигурационный параметр is-ef"
              ,{&dc-cm-ef-full}
              ,{&new-line}
              )
    view-as alert-box .
    undo, return error .
  end.

end.

if par-mode = {&update} then do:
  FIND FIRST buf_dis-card-type share-lock where
            recid(buf_dis-card-type) = par-rid No-ERROR.
  if not available buf_dis-card-type then do:
    message
    substitute("Не найден тип ДК recid &1", par-rid)
    view-as alert-box error .
    return error '':u.
  end.
  if buf_dis-card-type.card-media <> parcard-media
  and (buf_dis-card-type.card-media = integer({&dc-cm-ef})
       or
       parcard-media = integer({&dc-cm-ef}))
  then do:
    find first buf_dis-card no-lock where
              buf_dis-card.type = par-type
          and buf_dis-card.emitent-host-code = p-emitent-host-code no-error.
    if available buf_dis-card then do:
       message
       "Нельзя сменить тип носителя" skip
       "В системе имеются ДК данного типа"
       view-as alert-box  error.
       return error "card-media".
    end.
  end.
end.

if lookup(string(pardflt-d-pcnt-method),
          string({&dc-d-pcnt-good} + {&comma-char} + {&dc-d-pcnt-cash} + {&comma-char} + {&dc-d-pcnt-both})
         ) = 0 then do:
  message
  "Неверное значение кода использования скидки"
  view-as alert-box error .
  var-entry = "dflt-d-pcnt-method":U.
  return error var-entry.
end.

DO jj = 1 to num-entries(pardcbyshop):
  find first ub.shop No-LOCK WHERE
             ub.shop.obj-code = integer(entry(jj, pardcbyshop)) NO-ERROR.
  if not avail ub.shop or (p-emitent-host-code > 0 and ub.shop.host-code <> p-emitent-host-code) then do:
    message "В списке магазинов принимающие только СВОИ карты есть неверный код магазина " entry(jj, pardcbyshop)
    view-as alert-box error .
    var-entry = "lim-kr":U.
    return error var-entry.
  end.
END.

{ gbl/curr-r-b.i v-curr-r-b }

if pardflt-d-pcnt-method  = integer({&dc-d-pcnt-cash})
OR pardflt-d-pcnt-method  = integer({&dc-d-pcnt-both})  then do:
  message
  "ВНИМАНИЕ!" SKIP
  "Использование скидок на итог имеет смысл только при условии применения POS NCR или IBS TH POS" SKIP
  "Продолжить?"
  view-as alert-box QUESTION Buttons YES-NO
  update loc#log .
  if not loc#log then do:
    var-entry = "dflt-d-pcnt-method":U.
    return error var-entry.
  end.
end.

if parcheck-by-mask
and parho-join then do:
  run check-mask-correct-ho-join in this-procedure (
                                                input p-emitent-host-code
                                              ,input p-type
                                              ,input "":U
                                              ,input 0
                                              ,input "":U
                                              ,input 0
                                              ,output v-ok
                                              ) no-error .
  if error-status:error then do:
    message substitute("Невозможно установить для ДК свойство&1<Проверка № карт по маске> с опцией <Привязка к фирме/объекту:&1&2 &3"
                            , {&new-line}
                            , error-status:get-message(1)
                            , return-value
                            )
    view-as alert-box error .
    var-entry = "mask":U.
    undo, return error var-entry.
  end.
  if not v-ok then do:
    message substitute("Невозможно установить для ДК свойство&1<Проверка № карт по маске> с опцией <Привязка к фирме/объекту:&1&2"
                            , {&new-line}
                            , return-value
                            )
    view-as alert-box error .
    var-entry = "mask":U.
    undo, return error var-entry.
  end.
end.
for each tt0-root-dis-card-type:
  delete tt0-root-dis-card-type.
end.

_MAIN:
do transaction
on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )
:
   if not valid-handle(v-cmd-proc-handle ) then dO:
    /* инициализируем библиотеку формирования команды */
    run nws/cmd-bush.p persistent set v-cmd-proc-handle no-error .
    if error-status :error
    then do:
      delete procedure v-cmd-proc-handle .
      undo _main, return error substitute("&1 &2 &3&4Ошибка при запуске процедуры cmd-bush.p&4" +
                                          "&5&4&6"
                                          ,vss-workfile
                                          ,vss-revision
                                          ,vss-description
                                          ,{&new-line}
                                          ,error-status:get-message(1)
                                          ,return-value ).
    end.
  end.
  /* начало формирования команды */
  assign
  v-command =  substitute("&2&1&3&1&4"
                         , {&delim-cmd}
                         , {&cmd-dct-send}
                         , p-emitent-host-code
                         , p-type
                         ).
  run begin-create-command in v-cmd-proc-handle
    (input v-command /* p-command-name */
    ,input "":U                /* p-db-list      */
    ,output v-cmd-code        /* p-command-code */
    ) no-error.
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      substitute( "Ошибка при создании команды &1", {&cmd-dct-send} ) skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    delete procedure v-cmd-proc-handle .
    undo _main, return error return-value .
  end.
  create tt0-root-dis-card-type.
  if par-mode = {&add-def} then do:
    if can-find( FIRST ub.dis-card-type No-LOCK where
                      ub.dis-card-type.emitent-host-code = p-emitent-host-code AND
                      ub.dis-card-type.type = p-type AND
                      ub.dis-card-type.host-code = parhost-code AND
                      ub.dis-card-type.obj-type = parobj-type AND
                      ub.dis-card-type.obj-code = parobj-code
                        ) then do:
      delete procedure v-cmd-proc-handle .
      message (if p-emitent-host-code = 0
              then "Уже есть такой тип глобальной дисконтной карты "
              else ("Уже есть такой тип дисконтной карты на фирме " + string(p-emitent-host-code)))
      view-as alert-box ERROR .
      var-entry = "type":U.
      undo _main, return error var-entry.
    end. /*can-find*/
    if can-find( FIRST ub.dis-card-type No-LOCK where
                      ub.dis-card-type.type = p-type AND
                      ub.dis-card-type.host-code = parhost-code AND
                      ub.dis-card-type.obj-type = parobj-type AND
                      ub.dis-card-type.obj-code = parobj-code ) then do:
      delete procedure v-cmd-proc-handle .
      message "Уже есть такой тип дисконтной карты "
              (if p-emitent-host-code = 0
              then " - глобальный "
              else (" - на фирме " + string(p-emitent-host-code)))
      view-as alert-box ERROR .
      var-entry = "type":U.
      undo _main, return error var-entry.
    end. /*can-find*/
    CREATE buf_dis-card-type.
    assign
    buf_dis-card-type.emitent-host-code = p-emitent-host-code
    buf_dis-card-type.type = p-type
    buf_dis-card-type.host-code = parhost-code
    buf_dis-card-type.obj-type = parobj-type
    buf_dis-card-type.obj-code = parobj-code
    par-rid = recid( buf_dis-card-type )
    .
    define variable v-uniq-key-rec as character no-undo .
    run gen-key-rec in this-procedure ( input {&table_dis-card-type}
                                      ,input buffer buf_dis-card-type:handle
                                      ,output v-uniq-key-rec).
    assign
    buf_dis-card-type.uniq-key-rec = v-uniq-key-rec
    p-uniq-key-rec = v-uniq-key-rec
    .

  end. /*add-def*/
  else do:
    FIND FIRST buf_dis-card-type exclusive-lock where
              recid(buf_dis-card-type) = par-rid No-ERROR.
    if not available buf_dis-card-type then return error '':u.
    if buf_dis-card-type.uniq-key-rec <> p-uniq-key-rec then do:
      delete procedure v-cmd-proc-handle .
      message
      substitute("Неверное значение параметра p-uniq-key-rec &1", p-uniq-key-rec)
      view-as alert-box error.
      undo _main, return error .
    end.
    buffer-copy buf_dis-card-type to tt0-root-dis-card-type.
  end.
  assign
  buf_dis-card-type.d-pcnt-byshop = pard-pcnt-byshop
  buf_dis-card-type.dflt-d-pcnt-method = pardflt-d-pcnt-method
  buf_dis-card-type.dflt-credit-card = pardflt-credit-card
  buf_dis-card-type.dflt-debet-card = pardflt-debet-card
  buf_dis-card-type.dflt-staff-card = pardflt-staff-card
  buf_dis-card-type.fiscal-pay = parfiscal-pay
  buf_dis-card-type.mixed-pay = parmixed-pay
  buf_dis-card-type.card-media = parcard-media
  buf_dis-card-type.cardname-sent = parcardname-sent
  buf_dis-card-type.custom-sent = parcustom-sent
  buf_dis-card-type.pay-code = parpay-code
  buf_dis-card-type.lim-kr = parlim-kr
  buf_dis-card-type.dc-pfx = pardc-pfx
  buf_dis-card-type.dcbyshop = pardcbyshop
  buf_dis-card-type.check-by-mask = (if parcheck-by-mask then 1 else 0)
  buf_dis-card-type.ho-join = (if parho-join then 1 else 0)
  .
  buffer-compare tt0-root-dis-card-type to buf_dis-card-type
  case-sensitive
  save result in v-cmp-loc.
  v-cmp = v-cmp and v-cmp-loc.
  if not v-cmp-loc then do:
     buffer-copy buf_dis-card-type to tt0-root-dis-card-type .
&scop table__  ~{&table_dis-card-type~}
&scop buffer-handle  buffer buf_dis-card-type:handle
&scop action__ '+update'
    {&add-dump}.
  end.
  release buf_dis-card-type no-error .
  if error-status:error then do:
    delete procedure v-cmd-proc-handle .
    message
    "Ошибка при сохранении записи ТИП ДИСКОНТНОЙ КАРТЫ" skip
    error-status:get-message(1) skip
    return-value
    view-as alert-box error .
    undo _main, return error .
  end.
  for each buf_tt0-dis-dct-rule
    on ERROR UNDO _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
    ON STOP undo _MAIN, return error '':u:
    if not (buf_tt0-dis-dct-rule.discnt-role = {&ddctr-def-pcnt}
            or
            buf_tt0-dis-dct-rule.discnt-role = {&ddctr-def-cash-pcnt}
            or
            buf_tt0-dis-dct-rule.discnt-role = {&ddctr-def-categ}) then next.
    find first buf_dis-dct-rule where
            buf_dis-dct-rule.emitent-host-code = buf_tt0-dis-dct-rule.emitent-host-code
        and buf_dis-dct-rule.type = buf_tt0-dis-dct-rule.type
        and buf_dis-dct-rule.host-code = buf_tt0-dis-dct-rule.host-code
        and buf_dis-dct-rule.obj-type = buf_tt0-dis-dct-rule.obj-type
        and buf_dis-dct-rule.obj-code = buf_tt0-dis-dct-rule.obj-code
        and buf_dis-dct-rule.pos-type = buf_tt0-dis-dct-rule.pos-type
        and buf_dis-dct-rule.discnt-role = buf_tt0-dis-dct-rule.discnt-role
        and buf_dis-dct-rule.nonunique = buf_tt0-dis-dct-rule.nonunique
        no-error.
    if not available buf_dis-dct-rule then do:
      v-cmp-loc = no.
      create buf_dis-dct-rule.
      buffer-copy buf_tt0-dis-dct-rule to buf_dis-dct-rule.
    end.
    else do:
      buffer-compare
      buf_tt0-dis-dct-rule except emitent-host-code type
      to buf_dis-dct-rule
      case-sensitive
      save result in v-cmp-loc.
      if not v-cmp-loc then do:
        assign
        buf_dis-dct-rule.rule-num = buf_tt0-dis-dct-rule.rule-num
        buf_dis-dct-rule.rl-root = buf_tt0-dis-dct-rule.rl-root
        buf_dis-dct-rule.templ-rl-root = buf_tt0-dis-dct-rule.templ-rl-root
        buf_dis-dct-rule.time-templ-rl-root = buf_tt0-dis-dct-rule.time-templ-rl-root
        buf_dis-dct-rule.nonunique = buf_tt0-dis-dct-rule.nonunique
        .
      end.
    end.
    if not v-cmp-loc then do:
&scop table__  ~{&table_dis-dct-rule~}
&scop buffer-handle  buffer buf_dis-dct-rule:handle
&scop action__ '+update'
      {&add-dump}.
    end.

  end.
  _dis-dct-rule:
  for each buf_dis-dct-rule where
            buf_dis-dct-rule.emitent-host-code = p-emitent-host-code
        and buf_dis-dct-rule.type = p-type
  on ERROR UNDO _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
  ON STOP undo _MAIN, return error '':u:
    if not (buf_dis-dct-rule.discnt-role = {&ddctr-def-pcnt}
            or
            buf_dis-dct-rule.discnt-role = {&ddctr-def-cash-pcnt}
            or
            buf_dis-dct-rule.discnt-role = {&ddctr-def-categ}) then next.
     if not pard-pcnt-byshop and
     not ( buf_dis-dct-rule.host-code = 0
           and
           buf_dis-dct-rule.obj-type = '':U
           and
           buf_dis-dct-rule.obj-code = 0) then do:
&scop table__  ~{&table_dis-dct-rule~}
&scop buffer-handle  buffer buf_dis-dct-rule:handle
&scop action__ '+delete'
         {&add-dump}.

       delete buf_dis-dct-rule.
       next _dis-dct-rule.
     end.

     find first buf_tt0-dis-dct-rule where
            buf_tt0-dis-dct-rule.emitent-host-code = buf_dis-dct-rule.emitent-host-code
        and buf_tt0-dis-dct-rule.type = buf_dis-dct-rule.type
        and buf_tt0-dis-dct-rule.host-code = buf_dis-dct-rule.host-code
        and buf_tt0-dis-dct-rule.obj-type = buf_dis-dct-rule.obj-type
        and buf_tt0-dis-dct-rule.obj-code = buf_dis-dct-rule.obj-code
        and buf_tt0-dis-dct-rule.pos-type = buf_dis-dct-rule.pos-type
        and buf_tt0-dis-dct-rule.discnt-role = buf_dis-dct-rule.discnt-role
        and buf_tt0-dis-dct-rule.nonunique = buf_dis-dct-rule.nonunique
        no-error .
     if not available buf_tt0-dis-dct-rule then do:
&scop table__  ~{&table_dis-dct-rule~}
&scop buffer-handle  buffer buf_dis-dct-rule:handle
&scop action__ '+delete'
         {&add-dump}.

       delete buf_dis-dct-rule.
     end.
  end.
  /*теперь ветки куста dis-card-type сделаем*/
  if pard-pcnt-byshop = no then do:
    for each term_dis-card-type where
            term_dis-card-type.emitent-host-code = p-emitent-host-code
        and term_dis-card-type.type = p-type
  on ERROR UNDO _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
  ON STOP undo _MAIN, return error '':u:
    if term_dis-card-type.host-code = 0
    and term_dis-card-type.obj-type = '':U
    and term_dis-card-type.obj-code = 0 then next.
&scop table__  ~{&table_dis-card-type~}
&scop buffer-handle  buffer term_dis-card-type:handle
&scop action__ '+delete'
         {&add-dump}.
       delete term_dis-card-type.
     end.
  end.
  else do:
    for each buf_dis-dct-rule where
              buf_dis-dct-rule.emitent-host-code = p-emitent-host-code
          and buf_dis-dct-rule.type = p-type
    on ERROR UNDO _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
    ON STOP undo _MAIN, return error '':u:
      if not (buf_dis-dct-rule.discnt-role = {&ddctr-def-pcnt}
              or
              buf_dis-dct-rule.discnt-role = {&ddctr-def-cash-pcnt}
              or
              buf_dis-dct-rule.discnt-role = {&ddctr-def-categ}) then next.
      if ( buf_dis-dct-rule.host-code = 0
            and
            buf_dis-dct-rule.obj-type = '':U
            and
            buf_dis-dct-rule.obj-code = 0) then do:
        next.
      end.
      v-cmp-loc = yes.
      find first term_dis-card-type where
                term_dis-card-type.emitent-host-code = p-emitent-host-code
            and term_dis-card-type.type = p-type
            and term_dis-card-type.host-code = buf_Dis-dct-rule.host-code
            and term_dis-card-type.obj-type = buf_Dis-dct-rule.obj-type
            and term_dis-card-type.obj-code = buf_Dis-dct-rule.obj-code
      no-error .
      if not available term_dis-card-type then do:
        v-cmp-loc = no.
        create term_dis-card-type.
        buffer-copy tt0-root-dis-card-type
        except host-code obj-type obj-code
        to term_dis-card-type
        assign
        term_dis-card-type.host-code = buf_dis-dct-rule.host-code
        term_dis-card-type.obj-type = buf_dis-dct-rule.obj-type
        term_dis-card-type.obj-code = buf_dis-dct-rule.obj-code
        .
        run gen-key-rec in this-procedure ( input {&table_dis-card-type}
                                          ,input buffer term_dis-card-type:handle
                                          ,output term_dis-card-type.uniq-key-rec).

      end.
      v-cmp = v-cmp and v-cmp-loc.
      if not v-cmp-loc then do:
  &scop table__  ~{&table_dis-card-type~}
  &scop buffer-handle  buffer term_dis-card-type:handle
  &scop action__ '+update'
          {&add-dump}.
      end.
    end. /*for each buf_dis-dct-rule where*/
  end. /*  elase if pard-pcnt-byshop = no then do:*/
  for each buf_db no-lock,
     each buf_hist-nws-option where
            buf_hist-nws-option.db-num = buf_db.db-num
        and buf_hist-nws-option.subject-group = {&table_c-dc-hist}
        and buf_hist-nws-option.host-code = p-emitent-host-code
        AND buf_hist-nws-option.charkey_one = p-type
        AND buf_hist-nws-option.obj-type = '':U
        AND buf_hist-nws-option.obj-code = 0
    on ERROR UNDO _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
    ON STOP undo _MAIN, return error '':u:
    find first tt0-hist-nws-option no-lock where
              tt0-hist-nws-option.db-num = 0
          and tt0-hist-nws-option.table-name = buf_hist-nws-option.table-name
          and tt0-hist-nws-option.host-code = buf_hist-nws-option.host-code
          AND tt0-hist-nws-option.charkey_one = buf_hist-nws-option.charkey_one
          AND tt0-hist-nws-option.obj-type = buf_hist-nws-option.obj-type
          AND tt0-hist-nws-option.obj-code = buf_hist-nws-option.obj-code
          AND tt0-hist-nws-option.key#_one = buf_hist-nws-option.key#_one no-error .
    if not available tt0-hist-nws-option then do:

&scop table__  ~{&table_hist-nws-option~}
&scop buffer-handle  buffer buf_hist-nws-option:handle
&scop action__ '+delete'
         {&add-dump}.
      delete buf_hist-nws-option.
    end.
   end.
  for each tt0-hist-nws-option
  on ERROR UNDO _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
  ON STOP undo _MAIN, return error '':u:
    for each buf_db no-lock
    on ERROR UNDO _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
    ON STOP undo _MAIN, return error '':u:
      find first buf_hist-nws-option where
                buf_hist-nws-option.db-num = buf_db.db-num
            and buf_hist-nws-option.table-name = tt0-hist-nws-option.table-name
            and buf_hist-nws-option.host-code = tt0-hist-nws-option.host-code
            AND buf_hist-nws-option.charkey_one = tt0-hist-nws-option.charkey_one
            AND buf_hist-nws-option.obj-type = tt0-hist-nws-option.obj-type
            AND buf_hist-nws-option.obj-code = tt0-hist-nws-option.obj-code
            AND buf_hist-nws-option.key#_one = tt0-hist-nws-option.key#_one no-error .
      if not available buf_hist-nws-option
      then do:
        find first buf_hist-nws-option where
                  buf_hist-nws-option.db-num = 0
              and buf_hist-nws-option.table-name = tt0-hist-nws-option.table-name
              and buf_hist-nws-option.host-code = tt0-hist-nws-option.host-code
              AND buf_hist-nws-option.charkey_one = tt0-hist-nws-option.charkey_one
              AND buf_hist-nws-option.obj-type = tt0-hist-nws-option.obj-type
              AND buf_hist-nws-option.obj-code = tt0-hist-nws-option.obj-code
              AND buf_hist-nws-option.key#_one = tt0-hist-nws-option.key#_one no-error .
        if available buf_hist-nws-option then do:
          v-last = buf_hist-nws-option.hn-id.
        end.
        else do:
          v-last = next-value(s-hn-id, {&db-name_schema}).
          create buf0_hist-nws-option.
          assign
          buf0_hist-nws-option.db-num = 0
          buf0_hist-nws-option.table-name = tt0-hist-nws-option.table-name
          buf0_hist-nws-option.host-code = tt0-hist-nws-option.host-code
          buf0_hist-nws-option.charkey_one = tt0-hist-nws-option.charkey_one
          buf0_hist-nws-option.obj-type = tt0-hist-nws-option.obj-type
          buf0_hist-nws-option.obj-code = tt0-hist-nws-option.obj-code
          buf0_hist-nws-option.key#_one = tt0-hist-nws-option.key#_one
          buf0_hist-nws-option.option-descr = tt0-hist-nws-option.option-descr
          buf0_hist-nws-option.subject-group = {&table_c-dc-hist}
          buf0_hist-nws-option.hn-id = v-last
          buf0_hist-nws-option.hist-from-prim = tt0-hist-nws-option.hist-from-prim
          buf0_hist-nws-option.hist-to-nws = tt0-hist-nws-option.hist-to-nws
          buf0_hist-nws-option.nws-to-cd = tt0-hist-nws-option.nws-to-cd
          buf0_hist-nws-option.nws-to-hist = tt0-hist-nws-option.nws-to-hist
          buf0_hist-nws-option.smart-nws = tt0-hist-nws-option.smart-nws
          buf0_hist-nws-option.get-hist-from-nws =  tt0-hist-nws-option.get-hist-from-nws
          .
&scop table__  ~{&table_hist-nws-option~}
&scop buffer-handle  buffer buf0_hist-nws-option:handle
&scop action__ '+update'
         {&add-dump}.
        end.
        assign
        v-cmp-loc = no
        v-cmp = v-cmp and v-cmp-loc
        .
        if buf_db.db-num > 0 then do:
          create buf_hist-nws-option.
          assign
          buf_hist-nws-option.db-num = buf_db.db-num
          buf_hist-nws-option.table-name = tt0-hist-nws-option.table-name
          buf_hist-nws-option.host-code = tt0-hist-nws-option.host-code
          buf_hist-nws-option.charkey_one = tt0-hist-nws-option.charkey_one
          buf_hist-nws-option.obj-type = tt0-hist-nws-option.obj-type
          buf_hist-nws-option.obj-code = tt0-hist-nws-option.obj-code
          buf_hist-nws-option.key#_one = tt0-hist-nws-option.key#_one
          buf_hist-nws-option.option-descr = tt0-hist-nws-option.option-descr
          buf_hist-nws-option.subject-group = {&table_c-dc-hist}
          buf_hist-nws-option.hn-id = v-last
          .
        end.
      end.
      if available buf_hist-nws-option then do:
        buffer-compare tt0-hist-nws-option
        except db-num hn-id
        to buf_hist-nws-option
        case-sensitive
        save result in v-cmp-loc.
        buffer-copy tt0-hist-nws-option except hn-id db-num
        to buf_hist-nws-option
        .

        if not v-cmp-loc then do:
  &scop table__  ~{&table_hist-nws-option~}
  &scop buffer-handle  buffer buf_hist-nws-option:handle
  &scop action__ '+update'
          {&add-dump}.
        end.
      end.
    end.
  end.
  run rul/ruprcall.p (
                       input {&table_dis-card-type}
                      ,input p-uniq-key-rec
                      ,input ({&table_rp-by-call} + {&comma-char} + {&table_rule-by-call} + {&comma-char} + {&table_rule-call-param})
                      ,input v-cmd-proc-handle
                      ,input v-cmd-code
                      ,INPUT TABLE tt0-rp-by-call
                      ,INPUT TABLE tt0-rule-by-call
                      ,INPUT TABLE tt0-rule-call-param) no-error .
  if error-status:error then do:
    delete procedure v-cmd-proc-handle .
    message
    "Ошибка при сохранении привязок профайлов и/правил для записи ТИП ДИСКОНТНОЙ КАРТЫ" skip
    error-status:get-message(1) skip
    return-value
    view-as alert-box error .
    undo _main, return error .
  end.
  define variable v-db-list as character no-undo .
  for each buf_db no-lock
  where buf_db.db-num > 0
  :
    assign
    v-db-list = v-db-list + {&delim-nws} + string(buf_db.db-num).
  end.
  v-db-list = trim(v-db-list, {&delim-nws}).
  run send-command in v-cmd-proc-handle
    ( input v-cmd-code  /* p-command-code */
      ,input v-db-list
      ) no-error .
  if error-status:error then do:
    delete procedure v-cmd-proc-handle .
    message
    vss-workfile vss-revision vss-description skip
    substitute( "Ошибка при отсылке команды &1", {&cmd-dct-send} ) skip
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
    undo _main, return error .
  end.
  delete procedure v-cmd-proc-handle .
END. /*transaction*/
RETURN '':u.


PROCEDURE get-r-b :
define input parameter p-emitent-host-code like ub.dis-card.emitent-host-code no-undo .
DEFINE OUTPUT PARAMETER p-r-b-curr-code LIKE ub.currency.curr-code NO-UNDO.
define variable v-curr-r-b  as character no-undo .
DEFINE BUFFER buf_sysconf FOR ub.sysconf.
{ gbl/curr-r-b.i v-curr-r-b  no-error }
if p-emitent-host-code = 0
and v-curr-r-b = {&r-b-base}
then do:
  ASSIGN
  p-r-b-curr-code = 0
  .
end.
else do:
  IF p-emitent-host-code = 0 or
     v-curr-r-b = {&r-b-rubl}
     THEN DO:
        ASSIGN
        p-r-b-curr-code = 0
        .
    END.
    ELSE DO:
       FIND FIRST buf_sysconf NO-LOCK WHERE
                 buf_sysconf.host-code = p-emitent-host-code .
       ASSIGN
       p-r-b-curr-code = buf_sysconf.base-code
        .
  END.
end.
END PROCEDURE.