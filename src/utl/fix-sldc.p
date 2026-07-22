block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: fix-sldc.p $
$Archive: utl/fix-sldc.p $

Корректировка расхождения между полученными trn-doc/inkas и командой на расчет ДК по этим документам

Автор: Бахтадзе Наталья Викторовна
Дата создания: 06/01/09
Author: Bakhtadze Natalya
Creation date: 06/01/09

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-read-only as logical no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: fix-sldc.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/fix-sldc.p $":U .
define variable vss-description as character no-undo init "Корректировка расхождения между полученными trn-doc/inkas и командой на расчет ДК по этим документам".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ str/trdcalib.i }

define variable conf-par as character no-undo .
define variable par-type as character no-undo .
define variable cre-pay as integer no-undo .

define buffer buf_doc-attr for ub.doc-attr.
define buffer buf_trn-doc for ub.trn-doc.
define buffer buf_cash-pay for ub.cash-pay.
define buffer buf_sysconf for ub.sysconf.
define buffer locked_doc-attr for ub.doc-attr.

/*преамбула*/

/*
при закрытии в УБД продажи или накладной с ДК в шапке на факт
сначала в новости уходит закрытие, а потом уже кустовая команда обсчета ДК
если ГБД примут закрытие продажи или накладной, но не примут куст расчета ДК и начнут выгружать УБД
то возникнет расснихронизаци
для этого при получении такого документа или продажи закрытых на факт проставляем атрибут документа {&trdcattr-need-saledc}
при получении куста обсчету по ДК и удачном его приеме атрибут удаляем
если атрибут есть при выгрузке в УБД - значит куст принять не успели и он выгрузится в УБД и при первом входе в УБД будем произведена попытка
РАСЧЕТА по ДК на имеющийся закрытый на факт документ
после чего атрибут будет удален


при удалении в УБД продажи или накладной с ДК в шапке на факт
сначала в новости уходит кустовая команда обсчета ДК, а потом уже закрытие,
если ГБД примут куст расчета ДК , но не примут удаление продажи или накладной на факт, и начнут выгружать УБД
то возникнет расснихронизаци
для этого при получении при получении куста обсчету по ДК проставляем атрибут документа {&trdcattr-need-saledc}
при приеме удаления такого документа или продажи закрытых на факт - атрибут удаляем
если атрибут есть при выгрузке в УБД - значит удаление принять не успели и он выгрузится в УБД и при первом входе в УБД будем произведена попытка
РАСЧЕТА по ДК на имеющийся закрытый на факт документ СО ЗНАКОМ + (что компенсирует уже случившийся расчет по удалению)
после чего атрибут будет удален

*/

