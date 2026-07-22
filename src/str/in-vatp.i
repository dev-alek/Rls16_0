/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Программа расчета суммы учетных цен со всеми налогами по строке в целом или партии в частности

Автор: Суслов Алексей Юрьевич
Дата создания: 04/11/06
Author: Alexey Suslov
Creation date: 04/11/06


Структура цены:
  цена без всех налогов(1) + НДС(2) + НП(3) + ДорНалог(4) + Трансп.расх.(5) + Проч.расх.(6)
Если старая розничная схема:
  Учетная цена = 1 + 2 + 3 + 4 + 5 + 6
Если новая оптовая - не должна использоватьс
  Учетная цена = 1 + 3 + 4 + 5 + 6
{1} - определение переменных def или подсчет по соответствующей таблице calc-parts, calc
{2} - буфер doc-line или parts
{3} - буфер trn-doc
{4} - параметр не употребляетс
{5} - суффикс переменных
РЕЗУЛЬТАТЫ В ВАЛЮТЕ ПОСТАВЩИКА ВОЗВРАЩАЮТСЯ ТОЛЬКО В СЛУЧАЕ ЗАПРОСА ПО ПАРТИИ!
*/
&scop road-tax-cfg  ~~~~~~~~~~~~~~~{&pf~~~~~~~~~~~~~~~}road-tax-~~~~~~~~~~~~~~~{&crc~~~~~~~~~~~~~~~}~~~~~~~~~~~~~~~{&sf~~~~~~~~~~~~~~~}~~~~~~~~~~~~~~~{&vr~~~~~~~~~~~~~~~}
&scop transport-cfg ~~~~~~~~~~~~~~~{&pf~~~~~~~~~~~~~~~}transport-~~~~~~~~~~~~~~~{&crc~~~~~~~~~~~~~~~}~~~~~~~~~~~~~~~{&sf~~~~~~~~~~~~~~~}~~~~~~~~~~~~~~~{&vr~~~~~~~~~~~~~~~}
&scop other-cfg     ~~~~~~~~~~~~~~~{&pf~~~~~~~~~~~~~~~}other-~~~~~~~~~~~~~~~{&crc~~~~~~~~~~~~~~~}~~~~~~~~~~~~~~~{&sf~~~~~~~~~~~~~~~}~~~~~~~~~~~~~~~{&vr~~~~~~~~~~~~~~~}
&scop sm-7-tld      ((if {&road-tax-cfg}  = ? then 0 else {&road-tax-cfg}) + (if {&transport-cfg} = ? then 0 else {&transport-cfg}) + (if {&other-cfg} = ? then 0 else {&other-cfg}))
&scop sm-3-tld {&sm-7-tld}
&scop sm       {&sm-3-tld}
&scop slt-koef-local   slt-pc-loc{5} / (100 + slt-pc-loc{5})
&scop vat-koef-local   vat-pc-loc{5} / (100 + vat-pc-loc{5})
&scop ass-vat ASSIGN   slt-~{&crc}-loc{5}    = (if in-vatp-have-vat-slt{5} = no then 0 else (price-~{&crc}-with-tax-loc{5} - {&sm-3-tld})                           * {&slt-koef-local}) ~
                       vat-~{&crc}-loc{5}    = (if in-vatp-have-vat-slt{5} = no then 0 else (price-~{&crc}-with-tax-loc{5} - {&sm-3-tld}) * (1 - {&slt-koef-local}) * {&vat-koef-local}).
&IF "{1}" <> "def"        and
    "{1}" <> "calc"       and
    "{1}" <> "calc-parts" &then
    &MESSAGE $Workfile$ Неверный параметр вызова 1 {1}
