/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

заполнение полей временной таблицы для отсылки дис карт на кассы

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/07/05
Author: Bakhtadze Natalya
Creation date: 12/07/05

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$".

&if "{2}" = "def" &then
define variable v-sum-id-c as character no-undo .
define variable v-sum-id as character no-undo .
define variable iid as integer no-undo .
define variable v-num-entries as integer no-undo .
define variable v-ii as integer no-undo .
define variable v-sum-id-value as character no-undo .
define variable v-sum-id-output as logical no-undo .
define variable  v-property-value-chr as character no-undo .
define variable v-d-pcnt as decimal no-undo .
define variable v-cash-d-pcnt as decimal no-undo .
define variable v-categ as integer no-undo .
define variable v-d-pcnt0 as decimal no-undo .
define variable v-cash-d-pcnt0 as decimal no-undo .
define variable v-categ0 as integer no-undo .
define variable v-gds-code as integer no-undo .
define variable v-b-code as integer no-undo .


define temp-table temp-cd-clu no-undo like ub.cd-clu.
define buffer buf_dis-card-property for ub.dis-card-property.

&else

&if "{2}" <> "MARIA" &then

&if "{1}" <> "mask" &then
if ub.dis-card.mask-card then.
else do:
&endif
FIND FIRST cash-cli where cash-cli.crf = (cr + 1) No-ERROR.
start-paket = no.
if not avail cash-cli then
create cash-cli.
else do:
  assign
  cash-cli.cli-adr   = ""
  cash-cli.cli-adr2  = ""
  cash-cli.director  = ""
  cash-cli.engl-name = ""
  cash-cli.telex     = "":U
  cash-cli.phone1-note  = "":U
  cash-cli.post-addr1 = "":U
  cash-cli.post-addr2 = "":U
  cash-cli.phone1  = "":U
  cash-cli.post-box  = ""
  cash-cli.valid-date = {&end-of-age}
  cash-cli.property-value-chr[1] = '':U
  cash-cli.property-value-chr[2] = '':U
  cash-cli.property-value-chr[3] = '':U
  cash-cli.property-value-chr[4] = '':U
  cash-cli.dcr-pcnt        = 0
  cash-cli.dcr-abs         = 0
  cash-cli.dcr-pcnt-qnty   = 0
  cash-cli.dcr-pcnt-tot    = 0
  cash-cli.ef-format       = 0
  cash-cli.ef-access-key   = ""
  cash-cli.has-attrs       = no
  cash-cli.has-attrs-lim   = no
  .
end.
error-status:error = false.
cash-cli.crf = cr + 1.
cr = cr + 1.
if ub.clients.obj-type = {&cmp} then do:
  FIND ub.firm WHERE ub.firm.firm-code = ub.clients.obj-code .
  assign
  cash-cli.cli-type = {&cmp}
  cash-cli.cli-code = ub.clients.obj-code
  cash-cli.cli-city = ub.firm.city
  cash-cli.cli-adr = trim( ub.firm.addres1 )
  cash-cli.cli-adr2 = trim( ub.firm.addres2 )
  cash-cli.director = trim( ub.firm.director )
  cash-cli.e-mail = trim( ub.firm.e-mail )
  cash-cli.engl-name = trim( ub.firm.engl-name)
  cash-cli.fax     = trim( ub.firm.fax)
  cash-cli.telex     = trim( ub.firm.telex)
  cash-cli.position  = trim( ub.firm.head-position)
  cash-cli.is-pboul  = ub.firm.is-pboul
  cash-cli.okonh     = trim(ub.firm.okonh)
  cash-cli.okpo      = trim(ub.firm.okpo)
  cash-cli.phone1-note  = trim(ub.firm.phone1-note)
  cash-cli.post-addr1 = trim( ub.firm.post-addr1 )
  cash-cli.post-addr2 = trim( ub.firm.post-addr2 )
  cash-cli.cli-inn = trim(ub.firm.inn)
  cash-cli.cli-phone = trim(ub.firm.phone)
  cash-cli.cli-ind = ub.firm.ind
  cash-cli.justface = 1
  cash-cli.kpp     = ub.firm.kpp
  .
