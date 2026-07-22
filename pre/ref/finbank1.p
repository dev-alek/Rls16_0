block-level on error undo, throw.
define input-output parameter p-doc-rec as recid no-undo.
define input parameter p-mode            as character no-undo .
define input parameter p-silent                       as logical no-undo .
define input parameter p-verify          as character no-undo .
define input parameter p-log-file                     as character no-undo .
define input parameter p-host-code       like ub.fin-bank.host-code no-undo .
define input parameter p-code-bank       like ub.fin-bank.code-bank no-undo .
define input parameter p-addres          like ub.fin-bank.addres    no-undo .
define input parameter p-bank-city       like ub.fin-bank.bank-city no-undo .
define input parameter p-addres1         like ub.fin-bank.addres1   no-undo .
define input parameter p-bank-name       like ub.fin-bank.bank-name no-undo .
define input parameter p-bik             like ub.fin-bank.bik       no-undo .
define input parameter p-cor-acc         like ub.fin-bank.cor-acc   no-undo .
define input parameter p-qr-rule         as integer                 no-undo .
define input parameter p-resive-debit    as character               no-undo .
define input parameter p-resive-kredit   as character               no-undo .
define input parameter p-e-mail          like ub.fin-bank.e-mail    no-undo .
define input parameter p-fax             like ub.fin-bank.fax       no-undo .
define input parameter p-inn             like ub.fin-bank.inn       no-undo .
define input parameter p-kpp             like ub.fin-bank.kpp       no-undo .
define input parameter p-licenz          like ub.fin-bank.licenz    no-undo .
define input parameter p-okato           like ub.fin-bank.okato     no-undo .
define input parameter p-okonx           like ub.fin-bank.okonx     no-undo .
define input parameter p-okpo            like ub.fin-bank.okpo      no-undo .
define input parameter p-otdel           like ub.fin-bank.otdel     no-undo .
define input parameter p-phone           like ub.fin-bank.phone     no-undo .
define input parameter p-PS              like ub.fin-bank.PS        no-undo .
define input parameter p-rkc             like ub.fin-bank.rkc       no-undo .
define input parameter p-short-name      like ub.fin-bank.short-name no-undo .
define input parameter p-cl-bank         like ub.fin-bank.cl-bank   no-undo .
define variable vss-revision    as character no-undo init "$Revision: b104425dd357, 2760, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Сб фев 20 15:59:21 2021 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: finbank1.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/finbank1.p $":U .
define variable vss-description as character no-undo init "Сохранение изменений в карточке банка".
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
define variable v-db-num like ub.db.db-num no-undo .
define variable v-correct-inn as logical no-undo .
define variable v-correct-acc as logical no-undo .
define variable v-correct-bik as logical no-undo .
define variable v-mess        as character no-undo .
define variable v-import as logical no-undo .
define buffer buf_sysconf  for ub.sysconf.
define buffer buf_fin-bank for ub.fin-bank.
define buffer buf_fin-schet for ub.fin-schet .
define variable v-value as character no-undo.
define variable v-ttype as character no-undo.
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
if p-mode = 'ДОБАВЛЕНИЕ-ИМПОРТ':U then do:
  v-import = yes.
  p-mode = 'ДОБАВЛЕНИЕ':U.
end.
run gbl/conf-rd.p ("is-erpRN", "", "", 0, "", "", "", no, output v-value, output v-ttype) no-error.
if v-value = "no"  then do:
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdbnum in g#library
  (output v-db-num
  )  .
find first buf_sysconf no-lock where
                buf_sysconf.host-code = p-host-code.
if not avail buf_sysconf then dO:
  v-mess = substitute("Не найдена фирма с кодом &1", p-host-code).
  run err-mess in this-procedure ( input-output v-mess).
  return error (if p-silent then v-mess else "host-code":U).
end.
if v-db-num <> buf_sysconf.firm-db-num
then do:
  v-mess =  substitute("Нельзя изменять запись БАНК в БД,&1отличной от главной БД фирмы: Номер текущей БД &2" +
                       "Номер главной БД фирмы &3"
                       , chr(10)
                       , v-db-num
                       , buf_sysconf.firm-db-num).
  run err-mess in this-procedure ( input-output v-mess ).
  undo, return error (if p-silent then v-mess else "host-code":U).
