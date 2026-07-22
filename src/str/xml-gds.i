/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Выгрузка на кассу XML

Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/18/03
Author: Bakhtadze Natalya
Creation date: 08/18/03

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define variable i-entry as integer no-undo .
define variable v-attr-value as character no-undo .
define variable v-attr-egais as integer no-undo .
define variable v-attr-sale-trk as character no-undo .
define variable v-attr-type as character no-undo .
define buffer buf_cash-gds for cash-gds.
define buffer buf_goods-attr for ub.goods-attr.
define buffer buf_gds-obj-attr for ub.gds-obj-attr.
define buffer buf_alc-type  for ub.alc-type.
define buffer buf_alc-type-gds for ub.alc-type-gds.
define buffer buf_bar-code for ub.bar-code .
define buffer buf_bar-code_cl for ub.bar-code .
define buffer buf_ext-classif for ub.ext-classif .
define variable v-IBCType as integer no-undo .
define variable v-mark  as logical no-undo initial no.
define variable v-attr-emrc as character no-undo.
define variable v-cli-base  as character initial "".
define variable v-i-cli     as integer no-undo .
define variable v-i-cli-qnty     as dec no-undo .
define variable v-dop-alt-name as character no-undo.
define variable vGdsTabak as logical no-undo.
{ gbl/objsrv.i }
define variable MarkType as ibs.th.str.marking.Types no-undo.
MarkType = ObjSrv:Env:Marking:Types.

define buffer buf_prod-bc-attr for ub.prod-bc-attr .
define buffer buf_prod-bc for ub.prod-bc .
define buffer     prod-bc for ub.prod-bc .
define buffer buf_goods   for ub.goods .
define variable vaction as character no-undo.
define variable d_action as character no-undo.
vaction = action.
d_action = "".
find first buf_goods no-lock where buf_goods.gds-code = cash-gds.gds-code no-error .
if available (buf_goods) and buf_goods.stts > 0 then do:
 vaction = "D".
 d_action = "D".
end.
if check-ban-sales-via-cd(cash-gds.gds-code) 
then do:
   vaction = "D".
end.
&if "{1}" <> "7" &then
if vaction = 'U':U then do:
  run bgelib-tag-open in this-procedure ( input 2, input "Producer", input substitute("ctrl='&1' tms='&2' code='&3'", 'ADD':u, OS2-time, cash-gds.producer-int)).
  run bgelib-tag-put in this-procedure ( input 3, input "ProducerName"  , input trim(cash-gds.producer), input 1 ).
  run bgelib-tag-close in this-procedure ( input 2, input "Producer").
end.
&endif

&if "{&called}" = "in-ov" &then
  if vaction = "D":U then do:
    run bgelib-tag-open in this-procedure ( input 2, input "Item", input substitute("ctrl='&1' tms='&2' code='&3'", 'LOCK':u, OS2-time, cash-gds.main-prt-b-code)).
    run bgelib-tag-put in this-procedure ( input 3, input "ItemLock"  , input string(1), input 1 ).
  end.
  else do:
    run bgelib-tag-open in this-procedure ( input 2, input "Item", input substitute("ctrl='&1' tms='&2' code='&3'", 'ADD':u, OS2-time, cash-gds.main-prt-b-code)).
    run bgelib-tag-put in this-procedure ( input 3, input "ItemLock"  , input string(1), input 1 ).
  end.

&else


/*если удаляется prod-bc то Item удалять не надо
если удаляется bar-code то  Item удалять надо!!
*/
  &if "{&called}"  =  "s-prodbc" or "{&called}" = "s-prodbcn"  or "{&called}"  =  "send-bc" or "{&called}" = "send-bcn" &then

  run bgelib-tag-open in this-procedure ( input 2, input "Item", input substitute("ctrl='&1' tms='&2' code='&3'"
                                        ,(if d_action <> "D" then "ADD":U else "DEL":U), OS2-time, cash-gds.main-prt-b-code)).
  d_action = "". 

  &else
  run bgelib-tag-open in this-procedure ( input 2, input "Item", input substitute("ctrl='&1' tms='&2' code='&3'",
                                        (if
                                        vaction = "U"
                                        then "ADD":U
                                        else "DEL":U), OS2-time, if cash-gds.ean-lz          = "*" and cash-gds.main-prt-b-code = ? then "*" else string(cash-gds.main-prt-b-code))).
  &endif
&endif

