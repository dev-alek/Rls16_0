/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Динамический вызов функции обсчитывающей dis-rule

Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/07/08
Author: Bakhtadze Natalya
Creation date: 08/07/08

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&if "{1}" = "deftt" &then
define temp-table temp-call-param no-undo
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
field fld-df as character /*уникальное имя поля*/
field field-name_ as CHARACTER /*имя поля которое хранит нужный нам регистр*/
field table-no as integer
field field-handle as handle /*handle */
index pi is unique primary call-name_ param-number_.

define variable v-last-call-name as character no-undo .
define variable v-last-call-number as int64 no-undo .
define variable v-inversed-chr as character no-undo init ''.

&endif

&if "{1}" = "def" &then
define variable v-ii as integer no-undo .
define buffer buf_temp-call-param for temp-call-param.
define buffer buf2_temp-call-param for temp-call-param.
define buffer buf_drt-prop for ub.drt-prop.
&endif

&if "{1}" = "create-new-record" &then

/*
{2} номер шаблона правила сскидок
{3} handle процедуры, содержащей функции лоя правил скидок
{4} handle буффера, харнящего ссылки на регистры

*/

define variable glog{&vssseq} as logical no-undo .

find first buf_temp-call-param where
        buf_temp-call-param.call-name_ = substitute("dis-rule_rf_&1&2", string({2}, "99999"), v-inversed-chr)
    and buf_temp-call-param.param-num = 0 no-error .
if not available buf_temp-call-param then do:
  if {3}:get-signature(substitute("dis-rule_rf_&1&2", string({2}, "99999"), v-inversed-chr )) = '':u then do:
    undo, return error substitute("Определение &1 отсутствует в &2"
                                   ,substitute("dis-rule_rf_&1&2", string({2}, "99999"), v-inversed-chr)
                                   , {3}:file-name).
  end.
  create buf_temp-call-param.
  assign
  buf_temp-call-param.call-name_ = substitute("dis-rule_rf_&1&2", string({2}, "99999"), v-inversed-chr)
  buf_temp-call-param.param-number_ = 0
  v-ii = 0
  .
  for each buf_drt-prop no-lock where
          buf_drt-prop.templ-rl-root = {2}
      and buf_drt-prop.upper-prop-code = "Run-params" + v-inversed-chr
    on error  undo , return error substitute( "&1. &2&3&4", vss-include-info{&vssseq},  return-value, {&new-line}, error-status :get-message (1))
    on stop   undo , return error substitute( "&1. stop", vss-include-info{&vssseq} )
    on endkey undo , return error substitute( "&1. endkey", vss-include-info{&vssseq} ):
    if integer(buf_drt-prop.prop-code) = 0 then do:
      assign
      buf_temp-call-param.call-name_ = substitute("dis-rule_rf_&1&2", string({2}, "99999"), v-inversed-chr)
      buf_temp-call-param.param-number_ = integer(buf_drt-prop.prop-code)
      buf_temp-call-param.param-name_ = entry(1, buf_drt-prop.property-value)
      buf_temp-call-param.param-datatype_ = entry(2, buf_drt-prop.property-value)
      buf_temp-call-param.io-mode_ = entry(3, buf_drt-prop.property-value)
      buf_temp-call-param.param-label_ = entry(4, buf_drt-prop.property-value)
      buf_temp-call-param.fld-df = entry(5, buf_drt-prop.property-value)
      .
      glog{&vssseq} = {4}:find-first( substitute(' where fld-df = &1&2&1', {&double-quote}, buf_temp-call-param.fld-df, {&double-quote})) no-error.
      if {4}:available = no then do:
        message
        substitute("Не определен регистр &1 параметра &2 для расчета скидок/бонусов по правилу с шаблоном &3"
                                      ,buf_temp-call-param.fld-df
                                      ,buf_temp-call-param.param-name_
                                      ,{2})
        view-as alert-box error .
        undo, return error substitute("Не определен регистр &1 параметра &2 для расчета скидок/бонусов по правилу с шаблоном &3"
                                      ,buf_temp-call-param.fld-df
                                      ,buf_temp-call-param.param-name_
                                      ,{2}).

      end.
      assign
      buf_temp-call-param.field-name_ = {4}::field-name_
      buf_temp-call-param.table-no = {4}::table-no
      buf_temp-call-param.num-params = v-ii
      .
    end.
    else do:
      create buf2_temp-call-param.
      assign
      v-ii = v-ii + 1
      buf2_temp-call-param.call-name_ = substitute("dis-rule_rf_&1&2", string({2}, "99999"), v-inversed-chr)
      buf2_temp-call-param.param-number_ = integer(buf_drt-prop.prop-code)
      buf2_temp-call-param.param-name_ = entry(1, buf_drt-prop.property-value)
      buf2_temp-call-param.param-datatype_ = entry(2, buf_drt-prop.property-value)
      buf2_temp-call-param.io-mode_ = entry(3, buf_drt-prop.property-value)
      buf2_temp-call-param.param-label_ = entry(4, buf_drt-prop.property-value)
      buf2_temp-call-param.fld-df = entry(5, buf_drt-prop.property-value)
      .
      glog{&vssseq} = {4}:find-first( substitute(' where fld-df = &1&2&1', {&double-quote}, buf2_temp-call-param.fld-df, {&double-quote})) no-error.
      if {4}:available = no then do:
        message
        substitute("Не определен регистр &1 параметра &2 для расчета скидок/бонусов по правилу с шаблоном &3"
                                      ,buf2_temp-call-param.fld-df
                                      ,buf2_temp-call-param.param-name_
                                      ,{2})
        view-as alert-box error .

        undo, return error substitute("Не определен регистр &1 параметра &2 для расчета скидок/бонусов по правилу с шаблоном &3"
                                      ,buf2_temp-call-param.fld-df
                                      ,buf2_temp-call-param.param-name_
                                      ,{2}).

      end.
      assign
      buf2_temp-call-param.field-name_ = {4}::field-name_
      buf2_temp-call-param.table-no = {4}::table-no
      .
    end.
  end.
  assign
  buf_temp-call-param.num-params = v-ii
  .
