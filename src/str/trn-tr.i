/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Общие триггеры РН и ПН : выход, клиент, исполнители, оплата, список...

Автор: Чернова Светлана Александровна
Дата создания: 10/10/06
Author: Svetlana Chernova
Creation date: 10/10/06

create: Alexey Suslov

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

{ rep/gn-extp.i }
&if "{1}" <> "pr" &then
  { gbl/hot-key.i b-lkp }
  { gbl/hot-key.i b-add }
  { gbl/hot-key.i b-chg }
  { gbl/hot-key.i b-del }
&endif

{ str/n-p-l.i
  &doc-rec = "pardoc-rec"
}  /* next, prev, last */

{ str/vrclvmd.i  }

on end-error, stop of frame {&frame-name} do:
  apply "choose" to b-exit in frame {&frame-name}.
  return no-apply.
end.

on choose of b-notes in frame {&frame-name} run notes-tr.

on choose of b-history   in frame {&frame-name} do:
  run proc-history in this-procedure no-error.
  if error-status :error then do: return no-apply. end.
end.

on choose of b-exit  in frame {&frame-name} /* Вых */
do:
  run proc-exit no-error.
  if error-status :error then do: return no-apply. end.
end.

&if "{1}" <> "pr" &then
{ str/st-perc.i }

&if "{1}" <> "inv" &then

on entry of t-doc.cli-code, r-clients in frame {&frame-name}
DO:
if t-doc.ret-supp = yes and
  can-find (first ub.doc-line where ub.doc-line.doc-code = t-doc.doc-code no-lock) then do:
    message "Уже есть строки возврата. Изменение контрагента невозможно."
    view-as alert-box error buttons ok.
    apply "entry" to browse br-dtl.
    return no-apply.
end.

if t-doc.cli-code <> ? then do:
  pardoc-mode = {&add-def}.
  run UI-on ("enable").
end.
end.

&if "{1}" <> "in" &then
on leave of t-doc.print-rubl in frame {&frame-name} do:
  if input frame {&frame-name} t-doc.print-rubl <> t-doc.print-rubl then do:
   run print-rubl.
  end.
END.

procedure print-rubl:

assign frame {&frame-name} t-doc.print-rubl.
define variable varbase-code as integer no-undo.
{ gbl/basecode.i v-cntxt-host-code-obj varbase-code }
if t-doc.print-rubl then
  assign
    t-doc.exch-code  = 0
    t-doc.exch-rate  = 1
    t-doc.exch-scale = 1.
  else
  assign
    t-doc.exch-code  = varbase-code
    t-doc.exch-rate  = t-doc.base-rate
    t-doc.exch-scale = t-doc.base-scale.
end procedure.

on leave of t-doc.base-rate  in frame {&frame-name} or
   leave of t-doc.base-scale in frame {&frame-name} do:
  if input frame {&frame-name} t-doc.base-rate  <> t-doc.base-rate  or
     input frame {&frame-name} t-doc.base-scale <> t-doc.base-scale then do:
    run check-rate no-error.
    if error-status :error then do:
       message "Ошибка при проверке курса" skip
               return-value
       view-as alert-box error.
       return no-apply.
    end.
    run gbl/calc-trn.p (input parparentproc, input recid(t-doc)) no-error.
    if error-status :error then undo, return no-apply.
    run ui-on ("line").
  end.
end.
&endif

on leave of t-doc.pay-code in frame {&frame-name}
do:
if input frame {&frame-name} t-doc.pay-code <> t-doc.pay-code then do:
  run leave-pay-code no-error.
  if error-status :error then return no-apply.
end.
end.

on leave of t-doc.doc-date in frame {&frame-name} do:
if input frame {&frame-name} t-doc.doc-date <> t-doc.doc-date then do:
  assign
    t-doc.doc-date = input frame {&frame-name} t-doc.doc-date.
end.
end.

on mouse-select-dblclick, return of t-doc.pay-code in frame {&frame-name} /* Оплта */
do:
if input frame {&frame-name} t-doc.pay-code <> t-doc.pay-code then do:
  run return-pay-code no-error.
  if error-status :error then return no-apply.
end.
apply "entry" to t-doc.wrkr in frame {&frame-name}.
return no-apply.

end.

on choose of r-pay in frame {&frame-name}
do:
  run choose-r-pay no-error.
  if error-status :error then return no-apply.
end.

on return, mouse-select-dblclick of br-dtl in frame {&frame-name}
do:
  if b-chg:sensitive then do:
    apply "choose" to b-chg in frame {&frame-name}.
  end.
  else do:
    apply "choose" to b-lkp in frame {&frame-name}.
  end.
end.

on choose of r-acc in frame {&frame-name}
do:
  run choose-r-acc no-error.
  if error-status :error then return no-apply.
end.

procedure choose-r-acc:
define variable v-today      as date    no-undo.
define variable varbase-code as integer no-undo.
&if "{1}" = "in" &then
run check-update no-error.
if error-status :error then return error.
run check-exch no-error.
if error-status :error then return error.
varlog = yes.
message "Подставить БИРЖЕВЫЕ курсы базовой валюты :" base-abbr "и валюты поставщика :"
        ub.currency.curr-abbr "на дату растаможивания ?"
view-as alert-box question buttons OK-Cancel update varlog.
if varlog <> true then do:
  return error.
end.
{ gbl/basecode.i v-cntxt-host-code-obj varbase-code }
find last ub.curr-accnt where ub.curr-accnt.curr-code = varbase-code and
                         ub.curr-accnt.exch-date <= input frame {&frame-name} t-doc.exch-date use-index pi no-lock no-error.
&else
varlog = yes.
message "Подставить курс базовой валюты : из справочника на текущую дату ?"
view-as alert-box question buttons OK-Cancel update varlog.
if varlog <> true then do:
  run UI-on ("line").
  return error.
end.
{ gbl/curobjdt.i t-doc.obj-type t-doc.obj-code v-today }
if v-today <> ? then do:
  find last ub.curr-accnt where ub.curr-accnt.curr-code  = varbase-code and
                             ub.curr-accnt.exch-date <= v-today      use-index pi no-lock no-error.
end.
else do:
  find last ub.curr-accnt where ub.curr-accnt.curr-code  = varbase-code   and
                             ub.curr-accnt.exch-date <= t-doc.doc-date use-index pi no-lock no-error.
end.

&endif
if not available ub.curr-accnt then do:
  message "На эту дату неизвестен курс базовой валюты.".
  apply "entry" to t-doc.base-rate in frame {&frame-name}.
  return error.
end.
disp ub.curr-accnt.exch-rate  @ t-doc.base-rate
     ub.curr-accnt.exch-scale @ t-doc.base-scale with frame {&frame-name}.
run check-rate.
&if "{1}" = "in" &then
find last ub.curr-accnt where ub.curr-accnt.curr-code = input t-doc.exch-code
          and ub.curr-accnt.exch-date <= input t-doc.exch-date use-index pi no-lock no-error.
if not available ub.curr-accnt then do:
  message "На дату " + input t-doc.exch-date + " неизвестен курс валюты поставщика.".
  apply "entry" to t-doc.exch-rate.
  return error.
end.
display ub.curr-accnt.exch-rate  @ t-doc.exch-rate
        ub.curr-accnt.exch-scale @ t-doc.exch-scale with frame {&frame-name}.
run check-rate.
run UI-on ("line").
&else
  apply "entry" to b-add in frame {&frame-name}.
  return error.
&endif
end procedure.

on mouse-select-dblclick, return of t-doc.cli-code, t-doc.cli-type
  in frame {&frame-name} /* Контрагент */
do:
  run choose-cli in this-procedure no-error.
  if error-status :error then do:
    display ? @ t-doc.cli-type ? @ t-doc.cli-code with frame {&frame-name}.
  end.
  return no-apply.
end.

on choose of r-clients in frame {&frame-name}
do:
define variable varfirm-code like ub.firm.firm-code no-undo.
define variable v-rid-list as character no-undo .
define variable v-types as character no-undo .
define buffer bf_clients for ub.clients.
if t-doc.internal then v-types = {&shop}.
                  else v-types = {&all}.  /* режим справочника */
if (t-doc.ext-doc-type = {&TDEDT_Ras_Vnesh} or t-doc.ext-doc-type = {&TDEDT_Ras_Vnesh_VP}) and
   varhold            = "yes"              and
   paris-hold         = yes                then do:
  assign
    varfirm-code = ?.
  run adm/sconfs.w ( input parparentproc
                   , input "b-sel":U
                   , input no
                   , input ?
                   , output varfirm-code
                   , input-output v-rid-list) no-error.
  if error-status :error or
     varfirm-code = ?   then do:
    return no-apply.
  end.
  find first bf_clients where bf_clients.obj-type = {&cmp}       and
                              bf_clients.obj-code = varfirm-code no-lock.
  assign ref-list = string(recid (bf_clients)).
  run check-base-code in this-procedure (recid(bf_clients)).
end.
else do:
  if transaction = yes then do:
    message "Критическая ошибка." skip
            "Вы находитесь в транзакции." skip
            "Работа со справочником клиентов невозможна."
    view-as alert-box error.
    return no-apply.
  end.
  def var supp-type as character no-undo.
  &if "{2}" <> "" &then
  case {2}:
    when {&is-fuel} then supp-type = "supp-np".
    when {&is-lgas} then supp-type = "supp-lgas".
    when {&is-lgas-corr} then supp-type = "supp-lgas".
  end case.
  &endif
  
  run ref/cli-all.w (parparentproc
                , "b-sel,b-add"
                , v-types
                , ?
                , ?
                , ?
                , ?
                , supp-type
                , output ref-list) .
end.
if ref-list <> "" then do:
  ref-rec = integer (ref-list).
  find ub.clients where recid ( ub.clients ) = ref-rec no-lock.
  disp ub.clients.obj-code @ t-doc.cli-code
          ub.clients.obj-name with frame {&frame-name}.
&if "{1}" <> "in" &then if pardoc-mode = {&add-def} then &endif
  disp ub.clients.obj-type @ t-doc.cli-type with frame {&frame-name}.
