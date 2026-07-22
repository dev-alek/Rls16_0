block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: 00105000.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cut/00105000.p $":U .
define variable vss-description as character no-undo init "Файл пирога обрезания. Относится к категории 105.".
procedure vss-get-info :
  define output parameter p-vss-revision    like vss-revision    no-undo .
  define output parameter p-vss-author      like vss-author      no-undo .
  define output parameter p-vss-date        like vss-date        no-undo .
  define output parameter p-vss-workfile    like vss-workfile    no-undo .
  define output parameter p-vss-archive     like vss-archive     no-undo .
  define output parameter p-vss-description like vss-description no-undo .
  assign
    p-vss-revision    = vss-revision
    p-vss-author      = vss-author
    p-vss-date        = vss-date
    p-vss-workfile    = vss-workfile
    p-vss-archive     = vss-archive
    p-vss-description = vss-description
  .
end procedure.
procedure vss-get-parameters :
  define output parameter p-vss-parameters as character no-undo .
end procedure.
define new global shared variable g#vssrevis-logger as handle    no-undo .
define variable v-vssrevis-logevent                 as logical   no-undo init false .
define variable v-vssrevis-logger                   as handle    no-undo .
procedure vss-logevent :
  define input  parameter p-extra-paramters as character no-undo .
  define variable v-vssrevis-parameters as character no-undo .
  do
  on error undo, return error return-value
  :
    if  valid-handle(v-vssrevis-logger)
    and v-vssrevis-logger :get-signature("logevent") <> ""
    then do:
      run vss-get-parameters in this-procedure
        (output v-vssrevis-parameters
        ).
      run logevent in v-vssrevis-logger
        (input vss-workfile
        ,input vss-revision
        ,input v-vssrevis-parameters
        ,input p-extra-paramters
        ).
    end.
  end.
end procedure.
assign
  v-vssrevis-logger = g#vssrevis-logger
.
if  valid-handle(v-vssrevis-logger)
and v-vssrevis-logger :get-signature("logevent") <> ""
then do:
  assign
    v-vssrevis-logevent = true
  .
  run vss-logevent in this-procedure (input vss-description) .
end.
define buffer old-prop-ref for src.prop-ref.
define buffer new-prop-ref for dst.prop-ref.
define buffer old-c-prop-ref for src.c-prop-ref.
define buffer new-c-prop-ref for dst.c-prop-ref.
define buffer old-prop-ref-attr for src.prop-ref-attr.
define buffer new-prop-ref-attr for dst.prop-ref-attr.
define buffer old-prop-ref-call for src.prop-ref-call.
define buffer new-prop-ref-call for dst.prop-ref-call.
define buffer old-prop-ref-call-attr for src.prop-ref-call-attr.
define buffer new-prop-ref-call-attr for dst.prop-ref-call-attr.
define buffer old-rp-by-call for src.rp-by-call.
define buffer new-rp-by-call for dst.rp-by-call.
define buffer old-c-rp-by-call for src.c-rp-by-call.
define buffer new-c-rp-by-call for dst.c-rp-by-call.
define buffer old-rp-by-call-attr for src.rp-by-call-attr.
define buffer new-rp-by-call-attr for dst.rp-by-call-attr.
define buffer old-rule-by-call for src.rule-by-call.
define buffer new-rule-by-call for dst.rule-by-call.
define buffer old-c-rule-by-call for src.c-rule-by-call.
define buffer new-c-rule-by-call for dst.c-rule-by-call.
define buffer old-rule-by-call-attr for src.rule-by-call-attr.
define buffer new-rule-by-call-attr for dst.rule-by-call-attr.
define buffer old-rule-call-param for src.rule-call-param.
define buffer new-rule-call-param for dst.rule-call-param.
define buffer old-c-rule-call-param for src.c-rule-call-param.
define buffer new-c-rule-call-param for dst.c-rule-call-param.
define buffer old-rule-call-param-attr for src.rule-call-param-attr.
define buffer new-rule-call-param-attr for dst.rule-call-param-attr.
define buffer old-rule-trans-memo for src.rule-trans-memo.
define buffer new-rule-trans-memo for dst.rule-trans-memo.
define buffer old-rule-trans-memo-attr for src.rule-trans-memo-attr.
define buffer new-rule-trans-memo-attr for dst.rule-trans-memo-attr.
do
on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)) :
define input parameter vartype-cut            as integer   no-undo.
define input parameter varlist-db             as character no-undo.
define input parameter vardate-actual-goods   as date      no-undo.
define input parameter vardate-actual-docs    as date      no-undo.
define input parameter vardate-actual-findoc  as date      no-undo.
define input parameter vardate-output-zone    as date      no-undo.
define input parameter varstay-recipe-goods   as logical   no-undo.
define input parameter varstay-weight-goods   as logical   no-undo.
define input parameter varnot-copy-del-goods  as logical   no-undo.
define input parameter varstay-history        as logical   no-undo.
define input parameter vargen-file            as character no-undo.
define stream str-gen.
output stream str-gen to vargen-file append.
if not connected("src") then do:
   return error "Нет коннекта с базой 'src'.".
