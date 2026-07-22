block-level on error undo, throw.
/*

$Revision: defa58501af7, 2087, rls $
$Author: druban $
$Date: Wed Dec 25 15:23:51 2019 +0300 $
$Workfile: libfarhp.p $
$Archive: str/libfarhp.p $

Внутренние процедуры для библиотеки по работы с финансовыми архивами по финдокументам

Автор: Суслов Алексей Юрьевич
Дата создания: 03/24/06
Author: Alexey Suslov
Creation date: 03/24/06

Создана: 18/12/2003
*/
define variable vss-revision    as character no-undo init "$Revision: defa58501af7, 2087, rls $":U .
define variable vss-author      as character no-undo init "$Author: druban $":U .
define variable vss-date        as character no-undo init "$Date: Wed Dec 25 15:23:51 2019 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: libfarhp.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/libfarhp.p $":U .
define variable vss-description as character no-undo init "Внутренние процедуры для библиотеки по работы с финансовыми архивами по финдокументам".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ str/libfarhp.i }
if valid-handle (g#libfarhp)
and g#libfarhp <> this-procedure :handle
and g#libfarhp :get-signature('libfarhp_calc-arh-fin-doc-an':u) <> ""
then do:
  message
    vss-workfile vss-revision vss-description skip
    "Попытка повторной загрузки внутренних процедур библиотеки для работы с финансовыми архивами по финансовым документам" skip
    g#libfarhp skip
    g#libfarhp :type skip
    g#libfarhp :file-name skip
    valid-handle(g#libfarhp) skip
    this-procedure :handle skip
    this-procedure :type skip
    this-procedure :file-name skip
    valid-handle(this-procedure) skip
    view-as alert-box error .
  undo, return error .
end.
else do:
  assign
    g#libfarhp = this-procedure :handle
  .
end.

on delete of this-procedure do:
  assign
    g#libfarhp = ?
  .
end.
define stream str-err.

procedure libfarhp_calc-arh-fin-doc-an :
define input parameter parmode                    as   character                   no-undo.
define input parameter parhost-code               like ub.fin-doc.host-code        no-undo.
define input parameter parpayer-type              like ub.fin-doc.payer-type       no-undo.
define input parameter parpayer-code              like ub.fin-doc.payer-code       no-undo.
define input parameter parreceiver-type           like ub.fin-doc.receiver-type    no-undo.
define input parameter parreceiver-code           like ub.fin-doc.receiver-code    no-undo.
define input parameter parpayer-code-schet        like ub.fin-schet.code-schet     no-undo.
define input parameter parreceiver-code-schet     like ub.fin-schet.code-schet     no-undo.
define input parameter parfin-ext-doc-type        like ub.fin-doc.fin-ext-doc-type no-undo.
define input parameter parfin-code-an-uchet       like ub.fin-doc.an-uchet-code    no-undo.
define input parameter parfin-code-cel-nazn       like ub.fin-doc.cel-nazn-code    no-undo.
define input parameter parfin-code-cor-acc        like ub.fin-doc.cor-acc          no-undo.
define input parameter parsum-type                as   character                   no-undo.
define input parameter parfact-order              like ub.fin-doc.fact-order       no-undo.
define input parameter parfin-doc-code            like ub.fin-doc.fin-doc-code     no-undo.
define input parameter parfact-date               like ub.fin-doc.fact-date        no-undo.
define input parameter parcurr-code               like ub.fin-doc.curr-code        no-undo.
define input parameter parbase-code               like ub.sysconf.base-code        no-undo.
define input parameter parcurr-dog-code           like ub.contract.curr-code       no-undo.
define input parameter parrel-dog-code            as   logical                     no-undo.
define input parameter parsum-doc                 as   decimal                     no-undo.
define input parameter parsum-rubl                as   decimal                     no-undo.
define input parameter parsum-base                as   decimal                     no-undo.
define input parameter parsum-contr               as   decimal                     no-undo.
define input parameter parsum-vat-doc             as   decimal                     no-undo.
define input parameter parsum-vat-rubl            as   decimal                     no-undo.
define input parameter parsum-vat-base            as   decimal                     no-undo.
define input parameter parsum-vat-contr           as   decimal                     no-undo.
define input parameter parsum-slt-doc             as   decimal                     no-undo.
define input parameter parsum-slt-rubl            as   decimal                     no-undo.
define input parameter parsum-slt-base            as   decimal                     no-undo.
define input parameter parsum-slt-contr           as   decimal                     no-undo.
define buffer bfps_arh-fin-doc-an  for ub.arh-fin-doc-an.
define buffer bfrs_arh-fin-doc-an  for ub.arh-fin-doc-an.
define buffer rbfps_arh-fin-doc-an for ub.arh-fin-doc-an.
define buffer rbfrs_arh-fin-doc-an for ub.arh-fin-doc-an.
define buffer bops_arh-fin-doc-an  for ub.arh-fin-doc-an.
define buffer bors_arh-fin-doc-an  for ub.arh-fin-doc-an.
define buffer bdps_arh-fin-doc-an  for ub.arh-fin-doc-an.
define buffer bdrs_arh-fin-doc-an  for ub.arh-fin-doc-an.
define buffer bfpr_arh-fin-doc-an  for ub.arh-fin-doc-an.
define buffer bfrr_arh-fin-doc-an  for ub.arh-fin-doc-an.
define buffer rbfpr_arh-fin-doc-an for ub.arh-fin-doc-an.
define buffer rbfrr_arh-fin-doc-an for ub.arh-fin-doc-an.
define buffer bopr_arh-fin-doc-an  for ub.arh-fin-doc-an.
define buffer borr_arh-fin-doc-an  for ub.arh-fin-doc-an.
define buffer bdpr_arh-fin-doc-an  for ub.arh-fin-doc-an.
define buffer bdrr_arh-fin-doc-an  for ub.arh-fin-doc-an.
define buffer bfpb_arh-fin-doc-an  for ub.arh-fin-doc-an.
define buffer bfrb_arh-fin-doc-an  for ub.arh-fin-doc-an.
define buffer rbfpb_arh-fin-doc-an for ub.arh-fin-doc-an.
define buffer rbfrb_arh-fin-doc-an for ub.arh-fin-doc-an.
define buffer bopb_arh-fin-doc-an  for ub.arh-fin-doc-an.
define buffer borb_arh-fin-doc-an  for ub.arh-fin-doc-an.
define buffer bdpb_arh-fin-doc-an  for ub.arh-fin-doc-an.
define buffer bdrb_arh-fin-doc-an  for ub.arh-fin-doc-an.
define buffer bfpc_arh-fin-doc-an  for ub.arh-fin-doc-an.
define buffer bfrc_arh-fin-doc-an  for ub.arh-fin-doc-an.
define buffer rbfpc_arh-fin-doc-an for ub.arh-fin-doc-an.
define buffer rbfrc_arh-fin-doc-an for ub.arh-fin-doc-an.
define buffer bopc_arh-fin-doc-an  for ub.arh-fin-doc-an.
define buffer borc_arh-fin-doc-an  for ub.arh-fin-doc-an.
define buffer bdpc_arh-fin-doc-an  for ub.arh-fin-doc-an.
define buffer bdrc_arh-fin-doc-an  for ub.arh-fin-doc-an.
do on error undo, return error substitute ("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
if parmode = "close":u then do:
  find last bops_arh-fin-doc-an where bops_arh-fin-doc-an.host-code         = parhost-code         and
                                      bops_arh-fin-doc-an.cli-type          = parpayer-type        and
                                      bops_arh-fin-doc-an.cli-code          = parpayer-code        and
                                      bops_arh-fin-doc-an.code-schet        = parpayer-code-schet  and
                                      bops_arh-fin-doc-an.fin-ext-doc-type  = parfin-ext-doc-type  and
                                      bops_arh-fin-doc-an.fin-code-an-uchet = parfin-code-an-uchet and
                                      bops_arh-fin-doc-an.fin-code-cel-nazn = parfin-code-cel-nazn and
                                      bops_arh-fin-doc-an.fin-code-cor-acc  = parfin-code-cor-acc  and
                                      bops_arh-fin-doc-an.calc-curr-code    = parcurr-code         and
                                      bops_arh-fin-doc-an.sum-type          = parsum-type          and
                                      bops_arh-fin-doc-an.fact-order        < parfact-order        use-index pi no-error.
  create bfps_arh-fin-doc-an.
  assign
    bfps_arh-fin-doc-an.host-code         = parhost-code
    bfps_arh-fin-doc-an.cli-type          = parpayer-type
    bfps_arh-fin-doc-an.cli-code          = parpayer-code
    bfps_arh-fin-doc-an.code-schet        = parpayer-code-schet
    bfps_arh-fin-doc-an.fin-ext-doc-type  = parfin-ext-doc-type
    bfps_arh-fin-doc-an.fin-code-an-uchet = parfin-code-an-uchet
    bfps_arh-fin-doc-an.fin-code-cel-nazn = parfin-code-cel-nazn
    bfps_arh-fin-doc-an.fin-code-cor-acc  = parfin-code-cor-acc
    bfps_arh-fin-doc-an.calc-curr-code    = parcurr-code
    bfps_arh-fin-doc-an.sum-type          = parsum-type
    bfps_arh-fin-doc-an.cource-des        = "s":u
    bfps_arh-fin-doc-an.fact-order        = parfact-order
    bfps_arh-fin-doc-an.fin-doc-code      = parfin-doc-code
    bfps_arh-fin-doc-an.fact-date         = parfact-date
    bfps_arh-fin-doc-an.curr-code         = parcurr-code
    bfps_arh-fin-doc-an.income            = (if available bops_arh-fin-doc-an then bops_arh-fin-doc-an.income      else 0)
    bfps_arh-fin-doc-an.income-vat        = (if available bops_arh-fin-doc-an then bops_arh-fin-doc-an.income-vat  else 0)
    bfps_arh-fin-doc-an.income-slt        = (if available bops_arh-fin-doc-an then bops_arh-fin-doc-an.income-slt  else 0)
    bfps_arh-fin-doc-an.expense           = (if available bops_arh-fin-doc-an then bops_arh-fin-doc-an.expense     else 0) + parsum-doc
    bfps_arh-fin-doc-an.expense-vat       = (if available bops_arh-fin-doc-an then bops_arh-fin-doc-an.expense-vat else 0) + parsum-vat-doc
    bfps_arh-fin-doc-an.expense-slt       = (if available bops_arh-fin-doc-an then bops_arh-fin-doc-an.expense-slt else 0) + parsum-slt-doc
  .
end.
else do:
  find first bfps_arh-fin-doc-an where bfps_arh-fin-doc-an.host-code         = parhost-code         and
                                       bfps_arh-fin-doc-an.cli-type          = parpayer-type        and
                                       bfps_arh-fin-doc-an.cli-code          = parpayer-code        and
                                       bfps_arh-fin-doc-an.code-schet        = parpayer-code-schet  and
                                       bfps_arh-fin-doc-an.fin-ext-doc-type  = parfin-ext-doc-type  and
                                       bfps_arh-fin-doc-an.fin-code-an-uchet = parfin-code-an-uchet and
                                       bfps_arh-fin-doc-an.fin-code-cel-nazn = parfin-code-cel-nazn and
                                       bfps_arh-fin-doc-an.fin-code-cor-acc  = parfin-code-cor-acc  and
                                       bfps_arh-fin-doc-an.calc-curr-code    = parcurr-code         and
                                       bfps_arh-fin-doc-an.sum-type          = parsum-type          and
                                       bfps_arh-fin-doc-an.fact-order        = parfact-order        exclusive-lock.
end.
for each rbfps_arh-fin-doc-an where rbfps_arh-fin-doc-an.host-code          = bfps_arh-fin-doc-an.host-code         and
                                    rbfps_arh-fin-doc-an.cli-type           = parpayer-type                         and
                                    rbfps_arh-fin-doc-an.cli-code           = parpayer-code                         and
                                    rbfps_arh-fin-doc-an.code-schet         = bfps_arh-fin-doc-an.code-schet        and
                                    rbfps_arh-fin-doc-an.fin-ext-doc-type   = bfps_arh-fin-doc-an.fin-ext-doc-type  and
                                    rbfps_arh-fin-doc-an.fin-code-an-uchet  = bfps_arh-fin-doc-an.fin-code-an-uchet and
                                    rbfps_arh-fin-doc-an.fin-code-cel-nazn  = bfps_arh-fin-doc-an.fin-code-cel-nazn and
                                    rbfps_arh-fin-doc-an.fin-code-cor-acc   = bfps_arh-fin-doc-an.fin-code-cor-acc  and
                                    rbfps_arh-fin-doc-an.calc-curr-code     = bfps_arh-fin-doc-an.calc-curr-code    and
                                    rbfps_arh-fin-doc-an.sum-type           = bfps_arh-fin-doc-an.sum-type          and
                                    rbfps_arh-fin-doc-an.fact-order         > bfps_arh-fin-doc-an.fact-order        use-index pi exclusive-lock on error undo, return error return-value :
  assign
    rbfps_arh-fin-doc-an.expense     = rbfps_arh-fin-doc-an.expense     + parsum-doc
    rbfps_arh-fin-doc-an.expense-vat = rbfps_arh-fin-doc-an.expense-vat + parsum-vat-doc
    rbfps_arh-fin-doc-an.expense-slt = rbfps_arh-fin-doc-an.expense-slt + parsum-slt-doc.
end.
if parmode = "close":u then do:
  find last bors_arh-fin-doc-an where bors_arh-fin-doc-an.host-code         = parhost-code            and
                                      bors_arh-fin-doc-an.cli-type          = parreceiver-type        and
                                      bors_arh-fin-doc-an.cli-code          = parreceiver-code        and
                                      bors_arh-fin-doc-an.code-schet        = parreceiver-code-schet  and
                                      bors_arh-fin-doc-an.fin-ext-doc-type  = parfin-ext-doc-type     and
                                      bors_arh-fin-doc-an.fin-code-an-uchet = parfin-code-an-uchet    and
                                      bors_arh-fin-doc-an.fin-code-cel-nazn = parfin-code-cel-nazn    and
                                      bors_arh-fin-doc-an.fin-code-cor-acc  = parfin-code-cor-acc     and
                                      bors_arh-fin-doc-an.calc-curr-code    = parcurr-code            and
                                      bors_arh-fin-doc-an.sum-type          = parsum-type             and
                                      bors_arh-fin-doc-an.fact-order        < parfact-order           use-index pi no-error.
  create bfrs_arh-fin-doc-an.
  assign
    bfrs_arh-fin-doc-an.host-code         = parhost-code
    bfrs_arh-fin-doc-an.cli-type          = parreceiver-type
    bfrs_arh-fin-doc-an.cli-code          = parreceiver-code
    bfrs_arh-fin-doc-an.code-schet        = parreceiver-code-schet
    bfrs_arh-fin-doc-an.fin-ext-doc-type  = parfin-ext-doc-type
    bfrs_arh-fin-doc-an.fin-code-an-uchet = parfin-code-an-uchet
    bfrs_arh-fin-doc-an.fin-code-cel-nazn = parfin-code-cel-nazn
    bfrs_arh-fin-doc-an.fin-code-cor-acc  = parfin-code-cor-acc
    bfrs_arh-fin-doc-an.calc-curr-code    = parcurr-code
    bfrs_arh-fin-doc-an.sum-type          = parsum-type
    bfrs_arh-fin-doc-an.cource-des        = "s":u
    bfrs_arh-fin-doc-an.fact-order        = parfact-order
    bfrs_arh-fin-doc-an.fin-doc-code      = parfin-doc-code
    bfrs_arh-fin-doc-an.fact-date         = parfact-date
    bfrs_arh-fin-doc-an.curr-code         = parcurr-code.
  assign
    bfrs_arh-fin-doc-an.expense           = (if available bors_arh-fin-doc-an then bors_arh-fin-doc-an.expense     else 0)
    bfrs_arh-fin-doc-an.expense-vat       = (if available bors_arh-fin-doc-an then bors_arh-fin-doc-an.expense-vat else 0)
    bfrs_arh-fin-doc-an.expense-slt       = (if available bors_arh-fin-doc-an then bors_arh-fin-doc-an.expense-slt else 0)
    bfrs_arh-fin-doc-an.income            = (if available bors_arh-fin-doc-an then bors_arh-fin-doc-an.income      else 0) + parsum-doc
    bfrs_arh-fin-doc-an.income-vat        = (if available bors_arh-fin-doc-an then bors_arh-fin-doc-an.income-vat  else 0) + parsum-vat-doc
    bfrs_arh-fin-doc-an.income-slt        = (if available bors_arh-fin-doc-an then bors_arh-fin-doc-an.income-slt  else 0) + parsum-slt-doc
  .
end.
else do:
  find first bfrs_arh-fin-doc-an where bfrs_arh-fin-doc-an.host-code         = parhost-code            and
                                       bfrs_arh-fin-doc-an.cli-type          = parreceiver-type        and
                                       bfrs_arh-fin-doc-an.cli-code          = parreceiver-code        and
                                       bfrs_arh-fin-doc-an.code-schet        = parreceiver-code-schet  and
                                       bfrs_arh-fin-doc-an.fin-ext-doc-type  = parfin-ext-doc-type     and
                                       bfrs_arh-fin-doc-an.fin-code-an-uchet = parfin-code-an-uchet    and
                                       bfrs_arh-fin-doc-an.fin-code-cel-nazn = parfin-code-cel-nazn    and
                                       bfrs_arh-fin-doc-an.fin-code-cor-acc  = parfin-code-cor-acc     and
                                       bfrs_arh-fin-doc-an.calc-curr-code    = parcurr-code            and
                                       bfrs_arh-fin-doc-an.sum-type          = parsum-type             and
                                       bfrs_arh-fin-doc-an.fact-order        = parfact-order           exclusive-lock.
end.
for each rbfrs_arh-fin-doc-an where rbfrs_arh-fin-doc-an.host-code         = bfrs_arh-fin-doc-an.host-code         and
                                    rbfrs_arh-fin-doc-an.cli-type          = parreceiver-type                      and
                                    rbfrs_arh-fin-doc-an.cli-code          = parreceiver-code                      and
                                    rbfrs_arh-fin-doc-an.code-schet        = bfrs_arh-fin-doc-an.code-schet        and
                                    rbfrs_arh-fin-doc-an.fin-ext-doc-type  = bfrs_arh-fin-doc-an.fin-ext-doc-type  and
                                    rbfrs_arh-fin-doc-an.fin-code-an-uchet = bfrs_arh-fin-doc-an.fin-code-an-uchet and
                                    rbfrs_arh-fin-doc-an.fin-code-cel-nazn = bfrs_arh-fin-doc-an.fin-code-cel-nazn and
                                    rbfrs_arh-fin-doc-an.fin-code-cor-acc  = bfrs_arh-fin-doc-an.fin-code-cor-acc  and
                                    rbfrs_arh-fin-doc-an.calc-curr-code    = bfrs_arh-fin-doc-an.calc-curr-code    and
                                    rbfrs_arh-fin-doc-an.sum-type          = bfrs_arh-fin-doc-an.sum-type          and
                                    rbfrs_arh-fin-doc-an.fact-order        > bfrs_arh-fin-doc-an.fact-order        use-index pi exclusive-lock on error undo, return error return-value :
  assign
    rbfrs_arh-fin-doc-an.income     = rbfrs_arh-fin-doc-an.income     + parsum-doc
    rbfrs_arh-fin-doc-an.income-vat = rbfrs_arh-fin-doc-an.income-vat + parsum-vat-doc
    rbfrs_arh-fin-doc-an.income-slt = rbfrs_arh-fin-doc-an.income-slt + parsum-slt-doc
  .
end.
if parmode = "delete":u then do:
  delete bfps_arh-fin-doc-an.
  delete bfrs_arh-fin-doc-an.
end.
if parcurr-code <> 0 then do:
  if parmode = "close":u then do:
    find last bopr_arh-fin-doc-an where bopr_arh-fin-doc-an.host-code         = parhost-code         and
                                        bopr_arh-fin-doc-an.cli-type          = parpayer-type        and
                                        bopr_arh-fin-doc-an.cli-code          = parpayer-code        and
                                        bopr_arh-fin-doc-an.code-schet        = parpayer-code-schet  and
                                        bopr_arh-fin-doc-an.fin-ext-doc-type  = parfin-ext-doc-type  and
                                        bopr_arh-fin-doc-an.fin-code-an-uchet = parfin-code-an-uchet and
                                        bopr_arh-fin-doc-an.fin-code-cel-nazn = parfin-code-cel-nazn and
                                        bopr_arh-fin-doc-an.fin-code-cor-acc  = parfin-code-cor-acc  and
                                        bopr_arh-fin-doc-an.calc-curr-code    = 0                    and
                                        bopr_arh-fin-doc-an.sum-type          = parsum-type          and
                                        bopr_arh-fin-doc-an.fact-order        < parfact-order        use-index pi no-error.
    create bfpr_arh-fin-doc-an.
    assign
      bfpr_arh-fin-doc-an.host-code         = parhost-code
      bfpr_arh-fin-doc-an.cli-type          = parpayer-type
      bfpr_arh-fin-doc-an.cli-code          = parpayer-code
      bfpr_arh-fin-doc-an.code-schet        = parpayer-code-schet
      bfpr_arh-fin-doc-an.fin-ext-doc-type  = parfin-ext-doc-type
      bfpr_arh-fin-doc-an.fin-code-an-uchet = parfin-code-an-uchet
      bfpr_arh-fin-doc-an.fin-code-cel-nazn = parfin-code-cel-nazn
      bfpr_arh-fin-doc-an.fin-code-cor-acc  = parfin-code-cor-acc
      bfpr_arh-fin-doc-an.calc-curr-code    = 0
      bfpr_arh-fin-doc-an.sum-type          = parsum-type
      bfpr_arh-fin-doc-an.cource-des        = "r":u
      bfpr_arh-fin-doc-an.fact-order        = parfact-order
      bfpr_arh-fin-doc-an.fin-doc-code      = parfin-doc-code
      bfpr_arh-fin-doc-an.fact-date         = parfact-date
      bfpr_arh-fin-doc-an.curr-code         = parcurr-code
      bfpr_arh-fin-doc-an.income            = (if available bopr_arh-fin-doc-an then bopr_arh-fin-doc-an.income     else 0)
      bfpr_arh-fin-doc-an.income-vat        = (if available bopr_arh-fin-doc-an then bopr_arh-fin-doc-an.income-vat else 0)
      bfpr_arh-fin-doc-an.income-slt        = (if available bopr_arh-fin-doc-an then bopr_arh-fin-doc-an.income-slt else 0)
      bfpr_arh-fin-doc-an.expense           = (if available bopr_arh-fin-doc-an then bopr_arh-fin-doc-an.expense     else 0) + parsum-rubl
      bfpr_arh-fin-doc-an.expense-vat       = (if available bopr_arh-fin-doc-an then bopr_arh-fin-doc-an.expense-vat else 0) + parsum-vat-rubl
      bfpr_arh-fin-doc-an.expense-slt       = (if available bopr_arh-fin-doc-an then bopr_arh-fin-doc-an.expense-slt else 0) + parsum-slt-rubl
    .
  end.
  else do:
    find first bfpr_arh-fin-doc-an where bfpr_arh-fin-doc-an.host-code         = parhost-code         and
                                         bfpr_arh-fin-doc-an.cli-type          = parpayer-type        and
                                         bfpr_arh-fin-doc-an.cli-code          = parpayer-code        and
                                         bfpr_arh-fin-doc-an.code-schet        = parpayer-code-schet  and
                                         bfpr_arh-fin-doc-an.fin-ext-doc-type  = parfin-ext-doc-type  and
                                         bfpr_arh-fin-doc-an.fin-code-an-uchet = parfin-code-an-uchet and
                                         bfpr_arh-fin-doc-an.fin-code-cel-nazn = parfin-code-cel-nazn and
                                         bfpr_arh-fin-doc-an.fin-code-cor-acc  = parfin-code-cor-acc  and
                                         bfpr_arh-fin-doc-an.calc-curr-code    = 0                    and
                                         bfpr_arh-fin-doc-an.sum-type          = parsum-type          and
                                         bfpr_arh-fin-doc-an.fact-order        = parfact-order        exclusive-lock.
  end.
  for each rbfpr_arh-fin-doc-an where rbfpr_arh-fin-doc-an.host-code         = bfpr_arh-fin-doc-an.host-code         and
                                      rbfpr_arh-fin-doc-an.cli-type          = parpayer-type                         and
                                      rbfpr_arh-fin-doc-an.cli-code          = parpayer-code                         and
                                      rbfpr_arh-fin-doc-an.code-schet        = bfpr_arh-fin-doc-an.code-schet        and
                                      rbfpr_arh-fin-doc-an.fin-ext-doc-type  = bfpr_arh-fin-doc-an.fin-ext-doc-type  and
                                      rbfpr_arh-fin-doc-an.fin-code-an-uchet = bfpr_arh-fin-doc-an.fin-code-an-uchet and
                                      rbfpr_arh-fin-doc-an.fin-code-cel-nazn = bfpr_arh-fin-doc-an.fin-code-cel-nazn and
                                      rbfpr_arh-fin-doc-an.fin-code-cor-acc  = bfpr_arh-fin-doc-an.fin-code-cor-acc  and
                                      rbfpr_arh-fin-doc-an.calc-curr-code    = bfpr_arh-fin-doc-an.calc-curr-code    and
                                      rbfpr_arh-fin-doc-an.sum-type          = bfpr_arh-fin-doc-an.sum-type          and
                                      rbfpr_arh-fin-doc-an.fact-order        > bfpr_arh-fin-doc-an.fact-order        use-index pi exclusive-lock on error undo, return error return-value :
    assign
      rbfpr_arh-fin-doc-an.expense     = rbfpr_arh-fin-doc-an.expense     + parsum-rubl
      rbfpr_arh-fin-doc-an.expense-vat = rbfpr_arh-fin-doc-an.expense-vat + parsum-vat-rubl
      rbfpr_arh-fin-doc-an.expense-slt = rbfpr_arh-fin-doc-an.expense-slt + parsum-slt-rubl
    .
  end.
  if parmode = "close":u then do:
    find last borr_arh-fin-doc-an where borr_arh-fin-doc-an.host-code         = parhost-code            and
                                        borr_arh-fin-doc-an.cli-type          = parreceiver-type        and
                                        borr_arh-fin-doc-an.cli-code          = parreceiver-code        and
                                        borr_arh-fin-doc-an.code-schet        = parreceiver-code-schet  and
                                        borr_arh-fin-doc-an.fin-ext-doc-type  = parfin-ext-doc-type     and
                                        borr_arh-fin-doc-an.fin-code-an-uchet = parfin-code-an-uchet    and
                                        borr_arh-fin-doc-an.fin-code-cel-nazn = parfin-code-cel-nazn    and
                                        borr_arh-fin-doc-an.fin-code-cor-acc  = parfin-code-cor-acc     and
                                        borr_arh-fin-doc-an.calc-curr-code    = 0                       and
                                        borr_arh-fin-doc-an.sum-type          = parsum-type             and
                                        borr_arh-fin-doc-an.fact-order        < parfact-order           use-index pi no-error.
      create bfrr_arh-fin-doc-an.
    assign
      bfrr_arh-fin-doc-an.host-code         = parhost-code
      bfrr_arh-fin-doc-an.cli-type          = parreceiver-type
      bfrr_arh-fin-doc-an.cli-code          = parreceiver-code
      bfrr_arh-fin-doc-an.code-schet        = parreceiver-code-schet
      bfrr_arh-fin-doc-an.fin-ext-doc-type  = parfin-ext-doc-type
      bfrr_arh-fin-doc-an.fin-code-an-uchet = parfin-code-an-uchet
      bfrr_arh-fin-doc-an.fin-code-cel-nazn = parfin-code-cel-nazn
      bfrr_arh-fin-doc-an.fin-code-cor-acc  = parfin-code-cor-acc
      bfrr_arh-fin-doc-an.calc-curr-code    = 0
      bfrr_arh-fin-doc-an.sum-type          = parsum-type
      bfrr_arh-fin-doc-an.cource-des        = "r":u
      bfrr_arh-fin-doc-an.fact-order        = parfact-order
      bfrr_arh-fin-doc-an.fin-doc-code      = parfin-doc-code
      bfrr_arh-fin-doc-an.fact-date         = parfact-date
      bfrr_arh-fin-doc-an.curr-code         = parcurr-code.
    assign
      bfrr_arh-fin-doc-an.expense           = (if available borr_arh-fin-doc-an then borr_arh-fin-doc-an.expense     else 0)
      bfrr_arh-fin-doc-an.expense-vat       = (if available borr_arh-fin-doc-an then borr_arh-fin-doc-an.expense-vat else 0)
      bfrr_arh-fin-doc-an.expense-slt       = (if available borr_arh-fin-doc-an then borr_arh-fin-doc-an.expense-slt else 0)
      bfrr_arh-fin-doc-an.income            = (if available borr_arh-fin-doc-an then borr_arh-fin-doc-an.income      else 0) + parsum-rubl
      bfrr_arh-fin-doc-an.income-vat        = (if available borr_arh-fin-doc-an then borr_arh-fin-doc-an.income-vat  else 0) + parsum-vat-rubl
      bfrr_arh-fin-doc-an.income-slt        = (if available borr_arh-fin-doc-an then borr_arh-fin-doc-an.income-slt  else 0) + parsum-slt-rubl
    .
  end.
  else do:
    find first bfrr_arh-fin-doc-an where bfrr_arh-fin-doc-an.host-code         = parhost-code            and
                                         bfrr_arh-fin-doc-an.cli-type          = parreceiver-type        and
                                         bfrr_arh-fin-doc-an.cli-code          = parreceiver-code        and
                                         bfrr_arh-fin-doc-an.code-schet        = parreceiver-code-schet  and
                                         bfrr_arh-fin-doc-an.fin-ext-doc-type  = parfin-ext-doc-type     and
                                         bfrr_arh-fin-doc-an.fin-code-an-uchet = parfin-code-an-uchet    and
                                         bfrr_arh-fin-doc-an.fin-code-cel-nazn = parfin-code-cel-nazn    and
                                         bfrr_arh-fin-doc-an.fin-code-cor-acc  = parfin-code-cor-acc     and
                                         bfrr_arh-fin-doc-an.calc-curr-code    = 0                       and
                                         bfrr_arh-fin-doc-an.sum-type          = parsum-type             and
                                         bfrr_arh-fin-doc-an.fact-order        = parfact-order           no-error.
  end.
  for each rbfrr_arh-fin-doc-an where rbfrr_arh-fin-doc-an.host-code         = bfrr_arh-fin-doc-an.host-code         and
                                      rbfrr_arh-fin-doc-an.cli-type          = parreceiver-type                      and
                                      rbfrr_arh-fin-doc-an.cli-code          = parreceiver-code                      and
                                      rbfrr_arh-fin-doc-an.code-schet        = bfrr_arh-fin-doc-an.code-schet        and
                                      rbfrr_arh-fin-doc-an.fin-ext-doc-type  = bfrr_arh-fin-doc-an.fin-ext-doc-type  and
                                      rbfrr_arh-fin-doc-an.fin-code-an-uchet = bfrr_arh-fin-doc-an.fin-code-an-uchet and
                                      rbfrr_arh-fin-doc-an.fin-code-cel-nazn = bfrr_arh-fin-doc-an.fin-code-cel-nazn and
                                      rbfrr_arh-fin-doc-an.fin-code-cor-acc  = bfrr_arh-fin-doc-an.fin-code-cor-acc  and
                                      rbfrr_arh-fin-doc-an.calc-curr-code    = bfrr_arh-fin-doc-an.calc-curr-code    and
                                      rbfrr_arh-fin-doc-an.sum-type          = bfrr_arh-fin-doc-an.sum-type          and
                                      rbfrr_arh-fin-doc-an.fact-order        > bfrr_arh-fin-doc-an.fact-order        use-index pi exclusive-lock on error undo, return error return-value :
    assign
      rbfrr_arh-fin-doc-an.income     = rbfrr_arh-fin-doc-an.income     + parsum-rubl
      rbfrr_arh-fin-doc-an.income-vat = rbfrr_arh-fin-doc-an.income-vat + parsum-vat-rubl
      rbfrr_arh-fin-doc-an.income-slt = rbfrr_arh-fin-doc-an.income-slt + parsum-slt-rubl
    .
  end.
  if parmode = "delete":u then do:
    delete bfpr_arh-fin-doc-an.
    delete bfrr_arh-fin-doc-an.
  end.
end.
if parbase-code <> parcurr-code and
   parbase-code <> 0            then do:
  if parmode = "close":u then do:
    find last bopb_arh-fin-doc-an where bopb_arh-fin-doc-an.host-code         = parhost-code         and
                                        bopb_arh-fin-doc-an.cli-type          = parpayer-type        and
                                        bopb_arh-fin-doc-an.cli-code          = parpayer-code        and
                                        bopb_arh-fin-doc-an.code-schet        = parpayer-code-schet  and
                                        bopb_arh-fin-doc-an.fin-ext-doc-type  = parfin-ext-doc-type  and
                                        bopb_arh-fin-doc-an.fin-code-an-uchet = parfin-code-an-uchet and
                                        bopb_arh-fin-doc-an.fin-code-cel-nazn = parfin-code-cel-nazn and
                                        bopb_arh-fin-doc-an.fin-code-cor-acc  = parfin-code-cor-acc  and
                                        bopb_arh-fin-doc-an.calc-curr-code    = parbase-code         and
                                        bopb_arh-fin-doc-an.sum-type          = parsum-type          and
                                        bopb_arh-fin-doc-an.fact-order        < parfact-order        use-index pi no-error.
    create bfpb_arh-fin-doc-an.
    assign
      bfpb_arh-fin-doc-an.host-code         = parhost-code
      bfpb_arh-fin-doc-an.cli-type          = parpayer-type
      bfpb_arh-fin-doc-an.cli-code          = parpayer-code
      bfpb_arh-fin-doc-an.code-schet        = parpayer-code-schet
      bfpb_arh-fin-doc-an.fin-ext-doc-type  = parfin-ext-doc-type
      bfpb_arh-fin-doc-an.fin-code-an-uchet = parfin-code-an-uchet
      bfpb_arh-fin-doc-an.fin-code-cel-nazn = parfin-code-cel-nazn
      bfpb_arh-fin-doc-an.fin-code-cor-acc  = parfin-code-cor-acc
      bfpb_arh-fin-doc-an.calc-curr-code    = parbase-code
      bfpb_arh-fin-doc-an.sum-type          = parsum-type
      bfpb_arh-fin-doc-an.cource-des        = "b":u
      bfpb_arh-fin-doc-an.fact-order        = parfact-order
      bfpb_arh-fin-doc-an.fin-doc-code      = parfin-doc-code
      bfpb_arh-fin-doc-an.fact-date         = parfact-date
      bfpb_arh-fin-doc-an.curr-code         = parcurr-code
      bfpb_arh-fin-doc-an.income            = (if available bopb_arh-fin-doc-an then bopb_arh-fin-doc-an.income      else 0)
      bfpb_arh-fin-doc-an.income-vat        = (if available bopb_arh-fin-doc-an then bopb_arh-fin-doc-an.income-vat  else 0)
      bfpb_arh-fin-doc-an.income-slt        = (if available bopb_arh-fin-doc-an then bopb_arh-fin-doc-an.income-slt  else 0)
      bfpb_arh-fin-doc-an.expense           = (if available bopb_arh-fin-doc-an then bopb_arh-fin-doc-an.expense     else 0) + parsum-base
      bfpb_arh-fin-doc-an.expense-vat       = (if available bopb_arh-fin-doc-an then bopb_arh-fin-doc-an.expense-vat else 0) + parsum-vat-base
      bfpb_arh-fin-doc-an.expense-slt       = (if available bopb_arh-fin-doc-an then bopb_arh-fin-doc-an.expense-slt else 0) + parsum-slt-base
    .
  end.
  else do:
    find last bfpb_arh-fin-doc-an where bfpb_arh-fin-doc-an.host-code         = parhost-code         and
                                        bfpb_arh-fin-doc-an.cli-type          = parpayer-type        and
                                        bfpb_arh-fin-doc-an.cli-code          = parpayer-code        and
                                        bfpb_arh-fin-doc-an.code-schet        = parpayer-code-schet  and
                                        bfpb_arh-fin-doc-an.fin-ext-doc-type  = parfin-ext-doc-type  and
                                        bfpb_arh-fin-doc-an.fin-code-an-uchet = parfin-code-an-uchet and
                                        bfpb_arh-fin-doc-an.fin-code-cel-nazn = parfin-code-cel-nazn and
                                        bfpb_arh-fin-doc-an.fin-code-cor-acc  = parfin-code-cor-acc  and
                                        bfpb_arh-fin-doc-an.calc-curr-code    = parbase-code         and
                                        bfpb_arh-fin-doc-an.sum-type          = parsum-type          and
                                        bfpb_arh-fin-doc-an.fact-order        = parfact-order        no-error.
  end.
  for each rbfpb_arh-fin-doc-an where rbfpb_arh-fin-doc-an.host-code         = bfpb_arh-fin-doc-an.host-code         and
                                      rbfpb_arh-fin-doc-an.cli-type          = parpayer-type                         and
                                      rbfpb_arh-fin-doc-an.cli-code          = parpayer-code                         and
                                      rbfpb_arh-fin-doc-an.code-schet        = bfpb_arh-fin-doc-an.code-schet        and
                                      rbfpb_arh-fin-doc-an.fin-ext-doc-type  = bfpb_arh-fin-doc-an.fin-ext-doc-type  and
                                      rbfpb_arh-fin-doc-an.fin-code-an-uchet = bfpb_arh-fin-doc-an.fin-code-an-uchet and
                                      rbfpb_arh-fin-doc-an.fin-code-cel-nazn = bfpb_arh-fin-doc-an.fin-code-cel-nazn and
                                      rbfpb_arh-fin-doc-an.fin-code-cor-acc  = bfpb_arh-fin-doc-an.fin-code-cor-acc  and
                                      rbfpb_arh-fin-doc-an.calc-curr-code    = bfpb_arh-fin-doc-an.calc-curr-code    and
                                      rbfpb_arh-fin-doc-an.sum-type          = bfpb_arh-fin-doc-an.sum-type          and
                                      rbfpb_arh-fin-doc-an.fact-order        > bfpb_arh-fin-doc-an.fact-order        use-index pi exclusive-lock on error undo, return error return-value :
    assign
      rbfpb_arh-fin-doc-an.expense     = rbfpb_arh-fin-doc-an.expense     + parsum-base
      rbfpb_arh-fin-doc-an.expense-vat = rbfpb_arh-fin-doc-an.expense-vat + parsum-vat-base
      rbfpb_arh-fin-doc-an.expense-slt = rbfpb_arh-fin-doc-an.expense-slt + parsum-slt-base
    .
  end.
  if parmode = "close":u then do:
    find last borb_arh-fin-doc-an where borb_arh-fin-doc-an.host-code         = parhost-code            and
                                        borb_arh-fin-doc-an.cli-type          = parreceiver-type        and
                                        borb_arh-fin-doc-an.cli-code          = parreceiver-code        and
                                        borb_arh-fin-doc-an.code-schet        = parreceiver-code-schet  and
                                        borb_arh-fin-doc-an.fin-ext-doc-type  = parfin-ext-doc-type     and
                                        borb_arh-fin-doc-an.fin-code-an-uchet = parfin-code-an-uchet    and
                                        borb_arh-fin-doc-an.fin-code-cel-nazn = parfin-code-cel-nazn    and
                                        borb_arh-fin-doc-an.fin-code-cor-acc  = parfin-code-cor-acc     and
                                        borb_arh-fin-doc-an.calc-curr-code    = parbase-code            and
                                        borb_arh-fin-doc-an.sum-type          = parsum-type             and
                                        borb_arh-fin-doc-an.fact-order        < parfact-order           use-index pi no-error.
    create bfrb_arh-fin-doc-an.
    assign
      bfrb_arh-fin-doc-an.host-code         = parhost-code
      bfrb_arh-fin-doc-an.cli-type          = parreceiver-type
      bfrb_arh-fin-doc-an.cli-code          = parreceiver-code
      bfrb_arh-fin-doc-an.code-schet        = parreceiver-code-schet
      bfrb_arh-fin-doc-an.fin-ext-doc-type  = parfin-ext-doc-type
      bfrb_arh-fin-doc-an.fin-code-an-uchet = parfin-code-an-uchet
      bfrb_arh-fin-doc-an.fin-code-cel-nazn = parfin-code-cel-nazn
      bfrb_arh-fin-doc-an.fin-code-cor-acc  = parfin-code-cor-acc
      bfrb_arh-fin-doc-an.calc-curr-code    = parbase-code
      bfrb_arh-fin-doc-an.sum-type          = parsum-type
      bfrb_arh-fin-doc-an.cource-des        = "b":u
      bfrb_arh-fin-doc-an.fact-order        = parfact-order
      bfrb_arh-fin-doc-an.fin-doc-code      = parfin-doc-code
      bfrb_arh-fin-doc-an.fact-date         = parfact-date
      bfrb_arh-fin-doc-an.curr-code         = parcurr-code
    .
    assign
      bfrb_arh-fin-doc-an.expense           = (if available borb_arh-fin-doc-an then borb_arh-fin-doc-an.expense     else 0)
      bfrb_arh-fin-doc-an.expense-vat       = (if available borb_arh-fin-doc-an then borb_arh-fin-doc-an.expense-vat else 0)
      bfrb_arh-fin-doc-an.expense-slt       = (if available borb_arh-fin-doc-an then borb_arh-fin-doc-an.expense-slt else 0)
      bfrb_arh-fin-doc-an.income            = (if available borb_arh-fin-doc-an then borb_arh-fin-doc-an.income      else 0) + parsum-base
      bfrb_arh-fin-doc-an.income-vat        = (if available borb_arh-fin-doc-an then borb_arh-fin-doc-an.income-vat  else 0) + parsum-vat-base
      bfrb_arh-fin-doc-an.income-slt        = (if available borb_arh-fin-doc-an then borb_arh-fin-doc-an.income-slt  else 0) + parsum-slt-base
    .
  end.
  else do:
      find first bfrb_arh-fin-doc-an where bfrb_arh-fin-doc-an.host-code         = parhost-code            and
                                           bfrb_arh-fin-doc-an.cli-type          = parreceiver-type        and
                                           bfrb_arh-fin-doc-an.cli-code          = parreceiver-code        and
                                           bfrb_arh-fin-doc-an.code-schet        = parreceiver-code-schet  and
                                           bfrb_arh-fin-doc-an.fin-ext-doc-type  = parfin-ext-doc-type     and
                                           bfrb_arh-fin-doc-an.fin-code-an-uchet = parfin-code-an-uchet    and
                                           bfrb_arh-fin-doc-an.fin-code-cel-nazn = parfin-code-cel-nazn    and
                                           bfrb_arh-fin-doc-an.fin-code-cor-acc  = parfin-code-cor-acc     and
                                           bfrb_arh-fin-doc-an.calc-curr-code    = parbase-code            and
                                           bfrb_arh-fin-doc-an.sum-type          = parsum-type             and
                                           bfrb_arh-fin-doc-an.fact-order        = parfact-order           exclusive-lock.
  end.
  for each rbfrb_arh-fin-doc-an where rbfrb_arh-fin-doc-an.host-code         = bfrb_arh-fin-doc-an.host-code         and
                                      rbfrb_arh-fin-doc-an.cli-type          = parreceiver-type                      and
                                      rbfrb_arh-fin-doc-an.cli-code          = parreceiver-code                      and
                                      rbfrb_arh-fin-doc-an.code-schet        = bfrb_arh-fin-doc-an.code-schet        and
                                      rbfrb_arh-fin-doc-an.fin-ext-doc-type  = bfrb_arh-fin-doc-an.fin-ext-doc-type  and
                                      rbfrb_arh-fin-doc-an.fin-code-an-uchet = bfrb_arh-fin-doc-an.fin-code-an-uchet and
                                      rbfrb_arh-fin-doc-an.fin-code-cel-nazn = bfrb_arh-fin-doc-an.fin-code-cel-nazn and
                                      rbfrb_arh-fin-doc-an.fin-code-cor-acc  = bfrb_arh-fin-doc-an.fin-code-cor-acc  and
                                      rbfrb_arh-fin-doc-an.calc-curr-code    = bfrb_arh-fin-doc-an.calc-curr-code    and
                                      rbfrb_arh-fin-doc-an.sum-type          = bfrb_arh-fin-doc-an.sum-type          and
                                      rbfrb_arh-fin-doc-an.fact-order        > bfrb_arh-fin-doc-an.fact-order        on error undo, return error return-value :
    assign
      rbfrb_arh-fin-doc-an.income      =  rbfrb_arh-fin-doc-an.income     + parsum-base
      rbfrb_arh-fin-doc-an.income-vat  =  rbfrb_arh-fin-doc-an.income-vat + parsum-vat-base
      rbfrb_arh-fin-doc-an.income-slt  =  rbfrb_arh-fin-doc-an.income-slt + parsum-slt-base
    .
  end.
  if parmode = "delete":u then do:
    delete bfpb_arh-fin-doc-an.
    delete bfrb_arh-fin-doc-an.
  end.
end.
if parrel-dog-code  =  yes          and
   parcurr-dog-code <> parcurr-code and
   parcurr-dog-code <> 0            and
   parcurr-dog-code <> parbase-code then do:
  if parmode = "close":u then do:
    find last bopc_arh-fin-doc-an where bopc_arh-fin-doc-an.host-code         = parhost-code         and
                                        bopc_arh-fin-doc-an.cli-type          = parpayer-type        and
                                        bopc_arh-fin-doc-an.cli-code          = parpayer-code        and
                                        bopc_arh-fin-doc-an.code-schet        = parpayer-code-schet  and
                                        bopc_arh-fin-doc-an.fin-ext-doc-type  = parfin-ext-doc-type  and
                                        bopc_arh-fin-doc-an.fin-code-an-uchet = parfin-code-an-uchet and
                                        bopc_arh-fin-doc-an.fin-code-cel-nazn = parfin-code-cel-nazn and
                                        bopc_arh-fin-doc-an.fin-code-cor-acc  = parfin-code-cor-acc  and
                                        bopc_arh-fin-doc-an.calc-curr-code    = parcurr-dog-code     and
                                        bopc_arh-fin-doc-an.sum-type          = parsum-type          and
                                        bopc_arh-fin-doc-an.fact-order        < parfact-order        use-index pi no-error.
    create bfpc_arh-fin-doc-an.
    assign
      bfpc_arh-fin-doc-an.host-code         = parhost-code
      bfpc_arh-fin-doc-an.cli-type          = parpayer-type
      bfpc_arh-fin-doc-an.cli-code          = parpayer-code
      bfpc_arh-fin-doc-an.code-schet        = parpayer-code-schet
      bfpc_arh-fin-doc-an.fin-ext-doc-type  = parfin-ext-doc-type
      bfpc_arh-fin-doc-an.fin-code-an-uchet = parfin-code-an-uchet
      bfpc_arh-fin-doc-an.fin-code-cel-nazn = parfin-code-cel-nazn
      bfpc_arh-fin-doc-an.fin-code-cor-acc  = parfin-code-cor-acc
      bfpc_arh-fin-doc-an.calc-curr-code    = parcurr-dog-code
      bfpc_arh-fin-doc-an.sum-type          = parsum-type
      bfpc_arh-fin-doc-an.cource-des        = "c":u
      bfpc_arh-fin-doc-an.fact-order        = parfact-order
      bfpc_arh-fin-doc-an.fin-doc-code      = parfin-doc-code
      bfpc_arh-fin-doc-an.fact-date         = parfact-date
      bfpc_arh-fin-doc-an.curr-code         = parcurr-code
      bfpc_arh-fin-doc-an.income            = (if available bopc_arh-fin-doc-an then bopc_arh-fin-doc-an.income      else 0)
      bfpc_arh-fin-doc-an.income-vat        = (if available bopc_arh-fin-doc-an then bopc_arh-fin-doc-an.income-vat  else 0)
      bfpc_arh-fin-doc-an.income-slt        = (if available bopc_arh-fin-doc-an then bopc_arh-fin-doc-an.income-slt  else 0)
      bfpc_arh-fin-doc-an.expense           = (if available bopc_arh-fin-doc-an then bopc_arh-fin-doc-an.expense     else 0) + parsum-contr
      bfpc_arh-fin-doc-an.expense-vat       = (if available bopc_arh-fin-doc-an then bopc_arh-fin-doc-an.expense-vat else 0) + parsum-vat-contr
      bfpc_arh-fin-doc-an.expense-slt       = (if available bopc_arh-fin-doc-an then bopc_arh-fin-doc-an.expense-slt else 0) + parsum-slt-contr
    .
  end.
  else do:
    find first bfpc_arh-fin-doc-an where bfpc_arh-fin-doc-an.host-code         = parhost-code         and
                                         bfpc_arh-fin-doc-an.cli-type          = parpayer-type        and
                                         bfpc_arh-fin-doc-an.cli-code          = parpayer-code        and
                                         bfpc_arh-fin-doc-an.code-schet        = parpayer-code-schet  and
                                         bfpc_arh-fin-doc-an.fin-ext-doc-type  = parfin-ext-doc-type  and
                                         bfpc_arh-fin-doc-an.fin-code-an-uchet = parfin-code-an-uchet and
                                         bfpc_arh-fin-doc-an.fin-code-cel-nazn = parfin-code-cel-nazn and
                                         bfpc_arh-fin-doc-an.fin-code-cor-acc  = parfin-code-cor-acc  and
                                         bfpc_arh-fin-doc-an.calc-curr-code    = parcurr-dog-code     and
                                         bfpc_arh-fin-doc-an.sum-type          = parsum-type          and
                                         bfpc_arh-fin-doc-an.fact-order        = parfact-order        exclusive-lock.
  end.
  for each rbfpc_arh-fin-doc-an where rbfpc_arh-fin-doc-an.host-code         = bfpc_arh-fin-doc-an.host-code         and
                                      rbfpc_arh-fin-doc-an.cli-type          = parpayer-type                         and
                                      rbfpc_arh-fin-doc-an.cli-code          = parpayer-code                         and
                                      rbfpc_arh-fin-doc-an.code-schet        = bfpc_arh-fin-doc-an.code-schet        and
                                      rbfpc_arh-fin-doc-an.fin-ext-doc-type  = bfpc_arh-fin-doc-an.fin-ext-doc-type  and
                                      rbfpc_arh-fin-doc-an.fin-code-an-uchet = bfpc_arh-fin-doc-an.fin-code-an-uchet and
                                      rbfpc_arh-fin-doc-an.fin-code-cel-nazn = bfpc_arh-fin-doc-an.fin-code-cel-nazn and
                                      rbfpc_arh-fin-doc-an.fin-code-cor-acc  = bfpc_arh-fin-doc-an.fin-code-cor-acc  and
                                      rbfpc_arh-fin-doc-an.calc-curr-code    = bfpc_arh-fin-doc-an.calc-curr-code    and
                                      rbfpc_arh-fin-doc-an.sum-type          = bfpc_arh-fin-doc-an.sum-type          and
                                      rbfpc_arh-fin-doc-an.fact-order        > bfpc_arh-fin-doc-an.fact-order        use-index pi on error undo, return error return-value :
    assign
      rbfpc_arh-fin-doc-an.expense     = rbfpc_arh-fin-doc-an.expense     + parsum-contr
      rbfpc_arh-fin-doc-an.expense-vat = rbfpc_arh-fin-doc-an.expense-vat + parsum-vat-contr
      rbfpc_arh-fin-doc-an.expense-slt = rbfpc_arh-fin-doc-an.expense-slt + parsum-slt-contr
    .
  end.
  if parmode = "close":u then do:
    find last borc_arh-fin-doc-an where borc_arh-fin-doc-an.host-code         = parhost-code            and
                                        borc_arh-fin-doc-an.cli-type          = parreceiver-type        and
                                        borc_arh-fin-doc-an.cli-code          = parreceiver-code        and
                                        borc_arh-fin-doc-an.code-schet        = parreceiver-code-schet  and
                                        borc_arh-fin-doc-an.fin-ext-doc-type  = parfin-ext-doc-type     and
                                        borc_arh-fin-doc-an.fin-code-an-uchet = parfin-code-an-uchet    and
                                        borc_arh-fin-doc-an.fin-code-cel-nazn = parfin-code-cel-nazn    and
                                        borc_arh-fin-doc-an.fin-code-cor-acc  = parfin-code-cor-acc     and
                                        borc_arh-fin-doc-an.calc-curr-code    = parcurr-dog-code        and
                                        borc_arh-fin-doc-an.sum-type          = parsum-type             and
                                        borc_arh-fin-doc-an.fact-order        < parfact-order           use-index pi no-error.
    create bfrc_arh-fin-doc-an.
    assign
      bfrc_arh-fin-doc-an.host-code         = parhost-code
      bfrc_arh-fin-doc-an.cli-type          = parreceiver-type
      bfrc_arh-fin-doc-an.cli-code          = parreceiver-code
      bfrc_arh-fin-doc-an.code-schet        = parreceiver-code-schet
      bfrc_arh-fin-doc-an.fin-ext-doc-type  = parfin-ext-doc-type
      bfrc_arh-fin-doc-an.fin-code-an-uchet = parfin-code-an-uchet
      bfrc_arh-fin-doc-an.fin-code-cel-nazn = parfin-code-cel-nazn
      bfrc_arh-fin-doc-an.fin-code-cor-acc  = parfin-code-cor-acc
      bfrc_arh-fin-doc-an.calc-curr-code    = parcurr-dog-code
      bfrc_arh-fin-doc-an.sum-type          = parsum-type
      bfrc_arh-fin-doc-an.cource-des        = "c":u
      bfrc_arh-fin-doc-an.fact-order        = parfact-order
      bfrc_arh-fin-doc-an.fin-doc-code      = parfin-doc-code
      bfrc_arh-fin-doc-an.fact-date         = parfact-date
      bfrc_arh-fin-doc-an.curr-code         = parcurr-code
    .
    assign
      bfrc_arh-fin-doc-an.expense           = (if available borc_arh-fin-doc-an then borc_arh-fin-doc-an.expense     else 0)
      bfrc_arh-fin-doc-an.expense-vat       = (if available borc_arh-fin-doc-an then borc_arh-fin-doc-an.expense-vat else 0)
      bfrc_arh-fin-doc-an.expense-slt       = (if available borc_arh-fin-doc-an then borc_arh-fin-doc-an.expense-slt else 0)
      bfrc_arh-fin-doc-an.income            = (if available borc_arh-fin-doc-an then borc_arh-fin-doc-an.income      else 0) + parsum-contr
      bfrc_arh-fin-doc-an.income-vat        = (if available borc_arh-fin-doc-an then borc_arh-fin-doc-an.income-vat  else 0) + parsum-vat-contr
      bfrc_arh-fin-doc-an.income-slt        = (if available borc_arh-fin-doc-an then borc_arh-fin-doc-an.income-slt  else 0) + parsum-slt-contr
    .
  end.
  else do:
    find first bfrc_arh-fin-doc-an where bfrc_arh-fin-doc-an.host-code         = parhost-code            and
                                         bfrc_arh-fin-doc-an.cli-type          = parreceiver-type        and
                                         bfrc_arh-fin-doc-an.cli-code          = parreceiver-code        and
                                         bfrc_arh-fin-doc-an.code-schet        = parreceiver-code-schet  and
                                         bfrc_arh-fin-doc-an.fin-ext-doc-type  = parfin-ext-doc-type     and
                                         bfrc_arh-fin-doc-an.fin-code-an-uchet = parfin-code-an-uchet    and
                                         bfrc_arh-fin-doc-an.fin-code-cel-nazn = parfin-code-cel-nazn    and
                                         bfrc_arh-fin-doc-an.fin-code-cor-acc  = parfin-code-cor-acc     and
                                         bfrc_arh-fin-doc-an.calc-curr-code    = parcurr-dog-code        and
                                         bfrc_arh-fin-doc-an.sum-type          = parsum-type             and
                                         bfrc_arh-fin-doc-an.fact-order        = parfact-order           exclusive-lock.
  end.
  for each rbfrc_arh-fin-doc-an where rbfrc_arh-fin-doc-an.host-code         = bfrc_arh-fin-doc-an.host-code         and
                                      rbfrc_arh-fin-doc-an.cli-type          = parreceiver-type                      and
                                      rbfrc_arh-fin-doc-an.cli-code          = parreceiver-code                      and
                                      rbfrc_arh-fin-doc-an.code-schet        = bfrc_arh-fin-doc-an.code-schet        and
                                      rbfrc_arh-fin-doc-an.fin-ext-doc-type  = bfrc_arh-fin-doc-an.fin-ext-doc-type  and
                                      rbfrc_arh-fin-doc-an.fin-code-an-uchet = bfrc_arh-fin-doc-an.fin-code-an-uchet and
                                      rbfrc_arh-fin-doc-an.fin-code-cel-nazn = bfrc_arh-fin-doc-an.fin-code-cel-nazn and
                                      rbfrc_arh-fin-doc-an.fin-code-cor-acc  = bfrc_arh-fin-doc-an.fin-code-cor-acc  and
                                      rbfrc_arh-fin-doc-an.calc-curr-code    = bfrc_arh-fin-doc-an.calc-curr-code    and
                                      rbfrc_arh-fin-doc-an.sum-type          = bfrc_arh-fin-doc-an.sum-type          and
                                      rbfrc_arh-fin-doc-an.fact-order        > bfrc_arh-fin-doc-an.fact-order        use-index pi exclusive-lock on error undo, return error return-value :
    assign
      rbfrc_arh-fin-doc-an.income     = rbfrc_arh-fin-doc-an.income     + parsum-contr
      rbfrc_arh-fin-doc-an.income-vat = rbfrc_arh-fin-doc-an.income-vat + parsum-vat-contr
      rbfrc_arh-fin-doc-an.income-slt = rbfrc_arh-fin-doc-an.income-slt + parsum-slt-contr
    .
  end.
  if parmode = "delete":u then do:
    delete bfpc_arh-fin-doc-an.
    delete bfrc_arh-fin-doc-an.
  end.
end.
end.
end procedure.

procedure libfarhp_calc-arh-fin-doc-contr-schet :
define input parameter parmode                    as   character                   no-undo.
define input parameter parhost-code               like ub.fin-doc.host-code        no-undo.
define input parameter parpayer-type              like ub.fin-doc.payer-type       no-undo.
define input parameter parpayer-code              like ub.fin-doc.payer-code       no-undo.
define input parameter parreceiver-type           like ub.fin-doc.receiver-type    no-undo.
define input parameter parreceiver-code           like ub.fin-doc.receiver-code    no-undo.
define input parameter parpayer-code-schet        like ub.fin-schet.code-schet     no-undo.
define input parameter parreceiver-code-schet     like ub.fin-schet.code-schet     no-undo.
define input parameter parfin-ext-doc-type        like ub.fin-doc.fin-ext-doc-type no-undo.
define input parameter parsum-type                as   character                   no-undo.
define input parameter parfact-order              like ub.fin-doc.fact-order       no-undo.
define input parameter parfin-doc-code            like ub.fin-doc.fin-doc-code     no-undo.
define input parameter parfact-date               like ub.fin-doc.fact-date        no-undo.
define input parameter parcurr-code               like ub.fin-doc.curr-code        no-undo.
define input parameter parbase-code               like ub.sysconf.base-code        no-undo.
define input parameter parcurr-dog-code           like ub.contract.curr-code       no-undo.
define input parameter parrel-dog-code            as   logical                     no-undo.
define input parameter parcontract-code           like ub.contract.contract-code   no-undo.
define input parameter parsum-doc                 as   decimal                     no-undo.
define input parameter parsum-rubl                as   decimal                     no-undo.
define input parameter parsum-base                as   decimal                     no-undo.
define input parameter parsum-contr               as   decimal                     no-undo.
define input parameter parsum-vat-doc             as   decimal                     no-undo.
define input parameter parsum-vat-rubl            as   decimal                     no-undo.
define input parameter parsum-vat-base            as   decimal                     no-undo.
define input parameter parsum-vat-contr           as   decimal                     no-undo.
define input parameter parsum-slt-doc             as   decimal                     no-undo.
define input parameter parsum-slt-rubl            as   decimal                     no-undo.
define input parameter parsum-slt-base            as   decimal                     no-undo.
define input parameter parsum-slt-contr           as   decimal                     no-undo.
define buffer bfps_arh-fin-doc-contr-schet  for ub.arh-fin-doc-contr-schet.
define buffer bfrs_arh-fin-doc-contr-schet  for ub.arh-fin-doc-contr-schet.
define buffer rbfps_arh-fin-doc-contr-schet for ub.arh-fin-doc-contr-schet.
define buffer rbfrs_arh-fin-doc-contr-schet for ub.arh-fin-doc-contr-schet.
define buffer bops_arh-fin-doc-contr-schet  for ub.arh-fin-doc-contr-schet.
define buffer bors_arh-fin-doc-contr-schet  for ub.arh-fin-doc-contr-schet.
define buffer bfpr_arh-fin-doc-contr-schet  for ub.arh-fin-doc-contr-schet.
define buffer bfrr_arh-fin-doc-contr-schet  for ub.arh-fin-doc-contr-schet.
define buffer rbfpr_arh-fin-doc-contr-schet for ub.arh-fin-doc-contr-schet.
define buffer rbfrr_arh-fin-doc-contr-schet for ub.arh-fin-doc-contr-schet.
define buffer bopr_arh-fin-doc-contr-schet  for ub.arh-fin-doc-contr-schet.
define buffer borr_arh-fin-doc-contr-schet  for ub.arh-fin-doc-contr-schet.
define buffer bfpb_arh-fin-doc-contr-schet  for ub.arh-fin-doc-contr-schet.
define buffer bfrb_arh-fin-doc-contr-schet  for ub.arh-fin-doc-contr-schet.
define buffer rbfpb_arh-fin-doc-contr-schet for ub.arh-fin-doc-contr-schet.
define buffer rbfrb_arh-fin-doc-contr-schet for ub.arh-fin-doc-contr-schet.
define buffer bopb_arh-fin-doc-contr-schet  for ub.arh-fin-doc-contr-schet.
define buffer borb_arh-fin-doc-contr-schet  for ub.arh-fin-doc-contr-schet.
define buffer bfpc_arh-fin-doc-contr-schet  for ub.arh-fin-doc-contr-schet.
define buffer bfrc_arh-fin-doc-contr-schet  for ub.arh-fin-doc-contr-schet.
define buffer rbfpc_arh-fin-doc-contr-schet for ub.arh-fin-doc-contr-schet.
define buffer rbfrc_arh-fin-doc-contr-schet for ub.arh-fin-doc-contr-schet.
define buffer bopc_arh-fin-doc-contr-schet  for ub.arh-fin-doc-contr-schet.
define buffer borc_arh-fin-doc-contr-schet  for ub.arh-fin-doc-contr-schet.
do on error undo, return error substitute ("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
if parmode = "close":u then do:
  find last bops_arh-fin-doc-contr-schet where bops_arh-fin-doc-contr-schet.host-code        = parhost-code         and
                                               bops_arh-fin-doc-contr-schet.contract-code    = parcontract-code     and
                                               bops_arh-fin-doc-contr-schet.cli-type         = parpayer-type        and
                                               bops_arh-fin-doc-contr-schet.cli-code         = parpayer-code        and
                                               bops_arh-fin-doc-contr-schet.code-schet       = parpayer-code-schet  and
                                               bops_arh-fin-doc-contr-schet.fin-ext-doc-type = parfin-ext-doc-type  and
                                               bops_arh-fin-doc-contr-schet.calc-curr-code   = parcurr-code         and
                                               bops_arh-fin-doc-contr-schet.sum-type         = parsum-type          and
                                               bops_arh-fin-doc-contr-schet.fact-order       < parfact-order        use-index pi no-error.
  create bfps_arh-fin-doc-contr-schet.
  assign
    bfps_arh-fin-doc-contr-schet.host-code        = parhost-code
    bfps_arh-fin-doc-contr-schet.contract-code    = parcontract-code
    bfps_arh-fin-doc-contr-schet.cli-type         = parpayer-type
    bfps_arh-fin-doc-contr-schet.cli-code         = parpayer-code
    bfps_arh-fin-doc-contr-schet.code-schet       = parpayer-code-schet
    bfps_arh-fin-doc-contr-schet.fin-ext-doc-type = parfin-ext-doc-type
    bfps_arh-fin-doc-contr-schet.calc-curr-code   = parcurr-code
    bfps_arh-fin-doc-contr-schet.sum-type         = parsum-type
    bfps_arh-fin-doc-contr-schet.cource-des       = "s":u
    bfps_arh-fin-doc-contr-schet.fact-order       = parfact-order
    bfps_arh-fin-doc-contr-schet.fin-doc-code     = parfin-doc-code
    bfps_arh-fin-doc-contr-schet.fact-date        = parfact-date
    bfps_arh-fin-doc-contr-schet.curr-code        = parcurr-code
    bfps_arh-fin-doc-contr-schet.income           = (if available bops_arh-fin-doc-contr-schet then bops_arh-fin-doc-contr-schet.income      else 0)
    bfps_arh-fin-doc-contr-schet.income-vat       = (if available bops_arh-fin-doc-contr-schet then bops_arh-fin-doc-contr-schet.income-vat  else 0)
    bfps_arh-fin-doc-contr-schet.income-slt       = (if available bops_arh-fin-doc-contr-schet then bops_arh-fin-doc-contr-schet.income-slt  else 0)
    bfps_arh-fin-doc-contr-schet.expense          = (if available bops_arh-fin-doc-contr-schet then bops_arh-fin-doc-contr-schet.expense     else 0) + parsum-doc
    bfps_arh-fin-doc-contr-schet.expense-vat      = (if available bops_arh-fin-doc-contr-schet then bops_arh-fin-doc-contr-schet.expense-vat else 0) + parsum-vat-doc
    bfps_arh-fin-doc-contr-schet.expense-slt      = (if available bops_arh-fin-doc-contr-schet then bops_arh-fin-doc-contr-schet.expense-slt else 0) + parsum-slt-doc
  .
end.
else do:
  find first bfps_arh-fin-doc-contr-schet where bfps_arh-fin-doc-contr-schet.host-code        = parhost-code         and
                                                bfps_arh-fin-doc-contr-schet.contract-code    = parcontract-code     and
                                                bfps_arh-fin-doc-contr-schet.cli-type         = parpayer-type        and
                                                bfps_arh-fin-doc-contr-schet.cli-code         = parpayer-code        and
                                                bfps_arh-fin-doc-contr-schet.code-schet       = parpayer-code-schet  and
                                                bfps_arh-fin-doc-contr-schet.fin-ext-doc-type = parfin-ext-doc-type  and
                                                bfps_arh-fin-doc-contr-schet.calc-curr-code   = parcurr-code         and
                                                bfps_arh-fin-doc-contr-schet.sum-type         = parsum-type          and
                                                bfps_arh-fin-doc-contr-schet.fact-order       = parfact-order        exclusive-lock.
end.
for each rbfps_arh-fin-doc-contr-schet where rbfps_arh-fin-doc-contr-schet.host-code        = bfps_arh-fin-doc-contr-schet.host-code        and
                                             rbfps_arh-fin-doc-contr-schet.contract-code    = bfps_arh-fin-doc-contr-schet.contract-code    and
                                             rbfps_arh-fin-doc-contr-schet.cli-type         = parpayer-type                                 and
                                             rbfps_arh-fin-doc-contr-schet.cli-code         = parpayer-code                                 and
                                             rbfps_arh-fin-doc-contr-schet.code-schet       = bfps_arh-fin-doc-contr-schet.code-schet       and
                                             rbfps_arh-fin-doc-contr-schet.fin-ext-doc-type = bfps_arh-fin-doc-contr-schet.fin-ext-doc-type and
                                             rbfps_arh-fin-doc-contr-schet.calc-curr-code   = bfps_arh-fin-doc-contr-schet.calc-curr-code   and
                                             rbfps_arh-fin-doc-contr-schet.sum-type         = bfps_arh-fin-doc-contr-schet.sum-type         and
                                             rbfps_arh-fin-doc-contr-schet.fact-order       > bfps_arh-fin-doc-contr-schet.fact-order       use-index pi exclusive-lock on error undo, return error return-value :
  assign
    rbfps_arh-fin-doc-contr-schet.expense     = rbfps_arh-fin-doc-contr-schet.expense     + parsum-doc
    rbfps_arh-fin-doc-contr-schet.expense-vat = rbfps_arh-fin-doc-contr-schet.expense-vat + parsum-vat-doc
    rbfps_arh-fin-doc-contr-schet.expense-slt = rbfps_arh-fin-doc-contr-schet.expense-slt + parsum-slt-doc
  .
end.
if parmode = "close":u then do:
  find last bors_arh-fin-doc-contr-schet where bors_arh-fin-doc-contr-schet.host-code        = parhost-code            and
                                               bors_arh-fin-doc-contr-schet.contract-code    = parcontract-code        and
                                               bors_arh-fin-doc-contr-schet.cli-type         = parreceiver-type        and
                                               bors_arh-fin-doc-contr-schet.cli-code         = parreceiver-code        and
                                               bors_arh-fin-doc-contr-schet.code-schet       = parreceiver-code-schet  and
                                               bors_arh-fin-doc-contr-schet.fin-ext-doc-type = parfin-ext-doc-type     and
                                               bors_arh-fin-doc-contr-schet.calc-curr-code   = parcurr-code            and
                                               bors_arh-fin-doc-contr-schet.sum-type         = parsum-type             and
                                               bors_arh-fin-doc-contr-schet.fact-order       < parfact-order           use-index pi no-error.
  create bfrs_arh-fin-doc-contr-schet.
  assign
    bfrs_arh-fin-doc-contr-schet.host-code        = parhost-code
    bfrs_arh-fin-doc-contr-schet.contract-code    = parcontract-code
    bfrs_arh-fin-doc-contr-schet.cli-type         = parreceiver-type
    bfrs_arh-fin-doc-contr-schet.cli-code         = parreceiver-code
    bfrs_arh-fin-doc-contr-schet.code-schet       = parreceiver-code-schet
    bfrs_arh-fin-doc-contr-schet.fin-ext-doc-type = parfin-ext-doc-type
    bfrs_arh-fin-doc-contr-schet.calc-curr-code   = parcurr-code
    bfrs_arh-fin-doc-contr-schet.sum-type         = parsum-type
    bfrs_arh-fin-doc-contr-schet.cource-des       = "s":u
    bfrs_arh-fin-doc-contr-schet.fact-order       = parfact-order
    bfrs_arh-fin-doc-contr-schet.fin-doc-code     = parfin-doc-code
    bfrs_arh-fin-doc-contr-schet.fact-date        = parfact-date
    bfrs_arh-fin-doc-contr-schet.curr-code        = parcurr-code
  .
  assign
    bfrs_arh-fin-doc-contr-schet.expense          = (if available bors_arh-fin-doc-contr-schet then bors_arh-fin-doc-contr-schet.expense     else 0)
    bfrs_arh-fin-doc-contr-schet.expense-vat      = (if available bors_arh-fin-doc-contr-schet then bors_arh-fin-doc-contr-schet.expense-vat else 0)
    bfrs_arh-fin-doc-contr-schet.expense-slt      = (if available bors_arh-fin-doc-contr-schet then bors_arh-fin-doc-contr-schet.expense-slt else 0)
    bfrs_arh-fin-doc-contr-schet.income           = (if available bors_arh-fin-doc-contr-schet then bors_arh-fin-doc-contr-schet.income      else 0) + parsum-doc
    bfrs_arh-fin-doc-contr-schet.income-vat       = (if available bors_arh-fin-doc-contr-schet then bors_arh-fin-doc-contr-schet.income-vat  else 0) + parsum-vat-doc
    bfrs_arh-fin-doc-contr-schet.income-slt       = (if available bors_arh-fin-doc-contr-schet then bors_arh-fin-doc-contr-schet.income-slt  else 0) + parsum-slt-doc
  .
end.
else do:
  find first bfrs_arh-fin-doc-contr-schet where bfrs_arh-fin-doc-contr-schet.host-code        = parhost-code            and
                                                bfrs_arh-fin-doc-contr-schet.contract-code    = parcontract-code        and
                                                bfrs_arh-fin-doc-contr-schet.cli-type         = parreceiver-type        and
                                                bfrs_arh-fin-doc-contr-schet.cli-code         = parreceiver-code        and
                                                bfrs_arh-fin-doc-contr-schet.code-schet       = parreceiver-code-schet  and
                                                bfrs_arh-fin-doc-contr-schet.fin-ext-doc-type = parfin-ext-doc-type     and
                                                bfrs_arh-fin-doc-contr-schet.calc-curr-code   = parcurr-code            and
                                                bfrs_arh-fin-doc-contr-schet.sum-type         = parsum-type             and
                                                bfrs_arh-fin-doc-contr-schet.fact-order       = parfact-order           exclusive-lock.
end.
for each rbfrs_arh-fin-doc-contr-schet where rbfrs_arh-fin-doc-contr-schet.host-code        = bfrs_arh-fin-doc-contr-schet.host-code        and
                                             rbfrs_arh-fin-doc-contr-schet.contract-code    = bfrs_arh-fin-doc-contr-schet.contract-code    and
                                             rbfrs_arh-fin-doc-contr-schet.cli-type         = parreceiver-type                              and
                                             rbfrs_arh-fin-doc-contr-schet.cli-code         = parreceiver-code                              and
                                             rbfrs_arh-fin-doc-contr-schet.code-schet       = bfrs_arh-fin-doc-contr-schet.code-schet       and
                                             rbfrs_arh-fin-doc-contr-schet.fin-ext-doc-type = bfrs_arh-fin-doc-contr-schet.fin-ext-doc-type and
                                             rbfrs_arh-fin-doc-contr-schet.calc-curr-code   = bfrs_arh-fin-doc-contr-schet.calc-curr-code   and
                                             rbfrs_arh-fin-doc-contr-schet.sum-type         = bfrs_arh-fin-doc-contr-schet.sum-type         and
                                             rbfrs_arh-fin-doc-contr-schet.fact-order       > bfrs_arh-fin-doc-contr-schet.fact-order       use-index pi exclusive-lock on error undo, return error return-value :
  assign
    rbfrs_arh-fin-doc-contr-schet.income     = rbfrs_arh-fin-doc-contr-schet.income     + parsum-doc
    rbfrs_arh-fin-doc-contr-schet.income-vat = rbfrs_arh-fin-doc-contr-schet.income-vat + parsum-vat-doc
    rbfrs_arh-fin-doc-contr-schet.income-slt = rbfrs_arh-fin-doc-contr-schet.income-slt + parsum-slt-doc
  .
end.
if parmode = "delete":u then do:
  delete bfps_arh-fin-doc-contr-schet.
  delete bfrs_arh-fin-doc-contr-schet.
end.
if parcurr-code <> 0 then do:
  if parmode = "close":u then do:
    find last bopr_arh-fin-doc-contr-schet where bopr_arh-fin-doc-contr-schet.host-code        = parhost-code         and
                                                 bopr_arh-fin-doc-contr-schet.contract-code    = parcontract-code     and
                                                 bopr_arh-fin-doc-contr-schet.cli-type         = parpayer-type        and
                                                 bopr_arh-fin-doc-contr-schet.cli-code         = parpayer-code        and
                                                 bopr_arh-fin-doc-contr-schet.code-schet       = parpayer-code-schet  and
                                                 bopr_arh-fin-doc-contr-schet.fin-ext-doc-type = parfin-ext-doc-type  and
                                                 bopr_arh-fin-doc-contr-schet.calc-curr-code   = 0                    and
                                                 bopr_arh-fin-doc-contr-schet.sum-type         = parsum-type          and
                                                 bopr_arh-fin-doc-contr-schet.fact-order       < parfact-order        use-index pi no-error.
    create bfpr_arh-fin-doc-contr-schet.
    assign
      bfpr_arh-fin-doc-contr-schet.host-code        = parhost-code
      bfpr_arh-fin-doc-contr-schet.contract-code    = parcontract-code
      bfpr_arh-fin-doc-contr-schet.cli-type         = parpayer-type
      bfpr_arh-fin-doc-contr-schet.cli-code         = parpayer-code
      bfpr_arh-fin-doc-contr-schet.code-schet       = parpayer-code-schet
      bfpr_arh-fin-doc-contr-schet.fin-ext-doc-type = parfin-ext-doc-type
      bfpr_arh-fin-doc-contr-schet.calc-curr-code   = 0
      bfpr_arh-fin-doc-contr-schet.sum-type         = parsum-type
      bfpr_arh-fin-doc-contr-schet.cource-des       = "r":u
      bfpr_arh-fin-doc-contr-schet.fact-order       = parfact-order
      bfpr_arh-fin-doc-contr-schet.fin-doc-code     = parfin-doc-code
      bfpr_arh-fin-doc-contr-schet.fact-date        = parfact-date
      bfpr_arh-fin-doc-contr-schet.curr-code        = parcurr-code
      bfpr_arh-fin-doc-contr-schet.income           = (if available bopr_arh-fin-doc-contr-schet then bopr_arh-fin-doc-contr-schet.income      else 0)
      bfpr_arh-fin-doc-contr-schet.income-vat       = (if available bopr_arh-fin-doc-contr-schet then bopr_arh-fin-doc-contr-schet.income-vat  else 0)
      bfpr_arh-fin-doc-contr-schet.income-slt       = (if available bopr_arh-fin-doc-contr-schet then bopr_arh-fin-doc-contr-schet.income-slt  else 0)
      bfpr_arh-fin-doc-contr-schet.expense          = (if available bopr_arh-fin-doc-contr-schet then bopr_arh-fin-doc-contr-schet.expense     else 0) + parsum-rubl
      bfpr_arh-fin-doc-contr-schet.expense-vat      = (if available bopr_arh-fin-doc-contr-schet then bopr_arh-fin-doc-contr-schet.expense-vat else 0) + parsum-vat-rubl
      bfpr_arh-fin-doc-contr-schet.expense-slt      = (if available bopr_arh-fin-doc-contr-schet then bopr_arh-fin-doc-contr-schet.expense-slt else 0) + parsum-slt-rubl
    .
  end.
  else do:
    find first bfpr_arh-fin-doc-contr-schet where bfpr_arh-fin-doc-contr-schet.host-code        = parhost-code         and
                                                  bfpr_arh-fin-doc-contr-schet.contract-code    = parcontract-code     and
                                                  bfpr_arh-fin-doc-contr-schet.cli-type         = parpayer-type        and
                                                  bfpr_arh-fin-doc-contr-schet.cli-code         = parpayer-code        and
                                                  bfpr_arh-fin-doc-contr-schet.code-schet       = parpayer-code-schet  and
                                                  bfpr_arh-fin-doc-contr-schet.fin-ext-doc-type = parfin-ext-doc-type  and
                                                  bfpr_arh-fin-doc-contr-schet.calc-curr-code   = 0                    and
                                                  bfpr_arh-fin-doc-contr-schet.sum-type         = parsum-type          and
                                                  bfpr_arh-fin-doc-contr-schet.fact-order       = parfact-order        exclusive-lock.
  end.
  for each rbfpr_arh-fin-doc-contr-schet where rbfpr_arh-fin-doc-contr-schet.host-code        = bfpr_arh-fin-doc-contr-schet.host-code        and
                                               rbfpr_arh-fin-doc-contr-schet.contract-code    = bfpr_arh-fin-doc-contr-schet.contract-code    and
                                               rbfpr_arh-fin-doc-contr-schet.cli-type         = parpayer-type                                 and
                                               rbfpr_arh-fin-doc-contr-schet.cli-code         = parpayer-code                                 and
                                               rbfpr_arh-fin-doc-contr-schet.code-schet       = bfpr_arh-fin-doc-contr-schet.code-schet       and
                                               rbfpr_arh-fin-doc-contr-schet.fin-ext-doc-type = bfpr_arh-fin-doc-contr-schet.fin-ext-doc-type and
                                               rbfpr_arh-fin-doc-contr-schet.calc-curr-code   = bfpr_arh-fin-doc-contr-schet.calc-curr-code   and
                                               rbfpr_arh-fin-doc-contr-schet.sum-type         = bfpr_arh-fin-doc-contr-schet.sum-type         and
                                               rbfpr_arh-fin-doc-contr-schet.fact-order       > bfpr_arh-fin-doc-contr-schet.fact-order       use-index pi exclusive-lock on error undo, return error return-value :
    assign
      rbfpr_arh-fin-doc-contr-schet.expense     = rbfpr_arh-fin-doc-contr-schet.expense     + parsum-rubl
      rbfpr_arh-fin-doc-contr-schet.expense-vat = rbfpr_arh-fin-doc-contr-schet.expense-vat + parsum-vat-rubl
      rbfpr_arh-fin-doc-contr-schet.expense-slt = rbfpr_arh-fin-doc-contr-schet.expense-slt + parsum-slt-rubl
    .
  end.
  if parmode = "close":u then do:
    find last borr_arh-fin-doc-contr-schet where borr_arh-fin-doc-contr-schet.host-code        = parhost-code            and
                                                 borr_arh-fin-doc-contr-schet.contract-code    = parcontract-code        and
                                                 borr_arh-fin-doc-contr-schet.cli-type         = parreceiver-type        and
                                                 borr_arh-fin-doc-contr-schet.cli-code         = parreceiver-code        and
                                                 borr_arh-fin-doc-contr-schet.code-schet       = parreceiver-code-schet  and
                                                 borr_arh-fin-doc-contr-schet.fin-ext-doc-type = parfin-ext-doc-type     and
                                                 borr_arh-fin-doc-contr-schet.calc-curr-code   = 0                       and
                                                 borr_arh-fin-doc-contr-schet.sum-type         = parsum-type             and
                                                 borr_arh-fin-doc-contr-schet.fact-order       < parfact-order           use-index pi no-error.
    create bfrr_arh-fin-doc-contr-schet.
    assign
      bfrr_arh-fin-doc-contr-schet.host-code        = parhost-code
      bfrr_arh-fin-doc-contr-schet.contract-code    = parcontract-code
      bfrr_arh-fin-doc-contr-schet.cli-type         = parreceiver-type
      bfrr_arh-fin-doc-contr-schet.cli-code         = parreceiver-code
      bfrr_arh-fin-doc-contr-schet.code-schet       = parreceiver-code-schet
      bfrr_arh-fin-doc-contr-schet.fin-ext-doc-type = parfin-ext-doc-type
      bfrr_arh-fin-doc-contr-schet.calc-curr-code   = 0
      bfrr_arh-fin-doc-contr-schet.sum-type         = parsum-type
      bfrr_arh-fin-doc-contr-schet.cource-des       = "r":u
      bfrr_arh-fin-doc-contr-schet.fact-order       = parfact-order
      bfrr_arh-fin-doc-contr-schet.fin-doc-code     = parfin-doc-code
      bfrr_arh-fin-doc-contr-schet.fact-date        = parfact-date
      bfrr_arh-fin-doc-contr-schet.curr-code        = parcurr-code
      .
    assign
      bfrr_arh-fin-doc-contr-schet.expense          = (if available borr_arh-fin-doc-contr-schet then borr_arh-fin-doc-contr-schet.expense     else 0)
      bfrr_arh-fin-doc-contr-schet.expense-vat      = (if available borr_arh-fin-doc-contr-schet then borr_arh-fin-doc-contr-schet.expense-vat else 0)
      bfrr_arh-fin-doc-contr-schet.expense-slt      = (if available borr_arh-fin-doc-contr-schet then borr_arh-fin-doc-contr-schet.expense-slt else 0)
      bfrr_arh-fin-doc-contr-schet.income           = (if available borr_arh-fin-doc-contr-schet then borr_arh-fin-doc-contr-schet.income      else 0) + parsum-rubl
      bfrr_arh-fin-doc-contr-schet.income-vat       = (if available borr_arh-fin-doc-contr-schet then borr_arh-fin-doc-contr-schet.income-vat  else 0) + parsum-vat-rubl
      bfrr_arh-fin-doc-contr-schet.income-slt       = (if available borr_arh-fin-doc-contr-schet then borr_arh-fin-doc-contr-schet.income-slt  else 0) + parsum-slt-rubl
    .
  end.
  else do:
    find first bfrr_arh-fin-doc-contr-schet where bfrr_arh-fin-doc-contr-schet.host-code        = parhost-code            and
                                                  bfrr_arh-fin-doc-contr-schet.contract-code    = parcontract-code        and
                                                  bfrr_arh-fin-doc-contr-schet.cli-type         = parreceiver-type        and
                                                  bfrr_arh-fin-doc-contr-schet.cli-code         = parreceiver-code        and
                                                  bfrr_arh-fin-doc-contr-schet.code-schet       = parreceiver-code-schet  and
                                                  bfrr_arh-fin-doc-contr-schet.fin-ext-doc-type = parfin-ext-doc-type     and
                                                  bfrr_arh-fin-doc-contr-schet.calc-curr-code   = 0                       and
                                                  bfrr_arh-fin-doc-contr-schet.sum-type         = parsum-type             and
                                                  bfrr_arh-fin-doc-contr-schet.fact-order       = parfact-order           exclusive-lock.
  end.
  for each rbfrr_arh-fin-doc-contr-schet where rbfrr_arh-fin-doc-contr-schet.host-code        = bfrr_arh-fin-doc-contr-schet.host-code        and
                                               rbfrr_arh-fin-doc-contr-schet.contract-code    = bfrr_arh-fin-doc-contr-schet.contract-code    and
                                               rbfrr_arh-fin-doc-contr-schet.cli-type         = parreceiver-type                              and
                                               rbfrr_arh-fin-doc-contr-schet.cli-code         = parreceiver-code                              and
                                               rbfrr_arh-fin-doc-contr-schet.code-schet       = bfrr_arh-fin-doc-contr-schet.code-schet       and
                                               rbfrr_arh-fin-doc-contr-schet.fin-ext-doc-type = bfrr_arh-fin-doc-contr-schet.fin-ext-doc-type and
                                               rbfrr_arh-fin-doc-contr-schet.calc-curr-code   = bfrr_arh-fin-doc-contr-schet.calc-curr-code   and
                                               rbfrr_arh-fin-doc-contr-schet.sum-type         = bfrr_arh-fin-doc-contr-schet.sum-type         and
                                               rbfrr_arh-fin-doc-contr-schet.fact-order       > bfrr_arh-fin-doc-contr-schet.fact-order       use-index pi exclusive-lock on error undo, return error return-value :
    assign
      rbfrr_arh-fin-doc-contr-schet.income     = rbfrr_arh-fin-doc-contr-schet.income     + parsum-rubl
      rbfrr_arh-fin-doc-contr-schet.income-vat = rbfrr_arh-fin-doc-contr-schet.income-vat + parsum-vat-rubl
      rbfrr_arh-fin-doc-contr-schet.income-slt = rbfrr_arh-fin-doc-contr-schet.income-slt + parsum-slt-rubl
    .
  end.
  if parmode = "delete":u then do:
    delete bfpr_arh-fin-doc-contr-schet.
    delete bfrr_arh-fin-doc-contr-schet.
  end.
end.
if parbase-code <> parcurr-code and
   parbase-code <> 0            then do:
  if parmode = "close":u then do:
    find last bopb_arh-fin-doc-contr-schet where bopb_arh-fin-doc-contr-schet.host-code        = parhost-code         and
                                                 bopb_arh-fin-doc-contr-schet.contract-code    = parcontract-code     and
                                                 bopb_arh-fin-doc-contr-schet.cli-type         = parpayer-type        and
                                                 bopb_arh-fin-doc-contr-schet.cli-code         = parpayer-code        and
                                                 bopb_arh-fin-doc-contr-schet.code-schet       = parpayer-code-schet  and
                                                 bopb_arh-fin-doc-contr-schet.fin-ext-doc-type = parfin-ext-doc-type  and
                                                 bopb_arh-fin-doc-contr-schet.calc-curr-code   = parbase-code         and
                                                 bopb_arh-fin-doc-contr-schet.sum-type         = parsum-type          and
                                                 bopb_arh-fin-doc-contr-schet.fact-order       < parfact-order        use-index pi no-error.
    create bfpb_arh-fin-doc-contr-schet.
    assign
      bfpb_arh-fin-doc-contr-schet.host-code        = parhost-code
      bfpb_arh-fin-doc-contr-schet.contract-code    = parcontract-code
      bfpb_arh-fin-doc-contr-schet.cli-type         = parpayer-type
      bfpb_arh-fin-doc-contr-schet.cli-code         = parpayer-code
      bfpb_arh-fin-doc-contr-schet.code-schet       = parpayer-code-schet
      bfpb_arh-fin-doc-contr-schet.fin-ext-doc-type = parfin-ext-doc-type
      bfpb_arh-fin-doc-contr-schet.calc-curr-code   = parbase-code
      bfpb_arh-fin-doc-contr-schet.sum-type         = parsum-type
      bfpb_arh-fin-doc-contr-schet.cource-des       = "b":u
      bfpb_arh-fin-doc-contr-schet.fact-order       = parfact-order
      bfpb_arh-fin-doc-contr-schet.fin-doc-code     = parfin-doc-code
      bfpb_arh-fin-doc-contr-schet.fact-date        = parfact-date
      bfpb_arh-fin-doc-contr-schet.curr-code        = parcurr-code
      bfpb_arh-fin-doc-contr-schet.income           = (if available bopb_arh-fin-doc-contr-schet then bopb_arh-fin-doc-contr-schet.income      else 0)
      bfpb_arh-fin-doc-contr-schet.income-vat       = (if available bopb_arh-fin-doc-contr-schet then bopb_arh-fin-doc-contr-schet.income-vat  else 0)
      bfpb_arh-fin-doc-contr-schet.income-slt       = (if available bopb_arh-fin-doc-contr-schet then bopb_arh-fin-doc-contr-schet.income-slt  else 0)
      bfpb_arh-fin-doc-contr-schet.expense          = (if available bopb_arh-fin-doc-contr-schet then bopb_arh-fin-doc-contr-schet.expense     else 0) + parsum-base
      bfpb_arh-fin-doc-contr-schet.expense-vat      = (if available bopb_arh-fin-doc-contr-schet then bopb_arh-fin-doc-contr-schet.expense-vat else 0) + parsum-vat-base
      bfpb_arh-fin-doc-contr-schet.expense-slt      = (if available bopb_arh-fin-doc-contr-schet then bopb_arh-fin-doc-contr-schet.expense-slt else 0) + parsum-slt-base
    .
  end.
  else do:
    find first bfpb_arh-fin-doc-contr-schet where bfpb_arh-fin-doc-contr-schet.host-code        = parhost-code         and
                                                  bfpb_arh-fin-doc-contr-schet.contract-code    = parcontract-code     and
                                                  bfpb_arh-fin-doc-contr-schet.cli-type         = parpayer-type        and
                                                  bfpb_arh-fin-doc-contr-schet.cli-code         = parpayer-code        and
                                                  bfpb_arh-fin-doc-contr-schet.code-schet       = parpayer-code-schet  and
                                                  bfpb_arh-fin-doc-contr-schet.fin-ext-doc-type = parfin-ext-doc-type  and
                                                  bfpb_arh-fin-doc-contr-schet.calc-curr-code   = parbase-code         and
                                                  bfpb_arh-fin-doc-contr-schet.sum-type         = parsum-type          and
                                                  bfpb_arh-fin-doc-contr-schet.fact-order       = parfact-order        exclusive-lock.
  end.
  for each rbfpb_arh-fin-doc-contr-schet where rbfpb_arh-fin-doc-contr-schet.host-code        = bfpb_arh-fin-doc-contr-schet.host-code        and
                                               rbfpb_arh-fin-doc-contr-schet.contract-code    = bfpb_arh-fin-doc-contr-schet.contract-code    and
                                               rbfpb_arh-fin-doc-contr-schet.cli-type         = parpayer-type                                 and
                                               rbfpb_arh-fin-doc-contr-schet.cli-code         = parpayer-code                                 and
                                               rbfpb_arh-fin-doc-contr-schet.code-schet       = bfpb_arh-fin-doc-contr-schet.code-schet       and
                                               rbfpb_arh-fin-doc-contr-schet.fin-ext-doc-type = bfpb_arh-fin-doc-contr-schet.fin-ext-doc-type and
                                               rbfpb_arh-fin-doc-contr-schet.calc-curr-code   = bfpb_arh-fin-doc-contr-schet.calc-curr-code   and
                                               rbfpb_arh-fin-doc-contr-schet.sum-type         = bfpb_arh-fin-doc-contr-schet.sum-type         and
                                               rbfpb_arh-fin-doc-contr-schet.fact-order       > bfpb_arh-fin-doc-contr-schet.fact-order       use-index pi exclusive-lock on error undo, return error return-value :
    assign
      rbfpb_arh-fin-doc-contr-schet.expense     = rbfpb_arh-fin-doc-contr-schet.expense     + parsum-base
      rbfpb_arh-fin-doc-contr-schet.expense-vat = rbfpb_arh-fin-doc-contr-schet.expense-vat + parsum-vat-base
      rbfpb_arh-fin-doc-contr-schet.expense-slt = rbfpb_arh-fin-doc-contr-schet.expense-slt + parsum-slt-base
    .
  end.
  if parmode = "close":u then do:
    find last borb_arh-fin-doc-contr-schet where borb_arh-fin-doc-contr-schet.host-code        = parhost-code            and
                                                 borb_arh-fin-doc-contr-schet.contract-code    = parcontract-code        and
                                                 borb_arh-fin-doc-contr-schet.cli-type         = parreceiver-type        and
                                                 borb_arh-fin-doc-contr-schet.cli-code         = parreceiver-code        and
                                                 borb_arh-fin-doc-contr-schet.code-schet       = parreceiver-code-schet  and
                                                 borb_arh-fin-doc-contr-schet.fin-ext-doc-type = parfin-ext-doc-type     and
                                                 borb_arh-fin-doc-contr-schet.calc-curr-code   = parbase-code            and
                                                 borb_arh-fin-doc-contr-schet.sum-type         = parsum-type             and
                                                 borb_arh-fin-doc-contr-schet.fact-order       < parfact-order           use-index pi no-error.
    create bfrb_arh-fin-doc-contr-schet.
    assign
      bfrb_arh-fin-doc-contr-schet.host-code        = parhost-code
      bfrb_arh-fin-doc-contr-schet.contract-code    = parcontract-code
      bfrb_arh-fin-doc-contr-schet.cli-type         = parreceiver-type
      bfrb_arh-fin-doc-contr-schet.cli-code         = parreceiver-code
      bfrb_arh-fin-doc-contr-schet.code-schet       = parreceiver-code-schet
      bfrb_arh-fin-doc-contr-schet.fin-ext-doc-type = parfin-ext-doc-type
      bfrb_arh-fin-doc-contr-schet.calc-curr-code   = parbase-code
      bfrb_arh-fin-doc-contr-schet.sum-type         = parsum-type
      bfrb_arh-fin-doc-contr-schet.cource-des       = "b":u
      bfrb_arh-fin-doc-contr-schet.fact-order       = parfact-order
      bfrb_arh-fin-doc-contr-schet.fin-doc-code     = parfin-doc-code
      bfrb_arh-fin-doc-contr-schet.fact-date        = parfact-date
      bfrb_arh-fin-doc-contr-schet.curr-code        = parcurr-code
    .
    assign
      bfrb_arh-fin-doc-contr-schet.expense          = (if available borb_arh-fin-doc-contr-schet then borb_arh-fin-doc-contr-schet.expense     else 0)
      bfrb_arh-fin-doc-contr-schet.expense-vat      = (if available borb_arh-fin-doc-contr-schet then borb_arh-fin-doc-contr-schet.expense-vat else 0)
      bfrb_arh-fin-doc-contr-schet.expense-slt      = (if available borb_arh-fin-doc-contr-schet then borb_arh-fin-doc-contr-schet.expense-slt else 0)
      bfrb_arh-fin-doc-contr-schet.income           = (if available borb_arh-fin-doc-contr-schet then borb_arh-fin-doc-contr-schet.income      else 0) + parsum-base
      bfrb_arh-fin-doc-contr-schet.income-vat       = (if available borb_arh-fin-doc-contr-schet then borb_arh-fin-doc-contr-schet.income-vat  else 0) + parsum-vat-base
      bfrb_arh-fin-doc-contr-schet.income-slt       = (if available borb_arh-fin-doc-contr-schet then borb_arh-fin-doc-contr-schet.income-slt  else 0) + parsum-slt-base
    .
  end.
  else do:
    find first bfrb_arh-fin-doc-contr-schet where bfrb_arh-fin-doc-contr-schet.host-code        = parhost-code            and
                                                  bfrb_arh-fin-doc-contr-schet.contract-code    = parcontract-code        and
                                                  bfrb_arh-fin-doc-contr-schet.cli-type         = parreceiver-type        and
                                                  bfrb_arh-fin-doc-contr-schet.cli-code         = parreceiver-code        and
                                                  bfrb_arh-fin-doc-contr-schet.code-schet       = parreceiver-code-schet  and
                                                  bfrb_arh-fin-doc-contr-schet.fin-ext-doc-type = parfin-ext-doc-type     and
                                                  bfrb_arh-fin-doc-contr-schet.calc-curr-code   = parbase-code            and
                                                  bfrb_arh-fin-doc-contr-schet.sum-type         = parsum-type             and
                                                  bfrb_arh-fin-doc-contr-schet.fact-order       = parfact-order           exclusive-lock.
  end.
  for each rbfrb_arh-fin-doc-contr-schet where rbfrb_arh-fin-doc-contr-schet.host-code        = bfrb_arh-fin-doc-contr-schet.host-code        and
                                               rbfrb_arh-fin-doc-contr-schet.contract-code    = bfrb_arh-fin-doc-contr-schet.contract-code    and
                                               rbfrb_arh-fin-doc-contr-schet.cli-type         = parreceiver-type                              and
                                               rbfrb_arh-fin-doc-contr-schet.cli-code         = parreceiver-code                              and
                                               rbfrb_arh-fin-doc-contr-schet.code-schet       = bfrb_arh-fin-doc-contr-schet.code-schet       and
                                               rbfrb_arh-fin-doc-contr-schet.fin-ext-doc-type = bfrb_arh-fin-doc-contr-schet.fin-ext-doc-type and
                                               rbfrb_arh-fin-doc-contr-schet.calc-curr-code   = bfrb_arh-fin-doc-contr-schet.calc-curr-code   and
                                               rbfrb_arh-fin-doc-contr-schet.sum-type         = bfrb_arh-fin-doc-contr-schet.sum-type         and
                                               rbfrb_arh-fin-doc-contr-schet.fact-order       > bfrb_arh-fin-doc-contr-schet.fact-order       use-index pi exclusive-lock on error undo, return error return-value :
    assign
      rbfrb_arh-fin-doc-contr-schet.income     = rbfrb_arh-fin-doc-contr-schet.income     + parsum-base
      rbfrb_arh-fin-doc-contr-schet.income-vat = rbfrb_arh-fin-doc-contr-schet.income-vat + parsum-vat-base
      rbfrb_arh-fin-doc-contr-schet.income-slt = rbfrb_arh-fin-doc-contr-schet.income-slt + parsum-slt-base
    .
  end.
  if parmode = "delete":u then do:
    delete bfpb_arh-fin-doc-contr-schet.
    delete bfrb_arh-fin-doc-contr-schet.
  end.
end.
if parrel-dog-code  =  yes          and
   parcurr-dog-code <> parcurr-code and
   parcurr-dog-code <> 0            and
   parcurr-dog-code <> parbase-code then do:
  if parmode = "close":u then do:
    find last bopc_arh-fin-doc-contr-schet where bopc_arh-fin-doc-contr-schet.host-code        = parhost-code         and
                                                 bopc_arh-fin-doc-contr-schet.contract-code    = parcontract-code     and
                                                 bopc_arh-fin-doc-contr-schet.cli-type         = parpayer-type        and
                                                 bopc_arh-fin-doc-contr-schet.cli-code         = parpayer-code        and
                                                 bopc_arh-fin-doc-contr-schet.code-schet       = parpayer-code-schet  and
                                                 bopc_arh-fin-doc-contr-schet.fin-ext-doc-type = parfin-ext-doc-type  and
                                                 bopc_arh-fin-doc-contr-schet.calc-curr-code   = parcurr-dog-code     and
                                                 bopc_arh-fin-doc-contr-schet.sum-type         = parsum-type          and
                                                 bopc_arh-fin-doc-contr-schet.fact-order       < parfact-order        use-index pi no-error.
    create bfpc_arh-fin-doc-contr-schet.
    assign
      bfpc_arh-fin-doc-contr-schet.host-code        = parhost-code
      bfpc_arh-fin-doc-contr-schet.contract-code    = parcontract-code
      bfpc_arh-fin-doc-contr-schet.cli-type         = parpayer-type
      bfpc_arh-fin-doc-contr-schet.cli-code         = parpayer-code
      bfpc_arh-fin-doc-contr-schet.code-schet       = parpayer-code-schet
      bfpc_arh-fin-doc-contr-schet.fin-ext-doc-type = parfin-ext-doc-type
      bfpc_arh-fin-doc-contr-schet.calc-curr-code   = parcurr-dog-code
      bfpc_arh-fin-doc-contr-schet.sum-type         = parsum-type
      bfpc_arh-fin-doc-contr-schet.cource-des       = "c":u
      bfpc_arh-fin-doc-contr-schet.fact-order       = parfact-order
      bfpc_arh-fin-doc-contr-schet.fin-doc-code     = parfin-doc-code
      bfpc_arh-fin-doc-contr-schet.fact-date        = parfact-date
      bfpc_arh-fin-doc-contr-schet.curr-code        = parcurr-code
      bfpc_arh-fin-doc-contr-schet.income           = (if available bopc_arh-fin-doc-contr-schet then bopc_arh-fin-doc-contr-schet.income      else 0)
      bfpc_arh-fin-doc-contr-schet.income-vat       = (if available bopc_arh-fin-doc-contr-schet then bopc_arh-fin-doc-contr-schet.income-vat  else 0)
      bfpc_arh-fin-doc-contr-schet.income-slt       = (if available bopc_arh-fin-doc-contr-schet then bopc_arh-fin-doc-contr-schet.income-slt  else 0)
      bfpc_arh-fin-doc-contr-schet.expense          = (if available bopc_arh-fin-doc-contr-schet then bopc_arh-fin-doc-contr-schet.expense     else 0) + parsum-contr
      bfpc_arh-fin-doc-contr-schet.expense-vat      = (if available bopc_arh-fin-doc-contr-schet then bopc_arh-fin-doc-contr-schet.expense-vat else 0) + parsum-vat-contr
      bfpc_arh-fin-doc-contr-schet.expense-slt      = (if available bopc_arh-fin-doc-contr-schet then bopc_arh-fin-doc-contr-schet.expense-slt else 0) + parsum-slt-contr
    .
  end.
  else do:
    find first bfpc_arh-fin-doc-contr-schet where bfpc_arh-fin-doc-contr-schet.host-code        = parhost-code         and
                                                  bfpc_arh-fin-doc-contr-schet.contract-code    = parcontract-code     and
                                                  bfpc_arh-fin-doc-contr-schet.cli-type         = parpayer-type        and
                                                  bfpc_arh-fin-doc-contr-schet.cli-code         = parpayer-code        and
                                                  bfpc_arh-fin-doc-contr-schet.code-schet       = parpayer-code-schet  and
                                                  bfpc_arh-fin-doc-contr-schet.fin-ext-doc-type = parfin-ext-doc-type  and
                                                  bfpc_arh-fin-doc-contr-schet.calc-curr-code   = parcurr-dog-code     and
                                                  bfpc_arh-fin-doc-contr-schet.sum-type         = parsum-type          and
                                                  bfpc_arh-fin-doc-contr-schet.fact-order       = parfact-order        exclusive-lock.
  end.
  for each rbfpc_arh-fin-doc-contr-schet where rbfpc_arh-fin-doc-contr-schet.host-code        = bfpc_arh-fin-doc-contr-schet.host-code        and
                                               rbfpc_arh-fin-doc-contr-schet.contract-code    = bfpc_arh-fin-doc-contr-schet.contract-code    and
                                               rbfpc_arh-fin-doc-contr-schet.cli-type         = parpayer-type                                 and
                                               rbfpc_arh-fin-doc-contr-schet.cli-code         = parpayer-code                                 and
                                               rbfpc_arh-fin-doc-contr-schet.code-schet       = bfpc_arh-fin-doc-contr-schet.code-schet       and
                                               rbfpc_arh-fin-doc-contr-schet.fin-ext-doc-type = bfpc_arh-fin-doc-contr-schet.fin-ext-doc-type and
                                               rbfpc_arh-fin-doc-contr-schet.calc-curr-code   = bfpc_arh-fin-doc-contr-schet.calc-curr-code   and
                                               rbfpc_arh-fin-doc-contr-schet.sum-type         = bfpc_arh-fin-doc-contr-schet.sum-type         and
                                               rbfpc_arh-fin-doc-contr-schet.fact-order       > bfpc_arh-fin-doc-contr-schet.fact-order       use-index pi exclusive-lock on error undo, return error return-value :
    assign
      rbfpc_arh-fin-doc-contr-schet.expense     = rbfpc_arh-fin-doc-contr-schet.expense     + parsum-contr
      rbfpc_arh-fin-doc-contr-schet.expense-vat = rbfpc_arh-fin-doc-contr-schet.expense-vat + parsum-vat-contr
      rbfpc_arh-fin-doc-contr-schet.expense-slt = rbfpc_arh-fin-doc-contr-schet.expense-slt + parsum-slt-contr
    .
  end.
  if parmode = "close":u then do:
    find last borc_arh-fin-doc-contr-schet where borc_arh-fin-doc-contr-schet.host-code        = parhost-code            and
                                                 borc_arh-fin-doc-contr-schet.contract-code    = parcontract-code        and
                                                 borc_arh-fin-doc-contr-schet.cli-type         = parreceiver-type        and
                                                 borc_arh-fin-doc-contr-schet.cli-code         = parreceiver-code        and
                                                 borc_arh-fin-doc-contr-schet.code-schet       = parreceiver-code-schet  and
                                                 borc_arh-fin-doc-contr-schet.fin-ext-doc-type = parfin-ext-doc-type     and
                                                 borc_arh-fin-doc-contr-schet.calc-curr-code   = parcurr-dog-code        and
                                                 borc_arh-fin-doc-contr-schet.sum-type         = parsum-type             and
                                                 borc_arh-fin-doc-contr-schet.fact-order       < parfact-order           use-index pi no-error.
    create bfrc_arh-fin-doc-contr-schet.
    assign
      bfrc_arh-fin-doc-contr-schet.host-code        = parhost-code
      bfrc_arh-fin-doc-contr-schet.contract-code    = parcontract-code
      bfrc_arh-fin-doc-contr-schet.cli-type         = parreceiver-type
      bfrc_arh-fin-doc-contr-schet.cli-code         = parreceiver-code
      bfrc_arh-fin-doc-contr-schet.code-schet       = parreceiver-code-schet
      bfrc_arh-fin-doc-contr-schet.fin-ext-doc-type = parfin-ext-doc-type
      bfrc_arh-fin-doc-contr-schet.calc-curr-code   = parcurr-dog-code
      bfrc_arh-fin-doc-contr-schet.sum-type         = parsum-type
      bfrc_arh-fin-doc-contr-schet.cource-des       = "c":u
      bfrc_arh-fin-doc-contr-schet.fact-order       = parfact-order
      bfrc_arh-fin-doc-contr-schet.fin-doc-code     = parfin-doc-code
      bfrc_arh-fin-doc-contr-schet.fact-date        = parfact-date
      bfrc_arh-fin-doc-contr-schet.curr-code        = parcurr-code
    .
    assign
      bfrc_arh-fin-doc-contr-schet.expense          = (if available borc_arh-fin-doc-contr-schet then borc_arh-fin-doc-contr-schet.expense     else 0)
      bfrc_arh-fin-doc-contr-schet.expense-vat      = (if available borc_arh-fin-doc-contr-schet then borc_arh-fin-doc-contr-schet.expense-vat else 0)
      bfrc_arh-fin-doc-contr-schet.expense-slt      = (if available borc_arh-fin-doc-contr-schet then borc_arh-fin-doc-contr-schet.expense-slt else 0)
      bfrc_arh-fin-doc-contr-schet.income           = (if available borc_arh-fin-doc-contr-schet then borc_arh-fin-doc-contr-schet.income      else 0) + parsum-contr
      bfrc_arh-fin-doc-contr-schet.income-vat       = (if available borc_arh-fin-doc-contr-schet then borc_arh-fin-doc-contr-schet.income-vat  else 0) + parsum-vat-contr
      bfrc_arh-fin-doc-contr-schet.income-slt       = (if available borc_arh-fin-doc-contr-schet then borc_arh-fin-doc-contr-schet.income-slt  else 0) + parsum-slt-contr
    .
  end.
  else do:
    find first bfrc_arh-fin-doc-contr-schet where bfrc_arh-fin-doc-contr-schet.host-code        = parhost-code            and
                                                  bfrc_arh-fin-doc-contr-schet.contract-code    = parcontract-code        and
                                                  bfrc_arh-fin-doc-contr-schet.cli-type         = parreceiver-type        and
                                                  bfrc_arh-fin-doc-contr-schet.cli-code         = parreceiver-code        and
                                                  bfrc_arh-fin-doc-contr-schet.code-schet       = parreceiver-code-schet  and
                                                  bfrc_arh-fin-doc-contr-schet.fin-ext-doc-type = parfin-ext-doc-type     and
                                                  bfrc_arh-fin-doc-contr-schet.calc-curr-code   = parcurr-dog-code        and
                                                  bfrc_arh-fin-doc-contr-schet.sum-type         = parsum-type             and
                                                  bfrc_arh-fin-doc-contr-schet.fact-order       = parfact-order           exclusive-lock.
  end.
  for each rbfrc_arh-fin-doc-contr-schet where rbfrc_arh-fin-doc-contr-schet.host-code        = bfrc_arh-fin-doc-contr-schet.host-code        and
                                               rbfrc_arh-fin-doc-contr-schet.contract-code    = bfrc_arh-fin-doc-contr-schet.contract-code    and
                                               rbfrc_arh-fin-doc-contr-schet.cli-type         = parreceiver-type                              and
                                               rbfrc_arh-fin-doc-contr-schet.cli-code         = parreceiver-code                              and
                                               rbfrc_arh-fin-doc-contr-schet.code-schet       = bfrc_arh-fin-doc-contr-schet.code-schet       and
                                               rbfrc_arh-fin-doc-contr-schet.fin-ext-doc-type = bfrc_arh-fin-doc-contr-schet.fin-ext-doc-type and
                                               rbfrc_arh-fin-doc-contr-schet.calc-curr-code   = bfrc_arh-fin-doc-contr-schet.calc-curr-code   and
                                               rbfrc_arh-fin-doc-contr-schet.sum-type         = bfrc_arh-fin-doc-contr-schet.sum-type         and
                                               rbfrc_arh-fin-doc-contr-schet.fact-order       > bfrc_arh-fin-doc-contr-schet.fact-order       use-index pi exclusive-lock on error undo, return error return-value :
    assign
      rbfrc_arh-fin-doc-contr-schet.income     = rbfrc_arh-fin-doc-contr-schet.income     + parsum-contr
      rbfrc_arh-fin-doc-contr-schet.income-vat = rbfrc_arh-fin-doc-contr-schet.income-vat + parsum-vat-contr
      rbfrc_arh-fin-doc-contr-schet.income-slt = rbfrc_arh-fin-doc-contr-schet.income-slt + parsum-slt-contr
    .
  end.
  if parmode = "delete":u then do:
    delete bfpc_arh-fin-doc-contr-schet.
    delete bfrc_arh-fin-doc-contr-schet.
  end.
end.
end.
end procedure.

procedure libfarhp_calc-arh-fin-doc-contr-schet-tax :
define input parameter parmode                    as   character                   no-undo.
define input parameter parhost-code               like ub.fin-doc.host-code        no-undo.
define input parameter parpayer-type              like ub.fin-doc.payer-type       no-undo.
define input parameter parpayer-code              like ub.fin-doc.payer-code       no-undo.
define input parameter parreceiver-type           like ub.fin-doc.receiver-type    no-undo.
define input parameter parreceiver-code           like ub.fin-doc.receiver-code    no-undo.
define input parameter parpayer-code-schet        like ub.fin-schet.code-schet     no-undo.
define input parameter parreceiver-code-schet     like ub.fin-schet.code-schet     no-undo.
define input parameter parfin-ext-doc-type        like ub.fin-doc.fin-ext-doc-type no-undo.
define input parameter parsum-type                as   character                   no-undo.
define input parameter parfact-order              like ub.fin-doc.fact-order       no-undo.
define input parameter parfin-doc-code            like ub.fin-doc.fin-doc-code     no-undo.
define input parameter parfact-date               like ub.fin-doc.fact-date        no-undo.
define input parameter parcurr-code               like ub.fin-doc.curr-code        no-undo.
define input parameter parbase-code               like ub.sysconf.base-code        no-undo.
define input parameter parcurr-dog-code           like ub.contract.curr-code       no-undo.
define input parameter parrel-dog-code            as   logical                     no-undo.
define input parameter parcontract-code           like ub.contract.contract-code   no-undo.
define input parameter parvat-pc                  like ub.fin-doc-tax.vat-pc       no-undo.
define input parameter parslt-pc                  like ub.fin-doc-tax.slt-pc       no-undo.
define input parameter parwith-vat                as   logical                     no-undo.
define input parameter parwith-slt                as   logical                     no-undo.
define input parameter parsum-doc                 as   decimal                     no-undo.
define input parameter parsum-rubl                as   decimal                     no-undo.
define input parameter parsum-base                as   decimal                     no-undo.
define input parameter parsum-contr               as   decimal                     no-undo.
define input parameter parsum-vat-doc             as   decimal                     no-undo.
define input parameter parsum-vat-rubl            as   decimal                     no-undo.
define input parameter parsum-vat-base            as   decimal                     no-undo.
define input parameter parsum-vat-contr           as   decimal                     no-undo.
define input parameter parsum-slt-doc             as   decimal                     no-undo.
define input parameter parsum-slt-rubl            as   decimal                     no-undo.
define input parameter parsum-slt-base            as   decimal                     no-undo.
define input parameter parsum-slt-contr           as   decimal                     no-undo.
define buffer bfps_arh-fin-doc-contr-schet-tax for ub.arh-fin-doc-contr-schet-tax.
define buffer bfrs_arh-fin-doc-contr-schet-tax for ub.arh-fin-doc-contr-schet-tax.
define buffer rbfps_arh-fin-doc-contr-schet-t  for ub.arh-fin-doc-contr-schet-tax.
define buffer rbfrs_arh-fin-doc-contr-schet-t  for ub.arh-fin-doc-contr-schet-tax.
define buffer bops_arh-fin-doc-contr-schet-tax for ub.arh-fin-doc-contr-schet-tax.
define buffer bors_arh-fin-doc-contr-schet-tax for ub.arh-fin-doc-contr-schet-tax.
define buffer bfpr_arh-fin-doc-contr-schet-tax for ub.arh-fin-doc-contr-schet-tax.
define buffer bfrr_arh-fin-doc-contr-schet-tax for ub.arh-fin-doc-contr-schet-tax.
define buffer rbfpr_arh-fin-doc-contr-schet-t  for ub.arh-fin-doc-contr-schet-tax.
define buffer rbfrr_arh-fin-doc-contr-schet-t  for ub.arh-fin-doc-contr-schet-tax.
define buffer bopr_arh-fin-doc-contr-schet-tax for ub.arh-fin-doc-contr-schet-tax.
define buffer borr_arh-fin-doc-contr-schet-tax for ub.arh-fin-doc-contr-schet-tax.
define buffer bfpb_arh-fin-doc-contr-schet-tax for ub.arh-fin-doc-contr-schet-tax.
define buffer bfrb_arh-fin-doc-contr-schet-tax for ub.arh-fin-doc-contr-schet-tax.
define buffer rbfpb_arh-fin-doc-contr-schet-t  for ub.arh-fin-doc-contr-schet-tax.
define buffer rbfrb_arh-fin-doc-contr-schet-t  for ub.arh-fin-doc-contr-schet-tax.
define buffer bopb_arh-fin-doc-contr-schet-tax for ub.arh-fin-doc-contr-schet-tax.
define buffer borb_arh-fin-doc-contr-schet-tax for ub.arh-fin-doc-contr-schet-tax.
define buffer bfpc_arh-fin-doc-contr-schet-tax for ub.arh-fin-doc-contr-schet-tax.
define buffer bfrc_arh-fin-doc-contr-schet-tax for ub.arh-fin-doc-contr-schet-tax.
define buffer rbfpc_arh-fin-doc-contr-schet-t  for ub.arh-fin-doc-contr-schet-tax.
define buffer rbfrc_arh-fin-doc-contr-schet-t  for ub.arh-fin-doc-contr-schet-tax.
define buffer bopc_arh-fin-doc-contr-schet-tax for ub.arh-fin-doc-contr-schet-tax.
define buffer borc_arh-fin-doc-contr-schet-tax for ub.arh-fin-doc-contr-schet-tax.
do on error undo, return error substitute ("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
if parmode = "close":u then do:
  find last bops_arh-fin-doc-contr-schet-tax where bops_arh-fin-doc-contr-schet-tax.host-code        = parhost-code         and
                                                   bops_arh-fin-doc-contr-schet-tax.contract-code    = parcontract-code     and
                                                   bops_arh-fin-doc-contr-schet-tax.cli-type         = parpayer-type        and
                                                   bops_arh-fin-doc-contr-schet-tax.cli-code         = parpayer-code        and
                                                   bops_arh-fin-doc-contr-schet-tax.code-schet       = parpayer-code-schet  and
                                                   bops_arh-fin-doc-contr-schet-tax.fin-ext-doc-type = parfin-ext-doc-type  and
                                                   bops_arh-fin-doc-contr-schet-tax.calc-curr-code   = parcurr-code         and
                                                   bops_arh-fin-doc-contr-schet-tax.vat-pc           = parvat-pc            and
                                                   bops_arh-fin-doc-contr-schet-tax.slt-pc           = parslt-pc            and
                                                   bops_arh-fin-doc-contr-schet-tax.with-vat         = parwith-vat          and
                                                   bops_arh-fin-doc-contr-schet-tax.with-slt         = parwith-slt          and
                                                   bops_arh-fin-doc-contr-schet-tax.sum-type         = parsum-type          and
                                                   bops_arh-fin-doc-contr-schet-tax.fact-order       < parfact-order        use-index pi no-error.
  create bfps_arh-fin-doc-contr-schet-tax.
  assign
    bfps_arh-fin-doc-contr-schet-tax.host-code        = parhost-code
    bfps_arh-fin-doc-contr-schet-tax.contract-code    = parcontract-code
    bfps_arh-fin-doc-contr-schet-tax.cli-type         = parpayer-type
    bfps_arh-fin-doc-contr-schet-tax.cli-code         = parpayer-code
    bfps_arh-fin-doc-contr-schet-tax.code-schet       = parpayer-code-schet
    bfps_arh-fin-doc-contr-schet-tax.fin-ext-doc-type = parfin-ext-doc-type
    bfps_arh-fin-doc-contr-schet-tax.calc-curr-code   = parcurr-code
    bfps_arh-fin-doc-contr-schet-tax.vat-pc           = parvat-pc
    bfps_arh-fin-doc-contr-schet-tax.slt-pc           = parslt-pc
    bfps_arh-fin-doc-contr-schet-tax.with-vat         = parwith-vat
    bfps_arh-fin-doc-contr-schet-tax.with-slt         = parwith-slt
    bfps_arh-fin-doc-contr-schet-tax.sum-type         = parsum-type
    bfps_arh-fin-doc-contr-schet-tax.cource-des       = "s":u
    bfps_arh-fin-doc-contr-schet-tax.fact-order       = parfact-order
    bfps_arh-fin-doc-contr-schet-tax.fin-doc-code     = parfin-doc-code
    bfps_arh-fin-doc-contr-schet-tax.fact-date        = parfact-date
    bfps_arh-fin-doc-contr-schet-tax.curr-code        = parcurr-code
    bfps_arh-fin-doc-contr-schet-tax.income           = (if available bops_arh-fin-doc-contr-schet-tax then bops_arh-fin-doc-contr-schet-tax.income      else 0)
    bfps_arh-fin-doc-contr-schet-tax.income-vat       = (if available bops_arh-fin-doc-contr-schet-tax then bops_arh-fin-doc-contr-schet-tax.income-vat  else 0)
    bfps_arh-fin-doc-contr-schet-tax.income-slt       = (if available bops_arh-fin-doc-contr-schet-tax then bops_arh-fin-doc-contr-schet-tax.income-slt  else 0)
    bfps_arh-fin-doc-contr-schet-tax.expense          = (if available bops_arh-fin-doc-contr-schet-tax then bops_arh-fin-doc-contr-schet-tax.expense     else 0) + parsum-doc
    bfps_arh-fin-doc-contr-schet-tax.expense-vat      = (if available bops_arh-fin-doc-contr-schet-tax then bops_arh-fin-doc-contr-schet-tax.expense-vat else 0) + parsum-vat-doc
    bfps_arh-fin-doc-contr-schet-tax.expense-slt      = (if available bops_arh-fin-doc-contr-schet-tax then bops_arh-fin-doc-contr-schet-tax.expense-slt else 0) + parsum-slt-doc
  .
end.
else do:
  find first bfps_arh-fin-doc-contr-schet-tax where bfps_arh-fin-doc-contr-schet-tax.host-code        = parhost-code         and
                                                    bfps_arh-fin-doc-contr-schet-tax.contract-code    = parcontract-code     and
                                                    bfps_arh-fin-doc-contr-schet-tax.cli-type         = parpayer-type        and
                                                    bfps_arh-fin-doc-contr-schet-tax.cli-code         = parpayer-code        and
                                                    bfps_arh-fin-doc-contr-schet-tax.code-schet       = parpayer-code-schet  and
                                                    bfps_arh-fin-doc-contr-schet-tax.fin-ext-doc-type = parfin-ext-doc-type  and
                                                    bfps_arh-fin-doc-contr-schet-tax.calc-curr-code   = parcurr-code         and
                                                    bfps_arh-fin-doc-contr-schet-tax.vat-pc           = parvat-pc            and
                                                    bfps_arh-fin-doc-contr-schet-tax.slt-pc           = parslt-pc            and
                                                    bfps_arh-fin-doc-contr-schet-tax.with-vat         = parwith-vat          and
                                                    bfps_arh-fin-doc-contr-schet-tax.with-slt         = parwith-slt          and
                                                    bfps_arh-fin-doc-contr-schet-tax.sum-type         = parsum-type          and
                                                    bfps_arh-fin-doc-contr-schet-tax.fact-order       = parfact-order        exclusive-lock.
end.
for each rbfps_arh-fin-doc-contr-schet-t where rbfps_arh-fin-doc-contr-schet-t.host-code        = bfps_arh-fin-doc-contr-schet-tax.host-code        and
                                               rbfps_arh-fin-doc-contr-schet-t.contract-code    = bfps_arh-fin-doc-contr-schet-tax.contract-code    and
                                               rbfps_arh-fin-doc-contr-schet-t.cli-type         = parpayer-type                                     and
                                               rbfps_arh-fin-doc-contr-schet-t.cli-code         = parpayer-code                                     and
                                               rbfps_arh-fin-doc-contr-schet-t.code-schet       = bfps_arh-fin-doc-contr-schet-tax.code-schet       and
                                               rbfps_arh-fin-doc-contr-schet-t.fin-ext-doc-type = bfps_arh-fin-doc-contr-schet-tax.fin-ext-doc-type and
                                               rbfps_arh-fin-doc-contr-schet-t.calc-curr-code   = bfps_arh-fin-doc-contr-schet-tax.calc-curr-code   and
                                               rbfps_arh-fin-doc-contr-schet-t.vat-pc           = bfps_arh-fin-doc-contr-schet-tax.vat-pc           and
                                               rbfps_arh-fin-doc-contr-schet-t.slt-pc           = bfps_arh-fin-doc-contr-schet-tax.slt-pc           and
                                               rbfps_arh-fin-doc-contr-schet-t.with-vat         = bfps_arh-fin-doc-contr-schet-tax.with-vat         and
                                               rbfps_arh-fin-doc-contr-schet-t.with-slt         = bfps_arh-fin-doc-contr-schet-tax.with-slt         and
                                               rbfps_arh-fin-doc-contr-schet-t.sum-type         = bfps_arh-fin-doc-contr-schet-tax.sum-type         and
                                               rbfps_arh-fin-doc-contr-schet-t.fact-order       > bfps_arh-fin-doc-contr-schet-tax.fact-order       use-index pi exclusive-lock on error undo, return error return-value :
  assign
    rbfps_arh-fin-doc-contr-schet-t.expense     = rbfps_arh-fin-doc-contr-schet-t.expense     + parsum-doc
    rbfps_arh-fin-doc-contr-schet-t.expense-vat = rbfps_arh-fin-doc-contr-schet-t.expense-vat + parsum-vat-doc
    rbfps_arh-fin-doc-contr-schet-t.expense-slt = rbfps_arh-fin-doc-contr-schet-t.expense-slt + parsum-slt-doc
  .
end.
if parmode = "close":u then do:
  find last bors_arh-fin-doc-contr-schet-tax where bors_arh-fin-doc-contr-schet-tax.host-code         = parhost-code           and
                                                   bors_arh-fin-doc-contr-schet-tax.contract-code     = parcontract-code       and
                                                   bors_arh-fin-doc-contr-schet-tax.cli-type          = parreceiver-type       and
                                                   bors_arh-fin-doc-contr-schet-tax.cli-code          = parreceiver-code       and
                                                   bors_arh-fin-doc-contr-schet-tax.code-schet        = parreceiver-code-schet and
                                                   bors_arh-fin-doc-contr-schet-tax.fin-ext-doc-type  = parfin-ext-doc-type    and
                                                   bors_arh-fin-doc-contr-schet-tax.calc-curr-code    = parcurr-code           and
                                                   bors_arh-fin-doc-contr-schet-tax.vat-pc            = parvat-pc              and
                                                   bors_arh-fin-doc-contr-schet-tax.slt-pc            = parslt-pc              and
                                                   bors_arh-fin-doc-contr-schet-tax.with-vat          = parwith-vat            and
                                                   bors_arh-fin-doc-contr-schet-tax.with-slt          = parwith-slt            and
                                                   bors_arh-fin-doc-contr-schet-tax.sum-type          = parsum-type            and
                                                   bors_arh-fin-doc-contr-schet-tax.fact-order        < parfact-order          use-index pi no-error.
  create bfrs_arh-fin-doc-contr-schet-tax.
  assign
    bfrs_arh-fin-doc-contr-schet-tax.host-code        = parhost-code
    bfrs_arh-fin-doc-contr-schet-tax.contract-code    = parcontract-code
    bfrs_arh-fin-doc-contr-schet-tax.cli-type         = parreceiver-type
    bfrs_arh-fin-doc-contr-schet-tax.cli-code         = parreceiver-code
    bfrs_arh-fin-doc-contr-schet-tax.code-schet       = parreceiver-code-schet
    bfrs_arh-fin-doc-contr-schet-tax.fin-ext-doc-type = parfin-ext-doc-type
    bfrs_arh-fin-doc-contr-schet-tax.calc-curr-code   = parcurr-code
    bfrs_arh-fin-doc-contr-schet-tax.vat-pc           = parvat-pc
    bfrs_arh-fin-doc-contr-schet-tax.slt-pc           = parslt-pc
    bfrs_arh-fin-doc-contr-schet-tax.with-vat         = parwith-vat
    bfrs_arh-fin-doc-contr-schet-tax.with-slt         = parwith-slt
    bfrs_arh-fin-doc-contr-schet-tax.sum-type         = parsum-type
    bfrs_arh-fin-doc-contr-schet-tax.cource-des       = "s":u
    bfrs_arh-fin-doc-contr-schet-tax.fact-order       = parfact-order
    bfrs_arh-fin-doc-contr-schet-tax.fin-doc-code     = parfin-doc-code
    bfrs_arh-fin-doc-contr-schet-tax.fact-date        = parfact-date
    bfrs_arh-fin-doc-contr-schet-tax.curr-code        = parcurr-code
  .
  assign
    bfrs_arh-fin-doc-contr-schet-tax.expense          = (if available bors_arh-fin-doc-contr-schet-tax then bors_arh-fin-doc-contr-schet-tax.expense     else 0)
    bfrs_arh-fin-doc-contr-schet-tax.expense-vat      = (if available bors_arh-fin-doc-contr-schet-tax then bors_arh-fin-doc-contr-schet-tax.expense-vat else 0)
    bfrs_arh-fin-doc-contr-schet-tax.expense-slt      = (if available bors_arh-fin-doc-contr-schet-tax then bors_arh-fin-doc-contr-schet-tax.expense-slt else 0)
    bfrs_arh-fin-doc-contr-schet-tax.income           = (if available bors_arh-fin-doc-contr-schet-tax then bors_arh-fin-doc-contr-schet-tax.income      else 0) + parsum-doc
    bfrs_arh-fin-doc-contr-schet-tax.income-vat       = (if available bors_arh-fin-doc-contr-schet-tax then bors_arh-fin-doc-contr-schet-tax.income-vat  else 0) + parsum-vat-doc
    bfrs_arh-fin-doc-contr-schet-tax.income-slt       = (if available bors_arh-fin-doc-contr-schet-tax then bors_arh-fin-doc-contr-schet-tax.income-slt  else 0) + parsum-slt-doc
  .
end.
else do:
  find first bfrs_arh-fin-doc-contr-schet-tax where bfrs_arh-fin-doc-contr-schet-tax.host-code         = parhost-code           and
                                                    bfrs_arh-fin-doc-contr-schet-tax.contract-code     = parcontract-code       and
                                                    bfrs_arh-fin-doc-contr-schet-tax.cli-type          = parreceiver-type       and
                                                    bfrs_arh-fin-doc-contr-schet-tax.cli-code          = parreceiver-code       and
                                                    bfrs_arh-fin-doc-contr-schet-tax.code-schet        = parreceiver-code-schet and
                                                    bfrs_arh-fin-doc-contr-schet-tax.fin-ext-doc-type  = parfin-ext-doc-type    and
                                                    bfrs_arh-fin-doc-contr-schet-tax.calc-curr-code    = parcurr-code           and
                                                    bfrs_arh-fin-doc-contr-schet-tax.vat-pc            = parvat-pc              and
                                                    bfrs_arh-fin-doc-contr-schet-tax.slt-pc            = parslt-pc              and
                                                    bfrs_arh-fin-doc-contr-schet-tax.with-vat          = parwith-vat            and
                                                    bfrs_arh-fin-doc-contr-schet-tax.with-slt          = parwith-slt            and
                                                    bfrs_arh-fin-doc-contr-schet-tax.sum-type          = parsum-type            and
                                                    bfrs_arh-fin-doc-contr-schet-tax.fact-order        = parfact-order          exclusive-lock.
end.
for each rbfrs_arh-fin-doc-contr-schet-t where rbfrs_arh-fin-doc-contr-schet-t.host-code        = bfrs_arh-fin-doc-contr-schet-tax.host-code        and
                                               rbfrs_arh-fin-doc-contr-schet-t.contract-code    = bfrs_arh-fin-doc-contr-schet-tax.contract-code    and
                                               rbfrs_arh-fin-doc-contr-schet-t.cli-type         = parreceiver-type                                  and
                                               rbfrs_arh-fin-doc-contr-schet-t.cli-code         = parreceiver-code                                  and
                                               rbfrs_arh-fin-doc-contr-schet-t.code-schet       = bfrs_arh-fin-doc-contr-schet-tax.code-schet       and
                                               rbfrs_arh-fin-doc-contr-schet-t.fin-ext-doc-type = bfrs_arh-fin-doc-contr-schet-tax.fin-ext-doc-type and
                                               rbfrs_arh-fin-doc-contr-schet-t.calc-curr-code   = bfrs_arh-fin-doc-contr-schet-tax.calc-curr-code   and
                                               rbfrs_arh-fin-doc-contr-schet-t.vat-pc           = bfrs_arh-fin-doc-contr-schet-tax.vat-pc           and
                                               rbfrs_arh-fin-doc-contr-schet-t.slt-pc           = bfrs_arh-fin-doc-contr-schet-tax.slt-pc           and
                                               rbfrs_arh-fin-doc-contr-schet-t.with-vat         = bfrs_arh-fin-doc-contr-schet-tax.with-vat         and
                                               rbfrs_arh-fin-doc-contr-schet-t.with-slt         = bfrs_arh-fin-doc-contr-schet-tax.with-slt         and
                                               rbfrs_arh-fin-doc-contr-schet-t.sum-type         = bfrs_arh-fin-doc-contr-schet-tax.sum-type         and
                                               rbfrs_arh-fin-doc-contr-schet-t.fact-order       > bfrs_arh-fin-doc-contr-schet-tax.fact-order       use-index pi exclusive-lock on error undo, return error return-value :
  assign
    rbfrs_arh-fin-doc-contr-schet-t.income     = rbfrs_arh-fin-doc-contr-schet-t.income     + parsum-doc
    rbfrs_arh-fin-doc-contr-schet-t.income-vat = rbfrs_arh-fin-doc-contr-schet-t.income-vat + parsum-vat-doc
    rbfrs_arh-fin-doc-contr-schet-t.income-slt = rbfrs_arh-fin-doc-contr-schet-t.income-slt + parsum-slt-doc
  .
end.
if parmode = "delete":u then do:
  delete bfps_arh-fin-doc-contr-schet-tax.
  delete bfrs_arh-fin-doc-contr-schet-tax.
end.
if parcurr-code <> 0 then do:
  if parmode = "close":u then do:
    find last bopr_arh-fin-doc-contr-schet-tax where bopr_arh-fin-doc-contr-schet-tax.host-code        = parhost-code         and
                                                     bopr_arh-fin-doc-contr-schet-tax.contract-code    = parcontract-code     and
                                                     bopr_arh-fin-doc-contr-schet-tax.cli-type         = parpayer-type        and
                                                     bopr_arh-fin-doc-contr-schet-tax.cli-code         = parpayer-code        and
                                                     bopr_arh-fin-doc-contr-schet-tax.code-schet       = parpayer-code-schet  and
                                                     bopr_arh-fin-doc-contr-schet-tax.fin-ext-doc-type = parfin-ext-doc-type  and
                                                     bopr_arh-fin-doc-contr-schet-tax.calc-curr-code   = 0                    and
                                                     bopr_arh-fin-doc-contr-schet-tax.vat-pc           = parvat-pc            and
                                                     bopr_arh-fin-doc-contr-schet-tax.slt-pc           = parslt-pc            and
                                                     bopr_arh-fin-doc-contr-schet-tax.with-vat         = parwith-vat          and
                                                     bopr_arh-fin-doc-contr-schet-tax.with-slt         = parwith-slt          and
                                                     bopr_arh-fin-doc-contr-schet-tax.sum-type         = parsum-type          and
                                                     bopr_arh-fin-doc-contr-schet-tax.fact-order       < parfact-order        use-index pi no-error.
    create bfpr_arh-fin-doc-contr-schet-tax.
    assign
      bfpr_arh-fin-doc-contr-schet-tax.host-code        = parhost-code
      bfpr_arh-fin-doc-contr-schet-tax.contract-code    = parcontract-code
      bfpr_arh-fin-doc-contr-schet-tax.cli-type         = parpayer-type
      bfpr_arh-fin-doc-contr-schet-tax.cli-code         = parpayer-code
      bfpr_arh-fin-doc-contr-schet-tax.code-schet       = parpayer-code-schet
      bfpr_arh-fin-doc-contr-schet-tax.fin-ext-doc-type = parfin-ext-doc-type
      bfpr_arh-fin-doc-contr-schet-tax.calc-curr-code   = 0
      bfpr_arh-fin-doc-contr-schet-tax.vat-pc           = parvat-pc
      bfpr_arh-fin-doc-contr-schet-tax.slt-pc           = parslt-pc
      bfpr_arh-fin-doc-contr-schet-tax.with-vat         = parwith-vat
      bfpr_arh-fin-doc-contr-schet-tax.with-slt         = parwith-slt
      bfpr_arh-fin-doc-contr-schet-tax.sum-type         = parsum-type
      bfpr_arh-fin-doc-contr-schet-tax.cource-des       = "r":u
      bfpr_arh-fin-doc-contr-schet-tax.fact-order       = parfact-order
      bfpr_arh-fin-doc-contr-schet-tax.fin-doc-code     = parfin-doc-code
      bfpr_arh-fin-doc-contr-schet-tax.fact-date        = parfact-date
      bfpr_arh-fin-doc-contr-schet-tax.curr-code        = parcurr-code
      bfpr_arh-fin-doc-contr-schet-tax.income           = (if available bopr_arh-fin-doc-contr-schet-tax then bopr_arh-fin-doc-contr-schet-tax.income      else 0)
      bfpr_arh-fin-doc-contr-schet-tax.income-vat       = (if available bopr_arh-fin-doc-contr-schet-tax then bopr_arh-fin-doc-contr-schet-tax.income-vat  else 0)
      bfpr_arh-fin-doc-contr-schet-tax.income-slt       = (if available bopr_arh-fin-doc-contr-schet-tax then bopr_arh-fin-doc-contr-schet-tax.income-slt  else 0)
      bfpr_arh-fin-doc-contr-schet-tax.expense          = (if available bopr_arh-fin-doc-contr-schet-tax then bopr_arh-fin-doc-contr-schet-tax.expense     else 0) + parsum-rubl
      bfpr_arh-fin-doc-contr-schet-tax.expense-vat      = (if available bopr_arh-fin-doc-contr-schet-tax then bopr_arh-fin-doc-contr-schet-tax.expense-vat else 0) + parsum-vat-rubl
      bfpr_arh-fin-doc-contr-schet-tax.expense-slt      = (if available bopr_arh-fin-doc-contr-schet-tax then bopr_arh-fin-doc-contr-schet-tax.expense-slt else 0) + parsum-slt-rubl
    .
  end.
  else do:
    find first bfpr_arh-fin-doc-contr-schet-tax where bfpr_arh-fin-doc-contr-schet-tax.host-code        = parhost-code         and
                                                      bfpr_arh-fin-doc-contr-schet-tax.contract-code    = parcontract-code     and
                                                      bfpr_arh-fin-doc-contr-schet-tax.cli-type         = parpayer-type        and
                                                      bfpr_arh-fin-doc-contr-schet-tax.cli-code         = parpayer-code        and
                                                      bfpr_arh-fin-doc-contr-schet-tax.code-schet       = parpayer-code-schet  and
                                                      bfpr_arh-fin-doc-contr-schet-tax.fin-ext-doc-type = parfin-ext-doc-type  and
                                                      bfpr_arh-fin-doc-contr-schet-tax.calc-curr-code   = 0                    and
                                                      bfpr_arh-fin-doc-contr-schet-tax.vat-pc           = parvat-pc            and
                                                      bfpr_arh-fin-doc-contr-schet-tax.slt-pc           = parslt-pc            and
                                                      bfpr_arh-fin-doc-contr-schet-tax.with-vat         = parwith-vat          and
                                                      bfpr_arh-fin-doc-contr-schet-tax.with-slt         = parwith-slt          and
                                                      bfpr_arh-fin-doc-contr-schet-tax.sum-type         = parsum-type          and
                                                      bfpr_arh-fin-doc-contr-schet-tax.fact-order       = parfact-order        exclusive-lock.
  end.
  for each rbfpr_arh-fin-doc-contr-schet-t where rbfpr_arh-fin-doc-contr-schet-t.host-code        = bfpr_arh-fin-doc-contr-schet-tax.host-code        and
                                                 rbfpr_arh-fin-doc-contr-schet-t.contract-code    = bfpr_arh-fin-doc-contr-schet-tax.contract-code    and
                                                 rbfpr_arh-fin-doc-contr-schet-t.cli-type         = parpayer-type                                     and
                                                 rbfpr_arh-fin-doc-contr-schet-t.cli-code         = parpayer-code                                     and
                                                 rbfpr_arh-fin-doc-contr-schet-t.code-schet       = bfpr_arh-fin-doc-contr-schet-tax.code-schet       and
                                                 rbfpr_arh-fin-doc-contr-schet-t.fin-ext-doc-type = bfpr_arh-fin-doc-contr-schet-tax.fin-ext-doc-type and
                                                 rbfpr_arh-fin-doc-contr-schet-t.calc-curr-code   = bfpr_arh-fin-doc-contr-schet-tax.calc-curr-code   and
                                                 rbfpr_arh-fin-doc-contr-schet-t.vat-pc           = bfpr_arh-fin-doc-contr-schet-tax.vat-pc           and
                                                 rbfpr_arh-fin-doc-contr-schet-t.slt-pc           = bfpr_arh-fin-doc-contr-schet-tax.slt-pc           and
                                                 rbfpr_arh-fin-doc-contr-schet-t.with-vat         = bfpr_arh-fin-doc-contr-schet-tax.with-vat         and
                                                 rbfpr_arh-fin-doc-contr-schet-t.with-slt         = bfpr_arh-fin-doc-contr-schet-tax.with-slt         and
                                                 rbfpr_arh-fin-doc-contr-schet-t.sum-type         = bfpr_arh-fin-doc-contr-schet-tax.sum-type         and
                                                 rbfpr_arh-fin-doc-contr-schet-t.fact-order       > bfpr_arh-fin-doc-contr-schet-tax.fact-order       use-index pi exclusive-lock on error undo, return error return-value :
    assign
      rbfpr_arh-fin-doc-contr-schet-t.expense     = rbfpr_arh-fin-doc-contr-schet-t.expense     + parsum-rubl
      rbfpr_arh-fin-doc-contr-schet-t.expense-vat = rbfpr_arh-fin-doc-contr-schet-t.expense-vat + parsum-vat-rubl
      rbfpr_arh-fin-doc-contr-schet-t.expense-slt = rbfpr_arh-fin-doc-contr-schet-t.expense-slt + parsum-slt-rubl
    .
  end.
  if parmode = "close":u then do:
    find last borr_arh-fin-doc-contr-schet-tax where borr_arh-fin-doc-contr-schet-tax.host-code        = parhost-code            and
                                                     borr_arh-fin-doc-contr-schet-tax.contract-code    = parcontract-code        and
                                                     borr_arh-fin-doc-contr-schet-tax.cli-type         = parreceiver-type        and
                                                     borr_arh-fin-doc-contr-schet-tax.cli-code         = parreceiver-code        and
                                                     borr_arh-fin-doc-contr-schet-tax.code-schet       = parreceiver-code-schet  and
                                                     borr_arh-fin-doc-contr-schet-tax.fin-ext-doc-type = parfin-ext-doc-type     and
                                                     borr_arh-fin-doc-contr-schet-tax.calc-curr-code   = 0                       and
                                                     borr_arh-fin-doc-contr-schet-tax.vat-pc           = parvat-pc               and
                                                     borr_arh-fin-doc-contr-schet-tax.slt-pc           = parslt-pc               and
                                                     borr_arh-fin-doc-contr-schet-tax.with-vat         = parwith-vat             and
                                                     borr_arh-fin-doc-contr-schet-tax.with-slt         = parwith-slt             and
                                                     borr_arh-fin-doc-contr-schet-tax.sum-type         = parsum-type             and
                                                     borr_arh-fin-doc-contr-schet-tax.fact-order       < parfact-order           use-index pi no-error.
    create bfrr_arh-fin-doc-contr-schet-tax.
    assign
      bfrr_arh-fin-doc-contr-schet-tax.host-code        = parhost-code
      bfrr_arh-fin-doc-contr-schet-tax.contract-code    = parcontract-code
      bfrr_arh-fin-doc-contr-schet-tax.cli-type         = parreceiver-type
      bfrr_arh-fin-doc-contr-schet-tax.cli-code         = parreceiver-code
      bfrr_arh-fin-doc-contr-schet-tax.code-schet       = parreceiver-code-schet
      bfrr_arh-fin-doc-contr-schet-tax.fin-ext-doc-type = parfin-ext-doc-type
      bfrr_arh-fin-doc-contr-schet-tax.calc-curr-code   = 0
      bfrr_arh-fin-doc-contr-schet-tax.vat-pc           = parvat-pc
      bfrr_arh-fin-doc-contr-schet-tax.slt-pc           = parslt-pc
      bfrr_arh-fin-doc-contr-schet-tax.with-vat         = parwith-vat
      bfrr_arh-fin-doc-contr-schet-tax.with-slt         = parwith-slt
      bfrr_arh-fin-doc-contr-schet-tax.sum-type         = parsum-type
      bfrr_arh-fin-doc-contr-schet-tax.cource-des       = "r":u
      bfrr_arh-fin-doc-contr-schet-tax.fact-order       = parfact-order
      bfrr_arh-fin-doc-contr-schet-tax.fin-doc-code     = parfin-doc-code
      bfrr_arh-fin-doc-contr-schet-tax.fact-date        = parfact-date
      bfrr_arh-fin-doc-contr-schet-tax.curr-code        = parcurr-code
    .
    assign
      bfrr_arh-fin-doc-contr-schet-tax.expense          = (if available borr_arh-fin-doc-contr-schet-tax then borr_arh-fin-doc-contr-schet-tax.expense     else 0)
      bfrr_arh-fin-doc-contr-schet-tax.expense-vat      = (if available borr_arh-fin-doc-contr-schet-tax then borr_arh-fin-doc-contr-schet-tax.expense-vat else 0)
      bfrr_arh-fin-doc-contr-schet-tax.expense-slt      = (if available borr_arh-fin-doc-contr-schet-tax then borr_arh-fin-doc-contr-schet-tax.expense-slt else 0)
      bfrr_arh-fin-doc-contr-schet-tax.income           = (if available borr_arh-fin-doc-contr-schet-tax then borr_arh-fin-doc-contr-schet-tax.income      else 0) + parsum-rubl
      bfrr_arh-fin-doc-contr-schet-tax.income-vat       = (if available borr_arh-fin-doc-contr-schet-tax then borr_arh-fin-doc-contr-schet-tax.income-vat  else 0) + parsum-vat-rubl
      bfrr_arh-fin-doc-contr-schet-tax.income-slt       = (if available borr_arh-fin-doc-contr-schet-tax then borr_arh-fin-doc-contr-schet-tax.income-slt  else 0) + parsum-slt-rubl
    .
  end.
  else do:
    find first bfrr_arh-fin-doc-contr-schet-tax where bfrr_arh-fin-doc-contr-schet-tax.host-code        = parhost-code            and
                                                      bfrr_arh-fin-doc-contr-schet-tax.contract-code    = parcontract-code        and
                                                      bfrr_arh-fin-doc-contr-schet-tax.cli-type         = parreceiver-type        and
                                                      bfrr_arh-fin-doc-contr-schet-tax.cli-code         = parreceiver-code        and
                                                      bfrr_arh-fin-doc-contr-schet-tax.code-schet       = parreceiver-code-schet  and
                                                      bfrr_arh-fin-doc-contr-schet-tax.fin-ext-doc-type = parfin-ext-doc-type     and
                                                      bfrr_arh-fin-doc-contr-schet-tax.calc-curr-code   = 0                       and
                                                      bfrr_arh-fin-doc-contr-schet-tax.vat-pc           = parvat-pc               and
                                                      bfrr_arh-fin-doc-contr-schet-tax.slt-pc           = parslt-pc               and
                                                      bfrr_arh-fin-doc-contr-schet-tax.with-vat         = parwith-vat             and
                                                      bfrr_arh-fin-doc-contr-schet-tax.with-slt         = parwith-slt             and
                                                      bfrr_arh-fin-doc-contr-schet-tax.sum-type         = parsum-type             and
                                                      bfrr_arh-fin-doc-contr-schet-tax.fact-order       = parfact-order           exclusive-lock.
  end.
  for each rbfrr_arh-fin-doc-contr-schet-t where rbfrr_arh-fin-doc-contr-schet-t.host-code        = bfrr_arh-fin-doc-contr-schet-tax.host-code        and
                                                 rbfrr_arh-fin-doc-contr-schet-t.contract-code    = bfrr_arh-fin-doc-contr-schet-tax.contract-code    and
                                                 rbfrr_arh-fin-doc-contr-schet-t.cli-type         = parreceiver-type                                  and
                                                 rbfrr_arh-fin-doc-contr-schet-t.cli-code         = parreceiver-code                                  and
                                                 rbfrr_arh-fin-doc-contr-schet-t.code-schet       = bfrr_arh-fin-doc-contr-schet-tax.code-schet       and
                                                 rbfrr_arh-fin-doc-contr-schet-t.fin-ext-doc-type = bfrr_arh-fin-doc-contr-schet-tax.fin-ext-doc-type and
                                                 rbfrr_arh-fin-doc-contr-schet-t.calc-curr-code   = bfrr_arh-fin-doc-contr-schet-tax.calc-curr-code   and
                                                 rbfrr_arh-fin-doc-contr-schet-t.vat-pc           = bfrr_arh-fin-doc-contr-schet-tax.vat-pc           and
                                                 rbfrr_arh-fin-doc-contr-schet-t.slt-pc           = bfrr_arh-fin-doc-contr-schet-tax.slt-pc           and
                                                 rbfrr_arh-fin-doc-contr-schet-t.with-vat         = bfrr_arh-fin-doc-contr-schet-tax.with-vat         and
                                                 rbfrr_arh-fin-doc-contr-schet-t.with-slt         = bfrr_arh-fin-doc-contr-schet-tax.with-slt         and
                                                 rbfrr_arh-fin-doc-contr-schet-t.sum-type         = bfrr_arh-fin-doc-contr-schet-tax.sum-type         and
                                                 rbfrr_arh-fin-doc-contr-schet-t.fact-order       > bfrr_arh-fin-doc-contr-schet-tax.fact-order       use-index pi exclusive-lock on error undo, return error return-value :
    assign
      rbfrr_arh-fin-doc-contr-schet-t.income     = rbfrr_arh-fin-doc-contr-schet-t.income     + parsum-rubl
      rbfrr_arh-fin-doc-contr-schet-t.income-vat = rbfrr_arh-fin-doc-contr-schet-t.income-vat + parsum-vat-rubl
      rbfrr_arh-fin-doc-contr-schet-t.income-slt = rbfrr_arh-fin-doc-contr-schet-t.income-slt + parsum-slt-rubl
    .
  end.
  if parmode = "delete":u then do:
    delete bfpr_arh-fin-doc-contr-schet-tax.
    delete bfrr_arh-fin-doc-contr-schet-tax.
  end.
end.
if parbase-code <> parcurr-code and
   parbase-code <> 0            then do:
  if parmode = "close":u then do:
    find last bopb_arh-fin-doc-contr-schet-tax where bopb_arh-fin-doc-contr-schet-tax.host-code        = parhost-code         and
                                                     bopb_arh-fin-doc-contr-schet-tax.contract-code    = parcontract-code     and
                                                     bopb_arh-fin-doc-contr-schet-tax.cli-type         = parpayer-type        and
                                                     bopb_arh-fin-doc-contr-schet-tax.cli-code         = parpayer-code        and
                                                     bopb_arh-fin-doc-contr-schet-tax.code-schet       = parpayer-code-schet  and
                                                     bopb_arh-fin-doc-contr-schet-tax.fin-ext-doc-type = parfin-ext-doc-type  and
                                                     bopb_arh-fin-doc-contr-schet-tax.calc-curr-code   = parbase-code         and
                                                     bopb_arh-fin-doc-contr-schet-tax.vat-pc           = parvat-pc            and
                                                     bopb_arh-fin-doc-contr-schet-tax.slt-pc           = parslt-pc            and
                                                     bopb_arh-fin-doc-contr-schet-tax.with-vat         = parwith-vat          and
                                                     bopb_arh-fin-doc-contr-schet-tax.with-slt         = parwith-slt          and
                                                     bopb_arh-fin-doc-contr-schet-tax.sum-type         = parsum-type          and
                                                     bopb_arh-fin-doc-contr-schet-tax.fact-order       < parfact-order        use-index pi no-error.
    create bfpb_arh-fin-doc-contr-schet-tax.
    assign
      bfpb_arh-fin-doc-contr-schet-tax.host-code        = parhost-code
      bfpb_arh-fin-doc-contr-schet-tax.contract-code    = parcontract-code
      bfpb_arh-fin-doc-contr-schet-tax.cli-type         = parpayer-type
      bfpb_arh-fin-doc-contr-schet-tax.cli-code         = parpayer-code
      bfpb_arh-fin-doc-contr-schet-tax.code-schet       = parpayer-code-schet
      bfpb_arh-fin-doc-contr-schet-tax.fin-ext-doc-type = parfin-ext-doc-type
      bfpb_arh-fin-doc-contr-schet-tax.calc-curr-code   = parbase-code
      bfpb_arh-fin-doc-contr-schet-tax.vat-pc           = parvat-pc
      bfpb_arh-fin-doc-contr-schet-tax.slt-pc           = parslt-pc
      bfpb_arh-fin-doc-contr-schet-tax.with-vat         = parwith-vat
      bfpb_arh-fin-doc-contr-schet-tax.with-slt         = parwith-slt
      bfpb_arh-fin-doc-contr-schet-tax.sum-type         = parsum-type
      bfpb_arh-fin-doc-contr-schet-tax.cource-des       = "b":u
      bfpb_arh-fin-doc-contr-schet-tax.fact-order       = parfact-order
      bfpb_arh-fin-doc-contr-schet-tax.fin-doc-code     = parfin-doc-code
      bfpb_arh-fin-doc-contr-schet-tax.fact-date        = parfact-date
      bfpb_arh-fin-doc-contr-schet-tax.curr-code        = parcurr-code
      bfpb_arh-fin-doc-contr-schet-tax.income           = (if available bopb_arh-fin-doc-contr-schet-tax then bopb_arh-fin-doc-contr-schet-tax.income      else 0)
      bfpb_arh-fin-doc-contr-schet-tax.income-vat       = (if available bopb_arh-fin-doc-contr-schet-tax then bopb_arh-fin-doc-contr-schet-tax.income-vat  else 0)
      bfpb_arh-fin-doc-contr-schet-tax.income-slt       = (if available bopb_arh-fin-doc-contr-schet-tax then bopb_arh-fin-doc-contr-schet-tax.income-slt  else 0)
      bfpb_arh-fin-doc-contr-schet-tax.expense          = (if available bopb_arh-fin-doc-contr-schet-tax then bopb_arh-fin-doc-contr-schet-tax.expense     else 0) + parsum-base
      bfpb_arh-fin-doc-contr-schet-tax.expense-vat      = (if available bopb_arh-fin-doc-contr-schet-tax then bopb_arh-fin-doc-contr-schet-tax.expense-vat else 0) + parsum-vat-base
      bfpb_arh-fin-doc-contr-schet-tax.expense-slt      = (if available bopb_arh-fin-doc-contr-schet-tax then bopb_arh-fin-doc-contr-schet-tax.expense-slt else 0) + parsum-slt-base
    .
  end.
  else do:
    find first bfpb_arh-fin-doc-contr-schet-tax where bfpb_arh-fin-doc-contr-schet-tax.host-code        = parhost-code         and
                                                      bfpb_arh-fin-doc-contr-schet-tax.contract-code    = parcontract-code     and
                                                      bfpb_arh-fin-doc-contr-schet-tax.cli-type         = parpayer-type        and
                                                      bfpb_arh-fin-doc-contr-schet-tax.cli-code         = parpayer-code        and
                                                      bfpb_arh-fin-doc-contr-schet-tax.code-schet       = parpayer-code-schet  and
                                                      bfpb_arh-fin-doc-contr-schet-tax.fin-ext-doc-type = parfin-ext-doc-type  and
                                                      bfpb_arh-fin-doc-contr-schet-tax.calc-curr-code   = parbase-code         and
                                                      bfpb_arh-fin-doc-contr-schet-tax.vat-pc           = parvat-pc            and
                                                      bfpb_arh-fin-doc-contr-schet-tax.slt-pc           = parslt-pc            and
                                                      bfpb_arh-fin-doc-contr-schet-tax.with-vat         = parwith-vat          and
                                                      bfpb_arh-fin-doc-contr-schet-tax.with-slt         = parwith-slt          and
                                                      bfpb_arh-fin-doc-contr-schet-tax.sum-type         = parsum-type          and
                                                      bfpb_arh-fin-doc-contr-schet-tax.fact-order       = parfact-order        exclusive-lock.
  end.
  for each rbfpb_arh-fin-doc-contr-schet-t where rbfpb_arh-fin-doc-contr-schet-t.host-code        = bfpb_arh-fin-doc-contr-schet-tax.host-code        and
                                                 rbfpb_arh-fin-doc-contr-schet-t.contract-code    = bfpb_arh-fin-doc-contr-schet-tax.contract-code    and
                                                 rbfpb_arh-fin-doc-contr-schet-t.cli-type         = parpayer-type                                     and
                                                 rbfpb_arh-fin-doc-contr-schet-t.cli-code         = parpayer-code                                     and
                                                 rbfpb_arh-fin-doc-contr-schet-t.code-schet       = bfpb_arh-fin-doc-contr-schet-tax.code-schet       and
                                                 rbfpb_arh-fin-doc-contr-schet-t.fin-ext-doc-type = bfpb_arh-fin-doc-contr-schet-tax.fin-ext-doc-type and
                                                 rbfpb_arh-fin-doc-contr-schet-t.calc-curr-code   = bfpb_arh-fin-doc-contr-schet-tax.calc-curr-code   and
                                                 rbfpb_arh-fin-doc-contr-schet-t.vat-pc           = bfpb_arh-fin-doc-contr-schet-tax.vat-pc           and
                                                 rbfpb_arh-fin-doc-contr-schet-t.slt-pc           = bfpb_arh-fin-doc-contr-schet-tax.slt-pc           and
                                                 rbfpb_arh-fin-doc-contr-schet-t.with-vat         = bfpb_arh-fin-doc-contr-schet-tax.with-vat         and
                                                 rbfpb_arh-fin-doc-contr-schet-t.with-slt         = bfpb_arh-fin-doc-contr-schet-tax.with-slt         and
                                                 rbfpb_arh-fin-doc-contr-schet-t.sum-type         = bfpb_arh-fin-doc-contr-schet-tax.sum-type         and
                                                 rbfpb_arh-fin-doc-contr-schet-t.fact-order       > bfpb_arh-fin-doc-contr-schet-tax.fact-order       use-index pi exclusive-lock on error undo, return error return-value :
    assign
      rbfpb_arh-fin-doc-contr-schet-t.expense     = rbfpb_arh-fin-doc-contr-schet-t.expense     + parsum-base
      rbfpb_arh-fin-doc-contr-schet-t.expense-vat = rbfpb_arh-fin-doc-contr-schet-t.expense-vat + parsum-vat-base
      rbfpb_arh-fin-doc-contr-schet-t.expense-slt = rbfpb_arh-fin-doc-contr-schet-t.expense-slt + parsum-slt-base
    .
  end.
  if parmode = "close":u then do:
    find last borb_arh-fin-doc-contr-schet-tax where borb_arh-fin-doc-contr-schet-tax.host-code        = parhost-code            and
                                                     borb_arh-fin-doc-contr-schet-tax.contract-code    = parcontract-code        and
                                                     borb_arh-fin-doc-contr-schet-tax.cli-type         = parreceiver-type        and
                                                     borb_arh-fin-doc-contr-schet-tax.cli-code         = parreceiver-code        and
                                                     borb_arh-fin-doc-contr-schet-tax.code-schet       = parreceiver-code-schet  and
                                                     borb_arh-fin-doc-contr-schet-tax.fin-ext-doc-type = parfin-ext-doc-type     and
                                                     borb_arh-fin-doc-contr-schet-tax.calc-curr-code   = parbase-code            and
                                                     borb_arh-fin-doc-contr-schet-tax.vat-pc           = parvat-pc               and
                                                     borb_arh-fin-doc-contr-schet-tax.slt-pc           = parslt-pc               and
                                                     borb_arh-fin-doc-contr-schet-tax.with-vat         = parwith-vat             and
                                                     borb_arh-fin-doc-contr-schet-tax.with-slt         = parwith-slt             and
                                                     borb_arh-fin-doc-contr-schet-tax.sum-type         = parsum-type             use-index pi no-error.
    create bfrb_arh-fin-doc-contr-schet-tax.
    assign
      bfrb_arh-fin-doc-contr-schet-tax.host-code        = parhost-code
      bfrb_arh-fin-doc-contr-schet-tax.contract-code    = parcontract-code
      bfrb_arh-fin-doc-contr-schet-tax.cli-type         = parreceiver-type
      bfrb_arh-fin-doc-contr-schet-tax.cli-code         = parreceiver-code
      bfrb_arh-fin-doc-contr-schet-tax.code-schet       = parreceiver-code-schet
      bfrb_arh-fin-doc-contr-schet-tax.fin-ext-doc-type = parfin-ext-doc-type
      bfrb_arh-fin-doc-contr-schet-tax.calc-curr-code   = parbase-code
      bfrb_arh-fin-doc-contr-schet-tax.vat-pc           = parvat-pc
      bfrb_arh-fin-doc-contr-schet-tax.slt-pc           = parslt-pc
      bfrb_arh-fin-doc-contr-schet-tax.with-vat         = parwith-vat
      bfrb_arh-fin-doc-contr-schet-tax.with-slt         = parwith-slt
      bfrb_arh-fin-doc-contr-schet-tax.sum-type         = parsum-type
      bfrb_arh-fin-doc-contr-schet-tax.cource-des       = "b":u
      bfrb_arh-fin-doc-contr-schet-tax.fact-order       = parfact-order
      bfrb_arh-fin-doc-contr-schet-tax.fin-doc-code     = parfin-doc-code
      bfrb_arh-fin-doc-contr-schet-tax.fact-date        = parfact-date
      bfrb_arh-fin-doc-contr-schet-tax.curr-code        = parcurr-code
    .
    assign
      bfrb_arh-fin-doc-contr-schet-tax.expense          = (if available borb_arh-fin-doc-contr-schet-tax then borb_arh-fin-doc-contr-schet-tax.expense     else 0)
      bfrb_arh-fin-doc-contr-schet-tax.expense-vat      = (if available borb_arh-fin-doc-contr-schet-tax then borb_arh-fin-doc-contr-schet-tax.expense-vat else 0)
      bfrb_arh-fin-doc-contr-schet-tax.expense-slt      = (if available borb_arh-fin-doc-contr-schet-tax then borb_arh-fin-doc-contr-schet-tax.expense-slt else 0)
      bfrb_arh-fin-doc-contr-schet-tax.income           = (if available borb_arh-fin-doc-contr-schet-tax then borb_arh-fin-doc-contr-schet-tax.income      else 0) + parsum-base
      bfrb_arh-fin-doc-contr-schet-tax.income-vat       = (if available borb_arh-fin-doc-contr-schet-tax then borb_arh-fin-doc-contr-schet-tax.income-vat  else 0) + parsum-vat-base
      bfrb_arh-fin-doc-contr-schet-tax.income-slt       = (if available borb_arh-fin-doc-contr-schet-tax then borb_arh-fin-doc-contr-schet-tax.income-slt  else 0) + parsum-slt-base
    .
  end.
  else do:
    find first bfrb_arh-fin-doc-contr-schet-tax where bfrb_arh-fin-doc-contr-schet-tax.host-code        = parhost-code            and
                                                      bfrb_arh-fin-doc-contr-schet-tax.contract-code    = parcontract-code        and
                                                      bfrb_arh-fin-doc-contr-schet-tax.cli-type         = parreceiver-type        and
                                                      bfrb_arh-fin-doc-contr-schet-tax.cli-code         = parreceiver-code        and
                                                      bfrb_arh-fin-doc-contr-schet-tax.code-schet       = parreceiver-code-schet  and
                                                      bfrb_arh-fin-doc-contr-schet-tax.fin-ext-doc-type = parfin-ext-doc-type     and
                                                      bfrb_arh-fin-doc-contr-schet-tax.calc-curr-code   = parbase-code            and
                                                      bfrb_arh-fin-doc-contr-schet-tax.vat-pc           = parvat-pc               and
                                                      bfrb_arh-fin-doc-contr-schet-tax.slt-pc           = parslt-pc               and
                                                      bfrb_arh-fin-doc-contr-schet-tax.with-vat         = parwith-vat             and
                                                      bfrb_arh-fin-doc-contr-schet-tax.with-slt         = parwith-slt             and
                                                      bfrb_arh-fin-doc-contr-schet-tax.sum-type         = parsum-type             and
                                                      bfrb_arh-fin-doc-contr-schet-tax.fact-order       = parfact-order           exclusive-lock.
  end.
  for each rbfrb_arh-fin-doc-contr-schet-t where rbfrb_arh-fin-doc-contr-schet-t.host-code        = bfrb_arh-fin-doc-contr-schet-tax.host-code        and
                                                 rbfrb_arh-fin-doc-contr-schet-t.contract-code    = bfrb_arh-fin-doc-contr-schet-tax.contract-code    and
                                                 rbfrb_arh-fin-doc-contr-schet-t.cli-type         = parreceiver-type                                  and
                                                 rbfrb_arh-fin-doc-contr-schet-t.cli-code         = parreceiver-code                                  and
                                                 rbfrb_arh-fin-doc-contr-schet-t.code-schet       = bfrb_arh-fin-doc-contr-schet-tax.code-schet       and
                                                 rbfrb_arh-fin-doc-contr-schet-t.fin-ext-doc-type = bfrb_arh-fin-doc-contr-schet-tax.fin-ext-doc-type and
                                                 rbfrb_arh-fin-doc-contr-schet-t.calc-curr-code   = bfrb_arh-fin-doc-contr-schet-tax.calc-curr-code   and
                                                 rbfrb_arh-fin-doc-contr-schet-t.vat-pc           = bfrb_arh-fin-doc-contr-schet-tax.vat-pc           and
                                                 rbfrb_arh-fin-doc-contr-schet-t.slt-pc           = bfrb_arh-fin-doc-contr-schet-tax.slt-pc           and
                                                 rbfrb_arh-fin-doc-contr-schet-t.with-vat         = bfrb_arh-fin-doc-contr-schet-tax.with-vat         and
                                                 rbfrb_arh-fin-doc-contr-schet-t.with-slt         = bfrb_arh-fin-doc-contr-schet-tax.with-slt         and
                                                 rbfrb_arh-fin-doc-contr-schet-t.sum-type         = bfrb_arh-fin-doc-contr-schet-tax.sum-type         and
                                                 rbfrb_arh-fin-doc-contr-schet-t.fact-order       > bfrb_arh-fin-doc-contr-schet-tax.fact-order       use-index pi exclusive-lock on error undo, return error return-value :
    assign
      rbfrb_arh-fin-doc-contr-schet-t.income     = rbfrb_arh-fin-doc-contr-schet-t.income     + parsum-base
      rbfrb_arh-fin-doc-contr-schet-t.income-vat = rbfrb_arh-fin-doc-contr-schet-t.income-vat + parsum-vat-base
      rbfrb_arh-fin-doc-contr-schet-t.income-slt = rbfrb_arh-fin-doc-contr-schet-t.income-slt + parsum-slt-base
    .
  end.
  if parmode = "delete":u then do:
    delete bfpb_arh-fin-doc-contr-schet-tax.
    delete bfrb_arh-fin-doc-contr-schet-tax.
  end.
end.
if parrel-dog-code  =  yes          and
   parcurr-dog-code <> parcurr-code and
   parcurr-dog-code <> 0            and
   parcurr-dog-code <> parbase-code then do:
  if parmode = "close":u then do:
    find last bopc_arh-fin-doc-contr-schet-tax where bopc_arh-fin-doc-contr-schet-tax.host-code        = parhost-code         and
                                                     bopc_arh-fin-doc-contr-schet-tax.contract-code    = parcontract-code     and
                                                     bopc_arh-fin-doc-contr-schet-tax.cli-type         = parpayer-type        and
                                                     bopc_arh-fin-doc-contr-schet-tax.cli-code         = parpayer-code        and
                                                     bopc_arh-fin-doc-contr-schet-tax.code-schet       = parpayer-code-schet  and
                                                     bopc_arh-fin-doc-contr-schet-tax.fin-ext-doc-type = parfin-ext-doc-type  and
                                                     bopc_arh-fin-doc-contr-schet-tax.calc-curr-code   = parcurr-dog-code     and
                                                     bopc_arh-fin-doc-contr-schet-tax.vat-pc           = parvat-pc            and
                                                     bopc_arh-fin-doc-contr-schet-tax.slt-pc           = parslt-pc            and
                                                     bopc_arh-fin-doc-contr-schet-tax.with-vat         = parwith-vat          and
                                                     bopc_arh-fin-doc-contr-schet-tax.with-slt         = parwith-slt          and
                                                     bopc_arh-fin-doc-contr-schet-tax.sum-type         = parsum-type          and
                                                     bopc_arh-fin-doc-contr-schet-tax.fact-order       < parfact-order        use-index pi no-error.
    create bfpc_arh-fin-doc-contr-schet-tax.
    assign
      bfpc_arh-fin-doc-contr-schet-tax.host-code        = parhost-code
      bfpc_arh-fin-doc-contr-schet-tax.contract-code    = parcontract-code
      bfpc_arh-fin-doc-contr-schet-tax.cli-type         = parpayer-type
      bfpc_arh-fin-doc-contr-schet-tax.cli-code         = parpayer-code
      bfpc_arh-fin-doc-contr-schet-tax.code-schet       = parpayer-code-schet
      bfpc_arh-fin-doc-contr-schet-tax.fin-ext-doc-type = parfin-ext-doc-type
      bfpc_arh-fin-doc-contr-schet-tax.calc-curr-code   = parcurr-dog-code
      bfpc_arh-fin-doc-contr-schet-tax.vat-pc           = parvat-pc
      bfpc_arh-fin-doc-contr-schet-tax.slt-pc           = parslt-pc
      bfpc_arh-fin-doc-contr-schet-tax.with-vat         = parwith-vat
      bfpc_arh-fin-doc-contr-schet-tax.with-slt         = parwith-slt
      bfpc_arh-fin-doc-contr-schet-tax.sum-type         = parsum-type
      bfpc_arh-fin-doc-contr-schet-tax.cource-des       = "c":u
      bfpc_arh-fin-doc-contr-schet-tax.fact-order       = parfact-order
      bfpc_arh-fin-doc-contr-schet-tax.fin-doc-code     = parfin-doc-code
      bfpc_arh-fin-doc-contr-schet-tax.fact-date        = parfact-date
      bfpc_arh-fin-doc-contr-schet-tax.curr-code        = parcurr-code
      bfpc_arh-fin-doc-contr-schet-tax.income           = (if available bopc_arh-fin-doc-contr-schet-tax then bopc_arh-fin-doc-contr-schet-tax.income      else 0)
      bfpc_arh-fin-doc-contr-schet-tax.income-vat       = (if available bopc_arh-fin-doc-contr-schet-tax then bopc_arh-fin-doc-contr-schet-tax.income-vat  else 0)
      bfpc_arh-fin-doc-contr-schet-tax.income-slt       = (if available bopc_arh-fin-doc-contr-schet-tax then bopc_arh-fin-doc-contr-schet-tax.income-slt  else 0)
      bfpc_arh-fin-doc-contr-schet-tax.expense          = (if available bopc_arh-fin-doc-contr-schet-tax then bopc_arh-fin-doc-contr-schet-tax.expense     else 0) + parsum-contr
      bfpc_arh-fin-doc-contr-schet-tax.expense-vat      = (if available bopc_arh-fin-doc-contr-schet-tax then bopc_arh-fin-doc-contr-schet-tax.expense-vat else 0) + parsum-vat-contr
      bfpc_arh-fin-doc-contr-schet-tax.expense-slt      = (if available bopc_arh-fin-doc-contr-schet-tax then bopc_arh-fin-doc-contr-schet-tax.expense-slt else 0) + parsum-slt-contr
    .
  end.
  else do:
    find first bfpc_arh-fin-doc-contr-schet-tax where bfpc_arh-fin-doc-contr-schet-tax.host-code        = parhost-code         and
                                                      bfpc_arh-fin-doc-contr-schet-tax.contract-code    = parcontract-code     and
                                                      bfpc_arh-fin-doc-contr-schet-tax.cli-type         = parpayer-type        and
                                                      bfpc_arh-fin-doc-contr-schet-tax.cli-code         = parpayer-code        and
                                                      bfpc_arh-fin-doc-contr-schet-tax.code-schet       = parpayer-code-schet  and
                                                      bfpc_arh-fin-doc-contr-schet-tax.fin-ext-doc-type = parfin-ext-doc-type  and
                                                      bfpc_arh-fin-doc-contr-schet-tax.calc-curr-code   = parcurr-dog-code     and
                                                      bfpc_arh-fin-doc-contr-schet-tax.vat-pc           = parvat-pc            and
                                                      bfpc_arh-fin-doc-contr-schet-tax.slt-pc           = parslt-pc            and
                                                      bfpc_arh-fin-doc-contr-schet-tax.with-vat         = parwith-vat          and
                                                      bfpc_arh-fin-doc-contr-schet-tax.with-slt         = parwith-slt          and
                                                      bfpc_arh-fin-doc-contr-schet-tax.sum-type         = parsum-type          and
                                                      bfpc_arh-fin-doc-contr-schet-tax.fact-order       = parfact-order        exclusive-lock.
  end.
  for each rbfpc_arh-fin-doc-contr-schet-t where rbfpc_arh-fin-doc-contr-schet-t.host-code        = bfpc_arh-fin-doc-contr-schet-tax.host-code        and
                                                 rbfpc_arh-fin-doc-contr-schet-t.contract-code    = bfpc_arh-fin-doc-contr-schet-tax.contract-code    and
                                                 rbfpc_arh-fin-doc-contr-schet-t.cli-type         = parpayer-type                                     and
                                                 rbfpc_arh-fin-doc-contr-schet-t.cli-code         = parpayer-code                                     and
                                                 rbfpc_arh-fin-doc-contr-schet-t.code-schet       = bfpc_arh-fin-doc-contr-schet-tax.code-schet       and
                                                 rbfpc_arh-fin-doc-contr-schet-t.fin-ext-doc-type = bfpc_arh-fin-doc-contr-schet-tax.fin-ext-doc-type and
                                                 rbfpc_arh-fin-doc-contr-schet-t.calc-curr-code   = bfpc_arh-fin-doc-contr-schet-tax.calc-curr-code   and
                                                 rbfpc_arh-fin-doc-contr-schet-t.vat-pc           = bfpc_arh-fin-doc-contr-schet-tax.vat-pc           and
                                                 rbfpc_arh-fin-doc-contr-schet-t.slt-pc           = bfpc_arh-fin-doc-contr-schet-tax.slt-pc           and
                                                 rbfpc_arh-fin-doc-contr-schet-t.with-vat         = bfpc_arh-fin-doc-contr-schet-tax.with-vat         and
                                                 rbfpc_arh-fin-doc-contr-schet-t.with-slt         = bfpc_arh-fin-doc-contr-schet-tax.with-slt         and
                                                 rbfpc_arh-fin-doc-contr-schet-t.sum-type         = bfpc_arh-fin-doc-contr-schet-tax.sum-type         and
                                                 rbfpc_arh-fin-doc-contr-schet-t.fact-order       > bfpc_arh-fin-doc-contr-schet-tax.fact-order       use-index pi exclusive-lock on error undo, return error return-value :
    assign
      rbfpc_arh-fin-doc-contr-schet-t.expense     = rbfpc_arh-fin-doc-contr-schet-t.expense     + parsum-contr
      rbfpc_arh-fin-doc-contr-schet-t.expense-vat = rbfpc_arh-fin-doc-contr-schet-t.expense-vat + parsum-vat-contr
      rbfpc_arh-fin-doc-contr-schet-t.expense-slt = rbfpc_arh-fin-doc-contr-schet-t.expense-slt + parsum-slt-contr
    .
  end.
  if parmode = "close":u then do:
    find last borc_arh-fin-doc-contr-schet-tax where borc_arh-fin-doc-contr-schet-tax.host-code        = parhost-code           and
                                                     borc_arh-fin-doc-contr-schet-tax.contract-code    = parcontract-code       and
                                                     borc_arh-fin-doc-contr-schet-tax.cli-type         = parreceiver-type       and
                                                     borc_arh-fin-doc-contr-schet-tax.cli-code         = parreceiver-code       and
                                                     borc_arh-fin-doc-contr-schet-tax.code-schet       = parreceiver-code-schet and
                                                     borc_arh-fin-doc-contr-schet-tax.fin-ext-doc-type = parfin-ext-doc-type    and
                                                     borc_arh-fin-doc-contr-schet-tax.calc-curr-code   = parcurr-dog-code       and
                                                     borc_arh-fin-doc-contr-schet-tax.vat-pc           = parvat-pc              and
                                                     borc_arh-fin-doc-contr-schet-tax.slt-pc           = parslt-pc              and
                                                     borc_arh-fin-doc-contr-schet-tax.with-vat         = parwith-vat            and
                                                     borc_arh-fin-doc-contr-schet-tax.with-slt         = parwith-slt            and
                                                     borc_arh-fin-doc-contr-schet-tax.sum-type         = parsum-type            use-index pi no-error.
    create bfrc_arh-fin-doc-contr-schet-tax.
    assign
      bfrc_arh-fin-doc-contr-schet-tax.host-code        = parhost-code
      bfrc_arh-fin-doc-contr-schet-tax.contract-code    = parcontract-code
      bfrc_arh-fin-doc-contr-schet-tax.cli-type         = parreceiver-type
      bfrc_arh-fin-doc-contr-schet-tax.cli-code         = parreceiver-code
      bfrc_arh-fin-doc-contr-schet-tax.code-schet       = parreceiver-code-schet
      bfrc_arh-fin-doc-contr-schet-tax.fin-ext-doc-type = parfin-ext-doc-type
      bfrc_arh-fin-doc-contr-schet-tax.calc-curr-code   = parcurr-dog-code
      bfrc_arh-fin-doc-contr-schet-tax.vat-pc           = parvat-pc
      bfrc_arh-fin-doc-contr-schet-tax.slt-pc           = parslt-pc
      bfrc_arh-fin-doc-contr-schet-tax.with-vat         = parwith-vat
      bfrc_arh-fin-doc-contr-schet-tax.with-slt         = parwith-slt
      bfrc_arh-fin-doc-contr-schet-tax.sum-type         = parsum-type
      bfrc_arh-fin-doc-contr-schet-tax.cource-des       = "c":u
      bfrc_arh-fin-doc-contr-schet-tax.fact-order       = parfact-order
      bfrc_arh-fin-doc-contr-schet-tax.fin-doc-code     = parfin-doc-code
      bfrc_arh-fin-doc-contr-schet-tax.fact-date        = parfact-date
      bfrc_arh-fin-doc-contr-schet-tax.curr-code        = parcurr-code
    .
    assign
      bfrc_arh-fin-doc-contr-schet-tax.expense          = (if available borc_arh-fin-doc-contr-schet-tax then borc_arh-fin-doc-contr-schet-tax.expense     else 0)
      bfrc_arh-fin-doc-contr-schet-tax.expense-vat      = (if available borc_arh-fin-doc-contr-schet-tax then borc_arh-fin-doc-contr-schet-tax.expense-vat else 0)
      bfrc_arh-fin-doc-contr-schet-tax.expense-slt      = (if available borc_arh-fin-doc-contr-schet-tax then borc_arh-fin-doc-contr-schet-tax.expense-slt else 0)
      bfrc_arh-fin-doc-contr-schet-tax.income           = (if available borc_arh-fin-doc-contr-schet-tax then borc_arh-fin-doc-contr-schet-tax.income      else 0) + parsum-contr
      bfrc_arh-fin-doc-contr-schet-tax.income-vat       = (if available borc_arh-fin-doc-contr-schet-tax then borc_arh-fin-doc-contr-schet-tax.income-vat  else 0) + parsum-vat-contr
      bfrc_arh-fin-doc-contr-schet-tax.income-slt       = (if available borc_arh-fin-doc-contr-schet-tax then borc_arh-fin-doc-contr-schet-tax.income-slt  else 0) + parsum-slt-contr
    .
  end.
  else do:
    find first bfrc_arh-fin-doc-contr-schet-tax where bfrc_arh-fin-doc-contr-schet-tax.host-code        = parhost-code           and
                                                      bfrc_arh-fin-doc-contr-schet-tax.contract-code    = parcontract-code       and
                                                      bfrc_arh-fin-doc-contr-schet-tax.cli-type         = parreceiver-type       and
                                                      bfrc_arh-fin-doc-contr-schet-tax.cli-code         = parreceiver-code       and
                                                      bfrc_arh-fin-doc-contr-schet-tax.code-schet       = parreceiver-code-schet and
                                                      bfrc_arh-fin-doc-contr-schet-tax.fin-ext-doc-type = parfin-ext-doc-type    and
                                                      bfrc_arh-fin-doc-contr-schet-tax.calc-curr-code   = parcurr-dog-code       and
                                                      bfrc_arh-fin-doc-contr-schet-tax.vat-pc           = parvat-pc              and
                                                      bfrc_arh-fin-doc-contr-schet-tax.slt-pc           = parslt-pc              and
                                                      bfrc_arh-fin-doc-contr-schet-tax.with-vat         = parwith-vat            and
                                                      bfrc_arh-fin-doc-contr-schet-tax.with-slt         = parwith-slt            and
                                                      bfrc_arh-fin-doc-contr-schet-tax.sum-type         = parsum-type            and
                                                      bfrc_arh-fin-doc-contr-schet-tax.fact-order       = parfact-order          exclusive-lock.
  end.
  for each rbfrc_arh-fin-doc-contr-schet-t where rbfrc_arh-fin-doc-contr-schet-t.host-code        = bfrc_arh-fin-doc-contr-schet-tax.host-code        and
                                                 rbfrc_arh-fin-doc-contr-schet-t.contract-code    = bfrc_arh-fin-doc-contr-schet-tax.contract-code    and
                                                 rbfrc_arh-fin-doc-contr-schet-t.cli-type         = parreceiver-type                                  and
                                                 rbfrc_arh-fin-doc-contr-schet-t.cli-code         = parreceiver-code                                  and
                                                 rbfrc_arh-fin-doc-contr-schet-t.code-schet       = bfrc_arh-fin-doc-contr-schet-tax.code-schet       and
                                                 rbfrc_arh-fin-doc-contr-schet-t.fin-ext-doc-type = bfrc_arh-fin-doc-contr-schet-tax.fin-ext-doc-type and
                                                 rbfrc_arh-fin-doc-contr-schet-t.calc-curr-code   = bfrc_arh-fin-doc-contr-schet-tax.calc-curr-code   and
                                                 rbfrc_arh-fin-doc-contr-schet-t.vat-pc           = bfrc_arh-fin-doc-contr-schet-tax.vat-pc           and
                                                 rbfrc_arh-fin-doc-contr-schet-t.slt-pc           = bfrc_arh-fin-doc-contr-schet-tax.slt-pc           and
                                                 rbfrc_arh-fin-doc-contr-schet-t.with-vat         = bfrc_arh-fin-doc-contr-schet-tax.with-vat         and
                                                 rbfrc_arh-fin-doc-contr-schet-t.with-slt         = bfrc_arh-fin-doc-contr-schet-tax.with-slt         and
                                                 rbfrc_arh-fin-doc-contr-schet-t.sum-type         = bfrc_arh-fin-doc-contr-schet-tax.sum-type         and
                                                 rbfrc_arh-fin-doc-contr-schet-t.fact-order       > bfrc_arh-fin-doc-contr-schet-tax.fact-order       use-index pi exclusive-lock on error undo, return error return-value :
    assign
      rbfrc_arh-fin-doc-contr-schet-t.income     = rbfrc_arh-fin-doc-contr-schet-t.income     + parsum-contr
      rbfrc_arh-fin-doc-contr-schet-t.income-vat = rbfrc_arh-fin-doc-contr-schet-t.income-vat + parsum-vat-contr
      rbfrc_arh-fin-doc-contr-schet-t.income-slt = rbfrc_arh-fin-doc-contr-schet-t.income-slt + parsum-slt-contr
    .
  end.
  if parmode = "delete":u then do:
    delete bfpc_arh-fin-doc-contr-schet-tax.
    delete bfrc_arh-fin-doc-contr-schet-tax.
  end.
end.
end.
end procedure.

procedure libfarhp_calc-arh-fin-doc-schet :
define input parameter parmode                    as   character                   no-undo.
define input parameter parhost-code               like ub.fin-doc.host-code        no-undo.
define input parameter parpayer-type              like ub.fin-doc.payer-type       no-undo.
define input parameter parpayer-code              like ub.fin-doc.payer-code       no-undo.
define input parameter parreceiver-type           like ub.fin-doc.receiver-type    no-undo.
define input parameter parreceiver-code           like ub.fin-doc.receiver-code    no-undo.
define input parameter parpayer-code-schet        like ub.fin-schet.code-schet     no-undo.
define input parameter parreceiver-code-schet     like ub.fin-schet.code-schet     no-undo.
define input parameter parfin-ext-doc-type        like ub.fin-doc.fin-ext-doc-type no-undo.
define input parameter parsum-type                as   character                   no-undo.
define input parameter parfact-order              like ub.fin-doc.fact-order       no-undo.
define input parameter parfin-doc-code            like ub.fin-doc.fin-doc-code     no-undo.
define input parameter parfact-date               like ub.fin-doc.fact-date        no-undo.
define input parameter parcurr-code               like ub.fin-doc.curr-code        no-undo.
define input parameter parbase-code               like ub.sysconf.base-code        no-undo.
define input parameter parsum-doc                 as   decimal                     no-undo.
define input parameter parsum-rubl                as   decimal                     no-undo.
define input parameter parsum-base                as   decimal                     no-undo.
define input parameter parsum-vat-doc             as   decimal                     no-undo.
define input parameter parsum-vat-rubl            as   decimal                     no-undo.
define input parameter parsum-vat-base            as   decimal                     no-undo.
define input parameter parsum-slt-doc             as   decimal                     no-undo.
define input parameter parsum-slt-rubl            as   decimal                     no-undo.
define input parameter parsum-slt-base            as   decimal                     no-undo.
define buffer bfps_arh-fin-doc-schet  for ub.arh-fin-doc-schet.
define buffer bfrs_arh-fin-doc-schet  for ub.arh-fin-doc-schet.
define buffer rbfps_arh-fin-doc-schet for ub.arh-fin-doc-schet.
define buffer rbfrs_arh-fin-doc-schet for ub.arh-fin-doc-schet.
define buffer bops_arh-fin-doc-schet  for ub.arh-fin-doc-schet.
define buffer bors_arh-fin-doc-schet  for ub.arh-fin-doc-schet.
define buffer bfpr_arh-fin-doc-schet  for ub.arh-fin-doc-schet.
define buffer bfrr_arh-fin-doc-schet  for ub.arh-fin-doc-schet.
define buffer rbfpr_arh-fin-doc-schet for ub.arh-fin-doc-schet.
define buffer rbfrr_arh-fin-doc-schet for ub.arh-fin-doc-schet.
define buffer bopr_arh-fin-doc-schet  for ub.arh-fin-doc-schet.
define buffer borr_arh-fin-doc-schet  for ub.arh-fin-doc-schet.
define buffer bfpb_arh-fin-doc-schet  for ub.arh-fin-doc-schet.
define buffer bfrb_arh-fin-doc-schet  for ub.arh-fin-doc-schet.
define buffer rbfpb_arh-fin-doc-schet for ub.arh-fin-doc-schet.
define buffer rbfrb_arh-fin-doc-schet for ub.arh-fin-doc-schet.
define buffer bopb_arh-fin-doc-schet  for ub.arh-fin-doc-schet.
define buffer borb_arh-fin-doc-schet  for ub.arh-fin-doc-schet.
define buffer bfpc_arh-fin-doc-schet  for ub.arh-fin-doc-schet.
define buffer bfrc_arh-fin-doc-schet  for ub.arh-fin-doc-schet.
define buffer rbfpc_arh-fin-doc-schet for ub.arh-fin-doc-schet.
define buffer rbfrc_arh-fin-doc-schet for ub.arh-fin-doc-schet.
define buffer bopc_arh-fin-doc-schet  for ub.arh-fin-doc-schet.
define buffer borc_arh-fin-doc-schet  for ub.arh-fin-doc-schet.
do on error undo, return error substitute ("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
if parpayer-code <> 0 then do:
if parmode = "close":u then do:
  find last bops_arh-fin-doc-schet where bops_arh-fin-doc-schet.host-code        = parhost-code         and
                                         bops_arh-fin-doc-schet.cli-type         = parpayer-type        and
                                         bops_arh-fin-doc-schet.cli-code         = parpayer-code        and
                                         bops_arh-fin-doc-schet.code-schet       = parpayer-code-schet  and
                                         bops_arh-fin-doc-schet.fin-ext-doc-type = parfin-ext-doc-type  and
                                         bops_arh-fin-doc-schet.calc-curr-code   = parcurr-code         and
                                         bops_arh-fin-doc-schet.sum-type         = parsum-type          and
                                         bops_arh-fin-doc-schet.fact-order       < parfact-order        use-index pi no-error.
  create bfps_arh-fin-doc-schet.
  assign
    bfps_arh-fin-doc-schet.host-code        = parhost-code
    bfps_arh-fin-doc-schet.cli-type         = parpayer-type
    bfps_arh-fin-doc-schet.cli-code         = parpayer-code
    bfps_arh-fin-doc-schet.code-schet       = parpayer-code-schet
    bfps_arh-fin-doc-schet.fin-ext-doc-type = parfin-ext-doc-type
    bfps_arh-fin-doc-schet.calc-curr-code   = parcurr-code
    bfps_arh-fin-doc-schet.sum-type         = parsum-type
    bfps_arh-fin-doc-schet.cource-des       = "s":u
    bfps_arh-fin-doc-schet.fact-order       = parfact-order
    bfps_arh-fin-doc-schet.fin-doc-code     = parfin-doc-code
    bfps_arh-fin-doc-schet.fact-date        = parfact-date
    bfps_arh-fin-doc-schet.curr-code        = parcurr-code
    bfps_arh-fin-doc-schet.income           = (if available bops_arh-fin-doc-schet then bops_arh-fin-doc-schet.income      else 0)
    bfps_arh-fin-doc-schet.income-vat       = (if available bops_arh-fin-doc-schet then bops_arh-fin-doc-schet.income-vat  else 0)
    bfps_arh-fin-doc-schet.income-slt       = (if available bops_arh-fin-doc-schet then bops_arh-fin-doc-schet.income-slt  else 0)
    bfps_arh-fin-doc-schet.expense          = (if available bops_arh-fin-doc-schet then bops_arh-fin-doc-schet.expense     else 0) + parsum-doc
    bfps_arh-fin-doc-schet.expense-vat      = (if available bops_arh-fin-doc-schet then bops_arh-fin-doc-schet.expense-vat else 0) + parsum-vat-doc
    bfps_arh-fin-doc-schet.expense-slt      = (if available bops_arh-fin-doc-schet then bops_arh-fin-doc-schet.expense-slt else 0) + parsum-slt-doc
  .
end.
else do:
  find first bfps_arh-fin-doc-schet where bfps_arh-fin-doc-schet.host-code        = parhost-code         and
                                          bfps_arh-fin-doc-schet.cli-type         = parpayer-type        and
                                          bfps_arh-fin-doc-schet.cli-code         = parpayer-code        and
                                          bfps_arh-fin-doc-schet.code-schet       = parpayer-code-schet  and
                                          bfps_arh-fin-doc-schet.fin-ext-doc-type = parfin-ext-doc-type  and
                                          bfps_arh-fin-doc-schet.calc-curr-code   = parcurr-code         and
                                          bfps_arh-fin-doc-schet.sum-type         = parsum-type          and
                                          bfps_arh-fin-doc-schet.fact-order       = parfact-order        exclusive-lock.
end.
for each rbfps_arh-fin-doc-schet where rbfps_arh-fin-doc-schet.host-code        = bfps_arh-fin-doc-schet.host-code        and
                                       rbfps_arh-fin-doc-schet.cli-type         = parpayer-type                           and
                                       rbfps_arh-fin-doc-schet.cli-code         = parpayer-code                           and
                                       rbfps_arh-fin-doc-schet.code-schet       = bfps_arh-fin-doc-schet.code-schet       and
                                       rbfps_arh-fin-doc-schet.fin-ext-doc-type = bfps_arh-fin-doc-schet.fin-ext-doc-type and
                                       rbfps_arh-fin-doc-schet.calc-curr-code   = bfps_arh-fin-doc-schet.calc-curr-code   and
                                       rbfps_arh-fin-doc-schet.sum-type         = bfps_arh-fin-doc-schet.sum-type         and
                                       rbfps_arh-fin-doc-schet.fact-order       > bfps_arh-fin-doc-schet.fact-order       use-index pi exclusive-lock on error undo, return error return-value :
  assign
    rbfps_arh-fin-doc-schet.expense     = rbfps_arh-fin-doc-schet.expense     + parsum-doc
    rbfps_arh-fin-doc-schet.expense-vat = rbfps_arh-fin-doc-schet.expense-vat + parsum-vat-doc
    rbfps_arh-fin-doc-schet.expense-slt = rbfps_arh-fin-doc-schet.expense-slt + parsum-slt-doc
  .
end.
end.
if parreceiver-code <> 0 then do:
if parmode = "close":u then do:
  find last bors_arh-fin-doc-schet where bors_arh-fin-doc-schet.host-code        = parhost-code            and
                                         bors_arh-fin-doc-schet.cli-type         = parreceiver-type        and
                                         bors_arh-fin-doc-schet.cli-code         = parreceiver-code        and
                                         bors_arh-fin-doc-schet.code-schet       = parreceiver-code-schet  and
                                         bors_arh-fin-doc-schet.fin-ext-doc-type = parfin-ext-doc-type     and
                                         bors_arh-fin-doc-schet.calc-curr-code   = parcurr-code            and
                                         bors_arh-fin-doc-schet.sum-type         = parsum-type             and
                                         bors_arh-fin-doc-schet.fact-order       < parfact-order           use-index pi no-error.
  create bfrs_arh-fin-doc-schet.
  assign
    bfrs_arh-fin-doc-schet.host-code        = parhost-code
    bfrs_arh-fin-doc-schet.cli-type         = parreceiver-type
    bfrs_arh-fin-doc-schet.cli-code         = parreceiver-code
    bfrs_arh-fin-doc-schet.code-schet       = parreceiver-code-schet
    bfrs_arh-fin-doc-schet.fin-ext-doc-type = parfin-ext-doc-type
    bfrs_arh-fin-doc-schet.calc-curr-code   = parcurr-code
    bfrs_arh-fin-doc-schet.sum-type         = parsum-type
    bfrs_arh-fin-doc-schet.cource-des       = "s":u
    bfrs_arh-fin-doc-schet.fact-order       = parfact-order
    bfrs_arh-fin-doc-schet.fin-doc-code     = parfin-doc-code
    bfrs_arh-fin-doc-schet.fact-date        = parfact-date
    bfrs_arh-fin-doc-schet.curr-code        = parcurr-code
  .
  assign
    bfrs_arh-fin-doc-schet.expense          = (if available bors_arh-fin-doc-schet then bors_arh-fin-doc-schet.expense     else 0)
    bfrs_arh-fin-doc-schet.expense-vat      = (if available bors_arh-fin-doc-schet then bors_arh-fin-doc-schet.expense-vat else 0)
    bfrs_arh-fin-doc-schet.expense-slt      = (if available bors_arh-fin-doc-schet then bors_arh-fin-doc-schet.expense-slt else 0)
    bfrs_arh-fin-doc-schet.income           = (if available bors_arh-fin-doc-schet then bors_arh-fin-doc-schet.income      else 0) + parsum-doc
    bfrs_arh-fin-doc-schet.income-vat       = (if available bors_arh-fin-doc-schet then bors_arh-fin-doc-schet.income-vat  else 0) + parsum-vat-doc
    bfrs_arh-fin-doc-schet.income-slt       = (if available bors_arh-fin-doc-schet then bors_arh-fin-doc-schet.income-slt  else 0) + parsum-slt-doc
  .
end.
else do:
  find first bfrs_arh-fin-doc-schet where bfrs_arh-fin-doc-schet.host-code        = parhost-code            and
                                          bfrs_arh-fin-doc-schet.cli-type         = parreceiver-type        and
                                          bfrs_arh-fin-doc-schet.cli-code         = parreceiver-code        and
                                          bfrs_arh-fin-doc-schet.code-schet       = parreceiver-code-schet  and
                                          bfrs_arh-fin-doc-schet.fin-ext-doc-type = parfin-ext-doc-type     and
                                          bfrs_arh-fin-doc-schet.calc-curr-code   = parcurr-code            and
                                          bfrs_arh-fin-doc-schet.sum-type         = parsum-type             and
                                          bfrs_arh-fin-doc-schet.fact-order       = parfact-order           exclusive-lock.
end.
for each rbfrs_arh-fin-doc-schet where rbfrs_arh-fin-doc-schet.host-code        = bfrs_arh-fin-doc-schet.host-code        and
                                       rbfrs_arh-fin-doc-schet.cli-type         = parreceiver-type                        and
                                       rbfrs_arh-fin-doc-schet.cli-code         = parreceiver-code                        and
                                       rbfrs_arh-fin-doc-schet.code-schet       = bfrs_arh-fin-doc-schet.code-schet       and
                                       rbfrs_arh-fin-doc-schet.fin-ext-doc-type = bfrs_arh-fin-doc-schet.fin-ext-doc-type and
                                       rbfrs_arh-fin-doc-schet.calc-curr-code   = bfrs_arh-fin-doc-schet.calc-curr-code   and
                                       rbfrs_arh-fin-doc-schet.sum-type         = bfrs_arh-fin-doc-schet.sum-type         and
                                       rbfrs_arh-fin-doc-schet.fact-order       > bfrs_arh-fin-doc-schet.fact-order       use-index pi exclusive-lock on error undo, return error return-value :
  assign
    rbfrs_arh-fin-doc-schet.income     = rbfrs_arh-fin-doc-schet.income     + parsum-doc
    rbfrs_arh-fin-doc-schet.income-vat = rbfrs_arh-fin-doc-schet.income-vat + parsum-vat-doc
    rbfrs_arh-fin-doc-schet.income-slt = rbfrs_arh-fin-doc-schet.income-slt + parsum-slt-doc
  .
end.
end. /*if parreceiver-code <> 0 then do: */
if parmode = "delete":u then do:
  if parpayer-code <> 0 then do:
  delete bfps_arh-fin-doc-schet.
  end.
  if parreceiver-code <> 0 then do:
  delete bfrs_arh-fin-doc-schet.
end.
end.
if parcurr-code <> 0 then do:
if parpayer-code <> 0 then do:
  if parmode = "close":u then do:
    find last bopr_arh-fin-doc-schet where bopr_arh-fin-doc-schet.host-code        = parhost-code         and
                                           bopr_arh-fin-doc-schet.cli-type         = parpayer-type        and
                                           bopr_arh-fin-doc-schet.cli-code         = parpayer-code        and
                                           bopr_arh-fin-doc-schet.code-schet       = parpayer-code-schet  and
                                           bopr_arh-fin-doc-schet.fin-ext-doc-type = parfin-ext-doc-type  and
                                           bopr_arh-fin-doc-schet.calc-curr-code   = 0                    and
                                           bopr_arh-fin-doc-schet.sum-type         = parsum-type          and
                                           bopr_arh-fin-doc-schet.fact-order       < parfact-order        use-index pi no-error.
    create bfpr_arh-fin-doc-schet.
    assign
      bfpr_arh-fin-doc-schet.host-code        = parhost-code
      bfpr_arh-fin-doc-schet.cli-type         = parpayer-type
      bfpr_arh-fin-doc-schet.cli-code         = parpayer-code
      bfpr_arh-fin-doc-schet.code-schet       = parpayer-code-schet
      bfpr_arh-fin-doc-schet.fin-ext-doc-type = parfin-ext-doc-type
      bfpr_arh-fin-doc-schet.calc-curr-code   = 0
      bfpr_arh-fin-doc-schet.sum-type         = parsum-type
      bfpr_arh-fin-doc-schet.cource-des       = "r":u
      bfpr_arh-fin-doc-schet.fact-order       = parfact-order
      bfpr_arh-fin-doc-schet.fin-doc-code     = parfin-doc-code
      bfpr_arh-fin-doc-schet.fact-date        = parfact-date
      bfpr_arh-fin-doc-schet.curr-code        = parcurr-code
      bfpr_arh-fin-doc-schet.income           = (if available bopr_arh-fin-doc-schet then bopr_arh-fin-doc-schet.income      else 0)
      bfpr_arh-fin-doc-schet.income-vat       = (if available bopr_arh-fin-doc-schet then bopr_arh-fin-doc-schet.income-vat  else 0)
      bfpr_arh-fin-doc-schet.income-slt       = (if available bopr_arh-fin-doc-schet then bopr_arh-fin-doc-schet.income-slt  else 0)
      bfpr_arh-fin-doc-schet.expense          = (if available bopr_arh-fin-doc-schet then bopr_arh-fin-doc-schet.expense     else 0) + parsum-rubl
      bfpr_arh-fin-doc-schet.expense-vat      = (if available bopr_arh-fin-doc-schet then bopr_arh-fin-doc-schet.expense-vat else 0) + parsum-vat-rubl
      bfpr_arh-fin-doc-schet.expense-slt      = (if available bopr_arh-fin-doc-schet then bopr_arh-fin-doc-schet.expense-slt else 0) + parsum-slt-rubl
    .
  end.
  else do:
    find first bfpr_arh-fin-doc-schet where bfpr_arh-fin-doc-schet.host-code        = parhost-code         and
                                            bfpr_arh-fin-doc-schet.cli-type         = parpayer-type        and
                                            bfpr_arh-fin-doc-schet.cli-code         = parpayer-code        and
                                            bfpr_arh-fin-doc-schet.code-schet       = parpayer-code-schet  and
                                            bfpr_arh-fin-doc-schet.fin-ext-doc-type = parfin-ext-doc-type  and
                                            bfpr_arh-fin-doc-schet.calc-curr-code   = 0                    and
                                            bfpr_arh-fin-doc-schet.sum-type         = parsum-type          and
                                            bfpr_arh-fin-doc-schet.fact-order       = parfact-order        exclusive-lock.
  end.
  for each rbfpr_arh-fin-doc-schet where rbfpr_arh-fin-doc-schet.host-code        = bfpr_arh-fin-doc-schet.host-code        and
                                         rbfpr_arh-fin-doc-schet.cli-type         = parpayer-type                           and
                                         rbfpr_arh-fin-doc-schet.cli-code         = parpayer-code                           and
                                         rbfpr_arh-fin-doc-schet.code-schet       = bfpr_arh-fin-doc-schet.code-schet       and
                                         rbfpr_arh-fin-doc-schet.fin-ext-doc-type = bfpr_arh-fin-doc-schet.fin-ext-doc-type and
                                         rbfpr_arh-fin-doc-schet.calc-curr-code   = bfpr_arh-fin-doc-schet.calc-curr-code   and
                                         rbfpr_arh-fin-doc-schet.sum-type         = bfpr_arh-fin-doc-schet.sum-type         and
                                         rbfpr_arh-fin-doc-schet.fact-order       > bfpr_arh-fin-doc-schet.fact-order       use-index pi exclusive-lock on error undo, return error return-value :
    assign
      rbfpr_arh-fin-doc-schet.expense     = rbfpr_arh-fin-doc-schet.expense     + parsum-rubl
      rbfpr_arh-fin-doc-schet.expense-vat = rbfpr_arh-fin-doc-schet.expense-vat + parsum-vat-rubl
      rbfpr_arh-fin-doc-schet.expense-slt = rbfpr_arh-fin-doc-schet.expense-slt + parsum-slt-rubl
    .
  end.
  end. /*if parpayer-code <> 0 then do: */
  if parreceiver-code <> 0 then do:
  if parmode = "close":u then do:
    find last borr_arh-fin-doc-schet where borr_arh-fin-doc-schet.host-code        = parhost-code            and
                                           borr_arh-fin-doc-schet.cli-type         = parreceiver-type        and
                                           borr_arh-fin-doc-schet.cli-code         = parreceiver-code        and
                                           borr_arh-fin-doc-schet.code-schet       = parreceiver-code-schet  and
                                           borr_arh-fin-doc-schet.fin-ext-doc-type = parfin-ext-doc-type     and
                                           borr_arh-fin-doc-schet.calc-curr-code   = 0                       and
                                           borr_arh-fin-doc-schet.sum-type         = parsum-type             and
                                           borr_arh-fin-doc-schet.fact-order       < parfact-order           use-index pi no-error.
    create bfrr_arh-fin-doc-schet.
    assign
      bfrr_arh-fin-doc-schet.host-code        = parhost-code
      bfrr_arh-fin-doc-schet.cli-type         = parreceiver-type
      bfrr_arh-fin-doc-schet.cli-code         = parreceiver-code
      bfrr_arh-fin-doc-schet.code-schet       = parreceiver-code-schet
      bfrr_arh-fin-doc-schet.fin-ext-doc-type = parfin-ext-doc-type
      bfrr_arh-fin-doc-schet.calc-curr-code   = 0
      bfrr_arh-fin-doc-schet.sum-type         = parsum-type
      bfrr_arh-fin-doc-schet.cource-des       = "r":u
      bfrr_arh-fin-doc-schet.fact-order       = parfact-order
      bfrr_arh-fin-doc-schet.fin-doc-code     = parfin-doc-code
      bfrr_arh-fin-doc-schet.fact-date        = parfact-date
      bfrr_arh-fin-doc-schet.curr-code        = parcurr-code
    .
    assign
      bfrr_arh-fin-doc-schet.expense          = (if available borr_arh-fin-doc-schet then borr_arh-fin-doc-schet.expense     else 0)
      bfrr_arh-fin-doc-schet.expense-vat      = (if available borr_arh-fin-doc-schet then borr_arh-fin-doc-schet.expense-vat else 0)
      bfrr_arh-fin-doc-schet.expense-slt      = (if available borr_arh-fin-doc-schet then borr_arh-fin-doc-schet.expense-slt else 0)
      bfrr_arh-fin-doc-schet.income           = (if available borr_arh-fin-doc-schet then borr_arh-fin-doc-schet.income      else 0) + parsum-rubl
      bfrr_arh-fin-doc-schet.income-vat       = (if available borr_arh-fin-doc-schet then borr_arh-fin-doc-schet.income-vat  else 0) + parsum-vat-rubl
      bfrr_arh-fin-doc-schet.income-slt       = (if available borr_arh-fin-doc-schet then borr_arh-fin-doc-schet.income-slt  else 0) + parsum-slt-rubl
    .
  end.
  else do:
    find first bfrr_arh-fin-doc-schet where bfrr_arh-fin-doc-schet.host-code        = parhost-code            and
                                            bfrr_arh-fin-doc-schet.cli-type         = parreceiver-type        and
                                            bfrr_arh-fin-doc-schet.cli-code         = parreceiver-code        and
                                            bfrr_arh-fin-doc-schet.code-schet       = parreceiver-code-schet  and
                                            bfrr_arh-fin-doc-schet.fin-ext-doc-type = parfin-ext-doc-type     and
                                            bfrr_arh-fin-doc-schet.calc-curr-code   = 0                       and
                                            bfrr_arh-fin-doc-schet.sum-type         = parsum-type             and
                                            bfrr_arh-fin-doc-schet.fact-order       = parfact-order           exclusive-lock.
  end.
  for each rbfrr_arh-fin-doc-schet where rbfrr_arh-fin-doc-schet.host-code        = bfrr_arh-fin-doc-schet.host-code        and
                                         rbfrr_arh-fin-doc-schet.cli-type         = parreceiver-type                        and
                                         rbfrr_arh-fin-doc-schet.cli-code         = parreceiver-code                        and
                                         rbfrr_arh-fin-doc-schet.code-schet       = bfrr_arh-fin-doc-schet.code-schet       and
                                         rbfrr_arh-fin-doc-schet.fin-ext-doc-type = bfrr_arh-fin-doc-schet.fin-ext-doc-type and
                                         rbfrr_arh-fin-doc-schet.calc-curr-code   = bfrr_arh-fin-doc-schet.calc-curr-code   and
                                         rbfrr_arh-fin-doc-schet.sum-type         = bfrr_arh-fin-doc-schet.sum-type         and
                                         rbfrr_arh-fin-doc-schet.fact-order       > bfrr_arh-fin-doc-schet.fact-order       use-index pi exclusive-lock on error undo, return error return-value :
    assign
      rbfrr_arh-fin-doc-schet.income     = rbfrr_arh-fin-doc-schet.income     + parsum-rubl
      rbfrr_arh-fin-doc-schet.income-vat = rbfrr_arh-fin-doc-schet.income-vat + parsum-vat-rubl
      rbfrr_arh-fin-doc-schet.income-slt = rbfrr_arh-fin-doc-schet.income-slt + parsum-slt-rubl
    .
  end.
  if parmode = "delete":u then do:
    if parpayer-code <> 0 then do:
    delete bfpr_arh-fin-doc-schet.
    end.
    if parreceiver-code <> 0 then do:
    delete bfrr_arh-fin-doc-schet.
  end.
end.
  end. /*if parreceiver-code <> 0 then do:*/
end.
if parbase-code <> parcurr-code and
   parbase-code <> 0            then do:
  if parpayer-code <> 0 then do:
  if parmode = "close":u then do:
    find last bopb_arh-fin-doc-schet where bopb_arh-fin-doc-schet.host-code        = parhost-code         and
                                           bopb_arh-fin-doc-schet.cli-type         = parpayer-type        and
                                           bopb_arh-fin-doc-schet.cli-code         = parpayer-code        and
                                           bopb_arh-fin-doc-schet.code-schet       = parpayer-code-schet  and
                                           bopb_arh-fin-doc-schet.fin-ext-doc-type = parfin-ext-doc-type  and
                                           bopb_arh-fin-doc-schet.calc-curr-code   = parbase-code         and
                                           bopb_arh-fin-doc-schet.sum-type         = parsum-type          and
                                           bopb_arh-fin-doc-schet.fact-order       < parfact-order        use-index pi no-error.
    create bfpb_arh-fin-doc-schet.
    assign
      bfpb_arh-fin-doc-schet.host-code        = parhost-code
      bfpb_arh-fin-doc-schet.cli-type         = parpayer-type
      bfpb_arh-fin-doc-schet.cli-code         = parpayer-code
      bfpb_arh-fin-doc-schet.code-schet       = parpayer-code-schet
      bfpb_arh-fin-doc-schet.fin-ext-doc-type = parfin-ext-doc-type
      bfpb_arh-fin-doc-schet.calc-curr-code   = parbase-code
      bfpb_arh-fin-doc-schet.sum-type         = parsum-type
      bfpb_arh-fin-doc-schet.cource-des       = "b":u
      bfpb_arh-fin-doc-schet.fact-order       = parfact-order
      bfpb_arh-fin-doc-schet.fin-doc-code     = parfin-doc-code
      bfpb_arh-fin-doc-schet.fact-date        = parfact-date
      bfpb_arh-fin-doc-schet.curr-code        = parcurr-code
      bfpb_arh-fin-doc-schet.income           = (if available bopb_arh-fin-doc-schet then bopb_arh-fin-doc-schet.income      else 0)
      bfpb_arh-fin-doc-schet.income-vat       = (if available bopb_arh-fin-doc-schet then bopb_arh-fin-doc-schet.income-vat  else 0)
      bfpb_arh-fin-doc-schet.income-slt       = (if available bopb_arh-fin-doc-schet then bopb_arh-fin-doc-schet.income-slt  else 0)
      bfpb_arh-fin-doc-schet.expense          = (if available bopb_arh-fin-doc-schet then bopb_arh-fin-doc-schet.expense     else 0) + parsum-base
      bfpb_arh-fin-doc-schet.expense-vat      = (if available bopb_arh-fin-doc-schet then bopb_arh-fin-doc-schet.expense-vat else 0) + parsum-vat-base
      bfpb_arh-fin-doc-schet.expense-slt      = (if available bopb_arh-fin-doc-schet then bopb_arh-fin-doc-schet.expense-slt else 0) + parsum-slt-base
    .
  end.
  else do:
    find first bfpb_arh-fin-doc-schet where bfpb_arh-fin-doc-schet.host-code        = parhost-code         and
                                            bfpb_arh-fin-doc-schet.cli-type         = parpayer-type        and
                                            bfpb_arh-fin-doc-schet.cli-code         = parpayer-code        and
                                            bfpb_arh-fin-doc-schet.code-schet       = parpayer-code-schet  and
                                            bfpb_arh-fin-doc-schet.fin-ext-doc-type = parfin-ext-doc-type  and
                                            bfpb_arh-fin-doc-schet.calc-curr-code   = parbase-code         and
                                            bfpb_arh-fin-doc-schet.sum-type         = parsum-type          and
                                            bfpb_arh-fin-doc-schet.fact-order       = parfact-order        exclusive-lock.
  end.
  for each rbfpb_arh-fin-doc-schet where rbfpb_arh-fin-doc-schet.host-code        = bfpb_arh-fin-doc-schet.host-code        and
                                         rbfpb_arh-fin-doc-schet.cli-type         = parpayer-type                           and
                                         rbfpb_arh-fin-doc-schet.cli-code         = parpayer-code                           and
                                         rbfpb_arh-fin-doc-schet.code-schet       = bfpb_arh-fin-doc-schet.code-schet       and
                                         rbfpb_arh-fin-doc-schet.fin-ext-doc-type = bfpb_arh-fin-doc-schet.fin-ext-doc-type and
                                         rbfpb_arh-fin-doc-schet.calc-curr-code   = bfpb_arh-fin-doc-schet.calc-curr-code   and
                                         rbfpb_arh-fin-doc-schet.sum-type         = bfpb_arh-fin-doc-schet.sum-type         and
                                         rbfpb_arh-fin-doc-schet.fact-order       > bfpb_arh-fin-doc-schet.fact-order       use-index pi exclusive-lock on error undo, return error return-value :
    assign
      rbfpb_arh-fin-doc-schet.expense     = rbfpb_arh-fin-doc-schet.expense     + parsum-base
      rbfpb_arh-fin-doc-schet.expense-vat = rbfpb_arh-fin-doc-schet.expense-vat + parsum-vat-base
      rbfpb_arh-fin-doc-schet.expense-slt = rbfpb_arh-fin-doc-schet.expense-slt + parsum-slt-base
    .
  end.
  end. /*if parpayer-code <> 0 then do:      */
  if parreceiver-code <> 0 then do:
  if parmode = "close":u then do:
    find last borb_arh-fin-doc-schet where borb_arh-fin-doc-schet.host-code        = parhost-code            and
                                           borb_arh-fin-doc-schet.cli-type         = parreceiver-type        and
                                           borb_arh-fin-doc-schet.cli-code         = parreceiver-code        and
                                           borb_arh-fin-doc-schet.code-schet       = parreceiver-code-schet  and
                                           borb_arh-fin-doc-schet.fin-ext-doc-type = parfin-ext-doc-type     and
                                           borb_arh-fin-doc-schet.calc-curr-code   = parbase-code            and
                                           borb_arh-fin-doc-schet.sum-type         = parsum-type             and
                                           borb_arh-fin-doc-schet.fact-order       < parfact-order           use-index pi no-error.
    create bfrb_arh-fin-doc-schet.
    assign
      bfrb_arh-fin-doc-schet.host-code        = parhost-code
      bfrb_arh-fin-doc-schet.cli-type         = parreceiver-type
      bfrb_arh-fin-doc-schet.cli-code         = parreceiver-code
      bfrb_arh-fin-doc-schet.code-schet       = parreceiver-code-schet
      bfrb_arh-fin-doc-schet.fin-ext-doc-type = parfin-ext-doc-type
      bfrb_arh-fin-doc-schet.calc-curr-code   = parbase-code
      bfrb_arh-fin-doc-schet.sum-type         = parsum-type
      bfrb_arh-fin-doc-schet.cource-des       = "b":u
      bfrb_arh-fin-doc-schet.fact-order       = parfact-order
      bfrb_arh-fin-doc-schet.fin-doc-code     = parfin-doc-code
      bfrb_arh-fin-doc-schet.fact-date        = parfact-date
      bfrb_arh-fin-doc-schet.curr-code        = parcurr-code
    .
    assign
      bfrb_arh-fin-doc-schet.expense          = (if available borb_arh-fin-doc-schet then borb_arh-fin-doc-schet.expense     else 0)
      bfrb_arh-fin-doc-schet.expense-vat      = (if available borb_arh-fin-doc-schet then borb_arh-fin-doc-schet.expense-vat else 0)
      bfrb_arh-fin-doc-schet.expense-slt      = (if available borb_arh-fin-doc-schet then borb_arh-fin-doc-schet.expense-slt else 0)
      bfrb_arh-fin-doc-schet.income           = (if available borb_arh-fin-doc-schet then borb_arh-fin-doc-schet.income      else 0) + parsum-base
      bfrb_arh-fin-doc-schet.income-vat       = (if available borb_arh-fin-doc-schet then borb_arh-fin-doc-schet.income-vat  else 0) + parsum-vat-base
      bfrb_arh-fin-doc-schet.income-slt       = (if available borb_arh-fin-doc-schet then borb_arh-fin-doc-schet.income-slt  else 0) + parsum-slt-base
    .
  end.
  else do:
    find first bfrb_arh-fin-doc-schet where bfrb_arh-fin-doc-schet.host-code        = parhost-code            and
                                            bfrb_arh-fin-doc-schet.cli-type         = parreceiver-type        and
                                            bfrb_arh-fin-doc-schet.cli-code         = parreceiver-code        and
                                            bfrb_arh-fin-doc-schet.code-schet       = parreceiver-code-schet  and
                                            bfrb_arh-fin-doc-schet.fin-ext-doc-type = parfin-ext-doc-type     and
                                            bfrb_arh-fin-doc-schet.calc-curr-code   = parbase-code            and
                                            bfrb_arh-fin-doc-schet.sum-type         = parsum-type             and
                                            bfrb_arh-fin-doc-schet.fact-order       = parfact-order           exclusive-lock.
  end.
  for each rbfrb_arh-fin-doc-schet where rbfrb_arh-fin-doc-schet.host-code        = bfrb_arh-fin-doc-schet.host-code        and
                                         rbfrb_arh-fin-doc-schet.cli-type         = parreceiver-type                        and
                                         rbfrb_arh-fin-doc-schet.cli-code         = parreceiver-code                        and
                                         rbfrb_arh-fin-doc-schet.code-schet       = bfrb_arh-fin-doc-schet.code-schet       and
                                         rbfrb_arh-fin-doc-schet.fin-ext-doc-type = bfrb_arh-fin-doc-schet.fin-ext-doc-type and
                                         rbfrb_arh-fin-doc-schet.calc-curr-code   = bfrb_arh-fin-doc-schet.calc-curr-code   and
                                         rbfrb_arh-fin-doc-schet.sum-type         = bfrb_arh-fin-doc-schet.sum-type         and
                                         rbfrb_arh-fin-doc-schet.fact-order       > bfrb_arh-fin-doc-schet.fact-order       use-index pi exclusive-lock on error undo, return error return-value :
    assign
      rbfrb_arh-fin-doc-schet.income     = rbfrb_arh-fin-doc-schet.income     + parsum-base
      rbfrb_arh-fin-doc-schet.income-vat = rbfrb_arh-fin-doc-schet.income-vat + parsum-vat-base
      rbfrb_arh-fin-doc-schet.income-slt = rbfrb_arh-fin-doc-schet.income-slt + parsum-slt-base
    .
  end.
  if parmode = "delete":u then do:
    if parpayer-code <> 0 then do:
    delete bfpb_arh-fin-doc-schet.
    end.
    if parreceiver-code <> 0 then do:
    delete bfrb_arh-fin-doc-schet.
  end.
end.
end.
end. /*if parreceiver-code <> 0 then do:    */

end.
end procedure.

procedure libfarhp_calc-arh-fin-doc-schet-tax :
define input parameter parmode                    as   character                   no-undo.
define input parameter parhost-code               like ub.fin-doc.host-code        no-undo.
define input parameter parpayer-type              like ub.fin-doc.payer-type       no-undo.
define input parameter parpayer-code              like ub.fin-doc.payer-code       no-undo.
define input parameter parreceiver-type           like ub.fin-doc.receiver-type    no-undo.
define input parameter parreceiver-code           like ub.fin-doc.receiver-code    no-undo.
define input parameter parpayer-code-schet        like ub.fin-schet.code-schet     no-undo.
define input parameter parreceiver-code-schet     like ub.fin-schet.code-schet     no-undo.
define input parameter parfin-ext-doc-type        like ub.fin-doc.fin-ext-doc-type no-undo.
define input parameter parsum-type                as   character                   no-undo.
define input parameter parfact-order              like ub.fin-doc.fact-order       no-undo.
define input parameter parfin-doc-code            like ub.fin-doc.fin-doc-code     no-undo.
define input parameter parfact-date               like ub.fin-doc.fact-date        no-undo.
define input parameter parcurr-code               like ub.fin-doc.curr-code        no-undo.
define input parameter parbase-code               like ub.sysconf.base-code        no-undo.
define input parameter parvat-pc                  like ub.fin-doc-tax.vat-pc       no-undo.
define input parameter parslt-pc                  like ub.fin-doc-tax.slt-pc       no-undo.
define input parameter parwith-vat                as   logical                     no-undo.
define input parameter parwith-slt                as   logical                     no-undo.
define input parameter parsum-doc                 as   decimal                     no-undo.
define input parameter parsum-rubl                as   decimal                     no-undo.
define input parameter parsum-base                as   decimal                     no-undo.
define input parameter parsum-contr               as   decimal                     no-undo.
define input parameter parsum-vat-doc             as   decimal                     no-undo.
define input parameter parsum-vat-rubl            as   decimal                     no-undo.
define input parameter parsum-vat-base            as   decimal                     no-undo.
define input parameter parsum-vat-contr           as   decimal                     no-undo.
define input parameter parsum-slt-doc             as   decimal                     no-undo.
define input parameter parsum-slt-rubl            as   decimal                     no-undo.
define input parameter parsum-slt-base            as   decimal                     no-undo.
define input parameter parsum-slt-contr           as   decimal                     no-undo.
define buffer bfps_arh-fin-doc-schet-tax  for ub.arh-fin-doc-schet-tax.
define buffer bfrs_arh-fin-doc-schet-tax  for ub.arh-fin-doc-schet-tax.
define buffer rbfps_arh-fin-doc-schet-tax for ub.arh-fin-doc-schet-tax.
define buffer rbfrs_arh-fin-doc-schet-tax for ub.arh-fin-doc-schet-tax.
define buffer bops_arh-fin-doc-schet-tax  for ub.arh-fin-doc-schet-tax.
define buffer bors_arh-fin-doc-schet-tax  for ub.arh-fin-doc-schet-tax.
define buffer bfpr_arh-fin-doc-schet-tax  for ub.arh-fin-doc-schet-tax.
define buffer bfrr_arh-fin-doc-schet-tax  for ub.arh-fin-doc-schet-tax.
define buffer rbfpr_arh-fin-doc-schet-tax for ub.arh-fin-doc-schet-tax.
define buffer rbfrr_arh-fin-doc-schet-tax for ub.arh-fin-doc-schet-tax.
define buffer bopr_arh-fin-doc-schet-tax  for ub.arh-fin-doc-schet-tax.
define buffer borr_arh-fin-doc-schet-tax  for ub.arh-fin-doc-schet-tax.
define buffer bfpb_arh-fin-doc-schet-tax  for ub.arh-fin-doc-schet-tax.
define buffer bfrb_arh-fin-doc-schet-tax  for ub.arh-fin-doc-schet-tax.
define buffer rbfpb_arh-fin-doc-schet-tax for ub.arh-fin-doc-schet-tax.
define buffer rbfrb_arh-fin-doc-schet-tax for ub.arh-fin-doc-schet-tax.
define buffer bopb_arh-fin-doc-schet-tax  for ub.arh-fin-doc-schet-tax.
define buffer borb_arh-fin-doc-schet-tax  for ub.arh-fin-doc-schet-tax.
define buffer bfpc_arh-fin-doc-schet-tax  for ub.arh-fin-doc-schet-tax.
define buffer bfrc_arh-fin-doc-schet-tax  for ub.arh-fin-doc-schet-tax.
define buffer rbfpc_arh-fin-doc-schet-tax for ub.arh-fin-doc-schet-tax.
define buffer rbfrc_arh-fin-doc-schet-tax for ub.arh-fin-doc-schet-tax.
define buffer bopc_arh-fin-doc-schet-tax  for ub.arh-fin-doc-schet-tax.
define buffer borc_arh-fin-doc-schet-tax  for ub.arh-fin-doc-schet-tax.
do on error undo, return error substitute ("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
if parmode = "close":u then do:
  find last bops_arh-fin-doc-schet-tax where bops_arh-fin-doc-schet-tax.host-code        = parhost-code         and
                                             bops_arh-fin-doc-schet-tax.cli-type         = parpayer-type        and
                                             bops_arh-fin-doc-schet-tax.cli-code         = parpayer-code        and
                                             bops_arh-fin-doc-schet-tax.code-schet       = parpayer-code-schet  and
                                             bops_arh-fin-doc-schet-tax.fin-ext-doc-type = parfin-ext-doc-type  and
                                             bops_arh-fin-doc-schet-tax.calc-curr-code   = parcurr-code         and
                                             bops_arh-fin-doc-schet-tax.vat-pc           = parvat-pc            and
                                             bops_arh-fin-doc-schet-tax.slt-pc           = parslt-pc            and
                                             bops_arh-fin-doc-schet-tax.with-vat         = parwith-vat          and
                                             bops_arh-fin-doc-schet-tax.with-slt         = parwith-slt          and
                                             bops_arh-fin-doc-schet-tax.sum-type         = parsum-type          and
                                             bops_arh-fin-doc-schet-tax.fact-order       < parfact-order        use-index pi no-error.
  create bfps_arh-fin-doc-schet-tax.
  assign
    bfps_arh-fin-doc-schet-tax.host-code        = parhost-code
    bfps_arh-fin-doc-schet-tax.cli-type         = parpayer-type
    bfps_arh-fin-doc-schet-tax.cli-code         = parpayer-code
    bfps_arh-fin-doc-schet-tax.code-schet       = parpayer-code-schet
    bfps_arh-fin-doc-schet-tax.fin-ext-doc-type = parfin-ext-doc-type
    bfps_arh-fin-doc-schet-tax.calc-curr-code   = parcurr-code
    bfps_arh-fin-doc-schet-tax.vat-pc           = parvat-pc
    bfps_arh-fin-doc-schet-tax.slt-pc           = parslt-pc
    bfps_arh-fin-doc-schet-tax.with-vat         = parwith-vat
    bfps_arh-fin-doc-schet-tax.with-slt         = parwith-slt
    bfps_arh-fin-doc-schet-tax.sum-type         = parsum-type
    bfps_arh-fin-doc-schet-tax.cource-des       = "s":u
    bfps_arh-fin-doc-schet-tax.fact-order       = parfact-order
    bfps_arh-fin-doc-schet-tax.fin-doc-code     = parfin-doc-code
    bfps_arh-fin-doc-schet-tax.fact-date        = parfact-date
    bfps_arh-fin-doc-schet-tax.curr-code        = parcurr-code
    bfps_arh-fin-doc-schet-tax.income           = (if available bops_arh-fin-doc-schet-tax then bops_arh-fin-doc-schet-tax.income      else 0)
    bfps_arh-fin-doc-schet-tax.income-vat       = (if available bops_arh-fin-doc-schet-tax then bops_arh-fin-doc-schet-tax.income-vat  else 0)
    bfps_arh-fin-doc-schet-tax.income-slt       = (if available bops_arh-fin-doc-schet-tax then bops_arh-fin-doc-schet-tax.income-slt  else 0)
    bfps_arh-fin-doc-schet-tax.expense          = (if available bops_arh-fin-doc-schet-tax then bops_arh-fin-doc-schet-tax.expense     else 0) + parsum-doc
    bfps_arh-fin-doc-schet-tax.expense-vat      = (if available bops_arh-fin-doc-schet-tax then bops_arh-fin-doc-schet-tax.expense-vat else 0) + parsum-vat-doc
    bfps_arh-fin-doc-schet-tax.expense-slt      = (if available bops_arh-fin-doc-schet-tax then bops_arh-fin-doc-schet-tax.expense-slt else 0) + parsum-slt-doc
  .
end.
else do:
  find first bfps_arh-fin-doc-schet-tax where bfps_arh-fin-doc-schet-tax.host-code        = parhost-code         and
                                              bfps_arh-fin-doc-schet-tax.cli-type         = parpayer-type        and
                                              bfps_arh-fin-doc-schet-tax.cli-code         = parpayer-code        and
                                              bfps_arh-fin-doc-schet-tax.code-schet       = parpayer-code-schet  and
                                              bfps_arh-fin-doc-schet-tax.fin-ext-doc-type = parfin-ext-doc-type  and
                                              bfps_arh-fin-doc-schet-tax.calc-curr-code   = parcurr-code         and
                                              bfps_arh-fin-doc-schet-tax.vat-pc           = parvat-pc            and
                                              bfps_arh-fin-doc-schet-tax.slt-pc           = parslt-pc            and
                                              bfps_arh-fin-doc-schet-tax.with-vat         = parwith-vat          and
                                              bfps_arh-fin-doc-schet-tax.with-slt         = parwith-slt          and
                                              bfps_arh-fin-doc-schet-tax.sum-type         = parsum-type          and
                                              bfps_arh-fin-doc-schet-tax.fact-order       = parfact-order        exclusive-lock.
end.
for each rbfps_arh-fin-doc-schet-tax where rbfps_arh-fin-doc-schet-tax.host-code        = bfps_arh-fin-doc-schet-tax.host-code        and
                                           rbfps_arh-fin-doc-schet-tax.cli-type         = parpayer-type                               and
                                           rbfps_arh-fin-doc-schet-tax.cli-code         = parpayer-code                               and
                                           rbfps_arh-fin-doc-schet-tax.code-schet       = bfps_arh-fin-doc-schet-tax.code-schet       and
                                           rbfps_arh-fin-doc-schet-tax.fin-ext-doc-type = bfps_arh-fin-doc-schet-tax.fin-ext-doc-type and
                                           rbfps_arh-fin-doc-schet-tax.calc-curr-code   = bfps_arh-fin-doc-schet-tax.calc-curr-code   and
                                           rbfps_arh-fin-doc-schet-tax.vat-pc           = bfps_arh-fin-doc-schet-tax.vat-pc           and
                                           rbfps_arh-fin-doc-schet-tax.slt-pc           = bfps_arh-fin-doc-schet-tax.slt-pc           and
                                           rbfps_arh-fin-doc-schet-tax.with-vat         = bfps_arh-fin-doc-schet-tax.with-vat         and
                                           rbfps_arh-fin-doc-schet-tax.with-slt         = bfps_arh-fin-doc-schet-tax.with-slt         and
                                           rbfps_arh-fin-doc-schet-tax.sum-type         = bfps_arh-fin-doc-schet-tax.sum-type         and
                                           rbfps_arh-fin-doc-schet-tax.fact-order       > bfps_arh-fin-doc-schet-tax.fact-order       use-index pi exclusive-lock on error undo, return error return-value :
  assign
    rbfps_arh-fin-doc-schet-tax.expense     = rbfps_arh-fin-doc-schet-tax.expense     + parsum-doc
    rbfps_arh-fin-doc-schet-tax.expense-vat = rbfps_arh-fin-doc-schet-tax.expense-vat + parsum-vat-doc
    rbfps_arh-fin-doc-schet-tax.expense-slt = rbfps_arh-fin-doc-schet-tax.expense-slt + parsum-slt-doc
  .
end.
if parmode = "close":u then do:
  find last bors_arh-fin-doc-schet-tax where bors_arh-fin-doc-schet-tax.host-code         = parhost-code           and
                                             bors_arh-fin-doc-schet-tax.cli-type          = parreceiver-type       and
                                             bors_arh-fin-doc-schet-tax.cli-code          = parreceiver-code       and
                                             bors_arh-fin-doc-schet-tax.code-schet        = parreceiver-code-schet and
                                             bors_arh-fin-doc-schet-tax.fin-ext-doc-type  = parfin-ext-doc-type    and
                                             bors_arh-fin-doc-schet-tax.calc-curr-code    = parcurr-code           and
                                             bors_arh-fin-doc-schet-tax.vat-pc            = parvat-pc              and
                                             bors_arh-fin-doc-schet-tax.slt-pc            = parslt-pc              and
                                             bors_arh-fin-doc-schet-tax.with-vat          = parwith-vat            and
                                             bors_arh-fin-doc-schet-tax.with-slt          = parwith-slt            and
                                             bors_arh-fin-doc-schet-tax.sum-type          = parsum-type            and
                                             bors_arh-fin-doc-schet-tax.fact-order        < parfact-order          use-index pi no-error.
  create bfrs_arh-fin-doc-schet-tax.
  assign
    bfrs_arh-fin-doc-schet-tax.host-code        = parhost-code
    bfrs_arh-fin-doc-schet-tax.cli-type         = parreceiver-type
    bfrs_arh-fin-doc-schet-tax.cli-code         = parreceiver-code
    bfrs_arh-fin-doc-schet-tax.code-schet       = parreceiver-code-schet
    bfrs_arh-fin-doc-schet-tax.fin-ext-doc-type = parfin-ext-doc-type
    bfrs_arh-fin-doc-schet-tax.calc-curr-code   = parcurr-code
    bfrs_arh-fin-doc-schet-tax.vat-pc           = parvat-pc
    bfrs_arh-fin-doc-schet-tax.slt-pc           = parslt-pc
    bfrs_arh-fin-doc-schet-tax.with-vat         = parwith-vat
    bfrs_arh-fin-doc-schet-tax.with-slt         = parwith-slt
    bfrs_arh-fin-doc-schet-tax.sum-type         = parsum-type
    bfrs_arh-fin-doc-schet-tax.cource-des       = "s":u
    bfrs_arh-fin-doc-schet-tax.fact-order       = parfact-order
    bfrs_arh-fin-doc-schet-tax.fin-doc-code     = parfin-doc-code
    bfrs_arh-fin-doc-schet-tax.fact-date        = parfact-date
    bfrs_arh-fin-doc-schet-tax.curr-code        = parcurr-code
  .
  assign
    bfrs_arh-fin-doc-schet-tax.expense          = (if available bors_arh-fin-doc-schet-tax then bors_arh-fin-doc-schet-tax.expense     else 0)
    bfrs_arh-fin-doc-schet-tax.expense-vat      = (if available bors_arh-fin-doc-schet-tax then bors_arh-fin-doc-schet-tax.expense-vat else 0)
    bfrs_arh-fin-doc-schet-tax.expense-slt      = (if available bors_arh-fin-doc-schet-tax then bors_arh-fin-doc-schet-tax.expense-slt else 0)
    bfrs_arh-fin-doc-schet-tax.income           = (if available bors_arh-fin-doc-schet-tax then bors_arh-fin-doc-schet-tax.income      else 0) + parsum-doc
    bfrs_arh-fin-doc-schet-tax.income-vat       = (if available bors_arh-fin-doc-schet-tax then bors_arh-fin-doc-schet-tax.income-vat  else 0) + parsum-vat-doc
    bfrs_arh-fin-doc-schet-tax.income-slt       = (if available bors_arh-fin-doc-schet-tax then bors_arh-fin-doc-schet-tax.income-slt  else 0) + parsum-slt-doc
  .
end.
else do:
  find first bfrs_arh-fin-doc-schet-tax where bfrs_arh-fin-doc-schet-tax.host-code         = parhost-code           and
                                              bfrs_arh-fin-doc-schet-tax.cli-type          = parreceiver-type       and
                                              bfrs_arh-fin-doc-schet-tax.cli-code          = parreceiver-code       and
                                              bfrs_arh-fin-doc-schet-tax.code-schet        = parreceiver-code-schet and
                                              bfrs_arh-fin-doc-schet-tax.fin-ext-doc-type  = parfin-ext-doc-type    and
                                              bfrs_arh-fin-doc-schet-tax.calc-curr-code    = parcurr-code           and
                                              bfrs_arh-fin-doc-schet-tax.vat-pc            = parvat-pc              and
                                              bfrs_arh-fin-doc-schet-tax.slt-pc            = parslt-pc              and
                                              bfrs_arh-fin-doc-schet-tax.with-vat          = parwith-vat            and
                                              bfrs_arh-fin-doc-schet-tax.with-slt          = parwith-slt            and
                                              bfrs_arh-fin-doc-schet-tax.sum-type          = parsum-type            and
                                              bfrs_arh-fin-doc-schet-tax.fact-order        = parfact-order          exclusive-lock.

end.
for each rbfrs_arh-fin-doc-schet-tax where rbfrs_arh-fin-doc-schet-tax.host-code        = bfrs_arh-fin-doc-schet-tax.host-code        and
                                           rbfrs_arh-fin-doc-schet-tax.cli-type         = parreceiver-type                            and
                                           rbfrs_arh-fin-doc-schet-tax.cli-code         = parreceiver-code                            and
                                           rbfrs_arh-fin-doc-schet-tax.code-schet       = bfrs_arh-fin-doc-schet-tax.code-schet       and
                                           rbfrs_arh-fin-doc-schet-tax.fin-ext-doc-type = bfrs_arh-fin-doc-schet-tax.fin-ext-doc-type and
                                           rbfrs_arh-fin-doc-schet-tax.calc-curr-code   = bfrs_arh-fin-doc-schet-tax.calc-curr-code   and
                                           rbfrs_arh-fin-doc-schet-tax.vat-pc           = bfrs_arh-fin-doc-schet-tax.vat-pc           and
                                           rbfrs_arh-fin-doc-schet-tax.slt-pc           = bfrs_arh-fin-doc-schet-tax.slt-pc           and
                                           rbfrs_arh-fin-doc-schet-tax.with-vat         = bfrs_arh-fin-doc-schet-tax.with-vat         and
                                           rbfrs_arh-fin-doc-schet-tax.with-slt         = bfrs_arh-fin-doc-schet-tax.with-slt         and
                                           rbfrs_arh-fin-doc-schet-tax.sum-type         = bfrs_arh-fin-doc-schet-tax.sum-type         and
                                           rbfrs_arh-fin-doc-schet-tax.fact-order       > bfrs_arh-fin-doc-schet-tax.fact-order       use-index pi exclusive-lock on error undo, return error return-value :
  assign
    rbfrs_arh-fin-doc-schet-tax.income     = rbfrs_arh-fin-doc-schet-tax.income     + parsum-doc
    rbfrs_arh-fin-doc-schet-tax.income-vat = rbfrs_arh-fin-doc-schet-tax.income-vat + parsum-vat-doc
    rbfrs_arh-fin-doc-schet-tax.income-slt = rbfrs_arh-fin-doc-schet-tax.income-slt + parsum-slt-doc
  .
end.
if parmode = "delete":u then do:
  delete bfps_arh-fin-doc-schet-tax.
  delete bfrs_arh-fin-doc-schet-tax.
end.
if parcurr-code <> 0 then do:
  if parmode = "close":u then do:
    find last bopr_arh-fin-doc-schet-tax where bopr_arh-fin-doc-schet-tax.host-code        = parhost-code         and
                                               bopr_arh-fin-doc-schet-tax.cli-type         = parpayer-type        and
                                               bopr_arh-fin-doc-schet-tax.cli-code         = parpayer-code        and
                                               bopr_arh-fin-doc-schet-tax.code-schet       = parpayer-code-schet  and
                                               bopr_arh-fin-doc-schet-tax.fin-ext-doc-type = parfin-ext-doc-type  and
                                               bopr_arh-fin-doc-schet-tax.calc-curr-code   = 0                    and
                                               bopr_arh-fin-doc-schet-tax.vat-pc           = parvat-pc            and
                                               bopr_arh-fin-doc-schet-tax.slt-pc           = parslt-pc            and
                                               bopr_arh-fin-doc-schet-tax.with-vat         = parwith-vat          and
                                               bopr_arh-fin-doc-schet-tax.with-slt         = parwith-slt          and
                                               bopr_arh-fin-doc-schet-tax.sum-type         = parsum-type          and
                                               bopr_arh-fin-doc-schet-tax.fact-order       < parfact-order        use-index pi no-error.
    create bfpr_arh-fin-doc-schet-tax.
    assign
      bfpr_arh-fin-doc-schet-tax.host-code        = parhost-code
      bfpr_arh-fin-doc-schet-tax.cli-type         = parpayer-type
      bfpr_arh-fin-doc-schet-tax.cli-code         = parpayer-code
      bfpr_arh-fin-doc-schet-tax.code-schet       = parpayer-code-schet
      bfpr_arh-fin-doc-schet-tax.fin-ext-doc-type = parfin-ext-doc-type
      bfpr_arh-fin-doc-schet-tax.calc-curr-code   = 0
      bfpr_arh-fin-doc-schet-tax.vat-pc           = parvat-pc
      bfpr_arh-fin-doc-schet-tax.slt-pc           = parslt-pc
      bfpr_arh-fin-doc-schet-tax.with-vat         = parwith-vat
      bfpr_arh-fin-doc-schet-tax.with-slt         = parwith-slt
      bfpr_arh-fin-doc-schet-tax.sum-type         = parsum-type
      bfpr_arh-fin-doc-schet-tax.cource-des       = "r":u
      bfpr_arh-fin-doc-schet-tax.fact-order       = parfact-order
      bfpr_arh-fin-doc-schet-tax.fin-doc-code     = parfin-doc-code
      bfpr_arh-fin-doc-schet-tax.fact-date        = parfact-date
      bfpr_arh-fin-doc-schet-tax.curr-code        = parcurr-code
      bfpr_arh-fin-doc-schet-tax.income           = (if available bopr_arh-fin-doc-schet-tax then bopr_arh-fin-doc-schet-tax.income      else 0)
      bfpr_arh-fin-doc-schet-tax.income-vat       = (if available bopr_arh-fin-doc-schet-tax then bopr_arh-fin-doc-schet-tax.income-vat  else 0)
      bfpr_arh-fin-doc-schet-tax.income-slt       = (if available bopr_arh-fin-doc-schet-tax then bopr_arh-fin-doc-schet-tax.income-slt  else 0)
      bfpr_arh-fin-doc-schet-tax.expense          = (if available bopr_arh-fin-doc-schet-tax then bopr_arh-fin-doc-schet-tax.expense     else 0) + parsum-rubl
      bfpr_arh-fin-doc-schet-tax.expense-vat      = (if available bopr_arh-fin-doc-schet-tax then bopr_arh-fin-doc-schet-tax.expense-vat else 0) + parsum-vat-rubl
      bfpr_arh-fin-doc-schet-tax.expense-slt      = (if available bopr_arh-fin-doc-schet-tax then bopr_arh-fin-doc-schet-tax.expense-slt else 0) + parsum-slt-rubl
    .
  end.
  else do:
    find first bfpr_arh-fin-doc-schet-tax where bfpr_arh-fin-doc-schet-tax.host-code        = parhost-code         and
                                                bfpr_arh-fin-doc-schet-tax.cli-type         = parpayer-type        and
                                                bfpr_arh-fin-doc-schet-tax.cli-code         = parpayer-code        and
                                                bfpr_arh-fin-doc-schet-tax.code-schet       = parpayer-code-schet  and
                                                bfpr_arh-fin-doc-schet-tax.fin-ext-doc-type = parfin-ext-doc-type  and
                                                bfpr_arh-fin-doc-schet-tax.calc-curr-code   = 0                    and
                                                bfpr_arh-fin-doc-schet-tax.vat-pc           = parvat-pc            and
                                                bfpr_arh-fin-doc-schet-tax.slt-pc           = parslt-pc            and
                                                bfpr_arh-fin-doc-schet-tax.with-vat         = parwith-vat          and
                                                bfpr_arh-fin-doc-schet-tax.with-slt         = parwith-slt          and
                                                bfpr_arh-fin-doc-schet-tax.sum-type         = parsum-type          and
                                                bfpr_arh-fin-doc-schet-tax.fact-order       = parfact-order        exclusive-lock.
  end.
  for each rbfpr_arh-fin-doc-schet-tax where rbfpr_arh-fin-doc-schet-tax.host-code        = bfpr_arh-fin-doc-schet-tax.host-code        and
                                             rbfpr_arh-fin-doc-schet-tax.cli-type         = parpayer-type                               and
                                             rbfpr_arh-fin-doc-schet-tax.cli-code         = parpayer-code                               and
                                             rbfpr_arh-fin-doc-schet-tax.code-schet       = bfpr_arh-fin-doc-schet-tax.code-schet       and
                                             rbfpr_arh-fin-doc-schet-tax.fin-ext-doc-type = bfpr_arh-fin-doc-schet-tax.fin-ext-doc-type and
                                             rbfpr_arh-fin-doc-schet-tax.calc-curr-code   = bfpr_arh-fin-doc-schet-tax.calc-curr-code   and
                                             rbfpr_arh-fin-doc-schet-tax.vat-pc           = bfpr_arh-fin-doc-schet-tax.vat-pc           and
                                             rbfpr_arh-fin-doc-schet-tax.slt-pc           = bfpr_arh-fin-doc-schet-tax.slt-pc           and
                                             rbfpr_arh-fin-doc-schet-tax.with-vat         = bfpr_arh-fin-doc-schet-tax.with-vat         and
                                             rbfpr_arh-fin-doc-schet-tax.with-slt         = bfpr_arh-fin-doc-schet-tax.with-slt         and
                                             rbfpr_arh-fin-doc-schet-tax.sum-type         = bfpr_arh-fin-doc-schet-tax.sum-type         and
                                             rbfpr_arh-fin-doc-schet-tax.fact-order       > bfpr_arh-fin-doc-schet-tax.fact-order       use-index pi exclusive-lock on error undo, return error return-value :
    assign
      rbfpr_arh-fin-doc-schet-tax.expense     = rbfpr_arh-fin-doc-schet-tax.expense     + parsum-rubl
      rbfpr_arh-fin-doc-schet-tax.expense-vat = rbfpr_arh-fin-doc-schet-tax.expense-vat + parsum-vat-rubl
      rbfpr_arh-fin-doc-schet-tax.expense-slt = rbfpr_arh-fin-doc-schet-tax.expense-slt + parsum-slt-rubl
    .
  end.
  if parmode = "close":u then do:
    find last borr_arh-fin-doc-schet-tax where borr_arh-fin-doc-schet-tax.host-code        = parhost-code            and
                                               borr_arh-fin-doc-schet-tax.cli-type         = parreceiver-type        and
                                               borr_arh-fin-doc-schet-tax.cli-code         = parreceiver-code        and
                                               borr_arh-fin-doc-schet-tax.code-schet       = parreceiver-code-schet  and
                                               borr_arh-fin-doc-schet-tax.fin-ext-doc-type = parfin-ext-doc-type     and
                                               borr_arh-fin-doc-schet-tax.calc-curr-code   = 0                       and
                                               borr_arh-fin-doc-schet-tax.vat-pc           = parvat-pc               and
                                               borr_arh-fin-doc-schet-tax.slt-pc           = parslt-pc               and
                                               borr_arh-fin-doc-schet-tax.with-vat         = parwith-vat             and
                                               borr_arh-fin-doc-schet-tax.with-slt         = parwith-slt             and
                                               borr_arh-fin-doc-schet-tax.sum-type         = parsum-type             and
                                               borr_arh-fin-doc-schet-tax.fact-order       < parfact-order           use-index pi no-error.
    create bfrr_arh-fin-doc-schet-tax.
    assign
      bfrr_arh-fin-doc-schet-tax.host-code        = parhost-code
      bfrr_arh-fin-doc-schet-tax.cli-type         = parreceiver-type
      bfrr_arh-fin-doc-schet-tax.cli-code         = parreceiver-code
      bfrr_arh-fin-doc-schet-tax.code-schet       = parreceiver-code-schet
      bfrr_arh-fin-doc-schet-tax.fin-ext-doc-type = parfin-ext-doc-type
      bfrr_arh-fin-doc-schet-tax.calc-curr-code   = 0
      bfrr_arh-fin-doc-schet-tax.vat-pc           = parvat-pc
      bfrr_arh-fin-doc-schet-tax.slt-pc           = parslt-pc
      bfrr_arh-fin-doc-schet-tax.with-vat         = parwith-vat
      bfrr_arh-fin-doc-schet-tax.with-slt         = parwith-slt
      bfrr_arh-fin-doc-schet-tax.sum-type         = parsum-type
      bfrr_arh-fin-doc-schet-tax.cource-des       = "r":u
      bfrr_arh-fin-doc-schet-tax.fact-order       = parfact-order
      bfrr_arh-fin-doc-schet-tax.fin-doc-code     = parfin-doc-code
      bfrr_arh-fin-doc-schet-tax.fact-date        = parfact-date
      bfrr_arh-fin-doc-schet-tax.curr-code        = parcurr-code
    .
    assign
      bfrr_arh-fin-doc-schet-tax.expense          = (if available borr_arh-fin-doc-schet-tax then borr_arh-fin-doc-schet-tax.expense     else 0)
      bfrr_arh-fin-doc-schet-tax.expense-vat      = (if available borr_arh-fin-doc-schet-tax then borr_arh-fin-doc-schet-tax.expense-vat else 0)
      bfrr_arh-fin-doc-schet-tax.expense-slt      = (if available borr_arh-fin-doc-schet-tax then borr_arh-fin-doc-schet-tax.expense-slt else 0)
      bfrr_arh-fin-doc-schet-tax.income           = (if available borr_arh-fin-doc-schet-tax then borr_arh-fin-doc-schet-tax.income      else 0) + parsum-rubl
      bfrr_arh-fin-doc-schet-tax.income-vat       = (if available borr_arh-fin-doc-schet-tax then borr_arh-fin-doc-schet-tax.income-vat  else 0) + parsum-vat-rubl
      bfrr_arh-fin-doc-schet-tax.income-slt       = (if available borr_arh-fin-doc-schet-tax then borr_arh-fin-doc-schet-tax.income-slt  else 0) + parsum-slt-rubl
    .
  end.
  else do:
    find first bfrr_arh-fin-doc-schet-tax where bfrr_arh-fin-doc-schet-tax.host-code        = parhost-code            and
                                                bfrr_arh-fin-doc-schet-tax.cli-type         = parreceiver-type        and
                                                bfrr_arh-fin-doc-schet-tax.cli-code         = parreceiver-code        and
                                                bfrr_arh-fin-doc-schet-tax.code-schet       = parreceiver-code-schet  and
                                                bfrr_arh-fin-doc-schet-tax.fin-ext-doc-type = parfin-ext-doc-type     and
                                                bfrr_arh-fin-doc-schet-tax.calc-curr-code   = 0                       and
                                                bfrr_arh-fin-doc-schet-tax.vat-pc           = parvat-pc               and
                                                bfrr_arh-fin-doc-schet-tax.slt-pc           = parslt-pc               and
                                                bfrr_arh-fin-doc-schet-tax.with-vat         = parwith-vat             and
                                                bfrr_arh-fin-doc-schet-tax.with-slt         = parwith-slt             and
                                                bfrr_arh-fin-doc-schet-tax.sum-type         = parsum-type             and
                                                bfrr_arh-fin-doc-schet-tax.fact-order       = parfact-order           exclusive-lock.
  end.
  for each rbfrr_arh-fin-doc-schet-tax where rbfrr_arh-fin-doc-schet-tax.host-code        = bfrr_arh-fin-doc-schet-tax.host-code        and
                                             rbfrr_arh-fin-doc-schet-tax.cli-type         = parreceiver-type                            and
                                             rbfrr_arh-fin-doc-schet-tax.cli-code         = parreceiver-code                            and
                                             rbfrr_arh-fin-doc-schet-tax.code-schet       = bfrr_arh-fin-doc-schet-tax.code-schet       and
                                             rbfrr_arh-fin-doc-schet-tax.fin-ext-doc-type = bfrr_arh-fin-doc-schet-tax.fin-ext-doc-type and
                                             rbfrr_arh-fin-doc-schet-tax.calc-curr-code   = bfrr_arh-fin-doc-schet-tax.calc-curr-code   and
                                             rbfrr_arh-fin-doc-schet-tax.vat-pc           = bfrr_arh-fin-doc-schet-tax.vat-pc           and
                                             rbfrr_arh-fin-doc-schet-tax.slt-pc           = bfrr_arh-fin-doc-schet-tax.slt-pc           and
                                             rbfrr_arh-fin-doc-schet-tax.with-vat         = bfrr_arh-fin-doc-schet-tax.with-vat         and
                                             rbfrr_arh-fin-doc-schet-tax.with-slt         = bfrr_arh-fin-doc-schet-tax.with-slt         and
                                             rbfrr_arh-fin-doc-schet-tax.sum-type         = bfrr_arh-fin-doc-schet-tax.sum-type         and
                                             rbfrr_arh-fin-doc-schet-tax.fact-order       > bfrr_arh-fin-doc-schet-tax.fact-order       use-index pi exclusive-lock on error undo, return error return-value :
    assign
      rbfrr_arh-fin-doc-schet-tax.income     = rbfrr_arh-fin-doc-schet-tax.income     + parsum-rubl
      rbfrr_arh-fin-doc-schet-tax.income-vat = rbfrr_arh-fin-doc-schet-tax.income-vat + parsum-vat-rubl
      rbfrr_arh-fin-doc-schet-tax.income-slt = rbfrr_arh-fin-doc-schet-tax.income-slt + parsum-slt-rubl
    .
  end.
  if parmode = "delete":u then do:
    delete bfpr_arh-fin-doc-schet-tax.
    delete bfrr_arh-fin-doc-schet-tax.
  end.
end.
if parbase-code <> parcurr-code and
   parbase-code <> 0            then do:
  if parmode = "close":u then do:
    find last bopb_arh-fin-doc-schet-tax where bopb_arh-fin-doc-schet-tax.host-code        = parhost-code         and
                                               bopb_arh-fin-doc-schet-tax.cli-type         = parpayer-type        and
                                               bopb_arh-fin-doc-schet-tax.cli-code         = parpayer-code        and
                                               bopb_arh-fin-doc-schet-tax.code-schet       = parpayer-code-schet  and
                                               bopb_arh-fin-doc-schet-tax.fin-ext-doc-type = parfin-ext-doc-type  and
                                               bopb_arh-fin-doc-schet-tax.calc-curr-code   = parbase-code         and
                                               bopb_arh-fin-doc-schet-tax.vat-pc           = parvat-pc            and
                                               bopb_arh-fin-doc-schet-tax.slt-pc           = parslt-pc            and
                                               bopb_arh-fin-doc-schet-tax.with-vat         = parwith-vat          and
                                               bopb_arh-fin-doc-schet-tax.with-slt         = parwith-slt          and
                                               bopb_arh-fin-doc-schet-tax.sum-type         = parsum-type          and
                                               bopb_arh-fin-doc-schet-tax.fact-order       < parfact-order        use-index pi no-error.
    create bfpb_arh-fin-doc-schet-tax.
    assign
      bfpb_arh-fin-doc-schet-tax.host-code        = parhost-code
      bfpb_arh-fin-doc-schet-tax.cli-type         = parpayer-type
      bfpb_arh-fin-doc-schet-tax.cli-code         = parpayer-code
      bfpb_arh-fin-doc-schet-tax.code-schet       = parpayer-code-schet
      bfpb_arh-fin-doc-schet-tax.fin-ext-doc-type = parfin-ext-doc-type
      bfpb_arh-fin-doc-schet-tax.calc-curr-code   = parbase-code
      bfpb_arh-fin-doc-schet-tax.vat-pc           = parvat-pc
      bfpb_arh-fin-doc-schet-tax.slt-pc           = parslt-pc
      bfpb_arh-fin-doc-schet-tax.with-vat         = parwith-vat
      bfpb_arh-fin-doc-schet-tax.with-slt         = parwith-slt
      bfpb_arh-fin-doc-schet-tax.sum-type         = parsum-type
      bfpb_arh-fin-doc-schet-tax.cource-des       = "b":u
      bfpb_arh-fin-doc-schet-tax.fact-order       = parfact-order
      bfpb_arh-fin-doc-schet-tax.fin-doc-code     = parfin-doc-code
      bfpb_arh-fin-doc-schet-tax.fact-date        = parfact-date
      bfpb_arh-fin-doc-schet-tax.curr-code        = parcurr-code
      bfpb_arh-fin-doc-schet-tax.income           = (if available bopb_arh-fin-doc-schet-tax then bopb_arh-fin-doc-schet-tax.income      else 0)
      bfpb_arh-fin-doc-schet-tax.income-vat       = (if available bopb_arh-fin-doc-schet-tax then bopb_arh-fin-doc-schet-tax.income-vat  else 0)
      bfpb_arh-fin-doc-schet-tax.income-slt       = (if available bopb_arh-fin-doc-schet-tax then bopb_arh-fin-doc-schet-tax.income-slt  else 0)
      bfpb_arh-fin-doc-schet-tax.expense          = (if available bopb_arh-fin-doc-schet-tax then bopb_arh-fin-doc-schet-tax.expense     else 0) + parsum-base
      bfpb_arh-fin-doc-schet-tax.expense-vat      = (if available bopb_arh-fin-doc-schet-tax then bopb_arh-fin-doc-schet-tax.expense-vat else 0) + parsum-vat-base
      bfpb_arh-fin-doc-schet-tax.expense-slt      = (if available bopb_arh-fin-doc-schet-tax then bopb_arh-fin-doc-schet-tax.expense-slt else 0) + parsum-slt-base
    .
  end.
  else do:
    find first bfpb_arh-fin-doc-schet-tax where bfpb_arh-fin-doc-schet-tax.host-code        = parhost-code         and
                                                bfpb_arh-fin-doc-schet-tax.cli-type         = parpayer-type        and
                                                bfpb_arh-fin-doc-schet-tax.cli-code         = parpayer-code        and
                                                bfpb_arh-fin-doc-schet-tax.code-schet       = parpayer-code-schet  and
                                                bfpb_arh-fin-doc-schet-tax.fin-ext-doc-type = parfin-ext-doc-type  and
                                                bfpb_arh-fin-doc-schet-tax.calc-curr-code   = parbase-code         and
                                                bfpb_arh-fin-doc-schet-tax.vat-pc           = parvat-pc            and
                                                bfpb_arh-fin-doc-schet-tax.slt-pc           = parslt-pc            and
                                                bfpb_arh-fin-doc-schet-tax.with-vat         = parwith-vat          and
                                                bfpb_arh-fin-doc-schet-tax.with-slt         = parwith-slt          and
                                                bfpb_arh-fin-doc-schet-tax.sum-type         = parsum-type          and
                                                bfpb_arh-fin-doc-schet-tax.fact-order       = parfact-order        exclusive-lock.
  end.
  for each rbfpb_arh-fin-doc-schet-tax where rbfpb_arh-fin-doc-schet-tax.host-code        = bfpb_arh-fin-doc-schet-tax.host-code        and
                                             rbfpb_arh-fin-doc-schet-tax.cli-type         = parpayer-type                               and
                                             rbfpb_arh-fin-doc-schet-tax.cli-code         = parpayer-code                               and
                                             rbfpb_arh-fin-doc-schet-tax.code-schet       = bfpb_arh-fin-doc-schet-tax.code-schet       and
                                             rbfpb_arh-fin-doc-schet-tax.fin-ext-doc-type = bfpb_arh-fin-doc-schet-tax.fin-ext-doc-type and
                                             rbfpb_arh-fin-doc-schet-tax.calc-curr-code   = bfpb_arh-fin-doc-schet-tax.calc-curr-code   and
                                             rbfpb_arh-fin-doc-schet-tax.vat-pc           = bfpb_arh-fin-doc-schet-tax.vat-pc           and
                                             rbfpb_arh-fin-doc-schet-tax.slt-pc           = bfpb_arh-fin-doc-schet-tax.slt-pc           and
                                             rbfpb_arh-fin-doc-schet-tax.with-vat         = bfpb_arh-fin-doc-schet-tax.with-vat         and
                                             rbfpb_arh-fin-doc-schet-tax.with-slt         = bfpb_arh-fin-doc-schet-tax.with-slt         and
                                             rbfpb_arh-fin-doc-schet-tax.sum-type         = bfpb_arh-fin-doc-schet-tax.sum-type         and
                                             rbfpb_arh-fin-doc-schet-tax.fact-order       > bfpb_arh-fin-doc-schet-tax.fact-order       use-index pi exclusive-lock on error undo, return error return-value :
    assign
      rbfpb_arh-fin-doc-schet-tax.expense     = rbfpb_arh-fin-doc-schet-tax.expense     + parsum-base
      rbfpb_arh-fin-doc-schet-tax.expense-vat = rbfpb_arh-fin-doc-schet-tax.expense-vat + parsum-vat-base
      rbfpb_arh-fin-doc-schet-tax.expense-slt = rbfpb_arh-fin-doc-schet-tax.expense-slt + parsum-slt-base
    .
  end.
  if parmode = "close":u then do:
    find last borb_arh-fin-doc-schet-tax where borb_arh-fin-doc-schet-tax.host-code        = parhost-code            and
                                               borb_arh-fin-doc-schet-tax.cli-type         = parreceiver-type        and
                                               borb_arh-fin-doc-schet-tax.cli-code         = parreceiver-code        and
                                               borb_arh-fin-doc-schet-tax.code-schet       = parreceiver-code-schet  and
                                               borb_arh-fin-doc-schet-tax.fin-ext-doc-type = parfin-ext-doc-type     and
                                               borb_arh-fin-doc-schet-tax.calc-curr-code   = parbase-code            and
                                               borb_arh-fin-doc-schet-tax.vat-pc           = parvat-pc               and
                                               borb_arh-fin-doc-schet-tax.slt-pc           = parslt-pc               and
                                               borb_arh-fin-doc-schet-tax.with-vat         = parwith-vat             and
                                               borb_arh-fin-doc-schet-tax.with-slt         = parwith-slt             and
                                               borb_arh-fin-doc-schet-tax.sum-type         = parsum-type             and
                                               borb_arh-fin-doc-schet-tax.fact-order       < parfact-order           use-index pi no-error.
    create bfrb_arh-fin-doc-schet-tax.
    assign
      bfrb_arh-fin-doc-schet-tax.host-code        = parhost-code
      bfrb_arh-fin-doc-schet-tax.cli-type         = parreceiver-type
      bfrb_arh-fin-doc-schet-tax.cli-code         = parreceiver-code
      bfrb_arh-fin-doc-schet-tax.code-schet       = parreceiver-code-schet
      bfrb_arh-fin-doc-schet-tax.fin-ext-doc-type = parfin-ext-doc-type
      bfrb_arh-fin-doc-schet-tax.calc-curr-code   = parbase-code
      bfrb_arh-fin-doc-schet-tax.vat-pc           = parvat-pc
      bfrb_arh-fin-doc-schet-tax.slt-pc           = parslt-pc
      bfrb_arh-fin-doc-schet-tax.with-vat         = parwith-vat
      bfrb_arh-fin-doc-schet-tax.with-slt         = parwith-slt
      bfrb_arh-fin-doc-schet-tax.sum-type         = parsum-type
      bfrb_arh-fin-doc-schet-tax.cource-des       = "b":u
      bfrb_arh-fin-doc-schet-tax.fact-order       = parfact-order
      bfrb_arh-fin-doc-schet-tax.fin-doc-code     = parfin-doc-code
      bfrb_arh-fin-doc-schet-tax.fact-date        = parfact-date
      bfrb_arh-fin-doc-schet-tax.curr-code        = parcurr-code
    .
    assign
      bfrb_arh-fin-doc-schet-tax.expense          = (if available borb_arh-fin-doc-schet-tax then borb_arh-fin-doc-schet-tax.expense     else 0)
      bfrb_arh-fin-doc-schet-tax.expense-vat      = (if available borb_arh-fin-doc-schet-tax then borb_arh-fin-doc-schet-tax.expense-vat else 0)
      bfrb_arh-fin-doc-schet-tax.expense-slt      = (if available borb_arh-fin-doc-schet-tax then borb_arh-fin-doc-schet-tax.expense-slt else 0)
      bfrb_arh-fin-doc-schet-tax.income           = (if available borb_arh-fin-doc-schet-tax then borb_arh-fin-doc-schet-tax.income      else 0) + parsum-base
      bfrb_arh-fin-doc-schet-tax.income-vat       = (if available borb_arh-fin-doc-schet-tax then borb_arh-fin-doc-schet-tax.income-vat  else 0) + parsum-vat-base
      bfrb_arh-fin-doc-schet-tax.income-slt       = (if available borb_arh-fin-doc-schet-tax then borb_arh-fin-doc-schet-tax.income-slt  else 0) + parsum-slt-base
    .
  end.
  else do:
    find first bfrb_arh-fin-doc-schet-tax where bfrb_arh-fin-doc-schet-tax.host-code        = parhost-code            and
                                                bfrb_arh-fin-doc-schet-tax.cli-type         = parreceiver-type        and
                                                bfrb_arh-fin-doc-schet-tax.cli-code         = parreceiver-code        and
                                                bfrb_arh-fin-doc-schet-tax.code-schet       = parreceiver-code-schet  and
                                                bfrb_arh-fin-doc-schet-tax.fin-ext-doc-type = parfin-ext-doc-type     and
                                                bfrb_arh-fin-doc-schet-tax.calc-curr-code   = parbase-code            and
                                                bfrb_arh-fin-doc-schet-tax.vat-pc           = parvat-pc               and
                                                bfrb_arh-fin-doc-schet-tax.slt-pc           = parslt-pc               and
                                                bfrb_arh-fin-doc-schet-tax.with-vat         = parwith-vat             and
                                                bfrb_arh-fin-doc-schet-tax.with-slt         = parwith-slt             and
                                                bfrb_arh-fin-doc-schet-tax.sum-type         = parsum-type             and
                                                bfrb_arh-fin-doc-schet-tax.fact-order       = parfact-order           exclusive-lock.
  end.
  for each rbfrb_arh-fin-doc-schet-tax where rbfrb_arh-fin-doc-schet-tax.host-code        = bfrb_arh-fin-doc-schet-tax.host-code        and
                                             rbfrb_arh-fin-doc-schet-tax.cli-type         = parreceiver-type                            and
                                             rbfrb_arh-fin-doc-schet-tax.cli-code         = parreceiver-code                            and
                                             rbfrb_arh-fin-doc-schet-tax.code-schet       = bfrb_arh-fin-doc-schet-tax.code-schet       and
                                             rbfrb_arh-fin-doc-schet-tax.fin-ext-doc-type = bfrb_arh-fin-doc-schet-tax.fin-ext-doc-type and
                                             rbfrb_arh-fin-doc-schet-tax.calc-curr-code   = bfrb_arh-fin-doc-schet-tax.calc-curr-code   and
                                             rbfrb_arh-fin-doc-schet-tax.vat-pc           = bfrb_arh-fin-doc-schet-tax.vat-pc           and
                                             rbfrb_arh-fin-doc-schet-tax.slt-pc           = bfrb_arh-fin-doc-schet-tax.slt-pc           and
                                             rbfrb_arh-fin-doc-schet-tax.with-vat         = bfrb_arh-fin-doc-schet-tax.with-vat         and
                                             rbfrb_arh-fin-doc-schet-tax.with-slt         = bfrb_arh-fin-doc-schet-tax.with-slt         and
                                             rbfrb_arh-fin-doc-schet-tax.sum-type         = bfrb_arh-fin-doc-schet-tax.sum-type         and
                                             rbfrb_arh-fin-doc-schet-tax.fact-order       > bfrb_arh-fin-doc-schet-tax.fact-order       use-index pi exclusive-lock on error undo, return error return-value :
    assign
      rbfrb_arh-fin-doc-schet-tax.income     = rbfrb_arh-fin-doc-schet-tax.income     + parsum-base
      rbfrb_arh-fin-doc-schet-tax.income-vat = rbfrb_arh-fin-doc-schet-tax.income-vat + parsum-vat-base
      rbfrb_arh-fin-doc-schet-tax.income-slt = rbfrb_arh-fin-doc-schet-tax.income-slt + parsum-slt-base
    .
  end.
  if parmode = "delete":u then do:
    delete bfpb_arh-fin-doc-schet-tax.
    delete bfrb_arh-fin-doc-schet-tax.
  end.
end.
end.
end procedure.

/*Процедуры по расчету налогов по наличным*/
procedure libfarhp_calc-arh-fin-doc-an-n :
define input parameter parmode                    as   character                    no-undo.
define input parameter parhost-code               like ub.fin-doc.host-code         no-undo.
define input parameter parpayer-type              like ub.fin-doc.payer-type        no-undo.
define input parameter parpayer-code              like ub.fin-doc.payer-code        no-undo.
define input parameter parreceiver-type           like ub.fin-doc.receiver-type     no-undo.
define input parameter parreceiver-code           like ub.fin-doc.receiver-code     no-undo.
define input parameter parpayer-fin-code-acc      like ub.fin-code-cor-acc.fin-code no-undo.
define input parameter parreceiver-fin-code-acc   like ub.fin-code-cor-acc.fin-code no-undo.
define input parameter parfin-ext-doc-type        like ub.fin-doc.fin-ext-doc-type  no-undo.
define input parameter parfin-code-an-uchet       like ub.fin-doc.an-uchet-code     no-undo.
define input parameter parfin-code-cel-nazn       like ub.fin-doc.cel-nazn-code     no-undo.
define input parameter parfin-code-cor-acc        like ub.fin-doc.cor-acc           no-undo.
define input parameter parsum-type                as   character                    no-undo.
define input parameter parfact-order              like ub.fin-doc.fact-order        no-undo.
define input parameter parfin-doc-code            like ub.fin-doc.fin-doc-code      no-undo.
define input parameter parfact-date               like ub.fin-doc.fact-date         no-undo.
define input parameter parcurr-code               like ub.fin-doc.curr-code         no-undo.
define input parameter parbase-code               like ub.sysconf.base-code         no-undo.
define input parameter parcurr-dog-code           like ub.contract.curr-code        no-undo.
define input parameter parrel-dog-code            as   logical                      no-undo.
define input parameter parsum-doc                 as   decimal                      no-undo.
define input parameter parsum-rubl                as   decimal                      no-undo.
define input parameter parsum-base                as   decimal                      no-undo.
define input parameter parsum-contr               as   decimal                      no-undo.
define input parameter parsum-vat-doc             as   decimal                      no-undo.
define input parameter parsum-vat-rubl            as   decimal                      no-undo.
define input parameter parsum-vat-base            as   decimal                      no-undo.
define input parameter parsum-vat-contr           as   decimal                      no-undo.
define input parameter parsum-slt-doc             as   decimal                      no-undo.
define input parameter parsum-slt-rubl            as   decimal                      no-undo.
define input parameter parsum-slt-base            as   decimal                      no-undo.
define input parameter parsum-slt-contr           as   decimal                      no-undo.
define buffer bfps_arh-fin-doc-an-nal  for ub.arh-fin-doc-an-nal.
define buffer bfrs_arh-fin-doc-an-nal  for ub.arh-fin-doc-an-nal.
define buffer rbfps_arh-fin-doc-an-nal for ub.arh-fin-doc-an-nal.
define buffer rbfrs_arh-fin-doc-an-nal for ub.arh-fin-doc-an-nal.
define buffer bops_arh-fin-doc-an-nal  for ub.arh-fin-doc-an-nal.
define buffer bors_arh-fin-doc-an-nal  for ub.arh-fin-doc-an-nal.
define buffer bfpr_arh-fin-doc-an-nal  for ub.arh-fin-doc-an-nal.
define buffer bfrr_arh-fin-doc-an-nal  for ub.arh-fin-doc-an-nal.
define buffer rbfpr_arh-fin-doc-an-nal for ub.arh-fin-doc-an-nal.
define buffer rbfrr_arh-fin-doc-an-nal for ub.arh-fin-doc-an-nal.
define buffer bopr_arh-fin-doc-an-nal  for ub.arh-fin-doc-an-nal.
define buffer borr_arh-fin-doc-an-nal  for ub.arh-fin-doc-an-nal.
define buffer bfpb_arh-fin-doc-an-nal  for ub.arh-fin-doc-an-nal.
define buffer bfrb_arh-fin-doc-an-nal  for ub.arh-fin-doc-an-nal.
define buffer rbfpb_arh-fin-doc-an-nal for ub.arh-fin-doc-an-nal.
define buffer rbfrb_arh-fin-doc-an-nal for ub.arh-fin-doc-an-nal.
define buffer bopb_arh-fin-doc-an-nal  for ub.arh-fin-doc-an-nal.
define buffer borb_arh-fin-doc-an-nal  for ub.arh-fin-doc-an-nal.
define buffer bfpc_arh-fin-doc-an-nal  for ub.arh-fin-doc-an-nal.
define buffer bfrc_arh-fin-doc-an-nal  for ub.arh-fin-doc-an-nal.
define buffer rbfpc_arh-fin-doc-an-nal for ub.arh-fin-doc-an-nal.
define buffer rbfrc_arh-fin-doc-an-nal for ub.arh-fin-doc-an-nal.
define buffer bopc_arh-fin-doc-an-nal  for ub.arh-fin-doc-an-nal.
define buffer borc_arh-fin-doc-an-nal  for ub.arh-fin-doc-an-nal.
do on error undo, return error substitute ("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
if parmode = "close":u then do:
  find last bops_arh-fin-doc-an-nal where bops_arh-fin-doc-an-nal.host-code         = parhost-code          and
                                          bops_arh-fin-doc-an-nal.cli-type          = parpayer-type         and
                                          bops_arh-fin-doc-an-nal.cli-code          = parpayer-code         and
                                          bops_arh-fin-doc-an-nal.fin-code-acc      = parpayer-fin-code-acc and
                                          bops_arh-fin-doc-an-nal.curr-code         = parcurr-code          and
                                          bops_arh-fin-doc-an-nal.fin-ext-doc-type  = parfin-ext-doc-type   and
                                          bops_arh-fin-doc-an-nal.fin-code-an-uchet = parfin-code-an-uchet  and
                                          bops_arh-fin-doc-an-nal.fin-code-cel-nazn = parfin-code-cel-nazn  and
                                          bops_arh-fin-doc-an-nal.fin-code-cor-acc  = parfin-code-cor-acc   and
                                          bops_arh-fin-doc-an-nal.calc-curr-code    = parcurr-code          and
                                          bops_arh-fin-doc-an-nal.sum-type          = parsum-type           and
                                          bops_arh-fin-doc-an-nal.fact-order        < parfact-order         use-index pi no-error.
  create bfps_arh-fin-doc-an-nal.
  assign
    bfps_arh-fin-doc-an-nal.host-code         = parhost-code
    bfps_arh-fin-doc-an-nal.cli-type          = parpayer-type
    bfps_arh-fin-doc-an-nal.cli-code          = parpayer-code
    bfps_arh-fin-doc-an-nal.fin-code-acc      = parpayer-fin-code-acc
    bfps_arh-fin-doc-an-nal.fin-ext-doc-type  = parfin-ext-doc-type
    bfps_arh-fin-doc-an-nal.curr-code         = parcurr-code
    bfps_arh-fin-doc-an-nal.fin-code-an-uchet = parfin-code-an-uchet
    bfps_arh-fin-doc-an-nal.fin-code-cel-nazn = parfin-code-cel-nazn
    bfps_arh-fin-doc-an-nal.fin-code-cor-acc  = parfin-code-cor-acc
    bfps_arh-fin-doc-an-nal.calc-curr-code    = parcurr-code
    bfps_arh-fin-doc-an-nal.sum-type          = parsum-type
    bfps_arh-fin-doc-an-nal.cource-des        = "s":u
    bfps_arh-fin-doc-an-nal.fact-order        = parfact-order
    bfps_arh-fin-doc-an-nal.fin-doc-code      = parfin-doc-code
    bfps_arh-fin-doc-an-nal.fact-date         = parfact-date
    bfps_arh-fin-doc-an-nal.curr-code         = parcurr-code
    bfps_arh-fin-doc-an-nal.income            = (if available bops_arh-fin-doc-an-nal then bops_arh-fin-doc-an-nal.income      else 0)
    bfps_arh-fin-doc-an-nal.income-vat        = (if available bops_arh-fin-doc-an-nal then bops_arh-fin-doc-an-nal.income-vat  else 0)
    bfps_arh-fin-doc-an-nal.income-slt        = (if available bops_arh-fin-doc-an-nal then bops_arh-fin-doc-an-nal.income-slt  else 0)
    bfps_arh-fin-doc-an-nal.expense           = (if available bops_arh-fin-doc-an-nal then bops_arh-fin-doc-an-nal.expense     else 0) + parsum-doc
    bfps_arh-fin-doc-an-nal.expense-vat       = (if available bops_arh-fin-doc-an-nal then bops_arh-fin-doc-an-nal.expense-vat else 0) + parsum-vat-doc
    bfps_arh-fin-doc-an-nal.expense-slt       = (if available bops_arh-fin-doc-an-nal then bops_arh-fin-doc-an-nal.expense-slt else 0) + parsum-slt-doc
  .
end.
else do:
  find first bfps_arh-fin-doc-an-nal where bfps_arh-fin-doc-an-nal.host-code         = parhost-code          and
                                           bfps_arh-fin-doc-an-nal.cli-type          = parpayer-type         and
                                           bfps_arh-fin-doc-an-nal.cli-code          = parpayer-code         and
                                           bfps_arh-fin-doc-an-nal.fin-code-acc      = parpayer-fin-code-acc and
                                           bfps_arh-fin-doc-an-nal.curr-code         = parcurr-code          and
                                           bfps_arh-fin-doc-an-nal.fin-ext-doc-type  = parfin-ext-doc-type   and
                                           bfps_arh-fin-doc-an-nal.fin-code-an-uchet = parfin-code-an-uchet  and
                                           bfps_arh-fin-doc-an-nal.fin-code-cel-nazn = parfin-code-cel-nazn  and
                                           bfps_arh-fin-doc-an-nal.fin-code-cor-acc  = parfin-code-cor-acc   and
                                           bfps_arh-fin-doc-an-nal.calc-curr-code    = parcurr-code          and
                                           bfps_arh-fin-doc-an-nal.sum-type          = parsum-type           use-index pi no-error.
end.
for each rbfps_arh-fin-doc-an-nal where rbfps_arh-fin-doc-an-nal.host-code         = bfps_arh-fin-doc-an-nal.host-code         and
                                        rbfps_arh-fin-doc-an-nal.cli-type          = parpayer-type                             and
                                        rbfps_arh-fin-doc-an-nal.cli-code          = parpayer-code                             and
                                        rbfps_arh-fin-doc-an-nal.fin-ext-doc-type  = bfps_arh-fin-doc-an-nal.fin-ext-doc-type  and
                                        rbfps_arh-fin-doc-an-nal.fin-code-acc      = bfps_arh-fin-doc-an-nal.fin-code-acc      and
                                        rbfps_arh-fin-doc-an-nal.curr-code         = bfps_arh-fin-doc-an-nal.curr-code         and
                                        rbfps_arh-fin-doc-an-nal.fin-code-an-uchet = bfps_arh-fin-doc-an-nal.fin-code-an-uchet and
                                        rbfps_arh-fin-doc-an-nal.fin-code-cel-nazn = bfps_arh-fin-doc-an-nal.fin-code-cel-nazn and
                                        rbfps_arh-fin-doc-an-nal.fin-code-cor-acc  = bfps_arh-fin-doc-an-nal.fin-code-cor-acc  and
                                        rbfps_arh-fin-doc-an-nal.calc-curr-code    = bfps_arh-fin-doc-an-nal.calc-curr-code    and
                                        rbfps_arh-fin-doc-an-nal.sum-type          = bfps_arh-fin-doc-an-nal.sum-type          and
                                        rbfps_arh-fin-doc-an-nal.fact-order        > bfps_arh-fin-doc-an-nal.fact-order        use-index pi exclusive-lock on error undo, return error return-value :
  assign
    rbfps_arh-fin-doc-an-nal.expense     = rbfps_arh-fin-doc-an-nal.expense     + parsum-doc
    rbfps_arh-fin-doc-an-nal.expense-vat = rbfps_arh-fin-doc-an-nal.expense-vat + parsum-vat-doc
    rbfps_arh-fin-doc-an-nal.expense-slt = rbfps_arh-fin-doc-an-nal.expense-slt + parsum-slt-doc
  .
end.
if parmode = "close":u then do:
  find last bors_arh-fin-doc-an-nal where bors_arh-fin-doc-an-nal.host-code         = parhost-code             and
                                          bors_arh-fin-doc-an-nal.cli-type          = parreceiver-type         and
                                          bors_arh-fin-doc-an-nal.cli-code          = parreceiver-code         and
                                          bors_arh-fin-doc-an-nal.fin-code-acc      = parreceiver-fin-code-acc and
                                          bors_arh-fin-doc-an-nal.curr-code         = parcurr-code             and
                                          bors_arh-fin-doc-an-nal.fin-ext-doc-type  = parfin-ext-doc-type      and
                                          bors_arh-fin-doc-an-nal.fin-code-an-uchet = parfin-code-an-uchet     and
                                          bors_arh-fin-doc-an-nal.fin-code-cel-nazn = parfin-code-cel-nazn     and
                                          bors_arh-fin-doc-an-nal.fin-code-cor-acc  = parfin-code-cor-acc      and
                                          bors_arh-fin-doc-an-nal.calc-curr-code    = parcurr-code             and
                                          bors_arh-fin-doc-an-nal.sum-type          = parsum-type              and
                                          bors_arh-fin-doc-an-nal.fact-order        < parfact-order            use-index pi no-error.
  create bfrs_arh-fin-doc-an-nal.
  assign
    bfrs_arh-fin-doc-an-nal.host-code         = parhost-code
    bfrs_arh-fin-doc-an-nal.cli-type          = parreceiver-type
    bfrs_arh-fin-doc-an-nal.cli-code          = parreceiver-code
    bfrs_arh-fin-doc-an-nal.fin-ext-doc-type  = parfin-ext-doc-type
    bfrs_arh-fin-doc-an-nal.fin-code-acc      = parreceiver-fin-code-acc
    bfrs_arh-fin-doc-an-nal.curr-code         = parcurr-code
    bfrs_arh-fin-doc-an-nal.fin-code-an-uchet = parfin-code-an-uchet
    bfrs_arh-fin-doc-an-nal.fin-code-cel-nazn = parfin-code-cel-nazn
    bfrs_arh-fin-doc-an-nal.fin-code-cor-acc  = parfin-code-cor-acc
    bfrs_arh-fin-doc-an-nal.calc-curr-code    = parcurr-code
    bfrs_arh-fin-doc-an-nal.sum-type          = parsum-type
    bfrs_arh-fin-doc-an-nal.cource-des        = "s":u
    bfrs_arh-fin-doc-an-nal.fact-order        = parfact-order
    bfrs_arh-fin-doc-an-nal.fin-doc-code      = parfin-doc-code
    bfrs_arh-fin-doc-an-nal.fact-date         = parfact-date
    bfrs_arh-fin-doc-an-nal.curr-code         = parcurr-code
  .
  assign
    bfrs_arh-fin-doc-an-nal.expense           = (if available bors_arh-fin-doc-an-nal then bors_arh-fin-doc-an-nal.expense     else 0)
    bfrs_arh-fin-doc-an-nal.expense-vat       = (if available bors_arh-fin-doc-an-nal then bors_arh-fin-doc-an-nal.expense-vat else 0)
    bfrs_arh-fin-doc-an-nal.expense-slt       = (if available bors_arh-fin-doc-an-nal then bors_arh-fin-doc-an-nal.expense-slt else 0)
    bfrs_arh-fin-doc-an-nal.income            = (if available bors_arh-fin-doc-an-nal then bors_arh-fin-doc-an-nal.income      else 0) + parsum-doc
    bfrs_arh-fin-doc-an-nal.income-vat        = (if available bors_arh-fin-doc-an-nal then bors_arh-fin-doc-an-nal.income-vat  else 0) + parsum-vat-doc
    bfrs_arh-fin-doc-an-nal.income-slt        = (if available bors_arh-fin-doc-an-nal then bors_arh-fin-doc-an-nal.income-slt  else 0) + parsum-slt-doc
  .
end.
else do:
  find first bfrs_arh-fin-doc-an-nal where bfrs_arh-fin-doc-an-nal.host-code         = parhost-code             and
                                           bfrs_arh-fin-doc-an-nal.cli-type          = parreceiver-type         and
                                           bfrs_arh-fin-doc-an-nal.cli-code          = parreceiver-code         and
                                           bfrs_arh-fin-doc-an-nal.fin-code-acc      = parreceiver-fin-code-acc and
                                           bfrs_arh-fin-doc-an-nal.curr-code         = parcurr-code             and
                                           bfrs_arh-fin-doc-an-nal.fin-ext-doc-type  = parfin-ext-doc-type      and
                                           bfrs_arh-fin-doc-an-nal.fin-code-an-uchet = parfin-code-an-uchet     and
                                           bfrs_arh-fin-doc-an-nal.fin-code-cel-nazn = parfin-code-cel-nazn     and
                                           bfrs_arh-fin-doc-an-nal.fin-code-cor-acc  = parfin-code-cor-acc      and
                                           bfrs_arh-fin-doc-an-nal.calc-curr-code    = parcurr-code             and
                                           bfrs_arh-fin-doc-an-nal.sum-type          = parsum-type              and
                                           bfrs_arh-fin-doc-an-nal.fact-order        = parfact-order            exclusive-lock.
end.
for each rbfrs_arh-fin-doc-an-nal where rbfrs_arh-fin-doc-an-nal.host-code         = bfrs_arh-fin-doc-an-nal.host-code         and
                                        rbfrs_arh-fin-doc-an-nal.cli-type          = parreceiver-type                          and
                                        rbfrs_arh-fin-doc-an-nal.cli-code          = parreceiver-code                          and
                                        rbfrs_arh-fin-doc-an-nal.fin-ext-doc-type  = bfrs_arh-fin-doc-an-nal.fin-ext-doc-type  and
                                        rbfrs_arh-fin-doc-an-nal.fin-code-acc      = bfrs_arh-fin-doc-an-nal.fin-code-acc      and
                                        rbfrs_arh-fin-doc-an-nal.curr-code         = bfrs_arh-fin-doc-an-nal.curr-code         and
                                        rbfrs_arh-fin-doc-an-nal.fin-code-an-uchet = bfrs_arh-fin-doc-an-nal.fin-code-an-uchet and
                                        rbfrs_arh-fin-doc-an-nal.fin-code-cel-nazn = bfrs_arh-fin-doc-an-nal.fin-code-cel-nazn and
                                        rbfrs_arh-fin-doc-an-nal.fin-code-cor-acc  = bfrs_arh-fin-doc-an-nal.fin-code-cor-acc  and
                                        rbfrs_arh-fin-doc-an-nal.calc-curr-code    = bfrs_arh-fin-doc-an-nal.calc-curr-code    and
                                        rbfrs_arh-fin-doc-an-nal.sum-type          = bfrs_arh-fin-doc-an-nal.sum-type          and
                                        rbfrs_arh-fin-doc-an-nal.fact-order        > bfrs_arh-fin-doc-an-nal.fact-order        use-index pi exclusive-lock on error undo, return error return-value :
  assign
    rbfrs_arh-fin-doc-an-nal.income     = rbfrs_arh-fin-doc-an-nal.income     + parsum-doc
    rbfrs_arh-fin-doc-an-nal.income-vat = rbfrs_arh-fin-doc-an-nal.income-vat + parsum-vat-doc
    rbfrs_arh-fin-doc-an-nal.income-slt = rbfrs_arh-fin-doc-an-nal.income-slt + parsum-slt-doc
  .
end.
if parmode = "delete":u then do:
  delete bfps_arh-fin-doc-an-nal.
  delete bfrs_arh-fin-doc-an-nal.
end.
if parcurr-code <> 0 then do:
  if parmode = "close":u then do:
    find last bopr_arh-fin-doc-an-nal where bopr_arh-fin-doc-an-nal.host-code         = parhost-code          and
                                            bopr_arh-fin-doc-an-nal.cli-type          = parpayer-type         and
                                            bopr_arh-fin-doc-an-nal.cli-code          = parpayer-code         and
                                            bopr_arh-fin-doc-an-nal.fin-code-acc      = parpayer-fin-code-acc and
                                            bopr_arh-fin-doc-an-nal.curr-code         = parcurr-code          and
                                            bopr_arh-fin-doc-an-nal.fin-ext-doc-type  = parfin-ext-doc-type   and
                                            bopr_arh-fin-doc-an-nal.fin-code-an-uchet = parfin-code-an-uchet  and
                                            bopr_arh-fin-doc-an-nal.fin-code-cel-nazn = parfin-code-cel-nazn  and
                                            bopr_arh-fin-doc-an-nal.fin-code-cor-acc  = parfin-code-cor-acc   and
                                            bopr_arh-fin-doc-an-nal.calc-curr-code    = 0                     and
                                            bopr_arh-fin-doc-an-nal.sum-type          = parsum-type           and
                                            bopr_arh-fin-doc-an-nal.fact-order        < parfact-order         use-index pi no-error.
    create bfpr_arh-fin-doc-an-nal.
    assign
      bfpr_arh-fin-doc-an-nal.host-code         = parhost-code
      bfpr_arh-fin-doc-an-nal.cli-type          = parpayer-type
      bfpr_arh-fin-doc-an-nal.cli-code          = parpayer-code
      bfpr_arh-fin-doc-an-nal.fin-code-acc      = parpayer-fin-code-acc
      bfpr_arh-fin-doc-an-nal.curr-code         = parcurr-code
      bfpr_arh-fin-doc-an-nal.fin-ext-doc-type  = parfin-ext-doc-type
      bfpr_arh-fin-doc-an-nal.fin-code-an-uchet = parfin-code-an-uchet
      bfpr_arh-fin-doc-an-nal.fin-code-cel-nazn = parfin-code-cel-nazn
      bfpr_arh-fin-doc-an-nal.fin-code-cor-acc  = parfin-code-cor-acc
      bfpr_arh-fin-doc-an-nal.calc-curr-code    = 0
      bfpr_arh-fin-doc-an-nal.sum-type          = parsum-type
      bfpr_arh-fin-doc-an-nal.cource-des        = "r":u
      bfpr_arh-fin-doc-an-nal.fact-order        = parfact-order
      bfpr_arh-fin-doc-an-nal.fin-doc-code      = parfin-doc-code
      bfpr_arh-fin-doc-an-nal.fact-date         = parfact-date
      bfpr_arh-fin-doc-an-nal.curr-code         = parcurr-code
      bfpr_arh-fin-doc-an-nal.income            = (if available bopr_arh-fin-doc-an-nal then bopr_arh-fin-doc-an-nal.income      else 0)
      bfpr_arh-fin-doc-an-nal.income-vat        = (if available bopr_arh-fin-doc-an-nal then bopr_arh-fin-doc-an-nal.income-vat  else 0)
      bfpr_arh-fin-doc-an-nal.income-slt        = (if available bopr_arh-fin-doc-an-nal then bopr_arh-fin-doc-an-nal.income-slt  else 0)
      bfpr_arh-fin-doc-an-nal.expense           = (if available bopr_arh-fin-doc-an-nal then bopr_arh-fin-doc-an-nal.expense     else 0) + parsum-rubl
      bfpr_arh-fin-doc-an-nal.expense-vat       = (if available bopr_arh-fin-doc-an-nal then bopr_arh-fin-doc-an-nal.expense-vat else 0) + parsum-vat-rubl
      bfpr_arh-fin-doc-an-nal.expense-slt       = (if available bopr_arh-fin-doc-an-nal then bopr_arh-fin-doc-an-nal.expense-slt else 0) + parsum-slt-rubl
    .
  end.
  else do:
    find first bfpr_arh-fin-doc-an-nal where bfpr_arh-fin-doc-an-nal.host-code         = parhost-code          and
                                             bfpr_arh-fin-doc-an-nal.cli-type          = parpayer-type         and
                                             bfpr_arh-fin-doc-an-nal.cli-code          = parpayer-code         and
                                             bfpr_arh-fin-doc-an-nal.fin-code-acc      = parpayer-fin-code-acc and
                                             bfpr_arh-fin-doc-an-nal.curr-code         = parcurr-code          and
                                             bfpr_arh-fin-doc-an-nal.fin-ext-doc-type  = parfin-ext-doc-type   and
                                             bfpr_arh-fin-doc-an-nal.fin-code-an-uchet = parfin-code-an-uchet  and
                                             bfpr_arh-fin-doc-an-nal.fin-code-cel-nazn = parfin-code-cel-nazn  and
                                             bfpr_arh-fin-doc-an-nal.fin-code-cor-acc  = parfin-code-cor-acc   and
                                             bfpr_arh-fin-doc-an-nal.calc-curr-code    = 0                     and
                                             bfpr_arh-fin-doc-an-nal.sum-type          = parsum-type           and
                                             bfpr_arh-fin-doc-an-nal.fact-order        = parfact-order         exclusive-lock.
  end.
  for each rbfpr_arh-fin-doc-an-nal where rbfpr_arh-fin-doc-an-nal.host-code         = bfpr_arh-fin-doc-an-nal.host-code         and
                                          rbfpr_arh-fin-doc-an-nal.cli-type          = parpayer-type                             and
                                          rbfpr_arh-fin-doc-an-nal.cli-code          = parpayer-code                             and
                                          rbfpr_arh-fin-doc-an-nal.fin-code-acc      = bfpr_arh-fin-doc-an-nal.fin-code-acc      and
                                          rbfpr_arh-fin-doc-an-nal.curr-code         = bfpr_arh-fin-doc-an-nal.curr-code         and
                                          rbfpr_arh-fin-doc-an-nal.fin-ext-doc-type  = bfpr_arh-fin-doc-an-nal.fin-ext-doc-type  and
                                          rbfpr_arh-fin-doc-an-nal.fin-code-an-uchet = bfpr_arh-fin-doc-an-nal.fin-code-an-uchet and
                                          rbfpr_arh-fin-doc-an-nal.fin-code-cel-nazn = bfpr_arh-fin-doc-an-nal.fin-code-cel-nazn and
                                          rbfpr_arh-fin-doc-an-nal.fin-code-cor-acc  = bfpr_arh-fin-doc-an-nal.fin-code-cor-acc  and
                                          rbfpr_arh-fin-doc-an-nal.calc-curr-code    = bfpr_arh-fin-doc-an-nal.calc-curr-code    and
                                          rbfpr_arh-fin-doc-an-nal.sum-type          = bfpr_arh-fin-doc-an-nal.sum-type          and
                                          rbfpr_arh-fin-doc-an-nal.fact-order        > bfpr_arh-fin-doc-an-nal.fact-order        use-index pi on error undo, return error return-value :
    assign
      rbfpr_arh-fin-doc-an-nal.expense     = rbfpr_arh-fin-doc-an-nal.expense     + parsum-rubl
      rbfpr_arh-fin-doc-an-nal.expense-vat = rbfpr_arh-fin-doc-an-nal.expense-vat + parsum-vat-rubl
      rbfpr_arh-fin-doc-an-nal.expense-slt = rbfpr_arh-fin-doc-an-nal.expense-slt + parsum-slt-rubl
    .
  end.
  if parmode = "close":u then do:
    find last borr_arh-fin-doc-an-nal where borr_arh-fin-doc-an-nal.host-code         = parhost-code             and
                                            borr_arh-fin-doc-an-nal.cli-type          = parreceiver-type         and
                                            borr_arh-fin-doc-an-nal.cli-code          = parreceiver-code         and
                                            borr_arh-fin-doc-an-nal.fin-code-acc      = parreceiver-fin-code-acc and
                                            borr_arh-fin-doc-an-nal.curr-code         = parcurr-code             and
                                            borr_arh-fin-doc-an-nal.fin-ext-doc-type  = parfin-ext-doc-type      and
                                            borr_arh-fin-doc-an-nal.fin-code-an-uchet = parfin-code-an-uchet     and
                                            borr_arh-fin-doc-an-nal.fin-code-cel-nazn = parfin-code-cel-nazn     and
                                            borr_arh-fin-doc-an-nal.fin-code-cor-acc  = parfin-code-cor-acc      and
                                            borr_arh-fin-doc-an-nal.calc-curr-code    = 0                        and
                                            borr_arh-fin-doc-an-nal.sum-type          = parsum-type              and
                                            borr_arh-fin-doc-an-nal.fact-order        < parfact-order            use-index pi no-error.
    create bfrr_arh-fin-doc-an-nal.
    assign
      bfrr_arh-fin-doc-an-nal.host-code         = parhost-code
      bfrr_arh-fin-doc-an-nal.cli-type          = parreceiver-type
      bfrr_arh-fin-doc-an-nal.cli-code          = parreceiver-code
      bfrr_arh-fin-doc-an-nal.fin-code-acc      = parreceiver-fin-code-acc
      bfrr_arh-fin-doc-an-nal.curr-code         = parcurr-code
      bfrr_arh-fin-doc-an-nal.fin-ext-doc-type  = parfin-ext-doc-type
      bfrr_arh-fin-doc-an-nal.fin-code-an-uchet = parfin-code-an-uchet
      bfrr_arh-fin-doc-an-nal.fin-code-cel-nazn = parfin-code-cel-nazn
      bfrr_arh-fin-doc-an-nal.fin-code-cor-acc  = parfin-code-cor-acc
      bfrr_arh-fin-doc-an-nal.calc-curr-code    = 0
      bfrr_arh-fin-doc-an-nal.sum-type          = parsum-type
      bfrr_arh-fin-doc-an-nal.cource-des        = "r":u
      bfrr_arh-fin-doc-an-nal.fact-order        = parfact-order
      bfrr_arh-fin-doc-an-nal.fin-doc-code      = parfin-doc-code
      bfrr_arh-fin-doc-an-nal.fact-date         = parfact-date
      bfrr_arh-fin-doc-an-nal.curr-code         = parcurr-code
     .
    assign
      bfrr_arh-fin-doc-an-nal.expense           = (if available borr_arh-fin-doc-an-nal then borr_arh-fin-doc-an-nal.expense     else 0)
      bfrr_arh-fin-doc-an-nal.expense-vat       = (if available borr_arh-fin-doc-an-nal then borr_arh-fin-doc-an-nal.expense-vat else 0)
      bfrr_arh-fin-doc-an-nal.expense-slt       = (if available borr_arh-fin-doc-an-nal then borr_arh-fin-doc-an-nal.expense-slt else 0)
      bfrr_arh-fin-doc-an-nal.income            = (if available borr_arh-fin-doc-an-nal then borr_arh-fin-doc-an-nal.income      else 0) + parsum-rubl
      bfrr_arh-fin-doc-an-nal.income-vat        = (if available borr_arh-fin-doc-an-nal then borr_arh-fin-doc-an-nal.income-vat  else 0) + parsum-vat-rubl
      bfrr_arh-fin-doc-an-nal.income-slt        = (if available borr_arh-fin-doc-an-nal then borr_arh-fin-doc-an-nal.income-slt  else 0) + parsum-slt-rubl
    .
  end.
  else do:
    find first bfrr_arh-fin-doc-an-nal where bfrr_arh-fin-doc-an-nal.host-code         = parhost-code             and
                                             bfrr_arh-fin-doc-an-nal.cli-type          = parreceiver-type         and
                                             bfrr_arh-fin-doc-an-nal.cli-code          = parreceiver-code         and
                                             bfrr_arh-fin-doc-an-nal.fin-code-acc      = parreceiver-fin-code-acc and
                                             bfrr_arh-fin-doc-an-nal.curr-code         = parcurr-code             and
                                             bfrr_arh-fin-doc-an-nal.fin-ext-doc-type  = parfin-ext-doc-type      and
                                             bfrr_arh-fin-doc-an-nal.fin-code-an-uchet = parfin-code-an-uchet     and
                                             bfrr_arh-fin-doc-an-nal.fin-code-cel-nazn = parfin-code-cel-nazn     and
                                             bfrr_arh-fin-doc-an-nal.fin-code-cor-acc  = parfin-code-cor-acc      and
                                             bfrr_arh-fin-doc-an-nal.calc-curr-code    = 0                        and
                                             bfrr_arh-fin-doc-an-nal.sum-type          = parsum-type              and
                                             bfrr_arh-fin-doc-an-nal.fact-order        = parfact-order            exclusive-lock.
  end.
  for each rbfrr_arh-fin-doc-an-nal where rbfrr_arh-fin-doc-an-nal.host-code         = bfrr_arh-fin-doc-an-nal.host-code         and
                                          rbfrr_arh-fin-doc-an-nal.cli-type          = parreceiver-type                          and
                                          rbfrr_arh-fin-doc-an-nal.cli-code          = parreceiver-code                          and
                                          rbfrr_arh-fin-doc-an-nal.fin-code-acc      = bfrr_arh-fin-doc-an-nal.fin-code-acc      and
                                          rbfrr_arh-fin-doc-an-nal.curr-code         = bfrr_arh-fin-doc-an-nal.curr-code         and
                                          rbfrr_arh-fin-doc-an-nal.fin-ext-doc-type  = bfrr_arh-fin-doc-an-nal.fin-ext-doc-type  and
                                          rbfrr_arh-fin-doc-an-nal.fin-code-an-uchet = bfrr_arh-fin-doc-an-nal.fin-code-an-uchet and
                                          rbfrr_arh-fin-doc-an-nal.fin-code-cel-nazn = bfrr_arh-fin-doc-an-nal.fin-code-cel-nazn and
                                          rbfrr_arh-fin-doc-an-nal.fin-code-cor-acc  = bfrr_arh-fin-doc-an-nal.fin-code-cor-acc  and
                                          rbfrr_arh-fin-doc-an-nal.calc-curr-code    = bfrr_arh-fin-doc-an-nal.calc-curr-code    and
                                          rbfrr_arh-fin-doc-an-nal.sum-type          = bfrr_arh-fin-doc-an-nal.sum-type          and
                                          rbfrr_arh-fin-doc-an-nal.fact-order        > bfrr_arh-fin-doc-an-nal.fact-order        use-index pi exclusive-lock on error undo, return error return-value :
    assign
      rbfrr_arh-fin-doc-an-nal.income     = rbfrr_arh-fin-doc-an-nal.income     + parsum-rubl
      rbfrr_arh-fin-doc-an-nal.income-vat = rbfrr_arh-fin-doc-an-nal.income-vat + parsum-vat-rubl
      rbfrr_arh-fin-doc-an-nal.income-slt = rbfrr_arh-fin-doc-an-nal.income-slt + parsum-slt-rubl
    .
  end.
  if parmode = "delete":u then do:
      delete bfpr_arh-fin-doc-an-nal.
      delete bfrr_arh-fin-doc-an-nal.
  end.
end.
if parbase-code <> parcurr-code and
   parbase-code <> 0            then do:
  if parmode = "close":u then do:
    find last bopb_arh-fin-doc-an-nal where bopb_arh-fin-doc-an-nal.host-code         = parhost-code          and
                                            bopb_arh-fin-doc-an-nal.cli-type          = parpayer-type         and
                                            bopb_arh-fin-doc-an-nal.cli-code          = parpayer-code         and
                                            bopb_arh-fin-doc-an-nal.fin-code-acc      = parpayer-fin-code-acc and
                                            bopb_arh-fin-doc-an-nal.curr-code         = parcurr-code          and
                                            bopb_arh-fin-doc-an-nal.fin-ext-doc-type  = parfin-ext-doc-type   and
                                            bopb_arh-fin-doc-an-nal.fin-code-an-uchet = parfin-code-an-uchet  and
                                            bopb_arh-fin-doc-an-nal.fin-code-cel-nazn = parfin-code-cel-nazn  and
                                            bopb_arh-fin-doc-an-nal.fin-code-cor-acc  = parfin-code-cor-acc   and
                                            bopb_arh-fin-doc-an-nal.calc-curr-code    = parbase-code          and
                                            bopb_arh-fin-doc-an-nal.sum-type          = parsum-type           and
                                            bopb_arh-fin-doc-an-nal.fact-order        < parfact-order         use-index pi no-error.
    create bfpb_arh-fin-doc-an-nal.
    assign
      bfpb_arh-fin-doc-an-nal.host-code         = parhost-code
      bfpb_arh-fin-doc-an-nal.cli-type          = parpayer-type
      bfpb_arh-fin-doc-an-nal.cli-code          = parpayer-code
      bfpb_arh-fin-doc-an-nal.fin-code-acc      = parpayer-fin-code-acc
      bfpb_arh-fin-doc-an-nal.curr-code         = parcurr-code
      bfpb_arh-fin-doc-an-nal.fin-ext-doc-type  = parfin-ext-doc-type
      bfpb_arh-fin-doc-an-nal.fin-code-an-uchet = parfin-code-an-uchet
      bfpb_arh-fin-doc-an-nal.fin-code-cel-nazn = parfin-code-cel-nazn
      bfpb_arh-fin-doc-an-nal.fin-code-cor-acc  = parfin-code-cor-acc
      bfpb_arh-fin-doc-an-nal.calc-curr-code    = parbase-code
      bfpb_arh-fin-doc-an-nal.sum-type          = parsum-type
      bfpb_arh-fin-doc-an-nal.cource-des        = "b":u
      bfpb_arh-fin-doc-an-nal.fact-order        = parfact-order
      bfpb_arh-fin-doc-an-nal.fin-doc-code      = parfin-doc-code
      bfpb_arh-fin-doc-an-nal.fact-date         = parfact-date
      bfpb_arh-fin-doc-an-nal.curr-code         = parcurr-code
      bfpb_arh-fin-doc-an-nal.income            = (if available bopb_arh-fin-doc-an-nal then bopb_arh-fin-doc-an-nal.income      else 0)
      bfpb_arh-fin-doc-an-nal.income-vat        = (if available bopb_arh-fin-doc-an-nal then bopb_arh-fin-doc-an-nal.income-vat  else 0)
      bfpb_arh-fin-doc-an-nal.income-slt        = (if available bopb_arh-fin-doc-an-nal then bopb_arh-fin-doc-an-nal.income-slt  else 0)
      bfpb_arh-fin-doc-an-nal.expense           = (if available bopb_arh-fin-doc-an-nal then bopb_arh-fin-doc-an-nal.expense     else 0) + parsum-base
      bfpb_arh-fin-doc-an-nal.expense-vat       = (if available bopb_arh-fin-doc-an-nal then bopb_arh-fin-doc-an-nal.expense-vat else 0) + parsum-vat-base
      bfpb_arh-fin-doc-an-nal.expense-slt       = (if available bopb_arh-fin-doc-an-nal then bopb_arh-fin-doc-an-nal.expense-slt else 0) + parsum-slt-base
    .
  end.
  else do:
    find first bfpb_arh-fin-doc-an-nal where bfpb_arh-fin-doc-an-nal.host-code         = parhost-code          and
                                             bfpb_arh-fin-doc-an-nal.cli-type          = parpayer-type         and
                                             bfpb_arh-fin-doc-an-nal.cli-code          = parpayer-code         and
                                             bfpb_arh-fin-doc-an-nal.fin-code-acc      = parpayer-fin-code-acc and
                                             bfpb_arh-fin-doc-an-nal.curr-code         = parcurr-code          and
                                             bfpb_arh-fin-doc-an-nal.fin-ext-doc-type  = parfin-ext-doc-type   and
                                             bfpb_arh-fin-doc-an-nal.fin-code-an-uchet = parfin-code-an-uchet  and
                                             bfpb_arh-fin-doc-an-nal.fin-code-cel-nazn = parfin-code-cel-nazn  and
                                             bfpb_arh-fin-doc-an-nal.fin-code-cor-acc  = parfin-code-cor-acc   and
                                             bfpb_arh-fin-doc-an-nal.calc-curr-code    = parbase-code          and
                                             bfpb_arh-fin-doc-an-nal.sum-type          = parsum-type           and
                                             bfpb_arh-fin-doc-an-nal.fact-order        = parfact-order         exclusive-lock.
  end.
  for each rbfpb_arh-fin-doc-an-nal where rbfpb_arh-fin-doc-an-nal.host-code         = bfpb_arh-fin-doc-an-nal.host-code         and
                                          rbfpb_arh-fin-doc-an-nal.cli-type          = parpayer-type                             and
                                          rbfpb_arh-fin-doc-an-nal.cli-code          = parpayer-code                             and
                                          rbfpb_arh-fin-doc-an-nal.fin-code-acc      = bfpb_arh-fin-doc-an-nal.fin-code-acc      and
                                          rbfpb_arh-fin-doc-an-nal.curr-code         = bfpb_arh-fin-doc-an-nal.curr-code         and
                                          rbfpb_arh-fin-doc-an-nal.fin-ext-doc-type  = bfpb_arh-fin-doc-an-nal.fin-ext-doc-type  and
                                          rbfpb_arh-fin-doc-an-nal.fin-code-an-uchet = bfpb_arh-fin-doc-an-nal.fin-code-an-uchet and
                                          rbfpb_arh-fin-doc-an-nal.fin-code-cel-nazn = bfpb_arh-fin-doc-an-nal.fin-code-cel-nazn and
                                          rbfpb_arh-fin-doc-an-nal.fin-code-cor-acc  = bfpb_arh-fin-doc-an-nal.fin-code-cor-acc  and
                                          rbfpb_arh-fin-doc-an-nal.calc-curr-code    = bfpb_arh-fin-doc-an-nal.calc-curr-code    and
                                          rbfpb_arh-fin-doc-an-nal.sum-type          = bfpb_arh-fin-doc-an-nal.sum-type          and
                                          rbfpb_arh-fin-doc-an-nal.fact-order        > bfpb_arh-fin-doc-an-nal.fact-order        use-index pi exclusive-lock on error undo, return error return-value :
    assign
      rbfpb_arh-fin-doc-an-nal.expense     = rbfpb_arh-fin-doc-an-nal.expense     + parsum-base
      rbfpb_arh-fin-doc-an-nal.expense-vat = rbfpb_arh-fin-doc-an-nal.expense-vat + parsum-vat-base
      rbfpb_arh-fin-doc-an-nal.expense-slt = rbfpb_arh-fin-doc-an-nal.expense-slt + parsum-slt-base
    .
  end.
  if parmode = "close":u then do:
    find last borb_arh-fin-doc-an-nal where borb_arh-fin-doc-an-nal.host-code         = parhost-code             and
                                            borb_arh-fin-doc-an-nal.cli-type          = parreceiver-type         and
                                            borb_arh-fin-doc-an-nal.cli-code          = parreceiver-code         and
                                            borb_arh-fin-doc-an-nal.fin-code-acc      = parreceiver-fin-code-acc and
                                            borb_arh-fin-doc-an-nal.curr-code         = parcurr-code             and
                                            borb_arh-fin-doc-an-nal.fin-ext-doc-type  = parfin-ext-doc-type      and
                                            borb_arh-fin-doc-an-nal.fin-code-an-uchet = parfin-code-an-uchet     and
                                            borb_arh-fin-doc-an-nal.fin-code-cel-nazn = parfin-code-cel-nazn     and
                                            borb_arh-fin-doc-an-nal.fin-code-cor-acc  = parfin-code-cor-acc      and
                                            borb_arh-fin-doc-an-nal.calc-curr-code    = parbase-code             and
                                            borb_arh-fin-doc-an-nal.sum-type          = parsum-type              and
                                            borb_arh-fin-doc-an-nal.fact-order        < parfact-order            use-index pi no-error.
    create bfrb_arh-fin-doc-an-nal.
    assign
      bfrb_arh-fin-doc-an-nal.host-code         = parhost-code
      bfrb_arh-fin-doc-an-nal.cli-type          = parreceiver-type
      bfrb_arh-fin-doc-an-nal.cli-code          = parreceiver-code
      bfrb_arh-fin-doc-an-nal.fin-code-acc      = parreceiver-fin-code-acc
      bfrb_arh-fin-doc-an-nal.curr-code         = parcurr-code
      bfrb_arh-fin-doc-an-nal.fin-ext-doc-type  = parfin-ext-doc-type
      bfrb_arh-fin-doc-an-nal.fin-code-an-uchet = parfin-code-an-uchet
      bfrb_arh-fin-doc-an-nal.fin-code-cel-nazn = parfin-code-cel-nazn
      bfrb_arh-fin-doc-an-nal.fin-code-cor-acc  = parfin-code-cor-acc
      bfrb_arh-fin-doc-an-nal.calc-curr-code    = parbase-code
      bfrb_arh-fin-doc-an-nal.sum-type          = parsum-type
      bfrb_arh-fin-doc-an-nal.cource-des        = "b":u
      bfrb_arh-fin-doc-an-nal.fact-order        = parfact-order
      bfrb_arh-fin-doc-an-nal.fin-doc-code      = parfin-doc-code
      bfrb_arh-fin-doc-an-nal.fact-date         = parfact-date
      bfrb_arh-fin-doc-an-nal.curr-code         = parcurr-code
    .
    assign
      bfrb_arh-fin-doc-an-nal.expense           = (if available borb_arh-fin-doc-an-nal then borb_arh-fin-doc-an-nal.expense     else 0)
      bfrb_arh-fin-doc-an-nal.expense-vat       = (if available borb_arh-fin-doc-an-nal then borb_arh-fin-doc-an-nal.expense-vat else 0)
      bfrb_arh-fin-doc-an-nal.expense-slt       = (if available borb_arh-fin-doc-an-nal then borb_arh-fin-doc-an-nal.expense-slt else 0)
      bfrb_arh-fin-doc-an-nal.income            = (if available borb_arh-fin-doc-an-nal then borb_arh-fin-doc-an-nal.income      else 0) + parsum-base
      bfrb_arh-fin-doc-an-nal.income-vat        = (if available borb_arh-fin-doc-an-nal then borb_arh-fin-doc-an-nal.income-vat  else 0) + parsum-vat-base
      bfrb_arh-fin-doc-an-nal.income-slt        = (if available borb_arh-fin-doc-an-nal then borb_arh-fin-doc-an-nal.income-slt  else 0) + parsum-slt-base
    .
  end.
  else do:
    find first bfrb_arh-fin-doc-an-nal where bfrb_arh-fin-doc-an-nal.host-code         = parhost-code             and
                                             bfrb_arh-fin-doc-an-nal.cli-type          = parreceiver-type         and
                                             bfrb_arh-fin-doc-an-nal.cli-code          = parreceiver-code         and
                                             bfrb_arh-fin-doc-an-nal.fin-code-acc      = parreceiver-fin-code-acc and
                                             bfrb_arh-fin-doc-an-nal.curr-code         = parcurr-code             and
                                             bfrb_arh-fin-doc-an-nal.fin-ext-doc-type  = parfin-ext-doc-type      and
                                             bfrb_arh-fin-doc-an-nal.fin-code-an-uchet = parfin-code-an-uchet     and
                                             bfrb_arh-fin-doc-an-nal.fin-code-cel-nazn = parfin-code-cel-nazn     and
                                             bfrb_arh-fin-doc-an-nal.fin-code-cor-acc  = parfin-code-cor-acc      and
                                             bfrb_arh-fin-doc-an-nal.calc-curr-code    = parbase-code             and
                                             bfrb_arh-fin-doc-an-nal.sum-type          = parsum-type              and
                                             bfrb_arh-fin-doc-an-nal.fact-order        = parfact-order            exclusive-lock.
  end.
  for each rbfrb_arh-fin-doc-an-nal where rbfrb_arh-fin-doc-an-nal.host-code         = bfrb_arh-fin-doc-an-nal.host-code         and
                                          rbfrb_arh-fin-doc-an-nal.cli-type          = parreceiver-type                          and
                                          rbfrb_arh-fin-doc-an-nal.cli-code          = parreceiver-code                          and
                                          rbfrb_arh-fin-doc-an-nal.fin-code-acc      = bfrb_arh-fin-doc-an-nal.fin-code-acc      and
                                          rbfrb_arh-fin-doc-an-nal.curr-code         = bfrb_arh-fin-doc-an-nal.curr-code         and
                                          rbfrb_arh-fin-doc-an-nal.fin-ext-doc-type  = bfrb_arh-fin-doc-an-nal.fin-ext-doc-type  and
                                          rbfrb_arh-fin-doc-an-nal.fin-code-an-uchet = bfrb_arh-fin-doc-an-nal.fin-code-an-uchet and
                                          rbfrb_arh-fin-doc-an-nal.fin-code-cel-nazn = bfrb_arh-fin-doc-an-nal.fin-code-cel-nazn and
                                          rbfrb_arh-fin-doc-an-nal.fin-code-cor-acc  = bfrb_arh-fin-doc-an-nal.fin-code-cor-acc  and
                                          rbfrb_arh-fin-doc-an-nal.calc-curr-code    = bfrb_arh-fin-doc-an-nal.calc-curr-code    and
                                          rbfrb_arh-fin-doc-an-nal.sum-type          = bfrb_arh-fin-doc-an-nal.sum-type          and
                                          rbfrb_arh-fin-doc-an-nal.fact-order        > bfrb_arh-fin-doc-an-nal.fact-order        use-index pi exclusive-lock on error undo, return error return-value :
   assign
     rbfrb_arh-fin-doc-an-nal.income     = rbfrb_arh-fin-doc-an-nal.income     + parsum-base
     rbfrb_arh-fin-doc-an-nal.income-vat = rbfrb_arh-fin-doc-an-nal.income-vat + parsum-vat-base
     rbfrb_arh-fin-doc-an-nal.income-slt = rbfrb_arh-fin-doc-an-nal.income-slt + parsum-slt-base
   .
  end.
  if parmode = "delete":u then do:
    delete bfpb_arh-fin-doc-an-nal.
    delete bfrb_arh-fin-doc-an-nal.
  end.
end.
if parrel-dog-code  =  yes          and
   parcurr-dog-code <> parcurr-code and
   parcurr-dog-code <> 0            and
   parcurr-dog-code <> parbase-code then do:
  if parmode = "close":u then do:
    find last bopc_arh-fin-doc-an-nal where bopc_arh-fin-doc-an-nal.host-code         = parhost-code          and
                                            bopc_arh-fin-doc-an-nal.cli-type          = parpayer-type         and
                                            bopc_arh-fin-doc-an-nal.cli-code          = parpayer-code         and
                                            bopc_arh-fin-doc-an-nal.fin-code-acc      = parpayer-fin-code-acc and
                                            bopc_arh-fin-doc-an-nal.curr-code         = parcurr-code          and
                                            bopc_arh-fin-doc-an-nal.fin-ext-doc-type  = parfin-ext-doc-type   and
                                            bopc_arh-fin-doc-an-nal.fin-code-an-uchet = parfin-code-an-uchet  and
                                            bopc_arh-fin-doc-an-nal.fin-code-cel-nazn = parfin-code-cel-nazn  and
                                            bopc_arh-fin-doc-an-nal.fin-code-cor-acc  = parfin-code-cor-acc   and
                                            bopc_arh-fin-doc-an-nal.calc-curr-code    = parcurr-dog-code      and
                                            bopc_arh-fin-doc-an-nal.sum-type          = parsum-type           and
                                            bopc_arh-fin-doc-an-nal.fact-order        < parfact-order         use-index pi no-error.
    create bfpc_arh-fin-doc-an-nal.
    assign
      bfpc_arh-fin-doc-an-nal.host-code         = parhost-code
      bfpc_arh-fin-doc-an-nal.cli-type          = parpayer-type
      bfpc_arh-fin-doc-an-nal.cli-code          = parpayer-code
      bfpc_arh-fin-doc-an-nal.fin-code-acc      = parpayer-fin-code-acc
      bfpc_arh-fin-doc-an-nal.curr-code         = parcurr-code
      bfpc_arh-fin-doc-an-nal.fin-ext-doc-type  = parfin-ext-doc-type
      bfpc_arh-fin-doc-an-nal.fin-code-an-uchet = parfin-code-an-uchet
      bfpc_arh-fin-doc-an-nal.fin-code-cel-nazn = parfin-code-cel-nazn
      bfpc_arh-fin-doc-an-nal.fin-code-cor-acc  = parfin-code-cor-acc
      bfpc_arh-fin-doc-an-nal.calc-curr-code    = parcurr-dog-code
      bfpc_arh-fin-doc-an-nal.sum-type          = parsum-type
      bfpc_arh-fin-doc-an-nal.cource-des        = "c":u
      bfpc_arh-fin-doc-an-nal.fact-order        = parfact-order
      bfpc_arh-fin-doc-an-nal.fin-doc-code      = parfin-doc-code
      bfpc_arh-fin-doc-an-nal.fact-date         = parfact-date
      bfpc_arh-fin-doc-an-nal.curr-code         = parcurr-code
      bfpc_arh-fin-doc-an-nal.income            = (if available bopc_arh-fin-doc-an-nal then bopc_arh-fin-doc-an-nal.income      else 0)
      bfpc_arh-fin-doc-an-nal.income-vat        = (if available bopc_arh-fin-doc-an-nal then bopc_arh-fin-doc-an-nal.income-vat  else 0)
      bfpc_arh-fin-doc-an-nal.income-slt        = (if available bopc_arh-fin-doc-an-nal then bopc_arh-fin-doc-an-nal.income-slt  else 0)
      bfpc_arh-fin-doc-an-nal.expense           = (if available bopc_arh-fin-doc-an-nal then bopc_arh-fin-doc-an-nal.expense     else 0) + parsum-contr
      bfpc_arh-fin-doc-an-nal.expense-vat       = (if available bopc_arh-fin-doc-an-nal then bopc_arh-fin-doc-an-nal.expense-vat else 0) + parsum-vat-contr
      bfpc_arh-fin-doc-an-nal.expense-slt       = (if available bopc_arh-fin-doc-an-nal then bopc_arh-fin-doc-an-nal.expense-slt else 0) + parsum-slt-contr
    .
  end.
  else do:
    find first bfpc_arh-fin-doc-an-nal where bfpc_arh-fin-doc-an-nal.host-code         = parhost-code          and
                                             bfpc_arh-fin-doc-an-nal.cli-type          = parpayer-type         and
                                             bfpc_arh-fin-doc-an-nal.cli-code          = parpayer-code         and
                                             bfpc_arh-fin-doc-an-nal.fin-code-acc      = parpayer-fin-code-acc and
                                             bfpc_arh-fin-doc-an-nal.curr-code         = parcurr-code          and
                                             bfpc_arh-fin-doc-an-nal.fin-ext-doc-type  = parfin-ext-doc-type   and
                                             bfpc_arh-fin-doc-an-nal.fin-code-an-uchet = parfin-code-an-uchet  and
                                             bfpc_arh-fin-doc-an-nal.fin-code-cel-nazn = parfin-code-cel-nazn  and
                                             bfpc_arh-fin-doc-an-nal.fin-code-cor-acc  = parfin-code-cor-acc   and
                                             bfpc_arh-fin-doc-an-nal.calc-curr-code    = parcurr-dog-code      and
                                             bfpc_arh-fin-doc-an-nal.sum-type          = parsum-type           and
                                             bfpc_arh-fin-doc-an-nal.fact-order        = parfact-order         exclusive-lock.
  end.
  for each rbfpc_arh-fin-doc-an-nal where rbfpc_arh-fin-doc-an-nal.host-code         = bfpc_arh-fin-doc-an-nal.host-code         and
                                          rbfpc_arh-fin-doc-an-nal.cli-type          = parpayer-type                             and
                                          rbfpc_arh-fin-doc-an-nal.cli-code          = parpayer-code                             and
                                          rbfpc_arh-fin-doc-an-nal.fin-code-acc      = bfpc_arh-fin-doc-an-nal.fin-code-acc      and
                                          rbfpc_arh-fin-doc-an-nal.curr-code         = bfpc_arh-fin-doc-an-nal.curr-code         and
                                          rbfpc_arh-fin-doc-an-nal.fin-ext-doc-type  = bfpc_arh-fin-doc-an-nal.fin-ext-doc-type  and
                                          rbfpc_arh-fin-doc-an-nal.fin-code-an-uchet = bfpc_arh-fin-doc-an-nal.fin-code-an-uchet and
                                          rbfpc_arh-fin-doc-an-nal.fin-code-cel-nazn = bfpc_arh-fin-doc-an-nal.fin-code-cel-nazn and
                                          rbfpc_arh-fin-doc-an-nal.fin-code-cor-acc  = bfpc_arh-fin-doc-an-nal.fin-code-cor-acc  and
                                          rbfpc_arh-fin-doc-an-nal.calc-curr-code    = bfpc_arh-fin-doc-an-nal.calc-curr-code    and
                                          rbfpc_arh-fin-doc-an-nal.sum-type          = bfpc_arh-fin-doc-an-nal.sum-type          and
                                          rbfpc_arh-fin-doc-an-nal.fact-order        > bfpc_arh-fin-doc-an-nal.fact-order        use-index pi exclusive-lock on error undo, return error return-value :
    assign
      rbfpc_arh-fin-doc-an-nal.expense     = rbfpc_arh-fin-doc-an-nal.expense     + parsum-contr
      rbfpc_arh-fin-doc-an-nal.expense-vat = rbfpc_arh-fin-doc-an-nal.expense-vat + parsum-vat-contr
      rbfpc_arh-fin-doc-an-nal.expense-slt = rbfpc_arh-fin-doc-an-nal.expense-slt + parsum-slt-contr
    .
  end.
  if parmode = "close":u then do:
    find last borc_arh-fin-doc-an-nal where borc_arh-fin-doc-an-nal.host-code         = parhost-code             and
                                            borc_arh-fin-doc-an-nal.cli-type          = parreceiver-type         and
                                            borc_arh-fin-doc-an-nal.cli-code          = parreceiver-code         and
                                            borc_arh-fin-doc-an-nal.fin-code-acc      = parreceiver-fin-code-acc and
                                            borc_arh-fin-doc-an-nal.curr-code         = parcurr-code             and
                                            borc_arh-fin-doc-an-nal.fin-ext-doc-type  = parfin-ext-doc-type      and
                                            borc_arh-fin-doc-an-nal.fin-code-an-uchet = parfin-code-an-uchet     and
                                            borc_arh-fin-doc-an-nal.fin-code-cel-nazn = parfin-code-cel-nazn     and
                                            borc_arh-fin-doc-an-nal.fin-code-cor-acc  = parfin-code-cor-acc      and
                                            borc_arh-fin-doc-an-nal.calc-curr-code    = parcurr-dog-code         and
                                            borc_arh-fin-doc-an-nal.sum-type          = parsum-type              and
                                            borc_arh-fin-doc-an-nal.fact-order        < parfact-order            use-index pi no-error.
    create bfrc_arh-fin-doc-an-nal.
    assign
      bfrc_arh-fin-doc-an-nal.host-code         = parhost-code
      bfrc_arh-fin-doc-an-nal.cli-type          = parreceiver-type
      bfrc_arh-fin-doc-an-nal.cli-code          = parreceiver-code
      bfrc_arh-fin-doc-an-nal.fin-code-acc      = parreceiver-fin-code-acc
      bfrc_arh-fin-doc-an-nal.curr-code         = parcurr-code
      bfrc_arh-fin-doc-an-nal.fin-ext-doc-type  = parfin-ext-doc-type
      bfrc_arh-fin-doc-an-nal.fin-code-an-uchet = parfin-code-an-uchet
      bfrc_arh-fin-doc-an-nal.fin-code-cel-nazn = parfin-code-cel-nazn
      bfrc_arh-fin-doc-an-nal.fin-code-cor-acc  = parfin-code-cor-acc
      bfrc_arh-fin-doc-an-nal.calc-curr-code    = parcurr-dog-code
      bfrc_arh-fin-doc-an-nal.sum-type          = parsum-type
      bfrc_arh-fin-doc-an-nal.cource-des        = "c":u
      bfrc_arh-fin-doc-an-nal.fact-order        = parfact-order
      bfrc_arh-fin-doc-an-nal.fin-doc-code      = parfin-doc-code
      bfrc_arh-fin-doc-an-nal.fact-date         = parfact-date
      bfrc_arh-fin-doc-an-nal.curr-code         = parcurr-code
    .
    assign
      bfrc_arh-fin-doc-an-nal.expense           = (if available borc_arh-fin-doc-an-nal then borc_arh-fin-doc-an-nal.expense     else 0)
      bfrc_arh-fin-doc-an-nal.expense-vat       = (if available borc_arh-fin-doc-an-nal then borc_arh-fin-doc-an-nal.expense-vat else 0)
      bfrc_arh-fin-doc-an-nal.expense-slt       = (if available borc_arh-fin-doc-an-nal then borc_arh-fin-doc-an-nal.expense-slt else 0)
      bfrc_arh-fin-doc-an-nal.income            = (if available borc_arh-fin-doc-an-nal then borc_arh-fin-doc-an-nal.income      else 0) + parsum-contr
      bfrc_arh-fin-doc-an-nal.income-vat        = (if available borc_arh-fin-doc-an-nal then borc_arh-fin-doc-an-nal.income-vat  else 0) + parsum-vat-contr
      bfrc_arh-fin-doc-an-nal.income-slt        = (if available borc_arh-fin-doc-an-nal then borc_arh-fin-doc-an-nal.income-slt  else 0) + parsum-slt-contr
    .
  end.
  else do:
    find first bfrc_arh-fin-doc-an-nal where bfrc_arh-fin-doc-an-nal.host-code         = parhost-code             and
                                             bfrc_arh-fin-doc-an-nal.cli-type          = parreceiver-type         and
                                             bfrc_arh-fin-doc-an-nal.cli-code          = parreceiver-code         and
                                             bfrc_arh-fin-doc-an-nal.fin-code-acc      = parreceiver-fin-code-acc and
                                             bfrc_arh-fin-doc-an-nal.curr-code         = parcurr-code             and
                                             bfrc_arh-fin-doc-an-nal.fin-ext-doc-type  = parfin-ext-doc-type      and
                                             bfrc_arh-fin-doc-an-nal.fin-code-an-uchet = parfin-code-an-uchet     and
                                             bfrc_arh-fin-doc-an-nal.fin-code-cel-nazn = parfin-code-cel-nazn     and
                                             bfrc_arh-fin-doc-an-nal.fin-code-cor-acc  = parfin-code-cor-acc      and
                                             bfrc_arh-fin-doc-an-nal.calc-curr-code    = parcurr-dog-code         and
                                             bfrc_arh-fin-doc-an-nal.sum-type          = parsum-type              and
                                             bfrc_arh-fin-doc-an-nal.fact-order        = parfact-order            exclusive-lock.
  end.
  for each rbfrc_arh-fin-doc-an-nal where rbfrc_arh-fin-doc-an-nal.host-code         = bfrc_arh-fin-doc-an-nal.host-code         and
                                          rbfrc_arh-fin-doc-an-nal.cli-type          = parreceiver-type                          and
                                          rbfrc_arh-fin-doc-an-nal.cli-code          = parreceiver-code                          and
                                          rbfrc_arh-fin-doc-an-nal.fin-code-acc      = bfrc_arh-fin-doc-an-nal.fin-code-acc      and
                                          rbfrc_arh-fin-doc-an-nal.curr-code         = bfrc_arh-fin-doc-an-nal.curr-code         and
                                          rbfrc_arh-fin-doc-an-nal.fin-ext-doc-type  = bfrc_arh-fin-doc-an-nal.fin-ext-doc-type  and
                                          rbfrc_arh-fin-doc-an-nal.fin-code-an-uchet = bfrc_arh-fin-doc-an-nal.fin-code-an-uchet and
                                          rbfrc_arh-fin-doc-an-nal.fin-code-cel-nazn = bfrc_arh-fin-doc-an-nal.fin-code-cel-nazn and
                                          rbfrc_arh-fin-doc-an-nal.fin-code-cor-acc  = bfrc_arh-fin-doc-an-nal.fin-code-cor-acc  and
                                          rbfrc_arh-fin-doc-an-nal.calc-curr-code    = bfrc_arh-fin-doc-an-nal.calc-curr-code    and
                                          rbfrc_arh-fin-doc-an-nal.sum-type          = bfrc_arh-fin-doc-an-nal.sum-type          and
                                          rbfrc_arh-fin-doc-an-nal.fact-order        > bfrc_arh-fin-doc-an-nal.fact-order        use-index pi exclusive-lock on error undo, return error return-value :
    assign
      rbfrc_arh-fin-doc-an-nal.income     = rbfrc_arh-fin-doc-an-nal.income     + parsum-contr
      rbfrc_arh-fin-doc-an-nal.income-vat = rbfrc_arh-fin-doc-an-nal.income-vat + parsum-vat-contr
      rbfrc_arh-fin-doc-an-nal.income-slt = rbfrc_arh-fin-doc-an-nal.income-slt + parsum-slt-contr
    .
  end.
  if parmode = "delete":u then do:
    delete bfpc_arh-fin-doc-an-nal.
    delete bfrc_arh-fin-doc-an-nal.
  end.
end.
end.
end procedure.

procedure libfarhp_calc-arh-fin-doc-contr-schet-n :
define input parameter parmode                    as   character                    no-undo.
define input parameter parhost-code               like ub.fin-doc.host-code         no-undo.
define input parameter parpayer-type              like ub.fin-doc.payer-type       no-undo.
define input parameter parpayer-code              like ub.fin-doc.payer-code       no-undo.
define input parameter parreceiver-type           like ub.fin-doc.receiver-type    no-undo.
define input parameter parreceiver-code           like ub.fin-doc.receiver-code    no-undo.
define input parameter parpayer-fin-code-acc      like ub.fin-code-cor-acc.fin-code no-undo.
define input parameter parreceiver-fin-code-acc   like ub.fin-code-cor-acc.fin-code no-undo.
define input parameter parfin-ext-doc-type        like ub.fin-doc.fin-ext-doc-type  no-undo.
define input parameter parsum-type                as   character                    no-undo.
define input parameter parfact-order              like ub.fin-doc.fact-order        no-undo.
define input parameter parfin-doc-code            like ub.fin-doc.fin-doc-code      no-undo.
define input parameter parfact-date               like ub.fin-doc.fact-date         no-undo.
define input parameter parcurr-code               like ub.fin-doc.curr-code         no-undo.
define input parameter pcashbookid                like ub.fin-doc.cashbookid        no-undo.
define input parameter parbase-code               like ub.sysconf.base-code         no-undo.
define input parameter parcurr-dog-code           like ub.contract.curr-code        no-undo.
define input parameter parrel-dog-code            as   logical                      no-undo.
define input parameter parcontract-code           like ub.contract.contract-code    no-undo.
define input parameter parsum-doc                 as   decimal                      no-undo.
define input parameter parsum-rubl                as   decimal                      no-undo.
define input parameter parsum-base                as   decimal                      no-undo.
define input parameter parsum-contr               as   decimal                      no-undo.
define input parameter parsum-vat-doc             as   decimal                      no-undo.
define input parameter parsum-vat-rubl            as   decimal                      no-undo.
define input parameter parsum-vat-base            as   decimal                      no-undo.
define input parameter parsum-vat-contr           as   decimal                      no-undo.
define input parameter parsum-slt-doc             as   decimal                      no-undo.
define input parameter parsum-slt-rubl            as   decimal                      no-undo.
define input parameter parsum-slt-base            as   decimal                      no-undo.
define input parameter parsum-slt-contr           as   decimal                      no-undo.
define buffer bfps_arh-fin-doc-contr-schet-nal for ub.arh-fin-doc-contr-schet-nal.
define buffer bfrs_arh-fin-doc-contr-schet-nal for ub.arh-fin-doc-contr-schet-nal.
define buffer rbfps_arh-fin-doc-contr-schet-n  for ub.arh-fin-doc-contr-schet-nal.
define buffer rbfrs_arh-fin-doc-contr-schet-n  for ub.arh-fin-doc-contr-schet-nal.
define buffer bops_arh-fin-doc-contr-schet-nal for ub.arh-fin-doc-contr-schet-nal.
define buffer bors_arh-fin-doc-contr-schet-nal for ub.arh-fin-doc-contr-schet-nal.
define buffer bfpr_arh-fin-doc-contr-schet-nal for ub.arh-fin-doc-contr-schet-nal.
define buffer bfrr_arh-fin-doc-contr-schet-nal for ub.arh-fin-doc-contr-schet-nal.
define buffer rbfpr_arh-fin-doc-contr-schet-n  for ub.arh-fin-doc-contr-schet-nal.
define buffer rbfrr_arh-fin-doc-contr-schet-n  for ub.arh-fin-doc-contr-schet-nal.
define buffer bopr_arh-fin-doc-contr-schet-nal for ub.arh-fin-doc-contr-schet-nal.
define buffer borr_arh-fin-doc-contr-schet-nal for ub.arh-fin-doc-contr-schet-nal.
define buffer bfpb_arh-fin-doc-contr-schet-nal for ub.arh-fin-doc-contr-schet-nal.
define buffer bfrb_arh-fin-doc-contr-schet-nal for ub.arh-fin-doc-contr-schet-nal.
define buffer rbfpb_arh-fin-doc-contr-schet-n  for ub.arh-fin-doc-contr-schet-nal.
define buffer rbfrb_arh-fin-doc-contr-schet-n  for ub.arh-fin-doc-contr-schet-nal.
define buffer bopb_arh-fin-doc-contr-schet-nal for ub.arh-fin-doc-contr-schet-nal.
define buffer borb_arh-fin-doc-contr-schet-nal for ub.arh-fin-doc-contr-schet-nal.
define buffer bfpc_arh-fin-doc-contr-schet-nal for ub.arh-fin-doc-contr-schet-nal.
define buffer bfrc_arh-fin-doc-contr-schet-nal for ub.arh-fin-doc-contr-schet-nal.
define buffer rbfpc_arh-fin-doc-contr-schet-n  for ub.arh-fin-doc-contr-schet-nal.
define buffer rbfrc_arh-fin-doc-contr-schet-n  for ub.arh-fin-doc-contr-schet-nal.
define buffer bopc_arh-fin-doc-contr-schet-nal for ub.arh-fin-doc-contr-schet-nal.
define buffer borc_arh-fin-doc-contr-schet-nal for ub.arh-fin-doc-contr-schet-nal.
do on error undo, return error substitute ("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
if parmode = "close":u then do:
  find last bops_arh-fin-doc-contr-schet-nal where bops_arh-fin-doc-contr-schet-nal.host-code        = parhost-code          and
                                                   bops_arh-fin-doc-contr-schet-nal.cli-type         = parpayer-type         and
                                                   bops_arh-fin-doc-contr-schet-nal.cli-code         = parpayer-code         and
                                                   bops_arh-fin-doc-contr-schet-nal.contract-code    = parcontract-code      and
                                                   bops_arh-fin-doc-contr-schet-nal.fin-code-acc     = parpayer-fin-code-acc and
                                                   bops_arh-fin-doc-contr-schet-nal.curr-code        = parcurr-code          and
                                                   bops_arh-fin-doc-contr-schet-nal.fin-ext-doc-type = parfin-ext-doc-type   and
                                                   bops_arh-fin-doc-contr-schet-nal.calc-curr-code   = parcurr-code          and
                                                   bops_arh-fin-doc-contr-schet-nal.sum-type         = parsum-type           and
                                                   bops_arh-fin-doc-contr-schet-nal.cashbookid       = pcashbookid           and
                                                   bops_arh-fin-doc-contr-schet-nal.fact-order       < parfact-order         use-index pi no-error.
  create bfps_arh-fin-doc-contr-schet-nal.
  assign
    bfps_arh-fin-doc-contr-schet-nal.host-code        = parhost-code
    bfps_arh-fin-doc-contr-schet-nal.cli-type         = parpayer-type
    bfps_arh-fin-doc-contr-schet-nal.cli-code         = parpayer-code
    bfps_arh-fin-doc-contr-schet-nal.contract-code    = parcontract-code
    bfps_arh-fin-doc-contr-schet-nal.fin-code-acc     = parpayer-fin-code-acc
    bfps_arh-fin-doc-contr-schet-nal.curr-code        = parcurr-code
    bfps_arh-fin-doc-contr-schet-nal.fin-ext-doc-type = parfin-ext-doc-type
    bfps_arh-fin-doc-contr-schet-nal.calc-curr-code   = parcurr-code
    bfps_arh-fin-doc-contr-schet-nal.sum-type         = parsum-type
    bfps_arh-fin-doc-contr-schet-nal.cource-des       = "s":u
    bfps_arh-fin-doc-contr-schet-nal.fact-order       = parfact-order
    bfps_arh-fin-doc-contr-schet-nal.fin-doc-code     = parfin-doc-code
    bfps_arh-fin-doc-contr-schet-nal.fact-date        = parfact-date
    bfps_arh-fin-doc-contr-schet-nal.curr-code        = parcurr-code
    bfps_arh-fin-doc-contr-schet-nal.cashbookid       = pcashbookid
    bfps_arh-fin-doc-contr-schet-nal.income           = (if available bops_arh-fin-doc-contr-schet-nal then bops_arh-fin-doc-contr-schet-nal.income      else 0)
    bfps_arh-fin-doc-contr-schet-nal.income-vat       = (if available bops_arh-fin-doc-contr-schet-nal then bops_arh-fin-doc-contr-schet-nal.income-vat  else 0)
    bfps_arh-fin-doc-contr-schet-nal.income-slt       = (if available bops_arh-fin-doc-contr-schet-nal then bops_arh-fin-doc-contr-schet-nal.income-slt  else 0)
    bfps_arh-fin-doc-contr-schet-nal.expense          = (if available bops_arh-fin-doc-contr-schet-nal then bops_arh-fin-doc-contr-schet-nal.expense     else 0) + parsum-doc
    bfps_arh-fin-doc-contr-schet-nal.expense-vat      = (if available bops_arh-fin-doc-contr-schet-nal then bops_arh-fin-doc-contr-schet-nal.expense-vat else 0) + parsum-vat-doc
    bfps_arh-fin-doc-contr-schet-nal.expense-slt      = (if available bops_arh-fin-doc-contr-schet-nal then bops_arh-fin-doc-contr-schet-nal.expense-slt else 0) + parsum-slt-doc
  .
end.
else do:
  find first bfps_arh-fin-doc-contr-schet-nal where bfps_arh-fin-doc-contr-schet-nal.host-code        = parhost-code          and
                                                    bfps_arh-fin-doc-contr-schet-nal.cli-type         = parpayer-type         and
                                                    bfps_arh-fin-doc-contr-schet-nal.cli-code         = parpayer-code         and
                                                    bfps_arh-fin-doc-contr-schet-nal.contract-code    = parcontract-code      and
                                                    bfps_arh-fin-doc-contr-schet-nal.fin-code-acc     = parpayer-fin-code-acc and
                                                    bfps_arh-fin-doc-contr-schet-nal.curr-code        = parcurr-code          and
                                                    bfps_arh-fin-doc-contr-schet-nal.fin-ext-doc-type = parfin-ext-doc-type   and
                                                    bfps_arh-fin-doc-contr-schet-nal.calc-curr-code   = parcurr-code          and
                                                    bfps_arh-fin-doc-contr-schet-nal.sum-type         = parsum-type           and
                                                    bfps_arh-fin-doc-contr-schet-nal.cashbookid       = pcashbookid           and
                                                    bfps_arh-fin-doc-contr-schet-nal.fact-order       = parfact-order         exclusive-lock.
end.
for each rbfps_arh-fin-doc-contr-schet-n where rbfps_arh-fin-doc-contr-schet-n.host-code        = bfps_arh-fin-doc-contr-schet-nal.host-code        and
                                               rbfps_arh-fin-doc-contr-schet-n.cli-type         = parpayer-type                                     and
                                               rbfps_arh-fin-doc-contr-schet-n.cli-code         = parpayer-code                                     and
                                               rbfps_arh-fin-doc-contr-schet-n.contract-code    = bfps_arh-fin-doc-contr-schet-nal.contract-code    and
                                               rbfps_arh-fin-doc-contr-schet-n.fin-code-acc     = bfps_arh-fin-doc-contr-schet-nal.fin-code-acc     and
                                               rbfps_arh-fin-doc-contr-schet-n.curr-code        = bfps_arh-fin-doc-contr-schet-nal.curr-code        and
                                               rbfps_arh-fin-doc-contr-schet-n.fin-ext-doc-type = bfps_arh-fin-doc-contr-schet-nal.fin-ext-doc-type and
                                               rbfps_arh-fin-doc-contr-schet-n.calc-curr-code   = bfps_arh-fin-doc-contr-schet-nal.calc-curr-code   and
                                               rbfps_arh-fin-doc-contr-schet-n.sum-type         = bfps_arh-fin-doc-contr-schet-nal.sum-type         and
                                               rbfps_arh-fin-doc-contr-schet-n.cashbookid       = pcashbookid                                       and
                                               rbfps_arh-fin-doc-contr-schet-n.fact-order       > bfps_arh-fin-doc-contr-schet-nal.fact-order       use-index pi exclusive-lock on error undo, return error return-value :
  assign
    rbfps_arh-fin-doc-contr-schet-n.expense     = rbfps_arh-fin-doc-contr-schet-n.expense     + parsum-doc
    rbfps_arh-fin-doc-contr-schet-n.expense-vat = rbfps_arh-fin-doc-contr-schet-n.expense-vat + parsum-vat-doc
    rbfps_arh-fin-doc-contr-schet-n.expense-slt = rbfps_arh-fin-doc-contr-schet-n.expense-slt + parsum-slt-doc
  .
end.
if parmode = "close":u then do:
  find last bors_arh-fin-doc-contr-schet-nal where bors_arh-fin-doc-contr-schet-nal.host-code        = parhost-code             and
                                                   bors_arh-fin-doc-contr-schet-nal.cli-type         = parreceiver-type         and
                                                   bors_arh-fin-doc-contr-schet-nal.cli-code         = parreceiver-code         and
                                                   bors_arh-fin-doc-contr-schet-nal.contract-code    = parcontract-code         and
                                                   bors_arh-fin-doc-contr-schet-nal.fin-code-acc     = parreceiver-fin-code-acc and
                                                   bors_arh-fin-doc-contr-schet-nal.curr-code        = parcurr-code             and
                                                   bors_arh-fin-doc-contr-schet-nal.fin-ext-doc-type = parfin-ext-doc-type      and
                                                   bors_arh-fin-doc-contr-schet-nal.calc-curr-code   = parcurr-code             and
                                                   bors_arh-fin-doc-contr-schet-nal.sum-type         = parsum-type              and
                                                   bors_arh-fin-doc-contr-schet-nal.cashbookid       = pcashbookid              and
                                                   bors_arh-fin-doc-contr-schet-nal.fact-order       < parfact-order            use-index pi no-error.
  create bfrs_arh-fin-doc-contr-schet-nal.
  assign
    bfrs_arh-fin-doc-contr-schet-nal.host-code        = parhost-code
    bfrs_arh-fin-doc-contr-schet-nal.cli-type         = parreceiver-type
    bfrs_arh-fin-doc-contr-schet-nal.cli-code         = parreceiver-code
    bfrs_arh-fin-doc-contr-schet-nal.contract-code    = parcontract-code
    bfrs_arh-fin-doc-contr-schet-nal.fin-code-acc     = parreceiver-fin-code-acc
    bfrs_arh-fin-doc-contr-schet-nal.curr-code        = parcurr-code
    bfrs_arh-fin-doc-contr-schet-nal.fin-ext-doc-type = parfin-ext-doc-type
    bfrs_arh-fin-doc-contr-schet-nal.calc-curr-code   = parcurr-code
    bfrs_arh-fin-doc-contr-schet-nal.sum-type         = parsum-type
    bfrs_arh-fin-doc-contr-schet-nal.cource-des       = "s":u
    bfrs_arh-fin-doc-contr-schet-nal.fact-order       = parfact-order
    bfrs_arh-fin-doc-contr-schet-nal.fin-doc-code     = parfin-doc-code
    bfrs_arh-fin-doc-contr-schet-nal.fact-date        = parfact-date
    bfrs_arh-fin-doc-contr-schet-nal.curr-code        = parcurr-code
    bfrs_arh-fin-doc-contr-schet-nal.cashbookid       = pcashbookid
  .
  assign
    bfrs_arh-fin-doc-contr-schet-nal.expense          = (if available bors_arh-fin-doc-contr-schet-nal then bors_arh-fin-doc-contr-schet-nal.expense     else 0)
    bfrs_arh-fin-doc-contr-schet-nal.expense-vat      = (if available bors_arh-fin-doc-contr-schet-nal then bors_arh-fin-doc-contr-schet-nal.expense-vat else 0)
    bfrs_arh-fin-doc-contr-schet-nal.expense-slt      = (if available bors_arh-fin-doc-contr-schet-nal then bors_arh-fin-doc-contr-schet-nal.expense-slt else 0)
    bfrs_arh-fin-doc-contr-schet-nal.income           = (if available bors_arh-fin-doc-contr-schet-nal then bors_arh-fin-doc-contr-schet-nal.income      else 0) + parsum-doc
    bfrs_arh-fin-doc-contr-schet-nal.income-vat       = (if available bors_arh-fin-doc-contr-schet-nal then bors_arh-fin-doc-contr-schet-nal.income-vat  else 0) + parsum-vat-doc
    bfrs_arh-fin-doc-contr-schet-nal.income-slt       = (if available bors_arh-fin-doc-contr-schet-nal then bors_arh-fin-doc-contr-schet-nal.income-slt  else 0) + parsum-slt-doc
  .
end.
else do:
  find first bfrs_arh-fin-doc-contr-schet-nal where bfrs_arh-fin-doc-contr-schet-nal.host-code        = parhost-code             and
                                                    bfrs_arh-fin-doc-contr-schet-nal.cli-type         = parreceiver-type         and
                                                    bfrs_arh-fin-doc-contr-schet-nal.cli-code         = parreceiver-code         and
                                                    bfrs_arh-fin-doc-contr-schet-nal.contract-code    = parcontract-code         and
                                                    bfrs_arh-fin-doc-contr-schet-nal.fin-code-acc     = parreceiver-fin-code-acc and
                                                    bfrs_arh-fin-doc-contr-schet-nal.curr-code        = parcurr-code             and
                                                    bfrs_arh-fin-doc-contr-schet-nal.fin-ext-doc-type = parfin-ext-doc-type      and
                                                    bfrs_arh-fin-doc-contr-schet-nal.calc-curr-code   = parcurr-code             and
                                                    bfrs_arh-fin-doc-contr-schet-nal.sum-type         = parsum-type              and
                                                    bfps_arh-fin-doc-contr-schet-nal.cashbookid       = pcashbookid              and
                                                    bfrs_arh-fin-doc-contr-schet-nal.fact-order       = parfact-order            exclusive-lock.
end.
for each rbfrs_arh-fin-doc-contr-schet-n where rbfrs_arh-fin-doc-contr-schet-n.host-code        = bfrs_arh-fin-doc-contr-schet-nal.host-code        and
                                               rbfrs_arh-fin-doc-contr-schet-n.cli-type         = parreceiver-type                                  and
                                               rbfrs_arh-fin-doc-contr-schet-n.cli-code         = parreceiver-code                                  and
                                               rbfrs_arh-fin-doc-contr-schet-n.contract-code    = bfrs_arh-fin-doc-contr-schet-nal.contract-code    and
                                               rbfrs_arh-fin-doc-contr-schet-n.fin-code-acc     = bfrs_arh-fin-doc-contr-schet-nal.fin-code-acc     and
                                               rbfrs_arh-fin-doc-contr-schet-n.curr-code        = bfrs_arh-fin-doc-contr-schet-nal.curr-code        and
                                               rbfrs_arh-fin-doc-contr-schet-n.fin-ext-doc-type = bfrs_arh-fin-doc-contr-schet-nal.fin-ext-doc-type and
                                               rbfrs_arh-fin-doc-contr-schet-n.calc-curr-code   = bfrs_arh-fin-doc-contr-schet-nal.calc-curr-code   and
                                               rbfrs_arh-fin-doc-contr-schet-n.sum-type         = bfrs_arh-fin-doc-contr-schet-nal.sum-type         and
                                               rbfrs_arh-fin-doc-contr-schet-n.cashbookid       = pcashbookid                                       and
                                               rbfrs_arh-fin-doc-contr-schet-n.fact-order       > bfrs_arh-fin-doc-contr-schet-nal.fact-order       use-index pi on error undo, return error return-value :
  assign
    rbfrs_arh-fin-doc-contr-schet-n.income     = rbfrs_arh-fin-doc-contr-schet-n.income     + parsum-doc
    rbfrs_arh-fin-doc-contr-schet-n.income-vat = rbfrs_arh-fin-doc-contr-schet-n.income-vat + parsum-vat-doc
    rbfrs_arh-fin-doc-contr-schet-n.income-slt = rbfrs_arh-fin-doc-contr-schet-n.income-slt + parsum-slt-doc
  .
end.
if parmode = "delete":u then do:
  delete bfps_arh-fin-doc-contr-schet-nal.
  delete bfrs_arh-fin-doc-contr-schet-nal.
end.
if parcurr-code <> 0 then do:
  if parmode = "close":u then do:
    find last bopr_arh-fin-doc-contr-schet-nal where bopr_arh-fin-doc-contr-schet-nal.host-code        = parhost-code          and
                                                     bopr_arh-fin-doc-contr-schet-nal.cli-type         = parpayer-type         and
                                                     bopr_arh-fin-doc-contr-schet-nal.cli-code         = parpayer-code         and
                                                     bopr_arh-fin-doc-contr-schet-nal.contract-code    = parcontract-code      and
                                                     bopr_arh-fin-doc-contr-schet-nal.fin-code-acc     = parpayer-fin-code-acc and
                                                     bopr_arh-fin-doc-contr-schet-nal.curr-code        = parcurr-code          and
                                                     bopr_arh-fin-doc-contr-schet-nal.fin-ext-doc-type = parfin-ext-doc-type   and
                                                     bopr_arh-fin-doc-contr-schet-nal.calc-curr-code   = 0                     and
                                                     bopr_arh-fin-doc-contr-schet-nal.sum-type         = parsum-type           and
                                                     bopr_arh-fin-doc-contr-schet-nal.cashbookid       = pcashbookid           and
                                                     bopr_arh-fin-doc-contr-schet-nal.fact-order       < parfact-order         use-index pi no-error.
    create bfpr_arh-fin-doc-contr-schet-nal.
    assign
      bfpr_arh-fin-doc-contr-schet-nal.host-code        = parhost-code
      bfpr_arh-fin-doc-contr-schet-nal.cli-type         = parpayer-type
      bfpr_arh-fin-doc-contr-schet-nal.cli-code         = parpayer-code
      bfpr_arh-fin-doc-contr-schet-nal.contract-code    = parcontract-code
      bfpr_arh-fin-doc-contr-schet-nal.fin-code-acc     = parpayer-fin-code-acc
      bfpr_arh-fin-doc-contr-schet-nal.curr-code        = parcurr-code
      bfpr_arh-fin-doc-contr-schet-nal.fin-ext-doc-type = parfin-ext-doc-type
      bfpr_arh-fin-doc-contr-schet-nal.calc-curr-code   = 0
      bfpr_arh-fin-doc-contr-schet-nal.sum-type         = parsum-type
      bfpr_arh-fin-doc-contr-schet-nal.cource-des       = "r":u
      bfpr_arh-fin-doc-contr-schet-nal.fact-order       = parfact-order
      bfpr_arh-fin-doc-contr-schet-nal.fin-doc-code     = parfin-doc-code
      bfpr_arh-fin-doc-contr-schet-nal.fact-date        = parfact-date
      bfpr_arh-fin-doc-contr-schet-nal.curr-code        = parcurr-code
      bfpr_arh-fin-doc-contr-schet-nal.cashbookid       = pcashbookid
      bfpr_arh-fin-doc-contr-schet-nal.income           = (if available bopr_arh-fin-doc-contr-schet-nal then bopr_arh-fin-doc-contr-schet-nal.income      else 0)
      bfpr_arh-fin-doc-contr-schet-nal.income-vat       = (if available bopr_arh-fin-doc-contr-schet-nal then bopr_arh-fin-doc-contr-schet-nal.income-vat  else 0)
      bfpr_arh-fin-doc-contr-schet-nal.income-slt       = (if available bopr_arh-fin-doc-contr-schet-nal then bopr_arh-fin-doc-contr-schet-nal.income-slt  else 0)
      bfpr_arh-fin-doc-contr-schet-nal.expense          = (if available bopr_arh-fin-doc-contr-schet-nal then bopr_arh-fin-doc-contr-schet-nal.expense     else 0) + parsum-rubl
      bfpr_arh-fin-doc-contr-schet-nal.expense-vat      = (if available bopr_arh-fin-doc-contr-schet-nal then bopr_arh-fin-doc-contr-schet-nal.expense-vat else 0) + parsum-vat-rubl
      bfpr_arh-fin-doc-contr-schet-nal.expense-slt      = (if available bopr_arh-fin-doc-contr-schet-nal then bopr_arh-fin-doc-contr-schet-nal.expense-slt else 0) + parsum-slt-rubl
    .
  end.
  else do:
    find first bfpr_arh-fin-doc-contr-schet-nal where bfpr_arh-fin-doc-contr-schet-nal.host-code        = parhost-code          and
                                                      bfpr_arh-fin-doc-contr-schet-nal.cli-type         = parpayer-type         and
                                                      bfpr_arh-fin-doc-contr-schet-nal.cli-code         = parpayer-code         and
                                                      bfpr_arh-fin-doc-contr-schet-nal.contract-code    = parcontract-code      and
                                                      bfpr_arh-fin-doc-contr-schet-nal.fin-code-acc     = parpayer-fin-code-acc and
                                                      bfpr_arh-fin-doc-contr-schet-nal.curr-code        = parcurr-code          and
                                                      bfpr_arh-fin-doc-contr-schet-nal.fin-ext-doc-type = parfin-ext-doc-type   and
                                                      bfpr_arh-fin-doc-contr-schet-nal.calc-curr-code   = 0                     and
                                                      bfpr_arh-fin-doc-contr-schet-nal.sum-type         = parsum-type           and
                                                      bfpr_arh-fin-doc-contr-schet-nal.cashbookid       = pcashbookid           and
                                                      bfpr_arh-fin-doc-contr-schet-nal.fact-order       = parfact-order         exclusive-lock.
  end.
  for each rbfpr_arh-fin-doc-contr-schet-n where rbfpr_arh-fin-doc-contr-schet-n.host-code        = bfpr_arh-fin-doc-contr-schet-nal.host-code        and
                                                 rbfpr_arh-fin-doc-contr-schet-n.cli-type         = parpayer-type                                     and
                                                 rbfpr_arh-fin-doc-contr-schet-n.cli-code         = parpayer-code                                     and
                                                 rbfpr_arh-fin-doc-contr-schet-n.contract-code    = bfpr_arh-fin-doc-contr-schet-nal.contract-code    and
                                                 rbfpr_arh-fin-doc-contr-schet-n.fin-code-acc     = bfpr_arh-fin-doc-contr-schet-nal.fin-code-acc     and
                                                 rbfpr_arh-fin-doc-contr-schet-n.curr-code        = bfpr_arh-fin-doc-contr-schet-nal.curr-code        and
                                                 rbfpr_arh-fin-doc-contr-schet-n.fin-ext-doc-type = bfpr_arh-fin-doc-contr-schet-nal.fin-ext-doc-type and
                                                 rbfpr_arh-fin-doc-contr-schet-n.calc-curr-code   = bfpr_arh-fin-doc-contr-schet-nal.calc-curr-code   and
                                                 rbfpr_arh-fin-doc-contr-schet-n.sum-type         = bfpr_arh-fin-doc-contr-schet-nal.sum-type         and
                                                 rbfpr_arh-fin-doc-contr-schet-n.cashbookid       = pcashbookid                                       and
                                                 rbfpr_arh-fin-doc-contr-schet-n.fact-order       > bfpr_arh-fin-doc-contr-schet-nal.fact-order       use-index pi exclusive-lock on error undo, return error return-value :
    assign
      rbfpr_arh-fin-doc-contr-schet-n.expense     = rbfpr_arh-fin-doc-contr-schet-n.expense     + parsum-rubl
      rbfpr_arh-fin-doc-contr-schet-n.expense-vat = rbfpr_arh-fin-doc-contr-schet-n.expense-vat + parsum-vat-rubl
      rbfpr_arh-fin-doc-contr-schet-n.expense-slt = rbfpr_arh-fin-doc-contr-schet-n.expense-slt + parsum-slt-rubl
    .
  end.
  if parmode = "close":u then do:
    find last borr_arh-fin-doc-contr-schet-nal where borr_arh-fin-doc-contr-schet-nal.host-code        = parhost-code             and
                                                     borr_arh-fin-doc-contr-schet-nal.cli-type         = parreceiver-type         and
                                                     borr_arh-fin-doc-contr-schet-nal.cli-code         = parreceiver-code         and
                                                     borr_arh-fin-doc-contr-schet-nal.contract-code    = parcontract-code         and
                                                     borr_arh-fin-doc-contr-schet-nal.fin-code-acc     = parreceiver-fin-code-acc and
                                                     borr_arh-fin-doc-contr-schet-nal.curr-code        = parcurr-code             and
                                                     borr_arh-fin-doc-contr-schet-nal.fin-ext-doc-type = parfin-ext-doc-type      and
                                                     borr_arh-fin-doc-contr-schet-nal.calc-curr-code   = 0                        and
                                                     borr_arh-fin-doc-contr-schet-nal.sum-type         = parsum-type              and
                                                     borr_arh-fin-doc-contr-schet-nal.cashbookid       = pcashbookid              and
                                                     borr_arh-fin-doc-contr-schet-nal.fact-order       < parfact-order            use-index pi no-error.
    create bfrr_arh-fin-doc-contr-schet-nal.
    assign
      bfrr_arh-fin-doc-contr-schet-nal.host-code        = parhost-code
      bfrr_arh-fin-doc-contr-schet-nal.cli-type         = parreceiver-type
      bfrr_arh-fin-doc-contr-schet-nal.cli-code         = parreceiver-code
      bfrr_arh-fin-doc-contr-schet-nal.contract-code    = parcontract-code
      bfrr_arh-fin-doc-contr-schet-nal.fin-code-acc     = parreceiver-fin-code-acc
      bfrr_arh-fin-doc-contr-schet-nal.curr-code        = parcurr-code
      bfrr_arh-fin-doc-contr-schet-nal.fin-ext-doc-type = parfin-ext-doc-type
      bfrr_arh-fin-doc-contr-schet-nal.calc-curr-code   = 0
      bfrr_arh-fin-doc-contr-schet-nal.sum-type         = parsum-type
      bfrr_arh-fin-doc-contr-schet-nal.cource-des       = "r":u
      bfrr_arh-fin-doc-contr-schet-nal.fact-order       = parfact-order
      bfrr_arh-fin-doc-contr-schet-nal.fin-doc-code     = parfin-doc-code
      bfrr_arh-fin-doc-contr-schet-nal.fact-date        = parfact-date
      bfrr_arh-fin-doc-contr-schet-nal.curr-code        = parcurr-code
      bfrr_arh-fin-doc-contr-schet-nal.cashbookid       = pcashbookid
    .
    assign
      bfrr_arh-fin-doc-contr-schet-nal.expense          = (if available borr_arh-fin-doc-contr-schet-nal then borr_arh-fin-doc-contr-schet-nal.expense     else 0)
      bfrr_arh-fin-doc-contr-schet-nal.expense-vat      = (if available borr_arh-fin-doc-contr-schet-nal then borr_arh-fin-doc-contr-schet-nal.expense-vat else 0)
      bfrr_arh-fin-doc-contr-schet-nal.expense-slt      = (if available borr_arh-fin-doc-contr-schet-nal then borr_arh-fin-doc-contr-schet-nal.expense-slt else 0)
      bfrr_arh-fin-doc-contr-schet-nal.income           = (if available borr_arh-fin-doc-contr-schet-nal then borr_arh-fin-doc-contr-schet-nal.income      else 0) + parsum-rubl
      bfrr_arh-fin-doc-contr-schet-nal.income-vat       = (if available borr_arh-fin-doc-contr-schet-nal then borr_arh-fin-doc-contr-schet-nal.income-vat  else 0) + parsum-vat-rubl
      bfrr_arh-fin-doc-contr-schet-nal.income-slt       = (if available borr_arh-fin-doc-contr-schet-nal then borr_arh-fin-doc-contr-schet-nal.income-slt  else 0) + parsum-slt-rubl
    .
  end.
  else do:
    find first bfrr_arh-fin-doc-contr-schet-nal where bfrr_arh-fin-doc-contr-schet-nal.host-code        = parhost-code             and
                                                      bfrr_arh-fin-doc-contr-schet-nal.cli-type         = parreceiver-type         and
                                                      bfrr_arh-fin-doc-contr-schet-nal.cli-code         = parreceiver-code         and
                                                      bfrr_arh-fin-doc-contr-schet-nal.contract-code    = parcontract-code         and
                                                      bfrr_arh-fin-doc-contr-schet-nal.fin-code-acc     = parreceiver-fin-code-acc and
                                                      bfrr_arh-fin-doc-contr-schet-nal.curr-code        = parcurr-code             and
                                                      bfrr_arh-fin-doc-contr-schet-nal.fin-ext-doc-type = parfin-ext-doc-type      and
                                                      bfrr_arh-fin-doc-contr-schet-nal.calc-curr-code   = 0                        and
                                                      bfrr_arh-fin-doc-contr-schet-nal.sum-type         = parsum-type              and
                                                      bfrr_arh-fin-doc-contr-schet-nal.cashbookid       = pcashbookid              and
                                                      bfrr_arh-fin-doc-contr-schet-nal.fact-order       = parfact-order            exclusive-lock.
  end.
  for each rbfrr_arh-fin-doc-contr-schet-n where rbfrr_arh-fin-doc-contr-schet-n.host-code        = bfrr_arh-fin-doc-contr-schet-nal.host-code        and
                                                 rbfrr_arh-fin-doc-contr-schet-n.cli-type         = parreceiver-type                                  and
                                                 rbfrr_arh-fin-doc-contr-schet-n.cli-code         = parreceiver-code                                  and
                                                 rbfrr_arh-fin-doc-contr-schet-n.contract-code    = bfrr_arh-fin-doc-contr-schet-nal.contract-code    and
                                                 rbfrr_arh-fin-doc-contr-schet-n.fin-code-acc     = bfrr_arh-fin-doc-contr-schet-nal.fin-code-acc     and
                                                 rbfrr_arh-fin-doc-contr-schet-n.curr-code        = bfrr_arh-fin-doc-contr-schet-nal.curr-code        and
                                                 rbfrr_arh-fin-doc-contr-schet-n.fin-ext-doc-type = bfrr_arh-fin-doc-contr-schet-nal.fin-ext-doc-type and
                                                 rbfrr_arh-fin-doc-contr-schet-n.calc-curr-code   = bfrr_arh-fin-doc-contr-schet-nal.calc-curr-code   and
                                                 rbfrr_arh-fin-doc-contr-schet-n.sum-type         = bfrr_arh-fin-doc-contr-schet-nal.sum-type         and
                                                 rbfrr_arh-fin-doc-contr-schet-n.cashbookid       = pcashbookid                                       and
                                                 rbfrr_arh-fin-doc-contr-schet-n.fact-order       > bfrr_arh-fin-doc-contr-schet-nal.fact-order       use-index pi on error undo, return error return-value :
    assign
      rbfrr_arh-fin-doc-contr-schet-n.income     = rbfrr_arh-fin-doc-contr-schet-n.income     + parsum-rubl
      rbfrr_arh-fin-doc-contr-schet-n.income-vat = rbfrr_arh-fin-doc-contr-schet-n.income-vat + parsum-vat-rubl
      rbfrr_arh-fin-doc-contr-schet-n.income-slt = rbfrr_arh-fin-doc-contr-schet-n.income-slt + parsum-slt-rubl
    .
  end.
  if parmode = "delete":u then do:
    delete bfpr_arh-fin-doc-contr-schet-nal.
    delete bfrr_arh-fin-doc-contr-schet-nal.
  end.
end.
if parbase-code <> parcurr-code and
   parbase-code <> 0            then do:
  if parmode = "close":u then do:
    find last bopb_arh-fin-doc-contr-schet-nal where bopb_arh-fin-doc-contr-schet-nal.host-code        = parhost-code          and
                                                     bopb_arh-fin-doc-contr-schet-nal.cli-type         = parpayer-type         and
                                                     bopb_arh-fin-doc-contr-schet-nal.cli-code         = parpayer-code         and
                                                     bopb_arh-fin-doc-contr-schet-nal.contract-code    = parcontract-code      and
                                                     bopb_arh-fin-doc-contr-schet-nal.fin-code-acc     = parpayer-fin-code-acc and
                                                     bopb_arh-fin-doc-contr-schet-nal.curr-code        = parcurr-code          and
                                                     bopb_arh-fin-doc-contr-schet-nal.fin-ext-doc-type = parfin-ext-doc-type   and
                                                     bopb_arh-fin-doc-contr-schet-nal.calc-curr-code   = parbase-code          and
                                                     bopb_arh-fin-doc-contr-schet-nal.sum-type         = parsum-type           and
                                                     bopb_arh-fin-doc-contr-schet-nal.cashbookid       = pcashbookid           and
                                                     bopb_arh-fin-doc-contr-schet-nal.fact-order       < parfact-order         use-index pi no-error.
    create bfpb_arh-fin-doc-contr-schet-nal.
    assign
      bfpb_arh-fin-doc-contr-schet-nal.host-code        = parhost-code
      bfpb_arh-fin-doc-contr-schet-nal.cli-type         = parpayer-type
      bfpb_arh-fin-doc-contr-schet-nal.cli-code         = parpayer-code
      bfpb_arh-fin-doc-contr-schet-nal.contract-code    = parcontract-code
      bfpb_arh-fin-doc-contr-schet-nal.fin-code-acc     = parpayer-fin-code-acc
      bfpb_arh-fin-doc-contr-schet-nal.curr-code        = parcurr-code
      bfpb_arh-fin-doc-contr-schet-nal.fin-ext-doc-type = parfin-ext-doc-type
      bfpb_arh-fin-doc-contr-schet-nal.calc-curr-code   = parbase-code
      bfpb_arh-fin-doc-contr-schet-nal.sum-type         = parsum-type
      bfpb_arh-fin-doc-contr-schet-nal.cource-des       = "b":u
      bfpb_arh-fin-doc-contr-schet-nal.fact-order       = parfact-order
      bfpb_arh-fin-doc-contr-schet-nal.fin-doc-code     = parfin-doc-code
      bfpb_arh-fin-doc-contr-schet-nal.fact-date        = parfact-date
      bfpb_arh-fin-doc-contr-schet-nal.curr-code        = parcurr-code
      bfpb_arh-fin-doc-contr-schet-nal.cashbookid       = pcashbookid
      bfpb_arh-fin-doc-contr-schet-nal.income           = (if available bopb_arh-fin-doc-contr-schet-nal then bopb_arh-fin-doc-contr-schet-nal.income      else 0)
      bfpb_arh-fin-doc-contr-schet-nal.income-vat       = (if available bopb_arh-fin-doc-contr-schet-nal then bopb_arh-fin-doc-contr-schet-nal.income-vat  else 0)
      bfpb_arh-fin-doc-contr-schet-nal.income-slt       = (if available bopb_arh-fin-doc-contr-schet-nal then bopb_arh-fin-doc-contr-schet-nal.income-slt  else 0)
      bfpb_arh-fin-doc-contr-schet-nal.expense          = (if available bopb_arh-fin-doc-contr-schet-nal then bopb_arh-fin-doc-contr-schet-nal.expense     else 0) + parsum-base
      bfpb_arh-fin-doc-contr-schet-nal.expense-vat      = (if available bopb_arh-fin-doc-contr-schet-nal then bopb_arh-fin-doc-contr-schet-nal.expense-vat else 0) + parsum-vat-base
      bfpb_arh-fin-doc-contr-schet-nal.expense-slt      = (if available bopb_arh-fin-doc-contr-schet-nal then bopb_arh-fin-doc-contr-schet-nal.expense-slt else 0) + parsum-slt-base
    .
  end.
  else do:
    find first bfpb_arh-fin-doc-contr-schet-nal where bfpb_arh-fin-doc-contr-schet-nal.host-code        = parhost-code          and
                                                      bfpb_arh-fin-doc-contr-schet-nal.cli-type         = parpayer-type         and
                                                      bfpb_arh-fin-doc-contr-schet-nal.cli-code         = parpayer-code         and
                                                      bfpb_arh-fin-doc-contr-schet-nal.contract-code    = parcontract-code      and
                                                      bfpb_arh-fin-doc-contr-schet-nal.fin-code-acc     = parpayer-fin-code-acc and
                                                      bfpb_arh-fin-doc-contr-schet-nal.curr-code        = parcurr-code          and
                                                      bfpb_arh-fin-doc-contr-schet-nal.fin-ext-doc-type = parfin-ext-doc-type   and
                                                      bfpb_arh-fin-doc-contr-schet-nal.calc-curr-code   = parbase-code          and
                                                      bfpb_arh-fin-doc-contr-schet-nal.sum-type         = parsum-type           and
                                                      bfpb_arh-fin-doc-contr-schet-nal.cashbookid       = pcashbookid           and
                                                      bfpb_arh-fin-doc-contr-schet-nal.fact-order       = parfact-order         exclusive-lock.
  end.
  for each rbfpb_arh-fin-doc-contr-schet-n where rbfpb_arh-fin-doc-contr-schet-n.host-code        = bfpb_arh-fin-doc-contr-schet-nal.host-code        and
                                                 rbfpb_arh-fin-doc-contr-schet-n.cli-type         = parpayer-type                                     and
                                                 rbfpb_arh-fin-doc-contr-schet-n.cli-code         = parpayer-code                                     and
                                                 rbfpb_arh-fin-doc-contr-schet-n.contract-code    = bfpb_arh-fin-doc-contr-schet-nal.contract-code    and
                                                 rbfpb_arh-fin-doc-contr-schet-n.fin-code-acc     = bfpb_arh-fin-doc-contr-schet-nal.fin-code-acc     and
                                                 rbfpb_arh-fin-doc-contr-schet-n.curr-code        = bfpb_arh-fin-doc-contr-schet-nal.curr-code        and
                                                 rbfpb_arh-fin-doc-contr-schet-n.fin-ext-doc-type = bfpb_arh-fin-doc-contr-schet-nal.fin-ext-doc-type and
                                                 rbfpb_arh-fin-doc-contr-schet-n.calc-curr-code   = bfpb_arh-fin-doc-contr-schet-nal.calc-curr-code   and
                                                 rbfpb_arh-fin-doc-contr-schet-n.sum-type         = bfpb_arh-fin-doc-contr-schet-nal.sum-type         and
                                                 rbfpb_arh-fin-doc-contr-schet-n.cashbookid       = pcashbookid                                       and
                                                 rbfpb_arh-fin-doc-contr-schet-n.fact-order       > bfpb_arh-fin-doc-contr-schet-nal.fact-order       use-index pi exclusive-lock on error undo, return error return-value :
    assign
      rbfpb_arh-fin-doc-contr-schet-n.expense     = rbfpb_arh-fin-doc-contr-schet-n.expense     + parsum-base
      rbfpb_arh-fin-doc-contr-schet-n.expense-vat = rbfpb_arh-fin-doc-contr-schet-n.expense-vat + parsum-vat-base
      rbfpb_arh-fin-doc-contr-schet-n.expense-slt = rbfpb_arh-fin-doc-contr-schet-n.expense-slt + parsum-slt-base
    .
  end.
  if parmode = "close":u then do:
    find last borb_arh-fin-doc-contr-schet-nal where borb_arh-fin-doc-contr-schet-nal.host-code        = parhost-code             and
                                                     borb_arh-fin-doc-contr-schet-nal.cli-type         = parreceiver-type         and
                                                     borb_arh-fin-doc-contr-schet-nal.cli-code         = parreceiver-code         and
                                                     borb_arh-fin-doc-contr-schet-nal.contract-code    = parcontract-code         and
                                                     borb_arh-fin-doc-contr-schet-nal.fin-code-acc     = parreceiver-fin-code-acc and
                                                     borb_arh-fin-doc-contr-schet-nal.curr-code        = parcurr-code             and
                                                     borb_arh-fin-doc-contr-schet-nal.fin-ext-doc-type = parfin-ext-doc-type      and
                                                     borb_arh-fin-doc-contr-schet-nal.calc-curr-code   = parbase-code             and
                                                     borb_arh-fin-doc-contr-schet-nal.sum-type         = parsum-type              and
                                                     borb_arh-fin-doc-contr-schet-nal.cashbookid       = pcashbookid              and
                                                     borb_arh-fin-doc-contr-schet-nal.fact-order       < parfact-order            use-index pi no-error.
    create bfrb_arh-fin-doc-contr-schet-nal.
    assign
      bfrb_arh-fin-doc-contr-schet-nal.host-code        = parhost-code
      bfrb_arh-fin-doc-contr-schet-nal.cli-type         = parreceiver-type
      bfrb_arh-fin-doc-contr-schet-nal.cli-code         = parreceiver-code
      bfrb_arh-fin-doc-contr-schet-nal.contract-code    = parcontract-code
      bfrb_arh-fin-doc-contr-schet-nal.fin-code-acc     = parreceiver-fin-code-acc
      bfrb_arh-fin-doc-contr-schet-nal.curr-code        = parcurr-code
      bfrb_arh-fin-doc-contr-schet-nal.fin-ext-doc-type = parfin-ext-doc-type
      bfrb_arh-fin-doc-contr-schet-nal.calc-curr-code   = parbase-code
      bfrb_arh-fin-doc-contr-schet-nal.sum-type         = parsum-type
      bfrb_arh-fin-doc-contr-schet-nal.cource-des       = "b":u
      bfrb_arh-fin-doc-contr-schet-nal.fact-order       = parfact-order
      bfrb_arh-fin-doc-contr-schet-nal.fin-doc-code     = parfin-doc-code
      bfrb_arh-fin-doc-contr-schet-nal.fact-date        = parfact-date
      bfrb_arh-fin-doc-contr-schet-nal.curr-code        = parcurr-code
      bfrb_arh-fin-doc-contr-schet-nal.cashbookid       = pcashbookid
    .
    assign
      bfrb_arh-fin-doc-contr-schet-nal.expense          = (if available borb_arh-fin-doc-contr-schet-nal then borb_arh-fin-doc-contr-schet-nal.expense     else 0)
      bfrb_arh-fin-doc-contr-schet-nal.expense-vat      = (if available borb_arh-fin-doc-contr-schet-nal then borb_arh-fin-doc-contr-schet-nal.expense-vat else 0)
      bfrb_arh-fin-doc-contr-schet-nal.expense-slt      = (if available borb_arh-fin-doc-contr-schet-nal then borb_arh-fin-doc-contr-schet-nal.expense-slt else 0)
      bfrb_arh-fin-doc-contr-schet-nal.income           = (if available borb_arh-fin-doc-contr-schet-nal then borb_arh-fin-doc-contr-schet-nal.income      else 0) + parsum-base
      bfrb_arh-fin-doc-contr-schet-nal.income-vat       = (if available borb_arh-fin-doc-contr-schet-nal then borb_arh-fin-doc-contr-schet-nal.income-vat  else 0) + parsum-vat-base
      bfrb_arh-fin-doc-contr-schet-nal.income-slt       = (if available borb_arh-fin-doc-contr-schet-nal then borb_arh-fin-doc-contr-schet-nal.income-slt  else 0) + parsum-slt-base
    .
  end.
  else do:
    find first bfrb_arh-fin-doc-contr-schet-nal where bfrb_arh-fin-doc-contr-schet-nal.host-code        = parhost-code             and
                                                      bfrb_arh-fin-doc-contr-schet-nal.cli-type         = parreceiver-type         and
                                                      bfrb_arh-fin-doc-contr-schet-nal.cli-code         = parreceiver-code         and
                                                      bfrb_arh-fin-doc-contr-schet-nal.contract-code    = parcontract-code         and
                                                      bfrb_arh-fin-doc-contr-schet-nal.fin-code-acc     = parreceiver-fin-code-acc and
                                                      bfrb_arh-fin-doc-contr-schet-nal.curr-code        = parcurr-code             and
                                                      bfrb_arh-fin-doc-contr-schet-nal.fin-ext-doc-type = parfin-ext-doc-type      and
                                                      bfrb_arh-fin-doc-contr-schet-nal.calc-curr-code   = parbase-code             and
                                                      bfrb_arh-fin-doc-contr-schet-nal.sum-type         = parsum-type              and
                                                      bfrb_arh-fin-doc-contr-schet-nal.cashbookid       = pcashbookid              and
                                                      bfrb_arh-fin-doc-contr-schet-nal.fact-order       = parfact-order            exclusive-lock.
  end.
  for each rbfrb_arh-fin-doc-contr-schet-n where rbfrb_arh-fin-doc-contr-schet-n.host-code        = bfrb_arh-fin-doc-contr-schet-nal.host-code        and
                                                 rbfrb_arh-fin-doc-contr-schet-n.cli-type         = parreceiver-type                                  and
                                                 rbfrb_arh-fin-doc-contr-schet-n.cli-code         = parreceiver-code                                  and
                                                 rbfrb_arh-fin-doc-contr-schet-n.contract-code    = bfrb_arh-fin-doc-contr-schet-nal.contract-code    and
                                                 rbfrb_arh-fin-doc-contr-schet-n.fin-code-acc     = bfrb_arh-fin-doc-contr-schet-nal.fin-code-acc     and
                                                 rbfrb_arh-fin-doc-contr-schet-n.curr-code        = bfrb_arh-fin-doc-contr-schet-nal.curr-code        and
                                                 rbfrb_arh-fin-doc-contr-schet-n.fin-ext-doc-type = bfrb_arh-fin-doc-contr-schet-nal.fin-ext-doc-type and
                                                 rbfrb_arh-fin-doc-contr-schet-n.calc-curr-code   = bfrb_arh-fin-doc-contr-schet-nal.calc-curr-code   and
                                                 rbfrb_arh-fin-doc-contr-schet-n.sum-type         = bfrb_arh-fin-doc-contr-schet-nal.sum-type         and
                                                 rbfrb_arh-fin-doc-contr-schet-n.cashbookid       = pcashbookid                                       and
                                                 rbfrb_arh-fin-doc-contr-schet-n.fact-order       > bfrb_arh-fin-doc-contr-schet-nal.fact-order       use-index pi on error undo, return error return-value :
    assign
      rbfrb_arh-fin-doc-contr-schet-n.income     = rbfrb_arh-fin-doc-contr-schet-n.income     + parsum-base
      rbfrb_arh-fin-doc-contr-schet-n.income-vat = rbfrb_arh-fin-doc-contr-schet-n.income-vat + parsum-vat-base
      rbfrb_arh-fin-doc-contr-schet-n.income-slt = rbfrb_arh-fin-doc-contr-schet-n.income-slt + parsum-slt-base
    .
  end.
  if parmode = "delete":u then do:
    delete bfpb_arh-fin-doc-contr-schet-nal.
    delete bfrb_arh-fin-doc-contr-schet-nal.
  end.
end.
if parrel-dog-code  =  yes          and
   parcurr-dog-code <> parcurr-code and
   parcurr-dog-code <> 0            and
   parcurr-dog-code <> parbase-code then do:
  if parmode = "close":u then do:
    find last bopc_arh-fin-doc-contr-schet-nal where bopc_arh-fin-doc-contr-schet-nal.host-code        = parhost-code          and
                                                     bopc_arh-fin-doc-contr-schet-nal.cli-type         = parpayer-type         and
                                                     bopc_arh-fin-doc-contr-schet-nal.cli-code         = parpayer-code         and
                                                     bopc_arh-fin-doc-contr-schet-nal.contract-code    = parcontract-code      and
                                                     bopc_arh-fin-doc-contr-schet-nal.fin-code-acc     = parpayer-fin-code-acc and
                                                     bopc_arh-fin-doc-contr-schet-nal.curr-code        = parcurr-code          and
                                                     bopc_arh-fin-doc-contr-schet-nal.fin-ext-doc-type = parfin-ext-doc-type   and
                                                     bopc_arh-fin-doc-contr-schet-nal.calc-curr-code   = parcurr-dog-code      and
                                                     bopc_arh-fin-doc-contr-schet-nal.sum-type         = parsum-type           and
                                                     bopc_arh-fin-doc-contr-schet-nal.cashbookid       = pcashbookid           and
                                                     bopc_arh-fin-doc-contr-schet-nal.fact-order       < parfact-order         use-index pi no-error.
    create bfpc_arh-fin-doc-contr-schet-nal.
    assign
      bfpc_arh-fin-doc-contr-schet-nal.host-code        = parhost-code
      bfpc_arh-fin-doc-contr-schet-nal.cli-type         = parpayer-type
      bfpc_arh-fin-doc-contr-schet-nal.cli-code         = parpayer-code
      bfpc_arh-fin-doc-contr-schet-nal.contract-code    = parcontract-code
      bfpc_arh-fin-doc-contr-schet-nal.fin-code-acc     = parpayer-fin-code-acc
      bfpc_arh-fin-doc-contr-schet-nal.curr-code        = parcurr-code
      bfpc_arh-fin-doc-contr-schet-nal.fin-ext-doc-type = parfin-ext-doc-type
      bfpc_arh-fin-doc-contr-schet-nal.calc-curr-code   = parcurr-dog-code
      bfpc_arh-fin-doc-contr-schet-nal.sum-type         = parsum-type
      bfpc_arh-fin-doc-contr-schet-nal.cource-des       = "c":u
      bfpc_arh-fin-doc-contr-schet-nal.fact-order       = parfact-order
      bfpc_arh-fin-doc-contr-schet-nal.fin-doc-code     = parfin-doc-code
      bfpc_arh-fin-doc-contr-schet-nal.fact-date        = parfact-date
      bfpc_arh-fin-doc-contr-schet-nal.curr-code        = parcurr-code
      bfpc_arh-fin-doc-contr-schet-nal.cashbookid       = pcashbookid
      bfpc_arh-fin-doc-contr-schet-nal.income           = (if available bopc_arh-fin-doc-contr-schet-nal then bopc_arh-fin-doc-contr-schet-nal.income     else 0)
      bfpc_arh-fin-doc-contr-schet-nal.income-vat       = (if available bopc_arh-fin-doc-contr-schet-nal then bopc_arh-fin-doc-contr-schet-nal.income-vat else 0)
      bfpc_arh-fin-doc-contr-schet-nal.income-slt       = (if available bopc_arh-fin-doc-contr-schet-nal then bopc_arh-fin-doc-contr-schet-nal.income-slt else 0)
      bfpc_arh-fin-doc-contr-schet-nal.expense          = (if available bopc_arh-fin-doc-contr-schet-nal then bopc_arh-fin-doc-contr-schet-nal.expense     else 0) + parsum-contr
      bfpc_arh-fin-doc-contr-schet-nal.expense-vat      = (if available bopc_arh-fin-doc-contr-schet-nal then bopc_arh-fin-doc-contr-schet-nal.expense-vat else 0) + parsum-vat-contr
      bfpc_arh-fin-doc-contr-schet-nal.expense-slt      = (if available bopc_arh-fin-doc-contr-schet-nal then bopc_arh-fin-doc-contr-schet-nal.expense-slt else 0) + parsum-slt-contr
    .
  end.
  else do:
    find first bfpc_arh-fin-doc-contr-schet-nal where bfpc_arh-fin-doc-contr-schet-nal.host-code        = parhost-code          and
                                                      bfpc_arh-fin-doc-contr-schet-nal.cli-type         = parpayer-type         and
                                                      bfpc_arh-fin-doc-contr-schet-nal.cli-code         = parpayer-code         and
                                                      bfpc_arh-fin-doc-contr-schet-nal.contract-code    = parcontract-code      and
                                                      bfpc_arh-fin-doc-contr-schet-nal.fin-code-acc     = parpayer-fin-code-acc and
                                                      bfpc_arh-fin-doc-contr-schet-nal.curr-code        = parcurr-code          and
                                                      bfpc_arh-fin-doc-contr-schet-nal.fin-ext-doc-type = parfin-ext-doc-type   and
                                                      bfpc_arh-fin-doc-contr-schet-nal.calc-curr-code   = parcurr-dog-code      and
                                                      bfpc_arh-fin-doc-contr-schet-nal.sum-type         = parsum-type           and
                                                      bfpc_arh-fin-doc-contr-schet-nal.cashbookid       = pcashbookid           and
                                                      bfpc_arh-fin-doc-contr-schet-nal.fact-order       = parfact-order         exclusive-lock.
  end.
  for each rbfpc_arh-fin-doc-contr-schet-n where rbfpc_arh-fin-doc-contr-schet-n.host-code        = bfpc_arh-fin-doc-contr-schet-nal.host-code        and
                                                 rbfpc_arh-fin-doc-contr-schet-n.cli-type         = parpayer-type                                     and
                                                 rbfpc_arh-fin-doc-contr-schet-n.cli-code         = parpayer-code                                     and
                                                 rbfpc_arh-fin-doc-contr-schet-n.contract-code    = bfpc_arh-fin-doc-contr-schet-nal.contract-code    and
                                                 rbfpc_arh-fin-doc-contr-schet-n.fin-code-acc     = bfpc_arh-fin-doc-contr-schet-nal.fin-code-acc     and
                                                 rbfpc_arh-fin-doc-contr-schet-n.curr-code        = bfpc_arh-fin-doc-contr-schet-nal.curr-code        and
                                                 rbfpc_arh-fin-doc-contr-schet-n.fin-ext-doc-type = bfpc_arh-fin-doc-contr-schet-nal.fin-ext-doc-type and
                                                 rbfpc_arh-fin-doc-contr-schet-n.calc-curr-code   = bfpc_arh-fin-doc-contr-schet-nal.calc-curr-code   and
                                                 rbfpc_arh-fin-doc-contr-schet-n.sum-type         = bfpc_arh-fin-doc-contr-schet-nal.sum-type         and
                                                 rbfpc_arh-fin-doc-contr-schet-n.cashbookid       = pcashbookid                                       and
                                                 rbfpc_arh-fin-doc-contr-schet-n.fact-order       > bfpc_arh-fin-doc-contr-schet-nal.fact-order       use-index pi exclusive-lock on error undo, return error return-value :
    assign
      rbfpc_arh-fin-doc-contr-schet-n.expense     = rbfpc_arh-fin-doc-contr-schet-n.expense     + parsum-contr
      rbfpc_arh-fin-doc-contr-schet-n.expense-vat = rbfpc_arh-fin-doc-contr-schet-n.expense-vat + parsum-vat-contr
      rbfpc_arh-fin-doc-contr-schet-n.expense-slt = rbfpc_arh-fin-doc-contr-schet-n.expense-slt + parsum-slt-contr
    .
  end.
  if parmode = "close":u then do:
    find last borc_arh-fin-doc-contr-schet-nal where borc_arh-fin-doc-contr-schet-nal.host-code        = parhost-code             and
                                                     borc_arh-fin-doc-contr-schet-nal.cli-type         = parreceiver-type         and
                                                     borc_arh-fin-doc-contr-schet-nal.cli-code         = parreceiver-code         and
                                                     borc_arh-fin-doc-contr-schet-nal.contract-code    = parcontract-code         and
                                                     borc_arh-fin-doc-contr-schet-nal.fin-code-acc     = parreceiver-fin-code-acc and
                                                     borc_arh-fin-doc-contr-schet-nal.curr-code        = parcurr-code             and
                                                     borc_arh-fin-doc-contr-schet-nal.fin-ext-doc-type = parfin-ext-doc-type      and
                                                     borc_arh-fin-doc-contr-schet-nal.calc-curr-code   = parcurr-dog-code         and
                                                     borc_arh-fin-doc-contr-schet-nal.sum-type         = parsum-type              and
                                                     borc_arh-fin-doc-contr-schet-nal.cashbookid       = pcashbookid              and
                                                     borc_arh-fin-doc-contr-schet-nal.fact-order       < parfact-order            use-index pi no-error.
    create bfrc_arh-fin-doc-contr-schet-nal.
    assign
      bfrc_arh-fin-doc-contr-schet-nal.host-code        = parhost-code
      bfrc_arh-fin-doc-contr-schet-nal.cli-type         = parreceiver-type
      bfrc_arh-fin-doc-contr-schet-nal.cli-code         = parreceiver-code
      bfrc_arh-fin-doc-contr-schet-nal.contract-code    = parcontract-code
      bfrc_arh-fin-doc-contr-schet-nal.fin-code-acc     = parreceiver-fin-code-acc
      bfrc_arh-fin-doc-contr-schet-nal.curr-code        = parcurr-code
      bfrc_arh-fin-doc-contr-schet-nal.fin-ext-doc-type = parfin-ext-doc-type
      bfrc_arh-fin-doc-contr-schet-nal.calc-curr-code   = parcurr-dog-code
      bfrc_arh-fin-doc-contr-schet-nal.sum-type         = parsum-type
      bfrc_arh-fin-doc-contr-schet-nal.cource-des       = "c":u
      bfrc_arh-fin-doc-contr-schet-nal.fact-order       = parfact-order
      bfrc_arh-fin-doc-contr-schet-nal.fin-doc-code     = parfin-doc-code
      bfrc_arh-fin-doc-contr-schet-nal.fact-date        = parfact-date
      bfrc_arh-fin-doc-contr-schet-nal.curr-code        = parcurr-code
      bfrc_arh-fin-doc-contr-schet-nal.cashbookid       = pcashbookid
    .
    assign
      bfrc_arh-fin-doc-contr-schet-nal.expense          = (if available borc_arh-fin-doc-contr-schet-nal then borc_arh-fin-doc-contr-schet-nal.expense     else 0)
      bfrc_arh-fin-doc-contr-schet-nal.expense-vat      = (if available borc_arh-fin-doc-contr-schet-nal then borc_arh-fin-doc-contr-schet-nal.expense-vat else 0)
      bfrc_arh-fin-doc-contr-schet-nal.expense-slt      = (if available borc_arh-fin-doc-contr-schet-nal then borc_arh-fin-doc-contr-schet-nal.expense-slt else 0)
      bfrc_arh-fin-doc-contr-schet-nal.income           = (if available borc_arh-fin-doc-contr-schet-nal then borc_arh-fin-doc-contr-schet-nal.income      else 0) + parsum-contr
      bfrc_arh-fin-doc-contr-schet-nal.income-vat       = (if available borc_arh-fin-doc-contr-schet-nal then borc_arh-fin-doc-contr-schet-nal.income-vat  else 0) + parsum-vat-contr
      bfrc_arh-fin-doc-contr-schet-nal.income-slt       = (if available borc_arh-fin-doc-contr-schet-nal then borc_arh-fin-doc-contr-schet-nal.income-slt  else 0) + parsum-slt-contr
    .
  end.
  else do:
    find first bfrc_arh-fin-doc-contr-schet-nal where bfrc_arh-fin-doc-contr-schet-nal.host-code        = parhost-code             and
                                                      bfrc_arh-fin-doc-contr-schet-nal.cli-type         = parreceiver-type         and
                                                      bfrc_arh-fin-doc-contr-schet-nal.cli-code         = parreceiver-code         and
                                                      bfrc_arh-fin-doc-contr-schet-nal.contract-code    = parcontract-code         and
                                                      bfrc_arh-fin-doc-contr-schet-nal.fin-code-acc     = parreceiver-fin-code-acc and
                                                      bfrc_arh-fin-doc-contr-schet-nal.curr-code        = parcurr-code             and
                                                      bfrc_arh-fin-doc-contr-schet-nal.fin-ext-doc-type = parfin-ext-doc-type      and
                                                      bfrc_arh-fin-doc-contr-schet-nal.calc-curr-code   = parcurr-dog-code         and
                                                      bfrc_arh-fin-doc-contr-schet-nal.sum-type         = parsum-type              and
                                                      bfrc_arh-fin-doc-contr-schet-nal.cashbookid       = pcashbookid              and
                                                      bfrc_arh-fin-doc-contr-schet-nal.fact-order       = parfact-order            exclusive-lock.
  end.
  for each rbfrc_arh-fin-doc-contr-schet-n where rbfrc_arh-fin-doc-contr-schet-n.host-code        = bfrc_arh-fin-doc-contr-schet-nal.host-code        and
                                                 rbfrc_arh-fin-doc-contr-schet-n.cli-type         = parreceiver-type                                  and
                                                 rbfrc_arh-fin-doc-contr-schet-n.cli-code         = parreceiver-code                                  and
                                                 rbfrc_arh-fin-doc-contr-schet-n.contract-code    = bfrc_arh-fin-doc-contr-schet-nal.contract-code    and
                                                 rbfrc_arh-fin-doc-contr-schet-n.fin-code-acc     = bfrc_arh-fin-doc-contr-schet-nal.fin-code-acc     and
                                                 rbfrc_arh-fin-doc-contr-schet-n.curr-code        = bfrc_arh-fin-doc-contr-schet-nal.curr-code        and
                                                 rbfrc_arh-fin-doc-contr-schet-n.fin-ext-doc-type = bfrc_arh-fin-doc-contr-schet-nal.fin-ext-doc-type and
                                                 rbfrc_arh-fin-doc-contr-schet-n.calc-curr-code   = bfrc_arh-fin-doc-contr-schet-nal.calc-curr-code   and
                                                 rbfrc_arh-fin-doc-contr-schet-n.sum-type         = bfrc_arh-fin-doc-contr-schet-nal.sum-type         and
                                                 rbfrc_arh-fin-doc-contr-schet-n.cashbookid       = pcashbookid                                       and
                                                 rbfrc_arh-fin-doc-contr-schet-n.fact-order       > bfrc_arh-fin-doc-contr-schet-nal.fact-order       use-index pi on error undo, return error return-value :
    assign
      rbfrc_arh-fin-doc-contr-schet-n.income     = rbfrc_arh-fin-doc-contr-schet-n.income     + parsum-contr
      rbfrc_arh-fin-doc-contr-schet-n.income-vat = rbfrc_arh-fin-doc-contr-schet-n.income-vat + parsum-vat-contr
      rbfrc_arh-fin-doc-contr-schet-n.income-slt = rbfrc_arh-fin-doc-contr-schet-n.income-slt + parsum-slt-contr
    .
  end.
  if parmode = "delete":u then do:
    delete bfpc_arh-fin-doc-contr-schet-nal.
    delete bfrc_arh-fin-doc-contr-schet-nal.
  end.
end.
end.
end procedure.

procedure libfarhp_calc-arh-fin-doc-contr-schet-tax-n :
define input parameter parmode                    as   character                    no-undo.
define input parameter parhost-code               like ub.fin-doc.host-code         no-undo.
define input parameter parpayer-type              like ub.fin-doc.payer-type       no-undo.
define input parameter parpayer-code              like ub.fin-doc.payer-code       no-undo.
define input parameter parreceiver-type           like ub.fin-doc.receiver-type    no-undo.
define input parameter parreceiver-code           like ub.fin-doc.receiver-code    no-undo.
define input parameter parpayer-fin-code-acc      like ub.fin-code-cor-acc.fin-code no-undo.
define input parameter parreceiver-fin-code-acc   like ub.fin-code-cor-acc.fin-code no-undo.
define input parameter parfin-ext-doc-type        like ub.fin-doc.fin-ext-doc-type  no-undo.
define input parameter parsum-type                as   character                    no-undo.
define input parameter parfact-order              like ub.fin-doc.fact-order        no-undo.
define input parameter parfin-doc-code            like ub.fin-doc.fin-doc-code      no-undo.
define input parameter parfact-date               like ub.fin-doc.fact-date         no-undo.
define input parameter parcurr-code               like ub.fin-doc.curr-code         no-undo.
define input parameter parbase-code               like ub.sysconf.base-code         no-undo.
define input parameter parcurr-dog-code           like ub.contract.curr-code        no-undo.
define input parameter parrel-dog-code            as   logical                      no-undo.
define input parameter parcontract-code           like ub.contract.contract-code    no-undo.
define input parameter parvat-pc                  like ub.fin-doc-tax.vat-pc        no-undo.
define input parameter parslt-pc                  like ub.fin-doc-tax.slt-pc        no-undo.
define input parameter parwith-vat                as   logical                      no-undo.
define input parameter parwith-slt                as   logical                      no-undo.
define input parameter parsum-doc                 as   decimal                      no-undo.
define input parameter parsum-rubl                as   decimal                      no-undo.
define input parameter parsum-base                as   decimal                      no-undo.
define input parameter parsum-contr               as   decimal                      no-undo.
define input parameter parsum-vat-doc             as   decimal                      no-undo.
define input parameter parsum-vat-rubl            as   decimal                      no-undo.
define input parameter parsum-vat-base            as   decimal                      no-undo.
define input parameter parsum-vat-contr           as   decimal                      no-undo.
define input parameter parsum-slt-doc             as   decimal                      no-undo.
define input parameter parsum-slt-rubl            as   decimal                      no-undo.
define input parameter parsum-slt-base            as   decimal                      no-undo.
define input parameter parsum-slt-contr           as   decimal                      no-undo.
define buffer bfps_arh-fin-doc-c-schet-tax-nal for ub.arh-fin-doc-c-schet-tax-nal.
define buffer bfrs_arh-fin-doc-c-schet-tax-nal for ub.arh-fin-doc-c-schet-tax-nal.
define buffer rbfps_arh-fin-doc-c-schet-tax-n  for ub.arh-fin-doc-c-schet-tax-nal.
define buffer rbfrs_arh-fin-doc-c-schet-tax-n  for ub.arh-fin-doc-c-schet-tax-nal.
define buffer bops_arh-fin-doc-c-schet-tax-nal for ub.arh-fin-doc-c-schet-tax-nal.
define buffer bors_arh-fin-doc-c-schet-tax-nal for ub.arh-fin-doc-c-schet-tax-nal.
define buffer bfpr_arh-fin-doc-c-schet-tax-nal for ub.arh-fin-doc-c-schet-tax-nal.
define buffer bfrr_arh-fin-doc-c-schet-tax-nal for ub.arh-fin-doc-c-schet-tax-nal.
define buffer rbfpr_arh-fin-doc-c-schet-tax-n  for ub.arh-fin-doc-c-schet-tax-nal.
define buffer rbfrr_arh-fin-doc-c-schet-tax-n  for ub.arh-fin-doc-c-schet-tax-nal.
define buffer bopr_arh-fin-doc-c-schet-tax-nal for ub.arh-fin-doc-c-schet-tax-nal.
define buffer borr_arh-fin-doc-c-schet-tax-nal for ub.arh-fin-doc-c-schet-tax-nal.
define buffer bfpb_arh-fin-doc-c-schet-tax-nal for ub.arh-fin-doc-c-schet-tax-nal.
define buffer bfrb_arh-fin-doc-c-schet-tax-nal for ub.arh-fin-doc-c-schet-tax-nal.
define buffer rbfpb_arh-fin-doc-c-schet-tax-n  for ub.arh-fin-doc-c-schet-tax-nal.
define buffer rbfrb_arh-fin-doc-c-schet-tax-n  for ub.arh-fin-doc-c-schet-tax-nal.
define buffer bopb_arh-fin-doc-c-schet-tax-nal for ub.arh-fin-doc-c-schet-tax-nal.
define buffer borb_arh-fin-doc-c-schet-tax-nal for ub.arh-fin-doc-c-schet-tax-nal.
define buffer bfpc_arh-fin-doc-c-schet-tax-nal for ub.arh-fin-doc-c-schet-tax-nal.
define buffer bfrc_arh-fin-doc-c-schet-tax-nal for ub.arh-fin-doc-c-schet-tax-nal.
define buffer rbfpc_arh-fin-doc-c-schet-tax-n  for ub.arh-fin-doc-c-schet-tax-nal.
define buffer rbfrc_arh-fin-doc-c-schet-tax-n  for ub.arh-fin-doc-c-schet-tax-nal.
define buffer bopc_arh-fin-doc-c-schet-tax-nal for ub.arh-fin-doc-c-schet-tax-nal.
define buffer borc_arh-fin-doc-c-schet-tax-nal for ub.arh-fin-doc-c-schet-tax-nal.
do on error undo, return error substitute ("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
if parmode = "close":u then do:
  find last bops_arh-fin-doc-c-schet-tax-nal where bops_arh-fin-doc-c-schet-tax-nal.host-code        = parhost-code          and
                                                   bops_arh-fin-doc-c-schet-tax-nal.cli-type         = parpayer-type         and
                                                   bops_arh-fin-doc-c-schet-tax-nal.cli-code         = parpayer-code         and
                                                   bops_arh-fin-doc-c-schet-tax-nal.contract-code    = parcontract-code      and
                                                   bops_arh-fin-doc-c-schet-tax-nal.fin-code-acc     = parpayer-fin-code-acc and
                                                   bops_arh-fin-doc-c-schet-tax-nal.curr-code        = parcurr-code          and
                                                   bops_arh-fin-doc-c-schet-tax-nal.fin-ext-doc-type = parfin-ext-doc-type   and
                                                   bops_arh-fin-doc-c-schet-tax-nal.calc-curr-code   = parcurr-code          and
                                                   bops_arh-fin-doc-c-schet-tax-nal.vat-pc           = parvat-pc             and
                                                   bops_arh-fin-doc-c-schet-tax-nal.slt-pc           = parslt-pc             and
                                                   bops_arh-fin-doc-c-schet-tax-nal.with-vat         = parwith-vat           and
                                                   bops_arh-fin-doc-c-schet-tax-nal.with-slt         = parwith-slt           and
                                                   bops_arh-fin-doc-c-schet-tax-nal.sum-type         = parsum-type           and
                                                   bops_arh-fin-doc-c-schet-tax-nal.fact-order       < parfact-order         no-error.
  create bfps_arh-fin-doc-c-schet-tax-nal.
  assign
    bfps_arh-fin-doc-c-schet-tax-nal.host-code        = parhost-code
    bfps_arh-fin-doc-c-schet-tax-nal.contract-code    = parcontract-code
    bfps_arh-fin-doc-c-schet-tax-nal.cli-type         = parpayer-type
    bfps_arh-fin-doc-c-schet-tax-nal.cli-code         = parpayer-code
    bfps_arh-fin-doc-c-schet-tax-nal.fin-code-acc     = parpayer-fin-code-acc
    bfps_arh-fin-doc-c-schet-tax-nal.curr-code        = parcurr-code
    bfps_arh-fin-doc-c-schet-tax-nal.fin-ext-doc-type = parfin-ext-doc-type
    bfps_arh-fin-doc-c-schet-tax-nal.vat-pc           = parvat-pc
    bfps_arh-fin-doc-c-schet-tax-nal.slt-pc           = parslt-pc
    bfps_arh-fin-doc-c-schet-tax-nal.with-vat         = parwith-vat
    bfps_arh-fin-doc-c-schet-tax-nal.with-slt         = parwith-slt
    bfps_arh-fin-doc-c-schet-tax-nal.sum-type         = parsum-type
    bfps_arh-fin-doc-c-schet-tax-nal.calc-curr-code   = parcurr-code
    bfps_arh-fin-doc-c-schet-tax-nal.cource-des       = "s":u
    bfps_arh-fin-doc-c-schet-tax-nal.fact-order       = parfact-order
    bfps_arh-fin-doc-c-schet-tax-nal.fin-doc-code     = parfin-doc-code
    bfps_arh-fin-doc-c-schet-tax-nal.fact-date        = parfact-date
    bfps_arh-fin-doc-c-schet-tax-nal.curr-code        = parcurr-code
    bfps_arh-fin-doc-c-schet-tax-nal.income           = (if available bops_arh-fin-doc-c-schet-tax-nal then bops_arh-fin-doc-c-schet-tax-nal.income      else 0)
    bfps_arh-fin-doc-c-schet-tax-nal.income-vat       = (if available bops_arh-fin-doc-c-schet-tax-nal then bops_arh-fin-doc-c-schet-tax-nal.income-vat  else 0)
    bfps_arh-fin-doc-c-schet-tax-nal.income-slt       = (if available bops_arh-fin-doc-c-schet-tax-nal then bops_arh-fin-doc-c-schet-tax-nal.income-slt  else 0)
    bfps_arh-fin-doc-c-schet-tax-nal.expense          = (if available bops_arh-fin-doc-c-schet-tax-nal then bops_arh-fin-doc-c-schet-tax-nal.expense     else 0) + parsum-doc
    bfps_arh-fin-doc-c-schet-tax-nal.expense-vat      = (if available bops_arh-fin-doc-c-schet-tax-nal then bops_arh-fin-doc-c-schet-tax-nal.expense-vat else 0) + parsum-vat-doc
    bfps_arh-fin-doc-c-schet-tax-nal.expense-slt      = (if available bops_arh-fin-doc-c-schet-tax-nal then bops_arh-fin-doc-c-schet-tax-nal.expense-slt else 0) + parsum-slt-doc
  .
end.
else do:
  find first bfps_arh-fin-doc-c-schet-tax-nal where bfps_arh-fin-doc-c-schet-tax-nal.host-code        = parhost-code          and
                                                    bfps_arh-fin-doc-c-schet-tax-nal.cli-type         = parpayer-type         and
                                                    bfps_arh-fin-doc-c-schet-tax-nal.cli-code         = parpayer-code         and
                                                    bfps_arh-fin-doc-c-schet-tax-nal.contract-code    = parcontract-code      and
                                                    bfps_arh-fin-doc-c-schet-tax-nal.fin-code-acc     = parpayer-fin-code-acc and
                                                    bfps_arh-fin-doc-c-schet-tax-nal.curr-code        = parcurr-code          and
                                                    bfps_arh-fin-doc-c-schet-tax-nal.fin-ext-doc-type = parfin-ext-doc-type   and
                                                    bfps_arh-fin-doc-c-schet-tax-nal.calc-curr-code   = parcurr-code          and
                                                    bfps_arh-fin-doc-c-schet-tax-nal.vat-pc           = parvat-pc             and
                                                    bfps_arh-fin-doc-c-schet-tax-nal.slt-pc           = parslt-pc             and
                                                    bfps_arh-fin-doc-c-schet-tax-nal.with-vat         = parwith-vat           and
                                                    bfps_arh-fin-doc-c-schet-tax-nal.with-slt         = parwith-slt           and
                                                    bfps_arh-fin-doc-c-schet-tax-nal.sum-type         = parsum-type           and
                                                    bfps_arh-fin-doc-c-schet-tax-nal.fact-order       = parfact-order         exclusive-lock.
end.
for each rbfps_arh-fin-doc-c-schet-tax-n where rbfps_arh-fin-doc-c-schet-tax-n.host-code        = bfps_arh-fin-doc-c-schet-tax-nal.host-code        and
                                               rbfps_arh-fin-doc-c-schet-tax-n.cli-type         = parpayer-type                                     and
                                               rbfps_arh-fin-doc-c-schet-tax-n.cli-code         = parpayer-code                                     and
                                               rbfps_arh-fin-doc-c-schet-tax-n.contract-code    = bfps_arh-fin-doc-c-schet-tax-nal.contract-code    and
                                               rbfps_arh-fin-doc-c-schet-tax-n.fin-code-acc     = bfps_arh-fin-doc-c-schet-tax-nal.fin-code-acc     and
                                               rbfps_arh-fin-doc-c-schet-tax-n.curr-code        = bfps_arh-fin-doc-c-schet-tax-nal.curr-code        and
                                               rbfps_arh-fin-doc-c-schet-tax-n.fin-ext-doc-type = bfps_arh-fin-doc-c-schet-tax-nal.fin-ext-doc-type and
                                               rbfps_arh-fin-doc-c-schet-tax-n.calc-curr-code   = bfps_arh-fin-doc-c-schet-tax-nal.calc-curr-code   and
                                               rbfps_arh-fin-doc-c-schet-tax-n.vat-pc           = bfps_arh-fin-doc-c-schet-tax-nal.vat-pc           and
                                               rbfps_arh-fin-doc-c-schet-tax-n.slt-pc           = bfps_arh-fin-doc-c-schet-tax-nal.slt-pc           and
                                               rbfps_arh-fin-doc-c-schet-tax-n.with-vat         = bfps_arh-fin-doc-c-schet-tax-nal.with-vat         and
                                               rbfps_arh-fin-doc-c-schet-tax-n.with-slt         = bfps_arh-fin-doc-c-schet-tax-nal.with-slt         and
                                               rbfps_arh-fin-doc-c-schet-tax-n.sum-type         = bfps_arh-fin-doc-c-schet-tax-nal.sum-type         and
                                               rbfps_arh-fin-doc-c-schet-tax-n.fact-order       > bfps_arh-fin-doc-c-schet-tax-nal.fact-order       use-index pi exclusive-lock on error undo, return error return-value :
  assign
    rbfps_arh-fin-doc-c-schet-tax-n.expense     = rbfps_arh-fin-doc-c-schet-tax-n.expense     + parsum-doc
    rbfps_arh-fin-doc-c-schet-tax-n.expense-vat = rbfps_arh-fin-doc-c-schet-tax-n.expense-vat + parsum-vat-doc
    rbfps_arh-fin-doc-c-schet-tax-n.expense-slt = rbfps_arh-fin-doc-c-schet-tax-n.expense-slt + parsum-slt-doc
  .
end.
if parmode = "close":u then do:
  find last bors_arh-fin-doc-c-schet-tax-nal where bors_arh-fin-doc-c-schet-tax-nal.host-code         = parhost-code             and
                                                   bors_arh-fin-doc-c-schet-tax-nal.cli-type          = parreceiver-type         and
                                                   bors_arh-fin-doc-c-schet-tax-nal.cli-code          = parreceiver-code         and
                                                   bors_arh-fin-doc-c-schet-tax-nal.contract-code     = parcontract-code         and
                                                   bors_arh-fin-doc-c-schet-tax-nal.fin-code-acc      = parreceiver-fin-code-acc and
                                                   bors_arh-fin-doc-c-schet-tax-nal.curr-code         = parcurr-code             and
                                                   bors_arh-fin-doc-c-schet-tax-nal.fin-ext-doc-type  = parfin-ext-doc-type      and
                                                   bors_arh-fin-doc-c-schet-tax-nal.calc-curr-code    = parcurr-code             and
                                                   bors_arh-fin-doc-c-schet-tax-nal.vat-pc            = parvat-pc                and
                                                   bors_arh-fin-doc-c-schet-tax-nal.slt-pc            = parslt-pc                and
                                                   bors_arh-fin-doc-c-schet-tax-nal.with-vat          = parwith-vat              and
                                                   bors_arh-fin-doc-c-schet-tax-nal.with-slt          = parwith-slt              and
                                                   bors_arh-fin-doc-c-schet-tax-nal.sum-type          = parsum-type              and
                                                   bors_arh-fin-doc-c-schet-tax-nal.fact-order        < parfact-order            no-error.
  create bfrs_arh-fin-doc-c-schet-tax-nal.
  assign
    bfrs_arh-fin-doc-c-schet-tax-nal.host-code        = parhost-code
    bfrs_arh-fin-doc-c-schet-tax-nal.cli-type         = parreceiver-type
    bfrs_arh-fin-doc-c-schet-tax-nal.cli-code         = parreceiver-code
    bfrs_arh-fin-doc-c-schet-tax-nal.contract-code    = parcontract-code
    bfrs_arh-fin-doc-c-schet-tax-nal.fin-code-acc     = parreceiver-fin-code-acc
    bfrs_arh-fin-doc-c-schet-tax-nal.curr-code        = parcurr-code
    bfrs_arh-fin-doc-c-schet-tax-nal.fin-ext-doc-type = parfin-ext-doc-type
    bfrs_arh-fin-doc-c-schet-tax-nal.calc-curr-code   = parcurr-code
    bfrs_arh-fin-doc-c-schet-tax-nal.vat-pc           = parvat-pc
    bfrs_arh-fin-doc-c-schet-tax-nal.slt-pc           = parslt-pc
    bfrs_arh-fin-doc-c-schet-tax-nal.with-vat         = parwith-vat
    bfrs_arh-fin-doc-c-schet-tax-nal.with-slt         = parwith-slt
    bfrs_arh-fin-doc-c-schet-tax-nal.sum-type         = parsum-type
    bfrs_arh-fin-doc-c-schet-tax-nal.cource-des       = "s":u
    bfrs_arh-fin-doc-c-schet-tax-nal.fact-order       = parfact-order
    bfrs_arh-fin-doc-c-schet-tax-nal.fin-doc-code     = parfin-doc-code
    bfrs_arh-fin-doc-c-schet-tax-nal.fact-date        = parfact-date
    bfrs_arh-fin-doc-c-schet-tax-nal.curr-code        = parcurr-code
  .
  assign
    bfrs_arh-fin-doc-c-schet-tax-nal.expense          = (if available bors_arh-fin-doc-c-schet-tax-nal then bors_arh-fin-doc-c-schet-tax-nal.expense     else 0)
    bfrs_arh-fin-doc-c-schet-tax-nal.expense-vat      = (if available bors_arh-fin-doc-c-schet-tax-nal then bors_arh-fin-doc-c-schet-tax-nal.expense-vat else 0)
    bfrs_arh-fin-doc-c-schet-tax-nal.expense-slt      = (if available bors_arh-fin-doc-c-schet-tax-nal then bors_arh-fin-doc-c-schet-tax-nal.expense-slt else 0)
    bfrs_arh-fin-doc-c-schet-tax-nal.income           = (if available bors_arh-fin-doc-c-schet-tax-nal then bors_arh-fin-doc-c-schet-tax-nal.income      else 0) + parsum-doc
    bfrs_arh-fin-doc-c-schet-tax-nal.income-vat       = (if available bors_arh-fin-doc-c-schet-tax-nal then bors_arh-fin-doc-c-schet-tax-nal.income-vat  else 0) + parsum-vat-doc
    bfrs_arh-fin-doc-c-schet-tax-nal.income-slt       = (if available bors_arh-fin-doc-c-schet-tax-nal then bors_arh-fin-doc-c-schet-tax-nal.income-slt  else 0) + parsum-slt-doc
  .
end.
else do:
  find first bfrs_arh-fin-doc-c-schet-tax-nal where bfrs_arh-fin-doc-c-schet-tax-nal.host-code         = parhost-code             and
                                                    bfrs_arh-fin-doc-c-schet-tax-nal.cli-type          = parreceiver-type         and
                                                    bfrs_arh-fin-doc-c-schet-tax-nal.cli-code          = parreceiver-code         and
                                                    bfrs_arh-fin-doc-c-schet-tax-nal.contract-code     = parcontract-code         and
                                                    bfrs_arh-fin-doc-c-schet-tax-nal.fin-code-acc      = parreceiver-fin-code-acc and
                                                    bfrs_arh-fin-doc-c-schet-tax-nal.curr-code         = parcurr-code             and
                                                    bfrs_arh-fin-doc-c-schet-tax-nal.fin-ext-doc-type  = parfin-ext-doc-type      and
                                                    bfrs_arh-fin-doc-c-schet-tax-nal.calc-curr-code    = parcurr-code             and
                                                    bfrs_arh-fin-doc-c-schet-tax-nal.vat-pc            = parvat-pc                and
                                                    bfrs_arh-fin-doc-c-schet-tax-nal.slt-pc            = parslt-pc                and
                                                    bfrs_arh-fin-doc-c-schet-tax-nal.with-vat          = parwith-vat              and
                                                    bfrs_arh-fin-doc-c-schet-tax-nal.with-slt          = parwith-slt              and
                                                    bfrs_arh-fin-doc-c-schet-tax-nal.sum-type          = parsum-type              and
                                                    bfrs_arh-fin-doc-c-schet-tax-nal.fact-order        = parfact-order            exclusive-lock.
end.
for each rbfrs_arh-fin-doc-c-schet-tax-n where rbfrs_arh-fin-doc-c-schet-tax-n.host-code        = bfrs_arh-fin-doc-c-schet-tax-nal.host-code        and
                                               rbfrs_arh-fin-doc-c-schet-tax-n.cli-type         = parreceiver-type                                  and
                                               rbfrs_arh-fin-doc-c-schet-tax-n.cli-code         = parreceiver-code                                  and
                                               rbfrs_arh-fin-doc-c-schet-tax-n.contract-code    = bfrs_arh-fin-doc-c-schet-tax-nal.contract-code    and
                                               rbfrs_arh-fin-doc-c-schet-tax-n.fin-code-acc     = bfrs_arh-fin-doc-c-schet-tax-nal.fin-code-acc     and
                                               rbfrs_arh-fin-doc-c-schet-tax-n.curr-code        = bfrs_arh-fin-doc-c-schet-tax-nal.curr-code        and
                                               rbfrs_arh-fin-doc-c-schet-tax-n.fin-ext-doc-type = bfrs_arh-fin-doc-c-schet-tax-nal.fin-ext-doc-type and
                                               rbfrs_arh-fin-doc-c-schet-tax-n.calc-curr-code   = bfrs_arh-fin-doc-c-schet-tax-nal.calc-curr-code   and
                                               rbfrs_arh-fin-doc-c-schet-tax-n.vat-pc           = bfrs_arh-fin-doc-c-schet-tax-nal.vat-pc           and
                                               rbfrs_arh-fin-doc-c-schet-tax-n.slt-pc           = bfrs_arh-fin-doc-c-schet-tax-nal.slt-pc           and
                                               rbfrs_arh-fin-doc-c-schet-tax-n.with-vat         = bfrs_arh-fin-doc-c-schet-tax-nal.with-vat         and
                                               rbfrs_arh-fin-doc-c-schet-tax-n.with-slt         = bfrs_arh-fin-doc-c-schet-tax-nal.with-slt         and
                                               rbfrs_arh-fin-doc-c-schet-tax-n.sum-type         = bfrs_arh-fin-doc-c-schet-tax-nal.sum-type         and
                                               rbfrs_arh-fin-doc-c-schet-tax-n.fact-order       > bfrs_arh-fin-doc-c-schet-tax-nal.fact-order       use-index pi exclusive-lock on error undo, return error return-value :
  assign
    rbfrs_arh-fin-doc-c-schet-tax-n.income     = rbfrs_arh-fin-doc-c-schet-tax-n.income     + parsum-doc
    rbfrs_arh-fin-doc-c-schet-tax-n.income-vat = rbfrs_arh-fin-doc-c-schet-tax-n.income-vat + parsum-vat-doc
    rbfrs_arh-fin-doc-c-schet-tax-n.income-slt = rbfrs_arh-fin-doc-c-schet-tax-n.income-slt + parsum-slt-doc
  .
end.
if parmode = "delete":u then do:
  delete bfps_arh-fin-doc-c-schet-tax-nal.
  delete bfrs_arh-fin-doc-c-schet-tax-nal.
end.
if parcurr-code <> 0 then do:
  if parmode = "close":u then do:
    find last bopr_arh-fin-doc-c-schet-tax-nal where bopr_arh-fin-doc-c-schet-tax-nal.host-code        = parhost-code          and
                                                     bopr_arh-fin-doc-c-schet-tax-nal.cli-type         = parpayer-type         and
                                                     bopr_arh-fin-doc-c-schet-tax-nal.cli-code         = parpayer-code         and
                                                     bopr_arh-fin-doc-c-schet-tax-nal.contract-code    = parcontract-code      and
                                                     bopr_arh-fin-doc-c-schet-tax-nal.fin-code-acc     = parpayer-fin-code-acc and
                                                     bopr_arh-fin-doc-c-schet-tax-nal.curr-code        = parcurr-code          and
                                                     bopr_arh-fin-doc-c-schet-tax-nal.fin-ext-doc-type = parfin-ext-doc-type   and
                                                     bopr_arh-fin-doc-c-schet-tax-nal.calc-curr-code   = 0                     and
                                                     bopr_arh-fin-doc-c-schet-tax-nal.vat-pc           = parvat-pc             and
                                                     bopr_arh-fin-doc-c-schet-tax-nal.slt-pc           = parslt-pc             and
                                                     bopr_arh-fin-doc-c-schet-tax-nal.with-vat         = parwith-vat           and
                                                     bopr_arh-fin-doc-c-schet-tax-nal.with-slt         = parwith-slt           and
                                                     bopr_arh-fin-doc-c-schet-tax-nal.sum-type         = parsum-type           and
                                                     bopr_arh-fin-doc-c-schet-tax-nal.fact-order       < parfact-order         no-error.
    create bfpr_arh-fin-doc-c-schet-tax-nal.
    assign
      bfpr_arh-fin-doc-c-schet-tax-nal.host-code        = parhost-code
      bfpr_arh-fin-doc-c-schet-tax-nal.cli-type         = parpayer-type
      bfpr_arh-fin-doc-c-schet-tax-nal.cli-code         = parpayer-code
      bfpr_arh-fin-doc-c-schet-tax-nal.contract-code    = parcontract-code
      bfpr_arh-fin-doc-c-schet-tax-nal.fin-code-acc     = parpayer-fin-code-acc
      bfpr_arh-fin-doc-c-schet-tax-nal.curr-code        = parcurr-code
      bfpr_arh-fin-doc-c-schet-tax-nal.fin-ext-doc-type = parfin-ext-doc-type
      bfpr_arh-fin-doc-c-schet-tax-nal.calc-curr-code   = 0
      bfpr_arh-fin-doc-c-schet-tax-nal.vat-pc           = parvat-pc
      bfpr_arh-fin-doc-c-schet-tax-nal.slt-pc           = parslt-pc
      bfpr_arh-fin-doc-c-schet-tax-nal.with-vat         = parwith-vat
      bfpr_arh-fin-doc-c-schet-tax-nal.with-slt         = parwith-slt
      bfpr_arh-fin-doc-c-schet-tax-nal.sum-type         = parsum-type
      bfpr_arh-fin-doc-c-schet-tax-nal.cource-des       = "r":u
      bfpr_arh-fin-doc-c-schet-tax-nal.fact-order       = parfact-order
      bfpr_arh-fin-doc-c-schet-tax-nal.fin-doc-code     = parfin-doc-code
      bfpr_arh-fin-doc-c-schet-tax-nal.fact-date        = parfact-date
      bfpr_arh-fin-doc-c-schet-tax-nal.curr-code        = parcurr-code
      bfpr_arh-fin-doc-c-schet-tax-nal.income           = (if available bopr_arh-fin-doc-c-schet-tax-nal then bopr_arh-fin-doc-c-schet-tax-nal.income      else 0)
      bfpr_arh-fin-doc-c-schet-tax-nal.income-vat       = (if available bopr_arh-fin-doc-c-schet-tax-nal then bopr_arh-fin-doc-c-schet-tax-nal.income-vat  else 0)
      bfpr_arh-fin-doc-c-schet-tax-nal.income-slt       = (if available bopr_arh-fin-doc-c-schet-tax-nal then bopr_arh-fin-doc-c-schet-tax-nal.income-slt  else 0)
      bfpr_arh-fin-doc-c-schet-tax-nal.expense          = (if available bopr_arh-fin-doc-c-schet-tax-nal then bopr_arh-fin-doc-c-schet-tax-nal.expense     else 0) + parsum-rubl
      bfpr_arh-fin-doc-c-schet-tax-nal.expense-vat      = (if available bopr_arh-fin-doc-c-schet-tax-nal then bopr_arh-fin-doc-c-schet-tax-nal.expense-vat else 0) + parsum-vat-rubl
      bfpr_arh-fin-doc-c-schet-tax-nal.expense-slt      = (if available bopr_arh-fin-doc-c-schet-tax-nal then bopr_arh-fin-doc-c-schet-tax-nal.expense-slt else 0) + parsum-slt-rubl
    .
  end.
  else do:
    find first bfpr_arh-fin-doc-c-schet-tax-nal where bfpr_arh-fin-doc-c-schet-tax-nal.host-code        = parhost-code          and
                                                      bfpr_arh-fin-doc-c-schet-tax-nal.cli-type         = parpayer-type         and
                                                      bfpr_arh-fin-doc-c-schet-tax-nal.cli-code         = parpayer-code         and
                                                      bfpr_arh-fin-doc-c-schet-tax-nal.contract-code    = parcontract-code      and
                                                      bfpr_arh-fin-doc-c-schet-tax-nal.fin-code-acc     = parpayer-fin-code-acc and
                                                      bfpr_arh-fin-doc-c-schet-tax-nal.curr-code        = parcurr-code          and
                                                      bfpr_arh-fin-doc-c-schet-tax-nal.fin-ext-doc-type = parfin-ext-doc-type   and
                                                      bfpr_arh-fin-doc-c-schet-tax-nal.calc-curr-code   = 0                     and
                                                      bfpr_arh-fin-doc-c-schet-tax-nal.vat-pc           = parvat-pc             and
                                                      bfpr_arh-fin-doc-c-schet-tax-nal.slt-pc           = parslt-pc             and
                                                      bfpr_arh-fin-doc-c-schet-tax-nal.with-vat         = parwith-vat           and
                                                      bfpr_arh-fin-doc-c-schet-tax-nal.with-slt         = parwith-slt           and
                                                      bfpr_arh-fin-doc-c-schet-tax-nal.sum-type         = parsum-type           and
                                                      bfpr_arh-fin-doc-c-schet-tax-nal.fact-order       = parfact-order         exclusive-lock.
  end.
  for each rbfpr_arh-fin-doc-c-schet-tax-n where rbfpr_arh-fin-doc-c-schet-tax-n.host-code        = bfpr_arh-fin-doc-c-schet-tax-nal.host-code        and
                                                 rbfpr_arh-fin-doc-c-schet-tax-n.cli-type         = parpayer-type                                     and
                                                 rbfpr_arh-fin-doc-c-schet-tax-n.cli-code         = parpayer-code                                     and
                                                 rbfpr_arh-fin-doc-c-schet-tax-n.contract-code    = bfpr_arh-fin-doc-c-schet-tax-nal.contract-code    and
                                                 rbfpr_arh-fin-doc-c-schet-tax-n.fin-code-acc     = bfpr_arh-fin-doc-c-schet-tax-nal.fin-code-acc     and
                                                 rbfpr_arh-fin-doc-c-schet-tax-n.curr-code        = bfpr_arh-fin-doc-c-schet-tax-nal.curr-code        and
                                                 rbfpr_arh-fin-doc-c-schet-tax-n.fin-ext-doc-type = bfpr_arh-fin-doc-c-schet-tax-nal.fin-ext-doc-type and
                                                 rbfpr_arh-fin-doc-c-schet-tax-n.calc-curr-code   = bfpr_arh-fin-doc-c-schet-tax-nal.calc-curr-code   and
                                                 rbfpr_arh-fin-doc-c-schet-tax-n.vat-pc           = bfpr_arh-fin-doc-c-schet-tax-nal.vat-pc           and
                                                 rbfpr_arh-fin-doc-c-schet-tax-n.slt-pc           = bfpr_arh-fin-doc-c-schet-tax-nal.slt-pc           and
                                                 rbfpr_arh-fin-doc-c-schet-tax-n.with-vat         = bfpr_arh-fin-doc-c-schet-tax-nal.with-vat         and
                                                 rbfpr_arh-fin-doc-c-schet-tax-n.with-slt         = bfpr_arh-fin-doc-c-schet-tax-nal.with-slt         and
                                                 rbfpr_arh-fin-doc-c-schet-tax-n.sum-type         = bfpr_arh-fin-doc-c-schet-tax-nal.sum-type         and
                                                 rbfpr_arh-fin-doc-c-schet-tax-n.fact-order       > bfpr_arh-fin-doc-c-schet-tax-nal.fact-order       use-index pi exclusive-lock on error undo, return error return-value :
    assign
      rbfpr_arh-fin-doc-c-schet-tax-n.expense     = rbfpr_arh-fin-doc-c-schet-tax-n.expense     + parsum-rubl
      rbfpr_arh-fin-doc-c-schet-tax-n.expense-vat = rbfpr_arh-fin-doc-c-schet-tax-n.expense-vat + parsum-vat-rubl
      rbfpr_arh-fin-doc-c-schet-tax-n.expense-slt = rbfpr_arh-fin-doc-c-schet-tax-n.expense-slt + parsum-slt-rubl
    .
  end.
  if parmode = "close":u then do:
    find last borr_arh-fin-doc-c-schet-tax-nal where borr_arh-fin-doc-c-schet-tax-nal.host-code        = parhost-code             and
                                                     borr_arh-fin-doc-c-schet-tax-nal.cli-type         = parreceiver-type         and
                                                     borr_arh-fin-doc-c-schet-tax-nal.cli-code         = parreceiver-code         and
                                                     borr_arh-fin-doc-c-schet-tax-nal.contract-code    = parcontract-code         and
                                                     borr_arh-fin-doc-c-schet-tax-nal.fin-code-acc     = parreceiver-fin-code-acc and
                                                     borr_arh-fin-doc-c-schet-tax-nal.curr-code        = parcurr-code             and
                                                     borr_arh-fin-doc-c-schet-tax-nal.fin-ext-doc-type = parfin-ext-doc-type      and
                                                     borr_arh-fin-doc-c-schet-tax-nal.calc-curr-code   = 0                        and
                                                     borr_arh-fin-doc-c-schet-tax-nal.vat-pc           = parvat-pc                and
                                                     borr_arh-fin-doc-c-schet-tax-nal.slt-pc           = parslt-pc                and
                                                     borr_arh-fin-doc-c-schet-tax-nal.with-vat         = parwith-vat              and
                                                     borr_arh-fin-doc-c-schet-tax-nal.with-slt         = parwith-slt              and
                                                     borr_arh-fin-doc-c-schet-tax-nal.sum-type         = parsum-type              and
                                                     borr_arh-fin-doc-c-schet-tax-nal.fact-order       < parfact-order            no-error.
    create bfrr_arh-fin-doc-c-schet-tax-nal.
    assign
      bfrr_arh-fin-doc-c-schet-tax-nal.host-code        = parhost-code
      bfrr_arh-fin-doc-c-schet-tax-nal.cli-type         = parreceiver-type
      bfrr_arh-fin-doc-c-schet-tax-nal.cli-code         = parreceiver-code
      bfrr_arh-fin-doc-c-schet-tax-nal.contract-code    = parcontract-code
      bfrr_arh-fin-doc-c-schet-tax-nal.fin-code-acc     = parreceiver-fin-code-acc
      bfrr_arh-fin-doc-c-schet-tax-nal.curr-code        = parcurr-code
      bfrr_arh-fin-doc-c-schet-tax-nal.fin-ext-doc-type = parfin-ext-doc-type
      bfrr_arh-fin-doc-c-schet-tax-nal.calc-curr-code   = 0
      bfrr_arh-fin-doc-c-schet-tax-nal.vat-pc           = parvat-pc
      bfrr_arh-fin-doc-c-schet-tax-nal.slt-pc           = parslt-pc
      bfrr_arh-fin-doc-c-schet-tax-nal.with-vat         = parwith-vat
      bfrr_arh-fin-doc-c-schet-tax-nal.with-slt         = parwith-slt
      bfrr_arh-fin-doc-c-schet-tax-nal.sum-type         = parsum-type
      bfrr_arh-fin-doc-c-schet-tax-nal.cource-des       = "r":u
      bfrr_arh-fin-doc-c-schet-tax-nal.fact-order       = parfact-order
      bfrr_arh-fin-doc-c-schet-tax-nal.fin-doc-code     = parfin-doc-code
      bfrr_arh-fin-doc-c-schet-tax-nal.fact-date        = parfact-date
      bfrr_arh-fin-doc-c-schet-tax-nal.curr-code        = parcurr-code
    .
    assign
      bfrr_arh-fin-doc-c-schet-tax-nal.expense          = (if available borr_arh-fin-doc-c-schet-tax-nal then borr_arh-fin-doc-c-schet-tax-nal.expense     else 0)
      bfrr_arh-fin-doc-c-schet-tax-nal.expense-vat      = (if available borr_arh-fin-doc-c-schet-tax-nal then borr_arh-fin-doc-c-schet-tax-nal.expense-vat else 0)
      bfrr_arh-fin-doc-c-schet-tax-nal.expense-slt      = (if available borr_arh-fin-doc-c-schet-tax-nal then borr_arh-fin-doc-c-schet-tax-nal.expense-slt else 0)
      bfrr_arh-fin-doc-c-schet-tax-nal.income           = (if available borr_arh-fin-doc-c-schet-tax-nal then borr_arh-fin-doc-c-schet-tax-nal.income      else 0) + parsum-rubl
      bfrr_arh-fin-doc-c-schet-tax-nal.income-vat       = (if available borr_arh-fin-doc-c-schet-tax-nal then borr_arh-fin-doc-c-schet-tax-nal.income-vat  else 0) + parsum-vat-rubl
      bfrr_arh-fin-doc-c-schet-tax-nal.income-slt       = (if available borr_arh-fin-doc-c-schet-tax-nal then borr_arh-fin-doc-c-schet-tax-nal.income-slt  else 0) + parsum-slt-rubl
    .
  end.
  else do:
    find first bfrr_arh-fin-doc-c-schet-tax-nal where bfrr_arh-fin-doc-c-schet-tax-nal.host-code        = parhost-code             and
                                                      bfrr_arh-fin-doc-c-schet-tax-nal.cli-type         = parreceiver-type         and
                                                      bfrr_arh-fin-doc-c-schet-tax-nal.cli-code         = parreceiver-code         and
                                                      bfrr_arh-fin-doc-c-schet-tax-nal.contract-code    = parcontract-code         and
                                                      bfrr_arh-fin-doc-c-schet-tax-nal.fin-code-acc     = parreceiver-fin-code-acc and
                                                      bfrr_arh-fin-doc-c-schet-tax-nal.curr-code        = parcurr-code             and
                                                      bfrr_arh-fin-doc-c-schet-tax-nal.fin-ext-doc-type = parfin-ext-doc-type      and
                                                      bfrr_arh-fin-doc-c-schet-tax-nal.calc-curr-code   = 0                        and
                                                      bfrr_arh-fin-doc-c-schet-tax-nal.vat-pc           = parvat-pc                and
                                                      bfrr_arh-fin-doc-c-schet-tax-nal.slt-pc           = parslt-pc                and
                                                      bfrr_arh-fin-doc-c-schet-tax-nal.with-vat         = parwith-vat              and
                                                      bfrr_arh-fin-doc-c-schet-tax-nal.with-slt         = parwith-slt              and
                                                      bfrr_arh-fin-doc-c-schet-tax-nal.sum-type         = parsum-type              and
                                                      bfrr_arh-fin-doc-c-schet-tax-nal.fact-order       = parfact-order            exclusive-lock.
  end.
  for each rbfrr_arh-fin-doc-c-schet-tax-n where rbfrr_arh-fin-doc-c-schet-tax-n.host-code        = bfrr_arh-fin-doc-c-schet-tax-nal.host-code        and
                                                 rbfrr_arh-fin-doc-c-schet-tax-n.cli-type         = parreceiver-type                                  and
                                                 rbfrr_arh-fin-doc-c-schet-tax-n.cli-code         = parreceiver-code                                  and
                                                 rbfrr_arh-fin-doc-c-schet-tax-n.contract-code    = bfrr_arh-fin-doc-c-schet-tax-nal.contract-code    and
                                                 rbfrr_arh-fin-doc-c-schet-tax-n.fin-code-acc     = bfrr_arh-fin-doc-c-schet-tax-nal.fin-code-acc     and
                                                 rbfrr_arh-fin-doc-c-schet-tax-n.curr-code        = bfrr_arh-fin-doc-c-schet-tax-nal.curr-code        and
                                                 rbfrr_arh-fin-doc-c-schet-tax-n.fin-ext-doc-type = bfrr_arh-fin-doc-c-schet-tax-nal.fin-ext-doc-type and
                                                 rbfrr_arh-fin-doc-c-schet-tax-n.calc-curr-code   = bfrr_arh-fin-doc-c-schet-tax-nal.calc-curr-code   and
                                                 rbfrr_arh-fin-doc-c-schet-tax-n.vat-pc           = bfrr_arh-fin-doc-c-schet-tax-nal.vat-pc           and
                                                 rbfrr_arh-fin-doc-c-schet-tax-n.slt-pc           = bfrr_arh-fin-doc-c-schet-tax-nal.slt-pc           and
                                                 rbfrr_arh-fin-doc-c-schet-tax-n.with-vat         = bfrr_arh-fin-doc-c-schet-tax-nal.with-vat         and
                                                 rbfrr_arh-fin-doc-c-schet-tax-n.with-slt         = bfrr_arh-fin-doc-c-schet-tax-nal.with-slt         and
                                                 rbfrr_arh-fin-doc-c-schet-tax-n.sum-type         = bfrr_arh-fin-doc-c-schet-tax-nal.sum-type         and
                                                 rbfrr_arh-fin-doc-c-schet-tax-n.fact-order       > bfrr_arh-fin-doc-c-schet-tax-nal.fact-order       use-index pi exclusive-lock on error undo, return error return-value :
    assign
      rbfrr_arh-fin-doc-c-schet-tax-n.income     = rbfrr_arh-fin-doc-c-schet-tax-n.income     + parsum-rubl
      rbfrr_arh-fin-doc-c-schet-tax-n.income-vat = rbfrr_arh-fin-doc-c-schet-tax-n.income-vat + parsum-vat-rubl
      rbfrr_arh-fin-doc-c-schet-tax-n.income-slt = rbfrr_arh-fin-doc-c-schet-tax-n.income-slt + parsum-slt-rubl
    .
  end.
  if parmode = "delete":u then do:
    delete bfpr_arh-fin-doc-c-schet-tax-nal.
    delete bfrr_arh-fin-doc-c-schet-tax-nal.
  end.
end.
if parbase-code <> parcurr-code and
   parbase-code <> 0            then do:
  if parmode = "close":u then do:
    find last bopb_arh-fin-doc-c-schet-tax-nal where bopb_arh-fin-doc-c-schet-tax-nal.host-code        = parhost-code          and
                                                     bopb_arh-fin-doc-c-schet-tax-nal.cli-type         = parpayer-type         and
                                                     bopb_arh-fin-doc-c-schet-tax-nal.cli-code         = parpayer-code         and
                                                     bopb_arh-fin-doc-c-schet-tax-nal.contract-code    = parcontract-code      and
                                                     bopb_arh-fin-doc-c-schet-tax-nal.fin-code-acc     = parpayer-fin-code-acc and
                                                     bopb_arh-fin-doc-c-schet-tax-nal.curr-code        = parcurr-code          and
                                                     bopb_arh-fin-doc-c-schet-tax-nal.fin-ext-doc-type = parfin-ext-doc-type   and
                                                     bopb_arh-fin-doc-c-schet-tax-nal.calc-curr-code   = parbase-code          and
                                                     bopb_arh-fin-doc-c-schet-tax-nal.vat-pc           = parvat-pc             and
                                                     bopb_arh-fin-doc-c-schet-tax-nal.slt-pc           = parslt-pc             and
                                                     bopb_arh-fin-doc-c-schet-tax-nal.with-vat         = parwith-vat           and
                                                     bopb_arh-fin-doc-c-schet-tax-nal.with-slt         = parwith-slt           and
                                                     bopb_arh-fin-doc-c-schet-tax-nal.sum-type         = parsum-type           and
                                                     bopb_arh-fin-doc-c-schet-tax-nal.fact-order       < parfact-order         no-error.
    create bfpb_arh-fin-doc-c-schet-tax-nal.
    assign
      bfpb_arh-fin-doc-c-schet-tax-nal.host-code        = parhost-code
      bfpb_arh-fin-doc-c-schet-tax-nal.cli-type         = parpayer-type
      bfpb_arh-fin-doc-c-schet-tax-nal.cli-code         = parpayer-code
      bfpb_arh-fin-doc-c-schet-tax-nal.contract-code    = parcontract-code
      bfpb_arh-fin-doc-c-schet-tax-nal.fin-code-acc     = parpayer-fin-code-acc
      bfpb_arh-fin-doc-c-schet-tax-nal.curr-code        = parcurr-code
      bfpb_arh-fin-doc-c-schet-tax-nal.fin-ext-doc-type = parfin-ext-doc-type
      bfpb_arh-fin-doc-c-schet-tax-nal.calc-curr-code   = parbase-code
      bfpb_arh-fin-doc-c-schet-tax-nal.vat-pc           = parvat-pc
      bfpb_arh-fin-doc-c-schet-tax-nal.slt-pc           = parslt-pc
      bfpb_arh-fin-doc-c-schet-tax-nal.with-vat         = parwith-vat
      bfpb_arh-fin-doc-c-schet-tax-nal.with-slt         = parwith-slt
      bfpb_arh-fin-doc-c-schet-tax-nal.sum-type         = parsum-type
      bfpb_arh-fin-doc-c-schet-tax-nal.cource-des       = "b":u
      bfpb_arh-fin-doc-c-schet-tax-nal.fact-order       = parfact-order
      bfpb_arh-fin-doc-c-schet-tax-nal.fin-doc-code     = parfin-doc-code
      bfpb_arh-fin-doc-c-schet-tax-nal.fact-date        = parfact-date
      bfpb_arh-fin-doc-c-schet-tax-nal.curr-code        = parcurr-code
      bfpb_arh-fin-doc-c-schet-tax-nal.income           = (if available bopb_arh-fin-doc-c-schet-tax-nal then bopb_arh-fin-doc-c-schet-tax-nal.income      else 0)
      bfpb_arh-fin-doc-c-schet-tax-nal.income-vat       = (if available bopb_arh-fin-doc-c-schet-tax-nal then bopb_arh-fin-doc-c-schet-tax-nal.income-vat  else 0)
      bfpb_arh-fin-doc-c-schet-tax-nal.income-slt       = (if available bopb_arh-fin-doc-c-schet-tax-nal then bopb_arh-fin-doc-c-schet-tax-nal.income-slt  else 0)
      bfpb_arh-fin-doc-c-schet-tax-nal.expense          = (if available bopb_arh-fin-doc-c-schet-tax-nal then bopb_arh-fin-doc-c-schet-tax-nal.expense     else 0) + parsum-base
      bfpb_arh-fin-doc-c-schet-tax-nal.expense-vat      = (if available bopb_arh-fin-doc-c-schet-tax-nal then bopb_arh-fin-doc-c-schet-tax-nal.expense-vat else 0) + parsum-vat-base
      bfpb_arh-fin-doc-c-schet-tax-nal.expense-slt      = (if available bopb_arh-fin-doc-c-schet-tax-nal then bopb_arh-fin-doc-c-schet-tax-nal.expense-slt else 0) + parsum-slt-base
    .
  end.
  else do:
    find first bfpb_arh-fin-doc-c-schet-tax-nal where bfpb_arh-fin-doc-c-schet-tax-nal.host-code        = parhost-code          and
                                                      bfpb_arh-fin-doc-c-schet-tax-nal.cli-type         = parpayer-type         and
                                                      bfpb_arh-fin-doc-c-schet-tax-nal.cli-code         = parpayer-code         and
                                                      bfpb_arh-fin-doc-c-schet-tax-nal.contract-code    = parcontract-code      and
                                                      bfpb_arh-fin-doc-c-schet-tax-nal.fin-code-acc     = parpayer-fin-code-acc and
                                                      bfpb_arh-fin-doc-c-schet-tax-nal.curr-code        = parcurr-code          and
                                                      bfpb_arh-fin-doc-c-schet-tax-nal.fin-ext-doc-type = parfin-ext-doc-type   and
                                                      bfpb_arh-fin-doc-c-schet-tax-nal.calc-curr-code   = parbase-code          and
                                                      bfpb_arh-fin-doc-c-schet-tax-nal.vat-pc           = parvat-pc             and
                                                      bfpb_arh-fin-doc-c-schet-tax-nal.slt-pc           = parslt-pc             and
                                                      bfpb_arh-fin-doc-c-schet-tax-nal.with-vat         = parwith-vat           and
                                                      bfpb_arh-fin-doc-c-schet-tax-nal.with-slt         = parwith-slt           and
                                                      bfpb_arh-fin-doc-c-schet-tax-nal.sum-type         = parsum-type           and
                                                      bfpb_arh-fin-doc-c-schet-tax-nal.fact-order       = parfact-order         exclusive-lock.
  end.
  for each rbfpb_arh-fin-doc-c-schet-tax-n where rbfpb_arh-fin-doc-c-schet-tax-n.host-code        = bfpb_arh-fin-doc-c-schet-tax-nal.host-code        and
                                                 rbfpb_arh-fin-doc-c-schet-tax-n.cli-type         = parpayer-type                                     and
                                                 rbfpb_arh-fin-doc-c-schet-tax-n.cli-code         = parpayer-code                                     and
                                                 rbfpb_arh-fin-doc-c-schet-tax-n.contract-code    = bfpb_arh-fin-doc-c-schet-tax-nal.contract-code    and
                                                 rbfpb_arh-fin-doc-c-schet-tax-n.fin-code-acc     = bfpb_arh-fin-doc-c-schet-tax-nal.fin-code-acc     and
                                                 rbfpb_arh-fin-doc-c-schet-tax-n.curr-code        = bfpb_arh-fin-doc-c-schet-tax-nal.curr-code        and
                                                 rbfpb_arh-fin-doc-c-schet-tax-n.fin-ext-doc-type = bfpb_arh-fin-doc-c-schet-tax-nal.fin-ext-doc-type and
                                                 rbfpb_arh-fin-doc-c-schet-tax-n.calc-curr-code   = bfpb_arh-fin-doc-c-schet-tax-nal.calc-curr-code   and
                                                 rbfpb_arh-fin-doc-c-schet-tax-n.vat-pc           = bfpb_arh-fin-doc-c-schet-tax-nal.vat-pc           and
                                                 rbfpb_arh-fin-doc-c-schet-tax-n.slt-pc           = bfpb_arh-fin-doc-c-schet-tax-nal.slt-pc           and
                                                 rbfpb_arh-fin-doc-c-schet-tax-n.with-vat         = bfpb_arh-fin-doc-c-schet-tax-nal.with-vat         and
                                                 rbfpb_arh-fin-doc-c-schet-tax-n.with-slt         = bfpb_arh-fin-doc-c-schet-tax-nal.with-slt         and
                                                 rbfpb_arh-fin-doc-c-schet-tax-n.sum-type         = bfpb_arh-fin-doc-c-schet-tax-nal.sum-type         and
                                                 rbfpb_arh-fin-doc-c-schet-tax-n.fact-order       > bfpb_arh-fin-doc-c-schet-tax-nal.fact-order       use-index pi exclusive-lock on error undo, return error return-value :
    assign
      rbfpb_arh-fin-doc-c-schet-tax-n.expense     = rbfpb_arh-fin-doc-c-schet-tax-n.expense     + parsum-base
      rbfpb_arh-fin-doc-c-schet-tax-n.expense-vat = rbfpb_arh-fin-doc-c-schet-tax-n.expense-vat + parsum-vat-base
      rbfpb_arh-fin-doc-c-schet-tax-n.expense-slt = rbfpb_arh-fin-doc-c-schet-tax-n.expense-slt + parsum-slt-base
    .
  end.
  if parmode = "close":u then do:
    find last borb_arh-fin-doc-c-schet-tax-nal where borb_arh-fin-doc-c-schet-tax-nal.host-code        = parhost-code             and
                                                     borb_arh-fin-doc-c-schet-tax-nal.cli-type         = parreceiver-type         and
                                                     borb_arh-fin-doc-c-schet-tax-nal.cli-code         = parreceiver-code         and
                                                     borb_arh-fin-doc-c-schet-tax-nal.contract-code    = parcontract-code         and
                                                     borb_arh-fin-doc-c-schet-tax-nal.fin-code-acc     = parreceiver-fin-code-acc and
                                                     borb_arh-fin-doc-c-schet-tax-nal.curr-code        = parcurr-code             and
                                                     borb_arh-fin-doc-c-schet-tax-nal.fin-ext-doc-type = parfin-ext-doc-type      and
                                                     borb_arh-fin-doc-c-schet-tax-nal.calc-curr-code   = parbase-code             and
                                                     borb_arh-fin-doc-c-schet-tax-nal.vat-pc           = parvat-pc                and
                                                     borb_arh-fin-doc-c-schet-tax-nal.slt-pc           = parslt-pc                and
                                                     borb_arh-fin-doc-c-schet-tax-nal.with-vat         = parwith-vat              and
                                                     borb_arh-fin-doc-c-schet-tax-nal.with-slt         = parwith-slt              and
                                                     borb_arh-fin-doc-c-schet-tax-nal.sum-type         = parsum-type              and
                                                     borb_arh-fin-doc-c-schet-tax-nal.fact-order       < parfact-order            no-error.
    create bfrb_arh-fin-doc-c-schet-tax-nal.
    assign
      bfrb_arh-fin-doc-c-schet-tax-nal.host-code        = parhost-code
      bfrb_arh-fin-doc-c-schet-tax-nal.cli-type         = parreceiver-type
      bfrb_arh-fin-doc-c-schet-tax-nal.cli-code         = parreceiver-code
      bfrb_arh-fin-doc-c-schet-tax-nal.contract-code    = parcontract-code
      bfrb_arh-fin-doc-c-schet-tax-nal.fin-code-acc     = parreceiver-fin-code-acc
      bfrb_arh-fin-doc-c-schet-tax-nal.curr-code        = parcurr-code
      bfrb_arh-fin-doc-c-schet-tax-nal.fin-ext-doc-type = parfin-ext-doc-type
      bfrb_arh-fin-doc-c-schet-tax-nal.calc-curr-code   = parbase-code
      bfrb_arh-fin-doc-c-schet-tax-nal.vat-pc           = parvat-pc
      bfrb_arh-fin-doc-c-schet-tax-nal.slt-pc           = parslt-pc
      bfrb_arh-fin-doc-c-schet-tax-nal.with-vat         = parwith-vat
      bfrb_arh-fin-doc-c-schet-tax-nal.with-slt         = parwith-slt
      bfrb_arh-fin-doc-c-schet-tax-nal.sum-type         = parsum-type
      bfrb_arh-fin-doc-c-schet-tax-nal.cource-des       = "b":u
      bfrb_arh-fin-doc-c-schet-tax-nal.fact-order       = parfact-order
      bfrb_arh-fin-doc-c-schet-tax-nal.fin-doc-code     = parfin-doc-code
      bfrb_arh-fin-doc-c-schet-tax-nal.fact-date        = parfact-date
      bfrb_arh-fin-doc-c-schet-tax-nal.curr-code        = parcurr-code
    .
    assign
      bfrb_arh-fin-doc-c-schet-tax-nal.expense          = (if available borb_arh-fin-doc-c-schet-tax-nal then borb_arh-fin-doc-c-schet-tax-nal.expense     else 0)
      bfrb_arh-fin-doc-c-schet-tax-nal.expense-vat      = (if available borb_arh-fin-doc-c-schet-tax-nal then borb_arh-fin-doc-c-schet-tax-nal.expense-vat else 0)
      bfrb_arh-fin-doc-c-schet-tax-nal.expense-slt      = (if available borb_arh-fin-doc-c-schet-tax-nal then borb_arh-fin-doc-c-schet-tax-nal.expense-slt else 0)
      bfrb_arh-fin-doc-c-schet-tax-nal.income           = (if available borb_arh-fin-doc-c-schet-tax-nal then borb_arh-fin-doc-c-schet-tax-nal.income      else 0) + parsum-base
      bfrb_arh-fin-doc-c-schet-tax-nal.income-vat       = (if available borb_arh-fin-doc-c-schet-tax-nal then borb_arh-fin-doc-c-schet-tax-nal.income-vat  else 0) + parsum-vat-base
      bfrb_arh-fin-doc-c-schet-tax-nal.income-slt       = (if available borb_arh-fin-doc-c-schet-tax-nal then borb_arh-fin-doc-c-schet-tax-nal.income-slt  else 0) + parsum-slt-base
    .
  end.
  else do:
    find first bfrb_arh-fin-doc-c-schet-tax-nal where bfrb_arh-fin-doc-c-schet-tax-nal.host-code        = parhost-code             and
                                                      bfrb_arh-fin-doc-c-schet-tax-nal.cli-type         = parreceiver-type         and
                                                      bfrb_arh-fin-doc-c-schet-tax-nal.cli-code         = parreceiver-code         and
                                                      bfrb_arh-fin-doc-c-schet-tax-nal.contract-code    = parcontract-code         and
                                                      bfrb_arh-fin-doc-c-schet-tax-nal.fin-code-acc     = parreceiver-fin-code-acc and
                                                      bfrb_arh-fin-doc-c-schet-tax-nal.curr-code        = parcurr-code             and
                                                      bfrb_arh-fin-doc-c-schet-tax-nal.fin-ext-doc-type = parfin-ext-doc-type      and
                                                      bfrb_arh-fin-doc-c-schet-tax-nal.calc-curr-code   = parbase-code             and
                                                      bfrb_arh-fin-doc-c-schet-tax-nal.vat-pc           = parvat-pc                and
                                                      bfrb_arh-fin-doc-c-schet-tax-nal.slt-pc           = parslt-pc                and
                                                      bfrb_arh-fin-doc-c-schet-tax-nal.with-vat         = parwith-vat              and
                                                      bfrb_arh-fin-doc-c-schet-tax-nal.with-slt         = parwith-slt              and
                                                      bfrb_arh-fin-doc-c-schet-tax-nal.sum-type         = parsum-type              and
                                                      bfrb_arh-fin-doc-c-schet-tax-nal.fact-order       = parfact-order            exclusive-lock.
  end.
  for each rbfrb_arh-fin-doc-c-schet-tax-n where rbfrb_arh-fin-doc-c-schet-tax-n.host-code        = bfrb_arh-fin-doc-c-schet-tax-nal.host-code        and
                                                 rbfrb_arh-fin-doc-c-schet-tax-n.cli-type         = parreceiver-type                                  and
                                                 rbfrb_arh-fin-doc-c-schet-tax-n.cli-code         = parreceiver-code                                  and
                                                 rbfrb_arh-fin-doc-c-schet-tax-n.contract-code    = bfrb_arh-fin-doc-c-schet-tax-nal.contract-code    and
                                                 rbfrb_arh-fin-doc-c-schet-tax-n.fin-code-acc     = bfrb_arh-fin-doc-c-schet-tax-nal.fin-code-acc     and
                                                 rbfrb_arh-fin-doc-c-schet-tax-n.curr-code        = bfrb_arh-fin-doc-c-schet-tax-nal.curr-code        and
                                                 rbfrb_arh-fin-doc-c-schet-tax-n.fin-ext-doc-type = bfrb_arh-fin-doc-c-schet-tax-nal.fin-ext-doc-type and
                                                 rbfrb_arh-fin-doc-c-schet-tax-n.calc-curr-code   = bfrb_arh-fin-doc-c-schet-tax-nal.calc-curr-code   and
                                                 rbfrb_arh-fin-doc-c-schet-tax-n.vat-pc           = bfrb_arh-fin-doc-c-schet-tax-nal.vat-pc           and
                                                 rbfrb_arh-fin-doc-c-schet-tax-n.slt-pc           = bfrb_arh-fin-doc-c-schet-tax-nal.slt-pc           and
                                                 rbfrb_arh-fin-doc-c-schet-tax-n.with-vat         = bfrb_arh-fin-doc-c-schet-tax-nal.with-vat         and
                                                 rbfrb_arh-fin-doc-c-schet-tax-n.with-slt         = bfrb_arh-fin-doc-c-schet-tax-nal.with-slt         and
                                                 rbfrb_arh-fin-doc-c-schet-tax-n.sum-type         = bfrb_arh-fin-doc-c-schet-tax-nal.sum-type         and
                                                 rbfrb_arh-fin-doc-c-schet-tax-n.fact-order       > bfrb_arh-fin-doc-c-schet-tax-nal.fact-order       use-index pi exclusive-lock on error undo, return error return-value :
    assign
      rbfrb_arh-fin-doc-c-schet-tax-n.income     = rbfrb_arh-fin-doc-c-schet-tax-n.income     + parsum-base
      rbfrb_arh-fin-doc-c-schet-tax-n.income-vat = rbfrb_arh-fin-doc-c-schet-tax-n.income-vat + parsum-vat-base
      rbfrb_arh-fin-doc-c-schet-tax-n.income-slt = rbfrb_arh-fin-doc-c-schet-tax-n.income-slt + parsum-slt-base
    .
  end.
  if parmode = "delete":u then do:
    delete bfpb_arh-fin-doc-c-schet-tax-nal.
    delete bfrb_arh-fin-doc-c-schet-tax-nal.
  end.
end.
if parrel-dog-code  =  yes          and
   parcurr-dog-code <> parcurr-code and
   parcurr-dog-code <> 0            and
   parcurr-dog-code <> parbase-code then do:
  if parmode = "close":u then do:
    find last bopc_arh-fin-doc-c-schet-tax-nal where bopc_arh-fin-doc-c-schet-tax-nal.host-code        = parhost-code          and
                                                     bopc_arh-fin-doc-c-schet-tax-nal.cli-type         = parpayer-type         and
                                                     bopc_arh-fin-doc-c-schet-tax-nal.cli-code         = parpayer-code         and
                                                     bopc_arh-fin-doc-c-schet-tax-nal.contract-code    = parcontract-code      and
                                                     bopc_arh-fin-doc-c-schet-tax-nal.fin-code-acc     = parpayer-fin-code-acc and
                                                     bopc_arh-fin-doc-c-schet-tax-nal.curr-code        = parcurr-code          and
                                                     bopc_arh-fin-doc-c-schet-tax-nal.fin-ext-doc-type = parfin-ext-doc-type   and
                                                     bopc_arh-fin-doc-c-schet-tax-nal.calc-curr-code   = parcurr-dog-code      and
                                                     bopc_arh-fin-doc-c-schet-tax-nal.vat-pc           = parvat-pc             and
                                                     bopc_arh-fin-doc-c-schet-tax-nal.slt-pc           = parslt-pc             and
                                                     bopc_arh-fin-doc-c-schet-tax-nal.with-vat         = parwith-vat           and
                                                     bopc_arh-fin-doc-c-schet-tax-nal.with-slt         = parwith-slt           and
                                                     bopc_arh-fin-doc-c-schet-tax-nal.sum-type         = parsum-type           and
                                                     bopc_arh-fin-doc-c-schet-tax-nal.fact-order       < parfact-order         no-error.
    create bfpc_arh-fin-doc-c-schet-tax-nal.
    assign
      bfpc_arh-fin-doc-c-schet-tax-nal.host-code        = parhost-code
      bfpc_arh-fin-doc-c-schet-tax-nal.cli-type         = parpayer-type
      bfpc_arh-fin-doc-c-schet-tax-nal.cli-code         = parpayer-code
      bfpc_arh-fin-doc-c-schet-tax-nal.contract-code    = parcontract-code
      bfpc_arh-fin-doc-c-schet-tax-nal.fin-code-acc     = parpayer-fin-code-acc
      bfpc_arh-fin-doc-c-schet-tax-nal.curr-code        = parcurr-code
      bfpc_arh-fin-doc-c-schet-tax-nal.fin-ext-doc-type = parfin-ext-doc-type
      bfpc_arh-fin-doc-c-schet-tax-nal.calc-curr-code   = parcurr-dog-code
      bfpc_arh-fin-doc-c-schet-tax-nal.vat-pc           = parvat-pc
      bfpc_arh-fin-doc-c-schet-tax-nal.slt-pc           = parslt-pc
      bfpc_arh-fin-doc-c-schet-tax-nal.with-vat         = parwith-vat
      bfpc_arh-fin-doc-c-schet-tax-nal.with-slt         = parwith-slt
      bfpc_arh-fin-doc-c-schet-tax-nal.sum-type         = parsum-type
      bfpc_arh-fin-doc-c-schet-tax-nal.cource-des       = "c":u
      bfpc_arh-fin-doc-c-schet-tax-nal.fact-order       = parfact-order
      bfpc_arh-fin-doc-c-schet-tax-nal.fin-doc-code     = parfin-doc-code
      bfpc_arh-fin-doc-c-schet-tax-nal.fact-date        = parfact-date
      bfpc_arh-fin-doc-c-schet-tax-nal.curr-code        = parcurr-code
      bfpc_arh-fin-doc-c-schet-tax-nal.income           = (if available bopc_arh-fin-doc-c-schet-tax-nal then bopc_arh-fin-doc-c-schet-tax-nal.income      else 0)
      bfpc_arh-fin-doc-c-schet-tax-nal.income-vat       = (if available bopc_arh-fin-doc-c-schet-tax-nal then bopc_arh-fin-doc-c-schet-tax-nal.income-vat  else 0)
      bfpc_arh-fin-doc-c-schet-tax-nal.income-slt       = (if available bopc_arh-fin-doc-c-schet-tax-nal then bopc_arh-fin-doc-c-schet-tax-nal.income-slt  else 0)
      bfpc_arh-fin-doc-c-schet-tax-nal.expense          = (if available bopc_arh-fin-doc-c-schet-tax-nal then bopc_arh-fin-doc-c-schet-tax-nal.expense     else 0) + parsum-contr
      bfpc_arh-fin-doc-c-schet-tax-nal.expense-vat      = (if available bopc_arh-fin-doc-c-schet-tax-nal then bopc_arh-fin-doc-c-schet-tax-nal.expense-vat else 0) + parsum-vat-contr
      bfpc_arh-fin-doc-c-schet-tax-nal.expense-slt      = (if available bopc_arh-fin-doc-c-schet-tax-nal then bopc_arh-fin-doc-c-schet-tax-nal.expense-slt else 0) + parsum-slt-contr
    .
  end.
  else do:
    find first bfpc_arh-fin-doc-c-schet-tax-nal where bfpc_arh-fin-doc-c-schet-tax-nal.host-code        = parhost-code          and
                                                      bfpc_arh-fin-doc-c-schet-tax-nal.cli-type         = parpayer-type         and
                                                      bfpc_arh-fin-doc-c-schet-tax-nal.cli-code         = parpayer-code         and
                                                      bfpc_arh-fin-doc-c-schet-tax-nal.contract-code    = parcontract-code      and
                                                      bfpc_arh-fin-doc-c-schet-tax-nal.fin-code-acc     = parpayer-fin-code-acc and
                                                      bfpc_arh-fin-doc-c-schet-tax-nal.curr-code        = parcurr-code          and
                                                      bfpc_arh-fin-doc-c-schet-tax-nal.fin-ext-doc-type = parfin-ext-doc-type   and
                                                      bfpc_arh-fin-doc-c-schet-tax-nal.calc-curr-code   = parcurr-dog-code      and
                                                      bfpc_arh-fin-doc-c-schet-tax-nal.vat-pc           = parvat-pc             and
                                                      bfpc_arh-fin-doc-c-schet-tax-nal.slt-pc           = parslt-pc             and
                                                      bfpc_arh-fin-doc-c-schet-tax-nal.with-vat         = parwith-vat           and
                                                      bfpc_arh-fin-doc-c-schet-tax-nal.with-slt         = parwith-slt           and
                                                      bfpc_arh-fin-doc-c-schet-tax-nal.sum-type         = parsum-type           and
                                                      bfpc_arh-fin-doc-c-schet-tax-nal.fact-order       = parfact-order         exclusive-lock.
  end.
  for each rbfpc_arh-fin-doc-c-schet-tax-n where rbfpc_arh-fin-doc-c-schet-tax-n.host-code        = bfpc_arh-fin-doc-c-schet-tax-nal.host-code        and
                                                 rbfpc_arh-fin-doc-c-schet-tax-n.cli-type         = parpayer-type                                     and
                                                 rbfpc_arh-fin-doc-c-schet-tax-n.cli-code         = parpayer-code                                     and
                                                 rbfpc_arh-fin-doc-c-schet-tax-n.contract-code    = bfpc_arh-fin-doc-c-schet-tax-nal.contract-code    and
                                                 rbfpc_arh-fin-doc-c-schet-tax-n.fin-code-acc     = bfpc_arh-fin-doc-c-schet-tax-nal.fin-code-acc     and
                                                 rbfpc_arh-fin-doc-c-schet-tax-n.curr-code        = bfpc_arh-fin-doc-c-schet-tax-nal.curr-code        and
                                                 rbfpc_arh-fin-doc-c-schet-tax-n.fin-ext-doc-type = bfpc_arh-fin-doc-c-schet-tax-nal.fin-ext-doc-type and
                                                 rbfpc_arh-fin-doc-c-schet-tax-n.calc-curr-code   = bfpc_arh-fin-doc-c-schet-tax-nal.calc-curr-code   and
                                                 rbfpc_arh-fin-doc-c-schet-tax-n.vat-pc           = bfpc_arh-fin-doc-c-schet-tax-nal.vat-pc           and
                                                 rbfpc_arh-fin-doc-c-schet-tax-n.slt-pc           = bfpc_arh-fin-doc-c-schet-tax-nal.slt-pc           and
                                                 rbfpc_arh-fin-doc-c-schet-tax-n.with-vat         = bfpc_arh-fin-doc-c-schet-tax-nal.with-vat         and
                                                 rbfpc_arh-fin-doc-c-schet-tax-n.with-slt         = bfpc_arh-fin-doc-c-schet-tax-nal.with-slt         and
                                                 rbfpc_arh-fin-doc-c-schet-tax-n.sum-type         = bfpc_arh-fin-doc-c-schet-tax-nal.sum-type         and
                                                 rbfpc_arh-fin-doc-c-schet-tax-n.fact-order       > bfpc_arh-fin-doc-c-schet-tax-nal.fact-order       use-index pi exclusive-lock on error undo, return error return-value :
    assign
      rbfpc_arh-fin-doc-c-schet-tax-n.expense     = rbfpc_arh-fin-doc-c-schet-tax-n.expense     + parsum-contr
      rbfpc_arh-fin-doc-c-schet-tax-n.expense-vat = rbfpc_arh-fin-doc-c-schet-tax-n.expense-vat + parsum-vat-contr
      rbfpc_arh-fin-doc-c-schet-tax-n.expense-slt = rbfpc_arh-fin-doc-c-schet-tax-n.expense-slt + parsum-slt-contr
    .
  end.
  if parmode = "close":u then do:
    find last borc_arh-fin-doc-c-schet-tax-nal where borc_arh-fin-doc-c-schet-tax-nal.host-code        = parhost-code             and
                                                     borc_arh-fin-doc-c-schet-tax-nal.cli-type         = parreceiver-type         and
                                                     borc_arh-fin-doc-c-schet-tax-nal.cli-code         = parreceiver-code         and
                                                     borc_arh-fin-doc-c-schet-tax-nal.contract-code    = parcontract-code         and
                                                     borc_arh-fin-doc-c-schet-tax-nal.fin-code-acc     = parreceiver-fin-code-acc and
                                                     borc_arh-fin-doc-c-schet-tax-nal.curr-code        = parcurr-code             and
                                                     borc_arh-fin-doc-c-schet-tax-nal.fin-ext-doc-type = parfin-ext-doc-type      and
                                                     borc_arh-fin-doc-c-schet-tax-nal.calc-curr-code   = parcurr-dog-code         and
                                                     borc_arh-fin-doc-c-schet-tax-nal.vat-pc           = parvat-pc                and
                                                     borc_arh-fin-doc-c-schet-tax-nal.slt-pc           = parslt-pc                and
                                                     borc_arh-fin-doc-c-schet-tax-nal.with-vat         = parwith-vat              and
                                                     borc_arh-fin-doc-c-schet-tax-nal.with-slt         = parwith-slt              and
                                                     borc_arh-fin-doc-c-schet-tax-nal.sum-type         = parsum-type              and
                                                     borc_arh-fin-doc-c-schet-tax-nal.fact-order       < parfact-order            no-error.
    create bfrc_arh-fin-doc-c-schet-tax-nal.
    assign
      bfrc_arh-fin-doc-c-schet-tax-nal.host-code        = parhost-code
      bfrc_arh-fin-doc-c-schet-tax-nal.cli-type         = parreceiver-type
      bfrc_arh-fin-doc-c-schet-tax-nal.cli-code         = parreceiver-code
      bfrc_arh-fin-doc-c-schet-tax-nal.contract-code    = parcontract-code
      bfrc_arh-fin-doc-c-schet-tax-nal.fin-code-acc     = parreceiver-fin-code-acc
      bfrc_arh-fin-doc-c-schet-tax-nal.curr-code        = parcurr-code
      bfrc_arh-fin-doc-c-schet-tax-nal.fin-ext-doc-type = parfin-ext-doc-type
      bfrc_arh-fin-doc-c-schet-tax-nal.calc-curr-code   = parcurr-dog-code
      bfrc_arh-fin-doc-c-schet-tax-nal.vat-pc           = parvat-pc
      bfrc_arh-fin-doc-c-schet-tax-nal.slt-pc           = parslt-pc
      bfrc_arh-fin-doc-c-schet-tax-nal.with-vat         = parwith-vat
      bfrc_arh-fin-doc-c-schet-tax-nal.with-slt         = parwith-slt
      bfrc_arh-fin-doc-c-schet-tax-nal.sum-type         = parsum-type
      bfrc_arh-fin-doc-c-schet-tax-nal.cource-des       = "c":u
      bfrc_arh-fin-doc-c-schet-tax-nal.fact-order       = parfact-order
      bfrc_arh-fin-doc-c-schet-tax-nal.fin-doc-code     = parfin-doc-code
      bfrc_arh-fin-doc-c-schet-tax-nal.fact-date        = parfact-date
      bfrc_arh-fin-doc-c-schet-tax-nal.curr-code        = parcurr-code
    .
    assign
      bfrc_arh-fin-doc-c-schet-tax-nal.expense          = (if available borc_arh-fin-doc-c-schet-tax-nal then borc_arh-fin-doc-c-schet-tax-nal.expense     else 0)
      bfrc_arh-fin-doc-c-schet-tax-nal.expense-vat      = (if available borc_arh-fin-doc-c-schet-tax-nal then borc_arh-fin-doc-c-schet-tax-nal.expense-vat else 0)
      bfrc_arh-fin-doc-c-schet-tax-nal.expense-slt      = (if available borc_arh-fin-doc-c-schet-tax-nal then borc_arh-fin-doc-c-schet-tax-nal.expense-slt else 0)
      bfrc_arh-fin-doc-c-schet-tax-nal.income           = (if available borc_arh-fin-doc-c-schet-tax-nal then borc_arh-fin-doc-c-schet-tax-nal.income      else 0) + parsum-contr
      bfrc_arh-fin-doc-c-schet-tax-nal.income-vat       = (if available borc_arh-fin-doc-c-schet-tax-nal then borc_arh-fin-doc-c-schet-tax-nal.income-vat  else 0) + parsum-vat-contr
      bfrc_arh-fin-doc-c-schet-tax-nal.income-slt       = (if available borc_arh-fin-doc-c-schet-tax-nal then borc_arh-fin-doc-c-schet-tax-nal.income-slt  else 0) + parsum-slt-contr
    .
  end.
  else do:
    find first bfrc_arh-fin-doc-c-schet-tax-nal where bfrc_arh-fin-doc-c-schet-tax-nal.host-code        = parhost-code             and
                                                      bfrc_arh-fin-doc-c-schet-tax-nal.cli-type         = parreceiver-type         and
                                                      bfrc_arh-fin-doc-c-schet-tax-nal.cli-code         = parreceiver-code         and
                                                      bfrc_arh-fin-doc-c-schet-tax-nal.contract-code    = parcontract-code         and
                                                      bfrc_arh-fin-doc-c-schet-tax-nal.fin-code-acc     = parreceiver-fin-code-acc and
                                                      bfrc_arh-fin-doc-c-schet-tax-nal.curr-code        = parcurr-code             and
                                                      bfrc_arh-fin-doc-c-schet-tax-nal.fin-ext-doc-type = parfin-ext-doc-type      and
                                                      bfrc_arh-fin-doc-c-schet-tax-nal.calc-curr-code   = parcurr-dog-code         and
                                                      bfrc_arh-fin-doc-c-schet-tax-nal.vat-pc           = parvat-pc                and
                                                      bfrc_arh-fin-doc-c-schet-tax-nal.slt-pc           = parslt-pc                and
                                                      bfrc_arh-fin-doc-c-schet-tax-nal.with-vat         = parwith-vat              and
                                                      bfrc_arh-fin-doc-c-schet-tax-nal.with-slt         = parwith-slt              and
                                                      bfrc_arh-fin-doc-c-schet-tax-nal.sum-type         = parsum-type              and
                                                      bfrc_arh-fin-doc-c-schet-tax-nal.fact-order       = parfact-order            exclusive-lock.
  end.
  for each rbfrc_arh-fin-doc-c-schet-tax-n where rbfrc_arh-fin-doc-c-schet-tax-n.host-code        = bfrc_arh-fin-doc-c-schet-tax-nal.host-code        and
                                                 rbfrc_arh-fin-doc-c-schet-tax-n.cli-type         = parreceiver-type                                  and
                                                 rbfrc_arh-fin-doc-c-schet-tax-n.cli-code         = parreceiver-code                                  and
                                                 rbfrc_arh-fin-doc-c-schet-tax-n.contract-code    = bfrc_arh-fin-doc-c-schet-tax-nal.contract-code    and
                                                 rbfrc_arh-fin-doc-c-schet-tax-n.fin-code-acc     = bfrc_arh-fin-doc-c-schet-tax-nal.fin-code-acc     and
                                                 rbfrc_arh-fin-doc-c-schet-tax-n.curr-code        = bfrc_arh-fin-doc-c-schet-tax-nal.curr-code        and
                                                 rbfrc_arh-fin-doc-c-schet-tax-n.fin-ext-doc-type = bfrc_arh-fin-doc-c-schet-tax-nal.fin-ext-doc-type and
                                                 rbfrc_arh-fin-doc-c-schet-tax-n.calc-curr-code   = bfrc_arh-fin-doc-c-schet-tax-nal.calc-curr-code   and
                                                 rbfrc_arh-fin-doc-c-schet-tax-n.vat-pc           = bfrc_arh-fin-doc-c-schet-tax-nal.vat-pc           and
                                                 rbfrc_arh-fin-doc-c-schet-tax-n.slt-pc           = bfrc_arh-fin-doc-c-schet-tax-nal.slt-pc           and
                                                 rbfrc_arh-fin-doc-c-schet-tax-n.with-vat         = bfrc_arh-fin-doc-c-schet-tax-nal.with-vat         and
                                                 rbfrc_arh-fin-doc-c-schet-tax-n.with-slt         = bfrc_arh-fin-doc-c-schet-tax-nal.with-slt         and
                                                 rbfrc_arh-fin-doc-c-schet-tax-n.sum-type         = bfrc_arh-fin-doc-c-schet-tax-nal.sum-type         and
                                                 rbfrc_arh-fin-doc-c-schet-tax-n.fact-order       > bfrc_arh-fin-doc-c-schet-tax-nal.fact-order       use-index pi exclusive-lock on error undo, return error return-value :
    assign
      rbfrc_arh-fin-doc-c-schet-tax-n.income     = rbfrc_arh-fin-doc-c-schet-tax-n.income     + parsum-contr
      rbfrc_arh-fin-doc-c-schet-tax-n.income-vat = rbfrc_arh-fin-doc-c-schet-tax-n.income-vat + parsum-vat-contr
      rbfrc_arh-fin-doc-c-schet-tax-n.income-slt = rbfrc_arh-fin-doc-c-schet-tax-n.income-slt + parsum-slt-contr
    .
  end.
  if parmode = "delete":u then do:
    delete bfpc_arh-fin-doc-c-schet-tax-nal.
    delete bfrc_arh-fin-doc-c-schet-tax-nal.
  end.
end.
end.
end procedure.

procedure libfarhp_calc-arh-fin-doc-schet-n :
define input parameter parmode                    as   character                    no-undo.
define input parameter parhost-code               like ub.fin-doc.host-code         no-undo.
define input parameter parpayer-type              like ub.fin-doc.payer-type       no-undo.
define input parameter parpayer-code              like ub.fin-doc.payer-code       no-undo.
define input parameter parreceiver-type           like ub.fin-doc.receiver-type    no-undo.
define input parameter parreceiver-code           like ub.fin-doc.receiver-code    no-undo.
define input parameter parpayer-fin-code-acc      like ub.fin-code-cor-acc.fin-code no-undo.
define input parameter parreceiver-fin-code-acc   like ub.fin-code-cor-acc.fin-code no-undo.
define input parameter parfin-ext-doc-type        like ub.fin-doc.fin-ext-doc-type  no-undo.
define input parameter parsum-type                as   character                    no-undo.
define input parameter parfact-order              like ub.fin-doc.fact-order        no-undo.
define input parameter parfin-doc-code            like ub.fin-doc.fin-doc-code      no-undo.
define input parameter parfact-date               like ub.fin-doc.fact-date         no-undo.
define input parameter parcurr-code               like ub.fin-doc.curr-code         no-undo.
define input parameter parbase-code               like ub.sysconf.base-code         no-undo.
define input parameter parsum-doc                 as   decimal                      no-undo.
define input parameter parsum-rubl                as   decimal                      no-undo.
define input parameter parsum-base                as   decimal                      no-undo.
define input parameter parsum-vat-doc             as   decimal                      no-undo.
define input parameter parsum-vat-rubl            as   decimal                      no-undo.
define input parameter parsum-vat-base            as   decimal                      no-undo.
define input parameter parsum-slt-doc             as   decimal                      no-undo.
define input parameter parsum-slt-rubl            as   decimal                      no-undo.
define input parameter parsum-slt-base            as   decimal                      no-undo.
define buffer bfps_arh-fin-doc-schet-nal  for ub.arh-fin-doc-schet-nal.
define buffer bfrs_arh-fin-doc-schet-nal  for ub.arh-fin-doc-schet-nal.
define buffer rbfps_arh-fin-doc-schet-nal for ub.arh-fin-doc-schet-nal.
define buffer rbfrs_arh-fin-doc-schet-nal for ub.arh-fin-doc-schet-nal.
define buffer bops_arh-fin-doc-schet-nal  for ub.arh-fin-doc-schet-nal.
define buffer bors_arh-fin-doc-schet-nal  for ub.arh-fin-doc-schet-nal.
define buffer bfpr_arh-fin-doc-schet-nal  for ub.arh-fin-doc-schet-nal.
define buffer bfrr_arh-fin-doc-schet-nal  for ub.arh-fin-doc-schet-nal.
define buffer rbfpr_arh-fin-doc-schet-nal for ub.arh-fin-doc-schet-nal.
define buffer rbfrr_arh-fin-doc-schet-nal for ub.arh-fin-doc-schet-nal.
define buffer bopr_arh-fin-doc-schet-nal  for ub.arh-fin-doc-schet-nal.
define buffer borr_arh-fin-doc-schet-nal  for ub.arh-fin-doc-schet-nal.
define buffer bfpb_arh-fin-doc-schet-nal  for ub.arh-fin-doc-schet-nal.
define buffer bfrb_arh-fin-doc-schet-nal  for ub.arh-fin-doc-schet-nal.
define buffer rbfpb_arh-fin-doc-schet-nal for ub.arh-fin-doc-schet-nal.
define buffer rbfrb_arh-fin-doc-schet-nal for ub.arh-fin-doc-schet-nal.
define buffer bopb_arh-fin-doc-schet-nal  for ub.arh-fin-doc-schet-nal.
define buffer borb_arh-fin-doc-schet-nal  for ub.arh-fin-doc-schet-nal.
define buffer bfpc_arh-fin-doc-schet-nal  for ub.arh-fin-doc-schet-nal.
define buffer bfrc_arh-fin-doc-schet-nal  for ub.arh-fin-doc-schet-nal.
define buffer rbfpc_arh-fin-doc-schet-nal for ub.arh-fin-doc-schet-nal.
define buffer rbfrc_arh-fin-doc-schet-nal for ub.arh-fin-doc-schet-nal.
define buffer bopc_arh-fin-doc-schet-nal  for ub.arh-fin-doc-schet-nal.
define buffer borc_arh-fin-doc-schet-nal  for ub.arh-fin-doc-schet-nal.
do on error undo, return error substitute ("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
if parpayer-code <> 0 then do:
if parmode = "close":u then do:
  find last bops_arh-fin-doc-schet-nal where bops_arh-fin-doc-schet-nal.host-code        = parhost-code          and
                                             bops_arh-fin-doc-schet-nal.cli-type         = parpayer-type         and
                                             bops_arh-fin-doc-schet-nal.cli-code         = parpayer-code         and
                                             bops_arh-fin-doc-schet-nal.fin-code-acc     = parpayer-fin-code-acc and
                                             bops_arh-fin-doc-schet-nal.curr-code        = parcurr-code          and
                                             bops_arh-fin-doc-schet-nal.fin-ext-doc-type = parfin-ext-doc-type   and
                                             bops_arh-fin-doc-schet-nal.calc-curr-code   = parcurr-code          and
                                             bops_arh-fin-doc-schet-nal.sum-type         = parsum-type           and
                                             bops_arh-fin-doc-schet-nal.fact-order       < parfact-order         use-index pi no-error.
  create bfps_arh-fin-doc-schet-nal.
  assign
    bfps_arh-fin-doc-schet-nal.host-code        = parhost-code
    bfps_arh-fin-doc-schet-nal.cli-type         = parpayer-type
    bfps_arh-fin-doc-schet-nal.cli-code         = parpayer-code
    bfps_arh-fin-doc-schet-nal.fin-code-acc     = parpayer-fin-code-acc
    bfps_arh-fin-doc-schet-nal.curr-code        = parcurr-code
    bfps_arh-fin-doc-schet-nal.fin-ext-doc-type = parfin-ext-doc-type
    bfps_arh-fin-doc-schet-nal.calc-curr-code   = parcurr-code
    bfps_arh-fin-doc-schet-nal.sum-type         = parsum-type
    bfps_arh-fin-doc-schet-nal.cource-des       = "s":u
    bfps_arh-fin-doc-schet-nal.fact-order       = parfact-order
    bfps_arh-fin-doc-schet-nal.fin-doc-code     = parfin-doc-code
    bfps_arh-fin-doc-schet-nal.fact-date        = parfact-date
    bfps_arh-fin-doc-schet-nal.curr-code        = parcurr-code
    bfps_arh-fin-doc-schet-nal.income           = (if available bops_arh-fin-doc-schet-nal then bops_arh-fin-doc-schet-nal.income      else 0)
    bfps_arh-fin-doc-schet-nal.income-vat       = (if available bops_arh-fin-doc-schet-nal then bops_arh-fin-doc-schet-nal.income-vat  else 0)
    bfps_arh-fin-doc-schet-nal.income-slt       = (if available bops_arh-fin-doc-schet-nal then bops_arh-fin-doc-schet-nal.income-slt  else 0)
    bfps_arh-fin-doc-schet-nal.expense          = (if available bops_arh-fin-doc-schet-nal then bops_arh-fin-doc-schet-nal.expense     else 0) + parsum-doc
    bfps_arh-fin-doc-schet-nal.expense-vat      = (if available bops_arh-fin-doc-schet-nal then bops_arh-fin-doc-schet-nal.expense-vat else 0) + parsum-vat-doc
    bfps_arh-fin-doc-schet-nal.expense-slt      = (if available bops_arh-fin-doc-schet-nal then bops_arh-fin-doc-schet-nal.expense-slt else 0) + parsum-slt-doc
  .
end.
else do:
  find first bfps_arh-fin-doc-schet-nal where bfps_arh-fin-doc-schet-nal.host-code        = parhost-code          and
                                              bfps_arh-fin-doc-schet-nal.cli-type         = parpayer-type         and
                                              bfps_arh-fin-doc-schet-nal.cli-code         = parpayer-code         and
                                              bfps_arh-fin-doc-schet-nal.fin-code-acc     = parpayer-fin-code-acc and
                                              bfps_arh-fin-doc-schet-nal.curr-code        = parcurr-code          and
                                              bfps_arh-fin-doc-schet-nal.fin-ext-doc-type = parfin-ext-doc-type   and
                                              bfps_arh-fin-doc-schet-nal.calc-curr-code   = parcurr-code          and
                                              bfps_arh-fin-doc-schet-nal.sum-type         = parsum-type           and
                                              bfps_arh-fin-doc-schet-nal.fact-order       = parfact-order         exclusive-lock.
end.
for each rbfps_arh-fin-doc-schet-nal where rbfps_arh-fin-doc-schet-nal.host-code        = bfps_arh-fin-doc-schet-nal.host-code        and
                                           rbfps_arh-fin-doc-schet-nal.cli-type         = parpayer-type                               and
                                           rbfps_arh-fin-doc-schet-nal.cli-code         = parpayer-code                               and
                                           rbfps_arh-fin-doc-schet-nal.fin-code-acc     = bfps_arh-fin-doc-schet-nal.fin-code-acc     and
                                           rbfps_arh-fin-doc-schet-nal.curr-code        = bfps_arh-fin-doc-schet-nal.curr-code        and
                                           rbfps_arh-fin-doc-schet-nal.fin-ext-doc-type = bfps_arh-fin-doc-schet-nal.fin-ext-doc-type and
                                           rbfps_arh-fin-doc-schet-nal.calc-curr-code   = bfps_arh-fin-doc-schet-nal.calc-curr-code   and
                                           rbfps_arh-fin-doc-schet-nal.sum-type         = bfps_arh-fin-doc-schet-nal.sum-type         and
                                           rbfps_arh-fin-doc-schet-nal.fact-order       > bfps_arh-fin-doc-schet-nal.fact-order       use-index pi exclusive-lock on error undo, return error return-value :
  assign
    rbfps_arh-fin-doc-schet-nal.expense     = rbfps_arh-fin-doc-schet-nal.expense     + parsum-doc
    rbfps_arh-fin-doc-schet-nal.expense-vat = rbfps_arh-fin-doc-schet-nal.expense-vat + parsum-vat-doc
    rbfps_arh-fin-doc-schet-nal.expense-slt = rbfps_arh-fin-doc-schet-nal.expense-slt + parsum-slt-doc
  .
end.
end.
if parreceiver-code <> 0 then do:
if parmode = "close":u then do:
  find last bors_arh-fin-doc-schet-nal where bors_arh-fin-doc-schet-nal.host-code        = parhost-code             and
                                             bors_arh-fin-doc-schet-nal.cli-type         = parreceiver-type         and
                                             bors_arh-fin-doc-schet-nal.cli-code         = parreceiver-code         and
                                             bors_arh-fin-doc-schet-nal.fin-code-acc     = parreceiver-fin-code-acc and
                                             bors_arh-fin-doc-schet-nal.curr-code        = parcurr-code             and
                                             bors_arh-fin-doc-schet-nal.fin-ext-doc-type = parfin-ext-doc-type      and
                                             bors_arh-fin-doc-schet-nal.calc-curr-code   = parcurr-code             and
                                             bors_arh-fin-doc-schet-nal.sum-type         = parsum-type              and
                                             bors_arh-fin-doc-schet-nal.fact-order       < parfact-order            use-index pi no-error.
  create bfrs_arh-fin-doc-schet-nal.
  assign
    bfrs_arh-fin-doc-schet-nal.host-code        = parhost-code
    bfrs_arh-fin-doc-schet-nal.cli-type         = parreceiver-type
    bfrs_arh-fin-doc-schet-nal.cli-code         = parreceiver-code
    bfrs_arh-fin-doc-schet-nal.fin-code-acc     = parreceiver-fin-code-acc
    bfrs_arh-fin-doc-schet-nal.curr-code        = parcurr-code
    bfrs_arh-fin-doc-schet-nal.fin-ext-doc-type = parfin-ext-doc-type
    bfrs_arh-fin-doc-schet-nal.calc-curr-code   = parcurr-code
    bfrs_arh-fin-doc-schet-nal.sum-type         = parsum-type
    bfrs_arh-fin-doc-schet-nal.cource-des       = "s":u
    bfrs_arh-fin-doc-schet-nal.fact-order       = parfact-order
    bfrs_arh-fin-doc-schet-nal.fin-doc-code     = parfin-doc-code
    bfrs_arh-fin-doc-schet-nal.fact-date        = parfact-date
    bfrs_arh-fin-doc-schet-nal.curr-code        = parcurr-code
  .
  assign
    bfrs_arh-fin-doc-schet-nal.expense          = (if available bors_arh-fin-doc-schet-nal then bors_arh-fin-doc-schet-nal.expense     else 0)
    bfrs_arh-fin-doc-schet-nal.expense-vat      = (if available bors_arh-fin-doc-schet-nal then bors_arh-fin-doc-schet-nal.expense-vat else 0)
    bfrs_arh-fin-doc-schet-nal.expense-slt      = (if available bors_arh-fin-doc-schet-nal then bors_arh-fin-doc-schet-nal.expense-slt else 0)
    bfrs_arh-fin-doc-schet-nal.income           = (if available bors_arh-fin-doc-schet-nal then bors_arh-fin-doc-schet-nal.income      else 0) + parsum-doc
    bfrs_arh-fin-doc-schet-nal.income-vat       = (if available bors_arh-fin-doc-schet-nal then bors_arh-fin-doc-schet-nal.income-vat  else 0) + parsum-vat-doc
    bfrs_arh-fin-doc-schet-nal.income-slt       = (if available bors_arh-fin-doc-schet-nal then bors_arh-fin-doc-schet-nal.income-slt  else 0) + parsum-slt-doc
  .
end.
else do:
  find first bfrs_arh-fin-doc-schet-nal where bfrs_arh-fin-doc-schet-nal.host-code        = parhost-code             and
                                              bfrs_arh-fin-doc-schet-nal.cli-type         = parreceiver-type         and
                                              bfrs_arh-fin-doc-schet-nal.cli-code         = parreceiver-code         and
                                              bfrs_arh-fin-doc-schet-nal.fin-code-acc     = parreceiver-fin-code-acc and
                                              bfrs_arh-fin-doc-schet-nal.curr-code        = parcurr-code             and
                                              bfrs_arh-fin-doc-schet-nal.fin-ext-doc-type = parfin-ext-doc-type      and
                                              bfrs_arh-fin-doc-schet-nal.calc-curr-code   = parcurr-code             and
                                              bfrs_arh-fin-doc-schet-nal.sum-type         = parsum-type              and
                                              bfrs_arh-fin-doc-schet-nal.fact-order       = parfact-order            exclusive-lock.
end.
for each rbfrs_arh-fin-doc-schet-nal where rbfrs_arh-fin-doc-schet-nal.host-code        = bfrs_arh-fin-doc-schet-nal.host-code        and
                                           rbfrs_arh-fin-doc-schet-nal.cli-type         = parreceiver-type                            and
                                           rbfrs_arh-fin-doc-schet-nal.cli-code         = parreceiver-code                            and
                                           rbfrs_arh-fin-doc-schet-nal.fin-code-acc     = bfrs_arh-fin-doc-schet-nal.fin-code-acc     and
                                           rbfrs_arh-fin-doc-schet-nal.curr-code        = bfrs_arh-fin-doc-schet-nal.curr-code        and
                                           rbfrs_arh-fin-doc-schet-nal.fin-ext-doc-type = bfrs_arh-fin-doc-schet-nal.fin-ext-doc-type and
                                           rbfrs_arh-fin-doc-schet-nal.calc-curr-code   = bfrs_arh-fin-doc-schet-nal.calc-curr-code   and
                                           rbfrs_arh-fin-doc-schet-nal.sum-type         = bfrs_arh-fin-doc-schet-nal.sum-type         and
                                           rbfrs_arh-fin-doc-schet-nal.fact-order       > bfrs_arh-fin-doc-schet-nal.fact-order       use-index pi exclusive-lock on error undo, return error return-value :
  assign
    rbfrs_arh-fin-doc-schet-nal.income     = rbfrs_arh-fin-doc-schet-nal.income     + parsum-doc
    rbfrs_arh-fin-doc-schet-nal.income-vat = rbfrs_arh-fin-doc-schet-nal.income-vat + parsum-vat-doc
    rbfrs_arh-fin-doc-schet-nal.income-slt = rbfrs_arh-fin-doc-schet-nal.income-slt + parsum-slt-doc
  .
end.
end. /*if parreceiver-code <> 0 then do:    */
if parmode = "delete":u then do:
  if parpayer-code <> 0 then do:
  delete bfps_arh-fin-doc-schet-nal.
  end.
  if parreceiver-code <> 0 then do:
  delete bfrs_arh-fin-doc-schet-nal.
end.
end.
if parcurr-code <> 0 then do:
if parpayer-code <> 0 then do:

  if parmode = "close":u then do:
    find last bopr_arh-fin-doc-schet-nal where bopr_arh-fin-doc-schet-nal.host-code        = parhost-code          and
                                               bopr_arh-fin-doc-schet-nal.cli-type         = parpayer-type         and
                                               bopr_arh-fin-doc-schet-nal.cli-code         = parpayer-code         and
                                               bopr_arh-fin-doc-schet-nal.fin-code-acc     = parpayer-fin-code-acc and
                                               bopr_arh-fin-doc-schet-nal.curr-code        = parcurr-code          and
                                               bopr_arh-fin-doc-schet-nal.fin-ext-doc-type = parfin-ext-doc-type   and
                                               bopr_arh-fin-doc-schet-nal.calc-curr-code   = 0                     and
                                               bopr_arh-fin-doc-schet-nal.sum-type         = parsum-type           and
                                               bopr_arh-fin-doc-schet-nal.fact-order       < parfact-order         use-index pi no-error.
    create bfpr_arh-fin-doc-schet-nal.
    assign
      bfpr_arh-fin-doc-schet-nal.host-code        = parhost-code
      bfpr_arh-fin-doc-schet-nal.cli-type         = parpayer-type
      bfpr_arh-fin-doc-schet-nal.cli-code         = parpayer-code
      bfpr_arh-fin-doc-schet-nal.fin-code-acc     = parpayer-fin-code-acc
      bfpr_arh-fin-doc-schet-nal.curr-code        = parcurr-code
      bfpr_arh-fin-doc-schet-nal.fin-ext-doc-type = parfin-ext-doc-type
      bfpr_arh-fin-doc-schet-nal.calc-curr-code   = 0
      bfpr_arh-fin-doc-schet-nal.sum-type         = parsum-type
      bfpr_arh-fin-doc-schet-nal.cource-des       = "r":u
      bfpr_arh-fin-doc-schet-nal.fact-order       = parfact-order
      bfpr_arh-fin-doc-schet-nal.fin-doc-code     = parfin-doc-code
      bfpr_arh-fin-doc-schet-nal.fact-date        = parfact-date
      bfpr_arh-fin-doc-schet-nal.curr-code        = parcurr-code
      bfpr_arh-fin-doc-schet-nal.income           = (if available bopr_arh-fin-doc-schet-nal then bopr_arh-fin-doc-schet-nal.income      else 0)
      bfpr_arh-fin-doc-schet-nal.income-vat       = (if available bopr_arh-fin-doc-schet-nal then bopr_arh-fin-doc-schet-nal.income-vat  else 0)
      bfpr_arh-fin-doc-schet-nal.income-slt       = (if available bopr_arh-fin-doc-schet-nal then bopr_arh-fin-doc-schet-nal.income-slt  else 0)
      bfpr_arh-fin-doc-schet-nal.expense          = (if available bopr_arh-fin-doc-schet-nal then bopr_arh-fin-doc-schet-nal.expense     else 0) + parsum-rubl
      bfpr_arh-fin-doc-schet-nal.expense-vat      = (if available bopr_arh-fin-doc-schet-nal then bopr_arh-fin-doc-schet-nal.expense-vat else 0) + parsum-vat-rubl
      bfpr_arh-fin-doc-schet-nal.expense-slt      = (if available bopr_arh-fin-doc-schet-nal then bopr_arh-fin-doc-schet-nal.expense-slt else 0) + parsum-slt-rubl
    .
  end.
  else do:
    find first bfpr_arh-fin-doc-schet-nal where bfpr_arh-fin-doc-schet-nal.host-code        = parhost-code          and
                                                bfpr_arh-fin-doc-schet-nal.cli-type         = parpayer-type         and
                                                bfpr_arh-fin-doc-schet-nal.cli-code         = parpayer-code         and
                                                bfpr_arh-fin-doc-schet-nal.fin-code-acc     = parpayer-fin-code-acc and
                                                bfpr_arh-fin-doc-schet-nal.curr-code        = parcurr-code          and
                                                bfpr_arh-fin-doc-schet-nal.fin-ext-doc-type = parfin-ext-doc-type   and
                                                bfpr_arh-fin-doc-schet-nal.calc-curr-code   = 0                     and
                                                bfpr_arh-fin-doc-schet-nal.sum-type         = parsum-type           and
                                                bfpr_arh-fin-doc-schet-nal.fact-order       = parfact-order         exclusive-lock.
  end.
  for each rbfpr_arh-fin-doc-schet-nal where rbfpr_arh-fin-doc-schet-nal.host-code        = bfpr_arh-fin-doc-schet-nal.host-code        and
                                             rbfpr_arh-fin-doc-schet-nal.cli-type         = parpayer-type                               and
                                             rbfpr_arh-fin-doc-schet-nal.cli-code         = parpayer-code                               and
                                             rbfpr_arh-fin-doc-schet-nal.fin-code-acc     = bfpr_arh-fin-doc-schet-nal.fin-code-acc     and
                                             rbfpr_arh-fin-doc-schet-nal.curr-code        = bfpr_arh-fin-doc-schet-nal.curr-code        and
                                             rbfpr_arh-fin-doc-schet-nal.fin-ext-doc-type = bfpr_arh-fin-doc-schet-nal.fin-ext-doc-type and
                                             rbfpr_arh-fin-doc-schet-nal.calc-curr-code   = bfpr_arh-fin-doc-schet-nal.calc-curr-code   and
                                             rbfpr_arh-fin-doc-schet-nal.sum-type         = bfpr_arh-fin-doc-schet-nal.sum-type         and
                                             rbfpr_arh-fin-doc-schet-nal.fact-order       > bfpr_arh-fin-doc-schet-nal.fact-order       use-index pi exclusive-lock on error undo, return error return-value :
    assign
      rbfpr_arh-fin-doc-schet-nal.expense     = rbfpr_arh-fin-doc-schet-nal.expense     + parsum-rubl
      rbfpr_arh-fin-doc-schet-nal.expense-vat = rbfpr_arh-fin-doc-schet-nal.expense-vat + parsum-vat-rubl
      rbfpr_arh-fin-doc-schet-nal.expense-slt = rbfpr_arh-fin-doc-schet-nal.expense-slt + parsum-slt-rubl
    .
  end.
  end. /*if parpayer-code <> 0 then do:*/
  if parreceiver-code <> 0 then do:
  if parmode = "close":u then do:
    find last borr_arh-fin-doc-schet-nal where borr_arh-fin-doc-schet-nal.host-code        = parhost-code             and
                                               borr_arh-fin-doc-schet-nal.cli-type         = parreceiver-type         and
                                               borr_arh-fin-doc-schet-nal.cli-code         = parreceiver-code         and
                                               borr_arh-fin-doc-schet-nal.fin-code-acc     = parreceiver-fin-code-acc and
                                               borr_arh-fin-doc-schet-nal.curr-code        = parcurr-code             and
                                               borr_arh-fin-doc-schet-nal.fin-ext-doc-type = parfin-ext-doc-type      and
                                               borr_arh-fin-doc-schet-nal.calc-curr-code   = 0                        and
                                               borr_arh-fin-doc-schet-nal.sum-type         = parsum-type              and
                                               borr_arh-fin-doc-schet-nal.fact-order       < parfact-order            use-index pi no-error.
    create bfrr_arh-fin-doc-schet-nal.
    assign
      bfrr_arh-fin-doc-schet-nal.host-code        = parhost-code
      bfrr_arh-fin-doc-schet-nal.cli-type         = parreceiver-type
      bfrr_arh-fin-doc-schet-nal.cli-code         = parreceiver-code
      bfrr_arh-fin-doc-schet-nal.fin-code-acc     = parreceiver-fin-code-acc
      bfrr_arh-fin-doc-schet-nal.curr-code        = parcurr-code
      bfrr_arh-fin-doc-schet-nal.fin-ext-doc-type = parfin-ext-doc-type
      bfrr_arh-fin-doc-schet-nal.calc-curr-code   = 0
      bfrr_arh-fin-doc-schet-nal.sum-type         = parsum-type
      bfrr_arh-fin-doc-schet-nal.cource-des       = "r":u
      bfrr_arh-fin-doc-schet-nal.fact-order       = parfact-order
      bfrr_arh-fin-doc-schet-nal.fin-doc-code     = parfin-doc-code
      bfrr_arh-fin-doc-schet-nal.fact-date        = parfact-date
      bfrr_arh-fin-doc-schet-nal.curr-code        = parcurr-code
    .
    assign
      bfrr_arh-fin-doc-schet-nal.expense          = (if available borr_arh-fin-doc-schet-nal then borr_arh-fin-doc-schet-nal.expense     else 0)
      bfrr_arh-fin-doc-schet-nal.expense-vat      = (if available borr_arh-fin-doc-schet-nal then borr_arh-fin-doc-schet-nal.expense-vat else 0)
      bfrr_arh-fin-doc-schet-nal.expense-slt      = (if available borr_arh-fin-doc-schet-nal then borr_arh-fin-doc-schet-nal.expense-slt else 0)
      bfrr_arh-fin-doc-schet-nal.income           = (if available borr_arh-fin-doc-schet-nal then borr_arh-fin-doc-schet-nal.income      else 0) + parsum-rubl
      bfrr_arh-fin-doc-schet-nal.income-vat       = (if available borr_arh-fin-doc-schet-nal then borr_arh-fin-doc-schet-nal.income-vat  else 0) + parsum-vat-rubl
      bfrr_arh-fin-doc-schet-nal.income-slt       = (if available borr_arh-fin-doc-schet-nal then borr_arh-fin-doc-schet-nal.income-slt  else 0) + parsum-slt-rubl
    .
  end.
  else do:
    find first bfrr_arh-fin-doc-schet-nal where bfrr_arh-fin-doc-schet-nal.host-code        = parhost-code             and
                                                bfrr_arh-fin-doc-schet-nal.cli-type         = parreceiver-type         and
                                                bfrr_arh-fin-doc-schet-nal.cli-code         = parreceiver-code         and
                                                bfrr_arh-fin-doc-schet-nal.fin-code-acc     = parreceiver-fin-code-acc and
                                                bfrr_arh-fin-doc-schet-nal.curr-code        = parcurr-code             and
                                                bfrr_arh-fin-doc-schet-nal.fin-ext-doc-type = parfin-ext-doc-type      and
                                                bfrr_arh-fin-doc-schet-nal.calc-curr-code   = 0                        and
                                                bfrr_arh-fin-doc-schet-nal.sum-type         = parsum-type              and
                                                bfrr_arh-fin-doc-schet-nal.fact-order       = parfact-order            exclusive-lock.
  end.
  for each rbfrr_arh-fin-doc-schet-nal where rbfrr_arh-fin-doc-schet-nal.host-code        = bfrr_arh-fin-doc-schet-nal.host-code        and
                                             rbfrr_arh-fin-doc-schet-nal.cli-type         = parreceiver-type                            and
                                             rbfrr_arh-fin-doc-schet-nal.cli-code         = parreceiver-code                            and
                                             rbfrr_arh-fin-doc-schet-nal.fin-code-acc     = bfrr_arh-fin-doc-schet-nal.fin-code-acc     and
                                             rbfrr_arh-fin-doc-schet-nal.curr-code        = bfrr_arh-fin-doc-schet-nal.curr-code        and
                                             rbfrr_arh-fin-doc-schet-nal.fin-ext-doc-type = bfrr_arh-fin-doc-schet-nal.fin-ext-doc-type and
                                             rbfrr_arh-fin-doc-schet-nal.calc-curr-code   = bfrr_arh-fin-doc-schet-nal.calc-curr-code   and
                                             rbfrr_arh-fin-doc-schet-nal.sum-type         = bfrr_arh-fin-doc-schet-nal.sum-type         and
                                             rbfrr_arh-fin-doc-schet-nal.fact-order       > bfrr_arh-fin-doc-schet-nal.fact-order       use-index pi exclusive-lock on error undo, return error return-value :
    assign
      rbfrr_arh-fin-doc-schet-nal.income     = rbfrr_arh-fin-doc-schet-nal.income     + parsum-doc
      rbfrr_arh-fin-doc-schet-nal.income-vat = rbfrr_arh-fin-doc-schet-nal.income-vat + parsum-vat-doc
      rbfrr_arh-fin-doc-schet-nal.income-slt = rbfrr_arh-fin-doc-schet-nal.income-slt + parsum-slt-doc
    .
  end.
  end. /*if parreceiver-code <> 0 then do:*/
  if parmode = "delete":u then do:
    if parpayer-code <> 0 then do:
    delete bfpr_arh-fin-doc-schet-nal.
    end.
    if parreceiver-code <> 0 then do:
    delete bfrr_arh-fin-doc-schet-nal.
  end.
end.
end.
if parbase-code <> parcurr-code and
   parbase-code <> 0            then do:
  if parpayer-code <> 0 then do:

  if parmode = "close":u then do:
    find last bopb_arh-fin-doc-schet-nal where bopb_arh-fin-doc-schet-nal.host-code        = parhost-code          and
                                               bopb_arh-fin-doc-schet-nal.cli-type         = parpayer-type         and
                                               bopb_arh-fin-doc-schet-nal.cli-code         = parpayer-code         and
                                               bopb_arh-fin-doc-schet-nal.fin-code-acc     = parpayer-fin-code-acc and
                                               bopb_arh-fin-doc-schet-nal.curr-code        = parcurr-code          and
                                               bopb_arh-fin-doc-schet-nal.fin-ext-doc-type = parfin-ext-doc-type   and
                                               bopb_arh-fin-doc-schet-nal.calc-curr-code   = parbase-code          and
                                               bopb_arh-fin-doc-schet-nal.sum-type         = parsum-type           and
                                               bopb_arh-fin-doc-schet-nal.fact-order       < parfact-order         use-index pi no-error.
    create bfpb_arh-fin-doc-schet-nal.
    assign
      bfpb_arh-fin-doc-schet-nal.host-code        = parhost-code
      bfpb_arh-fin-doc-schet-nal.cli-type         = parpayer-type
      bfpb_arh-fin-doc-schet-nal.cli-code         = parpayer-code
      bfpb_arh-fin-doc-schet-nal.fin-code-acc     = parpayer-fin-code-acc
      bfpb_arh-fin-doc-schet-nal.curr-code        = parcurr-code
      bfpb_arh-fin-doc-schet-nal.fin-ext-doc-type = parfin-ext-doc-type
      bfpb_arh-fin-doc-schet-nal.calc-curr-code   = parbase-code
      bfpb_arh-fin-doc-schet-nal.sum-type         = parsum-type
      bfpb_arh-fin-doc-schet-nal.cource-des       = "b":u
      bfpb_arh-fin-doc-schet-nal.fact-order       = parfact-order
      bfpb_arh-fin-doc-schet-nal.fin-doc-code     = parfin-doc-code
      bfpb_arh-fin-doc-schet-nal.fact-date        = parfact-date
      bfpb_arh-fin-doc-schet-nal.curr-code        = parcurr-code
      bfpb_arh-fin-doc-schet-nal.income           = (if available bopb_arh-fin-doc-schet-nal then bopb_arh-fin-doc-schet-nal.income      else 0)
      bfpb_arh-fin-doc-schet-nal.income-vat       = (if available bopb_arh-fin-doc-schet-nal then bopb_arh-fin-doc-schet-nal.income-vat  else 0)
      bfpb_arh-fin-doc-schet-nal.income-slt       = (if available bopb_arh-fin-doc-schet-nal then bopb_arh-fin-doc-schet-nal.income-slt  else 0)
      bfpb_arh-fin-doc-schet-nal.expense          = (if available bopb_arh-fin-doc-schet-nal then bopb_arh-fin-doc-schet-nal.expense     else 0) + parsum-base
      bfpb_arh-fin-doc-schet-nal.expense-vat      = (if available bopb_arh-fin-doc-schet-nal then bopb_arh-fin-doc-schet-nal.expense-vat else 0) + parsum-vat-base
      bfpb_arh-fin-doc-schet-nal.expense-slt      = (if available bopb_arh-fin-doc-schet-nal then bopb_arh-fin-doc-schet-nal.expense-slt else 0) + parsum-slt-base
    .
  end.
  else do:
    find first bfpb_arh-fin-doc-schet-nal where bfpb_arh-fin-doc-schet-nal.host-code        = parhost-code          and
                                                bfpb_arh-fin-doc-schet-nal.cli-type         = parpayer-type         and
                                                bfpb_arh-fin-doc-schet-nal.cli-code         = parpayer-code         and
                                                bfpb_arh-fin-doc-schet-nal.fin-code-acc     = parpayer-fin-code-acc and
                                                bfpb_arh-fin-doc-schet-nal.curr-code        = parcurr-code          and
                                                bfpb_arh-fin-doc-schet-nal.fin-ext-doc-type = parfin-ext-doc-type   and
                                                bfpb_arh-fin-doc-schet-nal.calc-curr-code   = parbase-code          and
                                                bfpb_arh-fin-doc-schet-nal.sum-type         = parsum-type           and
                                                bfpb_arh-fin-doc-schet-nal.fact-order       = parfact-order         exclusive-lock.
  end.
  for each rbfpb_arh-fin-doc-schet-nal where rbfpb_arh-fin-doc-schet-nal.host-code        = bfpb_arh-fin-doc-schet-nal.host-code        and
                                             rbfpb_arh-fin-doc-schet-nal.cli-type         = parpayer-type                               and
                                             rbfpb_arh-fin-doc-schet-nal.cli-code         = parpayer-code                               and
                                             rbfpb_arh-fin-doc-schet-nal.fin-code-acc     = bfpb_arh-fin-doc-schet-nal.fin-code-acc     and
                                             rbfpb_arh-fin-doc-schet-nal.curr-code        = bfpb_arh-fin-doc-schet-nal.curr-code        and
                                             rbfpb_arh-fin-doc-schet-nal.fin-ext-doc-type = bfpb_arh-fin-doc-schet-nal.fin-ext-doc-type and
                                             rbfpb_arh-fin-doc-schet-nal.calc-curr-code   = bfpb_arh-fin-doc-schet-nal.calc-curr-code   and
                                             rbfpb_arh-fin-doc-schet-nal.sum-type         = bfpb_arh-fin-doc-schet-nal.sum-type         and
                                             rbfpb_arh-fin-doc-schet-nal.fact-order       > bfpb_arh-fin-doc-schet-nal.fact-order       use-index pi exclusive-lock on error undo, return error return-value :
    assign
      rbfpb_arh-fin-doc-schet-nal.expense     = rbfpb_arh-fin-doc-schet-nal.expense     + parsum-base
      rbfpb_arh-fin-doc-schet-nal.expense-vat = rbfpb_arh-fin-doc-schet-nal.expense-vat + parsum-vat-base
      rbfpb_arh-fin-doc-schet-nal.expense-slt = rbfpb_arh-fin-doc-schet-nal.expense-slt + parsum-slt-base
    .
  end.
  end. /*if parpayer-code <> 0 then do:  */
  if parreceiver-code <> 0 then do:
  if parmode = "close":u then do:
    find last borb_arh-fin-doc-schet-nal where borb_arh-fin-doc-schet-nal.host-code        = parhost-code             and
                                               borb_arh-fin-doc-schet-nal.cli-type         = parreceiver-type         and
                                               borb_arh-fin-doc-schet-nal.cli-code         = parreceiver-code         and
                                               borb_arh-fin-doc-schet-nal.fin-code-acc     = parreceiver-fin-code-acc and
                                               borb_arh-fin-doc-schet-nal.curr-code        = parcurr-code             and
                                               borb_arh-fin-doc-schet-nal.fin-ext-doc-type = parfin-ext-doc-type      and
                                               borb_arh-fin-doc-schet-nal.calc-curr-code   = parbase-code             and
                                               borb_arh-fin-doc-schet-nal.sum-type         = parsum-type              and
                                               borb_arh-fin-doc-schet-nal.fact-order       < parfact-order            use-index pi no-error.
    create bfrb_arh-fin-doc-schet-nal.
    assign
      bfrb_arh-fin-doc-schet-nal.host-code        = parhost-code
      bfrb_arh-fin-doc-schet-nal.cli-type         = parreceiver-type
      bfrb_arh-fin-doc-schet-nal.cli-code         = parreceiver-code
      bfrb_arh-fin-doc-schet-nal.fin-code-acc     = parreceiver-fin-code-acc
      bfrb_arh-fin-doc-schet-nal.curr-code        = parcurr-code
      bfrb_arh-fin-doc-schet-nal.fin-ext-doc-type = parfin-ext-doc-type
      bfrb_arh-fin-doc-schet-nal.calc-curr-code   = parbase-code
      bfrb_arh-fin-doc-schet-nal.sum-type         = parsum-type
      bfrb_arh-fin-doc-schet-nal.cource-des       = "b":u
      bfrb_arh-fin-doc-schet-nal.fact-order       = parfact-order
      bfrb_arh-fin-doc-schet-nal.fin-doc-code     = parfin-doc-code
      bfrb_arh-fin-doc-schet-nal.fact-date        = parfact-date
      bfrb_arh-fin-doc-schet-nal.curr-code        = parcurr-code
    .
    assign
      bfrb_arh-fin-doc-schet-nal.expense          = (if available borb_arh-fin-doc-schet-nal then borb_arh-fin-doc-schet-nal.expense     else 0)
      bfrb_arh-fin-doc-schet-nal.expense-vat      = (if available borb_arh-fin-doc-schet-nal then borb_arh-fin-doc-schet-nal.expense-vat else 0)
      bfrb_arh-fin-doc-schet-nal.expense-slt      = (if available borb_arh-fin-doc-schet-nal then borb_arh-fin-doc-schet-nal.expense-slt else 0)
      bfrb_arh-fin-doc-schet-nal.income           = (if available borb_arh-fin-doc-schet-nal then borb_arh-fin-doc-schet-nal.income      else 0) + parsum-base
      bfrb_arh-fin-doc-schet-nal.income-vat       = (if available borb_arh-fin-doc-schet-nal then borb_arh-fin-doc-schet-nal.income-vat  else 0) + parsum-vat-base
      bfrb_arh-fin-doc-schet-nal.income-slt       = (if available borb_arh-fin-doc-schet-nal then borb_arh-fin-doc-schet-nal.income-slt  else 0) + parsum-slt-base
    .
  end.
  else do:
    find first bfrb_arh-fin-doc-schet-nal where bfrb_arh-fin-doc-schet-nal.host-code        = parhost-code             and
                                                bfrb_arh-fin-doc-schet-nal.cli-type         = parreceiver-type         and
                                                bfrb_arh-fin-doc-schet-nal.cli-code         = parreceiver-code         and
                                                bfrb_arh-fin-doc-schet-nal.fin-code-acc     = parreceiver-fin-code-acc and
                                                bfrb_arh-fin-doc-schet-nal.curr-code        = parcurr-code             and
                                                bfrb_arh-fin-doc-schet-nal.fin-ext-doc-type = parfin-ext-doc-type      and
                                                bfrb_arh-fin-doc-schet-nal.calc-curr-code   = parbase-code             and
                                                bfrb_arh-fin-doc-schet-nal.sum-type         = parsum-type              and
                                                bfrb_arh-fin-doc-schet-nal.fact-order       = parfact-order            exclusive-lock.
  end.
  for each rbfrb_arh-fin-doc-schet-nal where rbfrb_arh-fin-doc-schet-nal.host-code        = bfrb_arh-fin-doc-schet-nal.host-code        and
                                             rbfrb_arh-fin-doc-schet-nal.cli-type         = parreceiver-type                            and
                                             rbfrb_arh-fin-doc-schet-nal.cli-code         = parreceiver-code                            and
                                             rbfrb_arh-fin-doc-schet-nal.fin-code-acc     = bfrb_arh-fin-doc-schet-nal.fin-code-acc     and
                                             rbfrb_arh-fin-doc-schet-nal.curr-code        = bfrb_arh-fin-doc-schet-nal.curr-code        and
                                             rbfrb_arh-fin-doc-schet-nal.fin-ext-doc-type = bfrb_arh-fin-doc-schet-nal.fin-ext-doc-type and
                                             rbfrb_arh-fin-doc-schet-nal.calc-curr-code   = bfrb_arh-fin-doc-schet-nal.calc-curr-code   and
                                             rbfrb_arh-fin-doc-schet-nal.sum-type         = bfrb_arh-fin-doc-schet-nal.sum-type         and
                                             rbfrb_arh-fin-doc-schet-nal.fact-order       > bfrb_arh-fin-doc-schet-nal.fact-order       use-index pi exclusive-lock on error undo, return error return-value :
    assign
      rbfrb_arh-fin-doc-schet-nal.income     = rbfrb_arh-fin-doc-schet-nal.income     + parsum-base
      rbfrb_arh-fin-doc-schet-nal.income-vat = rbfrb_arh-fin-doc-schet-nal.income-vat + parsum-vat-base
      rbfrb_arh-fin-doc-schet-nal.income-slt = rbfrb_arh-fin-doc-schet-nal.income-slt + parsum-slt-base
    .
  end.
  end. /*if parreceiver-code <> 0 then do: */
  if parmode = "delete":u then do:
    if parpayer-code <> 0 then do:
    delete bfpb_arh-fin-doc-schet-nal.
    end.
    if parreceiver-code <> 0 then do:
    delete bfrb_arh-fin-doc-schet-nal.
  end.
end.
end.
end.
end procedure.

procedure libfarhp_calc-arh-fin-doc-schet-tax-n :
define input parameter parmode                    as   character                    no-undo.
define input parameter parhost-code               like ub.fin-doc.host-code         no-undo.
define input parameter parpayer-type              like ub.fin-doc.payer-type       no-undo.
define input parameter parpayer-code              like ub.fin-doc.payer-code       no-undo.
define input parameter parreceiver-type           like ub.fin-doc.receiver-type    no-undo.
define input parameter parreceiver-code           like ub.fin-doc.receiver-code    no-undo.
define input parameter parpayer-fin-code-acc      like ub.fin-code-cor-acc.fin-code no-undo.
define input parameter parreceiver-fin-code-acc   like ub.fin-code-cor-acc.fin-code no-undo.
define input parameter parfin-ext-doc-type        like ub.fin-doc.fin-ext-doc-type  no-undo.
define input parameter parsum-type                as   character                    no-undo.
define input parameter parfact-order              like ub.fin-doc.fact-order        no-undo.
define input parameter parfin-doc-code            like ub.fin-doc.fin-doc-code      no-undo.
define input parameter parfact-date               like ub.fin-doc.fact-date         no-undo.
define input parameter parcurr-code               like ub.fin-doc.curr-code         no-undo.
define input parameter parbase-code               like ub.sysconf.base-code         no-undo.
define input parameter parvat-pc                  like ub.fin-doc-tax.vat-pc        no-undo.
define input parameter parslt-pc                  like ub.fin-doc-tax.slt-pc        no-undo.
define input parameter parwith-vat                as   logical                      no-undo.
define input parameter parwith-slt                as   logical                      no-undo.
define input parameter parsum-doc                 as   decimal                      no-undo.
define input parameter parsum-rubl                as   decimal                      no-undo.
define input parameter parsum-base                as   decimal                      no-undo.
define input parameter parsum-contr               as   decimal                      no-undo.
define input parameter parsum-vat-doc             as   decimal                      no-undo.
define input parameter parsum-vat-rubl            as   decimal                      no-undo.
define input parameter parsum-vat-base            as   decimal                      no-undo.
define input parameter parsum-vat-contr           as   decimal                      no-undo.
define input parameter parsum-slt-doc             as   decimal                      no-undo.
define input parameter parsum-slt-rubl            as   decimal                      no-undo.
define input parameter parsum-slt-base            as   decimal                      no-undo.
define input parameter parsum-slt-contr           as   decimal                      no-undo.
define buffer bfps_arh-fin-doc-schet-tax-nal  for ub.arh-fin-doc-schet-tax-nal.
define buffer bfrs_arh-fin-doc-schet-tax-nal  for ub.arh-fin-doc-schet-tax-nal.
define buffer rbfps_arh-fin-doc-schet-tax-nal for ub.arh-fin-doc-schet-tax-nal.
define buffer rbfrs_arh-fin-doc-schet-tax-nal for ub.arh-fin-doc-schet-tax-nal.
define buffer bops_arh-fin-doc-schet-tax-nal  for ub.arh-fin-doc-schet-tax-nal.
define buffer bors_arh-fin-doc-schet-tax-nal  for ub.arh-fin-doc-schet-tax-nal.
define buffer bfpr_arh-fin-doc-schet-tax-nal  for ub.arh-fin-doc-schet-tax-nal.
define buffer bfrr_arh-fin-doc-schet-tax-nal  for ub.arh-fin-doc-schet-tax-nal.
define buffer rbfpr_arh-fin-doc-schet-tax-nal for ub.arh-fin-doc-schet-tax-nal.
define buffer rbfrr_arh-fin-doc-schet-tax-nal for ub.arh-fin-doc-schet-tax-nal.
define buffer bopr_arh-fin-doc-schet-tax-nal  for ub.arh-fin-doc-schet-tax-nal.
define buffer borr_arh-fin-doc-schet-tax-nal  for ub.arh-fin-doc-schet-tax-nal.
define buffer bfpb_arh-fin-doc-schet-tax-nal  for ub.arh-fin-doc-schet-tax-nal.
define buffer bfrb_arh-fin-doc-schet-tax-nal  for ub.arh-fin-doc-schet-tax-nal.
define buffer rbfpb_arh-fin-doc-schet-tax-nal for ub.arh-fin-doc-schet-tax-nal.
define buffer rbfrb_arh-fin-doc-schet-tax-nal for ub.arh-fin-doc-schet-tax-nal.
define buffer bopb_arh-fin-doc-schet-tax-nal  for ub.arh-fin-doc-schet-tax-nal.
define buffer borb_arh-fin-doc-schet-tax-nal  for ub.arh-fin-doc-schet-tax-nal.
define buffer bfpc_arh-fin-doc-schet-tax-nal  for ub.arh-fin-doc-schet-tax-nal.
define buffer bfrc_arh-fin-doc-schet-tax-nal  for ub.arh-fin-doc-schet-tax-nal.
define buffer rbfpc_arh-fin-doc-schet-tax-nal for ub.arh-fin-doc-schet-tax-nal.
define buffer rbfrc_arh-fin-doc-schet-tax-nal for ub.arh-fin-doc-schet-tax-nal.
define buffer bopc_arh-fin-doc-schet-tax-nal  for ub.arh-fin-doc-schet-tax-nal.
define buffer borc_arh-fin-doc-schet-tax-nal  for ub.arh-fin-doc-schet-tax-nal.
do on error undo, return error substitute ("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
if parmode = "close":u then do:
  find last bops_arh-fin-doc-schet-tax-nal where bops_arh-fin-doc-schet-tax-nal.host-code        = parhost-code          and
                                                 bops_arh-fin-doc-schet-tax-nal.cli-type         = parpayer-type         and
                                                 bops_arh-fin-doc-schet-tax-nal.cli-code         = parpayer-code         and
                                                 bops_arh-fin-doc-schet-tax-nal.fin-code-acc     = parpayer-fin-code-acc and
                                                 bops_arh-fin-doc-schet-tax-nal.curr-code        = parcurr-code          and
                                                 bops_arh-fin-doc-schet-tax-nal.fin-ext-doc-type = parfin-ext-doc-type   and
                                                 bops_arh-fin-doc-schet-tax-nal.calc-curr-code   = parcurr-code          and
                                                 bops_arh-fin-doc-schet-tax-nal.vat-pc           = parvat-pc             and
                                                 bops_arh-fin-doc-schet-tax-nal.slt-pc           = parslt-pc             and
                                                 bops_arh-fin-doc-schet-tax-nal.with-vat         = parwith-vat           and
                                                 bops_arh-fin-doc-schet-tax-nal.with-slt         = parwith-slt           and
                                                 bops_arh-fin-doc-schet-tax-nal.sum-type         = parsum-type           and
                                                 bops_arh-fin-doc-schet-tax-nal.fact-order       < parfact-order         use-index pi no-error.
  create bfps_arh-fin-doc-schet-tax-nal.
  assign
    bfps_arh-fin-doc-schet-tax-nal.host-code        = parhost-code
    bfps_arh-fin-doc-schet-tax-nal.cli-type         = parpayer-type
    bfps_arh-fin-doc-schet-tax-nal.cli-code         = parpayer-code
    bfps_arh-fin-doc-schet-tax-nal.fin-code-acc     = parpayer-fin-code-acc
    bfps_arh-fin-doc-schet-tax-nal.curr-code        = parcurr-code
    bfps_arh-fin-doc-schet-tax-nal.fin-ext-doc-type = parfin-ext-doc-type
    bfps_arh-fin-doc-schet-tax-nal.calc-curr-code   = parcurr-code
    bfps_arh-fin-doc-schet-tax-nal.vat-pc           = parvat-pc
    bfps_arh-fin-doc-schet-tax-nal.slt-pc           = parslt-pc
    bfps_arh-fin-doc-schet-tax-nal.with-vat         = parwith-vat
    bfps_arh-fin-doc-schet-tax-nal.with-slt         = parwith-slt
    bfps_arh-fin-doc-schet-tax-nal.sum-type         = parsum-type
    bfps_arh-fin-doc-schet-tax-nal.cource-des       = "s":u
    bfps_arh-fin-doc-schet-tax-nal.fact-order       = parfact-order
    bfps_arh-fin-doc-schet-tax-nal.fin-doc-code     = parfin-doc-code
    bfps_arh-fin-doc-schet-tax-nal.fact-date        = parfact-date
    bfps_arh-fin-doc-schet-tax-nal.curr-code        = parcurr-code
    bfps_arh-fin-doc-schet-tax-nal.income           = (if available bops_arh-fin-doc-schet-tax-nal then bops_arh-fin-doc-schet-tax-nal.income      else 0)
    bfps_arh-fin-doc-schet-tax-nal.income-vat       = (if available bops_arh-fin-doc-schet-tax-nal then bops_arh-fin-doc-schet-tax-nal.income-vat  else 0)
    bfps_arh-fin-doc-schet-tax-nal.income-slt       = (if available bops_arh-fin-doc-schet-tax-nal then bops_arh-fin-doc-schet-tax-nal.income-slt  else 0)
    bfps_arh-fin-doc-schet-tax-nal.expense          = (if available bops_arh-fin-doc-schet-tax-nal then bops_arh-fin-doc-schet-tax-nal.expense     else 0) + parsum-doc
    bfps_arh-fin-doc-schet-tax-nal.expense-vat      = (if available bops_arh-fin-doc-schet-tax-nal then bops_arh-fin-doc-schet-tax-nal.expense-vat else 0) + parsum-vat-doc
    bfps_arh-fin-doc-schet-tax-nal.expense-slt      = (if available bops_arh-fin-doc-schet-tax-nal then bops_arh-fin-doc-schet-tax-nal.expense-slt else 0) + parsum-slt-doc
  .
end.
else do:
  find first bfps_arh-fin-doc-schet-tax-nal where bfps_arh-fin-doc-schet-tax-nal.host-code        = parhost-code          and
                                                  bfps_arh-fin-doc-schet-tax-nal.cli-type         = parpayer-type         and
                                                  bfps_arh-fin-doc-schet-tax-nal.cli-code         = parpayer-code         and
                                                  bfps_arh-fin-doc-schet-tax-nal.fin-code-acc     = parpayer-fin-code-acc and
                                                  bfps_arh-fin-doc-schet-tax-nal.curr-code        = parcurr-code          and
                                                  bfps_arh-fin-doc-schet-tax-nal.fin-ext-doc-type = parfin-ext-doc-type   and
                                                  bfps_arh-fin-doc-schet-tax-nal.calc-curr-code   = parcurr-code          and
                                                  bfps_arh-fin-doc-schet-tax-nal.vat-pc           = parvat-pc             and
                                                  bfps_arh-fin-doc-schet-tax-nal.slt-pc           = parslt-pc             and
                                                  bfps_arh-fin-doc-schet-tax-nal.with-vat         = parwith-vat           and
                                                  bfps_arh-fin-doc-schet-tax-nal.with-slt         = parwith-slt           and
                                                  bfps_arh-fin-doc-schet-tax-nal.sum-type         = parsum-type           and
                                                  bfps_arh-fin-doc-schet-tax-nal.fact-order       = parfact-order         exclusive-lock.
end.
for each rbfps_arh-fin-doc-schet-tax-nal where rbfps_arh-fin-doc-schet-tax-nal.host-code        = bfps_arh-fin-doc-schet-tax-nal.host-code        and
                                               rbfps_arh-fin-doc-schet-tax-nal.cli-type         = parpayer-type                                   and
                                               rbfps_arh-fin-doc-schet-tax-nal.cli-code         = parpayer-code                                   and
                                               rbfps_arh-fin-doc-schet-tax-nal.fin-code-acc     = bfps_arh-fin-doc-schet-tax-nal.fin-code-acc     and
                                               rbfps_arh-fin-doc-schet-tax-nal.curr-code        = bfps_arh-fin-doc-schet-tax-nal.curr-code        and
                                               rbfps_arh-fin-doc-schet-tax-nal.fin-ext-doc-type = bfps_arh-fin-doc-schet-tax-nal.fin-ext-doc-type and
                                               rbfps_arh-fin-doc-schet-tax-nal.calc-curr-code   = bfps_arh-fin-doc-schet-tax-nal.calc-curr-code   and
                                               rbfps_arh-fin-doc-schet-tax-nal.vat-pc           = bfps_arh-fin-doc-schet-tax-nal.vat-pc           and
                                               rbfps_arh-fin-doc-schet-tax-nal.slt-pc           = bfps_arh-fin-doc-schet-tax-nal.slt-pc           and
                                               rbfps_arh-fin-doc-schet-tax-nal.with-vat         = bfps_arh-fin-doc-schet-tax-nal.with-vat         and
                                               rbfps_arh-fin-doc-schet-tax-nal.with-slt         = bfps_arh-fin-doc-schet-tax-nal.with-slt         and
                                               rbfps_arh-fin-doc-schet-tax-nal.sum-type         = bfps_arh-fin-doc-schet-tax-nal.sum-type         and
                                               rbfps_arh-fin-doc-schet-tax-nal.fact-order       > bfps_arh-fin-doc-schet-tax-nal.fact-order       use-index pi exclusive-lock on error undo, return error return-value :
   assign
     rbfps_arh-fin-doc-schet-tax-nal.expense     = rbfps_arh-fin-doc-schet-tax-nal.expense     + parsum-doc
     rbfps_arh-fin-doc-schet-tax-nal.expense-vat = rbfps_arh-fin-doc-schet-tax-nal.expense-vat + parsum-vat-doc
     rbfps_arh-fin-doc-schet-tax-nal.expense-slt = rbfps_arh-fin-doc-schet-tax-nal.expense-slt + parsum-slt-doc
   .
end.
if parmode = "close":u then do:
  find last bors_arh-fin-doc-schet-tax-nal where bors_arh-fin-doc-schet-tax-nal.host-code         = parhost-code             and
                                                 bors_arh-fin-doc-schet-tax-nal.cli-type          = parreceiver-type         and
                                                 bors_arh-fin-doc-schet-tax-nal.cli-code          = parreceiver-code         and
                                                 bors_arh-fin-doc-schet-tax-nal.fin-code-acc      = parreceiver-fin-code-acc and
                                                 bors_arh-fin-doc-schet-tax-nal.curr-code         = parcurr-code             and
                                                 bors_arh-fin-doc-schet-tax-nal.fin-ext-doc-type  = parfin-ext-doc-type      and
                                                 bors_arh-fin-doc-schet-tax-nal.calc-curr-code    = parcurr-code             and
                                                 bors_arh-fin-doc-schet-tax-nal.vat-pc            = parvat-pc                and
                                                 bors_arh-fin-doc-schet-tax-nal.slt-pc            = parslt-pc                and
                                                 bors_arh-fin-doc-schet-tax-nal.with-vat          = parwith-vat              and
                                                 bors_arh-fin-doc-schet-tax-nal.with-slt          = parwith-slt              and
                                                 bors_arh-fin-doc-schet-tax-nal.sum-type          = parsum-type              and
                                                 bors_arh-fin-doc-schet-tax-nal.fact-order        < parfact-order            use-index pi no-error.
  create bfrs_arh-fin-doc-schet-tax-nal.
  assign
    bfrs_arh-fin-doc-schet-tax-nal.host-code        = parhost-code
    bfrs_arh-fin-doc-schet-tax-nal.cli-type         = parreceiver-type
    bfrs_arh-fin-doc-schet-tax-nal.cli-code         = parreceiver-code
    bfrs_arh-fin-doc-schet-tax-nal.fin-code-acc     = parreceiver-fin-code-acc
    bfrs_arh-fin-doc-schet-tax-nal.curr-code        = parcurr-code
    bfrs_arh-fin-doc-schet-tax-nal.fin-ext-doc-type = parfin-ext-doc-type
    bfrs_arh-fin-doc-schet-tax-nal.calc-curr-code   = parcurr-code
    bfrs_arh-fin-doc-schet-tax-nal.vat-pc           = parvat-pc
    bfrs_arh-fin-doc-schet-tax-nal.slt-pc           = parslt-pc
    bfrs_arh-fin-doc-schet-tax-nal.with-vat         = parwith-vat
    bfrs_arh-fin-doc-schet-tax-nal.with-slt         = parwith-slt
    bfrs_arh-fin-doc-schet-tax-nal.sum-type         = parsum-type
    bfrs_arh-fin-doc-schet-tax-nal.cource-des       = "s":u
    bfrs_arh-fin-doc-schet-tax-nal.fact-order       = parfact-order
    bfrs_arh-fin-doc-schet-tax-nal.fin-doc-code     = parfin-doc-code
    bfrs_arh-fin-doc-schet-tax-nal.fact-date        = parfact-date
    bfrs_arh-fin-doc-schet-tax-nal.curr-code        = parcurr-code
  .
  assign
    bfrs_arh-fin-doc-schet-tax-nal.expense          = (if available bors_arh-fin-doc-schet-tax-nal then bors_arh-fin-doc-schet-tax-nal.expense     else 0)
    bfrs_arh-fin-doc-schet-tax-nal.expense-vat      = (if available bors_arh-fin-doc-schet-tax-nal then bors_arh-fin-doc-schet-tax-nal.expense-vat else 0)
    bfrs_arh-fin-doc-schet-tax-nal.expense-slt      = (if available bors_arh-fin-doc-schet-tax-nal then bors_arh-fin-doc-schet-tax-nal.expense-slt else 0)
    bfrs_arh-fin-doc-schet-tax-nal.income           = (if available bors_arh-fin-doc-schet-tax-nal then bors_arh-fin-doc-schet-tax-nal.income      else 0) + parsum-doc
    bfrs_arh-fin-doc-schet-tax-nal.income-vat       = (if available bors_arh-fin-doc-schet-tax-nal then bors_arh-fin-doc-schet-tax-nal.income-vat  else 0) + parsum-vat-doc
    bfrs_arh-fin-doc-schet-tax-nal.income-slt       = (if available bors_arh-fin-doc-schet-tax-nal then bors_arh-fin-doc-schet-tax-nal.income-slt  else 0) + parsum-slt-doc
  .
end.
else do:
  find first bfrs_arh-fin-doc-schet-tax-nal where bfrs_arh-fin-doc-schet-tax-nal.host-code         = parhost-code             and
                                                  bfrs_arh-fin-doc-schet-tax-nal.cli-type          = parreceiver-type         and
                                                  bfrs_arh-fin-doc-schet-tax-nal.cli-code          = parreceiver-code         and
                                                  bfrs_arh-fin-doc-schet-tax-nal.fin-code-acc      = parreceiver-fin-code-acc and
                                                  bfrs_arh-fin-doc-schet-tax-nal.curr-code         = parcurr-code             and
                                                  bfrs_arh-fin-doc-schet-tax-nal.fin-ext-doc-type  = parfin-ext-doc-type      and
                                                  bfrs_arh-fin-doc-schet-tax-nal.calc-curr-code    = parcurr-code             and
                                                  bfrs_arh-fin-doc-schet-tax-nal.vat-pc            = parvat-pc                and
                                                  bfrs_arh-fin-doc-schet-tax-nal.slt-pc            = parslt-pc                and
                                                  bfrs_arh-fin-doc-schet-tax-nal.with-vat          = parwith-vat              and
                                                  bfrs_arh-fin-doc-schet-tax-nal.with-slt          = parwith-slt              and
                                                  bfrs_arh-fin-doc-schet-tax-nal.sum-type          = parsum-type              and
                                                  bfrs_arh-fin-doc-schet-tax-nal.fact-order        = parfact-order            exclusive-lock.
end.
for each rbfrs_arh-fin-doc-schet-tax-nal where rbfrs_arh-fin-doc-schet-tax-nal.host-code        = bfrs_arh-fin-doc-schet-tax-nal.host-code        and
                                               rbfrs_arh-fin-doc-schet-tax-nal.cli-type         = parreceiver-type                                and
                                               rbfrs_arh-fin-doc-schet-tax-nal.cli-code         = parreceiver-code                                and
                                               rbfrs_arh-fin-doc-schet-tax-nal.fin-code-acc     = bfrs_arh-fin-doc-schet-tax-nal.fin-code-acc     and
                                               rbfrs_arh-fin-doc-schet-tax-nal.curr-code        = bfrs_arh-fin-doc-schet-tax-nal.curr-code        and
                                               rbfrs_arh-fin-doc-schet-tax-nal.fin-ext-doc-type = bfrs_arh-fin-doc-schet-tax-nal.fin-ext-doc-type and
                                               rbfrs_arh-fin-doc-schet-tax-nal.calc-curr-code   = bfrs_arh-fin-doc-schet-tax-nal.calc-curr-code   and
                                               rbfrs_arh-fin-doc-schet-tax-nal.vat-pc           = bfrs_arh-fin-doc-schet-tax-nal.vat-pc           and
                                               rbfrs_arh-fin-doc-schet-tax-nal.slt-pc           = bfrs_arh-fin-doc-schet-tax-nal.slt-pc           and
                                               rbfrs_arh-fin-doc-schet-tax-nal.with-vat         = bfrs_arh-fin-doc-schet-tax-nal.with-vat         and
                                               rbfrs_arh-fin-doc-schet-tax-nal.with-slt         = bfrs_arh-fin-doc-schet-tax-nal.with-slt         and
                                               rbfrs_arh-fin-doc-schet-tax-nal.sum-type         = bfrs_arh-fin-doc-schet-tax-nal.sum-type         and
                                               rbfrs_arh-fin-doc-schet-tax-nal.fact-order       > bfrs_arh-fin-doc-schet-tax-nal.fact-order       use-index pi exclusive-lock on error undo, return error return-value:
  assign
    rbfrs_arh-fin-doc-schet-tax-nal.income     = rbfrs_arh-fin-doc-schet-tax-nal.income     + parsum-doc
    rbfrs_arh-fin-doc-schet-tax-nal.income-vat = rbfrs_arh-fin-doc-schet-tax-nal.income-vat + parsum-vat-doc
    rbfrs_arh-fin-doc-schet-tax-nal.income-slt = rbfrs_arh-fin-doc-schet-tax-nal.income-slt + parsum-slt-doc
  .
end.
if parmode = "delete":u then do:
  delete bfps_arh-fin-doc-schet-tax-nal.
  delete bfrs_arh-fin-doc-schet-tax-nal.
end.
if parcurr-code <> 0 then do:
  if parmode = "close":u then do:
    find last bopr_arh-fin-doc-schet-tax-nal where bopr_arh-fin-doc-schet-tax-nal.host-code        = parhost-code          and
                                                   bopr_arh-fin-doc-schet-tax-nal.cli-type         = parpayer-type         and
                                                   bopr_arh-fin-doc-schet-tax-nal.cli-code         = parpayer-code         and
                                                   bopr_arh-fin-doc-schet-tax-nal.fin-code-acc     = parpayer-fin-code-acc and
                                                   bopr_arh-fin-doc-schet-tax-nal.curr-code        = parcurr-code          and
                                                   bopr_arh-fin-doc-schet-tax-nal.fin-ext-doc-type = parfin-ext-doc-type   and
                                                   bopr_arh-fin-doc-schet-tax-nal.calc-curr-code   = 0                     and
                                                   bopr_arh-fin-doc-schet-tax-nal.vat-pc           = parvat-pc             and
                                                   bopr_arh-fin-doc-schet-tax-nal.slt-pc           = parslt-pc             and
                                                   bopr_arh-fin-doc-schet-tax-nal.with-vat         = parwith-vat           and
                                                   bopr_arh-fin-doc-schet-tax-nal.with-slt         = parwith-slt           and
                                                   bopr_arh-fin-doc-schet-tax-nal.sum-type         = parsum-type           and
                                                   bopr_arh-fin-doc-schet-tax-nal.fact-order       < parfact-order         use-index pi no-error.
    create bfpr_arh-fin-doc-schet-tax-nal.
    assign
      bfpr_arh-fin-doc-schet-tax-nal.host-code        = parhost-code
      bfpr_arh-fin-doc-schet-tax-nal.cli-type         = parpayer-type
      bfpr_arh-fin-doc-schet-tax-nal.cli-code         = parpayer-code
      bfpr_arh-fin-doc-schet-tax-nal.fin-code-acc     = parpayer-fin-code-acc
      bfpr_arh-fin-doc-schet-tax-nal.curr-code        = parcurr-code
      bfpr_arh-fin-doc-schet-tax-nal.fin-ext-doc-type = parfin-ext-doc-type
      bfpr_arh-fin-doc-schet-tax-nal.calc-curr-code   = 0
      bfpr_arh-fin-doc-schet-tax-nal.vat-pc           = parvat-pc
      bfpr_arh-fin-doc-schet-tax-nal.slt-pc           = parslt-pc
      bfpr_arh-fin-doc-schet-tax-nal.with-vat         = parwith-vat
      bfpr_arh-fin-doc-schet-tax-nal.with-slt         = parwith-slt
      bfpr_arh-fin-doc-schet-tax-nal.sum-type         = parsum-type
      bfpr_arh-fin-doc-schet-tax-nal.cource-des       = "r":u
      bfpr_arh-fin-doc-schet-tax-nal.fact-order       = parfact-order
      bfpr_arh-fin-doc-schet-tax-nal.fin-doc-code     = parfin-doc-code
      bfpr_arh-fin-doc-schet-tax-nal.fact-date        = parfact-date
      bfpr_arh-fin-doc-schet-tax-nal.curr-code        = parcurr-code
      bfpr_arh-fin-doc-schet-tax-nal.income           = (if available bopr_arh-fin-doc-schet-tax-nal then bopr_arh-fin-doc-schet-tax-nal.income      else 0)
      bfpr_arh-fin-doc-schet-tax-nal.income-vat       = (if available bopr_arh-fin-doc-schet-tax-nal then bopr_arh-fin-doc-schet-tax-nal.income-vat  else 0)
      bfpr_arh-fin-doc-schet-tax-nal.income-slt       = (if available bopr_arh-fin-doc-schet-tax-nal then bopr_arh-fin-doc-schet-tax-nal.income-slt  else 0)
      bfpr_arh-fin-doc-schet-tax-nal.expense          = (if available bopr_arh-fin-doc-schet-tax-nal then bopr_arh-fin-doc-schet-tax-nal.expense     else 0) + parsum-rubl
      bfpr_arh-fin-doc-schet-tax-nal.expense-vat      = (if available bopr_arh-fin-doc-schet-tax-nal then bopr_arh-fin-doc-schet-tax-nal.expense-vat else 0) + parsum-vat-rubl
      bfpr_arh-fin-doc-schet-tax-nal.expense-slt      = (if available bopr_arh-fin-doc-schet-tax-nal then bopr_arh-fin-doc-schet-tax-nal.expense-slt else 0) + parsum-slt-rubl
    .
  end.
  else do:
    find first bfpr_arh-fin-doc-schet-tax-nal where bfpr_arh-fin-doc-schet-tax-nal.host-code        = parhost-code          and
                                                    bfpr_arh-fin-doc-schet-tax-nal.cli-type         = parpayer-type         and
                                                    bfpr_arh-fin-doc-schet-tax-nal.cli-code         = parpayer-code         and
                                                    bfpr_arh-fin-doc-schet-tax-nal.fin-code-acc     = parpayer-fin-code-acc and
                                                    bfpr_arh-fin-doc-schet-tax-nal.curr-code        = parcurr-code          and
                                                    bfpr_arh-fin-doc-schet-tax-nal.fin-ext-doc-type = parfin-ext-doc-type   and
                                                    bfpr_arh-fin-doc-schet-tax-nal.calc-curr-code   = 0                     and
                                                    bfpr_arh-fin-doc-schet-tax-nal.vat-pc           = parvat-pc             and
                                                    bfpr_arh-fin-doc-schet-tax-nal.slt-pc           = parslt-pc             and
                                                    bfpr_arh-fin-doc-schet-tax-nal.with-vat         = parwith-vat           and
                                                    bfpr_arh-fin-doc-schet-tax-nal.with-slt         = parwith-slt           and
                                                    bfpr_arh-fin-doc-schet-tax-nal.sum-type         = parsum-type           and
                                                    bfpr_arh-fin-doc-schet-tax-nal.fact-order       = parfact-order         exclusive-lock.
  end.
  for each rbfpr_arh-fin-doc-schet-tax-nal where rbfpr_arh-fin-doc-schet-tax-nal.host-code        = bfpr_arh-fin-doc-schet-tax-nal.host-code        and
                                                 rbfpr_arh-fin-doc-schet-tax-nal.cli-type         = parpayer-type                                   and
                                                 rbfpr_arh-fin-doc-schet-tax-nal.cli-code         = parpayer-code                                   and
                                                 rbfpr_arh-fin-doc-schet-tax-nal.fin-code-acc     = bfpr_arh-fin-doc-schet-tax-nal.fin-code-acc     and
                                                 rbfpr_arh-fin-doc-schet-tax-nal.curr-code        = bfpr_arh-fin-doc-schet-tax-nal.curr-code        and
                                                 rbfpr_arh-fin-doc-schet-tax-nal.fin-ext-doc-type = bfpr_arh-fin-doc-schet-tax-nal.fin-ext-doc-type and
                                                 rbfpr_arh-fin-doc-schet-tax-nal.calc-curr-code   = bfpr_arh-fin-doc-schet-tax-nal.calc-curr-code   and
                                                 rbfpr_arh-fin-doc-schet-tax-nal.vat-pc           = bfpr_arh-fin-doc-schet-tax-nal.vat-pc           and
                                                 rbfpr_arh-fin-doc-schet-tax-nal.slt-pc           = bfpr_arh-fin-doc-schet-tax-nal.slt-pc           and
                                                 rbfpr_arh-fin-doc-schet-tax-nal.with-vat         = bfpr_arh-fin-doc-schet-tax-nal.with-vat         and
                                                 rbfpr_arh-fin-doc-schet-tax-nal.with-slt         = bfpr_arh-fin-doc-schet-tax-nal.with-slt         and
                                                 rbfpr_arh-fin-doc-schet-tax-nal.sum-type         = bfpr_arh-fin-doc-schet-tax-nal.sum-type         and
                                                 rbfpr_arh-fin-doc-schet-tax-nal.fact-order       > bfpr_arh-fin-doc-schet-tax-nal.fact-order       use-index pi exclusive-lock on error undo, return error return-value :
    assign
      rbfpr_arh-fin-doc-schet-tax-nal.expense     = rbfpr_arh-fin-doc-schet-tax-nal.expense     + parsum-rubl
      rbfpr_arh-fin-doc-schet-tax-nal.expense-vat = rbfpr_arh-fin-doc-schet-tax-nal.expense-vat + parsum-vat-rubl
      rbfpr_arh-fin-doc-schet-tax-nal.expense-slt = rbfpr_arh-fin-doc-schet-tax-nal.expense-slt + parsum-slt-rubl
    .
  end.
  if parmode = "close":u then do:
    find last borr_arh-fin-doc-schet-tax-nal where borr_arh-fin-doc-schet-tax-nal.host-code        = parhost-code             and
                                                   borr_arh-fin-doc-schet-tax-nal.cli-type         = parreceiver-type         and
                                                   borr_arh-fin-doc-schet-tax-nal.cli-code         = parreceiver-code         and
                                                   borr_arh-fin-doc-schet-tax-nal.fin-code-acc     = parreceiver-fin-code-acc and
                                                   borr_arh-fin-doc-schet-tax-nal.curr-code        = parcurr-code             and
                                                   borr_arh-fin-doc-schet-tax-nal.fin-ext-doc-type = parfin-ext-doc-type      and
                                                   borr_arh-fin-doc-schet-tax-nal.calc-curr-code   = 0                        and
                                                   borr_arh-fin-doc-schet-tax-nal.vat-pc           = parvat-pc                and
                                                   borr_arh-fin-doc-schet-tax-nal.slt-pc           = parslt-pc                and
                                                   borr_arh-fin-doc-schet-tax-nal.with-vat         = parwith-vat              and
                                                   borr_arh-fin-doc-schet-tax-nal.with-slt         = parwith-slt              and
                                                   borr_arh-fin-doc-schet-tax-nal.sum-type         = parsum-type              and
                                                   borr_arh-fin-doc-schet-tax-nal.fact-order       < parfact-order            use-index pi no-error.
    create bfrr_arh-fin-doc-schet-tax-nal.
    assign
      bfrr_arh-fin-doc-schet-tax-nal.host-code        = parhost-code
      bfrr_arh-fin-doc-schet-tax-nal.cli-type         = parreceiver-type
      bfrr_arh-fin-doc-schet-tax-nal.cli-code         = parreceiver-code
      bfrr_arh-fin-doc-schet-tax-nal.fin-code-acc     = parreceiver-fin-code-acc
      bfrr_arh-fin-doc-schet-tax-nal.curr-code        = parcurr-code
      bfrr_arh-fin-doc-schet-tax-nal.fin-ext-doc-type = parfin-ext-doc-type
      bfrr_arh-fin-doc-schet-tax-nal.calc-curr-code   = 0
      bfrr_arh-fin-doc-schet-tax-nal.vat-pc           = parvat-pc
      bfrr_arh-fin-doc-schet-tax-nal.slt-pc           = parslt-pc
      bfrr_arh-fin-doc-schet-tax-nal.with-vat         = parwith-vat
      bfrr_arh-fin-doc-schet-tax-nal.with-slt         = parwith-slt
      bfrr_arh-fin-doc-schet-tax-nal.sum-type         = parsum-type
      bfrr_arh-fin-doc-schet-tax-nal.cource-des       = "r":u
      bfrr_arh-fin-doc-schet-tax-nal.fact-order       = parfact-order
      bfrr_arh-fin-doc-schet-tax-nal.fin-doc-code     = parfin-doc-code
      bfrr_arh-fin-doc-schet-tax-nal.fact-date        = parfact-date
      bfrr_arh-fin-doc-schet-tax-nal.curr-code        = parcurr-code
    .
    assign
      bfrr_arh-fin-doc-schet-tax-nal.expense          = (if available borr_arh-fin-doc-schet-tax-nal then borr_arh-fin-doc-schet-tax-nal.expense     else 0)
      bfrr_arh-fin-doc-schet-tax-nal.expense-vat      = (if available borr_arh-fin-doc-schet-tax-nal then borr_arh-fin-doc-schet-tax-nal.expense-vat else 0)
      bfrr_arh-fin-doc-schet-tax-nal.expense-slt      = (if available borr_arh-fin-doc-schet-tax-nal then borr_arh-fin-doc-schet-tax-nal.expense-slt else 0)
      bfrr_arh-fin-doc-schet-tax-nal.income           = (if available borr_arh-fin-doc-schet-tax-nal then borr_arh-fin-doc-schet-tax-nal.income      else 0) + parsum-rubl
      bfrr_arh-fin-doc-schet-tax-nal.income-vat       = (if available borr_arh-fin-doc-schet-tax-nal then borr_arh-fin-doc-schet-tax-nal.income-vat  else 0) + parsum-vat-rubl
      bfrr_arh-fin-doc-schet-tax-nal.income-slt       = (if available borr_arh-fin-doc-schet-tax-nal then borr_arh-fin-doc-schet-tax-nal.income-slt  else 0) + parsum-slt-rubl
    .
  end.
  else do:
    find first bfrr_arh-fin-doc-schet-tax-nal where bfrr_arh-fin-doc-schet-tax-nal.host-code        = parhost-code             and
                                                    bfrr_arh-fin-doc-schet-tax-nal.cli-type         = parreceiver-type         and
                                                    bfrr_arh-fin-doc-schet-tax-nal.cli-code         = parreceiver-code         and
                                                    bfrr_arh-fin-doc-schet-tax-nal.fin-code-acc     = parreceiver-fin-code-acc and
                                                    bfrr_arh-fin-doc-schet-tax-nal.curr-code        = parcurr-code             and
                                                    bfrr_arh-fin-doc-schet-tax-nal.fin-ext-doc-type = parfin-ext-doc-type      and
                                                    bfrr_arh-fin-doc-schet-tax-nal.calc-curr-code   = 0                        and
                                                    bfrr_arh-fin-doc-schet-tax-nal.vat-pc           = parvat-pc                and
                                                    bfrr_arh-fin-doc-schet-tax-nal.slt-pc           = parslt-pc                and
                                                    bfrr_arh-fin-doc-schet-tax-nal.with-vat         = parwith-vat              and
                                                    bfrr_arh-fin-doc-schet-tax-nal.with-slt         = parwith-slt              and
                                                    bfrr_arh-fin-doc-schet-tax-nal.sum-type         = parsum-type              and
                                                    bfrr_arh-fin-doc-schet-tax-nal.fact-order       = parfact-order            exclusive-lock.
  end.
  for each rbfrr_arh-fin-doc-schet-tax-nal where rbfrr_arh-fin-doc-schet-tax-nal.host-code        = bfrr_arh-fin-doc-schet-tax-nal.host-code        and
                                                 rbfrr_arh-fin-doc-schet-tax-nal.cli-type         = parreceiver-type                                and
                                                 rbfrr_arh-fin-doc-schet-tax-nal.cli-code         = parreceiver-code                                and
                                                 rbfrr_arh-fin-doc-schet-tax-nal.fin-code-acc     = bfrr_arh-fin-doc-schet-tax-nal.fin-code-acc     and
                                                 rbfrr_arh-fin-doc-schet-tax-nal.curr-code        = bfrr_arh-fin-doc-schet-tax-nal.curr-code        and
                                                 rbfrr_arh-fin-doc-schet-tax-nal.fin-ext-doc-type = bfrr_arh-fin-doc-schet-tax-nal.fin-ext-doc-type and
                                                 rbfrr_arh-fin-doc-schet-tax-nal.calc-curr-code   = bfrr_arh-fin-doc-schet-tax-nal.calc-curr-code   and
                                                 rbfrr_arh-fin-doc-schet-tax-nal.vat-pc           = bfrr_arh-fin-doc-schet-tax-nal.vat-pc           and
                                                 rbfrr_arh-fin-doc-schet-tax-nal.slt-pc           = bfrr_arh-fin-doc-schet-tax-nal.slt-pc           and
                                                 rbfrr_arh-fin-doc-schet-tax-nal.with-vat         = bfrr_arh-fin-doc-schet-tax-nal.with-vat         and
                                                 rbfrr_arh-fin-doc-schet-tax-nal.with-slt         = bfrr_arh-fin-doc-schet-tax-nal.with-slt         and
                                                 rbfrr_arh-fin-doc-schet-tax-nal.sum-type         = bfrr_arh-fin-doc-schet-tax-nal.sum-type         and
                                                 rbfrr_arh-fin-doc-schet-tax-nal.fact-order       > bfrr_arh-fin-doc-schet-tax-nal.fact-order       use-index pi exclusive-lock on error undo, return error return-value:
    assign
      rbfrr_arh-fin-doc-schet-tax-nal.income     = rbfrr_arh-fin-doc-schet-tax-nal.income     + parsum-rubl
      rbfrr_arh-fin-doc-schet-tax-nal.income-vat = rbfrr_arh-fin-doc-schet-tax-nal.income-vat + parsum-vat-rubl
      rbfrr_arh-fin-doc-schet-tax-nal.income-slt = rbfrr_arh-fin-doc-schet-tax-nal.income-slt + parsum-slt-rubl
    .
  end.
  if parmode = "delete":u then do:
    delete bfpr_arh-fin-doc-schet-tax-nal.
    delete bfrr_arh-fin-doc-schet-tax-nal.
  end.
end.
if parbase-code <> parcurr-code and
   parbase-code <> 0            then do:
  if parmode = "close":u then do:
    find last bopb_arh-fin-doc-schet-tax-nal where bopb_arh-fin-doc-schet-tax-nal.host-code        = parhost-code          and
                                                   bopb_arh-fin-doc-schet-tax-nal.cli-type         = parpayer-type         and
                                                   bopb_arh-fin-doc-schet-tax-nal.cli-code         = parpayer-code         and
                                                   bopb_arh-fin-doc-schet-tax-nal.fin-code-acc     = parpayer-fin-code-acc and
                                                   bopb_arh-fin-doc-schet-tax-nal.curr-code        = parcurr-code          and
                                                   bopb_arh-fin-doc-schet-tax-nal.fin-ext-doc-type = parfin-ext-doc-type   and
                                                   bopb_arh-fin-doc-schet-tax-nal.calc-curr-code   = parbase-code          and
                                                   bopb_arh-fin-doc-schet-tax-nal.vat-pc           = parvat-pc             and
                                                   bopb_arh-fin-doc-schet-tax-nal.slt-pc           = parslt-pc             and
                                                   bopb_arh-fin-doc-schet-tax-nal.with-vat         = parwith-vat           and
                                                   bopb_arh-fin-doc-schet-tax-nal.with-slt         = parwith-slt           and
                                                   bopb_arh-fin-doc-schet-tax-nal.sum-type         = parsum-type           and
                                                   bopb_arh-fin-doc-schet-tax-nal.fact-order       < parfact-order         use-index pi no-error.
    create bfpb_arh-fin-doc-schet-tax-nal.
    assign
      bfpb_arh-fin-doc-schet-tax-nal.host-code        = parhost-code
      bfpb_arh-fin-doc-schet-tax-nal.cli-type         = parpayer-type
      bfpb_arh-fin-doc-schet-tax-nal.cli-code         = parpayer-code
      bfpb_arh-fin-doc-schet-tax-nal.fin-code-acc     = parpayer-fin-code-acc
      bfpb_arh-fin-doc-schet-tax-nal.curr-code        = parcurr-code
      bfpb_arh-fin-doc-schet-tax-nal.fin-ext-doc-type = parfin-ext-doc-type
      bfpb_arh-fin-doc-schet-tax-nal.calc-curr-code   = parbase-code
      bfpb_arh-fin-doc-schet-tax-nal.vat-pc           = parvat-pc
      bfpb_arh-fin-doc-schet-tax-nal.slt-pc           = parslt-pc
      bfpb_arh-fin-doc-schet-tax-nal.with-vat         = parwith-vat
      bfpb_arh-fin-doc-schet-tax-nal.with-slt         = parwith-slt
      bfpb_arh-fin-doc-schet-tax-nal.sum-type         = parsum-type
      bfpb_arh-fin-doc-schet-tax-nal.cource-des       = "b":u
      bfpb_arh-fin-doc-schet-tax-nal.fact-order       = parfact-order
      bfpb_arh-fin-doc-schet-tax-nal.fin-doc-code     = parfin-doc-code
      bfpb_arh-fin-doc-schet-tax-nal.fact-date        = parfact-date
      bfpb_arh-fin-doc-schet-tax-nal.curr-code        = parcurr-code
      bfpb_arh-fin-doc-schet-tax-nal.income           = (if available bopb_arh-fin-doc-schet-tax-nal then bopb_arh-fin-doc-schet-tax-nal.income      else 0)
      bfpb_arh-fin-doc-schet-tax-nal.income-vat       = (if available bopb_arh-fin-doc-schet-tax-nal then bopb_arh-fin-doc-schet-tax-nal.income-vat  else 0)
      bfpb_arh-fin-doc-schet-tax-nal.income-slt       = (if available bopb_arh-fin-doc-schet-tax-nal then bopb_arh-fin-doc-schet-tax-nal.income-slt  else 0)
      bfpb_arh-fin-doc-schet-tax-nal.expense          = (if available bopb_arh-fin-doc-schet-tax-nal then bopb_arh-fin-doc-schet-tax-nal.expense     else 0) + parsum-base
      bfpb_arh-fin-doc-schet-tax-nal.expense-vat      = (if available bopb_arh-fin-doc-schet-tax-nal then bopb_arh-fin-doc-schet-tax-nal.expense-vat else 0) + parsum-vat-base
      bfpb_arh-fin-doc-schet-tax-nal.expense-slt      = (if available bopb_arh-fin-doc-schet-tax-nal then bopb_arh-fin-doc-schet-tax-nal.expense-slt else 0) + parsum-slt-base
    .
  end.
  else do:
    find first bfpb_arh-fin-doc-schet-tax-nal where bfpb_arh-fin-doc-schet-tax-nal.host-code        = parhost-code          and
                                                    bfpb_arh-fin-doc-schet-tax-nal.cli-type         = parpayer-type         and
                                                    bfpb_arh-fin-doc-schet-tax-nal.cli-code         = parpayer-code         and
                                                    bfpb_arh-fin-doc-schet-tax-nal.fin-code-acc     = parpayer-fin-code-acc and
                                                    bfpb_arh-fin-doc-schet-tax-nal.curr-code        = parcurr-code          and
                                                    bfpb_arh-fin-doc-schet-tax-nal.fin-ext-doc-type = parfin-ext-doc-type   and
                                                    bfpb_arh-fin-doc-schet-tax-nal.calc-curr-code   = parbase-code          and
                                                    bfpb_arh-fin-doc-schet-tax-nal.vat-pc           = parvat-pc             and
                                                    bfpb_arh-fin-doc-schet-tax-nal.slt-pc           = parslt-pc             and
                                                    bfpb_arh-fin-doc-schet-tax-nal.with-vat         = parwith-vat           and
                                                    bfpb_arh-fin-doc-schet-tax-nal.with-slt         = parwith-slt           and
                                                    bfpb_arh-fin-doc-schet-tax-nal.sum-type         = parsum-type           and
                                                    bfpb_arh-fin-doc-schet-tax-nal.fact-order       = parfact-order         exclusive-lock.
  end.
  for each rbfpb_arh-fin-doc-schet-tax-nal where rbfpb_arh-fin-doc-schet-tax-nal.host-code        = bfpb_arh-fin-doc-schet-tax-nal.host-code        and
                                                 rbfpb_arh-fin-doc-schet-tax-nal.cli-type         = parpayer-type                                   and
                                                 rbfpb_arh-fin-doc-schet-tax-nal.cli-code         = parpayer-code                                   and
                                                 rbfpb_arh-fin-doc-schet-tax-nal.fin-code-acc     = bfpb_arh-fin-doc-schet-tax-nal.fin-code-acc     and
                                                 rbfpb_arh-fin-doc-schet-tax-nal.curr-code        = bfpb_arh-fin-doc-schet-tax-nal.curr-code        and
                                                 rbfpb_arh-fin-doc-schet-tax-nal.fin-ext-doc-type = bfpb_arh-fin-doc-schet-tax-nal.fin-ext-doc-type and
                                                 rbfpb_arh-fin-doc-schet-tax-nal.calc-curr-code   = bfpb_arh-fin-doc-schet-tax-nal.calc-curr-code   and
                                                 rbfpb_arh-fin-doc-schet-tax-nal.vat-pc           = bfpb_arh-fin-doc-schet-tax-nal.vat-pc           and
                                                 rbfpb_arh-fin-doc-schet-tax-nal.slt-pc           = bfpb_arh-fin-doc-schet-tax-nal.slt-pc           and
                                                 rbfpb_arh-fin-doc-schet-tax-nal.with-vat         = bfpb_arh-fin-doc-schet-tax-nal.with-vat         and
                                                 rbfpb_arh-fin-doc-schet-tax-nal.with-slt         = bfpb_arh-fin-doc-schet-tax-nal.with-slt         and
                                                 rbfpb_arh-fin-doc-schet-tax-nal.sum-type         = bfpb_arh-fin-doc-schet-tax-nal.sum-type         and
                                                 rbfpb_arh-fin-doc-schet-tax-nal.fact-order       > bfpb_arh-fin-doc-schet-tax-nal.fact-order       use-index pi exclusive-lock on error undo, return error return-value :
     assign
       rbfpb_arh-fin-doc-schet-tax-nal.expense     = rbfpb_arh-fin-doc-schet-tax-nal.expense     + parsum-base
       rbfpb_arh-fin-doc-schet-tax-nal.expense-vat = rbfpb_arh-fin-doc-schet-tax-nal.expense-vat + parsum-vat-base
       rbfpb_arh-fin-doc-schet-tax-nal.expense-slt = rbfpb_arh-fin-doc-schet-tax-nal.expense-slt + parsum-slt-base
     .
  end.
  if parmode = "close":u then do:
    find last borb_arh-fin-doc-schet-tax-nal where borb_arh-fin-doc-schet-tax-nal.host-code        = parhost-code             and
                                                   borb_arh-fin-doc-schet-tax-nal.cli-type         = parreceiver-type         and
                                                   borb_arh-fin-doc-schet-tax-nal.cli-code         = parreceiver-code         and
                                                   borb_arh-fin-doc-schet-tax-nal.fin-code-acc     = parreceiver-fin-code-acc and
                                                   borb_arh-fin-doc-schet-tax-nal.curr-code        = parcurr-code             and
                                                   borb_arh-fin-doc-schet-tax-nal.fin-ext-doc-type = parfin-ext-doc-type      and
                                                   borb_arh-fin-doc-schet-tax-nal.calc-curr-code   = parbase-code             and
                                                   borb_arh-fin-doc-schet-tax-nal.vat-pc           = parvat-pc                and
                                                   borb_arh-fin-doc-schet-tax-nal.slt-pc           = parslt-pc                and
                                                   borb_arh-fin-doc-schet-tax-nal.with-vat         = parwith-vat              and
                                                   borb_arh-fin-doc-schet-tax-nal.with-slt         = parwith-slt              and
                                                   borb_arh-fin-doc-schet-tax-nal.sum-type         = parsum-type              and
                                                   borb_arh-fin-doc-schet-tax-nal.fact-order       < parfact-order            use-index pi no-error.
    create bfrb_arh-fin-doc-schet-tax-nal.
    assign
      bfrb_arh-fin-doc-schet-tax-nal.host-code        = parhost-code
      bfrb_arh-fin-doc-schet-tax-nal.cli-type         = parreceiver-type
      bfrb_arh-fin-doc-schet-tax-nal.cli-code         = parreceiver-code
      bfrb_arh-fin-doc-schet-tax-nal.fin-code-acc     = parreceiver-fin-code-acc
      bfrb_arh-fin-doc-schet-tax-nal.curr-code        = parcurr-code
      bfrb_arh-fin-doc-schet-tax-nal.fin-ext-doc-type = parfin-ext-doc-type
      bfrb_arh-fin-doc-schet-tax-nal.calc-curr-code   = parbase-code
      bfrb_arh-fin-doc-schet-tax-nal.vat-pc           = parvat-pc
      bfrb_arh-fin-doc-schet-tax-nal.slt-pc           = parslt-pc
      bfrb_arh-fin-doc-schet-tax-nal.with-vat         = parwith-vat
      bfrb_arh-fin-doc-schet-tax-nal.with-slt         = parwith-slt
      bfrb_arh-fin-doc-schet-tax-nal.sum-type         = parsum-type
      bfrb_arh-fin-doc-schet-tax-nal.cource-des       = "b":u
      bfrb_arh-fin-doc-schet-tax-nal.fact-order       = parfact-order
      bfrb_arh-fin-doc-schet-tax-nal.fin-doc-code     = parfin-doc-code
      bfrb_arh-fin-doc-schet-tax-nal.fact-date        = parfact-date
      bfrb_arh-fin-doc-schet-tax-nal.curr-code        = parcurr-code
    .
    assign
      bfrb_arh-fin-doc-schet-tax-nal.expense          = (if available borb_arh-fin-doc-schet-tax-nal then borb_arh-fin-doc-schet-tax-nal.expense     else 0)
      bfrb_arh-fin-doc-schet-tax-nal.expense-vat      = (if available borb_arh-fin-doc-schet-tax-nal then borb_arh-fin-doc-schet-tax-nal.expense-vat else 0)
      bfrb_arh-fin-doc-schet-tax-nal.expense-slt      = (if available borb_arh-fin-doc-schet-tax-nal then borb_arh-fin-doc-schet-tax-nal.expense-slt else 0)
      bfrb_arh-fin-doc-schet-tax-nal.income           = (if available borb_arh-fin-doc-schet-tax-nal then borb_arh-fin-doc-schet-tax-nal.income      else 0) + parsum-base
      bfrb_arh-fin-doc-schet-tax-nal.income-vat       = (if available borb_arh-fin-doc-schet-tax-nal then borb_arh-fin-doc-schet-tax-nal.income-vat  else 0) + parsum-vat-base
      bfrb_arh-fin-doc-schet-tax-nal.income-slt       = (if available borb_arh-fin-doc-schet-tax-nal then borb_arh-fin-doc-schet-tax-nal.income-slt  else 0) + parsum-slt-base
    .
  end.
  else do:
    find first bfrb_arh-fin-doc-schet-tax-nal where bfrb_arh-fin-doc-schet-tax-nal.host-code        = parhost-code             and
                                                    bfrb_arh-fin-doc-schet-tax-nal.cli-type         = parreceiver-type         and
                                                    bfrb_arh-fin-doc-schet-tax-nal.cli-code         = parreceiver-code         and
                                                    bfrb_arh-fin-doc-schet-tax-nal.fin-code-acc     = parreceiver-fin-code-acc and
                                                    bfrb_arh-fin-doc-schet-tax-nal.curr-code        = parcurr-code             and
                                                    bfrb_arh-fin-doc-schet-tax-nal.fin-ext-doc-type = parfin-ext-doc-type      and
                                                    bfrb_arh-fin-doc-schet-tax-nal.calc-curr-code   = parbase-code             and
                                                    bfrb_arh-fin-doc-schet-tax-nal.vat-pc           = parvat-pc                and
                                                    bfrb_arh-fin-doc-schet-tax-nal.slt-pc           = parslt-pc                and
                                                    bfrb_arh-fin-doc-schet-tax-nal.with-vat         = parwith-vat              and
                                                    bfrb_arh-fin-doc-schet-tax-nal.with-slt         = parwith-slt              and
                                                    bfrb_arh-fin-doc-schet-tax-nal.sum-type         = parsum-type              and
                                                    bfrb_arh-fin-doc-schet-tax-nal.fact-order       = parfact-order            exclusive-lock.
  end.
  for each rbfrb_arh-fin-doc-schet-tax-nal where rbfrb_arh-fin-doc-schet-tax-nal.host-code        = bfrb_arh-fin-doc-schet-tax-nal.host-code        and
                                                 rbfrb_arh-fin-doc-schet-tax-nal.cli-type         = parreceiver-type                                and
                                                 rbfrb_arh-fin-doc-schet-tax-nal.cli-code         = parreceiver-code                                and
                                                 rbfrb_arh-fin-doc-schet-tax-nal.fin-code-acc     = bfrb_arh-fin-doc-schet-tax-nal.fin-code-acc     and
                                                 rbfrb_arh-fin-doc-schet-tax-nal.curr-code        = bfrb_arh-fin-doc-schet-tax-nal.curr-code        and
                                                 rbfrb_arh-fin-doc-schet-tax-nal.fin-ext-doc-type = bfrb_arh-fin-doc-schet-tax-nal.fin-ext-doc-type and
                                                 rbfrb_arh-fin-doc-schet-tax-nal.calc-curr-code   = bfrb_arh-fin-doc-schet-tax-nal.calc-curr-code   and
                                                 rbfrb_arh-fin-doc-schet-tax-nal.vat-pc           = bfrb_arh-fin-doc-schet-tax-nal.vat-pc           and
                                                 rbfrb_arh-fin-doc-schet-tax-nal.slt-pc           = bfrb_arh-fin-doc-schet-tax-nal.slt-pc           and
                                                 rbfrb_arh-fin-doc-schet-tax-nal.with-vat         = bfrb_arh-fin-doc-schet-tax-nal.with-vat         and
                                                 rbfrb_arh-fin-doc-schet-tax-nal.with-slt         = bfrb_arh-fin-doc-schet-tax-nal.with-slt         and
                                                 rbfrb_arh-fin-doc-schet-tax-nal.sum-type         = bfrb_arh-fin-doc-schet-tax-nal.sum-type         and
                                                 rbfrb_arh-fin-doc-schet-tax-nal.fact-order       > bfrb_arh-fin-doc-schet-tax-nal.fact-order       use-index pi exclusive-lock on error undo, return error return-value:
    assign
      rbfrb_arh-fin-doc-schet-tax-nal.income     = rbfrb_arh-fin-doc-schet-tax-nal.income     + parsum-base
      rbfrb_arh-fin-doc-schet-tax-nal.income-vat = rbfrb_arh-fin-doc-schet-tax-nal.income-vat + parsum-vat-base
      rbfrb_arh-fin-doc-schet-tax-nal.income-slt = rbfrb_arh-fin-doc-schet-tax-nal.income-slt + parsum-slt-base
    .
  end.
  if parmode = "delete":u then do:
    delete bfpb_arh-fin-doc-schet-tax-nal.
    delete bfrb_arh-fin-doc-schet-tax-nal.
  end.
end.
end.
end procedure.