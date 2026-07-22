/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Формирование данных по оборотам для товара на объекте.

Автор: Чернова Светлана Александровна
Дата создания: 10/10/06
Author: Svetlana Chernova
Creation date: 10/10/06

create: Суслов Алексей Юрьевич

Данные формируется в виде временной таблицы.

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&if "{1}" = "def" &then
  define temp-table tt-ot-line{2} no-undo like ub.ot-line
  field cli-type like ub.clients.obj-type
  field cli-code like ub.clients.obj-code
  index clidoc-type
  cli-type
  cli-code
  ext-doc-type
  index doc-type
  artic
  prod-type
  prod-code
  ext-doc-type
  index cligood
  cli-type
  cli-code
  artic
  prod-type
  prod-code
  .
&else
/*"{1}" = "calc" */
procedure ot-lnrv:
define input  parameter parobj-type         like ub.clients.obj-type    no-undo.
define input  parameter parobj-code         like ub.clients.obj-code    no-undo.
define input  parameter parcli-type         like ub.clients.obj-type    no-undo.
define input  parameter parcli-code         like ub.clients.obj-code    no-undo.
define input  parameter parartic            like ub.goods.artic         no-undo.
define input  parameter parprod-type        like ub.goods.prod-type     no-undo.
define input  parameter parprod-code        like ub.goods.prod-code     no-undo.
define input  parameter parfact-order-start like ub.ot-line.fact-order no-undo.
define input  parameter parfact-order-end   like ub.ot-line.fact-order no-undo.
define input  parameter parsum-type         like ub.ot-line.sum-type   no-undo.
define input  parameter parcat-id           like ub.ot-line.cat-id     no-undo.
define output parameter table for tt-ot-line{2}.
define variable varext-doc-type like ub.ot-line.ext-doc-type no-undo.
  FOR EACH ub.ot-line No-LOCK WHERE
            ub.ot-line.obj-type = parobj-type AND
            ub.ot-line.obj-code = parobj-code AND
            ub.ot-line.artic = parartic AND
            ub.ot-line.prod-type = parprod-type AND
            ub.ot-line.prod-code = parprod-code AND
            ub.ot-line.fact-order >= parfact-order-start AND
            ub.ot-line.fact-order <= parfact-order-end AND
            ub.ot-line.sum-type = parsum-type AND
            (parcat-id = ? OR ub.ot-line.cat-id = parcat-id),
      FIRST ub.trn-doc where
            ub.trn-doc.doc-code = ub.ot-line.doc-code AND
            ub.trn-doc.cli-type = parcli-type AND
            ub.trn-doc.cli-code = parcli-code:

    FIND FIRST tt-ot-line{2} where
                tt-ot-line{2}.obj-type       = parobj-type AND
                tt-ot-line{2}.obj-code       = parobj-code AND
                tt-ot-line{2}.artic          = parartic AND
                tt-ot-line{2}.prod-type      = parprod-type AND
                tt-ot-line{2}.prod-code      = parprod-code AND
                tt-ot-line{2}.fact-order     = 0 AND
                tt-ot-line{2}.sum-type       = parsum-type AND
                tt-ot-line{2}.cat-id         = parcat-id AND
                tt-ot-line{2}.ext-doc-type   = ub.ot-line.ext-doc-type AND
                tt-ot-line{2}.cli-type       = parcli-type AND
                tt-ot-line{2}.cli-code       = parcli-code
                No-ERROR.
    IF NOT AVAIL tt-ot-line{2}  then do:
      create tt-ot-line{2}.
      assign
      tt-ot-line{2}.obj-type       = parobj-type
      tt-ot-line{2}.obj-code       = parobj-code
      tt-ot-line{2}.artic          = parartic
      tt-ot-line{2}.prod-type      = parprod-type
      tt-ot-line{2}.prod-code      = parprod-code
      tt-ot-line{2}.cli-type       = parcli-type
      tt-ot-line{2}.cli-code       = parcli-code
      tt-ot-line{2}.sum-type       = parsum-type
      tt-ot-line{2}.cat-id         = parcat-id
      tt-ot-line{2}.ext-doc-type   = ub.ot-line.ext-doc-type
      .
    end. /*IF NOT AVAIL tt-ot-line{2}*/
    assign
    tt-ot-line{2}.fact-qnty      = tt-ot-line{2}.fact-qnty + ub.ot-line.fact-qnty
    tt-ot-line{2}.sum-base       = tt-ot-line{2}.sum-base + ub.ot-line.sum-base
    tt-ot-line{2}.sum-rubl       = tt-ot-line{2}.sum-rubl + ub.ot-line.sum-rubl
    tt-ot-line{2}.SLT-base       = tt-ot-line{2}.SLT-base + ub.ot-line.SLT-base
    tt-ot-line{2}.SLT-rubl       = tt-ot-line{2}.SLT-rubl + ub.ot-line.SLT-rubl
    tt-ot-line{2}.VAT-base       = tt-ot-line{2}.VAT-base + ub.ot-line.VAT-base
    tt-ot-line{2}.VAT-rubl       = tt-ot-line{2}.VAT-rubl + ub.ot-line.VAT-rubl
    tt-ot-line{2}.excise-base    = tt-ot-line{2}.excise-base + ub.ot-line.excise-base
    tt-ot-line{2}.excise-rubl    = tt-ot-line{2}.excise-rubl + ub.ot-line.excise-rubl
    tt-ot-line{2}.other-base     = tt-ot-line{2}.other-base + ub.ot-line.other-base
    tt-ot-line{2}.other-rubl     = tt-ot-line{2}.other-rubl + ub.ot-line.other-rubl
    tt-ot-line{2}.road-tax-base  = tt-ot-line{2}.road-tax-base + ub.ot-line.road-tax-base
    tt-ot-line{2}.road-tax-rubl  = tt-ot-line{2}.road-tax-rubl + ub.ot-line.road-tax-rubl
    tt-ot-line{2}.transport-base = tt-ot-line{2}.transport-base + ub.ot-line.transport-base
    tt-ot-line{2}.transport-rubl = tt-ot-line{2}.transport-rubl + ub.ot-line.transport-rubl
    .
   end. /*FOR EACH*/
end procedure.
&endif
/* $Workfile$ e n d */