block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: 00104000.p $
$Archive: cut/00104000.p $

Файл пирога обрезания. Относится к категории 104.

prop-head
c-prop-head
prop-head-attr
prop-map
prop-map-attr
prop-ruleset
c-prop-ruleset
prop-ruleset-attr
prop-script
c-prop-script
prop-script-attr
pscript-ruleset
c-pscript-ruleset
pscript-ruleset-attr
rp-rule-param
c-rp-rule-param
rp-rule-param-attr
rule
c-rule
rule-attr
rule-by-profile
c-rule-by-profile
rule-by-profile-attr
rule-by-set
c-rule-by-set
rule-by-set-attr
rule-profile
c-rule-profile
profile-by-profile
c-profile-by-profile
rule-profile-attr
rule-i-script
rule-i-script-attr
rule-script
rule-script-attr
ruledict
c-ruledict
ruledict-attr
ruledict-param
c-ruledict-param
ruledict-param-attr
ruleset
c-ruleset
rule-process
c-rule-process
ruleset-attr
clob-bind  - частично
clob-data - частично
layout
c-layout
layout-attr
c-layout-attr
layout-elem
c-layout-elem
layout-elem-attr
c-layout-elem-attr
layout-elem-rule
c-layout-elem-rule
layout-elem-rule-attr
c-layout-elem-rule-attr
wi-mode
c-wi-mode
wi-mode-attr
c-wi-mode-attr



Автор: Бахтадзе Наталья Викторовна
Дата создания: 05/21/09
Author: Bakhtadze Natalya
Creation date: 05/21/09

*/


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: 00104000.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cut/00104000.p $".
define variable vss-description as character no-undo init "Файл пирога обрезания. Относится к категории 104.".
{ cmp/str-glbl.i }

