block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: gen-flsp.p $
$Archive: str/gen-flsp.p $

Процедура генерации Фин Об по заданным параметрам по спецификациям

Автор: Чернова Светлана Александровна
Дата создания: 12/08/05
Author: Svetlana Chernova
Creation date: 12/08/05

*/

define input  parameter parparentproc  as widget-handle no-undo.
define input  parameter par-host-code  like ub.clients.obj-code no-undo.
define input  parameter p-date-end     as date no-undo    .
define input  parameter p-type-date    as integer   no-undo .
define input  parameter p-rid-list     as character no-undo .
define input-output parameter p-res    as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: gen-flsp.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/gen-flsp.p $":U .
define variable vss-description as character no-undo init "Процедура генерации Фин Об по заданным параметрам по спецификациям".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i }

define variable g#db-num as integer   no-undo .
run get-db-num  in parParentProc ( output g#db-num ).
define variable g#userid as character no-undo .
run get-userid  in parParentProc ( output g#userid ).
/*{ cmp/trg-def.i  }*/
{ gbl/waitfram.i }
{ gbl/cur-time.i }
{ str/crfinob.i  fin-ob }
{ str/libofarh.i }
{ str/fo-clos.i  }
{ str/clcprtsl.i }
{ gbl/getcntxt.i def }
{ gbl/thbjattr.i }
{ str/cont-ms-def.i }


define temp-table temp_fin-gds-part no-undo like ub.fin-gds-part .
define buffer buf_sysconf for ub.sysconf  .
define variable v-mess as character no-undo .
find first buf_sysconf no-lock where
           buf_sysconf.host-code = par-host-code and
           buf_sysconf.fin-calc  = 1  /* по объекту */
           no-error .

if available buf_sysconf then do:
    v-mess = substitute("--<< На фирме &1 включен учет ФО по объектам, формировать ФО по спецификации запрещено!" ,  par-host-code ) .
    p-res =  p-res + v-mess .
   return v-mess .
end.

do on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)) :

  define variable g-log as logical no-undo .
  define variable vari as integer   no-undo .
  define variable col-trn as integer   no-undo .
  define variable col-fo as integer   no-undo .

  define variable p-ri       as recid   no-undo .
  define variable p-doc-code as character no-undo .
  define variable n-doc-date             like         ub.fin-ob.doc-date         no-undo .
  define variable n-doc-type             like         ub.fin-ob.doc-type         no-undo .
  define variable n-payer-name           like         ub.fin-ob.payer-name       no-undo .
  define variable n-receiver-name        like         ub.fin-ob.receiver-name    no-undo .
  define variable n-curr-code            like         ub.fin-ob.curr-code        no-undo .
  define variable n-sum-doc              like         ub.fin-ob.sum-doc          no-undo .
  define variable n-user-db-num-doc      like         ub.fin-ob.user-db-num-doc  no-undo .
  define variable n-user-name-doc        like         ub.fin-ob.user-name-doc    no-undo .
  define variable n-base-rate            like         ub.fin-ob.base-rate        no-undo .
  define variable n-base-scale           like         ub.fin-ob.base-scale       no-undo .
  define variable n-receiver-code        like         ub.fin-ob.receiver-code    no-undo .
  define variable n-receiver-type        like         ub.fin-ob.receiver-type    no-undo .
  define variable n-contract-code        like         ub.fin-ob.contract-code    no-undo .
  define variable n-exch-rate            like         ub.fin-ob.exch-rate        no-undo .
  define variable n-exch-scale           like         ub.fin-ob.exch-scale       no-undo .
  define variable n-contract-curr        like         ub.fin-ob.contract-curr    no-undo .
  define variable n-contract-rate        like         ub.fin-ob.contract-rate    no-undo .
  define variable n-contract-scale       like         ub.fin-ob.contract-scale   no-undo .
  define variable n-fact-date            like         ub.fin-ob.fact-date        no-undo .
  define variable n-fact-order           like         ub.fin-ob.fact-order       no-undo .
  define variable n-payer-code           like         ub.fin-ob.payer-code       no-undo .
  define variable n-payer-type           like         ub.fin-ob.payer-type       no-undo .
  define variable n-pay-date             like         ub.fin-ob.pay-date         no-undo .
  define variable n-prn-doc-code         like         ub.fin-ob.prn-doc-code     no-undo .
  define variable n-sum-base-orig        like         ub.fin-ob.sum-base-orig    no-undo .
  define variable n-sum-base             like         ub.fin-ob.sum-base         no-undo .
  define variable n-sum-doc-orig         like         ub.fin-ob.sum-doc-orig     no-undo .
  define variable n-sum-rubl-orig        like         ub.fin-ob.sum-rubl-orig    no-undo .
  define variable n-sum-rubl             like         ub.fin-ob.sum-rubl         no-undo .
  define variable n-sum-contract         like         ub.fin-ob.sum-contract     no-undo .
  define variable n-trn-doc-code         like         ub.fin-ob.trn-doc-code     no-undo .
  define variable n-trn-doc-code-orig    like         ub.fin-ob.trn-doc-code     no-undo .
  define variable n-user-db-num-fact     like         ub.fin-ob.user-db-num-fact no-undo .
  define variable n-user-db-num-pay      like         ub.fin-ob.user-db-num-pay  no-undo .
  define variable n-user-name-fact       like         ub.fin-ob.user-name-fact   no-undo .
  define variable n-user-name-pay        like         ub.fin-ob.user-name-pay    no-undo .
  define variable n-in-type              like         ub.fin-ob.in-type          no-undo .
  define variable n-sum-tax-base         like         ub.fin-ob.sum-tax-base     no-undo .
  define variable n-sum-tax-doc          like         ub.fin-ob.sum-tax-doc      no-undo .
  define variable n-sum-tax-rubl         like         ub.fin-ob.sum-tax-rubl     no-undo .
  define variable n-sum-tax-contract     like         ub.fin-ob.sum-tax-contract no-undo .
  define variable n-obj-code             like         ub.fin-ob.obj-code       no-undo .
  define variable n-obj-type             like         ub.fin-ob.obj-type       no-undo .
  define variable n-abbr-doc as character no-undo .

  define variable Temp1         as integer init 10 no-undo .

  { gbl/getcntxt.i get }
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_fin-liability_add-def':U
    {&cntxt-firm}
    par-host-code
    '':U
    0
    0
    0
    0
    true
    g-log
  }
  if not g-log then  return .

  define buffer buf_contract for ub.contract .
  define buffer buf2_contract for ub.contract .
  define buffer buf_contract-specif for ub.contract-specif .
  define buffer buf_fin-ob-trn for ub.fin-ob-trn.

  { gbl/baserate.i  par-host-code  today  n-base-rate  n-base-scale   }

  run waitfram-show("Ждите...").

  if p-type-date > 0 then do:
    for each buf_contract no-lock
      where buf_contract.host-code  = par-host-code
        and buf_contract.status_    = {&current-contr}
        and buf_contract.need-fo    = 1
        and buf_contract.cr-fo      = false
      :