end.
end.
if
can-find(first buf_fin-bank no-lock where
                  buf_fin-bank.host-code = p-host-code
              AND buf_fin-bank.bik       = p-bik
              AND (p-mode = 'ДОБАВЛЕНИЕ':U OR p-doc-rec <> recid(buf_fin-bank))
              AND p-cor-acc = buf_fin-bank.cor-acc
              ) then do:
  v-mess = substitute("Уже есть банк с таким БИК и корсчетом для фирмы &1: БИК &2 коррсчет &3", p-host-code, p-bik, p-cor-acc) .
  run err-mess in this-procedure ( input-output v-mess).
  return error (if p-silent then v-mess else "bik":U).
end.
if p-bank-name = "":U then do:
  v-mess = "Имя банка не может быть пустым".
  run err-mess in this-procedure ( input-output v-mess).
  return error (if p-silent then v-mess else "bank-name":U).
end.
if p-bank-city = '':U then do:
  v-mess = "ГОРОД для банка не может быть пустым".
  run err-mess in this-procedure ( input-output v-mess).
  return error (if p-silent then v-mess else "bank-city":U).
end.
if p-inn <> "":U then do:
  run gbl/keyinn.p (p-inn, 'орг':U, 0, no , output v-correct-inn) no-error .
  if error-status:error or not v-correct-inn then do:
    v-mess = substitute("Неверный ИНН &1: &2", p-inn, return-value).
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent then v-mess else "inn":U).
  end.
end.
if lookup("bik" , p-verify) > 0 then do:
run check-bik in this-procedure (p-bik, output v-correct-bik) no-error.
if error-status:error
or not v-correct-bik then do:
  v-mess = substitute("Неверный БИК &1: &2", p-bik, return-value).
  run err-mess in this-procedure ( input-output v-mess).
  return error (if p-silent then v-mess else "bik":U).
end.
end.
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
run check-cor-acc in this-procedure ( input p-cor-acc
                                    , input p-bik
                                    , output v-correct-acc) no-error.
if error-status:error or not v-correct-acc then do:
  if v-nocoracc = "no" then do:
    v-mess = substitute("Неверный корсчет банка &1: &2", p-cor-acc, return-value).
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent then v-mess else "cor-acc":U).
  end.
end.
if p-cl-bank <> '':U then do:
  IF LOOKUP(P-CL-BANK, '1s':U) = 0 THEN DO:
    v-mess = substitute("Неверный тип системы КЛИЕНТ-БАНК: &1", p-cl-bank).
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent then v-mess else "cl-bank":U).
  END.
END.
_MAIN:
DO ON ERROR UNDO, RETURN ERROR
ON STOP UNDO, RETURN ERROR:
  if p-mode = 'ДОБАВЛЕНИЕ':U then do:
    create ub.fin-bank.
    assign
    ub.fin-bank.host-code = p-host-code
    ub.fin-bank.code-bank = (if v-import then p-code-bank else next-value(s-fin-bank, ub))
    p-doc-rec = recid(ub.fin-bank)
    .
  end.
  else do:
    FIND FIRST ub.fin-bank where
              recid(ub.fin-bank) = p-doc-rec No-ERROR.
    if not available ub.fin-bank then do:
      message
      vss-workfile vss-revision vss-description skip
      "Не найдена запись банк - p-doc-rec" p-doc-rec
      view-as alert-box error .
      undo, return error '':u.
    end.
    if ub.fin-bank.host-code <> p-host-code
    OR ub.fin-bank.code-bank <> p-code-bank then do:
      message
      vss-workfile vss-revision vss-description skip
      "Для уже имеющейся записи нельзя изменить"
      "код фирмы и код банка" skip
      view-as alert-box ERROR.
      undo, return error '':U.
    end.
    if ub.fin-bank.cor-acc <> p-cor-acc then do:
      for each buf_fin-schet no-lock where
                 buf_fin-schet.host-code = p-host-code
             AND buf_fin-schet.code-bank = p-code-bank:
        if buf_fin-schet.c-schet <> p-cor-acc
        and buf_fin-schet.status_ = 'тек':U then do:
          message
          vss-workfile vss-revision vss-description skip
          "Для уже имеющейся записи нельзя изменить"
          "коррсчет банка, если имеются записи банковских счетов для этогов банка в статусе" 'тек':U skip
          view-as alert-box ERROR.
          undo, return error '':U.
        end.
      end.
    end.
  end.
  assign
  ub.fin-bank.addres     = p-addres
  ub.fin-bank.addres1    = p-addres1
  ub.fin-bank.bik        = trim(p-bik)
  ub.fin-bank.bank-name  = p-bank-name
  ub.fin-bank.bank-city  = p-bank-city
  ub.fin-bank.cl-bank    = p-cl-bank
  ub.fin-bank.cor-acc    = trim(p-cor-acc)
  ub.fin-bank.e-mail     = p-e-mail
  ub.fin-bank.fax        = p-fax
  ub.fin-bank.inn        = p-inn
  ub.fin-bank.kpp        = p-kpp
  ub.fin-bank.licenz     = p-licenz
  ub.fin-bank.okato      = p-okato
  ub.fin-bank.okonx      = p-okonx
  ub.fin-bank.okpo       = p-okpo
  ub.fin-bank.otdel      = p-otdel
  ub.fin-bank.phone      = p-phone
  ub.fin-bank.PS         = p-PS
  ub.fin-bank.rkc        = p-rkc
  ub.fin-bank.short-name = p-short-name
  ub.fin-bank.status_    =  (if p-mode = 'ДОБАВЛЕНИЕ':U
                             then 'тек':U
                             else ub.fin-bank.status_)
  .
