/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

i-для правила 1973

Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/18/08
Author: Bakhtadze Natalya
Creation date: 08/18/08

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".


if lookup(string(v-templ-rl-root), "42") > 0
then  do:
  v-bh[{&chk-discnt}]:buffer-create.
  v-bh[{&chk-discnt}]:buffer-copy(v-bh[{&chk-doc}]).
  v-inversed-chr = (if v-inversed then "i":U else "").
  assign
  v-bh[{&chk-discnt}]:buffer-field("record-type"):buffer-value = 0
  v-bh[{&chk-discnt}]:buffer-field("line-type"):buffer-value = v-line-type
  v-bh[{&chk-discnt}]:buffer-field("discnt-id"):buffer-value = v-bh[{&chk-context}]:buffer-field("discnt-id"):buffer-value + 1
  v-bh[{&chk-context}]:buffer-field("discnt-id"):buffer-value = v-bh[{&chk-context}]:buffer-field("discnt-id"):buffer-value + 1

  v-bh[{&chk-discnt}]:buffer-field("line-num"):buffer-value = (if buf_temp-discnt-role.table-name = {&table_dis-gds-rule}
                                                              then v-bh[{&chk-gds}]:buffer-field("line-num"):buffer-value
                                                              else v-bh[{&chk-pay}]:buffer-field("line-num"):buffer-value)
  v-bh[{&chk-context}]:buffer-field("lnd"):buffer-value  = v-bh[{&chk-context}]:buffer-field("lnd"):buffer-value + 1

  v-bh[{&chk-discnt}]:buffer-field("doc-code"):buffer-value = v-bh[{&chk-doc}]:buffer-field("doc-code"):buffer-value
  v-bh[{&chk-discnt}]:buffer-field("pay-desk"):buffer-value = v-bh[{&chk-doc}]:buffer-field("pay-desk"):buffer-value
  v-bh[{&chk-discnt}]:buffer-field("obj-type"):buffer-value = v-bh[{&chk-doc}]:buffer-field("obj-type"):buffer-value
  v-bh[{&chk-discnt}]:buffer-field("obj-code"):buffer-value = v-bh[{&chk-doc}]:buffer-field("obj-code"):buffer-value
  v-bh[{&chk-discnt}]:buffer-field("chk-date"):buffer-value = v-bh[{&chk-doc}]:buffer-field("chk-date"):buffer-value
  v-bh[{&chk-discnt}]:buffer-field("chk-time"):buffer-value = v-bh[{&chk-doc}]:buffer-field("chk-time"):buffer-value
  v-bh[{&chk-discnt}]:buffer-field("time-oper"):buffer-value = v-bh[{&chk-context}]:buffer-field("current-time"):buffer-value
  v-bh[{&chk-discnt}]:buffer-field("src-d-card"):buffer-value = v-bh[{&chk-doc}]:buffer-field("src-d-card"):buffer-value
  v-bh[{&chk-discnt}]:buffer-field("kateg"):buffer-value = v-bh[{&chk-context}]:buffer-field("category"):buffer-value
  v-bh[{&chk-discnt}]:buffer-field("rank"):buffer-value = buf_temp-rule-call-param.p-index
  v-bh[{&chk-discnt}]:buffer-field("pass-discnt"):buffer-value = integer({&discnt-p-auto})
  v-bh[{&chk-discnt}]:buffer-field("rule-num"):buffer-value = v-rule-num
  v-bh[{&chk-discnt}]:buffer-field("templ-rl-root"):buffer-value = v-templ-rl-root
  v-bh[{&chk-discnt}]:buffer-field("discnt-type"):buffer-value = buf_temp-discnt-role.discnt-type
  v-bh[{&chk-discnt}]:buffer-field("discnt-role"):buffer-value = buf_temp-discnt-role.discnt-role

  v-bh[{&chk-discnt}]:buffer-field("object-line-num"):buffer-value = (if buf_temp-discnt-role.table-name = {&table_dis-gds-rule}
                                                                      then v-bh[{&chk-gds}]:buffer-field("line-num"):buffer-value
                                                                      else v-bh[{&chk-pay}]:buffer-field("line-num"):buffer-value
                                                                      )
  /*todo пока пишем из строки  надо устанавливать количество внутри правила если link-prop не 0 */
  v-bh[{&chk-discnt}]:buffer-field("object-qnty"):buffer-value = (if buf_temp-discnt-role.table-name = {&table_dis-gds-rule}
                                                                  then v-bh[{&chk-gds}]:buffer-field("src-qnty"):buffer-value
                                                                  else v-bh[{&chk-context}]:buffer-field("src-qnty"):buffer-value)
  /*todo пока пишем из строки  надо устанавливать сумму внутри правила если link-prop не 0 */
  v-bh[{&chk-discnt}]:buffer-field("object-sum"):buffer-value = (if buf_temp-discnt-role.table-name = {&table_dis-gds-rule}
                                                                 then (v-bh[{&chk-gds}]:buffer-field("src-price-netto"):buffer-value +
                                                                       v-bh[{&chk-gds}]:buffer-field("src-qnty"):buffer-value
                                                                       )
                                                                 else v-bh[{&chk-pay}]:buffer-field("brutto-r-b"):buffer-value)
  .
  /*
  заполняется при постобработке
  chk-discnt.d-card -

  заполняется внутри правила через регистр

  chk-discnt.value-type

  chk-discnt.discnt-value-abs
  или
  chk-discnt.discnt-value-pcnt

  */
  { str/cdrdcal1.i create-new-record v-templ-rl-root this-procedure:handle p-dr-flddf }

  { str/cdrdcal1.i create-call v-templ-rl-root this-procedure:handle }

  { str/cdrdcal1.i invoke v-templ-rl-root  v-bh }

  /*в переменные вернем значения, которые возможно были изменены правилом*/
  /*все скидки в итоге должны выражаться в дельте удельной скидки*/
  /*
  заполняется после выполнения правила
  v-bh[{&chk-discnt}]:buffer-field("line-sign"):buffer-value

  заполняется после выполнения правила
  chk-discnt.discnt-value-abs
  или
  chk-discnt.discnt-value-pcnt
  */
  /*на этом месте мы уже в регистрах имеем правильные значения*/
  /*возвращаемое всегда discnt-value-abs*/
  if v-inversed then do:
    v-bh[{&chk-discnt}]:buffer-field("object-sum"):buffer-value =
    v-bh[{&chk-discnt}]:buffer-field("object-sum"):buffer-value /* + v-bh[{&chk-discnt}]:buffer-field("discnt-value-abs"):buffer-value*/  .
  end.
  if v-bh[{&chk-discnt}]:buffer-field("value-type"):buffer-value =  integer({&discnt-v-pcnt}) then do:
    /*возвращаемое всегда discnt-value-abs поэтому его не пересчитываем*/

  end.
  else do:
    v-bh[{&chk-discnt}]:buffer-field("discnt-value-pcnt"):buffer-value =
              v-bh[{&chk-discnt}]:buffer-field("discnt-value-abs"):buffer-value /
              v-bh[{&chk-discnt}]:buffer-field("object-sum"):buffer-value * 100
              .
  end.
  assign
  v-delta-discnt-r-b = v-bh[{&chk-discnt}]:buffer-field("discnt-value-abs"):buffer-value
  .
  if v-bh[{&context}]:buffer-field("r-b"):buffer-value = {&r-b-rubl} then do:
    assign
    v-delta-discnt-rubl = v-delta-discnt-r-b
    v-new-rubl-sum = v-rubl-sum - v-delta-discnt-rubl * integer(not v-inversed)
    v-new-discnt-rubl = v-discnt-rubl + v-delta-discnt-rubl
    .
    if v-bh[{&context}]:buffer-field("base-code"):buffer-value = 0 then do:
      assign
      v-delta-discnt-base = v-delta-discnt-r-b
      v-new-base-sum = v-base-sum - v-delta-discnt-base * integer(not v-inversed)
      v-new-discnt-base = v-discnt-base + v-delta-discnt-base
      .
    end.
    else do:
      assign
      v-delta-discnt-base = v-delta-discnt-r-b * v-bh[{&chk-context}]:buffer-field("base-rate"):buffer-value
      v-new-base-sum = v-base-sum - v-delta-discnt-base * integer(not v-inversed)
      v-new-discnt-base = v-discnt-base + v-delta-discnt-base
      .
    end.
  end.
  else do:
    assign
    v-delta-discnt-base = v-delta-discnt-r-b
    v-new-base-sum = v-base-sum - v-delta-discnt-base  * integer(not v-inversed)
    v-new-discnt-base = v-discnt-base + v-delta-discnt-base
    .
    if  v-bh[{&context}]:buffer-field("base-code"):buffer-value = 0 then do:
      assign
      v-delta-discnt-rubl = v-delta-discnt-r-b
      v-new-rubl-sum = v-rubl-sum - v-delta-discnt-base * integer(not v-inversed)
      v-new-discnt-rubl = v-discnt-rubl + v-delta-discnt-base
      .
    end.
    else do:
      assign
      v-delta-discnt-base = v-delta-discnt-r-b / v-bh[{&chk-context}]:buffer-field("base-rate"):buffer-value
      v-new-base-sum = v-base-sum - v-delta-discnt-base * integer(not v-inversed)
      v-new-discnt-base = v-discnt-base + v-delta-discnt-base
      .
    end.
  end.
  if v-curr-code = 0 then do:
    assign
    v-delta-discnt-curr = v-delta-discnt-rubl
    v-new-curr-sum = v-curr-sum - v-delta-discnt-curr * integer(not v-inversed)
    v-new-discnt-curr = v-discnt-curr + v-delta-discnt-curr
    .
  end.
  else do:
    if v-curr-code = v-bh[{&context}]:buffer-field("base-code"):buffer-value then do:
      assign
      v-delta-discnt-curr = v-delta-discnt-base
      v-new-curr-sum = v-curr-sum - v-delta-discnt-curr  * integer(not v-inversed)
      v-new-discnt-curr = v-discnt-curr + v-delta-discnt-curr
      .
    end.
    else do:
      assign
      v-delta-discnt-curr = v-delta-discnt-rubl / v-bh[{&chk-pay}]:buffer-field("exch-rate"):buffer-value * v-bh[{&chk-pay}]:buffer-field("exch-scale"):buffer-value
      v-new-curr-sum = v-curr-sum - v-delta-discnt-curr * integer(not v-inversed)
      v-new-discnt-curr = v-discnt-curr + v-delta-discnt-curr
      .
    end.
  end.
  if v-bh[{&chk-discnt}]:buffer-field("intended"):buffer-value = no
  and v-bh[{&chk-discnt}]:buffer-field("not-found"):buffer-value = no
  then do:
    if v-inversed then do:
      create buf_chk-discnt.
      buffer buf_chk-discnt:handle:buffer-copy(v-bh[{&chk-discnt}]).
      if buf_temp-discnt-role.table-name = {&table_dis-cp-rule} then do:
        assign
        buffer buf_chk-discnt:handle:buffer-field("object-sum"):buffer-value = v-bh[{&chk-context}]:buffer-field("netto"):buffer-value
        .
      end.
      run printbuffer in this-procedure ( input v-bh[{&chk-discnt}]).
      release buf_chk-discnt.
    end. /*if not v-inversed then do:*/
    v-bh[{&chk-discnt}]:buffer-release().
    v-found = yes.
  end.
  else do:
    v-bh[{&chk-discnt}]:buffer-delete().
    v-found = no.
  end.
end. /*if v-templ-rl-root < 10 then  do:*/


/* $Workfile$ e n d */