/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

заполнение полей временной таблицы для отсылки товаров на кассы

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/02/05
Author: Bakhtadze Natalya
Creation date: 12/02/05

*/
/* loc-goods -  предполагается goods */
/* loc-bar-code -  предполагается bar-code */
/* loc-gds-prt -  предполагается gds-prt корень*/
/* loc-gds-obj -  предполагается gds-obj */
/* loc-price-list -  предполагается price-list */
/* loc-units -  предполагается units */
/* loc-gds-prt-term -  предполагается gds-prt для признака*/
/* loc-prod-bc -  предполагается prod-bc */

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

PROCEDURE asc-gds.
DEFINE parameter buffer loc-goods for {1}.
&if "{&called}" = "send-bcn" &then
DEFINE parameter buffer loc-bar-code for bc-list.
&else
DEFINE parameter buffer loc-bar-code for ub.bar-code.
&endif
DEFINE parameter buffer loc-gds-prt-root for ub.gds-prt.
DEFINE parameter buffer loc-gds-obj for ub.gds-obj.
DEFINE parameter buffer loc-price-list for ub.price-list.
DEFINE parameter buffer loc-units for ub.units.
DEFINE parameter buffer loc-gds-prt-term for ub.gds-prt.
DEFINE input parameter loc-prod-bc like ub.prod-bc.b-str.
DEFINE input parameter loc-bc-on-type like ub.prod-bc.bc-on-type.
DEFINE input parameter loc-bc-units-cli-type like ub.units.type.
DEFINE input parameter loc-bc-units-okei like ub.units.okei.
define input parameter parhost-code like ub.sysconf.host-code no-undo .
define input parameter parobj-type like ub.clients.obj-type no-undo .
define input parameter parobj-code like ub.clients.obj-code no-undo .
define variable v-doc-num like ub.price-list.doc-num no-undo .
DEFINE VARIABLE vat-value like ub.doc-line.vat-pc no-undo .
DEFINE VARIABLE slt-value like ub.doc-line.slt-pc no-undo .
define variable v-disc-price-sale as decimal no-undo .
define variable v-pdf-id as integer no-undo .
define variable v-pdf-db-num as integer no-undo .
define variable v-oss as character no-undo.

define variable v-gtd as character no-undo .
define variable v-is-gas as character no-undo .
define variable v-ban-bonus as character no-undo .
define variable v-ptrl-as-good as character no-undo .
define variable v-type as character no-undo .
define variable disc-b-code as integer no-undo .
define variable v-main-prt-b-code as integer no-undo .
define variable IBM-good-code as character no-undo .
define variable IBM-good-code-2 as character no-undo .
define variable IBM2-short      as character no-undo .
define variable v-gds-null-price as character no-undo .

define variable iii as integer no-undo .
define variable v-mask-full as character no-undo .
define variable v-mask-short as character no-undo .
define variable vKKT as integer no-undo.
define variable attrValue as character no-undo.
define variable attrType  as character no-undo.

DEFine BUFFER BUF_BAR-CODE FOR UB.BAR-CODE.
define buffer buf_price-list for ub.price-list.
define buffer buf_price-doc-forming-gds FOR UB.PRICE-doc-forming-gds.
define buffer buf_temp-dis-gds-rule for temp-dis-gds-rule.
define buffer main-prt-bar-code  for ub.bar-code.
define buffer buf_goods-attr for goods-attr.
define buffer b-code for code.

&if  "{&called}" <> "send-codes-only" &then
/*цена нам не нужна если мы только создаем массив кодов*/

if action = "U" then do:
  if loc-bar-code.stts = Integer({&hn-switch-off}) then return.
    for-price = ?.
    /*
    { gbl/pftxvalg.i loc-goods.gds-code {&vat-tax-code} ? parhost-code parobj-type parobj-code vat-value no-error }
    { gbl/pftxvalg.i loc-goods.gds-code {&slt-tax-code} ? parhost-code parobj-type parobj-code slt-value no-error }
    */
    /*пока поле нигде не используется*/

&if  "{&called}" = "in-ov" &then
    assign
    for-price = ub.price-list.price-sale no-error.
    { str/sendbctr.i }
&else
    { gbl/bcodeprc.i
      {&shop}
      ub.shop.obj-code
      loc-bar-code.b-code
      main-b-code
      0
      v-doc-num
      for-price
      for-road
      for-excise
      no-error
    }
&endif
    if error-status:error then do:
&if  "{&called}" = "in-ov" &then
        return error.
