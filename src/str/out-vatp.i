/*------------------------------------------------------------------------------------------
$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Возвращает структуру продажной цены

Автор: Чернова Светлана Александровна
Дата создания: 03/24/08
Author: Svetlana Chernova
Creation date: 03/24/08

Автор1: Суслов Алексей Юрьевич
Дата создания: 09/19/05


!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!     ВНИМАНИЕ!!! СКИДКА УЧТЕНА В ВОЗВРАЩАЕМЫХ ЦЕНАХ С НАЛОГАМИ И БЕЗ ОНЫХ             !!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

 {1} - определение переменных (def) или подсчет по признаку(calc-gds-dtl), строке(doc-line)
       или конкретной партии (calc-parts)
 {2} - буфер doc-line
 {3} - буфер trn-doc
 {4} - буфер gds-dtl (нужен только если подсчет идет по gds-dtl)
 {5} - суффикс переменных
 {6} - если надо вернуть не переменные, а параметры
 {7} - если не doc-code, а doc-num
 "{8}" = "cur" - если расчет идет на основе текущих продажных цен из конкретного признака при проходе по всему документу
 {9} - при работе по конкретной партии - префикс переменных отвечающих партии
 ===========
 Расчет НДС
 ==============================================================================================

 Расчет НДС по строке:
 ----------------------------------------------------------------------------

 Цена_реализации = Сумма(Цена_признака * кол-во_по_признаку) / кол-во по строке
 Учетная_цена_конс_товара = Сумма_конс_партий(Цена_партии * кол-во по партии) / кол-во_конс_товара

 Сумма_НДС = Сумма_НДС_конс + Сумма_НДС_выкуп
 Сумма_НДС = ((Цена_реализ - НСП) - Учет_цена_конс)) * НДС_конс * Кол-во_конс +
              (Цена_реализ - НСП) * НДС_выкуп * Кол-во_выкуп
 (1) Сумма_НДС = (Цена_реализ - НСП) * (НДС_конс * Кол-во_конс + НДС_выкуп * Кол_во_выкуп) - Учет_цена_конс * НДС_конс * Кол-во_конс
 Цена_НДС = (Цена_реализ - НСП) * (НДС_конс * Кол-во_конс + НДС_выкуп * Кол_во_выкуп) / Кол-во - Учет_цена_конс * НДС_конс * Кол-во_конс / Кол-во

 Расчет НДС по признаку, если есть консигнация:
 ------------------------------------------------------------------------------
 Всего по строке количество - K
 Количество по всем консигнационным партиям - Q
 Средняя учетная цена консигнационных партий - C
 Количество в признаке - y
 Количество консигнационного товара в признаке - y * Q / K
 Количество остального товара в признаке - у * (K- Q) / K
 Сумма_НДС = Сумма_консигнационной_части + Сумма_выкупной_части
 Сумма_НДС = [(Цена_реализ - НСП - C) * НДС_конс * y * Q / K + (Цена_реализ - НСП) * НДС_выкуп * у * (K- Q) / K]
 Цена_НДС = [(Цена_реализ - НСП - C) * НДС_конс * y * Q / K + (Цена_реализ - НСП) * НДС_выкуп * у * (K- Q) / K] / K


 Расчет НДС по признаку если нет консигнационного товара:
 --------------------------------------------------------

 Цена_НДС_признака = (Цена_релиз_признака - НСП) * НДС_выкуп

 Расчет НДС по выкупной партии:
 ------------------------------

 Цена_НДС_партии = (Цена_реализ - НСП) * НДС_выкуп

 Расчет НДС по консигнационной партии:
 -------------------------------------

 Цена_НДС_партии = (Цена_реализ - НСП - Учетная_цена_партии) * НДС_конс

 Расчет НДС по строке или признаку для покупателя:
 ------------------------------------------------

 Цена_НДС = (Цена_рализ - НСП) *  НДС_выкуп

 ===========================================================================================
 ------------------------------------------------------------------------------------------*/