define buffer old-prop-head for src.prop-head.
define buffer new-prop-head for dst.prop-head.
define buffer old-c-prop-head for src.c-prop-head.
define buffer new-c-prop-head for dst.c-prop-head.
define buffer old-prop-head-attr for src.prop-head-attr.
define buffer new-prop-head-attr for dst.prop-head-attr.
define buffer old-prop-map for src.prop-map.
define buffer new-prop-map for dst.prop-map.
define buffer old-prop-map-attr for src.prop-map-attr.
define buffer new-prop-map-attr for dst.prop-map-attr.
define buffer old-prop-ruleset for src.prop-ruleset.
define buffer new-prop-ruleset for dst.prop-ruleset.
define buffer old-c-prop-ruleset for src.c-prop-ruleset.
define buffer new-c-prop-ruleset for dst.c-prop-ruleset.
define buffer old-prop-ruleset-attr for src.prop-ruleset-attr.
define buffer new-prop-ruleset-attr for dst.prop-ruleset-attr.
define buffer old-prop-script for src.prop-script.
define buffer new-prop-script for dst.prop-script.
define buffer old-c-prop-script for src.c-prop-script.
define buffer new-c-prop-script for dst.c-prop-script.
define buffer old-prop-script-attr for src.prop-script-attr.
define buffer new-prop-script-attr for dst.prop-script-attr.
define buffer old-pscript-ruleset for src.pscript-ruleset.
define buffer new-pscript-ruleset for dst.pscript-ruleset.
define buffer old-c-pscript-ruleset for src.c-pscript-ruleset.
define buffer new-c-pscript-ruleset for dst.c-pscript-ruleset.
define buffer old-pscript-ruleset-attr for src.pscript-ruleset-attr.
define buffer new-pscript-ruleset-attr for dst.pscript-ruleset-attr.
define buffer old-rp-rule-param for src.rp-rule-param.
define buffer new-rp-rule-param for dst.rp-rule-param.
define buffer old-c-rp-rule-param for src.c-rp-rule-param.
define buffer new-c-rp-rule-param for dst.c-rp-rule-param.
define buffer old-rp-rule-param-attr for src.rp-rule-param-attr.
define buffer new-rp-rule-param-attr for dst.rp-rule-param-attr.
define buffer old-rule for src.rule.
define buffer new-rule for dst.rule.
define buffer old-c-rule for src.c-rule.
define buffer new-c-rule for dst.c-rule.
define buffer old-rule-attr for src.rule-attr.
define buffer new-rule-attr for dst.rule-attr.
define buffer old-rule-by-profile for src.rule-by-profile.
define buffer new-rule-by-profile for dst.rule-by-profile.
define buffer old-c-rule-by-profile for src.c-rule-by-profile.
define buffer new-c-rule-by-profile for dst.c-rule-by-profile.
define buffer old-rule-by-profile-attr for src.rule-by-profile-attr.
define buffer new-rule-by-profile-attr for dst.rule-by-profile-attr.
define buffer old-rule-by-set for src.rule-by-set.
define buffer new-rule-by-set for dst.rule-by-set.
define buffer old-c-rule-by-set for src.c-rule-by-set.
define buffer new-c-rule-by-set for dst.c-rule-by-set.
define buffer old-rule-by-set-attr for src.rule-by-set-attr.
define buffer new-rule-by-set-attr for dst.rule-by-set-attr.
define buffer old-rule-profile for src.rule-profile.
define buffer new-rule-profile for dst.rule-profile.
define buffer old-c-rule-profile for src.c-rule-profile.
define buffer new-c-rule-profile for dst.c-rule-profile.
define buffer old-profile-by-profile for src.profile-by-profile.
define buffer new-profile-by-profile for dst.profile-by-profile.
define buffer old-c-profile-by-profile for src.c-profile-by-profile.
define buffer new-c-profile-by-profile for dst.c-profile-by-profile.
define buffer old-rule-profile-attr for src.rule-profile-attr.
define buffer new-rule-profile-attr for dst.rule-profile-attr.
define buffer old-rule-i-script for src.rule-i-script.
define buffer new-rule-i-script for dst.rule-i-script.
define buffer old-rule-i-script-attr for src.rule-i-script-attr.
define buffer new-rule-i-script-attr for dst.rule-i-script-attr.
define buffer old-rule-script for src.rule-script.
define buffer new-rule-script for dst.rule-script.
define buffer old-rule-script-attr for src.rule-script-attr.
define buffer new-rule-script-attr for dst.rule-script-attr.
define buffer old-ruledict for src.ruledict.
define buffer new-ruledict for dst.ruledict.
define buffer old-c-ruledict for src.c-ruledict.
define buffer new-c-ruledict for dst.c-ruledict.
define buffer old-ruledict-attr for src.ruledict-attr.
define buffer new-ruledict-attr for dst.ruledict-attr.
define buffer old-ruledict-param for src.ruledict-param.
define buffer new-ruledict-param for dst.ruledict-param.
define buffer old-c-ruledict-param for src.c-ruledict-param.
define buffer new-c-ruledict-param for dst.c-ruledict-param.
define buffer old-ruledict-param-attr for src.ruledict-param-attr.
define buffer new-ruledict-param-attr for dst.ruledict-param-attr.
define buffer old-ruleset for src.ruleset.
define buffer new-ruleset for dst.ruleset.
define buffer old-c-ruleset for src.c-ruleset.
define buffer new-c-ruleset for dst.c-ruleset.
define buffer old-ruleset-attr for src.ruleset-attr.
define buffer new-ruleset-attr for dst.ruleset-attr.
define buffer old-rule-process for src.rule-process.
define buffer new-rule-process for dst.rule-process.
define buffer old-c-rule-process for src.c-rule-process.
define buffer new-c-rule-process for dst.c-rule-process.
define buffer old-clob-bind for src.clob-bind.
define buffer new-clob-bind for dst.clob-bind.
define buffer old-clob-data for src.clob-data.
define buffer new-clob-data for dst.clob-data.
define buffer old-layout for src.layout.
define buffer new-layout for dst.layout.
define buffer old-c-layout for src.c-layout.
define buffer new-c-layout for dst.c-layout.
define buffer old-layout-attr for src.layout-attr.
define buffer new-layout-attr for dst.layout-attr.
define buffer old-c-layout-attr for src.c-layout-attr.
define buffer new-c-layout-attr for dst.c-layout-attr.
define buffer old-layout-elem for src.layout-elem.
define buffer new-layout-elem for dst.layout-elem.
define buffer old-c-layout-elem for src.c-layout-elem.
define buffer new-c-layout-elem for dst.c-layout-elem.
define buffer old-layout-elem-attr for src.layout-elem-attr.
define buffer new-layout-elem-attr for dst.layout-elem-attr.
define buffer old-c-layout-elem-attr for src.c-layout-elem-attr.
define buffer new-c-layout-elem-attr for dst.c-layout-elem-attr.
define buffer old-layout-elem-rule for src.layout-elem-rule.
define buffer new-layout-elem-rule for dst.layout-elem-rule.
define buffer old-c-layout-elem-rule for src.c-layout-elem-rule.
define buffer new-c-layout-elem-rule for dst.c-layout-elem-rule.
define buffer old-layout-elem-rule-attr for src.layout-elem-rule-attr.
define buffer new-layout-elem-rule-attr for dst.layout-elem-rule-attr.
define buffer old-c-layout-elem-rule-attr for src.c-layout-elem-rule-attr.
define buffer new-c-layout-elem-rule-attr for dst.c-layout-elem-rule-attr.
define buffer old-wi-mode for src.wi-mode.
define buffer new-wi-mode for dst.wi-mode.
define buffer old-c-wi-mode for src.c-wi-mode.
define buffer new-c-wi-mode for dst.c-wi-mode.
define buffer old-wi-mode-attr for src.wi-mode-attr.
define buffer new-wi-mode-attr for dst.wi-mode-attr.
define buffer old-c-wi-mode-attr for src.c-wi-mode-attr.
define buffer new-c-wi-mode-attr for dst.c-wi-mode-attr.




