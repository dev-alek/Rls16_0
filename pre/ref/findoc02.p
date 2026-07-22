block-level on error undo, throw.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define input parameter p-mode as character no-undo .
define input parameter p-close-mode as character no-undo .
define input parameter p-host-code           like ub.fin-doc.host-code            no-undo . define input parameter p-fin-doc-code        like ub.fin-doc.fin-doc-code         no-undo . define input parameter p-an-uchet-code       like ub.fin-doc.an-uchet-code        no-undo . define input parameter p-an-uchet-value      like ub.fin-doc.an-uchet-value       no-undo . define input parameter p-base-rate           like ub.fin-doc.base-rate            no-undo . define input parameter p-base-scale          like ub.fin-doc.base-scale           no-undo . define input parameter p-cel-nazn-code       like ub.fin-doc.cel-nazn-code        no-undo . define input parameter p-cel-nazn-value      like ub.fin-doc.cel-nazn-value       no-undo . define input parameter p-contract-code       like ub.fin-doc.contract-code        no-undo . define input parameter p-contract-curr       like ub.fin-doc.contract-curr        no-undo . define input parameter p-contract-rate       like ub.fin-doc.contract-rate        no-undo . define input parameter p-contract-scale      like ub.fin-doc.contract-scale       no-undo . define input parameter p-cor-acc             like ub.fin-doc.cor-acc              no-undo . define input parameter p-cor-acc-value       like ub.fin-doc.cor-acc-value        no-undo . define input parameter p-cor-acc1            like ub.fin-doc.cor-acc1             no-undo . define input parameter p-cor-acc1-value      like ub.fin-doc.cor-acc1-value       no-undo . define input parameter p-curr-code           like ub.fin-doc.curr-code            no-undo . define input parameter p-doc-date            like ub.fin-doc.doc-date             no-undo . define input parameter p-shift-date          like ub.fin-doc.shift-dat            no-undo . define input parameter p-shift-num           like ub.fin-doc.shift-num            no-undo . define input parameter p-shift-name          like ub.fin-doc.shift-name           no-undo . define input parameter p-enclosure           like ub.fin-doc.enclosure            no-undo . define input parameter p-exch-rate           like ub.fin-doc.exch-rate            no-undo . define input parameter p-exch-scale          like ub.fin-doc.exch-scale           no-undo . define input parameter p-f104                like ub.fin-doc.f104                 no-undo . define input parameter p-f105                like ub.fin-doc.f105                 no-undo . define input parameter p-f106                like ub.fin-doc.f106                 no-undo . define input parameter p-f107                like ub.fin-doc.f107                 no-undo . define input parameter p-f108                like ub.fin-doc.f108                 no-undo . define input parameter p-f109                like ub.fin-doc.f109                 no-undo . define input parameter p-f110                like ub.fin-doc.f110                 no-undo . define input parameter p-f22                 like ub.fin-doc.f22                  no-undo . define input parameter p-f23                 like ub.fin-doc.f23                  no-undo . define input parameter p-fact-date           like ub.fin-doc.fact-date            no-undo . define input parameter p-fin-doc-type        like ub.fin-doc.fin-doc-type         no-undo . define input parameter p-fin-ext-doc-type    like ub.fin-doc.fin-ext-doc-type     no-undo . define input parameter p-in-doc-code         like ub.fin-doc.in-doc-code          no-undo . define input parameter p-in-host-code        like ub.fin-doc.in-host-code         no-undo . define input parameter p-including           like ub.fin-doc.including            no-undo . define input parameter p-nazn-pl             like ub.fin-doc.nazn-pl              no-undo . define input parameter p-naznach-plat        like ub.fin-doc.naznach-plat         no-undo . define input parameter p-ocher-pl            like ub.fin-doc.ocher-pl             no-undo . define input parameter p-out-doc-code        like ub.fin-doc.out-doc-code         no-undo . define input parameter p-out-host-code       like ub.fin-doc.out-host-code        no-undo . define input parameter p-pay-date            like ub.fin-doc.pay-date             no-undo . define input parameter p-payer-bank-name     like ub.fin-doc.payer-bank-name      no-undo . define input parameter p-payer-bank-city     like ub.fin-doc.payer-bank-city      no-undo . define input parameter p-payer-bik           like ub.fin-doc.payer-bik            no-undo . define input parameter p-payer-c-schet       like ub.fin-doc.payer-c-schet        no-undo . define input parameter p-payer-code          like ub.fin-doc.payer-code           no-undo . define input parameter p-payer-code-schet    like ub.fin-doc.payer-code-schet     no-undo . define input parameter p-payer-dop1          like ub.fin-doc.payer-dop1           no-undo . define input parameter p-payer-dop2          like ub.fin-doc.payer-dop2           no-undo . define input parameter p-payer-inn           like ub.fin-doc.payer-inn            no-undo . define input parameter p-payer-kpp           like ub.fin-doc.payer-kpp            no-undo . define input parameter p-payer-name          like ub.fin-doc.payer-name           no-undo . define input parameter p-payer-okpo          like ub.fin-doc.payer-okpo           no-undo . define input parameter p-payer-passport      like ub.fin-doc.payer-passport       no-undo . define input parameter p-payer-r-schet       like ub.fin-doc.payer-r-schet        no-undo . define input parameter p-payer-type          like ub.fin-doc.payer-type           no-undo . define input parameter p-perm-date           like ub.fin-doc.perm-date            no-undo . define input parameter p-prn-doc-code        like ub.fin-doc.prn-doc-code         no-undo . define input parameter p-PS                  like ub.fin-doc.PS                   no-undo . define input parameter p-receiver-bank-name  like ub.fin-doc.receiver-bank-name   no-undo . define input parameter p-receiver-bank-city  like ub.fin-doc.receiver-bank-city   no-undo . define input parameter p-receiver-bik        like ub.fin-doc.receiver-bik         no-undo . define input parameter p-receiver-c-schet    like ub.fin-doc.receiver-c-schet     no-undo . define input parameter p-receiver-code       like ub.fin-doc.receiver-code        no-undo . define input parameter p-receiver-code-schet like ub.fin-doc.receiver-code-schet  no-undo . define input parameter p-receiver-dop1       like ub.fin-doc.receiver-dop1        no-undo . define input parameter p-receiver-dop2       like ub.fin-doc.receiver-dop2        no-undo . define input parameter p-receiver-inn        like ub.fin-doc.receiver-inn         no-undo . define input parameter p-receiver-kpp        like ub.fin-doc.receiver-kpp         no-undo . define input parameter p-receiver-name       like ub.fin-doc.receiver-name        no-undo . define input parameter p-receiver-okpo       like ub.fin-doc.receiver-okpo        no-undo . define input parameter p-receiver-passport   like ub.fin-doc.receiver-passport    no-undo . define input parameter p-receiver-r-schet    like ub.fin-doc.receiver-r-schet     no-undo . define input parameter p-receiver-type       like ub.fin-doc.receiver-type        no-undo . define input parameter p-srok-pl             like ub.fin-doc.srok-pl              no-undo . define input parameter p-stat-pl             like ub.fin-doc.stat-pl              no-undo . define input parameter p-str-podr-code       like ub.fin-doc.str-podr-code        no-undo . define input parameter p-str-podr-type       like ub.fin-doc.str-podr-type        no-undo . define input parameter p-str-podr-name       like ub.fin-doc.str-podr-name        no-undo . define input parameter p-sum-base            like ub.fin-doc.sum-base             no-undo . define input parameter p-sum-doc             like ub.fin-doc.sum-doc              no-undo . define input parameter p-sum-rubl            like ub.fin-doc.sum-rubl             no-undo . define input parameter p-sum-contr           like ub.fin-doc.sum-contr            no-undo . define input parameter p-trn-doc-code        like ub.fin-doc.trn-doc-code         no-undo . define input parameter p-vid-opl             like ub.fin-doc.vid-opl              no-undo . define input parameter p-vid-plat            like ub.fin-doc.vid-plat             no-undo .
define input parameter p-con-sum-rubl        like ub.fin-doc.con-sum-rubl         no-undo . define input parameter p-con-sum-base        like ub.fin-doc.con-sum-base         no-undo . define input parameter p-con-sum-doc         like ub.fin-doc.con-sum-doc          no-undo . define input parameter p-con-sum-contr       like ub.fin-doc.con-sum-contr        no-undo . define input parameter p-con-stat            like ub.fin-doc.con-stat             no-undo . define input parameter p-payer-sign1               like ub.fin-doc.payer-sign1                no-undo . define input parameter p-payer-sign2               like ub.fin-doc.payer-sign2                no-undo . define input parameter p-payer-sign3               like ub.fin-doc.payer-sign3                no-undo . define input parameter p-payer-sign4               like ub.fin-doc.payer-sign4                no-undo . define input parameter p-receiver-sign1               like ub.fin-doc.receiver-sign1                no-undo . define input parameter p-receiver-sign2               like ub.fin-doc.receiver-sign2                no-undo . define input parameter p-receiver-sign3               like ub.fin-doc.receiver-sign3                no-undo . define input parameter p-receiver-sign4               like ub.fin-doc.receiver-sign4                no-undo . define input parameter p-obj-type                  like ub.fin-doc.obj-type                  no-undo . define input parameter p-obj-code                  like ub.fin-doc.obj-code                  no-undo . define input parameter p-doc-author                like ub.fin-doc.doc-author                no-undo . define input parameter p-fact-author               like ub.fin-doc.fact-author               no-undo . define input parameter p-cashbookid               like ub.fin-doc.CashBookId                no-undo .
define input parameter p-status_ like ub.fin-doc.status_ no-undo .
define input parameter p-status-date like ub.fin-doc.doc-date no-undo .
define output parameter p-correct as logical no-undo .
define output parameter p-err-mess as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: findoc02.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/findoc02.p $":U .
define variable vss-description as character no-undo init "Проверка платежа типа expense-cash".
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
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define buffer buf_fin-code-cor-acc for ub.fin-code-cor-acc.
define buffer buf_fin-doc for ub.fin-doc.
define buffer buf_sysconf for ub.sysconf.
define buffer buf_fin-connect for ub.fin-connect.
procedure income-expense-gen :
define input parameter p-close-mode as character no-undo .
define output parameter p-correct as logical no-undo .
do
on error undo, return error
:
  find first buf_sysconf no-lock where
            buf_sysconf.host-code = p-host-code .
  if p-status_ = 'разрешен':U then do:
    if p-naznach-plat = "":U
    and p-CashBookId = 0
    then do:
      assign
      p-err-mess = "Не заполнено основание платежа"
      .
      return "naznach-plat":u.
    end.
    if p-receiver-passport = "":U then do:
      p-err-mess = "Нет данных о документе, удостоверяющем личность ПОЛУЧАТЕЛЯ"
      .
    end.
  end.
  if p-status_ = 'факт':U then do:
    if p-prn-doc-code = "":U then do:
      assign
      p-err-mess = "Не заполнен номер платежа"
      .
      return "prn-doc-code":U.
    end.
    find first buf_fin-connect no-lock where
            buf_fin-connect.host-code      = p-host-code
        AND buf_fin-connect.fin-doc-code   = p-fin-doc-code no-error.
    if not available buf_fin-connect then do:
      if buf_sysconf.fin-calc = 1
      and p-obj-type = "":U and p-obj-code = 0
      then do:
        p-err-mess = substitute("Финансовый учет на фирме ведется пообъектно, а объект не задан")
        .
        return error "obj-code":U.
      end.
    end.
  end.
  if p-status_ = 'факт':U then do:
    if buf_sysconf.is-cassa-acc
    and (p-cor-acc1 = ? or p-cor-acc1 = 0) then do:
      if p-fin-doc-type = 'пко':U then
      assign
      p-err-mess = "Не заполнен счет/субсчет по дебету"
      .
      else
      assign
      p-err-mess = "Не заполнен счет/субсчет по кредиту"
      .
      return "cor-acc1":U.
    end.
    if buf_sysconf.is-corr-acc
    and (p-cor-acc = ? or p-cor-acc = 0) then do:
      if p-fin-doc-type = 'пко':U then
      assign
      p-err-mess = "Не заполнен счет/субсчет по кредиту"
      .
      else
      assign
      p-err-mess = "Не заполнен счет/субсчет по дебету"
      .
      return "cor-acc":U.
    end.
    if buf_sysconf.is-code-cel-nazn
    and (p-cel-nazn-code = ? or p-cel-nazn-code = 0) then do:
      assign
      p-err-mess = "Не заполнен код целевого назначения"
      .
      return "cel-nazn-code":U.
    end.
    if buf_sysconf.is-an-uchet
    and (p-an-uchet-code = ? or p-an-uchet-code = 0) then do:
      assign
      p-err-mess = "Не заполнен код аналитического учета"
      .
      return  "an-uchet-code":U.
    end.
  end.
  assign
  p-correct = yes
  .
end.
end procedure.
do
on error undo, return error
  :
  run income-expense-gen in this-procedure(input p-close-mode, output p-correct) no-error .
  if error-status:error then do:
    return "Ошибка в процедуре проверки валидности платежа".
  end.
  else do:
    if p-correct = no then return return-value.
  end.
  assign
  p-correct = yes
  .
end.