&IF "{1}" = "def" &THEN
    define &IF "{6}" <> "" &THEN {6} &ELSE variable &ENDIF price-rubl-with-tax-sale{5}    like ub.doc-line.price-rubl no-undo.
    define &IF "{6}" <> "" &THEN {6} &ELSE variable &ENDIF price-base-with-tax-sale{5}    like ub.doc-line.price-base no-undo.
    define &IF "{6}" <> "" &THEN {6} &ELSE variable &ENDIF price-rubl-without-tax-sale{5} like ub.doc-line.price-rubl no-undo.
    define &IF "{6}" <> "" &THEN {6} &ELSE variable &ENDIF price-base-without-tax-sale{5} like ub.doc-line.price-base no-undo.
    define &IF "{6}" <> "" &THEN {6} &ELSE variable &ENDIF vat-base-sale{5}               like ub.doc-line.price-base no-undo.
    define &IF "{6}" <> "" &THEN {6} &ELSE variable &ENDIF vat-rubl-sale{5}               like ub.doc-line.price-rubl no-undo.
    define &IF "{6}" <> "" &THEN {6} &ELSE variable &ENDIF vat-base-buyer{5}              like ub.doc-line.price-base no-undo.
    define &IF "{6}" <> "" &THEN {6} &ELSE variable &ENDIF vat-rubl-buyer{5}              like ub.doc-line.price-rubl no-undo.
    define &IF "{6}" <> "" &THEN {6} &ELSE variable &ENDIF slt-base-sale{5}               like ub.doc-line.price-base no-undo.
    define &IF "{6}" <> "" &THEN {6} &ELSE variable &ENDIF slt-rubl-sale{5}               like ub.doc-line.price-rubl no-undo.
    define &IF "{6}" <> "" &THEN {6} &ELSE variable &ENDIF road-tax-base-sale{5}          like ub.doc-line.road-tax   no-undo.
    define &IF "{6}" <> "" &THEN {6} &ELSE variable &ENDIF road-tax-rubl-sale{5}          like ub.doc-line.road-tax   no-undo.
    define &IF "{6}" <> "" &THEN {6} &ELSE variable &ENDIF excise-base-sale{5}            like ub.doc-line.price-base no-undo.
    define &IF "{6}" <> "" &THEN {6} &ELSE variable &ENDIF excise-rubl-sale{5}            like ub.doc-line.price-rubl no-undo.
    define &IF "{6}" <> "" &THEN {6} &ELSE variable &ENDIF discnt-base-sale{5}            like ub.gds-dtl.discnt-base no-undo.
    define &IF "{6}" <> "" &THEN {6} &ELSE variable &ENDIF discnt-rubl-sale{5}            like ub.gds-dtl.discnt-rubl no-undo.

    define buffer out-vatp_gds-dtl{5}     for ub.gds-dtl.
    define buffer buf_out-vatp_gds-dtl{5} for ub.gds-dtl.
    define buffer out-vatp_parts{5}       for ub.parts.
    define buffer out-vatp_sysconf{5}     for ub.sysconf.
    define buffer out-vatp_doc-line{5}    for ub.doc-line.
    define buffer out-vatp_goods{5}       for ub.goods.
    define buffer out-vatp_trn-doc{5}     for ub.trn-doc.
    define buffer out-vatp_doc-attr{5}    for ub.doc-attr.

    define variable varprice-base-cons{5}      like ub.doc-line.price-base initial 0.00 no-undo.
    define variable varprice-rubl-cons{5}      like ub.doc-line.price-rubl initial 0.00 no-undo.
    define variable varfrm-cnsv-type{5}         as   character                           no-undo.
    define variable varfrm-cnsv{5}              as   character                           no-undo.
    define variable varroot-node{5}             as   integer                             no-undo.
    define variable varempty-scale{5}           as   logical                             no-undo.
    define variable varis-cons-parts-have{5}    as   logical                             no-undo.
    define variable varsum-base-factovp{5}      like ub.gds-dtl.price-base               no-undo.
    define variable varslt-base-factovp{5}      like ub.gds-dtl.price-base               no-undo.
    define variable varvat-base-factovp{5}      like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-base-factovp{5}  like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-base-factovp{5}      like ub.gds-dtl.price-base               no-undo.
    define variable varsum-base-docovp{5}       like ub.gds-dtl.price-base               no-undo.
    define variable varslt-base-docovp{5}       like ub.gds-dtl.price-base               no-undo.
    define variable varvat-base-docovp{5}       like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-base-docovp{5}   like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-base-docovp{5}       like ub.gds-dtl.price-base               no-undo.
    define variable varsum-rubl-factovp{5}      like ub.gds-dtl.price-base               no-undo.
    define variable varslt-rubl-factovp{5}      like ub.gds-dtl.price-base               no-undo.
    define variable varvat-rubl-factovp{5}      like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-rubl-factovp{5}  like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-rubl-factovp{5}      like ub.gds-dtl.price-base               no-undo.
    define variable varsum-rubl-docovp{5}       like ub.gds-dtl.price-base               no-undo.
    define variable varslt-rubl-docovp{5}       like ub.gds-dtl.price-base               no-undo.
    define variable varvat-rubl-docovp{5}       like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-rubl-docovp{5}   like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-rubl-docovp{5}       like ub.gds-dtl.price-base               no-undo.
    define variable varfact-qnty{5}             like ub.parts.fact-qnty                  no-undo.
    define variable varcons-qnty{5}             like ub.parts.fact-qnty                  no-undo.
    define variable varis-one-gds-dtl{5}        as   logical                             no-undo.
    define variable varcur{5}price-base         like ub.gds-dtl.cur-base                 no-undo.
    define variable varcur{5}price-rubl         like ub.gds-dtl.price-base               no-undo.
    define variable varcur{5}discnt-base        like ub.gds-dtl.cur-base                 no-undo.
    define variable varcur{5}discnt-rubl        like ub.gds-dtl.price-base               no-undo.
    define variable varoutvprb{5}               as   character                           no-undo.
    define variable out-vatp-have-vat-slt{5}    as   logical initial yes                 no-undo.
    { str/in-vatp.i def " " " " " " o{5} }
&else
if {3}ext-doc-type = {&TDEDT_Overturn} or
   {3}ext-doc-type = ?                 then do:
  assign
   out-vatp-have-vat-slt{5} = yes.
