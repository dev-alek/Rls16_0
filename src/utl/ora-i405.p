block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: ora-i405.p $
$Archive: utl/ora-i405.p $

Импорт Договора и спецификации из временной таблицы

Автор: Чернова Светлана Александровна
Дата создания: 01/28/09
Author: Svetlana Chernova
Creation date: 01/28/09

*/
{ utl/tt405.i }

define input  parameter parparentproc as widget-handle no-undo .
define input  parameter p-log-handle  as handle no-undo .
define input  PARAMETER TABLE FOR  temp_contract.
define input  PARAMETER TABLE FOR  temp_contract-specif.
define output parameter p-ok-doc as integer   no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: ora-i405.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/ora-i405.p $":U .
define variable vss-description as character no-undo init "Импорт Договора и спецификации из временной таблицы".


{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ gbl/getcntxt.i def }
{ utl/ora-icli.i }
{ ref/extclass.i }
{ gbl/orapreps.i }


/*
create temp_contract.
 assign
  temp_contract.contract-code  =
  temp_contract.contract-date  = today
  temp_contract.contract-type  = "Купли-продажи"
  temp_contract.host-code      = 1
  temp_contract.cli-type       = "орг"
  temp_contract.cli-code       = 4545
  temp_contract.status_        = "тек"
  .
create temp_contract-specif.
  assign
    temp_contract-specif.contract-code = temp_contract.contract-code
    temp_contract-specif.host-code     = 1
    temp_contract-specif.gds-code      = 1517920
    temp_contract-specif.vat-pc        = 18
    temp_contract-specif.prc           = 5
    temp_contract-specif.price-rubl    = 123
    .

 */

define buffer new_contract        for ub.contract  .
define buffer new_contract-specif for ub.contract-specif  .
define buffer buf_goods           for ub.goods  .
define buffer buf_clients         for ub.clients  .
define buffer own_clients         for ub.clients  .
define buffer buf_firm            for ub.firm  .
define buffer buf_contract-specif for ub.contract-specif  .

define variable my-message as character no-undo .
define variable k as integer   no-undo .

  do
  on error undo, return error return-value
  :
run get-db-num in parparentproc (output v-cntxt-db-num ) .
run get-userid in parparentproc (output v-cntxt-userid ) .
p-ok-doc = 0 .

for each temp_contract-specif break by temp_contract-specif.contract-code :
   if first-of(temp_contract-specif.contract-code) then do:
    create temp_contract.
    assign
      temp_contract.contract-code = temp_contract-specif.contract-code
      temp_contract.contract-date = today
      temp_contract.exch-code = temp_contract-specif.exch-code
    .
    end.
end.

