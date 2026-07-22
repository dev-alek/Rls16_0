block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: 00104000.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cut/00104000.p $".
define variable vss-description as character no-undo init "Файл пирога обрезания. Относится к категории 104.".
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
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
for each old-prop-head  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-prop-head.
   buffer-copy old-prop-head to new-prop-head.
end.
if varstay-history then do:
for each old-c-prop-head  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-c-prop-head.
   buffer-copy old-c-prop-head to new-c-prop-head.
end.
end.
for each old-prop-head-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-prop-head-attr.
   buffer-copy old-prop-head-attr to new-prop-head-attr.
end.
for each old-prop-map  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-prop-map.
   buffer-copy old-prop-map to new-prop-map.
end.
for each old-prop-map-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-prop-map-attr.
   buffer-copy old-prop-map-attr to new-prop-map-attr.
end.
for each old-prop-ruleset  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-prop-ruleset.
   buffer-copy old-prop-ruleset to new-prop-ruleset.
end.
if varstay-history then do:
for each old-c-prop-ruleset  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-c-prop-ruleset.
   buffer-copy old-c-prop-ruleset to new-c-prop-ruleset.
end.
end.
for each old-prop-ruleset-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-prop-ruleset-attr.
   buffer-copy old-prop-ruleset-attr to new-prop-ruleset-attr.
end.
for each old-prop-script  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-prop-script.
   buffer-copy old-prop-script to new-prop-script.
end.
if varstay-history then do:
for each old-c-prop-script  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-c-prop-script.
   buffer-copy old-c-prop-script to new-c-prop-script.
end.
end.
for each old-prop-script-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-prop-script-attr.
   buffer-copy old-prop-script-attr to new-prop-script-attr.
end.
for each old-pscript-ruleset  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-pscript-ruleset.
   buffer-copy old-pscript-ruleset to new-pscript-ruleset.
end.
if varstay-history then do:
for each old-c-pscript-ruleset  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-c-pscript-ruleset.
   buffer-copy old-c-pscript-ruleset to new-c-pscript-ruleset.
end.
end.
for each old-pscript-ruleset-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-pscript-ruleset-attr.
   buffer-copy old-pscript-ruleset-attr to new-pscript-ruleset-attr.
end.
for each old-rp-rule-param  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-rp-rule-param.
   buffer-copy old-rp-rule-param to new-rp-rule-param.
end.
if varstay-history then do:
for each old-c-rp-rule-param  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-c-rp-rule-param.
   buffer-copy old-c-rp-rule-param to new-c-rp-rule-param.
end.
end.
for each old-rp-rule-param-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-rp-rule-param-attr.
   buffer-copy old-rp-rule-param-attr to new-rp-rule-param-attr.
end.
for each old-rule  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-rule.
   buffer-copy old-rule to new-rule.
end.
if varstay-history then do:
for each old-c-rule  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-c-rule.
   buffer-copy old-c-rule to new-c-rule.
end.
end.
for each old-rule-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-rule-attr.
   buffer-copy old-rule-attr to new-rule-attr.
end.
for each old-rule-by-profile  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-rule-by-profile.
   buffer-copy old-rule-by-profile to new-rule-by-profile.
end.
if varstay-history then do:
for each old-c-rule-by-profile  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-c-rule-by-profile.
   buffer-copy old-c-rule-by-profile to new-c-rule-by-profile.
end.
end.
for each old-rule-by-profile-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-rule-by-profile-attr.
   buffer-copy old-rule-by-profile-attr to new-rule-by-profile-attr.
end.
for each old-rule-by-set  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-rule-by-set.
   buffer-copy old-rule-by-set to new-rule-by-set.
end.
if varstay-history then do:
for each old-c-rule-by-set  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-c-rule-by-set.
   buffer-copy old-c-rule-by-set to new-c-rule-by-set.
end.
end.
for each old-rule-by-set-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-rule-by-set-attr.
   buffer-copy old-rule-by-set-attr to new-rule-by-set-attr.
end.
for each old-rule-profile  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-rule-profile.
   buffer-copy old-rule-profile to new-rule-profile.
end.
if varstay-history then do:
for each old-c-rule-profile  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-c-rule-profile.
   buffer-copy old-c-rule-profile to new-c-rule-profile.
end.
end.
for each old-profile-by-profile  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-profile-by-profile.
   buffer-copy old-profile-by-profile to new-profile-by-profile.
end.
if varstay-history then do:
for each old-c-profile-by-profile  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-c-profile-by-profile.
   buffer-copy old-c-profile-by-profile to new-c-profile-by-profile.
end.
end.
for each old-rule-profile-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-rule-profile-attr.
   buffer-copy old-rule-profile-attr to new-rule-profile-attr.