/*
      find first buf_contract-specif no-lock where
                 buf_contract-specif.host-code = par-host-code
             and buf_contract-specif.contract-num  = buf_contract.contract-code
           no-error .
*/
      {str/cont-slave-inc.i
           &FIND_FIRST = YES
           &BUFFER_SPECIF    = buf_contract-specif
           &P_HOST_CODE      = par-host-code
           &P_CONTRACT_NUM   = buf_contract.contract-code
           &NO_LOCK=YES
           &NO_ERROR=YES
      }
      if not available buf_contract-specif then next.
      run proc-body .
    end.
  end.
  else do:
    do vari = 1 to num-entries (p-rid-list):
      find first buf_contract where recid(buf_contract) = integer(entry (vari, p-rid-list)) no-lock.
      if buf_contract.status_ <> {&current-contr} then do:
        message "Договор " buf_contract.contract-prn-code " статус " buf_contract.status_ " не в статусе " {&current-contr} " . Пропускаем." view-as alert-box.
        next .
      end.
/*
      find first buf_contract-specif no-lock where
                 buf_contract-specif.host-code = par-host-code
             and buf_contract-specif.contract-num  = buf_contract.contract-code
           no-error .
*/
      {str/cont-slave-inc.i
           &FIND_FIRST = YES
           &BUFFER_SPECIF    = buf_contract-specif
           &P_HOST_CODE      = par-host-code
           &P_CONTRACT_NUM   = buf_contract.contract-code
           &NO_LOCK=YES
           &NO_ERROR=YES
      }

      if not available buf_contract-specif then do:
        message "У договора " buf_contract.contract-prn-code " нет спецификации. Пропускаем." view-as alert-box.
        next.
      end.
      if buf_contract.cr-fo = yes then do:
        message "По договору " buf_contract.contract-prn-code " уже создавалось ФО от " buf_contract.fo-date " числа. Пропускаем." view-as alert-box.
        next.
      end.
      run proc-body .
    end.
  end.
  p-res = p-res  + {&new-line}   +  {&new-line}   +
       "Генерация завершена: " + cur-time-string()  + {&new-line} +
       if p-type-date > 0 then string("за период до " + string( p-date-end,"99/99/9999")  + {&new-line}) else "" +
       " Создано финансовых обязательств :" + string(col-fo) + {&new-line} +
       "Просмотрено договоров            :" + string(col-trn)
       .

