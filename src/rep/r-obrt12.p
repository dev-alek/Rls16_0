block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-obrt12.p $
$Archive: rep/r-obrt12.p $

расчетная часть детализированой оборотки r-obort1

Автор: Демин Алексей Сергеевич
Дата создания: 12/14/06
Author: Alexey Demin
Creation date: 12/14/06

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-obrt12.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-obrt12.p $":U .
define variable vss-description as character no-undo init "".

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ str/clcprtsl.i }

define input  parameter x-SET_val_TYPE    as integer   no-undo .
define input  parameter p-fo              as decimal   no-undo .
define input  parameter p-free-qnty       as decimal   no-undo .
define input  parameter p-obj-type  like gds-obj.obj-type     .
define input  parameter p-obj-code  like gds-obj.obj-code     .
define input  parameter p-prod-type like gds-obj.prod-type    .
define input  parameter p-prod-code like gds-obj.prod-code    .
define input  parameter p-artic     like gds-obj.artic        .
define input-output parameter p-Free-CostSum    as decimal   no-undo .
define input-output parameter p-Free-SaleSum    as decimal   no-undo .
define input-output parameter p-Res-Qnty        as decimal   no-undo .
define input-output parameter p-Res-CostSum     as decimal   no-undo .
define input-output parameter p-Res-DocSum      as decimal   no-undo .
define input-output parameter p-Res-SaleSum     as decimal   no-undo .
define input-output parameter p-Res-DiscntSum   as decimal   no-undo .

define buffer buf_stk-line for stk-line.
    /* нужны остатки на конец в ценах продажи */
      find last buf_stk-line no-lock
        where buf_stk-line.obj-type  = p-obj-type
          and buf_stk-line.obj-code  = p-obj-code
          and buf_stk-line.artic     = p-artic
          and buf_stk-line.prod-type = p-prod-type
          and buf_stk-line.prod-code = p-prod-code
          and buf_stk-line.sum-type  = {&arh-crsa}
          and buf_stk-line.cat-id    = '##,##'
          and buf_stk-line.fact-order <= p-fo
        use-index category no-error .

      if available buf_stk-line then do:
        if x-SET_val_TYPE = 1  then assign p-Free-SaleSum = p-Free-SaleSum + buf_stk-line.sum-rubl * p-free-qnty / buf_stk-line.fact-qnty .
        else                        assign p-Free-SaleSum = p-Free-SaleSum + buf_stk-line.sum-base * p-free-qnty / buf_stk-line.fact-qnty .
      end.
      if p-Free-SaleSum = ? then p-Free-SaleSum = 0.
      find last buf_stk-line no-lock
        where buf_stk-line.obj-type  = p-obj-type
          and buf_stk-line.obj-code  = p-obj-code
          and buf_stk-line.artic     = p-artic
          and buf_stk-line.prod-type = p-prod-type
          and buf_stk-line.prod-code = p-prod-code
          and buf_stk-line.sum-type  = {&arh-cost}
          and buf_stk-line.cat-id    = '##,##'
          and buf_stk-line.fact-order <= p-fo
        use-index category no-error .

      if available buf_stk-line then do:
        if x-SET_val_TYPE = 1  then assign p-Free-CostSum = p-Free-CostSum + buf_stk-line.sum-rubl * p-free-qnty / buf_stk-line.fact-qnty .
        else                        assign p-Free-CostSum = p-Free-CostSum + buf_stk-line.sum-base * p-free-qnty / buf_stk-line.fact-qnty .
      end.
      if p-Free-CostSum = ? then p-Free-CostSum = 0.
    /* резервы */
    run CalcWaitQnty (input {&TDEDT_Ras_Vnesh} ) .
    run CalcWaitQnty (input {&TDEDT_Ras_Vnesh_VP} ) .
    run CalcWaitQnty (input {&TDEDT_Ras_Vnesh_Kass} ) .
    run CalcWaitQnty (input {&TDEDT_Spi_Vnesh} ) .
    run CalcWaitQnty (input {&TDEDT_Ras_Perem} ) .
    run CalcWaitQnty (input {&TDEDT_Ras_Prvo } ) .
    run CalcWaitQnty (input {&TDEDT_Spi_Prvo } ) .
    run CalcWaitQnty (input {&TDEDT_Inv} ) .
    run CalcWaitQnty (input {&TDEDT_Peresort} ) .




procedure CalcWaitQnty :
  define input  parameter p-ext-doc-type as character no-undo .

  define buffer buf_doc-line for doc-line .

  for each buf_doc-line no-lock
    where ( buf_doc-line.obj-type         = p-obj-type
            and buf_doc-line.obj-code     = p-obj-code
            and buf_doc-line.prod-type    = p-prod-type
            and buf_doc-line.prod-code    = p-prod-code
            and buf_doc-line.artic        = p-artic
            and buf_doc-line.ext-doc-type = p-ext-doc-type
            and buf_doc-line.status_      = {&wayb}
          )
      or ( buf_doc-line.obj-type         = p-obj-type
           and buf_doc-line.obj-code     = p-obj-code
           and buf_doc-line.prod-type    = p-prod-type
           and buf_doc-line.prod-code    = p-prod-code
           and buf_doc-line.artic        = p-artic
           and buf_doc-line.ext-doc-type = p-ext-doc-type
           and buf_doc-line.status_      = {&permitted}
         )
    :
    if ( p-ext-doc-type = {&TDEDT_Inv} or p-ext-doc-type = {&TDEDT_Peresort} ) and buf_doc-line.fact-qnty >= 0 then next .
    run clcprtsl_calc-line (recid (buf_doc-line)) .
    find first tt-allsum-line where tt-allsum-line.sum-type = {&sum-general} no-error .
    if available tt-allsum-line then do:
      if x-SET_val_TYPE = 1  then do:
        assign
          p-Res-Qnty      = p-Res-Qnty      + tt-allsum-line.fact-qnty
          p-Res-CostSum   = p-Res-CostSum   + tt-allsum-line.sum-dsc-rubl-acc
          p-Res-DocSum    = p-Res-DocSum    + tt-allsum-line.sum-dsc-rubl-doc
          p-Res-SaleSum   = p-Res-SaleSum   + tt-allsum-line.sum-dsc-rubl-cur
          p-Res-DiscntSum = p-Res-DiscntSum + tt-allsum-line.sum-dsc-rubl-cur - tt-allsum-line.sum-dsc-rubl-doc
        .
      end.
      else do:
        assign
          p-Res-Qnty      = p-Res-Qnty      + tt-allsum-line.fact-qnty
          p-Res-CostSum   = p-Res-CostSum   + tt-allsum-line.sum-dsc-base-acc
          p-Res-DocSum    = p-Res-DocSum    + tt-allsum-line.sum-dsc-base-doc
          p-Res-SaleSum   = p-Res-SaleSum   + tt-allsum-line.sum-dsc-base-cur
          p-Res-DiscntSum = p-Res-DiscntSum + tt-allsum-line.sum-dsc-base-cur - tt-allsum-line.sum-dsc-base-doc
        .
      end.
    end.
  end.
end procedure. /* CalcWaitQnty */