/*

$Revision: b8cfd3560a3b, 3573, rls $
$Author: ARostovtsev $
$Date: 2023/12/14 13:36:12 $
$Workfile: putc-gds.i $
$Archive: str/putc-gds.i $

вывод в поток для разных типов касс - пересылка товаров

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/12/05
Author: Bakhtadze Natalya
Creation date: 10/12/05

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile: putc-gds.i $ $Revision: b8cfd3560a3b, 3573, rls $".

PROCEDURE putc-gds.
define parameter buffer buf_cash-desk for ub.cash-desk.
define input parameter pos-type as char no-undo.
define input parameter p-version like ub.cash-desk.version no-undo .
define input parameter p-cash-os like ub.cash-desk.cash-os no-undo .
define variable ff  as  int     no-undo.
define variable gg  as  int     no-undo.
DEFINE VARIABLE second-name as character no-undo.
define variable nam-2str-shift as integer no-undo .
define variable v-length as integer no-undo .
DEFINE VARIABLE IBM-good-code-2 as character no-undo .
define variable std-disc-dec as decimal no-undo .
define variable std-disc-reason as integer no-undo .
define variable std-disc-lim as date no-undo .
define variable temp-disc-dec as decimal no-undo .
define variable temp-disc-reason as integer no-undo .
define variable temp-disc-start as date no-undo .
define variable temp-disc-end as date no-undo .
define variable temp-disc-time-start as integer no-undo .
define variable temp-disc-time-end as integer no-undo .
define variable temp-disc-weekday as integer no-undo .
define variable v-version-dec as decimal no-undo .
define variable v-kat-num as integer no-undo .
define variable v-kat-discnt as decimal no-undo .
define variable v-time-rule-num like ub.dis-rule.time-rule-num no-undo .
define variable IBM2-short as character no-undo .
define variable v-what-find as character no-undo .
define variable v-plu as character no-undo .
define variable v-pl-code as integer no-undo .
define variable v-marketer-action as character no-undo .
define variable v-versiond as decimal no-undo .
define variable v-b-code-to-find as logical no-undo .
define variable v-maria-discnt-value as character no-undo .
define variable v-ii as integer no-undo .
define variable v-dop as character no-undo .
define variable v-gds-rule-num as integer no-undo .
define variable v-maria-rule-num as integer no-undo .
define variable v-discreteness as character no-undo .
define variable wd-option as integer no-undo .
define variable wgd-option as integer no-undo .
define variable v-type as logical   no-undo .
define variable  s as char no-undo.
define variable articul as char no-undo.
define variable v-disc-price-sale as decimal no-undo .
define variable v-pdf-id as integer no-undo .
define variable v-pdf-db-num as integer no-undo .

define buffer buf_cash-dis-rule for cash-dis-rule .
define buffer buf_cd-plu for ub.cd-plu.
define buffer buf_dis-rule for ub.dis-rule.
define buffer buf_place for ub.place.
define buffer buf_pl-gds for ub.pl-gds.
define buffer bcash-gds for cash-gds.
define buffer buf_cash-desk-attr for cash-desk-attr.
define variable vcash-desk-stndart as logical no-undo init yes.
assign
v-version-dec = decimal(p-version)
no-error .
if buf_cash-desk.autonomy = integer({&cd-manager})
then do:
   vcash-desk-stndart = no.
end.
  if buf_cash-desk.device-kind = 2 then vcash-desk-stndart = no.

define variable is-petrol   as logical   no-undo.
define variable is-pieces   as logical   no-undo.

{ str/is-petrl.i cash-gds.artic
                 ?
                 cash-gds.gds-code
                 is-petrol
                 is-pieces              
                 NO-ERROR }
if     not vcash-desk-stndart 
   and not is-petrol
then 
   return.
if cash-gds.std-discnt-rule > 0 then do:
  find first cash-dis-rule no-lock where
            cash-dis-rule.rule-num =  cash-gds.std-discnt-rule no-error .
  if available cash-dis-rule then do:
    find first cash-dis-time-rule no-lock where
              cash-dis-time-rule.time-rule-num = cash-dis-rule.time-rule-num no-error .
    assign
    std-disc-dec = - cash-dis-rule.discnt-value
    std-disc-reason = 0
    no-error
    .
    if available cash-dis-time-rule then do:
      assign
      std-disc-lim = cash-dis-time-rule.date-to
      .
      if std-disc-lim <> 12/31/1989 and std-disc-lim < today then
      assign
      std-disc-dec = 0
      std-disc-reason = 0
      .
      if cash-dis-time-rule.date-to <> 12/31/1989 and cash-dis-time-rule.date-from > today then
      assign
      std-disc-dec = 0
      std-disc-reason = 0
      .
    end.
  end.
end.
if cash-gds.wd > 1 then do:
  find first cash-dis-rule no-lock where
            cash-dis-rule.rule-num =  cash-gds.wd-rule no-error .
  if available cash-dis-rule then  do:
    assign
    wd-option = integer(cash-dis-rule.discnt-value).
  end.
end.
if cash-gds.wd = 1 then do:  /* запрет может устанавливаться из 2-х мест. из правил скидок и по глоб.атрибуту товара. Если по глоб.атрибуту, то в wd будет стоять 1. */
   wd-option = 1.
