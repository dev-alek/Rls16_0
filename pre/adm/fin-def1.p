block-level on error undo, throw.
define input-output     parameter p-rec as recid no-undo.
define input parameter  p-mode                as character no-undo .
define input parameter  p-silent              as logical  no-undo .
define input parameter  p-host-code                    as integer no-undo .
define input parameter  p-fin-copy            as logical no-undo .
define input parameter  p-fin-host-copy       like ub.sysconf.host-code        no-undo .
define input parameter  p-contract-city              like ub.sysconf.contract-city            no-undo .
define input parameter  p-contract-type              like ub.sysconf.contract-type            no-undo .
define input parameter  p-pay-sign-post              like ub.sysconf.pay-sign-post            no-undo .
define input parameter  p-pay-sign                   like ub.sysconf.pay-sign                 no-undo .
define input parameter  p-fin-VAT-pc                 like ub.sysconf.fin-VAT-pc               no-undo .
define input parameter  p-srok-opl                   like ub.sysconf.srok-opl                 no-undo .
define input parameter  p-srok-opl-sf                like ub.sysconf.srok-opl-sf              no-undo .
define input parameter  p-usl-opl                    like ub.sysconf.usl-opl                  no-undo .
define input parameter  p-usl-opl-sf                 like ub.sysconf.usl-opl-sf               no-undo .
define input parameter  p-is-an-uchet                like ub.sysconf.is-an-uchet              no-undo .
define input parameter  p-is-code-cel-nazn           like ub.sysconf.is-code-cel-nazn         no-undo .
define input parameter  p-is-corr-acc                like ub.sysconf.is-corr-acc              no-undo .
define input parameter  p-is-cassa-acc               like ub.sysconf.is-cassa-acc             no-undo .
define input parameter  p-fin-calc                   like ub.sysconf.fin-calc                 no-undo .
define input parameter  p-pay-code-schet-rubl        like ub.sysconf.pay-code-schet-rubl      no-undo .
define input parameter  p-pay-code-schet-base        like ub.sysconf.pay-code-schet-base      no-undo .
define input parameter  p-an-uchet-code-out          like ub.sysconf.an-uchet-code-out        no-undo .
define input parameter  p-cel-nazn-code-out          like ub.sysconf.cel-nazn-code-out        no-undo .
define input parameter  p-cor-acc-out                like ub.sysconf.cor-acc-out              no-undo .
define input parameter  p-cor-acc1-out               like ub.sysconf.cor-acc1-out             no-undo .
define input parameter  p-an-uchet-code-in           like ub.sysconf.an-uchet-code-in         no-undo .
define input parameter  p-cel-nazn-code-in           like ub.sysconf.cel-nazn-code-in         no-undo .
define input parameter  p-cor-acc-in                 like ub.sysconf.cor-acc-in               no-undo .
define input parameter  p-cor-acc1-in                like ub.sysconf.cor-acc1-in              no-undo .
define input parameter  p-an-uchet-code-out-cash     like ub.sysconf.an-uchet-code-out-cash   no-undo .
define input parameter  p-cel-nazn-code-out-cash     like ub.sysconf.cel-nazn-code-out-cash   no-undo .
define input parameter  p-cor-acc-out-cash           like ub.sysconf.cor-acc-out-cash         no-undo .
define input parameter  p-cor-acc1-out-cash          like ub.sysconf.cor-acc1-out-cash        no-undo .
define input parameter  p-an-uchet-code-in-cash      like ub.sysconf.an-uchet-code-in-cash    no-undo .
define input parameter  p-cel-nazn-code-in-cash      like ub.sysconf.cel-nazn-code-in-cash    no-undo .
define input parameter  p-cor-acc-in-cash            like ub.sysconf.cor-acc-in-cash          no-undo .
define input parameter  p-cor-acc1-in-cash           like ub.sysconf.cor-acc1-in-cash         no-undo .
define input parameter  p-an-uchet-code-out-payoff   like ub.sysconf.an-uchet-code-out-payoff no-undo .
define input parameter  p-cel-nazn-code-out-payoff   like ub.sysconf.cel-nazn-code-out-payoff no-undo .
define input parameter  p-cor-acc-out-payoff         like ub.sysconf.cor-acc-out-payoff       no-undo .
define input parameter  p-cor-acc1-out-payoff        like ub.sysconf.cor-acc1-out-payoff      no-undo .
define input parameter  p-an-uchet-code-in-payoff    like ub.sysconf.an-uchet-code-in-payoff  no-undo .
define input parameter  p-cel-nazn-code-in-payoff    like ub.sysconf.cel-nazn-code-in-payoff  no-undo .
define input parameter  p-cor-acc-in-payoff          like ub.sysconf.cor-acc-in-payoff        no-undo .
define input parameter  p-cor-acc1-in-payoff         like ub.sysconf.cor-acc1-in-payoff       no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: fin-def1.p $":U .
define variable vss-archive     as character no-undo init "$Archive: adm/fin-def1.p $":U .
define variable vss-description as character no-undo init "Сохранение настроек фирмы для взаиморасчетов и СФ".
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
define   shared variable g#auto as logical no-undo.
define   shared variable g#news as logical no-undo.
define   shared variable g#oxml as logical no-undo.
define   shared variable g#esys as logical no-undo.
define   shared variable g#news-source-db as integer no-undo.
define   shared variable g#esys-source-esys as integer no-undo.
define   shared variable g#db-num as integer   no-undo .
define   shared variable g#userid as character no-undo .
define   shared variable g#passwd as character no-undo .
define variable v-err-mess as character no-undo .
define variable is-fin as logical no-undo .
define variable is-fin-char as character no-undo .
define variable is-fin-type as character no-undo .
define buffer buf_sysconf for ub.sysconf.
define buffer buf_fin-schet for ub.fin-schet.
define buffer buf_fin-code-an-uchet for ub.fin-code-an-uchet.
define buffer buf_fin-code-cel-nazn for ub.fin-code-cel-nazn.
define buffer buf_fin-code-cor-acc for ub.fin-code-cor-acc.
if p-mode <> 'ДОБАВЛЕНИЕ':U
AND p-mode <> 'ИЗМЕНЕНИЕ':U
and p-mode <> 'ДОБАВЛЕНИЕ-ИМПОРТ':U
then do:
  message
  vss-workfile vss-revision vss-description skip
  "Неверный параметр p-mode" p-mode
  view-as alert-box error .
  return error '':u.
