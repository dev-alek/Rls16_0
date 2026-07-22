/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Динамический вызов функции обсчитывающей dis-rule

Автор: Бахтадзе Наталья Викторовна
Дата создания: 06/13/07
Author: Bakhtadze Natalya
Creation date: 06/13/07

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&if "{1}" = "deftt" &then
define protected temp-table temp-call-param no-undo
field call-number as integer /*наращиваемый счетчик*/
field call-name_ as character
field param-name_ as character
field param-label_ as character
field num-params_ as integer
field call-handle_ as handle /*может быть только для записи с param-number = 0 это запись для самого call*/
field param-number_ as integer
field param-datatype_ as character
field io-mode_ as character
field character_ as character
field date_ as date
field decimal_ as decimal
field integer_ as integer
field logical_ as logical
index pi is unique primary call-name_ param-number_.

define protected variable v-last-call-name as character no-undo .
define protected variable v-last-call-number as int64 no-undo .
&endif

&if "{1}" = "def" &then
define variable v-ii as integer no-undo .
define buffer buf_temp-call-param for temp-call-param.
define buffer buf2_temp-call-param for temp-call-param.
define buffer buf_drt-prop for ub.drt-prop.
&endif

&if "{1}" = "create-new-record" &then
find first buf_temp-call-param where
        buf_temp-call-param.call-name_ = substitute("dis-rule_&1", string({2}, "99999"))
    and buf_temp-call-param.param-num = 0 no-error .
if not available buf_temp-call-param then do:
  if v_gc:get-signature(substitute("dis-rule_&1", string({2}, "99999"))) = '':u then do:
    undo, return error substitute("Определение &1 отсутствует в &2"
                                   ,substitute("dis-rule_&1", string({2}, "99999"))
                                   , v_gc:file-name).
  end.
  create buf_temp-call-param.
  assign
  buf_temp-call-param.call-name_ = substitute("dis-rule_&1", string({2}, "99999"))
  buf_temp-call-param.param-number_ = 0
  .
  for each buf_drt-prop no-lock where
          buf_drt-prop.templ-rl-root = {2}
      and buf_drt-prop.upper-prop-code = "Call-params"
    on error  undo , return error substitute( "&1. &2&3&4", vss-include-info{&vssseq},  return-value, {&new-line}, error-status :get-message (1))
    on stop   undo , return error substitute( "&1. stop", vss-include-info{&vssseq} )
    on endkey undo , return error substitute( "&1. endkey", vss-include-info{&vssseq} ):
    if integer(buf_drt-prop.prop-code) = 0 then do:
      assign
      buf_temp-call-param.call-name_ = substitute("dis-rule_&1", string({2}, "99999"))
      buf_temp-call-param.param-number_ = integer(buf_drt-prop.prop-code)
      buf_temp-call-param.param-name_ = entry(1, buf_drt-prop.property-value)
      buf_temp-call-param.param-datatype_ = entry(2, buf_drt-prop.property-value)
      buf_temp-call-param.io-mode_ = entry(3, buf_drt-prop.property-value)
      buf_temp-call-param.param-label_ = entry(4, buf_drt-prop.property-value)
      .
    end.
    else do:
      create buf2_temp-call-param.
      assign
      v-ii = v-ii + 1
      buf2_temp-call-param.call-name_ = substitute("dis-rule_&1", string({2}, "99999"))
      buf2_temp-call-param.param-number_ = integer(buf_drt-prop.prop-code)
      buf2_temp-call-param.param-name_ = entry(1, buf_drt-prop.property-value)
      buf2_temp-call-param.param-datatype_ = entry(2, buf_drt-prop.property-value)
      buf2_temp-call-param.io-mode_ = entry(3, buf_drt-prop.property-value)
      buf2_temp-call-param.param-label_ = entry(4, buf_drt-prop.property-value)
      .
    end.
  end.
  assign
  buf_temp-call-param.num-params = v-ii
  .
end.
&endif

&if "{1}" = "create-call" &then
  find first buf_temp-call-param where
            buf_temp-call-param.call-name_ = substitute("dis-rule_&1", string({2}, "99999"))
        and buf_temp-call-param.param-number = 0.
  if not valid-handle(buf_temp-call-param.call-handle_) then do:
    create call buf_temp-call-param.call-handle_.
    assign
    buf_temp-call-param.call-handle_:call-name = buf_temp-call-param.call-name_
    buf_temp-call-param.call-handle_:call-type = FUNCTION-CALL-TYPE
    buf_temp-call-param.call-handle_:in-handle = v_gc
    buf_temp-call-param.call-handle_:num-parameters = buf_temp-call-param.num-params
    .
  end.
&Endif