&else
        if g#news
        or g#auto
        or g#esys
        then return error.
        else do:
            error-status:error = no.
            message "Ошибка при определении цены на товар "
                    loc-goods.artic loc-goods.prod-type loc-goods.prod-code
            view-as alert-box ERROR.
            return.
        end.
&endif
    end.
    if return-value = "error" then do:
        if for-price = ? then do:
          return.
        end.
        if not g#news
        and not g#auto
        and not g#esys
        then
        message prichina view-as alert-box ERROR.
        return error.
    end.
    else if (for-price = ? or for-price = 0) then do:
      if v-is-restaurant and v-is-null-price  then do:
        assign
        for-price = 0.
      end.
      else do:
        run gds-attr-value in this-procedure  ( input loc-goods.gds-code
                                               ,input {&attr-null-price}
                                               ,output v-gds-null-price
                                               ,output v-type) no-error.  
        if (not logical(v-gds-null-price) and for-price = 0) or for-price = ? then 
        return "NEXT".
      end.
    end.
  end. /*добавление на кассу*/
  else do:
        /*удаление с кассы*/
        for-price = 0.
  end.
&if  "{&called}" = "in-ov" &then
for-price =  (if loc-bar-code.unit-cli = plist-unit-cli
              then
              for-price
              else
              round-m( loc-bar-code.cli-base-rate * for-price, rnd-znak)
              ).
&else
for-price = round-m( for-price , rnd-znak ).
&endif
&endif /*&if  "{&called}" <> "send-codes-only" &then */
FIND FIRST cash-gds where cash-gds.crf = (cr + 1) No-ERROR.
start-paket = no.
if not avail cash-gds then do:
create cash-gds.
error-status:error = false.
end.
cash-gds.crf = cr + 1.
cr = cr + 1.
if loc-bar-code.in-code <> ''
or loc-bar-code.part-code <> ''
then do:
  find first main-prt-bar-code no-lock where
            main-prt-bar-code.gds-code = loc-goods.gds-code
        and main-prt-bar-code.node-code = loc-bar-code.node-code
        and main-prt-bar-code.unit-cli = loc-bar-code.unit-cli
        and main-prt-bar-code.part-code = ''
        and main-prt-bar-code.in-code = '' no-error.
  if available main-prt-bar-code then do:
    v-main-prt-b-code = main-prt-bar-code.b-code.
  end.
end.
else do:
  v-main-prt-b-code = loc-bar-code.b-code.
end.
find first tt-tax no-lock where
           tt-tax.tax-code = vattaxcd no-error .
do iii = 1 to num-entries(mask_s-c) :
  assign
    v-mask-full  = trim(entry(iii, mask_s-c))
    v-mask-short = entry(1, v-mask-full, "*")
    loc-prod-bc  = trim(loc-prod-bc)
  .
  if length(v-mask-full) = length(loc-prod-bc) and  substring(loc-prod-bc, 1, length(v-mask-short)) = v-mask-short then
    loc-prod-bc = "*" + substring(loc-prod-bc, length(v-mask-short) + 1).
end.
define variable vBc-on as logical no-undo.
if loc-prod-bc ne ? 
then do:
    find first prod-bc where prod-bc.b-code eq loc-bar-code.b-code
                         and prod-bc.b-str  eq loc-prod-bc
                         no-lock no-error.
    if available prod-bc
    then
       vBc-on = prod-bc.bc-on.
    else
       vBc-on = yes.
end.
else
   vBc-on = yes.
run gdsoattr-value in this-procedure (
  {&attr-dt-seasons},
  loc-goods.gds-code,
  parobj-type,
  parobj-code,
  output attrValue,
  output attrType
) no-error.
if attrValue <> "" then do:
  find first b-code where
             b-code.parent = "DTSeasons"
         and b-code.code   = attrValue
       no-lock no-error.
  v-main-prt-b-code = integer(b-code.code).
end.
else release b-code.

assign
cash-gds.gds-code = loc-goods.gds-code
cash-gds.artic = loc-goods.artic
cash-gds.b-code = loc-bar-code.b-code
cash-gds.main-prt-b-code = v-main-prt-b-code
/*если loc-prod-bc <> значит это для prod-bc*/
cash-gds.b-str = if loc-prod-bc = ? then "" else loc-prod-bc
cash-gds.bc-on-type = loc-bc-on-type
cash-gds.bc-on = vBc-on
cash-gds.unit-cli = loc-bar-code.unit-cli
cash-gds.cli-base-rate = loc-bar-code.cli-base-rate
cash-gds.std-discnt-rule = std-discnt-rule_
cash-gds.gds-namelong = loc-goods.gds-name
cash-gds.gds-name = IF nam-2str
                    then if available b-code then b-code.codename else loc-goods.gds-name
                    else (
                          IF nam-artc
                          then loc-goods.artic
                          else if available b-code 
                               then b-code.codename 
                               else (if loc-goods.chk-name <> ""
                                     then loc-goods.chk-name
                                     else loc-goods.gds-name)
                         )
                 