end.
if cash-gds.wgd > 0 then do:
  find first cash-dis-rule no-lock where
            cash-dis-rule.rule-num =  cash-gds.wgd-rule no-error .
  if available cash-dis-rule then  do:
    assign
    wgd-option = integer(cash-dis-rule.discnt-value).
  end.
end.
if cash-gds.temp-discnt-rule <> 0 then do:
  assign
  temp-disc-dec = 0
  .
  find first cash-dis-rule no-lock where
            cash-dis-rule.rule-num = cash-gds.temp-discnt-rule no-error .
  if available cash-dis-rule
           and cash-dis-rule.is-term = yes then do:
    if cash-dis-rule.time-rule-num > 0 then do:
      find first cash-dis-time-rule no-lock where
                  cash-dis-time-rule.time-rule-num = cash-dis-rule.time-rule-num no-error .
      if available cash-dis-time-rule
      and cash-dis-time-rule.templ-rl-root = 50001 /*всегда*/
          or
          (
           (
            (cash-dis-time-rule.date-from < today)
            or
            (cash-dis-time-rule.date-from = 12/31/1989)
           )
          and
          (
           (cash-dis-time-rule.date-to >= today)
           or
           (cash-dis-time-rule.date-to = 12/31/1989)
          )
         ) then do:
         temp-disc-dec = ?.
      end.
      else do:
        assign
        temp-disc-dec = 0
        .
      end.
    end. /* cash-dis-time-rule > 0*/
    else do:
      temp-disc-dec = ?.
    end.
    if temp-disc-dec = ? then do:
      case cash-dis-rule.value-type:
        when integer({&discnt-v-pcnt}) then do:
      assign
      temp-disc-dec = - cash-dis-rule.discnt-value
      .
    end.
        when integer({&discnt-v-pdf-pcnt}) then do:
          /*получим % из соотношения cash-gds.price-sale и цены полученной из прайс-листа типа cash-dis-rule.charkey_one*/
          find first cash-gds-discnt where
                    cash-gds-discnt.b-code = cash-gds.b-code
                and  cash-gds-discnt.rule-num = cash-dis-rule.rule-num
                and cash-gds-discnt.obj-type = {&shop}
                and cash-gds-discnt.obj-code = i-obj-code
                no-error.
          if available cash-gds-discnt then do:
            assign
            temp-disc-dec = - (cash-gds.price-sale - cash-gds-discnt.discnt-value) / cash-gds.price-sale * 100
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
    end. /*if temp-disc-dec = ? then do:*/
  end.  /*if available cash-dis-rule*/
end. /*if cash-gds.temp-discnt-rule <> 0 then do:*/