end.
if g#db-num <> 0
then do:
  v-err-mess = substitute("Нельзя изменять запись СВОЕЙ ФИРМЫ в УБД: Номер текущей БД &1", g#db-num ).
  run err-mess in this-procedure ( input-output v-err-mess ).
  undo, return error "":U.
end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-fin'
  ,input  0
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  no
  ,output is-fin-char
  ,output is-fin-type
  ) no-error .
is-fin = (is-fin-char = "yes").
if p-fin-copy then do:
  if p-fin-host-copy = p-host-code then do:
    v-err-mess = substitute("Нельзя скопировать настройки блока ВЗАИМОРАСЧЕТЫ: код СВОЕЙ ФИРМЫ &1, код фирмы для копирования &2", p-host-code, p-fin-host-copy ).
    run err-mess in this-procedure ( input-output v-err-mess  ).
    undo, return error  (if p-silent = yes then v-err-mess else '':U).
  end.
  if not can-find(first ub.sysconf no-lock where
                      ub.sysconf.host-code = p-fin-host-copy ) then do:
    v-err-mess = substitute("Не найдена СВОЯ ФИРМА с кодом &1 для копирования настроек блока ВЗАИМОРАСЧЕТЫ", p-fin-host-copy ).
    run err-mess in this-procedure ( input-output v-err-mess  ).
    undo, return error (if p-silent = yes then v-err-mess else '':U).
  end.
end.
if is-fin then do:
if lookup(p-contract-type, 'Купли-продажи,Консигнации,Ответственного хранения,Агентский договор,Давальческого сырья,Продажи через ТПСИ,о Дополнительных расходах':U) = 0 then do:
    v-err-mess = substitute("Неверный тип контракта = &1", p-contract-type).
  run err-mess in this-procedure ( input-output v-err-mess  ).
  undo, return error  (if p-silent = yes then v-err-mess else "contract-type":U).
end.
if p-fin-vat-pc < 0
or p-fin-vat-pc >= 100 then do:
  v-err-mess = substitute("Неверное значение НДС = &1", p-fin-vat-pc).
  run err-mess in this-procedure ( input-output v-err-mess  ).
  undo, return error (if p-silent = yes then v-err-mess else "fin-vat-pc":U).
