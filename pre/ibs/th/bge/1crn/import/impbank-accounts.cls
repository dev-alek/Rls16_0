using Progress.Lang.*.
using ibs.th.bge.1crn.subjects.*.
USING ibs.th.trg.newbcod from propath.
USING ibs.th.gbl.curdburt from propath.
block-level on error undo, throw.
class ibs.th.bge.1crn.import.impbank-accounts implements ibs.th.bge.1crn.import.iimpsubject:
  define property Msg as character no-undo
    get.
    set.
  method public logical Excute( subjectObj as class ibs.th.bge.1crn.subjects.isubject ):
    define variable ri as recid no-undo .
    define buffer buf_fin-bank    for ub.fin-bank .
    define buffer buf_fin-schet   for ub.fin-schet .
    define buffer X_schet-clients for ub.clients .
    DEFINE BUFFER X_currency      FOR ub.currency.
    define variable v-curr-code       as integer   no-undo .
    define variable v-code-bank       as integer   no-undo .
    define variable v-code-bank-schet as integer   no-undo .
    define variable v-mode            as character no-undo .
    define variable v-mode-bank       as character no-undo .
    define variable v-doc-rec         as recid     no-undo .
    define variable v-host-code       as integer   no-undo .
    define variable v-obj-code        as integer   no-undo .
    define variable v-status_         as character no-undo .
    define variable objBank-Accounts  as class     bank-accounts      no-undo.
    define variable objBank           as class     bank-accounts_bank no-undo .
    objBank-Accounts = cast (subjectObj, bank-accounts).
    if objBank-Accounts:del-f > 0 then do:
      Msg = "физическое удаление банковских счетов не предусмотрено".
      return false.
    end.
    find first sysconf no-lock no-error.
    if AVAILABLE (sysconf) then v-host-code = sysconf.host-code .
    else do:
      Msg = "Не найдена фирма" .
      return false.
    end.
    v-obj-code = integer(objBank-Accounts:cont-code) no-error .
    if error-status:error then do :
      Msg = substitute("ошибка преобразования в число значения cont-code = &1", objBank-Accounts:cont-code) .
      return false.
    end .
    if objBank-Accounts:del-l > 0 then do:
      find first buf_fin-schet EXCLUSIVE-LOCK
           where buf_fin-schet.r-schet   = objBank-Accounts:r-schet
             and buf_fin-schet.cli-code  = v-obj-code
              and buf_fin-schet.cli-type = 'орг':U no-error .
      if available (buf_fin-schet) then do :
        v-status_ = 'удал':U .
        run ref/finscht2.p (
          input recid(buf_fin-schet)
         ,input yes
         ,input ''
         ,input-output v-status_
        ) no-error .
        if error-status:error then do :
          Msg = return-value .
          return false .
        end .
        else return true .
      end .
      else do :
        return true.
      end .
    end.
    objBank  = objBank-Accounts:bank .
    find first X_schet-clients no-lock where X_schet-clients.obj-code = v-obj-code and
      X_schet-clients.obj-type = 'орг':U no-error .
    if not available X_schet-clients then
    do:
      Msg = "Не найден держатель счета в справочнике клиентов с кодом:" + string(objBank-Accounts:cont-code) .
      return error.
    end.
    find first buf_fin-bank no-LOCK where buf_fin-bank.bik = objBank:bik
      and buf_fin-bank.host-code = v-host-code no-error .
    if not available buf_fin-bank then
    do:
      find last ub.fin-bank no-error.
      if AVAILABLE ub.fin-bank then v-code-bank = ub.fin-bank.code-bank + 1 .
      else v-code-bank = 1 .
      assign
        v-doc-rec   = ?
        v-mode-bank = 'ДОБАВЛЕНИЕ':U
        .
    end.
    else
    do:
      assign
        v-doc-rec   = recid (buf_fin-bank)
        v-mode-bank = 'ИЗМЕНЕНИЕ':U
        v-code-bank = buf_fin-bank.code-bank
        .
    end.
    run ref/finbank1.p (
      input-output v-doc-rec
      ,input v-mode-bank
      ,input yes
      ,input ""
      ,input "":U
      ,input v-host-code
      ,input v-code-bank
      ,input if AVAILABLE buf_fin-bank then buf_fin-bank.addres else ""
      ,input objBank:bank-city
      ,input if AVAILABLE buf_fin-bank then buf_fin-bank.addres1 else ""
      ,input objBank:bank-name
      ,input objBank:bik
      ,input objBank:cor-acc
      ,input objBank:qr-rule
      ,input objBank:bank-deposit-debit
      ,input objBank:bank-deposit-kredit
      ,input if AVAILABLE buf_fin-bank then buf_fin-bank.e-mail else ""
      ,input if AVAILABLE buf_fin-bank then buf_fin-bank.fax else ""
      ,input if AVAILABLE buf_fin-bank then buf_fin-bank.inn else ""
      ,input if AVAILABLE buf_fin-bank then buf_fin-bank.kpp else ""
      ,input if AVAILABLE buf_fin-bank then buf_fin-bank.licenz else ""
      ,input if AVAILABLE buf_fin-bank then buf_fin-bank.okato else ""
      ,input if AVAILABLE buf_fin-bank then buf_fin-bank.okonx else ""
      ,input if AVAILABLE buf_fin-bank then buf_fin-bank.okpo else ""
      ,input if AVAILABLE buf_fin-bank then buf_fin-bank.otdel else ""
      ,input if AVAILABLE buf_fin-bank then buf_fin-bank.phone else ""
      ,input if AVAILABLE buf_fin-bank then buf_fin-bank.PS else ""
      ,input if AVAILABLE buf_fin-bank then buf_fin-bank.rkc else ""
      ,input if AVAILABLE buf_fin-bank then buf_fin-bank.short-name else ""
      ,input if AVAILABLE buf_fin-bank then buf_fin-bank.cl-bank else ""
      )
      no-error.
    if error-status:error then
    do:
      Msg = return-value.
      return error.
    end.
    find first buf_fin-bank no-LOCK where RECID (buf_fin-bank) = v-doc-rec no-error.
    if AVAILABLE buf_fin-bank then
    do:
      v-code-bank-schet = buf_fin-bank.code-bank .
      find first ub.sysconf no-lock where ub.sysconf.host-code = buf_fin-bank.host-code no-error.
      if AVAILABLE ub.sysconf then
      do:
        v-curr-code = ub.sysconf.base-code .
      end.
      else
      do:
        Msg = "Не найдены системные настройки для фирмы с кодом:" + string(buf_fin-bank.host-code) .
        find first X_currency no-lock no-error.
        if AVAILABLE x_currency then
        do:
          v-curr-code = ub.currency.curr-code .
        end.
        else
        do:
          Msg = "Вы не выбрали валюту счета".
          return error .
        end.
      end.
      find first buf_fin-schet EXCLUSIVE-LOCK where buf_fin-schet.r-schet = objBank-Accounts:r-schet
        and buf_fin-schet.cli-code = X_schet-clients.obj-code
        and buf_fin-schet.cli-type = X_schet-clients.obj-type
        and buf_fin-schet.code-bank = v-code-bank-schet no-error .
      if AVAILABLE buf_fin-schet then
      do:
        v-mode = 'ИЗМЕНЕНИЕ':U .
        ri = recid(buf_fin-schet) .
        if (objBank-Accounts:del-l = 0) and (buf_fin-schet.status_ <> 'тек':U) then do :
          v-status_ = 'тек':U .
          run ref/finscht2.p (
          input ri
         ,input yes
         ,input ''
         ,input-output v-status_
          ) no-error .
          if error-status:error then do :
            Msg = return-value .
            return false .
          end .
        end .
      end.
      else
      do:
        v-mode = 'ДОБАВЛЕНИЕ':U .
        ri = ? .
      end.
      run ref/finscht1.p (
        input-output ri
        ,input v-mode
        ,input yes
        ,input ""
        ,input v-host-code
        ,input (if v-mode = 'ДОБАВЛЕНИЕ':U then 0 else buf_fin-schet.code-schet)
        ,input (if v-mode = 'ДОБАВЛЕНИЕ':U then '' else buf_fin-schet.c-schet)
        ,input X_schet-clients.obj-type
        ,input X_schet-clients.obj-code
        ,input v-code-bank-schet
        ,input v-curr-code
        ,INPUT (if v-mode = 'ДОБАВЛЕНИЕ':U then '' else buf_fin-schet.dop1)
        ,INPUT (if v-mode = 'ДОБАВЛЕНИЕ':U then '' else buf_fin-schet.dop2)
        ,input objBank-Accounts:r-schet
        ,input (if v-mode = 'ДОБАВЛЕНИЕ':U then '' else buf_fin-schet.ps)
        )
        no-error.
      if error-status:error then
      do:
        Msg = return-value.
        return false.
      end.
    end.
  end method.
end class.