end.
else do:
  find first out-vatp_doc-attr{5} no-lock
    where out-vatp_doc-attr{5}.doc-code  = {3}doc-code
      and out-vatp_doc-attr{5}.attr-code = {&trdcattr-envd}
      no-error .
  if not available out-vatp_doc-attr{5} then do:
    assign
      out-vatp-have-vat-slt{5} = yes.
  end.
  else do:
     out-vatp-have-vat-slt{5} = no. 
      /*
    if out-vatp_doc-attr{5}.attr-value <> "yes":u then do:
      assign
        out-vatp-have-vat-slt{5} = yes.
    end.
    else do:
      find first out-vatp_trn-doc{5} where out-vatp_trn-doc{5}.doc-code = {3}doc-code no-lock.
      find out-vatp_sysconf{5} where out-vatp_sysconf{5}.host-code = out-vatp_trn-doc{5}.host-code no-lock.
      if out-vatp_trn-doc{5}.ext-doc-type = {&TDEDT_Ras_Vnesh_Kass}      or
         out-vatp_trn-doc{5}.ext-doc-type = {&TDEDT_Vozvrat_Vnesh_Kass}  or
         out-vatp_trn-doc{5}.pay-code     = out-vatp_sysconf{5}.cash-pay then do:
        assign
          out-vatp-have-vat-slt{5} = no.
      end.
      else do:
        assign
          out-vatp-have-vat-slt{5} = yes.
      end.
    end.
    */
  end.
end.
&scop road-tax-dtl    (if {2}road-tax = ? then 0 else {2}road-tax ~{&rate-calc-rubl-base})
&scop excise-dtl      (if {2}excise   = ? then 0 else {2}excise   ~{&rate-calc-rubl-base})
&scop price-dtl       (~{&gds-dtl-p~}price-~{&ext-rubl-base~} - ~{&gds-dtl-p~}discnt-~{&ext-rubl-base~})
&scop SLT-dtl         (if out-vatp-have-vat-slt{5} = no then 0 else ~{&gds-dtl-p~}price-~{&ext-rubl-base~} - ~{&gds-dtl-p~}discnt-~{&ext-rubl-base~}                - road-tax-~{&ext-rubl-base~}-sale{5}) * {2}SLT-pc / (100 + {2}SLT-pc)
&scop VAT-dtl         (if out-vatp-have-vat-slt{5} = no then 0 else ~{&gds-dtl-p~}price-~{&ext-rubl-base~} - ~{&gds-dtl-p~}discnt-~{&ext-rubl-base~} - ~{&SLT-dtl~} - road-tax-~{&ext-rubl-base~}-sale{5}) * {2}vat-pc / (100 + {2}vat-pc)
find first out-vatp_goods{5} where out-vatp_goods{5}.artic     = {2}artic     and
                                   out-vatp_goods{5}.prod-type = {2}prod-type and
                                   out-vatp_goods{5}.prod-code = {2}prod-code no-lock.
/* определяется корень шкалы товара */
{ gbl/rootnode.i
  {2}artic
  {2}prod-type
  {2}prod-code
  varroot-node{5}
  no-error
}
if error-status :error then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка при определении корневого признака товара" skip
    "Артикул" {2}artic {2}prod-type {2}prod-code skip
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  undo, return error .
end.

/* определяем, имеет ли товар пустую шкалу или шкалу с признаками */
{ gbl/prtat.i
  varroot-node{5}
  "'empty-scale=request'"
  varempty-scale{5}
  no-error
}
if error-status :error then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка при определении атрибута признака" skip
    "Артикул" {2}artic {2}prod-type {2}prod-code skip
    "Признак" varroot-node{5} skip
    "Запрашивался атрибут" "empty-scale=request" skip
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  undo, return error .
end.
{ gbl/curr-r-b.i varoutvprb{5} }

/*Расчитываем акциз и дорожный налог*/
&scop ext-rubl-base base
if varoutvprb{5} = "{&ext-rubl-base}":u then do:
  assign
    &scop rate-calc-rubl-base * 1
    road-tax-base-sale{5}    =  {&road-tax-dtl}
    excise-base-sale{5}      =  {&excise-dtl}
  .
end.
else do:
  assign
    &scop rate-calc-rubl-base / {3}base-rate * {3}base-scale
    road-tax-base-sale{5}    =  {&road-tax-dtl}
    excise-base-sale{5}      =  {&excise-dtl}
  .
end.
&scop ext-rubl-base rubl
if varoutvprb{5} = "{&ext-rubl-base}":u then do:
  assign
    &scop rate-calc-rubl-base * 1
    road-tax-rubl-sale{5}    = {&road-tax-dtl}
    excise-rubl-sale{5}      = {&excise-dtl} .
end.
else do:
  assign
    &scop rate-calc-rubl-base * {3}base-rate / {3}base-scale
    road-tax-rubl-sale{5}    = {&road-tax-dtl}
    excise-rubl-sale{5}      = {&excise-dtl} .
end.

assign
  varis-cons-parts-have{5} =  no.