end.
if p-srok-opl < 0
then do:
  v-err-mess = substitute("Неверное значение Срока оплаты = &1", p-srok-opl).
  run err-mess in this-procedure ( input-output v-err-mess  ).
  undo, return error (if p-silent = yes then v-err-mess else "srok-pl":U).
end.
if p-srok-opl-sf < 0
then do:
  v-err-mess = substitute("Неверное значение Срока оплаты счетов-фактур = &1", p-srok-opl-sf) .
  run err-mess in this-procedure ( input-output v-err-mess ).
  undo, return error (if p-silent = yes then v-err-mess else 'srok-opl-sf':U).
end.
if lookup(p-usl-opl,  'Не определено,По заказу,По поставке заказа,Отсрочка платежа по заказу,Отсрочка платежа по поставке заказа,По факту поставки,По факту реализации,Отсрочка платежа (по поставке),Отсрочка платежа (по реализации),По реализации части приход. накладной,По спецификации,Отсрочка платежа по спецификации,Предоплата,Предоплата(%),По факту поставки покупателю,Отсрочка платежа по поставке':U ) = 0 then do:
  v-err-mess = substitute("Неверное значение Условий генерации ФО = &1", p-usl-opl).
  run err-mess in this-procedure ( input-output v-err-mess  ).
  undo, return error (if p-silent = yes then v-err-mess else 'usl-opl':U).
end.
if lookup(p-usl-opl-sf,  'Не определено':U + chr(44)  +
                         'По приходной накладной':U + chr(44)  + 'По фин. обязательству':U + ","  + 'По платежу':U + "," + 'По накл. смены типа преобр.':U ) = 0 then do:
  v-err-mess = substitute("Неверное значение Условий генерации СФ = &1", p-usl-opl-sf).
  run err-mess in this-procedure ( input-output v-err-mess  ).
  undo, return error (if p-silent = yes then v-err-mess else "usl-opl-sf":U).
end.
if p-pay-code-schet-rubl <> ?
and p-pay-code-schet-rubl <> 0
then do:
  find first buf_fin-schet no-lock where
            buf_fin-schet.code-schet = p-pay-code-schet-rubl
        and buf_fin-schet.host-code = p-host-code no-error .
  if not available buf_fin-schet then do:
    v-err-mess = substitute("Не найден счет с вн.кодом &1, заданный как текущий счет ФИРМЫ", p-pay-code-schet-rubl).
    run err-mess in this-procedure ( input-output v-err-mess  ).
    undo, return error (if p-silent = yes then v-err-mess else "pay-code-schet-rubl":U).
  end.
end.
else do:
  assign
  p-pay-code-schet-rubl = 0.
end.
if p-pay-code-schet-base <> ?
and p-pay-code-schet-base <> 0
then do:
  find first buf_fin-schet no-lock where
            buf_fin-schet.code-schet = p-pay-code-schet-base
        and buf_fin-schet.host-code = p-host-code no-error .
  if not available buf_fin-schet then do:
    v-err-mess = substitute("Не найден счет с вн.кодом &1, заданный как текущий счет ФИРМЫ", p-pay-code-schet-rubl).
    run err-mess in this-procedure ( input-output v-err-mess  ).
    undo, return error  (if p-silent = yes then v-err-mess else "pay-code-schet-rubl":U).
  end.
end.
else do:
  assign
  p-pay-code-schet-base = 0.
end.
end.
if is-fin then do:
if p-an-uchet-code-out <> ?
and p-an-uchet-code-out <> 0 then do:
  find first buf_fin-code-an-uchet no-lock where
          buf_fin-code-an-uchet.fin-code = p-an-uchet-code-out
      and buf_fin-code-an-uchet.host-code = p-host-code no-error .
  if not available buf_fin-code-an-uchet then do:
    v-err-mess = substitute("Не найден код аналитического учета для РПП", p-an-uchet-code-out).
    run err-mess in this-procedure ( input-output v-err-mess  ).
    undo, return error (if p-silent = yes then v-err-mess else "an-uchet-code-out":U).
  end.
end.
else do:
  assign
  p-an-uchet-code-out = 0
  .
end.
if p-cel-nazn-code-out <> ?
and p-cel-nazn-code-out <> 0 then do:
  find first buf_fin-code-cel-nazn no-lock where
          buf_fin-code-cel-nazn.fin-code  = p-cel-nazn-code-out
      and buf_fin-code-cel-nazn.host-code = p-host-code no-error .
  if not available buf_fin-code-cel-nazn then do:
    v-err-mess = substitute("Не найден код целевого назначения учета для РПП", p-an-uchet-code-out).
    run err-mess in this-procedure ( input-output v-err-mess  ).
    undo, return error (if p-silent = yes then v-err-mess else "cel-nazn-code-out":U).
  end.