end.
if trn-type = {&is-fuel}
then do :
  define variable v-tmp-char like ub.thbj-attr.property-value-character no-undo .
  define variable v-tmp-date      like ub.thbj-attr.property-value-date    no-undo .
  define variable v-tmp-decimal   like ub.thbj-attr.property-value-decimal no-undo .
  define variable v-tmp-integer   like ub.thbj-attr.property-value-integer no-undo .
  define variable v-rvd-own-nb as logical no-undo .
  define variable v-rvd-own-nb-type as   character no-undo .
  
  find ub.clients where ub.clients.obj-code = input frame {&frame-name} t-doc.cli-code
               and ub.clients.obj-type = input frame {&frame-name} t-doc.cli-type no-error.
  if not available ub.clients then do:
    if input frame {&frame-name} t-doc.cli-code <> ? and input t-doc.cli-type <> ? then
      message "Неправильный код или тип контрагента.".
    apply "entry" to t-doc.cli-code in frame {&frame-name}.
    return no-apply .
  end.
  
  run adm/shattri.p (
      input "get":U
      ,input t-doc.obj-type
      ,input t-doc.obj-code
      ,input {&attr-petrol}
      ,input  "rvd-own-nb"
      ,output v-tmp-char
      ,output v-tmp-date
      ,output v-tmp-decimal
      ,output v-tmp-integer
      ,output v-rvd-own-nb
      ,output v-rvd-own-nb-type
      ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
      ) no-error .
  if error-status :error then v-rvd-own-nb = false .
  if v-rvd-own-nb = false
  then do :
    find first ub.clients-attr no-lock where ub.clients-attr.obj-type = ub.clients.obj-type
                                         and ub.clients-attr.obj-code = ub.clients.obj-code
                                         and ub.clients-attr.attr-code = {&attr-owner-code}
                                         no-error .
    if available ub.clients-attr
    and ub.clients-attr.attr-value > ""
    then do :
      if ub.clients-attr.attr-value = "орг" + string(t-doc.host-code)
      then do :                            
        message "Для данного поставщика документ может быть заполнен только в автоматическом режиме путем сканирования 2D кода. Просканируйте код с ТТН, при возникновении проблемы обратитесь в тех. поддержку".
        run str/trnscanqr.w (parparentproc, t-doc.doc-code, "", this-procedure).
        return no-apply .
      end .
    end .
  end .                                     
end .
run check-cli no-error.
if error-status :error then return no-apply.
&if "{1}" = "in" or "{1}" = "inv" or "{1}" = "out" &then run fill-mol in this-procedure. &endif
if error-status :error then return no-apply.
end.

procedure check-cli :
define variable v-today as date      no-undo.
define variable v-time  as integer   no-undo.
define buffer buf_sysconf      for ub.sysconf.
define buffer buf_firm         for ub.firm.
define buffer in-cli           for ub.trn-doc.
define buffer buf-hold_clients for ub.clients.
define buffer buf-hold_shop    for ub.shop.
define buffer buf-hold_store   for ub.store.
define buffer bf_clients       for ub.clients.
define buffer bf_contract      for ub.contract.
define buffer buf_contract-attr for ub.contract-attr.
define buffer bf_currency      for ub.currency.
define buffer buf_trn-reason   for ub.trn-reason.
define variable varexch-rate     like ub.trn-doc.exch-rate            no-undo.
define variable varexch-scale    like ub.trn-doc.exch-scale           no-undo.
define variable varcurr-abbr     as   character                       no-undo.
define variable parhold-obj-type like ub.firm.main-obj-type           no-undo.
define variable parhold-obj-code like ub.firm.main-obj-code initial ? no-undo.
define variable varcontract-code like ub.contract.contract-code       no-undo.
define variable varr-b           as   character                       no-undo.
define variable varis-fin        as   character                       no-undo.
define variable varis-finby      as   character                       no-undo.
define variable vartype          as   character                       no-undo.
define variable varcontract      as   character                       no-undo.
define variable varcontract-cli  as   character                       no-undo.
define variable varcontract-type  as character no-undo .
define variable v-value-character like ub.thbj-attr.property-value-character no-undo .
define variable v-value-date      like ub.thbj-attr.property-value-date    no-undo .
define variable v-value-decimal   like ub.thbj-attr.property-value-decimal no-undo .
define variable v-value-logical   like ub.thbj-attr.property-value-logical no-undo .
define variable v-value-integer   like ub.thbj-attr.property-value-integer no-undo .
define variable v-tth as handle no-undo .
define variable v-tth1 as handle no-undo .
define variable varintprmvq      as logical   no-undo .
define variable varintprmvq-type as   character                       no-undo.
define variable v-num            as   integer       initial 1         no-undo.
define variable varis-perm       as   logical       initial no        no-undo.
define buffer bf-f_contract-specif    for ub.contract-specif.
define variable v-master as character no-undo.
define variable trn-is-return          as logical   no-undo init no .


{ gbl/objsrv.i }
define variable EDOParSec as class ibs.th.gbl.env.prmtrs.edo .

define buffer bf_shop for ub.shop.
do on error undo, return error return-value :
{ gbl/curr-r-b.i varr-b }
{ gbl/conf-rd.i  "'is-fin'"   0               "''"           0              "''" "''" "''" no varis-fin       vartype          no-error }
{ gbl/conf-rd.i  "'is-finby'" 0               "''"           0              "''" "''" "''" no varis-finby     vartype          no-error }
  run adm/shattri.p (
      input "get":U
      ,input t-doc.obj-type
      ,input t-doc.obj-code
      ,input {&attr-nakl_par}
      ,input  "intprmvq"
      ,output v-value-character
      ,output v-value-date
      ,output v-value-decimal
      ,output v-value-integer
      ,output varintprmvq
      ,output varintprmvq-type
      ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
      ) no-error .
      if error-status :error then varintprmvq = false .


&if "{1}" = "out"
&then
&else
{ gbl/curobjdt.i t-doc.obj-type t-doc.obj-code v-today }
assign
  t-doc.exch-date     = v-today
  t-doc.exch-code     = 0
  t-doc.exch-rate     = 1
  t-doc.exch-scale    = 1
  t-doc.print-rubl    = yes.
&endif
if input frame {&frame-name} t-doc.cli-type = ? or input frame {&frame-name} t-doc.cli-type = "" then do:
  if t-doc.internal then do:
    if can-find (ub.clients where ub.clients.obj-code = input frame {&frame-name} t-doc.cli-code
                                     and ub.clients.obj-type = {&stock} no-lock) then do:
      disp {&stock} @ t-doc.cli-type with frame {&frame-name}.
    end.
    else do:
      disp {&shop} @ t-doc.cli-type with frame {&frame-name}.
    end.
  end.
  else do:
    if can-find (ub.clients where ub.clients.obj-code = input frame {&frame-name} t-doc.cli-code
                                     and ub.clients.obj-type = {&cmp} no-lock) then do:
      disp {&cmp} @ t-doc.cli-type with frame {&frame-name}.
    end.
    else do:
      disp {&prs} @ t-doc.cli-type with frame {&frame-name}.
    end.
  end.
end.

define variable conf-par as character no-undo.
define variable mode-erprn as logical no-undo.
define variable par-type as character no-undo.
  { gbl/conf-rd.i
  "'is-erpRN'"
  0
  "''"
  0
  "''"
  "''"
  "''"
  NO
  conf-par
  par-type
  no-error
  }
if not error-status:error and conf-par = "yes":U then mode-erprn = yes.
  else mode-erprn = no.

find ub.clients where ub.clients.obj-code = input frame {&frame-name} t-doc.cli-code
               and ub.clients.obj-type = input frame {&frame-name} t-doc.cli-type no-error.
if not available ub.clients then do:
  if input frame {&frame-name} t-doc.cli-code <> ? and input t-doc.cli-type <> ? then
    message "Неправильный код или тип контрагента.".
  apply "entry" to t-doc.cli-code in frame {&frame-name}.
  return error.
end.
disp ub.clients.obj-type @ t-doc.cli-type with frame {&frame-name}.
if (ub.clients.obj-type = v-cntxt-obj-type and ub.clients.obj-code = v-cntxt-obj-code) or
   (ub.clients.obj-type = {&cmp} and ub.clients.obj-code = v-cntxt-host-code-obj) then do:
  release ub.clients no-error.
  message "Запрещенный код и тип контрагента.".
  apply "entry" to t-doc.cli-code in frame {&frame-name}.
  return error.
end.
if ub.clients.stts <> 0 then do:
 message "Данный клиент имеет статус 'неактивный'.".
 apply "entry" to t-doc.cli-code in frame {&frame-name}.
 return error.
end.

define variable v-err as logical   no-undo .
  run ver-clients  ( ub.clients.obj-type , ub.clients.obj-code , output v-err ) .
  if  v-err then do:
  apply "entry" to t-doc.cli-code in frame {&frame-name}.
  return error.
  end.

if lookup(ub.clients.obj-type, {&stock} + ',' + {&shop}) > 0
then do:
  if t-doc.internal then do:
    if ub.clients.obj-type = {&stock} then do:
      find ub.store where ub.store.obj-code = ub.clients.obj-code no-lock.
      if ub.store.host-code <> v-cntxt-host-code-obj then do:
        release ub.clients no-error.
        message "Выбран склад другой фирмы. Используйте внешний документ.".
        apply "entry" to t-doc.cli-code in frame {&frame-name}.
        return error.
      end.
    end.
    else do:
      find ub.shop where ub.shop.obj-code = ub.clients.obj-code no-lock.
      if ub.shop.host-code <> v-cntxt-host-code-obj then do:
        release ub.clients no-error.
        message "Выбран магазин другой фирмы. Используйте внешний документ.".
        apply "entry" to t-doc.cli-code in frame {&frame-name}.
        return error.
      end.
    end.
  end.
  else do:
    release ub.clients no-error.
    message "Это не внутреннее перемещение. Выберите организацию или человека.".
    apply "entry" to t-doc.cli-code in frame {&frame-name}.
    return error.
  end.
end.
else do:
  if t-doc.internal then do:
    release ub.clients no-error.
    message "Вы заполняете внутреннее перемещение. Выберите склад или магазин.".
    apply "entry" to t-doc.cli-code in frame {&frame-name}.
    return error.
  end.
end.
&if "{2}" = "trn-type" &then
   if {2} = {&is-gds} then varvalue = "yes" .
   else do:
   { str/tdat-val.i
     t-doc.doc-code
     {&trdcattr-trn-is-gds}
     varvalue
     vartype
     no-error
   }
      if varvalue = "no" then do:
      if can-find (FIRST ub.clients-attr no-lock where (ub.clients-attr.attr-code = {&attr-supp-np} or ub.clients-attr.attr-code = {&attr-supp-lgas})
                                                and ub.clients-attr.attr-value = "yes") then varvalue = "no" . else varvalue = "yes" . 
      end.
      end.
&else
   { str/tdat-val.i
     t-doc.doc-code
     {&trdcattr-trn-is-gds}
     varvalue
     vartype
     no-error
   }
