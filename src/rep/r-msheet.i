/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Инклюд для r-mscheet.p

Автор: Уханов Дмитрий Юрьевич
Дата создания: 01/30/09
Author: Dmitry Ukhanov
Creation date: 01/30/09

Автор1: Суслов Алексей Юрьевич
Дата создания1: 04/12/06

*/



ASSIGN varmeasure-qnty     = ?
       varmeasure-cli-qnty = ?.
find first bef-rvs-doc where bef-rvs-doc.out-code = buf_trn-doc.doc-code and
                             bef-rvs-doc.rvs-type = {&rvs-before-doc} no-lock no-error.
if available bef-rvs-doc then do:
   find first aft-rvs-doc where aft-rvs-doc.out-code = buf_trn-doc.doc-code and
                                aft-rvs-doc.rvs-type = {&rvs-before-doc} no-lock no-error.
   if available aft-rvs-doc then do:
      for each buf_doc-pl where buf_doc-pl.out-code = buf_trn-doc.doc-code and
                            buf_doc-pl.gds-code = {&gds-buffer}.gds-code   no-lock:
          find first bef-rvs-line where bef-rvs-line.rvs-code = bef-rvs-doc.rvs-code and
                                        bef-rvs-line.obj-type = buf_doc-pl.obj-type      and
                                        bef-rvs-line.obj-code = buf_doc-pl.obj-code      and
                                        bef-rvs-line.pl-code  = buf_doc-pl.pl-code       and
                                        bef-rvs-line.gds-code = buf_doc-pl.gds-code      no-lock.
          find first aft-rvs-line where aft-rvs-line.rvs-code = aft-rvs-doc.rvs-code and
                                        aft-rvs-line.obj-type = buf_doc-pl.obj-type      and
                                        aft-rvs-line.obj-code = buf_doc-pl.obj-code      and
                                        aft-rvs-line.pl-code  = buf_doc-pl.pl-code       and
                                        aft-rvs-line.gds-code = buf_doc-pl.gds-code      no-lock.

          ACCUMULATE (aft-rvs-line.measure-qnty     - bef-rvs-line.measure-qnty)     (TOTAL)
                     (aft-rvs-line.measure-cli-qnty - bef-rvs-line.measure-cli-qnty) (TOTAL).
      end. /*each buf_doc-pl*/
      ASSIGN varmeasure-qnty     = (ACCUM TOTAL (aft-rvs-line.measure-qnty     - bef-rvs-line.measure-qnty)    )
             varmeasure-cli-qnty = (ACCUM TOTAL (aft-rvs-line.measure-cli-qnty - bef-rvs-line.measure-cli-qnty)).
   end.
end.
ASSIGN
vardeviationdoc-qnty = buf_doc-line.doc-qnty - varmeasure-qnty
vardeviationcli-qnty = buf_doc-line.cli-qnty - varmeasure-cli-qnty
vardeviationperc     = vardeviationdoc-qnty / buf_doc-line.doc-qnty * 100
vardevfactdoc-qnty   = buf_doc-line.doc-qnty - buf_doc-line.fact-qnty
vardevfactcli-qnty   = buf_doc-line.cli-qnty - buf_doc-line.fact-qnty / buf_doc-line.cli-base-rate
vardevfactperc       = vardevfactdoc-qnty   / buf_doc-line.doc-qnty * 100.

ACCUMULATE buf_doc-line.doc-qnty    (TOTAL)
           buf_doc-line.cli-qnty    (TOTAL)
           vardeviationdoc-qnty (TOTAL)
           vardeviationcli-qnty (TOTAL)
           vardevfactdoc-qnty   (TOTAL)
           vardevfactcli-qnty   (TOTAL).

display stream repstr
sym1  space(0) buf_trn-doc.shift-name
sym2  space(0) buf_trn-doc.shift-date
sym3  space(0) buf_trn-doc.doc-code
sym4  space(0) buf_doc-line.doc-qnty
sym5  space(0) buf_doc-line.cli-qnty
sym6  space(0) vardeviationdoc-qnty
sym7  space(0) vardeviationcli-qnty
sym8  space(0) vardeviationperc
sym9  space(0) vardevfactdoc-qnty
sym10 space(0) vardevfactcli-qnty
sym11 space(0) vardevfactperc
sym12 space(0)
with frame doc-line-frm .
down stream repstr 1 with frame doc-line-frm.