&if "{1}" <> "7" &then
if vaction = "U":U then do:

    for first ub.gds-obj-attr no-lock where ub.gds-obj-attr.attr-code = "dop-alt-name-o"
                                                   and ub.gds-obj-attr.gds-code = cash-gds.gds-code
                                                   and ub.gds-obj-attr.obj-code = cash-gds.obj-code
                                                   and ub.gds-obj-attr.obj-type = cash-gds.obj-type :
        v-dop-alt-name = ub.gds-obj-attr.attr-value .
    end.                                                       
                      
  run bgelib-tag-put in this-procedure ( input 3, input "ItemName"       , input string(trim(chk_name, {&space-char}) + v-dop-alt-name), input 1 ).
  run bgelib-tag-put in this-procedure ( input 3, input "ItemAltName"    , input trim(second-name, {&double-quote}), input 1 ).
  run bgelib-tag-put in this-procedure ( input 3, input "ItemMainPrice"  , input string( cash-gds.price-sale ), input 1 ).
  run bgelib-tag-put in this-procedure ( input 3, input "ItemMasterCode"  , input string( cash-gds.gds-code), input 1 ).
  run bgelib-tag-put in this-procedure ( input 3, input "ItemDisc"  , input string( std-disc-dec), input 1 ).
  run bgelib-tag-put in this-procedure ( input 3, input "ItemDiscReason"  , input string( std-disc-reason), input 1 ).
  if pos-type <> {&cd-type-infokiosk} then do:
    run bgelib-tag-put in this-procedure ( input 3, input "ItemOKEI"         , input string( cash-gds.okei), input 1 ).
    run bgelib-tag-put in this-procedure ( input 3, input "ItemKKTEICode"    , input string( cash-gds.kkt), input 1 ).
  end.
  run bgelib-tag-put in this-procedure ( input 3, input "ItemMeasure"      , input string( cash-gds.unit-cli), input 1 ).
  find first buf_goods-attr where buf_goods-attr.gds-code = cash-gds.gds-code 
                              and buf_goods-attr.attr-code = "item-matter-mark" no-error.
  run bgelib-tag-put in this-procedure ( input 3, input "ItemMatterMark"  , if available buf_goods-attr then buf_goods-attr.attr-value else "" , input 1 ).

  define buffer bb_goods for ub.goods.
  define variable vVal as character no-undo .
  define variable vType as character no-undo .
  
   find FIRST buf_goods-attr where buf_goods-attr.gds-code = cash-gds.gds-code and buf_goods-attr.attr-code = "image-list" no-error.
	if available buf_goods-attr then do:
     vVal = entry(1,buf_goods-attr.attr-value).    
	end.
  if pos-type = {&cd-type-infokiosk} then do:
    find first bb_goods no-lock where bb_goods.gds-code = cash-gds.gds-code.
                      
    run bgelib-tag-put in this-procedure ( input 3, input "ItemNameLong"  , input string( bb_goods.gds-name), input 1 ).
    run bgelib-tag-put in this-procedure ( input 3, input "ItemDetails"    , input string( bb_goods.Ps ), input 1 ).

    run bgelib-tag-put in this-procedure ( input 3, input "ItemPhoto"    , input string( entry(1,vVal)), input 1 ).
    run bgelib-tag-put in this-procedure ( input 3, input "ItemGroupBO"  , input string( bb_goods.grp-code ), input 1 ).
    run bgelib-tag-put in this-procedure ( input 3, input "ItemSizeColorCode" , input string( cash-gds.node-code), input 1 ).
    run bgelib-tag-put in this-procedure ( input 3, input "ItemAttributes" , input string( bb_goods.attrib), input 1 ).

    run bgelib-tag-put in this-procedure ( input 3, input "ItemDestination" , input string( bb_goods.destin), input 1 ).
    run bgelib-tag-put in this-procedure ( input 3, input "ItemSert" , input string( bb_goods.sert), input 1 ).
    run bgelib-tag-put in this-procedure ( input 3, input "ItemDeadLine" , input string( bb_goods.deadline), input 1 ).

    run bgelib-tag-put in this-procedure ( input 3, input "ItemUserRules" , input string( bb_goods.user-rule), input 1 ).
    run bgelib-tag-put in this-procedure ( input 3, input "ItemStructure" , input string( bb_goods.struct), input 1 ).
    run bgelib-tag-put in this-procedure ( input 3, input "ItemSort" , input string( bb_goods.sort), input 1 ).
    run bgelib-tag-put in this-procedure ( input 3, input "ItemUnitWeight" , input string( bb_goods.wt-cart), input 1 ).
    run bgelib-tag-put in this-procedure ( input 3, input "ItemUnitVolume" , input string( bb_goods.ms-cart), input 1 ).
    run bgelib-tag-put in this-procedure ( input 3, input "ItemCountry" , input string( cash-gds.alpha1), input 1 ).
   
    
  end.
  else do: /*не инфокиоск*/
  
find first buf_gds-obj-attr where buf_gds-obj-attr.gds-code = cash-gds.gds-code 
                              and buf_gds-obj-attr.obj-code = cash-gds.obj-code
                              and buf_gds-obj-attr.obj-type = cash-gds.obj-type
                              and buf_gds-obj-attr.attr-code = "sum-grp" no-error.
  if available buf_gds-obj-attr then do:               
  v-attr-value = buf_gds-obj-attr.attr-value .
  end.  
else do:
find first buf_goods-attr where buf_goods-attr.gds-code = cash-gds.gds-code and buf_goods-attr.attr-code = "sum-grp-gl" no-error.
  if available buf_goods-attr then do:
  v-attr-value = buf_goods-attr.attr-value .
  end.
end.                            
    run gds-attr-value in this-procedure (
                                 input cash-gds.gds-code
                                ,input {&attr-ptrl-as-good}
                                ,output v-attr-sale-trk
                                ,output v-attr-type) no-error.
    /* Режим отдельных поддиректорий для каждого товара */
define variable v-param-types   as character  no-undo.
define variable v-value-char    as character  no-undo.
define variable v-val-date      as date       no-undo.
define variable v-val-decimal   as decimal    no-undo.
define variable v-val-integer   as integer    no-undo.
define variable v-val-logical   as logical    no-undo.
define variable v-tthd          as handle     no-undo.

if  vVal <> "" and v-val-integer = 0 then do:
        run adm/shattri.p (
        input "get":U
        ,input  '':U /*p-obj-type*/
        ,input  0 /*p-obj-code*/
        ,input  {&attr-gds-ref}
        ,input  {&attr-gds-ref_shema-foto} /*p-param-code*/
        ,output v-value-char
        ,output v-val-date
        ,output v-val-decimal
        ,output v-val-integer
        ,output v-val-logical
        ,output v-param-types
        ,INPUT-OUTPUT table-handle v-tthd
        ) no-error.
        delete object v-tthd.
