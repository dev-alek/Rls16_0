block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: ora-i401.p $
$Archive: utl/ora-i401.p $

Импорт Заказа из временной таблицы

Автор: Чернова Светлана Александровна
Дата создания: 01/28/09
Author: Svetlana Chernova
Creation date: 01/28/09

*/
{ utl/tt401.i    }

define input  parameter parparentproc as widget-handle no-undo .
define input  parameter p-log-handle  as handle no-undo .
define input  PARAMETER TABLE FOR  temp_ord-doc.
define input  PARAMETER TABLE FOR  temp_ord-line.
define output parameter p-ok-doc as integer   no-undo .


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: ora-i401.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/ora-i401.p $":U .
define variable vss-description as character no-undo init "Импорт Заказа из временной таблицы".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ str/lib-trn.i  }
{ gbl/getcntxt.i def }
{ cus/ord-code.i def }
{ cmp/df-sub.i   }
{ utl/ora-icli.i }
{ gbl/orapreps.i }
{ gbl/getsect.i def }

/*
create temp_ord-doc.
assign
 temp_ord-doc.doc-code         = 'ora'
 temp_ord-doc.doc-date         =  today
 temp_ord-doc.ext-doc-type     =  'oo'
 temp_ord-doc.cli-type         =  'орг'
 temp_ord-doc.cli-code         =  4545
 temp_ord-doc.obj-type         =  'маг'
 temp_ord-doc.obj-code         =   20
 temp_ord-doc.wrkr             =   5
 temp_ord-doc.agnt             =   5
 temp_ord-doc.boss             =   5
 temp_ord-doc.creid            =  '0-55'
 temp_ord-doc.ps               =  'rere'
 temp_ord-doc.host-code        =  1
 temp_ord-doc.contract-code    =  644
 .

create temp_ord-line.
assign
 temp_ord-line.doc-code     = 'ora'
 temp_ord-line.artic        = "zxczxc"
 temp_ord-line.prod-type    = 'орг'
 temp_ord-line.prod-code    =  4
 temp_ord-line.fact-qnty    =  1
 temp_ord-line.price-rubl   =  101
 temp_ord-line.vat-pc       = 32.5
 .
create temp_ord-line.
assign
 temp_ord-line.doc-code     = 'ora'
 temp_ord-line.artic        = 'zxzx'
 temp_ord-line.prod-type    = 'орг'
 temp_ord-line.prod-code    =  4
 temp_ord-line.fact-qnty    =  1
 temp_ord-line.price-rubl   =  133
 temp_ord-line.vat-pc       =  32.5
 .
*/

define variable v-base-rate  as decimal   no-undo .
define variable v-base-scale as decimal   no-undo .
define variable v-out-pay    as integer   no-undo .
define buffer   buf_clients  for ub.clients.
define buffer   buf_goods    for ub.goods  .
define variable v-i-doc      as character no-undo .
define variable v-doc-code   as character no-undo .
define variable k as integer   no-undo .
define variable v-end-message as character no-undo .
define variable v-host-code as integer   no-undo .
define buffer buf_contract for ub.contract  .
define buffer bufo_clients for ub.clients  .
define variable v-specif as logical   no-undo .
define variable v-typevat as character no-undo .
define variable vv-kol      as decimal   no-undo .
define variable vv-kolcli   as decimal   no-undo .
define variable vv-sumkolr  as decimal   no-undo .
define variable vv-sumkolv  as decimal   no-undo .
define variable vv-sumkolc  as decimal   no-undo .





MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

   for each  temp_ord-doc :
       for each temp_ord-line where
                temp_ord-line.line-num = temp_ord-doc.line-num :
           if temp_ord-line.doc-code <> temp_ord-doc.doc-code then do:
              assign
                  v-end-message =  substitute("Не верно указан doc-num &1 &2  товар &3" ,
                  temp_ord-line.doc-code ,
                  temp_ord-doc.doc-code ,
                  temp_ord-line.gds-code
                  ).
              run pcall-log-file in p-log-handle (input v-end-message) .
              undo, return error v-end-message.
           end.
       end.
   end.