if not (g#db-num > 0
and not g#news) then do:
  return.
end.

/*таких атрибутиков вряд ли может быть больше одного*/
main-block:
for each buf_doc-attr no-lock where
        buf_doc-attr.attr-code = {&trdcattr-need-saledc}
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  find first locked_doc-attr exclusive-lock where
            recid(locked_doc-attr) = recid(buf_doc-attr).
  if p-read-only then do:
    return error substitute("&1 &2 &3&4До начала работы с данной БД (режим RO) необходимо произвести вход в ОСНОВНУЮ БД!!!"
                            ,vss-workfile
                            ,vss-revision
                            ,vss-description
                            ,{&new-line}).
  end.

  find first buf_trn-doc exclusive-lock where
            buf_trn-doc.doc-code = locked_doc-attr.doc-code no-error.
  if not available buf_trn-doc then do:
    /*ошибка!!!*/
    undo main-block, return error substitute("&1 &2&3Не найден документ &4 для атрибута <Требуется расчет данных по ДК>"
                                             , vss-workfile
                                             , vss-description
                                             , {&new-line}
                                             , buf_trn-doc.doc-code).
  end.
  if buf_trn-doc.status_ <> {&fact} then do:
    /*ошибка!!!*/
    undo main-block, return error substitute("&1 &2&3Документ &4 для атрибута <Требуется расчет данных по ДК> находится в статусе  &5"
                                          , vss-workfile
                                          , vss-description
                                          , {&new-line}
                                           , buf_trn-doc.doc-code
                                           , buf_trn-doc.status_
                                           ).

  end.
  case buf_trn-doc.ext-doc-type:
    when {&TDEDT_Ras_Vnesh_Kass} then do:
      find first buf_sysconf where
              buf_sysconf.host-code = buf_trn-doc.host-code no-lock.
      find first buf_Cash-pay no-lock where
                buf_cash-pay.cdpay-code = buf_sysconf.credit-pay no-error.
      { gbl/conf-rd.i
        "'iscredit'"
        0
        "''"
        0
        "''"
        "''"
        "''"
        no
        conf-par
        par-type
        no-error
      }
      if error-status:error
      or not available buf_cash-pay
      or buf_cash-pay.is-credit = no
      or conf-par <> "yes"
      then do:
          assign
          cre-pay = 0
          .
      end.
      else do:
        assign
        cre-pay = buf_sysconf.credit-pay
        .
      end.
      run str/diallog.w ( input parparentproc
                  , input this-procedure
                  , input ('fix-sldc_diallog':U + {&delim-par} +
                          "1" + {&delim-par} +
                          "0" + {&delim-par} +
                          "1" + {&delim-par} +
                          "1" + {&delim-par} +
                          "yes")
                  , input ''
                  , input yes /*p-auto-go*/
                  , input 'Прервать'
                  , input substitute('Досчет ДК по недовыгруженной продаже &1 ', buf_trn-doc.doc-code)) no-error .

    end.
    otherwise do:
      if  (buf_trn-doc.ext-doc-type = {&TDEDT_Vozvrat_Vnesh} OR
        buf_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh})
        and buf_trn-doc.d-card       <> ""
        and buf_trn-doc.d-card       <> ?
      then do:
        run str/saledc.p ( INPUT parparentproc
                    ,input ? /*this-procedure:handle*/
                    ,input ? /*p-log-handle*/
                    ,input {&dct-proc_trn-doc-close} /*p-doc-type*/
                    ,input ? /*p-emitent-host-code*/
                    ,input "" /*p-type*/
                    ,input 0 /*p-profile-id*/
                    ,input 0 /*p-codex-id*/
                    ,input 0 /*p-ruleset-id*/
                    ,INPUT g#db-num
                    ,INPUT buf_trn-doc.doc-code
                    ,input buf_trn-doc.doc-date
                    ,input buf_trn-doc.fact-date
                    ,input ? /*cre-pay*/
                    ,input (if locked_doc-attr.attr-value = string(1)
                           then 1
                           else -1) /*p-sign*/
                    ,input (if buf_trn-doc.ext-doc-type = {&TDEDT_Vozvrat_Vnesh}
                            then -1
                            else 1) /*p-direction*/
                    ,input yes  /*p-save*/
                    ) no-error .
      end.
    end.
  end case.
  if error-status :error
  then do:
    undo main-block, return error substitute("&1 &2&3Ошибка при проведении досчета ДК по недовыгруженной продаже/накладной &4.&3&5&3&6"
                                  , vss-workfile
                                  , vss-description
                                  , {&new-line}
                                  , buf_trn-doc.doc-code
                                  , error-status:get-message(1)
                                  , return-value
                                  ).
  end.
  define variable v-deleted as logical no-undo .
  { str/tdat-del.i
      buf_trn-doc.doc-code
      ~{&trdcattr-need-saledc~}
      v-deleted
      no-error
    }
  if error-status:error then do:
    undo main-block, return error substitute("&1 &2&3Ошибка при удалении атрибута <Требуется расчет данных по ДК> после проведения досчета ДК по недовыгруженной продаже/накладной &4.&3&5&3&6"
                                  , vss-workfile
                                  , vss-description
                                  , {&new-line}
                                  , buf_trn-doc.doc-code
                                  , error-status:get-message(1)
                                  , return-value
                                  ).

  end.
end.

procedure fix-sldc_diallog :
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-parameter   as character no-undo .
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
    run str/saledc.p
      (
      input parparentproc
      ,input p-parent-handle
      ,input p-log-handle
      ,input {&dct-proc_sale-close}
      ,input ? /*p-emitent-host-code*/
      ,input "" /*p-type*/
      ,input 0 /*p-profile-id*/
      ,input 0 /*p-codex-id*/
      ,input 0 /*p-ruleset-id*/
      ,input g#db-num
      ,input buf_trn-doc.doc-code
      ,input buf_trn-doc.doc-date
      ,input buf_trn-doc.fact-date
      ,input cre-pay
      ,input (if locked_doc-attr.attr-value = string(1)
              then 1
              else -1 )
              /*par-sign*/
      ,input ? /*par-direction*/
      ,input yes /*p-save*/
      ) no-error .
    if error-status:error then do:
      undo main-block, return error return-value .
    end.
end.

end procedure. /* fix-sldc_diallog */