end.
if not connected("dst") then do:
   return error "Нет коннекта с базой 'dst'.".
end.
find src.sys-ctrl no-lock.
if not available src.sys-ctrl then do:
   return error "В базе данных src не найдена уникальная запись sys-ctrl.".
end.
if src.sys-ctrl.db-num <> 0 then do:
   return error "Пакет обрезания работает только в главной базе данных. В данной версии удаленные БД создаются выгрузкой из главных.".
end.
if vardate-actual-docs <> ? and
   (vardate-actual-goods   > vardate-actual-docs or
    vardate-actual-goods   = ? )   then do:
      return error SUBSTITUTE("Ошибка при задании дат актуальности." +
                              "Дата актуальности товаров &1."        +
                              "Дата актуальности документов &2."     +
                              "Дата актуальности документов должна быть больше или равна дат актуальностей товаров.",
                              vardate-actual-goods,
                              vardate-actual-docs).
end.
on WRITE of dst.prop-ref override do: end.
on WRITE of dst.c-prop-ref override do: end.
on WRITE of dst.prop-ref-attr override do: end.
on WRITE of dst.prop-ref-call override do: end.
on WRITE of dst.prop-ref-call-attr override do: end.
on WRITE of dst.rp-by-call override do: end.
on WRITE of dst.c-rp-by-call override do: end.
on WRITE of dst.rp-by-call-attr override do: end.
on WRITE of dst.rule-by-call override do: end.
on WRITE of dst.c-rule-by-call override do: end.
on WRITE of dst.rule-by-call-attr override do: end.
on WRITE of dst.rule-call-param override do: end.
on WRITE of dst.c-rule-call-param override do: end.
on WRITE of dst.rule-call-param-attr override do: end.
on WRITE of dst.rule-trans-memo override do: end.
on WRITE of dst.rule-trans-memo-attr override do: end.
for each old-prop-ref  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-prop-ref.
   buffer-copy old-prop-ref to new-prop-ref.
end.
if varstay-history then do:
for each old-c-prop-ref  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-c-prop-ref.
   buffer-copy old-c-prop-ref to new-c-prop-ref.
end.
end.
for each old-prop-ref-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-prop-ref-attr.
   buffer-copy old-prop-ref-attr to new-prop-ref-attr.
end.
for each old-prop-ref-call  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-prop-ref-call.
   buffer-copy old-prop-ref-call to new-prop-ref-call.
end.
for each old-prop-ref-call-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-prop-ref-call-attr.
   buffer-copy old-prop-ref-call-attr to new-prop-ref-call-attr.
end.
for each old-rp-by-call  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-rp-by-call.
   buffer-copy old-rp-by-call to new-rp-by-call.
end.
if varstay-history then do:
for each old-c-rp-by-call  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-c-rp-by-call.
   buffer-copy old-c-rp-by-call to new-c-rp-by-call.
end.
end.
for each old-rp-by-call-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-rp-by-call-attr.
   buffer-copy old-rp-by-call-attr to new-rp-by-call-attr.
end.
for each old-rule-by-call  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-rule-by-call.
   buffer-copy old-rule-by-call to new-rule-by-call.
end.
if varstay-history then do:
for each old-c-rule-by-call  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-c-rule-by-call.
   buffer-copy old-c-rule-by-call to new-c-rule-by-call.
end.
end.
for each old-rule-by-call-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-rule-by-call-attr.
   buffer-copy old-rule-by-call-attr to new-rule-by-call-attr.
end.
for each old-rule-call-param  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-rule-call-param.
   buffer-copy old-rule-call-param to new-rule-call-param.
end.
if varstay-history then do:
for each old-c-rule-call-param  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-c-rule-call-param.
   buffer-copy old-c-rule-call-param to new-c-rule-call-param.
end.
end.
for each old-rule-call-param-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-rule-call-param-attr.
   buffer-copy old-rule-call-param-attr to new-rule-call-param-attr.
end.
for each old-rule-trans-memo  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-rule-trans-memo.
   buffer-copy old-rule-trans-memo to new-rule-trans-memo.
end.
for each old-rule-trans-memo-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-rule-trans-memo-attr.
   buffer-copy old-rule-trans-memo-attr to new-rule-trans-memo-attr.
end.
output stream str-gen close.
return "Произведен экспорт таблиц: ~
prop-ref c-prop-ref prop-ref-attr prop-ref-call prop-ref-call-attr rp-by-call c-rp-by-call rp-by-call-attr~
rule-by-call c-rule-by-call rule-by-call-attr rule-call-param c-rule-call-param rule-call-param-attr rule-trans-memo rule-trans-memo-attr.".
end.