run get-db-num in parparentproc ( output v-cntxt-db-num ) .
run get-userid in parparentproc ( output v-cntxt-userid ) .
p-ok-doc = 0 .
   _temp-ord-doc:
   for each temp_ord-doc
   :

   k = 0 .
  case temp_ord-doc.status_ :
  when {&ora-line-create}
  or
  when {&ora-line-update}
  or
  when {&ora-line-delete} then do:
    if temp_ord-doc.status_ = {&ora-line-delete} then do:
      find first ub.ord-doc exclusive-lock where
                 ub.ord-doc.doc-code =  trim(temp_ord-doc.corr-doc-code) no-error .
      if error-status :error then do:
      v-end-message =  substitute(" Заказ: &1 не найден " ,
                                    temp_ord-doc.corr-doc-code
                                    ).
      run pcall-log-file in p-log-handle (input v-end-message) .
      undo, return error v-end-message.
      end.
      assign
        ub.ord-doc.fact-date  = today
        ub.ord-doc.fact-order = decimal(today)
        ub.ord-doc.status_    = {&ord-rejection}
        ub.ord-doc.cons-code  = ""
        temp_ord-doc.pay-code = ub.ord-doc.pay-code
        .
      ub.ord-doc.ps = "ОТКАЗ из внешней ситемы " + ub.ord-doc.ps + " №:" + temp_ord-doc.doc-code +
                    " от " + string ( temp_ord-doc.doc-date , "99/99/9999") .

      v-end-message =  substitute(" ОТКАЗ &3&4 Заказ: &1  товаров: &2" ,
                                    temp_ord-doc.doc-code    ,
                                    k ,
                                    temp_ord-doc.obj-type ,
                                    temp_ord-doc.obj-code
                                    ).
      run pcall-log-file in p-log-handle (input v-end-message) .
      /*утверждается, что не надо проверять есть ли строки - потому строки всегда есть иначе ругается схема - там min-occurs на ord-line = 1*/
      next _temp-ord-doc.
       /* Проверка на заказ без строк */
       /* НЕДОСТИЖИМЫЙ КОД */
       /*
      find first temp_ord-line where
                 temp_ord-line.doc-code = temp_ord-doc.doc-code no-error .
      if not available  temp_ord-line then do:
        v-end-message =  substitute("Новый заказ не прилагается "  ).
        run pcall-log-file in p-log-handle (input v-end-message) .
        next.
      end.
      */
  end.
  else do /* U или N */:
     if temp_ord-doc.corr-doc-code <> "" then do:
      find first ub.ord-doc exclusive-lock where
                 ub.ord-doc.doc-code =  trim(temp_ord-doc.corr-doc-code) no-error .
      if error-status :error then do:
      v-end-message =  substitute(" Заказ: &1 не найден " ,
                                    temp_ord-doc.corr-doc-code
                                    ).
      run pcall-log-file in p-log-handle (input v-end-message) .
      undo, return error v-end-message.
      end.
      assign
        ub.ord-doc.fact-date  = today
        ub.ord-doc.fact-order = decimal(today)
        ub.ord-doc.status_    = {&fact}
        ub.ord-doc.cons-code  = ""
        temp_ord-doc.pay-code = ub.ord-doc.pay-code
        .
      v-end-message = "Закрыт заказом из внешней ситемы  №:" + temp_ord-doc.doc-code +
                    " от " + string ( temp_ord-doc.doc-date , "99/99/9999") .

      ub.ord-doc.ps = v-end-message.

      run pcall-log-file in p-log-handle (input v-end-message) .
    end.
    else do:
      v-end-message = "Заказ от внешней системы  №:" + temp_ord-doc.doc-code +
                    " от " + string ( temp_ord-doc.doc-date , "99/99/9999") + " Пришел без ссылки на заказ ТН." .
      run pcall-log-file in p-log-handle (input v-end-message) .
    end.
  end.
  find first bufo_clients no-lock where
             bufo_clients.obj-type  = temp_ord-doc.obj-type  and
             bufo_clients.obj-code  = temp_ord-doc.obj-code  no-error .

      if error-status :error then do:
              assign
              v-end-message =  substitute(" Не найден объект &1 &2 &3 &4" , temp_ord-doc.obj-type , temp_ord-doc.obj-code , error-status :get-message(1) , return-value )
              .
              run pcall-log-file in p-log-handle (input v-end-message) .
              undo, return error v-end-message.
      end.

    { gbl/hostcode.i
      temp_ord-doc.obj-type
      temp_ord-doc.obj-code
      v-host-code
      no-error }
      if error-status :error then do:
        assign
            v-end-message =  substitute("Не верно указан объект &1 &2 " ,
            temp_ord-doc.obj-type ,
            temp_ord-doc.obj-code ).

        run pcall-log-file in p-log-handle (input v-end-message) .
        undo, return error v-end-message.

      end.

      temp_ord-doc.host-code = v-host-code .
    find first buf_contract no-lock where
               buf_contract.contract-code =  temp_ord-doc.cli-code and
               buf_contract.host-code     =  temp_ord-doc.host-code no-error .
   if not available  buf_contract then do:
      temp_ord-doc.contract-code =  0.
   end.
   else do:
      temp_ord-doc.contract-code =  buf_contract.contract-code .
   end.

      v-specif = false .
      { gbl/getsect.i run temp_ord-doc.obj-type temp_ord-doc.obj-code {&attr-nakl_par} }

      for each thbjattr_thbj-attr :
        if thbjattr_thbj-attr.prop-code = 'type-vat' then v-value-integer = thbjattr_thbj-attr.property-value-integer.
      end.
          case v-value-integer:
          when 1 or when ? then do:
            assign
              v-typevat = {&inc-vat}.
          end.
          when 2 then do:
            assign
              v-typevat = {&no-vat}.
          end.
          when 3 then do:
            assign
              v-typevat = {&without-vat}.
          end.
          otherwise do:
              v-end-message =  substitute(" Не верно задан атрибут 'Тип заведения НДС' (type-vat). &1 &2 &3 &4 &5" , temp_ord-doc.obj-type , temp_ord-doc.obj-code , error-status :get-message(1) , return-value , v-value-integer ) .
              run pcall-log-file in p-log-handle (input v-end-message) .
              undo, return error v-end-message.
          end.
          end case.


   if temp_ord-doc.contract-code  > 0 then do:
     find first  ub.contract-specif no-lock where
      ub.contract-specif.contract-num = temp_ord-doc.contract-code and
      ub.contract-specif.host-code    = temp_ord-doc.host-code  no-error .
      if available ub.contract-specif then
         assign
           v-typevat  = ub.contract-specif.VAT-type
           v-specif = true .
         .

   end.

   if buf_contract.curr-code <> temp_ord-doc.exch-code then do:
                v-end-message =  substitute("По договору &3   ожидалась валюта &1  пришла &2 " ,
                buf_contract.curr-code,
                temp_ord-doc.exch-code,
                temp_ord-doc.contract-code ) .
                run pcall-log-file in p-log-handle (input v-end-message) .
                undo, return error v-end-message.
   end.

      run who-cli-ora in this-procedure (
          input  temp_ord-doc.cli-code ,
          output temp_ord-doc.cli-type ,
          output temp_ord-doc.cli-code
          ) no-error .
          if error-status :error then return error return-value .

      v-cntxt-obj-code      =  temp_ord-doc.obj-code .
      v-cntxt-obj-type      =  temp_ord-doc.obj-type .
      v-cntxt-host-code-obj =  v-host-code .


  { cus/ord-code.i
      'main'
      v-cntxt-db-num
      temp_ord-doc.obj-type
      temp_ord-doc.obj-code
      v-i-doc
      v-doc-code
      }

  { gbl/curobjdt.i
      temp_ord-doc.obj-type
      temp_ord-doc.obj-code
      to-day
      }
  { gbl/baserate.i
      v-host-code
      to-day
      v-base-rate
      v-base-scale
      }

  define buffer buf_sysconf for ub.sysconf  .
  find first buf_sysconf no-lock where buf_sysconf.host-code = v-host-code .
   if temp_ord-doc.pay-code = 0 then do:
   v-out-pay = buf_sysconf.out-pay.
   temp_ord-doc.pay-code = v-out-pay .
   end.
   else do:
      v-out-pay = temp_ord-doc.pay-code .
   end.

  if temp_ord-doc.exch-code = ? then do:
      assign
        temp_ord-doc.exch-code = 0
        temp_ord-doc.exch-rate  = 1
        temp_ord-doc.exch-scale = 1
      .
      v-end-message =  substitute("Предупреждение !!! Не верно введена валюта ПОСТАВЩИКА код &1 , меняю на национальную " ,              temp_ord-doc.exch-code   ) .
      run pcall-log-file in p-log-handle (input v-end-message) .

  end.

  if temp_ord-doc.exch-code = 0 then do:
      assign
        temp_ord-doc.exch-code = 0
        temp_ord-doc.exch-rate  = 1
        temp_ord-doc.exch-scale = 1
      .
  end.

  if temp_ord-doc.exch-rate  = 0 or
        temp_ord-doc.exch-rate  = ? then do:
          assign
            temp_ord-doc.exch-code = 0
            temp_ord-doc.exch-rate  = 1
            temp_ord-doc.exch-scale = 1
          .
      v-end-message =  substitute("Предупреждение !!! Не верно введен курс = &2 валюты ПОСТВЩИКА код &1 , меняю на национальную " ,              temp_ord-doc.exch-code , temp_ord-doc.exch-rate ) .
      run pcall-log-file in p-log-handle (input v-end-message) .

  end.
  if temp_ord-doc.exch-scale  = 0 or
        temp_ord-doc.exch-scale  = ? then do:
          assign
            temp_ord-doc.exch-code = 0
            temp_ord-doc.exch-rate  = 1
            temp_ord-doc.exch-scale = 1
          .
      v-end-message =  substitute("Предупреждение !!! Не верно введен масштаб = &2 валюты ПОСТВЩИКА код &1 , меняю на национальную " ,              temp_ord-doc.exch-code , temp_ord-doc.exch-scale ) .
      run pcall-log-file in p-log-handle (input v-end-message) .

  end.

    find first ub.currency where ub.currency.curr-code = temp_ord-doc.exch-code no-error .
    if error-status :error then do:
              v-end-message =  substitute("Нет валюты с кодом &1  (&2)" ,
              temp_ord-doc.exch-code , error-status :get-message(1)   ) .
            run pcall-log-file in p-log-handle (input v-end-message) .
            undo, return error v-end-message.
        end.

       k = 0 .
       vv-kol       = 0 .
       vv-kolcli    = 0 .
       vv-sumkolr   = 0 .
       vv-sumkolv   = 0 .
       vv-sumkolc   = 0 .
       for each temp_ord-line where
                temp_ord-line.doc-code = temp_ord-doc.doc-code
       :
            run ora-ver-goods ( temp_ord-line.gds-code )  no-error .
              if error-status :error then do:
                  v-end-message = return-value .
                  run pcall-log-file in p-log-handle ( input v-end-message ) .
                  undo, return error v-end-message.
              end.

            if temp_ord-doc.exch-code <> 0 and
               ( temp_ord-line.price-cli = 0 or
                 temp_ord-line.price-cli = ? ) then do:
                  v-end-message =  substitute("Не задана цена товара &1 в валюте поставщика " ,
                  temp_ord-line.gds-code  ) .
                run pcall-log-file in p-log-handle (input v-end-message) .
                undo, return error v-end-message.
             end.

            if temp_ord-doc.exch-code = 0 and
               temp_ord-line.price-rubl <> 0 and
               temp_ord-line.price-rubl <> ?
            then temp_ord-line.price-cli = temp_ord-line.price-rubl  .


           find first ub.goods no-lock  where
                ub.goods.gds-code = temp_ord-line.gds-code  no-error.
           if available ub.goods then do:
           if v-specif = true then do:
              find first ub.contract-specif no-lock where
                         ub.contract-specif.gds-code      = ub.goods.gds-code and
                         ub.contract-specif.contract-num  = temp_ord-doc.contract-code and
                         ub.contract-specif.host-code     = temp_ord-doc.host-code no-error .
              if not available ub.contract-specif then do:
                v-end-message =  substitute(" Товара &1 &2 нет в спецификации &3" , ub.goods.gds-code,
                ub.goods.gds-name, temp_ord-doc.contract-code ) .
                run pcall-log-file in p-log-handle (input v-end-message) .
                undo, return error v-end-message.
              end.
              else do:
                  { str/ckcntspc.i
                    temp_ord-doc.host-code
                    temp_ord-doc.contract-code
                    ub.goods.gds-code
                    temp_ord-line.price-cli
                    ub.contract-specif.VAT-type
                    temp_ord-line.VAT-pc
                    no-error
                  }
                if error-status :error then do:
                      v-end-message =  substitute(" У Товара &1 &2 в спецификации &3  &4 " , ub.goods.gds-code,
                      ub.goods.gds-name, temp_ord-doc.contract-code , return-value ) .
                      run pcall-log-file in p-log-handle (input v-end-message) .
                      undo, return error v-end-message.
                end.
               end.

           end.
               assign
                 k = k + 1
                 temp_ord-line.artic    = ub.goods.artic
                 temp_ord-line.prod-type= ub.goods.prod-type
                 temp_ord-line.prod-code= ub.goods.prod-code
                .
            end.
            else do:
                assign
                  v-end-message =  substitute(" Нет товара &1 " ,
                  temp_ord-line.gds-code  ) .
                run pcall-log-file in p-log-handle (input v-end-message) .
                undo, return error v-end-message.
            end.


            create ub.ord-line no-error.
                assign
                  ub.ord-line.doc-code        = v-doc-code
                  ub.ord-line.prod-type       = ub.goods.prod-type
                  ub.ord-line.prod-code       = ub.goods.prod-code
                  ub.ord-line.artic           = ub.goods.artic
                  ub.ord-line.gds-code        = ub.goods.gds-code
                  ub.ord-line.qnty            = temp_ord-line.fact-qnty
                  ub.ord-line.initial-qnty    = temp_ord-line.fact-qnt
                  ub.ord-line.cli-qnty        = temp_ord-line.fact-qnty
                  ub.ord-line.price-cli       = temp_ord-line.price-cli
                  ub.ord-line.sum-cli         = ub.ord-line.price-cli * ub.ord-line.cli-qnty
                  ub.ord-line.price-rubl      = ub.ord-line.price-cli * temp_ord-doc.exch-rate / temp_ord-doc.exch-scale
                  ub.ord-line.price-base      = ( temp_ord-line.price-rubl ) / v-base-rate * v-base-scale
                  ub.ord-line.ord-dec1        = ub.ord-line.price-rubl
                  ub.ord-line.sum-rubl        = ub.ord-line.price-rubl * ub.ord-line.qnty
                  ub.ord-line.sum-base        = ub.ord-line.price-base * ub.ord-line.qnty
                  ub.ord-line.unit-cli        = ub.goods.unit-cli
                  ub.ord-line.line-num        = k
                  ub.ord-line.vat-pc          = temp_ord-line.vat-pc
                  vv-kol                      = vv-kol + ub.ord-line.qnty
                  vv-kolcli                   = vv-kolcli + ub.ord-line.cli-qnty
                  vv-sumkolr                  = vv-sumkolr + ( ub.ord-line.qnty * ub.ord-line.price-rubl )
                  vv-sumkolv                  = vv-sumkolv + ( ub.ord-line.qnty * ub.ord-line.price-base )
                  vv-sumkolc                  = vv-sumkolc + ( ub.ord-line.cli-qnty * ub.ord-line.price-cli  )
                  .
                  find first ub.ext-artic no-lock  where
                              ub.ext-artic.cli-type = temp_ord-doc.cli-type
                          and ub.ext-artic.cli-code = temp_ord-doc.cli-code
                          and ub.ext-artic.gds-code = ub.goods.gds-code
                          and ub.ext-artic.status_  = {&current-status}
                          no-error .
                  if available ub.ext-artic then do:
                     ub.ord-line.cli-art = ub.ext-artic.ext-artic .
                  end.
                  else do:
                    ub.ord-line.cli-art = '' .
                  end.

          end . /* ord-line */

          find first buf_clients no-lock where
                     buf_clients.obj-type = temp_ord-doc.cli-type and
                     buf_clients.obj-code = temp_ord-doc.cli-code
                     no-error.
              if not available buf_clients then do:
                v-end-message =  return-value .
                run pcall-log-file in p-log-handle (input v-end-message) .
                undo, return error v-end-message.
              end.

          run ver-contract  ( temp_ord-doc.contract-code, temp_ord-doc.host-code , v-doc-code) no-error .
          if error-status :error then do:
              undo, return error .
          end.

          create ub.ord-doc.
          buffer-copy temp_ord-doc to ub.ord-doc
          assign
              ub.ord-doc.doc-code     = v-doc-code
              ub.ord-doc.cli-out-doc  = temp_ord-doc.doc-code /* Номер заказа ОРА */
              ub.ord-doc.doc-date     = to-day
              ub.ord-doc.cli-code     = buf_clients.obj-code
              ub.ord-doc.cli-name     = buf_clients.obj-name
              ub.ord-doc.cli-type     = buf_clients.obj-type
              ub.ord-doc.creid        = v-cntxt-userid
              ub.ord-doc.fact-date    = ?
              ub.ord-doc.pay-code     = v-out-pay
              ub.ord-doc.ship-date    = temp_ord-doc.ship-date
              ub.ord-doc.sum-service  = 0
              ub.ord-doc.sum-ship     = 0
              ub.ord-doc.flag_        = true
              ub.ord-doc.status_      = {&ord-rcv}
              ub.ord-doc.host-code    = temp_ord-doc.host-code
              ub.ord-doc.doc-type     = {&O-P}
              ub.ord-doc.tot-lines    = k
              ub.ord-doc.order-type   = 0
              ub.ord-doc.cycle-day    = 0
              ub.ord-doc.start-date   = temp_ord-doc.doc-date
              ub.ord-doc.end-date     = temp_ord-doc.doc-date
              ub.ord-doc.date-sale-1  = temp_ord-doc.doc-date
              ub.ord-doc.date-sale-2  = temp_ord-doc.doc-date
              ub.ord-doc.pay-day      = 0
              ub.ord-doc.obj-code     = temp_ord-doc.obj-code
              ub.ord-doc.obj-type     = temp_ord-doc.obj-type
              ub.ord-doc.slt-type     = {&without-slt}
              ub.ord-doc.vat-type     = v-typevat
              ub.ord-doc.exch-date    = to-day
              ub.ord-doc.e-method     = ""
              ub.ord-doc.sum-rubl     = vv-sumkolr
              ub.ord-doc.sum-base     = vv-sumkolv
              ub.ord-doc.sum-cli      = vv-sumkolc
              ub.ord-doc.qnty         = vv-kol
              ub.ord-doc.cli-qnty     = vv-kolcli
              no-error .
                 if error-status :error then do:
                    v-end-message =  substitute(" Заказ: &1   &2 &3" ,
                                                  temp_ord-doc.doc-code    ,
                                                  return-value ,
                                                  error-status :get-message(1)  ).
                    run pcall-log-file in p-log-handle (input v-end-message) .
                    undo, return error v-end-message.

                 end.
            { gbl/baserate.i
              ub.ord-doc.host-code
              ub.ord-doc.exch-date
              ub.ord-doc.base-rate
              ub.ord-doc.base-scale
              }
                ub.ord-doc.cons-code  = temp_ord-doc.doc-code .
                ub.ord-doc.ps = ub.ord-doc.ps + " " + temp_ord-doc.doc-code +
                           " от " + string ( temp_ord-doc.doc-date , "99/99/9999") .
              v-end-message =  substitute(" &3&4 Заказ: &1  товаров: &2 " ,
                                            temp_ord-doc.doc-code    ,
                                            k ,
                                            temp_ord-doc.obj-type ,
                                            temp_ord-doc.obj-code
                                            ).

              run pcall-log-file in p-log-handle (input v-end-message) .
              p-ok-doc = p-ok-doc + 1 .
  end. /* N */
  otherwise do:
      v-end-message =  substitute(" Заказ: &1  не верный статус: &2" ,
                                    temp_ord-doc.doc-code    ,
                                    temp_ord-doc.status_
                                    ).
      run pcall-log-file in p-log-handle (input v-end-message) .
      undo, return error v-end-message.
  end.
  end case.

   end.