end.
else do:
  if ub.clients.obj-type = {&prs} then do:
    FIND ub.person WHERE ub.person.psn-code = ub.clients.obj-code .
    assign
    cash-cli.cli-type = {&prs}
    cash-cli.cli-code = ub.clients.obj-code
    cash-cli.cli-city = ub.person.city
    cash-cli.cli-adr = trim( ub.person.address )
    cash-cli.cli-inn = trim(ub.person.inn)
    cash-cli.cli-phone = trim(ub.person.phone1)
    cash-cli.cli-ind = ub.person.ind
    cash-cli.phone1  = trim(ub.person.phone1)
    cash-cli.e-mail = trim( ub.person.e-mail )
    cash-cli.fax     = trim( ub.person.fax)
    cash-cli.position  = trim( ub.person.position)
    cash-cli.is-pboul  = ub.person.is-pboul
    cash-cli.okonh     = trim(ub.person.okonh)
    cash-cli.okpo      = trim(ub.person.okpo)
    cash-cli.post-box  = trim(ub.person.post-box)
    cash-cli.justface = 0
    cash-cli.kpp     = ub.person.kpp
    .
  end.
  else do:
    NEXT .
  end.
end.
/*для КАРАВАНА - пересчитываем лимит кредит для клиента в соответствии
с итогами по его дисконтной карте
лимит кредита уменьшается на величину =
сумма товарных строк чеков + сумма суммовых строк чеков - скидка (пока только товарная)
- сумма оплат по карте)
*/

assign
cash-cli.mask-card     = ub.dis-card.mask-card
cash-cli.current-saldo =  (if ub.dis-card.credit-card = yes
                            then (if v-curr-r-b = {&r-b-base}
                                  then ub.dis-card.saldo-base
                                  else ub.dis-card.saldo-rubl)
                            else 0)
cash-cli.current-saldo-rubl = ub.dis-card.saldo-rubl
cash-cli.current-saldo-base = ub.dis-card.saldo-base
cash-cli.lim-kr = (if ub.dis-card.credit-card = yes
                    then ub.dis-card.lim-kr
                    else 0)
cash-cli.d-pcnt = ub.dis-card.d-pcnt
cash-cli.kat-pcnt = ub.dis-card.category
cash-cli.h-ka = (if ub.dis-card.category > 0 then 2 else 0)
cash-cli.cash-d-pcnt = ub.dis-card.cash-d-pcnt
cash-cli.d-pcnt-method = ub.dis-card.d-pcnt-method
cash-cli.status_ = ub.dis-card.status_
cash-cli.d-card = ub.dis-card.d-card
cash-cli.issue-code = ub.dis-card.issue-code
cash-cli.issue-date = ub.dis-card.issue-date
cash-cli.type = ub.dis-card.type
cash-cli.emitent-host-code = ub.dis-card.emitent-host-code
cash-cli.d-pcnt-byshop = ub.dis-card-type.d-pcnt-byshop
cash-cli.cli-status_ = ub.clients.stts
cash-cli.card-media = ub.dis-card-type.card-media
cash-cli.credit-card = ub.dis-card.credit-card
cash-cli.debet-card = ub.dis-card.debet-card
cash-cli.staff-card = ub.dis-card.staff-card
cash-cli.cli-message = ub.dis-card.cli-message
cash-cli.fiscal-pay = (if cash-cli.debet-card
                        or cash-cli.credit-card
                        then  ub.dis-card-type.fiscal-pay
                        else no)
cash-cli.pay-code = ub.dis-card-type.pay-code
cash-cli.mixed-pay =  ub.dis-card-type.mixed-pay
cash-cli.sourced-card = ub.dis-card.sourced-card
cash-cli.valid-date  = (if ub.dis-card.valid-date <> ?
                        then ub.dis-card.valid-date
                        else cash-cli.valid-date)
.

/*
по типу ДК должны найти размер текущих накоплений - для этого надо получить sum-id для записей итогов
*/

if cash-cli.card-media = integer({&dc-cm-ef}) then do:
  /*надо найти формат и ключ доступа*/
  find first buf_Dis-card-property no-lock where
            buf_Dis-card-property.d-card = cash-cli.d-card
       and buf_Dis-card-property.dtm-code = integer({&dc-prop_easyfuel})
       and buf_Dis-card-property.node-code = integer({&dc_prop_easyfuel_access-key})
       and buf_Dis-card-property.host-code = 0
       and buf_Dis-card-property.obj-type = ''
       and buf_Dis-card-property.obj-code = 0 no-error.
  if available buf_dis-card-property then
  cash-cli.ef-access-key = buf_Dis-card-property.property-value-character.
  find first buf_Dis-card-property no-lock where
            buf_Dis-card-property.d-card = cash-cli.d-card
       and buf_Dis-card-property.dtm-code = integer({&dc-prop_easyfuel})
       and buf_Dis-card-property.node-code = integer({&dc_prop_easyfuel_ef-format})
       and buf_Dis-card-property.host-code = 0
       and buf_Dis-card-property.obj-type = ''
       and buf_Dis-card-property.obj-code = 0 no-error.
  if available buf_dis-card-property then
  cash-cli.ef-format = buf_Dis-card-property.property-value-integer.