assign
  varfact-qnty{5}       = 0
  varcons-qnty{5}       = 0
  varprice-base-cons{5} = 0
  varprice-rubl-cons{5} = 0.

/*Проход по консигнационным партиям*/
&if "{1}" = "calc-parts" &then
if {9}purch-code = {&bef-consignation-code} then do:
  { str/in-vatp.i calc-parts {9} {3} " " o{5} }
  assign
    varprice-base-cons{5}    = varprice-base-cons{5} + (price-base-with-tax-loco{5} - (if road-tax-base-loco{5} = ? then 0 else road-tax-base-loco{5}))* {9}fact-qnty
    varprice-rubl-cons{5}    = varprice-rubl-cons{5} + (price-rubl-with-tax-loco{5} - (if road-tax-rubl-loco{5} = ? then 0 else road-tax-rubl-loco{5}))* {9}fact-qnty
    varis-cons-parts-have{5} = yes
    varcons-qnty{5}          = varcons-qnty{5} + {9}fact-qnty.
end.
assign
  varfact-qnty{5} = {9}fact-qnty.
&else
find first out-vatp_doc-line{5} where
           out-vatp_doc-line{5}.doc-code   = &IF "{7}" <> "" &THEN {3}{7} &ELSE {3}doc-code &ENDIF
       and out-vatp_doc-line{5}.artic      = {2}artic
       and out-vatp_doc-line{5}.prod-type  = {2}prod-type
       and out-vatp_doc-line{5}.prod-code  = {2}prod-code no-lock no-error.
if available out-vatp_doc-line{5}           and
  (out-vatp_doc-line{5}.status_ = {&inquiry} or out-vatp_goods{5}.gds-type = {&gds-office}) then do:
  assign
    varfact-qnty{5} = out-vatp_doc-line{5}.fact-qnty.
end.
else do:
  for each out-vatp_parts{5} where out-vatp_parts{5}.out-code   = &IF "{7}" <> "" &THEN {3}{7} &ELSE {3}doc-code &ENDIF
                               and out-vatp_parts{5}.obj-type   = {3}obj-type
                               and out-vatp_parts{5}.obj-code   = {3}obj-code
                               and out-vatp_parts{5}.artic      = {2}artic
                               and out-vatp_parts{5}.prod-type  = {2}prod-type
                               and out-vatp_parts{5}.prod-code  = {2}prod-code no-lock :
    if out-vatp_parts{5}.purch-code = {&bef-consignation-code} then do:
      { str/in-vatp.i calc-parts out-vatp_parts{5}. {3} " " o{5} }
      assign
        varprice-base-cons{5} = varprice-base-cons{5} + (price-base-with-tax-loco{5} - (if road-tax-base-loco{5} = ? then 0 else road-tax-base-loco{5}))* out-vatp_parts{5}.fact-qnty
        varprice-rubl-cons{5} = varprice-rubl-cons{5} + (price-rubl-with-tax-loco{5} - (if road-tax-rubl-loco{5} = ? then 0 else road-tax-rubl-loco{5}))* out-vatp_parts{5}.fact-qnty.
      assign
        varis-cons-parts-have{5} = yes
        varcons-qnty{5}          = varcons-qnty{5} + out-vatp_parts{5}.fact-qnty.
    end.
    assign
      varfact-qnty{5} = varfact-qnty{5} + out-vatp_parts{5}.fact-qnty.
  end.
end.
&endif
assign
  varprice-base-cons{5} = varprice-base-cons{5} / varcons-qnty{5}
  varprice-rubl-cons{5} = varprice-rubl-cons{5} / varcons-qnty{5}.
if varprice-base-cons{5} = ? then do:
  assign
    varprice-base-cons{5} = 0.
end.
if varprice-rubl-cons{5} = ? then do:
  assign
    varprice-rubl-cons{5} = 0.
end.
&if "{1}" = "calc-gds-dtl" or
    "{1}" = "calc-parts"   &then
/*Информация по признаку*/
&scop gds-dtl   {4}
&scop gds-dtl-p {4}
assign
  &scop ext-rubl-base base
  slt-base-sale{5}               = {&SLT-dtl}
  vat-base-buyer{5}              = {&VAT-dtl}
  discnt-base-sale{5}            = {&gds-dtl}discnt-base
  price-base-with-tax-sale{5}    = {&price-dtl}
  &SCOP ext-rubl-base rubl
  slt-rubl-sale{5}               = {&SLT-dtl}
  vat-rubl-buyer{5}              = {&VAT-dtl}
  discnt-rubl-sale{5}            = {&gds-dtl}discnt-rubl
  price-rubl-with-tax-sale{5}    = {&price-dtl}
  .
if {3}doc-type = {&inventory} then do:
  assign
    varfact-qnty{5} = {&gds-dtl}doc-qnty.
end.
else do:
  assign
    varfact-qnty{5} = {&gds-dtl}fact-qnty.
end.
if varis-cons-parts-have{5} = no then do:
  assign
    &SCOP ext-rubl-base base
    vat-base-sale{5}               = {&VAT-dtl}
    &SCOP ext-rubl-base rubl
    vat-rubl-sale{5}               = {&VAT-dtl}.