end.


procedure proc-body :
  do on error undo, return error return-value :

    col-trn = col-trn + 1 .

    define variable var-sum-rubl     as decimal   no-undo .
    define variable var-sum-base     as decimal   no-undo .
    define variable var-sum-contract as decimal   no-undo .
    define variable col-part         as integer   no-undo .

    { gbl/exchrate.i  buf_contract.curr-code  today  n-exch-rate  n-exch-scale  n-abbr-doc }

    if ( col-trn  modulo temp1 = 0 ) and ( col-trn >= temp1 ) then run waitfram-show( "Обработано договоров : " + string( col-trn )) .

    for each temp_fin-gds-part :
      delete temp_fin-gds-part .
    end.

/*
    for each buf_contract-specif no-lock where
             buf_contract-specif.host-code     = par-host-code
         and buf_contract-specif.contract-num  = buf_contract.contract-code :
*/
    {str/cont-slave-inc.i
         &FOR_ = YES
         &EACH_ = YES
         &BUFFER_SPECIF   = buf_contract-specif
         &P_HOST_CODE     = par-host-code
         &P_CONTRACT_NUM  = buf_contract.contract-code
         &NO_LOCK=YES
    }


/*      find first goods no-lock where goods.gds-code = buf_contract-specif.gds-code .*/

      col-part = col-part + 1.
      if ( col-part  modulo temp1 = 0 ) and ( col-part >= temp1 ) then run waitfram-show( "Создано партий : " + string( col-part )) .

      create temp_fin-gds-part .
      assign
        temp_fin-gds-part.host-code          = par-host-code
        temp_fin-gds-part.fin-ob-code        = " "   /* !!!!!!!!!!!!!!! */
        temp_fin-gds-part.obj-type           = v-cntxt-obj-type
        temp_fin-gds-part.obj-code           = v-cntxt-obj-code
        temp_fin-gds-part.gds-code           = buf_contract-specif.gds-code
        temp_fin-gds-part.in-code            = string(buf_contract.contract-code)
        temp_fin-gds-part.out-code           = string(buf_contract.contract-code)
        temp_fin-gds-part.part-code          = " "
        temp_fin-gds-part.doc-qnty           = buf_contract-specif.qnty * buf_contract-specif.cli-base-rate
        temp_fin-gds-part.fact-qnty          = buf_contract-specif.qnty * buf_contract-specif.cli-base-rate
        temp_fin-gds-part.status_dop         = {&fin-gen}
        temp_fin-gds-part.user-db-num        = g#db-num
        temp_fin-gds-part.user-name          = g#userid
        temp_fin-gds-part.base-rate          = n-base-rate
        temp_fin-gds-part.base-scale         = n-base-scale
        temp_fin-gds-part.vat-pc             = buf_contract-specif.VAT-pc
        temp_fin-gds-part.vat-type           = {&inc-VAT}
        temp_fin-gds-part.sum-contract       = buf_contract-specif.sum-cli
        temp_fin-gds-part.sum-rubl           = buf_contract-specif.sum-cli * n-exch-rate  / n-exch-scale
        temp_fin-gds-part.sum-base           = temp_fin-gds-part.sum-rubl  * n-base-scale / n-base-rate
        .
      assign
        temp_fin-gds-part.vat-contract       = if temp_fin-gds-part.vat-type = {&inc-VAT} then temp_fin-gds-part.vat-PC * ( temp_fin-gds-part.sum-contract  / ( 100 + temp_fin-gds-part.vat-PC))  else temp_fin-gds-part.sum-contract * temp_fin-gds-part.vat-pc / 100
        temp_fin-gds-part.vat-rubl           = if temp_fin-gds-part.vat-type = {&inc-VAT} then temp_fin-gds-part.vat-PC * ( temp_fin-gds-part.sum-rubl      / ( 100 + temp_fin-gds-part.vat-PC))  else temp_fin-gds-part.sum-rubl     * temp_fin-gds-part.vat-pc / 100
        temp_fin-gds-part.vat-base           = if temp_fin-gds-part.vat-type = {&inc-VAT} then temp_fin-gds-part.vat-PC * ( temp_fin-gds-part.sum-base      / ( 100 + temp_fin-gds-part.vat-PC))  else temp_fin-gds-part.sum-base     * temp_fin-gds-part.vat-pc / 100
        temp_fin-gds-part.vat-contract-orig  = temp_fin-gds-part.vat-contract
        temp_fin-gds-part.vat-rubl-orig      = temp_fin-gds-part.vat-rubl
        temp_fin-gds-part.vat-base-orig      = temp_fin-gds-part.vat-base
      .
      if ( temp_fin-gds-part.doc-qnty = ?     ) then assign temp_fin-gds-part.doc-qnty      = 0 .
      if ( temp_fin-gds-part.fact-qnty = ?    ) then assign temp_fin-gds-part.fact-qnty     = 0 .
      if ( temp_fin-gds-part.sum-rubl = ?     ) then assign temp_fin-gds-part.sum-rubl      = 0 .
      if ( temp_fin-gds-part.sum-contract = ? ) then assign temp_fin-gds-part.sum-contract  = 0 .
      if ( temp_fin-gds-part.sum-base = ?     ) then assign temp_fin-gds-part.sum-base      = 0 .
      assign
        temp_fin-gds-part.sum-contract-orig  = temp_fin-gds-part.sum-contract
        temp_fin-gds-part.sum-rubl-orig      = temp_fin-gds-part.sum-rubl
        temp_fin-gds-part.sum-base-orig      = temp_fin-gds-part.sum-base
        var-sum-rubl     = var-sum-rubl     +  temp_fin-gds-part.sum-rubl
        var-sum-contract = var-sum-contract +  temp_fin-gds-part.sum-contract
        var-sum-base     = var-sum-base     +  temp_fin-gds-part.sum-base
      .
    end.
    run make-fo ( input var-sum-rubl, input var-sum-base, input var-sum-contract ) no-error .
    if error-status :error then  do:
      col-fo = col-fo - 1.
      p-res = p-res + {&new-line} + error-status :get-message(1) .
    end.
  end. /* do */
