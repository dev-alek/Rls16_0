block-level on error undo, throw.
/*

$Revision: 026c675a5513, 352, rls $
$Author: EShklyar $
$Date: Thu Dec 17 17:50:47 2015 +0300 $
$Workfile: cont-bal.p $
$Archive: utl/cont-bal.p $

Пересчет баланса ФО и платежей к договору

Автор: Кочетков Михаил Юрьевич
Дата создания: 03/27/06
Author: Michael Kochetkov
Creation date: 03/27/06

*/

define input parameter parParentProc as handle           no-undo.

/* ***************************  Definitions  ************************** */
define variable vss-revision    as character no-undo init "$Revision: 026c675a5513, 352, rls $":u .
define variable vss-author      as character no-undo init "$Author: EShklyar $":u .
define variable vss-date        as character no-undo init "$Date: Thu Dec 17 17:50:47 2015 +0300 $":u .
define variable vss-workfile    as character no-undo init "$Workfile: cont-bal.p $":u .
define variable vss-archive     as character no-undo init "$Archive: utl/cont-bal.p $":u .
define variable vss-description as character no-undo init "утилита Пересчет баланса ФО и платежей к договору" .
{ cmp/vssrevis.i }
{ cmp/str-glbl.i  }
{ cmp/library.i  }
{ gbl/cur-time.i }