end.        
    /* {gbl/conf-rd.i "'photomgd':u"  "'':u" "'':u" 0 "'':u" "'':u" "'':u" no vPar-val vPar-type no-error}  */
        
    run bgelib-tag-put in this-procedure ( input 3, input "ItemGroup"      , input string( if v-attr-value = "" then string(cash-gds.grp-code) else v-attr-value ), input 1 ).
    run bgelib-tag-put in this-procedure ( input 3, input "ItemShop"      , input string( i-obj-code ), input 1 ).
    if v-val-integer = 1 and vVal <> "" then do:
        run bgelib-tag-put in this-procedure ( input 3, input "ItemImage"    , input string( entry(1,vVal)), input 1 ).
    end.
    if v-val-integer = 2 and vVal <> "" then do:
        run bgelib-tag-put in this-procedure ( input 3, input "ItemImage"    , input string(string(cash-gds.gds-code) + "/" + entry(1,vVal)), input 1 ).
    end. 
    if cash-gds.CalculationMethod > 0 then 
    do: 
        run bgelib-tag-put in this-procedure ( input 3, input "ItemCalculationMethod" ,
                                              input string(cash-gds.CalculationMethod), input 1 ).
        run bgelib-tag-put in this-procedure ( input 3, input "ItemCalculationMethodRestr" ,
                                              input if cash-gds.CalculationMethodRestr > 0 then string(cash-gds.CalculationMethodRestr) else "", input 1 ).
    end.
    /*статус*/
    run bgelib-tag-open in this-procedure ( input 3, input "ItemStatus", input "" ).
    run bgelib-tag-put in this-procedure ( input 4, input "ISWeight" ,
                                          input string(if LOOKUP( {&weight}, cash-gds.unit-cli-type  ) > 0
                                                       or LOOKUP( {&divisional}, cash-gds.unit-cli-type  ) > 0
                                                       then 1 else 0), input 1 ).
    run bgelib-tag-put in this-procedure ( input 4, input "ISFuel" ,
                                          input string(if (LOOKUP({&petrolium}, cash-gds.unit-cli-type) > 0
                                                        and LOOKUP({&divisional}, cash-gds.unit-cli-type) > 0)
                                                        or cash-gds.pp > 0
                                                        or (v-attr-sale-trk = "yes" and LOOKUP({&divisional}, cash-gds.unit-cli-type) > 0)
                                                        then 1
                                                        else 0), input 1 ).
    /*run bgelib-tag-put in this-procedure ( input 4, input "ISAuthorize" ,
                                          input string(cash-gds.pp), input 1 ).*/
    run bgelib-tag-put in this-procedure ( input 4, input "ISAuthorize" ,
                                          input string(cash-gds.need-auth), input 1 ).
    run bgelib-tag-put in this-procedure ( input 4, input "ISFreePrice" ,
                                            input string(if cash-gds.fp then 1 else 0), input 1 ).
    run bgelib-tag-put in this-procedure ( input 4, input "ISNullPrice" ,
                                            string(cash-gds.zp), input 1 ).
    run bgelib-tag-put in this-procedure ( input 4, input "ISNoTotalDisc" ,
                                          input string(if cash-gds.wd > 0 then wd-option else 0), input 1 ).
    run bgelib-tag-put in this-procedure ( input 4, input "ISService" ,
                                          input string(cash-gds.office), input 1 ).
    find first ub.OperServ no-lock where ub.OperServ.gds-code = cash-gds.gds-code no-error .     
    if available (ub.OperServ) then do:                                     
    run bgelib-tag-put in this-procedure ( input 4, input "ISComplex" ,
                                          input string(1), input 1 ).
    end.
    else do:
    run bgelib-tag-put in this-procedure ( input 4, input "ISComplex" ,
                                          input string(0), input 1 ).
    end.                                            
    run bgelib-tag-put in this-procedure ( input 4, input "ISActivate" ,
                                          input (if cash-gds.office-type = {&attr-office-type_card-act} then string(1) else string(0)), input 1 ).
    run bgelib-tag-put in this-procedure ( input 4, input "ISNoDiscount" ,
                                            input string(if cash-gds.wgd > 0 then wgd-option else 0), input 1 ).
    run bgelib-tag-put in this-procedure ( input 4, input "ISGaz" ,
                                            input string(if cash-gds.is-gas then 1 else 0), input 1 ).
    run bgelib-tag-put in this-procedure ( input 4, input "ISFuelAsUnit" ,
                                            input string(if cash-gds.ptrl-as-good then 1 else 0), input 1 ).

/*IS18*/
  find first buf_goods-attr where buf_goods-attr.gds-code = cash-gds.gds-code 
         and buf_goods-attr.attr-code = "IS18Plus" 
         and buf_goods-attr.attr-value = "1"
         no-lock no-error. 
  if available buf_goods-attr then do:   
      run bgelib-tag-put in this-procedure ( input 4, input "IS18Plus", input 1, input 1 ). 
  end.

/*  if not available buf_goods-attr then do:   
      run bgelib-tag-put in this-procedure ( input 4, input "IS18Plus", input 0, input 1 ). 
  end. */


/* Оплата баллами Семейная команда */ 
  find first buf_goods-attr where buf_goods-attr.gds-code = cash-gds.gds-code 
         and buf_goods-attr.attr-code = "loyalty-gift" 
         and buf_goods-attr.attr-value = "1"
         no-lock no-error. 
  if available buf_goods-attr then do:   
      run bgelib-tag-put in this-procedure ( input 4, input "ItemLoyaltyGift", input 1, input 1 ). 
  end.


