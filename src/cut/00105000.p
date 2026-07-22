block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: 00105000.p $
$Archive: cut/00105000.p $

Файл пирога обрезания. Относится к категории 105.

prop-ref
c-prop-ref
prop-ref-attr
prop-ref-call
prop-ref-call-attr
rp-by-call
c-rp-by-call
rp-by-call-attr
rule-by-call
c-rule-by-call
rule-by-call-attr
rule-call-param
c-rule-call-param
rule-call-param-attr
rule-trans-memo
rule-trans-memo-attr

Автор: Бахтадзе Наталья Викторовна
Дата создания: 05/21/09
Author: Bakhtadze Natalya
Creation date: 05/21/09

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: 00105000.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cut/00105000.p $":U .
define variable vss-description as character no-undo init "Файл пирога обрезания. Относится к категории 105.".
{ cmp/vssrevis.i }

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
{ utl/00000001.i }
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




{ utl/00000002.i prop-ref }
if varstay-history then do:
  { utl/00000002.i c-prop-ref }
end.
{ utl/00000002.i prop-ref-attr }
{ utl/00000002.i prop-ref-call }
{ utl/00000002.i prop-ref-call-attr }
{ utl/00000002.i rp-by-call }
if varstay-history then do:
  { utl/00000002.i c-rp-by-call }
end.
{ utl/00000002.i rp-by-call-attr }
{ utl/00000002.i rule-by-call }
if varstay-history then do:
  { utl/00000002.i c-rule-by-call }
end.
{ utl/00000002.i rule-by-call-attr }
{ utl/00000002.i rule-call-param }
if varstay-history then do:
  { utl/00000002.i c-rule-call-param }
end.
{ utl/00000002.i rule-call-param-attr }
{ utl/00000002.i rule-trans-memo }
{ utl/00000002.i rule-trans-memo-attr }


output stream str-gen close.
return "Произведен экспорт таблиц: ~
prop-ref c-prop-ref prop-ref-attr prop-ref-call prop-ref-call-attr rp-by-call c-rp-by-call rp-by-call-attr~
rule-by-call c-rule-by-call rule-by-call-attr rule-call-param c-rule-call-param rule-call-param-attr rule-trans-memo rule-trans-memo-attr.".
end.