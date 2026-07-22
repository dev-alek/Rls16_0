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
def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: findoc04.p $":U .
def var vss-archive     as character no-undo init "$Archive: ref/findoc04.p $":U .
def var vss-description as character no-undo init "Проверка платежа типа expense-cashless".
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
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-is-an-uchet as logical no-undo .
define variable v-dopi as integer no-undo .
define variable v-reason as character no-undo .
define variable v-author as character no-undo .
define buffer buf_fin-code-cor-acc for ub.fin-code-cor-acc.
define buffer buf_fin-doc for ub.fin-doc.
define buffer buf_sysconf for ub.sysconf.
define buffer buf_fin-connect for ub.fin-connect.
FUNCTION check-f107 RETURNS LOGICAL(input  p-f107 as character,
                                    output p-reason as character):
define variable v-dopi as integer no-undo .
define variable v-dopdate as date no-undo .
if length(p-f107) <> 10 then do:
  assign
  p-reason = "длина должна быть 10 знаков"
  .
  return no.
end.
if substr(p-f107, 3, 1) <> ".":U
or substr(p-f107, 6, 1) <> ".":U then do:
  assign
  p-reason = "3-й и 6-й знаки должны быть точками".
  .
  return no.
end.
assign
v-dopi = integer(substr(p-f107, 1, 2))
no-error .
if not error-status:error then do:
  assign
  v-dopdate = date(
                   integer(substr(p-f107, 4, 2))
                  , integer(substr(p-f107, 1, 2))
                  , integer(substr(p-f107, 7, 4))
                 )
  no-error .
  if error-status:error then do:
    assign
    p-reason = "не соответствует никакой дате"
    .
    return no.
  end.
end.
if LOOKUP(substr(p-f107, 1, 2), "Д1,Д2,Д3,МС,КВ,ПЛ,ГД":U) = 0 then do:
  assign
  p-reason = substitute("первые два знака должно быть одни из &1", "Д1,Д2,Д3,МС,КВ,ПЛ,ГД":U).
  .
  return no.
end.
assign
v-dopi = integer(substr(p-f107, 4, 2))
no-error .
CASE substr(p-f107, 1, 2):
  when "Д1":U
  or
  when "Д2":U
  or
  when "Д3":U
  or
  when "МС":U then do:
    if error-status:error
    or v-dopi < 1
    or v-dopi > 12 then do:
      assign
      p-reason = "4 и 5 знак должны быть равны номеру месяца -от 01 до 12".
      .
      return no.
    end.
  end.
  when "КВ":U then do:
    if error-status:error
    or v-dopi < 1
    or v-dopi > 4 then do:
      assign
      p-reason = "4 и 5 знак должны быть равны номеру квартала -от 01 до 04".
      .
      return no.
    end.
  end.
  when "ПЛ":U then do:
    if error-status:error
    or v-dopi < 1
    or v-dopi > 2 then do:
      assign
      p-reason = "4 и 5 знак должны быть равны номеру полугодия -от 01 до 02".
      .
      return no.
    end.
  end.
  when "ГД":U then do:
    if error-status:error
    or v-dopi <> 0 then do:
      assign
      p-reason = "4 и 5 знак должны быть равны 00".
      .
      return no.
    end.
  end.
END CASE.
assign
p-reason = "":U.
RETURN yes.
END FUNCTION.
FUNCTION check-f109 RETURNS LOGICAL(input  p-f109 as character,
                                    output p-reason as character):
define variable v-dopdate as date no-undo .
if length(p-f109) <> 10 then do:
  assign
  p-reason = "длина должна быть 10 знаков"
  .
  return no.
end.
if substr(p-f109, 3, 1) <> ".":U
or substr(p-f109, 6, 1) <> ".":U then do:
  assign
  p-reason = "3-й и 6-й знаки должны быть точками".
  .
  return no.
end.
assign
v-dopdate = date(
                  integer(substr(p-f109, 4, 2))
                , integer(substr(p-f109, 1, 2))
                , integer(substr(p-f109, 7, 4))
                )
no-error .
if error-status:error then do:
  assign
  p-reason = "не соответствует никакой дате"
  .
  return no.
