block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Библиотека процедур для работы со складскими документами

Автор: Чернова Светлана Александровна
Дата создания: 03/24/08
Author: Svetlana Chernova
Creation date: 03/24/08

Автор1: Суслов Алексей Юрьевич
Дата создания: 04/03/02

*/

using ibs.th.gbl.gbl-hndllib from propath.

define variable vss-revision    as character no-undo initial "$Revision$":U .
define variable vss-author      as character no-undo initial "$Author$":U .
define variable vss-date        as character no-undo initial "$Date$":U .
define variable vss-workfile    as character no-undo initial "$Workfile$":U .
define variable vss-archive     as character no-undo initial "$Archive$":U .
define variable vss-description as character no-undo initial "Библиотека процедур для работы со складскими документами":U.

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ str/lib-trn.i  }
{ str/lib-rvs.i  }
{ gbl/clntattr.i }
{ str/trdcalib.i }
{ cmp/strcodec.i }
{ str/lib-def.i  }
{ str/hvrdtax.i  }
{ str/lib-calc.i }
{ str/plgdsfnd.i no-interface }
{ str/cpprclig.i }
{ str/libtfarh.i }
{ trg/checkart.i }
{ str/valddnst.i def }
{ gbl/ptrlprop.i def }
{ ref/gds-attr.i }
{ gbl/objsrv.i }
  

define variable g-varr-b as character no-undo. /* читается из gbl/curr-r-b.i один раз на всю библиотеку */

if valid-handle (g#lib-trn)
and g#lib-trn <> this-procedure :handle
and g#lib-trn :get-signature('lib-trn_acc-cost':u) <> ""
then do:
  message
    vss-workfile vss-revision vss-description skip
    "Попытка повторной загрузки библиотеки для работы с документами" skip
    g#lib-trn skip
    g#lib-trn :type skip
    g#lib-trn :file-name skip
    valid-handle(g#lib-trn) skip
    this-procedure :handle skip
    this-procedure :type skip
    this-procedure :file-name skip
    valid-handle(this-procedure) skip
    view-as alert-box error .
  undo, return error .
end.
else do:
  assign
    g#lib-trn = this-procedure :handle
  .
  { gbl/curr-r-b.i
    g-varr-b
    no-error
  }
  if error-status :error then do:
    return error "Ошибка при определении валюты продажи.".
  end.
  def var gbl-hndllibObj as class gbl-hndllib no-undo.
  gbl-hndllibObj = new gbl-hndllib ().
  gbl-hndllibObj:InitHndl("g#lib-trn", g#lib-trn).
  delete object gbl-hndllibObj.
end.

on delete of this-procedure do:
  assign
    g#lib-trn = ?
  .
  def var gbl-hndllibObj as class gbl-hndllib no-undo.
  gbl-hndllibObj = new gbl-hndllib ().
  gbl-hndllibObj:InitHndl("g#lib-trn", g#lib-trn).
  delete object gbl-hndllibObj.
end.

define stream str-err.

/* Расчет суммы продажных цен по строке */
procedure lib-trn_acc-cost:
define input  parameter parobj-type                      like ub.doc-line.obj-type      no-undo.
define input  parameter parobj-code                      like ub.doc-line.obj-code      no-undo.
define input  parameter pardoc-code                      like ub.doc-line.doc-code      no-undo.
define input  parameter parartic                         like ub.doc-line.artic         no-undo.
define input  parameter parprod-type                     like ub.doc-line.prod-type     no-undo.
define input  parameter parprod-code                     like ub.doc-line.prod-code     no-undo.
define input  parameter parcli-qnty                      like ub.doc-line.cli-qnty      no-undo.
define input  parameter pardoc-qnty                      like ub.doc-line.doc-qnty      no-undo.
define input  parameter parfact-qnty                     like ub.doc-line.fact-qnty     no-undo.
define input  parameter parprice-base                    like ub.doc-line.price-base    no-undo.
define input  parameter parprice-rubl                    like ub.doc-line.price-rubl    no-undo.
define input  parameter parmode                          as   character                 no-undo.
define output parameter partotal-doc-line_tot-ov         like ub.trn-doc.tot-ov         no-undo.
define output parameter partotal-doc-line_fact-rubl      like ub.trn-doc.fact-rubl      no-undo.
define output parameter partotal-doc-line_fact-base      like ub.trn-doc.fact-base      no-undo.
define output parameter partotal-doc-line_fact-qnty      like ub.trn-doc.fact-qnty      no-undo.
define output parameter partotal-doc-line_doc-qnty       like ub.trn-doc.doc-qnty       no-undo.
define output parameter partotal-doc-line_cli-qnty       like ub.trn-doc.cli-qnty       no-undo.
define variable vartotal-parts_fact-base like ub.parts.price-base no-undo.
define variable vartotal-parts_fact-rubl like ub.parts.price-rubl no-undo.
define variable vartotal-parts_fact-qnty like ub.parts.fact-qnty  no-undo.
define variable rec-inv-lin              as   recid               no-undo.
define variable varfact-qnty-kg          as   decimal             no-undo.
define variable varis-petrolium as logical no-undo.
define variable varis-pieces    as logical no-undo.
define buffer inv-line-ch for ub.inv-line.
define buffer gds-dtl-ch  for ub.gds-dtl.
define buffer doc-line-ch for ub.doc-line.
define buffer parts-ch    for ub.parts.
define buffer trn-doc-ch  for ub.trn-doc.

do on error undo, return error return-value :
/* { gbl/curr-r-b.i varr-b } 12/II-2019 - вынесено в main-block */
  find first trn-doc-ch  where trn-doc-ch.doc-code = pardoc-code.
  if trn-doc-ch.doc-type <> {&inventory} then do:
    assign
      partotal-doc-line_fact-base = parfact-qnty * parprice-base
      partotal-doc-line_fact-rubl = parfact-qnty * parprice-rubl
    .
  end.
  else do:
    assign
      vartotal-parts_fact-base = 0
      vartotal-parts_fact-rubl = 0
      vartotal-parts_fact-qnty = 0
    .

    for each parts-ch
      where parts-ch.obj-type  = parobj-type
        and parts-ch.obj-code  = parobj-code
        and parts-ch.artic     = parartic
        and parts-ch.prod-type = parprod-type
        and parts-ch.prod-code = parprod-code
        and parts-ch.out-code  = pardoc-code
    :
      assign
        vartotal-parts_fact-base  = vartotal-parts_fact-base
                                    + parts-ch.fact-qnty * parts-ch.price-base
        vartotal-parts_fact-rubl  = vartotal-parts_fact-rubl
                                    + parts-ch.fact-qnty * parts-ch.price-rubl
        vartotal-parts_fact-qnty  = vartotal-parts_fact-qnty
                                    + parts-ch.fact-qnty
      .
    end.
    assign
      partotal-doc-line_fact-base = vartotal-parts_fact-base
      partotal-doc-line_fact-rubl = vartotal-parts_fact-rubl
    .
  end. /*инвентаризация*/

  assign
    partotal-doc-line_fact-qnty = parfact-qnty
    partotal-doc-line_doc-qnty  = pardoc-qnty
    partotal-doc-line_cli-qnty  = parcli-qnty
  .
  ASSIGN partotal-doc-line_tot-ov = 0.
  for each gds-dtl-ch where gds-dtl-ch.doc-code  = pardoc-code  and
                            gds-dtl-ch.artic     = parartic     and
                            gds-dtl-ch.prod-type = parprod-type and
                            gds-dtl-ch.prod-code = parprod-code no-lock :
     if g-varr-b = "rubl":U then do:
      assign
       partotal-doc-line_tot-ov = partotal-doc-line_tot-ov
                                + (gds-dtl-ch.cur-base - gds-dtl-ch.price-rubl) * gds-dtl-ch.fact-qnty.
    end.
    else do:
      assign
       partotal-doc-line_tot-ov = partotal-doc-line_tot-ov
                                + (gds-dtl-ch.cur-base - gds-dtl-ch.price-base) * gds-dtl-ch.fact-qnty.
    end.
  end.
  find first doc-line-ch no-lock where
             doc-line-ch.doc-code  = pardoc-code  and
             doc-line-ch.artic     = parartic     and
             doc-line-ch.prod-type = parprod-type and
             doc-line-ch.prod-code = parprod-code .
  { str/is-petrl.i
    doc-line-ch.artic
    doc-line-ch.prod-type
    doc-line-ch.prod-code
    varis-petrolium
    varis-pieces
    no-error
  }
  if varis-petrolium and
     not varis-pieces then do:
    find first inv-line-ch no-lock where
               inv-line-ch.doc-code  = pardoc-code  and
               inv-line-ch.artic     = parartic     and
               inv-line-ch.prod-type = parprod-type and
               inv-line-ch.prod-code = parprod-code no-error.
    if available inv-line-ch then do:
      assign
        varfact-qnty-kg = inv-line-ch.wast-cli-qnty.
    end.
    else do:
      assign
        varfact-qnty-kg = ?.
    end.
    { str/chkinvln.i pardoc-code
                 parartic
                 parprod-type
                 parprod-code
                 ?
                 ?
                 ?
                 ?
                 varfact-qnty-kg
                 doc-line-ch.fact-density
                 rec-inv-lin         no-error }
    if error-status :error then do:
      return error return-value.
    end.
  end.
end. /*do on error*/
end procedure.

/* Редактирование шапки накладной по учетным ценам */
procedure lib-trn_ass-cost:
define input parameter parrecid-doc              as recid                       no-undo.
define input parameter parinc_tot-ovnew          like ub.trn-doc.tot-ov         no-undo.
define input parameter parinc_fact-rublnew       like ub.trn-doc.fact-rubl      no-undo.
define input parameter parinc_fact-basenew       like ub.trn-doc.fact-base      no-undo.
define input parameter parinc_fact-qntynew       like ub.trn-doc.fact-qnty      no-undo.
define input parameter parinc_doc-qntynew        like ub.trn-doc.doc-qnty       no-undo.
define input parameter parinc_cli-qntynew        like ub.trn-doc.cli-qnty       no-undo.
define input parameter parinc_tot-ovold          like ub.trn-doc.tot-ov         no-undo.
define input parameter parinc_fact-rublold       like ub.trn-doc.fact-rubl      no-undo.
define input parameter parinc_fact-baseold       like ub.trn-doc.fact-base      no-undo.
define input parameter parinc_fact-qntyold       like ub.trn-doc.fact-qnty      no-undo.
define input parameter parinc_doc-qntyold        like ub.trn-doc.doc-qnty       no-undo.
define input parameter parinc_cli-qntyold        like ub.trn-doc.cli-qnty       no-undo.
define buffer ass_trn-doc for ub.trn-doc.
do on error undo, return error return-value :
  find first ass_trn-doc where recid(ass_trn-doc) = parrecid-doc.
  assign
    ass_trn-doc.fact-qnty = ass_trn-doc.fact-qnty + parinc_fact-qntynew - parinc_fact-qntyold
    ass_trn-doc.cli-qnty  = ass_trn-doc.cli-qnty  + parinc_cli-qntynew  - parinc_cli-qntyold
    ass_trn-doc.fact-base = ass_trn-doc.fact-base + parinc_fact-basenew - parinc_fact-baseold
    ass_trn-doc.fact-rubl = ass_trn-doc.fact-rubl + parinc_fact-rublnew - parinc_fact-rublold
    ass_trn-doc.tot-ov    = ass_trn-doc.tot-ov    + parinc_tot-ovnew    - parinc_tot-ovold.
  if ass_trn-doc.doc-type <> {&inventory} then do:
    assign
    ass_trn-doc.doc-qnty  = ass_trn-doc.doc-qnty  + parinc_doc-qntynew  - parinc_doc-qntyold.
  end.
end.
end procedure.

/* Пересчет шапки внешней приходной накладной */
procedure lib-trn_calc-in:
define input parameter parparentproc AS WIDGET-HANDLE NO-UNDO.
define input parameter parrec-doc as recid  no-undo.
define input parameter parhandle  as handle no-undo.
define variable varcount   as integer   no-undo.
define variable vartime    as integer   no-undo.
define variable varmessage as character no-undo.
define buffer   rc_trn-doc  for ub.trn-doc.
define buffer   d-l-b       for ub.doc-line.
do on error undo, return error return-value :
assign
  vartime = time.
find first rc_trn-doc where recid(rc_trn-doc) = parrec-doc.
assign
  rc_trn-doc.VAT-rubl   = 0
  rc_trn-doc.VAT-base   = 0
  rc_trn-doc.SLT-rubl   = 0
  rc_trn-doc.SLT-base   = 0
  rc_trn-doc.doc-qnty   = 0
  rc_trn-doc.fact-qnty  = 0
  rc_trn-doc.tot-calc   = 0
  rc_trn-doc.cli-qnty   = 0
  rc_trn-doc.tot-doc    = 0
  rc_trn-doc.tot-fact   = 0
  rc_trn-doc.tot-sale   = 0
  rc_trn-doc.tot-rubl   = 0
  rc_trn-doc.fact-base  = 0
  rc_trn-doc.fact-rubl  = 0
  rc_trn-doc.tot-lines  = 0
  rc_trn-doc.tot-ov     = 0
  rc_trn-doc.road-tax   = 0
  .
if rc_trn-doc.status_ = {&fact} then do:
  assign
    rc_trn-doc.tot-other  = 0
    rc_trn-doc.tot-transp = 0.
end.
assign
  varcount = 0.
for each d-l-b where d-l-b.doc-code = rc_trn-doc.doc-code on error undo, return error return-value :
  run waitfram-join in parhandle (substitute ("Пересчет шапки документа &1.", rc_trn-doc.doc-code),
                                  substitute ("Товар &1 &2 &3. ", d-l-b.artic, d-l-b.prod-type, d-l-b.prod-code),
                                  substitute (" Всего обработано строк: &1", varcount) +
                                  substitute (" Время: &1.", string(time - vartime, "hh:mm:ss")),
                                  output varmessage
                                  ) no-error.
  run waitfram-show in parhandle (varmessage) no-error.
  assign
    varcount = varcount + 1.
  { str/clcintrn.i
    parparentproc
    recid(d-l-b)
    d-l-b.doc-code
    d-l-b.artic
    d-l-b.prod-type
    d-l-b.prod-code
    0
    0
    0
    0
    0
    0
    0
    0
    0
    0
    0
    0
    0
    "'create':U"
    "'':U"
  }
end.
end.
end procedure.

/* Полный пересчет инвентаризации продажные + учетные цены */
procedure lib-trn_calc-inv:
define input parameter parrec-doc as recid  no-undo.
define input parameter parhandle  as handle no-undo.
define buffer fc_trn-doc  for ub.trn-doc.
define buffer fc_doc-line for ub.doc-line.
define variable vartot-doc        like ub.trn-doc.tot-doc  no-undo.
define variable vartot-rubl       like ub.trn-doc.tot-rubl no-undo.
define variable vartotal-tot-doc  like ub.trn-doc.tot-doc  no-undo.
define variable vartotal-tot-rubl like ub.trn-doc.tot-rubl no-undo.
define variable varcount   as integer   no-undo.
define variable vartime    as integer   no-undo.
define variable varmessage as character no-undo.
define variable vartotal-doc-qnty as decimal   no-undo .

do transaction on error undo, return error return-value :
/* { gbl/curr-r-b.i varr-b } 12/II-2019 - вынесено в main-block */
assign
  vartime  = time
  varcount = 0
  vartotal-doc-qnty = 0 .
find first fc_trn-doc where recid(fc_trn-doc) = parrec-doc.
for each fc_doc-line
  where fc_doc-line.doc-code = fc_trn-doc.doc-code
on error undo, return error
:
  run waitfram-join in parhandle (substitute ("Пересчет шапки документа &1.", fc_trn-doc.doc-code),
                                  substitute ("Товар &1 &2 &3. ", fc_doc-line.artic, fc_doc-line.prod-type, fc_doc-line.prod-code),
                                  substitute (" Всего обработано строк: &1", varcount) +
                                  substitute (" Время: &1.", string(time - vartime, "hh:mm:ss")),
                                  output varmessage
                                  ) no-error.
  run waitfram-show in parhandle (varmessage) no-error.
  assign
    varcount = varcount + 1.

  { str/clclninv.i
    recid(fc_doc-line)
    yes
    "'':U"
    vartot-doc
    vartot-rubl
    no-error
  }
  if error-status :error then do:
     return error return-value.
  end.
  assign
    vartotal-doc-qnty   =  vartotal-doc-qnty + fc_doc-line.doc-qnty - fc_doc-line.fact-qnty
    vartotal-tot-doc    =  vartotal-tot-doc  + vartot-doc
    vartotal-tot-rubl   =  vartotal-tot-rubl + vartot-rubl
  .
end. /*doc-line*/
fc_trn-doc.doc-qnty = vartotal-doc-qnty .
if g-varr-b = "rubl":u then do:
  assign
    fc_trn-doc.tot-rubl = vartotal-tot-rubl
    fc_trn-doc.tot-doc  = fc_trn-doc.tot-rubl / fc_trn-doc.base-rate * fc_trn-doc.base-scale
 .
end.
else do:
  assign
    fc_trn-doc.tot-doc  = vartotal-tot-doc
    fc_trn-doc.tot-rubl = fc_trn-doc.tot-doc * fc_trn-doc.base-rate / fc_trn-doc.base-scale
 .
end.
/* Пересчет по учетным ценам */
run str/calc-hd.p (INPUT fc_trn-doc.doc-code) no-error.
    if error-status :error then do:
      return error return-value.
    end.
end.
end procedure.

/*Расчет линии инвентаризации с возвратом параметров*/
procedure lib-trn_clclninv:
define input  parameter parrec-line            as   recid               no-undo.
define input  parameter parstate-price         as   logical             no-undo.
define input  parameter parmode                as   character           no-undo.
define output parameter partot-doc             like ub.trn-doc.tot-doc            no-undo.
define output parameter partot-rubl            like ub.trn-doc.tot-rubl           no-undo.
define buffer cdl_doc-line for ub.doc-line.
define buffer cdl_goods    for ub.goods.
define buffer cdl_inv-line for ub.inv-line.
define buffer cdl_gds-dtl  for ub.gds-dtl.
define buffer cdl_trn-doc  for ub.trn-doc.
define variable varsum-sale like ub.gds-dtl.price-rubl no-undo.
define variable rec-inv-lin as   recid                 no-undo.
define variable varis-petrolium as logical no-undo.
define variable varis-pieces    as logical no-undo.

{ str/get-pr.i def }
do on error undo, return error return-value :
/* { gbl/curr-r-b.i varr-b } 12/II-2019 - вынесено в main-block */
find first cdl_doc-line where recid(cdl_doc-line)  = parrec-line.
find first cdl_inv-line
  where cdl_inv-line.doc-code  = cdl_doc-line.doc-code
    and cdl_inv-line.artic     = cdl_doc-line.artic
    and cdl_inv-line.prod-type = cdl_doc-line.prod-type
    and cdl_inv-line.prod-code = cdl_doc-line.prod-code
  no-error.
find first cdl_trn-doc  where cdl_trn-doc.doc-code = cdl_doc-line.doc-code no-error.
if not available cdl_trn-doc then do:
  return error substitute ("Не найден документ с номером &1.", cdl_doc-line.doc-code).
end.
find first cdl_goods where cdl_goods.artic     = cdl_doc-line.artic and
                           cdl_goods.prod-type = cdl_doc-line.prod-type and
                           cdl_goods.prod-code = cdl_doc-line.prod-code no-lock.

for each cdl_gds-dtl where cdl_gds-dtl.doc-code  = cdl_doc-line.doc-code
                       and cdl_gds-dtl.prod-code = cdl_doc-line.prod-code
                       and cdl_gds-dtl.prod-type = cdl_doc-line.prod-type
                       and cdl_gds-dtl.artic     = cdl_doc-line.artic on error undo, return error :
   /* в признаки пишем продажную цену на момент закрытия инвентаризации */
   if parstate-price then do:
     { str/get-pr.i calc cdl_gds-dtl.obj-type cdl_gds-dtl.obj-code cdl_goods.gds-code cdl_gds-dtl.prt-code " " cdl_trn-doc.fact-order }
     if gp-price-sale <> ? then do:
       if g-varr-b = "rubl":u then do:
         assign
           cdl_doc-line.excise      = gp-excise
           cdl_doc-line.road-tax    = gp-road-tax
           cdl_gds-dtl.price-rubl   = gp-price-sale-parts.
       end.
       else do:
         assign
           cdl_doc-line.excise      = gp-excise
           cdl_doc-line.road-tax    = gp-road-tax
           cdl_gds-dtl.price-base   = gp-price-sale-parts.
       end.
     end.
     else do:
       if g-varr-b = "rubl":u then do:
         assign
           cdl_gds-dtl.price-rubl = 0.
       end.
       else do:
         assign
           cdl_gds-dtl.price-base = 0.
       end.
     end.
    if g-varr-b = "base":u then do:
      assign
        cdl_gds-dtl.price-rubl = cdl_gds-dtl.price-base * cdl_trn-doc.base-rate / cdl_trn-doc.base-scale.
    end.
    else do:
      assign
        cdl_gds-dtl.price-base = cdl_gds-dtl.price-rubl / cdl_trn-doc.base-rate * cdl_trn-doc.base-scale.
    end.
   end.
   if g-varr-b = "base":u then do:
     assign varsum-sale = varsum-sale + cdl_gds-dtl.price-base * cdl_gds-dtl.doc-qnty.
   end.
   else do:
     assign varsum-sale = varsum-sale + cdl_gds-dtl.price-rubl * cdl_gds-dtl.doc-qnty.
   end.
end. /*gds-dtl*/

  if g-varr-b = "base":u then do:
    assign
      partot-doc   = varsum-sale
      partot-rubl  = partot-doc * cdl_trn-doc.base-rate / cdl_trn-doc.base-scale
    .
  end.
  else do:
    assign
      partot-rubl  = varsum-sale
      partot-doc   = partot-rubl / cdl_trn-doc.base-rate * cdl_trn-doc.base-scale
   .
  end.
  .
  { str/is-petrl.i
    cdl_doc-line.artic
    cdl_doc-line.prod-type
    cdl_doc-line.prod-code
    varis-petrolium
    varis-pieces
    no-error
  }
  if varis-petrolium
    and not varis-pieces
  then do:
    { str/chkinvln.i
      cdl_trn-doc.doc-code
      cdl_doc-line.artic
      cdl_doc-line.prod-type
      cdl_doc-line.prod-code
      ?
      ?
      ?
      ?
      "(if available cdl_inv-line then cdl_inv-line.wast-cli-qnty else ?)"
      cdl_doc-line.doc-density
      rec-inv-lin
      no-error
    }
    if error-status :error then do:
      return error return-value.
    end.
  end.
end.

end procedure.

/* ============================================================================
Проверка на установку налога с продаж
========================================================================== */
procedure lib-trn_chpsltpc :
define input  parameter parinternal     like ub.trn-doc.internal     no-undo.
define input  parameter pardoc-type     like ub.trn-doc.doc-type     no-undo.
define input  parameter parpay-code     like ub.trn-doc.pay-code     no-undo.
define input  parameter parcash-pay     as   integer                 no-undo.
define input  parameter parslt-type     like ub.parts.slt-type       no-undo.
define input  parameter parext-doc-type like ub.trn-doc.ext-doc-type no-undo.
define output parameter parslt-yes      as   logical                 no-undo.
if not parinternal
   and (    ( parpay-code = parcash-pay and can-do ({&expense_return}, pardoc-type) )
         or ( pardoc-type = {&income}   and parslt-type <> {&without-slt}           )
         or parext-doc-type = {&TDEDT_Corr_Acc_Price}
       )
then do:
  assign
    parslt-yes = yes.
end.
else do:
  assign
    parslt-yes = no.
end.
end procedure.

/* ============================================================================
Установка налога с продаж
========================================================================== */
procedure lib-trn_st-sltpc :
do
on error undo, return error
:
def input  parameter p-goods-recid    as recid                    no-undo.
def input  parameter p-trn-doc-recid  as recid                    no-undo.
def input  parameter p-cash-pay       as integer                  no-undo.
def output parameter p-st-sltpc-slt   like ub.doc-line.SLT-pc     no-undo.

def var v-host-code     like ub.sysconf.host-code  no-undo.
define variable varslt-yes as logical no-undo.
def buffer buf_st-sltpc_goods   for ub.goods.
def buffer buf_st-sltpc_trn-doc for ub.trn-doc.

find first buf_st-sltpc_goods   where recid(buf_st-sltpc_goods)     = p-goods-recid.
find first buf_st-sltpc_trn-doc where recid(buf_st-sltpc_trn-doc)   = p-trn-doc-recid.

{ str/chpsltpc.i
  buf_st-sltpc_trn-doc.internal
  buf_st-sltpc_trn-doc.doc-type
  buf_st-sltpc_trn-doc.pay-code
  p-cash-pay
  buf_st-sltpc_trn-doc.slt-type
  buf_st-sltpc_trn-doc.ext-doc-type
  varslt-yes
  no-error
}
if error-status :error then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка при проверке установки налога с продаж " skip
    " для товара " buf_st-sltpc_goods.artic buf_st-sltpc_goods.prod-type buf_st-sltpc_goods.prod-code skip
    " в документе " buf_st-sltpc_trn-doc.doc-code skip
    return-value skip
    trim(error-status :get-message(1))
    trim(error-status :get-message(2))
    trim(error-status :get-message(3))
    trim(error-status :get-message(4))
    trim(error-status :get-message(5)) skip
    view-as alert-box error.
  undo, return error .
end.
if varslt-yes
then do:
    { gbl/hostcode.i    buf_st-sltpc_trn-doc.obj-type
                    buf_st-sltpc_trn-doc.obj-code
                    v-host-code
    }
    { gbl/pftxvalg.i    buf_st-sltpc_goods.gds-code
                    {&slt-tax-code}
                    ?
                    v-host-code
                    buf_st-sltpc_trn-doc.obj-type
                    buf_st-sltpc_trn-doc.obj-code
                    p-st-sltpc-slt
                    no-error
    }
end.
else do:
    assign
        p-st-sltpc-slt      = 0
    .
end.

end.
end procedure. /* st-sltpc */

/* Перерасчет всех документов кроме внешего прихода и инвентаризации */
procedure lib-trn_calc-out :
/* ------------------------------------------------------------------------------------------------------------------------------------------
  Purpose:  расчет скидок по документу и обновление цен
            вызывается из UI-on (o u t - d o c . w)
            b-close (t r n - c l o s . i)
Типы скидок по документу :

trn-doc.discnt-type | gds-dtl.discnt-type
                    |
сумма               | безразлично           - скидки по строкам считаются от общей скидки по док-ту
процент             | безразлично           - скидки по строкам считаются от общего % скидки по док-ту
карта               | безразлично           - скидки по строкам считаются от общего % скидки по док-ту
группа              | безразлично           - скидки по строкам считаются от общего % скидки по док-ту
строка              | no                    - скидка по док-ту считается от скидок по строкам
строка              | yes                   - скидка по док-ту считается от % по строкам

При возврате поставщику цены документа и сумма к оплате считается от партий
-------------------------------------------------------------------------------------------------------------------------------------------- */
define input parameter parrec-doc      as recid  no-undo.
define input parameter parrecalc-price as logical no-undo.
define input parameter parhandle       as handle  no-undo.
define buffer cd_trn-doc  for ub.trn-doc.
define buffer cd_sysconf  for ub.sysconf.
define buffer cd_doc-line for ub.doc-line.
define buffer cd_goods    for ub.goods.
define buffer p-doc-line  for ub.doc-line.
define buffer p-goods     for ub.goods.
define variable is-petrolium-out-body                     as logical                 no-undo.
define variable is-pieces-out-body                        as logical                 no-undo.
define variable varagsum-base-doc                         like ub.gds-dtl.price-base no-undo.
define variable varagsum-rubl-doc                         like ub.gds-dtl.price-rubl no-undo.
define variable varagsum-base-fact                        like ub.gds-dtl.price-base no-undo.
define variable varagsum-rubl-fact                        like ub.gds-dtl.price-rubl no-undo.
define variable varagcount                                as integer                 no-undo.
define variable vartotal-agsum-base-doc                   like ub.gds-dtl.price-base no-undo.
define variable vartotal-agsum-rubl-doc                   like ub.gds-dtl.price-rubl no-undo.
define variable vartotal-agsum-base-fact                  like ub.gds-dtl.price-base no-undo.
define variable vartotal-agsum-rubl-fact                  like ub.gds-dtl.price-rubl no-undo.
define variable vartotal-agcount                          as integer                 no-undo.
define variable varroad-tax-fact-base                     like ub.gds-dtl.price-base no-undo.
define variable varexcise-fact-base                       like ub.gds-dtl.price-base no-undo.
define variable varslt-fact-base                          like ub.gds-dtl.price-base no-undo.
define variable varvat-fact-base                          like ub.gds-dtl.price-base no-undo.
define variable varslt-doc-base                           like ub.gds-dtl.price-base no-undo.
define variable varvat-doc-base                           like ub.gds-dtl.price-base no-undo.
define variable varsum-fact-out-dsv-base                  like ub.gds-dtl.price-base no-undo.
define variable varroad-tax-fact-rubl                     like ub.gds-dtl.price-base no-undo.
define variable varexcise-fact-rubl                       like ub.gds-dtl.price-base no-undo.
define variable varslt-fact-rubl                          like ub.gds-dtl.price-base no-undo.
define variable varvat-fact-rubl                          like ub.gds-dtl.price-base no-undo.
define variable varslt-doc-rubl                           like ub.gds-dtl.price-base no-undo.
define variable varvat-doc-rubl                           like ub.gds-dtl.price-base no-undo.
define variable varsum-fact-out-dsv-rubl                  like ub.gds-dtl.price-base no-undo.
define variable varsum-fact-out-dsc-base                  like ub.gds-dtl.price-base no-undo.
define variable varsum-fact-out-dsc-rubl                  like ub.gds-dtl.price-base no-undo.
define variable varsum-fact-cur                           like ub.gds-dtl.price-base no-undo.
define variable varov-fact-base                           like ub.gds-dtl.price-base no-undo.
define variable varov-vat-fact-base                       like ub.gds-dtl.price-base no-undo.
define variable varsum-doc-cur                            like ub.gds-dtl.price-base no-undo.
define variable varov-doc-base                            like ub.gds-dtl.price-base no-undo.
define variable varov-vat-doc-base                        like ub.gds-dtl.price-base no-undo.
define variable varsum-doc-base                           like ub.gds-dtl.price-base no-undo.
define variable varsum-doc-rubl                           like ub.gds-dtl.price-base no-undo.
define variable varroad-tax-fact                          like ub.gds-dtl.price-base no-undo.
define variable varexcise-fact                            like ub.gds-dtl.price-base no-undo.
define variable varroad-tax-doc                           like ub.gds-dtl.price-base no-undo.
define variable varexcise-doc                             like ub.gds-dtl.price-base no-undo.
define variable vardiscnt-base-doc                        like ub.gds-dtl.price-base no-undo.
define variable vardiscnt-rubl-doc                        like ub.gds-dtl.price-base no-undo.
define variable vardiscnt-base-fact                       like ub.gds-dtl.price-base no-undo.
define variable vardiscnt-rubl-fact                       like ub.gds-dtl.price-base no-undo.
define variable vartotal-road-tax-fact-base               like ub.gds-dtl.price-base no-undo.
define variable vartotal-excise-fact-base                 like ub.gds-dtl.price-base no-undo.
define variable vartotal-slt-fact-base                    like ub.gds-dtl.price-base no-undo.
define variable vartotal-vat-fact-base                    like ub.gds-dtl.price-base no-undo.
define variable vartotal-slt-doc-base                     like ub.gds-dtl.price-base no-undo.
define variable vartotal-vat-doc-base                     like ub.gds-dtl.price-base no-undo.
define variable vartotal-sum-fact-out-dsv-base            like ub.gds-dtl.price-base no-undo.
define variable vartotal-road-tax-fact-rubl               like ub.gds-dtl.price-base no-undo.
define variable vartotal-excise-fact-rubl                 like ub.gds-dtl.price-base no-undo.
define variable vartotal-slt-fact-rubl                    like ub.gds-dtl.price-base no-undo.
define variable vartotal-vat-fact-rubl                    like ub.gds-dtl.price-base no-undo.
define variable vartotal-slt-doc-rubl                     like ub.gds-dtl.price-base no-undo.
define variable vartotal-vat-doc-rubl                     like ub.gds-dtl.price-base no-undo.
define variable vartotal-sum-fact-out-dsv-rubl            like ub.gds-dtl.price-base no-undo.
define variable vartotal-sum-fact-out-dsc-base            like ub.gds-dtl.price-base no-undo.
define variable vartotal-sum-fact-out-dsc-rubl            like ub.gds-dtl.price-base no-undo.
define variable vartotal-sum-fact-cur                     like ub.gds-dtl.price-base no-undo.
define variable vartotal-ov-fact-base                     like ub.gds-dtl.price-base no-undo.
define variable vartotal-ov-vat-fact-base                 like ub.gds-dtl.price-base no-undo.
define variable vartotal-sum-doc-cur                      like ub.gds-dtl.price-base no-undo.
define variable vartotal-ov-doc-base                      like ub.gds-dtl.price-base no-undo.
define variable vartotal-ov-vat-doc-base                  like ub.gds-dtl.price-base no-undo.
define variable vartotal-sum-doc-base                     like ub.gds-dtl.price-base no-undo.
define variable vartotal-sum-doc-rubl                     like ub.gds-dtl.price-base no-undo.
define variable vartotal-road-tax-fact                    like ub.gds-dtl.price-base no-undo.
define variable vartotal-excise-fact                      like ub.gds-dtl.price-base no-undo.
define variable vartotal-road-tax-doc                     like ub.gds-dtl.price-base no-undo.
define variable vartotal-excise-doc                       like ub.gds-dtl.price-base no-undo.
define variable vartotal-discnt-base-doc                  like ub.gds-dtl.price-base no-undo.
define variable vartotal-discnt-rubl-doc                  like ub.gds-dtl.price-base no-undo.
define variable vartotal-discnt-base-fact                 like ub.gds-dtl.price-base no-undo.
define variable vartotal-discnt-rubl-fact                 like ub.gds-dtl.price-base no-undo.
define variable vartime                                   as   integer               no-undo.
define variable varcount                                  as   integer               no-undo.
define variable varmessage                                as   character             no-undo.


do on error undo, return error return-value :
assign vartime = time.
find first cd_trn-doc where recid(cd_trn-doc) = parrec-doc.
assign
cd_trn-doc.doc-qnty    = 0
cd_trn-doc.tot-doc     = 0
cd_trn-doc.tot-rubl    = 0
cd_trn-doc.fact-qnty   = 0
cd_trn-doc.tot-fact    = 0
cd_trn-doc.tot-sale    = 0
cd_trn-doc.tot-lines   = 0
cd_trn-doc.tot-cli     = 0
cd_trn-doc.road-tax    = 0
cd_trn-doc.excise      = 0
cd_trn-doc.slt-base    = 0
cd_trn-doc.vat-base    = 0
cd_trn-doc.slt-rubl    = 0
cd_trn-doc.vat-rubl    = 0.
find cd_sysconf where cd_sysconf.host-code = cd_trn-doc.host-code no-lock.
/* 1 проход - простановка цен, вычисление сумм по документу */
assign varcount = 0.
for each cd_doc-line where cd_doc-line.doc-code = cd_trn-doc.doc-code exclusive:
    find cd_goods where cd_doc-line.prod-code = cd_goods.prod-code
                    and cd_doc-line.prod-type = cd_goods.prod-type
                    and cd_doc-line.artic     = cd_goods.artic no-lock.
  run waitfram-join in parhandle (substitute ("Устанавливаем продажные цены в строках документа &1.", cd_trn-doc.doc-code),
                                  substitute ("Товар &1 &2 &3. ", cd_doc-line.artic, cd_doc-line.prod-type, cd_doc-line.prod-code),
                                  substitute (" Всего обработано строк: &1", varcount) +
                                  substitute (" Время: &1.", string(time - vartime, "hh:mm:ss")),
                                  output varmessage
                                  ) no-error.
  run waitfram-show in parhandle (varmessage) no-error.
  assign
    varcount = varcount + 1.

   { str/accgdspr.i
     recid(cd_doc-line)
     "(if parrecalc-price = yes then yes else no)"
     varagsum-base-doc
     varagsum-rubl-doc
     varagsum-base-fact
     varagsum-rubl-fact
     varagcount }
   if (varagcount) = 0 then delete cd_doc-line.
   assign
   vartotal-agsum-base-doc    = vartotal-agsum-base-doc   + varagsum-base-doc
   vartotal-agsum-rubl-doc    = vartotal-agsum-rubl-doc   + varagsum-rubl-doc
   vartotal-agsum-base-fact   = vartotal-agsum-base-fact  + varagsum-base-fact
   vartotal-agsum-rubl-fact   = vartotal-agsum-rubl-fact  + varagsum-rubl-fact
   vartotal-agcount           = vartotal-agcount          + varagcount       .
END.
/*Пересчет шапки накладной*/
{ str/clcdocpr.i
  recid(cd_trn-doc)
  vartotal-agsum-base-doc
  vartotal-agsum-rubl-doc
  vartotal-agsum-base-fact
  vartotal-agsum-rubl-fact
  vartotal-agcount
  0
  0
  0
  0
  0
  no-error
}
if error-status :error then do:
  return error return-value.
end.
assign varcount = 0.
/* 2 проход - вычисление или распространение скидок */
for each cd_doc-line where cd_doc-line.doc-code = cd_trn-doc.doc-code on error undo, return error :
  run waitfram-join in parhandle (substitute ("Вычисление и распространение скидок &1.", cd_trn-doc.doc-code),
                                  substitute ("Товар &1 &2 &3. ", cd_doc-line.artic, cd_doc-line.prod-type, cd_doc-line.prod-code),
                                  substitute (" Всего обработано строк: &1", varcount) +
                                  substitute (" Время: &1.", string(time - vartime, "hh:mm:ss")),
                                  output varmessage
                                  ) no-error.
  run waitfram-show in parhandle (varmessage) no-error.
  assign
    varcount = varcount + 1.
   { str/reclcdsc.i recid(cd_doc-line) no-error }
   if error-status :error then do:
      return error return-value.
   end.
end.

if cd_trn-doc.discnt-type <> {&amount} then do:
    assign
      cd_trn-doc.tot-calc    = 0
      cd_trn-doc.discnt-rubl = 0
      .
end.

/* 3 проход - вычисление НДС */
assign varcount = 0.
for each cd_doc-line where cd_doc-line.doc-code = cd_trn-doc.doc-code:
  run waitfram-join in parhandle (substitute ("Вычисление НДС &1.", cd_trn-doc.doc-code),
                                  substitute ("Товар &1 &2 &3. ", cd_doc-line.artic, cd_doc-line.prod-type, cd_doc-line.prod-code),
                                  substitute (" Всего обработано строк: &1", varcount) +
                                  substitute (" Время: &1.", string(time - vartime, "hh:mm:ss")),
                                  output varmessage
                                  ) no-error.
  run waitfram-show in parhandle (varmessage) no-error.
  assign
    varcount = varcount + 1.

  /*-------------------------------------------------------------------------------------
    Подсчет налогов и НДС по накладной
   -------------------------------------------------------------------------------------*/
   { str/acsupacc.i
   recid(cd_doc-line)
   varroad-tax-fact-base
   varexcise-fact-base
   varslt-fact-base
   varvat-fact-base
   varslt-doc-base
   varvat-doc-base
   varsum-fact-out-dsv-base
   varroad-tax-fact-rubl
   varexcise-fact-rubl
   varslt-fact-rubl
   varvat-fact-rubl
   varslt-doc-rubl
   varvat-doc-rubl
   varsum-fact-out-dsv-rubl
   varsum-fact-out-dsc-base
   varsum-fact-out-dsc-rubl
   varsum-fact-cur
   varov-fact-base
   varov-vat-fact-base
   varsum-doc-cur
   varov-doc-base
   varov-vat-doc-base
   varsum-doc-base
   varsum-doc-rubl
   varroad-tax-fact
   varexcise-fact
   varroad-tax-doc
   varexcise-doc
   vardiscnt-base-doc
   vardiscnt-rubl-doc
   vardiscnt-base-fact
   vardiscnt-rubl-fact
   no-error }
 if error-status :error then do:
   return error return-value.
 end.
 assign
   vartotal-road-tax-fact-base              = vartotal-road-tax-fact-base               + varroad-tax-fact-base
   vartotal-excise-fact-base                = vartotal-excise-fact-base                 + varexcise-fact-base
   vartotal-slt-fact-base                   = vartotal-slt-fact-base                    + varslt-fact-base
   vartotal-vat-fact-base                   = vartotal-vat-fact-base                    + varvat-fact-base
   vartotal-slt-doc-base                    = vartotal-slt-doc-base                     + varslt-doc-base
   vartotal-vat-doc-base                    = vartotal-vat-doc-base                     + varvat-doc-base
   vartotal-sum-fact-out-dsv-base           = vartotal-sum-fact-out-dsv-base            + varsum-fact-out-dsv-base
   vartotal-road-tax-fact-rubl              = vartotal-road-tax-fact-rubl               + varroad-tax-fact-rubl
   vartotal-excise-fact-rubl                = vartotal-excise-fact-rubl                 + varexcise-fact-rubl
   vartotal-slt-fact-rubl                   = vartotal-slt-fact-rubl                    + varslt-fact-rubl
   vartotal-vat-fact-rubl                   = vartotal-vat-fact-rubl                    + varvat-fact-rubl
   vartotal-slt-doc-rubl                    = vartotal-slt-doc-rubl                     + varslt-doc-rubl
   vartotal-vat-doc-rubl                    = vartotal-vat-doc-rubl                     + varvat-doc-rubl
   vartotal-sum-fact-out-dsv-rubl           = vartotal-sum-fact-out-dsv-rubl            + varsum-fact-out-dsv-rubl
   vartotal-sum-fact-out-dsc-base           = vartotal-sum-fact-out-dsc-base            + varsum-fact-out-dsc-base
   vartotal-sum-fact-out-dsc-rubl           = vartotal-sum-fact-out-dsc-rubl            + varsum-fact-out-dsc-rubl
   vartotal-sum-fact-cur                    = vartotal-sum-fact-cur                     + varsum-fact-cur
   vartotal-ov-fact-base                    = vartotal-ov-fact-base                     + varov-fact-base
   vartotal-ov-vat-fact-base                = vartotal-ov-vat-fact-base                 + varov-vat-fact-base
   vartotal-sum-doc-cur                     = vartotal-sum-doc-cur                      + varsum-doc-cur
   vartotal-ov-doc-base                     = vartotal-ov-doc-base                      + varov-doc-base
   vartotal-ov-vat-doc-base                 = vartotal-ov-vat-doc-base                  + varov-vat-doc-base
   vartotal-sum-doc-base                    = vartotal-sum-doc-base                     + varsum-doc-base
   vartotal-sum-doc-rubl                    = vartotal-sum-doc-rubl                     + varsum-doc-rubl
   vartotal-road-tax-fact                   = vartotal-road-tax-fact                    + varroad-tax-fact
   vartotal-excise-fact                     = vartotal-excise-fact                      + varexcise-fact
   vartotal-road-tax-doc                    = vartotal-road-tax-doc                     + varroad-tax-doc
   vartotal-excise-doc                      = vartotal-excise-doc                       + varexcise-doc
   vartotal-discnt-base-doc                 = vartotal-discnt-base-doc                  + vardiscnt-base-doc
   vartotal-discnt-rubl-doc                 = vartotal-discnt-rubl-doc                  + vardiscnt-rubl-doc
   vartotal-discnt-base-fact                = vartotal-discnt-base-fact                 + vardiscnt-base-fact
   vartotal-discnt-rubl-fact                = vartotal-discnt-rubl-fact                 + vardiscnt-rubl-fact              .
end.
/*Окончательный пересчет шапки накладной после пересчета скидок, налога и НДС*/
{ str/clcpttrn.i
  recid(cd_trn-doc)
  vartotal-discnt-base-fact
  vartotal-discnt-rubl-fact
  vartotal-road-tax-fact
  vartotal-excise-fact
  vartotal-slt-fact-base
  vartotal-vat-fact-base
  vartotal-slt-fact-rubl
  vartotal-vat-fact-rubl
  0
  0
  0
  0
  0
  0
  0
  0
  no-error
}
run str/calc-hd.p (cd_trn-doc.doc-code) no-error.
if error-status :error then do:
   return error return-value.
end.
end.
end procedure.

/* -------------------------------------------------------------------
  Пересчет части шапки расходной накладной
-------------------------------------------------------------------- */
procedure lib-trn_clcdocpr :
define input parameter parrec-doc               as recid                   no-undo.
define input parameter parargsum-base-doc-new   like ub.gds-dtl.price-base no-undo.
define input parameter parargsum-rubl-doc-new   like ub.gds-dtl.price-rubl no-undo.
define input parameter parargsum-base-fact-new  like ub.gds-dtl.price-base no-undo.
define input parameter parargsum-rubl-fact-new  like ub.gds-dtl.price-rubl no-undo.
define input parameter parargcount-new          as integer                 no-undo.
define input parameter parargsum-base-doc-old   like ub.gds-dtl.price-base no-undo.
define input parameter parargsum-rubl-doc-old   like ub.gds-dtl.price-rubl no-undo.
define input parameter parargsum-base-fact-old  like ub.gds-dtl.price-base no-undo.
define input parameter parargsum-rubl-fact-old  like ub.gds-dtl.price-rubl no-undo.
define input parameter parargcount-old          as integer                 no-undo.
define buffer ct_trn-doc for ub.trn-doc.
do on error undo, return error return-value :
find first ct_trn-doc where recid(ct_trn-doc) = parrec-doc.
assign
    ct_trn-doc.tot-doc   = ct_trn-doc.tot-doc   + parargsum-base-doc-new   - parargsum-base-doc-old
    ct_trn-doc.tot-rubl  = ct_trn-doc.tot-rubl  + parargsum-rubl-doc-new   - parargsum-rubl-doc-old
    ct_trn-doc.tot-fact  = ct_trn-doc.tot-fact  + parargsum-base-fact-new  - parargsum-base-fact-old
    ct_trn-doc.tot-sale  = ct_trn-doc.tot-sale  + parargsum-rubl-fact-new  - parargsum-rubl-fact-old
    ct_trn-doc.tot-lines = ct_trn-doc.tot-lines + parargcount-new          - parargcount-old
    .
/* Корректировка скидок по накладной */
/* если тип скидки неизвестен (это мб при копировании из др. док-та), считаем скидку = 0 */
if not can-do ({&d-type-list}, ct_trn-doc.discnt-type) and
   ct_trn-doc.discnt-type <> {&cash-desk}              and
   ct_trn-doc.discnt-type <> {&manufactured}           and
   ct_trn-doc.internal    =  no                        then
  assign
    ct_trn-doc.discnt-type = {&percent}
    ct_trn-doc.discnt-pc = 0.
/*Корректировка скидки в шапке накладной*/
if ct_trn-doc.discnt-type = {&amount} then do:
  if ct_trn-doc.print-rubl then do:
    assign
      ct_trn-doc.discnt-pc = ct_trn-doc.discnt-rubl * 100 / ct_trn-doc.tot-rubl
      ct_trn-doc.tot-calc  = ct_trn-doc.discnt-rubl * ct_trn-doc.base-scale / ct_trn-doc.base-rate.
  end.
  else do:
    assign
      ct_trn-doc.discnt-pc   = ct_trn-doc.tot-calc * 100 / ct_trn-doc.tot-doc
      ct_trn-doc.discnt-rubl = ct_trn-doc.tot-calc * ct_trn-doc.base-rate / ct_trn-doc.base-scale.
  end.
if ct_trn-doc.discnt-pc = ? then do:
  assign
    ct_trn-doc.discnt-pc = 0.
end.
end.
end.
end procedure.

/* -------------------------------------------------------------------------------------
Description:  Заключительный пересчет шапки накладной
------------------------------------------------------------------------------------- */
procedure lib-trn_clcpttrn:
define input parameter parrec-doc                 as   recid               no-undo.
define input parameter pardiscnt-base-fact-new  like ub.trn-doc.tot-calc no-undo.
define input parameter pardiscnt-rubl-fact-new  like ub.trn-doc.tot-calc no-undo.
define input parameter parroad-tax-fact-new     like ub.trn-doc.tot-calc no-undo.
define input parameter parexcise-fact-new       like ub.trn-doc.tot-calc no-undo.
define input parameter parslt-fact-base-new     like ub.trn-doc.tot-calc no-undo.
define input parameter parvat-fact-base-new     like ub.trn-doc.tot-calc no-undo.
define input parameter parslt-fact-rubl-new     like ub.trn-doc.tot-calc no-undo.
define input parameter parvat-fact-rubl-new     like ub.trn-doc.tot-calc no-undo.
define input parameter pardiscnt-base-fact-old  like ub.trn-doc.tot-calc no-undo.
define input parameter pardiscnt-rubl-fact-old  like ub.trn-doc.tot-calc no-undo.
define input parameter parroad-tax-fact-old     like ub.trn-doc.tot-calc no-undo.
define input parameter parexcise-fact-old       like ub.trn-doc.tot-calc no-undo.
define input parameter parslt-fact-base-old     like ub.trn-doc.tot-calc no-undo.
define input parameter parvat-fact-base-old     like ub.trn-doc.tot-calc no-undo.
define input parameter parslt-fact-rubl-old     like ub.trn-doc.tot-calc no-undo.
define input parameter parvat-fact-rubl-old     like ub.trn-doc.tot-calc no-undo.
define buffer ct_trn-doc for ub.trn-doc.
do on error undo, return error return-value :
find first ct_trn-doc where recid(ct_trn-doc) = parrec-doc.
if ct_trn-doc.discnt-type <> {&amount} then do:
    assign
      ct_trn-doc.tot-calc    = ct_trn-doc.tot-calc    + pardiscnt-base-fact-new - pardiscnt-base-fact-old
      ct_trn-doc.discnt-rubl = ct_trn-doc.discnt-rubl + pardiscnt-rubl-fact-new - pardiscnt-rubl-fact-old .
end.
if not can-do ({&d-type-pc}, ct_trn-doc.discnt-type) then do:
  assign
    ct_trn-doc.discnt-pc   = ( if ct_trn-doc.print-rubl then ( if ct_trn-doc.tot-sale = 0 then 0 else ct_trn-doc.discnt-rubl * 100 / ct_trn-doc.tot-sale )
                                                        else ( if ct_trn-doc.tot-fact = 0 then 0 else ct_trn-doc.tot-calc    * 100 / ct_trn-doc.tot-fact ) ).
  if ct_trn-doc.discnt-pc = ? then do:
    assign
      ct_trn-doc.discnt-pc = 0.
  end.
end.
assign ct_trn-doc.tot-cli = ct_trn-doc.tot-doc - ct_trn-doc.tot-calc.
ASSIGN
   ct_trn-doc.road-tax = ct_trn-doc.road-tax + parroad-tax-fact-new - parroad-tax-fact-old
   ct_trn-doc.excise   = ct_trn-doc.excise   + parexcise-fact-new   - parexcise-fact-old
   ct_trn-doc.slt-base = ct_trn-doc.slt-base + parslt-fact-base-new - parslt-fact-base-old
   ct_trn-doc.vat-base = ct_trn-doc.vat-base + parvat-fact-base-new - parvat-fact-base-old
   ct_trn-doc.slt-rubl = ct_trn-doc.slt-rubl + parslt-fact-rubl-new - parslt-fact-rubl-old
   ct_trn-doc.vat-rubl = ct_trn-doc.vat-rubl + parvat-fact-rubl-new - parvat-fact-rubl-old
   .
END.
end procedure.

/* Проставка цен и НДС из линий в gds-dtl и parts во внешней приходной накладной */
procedure lib-trn_fill-ext-inc:
define input parameter parparentproc    AS WIDGET-HANDLE               NO-UNDO.
define input parameter pardoc-code      like ub.trn-doc.doc-code       no-undo.
define input parameter parartic         like ub.doc-line.artic         no-undo.
define input parameter parprod-type     like ub.doc-line.prod-type     no-undo.
define input parameter parprod-code     like ub.doc-line.prod-code     no-undo.
define input parameter parprice-base    like ub.doc-line.price-base    no-undo.
define input parameter parprice-rubl    like ub.doc-line.price-rubl    no-undo.
define input parameter parcli-base-rate like ub.doc-line.cli-base-rate no-undo.
define input parameter parprice-vat     like ub.doc-line.price-base no-undo.
define input parameter paradd-param     as   character              no-undo.
define buffer ei_trn-doc  for ub.trn-doc.
define buffer ei_gds-dtl  for ub.gds-dtl.
do on error undo, return error return-value :
find first ei_trn-doc where ei_trn-doc.doc-code = pardoc-code.
if ei_trn-doc.doc-type = {&income} and
   ei_trn-doc.internal = no        then do:
    for each ei_gds-dtl where ei_gds-dtl.doc-code  = ei_trn-doc.doc-code   and
                              ei_gds-dtl.artic     = parartic     and
                              ei_gds-dtl.prod-code = parprod-code and
                              ei_gds-dtl.prod-type = parprod-type :
       assign ei_gds-dtl.price-base = parprice-base
              ei_gds-dtl.price-rubl = parprice-rubl.
    end.
    /* обновление информации в партиях документа */
    run trg/partsupd.p
      (input parparentproc
      ,input ei_trn-doc.doc-code    /* p-doc-code        */
      ,input ei_trn-doc.obj-type    /* p-obj-type        */
      ,input ei_trn-doc.obj-code    /* p-obj-code        */
      ,input parartic               /* p-artic           */
      ,input parprod-type           /* p-prod-type       */
      ,input parprod-code           /* p-prod-code       */
      ,input true                   /* l-update-doc-line */
      ,input paradd-param           /* p-update-parts-info */
      ) no-error.
   if error-status :error then do:
      undo, return error.
   end.
end.
end.
end procedure.

/* У фирм с вмененным налогом на доход не должен считаться НДС и НП */
procedure lib-trn_have-vat-slt:
define input  parameter pardoc-code     like ub.trn-doc.doc-code no-undo.
define output parameter parhave-vat-slt as   logical             no-undo.
define buffer bf_trn-doc for ub.trn-doc.
define buffer bf_sysconf for ub.sysconf.
define variable varenvd as character no-undo.
define variable vartype as character no-undo.
do on error undo, return error return-value :
{ str/tdat-val.i pardoc-code
             {&trdcattr-envd}
             varenvd
             vartype }
if varenvd <> "yes":u then do:
  assign
    parhave-vat-slt = yes.
end.
else do:
find first bf_trn-doc where bf_trn-doc.doc-code  = pardoc-code          no-lock.
find first bf_sysconf where bf_sysconf.host-code = bf_trn-doc.host-code no-lock.
  if ( bf_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh_Kass}                                               or
       bf_trn-doc.ext-doc-type = {&TDEDT_Vozvrat_Vnesh_Kass}                                           or
      (bf_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh}     and bf_sysconf.cash-pay = bf_trn-doc.pay-code) or
      (bf_trn-doc.ext-doc-type = {&TDEDT_Vozvrat_Vnesh} and bf_sysconf.cash-pay = bf_trn-doc.pay-code)
     ) then do:
    assign
      parhave-vat-slt = no.
  end.
  else do:
    assign
      parhave-vat-slt = yes.
  end.
  end.
end.
end procedure.

/*   РАСЧЕТ ЦЕН И НДС В СТРОКЕ ПН

!!! ОСНОВНОЙ ПОСТУЛАТ: ЦЕНА ВВОДИМАЯ РУКАМИ НЕ ДОЛЖНА ПЕРЕСЧИТЫВАТЬСЯ !!!
|----------------------------------------|---------------------------------------|
|  Тип товара для заведения              |        Схема пересчета цен            |
|----------------------------------------|---------------------------------------|
|{&twounit},штучное топливо,             | price-cli <- price-rubl -> price-base |
| дробное топливо заводимое через литры  |                                       |
|----------------------------------------|---------------------------------------|
|        остальные                       | price-cli -> price-rubl -> price-base |
|----------------------------------------|---------------------------------------|
*/

procedure lib-trn_in-vat:
define input  parameter pardoc-code-or-zone         as   character               no-undo.
define input  parameter parbase-rate                like ub.trn-doc.base-rate    no-undo.
define input  parameter parbase-scale               like ub.trn-doc.base-scale   no-undo.
define input  parameter parexch-rate                like ub.trn-doc.exch-rate    no-undo.
define input  parameter parexch-scale               like ub.trn-doc.exch-scale   no-undo.
define input  parameter parvat-type                 like ub.parts.vat-type       no-undo.
define input  parameter parslt-type                 like ub.parts.slt-type       no-undo.
define input  parameter parartic                    like ub.parts.artic          no-undo.
define input  parameter parprod-type                like ub.parts.prod-type      no-undo.
define input  parameter parprod-code                like ub.parts.prod-code      no-undo.
define input  parameter parpr-cli                   like ub.parts.price-cli      no-undo.
define input  parameter parcli-base-rate            like ub.parts.cli-base-rate  no-undo.
define input  parameter parpr-rubl                  like ub.parts.price-rubl     no-undo.
define input  parameter parvat-pc                   like ub.parts.slt-pc         no-undo.
define input  parameter parslt-pc                   like ub.parts.slt-pc         no-undo.
define input  parameter parroad-tax                 like ub.parts.road-tax-rubl  no-undo.
define input  parameter partransport-rubl           like ub.parts.transport-rubl no-undo.
define input  parameter parother-rubl               like ub.parts.other-rubl     no-undo.
define output parameter parprice-cli                like ub.doc-line.price-rubl no-undo.
define output parameter parprice-cli-unit-base      like ub.doc-line.price-rubl no-undo.
define output parameter parprice-road-tax           like ub.doc-line.price-rubl no-undo.
define output parameter parprice-other-exp          like ub.doc-line.price-rubl no-undo.
define output parameter parprice-transport-exp      like ub.doc-line.price-rubl no-undo.
define output parameter parprice-without-abs        like ub.doc-line.price-rubl no-undo.
define output parameter parprice-slt                like ub.doc-line.price-rubl no-undo.
define output parameter parprice-no-slt             like ub.doc-line.price-rubl no-undo.
define output parameter parprice-vat                like ub.doc-line.price-rubl no-undo.
define output parameter parprice-no-vat-slt         like ub.doc-line.price-rubl no-undo.
define output parameter parprice-rubl               like ub.doc-line.price-rubl no-undo.
define output parameter parprice-road-tax-rubl      like ub.doc-line.price-rubl no-undo.
define output parameter parprice-other-exp-rubl     like ub.doc-line.price-rubl no-undo.
define output parameter parprice-transport-exp-rubl like ub.doc-line.price-rubl no-undo.
define output parameter parprice-without-abs-rubl   like ub.doc-line.price-rubl no-undo.
define output parameter parprice-slt-rubl           like ub.doc-line.price-rubl no-undo.
define output parameter parprice-no-slt-rubl        like ub.doc-line.price-rubl no-undo.
define output parameter parprice-vat-rubl           like ub.doc-line.price-rubl no-undo.
define output parameter parprice-no-vat-slt-rubl    like ub.doc-line.price-rubl no-undo.
define output parameter parprice-base               like ub.doc-line.price-base no-undo.
define output parameter parprice-road-tax-base      like ub.doc-line.price-base no-undo.
define output parameter parprice-other-exp-base     like ub.doc-line.price-base no-undo.
define output parameter parprice-transport-exp-base like ub.doc-line.price-base no-undo.
define output parameter parprice-without-abs-base   like ub.doc-line.price-base no-undo.
define output parameter parprice-slt-base           like ub.doc-line.price-base no-undo.
define output parameter parprice-no-slt-base        like ub.doc-line.price-base no-undo.
define output parameter parprice-vat-base           like ub.doc-line.price-base no-undo.
define output parameter parprice-no-vat-slt-base    like ub.doc-line.price-base no-undo.
define buffer iv-goods    for ub.goods.
define buffer iv-units    for ub.units.
define variable vartype   as character no-undo.
define variable varpetrol as logical   no-undo.
define variable varpieces as logical   no-undo.
define variable varhave-vat-slt as logical no-undo.

define buffer buf_trn-doc for ub.trn-doc .

do
on error undo, return error return-value
:
/* { gbl/curr-r-b.i varr-b } 12/II-2019 - вынесено в main-block */
if pardoc-code-or-zone = "zakaz":u then do:
  assign
    varhave-vat-slt  = yes
    ptrlprop-expptrl = {&calc-petrol-weight}
  .
end.
else do:
  run lib-trn_have-vat-slt in this-procedure
    (input  pardoc-code-or-zone,
     output varhave-vat-slt).
  find first buf_trn-doc no-lock
    where buf_trn-doc.doc-code = pardoc-code-or-zone
    no-error .
  if available buf_trn-doc then do:
    { gbl/ptrlprop.i
      run
      buf_trn-doc.obj-type
      buf_trn-doc.obj-code
    }
    def var varvalue as character no-undo.

    find first ub.goods no-lock where  
            ub.goods.artic = parartic
        and ub.goods.prod-type = parprod-type
        and ub.goods.prod-code = parprod-code.
    
    run gds-attr-value in this-procedure
      (  input ub.goods.gds-code
      ,  input {&attr-fuel-type}
      , output varvalue
      , output vartype
      ) no-error .
    /*для типа топлива СУГ работаем через кг*/
    if varvalue = 'lgas' then 
    do:
      ptrlprop-expptrl = {&calc-petrol-weight}.
    end.

    find first ub.goods no-lock where  
            ub.goods.artic = parartic
        and ub.goods.prod-type = parprod-type
        and ub.goods.prod-code = parprod-code.
    
    run gds-attr-value in this-procedure
      (  input ub.goods.gds-code
      ,  input {&attr-fuel-type}
      , output varvalue
      , output vartype
      ) no-error .
    /*для типа топлива СУГ работаем через кг*/
    if varvalue = 'lgas' then 
    do:
      ptrlprop-expptrl = {&calc-petrol-weight}.
    end.
    
  end.
end.
/*----------------------------------------------------------------------------------*/
/*            Определяем схему заведения цен в приходную накладную                  */
/*----------------------------------------------------------------------------------*/
find first iv-goods where iv-goods.artic     = parartic       and
                          iv-goods.prod-type = parprod-type   and
                          iv-goods.prod-code = parprod-code   no-lock.
find first iv-units where iv-units.unit-name = iv-goods.unit-base no-lock.

if lookup({&twounit}, iv-units.type) = 0
  and not ( lookup({&petrolium},  iv-units.type) > 0
            and lookup({&pieces}, iv-units.type) > 0
          )
  and not ( lookup({&petrolium},  iv-units.type) > 0
            and lookup({&pieces}, iv-units.type) = 0
            and lookup( ptrlprop-inpptrl, "{&bef-calc-petrol-volume},{&bef-calc-petrol-volume-plus}" ) > 0
          )
then do:
  assign vartype = "cli".
end.
else do:
  assign vartype = "rubl".
end.

/*-----------------------------------------------------------------------------------*/
/*      Если р_ублевая цена является определяющей, то раскрываем ее компоненты.       */
/*         В случае определения рассчитываемых цен, пишем в "цену по ТТН".            */
/*-----------------------------------------------------------------------------------*/
if vartype = "rubl" then do:
  assign parprice-rubl = parpr-rubl.
  run lib-trn_in-vat-incl in this-procedure (input  parother-rubl                  ,
                           input  partransport-rubl              ,
                           input  parroad-tax                    ,
                           input  parprice-rubl                  ,
                           input  parvat-pc                      ,
                           input  parslt-pc                      ,
                           input  parbase-rate                   ,
                           input  parbase-scale                  ,
                           input  varhave-vat-slt                ,
                           output parprice-other-exp-rubl        ,
                           output parprice-transport-exp-rubl    ,
                           output parprice-road-tax-rubl         ,
                           output parprice-without-abs-rubl      ,
                           output parprice-SLT-rubl              ,
                           output parprice-no-slt-rubl           ,
                           output parprice-VAT-rubl              ,
                           output parprice-no-VAT-slt-rubl    ) no-error.
  if error-status :error then do:
     return error return-value.
  end.
  assign parprice-cli-unit-base = (parprice-no-vat-slt-rubl +
                         (if parvat-type =  {&inc-VAT} then parprice-vat-rubl else 0) +
                         (if parslt-type =  {&inc-SLT} then parprice-slt-rubl else 0) )
                         / parexch-rate  * parexch-scale
         parprice-cli = parprice-cli-unit-base * parcli-base-rate.
end.
else do:
  assign parprice-cli           = parpr-cli
         parprice-cli-unit-base = parprice-cli / parcli-base-rate.
end.

/*---------------------------------------------------------------------------------*/
/*                    Вычисление компонентов цены по ТТН                           */
/*---------------------------------------------------------------------------------*/

ASSIGN
parprice-other-exp     = (if parother-rubl     <> ? then parother-rubl     else 0)
                         / parexch-rate * parexch-scale
                         * parcli-base-rate
parprice-transport-exp = (if partransport-rubl <> ? then partransport-rubl else 0)
                         / parexch-rate * parexch-scale
                         * parcli-base-rate
.
if g-varr-b = "rubl":u then do:
  assign
    parprice-road-tax      = parroad-tax
                             / parexch-rate * parexch-scale
                             * parcli-base-rate
  .
end.
else do:
  assign
    parprice-road-tax      = parroad-tax
                             * parbase-rate / parbase-scale
                             / parexch-rate * parexch-scale
                             * parcli-base-rate
  .
end.
case parvat-type:
when {&without-vat} then do:
  if parvat-pc <> 0 then do:
    return error substitute(" В документе установлен тип НДС - без, а ставка НДС отлична от 0.( = &1 )" ,parvat-pc ) .
  end.
  if parslt-type = {&no-slt}      or
     parslt-Type = {&without-slt} then do:
    assign
      parprice-VAT        = 0
      parprice-slt        = (if varhave-vat-slt <> yes then 0 else parprice-cli * parslt-pc / 100)
      parprice-no-vat-slt = parprice-cli.
  end.
  else do:
    assign
      parprice-VAT        = 0
      parprice-slt        = (if varhave-vat-slt <> yes then 0 else parprice-cli * parslt-pc / (100 + parslt-pc))
      parprice-no-vat-slt = parprice-cli - parprice-slt.
  end.
end.
when {&no-vat} then do:
  if parslt-type = {&no-slt}      or
     parslt-Type = {&without-slt} then do:
    assign
      parprice-VAT        = (if varhave-vat-slt <> yes then 0 else parprice-cli                         * parvat-pc / 100)
      parprice-slt        = (if varhave-vat-slt <> yes then 0 else parprice-cli * (1 + parvat-pc / 100) * parslt-pc / 100)
      parprice-no-vat-slt = parprice-cli.
  end.
  /*inc-slt
   Вырожденный случай когда указали цену без НДС, но с налогом с продаж*/
  else do:
    assign
      parprice-VAT        = (if varhave-vat-slt <> yes then 0 else parprice-cli / ((100 / parvat-pc) * (1 + parslt-pc / 100) + parslt-pc / 100))
      parprice-slt        = (if varhave-vat-slt <> yes then 0 else parprice-cli * ( 1 - 1 / (1 + parslt-pc / 100 + parslt-pc / 100 * parvat-pc / 100 )))
      parprice-no-vat-slt = parprice-cli - parprice-slt.
  end.
end.
/*inc-vat*/
when {&inc-vat} then do:
  if parslt-type = {&no-slt}      or
     parslt-Type = {&without-slt} then do:
    assign
      parprice-VAT        = (if varhave-vat-slt <> yes then 0 else parprice-cli   * parvat-pc / (100 + parvat-pc))
      parprice-slt        = (if varhave-vat-slt <> yes then 0 else parprice-cli   * parslt-pc / 100)
      parprice-no-vat-slt = parprice-cli - parprice-VAT.
  end.
  /*inc-slt*/
  else do:
    assign
      parprice-VAT        = (if varhave-vat-slt <> yes then 0 else parprice-cli * (100 / ( 100 + parslt-pc)) * parvat-pc / (100 + parvat-pc))
      parprice-slt        = (if varhave-vat-slt <> yes then 0 else parprice-cli                              * parslt-pc / (100 + parslt-pc))
      parprice-no-vat-slt = parprice-cli - parprice-VAT - parprice-SLT.
  end.
end.
end case.
assign parprice-without-abs = parprice-no-vat-slt + parprice-VAT + parprice-slt.
if vartype = "cli" then do:
  assign
  parprice-rubl  = (parprice-without-abs
                    * parexch-rate / parexch-scale
                    / parcli-base-rate
                    +
                    parroad-tax * (if g-varr-b = "base":u then parbase-rate  /  parbase-scale else 1) +
                    (if partransport-rubl <> ? then partransport-rubl else 0)  +
                    (if parother-rubl     <> ? then parother-rubl     else 0)
                    ).
  run lib-trn_in-vat-incl in this-procedure (input  parother-rubl                  ,
                           input  partransport-rubl              ,
                           input  parroad-tax                    ,
                           input  parprice-rubl                  ,
                           input  parvat-pc                      ,
                           input  parslt-pc                      ,
                           input  parbase-rate                   ,
                           input  parbase-scale                  ,
                           input  varhave-vat-slt                ,
                           output parprice-other-exp-rubl        ,
                           output parprice-transport-exp-rubl    ,
                           output parprice-road-tax-rubl         ,
                           output parprice-without-abs-rubl      ,
                           output parprice-SLT-rubl              ,
                           output parprice-no-slt-rubl           ,
                           output parprice-VAT-rubl              ,
                           output parprice-no-VAT-slt-rubl    ) no-error.
  if error-status :error then do:
     return error return-value.
  end.
end.
assign
parprice-base               = parprice-rubl               / parbase-rate * parbase-scale
parprice-road-tax-base      = parprice-road-tax-rubl      / parbase-rate * parbase-scale
parprice-other-exp-base     = parprice-other-exp-rubl     / parbase-rate * parbase-scale
parprice-transport-exp-base = parprice-transport-exp-rubl / parbase-rate * parbase-scale
parprice-without-abs-base   = parprice-without-abs-rubl   / parbase-rate * parbase-scale
parprice-slt-base           = parprice-slt-rubl           / parbase-rate * parbase-scale
parprice-no-slt-base        = parprice-no-slt-rubl        / parbase-rate * parbase-scale
parprice-vat-base           = parprice-vat-rubl           / parbase-rate * parbase-scale
parprice-no-vat-slt-base    = parprice-no-vat-slt-rubl    / parbase-rate * parbase-scale
.
end.
end procedure.

procedure lib-trn_in-vat-incl:
define input  parameter parother-rubl                like ub.parts.other-rubl     no-undo.
define input  parameter partransport-rubl            like ub.parts.transport-rubl no-undo.
define input  parameter parroad-tax                  like ub.parts.road-tax-base  no-undo.
define input  parameter parpr-rubl                   like ub.parts.price-rubl     no-undo.
define input  parameter parvat-pc                    like ub.parts.vat-pc         no-undo.
define input  parameter parslt-pc                    like ub.parts.slt-pc         no-undo.
define input  parameter parbase-rate                 like ub.trn-doc.base-rate    no-undo.
define input  parameter parbase-scale                like ub.trn-doc.base-scale   no-undo.
define input  parameter parhave-vat-slt              as   logical                 no-undo.
define output parameter parprice-other-exp-rubl      like ub.parts.other-rubl     no-undo.
define output parameter parprice-transport-exp-rubl  like ub.parts.transport-rubl no-undo.
define output parameter parprice-road-tax-rubl       like ub.parts.road-tax-rubl  no-undo.
define output parameter parprice-without-abs-rubl    like ub.parts.price-rubl     no-undo.
define output parameter parprice-SLT-rubl            like ub.parts.price-rubl     no-undo.
define output parameter parprice-no-slt-rubl         like ub.parts.price-rubl     no-undo.
define output parameter parprice-VAT-rubl            like ub.parts.price-rubl     no-undo.
define output parameter parprice-no-VAT-slt-rubl     like ub.parts.price-rubl     no-undo.
define variable varr-b as character no-undo.
do on error undo, return error return-value :
  ASSIGN
  parprice-other-exp-rubl     = (if parother-rubl     <> ? then parother-rubl     else 0)
  parprice-transport-exp-rubl = (if partransport-rubl <> ? then partransport-rubl else 0)
  parprice-road-tax-rubl      = parroad-tax *  (if varr-b = "base":u THEN parbase-rate / parbase-scale else 1 )
  parprice-without-abs-rubl   = parpr-rubl                  -
                                parprice-other-exp-rubl     -
                                parprice-transport-exp-rubl -
                                parprice-road-tax-rubl.
  /* НП в р_ублевой цене и р_ублевая цена без НП*/
  assign parprice-SLT-rubl    = (if parhave-vat-slt <> yes then 0 else parprice-without-abs-rubl * parslt-pc / (parslt-pc + 100))
         parprice-no-slt-rubl = parprice-without-abs-rubl - parprice-slt-rubl.
  /* НДС в р_ублевой цене и р_ублевая цена без НДС*/
  assign
      parprice-VAT-rubl        = (if parhave-vat-slt <> yes then 0 else parprice-no-slt-rubl * parvat-pc / (parvat-pc + 100))
      parprice-no-VAT-slt-rubl = parprice-no-slt-rubl - parprice-VAT-rubl.
end.
end procedure.

/* Проверка на топливо */
procedure lib-trn_is-petrl :
  define  input parameter parartic        like ub.goods.artic     no-undo.
  define  input parameter parprod-type    like ub.goods.prod-type no-undo.
  define  input parameter parprod-code    like ub.goods.prod-code no-undo.
  define output parameter paris-petrolium as   logical            no-undo.
  define output parameter paris-pieces    as   logical            no-undo.

  define buffer bf_goods for ub.goods.
  define buffer bf_units for ub.units.

  do on error undo, return error
              substitute( 'lib-trn_is-petrl: ошибка определения товара на топливо: товар &1 ' + if parprod-type eq ? then '(код &3).' else '(производитель &2 &3).',
                          parartic, parprod-type, parprod-code ) :
    if parprod-type ne ? 
    then
       find first bf_goods no-lock where
                  bf_goods.artic     = parartic     and
                  bf_goods.prod-type = parprod-type and
                  bf_goods.prod-code = parprod-code no-error.
    else
       find first bf_goods no-lock where
                  bf_goods.gds-code     = parprod-code no-error.
    if not available bf_goods then do:
      undo, return error substitute( "lib-trn_is-petrl: не найден товар &1 " + if parprod-type eq ? then '(код &3).' else '(производитель &2 &3).',
                                     parartic, parprod-type, parprod-code ).
    end.
    find first bf_units no-lock where bf_units.unit-name = bf_goods.unit-base no-error.
    if not available bf_units then do:
      return error substitute( 'lib-trn_is-petrl: не найдена базовая ед.изм. "&1" в товаре &2 ' + if parprod-type eq ? then '(код &4).' else '(производитель &3 &4).',
                               bf_goods.unit-base, parartic, parprod-type, parprod-code ).
	end.
    assign paris-petrolium = ( if lookup( {&petrolium}, bf_units.type ) > 0 then yes else no ).
    if lookup( {&pieces}, bf_units.type ) = 0 then do:
      if paris-petrolium = yes and lookup( {&divisional}, bf_units.type ) = 0 then do:
        undo, return error substitute( 'lib-trn_is-petrl: Неверная связка типов единиц измерения для топлива: "&1" .',
                                       bf_units.type ).
      end.
      assign paris-pieces = no.
    end.
    else do:
      assign paris-pieces = yes.
    end.
  end. /* on error */
end procedure. /* lib-trn_is-petrl */

/* --------------------------------------------------------------------------------------- */
/*  Description: Пересчет шапки внешней приходной накладной после работы с одной строкой   */
/* --------------------------------------------------------------------------------------- */
procedure lib-trn_clcintrn:
define input parameter parparentproc     AS WIDGET-HANDLE                NO-UNDO.
define input parameter parrec-linenew    as recid                        no-undo.
define input parameter pardoc-code       like ub.doc-line.doc-code       no-undo.
define input parameter parartic          like ub.doc-line.artic          no-undo.
define input parameter parprod-type      like ub.doc-line.prod-type      no-undo.
define input parameter parprod-code      like ub.doc-line.prod-code      no-undo.
define input parameter parprice-cli      like ub.doc-line.price-cli      no-undo.
define input parameter parprice-rubl     like ub.doc-line.price-rubl     no-undo.
define input parameter parprice-base     like ub.doc-line.price-base     no-undo.
define input parameter parcli-qnty       like ub.doc-line.cli-qnty       no-undo.
define input parameter parcli-base-rate  like ub.doc-line.cli-base-rate  no-undo.
define input parameter parfact-qnty      like ub.doc-line.fact-qnty      no-undo.
define input parameter pardoc-qnty       like ub.doc-line.doc-qnty       no-undo.
define input parameter parvat-pc         like ub.doc-line.vat-pc         no-undo.
define input parameter parslt-pc         like ub.doc-line.slt-pc         no-undo.
define input parameter parroad-tax       like ub.doc-line.road-tax       no-undo.
define input parameter parexcise         like ub.doc-line.excise         no-undo.
define input parameter partransport-rubl like ub.doc-line.transport-rubl no-undo.
define input parameter parother-rubl     like ub.doc-line.other-rubl     no-undo.
define input parameter parmode           as character                    no-undo.
define input parameter parrsrv-inf       as character                    no-undo.
define variable v-clcdoc-vat-pc                     like ub.doc-line.vat-pc        no-undo.
define variable v-clcdoc-slt-pc                     like ub.doc-line.slt-pc        no-undo.
define variable v-clcdoc-have-slt-pc                like ub.doc-line.slt-pc        no-undo.
define variable v-clcdoc-host-code                  like ub.sysconf.host-code         no-undo.
define variable v-total-doc-line_tot-ovnew          like ub.trn-doc.tot-ov         no-undo.
define variable v-total-doc-line_fact-rublnew       like ub.trn-doc.fact-rubl      no-undo.
define variable v-total-doc-line_fact-basenew       like ub.trn-doc.fact-base      no-undo.
define variable v-total-doc-line_fact-qntynew       like ub.trn-doc.fact-qnty      no-undo.
define variable v-total-doc-line_doc-qntynew        like ub.trn-doc.doc-qnty       no-undo.
define variable v-total-doc-line_cli-qntynew        like ub.trn-doc.cli-qnty       no-undo.
define variable v-total-parts_fact-basenew          as   decimal                   no-undo.
define variable v-total-parts_fact-rublnew          as   decimal                   no-undo.
define variable v-total-parts_fact-qntynew          as   decimal                   no-undo.
define variable v-total-doc-line_tot-ovold          like ub.trn-doc.tot-ov         no-undo.
define variable v-total-doc-line_fact-rublold       like ub.trn-doc.fact-rubl      no-undo.
define variable v-total-doc-line_fact-baseold       like ub.trn-doc.fact-base      no-undo.
define variable v-total-doc-line_fact-qntyold       like ub.trn-doc.fact-qnty      no-undo.
define variable v-total-doc-line_doc-qntyold        like ub.trn-doc.doc-qnty       no-undo.
define variable v-total-doc-line_cli-qntyold        like ub.trn-doc.cli-qnty       no-undo.
define variable v-total-parts_fact-baseold          as   decimal                   no-undo.
define variable v-total-parts_fact-rublold          as   decimal                   no-undo.
define variable v-total-parts_fact-qntyold          as   decimal                   no-undo.
define variable delta-line-vat                      like ub.trn-doc.vat-base       no-undo.
define variable delta-line-slt                      like ub.trn-doc.slt-base       no-undo.
define variable v-inout-price                       like ub.store.inout-price      no-undo.
define variable v-cash-pay                          like ub.sysconf.cash-pay       no-undo.
define variable varprice-clinew                     like ub.doc-line.price-rubl no-undo.
define variable varprice-cli-unit-basenew           like ub.doc-line.price-rubl no-undo.
define variable varprice-road-taxnew                like ub.doc-line.price-rubl no-undo.
define variable varprice-other-expnew               like ub.doc-line.price-rubl no-undo.
define variable varprice-transport-expnew           like ub.doc-line.price-rubl no-undo.
define variable varprice-without-absnew             like ub.doc-line.price-rubl no-undo.
define variable varprice-sltnew                     like ub.doc-line.price-rubl no-undo.
define variable varprice-no-sltnew                  like ub.doc-line.price-rubl no-undo.
define variable varprice-vatnew                     like ub.doc-line.price-rubl no-undo.
define variable varprice-no-vat-sltnew              like ub.doc-line.price-rubl no-undo.
define variable varprice-rublnew                    like ub.doc-line.price-rubl no-undo.
define variable varprice-road-tax-rublnew           like ub.doc-line.price-rubl no-undo.
define variable varprice-other-exp-rublnew          like ub.doc-line.price-rubl no-undo.
define variable varprice-transport-exp-rublnew      like ub.doc-line.price-rubl no-undo.
define variable varprice-without-abs-rublnew        like ub.doc-line.price-rubl no-undo.
define variable varprice-slt-rublnew                like ub.doc-line.price-rubl no-undo.
define variable varprice-no-slt-rublnew             like ub.doc-line.price-rubl no-undo.
define variable varprice-vat-rublnew                like ub.doc-line.price-rubl no-undo.
define variable varprice-no-vat-slt-rublnew         like ub.doc-line.price-rubl no-undo.
define variable varprice-basenew                    like ub.doc-line.price-base no-undo.
define variable varprice-road-tax-basenew           like ub.doc-line.price-base no-undo.
define variable varprice-other-exp-basenew          like ub.doc-line.price-base no-undo.
define variable varprice-transport-exp-basenew      like ub.doc-line.price-base no-undo.
define variable varprice-without-abs-basenew        like ub.doc-line.price-base no-undo.
define variable varprice-slt-basenew                like ub.doc-line.price-base no-undo.
define variable varprice-no-slt-basenew             like ub.doc-line.price-base no-undo.
define variable varprice-vat-basenew                like ub.doc-line.price-base no-undo.
define variable varprice-no-vat-slt-basenew         like ub.doc-line.price-base no-undo.
define variable varprice-cliold                     like ub.doc-line.price-rubl no-undo.
define variable varprice-cli-unit-baseold           like ub.doc-line.price-rubl no-undo.
define variable varprice-road-taxold                like ub.doc-line.price-rubl no-undo.
define variable varprice-other-expold               like ub.doc-line.price-rubl no-undo.
define variable varprice-transport-expold           like ub.doc-line.price-rubl no-undo.
define variable varprice-without-absold             like ub.doc-line.price-rubl no-undo.
define variable varprice-sltold                     like ub.doc-line.price-rubl no-undo.
define variable varprice-no-sltold                  like ub.doc-line.price-rubl no-undo.
define variable varprice-vatold                     like ub.doc-line.price-rubl no-undo.
define variable varprice-no-vat-sltold              like ub.doc-line.price-rubl no-undo.
define variable varprice-rublold                    like ub.doc-line.price-rubl no-undo.
define variable varprice-road-tax-rublold           like ub.doc-line.price-rubl no-undo.
define variable varprice-other-exp-rublold          like ub.doc-line.price-rubl no-undo.
define variable varprice-transport-exp-rublold      like ub.doc-line.price-rubl no-undo.
define variable varprice-without-abs-rublold        like ub.doc-line.price-rubl no-undo.
define variable varprice-slt-rublold                like ub.doc-line.price-rubl no-undo.
define variable varprice-no-slt-rublold             like ub.doc-line.price-rubl no-undo.
define variable varprice-vat-rublold                like ub.doc-line.price-rubl no-undo.
define variable varprice-no-vat-slt-rublold         like ub.doc-line.price-rubl no-undo.
define variable varprice-baseold                    like ub.doc-line.price-base no-undo.
define variable varprice-road-tax-baseold           like ub.doc-line.price-base no-undo.
define variable varprice-other-exp-baseold          like ub.doc-line.price-base no-undo.
define variable varprice-transport-exp-baseold      like ub.doc-line.price-base no-undo.
define variable varprice-without-abs-baseold        like ub.doc-line.price-base no-undo.
define variable varprice-slt-baseold                like ub.doc-line.price-base no-undo.
define variable varprice-no-slt-baseold             like ub.doc-line.price-base no-undo.
define variable varprice-vat-baseold                like ub.doc-line.price-base no-undo.
define variable varprice-no-vat-slt-baseold         like ub.doc-line.price-base no-undo.
define buffer tc_doc-line-new for ub.doc-line.
define buffer tc_trn-doc      for ub.trn-doc.
define buffer tc_store        for ub.store.
define buffer tc_shop         for ub.shop.
define buffer tc_goods        for ub.goods.
define buffer tc_sysconf      for ub.sysconf.
do on error undo, return error return-value :
find first tc_trn-doc  where tc_trn-doc.doc-code = pardoc-code.
if parmode <> "delete" then do:
  find first tc_doc-line-new where recid(tc_doc-line-new) = parrec-linenew.
  if tc_trn-doc.obj-type = {&stock} then do:
    find tc_store where tc_store.obj-code = tc_trn-doc.obj-code no-lock.
    assign
      v-inout-price = tc_store.inout-price.
    find tc_sysconf where tc_sysconf.host-code = tc_store.host-code no-lock.
  end.
  else do:
    find tc_shop where tc_shop.obj-code = tc_trn-doc.obj-code no-lock.
    assign
      v-inout-price = tc_shop.inout-price.
    find tc_sysconf where tc_sysconf.host-code = tc_shop.host-code no-lock.
  end.
  assign
         v-cash-pay  = tc_sysconf.cash-pay.
  if not v-inout-price               and
     tc_trn-doc.doc-type = {&income} and
     not tc_trn-doc.internal         and
     tc_trn-doc.doc-type = {&wayb}   and
     not tc_trn-doc.flag_         then do:
      /* обновление налогов - могло измениться за время работы */
      find tc_goods where tc_goods.artic     = tc_doc-line-new.artic     and
                          tc_goods.prod-type = tc_doc-line-new.prod-type and
                          tc_goods.prod-code = tc_doc-line-new.prod-code
      no-lock.
      { gbl/hostcode.i tc_doc-line-new.obj-type tc_doc-line-new.obj-code v-clcdoc-host-code }
      { gbl/pftxvalg.i tc_goods.gds-code {&vat-tax-code} ? v-clcdoc-host-code tc_doc-line-new.obj-type tc_doc-line-new.obj-code v-clcdoc-vat-pc no-error }
      assign
          tc_doc-line-new.vat-pc = v-clcdoc-vat-pc
      .
      { str/st-sltpc.i
        recid(tc_goods)
        recid(tc_trn-doc)
        v-cash-pay
        v-clcdoc-slt-pc
        no-error
      }
      if error-status :error then return error.
      assign tc_doc-line-new.slt-pc = v-clcdoc-slt-pc.
   end.
   { str/in-vat.i
    tc_trn-doc.doc-code
    tc_trn-doc.base-rate
    tc_trn-doc.base-scale
    tc_trn-doc.exch-rate
    tc_trn-doc.exch-scale
    tc_trn-doc.vat-type
    tc_trn-doc.slt-type
    tc_doc-line-new.artic
    tc_doc-line-new.prod-type
    tc_doc-line-new.prod-code
    tc_doc-line-new.price-cli
    tc_doc-line-new.cli-base-rate
    tc_doc-line-new.price-rubl
    tc_doc-line-new.vat-pc
    tc_doc-line-new.slt-pc
    tc_doc-line-new.road-tax
    tc_doc-line-new.transport-rubl
    tc_doc-line-new.other-rubl
    varprice-clinew
    varprice-cli-unit-basenew
    varprice-road-taxnew
    varprice-other-expnew
    varprice-transport-expnew
    varprice-without-absnew
    varprice-sltnew
    varprice-no-sltnew
    varprice-vatnew
    varprice-no-vat-sltnew
    varprice-rublnew
    varprice-road-tax-rublnew
    varprice-other-exp-rublnew
    varprice-transport-exp-rublnew
    varprice-without-abs-rublnew
    varprice-slt-rublnew
    varprice-no-slt-rublnew
    varprice-vat-rublnew
    varprice-no-vat-slt-rublnew
    varprice-basenew
    varprice-road-tax-basenew
    varprice-other-exp-basenew
    varprice-transport-exp-basenew
    varprice-without-abs-basenew
    varprice-slt-basenew
    varprice-no-slt-basenew
    varprice-vat-basenew
    varprice-no-vat-slt-basenew
    no-error
   }
   if error-status :error then do:
     return error substitute ("Ошибка при вычисление компонентов линии документа &1.", return-value).
   end.
   assign delta-line-VAT =  tc_doc-line-new.fact-qnty *
                            varprice-vatnew /
                            tc_doc-line-new.cli-base-rate.
   assign delta-line-SLT = tc_doc-line-new.fact-qnty *
                           varprice-sltnew /
                           tc_doc-line-new.cli-base-rate.
   /*Запишем цены из линии в признаки и партии и ндс в признаки*/
   run lib-trn_fill-ext-inc in this-procedure (input parparentproc,
                             input tc_doc-line-new.doc-code,
                             input tc_doc-line-new.artic,
                             input tc_doc-line-new.prod-type,
                             input tc_doc-line-new.prod-code,
                             input tc_doc-line-new.price-base,
                             input tc_doc-line-new.price-rubl,
                             input tc_doc-line-new.cli-base-rate,
                             input varprice-vatnew,
                             input parrsrv-inf) no-error.
   if error-status :error then do:
     return error return-value.
   end.
   /*подсчитаем новые значения в учетных ценах*/
   { str/acc-cost.i
     tc_doc-line-new.obj-type
     tc_doc-line-new.obj-code
     tc_doc-line-new.doc-code
     tc_doc-line-new.artic
     tc_doc-line-new.prod-type
     tc_doc-line-new.prod-code
     tc_doc-line-new.cli-qnty
     tc_doc-line-new.doc-qnty
     tc_doc-line-new.fact-qnty
     tc_doc-line-new.price-base
     tc_doc-line-new.price-rubl
     "'new':U"
     v-total-doc-line_tot-ovnew
     v-total-doc-line_fact-rublnew
     v-total-doc-line_fact-basenew
     v-total-doc-line_fact-qntynew
     v-total-doc-line_doc-qntynew
     v-total-doc-line_cli-qntynew
     no-error
   }
   if error-status :error then do:
     return error return-value.
   end.
end. /*<> "delete"*/
else do:
  assign
  v-total-doc-line_tot-ovnew       = 0
  v-total-doc-line_fact-rublnew    = 0
  v-total-doc-line_fact-basenew    = 0
  v-total-doc-line_fact-qntynew    = 0
  v-total-doc-line_doc-qntynew     = 0
  v-total-doc-line_cli-qntynew     = 0
  .
end.

if parmode <> "create" then do:
   run lib-trn_in-vat in this-procedure (
    input  tc_trn-doc.doc-code          ,
    input  tc_trn-doc.base-rate         ,
    input  tc_trn-doc.base-scale        ,
    input  tc_trn-doc.exch-rate         ,
    input  tc_trn-doc.exch-scale        ,
    input  tc_trn-doc.vat-type          ,
    input  tc_trn-doc.slt-type          ,
    input  parartic                     ,
    input  parprod-type                 ,
    input  parprod-code                 ,
    input  parprice-cli                 ,
    input  parcli-base-rate             ,
    input  parprice-rubl                ,
    input  parvat-pc                    ,
    input  parslt-pc                    ,
    input  parroad-tax                  ,
    input  partransport-rubl            ,
    input  parother-rubl                ,
    output varprice-cliold                              ,
    output varprice-cli-unit-baseold                    ,
    output varprice-road-taxold                         ,
    output varprice-other-expold                        ,
    output varprice-transport-expold                    ,
    output varprice-without-absold                      ,
    output varprice-sltold                              ,
    output varprice-no-sltold                           ,
    output varprice-vatold                              ,
    output varprice-no-vat-sltold                       ,
    output varprice-rublold                             ,
    output varprice-road-tax-rublold                    ,
    output varprice-other-exp-rublold                   ,
    output varprice-transport-exp-rublold               ,
    output varprice-without-abs-rublold                 ,
    output varprice-slt-rublold                         ,
    output varprice-no-slt-rublold                      ,
    output varprice-vat-rublold                         ,
    output varprice-no-vat-slt-rublold                  ,
    output varprice-baseold                             ,
    output varprice-road-tax-baseold                    ,
    output varprice-other-exp-baseold                   ,
    output varprice-transport-exp-baseold               ,
    output varprice-without-abs-baseold                 ,
    output varprice-slt-baseold                         ,
    output varprice-no-slt-baseold                      ,
    output varprice-vat-baseold                         ,
    output varprice-no-vat-slt-baseold                  ) no-error.
  if error-status :error then do:
     return error substitute ("Ошибка при вычисление компонентов линии документа &1.", return-value).
  end.
  ASSIGN delta-line-VAT =  delta-line-vat -
                           parfact-qnty * varprice-vatold / parcli-base-rate
         delta-line-SLT =  delta-line-slt -
                           parfact-qnty * varprice-sltold / parcli-base-rate.
  /*подсчитаем старые значения в учетных ценах*/
  { str/acc-cost.i
   tc_trn-doc.obj-type
   tc_trn-doc.obj-code
   pardoc-code
   parartic
   parprod-type
   parprod-code
   parcli-qnty
   pardoc-qnty
   parfact-qnty
   parprice-base
   parprice-rubl
   "'old':U"
   v-total-doc-line_tot-ovold
   v-total-doc-line_fact-rublold
   v-total-doc-line_fact-baseold
   v-total-doc-line_fact-qntyold
   v-total-doc-line_doc-qntyold
   v-total-doc-line_cli-qntyold
   no-error
  }
  if error-status :error then do:
    return error return-value.
  end.
end.
else do:
  assign
  v-total-doc-line_tot-ovold       = 0
  v-total-doc-line_fact-rublold    = 0
  v-total-doc-line_fact-baseold    = 0
  v-total-doc-line_fact-qntyold    = 0
  v-total-doc-line_doc-qntyold     = 0
  v-total-doc-line_cli-qntyold     = 0
  .
end.
if tc_trn-doc.doc-qnty = ? then tc_trn-doc.doc-qnty = 0.
if delta-line-vat      = ? then delta-line-vat      = 0.
if delta-line-slt      = ? then delta-line-slt      = 0.
if parmode <> "delete" then do:
   if tc_doc-line-new.fact-qnty = ? then do:
     assign
      tc_doc-line-new.fact-qnty = 0.
   end.
end.

assign
  tc_trn-doc.vat-rubl = tc_trn-doc.vat-rubl + delta-line-vat * tc_trn-doc.exch-rate / tc_trn-doc.exch-scale
  tc_trn-doc.vat-base = tc_trn-doc.vat-rubl / tc_trn-doc.base-rate * tc_trn-doc.base-scale
  tc_trn-doc.slt-rubl = tc_trn-doc.slt-rubl + delta-line-slt * tc_trn-doc.exch-rate / tc_trn-doc.exch-scale
  tc_trn-doc.slt-base = tc_trn-doc.slt-rubl / tc_trn-doc.base-rate * tc_trn-doc.base-scale
  tc_trn-doc.tot-calc = tc_trn-doc.tot-calc +
                  (if parmode <> "delete" then (tc_doc-line-new.cli-qnty * tc_doc-line-new.price-cli) else 0) -
                  (if parmode <> "create" then (parcli-qnty * parprice-cli) else 0)
  tc_trn-doc.tot-doc  = tc_trn-doc.tot-doc +
                  (if parmode <> "delete" then (tc_doc-line-new.doc-qnty * tc_doc-line-new.price-base) else 0) -
                  (if parmode <> "create" then (pardoc-qnty * parprice-base) else 0)
  tc_trn-doc.tot-fact = tc_trn-doc.tot-fact +
                  (if parmode <> "delete" then (tc_doc-line-new.fact-qnty * tc_doc-line-new.price-base) else 0)  -
                  (if parmode <> "create" then (parfact-qnty * parprice-base) else 0)
  tc_trn-doc.road-tax = tc_trn-doc.road-tax  +
                  (if parmode <> "delete" then (tc_doc-line-new.fact-qnty * tc_doc-line-new.road-tax) else 0) -
                  (if parmode <> "create" then (parfact-qnty * parroad-tax) else 0)
  tc_trn-doc.excise = tc_trn-doc.excise +
                  (if parmode <> "delete" then (tc_doc-line-new.fact-qnty * tc_doc-line-new.excise) else 0) -
                  (if parmode <> "create" then (parfact-qnty * parexcise) else 0)
  tc_trn-doc.tot-sale = tc_trn-doc.tot-sale +
                  (if parmode <> "delete" then (tc_doc-line-new.fact-qnty * tc_doc-line-new.price-rubl) else 0) -
                  (if parmode <> "create" then (parfact-qnty * parprice-rubl) else 0)
  tc_trn-doc.tot-rubl = tc_trn-doc.tot-rubl +
                  (if parmode <> "delete" then (tc_doc-line-new.doc-qnty * tc_doc-line-new.price-rubl) else 0) -
                  (if parmode <> "create" then (pardoc-qnty * parprice-rubl) else 0)

                  .
if tc_trn-doc.status_ = {&fact} then do:
  assign
      tc_trn-doc.tot-transp = tc_trn-doc.tot-transp +
                  (if parmode <> "delete" then (tc_doc-line-new.fact-qnty * tc_doc-line-new.transport-rubl) else 0) -
                  (if parmode <> "create" then (parfact-qnty * partransport-rubl) else 0)
      tc_trn-doc.tot-other = tc_trn-doc.tot-other +
                  (if parmode <> "delete" then (tc_doc-line-new.fact-qnty * tc_doc-line-new.other-rubl) else 0) -
                  (if parmode <> "create" then (parfact-qnty * parother-rubl) else 0).
end.
{ str/ass-cost.i
  recid(tc_trn-doc)
  v-total-doc-line_tot-ovnew
  v-total-doc-line_fact-rublnew
  v-total-doc-line_fact-basenew
  v-total-doc-line_fact-qntynew
  v-total-doc-line_doc-qntynew
  v-total-doc-line_cli-qntynew
  v-total-doc-line_tot-ovold
  v-total-doc-line_fact-rublold
  v-total-doc-line_fact-baseold
  v-total-doc-line_fact-qntyold
  v-total-doc-line_doc-qntyold
  v-total-doc-line_cli-qntyold
  no-error
}
  if error-status :error then undo, return error.
if parmode = "delete" then do:
  assign tc_trn-doc.tot-lines = tc_trn-doc.tot-lines - 1.
end.
if parmode = "create" then do:
  assign tc_trn-doc.tot-lines = tc_trn-doc.tot-lines + 1.
end.
if substr (tc_trn-doc.PS, 1, 1) = "@" then
        tc_trn-doc.PS = "@  Строк в документе : " + string (tc_trn-doc.tot-lines).
end.
end procedure.

/* Проверка на целое количество в штучных единицах измерения */
procedure lib-trn_chkwhole:
define input parameter pardoc-code  like ub.trn-doc.doc-code   no-undo.
define input parameter parartic     like ub.doc-line.artic     no-undo.
define input parameter parprod-type like ub.doc-line.prod-type no-undo.
define input parameter parprod-code like ub.doc-line.prod-code no-undo.
define input parameter parcli-qnty  like ub.doc-line.cli-qnty  no-undo.
define input parameter pardoc-qnty  like ub.doc-line.doc-qnty  no-undo.
define input parameter parfact-qnty like ub.doc-line.fact-qnty no-undo.
define input parameter parrecalc    as   logical               no-undo.
define variable is-unit-error as logical no-undo.
define variable g-log as logical no-undo.
define buffer cw-cli-units  for ub.units.
define buffer cw-base-units for ub.units.
define buffer cw-goods      for ub.goods.
define buffer cw-doc-line   for ub.doc-line.
define buffer cw-trn-doc    for ub.trn-doc.
find first cw-goods      where cw-goods.artic     = parartic                  and
                               cw-goods.prod-type = parprod-type              and
                               cw-goods.prod-code = parprod-code              no-lock.
find first cw-doc-line   where cw-doc-line.doc-code    = pardoc-code          and
                               cw-doc-line.artic       = cw-goods.artic       and
                               cw-doc-line.prod-type   = cw-goods.prod-type   and
                               cw-doc-line.prod-code   = cw-goods.prod-code   .
find first cw-base-units where cw-base-units.unit-name = cw-goods.unit-base   no-lock.
find first cw-trn-doc    where cw-trn-doc.doc-code     = pardoc-code          no-lock.
if cw-doc-line.unit-cli <> "" then do:
   find first cw-cli-units  where cw-cli-units.unit-name  = cw-doc-line.unit-cli no-lock.
   /*Получаем не целое кол-во в единицах поставщика*/
   if lookup({&pieces}, cw-cli-units.type) > 0 and
      trunc(parcli-qnty, 0) <> parcli-qnty     then do:
      /*Проверим можно ли переделать накладную к базовым единицам*/
      run str/ck-uncli.p (input cw-goods.unit-base,
                      input cw-goods.gds-code,
                      input cw-trn-doc.obj-type,
                      input cw-trn-doc.obj-code,
                      input cw-trn-doc.hold-doc-code-parent,
                      input cw-trn-doc.hold-doc-code-child,
                      output is-unit-error) no-error.
      if error-status :error then return error return-value.
      if is-unit-error or
         not (cw-trn-doc.doc-type = {&income} and
              not cw-trn-doc.internal) then do:
         return error substitute ("Товар : &1 &2 имеет штучную единицу измерения поставщика &3 Количество в единицах поставщика &4.",
                cw-goods.artic,
                cw-goods.gds-name,
                cw-doc-line.unit-cli,
                parcli-qnty).
      end.
      else do:
        if not parrecalc then do:
          return error substitute ("Товар : &1 &2 имеет штучную единицу измерения поставщика &3 Количество в единицах поставщика &4",
                        cw-goods.artic,
                        cw-goods.gds-name,
                        cw-doc-line.unit-cli,
                        parcli-qnty).
        end.
        else do:
            assign cw-doc-line.unit-cli      =  cw-goods.unit-base
                   cw-doc-line.cli-qnty      =  cw-doc-line.cli-qnty * cw-doc-line.cli-base-rate
                   cw-doc-line.price-cli     =  cw-doc-line.price-cli / cw-doc-line.cli-base-rate
                   cw-doc-line.cli-base-rate = 1.
            /*Все равно следует пересчитать цены, т.к. цена округляется при делении на cli-base-rate*/
            run str/rc-price.p (input recid(cw-doc-line)) no-error.
            return  " Изменены единицы измерения поставщика на: " + string (cw-doc-line.unit-cli) + " ".
        end.
      end.
   end.
end.
/*Если кол-во в базовых единицах товара получается дробное, то ошибка.*/
if lookup({&pieces}, cw-base-units.type) > 0  and
   trunc (pardoc-qnty, 0) <> pardoc-qnty
then do:
    return error substitute("Базовая единица товара &1  - штучная. Кол-во по документу должно быть целым.",
                            cw-goods.unit-base).
end.
if lookup({&pieces}, cw-base-units.type) > 0  and
   trunc(parfact-qnty, 0) <> parfact-qnty
then do:
    return error substitute ("Базовая единица товара &1 - штучная. Кол-во по факту должно быть целым.", cw-goods.unit-base).
end.
end procedure.

/* создание признака */
procedure lib-trn_crgdsdtl:
define input parameter parobj-code  like ub.clients.obj-code  no-undo.
define input parameter parobj-type  like ub.clients.obj-type  no-undo.
define input parameter pardoc-code  like ub.trn-doc.doc-code  no-undo.
define input parameter parartic     like ub.goods.artic       no-undo.
define input parameter parprod-code like ub.goods.prod-code   no-undo.
define input parameter parprod-type like ub.goods.prod-type   no-undo.
define input parameter parprt-code  like ub.gds-dtl.prt-code  no-undo.
define input parameter parcheck     as   logical              no-undo.
define variable        varis-new    as   logical              no-undo.
define buffer bf_gds-dtl  for ub.gds-dtl.
define buffer bf_clients  for ub.clients.
define buffer bf_trn-doc  for ub.trn-doc.
define buffer bf_goods    for ub.goods.
define buffer bf_bar-code for ub.bar-code.
do on error undo, return error return-value :
find first bf_gds-dtl where bf_gds-dtl.doc-code   = pardoc-code
                        and bf_gds-dtl.artic      = parartic
                        and bf_gds-dtl.prod-code  = parprod-code
                        and bf_gds-dtl.prod-type  = parprod-type
                        and bf_gds-dtl.prt-code   = parprt-code   no-error.
if not available bf_gds-dtl then do:
   if parcheck = yes then do:
      find first bf_clients where bf_clients.obj-type = parobj-type and
                                  bf_clients.obj-code = parobj-code no-lock no-error.
      if not available bf_clients then do:
         return error subst("Создание признака невозможно. Не найден объект &1 &2.", parobj-type, parobj-code) .
      end.
      find first bf_trn-doc where bf_trn-doc.doc-code = pardoc-code no-lock no-error.
      if not available bf_trn-doc then do:
         return error subst("Создание признака невозможно. Не найден документ &1.", pardoc-code) .
      end.
      if bf_trn-doc.obj-type <> bf_clients.obj-type or
         bf_trn-doc.obj-code <> bf_clients.obj-code then do:
         return error subst("Создание признака невозможно. Документ &1 "
                          + " не принадлежит объекту &2 &3 . ", bf_trn-doc.doc-code, bf_clients.obj-type, bf_clients.obj-code).
      end.
   end.
   find first bf_goods where bf_goods.artic     = parartic     and
                             bf_goods.prod-type = parprod-type and
                             bf_goods.prod-code = parprod-code no-lock no-error.
   if not available bf_goods then do:
      return error subst("Создание признака невозможно. Не найден товар &1 &2 &3.", parartic, parprod-code, parprod-code).
   end.

   tr:
   do transaction on error undo tr, return error return-value :
     { gbl/barcodcr.i
      bf_goods.gds-code
      parprt-code
      "''"
      "''"
      bf_goods.unit-base
      ?
      varis-new
      bf_bar-code
     }
     run check-use-artic in this-procedure ( input "gds-dtl":U,
                                             input parartic,
                                             input parprod-type,
                                             input parprod-code  ) no-error.
     if error-status :error then do:
       undo tr, return error substitute( 'lib-trn_crgdsdtl: &1', return-value ).
     end.
     create bf_gds-dtl.
     assign
       bf_gds-dtl.obj-code      = parobj-code
       bf_gds-dtl.obj-type      = parobj-type
       bf_gds-dtl.doc-code      = pardoc-code
       bf_gds-dtl.artic         = parartic
       bf_gds-dtl.prod-code     = parprod-code
       bf_gds-dtl.prod-type     = parprod-type
       bf_gds-dtl.prt-code      = parprt-code.
   end. /*transaction*/
end. /*not available*/
end.
end procedure.

/* Создание строки документа */
procedure lib-trn_create-doc-line: /*Не вызывается извне данной библиотеки*/
define input parameter parartic     like ub.doc-line.artic     no-undo.
define input parameter parprod-type like ub.doc-line.prod-type no-undo.
define input parameter parprod-code like ub.doc-line.prod-code no-undo.
define input parameter parrec-doc as recid no-undo.
define buffer cd_trn-doc  for ub.trn-doc.
define buffer cd_doc-line for ub.doc-line.
define buffer cd_goods    for ub.goods.
define buffer cd_sysconf  for ub.sysconf.
define buffer cd_gds-obj  for ub.gds-obj.
define variable v-host-code like ub.sysconf.host-code no-undo.
define variable v-cash-pay  like ub.sysconf.cash-pay  no-undo.
define variable varslt-pc   like ub.doc-line.slt-pc   no-undo.
define variable varvat-pc   like ub.doc-line.vat-pc   no-undo.
do on error undo, return error return-value :
find first cd_trn-doc where recid(cd_trn-doc) = parrec-doc.
find first cd_goods where cd_goods.artic     = parartic     and
                          cd_goods.prod-type = parprod-type and
                          cd_goods.prod-code = parprod-code no-lock.
find cd_doc-line where cd_doc-line.doc-code  = cd_trn-doc.doc-code
                   and cd_doc-line.artic     = cd_goods.artic
                   and cd_doc-line.prod-code = cd_goods.prod-code
                   and cd_doc-line.prod-type = cd_goods.prod-type no-error.
if not available cd_doc-line then do:
  { gbl/hostcode.i cd_trn-doc.obj-type cd_trn-doc.obj-code v-host-code }
  find first cd_sysconf where cd_sysconf.host-code = v-host-code no-lock.
  assign
    v-cash-pay = cd_sysconf.cash-pay.
  if cd_sysconf.cons-vat-pc = ? then do:
    return error "У Вас не установлен НДС для консигнационного товара по фирме.".
  end.
   { gbl/pftxvalg.i
     cd_goods.gds-code
     {&vat-tax-code}
     ?
     v-host-code
     cd_trn-doc.obj-type
     cd_trn-doc.obj-code
     varvat-pc
     no-error
   }
   if error-status :error then do:
     message return-value view-as alert-box.
     return error return-value.
   end.

  { str/st-sltpc.i
    recid(cd_goods)
    recid(cd_trn-doc)
    v-cash-pay
    varslt-pc
    no-error
  }
  if error-status :error then do:
    return error return-value.
  end.
  { str/crdoclin.i
    cd_trn-doc.doc-code
    cd_goods.artic
    cd_goods.prod-type
    cd_goods.prod-code
    cd_trn-doc.obj-type
    cd_trn-doc.obj-code
    cd_trn-doc.status_
    cd_trn-doc.ext-doc-type
    cd_goods.prt-root
    varvat-pc
    varslt-pc
    cd_sysconf.cons-vat-pc
    no-error
  }
  if error-status :error then do:
    return error return-value.
  end.
  find first cd_doc-line where cd_doc-line.doc-code  = cd_trn-doc.doc-code and
                               cd_doc-line.artic     = cd_goods.artic      and
                               cd_doc-line.prod-type = cd_goods.prod-type  and
                               cd_doc-line.prod-code = cd_goods.prod-code  exclusive-lock.
  assign
   cd_doc-line.cli-qnty        = 0
   cd_doc-line.doc-qnty        = 0
   cd_doc-line.fact-qnty       = 0

   .


  /* Проверим есть ли gds-obj. Если нет создадим болванку без числовых полей.
     Иначе если по новому товару добавить строку в приходной накладной не
     разбивая ее по шкале gds-obj не создается и строки не видно в browser-е
     приходных накладных*/
  { gbl/gdsobjcr.i
    cd_doc-line.obj-type
    cd_doc-line.obj-code
    cd_doc-line.artic
    cd_doc-line.prod-type
    cd_doc-line.prod-code
    cd_gds-obj
    no-error
    }
  if error-status :error then do:
    undo, return error return-value.
  end.
end.
end. /*do*/
end procedure.

/* Поиск узла дерева для копирования */
procedure lib-trn_lgl-node:
define input  parameter parartic      like ub.gds-dtl.artic     no-undo.
define input  parameter parprod-type  like ub.gds-dtl.prod-type no-undo.
define input  parameter parprod-code  like ub.gds-dtl.prod-code no-undo.
define input  parameter parprt-code   like ub.gds-dtl.prt-code  no-undo.
define input  parameter parobj-type   like ub.trn-doc.obj-type  no-undo.
define input  parameter parobj-code   like ub.trn-doc.obj-code  no-undo.
define output parameter parlegal-node like ub.gds-prt.node-code no-undo.
define variable g-doc-prt as logical no-undo.
define variable v-root-node like ub.gds-prt.node-code no-undo.
do on error undo, return error return-value :

{ gbl/objat.i
  parobj-type
  parobj-code
  "'doc-prt=request'"
  g-doc-prt
}

{ gbl/rootnode.i
    parartic
    parprod-type
    parprod-code
    v-root-node
}
if g-doc-prt              = no  then do:
   assign
     parlegal-node = v-root-node.
end.
else do:
  { gbl/termnode.i
    parprt-code
    parlegal-node
  }
end.
end. /*do*/
end procedure.

/* Копирование разными способами в приходную накладную */
procedure lib-trn_copy-inh :
  define input  parameter parparentproc     as widget-handle no-undo.
  define input  parameter parrec-doc        as recid         no-undo.
  define input  parameter parmode           as character     no-undo.
  define input  parameter parrecalc         as logical       no-undo.
  define input  parameter parrsrv-fact-qnty as logical       no-undo.

  define input parameter table for lib-trn_ret-doc.
  define input parameter table for lib-trn_ret-line.      /* одна запись строки */
  define input parameter table for lib-trn_ret-line-attr.
  define input parameter table for lib-trn_ret-dtl.
  define input parameter table for lib-trn_ret-parts.

  define buffer ca_lib-trn_ret-doc       for lib-trn_ret-doc.
  define buffer ca_lib-trn_ret-line      for lib-trn_ret-line.
  define buffer ca_lib-trn_ret-line-attr for lib-trn_ret-line-attr.
  define buffer ca_lib-trn_ret-dtl       for lib-trn_ret-dtl.
  define buffer ca_lib-trn_ret-parts     for lib-trn_ret-parts.

  define variable varroot-node                   like ub.bar-code.node-code    no-undo.
  define variable delta-line-vat                 like ub.trn-doc.vat-base      no-undo.
  define variable delta-line-slt                 like ub.trn-doc.vat-base      no-undo.
  define variable chg-qnty                       like ub.gds-dtl.doc-qnty      no-undo.
  define variable fix-qnty                       like ub.gds-dtl.doc-qnty      no-undo.
  define variable mem-qnty                       like ub.gds-dtl.doc-qnty      no-undo.
  define variable temp-mes                       as   character                no-undo.
  define variable temp-ok                        as   logical                  no-undo initial yes.
  define variable v-insalepr                     as   logical                  no-undo initial ?.
  define variable parsale-price                  like ub.price-list.price-sale no-undo initial ?.
  define variable varcst-rsrv                    as   character                no-undo.
  define variable varlast-date-rsrv              as   character                no-undo.
  define variable varprice-cli-ca                like ub.doc-line.price-rubl   no-undo.
  define variable varprice-cli-unit-base-ca      like ub.doc-line.price-rubl   no-undo.
  define variable varprice-road-tax-ca           like ub.doc-line.price-rubl   no-undo.
  define variable varprice-other-exp-ca          like ub.doc-line.price-rubl   no-undo.
  define variable varprice-transport-exp-ca      like ub.doc-line.price-rubl   no-undo.
  define variable varprice-without-abs-ca        like ub.doc-line.price-rubl   no-undo.
  define variable varprice-slt-ca                like ub.doc-line.price-rubl   no-undo.
  define variable varprice-no-slt-ca             like ub.doc-line.price-rubl   no-undo.
  define variable varprice-vat-ca                like ub.doc-line.price-rubl   no-undo.
  define variable varprice-no-vat-slt-ca         like ub.doc-line.price-rubl   no-undo.
  define variable varprice-rubl-ca               like ub.doc-line.price-rubl   no-undo.
  define variable varprice-road-tax-rubl-ca      like ub.doc-line.price-rubl   no-undo.
  define variable varprice-other-exp-rubl-ca     like ub.doc-line.price-rubl   no-undo.
  define variable varprice-transport-exp-rubl-ca like ub.doc-line.price-rubl   no-undo.
  define variable varprice-without-abs-rubl-ca   like ub.doc-line.price-rubl   no-undo.
  define variable varprice-slt-rubl-ca           like ub.doc-line.price-rubl   no-undo.
  define variable varprice-no-slt-rubl-ca        like ub.doc-line.price-rubl   no-undo.
  define variable varprice-vat-rubl-ca           like ub.doc-line.price-rubl   no-undo.
  define variable varprice-no-vat-slt-rubl-ca    like ub.doc-line.price-rubl   no-undo.
  define variable varprice-base-ca               like ub.doc-line.price-base   no-undo.
  define variable varprice-road-tax-base-ca      like ub.doc-line.price-base   no-undo.
  define variable varprice-other-exp-base-ca     like ub.doc-line.price-base   no-undo.
  define variable varprice-transport-exp-base-ca like ub.doc-line.price-base   no-undo.
  define variable varprice-without-abs-base-ca   like ub.doc-line.price-base   no-undo.
  define variable varprice-slt-base-ca           like ub.doc-line.price-base   no-undo.
  define variable varprice-no-slt-base-ca        like ub.doc-line.price-base   no-undo.
  define variable varprice-vat-base-ca           like ub.doc-line.price-base   no-undo.
  define variable varprice-no-vat-slt-base-ca    like ub.doc-line.price-base   no-undo.
  define variable varlegal-node                  like ub.gds-prt.node-code     no-undo.
  define variable full-rsrv-qnty                 like ub.gds-dtl.fact-qnty     no-undo.
  define variable conf-par                       as   character                no-undo.
  define variable par-type                       as   character                no-undo.
  define variable g-doc-prt                      as   logical                  no-undo.
  define variable varr-btype                     as   character                no-undo.
  define variable varerr-recalc                  as   logical                  no-undo.
  define variable v-accum-cli-qnty               like ub.doc-line.cli-qnty     no-undo.
  define variable varpart-code-rsrv              as   character              no-undo.
  define variable var_is-petrol                  as   logical                  no-undo.
  define variable var_is-pieces                  as   logical                  no-undo.
  define variable v-density                      like ub.doc-line.fact-density no-undo.
  define variable is-doc-hold                    as   logical                  no-undo.
  define variable l_place-rsrv                   as   logical                  no-undo.
  define variable is_doc-pl_rsrv                 as   logical                  no-undo initial no.
  define variable varpl-inf                      as   character                no-undo.
  define variable v-doc-pl-rowid                 as   rowid                    no-undo.
  define variable v-has-part                     as   logical                  no-undo.
  define variable v-gds-mark       as   logical              no-undo.
  define variable v-gds-attr-value as   character            no-undo.
  define variable v-gds-attr-type  as   character            no-undo.
  define variable v-level          as   integer              no-undo. 
  define variable v-is-in-doc      as   logical              no-undo init no .
  define variable v-program-name   as   character            no-undo.
  { str/get-pr.i def }

  define buffer d-l-b       for ub.doc-line.
  define buffer old-doc     for ub.trn-doc.   /* для всех ПН, скопированных из запроса */
  define buffer old-line    for ub.doc-line.
  define buffer old-dtl     for ub.gds-dtl.
  define buffer ca_trn-doc  for ub.trn-doc.
  define buffer ca_doc-line for ub.doc-line.
  define buffer ca_doc-line-attr for ub.doc-line-attr.
  define buffer ca_gds-dtl  for ub.gds-dtl.
  define buffer ca_parts    for ub.parts.
  define buffer ca_goods    for ub.goods.
  define buffer ca_units    for ub.units.
  define buffer ca_gds-prt  for ub.gds-prt.
  define buffer ca_shop     for ub.shop.
  define buffer ca_store    for ub.store.
  define buffer ca_doc-pl   for ub.doc-pl.
  define buffer bf_parts    for ub.parts.
  define buffer ca_clients  for ub.clients.
  define buffer bf_trn-doc  for ub.trn-doc.
do
on error undo, return error return-value
:

  if not can-do ("cr-upd,copy", parmode) then do:
    return error "Некорректный параметр parmode передан процедуре lib-trn_copy-inh.".
  end.
  
/* { gbl/curr-r-b.i varr-b } 12/II-2019 - вынесено в main-block */
  
find first ca_trn-doc where recid(ca_trn-doc) = parrec-doc.
find first ca_clients where ca_clients.obj-type = ca_trn-doc.obj-type and
                            ca_clients.obj-code = ca_trn-doc.obj-code no-lock no-error.

if ca_trn-doc.out-code <> "" and ca_trn-doc.out-code <> ? then do:
  find first bf_trn-doc where bf_trn-doc.doc-code = ca_trn-doc.out-code no-lock no-error.
end.
find ca_lib-trn_ret-doc.
find ca_lib-trn_ret-line.

{ gbl/hold-doc.i ca_lib-trn_ret-doc.doc-code is-doc-hold no-error }
if error-status :error or is-doc-hold = ? then do: assign is-doc-hold = no. end.
find ca_goods where ca_goods.artic        = ca_lib-trn_ret-line.artic
                and ca_goods.prod-type    = ca_lib-trn_ret-line.prod-type
                and ca_goods.prod-code    = ca_lib-trn_ret-line.prod-code no-lock.
{ str/is-petrl.i
  ca_goods.artic
  ca_goods.prod-type
  ca_goods.prod-code
  var_is-petrol
  var_is-pieces
  no-error
}
if error-status :error then do:
  return error substitute( 'Ошибка при определении атрибута товара "топливо".&1'
                         + 'Артикул &2 &3 &4&1&7&1&8'
                         , {&new-line}
                         , ca_goods.artic
                         , ca_goods.prod-type
                         , ca_goods.prod-code
                         , return-value
                         , error-status :get-message(1)
                         ).
end. /* error */
{ gbl/gdsobjat.i
  ca_trn-doc.obj-type
  ca_trn-doc.obj-code
  ca_goods.artic
  ca_goods.prod-type
  ca_goods.prod-code
  "'place-rsrv=request':U"
  l_place-rsrv
  no-error
}
if error-status :error then do:
  return error substitute( 'Ошибка при определении атрибута товара на объекте.&1'
                         + 'Атрибут &2&1Документ &3&1Артикул &4 &5 &6&1&7&1&8'
                         , {&new-line}
                         , "'place-rsrv=request':U"
                         , ca_lib-trn_ret-doc.doc-code
                         , ca_goods.artic
                         , ca_goods.prod-type
                         , ca_goods.prod-code
                         , return-value
                         , error-status :get-message(1)
                         ).
end. /* error */

RUN gds-attr-value (
                    INPUT ca_goods.gds-code,
                    INPUT {&attr-mark-type},
                    OUTPUT v-gds-attr-value,
                    OUTPUT v-gds-attr-type
                    ).
if v-gds-attr-value > ""
and ObjSrv:Env:ParametrsOfSection:GetSectionEDO(ca_trn-doc.obj-type, ca_trn-doc.obj-code):GetIsMarkingForType(v-gds-attr-value)
then 
  v-gds-mark = true .
else
  v-gds-mark = false .

assign v-level = 2 .  
repeat while program-name( v-level ) <> ? :
  v-program-name = program-name( v-level ) .
  v-is-in-doc = index(v-program-name, "in-doc.") > 0 .
  if v-is-in-doc then leave .
  assign
    v-level = v-level + 1
  .
end.
  
if v-gds-attr-value > ""
and v-is-in-doc
and ca_trn-doc.ext-doc-type = {&TDEDT_Pri_Vnesh}
and ObjSrv:Env:ParametrsOfSection:GetSectionEDO(ca_trn-doc.obj-type, ca_trn-doc.obj-code):IsEDO
and (ObjSrv:Env:ParametrsOfSection:GetSectionEDO(ca_trn-doc.obj-type, ca_trn-doc.obj-code):GetIsArticForType(v-gds-attr-value)
  or ObjSrv:Env:ParametrsOfSection:GetSectionEDO(ca_trn-doc.obj-type, ca_trn-doc.obj-code):GetIsEdoForType(v-gds-attr-value))
then do :
  return error ("Товар:" + ca_goods.artic + " " + ca_goods.prod-type + " " + string(ca_goods.prod-code) + " " + ca_goods.gds-name + " " + {&new-line} +
                "нельзя добавлять в ручном режиме, так как он подлежит маркировке.") .
end .

if l_place-rsrv = yes then do:
  if ca_lib-trn_ret-doc.obj-type = ca_trn-doc.obj-type
    and ca_lib-trn_ret-doc.obj-code = ca_trn-doc.obj-code
  then do:
    assign
      is_doc-pl_rsrv = yes
    .
  end.
  else do:
    assign
      is_doc-pl_rsrv = no
    .
  end.
end.
find first ca_lib-trn_ret-line-attr where ca_lib-trn_ret-line-attr.doc-code  = ca_lib-trn_ret-line.doc-code and
                                          ca_lib-trn_ret-line-attr.gds-code  = ca_goods.gds-code and
                                          ca_lib-trn_ret-line-attr.attr-code = {&rsrv-dtl_cst-code}        no-error.
if available ca_lib-trn_ret-line-attr                  and
             ca_lib-trn_ret-line-attr.attr-value <> ?  and
             ca_lib-trn_ret-line-attr.attr-value <> "" then do:
   assign varcst-rsrv = "," + {&rsrv-dtl_cst-code} + "=":u + str-encode (ca_lib-trn_ret-line-attr.attr-value,  "", ",=":u ).
end.
else varcst-rsrv = "".

find first ca_lib-trn_ret-line-attr where ca_lib-trn_ret-line-attr.doc-code  = ca_lib-trn_ret-line.doc-code and
                                          ca_lib-trn_ret-line-attr.gds-code  = ca_goods.gds-code and
                                          ca_lib-trn_ret-line-attr.attr-code = {&rsrv-dtl_last-date}        no-error.
if available ca_lib-trn_ret-line-attr                  and
             ca_lib-trn_ret-line-attr.attr-value <> ?  and
             ca_lib-trn_ret-line-attr.attr-value <> "" then do:
   assign varlast-date-rsrv = "," + {&rsrv-dtl_last-date} + "=":u + str-encode (ca_lib-trn_ret-line-attr.attr-value,  "", ",=":u ).
end.
else varlast-date-rsrv = "".

for each  ca_lib-trn_ret-line-attr where ca_lib-trn_ret-line-attr.doc-code  = ca_lib-trn_ret-line.doc-code and
                                         ca_lib-trn_ret-line-attr.gds-code  = ca_goods.gds-code :
   find first  ca_doc-line-attr no-lock where
               ca_doc-line-attr.doc-code  = ca_trn-doc.doc-code and
               ca_doc-line-attr.gds-code  = ca_goods.gds-code and
               ca_doc-line-attr.attr-code = ca_lib-trn_ret-line-attr.attr-code no-error .
   if not available ca_doc-line-attr then do:
      create ca_doc-line-attr.
      buffer-copy ca_lib-trn_ret-line-attr to  ca_doc-line-attr
          assign   ca_doc-line-attr.doc-code = ca_trn-doc.doc-code
      .
   end.
end.


/* Установка кода партии для алкогольной продукции */
if ca_lib-trn_ret-line.part-code <> ?  and
   ca_lib-trn_ret-line.part-code <> "" then do:
  assign
    varpart-code-rsrv = "," + {&rsrv-dtl_cre-part-code} + "=":u
                      + str-encode (ca_lib-trn_ret-line.part-code, "", ",=":u )
  .
end.
else do:
  varpart-code-rsrv = "".
end.

find ca_gds-prt where ca_gds-prt.upper-code = ca_goods.prt-root  no-lock.
find ca_units   where ca_units.unit-name    = ca_goods.unit-base no-lock.
run lib-trn_create-doc-line in this-procedure
  ( input ca_lib-trn_ret-line.artic
   , input ca_lib-trn_ret-line.prod-type
   , input ca_lib-trn_ret-line.prod-code
   , input recid(ca_trn-doc)
  ) no-error.
if error-status :error then do:
  undo, return error return-value.
end.
find first ca_doc-line
  where ca_doc-line.doc-code  = ca_trn-doc.doc-code
    and ca_doc-line.artic     = ca_lib-trn_ret-line.artic
    and ca_doc-line.prod-type = ca_lib-trn_ret-line.prod-type
    and ca_doc-line.prod-code = ca_lib-trn_ret-line.prod-code
  .

assign
  ca_doc-line.prt-OK   = ca_lib-trn_ret-line.prt-OK
  ca_doc-line.prt-root = ca_goods.prt-root.
/*----------------------------------------------------------*/
/* В случае копирования из внешней приходной накладной      */
/* во внешнюю приходную накладную сохраняем ее составляющие.*/
/*----------------------------------------------------------*/
if ca_lib-trn_ret-doc.doc-type = {&income}
  and ca_lib-trn_ret-doc.internal = false
then do:
  assign
     ca_doc-line.unit-cli       = ca_lib-trn_ret-line.unit-cli
     ca_doc-line.cli-base-rate  = ca_lib-trn_ret-line.cli-base-rate
     ca_doc-line.temperature    = ca_lib-trn_ret-line.temperature
     ca_doc-line.num-place      = ca_lib-trn_ret-line.num-place
     ca_doc-line.wt-brutto      = ca_lib-trn_ret-line.wt-brutto
     ca_doc-line.new-price-sale = ca_lib-trn_ret-line.new-price-sale
     ca_doc-line.vat-pc         = ca_lib-trn_ret-line.vat-pc
     ca_doc-line.slt-pc         = if ca_trn-doc.slt-type = {&without-slt} then 0 else ca_lib-trn_ret-line.slt-pc.
end.
else do:
  assign
     ca_doc-line.unit-cli       = ca_lib-trn_ret-line.unit-cli
     ca_doc-line.cli-base-rate  = ca_lib-trn_ret-line.cli-base-rate
   .
end.

/* Если копируем из межфирменного перемещения, то следует сохранить НДС и НП */
if ca_lib-trn_ret-doc.doc-type = {&expense} and
   not ca_lib-trn_ret-doc.internal          and
   not (ca_lib-trn_ret-doc.hold-doc-code-child = ""       or
        ca_lib-trn_ret-doc.hold-doc-code-child = "no-hold")
   then do:
  assign
    ca_doc-line.vat-pc        = ca_lib-trn_ret-line.vat-pc
    ca_doc-line.slt-pc        = if ca_trn-doc.slt-type = {&without-slt} then 0 else ca_lib-trn_ret-line.slt-pc.
end.

if lookup({&serial}, ca_units.type) > 0 then do:
   assign
   ca_doc-line.price-cli     = ca_lib-trn_ret-line.price-cli
   ca_doc-line.price-base    = ca_lib-trn_ret-line.price-base
   ca_doc-line.price-rubl    = ca_lib-trn_ret-line.price-rubl
   ca_doc-line.road-tax      = ca_lib-trn_ret-line.road-tax
   ca_doc-line.excise        = ca_lib-trn_ret-line.excise.
   if parmode = "cr-upd" then do:
     assign
     ca_doc-line.cli-qnty      = ca_lib-trn_ret-line.cli-qnty
     ca_doc-line.fact-qnty     = ca_lib-trn_ret-line.fact-qnty
     ca_doc-line.doc-qnty      = ca_lib-trn_ret-line.doc-qnty.
  end.
end.
/* Несерийный товар */
else do:
  /* Проставляем количества в случае создания-редактирования */
  if parmode = "cr-upd" then do:
   assign
     ca_doc-line.cli-qnty      = ca_lib-trn_ret-line.cli-qnty
     ca_doc-line.fact-qnty     = ca_lib-trn_ret-line.fact-qnty
     ca_doc-line.doc-qnty      = ca_lib-trn_ret-line.doc-qnty
     ca_doc-line.doc-density   = ca_lib-trn_ret-line.doc-density
     ca_doc-line.fact-density  = ca_lib-trn_ret-line.fact-density
   .
  end.
  else do:
    if not (ca_lib-trn_ret-doc.status_ = "temp" and ca_trn-doc.flag_) then do:
      if l_place-rsrv = yes
        and var_is-petrol = true
        and var_is-pieces = false
      then do:
        assign
          ca_doc-line.doc-density  = (if parrsrv-fact-qnty then ca_lib-trn_ret-line.fact-density else ca_lib-trn_ret-line.doc-density)
          ca_doc-line.fact-density = ca_doc-line.doc-density
        .
        if valid-density( ca_doc-line.doc-density, (ca_goods.unit-base = ca_goods.unit-cli) ) <> true then do:
          undo, return error substitute( "Плотность в документе источнике имеет некорректное значение &1.", v-density ) .
        end.
        assign
          ca_doc-line.unit-cli      = ca_goods.unit-cli
          ca_doc-line.cli-base-rate = 1 / ca_doc-line.doc-density
        .
      end.
      if ca_lib-trn_ret-doc.doc-type = {&income}
        and ca_lib-trn_ret-doc.internal = false
      then do:
        assign
          ca_doc-line.doc-qnty      = ca_doc-line.doc-qnty + (if parrsrv-fact-qnty then ca_lib-trn_ret-line.fact-qnty else ca_lib-trn_ret-line.doc-qnty)
          ca_doc-line.fact-qnty     = ca_doc-line.doc-qnty
        .
      end.
      else do:
        ca_doc-line.prt-ok      = yes.
      end.
      assign
        ca_doc-line.cli-qnty = ca_doc-line.cli-qnty +
                               ( if parrsrv-fact-qnty = yes
                                 then ca_lib-trn_ret-line.fact-qnty / ca_lib-trn_ret-line.cli-base-rate
                                 else ca_lib-trn_ret-line.doc-qnty  / ca_lib-trn_ret-line.cli-base-rate ).
    end.
  end.
  /* Иногда количества следует подкорректировать */
  if ca_doc-line.doc-qnty = ? then do:
     assign
      ca_doc-line.doc-qnty = 0.
  end.
  /* Проставляем цены */
  if ca_lib-trn_ret-doc.doc-type = {&income}
    and ca_lib-trn_ret-doc.internal = false
  then do:
   { gbl/gdsobjat.i
     ca_trn-doc.obj-type
     ca_trn-doc.obj-code
     ca_goods.artic
     ca_goods.prod-type
     ca_goods.prod-code
     "'insalepr=request'":U
     v-insalepr
     no-error
   }
   if error-status:error then do :
     v-insalepr = false .
   end .
   /* Приемка по продажной цене */
   if v-insalepr = true then do:
      { str/get-pr.i
        calc
        ca_trn-doc.obj-type
        ca_trn-doc.obj-code
        ca_goods.gds-code
        ca_gds-prt.node-code
        "undo, return error return-value."
      }
      if gp-price-sale = ? then do:
           undo, return error substitute ("Не могу найти продажную цену для товара: &1 &2 &3 &4.", ca_goods.artic, ca_goods.prod-type, ca_goods.prod-code, ca_goods.gds-name).
      end.
      else do:
        ASSIGN
          ca_doc-line.price-cli  = gp-price-sale * (IF g-varr-b = "base":u THEN ca_trn-doc.base-rate / ca_trn-doc.base-scale else 1)
                               / ca_trn-doc.exch-rate * ca_trn-doc.exch-scale * ca_doc-line.cli-base-rate
          ca_doc-line.price-base = gp-price-sale / (IF g-varr-b = "base":u THEN 1 else ca_trn-doc.base-rate * ca_trn-doc.base-scale)
          ca_doc-line.price-rubl = gp-price-sale * (IF g-varr-b = "base":u THEN ca_trn-doc.base-rate / ca_trn-doc.base-scale else 1)
          ca_doc-line.road-tax   = gp-road-tax
          ca_doc-line.excise     = gp-excise.
      end.
   end.
   /* берем цену из копируемого товара или из любого признака */
   else  do:
     if ca_doc-line.cli-base-rate <> 1 then do:
       if ca_lib-trn_ret-line.cli-base-rate <> ? and
          ca_lib-trn_ret-line.cli-base-rate <> 0 then do:
         assign
           ca_doc-line.price-cli  = ca_lib-trn_ret-line.price-cli * ca_doc-line.cli-base-rate / ca_lib-trn_ret-line.cli-base-rate.
       end.
       else do:
        assign
           ca_doc-line.price-cli  = ca_lib-trn_ret-line.price-cli * ca_doc-line.cli-base-rate.
       end.
     end.
     else do:
       assign
         ca_doc-line.price-cli  = ca_lib-trn_ret-line.price-cli.
     end.
     assign
       ca_doc-line.price-base = ca_lib-trn_ret-line.price-base
       ca_doc-line.price-rubl = ca_lib-trn_ret-line.price-rubl
       ca_doc-line.road-tax   = ca_lib-trn_ret-line.road-tax
       ca_doc-line.excise     = ca_lib-trn_ret-line.excise.
   end.
   /* Распространяем ее по price-base, price-rubl
      или по price-cli в случае двуедизмов */
   { str/in-vat.i
      ca_trn-doc.doc-code
      ca_trn-doc.base-rate
      ca_trn-doc.base-scale
      ca_trn-doc.exch-rate
      ca_trn-doc.exch-scale
      ca_trn-doc.vat-type
      ca_trn-doc.slt-type
      ca_doc-line.artic
      ca_doc-line.prod-type
      ca_doc-line.prod-code
      ca_doc-line.price-cli
      ca_doc-line.cli-base-rate
      ca_doc-line.price-rubl
      ca_doc-line.vat-pc
      ca_doc-line.slt-pc
      ca_doc-line.road-tax
      ca_doc-line.transport-rubl
      ca_doc-line.other-rubl
      varprice-cli-ca
      varprice-cli-unit-base-ca
      varprice-road-tax-ca
      varprice-other-exp-ca
      varprice-transport-exp-ca
      varprice-without-abs-ca
      varprice-slt-ca
      varprice-no-slt-ca
      varprice-vat-ca
      varprice-no-vat-slt-ca
      varprice-rubl-ca
      varprice-road-tax-rubl-ca
      varprice-other-exp-rubl-ca
      varprice-transport-exp-rubl-ca
      varprice-without-abs-rubl-ca
      varprice-slt-rubl-ca
      varprice-no-slt-rubl-ca
      varprice-vat-rubl-ca
      varprice-no-vat-slt-rubl-ca
      varprice-base-ca
      varprice-road-tax-base-ca
      varprice-other-exp-base-ca
      varprice-transport-exp-base-ca
      varprice-without-abs-base-ca
      varprice-slt-base-ca
      varprice-no-slt-base-ca
      varprice-vat-base-ca
      varprice-no-vat-slt-base-ca
      no-error
    }
    if error-status :error then do:
      undo, return error return-value.
    end.
    assign
     ca_doc-line.price-cli  = varprice-cli-ca
     ca_doc-line.price-rubl = varprice-rubl-ca
     ca_doc-line.price-base = varprice-base-ca.
  end.
  { gbl/conf-rd.i
    "'is-prt':u"
    0
    "'':u"
    0
    "'':u"
    "'':u"
    "'':u"
    yes
    conf-par
    par-type
    no-error
  }
  if ca_trn-doc.obj-type = {&shop} then do:
     find first ca_shop where ca_shop.obj-code = ca_trn-doc.obj-code no-lock.
     if conf-par = "yes" and
        ca_shop.doc-prt  then do:
       assign
       g-doc-prt = yes.
     end.
     else do:
       assign
       g-doc-prt = no.
     end.
  end.
  else do:
    find first ca_store where ca_store.obj-code = ca_trn-doc.obj-code no-lock.
    if conf-par = "yes" and
       ca_store.doc-prt  then do:
      assign
      g-doc-prt = yes.
    end.
    else do:
      assign
      g-doc-prt = no.
    end.
  end.
  /* Создание корневого признака */

  if parmode = "cr-upd" then do:
    assign varlegal-node = ca_gds-prt.node-code.
    if (ca_gds-prt.node-name = {&empty-scale} or not g-doc-prt) then do:
       find ca_gds-dtl where ca_gds-dtl.doc-code   = ca_trn-doc.doc-code
                         and ca_gds-dtl.artic      = ca_goods.artic
                         and ca_gds-dtl.prod-code  = ca_goods.prod-code
                         and ca_gds-dtl.prod-type  = ca_goods.prod-type
                         and ca_gds-dtl.prt-code   = varlegal-node no-error.
       if not available ca_gds-dtl then do:
         { str/crgdsdtl.i
           ca_trn-doc.obj-code
           ca_trn-doc.obj-type
           ca_trn-doc.doc-code
           ca_goods.artic
           ca_goods.prod-code
           ca_goods.prod-type
           varlegal-node
           yes
           no-error
         }
         if error-status :error then do:
            return error return-value.
         end.
         find first ca_gds-dtl where ca_gds-dtl.doc-code  = ca_trn-doc.doc-code and
                                     ca_gds-dtl.artic     = ca_goods.artic         and
                                     ca_gds-dtl.prod-code = ca_goods.prod-code     and
                                     ca_gds-dtl.prod-type = ca_goods.prod-type     and
                                     ca_gds-dtl.prt-code  = varlegal-node.
         assign
             ca_gds-dtl.doc-qnty      = 0
             ca_gds-dtl.fact-qnty     = 0.
        end.

        if is_doc-pl_rsrv = yes then do:
          /* подчистим партии созданные по местам хранения которые стали невостребованными в данном документе */
          for each ca_parts no-lock
            where ca_parts.obj-type  = ca_trn-doc.obj-type
              and ca_parts.obj-code  = ca_trn-doc.obj-code
              and ca_parts.artic     = ca_goods.artic
              and ca_parts.prod-type = ca_goods.prod-type
              and ca_parts.prod-code = ca_goods.prod-code
              and ca_parts.in-code   = ca_trn-doc.doc-code
              and ca_parts.out-code  = ca_trn-doc.doc-code
          on error undo, return error return-value
          :
            find first ca_doc-pl no-lock
              where ca_doc-pl.obj-type = ca_parts.obj-type
                and ca_doc-pl.obj-code = ca_parts.obj-code
                and ca_doc-pl.out-code = ca_trn-doc.doc-code
                and ca_doc-pl.gds-code = ca_goods.gds-code
                and ca_doc-pl.pl-code  = ca_parts.pl-code
              no-error .
            if not available ca_doc-pl then do:
              assign
                chg-qnty = 0.0 - ca_parts.fact-qnty
                mem-qnty = chg-qnty
              .
              run trg/rsrv-dtl.p
                ( input        parparentproc,
                  input        {&rsrv-dtl_action_reserv}
                              + ( /* При добавлении и изменении строки ГТД должно дублироваться во все дорезервируемые партии */

                                  if ca_lib-trn_ret-line.cst-code <> ? and ca_lib-trn_ret-line.cst-code <> ""
                                  then "," + {&rsrv-dtl_cst-code} + "=":u + str-encode( ca_lib-trn_ret-line.cst-code, "", ",=":u )
                                  else ""
                                )
                              + "," + {&rsrv-dtl_cli-qnty}      + "=":U + string( 0 )
                              + "," + {&rsrv-dtl_cre-part-code} + "=":U + string( ca_parts.pl-code  )
                              + "," + {&rsrv-dtl_pl-code}       + "=":U + string( ca_parts.pl-code  )
                              ,
                  buffer       ca_gds-dtl,
                  input-output chg-qnty,
                  input-output ca_doc-line.price-base,
                  input-output ca_doc-line.price-rubl,
                  input        -1,
                  input        if v-gds-mark then ("copy-ret" + {&delim-par} + ca_lib-trn_ret-doc.doc-code) else ""
                ) no-error.
              if error-status :error
                or chg-qnty <> mem-qnty
              then do:
                undo, return error return-value.
              end.
            end.
          end.
          /* создадим новые партии по местам хранения */
          for each ca_doc-pl no-lock
            where ca_doc-pl.obj-type = ca_doc-line.obj-type
              and ca_doc-pl.obj-code = ca_doc-line.obj-code
              and ca_doc-pl.out-code = ca_doc-line.doc-code
              and ca_doc-pl.gds-code = ca_goods.gds-code
            break by ca_doc-pl.pl-code
          on error undo, return error return-value
          : /* создадим (откорректируем) партии по местам хранения */
            find first ca_parts no-lock
              where ca_parts.obj-type  = ca_trn-doc.obj-type
                and ca_parts.obj-code  = ca_trn-doc.obj-code
                and ca_parts.artic     = ca_goods.artic
                and ca_parts.prod-type = ca_goods.prod-type
                and ca_parts.prod-code = ca_goods.prod-code
                and ca_parts.in-code   = ca_trn-doc.doc-code
                and ca_parts.out-code  = ca_trn-doc.doc-code
                and ca_parts.pl-code   = ca_doc-pl.pl-code
              no-error.
            assign
              chg-qnty = ( if ca_trn-doc.flag_ = yes then ca_doc-pl.fact-qnty else ca_doc-pl.doc-qnty )
                         - ( if available ca_parts then ca_parts.fact-qnty else 0.00 )
              mem-qnty = chg-qnty
            .
            run trg/rsrv-dtl.p
              ( input        parparentproc,
                input        {&rsrv-dtl_action_reserv}
                            + ( /* При добавлении и изменении строки ГТД должно дублироваться во все дорезервируемые партии */

                                if ca_lib-trn_ret-line.cst-code <> ? and ca_lib-trn_ret-line.cst-code <> ""
                                then "," + {&rsrv-dtl_cst-code} + "=":u + str-encode( ca_lib-trn_ret-line.cst-code, "", ",=":u )
                                else ""
                              )
                            + "," + {&rsrv-dtl_cli-qnty}      + "=":U + string( ca_doc-pl.cli-qnty )
                            + "," + {&rsrv-dtl_cre-part-code} + "=":U + string( ca_doc-pl.pl-code  )
                            + "," + {&rsrv-dtl_pl-code}       + "=":U + string( ca_doc-pl.pl-code  )
                            ,
                buffer       ca_gds-dtl,
                input-output chg-qnty,
                input-output ca_doc-line.price-base,
                input-output ca_doc-line.price-rubl,
                input        -1,
                input        if v-gds-mark then ("copy-ret" + {&delim-par} + ca_lib-trn_ret-doc.doc-code) else ""
              ) no-error.
            if error-status :error
              or chg-qnty <> mem-qnty
            then do:
              undo, return error return-value.
            end.
          end. /* for each ca_doc-pl */

          for each ca_doc-pl no-lock
            where ca_doc-pl.obj-type = ca_trn-doc.obj-type
              and ca_doc-pl.obj-code = ca_trn-doc.obj-code
              and ca_doc-pl.out-code = ca_trn-doc.doc-code
              and ca_doc-pl.gds-code = ca_goods.gds-code
            break by ca_doc-pl.pl-code
          on error undo, return error return-value
          : /* проверим партии по местам хранения */
            find first ca_parts no-lock
              where ca_parts.obj-type  = ca_doc-pl.obj-type
                and ca_parts.obj-code  = ca_doc-pl.obj-code
                and ca_parts.artic     = ca_goods.artic
                and ca_parts.prod-type = ca_goods.prod-type
                and ca_parts.prod-code = ca_goods.prod-code
                and ca_parts.in-code   = ca_trn-doc.doc-code
                and ca_parts.out-code  = ca_trn-doc.doc-code
                and ca_parts.pl-code   = ca_doc-pl.pl-code
              no-error.
            if available ca_parts then do:
              find first bf_parts no-lock
                where bf_parts.obj-type  =  ca_parts.obj-type
                  and bf_parts.obj-code  =  ca_parts.obj-code
                  and bf_parts.artic     =  ca_parts.artic
                  and bf_parts.prod-type =  ca_parts.prod-type
                  and bf_parts.prod-code =  ca_parts.prod-code
                  and bf_parts.in-code   =  ca_parts.in-code
                  and bf_parts.out-code  =  ca_parts.out-code
                  and bf_parts.part-code <> ca_parts.part-code
                  and bf_parts.pl-code   =  ca_parts.pl-code
                no-error.
              if available bf_parts then do:
                undo, return error substitute ("Найдены две партии товара &1 &2 &3 привязанные к одному месту хранения &4.", ca_goods.artic, ca_goods.prod-type, ca_goods.prod-code, ca_doc-pl.pl-code).
              end.
            end.
            else do:
              find first bf_parts no-lock
                where bf_parts.obj-type  = ca_trn-doc.obj-type
                  and bf_parts.obj-code  = ca_trn-doc.obj-code
                  and bf_parts.artic     = ca_goods.artic
                  and bf_parts.prod-type = ca_goods.prod-type
                  and bf_parts.prod-code = ca_goods.prod-code
                  and bf_parts.in-code   = ca_trn-doc.doc-code
                  and bf_parts.out-code  = ca_trn-doc.doc-code
                no-error.
              if available bf_parts
                and ( bf_parts.pl-code = 0
                      or bf_parts.pl-code = ?
                    )
              then do:
                undo, return error substitute ("Обнаружены партии по товару &1 &2 &3 не привязанные к месту хранения!!!", ca_goods.artic, ca_goods.prod-type, ca_goods.prod-code).
              end.
            end.
          end.
        end.
        else do:
          assign
            chg-qnty = (if ca_trn-doc.flag_ then (ca_doc-line.fact-qnty - ca_gds-dtl.fact-qnty) else (ca_doc-line.doc-qnty - ca_gds-dtl.doc-qnty))
            mem-qnty = chg-qnty
          .
          run trg/rsrv-dtl.p
            ( input parparentproc
             ,input {&rsrv-dtl_action_reserv}
                    + ( /* При добавлении и изменении строки ГТД должно дублироваться во все дорезервируемые партии */
                        if ca_lib-trn_ret-line.cst-code <> ? and ca_lib-trn_ret-line.cst-code <> "" then "," + {&rsrv-dtl_cst-code} + "=":u + str-encode (ca_lib-trn_ret-line.cst-code,  "", ",=":u ) else "")
                        + "," + {&rsrv-dtl_cli-qnty} + "=":u + string(ca_doc-line.cli-qnty)
                        + varpart-code-rsrv
             ,buffer ca_gds-dtl
             ,input-output chg-qnty
             ,input-output ca_doc-line.price-base
             ,input-output ca_doc-line.price-rubl
             ,input -1
             ,input if v-gds-mark then ("copy-ret" + {&delim-par} + ca_lib-trn_ret-doc.doc-code) else ""
            ) no-error.
          if error-status :error
            or chg-qnty <> mem-qnty
          then do:
            undo, return error return-value.
          end.
        end.
        assign
          ca_gds-dtl.doc-qnty     = ca_doc-line.doc-qnty
          ca_gds-dtl.fact-qnty    = ca_doc-line.fact-qnty
          ca_doc-line.prt-OK      = yes
        .
    end.
  end.
  else do:
    for each ca_lib-trn_ret-dtl no-lock
      where ca_lib-trn_ret-dtl.prod-type = ca_goods.prod-type
        and ca_lib-trn_ret-dtl.prod-code = ca_goods.prod-code
        and ca_lib-trn_ret-dtl.artic     = ca_goods.artic
        and ca_lib-trn_ret-dtl.doc-code  = ca_lib-trn_ret-line.doc-code
      break by ca_lib-trn_ret-dtl.prod-type
            by ca_lib-trn_ret-dtl.prod-code
            by ca_lib-trn_ret-dtl.artic
    on error undo, return error return-value
    :
       if ca_doc-line.price-cli = 0 or ca_doc-line.price-cli = ? then do:
         /* берем цену из копируемого товара или из любого признака */
         if ca_lib-trn_ret-doc.doc-type = {&income} and
            not ca_lib-trn_ret-doc.internal then do:
            if lookup({&twounit}, ca_units.type) = 0 then do:
              assign
              ca_doc-line.price-cli  = ca_lib-trn_ret-line.price-cli.
            end.
            else do:
              assign
              ca_doc-line.price-base = ca_lib-trn_ret-line.price-base
              ca_doc-line.price-rubl = ca_lib-trn_ret-line.price-rubl.
            end.
            assign
              ca_doc-line.road-tax   = ca_lib-trn_ret-line.road-tax
              ca_doc-line.excise     = ca_lib-trn_ret-line.excise.
         end. /*вешний приход*/
         else do:
           /*работаем в р_ублях*/
           if ca_trn-doc.exch-code           = 0 and
              (ca_lib-trn_ret-dtl.price-rubl - ca_lib-trn_ret-dtl.discnt-rubl) <> 0 and
              (ca_lib-trn_ret-dtl.price-rubl - ca_lib-trn_ret-dtl.discnt-rubl) <> ? then do:
              assign
                ca_doc-line.price-cli = (ca_lib-trn_ret-dtl.price-rubl - ca_lib-trn_ret-dtl.discnt-rubl - (if g-varr-b = "rubl" then ca_lib-trn_ret-line.road-tax else ca_lib-trn_ret-line.road-tax * ca_trn-doc.base-rate / ca_trn-doc.base-scale)) * ca_doc-line.cli-base-rate.
                ca_doc-line.road-tax  = ca_lib-trn_ret-line.road-tax.
           end.
           else do:
             /*А это в базовой валюте*/
             if ca_trn-doc.exch-code  = ca_lib-trn_ret-doc.exch-code                  and
                ca_lib-trn_ret-doc.exch-code   <> 0                                   and
                (ca_lib-trn_ret-dtl.price-base - ca_lib-trn_ret-dtl.discnt-base) <> 0 and
                (ca_lib-trn_ret-dtl.price-base - ca_lib-trn_ret-dtl.discnt-base) <> ? then do:
                assign
                  ca_doc-line.price-cli = (ca_lib-trn_ret-dtl.price-base - ca_lib-trn_ret-dtl.discnt-base - (if g-varr-b = "base" then ca_lib-trn_ret-line.road-tax else ca_lib-trn_ret-line.road-tax / ca_trn-doc.base-rate * ca_trn-doc.base-scale)) * ca_doc-line.cli-base-rate.
                  ca_doc-line.road-tax  = ca_lib-trn_ret-line.road-tax.
             end.
           end.
         end.
         { str/in-vat.i
            ca_trn-doc.doc-code
            ca_trn-doc.base-rate
            ca_trn-doc.base-scale
            ca_trn-doc.exch-rate
            ca_trn-doc.exch-scale
            ca_trn-doc.vat-type
            ca_trn-doc.slt-type
            ca_doc-line.artic
            ca_doc-line.prod-type
            ca_doc-line.prod-code
            ca_doc-line.price-cli
            ca_doc-line.cli-base-rate
            ca_doc-line.price-rubl
            ca_doc-line.vat-pc
            ca_doc-line.slt-pc
            ca_doc-line.road-tax
            ca_doc-line.transport-rubl
            ca_doc-line.other-rubl
            varprice-cli-ca
            varprice-cli-unit-base-ca
            varprice-road-tax-ca
            varprice-other-exp-ca
            varprice-transport-exp-ca
            varprice-without-abs-ca
            varprice-slt-ca
            varprice-no-slt-ca
            varprice-vat-ca
            varprice-no-vat-slt-ca
            varprice-rubl-ca
            varprice-road-tax-rubl-ca
            varprice-other-exp-rubl-ca
            varprice-transport-exp-rubl-ca
            varprice-without-abs-rubl-ca
            varprice-slt-rubl-ca
            varprice-no-slt-rubl-ca
            varprice-vat-rubl-ca
            varprice-no-vat-slt-rubl-ca
            varprice-base-ca
            varprice-road-tax-base-ca
            varprice-other-exp-base-ca
            varprice-transport-exp-base-ca
            varprice-without-abs-base-ca
            varprice-slt-base-ca
            varprice-no-slt-base-ca
            varprice-vat-base-ca
            varprice-no-vat-slt-base-ca
            no-error
         }
         if error-status :error then do:
           undo, return error return-value.
         end.
         assign
           ca_doc-line.price-cli  = varprice-cli-ca
           ca_doc-line.price-rubl = varprice-rubl-ca
           ca_doc-line.price-base = varprice-base-ca.
       end. /*простановка цены*/
       if ca_trn-doc.status_ = {&wayb} and
          ca_doc-line.price-cli = ? then do:
          undo, return error substitute ("Артикул : &1 &2 Цена не может быть определена !", ca_goods.artic, ca_goods.gds-name).
       end.
       { str/lgl-node.i
          ca_lib-trn_ret-dtl.artic
          ca_lib-trn_ret-dtl.prod-type
          ca_lib-trn_ret-dtl.prod-code
          ca_lib-trn_ret-dtl.prt-code
          ca_trn-doc.obj-type
          ca_trn-doc.obj-code
          varlegal-node
          no-error
       }
       if error-status :error then return error return-value.
       find ca_gds-dtl where ca_gds-dtl.doc-code   = ca_trn-doc.doc-code
                         and ca_gds-dtl.artic      = ca_goods.artic
                         and ca_gds-dtl.prod-code  = ca_goods.prod-code
                         and ca_gds-dtl.prod-type  = ca_goods.prod-type
                         and ca_gds-dtl.prt-code   = varlegal-node no-error.
       if not available ca_gds-dtl then do:
         { str/crgdsdtl.i
           ca_trn-doc.obj-code
           ca_trn-doc.obj-type
           ca_trn-doc.doc-code
           ca_goods.artic
           ca_goods.prod-code
           ca_goods.prod-type
           varlegal-node
           yes
           no-error
         }
         if error-status :error then do:
            return error return-value.
         end.
         find first ca_gds-dtl where ca_gds-dtl.doc-code  = ca_trn-doc.doc-code and
                                     ca_gds-dtl.artic     = ca_goods.artic      and
                                     ca_gds-dtl.prod-code = ca_goods.prod-code  and
                                     ca_gds-dtl.prod-type = ca_goods.prod-type  and
                                     ca_gds-dtl.prt-code  = varlegal-node.
         assign
           ca_gds-dtl.doc-qnty      = 0
           ca_gds-dtl.fact-qnty     = 0.
       end. /*создание признака*/
       /*----------------------------------------------------------------------------------*/
       /*                      Резервирование при копировании                              */
       /*----------------------------------------------------------------------------------*/
        if is_doc-pl_rsrv = yes then do:
          if first-of(ca_lib-trn_ret-dtl.artic) then do:
            assign
              full-rsrv-qnty = 0
            .
            for each ca_lib-trn_ret-parts no-lock
              where ca_lib-trn_ret-parts.out-code  = ca_lib-trn_ret-dtl.doc-code
                and ca_lib-trn_ret-parts.obj-type  = ca_lib-trn_ret-dtl.obj-type
                and ca_lib-trn_ret-parts.obj-code  = ca_lib-trn_ret-dtl.obj-code
                and ca_lib-trn_ret-parts.artic     = ca_lib-trn_ret-dtl.artic
                and ca_lib-trn_ret-parts.prod-type = ca_lib-trn_ret-dtl.prod-type
                and ca_lib-trn_ret-parts.prod-code = ca_lib-trn_ret-dtl.prod-code
            on error undo, return error return-value
            :

              assign
                chg-qnty = (if parrsrv-fact-qnty then ca_lib-trn_ret-parts.fact-qnty else ca_lib-trn_ret-parts.qnty)
                fix-qnty = chg-qnty
              .
              run trg/rsrv-dtl.p
                ( input        parparentproc,
                  input        {&rsrv-dtl_action_reserv}
                              + ( /* При добавлении и изменении строки ГТД должно дублироваться во все дорезервируемые партии */
                                  if ca_lib-trn_ret-line.cst-code <> ? and ca_lib-trn_ret-line.cst-code <> ""
                                  then "," + {&rsrv-dtl_cst-code} + "=":u + str-encode( ca_lib-trn_ret-line.cst-code, "", ",=":u )
                                  else ""
                                )
                              + "," + {&rsrv-dtl_cli-qnty}      + "=":U + string( chg-qnty / ca_doc-line.cli-base-rate )
                              + "," + {&rsrv-dtl_cre-part-code} + "=":U + string( ca_lib-trn_ret-parts.pl-code  )
                              + "," + {&rsrv-dtl_pl-code}       + "=":U + string( ca_lib-trn_ret-parts.pl-code  )
                              ,
                  buffer       ca_gds-dtl,
                  input-output chg-qnty,
                  input-output ca_doc-line.price-base,
                  input-output ca_doc-line.price-rubl,
                  input        -1,
                  input        if v-gds-mark then ("copy-ret" + {&delim-par} + ca_lib-trn_ret-doc.doc-code) else ""
                ) no-error.
              if chg-qnty <> fix-qnty then do:
                undo, return error substitute( "Не удалось скопировать полностью товар: &1 &2 &3 во внешнюю приходную накладную."
                                               ,ca_gds-dtl.artic
                                               ,ca_gds-dtl.prod-type
                                               ,ca_gds-dtl.prod-code
                                             ).
              end.
              assign
                full-rsrv-qnty = full-rsrv-qnty + chg-qnty
              .
              find first ca_doc-pl
                where ca_doc-pl.obj-type = ca_trn-doc.obj-type
                  and ca_doc-pl.obj-code = ca_trn-doc.obj-code
                  and ca_doc-pl.pl-code  = ca_lib-trn_ret-parts.pl-code
                  and ca_doc-pl.out-code = ca_trn-doc.doc-code
                  and ca_doc-pl.gds-code = ca_goods.gds-code
                no-error .
              if not available ca_doc-pl then do:
                { str/crdocpl.i
                  ca_trn-doc.doc-code
                  ca_goods.gds-code
                  ca_lib-trn_ret-parts.pl-code
                  ca_trn-doc.obj-type
                  ca_trn-doc.obj-code
                  v-doc-pl-rowid
                  no-error
                }
                find first ca_doc-pl
                  where rowid( ca_doc-pl ) = v-doc-pl-rowid
                  .
              end.
              assign
                ca_doc-pl.doc-qnty      = ca_doc-pl.doc-qnty + chg-qnty
                ca_doc-pl.fact-qnty     = ca_doc-pl.doc-qnty
                ca_doc-pl.cli-qnty      = ca_doc-pl.doc-qnty / ca_doc-line.cli-base-rate
                ca_doc-pl.cli-doc-qnty  = ca_doc-pl.doc-qnty * ca_doc-line.doc-density  /* todo плотность надо брать из резервуара */
                ca_doc-pl.cli-fact-qnty = ca_doc-pl.cli-doc-qnty
              .
            end. /* for each lib-trn_ret-parts */
          end. /* if first-of(ca_lib-trn_ret-dtl.artic) */
          if not ( ca_lib-trn_ret-doc.doc-type = {&income}
                   and ca_lib-trn_ret-doc.internal = false
                  )
          then do:
            /*Если копировали из внешнего прихода, то кол-во уже проставили*/
            assign
              ca_doc-line.doc-qnty     = ca_doc-line.doc-qnty + full-rsrv-qnty
              ca_doc-line.cli-qnty     = ca_doc-line.doc-qnty / ca_doc-line.cli-base-rate
              ca_doc-line.fact-qnty    = ca_doc-line.doc-qnty
            .
          end.
        end.
        else do:
          if ca_lib-trn_ret-doc.status_ = "temp":u
            and ca_trn-doc.flag_
          then do:
            /*Копирование факт кол-ва по бар-коду*/
            assign chg-qnty = ca_lib-trn_ret-dtl.fact-qnty.
            run trg/rsrv-dtl.p (input parparentproc,
                                {&rsrv-dtl_action_reserv} + varcst-rsrv + varlast-date-rsrv + varpart-code-rsrv,
                                buffer ca_gds-dtl,
                                input-output chg-qnty,
                                input-output ca_doc-line.price-base,
                                input-output ca_doc-line.price-rubl,
                                input -1,
                                input if v-gds-mark then ("copy-ret" + {&delim-par} + ca_lib-trn_ret-doc.doc-code) else ""
                                ) no-error.
            if error-status :error then undo, return error return-value.
            assign
              ca_gds-dtl.fact-qnty  = ca_gds-dtl.fact-qnty  + chg-qnty
              ca_doc-line.fact-qnty = ca_doc-line.fact-qnty + chg-qnty.
          end.
          else do:
            assign full-rsrv-qnty = 0.
            /* Резервирование из запроса или документа "import"*/
            if ca_lib-trn_ret-doc.status_                  = {&inquiry} or
              substring(ca_lib-trn_ret-doc.doc-code, 1, 6) = "import"   then do:

              v-has-part = can-find ( first ca_lib-trn_ret-parts no-lock
                      where ca_lib-trn_ret-parts.out-code  = ca_lib-trn_ret-dtl.doc-code
                        and ca_lib-trn_ret-parts.obj-type  = ca_lib-trn_ret-dtl.obj-type
                        and ca_lib-trn_ret-parts.obj-code  = ca_lib-trn_ret-dtl.obj-code
                        and ca_lib-trn_ret-parts.artic     = ca_lib-trn_ret-dtl.artic
                        and ca_lib-trn_ret-parts.prod-type = ca_lib-trn_ret-dtl.prod-type
                        and ca_lib-trn_ret-parts.prod-code = ca_lib-trn_ret-dtl.prod-code ) .

                if ca_lib-trn_ret-doc.status_  = {&inquiry} or v-has-part = false  then do:
                /* Для запросов или если нет партий в importе */
                        assign
                          chg-qnty = ca_lib-trn_ret-dtl.fact-qnty.
                        run trg/rsrv-dtl.p (
                            input parparentproc,
                            {&rsrv-dtl_action_reserv} + varcst-rsrv + varlast-date-rsrv + varpart-code-rsrv,
                            buffer ca_gds-dtl,
                            input-output chg-qnty,
                            input-output ca_doc-line.price-base,
                            input-output ca_doc-line.price-rubl,
                            input -1,
                            input if v-gds-mark then ("copy-ret" + {&delim-par} + ca_lib-trn_ret-doc.doc-code) else ""
                            )  no-error.
                end.

                if substring(ca_lib-trn_ret-doc.doc-code, 1, 6) = "import" and v-has-part = true  then do:
                /* Для importа с партиями */
                    assign
                      full-rsrv-qnty = 0
                    .
                    for each ca_lib-trn_ret-parts no-lock
                      where ca_lib-trn_ret-parts.out-code  = ca_lib-trn_ret-dtl.doc-code
                        and ca_lib-trn_ret-parts.obj-type  = ca_lib-trn_ret-dtl.obj-type
                        and ca_lib-trn_ret-parts.obj-code  = ca_lib-trn_ret-dtl.obj-code
                        and ca_lib-trn_ret-parts.artic     = ca_lib-trn_ret-dtl.artic
                        and ca_lib-trn_ret-parts.prod-type = ca_lib-trn_ret-dtl.prod-type
                        and ca_lib-trn_ret-parts.prod-code = ca_lib-trn_ret-dtl.prod-code
                    on error undo, return error return-value
                    :
                      assign
                        chg-qnty = (if parrsrv-fact-qnty then ca_lib-trn_ret-parts.fact-qnty else ca_lib-trn_ret-parts.qnty)
                        fix-qnty = chg-qnty
                      .
                      run trg/rsrv-dtl.p
                        ( input        parparentproc,
                          input        {&rsrv-dtl_action_reserv}
                                      + ( if ca_lib-trn_ret-parts.cst-code <> ? and ca_lib-trn_ret-parts.cst-code <> ""
                                          then "," + {&rsrv-dtl_cst-code} + "=":u  + str-encode( ca_lib-trn_ret-parts.cst-code, "", ",=":u )
                                          else ""
                                        )

                                      + ( if ca_lib-trn_ret-parts.dop <> ""
                                          then  "," + {&rsrv-dtl_dop} + "=":U + str-encode(string(ca_lib-trn_ret-parts.dop), "", ",=":u)
                                          else ""
                                        )

                                      + ( if ca_lib-trn_ret-parts.last-date <> ?
                                          then  "," + {&rsrv-dtl_last-date} + "=":U + str-encode(string(ca_lib-trn_ret-parts.last-date), "", ",=":u)
                                          else ""
                                        )

                                      + "," + {&rsrv-dtl_cli-qnty}      + "=":U + string( chg-qnty / ca_doc-line.cli-base-rate )

                                      + ( if ca_lib-trn_ret-parts.part-code <> ? and ca_lib-trn_ret-parts.part-code <> ""
                                          then  "," + {&rsrv-dtl_cre-part-code} + "=":U + str-encode (ca_lib-trn_ret-parts.part-code, "", ",=":u )
                                          else ""
                                        )

                                      ,
                          buffer       ca_gds-dtl,
                          input-output chg-qnty,
                          input-output ca_doc-line.price-base,
                          input-output ca_doc-line.price-rubl,
                          input        -1,
                          input        if v-gds-mark then ("copy-ret" + {&delim-par} + ca_lib-trn_ret-doc.doc-code) else ""
                        ) no-error.
                    end.
                end.

              if error-status :error then undo, return error return-value.
              assign
                ca_gds-dtl.doc-qnty  = ca_gds-dtl.doc-qnty + chg-qnty.
                ca_gds-dtl.fact-qnty = ca_gds-dtl.doc-qnty.
              assign full-rsrv-qnty = chg-qnty.

            end.
            else do:
              /*------------------------------------------------------------------------------------*/
              /*  Вот здесь будет резервирование из старых партий с их атрибутами                   */
              /*------------------------------------------------------------------------------------*/
              /* По внешнему приходу по первому попавшемуся признаку резервируем по всем партиям.
                Если не удается зарезервировать по всем партиям, то откат.
                В признаки копируем кол-во из документа копирования.
                Невозможно в случае копирования документарного количества.*/
              if ca_trn-doc.doc-type = {&income} and
                  not ca_trn-doc.internal         and
                  (ca_lib-trn_ret-doc.status_ <> "temp" or
                  ca_trn-doc.hold-doc-code-parent <> "") and
                  parrsrv-fact-qnty               = yes
                  then do:
                  if first-of(ca_lib-trn_ret-dtl.artic) then do:
                    for each ca_lib-trn_ret-parts where ca_lib-trn_ret-parts.out-code  = ca_lib-trn_ret-dtl.doc-code  AND
                                                        ca_lib-trn_ret-parts.obj-type  = ca_lib-trn_ret-dtl.obj-type  AND
                                                        ca_lib-trn_ret-parts.obj-code  = ca_lib-trn_ret-dtl.obj-code  AND
                                                        ca_lib-trn_ret-parts.artic     = ca_lib-trn_ret-dtl.artic     AND
                                                        ca_lib-trn_ret-parts.prod-type = ca_lib-trn_ret-dtl.prod-type AND
                                                        ca_lib-trn_ret-parts.prod-code = ca_lib-trn_ret-dtl.prod-code NO-LOCK:
                      ASSIGN
                        chg-qnty = ca_lib-trn_ret-parts.fact-qnty
                        fix-qnty = chg-qnty
                      .
                      assign
                          varpl-inf = (if ca_trn-doc.ext-doc-type = {&TDEDT_Pri_Vnesh} and trim(ca_lib-trn_ret-parts.part-code) > "" then "," +  {&rsrv-dtl_cre-part-code} + "=":U + str-encode(ca_lib-trn_ret-parts.part-code, "", ",=":u) else "":u).
                      if ca_trn-doc.hold-doc-code-parent <> "" then do:
                        run trg/rsrv-dtl.p
                          (input parparentproc,
                          {&rsrv-dtl_action_reserv} + "," +
                            {&rsrv-dtl_hold-code-parent} + "=" + str-encode(ca_lib-trn_ret-parts.in-code, "", ",=":u)
                            + "," + {&rsrv-dtl_part-code-parent} + "=" + str-encode(ca_lib-trn_ret-parts.part-code, "", ",=":u)
                            + "," + {&rsrv-dtl_hold-date}        + "=" + str-encode(string(ca_lib-trn_ret-parts.hold-date), "", ",=":u)
                            + "," + {&rsrv-dtl_last-date}        + "=" + str-encode(string(ca_lib-trn_ret-parts.last-date), "", ",=":u)
                            + "," + {&rsrv-dtl_cst-code} + "=" + str-encode(ca_lib-trn_ret-parts.cst-code, "", ",=":u)
                            + "," + {&rsrv-dtl_cli-qnty} + "=" + string(ca_lib-trn_ret-parts.cli-qnty)
                            + varpl-inf
                            ,
                            buffer ca_gds-dtl,
                            input-output chg-qnty,
                            input-output ca_doc-line.price-base,
                            input-output ca_doc-line.price-rubl,
                            input -1,
                            input if v-gds-mark then ("copy-ret" + {&delim-par} + ca_lib-trn_ret-doc.doc-code) else ""
                            ) no-error.
                        if error-status :error then do:
                            undo, return error return-value.
                        end.
                      end.
                      else do:

                        assign
                          varpl-inf = (if available bf_trn-doc and bf_trn-doc.ext-doc-type = {&TDEDT_Spi_Vnesh} and ca_lib-trn_ret-parts.pl-code <> 0 and ca_lib-trn_ret-parts.pl-code <> ? then "," +  {&rsrv-dtl_pl-code} + "=":U + string( ca_lib-trn_ret-parts.pl-code  ) else "":u).
                        run trg/rsrv-dtl.p
                          (input parparentproc,
                          {&rsrv-dtl_action_reserv}
                            /*ГТД прямо из партий*/
                            + "," + {&rsrv-dtl_cst-code} + "=" + str-encode(ca_lib-trn_ret-parts.cst-code, "", ",=":u)
                            + "," + {&rsrv-dtl_cre-part-code} + "=" + (if ca_lib-trn_ret-doc.doc-type = {&income} and ca_lib-trn_ret-doc.internal = no then str-encode(ca_lib-trn_ret-parts.part-code, "", ",=":u) else str-encode("#":u + ca_lib-trn_ret-parts.in-code, "", ",=":u))
                            + "," + {&rsrv-dtl_last-date} + "=" + str-encode(string(ca_lib-trn_ret-parts.last-date), "", ",=":u)
                            + varpl-inf
                            ,
                            buffer ca_gds-dtl,
                            input-output chg-qnty,
                            input-output ca_doc-line.price-base,
                            input-output ca_doc-line.price-rubl,
                            input -1,
                            input if v-gds-mark then ("copy-ret" + {&delim-par} + ca_lib-trn_ret-doc.doc-code) else ""
                            ) no-error.
                        if error-status :error then do:
                            undo, return error return-value.
                        end.
                      end.
                      if chg-qnty <> fix-qnty then do:
                          undo, return error substitute ("Не удалось скопировать полностью товар: &1 &2 &3 во внешнюю приходную накладную.",
                                                        ca_gds-dtl.artic,
                                                        ca_gds-dtl.prod-type,
                                                        ca_gds-dtl.prod-code ) .
                      end.
                    end. /*for each lib-trn_ret-parts*/
                  end. /*first-of gds-dtl*/
                  assign
                    ca_gds-dtl.doc-qnty  = ca_gds-dtl.doc-qnty + ca_lib-trn_ret-dtl.doc-qnty.
                    ca_gds-dtl.fact-qnty = ca_gds-dtl.doc-qnty.
                  assign full-rsrv-qnty = ca_lib-trn_ret-dtl.doc-qnty.
              end.
              else do:
                  if parrsrv-fact-qnty then do:
                    assign
                      chg-qnty = ca_lib-trn_ret-dtl.fact-qnty.
                  end.
                  else do:
                    assign
                      chg-qnty = ca_lib-trn_ret-dtl.doc-qnty.
                  end.
                  run trg/rsrv-dtl.p (input parparentproc,
                            {&rsrv-dtl_action_reserv} + varcst-rsrv + varlast-date-rsrv + varpart-code-rsrv,
                            buffer ca_gds-dtl,
                            input-output chg-qnty,
                            input-output ca_doc-line.price-base,
                            input-output ca_doc-line.price-rubl,
                            input -1,
                            input if v-gds-mark then ("copy-ret" + {&delim-par} + ca_lib-trn_ret-doc.doc-code) else ""
                            ) no-error.
                  if error-status :error then undo, return error return-value.
                  assign
                    ca_gds-dtl.doc-qnty  = ca_gds-dtl.doc-qnty + chg-qnty
                    ca_gds-dtl.fact-qnty = ca_gds-dtl.doc-qnty.
                  assign full-rsrv-qnty = chg-qnty.
              end.
            end.
            /*Если копировали из внешнего прихода, то кол-во уже проставили*/
            if not ( ca_lib-trn_ret-doc.doc-type = {&income}
                    and ca_lib-trn_ret-doc.internal = false
                    )
            then do:
              assign
                ca_doc-line.doc-qnty  = ca_doc-line.doc-qnty + full-rsrv-qnty
                ca_doc-line.cli-qnty  = ca_doc-line.doc-qnty / ca_doc-line.cli-base-rate
                ca_doc-line.fact-qnty = ca_doc-line.doc-qnty
              .
            end.
          end.
        end. /*окончание различных резервирований*/
       /* --------------------------------------------------------------------------------------------------------------------------------------------
         Коррекция количества в случае копирования в ПН из запроса - ПРИЗНАКИ
       -------------------------------------------------------------------------------------------------------------------------------------------- */
       find ca_gds-prt where ca_gds-prt.upper-code = ca_goods.prt-root no-lock.
       if ca_gds-prt.node-name <> {&empty-scale}   and
          ca_lib-trn_ret-doc.doc-type      = {&income}        and
          not ca_lib-trn_ret-doc.internal                     and
          ca_trn-doc.status_    = {&wayb}          and
          ca_lib-trn_ret-doc.status_       = {&inquiry}       and
          ca_trn-doc.ord-num    = ca_lib-trn_ret-doc.doc-code then do:
         for each old-doc no-lock where
                  old-doc.ord-num = ca_lib-trn_ret-doc.doc-code :
           find old-dtl where old-dtl.doc-code  = old-doc.doc-code
                          and old-dtl.artic     = ca_lib-trn_ret-dtl.artic
                          and old-dtl.prod-type = ca_lib-trn_ret-dtl.prod-type
                          and old-dtl.prod-code = ca_lib-trn_ret-dtl.prod-code
                          and old-dtl.prt-code  = varlegal-node no-error.
           if available old-dtl then do:
             if old-dtl.obj-type = ca_lib-trn_ret-dtl.obj-type and
                old-dtl.obj-code = ca_lib-trn_ret-dtl.obj-code then do:
               accumulate old-dtl.doc-qnty (total).
             end.
             else do:
               message "На объекте " old-dtl.obj-type " " old-dtl.obj-code skip
                       " был заведен документ " old-dtl.doc-code " связаный с заказом " ca_lib-trn_ret-dtl.doc-code skip
                       " в нем есть признак товара " old-dtl.artic " " old-dtl.prod-type " " old-dtl.prod-code skip
                       " с количеством " old-dtl.doc-qnty " ." skip
                       "Данное количество не будет учтено при расчете накладной."
               view-as alert-box.
             end.
           end.
         end.
         if ca_lib-trn_ret-dtl.doc-qnty - (accum total old-dtl.doc-qnty) < 0 then do:
           /* по накладным уже больше, чем по заказу - выравниваем, мб в минус */
           assign
             chg-qnty = - (accum total old-dtl.doc-qnty) + ca_lib-trn_ret-dtl.doc-qnty.
           run trg/rsrv-dtl.p (input parparentproc,
                           {&rsrv-dtl_action_reserv} + varcst-rsrv + varlast-date-rsrv + varpart-code-rsrv,
                           buffer ca_gds-dtl, input-output chg-qnty,
                                  input-output ca_doc-line.price-base, input-output ca_doc-line.price-rubl, -1, "") no-error.
           if error-status :error then do:
              undo, return error return-value.
           end.
           assign
             ca_gds-dtl.doc-qnty  = ca_gds-dtl.doc-qnty + chg-qnty
             ca_gds-dtl.fact-qnty = ca_gds-dtl.doc-qnty.
         end.
         accumulate ca_gds-dtl.doc-qnty (total).
       end.
    end. /*for each ca_lib-trn_ret-dtl*/
    /* --------------------------------------------------------------------------------------------------------------------------------------------
         Коррекция количества в случае копирования в ПН из запроса
       -------------------------------------------------------------------------------------------------------------------------------------------- */
    if ca_lib-trn_ret-doc.doc-type     = {&income}  and
       not ca_lib-trn_ret-doc.internal              and
       ca_trn-doc.status_   = {&wayb}    and
       ca_lib-trn_ret-doc.status_      = {&inquiry} and
       ca_trn-doc.ord-num  = ca_lib-trn_ret-doc.doc-code then do:
      if ca_gds-prt.node-name = {&empty-scale} then do:
         assign
         v-accum-cli-qnty = 0.
         for each old-doc no-lock where
                  old-doc.ord-num = ca_lib-trn_ret-doc.doc-code :
          find old-line where old-line.doc-code  = old-doc.doc-code
                          and old-line.artic     = ca_doc-line.artic
                          and old-line.prod-type = ca_doc-line.prod-type
                          and old-line.prod-code = ca_doc-line.prod-code no-error.
          if available old-line then do:
            if old-line.obj-type = ca_doc-line.obj-type
              and old-line.obj-code = ca_doc-line.obj-code
            then do:
              assign v-accum-cli-qnty = v-accum-cli-qnty + old-line.fact-qnty / old-line.cli-base-rate.
            end.
            else do:
              message "На объекте " old-line.obj-type " " old-line.obj-code skip
                      " был заведен документ " old-line.doc-code " связанный с данным заказом " skip
                      " в нем есть признак товара " old-line.artic " " old-line.prod-type " " old-line.prod-code skip
                      " с количеством " old-line.doc-qnty " ." skip
                      "Данное количество не будет учтено при расчете накладной."
              view-as alert-box.
            end.
          end.
        end.
        if ca_lib-trn_ret-line.cli-qnty - v-accum-cli-qnty   < 0 then do:
          /* по накладным уже больше, чем по заказу - выравниваем, мб в минус */
          /*ca_lib-trn_ret-line.cli-qnty изначально копируется с заказа?*/
          find ca_gds-dtl where ca_gds-dtl.doc-code  = ca_trn-doc.doc-code
                            and ca_gds-dtl.artic     = ca_doc-line.artic
                            and ca_gds-dtl.prod-code = ca_doc-line.prod-code
                            and ca_gds-dtl.prod-type = ca_doc-line.prod-type
                            and ca_gds-dtl.prt-code  = ca_gds-prt.node-code.
          assign
            chg-qnty = (- v-accum-cli-qnty + ca_lib-trn_ret-line.cli-qnty) * ca_doc-line.cli-base-rate.
          if chg-qnty <> 0 then do:
            run trg/rsrv-dtl.p (input parparentproc,
                            {&rsrv-dtl_action_reserv} + varcst-rsrv + varlast-date-rsrv + varpart-code-rsrv,
                            buffer ca_gds-dtl, input-output chg-qnty,
                            input-output ca_doc-line.price-base, input-output ca_doc-line.price-rubl,-1, "") no-error.
            if error-status :error then do:
              undo, return error return-value.
            end.
            assign
              ca_doc-line.cli-qnty  = ca_doc-line.cli-qnty + chg-qnty / ca_doc-line.cli-base-rate
              ca_doc-line.doc-qnty  = ca_doc-line.cli-qnty * ca_doc-line.cli-base-rate
              ca_doc-line.fact-qnty = ca_doc-line.doc-qnty
              ca_gds-dtl.doc-qnty   = ca_doc-line.doc-qnty
              ca_gds-dtl.fact-qnty  = ca_doc-line.doc-qnty.
          end.
        end.
      end.
      else do:
        /* сумму признаков с коррекцией записываем в строку */

        if ca_doc-line.doc-qnty <> (accum total ca_gds-dtl.doc-qnty) then do:
          assign
            ca_doc-line.doc-qnty = (accum total ca_gds-dtl.doc-qnty)
            ca_doc-line.fact-qnty = ca_doc-line.doc-qnty.
          if ca_doc-line.unit-cli = ca_goods.unit-base then do:
            assign
             ca_doc-line.cli-qnty = ca_doc-line.doc-qnty.
          end.
          else do:
            assign
             ca_doc-line.cli-qnty = ca_doc-line.doc-qnty / ca_doc-line.cli-base-rate.
          end.
        end.
      end.
    end.
  end. /* не просто создание из интерфейса */
  /*----------------------------------------------------------------------------*/
  /*      Если ничего не зарезервировали, то следует подчистить                 */
  /*             Этот блок срабатывает при копировании                          */
  /*----------------------------------------------------------------------------*/
  if ca_doc-line.cli-qnty <= 0 or
     ca_doc-line.doc-qnty <= 0 then do:
     delete ca_doc-line.
  end.
  if available ca_doc-line then do:
    /*проверка на целое*/
    { str/chkwhole.i
      ca_doc-line.doc-code
      ca_doc-line.artic
      ca_doc-line.prod-type
      ca_doc-line.prod-code
      ca_doc-line.cli-qnty
      ca_doc-line.doc-qnty
      ca_doc-line.fact-qnty
      parrecalc
      no-error
    }
    if error-status :error then do:
      undo, return error return-value.
    end.
    /*Проверка на факт. количество в топливном товаре*/
    { str/lnfactqt.i
      parparentproc
      recid(ca_doc-line)
      no
      ca_trn-doc.status_
      ca_trn-doc.flag_
      no-error }
    if error-status :error then do:
      undo, return error return-value .
    end.
  end.
end. /* Несерийный товар */
end.
end procedure. /* lib-trn_copy-inh */

/* Тело продуцирования строки накладной из сканерного файла */
procedure lib-trn_copy-scn:
define input  parameter parparentproc AS WIDGET-HANDLE           NO-UNDO.
define input  parameter parrec-doc    as   recid                 no-undo.
define input  parameter parb-code     like ub.bar-code.b-code    no-undo.
define input  parameter b-qnty        like ub.gds-dtl.doc-qnty   no-undo.  /* количество по бар-коду в основных едизмах */
define input  parameter paris-all     as   logical               no-undo.
define input  parameter paradd-sens   as   logical               no-undo.
define input  parameter parline-mode  as character no-undo.
define output parameter parmes        as character no-undo.
define output parameter parok         as character no-undo.

define variable v-is-zam as logical   no-undo .
define variable parts-qnty like ub.parts.fact-qnty     no-undo.  /* остаток в БД по партии было  */
define variable parts-qnty-doc like ub.parts.fact-qnty no-undo.  /* существующие партии по инвентаризации  */
define variable parts-scan as decimal   no-undo .
define variable prt-qnty like ub.prt-obj.fact-qnty     no-undo.  /* остаток в БД по признаку */
define variable gds-qnty like ub.gds-obj.fact-qnty     no-undo.  /* остаток в БД по товару   */
define variable b-c      as   integer                  no-undo.  /* параметр передаваемый в rsrv-dtl.p:
                                                                                  - если бар-код на партию то резервирование по этой партии;
                                                                                  - если -1 - то выбор партий для резерва автоматически */
define variable inv-qnty    like ub.gds-dtl.fact-qnty     no-undo.
define variable memexp-qnty like ub.gds-dtl.doc-qnty      no-undo.
define variable g-doc-prt as logical no-undo.
define buffer cs_trn-doc  for ub.trn-doc.
define buffer cs_doc-line for ub.doc-line.
define buffer cs_gds-dtl  for ub.gds-dtl.
define buffer cs_parts    for ub.parts.
define buffer cs_goods    for ub.goods.
define buffer cs_units    for ub.units.
define buffer cs_gds-prt  for ub.gds-prt.
define buffer cs_bar-code for ub.bar-code.
define buffer cs_shop     for ub.shop.
define buffer cs_store    for ub.store.
define buffer cs_prt-obj  for ub.prt-obj.
define buffer cs_gds-obj  for ub.gds-obj.
define buffer cli-gds-cs for ub.cli-gds.
define variable v-insalepr                     as   logical      initial ? no-undo.
define variable parsale-price                  like ub.price-list.price-sale initial ? no-undo.
define variable varcst-rsrv                    as   character              no-undo.
define variable varprice-cli-cs                like ub.doc-line.price-rubl no-undo.
define variable varprice-cli-unit-base-cs      like ub.doc-line.price-rubl no-undo.
define variable varprice-road-tax-cs           like ub.doc-line.price-rubl no-undo.
define variable varprice-other-exp-cs          like ub.doc-line.price-rubl no-undo.
define variable varprice-transport-exp-cs      like ub.doc-line.price-rubl no-undo.
define variable varprice-without-abs-cs        like ub.doc-line.price-rubl no-undo.
define variable varprice-slt-cs                like ub.doc-line.price-rubl no-undo.
define variable varprice-no-slt-cs             like ub.doc-line.price-rubl no-undo.
define variable varprice-vat-cs                like ub.doc-line.price-rubl no-undo.
define variable varprice-no-vat-slt-cs         like ub.doc-line.price-rubl no-undo.
define variable varprice-rubl-cs               like ub.doc-line.price-rubl no-undo.
define variable varprice-road-tax-rubl-cs      like ub.doc-line.price-rubl no-undo.
define variable varprice-other-exp-rubl-cs     like ub.doc-line.price-rubl no-undo.
define variable varprice-transport-exp-rubl-cs like ub.doc-line.price-rubl no-undo.
define variable varprice-without-abs-rubl-cs   like ub.doc-line.price-rubl no-undo.
define variable varprice-slt-rubl-cs           like ub.doc-line.price-rubl no-undo.
define variable varprice-no-slt-rubl-cs        like ub.doc-line.price-rubl no-undo.
define variable varprice-vat-rubl-cs           like ub.doc-line.price-rubl no-undo.
define variable varprice-no-vat-slt-rubl-cs    like ub.doc-line.price-rubl no-undo.
define variable varprice-base-cs               like ub.doc-line.price-base no-undo.
define variable varprice-road-tax-base-cs      like ub.doc-line.price-base no-undo.
define variable varprice-other-exp-base-cs     like ub.doc-line.price-base no-undo.
define variable varprice-transport-exp-base-cs like ub.doc-line.price-base no-undo.
define variable varprice-without-abs-base-cs   like ub.doc-line.price-base no-undo.
define variable varprice-slt-base-cs           like ub.doc-line.price-base no-undo.
define variable varprice-no-slt-base-cs        like ub.doc-line.price-base no-undo.
define variable varprice-vat-base-cs           like ub.doc-line.price-base no-undo.
define variable varprice-no-vat-slt-base-cs    like ub.doc-line.price-base no-undo.
define variable varlegal-node like ub.gds-prt.node-code no-undo.
define variable varis-petrolium as logical no-undo.
define variable varis-pieces    as logical no-undo.
define variable varis-term as logical no-undo.
define variable varr-b-type as character no-undo.
define variable conf-par  as char    no-undo.
define variable par-type  as char    no-undo.
define variable g-log as logical no-undo.
define variable chg-qnty                       like ub.gds-dtl.doc-qnty       no-undo.
define variable fix-qnty                       like ub.gds-dtl.doc-qnty       no-undo.
define variable mem-qnty                       like ub.gds-dtl.doc-qnty       no-undo.
define variable rec-inv-line as recid no-undo.

parts-scan = b-qnty .
v-is-zam = paris-all .
{ str/get-pr.i def }
do transaction on error undo, return error return-value :
find first cs_trn-doc where recid(cs_trn-doc) = parrec-doc.
find first cs_bar-code where cs_bar-code.b-code = parb-code.

{ gbl/conf-rd.i
  "'is-prt':u"
  0
  "'':u"
  0
  "'':u"
  "'':u"
  "'':u"
  yes
  conf-par
  par-type
  no-error
}
/* { gbl/curr-r-b.i varr-b } 12/II-2019 - вынесено в main-block */
if cs_trn-doc.obj-type = {&shop} then do:
   find first cs_shop where cs_shop.obj-code = cs_trn-doc.obj-code no-lock.
   if conf-par = "yes" and
      cs_shop.doc-prt  then do:
     assign
     g-doc-prt = yes.
   end.
   else do:
     assign
     g-doc-prt = no.
   end.
end.
else do:
  find first cs_store where cs_store.obj-code = cs_trn-doc.obj-code no-lock.
  if conf-par = "yes" and
     cs_store.doc-prt  then do:
    assign
    g-doc-prt = yes.
  end.
  else do:
    assign
    g-doc-prt = no.
  end.
end.

find first cs_goods   where cs_goods.gds-code     = cs_bar-code.gds-code no-lock.
find first cs_gds-prt where cs_gds-prt.upper-code = cs_goods.prt-root  no-lock.
find first cs_units   where cs_units.unit-name    = cs_goods.unit-base no-lock.
find cs_doc-line where cs_doc-line.doc-code  = cs_trn-doc.doc-code
                   and cs_doc-line.artic     = cs_goods.artic
                   and cs_doc-line.prod-code = cs_goods.prod-code
                   and cs_doc-line.prod-type = cs_goods.prod-type no-error.
if not available cs_doc-line and
   (paradd-sens = no  or
    cs_trn-doc.doc-type = {&inventory} ) then do:
   return error substitute("&1 Нельзя добавить строку документа : &2 .", parmes, cs_goods.artic).
end.
if not available cs_doc-line then do:
  run lib-trn_create-doc-line in this-procedure (input cs_goods.artic,
                                                 input cs_goods.prod-type,
                                                 input cs_goods.prod-code,
                                                 recid(cs_trn-doc)) no-error.
  if error-status :error then do:
    return error substitute("&1 &2", parmes, return-value).
  end.
  find first cs_doc-line where cs_doc-line.doc-code  = cs_trn-doc.doc-code and
                               cs_doc-line.artic     = cs_goods.artic      and
                               cs_doc-line.prod-type = cs_goods.prod-type  and
                               cs_doc-line.prod-code = cs_goods.prod-code .

  assign
    cs_doc-line.unit-cli      = cs_goods.unit-cli
    cs_doc-line.cli-base-rate = cs_goods.cli-base-rate.
end.
if cs_trn-doc.doc-type = {&inventory} then do:
   /*При создании инвентаризации не обрабатываем бар-коды нетерминальных признаков*/
   { gbl/prtat.i cs_bar-code.node-code 'terminal-prt=request':u varis-term }
   if varis-term <> yes and
      g-doc-prt         then do:
      return error substitute("&1 Бар-код &2 не является бар-кодом терминального признака.", parmes, cs_bar-code.b-code).
   end.
end.
find cs_gds-dtl where cs_gds-dtl.doc-code   = cs_trn-doc.doc-code
                  and cs_gds-dtl.artic      = cs_goods.artic
                  and cs_gds-dtl.prod-code  = cs_goods.prod-code
                  and cs_gds-dtl.prod-type  = cs_goods.prod-type
                  and cs_gds-dtl.prt-code   = cs_bar-code.node-code no-error.
if not available cs_gds-dtl then do:
   if not paradd-sens and cs_trn-doc.doc-type <> {&inventory} then do:
     return error substitute("Нельзя добавить признак по товару &1 &2 &3 с бар-кодом &4.", cs_goods.artic, cs_goods.prod-type, cs_goods.prod-code, cs_bar-code.b-code).
   end.
   { str/crgdsdtl.i
     cs_trn-doc.obj-code
     cs_trn-doc.obj-type
     cs_trn-doc.doc-code
     cs_goods.artic
     cs_goods.prod-code
     cs_goods.prod-type
     cs_bar-code.node-code
     yes
     no-error
   }
   if error-status :error then do:
      return error substitute("&1 &2", parmes, return-value).
   end.
   find first cs_gds-dtl where cs_gds-dtl.doc-code  = cs_trn-doc.doc-code and
                               cs_gds-dtl.artic     = cs_goods.artic      and
                               cs_gds-dtl.prod-code = cs_goods.prod-code  and
                               cs_gds-dtl.prod-type = cs_goods.prod-type  and
                               cs_gds-dtl.prt-code  = cs_bar-code.node-code.
end.
/*-----------------------------------------------------*/
/*           Проверка бар-кода партии                  */
/*-----------------------------------------------------*/
parts-qnty-doc = 0 .
if cs_bar-code.in-code <> "" THEN DO:
  find first cs_parts WHERE cs_parts.obj-code    = cs_trn-doc.obj-code
                        and cs_parts.obj-type    = cs_trn-doc.obj-type
                        and cs_parts.artic       = cs_doc-line.artic
                        and cs_parts.prod-type   = cs_doc-line.prod-type
                        and cs_parts.prod-code   = cs_doc-line.prod-code
                        and cs_parts.in-code     = cs_bar-code.in-code
                        and cs_parts.part-code   = cs_bar-code.part-code no-error.
   if not available cs_parts and
      cs_bar-code.in-code <> "" then do:
        undo, return error substitute("&1 Ссылка на несуществующую партию: &2.", parmes, cs_bar-code.part-code).
   end.
   /*В режиме замены партия должна быть обязательно привязана к документу*/
   find first cs_parts where cs_parts.out-code    = cs_trn-doc.doc-code
                         and cs_parts.obj-code    = cs_trn-doc.obj-code
                         and cs_parts.obj-type    = cs_trn-doc.obj-type
                         and cs_parts.artic       = cs_doc-line.artic
                         and cs_parts.prod-type   = cs_doc-line.prod-type
                         and cs_parts.prod-code   = cs_doc-line.prod-code
                         and cs_parts.in-code     = cs_bar-code.in-code
                         and cs_parts.part-code   = cs_bar-code.part-code no-error.
   if not available cs_parts    and
      cs_bar-code.in-code <> "" and
      paris-all = yes /*режим замены*/ then do:
          /*undo, return error substitute ("&1 Ссылка на партию не задействованную в документе: &2.", parmes, cs_bar-code.part-code).*/
   end.

   if available cs_parts then do:
      parts-qnty-doc = cs_parts.fact-qnty .
   end.

end.
/*-----------------------------------------------------*/
/* Подготовка к резервированию по бар-коду партии      */
/*-----------------------------------------------------*/
if cs_bar-code.in-code <> ""                                                             and
   ((can-do ({&expense_write-off_return}, cs_trn-doc.doc-type) and not cs_trn-doc.flag_) or
    (cs_trn-doc.doc-type = {&inventory} and
     cs_trn-doc.status_ = {&permitted})) then do:
      /* определяем количество для резервирования по партии */
      assign
        parmes = parmes + " Партия: " + cs_bar-code.part-code + " ".
      if paris-all = ? then do:
         g-log = no.
         if available cs_parts then do:
            message "Товар :" cs_goods.artic cs_goods.gds-name skip
                    "Партия :" cs_parts.part-code "-  количество не 0 !" skip (2)
                    "yes - переписать количество со сканера в партию :" b-qnty skip (2)
                    "no  - прибавить количество со сканера к партии :"  cs_parts.qnty "+" b-qnty
                    view-as alert-box question buttons yes-no update g-log.
                    v-is-zam = g-log .
         end.
         else do:
            message "Товар :" cs_goods.artic cs_goods.gds-name skip
                    "Партия :" cs_bar-code.part-code skip(2)
                    "Режим замены осуществить невозможно. Только добавление." skip
                    "yes - Пропустить партию." skip
                    "no  - прибавить количество со сканера к партии :" b-qnty
            view-as alert-box question buttons yes-no update g-log.
            if g-log = yes then do:
               undo, return error substitute ("&1 Невозможно осуществить режим замены. Партия: &2 не привязана к данному документу.", parmes, cs_bar-code.part-code).
            end.
            v-is-zam = g-log .
         end.
      end.
      else g-log = paris-all.

      if g-log then do:
      /* уменьшаем количество b-qnty так, чтоб потом получилось parts.qnty = parts.qnty + b-qnty = исходному b-qnty,
         в том числе может получиться и отрицательное b-qnty */
      assign
        parmes  = parmes + " Количество заменено на: " + string (b-qnty) + " "
        b-qnty = b-qnty - parts-qnty-doc
        .
      end.

      if b-qnty = 0 then return.
      assign
        b-c = cs_bar-code.b-code. /* резервирование по конкретной партии в rsrv-dtl.p */
end.
/*-----------------------------------------------------*/
/* Подготовка к резервированию не по бар-коду партии   */
/*-----------------------------------------------------*/
else do:
  /*----------------------------------------------*/
  /*             Инвентаризация                   */
  /*----------------------------------------------*/
  if cs_trn-doc.doc-type = {&inventory} then do:
     find cs_prt-obj where cs_prt-obj.obj-type  = cs_trn-doc.obj-type
                       and cs_prt-obj.obj-code  = cs_trn-doc.obj-code
                       and cs_prt-obj.artic     = cs_gds-dtl.artic
                       and cs_prt-obj.prod-code = cs_gds-dtl.prod-code
                       and cs_prt-obj.prod-type = cs_gds-dtl.prod-type
                       and cs_prt-obj.prt-code  = cs_gds-dtl.prt-code no-lock no-error.
     if available cs_prt-obj then do:
        assign
        prt-qnty   = cs_prt-obj.fact-qnty.
     end.
     else do:
       assign
       prt-qnty = 0.
     end.
     if paris-all = ? then do:
      g-log = no.
      message "Товар :" cs_goods.artic cs_goods.gds-name
              " Было  количество " prt-qnty + cs_gds-dtl.doc-qnty skip (2)
              "yes - переписать количество со сканера в документ :" b-qnty skip (2)
              "no - прибавить количество со сканера к документу :"  prt-qnty + cs_gds-dtl.doc-qnty "+" b-qnty
              view-as alert-box question buttons yes-no update g-log.
     end.
     else g-log = paris-all.
     if g-log then do:
       assign
        parmes = parmes + " Количество заменено на: " + string (b-qnty).
     end.
     else do:
       assign
         b-qnty = prt-qnty + cs_gds-dtl.doc-qnty + b-qnty.
     end.
  end.
  else do:
    /*Если не инвентаризация*/
    if cs_gds-dtl.fact-qnty <> 0 then do:
      if paris-all = ? then do:
        g-log = no.
        message "Товар :" cs_goods.artic cs_goods.gds-name
                " -  количество не 0 !" skip (2)
                "yes - переписать количество со сканера в документ :" b-qnty skip (2)
                "no - прибавить количество со сканера к документу :" cs_doc-line.fact-qnty "+" b-qnty
                view-as alert-box question buttons yes-no update g-log.
      end.
      else g-log = paris-all.
      if g-log then do:
         assign
         parmes = parmes + " Количество заменено на: " + string (b-qnty) + " "
         b-qnty = b-qnty - cs_gds-dtl.fact-qnty.
      end.
    end.
  end.
  b-c = -1. /* автомат. резервирование по любым партиям в rsrv-dtl.p */
end.
/*----------------------------------*/
/* Резервирование при инвентаризации*/
/*----------------------------------*/
if cs_trn-doc.doc-type = {&inventory} and
   cs_trn-doc.status_  = {&permitted} then do:

    find cs_gds-obj where cs_gds-obj.obj-type  = cs_trn-doc.obj-type
                      and cs_gds-obj.obj-code  = cs_trn-doc.obj-code
                      and cs_gds-obj.artic     = cs_gds-dtl.artic
                      and cs_gds-obj.prod-code = cs_gds-dtl.prod-code
                      and cs_gds-obj.prod-type = cs_gds-dtl.prod-type   no-lock no-error.
    if available cs_gds-obj then do:
      assign
       gds-qnty = cs_gds-obj.fact-qnty.
    end.
    else do:
      assign
      gds-qnty = 0.
    end.

    define buffer cs_doc-prts for ub.doc-prts  .
    find first cs_doc-prts no-lock where
               cs_doc-prts.b-code    = cs_bar-code.b-code and
               cs_doc-prts.out-code  = cs_trn-doc.doc-code
               no-error.
    if available cs_doc-prts then do:
      assign
       parts-qnty = cs_doc-prts.fact-qnty.
    end.
    else do:
      assign
      parts-qnty = 0.
      if cs_bar-code.in-code <> "" then do:
         message 'Необходимо пересобрать инвентаризацию  с  разр+ до накл-. Не рассчиталось БЫЛО по партиям !' view-as alert-box information .
         return error .
      end.
    end.


    if cs_bar-code.in-code <> "" then do:
/*
     message 'v-is-zam      ' v-is-zam skip
             'parts-qnty-doc' parts-qnty-doc skip
             'parts-qnty    ' parts-qnty skip
             'parts-scan    ' parts-scan skip
             'b-qnty        ' b-qnty
             .

  */
           /* !!!! */
          if v-is-zam = false then do:
             /* Прибавить не сбрасывая */
             b-qnty   = parts-qnty + parts-qnty-doc + parts-scan .
          end.
          else do:
            /* Замена */
              b-qnty   = parts-scan .
          end.
          chg-qnty = b-qnty - parts-qnty -  parts-qnty-doc  .
    end.
    else do:
        if not available cs_parts then do:
          assign
            chg-qnty = b-qnty - (prt-qnty + cs_gds-dtl.doc-qnty). /*стало - было*/
        end.
        else do:
          assign
            chg-qnty = b-qnty.
        end.
    end.

    assign inv-qnty = chg-qnty. /* вот тут дожно быть сколько зарезервировать */
    define variable v-rsrv-mode as character no-undo .
    if b-c > 0 then do:
       v-rsrv-mode =  {&rsrv-dtl_action_reserv}
            + ",":U + {&rsrv-dtl_rsrv-single-part}
            + ",":U + {&rsrv-dtl_rsrv-in-code}   + "=":U + str-encode ( cs_bar-code.in-code  ,  "", ",=":U )
            + ",":U + {&rsrv-dtl_rsrv-part-code} + "=":U + str-encode ( cs_bar-code.part-code,  "", ",=":U )
            .
    end.
    else do:
       v-rsrv-mode = {&rsrv-dtl_action_reserv} + "," +
                     {&rsrv-dtl_no-message} +
                     varcst-rsrv .
    end.
    run trg/rsrv-dtl.p
        ( input parparentproc,
          input v-rsrv-mode ,
          buffer cs_gds-dtl,
          input-output chg-qnty,
          input-output cs_doc-line.price-base,
          input-output cs_doc-line.price-rubl,
          b-c, "" )
          no-error.
    if error-status :error then do:
       undo, return error substitute ("&1 Ошибка при резервировании &2", parmes, return-value).
    end.
    if inv-qnty <> chg-qnty then do:
       undo, return error substitute ("&1 Ошибка при резервировании &2. Не удалось зарезервировать все количество.", parmes, return-value).
    end.

    assign
      cs_doc-line.doc-qnty  = cs_doc-line.doc-qnty + chg-qnty
      cs_gds-dtl.doc-qnty   = cs_gds-dtl.doc-qnty  + chg-qnty
      cs_doc-line.fact-qnty = cs_doc-line.doc-qnty - gds-qnty
      cs_gds-dtl.fact-qnty  = prt-qnty + cs_gds-dtl.doc-qnty
    .

    if b-c > 0 then do:
        assign
          cs_gds-dtl.fact-qnty  = cs_doc-line.doc-qnty
          cs_gds-dtl.doc-qnty   = cs_doc-line.fact-qnty
        .
    end.


    if cs_trn-doc.exch-rate <> 0 then do:
      assign
        cs_doc-line.price-cli  = cs_doc-line.price-rubl
                            * ( cs_trn-doc.exch-scale / cs_trn-doc.exch-rate )
                            * cs_doc-line.cli-base-rate
      .
    end.

    else assign cs_doc-line.price-cli  = 0.

    if cs_gds-dtl.doc-qnty = 0 then do:
      delete cs_gds-dtl.
    end.
    assign
      cs_doc-line.prt-OK = no.
    find cs_gds-prt where cs_gds-prt.upper-code = cs_goods.prt-root no-lock.
    /* назначено по всем признакам */
    for each cs_gds-dtl where cs_gds-dtl.prod-code = cs_goods.prod-code
                          and cs_gds-dtl.prod-type = cs_goods.prod-type
                          and cs_gds-dtl.artic     = cs_goods.artic
                          and cs_gds-dtl.doc-code  = cs_doc-line.doc-code:
      if cs_gds-dtl.doc-qnty <> 0 and
         cs_gds-dtl.prt-code <> cs_gds-prt.node-code then do:
         assign
         cs_doc-line.prt-OK = yes.
      end.
    end.
end.
/*---------------------------------------------------------------*/
/*простановка док. количеств - приход, расход, списание, возврат */
/*              при коприровании со сканера                      */
/*---------------------------------------------------------------*/
if can-do ({&expense_income_return_write-off}, cs_trn-doc.doc-type)
and (cs_trn-doc.status_ = {&wayb} or cs_trn-doc.status_ = {&inquiry})
and not cs_trn-doc.flag_ then do:
  def var l-inv-on as logical no-undo .
  if cs_trn-doc.status_ <> {&inquiry} and
     not (cs_trn-doc.doc-type = {&income} and cs_trn-doc.flag_ = no) then do:
    { gbl/gdsobjat.i
       cs_doc-line.obj-type
       cs_doc-line.obj-code
       cs_doc-line.artic
       cs_doc-line.prod-type
       cs_doc-line.prod-code
       "'inv-on=request'"
       l-inv-on
       no-error }
    if error-status :error then do:
        undo, return error substitute ("&1 Ошибка получения признака товара на объекте &2 &3.", parmes, error-status :get-message(1), return-value).
    end.
    if l-inv-on then do:
       undo, return error substitute ("&1 товар в инвентаризации", parmes).
    end.
  end.
  case cs_trn-doc.doc-type :
    when {&income} then do:
      if available cs_parts then do:
        /* бар-код соответствует партии */
        if paris-all = ? then do:
          g-log = no.
          message "Товар :" cs_goods.artic cs_goods.gds-name skip
                  "Партия :" cs_parts.part-code "-  количество не 0 !" skip (2)
                  "yes - переписать количество со сканера в партию :" b-qnty skip (2)
                  "no  - прибавить количество со сканера к партии :" cs_parts.qnty "+" b-qnty
          view-as alert-box question buttons yes-no update g-log.
        end.
        else g-log = paris-all.
        if g-log then do:
           assign
            parmes = parmes + " Партия : " + cs_parts.part-code + " Заменено кол-во на : " + string (b-qnty)
            b-qnty = b-qnty - cs_parts.qnty.
        end.
        else do:
          assign
           parmes = parmes + " Партия : " + cs_parts.part-code + " Прибавлено к кол-ву : " + string (cs_parts.qnty) + " + " + string (b-qnty).
        end.
        assign
        b-c = cs_bar-code.b-code. /* резервирование по конкретной партии в rsrv-dtl.p */
      end.
      else b-c = -1.   /* бар-код соответствует товару или признаку */
      assign memexp-qnty = b-qnty.
      if cs_trn-doc.status_ <> {&inquiry} then do:
         run trg/rsrv-dtl.p (input parparentproc,
                         {&rsrv-dtl_action_reserv} + ',' + {&rsrv-dtl_no-message} + varcst-rsrv, buffer cs_gds-dtl, input-output b-qnty, input-output cs_doc-line.price-base, input-output cs_doc-line.price-rubl, b-c, "") no-error.
         if error-status :error then do:
            undo, return error substitute("&1 &2", parmes, return-value).
         end.
      end.
      assign
        cs_doc-line.doc-qnty  = cs_doc-line.doc-qnty + b-qnty
        cs_gds-dtl.doc-qnty   = cs_gds-dtl.doc-qnty  + b-qnty
        cs_doc-line.fact-qnty = cs_doc-line.doc-qnty
        cs_gds-dtl.fact-qnty  = cs_gds-dtl.doc-qnty
      .
      if memexp-qnty <> b-qnty then do:
        assign
        parmes = parmes + " количество " + string (memexp-qnty) + " недоступно. Заменено на " + string (b-qnty)
        parok = "qnty=" + string(memexp-qnty - b-qnty).
      end.
      assign cs_doc-line.cli-qnty = cs_doc-line.doc-qnty / cs_doc-line.cli-base-rate.
      if cs_trn-doc.exch-rate <> 0 then do:
        assign
          cs_doc-line.price-cli  = cs_doc-line.price-rubl
                              * ( cs_trn-doc.exch-scale / cs_trn-doc.exch-rate )
                              * cs_doc-line.cli-base-rate .
      end.
      else do:
        assign
          cs_doc-line.price-cli  = 0.
      end.
      if cs_doc-line.price-base = ? or
         cs_doc-line.price-base = 0 then do:
        { gbl/gdsobjat.i
          cs_trn-doc.obj-type
          cs_trn-doc.obj-code
          cs_goods.artic
          cs_goods.prod-type
          cs_goods.prod-code
          "'insalepr=request'":U
          v-insalepr
        }
        /* подставляем продажную цену */
        if v-insalepr = true then do:
           { str/get-pr.i calc cs_trn-doc.obj-type cs_trn-doc.obj-code cs_goods.gds-code cs_gds-prt.node-code "undo, return error substitute('&1 &2', parmes, return-value)." }
           if gp-price-sale <> ? then undo, return error substitute("&1 &2", parmes, return-value).
           assign
             cs_doc-line.price-cli  = gp-price-sale * (if g-varr-b = "base" then cs_trn-doc.base-rate / cs_trn-doc.base-scale else 1)
                                   / cs_trn-doc.exch-rate * cs_trn-doc.exch-scale * cs_doc-line.cli-base-rate
             cs_doc-line.price-base = gp-price-sale / (if g-varr-b = "base":u then 1 else cs_trn-doc.base-rate * cs_trn-doc.base-scale)
             cs_doc-line.price-rubl = gp-price-sale * (if g-varr-b = "base":u then cs_trn-doc.base-rate / cs_trn-doc.base-scale else 1)
             cs_doc-line.excise     = gp-excise
             cs_doc-line.road-tax   = gp-road-tax.
        end.
        /* подставляем последнюю приходную цену - НДС, если был, учесть не можем */
        else do:
          run cpprclig in this-procedure   (
          input        cs_trn-doc.doc-code              ,
          input        cs_trn-doc.cli-code              ,
          input        cs_trn-doc.cli-type              ,
          input        cs_trn-doc.host-code             ,
          input        cs_trn-doc.base-rate             ,
          input        cs_trn-doc.base-scale            ,
          input        cs_trn-doc.exch-rate             ,
          input        cs_trn-doc.exch-scale            ,
          input        cs_trn-doc.vat-type              ,
          input        cs_trn-doc.slt-type              ,
          input        cs_doc-line.artic                ,
          input        cs_doc-line.prod-type            ,
          input        cs_doc-line.prod-code            ,
          input        yes                              ,
          input        cs_doc-line.cli-base-rate        ,
          input        cs_doc-line.transport-rubl       ,
          input        cs_doc-line.other-rubl           ,
          output       cs_doc-line.price-cli            ,
          output       cs_doc-line.price-base           ,
          output       cs_doc-line.price-rubl           ,
          input-output cs_doc-line.vat-pc               ,
          input-output cs_doc-line.slt-pc               ,
          input-output cs_doc-line.road-tax             ,
          input-output cs_doc-line.excise               ) no-error.
        end.
        if cs_doc-line.vat-pc = ? then do:
          { gbl/pftxvalg.i cs_goods.gds-code {&vat-tax-code} ? cs_trn-doc.host-code cs_trn-doc.obj-type cs_trn-doc.obj-code cs_doc-line.vat-pc no-error }
        end.
        if cs_doc-line.slt-pc   = ?              and
           cs_trn-doc.slt-type <> {&without-slt} then do:
          { gbl/pftxvalg.i cs_goods.gds-code {&slt-tax-code} ? cs_trn-doc.host-code cs_trn-doc.obj-type cs_trn-doc.obj-code cs_doc-line.slt-pc no-error }
        end.
        assign cs_doc-line.prt-OK = yes.
        { str/in-vat.i
          cs_trn-doc.doc-code
          cs_trn-doc.base-rate
          cs_trn-doc.base-scale
          cs_trn-doc.exch-rate
          cs_trn-doc.exch-scale
          cs_trn-doc.vat-type
          cs_trn-doc.slt-type
          cs_doc-line.artic
          cs_doc-line.prod-type
          cs_doc-line.prod-code
          cs_doc-line.price-cli
          cs_doc-line.cli-base-rate
          cs_doc-line.price-rubl
          cs_doc-line.vat-pc
          cs_doc-line.slt-pc
          cs_doc-line.road-tax
          cs_doc-line.transport-rubl
          cs_doc-line.other-rubl
          varprice-cli-cs
          varprice-cli-unit-base-cs
          varprice-road-tax-cs
          varprice-other-exp-cs
          varprice-transport-exp-cs
          varprice-without-abs-cs
          varprice-slt-cs
          varprice-no-slt-cs
          varprice-vat-cs
          varprice-no-vat-slt-cs
          varprice-rubl-cs
          varprice-road-tax-rubl-cs
          varprice-other-exp-rubl-cs
          varprice-transport-exp-rubl-cs
          varprice-without-abs-rubl-cs
          varprice-slt-rubl-cs
          varprice-no-slt-rubl-cs
          varprice-vat-rubl-cs
          varprice-no-vat-slt-rubl-cs
          varprice-base-cs
          varprice-road-tax-base-cs
          varprice-other-exp-base-cs
          varprice-transport-exp-base-cs
          varprice-without-abs-base-cs
          varprice-slt-base-cs
          varprice-no-slt-base-cs
          varprice-vat-base-cs
          varprice-no-vat-slt-base-cs
          no-error
        }
            if error-status :error then do:
              undo, return error substitute ("&1 &2", parmes, return-value).
            end.
            assign
            cs_doc-line.price-cli  = varprice-cli-cs
            cs_doc-line.price-rubl = varprice-rubl-cs
            cs_doc-line.price-base = varprice-base-cs.
      end.
    end.
    when {&expense}   or
    when {&write-off} or
    when {&return}    then do:
      assign
      cs_gds-dtl.discnt-pc = cs_trn-doc.discnt-pc.
      /* подстановка цены, в т.ч. возврат поставщику или перемещение по цене магазина */
      { str/set-pr.i recid(cs_gds-dtl) no ? no-error }
      if error-status :error then do:
        undo, return error substitute ("&1 &2", parmes, return-value).
      end.
      assign
        cs_doc-line.fact-qnty = cs_doc-line.doc-qnty.
        cs_gds-dtl.fact-qnty  = cs_gds-dtl.doc-qnty.
      assign memexp-qnty = b-qnty.
      if cs_trn-doc.status_ <> {&inquiry} then do:
         run trg/rsrv-dtl.p (input parparentproc,
                       {&rsrv-dtl_action_reserv} + ',' + {&rsrv-dtl_no-message} + varcst-rsrv,buffer cs_gds-dtl, input-output b-qnty, input-output cs_doc-line.price-base, input-output cs_doc-line.price-rubl, b-c, "") no-error.
         if error-status :error then do:
           undo, return error substitute ("&1 &2", parmes, return-value).
         end.
      end.
      assign
        cs_doc-line.doc-qnty  = cs_doc-line.doc-qnty + b-qnty
        cs_gds-dtl.doc-qnty   = cs_gds-dtl.doc-qnty  + b-qnty
        cs_doc-line.fact-qnty = cs_doc-line.doc-qnty
        cs_gds-dtl.fact-qnty  = cs_gds-dtl.doc-qnty
        .
      if memexp-qnty <> b-qnty then do:
        assign
        parmes = parmes + " количество " + string (memexp-qnty) + " недоступно. Заменено на " + string (b-qnty)
        parok = "qnty=" + string(memexp-qnty - b-qnty).
      end.
      /*В случае если введен бар-код в накладной, то оставляем пустую болванку для последующего
        редактирования*/
      if parline-mode <> "b-c" then do:
         if cs_gds-dtl.doc-qnty  = 0 then delete cs_gds-dtl.
         if cs_doc-line.doc-qnty = 0 then delete cs_doc-line.
      end.
    end.
  end.
end.
/*Простановка факт количеств*/
if (can-do ({&expense_write-off_return}, cs_trn-doc.doc-type) and
    cs_trn-doc.status_ = {&permitted}) or
   (cs_trn-doc.doc-type = {&income} and
    cs_trn-doc.status_ = {&wayb}    and
    cs_trn-doc.flag_) then do:
  if available cs_parts then do:    /* бар-код соответствует партии */
    if cs_parts.fact-qnty = 0 then do:
       assign
       parmes = parmes + " Партия : " + cs_parts.part-code +
                     " Записано кол-во ФАКТ : " + string (b-qnty).
    end.
    else do:
     if paris-all = ? then do:
      g-log = no.
      message "Товар :" cs_goods.artic cs_goods.gds-name skip
              "Партия :" cs_parts.part-code "- ФАКТ количество не 0 !" skip (2)
              "yes - переписать количество со сканера в партию :" b-qnty skip (2)
              "no - прибавить количество со сканера к партии :" cs_parts.fact-qnty "+" b-qnty
      view-as alert-box question buttons yes-no update g-log.
     end.
     else g-log = paris-all.
     if g-log then do:
       assign
        parmes = parmes + " Партия : " + cs_parts.part-code +
                      " Заменено кол-во ФАКТ на : " + string (b-qnty)
        cs_doc-line.fact-qnty = cs_doc-line.fact-qnty - cs_parts.fact-qnty
        cs_gds-dtl.fact-qnty = cs_gds-dtl.fact-qnty - cs_parts.fact-qnty
        cs_parts.fact-qnty = 0.
      end.
      else do:
        assign
        parmes = parmes + " Партия : " + cs_parts.part-code +
                            " Прибавлено к кол-ву ФАКТ : " + string (cs_parts.fact-qnty) + " + " + string (b-qnty).
      end.
    end.
    if (cs_parts.fact-qnty + b-qnty > cs_parts.qnty) and
       (cs_trn-doc.doc-type <> {&income} or cs_trn-doc.internal) then do:
      parmes = parmes + " Партия : " + cs_parts.part-code +
                    " ФАКТ количество : " + string (cs_parts.fact-qnty + b-qnty) + " уменьшено до кол-ва по док. : " + string (cs_parts.qnty).
      b-qnty = cs_parts.qnty - cs_parts.fact-qnty.
    end.
    assign
    cs_parts.fact-qnty    = cs_parts.fact-qnty    + b-qnty
    cs_doc-line.fact-qnty = cs_doc-line.fact-qnty + b-qnty
    cs_gds-dtl.fact-qnty  = cs_gds-dtl.fact-qnty  + b-qnty.
  end.
  else do:    /* бар-код соответствует товару или признаку */
     if (cs_gds-dtl.fact-qnty + b-qnty > cs_gds-dtl.doc-qnty) and (cs_trn-doc.doc-type <> {&income} or cs_trn-doc.internal) then do:
        parmes = parmes + " Признак : " + string (cs_gds-dtl.prt-code) +
                      " ФАКТ количество : " + string (cs_gds-dtl.fact-qnty + b-qnty) + " уменьшено до кол-ва по док. : " + string (cs_gds-dtl.doc-qnty).
        b-qnty = cs_gds-dtl.doc-qnty - cs_gds-dtl.fact-qnty.
     end.
  end.
  assign memexp-qnty = b-qnty.
  run trg/rsrv-dtl.p (input parparentproc,
                 {&rsrv-dtl_action_reserv} + ',' + {&rsrv-dtl_no-message} + varcst-rsrv, buffer cs_gds-dtl,input-output b-qnty,input-output cs_doc-line.price-base,input-output cs_doc-line.price-rubl, b-c, "") no-error.
  if error-status :error then undo, return error substitute ("&1 &2", parmes, parok).
  assign
  cs_doc-line.fact-qnty = cs_doc-line.fact-qnty + b-qnty
  cs_gds-dtl.fact-qnty  = cs_gds-dtl.fact-qnty  + b-qnty.
  if memexp-qnty <> b-qnty then
   assign
   parmes = parmes + " количество " + string (memexp-qnty) + " недоступно. Заменено на " + string (b-qnty)
   parok = "qnty=" + string(memexp-qnty - b-qnty).
end.
/*проверка на приведение к целому*/
{ str/chkwhole.i
  cs_doc-line.doc-code
  cs_doc-line.artic
  cs_doc-line.prod-type
  cs_doc-line.prod-code
  cs_doc-line.cli-qnty
  cs_doc-line.doc-qnty
  cs_doc-line.fact-qnty
  yes
  no-error
}
if error-status :error then do:
  return error substitute("&1 &2", parmes, return-value).
end.
{ str/is-petrl.i
  cs_doc-line.artic
  cs_doc-line.prod-type
  cs_doc-line.prod-code
  varis-petrolium
  varis-pieces
  no-error
}
if varis-petrolium  and
   not varis-pieces then do:
  /*проверка на факт. кол-во в топливной строке*/
  { str/lnfactqt.i
    parparentproc
    recid(cs_doc-line)
    no
    cs_trn-doc.status_
    cs_trn-doc.flag_
    no-error }
  if error-status :error then do:
    undo, return error substitute("&1 &2", parmes, return-value).
  end.
  { str/corinvln.i cs_doc-line.doc-code
               cs_doc-line.artic
               cs_doc-line.prod-type
               cs_doc-line.prod-code
               ?
               ?
               ?
               ?
               ?
               ?
               rec-inv-line          no-error }
  if error-status :error then do:
    undo, return error substitute( "&1 &2", parmes, return-value ).
  end.
end.
end. /* do */
end procedure.

/* Создание шапки складского документа */
procedure lib-trn_crtrndoc:
define input parameter paracc-date     like ub.trn-doc.acc-date     no-undo.
define input parameter parbge-date     like ub.trn-doc.bge-date     no-undo.
define input parameter parbase-rate    like ub.trn-doc.base-rate    no-undo.
define input parameter parbase-scale   like ub.trn-doc.base-scale   no-undo.
define input parameter parcli-code     like ub.trn-doc.cli-code     no-undo.
define input parameter parcli-type     like ub.trn-doc.cli-type     no-undo.
define input parameter parcli-name     like ub.trn-doc.cli-name     no-undo.
define input parameter parcr-db-num    like ub.trn-doc.cr-db-num    no-undo.
define input parameter parcreid        like ub.trn-doc.creid        no-undo.
define input parameter pardiscnt-type  like ub.trn-doc.discnt-type  no-undo.
define input parameter pardoc-code     like ub.trn-doc.doc-code     no-undo.
define input parameter pardoc-date     like ub.trn-doc.doc-date     no-undo.
define input parameter pardoc-type     like ub.trn-doc.doc-type     no-undo.
define input parameter parflag_        like ub.trn-doc.flag_        no-undo.
define input parameter parhost-code    like ub.trn-doc.host-code    no-undo.
define input parameter parinternal     like ub.trn-doc.internal     no-undo.
define input parameter parobj-code     like ub.trn-doc.obj-code     no-undo.
define input parameter parobj-type     like ub.trn-doc.obj-type     no-undo.
define input parameter paroffice       like ub.trn-doc.office       no-undo.
define input parameter parpay-code     like ub.trn-doc.pay-code     no-undo.
define input parameter parps           like ub.trn-doc.ps           no-undo.
define input parameter parret-supp     like ub.trn-doc.ret-supp     no-undo.
define input parameter parslt-type     like ub.trn-doc.slt-type     no-undo.
define input parameter parstatus_      like ub.trn-doc.status_      no-undo.
define input parameter parvat-type     like ub.trn-doc.vat-type     no-undo.
define input parameter parext-doc-type like ub.trn-doc.ext-doc-type no-undo.
define input parameter parpurch-code   like ub.trn-doc.purch-code   no-undo.
define buffer cr_trn-doc for ub.trn-doc.
define variable varenvd as character no-undo.
define variable vartype as character no-undo.
define variable v-type       as character no-undo .
define variable varstfactdt      as logical   no-undo .
define variable varstfactdt-type as character no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date      as date      no-undo .
define variable v-value-decimal   as decimal   no-undo .
define variable v-value-integer   as integer   no-undo .

do for cr_trn-doc transaction on error undo, return error return-value :

find first cr_trn-doc where cr_trn-doc.doc-code = pardoc-code no-error.
if not available cr_trn-doc then do:
  create cr_trn-doc.
  assign
    cr_trn-doc.acc-date     = paracc-date
    cr_trn-doc.bge-date     = parbge-date
    cr_trn-doc.base-rate    = parbase-rate
    cr_trn-doc.base-scale   = parbase-scale
    cr_trn-doc.cli-code     = parcli-code
    cr_trn-doc.cli-type     = parcli-type
    cr_trn-doc.cli-name     = parcli-name
    cr_trn-doc.cr-db-num    = parcr-db-num
    cr_trn-doc.creid        = parcreid
    cr_trn-doc.discnt-type  = pardiscnt-type
    cr_trn-doc.doc-code     = pardoc-code
    cr_trn-doc.doc-date     = pardoc-date
    cr_trn-doc.doc-type     = pardoc-type
    cr_trn-doc.flag_        = parflag_
    cr_trn-doc.host-code    = parhost-code
    cr_trn-doc.internal     = parinternal
    cr_trn-doc.obj-code     = parobj-code
    cr_trn-doc.obj-type     = parobj-type
    cr_trn-doc.office       = paroffice
    cr_trn-doc.pay-code     = parpay-code
    cr_trn-doc.ps           = parps
    cr_trn-doc.ret-supp     = parret-supp
    cr_trn-doc.slt-type     = parslt-type
    cr_trn-doc.status_      = parstatus_
    cr_trn-doc.vat-type     = parvat-type
    cr_trn-doc.ext-doc-type = parext-doc-type
    cr_trn-doc.purch-code   = parpurch-code
    .
  run clntattr-value in this-procedure (
      cr_trn-doc.obj-type,
      cr_trn-doc.obj-code,
      {&attr-envd},
      output varenvd,
      output vartype).
  if varenvd = "yes":u then do:
    { str/tdat-wrt.i
        cr_trn-doc.doc-code
        {&trdcattr-envd}
        "'yes':U" }
  end.
  { str/trn-rsn.i pardoc-code no-error }
  for each thbjattr_thbj-attr:
    delete thbjattr_thbj-attr.
  end.
  run adm/shattri.p (
      input "get":U
      ,input cr_trn-doc.obj-type
      ,input cr_trn-doc.obj-code
      ,input {&attr-nakl_par}
      ,input  "stfactdt"
      ,output v-value-character
      ,output v-value-date
      ,output v-value-decimal
      ,output v-value-integer
      ,output varstfactdt
      ,output varstfactdt-type
      ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
      ) no-error .
      if error-status :error then varstfactdt = false .
   define variable l-shift-on as logical no-undo.
    { gbl/objat.i
      cr_trn-doc.obj-type
      cr_trn-doc.obj-code
      "'shift-on=request'"
      l-shift-on
    }


  if (cr_trn-doc.ext-doc-type = {&TDEDT_Pri_Vnesh} or
      cr_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh} ) and
      varstfactdt = yes                              and
      l-shift-on <> yes                              then do:
    assign
      cr_trn-doc.fact-date = cr_trn-doc.doc-date
      cr_trn-doc.fact-time = time.
  end.

end.
end.
end procedure.

/* Создание строки складского документа */
procedure lib-trn_crdoclin:
  define input parameter pardoc-code      like ub.doc-line.doc-code     no-undo.
  define input parameter parartic         like ub.doc-line.artic        no-undo.
  define input parameter parprod-type     like ub.doc-line.prod-type    no-undo.
  define input parameter parprod-code     like ub.doc-line.prod-code    no-undo.
  define input parameter parobj-type      like ub.doc-line.obj-type     no-undo.
  define input parameter parobj-code      like ub.doc-line.obj-code     no-undo.
  define input parameter parstatus_       like ub.doc-line.status_      no-undo.
  define input parameter parext-doc-type  like ub.doc-line.ext-doc-type no-undo.
  define input parameter parprt-root      like ub.doc-line.prt-root     no-undo.
  define input parameter parvat-pc        like ub.doc-line.vat-pc       no-undo.
  define input parameter parslt-pc        like ub.doc-line.slt-pc       no-undo.
  define input parameter parcons-vat-pc   like ub.doc-line.cons-vat-pc  no-undo.
  do transaction
  on error undo, return error return-value
  :
    define variable varis-petrolium as logical no-undo.
    define variable varis-pieces    as logical no-undo.
    define buffer cr_doc-line for ub.doc-line.
    define buffer last_doc-line for ub.doc-line.
    define variable varline-num as integer no-undo.
    define variable rec-inv-line as recid no-undo.

    find last last_doc-line where last_doc-line.doc-code = pardoc-code use-index line-num no-lock no-error.
    if not available last_doc-line then do:
      assign varline-num = 1.
    end.
    else do:
      assign varline-num = last_doc-line.line-num + 1.
    end.
    find first cr_doc-line where cr_doc-line.doc-code  = pardoc-code  and
                                cr_doc-line.artic     = parartic     and
                                cr_doc-line.prod-type = parprod-type and
                                cr_doc-line.prod-code = parprod-code no-error.
    if not available cr_doc-line then do:
      run check-use-artic in this-procedure ( input "doc-line":U,
                                              input parartic,
                                              input parprod-type,
                                              input parprod-code  ) no-error.
      if error-status :error then do:
        undo, return error substitute( 'lib-trn_crdoclin: &1', return-value ).
      end.
      create cr_doc-line.
      assign
        cr_doc-line.doc-code      =  pardoc-code
        cr_doc-line.artic         =  parartic
        cr_doc-line.prod-type     =  parprod-type
        cr_doc-line.prod-code     =  parprod-code
        cr_doc-line.obj-type      =  parobj-type
        cr_doc-line.obj-code      =  parobj-code
        cr_doc-line.status_       =  parstatus_
        cr_doc-line.ext-doc-type  =  parext-doc-type
        cr_doc-line.prt-root      =  parprt-root
        cr_doc-line.vat-pc        =  parvat-pc
        cr_doc-line.slt-pc        =  parslt-pc
        cr_doc-line.cons-vat-pc   =  parcons-vat-pc
        cr_doc-line.line-num      =  varline-num
        .

      if ( cr_doc-line.cli-base-rate = 0 or cr_doc-line.cli-base-rate = ? )
        then
        cr_doc-line.cli-base-rate = 1 .

    end.
    { str/corinvln.i
      pardoc-code
      parartic
      parprod-type
      parprod-code
      ?
      ?
      ?
      ?
      ?
      ?
      rec-inv-line
      no-error
    }
    if error-status :error then do:
      undo, return error return-value.
    end.
  end.
end procedure.

/* Создание места хранения для строки складского документа */
procedure lib-trn_crdocpl:
  define input parameter  p-doc-code like ub.doc-line.doc-code no-undo .
  define input parameter  p-gds-code like ub.goods.gds-code    no-undo .
  define input parameter  p-pl-code  like ub.pl-gds.pl-code    no-undo .
  define input parameter  p-obj-type like ub.doc-line.obj-type no-undo .
  define input parameter  p-obj-code like ub.doc-line.obj-code no-undo .
  define output parameter p-rowid    as   rowid                no-undo .

  do transaction
  on error undo, return error return-value
  :
    define buffer buf_doc-pl for ub.doc-pl .

    find first buf_doc-pl share-lock
      where buf_doc-pl.obj-type = p-obj-type
        and buf_doc-pl.obj-code = p-obj-code
        and buf_doc-pl.pl-code  = p-pl-code
        and buf_doc-pl.out-code = p-doc-code
        and buf_doc-pl.gds-code = p-gds-code
      no-error.
    if not available buf_doc-pl then do:
      create buf_doc-pl.
      assign
        buf_doc-pl.obj-type         = p-obj-type
        buf_doc-pl.obj-code         = p-obj-code
        buf_doc-pl.pl-code          = p-pl-code
        buf_doc-pl.out-code         = p-doc-code
        buf_doc-pl.gds-code         = p-gds-code
        buf_doc-pl.cli-qnty         = 0.0
        buf_doc-pl.doc-qnty         = 0.0
        buf_doc-pl.cli-doc-qnty     = 0.0
        buf_doc-pl.fact-qnty        = 0.0
        buf_doc-pl.cli-fact-qnty    = 0.0
        buf_doc-pl.rest-af-qnty     = ?
        buf_doc-pl.rest-bf-qnty     = ?
        buf_doc-pl.cli-rest-af-qnty = ?
        buf_doc-pl.cli-rest-bf-qnty = ?
      .
    end.
    assign
      p-rowid = rowid( buf_doc-pl )
    .
  end.
end procedure.

/* Удаление документа */
procedure lib-trn_del-doc :
  define  input parameter parparentproc      as   widget-handle                no-undo.
  define  input parameter pardoc-code        like ub.trn-doc.doc-code          no-undo.
  define  input parameter parcurdb-num       like ub.clients.db-num            no-undo.
  define  input parameter parfile-name-err   as   character                    no-undo.
  define  input parameter parcorr-inkas-code like ub.c-trn-doc.corr-inkas-code no-undo.
  define  input parameter parcorr-fbr-code   like ub.c-trn-doc.corr-fbr-code   no-undo.
  define  input parameter paruserid          as   character                    no-undo.
  define  input parameter parphdoc-code      like ub.trn-doc.doc-code          no-undo.
  define  input parameter parphchip-num      as   integer                      no-undo.
  define output parameter parchip-num        as   integer                      no-undo.
  define  input parameter parhandle          as   handle                       no-undo.

  define buffer del_trn-doc         for ub.trn-doc.
  define buffer del_clients         for ub.clients.
  define buffer delc_clients        for ub.clients.
  define buffer del_shop            for ub.shop.
  define buffer del_store           for ub.store.
  define buffer del_firm            for ub.firm.
  define buffer del_parts           for ub.parts .
  define buffer del_doc-line        for ub.doc-line.
  define buffer del_rvs-doc         for ub.rvs-doc.
  define buffer bf_fin-ob           for ub.fin-ob.
  define buffer del_fin-ob          for ub.fin-ob.
  define buffer bf_fin-ob-before    for ub.fin-ob-before.
  define buffer del_fin-ob-trn      for ub.fin-ob-trn.
  define buffer bf_fin-ob-trn       for ub.fin-ob-trn.
  define buffer bf_fin-gds-part     for ub.fin-gds-part.
  define buffer bf_clients          for ub.clients.
  define buffer bf-c_clients        for ub.clients.
  define buffer bf_ord-doc          for ub.ord-doc.
  define buffer bf_ord-doc-rcv      for ub.ord-doc-rcv.
  define buffer bufz_trn-doc        for ub.trn-doc.
  define buffer del_turnover-buyer  for ub.turnover-buyer  .

  define variable varactive        like ub.store.active         no-undo.
  define variable varhold          as   character               no-undo.
  define variable varhold-type     as   character               no-undo.
  define variable varflag-doc-err  as   logical                 no-undo.
  define variable g-log            as   logical                 no-undo.
  define variable varmes-line      as   character               no-undo.
  define variable varmes           as   character               no-undo.
  define variable varobj-date      as   date                    no-undo.
  define variable varshift-date    like ub.shift-obj.shift-date no-undo.
  define variable varshift-num     like ub.shift-obj.shift-num  no-undo.
  define variable varshift-name    as   character                no-undo.
  define variable l-shift-on       as   logical                 no-undo.
  define variable vartime          as   integer                 no-undo.
  define variable vardel-line      as   integer                 no-undo.
  define variable varmessage       as   character               no-undo.
  define variable varchip-num-main as   integer                 no-undo.
  define variable l-inv-on         as   logical                 no-undo.
  define variable varcut-status    as   integer                 no-undo.
  define variable varcut-date      as   date                    no-undo.
  define variable varcut-fin-date  as   date                    no-undo.
  define variable vardoc-hold      as   logical                 no-undo.
  define variable is-petrol        as   logical                 no-undo.
  define variable is-pieces        as   logical                 no-undo.
  define variable varsale-auto     as   character               no-undo.
  define variable vartype          as   character               no-undo.
  define variable parhost-code     like ub.trn-doc.host-code    no-undo.
  define variable parobj-type      like ub.trn-doc.obj-type     no-undo.
  define variable parobj-code      like ub.trn-doc.obj-code     no-undo.
  define variable pararm-code      as   character               no-undo.
  define variable varcli-qnty      as   decimal                 no-undo.
  define variable v-mess           as character no-undo .
  define variable v-flag-del as logical   no-undo .
  define variable v-attr-value  as character no-undo .
  define variable v-attr-type  as character no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date as date  no-undo .
define variable v-date-close-period as date      no-undo .
define variable v-value-decimal as decimal   no-undo .
define variable v-value-integer as integer   no-undo .
define variable v-value-logical as logical   no-undo .
define variable v-value-type as character no-undo .
define variable v-back-date as logical   no-undo .
define variable v-back-date-type as character no-undo .


  { gbl/getcntxt.i def }
  do on error undo, return error return-value :
  { gbl/getcntxt.i get }
    assign
      vartime = time.
    run waitfram-show in parhandle ( input substitute( "Удаления документа &1.", pardoc-code ) + {&new-line} +
                                           substitute( "Время: &1.", string( time - vartime, "hh:mm:ss":U ) ) ) no-error.
    find first del_trn-doc where
               del_trn-doc.doc-code = pardoc-code.
    find first del_clients where
               del_clients.obj-type = del_trn-doc.obj-type and
               del_clients.obj-code = del_trn-doc.obj-code .
    { gbl/curobjdt.i del_trn-doc.obj-type del_trn-doc.obj-code varobj-date no-error }
    if error-status :error or
       varobj-date = ?     then do:
      return error "Нет текущей даты на объекте документа.".
    end.
    { gbl/cutd-obj.i del_trn-doc.obj-type del_trn-doc.obj-code varcut-status varcut-date varcut-fin-date no-error }
    if error-status :error then do:
      return error substitute( "Ошибка при определении состояния объекта по обрезанию данных &1 &2.", return-value , error-status :get-message(1)  ).
    end.
    { gbl/objat.i
      del_trn-doc.obj-type
      del_trn-doc.obj-code
      "'shift-on=request'"
      l-shift-on
    }
    if l-shift-on = yes then do:
      /* на объекте включены смены */
      { gbl/curshift.i
          del_trn-doc.obj-type
          del_trn-doc.obj-code
          varshift-date
          varshift-num
          varshift-name
          no-error
      }
      if del_trn-doc.status_ = {&fact} and error-status :error then do:
        return error "Ошибка при поиске текущей смены на объекте".
      end.
    end.
    else do:
      assign
        varshift-date = ?
        varshift-num  = ?
        varshift-name = ?.
    end.

    if del_clients.obj-type = {&shop} then do:
      assign
        varactive = yes.
    end.
    else do:
      find first del_store where del_store.obj-code = del_clients.obj-code.
      assign
        varactive = del_store.active.
    end.
    if del_trn-doc.status_ = {&permitted} or
       del_trn-doc.status_ = {&wayb}      and del_trn-doc.flag_ = yes and del_trn-doc.doc-type = {&income}
    then do:
      run waitfram-hide in parhandle no-error.
      return error "Данный документ не может быть удален.".
    end.
    if not ( ( parcurdb-num          = del_clients.db-num and
               varactive             = yes              ) or
             ( parcurdb-num          = 0                  and
               varactive             = no               ) or
             ( parcurdb-num          = 0                  and
               del_trn-doc.flag_     = no                 and
               del_trn-doc.cr-db-num = 0                  and
             ( del_trn-doc.status_   = {&wayb}            or
               del_trn-doc.status_   = {&manufactured}    or
               del_trn-doc.status_   = {&inquiry}   ) ) )
    then do:
      run waitfram-hide in parhandle no-error.
      return error "Накладная может быть удалена только на активной стороне или в месте ее создания в начальном статусе.".
    end.
    if not ( del_trn-doc.status_ = {&wayb}         and not del_trn-doc.flag_ or
             del_trn-doc.status_ = {&manufactured} and not del_trn-doc.flag_ or
             del_trn-doc.status_ = {&wayb}         and     del_trn-doc.flag_ and not del_trn-doc.doc-type = {&income} or
             del_trn-doc.status_ = {&inquiry}      and not del_trn-doc.flag_ or
             del_trn-doc.status_ = {&fact}  ) then do:
      run waitfram-hide in parhandle no-error.
      return error substitute( "Некорректный статус-флаг &1-&2 документа &3.",
                               del_trn-doc.status_, string( del_trn-doc.flag_, "+/-":U ), del_trn-doc.doc-code ).
    end.
      /* проверка на наличие привязанных ДопРасходов */
      define variable is-addcharges as logical   no-undo .
      define variable v-kol-rel as integer   no-undo .
      define buffer buf_add-trn  for ub.add-trn  .
      define buffer buf2_add-trn for ub.add-trn  .
      define buffer buf_add-doc  for ub.add-doc  .
      run chk-is-addcharges in parparentproc (output is-addcharges) no-error .
        if error-status :error then is-addcharges = false .
        if is-addcharges = true then do:
           find first buf_add-trn no-lock where
                      buf_add-trn.trn-doc-code = del_trn-doc.doc-code no-error .
           if available  buf_add-trn then do:
              v-kol-rel = 0 .
              for each  buf2_add-trn no-lock where
                        buf2_add-trn.doc-code = buf_add-trn.doc-code :
                        v-kol-rel = v-kol-rel + 1.
              end.
              if v-kol-rel > 1 then  return error substitute( "Для накладной № &1 есть ДопРасход № &2 на несколько накладных . Удаление документа невозможно. Удалите сначала ДопРасход", del_trn-doc.doc-code ,buf_add-trn.doc-code ).
              if v-kol-rel = 1 then do:
                 find first buf_add-doc exclusive-lock where
                            buf_add-doc.doc-code = buf_add-trn.doc-code no-error .
                 if available buf_add-doc then do:
                    delete buf_add-doc .
                 end.
              end.
           end.
        end.
    if del_trn-doc.status_ = {&fact} then do:
  /* проверяем дату закрытого периода */
  for each thbjattr_thbj-attr:
    delete thbjattr_thbj-attr.
  end.
  run adm/shattri.p (
      input "get":U
      ,input del_trn-doc.obj-type
      ,input del_trn-doc.obj-code
      ,input {&attr-nakl_par}
      ,input  "back-date"
      ,output v-value-character
      ,output v-value-date
      ,output v-value-decimal
      ,output v-value-integer
      ,output v-back-date
      ,output v-value-type
      ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
      ) no-error .
      if error-status :error then v-back-date = false .
      if v-back-date <> true then do:
          if del_trn-doc.fact-date <> varobj-date  then do:
            return error substitute( "Запрещено работать с документами (в данном случае удалять) задним числом ") .
          end.
      end.
  /* проверяем дату закрытого периода */
  for each thbjattr_thbj-attr:
    delete thbjattr_thbj-attr.
  end.
  run adm/shattri.p (
      input "get":U
      ,input del_trn-doc.obj-type
      ,input del_trn-doc.obj-code
      ,input {&attr-nakl_par}
      ,input  "date-close-period"
      ,output v-value-character
      ,output v-date-close-period
      ,output v-value-decimal
      ,output v-value-integer
      ,output v-value-logical
      ,output v-value-type
      ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
      ) no-error .
      if error-status :error then v-date-close-period = date('').
   if v-date-close-period <> date('') then do:
  if  del_trn-doc.fact-date < v-date-close-period
  then do:
    return error substitute(
      "Дата закрытия документа &1 более ранняя, чем дата закрытия периода &2
       Дата закрытия документа  &3 &2
       Дата закрытия периода    &4 &2
       Объект &5 &6 "
       ,
       del_trn-doc.doc-code  ,
       {&new-line}  ,
       string ( del_trn-doc.fact-date, "99/99/9999") ,
       string ( v-date-close-period,   "99/99/9999") ,
                del_trn-doc.obj-type ,
                del_trn-doc.obj-code  ) .
  end.
  end.
  /* для внутреннего перемещения */
  if del_trn-doc.cli-type = {&shop} or del_trn-doc.cli-type = {&stock}  then do:
  for each thbjattr_thbj-attr:
    delete thbjattr_thbj-attr.
  end.
      run adm/shattri.p (
          input "get":U
          ,input del_trn-doc.cli-type
          ,input del_trn-doc.cli-code
          ,input {&attr-nakl_par}
          ,input  "date-close-period"
          ,output v-value-character
          ,output v-date-close-period
          ,output v-value-decimal
          ,output v-value-integer
          ,output v-value-logical
          ,output v-value-type
          ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
          ) no-error .
          if error-status :error then v-date-close-period = date('').
      if v-date-close-period <> date('') then do:
      if  del_trn-doc.fact-date < v-date-close-period
      then do:
        return error substitute(
          "Дата закрытия документа &1 более ранняя, чем дата закрытия периода &2
          Дата закрытия документа  &3 &2
          Дата закрытия периода    &4 &2
          Объект &5 &6 "
          ,
          del_trn-doc.doc-code  ,
          {&new-line}  ,
          string ( del_trn-doc.fact-date, "99/99/9999") ,
          string ( v-date-close-period,   "99/99/9999") ,
                    del_trn-doc.cli-type ,
                    del_trn-doc.cli-code  ) .
      end.

  end.
  end.
  /* для межфирменного перемещения */
  if del_trn-doc.hold-obj-type = {&shop} or del_trn-doc.hold-obj-type = {&stock}  then do:
  for each thbjattr_thbj-attr:
    delete thbjattr_thbj-attr.
  end.
      run adm/shattri.p (
          input "get":U
          ,input del_trn-doc.hold-obj-type
          ,input del_trn-doc.hold-obj-code
          ,input {&attr-nakl_par}
          ,input  "date-close-period"
          ,output v-value-character
          ,output v-date-close-period
          ,output v-value-decimal
          ,output v-value-integer
          ,output v-value-logical
          ,output v-value-type
          ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
          ) no-error .
          if error-status :error then v-date-close-period = date('').
      if v-date-close-period <> date('') then do:
      if  del_trn-doc.fact-date < v-date-close-period
      then do:
        return error substitute(
          "Дата закрытия документа &1 более ранняя (или равна), чем дата закрытия периода &2
          Дата закрытия документа  &3 &2
          Дата закрытия периода    &4 &2
          Объект &5 &6 "
          ,
          del_trn-doc.doc-code  ,
          {&new-line}  ,
          string ( del_trn-doc.fact-date, "99/99/9999") ,
          string ( v-date-close-period,   "99/99/9999") ,
                    del_trn-doc.hold-obj-type ,
                    del_trn-doc.hold-obj-code  ) .
      end.
  end.
  end.

  /* проверяем дату начала подробного складского архива по товарам */
  define variable v-arh-detail-date as date      no-undo .

  run clntattr-value in this-procedure
    (input  del_trn-doc.obj-type    /* p-obj-type */
    ,input  del_trn-doc.obj-code    /* p-obj-code */
    ,input  {&attr-arh-detail-date} /* p-code     */
    ,output v-attr-value            /* p-value    */
    ,output v-attr-type             /* p-type     */
    ) .

  if v-attr-type = {&type-date}
  then do:
    assign
      v-arh-detail-date = date(v-attr-value)
    .
  end.

  if  v-arh-detail-date <> ?
  and del_trn-doc.fact-date < v-arh-detail-date
  then do:
    return error substitute(
      "Дата закрытия документа &1 более ранняя, чем дата начала подробного складского архива по товарам &2
       Дата закрытия документа  &3 &2
       Дата начала подробного складского архива по товарам &4" ,
       del_trn-doc.doc-code  ,
       {&new-line}  ,
       string ( del_trn-doc.fact-date, "99/99/9999") ,
       string ( v-arh-detail-date,     "99/99/9999")
       ) .
  end.


      case varcut-status :
        when 1 then do:
          /* 1 - БД никогда не обрезалась ( при этом p-cut-date = ? ) */
        end.
        when 2 then do:
          /* 2 - БД обрезалась "полностью" */
        end.
        when 3 then do:
          /* 3 - Обрезались документы по запрашиваемому объекту, но БД не была выгружена */
          if varcut-date > del_trn-doc.fact-date then do:
            return error substitute( "В главной базе данных проводилось обрезание &3 по объекту &1 &2. База данных этого объекта не была выгружена. Удаление документа невозможно.", del_trn-doc.obj-type, del_trn-doc.obj-code ,varcut-date ).
          end.
        end.
        when 4 then do:
          /* 4 - БД была выгружена после обрезания документов по запрашиваемому объекту */
        end.
        otherwise do:
          return error substitute( "Неверный статус объекта &1 получен от программы cutd-obj.", varcut-status ).
        end.
      end case. /* varcut-status */
      /* Нельзя удалять закрытые на факт внутренние разных баз данных, межфирменных документы и инвентаризацию */
      { gbl/conf-rd.i
        "'holding':u"
        0
        "'':u"
        0
        "'':u"
        "'':u"
        "'':u"
        no
        varhold
        varhold-type
        no-error
      }
      { gbl/hold-doc.i
        del_trn-doc.doc-code
        vardoc-hold
      }

      if varhold     = "yes" and
         vardoc-hold =  yes  then do:
        run waitfram-hide in parhandle no-error.
        /* Межфирменные документы, закрытые до факта */
        if del_trn-doc.ext-doc-type = {&TDEDT_Pri_Vnesh}     or
           del_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh}     or
           del_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh_VP}  or
           del_trn-doc.ext-doc-type = {&TDEDT_Vozvrat_Vnesh} then do:
          case del_trn-doc.doc-type :
            when {&income}
            then do:
              { gbl/chk-actg.i
                  parcurdb-num
                  paruserid
                  {&action-head-code-main}
                  'actn_hold-income_del-fact':U
                  {&cntxt-object}
                  v-cntxt-host-code-obj
                  v-cntxt-obj-type
                  v-cntxt-obj-code
                  0
                  0
                  0
                  yes
                  g-log
                  no-error
              }
            end.
            when {&expense}
            then do:
              { gbl/chk-actg.i
                  parcurdb-num
                  paruserid
                  {&action-head-code-main}
                  'actn_hold-expense_del-fact':U
                  {&cntxt-object}
                  v-cntxt-host-code-obj
                  v-cntxt-obj-type
                  v-cntxt-obj-code
                  0
                  0
                  0
                  yes
                  g-log
                  no-error
              }
            end.
            when {&return}
            then do:
              { gbl/chk-actg.i
                  parcurdb-num
                  paruserid
                  {&action-head-code-main}
                  'actn_hold-return_del-fact':U
                  {&cntxt-object}
                  v-cntxt-host-code-obj
                  v-cntxt-obj-type
                  v-cntxt-obj-code
                  0
                  0
                  0
                  yes
                  g-log
                  no-error
              }
            end.
          end case. /* del_trn-doc.doc-type */
          if error-status :error or
             g-log = no          then do:
            run waitfram-hide in parhandle no-error.
            undo, return error "Вы не имеете прав на удаление документа, закрытого на факт.".
          end.
        end.
      end. /* hold */
      if del_trn-doc.ext-doc-type = {&TDEDT_Pri_Perem}     or
         del_trn-doc.ext-doc-type = {&TDEDT_Ras_Perem}     or
         del_trn-doc.ext-doc-type = {&TDEDT_Vozvrat_Perem} then do:
        find first bf_clients no-lock where
                   bf_clients.obj-type = del_trn-doc.obj-type and
                   bf_clients.obj-code = del_trn-doc.obj-code .
        find first bf-c_clients no-lock where
                   bf-c_clients.obj-type = del_trn-doc.cli-type and
                   bf-c_clients.obj-code = del_trn-doc.cli-code .
        if bf_clients.db-num <> bf-c_clients.db-num then do:
          return error substitute( "Во внутреннем документе &1 по объекту &2 &3 базы данных &4 контрагентом является объект &5 &6 базы данных &7. Нельзя удалять внутренние документы относящиеся к разным базам данных.",
                                   del_trn-doc.doc-code,
                                   del_trn-doc.obj-type,
                                   del_trn-doc.obj-code,
                                   bf_clients.db-num,
                                   del_trn-doc.cli-type,
                                   del_trn-doc.cli-code,
                                   bf-c_clients.db-num
                                 ) .
        end.
      end.
      /*нельзя удалять автоматические документы привязанные к продаже - а они могут иметь обычный doc-type и ext-doc-type*/
      if LOOKUP(del_trn-doc.ext-doc-type, {&sale-add-ext-doc-types}) > 0 then do:
        define buffer buf_sale-doc for ub.sale-doc.
        find first buf_sale-doc no-lock where
                 buf_sale-doc.doc-code = del_trn-doc.doc-code
             and buf_sale-doc.inkas-code = del_trn-doc.out-code
             and buf_sale-doc.order > 0 no-error.
        if available buf_sale-doc then do:
        /* найдем атрибут этого документа */
          run waitfram-hide in parhandle no-error.
          undo, return error substitute("Автодокумент &1, созданный по чекам продажи &2, удаляется только при удалении продажи"
                                  ,del_trn-doc.doc-code
                                  ,del_trn-doc.out-code
                                  ).
        end.
      end.

      if del_trn-doc.ext-doc-type = {&TDEDT_Ras_Perem}
      then do:
        { gbl/chk-actg.i
          parcurdb-num
          paruserid
          {&action-head-code-main}
          'actn_tdedt-ras-perem_del-fact':u
          {&cntxt-object}
          del_trn-doc.host-code
          del_trn-doc.obj-type
          del_trn-doc.obj-code
          0
          0
          0
          true
          g-log
        }
      end.
      else do:
        if del_trn-doc.ext-doc-type = {&TDEDT_Peresort}
        then do:
          { gbl/chk-actg.i
            parcurdb-num
            paruserid
            {&action-head-code-main}
            'actn_tdedt-peresort_del-fact':u
            {&cntxt-object}
            del_trn-doc.host-code
            del_trn-doc.obj-type
            del_trn-doc.obj-code
            0
            0
            0
            true
            g-log
          }
        end.
        else do:
          case del_trn-doc.doc-type
          :
            when {&income}
            then do:
              { gbl/chk-actg.i
                parcurdb-num
                paruserid
                {&action-head-code-main}
                'actn_income_del-fact':u
                {&cntxt-object}
                del_trn-doc.host-code
                del_trn-doc.obj-type
                del_trn-doc.obj-code
                0
                0
                0
                true
                g-log
              }
            end.
            when {&expense}
            then do:
              { gbl/chk-actg.i
                parcurdb-num
                paruserid
                {&action-head-code-main}
                'actn_expense_del-fact':u
                {&cntxt-object}
                del_trn-doc.host-code
                del_trn-doc.obj-type
                del_trn-doc.obj-code
                0
                0
                0
                true
                g-log
              }
            end.
            when {&write-off}
            then do:
              { gbl/chk-actg.i
                parcurdb-num
                paruserid
                {&action-head-code-main}
                'actn_write-off_del-fact':u
                {&cntxt-object}
                del_trn-doc.host-code
                del_trn-doc.obj-type
                del_trn-doc.obj-code
                0
                0
                0
                true
                g-log
              }
            end.
            when {&return}
            then do:
              { gbl/chk-actg.i
                parcurdb-num
                paruserid
                {&action-head-code-main}
                'actn_return_del-fact':u
                {&cntxt-object}
                del_trn-doc.host-code
                del_trn-doc.obj-type
                del_trn-doc.obj-code
                0
                0
                0
                true
                g-log
              }
            end.
            when {&inventory}
            then do:
              { gbl/chk-actg.i
                parcurdb-num
                paruserid
                {&action-head-code-main}
                'actn_inventory_del-fact':u
                {&cntxt-object}
                del_trn-doc.host-code
                del_trn-doc.obj-type
                del_trn-doc.obj-code
                0
                0
                0
                true
                g-log
              }
            end.
            otherwise do:
              message
                vss-workfile vss-revision vss-description skip
                "Неизвестный тип документа" skip
                "Тип документа" del_trn-doc.doc-type skip
                "Код документа" del_trn-doc.doc-code skip
                view-as alert-box error .
              undo, return error return-value .
            end.
          end case.
        end.
      end.
      if g-log = no
      then do:
        run waitfram-hide in parhandle no-error.
        undo, return error "Вы не имеете прав на удаление документа, закрытого на факт.".
      end.
    end.
    else do:
      if del_trn-doc.ext-doc-type = {&TDEDT_Corr_Acc_Price}
      then do:
        { gbl/chk-actg.i
          parcurdb-num
          paruserid
          {&action-head-code-main}
          'actn_corr-acc-pr-view_preparation':u
          {&cntxt-object}
          del_trn-doc.host-code
          del_trn-doc.obj-type
          del_trn-doc.obj-code
          0
          0
          0
          true
          g-log
        }
      end.
      else do:
        if del_trn-doc.ext-doc-type = {&TDEDT_Peresort}
        then do:
          { gbl/chk-actg.i
            parcurdb-num
            paruserid
            {&action-head-code-main}
            'actn_tdedt-peresort_preparation':u
            {&cntxt-object}
            del_trn-doc.host-code
            del_trn-doc.obj-type
            del_trn-doc.obj-code
            0
            0
            0
            true
            g-log
          }
        end.
        else do:
          case del_trn-doc.doc-type
          :
            when {&income}
            then do:
              { gbl/chk-actg.i
                parcurdb-num
                paruserid
                {&action-head-code-main}
                'actn_income_preparation':u
                {&cntxt-object}
                del_trn-doc.host-code
                del_trn-doc.obj-type
                del_trn-doc.obj-code
                0
                0
                0
                true
                g-log
              }
            end.
            when {&expense}
            then do:
              if del_trn-doc.status_ = {&inquiry} then do:
                { gbl/chk-actg.i
                  parcurdb-num
                  paruserid
                  {&action-head-code-main}
                  'actn_expense_del-inquiry':u
                  {&cntxt-object}
                  del_trn-doc.host-code
                  del_trn-doc.obj-type
                  del_trn-doc.obj-code
                  0
                  0
                  0
                  true
                  g-log
                }
              end.
              else if del_trn-doc.status_ = {&wayb} and del_trn-doc.flag_ then do:
                { gbl/chk-actg.i
                  parcurdb-num
                  paruserid
                  {&action-head-code-main}
                  'actn_expense_del-wayb':u
                  {&cntxt-object}
                  del_trn-doc.host-code
                  del_trn-doc.obj-type
                  del_trn-doc.obj-code
                  0
                  0
                  0
                  true
                  g-log
                }
              end.
              else if del_trn-doc.status_ = {&wayb} and not del_trn-doc.flag_ then do:
                { gbl/chk-actg.i
                  parcurdb-num
                  paruserid
                  {&action-head-code-main}
                  'actn_expense_del-wayb-minus':u
                  {&cntxt-object}
                  del_trn-doc.host-code
                  del_trn-doc.obj-type
                  del_trn-doc.obj-code
                  0
                  0
                  0
                  true
                  g-log
                }
              end.
              else do:
                { gbl/chk-actg.i
                  parcurdb-num
                  paruserid
                  {&action-head-code-main}
                  'actn_expense_preparation':u
                  {&cntxt-object}
                  del_trn-doc.host-code
                  del_trn-doc.obj-type
                  del_trn-doc.obj-code
                  0
                  0
                  0
                  true
                  g-log
                }
              end.
            end.
            when {&write-off}
            then do:
              { gbl/chk-actg.i
                parcurdb-num
                paruserid
                {&action-head-code-main}
                'actn_write-off_preparation':u
                {&cntxt-object}
                del_trn-doc.host-code
                del_trn-doc.obj-type
                del_trn-doc.obj-code
                0
                0
                0
                true
                g-log
              }
            end.
            when {&return}
            then do:
              { gbl/chk-actg.i
                parcurdb-num
                paruserid
                {&action-head-code-main}
                'actn_return_preparation':u
                {&cntxt-object}
                del_trn-doc.host-code
                del_trn-doc.obj-type
                del_trn-doc.obj-code
                0
                0
                0
                true
                g-log
              }
            end.
            when {&inventory}
            then do:
              { gbl/chk-actg.i
                parcurdb-num
                paruserid
                {&action-head-code-main}
                'actn_inventory_delete':u
                {&cntxt-object}
                del_trn-doc.host-code
                del_trn-doc.obj-type
                del_trn-doc.obj-code
                0
                0
                0
                true
                g-log
              }
            end.
            otherwise do:
              message
                vss-workfile vss-revision vss-description skip
                "Неизвестный тип документа" skip
                "Тип документа" del_trn-doc.doc-type skip
                "Код документа" del_trn-doc.doc-code skip
                view-as alert-box error .
              undo, return error return-value .
            end.
          end case.
        end.
      end.
      if g-log <> true
      then do:
        run waitfram-hide in parhandle no-error.
        return error "Вы не имеете прав на удаление документа.".
      end.
    end.

    do on error undo, return error return-value :
      /* Переведем запрос ГОТОВ в статус ОТКАЗ */
      for each  bufz_trn-doc exclusive-lock where
                bufz_trn-doc.doc-code = del_trn-doc.out-code and
                bufz_trn-doc.status_  = {&ready}             :
        assign
            bufz_trn-doc.status_ = {&rejected}
        .
      end.

      if del_trn-doc.status_ = {&fact}
      then do:
        run str/chkdeltr.p
          ( input parcurdb-num
          , input paruserid
          , input del_trn-doc.doc-code
          , input parphdoc-code
          , input parfile-name-err
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.
        { str/corrsprc.i
          "'-'"
          del_trn-doc.doc-code
          v-mess
          no-error
        }
        if error-status :error
        then do:
          undo, return error return-value .
        end.
      end.

      /* Если документ удаляется по факту, то разрезервирование и работа с партиями в процедуре trndocdl.p */
      if del_trn-doc.status_ <> {&fact}    and
         del_trn-doc.status_ <> {&inquiry} then do:
        assign
          del_trn-doc.flag_ = no.
        assign
          vardel-line = 0.
        for each del_doc-line where
                 del_doc-line.doc-code = del_trn-doc.doc-code
        on error undo, return error return-value :
          run waitfram-join in parhandle (
             input substitute( "Разрезервирование строк документа &1 перед удалением.", pardoc-code ),
             input substitute( " Товар &1 &2 &3.", del_doc-line.artic, del_doc-line.prod-type, del_doc-line.prod-code ),
             input substitute( " Всего удалено строк: &1", vardel-line ) +
                   substitute( " Время: &1.", string( time - vartime, "hh:mm:ss":U ) ),
            output varmessage            ) no-error.
          run waitfram-show in parhandle ( input varmessage ) no-error.
          assign
            vardel-line = vardel-line + 1.
          if del_trn-doc.ext-doc-type = {&TDEDT_Peresort} then do:
            { gbl/gdsobjat.i del_doc-line.obj-type del_doc-line.obj-code del_doc-line.artic del_doc-line.prod-type del_doc-line.prod-code "'inv-on=false'" l-inv-on no-error }
            if error-status :error then do:
              undo, return error SUBSTITUTE ("Ошибка установки атрибута товара на объекте. Документ &1. Объект &2 &3. Артикул &4 &5 &6. Признак товара в инвентаризации &7.",
                                            del_doc-line.doc-code, del_doc-line.obj-type, del_doc-line.obj-code, del_doc-line.artic, del_doc-line.prod-type, del_doc-line.prod-code, l-inv-on).
            end.
          end.
          run trg/rsrv-del.p ( input del_doc-line.doc-code,
                           input del_doc-line.artic,
                           input del_doc-line.prod-type,
                           input del_doc-line.prod-code ) no-error.
          if error-status :error then do:
            run waitfram-hide in parhandle no-error.
            undo, return error "Ошибка при разрезервировании.".
          end.
        end.
      end.
      if del_trn-doc.status_ = {&fact} then do:
        if parphchip-num <> ? then do:
          assign
            varchip-num-main = parphchip-num.
        end.
        else do:
          assign
            varchip-num-main = next-value( s-corr-chip, {&db-name_schema} )
          .
        end.
        assign
          parchip-num = varchip-num-main
        .
        /* Удаляем, связанные с документом сверки */
        for each del_rvs-doc exclusive-lock
          where del_rvs-doc.out-code = del_trn-doc.doc-code
        on error undo, return error return-value
        :
          run waitfram-join in parhandle (
             input substitute( "Создание истории по сверкам документа &1 и их удаление.", pardoc-code ),
             input '':U,
             input substitute( " Время: &1.", string( time - vartime, "hh:mm:ss":U ) ),
            output varmessage            ) no-error.
          run waitfram-show in parhandle ( input varmessage ) no-error.

          { str/hstc-rvs.i
            "buffer del_rvs-doc"
            integer({&hn-delete})
            del_trn-doc.doc-code
            varchip-num-main
            no-error
          }
          if error-status :error then do:
            run waitfram-hide in parhandle no-error.
            undo, return error return-value.
          end.
          assign
            del_rvs-doc.is-del = yes
          .
          delete del_rvs-doc.
        end.

        run waitfram-join in parhandle (  input substitute( "Создание истории по удаляемому документу &1.", pardoc-code ),
                                          input '':U,
                                          input substitute( " Время: &1.", string( time - vartime, "hh:mm:ss":U ) ),
                                         output varmessage ) no-error.
        run waitfram-show in parhandle (  input varmessage ) no-error.

        /* Создаем историю по удаленной накладной */
        assign
          del_trn-doc.is-del = yes
        .
        if del_trn-doc.d-card <> "":U and del_trn-doc.d-card <> ? then do:
          run str/saledc.p ( input parparentproc
                      , input ? /*p-parent-handle*/
                      , input ? /*p-log-handle*/
                      , input {&dct-proc_trn-doc-delete}
                      , input ? /*p-emitent-host-code*/
                      , input "" /*p-type*/
                      , input 0 /*p-profile-id*/
                      , input 0 /*p-codex-id*/
                      , input 0 /*p-ruleset-id*/
                      , input parcurdb-num
                      , input del_trn-doc.doc-code
                      , input del_trn-doc.doc-date
                      , input del_trn-doc.fact-date
                      , input ? /*cre-pay*/
                      , input ( -1 ) /*p-sign*/
                      , input ( if del_trn-doc.ext-doc-type = {&TDEDT_Vozvrat_Vnesh} then -1 else 1 ) /* p-direction */
                      , input yes /*p-save*/
                      ) no-error .
          if error-status :error then do:
            run waitfram-hide in parhandle no-error.
            undo, return error return-value.
          end.
        end.
        run lib-trn_hstd-trn in this-procedure ( input del_trn-doc.doc-code, input varchip-num-main ) no-error.
        if error-status :error then do:
          run waitfram-hide in parhandle no-error.
          undo, return error return-value.
        end.
        { str/hstc-trn.i
          recid(del_trn-doc)
          varobj-date
          varshift-date
          varshift-num
          varshift-name
          parcorr-inkas-code
          parcorr-fbr-code
          paruserid
          parcurdb-num
          varchip-num-main
          no-error }
        if error-status :error then do:
          run waitfram-hide in parhandle no-error.
          undo, return error return-value.
        end.
        run trg/trndocdl.p ( input del_trn-doc.doc-code, input varchip-num-main ) no-error.
        if error-status :error then do:
          run waitfram-hide in parhandle no-error.
          undo, return error substitute("Ошибка при удалении складского документа &2&1&3", {&new-line}, del_trn-doc.doc-code, return-value ).
        end.
      end.
      else do :    /*   del_trn-doc.status_ <> {&fact}   */

        /* Удаляем незакрытые ФО по документу  */
        define variable v-del-fo as logical no-undo .
       /* define variable v-del-fo-trn as logical no-undo .
        define variable v-mod-fo as logical no-undo .   */
        define variable v-kol-trn-fo as integer no-undo .
        v-del-fo = true .
       /* v-del-fo-trn = true .*/
        /*v-mod-fo = false .*/
        v-kol-trn-fo = 0.
        for each del_fin-ob-trn where del_fin-ob-trn.trn-doc-code = del_trn-doc.doc-code  and
                                      del_fin-ob-trn.host-code    = del_trn-doc.host-code exclusive-lock,
                each del_fin-ob where del_fin-ob.doc-code = del_fin-ob-trn.doc-code  exclusive-lock
                :

             /*   for each bf_fin-doc no-lock,
                    each bf_fin-connect where bf_fin-connect.fin-doc-code = bf_fin-doc.fin-doc-code and
                                              bf_fin-connect.fin-ob-code  = del_fin-ob.doc-code     no-lock :
                      v-del-fo = false.
                      v-del-fo-trn = false.
                end.  */
                for each bf_fin-ob-trn where bf_fin-ob-trn.doc-code = del_fin-ob.doc-code and
						 bf_fin-ob-trn.trn-doc-code <> del_trn-doc.doc-code	 no-lock:
                      v-kol-trn-fo = v-kol-trn-fo + 1.
                end.
                    if v-kol-trn-fo > 0 then do :
                      assign
                        v-del-fo = false .
                      /* v-mod-fo = true .  */
                      message substitute ("ФО №&1 по данной накладной не будет удалено, т.к. сформированно по нескольким накладным", del_fin-ob.doc-code) view-as alert-box .
                    end.
                if del_fin-ob.status_ <> {&fact} or (del_fin-ob.status_ = {&fact} and del_fin-ob.con-stat = 0) and v-del-fo then do :
                  assign
                    del_fin-ob.is-doc-del = yes.
                    del_fin-ob-trn.is-doc-del = yes.
                  delete del_fin-ob.
                  if available del_fin-ob-trn then delete del_fin-ob-trn.
                end.
                else if del_fin-ob.status_ = {&fact} and del_fin-ob.con-stat <> 0 then do :
                    message substitute ("ФО №&1 по данной накладной не будет удалено, т.к. есть платежи", del_fin-ob.doc-code) view-as alert-box .
                end.

                /*if v-mod-fo then do :
                  assign
                    del_fin-ob.sum-rubl-orig = del_fin-ob.sum-rubl-orig - del_trn-doc.fact-rubl
                    del_fin-ob.sum-rubl      = del_fin-ob.sum-rubl      - del_trn-doc.fact-rubl
                    del_fin-ob.sum-contract  = del_fin-ob.sum-contract  - del_trn-doc.fact-rubl
                    del_fin-ob.sum-doc-orig  = del_fin-ob.sum-doc-orig  - del_trn-doc.fact-rubl
                    del_fin-ob.sum-doc       = del_fin-ob.sum-doc       - del_trn-doc.fact-rubl

                    del_fin-ob.sum-base-orig = del_fin-ob.sum-base-orig - del_trn-doc.fact-base
                    del_fin-ob.sum-base      = del_fin-ob.sum-base      - del_trn-doc.fact-base

                    del_fin-ob.sum-tax-contract  = del_fin-ob.sum-tax-contract  - del_trn-doc.vat-rubl
                    del_fin-ob.sum-tax-doc       = del_fin-ob.sum-tax-doc       - del_trn-doc.vat-rubl
                    del_fin-ob.sum-tax-rubl      = del_fin-ob.sum-tax-rubl      - del_trn-doc.vat-rubl

                    del_fin-ob.sum-tax-base      = del_fin-ob.sum-tax-base      - del_trn-doc.vat-base
                    .

                end.*/
        end.
      end.

      if del_trn-doc.ext-doc-type = {&TDEDt_Corr_Acc_Price} then do:
        assign
          vardel-line = 0.
        for each del_doc-line where
                 del_doc-line.doc-code = del_trn-doc.doc-code
        on error undo, return error return-value :
          run waitfram-join in parhandle (
             input substitute( "Снятие атрибута 'товар в инвентаризации' со строк документа &1.", pardoc-code ),
             input substitute( " Товар &1 &2 &3.", del_doc-line.artic, del_doc-line.prod-type, del_doc-line.prod-code ),
             input substitute( " Всего удалено строк: ", vardel-line ) +
                   substitute( " Время: &1.", string( time - vartime, "hh:mm:ss":U ) ),
            output varmessage            ) no-error.
          run waitfram-show in parhandle ( input varmessage ) no-error.
          assign
            vardel-line = vardel-line + 1.

          { gbl/gdsobjat.i
            del_doc-line.obj-type
            del_doc-line.obj-code
            del_doc-line.artic
            del_doc-line.prod-type
            del_doc-line.prod-code
            "'inv-on=false'"
            l-inv-on
            no-error
          }
          if error-status :error then do:
            run waitfram-hide in parhandle no-error.
            undo, return error substitute(
              "Ошибка установки атрибута товара на объекте. Документ &1 Объект &2 &3 Товар &4 &5 &6 l-inv-on &7."
              , del_doc-line.doc-code
              , del_doc-line.obj-type
              , del_doc-line.obj-code
              , del_doc-line.artic
              , del_doc-line.prod-type
              , del_doc-line.prod-code
              , l-inv-on                 ).
          end.
        end.
      end.

   /* очистить в поставке ссылку на накладную */
   for each ub.ord-chain exclusive-lock where
            ub.ord-chain.rel-doc-code = del_trn-doc.doc-code and
            ub.ord-chain.rel-doc-type = 'trn'
            :

      if ub.ord-chain.doc-type = 'rcv'  then do:
          find first bf_ord-doc-rcv exclusive-lock where
                     bf_ord-doc-rcv.rcv-code =  ub.ord-chain.doc-code
          no-error .
          if available bf_ord-doc-rcv then do:
             bf_ord-doc-rcv.status_ = {&ord-rcv}.
          end.
      end.
      delete ub.ord-chain.
   end.


     find first bf_ord-doc exclusive-lock where bf_ord-doc.doc-code = bf_ord-doc-rcv.doc-code and
                                                bf_ord-doc.doc-type = {&o-r} no-error .
     if available bf_ord-doc then do:
       assign
        bf_ord-doc.status_ =  {&ord-req}
        bf_ord-doc.flag_   =  true
        bf_ord-doc.fact-date  =  ?
       .
     end.
      if del_trn-doc.ext-doc-type = {&TDEDT_Inv} then do:
        run str/del-invc.p ( input del_trn-doc.doc-code
                        ,input del_trn-doc.obj-type
                        ,input del_trn-doc.obj-code ).
      end.
      /* пересчесчет последующих  инвентаризаций */
      if del_trn-doc.status_ = {&fact} then do:
        run str/vtrecalc.p ( input parparentproc
                           , input recid (del_trn-doc)
                           ) no-error .
        if error-status :error then do:
           run waitfram-hide in parhandle no-error.
           undo, return error return-value .
        end.
      end.
      /* Пересчет оборотов покупателя */
      if del_trn-doc.status_ = {&fact} then do:
        v-flag-del = false .
        for each   del_turnover-buyer exclusive-lock where
                   del_turnover-buyer.doc-code = del_trn-doc.doc-code :
            delete del_turnover-buyer .
            v-flag-del = true  .
        end.
        if v-flag-del = true then
            run ref/calctur1.p ( input del_trn-doc.cli-type,
                                input del_trn-doc.cli-code,
                                input del_trn-doc.obj-type,
                                input del_trn-doc.obj-code,
                                input del_trn-doc.fact-order - {&arh-delta}
                                ).

      end.


      run waitfram-hide in parhandle no-error.

      delete del_trn-doc.
    end.
  end.
end procedure. /* lib-trn_del-doc */

/* Проверка добавления линии документа задним числом */
procedure lib-trn_chkaddln :

define input  parameter pardb-num       as integer   no-undo .
define input  parameter paruserid       as character no-undo .
define input parameter parobj-type      like ub.trn-doc.obj-type     no-undo.
define input parameter parobj-code      like ub.trn-doc.obj-code     no-undo.
define input parameter parartic         like ub.doc-line.artic       no-undo.
define input parameter parprod-type     like ub.doc-line.prod-type   no-undo.
define input parameter parprod-code     like ub.doc-line.prod-code   no-undo.
define input parameter pardoc-code      like ub.trn-doc.doc-code     no-undo.
define input parameter parfact-order    like ub.trn-doc.fact-order   no-undo.
define input parameter pardoc-type      like ub.trn-doc.doc-type     no-undo.
define input parameter parext-doc-type  like ub.trn-doc.ext-doc-type no-undo.
define input parameter parshift-date    like ub.trn-doc.shift-date   no-undo.
define input parameter parshift-num     like ub.trn-doc.shift-num    no-undo.
define input parameter parfact-qnty     like ub.trn-doc.fact-qnty    no-undo.
define input parameter parfile-name-err as   character               no-undo.
define buffer cad_goods       for ub.goods.
define buffer cadinv_doc-line for ub.doc-line.
define buffer cad_shift-obj   for ub.shift-obj.
define buffer cad_rvs-doc     for ub.rvs-doc.
define buffer cad_rvs-line    for ub.rvs-line.
define buffer cad_doc-line    for ub.doc-line.
define buffer cad_price-list  for ub.price-list.
define buffer cad_bar-code    for ub.bar-code.

define variable varflag-err     as logical no-undo.
define variable l-shift-on      as logical no-undo.
define variable varis-petrolium as logical no-undo.
define variable varis-pieces    as logical no-undo.
define variable g-log           as logical no-undo.
define variable v-root-node     as integer no-undo.
define variable varis-new       as logical no-undo.
define variable v-action        as character no-undo .
define variable v-chk-act-host-code as integer   no-undo .

do
on error undo, return error return-value
:
assign g-log = no.

{ gbl/hostcode.i
  parobj-type
  parobj-code
  v-chk-act-host-code
}
define variable v-value-character as character no-undo .
define variable v-value-date      as date no-undo .
define variable v-value-decimal   as decimal no-undo .
define variable v-value-integer   as integer no-undo .
define variable v-value-logical   as logical no-undo .
define variable v-tth             as handle no-undo .
define variable v-back-date as logical   no-undo .
define variable v-back-date-type as character no-undo .

      delete object v-tth no-error.
      run adm/shattri.p (
           input "get":U
          ,input parobj-type
          ,input parobj-code
          ,input {&attr-nakl_par}
          ,input  "back-date"
          ,output v-value-character
          ,output v-value-date
          ,output v-value-decimal
          ,output v-value-integer
          ,output v-back-date
          ,output v-back-date-type
          ,INPUT-OUTPUT table-handle v-tth
          ) no-error .
          if error-status :error  then v-back-date = false .
          delete object v-tth no-error.
    if v-back-date <> true then do:
        output stream str-err to value(parfile-name-err) append.
        put stream str-err unformatted substitute (" Запрещено добавление документов прошедшей датой." ).
        output stream str-err close.
        return error "CRITICAL".
    end.

case pardoc-type
:
  when {&income} then do:
    assign
      v-action = 'actn_income_add-back-date':u
    .
  end.
  when {&expense} then do:
    assign
      v-action = 'actn_expense_add-back-date':u
    .
  end.
  when {&write-off} then do:
    assign
      v-action = 'actn_write-off_add-back-date':u
    .
  end.
  when {&return} then do:
    assign
      v-action = 'actn_return_add-back-date':u
    .
  end.
  when {&inventory} then do:
    assign
      v-action = 'actn_inventory_add-back-date':u
    .
  end.
  otherwise do:
    message
      vss-workfile vss-revision vss-description skip
      "Неизвестный тип документа" skip
      "Тип документа" pardoc-type skip
      "Код документа" pardoc-code skip
      view-as alert-box error .
    undo, return error return-value .
  end.
end case.

{ gbl/chk-actg.i
  pardb-num
  paruserid
  {&action-head-code-main}
  v-action
  {&cntxt-object}
  v-chk-act-host-code
  parobj-type
  parobj-code
  0
  0
  0
  true
  g-log
}

if not g-log then do:
  output stream str-err to value(parfile-name-err) append.
  put stream str-err unformatted substitute (" Вы не имеете прав на добавление документов прошедшей датой." ).
  output stream str-err close.
  return error "CRITICAL".
end.

find first cad_goods no-lock
  where cad_goods.artic     = parartic
    and cad_goods.prod-type = parprod-type
    and cad_goods.prod-code = parprod-code
  .
{ str/is-petrl.i
  parartic
  parprod-type
  parprod-code
  varis-petrolium
  varis-pieces
  no-error
}
if error-status :error then do:
  output stream str-err to value(parfile-name-err) append.
  put stream str-err unformatted return-value.
  output stream str-err close.
  return error "CRITICAL".
end.
if varis-petrolium = yes
  and varis-pieces    = no
then do:
  { gbl/objat.i
    parobj-type
    parobj-code
    "'shift-on=request'"
    l-shift-on
  }
  if l-shift-on then do:
    find first cad_shift-obj
      where cad_shift-obj.obj-type = parobj-type
        and cad_shift-obj.obj-code = parobj-code
        and cad_shift-obj.status_  = {&sht-current}
      no-error.
    if not available cad_shift-obj
      or cad_shift-obj.shift-date <> parshift-date
      or cad_shift-obj.shift-num  <> parshift-num
    then do:
      case pardoc-type
      :
        when {&income} then do:
          assign
            v-action = 'actn_income_add-ptrl-prev-shft':u
          .
        end.
        when {&expense} then do:
          assign
            v-action = 'actn_expense_add-ptrl-prev-shft':u
          .
        end.
        when {&write-off} then do:
          assign
            v-action = 'actn_write-off_add-ptrl-prev-shft':u
          .
        end.
        when {&return} then do:
          assign
            v-action = 'actn_return_add-ptrl-prev-shft':u
          .
        end.
        when {&inventory} then do:
          assign
            v-action = 'actn_inventory_add-ptrl-prev-shft':u
          .
        end.
        otherwise do:
          message
            vss-workfile vss-revision vss-description skip
            "Неизвестный тип документа" skip
            "Тип документа" pardoc-type skip
            "Код документа" pardoc-code skip
            view-as alert-box error .
          undo, return error return-value .
        end.
      end case.
      { gbl/chk-actg.i
        pardb-num
        paruserid
        {&action-head-code-main}
        v-action
        {&cntxt-object}
        v-chk-act-host-code
        parobj-type
        parobj-code
        0
        0
        0
        true
        g-log
      }

      if not g-log then do:
        output stream str-err to value(parfile-name-err) append.
        put stream str-err unformatted substitute ("Товар &1 &2 &3 &4 - топливо. Вы не имеете прав на создание документов по топливу в предыдущих сменах. Документы можно добавлять только в текущей смене."
                                , parartic
                                , parprod-type
                                , parprod-code
                                , cad_goods.gds-name).
        output stream str-err close.
        return error "CRITICAL".
      end.
    end.
  end.
  /*Не должно быть открытых сверок по топливу*/
  &scop open-rvs-doc ~
  for each cad_rvs-doc where cad_rvs-doc.obj-type = parobj-type and                 ~
                             cad_rvs-doc.obj-code = parobj-code and                 ~
                             cad_rvs-doc.status_  ~{&znak} {&fact} and              ~
                             cad_rvs-doc.rvs-type ne ~{&test-asi} and               ~
                             cad_rvs-doc.out-code <> pardoc-code no-lock ,          ~
      first cad_rvs-line where cad_rvs-line.gds-code = cad_goods.gds-code   and     ~
                               cad_rvs-line.rvs-code = cad_rvs-doc.rvs-code and     ~
                               cad_rvs-line.obj-type = parobj-type          and     ~
                               cad_rvs-line.obj-code = parobj-code          no-lock ~
  on error undo, return error return-value                                      ~
  :                                                                             ~
    output stream str-err to value(parfile-name-err) append.                    ~
    put stream str-err unformatted substitute ("По товару &1 &2 &3 &4 есть незакрытая сверка &5", ~
                                                      parartic,                ~
                                                      parprod-type,            ~
                                                      parprod-code,            ~
                                                      cad_goods.gds-name,      ~
                                                      cad_rvs-line.rvs-code) skip. ~
    output stream str-err close.                                              ~
    assign varflag-err = yes.   ~
  end.
  &scop znak >
  {&open-rvs-doc}
  &scop znak <
  {&open-rvs-doc}
end.
/*Не должно быть открытых инвентаризаций*/
&scop  open-trn-doc ~
for each cad_doc-line where cad_doc-line.obj-type  = parobj-type   and         ~
                            cad_doc-line.obj-code  = parobj-code   and         ~
                            cad_doc-line.prod-type = parprod-type  and         ~
                            cad_doc-line.prod-code = parprod-code  and         ~
                            cad_doc-line.artic     = parartic      and         ~
                            cad_doc-line.ext-doc-type = {&TDEDT_Inv} and       ~
                            cad_doc-line.status_   ~{&znak} {&fact} and       ~
                            cad_doc-line.doc-code  <> pardoc-code  no-lock    ~
on error undo, return error return-value                                      ~
:                                                                             ~
     output stream str-err to value(parfile-name-err) append.                 ~
     put stream str-err unformatted  substitute ("По товару &1 &2 &3 &4 есть открытый документ &5.", ~
                                                 parartic,                    ~
                                                 parprod-type,                ~
                                                 parprod-code,                ~
                                                 cad_goods.gds-name,          ~
                                                 cad_doc-line.doc-code) skip. ~
    output stream str-err close.                                              ~
    assign varflag-err = yes.   ~
end.
&scop znak >
{&open-trn-doc}
&scop znak <
{&open-trn-doc}

/*Не должно быть открытых пересортиц*/
&scop  open-trn-doc ~
for each cad_doc-line where cad_doc-line.obj-type  = parobj-type   and         ~
                            cad_doc-line.obj-code  = parobj-code   and         ~
                            cad_doc-line.prod-type = parprod-type  and         ~
                            cad_doc-line.prod-code = parprod-code  and         ~
                            cad_doc-line.artic     = parartic      and         ~
                            cad_doc-line.ext-doc-type = {&TDEDT_Peresort} and       ~
                            cad_doc-line.status_   ~{&znak} {&fact} and        ~
                            cad_doc-line.doc-code  <> pardoc-code  no-lock    ~
on error undo, return error return-value                                      ~
:                                                                             ~
     output stream str-err to value(parfile-name-err) append.                 ~
     put stream str-err unformatted  substitute ("По товару &1 &2 &3 &4 есть открытый документ &5.", ~
                                                 parartic,                    ~
                                                 parprod-type,                ~
                                                 parprod-code,                ~
                                                 cad_goods.gds-name,          ~
                                                 cad_doc-line.doc-code) skip. ~
    output stream str-err close.                                              ~
    assign varflag-err = yes.   ~
end.
&scop znak >
{&open-trn-doc}
&scop znak <
{&open-trn-doc}

if varflag-err = yes then do:
  return error.
end.
end.
end procedure.

/* Запись удаляемого документа в историю */
procedure lib-trn_hstc-trn :
  define input parameter parrec-trn-doc     as   recid                        no-undo.
  define input parameter parobj-date        as   date                         no-undo.
  define input parameter parshift-date      like ub.shift-obj.shift-date      no-undo.
  define input parameter parshift-num       like ub.shift-obj.shift-num       no-undo.
  define input parameter parshift-name      like ub.shift-obj.shift-name      no-undo.
  define input parameter parcorr-incas-code like ub.c-trn-doc.corr-inkas-code no-undo.
  define input parameter parcorr-fbr-code   like ub.c-trn-doc.corr-fbr-code   no-undo.
  define input parameter paruserid          as   character                    no-undo.
  define input parameter parcurdb-num       as   integer                      no-undo.
  define input parameter parchip-num        as   integer                      no-undo.

  define buffer hstc_trn-doc         for ub.trn-doc.
  define buffer hstc_trn-doc-sum     for ub.trn-doc-sum.
  define buffer hstc_doc-line        for ub.doc-line.
  define buffer hstc_doc-line-attr   for ub.doc-line-attr.
  define buffer hstc_doc-line-sum    for ub.doc-line-sum.
  define buffer hstc_gds-dtl         for ub.gds-dtl.
  define buffer hstc_parts           for ub.parts.
  define buffer hstc_parts-root      for ub.parts-root.
  define buffer hstc_parts-attr      for ub.parts-attr.
  define buffer hstc_doc-prts        for ub.doc-prts.
  define buffer hstc_doc-pl          for ub.doc-pl.
  define buffer hstc_doc-pl-pump     for ub.doc-pl-pump.
  define buffer hstc_doc-attr        for ub.doc-attr.
  define buffer hstc_doc-fbr-gds     for ub.doc-fbr-gds.
  define buffer hstc_c-trn-doc       for ub.c-trn-doc.
  define buffer hstc_c-trn-doc-sum   for ub.c-trn-doc-sum.
  define buffer hstc_c-doc-line      for ub.c-doc-line.
  define buffer hstc_c-doc-line-attr for ub.c-doc-line-attr.
  define buffer hstc_c-doc-line-sum  for ub.c-doc-line-sum.
  define buffer hstc_c-gds-dtl       for ub.c-gds-dtl.
  define buffer hstc_c-parts         for ub.c-parts.
  define buffer hstc_c-parts-root    for ub.c-parts-root.
  define buffer hstc_c-parts-attr    for ub.c-parts-attr.
  define buffer hstc_c-doc-prts      for ub.c-doc-prts.
  define buffer hstc_c-doc-pl        for ub.c-doc-pl.
  define buffer hstc_c-doc-pl-pump   for ub.c-doc-pl-pump.
  define buffer hstc_c-doc-attr      for ub.c-doc-attr.
  define buffer hstc_c-doc-fbr-gds   for ub.c-doc-fbr-gds.

  do on error undo, return error return-value :
    find first hstc_trn-doc where recid( hstc_trn-doc ) = parrec-trn-doc.
    create hstc_c-trn-doc.
    buffer-copy hstc_trn-doc to hstc_c-trn-doc.
    assign
      hstc_c-trn-doc.chip-num        = parchip-num
      hstc_c-trn-doc.corr-user-name  = paruserid
      hstc_c-trn-doc.corr-user-db-num = parcurdb-num
      hstc_c-trn-doc.corr-inkas-code = parcorr-incas-code
      hstc_c-trn-doc.corr-fbr-code   = parcorr-fbr-code
      hstc_c-trn-doc.corr-date       = parobj-date
      hstc_c-trn-doc.corr-shift-date = parshift-date
      hstc_c-trn-doc.corr-shift-num  = parshift-num
      hstc_c-trn-doc.corr-shift-name = parshift-name
      hstc_c-trn-doc.bge-date        = ?
      hstc_c-trn-doc.scf-date        = ?
    .
    for each hstc_trn-doc-sum where hstc_trn-doc-sum.doc-code = hstc_trn-doc.doc-code on error undo, return error return-value :
      create hstc_c-trn-doc-sum.
      buffer-copy hstc_trn-doc-sum to hstc_c-trn-doc-sum.
      assign hstc_c-trn-doc-sum.chip-num         = hstc_c-trn-doc.chip-num
             hstc_c-trn-doc-sum.corr-user-db-num = hstc_c-trn-doc.user-db-num
      .
    end.
    for each hstc_doc-attr where hstc_doc-attr.doc-code = hstc_trn-doc.doc-code on error undo, return error return-value :
      create hstc_c-doc-attr.
      buffer-copy hstc_doc-attr to hstc_c-doc-attr.
      assign hstc_c-doc-attr.chip-num = hstc_c-trn-doc.chip-num.
    end.
    for each hstc_doc-line where hstc_doc-line.doc-code = hstc_trn-doc.doc-code on error undo, return error return-value :
        create hstc_c-doc-line.
        buffer-copy hstc_doc-line to hstc_c-doc-line.
        assign hstc_c-doc-line.chip-num = hstc_c-trn-doc.chip-num.
    end.
    for each hstc_doc-line-attr where hstc_doc-line-attr.doc-code = hstc_trn-doc.doc-code on error undo, return error return-value :
      create hstc_c-doc-line-attr.
      buffer-copy hstc_doc-line-attr to hstc_c-doc-line-attr.
      assign hstc_c-doc-line-attr.chip-num = hstc_c-trn-doc.chip-num.
    end.
    for each hstc_doc-line-sum where hstc_doc-line-sum.doc-code = hstc_trn-doc.doc-code on error undo, return error return-value :
      create hstc_c-doc-line-sum.
      buffer-copy hstc_doc-line-sum to hstc_c-doc-line-sum.
      assign hstc_c-doc-line-sum.chip-num         = hstc_c-trn-doc.chip-num
             hstc_c-doc-line-sum.corr-user-db-num = hstc_c-trn-doc.user-db-num
      .
    end.
    for each hstc_gds-dtl where hstc_gds-dtl.doc-code = hstc_trn-doc.doc-code on error undo, return error return-value :
        create hstc_c-gds-dtl.
        buffer-copy hstc_gds-dtl to hstc_c-gds-dtl.
        assign hstc_c-gds-dtl.chip-num = hstc_c-trn-doc.chip-num.
    end.
    for each hstc_parts where hstc_parts.out-code = hstc_trn-doc.doc-code on error undo, return error return-value :
        create hstc_c-parts.
        buffer-copy hstc_parts to hstc_c-parts.
        assign hstc_c-parts.chip-num = hstc_c-trn-doc.chip-num.
    end.
    for each hstc_parts-root where hstc_parts-root.doc-code = hstc_trn-doc.doc-code on error undo, return error return-value :
      create hstc_c-parts-root.
      buffer-copy hstc_parts-root to hstc_c-parts-root.
      assign hstc_c-parts-root.chip-num = hstc_c-trn-doc.chip-num.
    end.
    for each hstc_parts-attr where hstc_parts-attr.in-code = hstc_trn-doc.doc-code on error undo, return error return-value :
      create hstc_c-parts-attr.
      buffer-copy hstc_parts-attr to hstc_c-parts-attr.
      assign hstc_c-parts-attr.chip-num = hstc_c-trn-doc.chip-num.
    end.
    for each hstc_doc-prts where hstc_doc-prts.out-code = hstc_trn-doc.doc-code on error undo, return error return-value :
      create hstc_c-doc-prts.
      buffer-copy hstc_doc-prts to hstc_c-doc-prts.
      assign hstc_c-doc-prts.chip-num = hstc_c-trn-doc.chip-num.
    end.
    for each hstc_doc-pl where hstc_doc-pl.out-code = hstc_trn-doc.doc-code on error undo, return error return-value :
      create hstc_c-doc-pl.
      buffer-copy hstc_doc-pl to hstc_c-doc-pl.
      assign hstc_c-doc-pl.chip-num = hstc_c-trn-doc.chip-num.
    end.
    for each hstc_doc-pl-pump where hstc_doc-pl-pump.out-code = hstc_trn-doc.doc-code on error undo, return error return-value :
      create hstc_c-doc-pl-pump.
      buffer-copy hstc_doc-pl-pump to hstc_c-doc-pl-pump.
      assign hstc_c-doc-pl-pump.chip-num = hstc_c-trn-doc.chip-num.
    end.
    for each hstc_doc-fbr-gds where hstc_doc-fbr-gds.out-code = hstc_trn-doc.doc-code on error undo, return error return-value :
      create hstc_c-doc-fbr-gds.
      buffer-copy hstc_doc-fbr-gds to hstc_c-doc-fbr-gds.
      assign hstc_c-doc-fbr-gds.chip-num = hstc_c-trn-doc.chip-num.
    end.

  /*  Простановка данных по генерации ФО на удаленных документах */
  if hstc_c-trn-doc.need-buyer = 1   and
     hstc_c-trn-doc.cr-fo-buyer   = yes then do:
    assign
      hstc_c-trn-doc.cr-fo-buyer      = no
      hstc_c-trn-doc.buyer-fo-date    = 01/01/1990.
  end.
  else do:
    assign
      hstc_c-trn-doc.need-buyer = 0
      hstc_c-trn-doc.cr-fo-buyer   = no
      hstc_c-trn-doc.buyer-fo-date = 01/01/1990.
  end.
  if hstc_c-trn-doc.need-incfo = 1   and
     hstc_c-trn-doc.cr-incfo   = yes then do:
    assign
      hstc_c-trn-doc.cr-incfo      = no
      hstc_c-trn-doc.incfo-date    = 01/01/1990.
  end.
  else do:
    assign
      hstc_c-trn-doc.need-incfo = 0
      hstc_c-trn-doc.cr-incfo   = no
      hstc_c-trn-doc.incfo-date = 01/01/1990.
  end.
  if hstc_c-trn-doc.need-expfo = 1   and
     hstc_c-trn-doc.cr-expfo   = yes then do:
    assign
      hstc_c-trn-doc.cr-expfo      = no
      hstc_c-trn-doc.expfo-date    = 01/01/1990.
  end.
  else do:
    assign
      hstc_c-trn-doc.need-expfo = 0
      hstc_c-trn-doc.cr-expfo   = no
      hstc_c-trn-doc.incfo-date = 01/01/1990.
  end.
  if hstc_c-trn-doc.need-incfo = 1 or
     hstc_c-trn-doc.need-expfo = 1 then do:
    assign
      hstc_c-trn-doc.need-incorexpfo = 1.
  end.
  if hstc_c-trn-doc.cr-incfo = yes or
     hstc_c-trn-doc.cr-expfo = yes then do:
    assign
      hstc_c-trn-doc.cr-incorexpfo = yes.
  end.

  end.
end procedure. /* lib-trn_hstc-trn */

/* Удаление истории по складскому документу (при удалении документа) */
procedure lib-trn_hstd-trn :
  define input parameter p-doc-code like ub.trn-doc.doc-code   no-undo.
  define input parameter p-chip-num like ub.c-trn-doc.chip-num no-undo.

  define buffer bf_goods       for ub.goods.
  define buffer bf_pl-gds-pump for ub.pl-gds-pump.
  define buffer bf_place       for ub.place.
  define buffer bf_rvs-doc     for ub.rvs-doc.

  do on error   undo, return error return-value
     on end-key undo, return error return-value
     on stop    undo, return error return-value :
    for each ub.c-trn-doc where
             ub.c-trn-doc.doc-code  = p-doc-code and
             ub.c-trn-doc.chip-num <> p-chip-num :
      delete ub.c-trn-doc.
    end. /* for each ub.c-trn-doc */
    for each ub.c-trn-doc-sum where
             ub.c-trn-doc-sum.doc-code  = p-doc-code and
             ub.c-trn-doc-sum.chip-num <> p-chip-num :
      delete ub.c-trn-doc-sum.
    end.
    for each ub.c-doc-attr where
             ub.c-doc-attr.doc-code  = p-doc-code and
             ub.c-doc-attr.chip-num <> p-chip-num :
      delete ub.c-doc-attr.
    end.
    for each bf_rvs-doc no-lock where bf_rvs-doc.out-code = p-doc-code :
      for each ub.c-rvs-doc where
               ub.c-rvs-doc.rvs-code =  bf_rvs-doc.rvs-code and
               ub.c-rvs-doc.chip-num <> p-chip-num          :
        delete ub.c-rvs-doc.
      end.
    end.
    for each ub.c-doc-line where
             ub.c-doc-line.doc-code =  p-doc-code and
             ub.c-doc-line.chip-num <> p-chip-num :
      find first bf_goods no-lock where
                 bf_goods.artic     = ub.c-doc-line.artic     and
                 bf_goods.prod-type = ub.c-doc-line.prod-type and
                 bf_goods.prod-code = ub.c-doc-line.prod-code .
      for each ub.c-parts where
               ub.c-parts.out-code  =  ub.c-doc-line.doc-code  and
               ub.c-parts.obj-type  =  ub.c-doc-line.obj-type  and
               ub.c-parts.obj-code  =  ub.c-doc-line.obj-code  and
               ub.c-parts.artic     =  ub.c-doc-line.artic     and
               ub.c-parts.prod-type =  ub.c-doc-line.prod-type and
               ub.c-parts.prod-code =  ub.c-doc-line.prod-code and
               ub.c-parts.chip-num  <> p-chip-num              :
        for each ub.c-parts-root where
                 ub.c-parts-root.doc-code       =  ub.c-parts.out-code  and
                 ub.c-parts-root.orig-in-code   =  ub.c-parts.in-code   and
                 ub.c-parts-root.orig-gds-code  =  ub.c-goods.gds-code  and
                 ub.c-parts-root.orig-part-code =  ub.c-parts.part-code and
                 ub.c-parts-root.chip-num       <> p-chip-num           :
          delete ub.c-parts-root.
        end.
        delete ub.c-parts.
      end.

      for each ub.c-parts-attr where
               ub.c-parts-attr.in-code  =  ub.c-doc-line.doc-code and
               ub.c-parts-attr.gds-code =  ub.c-goods.gds-code    and
               ub.c-parts-attr.chip-num <> p-chip-num             :
        delete ub.c-parts-attr.
      end.

      for each ub.c-gds-dtl where
               ub.c-gds-dtl.doc-code  =  ub.c-doc-line.doc-code  and
               ub.c-gds-dtl.artic     =  ub.c-doc-line.artic     and
               ub.c-gds-dtl.prod-type =  ub.c-doc-line.prod-type and
               ub.c-gds-dtl.prod-code =  ub.c-doc-line.prod-code and
               ub.c-gds-dtl.chip-num  <> p-chip-num              :
        delete ub.c-gds-dtl.
      end.

      for each ub.c-doc-prts where
               ub.c-doc-prts.out-code =  ub.c-doc-line.doc-code and
               ub.c-doc-prts.gds-code =  ub.c-goods.gds-code    and
               ub.c-doc-prts.chip-num <> p-chip-num             :
        delete ub.c-doc-prts.
      end.

      for each ub.c-doc-pl where
               ub.c-doc-pl.out-code =  ub.c-doc-line.doc-code and
               ub.c-doc-pl.gds-code =  ub.c-goods.gds-code    and
               ub.c-doc-pl.chip-num <> p-chip-num             :
        delete ub.c-doc-pl.
      end.

      find first ub.c-doc-pl-pump where ub.c-doc-pl-pump.gds-code = bf_goods.gds-code no-error.
      if available ub.c-doc-pl-pump then do:
        for each bf_place       no-lock where
                 bf_place.obj-type       = ub.c-doc-line.obj-type and
                 bf_place.obj-code       = ub.c-doc-line.obj-code
          , each bf_pl-gds-pump no-lock where
                 bf_pl-gds-pump.obj-type = bf_place.obj-type      and
                 bf_pl-gds-pump.obj-code = bf_place.obj-code      and
                 bf_pl-gds-pump.pl-code  = bf_place.pl-code       and
                 bf_pl-gds-pump.gds-code = bf_goods.gds-code      :
          for each ub.c-doc-pl-pump where
                   ub.c-doc-pl-pump.obj-type  =  bf_pl-gds-pump.obj-type  and
                   ub.c-doc-pl-pump.obj-code  =  bf_pl-gds-pump.obj-code  and
                   ub.c-doc-pl-pump.pl-code   =  bf_pl-gds-pump.pl-code   and
                   ub.c-doc-pl-pump.pump-code =  bf_pl-gds-pump.pump-code and
                   ub.c-doc-pl-pump.out-code  =  ub.c-doc-line.doc-code   and
                   ub.c-doc-pl-pump.gds-code  =  bf_goods.gds-code        and
                   ub.c-doc-pl-pump.chip-num  <> p-chip-num               :
            delete ub.c-doc-pl-pump.
          end. /* for each ub.c-doc-pl-pump */
        end. /* for each bf_place */
      end. /* if available ub.c-doc-pl-pump */

      for each ub.c-doc-line-attr where
               ub.c-doc-line-attr.doc-code =  ub.c-doc-line.doc-code and
               ub.c-doc-line-attr.gds-code =  bf_goods.gds-code      and
               ub.c-doc-line-attr.chip-num <> p-chip-num             :
        delete ub.c-doc-line-attr.
      end.

      for each ub.c-doc-line-sum where
               ub.c-doc-line-sum.doc-code =  ub.c-doc-line.doc-code and
               ub.c-doc-line-sum.gds-code =  bf_goods.gds-code      and
               ub.c-doc-line-sum.chip-num <> p-chip-num             :
        delete ub.c-doc-line-sum.
      end.

      for each ub.c-doc-fbr-gds where
               ub.c-doc-fbr-gds.out-code =  ub.c-doc-line.doc-code and
               ub.c-doc-fbr-gds.gds-code =  bf_goods.gds-code      and
               ub.c-doc-fbr-gds.chip-num <> p-chip-num             :
        delete ub.c-doc-fbr-gds.
      end. /* for each ub.c-doc-fbr-gds */

      delete ub.c-doc-line.
    end. /* for each ub.c-doc-line */
  end. /* on eror */
end procedure. /* lib-trn_hstd-trn */

/* Создание строки а-ля расход */
procedure lib-trn_crdoclno :
  define input parameter pardoc-code    like ub.trn-doc.doc-code     no-undo.
  define input parameter parobj-type    like ub.trn-doc.obj-type     no-undo. /*t-doc*/
  define input parameter parobj-code    like ub.trn-doc.obj-code     no-undo.
  define input parameter parartic       like ub.goods.artic          no-undo. /*goods*/
  define input parameter parprod-type   like ub.goods.prod-type      no-undo.
  define input parameter parprod-code   like ub.goods.prod-code      no-undo.
  define input parameter pargds-name    like ub.goods.gds-name       no-undo.
  define input parameter parprt-root    like ub.goods.prt-root       no-undo.
  define input parameter parvat-pc      like ub.doc-line.vat-pc      no-undo. /*ret-line.vat-pc or ?*/
  define input parameter parcons-vat-pc like ub.doc-line.cons-vat-pc no-undo.
  define input parameter parcash-pay    like ub.sysconf.cash-pay     no-undo.

  define variable l-inv-on           as logical             no-undo .
  define variable v-clcdoc-host-code like ub.sysconf.host-code no-undo .
  define variable v-clcdoc-vat-pc    like ub.doc-line.vat-pc   no-undo .
  define variable v-clcdoc-slt-pc    like ub.doc-line.slt-pc   no-undo .
  define variable g-log              as logical             no-undo .

  define buffer crd_doc-line for ub.doc-line.
  define buffer crd_trn-doc  for ub.trn-doc.
  define buffer crd_goods    for ub.goods.
  define buffer crd_sysconf  for ub.sysconf.

  do on error undo, return error return-value :
    { gbl/gdsobjat.i
        parobj-type
        parobj-code
        parartic
        parprod-type
        parprod-code
        "'inv-on=request'"
        l-inv-on
        no-error
    }
    if error-status :error then do:
      undo, return error substitute( "Ошибка получения признака товара на объекте &1 &2.",
                                     error-status :get-message( 1 ), return-value ).
    end.
    if l-inv-on = yes then do:
      assign g-log = yes.
      message "Артикул :" parartic pargds-name "- товар в инвентаризации." skip (2)
              "Добавление невозможно." skip (2)
              "OK - пропустить товар, Cancel - отменить копирование"
      view-as alert-box question buttons OK-Cancel update g-log.
      if g-log = true then do:
        return "next".
      end.
      else do:
        undo, return error.
      end.
    end.
    find crd_doc-line where crd_doc-line.doc-code  = pardoc-code
                        and crd_doc-line.artic     = parartic
                        and crd_doc-line.prod-code = parprod-code
                        and crd_doc-line.prod-type = parprod-type no-error.
    if not available crd_doc-line then do:
      find first crd_trn-doc where crd_trn-doc.doc-code = pardoc-code.
      find first crd_goods where crd_goods.artic     = parartic     and
                                 crd_goods.prod-type = parprod-type and
                                 crd_goods.prod-code = parprod-code no-lock no-error.
      if error-status :error then do:
        return error substitute( "Нет товара &1 &2 &3.", crd_doc-line.artic, crd_doc-line.prod-type, crd_doc-line.prod-code ).
      end.
      if parvat-pc = ? then do:
        { gbl/hostcode.i parobj-type parobj-code v-clcdoc-host-code }
        { gbl/pftxvalg.i crd_goods.gds-code {&vat-tax-code} ? v-clcdoc-host-code parobj-type parobj-code v-clcdoc-vat-pc no-error }
      end.
      find first crd_sysconf where crd_sysconf.host-code = crd_trn-doc.host-code.
      if crd_sysconf.cons-vat-pc = ? then do:
        return error "У Вас не установлен НДС для консигнационного товара по фирме.".
      end.
      { str/st-sltpc.i
          recid(crd_goods)
          recid(crd_trn-doc)
          parcash-pay
          v-clcdoc-slt-pc
          no-error
      }
      if error-status :error then do:
        return error return-value.
      end.
      { str/crdoclin.i
        pardoc-code
        parartic
        parprod-type
        parprod-code
        parobj-type
        parobj-code
        crd_trn-doc.status_
        crd_trn-doc.ext-doc-type
        parprt-root
        "(if parvat-pc = ? then v-clcdoc-vat-pc else parvat-pc)"
        v-clcdoc-slt-pc
        crd_sysconf.cons-vat-pc
        no-error
      }

      if error-status :error then do:
        return error return-value.
      end.
      find first crd_doc-line where crd_doc-line.doc-code  = pardoc-code  and
                                    crd_doc-line.artic     = parartic     and
                                    crd_doc-line.prod-type = parprod-type and
                                    crd_doc-line.prod-code = parprod-code exclusive-lock.
      if crd_doc-line.cli-base-rate = 0 or crd_doc-line.cli-base-rate = ? then
         crd_doc-line.cli-base-rate = 1 .
      assign
        crd_doc-line.prt-OK     = yes
        crd_doc-line.doc-qnty   = 0.
    end. /* if not available crd_doc-line */
  end. /* on error */
end procedure. /* lib-trn_crdoclno */

/* ---------------------------------------------------------------------------------------------------------------------------
  Копирование в РН, ВН из любого t-doc. Копирует по возможности количество с подрезанием.
------------------------------------------------------------------------------------------------------------------------------ */
define temp-table tt-doc-line no-undo like lib-trn_ret-line.
define temp-table tt-gds-dtl  no-undo like ub.gds-dtl.
define temp-table tt-parts    no-undo like ub.parts.

procedure lib-trn_copy-ret :
/* Документ источник */
define input parameter parparentproc  AS WIDGET-HANDLE            NO-UNDO.
define input parameter pardoc-code    like ub.trn-doc.doc-code    no-undo.
define input parameter pardoc-type    like ub.trn-doc.doc-type    no-undo.
define input parameter parstatus_     like ub.trn-doc.status_     no-undo.
define input parameter parinternal    like ub.trn-doc.internal    no-undo.
define input parameter parcli-type    like ub.trn-doc.cli-type    no-undo.
define input parameter parcli-code    like ub.trn-doc.cli-code    no-undo.
define input parameter pardiscnt-type like ub.trn-doc.discnt-type no-undo.
define input parameter partot-calc    like ub.trn-doc.tot-calc    no-undo.
define input parameter pardiscnt-pc   like ub.trn-doc.discnt-pc   no-undo.
define input parameter paragnt        like ub.trn-doc.agnt        no-undo.
define input parameter parboss        like ub.trn-doc.boss        no-undo.
define input parameter parwrkr        like ub.trn-doc.wrkr        no-undo.
define input parameter parbase-rate   like ub.trn-doc.base-rate   no-undo.
define input parameter parbase-scale  like ub.trn-doc.base-scale  no-undo.
define input parameter parexch-code   like ub.trn-doc.exch-code   no-undo.
define input parameter parvat-type    like ub.trn-doc.vat-type    no-undo.
/*Документ приемник*/
define input parameter pardstdoc-code     like ub.trn-doc.doc-code    no-undo.
define input parameter parinp-discnt-type as   logical                no-undo.
define input parameter parinp-discnt-pc   like ub.trn-doc.discnt-pc   no-undo.
define input parameter parinp-agnt        like ub.trn-doc.agnt        no-undo.
define input parameter parinp-boss        like ub.trn-doc.boss        no-undo.
define input parameter parinp-wrkr        like ub.trn-doc.wrkr        no-undo.
define input parameter parinp-base-rate   like ub.trn-doc.base-rate   no-undo.
define input parameter parinp-base-scale  like ub.trn-doc.base-scale  no-undo.
/*Глобальные параметры*/
define input parameter parcash-pay        like ub.sysconf.cash-pay    no-undo.
define input parameter parglob-base-code  like ub.sysconf.base-code   no-undo.
/*Временные таблицы*/
/*после копирования в них просталвются новые количества*/
/*если parrsrv-fact-qnty = yes*/
/*в fact-qnty - то то осталось дорезервировать*/
/*в doc-qnty то что стоит в скопированной накладной в doc-qnty*/
/*если parrsrv-fact-qnty = yes*/
/*в doc-qnty - точ то осталось дорезервировать*/
/*в fact-qnty то что стоит в скопированной накладной в fact-qnty*/
define input-output parameter table for tt-doc-line.
define input-output parameter table for tt-gds-dtl.
define input-output parameter table for tt-parts.
define input parameter paruse-parts       as   logical                no-undo.
define input parameter parall-qnty        as   logical                no-undo.
define input parameter parfix-price       as   logical                no-undo.
define input parameter parrsrv-fact-qnty  as   logical                no-undo.

define buffer crt_trn-doc    for ub.trn-doc.
define buffer crt_goods      for ub.goods.
define buffer crt_doc-line   for ub.doc-line.
define buffer crt_gds-dtl    for ub.gds-dtl.
define buffer bf-cas_trn-doc for ub.trn-doc.
define buffer crt_doc-pl     for ub.doc-pl.
define buffer crt_lib-trn_ret-doc       for ub.trn-doc.
define buffer crt_lib-trn_ret-parts     for ub.parts.

define variable fix-price        as   logical              no-undo. /* фиксация цен исходного документа */
define variable end-price        as   logical              no-undo. /* при возврате подставлять цену - скидка */
define variable real-type        like ub.goods.gds-type    no-undo.
define variable legal-node       like ub.gds-prt.node-code no-undo. /* код признака, в который копируется gds-dtl, если призн-вкл -> призн-выкл или наоборот */
define variable chg-qnty         like ub.gds-dtl.fact-qnty no-undo.
define variable mem-qnty         like ub.gds-dtl.fact-qnty no-undo.
define variable fix-qnty         like ub.gds-dtl.doc-qnty  no-undo.
define variable varchg-qnty      like ub.gds-dtl.fact-qnty no-undo.
define variable varcheck-qnty    like ub.gds-dtl.fact-qnty no-undo.
define variable g-log            as   logical              no-undo.
define variable v-is-hold        as   logical              no-undo.
define variable v-add-par        as   character            no-undo.
define variable v-reserv-pl-code as   logical              no-undo.
define variable var_is-petrol    as   logical              no-undo.
define variable var_is-pieces    as   logical              no-undo.
define variable l_place-rsrv     as   logical              no-undo.
define variable is_doc-pl_rsrv   as   logical              no-undo initial no.
define variable full-rsrv-qnty   like ub.gds-dtl.fact-qnty no-undo.
define variable v-doc-pl-rowid   as   rowid                no-undo.
define variable v-density        like ub.doc-line.fact-density no-undo.
define variable v-gds-mark       as   logical              no-undo.
define variable v-gds-attr-value as   character            no-undo.
define variable v-gds-attr-type  as   character            no-undo.
define variable vIsExemplarGoods  as   logical              no-undo. 
define variable vIsVolumArticGoods as   logical              no-undo. 

{ gbl/getcntxt.i def }

c-l:
do
on error undo c-l, return error return-value
on stop  undo c-l, return error "(copy-ret) stop"
:

{ gbl/getcntxt.i get }

find first crt_trn-doc where crt_trn-doc.doc-code = pardstdoc-code.
find first crt_lib-trn_ret-doc where crt_lib-trn_ret-doc.doc-code = pardoc-code.

if paruse-parts      =  yes and
   parrsrv-fact-qnty <> yes then do:
  return error "Неверно установлены параметры для процедуры copy-ret. Резервирование по партиям можно проводить только по фактическому количеству.".
end.
if paruse-parts = yes and
   parall-qnty  <> yes then do:
  return error "Неверно установлены параметры для процедуры copy-ret. Резервирование по партиям можно проводить только по всему количеству.".
end.
assign
  fix-price = parfix-price.
if fix-price <> yes then do:
  if crt_trn-doc.internal and
     crt_trn-doc.doc-type <> {&income}                  or
     crt_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh_VP} and
     crt_trn-doc.status_ <> {&inquiry}      then do:
    assign
     fix-price = no.
  end.
  else do:
    fix-price = no.
    message "Зафиксировать исходные цены ?" skip (2)
            "Цены в добавляемых строках будут :" skip
            "YES - равны ценам документа - источника;" skip
            "NO - подставлены текущие цены продажи."
            view-as alert-box question buttons YES-NO update fix-price.
    assign
      g-log = yes.
    if fix-price and can-do
      ({&expense}, crt_trn-doc.doc-type)
    then do:
      { gbl/chk-actg.i
        v-cntxt-db-num
        v-cntxt-userid
        {&action-head-code-main}
        'actn_expense_price':U
        {&cntxt-object}
        crt_trn-doc.host-code
        crt_trn-doc.obj-type
        crt_trn-doc.obj-code
        0
        0
        0
        false
        g-log
      }
    end.
    if fix-price
    and can-do ({&return}, crt_trn-doc.doc-type)
    then do:
      { gbl/chk-actg.i
        v-cntxt-db-num
        v-cntxt-userid
        {&action-head-code-main}
        'actn_return_price':U
        {&cntxt-object}
        crt_trn-doc.host-code
        crt_trn-doc.obj-type
        crt_trn-doc.obj-code
        0
        0
        0
        false
        g-log
      }
    end.
    if not g-log then do:
      return error "У Вас нет прав для назначения произвольных цен в документе, поэтому копирование цен из выбранного источника невозможно.".
    end.
  end.
end.
/* ссылка на исходный документ сохраняется только при создании ВН на основании РН */
assign
  end-price = no.
if pardoc-type          = {&expense}             and
   parstatus_           = {&fact}                and
   parinternal          = no                     and
   crt_trn-doc.doc-type = {&return}              and
   crt_trn-doc.internal = no                     and
   parcli-type          = crt_trn-doc.cli-type   and
   parcli-code          = crt_trn-doc.cli-code   and
   can-do ({&d-type-list}, pardiscnt-type)       then do:
   assign
     crt_trn-doc.out-code = pardoc-code.
   if fix-price then do:
     assign
       end-price = yes.
   end.
end.

if parinp-discnt-type = yes and
   parinp-discnt-pc   = 0   and
   can-do ({&d-type-list}, pardiscnt-type)
   then do:
  assign
    crt_trn-doc.tot-calc    = partot-calc
    crt_trn-doc.discnt-pc   = pardiscnt-pc
    crt_trn-doc.discnt-type = pardiscnt-type.
end.

if parinp-agnt = ? then do:
  assign
    crt_trn-doc.agnt = paragnt.
end.
if parinp-boss = ? then do:
  assign
    crt_trn-doc.boss = parboss.
end.
if parinp-wrkr = ? then do:
  assign
    crt_trn-doc.wrkr = parwrkr.
end.

if parinp-base-rate  = ? then do:
  assign
    crt_trn-doc.base-rate  = parbase-rate.
end.
if parinp-base-scale = ? then do:
  assign
    crt_trn-doc.base-scale = parbase-scale.
end.
/* проверка на услуги (считаем, что в документе источнике и приемнике до этого все было однородно)*/
find first tt-doc-line where tt-doc-line.doc-code = pardoc-code no-lock no-error.
if available tt-doc-line then do:
  find crt_goods where crt_goods.artic     = tt-doc-line.artic
                   and crt_goods.prod-type = tt-doc-line.prod-type
                   and crt_goods.prod-code = tt-doc-line.prod-code no-lock.
  if crt_goods.gds-type = {&gds-office} and
     (crt_trn-doc.doc-type <> {&expense} or crt_trn-doc.internal) then do:
    return error "В данный документ нельзя копировать услуги.".
  end.
  assign
    real-type = crt_goods.gds-type.
  find first crt_doc-line where crt_doc-line.doc-code = crt_trn-doc.doc-code no-lock no-error.
  if available crt_doc-line then do:
    find crt_goods where crt_goods.artic     = crt_doc-line.artic
                     and crt_goods.prod-type = crt_doc-line.prod-type
                     and crt_goods.prod-code = crt_doc-line.prod-code no-lock.
    if crt_goods.gds-type <> real-type then do:
      return error "Услуги и товары не могут быть добавлены в один и тот же документ.".
    end.
  end.
  else do:
    assign
      crt_trn-doc.office = (if real-type = {&gds-office} then yes else no).
  end.
end.
{ gbl/hold-doc.i
  pardstdoc-code
  v-is-hold
}
r-l:
for each tt-doc-line where tt-doc-line.doc-code = pardoc-code by tt-doc-line.line-num on error undo, return error return-value :
  find crt_goods where crt_goods.artic     = tt-doc-line.artic
                   and crt_goods.prod-type = tt-doc-line.prod-type
                   and crt_goods.prod-code = tt-doc-line.prod-code no-lock.
  
  if crt_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh_VP} then 
  do:
      run isExemplarGoods in this-procedure 
          (tt-doc-line.obj-type, tt-doc-line.obj-code, crt_goods.gds-code, output vIsExemplarGoods).
      run isVolumArticGoods in this-procedure 
          (tt-doc-line.obj-type, tt-doc-line.obj-code, crt_goods.gds-code, output vIsVolumArticGoods).
      if vIsExemplarGoods or vIsVolumArticGoods then
      do:
        message substitute("Товар &1 &2 &3 &4 подлежит обязательной маркировке. Для возврата используйте документ Расход внешний.~nТовар в документ добавлен не будет."
               , crt_goods.artic
               , crt_goods.prod-type
               , crt_goods.prod-code
               , crt_goods.gds-name
               )
        view-as alert-box .
        varcheck-qnty = varcheck-qnty + tt-doc-line.fact-qnty.
        next r-l.
      end.
  end.
  
  { str/crdoclno.i
    crt_trn-doc.doc-code
    crt_trn-doc.obj-type
    crt_trn-doc.obj-code
    crt_goods.artic
    crt_goods.prod-type
    crt_goods.prod-code
    crt_goods.gds-name
    crt_goods.prt-root
    ?
    ?
    parcash-pay
    no-error
  }
  if error-status :error then do:
    undo c-l, return error return-value.
  end.
  if return-value = "next" then do:
    next r-l.
  end.
  find first crt_doc-line where crt_doc-line.doc-code  = crt_trn-doc.doc-code and
                                crt_doc-line.artic     = crt_goods.artic      and
                                crt_doc-line.prod-type = crt_goods.prod-type  and
                                crt_doc-line.prod-code = crt_goods.prod-code .

  { str/is-petrl.i
    crt_goods.artic
    crt_goods.prod-type
    crt_goods.prod-code
    var_is-petrol
    var_is-pieces
    no-error
  }
  if error-status :error then do:
    return error substitute( 'Ошибка при определении атрибута товара "топливо".&1'
                          + 'Артикул &2 &3 &4&1&7&1&8'
                          , {&new-line}
                          , crt_goods.artic
                          , crt_goods.prod-type
                          , crt_goods.prod-code
                          , return-value
                          , error-status :get-message(1)
                          ).
  end. /* error */
  { gbl/gdsobjat.i
    crt_trn-doc.obj-type
    crt_trn-doc.obj-code
    crt_goods.artic
    crt_goods.prod-type
    crt_goods.prod-code
    "'place-rsrv=request':U"
    l_place-rsrv
    no-error
  }
  if error-status :error
  then do:
    undo c-l, return error substitute ("Ошибка при запросе атрибута place-rsrv товара на объекте. &1 &2", return-value, error-status :get-message (1)).
  end.

  if l_place-rsrv = yes then do:
      if  crt_lib-trn_ret-doc.obj-type = crt_trn-doc.obj-type
      and crt_lib-trn_ret-doc.obj-code = crt_trn-doc.obj-code
      then do:
        assign
          is_doc-pl_rsrv = yes
        .
      end.
      else do:
        assign
          is_doc-pl_rsrv = no
        .
      end.
  end.

  if not (crt_lib-trn_ret-doc.status_ = "temp" and crt_trn-doc.flag_) then do:
    if l_place-rsrv = yes
      and var_is-petrol = true
      and var_is-pieces = false
    then do:
      assign
        crt_doc-line.doc-density  = (if parrsrv-fact-qnty then tt-doc-line.fact-density else tt-doc-line.doc-density)
        crt_doc-line.fact-density = crt_doc-line.doc-density
      .
      if valid-density( crt_doc-line.doc-density, (crt_goods.unit-base = crt_goods.unit-cli) ) <> true then do:
        undo, return error substitute( "Плотность в документе источнике имеет некорректное значение &1.", v-density ) .
      end.
      assign
        crt_doc-line.unit-cli      = crt_goods.unit-cli
        crt_doc-line.cli-base-rate = 1 / crt_doc-line.doc-density
      .
    end.
  end.
  
  RUN gds-attr-value (
                          INPUT crt_goods.gds-code,
                          INPUT {&attr-mark-type},
                          OUTPUT v-gds-attr-value,
                          OUTPUT v-gds-attr-type
                          ).
  if v-gds-attr-value > ""
  and ObjSrv:Env:ParametrsOfSection:GetSectionEDO(crt_trn-doc.obj-type, crt_trn-doc.obj-code):GetIsMarkingForType(v-gds-attr-value)
  then 
    v-gds-mark = true .
  else
    v-gds-mark = false .
  _tt-gds-dtl:
  for each tt-gds-dtl where tt-gds-dtl.prod-type = tt-doc-line.prod-type and
                            tt-gds-dtl.prod-code = tt-doc-line.prod-code and
                            tt-gds-dtl.artic     = tt-doc-line.artic     and
                            tt-gds-dtl.doc-code  = tt-doc-line.doc-code
                            break by tt-gds-dtl.artic
                                  by tt-gds-dtl.prod-type
                                  by tt-gds-dtl.prod-code
                            :

    { str/lgl-node.i
      tt-gds-dtl.artic
      tt-gds-dtl.prod-type
      tt-gds-dtl.prod-code
      tt-gds-dtl.prt-code
      tt-doc-line.obj-type
      tt-doc-line.obj-code
      legal-node
      no-error }
    if error-status :error then do:
       undo c-l, return error substitute ("&1 &2", return-value, error-status :get-message (1)).
    end.

    { str/crgdsdtl.i
       crt_trn-doc.obj-code
       crt_trn-doc.obj-type
       crt_trn-doc.doc-code
       crt_goods.artic
       crt_goods.prod-code
       crt_goods.prod-type
       legal-node
       yes
       no-error }
     if error-status :error then do:
        return error substitute ("Ошибка при создании признака &1.", return-value) .
     end.
     find first crt_gds-dtl where crt_gds-dtl.doc-code  = crt_trn-doc.doc-code and
                                  crt_gds-dtl.artic     = crt_goods.artic      and
                                  crt_gds-dtl.prod-code = crt_goods.prod-code  and
                                  crt_gds-dtl.prod-type = crt_goods.prod-type  and
                                  crt_gds-dtl.prt-code  = legal-node.

        if is_doc-pl_rsrv = yes then do:
          if first-of(tt-gds-dtl.artic) then do:
            assign
              full-rsrv-qnty = 0
            .
            for each crt_lib-trn_ret-parts no-lock
              where crt_lib-trn_ret-parts.out-code  = tt-gds-dtl.doc-code
                and crt_lib-trn_ret-parts.obj-type  = tt-gds-dtl.obj-type
                and crt_lib-trn_ret-parts.obj-code  = tt-gds-dtl.obj-code
                and crt_lib-trn_ret-parts.artic     = tt-gds-dtl.artic
                and crt_lib-trn_ret-parts.prod-type = tt-gds-dtl.prod-type
                and crt_lib-trn_ret-parts.prod-code = tt-gds-dtl.prod-code
            on error undo, return error return-value
            :

              assign
                chg-qnty = (if parrsrv-fact-qnty then crt_lib-trn_ret-parts.fact-qnty else crt_lib-trn_ret-parts.qnty)
                fix-qnty = chg-qnty
              .

              find first crt_doc-pl
                where crt_doc-pl.obj-type = crt_trn-doc.obj-type
                  and crt_doc-pl.obj-code = crt_trn-doc.obj-code
                  and crt_doc-pl.pl-code  = crt_lib-trn_ret-parts.pl-code
                  and crt_doc-pl.out-code = crt_trn-doc.doc-code
                  and crt_doc-pl.gds-code = crt_goods.gds-code
                no-error .
              if not available crt_doc-pl then do:
                { str/crdocpl.i
                  crt_trn-doc.doc-code
                  crt_goods.gds-code
                  crt_lib-trn_ret-parts.pl-code
                  crt_trn-doc.obj-type
                  crt_trn-doc.obj-code
                  v-doc-pl-rowid
                  no-error
                }
                find first crt_doc-pl
                  where rowid( crt_doc-pl ) = v-doc-pl-rowid
                  .
              end.
              assign
                crt_doc-pl.doc-qnty      = crt_doc-pl.doc-qnty + chg-qnty
                crt_doc-pl.fact-qnty     = crt_doc-pl.doc-qnty
                crt_doc-pl.cli-qnty      = crt_doc-pl.doc-qnty / crt_doc-line.cli-base-rate
                crt_doc-pl.cli-doc-qnty  = crt_doc-pl.doc-qnty * crt_doc-line.doc-density  /* todo плотность надо брать из резервуара */
                crt_doc-pl.cli-fact-qnty = crt_doc-pl.cli-doc-qnty
              .

              assign
                v-add-par = ( /* При добавлении и изменении строки ГТД должно дублироваться во все дорезервируемые партии */
                                        if tt-doc-line.cst-code <> ? and tt-doc-line.cst-code <> ""
                                        then "," + {&rsrv-dtl_cst-code} + "=":u + str-encode( tt-doc-line.cst-code, "", ",=":u )
                                        else ""
                                      )
                                    + "," + {&rsrv-dtl_cli-qnty}      + "=":U + string( chg-qnty / crt_doc-line.cli-base-rate )
                                    + "," + {&rsrv-dtl_cre-part-code} + "=":U + string( crt_lib-trn_ret-parts.pl-code )
                                    + "," + {&rsrv-dtl_pl-code}       + "=":U + string( crt_lib-trn_ret-parts.pl-code )
                .

              if chg-qnty <> fix-qnty then do:
                undo, return error substitute( "Не удалось скопировать полностью товар: &1 &2 &3 в накладную."
                                               ,crt_gds-dtl.artic
                                               ,crt_gds-dtl.prod-type
                                               ,crt_gds-dtl.prod-code
                                             ).
              end.
              assign
                full-rsrv-qnty = full-rsrv-qnty + chg-qnty
              .
            end. /* for each lib-trn_ret-parts */
          end. /* if first-of(crt_lib-trn_ret-dtl.artic) */
        end.

    assign
      /* фиксируем цену, либо будет подставлена текущая цена объекта */
      crt_gds-dtl.ov           = fix-price
      crt_gds-dtl.price-base   = tt-gds-dtl.price-base
      crt_gds-dtl.price-rubl   = tt-gds-dtl.price-rubl.
    if can-do ({&d-type-list}, pardiscnt-type) then do:
      assign
        crt_gds-dtl.discnt-base  = tt-gds-dtl.discnt-base
        crt_gds-dtl.discnt-rubl  = tt-gds-dtl.discnt-rubl
        crt_gds-dtl.discnt-pc    = tt-gds-dtl.discnt-pc
        crt_gds-dtl.discnt-type  = tt-gds-dtl.discnt-type.
    end.
    /* при возврате поставщику, если цены источника (фикс), по возм-ти брать с НДС */
    if crt_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh_VP}  and
       pardoc-type = {&income}                           and
       parinternal = no                                  and
       crt_trn-doc.cli-type = parcli-type                and
       crt_trn-doc.cli-code = parcli-code                then do:
      if parexch-code = 0         and
         parvat-type = {&inc-vat} then do:
         assign
           crt_gds-dtl.price-rubl = tt-doc-line.price-rubl - tt-doc-line.transport-rubl - tt-doc-line.other-rubl
           crt_gds-dtl.price-base = crt_gds-dtl.price-rubl / crt_trn-doc.base-rate * crt_trn-doc.base-scale
           crt_gds-dtl.ov         = yes.
      end.
      if parexch-code = parglob-base-code and
         parvat-type = {&inc-vat} then do:
         assign
           crt_gds-dtl.price-base = tt-doc-line.price-base - tt-doc-line.transport-base - tt-doc-line.other-base
           crt_gds-dtl.price-rubl = crt_gds-dtl.price-base * crt_trn-doc.base-rate / crt_trn-doc.base-scale
           crt_gds-dtl.ov         = yes
         .
      end.
    end.
    if end-price then do:
      assign
        crt_gds-dtl.ov             = yes
        crt_gds-dtl.price-base     = tt-gds-dtl.price-base
        crt_gds-dtl.discnt-base    = tt-gds-dtl.discnt-base
        crt_gds-dtl.price-rubl     = tt-gds-dtl.price-rubl
        crt_gds-dtl.discnt-rubl    = tt-gds-dtl.discnt-rubl
        crt_gds-dtl.discnt-pc      = tt-gds-dtl.discnt-pc
        crt_gds-dtl.discnt-type    = (if crt_trn-doc.discnt-type = {&percent} then yes else no).
    end.
    /* подстановка цены, в т.ч. возврат поставщику или перемещение по цене магазина */
    { str/set-pr.i recid(crt_gds-dtl) no ? no-error }
    if error-status :error then do:
      undo c-l, return error return-value.
    end.
    /* защита от вопросительных цен */
    if (crt_gds-dtl.price-rubl = ? or crt_gds-dtl.price-base = ?) and
       crt_gds-dtl.ov then do:
      undo c-l, return error substitute ("При добавлении с фиксацией взятых из документа - источника цен требуется, чтобы ни одна из цен источника не была '?'. Добавляйте с текущими ценами продажи или выберите другой источник. Товар &1 &2 &3", crt_gds-dtl.artic, crt_gds-dtl.prod-type, crt_gds-dtl.prod-code).
    end.

    if paruse-parts = true
/*      or v-reserv-pl-code = true*/
    then do: /*резервирование по партиям*/
      if first-of (tt-gds-dtl.prod-code) then do:
        _tt-parts:
        for each tt-parts
          where tt-parts.out-code  = pardoc-code
            and tt-parts.artic     = tt-gds-dtl.artic
            and tt-parts.prod-type = tt-gds-dtl.prod-type
            and tt-parts.prod-code = tt-gds-dtl.prod-code
        on error undo, return error return-value
        :
          if tt-parts.fact-qnty = 0 then NEXT _tt-parts.

          assign
            chg-qnty = tt-parts.fact-qnty
            mem-qnty = chg-qnty
          .
          if v-is-hold = true then do:
            run trg/rsrv-dtl.p
              ( input parparentproc
               ,input {&rsrv-dtl_action_reserv}
                      + "," + {&rsrv-dtl_hold-date} + "=" + str-encode( string (tt-parts.hold-date), "", ",=":u)
                      + "," + {&rsrv-dtl_hold-code-parent} + "=" + str-encode(tt-parts.in-code, "", ",=":u)
                      + "," + {&rsrv-dtl_part-code-parent} + "=" + str-encode(tt-parts.part-code, "", ",=":u)
                      + "," + {&rsrv-dtl_cst-code} + "=" + str-encode(tt-parts.cst-code, "", ",=":u)
               ,buffer crt_gds-dtl
               ,input-output chg-qnty
               ,input-output crt_doc-line.price-base
               ,input-output crt_doc-line.price-rubl
               ,input -1
               ,input if v-gds-mark then ("copy-ret" + {&delim-par} + pardoc-code) else ""
              ) no-error.
            if error-status :error then do:
              undo c-l, return error return-value.
            end.
          end.
          else do:
            assign
              v-add-par = ( if tt-parts.pl-code <> 0 and tt-parts.pl-code <> ?
                            then ",":U + {&rsrv-dtl_pl-code} + "=":U + string(tt-parts.pl-code)
                            else "":U
                           )
            .

            run trg/rsrv-dtl.p
              ( input parparentproc
               ,input {&rsrv-dtl_action_reserv}
                      + "," + {&rsrv-dtl_rsrv-single-part}
                      + "," + {&rsrv-dtl_rsrv-in-code} + "=" + str-encode(tt-parts.in-code, "", ",=":u)
                      + "," + {&rsrv-dtl_rsrv-part-code} + "=" + str-encode(tt-parts.part-code, "", ",=":u)
                      + "," + {&rsrv-dtl_cst-code} + "=" + str-encode(tt-parts.cst-code, "", ",=":u)
                      + v-add-par
               ,buffer crt_gds-dtl
               ,input-output chg-qnty
               ,input-output crt_doc-line.price-base
               ,input-output crt_doc-line.price-rubl
               ,input -1
               ,input if v-gds-mark then ("copy-ret" + {&delim-par} + pardoc-code) else ""
              ) no-error.
            if error-status :error then do:
              undo c-l, return error return-value.
            end.
          end.
          if chg-qnty <> mem-qnty then do:
            undo c-l, return error substitute("Не удалось зарезервировать все количество по товару &1 &2 &3 партия &4 &5.", crt_doc-line.artic, crt_doc-line.prod-type, crt_doc-line.prod-code, tt-parts.in-code, tt-parts.part-code).
          end.
          assign
            crt_doc-line.doc-qnty  = crt_doc-line.doc-qnty + chg-qnty
            crt_doc-line.fact-qnty = crt_doc-line.doc-qnty
            crt_doc-line.cli-qnty  = crt_doc-line.doc-qnty / crt_doc-line.cli-base-rate
            crt_gds-dtl.doc-qnty   = crt_gds-dtl.doc-qnty  + chg-qnty
            crt_gds-dtl.fact-qnty  = crt_gds-dtl.doc-qnty
            varchg-qnty            = varchg-qnty           + chg-qnty
            varcheck-qnty          = varcheck-qnty         + chg-qnty
            tt-parts.fact-qnty     = 0
            tt-parts.qnty          = tt-parts.qnty         + chg-qnty
          .
        end.
        /* считаем суммарное количество, которое удалось скопировать */
        assign
          tt-gds-dtl.fact-qnty     = 0
          tt-gds-dtl.doc-qnty      = crt_gds-dtl.doc-qnty
        .
      end.
    end. /*резервирование по партиям*/
    else do: /*резервирование по признакам*/
      if parrsrv-fact-qnty = yes then do:
        if tt-gds-dtl.fact-qnty = 0 then NEXT _tt-gds-dtl.
        assign
          chg-qnty = tt-gds-dtl.fact-qnty
          mem-qnty = chg-qnty
        .
      end.
      else do:
        if tt-gds-dtl.doc-qnty = 0 then NEXT _tt-gds-dtl.
        assign
          chg-qnty = tt-gds-dtl.doc-qnty
          mem-qnty = chg-qnty
        .
      end.

      find first bf-cas_trn-doc no-lock
        where bf-cas_trn-doc.doc-code = crt_trn-doc.out-code
        no-error.
      if available bf-cas_trn-doc
        and bf-cas_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh_Kass}
      then do:
        assign
          v-add-par = ',':U + {&rsrv-dtl_negative-check} + "=2":U
        .
      end.
      else do:
        assign
          v-add-par = "":U
        .
      end.
      run trg/rsrv-dtl.p
        ( input parparentproc
         ,input {&rsrv-dtl_action_reserv} + v-add-par
         ,buffer crt_gds-dtl
         ,input-output chg-qnty
         ,input-output crt_doc-line.price-base
         ,input-output crt_doc-line.price-rubl
         ,input -1
         ,input if v-gds-mark then ("copy-ret" + {&delim-par} + pardoc-code) else ""
        ) no-error.
      if error-status :error then do:
        undo c-l, return error return-value.
      end.
      if parall-qnty
        and chg-qnty <> mem-qnty
      then do:
         undo c-l, return error substitute("Не удалось зарезервировать все количество по товару &1 &2 &3.", crt_doc-line.artic, crt_doc-line.prod-type, crt_doc-line.prod-code).
      end.
      assign
        crt_doc-line.doc-qnty  = crt_doc-line.doc-qnty + chg-qnty
        crt_gds-dtl.doc-qnty   = crt_gds-dtl.doc-qnty  + chg-qnty
        crt_gds-dtl.fact-qnty  = crt_gds-dtl.doc-qnty
        crt_doc-line.fact-qnty = crt_doc-line.doc-qnty
        crt_doc-line.cli-qnty  = crt_doc-line.doc-qnty / crt_doc-line.cli-base-rate
      .

      /* считаем суммарное количество, которое удалось скопировать */
      assign
        varchg-qnty   = varchg-qnty   + chg-qnty
        varcheck-qnty = varcheck-qnty + (if parrsrv-fact-qnty = yes then tt-gds-dtl.fact-qnty else tt-gds-dtl.doc-qnty)
        tt-gds-dtl.fact-qnty     = (if parrsrv-fact-qnty
                                    then (tt-gds-dtl.fact-qnty - chg-qnty)
                                    else crt_gds-dtl.fact-qnty)
        tt-gds-dtl.doc-qnty      = (if parrsrv-fact-qnty
                                    then crt_gds-dtl.doc-qnty
                                    else (tt-gds-dtl.doc-qnty - chg-qnty))
        tt-doc-line.fact-qnty     = (if parrsrv-fact-qnty
                                      then (tt-doc-line.fact-qnty - chg-qnty)
                                      else crt_doc-line.fact-qnty)
        tt-doc-line.doc-qnty      = (if parrsrv-fact-qnty
                                      then crt_doc-line.doc-qnty
                                      else (tt-doc-line.doc-qnty - chg-qnty))
      .
    end. /*резервирование по признакам*/
    if crt_gds-dtl.doc-qnty = 0 then do:
      delete crt_gds-dtl.
    end.
  end.
  if crt_doc-line.doc-qnty = 0 then do:
    delete crt_doc-line.
  end.
end.
if varcheck-qnty <> varchg-qnty and
   not (available bf-cas_trn-doc and bf-cas_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh_Kass}) then do:

  message
  substitute(("Внимание !!!&1&1" +
             "НЕ ВСЕ количество из документа &2 - источника УДАЛОСЬ добавить в заполняемый документ &3!&1&1" +
             "Общее количество в документе - источнике : &4&1"  +
             "Удалось добавить в документ : &5")
              , {&new-line}
              , pardoc-code
              , pardstdoc-code
              , varcheck-qnty
              , varchg-qnty)
 view-as alert-box .
end.
end.
end procedure.


/* Workfile: l i b - t r n . p   --   E n d */