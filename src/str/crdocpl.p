block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: crdocpl.p $
$Archive: str/crdocpl.p $

Пересчет и создание doc-pl по документу на основе parts

Автор: Уханов Дмитрий Юрьевич
Дата создания: 10/17/06
Author: Dmitry Ukhanov
Creation date: 10/17/06

*/

define input  parameter p-doc-code    as character no-undo .
define input  parameter p-gds-code    as integer   no-undo .
define input  parameter p-dens-source as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: crdocpl.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/crdocpl.p $":U .
define variable vss-description as character no-undo init "Пересчет и создание doc-pl по документу".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ str/lib-trn.i  }

do
on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
on stop   undo, return error substitute( "&1. stop", vss-workfile )
on endkey undo, return error substitute( "&1. endkey", vss-workfile )
:

  define buffer buf_doc-pl   for ub.doc-pl .
  define buffer buf_parts    for ub.parts .
  define buffer buf_goods    for ub.goods .
  define buffer buf_trn-doc  for ub.trn-doc .
  define buffer buf_doc-line for ub.doc-line .

  define variable v-density               as decimal no-undo .
  define variable vardoc-qnty-doc-pl      as decimal no-undo.
  define variable varfact-qnty-doc-pl     as decimal no-undo.
  define variable varcli-doc-qnty-doc-pl  as decimal no-undo.
  define variable varcli-fact-qnty-doc-pl as decimal no-undo.

  define variable is-petrol               as logical no-undo.
  define variable is-pieces               as logical no-undo.

  if p-dens-source <> "dens_parts":U
    and p-dens-source <> "dens_doc-line":U
    and ( not ( p-dens-source begins "dens_value":U )
          or ( ( p-dens-source begins "dens_value":U )
                 and num-entries( p-dens-source, ":":U ) <> 2
             )
        )
  then do:
    return error substitute( "&1. Ошибка задания входящих параметров. Неверно задан параметр p-dens-source (&2)", vss-workfile, p-dens-source ) .
  end.

  find first buf_trn-doc
    where buf_trn-doc.doc-code = p-doc-code
    .

  if p-gds-code <> ? then do:
    find first buf_goods no-lock
      where buf_goods.gds-code = p-gds-code
      .
  end.

  for each buf_doc-line
    where ( buf_doc-line.doc-code      = p-doc-code
            and p-gds-code = ?
          )
          or
          ( buf_doc-line.doc-code      = p-doc-code
            and buf_doc-line.artic     = buf_goods.artic
            and buf_doc-line.prod-type = buf_goods.prod-type
            and buf_doc-line.prod-code = buf_goods.prod-code
          )
  on error undo, return error return-value
  :

    find first buf_goods no-lock
      where buf_goods.artic     = buf_doc-line.artic
        and buf_goods.prod-type = buf_doc-line.prod-type
        and buf_goods.prod-code = buf_doc-line.prod-code
      .
    { str/is-petrl.i
      buf_goods.artic
      buf_goods.prod-type
      buf_goods.prod-code
      is-petrol
      is-pieces
    }
    if is-petrol = true
      and is-pieces <> true
    then do:
      if p-dens-source = "dens_doc-line":U then do:
        assign
          v-density = 1 / buf_doc-line.cli-base-rate
        .
      end.
      else do:
        if p-dens-source begins "dens_value":U then do:
          assign
            v-density = decimal( entry( 2, p-dens-source, ":":U ) )
          .
        end.
      end.
      for each buf_doc-pl
        where buf_doc-pl.out-code = buf_trn-doc.doc-code
          and buf_doc-pl.gds-code = buf_goods.gds-code
      on error undo, return error return-value
      :
        delete buf_doc-pl.
      end.
      for each buf_parts
        where buf_parts.out-code  = buf_trn-doc.doc-code
          and buf_parts.obj-type  = buf_trn-doc.obj-type
          and buf_parts.obj-code  = buf_trn-doc.obj-code
          and buf_parts.artic     = buf_goods.artic
          and buf_parts.prod-type = buf_goods.prod-type
          and buf_parts.prod-code = buf_goods.prod-code
        break by buf_parts.pl-code
      on error undo, return error return-value
      :
        if p-dens-source = "dens_parts":U then do:
          assign
            v-density = 1 / buf_parts.cli-base-rate
          .
        end.
        if first-of(buf_parts.pl-code) then do:
          create buf_doc-pl.
          assign
            buf_doc-pl.obj-type = buf_parts.obj-type
            buf_doc-pl.obj-code = buf_parts.obj-code
            buf_doc-pl.pl-code  = buf_parts.pl-code
            buf_doc-pl.out-code = buf_parts.out-code
            buf_doc-pl.gds-code = buf_goods.gds-code
          .

          assign
            vardoc-qnty-doc-pl      = 0.00
            varfact-qnty-doc-pl     = 0.00
            varcli-doc-qnty-doc-pl  = 0.00
            varcli-fact-qnty-doc-pl = 0.00
          .
        end.
        if v-density = ?
          or v-density >= 1
          or v-density <= 0
        then do:
          return error substitute( "&1. Плотность имеет некорректное значение &2. Параметр p-dens-source: &3", vss-workfile, v-density, p-dens-source ) .
        end.
        assign
          vardoc-qnty-doc-pl      = vardoc-qnty-doc-pl       + buf_parts.qnty
          varfact-qnty-doc-pl     = varfact-qnty-doc-pl      + buf_parts.fact-qnty
          varcli-doc-qnty-doc-pl  = varcli-doc-qnty-doc-pl   + buf_parts.qnty * v-density
          varcli-fact-qnty-doc-pl = varcli-fact-qnty-doc-pl  + buf_parts.fact-qnty * v-density
        .
        if last-of(buf_parts.pl-code) then do:
          assign
            buf_doc-pl.doc-qnty      = vardoc-qnty-doc-pl
            buf_doc-pl.fact-qnty     = varfact-qnty-doc-pl
            buf_doc-pl.cli-qnty      = varcli-doc-qnty-doc-pl
            buf_doc-pl.cli-doc-qnty  = varcli-doc-qnty-doc-pl
            buf_doc-pl.cli-fact-qnty = varcli-fact-qnty-doc-pl
          .
        end.
      end.

    end.
  end.
  return.
end.

/* $Workfile: crdocpl.p $ e n d */