/*Алкоголь*/

  find first buf_goods-attr where buf_goods-attr.gds-code = cash-gds.gds-code and buf_goods-attr.attr-code = "alcohol-prod" no-lock no-error. 
  if available buf_goods-attr then do:   
  v-attr-egais = 1.
  find first buf_goods-attr where buf_goods-attr.gds-code = cash-gds.gds-code and buf_goods-attr.attr-code = "mark" no-lock no-error. 
    if available buf_goods-attr and buf_goods-attr.attr-value = "no" then  do: 
      run bgelib-tag-put in this-procedure ( input 4, input "ISEgaisNoPDF", input 1, input 1 ). 
    end. 
    if available buf_goods-attr and buf_goods-attr.attr-value = "yes" then  do:
      run bgelib-tag-put in this-procedure ( input 4, input "ISEgaisPDF"      , input 1, input 1 ).
    end.  
    if not available buf_goods-attr then do:
      run bgelib-tag-put in this-procedure ( input 4, input "ISEgaisNoPDF", input 1, input 1 ).
    end.  
  end.  
  
  find first buf_goods-attr where buf_goods-attr.gds-code = cash-gds.gds-code 
                              and buf_goods-attr.attr-code = "time-coock" 
                              and buf_goods-attr.attr-value = "yes" no-lock no-error. 
  if available buf_goods-attr then do:   
      run bgelib-tag-put in this-procedure ( input 4, input "ISCookStumped", input 1, input 1 ).
  end.  
  
      run bgelib-tag-close in this-procedure ( input 3, input "ItemStatus").
  end. /*не инфокиоск*/

  /*ночная скидка*/
  if cash-gds.temp-discnt-rule <> 0 then do:
    find first cash-dis-rule no-lock where
              cash-dis-rule.rule-num = cash-gds.temp-discnt-rule no-error .
    if available cash-dis-rule then do:
      for each buf_cash-dis-rule no-lock where
              (cash-dis-rule.is-term = yes
              and buf_cash-dis-rule.rule-num = cash-gds.temp-discnt-rule)
            or
            buf_cash-dis-rule.upper-rule-num = cash-gds.temp-discnt-rule,
        first cash-dis-time-rule no-lock where
                  cash-dis-time-rule.time-rule-num = buf_cash-dis-rule.time-rule-num:
        if buf_cash-dis-rule.is-term
        and buf_cash-dis-rule.root then do:
          /*ничего не находим все уже получили ранее в  p u t c - g d s .i */
        end.
        else do:
          case buf_cash-dis-rule.value-type:
            when integer({&discnt-v-pcnt}) then do:
              assign
              temp-disc-dec = - buf_cash-dis-rule.discnt-value
              .
            end.
            when integer({&discnt-v-pdf-pcnt}) then do:
              find first cash-gds-discnt where
                        cash-gds-discnt.b-code = cash-gds.b-code
                    and  cash-gds-discnt.rule-num = buf_cash-dis-rule.rule-num
                    and cash-gds-discnt.obj-type = {&shop}
                    and cash-gds-discnt.obj-code = i-obj-code
                    no-error.
              if available cash-gds-discnt then do:
                assign
                temp-disc-dec = - (cash-gds.price-sale - cash-gds-discnt.discnt-value) /  cash-gds.price-sale * 100
                .
              end.
              else do:
                assign
                temp-disc-dec = 0.
              end.
            end.
            otherwise do:
              temp-disc-dec = 0.
            end.
          end case.
        end.
        assign
        temp-disc-reason = 0
        temp-disc-weekday = 0
        no-error
        .
        assign
        temp-disc-start = cash-dis-time-rule.date-from
        temp-disc-end   = cash-dis-time-rule.date-to
        temp-disc-time-start = (if cash-dis-time-rule.time-from >= 0 then cash-dis-time-rule.time-from else 0)
        temp-disc-time-end = (if cash-dis-time-rule.time-to >= 0 then cash-dis-time-rule.time-to else 0)
        temp-disc-weekday = (if cash-dis-time-rule.week-day-1 then 1 else 0) +
                            (if cash-dis-time-rule.week-day-2 then 2 else 0) +
                            (if cash-dis-time-rule.week-day-3 then 3 else 0) +
                            (if cash-dis-time-rule.week-day-4 then 4 else 0) +
                            (if cash-dis-time-rule.week-day-5 then 5 else 0) +
                            (if cash-dis-time-rule.week-day-6 then 6 else 0) +
                            (if cash-dis-time-rule.week-day-7 then 7 else 0)
        .
        if temp-disc-end <> 12/31/1989 and temp-disc-end < today then
        assign
        temp-disc-dec = 0
        temp-disc-reason = 0
        temp-disc-weekday = 0
        temp-disc-time-start = 0
        temp-disc-time-end = 0
        temp-disc-start = 12/31/1989
        temp-disc-end = {&end-of-age}
        .
        run bgelib-tag-open in this-procedure ( input 3, input "ItemTimeDisc", input "" ).
        run bgelib-tag-put in this-procedure ( input 4, input "ITDEvery"     , input string(temp-disc-weekday), input 1 ).
        run bgelib-tag-put in this-procedure ( input 4, input "ITDValue" , input string(temp-disc-dec), input 1 ).
        if temp-disc-start <> ? then
        run bgelib-tag-put in this-procedure ( input 4, input "ITDBeg" , input Xml-CD-DateTimetoString(temp-disc-start, temp-disc-time-start), input 1 ).
        if temp-disc-end <> ? then
        run bgelib-tag-put in this-procedure ( input 4, input "ITDEnd" , input Xml-CD-DateTimetoString(temp-disc-end, temp-disc-time-end), input 1 ).
        run bgelib-tag-put in this-procedure ( input 4, input "ITDReason" , input string(temp-disc-reason), input 1 ).
        run bgelib-tag-close in this-procedure ( input 3, input "ItemTimeDisc").
      end. /*for each buf_cash-dis-rule no-lock where*/
    end. /*avail cash-dis-rule*/
  end. /*if cash-gds.temp-discnt-rule <> 0 then do:*/
  else do:
      run bgelib-tag-open in this-procedure ( input 3, input "ItemTimeDisc", input "" ).
      run bgelib-tag-close in this-procedure ( input 3, input "ItemTimeDisc").
  end.

  &endif

  /*скидки на колво*/
  if cash-gds.qnty-discnt-rule <> 0 then do:
    for each cash-dis-rule no-lock where
            cash-dis-rule.upper-rule-num = cash-gds.qnty-discnt-rule
      :
      run bgelib-tag-open in this-procedure ( input 3, input "ItemQtyDisc", input "" ).
      run bgelib-tag-put in this-procedure ( input 4, input "IQty", input string(cash-dis-rule.doc-qnty / cash-gds.cli-base-rate), input 1 ).
      run bgelib-tag-put in this-procedure ( input 4, input "IQPercent" , input string(- cash-dis-rule.discnt-value),  input 1 ).
      if v-version-dec >= 1.09 then do:
          run bgelib-tag-put in this-procedure ( input 4, input "IQType"
                                              , input string(if cash-dis-rule.value-type = integer({&discnt-v-abs})
                                                              then 1
                                                              else 0)
                                                , input 1 ).
          run bgelib-tag-put in this-procedure ( input 4, input "IQPayRestriction"
                                               , input string(if cash-dis-rule.templ-rl-root = 73
                                                              or cash-dis-rule.templ-rl-root = 74
                                                              then cash-dis-rule.key#_one
                                                              else 0
                                                              ),  input 1 ).
      end.
      run bgelib-tag-close in this-procedure ( input 3, input "ItemQtyDisc").
    end.
  end.
  else do:
    run bgelib-tag-open in this-procedure ( input 3, input "ItemQtyDisc", input "" ).
    run bgelib-tag-close in this-procedure ( input 3, input "ItemQtyDisc").
  end.


  /*кат скидок*/

  if cash-gds.kat-discnt-rule <> 0  then do:
    for each cash-dis-rule no-lock where
            cash-dis-rule.upper-rule-num = cash-gds.kat-discnt-rule   :
      run bgelib-tag-open in this-procedure ( input 3, input "ItemDisCat", input "" ).
      run bgelib-tag-put in this-procedure ( input 4, input "IDCCat" ,  input string(cash-dis-rule.dis-kat), input 1 ).
      if cash-dis-rule.templ-rl-root = 34 then do:
        /*используется поправочный коэффициент и предел скидки*/
        run bgelib-tag-put in this-procedure ( input 4, input "IDCMode" , input string(5), input 1 ).
        run bgelib-tag-put in this-procedure ( input 4, input "IDCLimit", input string(- cash-dis-rule.discnt-value),  input 1 ).
        run bgelib-tag-put in this-procedure ( input 4, input "IDCFactor", input string(cash-dis-rule.tot-sum),  input 1 ).
      end.
      else do:
        /*используется abd или % скидки*/
        case cash-dis-rule.value-type:
          when integer({&discnt-v-abs}) then do:
            run bgelib-tag-put in this-procedure ( input 4, input "IDCMode" , input string(2), input 1 ).
            run bgelib-tag-put in this-procedure ( input 4, input "IDCValue", input string(- cash-dis-rule.discnt-value * cash-gds.cli-base-rate),  input 1 ).
          end.
          when integer({&discnt-v-pcnt}) then do:
            run bgelib-tag-put in this-procedure ( input 4, input "IDCMode" , input string(1), input 1 ).
            run bgelib-tag-put in this-procedure ( input 4, input "IDCPercent", input string(- cash-dis-rule.discnt-value),  input 1 ).
          end.
          when integer({&discnt-v-FP}) then do:
            run bgelib-tag-put in this-procedure ( input 4, input "IDCMode" , input string(3), input 1 ).
            run bgelib-tag-put in this-procedure ( input 4, input "IDCPrice", input string(cash-dis-rule.discnt-value),  input 1 ).
          end.
          when integer({&discnt-v-pdf-FP}) then do:
            find first cash-gds-discnt where
                      cash-gds-discnt.b-code = cash-gds.b-code
                  and  cash-gds-discnt.rule-num = cash-dis-rule.rule-num
                and cash-gds-discnt.obj-type = {&shop}
                and cash-gds-discnt.obj-code = i-obj-code
                  no-error.
            if available cash-gds-discnt then do:
              assign
              v-kat-discnt = cash-gds-discnt.discnt-value
              .
            end.
            else do:
              v-kat-discnt = cash-gds.price-sale.
            end.
            run bgelib-tag-put in this-procedure ( input 4, input "IDCMode" , input string(3), input 1 ).
            run bgelib-tag-put in this-procedure ( input 4, input "IDCPrice", input string(v-kat-discnt),  input 1 ).
          end.
        end case.
      end.
      run bgelib-tag-close in this-procedure ( input 3, input "ItemDisCat").
    end. /*for each cash-dis-rule no-lock where*/
  end.
  else do:
    run bgelib-tag-open in this-procedure ( input 3, input "ItemDisCat", input "" ).
    run bgelib-tag-close in this-procedure ( input 3, input "ItemDisCat").
  end.



