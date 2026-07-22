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
  if buf_chk-gds.src-qnty = 0
  and not(lookup(string(buf_chk-doc.chk-type), {&sale-in-receipt-codes}) > 0
         and buf_chk-gds.write-off-code > 0)  /*списание*/
  and not (lookup(string(buf_chk-doc.chk-type), {&petrol-receipt-codes}) > 0  /*глюки колонки в бензин чеках*/
           and (
                (buf_chk-gds.src-price <> 0
                and
                buf_chk-gds.src-sum / buf_chk-gds.src-price <> 0)
                or buf_chk-doc.chk-type = integer({&rcpt-trans-cancell})
               )
           )
  and not {&prefix}pos-type = {&cd-type-autotank} and not {&prefix}pos-type = {&cd-type-ibm-xml} and not {&prefix}pos-type = {&cd-type-ibm}
  then do:
    /*случай когда возвращают или списывают на возварте чек в котором было списание - второй раз списать нельз
    положим товар для информативности
    */
    assign
    iserr = yes
    for-chk-type = for-chk-type + {&amount-err} + {&comma-char}
    buf_chk-doc.correct = no
    {&prefix}view-log = yes
    .
&scop my-message substitute( ~
                            "!!!Чек &1 - ошибочный. &2 Товар с кодом &3: количество = 0" ~
                            , buf_chk-doc.doc-code ~
                            , ~{&new-line~} ~
                            , buf_chk-gds.src-code ~
                          )
    {&display-message}.
  end.
  &scop wro-code STRING(if buf_chk-gds.write-off-code <> ? then buf_chk-gds.write-off-code else 0)
  FIND FIRST buf_goods WHERE
             buf_goods.gds-code = buf_bar-code.gds-code NO-LOCK.
  FIND FIRST ub.gds-obj No-LOCK WHERE
             ub.gds-obj.gds-code = buf_bar-code.gds-code AND
             ub.gds-obj.obj-type =  buf_chk-doc.obj-type AND
             ub.gds-obj.obj-code =   buf_chk-doc.obj-code NO-ERROR.
  cashparts = IF AVAIL ub.gds-obj then ub.gds-obj.cash-parts else no.
  FIND FIRST buf_units WHERE buf_units.unit-name = buf_goods.unit-base NO-LOCK .
  if LOOKUP(buf_goods.gds-type, for-chk-type) = 0 then
  do:
    assign
    for-chk-type = for-chk-type + buf_goods.gds-type + {&comma-char}
    main-gds-type = buf_goods.gds-type
    .
  end.
  if (LOOKUP({&gds-goods}, for-chk-type) > 0
      OR
      LOOKUP({&gds-office}, for-chk-type) > 0
      )
  and LOOKUP({&amount}, for-chk-type) > 0 then do:
&scop my-message  substitute( ~
                            "!!!Чек &1 - ошибочный. &2В одном чеке смешаны товары/услуги и суммовые строки.&3" ~
                            , buf_chk-doc.doc-code ~
                            , ~{&new-line~} ~
                            , ~{&new-line~} ~
                          )
    {&dsiplay-message}.
    assign
    for-chk-type = for-chk-type + buf_goods.gds-type + {&comma-char}
    buf_chk-doc.correct = no
    buf_chk-gds.is-err = yes
    {&prefix}view-log = yes
    .
  end.
  find first ub.goods-attr where ub.goods-attr.gds-code = buf_goods.gds-code and ub.goods-attr.attr-code = {&attr-ptrl-as-good} no-error.

  if LOOKUP({&petrolium}, buf_units.type) = 0 and (available (ub.goods-attr) and ub.goods-attr.attr-value= 'yes') then do:
    buf_chk-gds.nozzle-code = 0.
    buf_chk-gds.pump = 0.
  end.

  IF buf_chk-gds.pump > 0 and LOOKUP({&petrolium}, buf_units.type) = 0 and buf_goods.gds-type = {&gds-office} then do:
    buf_chk-gds.pump = 0.
  end.
  { str/libchkvl_petrol-valid.i
   buf_chk-doc.chk-type
   buf_chk-gds.line-num
   buf_chk-doc.obj-type
   buf_chk-doc.obj-code
   {&prefix}pos-type
   buf_chk-gds.src-code
   buf_goods.gds-code
   buf_units.type
   buf_chk-gds.pump
   buf_chk-gds.nozzle-code
    v-valid~{&seq~}
    v-mess~{&seq~}
    v-chr-err~{&seq~}
    no-error
  }
  if error-status:error
  or not v-valid{&seq} then do:
&scop my-message substitute("!!!Чек &1 - ошибочный.&2" ~
                          , buf_chk-doc.doc-code ~
                          ,v-mess~{&seq~})
    {&dsiplay-message}
    assign
    for-chk-type = for-chk-type + v-chr-err{&seq} + {&comma-char}
    buf_chk-gds.is-err = yes
    iserr = yes
    {&prefix}view-log = yes
    .
  end.
  if LOOKUP( {&serial}, buf_units.type ) > 0 OR
     lookup({&twounit}, buf_units.type) > 0 OR
     lookup({&altunit}, buf_units.type) > 0 then do:
    { str/libchkvl_unit-type-qnty.i
    buf_chk-doc.chk-type
    buf_chk-gds.line-num
    buf_units.type
    ''
    buf_chk-gds.src-code
    buf_bar-code.in-code
    buf_chk-gds.src-qnty
    buf_goods.min-rate
    buf_goods.max-rate
    v-valid~{&seq~}
    v-mess~{&seq~}
    v-chr-err~{&seq~}
    no-error
    }
    if error-status:error
    or not v-valid{&seq} then do:
&scop my-message substitute("!!!Чек &1 - ошибочный.&2" ~
                            , buf_chk-doc.doc-code  ~
                            ,v-mess~{&seq~})
      {&display-message}.
      assign
      for-chk-type = for-chk-type + v-chr-err{&seq} + {&comma-char}
      buf_chk-gds.is-err = yes
      iserr = yes
      {&prefix}view-log = yes
      .
    end.
  end. /*if LOOKUP( {&serial}, buf_units.type ) > 0 OR*/
  if LOOKUP({&serial}, buf_units.type) = 0 then do:
    { str/libchkvl_part-valid.i
    buf_chk-doc.chk-type
    buf_chk-gds.line-num
    buf_units.type
    ''
    buf_chk-gds.src-code
    buf_bar-code.in-code
    buf_bar-code.part-code
    cashparts
    buf_chk-gds.src-qnty
    v-valid~{&seq~}
    v-mess~{&seq~}
    v-chr-err~{&seq~}
    no-error
    }
    if error-status:error
    or not v-valid{&seq} then do:
&scop my-message  substitute("!!!Чек &1 - ошибочный.&2" ~
                            , buf_chk-doc.doc-code ~
                            ,v-mess~{&seq~})
      {&display-message}.
      assign
      for-chk-type = for-chk-type + v-chr-err{&seq} + {&comma-char}
      buf_chk-gds.is-err = yes
      iserr = yes
      {&prefix}view-log = yes
      .
    end.
  end. /*if LOOKUP({&serial}, buf_units.type) = 0 then do:*/
   { str/libchkvl_place-valid.i
    buf_chk-doc.chk-type
    buf_chk-gds.line-num
    buf_chk-doc.obj-type
    buf_chk-doc.obj-code
    buf_chk-gds.src-code
    buf_goods.gds-code
    buf_chk-gds.loc1
    buf_chk-gds.src-pl-code
    buf_chk-gds.pl-code
    v-valid~{&seq~}
    v-mess~{&seq~}
    v-chr-err~{&seq~}
    no-error
    }
  if error-status:error
  or not v-valid{&seq} then do:
&scop my-message substitute("!!!Чек &1 - ошибочный.&2" ~
                          , buf_chk-doc.doc-code~
                          ,v-mess~{&seq~})
    {&dsiplay-message}.
    assign
    for-chk-type = for-chk-type + v-chr-err{&seq} + {&comma-char}
    buf_chk-gds.is-err = yes
    iserr = yes
    {&prefix}view-log = yes
    .
  end.
  FIND buf_gds-prt WHERE buf_gds-prt.upper-code = buf_goods.prt-root NO-LOCK .
  { str/libchkvl_prt-valid.i
    buf_chk-doc.chk-type
    buf_chk-gds.line-num
    {&prefix}doc-prt
    buf_chk-gds.src-code
    "(buf_gds-prt.node-name <> {&empty-scale})"
    buf_gds-prt.node-code
    buf_bar-code.node-code
    v-valid{&seq}
    v-mess{&seq}
    v-chr-err{&seq}
    no-error
  }
  if error-status:error
  or not v-valid{&seq} then do:
&scop my-message substitute("!!!Чек &1 - ошибочный.&2" ~
                          , buf_chk-doc.doc-code ~
                          ,v-mess~{&seq~})
    {&display-message}.
    assign
    for-chk-type = for-chk-type + v-chr-err{&seq} + {&comma-char}
    buf_chk-gds.is-err = yes
    iserr = yes
    {&prefix}view-log = yes
    .
  end.
  { str/libchkvl_fbr-valid.i
   buf_chk-doc.chk-type
   buf_chk-gds.line-num
   buf_chk-doc.obj-type
   buf_chk-doc.obj-code
   {&prefix}is-catering
   {&prefix}pos-type
   buf_chk-gds.src-code
   buf_goods.gds-code
   buf_chk-gds.src-price
   buf_chk-gds.src-discnt
   buf_chk-gds.write-off-code
   buf_chk-gds.depart-type
   buf_chk-gds.depart-code
    v-is-null-price
    v-valid{&seq}
    v-mess{&seq}
    v-chr-err{&seq}
    no-error
  }
  if error-status:error
  or not v-valid{&seq} then do:
&scop my-message  substitute("!!!Чек &1 - ошибочный.&2" ~
                          , buf_chk-doc.doc-code ~
                          ,v-mess~{&seq~})
    {&display-message}.
    assign
    for-chk-type = for-chk-type + v-chr-err{&seq} + {&comma-char}
    buf_chk-gds.is-err = yes
    iserr = yes
    {&prefix}view-log = yes
    .
  end.
end.
else do:
&scop my-message  substitute( ~
                            "!!!Чек &1 - ошибочный. &2Товар с кодом &3 отсутствует в БД" ~
                            , buf_chk-doc.doc-code ~
                            , ~{&new-line~} ~
                            , buf_chk-gds.src-code ~
                          )
  {&display-message}.
  assign
  for-chk-type = for-chk-type + "0" + {&comma-char}
  buf_chk-gds.is-err = yes
  iserr = yes
  {&prefix}view-log = yes
  .
end.

{ str/libchkvl_chk-gds-wro.i
 buf_chk-doc.chk-type
 buf_chk-gds.line-num
 buf_chk-gds.src-qnty
 buf_chk-gds.write-off-code
 v-valid~{&seq~}
 v-mess~{&seq~}
 no-error
 }
if error-status:error
or not v-valid{&seq} then do:
&scop my-message substitute("!!!Чек &1 - ошибочный.&2" ~
                         ,buf_chk-doc.doc-code ~
                         ,v-mess~{&seq~})
  {&display-message}.
  assign
  for-chk-type = for-chk-type + "0" + {&comma-char}
  buf_chk-gds.is-err = yes
  iserr = yes
  {&prefix}view-log = yes
  .
end. /*if error-status:error*/


/* $Workfile$ e n d */