end.

procedure ver-contract :
define input  parameter p-contract-code as integer   no-undo .
define input  parameter p-host-code     as integer   no-undo .
define input  parameter p-doc-code      as character no-undo .

define buffer bf_contract-specif for ub.contract-specif  .

  do
  on error undo, return error return-value
  :
      /* Проверка по договору */
      if p-contract-code > 0  then do:
          find first bf_contract-specif where bf_contract-specif.host-code    = p-host-code     and
                                              bf_contract-specif.contract-num = p-contract-code no-lock no-error.
          if available bf_contract-specif then do: /* спецификация есть */
             for each ub.ord-line no-lock where
                      ub.ord-line.doc-code = p-doc-code :

                if not can-find (first bf_contract-specif no-lock where
                                       bf_contract-specif.host-code    = p-host-code and
                                       bf_contract-specif.contract-num = p-contract-code and
                                       bf_contract-specif.gds-code     = ub.ord-line.gds-code   ) then do:
                    v-end-message =  substitute(
                      "Выбран Договор со спецификацией. Несоответствие списка товаров заказа и спецификации&1Заказ      :&2&1код товара :&3&1артикл     :&4&1 ",
                      ub.ord-line.doc-code,
                      ub.ord-line.gds-code,
                      ub.ord-line.artic ).
                    run pcall-log-file in p-log-handle (input v-end-message) .
                    undo, return error v-end-message.
                end.
             end.
          end.
        end.

  end.

end procedure. /* ver-contract */