end.
assign
p-reason = "":U.
RETURN yes.
END FUNCTION.
procedure income-expense-gen :
define input parameter p-close-mode as character no-undo .
define output parameter p-correct as logical no-undo .
define buffer buf_firm for ub.firm.
define buffer buf_person for ub.person.
do
on error undo, return error
:
  find first buf_sysconf no-lock where
            buf_sysconf.host-code = p-host-code .
  if p-status_ = 'разрешен':U
  or v-author = 'cl-bank':U
  then do:
    if p-naznach-plat = "":U then do:
      assign
      p-err-mess = "Не заполнено основание платежа"
      .
      return "naznach-plat":u.
    end.
    if p-vid-opl <> '01':U then do:
      assign
      p-err-mess = "Неверное значение поля <Вид оп.>"
      .
      return "vid-opl":u.
    end.
  end.
  if p-status_ = 'факт':U then do:
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
    if p-prn-doc-code = "":U then do:
      assign
      p-err-mess = "Не заполнен номер платежа"
      .
      return "prn-doc-code":U.
    end.
  end.
  if p-status_ = 'факт':U then do:
    if buf_sysconf.is-corr-acc
    and (p-cor-acc = ? or p-cor-acc = 0) then do:
      assign
      p-err-mess = "Не заполнен корр. счет/субсчет"
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
  if LOOKUP(p-vid-plat , 'почтой,телеграфом,электронно,':U) = 0 then do:
    assign
    p-err-mess = "Неверный тип платежа -должен быть один из" + chr(32) + 'почтой,телеграфом,электронно,':U
    .
    return "vid-plat":U.
  end.
  if p-status_ = 'разрешен':U
  or v-author = 'cl-bank':U
  then do:
    if p-payer-inn = "":U then do:
      assign
      p-err-mess = "Не заполнен ИНН ПЛАТЕЛЬЩИКА"
      .
      return "payer-inn":U.
    end.
    if p-payer-kpp = "":U
    then do:
      CASE p-payer-type:
        when 'орг':U then do:
          find first buf_firm no-lock where
                    buf_firm.firm-code = p-payer-code .
        end.
        when 'чел':U then do:
          find first buf_person no-lock where
                    buf_person.psn-code = p-payer-code .
        end.
      END CASE.
    end.
    if p-payer-bik = "":U then do:
      assign
      p-err-mess = "Не заполнен БИК ПЛАТЕЛЬЩИКА"
      .
          message p-err-mess skip
              "Закрывать документ ? "
              view-as alert-box question
              buttons yes-no
              title "ВНИМАНИЕ !!!"
              update v-ok3 as logical.
          if not v-ok3 then do:
             return "payer-bik":U.
          end.
    end.
    if p-payer-r-schet = "":U then do:
      assign
      p-err-mess = "Не заполнен р/с ПЛАТЕЛЬЩИКА"
      .
      return "payer-r-schet":U.
    end.
    if p-payer-bank-name = "":U then do:
      assign
      p-err-mess = "Не заполнен банк ПЛАТЕЛЬЩИКА"
      .
      return "payer-bank-name":U.
    end.
    if p-payer-c-schet = "":U then do:
      if not (
              (substring(p-payer-bik, 7, 9) = '000'
              or
              substring(p-payer-bik, 7, 9) = '001'
              or
              substring(p-payer-bik, 7, 9) = '002'
              )
              and not
              ( "руб" = "тг."
                or "руб" = "грн"
                or "руб" = "дрм"
                or "руб" = "lei")
             )
      then do:
        assign
        p-err-mess = "Не заполнен к/с ПЛАТЕЛЬЩИКА"
        .
        define variable v-nocoracc as character no-undo .
        define variable v-conf-type as character no-undo .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'nocoracc'
  ,input  0
  ,input  '':U
  ,input  0
  ,input  '':U
  ,input  '':U
  ,input  '':U
  ,input  NO
  ,output v-nocoracc
  ,output v-conf-type
  ) NO-ERROR .
        IF ERROR-STATUS:ERROR OR v-conf-type <> 'L':U THEN v-nocoracc = "no".
        if v-nocoracc = "no" then   return "payer-c-schet":U.
      end.
    end.
    if p-receiver-inn = "":U then do:
      assign
      p-err-mess = "Не заполнен ИНН ПОЛУЧАТЕЛЯ"
      .
      return "receiver-inn":U.
    end.
    if p-receiver-kpp = "":U then do:
      CASE p-receiver-type:
        when 'орг':U then do:
          find first buf_firm no-lock where
                    buf_firm.firm-code = p-receiver-code .
        end.
        when 'чел':U then do:
          find first buf_person no-lock where
                    buf_person.psn-code = p-receiver-code .
        end.
      END CASE.
    end.
    if p-receiver-bik = "":U then do:
      assign
      p-err-mess = "Не заполнен БИК ПОЛУЧАТЕЛЯ"
      .
          message p-err-mess skip
              "Закрывать документ ? "
              view-as alert-box question
              buttons yes-no
              title "ВНИМАНИЕ !!!"
              update v-ok4 as logical.
          if not v-ok4 then do:
             return "receiver-bik":U.
          end.
    end.
    if p-receiver-r-schet = "":U then do:
      assign
      p-err-mess = "Не заполнен р/с ПОЛУЧАТЕЛЯ"
      .
      return "receiver-r-schet":U.
    end.
    if p-receiver-bank-name = "":U then do:
      assign
      p-err-mess = "Не заполнен банк ПОЛУЧАТЕЛЯ"
      .
      return "receiver-bank-name":U.
    end.
    if p-receiver-c-schet = "":U then do:
      if not (
             (substring(p-receiver-bik, 7, 9) = '000'
              or
              substring(p-receiver-bik, 7, 9) = '001'
              or
              substring(p-receiver-bik, 7, 9) = '002'
              )
              and not
              ( "руб" = "тг."
                or "руб" = "грн"
                or "руб" = "дрм"
                or "руб" = "lei")
             )
       then do:
        assign
        p-err-mess = "Не заполнен к/с ПОЛУЧАТЕЛЯ"
        .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'nocoracc'
  ,input  0
  ,input  '':U
  ,input  0
  ,input  '':U
  ,input  '':U
  ,input  '':U
  ,input  NO
  ,output v-nocoracc
  ,output v-conf-type
  ) NO-ERROR .
        IF ERROR-STATUS:ERROR OR v-conf-type <> 'L':U THEN v-nocoracc = "no".
        if v-nocoracc = "no" then   return "payer-c-schet":U.
      end.
    end.
    assign
    v-dopi =  integer(p-ocher-pl)
    no-error .
    if error-status:error
    or v-dopi < 1 or v-dopi > 6 then do:
      assign
      p-err-mess = "Неверно заполнено поле очередность платежа"
      .
      return "ocher-pl":U.
    end.
    if p-stat-pl <> "":U then do:
      if lookup(p-stat-pl, '01,02,03,04,05,06,07,08':U) = 0 then do:
        assign
        p-err-mess = "Неверно заполнено поле статус плательщика"
        .
        return "stat-pl":U.
      end.
      if p-f104 = "":U then do:
        assign
        p-err-mess = "Не заполнено поле показателя Кода Бюджетной Классификации"
        .
        return "f-104":U.
      end.
      if p-f105 = "":U then do:
        assign
        p-err-mess = "Не заполнено поле кода ОКАТО"
        .
        return "f-105":U.
      end.
      if p-f106 = "":U
      or lookup(p-f106, 'ТП,ЗД,ТР,РС,ОТ,РТ,ВУ,ПР,АП,АР,0':U) = 0
      then do:
        assign
        p-err-mess = "Не заполнено или неверно заполнено поле показателя основания платежа"
        .
        return "f-106":U.
      end.
      if p-f107 = "":U
      or check-f107(p-f107, output v-reason) = no
      then do:
        assign
        p-err-mess = substitute("Не заполнено или неверно заполнено поле показателя налового периода: &1", v-reason)
        .
        return "f-107":U.
      end.
      if (p-f106 = "ТП":U
      or p-f106 = "ЗД":U )
      and p-f108 <> "0":U then do:
        assign
        p-err-mess = substitute("Неверно заполнено поле показателя номера документа: если показатель основания платежа = &1, то там должно стоять <0>", p-f106)
        .
        return "f-108":U.
      end.
      if p-f109 = "":U
      or check-f109(p-f109, output v-reason) = no
      then do:
        assign
        p-err-mess = substitute("Не заполнено или неверно заполнено поле показателя даты документа: &1", v-reason)
        .
        return "f-109":U.
      end.
      if p-f110 = "":U
      or lookup(p-f110, 'НС,АВ,ПЕ,ПЦ,СА,АШ,ИШ,0':U) = 0
      then do:
        assign
        p-err-mess = "Не заполнено или неверно заполнено поле показателя типа платежа"
        .
        return "f-110":U.
      end.
    end.
  end.
  if p-close-mode = '<закрытие документа>':U
  or p-close-mode = '<отказ от документа>':U
  then do:
    if (p-perm-date <> ? and p-doc-date > p-perm-date )
    or (p-status-date <> ? and p-doc-date > p-status-date and p-status_ = 'разрешен':U)
    then do:
      assign
      p-err-mess = "Дата разр не может быть меньше даты док"
      .
      return "perm-date":U.
    end.
    if (p-pay-date <> ? and p-perm-date > p-pay-date)
    or (p-status-date <> ? and p-perm-date > p-status-date and p-status_ = 'банк':U )  then do:
      assign
      p-err-mess = "Дата оплаты не может быть меньше даты разр"
      .
      return "pay-date":U.
    end.
    if (p-fact-date <> ? and p-pay-date > p-fact-date)
    or (p-status-date <> ? and p-pay-date > p-status-date and (p-status_ = 'факт':U or p-status_ = 'отказ':U))
      then do:
      assign
      p-err-mess = "Дата факт (или дата отказ) не может быть меньше даты платежа".
      return "fact-date":U.
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
  assign
  v-author = (if num-entries(p-mode, chr(4)) > 1
            then entry(2, p-mode, chr(4))
            else '':U)
  p-mode = entry(1, p-mode, chr(4))
  .
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