{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get  }

  define variable v-choice as integer   no-undo .
  define variable doc-list as character no-undo .
  define variable v-num    as integer   no-undo .
  define variable ii as integer   no-undo .
  define variable Counter1 as integer   no-undo .

  define buffer buf_contract for contract .
  define buffer buf_clients for clients .
  define buffer buf_fin-ob for fin-ob .
  define buffer buf_fin-doc for fin-doc .

  run gbl/d-askw.w (input "Расчет баланса",
                input ("Пересчет баланса ФО и платежей к договору:"  ),
                input "|",
                input ("По договору|" +  "По контрагенту|" + "Все|" + "Выход"),
                input "|||",
                input 1,
                input 4,
                output v-choice).
  if v-choice <> 4 then do:

    os-delete 'cont-bal.log' .
    { str/writelog.i def "'cont-bal.log'"  }

    assign  Counter1 = 0 .
    { rep/repfrm.i def } /* Показать окно информации о текущем процессе */
    { rep/repfrm.i on 1 } /* Показать окно информации о текущем процессе */

    case v-choice :
      when 1 then do:
        run str/cont-all.w (input ParParentProc, input v-cntxt-host-code-obj, input "b-sel,b-mark", input {&all}, input ?,
                  input ?, input ?, input ?, input "current":u, input "all":u, input-output doc-list).
        if doc-list <> "" then do:
          assign v-num = num-entries(doc-list) .
          do ii = 1 to v-num:
            find first buf_contract no-lock where RECID(buf_contract) = int (doc-list) no-error .
            if available buf_contract then do:
              run CalcContr in this-procedure  .
            end.
          end.
        end.
      end.
      when 2 then do:
        run ref/cli-all.w ( parParentProc, "b-sel,b-mark", {&cmp}, {&all}, {&current}, ?, ",,,,,,NO,,":u, ?, output doc-list ) .
        if doc-list <> "" then do:
          assign v-num = num-entries(doc-list) .
          do ii = 1 to v-num:
            find first buf_clients no-lock where RECID(buf_clients) = integer(entry(ii, doc-list)) no-error.
            run writelog ( "cont-bal.log", 0, "Контрагент: " + buf_clients.obj-name ) .
            for each buf_contract no-lock
              where buf_contract.cli-type = buf_clients.obj-type
                and buf_contract.cli-code = buf_clients.obj-code
                and buf_contract.db-num   = v-cntxt-db-num
              :
              run CalcContr in this-procedure  .
            end.
          end.
        end.
      end.
      when 3 then do:
        for each buf_contract no-lock
          where buf_contract.db-num   = v-cntxt-db-num :
          run CalcContr in this-procedure  .
        end.
      end.
    end.
    { rep/repfrm.i off } /* Показать окно информации о текущем процессе */

    define variable g#log as logical   no-undo .
    define variable s-list as character no-undo .
    run gbl/prnfilen.w ( input  "Результат работы утилиты", input  0, input  'cont-bal.log', input 7, output s-list, output g#log ).
  end.




procedure CalcContr :
  do on error undo, return error return-value :

    assign Counter1 = Counter1 + 1.
    { rep/repfrm.i disp Counter1 }

    define variable fin-ob-sum       as decimal   no-undo .
    define variable fin-ob-sum-rubl  as decimal   no-undo .
    define variable fin-ob-sum-base  as decimal   no-undo .
    define variable fin-doc-sum      as decimal   no-undo .
    define variable fin-doc-sum-rubl as decimal   no-undo .
    define variable fin-doc-sum-base as decimal   no-undo .
    assign
      fin-ob-sum       = 0
      fin-ob-sum-rubl  = 0
      fin-ob-sum-base  = 0
      fin-doc-sum      = 0
      fin-doc-sum-rubl = 0
      fin-doc-sum-base = 0
    .

    for each buf_fin-ob no-lock
      where buf_fin-ob.host-code     = buf_contract.host-code
        and buf_fin-ob.contract-code = buf_contract.contract-code
        and buf_fin-ob.status_       = {&fact}
      :
      assign
        fin-ob-sum      = fin-ob-sum      + buf_fin-ob.sum-contract
        fin-ob-sum-rubl = fin-ob-sum-rubl + buf_fin-ob.sum-rubl
        fin-ob-sum-base = fin-ob-sum-base + buf_fin-ob.sum-base
      .
    end.
    for each buf_fin-doc no-lock
      where buf_fin-doc.host-code     = buf_contract.host-code
        and buf_fin-doc.contract-code = buf_contract.contract-code
        and buf_fin-doc.status_       = {&fin-fact}
      :
      if buf_fin-doc.fin-doc-type = {&income-cashless} or buf_fin-doc.fin-doc-type = {&income-cash} or buf_fin-doc.fin-doc-type = {&income-payoff}  then do:
        assign
          fin-doc-sum      = fin-doc-sum      + buf_fin-doc.sum-contr
          fin-doc-sum-rubl = fin-doc-sum-rubl + buf_fin-doc.sum-rubl
          fin-doc-sum-base = fin-doc-sum-base + buf_fin-doc.sum-base
        .
      end.
      else do:
        assign
          fin-doc-sum      = fin-doc-sum      - buf_fin-doc.sum-contr
          fin-doc-sum-rubl = fin-doc-sum-rubl - buf_fin-doc.sum-rubl
          fin-doc-sum-base = fin-doc-sum-base - buf_fin-doc.sum-base
        .
      end.
    end.
    if buf_contract.doc-type = {&income} then do:
      assign
        fin-doc-sum      = - fin-doc-sum
        fin-doc-sum-rubl = - fin-doc-sum-rubl
        fin-doc-sum-base = - fin-doc-sum-base
      .
    end.
/*    find current buf_contract exclusive-lock .*/
/*    assign*/
/*      buf_contract.balance-fo        = fin-ob-sum*/
/*      buf_contract.balance-plat      = fin-doc-sum*/
/*      buf_contract.balance-fo-rubl   = fin-ob-sum-rubl*/
/*      buf_contract.balance-plat-rubl = fin-doc-sum-rubl*/
/*      buf_contract.balance-fo-base   = fin-ob-sum-base*/
/*      buf_contract.balance-plat-base = fin-doc-sum-base*/
/*    .*/
    find first contract exclusive-lock where recid(contract) = recid(buf_contract) .
    assign
      contract.balance-fo        = fin-ob-sum
      contract.balance-plat      = fin-doc-sum
      contract.balance-fo-rubl   = fin-ob-sum-rubl
      contract.balance-plat-rubl = fin-doc-sum-rubl
      contract.balance-fo-base   = fin-ob-sum-base
      contract.balance-plat-base = fin-doc-sum-base
    .
    if v-choice = 3 then find first buf_clients no-lock where buf_clients.obj-type = buf_contract.cli-type and buf_clients.obj-code = buf_contract.cli-code  no-error.
    if available buf_clients then run writelog ( "cont-bal.log", 0, string("Контрагент: " + buf_clients.obj-type + string(buf_clients.obj-code) + " Договор (вн. №): " + string(buf_contract.contract-code) + " Баланс ФО: " + string(contract.balance-fo) + " Баланс плат.: " + string(contract.balance-plat)) ) .
  end.
end procedure. /* CalcContr */