do
on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)) :
{ utl/00000001.i }
on WRITE of dst.prop-head override do: end.
on WRITE of dst.c-prop-head override do: end.
on WRITE of dst.prop-head-attr override do: end.
on WRITE of dst.prop-map override do: end.
on WRITE of dst.prop-map-attr override do: end.
on WRITE of dst.prop-ruleset override do: end.
on WRITE of dst.c-prop-ruleset override do: end.
on WRITE of dst.prop-ruleset-attr override do: end.
on WRITE of dst.prop-script override do: end.
on WRITE of dst.c-prop-script override do: end.
on WRITE of dst.prop-script-attr override do: end.
on WRITE of dst.pscript-ruleset       override do: end.
on WRITE of dst.c-pscript-ruleset     override do: end.
on WRITE of dst.pscript-ruleset-attr  override do: end.
on WRITE of dst.rp-rule-param         override do: end.
on WRITE of dst.c-rp-rule-param       override do: end.
on WRITE of dst.rp-rule-param-attr    override do: end.
on WRITE of dst.rule                  override do: end.
on WRITE of dst.c-rule                override do: end.
on WRITE of dst.rule-attr             override do: end.
on WRITE of dst.rule-by-profile       override do: end.
on WRITE of dst.c-rule-by-profile     override do: end.
on WRITE of dst.rule-by-profile-attr  override do: end.
on WRITE of dst.rule-by-set           override do: end.
on WRITE of dst.c-rule-by-set         override do: end.
on WRITE of dst.rule-by-set-attr      override do: end.
on WRITE of dst.rule-profile          override do: end.
on WRITE of dst.c-rule-profile        override do: end.
on WRITE of dst.rule-profile-attr     override do: end.
on WRITE of dst.profile-by-profile    override do: end.
on WRITE of dst.c-profile-by-profile  override do: end.
on WRITE of dst.rule-i-script         override do: end.
on WRITE of dst.rule-i-script-attr    override do: end.
on WRITE of dst.rule-script           override do: end.
on WRITE of dst.rule-script-attr      override do: end.
on WRITE of dst.ruledict              override do: end.
on WRITE of dst.c-ruledict            override do: end.
on WRITE of dst.ruledict-attr         override do: end.
on WRITE of dst.ruledict-param        override do: end.
on WRITE of dst.c-ruledict-param      override do: end.
on WRITE of dst.ruledict-param-attr   override do: end.
on WRITE of dst.ruleset               override do: end.
on WRITE of dst.c-ruleset             override do: end.
on WRITE of dst.ruleset-attr          override do: end.
on WRITE of dst.rule-process               override do: end.
on WRITE of dst.c-rule-process             override do: end.
on WRITE of dst.clob-bind             override do: end.
on WRITE of dst.clob-data             override do: end.
on WRITE of dst.layout                override do: end.
on WRITE of dst.c-layout              override do: end.
on WRITE of dst.layout-attr           override do: end.
on WRITE of dst.c-layout-attr         override do: end.
on WRITE of dst.layout-elem                override do: end.
on WRITE of dst.c-layout-elem              override do: end.
on WRITE of dst.layout-elem-attr           override do: end.
on WRITE of dst.c-layout-elem-attr         override do: end.
on WRITE of dst.layout-elem-rule                override do: end.
on WRITE of dst.c-layout-elem-rule              override do: end.
on WRITE of dst.layout-elem-rule-attr           override do: end.
on WRITE of dst.c-layout-elem-rule-attr         override do: end.
on WRITE of dst.wi-mode                override do: end.
on WRITE of dst.c-wi-mode              override do: end.
on WRITE of dst.wi-mode-attr           override do: end.
on WRITE of dst.c-wi-mode-attr         override do: end.