end.
else do:
  assign
  p-cel-nazn-code-out = 0
  .
end.
if p-cor-acc-out <> ?
and p-cor-acc-out <> 0 then do:
  find first buf_fin-code-cor-acc no-lock where
            buf_fin-code-cor-acc.fin-code  = p-cor-acc-out
        and buf_fin-code-cor-acc.host-code = p-host-code no-error .
  if not available buf_fin-code-cor-acc then do:
    v-err-mess = substitute("Не найден корреспондирующий счет для РПП", p-cor-acc-out).
    run err-mess in this-procedure ( input-output v-err-mess  ).
    undo, return error (if p-silent = yes then v-err-mess else "cor-acc-out":U).
  end.
end.
else do:
  p-cor-acc-out = 0.
end.
if p-cor-acc1-out <> ?
and p-cor-acc1-out <> 0 then do:
  find first buf_fin-code-cor-acc no-lock where
            buf_fin-code-cor-acc.fin-code  = p-cor-acc1-out
        and buf_fin-code-cor-acc.host-code = p-host-code no-error .
  if not available buf_fin-code-cor-acc then do:
    v-err-mess = substitute("Не найден корр.счет (касса) для РПП", p-cor-acc1-out).
    run err-mess in this-procedure ( input-output v-err-mess  ).
    undo, return error (if p-silent = yes then v-err-mess else "cor-acc-1-out":U).
  end.
end.
else do:
  p-cor-acc1-out = 0.
end.
if p-an-uchet-code-in <> ?
and p-an-uchet-code-in <> 0 then do:
  find first buf_fin-code-an-uchet no-lock where
          buf_fin-code-an-uchet.fin-code = p-an-uchet-code-in
      and buf_fin-code-an-uchet.host-code = p-host-code no-error .
  if not available buf_fin-code-an-uchet then do:
    v-err-mess = substitute("Не найден код аналитического учета для ППП", p-an-uchet-code-in).
    run err-mess in this-procedure ( input-output v-err-mess  ).
    undo, return error (if p-silent = yes then v-err-mess else "an-uchet-code-in":U).
  end.
end.
else do:
  p-an-uchet-code-in = 0.
end.
if p-cel-nazn-code-in <> ?
and p-cel-nazn-code-in <> 0 then do:
  find first buf_fin-code-cel-nazn no-lock where
          buf_fin-code-cel-nazn.fin-code  = p-cel-nazn-code-in
      and buf_fin-code-cel-nazn.host-code = p-host-code no-error .
  if not available buf_fin-code-cel-nazn then do:
    v-err-mess = substitute("Не найден код целевого назначения учета для ППП", p-an-uchet-code-in) .
    run err-mess in this-procedure ( input-output v-err-mess ).
    undo, return error (if p-silent = yes then v-err-mess else "cel-nazn-code-in":U).
  end.
end.
else do:
  p-cel-nazn-code-in = 0.
end.
if p-cor-acc-in <> ?
and p-cor-acc-in <> 0 then do:
  find first buf_fin-code-cor-acc no-lock where
            buf_fin-code-cor-acc.fin-code  = p-cor-acc-in
        and buf_fin-code-cor-acc.host-code = p-host-code no-error .
  if not available buf_fin-code-cor-acc then do:
    v-err-mess = substitute("Не найден корреспондирующий счет для ППП", p-cor-acc-in).
    run err-mess in this-procedure ( input-output v-err-mess  ).
    undo, return error (if p-silent = yes then v-err-mess else "cor-acc-in":U).
  end.
end.
else do:
  p-cor-acc-in = 0.
end.
if p-cor-acc1-in <> ?
and p-cor-acc1-in <> 0 then do:
  find first buf_fin-code-cor-acc no-lock where
            buf_fin-code-cor-acc.fin-code  = p-cor-acc1-in
        and buf_fin-code-cor-acc.host-code = p-host-code no-error .
  if not available buf_fin-code-cor-acc then do:
    v-err-mess = substitute("Не найден корр.счет (касса) для ППП", p-cor-acc1-in).
    run err-mess in this-procedure ( input-output v-err-mess  ).
    undo, return error (if p-silent = yes then v-err-mess else "cor-acc-1-in":U).
  end.