&endif   
   if varvalue = "yes" or varvalue = "" then 
   do:
      run adm/shattri.p (
         input "get":U
         ,input t-doc.obj-type
         ,input t-doc.obj-code
         ,input {&attr-contr-in}
         ,input ( if t-doc.ext-doc-type = {&TDEDT_Ras_Vnesh}  then  "contr-in-expense" else "contr-in-income" )
         ,output v-value-character
         ,output v-value-date
         ,output v-value-decimal
         ,output v-value-integer
         ,output v-value-logical
         ,output varcontract-type
         ,INPUT-OUTPUT TABLE-handle v-tth1
         ) no-error .
      if error-status :error then
         message
            vss-workfile vss-revision vss-description skip
            error-status :get-message(1) skip
            return-value skip
            "adm/shattri.p"
            view-as alert-box error
            .
   end.
   else 
   do:
      run adm/shattri.p (
         input "get":U
         ,input t-doc.obj-type
         ,input t-doc.obj-code
         ,input {&attr-contr-in}
         ,input ( if t-doc.ext-doc-type = {&TDEDT_Ras_Vnesh}  then  "contr-in-expense-NP" else "contr-in-income-NP" )
         ,output v-value-character
         ,output v-value-date
         ,output v-value-decimal
         ,output v-value-integer
         ,output v-value-logical
         ,output varcontract-type
         ,INPUT-OUTPUT TABLE-handle v-tth1
         ) no-error .
      if error-status :error then
         message
            vss-workfile vss-revision vss-description skip
            error-status :get-message(1) skip
            return-value skip
            "adm/shattri.p"
            view-as alert-box error
            .         
   end.   
      delete object v-tth1.
      if v-value-logical = true then varcontract = "yes" .
                                else varcontract = "no" .

{ str/tdat-val.i
   t-doc.doc-code
   {&trdcattr-is-return}
   varvalue
   vartype
   no-error
}
if varvalue = "yes"
then do :
  trn-is-return = yes .
end .
if ( varis-fin = "yes":u
 and ( t-doc.ext-doc-type = {&TDEDT_Pri_Vnesh} or
       t-doc.ext-doc-type = {&TDEDT_Ras_Vnesh_VP} or
   ( t-doc.ext-doc-type = {&TDEDT_Ras_Vnesh} and (paris-hold = true or mode-erprn = true or trn-is-return = true) ) or
     ( t-doc.ext-doc-type = {&TDEDT_Vozvrat_Vnesh} and (paris-hold = true or mode-erprn = true)   )))
  or ( varis-finby = "yes":u
  and ( t-doc.ext-doc-type = {&TDEDT_Ras_Vnesh}      or
        t-doc.ext-doc-type = {&TDEDT_Ras_Vnesh_VP} or
        t-doc.ext-doc-type = {&TDEDT_Vozvrat_Vnesh}  or
      ( t-doc.ext-doc-type = {&TDEDT_Ras_Vnesh}  and paris-hold = true )))
  then do:
    find first bf_contract where bf_contract.host-code = t-doc.host-code                          and
                                 bf_contract.cli-type  = input frame {&frame-name} t-doc.cli-type and
                                 bf_contract.cli-code  = input frame {&frame-name} t-doc.cli-code no-lock no-error.
    if not available bf_contract then do:
      if (varcontract <> "yes":u or trn-type = {&is-fuel}) and
         not (t-doc.ext-doc-type = {&TDEDT_Ras_Vnesh} and trn-is-return) /* если внешний расход-возврат, то на контрагенте должен быть договор  */ 
      then do:
        assign
          t-doc.contract-code  = 0.
      end.
      else do:
        message "По клиенту " input frame {&frame-name} t-doc.cli-code " " input frame {&frame-name} t-doc.cli-type
                " на фирме " t-doc.host-code " нет ни одного договора. "
                func-get-name-from-ext-type ( t-doc.ext-doc-type , true ) " не может быть оформлен."
        view-as alert-box error.
        apply "entry" to t-doc.cli-code in frame {&frame-name}.
        return error.
      end.
    end.
    else do:
        run check-contract-code in this-procedure (input  substitute("&1,&2=&3", "choose":u, "doc-type", t-doc.ext-doc-type),
                                                  input  t-doc.host-code,
                                                  input  input frame {&frame-name} t-doc.cli-type,
                                                  input  input frame {&frame-name} t-doc.cli-code,
                                                  input  ?,
                                                  input  parparentproc,
                                                  input  t-doc.doc-date,
                                                  input if paris-hold = yes then "all" else (if ( t-doc.ext-doc-type = {&TDEDT_Pri_Vnesh} or t-doc.ext-doc-type = {&TDEDT_Ras_Vnesh_VP} or mode-erprn or (t-doc.ext-doc-type = {&TDEDT_Ras_Vnesh} and (logical(varcontract) or trn-is-return))) then {&income} else {&expense}) ,
                                                  output varcontract-code) no-error.
      if error-status :error    or
         varcontract-code = ?  or
         varcontract-code = 0  then do:
        if trn-is-return
        then do :
          apply "entry" to t-doc.cli-code in frame {&frame-name}.
          return error.
        end .
        if varcontract <> "yes":u or trn-type = {&is-fuel} then do:
          message "Вы не выбрали договор. Вы хотите оформить "
            func-get-name-from-ext-type ( t-doc.ext-doc-type , false ) " без договора?"
          view-as alert-box question buttons yes-no update varlog.
          if varlog = no then do:
            apply "entry" to t-doc.cli-code in frame {&frame-name}.
            return error.
          end.
          else do:
            assign
              t-doc.contract-code = 0.
          end.
        end.
        else do:
          message "Вы не выбрали договор. "
          func-get-name-from-ext-type (t-doc.ext-doc-type, true ) " не может быть оформлен."
          view-as alert-box error.
          apply "entry" to t-doc.cli-code in frame {&frame-name}.
          return error.
        end.
      end.
      else do:
        find first bf_contract where bf_contract.host-code     = t-doc.host-code  and
                                     bf_contract.contract-code = varcontract-code no-lock.
        find first bf_currency where bf_currency.curr-code = bf_contract.curr-code no-lock no-error.
        if not available bf_currency then do:
          message "В договоре указана валюта " bf_contract.curr-code "." skip
                  "Но этой валюты нет в справочнике валют."
          view-as alert-box error.
          apply "entry" to t-doc.cli-code in frame {&frame-name}.
          return error.
        end.
        { gbl/exchrate.i
          bf_currency.curr-code
          t-doc.exch-date
          varexch-rate
          varexch-scale
          varcurr-abbr
          no-error
        }
        if error-status :error then do:
          message "Ошибка при поиске курса валюты поставки по договору." skip
                  return-value skip
                  error-status :get-message( 1 ) skip
                  error-status :get-message( 2 )
          view-as alert-box error.
          return error.
        end.
        
        if t-doc.ext-doc-type = {&TDEDT_Pri_Vnesh}
        then do :
          EDOParSec = ObjSrv:Env:ParametrsOfSection:GetSectionEDO(t-doc.obj-type, t-doc.obj-code).
          find first buf_contract-attr no-lock where buf_contract-attr.host-code = bf_contract.host-code
                                                 and buf_contract-attr.contract-code = bf_contract.contract-code
                                                 and buf_contract-attr.attr-code = "contract-edi"
                                                 no-error .
          if EDOParSec:IsEdo
          and available buf_contract-attr
          and logical(buf_contract-attr.attr-value) = true 
          then do :
            message "Договор рассчитан на поставки через ЭДО. Ручной приход по нему невозможен!" view-as alert-box error.
            apply "entry" to t-doc.cli-code in frame {&frame-name}.
            return error.
          end .
        end .
        
        if t-doc.ext-doc-type = {&TDEDT_Ras_Vnesh_VP}
        then do :
          EDOParSec = ObjSrv:Env:ParametrsOfSection:GetSectionEDO(t-doc.obj-type, t-doc.obj-code).
          find first buf_contract-attr no-lock where buf_contract-attr.host-code = bf_contract.host-code
                                                 and buf_contract-attr.contract-code = bf_contract.contract-code
                                                 and buf_contract-attr.attr-code = "contract-edi"
                                                 no-error .
          if EDOParSec:IsEdo
          and available buf_contract-attr
          and logical(buf_contract-attr.attr-value) = true 
          then do :
            message "По договору осуществляется ЭДО. Для возврата используйте документ Расход внешний." view-as alert-box .
            return error.
          end .
          else do :
            find first buf_contract-attr no-lock where buf_contract-attr.host-code = bf_contract.host-code
                                                   and buf_contract-attr.contract-code = bf_contract.contract-code
                                                   and buf_contract-attr.attr-code = "contract-diadoc"
                                                   no-error .
            if EDOParSec:IsEdo
            and available buf_contract-attr
            and logical(buf_contract-attr.attr-value) = true 
            then do :
              message "По договору осуществляется ЭДО. Для возврата используйте документ Расход внешний." view-as alert-box .
              return error.
            end .
          end .
        end .
        
        if t-doc.ext-doc-type = {&TDEDT_Ras_Vnesh}
        and trn-is-return
        then do :
          if (bf_contract.status_ = {&objdt-closed}
          or (bf_contract.contract-date-end <> ? and bf_contract.contract-date-end < t-doc.doc-date))
          then do:
            message "Выбранный договор поставки закрыт или истёк срок его действия, оформить возврат невозможно. Обратитесь в офис для корректировки договора." view-as alert-box .
            run check-cli no-error.
            if error-status :error
            then return error .
            else return .
          end .
          if bf_contract.spec-check = 0
          then do :
            message "Для выбранного договора поставки не определена схема возврата, оформить возврат невозможно. Обратитесь в офис для корректировки договора." view-as alert-box .
            run check-cli no-error.
            if error-status :error
            then return error .
            else return .
          end .
          if not can-find(first buf_trn-reason no-lock where buf_trn-reason.reason-code = bf_contract.spec-check) then
          do:
            message "Для выбранного договора поставки не определена схема возврата, оформить возврат невозможно. Обратитесь в офис для корректировки договора." view-as alert-box .
            run check-cli no-error.
            if error-status :error
            then return error .
            else return .
          end.
        end .
        
        
        
        assign
          t-doc.contract-code = varcontract-code
          t-doc.exch-code     = bf_contract.curr-code
          t-doc.exch-rate     = varexch-rate
          t-doc.exch-scale    = varexch-scale
        .
        v-master = Is-Master-Slave-Contract( buffer bf_contract) .
        if v-master  = "+" or v-master  = ""  then do :
          find first bf-f_contract-specif no-lock where bf-f_contract-specif.contract-num = bf_contract.contract-code
                                                    and bf-f_contract-specif.host-code = bf_contract.host-code no-error.
        end.
        else do :
          find first bf-f_contract-specif no-lock where bf-f_contract-specif.contract-num =integer(v-master)
                                                    and bf-f_contract-specif.host-code = bf_contract.host-code no-error.
        end.
        if available bf-f_contract-specif then do:
          t-doc.vat-type = bf-f_contract-specif.vat-type .
        end.
        run chg-purch-contract in this-procedure.
      end.
    end.
  end.