end.
else do:
  if {3}doc-type = {&inventory} then do:
    assign
      &SCOP ext-rubl-base base
      vat-base-sale{5}               = (if out-vatp-have-vat-slt{5} = no then 0 else (({&price-dtl} - {&slt-dtl} - road-tax-{&ext-rubl-base}-sale{5} - varprice-{&ext-rubl-base}-cons{5}) * {2}cons-vat-pc / (100 + {2}cons-vat-pc) * {&gds-dtl}doc-qnty * varcons-qnty{5} / varfact-qnty{5} + ({&price-dtl} - {&slt-dtl} - road-tax-{&ext-rubl-base}-sale{5}) * {2}vat-pc / (100 + {2}vat-pc) * {&gds-dtl}doc-qnty * (varfact-qnty{5} - varcons-qnty{5}) / varfact-qnty{5}) / varfact-qnty{5})
      &SCOP ext-rubl-base rubl
      vat-rubl-sale{5}               = (if out-vatp-have-vat-slt{5} = no then 0 else (({&price-dtl} - {&slt-dtl} - road-tax-{&ext-rubl-base}-sale{5} - varprice-{&ext-rubl-base}-cons{5}) * {2}cons-vat-pc / (100 + {2}cons-vat-pc) * {&gds-dtl}doc-qnty * varcons-qnty{5} / varfact-qnty{5} + ({&price-dtl} - {&slt-dtl} - road-tax-{&ext-rubl-base}-sale{5}) * {2}vat-pc / (100 + {2}vat-pc) * {&gds-dtl}doc-qnty * (varfact-qnty{5} - varcons-qnty{5}) / varfact-qnty{5}) / varfact-qnty{5})
     .

  end.
  else do:
    assign
      &SCOP ext-rubl-base base
      vat-base-sale{5}               = (if out-vatp-have-vat-slt{5} = no then 0 else (({&price-dtl} - {&slt-dtl} - road-tax-{&ext-rubl-base}-sale{5} - varprice-{&ext-rubl-base}-cons{5}) * {2}cons-vat-pc / (100 + {2}cons-vat-pc) * {&gds-dtl}fact-qnty * varcons-qnty{5} / varfact-qnty{5} + ({&price-dtl} - {&slt-dtl} - varprice-{&ext-rubl-base}-cons{5}) * {2}vat-pc / (100 + {2}vat-pc) * {&gds-dtl}fact-qnty * (varfact-qnty{5} - varcons-qnty{5}) / varfact-qnty{5}) / varfact-qnty{5})
      &SCOP ext-rubl-base rubl
      vat-rubl-sale{5}               = (if out-vatp-have-vat-slt{5} = no then 0 else (({&price-dtl} - {&slt-dtl} - road-tax-{&ext-rubl-base}-sale{5} - varprice-{&ext-rubl-base}-cons{5}) * {2}cons-vat-pc / (100 + {2}cons-vat-pc) * {&gds-dtl}fact-qnty * varcons-qnty{5} / varfact-qnty{5} + ({&price-dtl} - {&slt-dtl} - varprice-{&ext-rubl-base}-cons{5}) * {2}vat-pc / (100 + {2}vat-pc) * {&gds-dtl}fact-qnty * (varfact-qnty{5} - varcons-qnty{5}) / varfact-qnty{5}) / varfact-qnty{5})
     .
  end.
end.
assign
price-base-without-tax-sale{5} = price-base-with-tax-sale{5} - vat-base-sale{5} - slt-base-sale{5} - road-tax-base-sale{5}
price-rubl-without-tax-sale{5} = price-rubl-with-tax-sale{5} - vat-rubl-sale{5} - slt-rubl-sale{5} - road-tax-rubl-sale{5}.
&undef gds-dtl
&undef gds-dtl-p
&else
&scop gds-dtl out-vatp_gds-dtl{5}.
&if "{8}" = "cur" &then
&scop gds-dtl-p varcur{5}
&else
&scop gds-dtl-p out-vatp_gds-dtl{5}.
&endif
assign
  varsum-base-factovp{5}     = 0
  varslt-base-factovp{5}     = 0
  varvat-base-factovp{5}     = 0
  varvatcons-base-factovp{5} = 0
  vardsc-base-factovp{5}     = 0
  varsum-base-docovp{5}      = 0
  varslt-base-docovp{5}      = 0
  varvat-base-docovp{5}      = 0
  varvatcons-base-docovp{5}  = 0
  vardsc-base-docovp{5}      = 0
  varsum-rubl-factovp{5}     = 0
  varslt-rubl-factovp{5}     = 0
  varvat-rubl-factovp{5}     = 0
  varvatcons-rubl-factovp{5} = 0
  vardsc-rubl-factovp{5}     = 0
  varsum-rubl-docovp{5}      = 0
  varslt-rubl-docovp{5}      = 0
  varvat-rubl-docovp{5}      = 0
  varvatcons-rubl-docovp{5}  = 0
  vardsc-rubl-docovp{5}      = 0.
assign
  varis-one-gds-dtl{5} = no.