cash-gds.f-name = if NOT l-empty-scale then loc-gds-prt-term.f-name else ""
cash-gds.unit-base = loc-goods.unit-base
cash-gds.grp-code = for-grp-code
cash-gds.fp = for-fp
cash-gds.ingredient = loc-goods.struct
cash-gds.producer = for-producer
cash-gds.producer-int = for-producer-int
cash-gds.alpha1     = loc-goods.alpha1.

  run gds-attr-value in this-procedure  ( input cash-gds.gds-code
                                         ,input {&attr-office-type}
                                         ,output v-oss
                                         ,output v-type) no-error.
cash-gds.office-type = v-oss.

  run gds-attr-value in this-procedure  ( input cash-gds.gds-code
                                         ,input {&attr-type-method-calc}
                                         ,output v-oss
                                         ,output v-type) no-error.
                         
if v-oss <> "" then
  assign
    cash-gds.CalculationMethod = int(entry(1,v-oss,","))
    cash-gds.CalculationMethodRestr = if num-entries(v-oss,",") > 1 then int(entry(2,v-oss,",")) else 0
  .
else 
  assign
    cash-gds.CalculationMethod = 0
    cash-gds.CalculationMethodRestr = 0
  .
  
assign
cash-gds.fact-qnty = for-fact-qnty
cash-gds.okei = loc-bc-units-okei
cash-gds.kat-discnt-method = kat-discnt-method_
cash-gds.temp-discnt-method = temp-discnt-method_
cash-gds.kat-discnt-rule = (if how-pcnt-kat = {&dthbjr-pcnt-kat-pdf}
                             then  kat-discnt-rule_pdf
                             else  kat-discnt-rule_)
cash-gds.date-discnt-rule = date-discnt-rule_
cash-gds.abs-discnt-rule = abs-discnt-rule_
cash-gds.tot-discnt-rule = tot-discnt-rule_
cash-gds.wgd-rule = for-wgd
cash-gds.gds-stat = ( if lookup( {&weight}, loc-bc-units-cli-type ) > 0 OR lookup({&divisional}, loc-bc-units-cli-type) > 0
                        then 1
                        else 0)
/*теперь выяснилось что топливный для кассы только разливное топливо*/
cash-gds.gds-stat = (if (lookup({&petrolium}, loc-units.type) > 0 AND lookup({&divisional}, loc-units.type) > 0)
                     or for-petrol-purse
                     then (cash-gds.gds-stat + 8)
                     else cash-gds.gds-stat)
cash-gds.gds-stat = if (loc-goods.gds-type = {&gds-office} and (cash-gds.gds-stat < 8 or for-petrol-purse))
                    then (cash-gds.gds-stat + 16)
                    else cash-gds.gds-stat
cash-gds.gds-stat = if cash-gds.fp
                    then (cash-gds.gds-stat + 2)
                    else cash-gds.gds-stat
cash-gds.gds-stat = if cash-gds.wgd-rule > 0
                    then (cash-gds.gds-stat + 128)
                    else cash-gds.gds-stat
cash-gds.office = if loc-goods.gds-type = {&gds-office} then 1 else 0
cash-gds.temp-discnt-rule = (if how-temp-disc = {&dthbjr-temp-disc-pdf}
                             then temp-discnt-rule_pdf
                             else temp-discnt-rule_)
cash-gds.wd-rule = for-wd
cash-gds.pp = (if for-petrol-purse then 1 else 0)
cash-gds.need-auth = (if need-auth then 1 else 0)
cash-gds.price-sale =  for-price
cash-gds.unit-type = loc-units.type
cash-gds.unit-cli-type = loc-bc-units-cli-type
cash-gds.tax-string = tax-string
cash-gds.new-good = new-good
cash-gds.rc = recid(loc-goods)
cash-gds.qnty-discnt-rule = qnty-discnt-rule_
cash-gds.vat-pc = (if avail tt-tax
                   then tt-tax.rate-value
                   else 0)
cash-gds.vat-code = (if avail tt-tax
                     then tt-tax.rate-code
                     else ?)