end.
for each old-rule-i-script  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-rule-i-script.
   buffer-copy old-rule-i-script to new-rule-i-script.
end.
for each old-rule-i-script-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-rule-i-script-attr.
   buffer-copy old-rule-i-script-attr to new-rule-i-script-attr.
end.
for each old-rule-script  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-rule-script.
   buffer-copy old-rule-script to new-rule-script.
end.
for each old-rule-script-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-rule-script-attr.
   buffer-copy old-rule-script-attr to new-rule-script-attr.
end.
for each old-ruledict  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-ruledict.
   buffer-copy old-ruledict to new-ruledict.
end.
if varstay-history then do:
for each old-c-ruledict  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-c-ruledict.
   buffer-copy old-c-ruledict to new-c-ruledict.
end.
end.
for each old-ruledict-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-ruledict-attr.
   buffer-copy old-ruledict-attr to new-ruledict-attr.
end.
for each old-ruledict-param  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-ruledict-param.
   buffer-copy old-ruledict-param to new-ruledict-param.
end.
if varstay-history then do:
for each old-c-ruledict-param  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-c-ruledict-param.
   buffer-copy old-c-ruledict-param to new-c-ruledict-param.
end.
end.
for each old-ruledict-param-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-ruledict-param-attr.
   buffer-copy old-ruledict-param-attr to new-ruledict-param-attr.
end.
for each old-ruleset  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-ruleset.
   buffer-copy old-ruleset to new-ruleset.
end.
if varstay-history then do:
for each old-c-ruleset  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-c-ruleset.
   buffer-copy old-c-ruleset to new-c-ruleset.
end.
end.
for each old-ruleset-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-ruleset-attr.
   buffer-copy old-ruleset-attr to new-ruleset-attr.
end.
for each old-rule-process  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-rule-process.
   buffer-copy old-rule-process to new-rule-process.
end.
if varstay-history then do:
for each old-c-rule-process  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-c-rule-process.
   buffer-copy old-c-rule-process to new-c-rule-process.
end.
end.
for each old-layout  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-layout.
   buffer-copy old-layout to new-layout.
end.
if varstay-history then do:
for each old-c-layout  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-c-layout.
   buffer-copy old-c-layout to new-c-layout.
end.
end.
for each old-layout-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-layout-attr.
   buffer-copy old-layout-attr to new-layout-attr.
end.
if varstay-history then do:
for each old-c-layout-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-c-layout-attr.
   buffer-copy old-c-layout-attr to new-c-layout-attr.
end.
end.
for each old-layout-elem  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-layout-elem.
   buffer-copy old-layout-elem to new-layout-elem.
end.
if varstay-history then do:
for each old-c-layout-elem  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-c-layout-elem.
   buffer-copy old-c-layout-elem to new-c-layout-elem.
end.
end.
for each old-layout-elem-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-layout-elem-attr.
   buffer-copy old-layout-elem-attr to new-layout-elem-attr.
end.
if varstay-history then do:
for each old-c-layout-elem-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-c-layout-elem-attr.
   buffer-copy old-c-layout-elem-attr to new-c-layout-elem-attr.
end.
end.
for each old-layout-elem-rule  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-layout-elem-rule.
   buffer-copy old-layout-elem-rule to new-layout-elem-rule.
end.
if varstay-history then do:
for each old-c-layout-elem-rule  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-c-layout-elem-rule.
   buffer-copy old-c-layout-elem-rule to new-c-layout-elem-rule.
end.
end.
for each old-layout-elem-rule-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-layout-elem-rule-attr.
   buffer-copy old-layout-elem-rule-attr to new-layout-elem-rule-attr.
end.
if varstay-history then do:
for each old-c-layout-elem-rule-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-c-layout-elem-rule-attr.
   buffer-copy old-c-layout-elem-rule-attr to new-c-layout-elem-rule-attr.
end.
end.
for each old-wi-mode  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-wi-mode.
   buffer-copy old-wi-mode to new-wi-mode.
end.
if varstay-history then do:
for each old-c-wi-mode  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-c-wi-mode.
   buffer-copy old-c-wi-mode to new-c-wi-mode.
end.
end.
for each old-wi-mode-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-wi-mode-attr.
   buffer-copy old-wi-mode-attr to new-wi-mode-attr.
end.
if varstay-history then do:
for each old-c-wi-mode-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-c-wi-mode-attr.
   buffer-copy old-c-wi-mode-attr to new-c-wi-mode-attr.
end.
end.
for each old-clob-bind no-lock where
    old-clob-bind.resource-type = 'gate':U
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
    old-clob-bind.resource-type = 'gate':U
and old-clob-bind.db-num = 0
and old-clob-bind.int64-id = 0
on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
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