end.
else do:
  p-cor-acc1-in = 0.
end.
end.
if p-an-uchet-code-out-cash <> ?
and p-an-uchet-code-out-cash <> 0 then do:
  find first buf_fin-code-an-uchet no-lock where
          buf_fin-code-an-uchet.fin-code = p-an-uchet-code-out-cash
      and buf_fin-code-an-uchet.host-code = p-host-code no-error .
  if not available buf_fin-code-an-uchet then do:
    v-err-mess = substitute("Не найден код аналитического учета для РКО", p-an-uchet-code-out-cash).
    run err-mess in this-procedure ( input-output v-err-mess  ).
    undo, return error (if p-silent = yes then v-err-mess else "an-uchet-code-out-cash":U).
  end.
end.
else do:
  p-an-uchet-code-out-cash = 0.
end.
if p-cel-nazn-code-out-cash <> ?
and p-cel-nazn-code-out-cash <> 0 then do:
  find first buf_fin-code-cel-nazn no-lock where
          buf_fin-code-cel-nazn.fin-code  = p-cel-nazn-code-out-cash
      and buf_fin-code-cel-nazn.host-code = p-host-code no-error .
  if not available buf_fin-code-cel-nazn then do:
    v-err-mess = substitute("Не найден код целевого назначения учета для РКО", p-an-uchet-code-out-cash).
    run err-mess in this-procedure ( input-output v-err-mess  ).
    undo, return error (if p-silent = yes then v-err-mess else "cel-nazn-code-out-cash":U).
  end.
end.
else do:
 p-cel-nazn-code-out-cash = 0.
end.
if p-cor-acc-out-cash <> ?
and p-cor-acc-out-cash <> 0 then do:
  find first buf_fin-code-cor-acc no-lock where
            buf_fin-code-cor-acc.fin-code  = p-cor-acc-out-cash
        and buf_fin-code-cor-acc.host-code = p-host-code no-error .
  if not available buf_fin-code-cor-acc then do:
    v-err-mess = substitute("Не найден корреспондирующий счет для РКО", p-cor-acc-out-cash).
    run err-mess in this-procedure ( input-output v-err-mess  ).
    undo, return error (if p-silent = yes then v-err-mess else "cor-acc-out-cash":U).
  end.
end.
else do:
  p-cor-acc-out-cash = 0.
end.
if p-cor-acc1-out-cash <> ?
and p-cor-acc1-out-cash <> 0 then do:
  find first buf_fin-code-cor-acc no-lock where
            buf_fin-code-cor-acc.fin-code  = p-cor-acc1-out-cash
        and buf_fin-code-cor-acc.host-code = p-host-code no-error .
  if not available buf_fin-code-cor-acc then do:
    v-err-mess = substitute("Не найден корр.счет (касса) для РКО", p-cor-acc1-out-cash).
    run err-mess in this-procedure ( input-output v-err-mess  ).
    undo, return error (if p-silent = yes then v-err-mess else "cor-acc-1-out-cash":U).
  end.
end.
else do:
  p-cor-acc1-out-cash = 0.
end.
if p-an-uchet-code-in-cash <> ?
and p-an-uchet-code-in-cash <> 0 then do:
  find first buf_fin-code-an-uchet no-lock where
          buf_fin-code-an-uchet.fin-code = p-an-uchet-code-in-cash
      and buf_fin-code-an-uchet.host-code = p-host-code no-error .
  if not available buf_fin-code-an-uchet then do:
    v-err-mess = substitute("Не найден код аналитического учета для ПКО", p-an-uchet-code-in-cash).
    run err-mess in this-procedure ( input-output v-err-mess  ).
    undo, return error (if p-silent = yes then v-err-mess else "an-uchet-code-in-cash":U).
  end.
end.
else do:
  p-an-uchet-code-in-cash = 0.
end.
if p-cel-nazn-code-in-cash <> ?
and p-cel-nazn-code-in-cash <> 0 then do:
  find first buf_fin-code-cel-nazn no-lock where
          buf_fin-code-cel-nazn.fin-code  = p-cel-nazn-code-in-cash
      and buf_fin-code-cel-nazn.host-code = p-host-code no-error .
  if not available buf_fin-code-cel-nazn then do:
    v-err-mess = substitute("Не найден код целевого назначения учета для ПКО", p-an-uchet-code-in-cash).
    run err-mess in this-procedure ( input-output v-err-mess  ).
    undo, return error (if p-silent = yes then v-err-mess else "cel-nazn-code-in-cash":U).
  end.