&if "{1}" = "invoke" &then
  for each buf2_temp-call-param where
          buf2_temp-call-param.param-num > 0
  on error  undo , return error substitute( "&1. &2&3&4", vss-include-info{&vssseq},  return-value, {&new-line}, error-status :get-message (1))
  on stop   undo , return error substitute( "&1. stop", vss-include-info{&vssseq} )
  on endkey undo , return error substitute( "&1. endkey", vss-include-info{&vssseq} ):
    buf_temp-call-param.call-handle_:set-parameter( buf2_temp-call-param.param-num
                                                    ,buf2_temp-call-param.param-datatype_
                                                    ,buf2_temp-call-param.io-mode
                                                    ,buffer buf2_temp-call-param:buffer-field( substitute("&1_", buf2_temp-call-param.param-datatype_)):buffer-value).
  end.
  assign
  buf_temp-call-param.call-number = buf_temp-call-param.call-number + 1
  v-last-call-number = buf_temp-call-param.call-number
  v-last-call-name = buf_temp-call-param.call-name_
  .
  buf_temp-call-param.call-handle_:invoke.
  assign
  buf_temp-call-param.param-datatype_ = buf_temp-call-param.call-handle_:return-value-data-type.
  case buf_temp-call-param.param-datatype_:
      when {&abl-datatype-character} then do:
        assign
        buf_temp-call-param.character_ = buf_temp-call-param.call-handle_:return-value.
      end.
      when {&abl-datatype-date} then do:
        assign
        buf_temp-call-param.date_ = buf_temp-call-param.call-handle_:return-value.
      end.
      when {&abl-datatype-decimal} then do:
        assign
        buf_temp-call-param.decimal_ = buf_temp-call-param.call-handle_:return-value.
      end.
      when {&abl-datatype-integer} then do:
        assign
        buf_temp-call-param.integer_ = buf_temp-call-param.call-handle_:return-value.
      end.
      when {&abl-datatype-logical} then do:
        assign
        buf_temp-call-param.logical_ = buf_temp-call-param.call-handle_:return-value.
      end.
  end case.
&Endif
&if "{1}" = "return-value-methods" &then
  method public decimal get_dis-rule-value_decimal ( input p-param-name as character):
    define buffer buf_temp-call-param for temp-call-param.
    find first buf_temp-call-param where
              buf_temp-call-param.param-name_ = p-param-name
          and buf_temp-call-param.call-name_ = v-last-call-name no-error .
    if not available buf_temp-call-param then do:
      undo, return error substitute("&1 данные о результатах расчета &2 по правилу скидки - параметр &3 - отсутствуют"
                                   ,vss-include-info{&vssseq}
                                   ,v-last-call-name
                                   ,p-param-name).

    end.
    if buf_temp-call-param.call-number <> v-last-call-number then do:
      undo, return error substitute("&1 данные о результатах расчета &2 по правилу скидки - параметр &3 - уже затерты"
                                   ,vss-include-info{&vssseq}
                                   ,v-last-call-name
                                   ,p-param-name).
    end.
    return buf_temp-call-param.decimal_.
  end method.
  method public integer get_dis-rule-value_integer ( input p-param-name as character):
    define buffer buf_temp-call-param for temp-call-param.
    find first buf_temp-call-param where
              buf_temp-call-param.param-name_ = p-param-name
          and buf_temp-call-param.call-name_ = v-last-call-name no-error .
    if not available buf_temp-call-param then do:
      undo, return error substitute("&1 данные о результатах расчета &2 по правилу скидки - параметр &3 - отсутствуют"
                                   ,vss-include-info{&vssseq}
                                   ,v-last-call-name
                                   ,p-param-name).

    end.
    if buf_temp-call-param.call-number <> v-last-call-number then do:
      undo, return error substitute("&1 данные о результатах расчета &2 по правилу скидки - параметр &3 - уже затерты"
                                   ,vss-include-info{&vssseq}
                                   ,v-last-call-name
                                   ,p-param-name).
    end.
    return buf_temp-call-param.integer_.
  end method.
  method public logical get_dis-rule-value_logical ( input p-param-name as character):
    define buffer buf_temp-call-param for temp-call-param.
    find first buf_temp-call-param where
              buf_temp-call-param.param-name_ = p-param-name
          and buf_temp-call-param.call-name_ = v-last-call-name no-error .
    if not available buf_temp-call-param then do:
      undo, return error substitute("&1 данные о результатах расчета &2 по правилу скидки - параметр &3 - отсутствуют"
                                   ,vss-include-info{&vssseq}
                                   ,v-last-call-name
                                   ,p-param-name).

    end.
    if buf_temp-call-param.call-number <> v-last-call-number then do:
      undo, return error substitute("&1 данные о результатах расчета &2 по правилу скидки - параметр &3 - уже затерты"
                                   ,vss-include-info{&vssseq}
                                   ,v-last-call-name
                                   ,p-param-name).
    end.
    return buf_temp-call-param.logical_.
  end method.
&endif