&ENDIF
&IF "{1}" = "def" &THEN
    define buffer   in-vatp-trn-doc{5}  for ub.trn-doc .
    define buffer   in-vatp-parts{5}    for ub.parts   .
    define buffer   in-vatp-doc{5}      for ub.trn-doc .
    define buffer   in-vatp-goods{5}    for ub.goods   .
    define buffer   in-vatp-sysconf{5}  for ub.sysconf .
    define buffer   in-vatp_doc-attr{5} for ub.doc-attr.

    define variable in-vatp-have-vat-slt{5}       as   logical initial yes    no-undo.
    define variable vat-pc-loc{5}                 like ub.doc-line.vat-pc     no-undo.
    define variable varinvprb{5}                  as   character              no-undo.
    define variable slt-pc-loc{5}                 like ub.doc-line.slt-pc     no-undo.
    define variable cli-base-rate{5}              as   decimal                no-undo.
    define variable price-rubl-with-tax-loc{5}    like ub.doc-line.price-rubl no-undo.
    define variable price-base-with-tax-loc{5}    like ub.doc-line.price-base no-undo.
    define variable price-cli-with-tax-loc{5}     like ub.doc-line.price-cli  no-undo.
    define variable price-rubl-without-tax-loc{5} like ub.doc-line.price-rubl no-undo.
    define variable price-base-without-tax-loc{5} like ub.doc-line.price-base no-undo.
    define variable price-cli-without-tax-loc{5}  like ub.doc-line.price-base no-undo.
    define variable vat-base-loc{5}               like ub.doc-line.price-base no-undo.
    define variable vat-rubl-loc{5}               like ub.doc-line.price-rubl no-undo.
    define variable vat-cli-loc{5}                like ub.doc-line.price-rubl no-undo.
    define variable slt-base-loc{5}               like ub.doc-line.price-base no-undo.
    define variable slt-rubl-loc{5}               like ub.doc-line.price-rubl no-undo.
    define variable slt-cli-loc{5}                like ub.doc-line.price-rubl no-undo.
    define variable road-tax-base-loc{5}          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-rubl-loc{5}          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-cli-loc{5}           like ub.doc-line.road-tax   no-undo.
    define variable transport-base-loc{5}         like ub.doc-line.price-base no-undo.
    define variable transport-rubl-loc{5}         like ub.doc-line.price-rubl no-undo.
    define variable transport-cli-loc{5}          like ub.doc-line.price-rubl no-undo.
    define variable other-base-loc{5}             like ub.doc-line.price-base no-undo.
    define variable other-rubl-loc{5}             like ub.doc-line.price-rubl no-undo.
    define variable other-cli-loc{5}              like ub.doc-line.price-rubl no-undo.
    define variable exch-rate-cli-loc{5}          like ub.trn-doc.exch-rate   no-undo.
    define variable varinvatp-envd{5}             as   character              no-undo.
    define variable varinvatp-type{5}             as   character              no-undo.

&ENDIF

&IF "{1}" = "calc-parts" OR
    "{1}" = "calc" &THEN
assign
  price-rubl-with-tax-loc{5} = {2}price-rubl
  price-base-with-tax-loc{5} = {2}price-base
