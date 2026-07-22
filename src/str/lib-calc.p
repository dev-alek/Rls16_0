block-level on error undo, throw.
/*

$Revision: 5baf537283c9, 2487, rls $
$Author: SSlivenko $
$Date: 2020/06/26 13:47:04 $
$Workfile: lib-calc.p $
$Archive: str/lib-calc.p $

Библиотека процедур для расчета данных по складским документам

Автор: Чернова Светлана Александровна
Дата создания: 03/24/08
Author: Svetlana Chernova
Creation date: 03/24/08

Автор1: Суслов Алексей Юрьевич
Дата создания: 04/03/02


*/

define variable vss-revision    as character no-undo initial "$Revision: 5baf537283c9, 2487, rls $":U .
define variable vss-author      as character no-undo initial "$Author: SSlivenko $":U .
define variable vss-date        as character no-undo initial "$Date: 2020/06/26 13:47:04 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: lib-calc.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: str/lib-calc.p $":U .
define variable vss-description as character no-undo initial "Библиотека процедур для расчета данных по складским документам":U .

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/croslist.i }
{ gbl/clntattr.i }
{ str/lib-calc.i }
{ str/hvrdtax.i  }
{ str/lib-trn.i  }
{ gbl/ptrlprop.i def }
{ ref/gds-attr.i } 