else do:
  assign
    t-doc.contract-code  = 0.
end.
if varhold = "yes" then do:
  if paris-hold and
    input frame {&frame-name} t-doc.cli-type = {&prs} then do:
    message "Вы работаете со своими фирмами. Физическое лицо не может являться контрагентом."
    view-as alert-box.
    apply "entry" to t-doc.cli-code in frame {&frame-name}.
    return error.
  end.
  if input frame {&frame-name} t-doc.cli-type = {&cmp} then do:
    find first buf_sysconf no-lock
         where buf_sysconf.host-code = input frame {&frame-name} t-doc.cli-code no-error.
  end.
  case t-doc.ext-doc-type :
    when {&TDEDT_Pri_Vnesh} then do:
      if paris-hold = yes then do:
        message "Критическая ошибка. Внешний приход между своими фирмами должен генериться автоматически."
        view-as alert-box error.
        apply "entry" to t-doc.cli-code in frame {&frame-name}.
        return error.
      end.
      else do:
         if available buf_sysconf then do:
           message "Внешний приход оформляется от своей фирмы."
                   "Вы уверены?" view-as alert-box buttons yes-no update varlog.
           if varlog <> yes then do:
             apply "entry" to t-doc.cli-code in frame {&frame-name}.
             return error.
           end.
            { gbl/chk-actg.i
              v-cntxt-db-num
              v-cntxt-userid
              {&action-head-code-main}
              'actn_income_prepownfirmhold':U
              {&cntxt-object}
              t-doc.host-code
              t-doc.obj-type
              t-doc.obj-code
              0
              0
              0
              true
              varlog
            }
           if varlog <> yes then do:
             apply "entry" to t-doc.cli-code in frame {&frame-name}.
             return error.
           end.
           assign
             t-doc.hold-doc-code-child  = "no-hold":u
             t-doc.hold-doc-code-parent = "no-hold":u
           .
         end.
      end.
    end.
    when {&TDEDT_Ras_Vnesh} then do:
      if paris-hold = yes then do:
        if not available buf_sysconf then do:
          message
          "В данном пункте меню можно оформить расход только на свою фирму." skip
          view-as alert-box.
          apply "entry" to t-doc.cli-code in frame {&frame-name}.
          return error.
        end.
        find first bf_clients where bf_clients.obj-type = {&cmp}         and
                                    bf_clients.obj-code = input frame {&frame-name} t-doc.cli-code no-lock.
        run check-base-code in this-procedure (recid(bf_clients)).
        find first buf_firm where buf_firm.firm-code = buf_sysconf.host-code no-lock.
        run str/chshobj.w (input  input frame {&frame-name} t-doc.cli-code,
                       input  buf_firm.main-obj-type,
                       input  buf_firm.main-obj-code,
                       output parhold-obj-type,
                       output parhold-obj-code ) no-error.
        if error-status :error then do:
          message
            "Ошибка при определении объекта при межфирменном перемещении."
            view-as alert-box.
          apply "entry" to t-doc.cli-code in frame {&frame-name}.
          return error.
        end.
        if  parhold-obj-type = ""
        and parhold-obj-code = 0
        then do:
          message "Не выбран объект для межфирменного перемещения."
          view-as alert-box information.
          apply "entry" to t-doc.cli-code in frame {&frame-name}.
          return error.
        end.

        find first buf-hold_clients where buf-hold_clients.obj-type = parhold-obj-type and
                                          buf-hold_clients.obj-code = parhold-obj-code no-lock no-error.
        if not available buf-hold_clients then do:
          message "Не верный объект " parhold-obj-type " " parhold-obj-code " для межфирменного перемещения."
          view-as alert-box error.
          apply "entry" to t-doc.cli-code in frame {&frame-name}.
          return error.
        end.
        if buf-hold_clients.obj-type <> {&shop}  and
           buf-hold_clients.obj-type <> {&stock} then do:
           message "Объект для межфирменном перемещения имеет тип " buf-hold_clients.obj-type " ." skip
                   "Он должен быть склад или магазин."
           view-as alert-box.
           apply "entry" to t-doc.cli-code in frame {&frame-name}.
           return error.
        end.
        if buf-hold_clients.obj-type = {&shop} then do:
          find first buf-hold_shop where buf-hold_shop.obj-code = buf-hold_clients.obj-code no-lock.
          if buf-hold_shop.host-code <> input frame {&frame-name} t-doc.cli-code then do:
            message "Объект " parhold-obj-type " " parhold-obj-code " для межфирменного перемещения не принадлежит фирме " input frame {&frame-name} t-doc.cli-code " ."
            view-as alert-box error.
            apply "entry" to t-doc.cli-code in frame {&frame-name}.
            return error.
          end.
        end.
        if buf-hold_clients.obj-type = {&stock} then do:
          find first buf-hold_store where buf-hold_store.obj-code = buf-hold_clients.obj-code no-lock.
          if buf-hold_store.host-code <> input frame {&frame-name} t-doc.cli-code then do:
            message "Объект " parhold-obj-type " " parhold-obj-code " для межфирменного перемещения не принадлежит фирме " input frame {&frame-name} t-doc.cli-code " ."
            view-as alert-box error.
            apply "entry" to t-doc.cli-code in frame {&frame-name}.
            return error.
          end.
        end.
    run adm/shattri.p (
      input "get":U
      ,input parhold-obj-type
      ,input parhold-obj-code
      ,input {&attr-contr-in}
      ,input  "contr-in-income"
      ,output v-value-character
      ,output v-value-date
      ,output v-value-decimal
      ,output v-value-integer
      ,output v-value-logical
      ,output varcontract-type
      ,INPUT-OUTPUT TABLE-handle v-tth
      ) no-error .
      if error-status :error then
      message
        vss-workfile vss-revision vss-description skip
        error-status :get-message(1) skip
        return-value skip
        "adm/shattri.p"
        view-as alert-box error
      .
      delete object v-tth.
      if v-value-logical = true then varcontract-cli = "yes" .
                                else varcontract-cli = "no" .

        assign
          t-doc.hold-obj-type        = parhold-obj-type
          t-doc.hold-obj-code        = parhold-obj-code
          t-doc.hold-doc-code-child  = "hold":u
          t-doc.hold-doc-code-parent = "hold":u.
        if varis-fin <> "yes" then do:
          assign
            t-doc.contract-code = 0.
        end.
        else do:
          if paris-hold = yes then do:
            if varcontract-code <> 0 then do:
              find first bf_contract where bf_contract.contract-code  = varcontract-code       no-lock no-error.
            end.
            else do:  
            find first bf_contract where bf_contract.host-code = t-doc.host-code  and
                                        bf_contract.cli-type  = {&cmp}                                    and
                                        bf_contract.cli-code  = buf_sysconf.host-code                     no-lock no-error.
            end.
          if not available bf_contract then do:
            if varcontract-cli <> "yes" then do:
              assign
                t-doc.contract-code  = 0.
            end.
            else do:
              message "По клиенту " t-doc.host-code " " {&cmp}
                      " на фирме " input frame {&frame-name} t-doc.cli-code " нет ни одного договора. Приход не может быть оформлен."
              view-as alert-box error.
              apply "entry" to t-doc.cli-code in frame {&frame-name}.
              return error.
            end.
          end.
          else do:
            t-doc.contract-code = bf_contract.contract-code.
          end.  
          end. /*if paris-hold = yes then do:*/
          else do:   
          find first bf_contract where bf_contract.host-code = input frame {&frame-name} t-doc.cli-code  and
                                       bf_contract.cli-type  = {&cmp}                                    and
                                       bf_contract.cli-code  = t-doc.host-code                           no-lock no-error.
          if not available bf_contract then do:
            if varcontract-cli <> "yes" then do:
              assign
                t-doc.contract-code  = 0.
            end.
            else do:
              message "По клиенту " t-doc.host-code " " {&cmp}
                      " на фирме " input frame {&frame-name} t-doc.cli-code " нет ни одного договора. Приход не может быть оформлен."
              view-as alert-box error.
              apply "entry" to t-doc.cli-code in frame {&frame-name}.
              return error.
            end.
          end.
          else do:
            run check-contract-code in this-procedure (input  "choose":u,
                                                       input  input frame {&frame-name} t-doc.cli-code,
                                                       input  {&cmp},
                                                       input  t-doc.host-code,
                                                       input  ?,
                                                       input  parparentproc,
                                                       input  t-doc.doc-date,
                                                       input {&income},
                                                       output varcontract-code) no-error.
            if error-status :error    or
               varcontract-code = ?  or
               varcontract-code = 0  then do:
              if varcontract-cli <> "yes":u then do:
                message "Вы не выбрали договор. Вы хотите оформить внешний приход без договора?"
                view-as alert-box question buttons yes-no update varlog.
                if varlog = no then do:
                  return error.
                end.
                else do:
                  assign
                    t-doc.contract-code = 0.
                end.
              end.
              else do:
                message "Вы не выбрали договор. Приход не может быть оформлен."
                view-as alert-box error.
                apply "entry" to t-doc.cli-code in frame {&frame-name}.
                return error.
              end.
            end.
            else do:
              assign
                t-doc.contract-code = varcontract-code.
            end.
          end.
          end.
        end. /*else do*/
      end.
      else do:
        if available buf_sysconf then do:
          message "В данном пункте меню можно оформить расход только на внешнего контрагента."
          "Вы хотите оформить расход на свою фирму, как на внешнего контрагента, без автоматической генерации прихода?"
          view-as alert-box question buttons yes-no update varlog.
          if varlog <> yes then do:
            apply "entry" to t-doc.cli-code in frame {&frame-name}.
            return error.
          end.
          else do:
            { gbl/chk-actg.i
              v-cntxt-db-num
              v-cntxt-userid
              {&action-head-code-main}
              'actn_expense_prepownfirmhold':U
              {&cntxt-object}
              t-doc.host-code
              t-doc.obj-type
              t-doc.obj-code
              0
              0
              0
              true
              varlog
            }
            if varlog <> yes then do:
              apply "entry" to t-doc.cli-code in frame {&frame-name}.
              return error.
            end.
            else do:
              assign
                t-doc.hold-doc-code-child  = "no-hold":u
                t-doc.hold-doc-code-parent = "no-hold":u .
            end.
          end.
        end.
      end.
    end.
    when {&TDEDT_Vozvrat_Vnesh} then do:
      if available buf_sysconf then do:
        message "Вы хотите оформить возврат от своей фирмы, как от внешнего контрагента?"
        view-as alert-box question buttons yes-no update varlog.
        if varlog <> yes then do:
          apply "entry" to t-doc.cli-code in frame {&frame-name}.
          return error.
        end.
        else do:
          { gbl/chk-actg.i
            v-cntxt-db-num
            v-cntxt-userid
            {&action-head-code-main}
            'actn_return_prepownfirmhold':U
            {&cntxt-object}
            t-doc.host-code
            t-doc.obj-type
            t-doc.obj-code
            0
            0
            0
            true
            varlog
          }
          if varlog <> yes then do:
            apply "entry" to t-doc.cli-code in frame {&frame-name}.
            return error.
          end.
        end.
      end.
    end.
    when {&TDEDT_Ras_Vnesh_VP} then do:
      if paris-hold = yes then do:
        if not available buf_sysconf then do:
          message
          "В данном пункте меню можно оформить возврат поставщику только на свою фирму." skip
          view-as alert-box.
          apply "entry" to t-doc.cli-code in frame {&frame-name}.
          return error.
        end.
        find first buf_firm where buf_firm.firm-code = buf_sysconf.host-code no-lock.
        find first bf_clients where bf_clients.obj-type = {&cmp}         and
                                    bf_clients.obj-code = input frame {&frame-name} t-doc.cli-code no-lock.
        run check-base-code in this-procedure (recid(bf_clients)).

        run str/chshobj.w (input  input frame {&frame-name} t-doc.cli-code,
                       input  buf_firm.main-obj-type,
                       input  buf_firm.main-obj-code,
                       output parhold-obj-type,
                       output parhold-obj-code ) no-error.
        if error-status :error then do:
          message
            "Ошибка при определении объекта при межфирменном перемещении."
            view-as alert-box.
          apply "entry" to t-doc.cli-code in frame {&frame-name}.
          return error.
        end.
        if  parhold-obj-type = ""
        and parhold-obj-code = 0
        then do:
          message "Не выбран объект для межфирменного перемещения."
          view-as alert-box information.
          apply "entry" to t-doc.cli-code in frame {&frame-name}.
          return error.
        end.

        find first buf-hold_clients where buf-hold_clients.obj-type = parhold-obj-type and
                                          buf-hold_clients.obj-code = parhold-obj-code no-lock no-error.
        if not available buf-hold_clients then do:
          message "Не верный объект " parhold-obj-type " " parhold-obj-code " для межфирменного перемещения."
          view-as alert-box error.
          apply "entry" to t-doc.cli-code in frame {&frame-name}.
          return error.
        end.
        if buf-hold_clients.obj-type <> {&shop}  and
           buf-hold_clients.obj-type <> {&stock} then do:
           message "Объект для межфирменном перемещения имеет тип " buf-hold_clients.obj-type " ." skip
                   "Он должен быть склад или магазин."
           view-as alert-box.
           apply "entry" to t-doc.cli-code in frame {&frame-name}.
           return error.
        end.
        if buf-hold_clients.obj-type = {&shop} then do:
          find first buf-hold_shop where buf-hold_shop.obj-code = buf-hold_clients.obj-code no-lock.
          if buf-hold_shop.host-code <> input frame {&frame-name} t-doc.cli-code then do:
            message "Объект " parhold-obj-type " " parhold-obj-code " для межфирменного перемещения не принадлежит фирме " input frame {&frame-name} t-doc.cli-code " ."
            view-as alert-box error.
            apply "entry" to t-doc.cli-code in frame {&frame-name}.
            return error.
          end.
        end.
        if buf-hold_clients.obj-type = {&stock} then do:
          find first buf-hold_store where buf-hold_store.obj-code = buf-hold_clients.obj-code no-lock.
          if buf-hold_store.host-code <> input frame {&frame-name} t-doc.cli-code then do:
            message "Объект " parhold-obj-type " " parhold-obj-code " для межфирменного перемещения не принадлежит фирме " input frame {&frame-name} t-doc.cli-code " ."
            view-as alert-box error.
            apply "entry" to t-doc.cli-code in frame {&frame-name}.
            return error.
          end.
        end.
        assign
          t-doc.hold-obj-type        = parhold-obj-type
          t-doc.hold-obj-code        = parhold-obj-code
          t-doc.hold-doc-code-child  = "hold":u
          t-doc.hold-doc-code-parent = "hold":u.
      end.
      else do:
        if available buf_sysconf then do:
          message "В данном пункте меню можно оформить возврат поставщику только на внешнего контрагента."
          "Вы хотите оформить возврат поставщику на свою фирму, как на внешнего контрагента, без автоматической генерации возврата от покупателя?"
          view-as alert-box question buttons yes-no update varlog.
          if varlog <> yes then do:
            apply "entry" to t-doc.cli-code in frame {&frame-name}.
            return error.
          end.
          else do:
            { gbl/chk-actg.i
              v-cntxt-db-num
              v-cntxt-userid
              {&action-head-code-main}
              'actn_expense_prepownfirmhold':U
              {&cntxt-object}
              t-doc.host-code
              t-doc.obj-type
              t-doc.obj-code
              0
              0
              0
              true
              varlog
            }
            if varlog <> yes then do:
              apply "entry" to t-doc.cli-code in frame {&frame-name}.
              return error.
            end.
            else do:
              assign
                t-doc.hold-doc-code-child  = "no-hold":u
                t-doc.hold-doc-code-parent = "no-hold":u .
            end.
          end.
        end.
      end.
    end.
    otherwise do:
    end.
  end case.