if pos-type <> {&cd-type-infokiosk} then do:
    &if "{1}" <> "7" &then
      if tax-cass
      AND vaction = "U" then do:
        do i-entry = 1 to num-entries(cash-gds.tax-string, {&space-char}):
          if entry(i-entry, cash-gds.tax-string, {&space-char}) <> "":U then do:
            run bgelib-tag-open in this-procedure ( input 3, input "ItemTax", input "" ).
            run bgelib-tag-put in this-procedure ( input 4, input "ITCode"  , input entry(i-entry, cash-gds.tax-string, {&space-char}), input 1 ).
            run bgelib-tag-close in this-procedure ( input 3, input "ItemTax").
          end.
        end.
      end.
    end.
    &endif
end.
run gds-attr-value in this-procedure (
                                 input cash-gds.gds-code
                                ,input {&attr-emrc-type}
                                ,output v-attr-emrc
                                ,output v-attr-type) no-error.
run bgelib-tag-put in this-procedure ( input 3, input "Item_EMRC"  , input v-attr-emrc , input 1 ).
vGdsTabak = if vaction = "D" then yes else no.
find first buf_goods-attr where buf_goods-attr.gds-code = cash-gds.gds-code 
              and buf_goods-attr.attr-code  = {&attr-mark-type} and buf_goods-attr.attr-value <> "not-type" no-error . 
    if available (buf_goods-attr) 
       and MarkType:GetKeyIntDB(buf_goods-attr.attr-value) > 0
    then do:
      run bgelib-tag-put in this-procedure ( input 3, input "ItemDataMatrixType"  , input string(MarkType:GetKeyIntDB(buf_goods-attr.attr-value)) , input 1 ).
      v-mark = yes .
      if buf_goods-attr.attr-value eq MarkType:tabak:NameProp 
      then do:
         vGdsTabak = yes.
      end.
       
    end.
    else do:
      run bgelib-tag-put in this-procedure ( input 3, input "ItemDataMatrixType"  , input "0", input 1 ).
    end. 
    find FIRST buf_goods-attr where buf_goods-attr.gds-code = cash-gds.gds-code and buf_goods-attr.attr-code = "gds-CommodityCode" no-error.
    if available buf_goods-attr then 
    do:
      run bgelib-tag-put in this-procedure ( input 4, input "ItemCommodityCode" , input string( buf_goods-attr.attr-value), input 1 ).  
    end.  