cash-gds.is-menu  = (if v-is-menu then 1 else 0)
cash-gds.is-semi-finished = (if v-is-semi-finished then 1 else 0)
cash-gds.is-modificator = (if v-is-modificator then 1 else 0)
cash-gds.fbr-grp-code = v-fbr-grp-code
cash-gds.fbr-grp-code-0 = loc-goods.fbr-grp-code
cash-gds.DepartID = v-fbr-obj-code
cash-gds.zp = (if v-is-null-price then 1 else 0)
cash-gds.node-code = loc-bar-code.node-code
cash-gds.taracode = for-taracode
cash-gds.is-main-code = (if cash-gds.b-str = ""
                         and loc-bar-code.in-code = ""
                         and loc-bar-code.part-code = ""
                         and cash-gds.unit-base = cash-gds.unit-cli
                         then yes
                         else no)
cash-gds.obj-type = parobj-type
cash-gds.obj-code = parobj-code
.
assign
cash-gds.gds-name1 =   name-2cdf(
                      input name-2cd
                    , input yes /*по товару*/
                    , input cod-pcod
                    , input cash-gds.b-code
                    , input loc-goods.gds-code
                    , input loc-goods.artic
                    , input loc-goods.engl-name
                    , input loc-bar-code.in-code
                    , input loc-bar-code.part-code
                    , input parobj-type
                    , input parobj-code
                    , input loc-goods.alpha1
                    , output v-gtd
                    )
cash-gds.gtd   = v-gtd
.
vKKT = 255.
find first b-code where
           b-code.parent  = "okei-kkt"
       and b-code.code    = string(cash-gds.okei)
       and b-code.status_ = 0
no-lock no-error.
if avail b-code then
   vKKT = integer(b-code.CodeName) no-error.
if error-status:error then vKKT = 255.
cash-gds.kkt = vKKT.
if (lookup({&petrolium}, loc-units.type) > 0 AND lookup({&divisional}, loc-units.type) > 0) then do:
   /*проверим на газ*/
   run gds-attr-value in this-procedure  (
                                          input cash-gds.gds-code
                                         ,input {&attr-fuel-type}
                                         ,output v-is-gas
                                         ,output v-type) no-error.
   run gds-attr-value in this-procedure  (
                                          input cash-gds.gds-code
                                         ,input {&attr-ptrl-as-good}
                                         ,output v-ptrl-as-good
                                         ,output v-type) no-error.

   assign
   cash-gds.ptrl-as-good = logical(v-ptrl-as-good)
   no-error .
   assign
   cash-gds.is-gas = (v-is-gas = 'metan':U) 
   no-error .
   if cash-gds.is-gas then do:
     cash-gds.gds-stat = cash-gds.gds-stat + 64.
   end.
end.
/* товары-исключения */
   run gds-attr-value in this-procedure  (
                                          input cash-gds.gds-code
                                         ,input {&attr-ban-bonus}
                                         ,output v-ban-bonus
                                         ,output v-type) no-error.
  assign
   cash-gds.wd = int(logical(v-ban-bonus))
   no-error .                                       
if how-temp-disc = {&dGR-temp-disc} then do:
  case temp-discnt-method_:
    when "" then do:
    end.
    when "bar-code.b-code" then do:
      if loc-bar-code.in-code <> ''
      or loc-bar-code.part-code <> ''
      then do:
        disc-b-code = cash-gds.main-prt-b-code.
      end.
      else do:
        disc-b-code = cash-gds.b-code.
      end.
      find first buf_temp-dis-gds-rule where
              buf_temp-dis-gds-rule.gds-code = cash-gds.gds-code
          and buf_temp-dis-gds-rule.nonunique = string( disc-b-code) no-error.
      if available buf_temp-dis-gds-rule then do:
          cash-gds.temp-discnt-rule = buf_temp-dis-gds-rule.rule-num.
      end.
    end.
    otherwise do:
      cash-gds.temp-discnt-rule = 0.
    end.
  end.
end.
assign
cash-gds.gds-name1 =   name-2cdf(
                      input name-2cd
                    , input yes /*по товару*/
                    , input cod-pcod
                    , input cash-gds.b-code
                    , input loc-goods.gds-code
                    , input loc-goods.artic
                    , input loc-goods.engl-name
                    , input loc-bar-code.in-code
                    , input loc-bar-code.part-code
                    , input parobj-type
                    , input parobj-code
                    , input loc-goods.alpha1
                    , output v-gtd
                    )
cash-gds.gtd   = v-gtd
.

assign
cash-gds.ean-lz = ''
cash-gds.ean-rz = ''
cash-gds.code-short = ''
.
run ibm-gdsc in this-procedure (input no /*p-zeros*/
                              , output cash-gds.ean-lz
                              , output cash-gds.ean-rz
                              , output cash-gds.code-short
                              ) no-error .


