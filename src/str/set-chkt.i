/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Проверка строки чеков при закачки / создании

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/09/05
Author: Bakhtadze Natalya
Creation date: 10/09/05

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&scop seq {&sequence}
define variable v-valid{&seq} as logical no-undo .
define variable v-mess{&seq} as character no-undo .
define variable v-chr-err{&seq} as character no-undo .


if v-b-c <> ? then do:
  iserr = no.
  if {2}.src-qnty = 0
  and not(lookup(string(chk-doc.chk-type), {&sale-in-receipt-codes}) > 0
         and {2}.write-off-code > 0)
  and not (chk-doc.chk-type = integer({&rcpt-trans-cancell}))
  and not p-pos-type = {&cd-type-autotank} and not p-pos-type = {&cd-type-ibm-xml} and not p-pos-type = {&cd-type-ibm}
  then do:
    /*случай когда возвращают или списывают на возварте чек в котором было списание - второй раз списать нельз
    положим товар для информативности
    */
    assign
    iserr = yes
    for-chk-type = for-chk-type + {&amount-err} + {&comma-char}
    {1}.correct = no
    p-view-log = yes
    .
    run write-log-and-file in {5} (
          input 1
        , input log-file-name
        , input 1
        , input substitute(
                            "!!!Чек &1 - ошибочный. &2 Товар с кодом &3: количество = 0"
                            , chk-doc.doc-code
                            , {&new-line}
                            , {2}.src-code
                          )
                                          ).
  end.
  &scop wro-code STRING(if {2}.write-off-code <> ? then {2}.write-off-code else 0)
  FIND FIRST goods WHERE
             goods.gds-code = bar-code.gds-code NO-LOCK.
  FIND FIRST gds-obj No-LOCK WHERE
             gds-obj.gds-code = bar-code.gds-code AND
             gds-obj.obj-type =  {1}.obj-type AND
             gds-obj.obj-code =   {1}.obj-code NO-ERROR.
  cashparts = IF AVAIL gds-obj then gds-obj.cash-parts else no.
  FIND FIRST units WHERE units.unit-name = goods.unit-base NO-LOCK .
  if LOOKUP(goods.gds-type, for-chk-type) = 0 then
  do:
    assign
    for-chk-type = for-chk-type + goods.gds-type + {&comma-char}
    main-gds-type = goods.gds-type
    .
  end.
  if (LOOKUP({&gds-goods}, for-chk-type) > 0
      OR
      LOOKUP({&gds-office}, for-chk-type) > 0
      )
  and LOOKUP({&amount}, for-chk-type) > 0 then do:
    run write-log-and-file in {5} (
          input 1
        , input log-file-name
        , input 1
        , input substitute(
                            "!!!Чек &1 - ошибочный. &2В одном чеке смешаны товары/услуги и суммовые строки.&3"
                            , chk-doc.doc-code
                            , {&new-line}
                            , {&new-line}
                          )
                                          ).
    assign
    for-chk-type = for-chk-type + goods.gds-type + {&comma-char}
    {1}.correct = no
    {2}.is-err = yes
    p-view-log = yes
    .
  end.

find first ub.goods-attr where ub.goods-attr.gds-code = ub.goods.gds-code and ub.goods-attr.attr-code = {&attr-ptrl-as-good} no-error.

if LOOKUP({&petrolium}, units.type) = 0 and (available (ub.goods-attr) and ub.goods-attr.attr-value= 'yes') then do:
  {2}.nozzle-code = 0.
  {2}.pump = 0.