find first buf_goods-attr where buf_goods-attr.gds-code = cash-gds.gds-code 
              and buf_goods-attr.attr-code  = {&attr-oper-serv-id} no-error. 
  if available buf_goods-attr then do:
            run bgelib-tag-put in this-procedure ( input 3, input "ItemOSPayAgent"  , input string(buf_goods-attr.attr-value), input 1 ).
  end.
  else do:
            run bgelib-tag-put in this-procedure ( input 3, input "ItemOSPayAgent"  , input "0", input 1 ).
  end.  

run bgelib-tag-close in this-procedure ( input 2, input "Item").

  if v-attr-egais = 1 then do:  
        run bgelib-tag-open in this-procedure ( input 2, input "ItemMarkCode", input substitute("ctrl='&1' tms='&2' code='&3'"
                                          ,"ADD":U, OS2-time,cash-gds.b-code)).  
        find first buf_alc-type-gds where buf_alc-type-gds.gds-code = cash-gds.gds-code no-lock no-error.                                   
        find first buf_alc-type where buf_alc-type.alc-type-inner-code = buf_alc-type-gds.alc-type-inner-code no-lock no-error.             
        if available buf_alc-type then do:                     
          run bgelib-tag-put in this-procedure ( input 3, input "IMarkCode" , input string(buf_alc-type.alc-type-code), input 1 ).  
        end.                                                                                                                        
        find first bb_goods where bb_goods.gds-code = cash-gds.gds-code no-lock no-error .                                                  
        run bgelib-tag-put in this-procedure ( input 3, input "IMarkVolume" , input string(bb_goods.ms-base), input 1 ).
        run bgelib-tag-put in this-procedure ( input 3, input "IMarkQnty" , input string(cash-gds.cli-base-rate), input 1 ).
        run bgelib-tag-put in this-procedure ( input 3, input "IMarkAlc" ,    input string(bb_goods.proof), input 1 ).              
        run bgelib-tag-close in this-procedure ( input 2, input "ItemMarkCode").                                                    
    end.                                                                                                                          


&if "{&called}" = "in-ov" &then
  if vaction = "U":U then do:
    run bgelib-tag-open in this-procedure ( input 2, input "Item", input substitute("ctrl='&1' tms='&2' code='&3'", 'FREE':u, OS2-time, cash-gds.main-prt-b-code)).
    run bgelib-tag-put in this-procedure ( input 3, input "ItemLock"  , input string(0), input 1 ).
    run bgelib-tag-close in this-procedure ( input 2, input "Item").
  end.
 
  if vaction = "D":U then return.
&endif
 
&if "{1}" <> "7" &then

&scop output-phrase  ~
    run bgelib-tag-open in this-procedure ( input 2, input "ItemBarCode", input substitute("ctrl='&1' tms='&2' code='&3'" ~
                                          , (if vaction = "U" ~
                                             then if avail buf_cash-gds ~
					     	  then if buf_cash-gds.bc-on eq yes then "ADD":U  else "DEL":U  ~
                                                  else if     cash-gds.bc-on eq yes then "ADD":U  else "DEL":U  ~
                                             else "DEL":U)   ~
                                          , OS2-time         ~
                                          , ~{&output-code~})).                                              ~
    run bgelib-tag-put in this-procedure ( input 3, input "IBCCode"                                          ~
                                          , input cash-gds.main-prt-b-code                                            ~
                                          , input 1 ).                                                       ~
    if vaction = 'U':U then do:                                                                               ~
      run bgelib-tag-put in this-procedure ( input 3, input "IBCProducer"                                      ~
                                          , input string(cash-gds.producer-int), input 1 ).                   ~
      run bgelib-tag-put in this-procedure ( input 3, input "IBCIngredient"                                    ~
                                          , input trim(string( cash-gds.ingredient, "X(40)")), input 1 ).     ~
      if cash-gds.gtd <> "":U then                                                                             ~
      run bgelib-tag-put in this-procedure ( input 3, input "IBCGTD"                                           ~
                                          , input trim(string( cash-gds.gtd, "X(40)")), input 1 ).            ~
      find first ub.country no-lock where ub.country.alpha1 = cash-gds.alpha1 no-error.                              ~
      if available ub.country then                                                                                ~
      run bgelib-tag-put in this-procedure ( input 3, input "IBCCountry"                                       ~
                                          , input ub.country.short-name, input 1 ).                              ~
      run bgelib-tag-put in this-procedure ( input 3, input "IBCPrice"                                         ~
                                          , input string( cash-gds.price-sale ), input 1 ).                   ~
      run bgelib-tag-put in this-procedure ( input 3, input "IBCType"                                         ~
                                          , input string( v-IBCType ), input 1 ).                             ~
      run bgelib-tag-put in this-procedure ( input 3, input "IBC_EMRC"                                        ~
                                          , input  v-attr-emrc, input 1 ).                                    ~
      run bgelib-tag-put in this-procedure ( input 3, input "IBCUnitFactor"                                   ~
                                          , input  string(cash-gds.cli-base-rate), input 1 ).                 ~
    end.                                                                                                      ~
    run bgelib-tag-close in this-procedure ( input 2, input "ItemBarCode")                                                        