end.
&endif

&if "{1}" = "create-call" &then

/*
{2} номер шаблона правила сскидок
{3} handle процедуры, содержащей функции лоя правил скидок
*/

  find first buf_temp-call-param where
            buf_temp-call-param.call-name_ = substitute("dis-rule_rf_&1&2", string({2}, "99999"), v-inversed-chr)
        and buf_temp-call-param.param-number = 0.
  if not valid-handle(buf_temp-call-param.call-handle_) then do:
    create call buf_temp-call-param.call-handle_.
    assign
    buf_temp-call-param.call-handle_:call-name = buf_temp-call-param.call-name_
    buf_temp-call-param.call-handle_:call-type = FUNCTION-CALL-TYPE
    buf_temp-call-param.call-handle_:in-handle = {3}
    buf_temp-call-param.call-handle_:num-parameters = buf_temp-call-param.num-params
    .
  end.
&Endif

&if "{1}" = "invoke" &then
/*
{2} - номер шаблона правила сскидок
{3} - массив буферов хранящихз регистры
*/
  define variable glog{&vssseq} as logical   no-undo .
  define variable v-dt-tp{&vssseq}  as character no-undo .

  for each buf2_temp-call-param where
          buf2_temp-call-param.param-num > 0
      and buf2_temp-call-param.call-name_ = substitute("dis-rule_rf_&1&2", string({2}, "99999"), v-inversed-chr)
  on error  undo , return error substitute( "&1. &2&3&4", vss-include-info{&vssseq},  return-value, {&new-line}, error-status :get-message (1))
  on stop   undo , return error substitute( "&1. stop", vss-include-info{&vssseq} )
  on endkey undo , return error substitute( "&1. endkey", vss-include-info{&vssseq} ):
      if {3}[buf2_temp-call-param.table-no]:buffer-field(buf2_temp-call-param.field-name_):buffer-value = ? then
      do:
         case buf2_temp-call-param.param-datatype_:
            when "decimal"  or when "integer" then
            do:
    glog{&vssseq} = buf_temp-call-param.call-handle_:set-parameter( buf2_temp-call-param.param-num
                                                    ,buf2_temp-call-param.param-datatype_
                                                    ,buf2_temp-call-param.io-mode
                                                    ,0
                                                    ).

            end.
            when "character" then
            do:
    glog{&vssseq} = buf_temp-call-param.call-handle_:set-parameter( buf2_temp-call-param.param-num
                                                    ,buf2_temp-call-param.param-datatype_
                                                    ,buf2_temp-call-param.io-mode
                                                    ,""
                                                    ).

            end.
         end case .
      end.
      else
    glog{&vssseq} = buf_temp-call-param.call-handle_:set-parameter( buf2_temp-call-param.param-num
                                                    ,buf2_temp-call-param.param-datatype_
                                                    ,buf2_temp-call-param.io-mode
                                                    ,{3}[buf2_temp-call-param.table-no]:buffer-field(buf2_temp-call-param.field-name_):buffer-value
                                                    ).
  end.
  assign
  buf_temp-call-param.call-number = buf_temp-call-param.call-number + 1
  v-last-call-number = buf_temp-call-param.call-number
  v-last-call-name = buf_temp-call-param.call-name_
  .

  buf_temp-call-param.call-handle_:invoke.
    if buf_temp-call-param.call-handle_:return-value = ? then
    do:
       v-dt-tp{&vssseq} = v-bh[buf_temp-call-param.table-no]:buffer-field(buf_temp-call-param.field-name_):data-type .
       if v-dt-tp{&vssseq} = "decimal" or v-dt-tp{&vssseq} = "integer" then
       do:
v-bh[buf_temp-call-param.table-no]:buffer-field(buf_temp-call-param.field-name_):buffer-value = 0 .

       end.
    end.
    else
    do:
  v-bh[buf_temp-call-param.table-no]:buffer-field(buf_temp-call-param.field-name_):buffer-value = buf_temp-call-param.call-handle_:return-value.
    end.
&Endif

&if "{1}" = "clear" &then
define buffer buf_temp-call-param for temp-call-param.
for each buf_temp-call-param where
        buf_temp-call-param.param-num = 0:
  delete object buf_temp-call-param.call-handle_.
  delete buf_temp-call-param.
end.
&endif

/* $Workfile$ e n d */