end.

CASE ub.dis-card-type.cardname-sent:
  when "card" then do:
    assign
    cash-cli.cli-name = dis-card.d-card
    cash-cli.obj-name = ub.clients.obj-name
    cash-cli.cli-name2 = "":U
    cash-cli.cli-name3 = "":U
    cash-cli.given-by = "":U
    cash-cli.passport = "":U
    .
  end.
  otherwise do:
    if cash-cli.cli-type = {&cmp} then do:
      assign
      cash-cli.cli-name = right-trim( ub.clients.obj-name )
      cash-cli.cli-name2 = "":U
      cash-cli.cli-name3 = "":U
      /*
      cash-cli.given-by = ub.firm.given-by
      cash-cli.passport = ub.firm.passp-ser + {&delim-par} + ub.firm.passp-num
      */
      .
    end.
    else do:
      assign
      cash-cli.obj-name = ub.clients.obj-name
      cash-cli.cli-name = right-trim( ub.clients.obj-name ) + {&delim-par} +
                          (
                          if ub.person.name1 <> "":U
                          and ub.person.name1 <> ?
                          then (substr(trim( ub.person.name1 ),1,1) + ".")
                          else "":U
                          ) + {&delim-par} +
                          (if ub.person.name2 <> "":U
                          and ub.person.name2 <> ?
                          then  (substr(trim( ub.person.name2 ),1,1) + ".")
                          else "":U
                          )
      cash-cli.cli-name2 = ub.person.name1
      cash-cli.cli-name3 = ub.person.name2
      cash-cli.given-by = ub.person.given-by
      cash-cli.passport = ub.person.passp-ser + {&delim-par} + ub.person.passp-num
      .
    end.
    .
  end.
END CASE.
assign
cash-cli.cli-name = replace(cash-cli.cli-name, {&double-quote}, "":U)
cash-cli.cli-city = replace(cash-cli.cli-city, {&double-quote}, "":U)
cash-cli.cli-adr = replace(cash-cli.cli-adr, {&double-quote}, "":U)
.
for each buf_dis-card-property no-lock where
          buf_dis-card-property.dtm-code = {&dc-prop_dc-petrol}
     and  buf_dis-card-property.d-card = cash-cli.d-card
     AND  buf_dis-card-property.HOST-CODE = 0
     AND  buf_dis-card-property.obj-type = '':U
     AND  buf_dis-card-property.obj-code = 0
  break
  by buf_dis-card-property.dt-code:
  if first-of(buf_dis-card-property.dt-code) then do:
    /*найдем bar-code*/
    v-gds-code = -1.
    v-gds-code =  propreft-string-to-petrol(buf_dis-card-property.sum-id) no-error .
    if not error-status:error
    and v-gds-code <> 0 then do:
    { gbl/gdsbcode.i v-gds-code ? v-b-code no-error }
    end. 
  end.
  if v-gds-code = -1 then next.
  find first cash-cli-attr no-lock where
            cash-cli-attr.d-card = ub.dis-card.d-card
        and cash-cli-attr.dc-petrol-code = v-b-code no-error .
  if not available cash-cli-attr then do:
    create cash-cli-attr.
    assign
    cash-cli-attr.d-card = ub.dis-card.d-card
    cash-cli-attr.dc-petrol-code = v-b-code
    .

  end.
  case buf_dis-card-property.node-code:
    when {&dc_prop_dc-petrol_car-reg-number}  then do:
      assign
      cash-cli-attr.dc-car-reg-number = buf_dis-card-property.property-value-character
      .
    end.
    when {&dc_prop_dc-petrol_car-brand} then do:
      assign
      cash-cli-attr.dc-car-brand = buf_dis-card-property.property-value-character
      .
    end.
    when {&dc_prop_dc-petrol_account-type} then do:
      cash-cli-attr.account-type = buf_dis-card-property.property-value-integer.
    end.
    when  {&dc_prop_dc-petrol_limit-type} then do:
      cash-cli-attr.dc-limit-type = buf_dis-card-property.property-value-character.
    end.
    when {&dc_prop_dc-petrol_sum-limit} then do:
      assign
      cash-cli-attr.dc-limit =  buf_dis-card-property.property-value-decimal
      .
    end.
    when {&dc_prop_dc-petrol_qnty-limit} then do:
      assign
      cash-cli-attr.dc-limit-l =  buf_dis-card-property.property-value-decimal   .
    end.
    when {&dc_prop_dc-petrol_quota-period} then do:
    end.
    when {&dc_prop_dc-petrol_quota} then do:
    end.
    when {&dc_prop_dc-petrol_cdpay-code} then do:
      assign
      cash-cli-attr.cdpay-code =  buf_dis-card-property.property-value-integer
      cash-cli-attr.curr-code = 0
      .
    end.
  end case.
  if first-of(buf_dis-card-property.dt-code) then do:
    release cash-cli-attr.
    cash-cli.has-attrs = yes.
  end.