{ utl/00000002.i prop-head }
if varstay-history then do:
  { utl/00000002.i c-prop-head }
end.
{ utl/00000002.i prop-head-attr }
{ utl/00000002.i prop-map }
{ utl/00000002.i prop-map-attr }
{ utl/00000002.i prop-ruleset }
if varstay-history then do:
  { utl/00000002.i c-prop-ruleset }
end.
{ utl/00000002.i prop-ruleset-attr }
{ utl/00000002.i prop-script }
if varstay-history then do:
  { utl/00000002.i c-prop-script }
end.
{ utl/00000002.i prop-script-attr }
{ utl/00000002.i pscript-ruleset }
if varstay-history then do:
  { utl/00000002.i c-pscript-ruleset }
end.
{ utl/00000002.i pscript-ruleset-attr }
{ utl/00000002.i rp-rule-param }
if varstay-history then do:
  { utl/00000002.i c-rp-rule-param }
end.
{ utl/00000002.i rp-rule-param-attr }
{ utl/00000002.i rule }
if varstay-history then do:
  { utl/00000002.i c-rule }
end.
{ utl/00000002.i rule-attr }
{ utl/00000002.i rule-by-profile }
if varstay-history then do:
  { utl/00000002.i c-rule-by-profile }
end.
{ utl/00000002.i rule-by-profile-attr }
{ utl/00000002.i rule-by-set }
if varstay-history then do:
 { utl/00000002.i c-rule-by-set }
end.
{ utl/00000002.i rule-by-set-attr }
{ utl/00000002.i rule-profile }
if varstay-history then do:
 { utl/00000002.i c-rule-profile }
end.
{ utl/00000002.i profile-by-profile }
if varstay-history then do:
 { utl/00000002.i c-profile-by-profile }
end.
{ utl/00000002.i rule-profile-attr }
{ utl/00000002.i rule-i-script }
{ utl/00000002.i rule-i-script-attr }
{ utl/00000002.i rule-script }
{ utl/00000002.i rule-script-attr }
{ utl/00000002.i ruledict }
if varstay-history then do:
  { utl/00000002.i c-ruledict }