if p-qr-rule <> ? then do:
  find first ub.fin-bank-attr exclusive-lock where ub.fin-bank-attr.code-bank = ub.fin-bank.code-bank
    and ub.fin-bank-attr.host-code = p-host-code and ub.fin-bank-attr.attr-code = "collect-qrcode":U no-error .
  if not available (ub.fin-bank-attr) then
  do:
    create ub.fin-bank-attr .
    assign
      ub.fin-bank-attr.code-bank = ub.fin-bank.code-bank
      ub.fin-bank-attr.host-code = p-host-code
      ub.fin-bank-attr.attr-code = "collect-qrcode":U
      .
  end.
  ub.fin-bank-attr.attr-value = string (p-qr-rule) .
 end.
 if p-resive-debit <> ? then do:
  find first ub.fin-bank-attr exclusive-lock where ub.fin-bank-attr.code-bank = ub.fin-bank.code-bank
    and ub.fin-bank-attr.host-code = p-host-code and ub.fin-bank-attr.attr-code = "collect-debt":U no-error .
  if not available (ub.fin-bank-attr) then
  do:
    create ub.fin-bank-attr .
    assign
      ub.fin-bank-attr.code-bank = ub.fin-bank.code-bank
      ub.fin-bank-attr.host-code = p-host-code
      ub.fin-bank-attr.attr-code = "collect-debt":U
      .
  end.
  ub.fin-bank-attr.attr-value = string (p-resive-debit) .
end.
if p-resive-kredit <> ? then do:
  find first ub.fin-bank-attr exclusive-lock where ub.fin-bank-attr.code-bank = ub.fin-bank.code-bank
    and ub.fin-bank-attr.host-code = p-host-code and ub.fin-bank-attr.attr-code = "collect-credit":U no-error .
  if not available (ub.fin-bank-attr) then
  do:
    create ub.fin-bank-attr .
    assign
      ub.fin-bank-attr.code-bank = ub.fin-bank.code-bank
      ub.fin-bank-attr.host-code = p-host-code
      ub.fin-bank-attr.attr-code = "collect-credit":U
      .
  end.
  ub.fin-bank-attr.attr-value = string (p-resive-kredit) .
end.
  release ub.fin-bank no-error.
  if error-status:error then do:
     v-mess = substitute("Ошибка при сохранении записи БАНК: &1: &2"
                 , ERROR-STATUS:GET-message(1)
                 , return-value
                 ).
     run err-mess in this-procedure ( input-output v-mess).
    undo, return error (if p-silent then v-mess else "":U).
 end.