CASE pos-type:
  when {&cd-type-MAGIA-XML}
  then do:
    if cash-gds.b-str <> "":U then do:
      return.
    end.
    assign
    chk_name = replace(cash-gds.gds-name, {&double-quote}, "":U) + cash-gds.f-name
    .
    if cash-gds.unit-base <> cash-gds.unit-cli then
    assign
    chk_name = string(substr(chk_name, 1, max(33, 50 - 1 - length(trim(string(cash-gds.cli-base-rate), {&space-char})))) +
                      "*":U +
                      trim(string( cash-gds.cli-base-rate ), {&space-char}), "x(50)":U ).
    else
    chk_name = string(chk_name, "X(50)":U).
    assign
    second-name = replace(cash-gds.gds-namelong, {&single-quote}, "":U)
    second-name =   ({&double-quote} +
                      TRIM(CAPS(string( replace(second-name, {&double-quote}, "":U), "X(40)":U ))) /* длинное название*/
                      + {&double-quote} )
    .
    if cash-gds.unit-base <> cash-gds.unit-cli then
    assign
    second-name = string(substr(second-name, 1, max(23, 40 - 1 - length(trim(string(cash-gds.cli-base-rate), {&space-char})))  ) +
                      "*":U +
                      trim(string(cash-gds.cli-base-rate), {&space-char}), "x(40)":U ).
    else
    second-name = string(second-name, "X(40)":U).


    if tax-cass AND cash-gds.new-good then do:
        for each cash-txr No-LOCK WHERE
                  cash-txr.rc = cash-gds.rc AND
                  cash-txr.host-code = ub.shop.host-code AND
                  cash-txr.obj-type = {&shop} AND
                  cash-txr.obj-code = ub.shop.obj-code:
          run putc-13(buffer buf_cash-desk
                    , input pos-type
                    , input p-cash-os
                    , input yes
                    ).
        end.
    end.
    { str/maxmlgds.i }
  end.
  when {&cd-type-IBM}
  or when {&cd-type-IBM-XML}
  or when {&cd-type-infokiosk}
  or when {&cd-type-maria}
  or when {&cd-type-autotank}
  then do:
      
    assign
    v-length = (if pos-type = {&cd-type-ibm} or pos-type = {&cd-type-IBM-XML} then 22 else 40 )
    v-length = (if pos-type = {&cd-type-maria} then 24 else v-length)
    v-length = (if pos-type = {&cd-type-maria} and lookup({&petrolium}, cash-gds.unit-cli-type) > 0
                then 5
                else v-length)
    nam-2str-shift = (if nam-2str then v-length else 0)
    .

    chk_name = chk-name_ibm_maria_ibm-xml_infokiosk_ibs-th ( input pos-type
                                         ,input nam-2str
                                         ,input nam-artc
                                         ,input cash-gds.unit-cli-type
                                         ,input cash-gds.unit-base
                                         ,input cash-gds.unit-cli
                                         ,input cash-gds.cli-base-rate
                                         ,input cash-gds.artic
                                         ,input cash-gds.f-name
                                         ,input cash-gds.gds-name
                                         ,input cash-gds.gds-name1
                                         ,output second-name ).
    if pos-type = {&cd-type-IBM-XML}
    or pos-type = {&cd-type-infokiosk}
    or pos-type = {&cd-type-autotank}
    then do:
      { str/ibm-gds.i XML }
    end.
    if pos-type = {&cd-type-IBM}
    or pos-type = {&cd-type-maria}
    then do:
      { str/ibm-gds.i }
    end.
  end.
    when {&cd-type-IPC-SERVISPL} then do:
    if cash-gds.b-str = "":U
    and
    (LOOKUP( {&weight}, cash-gds.unit-type ) > 0
    and cash-gds.unit-base = cash-gds.unit-cli
    and ub.shop.cd-sc-base
    ) then return.
    if lookup({&weight}, cash-gds.unit-type ) > 0 and ub.shop.cd-sc-base
    then do:
      if cash-gds.unit-cli <> "КГ"
      and cash-gds.unit-cli <> "КГ."
      then return.
    end.
    assign
    articul = string( cash-gds.artic,"x(17)" ) + string( cash-gds.b-code ).
    chk_name = string( trim(replace(if nam-artc
                                    then cash-gds.artic
                                    else cash-gds.gds-name, {&comma-char}, {&space-char})), "x(15)" ) +
                                    replace(cash-gds.f-name, {&comma-char}, {&space-char}) +
                                   (if cash-gds.unit-cli = cash-gds.unit-base then "" else ("*" + trim(string(cash-gds.cli-base-rate)))).
    assign
    v-discreteness = (if lookup({&divisional}, cash-gds.unit-cli-type ) > 0
                      then '",0.001,"':U
                      else '",1,"':U)
    .
    RUN gen-bc in this-procedure ( input cash-gds.b-code, output bar_code ).
        if num-entries(dob-curr, ";") > 1 then do:
        if lookup( string(i-obj-code) , entry(2,dob-curr,";") ) > 0
           then v-type  = true  .
           else v-type  = false .
    end.
    else do:
        v-type  = false .
    end.