end.
else do:
  p-cel-nazn-code-in-cash = 0.
end.
if p-cor-acc-in-cash <> ?
and p-cor-acc-in-cash <> 0 then do:
  find first buf_fin-code-cor-acc no-lock where
            buf_fin-code-cor-acc.fin-code  = p-cor-acc-in-cash
        and buf_fin-code-cor-acc.host-code = p-host-code no-error .
  if not available buf_fin-code-cor-acc then do:
    v-err-mess = substitute("Не найден корреспондирующий счет для ПКО", p-cor-acc-in-cash).
    run err-mess in this-procedure ( input-output v-err-mess  ).
    undo, return error (if p-silent = yes then v-err-mess else "cor-acc-in-cash":U).
  end.
end.
else do:
  p-cor-acc-in-cash = 0.
end.
if p-cor-acc1-in-cash <> ?
and p-cor-acc1-in-cash <> 0 then do:
  find first buf_fin-code-cor-acc no-lock where
            buf_fin-code-cor-acc.fin-code  = p-cor-acc1-in-cash
        and buf_fin-code-cor-acc.host-code = p-host-code no-error .
  if not available buf_fin-code-cor-acc then do:
    v-err-mess = substitute("Не найден корр.счет (касса) для ПКО", p-cor-acc1-in-cash).
    run err-mess in this-procedure ( input-output v-err-mess  ).
    undo, return error (if p-silent = yes then v-err-mess else "cor-acc-1-in-cash":U).
  end.
end.
else do:
  p-cor-acc1-in-cash = 0.
end.
if is-fin then do:
if p-an-uchet-code-out-payoff <> ?
and p-an-uchet-code-out-payoff <> 0 then do:
  find first buf_fin-code-an-uchet no-lock where
          buf_fin-code-an-uchet.fin-code = p-an-uchet-code-out-payoff
      and buf_fin-code-an-uchet.host-code = p-host-code no-error .
  if not available buf_fin-code-an-uchet then do:
    v-err-mess = substitute("Не найден код аналитического учета для Рс.АПЗ", p-an-uchet-code-out-payoff).
    run err-mess in this-procedure ( input-output v-err-mess  ).
    undo, return error (if p-silent = yes then v-err-mess else "an-uchet-code-out-payoff":U).
  end.
end.
else do:
 p-an-uchet-code-out-payoff = 0.
end.
if p-cel-nazn-code-out-payoff <> ?
and p-cel-nazn-code-out-payoff <> 0 then do:
  find first buf_fin-code-cel-nazn no-lock where
          buf_fin-code-cel-nazn.fin-code  = p-cel-nazn-code-out-payoff
      and buf_fin-code-cel-nazn.host-code = p-host-code no-error .
  if not available buf_fin-code-cel-nazn then do:
    v-err-mess = substitute("Не найден код целевого назначения учета для Рс.АПЗ", p-an-uchet-code-out-payoff).
    run err-mess in this-procedure ( input-output v-err-mess  ).
    undo, return error (if p-silent = yes then v-err-mess else "cel-nazn-code-out-payoff":U).
  end.
end.
else do:
  p-cel-nazn-code-out-payoff = 0.
end.
if p-cor-acc-out-payoff <> ?
and p-cor-acc-out-payoff <> 0 then do:
  find first buf_fin-code-cor-acc no-lock where
            buf_fin-code-cor-acc.fin-code  = p-cor-acc-out-payoff
        and buf_fin-code-cor-acc.host-code = p-host-code no-error .
  if not available buf_fin-code-cor-acc then do:
    v-err-mess = substitute("Не найден корреспондирующий счет для Рс.АПЗ", p-cor-acc-out-payoff).
    run err-mess in this-procedure ( input-output v-err-mess  ).
    undo, return error (if p-silent = yes then v-err-mess else "cor-acc-out-payoff":U).
  end.
end.
else do:
  p-cor-acc-out-payoff = 0.
end.
if p-cor-acc1-out-payoff <> ?
and p-cor-acc1-out-payoff <> 0 then do:
  find first buf_fin-code-cor-acc no-lock where
            buf_fin-code-cor-acc.fin-code  = p-cor-acc1-out-payoff
        and buf_fin-code-cor-acc.host-code = p-host-code no-error .
  if not available buf_fin-code-cor-acc then do:
    v-err-mess = substitute("Не найден корр.счет (касса) для Рс.АПЗ", p-cor-acc1-out-payoff).
    run err-mess in this-procedure ( input-output v-err-mess  ).
    undo, return error (if p-silent = yes then v-err-mess else "cor-acc-1-out-payoff":U).
  end.
