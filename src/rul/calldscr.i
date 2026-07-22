/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/08/07
Author: Bakhtadze Natalya
Creation date: 04/08/07

*/


&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

{ gbl/key-rec.i }
{ gbl/get-regf.i }

FUNCTION calldscr returns character ( input p-call-id as character):
define variable v-descr as character no-undo .
define variable v-field-list as character no-undo .
define variable v-value-list as character no-undo.
define variable v-prop-label as character no-undo .
define variable v-node-label as character no-undo .
define variable v-dt-code as integer no-undo .
define variable v-host-code as integer no-undo .
define variable v-obj-type as character no-undo .
define variable v-obj-code as integer no-undo .
define variable v-label as character no-undo .
define variable v-node-code as integer no-undo .

define buffer buf_prop-head for ub.prop-head.
define buffer buf_prop-ref for ub.prop-ref.
define buffer buf_prop-map for ub.prop-map.


run gen-key-fv in this-procedure ( input p-call-id
                                  ,output v-field-list
                                  ,output v-value-list) no-error .
if error-status:error then return p-call-id.
CASE entry(1, p-call-id, {&delim-key}):
  when {&table_dis-card-type} then do:
    v-descr = substitute("Тип ДК: эмитент &1 тип: &2"
                         ,integer(entry(lookup("emitent-host-code", v-field-list, {&delim-key}), v-value-list, {&delim-key}) )
                         ,entry(lookup("type", v-field-list, {&delim-key}), v-value-list, {&delim-key})
                         ).
  end.
  when {&table_dis-card} then do:
    v-descr = substitute("ДК: № &1"
                         ,entry(lookup("d-card", v-field-list, {&delim-key}), v-value-list, {&delim-key})
                         ).
  end.
  when {&table_dis-card-property} then do:
    v-dt-code = integer(entry(lookup("dt-code", v-field-list, {&delim-key}), v-value-list, {&delim-key}) ).
    v-node-code = integer(entry(lookup("node-code", v-field-list, {&delim-key}), v-value-list, {&delim-key}) ).
    v-host-code = integer(entry(lookup("host-code", v-field-list, {&delim-key}), v-value-list, {&delim-key}) ).
    v-obj-type = entry(lookup("obj-type", v-field-list, {&delim-key}), v-value-list, {&delim-key}) .
    v-obj-code = integer(entry(lookup("obj-code", v-field-list, {&delim-key}), v-value-list, {&delim-key}) ).
    find first buf_prop-ref no-lock where
              buf_prop-ref.dt-code = v-dt-code no-error .
    if available buf_prop-ref then do:
      find first buf_prop-head no-lock where
                buf_prop-head.dtm-code = buf_prop-ref.dtm-code no-error .
      v-prop-label = buf_prop-head.prop-label.
      find first buf_prop-map no-lock where
                buf_prop-map.dtm-code = buf_prop-ref.dtm-code
            and buf_prop-map.node-code = v-node-code no-error .
      if available buf_prop-map then do:
        v-label = buf_prop-map.node-label.
      end.
    end.
    v-descr = substitute("ДК: № &1 &2:&3 &4"
                         ,entry(lookup("d-card", v-field-list, {&delim-key}), v-value-list, {&delim-key})
                         ,v-prop-label
                         ,v-label
                         ,get-region(v-host-code, v-obj-type, v-obj-code)
                         ).
  end.
  when {&table_clients} then do:
    v-descr = substitute("&1&2"
                         ,entry(lookup("obj-type", v-field-list, {&delim-key}), v-value-list, {&delim-key})
                         ,integer(entry(lookup("obj-code", v-field-list, {&delim-key}), v-value-list, {&delim-key}) )
                         ).
  end.
  when {&table_ext-system} then do:
    v-descr = substitute("Внешняя система &1"
                         ,integer(entry(lookup("esys-id", v-field-list, {&delim-key}), v-value-list, {&delim-key}))
                         ).
  end.
  WHEN {&TABLE_THBJ-ATTR} then do:
    if entry(lookup("upper-prop-code", v-field-list, {&delim-key}), v-value-list, {&delim-key}) = {&attr-rum}
    or entry(lookup("upper-prop-code", v-field-list, {&delim-key}), v-value-list, {&delim-key}) = {&attr-rum_obj}
    then do:
      if entry(lookup("prop-code", v-field-list, {&delim-key}), v-value-list, {&delim-key}) = {&attr-rum_goods} then do:
        v-descr = "Операции с товарами".
      end.
      if entry(lookup("prop-code", v-field-list, {&delim-key}), v-value-list, {&delim-key}) = {&attr-rum_clients} then do:
        v-descr = "Операции с клиентами".
      end.
      if entry(lookup("prop-code", v-field-list, {&delim-key}), v-value-list, {&delim-key}) = {&attr-rum_gds-grp} then do:
        v-descr = "Операции с группами товаров".
      end.
      if entry(lookup("prop-code", v-field-list, {&delim-key}), v-value-list, {&delim-key}) = {&attr-rum_cli-grp} then do:
        v-descr = "Операции с группами клиентов".
      end.
      if entry(lookup("prop-code", v-field-list, {&delim-key}), v-value-list, {&delim-key}) = {&attr-rum_chk-doc_ibs-th} then do:
        v-descr = "Операции с чеками на POS IBS-TH".
      end.
      if entry(lookup("prop-code", v-field-list, {&delim-key}), v-value-list, {&delim-key}) = {&attr-rum_chk-doc_ibs-th-mob} then do:
        v-descr = "Операции с чеками на POS IBS-TH-MOB".
      end.
      if entry(lookup("prop-code", v-field-list, {&delim-key}), v-value-list, {&delim-key}) = {&attr-rum_edoc} then do:
        v-descr = "Операции в системе электронного документооборота".
      end.
      if entry(lookup("prop-code", v-field-list, {&delim-key}), v-value-list, {&delim-key}) = {&attr-rum_thref} then do:
        v-descr = "Операции со справочниками".
      end.
      if entry(lookup("prop-code", v-field-list, {&delim-key}), v-value-list, {&delim-key}) = {&attr-rum_pdf} then do:
        v-descr = "Операции с ДНЦ и переоценками".
      end.
      if entry(lookup("prop-code", v-field-list, {&delim-key}), v-value-list, {&delim-key}) = {&attr-rum_rep} then do:
        v-descr = "Отчеты".
      end.
      if entry(lookup("prop-code", v-field-list, {&delim-key}), v-value-list, {&delim-key}) = {&attr-rum_ord} then do:
        v-descr = "Операции с заказами".
      end.

    end.
  end.
  when {&table_cash-desk} then do:
    v-descr = substitute("БД &1 Маг &2 Касса № &4 &3"
                         ,entry(lookup("db-num", v-field-list, {&delim-key}), v-value-list, {&delim-key})
                         ,entry(lookup("obj-code", v-field-list, {&delim-key}), v-value-list, {&delim-key})
                         ,entry(lookup("cash-num", v-field-list, {&delim-key}), v-value-list, {&delim-key})
                         ,entry(lookup("pos-type", v-field-list, {&delim-key}), v-value-list, {&delim-key})
                         ).
  end.
  when {&table_ext-file} then do:
    v-descr = substitute("БД &1 Файл № &3 (из БД &2)"
                         ,entry(lookup("db-num", v-field-list, {&delim-key}), v-value-list, {&delim-key})
                         ,entry(lookup("from-db-num", v-field-list, {&delim-key}), v-value-list, {&delim-key})
                         ,entry(lookup("file-num", v-field-list, {&delim-key}), v-value-list, {&delim-key})
                         ).
  end.


end case.
return v-descr.
end function.