&scop output-code                                 (if buf_cash-gds.b-str <> "":U and buf_cash-gds.b-str <> "*" ~
                                                  then ( if  buf_cash-gds.unit-cli = buf_cash-gds.unit-base  ~
                                                         AND  (LOOKUP( ~{&weight~}, buf_cash-gds.unit-type ) > 0  ~
                                                         or buf_cash-gds.bc-on-type = ~{&loc-pg-code~}) ~
                                                         then (if buf_cash-gds.b-str begins "*" then left-trim(buf_cash-gds.b-str, "*") ~
                                                                                                else left-trim(buf_cash-gds.b-str, "0") ~
                                                              ) ~
                                                         else (if buf_cash-gds.b-str begins "*" then left-trim(buf_cash-gds.b-str, "*") ~
                                                                                                else buf_cash-gds.b-str ~
                                                              ) ~
                                                       ) ~
                                                  else (if buf_cash-gds.b-str eq "*" then buf_cash-gds.b-str else string(buf_cash-gds.b-code)))
for each buf_cash-gds no-lock where
&if "{&called}" <> "send-bc" and "{&called}" <> "send-bcn" and "{&called}" <> "s-prodbc" and "{&called}" <> "s-prodbcn" &then
          buf_cash-gds.main-prt-b-code = cash-gds.main-prt-b-code
      AND buf_cash-gds.obj-type = {&shop}
      AND buf_cash-gds.obj-code = abs(i-obj-code)
          :
&else
          buf_cash-gds.b-code = cash-gds.b-code
      AND buf_cash-gds.obj-type = {&shop}
      AND buf_cash-gds.obj-code = abs(i-obj-code)
          :