end.
else do:
  p-cor-acc1-out-payoff = 0.
end.
if p-an-uchet-code-in-payoff <> ?
and p-an-uchet-code-in-payoff <> 0 then do:
  find first buf_fin-code-an-uchet no-lock where
          buf_fin-code-an-uchet.fin-code = p-an-uchet-code-in-payoff
      and buf_fin-code-an-uchet.host-code = p-host-code no-error .
  if not available buf_fin-code-an-uchet then do:
    v-err-mess = substitute("Не найден код аналитического учета для Пр.АПЗ", p-an-uchet-code-in-payoff).
    run err-mess in this-procedure ( input-output v-err-mess  ).
    undo, return error (if p-silent = yes then v-err-mess else "an-uchet-code-in-payoff":U).
  end.
end.
else do:
  p-an-uchet-code-in-payoff = 0.
end.
if p-cel-nazn-code-in-payoff <> ?
and p-cel-nazn-code-in-payoff <> 0 then do:
  find first buf_fin-code-cel-nazn no-lock where
          buf_fin-code-cel-nazn.fin-code  = p-cel-nazn-code-in-payoff
      and buf_fin-code-cel-nazn.host-code = p-host-code no-error .
  if not available buf_fin-code-cel-nazn then do:
    v-err-mess = substitute("Не найден код целевого назначения учета для Пр.АПЗ", p-an-uchet-code-in-payoff).
    run err-mess in this-procedure ( input-output v-err-mess  ).
    undo, return error (if p-silent = yes then v-err-mess else "cel-nazn-code-in-payoff":U).
  end.
end.
else do:
 p-cel-nazn-code-in-payoff = 0.
end.
if p-cor-acc-in-payoff <> ?
and p-cor-acc-in-payoff <> 0 then do:
  find first buf_fin-code-cor-acc no-lock where
            buf_fin-code-cor-acc.fin-code  = p-cor-acc-in-payoff
        and buf_fin-code-cor-acc.host-code = p-host-code no-error .
  if not available buf_fin-code-cor-acc then do:
    v-err-mess = substitute("Не найден корреспондирующий счет для Пр.АПЗ", p-cor-acc-in-payoff) .
    run err-mess in this-procedure ( input-output v-err-mess ).
    undo, return error (if p-silent = yes then v-err-mess else "cor-acc-in-payoff":U).
  end.
end.
else do:
  p-cor-acc-in-payoff = 0 .
end.
if p-cor-acc1-in-payoff <> ?
and p-cor-acc1-in-payoff <> 0 then do:
  find first buf_fin-code-cor-acc no-lock where
            buf_fin-code-cor-acc.fin-code  = p-cor-acc1-in-payoff
        and buf_fin-code-cor-acc.host-code = p-host-code no-error .
  if not available buf_fin-code-cor-acc then do:
    v-err-mess = substitute("Не найден корр.счет (касса) для Пр.АПЗ", p-cor-acc1-in-payoff).
    run err-mess in this-procedure ( input-output v-err-mess  ).
    undo, return error (if p-silent = yes then v-err-mess else "cor-acc-1-in-payoff":U).
  end.
end.
else do:
  p-cor-acc1-in-payoff = 0 .