if new-good then new-good = not new-good.
if action = "U" then do:
  if cash-gds.kat-discnt-rule <> 0
  and how-pcnt-kat = {&dthbjr-pcnt-kat-pdf}
  then do:
    for each cash-dis-rule no-lock where
          cash-dis-rule.upper-rule-num = cash-gds.kat-discnt-rule
    :
      /*получим % из соотношения cash-gds.price-sale и цены полученной из прайс-листа типа cash-dis-rule.charkey_one*/
      run mpl-tpl-auto in this-procedure ( input cash-gds.b-code
                                          ,input {&shop}
                                          ,input i-obj-code
                                          ,input integer(entry(1, cash-dis-rule.charkey_one,"-"))
                                          ,input integer(entry(2, cash-dis-rule.charkey_one,"-"))
                                          ,input ? /*fact-order*/
                                          ,output v-disc-price-sale
                                          ,output v-pdf-id
                                          ,output v-pdf-db-num ) no-error.
      if error-status:error
      or v-disc-price-sale = 0
      or v-disc-price-sale = ?
      then do:
        /*ничего*/
      end.
      else do:
        find first  cash-gds-discnt where
                  cash-gds-discnt.b-code = cash-gds.b-code
                and  cash-gds-discnt.rule-num = cash-dis-rule.rule-num
                and cash-gds-discnt.obj-type = parobj-type
                and cash-gds-discnt.obj-code = parobj-code No-ERROR.
        if not available cash-gds-discnt then do:
          find first  cash-gds-discnt where
                    cash-gds-discnt.crf = (crgd + 1) No-ERROR.
          if not available cash-gds-discnt then do:
            create cash-gds-discnt.
            assign
            cash-gds-discnt.crf = crgd + 1.
          end.
          crgd = crgd + 1.
          assign
          cash-gds-discnt.b-code = cash-gds.b-code
          cash-gds-discnt.rule-num = cash-dis-rule.rule-num
          cash-gds-discnt.obj-type = parobj-type
          cash-gds-discnt.obj-code = parobj-code
          cash-gds-discnt.discnt-value = v-disc-price-sale
          .
          release cash-gds-discnt.
        end.
      end.
    end. /*for each cash-dis-rule no-lock where*/
  end.
  if cash-gds.temp-discnt-rule <> 0
  and how-temp-disc = {&dthbjr-temp-disc-pdf}
  then do:
    for each cash-dis-rule no-lock where
          (cash-dis-rule.upper-rule-num = cash-gds.temp-discnt-rule
      or cash-dis-rule.rule-num = cash-gds.temp-discnt-rule)
      and cash-dis-rule.is-term = yes
    :
      /*получим % из соотношения cash-gds.price-sale и цены полученной из прайс-листа типа cash-dis-rule.charkey_one*/
      run mpl-tpl-auto in this-procedure ( input cash-gds.b-code
                                          ,input {&shop}
                                          ,input i-obj-code
                                          ,input integer(entry(1, cash-dis-rule.charkey_one,"-"))
                                          ,input integer(entry(2, cash-dis-rule.charkey_one,"-"))
                                          ,input ? /*fact-order*/
                                          ,output v-disc-price-sale
                                          ,output v-pdf-id
                                          ,output v-pdf-db-num ) no-error.
      if error-status:error
      or v-disc-price-sale = 0
      or v-disc-price-sale = ?
      then do:
        /*ничего*/
      end.
      else do:
        find first  cash-gds-discnt where
                  cash-gds-discnt.b-code = cash-gds.b-code
                and  cash-gds-discnt.rule-num = cash-dis-rule.rule-num
                and cash-gds-discnt.obj-type = parobj-type
                and cash-gds-discnt.obj-code = parobj-code No-ERROR.
        if not available cash-gds-discnt then do:
          find first  cash-gds-discnt where
                    cash-gds-discnt.crf = (crgd + 1) No-ERROR.
          if not available cash-gds-discnt then do:
            create cash-gds-discnt.
            assign
            cash-gds-discnt.crf = crgd + 1.
          end.
          crgd = crgd + 1.
          assign
          cash-gds-discnt.b-code = cash-gds.b-code
          cash-gds-discnt.rule-num = cash-dis-rule.rule-num
          cash-gds-discnt.obj-type = parobj-type
          cash-gds-discnt.obj-code = parobj-code
          cash-gds-discnt.discnt-value = v-disc-price-sale.
          release cash-gds-discnt.
        end.
      end.
    end. /*for each cash-dis-rule no-lock where*/
  end.
end. /*if action = "U" then do:*/



END PROCEDURE.
/* $Workfile$ e n d */