&endif
   if LOOKUP( {&weight}, cash-gds.unit-cli-type ) > 0 and buf_cash-gds.b-str = "" and ub.shop.cd-sc-base  then NEXT.
   if (ub.shop.cd-loc-base = no and buf_cash-gds.is-main-code = yes) then next.
   v-IBCType = 0 .
   if v-mark then do: 
       find first buf_prod-bc no-lock where buf_prod-bc.b-code = buf_cash-gds.b-code and buf_prod-bc.bc-on-type = {&gtin} 
                                        and buf_prod-bc.b-str = buf_cash-gds.b-str no-error .
       if available (buf_prod-bc) then do:
       v-IBCType = 2 .
       end.
       else do:
       find first buf_prod-bc-attr no-lock where buf_prod-bc-attr.b-code = buf_cash-gds.b-code
                              and buf_prod-bc-attr.b-str = buf_cash-gds.b-str 
                              and buf_prod-bc-attr.attr-code = {&mark} 
                              no-error .
       if available (buf_prod-bc-attr) and buf_prod-bc-attr.attr-value = "yes" then 
         v-IBCType = 1 .
     end. 

      
   end.
  if v-mark and buf_cash-gds.b-str = "" then v-IBCType = 1 .
  
  find first ub.prod-bc no-lock where ub.prod-bc.b-str = buf_cash-gds.b-str and ub.prod-bc.b-str <> "" and ub.prod-bc.bc-on-type = {&gtin} 
  no-error .
  define variable vBarCode1 as int no-undo.
  define variable vBarCode2 as int no-undo.
  if available (ub.prod-bc) then do:
    if cash-gds.cli-base-rate eq 1
    then do:
       v-i-cli-qnty = 999999999.
       for each buf_bar-code_cl where buf_bar-code_cl.gds-code      eq cash-gds.gds-code
                                  and buf_bar-code_cl.cli-base-rate ne cash-gds.cli-base-rate
       no-lock:
         v-i-cli-qnty = min (v-i-cli-qnty, buf_bar-code_cl.cli-base-rate).
         if v-i-cli-qnty =  buf_bar-code_cl.cli-base-rate
         then 
            vBarCode1 = buf_bar-code_cl.b-code.
       end.
       if vaction = "D" and 
          v-i-cli-qnty = 999999999 
       then do:
          assign
             v-i-cli-qnty = cash-gds.cli-base-rate 
             vBarCode1 = cash-gds.main-prt-b-code
             .
       end.    
    end.
    else do:
       v-i-cli-qnty = 999999999.
       for first buf_bar-code_cl where buf_bar-code_cl.gds-code      eq cash-gds.gds-code
                                  and buf_bar-code_cl.cli-base-rate eq 1
       no-lock:
         v-i-cli-qnty = min (v-i-cli-qnty, buf_bar-code_cl.cli-base-rate).
         vBarCode2 = buf_bar-code_cl.b-code.
       end.
       if vaction = "D" and 
          v-i-cli-qnty = 999999999 
       then do:
          assign
             v-i-cli-qnty = cash-gds.cli-base-rate 
             vBarCode2 = cash-gds.main-prt-b-code
             .
       end.
    end.
    
    if vGdsTabak then do:
       block-cli:
       do v-i-cli = 1 to 2:
         if (      v-i-cli-qnty eq 999999999 
               and v-i-cli eq 2 
               and cash-gds.cli-base-rate eq 1  )
            or (   v-i-cli-qnty eq 999999999 
               and v-i-cli eq 1 
               and cash-gds.cli-base-rate ne 1  )
         then 
            next block-cli.
         v-cli-base = string (v-i-cli,"99").
   
         run bgelib-tag-open in this-procedure ( input 2, input "ItemBarCode", input substitute("ctrl='&1' tms='&2' code='&3'" 
                                             , (if vaction = "U" 
                                                then (if buf_cash-gds.bc-on eq yes then "ADD":U else "DEL":U)
                                                else "DEL":U) 
                                              , OS2-time         
                                             , string(v-cli-base + buf_cash-gds.b-str))).                                              
         run bgelib-tag-put in this-procedure ( input 3, input "IBCCode"                                          
                                              , input string( if v-i-cli eq 1 and cash-gds.cli-base-rate ne 1
                                                               then vBarCode2
                                                               else if v-i-cli eq 2 and cash-gds.cli-base-rate eq 1
                                                               then vBarCode1
                                                               else cash-gds.main-prt-b-code )
                                              , input 1 ).                                                       
         if vaction = 'U':U then do:                                                                               
           run bgelib-tag-put in this-procedure ( input 3, input "IBCProducer"                                      
                                               , input string(cash-gds.producer-int), input 1 ).                   
           run bgelib-tag-put in this-procedure ( input 3, input "IBCIngredient"                                    
                                               , input trim(string( cash-gds.ingredient, "X(40)")), input 1 ).     
           if cash-gds.gtd <> "":U then                                                                             
           run bgelib-tag-put in this-procedure ( input 3, input "IBCGTD"                                           
                                               , input trim(string( cash-gds.gtd, "X(40)")), input 1 ).            
           find first country no-lock where country.alpha1 = cash-gds.alpha1 no-error.                              
           if available country then                                                                                
           run bgelib-tag-put in this-procedure ( input 3, input "IBCCountry"                                       
                                               , input country.short-name, input 1 ).                              
           
           run bgelib-tag-put in this-procedure ( input 3, input "IBCPrice"                                         
                                                , input string( if v-i-cli eq 1 and cash-gds.cli-base-rate ne 1
     	                                            then cash-gds.price-sale / cash-gds.cli-base-rate
     	                                            else if v-i-cli eq 2 and cash-gds.cli-base-rate eq 1
                                                         then cash-gds.price-sale * v-i-cli-qnty
                                                         else cash-gds.price-sale )
                                                , input 1 ).                   
           run bgelib-tag-put in this-procedure ( input 3, input "IBCType"                                         
                                               , input string( v-IBCType ), input 1 ).
           run bgelib-tag-put in this-procedure ( input 3, input "IBC_EMRC"                                         
                                          , input  v-attr-emrc, input 1 ).                             
           run bgelib-tag-put in this-procedure ( input 3, input "IBCUnitFactor"                                         
                                          , input  string(if v-i-cli eq 1 and cash-gds.cli-base-rate ne 1
                                                          then 1
                                                          else if v-i-cli eq 2 and cash-gds.cli-base-rate eq 1
                                                          then v-i-cli-qnty
                                                          else cash-gds.cli-base-rate), input 1 ).                             
                                
                                   
                                                          
         end.
         run bgelib-tag-close in this-procedure ( input 2, input "ItemBarCode") .
       end.
    end.
    else do: /* vGdsTabak = NO */
      v-cli-base = if cash-gds.cli-base-rate = 1 then "01" else "02".

      run bgelib-tag-open in this-procedure ( input 2, input "ItemBarCode", input substitute("ctrl='&1' tms='&2' code='&3'" 
                                          , (if vaction = "U" 
                                             then (if buf_cash-gds.bc-on eq yes then "ADD":U else "DEL":U)
                                             else "DEL":U) 
                                           , OS2-time         
                                          , string(v-cli-base + buf_cash-gds.b-str))).                                              
      run bgelib-tag-put in this-procedure ( input 3, input "IBCCode"                                          
                                           , input string( cash-gds.main-prt-b-code )
                                           , input 1 ).                                                       
      if vaction = 'U':U then do:                                                                               
        run bgelib-tag-put in this-procedure ( input 3, input "IBCProducer"                                      
                                            , input string(cash-gds.producer-int), input 1 ).                   
        run bgelib-tag-put in this-procedure ( input 3, input "IBCIngredient"                                    
                                            , input trim(string( cash-gds.ingredient, "X(40)")), input 1 ).     
        if cash-gds.gtd <> "":U then                                                                             
        run bgelib-tag-put in this-procedure ( input 3, input "IBCGTD"                                           
                                            , input trim(string( cash-gds.gtd, "X(40)")), input 1 ).            
        find first country no-lock where country.alpha1 = cash-gds.alpha1 no-error.                              
        if available country then                                                                                
        run bgelib-tag-put in this-procedure ( input 3, input "IBCCountry"                                       
                                            , input country.short-name, input 1 ).                              
        
        run bgelib-tag-put in this-procedure ( input 3, input "IBCPrice"                                         
                                             , input string( cash-gds.price-sale )
                                             , input 1 ).                   
        run bgelib-tag-put in this-procedure ( input 3, input "IBCType"                                         
                                            , input string( v-IBCType ), input 1 ).
        run bgelib-tag-put in this-procedure ( input 3, input "IBC_EMRC"                                         
                                          , input  v-attr-emrc, input 1 ).                             
        run bgelib-tag-put in this-procedure ( input 3, input "IBCUnitFactor"                                         
                                          , input  string(cash-gds.cli-base-rate), input 1 ).                             
                                                                  
      end.
      run bgelib-tag-close in this-procedure ( input 2, input "ItemBarCode") .
    end.
  end.  
  else do: 
  {&output-phrase}.

  end.

&if "{&called}" <> "send-bc" and "{&called}" <> "send-bcn" and "{&called}" <> "s-prodbc" and "{&called}" <> "s-prodbcn" &then
if buf_cash-gds.b-str = ""
and buf_cash-gds.ean-rz <> buf_cash-gds.ean-lz
AND buf_cash-gds.ean-lz <> "":U
then do:
&scop output-code   trim(buf_cash-gds.ean-lz, ~{&space-char~} )
   {&output-phrase}.
end.
&endif
end.

&if "{&called}" <> "send-bc" and "{&called}" <> "send-bcn" and "{&called}" <> "s-prodbc" and "{&called}" <> "s-prodbcn" &then
&else
if cash-gds.b-str = ""
and IBM-good-code-2 <> IBM-good-code
AND IBM-good-code <> "":U
then do:
&scop output-code   trim(IBM-good-code, ~{&space-char~} )
   {&output-phrase}.
end.
&endif
&endif

/* $Workfile$ e n d */