end.
end.
main-block:
do for
buf_sysconf
on error undo, return error return-value
on stop undo, return error return-value
:
  find first buf_sysconf where
              recid(buf_sysconf) = p-rec no-error .
  if not available buf_sysconf then do:
    v-err-mess = substitute("Не найдена запись СВОЯ ФИРМА - p-rec &1", p-rec).
    run err-mess in this-procedure ( input-output v-err-mess).
    undo main-block, return error "":U.
  end.
  if buf_sysconf.host-code <> p-host-code then do:
    message
    "Неверно задан параметр p-rec или p-host-code"
    view-as alert-box error .
    undo main-block, return error "":U.
  end.
  assign
  buf_sysconf.contract-city               = p-contract-city
  buf_sysconf.contract-type               = p-contract-type
  buf_sysconf.pay-sign-post               = p-pay-sign-post
  buf_sysconf.pay-sign                    = p-pay-sign
  buf_sysconf.fin-VAT-pc                  = p-fin-VAT-pc
  buf_sysconf.srok-opl                    = p-srok-opl
  buf_sysconf.srok-opl-sf                 = p-srok-opl-sf
  buf_sysconf.usl-opl                     = p-usl-opl
  buf_sysconf.usl-opl-sf                  = p-usl-opl-sf
  buf_sysconf.is-an-uchet                 = p-is-an-uchet
  buf_sysconf.is-code-cel-nazn            = p-is-code-cel-nazn
  buf_sysconf.is-corr-acc                 = p-is-corr-acc
  buf_sysconf.is-cassa-acc                = p-is-cassa-acc
  buf_sysconf.fin-calc                    = p-fin-calc
  buf_sysconf.pay-code-schet-rubl         = p-pay-code-schet-rubl
  buf_sysconf.pay-code-schet-base         = p-pay-code-schet-base
  buf_sysconf.an-uchet-code-out           = p-an-uchet-code-out
  buf_sysconf.cel-nazn-code-out           = p-cel-nazn-code-out
  buf_sysconf.cor-acc-out                 = p-cor-acc-out
  buf_sysconf.cor-acc1-out                = p-cor-acc1-out
  buf_sysconf.an-uchet-code-in            = p-an-uchet-code-in
  buf_sysconf.cel-nazn-code-in            = p-cel-nazn-code-in
  buf_sysconf.cor-acc-in                  = p-cor-acc-in
  buf_sysconf.cor-acc1-in                 = p-cor-acc1-in
  buf_sysconf.an-uchet-code-out-cash      = p-an-uchet-code-out-cash
  buf_sysconf.cel-nazn-code-out-cash      = p-cel-nazn-code-out-cash
  buf_sysconf.cor-acc-out-cash            = p-cor-acc-out-cash
  buf_sysconf.cor-acc1-out-cash           = p-cor-acc1-out-cash
  buf_sysconf.an-uchet-code-in-cash       = p-an-uchet-code-in-cash
  buf_sysconf.cel-nazn-code-in-cash       = p-cel-nazn-code-in-cash
  buf_sysconf.cor-acc-in-cash             = p-cor-acc-in-cash
  buf_sysconf.cor-acc1-in-cash            = p-cor-acc1-in-cash
  buf_sysconf.an-uchet-code-out-payoff    = p-an-uchet-code-out-payoff
  buf_sysconf.cel-nazn-code-out-payoff    = p-cel-nazn-code-out-payoff
  buf_sysconf.cor-acc-out-payoff          = p-cor-acc-out-payoff
  buf_sysconf.cor-acc1-out-payoff         = p-cor-acc1-out-payoff
  buf_sysconf.an-uchet-code-in-payoff     = p-an-uchet-code-in-payoff
  buf_sysconf.cel-nazn-code-in-payoff     = p-cel-nazn-code-in-payoff
  buf_sysconf.cor-acc-in-payoff           = p-cor-acc-in-payoff
  buf_sysconf.cor-acc1-in-payoff          = p-cor-acc1-in-payoff
  .
  release buf_sysconf no-error.
  if error-status:error then do:
    v-err-mess = substitute("Ошибка при сохранении записи СВОЯ ФИРМА &1: &2", p-host-code, ERROR-STATUS:GET-message(1)).
    run err-mess in this-procedure ( input-output v-err-mess ).
    undo main-block, return error (if p-silent = yes then v-err-mess else '':U).
  end.
  if p-fin-copy then do:
    run utl/fin-init.p (
                    input p-fin-host-copy
                  , input p-host-code
                  , input yes
                  , input yes
                  , input yes
                  , input yes) no-error .
    if error-status:error then do:
      v-err-mess = substitute("Ошибка при копировании настроек блока ВЗАИМОРАСЧЕТЫ с фирмы &1 на фирму &2: &3", p-fin-host-copy, p-host-code, ERROR-STATUS:GET-message(1)).
      run err-mess in this-procedure ( input-output v-err-mess ).
      undo, return error (if p-silent = yes then v-err-mess else '':U).
    end.
  end.
end.
PROCEDURE err-mess:
  DEFINE INPUT-output PARAMETER p-mess as character No-UNDO.
  CASE p-silent:
    when yes then do:
      p-mess = substitute("СВОЯ ФИРМА &1: &2", p-host-code,  p-mess).
    end.
    otherwise do:
      message
      p-mess
      view-as alert-box error .
    end.
  end.
END PROCEDURE.