for each ub.sysconf no-lock :
  for each temp_contract :
    k = 0.

    find first buf_clients no-lock where
               buf_clients.obj-type = {&cmp} and
               buf_clients.obj-code = ub.sysconf.host-code
               no-error.
        if not available buf_clients then do:
          my-message = substitute("Не верный код фирмы: &2   -  &1" , return-value, ub.sysconf.host-code )  .
          run pcall-log-file in p-log-handle (input my-message ) .
          undo, return error my-message.
        end.
      temp_contract.host-code = ub.sysconf.host-code  .
      ora-icli_ver-stts-client = false .
      run who-cli-ora in this-procedure (
          input  temp_contract.contract-code ,
          output temp_contract.cli-type ,
          output temp_contract.cli-code
          ) no-error .
          if error-status :error then return error return-value .


      for each temp_contract-specif where
               temp_contract-specif.contract-code = temp_contract.contract-code
               :

        run ora-ver-goods ( temp_contract-specif.gds-code )  no-error .
          if error-status :error then do:
              my-message = return-value .
              run pcall-log-file in p-log-handle ( input my-message ) .
              undo, return error my-message.
          end.

        find first buf_goods no-lock where
                   buf_goods.gds-code = temp_contract-specif.gds-code no-error .

          k = k + 1.

          find first new_contract-specif where
              new_contract-specif.gds-code      = temp_contract-specif.gds-code and
              new_contract-specif.contract-num  = temp_contract.contract-code and
              new_contract-specif.host-code     = temp_contract.host-code     no-error .

           case caps(trim(temp_contract-specif.status_)) :
            when {&ora-line-update} or when {&ora-line-create} then do:
                if temp_contract-specif.vat-pc = ? then do:
                    my-message = substitute("Не задан НДС  по товару &1 &2 (в спецификации контрагента &3&4)" ,
                        buf_goods.artic ,
                        buf_goods.prod-type ,
                        buf_goods.prod-code ,
                        buf_goods.gds-name  ,
                        temp_contract.cli-type ,
                        temp_contract.cli-code
                        ) .
                    run pcall-log-file in p-log-handle (input my-message) .
                    undo, return error my-message.
                end.

               if not available new_contract-specif then create new_contract-specif.
                buffer-copy temp_contract-specif to new_contract-specif
                assign
                  new_contract-specif.gds-code      = temp_contract-specif.gds-code
                  new_contract-specif.contract-num  = temp_contract.contract-code
                  new_contract-specif.host-code     = temp_contract.host-code
                  new_contract-specif.gds-code      = buf_goods.gds-code
                  new_contract-specif.gds-name      = buf_goods.gds-name
                  new_contract-specif.artic         = buf_goods.artic
                  new_contract-specif.prod-type     = buf_goods.prod-type
                  new_contract-specif.prod-code     = buf_goods.prod-code
                  new_contract-specif.cli-base-rate = 1                    /* buf_goods.cli-base-rate */
                  new_contract-specif.unit-base     = buf_goods.unit-base  /* buf_goods.unit-cli      */
                  new_contract-specif.VAT-type      = temp_contract-specif.vat-type
                  new_contract-specif.VAT-pc        = temp_contract-specif.vat-pc
                  new_contract-specif.db-num        = v-cntxt-db-num
                  new_contract-specif.price-cli     = temp_contract-specif.price-cli
                .
            end.
            when {&ora-line-delete} then do:
                if available new_contract-specif then do:
                   delete new_contract-specif.
                   next.
                end.
            end.
            otherwise do:
                my-message = substitute("ошибка значения поля статус = &2 код товара &1" ,  temp_contract-specif.gds-code, temp_contract-specif.status_ ) .
                run pcall-log-file in p-log-handle (input my-message) .
                undo, return error my-message.
            end.
          end case.


      end. /*temp_contract-specif*/

      find first buf_clients no-lock where
                buf_clients.obj-type = temp_contract.cli-type and
                buf_clients.obj-code = temp_contract.cli-code no-error .
        if error-status :error then do:
            my-message = substitute("Нет такого Контрагента &3 &4 &1 &2" , error-status :get-message(1) , return-value ,
                          temp_contract.cli-type, temp_contract.cli-code       ) .
            run pcall-log-file in p-log-handle (input my-message) .
            undo, return error my-message.
        end.

      find first own_clients no-lock where
                own_clients.obj-type = {&cmp} and
                own_clients.obj-code = temp_contract.host-code no-error .
        if error-status :error then do:
            my-message = substitute("Нет такого Контрагента &3 &4 &1 &2" , error-status :get-message(1) , return-value ,
                          {&cmp}, temp_contract.host-code       ) .
            run pcall-log-file in p-log-handle (input my-message) .
            undo, return error my-message.

        end.

     find first new_contract no-lock where
                new_contract.contract-code = temp_contract.contract-code and
                new_contract.host-code     = temp_contract.host-code     no-error .
      if not available new_contract then do:
      create new_contract.
      assign
        new_contract.curr-code     = temp_contract.exch-code
        new_contract.contract-code = temp_contract.contract-code
        new_contract.host-code     = temp_contract.host-code
        new_contract.contract-prn-code = ""
        new_contract.contract-name = buf_clients.obj-name
        new_contract.contract-date = temp_contract.contract-date
        new_contract.contract-type = temp_contract.contract-type
        new_contract.doc-type      = {&income}
        new_contract.status_       = {&current-contr}
        new_contract.own-name      = own_clients.obj-name
        new_contract.cli-type      = temp_contract.cli-type
        new_contract.cli-code      = temp_contract.cli-code
        new_contract.cli-name      = buf_clients.obj-name
        new_contract.db-num        = v-cntxt-db-num
        new_contract.user-db-num   = v-cntxt-db-num
        new_contract.user-name     = v-cntxt-userid

      .
        /* читаем настройки фирмы по умолчанию */

        assign
          new_contract.an-uchet-code-out          = ub.sysconf.an-uchet-code-out
          new_contract.cel-nazn-code-out          = ub.sysconf.cel-nazn-code-out
          new_contract.cor-acc-out                = ub.sysconf.cor-acc-out
          new_contract.cor-acc1-out               = ub.sysconf.cor-acc1-out
          new_contract.an-uchet-code-in           = ub.sysconf.an-uchet-code-in
          new_contract.cel-nazn-code-in           = ub.sysconf.cel-nazn-code-in
          new_contract.cor-acc-in                 = ub.sysconf.cor-acc-in
          new_contract.cor-acc1-in                = ub.sysconf.cor-acc1-in
          new_contract.an-uchet-code-out-cash     = ub.sysconf.an-uchet-code-out-cash
          new_contract.cel-nazn-code-out-cash     = ub.sysconf.cel-nazn-code-out-cash
          new_contract.cor-acc-out-cash           = ub.sysconf.cor-acc-out-cash
          new_contract.cor-acc1-out-cash          = ub.sysconf.cor-acc1-out-cash
          new_contract.an-uchet-code-in-cash      = ub.sysconf.an-uchet-code-in-cash
          new_contract.cel-nazn-code-in-cash      = ub.sysconf.cel-nazn-code-in-cash
          new_contract.cor-acc-in-cash            = ub.sysconf.cor-acc-in-cash
          new_contract.cor-acc1-in-cash           = ub.sysconf.cor-acc1-in-cash
          new_contract.an-uchet-code-out-payoff   = ub.sysconf.an-uchet-code-out-payoff
          new_contract.cel-nazn-code-out-payoff   = ub.sysconf.cel-nazn-code-out-payoff
          new_contract.cor-acc-out-payoff         = ub.sysconf.cor-acc-out-payoff
          new_contract.cor-acc1-out-payoff        = ub.sysconf.cor-acc1-out-payoff
          new_contract.an-uchet-code-in-payoff    = ub.sysconf.an-uchet-code-in-payoff
          new_contract.cel-nazn-code-in-payoff    = ub.sysconf.cel-nazn-code-in-payoff
          new_contract.cor-acc-in-payoff          = ub.sysconf.cor-acc-in-payoff
          new_contract.cor-acc1-in-payoff         = ub.sysconf.cor-acc1-in-payoff
          new_contract.transport-cli-type         = ub.sysconf.transport-cli-type
          new_contract.transport-cli-code         = ub.sysconf.transport-cli-code
          new_contract.transport-host             = ub.sysconf.transport-host
          new_contract.transport-contract         = ub.sysconf.transport-contract
          new_contract.transport-uslov            = ub.sysconf.transport-uslov
          new_contract.transport-value            = ub.sysconf.transport-value
          new_contract.agnt-type                  = ""
          new_contract.posr-type                  = ""
        .
        if ub.sysconf.pay-code-schet-rubl > 0 then
          assign
            new_contract.own-code-schet = ub.sysconf.pay-code-schet-rubl
          .

        find first buf_firm no-lock where buf_firm.firm-code = temp_contract.host-code no-error .
        if error-status :error then do:
            my-message = substitute("Нет фирмы &3 &4 &1 &2" , error-status :get-message(1) , return-value ,
                          {&cmp}, temp_contract.host-code       ) .
            run pcall-log-file in p-log-handle (input my-message) .
            undo, return error my-message.
        end.
        assign
          new_contract.own-kpp           = buf_firm.kpp
          new_contract.own-inn           = buf_firm.inn
          new_contract.own-addres        = buf_firm.addres1
          new_contract.contract-city     = ub.sysconf.contract-city
          new_contract.own-sign-post     = ub.sysconf.pay-sign-post
          new_contract.own-sign          = ub.sysconf.pay-sign
          new_contract.contract-date     = today
          new_contract.contract-date-beg = today
          new_contract.contract-date-end = date('')
          new_contract.fin-vat-pc        = ub.sysconf.fin-vat-pc
          new_contract.srok-opl          = ub.sysconf.srok-opl
          new_contract.gen-factur-srok   = ub.sysconf.srok-opl-sf
        .


    case ub.sysconf.usl-opl-sf  :
      when {&contr-chf-nodef}  or
      when  "" or
      when ?      then do:
      assign  new_contract.gen-factur = 0 .
      end.
      when {&contr-chf-in}        then assign   new_contract.gen-factur = 1 .
      when {&contr-chf-fo}        then assign   new_contract.gen-factur = 2 .
      when {&contr-chf-pay}       then assign   new_contract.gen-factur = 3 .
      when {&contr-chf-type}      then assign   new_contract.gen-factur = 4 .
      when {&contr-chf-out}       then assign   new_contract.gen-factur = 5 .

    end.


    if ub.sysconf.contract-type <> "" and ub.sysconf.contract-type <> ?  and ub.sysconf.contract-type <> "Не задан" then
      new_contract.contract-type = ub.sysconf.contract-type .
    else new_contract.contract-type = {&contr-buy-sale} .

    if ub.sysconf.usl-opl <> "" and   ub.sysconf.usl-opl <> ? then
        new_contract.usl-opl =  ub.sysconf.usl-opl .
    else new_contract.usl-opl    = {&contr-pay-nodef} .

      new_contract.auto-pay = ub.sysconf.auto-pay .



    if ub.sysconf.pay-code-schet-rubl <> ? then do:
      find first ub.fin-schet no-lock where
          ub.fin-schet.host-code  = new_contract.host-code and
          ub.fin-schet.code-schet = ub.sysconf.pay-code-schet-rubl no-error .
      if available ub.fin-schet then do:
        find first ub.fin-bank no-lock where
                    ub.fin-bank.host-code = new_contract.host-code and
                    ub.fin-bank.code-bank = ub.fin-schet.code-bank no-error .
        assign
          new_contract.own-bank-name = ub.fin-bank.bank-name
          new_contract.own-bik       = ub.fin-bank.bik
          new_contract.own-r-schet   = ub.fin-schet.r-schet
          new_contract.own-c-schet   = ub.fin-schet.c-schet
        .
        release new_contract no-error .
        if error-status :error then do:
            message
              vss-workfile vss-revision vss-description skip
              error-status :get-message(1) skip
              return-value skip
              "Ошибка сохранения договора"
              view-as alert-box error
            .
          my-message = substitute("Ошибка сохранения договора по фирме &2 - &1" , return-value, ub.sysconf.host-code )  .
          run pcall-log-file in p-log-handle (input my-message ) .
          undo, return error my-message.
        end.
      end.
    end.
    end.

    /* договор уже есть  */
     find first new_contract exclusive-lock where
        new_contract.contract-code = temp_contract.contract-code and
        new_contract.host-code     = temp_contract.host-code     no-error .
      if available new_contract then do:
        new_contract.contract-name = buf_clients.obj-name .
        new_contract.contract-prn-code = "".

      if not can-find ( first buf_contract-specif no-lock where
         buf_contract-specif.host-code = new_contract.host-code  and
         buf_contract-specif.contract-num = new_contract.contract-code       ) then
         do:
           if new_contract.status_ <> {&close-contr}  then do:
              new_contract.status_  = {&close-contr}  .
              new_contract.contract-date-end = today .
           end.
         end.
         else do:
             new_contract.status_ = {&current-contr} .
             if new_contract.contract-date-end <> date('') then do:
                new_contract.contract-date-beg = today    .
                new_contract.contract-date-end = date('') .
             end.
         end.
      end.

    my-message =  substitute(" &3&4 Договор: &1 фирма &5 товаров: &2 " ,
                                  temp_contract.contract-code    ,
                                  k ,
                                  temp_contract.cli-type ,
                                  temp_contract.cli-code ,
                                  temp_contract.host-code
                                  ).
    run pcall-log-file in p-log-handle (input my-message) .
    p-ok-doc = p-ok-doc + 1.

  end. /* temp_contract */
  end. /* sysconf */

 end.