if valid-handle (g#lib-calc)
and g#lib-calc <> this-procedure :handle
and lookup('lib-calc_clcrdtax':u, g#lib-calc :internal-entries) > 0
then do:
  message
    vss-workfile vss-revision vss-description skip
    "Попытка повторной загрузки библиотеки для раcчета складских документов" skip
    g#lib-calc skip
    g#lib-calc :type skip
    g#lib-calc :file-name skip
    valid-handle(g#lib-calc) skip
    this-procedure :handle skip
    this-procedure :type skip
    this-procedure :file-name skip
    valid-handle(this-procedure) skip
    view-as alert-box error .
  undo, return error .
end.
else do:
  assign
    g#lib-calc = this-procedure :handle
  .
end.

on delete of this-procedure do:
  assign
    g#lib-calc = ?
  .
end.

/* --------------------------------------------------------------------------
   Библиотека процедур для пересчета полей строки внешней приходной накладной
   -------------------------------------------------------------------------- */
&scop string-mes "Для данного типа товара: " + parext-gds-type

/* Расчет дорожного налога в интерфейсе внешней приходной накладной */
procedure lib-calc_clcrdtax:
define input  parameter pargds-code      like ub.goods.gds-code         no-undo.
define input  parameter parext-gds-type  as   character                 no-undo.
define input  parameter parcli-base-rate like ub.doc-line.cli-base-rate no-undo.
define input  parameter pardoc-qnty      like ub.doc-line.doc-qnty      no-undo.
define input  parameter pardensity       like ub.doc-line.doc-density   no-undo.
define input  parameter parroad-tax-cli  like ub.doc-line.road-tax      no-undo.
define input  parameter parbase-rate     like ub.trn-doc.base-rate      no-undo.
define input  parameter parbase-scale    like ub.trn-doc.base-scale     no-undo.
define input  parameter parexch-rate     like ub.trn-doc.base-rate      no-undo.
define input  parameter parexch-scale    like ub.trn-doc.base-scale     no-undo.
define output parameter parroad-tax      like ub.doc-line.road-tax      no-undo.
define variable varr-b as character no-undo.
{ gbl/curr-r-b.i varr-b }
define buffer bf_goods for ub.goods.
find first bf_goods where bf_goods.gds-code = pargds-code no-lock.
if not hvrdtax (recid(bf_goods)) then return error {&string-mes} + " пересчет налога 3.".
case parext-gds-type:
when {&gds-bottle} then do:
  if varr-b = "rubl":u then do:
    assign parroad-tax = parroad-tax-cli
           * parexch-rate / parexch-scale.
  end.
  else do:
    assign parroad-tax = parroad-tax-cli
             / parbase-rate * parbase-scale
           * parexch-rate / parexch-scale.
  end.
end.
when {&gds-pcptrl} then do:
  if varr-b = "rubl":u then do:
    assign parroad-tax = parroad-tax-cli
           * parexch-rate / parexch-scale
           / parcli-base-rate.
  end.
  else do:
    assign parroad-tax = parroad-tax-cli
             / parbase-rate * parbase-scale
           * parexch-rate / parexch-scale
           / parcli-base-rate.
  end.
end.
when {&gds-lptrl} then do:
  if varr-b = "rubl":u then do:
    assign parroad-tax = parroad-tax-cli
           * parexch-rate / parexch-scale
           * (round(pardoc-qnty * pardensity, 0) / pardoc-qnty).
  end.
  else do:
    assign parroad-tax = parroad-tax-cli
           / parbase-rate * parbase-scale
           * parexch-rate / parexch-scale
           * (round(pardoc-qnty * pardensity, 0) / pardoc-qnty).
  end.
end.
when {&gds-kgptrl} then do:
  if varr-b = "rubl":u then do:
    assign parroad-tax = parroad-tax-cli
           * parexch-rate / parexch-scale
           * pardensity.
  end.
  else do:
    assign parroad-tax = parroad-tax-cli
           / parbase-rate * parbase-scale
           * parexch-rate / parexch-scale
           * pardensity.

  end.
end.
otherwise do:
   return error {&string-mes} + " пересчет налога 3.".
end.
end case.
end procedure.

/* Расчет количества в базовых единицах */
procedure lib-calc_clcdocqt:
define input  parameter parext-gds-type  as   character                 no-undo.
define input  parameter parcli-qnty      like ub.doc-line.cli-qnty      no-undo.
define input  parameter parcli-base-rate like ub.doc-line.cli-base-rate no-undo.
define input  parameter pardensity       like ub.doc-line.doc-density       no-undo.
define output parameter pardoc-qnty      like ub.doc-line.doc-qnty      no-undo.
case parext-gds-type:
  when {&gds-ordin}     or
  when {&gds-off-ordin} then do:
     assign pardoc-qnty = parcli-qnty * parcli-base-rate.
  end.
  when {&gds-serial} then do:
     /* суммирование по партиям сделано через иную ветку */
  end.
  when {&gds-bottle} then do:
     assign pardoc-qnty = parcli-qnty.
  end.
  when {&gds-kgptrl} then do:
     assign pardoc-qnty = parcli-qnty / pardensity.
  end.
  otherwise do:
     return error {&string-mes} + " пересчет количества в базовых единицах недопустим.".
  end.
end case.
end procedure.

/* Пересчет количества в единицах клиента */
procedure lib-calc_clccliqt:
define input  parameter parext-gds-type  as   character                 no-undo.
define input  parameter pardoc-qnty      like ub.doc-line.doc-qnty      no-undo.
define input  parameter parcli-base-rate like ub.doc-line.cli-base-rate no-undo.
define input  parameter pardensity       like ub.doc-line.doc-density       no-undo.
define input  parameter parround         as   integer                   no-undo.
define output parameter parcli-qnty      like ub.doc-line.cli-qnty      no-undo.
case parext-gds-type:
  when {&gds-serial} then do:
     /* суммирование по партиям сделано через иную ветку */
  end.
  when {&gds-pcptrl} then do:
     assign  parcli-qnty = pardoc-qnty / parcli-base-rate.
  end.
  when {&gds-lptrl} then do:
     assign parcli-qnty = pardoc-qnty * pardensity .
  end.
  otherwise do:
     return error {&string-mes} + " пересчет кол-ва по ТТН недопустим.".
  end.
end case.
end.

/* Пересчет плотности */
procedure lib-calc_clcdens:
define input  parameter parext-gds-type  as   character                 no-undo.
define input  parameter parcli-qnty      like ub.doc-line.cli-qnty      no-undo.
define input  parameter pardoc-qnty      like ub.doc-line.doc-qnty      no-undo.
define output parameter pardensity       like ub.doc-line.doc-density   no-undo.
case parext-gds-type:
  when {&gds-lptrl}
  or when {&gds-kgptrl} then do:
     assign pardensity = parcli-qnty / pardoc-qnty .
  end.
  otherwise do:
     return error {&string-mes} + " пересчет плотности недопустим.".
  end.
end case.
end.

procedure lib-calc_clcclirt:
define input  parameter parext-gds-type  as   character                 no-undo.
define input  parameter parcli-qnty      like ub.doc-line.cli-qnty      no-undo.
define input  parameter pardoc-qnty      like ub.doc-line.doc-qnty      no-undo.
define input  parameter pardensity       like ub.doc-line.doc-density       no-undo.
define input  parameter parround         as   integer                   no-undo.
define output parameter parcli-base-rate like ub.doc-line.cli-base-rate no-undo.
case parext-gds-type:
  when {&gds-serial} then do:
     assign parcli-base-rate = 1.
  end.
  when {&gds-bottle} then do:
     assign parcli-base-rate = 1.
  end.
  when {&gds-gold} then do:
     assign parcli-base-rate = pardoc-qnty / parcli-qnty .
     if parcli-base-rate  = ? then parcli-base-rate = 1.
  end.
  when {&gds-lptrl} then do:
     assign parcli-base-rate = 1 / pardensity .
  end.
  when {&gds-kgptrl} then do:
     assign parcli-base-rate = 1 / pardensity.
  end.
  otherwise do:
     return error {&string-mes} + " пересчет коэф-та поставщика недопустим.".
  end.
end case.

end procedure.

/* методика заведения приходных данных */
procedure lib-calc_kndinpin:
define input  parameter pargds-code            like ub.goods.gds-code        no-undo.
define input  parameter parcli-type            like ub.clients.obj-type      no-undo.
define input  parameter parcli-code            like ub.clients.obj-code      no-undo.
define input  parameter parobj-type            like ub.clients.obj-type      no-undo.
define input  parameter parobj-code            like ub.clients.obj-code      no-undo.
define output parameter parext-gds-type        as   character      initial ? no-undo.
define output parameter parcli-qnty-input      as   logical        initial ? no-undo. /* Может ли быть задано данное поле в интерфейсе */
define output parameter pardensity-input       as   logical        initial ? no-undo.
define output parameter parcli-base-rate-input as   logical        initial ? no-undo.
define output parameter pardoc-qnty-input      as   logical        initial ? no-undo.
define output parameter parfact-qnty-input     as   logical        initial ? no-undo.
define output parameter parprice-cli-input     as   logical        initial ? no-undo.
define output parameter parbase-price-input    as   logical        initial ? no-undo.
define output parameter partax-3-input         as   logical        initial ? no-undo.
define output parameter parcli-qnty-calc       as   character      initial ? no-undo. /* Какие поля пересчитываются после изменения данного поля */
define output parameter pardensity-calc        as   character      initial ? no-undo.
define output parameter parcli-base-rate-calc  as   character      initial ? no-undo.
define output parameter pardoc-qnty-calc       as   character      initial ? no-undo.
define output parameter parfact-qnty-calc      as   character      initial ? no-undo.
define output parameter parprice-cli-calc      as   character      initial ? no-undo.
define output parameter parbase-price-calc     as   character      initial ? no-undo.
define output parameter partax-3-calc          as   character      initial ? no-undo.
define output parameter parround               as   integer        initial ? no-undo. /* округление при вычислении ведомого количества */

define variable varis-petrolium as logical             no-undo.
define variable varis-pieces    as logical             no-undo.
define variable varhvrdtax      as logical             no-undo.

define variable varupd-fact-qnty as logical   no-undo initial yes.
define variable varrevision      as logical   no-undo initial no.
define variable varpercrev       as decimal   no-undo initial ?.
define variable varauto-tank     as logical   no-undo initial no.
define variable varpercauto      as decimal   no-undo initial ?.
define variable varinv           as logical   no-undo initial no.
define variable varpercinv       as decimal   no-undo initial ?.
define variable varinv-set       as logical   no-undo initial no.

define variable stfactplvalue    as character no-undo initial ?.
define variable stfactpltype     as character no-undo initial ?.
define variable varvalue         as character no-undo initial ?.
define variable vartype          as character no-undo initial ?.

define buffer bf_goods        for ub.goods.
define buffer bf_units        for ub.units.
define buffer bf_clients-attr for ub.clients-attr.

find first bf_goods where bf_goods.gds-code = pargds-code no-lock no-error.
if not available bf_goods then do:
   return error "Не найден товар с внутренним кодом " + string(pargds-code) + " .".
end.
find first bf_units where bf_units.unit-name = bf_goods.unit-base no-lock.
if hvrdtax (recid(bf_goods)) then assign varhvrdtax = yes.
                             else assign varhvrdtax = no.
/* стеклопосуда */
if cross-list(bf_units.type, {&bottle}, ?) then do:
   if bf_goods.cli-base-rate <> 1 then
      return error "Неверно заведен товар стеклопосуда. Коэффициент поставщика: " + string(bf_goods.cli-base-rate) + " .".
   if bf_goods.unit-base <> bf_goods.unit-cli then
      return error "Неверно заведен товар стеклопосуда. Базовая единица: " + bf_goods.unit-base + " не равна единице поставщика " +  bf_goods.unit-cli + " .".
   assign
     parext-gds-type         = {&gds-bottle}
     parcli-qnty-input       = yes
     pardensity-input        = no
     parcli-base-rate-input  = no
     pardoc-qnty-input       = no
     parfact-qnty-input      = yes
     parprice-cli-input      = yes
     parbase-price-input     = no
     partax-3-input          = varhvrdtax
     parcli-qnty-calc        = "doc-qnty":U
     pardensity-calc         = ""
     parcli-base-rate-calc   = ""
     pardoc-qnty-calc        = ""
     parfact-qnty-calc       = ""
     parprice-cli-calc       = "acc-price":U
     parbase-price-calc      = ""
     partax-3-calc           = (if varhvrdtax then "road-tax,acc-price":U else "").
end.
/* не стеклопосуда */
else do:
   /* весовое золотишко */
   if cross-list(bf_units.type, {&twounit}, ?) then do:
      assign
        parext-gds-type         = {&gds-gold}
        parcli-qnty-input       = yes
        pardensity-input        = no
        parcli-base-rate-input  = no
        pardoc-qnty-input       = yes
        parfact-qnty-input      = yes
        parprice-cli-input      = no
        parbase-price-input     = yes
        partax-3-input          = no
        parcli-qnty-calc        = "cli-base-rate,cli-price":U
        pardensity-calc         = ""
        parcli-base-rate-calc   = ""
        pardoc-qnty-calc        = "cli-base-rate,cli-price":U
        parfact-qnty-calc       = ""
        parprice-cli-calc       = ""
        parbase-price-calc      = "cli-price":U
        partax-3-calc           = "".
   end.
   /* не стеклопосуда и не весовое золотишко */
   else do:
      { str/is-petrl.i
        bf_goods.artic
        bf_goods.prod-type
        bf_goods.prod-code
        varis-petrolium
        varis-pieces
        no-error }
      if error-status :error then return error "Ошибка при вызове процедуры is-petrl "
                                + return-value + error-status :get-message( 1 ) + error-status :get-message( 2 ) + " .".
      if varis-petrolium then do:
         /* штучное топливо */
         if varis-pieces then do:
            assign
                parext-gds-type         = {&gds-pcptrl}
                parcli-qnty-input       = no
                pardensity-input        = no
                parcli-base-rate-input  = yes
                pardoc-qnty-input       = yes
                parfact-qnty-input      = yes
                parprice-cli-input      = no
                parbase-price-input     = yes
                partax-3-input          = varhvrdtax
                parcli-qnty-calc        = ""
                pardensity-calc         = ""
                parcli-base-rate-calc   = "cli-qnty,cli-price":U
                pardoc-qnty-calc        = "cli-qnty":U
                parfact-qnty-calc       = ""
                parprice-cli-calc       = ""
                parbase-price-calc      = "cli-price":U
                partax-3-calc           = (if varhvrdtax then "road-tax,acc-price":U else "").
         end.
         /* жидкое топливо */
         else do:

            { gbl/ptrlprop.i run parobj-type parobj-code }

            { gbl/conf-rd.i "'stfactpl'" "''" "''" 0 "''" "''" "''" no stfactplvalue stfactpltype no-error }


            if stfactplvalue <> "":U then do:
              { str/chkqtpl.i
                stfactplvalue
                varupd-fact-qnty
                varrevision
                varpercrev
                varauto-tank
                varpercauto
                varinv
                varpercinv
                varinv-set
              }
            end.

            /* технологический пролив и ему подобное всегда оформляется через литр */
            find first bf_clients-attr where
                       bf_clients-attr.obj-type   = parcli-type      and
                       bf_clients-attr.obj-code   = parcli-code      and
                       bf_clients-attr.attr-code  = {&attr-shftrep2} and
                       bf_clients-attr.attr-value = "yes":U          no-lock no-error.
            if available bf_clients-attr then do:
              /* для техпролива всегда в приходе работаем через основную единицу измерения для расхода */
              if ptrlprop-expptrl = {&calc-petrol-weight} then do:
                assign
                  ptrlprop-inpptrl = {&calc-petrol-weight}
                .
              end.
              else do:
                assign
                  ptrlprop-inpptrl = {&calc-petrol-volume}
                .
              end.
            end.
            run gds-attr-value in this-procedure
              (  input pargds-code
              ,  input {&attr-fuel-type}
              , output varvalue
              , output vartype
              ) no-error .
            /*для типа топлива СУГ работаем через кг для метана через литры*/
           case varvalue:
             when 'lgas' then do:
                ptrlprop-inpptrl = {&calc-petrol-weight}.
             end.
             when 'metan' then do:
                ptrlprop-inpptrl = {&calc-petrol-volume}.
             end.
           end.

   
            if lookup( ptrlprop-inpptrl, "{&bef-calc-petrol-weight},{&bef-calc-petrol-weight-plus}":U ) > 0 then do:
              /* работаем через килограммы */
              assign
                parext-gds-type         = {&gds-kgptrl}
                parcli-qnty-input       = yes
                parcli-base-rate-input  = no
                parfact-qnty-input      = varupd-fact-qnty
                parprice-cli-input      = yes
                parbase-price-input     = no
                partax-3-input          = varhvrdtax
                parcli-base-rate-calc   = ""
                parfact-qnty-calc       = "":U
                parprice-cli-calc       = "acc-price":U
                parbase-price-calc      = ""
                partax-3-calc           = (if varhvrdtax then "road-tax,acc-price":U else "")
              .
              if ptrlprop-inpptrl = {&calc-petrol-weight-plus}
                and bf_goods.unit-base <> bf_goods.unit-cli
              then do:
                assign
                  pardensity-input        = no
                  pardoc-qnty-input       = (if bf_goods.unit-base <> bf_goods.unit-cli then true else false)
                  parcli-qnty-calc        = "density,cli-base-rate,acc-price":U
                  pardensity-calc         = "":U
                  pardoc-qnty-calc        = "density,cli-base-rate,acc-price":U
                .
              end.
              else do:
                assign
                  pardensity-input        = (if bf_goods.unit-base <> bf_goods.unit-cli then true else false)
                  pardoc-qnty-input       = no
                  parcli-qnty-calc        = "doc-qnty,acc-price":U
                  pardensity-calc         = "cli-base-rate,doc-qnty,acc-price":U
                  pardoc-qnty-calc        = "":U
                .
              end.
            end.
            else do:
              /* работаем за литры */
              assign
                parext-gds-type         = {&gds-lptrl}
                parcli-base-rate-input  = no
                pardoc-qnty-input       = yes
                parfact-qnty-input      = varupd-fact-qnty
                parprice-cli-input      = no
                parbase-price-input     = yes
                partax-3-input          = varhvrdtax
                parcli-base-rate-calc   = ""
                parfact-qnty-calc       = ""
                parprice-cli-calc       = "":U
                parbase-price-calc      = "cli-price":U
                partax-3-calc           = (if varhvrdtax then "road-tax,acc-price":U else "")
              .
              if ptrlprop-inpptrl = {&calc-petrol-volume-plus}
                and bf_goods.unit-base <> bf_goods.unit-cli
              then do:
                assign
                  pardensity-input        = no
                  parcli-qnty-input       = (if bf_goods.unit-base <> bf_goods.unit-cli then true else false)
                  parcli-qnty-calc        = "density,cli-base-rate,acc-price":U
                  pardensity-calc         = "":U
                  pardoc-qnty-calc        = "density,cli-base-rate,acc-price":U
                .
              end.
              else do:
                assign
                  pardensity-input        = (if bf_goods.unit-base <> bf_goods.unit-cli then true else false)
                  parcli-qnty-input       = no
                  parcli-qnty-calc        = ""
                  pardensity-calc         = "cli-qnty,cli-base-rate,acc-price":U
                  pardoc-qnty-calc        = "cli-qnty,cli-base-rate,acc-price":U
                .
              end.
            end.
         end.
      end.
      /* не золото, стеклопосуда, топливо */
      else do:
          /* серийный товар */
          if LOOKUP({&serial}, bf_units.type) > 0 then do:
             assign
               parext-gds-type         = {&gds-serial}
               parcli-qnty-input       = no
               pardensity-input        = no
               parcli-base-rate-input  = no
               pardoc-qnty-input       = no
               parfact-qnty-input      = no
               parprice-cli-input      = yes
               parbase-price-input     = no
               partax-3-input          = varhvrdtax
               parcli-qnty-calc        = ""
               pardensity-calc         = ""
               parcli-base-rate-calc   = ""
               pardoc-qnty-calc        = ""
               parfact-qnty-calc       = ""
               parprice-cli-calc       = "acc-price":U
               parbase-price-calc      = ""
               partax-3-calc           = (if varhvrdtax then "road-tax,acc-price":U else "").

          end.
          /* все остальное "обычный товар" или услуга */
          else do:
             assign
               parext-gds-type         = (if bf_goods.gds-type = {&gds-office} then {&gds-off-ordin} else {&gds-ordin})
               parcli-qnty-input       = yes
               pardensity-input        = no
               parcli-base-rate-input  = yes
               pardoc-qnty-input       = no
               parfact-qnty-input      = yes
               parprice-cli-input      = yes
               parbase-price-input     = no
               partax-3-input          = varhvrdtax
               parcli-qnty-calc        = "doc-qnty":U
               pardensity-calc         = ""
               parcli-base-rate-calc   = "doc-qnty,acc-price":U
               pardoc-qnty-calc        = ""
               parfact-qnty-calc       = ""
               parprice-cli-calc       = "acc-price":U
               parbase-price-calc      = ""
               partax-3-calc           = (if varhvrdtax then "road-tax,acc-price":U else "").
          end.
      end.
   end.
end.
end. /* kndinpin */

/* Расчет фактического количества бензина в зависимости от конфигурационных настроек */
procedure lib-calc_stfactqt :
  define input        parameter parstfactpl          as   character              no-undo .
  define input        parameter pardoc-qnty          like ub.doc-line.doc-qnty   no-undo .
  define input        parameter pardensity           like ub.doc-line.doc-density    no-undo .
  define input        parameter parrvs-before-qnty   like ub.doc-line.fact-qnty  no-undo .
  define input        parameter parrvs-after-qnty    like ub.doc-line.fact-qnty  no-undo .
  define input        parameter parauto-tank-qnty    like ub.doc-line.fact-qnty  no-undo .
  define input        parameter parauto-tank-density like ub.doc-line.fact-density    no-undo .
  define input        parameter parcheck-place       as   logical                no-undo .
  define input-output parameter parfact-qnty         like ub.doc-line.fact-qnty  no-undo .
  define       output parameter parchg               as   logical                no-undo .
  define       output parameter parst-doc            as   logical                no-undo .

  define variable varupdate    as logical no-undo initial yes .
  define variable varrevision  as logical no-undo initial no  .
  define variable varpercrev   as decimal no-undo initial ?   .
  define variable varauto-tank as logical no-undo initial no  .
  define variable varpercauto  as decimal no-undo initial ?   .
  define variable varinv       as logical no-undo initial no  .
  define variable varpercinv   as decimal no-undo initial ?   .
  define variable varinv-set   as logical no-undo initial no  .
  define variable vardelta     as decimal no-undo .
  define variable varnewqt     as decimal no-undo .
  define variable varoldqt     as decimal no-undo .

  do
  on error undo, return error return-value
  :
    if parstfactpl = ""
    then do:
      return .
    end.
    { str/chkqtpl.i
      parstfactpl
      varupdate
      varrevision
      varpercrev
      varauto-tank
      varpercauto
      varinv
      varpercinv
      varinv-set
      no-error
    }
    if error-status :error then do:
      return error substitute( "Ошибка при проверке параметра stfactpl : &1"
                             , return-value
                             ) .
    end.
    assign
      parchg    = no
      parst-doc = no
    .
    if varupdate <> true
      and varrevision <> true
      and varauto-tank <> true
    then do:
      assign
        parfact-qnty = pardoc-qnty
        parst-doc    = true
      .
    end.
    else do:
      if varrevision  = true
      then do:
        assign
          vardelta = pardoc-qnty * varpercrev * 0.01
          varnewqt = parrvs-after-qnty - parrvs-before-qnty
        .
        if varpercrev = 0.00 or
                pardoc-qnty - varnewqt   > vardelta or
           abs( pardoc-qnty - varnewqt ) > vardelta and parcheck-place = yes
        then do:
          if varnewqt < 0
          then do:
            return error substitute( "Неверное количество по сверкам: &1. Количество должно быть больше 0."
                                   , varnewqt
                                   ) .
          end.
          assign
            parfact-qnty = varnewqt
            parchg       = yes
          .
        end.
        else do:
          if varupdate      <> yes or
             parcheck-place  = yes
          then do:
            assign
              parfact-qnty = pardoc-qnty
              parst-doc    = yes
            .
          end.
        end.
      end. /* if varrevision = yes */
      if varauto-tank = yes
      then do:
        assign
          varoldqt = pardoc-qnty * pardensity
          vardelta = varoldqt * varpercauto * 0.01
          varnewqt = parauto-tank-qnty * parauto-tank-density
        .
        if varpercauto = 0.00 or
                varoldqt - varnewqt   > vardelta or
           abs( varoldqt - varnewqt ) > vardelta and parcheck-place = yes
        then do:
          assign
            parfact-qnty = parauto-tank-qnty
            parchg       = yes
          .
        end.
        else do:
          if varupdate <> yes
          then do:
            assign
              parfact-qnty = pardoc-qnty
              parst-doc    = yes
            .
          end.
        end.
      end. /* if varauto-tank = yes */
    end.
  end. /* on error */
end procedure. /* lib-calc_stfactqt */

/* Проверка параметра stfactpl */
procedure lib-calc_chkqtpl :
  define  input parameter p-stfactpl  as character no-undo.
  define output parameter p-update    as logical   no-undo initial true.
  define output parameter p-revision  as logical   no-undo initial false.
  define output parameter p-percrev   as decimal   no-undo initial ?.
  define output parameter p-auto-tank as logical   no-undo initial false.
  define output parameter p-percauto  as decimal   no-undo initial ?.
  define output parameter p-inv       as logical   no-undo initial false.
  define output parameter p-percinv   as decimal   no-undo initial ?.
  define output parameter p-inv-set   as logical   no-undo initial false.

  do
  on error undo, return error return-value
  :
    define variable v-count    as integer no-undo.
    define variable v-num      as integer no-undo.
    define variable v-cnt-true as integer   no-undo .

    assign
      v-num      = num-entries( p-stfactpl, ";" )
      v-cnt-true = 0
    .
    do v-count = 1 to v-num :
      case trim( entry( 1, trim( entry( v-count, p-stfactpl, ";" ) ), "=" ) ) :
        when "read-only":U then do:
          assign
            p-update = false
          .
        end. /* read-only */
        when "inv-set":U then do:
          assign
            p-inv-set = true
          .
        end. /* inv-set */
        when "revision":U  then do:
          assign
            v-cnt-true = v-cnt-true + 1
            p-revision = yes
            p-percrev  = decimal( entry( 2, trim( entry( v-count, p-stfactpl, ";" ) ), "=" ) )
            no-error.
          if error-status :error
            or p-percrev < 0.00
          then do:
            return error "Неверно задан процент отклонения в подпараметре revision параметра stfactpl.".
          end.
        end. /* revision */
        when "auto-tank":U then do:
          assign
            v-cnt-true  = v-cnt-true + 1
            p-auto-tank = true
            p-percauto  = decimal( entry( 2, trim( entry( v-count, p-stfactpl, ";" ) ), "=" ) )
            no-error.
          if error-status :error
            or p-percauto < 0.00
          then do:
            return error "Неверно задан процент отклонения в подпараметре auto-tank параметра stfactpl.".
          end.
        end. /* auto-tank */
        when "inv":U then do:
          assign
            p-inv      = true
            p-percinv  = decimal( entry( 2, trim( entry( v-count, p-stfactpl, ";" ) ), "=" ) )
            no-error.
          if error-status :error
            or p-percinv < 0.00
          then do:
            return error "Неверно задан процент отклонения в подпараметре inv параметра stfactpl.".
          end.
        end. /* inv */
        otherwise             do:
          return error substitute( "Неизвестный подпараметр &1 в параметре stfactpl.", trim( entry( v-count, p-stfactpl, ";" ) ) ).
        end. /* otherwise */
      end case. /* trim( entry( 1, trim( entry( v-count, p-stfactpl, ";" ) ), "=" ) ) */
    end. /* do varcount */

    if v-cnt-true > 1 then do:
      return error "Ошибка параметра stfactpl. Нельзя определять установку фактического количества сразу из двух источников измерений." +
                   "(В параметре не должны присутствовать revision, auto-tank, inv одновременно.)".
    end.
/*    if p-inv = true
      and p-update = true
    then do:
      return error "Ошибка параметра stfactpl. Подпараметр inv может быть установлен, если установлено read-only.".
    end.  */
  end. /* on error */
end procedure. /* lib-calc_chkqtpl */

/* Установка факт кол-ва в топливной строке внешней приходной накладной */
procedure lib-calc_lnfactqt :
  define input parameter parparentproc as   widget-handle      no-undo.
  define input parameter parrec-line   as   recid              no-undo.
  define input parameter paris-update  as   logical            no-undo. /* установка факт. кол-ва или проверка */
  define input parameter parstatus     like ub.trn-doc.status_ no-undo.
  define input parameter parflag       like ub.trn-doc.flag_   no-undo.

  define variable varstfactpl          as   character             no-undo.
  define variable varstfactpltype      as   character             no-undo.
  define variable vardoc-qnty          like ub.doc-line.doc-qnty  no-undo.
  define variable varrvs-before-qnty   like ub.doc-line.fact-qnty no-undo.
  define variable varrvs-after-qnty    like ub.doc-line.fact-qnty no-undo.
  define variable varauto-tank-qnty    like ub.doc-line.fact-qnty no-undo.
  define variable varauto-tank-density as   decimal               no-undo.
  define variable varfact-qnty         like ub.doc-line.fact-qnty no-undo.
  define variable varis-petrol         as   logical               no-undo.
  define variable varis-pieces         as   logical               no-undo.
  define variable varupdate            as   logical initial yes   no-undo.
  define variable varrevision          as   logical initial no    no-undo.
  define variable varpercrev           as   decimal initial ?     no-undo.
  define variable varauto-tank         as   logical initial no    no-undo.
  define variable varpercauto          as   decimal initial ?     no-undo.
  define variable varinv               as   logical initial no    no-undo.
  define variable varpercinv           as   decimal initial ?     no-undo.
  define variable varinv-set           as   logical initial no    no-undo .
  define variable varchg-qnty          like ub.gds-dtl.fact-qnty  no-undo.
  define variable varb-c               as   integer               no-undo.
  define variable varchg               as   logical               no-undo.
  define variable varst-doc            as   logical               no-undo.

  define buffer ln_doc-line        for ub.doc-line.
  define buffer ln_trn-doc         for ub.trn-doc.
  define buffer ln_goods           for ub.goods.
  define buffer ln_doc-line-attr   for ub.doc-line-attr.
  define buffer ln_rvs-doc-before  for ub.rvs-doc.
  define buffer ln_rvs-doc-after   for ub.rvs-doc.
  define buffer ln_rvs-line-before for ub.rvs-line.
  define buffer ln_rvs-line-after  for ub.rvs-line.
  define buffer ln_gds-dtl         for ub.gds-dtl.

  do on error undo, return error :
find first ln_doc-line where recid (ln_doc-line) = parrec-line.
find first ln_goods where ln_goods.artic     = ln_doc-line.artic     and
                          ln_goods.prod-type = ln_doc-line.prod-type and
                          ln_goods.prod-code = ln_doc-line.prod-code no-lock.
if parstatus = {&wayb} and
   parflag   = yes     then do:
   { str/is-petrl.i
    ln_goods.artic
    ln_goods.prod-type
    ln_goods.prod-code
    varis-petrol
    varis-pieces
    no-error
   }
   if error-status :error then do:
     return error return-value.
   end.
   if varis-petrol     and
      not varis-pieces then do:
     { gbl/conf-rd.i "'stfactpl':U" "''" "''" 0 "''" "''" "''" no varstfactpl varstfactpltype no-error }
     find first ln_goods where ln_goods.artic     = ln_doc-line.artic     and
                               ln_goods.prod-type = ln_doc-line.prod-type and
                               ln_goods.prod-code = ln_doc-line.prod-code no-lock.
     find first ln_doc-line-attr where ln_doc-line-attr.doc-code  = ln_doc-line.doc-code and
                                       ln_doc-line-attr.gds-code  = ln_goods.gds-code    and
                                       ln_doc-line-attr.attr-code = "tank-vol":U           no-error.
     if available ln_doc-line-attr then do:
       assign varauto-tank-qnty = decimal (ln_doc-line-attr.attr-value).
     end.
     else do:
       assign varauto-tank-qnty = 0.
     end.
     find first ln_doc-line-attr where ln_doc-line-attr.doc-code  = ln_doc-line.doc-code and
                                       ln_doc-line-attr.gds-code  = ln_goods.gds-code    and
                                       ln_doc-line-attr.attr-code = "tank-weight":U       no-error.  /*Пытаемся посчитать плотность из массы потому, что при приведении в атрибуте плотности указана замеренная плотность и полученные кг не равны объему умноженному на эту плотность*/
     if available ln_doc-line-attr then do:
       assign varauto-tank-density = decimal (ln_doc-line-attr.attr-value) / varauto-tank-qnty no-error.
     end.
     else do:
       assign varauto-tank-density = ?.
     end.
     if varauto-tank-density = ? then do: /* На случай, если кг не указаны, то пытаемся найти просто плотность*/
        find first ln_doc-line-attr where ln_doc-line-attr.doc-code  = ln_doc-line.doc-code and
                                       ln_doc-line-attr.gds-code  = ln_goods.gds-code    and
                                       ln_doc-line-attr.attr-code = "tank-density":U       no-error.  
         if available ln_doc-line-attr then do:
           assign varauto-tank-density = decimal (ln_doc-line-attr.attr-value)  no-error.
         end.
     end.    
     assign
       varrvs-before-qnty = 0
       varrvs-after-qnty  = 0.
     find first ln_rvs-doc-before where ln_rvs-doc-before.rvs-type = {&rvs-before-doc}    and
                                        ln_rvs-doc-before.out-code = ln_doc-line.doc-code no-error.
     if available ln_rvs-doc-before then do:
       find first ln_rvs-doc-after where ln_rvs-doc-after.rvs-type = {&rvs-after-doc}     and
                                         ln_rvs-doc-after.out-code = ln_doc-line.doc-code no-error.
       if available ln_rvs-doc-after then do:
         for each ln_rvs-line-before where ln_rvs-line-before.gds-code = ln_goods.gds-code          and
                                           ln_rvs-line-before.rvs-code = ln_rvs-doc-before.rvs-code and
                                           ln_rvs-line-before.obj-type = ln_doc-line.obj-type       and
                                           ln_rvs-line-before.obj-code = ln_doc-line.obj-code       :
             if varrvs-before-qnty = ? then do:
               assign varrvs-before-qnty = 0.00.
             end.
             assign varrvs-before-qnty = varrvs-before-qnty + ln_rvs-line-before.state-measure-qnty.
         end.
         for each ln_rvs-line-after where ln_rvs-line-after.gds-code = ln_goods.gds-code          and
                                          ln_rvs-line-after.rvs-code = ln_rvs-doc-after.rvs-code  and
                                          ln_rvs-line-after.obj-type = ln_doc-line.obj-type       and
                                          ln_rvs-line-after.obj-code = ln_doc-line.obj-code       :
             if varrvs-after-qnty = ? then do:
               assign varrvs-after-qnty = 0.00.
             end.
             assign varrvs-after-qnty = varrvs-after-qnty + ln_rvs-line-after.state-measure-qnty.
         end.
       end.
     end.
     assign
       varfact-qnty = ln_doc-line.fact-qnty
       vardoc-qnty  = ln_doc-line.doc-qnty
     .
     { str/stfactqt.i
       varstfactpl
       vardoc-qnty
       ln_doc-line.doc-density
       varrvs-before-qnty
       varrvs-after-qnty
       varauto-tank-qnty
       varauto-tank-density
       no
       varfact-qnty
       varchg
       varst-doc
       no-error
     }
     if error-status :error then do:
        return error substitute ("Ошибка при вызове процедуры lib-calc_stfactqt из процедуры lib-calc_lnfactqt: &1.", return-value).
     end.
     if paris-update = yes then do:
       /* У бензина один признак */
       find ln_gds-dtl where ln_gds-dtl.doc-code  = ln_doc-line.doc-code  and
                             ln_gds-dtl.artic     = ln_doc-line.artic     and
                             ln_gds-dtl.prod-type = ln_doc-line.prod-type and
                             ln_gds-dtl.prod-code = ln_doc-line.prod-code .
      assign
         varchg-qnty  = varfact-qnty - ln_gds-dtl.fact-qnty.

       run trg/rsrv-dtl.p ( input        parparentproc,
                        input        ( {&rsrv-dtl_action_reserv} + "," + {&rsrv-dtl_no-message} ),
                        buffer       ln_gds-dtl,
                        input-output varchg-qnty,
                        input-output ln_doc-line.price-base,
                        input-output ln_doc-line.price-rubl,
                        input        varb-c,
                        input "" ) no-error.
       if error-status :error then do:
         return error return-value.
       end.
       assign
         ln_gds-dtl.fact-qnty  = ln_gds-dtl.fact-qnty  + varchg-qnty
         ln_doc-line.fact-qnty = ln_doc-line.fact-qnty + varchg-qnty .
     end.
     else do:
       /* ошибка проверки факт кол-ва */
       /*if ln_doc-line.fact-qnty <> varfact-qnty then do:
          { str/chkqtpl.i
            varstfactpl
            varupdate
            varrevision
            varpercrev
            varauto-tank
            varpercauto
            varinv
            varpercinv
            varinv-set
            no-error
          }
          if error-status :error then do:
            return error substitute ( "Ошибка при проверке параметра stfactpl : &1", return-value).
          end.
          if varupdate <> yes then do:
            if not varrevision  and
               not varauto-tank then do:
               if ln_doc-line.doc-qnty <> varfact-qnty then do:
                 /* Произошла ошибка при вычислении нужного фактического количества */
                 return error "Ошибка при установке фактического количества".
               end.
               return error substitute ({&new-line}                                                   +
                                        "Ошибка при установке фактического количества"            +
                                        {&new-line}                                               +
                                        "Фактическое количество должно равняться документарному." +
                                        {&new-line}                                               +
                                        "Фактическое количество: &1"                              +
                                        {&new-line}                                               +
                                        "Документарное количество: &2" + {&new-line},
                                        ln_doc-line.fact-qnty,
                                        varfact-qnty
                                        ).
            end.
            else do:
              if varrevision then do:
                return error substitute (
                                        {&new-line}                                                   +
                                        "Ошибка при установке фактического количества"               +
                                        {&new-line}                                                   +
                                        "Фактическое количество должно быть из сверок по резервуару (в случае превышения отклонения) или равняться документарному." +
                                        {&new-line}                                                   +
                                        "Фактическое количество: &1"                                  +
                                        {&new-line}                                                   +
                                        "Количество из сверок по резервуарам: &2" + {&new-line}          +
                                        "Документарное количество: &3" + {&new-line},
                                        ln_doc-line.fact-qnty,
                                        varfact-qnty,
                                        vardoc-qnty
                                        ).
              end.
              else do:
                if varauto-tank then do:
                  return error substitute ({&new-line}                                                   +
                                          "Ошибка при установке фактического количества"               +
                                          {&new-line}                                                   +
                                          "Фактическое количество должно быть из объема топлива в автоцистерне (в случае превышения отклонения) или равняться документарному." +
                                          {&new-line}                                                   +
                                          "Фактическое количество: &1"                                  +
                                          {&new-line}                                                   +
                                          "Количество топлива в автоцистерне: &2" + {&new-line}         +
                                          "Документарное количество: &3" + {&new-line},
                                          ln_doc-line.fact-qnty,
                                          varfact-qnty,
                                          vardoc-qnty
                                          ).
                end.
                else do:
                  return error substitute ("Ошибка при установке фактического количества").
                end.
              end.
            end.
          end.
       end.*/
     end.
   end.
end.
  end. /* on error */
end procedure. /* lib-calc_lnfactqt */

procedure lib-calc_accgdspr:
define input  parameter parrec-line         as recid     no-undo.
define input  parameter parupd-price        as logical   no-undo.
define output parameter paragsum-base-doc   like ub.gds-dtl.price-base no-undo.
define output parameter paragsum-rubl-doc   like ub.gds-dtl.price-rubl no-undo.
define output parameter paragsum-base-fact  like ub.gds-dtl.price-base no-undo.
define output parameter paragsum-rubl-fact  like ub.gds-dtl.price-rubl no-undo.
define output parameter paragcount          as integer                 no-undo.
define buffer ag_doc-line for ub.doc-line.
define buffer ag_gds-dtl  for ub.gds-dtl.
define buffer ag_goods    for ub.goods.
define buffer ag_units    for ub.units.
define buffer ag_parts    for ub.parts.
define variable varagfact-qnty like ub.parts.fact-qnty   no-undo.
define variable varagroad-tax  like ub.doc-line.road-tax no-undo.
define variable varr-b         as   character            no-undo.
do on error undo, return error return-value :
{ gbl/curr-r-b.i varr-b }
find first ag_doc-line where recid(ag_doc-line) = parrec-line.
for each ag_gds-dtl where ag_gds-dtl.doc-code  = ag_doc-line.doc-code
                      and ag_gds-dtl.prod-code = ag_doc-line.prod-code
                      and ag_gds-dtl.prod-type = ag_doc-line.prod-type
                      and ag_gds-dtl.artic     = ag_doc-line.artic :

    if parupd-price <> no then do:
       if parupd-price = yes then do:

          { str/set-pr.i
            recid(ag_gds-dtl)
            no
            ?
            no-error }
          if error-status :error then return error return-value.
       end.
       /* Для стелобутылки установка дорожного налога */
       find first ag_goods where ag_goods.artic     = ag_gds-dtl.artic     and
                                 ag_goods.prod-type = ag_gds-dtl.prod-type and
                                 ag_goods.prod-code = ag_gds-dtl.prod-code no-lock.
       find first ag_units where ag_units.unit-name = ag_goods.unit-base no-lock.
       /* У стеклопосуды недопустимы признаки, => проход один */
       if cross-list(ag_units.type, {&bottle}, ?) then do:
          assign varagfact-qnty = 0
                 varagroad-tax  = 0.
          for each ag_parts where ag_parts.out-code  = ag_doc-line.doc-code  and
                                  ag_parts.obj-type  = ag_doc-line.obj-type  and
                                  ag_parts.obj-code  = ag_doc-line.obj-code  and
                                  ag_parts.artic     = ag_doc-line.artic     and
                                  ag_parts.prod-type = ag_doc-line.prod-type and
                                  ag_parts.prod-code = ag_doc-line.prod-code :
              assign
              varagfact-qnty = varagfact-qnty + ag_parts.fact-qnty
              .
              if varr-b = "rubl":u then do:
                assign
                  varagroad-tax  = varagroad-tax  + ag_parts.road-tax-rubl * ag_parts.fact-qnty.
              end.
              else do:
                assign
                  varagroad-tax  = varagroad-tax  + ag_parts.road-tax-base * ag_parts.fact-qnty.
              end.
          end.
          assign ag_doc-line.road-tax = varagroad-tax / varagfact-qnty.
       end.
   end.
   assign
   paragsum-base-doc   = paragsum-base-doc  +  ag_gds-dtl.price-base * ag_gds-dtl.doc-qnty
   paragsum-rubl-doc   = paragsum-rubl-doc  +  ag_gds-dtl.price-rubl * ag_gds-dtl.doc-qnty
   paragsum-base-fact  = paragsum-base-fact +  ag_gds-dtl.price-base * ag_gds-dtl.fact-qnty
   paragsum-rubl-fact  = paragsum-rubl-fact +  ag_gds-dtl.price-rubl * ag_gds-dtl.fact-qnty
   paragcount          = paragcount         +  1 .
end.
end.
end procedure.

procedure lib-calc_acsupacc:
define input  parameter parrec-line                         as   recid                 no-undo.
define output parameter parroad-tax-fact-base               like ub.gds-dtl.price-base no-undo.
define output parameter parexcise-fact-base                 like ub.gds-dtl.price-base no-undo.
define output parameter parslt-fact-base                    like ub.gds-dtl.price-base no-undo.
define output parameter parvat-fact-base                    like ub.gds-dtl.price-base no-undo.
define output parameter parslt-doc-base                     like ub.gds-dtl.price-base no-undo.
define output parameter parvat-doc-base                     like ub.gds-dtl.price-base no-undo.
define output parameter parsum-fact-out-dsc-slt-vat-base    like ub.gds-dtl.price-base no-undo.
define output parameter parroad-tax-fact-rubl               like ub.gds-dtl.price-base no-undo.
define output parameter parexcise-fact-rubl                 like ub.gds-dtl.price-base no-undo.
define output parameter parslt-fact-rubl                    like ub.gds-dtl.price-base no-undo.
define output parameter parvat-fact-rubl                    like ub.gds-dtl.price-base no-undo.
define output parameter parslt-doc-rubl                     like ub.gds-dtl.price-base no-undo.
define output parameter parvat-doc-rubl                     like ub.gds-dtl.price-base no-undo.
define output parameter parsum-fact-out-dsc-slt-vat-rubl    like ub.gds-dtl.price-base no-undo.
define output parameter parsum-fact-out-dsc-base            like ub.gds-dtl.price-base no-undo.
define output parameter parsum-fact-out-dsc-rubl            like ub.gds-dtl.price-base no-undo.
define output parameter parsum-fact-cur                     like ub.gds-dtl.price-base no-undo.
define output parameter parov-fact-base                     like ub.gds-dtl.price-base no-undo.
define output parameter parov-vat-fact-base                 like ub.gds-dtl.price-base no-undo.
define output parameter parsum-doc-cur                      like ub.gds-dtl.price-base no-undo.
define output parameter parov-doc-base                      like ub.gds-dtl.price-base no-undo.
define output parameter parov-vat-doc-base                  like ub.gds-dtl.price-base no-undo.
define output parameter parsum-doc-base                     like ub.gds-dtl.price-base no-undo.
define output parameter parsum-doc-rubl                     like ub.gds-dtl.price-base no-undo.
define output parameter parroad-tax-fact                    like ub.gds-dtl.price-base no-undo.
define output parameter parexcise-fact                      like ub.gds-dtl.price-base no-undo.
define output parameter parroad-tax-doc                     like ub.gds-dtl.price-base no-undo.
define output parameter parexcise-doc                       like ub.gds-dtl.price-base no-undo.
define output parameter pardiscnt-base-doc                  like ub.gds-dtl.price-base no-undo.
define output parameter pardiscnt-rubl-doc                  like ub.gds-dtl.price-base no-undo.
define output parameter pardiscnt-base-fact                 like ub.gds-dtl.price-base no-undo.
define output parameter pardiscnt-rubl-fact                 like ub.gds-dtl.price-base no-undo.
define buffer as_doc-line for ub.doc-line.
define buffer as_gds-dtl  for ub.gds-dtl.
define buffer as_trn-doc  for ub.trn-doc.
define variable varr-b as character no-undo.
do on error undo, return error return-value :
{ gbl/curr-r-b.i varr-b }
find first as_doc-line where recid(as_doc-line) = parrec-line.
find first as_trn-doc  where as_trn-doc.doc-code = as_doc-line.doc-code.
{ str/out-vatp.i def " " " " " " "as" }
{ str/out-vatp.i doc-line as_doc-line. as_trn-doc. " " "as" }
if as_trn-doc.ext-doc-type = {&TDEDt_Inv}
  or as_trn-doc.ext-doc-type = {&TDEDt_Peresort}
then do:
  assign
    parroad-tax-doc                  = (if varr-b = "base" then road-tax-base-saleas else road-tax-rubl-saleas) * as_doc-line.fact-qnty
    parslt-doc-base                  = slt-base-saleas * as_doc-line.fact-qnty
    parvat-doc-base                  = vat-base-saleas * as_doc-line.fact-qnty
    parsum-doc-base                  = (price-base-with-tax-saleas + discnt-base-saleas) * as_doc-line.fact-qnty
    parsum-doc-rubl                  = (price-rubl-with-tax-saleas + discnt-rubl-saleas) * as_doc-line.fact-qnty
    pardiscnt-base-doc               = discnt-base-saleas * as_doc-line.fact-qnty
    pardiscnt-rubl-doc               = discnt-rubl-saleas * as_doc-line.fact-qnty
    parexcise-doc                    = (if varr-b = "base" then excise-base-saleas else excise-rubl-saleas) * as_doc-line.fact-qnty
    parslt-doc-rubl                  = slt-base-saleas * as_doc-line.fact-qnty
    parvat-doc-rubl                  = vat-base-saleas * as_doc-line.fact-qnty.
end.
else do:
  assign
    parroad-tax-fact-base            = road-tax-base-saleas * as_doc-line.fact-qnty
    parexcise-fact-base              = excise-base-saleas * as_doc-line.fact-qnty
    parslt-fact-base                 = slt-base-saleas * as_doc-line.fact-qnty
    parvat-fact-base                 = vat-base-saleas * as_doc-line.fact-qnty
    parsum-fact-out-dsc-slt-vat-base = (price-base-with-tax-saleas - vat-base-saleas - slt-base-saleas) * as_doc-line.fact-qnty
    parsum-fact-out-dsc-base         = price-base-with-tax-saleas * as_doc-line.fact-qnty
    parsum-fact-out-dsc-rubl         = price-rubl-with-tax-saleas * as_doc-line.fact-qnty
    pardiscnt-base-fact              = discnt-base-saleas * as_doc-line.fact-qnty
    pardiscnt-rubl-fact              = discnt-rubl-saleas * as_doc-line.fact-qnty
    parroad-tax-fact-rubl            = road-tax-rubl-saleas * as_doc-line.fact-qnty
    parexcise-fact-rubl              = excise-rubl-saleas * as_doc-line.fact-qnty
    parslt-fact-rubl                 = slt-rubl-saleas * as_doc-line.fact-qnty
    parvat-fact-rubl                 = vat-rubl-saleas * as_doc-line.fact-qnty
    parsum-fact-out-dsc-slt-vat-rubl = (price-rubl-with-tax-saleas - vat-rubl-saleas - slt-rubl-saleas) * as_doc-line.fact-qnty
    parroad-tax-fact                 = (if varr-b = "base" then road-tax-base-saleas else road-tax-rubl-saleas) * as_doc-line.fact-qnty
    parexcise-fact                   = (if varr-b = "base" then excise-base-saleas else excise-rubl-saleas) * as_doc-line.fact-qnty.
end.
for each as_gds-dtl where as_gds-dtl.artic     = as_doc-line.artic
                      and as_gds-dtl.prod-type = as_doc-line.prod-type
                      and as_gds-dtl.prod-code = as_doc-line.prod-code
                      and as_gds-dtl.doc-code  = as_doc-line.doc-code no-lock:

  assign
    parsum-fact-cur                  =  parsum-fact-cur                  + as_gds-dtl.cur-base * as_gds-dtl.fact-qnty
    parsum-doc-cur                   =  parsum-doc-cur                   + as_gds-dtl.cur-base * as_gds-dtl.doc-qnty
  .
  if varr-b = "rubl":u then do:
    assign
      parov-fact-base                  =  parov-fact-base                  + (as_gds-dtl.cur-base - as_gds-dtl.price-rubl) * as_gds-dtl.fact-qnty
      parov-vat-fact-base              =  parov-vat-fact-base              + (as_gds-dtl.cur-base - as_gds-dtl.price-rubl) * as_gds-dtl.fact-qnty * as_doc-line.vat-pc / ( 100 + as_doc-line.vat-pc)
      parov-doc-base                   =  parov-doc-base                   + (as_gds-dtl.cur-base - as_gds-dtl.price-rubl) * as_gds-dtl.doc-qnty
      parov-vat-doc-base               =  parov-vat-doc-base               + (as_gds-dtl.cur-base - as_gds-dtl.price-rubl) * as_gds-dtl.doc-qnty * as_doc-line.vat-pc / ( 100 + as_doc-line.vat-pc)
    .
  end.
  else do:
    assign
      parov-fact-base                  =  parov-fact-base                  + (as_gds-dtl.cur-base - as_gds-dtl.price-base) * as_gds-dtl.fact-qnty
      parov-vat-fact-base              =  parov-vat-fact-base              + (as_gds-dtl.cur-base - as_gds-dtl.price-base) * as_gds-dtl.fact-qnty * as_doc-line.vat-pc / ( 100 + as_doc-line.vat-pc)
      parov-doc-base                   =  parov-doc-base                   + (as_gds-dtl.cur-base - as_gds-dtl.price-base) * as_gds-dtl.doc-qnty
      parov-vat-doc-base               =  parov-vat-doc-base               + (as_gds-dtl.cur-base - as_gds-dtl.price-base) * as_gds-dtl.doc-qnty * as_doc-line.vat-pc / ( 100 + as_doc-line.vat-pc)
    .
  end.
end. /* for each gds-dtl*/
end.
end procedure.