.
{ gbl/curr-r-b.i varinvprb{5} }
&IF "{1}" = "calc-parts" &THEN
  if {2}out-code = {&free-code}     or
     {2}out-code = {&output-code}   or
     {2}doc-type = {&act-overvalue} then do:
    assign
      in-vatp-have-vat-slt{5} = yes.
  end.
  else do:
    find first in-vatp_doc-attr{5} no-lock
      where in-vatp_doc-attr{5}.doc-code  = {2}out-code
        and in-vatp_doc-attr{5}.attr-code = {&trdcattr-envd}
      no-error .
    if not available in-vatp_doc-attr{5} then do:
      assign
        in-vatp-have-vat-slt{5} = yes.
    end.
    else do:
         in-vatp-have-vat-slt{5} = no.
     /* if in-vatp_doc-attr{5}.attr-value <> "yes":u then do:
        assign
          in-vatp-have-vat-slt{5} = no.
      end.
      else do:
        find first in-vatp-trn-doc{5} where in-vatp-trn-doc{5}.doc-code  = {2}out-code no-lock.
        find first in-vatp-sysconf{5} where in-vatp-sysconf{5}.host-code = {2}host-code no-lock.
        if in-vatp-trn-doc{5}.ext-doc-type = {&TDEDT_Ras_Vnesh_Kass}     or
           in-vatp-trn-doc{5}.ext-doc-type = {&TDEDT_Vozvrat_Vnesh_Kass} or
           in-vatp-trn-doc{5}.pay-code     = in-vatp-sysconf{5}.cash-pay
           then do:
          assign
            in-vatp-have-vat-slt{5} = no.
        end.
        else do:
          assign
            in-vatp-have-vat-slt{5} = yes.
        end.
      end.  */
    end.
  end.
  assign
   price-cli-with-tax-loc{5} = {2}price-cli
   cli-base-rate{5}          = {2}cli-base-rate.
  ASSIGN   road-tax-base-loc{5}  = (if {2}road-tax-base  = ? then 0 else {2}road-tax-base)
           road-tax-rubl-loc{5}  = (if {2}road-tax-rubl  = ? then 0 else {2}road-tax-rubl).

  ASSIGN  transport-base-loc{5} = (if {2}transport-base = ? then 0 else {2}transport-base)
          transport-rubl-loc{5} = (if {2}transport-rubl = ? then 0 else {2}transport-rubl)
          other-base-loc{5}     = (if {2}other-base     = ? then 0 else {2}other-base)
          other-rubl-loc{5}     = (if {2}other-rubl     = ? then 0 else {2}other-rubl)
          vat-pc-loc{5}         = (if {2}vat-pc         = ? then 0 else {2}vat-pc)
          slt-pc-loc{5}         = (if {2}slt-pc         = ? then 0 else {2}slt-pc).
  &scop pf
  &scop vr {5}
  &scop sf -loc
  &scop crc base
  {&ass-vat}
  &scop crc rubl
  {&ass-vat}
  assign
    exch-rate-cli-loc{5} = ({2}price-rubl - transport-rubl-loc{5} - other-rubl-loc{5} - road-tax-rubl-loc{5} - (if {2}vat-type <> {&inc-vat} then vat-rubl-loc{5} else 0) - (if {2}slt-type <> {&inc-slt} then slt-rubl-loc{5} else 0)) / {2}price-cli .
  assign
    slt-cli-loc{5}        = slt-rubl-loc{5}       / exch-rate-cli-loc{5}
    vat-cli-loc{5}        = vat-rubl-loc{5}       / exch-rate-cli-loc{5}
    road-tax-cli-loc{5}   = road-tax-rubl-loc{5}  / exch-rate-cli-loc{5}
    transport-cli-loc{5}  = 0
    other-cli-loc{5}      = 0
  .