end procedure. /* proc-body */


procedure make-fo :
 do
 on error undo, return error return-value
 :
  define input parameter v-sum-rubl     as decimal no-undo .
  define input parameter v-sum-base     as decimal no-undo .
  define input parameter v-sum-contract as decimal no-undo .

  define variable v-date-pay as date      no-undo .

  if buf_contract.usl-opl = {&contr-pay-spec} then v-date-pay = today  .
  else v-date-pay  = today + (if buf_contract.srok-opl <> ? then buf_contract.srok-opl else 0 ) .

  /*  формируем расходные ФО */
  assign
    n-doc-type            = {&expense}
    n-curr-code           = buf_contract.curr-code
    n-receiver-code       = buf_contract.cli-code
    n-receiver-type       = buf_contract.cli-type
    n-receiver-name       = buf_contract.cli-name
    n-payer-code          = par-host-code
    n-payer-type          = {&cmp}
    n-payer-name          = buf_contract.own-name
    n-trn-doc-code        = string(buf_contract.contract-code)
    n-user-db-num-doc     = g#db-num
    n-user-name-doc       = g#userid
    n-contract-code       = buf_contract.contract-code
    n-contract-curr       = n-curr-code
    n-contract-rate       = n-exch-rate
    n-contract-scale      = n-exch-scale
    n-pay-date            = v-date-pay

    n-sum-rubl-orig       = v-sum-rubl
    n-sum-base-orig       = v-sum-base
    n-sum-contract        = v-sum-contract

    n-sum-base            = n-sum-base-orig
    n-sum-doc-orig        = n-sum-contract
    n-sum-doc             = n-sum-contract
    n-sum-rubl            = n-sum-rubl-orig

    n-in-type             = 0
    n-sum-tax-base        = 0
    n-sum-tax-doc         = 0
    n-sum-tax-rubl        = 0
    n-sum-tax-contract    = 0
    n-doc-date            = if p-type-date < 2 then  date(cur-time-date()) else p-date-end
 .

  run fin-ob-code (input g#db-num , output p-doc-code) .
  run create-fin-liab (
    input  yes                  ,
    input  p-doc-code           ,
    input  n-doc-date           ,
    input  n-doc-type           ,
    input  n-payer-name         ,
    input  n-receiver-name      ,
    input  n-curr-code         ,
    input  n-sum-doc           ,
    input  n-user-db-num-doc   ,
    input  n-user-name-doc     ,
    input  n-base-rate         ,
    input  n-base-scale        ,
    input  n-receiver-code     ,
    input  n-receiver-type     ,
    input  n-contract-code     ,
    input  n-exch-rate         ,
    input  n-exch-scale        ,
    input  n-contract-curr     ,
    input  n-contract-rate     ,
    input  n-contract-scale    ,
    input  n-fact-date         ,
    input  n-fact-order        ,
    input  par-host-code       ,
    input  n-payer-code        ,
    input  n-payer-type        ,
    input  n-pay-date          ,
    input  string(p-doc-code)  ,
    input  {&fin-gen}          ,
    input  n-sum-base-orig     ,
    input  n-sum-base          ,
    input  n-sum-doc-orig      ,
    input  n-sum-rubl-orig     ,
    input  n-sum-rubl          ,
    input  n-sum-contract      ,
    input  n-trn-doc-code      ,
    input  n-user-db-num-fact  ,
    input  n-user-db-num-pay   ,
    input  n-user-name-fact    ,
    input  n-user-name-pay     ,
    input  n-in-type           ,
    input  n-sum-tax-base      ,
    input  n-sum-tax-doc       ,
    input  n-sum-tax-rubl      ,
    input  n-sum-tax-contract  ,
    input  ""                  ,
    output p-ri )
    no-error .
    if error-status :error then
      message  vss-workfile vss-revision vss-description skip
               error-status :get-message(1) skip   return-value skip "-6"
      view-as alert-box error .

    col-fo = col-fo + 1.
    find first buf_fin-ob-trn no-lock
      where buf_fin-ob-trn.doc-code       = p-doc-code
        and buf_fin-ob-trn.host-code      = par-host-code
        and buf_fin-ob-trn.doc-type       = "spc"
        and buf_fin-ob-trn.trn-doc-code   = string(buf_contract.contract-code)
    no-error .
    if not available  buf_fin-ob-trn then  do :
      create buf_fin-ob-trn.
      assign
        buf_fin-ob-trn.doc-code       = p-doc-code
        buf_fin-ob-trn.host-code      = par-host-code
        buf_fin-ob-trn.doc-type       = "spc"
        buf_fin-ob-trn.sum-rubl       = n-sum-rubl
        buf_fin-ob-trn.trn-doc-code   = string(buf_contract.contract-code)
      .
    end.

    find first buf2_contract  exclusive-lock
      where buf2_contract.contract-code = buf_contract.contract-code
        and buf2_contract.host-code     = buf_contract.host-code
    no-error .
    if available buf2_contract then do:
     assign
        buf2_contract.cr-fo        = true
        buf2_contract.fo-date      = today
      .
    end.

    for each temp_fin-gds-part :
      create ub.fin-gds-part .
      assign  ub.fin-gds-part.fin-ob-code = p-doc-code  .
      buffer-copy temp_fin-gds-part EXCEPT fin-ob-code to ub.fin-gds-part .
      assign  ub.fin-gds-part.doc-type  = n-doc-type .
    end.

    /* создадим налоги по партиям */
    run make-tax ( input p-doc-code , input par-host-code ) .

    run update-fin-ob_obj ( input p-doc-code , input par-host-code) .

    /* если есть в договоре условие то закроем на факт */
    run close-fo-fact ( input par-host-code, input p-doc-code ) no-error   .
    if error-status :error then  p-res = p-res + {&new-line} + " Ошибка при закрытии на факт ФО " + return-value  + error-status :get-message(1) .

/*    define variable v-list as character no-undo.*/
/*    run str/gen-scf.p ( input parParentProc, input p-doc-code, input "fin-ob", output v-list) no-error .*/
/*    if error-status:error then  message "Ошибка создания счета-фактуры по ФО по спецификации к договору"  buf_contract.contract-prn-code return-value view-as alert-box.*/
  end. /* do */
end procedure. /* make-fo */



procedure close-fo-fact :
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :
define input parameter p-host-code as integer no-undo .
define input parameter p-doc-code  as character no-undo .
define buffer buf_fact-fin-ob   for ub.fin-ob .
define buffer buf_fact-contract for ub.contract .


find first buf_fact-fin-ob  no-lock where buf_fact-fin-ob.host-code = p-host-code and
                                          buf_fact-fin-ob.doc-code  = p-doc-code no-error .
                                          if error-status :error then
                                          do:
                                          return  error .
                                          end.

  find first buf_fact-contract no-lock where  buf_fact-contract.host-code = buf_fact-fin-ob.host-code and
                                              buf_fact-contract.contract-code = buf_fact-fin-ob.contract-code no-error .
                                              if error-status :error then
                                              do:
                                              return  error .
                                              end.


  if buf_fact-contract.auto-pay  > 0 then do:
      run proc-close-one-fin-ob (recid(buf_fact-fin-ob)) no-error .
      if error-status :error then do:
         message vss-workfile vss-revision vss-description skip
                "№ ФО :" buf_fact-fin-ob.doc-code skip
                "№ фирмы :" buf_fact-fin-ob.host-code skip
                "Вн.№ договора :" buf_fact-fin-ob.contract-code skip
                "Ошибка закрытия на факт ФО на ПН " skip
                 skip
                 error-status :get-message(1) skip
                 return-value skip
                 view-as alert-box error
         .
         return error .
      end.

      if buf_fact-contract.auto-pay > 1 then do:
         run str/payfoavt.p ( input parParentProc, input par-host-code, input recid(buf_fact-fin-ob)) no-error .
         if error-status :error then do:
            message vss-workfile vss-revision vss-description skip
                    "№ ФО :" buf_fact-fin-ob.doc-code skip
                    "№ фирмы :" buf_fact-fin-ob.host-code skip
                    "Вн.№ договора :" buf_fact-fin-ob.contract-code skip
                    "Ошибка автоматического создания платежа . Вернула процедура  payfoavt.p " skip
                    skip
                    error-status :get-message(1) skip
                    return-value skip
                    view-as alert-box error
            .
            return error .
         end.
      end.
  end.
 end. /* do */
end procedure. /* close-fo-fact */