end.

for each ub.dis-card-property no-lock where
          ub.dis-card-property.dtm-code = {&dc-prop_dc-limit}
     and  ub.dis-card-property.d-card = cash-cli.d-card
/*     and ub.dis-card-property.sum-id <> ""*/
     AND  ub.dis-card-property.HOST-CODE = 0
     AND  ub.dis-card-property.obj-type = '':U
     AND  ub.dis-card-property.obj-code = 0
  break
  by ub.dis-card-property.dt-code:
    
  for each ub.prop-ref where ub.prop-ref.dtm-code = ub.dis-card-property.dtm-code and ub.prop-ref.sum-id = ub.dis-card-property.sum-id:  
  find first cash-cli-attr no-lock where
            cash-cli-attr.d-card = ub.dis-card.d-card and cash-cli-attr.dc-sum-id = ub.dis-card-property.sum-id 
                                                      and cash-cli-attr.caller_id = ub.prop-ref.Caller_id no-error .
  if not available cash-cli-attr then do:
    create cash-cli-attr.
    assign
    cash-cli-attr.d-card = ub.dis-card.d-card
    cash-cli-attr.dc-sum-id = ub.dis-card-property.sum-id
    cash-cli-attr.caller_id = ub.prop-ref.Caller_id
    .
    
  end.
  case ub.dis-card-property.node-code:
    when {&dc_prop_dc-limit_minnum}  then do:
      assign
      cash-cli-attr.dc-minnum = ub.dis-card-property.property-value-decimal
      .
    end.
    when {&dc_prop_dc-limit_maxnum} then do:
      assign
      cash-cli-attr.dc-maxnum = ub.dis-card-property.property-value-decimal
      .
    end.
  end case.
  end.
  if last-of(ub.dis-card-property.dt-code) then do:
/*    release cash-cli-attr.*/
    cash-cli.has-attrs-lim = yes.
  end.
  
end.

&if "{1}" <> "mask" &then
end.
&endif

&endif
/*if "{2} = "MARIA" */
&endif
/* else if "{2} = "def" */

&IF "{2}" = "MARIA" &THEN
define buffer buf_dis-dc-rule for ub.dis-dc-rule.
IF can-find( first temp-cd where temp-cd.pos-type = {&cd-type-maria}) then do:
   /*заполнение полей правил для постоянных клиентов*/
  for each buf_dis-dc-rule no-lock where
            buf_dis-dc-rule.d-card = cash-cli.d-card
        and buf_dis-dc-rule.host-code = ub.sysconf.host-code
        and buf_dis-dc-rule.obj-type = {&shop}
        and buf_dis-dc-rule.obj-code = i-obj-code:
    if buf_dis-dc-rule.discnt-role = {&ddcr-debet-pay-pcnt-discnt}
    or buf_dis-dc-rule.discnt-role = {&ddcr-debet-pay-abs-discnt}
    or buf_dis-dc-rule.discnt-role = {&ddcr-debet-pay-qnty-discnt}
    or buf_dis-dc-rule.discnt-role = {&ddcr-debet-pay-sum-discnt}
    or buf_dis-dc-rule.discnt-role = {&ddcr-debet-pay-free-discnt}  then do:
      assign
      cash-cli.dcr-debet-pay = buf_dis-dc-rule.rule-num
      no-error
      .
      leave.
    end.
  end.
  for each buf_dis-dc-rule no-lock where
            buf_dis-dc-rule.d-card = cash-cli.d-card
        and buf_dis-dc-rule.host-code = ub.sysconf.host-code
        and buf_dis-dc-rule.obj-type = {&shop}
        and buf_dis-dc-rule.obj-code = i-obj-code:
    if buf_dis-dc-rule.discnt-role = {&ddcr-credit-pay-pcnt-discnt}
    or buf_dis-dc-rule.discnt-role = {&ddcr-credit-pay-abs-discnt}
    or buf_dis-dc-rule.discnt-role = {&ddcr-credit-pay-qnty-discnt}
    or buf_dis-dc-rule.discnt-role = {&ddcr-credit-pay-sum-discnt}
    or buf_dis-dc-rule.discnt-role = {&ddcr-credit-pay-free-discnt}  then do:
      assign
      cash-cli.dcr-credit-pay = buf_dis-dc-rule.rule-num
      no-error
      .
    end.
  end.

end.
&ENDIF




/* $Workfile$ e n d */