end.
{ utl/00000002.i ruledict-attr }
{ utl/00000002.i ruledict-param }
if varstay-history then do:
  { utl/00000002.i c-ruledict-param }
end.
{ utl/00000002.i ruledict-param-attr }
{ utl/00000002.i ruleset }
if varstay-history then do:
  { utl/00000002.i c-ruleset }
end.
{ utl/00000002.i ruleset-attr }
{ utl/00000002.i rule-process }
if varstay-history then do:
  { utl/00000002.i c-rule-process }
end.
{ utl/00000002.i layout }
if varstay-history then do:
  { utl/00000002.i c-layout }
end.
{ utl/00000002.i layout-attr }
if varstay-history then do:
  { utl/00000002.i c-layout-attr }
end.
{ utl/00000002.i layout-elem }
if varstay-history then do:
  { utl/00000002.i c-layout-elem }
end.
{ utl/00000002.i layout-elem-attr }
if varstay-history then do:
  { utl/00000002.i c-layout-elem-attr }
end.
{ utl/00000002.i layout-elem-rule }
if varstay-history then do:
  { utl/00000002.i c-layout-elem-rule }
end.
{ utl/00000002.i layout-elem-rule-attr }
if varstay-history then do:
  { utl/00000002.i c-layout-elem-rule-attr }
end.
{ utl/00000002.i wi-mode }
if varstay-history then do:
  { utl/00000002.i c-wi-mode }
end.
{ utl/00000002.i wi-mode-attr }
if varstay-history then do:
  { utl/00000002.i c-wi-mode-attr }
end.


for each old-clob-bind no-lock where
    old-clob-bind.resource-type = {&lob-res-gate}
and old-clob-bind.db-num = 0
and old-clob-bind.int64-id > 0
on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-clob-bind.
   buffer-copy old-clob-bind to new-clob-bind.
   for  EACH old-clob-data NO-LOCK
      where      (old-clob-data.db-num = old-clob-bind.db-num
              and old-clob-data.int64-id = old-clob-bind.int64-id )
              or (old-clob-data.file-name = old-clob-bind.uniq-key-rec
                  and
                  old-clob-bind.uniq-key-rec begins "exe/")
    on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
    create new-clob-data.
    buffer-copy old-clob-data to new-clob-data.
   end.
end.
for each old-clob-bind no-lock where
    old-clob-bind.resource-type = {&lob-res-gate}
and old-clob-bind.db-num = 0
and old-clob-bind.int64-id = 0
on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
  /*здесь лежит версия fixgate*/
   create new-clob-bind.
   buffer-copy old-clob-bind to new-clob-bind.
end.






output stream str-gen close.
return "Произведен экспорт таблиц: prop-head c-prop-head prop-head-attr prop-map prop-map-attr prop-ruleset c-prop-ruleset prop-ruleset-attr ~
prop-script c-prop-script prop-script-attr pscript-ruleset c-pscript-ruleset pscript-ruleset-attr ~
rp-rule-param c-rp-rule-param rp-rule-param-attr rule c-rule rule-attr ~
rule-by-profile c-rule-by-profile rule-by-profile-attr rule-by-set c-rule-by-set rule-by-set-attr ~
rule-profile c-rule-profile rule-profile-attr rule-i-script rule-i-script-attr rule-script rule-script-attr ~
ruledict c-ruledict ruledict-attr ruledict-param c-ruledict-param ruledict-param-attr ruleset c-ruleset ruleset-attr rule-process c-rule-process ~
clob-data clob-bind ~
layout c-layout layout-attr c-layout-attr layout-elem c-layout-elem layout-elem-attr c-layout-elem-attr ~
layout-elem-rule c-layout-elem-rule layout-elem-rule-attr c-layout-elem-rule-attr wi-mode c-wi-mode wi-mode-attr c-wi-mode-attr.".
end.