end.
procedure check-cor-acc :
define input parameter p-cor-acc like ub.fin-bank.cor-acc no-undo .
define input parameter p-bik like ub.fin-bank.bik no-undo .
define output parameter p-correct-acc as logical no-undo .
define variable ii as integer no-undo .
define variable v-dopi as integer no-undo .
  do
  on error undo, return error
  :
    if "руб" = "тг."
    or "руб" = "грн"
    or "руб" = "дрм"
    or "руб" = "lei"
    then do:
        p-correct-acc = true .
        return.
    end.
    assign
    p-cor-acc = trim(p-cor-acc).
    if substring(p-bik, 7, 3) = '000'
    or substring(p-bik, 7, 3) = '001'
    or substring(p-bik, 7, 3) = '002' then do:
      if p-cor-acc <> '':U then do:
         if substring(p-bik, 7, 3) = '000' then
         return error substitute("7-9 разряд БИК=000 -> банк является расчетно-кассовым центром&1"+
                                "или другим подразделением в составе&1" +
                                "территориального учреждения Банка России,&1" +
                                "наделенным функциями расчетно-кассового (кассового) центра&1" +
                                "для него № корр. счета НЕ УКАЗЫВАЕТСЯ"
                                , chr(10)
                                ).
         if substring(p-bik, 7, 3) = '001' then
         return error substitute("7-9 разряд БИК=001 -> банк является Головным расчетно-кассовым центром&1"+
                                 "или другим подразделением в составе&1" +
                                 "территориального учреждения Банка России,&1" +
                                "наделенным функциями расчетно-кассового (кассового) центра&1" +
                                "для него № корр. счета НЕ УКАЗЫВАЕТСЯ"
                                , chr(10)
                                ).
         if substring(p-bik, 7, 3) = '002' then
         return error substitute("7-9 разряд БИК=002 -> банк является подразделением расчетной сети БАНКА РОССИИ&1" +
                                 "или структурным подразделением банка России&1" +
                                "для него № корр. счета НЕ УКАЗЫВАЕТСЯ"
                                , chr(10)
                                ).
      End.
      p-correct-acc = yes.
      return.
    end.
    if p-cor-acc = "":U then do:
      return "Корсчет банка не может быть пустым".
    end.
    if length(p-cor-acc) <> 20 then do:
      return "Неверная длина корсчета банка - должно быть 20".
    end.
    do ii = 1 to 20:
      assign
      v-dopi = integer(substr(p-cor-acc, ii, 1))
      no-error .
      if error-status:error
      and not (ii = 6  and lookup(substr(p-cor-acc, ii, 1), "A,B,C,E,H,K,M,P,T,X":U) = 0)
      then do:
        return "Неверные символы в корсчете банка - должно быть цифры везде, кроме 6-го разряда".
      end.
    end.
    if substr(p-cor-acc, 18, 3) <> substr(p-bik, 7, 3) then do:
      return "Несоответствие номера корсчета и БИК - три последние цифры БИК и три  последние цифры корсчета должны совпадать".
    end.
    assign
    p-correct-acc = yes
    .
  end.
end procedure.
procedure check-bik :
define input parameter p-bik like ub.fin-bank.bik no-undo .
define output parameter p-correct-acc as logical no-undo .
define variable ii as integer no-undo .
define variable v-dopi as integer no-undo .
  do
  on error undo, return error
  :
    if  "руб" = "грн"
    then do:
        p-correct-acc = true .
        return.
    end.
    if "руб" = "тг."
    then do:
      if length(p-bik) <> 8 then do:
        return "BIC должен состоять из 8 символов".
      end.
      if substring(p-bik, 5, 2) <> "KZ" then do:
        return "5-6 символ BIC должен быть равен KZ".
      end.
        p-correct-acc = true .
        return.
    end.
    assign
    p-bik = trim(p-bik).
    if p-bik = "":U then do:
      return "БИК банка не может быть пустым".
    end.
    if length(p-bik) <> 9 then do:
      return "Неверная длина БИК - должно быть 9".
    end.
    do ii = 1 to 9:
      assign
      v-dopi = integer(substr(p-bik, ii, 1))
      no-error .
      if error-status:error
      then do:
        return "Неверные символы в корсчете банка - должно быть цифры".
      end.
    end.
    assign
    p-correct-acc = yes
    .
  end.
end procedure.
PROCEDURE err-mess:
  DEFINE INPUT-output  PARAMETER p-mess as character No-UNDO.
  CASE p-silent:
    when yes then do:
      p-mess = substitute("Банк &1: фирма: &2&3&4"
                          , p-code-bank
                          , p-host-code
                          ,chr(10)
                          ,p-mess
                          ).
    end.
    otherwise do:
      message
      p-mess
      view-as alert-box error .
    end.
  end.
END PROCEDURE.