end.
  IF {2}.pump > 0 and LOOKUP({&petrolium}, units.type) = 0 and ub.goods.gds-type = {&gds-office} then do:
    {2}.pump = 0.
  end.
  { str/libchkvl_petrol-valid.i
   chk-doc.chk-type
   {2}.line-num
   chk-doc.obj-type
   chk-doc.obj-code
   p-pos-type
   {2}.src-code
   goods.gds-code
   units.type
   {2}.pump
   {2}.nozzle-code
    v-valid~{&seq~}
    v-mess~{&seq~}
    v-chr-err~{&seq~}
    no-error
  }
  if error-status:error
  or not v-valid{&seq} then do:
    run write-log-and-file in {5} (
          input 1
        , input log-file-name
        , input 1
        , input substitute("!!!Чек &1 - ошибочный.&2"
                          , chk-doc.doc-code
                          ,v-mess{&seq})).
    assign
    for-chk-type = for-chk-type + v-chr-err{&seq} + {&comma-char}
    {2}.is-err = yes
    iserr = yes
    p-view-log = yes
    .
  end.
  if LOOKUP( {&serial}, units.type ) > 0 OR
     lookup({&twounit}, units.type) > 0 OR
     lookup({&altunit}, units.type) > 0 then do:
    { str/libchkvl_unit-type-qnty.i
    chk-doc.chk-type
    {2}.line-num
    units.type
    ''
    {2}.src-code
    bar-code.in-code
    {2}.src-qnty
    goods.min-rate
    goods.max-rate
    v-valid~{&seq~}
    v-mess~{&seq~}
    v-chr-err~{&seq~}
    no-error
    }
    if error-status:error
    or not v-valid{&seq} then do:
      run write-log-and-file in {5} (
            input 1
          , input log-file-name
          , input 1
          , input substitute("!!!Чек &1 - ошибочный.&2"
                            , chk-doc.doc-code
                            ,v-mess{&seq})).
      assign
      for-chk-type = for-chk-type + v-chr-err{&seq} + {&comma-char}
      {2}.is-err = yes
      iserr = yes
      p-view-log = yes
      .
    end.
  end. /*if LOOKUP( {&serial}, units.type ) > 0 OR*/
  if LOOKUP({&serial}, units.type) = 0 then do:
    { str/libchkvl_part-valid.i
    chk-doc.chk-type
    {2}.line-num
    units.type
    ''
    {2}.src-code
    bar-code.in-code
    bar-code.part-code
    cashparts
    {2}.src-qnty
    v-valid~{&seq~}
    v-mess~{&seq~}
    v-chr-err~{&seq~}
    no-error
    }
    if error-status:error
    or not v-valid{&seq} then do:
      run write-log-and-file in {5} (
            input 1
          , input log-file-name
          , input 1
          , input substitute("!!!Чек &1 - ошибочный.&2"
                            , chk-doc.doc-code
                            ,v-mess{&seq})).
      assign
      for-chk-type = for-chk-type + v-chr-err{&seq} + {&comma-char}
      {2}.is-err = yes
      iserr = yes
      p-view-log = yes
      .
    end.
  end. /*if LOOKUP({&serial}, units.type) = 0 then do:*/
  &if "{6}"  <> "update" &then
   { str/libchkvl_place-valid.i
    chk-doc.chk-type
    {2}.line-num
    chk-doc.obj-type
    chk-doc.obj-code
    {2}.src-code
    goods.gds-code
    {2}.loc1
    {2}.src-pl-code
    {2}.pl-code
    v-valid~{&seq~}
    v-mess~{&seq~}
    v-chr-err~{&seq~}
    no-error
    }
  if error-status:error
  or not v-valid{&seq} then do:
    run write-log-and-file in {5} (
          input 1
        , input log-file-name
        , input 1
        , input substitute("!!!Чек &1 - ошибочный.&2"
                          , chk-doc.doc-code
                          ,v-mess{&seq})).
    assign
    for-chk-type = for-chk-type + v-chr-err{&seq} + {&comma-char}
    {2}.is-err = yes
    iserr = yes
    p-view-log = yes
    .
  end.
&endif
  FIND gds-prt WHERE gds-prt.upper-code = goods.prt-root NO-LOCK .
  { str/libchkvl_prt-valid.i
    chk-doc.chk-type
    {2}.line-num
    shop.doc-prt
    {2}.src-code
    "(gds-prt.node-name <> {&empty-scale})"
    gds-prt.node-code
    bar-code.node-code
    v-valid{&seq}
    v-mess{&seq}
    v-chr-err{&seq}
    no-error
  }
  if error-status:error
  or not v-valid{&seq} then do:
    run write-log-and-file in {5} (
          input 1
        , input log-file-name
        , input 1
        , input substitute("!!!Чек &1 - ошибочный.&2"
                          , chk-doc.doc-code
                          ,v-mess{&seq})).
    assign
    for-chk-type = for-chk-type + v-chr-err{&seq} + {&comma-char}
    {2}.is-err = yes
    iserr = yes
    p-view-log = yes
    .
  end.
  { str/libchkvl_fbr-valid.i
   chk-doc.chk-type
   {2}.line-num
   chk-doc.obj-type
   chk-doc.obj-code
   shop.is-catering
   p-pos-type
   {2}.src-code
   goods.gds-code
   {2}.src-price
   {2}.src-discnt
   {2}.write-off-code
   {2}.depart-type
   {2}.depart-code
    v-is-null-price
    v-valid{&seq}
    v-mess{&seq}
    v-chr-err{&seq}
    no-error
  }
  if error-status:error
  or not v-valid{&seq} then do:
    run write-log-and-file in {5} (
          input 1
        , input log-file-name
        , input 1
        , input substitute("!!!Чек &1 - ошибочный.&2"
                          , chk-doc.doc-code
                          ,v-mess{&seq})).
    assign
    for-chk-type = for-chk-type + v-chr-err{&seq} + {&comma-char}
    {2}.is-err = yes
    iserr = yes
    p-view-log = yes
    .
  end.
end.
else do:
    run write-log-and-file in {5} (
          input 1
        , input log-file-name
        , input 1
        , input substitute(
                            "!!!Чек &1 - ошибочный. &2Товар с кодом &3 отсутствует в БД"
                            , chk-doc.doc-code
                            , {&new-line}
                            , {2}.src-code
                          )
                                          ).
  assign
  for-chk-type = for-chk-type + "0" + {&comma-char}
  {2}.is-err = yes
  iserr = yes
  p-view-log = yes
  .
end.

{ str/libchkvl_chk-gds-wro.i
 chk-doc.chk-type
 {2}.line-num
 {2}.src-qnty
 {2}.write-off-code
 v-valid~{&seq~}
 v-mess~{&seq~}
 no-error
 }
if error-status:error
or not v-valid{&seq} then do:
  run write-log-and-file in {5} (
        input 1
      , input log-file-name
      , input 1
      , input substitute("!!!Чек &1 - ошибочный.&2"
                         ,chk-doc.doc-code
                         ,v-mess{&seq})).
  assign
  for-chk-type = for-chk-type + "0" + {&comma-char}
  {2}.is-err = yes
  iserr = yes
  p-view-log = yes
  .
end. /*if error-status:error*/


/* $Workfile$ e n d */