find first out-vatp_gds-dtl{5} where out-vatp_gds-dtl{5}.doc-code  = {3}doc-code  and
                                     out-vatp_gds-dtl{5}.artic     = {2}artic     and
                                     out-vatp_gds-dtl{5}.prod-type = {2}prod-type and
                                     out-vatp_gds-dtl{5}.prod-code = {2}prod-code no-lock no-error.
/*Если есть хотя бы один признак*/
if available out-vatp_gds-dtl{5} then do:
  find first buf_out-vatp_gds-dtl{5} where buf_out-vatp_gds-dtl{5}.doc-code  =  {3}doc-code                and
                                           buf_out-vatp_gds-dtl{5}.artic     =  {2}artic                   and
                                           buf_out-vatp_gds-dtl{5}.prod-type =  {2}prod-type               and
                                           buf_out-vatp_gds-dtl{5}.prod-code =  {2}prod-code               and
                                           recid(buf_out-vatp_gds-dtl{5})    <> recid(out-vatp_gds-dtl{5}) no-lock no-error.
  if not available buf_out-vatp_gds-dtl{5} then do:
    assign
      varis-one-gds-dtl{5} = yes.
  end.
  if varoutvprb{5} = "base":u then do:
    assign
      varcur{5}price-base = {&gds-dtl}cur-base
      varcur{5}price-rubl = {&gds-dtl}cur-base * (({&gds-dtl}price-rubl - {&gds-dtl}discnt-rubl) / ({&gds-dtl}price-base - {&gds-dtl}discnt-base)).
  end.
  else do:
    assign
      varcur{5}price-base = {&gds-dtl}cur-base / (({&gds-dtl}price-rubl - {&gds-dtl}discnt-rubl) / ({&gds-dtl}price-base - {&gds-dtl}discnt-base))
      varcur{5}price-rubl = {&gds-dtl}cur-base.
  end.
  /*Если шкалы выключены или всего один признак в накладной*/
  if varempty-scale{5}    = yes or
     varis-one-gds-dtl{5} = yes   then do:
    assign
        &SCOP ext-rubl-base base
        price-base-with-tax-sale{5}    = {&price-dtl}
        slt-base-sale{5}               = {&SLT-dtl}
        vat-base-buyer{5}              = {&VAT-dtl}
        discnt-base-sale{5}            = out-vatp_gds-dtl{5}.discnt-base
        &SCOP ext-rubl-base rubl
        price-rubl-with-tax-sale{5}    = {&price-dtl}
        slt-rubl-sale{5}               = {&SLT-dtl}
        vat-rubl-buyer{5}              = {&VAT-dtl}
        discnt-rubl-sale{5}            = out-vatp_gds-dtl{5}.discnt-rubl
        .

    if {3}doc-type = {&inventory} then do:
      ASSIGN
        &SCOP ext-rubl-base base
        vat-base-sale{5}               = (if out-vatp-have-vat-slt{5} = no then 0 else (({&price-dtl} - {&slt-dtl} - road-tax-{&ext-rubl-base}-sale{5} - varprice-{&ext-rubl-base}-cons{5}) * {2}cons-vat-pc / (100 + {2}cons-vat-pc) * {&gds-dtl}doc-qnty * varcons-qnty{5} / varfact-qnty{5} + ({&price-dtl} - {&slt-dtl} - road-tax-{&ext-rubl-base}-sale{5}) * {2}vat-pc / (100 + {2}vat-pc) * {&gds-dtl}doc-qnty * (varfact-qnty{5} - varcons-qnty{5}) / varfact-qnty{5}) / varfact-qnty{5})
        &SCOP ext-rubl-base rubl
        vat-rubl-sale{5}               = (if out-vatp-have-vat-slt{5} = no then 0 else (({&price-dtl} - {&slt-dtl} - road-tax-{&ext-rubl-base}-sale{5} - varprice-{&ext-rubl-base}-cons{5}) * {2}cons-vat-pc / (100 + {2}cons-vat-pc) * {&gds-dtl}doc-qnty * varcons-qnty{5} / varfact-qnty{5} + ({&price-dtl} - {&slt-dtl} - road-tax-{&ext-rubl-base}-sale{5}) * {2}vat-pc / (100 + {2}vat-pc) * {&gds-dtl}doc-qnty * (varfact-qnty{5} - varcons-qnty{5}) / varfact-qnty{5}) / varfact-qnty{5})
        .
    end.
    else do:
      ASSIGN
        &SCOP ext-rubl-base base
        vat-base-sale{5}               = (if out-vatp-have-vat-slt{5} = no then 0 else (({&price-dtl} - {&slt-dtl} - road-tax-{&ext-rubl-base}-sale{5} - varprice-{&ext-rubl-base}-cons{5}) * {2}cons-vat-pc / (100 + {2}cons-vat-pc) * {&gds-dtl}fact-qnty * varcons-qnty{5} / varfact-qnty{5} + ({&price-dtl} - {&slt-dtl} - road-tax-{&ext-rubl-base}-sale{5} ) * {2}vat-pc / (100 + {2}vat-pc) * {&gds-dtl}fact-qnty * (varfact-qnty{5} - varcons-qnty{5}) / varfact-qnty{5}) / varfact-qnty{5})
        &SCOP ext-rubl-base rubl
        vat-rubl-sale{5}               = (if out-vatp-have-vat-slt{5} = no then 0 else (({&price-dtl} - {&slt-dtl} - road-tax-{&ext-rubl-base}-sale{5} - varprice-{&ext-rubl-base}-cons{5}) * {2}cons-vat-pc / (100 + {2}cons-vat-pc) * {&gds-dtl}fact-qnty * varcons-qnty{5} / varfact-qnty{5} + ({&price-dtl} - {&slt-dtl} - road-tax-{&ext-rubl-base}-sale{5}) * {2}vat-pc / (100 + {2}vat-pc) * {&gds-dtl}fact-qnty * (varfact-qnty{5} - varcons-qnty{5}) / varfact-qnty{5}) / varfact-qnty{5})
        .
    end.
  end.
  else do:
    for each out-vatp_gds-dtl{5} where out-vatp_gds-dtl{5}.doc-code  = {3}doc-code  and
                                       out-vatp_gds-dtl{5}.artic     = {2}artic     and
                                       out-vatp_gds-dtl{5}.prod-type = {2}prod-type and
                                       out-vatp_gds-dtl{5}.prod-code = {2}prod-code no-lock :
      if varoutvprb{5} = "base":u then do:
        assign
          varcur{5}price-base = {&gds-dtl}cur-base
          varcur{5}price-rubl = {&gds-dtl}cur-base * (({&gds-dtl}price-rubl - {&gds-dtl}discnt-rubl) / ({&gds-dtl}price-base - {&gds-dtl}discnt-base)).
      end.
      else do:
        assign
          varcur{5}price-base = {&gds-dtl}cur-base / (({&gds-dtl}price-rubl - {&gds-dtl}discnt-rubl) / ({&gds-dtl}price-base - {&gds-dtl}discnt-base))
          varcur{5}price-rubl = {&gds-dtl}cur-base.
      end.
      assign
      &scop ext-rubl-base base
       varsum-base-factovp{5} = varsum-base-factovp{5} + {&price-dtl}                 * out-vatp_gds-dtl{5}.fact-qnty
       varslt-base-factovp{5} = varslt-base-factovp{5} + {&SLT-dtl}                   * out-vatp_gds-dtl{5}.fact-qnty
       varvat-base-factovp{5} = varvat-base-factovp{5} + {&VAT-dtl}                   * out-vatp_gds-dtl{5}.fact-qnty
       varvatcons-base-factovp{5} = varvatcons-base-factovp{5} + (({&price-dtl} - {&slt-dtl} - road-tax-base-sale{5} - varprice-base-cons{5}) * {2}cons-vat-pc / (100 + {2}cons-vat-pc) * {&gds-dtl}fact-qnty * varcons-qnty{5} / varfact-qnty{5} + ({&price-dtl} - {&slt-dtl} - road-tax-base-sale{5}) * {2}vat-pc / (100 + {2}vat-pc) * {&gds-dtl}fact-qnty * (varfact-qnty{5} - varcons-qnty{5}) / varfact-qnty{5})
       vardsc-base-factovp{5} = vardsc-base-factovp{5} + out-vatp_gds-dtl{5}.discnt-base * out-vatp_gds-dtl{5}.fact-qnty
       varsum-base-docovp{5}  = varsum-base-docovp{5}  + {&price-dtl}                 * out-vatp_gds-dtl{5}.doc-qnty
       varslt-base-docovp{5}  = varslt-base-docovp{5}  + {&SLT-dtl}                   * out-vatp_gds-dtl{5}.doc-qnty
       varvat-base-docovp{5}  = varvat-base-docovp{5}  + {&VAT-dtl}                   * out-vatp_gds-dtl{5}.doc-qnty
       varvatcons-base-docovp{5}  = varvatcons-base-docovp{5}  + (({&price-dtl} - {&slt-dtl} - road-tax-base-sale{5} - varprice-base-cons{5}) * {2}cons-vat-pc / (100 + {2}cons-vat-pc) * {&gds-dtl}doc-qnty * varcons-qnty{5} / varfact-qnty{5} + ({&price-dtl} - {&slt-dtl} - road-tax-base-sale{5}) * {2}vat-pc / (100 + {2}vat-pc) * {&gds-dtl}doc-qnty * (varfact-qnty{5} - varcons-qnty{5}) / varfact-qnty{5})
       vardsc-base-docovp{5}  = vardsc-base-docovp{5}  + out-vatp_gds-dtl{5}.discnt-base * out-vatp_gds-dtl{5}.doc-qnty
      .
      assign
      &scop ext-rubl-base rubl
       varsum-rubl-factovp{5} = varsum-rubl-factovp{5} + {&price-dtl}                 * out-vatp_gds-dtl{5}.fact-qnty
       varslt-rubl-factovp{5} = varslt-rubl-factovp{5} + {&SLT-dtl}                   * out-vatp_gds-dtl{5}.fact-qnty
       varvat-rubl-factovp{5} = varvat-rubl-factovp{5} + {&VAT-dtl}                   * out-vatp_gds-dtl{5}.fact-qnty
       varvatcons-rubl-factovp{5} = varvatcons-rubl-factovp{5} + (({&price-dtl} - {&slt-dtl} - road-tax-rubl-sale{5} - varprice-rubl-cons{5}) * {2}cons-vat-pc / (100 + {2}cons-vat-pc) * {&gds-dtl}fact-qnty * varcons-qnty{5} / varfact-qnty{5} + ({&price-dtl} - {&slt-dtl} - road-tax-rubl-sale{5}) * {2}vat-pc / (100 + {2}vat-pc) * {&gds-dtl}fact-qnty * (varfact-qnty{5} - varcons-qnty{5}) / varfact-qnty{5})
       vardsc-rubl-factovp{5} = vardsc-rubl-factovp{5} + out-vatp_gds-dtl{5}.discnt-rubl * out-vatp_gds-dtl{5}.fact-qnty
       varsum-rubl-docovp{5}  = varsum-rubl-docovp{5}  + {&price-dtl}                 * out-vatp_gds-dtl{5}.doc-qnty
       varslt-rubl-docovp{5}  = varslt-rubl-docovp{5}  + {&SLT-dtl}                   * out-vatp_gds-dtl{5}.doc-qnty
       varvat-rubl-docovp{5}  = varvat-rubl-docovp{5}  + {&VAT-dtl}                   * out-vatp_gds-dtl{5}.doc-qnty
       varvatcons-rubl-docovp{5}  = varvatcons-rubl-docovp{5}  + (({&price-dtl} - {&slt-dtl} - road-tax-rubl-sale{5} - varprice-rubl-cons{5}) * {2}cons-vat-pc / (100 + {2}cons-vat-pc) * {&gds-dtl}doc-qnty * varcons-qnty{5} / varfact-qnty{5} + ({&price-dtl} - {&slt-dtl} - road-tax-rubl-sale{5}) * {2}vat-pc / (100 + {2}vat-pc) * {&gds-dtl}doc-qnty * (varfact-qnty{5} - varcons-qnty{5}) / varfact-qnty{5})
       vardsc-rubl-docovp{5}  = vardsc-rubl-docovp{5}  + out-vatp_gds-dtl{5}.discnt-rubl * out-vatp_gds-dtl{5}.doc-qnty   .
    end.
    if {3}doc-type = {&inventory} then do:
      ASSIGN
        &SCOP ext-rubl-base base
        price-base-with-tax-sale{5}    = varsum-base-docovp{5} / varfact-qnty{5}
        slt-base-sale{5}               = varslt-base-docovp{5} / varfact-qnty{5}
        vat-base-buyer{5}              = varvat-base-docovp{5} / varfact-qnty{5}
        discnt-base-sale{5}            = vardsc-base-docovp{5} / varfact-qnty{5}
        vat-base-sale{5}               = varvatcons-base-docovp{5} / varfact-qnty{5}
        &SCOP ext-rubl-base rubl
        price-rubl-with-tax-sale{5}    = varsum-rubl-docovp{5} / varfact-qnty{5}
        slt-rubl-sale{5}               = varslt-rubl-docovp{5} / varfact-qnty{5}
        vat-rubl-buyer{5}              = varvat-rubl-docovp{5} / varfact-qnty{5}
        discnt-rubl-sale{5}            = vardsc-rubl-docovp{5} / varfact-qnty{5}
        vat-rubl-sale{5}               = varvatcons-rubl-docovp{5} / varfact-qnty{5}.
    end.
    else do:
      ASSIGN
        &SCOP ext-rubl-base base
        price-base-with-tax-sale{5}    = varsum-base-factovp{5} / varfact-qnty{5}
        slt-base-sale{5}               = varslt-base-factovp{5} / varfact-qnty{5}
        vat-base-buyer{5}              = varvat-base-factovp{5} / varfact-qnty{5}
        discnt-base-sale{5}            = vardsc-base-factovp{5} / varfact-qnty{5}
        vat-base-sale{5}               = varvatcons-base-factovp{5} / varfact-qnty{5}
        &SCOP ext-rubl-base rubl
        price-rubl-with-tax-sale{5}    = varsum-rubl-factovp{5} / varfact-qnty{5}
        slt-rubl-sale{5}               = varslt-rubl-factovp{5} / varfact-qnty{5}
        vat-rubl-buyer{5}              = varvat-rubl-factovp{5} / varfact-qnty{5}
        discnt-rubl-sale{5}            = vardsc-rubl-factovp{5} / varfact-qnty{5}
        vat-rubl-sale{5}               = varvatcons-rubl-factovp{5} / varfact-qnty{5}.
    end.
  end.
end.
assign
  price-base-without-tax-sale{5} = price-base-with-tax-sale{5} - vat-base-sale{5} - slt-base-sale{5} - road-tax-base-sale{5}
  price-rubl-without-tax-sale{5} = price-rubl-with-tax-sale{5} - vat-rubl-sale{5} - slt-rubl-sale{5} - road-tax-rubl-sale{5}.
&UNDEF gds-dtl
&endif
&endif