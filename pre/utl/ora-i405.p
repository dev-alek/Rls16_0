block-level on error undo, throw.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table temp_contract no-undo
field contract-code as integer
field exch-code     as integer
field contract-date as date
field contract-type as character
field host-code     as integer
field cli-type      as character
field cli-code      as integer
field status_       as character
index pi
contract-code
.
define temp-table temp_contract-specif no-undo
field line-num as integer
field contract-code as integer
field exch-code     as integer
field gds-code      as integer
field vat-pc        as decimal
field vat-type      as character
field prc           as decimal
field price-cli     as decimal
field status_       as character
index pi
line-num
contract-code
gds-code
index pi2
contract-code
line-num
gds-code
  .
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
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable  ora-icli_ver-stts-client as logical   no-undo  init true .
procedure who-cli-ora :
define input  parameter p-cli-code-ora as integer   no-undo .
define output parameter p-cli-type as character no-undo .
define output parameter p-cli-code as integer   no-undo .
  do
  on error undo, return error return-value
  :
  if length (string(p-cli-code-ora))  <> 9 then do:
     return error substitute ("Не верный формат кода КОНТРАГЕНТА: &1" , p-cli-code-ora ) .
  end.
  if string(p-cli-code-ora) begins "1" or
     string(p-cli-code-ora) begins "2" or
     string(p-cli-code-ora) begins "4" then do:
      p-cli-type = 'орг':U .
      p-cli-code = p-cli-code-ora  .
  end.
  else do:
    if string(p-cli-code-ora) begins "3" then do:
      p-cli-type = 'чел':U .
      p-cli-code = p-cli-code-ora  .
    end.
    else do:
       return error substitute ("Не верный формат кода КОНТРАГЕНТА: &1 ( первый код )" , p-cli-code-ora ) .
    end.
  end.
  define buffer buf_clients for ub.clients  .
  find first buf_clients no-lock where
             buf_clients.obj-type = p-cli-type and
             buf_clients.obj-code = p-cli-code
             no-error .
      if error-status :error then do:
          return error substitute
          ( "Нет такого контрагента: &1 ( &2 &3 )" ,
              p-cli-code-ora ,
              p-cli-type ,
              p-cli-code ) .
      end.
      if ora-icli_ver-stts-client then do:
          if buf_clients.stts > 0 then do:
              return error substitute
              ( "Контрагент: &1 ( &2 &3 ) СТАТУС неактивный !!!" ,
                  p-cli-code-ora ,
                  p-cli-type ,
                  p-cli-code ) .
          end.
      end.
  end.
end procedure.
procedure ora-ver-goods :
define input  parameter p-gds-code as integer   no-undo .
define buffer buf_goods for ub.goods  .
define variable my-message as character no-undo .
  do
  on error undo, return error return-value
  :
        find first buf_goods no-lock where
                   buf_goods.gds-code = p-gds-code no-error .
            if error-status :error then do:
                my-message = substitute("Нет товара с кодом &1" ,  p-gds-code) .
                undo, return error my-message.
            end.
          if buf_goods.stts > 0 then do:
            assign
              my-message =  substitute(" Товара &1 УДАЛЕН" , buf_goods.gds-code  ) .
              undo, return error my-message.
          end.
  end.
end procedure.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
               buf_clients.obj-type = 'орг':U and
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
            when 'U' or when 'N' then do:
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
                  new_contract-specif.cli-base-rate = 1
                  new_contract-specif.unit-base     = buf_goods.unit-base
                  new_contract-specif.VAT-type      = temp_contract-specif.vat-type
                  new_contract-specif.VAT-pc        = temp_contract-specif.vat-pc
                  new_contract-specif.db-num        = v-cntxt-db-num
                  new_contract-specif.price-cli     = temp_contract-specif.price-cli
                .
            end.
            when 'D' then do:
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
      end.
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
                own_clients.obj-type = 'орг':U and
                own_clients.obj-code = temp_contract.host-code no-error .
        if error-status :error then do:
            my-message = substitute("Нет такого Контрагента &3 &4 &1 &2" , error-status :get-message(1) , return-value ,
                          'орг':U, temp_contract.host-code       ) .
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
        new_contract.doc-type      = 'при':U
        new_contract.status_       = 'тек':U
        new_contract.own-name      = own_clients.obj-name
        new_contract.cli-type      = temp_contract.cli-type
        new_contract.cli-code      = temp_contract.cli-code
        new_contract.cli-name      = buf_clients.obj-name
        new_contract.db-num        = v-cntxt-db-num
        new_contract.user-db-num   = v-cntxt-db-num
        new_contract.user-name     = v-cntxt-userid
      .
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
                          'орг':U, temp_contract.host-code       ) .
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
      when 'Не определено':U  or
      when  "" or
      when ?      then do:
      assign  new_contract.gen-factur = 0 .
      end.
      when 'По приходной накладной':U        then assign   new_contract.gen-factur = 1 .
      when 'По фин. обязательству':U        then assign   new_contract.gen-factur = 2 .
      when 'По платежу':U       then assign   new_contract.gen-factur = 3 .
      when 'По накл. смены типа преобр.':U      then assign   new_contract.gen-factur = 4 .
      when 'По расходной накладной':U       then assign   new_contract.gen-factur = 5 .
    end.
    if ub.sysconf.contract-type <> "" and ub.sysconf.contract-type <> ?  and ub.sysconf.contract-type <> "Не задан" then
      new_contract.contract-type = ub.sysconf.contract-type .
    else new_contract.contract-type = 'Купли-продажи':U .
    if ub.sysconf.usl-opl <> "" and   ub.sysconf.usl-opl <> ? then
        new_contract.usl-opl =  ub.sysconf.usl-opl .
    else new_contract.usl-opl    = 'Не определено':U .
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
           if new_contract.status_ <> 'зкр':U  then do:
              new_contract.status_  = 'зкр':U  .
              new_contract.contract-date-end = today .
           end.
         end.
         else do:
             new_contract.status_ = 'тек':U .
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
  end.
  end.
 end.