end.
assign
  t-doc.cli-code = input frame {&frame-name} t-doc.cli-code
  t-doc.cli-type = input frame {&frame-name} t-doc.cli-type.
display ub.clients.obj-name with frame {&frame-name}.
pardoc-mode = {&update}.
if ub.clients.obj-type = {&cmp} then do:
  /* ищем менеджера */
  find ub.firm where ub.firm.firm-code = ub.clients.obj-code no-lock.
  find ub.clients where ub.clients.obj-type = {&prs}
                        and ub.clients.obj-code = ub.firm.tobj-code no-lock no-error.
  if available ub.clients then
    display ub.clients.obj-code @ t-doc.boss
            ub.clients.obj-name @ boss-name with frame {&frame-name}.
end.
release ub.clients.
&if "{1}" = "out" &then
if t-doc.internal then do:
  assign
    t-doc.print-rubl = (if varr-b = "base":u then no else yes).
end.
else do:
  assign
    t-doc.print-rubl = yes.
end.
if not(not t-doc.internal and t-doc.doc-type = {&return}) then do:
  { gbl/curobjdt.i t-doc.obj-type t-doc.obj-code v-today }
  ASSIGN
    t-doc.rsrv-date = v-today + v-cntxp-rsrv-time
  .
end.
if t-doc.doc-type = {&expense} and
   t-doc.internal = no         then do:
  display t-doc.pay-code with frame {&frame-name}.
  /* ищем дисконтную карту */
  if t-doc.ret-supp = no then do:
    find first ub.dis-card where ub.dis-card.cli-type = t-doc.cli-type and
                              ub.dis-card.cli-code = t-doc.cli-code and
                              ub.dis-card.emitent-host-code = t-doc.host-code and
                              ub.dis-card.status_           = {&current-status} OR
                              ub.dis-card.cli-type = t-doc.cli-type and
                              ub.dis-card.cli-code = t-doc.cli-code and
                              ub.dis-card.emitent-host-code = 0 and
                              ub.dis-card.status_           = {&current-status} no-lock no-error.
    if available ub.dis-card then do:
      varlog = no.
      message "На выбранного клиента зарегистрирована одна или более дисконтных карт." skip
                      "Первая из них: №" ub.dis-card.d-card "Скидка:" ub.dis-card.d-pcnt "%" skip (2)
                      "Подставить эту скидку в счет ?"
                      view-as alert-box question buttons yes-no update varlog.
      if varlog then do:
        assign
          t-doc.discnt-pc   = ub.dis-card.d-pcnt
          t-doc.discnt-type = {&card}
          t-doc.d-card      = ub.dis-card.d-card.
      end.
    end.
  end.
end.
/*Для внутреннего расхода, если установлен параметр - "спрашивать цену", в точности это и делаем */
if t-doc.doc-type = {&expense} and
   t-doc.internal = yes        and
   varintprmvq    = yes    then do:
  if t-doc.cli-type = {&shop} then do:
     find bf_shop where bf_shop.obj-code = t-doc.cli-code no-lock.
     assign
       varis-perm = bf_shop.in-perm.
  end.
  if varis-perm <> yes then do:
    run gbl/d-askw.w
      (input "Вопрос"
      ,input "По каким ценам будем делать внутренний расход, объекта приемника или объекта источника?"
      ,input "|^"
      ,input "Цена источника|"
           + "Цена приемника|"
           + "Отмена"
      ,input "Исходя из цен объекта " + t-doc.obj-type + " " + string(t-doc.obj-code) + ".|"
           + "Исходя из цен объекта " + t-doc.cli-type + " " + string(t-doc.cli-code) + ".|"
           + "Отменить."
      ,input 1
      ,input 3
      ,output v-num
      ).
    if v-num = 3 then do:
      return error.
    end.
    if v-num = 2 then do:
      { str/tdat-wrt.i
          t-doc.doc-code
          {&trdcattr-price-target}
          "'yes':U"
          no-error
      }
      if error-status :error then do:
        message "Ошибка при записи атрибута документа." skip
                return-value skip
        view-as alert-box error.
        return error.
      end.
    end.
  end.
end.
run UI-on ("enable").
if b-add:sensitive = yes then apply "entry" to b-add in frame {&frame-name}.
&else
run UI-on ("enable").
&endif
end.
end procedure.

procedure check-rate :
/* -----------------------------------------------------------
  Purpose:     проверка заданности курсов и масштабов валют
-------------------------------------------------------------*/
define variable varbase-code as integer no-undo.
{ gbl/basecode.i v-cntxt-host-code-obj varbase-code }
&IF "{1}" = "in"
&THEN
define variable flag-recount as logical initial no no-undo.
/*Если курс изменился, то в конце пересчитаем накладную*/
if input frame {&frame-name} t-doc.exch-rate  <> t-doc.exch-rate  or
   input frame {&frame-name} t-doc.exch-scale <> t-doc.exch-scale or
   input frame {&frame-name} t-doc.base-rate  <> t-doc.base-rate  or
   input frame {&frame-name} t-doc.base-scale <> t-doc.base-scale then flag-recount = yes.
&endif
if input frame {&frame-name} t-doc.base-rate = ? or
   input frame {&frame-name} t-doc.base-rate = 0 then do:
  message "Не задан курс базовой валюты.".
  apply "entry" to t-doc.base-rate in frame {&frame-name}.
  return error.
end.
if input frame {&frame-name} t-doc.base-scale = ? or
   input frame {&frame-name} t-doc.base-scale = 0 then do:
  message "Не задан масштаб базовой валюты.".
  apply "entry" to t-doc.base-scale in frame {&frame-name}.
  return error.