if cash-gds.b-str = ""
    or lookup({&weight}, cash-gds.unit-cli-type) > 0
    then do:
        /*для этой кассы получается, что-нибудь пошлется даже если выключены пересылки
        и локального и собственного бар-кода*/
        if ub.sysconf.base-code <> 0  or v-type = true  then do:
        s = '"' + articul + '","'  + chk_name + '","' +
            (if cash-gds.unit-cli = "кг."
             or cash-gds.unit-cli = "кг"
             then "КГ"
             else cash-gds.unit-cli) +
              v-discreteness +
              string(cash-gds.producer, "X(20)") + '","' +
              STRING(I-OBJ-CODE)                  + '","' +
              substring(for-shop-name , 1, 20)    + '",'  +
              '0,0,0,"NOSIZE"," "," "," "," "," ",0.00,' +
                trim(string( (if v-type = true
                            then  cash-gds.price-sale / curr_cass
                            else cash-gds.price-sale),">>>>>9.99")) +
              '," ",' + {&double-quote} + string(cash-gds.vat-pc) + {&double-quote}  + ',"1",,0,0'.
        end.
        else do:
        s = '"' + articul + '","'  + chk_name + '","' +
            (if cash-gds.unit-cli = "кг."
             or cash-gds.unit-cli = "кг"
             then "КГ"
             else cash-gds.unit-cli) +
              v-discreteness +
              string(cash-gds.producer, "X(20)") + '","'  +
              STRING(I-OBJ-CODE)                  + '","'  +
              substring(for-shop-name , 1, 20)    + '",'   +
              '0,0,0,"NOSIZE"," "," "," "," "," ",' +
              trim( string( cash-gds.price-sale ,">>>>>>>>>>9.99")) +
              ',0.00," ",'  + {&double-quote} + string(cash-gds.vat-pc) + {&double-quote}  +  ',"1",,0,0'.
        end.
        put stream plucash unformatted s skip.
        if lookup({&weight}, cash-gds.unit-cli-type) = 0
        or (lookup({&weight}, cash-gds.unit-cli-type) > 0
            and not ub.shop.cd-sc-base
            and cash-gds.unit-cli = cash-gds.unit-base)
        then do:
          if ((ub.shop.cd-loc-base and cash-gds.unit-base = cash-gds.unit-cli) OR
              (ub.shop.cd-loc-alt and cash-gds.unit-base <> cash-gds.unit-cli)) then do:
              s = '"' + string( cash-gds.b-code ) + '","' + articul + '","NOSIZE",' + string(cash-gds.cli-base-rate).
              put stream bar unformatted s skip.
          end.
          if ((ub.shop.cd-bc-base and cash-gds.unit-base = cash-gds.unit-cli) OR
              (ub.shop.cd-bc-alt and cash-gds.unit-base <> cash-gds.unit-cli)) then do:
              s = '"' + trim( bar_code ) + '","' + articul + '","NOSIZE",' + string(cash-gds.cli-base-rate).
              put stream bar unformatted s skip.
          end.
        end.
      end.
      else do:
          s = '"' + string( cash-gds.b-str ) + '","' + articul + '","NOSIZE",' + string(cash-gds.cli-base-rate).
          put stream bar unformatted s skip.
      end.
      if lookup({&weight}, cash-gds.unit-cli-type) > 0 then do:
          s = '"' + string(ipcsc-pfx)  + string( cash-gds.b-str ) + '","' + articul + '","NOSIZE",' + string(cash-gds.cli-base-rate).
          put stream bar unformatted s skip.
      end.
      if cash-gds.bc-on-type = {&loc-pg-code} then do:
          s = '"' + string(ipcpg-pfx)  + string( cash-gds.b-str ) + '","' + articul + '","NOSIZE",' + string(cash-gds.cli-base-rate).
          put stream bar unformatted s skip.
      end.
    end.  /*ipc-servis+*/
  &if "{&called}" <> "del-gds" &then
  when {&cd-type-pricecheck-Servispl} then  do:
    if cash-gds.b-str = "":U  and
    (lookup( {&weight}, cash-gds.unit-type ) > 0
    and cash-gds.unit-base = cash-gds.unit-cli
    and ub.shop.cd-sc-base
    ) then return.
    if lookup({&weight}, cash-gds.unit-type ) > 0 and ub.shop.cd-sc-base
    then do:
      if cash-gds.unit-cli <> "КГ"
      and cash-gds.unit-cli <> "КГ."
      then return.
    end.
    assign
    articul = string( cash-gds.artic,"x(17)" ) + string( cash-gds.b-code ).
    chk_name = string( trim(replace(if nam-artc
                                    then cash-gds.artic
                                    else cash-gds.gds-name, {&comma-char}, {&space-char})), "x(20)" ) +
                                    replace(cash-gds.f-name, {&comma-char}, {&space-char}) +
                                   (if cash-gds.unit-cli = cash-gds.unit-base then "" else ("*" + string(cash-gds.cli-base-rate))).

    assign
    v-discreteness = (if lookup({&divisional}, cash-gds.unit-cli-type ) > 0
                      then ',0.001,':U
                      else ',1,':U)
    .
    RUN gen-bc( input cash-gds.b-code, output bar_code ).

    if num-entries(dob-curr, ";") > 1 then do:
        if lookup( string(i-obj-code) , entry(2,dob-curr,";") ) > 0
           then v-type  = true  .
           else v-type  = false .
    end.
    else do:
        v-type  = false .
    end.
    if cash-gds.b-str = ""
    or lookup({&weight}, cash-gds.unit-cli-type) > 0
    then do:
        /*для этой кассы получается, что-нибудь пошлется даже если выключены пересылки
        и локального и собственного бар-кода*/
        if ub.sysconf.base-code <> 0  or v-type = true  then do:
          s = articul + "," + chk_name + "," +
              (if cash-gds.unit-cli = "кг."
              or cash-gds.unit-cli = "кг"
              then "КГ"
              else cash-gds.unit-cli) +
                v-discreteness +
                string(cash-gds.producer, "X(20)") +  "," +
                STRING(I-OBJ-CODE)                  + "," +
                substring(for-shop-name , 1, 20)    + ","  +
                "0,0,0,NOSIZE,,,,,,0.00," +
                trim(string( (if v-type = true
                              then  cash-gds.price-sale / curr_cass
                              else cash-gds.price-sale),">>>>>9.99")) +
                ',,' + string(cash-gds.vat-pc) + ',1,,0,0'.
        end.
        else do:
          s = articul + ","  + chk_name + "," +
              (if cash-gds.unit-cli = "кг."
              or cash-gds.unit-cli = "кг"
              then "КГ"
              else cash-gds.unit-cli) +
                v-discreteness +
                string(cash-gds.producer, "X(20)") + ","  +
                STRING(I-OBJ-CODE)                  + ","  +
                substring(for-shop-name , 1, 20)    + ","   +
                "0,0,0,NOSIZE,,,,,," +
                trim( string( cash-gds.price-sale ,">>>>>>>>>>9.99")) +
                ',0.00,,' + string(cash-gds.vat-pc) + ',1,,0,0'.
        end.
        put stream plucash unformatted s skip.
        if lookup({&weight}, cash-gds.unit-cli-type) = 0
        or (lookup({&weight}, cash-gds.unit-cli-type) > 0
            and not ub.shop.cd-sc-base
            and cash-gds.unit-cli = cash-gds.unit-base)
        then do:
          if ((ub.shop.cd-loc-base and cash-gds.unit-base = cash-gds.unit-cli) OR
              (ub.shop.cd-loc-alt and cash-gds.unit-base <> cash-gds.unit-cli)) then do:
              s = string( cash-gds.b-code ) + "," + articul + ',NOSIZE,1' .
              put stream bar unformatted s skip.
          end.
          if ((ub.shop.cd-bc-base and cash-gds.unit-base = cash-gds.unit-cli) OR
              (ub.shop.cd-bc-alt and cash-gds.unit-base <> cash-gds.unit-cli)) then do:
              s = trim( bar_code ) + "," + articul + ',NOSIZE,1' .
              put stream bar unformatted s skip.
          end.
        end.
      end.
      else do:
          s = string( cash-gds.b-str ) + "," + articul + ',NOSIZE,1' .
          put stream bar unformatted s skip.
      end.
      if lookup({&weight}, cash-gds.unit-cli-type) > 0 then do:
        define variable v-sclspref-entry as integer no-undo .
        do v-sclspref-entry = 1 to num-entries(varscales-pref):
          s = trim(entry(v-sclspref-entry, varscales-pref))  + string( cash-gds.b-str ) + "," + articul + ',NOSIZE,1' .
          put stream bar unformatted s skip.
      end.
      end.
    end.  /*pricecheck-Servispl*/
    &endif
    when {&cd-type-OMRON} then  do:
        chk_name = string( if nam-artc then cash-gds.artic else cash-gds.gds-name, "x(15)" ) + cash-gds.f-name +
        (if cash-gds.unit-cli = cash-gds.unit-base then "" else ("*" + trim(string(cash-gds.cli-base-rate), {&space-char}))).
        if cash-gds.b-str = "" then do:
            assign
            b_code = string(cash-gds.b-code,'>>>>>>>>>>>>>>>9').
            run gen-bc(input cash-gds.b-code, output bar_code) no-error.
            if ((ub.shop.cd-loc-base and cash-gds.unit-base = cash-gds.unit-cli) OR
                (ub.shop.cd-loc-alt and cash-gds.unit-base <> cash-gds.unit-cli)) then do:
                put unformatted b_code '00101' caps(string(chk_name,'x(20)'))
                                      string( ( cash-gds.price-sale * 100 ) ,'99999999').
                put unformatted '0000000000000000000000000000000'
                string(action, "X(1)") '0000000000000'.
                put skip.
            end.
            if ((ub.shop.cd-bc-base and cash-gds.unit-base = cash-gds.unit-cli) OR
                (ub.shop.cd-bc-alt and cash-gds.unit-base <> cash-gds.unit-cli)) then do:
                put unformatted (fill(" " , 16 -  length(bar_code)) + bar_code) '00101'
                                              caps(string(chk_name,'x(20)'))
                                              string(( cash-gds.price-sale * 100 ) ,'99999999') .
                put unformatted '0000000000000000000000000000000'
                string(action, "X(1)") '0000000000000'.
                put skip.
            end.
        end.
        else do:
          put unformatted ( fill(" " , 16 -  length(cash-gds.b-str)) + cash-gds.b-str )
                                    '00101' caps( string( chk_name, 'x(20)' ) )
                                  string( ( cash-gds.price-sale * 100 ) ,'99999999') .
          put unformatted '0000000000000000000000000000000'
          string(action, "X(1)") '0000000000000'.
          put skip.
        end.
      end. /*omron*/
      when {&cd-type-omron-new} then  do:
        assign
        v-versiond = decimal(p-version)
        no-error .
        chk_name = string( if nam-artc then cash-gds.artic else cash-gds.gds-name, "x(15)" ) + cash-gds.f-name +
        (if cash-gds.unit-cli = cash-gds.unit-base then "" else ("*" + trim(string(cash-gds.cli-base-rate), {&space-char}))).
        if v-versiond >= 33.0 then do:
          if cash-gds.b-str = "" then do:
              assign
              b_code = string(cash-gds.b-code,'>>>>>>>>>>>>>>>9').
              run gen-bc(input cash-gds.b-code, output bar_code) no-error.
              if ((ub.shop.cd-loc-base and cash-gds.unit-base = cash-gds.unit-cli) OR
                  (ub.shop.cd-loc-alt and cash-gds.unit-base <> cash-gds.unit-cli)) then do:
                  put unformatted
                  b_code                                               /*код товара символьный 16*/
                  '00101'                                              /*код группы 3 и код налога 2*/
                  caps(string(chk_name,'x(20)'))                       /*название  20*/
                  string( ( cash-gds.price-sale * 100 ) ,'999999999999')   /*цена 12*/
                  .
                  put unformatted
                  '000000000000000000000000000'                    /*заполнитель 27*/
                  string(action, "X(1)")                               /*код движения 1*/
                  fill('0':U , 12)                                    /*заполнитель и все прочие поля 12*/
                  string(v-r-b-curr-magia, "9")
                  fill('0':U , 104)                                    /*заполнитель и все прочие поля 104*/
                  .
                  put skip.
              end.
              if ((ub.shop.cd-bc-base and cash-gds.unit-base = cash-gds.unit-cli) OR
                  (ub.shop.cd-bc-alt and cash-gds.unit-base <> cash-gds.unit-cli)) then do:
                  put unformatted
                  (fill(" " , 16 -  length(bar_code)) + bar_code)
                  '00101'
                  caps(string(chk_name,'x(20)'))
                  string(( cash-gds.price-sale * 100 ) ,'999999999999') .
                  put unformatted
                  '000000000000000000000000000'
                  string(action, "X(1)")
                  fill('0':U , 12)                                    /*заполнитель и все прочие поля 12*/
                  string(v-r-b-curr-magia, "9")
                  fill('0':U , 104)                                    /*заполнитель и все прочие поля 104*/
                  .
                  put skip.
              end.
          end.
          else do:
            put unformatted
            ( fill(" " , 16 -  length(cash-gds.b-str)) + cash-gds.b-str )
            '00101'
            caps( string( chk_name, 'x(20)' ) )
            string( ( cash-gds.price-sale * 100 ) ,'999999999999')
            .
            put unformatted
            '000000000000000000000000000'
            string(action, "X(1)")
            fill('0':U , 12)                                    /*заполнитель и все прочие поля 12*/
            string(v-r-b-curr-magia, "9")
            fill('0':U , 104)                                    /*заполнитель и все прочие поля 104*/
            .
            put skip.
          end.
        end.
        else do:
          if cash-gds.b-str = "" then do:
              assign
              b_code = string(cash-gds.b-code,'>>>>>>>>>>>>>>>9').
              run gen-bc(input cash-gds.b-code, output bar_code) no-error.
              if ((ub.shop.cd-loc-base and cash-gds.unit-base = cash-gds.unit-cli) OR
                  (ub.shop.cd-loc-alt and cash-gds.unit-base <> cash-gds.unit-cli)) then do:
                  put unformatted b_code '00101' caps(string(chk_name,'x(20)'))
                                        string( ( cash-gds.price-sale * 100 ) ,'99999999').
                  put unformatted '0000000000000000000000000000000'
                  string(action, "X(1)") '0000000000000'.
                  put skip.
              end.
              if ((ub.shop.cd-bc-base and cash-gds.unit-base = cash-gds.unit-cli) OR
                  (ub.shop.cd-bc-alt and cash-gds.unit-base <> cash-gds.unit-cli)) then do:
                  put unformatted (fill(" " , 16 -  length(bar_code)) + bar_code) '00101'
                                                caps(string(chk_name,'x(20)'))
                                                string(( cash-gds.price-sale * 100 ) ,'99999999') .
                  put unformatted '0000000000000000000000000000000'
                  string(action, "X(1)") '0000000000000'.
                  put skip.
              end.
          end.
          else do:
            put unformatted ( fill(" " , 16 -  length(cash-gds.b-str)) + cash-gds.b-str )
                                      '00101' caps( string( chk_name, 'x(20)' ) )
                                    string( ( cash-gds.price-sale * 100 ) ,'99999999') .
            put unformatted '0000000000000000000000000000000'
            string(action, "X(1)") '0000000000000'.
            put skip.
          end.
        end.
      end. /*omron-new*/
    when {&cd-type-NCR-GM}
    or when {&cd-type-NCR-AS-R}
    then do:
      { str/ncrgmgds.i }
    end.
  END CASE .
END PROCEDURE .

 /* $Workfile: putc-gds.i $ e n d */