&ELSE
  /* 
   find first in-vatp-trn-doc{5} where in-vatp-trn-doc{5}.doc-code = {2}doc-code no-lock.
   find in-vatp-sysconf{5} where in-vatp-sysconf{5}.host-code = in-vatp-trn-doc{5}.host-code no-lock.
   */
   find first in-vatp_doc-attr{5} no-lock
    where in-vatp_doc-attr{5}.doc-code  = {3}doc-code
      and in-vatp_doc-attr{5}.attr-code = {&trdcattr-envd}
    no-error .
    if available in-vatp_doc-attr{5} 
    /* and /*   if in-vatp-sysconf{5}.vat-sp = 999 and*/
      (in-vatp-trn-doc{5}.ext-doc-type = {&TDEDT_Ras_Vnesh_Kass}     or
      in-vatp-trn-doc{5}.ext-doc-type = {&TDEDT_Vozvrat_Vnesh_Kass} or
      (in-vatp-trn-doc{5}.ext-doc-type = {&TDEDT_Ras_Vnesh}     and in-vatp-trn-doc{5}.pay-code = in-vatp-sysconf{5}.cash-pay) or
      (in-vatp-trn-doc{5}.ext-doc-type = {&TDEDT_Vozvrat_Vnesh} and in-vatp-trn-doc{5}.pay-code = in-vatp-sysconf{5}.cash-pay)) */
       then do:
       assign
         in-vatp-have-vat-slt{5} = no.
   end.
   else do:
     assign
       in-vatp-have-vat-slt{5} = yes.
   end.
   find first in-vatp-goods{5} where in-vatp-goods{5}.artic     = {2}artic     and
                                     in-vatp-goods{5}.prod-type = {2}prod-type and
                                     in-vatp-goods{5}.prod-code = {2}prod-code no-lock.
   if (not {3}internal and
           {3}doc-type = {&income}) or
      in-vatp-goods{5}.gds-type = {&gds-office} then do:
      if varinvprb{5} = "base":u then do:
        assign
          road-tax-base-loc{5} = {2}road-tax
          road-tax-rubl-loc{5} = {2}road-tax * {3}base-rate / {3}base-scale.
      end.
      else do:
        ASSIGN
          road-tax-rubl-loc{5} = {2}road-tax
          road-tax-base-loc{5} = {2}road-tax / {3}base-rate * {3}base-scale.
      end.
      if road-tax-base-loc{5} = ? then road-tax-base-loc{5} = 0.
      if road-tax-rubl-loc{5} = ? then road-tax-rubl-loc{5} = 0.
      assign
        road-tax-cli-loc{5} = ?.
      ASSIGN
        transport-base-loc{5} = (if {2}transport-base = ? then 0 else {2}transport-base)
        transport-rubl-loc{5} = (if {2}transport-rubl = ? then 0 else {2}transport-rubl)
        transport-cli-loc{5}  = 0
        other-base-loc{5}     = (if {2}other-base     = ? then 0 else {2}other-base)
        other-rubl-loc{5}     = (if {2}other-rubl     = ? then 0 else {2}other-rubl)
        other-cli-loc{5}      = 0
        vat-pc-loc{5}         = (if {2}vat-pc         = ? then 0 else {2}vat-pc)
        slt-pc-loc{5}         = (if {2}slt-pc         = ? then 0 else {2}slt-pc).
      &scop pf
      &scop vr {5}
      &scop sf -loc
      &scop crc base
      {&ass-vat}
      &scop crc rubl
      {&ass-vat}
      assign
        vat-cli-loc{5}            = ?
        slt-cli-loc{5}            = ?
        price-cli-with-tax-loc{5} = ?.
   end.
   else do:
      &scop summa-without-abs-tax (in-vatp-parts{5}.price-~~~{&crc} - {&sm-7-tld})   * in-vatp-parts{5}.fact-qnty
      &scop slt-koef              in-vatp-parts{5}.slt-pc / (100 + in-vatp-parts{5}.slt-pc)
      &scop vat-koef              in-vatp-parts{5}.vat-pc / (100 + in-vatp-parts{5}.vat-pc)
      &scop summa-slt-parts       (if in-vatp-have-vat-slt{5} = no then 0 else {&summa-without-abs-tax}                     * {&slt-koef})
      &scop summa-vat-parts       (if in-vatp-have-vat-slt{5} = no then 0 else {&summa-without-abs-tax} * (1 - {&slt-koef}) * {&vat-koef})
      &scop accum-slt-parts       (if in-vatp-have-vat-slt{5} = no then 0 else {&summa-without-abs-tax}                      / (100 + in-vatp-parts{5}.slt-pc))
      &scop accum-vat-parts       (if in-vatp-have-vat-slt{5} = no then 0 else {&summa-without-abs-tax} * (1 - {&slt-koef})  / (100 + in-vatp-parts{5}.vat-pc))
      for each in-vatp-parts{5} where in-vatp-parts{5}.out-code  = {2}doc-code  and
                                      in-vatp-parts{5}.obj-type  = {2}obj-type  and
                                      in-vatp-parts{5}.obj-code  = {2}obj-code  and
                                      in-vatp-parts{5}.artic     = {2}artic     and
                                      in-vatp-parts{5}.prod-type = {2}prod-type and
                                      in-vatp-parts{5}.prod-code = {2}prod-code
                         use-index out-code no-lock:
          accumulate  in-vatp-parts{5}.road-tax-base  * in-vatp-parts{5}.fact-qnty (total)
                      in-vatp-parts{5}.road-tax-rubl  * in-vatp-parts{5}.fact-qnty (total)
                      in-vatp-parts{5}.transport-base * in-vatp-parts{5}.fact-qnty (total)
                      in-vatp-parts{5}.transport-rubl * in-vatp-parts{5}.fact-qnty (total)
                      in-vatp-parts{5}.other-base     * in-vatp-parts{5}.fact-qnty (total)
                      in-vatp-parts{5}.other-rubl     * in-vatp-parts{5}.fact-qnty (total)
                      &scop pf in-vatp-parts{5}.
                      &scop vr
                      &scop sf
                      &scop crc base
                      {&summa-slt-parts}  (total)
                      {&accum-slt-parts}  (total)
                      {&summa-vat-parts}  (total)
                      {&accum-vat-parts}  (total)
                      &scop crc rubl
                      {&summa-slt-parts}  (total)
                      {&accum-slt-parts}  (total)
                      {&summa-vat-parts}  (total)
                      {&accum-vat-parts}  (total)
                      .
      end.
      ASSIGN
        road-tax-base-loc{5}   = if {2}fact-qnty <> 0 then (accum total in-vatp-parts{5}.road-tax-base  * in-vatp-parts{5}.fact-qnty) / {2}fact-qnty  else 0
        road-tax-rubl-loc{5}   = if {2}fact-qnty <> 0 then (accum total in-vatp-parts{5}.road-tax-rubl  * in-vatp-parts{5}.fact-qnty) / {2}fact-qnty  else 0
        transport-base-loc{5}  = if {2}fact-qnty <> 0 then (accum total in-vatp-parts{5}.transport-base * in-vatp-parts{5}.fact-qnty) / {2}fact-qnty  else 0
        transport-rubl-loc{5}  = if {2}fact-qnty <> 0 then (accum total in-vatp-parts{5}.transport-rubl * in-vatp-parts{5}.fact-qnty) / {2}fact-qnty  else 0
        other-base-loc{5}      = if {2}fact-qnty <> 0 then (accum total in-vatp-parts{5}.other-base     * in-vatp-parts{5}.fact-qnty) / {2}fact-qnty  else 0
        other-rubl-loc{5}      = if {2}fact-qnty <> 0 then (accum total in-vatp-parts{5}.other-rubl     * in-vatp-parts{5}.fact-qnty) / {2}fact-qnty  else 0
        &scop pf in-vatp-parts{5}.
        &scop vr
        &scop sf
        &scop crc base
        vat-base-loc{5}        = if {2}fact-qnty <> 0 then (accum total {&summa-vat-parts}) / {2}fact-qnty   else 0
        slt-base-loc{5}        = if {2}fact-qnty <> 0 then (accum total {&summa-slt-parts}) / {2}fact-qnty   else 0
        &scop crc rubl
        vat-rubl-loc{5}        = if {2}fact-qnty <> 0 then (accum total {&summa-vat-parts}) / {2}fact-qnty   else 0
        slt-rubl-loc{5}        = if {2}fact-qnty <> 0 then (accum total {&summa-slt-parts}) / {2}fact-qnty   else 0
        vat-pc-loc{5}          = (accum total {&summa-vat-parts}) / (accum total {&accum-vat-parts})
        slt-pc-loc{5}          = (accum total {&summa-slt-parts}) / (accum total {&accum-slt-parts}).
      if road-tax-base-loc{5}  = ? then road-tax-base-loc{5}  = 0.
      if road-tax-rubl-loc{5}  = ? then road-tax-rubl-loc{5}  = 0.
      if transport-base-loc{5} = ? then transport-base-loc{5} = 0.
      if transport-rubl-loc{5} = ? then transport-rubl-loc{5} = 0.
      if other-base-loc{5}     = ? then other-base-loc{5}     = 0.
      if other-rubl-loc{5}     = ? then other-rubl-loc{5}     = 0.
      assign
        transport-cli-loc{5}      = 0
        other-cli-loc{5}          = 0
        road-tax-cli-loc{5}       = ?
        vat-cli-loc{5}            = ?
        slt-cli-loc{5}            = ?
        price-cli-with-tax-loc{5} = ?.
   end.
&ENDIF
ASSIGN
  &scop pf
  &scop vr {5}
  &scop sf -loc
  &scop crc base
  price-base-without-tax-loc{5} = price-base-with-tax-loc{5} - vat-base-loc{5} - slt-base-loc{5} - {&sm}
  &scop crc rubl
  price-rubl-without-tax-loc{5} = price-rubl-with-tax-loc{5} - vat-rubl-loc{5} - slt-rubl-loc{5} - {&sm}
.
&ENDIF

/* $Workfile$ e n d */