end.
assign frame {&frame-name}
  t-doc.base-rate
  t-doc.base-scale.
&IF "{1}" = "out"
&THEN
if t-doc.print-rubl then
  assign
    t-doc.exch-code  = 0
    t-doc.exch-rate  = 1
    t-doc.exch-scale = 1.
else
  assign
    t-doc.exch-code  = varbase-code
    t-doc.exch-rate  = t-doc.base-rate
    t-doc.exch-scale = t-doc.base-scale.
&endif
&if "{1}" = "in" &then
if input frame {&frame-name} t-doc.exch-rate = ? or
   input frame {&frame-name} t-doc.exch-rate = 0 then do:
  message "Не задан курс валюты поставщика.".
  apply "entry" to t-doc.exch-rate in frame {&frame-name}.
  return error.
end.
if input frame {&frame-name} t-doc.exch-scale = ? or
   input frame {&frame-name} t-doc.exch-scale = 0 then do:
  message "Не задан масштаб валюты поставщика.".
  apply "entry" to t-doc.exch-scale in frame {&frame-name}.
  return error.
end.
assign
  frame {&frame-name}
  t-doc.exch-rate
  t-doc.exch-scale.
run waitfram-show in this-procedure  ("ЖДИТЕ.  Пересчет документа ...").
if flag-recount then do:
   run full-recount.
end.
run waitfram-hide in this-procedure  .
&endif
end procedure.

&endif    /* для НЕ инвентаризации */
&endif    /* для НЕ переоценки */

&if "{1}" <> "inv" &then
procedure mode-on :
define variable varout-ret-supp like ub.trn-doc.ret-supp no-undo.
define variable varout-pay-code like ub.trn-doc.pay-code no-undo.
define variable vardoc-code     like ub.trn-doc.doc-code no-undo.
define variable v-today         as date                  no-undo.
define buffer cli_clients  for ub.clients.
define buffer cli_firm     for ub.firm.
define buffer main_clients for ub.clients.
define buffer cli_sysconf  for ub.sysconf.
define variable varpurch-code as integer   no-undo.
define variable varbase-code as integer no-undo.
{ gbl/basecode.i v-cntxt-host-code-obj varbase-code }
/* везде в этой процедуре, где надо вернуть из нее ошибку, используем undo,
    т.к. иначе error-status :error в вызывающей программе не срабатывает */
/* -----------------------------------------------------------
  Purpose:     чтение или создание шапки
-------------------------------------------------------------*/
do on error undo, return error :
case pardoc-mode :
  when {&add-def} then do:
    { gbl/curobjdt.i v-cntxt-obj-type v-cntxt-obj-code v-today }
    find last ub.curr-accnt where ub.curr-accnt.curr-code = varbase-code
        and ub.curr-accnt.exch-date <= v-today use-index pi no-lock no-error.
    if not available ub.curr-accnt then do:
      message "На дату" v-today "неизвестен курс базовой валюты.".
      undo, return error.
    end.
    &if "{1}" = "out" &then
    if v-cntxt-db-num-obj <> v-cntxt-db-num and parstat <> {&inquiry}  then do:
      message "Накладная не может быть выписана на пассивной стороне."
                      "Используйте запрос.".
      undo, return error.
    end.
    &endif
    if parinternal = ? then do:
      message "Неизвестно, внутренний или внешний документ.".
      undo, return error.
    end.
    /* разрешаем выписывать запросы и на внутренний приход */
    if parinternal and partype = {&return} then do:
      message "Для внутреннего перемещения можно создать только расход."
                      "Остальные документы создаются автоматически.".
      undo, return error.
    end.
    &if "{1}" = "out" &then
    case partype :
     when {&income}    then do:
       assign
       varout-ret-supp = no.
       varout-pay-code = v-cntxp-out-pay. /* для приходного запроса */
     end.
     when {&expense}   then do:
        if parext-doc-type = {&TDEDT_Ras_Vnesh_VP} then do:
           assign
           varout-ret-supp = yes
           varout-pay-code = v-cntxp-ret-sup-pay.
        end.
        else do:
          assign
          varout-pay-code = v-cntxp-out-pay.
        end.
     end.
     when {&write-off} then do:
       assign
       varout-ret-supp = no
       varout-pay-code = v-cntxp-down-pay.
     end.
     when {&return} then do:
       assign
       varout-ret-supp = no.
       varout-pay-code = v-cntxp-ret-pay.
     end.
    end case.
    &endif
    &if '{1}' = 'in' &then
    if v-cntxt-obj-type = {&stock} then do:
      find first ub.store where ub.store.obj-code = v-cntxt-obj-code no-lock.
      assign
        varpurch-code = ub.store.purch-code.
    end.
    else do:
      find first ub.shop where ub.shop.obj-code = v-cntxt-obj-code no-lock.
      assign
        varpurch-code = ub.shop.purch-code.
    end.
    if varpurch-code <> ? then do:
      if lookup (string(varpurch-code), {&purchase-codes}) = 0 then do:
        message "Неверный код типа приобретения по умолчанию для объекта. " skip
                "Допустимые типы: " {&purchase-code-full}
        view-as alert-box error.
        return error.
      end.
    end.
    if varpurch-code = ? then do:
      find first ub.sysconf where ub.sysconf.host-code = v-cntxt-host-code-obj no-lock.
      if lookup (string(ub.sysconf.purch-code), {&purchase-codes}) = 0 then do:
        message "Неверный код типа приобретения по умолчанию для фирмы. " skip
                "Допустимые типы: " {&purchase-code-full}
        view-as alert-box error.
        return error.
      end.
      assign
        varpurch-code = ub.sysconf.purch-code.
    end.
    &endif
    { gbl/curobjdt.i v-cntxt-obj-type v-cntxt-obj-code v-today }
    run doc-code in this-procedure
      (input  "main",
       input  v-cntxt-obj-type,
       input  v-cntxt-obj-code,
       input  ?,
       output vardoc-code ) no-error.
    if error-status :error then do:
      message "Ошибка при генерации номера документа." return-value view-as alert-box.
      return error.
    end.
    { str/crtrndoc.i
      ?
      ?
      ub.curr-accnt.exch-rate
      ub.curr-accnt.exch-scale
      ?
      ?
      ?
      v-cntxt-db-num
      v-cntxt-userid
      " &if '{1}' = 'out'
        &then {&percent}
        &else "''"
        &endif "
      vardoc-code
      v-today
      " &if   '{1}' = 'out'
        &then partype
        &else {&income}
        &endif "
      no
      v-cntxt-host-code-obj
      parinternal
      v-cntxt-obj-code
      v-cntxt-obj-type
      no
      " &if   '{1}' = 'out'
        &then varout-pay-code
        &else v-cntxp-in-pay
        &endif
      "
      "'@  '"
      " &if   '{1}' = 'out'
        &then varout-ret-supp
        &else no
        &endif
      "
      " &if   '{1}' = 'out' or '{1}' = 'pr'
        &then ?
        &else varslt-type-def
        &endif "
      " &if '{1}' = 'in' or '{1}' = 'out' &then parstat &else {&wayb} &endif "
      " &if   '{1}' = 'out' or '{1}' = 'pr'
        &then ?
        &else varvat-type-def
        &endif "
      parext-doc-type
      " &if '{1}' = 'in' &then
        varpurch-code
        &else
        ?
        &endif
      "
      no-error
    }
    if error-status :error then do:
      undo, return error return-value.
    end.
    find t-doc where t-doc.doc-code = vardoc-code.
    assign
      pardoc-rec = recid (t-doc)
      .
    &if "{1}" = "out" &then
       if not can-find(first ub.pay-type where ub.pay-type.obj-code = t-doc.pay-code no-lock) then do:
          case t-doc.doc-type :
            when {&income} or  when {&expense} then
               message "В настройках текущего объекта указан вид оплаты: " v-cntxp-out-pay ", которого нет в справочнике!"
                   view-as alert-box error buttons ok.
            when {&write-off} then
              message "В настройках текущего объекта указан вид оплаты списания: " v-cntxp-down-pay ", которого нет в справочнике!"
                   view-as alert-box error buttons ok.
            when {&return} then
             message "В настройках текущего объекта указан вид оплаты возврата: " v-cntxp-ret-pay ", которого нет в справочнике!"
                   view-as alert-box error buttons ok.
          end.
          undo, return error.
       end.
    &else
       if not can-find(first ub.pay-type where ub.pay-type.obj-code = t-doc.pay-code no-lock) then do:
          message "В настройках текущего объекта указан вид оплаты прихода: " v-cntxp-in-pay ", которого нет в справочнике!"
                   view-as alert-box error buttons ok.
          undo, return error.
       end.
    &endif
  end.
  when {&lookup} then do:
    find t-doc no-lock where recid( t-doc ) = pardoc-rec no-error.
    if available t-doc then do:
      if t-doc.internal = ? then do:
        message "Документ был заведен неверно и удаляется!!!" view-as alert-box.
        find t-doc exclusive-lock where recid( t-doc ) = pardoc-rec.
        delete t-doc. /* на случай отвала до установки клиента */
        return.
      end.
      if parext-doc-mode <> "":U then do:
        find t-doc exclusive-lock where recid( t-doc ) = pardoc-rec.
      end.
    end. /* if available t-doc */
  end.
  when {&update} then do:
    find t-doc where recid (t-doc) = pardoc-rec no-error. /* для сетевых проверок */
    if available t-doc then do:  /* на not avail здесь проверять нельзя - ветка дальше */
      if t-doc.cli-code = ? then do:
        message "Документ был заведен неверно и удаляется!!!" view-as alert-box.
        delete t-doc. /* на случай отвала до установки клиента */
        return.
      end.  /* без установки клиента док-т не виден, так что эта проверка бессмысленна. */
      /* работает в т.ч. для внутр. ПН */
      if t-doc.flag_ = yes and t-doc.status_ = {&wayb} and t-doc.doc-type <> {&income} and t-doc.ext-doc-type <> {&TDEDT_Ras_Object} then do:
        find t-doc where recid (t-doc) = pardoc-rec.
        message "Факт. кол-во можно проставлять только в статусе разрешен.".
        undo, return error.
      end.
      if t-doc.status_ = {&cash-desk} then do:
        find t-doc where recid (t-doc) = pardoc-rec.
        message "Все действия с кассовыми отчетами выполняются из АРМ Магазин.".
        undo, return error.
      end.
      if t-doc.status_ = {&fact} or
         (t-doc.flag_ = yes and t-doc.status_ = {&inquiry}) then do:        /* сетевая проверка */
        find t-doc where recid (t-doc) = pardoc-rec.
        message "Документ уже закрыт. Изменение невозможно.".
        undo, return error.
      end.
      if  t-doc.flag_ = yes
      then do:
        define variable v-obj-active  as logical   no-undo .
        { gbl/objat.i
          t-doc.obj-type
          t-doc.obj-code
          "'active=request':u"
          v-obj-active
        }
        if v-obj-active <> true
        then do:
          find t-doc
            where recid (t-doc) = pardoc-rec.
          message
            "Коррекция фактического количества допустима только в базе данных объекта" skip
            "Документ" t-doc.doc-code skip
            "Объект" t-doc.obj-type t-doc.obj-code skip
            view-as alert-box information .
          undo, return error.
        end.
      end.
      find t-doc exclusive-lock
        where recid (t-doc) = pardoc-rec
        .
    end.
  end.
end.
if not available t-doc
then do:
  message "Неправильно выбран документ.".
  undo, return error.
end.
end.
end procedure.
&endif    /* для НЕ инвентаризации */

&if "{1}" = "out" &then
procedure recalc-slt:
def var v-slt-pc        like ub.doc-line.slt-pc    no-undo.
def var v-host-code     like ub.sysconf.host-code  no-undo.
do on error undo, return error return-value :
find ub.sysconf where ub.sysconf.host-code = v-cntxt-host-code-obj no-lock.
if t-doc.pay-code = ub.sysconf.cash-pay then t-doc.slt-type = {&inc-slt}.
{ gbl/hostcode.i t-doc.obj-type t-doc.obj-code v-host-code }
for each ub.doc-line where ub.doc-line.doc-code = t-doc.doc-code exclusive,
    each ub.goods where ub.goods.artic     = ub.doc-line.artic and
                     ub.goods.prod-code = ub.doc-line.prod-code and
                     ub.goods.prod-type = ub.doc-line.prod-type no-lock on error undo, return error return-value :
  if t-doc.pay-code = ub.sysconf.cash-pay
     and not t-doc.internal
     and can-do ({&expense_return}, t-doc.doc-type)
  then do:
     { gbl/pftxvalg.i ub.goods.gds-code {&slt-tax-code} ? v-host-code t-doc.obj-type t-doc.obj-code v-slt-pc no-error }
     assign ub.doc-line.slt-pc =  v-slt-PC.
  end.
  else do:
     assign ub.doc-line.slt-pc =  0.
  end.
end.
run gbl/calc-trn.p (input parparentproc, input recid(t-doc)).
end.
end procedure.
&ENDIF

procedure notes-tr:
define variable notes as character no-undo.
assign
  notes = t-doc.PS.
if pardoc-mode = {&lookup} then do:
  run gbl/d-prompt.w (
      'title=Примечание\'
    + 'type=editor\'
    + 'fillin_width=96\'
    + 'fillin_height=15\'
    + 'readonly=yes\'
    , input-output notes).
end.
else do:
   run gbl/d-prompt.w (
      'title=примечание\'
    + 'type=editor\'
    + 'fillin_width=96\'
    + 'fillin_height=15\'
    , input-output notes).
    if return-value = 'false':u then return .
  if t-doc.PS <> notes then do:
  if pardoc-rec = ? then pardoc-rec = recid (t-doc). /* топорно, но работает */
    do transaction on error undo, return error return-value :
      find t-doc where recid (t-doc) = pardoc-rec exclusive.
      assign
        t-doc.PS = notes.
    end.
  end.
end.
end procedure.

&if "{1}" <> "inv" &then
procedure choose-cli:
define variable varfirm-code like ub.firm.firm-code no-undo.
define variable v-types as character no-undo .
define buffer bf_clients for ub.clients.
define variable ref-rec as recid no-undo.
define variable v-rid-list as character no-undo .
do on error undo, return error return-value :
run check-cli no-error.
if error-status :error then do:
  if t-doc.internal then v-types = {&shop}.
                    else v-types = {&all}.  /* режим справочника */
  if (t-doc.ext-doc-type = {&TDEDT_Ras_Vnesh} or t-doc.ext-doc-type = {&TDEDT_Ras_Vnesh_VP}) and
     varhold            = "yes"              and
     paris-hold         = yes                then do:
    assign
      varfirm-code = ?.
    run adm/sconfs.w ( input parparentproc
                    , input "b-sel":U
                    , input no
                    , input ?
                    , output varfirm-code
                    , input-output v-rid-list) no-error.
    if error-status :error or
       varfirm-code = ?   then do:
      return error.
    end.
    find first bf_clients where bf_clients.obj-type = {&cmp}       and
                                bf_clients.obj-code = varfirm-code no-lock.
    assign ref-list = string(recid (bf_clients)).
    run check-base-code in this-procedure (recid(bf_clients)).
  end.
  else do:
    if transaction = yes then do:
      message "Критическая ошибка." skip
              "Вы находитесь в транзакции." skip
              "Работа со справочником клиентов невозможна."
      view-as alert-box error.
      return error.
    end.
    run ref/cli-all.w ( parparentproc
                   , "b-sel,b-add"
                   , v-types
                   , ?
                   , ?
                   , ?
                   , ?
                   , ?
                  , output ref-list) .
  end.
  if ref-list <> "" then do:
    ref-rec = integer (ref-list).
    find ub.clients where recid ( ub.clients ) = ref-rec no-lock.
    disp ub.clients.obj-code @ t-doc.cli-code
            ub.clients.obj-name with frame {&frame-name}.
  &if "{1}" <> "in" &then if pardoc-mode = {&add-def} then &endif
    disp ub.clients.obj-type @ t-doc.cli-type with frame {&frame-name}.
  end.
  run check-cli no-error.
  if error-status :error then do:
    return error return-value.
  end.
end.
end.
end procedure.
&endif

&if "{1}" <> "inv" &then
&if "{1}" <> "pr" &then
procedure state-pay-code:
do transaction on error undo, return error :
   if input frame {&frame-name} t-doc.pay-code = v-cntxp-ret-sup-pay then do:
      message "Нельзя устанавливаться код возврата поставщику." skip
              "Возврат поставщику оформляется из отдельнего пункта меню."
      view-as alert-box error.
      undo, return error.
   end.
   assign t-doc.pay-code = input frame {&frame-name} t-doc.pay-code no-error.
   &if "{1}" = "in" &then
   for each ub.parts where ub.parts.out-code = t-doc.doc-code:
       assign ub.parts.pay-code = t-doc.pay-code.
   end.
   &endif
   &if "{1}" = "out"
   &then
   if t-doc.ext-doc-type = {&TDEDT_Pri_Perem}
   then do :
     for each ub.parts where ub.parts.out-code = t-doc.doc-code:
       assign ub.parts.pay-code = t-doc.pay-code.
     end.
   end .
   else do :
     run recalc-slt in this-procedure.
   end .
   &endif
end.
&if "{1}" = "out"
&then
   run ui-on("line").
&endif
end procedure.

procedure return-pay-code:
/*Нельзя менять код оплаты на возврат и с возврата обратно если есть хоть одна линия в накладной*/
if input frame {&frame-name} t-doc.pay-code <> t-doc.pay-code then do:
   if input frame {&frame-name} t-doc.pay-code = v-cntxp-ret-sup-pay then do:
      message "Нельзя устанавливаться код возврата поставщику." skip
              "Возврат поставщику оформляется из отдельнего пункта меню."
      view-as alert-box error.
      display t-doc.pay-code with frame {&frame-name}.
      return error.
   end.
end.
find ub.pay-type where ub.pay-type.obj-code = input frame {&frame-name} t-doc.pay-code no-lock no-error.
if not available ub.pay-type then apply "choose" to r-pay.
end procedure.

procedure choose-r-pay:
define variable varrecid-pay as recid no-undo.
define variable v-rid-list as character no-undo .
run ref/paytype.w (input parparentproc, "b-sel", output v-rid-list ).
find ub.pay-type where recid ( ub.pay-type ) = integer(v-rid-list) no-lock no-error.
if not available ub.pay-type then return no-apply.
/*Нельзя менять код оплаты на возврат и с возврата обратно если есть хоть одна линия в накладной*/
if ub.pay-type.obj-code = v-cntxp-ret-sup-pay then do:
   message "Нельзя устанавливаться код возврата поставщику." skip
           "Возврат поставщику оформляется из отдельнего пункта меню."
   view-as alert-box error.
   display t-doc.pay-code with frame {&frame-name}.
   return error.
end.
display ub.pay-type.obj-code @ t-doc.pay-code with frame {&frame-name}.
assign varrecid-pay = recid(ub.pay-type).
run state-pay-code no-error.
if error-status :error then do:
  display t-doc.pay-code with frame {&frame-name}.
  apply "entry" to t-doc.pay-code in frame {&frame-name}.
  return error.
end.
find ub.pay-type where recid(ub.pay-type) = varrecid-pay no-lock.
display t-doc.pay-code ub.pay-type.obj-name with frame {&frame-name}.
end procedure.

procedure leave-pay-code:
define variable varrecid-pay as recid no-undo.
if input frame {&frame-name} t-doc.pay-code = v-cntxp-ret-sup-pay then do:
   message "Нельзя устанавливаться код возврата поставщику." skip
           "Возврат поставщику оформляется из отдельнего пункта меню."
   view-as alert-box error.
   display t-doc.pay-code with frame {&frame-name}.
   return error.
end.
find ub.pay-type where ub.pay-type.obj-code = input frame {&frame-name} t-doc.pay-code no-lock no-error.
if not available ub.pay-type then do:
  message "Нет вида оплаты с таким кодом.".
  display t-doc.pay-code with frame {&frame-name}.
  apply "entry" to t-doc.pay-code in frame {&frame-name}.
  return error.
end.
assign varrecid-pay = recid(ub.pay-type).
run state-pay-code no-error.
if error-status :error then do:
  display t-doc.pay-code with frame {&frame-name}.
  apply "entry" to t-doc.pay-code in frame {&frame-name}.
  return error.
end.
find ub.pay-type where recid(ub.pay-type) = varrecid-pay no-lock.
display ub.pay-type.obj-name with frame {&frame-name}.
end procedure.
&endif
&endif

procedure proc-exit :
  define variable v-vat-pc   as decimal no-undo .
  define variable v-slt-pc   as decimal no-undo .
  define variable v-insalepr as logical no-undo .
  assign parnext-prev = ?.
  &if "{1}" <> "pr" &then
    &if "{1}" <> "inv" &then
  if lookup( pardoc-mode, {&add-def} ) > 0 then do:
    /* отказ от заведения накладной - не было переключения в изменение */
    if not can-find (first ub.doc-line where ub.doc-line.doc-code = t-doc.doc-code no-lock) then do:
      delete t-doc.
      assign pardoc-rec = ?.
    end.
    return.
  end.
    &endif
  if lookup( pardoc-mode, {&update} ) > 0 &if "{1}" = "inv" &then or pardoc-mode = {&add-def} &endif then do:
    if not can-find (first ub.doc-line where ub.doc-line.doc-code = t-doc.doc-code no-lock) and t-doc.is-flora = false then do:
      assign varlog = true .
      message "В документе нет строк, поэтому он удаляется." view-as alert-box question buttons OK-Cancel update varlog.
      if varlog = yes then do:
        if t-doc.is-flora = false then do:
                      /* delete t-doc. */
            define variable varchip-code as decimal   no-undo .
                  run str/del-doc.p
                      ( input  parparentproc,
                        input  t-doc.doc-code,
                        input  v-cntxt-db-num,
                        input  "del-doc.err",
                        input  ?,
                        input  ?,
                        input  v-cntxt-userid,
                        input  t-doc.doc-code,
                        input  ?,
                        output varchip-code )
                        .
          assign pardoc-rec = ?.
          return.
        end.
        else do:
          assign varlog = false .
          message "ВНИМАНИЕ !!! Документ удалится, так как в нем НЕТ ТОВАРОВ!!!"
                     view-as alert-box  question buttons OK-Cancel update varlog .
          if varlog = yes then do:
            delete t-doc.
            assign pardoc-rec = ?.
            return.
          end.
          return error.
        end.
      end.
      else do: return error. end.
    end.
      &if "{1}" = "out" &then
    run check-rate no-error.
    if error-status :error then do: return error. end.
      &endif
    assign frame {&frame-name} t-doc.wrkr t-doc.agnt t-doc.boss .   /* эти поля только выводятся на экран в триггерах */

    define variable v-err as logical   no-undo .

    run str/ver-fl.p ( input pardoc-mode, input t-doc.doc-code , output v-err ) no-error .
    if error-status :error then return error.
    &if "{1}" = "in" &then
    define buffer buff_doc-line for ub.doc-line  .
    define variable v-mess as character no-undo .
    for each buff_doc-line no-lock  where buff_doc-line.doc-code = t-doc.doc-code :
    v-mess = "" .
      { str/linesprc.i recid(buff_doc-line) v-mess }
      if v-mess <> "" then do:
        message v-mess view-as alert-box error TITLE "Сверка количества со спецификацией".
        return error.
      end.
      if not v-cntxp-inout-price and  not t-doc.flag_ then do:
          find ub.goods where ub.goods.artic    = buff_doc-line.artic     and
                           ub.goods.prod-type = buff_doc-line.prod-type and
                           ub.goods.prod-code = buff_doc-line.prod-code no-lock.
          { gbl/pftxvalg.i ub.goods.gds-code {&vat-tax-code} ? t-doc.host-code t-doc.obj-type t-doc.obj-code v-vat-pc no-error }
          { str/st-sltpc.i  recid(ub.goods)   recid(t-doc)  bf_sysconf.cash-pay    v-slt-pc  }
            if  buff_doc-line.vat-pc <> v-vat-pc     or buff_doc-line.slt-pc <> v-slt-pc
            then do:
              v-mess = substitute(" В карточке товара &1 &2 установлены другие налоги !&7 НДС &3% НСП &4% , а в документе &5% и &6%" , ub.goods.gds-code, ub.goods.gds-name, buff_doc-line.vat-pc , buff_doc-line.slt-pc , v-vat-pc , v-slt-pc , {&new-line} ) .
              message v-mess view-as alert-box error TITLE "Запрет на изменение налогов при приеме у поставщика".
              return error.
            end.
      end.
      find ub.goods where ub.goods.artic    = buff_doc-line.artic     and
                       ub.goods.prod-type = buff_doc-line.prod-type and
                       ub.goods.prod-code = buff_doc-line.prod-code no-lock.
      
      { gbl/gdsobjat.i
        buff_doc-line.obj-type
        buff_doc-line.obj-code
        buff_doc-line.artic
        buff_doc-line.prod-type
        buff_doc-line.prod-code
        "'insalepr=request'":U
        v-insalepr
      }
      if v-insalepr <> ? and v-insalepr = true
      then do:
        t-doc.tot-cli = t-doc.tot-calc.
      end.
      
    end.
    &endif
  end.
  &endif
  if t-doc.ext-doc-type = {&TDEDT_Ras_Vnesh_VP}  and pardoc-mode <> {&lookup} then do:
     run str/ep-corrp.p (input parparentproc , input t-doc.doc-code ) no-error.
  end.
  &if "{1}" = "in" or "{1}" = "inv" or "{1}" = "out" &then run fill-mol in this-procedure. &endif
end procedure. /* proc-exit */

procedure check-base-code :
define input parameter parrec-id as recid no-undo.
define variable varmy-host-code  like ub.sysconf.host-code no-undo.
define variable varmy-base-code  like ub.sysconf.base-code no-undo.
define variable varcli-base-code like ub.sysconf.base-code no-undo.
define buffer bf-my_currency  for ub.currency.
define buffer bf-cli_currency for ub.currency.
define buffer bf_clients for ub.clients.

do on error undo, return error return-value :
  find first bf_clients where recid(bf_clients) = parrec-id no-lock.
  { gbl/hostcode.i v-cntxt-obj-type v-cntxt-obj-code varmy-host-code no-error }
  if error-status :error then do:
    message "Ошибка при поиске фирмы для объекта " v-cntxt-obj-type " " v-cntxt-obj-code " ." skip
            return-value skip
            error-status :get-message( 1 )
    view-as alert-box error.
    return no-apply.
  end.
  { gbl/basecode.i varmy-host-code varmy-base-code no-error }
  if error-status :error then do:
    message "Ошибка при поиске базовой валюты для фирмы " varmy-base-code " ." skip
            return-value skip
            error-status :get-message( 1 )
    view-as alert-box error.
    return no-apply.
  end.
  { gbl/basecode.i bf_clients.obj-code varcli-base-code no-error }
  if error-status :error then do:
    message "Ошибка при поиске базовой валюты для фирмы " bf_clients.obj-code " ." skip
            return-value skip
            error-status :get-message( 1 )
    view-as alert-box error.
    return no-apply.
  end.
  if varmy-base-code <> varcli-base-code then do:
    find first bf-my_currency  where bf-my_currency.curr-code  = varmy-base-code  no-lock.
    find first bf-cli_currency where bf-cli_currency.curr-code = varcli-base-code no-lock.
    message "Несоответствие базовых валют фирм при межфирменном перемещении." skip
            "У нашей фирмы " varmy-host-code " базовая валюта " bf-my_currency.curr-abbr " " bf-my_currency.curr-name " с кодом " bf-my_currency.curr-code " ." skip
            "У фирмы контрагента " bf_clients.obj-code " базовая валюта " bf-cli_currency.curr-abbr " " bf-cli_currency.curr-name " с кодом " bf-cli_currency.curr-code " ." skip
            "Межфирменное перемещение невозможно."
    view-as alert-box error.
    return error.
  end.
end.

end procedure.

procedure proc-history :
  define variable loc-ref-list as character no-undo.
  &if "{1}" <> "inv" &then
  define variable loc-doc-save as recid     no-undo.
  define variable loc-mode     as character no-undo.
  define variable loc#stat     as character no-undo.
  define variable loc#type     as character no-undo.
  define variable loc#internal as logical   no-undo.

  define buffer buffer_trn-doc for ub.trn-doc.
  &endif

  &scop lock-table table-name

  &if     "{1}" = "in"  &then
    &scop table-name  t-doc
  &elseif "{1}" = "inv" &then
    &scop table-name  ub.doc-line
  &elseif "{1}" = "out" &then
    &scop table-name  ub.gds-dtl
  &elseif "{1}" = "pr"  &then
    &scop table-name  ub.gds-dtl
    &scop browse-name br-dtl
  &endif

  do on error undo, return error return-value :
    if not available {&table-name} then do:
      message "Неправильный выбор записи." view-as alert-box.
      return error.
    end.
  &if "{1}" <> "inv" &then
    find buffer_trn-doc no-lock where buffer_trn-doc.doc-code = {&table-name}.doc-code.
    assign pardoc-rec      = recid( {&table-name} ).
    { gbl/chk-actg.i
      v-cntxt-db-num
      v-cntxt-userid
      {&action-head-code-main}
      'actn_c-documents_all':U
      {&cntxt-object}
      v-cntxt-host-code-obj
      v-cntxt-obj-type
      v-cntxt-obj-code
      0
      0
      0
      true
      varlog
    }
    if varlog <> yes then do: return no-apply. end.
    run str/calldocs.w (  input  parparentproc,
                      input  'doc':U,
                      input  buffer_trn-doc.status_,
                      input  buffer_trn-doc.doc-type,
                      input  buffer_trn-doc.flag_,
                      input  buffer_trn-doc.internal,
                      input  "":U,
                      input  buffer_trn-doc.doc-code,
                      input  paris-hold ,
                      input  recid(buffer_trn-doc),
                      input  {&table-name}.obj-type,
                      input  {&table-name}.obj-code,
                      output loc-ref-list ).
  &else
    run str/docclins.w ( input        parparentproc,
                     input        "":U,
                     input        "doc",
                     input        {&table-name}.obj-type,
                     input        {&table-name}.obj-code,
                     input        {&table-name}.doc-code,
                     input        {&table-name}.artic,
                     input        {&table-name}.prod-type,
                     input        {&table-name}.prod-code,
                     input-output loc-ref-list             ).
  &endif
    apply "ENTRY":U to {&browse-name} in frame {&frame-name}.
  end. /* do */
  &scop table-name lock-table
end procedure. /* proc-history */


&if "{1}" = "in" or "{1}" = "inv" or "{1}" = "out" &then
procedure fill-mol:
  if pardoc-mode = {&update} or pardoc-mode = {&add-def}
  then 
  do:
    find first ub.user-account no-lock where ub.user-account.user-id = v-cntxt-userid.
    if ub.user-account.psn-code <> 0 and ub.user-account.psn-code <> ?
      then 
    do:
      if t-doc.boss = ? then do:
        t-doc.boss:screen-value in frame {&frame-name} = string (ub.user-account.psn-code).
        apply "leave" to t-doc.boss in frame {&frame-name}.
      end.
      if t-doc.wrkr = ?
      then do:
        t-doc.wrkr:screen-value in frame {&frame-name} = string (ub.user-account.psn-code).
        apply "leave" to t-doc.wrkr in frame {&frame-name}.
      end.
      t-doc.agnt:screen-value in frame {&frame-name} = string (ub.user-account.psn-code).
      apply "leave" to t-doc.agnt in frame {&frame-name}.
    end.
    release ub.user-account.    
  end.
end.
&endif
/* $Workfile$   E n d */