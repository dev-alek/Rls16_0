block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: defa58501af7, 2087, rls $":U .
define variable vss-author      as character no-undo init "$Author: druban $":U .
define variable vss-date        as character no-undo init "$Date: Wed Dec 25 15:23:51 2019 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: libfarpo.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/libfarpo.p $":U .
define variable vss-description as character no-undo init "Внутренние процедуры для библиотеки по работы с финансовыми архивами по финдокументам (объекты)".
procedure vss-get-info :
  define output parameter p-vss-revision    like vss-revision    no-undo .
  define output parameter p-vss-author      like vss-author      no-undo .
  define output parameter p-vss-date        like vss-date        no-undo .
  define output parameter p-vss-workfile    like vss-workfile    no-undo .
  define output parameter p-vss-archive     like vss-archive     no-undo .
  define output parameter p-vss-description like vss-description no-undo .
  assign
    p-vss-revision    = vss-revision
    p-vss-author      = vss-author
    p-vss-date        = vss-date
    p-vss-workfile    = vss-workfile
    p-vss-archive     = vss-archive
    p-vss-description = vss-description
  .
end procedure.
procedure vss-get-parameters :
  define output parameter p-vss-parameters as character no-undo .
end procedure.
define new global shared variable g#vssrevis-logger as handle    no-undo .
define variable v-vssrevis-logevent                 as logical   no-undo init false .
define variable v-vssrevis-logger                   as handle    no-undo .
procedure vss-logevent :
  define input  parameter p-extra-paramters as character no-undo .
  define variable v-vssrevis-parameters as character no-undo .
  do
  on error undo, return error return-value
  :
    if  valid-handle(v-vssrevis-logger)
    and v-vssrevis-logger :get-signature("logevent") <> ""
    then do:
      run vss-get-parameters in this-procedure
        (output v-vssrevis-parameters
        ).
      run logevent in v-vssrevis-logger
        (input vss-workfile
        ,input vss-revision
        ,input v-vssrevis-parameters
        ,input p-extra-paramters
        ).
    end.
  end.
end procedure.
assign
  v-vssrevis-logger = g#vssrevis-logger
.
if  valid-handle(v-vssrevis-logger)
and v-vssrevis-logger :get-signature("logevent") <> ""
then do:
  assign
    v-vssrevis-logevent = true
  .
  run vss-logevent in this-procedure (input vss-description) .
end.
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define new global shared variable g#libfarpo as handle no-undo .
if valid-handle (g#libfarpo)
and g#libfarpo <> this-procedure :handle
and g#libfarpo :get-signature('libfarpo_calc-arh-fin-doc-an-obj':u) <> ""
then do:
  message
    vss-workfile vss-revision vss-description skip
    "Попытка повторной загрузки внутренних процедур библиотеки для работы с финансовыми архивами по финансовым документам (объекты)" skip
    g#libfarpo skip
    g#libfarpo :type skip
    g#libfarpo :file-name skip
    valid-handle(g#libfarpo) skip
    this-procedure :handle skip
    this-procedure :type skip
    this-procedure :file-name skip
    valid-handle(this-procedure) skip
    view-as alert-box error .
  undo, return error .
end.
else do:
  assign
    g#libfarpo = this-procedure :handle
  .
end.
on delete of this-procedure do:
  assign
    g#libfarpo = ?
  .
end.
define stream str-err.
procedure libfarpo_calc-arh-fin-doc-an-obj :
define input parameter parmode                    as   character                   no-undo.
define input parameter parhost-code               like ub.fin-doc.host-code        no-undo.
define input parameter parobj-type                like ub.fin-doc.obj-type         no-undo.
define input parameter parobj-code                like ub.fin-doc.obj-code         no-undo.
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
define buffer bfps_arh-fin-doc-an-obj  for ub.arh-fin-doc-an-obj.
define buffer bfrs_arh-fin-doc-an-obj  for ub.arh-fin-doc-an-obj.
define buffer rbfps_arh-fin-doc-an-obj for ub.arh-fin-doc-an-obj.
define buffer rbfrs_arh-fin-doc-an-obj for ub.arh-fin-doc-an-obj.
define buffer bops_arh-fin-doc-an-obj  for ub.arh-fin-doc-an-obj.
define buffer bors_arh-fin-doc-an-obj  for ub.arh-fin-doc-an-obj.
define buffer bdps_arh-fin-doc-an-obj  for ub.arh-fin-doc-an-obj.
define buffer bdrs_arh-fin-doc-an-obj  for ub.arh-fin-doc-an-obj.
define buffer bfpr_arh-fin-doc-an-obj  for ub.arh-fin-doc-an-obj.
define buffer bfrr_arh-fin-doc-an-obj  for ub.arh-fin-doc-an-obj.
define buffer rbfpr_arh-fin-doc-an-obj for ub.arh-fin-doc-an-obj.
define buffer rbfrr_arh-fin-doc-an-obj for ub.arh-fin-doc-an-obj.
define buffer bopr_arh-fin-doc-an-obj  for ub.arh-fin-doc-an-obj.
define buffer borr_arh-fin-doc-an-obj  for ub.arh-fin-doc-an-obj.
define buffer bdpr_arh-fin-doc-an-obj  for ub.arh-fin-doc-an-obj.
define buffer bdrr_arh-fin-doc-an-obj  for ub.arh-fin-doc-an-obj.
define buffer bfpb_arh-fin-doc-an-obj  for ub.arh-fin-doc-an-obj.
define buffer bfrb_arh-fin-doc-an-obj  for ub.arh-fin-doc-an-obj.
define buffer rbfpb_arh-fin-doc-an-obj for ub.arh-fin-doc-an-obj.
define buffer rbfrb_arh-fin-doc-an-obj for ub.arh-fin-doc-an-obj.
define buffer bopb_arh-fin-doc-an-obj  for ub.arh-fin-doc-an-obj.
define buffer borb_arh-fin-doc-an-obj  for ub.arh-fin-doc-an-obj.
define buffer bdpb_arh-fin-doc-an-obj  for ub.arh-fin-doc-an-obj.
define buffer bdrb_arh-fin-doc-an-obj  for ub.arh-fin-doc-an-obj.
define buffer bfpc_arh-fin-doc-an-obj  for ub.arh-fin-doc-an-obj.
define buffer bfrc_arh-fin-doc-an-obj  for ub.arh-fin-doc-an-obj.
define buffer rbfpc_arh-fin-doc-an-obj for ub.arh-fin-doc-an-obj.
define buffer rbfrc_arh-fin-doc-an-obj for ub.arh-fin-doc-an-obj.
define buffer bopc_arh-fin-doc-an-obj  for ub.arh-fin-doc-an-obj.
define buffer borc_arh-fin-doc-an-obj  for ub.arh-fin-doc-an-obj.
define buffer bdpc_arh-fin-doc-an-obj  for ub.arh-fin-doc-an-obj.
define buffer bdrc_arh-fin-doc-an-obj  for ub.arh-fin-doc-an-obj.
do on error undo, return error substitute ("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
if parmode = "close":u then do:
  find last bops_arh-fin-doc-an-obj where bops_arh-fin-doc-an-obj.host-code         = parhost-code         and
                                          bops_arh-fin-doc-an-obj.cli-type          = parpayer-type        and
                                          bops_arh-fin-doc-an-obj.cli-code          = parpayer-code        and
                                          bops_arh-fin-doc-an-obj.obj-type          = parobj-type          and
                                          bops_arh-fin-doc-an-obj.obj-code          = parobj-code          and
                                          bops_arh-fin-doc-an-obj.code-schet        = parpayer-code-schet  and
                                          bops_arh-fin-doc-an-obj.fin-ext-doc-type  = parfin-ext-doc-type  and
                                          bops_arh-fin-doc-an-obj.fin-code-an-uchet = parfin-code-an-uchet and
                                          bops_arh-fin-doc-an-obj.fin-code-cel-nazn = parfin-code-cel-nazn and
                                          bops_arh-fin-doc-an-obj.fin-code-cor-acc  = parfin-code-cor-acc  and
                                          bops_arh-fin-doc-an-obj.calc-curr-code    = parcurr-code         and
                                          bops_arh-fin-doc-an-obj.sum-type          = parsum-type          and
                                          bops_arh-fin-doc-an-obj.fact-order        < parfact-order        use-index pi no-error.
  create bfps_arh-fin-doc-an-obj.
  assign
    bfps_arh-fin-doc-an-obj.host-code         = parhost-code
    bfps_arh-fin-doc-an-obj.obj-type          = parobj-type
    bfps_arh-fin-doc-an-obj.obj-code          = parobj-code
    bfps_arh-fin-doc-an-obj.cli-type          = parpayer-type
    bfps_arh-fin-doc-an-obj.cli-code          = parpayer-code
    bfps_arh-fin-doc-an-obj.code-schet        = parpayer-code-schet
    bfps_arh-fin-doc-an-obj.fin-ext-doc-type  = parfin-ext-doc-type
    bfps_arh-fin-doc-an-obj.fin-code-an-uchet = parfin-code-an-uchet
    bfps_arh-fin-doc-an-obj.fin-code-cel-nazn = parfin-code-cel-nazn
    bfps_arh-fin-doc-an-obj.fin-code-cor-acc  = parfin-code-cor-acc
    bfps_arh-fin-doc-an-obj.calc-curr-code    = parcurr-code
    bfps_arh-fin-doc-an-obj.sum-type          = parsum-type
    bfps_arh-fin-doc-an-obj.cource-des        = "s":u
    bfps_arh-fin-doc-an-obj.fact-order        = parfact-order
    bfps_arh-fin-doc-an-obj.fin-doc-code      = parfin-doc-code
    bfps_arh-fin-doc-an-obj.fact-date         = parfact-date
    bfps_arh-fin-doc-an-obj.curr-code         = parcurr-code
    bfps_arh-fin-doc-an-obj.income            = (if available bops_arh-fin-doc-an-obj then bops_arh-fin-doc-an-obj.income      else 0)
    bfps_arh-fin-doc-an-obj.income-vat        = (if available bops_arh-fin-doc-an-obj then bops_arh-fin-doc-an-obj.income-vat  else 0)
    bfps_arh-fin-doc-an-obj.income-slt        = (if available bops_arh-fin-doc-an-obj then bops_arh-fin-doc-an-obj.income-slt  else 0)
    bfps_arh-fin-doc-an-obj.expense           = (if available bops_arh-fin-doc-an-obj then bops_arh-fin-doc-an-obj.expense     else 0) + parsum-doc
    bfps_arh-fin-doc-an-obj.expense-vat       = (if available bops_arh-fin-doc-an-obj then bops_arh-fin-doc-an-obj.expense-vat else 0) + parsum-vat-doc
    bfps_arh-fin-doc-an-obj.expense-slt       = (if available bops_arh-fin-doc-an-obj then bops_arh-fin-doc-an-obj.expense-slt else 0) + parsum-slt-doc
  .
end.
else do:
  find first bfps_arh-fin-doc-an-obj where bfps_arh-fin-doc-an-obj.host-code         = parhost-code         and
                                           bfps_arh-fin-doc-an-obj.obj-type          = parobj-type          and
                                           bfps_arh-fin-doc-an-obj.obj-code          = parobj-code          and
                                           bfps_arh-fin-doc-an-obj.cli-type          = parpayer-type        and
                                           bfps_arh-fin-doc-an-obj.cli-code          = parpayer-code        and
                                           bfps_arh-fin-doc-an-obj.code-schet        = parpayer-code-schet  and
                                           bfps_arh-fin-doc-an-obj.fin-ext-doc-type  = parfin-ext-doc-type  and
                                           bfps_arh-fin-doc-an-obj.fin-code-an-uchet = parfin-code-an-uchet and
                                           bfps_arh-fin-doc-an-obj.fin-code-cel-nazn = parfin-code-cel-nazn and
                                           bfps_arh-fin-doc-an-obj.fin-code-cor-acc  = parfin-code-cor-acc  and
                                           bfps_arh-fin-doc-an-obj.calc-curr-code    = parcurr-code         and
                                           bfps_arh-fin-doc-an-obj.sum-type          = parsum-type          and
                                           bfps_arh-fin-doc-an-obj.fact-order        = parfact-order        exclusive-lock.
end.
for each rbfps_arh-fin-doc-an-obj where rbfps_arh-fin-doc-an-obj.host-code          = bfps_arh-fin-doc-an-obj.host-code         and
                                        rbfps_arh-fin-doc-an-obj.obj-type           = bfps_arh-fin-doc-an-obj.obj-type          and
                                        rbfps_arh-fin-doc-an-obj.obj-code           = bfps_arh-fin-doc-an-obj.obj-code          and
                                        rbfps_arh-fin-doc-an-obj.cli-type           = parpayer-type                             and
                                        rbfps_arh-fin-doc-an-obj.cli-code           = parpayer-code                             and
                                        rbfps_arh-fin-doc-an-obj.code-schet         = bfps_arh-fin-doc-an-obj.code-schet        and
                                        rbfps_arh-fin-doc-an-obj.fin-ext-doc-type   = bfps_arh-fin-doc-an-obj.fin-ext-doc-type  and
                                        rbfps_arh-fin-doc-an-obj.fin-code-an-uchet  = bfps_arh-fin-doc-an-obj.fin-code-an-uchet and
                                        rbfps_arh-fin-doc-an-obj.fin-code-cel-nazn  = bfps_arh-fin-doc-an-obj.fin-code-cel-nazn and
                                        rbfps_arh-fin-doc-an-obj.fin-code-cor-acc   = bfps_arh-fin-doc-an-obj.fin-code-cor-acc  and
                                        rbfps_arh-fin-doc-an-obj.calc-curr-code     = bfps_arh-fin-doc-an-obj.calc-curr-code    and
                                        rbfps_arh-fin-doc-an-obj.sum-type           = bfps_arh-fin-doc-an-obj.sum-type          and
                                        rbfps_arh-fin-doc-an-obj.fact-order         > bfps_arh-fin-doc-an-obj.fact-order        use-index pi exclusive-lock on error undo, return error return-value :
  assign
    rbfps_arh-fin-doc-an-obj.expense     = rbfps_arh-fin-doc-an-obj.expense     + parsum-doc
    rbfps_arh-fin-doc-an-obj.expense-vat = rbfps_arh-fin-doc-an-obj.expense-vat + parsum-vat-doc
    rbfps_arh-fin-doc-an-obj.expense-slt = rbfps_arh-fin-doc-an-obj.expense-slt + parsum-slt-doc.
end.
if parmode = "close":u then do:
  find last bors_arh-fin-doc-an-obj where bors_arh-fin-doc-an-obj.host-code         = parhost-code            and
                                          bors_arh-fin-doc-an-obj.obj-type          = parobj-type             and
                                          bors_arh-fin-doc-an-obj.obj-code          = parobj-code             and
                                          bors_arh-fin-doc-an-obj.cli-type          = parreceiver-type        and
                                          bors_arh-fin-doc-an-obj.cli-code          = parreceiver-code        and
                                          bors_arh-fin-doc-an-obj.code-schet        = parreceiver-code-schet  and
                                          bors_arh-fin-doc-an-obj.fin-ext-doc-type  = parfin-ext-doc-type     and
                                          bors_arh-fin-doc-an-obj.fin-code-an-uchet = parfin-code-an-uchet    and
                                          bors_arh-fin-doc-an-obj.fin-code-cel-nazn = parfin-code-cel-nazn    and
                                          bors_arh-fin-doc-an-obj.fin-code-cor-acc  = parfin-code-cor-acc     and
                                          bors_arh-fin-doc-an-obj.calc-curr-code    = parcurr-code            and
                                          bors_arh-fin-doc-an-obj.sum-type          = parsum-type             and
                                          bors_arh-fin-doc-an-obj.fact-order        < parfact-order           use-index pi no-error.
    create bfrs_arh-fin-doc-an-obj.
  assign
    bfrs_arh-fin-doc-an-obj.host-code         = parhost-code
    bfrs_arh-fin-doc-an-obj.obj-type          = parobj-type
    bfrs_arh-fin-doc-an-obj.obj-code          = parobj-code
    bfrs_arh-fin-doc-an-obj.cli-type          = parreceiver-type
    bfrs_arh-fin-doc-an-obj.cli-code          = parreceiver-code
    bfrs_arh-fin-doc-an-obj.code-schet        = parreceiver-code-schet
    bfrs_arh-fin-doc-an-obj.fin-ext-doc-type  = parfin-ext-doc-type
    bfrs_arh-fin-doc-an-obj.fin-code-an-uchet = parfin-code-an-uchet
    bfrs_arh-fin-doc-an-obj.fin-code-cel-nazn = parfin-code-cel-nazn
    bfrs_arh-fin-doc-an-obj.fin-code-cor-acc  = parfin-code-cor-acc
    bfrs_arh-fin-doc-an-obj.calc-curr-code    = parcurr-code
    bfrs_arh-fin-doc-an-obj.sum-type          = parsum-type
    bfrs_arh-fin-doc-an-obj.cource-des        = "s":u
    bfrs_arh-fin-doc-an-obj.fact-order        = parfact-order
    bfrs_arh-fin-doc-an-obj.fin-doc-code      = parfin-doc-code
    bfrs_arh-fin-doc-an-obj.fact-date         = parfact-date
    bfrs_arh-fin-doc-an-obj.curr-code         = parcurr-code.
  assign
    bfrs_arh-fin-doc-an-obj.expense           = (if available bors_arh-fin-doc-an-obj then bors_arh-fin-doc-an-obj.expense     else 0)
    bfrs_arh-fin-doc-an-obj.expense-vat       = (if available bors_arh-fin-doc-an-obj then bors_arh-fin-doc-an-obj.expense-vat else 0)
    bfrs_arh-fin-doc-an-obj.expense-slt       = (if available bors_arh-fin-doc-an-obj then bors_arh-fin-doc-an-obj.expense-slt else 0)
    bfrs_arh-fin-doc-an-obj.income            = (if available bors_arh-fin-doc-an-obj then bors_arh-fin-doc-an-obj.income      else 0) + parsum-doc
    bfrs_arh-fin-doc-an-obj.income-vat        = (if available bors_arh-fin-doc-an-obj then bors_arh-fin-doc-an-obj.income-vat  else 0) + parsum-vat-doc
    bfrs_arh-fin-doc-an-obj.income-slt        = (if available bors_arh-fin-doc-an-obj then bors_arh-fin-doc-an-obj.income-slt  else 0) + parsum-slt-doc
  .
end.
else do:
  find first bfrs_arh-fin-doc-an-obj where bfrs_arh-fin-doc-an-obj.host-code         = parhost-code            and
                                           bfrs_arh-fin-doc-an-obj.obj-type          = parobj-type             and
                                           bfrs_arh-fin-doc-an-obj.obj-code          = parobj-code             and
                                           bfrs_arh-fin-doc-an-obj.cli-type          = parreceiver-type        and
                                           bfrs_arh-fin-doc-an-obj.cli-code          = parreceiver-code        and
                                           bfrs_arh-fin-doc-an-obj.code-schet        = parreceiver-code-schet  and
                                           bfrs_arh-fin-doc-an-obj.fin-ext-doc-type  = parfin-ext-doc-type     and
                                           bfrs_arh-fin-doc-an-obj.fin-code-an-uchet = parfin-code-an-uchet    and
                                           bfrs_arh-fin-doc-an-obj.fin-code-cel-nazn = parfin-code-cel-nazn    and
                                           bfrs_arh-fin-doc-an-obj.fin-code-cor-acc  = parfin-code-cor-acc     and
                                           bfrs_arh-fin-doc-an-obj.calc-curr-code    = parcurr-code            and
                                           bfrs_arh-fin-doc-an-obj.sum-type          = parsum-type             and
                                           bfrs_arh-fin-doc-an-obj.fact-order        = parfact-order           exclusive-lock.
end.
for each rbfrs_arh-fin-doc-an-obj where rbfrs_arh-fin-doc-an-obj.host-code         = bfrs_arh-fin-doc-an-obj.host-code         and
                                        rbfrs_arh-fin-doc-an-obj.obj-type          = bfrs_arh-fin-doc-an-obj.obj-type          and
                                        rbfrs_arh-fin-doc-an-obj.obj-code          = bfrs_arh-fin-doc-an-obj.obj-code          and
                                        rbfrs_arh-fin-doc-an-obj.cli-type          = parreceiver-type                          and
                                        rbfrs_arh-fin-doc-an-obj.cli-code          = parreceiver-code                          and
                                        rbfrs_arh-fin-doc-an-obj.code-schet        = bfrs_arh-fin-doc-an-obj.code-schet        and
                                        rbfrs_arh-fin-doc-an-obj.fin-ext-doc-type  = bfrs_arh-fin-doc-an-obj.fin-ext-doc-type  and
                                        rbfrs_arh-fin-doc-an-obj.fin-code-an-uchet = bfrs_arh-fin-doc-an-obj.fin-code-an-uchet and
                                        rbfrs_arh-fin-doc-an-obj.fin-code-cel-nazn = bfrs_arh-fin-doc-an-obj.fin-code-cel-nazn and
                                        rbfrs_arh-fin-doc-an-obj.fin-code-cor-acc  = bfrs_arh-fin-doc-an-obj.fin-code-cor-acc  and
                                        rbfrs_arh-fin-doc-an-obj.calc-curr-code    = bfrs_arh-fin-doc-an-obj.calc-curr-code    and
                                        rbfrs_arh-fin-doc-an-obj.sum-type          = bfrs_arh-fin-doc-an-obj.sum-type          and
                                        rbfrs_arh-fin-doc-an-obj.fact-order        > bfrs_arh-fin-doc-an-obj.fact-order        use-index pi exclusive-lock on error undo, return error return-value :
  assign
    rbfrs_arh-fin-doc-an-obj.income     = rbfrs_arh-fin-doc-an-obj.income     + parsum-doc
    rbfrs_arh-fin-doc-an-obj.income-vat = rbfrs_arh-fin-doc-an-obj.income-vat + parsum-vat-doc
    rbfrs_arh-fin-doc-an-obj.income-slt = rbfrs_arh-fin-doc-an-obj.income-slt + parsum-slt-doc
  .
end.
if parmode = "delete":u then do:
  delete bfps_arh-fin-doc-an-obj.
  delete bfrs_arh-fin-doc-an-obj.
end.
if parcurr-code <> 0 then do:
  if parmode = "close":u then do:
    find last bopr_arh-fin-doc-an-obj where bopr_arh-fin-doc-an-obj.host-code         = parhost-code         and
                                            bopr_arh-fin-doc-an-obj.obj-type          = parobj-type          and
                                            bopr_arh-fin-doc-an-obj.obj-code          = parobj-code          and
                                            bopr_arh-fin-doc-an-obj.cli-type          = parpayer-type        and
                                            bopr_arh-fin-doc-an-obj.cli-code          = parpayer-code        and
                                            bopr_arh-fin-doc-an-obj.code-schet        = parpayer-code-schet  and
                                            bopr_arh-fin-doc-an-obj.fin-ext-doc-type  = parfin-ext-doc-type  and
                                            bopr_arh-fin-doc-an-obj.fin-code-an-uchet = parfin-code-an-uchet and
                                            bopr_arh-fin-doc-an-obj.fin-code-cel-nazn = parfin-code-cel-nazn and
                                            bopr_arh-fin-doc-an-obj.fin-code-cor-acc  = parfin-code-cor-acc  and
                                            bopr_arh-fin-doc-an-obj.calc-curr-code    = 0                    and
                                            bopr_arh-fin-doc-an-obj.sum-type          = parsum-type          and
                                            bopr_arh-fin-doc-an-obj.fact-order        < parfact-order        use-index pi no-error.
    create bfpr_arh-fin-doc-an-obj.
    assign
      bfpr_arh-fin-doc-an-obj.host-code         = parhost-code
      bfpr_arh-fin-doc-an-obj.obj-type          = parobj-type
      bfpr_arh-fin-doc-an-obj.obj-code          = parobj-code
      bfpr_arh-fin-doc-an-obj.cli-type          = parpayer-type
      bfpr_arh-fin-doc-an-obj.cli-code          = parpayer-code
      bfpr_arh-fin-doc-an-obj.code-schet        = parpayer-code-schet
      bfpr_arh-fin-doc-an-obj.fin-ext-doc-type  = parfin-ext-doc-type
      bfpr_arh-fin-doc-an-obj.fin-code-an-uchet = parfin-code-an-uchet
      bfpr_arh-fin-doc-an-obj.fin-code-cel-nazn = parfin-code-cel-nazn
      bfpr_arh-fin-doc-an-obj.fin-code-cor-acc  = parfin-code-cor-acc
      bfpr_arh-fin-doc-an-obj.calc-curr-code    = 0
      bfpr_arh-fin-doc-an-obj.sum-type          = parsum-type
      bfpr_arh-fin-doc-an-obj.cource-des        = "r":u
      bfpr_arh-fin-doc-an-obj.fact-order        = parfact-order
      bfpr_arh-fin-doc-an-obj.fin-doc-code      = parfin-doc-code
      bfpr_arh-fin-doc-an-obj.fact-date         = parfact-date
      bfpr_arh-fin-doc-an-obj.curr-code         = parcurr-code
      bfpr_arh-fin-doc-an-obj.income            = (if available bopr_arh-fin-doc-an-obj then bopr_arh-fin-doc-an-obj.income      else 0)
      bfpr_arh-fin-doc-an-obj.income-vat        = (if available bopr_arh-fin-doc-an-obj then bopr_arh-fin-doc-an-obj.income-vat  else 0)
      bfpr_arh-fin-doc-an-obj.income-slt        = (if available bopr_arh-fin-doc-an-obj then bopr_arh-fin-doc-an-obj.income-slt  else 0)
      bfpr_arh-fin-doc-an-obj.expense           = (if available bopr_arh-fin-doc-an-obj then bopr_arh-fin-doc-an-obj.expense     else 0) + parsum-rubl
      bfpr_arh-fin-doc-an-obj.expense-vat       = (if available bopr_arh-fin-doc-an-obj then bopr_arh-fin-doc-an-obj.expense-vat else 0) + parsum-vat-rubl
      bfpr_arh-fin-doc-an-obj.expense-slt       = (if available bopr_arh-fin-doc-an-obj then bopr_arh-fin-doc-an-obj.expense-slt else 0) + parsum-slt-rubl
    .
  end.
  else do:
    find first bfpr_arh-fin-doc-an-obj where bfpr_arh-fin-doc-an-obj.host-code         = parhost-code         and
                                             bfpr_arh-fin-doc-an-obj.obj-type          = parobj-type          and
                                             bfpr_arh-fin-doc-an-obj.obj-code          = parobj-code          and
                                             bfpr_arh-fin-doc-an-obj.cli-type          = parpayer-type        and
                                             bfpr_arh-fin-doc-an-obj.cli-code          = parpayer-code        and
                                             bfpr_arh-fin-doc-an-obj.code-schet        = parpayer-code-schet  and
                                             bfpr_arh-fin-doc-an-obj.fin-ext-doc-type  = parfin-ext-doc-type  and
                                             bfpr_arh-fin-doc-an-obj.fin-code-an-uchet = parfin-code-an-uchet and
                                             bfpr_arh-fin-doc-an-obj.fin-code-cel-nazn = parfin-code-cel-nazn and
                                             bfpr_arh-fin-doc-an-obj.fin-code-cor-acc  = parfin-code-cor-acc  and
                                             bfpr_arh-fin-doc-an-obj.calc-curr-code    = 0                    and
                                             bfpr_arh-fin-doc-an-obj.sum-type          = parsum-type          and
                                             bfpr_arh-fin-doc-an-obj.fact-order        = parfact-order        exclusive-lock.
  end.
  for each rbfpr_arh-fin-doc-an-obj where rbfpr_arh-fin-doc-an-obj.host-code         = bfpr_arh-fin-doc-an-obj.host-code         and
                                          rbfpr_arh-fin-doc-an-obj.obj-type          = bfpr_arh-fin-doc-an-obj.obj-type          and
                                          rbfpr_arh-fin-doc-an-obj.obj-code          = bfpr_arh-fin-doc-an-obj.obj-code          and
                                          rbfpr_arh-fin-doc-an-obj.cli-type          = parpayer-type                             and
                                          rbfpr_arh-fin-doc-an-obj.cli-code          = parpayer-code                             and
                                          rbfpr_arh-fin-doc-an-obj.code-schet        = bfpr_arh-fin-doc-an-obj.code-schet        and
                                          rbfpr_arh-fin-doc-an-obj.fin-ext-doc-type  = bfpr_arh-fin-doc-an-obj.fin-ext-doc-type  and
                                          rbfpr_arh-fin-doc-an-obj.fin-code-an-uchet = bfpr_arh-fin-doc-an-obj.fin-code-an-uchet and
                                          rbfpr_arh-fin-doc-an-obj.fin-code-cel-nazn = bfpr_arh-fin-doc-an-obj.fin-code-cel-nazn and
                                          rbfpr_arh-fin-doc-an-obj.fin-code-cor-acc  = bfpr_arh-fin-doc-an-obj.fin-code-cor-acc  and
                                          rbfpr_arh-fin-doc-an-obj.calc-curr-code    = bfpr_arh-fin-doc-an-obj.calc-curr-code    and
                                          rbfpr_arh-fin-doc-an-obj.sum-type          = bfpr_arh-fin-doc-an-obj.sum-type          and
                                          rbfpr_arh-fin-doc-an-obj.fact-order        > bfpr_arh-fin-doc-an-obj.fact-order        use-index pi exclusive-lock on error undo, return error return-value :
    assign
      rbfpr_arh-fin-doc-an-obj.expense     = rbfpr_arh-fin-doc-an-obj.expense     + parsum-rubl
      rbfpr_arh-fin-doc-an-obj.expense-vat = rbfpr_arh-fin-doc-an-obj.expense-vat + parsum-vat-rubl
      rbfpr_arh-fin-doc-an-obj.expense-slt = rbfpr_arh-fin-doc-an-obj.expense-slt + parsum-slt-rubl
    .
  end.
  if parmode = "close":u then do:
    find last borr_arh-fin-doc-an-obj where borr_arh-fin-doc-an-obj.host-code         = parhost-code            and
                                            borr_arh-fin-doc-an-obj.obj-type          = parobj-type             and
                                            borr_arh-fin-doc-an-obj.obj-code          = parobj-code             and
                                            borr_arh-fin-doc-an-obj.cli-type          = parreceiver-type        and
                                            borr_arh-fin-doc-an-obj.cli-code          = parreceiver-code        and
                                            borr_arh-fin-doc-an-obj.code-schet        = parreceiver-code-schet  and
                                            borr_arh-fin-doc-an-obj.fin-ext-doc-type  = parfin-ext-doc-type     and
                                            borr_arh-fin-doc-an-obj.fin-code-an-uchet = parfin-code-an-uchet    and
                                            borr_arh-fin-doc-an-obj.fin-code-cel-nazn = parfin-code-cel-nazn    and
                                            borr_arh-fin-doc-an-obj.fin-code-cor-acc  = parfin-code-cor-acc     and
                                            borr_arh-fin-doc-an-obj.calc-curr-code    = 0                       and
                                            borr_arh-fin-doc-an-obj.sum-type          = parsum-type             and
                                            borr_arh-fin-doc-an-obj.fact-order        < parfact-order           use-index pi no-error.
    create bfrr_arh-fin-doc-an-obj.
    assign
      bfrr_arh-fin-doc-an-obj.host-code         = parhost-code
      bfrr_arh-fin-doc-an-obj.obj-type          = parobj-type
      bfrr_arh-fin-doc-an-obj.obj-code          = parobj-code
      bfrr_arh-fin-doc-an-obj.cli-type          = parreceiver-type
      bfrr_arh-fin-doc-an-obj.cli-code          = parreceiver-code
      bfrr_arh-fin-doc-an-obj.code-schet        = parreceiver-code-schet
      bfrr_arh-fin-doc-an-obj.fin-ext-doc-type  = parfin-ext-doc-type
      bfrr_arh-fin-doc-an-obj.fin-code-an-uchet = parfin-code-an-uchet
      bfrr_arh-fin-doc-an-obj.fin-code-cel-nazn = parfin-code-cel-nazn
      bfrr_arh-fin-doc-an-obj.fin-code-cor-acc  = parfin-code-cor-acc
      bfrr_arh-fin-doc-an-obj.calc-curr-code    = 0
      bfrr_arh-fin-doc-an-obj.sum-type          = parsum-type
      bfrr_arh-fin-doc-an-obj.cource-des        = "r":u
      bfrr_arh-fin-doc-an-obj.fact-order        = parfact-order
      bfrr_arh-fin-doc-an-obj.fin-doc-code      = parfin-doc-code
      bfrr_arh-fin-doc-an-obj.fact-date         = parfact-date
      bfrr_arh-fin-doc-an-obj.curr-code         = parcurr-code.
    assign
      bfrr_arh-fin-doc-an-obj.expense           = (if available borr_arh-fin-doc-an-obj then borr_arh-fin-doc-an-obj.expense     else 0)
      bfrr_arh-fin-doc-an-obj.expense-vat       = (if available borr_arh-fin-doc-an-obj then borr_arh-fin-doc-an-obj.expense-vat else 0)
      bfrr_arh-fin-doc-an-obj.expense-slt       = (if available borr_arh-fin-doc-an-obj then borr_arh-fin-doc-an-obj.expense-slt else 0)
      bfrr_arh-fin-doc-an-obj.income            = (if available borr_arh-fin-doc-an-obj then borr_arh-fin-doc-an-obj.income      else 0) + parsum-rubl
      bfrr_arh-fin-doc-an-obj.income-vat        = (if available borr_arh-fin-doc-an-obj then borr_arh-fin-doc-an-obj.income-vat  else 0) + parsum-vat-rubl
      bfrr_arh-fin-doc-an-obj.income-slt        = (if available borr_arh-fin-doc-an-obj then borr_arh-fin-doc-an-obj.income-slt  else 0) + parsum-slt-rubl
    .
  end.
  else do:
    find first bfrr_arh-fin-doc-an-obj where bfrr_arh-fin-doc-an-obj.host-code         = parhost-code            and
                                             bfrr_arh-fin-doc-an-obj.obj-type          = parobj-type             and
                                             bfrr_arh-fin-doc-an-obj.obj-code          = parobj-code             and
                                             bfrr_arh-fin-doc-an-obj.cli-type          = parreceiver-type        and
                                             bfrr_arh-fin-doc-an-obj.cli-code          = parreceiver-code        and
                                             bfrr_arh-fin-doc-an-obj.code-schet        = parreceiver-code-schet  and
                                             bfrr_arh-fin-doc-an-obj.fin-ext-doc-type  = parfin-ext-doc-type     and
                                             bfrr_arh-fin-doc-an-obj.fin-code-an-uchet = parfin-code-an-uchet    and
                                             bfrr_arh-fin-doc-an-obj.fin-code-cel-nazn = parfin-code-cel-nazn    and
                                             bfrr_arh-fin-doc-an-obj.fin-code-cor-acc  = parfin-code-cor-acc     and
                                             bfrr_arh-fin-doc-an-obj.calc-curr-code    = 0                       and
                                             bfrr_arh-fin-doc-an-obj.sum-type          = parsum-type             and
                                             bfrr_arh-fin-doc-an-obj.fact-order        = parfact-order           no-error.
  end.
  for each rbfrr_arh-fin-doc-an-obj where rbfrr_arh-fin-doc-an-obj.host-code         = bfrr_arh-fin-doc-an-obj.host-code         and
                                          rbfrr_arh-fin-doc-an-obj.obj-type          = bfrr_arh-fin-doc-an-obj.obj-type          and
                                          rbfrr_arh-fin-doc-an-obj.obj-code          = bfrr_arh-fin-doc-an-obj.obj-code          and
                                          rbfrr_arh-fin-doc-an-obj.cli-type          = parreceiver-type                          and
                                          rbfrr_arh-fin-doc-an-obj.cli-code          = parreceiver-code                          and
                                          rbfrr_arh-fin-doc-an-obj.code-schet        = bfrr_arh-fin-doc-an-obj.code-schet        and
                                          rbfrr_arh-fin-doc-an-obj.fin-ext-doc-type  = bfrr_arh-fin-doc-an-obj.fin-ext-doc-type  and
                                          rbfrr_arh-fin-doc-an-obj.fin-code-an-uchet = bfrr_arh-fin-doc-an-obj.fin-code-an-uchet and
                                          rbfrr_arh-fin-doc-an-obj.fin-code-cel-nazn = bfrr_arh-fin-doc-an-obj.fin-code-cel-nazn and
                                          rbfrr_arh-fin-doc-an-obj.fin-code-cor-acc  = bfrr_arh-fin-doc-an-obj.fin-code-cor-acc  and
                                          rbfrr_arh-fin-doc-an-obj.calc-curr-code    = bfrr_arh-fin-doc-an-obj.calc-curr-code    and
                                          rbfrr_arh-fin-doc-an-obj.sum-type          = bfrr_arh-fin-doc-an-obj.sum-type          and
                                          rbfrr_arh-fin-doc-an-obj.fact-order        > bfrr_arh-fin-doc-an-obj.fact-order        use-index pi exclusive-lock on error undo, return error return-value :
    assign
      rbfrr_arh-fin-doc-an-obj.income     = rbfrr_arh-fin-doc-an-obj.income     + parsum-rubl
      rbfrr_arh-fin-doc-an-obj.income-vat = rbfrr_arh-fin-doc-an-obj.income-vat + parsum-vat-rubl
      rbfrr_arh-fin-doc-an-obj.income-slt = rbfrr_arh-fin-doc-an-obj.income-slt + parsum-slt-rubl
    .
  end.
  if parmode = "delete":u then do:
    delete bfpr_arh-fin-doc-an-obj.
    delete bfrr_arh-fin-doc-an-obj.
  end.
end.
if parbase-code <> parcurr-code and
   parbase-code <> 0            then do:
  if parmode = "close":u then do:
    find last bopb_arh-fin-doc-an-obj where bopb_arh-fin-doc-an-obj.host-code         = parhost-code         and
                                            bopb_arh-fin-doc-an-obj.obj-type          = parobj-type          and
                                            bopb_arh-fin-doc-an-obj.obj-code          = parobj-code          and
                                            bopb_arh-fin-doc-an-obj.cli-type          = parpayer-type        and
                                            bopb_arh-fin-doc-an-obj.cli-code          = parpayer-code        and
                                            bopb_arh-fin-doc-an-obj.code-schet        = parpayer-code-schet  and
                                            bopb_arh-fin-doc-an-obj.fin-ext-doc-type  = parfin-ext-doc-type  and
                                            bopb_arh-fin-doc-an-obj.fin-code-an-uchet = parfin-code-an-uchet and
                                            bopb_arh-fin-doc-an-obj.fin-code-cel-nazn = parfin-code-cel-nazn and
                                            bopb_arh-fin-doc-an-obj.fin-code-cor-acc  = parfin-code-cor-acc  and
                                            bopb_arh-fin-doc-an-obj.calc-curr-code    = parbase-code         and
                                            bopb_arh-fin-doc-an-obj.sum-type          = parsum-type          and
                                            bopb_arh-fin-doc-an-obj.fact-order        < parfact-order        use-index pi no-error.
    create bfpb_arh-fin-doc-an-obj.
    assign
      bfpb_arh-fin-doc-an-obj.host-code         = parhost-code
      bfpb_arh-fin-doc-an-obj.obj-type          = parobj-type
      bfpb_arh-fin-doc-an-obj.obj-code          = parobj-code
      bfpb_arh-fin-doc-an-obj.cli-type          = parpayer-type
      bfpb_arh-fin-doc-an-obj.cli-code          = parpayer-code
      bfpb_arh-fin-doc-an-obj.code-schet        = parpayer-code-schet
      bfpb_arh-fin-doc-an-obj.fin-ext-doc-type  = parfin-ext-doc-type
      bfpb_arh-fin-doc-an-obj.fin-code-an-uchet = parfin-code-an-uchet
      bfpb_arh-fin-doc-an-obj.fin-code-cel-nazn = parfin-code-cel-nazn
      bfpb_arh-fin-doc-an-obj.fin-code-cor-acc  = parfin-code-cor-acc
      bfpb_arh-fin-doc-an-obj.calc-curr-code    = parbase-code
      bfpb_arh-fin-doc-an-obj.sum-type          = parsum-type
      bfpb_arh-fin-doc-an-obj.cource-des        = "b":u
      bfpb_arh-fin-doc-an-obj.fact-order        = parfact-order
      bfpb_arh-fin-doc-an-obj.fin-doc-code      = parfin-doc-code
      bfpb_arh-fin-doc-an-obj.fact-date         = parfact-date
      bfpb_arh-fin-doc-an-obj.curr-code         = parcurr-code
      bfpb_arh-fin-doc-an-obj.income            = (if available bopb_arh-fin-doc-an-obj then bopb_arh-fin-doc-an-obj.income      else 0)
      bfpb_arh-fin-doc-an-obj.income-vat        = (if available bopb_arh-fin-doc-an-obj then bopb_arh-fin-doc-an-obj.income-vat  else 0)
      bfpb_arh-fin-doc-an-obj.income-slt        = (if available bopb_arh-fin-doc-an-obj then bopb_arh-fin-doc-an-obj.income-slt  else 0)
      bfpb_arh-fin-doc-an-obj.expense           = (if available bopb_arh-fin-doc-an-obj then bopb_arh-fin-doc-an-obj.expense     else 0) + parsum-base
      bfpb_arh-fin-doc-an-obj.expense-vat       = (if available bopb_arh-fin-doc-an-obj then bopb_arh-fin-doc-an-obj.expense-vat else 0) + parsum-vat-base
      bfpb_arh-fin-doc-an-obj.expense-slt       = (if available bopb_arh-fin-doc-an-obj then bopb_arh-fin-doc-an-obj.expense-slt else 0) + parsum-slt-base
    .
  end.
  else do:
    find last bfpb_arh-fin-doc-an-obj where bfpb_arh-fin-doc-an-obj.host-code         = parhost-code         and
                                            bfpb_arh-fin-doc-an-obj.obj-type          = parobj-type          and
                                            bfpb_arh-fin-doc-an-obj.obj-code          = parobj-code          and
                                            bfpb_arh-fin-doc-an-obj.cli-type          = parpayer-type        and
                                            bfpb_arh-fin-doc-an-obj.cli-code          = parpayer-code        and
                                            bfpb_arh-fin-doc-an-obj.code-schet        = parpayer-code-schet  and
                                            bfpb_arh-fin-doc-an-obj.fin-ext-doc-type  = parfin-ext-doc-type  and
                                            bfpb_arh-fin-doc-an-obj.fin-code-an-uchet = parfin-code-an-uchet and
                                            bfpb_arh-fin-doc-an-obj.fin-code-cel-nazn = parfin-code-cel-nazn and
                                            bfpb_arh-fin-doc-an-obj.fin-code-cor-acc  = parfin-code-cor-acc  and
                                            bfpb_arh-fin-doc-an-obj.calc-curr-code    = parbase-code         and
                                            bfpb_arh-fin-doc-an-obj.sum-type          = parsum-type          and
                                            bfpb_arh-fin-doc-an-obj.fact-order        = parfact-order        no-error.
  end.
  for each rbfpb_arh-fin-doc-an-obj where rbfpb_arh-fin-doc-an-obj.host-code         = bfpb_arh-fin-doc-an-obj.host-code         and
                                          rbfpb_arh-fin-doc-an-obj.obj-type          = bfpb_arh-fin-doc-an-obj.obj-type          and
                                          rbfpb_arh-fin-doc-an-obj.obj-code          = bfpb_arh-fin-doc-an-obj.obj-code          and
                                          rbfpb_arh-fin-doc-an-obj.cli-type          = parpayer-type                             and
                                          rbfpb_arh-fin-doc-an-obj.cli-code          = parpayer-code                             and
                                          rbfpb_arh-fin-doc-an-obj.code-schet        = bfpb_arh-fin-doc-an-obj.code-schet        and
                                          rbfpb_arh-fin-doc-an-obj.fin-ext-doc-type  = bfpb_arh-fin-doc-an-obj.fin-ext-doc-type  and
                                          rbfpb_arh-fin-doc-an-obj.fin-code-an-uchet = bfpb_arh-fin-doc-an-obj.fin-code-an-uchet and
                                          rbfpb_arh-fin-doc-an-obj.fin-code-cel-nazn = bfpb_arh-fin-doc-an-obj.fin-code-cel-nazn and
                                          rbfpb_arh-fin-doc-an-obj.fin-code-cor-acc  = bfpb_arh-fin-doc-an-obj.fin-code-cor-acc  and
                                          rbfpb_arh-fin-doc-an-obj.calc-curr-code    = bfpb_arh-fin-doc-an-obj.calc-curr-code    and
                                          rbfpb_arh-fin-doc-an-obj.sum-type          = bfpb_arh-fin-doc-an-obj.sum-type          and
                                          rbfpb_arh-fin-doc-an-obj.fact-order        > bfpb_arh-fin-doc-an-obj.fact-order        use-index pi exclusive-lock on error undo, return error return-value :
    assign
      rbfpb_arh-fin-doc-an-obj.expense     = rbfpb_arh-fin-doc-an-obj.expense     + parsum-base
      rbfpb_arh-fin-doc-an-obj.expense-vat = rbfpb_arh-fin-doc-an-obj.expense-vat + parsum-vat-base
      rbfpb_arh-fin-doc-an-obj.expense-slt = rbfpb_arh-fin-doc-an-obj.expense-slt + parsum-slt-base
    .
  end.
  if parmode = "close":u then do:
    find last borb_arh-fin-doc-an-obj where borb_arh-fin-doc-an-obj.host-code         = parhost-code            and
                                            borb_arh-fin-doc-an-obj.obj-type          = parobj-type             and
                                            borb_arh-fin-doc-an-obj.obj-code          = parobj-code             and
                                            borb_arh-fin-doc-an-obj.cli-type          = parreceiver-type        and
                                            borb_arh-fin-doc-an-obj.cli-code          = parreceiver-code        and
                                            borb_arh-fin-doc-an-obj.code-schet        = parreceiver-code-schet  and
                                            borb_arh-fin-doc-an-obj.fin-ext-doc-type  = parfin-ext-doc-type     and
                                            borb_arh-fin-doc-an-obj.fin-code-an-uchet = parfin-code-an-uchet    and
                                            borb_arh-fin-doc-an-obj.fin-code-cel-nazn = parfin-code-cel-nazn    and
                                            borb_arh-fin-doc-an-obj.fin-code-cor-acc  = parfin-code-cor-acc     and
                                            borb_arh-fin-doc-an-obj.calc-curr-code    = parbase-code            and
                                            borb_arh-fin-doc-an-obj.sum-type          = parsum-type             and
                                            borb_arh-fin-doc-an-obj.fact-order        < parfact-order           use-index pi no-error.
    create bfrb_arh-fin-doc-an-obj.
    assign
      bfrb_arh-fin-doc-an-obj.host-code         = parhost-code
      bfrb_arh-fin-doc-an-obj.obj-type          = parobj-type
      bfrb_arh-fin-doc-an-obj.obj-code          = parobj-code
      bfrb_arh-fin-doc-an-obj.cli-type          = parreceiver-type
      bfrb_arh-fin-doc-an-obj.cli-code          = parreceiver-code
      bfrb_arh-fin-doc-an-obj.code-schet        = parreceiver-code-schet
      bfrb_arh-fin-doc-an-obj.fin-ext-doc-type  = parfin-ext-doc-type
      bfrb_arh-fin-doc-an-obj.fin-code-an-uchet = parfin-code-an-uchet
      bfrb_arh-fin-doc-an-obj.fin-code-cel-nazn = parfin-code-cel-nazn
      bfrb_arh-fin-doc-an-obj.fin-code-cor-acc  = parfin-code-cor-acc
      bfrb_arh-fin-doc-an-obj.calc-curr-code    = parbase-code
      bfrb_arh-fin-doc-an-obj.sum-type          = parsum-type
      bfrb_arh-fin-doc-an-obj.cource-des        = "b":u
      bfrb_arh-fin-doc-an-obj.fact-order        = parfact-order
      bfrb_arh-fin-doc-an-obj.fin-doc-code      = parfin-doc-code
      bfrb_arh-fin-doc-an-obj.fact-date         = parfact-date
      bfrb_arh-fin-doc-an-obj.curr-code         = parcurr-code
    .
    assign
      bfrb_arh-fin-doc-an-obj.expense           = (if available borb_arh-fin-doc-an-obj then borb_arh-fin-doc-an-obj.expense     else 0)
      bfrb_arh-fin-doc-an-obj.expense-vat       = (if available borb_arh-fin-doc-an-obj then borb_arh-fin-doc-an-obj.expense-vat else 0)
      bfrb_arh-fin-doc-an-obj.expense-slt       = (if available borb_arh-fin-doc-an-obj then borb_arh-fin-doc-an-obj.expense-slt else 0)
      bfrb_arh-fin-doc-an-obj.income            = (if available borb_arh-fin-doc-an-obj then borb_arh-fin-doc-an-obj.income      else 0) + parsum-base
      bfrb_arh-fin-doc-an-obj.income-vat        = (if available borb_arh-fin-doc-an-obj then borb_arh-fin-doc-an-obj.income-vat  else 0) + parsum-vat-base
      bfrb_arh-fin-doc-an-obj.income-slt        = (if available borb_arh-fin-doc-an-obj then borb_arh-fin-doc-an-obj.income-slt  else 0) + parsum-slt-base
    .
  end.
  else do:
    find last bfrb_arh-fin-doc-an-obj where bfrb_arh-fin-doc-an-obj.host-code         = parhost-code            and
                                            bfrb_arh-fin-doc-an-obj.obj-type          = parobj-type             and
                                            bfrb_arh-fin-doc-an-obj.obj-code          = parobj-code             and
                                            bfrb_arh-fin-doc-an-obj.cli-type          = parreceiver-type        and
                                            bfrb_arh-fin-doc-an-obj.cli-code          = parreceiver-code        and
                                            bfrb_arh-fin-doc-an-obj.code-schet        = parreceiver-code-schet  and
                                            bfrb_arh-fin-doc-an-obj.fin-ext-doc-type  = parfin-ext-doc-type     and
                                            bfrb_arh-fin-doc-an-obj.fin-code-an-uchet = parfin-code-an-uchet    and
                                            bfrb_arh-fin-doc-an-obj.fin-code-cel-nazn = parfin-code-cel-nazn    and
                                            bfrb_arh-fin-doc-an-obj.fin-code-cor-acc  = parfin-code-cor-acc     and
                                            bfrb_arh-fin-doc-an-obj.calc-curr-code    = parbase-code            and
                                            bfrb_arh-fin-doc-an-obj.sum-type          = parsum-type             and
                                            bfrb_arh-fin-doc-an-obj.fact-order        = parfact-order           exclusive-lock.
  end.
  for each rbfrb_arh-fin-doc-an-obj where rbfrb_arh-fin-doc-an-obj.host-code         = bfrb_arh-fin-doc-an-obj.host-code         and
                                          rbfrb_arh-fin-doc-an-obj.obj-type          = bfrb_arh-fin-doc-an-obj.obj-type          and
                                          rbfrb_arh-fin-doc-an-obj.obj-code          = bfrb_arh-fin-doc-an-obj.obj-code          and
                                          rbfrb_arh-fin-doc-an-obj.cli-type          = parreceiver-type                          and
                                          rbfrb_arh-fin-doc-an-obj.cli-code          = parreceiver-code                          and
                                          rbfrb_arh-fin-doc-an-obj.code-schet        = bfrb_arh-fin-doc-an-obj.code-schet        and
                                          rbfrb_arh-fin-doc-an-obj.fin-ext-doc-type  = bfrb_arh-fin-doc-an-obj.fin-ext-doc-type  and
                                          rbfrb_arh-fin-doc-an-obj.fin-code-an-uchet = bfrb_arh-fin-doc-an-obj.fin-code-an-uchet and
                                          rbfrb_arh-fin-doc-an-obj.fin-code-cel-nazn = bfrb_arh-fin-doc-an-obj.fin-code-cel-nazn and
                                          rbfrb_arh-fin-doc-an-obj.fin-code-cor-acc  = bfrb_arh-fin-doc-an-obj.fin-code-cor-acc  and
                                          rbfrb_arh-fin-doc-an-obj.calc-curr-code    = bfrb_arh-fin-doc-an-obj.calc-curr-code    and
                                          rbfrb_arh-fin-doc-an-obj.sum-type          = bfrb_arh-fin-doc-an-obj.sum-type          and
                                          rbfrb_arh-fin-doc-an-obj.fact-order        > bfrb_arh-fin-doc-an-obj.fact-order        on error undo, return error return-value :
    assign
      rbfrb_arh-fin-doc-an-obj.income      =  rbfrb_arh-fin-doc-an-obj.income     + parsum-base
      rbfrb_arh-fin-doc-an-obj.income-vat  =  rbfrb_arh-fin-doc-an-obj.income-vat + parsum-vat-base
      rbfrb_arh-fin-doc-an-obj.income-slt  =  rbfrb_arh-fin-doc-an-obj.income-slt + parsum-slt-base
    .
  end.
  if parmode = "delete":u then do:
    delete bfpb_arh-fin-doc-an-obj.
    delete bfrb_arh-fin-doc-an-obj.
  end.
end.
if parrel-dog-code  =  yes          and
   parcurr-dog-code <> parcurr-code and
   parcurr-dog-code <> 0            and
   parcurr-dog-code <> parbase-code then do:
  if parmode = "close":u then do:
    find last bopc_arh-fin-doc-an-obj where bopc_arh-fin-doc-an-obj.host-code         = parhost-code         and
                                            bopc_arh-fin-doc-an-obj.obj-type          = parobj-type          and
                                            bopc_arh-fin-doc-an-obj.obj-code          = parobj-code          and
                                            bopc_arh-fin-doc-an-obj.cli-type          = parpayer-type        and
                                            bopc_arh-fin-doc-an-obj.cli-code          = parpayer-code        and
                                            bopc_arh-fin-doc-an-obj.code-schet        = parpayer-code-schet  and
                                            bopc_arh-fin-doc-an-obj.fin-ext-doc-type  = parfin-ext-doc-type  and
                                            bopc_arh-fin-doc-an-obj.fin-code-an-uchet = parfin-code-an-uchet and
                                            bopc_arh-fin-doc-an-obj.fin-code-cel-nazn = parfin-code-cel-nazn and
                                            bopc_arh-fin-doc-an-obj.fin-code-cor-acc  = parfin-code-cor-acc  and
                                            bopc_arh-fin-doc-an-obj.calc-curr-code    = parcurr-dog-code     and
                                            bopc_arh-fin-doc-an-obj.sum-type          = parsum-type          and
                                            bopc_arh-fin-doc-an-obj.fact-order        < parfact-order        use-index pi no-error.
    create bfpc_arh-fin-doc-an-obj.
    assign
      bfpc_arh-fin-doc-an-obj.host-code         = parhost-code
      bfpc_arh-fin-doc-an-obj.obj-type          = parobj-type
      bfpc_arh-fin-doc-an-obj.obj-code          = parobj-code
      bfpc_arh-fin-doc-an-obj.cli-type          = parpayer-type
      bfpc_arh-fin-doc-an-obj.cli-code          = parpayer-code
      bfpc_arh-fin-doc-an-obj.code-schet        = parpayer-code-schet
      bfpc_arh-fin-doc-an-obj.fin-ext-doc-type  = parfin-ext-doc-type
      bfpc_arh-fin-doc-an-obj.fin-code-an-uchet = parfin-code-an-uchet
      bfpc_arh-fin-doc-an-obj.fin-code-cel-nazn = parfin-code-cel-nazn
      bfpc_arh-fin-doc-an-obj.fin-code-cor-acc  = parfin-code-cor-acc
      bfpc_arh-fin-doc-an-obj.calc-curr-code    = parcurr-dog-code
      bfpc_arh-fin-doc-an-obj.sum-type          = parsum-type
      bfpc_arh-fin-doc-an-obj.cource-des        = "c":u
      bfpc_arh-fin-doc-an-obj.fact-order        = parfact-order
      bfpc_arh-fin-doc-an-obj.fin-doc-code      = parfin-doc-code
      bfpc_arh-fin-doc-an-obj.fact-date         = parfact-date
      bfpc_arh-fin-doc-an-obj.curr-code         = parcurr-code
      bfpc_arh-fin-doc-an-obj.income            = (if available bopc_arh-fin-doc-an-obj then bopc_arh-fin-doc-an-obj.income      else 0)
      bfpc_arh-fin-doc-an-obj.income-vat        = (if available bopc_arh-fin-doc-an-obj then bopc_arh-fin-doc-an-obj.income-vat  else 0)
      bfpc_arh-fin-doc-an-obj.income-slt        = (if available bopc_arh-fin-doc-an-obj then bopc_arh-fin-doc-an-obj.income-slt  else 0)
      bfpc_arh-fin-doc-an-obj.expense           = (if available bopc_arh-fin-doc-an-obj then bopc_arh-fin-doc-an-obj.expense     else 0) + parsum-contr
      bfpc_arh-fin-doc-an-obj.expense-vat       = (if available bopc_arh-fin-doc-an-obj then bopc_arh-fin-doc-an-obj.expense-vat else 0) + parsum-vat-contr
      bfpc_arh-fin-doc-an-obj.expense-slt       = (if available bopc_arh-fin-doc-an-obj then bopc_arh-fin-doc-an-obj.expense-slt else 0) + parsum-slt-contr
    .
  end.
  else do:
    find first bfpc_arh-fin-doc-an-obj where bfpc_arh-fin-doc-an-obj.host-code         = parhost-code         and
                                             bfpc_arh-fin-doc-an-obj.obj-type          = parobj-type          and
                                             bfpc_arh-fin-doc-an-obj.obj-code          = parobj-code          and
                                             bfpc_arh-fin-doc-an-obj.cli-type          = parpayer-type        and
                                             bfpc_arh-fin-doc-an-obj.cli-code          = parpayer-code        and
                                             bfpc_arh-fin-doc-an-obj.code-schet        = parpayer-code-schet  and
                                             bfpc_arh-fin-doc-an-obj.fin-ext-doc-type  = parfin-ext-doc-type  and
                                             bfpc_arh-fin-doc-an-obj.fin-code-an-uchet = parfin-code-an-uchet and
                                             bfpc_arh-fin-doc-an-obj.fin-code-cel-nazn = parfin-code-cel-nazn and
                                             bfpc_arh-fin-doc-an-obj.fin-code-cor-acc  = parfin-code-cor-acc  and
                                             bfpc_arh-fin-doc-an-obj.calc-curr-code    = parcurr-dog-code     and
                                             bfpc_arh-fin-doc-an-obj.sum-type          = parsum-type          and
                                             bfpc_arh-fin-doc-an-obj.fact-order        = parfact-order        exclusive-lock.
  end.
  for each rbfpc_arh-fin-doc-an-obj where rbfpc_arh-fin-doc-an-obj.host-code         = bfpc_arh-fin-doc-an-obj.host-code         and
                                          rbfpc_arh-fin-doc-an-obj.obj-type          = bfpc_arh-fin-doc-an-obj.obj-type          and
                                          rbfpc_arh-fin-doc-an-obj.obj-code          = bfpc_arh-fin-doc-an-obj.obj-code          and
                                          rbfpc_arh-fin-doc-an-obj.cli-type          = parpayer-type                             and
                                          rbfpc_arh-fin-doc-an-obj.cli-code          = parpayer-code                             and
                                          rbfpc_arh-fin-doc-an-obj.code-schet        = bfpc_arh-fin-doc-an-obj.code-schet        and
                                          rbfpc_arh-fin-doc-an-obj.fin-ext-doc-type  = bfpc_arh-fin-doc-an-obj.fin-ext-doc-type  and
                                          rbfpc_arh-fin-doc-an-obj.fin-code-an-uchet = bfpc_arh-fin-doc-an-obj.fin-code-an-uchet and
                                          rbfpc_arh-fin-doc-an-obj.fin-code-cel-nazn = bfpc_arh-fin-doc-an-obj.fin-code-cel-nazn and
                                          rbfpc_arh-fin-doc-an-obj.fin-code-cor-acc  = bfpc_arh-fin-doc-an-obj.fin-code-cor-acc  and
                                          rbfpc_arh-fin-doc-an-obj.calc-curr-code    = bfpc_arh-fin-doc-an-obj.calc-curr-code    and
                                          rbfpc_arh-fin-doc-an-obj.sum-type          = bfpc_arh-fin-doc-an-obj.sum-type          and
                                          rbfpc_arh-fin-doc-an-obj.fact-order        > bfpc_arh-fin-doc-an-obj.fact-order        use-index pi on error undo, return error return-value :
    assign
      rbfpc_arh-fin-doc-an-obj.expense     = rbfpc_arh-fin-doc-an-obj.expense     + parsum-contr
      rbfpc_arh-fin-doc-an-obj.expense-vat = rbfpc_arh-fin-doc-an-obj.expense-vat + parsum-vat-contr
      rbfpc_arh-fin-doc-an-obj.expense-slt = rbfpc_arh-fin-doc-an-obj.expense-slt + parsum-slt-contr
    .
  end.
  if parmode = "close":u then do:
    find last borc_arh-fin-doc-an-obj where borc_arh-fin-doc-an-obj.host-code         = parhost-code            and
                                            borc_arh-fin-doc-an-obj.obj-type          = parobj-type             and
                                            borc_arh-fin-doc-an-obj.obj-code          = parobj-code             and
                                            borc_arh-fin-doc-an-obj.cli-type          = parreceiver-type        and
                                            borc_arh-fin-doc-an-obj.cli-code          = parreceiver-code        and
                                            borc_arh-fin-doc-an-obj.code-schet        = parreceiver-code-schet  and
                                            borc_arh-fin-doc-an-obj.fin-ext-doc-type  = parfin-ext-doc-type     and
                                            borc_arh-fin-doc-an-obj.fin-code-an-uchet = parfin-code-an-uchet    and
                                            borc_arh-fin-doc-an-obj.fin-code-cel-nazn = parfin-code-cel-nazn    and
                                            borc_arh-fin-doc-an-obj.fin-code-cor-acc  = parfin-code-cor-acc     and
                                            borc_arh-fin-doc-an-obj.calc-curr-code    = parcurr-dog-code        and
                                            borc_arh-fin-doc-an-obj.sum-type          = parsum-type             and
                                            borc_arh-fin-doc-an-obj.fact-order        < parfact-order           use-index pi no-error.
    create bfrc_arh-fin-doc-an-obj.
    assign
      bfrc_arh-fin-doc-an-obj.host-code         = parhost-code
      bfrc_arh-fin-doc-an-obj.obj-type          = parobj-type
      bfrc_arh-fin-doc-an-obj.obj-code          = parobj-code
      bfrc_arh-fin-doc-an-obj.cli-type          = parreceiver-type
      bfrc_arh-fin-doc-an-obj.cli-code          = parreceiver-code
      bfrc_arh-fin-doc-an-obj.code-schet        = parreceiver-code-schet
      bfrc_arh-fin-doc-an-obj.fin-ext-doc-type  = parfin-ext-doc-type
      bfrc_arh-fin-doc-an-obj.fin-code-an-uchet = parfin-code-an-uchet
      bfrc_arh-fin-doc-an-obj.fin-code-cel-nazn = parfin-code-cel-nazn
      bfrc_arh-fin-doc-an-obj.fin-code-cor-acc  = parfin-code-cor-acc
      bfrc_arh-fin-doc-an-obj.calc-curr-code    = parcurr-dog-code
      bfrc_arh-fin-doc-an-obj.sum-type          = parsum-type
      bfrc_arh-fin-doc-an-obj.cource-des        = "c":u
      bfrc_arh-fin-doc-an-obj.fact-order        = parfact-order
      bfrc_arh-fin-doc-an-obj.fin-doc-code      = parfin-doc-code
      bfrc_arh-fin-doc-an-obj.fact-date         = parfact-date
      bfrc_arh-fin-doc-an-obj.curr-code         = parcurr-code
    .
    assign
      bfrc_arh-fin-doc-an-obj.expense           = (if available borc_arh-fin-doc-an-obj then borc_arh-fin-doc-an-obj.expense     else 0)
      bfrc_arh-fin-doc-an-obj.expense-vat       = (if available borc_arh-fin-doc-an-obj then borc_arh-fin-doc-an-obj.expense-vat else 0)
      bfrc_arh-fin-doc-an-obj.expense-slt       = (if available borc_arh-fin-doc-an-obj then borc_arh-fin-doc-an-obj.expense-slt else 0)
      bfrc_arh-fin-doc-an-obj.income            = (if available borc_arh-fin-doc-an-obj then borc_arh-fin-doc-an-obj.income      else 0) + parsum-contr
      bfrc_arh-fin-doc-an-obj.income-vat        = (if available borc_arh-fin-doc-an-obj then borc_arh-fin-doc-an-obj.income-vat  else 0) + parsum-vat-contr
      bfrc_arh-fin-doc-an-obj.income-slt        = (if available borc_arh-fin-doc-an-obj then borc_arh-fin-doc-an-obj.income-slt  else 0) + parsum-slt-contr
    .
  end.
  else do:
    find first bfrc_arh-fin-doc-an-obj where bfrc_arh-fin-doc-an-obj.host-code         = parhost-code            and
                                             bfrc_arh-fin-doc-an-obj.obj-type          = parobj-type             and
                                             bfrc_arh-fin-doc-an-obj.obj-code          = parobj-code             and
                                             bfrc_arh-fin-doc-an-obj.cli-type          = parreceiver-type        and
                                             bfrc_arh-fin-doc-an-obj.cli-code          = parreceiver-code        and
                                             bfrc_arh-fin-doc-an-obj.code-schet        = parreceiver-code-schet  and
                                             bfrc_arh-fin-doc-an-obj.fin-ext-doc-type  = parfin-ext-doc-type     and
                                             bfrc_arh-fin-doc-an-obj.fin-code-an-uchet = parfin-code-an-uchet    and
                                             bfrc_arh-fin-doc-an-obj.fin-code-cel-nazn = parfin-code-cel-nazn    and
                                             bfrc_arh-fin-doc-an-obj.fin-code-cor-acc  = parfin-code-cor-acc     and
                                             bfrc_arh-fin-doc-an-obj.calc-curr-code    = parcurr-dog-code        and
                                             bfrc_arh-fin-doc-an-obj.sum-type          = parsum-type             and
                                             bfrc_arh-fin-doc-an-obj.fact-order        = parfact-order           exclusive-lock.
  end.
  for each rbfrc_arh-fin-doc-an-obj where rbfrc_arh-fin-doc-an-obj.host-code         = bfrc_arh-fin-doc-an-obj.host-code         and
                                          rbfrc_arh-fin-doc-an-obj.obj-type          = bfrc_arh-fin-doc-an-obj.obj-type          and
                                          rbfrc_arh-fin-doc-an-obj.obj-code          = bfrc_arh-fin-doc-an-obj.obj-code          and
                                          rbfrc_arh-fin-doc-an-obj.cli-type          = parreceiver-type                          and
                                          rbfrc_arh-fin-doc-an-obj.cli-code          = parreceiver-code                          and
                                          rbfrc_arh-fin-doc-an-obj.code-schet        = bfrc_arh-fin-doc-an-obj.code-schet        and
                                          rbfrc_arh-fin-doc-an-obj.fin-ext-doc-type  = bfrc_arh-fin-doc-an-obj.fin-ext-doc-type  and
                                          rbfrc_arh-fin-doc-an-obj.fin-code-an-uchet = bfrc_arh-fin-doc-an-obj.fin-code-an-uchet and
                                          rbfrc_arh-fin-doc-an-obj.fin-code-cel-nazn = bfrc_arh-fin-doc-an-obj.fin-code-cel-nazn and
                                          rbfrc_arh-fin-doc-an-obj.fin-code-cor-acc  = bfrc_arh-fin-doc-an-obj.fin-code-cor-acc  and
                                          rbfrc_arh-fin-doc-an-obj.calc-curr-code    = bfrc_arh-fin-doc-an-obj.calc-curr-code    and
                                          rbfrc_arh-fin-doc-an-obj.sum-type          = bfrc_arh-fin-doc-an-obj.sum-type          and
                                          rbfrc_arh-fin-doc-an-obj.fact-order        > bfrc_arh-fin-doc-an-obj.fact-order        use-index pi exclusive-lock on error undo, return error return-value :
    assign
      rbfrc_arh-fin-doc-an-obj.income     = rbfrc_arh-fin-doc-an-obj.income     + parsum-contr
      rbfrc_arh-fin-doc-an-obj.income-vat = rbfrc_arh-fin-doc-an-obj.income-vat + parsum-vat-contr
      rbfrc_arh-fin-doc-an-obj.income-slt = rbfrc_arh-fin-doc-an-obj.income-slt + parsum-slt-contr
    .
  end.
  if parmode = "delete":u then do:
    delete bfpc_arh-fin-doc-an-obj.
    delete bfrc_arh-fin-doc-an-obj.
  end.
end.
end.
end procedure.
procedure libfarpo_calc-arh-fin-doc-contr-schet-obj :
define input parameter parmode                    as   character                   no-undo.
define input parameter parhost-code               like ub.fin-doc.host-code        no-undo.
define input parameter parobj-type                like ub.fin-doc.obj-type         no-undo.
define input parameter parobj-code                like ub.fin-doc.obj-code         no-undo.
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
define buffer bfps_arh-fin-doc-contr-schet-obj for ub.arh-fin-doc-contr-schet-obj.
define buffer bfrs_arh-fin-doc-contr-schet-obj for ub.arh-fin-doc-contr-schet-obj.
define buffer rbfps_arh-fin-doc-contr-schet-ob for ub.arh-fin-doc-contr-schet-obj.
define buffer rbfrs_arh-fin-doc-contr-schet-ob for ub.arh-fin-doc-contr-schet-obj.
define buffer bops_arh-fin-doc-contr-schet-obj for ub.arh-fin-doc-contr-schet-obj.
define buffer bors_arh-fin-doc-contr-schet-obj for ub.arh-fin-doc-contr-schet-obj.
define buffer bfpr_arh-fin-doc-contr-schet-obj for ub.arh-fin-doc-contr-schet-obj.
define buffer bfrr_arh-fin-doc-contr-schet-obj for ub.arh-fin-doc-contr-schet-obj.
define buffer rbfpr_arh-fin-doc-contr-schet-ob for ub.arh-fin-doc-contr-schet-obj.
define buffer rbfrr_arh-fin-doc-contr-schet-ob for ub.arh-fin-doc-contr-schet-obj.
define buffer bopr_arh-fin-doc-contr-schet-obj for ub.arh-fin-doc-contr-schet-obj.
define buffer borr_arh-fin-doc-contr-schet-obj for ub.arh-fin-doc-contr-schet-obj.
define buffer bfpb_arh-fin-doc-contr-schet-obj for ub.arh-fin-doc-contr-schet-obj.
define buffer bfrb_arh-fin-doc-contr-schet-obj for ub.arh-fin-doc-contr-schet-obj.
define buffer rbfpb_arh-fin-doc-contr-schet-ob for ub.arh-fin-doc-contr-schet-obj.
define buffer rbfrb_arh-fin-doc-contr-schet-ob for ub.arh-fin-doc-contr-schet-obj.
define buffer bopb_arh-fin-doc-contr-schet-obj for ub.arh-fin-doc-contr-schet-obj.
define buffer borb_arh-fin-doc-contr-schet-obj for ub.arh-fin-doc-contr-schet-obj.
define buffer bfpc_arh-fin-doc-contr-schet-obj for ub.arh-fin-doc-contr-schet-obj.
define buffer bfrc_arh-fin-doc-contr-schet-obj for ub.arh-fin-doc-contr-schet-obj.
define buffer rbfpc_arh-fin-doc-contr-schet-ob for ub.arh-fin-doc-contr-schet-obj.
define buffer rbfrc_arh-fin-doc-contr-schet-ob for ub.arh-fin-doc-contr-schet-obj.
define buffer bopc_arh-fin-doc-contr-schet-obj for ub.arh-fin-doc-contr-schet-obj.
define buffer borc_arh-fin-doc-contr-schet-obj for ub.arh-fin-doc-contr-schet-obj.
do on error undo, return error substitute ("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
if parmode = "close":u then do:
  find last bops_arh-fin-doc-contr-schet-obj where bops_arh-fin-doc-contr-schet-obj.host-code        = parhost-code         and
                                                   bops_arh-fin-doc-contr-schet-obj.obj-type         = parobj-type          and
                                                   bops_arh-fin-doc-contr-schet-obj.obj-code         = parobj-code          and
                                                   bops_arh-fin-doc-contr-schet-obj.cli-type         = parpayer-type        and
                                                   bops_arh-fin-doc-contr-schet-obj.cli-code         = parpayer-code        and
                                                   bops_arh-fin-doc-contr-schet-obj.contract-code    = parcontract-code     and
                                                   bops_arh-fin-doc-contr-schet-obj.code-schet       = parpayer-code-schet  and
                                                   bops_arh-fin-doc-contr-schet-obj.fin-ext-doc-type = parfin-ext-doc-type  and
                                                   bops_arh-fin-doc-contr-schet-obj.calc-curr-code   = parcurr-code         and
                                                   bops_arh-fin-doc-contr-schet-obj.sum-type         = parsum-type          and
                                                   bops_arh-fin-doc-contr-schet-obj.fact-order       < parfact-order        use-index pi no-error.
  create bfps_arh-fin-doc-contr-schet-obj.
  assign
    bfps_arh-fin-doc-contr-schet-obj.host-code        = parhost-code
    bfps_arh-fin-doc-contr-schet-obj.obj-type         = parobj-type
    bfps_arh-fin-doc-contr-schet-obj.obj-code         = parobj-code
    bfps_arh-fin-doc-contr-schet-obj.cli-type         = parpayer-type
    bfps_arh-fin-doc-contr-schet-obj.cli-code         = parpayer-code
    bfps_arh-fin-doc-contr-schet-obj.contract-code    = parcontract-code
    bfps_arh-fin-doc-contr-schet-obj.code-schet       = parpayer-code-schet
    bfps_arh-fin-doc-contr-schet-obj.fin-ext-doc-type = parfin-ext-doc-type
    bfps_arh-fin-doc-contr-schet-obj.calc-curr-code   = parcurr-code
    bfps_arh-fin-doc-contr-schet-obj.sum-type         = parsum-type
    bfps_arh-fin-doc-contr-schet-obj.cource-des       = "s":u
    bfps_arh-fin-doc-contr-schet-obj.fact-order       = parfact-order
    bfps_arh-fin-doc-contr-schet-obj.fin-doc-code     = parfin-doc-code
    bfps_arh-fin-doc-contr-schet-obj.fact-date        = parfact-date
    bfps_arh-fin-doc-contr-schet-obj.curr-code        = parcurr-code
    bfps_arh-fin-doc-contr-schet-obj.income           = (if available bops_arh-fin-doc-contr-schet-obj then bops_arh-fin-doc-contr-schet-obj.income      else 0)
    bfps_arh-fin-doc-contr-schet-obj.income-vat       = (if available bops_arh-fin-doc-contr-schet-obj then bops_arh-fin-doc-contr-schet-obj.income-vat  else 0)
    bfps_arh-fin-doc-contr-schet-obj.income-slt       = (if available bops_arh-fin-doc-contr-schet-obj then bops_arh-fin-doc-contr-schet-obj.income-slt  else 0)
    bfps_arh-fin-doc-contr-schet-obj.expense          = (if available bops_arh-fin-doc-contr-schet-obj then bops_arh-fin-doc-contr-schet-obj.expense     else 0) + parsum-doc
    bfps_arh-fin-doc-contr-schet-obj.expense-vat      = (if available bops_arh-fin-doc-contr-schet-obj then bops_arh-fin-doc-contr-schet-obj.expense-vat else 0) + parsum-vat-doc
    bfps_arh-fin-doc-contr-schet-obj.expense-slt      = (if available bops_arh-fin-doc-contr-schet-obj then bops_arh-fin-doc-contr-schet-obj.expense-slt else 0) + parsum-slt-doc
  .
end.
else do:
  find first bfps_arh-fin-doc-contr-schet-obj where bfps_arh-fin-doc-contr-schet-obj.host-code        = parhost-code         and
                                                    bfps_arh-fin-doc-contr-schet-obj.obj-type         = parobj-type          and
                                                    bfps_arh-fin-doc-contr-schet-obj.obj-code         = parobj-code          and
                                                    bfps_arh-fin-doc-contr-schet-obj.cli-type         = parpayer-type        and
                                                    bfps_arh-fin-doc-contr-schet-obj.cli-code         = parpayer-code        and
                                                    bfps_arh-fin-doc-contr-schet-obj.contract-code    = parcontract-code     and
                                                    bfps_arh-fin-doc-contr-schet-obj.code-schet       = parpayer-code-schet  and
                                                    bfps_arh-fin-doc-contr-schet-obj.fin-ext-doc-type = parfin-ext-doc-type  and
                                                    bfps_arh-fin-doc-contr-schet-obj.calc-curr-code   = parcurr-code         and
                                                    bfps_arh-fin-doc-contr-schet-obj.sum-type         = parsum-type          and
                                                    bfps_arh-fin-doc-contr-schet-obj.fact-order       = parfact-order        exclusive-lock.
end.
for each rbfps_arh-fin-doc-contr-schet-ob where rbfps_arh-fin-doc-contr-schet-ob.host-code        = bfps_arh-fin-doc-contr-schet-obj.host-code        and
                                                rbfps_arh-fin-doc-contr-schet-ob.obj-type         = bfps_arh-fin-doc-contr-schet-obj.obj-type         and
                                                rbfps_arh-fin-doc-contr-schet-ob.obj-code         = bfps_arh-fin-doc-contr-schet-obj.obj-code         and
                                                rbfps_arh-fin-doc-contr-schet-ob.cli-type         = parpayer-type                                     and
                                                rbfps_arh-fin-doc-contr-schet-ob.cli-code         = parpayer-code                                     and
                                                rbfps_arh-fin-doc-contr-schet-ob.contract-code    = bfps_arh-fin-doc-contr-schet-obj.contract-code    and
                                                rbfps_arh-fin-doc-contr-schet-ob.code-schet       = bfps_arh-fin-doc-contr-schet-obj.code-schet       and
                                                rbfps_arh-fin-doc-contr-schet-ob.fin-ext-doc-type = bfps_arh-fin-doc-contr-schet-obj.fin-ext-doc-type and
                                                rbfps_arh-fin-doc-contr-schet-ob.calc-curr-code   = bfps_arh-fin-doc-contr-schet-obj.calc-curr-code   and
                                                rbfps_arh-fin-doc-contr-schet-ob.sum-type         = bfps_arh-fin-doc-contr-schet-obj.sum-type         and
                                                rbfps_arh-fin-doc-contr-schet-ob.fact-order       > bfps_arh-fin-doc-contr-schet-obj.fact-order       use-index pi exclusive-lock on error undo, return error return-value :
  assign
    rbfps_arh-fin-doc-contr-schet-ob.expense     = rbfps_arh-fin-doc-contr-schet-ob.expense     + parsum-doc
    rbfps_arh-fin-doc-contr-schet-ob.expense-vat = rbfps_arh-fin-doc-contr-schet-ob.expense-vat + parsum-vat-doc
    rbfps_arh-fin-doc-contr-schet-ob.expense-slt = rbfps_arh-fin-doc-contr-schet-ob.expense-slt + parsum-slt-doc
  .
end.
if parmode = "close":u then do:
  find last bors_arh-fin-doc-contr-schet-obj where bors_arh-fin-doc-contr-schet-obj.host-code        = parhost-code            and
                                                   bors_arh-fin-doc-contr-schet-obj.obj-type         = parobj-type             and
                                                   bors_arh-fin-doc-contr-schet-obj.obj-code         = parobj-code             and
                                                   bors_arh-fin-doc-contr-schet-obj.cli-type         = parreceiver-type        and
                                                   bors_arh-fin-doc-contr-schet-obj.cli-code         = parreceiver-code        and
                                                   bors_arh-fin-doc-contr-schet-obj.contract-code    = parcontract-code        and
                                                   bors_arh-fin-doc-contr-schet-obj.code-schet       = parreceiver-code-schet  and
                                                   bors_arh-fin-doc-contr-schet-obj.fin-ext-doc-type = parfin-ext-doc-type     and
                                                   bors_arh-fin-doc-contr-schet-obj.calc-curr-code   = parcurr-code            and
                                                   bors_arh-fin-doc-contr-schet-obj.sum-type         = parsum-type             and
                                                   bors_arh-fin-doc-contr-schet-obj.fact-order       < parfact-order           use-index pi no-error.
  create bfrs_arh-fin-doc-contr-schet-obj.
  assign
    bfrs_arh-fin-doc-contr-schet-obj.host-code        = parhost-code
    bfrs_arh-fin-doc-contr-schet-obj.obj-type         = parobj-type
    bfrs_arh-fin-doc-contr-schet-obj.obj-code         = parobj-code
    bfrs_arh-fin-doc-contr-schet-obj.cli-type         = parreceiver-type
    bfrs_arh-fin-doc-contr-schet-obj.cli-code         = parreceiver-code
    bfrs_arh-fin-doc-contr-schet-obj.contract-code    = parcontract-code
    bfrs_arh-fin-doc-contr-schet-obj.code-schet       = parreceiver-code-schet
    bfrs_arh-fin-doc-contr-schet-obj.fin-ext-doc-type = parfin-ext-doc-type
    bfrs_arh-fin-doc-contr-schet-obj.calc-curr-code   = parcurr-code
    bfrs_arh-fin-doc-contr-schet-obj.sum-type         = parsum-type
    bfrs_arh-fin-doc-contr-schet-obj.cource-des       = "s":u
    bfrs_arh-fin-doc-contr-schet-obj.fact-order       = parfact-order
    bfrs_arh-fin-doc-contr-schet-obj.fin-doc-code     = parfin-doc-code
    bfrs_arh-fin-doc-contr-schet-obj.fact-date        = parfact-date
    bfrs_arh-fin-doc-contr-schet-obj.curr-code        = parcurr-code
  .
  assign
    bfrs_arh-fin-doc-contr-schet-obj.expense          = (if available bors_arh-fin-doc-contr-schet-obj then bors_arh-fin-doc-contr-schet-obj.expense     else 0)
    bfrs_arh-fin-doc-contr-schet-obj.expense-vat      = (if available bors_arh-fin-doc-contr-schet-obj then bors_arh-fin-doc-contr-schet-obj.expense-vat else 0)
    bfrs_arh-fin-doc-contr-schet-obj.expense-slt      = (if available bors_arh-fin-doc-contr-schet-obj then bors_arh-fin-doc-contr-schet-obj.expense-slt else 0)
    bfrs_arh-fin-doc-contr-schet-obj.income           = (if available bors_arh-fin-doc-contr-schet-obj then bors_arh-fin-doc-contr-schet-obj.income      else 0) + parsum-doc
    bfrs_arh-fin-doc-contr-schet-obj.income-vat       = (if available bors_arh-fin-doc-contr-schet-obj then bors_arh-fin-doc-contr-schet-obj.income-vat  else 0) + parsum-vat-doc
    bfrs_arh-fin-doc-contr-schet-obj.income-slt       = (if available bors_arh-fin-doc-contr-schet-obj then bors_arh-fin-doc-contr-schet-obj.income-slt  else 0) + parsum-slt-doc
  .
end.
else do:
  find first bfrs_arh-fin-doc-contr-schet-obj where bfrs_arh-fin-doc-contr-schet-obj.host-code        = parhost-code            and
                                                    bfrs_arh-fin-doc-contr-schet-obj.obj-type         = parobj-type             and
                                                    bfrs_arh-fin-doc-contr-schet-obj.obj-code         = parobj-code             and
                                                    bfrs_arh-fin-doc-contr-schet-obj.cli-type         = parreceiver-type        and
                                                    bfrs_arh-fin-doc-contr-schet-obj.cli-code         = parreceiver-code        and
                                                    bfrs_arh-fin-doc-contr-schet-obj.contract-code    = parcontract-code        and
                                                    bfrs_arh-fin-doc-contr-schet-obj.code-schet       = parreceiver-code-schet  and
                                                    bfrs_arh-fin-doc-contr-schet-obj.fin-ext-doc-type = parfin-ext-doc-type     and
                                                    bfrs_arh-fin-doc-contr-schet-obj.calc-curr-code   = parcurr-code            and
                                                    bfrs_arh-fin-doc-contr-schet-obj.sum-type         = parsum-type             and
                                                    bfrs_arh-fin-doc-contr-schet-obj.fact-order       = parfact-order           exclusive-lock.
end.
for each rbfrs_arh-fin-doc-contr-schet-ob where rbfrs_arh-fin-doc-contr-schet-ob.host-code        = bfrs_arh-fin-doc-contr-schet-obj.host-code        and
                                                rbfrs_arh-fin-doc-contr-schet-ob.obj-type         = bfrs_arh-fin-doc-contr-schet-obj.obj-type         and
                                                rbfrs_arh-fin-doc-contr-schet-ob.obj-code         = bfrs_arh-fin-doc-contr-schet-obj.obj-code         and
                                                rbfrs_arh-fin-doc-contr-schet-ob.cli-type         = parreceiver-type                                  and
                                                rbfrs_arh-fin-doc-contr-schet-ob.cli-code         = parreceiver-code                                  and
                                                rbfrs_arh-fin-doc-contr-schet-ob.contract-code    = bfrs_arh-fin-doc-contr-schet-obj.contract-code    and
                                                rbfrs_arh-fin-doc-contr-schet-ob.code-schet       = bfrs_arh-fin-doc-contr-schet-obj.code-schet       and
                                                rbfrs_arh-fin-doc-contr-schet-ob.fin-ext-doc-type = bfrs_arh-fin-doc-contr-schet-obj.fin-ext-doc-type and
                                                rbfrs_arh-fin-doc-contr-schet-ob.calc-curr-code   = bfrs_arh-fin-doc-contr-schet-obj.calc-curr-code   and
                                                rbfrs_arh-fin-doc-contr-schet-ob.sum-type         = bfrs_arh-fin-doc-contr-schet-obj.sum-type         and
                                                rbfrs_arh-fin-doc-contr-schet-ob.fact-order       > bfrs_arh-fin-doc-contr-schet-obj.fact-order       use-index pi exclusive-lock on error undo, return error return-value :
  assign
    rbfrs_arh-fin-doc-contr-schet-ob.income     = rbfrs_arh-fin-doc-contr-schet-ob.income     + parsum-doc
    rbfrs_arh-fin-doc-contr-schet-ob.income-vat = rbfrs_arh-fin-doc-contr-schet-ob.income-vat + parsum-vat-doc
    rbfrs_arh-fin-doc-contr-schet-ob.income-slt = rbfrs_arh-fin-doc-contr-schet-ob.income-slt + parsum-slt-doc
  .
end.
if parmode = "delete":u then do:
  delete bfps_arh-fin-doc-contr-schet-obj.
  delete bfrs_arh-fin-doc-contr-schet-obj.
end.
if parcurr-code <> 0 then do:
  if parmode = "close":u then do:
    find last bopr_arh-fin-doc-contr-schet-obj where bopr_arh-fin-doc-contr-schet-obj.host-code        = parhost-code         and
                                                     bopr_arh-fin-doc-contr-schet-obj.obj-type         = parobj-type          and
                                                     bopr_arh-fin-doc-contr-schet-obj.obj-code         = parobj-code          and
                                                     bopr_arh-fin-doc-contr-schet-obj.cli-type         = parpayer-type        and
                                                     bopr_arh-fin-doc-contr-schet-obj.cli-code         = parpayer-code        and
                                                     bopr_arh-fin-doc-contr-schet-obj.contract-code    = parcontract-code     and
                                                     bopr_arh-fin-doc-contr-schet-obj.code-schet       = parpayer-code-schet  and
                                                     bopr_arh-fin-doc-contr-schet-obj.fin-ext-doc-type = parfin-ext-doc-type  and
                                                     bopr_arh-fin-doc-contr-schet-obj.calc-curr-code   = 0                    and
                                                     bopr_arh-fin-doc-contr-schet-obj.sum-type         = parsum-type          and
                                                     bopr_arh-fin-doc-contr-schet-obj.fact-order       < parfact-order        use-index pi no-error.
    create bfpr_arh-fin-doc-contr-schet-obj.
    assign
      bfpr_arh-fin-doc-contr-schet-obj.host-code        = parhost-code
      bfpr_arh-fin-doc-contr-schet-obj.obj-type         = parobj-type
      bfpr_arh-fin-doc-contr-schet-obj.obj-code         = parobj-code
      bfpr_arh-fin-doc-contr-schet-obj.cli-type         = parpayer-type
      bfpr_arh-fin-doc-contr-schet-obj.cli-code         = parpayer-code
      bfpr_arh-fin-doc-contr-schet-obj.contract-code    = parcontract-code
      bfpr_arh-fin-doc-contr-schet-obj.code-schet       = parpayer-code-schet
      bfpr_arh-fin-doc-contr-schet-obj.fin-ext-doc-type = parfin-ext-doc-type
      bfpr_arh-fin-doc-contr-schet-obj.calc-curr-code   = 0
      bfpr_arh-fin-doc-contr-schet-obj.sum-type         = parsum-type
      bfpr_arh-fin-doc-contr-schet-obj.cource-des       = "r":u
      bfpr_arh-fin-doc-contr-schet-obj.fact-order       = parfact-order
      bfpr_arh-fin-doc-contr-schet-obj.fin-doc-code     = parfin-doc-code
      bfpr_arh-fin-doc-contr-schet-obj.fact-date        = parfact-date
      bfpr_arh-fin-doc-contr-schet-obj.curr-code        = parcurr-code
      bfpr_arh-fin-doc-contr-schet-obj.income           = (if available bopr_arh-fin-doc-contr-schet-obj then bopr_arh-fin-doc-contr-schet-obj.income      else 0)
      bfpr_arh-fin-doc-contr-schet-obj.income-vat       = (if available bopr_arh-fin-doc-contr-schet-obj then bopr_arh-fin-doc-contr-schet-obj.income-vat  else 0)
      bfpr_arh-fin-doc-contr-schet-obj.income-slt       = (if available bopr_arh-fin-doc-contr-schet-obj then bopr_arh-fin-doc-contr-schet-obj.income-slt  else 0)
      bfpr_arh-fin-doc-contr-schet-obj.expense          = (if available bopr_arh-fin-doc-contr-schet-obj then bopr_arh-fin-doc-contr-schet-obj.expense     else 0) + parsum-rubl
      bfpr_arh-fin-doc-contr-schet-obj.expense-vat      = (if available bopr_arh-fin-doc-contr-schet-obj then bopr_arh-fin-doc-contr-schet-obj.expense-vat else 0) + parsum-vat-rubl
      bfpr_arh-fin-doc-contr-schet-obj.expense-slt      = (if available bopr_arh-fin-doc-contr-schet-obj then bopr_arh-fin-doc-contr-schet-obj.expense-slt else 0) + parsum-slt-rubl
    .
  end.
  else do:
    find first bfpr_arh-fin-doc-contr-schet-obj where bfpr_arh-fin-doc-contr-schet-obj.host-code        = parhost-code         and
                                                      bfpr_arh-fin-doc-contr-schet-obj.obj-type         = parobj-type          and
                                                      bfpr_arh-fin-doc-contr-schet-obj.obj-code         = parobj-code          and
                                                      bfpr_arh-fin-doc-contr-schet-obj.cli-type         = parpayer-type        and
                                                      bfpr_arh-fin-doc-contr-schet-obj.cli-code         = parpayer-code        and
                                                      bfpr_arh-fin-doc-contr-schet-obj.contract-code    = parcontract-code     and
                                                      bfpr_arh-fin-doc-contr-schet-obj.code-schet       = parpayer-code-schet  and
                                                      bfpr_arh-fin-doc-contr-schet-obj.fin-ext-doc-type = parfin-ext-doc-type  and
                                                      bfpr_arh-fin-doc-contr-schet-obj.calc-curr-code   = 0                    and
                                                      bfpr_arh-fin-doc-contr-schet-obj.sum-type         = parsum-type          and
                                                      bfpr_arh-fin-doc-contr-schet-obj.fact-order       = parfact-order        exclusive-lock.
  end.
  for each rbfpr_arh-fin-doc-contr-schet-ob where rbfpr_arh-fin-doc-contr-schet-ob.host-code        = bfpr_arh-fin-doc-contr-schet-obj.host-code        and
                                                  rbfpr_arh-fin-doc-contr-schet-ob.obj-type         = bfpr_arh-fin-doc-contr-schet-obj.obj-type         and
                                                  rbfpr_arh-fin-doc-contr-schet-ob.obj-code         = bfpr_arh-fin-doc-contr-schet-obj.obj-code         and
                                                  rbfpr_arh-fin-doc-contr-schet-ob.cli-type         = parpayer-type                                     and
                                                  rbfpr_arh-fin-doc-contr-schet-ob.cli-code         = parpayer-code                                     and
                                                  rbfpr_arh-fin-doc-contr-schet-ob.contract-code    = bfpr_arh-fin-doc-contr-schet-obj.contract-code    and
                                                  rbfpr_arh-fin-doc-contr-schet-ob.code-schet       = bfpr_arh-fin-doc-contr-schet-obj.code-schet       and
                                                  rbfpr_arh-fin-doc-contr-schet-ob.fin-ext-doc-type = bfpr_arh-fin-doc-contr-schet-obj.fin-ext-doc-type and
                                                  rbfpr_arh-fin-doc-contr-schet-ob.calc-curr-code   = bfpr_arh-fin-doc-contr-schet-obj.calc-curr-code   and
                                                  rbfpr_arh-fin-doc-contr-schet-ob.sum-type         = bfpr_arh-fin-doc-contr-schet-obj.sum-type         and
                                                  rbfpr_arh-fin-doc-contr-schet-ob.fact-order       > bfpr_arh-fin-doc-contr-schet-obj.fact-order       use-index pi exclusive-lock on error undo, return error return-value :
    assign
      rbfpr_arh-fin-doc-contr-schet-ob.expense     = rbfpr_arh-fin-doc-contr-schet-ob.expense     + parsum-rubl
      rbfpr_arh-fin-doc-contr-schet-ob.expense-vat = rbfpr_arh-fin-doc-contr-schet-ob.expense-vat + parsum-vat-rubl
      rbfpr_arh-fin-doc-contr-schet-ob.expense-slt = rbfpr_arh-fin-doc-contr-schet-ob.expense-slt + parsum-slt-rubl
    .
  end.
  if parmode = "close":u then do:
    find last borr_arh-fin-doc-contr-schet-obj where borr_arh-fin-doc-contr-schet-obj.host-code        = parhost-code            and
                                                     borr_arh-fin-doc-contr-schet-obj.obj-type         = parobj-type             and
                                                     borr_arh-fin-doc-contr-schet-obj.obj-code         = parobj-code             and
                                                     borr_arh-fin-doc-contr-schet-obj.cli-type         = parreceiver-type        and
                                                     borr_arh-fin-doc-contr-schet-obj.cli-code         = parreceiver-code        and
                                                     borr_arh-fin-doc-contr-schet-obj.contract-code    = parcontract-code        and
                                                     borr_arh-fin-doc-contr-schet-obj.code-schet       = parreceiver-code-schet  and
                                                     borr_arh-fin-doc-contr-schet-obj.fin-ext-doc-type = parfin-ext-doc-type     and
                                                     borr_arh-fin-doc-contr-schet-obj.calc-curr-code   = 0                       and
                                                     borr_arh-fin-doc-contr-schet-obj.sum-type         = parsum-type             and
                                                     borr_arh-fin-doc-contr-schet-obj.fact-order       < parfact-order           use-index pi no-error.
    create bfrr_arh-fin-doc-contr-schet-obj.
    assign
      bfrr_arh-fin-doc-contr-schet-obj.host-code        = parhost-code
      bfrr_arh-fin-doc-contr-schet-obj.obj-type         = parobj-type
      bfrr_arh-fin-doc-contr-schet-obj.obj-code         = parobj-code
      bfrr_arh-fin-doc-contr-schet-obj.cli-type         = parreceiver-type
      bfrr_arh-fin-doc-contr-schet-obj.cli-code         = parreceiver-code
      bfrr_arh-fin-doc-contr-schet-obj.contract-code    = parcontract-code
      bfrr_arh-fin-doc-contr-schet-obj.code-schet       = parreceiver-code-schet
      bfrr_arh-fin-doc-contr-schet-obj.fin-ext-doc-type = parfin-ext-doc-type
      bfrr_arh-fin-doc-contr-schet-obj.calc-curr-code   = 0
      bfrr_arh-fin-doc-contr-schet-obj.sum-type         = parsum-type
      bfrr_arh-fin-doc-contr-schet-obj.cource-des       = "r":u
      bfrr_arh-fin-doc-contr-schet-obj.fact-order       = parfact-order
      bfrr_arh-fin-doc-contr-schet-obj.fin-doc-code     = parfin-doc-code
      bfrr_arh-fin-doc-contr-schet-obj.fact-date        = parfact-date
      bfrr_arh-fin-doc-contr-schet-obj.curr-code        = parcurr-code
      .
    assign
      bfrr_arh-fin-doc-contr-schet-obj.expense          = (if available borr_arh-fin-doc-contr-schet-obj then borr_arh-fin-doc-contr-schet-obj.expense     else 0)
      bfrr_arh-fin-doc-contr-schet-obj.expense-vat      = (if available borr_arh-fin-doc-contr-schet-obj then borr_arh-fin-doc-contr-schet-obj.expense-vat else 0)
      bfrr_arh-fin-doc-contr-schet-obj.expense-slt      = (if available borr_arh-fin-doc-contr-schet-obj then borr_arh-fin-doc-contr-schet-obj.expense-slt else 0)
      bfrr_arh-fin-doc-contr-schet-obj.income           = (if available borr_arh-fin-doc-contr-schet-obj then borr_arh-fin-doc-contr-schet-obj.income      else 0) + parsum-rubl
      bfrr_arh-fin-doc-contr-schet-obj.income-vat       = (if available borr_arh-fin-doc-contr-schet-obj then borr_arh-fin-doc-contr-schet-obj.income-vat  else 0) + parsum-vat-rubl
      bfrr_arh-fin-doc-contr-schet-obj.income-slt       = (if available borr_arh-fin-doc-contr-schet-obj then borr_arh-fin-doc-contr-schet-obj.income-slt  else 0) + parsum-slt-rubl
    .
  end.
  else do:
    find first bfrr_arh-fin-doc-contr-schet-obj where bfrr_arh-fin-doc-contr-schet-obj.host-code        = parhost-code            and
                                                      bfrr_arh-fin-doc-contr-schet-obj.obj-type         = parobj-type             and
                                                      bfrr_arh-fin-doc-contr-schet-obj.obj-code         = parobj-code             and
                                                      bfrr_arh-fin-doc-contr-schet-obj.cli-type         = parreceiver-type        and
                                                      bfrr_arh-fin-doc-contr-schet-obj.cli-code         = parreceiver-code        and
                                                      bfrr_arh-fin-doc-contr-schet-obj.contract-code    = parcontract-code        and
                                                      bfrr_arh-fin-doc-contr-schet-obj.code-schet       = parreceiver-code-schet  and
                                                      bfrr_arh-fin-doc-contr-schet-obj.fin-ext-doc-type = parfin-ext-doc-type     and
                                                      bfrr_arh-fin-doc-contr-schet-obj.calc-curr-code   = 0                       and
                                                      bfrr_arh-fin-doc-contr-schet-obj.sum-type         = parsum-type             and
                                                      bfrr_arh-fin-doc-contr-schet-obj.fact-order       = parfact-order           exclusive-lock.
  end.
  for each rbfrr_arh-fin-doc-contr-schet-ob where rbfrr_arh-fin-doc-contr-schet-ob.host-code        = bfrr_arh-fin-doc-contr-schet-obj.host-code        and
                                                  rbfrr_arh-fin-doc-contr-schet-ob.obj-type         = bfrr_arh-fin-doc-contr-schet-obj.obj-type         and
                                                  rbfrr_arh-fin-doc-contr-schet-ob.obj-code         = bfrr_arh-fin-doc-contr-schet-obj.obj-code         and
                                                  rbfrr_arh-fin-doc-contr-schet-ob.cli-type         = parreceiver-type                                  and
                                                  rbfrr_arh-fin-doc-contr-schet-ob.cli-code         = parreceiver-code                                  and
                                                  rbfrr_arh-fin-doc-contr-schet-ob.contract-code    = bfrr_arh-fin-doc-contr-schet-obj.contract-code    and
                                                  rbfrr_arh-fin-doc-contr-schet-ob.code-schet       = bfrr_arh-fin-doc-contr-schet-obj.code-schet       and
                                                  rbfrr_arh-fin-doc-contr-schet-ob.fin-ext-doc-type = bfrr_arh-fin-doc-contr-schet-obj.fin-ext-doc-type and
                                                  rbfrr_arh-fin-doc-contr-schet-ob.calc-curr-code   = bfrr_arh-fin-doc-contr-schet-obj.calc-curr-code   and
                                                  rbfrr_arh-fin-doc-contr-schet-ob.sum-type         = bfrr_arh-fin-doc-contr-schet-obj.sum-type         and
                                                  rbfrr_arh-fin-doc-contr-schet-ob.fact-order       > bfrr_arh-fin-doc-contr-schet-obj.fact-order       use-index pi exclusive-lock on error undo, return error return-value :
    assign
      rbfrr_arh-fin-doc-contr-schet-ob.income     = rbfrr_arh-fin-doc-contr-schet-ob.income     + parsum-rubl
      rbfrr_arh-fin-doc-contr-schet-ob.income-vat = rbfrr_arh-fin-doc-contr-schet-ob.income-vat + parsum-vat-rubl
      rbfrr_arh-fin-doc-contr-schet-ob.income-slt = rbfrr_arh-fin-doc-contr-schet-ob.income-slt + parsum-slt-rubl
    .
  end.
  if parmode = "delete":u then do:
    delete bfpr_arh-fin-doc-contr-schet-obj.
    delete bfrr_arh-fin-doc-contr-schet-obj.
  end.
end.
if parbase-code <> parcurr-code and
   parbase-code <> 0            then do:
  if parmode = "close":u then do:
    find last bopb_arh-fin-doc-contr-schet-obj where bopb_arh-fin-doc-contr-schet-obj.host-code        = parhost-code         and
                                                     bopb_arh-fin-doc-contr-schet-obj.obj-type         = parobj-type          and
                                                     bopb_arh-fin-doc-contr-schet-obj.obj-code         = parobj-code          and
                                                     bopb_arh-fin-doc-contr-schet-obj.cli-type         = parpayer-type        and
                                                     bopb_arh-fin-doc-contr-schet-obj.cli-code         = parpayer-code        and
                                                     bopb_arh-fin-doc-contr-schet-obj.contract-code    = parcontract-code     and
                                                     bopb_arh-fin-doc-contr-schet-obj.code-schet       = parpayer-code-schet  and
                                                     bopb_arh-fin-doc-contr-schet-obj.fin-ext-doc-type = parfin-ext-doc-type  and
                                                     bopb_arh-fin-doc-contr-schet-obj.calc-curr-code   = parbase-code         and
                                                     bopb_arh-fin-doc-contr-schet-obj.sum-type         = parsum-type          and
                                                     bopb_arh-fin-doc-contr-schet-obj.fact-order       < parfact-order        use-index pi no-error.
    create bfpb_arh-fin-doc-contr-schet-obj.
    assign
      bfpb_arh-fin-doc-contr-schet-obj.host-code        = parhost-code
      bfpb_arh-fin-doc-contr-schet-obj.obj-type         = parobj-type
      bfpb_arh-fin-doc-contr-schet-obj.obj-code         = parobj-code
      bfpb_arh-fin-doc-contr-schet-obj.cli-type         = parpayer-type
      bfpb_arh-fin-doc-contr-schet-obj.cli-code         = parpayer-code
      bfpb_arh-fin-doc-contr-schet-obj.contract-code    = parcontract-code
      bfpb_arh-fin-doc-contr-schet-obj.code-schet       = parpayer-code-schet
      bfpb_arh-fin-doc-contr-schet-obj.fin-ext-doc-type = parfin-ext-doc-type
      bfpb_arh-fin-doc-contr-schet-obj.calc-curr-code   = parbase-code
      bfpb_arh-fin-doc-contr-schet-obj.sum-type         = parsum-type
      bfpb_arh-fin-doc-contr-schet-obj.cource-des       = "b":u
      bfpb_arh-fin-doc-contr-schet-obj.fact-order       = parfact-order
      bfpb_arh-fin-doc-contr-schet-obj.fin-doc-code     = parfin-doc-code
      bfpb_arh-fin-doc-contr-schet-obj.fact-date        = parfact-date
      bfpb_arh-fin-doc-contr-schet-obj.curr-code        = parcurr-code
      bfpb_arh-fin-doc-contr-schet-obj.income           = (if available bopb_arh-fin-doc-contr-schet-obj then bopb_arh-fin-doc-contr-schet-obj.income      else 0)
      bfpb_arh-fin-doc-contr-schet-obj.income-vat       = (if available bopb_arh-fin-doc-contr-schet-obj then bopb_arh-fin-doc-contr-schet-obj.income-vat  else 0)
      bfpb_arh-fin-doc-contr-schet-obj.income-slt       = (if available bopb_arh-fin-doc-contr-schet-obj then bopb_arh-fin-doc-contr-schet-obj.income-slt  else 0)
      bfpb_arh-fin-doc-contr-schet-obj.expense          = (if available bopb_arh-fin-doc-contr-schet-obj then bopb_arh-fin-doc-contr-schet-obj.expense     else 0) + parsum-base
      bfpb_arh-fin-doc-contr-schet-obj.expense-vat      = (if available bopb_arh-fin-doc-contr-schet-obj then bopb_arh-fin-doc-contr-schet-obj.expense-vat else 0) + parsum-vat-base
      bfpb_arh-fin-doc-contr-schet-obj.expense-slt      = (if available bopb_arh-fin-doc-contr-schet-obj then bopb_arh-fin-doc-contr-schet-obj.expense-slt else 0) + parsum-slt-base
    .
  end.
  else do:
    find first bfpb_arh-fin-doc-contr-schet-obj where bfpb_arh-fin-doc-contr-schet-obj.host-code        = parhost-code         and
                                                      bfpb_arh-fin-doc-contr-schet-obj.obj-type         = parobj-type          and
                                                      bfpb_arh-fin-doc-contr-schet-obj.obj-code         = parobj-code          and
                                                      bfpb_arh-fin-doc-contr-schet-obj.cli-type         = parpayer-type        and
                                                      bfpb_arh-fin-doc-contr-schet-obj.cli-code         = parpayer-code        and
                                                      bfpb_arh-fin-doc-contr-schet-obj.contract-code    = parcontract-code     and
                                                      bfpb_arh-fin-doc-contr-schet-obj.code-schet       = parpayer-code-schet  and
                                                      bfpb_arh-fin-doc-contr-schet-obj.fin-ext-doc-type = parfin-ext-doc-type  and
                                                      bfpb_arh-fin-doc-contr-schet-obj.calc-curr-code   = parbase-code         and
                                                      bfpb_arh-fin-doc-contr-schet-obj.sum-type         = parsum-type          and
                                                      bfpb_arh-fin-doc-contr-schet-obj.fact-order       = parfact-order        exclusive-lock.
  end.
  for each rbfpb_arh-fin-doc-contr-schet-ob where rbfpb_arh-fin-doc-contr-schet-ob.host-code        = bfpb_arh-fin-doc-contr-schet-obj.host-code        and
                                                  rbfpb_arh-fin-doc-contr-schet-ob.obj-type         = bfpb_arh-fin-doc-contr-schet-obj.obj-type         and
                                                  rbfpb_arh-fin-doc-contr-schet-ob.obj-code         = bfpb_arh-fin-doc-contr-schet-obj.obj-code         and
                                                  rbfpb_arh-fin-doc-contr-schet-ob.cli-type         = parpayer-type                                     and
                                                  rbfpb_arh-fin-doc-contr-schet-ob.cli-code         = parpayer-code                                     and
                                                  rbfpb_arh-fin-doc-contr-schet-ob.contract-code    = bfpb_arh-fin-doc-contr-schet-obj.contract-code    and
                                                  rbfpb_arh-fin-doc-contr-schet-ob.code-schet       = bfpb_arh-fin-doc-contr-schet-obj.code-schet       and
                                                  rbfpb_arh-fin-doc-contr-schet-ob.fin-ext-doc-type = bfpb_arh-fin-doc-contr-schet-obj.fin-ext-doc-type and
                                                  rbfpb_arh-fin-doc-contr-schet-ob.calc-curr-code   = bfpb_arh-fin-doc-contr-schet-obj.calc-curr-code   and
                                                  rbfpb_arh-fin-doc-contr-schet-ob.sum-type         = bfpb_arh-fin-doc-contr-schet-obj.sum-type         and
                                                  rbfpb_arh-fin-doc-contr-schet-ob.fact-order       > bfpb_arh-fin-doc-contr-schet-obj.fact-order       use-index pi exclusive-lock on error undo, return error return-value :
    assign
      rbfpb_arh-fin-doc-contr-schet-ob.expense     = rbfpb_arh-fin-doc-contr-schet-ob.expense     + parsum-base
      rbfpb_arh-fin-doc-contr-schet-ob.expense-vat = rbfpb_arh-fin-doc-contr-schet-ob.expense-vat + parsum-vat-base
      rbfpb_arh-fin-doc-contr-schet-ob.expense-slt = rbfpb_arh-fin-doc-contr-schet-ob.expense-slt + parsum-slt-base
    .
  end.
  if parmode = "close":u then do:
    find last borb_arh-fin-doc-contr-schet-obj where borb_arh-fin-doc-contr-schet-obj.host-code        = parhost-code            and
                                                     borb_arh-fin-doc-contr-schet-obj.obj-type         = parobj-type             and
                                                     borb_arh-fin-doc-contr-schet-obj.obj-code         = parobj-code             and
                                                     borb_arh-fin-doc-contr-schet-obj.cli-type         = parreceiver-type        and
                                                     borb_arh-fin-doc-contr-schet-obj.cli-code         = parreceiver-code        and
                                                     borb_arh-fin-doc-contr-schet-obj.contract-code    = parcontract-code        and
                                                     borb_arh-fin-doc-contr-schet-obj.code-schet       = parreceiver-code-schet  and
                                                     borb_arh-fin-doc-contr-schet-obj.fin-ext-doc-type = parfin-ext-doc-type     and
                                                     borb_arh-fin-doc-contr-schet-obj.calc-curr-code   = parbase-code            and
                                                     borb_arh-fin-doc-contr-schet-obj.sum-type         = parsum-type             and
                                                     borb_arh-fin-doc-contr-schet-obj.fact-order       < parfact-order           use-index pi no-error.
    create bfrb_arh-fin-doc-contr-schet-obj.
    assign
      bfrb_arh-fin-doc-contr-schet-obj.host-code        = parhost-code
      bfrb_arh-fin-doc-contr-schet-obj.obj-type         = parobj-type
      bfrb_arh-fin-doc-contr-schet-obj.obj-code         = parobj-code
      bfrb_arh-fin-doc-contr-schet-obj.cli-type         = parreceiver-type
      bfrb_arh-fin-doc-contr-schet-obj.cli-code         = parreceiver-code
      bfrb_arh-fin-doc-contr-schet-obj.contract-code    = parcontract-code
      bfrb_arh-fin-doc-contr-schet-obj.code-schet       = parreceiver-code-schet
      bfrb_arh-fin-doc-contr-schet-obj.fin-ext-doc-type = parfin-ext-doc-type
      bfrb_arh-fin-doc-contr-schet-obj.calc-curr-code   = parbase-code
      bfrb_arh-fin-doc-contr-schet-obj.sum-type         = parsum-type
      bfrb_arh-fin-doc-contr-schet-obj.cource-des       = "b":u
      bfrb_arh-fin-doc-contr-schet-obj.fact-order       = parfact-order
      bfrb_arh-fin-doc-contr-schet-obj.fin-doc-code     = parfin-doc-code
      bfrb_arh-fin-doc-contr-schet-obj.fact-date        = parfact-date
      bfrb_arh-fin-doc-contr-schet-obj.curr-code        = parcurr-code
    .
    assign
      bfrb_arh-fin-doc-contr-schet-obj.expense          = (if available borb_arh-fin-doc-contr-schet-obj then borb_arh-fin-doc-contr-schet-obj.expense     else 0)
      bfrb_arh-fin-doc-contr-schet-obj.expense-vat      = (if available borb_arh-fin-doc-contr-schet-obj then borb_arh-fin-doc-contr-schet-obj.expense-vat else 0)
      bfrb_arh-fin-doc-contr-schet-obj.expense-slt      = (if available borb_arh-fin-doc-contr-schet-obj then borb_arh-fin-doc-contr-schet-obj.expense-slt else 0)
      bfrb_arh-fin-doc-contr-schet-obj.income           = (if available borb_arh-fin-doc-contr-schet-obj then borb_arh-fin-doc-contr-schet-obj.income      else 0) + parsum-base
      bfrb_arh-fin-doc-contr-schet-obj.income-vat       = (if available borb_arh-fin-doc-contr-schet-obj then borb_arh-fin-doc-contr-schet-obj.income-vat  else 0) + parsum-vat-base
      bfrb_arh-fin-doc-contr-schet-obj.income-slt       = (if available borb_arh-fin-doc-contr-schet-obj then borb_arh-fin-doc-contr-schet-obj.income-slt  else 0) + parsum-slt-base
    .
  end.
  else do:
    find first bfrb_arh-fin-doc-contr-schet-obj where bfrb_arh-fin-doc-contr-schet-obj.host-code        = parhost-code            and
                                                      bfrb_arh-fin-doc-contr-schet-obj.obj-type         = parobj-type             and
                                                      bfrb_arh-fin-doc-contr-schet-obj.obj-code         = parobj-code             and
                                                      bfrb_arh-fin-doc-contr-schet-obj.cli-type         = parreceiver-type        and
                                                      bfrb_arh-fin-doc-contr-schet-obj.cli-code         = parreceiver-code        and
                                                      bfrb_arh-fin-doc-contr-schet-obj.contract-code    = parcontract-code        and
                                                      bfrb_arh-fin-doc-contr-schet-obj.code-schet       = parreceiver-code-schet  and
                                                      bfrb_arh-fin-doc-contr-schet-obj.fin-ext-doc-type = parfin-ext-doc-type     and
                                                      bfrb_arh-fin-doc-contr-schet-obj.calc-curr-code   = parbase-code            and
                                                      bfrb_arh-fin-doc-contr-schet-obj.sum-type         = parsum-type             and
                                                      bfrb_arh-fin-doc-contr-schet-obj.fact-order       = parfact-order           exclusive-lock.
  end.
  for each rbfrb_arh-fin-doc-contr-schet-ob where rbfrb_arh-fin-doc-contr-schet-ob.host-code        = bfrb_arh-fin-doc-contr-schet-obj.host-code        and
                                                  rbfrb_arh-fin-doc-contr-schet-ob.obj-type         = bfrb_arh-fin-doc-contr-schet-obj.obj-type         and
                                                  rbfrb_arh-fin-doc-contr-schet-ob.obj-code         = bfrb_arh-fin-doc-contr-schet-obj.obj-code         and
                                                  rbfrb_arh-fin-doc-contr-schet-ob.cli-type         = parreceiver-type                                  and
                                                  rbfrb_arh-fin-doc-contr-schet-ob.cli-code         = parreceiver-code                                  and
                                                  rbfrb_arh-fin-doc-contr-schet-ob.contract-code    = bfrb_arh-fin-doc-contr-schet-obj.contract-code    and
                                                  rbfrb_arh-fin-doc-contr-schet-ob.code-schet       = bfrb_arh-fin-doc-contr-schet-obj.code-schet       and
                                                  rbfrb_arh-fin-doc-contr-schet-ob.fin-ext-doc-type = bfrb_arh-fin-doc-contr-schet-obj.fin-ext-doc-type and
                                                  rbfrb_arh-fin-doc-contr-schet-ob.calc-curr-code   = bfrb_arh-fin-doc-contr-schet-obj.calc-curr-code   and
                                                  rbfrb_arh-fin-doc-contr-schet-ob.sum-type         = bfrb_arh-fin-doc-contr-schet-obj.sum-type         and
                                                  rbfrb_arh-fin-doc-contr-schet-ob.fact-order       > bfrb_arh-fin-doc-contr-schet-obj.fact-order       use-index pi exclusive-lock on error undo, return error return-value :
    assign
      rbfrb_arh-fin-doc-contr-schet-ob.income     = rbfrb_arh-fin-doc-contr-schet-ob.income     + parsum-base
      rbfrb_arh-fin-doc-contr-schet-ob.income-vat = rbfrb_arh-fin-doc-contr-schet-ob.income-vat + parsum-vat-base
      rbfrb_arh-fin-doc-contr-schet-ob.income-slt = rbfrb_arh-fin-doc-contr-schet-ob.income-slt + parsum-slt-base
    .
  end.
  if parmode = "delete":u then do:
    delete bfpb_arh-fin-doc-contr-schet-obj.
    delete bfrb_arh-fin-doc-contr-schet-obj.
  end.
end.
if parrel-dog-code  =  yes          and
   parcurr-dog-code <> parcurr-code and
   parcurr-dog-code <> 0            and
   parcurr-dog-code <> parbase-code then do:
  if parmode = "close":u then do:
    find last bopc_arh-fin-doc-contr-schet-obj where bopc_arh-fin-doc-contr-schet-obj.host-code        = parhost-code         and
                                                     bopc_arh-fin-doc-contr-schet-obj.obj-type         = parobj-type          and
                                                     bopc_arh-fin-doc-contr-schet-obj.obj-code         = parobj-code          and
                                                     bopc_arh-fin-doc-contr-schet-obj.cli-type         = parpayer-type        and
                                                     bopc_arh-fin-doc-contr-schet-obj.cli-code         = parpayer-code        and
                                                     bopc_arh-fin-doc-contr-schet-obj.contract-code    = parcontract-code     and
                                                     bopc_arh-fin-doc-contr-schet-obj.code-schet       = parpayer-code-schet  and
                                                     bopc_arh-fin-doc-contr-schet-obj.fin-ext-doc-type = parfin-ext-doc-type  and
                                                     bopc_arh-fin-doc-contr-schet-obj.calc-curr-code   = parcurr-dog-code     and
                                                     bopc_arh-fin-doc-contr-schet-obj.sum-type         = parsum-type          and
                                                     bopc_arh-fin-doc-contr-schet-obj.fact-order       < parfact-order        use-index pi no-error.
    create bfpc_arh-fin-doc-contr-schet-obj.
    assign
      bfpc_arh-fin-doc-contr-schet-obj.host-code        = parhost-code
      bfpc_arh-fin-doc-contr-schet-obj.obj-type         = parobj-type
      bfpc_arh-fin-doc-contr-schet-obj.obj-code         = parobj-code
      bfpc_arh-fin-doc-contr-schet-obj.cli-type         = parpayer-type
      bfpc_arh-fin-doc-contr-schet-obj.cli-code         = parpayer-code
      bfpc_arh-fin-doc-contr-schet-obj.contract-code    = parcontract-code
      bfpc_arh-fin-doc-contr-schet-obj.code-schet       = parpayer-code-schet
      bfpc_arh-fin-doc-contr-schet-obj.fin-ext-doc-type = parfin-ext-doc-type
      bfpc_arh-fin-doc-contr-schet-obj.calc-curr-code   = parcurr-dog-code
      bfpc_arh-fin-doc-contr-schet-obj.sum-type         = parsum-type
      bfpc_arh-fin-doc-contr-schet-obj.cource-des       = "c":u
      bfpc_arh-fin-doc-contr-schet-obj.fact-order       = parfact-order
      bfpc_arh-fin-doc-contr-schet-obj.fin-doc-code     = parfin-doc-code
      bfpc_arh-fin-doc-contr-schet-obj.fact-date        = parfact-date
      bfpc_arh-fin-doc-contr-schet-obj.curr-code        = parcurr-code
      bfpc_arh-fin-doc-contr-schet-obj.income           = (if available bopc_arh-fin-doc-contr-schet-obj then bopc_arh-fin-doc-contr-schet-obj.income      else 0)
      bfpc_arh-fin-doc-contr-schet-obj.income-vat       = (if available bopc_arh-fin-doc-contr-schet-obj then bopc_arh-fin-doc-contr-schet-obj.income-vat  else 0)
      bfpc_arh-fin-doc-contr-schet-obj.income-slt       = (if available bopc_arh-fin-doc-contr-schet-obj then bopc_arh-fin-doc-contr-schet-obj.income-slt  else 0)
      bfpc_arh-fin-doc-contr-schet-obj.expense          = (if available bopc_arh-fin-doc-contr-schet-obj then bopc_arh-fin-doc-contr-schet-obj.expense     else 0) + parsum-contr
      bfpc_arh-fin-doc-contr-schet-obj.expense-vat      = (if available bopc_arh-fin-doc-contr-schet-obj then bopc_arh-fin-doc-contr-schet-obj.expense-vat else 0) + parsum-vat-contr
      bfpc_arh-fin-doc-contr-schet-obj.expense-slt      = (if available bopc_arh-fin-doc-contr-schet-obj then bopc_arh-fin-doc-contr-schet-obj.expense-slt else 0) + parsum-slt-contr
    .
  end.
  else do:
    find first bfpc_arh-fin-doc-contr-schet-obj where bfpc_arh-fin-doc-contr-schet-obj.host-code        = parhost-code         and
                                                      bfpc_arh-fin-doc-contr-schet-obj.obj-type         = parobj-type          and
                                                      bfpc_arh-fin-doc-contr-schet-obj.obj-code         = parobj-code          and
                                                      bfpc_arh-fin-doc-contr-schet-obj.cli-type         = parpayer-type        and
                                                      bfpc_arh-fin-doc-contr-schet-obj.cli-code         = parpayer-code        and
                                                      bfpc_arh-fin-doc-contr-schet-obj.contract-code    = parcontract-code     and
                                                      bfpc_arh-fin-doc-contr-schet-obj.code-schet       = parpayer-code-schet  and
                                                      bfpc_arh-fin-doc-contr-schet-obj.fin-ext-doc-type = parfin-ext-doc-type  and
                                                      bfpc_arh-fin-doc-contr-schet-obj.calc-curr-code   = parcurr-dog-code     and
                                                      bfpc_arh-fin-doc-contr-schet-obj.sum-type         = parsum-type          and
                                                      bfpc_arh-fin-doc-contr-schet-obj.fact-order       = parfact-order        exclusive-lock.
  end.
  for each rbfpc_arh-fin-doc-contr-schet-ob where rbfpc_arh-fin-doc-contr-schet-ob.host-code        = bfpc_arh-fin-doc-contr-schet-obj.host-code        and
                                                  rbfpc_arh-fin-doc-contr-schet-ob.obj-type         = bfpc_arh-fin-doc-contr-schet-obj.obj-type         and
                                                  rbfpc_arh-fin-doc-contr-schet-ob.obj-code         = bfpc_arh-fin-doc-contr-schet-obj.obj-code         and
                                                  rbfpc_arh-fin-doc-contr-schet-ob.cli-type         = parpayer-type                                     and
                                                  rbfpc_arh-fin-doc-contr-schet-ob.cli-code         = parpayer-code                                     and
                                                  rbfpc_arh-fin-doc-contr-schet-ob.contract-code    = bfpc_arh-fin-doc-contr-schet-obj.contract-code    and
                                                  rbfpc_arh-fin-doc-contr-schet-ob.code-schet       = bfpc_arh-fin-doc-contr-schet-obj.code-schet       and
                                                  rbfpc_arh-fin-doc-contr-schet-ob.fin-ext-doc-type = bfpc_arh-fin-doc-contr-schet-obj.fin-ext-doc-type and
                                                  rbfpc_arh-fin-doc-contr-schet-ob.calc-curr-code   = bfpc_arh-fin-doc-contr-schet-obj.calc-curr-code   and
                                                  rbfpc_arh-fin-doc-contr-schet-ob.sum-type         = bfpc_arh-fin-doc-contr-schet-obj.sum-type         and
                                                  rbfpc_arh-fin-doc-contr-schet-ob.fact-order       > bfpc_arh-fin-doc-contr-schet-obj.fact-order       use-index pi exclusive-lock on error undo, return error return-value :
    assign
      rbfpc_arh-fin-doc-contr-schet-ob.expense     = rbfpc_arh-fin-doc-contr-schet-ob.expense     + parsum-contr
      rbfpc_arh-fin-doc-contr-schet-ob.expense-vat = rbfpc_arh-fin-doc-contr-schet-ob.expense-vat + parsum-vat-contr
      rbfpc_arh-fin-doc-contr-schet-ob.expense-slt = rbfpc_arh-fin-doc-contr-schet-ob.expense-slt + parsum-slt-contr
    .
  end.
  if parmode = "close":u then do:
    find last borc_arh-fin-doc-contr-schet-obj where borc_arh-fin-doc-contr-schet-obj.host-code        = parhost-code            and
                                                     borc_arh-fin-doc-contr-schet-obj.obj-type         = parobj-type             and
                                                     borc_arh-fin-doc-contr-schet-obj.obj-code         = parobj-code             and
                                                     borc_arh-fin-doc-contr-schet-obj.cli-type         = parreceiver-type        and
                                                     borc_arh-fin-doc-contr-schet-obj.cli-code         = parreceiver-code        and
                                                     borc_arh-fin-doc-contr-schet-obj.contract-code    = parcontract-code        and
                                                     borc_arh-fin-doc-contr-schet-obj.code-schet       = parreceiver-code-schet  and
                                                     borc_arh-fin-doc-contr-schet-obj.fin-ext-doc-type = parfin-ext-doc-type     and
                                                     borc_arh-fin-doc-contr-schet-obj.calc-curr-code   = parcurr-dog-code        and
                                                     borc_arh-fin-doc-contr-schet-obj.sum-type         = parsum-type             and
                                                     borc_arh-fin-doc-contr-schet-obj.fact-order       < parfact-order           use-index pi no-error.
    create bfrc_arh-fin-doc-contr-schet-obj.
    assign
      bfrc_arh-fin-doc-contr-schet-obj.host-code        = parhost-code
      bfrc_arh-fin-doc-contr-schet-obj.obj-type         = parobj-type
      bfrc_arh-fin-doc-contr-schet-obj.obj-code         = parobj-code
      bfrc_arh-fin-doc-contr-schet-obj.cli-type         = parreceiver-type
      bfrc_arh-fin-doc-contr-schet-obj.cli-code         = parreceiver-code
      bfrc_arh-fin-doc-contr-schet-obj.contract-code    = parcontract-code
      bfrc_arh-fin-doc-contr-schet-obj.code-schet       = parreceiver-code-schet
      bfrc_arh-fin-doc-contr-schet-obj.fin-ext-doc-type = parfin-ext-doc-type
      bfrc_arh-fin-doc-contr-schet-obj.calc-curr-code   = parcurr-dog-code
      bfrc_arh-fin-doc-contr-schet-obj.sum-type         = parsum-type
      bfrc_arh-fin-doc-contr-schet-obj.cource-des       = "c":u
      bfrc_arh-fin-doc-contr-schet-obj.fact-order       = parfact-order
      bfrc_arh-fin-doc-contr-schet-obj.fin-doc-code     = parfin-doc-code
      bfrc_arh-fin-doc-contr-schet-obj.fact-date        = parfact-date
      bfrc_arh-fin-doc-contr-schet-obj.curr-code        = parcurr-code
    .
    assign
      bfrc_arh-fin-doc-contr-schet-obj.expense          = (if available borc_arh-fin-doc-contr-schet-obj then borc_arh-fin-doc-contr-schet-obj.expense     else 0)
      bfrc_arh-fin-doc-contr-schet-obj.expense-vat      = (if available borc_arh-fin-doc-contr-schet-obj then borc_arh-fin-doc-contr-schet-obj.expense-vat else 0)
      bfrc_arh-fin-doc-contr-schet-obj.expense-slt      = (if available borc_arh-fin-doc-contr-schet-obj then borc_arh-fin-doc-contr-schet-obj.expense-slt else 0)
      bfrc_arh-fin-doc-contr-schet-obj.income           = (if available borc_arh-fin-doc-contr-schet-obj then borc_arh-fin-doc-contr-schet-obj.income      else 0) + parsum-contr
      bfrc_arh-fin-doc-contr-schet-obj.income-vat       = (if available borc_arh-fin-doc-contr-schet-obj then borc_arh-fin-doc-contr-schet-obj.income-vat  else 0) + parsum-vat-contr
      bfrc_arh-fin-doc-contr-schet-obj.income-slt       = (if available borc_arh-fin-doc-contr-schet-obj then borc_arh-fin-doc-contr-schet-obj.income-slt  else 0) + parsum-slt-contr
    .
  end.
  else do:
    find first bfrc_arh-fin-doc-contr-schet-obj where bfrc_arh-fin-doc-contr-schet-obj.host-code        = parhost-code            and
                                                      bfrc_arh-fin-doc-contr-schet-obj.obj-type         = parobj-type             and
                                                      bfrc_arh-fin-doc-contr-schet-obj.obj-code         = parobj-code             and
                                                      bfrc_arh-fin-doc-contr-schet-obj.cli-type         = parreceiver-type        and
                                                      bfrc_arh-fin-doc-contr-schet-obj.cli-code         = parreceiver-code        and
                                                      bfrc_arh-fin-doc-contr-schet-obj.contract-code    = parcontract-code        and
                                                      bfrc_arh-fin-doc-contr-schet-obj.code-schet       = parreceiver-code-schet  and
                                                      bfrc_arh-fin-doc-contr-schet-obj.fin-ext-doc-type = parfin-ext-doc-type     and
                                                      bfrc_arh-fin-doc-contr-schet-obj.calc-curr-code   = parcurr-dog-code        and
                                                      bfrc_arh-fin-doc-contr-schet-obj.sum-type         = parsum-type             and
                                                      bfrc_arh-fin-doc-contr-schet-obj.fact-order       = parfact-order           exclusive-lock.
  end.
  for each rbfrc_arh-fin-doc-contr-schet-ob where rbfrc_arh-fin-doc-contr-schet-ob.host-code        = bfrc_arh-fin-doc-contr-schet-obj.host-code        and
                                                  rbfrc_arh-fin-doc-contr-schet-ob.obj-type         = bfrc_arh-fin-doc-contr-schet-obj.obj-type         and
                                                  rbfrc_arh-fin-doc-contr-schet-ob.obj-code         = bfrc_arh-fin-doc-contr-schet-obj.obj-code         and
                                                  rbfrc_arh-fin-doc-contr-schet-ob.cli-type         = parreceiver-type                                  and
                                                  rbfrc_arh-fin-doc-contr-schet-ob.cli-code         = parreceiver-code                                  and
                                                  rbfrc_arh-fin-doc-contr-schet-ob.contract-code    = bfrc_arh-fin-doc-contr-schet-obj.contract-code    and
                                                  rbfrc_arh-fin-doc-contr-schet-ob.code-schet       = bfrc_arh-fin-doc-contr-schet-obj.code-schet       and
                                                  rbfrc_arh-fin-doc-contr-schet-ob.fin-ext-doc-type = bfrc_arh-fin-doc-contr-schet-obj.fin-ext-doc-type and
                                                  rbfrc_arh-fin-doc-contr-schet-ob.calc-curr-code   = bfrc_arh-fin-doc-contr-schet-obj.calc-curr-code   and
                                                  rbfrc_arh-fin-doc-contr-schet-ob.sum-type         = bfrc_arh-fin-doc-contr-schet-obj.sum-type         and
                                                  rbfrc_arh-fin-doc-contr-schet-ob.fact-order       > bfrc_arh-fin-doc-contr-schet-obj.fact-order       use-index pi exclusive-lock on error undo, return error return-value :
    assign
      rbfrc_arh-fin-doc-contr-schet-ob.income     = rbfrc_arh-fin-doc-contr-schet-ob.income     + parsum-contr
      rbfrc_arh-fin-doc-contr-schet-ob.income-vat = rbfrc_arh-fin-doc-contr-schet-ob.income-vat + parsum-vat-contr
      rbfrc_arh-fin-doc-contr-schet-ob.income-slt = rbfrc_arh-fin-doc-contr-schet-ob.income-slt + parsum-slt-contr
    .
  end.
  if parmode = "delete":u then do:
    delete bfpc_arh-fin-doc-contr-schet-obj.
    delete bfrc_arh-fin-doc-contr-schet-obj.
  end.
end.
end.
end procedure.
procedure libfarpo_calc-arh-fin-doc-contr-schet-tax-obj :
define input parameter parmode                    as   character                   no-undo.
define input parameter parhost-code               like ub.fin-doc.host-code        no-undo.
define input parameter parobj-type                like ub.fin-doc.obj-type         no-undo.
define input parameter parobj-code                like ub.fin-doc.obj-code         no-undo.
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
define buffer bfps_arh-fin-doc-contr-s-tax-obj for ub.arh-fin-doc-contr-s-tax-obj.
define buffer bfrs_arh-fin-doc-contr-s-tax-obj for ub.arh-fin-doc-contr-s-tax-obj.
define buffer rbfps_arh-fin-doc-contr-s-t-obj  for ub.arh-fin-doc-contr-s-tax-obj.
define buffer rbfrs_arh-fin-doc-contr-s-t-obj  for ub.arh-fin-doc-contr-s-tax-obj.
define buffer bops_arh-fin-doc-contr-s-tax-obj for ub.arh-fin-doc-contr-s-tax-obj.
define buffer bors_arh-fin-doc-contr-s-tax-obj for ub.arh-fin-doc-contr-s-tax-obj.
define buffer bfpr_arh-fin-doc-contr-s-tax-obj for ub.arh-fin-doc-contr-s-tax-obj.
define buffer bfrr_arh-fin-doc-contr-s-tax-obj for ub.arh-fin-doc-contr-s-tax-obj.
define buffer rbfpr_arh-fin-doc-contr-s-t-obj  for ub.arh-fin-doc-contr-s-tax-obj.
define buffer rbfrr_arh-fin-doc-contr-s-t-obj  for ub.arh-fin-doc-contr-s-tax-obj.
define buffer bopr_arh-fin-doc-contr-s-tax-obj for ub.arh-fin-doc-contr-s-tax-obj.
define buffer borr_arh-fin-doc-contr-s-tax-obj for ub.arh-fin-doc-contr-s-tax-obj.
define buffer bfpb_arh-fin-doc-contr-s-tax-obj for ub.arh-fin-doc-contr-s-tax-obj.
define buffer bfrb_arh-fin-doc-contr-s-tax-obj for ub.arh-fin-doc-contr-s-tax-obj.
define buffer rbfpb_arh-fin-doc-contr-s-t-obj  for ub.arh-fin-doc-contr-s-tax-obj.
define buffer rbfrb_arh-fin-doc-contr-s-t-obj  for ub.arh-fin-doc-contr-s-tax-obj.
define buffer bopb_arh-fin-doc-contr-s-tax-obj for ub.arh-fin-doc-contr-s-tax-obj.
define buffer borb_arh-fin-doc-contr-s-tax-obj for ub.arh-fin-doc-contr-s-tax-obj.
define buffer bfpc_arh-fin-doc-contr-s-tax-obj for ub.arh-fin-doc-contr-s-tax-obj.
define buffer bfrc_arh-fin-doc-contr-s-tax-obj for ub.arh-fin-doc-contr-s-tax-obj.
define buffer rbfpc_arh-fin-doc-contr-s-t-obj  for ub.arh-fin-doc-contr-s-tax-obj.
define buffer rbfrc_arh-fin-doc-contr-s-t-obj  for ub.arh-fin-doc-contr-s-tax-obj.
define buffer bopc_arh-fin-doc-contr-s-tax-obj for ub.arh-fin-doc-contr-s-tax-obj.
define buffer borc_arh-fin-doc-contr-s-tax-obj for ub.arh-fin-doc-contr-s-tax-obj.
do on error undo, return error substitute ("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
if parmode = "close":u then do:
  find last bops_arh-fin-doc-contr-s-tax-obj where bops_arh-fin-doc-contr-s-tax-obj.host-code        = parhost-code         and
                                                   bops_arh-fin-doc-contr-s-tax-obj.obj-type         = parobj-type          and
                                                   bops_arh-fin-doc-contr-s-tax-obj.obj-code         = parobj-code          and
                                                   bops_arh-fin-doc-contr-s-tax-obj.cli-type         = parpayer-type        and
                                                   bops_arh-fin-doc-contr-s-tax-obj.cli-code         = parpayer-code        and
                                                   bops_arh-fin-doc-contr-s-tax-obj.contract-code    = parcontract-code     and
                                                   bops_arh-fin-doc-contr-s-tax-obj.code-schet       = parpayer-code-schet  and
                                                   bops_arh-fin-doc-contr-s-tax-obj.fin-ext-doc-type = parfin-ext-doc-type  and
                                                   bops_arh-fin-doc-contr-s-tax-obj.calc-curr-code   = parcurr-code         and
                                                   bops_arh-fin-doc-contr-s-tax-obj.vat-pc           = parvat-pc            and
                                                   bops_arh-fin-doc-contr-s-tax-obj.slt-pc           = parslt-pc            and
                                                   bops_arh-fin-doc-contr-s-tax-obj.with-vat         = parwith-vat          and
                                                   bops_arh-fin-doc-contr-s-tax-obj.with-slt         = parwith-slt          and
                                                   bops_arh-fin-doc-contr-s-tax-obj.sum-type         = parsum-type          and
                                                   bops_arh-fin-doc-contr-s-tax-obj.fact-order       < parfact-order        use-index pi no-error.
  create bfps_arh-fin-doc-contr-s-tax-obj.
  assign
    bfps_arh-fin-doc-contr-s-tax-obj.host-code        = parhost-code
    bfps_arh-fin-doc-contr-s-tax-obj.obj-type         = parobj-type
    bfps_arh-fin-doc-contr-s-tax-obj.obj-code         = parobj-code
    bfps_arh-fin-doc-contr-s-tax-obj.cli-type         = parpayer-type
    bfps_arh-fin-doc-contr-s-tax-obj.cli-code         = parpayer-code
    bfps_arh-fin-doc-contr-s-tax-obj.contract-code    = parcontract-code
    bfps_arh-fin-doc-contr-s-tax-obj.code-schet       = parpayer-code-schet
    bfps_arh-fin-doc-contr-s-tax-obj.fin-ext-doc-type = parfin-ext-doc-type
    bfps_arh-fin-doc-contr-s-tax-obj.calc-curr-code   = parcurr-code
    bfps_arh-fin-doc-contr-s-tax-obj.vat-pc           = parvat-pc
    bfps_arh-fin-doc-contr-s-tax-obj.slt-pc           = parslt-pc
    bfps_arh-fin-doc-contr-s-tax-obj.with-vat         = parwith-vat
    bfps_arh-fin-doc-contr-s-tax-obj.with-slt         = parwith-slt
    bfps_arh-fin-doc-contr-s-tax-obj.sum-type         = parsum-type
    bfps_arh-fin-doc-contr-s-tax-obj.cource-des       = "s":u
    bfps_arh-fin-doc-contr-s-tax-obj.fact-order       = parfact-order
    bfps_arh-fin-doc-contr-s-tax-obj.fin-doc-code     = parfin-doc-code
    bfps_arh-fin-doc-contr-s-tax-obj.fact-date        = parfact-date
    bfps_arh-fin-doc-contr-s-tax-obj.curr-code        = parcurr-code
    bfps_arh-fin-doc-contr-s-tax-obj.income           = (if available bops_arh-fin-doc-contr-s-tax-obj then bops_arh-fin-doc-contr-s-tax-obj.income      else 0)
    bfps_arh-fin-doc-contr-s-tax-obj.income-vat       = (if available bops_arh-fin-doc-contr-s-tax-obj then bops_arh-fin-doc-contr-s-tax-obj.income-vat  else 0)
    bfps_arh-fin-doc-contr-s-tax-obj.income-slt       = (if available bops_arh-fin-doc-contr-s-tax-obj then bops_arh-fin-doc-contr-s-tax-obj.income-slt  else 0)
    bfps_arh-fin-doc-contr-s-tax-obj.expense          = (if available bops_arh-fin-doc-contr-s-tax-obj then bops_arh-fin-doc-contr-s-tax-obj.expense     else 0) + parsum-doc
    bfps_arh-fin-doc-contr-s-tax-obj.expense-vat      = (if available bops_arh-fin-doc-contr-s-tax-obj then bops_arh-fin-doc-contr-s-tax-obj.expense-vat else 0) + parsum-vat-doc
    bfps_arh-fin-doc-contr-s-tax-obj.expense-slt      = (if available bops_arh-fin-doc-contr-s-tax-obj then bops_arh-fin-doc-contr-s-tax-obj.expense-slt else 0) + parsum-slt-doc
  .
end.
else do:
  find first bfps_arh-fin-doc-contr-s-tax-obj where bfps_arh-fin-doc-contr-s-tax-obj.host-code        = parhost-code         and
                                                    bfps_arh-fin-doc-contr-s-tax-obj.obj-type         = parobj-type          and
                                                    bfps_arh-fin-doc-contr-s-tax-obj.obj-code         = parobj-code          and
                                                    bfps_arh-fin-doc-contr-s-tax-obj.cli-type         = parpayer-type        and
                                                    bfps_arh-fin-doc-contr-s-tax-obj.cli-code         = parpayer-code        and
                                                    bfps_arh-fin-doc-contr-s-tax-obj.contract-code    = parcontract-code     and
                                                    bfps_arh-fin-doc-contr-s-tax-obj.code-schet       = parpayer-code-schet  and
                                                    bfps_arh-fin-doc-contr-s-tax-obj.fin-ext-doc-type = parfin-ext-doc-type  and
                                                    bfps_arh-fin-doc-contr-s-tax-obj.calc-curr-code   = parcurr-code         and
                                                    bfps_arh-fin-doc-contr-s-tax-obj.vat-pc           = parvat-pc            and
                                                    bfps_arh-fin-doc-contr-s-tax-obj.slt-pc           = parslt-pc            and
                                                    bfps_arh-fin-doc-contr-s-tax-obj.with-vat         = parwith-vat          and
                                                    bfps_arh-fin-doc-contr-s-tax-obj.with-slt         = parwith-slt          and
                                                    bfps_arh-fin-doc-contr-s-tax-obj.sum-type         = parsum-type          and
                                                    bfps_arh-fin-doc-contr-s-tax-obj.fact-order       = parfact-order        exclusive-lock.
end.
for each rbfps_arh-fin-doc-contr-s-t-obj where rbfps_arh-fin-doc-contr-s-t-obj.host-code        = bfps_arh-fin-doc-contr-s-tax-obj.host-code        and
                                               rbfps_arh-fin-doc-contr-s-t-obj.obj-type         = bfps_arh-fin-doc-contr-s-tax-obj.obj-type         and
                                               rbfps_arh-fin-doc-contr-s-t-obj.obj-code         = bfps_arh-fin-doc-contr-s-tax-obj.obj-code         and
                                               rbfps_arh-fin-doc-contr-s-t-obj.cli-type         = parpayer-type                                     and
                                               rbfps_arh-fin-doc-contr-s-t-obj.cli-code         = parpayer-code                                     and
                                               rbfps_arh-fin-doc-contr-s-t-obj.contract-code    = bfps_arh-fin-doc-contr-s-tax-obj.contract-code    and
                                               rbfps_arh-fin-doc-contr-s-t-obj.code-schet       = bfps_arh-fin-doc-contr-s-tax-obj.code-schet       and
                                               rbfps_arh-fin-doc-contr-s-t-obj.fin-ext-doc-type = bfps_arh-fin-doc-contr-s-tax-obj.fin-ext-doc-type and
                                               rbfps_arh-fin-doc-contr-s-t-obj.calc-curr-code   = bfps_arh-fin-doc-contr-s-tax-obj.calc-curr-code   and
                                               rbfps_arh-fin-doc-contr-s-t-obj.vat-pc           = bfps_arh-fin-doc-contr-s-tax-obj.vat-pc           and
                                               rbfps_arh-fin-doc-contr-s-t-obj.slt-pc           = bfps_arh-fin-doc-contr-s-tax-obj.slt-pc           and
                                               rbfps_arh-fin-doc-contr-s-t-obj.with-vat         = bfps_arh-fin-doc-contr-s-tax-obj.with-vat         and
                                               rbfps_arh-fin-doc-contr-s-t-obj.with-slt         = bfps_arh-fin-doc-contr-s-tax-obj.with-slt         and
                                               rbfps_arh-fin-doc-contr-s-t-obj.sum-type         = bfps_arh-fin-doc-contr-s-tax-obj.sum-type         and
                                               rbfps_arh-fin-doc-contr-s-t-obj.fact-order       > bfps_arh-fin-doc-contr-s-tax-obj.fact-order       use-index pi exclusive-lock on error undo, return error return-value :
  assign
    rbfps_arh-fin-doc-contr-s-t-obj.expense     = rbfps_arh-fin-doc-contr-s-t-obj.expense     + parsum-doc
    rbfps_arh-fin-doc-contr-s-t-obj.expense-vat = rbfps_arh-fin-doc-contr-s-t-obj.expense-vat + parsum-vat-doc
    rbfps_arh-fin-doc-contr-s-t-obj.expense-slt = rbfps_arh-fin-doc-contr-s-t-obj.expense-slt + parsum-slt-doc
  .
end.
if parmode = "close":u then do:
  find last bors_arh-fin-doc-contr-s-tax-obj where bors_arh-fin-doc-contr-s-tax-obj.host-code         = parhost-code           and
                                                   bors_arh-fin-doc-contr-s-tax-obj.obj-type          = parobj-type            and
                                                   bors_arh-fin-doc-contr-s-tax-obj.obj-code          = parobj-code            and
                                                   bors_arh-fin-doc-contr-s-tax-obj.cli-type          = parreceiver-type       and
                                                   bors_arh-fin-doc-contr-s-tax-obj.cli-code          = parreceiver-code       and
                                                   bors_arh-fin-doc-contr-s-tax-obj.contract-code     = parcontract-code       and
                                                   bors_arh-fin-doc-contr-s-tax-obj.code-schet        = parreceiver-code-schet and
                                                   bors_arh-fin-doc-contr-s-tax-obj.fin-ext-doc-type  = parfin-ext-doc-type    and
                                                   bors_arh-fin-doc-contr-s-tax-obj.calc-curr-code    = parcurr-code           and
                                                   bors_arh-fin-doc-contr-s-tax-obj.vat-pc            = parvat-pc              and
                                                   bors_arh-fin-doc-contr-s-tax-obj.slt-pc            = parslt-pc              and
                                                   bors_arh-fin-doc-contr-s-tax-obj.with-vat          = parwith-vat            and
                                                   bors_arh-fin-doc-contr-s-tax-obj.with-slt          = parwith-slt            and
                                                   bors_arh-fin-doc-contr-s-tax-obj.sum-type          = parsum-type            and
                                                   bors_arh-fin-doc-contr-s-tax-obj.fact-order        < parfact-order          use-index pi no-error.
  create bfrs_arh-fin-doc-contr-s-tax-obj.
  assign
    bfrs_arh-fin-doc-contr-s-tax-obj.host-code        = parhost-code
    bfrs_arh-fin-doc-contr-s-tax-obj.obj-type         = parobj-type
    bfrs_arh-fin-doc-contr-s-tax-obj.obj-code         = parobj-code
    bfrs_arh-fin-doc-contr-s-tax-obj.cli-type         = parreceiver-type
    bfrs_arh-fin-doc-contr-s-tax-obj.cli-code         = parreceiver-code
    bfrs_arh-fin-doc-contr-s-tax-obj.contract-code    = parcontract-code
    bfrs_arh-fin-doc-contr-s-tax-obj.code-schet       = parreceiver-code-schet
    bfrs_arh-fin-doc-contr-s-tax-obj.fin-ext-doc-type = parfin-ext-doc-type
    bfrs_arh-fin-doc-contr-s-tax-obj.calc-curr-code   = parcurr-code
    bfrs_arh-fin-doc-contr-s-tax-obj.vat-pc           = parvat-pc
    bfrs_arh-fin-doc-contr-s-tax-obj.slt-pc           = parslt-pc
    bfrs_arh-fin-doc-contr-s-tax-obj.with-vat         = parwith-vat
    bfrs_arh-fin-doc-contr-s-tax-obj.with-slt         = parwith-slt
    bfrs_arh-fin-doc-contr-s-tax-obj.sum-type         = parsum-type
    bfrs_arh-fin-doc-contr-s-tax-obj.cource-des       = "s":u
    bfrs_arh-fin-doc-contr-s-tax-obj.fact-order       = parfact-order
    bfrs_arh-fin-doc-contr-s-tax-obj.fin-doc-code     = parfin-doc-code
    bfrs_arh-fin-doc-contr-s-tax-obj.fact-date        = parfact-date
    bfrs_arh-fin-doc-contr-s-tax-obj.curr-code        = parcurr-code
  .
  assign
    bfrs_arh-fin-doc-contr-s-tax-obj.expense          = (if available bors_arh-fin-doc-contr-s-tax-obj then bors_arh-fin-doc-contr-s-tax-obj.expense     else 0)
    bfrs_arh-fin-doc-contr-s-tax-obj.expense-vat      = (if available bors_arh-fin-doc-contr-s-tax-obj then bors_arh-fin-doc-contr-s-tax-obj.expense-vat else 0)
    bfrs_arh-fin-doc-contr-s-tax-obj.expense-slt      = (if available bors_arh-fin-doc-contr-s-tax-obj then bors_arh-fin-doc-contr-s-tax-obj.expense-slt else 0)
    bfrs_arh-fin-doc-contr-s-tax-obj.income           = (if available bors_arh-fin-doc-contr-s-tax-obj then bors_arh-fin-doc-contr-s-tax-obj.income      else 0) + parsum-doc
    bfrs_arh-fin-doc-contr-s-tax-obj.income-vat       = (if available bors_arh-fin-doc-contr-s-tax-obj then bors_arh-fin-doc-contr-s-tax-obj.income-vat  else 0) + parsum-vat-doc
    bfrs_arh-fin-doc-contr-s-tax-obj.income-slt       = (if available bors_arh-fin-doc-contr-s-tax-obj then bors_arh-fin-doc-contr-s-tax-obj.income-slt  else 0) + parsum-slt-doc
  .
end.
else do:
  find first bfrs_arh-fin-doc-contr-s-tax-obj where bfrs_arh-fin-doc-contr-s-tax-obj.host-code         = parhost-code           and
                                                    bfrs_arh-fin-doc-contr-s-tax-obj.obj-type          = parobj-type            and
                                                    bfrs_arh-fin-doc-contr-s-tax-obj.obj-code          = parobj-code            and
                                                    bfrs_arh-fin-doc-contr-s-tax-obj.cli-type          = parreceiver-type       and
                                                    bfrs_arh-fin-doc-contr-s-tax-obj.cli-code          = parreceiver-code       and
                                                    bfrs_arh-fin-doc-contr-s-tax-obj.contract-code     = parcontract-code       and
                                                    bfrs_arh-fin-doc-contr-s-tax-obj.code-schet        = parreceiver-code-schet and
                                                    bfrs_arh-fin-doc-contr-s-tax-obj.fin-ext-doc-type  = parfin-ext-doc-type    and
                                                    bfrs_arh-fin-doc-contr-s-tax-obj.calc-curr-code    = parcurr-code           and
                                                    bfrs_arh-fin-doc-contr-s-tax-obj.vat-pc            = parvat-pc              and
                                                    bfrs_arh-fin-doc-contr-s-tax-obj.slt-pc            = parslt-pc              and
                                                    bfrs_arh-fin-doc-contr-s-tax-obj.with-vat          = parwith-vat            and
                                                    bfrs_arh-fin-doc-contr-s-tax-obj.with-slt          = parwith-slt            and
                                                    bfrs_arh-fin-doc-contr-s-tax-obj.sum-type          = parsum-type            and
                                                    bfrs_arh-fin-doc-contr-s-tax-obj.fact-order        = parfact-order          exclusive-lock.
end.
for each rbfrs_arh-fin-doc-contr-s-t-obj where rbfrs_arh-fin-doc-contr-s-t-obj.host-code        = bfrs_arh-fin-doc-contr-s-tax-obj.host-code        and
                                               rbfrs_arh-fin-doc-contr-s-t-obj.obj-type         = bfrs_arh-fin-doc-contr-s-tax-obj.obj-type         and
                                               rbfrs_arh-fin-doc-contr-s-t-obj.obj-code         = bfrs_arh-fin-doc-contr-s-tax-obj.obj-code         and
                                               rbfrs_arh-fin-doc-contr-s-t-obj.cli-type         = parreceiver-type                                  and
                                               rbfrs_arh-fin-doc-contr-s-t-obj.cli-code         = parreceiver-code                                  and
                                               rbfrs_arh-fin-doc-contr-s-t-obj.contract-code    = bfrs_arh-fin-doc-contr-s-tax-obj.contract-code    and
                                               rbfrs_arh-fin-doc-contr-s-t-obj.code-schet       = bfrs_arh-fin-doc-contr-s-tax-obj.code-schet       and
                                               rbfrs_arh-fin-doc-contr-s-t-obj.fin-ext-doc-type = bfrs_arh-fin-doc-contr-s-tax-obj.fin-ext-doc-type and
                                               rbfrs_arh-fin-doc-contr-s-t-obj.calc-curr-code   = bfrs_arh-fin-doc-contr-s-tax-obj.calc-curr-code   and
                                               rbfrs_arh-fin-doc-contr-s-t-obj.vat-pc           = bfrs_arh-fin-doc-contr-s-tax-obj.vat-pc           and
                                               rbfrs_arh-fin-doc-contr-s-t-obj.slt-pc           = bfrs_arh-fin-doc-contr-s-tax-obj.slt-pc           and
                                               rbfrs_arh-fin-doc-contr-s-t-obj.with-vat         = bfrs_arh-fin-doc-contr-s-tax-obj.with-vat         and
                                               rbfrs_arh-fin-doc-contr-s-t-obj.with-slt         = bfrs_arh-fin-doc-contr-s-tax-obj.with-slt         and
                                               rbfrs_arh-fin-doc-contr-s-t-obj.sum-type         = bfrs_arh-fin-doc-contr-s-tax-obj.sum-type         and
                                               rbfrs_arh-fin-doc-contr-s-t-obj.fact-order       > bfrs_arh-fin-doc-contr-s-tax-obj.fact-order       use-index pi exclusive-lock on error undo, return error return-value :
  assign
    rbfrs_arh-fin-doc-contr-s-t-obj.income     = rbfrs_arh-fin-doc-contr-s-t-obj.income     + parsum-doc
    rbfrs_arh-fin-doc-contr-s-t-obj.income-vat = rbfrs_arh-fin-doc-contr-s-t-obj.income-vat + parsum-vat-doc
    rbfrs_arh-fin-doc-contr-s-t-obj.income-slt = rbfrs_arh-fin-doc-contr-s-t-obj.income-slt + parsum-slt-doc
  .
end.
if parmode = "delete":u then do:
  delete bfps_arh-fin-doc-contr-s-tax-obj.
  delete bfrs_arh-fin-doc-contr-s-tax-obj.
end.
if parcurr-code <> 0 then do:
  if parmode = "close":u then do:
    find last bopr_arh-fin-doc-contr-s-tax-obj where bopr_arh-fin-doc-contr-s-tax-obj.host-code        = parhost-code         and
                                                     bopr_arh-fin-doc-contr-s-tax-obj.obj-type         = parobj-type          and
                                                     bopr_arh-fin-doc-contr-s-tax-obj.obj-code         = parobj-code          and
                                                     bopr_arh-fin-doc-contr-s-tax-obj.cli-type         = parpayer-type        and
                                                     bopr_arh-fin-doc-contr-s-tax-obj.cli-code         = parpayer-code        and
                                                     bopr_arh-fin-doc-contr-s-tax-obj.contract-code    = parcontract-code     and
                                                     bopr_arh-fin-doc-contr-s-tax-obj.code-schet       = parpayer-code-schet  and
                                                     bopr_arh-fin-doc-contr-s-tax-obj.fin-ext-doc-type = parfin-ext-doc-type  and
                                                     bopr_arh-fin-doc-contr-s-tax-obj.calc-curr-code   = 0                    and
                                                     bopr_arh-fin-doc-contr-s-tax-obj.vat-pc           = parvat-pc            and
                                                     bopr_arh-fin-doc-contr-s-tax-obj.slt-pc           = parslt-pc            and
                                                     bopr_arh-fin-doc-contr-s-tax-obj.with-vat         = parwith-vat          and
                                                     bopr_arh-fin-doc-contr-s-tax-obj.with-slt         = parwith-slt          and
                                                     bopr_arh-fin-doc-contr-s-tax-obj.sum-type         = parsum-type          and
                                                     bopr_arh-fin-doc-contr-s-tax-obj.fact-order       < parfact-order        use-index pi no-error.
    create bfpr_arh-fin-doc-contr-s-tax-obj.
    assign
      bfpr_arh-fin-doc-contr-s-tax-obj.host-code        = parhost-code
      bfpr_arh-fin-doc-contr-s-tax-obj.obj-type         = parobj-type
      bfpr_arh-fin-doc-contr-s-tax-obj.obj-code         = parobj-code
      bfpr_arh-fin-doc-contr-s-tax-obj.cli-type         = parpayer-type
      bfpr_arh-fin-doc-contr-s-tax-obj.cli-code         = parpayer-code
      bfpr_arh-fin-doc-contr-s-tax-obj.contract-code    = parcontract-code
      bfpr_arh-fin-doc-contr-s-tax-obj.code-schet       = parpayer-code-schet
      bfpr_arh-fin-doc-contr-s-tax-obj.fin-ext-doc-type = parfin-ext-doc-type
      bfpr_arh-fin-doc-contr-s-tax-obj.calc-curr-code   = 0
      bfpr_arh-fin-doc-contr-s-tax-obj.vat-pc           = parvat-pc
      bfpr_arh-fin-doc-contr-s-tax-obj.slt-pc           = parslt-pc
      bfpr_arh-fin-doc-contr-s-tax-obj.with-vat         = parwith-vat
      bfpr_arh-fin-doc-contr-s-tax-obj.with-slt         = parwith-slt
      bfpr_arh-fin-doc-contr-s-tax-obj.sum-type         = parsum-type
      bfpr_arh-fin-doc-contr-s-tax-obj.cource-des       = "r":u
      bfpr_arh-fin-doc-contr-s-tax-obj.fact-order       = parfact-order
      bfpr_arh-fin-doc-contr-s-tax-obj.fin-doc-code     = parfin-doc-code
      bfpr_arh-fin-doc-contr-s-tax-obj.fact-date        = parfact-date
      bfpr_arh-fin-doc-contr-s-tax-obj.curr-code        = parcurr-code
      bfpr_arh-fin-doc-contr-s-tax-obj.income           = (if available bopr_arh-fin-doc-contr-s-tax-obj then bopr_arh-fin-doc-contr-s-tax-obj.income      else 0)
      bfpr_arh-fin-doc-contr-s-tax-obj.income-vat       = (if available bopr_arh-fin-doc-contr-s-tax-obj then bopr_arh-fin-doc-contr-s-tax-obj.income-vat  else 0)
      bfpr_arh-fin-doc-contr-s-tax-obj.income-slt       = (if available bopr_arh-fin-doc-contr-s-tax-obj then bopr_arh-fin-doc-contr-s-tax-obj.income-slt  else 0)
      bfpr_arh-fin-doc-contr-s-tax-obj.expense          = (if available bopr_arh-fin-doc-contr-s-tax-obj then bopr_arh-fin-doc-contr-s-tax-obj.expense     else 0) + parsum-rubl
      bfpr_arh-fin-doc-contr-s-tax-obj.expense-vat      = (if available bopr_arh-fin-doc-contr-s-tax-obj then bopr_arh-fin-doc-contr-s-tax-obj.expense-vat else 0) + parsum-vat-rubl
      bfpr_arh-fin-doc-contr-s-tax-obj.expense-slt      = (if available bopr_arh-fin-doc-contr-s-tax-obj then bopr_arh-fin-doc-contr-s-tax-obj.expense-slt else 0) + parsum-slt-rubl
    .
  end.
  else do:
    find first bfpr_arh-fin-doc-contr-s-tax-obj where bfpr_arh-fin-doc-contr-s-tax-obj.host-code        = parhost-code         and
                                                      bfpr_arh-fin-doc-contr-s-tax-obj.obj-type         = parobj-type          and
                                                      bfpr_arh-fin-doc-contr-s-tax-obj.obj-code         = parobj-code          and
                                                      bfpr_arh-fin-doc-contr-s-tax-obj.cli-type         = parpayer-type        and
                                                      bfpr_arh-fin-doc-contr-s-tax-obj.cli-code         = parpayer-code        and
                                                      bfpr_arh-fin-doc-contr-s-tax-obj.contract-code    = parcontract-code     and
                                                      bfpr_arh-fin-doc-contr-s-tax-obj.code-schet       = parpayer-code-schet  and
                                                      bfpr_arh-fin-doc-contr-s-tax-obj.fin-ext-doc-type = parfin-ext-doc-type  and
                                                      bfpr_arh-fin-doc-contr-s-tax-obj.calc-curr-code   = 0                    and
                                                      bfpr_arh-fin-doc-contr-s-tax-obj.vat-pc           = parvat-pc            and
                                                      bfpr_arh-fin-doc-contr-s-tax-obj.slt-pc           = parslt-pc            and
                                                      bfpr_arh-fin-doc-contr-s-tax-obj.with-vat         = parwith-vat          and
                                                      bfpr_arh-fin-doc-contr-s-tax-obj.with-slt         = parwith-slt          and
                                                      bfpr_arh-fin-doc-contr-s-tax-obj.sum-type         = parsum-type          and
                                                      bfpr_arh-fin-doc-contr-s-tax-obj.fact-order       = parfact-order        exclusive-lock.
  end.
  for each rbfpr_arh-fin-doc-contr-s-t-obj where rbfpr_arh-fin-doc-contr-s-t-obj.host-code        = bfpr_arh-fin-doc-contr-s-tax-obj.host-code        and
                                                 rbfpr_arh-fin-doc-contr-s-t-obj.obj-type         = bfpr_arh-fin-doc-contr-s-tax-obj.obj-type         and
                                                 rbfpr_arh-fin-doc-contr-s-t-obj.obj-code         = bfpr_arh-fin-doc-contr-s-tax-obj.obj-code         and
                                                 rbfpr_arh-fin-doc-contr-s-t-obj.cli-type         = parpayer-type                                     and
                                                 rbfpr_arh-fin-doc-contr-s-t-obj.cli-code         = parpayer-code                                     and
                                                 rbfpr_arh-fin-doc-contr-s-t-obj.contract-code    = bfpr_arh-fin-doc-contr-s-tax-obj.contract-code    and
                                                 rbfpr_arh-fin-doc-contr-s-t-obj.code-schet       = bfpr_arh-fin-doc-contr-s-tax-obj.code-schet       and
                                                 rbfpr_arh-fin-doc-contr-s-t-obj.fin-ext-doc-type = bfpr_arh-fin-doc-contr-s-tax-obj.fin-ext-doc-type and
                                                 rbfpr_arh-fin-doc-contr-s-t-obj.calc-curr-code   = bfpr_arh-fin-doc-contr-s-tax-obj.calc-curr-code   and
                                                 rbfpr_arh-fin-doc-contr-s-t-obj.vat-pc           = bfpr_arh-fin-doc-contr-s-tax-obj.vat-pc           and
                                                 rbfpr_arh-fin-doc-contr-s-t-obj.slt-pc           = bfpr_arh-fin-doc-contr-s-tax-obj.slt-pc           and
                                                 rbfpr_arh-fin-doc-contr-s-t-obj.with-vat         = bfpr_arh-fin-doc-contr-s-tax-obj.with-vat         and
                                                 rbfpr_arh-fin-doc-contr-s-t-obj.with-slt         = bfpr_arh-fin-doc-contr-s-tax-obj.with-slt         and
                                                 rbfpr_arh-fin-doc-contr-s-t-obj.sum-type         = bfpr_arh-fin-doc-contr-s-tax-obj.sum-type         and
                                                 rbfpr_arh-fin-doc-contr-s-t-obj.fact-order       > bfpr_arh-fin-doc-contr-s-tax-obj.fact-order       use-index pi exclusive-lock on error undo, return error return-value :
    assign
      rbfpr_arh-fin-doc-contr-s-t-obj.expense     = rbfpr_arh-fin-doc-contr-s-t-obj.expense     + parsum-rubl
      rbfpr_arh-fin-doc-contr-s-t-obj.expense-vat = rbfpr_arh-fin-doc-contr-s-t-obj.expense-vat + parsum-vat-rubl
      rbfpr_arh-fin-doc-contr-s-t-obj.expense-slt = rbfpr_arh-fin-doc-contr-s-t-obj.expense-slt + parsum-slt-rubl
    .
  end.
  if parmode = "close":u then do:
    find last borr_arh-fin-doc-contr-s-tax-obj where borr_arh-fin-doc-contr-s-tax-obj.host-code        = parhost-code            and
                                                     borr_arh-fin-doc-contr-s-tax-obj.obj-type         = parobj-type             and
                                                     borr_arh-fin-doc-contr-s-tax-obj.obj-code         = parobj-code             and
                                                     borr_arh-fin-doc-contr-s-tax-obj.cli-type         = parreceiver-type        and
                                                     borr_arh-fin-doc-contr-s-tax-obj.cli-code         = parreceiver-code        and
                                                     borr_arh-fin-doc-contr-s-tax-obj.contract-code    = parcontract-code        and
                                                     borr_arh-fin-doc-contr-s-tax-obj.code-schet       = parreceiver-code-schet  and
                                                     borr_arh-fin-doc-contr-s-tax-obj.fin-ext-doc-type = parfin-ext-doc-type     and
                                                     borr_arh-fin-doc-contr-s-tax-obj.calc-curr-code   = 0                       and
                                                     borr_arh-fin-doc-contr-s-tax-obj.vat-pc           = parvat-pc               and
                                                     borr_arh-fin-doc-contr-s-tax-obj.slt-pc           = parslt-pc               and
                                                     borr_arh-fin-doc-contr-s-tax-obj.with-vat         = parwith-vat             and
                                                     borr_arh-fin-doc-contr-s-tax-obj.with-slt         = parwith-slt             and
                                                     borr_arh-fin-doc-contr-s-tax-obj.sum-type         = parsum-type             and
                                                     borr_arh-fin-doc-contr-s-tax-obj.fact-order       < parfact-order           use-index pi no-error.
    create bfrr_arh-fin-doc-contr-s-tax-obj.
    assign
      bfrr_arh-fin-doc-contr-s-tax-obj.host-code        = parhost-code
      bfrr_arh-fin-doc-contr-s-tax-obj.obj-type         = parobj-type
      bfrr_arh-fin-doc-contr-s-tax-obj.obj-code         = parobj-code
      bfrr_arh-fin-doc-contr-s-tax-obj.cli-type         = parreceiver-type
      bfrr_arh-fin-doc-contr-s-tax-obj.cli-code         = parreceiver-code
      bfrr_arh-fin-doc-contr-s-tax-obj.contract-code    = parcontract-code
      bfrr_arh-fin-doc-contr-s-tax-obj.code-schet       = parreceiver-code-schet
      bfrr_arh-fin-doc-contr-s-tax-obj.fin-ext-doc-type = parfin-ext-doc-type
      bfrr_arh-fin-doc-contr-s-tax-obj.calc-curr-code   = 0
      bfrr_arh-fin-doc-contr-s-tax-obj.vat-pc           = parvat-pc
      bfrr_arh-fin-doc-contr-s-tax-obj.slt-pc           = parslt-pc
      bfrr_arh-fin-doc-contr-s-tax-obj.with-vat         = parwith-vat
      bfrr_arh-fin-doc-contr-s-tax-obj.with-slt         = parwith-slt
      bfrr_arh-fin-doc-contr-s-tax-obj.sum-type         = parsum-type
      bfrr_arh-fin-doc-contr-s-tax-obj.cource-des       = "r":u
      bfrr_arh-fin-doc-contr-s-tax-obj.fact-order       = parfact-order
      bfrr_arh-fin-doc-contr-s-tax-obj.fin-doc-code     = parfin-doc-code
      bfrr_arh-fin-doc-contr-s-tax-obj.fact-date        = parfact-date
      bfrr_arh-fin-doc-contr-s-tax-obj.curr-code        = parcurr-code
    .
    assign
      bfrr_arh-fin-doc-contr-s-tax-obj.expense          = (if available borr_arh-fin-doc-contr-s-tax-obj then borr_arh-fin-doc-contr-s-tax-obj.expense     else 0)
      bfrr_arh-fin-doc-contr-s-tax-obj.expense-vat      = (if available borr_arh-fin-doc-contr-s-tax-obj then borr_arh-fin-doc-contr-s-tax-obj.expense-vat else 0)
      bfrr_arh-fin-doc-contr-s-tax-obj.expense-slt      = (if available borr_arh-fin-doc-contr-s-tax-obj then borr_arh-fin-doc-contr-s-tax-obj.expense-slt else 0)
      bfrr_arh-fin-doc-contr-s-tax-obj.income           = (if available borr_arh-fin-doc-contr-s-tax-obj then borr_arh-fin-doc-contr-s-tax-obj.income      else 0) + parsum-rubl
      bfrr_arh-fin-doc-contr-s-tax-obj.income-vat       = (if available borr_arh-fin-doc-contr-s-tax-obj then borr_arh-fin-doc-contr-s-tax-obj.income-vat  else 0) + parsum-vat-rubl
      bfrr_arh-fin-doc-contr-s-tax-obj.income-slt       = (if available borr_arh-fin-doc-contr-s-tax-obj then borr_arh-fin-doc-contr-s-tax-obj.income-slt  else 0) + parsum-slt-rubl
    .
  end.
  else do:
    find first bfrr_arh-fin-doc-contr-s-tax-obj where bfrr_arh-fin-doc-contr-s-tax-obj.host-code        = parhost-code            and
                                                      bfrr_arh-fin-doc-contr-s-tax-obj.obj-type         = parobj-type             and
                                                      bfrr_arh-fin-doc-contr-s-tax-obj.obj-code         = parobj-code             and
                                                      bfrr_arh-fin-doc-contr-s-tax-obj.cli-type         = parreceiver-type        and
                                                      bfrr_arh-fin-doc-contr-s-tax-obj.cli-code         = parreceiver-code        and
                                                      bfrr_arh-fin-doc-contr-s-tax-obj.contract-code    = parcontract-code        and
                                                      bfrr_arh-fin-doc-contr-s-tax-obj.code-schet       = parreceiver-code-schet  and
                                                      bfrr_arh-fin-doc-contr-s-tax-obj.fin-ext-doc-type = parfin-ext-doc-type     and
                                                      bfrr_arh-fin-doc-contr-s-tax-obj.calc-curr-code   = 0                       and
                                                      bfrr_arh-fin-doc-contr-s-tax-obj.vat-pc           = parvat-pc               and
                                                      bfrr_arh-fin-doc-contr-s-tax-obj.slt-pc           = parslt-pc               and
                                                      bfrr_arh-fin-doc-contr-s-tax-obj.with-vat         = parwith-vat             and
                                                      bfrr_arh-fin-doc-contr-s-tax-obj.with-slt         = parwith-slt             and
                                                      bfrr_arh-fin-doc-contr-s-tax-obj.sum-type         = parsum-type             and
                                                      bfrr_arh-fin-doc-contr-s-tax-obj.fact-order       = parfact-order           exclusive-lock.
  end.
  for each rbfrr_arh-fin-doc-contr-s-t-obj where rbfrr_arh-fin-doc-contr-s-t-obj.host-code        = bfrr_arh-fin-doc-contr-s-tax-obj.host-code        and
                                                 rbfrr_arh-fin-doc-contr-s-t-obj.obj-type         = bfrr_arh-fin-doc-contr-s-tax-obj.obj-type         and
                                                 rbfrr_arh-fin-doc-contr-s-t-obj.obj-code         = bfrr_arh-fin-doc-contr-s-tax-obj.obj-code         and
                                                 rbfrr_arh-fin-doc-contr-s-t-obj.cli-type         = parreceiver-type                                  and
                                                 rbfrr_arh-fin-doc-contr-s-t-obj.cli-code         = parreceiver-code                                  and
                                                 rbfrr_arh-fin-doc-contr-s-t-obj.contract-code    = bfrr_arh-fin-doc-contr-s-tax-obj.contract-code    and
                                                 rbfrr_arh-fin-doc-contr-s-t-obj.code-schet       = bfrr_arh-fin-doc-contr-s-tax-obj.code-schet       and
                                                 rbfrr_arh-fin-doc-contr-s-t-obj.fin-ext-doc-type = bfrr_arh-fin-doc-contr-s-tax-obj.fin-ext-doc-type and
                                                 rbfrr_arh-fin-doc-contr-s-t-obj.calc-curr-code   = bfrr_arh-fin-doc-contr-s-tax-obj.calc-curr-code   and
                                                 rbfrr_arh-fin-doc-contr-s-t-obj.vat-pc           = bfrr_arh-fin-doc-contr-s-tax-obj.vat-pc           and
                                                 rbfrr_arh-fin-doc-contr-s-t-obj.slt-pc           = bfrr_arh-fin-doc-contr-s-tax-obj.slt-pc           and
                                                 rbfrr_arh-fin-doc-contr-s-t-obj.with-vat         = bfrr_arh-fin-doc-contr-s-tax-obj.with-vat         and
                                                 rbfrr_arh-fin-doc-contr-s-t-obj.with-slt         = bfrr_arh-fin-doc-contr-s-tax-obj.with-slt         and
                                                 rbfrr_arh-fin-doc-contr-s-t-obj.sum-type         = bfrr_arh-fin-doc-contr-s-tax-obj.sum-type         and
                                                 rbfrr_arh-fin-doc-contr-s-t-obj.fact-order       > bfrr_arh-fin-doc-contr-s-tax-obj.fact-order       use-index pi exclusive-lock on error undo, return error return-value :
    assign
      rbfrr_arh-fin-doc-contr-s-t-obj.income     = rbfrr_arh-fin-doc-contr-s-t-obj.income     + parsum-rubl
      rbfrr_arh-fin-doc-contr-s-t-obj.income-vat = rbfrr_arh-fin-doc-contr-s-t-obj.income-vat + parsum-vat-rubl
      rbfrr_arh-fin-doc-contr-s-t-obj.income-slt = rbfrr_arh-fin-doc-contr-s-t-obj.income-slt + parsum-slt-rubl
    .
  end.
  if parmode = "delete":u then do:
    delete bfpr_arh-fin-doc-contr-s-tax-obj.
    delete bfrr_arh-fin-doc-contr-s-tax-obj.
  end.
end.
if parbase-code <> parcurr-code and
   parbase-code <> 0            then do:
  if parmode = "close":u then do:
    find last bopb_arh-fin-doc-contr-s-tax-obj where bopb_arh-fin-doc-contr-s-tax-obj.host-code        = parhost-code         and
                                                     bopb_arh-fin-doc-contr-s-tax-obj.obj-type         = parobj-type          and
                                                     bopb_arh-fin-doc-contr-s-tax-obj.obj-code         = parobj-code          and
                                                     bopb_arh-fin-doc-contr-s-tax-obj.cli-type         = parpayer-type        and
                                                     bopb_arh-fin-doc-contr-s-tax-obj.cli-code         = parpayer-code        and
                                                     bopb_arh-fin-doc-contr-s-tax-obj.contract-code    = parcontract-code     and
                                                     bopb_arh-fin-doc-contr-s-tax-obj.code-schet       = parpayer-code-schet  and
                                                     bopb_arh-fin-doc-contr-s-tax-obj.fin-ext-doc-type = parfin-ext-doc-type  and
                                                     bopb_arh-fin-doc-contr-s-tax-obj.calc-curr-code   = parbase-code         and
                                                     bopb_arh-fin-doc-contr-s-tax-obj.vat-pc           = parvat-pc            and
                                                     bopb_arh-fin-doc-contr-s-tax-obj.slt-pc           = parslt-pc            and
                                                     bopb_arh-fin-doc-contr-s-tax-obj.with-vat         = parwith-vat          and
                                                     bopb_arh-fin-doc-contr-s-tax-obj.with-slt         = parwith-slt          and
                                                     bopb_arh-fin-doc-contr-s-tax-obj.sum-type         = parsum-type          and
                                                     bopb_arh-fin-doc-contr-s-tax-obj.fact-order       < parfact-order        use-index pi no-error.
    create bfpb_arh-fin-doc-contr-s-tax-obj.
    assign
      bfpb_arh-fin-doc-contr-s-tax-obj.host-code        = parhost-code
      bfpb_arh-fin-doc-contr-s-tax-obj.obj-type         = parobj-type
      bfpb_arh-fin-doc-contr-s-tax-obj.obj-code         = parobj-code
      bfpb_arh-fin-doc-contr-s-tax-obj.cli-type         = parpayer-type
      bfpb_arh-fin-doc-contr-s-tax-obj.cli-code         = parpayer-code
      bfpb_arh-fin-doc-contr-s-tax-obj.contract-code    = parcontract-code
      bfpb_arh-fin-doc-contr-s-tax-obj.code-schet       = parpayer-code-schet
      bfpb_arh-fin-doc-contr-s-tax-obj.fin-ext-doc-type = parfin-ext-doc-type
      bfpb_arh-fin-doc-contr-s-tax-obj.calc-curr-code   = parbase-code
      bfpb_arh-fin-doc-contr-s-tax-obj.vat-pc           = parvat-pc
      bfpb_arh-fin-doc-contr-s-tax-obj.slt-pc           = parslt-pc
      bfpb_arh-fin-doc-contr-s-tax-obj.with-vat         = parwith-vat
      bfpb_arh-fin-doc-contr-s-tax-obj.with-slt         = parwith-slt
      bfpb_arh-fin-doc-contr-s-tax-obj.sum-type         = parsum-type
      bfpb_arh-fin-doc-contr-s-tax-obj.cource-des       = "b":u
      bfpb_arh-fin-doc-contr-s-tax-obj.fact-order       = parfact-order
      bfpb_arh-fin-doc-contr-s-tax-obj.fin-doc-code     = parfin-doc-code
      bfpb_arh-fin-doc-contr-s-tax-obj.fact-date        = parfact-date
      bfpb_arh-fin-doc-contr-s-tax-obj.curr-code        = parcurr-code
      bfpb_arh-fin-doc-contr-s-tax-obj.income           = (if available bopb_arh-fin-doc-contr-s-tax-obj then bopb_arh-fin-doc-contr-s-tax-obj.income      else 0)
      bfpb_arh-fin-doc-contr-s-tax-obj.income-vat       = (if available bopb_arh-fin-doc-contr-s-tax-obj then bopb_arh-fin-doc-contr-s-tax-obj.income-vat  else 0)
      bfpb_arh-fin-doc-contr-s-tax-obj.income-slt       = (if available bopb_arh-fin-doc-contr-s-tax-obj then bopb_arh-fin-doc-contr-s-tax-obj.income-slt  else 0)
      bfpb_arh-fin-doc-contr-s-tax-obj.expense          = (if available bopb_arh-fin-doc-contr-s-tax-obj then bopb_arh-fin-doc-contr-s-tax-obj.expense     else 0) + parsum-base
      bfpb_arh-fin-doc-contr-s-tax-obj.expense-vat      = (if available bopb_arh-fin-doc-contr-s-tax-obj then bopb_arh-fin-doc-contr-s-tax-obj.expense-vat else 0) + parsum-vat-base
      bfpb_arh-fin-doc-contr-s-tax-obj.expense-slt      = (if available bopb_arh-fin-doc-contr-s-tax-obj then bopb_arh-fin-doc-contr-s-tax-obj.expense-slt else 0) + parsum-slt-base
    .
  end.
  else do:
    find first bfpb_arh-fin-doc-contr-s-tax-obj where bfpb_arh-fin-doc-contr-s-tax-obj.host-code        = parhost-code         and
                                                      bfpb_arh-fin-doc-contr-s-tax-obj.obj-type         = parobj-type          and
                                                      bfpb_arh-fin-doc-contr-s-tax-obj.obj-code         = parobj-code          and
                                                      bfpb_arh-fin-doc-contr-s-tax-obj.cli-type         = parpayer-type        and
                                                      bfpb_arh-fin-doc-contr-s-tax-obj.cli-code         = parpayer-code        and
                                                      bfpb_arh-fin-doc-contr-s-tax-obj.contract-code    = parcontract-code     and
                                                      bfpb_arh-fin-doc-contr-s-tax-obj.code-schet       = parpayer-code-schet  and
                                                      bfpb_arh-fin-doc-contr-s-tax-obj.fin-ext-doc-type = parfin-ext-doc-type  and
                                                      bfpb_arh-fin-doc-contr-s-tax-obj.calc-curr-code   = parbase-code         and
                                                      bfpb_arh-fin-doc-contr-s-tax-obj.vat-pc           = parvat-pc            and
                                                      bfpb_arh-fin-doc-contr-s-tax-obj.slt-pc           = parslt-pc            and
                                                      bfpb_arh-fin-doc-contr-s-tax-obj.with-vat         = parwith-vat          and
                                                      bfpb_arh-fin-doc-contr-s-tax-obj.with-slt         = parwith-slt          and
                                                      bfpb_arh-fin-doc-contr-s-tax-obj.sum-type         = parsum-type          and
                                                      bfpb_arh-fin-doc-contr-s-tax-obj.fact-order       = parfact-order        exclusive-lock.
  end.
  for each rbfpb_arh-fin-doc-contr-s-t-obj where rbfpb_arh-fin-doc-contr-s-t-obj.host-code        = bfpb_arh-fin-doc-contr-s-tax-obj.host-code        and
                                                 rbfpb_arh-fin-doc-contr-s-t-obj.obj-type         = bfpb_arh-fin-doc-contr-s-tax-obj.obj-type         and
                                                 rbfpb_arh-fin-doc-contr-s-t-obj.obj-code         = bfpb_arh-fin-doc-contr-s-tax-obj.obj-code         and
                                                 rbfpb_arh-fin-doc-contr-s-t-obj.cli-type         = parpayer-type                                     and
                                                 rbfpb_arh-fin-doc-contr-s-t-obj.cli-code         = parpayer-code                                     and
                                                 rbfpb_arh-fin-doc-contr-s-t-obj.contract-code    = bfpb_arh-fin-doc-contr-s-tax-obj.contract-code    and
                                                 rbfpb_arh-fin-doc-contr-s-t-obj.code-schet       = bfpb_arh-fin-doc-contr-s-tax-obj.code-schet       and
                                                 rbfpb_arh-fin-doc-contr-s-t-obj.fin-ext-doc-type = bfpb_arh-fin-doc-contr-s-tax-obj.fin-ext-doc-type and
                                                 rbfpb_arh-fin-doc-contr-s-t-obj.calc-curr-code   = bfpb_arh-fin-doc-contr-s-tax-obj.calc-curr-code   and
                                                 rbfpb_arh-fin-doc-contr-s-t-obj.vat-pc           = bfpb_arh-fin-doc-contr-s-tax-obj.vat-pc           and
                                                 rbfpb_arh-fin-doc-contr-s-t-obj.slt-pc           = bfpb_arh-fin-doc-contr-s-tax-obj.slt-pc           and
                                                 rbfpb_arh-fin-doc-contr-s-t-obj.with-vat         = bfpb_arh-fin-doc-contr-s-tax-obj.with-vat         and
                                                 rbfpb_arh-fin-doc-contr-s-t-obj.with-slt         = bfpb_arh-fin-doc-contr-s-tax-obj.with-slt         and
                                                 rbfpb_arh-fin-doc-contr-s-t-obj.sum-type         = bfpb_arh-fin-doc-contr-s-tax-obj.sum-type         and
                                                 rbfpb_arh-fin-doc-contr-s-t-obj.fact-order       > bfpb_arh-fin-doc-contr-s-tax-obj.fact-order       use-index pi exclusive-lock on error undo, return error return-value :
    assign
      rbfpb_arh-fin-doc-contr-s-t-obj.expense     = rbfpb_arh-fin-doc-contr-s-t-obj.expense     + parsum-base
      rbfpb_arh-fin-doc-contr-s-t-obj.expense-vat = rbfpb_arh-fin-doc-contr-s-t-obj.expense-vat + parsum-vat-base
      rbfpb_arh-fin-doc-contr-s-t-obj.expense-slt = rbfpb_arh-fin-doc-contr-s-t-obj.expense-slt + parsum-slt-base
    .
  end.
  if parmode = "close":u then do:
    find last borb_arh-fin-doc-contr-s-tax-obj where borb_arh-fin-doc-contr-s-tax-obj.host-code        = parhost-code            and
                                                     borb_arh-fin-doc-contr-s-tax-obj.obj-type         = parobj-type             and
                                                     borb_arh-fin-doc-contr-s-tax-obj.obj-code         = parobj-code             and
                                                     borb_arh-fin-doc-contr-s-tax-obj.cli-type         = parreceiver-type        and
                                                     borb_arh-fin-doc-contr-s-tax-obj.cli-code         = parreceiver-code        and
                                                     borb_arh-fin-doc-contr-s-tax-obj.contract-code    = parcontract-code        and
                                                     borb_arh-fin-doc-contr-s-tax-obj.code-schet       = parreceiver-code-schet  and
                                                     borb_arh-fin-doc-contr-s-tax-obj.fin-ext-doc-type = parfin-ext-doc-type     and
                                                     borb_arh-fin-doc-contr-s-tax-obj.calc-curr-code   = parbase-code            and
                                                     borb_arh-fin-doc-contr-s-tax-obj.vat-pc           = parvat-pc               and
                                                     borb_arh-fin-doc-contr-s-tax-obj.slt-pc           = parslt-pc               and
                                                     borb_arh-fin-doc-contr-s-tax-obj.with-vat         = parwith-vat             and
                                                     borb_arh-fin-doc-contr-s-tax-obj.with-slt         = parwith-slt             and
                                                     borb_arh-fin-doc-contr-s-tax-obj.sum-type         = parsum-type             use-index pi no-error.
    create bfrb_arh-fin-doc-contr-s-tax-obj.
    assign
      bfrb_arh-fin-doc-contr-s-tax-obj.host-code        = parhost-code
      bfrb_arh-fin-doc-contr-s-tax-obj.obj-type         = parobj-type
      bfrb_arh-fin-doc-contr-s-tax-obj.obj-code         = parobj-code
      bfrb_arh-fin-doc-contr-s-tax-obj.cli-type         = parreceiver-type
      bfrb_arh-fin-doc-contr-s-tax-obj.cli-code         = parreceiver-code
      bfrb_arh-fin-doc-contr-s-tax-obj.contract-code    = parcontract-code
      bfrb_arh-fin-doc-contr-s-tax-obj.code-schet       = parreceiver-code-schet
      bfrb_arh-fin-doc-contr-s-tax-obj.fin-ext-doc-type = parfin-ext-doc-type
      bfrb_arh-fin-doc-contr-s-tax-obj.calc-curr-code   = parbase-code
      bfrb_arh-fin-doc-contr-s-tax-obj.vat-pc           = parvat-pc
      bfrb_arh-fin-doc-contr-s-tax-obj.slt-pc           = parslt-pc
      bfrb_arh-fin-doc-contr-s-tax-obj.with-vat         = parwith-vat
      bfrb_arh-fin-doc-contr-s-tax-obj.with-slt         = parwith-slt
      bfrb_arh-fin-doc-contr-s-tax-obj.sum-type         = parsum-type
      bfrb_arh-fin-doc-contr-s-tax-obj.cource-des       = "b":u
      bfrb_arh-fin-doc-contr-s-tax-obj.fact-order       = parfact-order
      bfrb_arh-fin-doc-contr-s-tax-obj.fin-doc-code     = parfin-doc-code
      bfrb_arh-fin-doc-contr-s-tax-obj.fact-date        = parfact-date
      bfrb_arh-fin-doc-contr-s-tax-obj.curr-code        = parcurr-code
    .
    assign
      bfrb_arh-fin-doc-contr-s-tax-obj.expense          = (if available borb_arh-fin-doc-contr-s-tax-obj then borb_arh-fin-doc-contr-s-tax-obj.expense     else 0)
      bfrb_arh-fin-doc-contr-s-tax-obj.expense-vat      = (if available borb_arh-fin-doc-contr-s-tax-obj then borb_arh-fin-doc-contr-s-tax-obj.expense-vat else 0)
      bfrb_arh-fin-doc-contr-s-tax-obj.expense-slt      = (if available borb_arh-fin-doc-contr-s-tax-obj then borb_arh-fin-doc-contr-s-tax-obj.expense-slt else 0)
      bfrb_arh-fin-doc-contr-s-tax-obj.income           = (if available borb_arh-fin-doc-contr-s-tax-obj then borb_arh-fin-doc-contr-s-tax-obj.income      else 0) + parsum-base
      bfrb_arh-fin-doc-contr-s-tax-obj.income-vat       = (if available borb_arh-fin-doc-contr-s-tax-obj then borb_arh-fin-doc-contr-s-tax-obj.income-vat  else 0) + parsum-vat-base
      bfrb_arh-fin-doc-contr-s-tax-obj.income-slt       = (if available borb_arh-fin-doc-contr-s-tax-obj then borb_arh-fin-doc-contr-s-tax-obj.income-slt  else 0) + parsum-slt-base
    .
  end.
  else do:
    find first bfrb_arh-fin-doc-contr-s-tax-obj where bfrb_arh-fin-doc-contr-s-tax-obj.host-code        = parhost-code            and
                                                      bfrb_arh-fin-doc-contr-s-tax-obj.obj-type         = parobj-type             and
                                                      bfrb_arh-fin-doc-contr-s-tax-obj.obj-code         = parobj-code             and
                                                      bfrb_arh-fin-doc-contr-s-tax-obj.cli-type         = parreceiver-type        and
                                                      bfrb_arh-fin-doc-contr-s-tax-obj.cli-code         = parreceiver-code        and
                                                      bfrb_arh-fin-doc-contr-s-tax-obj.contract-code    = parcontract-code        and
                                                      bfrb_arh-fin-doc-contr-s-tax-obj.code-schet       = parreceiver-code-schet  and
                                                      bfrb_arh-fin-doc-contr-s-tax-obj.fin-ext-doc-type = parfin-ext-doc-type     and
                                                      bfrb_arh-fin-doc-contr-s-tax-obj.calc-curr-code   = parbase-code            and
                                                      bfrb_arh-fin-doc-contr-s-tax-obj.vat-pc           = parvat-pc               and
                                                      bfrb_arh-fin-doc-contr-s-tax-obj.slt-pc           = parslt-pc               and
                                                      bfrb_arh-fin-doc-contr-s-tax-obj.with-vat         = parwith-vat             and
                                                      bfrb_arh-fin-doc-contr-s-tax-obj.with-slt         = parwith-slt             and
                                                      bfrb_arh-fin-doc-contr-s-tax-obj.sum-type         = parsum-type             and
                                                      bfrb_arh-fin-doc-contr-s-tax-obj.fact-order       = parfact-order           exclusive-lock.
  end.
  for each rbfrb_arh-fin-doc-contr-s-t-obj where rbfrb_arh-fin-doc-contr-s-t-obj.host-code        = bfrb_arh-fin-doc-contr-s-tax-obj.host-code        and
                                                 rbfrb_arh-fin-doc-contr-s-t-obj.obj-type         = bfrb_arh-fin-doc-contr-s-tax-obj.obj-type         and
                                                 rbfrb_arh-fin-doc-contr-s-t-obj.obj-code         = bfrb_arh-fin-doc-contr-s-tax-obj.obj-code         and
                                                 rbfrb_arh-fin-doc-contr-s-t-obj.cli-type         = parreceiver-type                                  and
                                                 rbfrb_arh-fin-doc-contr-s-t-obj.cli-code         = parreceiver-code                                  and
                                                 rbfrb_arh-fin-doc-contr-s-t-obj.contract-code    = bfrb_arh-fin-doc-contr-s-tax-obj.contract-code    and
                                                 rbfrb_arh-fin-doc-contr-s-t-obj.code-schet       = bfrb_arh-fin-doc-contr-s-tax-obj.code-schet       and
                                                 rbfrb_arh-fin-doc-contr-s-t-obj.fin-ext-doc-type = bfrb_arh-fin-doc-contr-s-tax-obj.fin-ext-doc-type and
                                                 rbfrb_arh-fin-doc-contr-s-t-obj.calc-curr-code   = bfrb_arh-fin-doc-contr-s-tax-obj.calc-curr-code   and
                                                 rbfrb_arh-fin-doc-contr-s-t-obj.vat-pc           = bfrb_arh-fin-doc-contr-s-tax-obj.vat-pc           and
                                                 rbfrb_arh-fin-doc-contr-s-t-obj.slt-pc           = bfrb_arh-fin-doc-contr-s-tax-obj.slt-pc           and
                                                 rbfrb_arh-fin-doc-contr-s-t-obj.with-vat         = bfrb_arh-fin-doc-contr-s-tax-obj.with-vat         and
                                                 rbfrb_arh-fin-doc-contr-s-t-obj.with-slt         = bfrb_arh-fin-doc-contr-s-tax-obj.with-slt         and
                                                 rbfrb_arh-fin-doc-contr-s-t-obj.sum-type         = bfrb_arh-fin-doc-contr-s-tax-obj.sum-type         and
                                                 rbfrb_arh-fin-doc-contr-s-t-obj.fact-order       > bfrb_arh-fin-doc-contr-s-tax-obj.fact-order       use-index pi exclusive-lock on error undo, return error return-value :
    assign
      rbfrb_arh-fin-doc-contr-s-t-obj.income     = rbfrb_arh-fin-doc-contr-s-t-obj.income     + parsum-base
      rbfrb_arh-fin-doc-contr-s-t-obj.income-vat = rbfrb_arh-fin-doc-contr-s-t-obj.income-vat + parsum-vat-base
      rbfrb_arh-fin-doc-contr-s-t-obj.income-slt = rbfrb_arh-fin-doc-contr-s-t-obj.income-slt + parsum-slt-base
    .
  end.
  if parmode = "delete":u then do:
    delete bfpb_arh-fin-doc-contr-s-tax-obj.
    delete bfrb_arh-fin-doc-contr-s-tax-obj.
  end.
end.
if parrel-dog-code  =  yes          and
   parcurr-dog-code <> parcurr-code and
   parcurr-dog-code <> 0            and
   parcurr-dog-code <> parbase-code then do:
  if parmode = "close":u then do:
    find last bopc_arh-fin-doc-contr-s-tax-obj where bopc_arh-fin-doc-contr-s-tax-obj.host-code        = parhost-code         and
                                                     bopc_arh-fin-doc-contr-s-tax-obj.obj-type         = parobj-type          and
                                                     bopc_arh-fin-doc-contr-s-tax-obj.obj-code         = parobj-code          and
                                                     bopc_arh-fin-doc-contr-s-tax-obj.cli-type         = parpayer-type        and
                                                     bopc_arh-fin-doc-contr-s-tax-obj.cli-code         = parpayer-code        and
                                                     bopc_arh-fin-doc-contr-s-tax-obj.contract-code    = parcontract-code     and
                                                     bopc_arh-fin-doc-contr-s-tax-obj.code-schet       = parpayer-code-schet  and
                                                     bopc_arh-fin-doc-contr-s-tax-obj.fin-ext-doc-type = parfin-ext-doc-type  and
                                                     bopc_arh-fin-doc-contr-s-tax-obj.calc-curr-code   = parcurr-dog-code     and
                                                     bopc_arh-fin-doc-contr-s-tax-obj.vat-pc           = parvat-pc            and
                                                     bopc_arh-fin-doc-contr-s-tax-obj.slt-pc           = parslt-pc            and
                                                     bopc_arh-fin-doc-contr-s-tax-obj.with-vat         = parwith-vat          and
                                                     bopc_arh-fin-doc-contr-s-tax-obj.with-slt         = parwith-slt          and
                                                     bopc_arh-fin-doc-contr-s-tax-obj.sum-type         = parsum-type          and
                                                     bopc_arh-fin-doc-contr-s-tax-obj.fact-order       < parfact-order        use-index pi no-error.
    create bfpc_arh-fin-doc-contr-s-tax-obj.
    assign
      bfpc_arh-fin-doc-contr-s-tax-obj.host-code        = parhost-code
      bfpc_arh-fin-doc-contr-s-tax-obj.obj-type         = parobj-type
      bfpc_arh-fin-doc-contr-s-tax-obj.obj-code         = parobj-code
      bfpc_arh-fin-doc-contr-s-tax-obj.cli-type         = parpayer-type
      bfpc_arh-fin-doc-contr-s-tax-obj.cli-code         = parpayer-code
      bfpc_arh-fin-doc-contr-s-tax-obj.contract-code    = parcontract-code
      bfpc_arh-fin-doc-contr-s-tax-obj.code-schet       = parpayer-code-schet
      bfpc_arh-fin-doc-contr-s-tax-obj.fin-ext-doc-type = parfin-ext-doc-type
      bfpc_arh-fin-doc-contr-s-tax-obj.calc-curr-code   = parcurr-dog-code
      bfpc_arh-fin-doc-contr-s-tax-obj.vat-pc           = parvat-pc
      bfpc_arh-fin-doc-contr-s-tax-obj.slt-pc           = parslt-pc
      bfpc_arh-fin-doc-contr-s-tax-obj.with-vat         = parwith-vat
      bfpc_arh-fin-doc-contr-s-tax-obj.with-slt         = parwith-slt
      bfpc_arh-fin-doc-contr-s-tax-obj.sum-type         = parsum-type
      bfpc_arh-fin-doc-contr-s-tax-obj.cource-des       = "c":u
      bfpc_arh-fin-doc-contr-s-tax-obj.fact-order       = parfact-order
      bfpc_arh-fin-doc-contr-s-tax-obj.fin-doc-code     = parfin-doc-code
      bfpc_arh-fin-doc-contr-s-tax-obj.fact-date        = parfact-date
      bfpc_arh-fin-doc-contr-s-tax-obj.curr-code        = parcurr-code
      bfpc_arh-fin-doc-contr-s-tax-obj.income           = (if available bopc_arh-fin-doc-contr-s-tax-obj then bopc_arh-fin-doc-contr-s-tax-obj.income      else 0)
      bfpc_arh-fin-doc-contr-s-tax-obj.income-vat       = (if available bopc_arh-fin-doc-contr-s-tax-obj then bopc_arh-fin-doc-contr-s-tax-obj.income-vat  else 0)
      bfpc_arh-fin-doc-contr-s-tax-obj.income-slt       = (if available bopc_arh-fin-doc-contr-s-tax-obj then bopc_arh-fin-doc-contr-s-tax-obj.income-slt  else 0)
      bfpc_arh-fin-doc-contr-s-tax-obj.expense          = (if available bopc_arh-fin-doc-contr-s-tax-obj then bopc_arh-fin-doc-contr-s-tax-obj.expense     else 0) + parsum-contr
      bfpc_arh-fin-doc-contr-s-tax-obj.expense-vat      = (if available bopc_arh-fin-doc-contr-s-tax-obj then bopc_arh-fin-doc-contr-s-tax-obj.expense-vat else 0) + parsum-vat-contr
      bfpc_arh-fin-doc-contr-s-tax-obj.expense-slt      = (if available bopc_arh-fin-doc-contr-s-tax-obj then bopc_arh-fin-doc-contr-s-tax-obj.expense-slt else 0) + parsum-slt-contr
    .
  end.
  else do:
    find first bfpc_arh-fin-doc-contr-s-tax-obj where bfpc_arh-fin-doc-contr-s-tax-obj.host-code        = parhost-code         and
                                                      bfpc_arh-fin-doc-contr-s-tax-obj.obj-type         = parobj-type          and
                                                      bfpc_arh-fin-doc-contr-s-tax-obj.obj-code         = parobj-code          and
                                                      bfpc_arh-fin-doc-contr-s-tax-obj.cli-type         = parpayer-type        and
                                                      bfpc_arh-fin-doc-contr-s-tax-obj.cli-code         = parpayer-code        and
                                                      bfpc_arh-fin-doc-contr-s-tax-obj.contract-code    = parcontract-code     and
                                                      bfpc_arh-fin-doc-contr-s-tax-obj.code-schet       = parpayer-code-schet  and
                                                      bfpc_arh-fin-doc-contr-s-tax-obj.fin-ext-doc-type = parfin-ext-doc-type  and
                                                      bfpc_arh-fin-doc-contr-s-tax-obj.calc-curr-code   = parcurr-dog-code     and
                                                      bfpc_arh-fin-doc-contr-s-tax-obj.vat-pc           = parvat-pc            and
                                                      bfpc_arh-fin-doc-contr-s-tax-obj.slt-pc           = parslt-pc            and
                                                      bfpc_arh-fin-doc-contr-s-tax-obj.with-vat         = parwith-vat          and
                                                      bfpc_arh-fin-doc-contr-s-tax-obj.with-slt         = parwith-slt          and
                                                      bfpc_arh-fin-doc-contr-s-tax-obj.sum-type         = parsum-type          and
                                                      bfpc_arh-fin-doc-contr-s-tax-obj.fact-order       = parfact-order        exclusive-lock.
  end.
  for each rbfpc_arh-fin-doc-contr-s-t-obj where rbfpc_arh-fin-doc-contr-s-t-obj.host-code        = bfpc_arh-fin-doc-contr-s-tax-obj.host-code        and
                                                 rbfpc_arh-fin-doc-contr-s-t-obj.obj-type         = bfpc_arh-fin-doc-contr-s-tax-obj.obj-type         and
                                                 rbfpc_arh-fin-doc-contr-s-t-obj.obj-code         = bfpc_arh-fin-doc-contr-s-tax-obj.obj-code         and
                                                 rbfpc_arh-fin-doc-contr-s-t-obj.cli-type         = parpayer-type                                     and
                                                 rbfpc_arh-fin-doc-contr-s-t-obj.cli-code         = parpayer-code                                     and
                                                 rbfpc_arh-fin-doc-contr-s-t-obj.contract-code    = bfpc_arh-fin-doc-contr-s-tax-obj.contract-code    and
                                                 rbfpc_arh-fin-doc-contr-s-t-obj.code-schet       = bfpc_arh-fin-doc-contr-s-tax-obj.code-schet       and
                                                 rbfpc_arh-fin-doc-contr-s-t-obj.fin-ext-doc-type = bfpc_arh-fin-doc-contr-s-tax-obj.fin-ext-doc-type and
                                                 rbfpc_arh-fin-doc-contr-s-t-obj.calc-curr-code   = bfpc_arh-fin-doc-contr-s-tax-obj.calc-curr-code   and
                                                 rbfpc_arh-fin-doc-contr-s-t-obj.vat-pc           = bfpc_arh-fin-doc-contr-s-tax-obj.vat-pc           and
                                                 rbfpc_arh-fin-doc-contr-s-t-obj.slt-pc           = bfpc_arh-fin-doc-contr-s-tax-obj.slt-pc           and
                                                 rbfpc_arh-fin-doc-contr-s-t-obj.with-vat         = bfpc_arh-fin-doc-contr-s-tax-obj.with-vat         and
                                                 rbfpc_arh-fin-doc-contr-s-t-obj.with-slt         = bfpc_arh-fin-doc-contr-s-tax-obj.with-slt         and
                                                 rbfpc_arh-fin-doc-contr-s-t-obj.sum-type         = bfpc_arh-fin-doc-contr-s-tax-obj.sum-type         and
                                                 rbfpc_arh-fin-doc-contr-s-t-obj.fact-order       > bfpc_arh-fin-doc-contr-s-tax-obj.fact-order       use-index pi exclusive-lock on error undo, return error return-value :
    assign
      rbfpc_arh-fin-doc-contr-s-t-obj.expense     = rbfpc_arh-fin-doc-contr-s-t-obj.expense     + parsum-contr
      rbfpc_arh-fin-doc-contr-s-t-obj.expense-vat = rbfpc_arh-fin-doc-contr-s-t-obj.expense-vat + parsum-vat-contr
      rbfpc_arh-fin-doc-contr-s-t-obj.expense-slt = rbfpc_arh-fin-doc-contr-s-t-obj.expense-slt + parsum-slt-contr
    .
  end.
  if parmode = "close":u then do:
    find last borc_arh-fin-doc-contr-s-tax-obj where borc_arh-fin-doc-contr-s-tax-obj.host-code        = parhost-code           and
                                                     borc_arh-fin-doc-contr-s-tax-obj.obj-type         = parobj-type            and
                                                     borc_arh-fin-doc-contr-s-tax-obj.obj-code         = parobj-code            and
                                                     borc_arh-fin-doc-contr-s-tax-obj.cli-type         = parreceiver-type       and
                                                     borc_arh-fin-doc-contr-s-tax-obj.cli-code         = parreceiver-code       and
                                                     borc_arh-fin-doc-contr-s-tax-obj.contract-code    = parcontract-code       and
                                                     borc_arh-fin-doc-contr-s-tax-obj.code-schet       = parreceiver-code-schet and
                                                     borc_arh-fin-doc-contr-s-tax-obj.fin-ext-doc-type = parfin-ext-doc-type    and
                                                     borc_arh-fin-doc-contr-s-tax-obj.calc-curr-code   = parcurr-dog-code       and
                                                     borc_arh-fin-doc-contr-s-tax-obj.vat-pc           = parvat-pc              and
                                                     borc_arh-fin-doc-contr-s-tax-obj.slt-pc           = parslt-pc              and
                                                     borc_arh-fin-doc-contr-s-tax-obj.with-vat         = parwith-vat            and
                                                     borc_arh-fin-doc-contr-s-tax-obj.with-slt         = parwith-slt            and
                                                     borc_arh-fin-doc-contr-s-tax-obj.sum-type         = parsum-type            use-index pi no-error.
    create bfrc_arh-fin-doc-contr-s-tax-obj.
    assign
      bfrc_arh-fin-doc-contr-s-tax-obj.host-code        = parhost-code
      bfrc_arh-fin-doc-contr-s-tax-obj.obj-type         = parobj-type
      bfrc_arh-fin-doc-contr-s-tax-obj.obj-code         = parobj-code
      bfrc_arh-fin-doc-contr-s-tax-obj.cli-type         = parreceiver-type
      bfrc_arh-fin-doc-contr-s-tax-obj.cli-code         = parreceiver-code
      bfrc_arh-fin-doc-contr-s-tax-obj.contract-code    = parcontract-code
      bfrc_arh-fin-doc-contr-s-tax-obj.code-schet       = parreceiver-code-schet
      bfrc_arh-fin-doc-contr-s-tax-obj.fin-ext-doc-type = parfin-ext-doc-type
      bfrc_arh-fin-doc-contr-s-tax-obj.calc-curr-code   = parcurr-dog-code
      bfrc_arh-fin-doc-contr-s-tax-obj.vat-pc           = parvat-pc
      bfrc_arh-fin-doc-contr-s-tax-obj.slt-pc           = parslt-pc
      bfrc_arh-fin-doc-contr-s-tax-obj.with-vat         = parwith-vat
      bfrc_arh-fin-doc-contr-s-tax-obj.with-slt         = parwith-slt
      bfrc_arh-fin-doc-contr-s-tax-obj.sum-type         = parsum-type
      bfrc_arh-fin-doc-contr-s-tax-obj.cource-des       = "c":u
      bfrc_arh-fin-doc-contr-s-tax-obj.fact-order       = parfact-order
      bfrc_arh-fin-doc-contr-s-tax-obj.fin-doc-code     = parfin-doc-code
      bfrc_arh-fin-doc-contr-s-tax-obj.fact-date        = parfact-date
      bfrc_arh-fin-doc-contr-s-tax-obj.curr-code        = parcurr-code
    .
    assign
      bfrc_arh-fin-doc-contr-s-tax-obj.expense          = (if available borc_arh-fin-doc-contr-s-tax-obj then borc_arh-fin-doc-contr-s-tax-obj.expense     else 0)
      bfrc_arh-fin-doc-contr-s-tax-obj.expense-vat      = (if available borc_arh-fin-doc-contr-s-tax-obj then borc_arh-fin-doc-contr-s-tax-obj.expense-vat else 0)
      bfrc_arh-fin-doc-contr-s-tax-obj.expense-slt      = (if available borc_arh-fin-doc-contr-s-tax-obj then borc_arh-fin-doc-contr-s-tax-obj.expense-slt else 0)
      bfrc_arh-fin-doc-contr-s-tax-obj.income           = (if available borc_arh-fin-doc-contr-s-tax-obj then borc_arh-fin-doc-contr-s-tax-obj.income      else 0) + parsum-contr
      bfrc_arh-fin-doc-contr-s-tax-obj.income-vat       = (if available borc_arh-fin-doc-contr-s-tax-obj then borc_arh-fin-doc-contr-s-tax-obj.income-vat  else 0) + parsum-vat-contr
      bfrc_arh-fin-doc-contr-s-tax-obj.income-slt       = (if available borc_arh-fin-doc-contr-s-tax-obj then borc_arh-fin-doc-contr-s-tax-obj.income-slt  else 0) + parsum-slt-contr
    .
  end.
  else do:
    find first bfrc_arh-fin-doc-contr-s-tax-obj where bfrc_arh-fin-doc-contr-s-tax-obj.host-code        = parhost-code           and
                                                      bfrc_arh-fin-doc-contr-s-tax-obj.obj-type         = parobj-type            and
                                                      bfrc_arh-fin-doc-contr-s-tax-obj.obj-code         = parobj-code            and
                                                      bfrc_arh-fin-doc-contr-s-tax-obj.cli-type         = parreceiver-type       and
                                                      bfrc_arh-fin-doc-contr-s-tax-obj.cli-code         = parreceiver-code       and
                                                      bfrc_arh-fin-doc-contr-s-tax-obj.contract-code    = parcontract-code       and
                                                      bfrc_arh-fin-doc-contr-s-tax-obj.code-schet       = parreceiver-code-schet and
                                                      bfrc_arh-fin-doc-contr-s-tax-obj.fin-ext-doc-type = parfin-ext-doc-type    and
                                                      bfrc_arh-fin-doc-contr-s-tax-obj.calc-curr-code   = parcurr-dog-code       and
                                                      bfrc_arh-fin-doc-contr-s-tax-obj.vat-pc           = parvat-pc              and
                                                      bfrc_arh-fin-doc-contr-s-tax-obj.slt-pc           = parslt-pc              and
                                                      bfrc_arh-fin-doc-contr-s-tax-obj.with-vat         = parwith-vat            and
                                                      bfrc_arh-fin-doc-contr-s-tax-obj.with-slt         = parwith-slt            and
                                                      bfrc_arh-fin-doc-contr-s-tax-obj.sum-type         = parsum-type            and
                                                      bfrc_arh-fin-doc-contr-s-tax-obj.fact-order       = parfact-order          exclusive-lock.
  end.
  for each rbfrc_arh-fin-doc-contr-s-t-obj where rbfrc_arh-fin-doc-contr-s-t-obj.host-code        = bfrc_arh-fin-doc-contr-s-tax-obj.host-code        and
                                                 rbfrc_arh-fin-doc-contr-s-t-obj.obj-type         = bfrc_arh-fin-doc-contr-s-tax-obj.obj-type         and
                                                 rbfrc_arh-fin-doc-contr-s-t-obj.obj-code         = bfrc_arh-fin-doc-contr-s-tax-obj.obj-code         and
                                                 rbfrc_arh-fin-doc-contr-s-t-obj.cli-type         = parreceiver-type                                  and
                                                 rbfrc_arh-fin-doc-contr-s-t-obj.cli-code         = parreceiver-code                                  and
                                                 rbfrc_arh-fin-doc-contr-s-t-obj.contract-code    = bfrc_arh-fin-doc-contr-s-tax-obj.contract-code    and
                                                 rbfrc_arh-fin-doc-contr-s-t-obj.code-schet       = bfrc_arh-fin-doc-contr-s-tax-obj.code-schet       and
                                                 rbfrc_arh-fin-doc-contr-s-t-obj.fin-ext-doc-type = bfrc_arh-fin-doc-contr-s-tax-obj.fin-ext-doc-type and
                                                 rbfrc_arh-fin-doc-contr-s-t-obj.calc-curr-code   = bfrc_arh-fin-doc-contr-s-tax-obj.calc-curr-code   and
                                                 rbfrc_arh-fin-doc-contr-s-t-obj.vat-pc           = bfrc_arh-fin-doc-contr-s-tax-obj.vat-pc           and
                                                 rbfrc_arh-fin-doc-contr-s-t-obj.slt-pc           = bfrc_arh-fin-doc-contr-s-tax-obj.slt-pc           and
                                                 rbfrc_arh-fin-doc-contr-s-t-obj.with-vat         = bfrc_arh-fin-doc-contr-s-tax-obj.with-vat         and
                                                 rbfrc_arh-fin-doc-contr-s-t-obj.with-slt         = bfrc_arh-fin-doc-contr-s-tax-obj.with-slt         and
                                                 rbfrc_arh-fin-doc-contr-s-t-obj.sum-type         = bfrc_arh-fin-doc-contr-s-tax-obj.sum-type         and
                                                 rbfrc_arh-fin-doc-contr-s-t-obj.fact-order       > bfrc_arh-fin-doc-contr-s-tax-obj.fact-order       use-index pi exclusive-lock on error undo, return error return-value :
    assign
      rbfrc_arh-fin-doc-contr-s-t-obj.income     = rbfrc_arh-fin-doc-contr-s-t-obj.income     + parsum-contr
      rbfrc_arh-fin-doc-contr-s-t-obj.income-vat = rbfrc_arh-fin-doc-contr-s-t-obj.income-vat + parsum-vat-contr
      rbfrc_arh-fin-doc-contr-s-t-obj.income-slt = rbfrc_arh-fin-doc-contr-s-t-obj.income-slt + parsum-slt-contr
    .
  end.
  if parmode = "delete":u then do:
    delete bfpc_arh-fin-doc-contr-s-tax-obj.
    delete bfrc_arh-fin-doc-contr-s-tax-obj.
  end.
end.
end.
end procedure.
procedure libfarpo_calc-arh-fin-doc-an-n-obj :
define input parameter parmode                    as   character                    no-undo.
define input parameter parhost-code               like ub.fin-doc.host-code         no-undo.
define input parameter parobj-type                like ub.fin-doc.obj-type          no-undo.
define input parameter parobj-code                like ub.fin-doc.obj-code          no-undo.
define input parameter parpayer-type              like ub.fin-doc.payer-type       no-undo.
define input parameter parpayer-code              like ub.fin-doc.payer-code       no-undo.
define input parameter parreceiver-type           like ub.fin-doc.receiver-type    no-undo.
define input parameter parreceiver-code           like ub.fin-doc.receiver-code    no-undo.
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
define buffer bfps_arh-fin-doc-an-nal-obj  for ub.arh-fin-doc-an-nal-obj.
define buffer bfrs_arh-fin-doc-an-nal-obj  for ub.arh-fin-doc-an-nal-obj.
define buffer rbfps_arh-fin-doc-an-nal-obj for ub.arh-fin-doc-an-nal-obj.
define buffer rbfrs_arh-fin-doc-an-nal-obj for ub.arh-fin-doc-an-nal-obj.
define buffer bops_arh-fin-doc-an-nal-obj  for ub.arh-fin-doc-an-nal-obj.
define buffer bors_arh-fin-doc-an-nal-obj  for ub.arh-fin-doc-an-nal-obj.
define buffer bfpr_arh-fin-doc-an-nal-obj  for ub.arh-fin-doc-an-nal-obj.
define buffer bfrr_arh-fin-doc-an-nal-obj  for ub.arh-fin-doc-an-nal-obj.
define buffer rbfpr_arh-fin-doc-an-nal-obj for ub.arh-fin-doc-an-nal-obj.
define buffer rbfrr_arh-fin-doc-an-nal-obj for ub.arh-fin-doc-an-nal-obj.
define buffer bopr_arh-fin-doc-an-nal-obj  for ub.arh-fin-doc-an-nal-obj.
define buffer borr_arh-fin-doc-an-nal-obj  for ub.arh-fin-doc-an-nal-obj.
define buffer bfpb_arh-fin-doc-an-nal-obj  for ub.arh-fin-doc-an-nal-obj.
define buffer bfrb_arh-fin-doc-an-nal-obj  for ub.arh-fin-doc-an-nal-obj.
define buffer rbfpb_arh-fin-doc-an-nal-obj for ub.arh-fin-doc-an-nal-obj.
define buffer rbfrb_arh-fin-doc-an-nal-obj for ub.arh-fin-doc-an-nal-obj.
define buffer bopb_arh-fin-doc-an-nal-obj  for ub.arh-fin-doc-an-nal-obj.
define buffer borb_arh-fin-doc-an-nal-obj  for ub.arh-fin-doc-an-nal-obj.
define buffer bfpc_arh-fin-doc-an-nal-obj  for ub.arh-fin-doc-an-nal-obj.
define buffer bfrc_arh-fin-doc-an-nal-obj  for ub.arh-fin-doc-an-nal-obj.
define buffer rbfpc_arh-fin-doc-an-nal-obj for ub.arh-fin-doc-an-nal-obj.
define buffer rbfrc_arh-fin-doc-an-nal-obj for ub.arh-fin-doc-an-nal-obj.
define buffer bopc_arh-fin-doc-an-nal-obj  for ub.arh-fin-doc-an-nal-obj.
define buffer borc_arh-fin-doc-an-nal-obj  for ub.arh-fin-doc-an-nal-obj.
do on error undo, return error substitute ("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
if parmode = "close":u then do:
  find last bops_arh-fin-doc-an-nal-obj where bops_arh-fin-doc-an-nal-obj.host-code         = parhost-code          and
                                              bops_arh-fin-doc-an-nal-obj.obj-type          = parobj-type           and
                                              bops_arh-fin-doc-an-nal-obj.obj-code          = parobj-code           and
                                              bops_arh-fin-doc-an-nal-obj.cli-type          = parpayer-type         and
                                              bops_arh-fin-doc-an-nal-obj.cli-code          = parpayer-code         and
                                              bops_arh-fin-doc-an-nal-obj.fin-code-acc      = parpayer-fin-code-acc and
                                              bops_arh-fin-doc-an-nal-obj.curr-code         = parcurr-code          and
                                              bops_arh-fin-doc-an-nal-obj.fin-ext-doc-type  = parfin-ext-doc-type   and
                                              bops_arh-fin-doc-an-nal-obj.fin-code-an-uchet = parfin-code-an-uchet  and
                                              bops_arh-fin-doc-an-nal-obj.fin-code-cel-nazn = parfin-code-cel-nazn  and
                                              bops_arh-fin-doc-an-nal-obj.fin-code-cor-acc  = parfin-code-cor-acc   and
                                              bops_arh-fin-doc-an-nal-obj.calc-curr-code    = parcurr-code          and
                                              bops_arh-fin-doc-an-nal-obj.sum-type          = parsum-type           and
                                              bops_arh-fin-doc-an-nal-obj.fact-order        < parfact-order         use-index pi no-error.
  create bfps_arh-fin-doc-an-nal-obj.
  assign
    bfps_arh-fin-doc-an-nal-obj.host-code         = parhost-code
    bfps_arh-fin-doc-an-nal-obj.obj-type          = parobj-type
    bfps_arh-fin-doc-an-nal-obj.obj-code          = parobj-code
    bfps_arh-fin-doc-an-nal-obj.cli-type          = parpayer-type
    bfps_arh-fin-doc-an-nal-obj.cli-code          = parpayer-code
    bfps_arh-fin-doc-an-nal-obj.fin-ext-doc-type  = parfin-ext-doc-type
    bfps_arh-fin-doc-an-nal-obj.fin-code-acc      = parpayer-fin-code-acc
    bfps_arh-fin-doc-an-nal-obj.curr-code         = parcurr-code
    bfps_arh-fin-doc-an-nal-obj.fin-code-an-uchet = parfin-code-an-uchet
    bfps_arh-fin-doc-an-nal-obj.fin-code-cel-nazn = parfin-code-cel-nazn
    bfps_arh-fin-doc-an-nal-obj.fin-code-cor-acc  = parfin-code-cor-acc
    bfps_arh-fin-doc-an-nal-obj.calc-curr-code    = parcurr-code
    bfps_arh-fin-doc-an-nal-obj.sum-type          = parsum-type
    bfps_arh-fin-doc-an-nal-obj.cource-des        = "s":u
    bfps_arh-fin-doc-an-nal-obj.fact-order        = parfact-order
    bfps_arh-fin-doc-an-nal-obj.fin-doc-code      = parfin-doc-code
    bfps_arh-fin-doc-an-nal-obj.fact-date         = parfact-date
    bfps_arh-fin-doc-an-nal-obj.curr-code         = parcurr-code
    bfps_arh-fin-doc-an-nal-obj.income            = (if available bops_arh-fin-doc-an-nal-obj then bops_arh-fin-doc-an-nal-obj.income      else 0)
    bfps_arh-fin-doc-an-nal-obj.income-vat        = (if available bops_arh-fin-doc-an-nal-obj then bops_arh-fin-doc-an-nal-obj.income-vat  else 0)
    bfps_arh-fin-doc-an-nal-obj.income-slt        = (if available bops_arh-fin-doc-an-nal-obj then bops_arh-fin-doc-an-nal-obj.income-slt  else 0)
    bfps_arh-fin-doc-an-nal-obj.expense           = (if available bops_arh-fin-doc-an-nal-obj then bops_arh-fin-doc-an-nal-obj.expense     else 0) + parsum-doc
    bfps_arh-fin-doc-an-nal-obj.expense-vat       = (if available bops_arh-fin-doc-an-nal-obj then bops_arh-fin-doc-an-nal-obj.expense-vat else 0) + parsum-vat-doc
    bfps_arh-fin-doc-an-nal-obj.expense-slt       = (if available bops_arh-fin-doc-an-nal-obj then bops_arh-fin-doc-an-nal-obj.expense-slt else 0) + parsum-slt-doc
  .
end.
else do:
  find first bfps_arh-fin-doc-an-nal-obj where bops_arh-fin-doc-an-nal-obj.host-code         = parhost-code          and
                                               bops_arh-fin-doc-an-nal-obj.obj-type          = parobj-type           and
                                               bops_arh-fin-doc-an-nal-obj.obj-code          = parobj-code           and
                                               bops_arh-fin-doc-an-nal-obj.cli-type          = parpayer-type         and
                                               bops_arh-fin-doc-an-nal-obj.cli-code          = parpayer-code         and
                                               bops_arh-fin-doc-an-nal-obj.fin-code-acc      = parpayer-fin-code-acc and
                                               bops_arh-fin-doc-an-nal-obj.curr-code         = parcurr-code          and
                                               bops_arh-fin-doc-an-nal-obj.fin-ext-doc-type  = parfin-ext-doc-type   and
                                               bops_arh-fin-doc-an-nal-obj.fin-code-an-uchet = parfin-code-an-uchet  and
                                               bops_arh-fin-doc-an-nal-obj.fin-code-cel-nazn = parfin-code-cel-nazn  and
                                               bops_arh-fin-doc-an-nal-obj.fin-code-cor-acc  = parfin-code-cor-acc   and
                                               bops_arh-fin-doc-an-nal-obj.calc-curr-code    = parcurr-code          and
                                               bops_arh-fin-doc-an-nal-obj.sum-type          = parsum-type           use-index pi no-error.
end.
for each rbfps_arh-fin-doc-an-nal-obj where rbfps_arh-fin-doc-an-nal-obj.host-code         = bfps_arh-fin-doc-an-nal-obj.host-code         and
                                            rbfps_arh-fin-doc-an-nal-obj.obj-type          = bfps_arh-fin-doc-an-nal-obj.obj-type          and
                                            rbfps_arh-fin-doc-an-nal-obj.obj-code          = bfps_arh-fin-doc-an-nal-obj.obj-code          and
                                            rbfps_arh-fin-doc-an-nal-obj.cli-type          = parpayer-type                                 and
                                            rbfps_arh-fin-doc-an-nal-obj.cli-code          = parpayer-code                                 and
                                            rbfps_arh-fin-doc-an-nal-obj.fin-ext-doc-type  = bfps_arh-fin-doc-an-nal-obj.fin-ext-doc-type  and
                                            rbfps_arh-fin-doc-an-nal-obj.fin-code-acc      = bfps_arh-fin-doc-an-nal-obj.fin-code-acc      and
                                            rbfps_arh-fin-doc-an-nal-obj.curr-code         = bfps_arh-fin-doc-an-nal-obj.curr-code         and
                                            rbfps_arh-fin-doc-an-nal-obj.fin-code-an-uchet = bfps_arh-fin-doc-an-nal-obj.fin-code-an-uchet and
                                            rbfps_arh-fin-doc-an-nal-obj.fin-code-cel-nazn = bfps_arh-fin-doc-an-nal-obj.fin-code-cel-nazn and
                                            rbfps_arh-fin-doc-an-nal-obj.fin-code-cor-acc  = bfps_arh-fin-doc-an-nal-obj.fin-code-cor-acc  and
                                            rbfps_arh-fin-doc-an-nal-obj.calc-curr-code    = bfps_arh-fin-doc-an-nal-obj.calc-curr-code    and
                                            rbfps_arh-fin-doc-an-nal-obj.sum-type          = bfps_arh-fin-doc-an-nal-obj.sum-type          and
                                            rbfps_arh-fin-doc-an-nal-obj.fact-order        > bfps_arh-fin-doc-an-nal-obj.fact-order        use-index pi exclusive-lock on error undo, return error return-value :
  assign
    rbfps_arh-fin-doc-an-nal-obj.expense     = rbfps_arh-fin-doc-an-nal-obj.expense     + parsum-doc
    rbfps_arh-fin-doc-an-nal-obj.expense-vat = rbfps_arh-fin-doc-an-nal-obj.expense-vat + parsum-vat-doc
    rbfps_arh-fin-doc-an-nal-obj.expense-slt = rbfps_arh-fin-doc-an-nal-obj.expense-slt + parsum-slt-doc
  .
end.
if parmode = "close":u then do:
  find last bors_arh-fin-doc-an-nal-obj where bors_arh-fin-doc-an-nal-obj.host-code         = parhost-code             and
                                              bors_arh-fin-doc-an-nal-obj.obj-type          = parobj-type              and
                                              bors_arh-fin-doc-an-nal-obj.obj-code          = parobj-code              and
                                              bors_arh-fin-doc-an-nal-obj.cli-type          = parreceiver-type         and
                                              bors_arh-fin-doc-an-nal-obj.cli-code          = parreceiver-code         and
                                              bors_arh-fin-doc-an-nal-obj.fin-code-acc      = parreceiver-fin-code-acc and
                                              bors_arh-fin-doc-an-nal-obj.curr-code         = parcurr-code             and
                                              bors_arh-fin-doc-an-nal-obj.fin-ext-doc-type  = parfin-ext-doc-type      and
                                              bors_arh-fin-doc-an-nal-obj.fin-code-an-uchet = parfin-code-an-uchet     and
                                              bors_arh-fin-doc-an-nal-obj.fin-code-cel-nazn = parfin-code-cel-nazn     and
                                              bors_arh-fin-doc-an-nal-obj.fin-code-cor-acc  = parfin-code-cor-acc      and
                                              bors_arh-fin-doc-an-nal-obj.calc-curr-code    = parcurr-code             and
                                              bors_arh-fin-doc-an-nal-obj.sum-type          = parsum-type              and
                                              bors_arh-fin-doc-an-nal-obj.fact-order        < parfact-order            use-index pi no-error.
  create bfrs_arh-fin-doc-an-nal-obj.
  assign
    bfrs_arh-fin-doc-an-nal-obj.host-code         = parhost-code
    bfrs_arh-fin-doc-an-nal-obj.obj-type          = parobj-type
    bfrs_arh-fin-doc-an-nal-obj.obj-code          = parobj-code
    bfrs_arh-fin-doc-an-nal-obj.cli-type          = parreceiver-type
    bfrs_arh-fin-doc-an-nal-obj.cli-code          = parreceiver-code
    bfrs_arh-fin-doc-an-nal-obj.fin-ext-doc-type  = parfin-ext-doc-type
    bfrs_arh-fin-doc-an-nal-obj.fin-code-acc      = parreceiver-fin-code-acc
    bfrs_arh-fin-doc-an-nal-obj.curr-code         = parcurr-code
    bfrs_arh-fin-doc-an-nal-obj.fin-code-an-uchet = parfin-code-an-uchet
    bfrs_arh-fin-doc-an-nal-obj.fin-code-cel-nazn = parfin-code-cel-nazn
    bfrs_arh-fin-doc-an-nal-obj.fin-code-cor-acc  = parfin-code-cor-acc
    bfrs_arh-fin-doc-an-nal-obj.calc-curr-code    = parcurr-code
    bfrs_arh-fin-doc-an-nal-obj.sum-type          = parsum-type
    bfrs_arh-fin-doc-an-nal-obj.cource-des        = "s":u
    bfrs_arh-fin-doc-an-nal-obj.fact-order        = parfact-order
    bfrs_arh-fin-doc-an-nal-obj.fin-doc-code      = parfin-doc-code
    bfrs_arh-fin-doc-an-nal-obj.fact-date         = parfact-date
    bfrs_arh-fin-doc-an-nal-obj.curr-code         = parcurr-code
  .
  assign
    bfrs_arh-fin-doc-an-nal-obj.expense           = (if available bors_arh-fin-doc-an-nal-obj then bors_arh-fin-doc-an-nal-obj.expense     else 0)
    bfrs_arh-fin-doc-an-nal-obj.expense-vat       = (if available bors_arh-fin-doc-an-nal-obj then bors_arh-fin-doc-an-nal-obj.expense-vat else 0)
    bfrs_arh-fin-doc-an-nal-obj.expense-slt       = (if available bors_arh-fin-doc-an-nal-obj then bors_arh-fin-doc-an-nal-obj.expense-slt else 0)
    bfrs_arh-fin-doc-an-nal-obj.income            = (if available bors_arh-fin-doc-an-nal-obj then bors_arh-fin-doc-an-nal-obj.income      else 0) + parsum-doc
    bfrs_arh-fin-doc-an-nal-obj.income-vat        = (if available bors_arh-fin-doc-an-nal-obj then bors_arh-fin-doc-an-nal-obj.income-vat  else 0) + parsum-vat-doc
    bfrs_arh-fin-doc-an-nal-obj.income-slt        = (if available bors_arh-fin-doc-an-nal-obj then bors_arh-fin-doc-an-nal-obj.income-slt  else 0) + parsum-slt-doc
  .
end.
else do:
  find first bfrs_arh-fin-doc-an-nal-obj where bfrs_arh-fin-doc-an-nal-obj.host-code         = parhost-code             and
                                               bfrs_arh-fin-doc-an-nal-obj.obj-type          = parobj-type              and
                                               bfrs_arh-fin-doc-an-nal-obj.obj-code          = parobj-code              and
                                               bfrs_arh-fin-doc-an-nal-obj.cli-type          = parreceiver-type         and
                                               bfrs_arh-fin-doc-an-nal-obj.cli-code          = parreceiver-code         and
                                               bfrs_arh-fin-doc-an-nal-obj.fin-code-acc      = parreceiver-fin-code-acc and
                                               bfrs_arh-fin-doc-an-nal-obj.curr-code         = parcurr-code             and
                                               bfrs_arh-fin-doc-an-nal-obj.fin-ext-doc-type  = parfin-ext-doc-type      and
                                               bfrs_arh-fin-doc-an-nal-obj.fin-code-an-uchet = parfin-code-an-uchet     and
                                               bfrs_arh-fin-doc-an-nal-obj.fin-code-cel-nazn = parfin-code-cel-nazn     and
                                               bfrs_arh-fin-doc-an-nal-obj.fin-code-cor-acc  = parfin-code-cor-acc      and
                                               bfrs_arh-fin-doc-an-nal-obj.calc-curr-code    = parcurr-code             and
                                               bfrs_arh-fin-doc-an-nal-obj.sum-type          = parsum-type              and
                                               bfrs_arh-fin-doc-an-nal-obj.fact-order        = parfact-order            exclusive-lock.
end.
for each rbfrs_arh-fin-doc-an-nal-obj where rbfrs_arh-fin-doc-an-nal-obj.host-code         = bfrs_arh-fin-doc-an-nal-obj.host-code         and
                                            rbfrs_arh-fin-doc-an-nal-obj.obj-type          = bfrs_arh-fin-doc-an-nal-obj.obj-type          and
                                            rbfrs_arh-fin-doc-an-nal-obj.obj-code          = bfrs_arh-fin-doc-an-nal-obj.obj-code          and
                                            rbfrs_arh-fin-doc-an-nal-obj.cli-type          = parreceiver-type                              and
                                            rbfrs_arh-fin-doc-an-nal-obj.cli-code          = parreceiver-code                              and
                                            rbfrs_arh-fin-doc-an-nal-obj.fin-ext-doc-type  = bfrs_arh-fin-doc-an-nal-obj.fin-ext-doc-type  and
                                            rbfrs_arh-fin-doc-an-nal-obj.fin-code-acc      = bfrs_arh-fin-doc-an-nal-obj.fin-code-acc      and
                                            rbfrs_arh-fin-doc-an-nal-obj.curr-code         = bfrs_arh-fin-doc-an-nal-obj.curr-code         and
                                            rbfrs_arh-fin-doc-an-nal-obj.fin-code-an-uchet = bfrs_arh-fin-doc-an-nal-obj.fin-code-an-uchet and
                                            rbfrs_arh-fin-doc-an-nal-obj.fin-code-cel-nazn = bfrs_arh-fin-doc-an-nal-obj.fin-code-cel-nazn and
                                            rbfrs_arh-fin-doc-an-nal-obj.fin-code-cor-acc  = bfrs_arh-fin-doc-an-nal-obj.fin-code-cor-acc  and
                                            rbfrs_arh-fin-doc-an-nal-obj.calc-curr-code    = bfrs_arh-fin-doc-an-nal-obj.calc-curr-code    and
                                            rbfrs_arh-fin-doc-an-nal-obj.sum-type          = bfrs_arh-fin-doc-an-nal-obj.sum-type          and
                                            rbfrs_arh-fin-doc-an-nal-obj.fact-order        > bfrs_arh-fin-doc-an-nal-obj.fact-order        use-index pi exclusive-lock on error undo, return error return-value :
  assign
    rbfrs_arh-fin-doc-an-nal-obj.income     = rbfrs_arh-fin-doc-an-nal-obj.income     + parsum-doc
    rbfrs_arh-fin-doc-an-nal-obj.income-vat = rbfrs_arh-fin-doc-an-nal-obj.income-vat + parsum-vat-doc
    rbfrs_arh-fin-doc-an-nal-obj.income-slt = rbfrs_arh-fin-doc-an-nal-obj.income-slt + parsum-slt-doc
  .
end.
if parmode = "delete":u then do:
  delete bfps_arh-fin-doc-an-nal-obj.
  delete bfrs_arh-fin-doc-an-nal-obj.
end.
if parcurr-code <> 0 then do:
  if parmode = "close":u then do:
    find last bopr_arh-fin-doc-an-nal-obj where bopr_arh-fin-doc-an-nal-obj.host-code         = parhost-code          and
                                                bopr_arh-fin-doc-an-nal-obj.obj-type          = parobj-type           and
                                                bopr_arh-fin-doc-an-nal-obj.obj-code          = parobj-code           and
                                                bopr_arh-fin-doc-an-nal-obj.cli-type          = parpayer-type         and
                                                bopr_arh-fin-doc-an-nal-obj.cli-code          = parpayer-code         and
                                                bopr_arh-fin-doc-an-nal-obj.fin-code-acc      = parpayer-fin-code-acc and
                                                bopr_arh-fin-doc-an-nal-obj.curr-code         = parcurr-code          and
                                                bopr_arh-fin-doc-an-nal-obj.fin-ext-doc-type  = parfin-ext-doc-type   and
                                                bopr_arh-fin-doc-an-nal-obj.fin-code-an-uchet = parfin-code-an-uchet  and
                                                bopr_arh-fin-doc-an-nal-obj.fin-code-cel-nazn = parfin-code-cel-nazn  and
                                                bopr_arh-fin-doc-an-nal-obj.fin-code-cor-acc  = parfin-code-cor-acc   and
                                                bopr_arh-fin-doc-an-nal-obj.calc-curr-code    = 0                     and
                                                bopr_arh-fin-doc-an-nal-obj.sum-type          = parsum-type           and
                                                bopr_arh-fin-doc-an-nal-obj.fact-order        < parfact-order         use-index pi no-error.
    create bfpr_arh-fin-doc-an-nal-obj.
    assign
      bfpr_arh-fin-doc-an-nal-obj.host-code         = parhost-code
      bfpr_arh-fin-doc-an-nal-obj.obj-type          = parobj-type
      bfpr_arh-fin-doc-an-nal-obj.obj-code          = parobj-code
      bfpr_arh-fin-doc-an-nal-obj.cli-type          = parpayer-type
      bfpr_arh-fin-doc-an-nal-obj.cli-code          = parpayer-code
      bfpr_arh-fin-doc-an-nal-obj.fin-code-acc      = parpayer-fin-code-acc
      bfpr_arh-fin-doc-an-nal-obj.curr-code         = parcurr-code
      bfpr_arh-fin-doc-an-nal-obj.fin-ext-doc-type  = parfin-ext-doc-type
      bfpr_arh-fin-doc-an-nal-obj.fin-code-an-uchet = parfin-code-an-uchet
      bfpr_arh-fin-doc-an-nal-obj.fin-code-cel-nazn = parfin-code-cel-nazn
      bfpr_arh-fin-doc-an-nal-obj.fin-code-cor-acc  = parfin-code-cor-acc
      bfpr_arh-fin-doc-an-nal-obj.calc-curr-code    = 0
      bfpr_arh-fin-doc-an-nal-obj.sum-type          = parsum-type
      bfpr_arh-fin-doc-an-nal-obj.cource-des        = "r":u
      bfpr_arh-fin-doc-an-nal-obj.fact-order        = parfact-order
      bfpr_arh-fin-doc-an-nal-obj.fin-doc-code      = parfin-doc-code
      bfpr_arh-fin-doc-an-nal-obj.fact-date         = parfact-date
      bfpr_arh-fin-doc-an-nal-obj.curr-code         = parcurr-code
      bfpr_arh-fin-doc-an-nal-obj.income            = (if available bopr_arh-fin-doc-an-nal-obj then bopr_arh-fin-doc-an-nal-obj.income      else 0)
      bfpr_arh-fin-doc-an-nal-obj.income-vat        = (if available bopr_arh-fin-doc-an-nal-obj then bopr_arh-fin-doc-an-nal-obj.income-vat  else 0)
      bfpr_arh-fin-doc-an-nal-obj.income-slt        = (if available bopr_arh-fin-doc-an-nal-obj then bopr_arh-fin-doc-an-nal-obj.income-slt  else 0)
      bfpr_arh-fin-doc-an-nal-obj.expense           = (if available bopr_arh-fin-doc-an-nal-obj then bopr_arh-fin-doc-an-nal-obj.expense     else 0) + parsum-rubl
      bfpr_arh-fin-doc-an-nal-obj.expense-vat       = (if available bopr_arh-fin-doc-an-nal-obj then bopr_arh-fin-doc-an-nal-obj.expense-vat else 0) + parsum-vat-rubl
      bfpr_arh-fin-doc-an-nal-obj.expense-slt       = (if available bopr_arh-fin-doc-an-nal-obj then bopr_arh-fin-doc-an-nal-obj.expense-slt else 0) + parsum-slt-rubl
    .
  end.
  else do:
    find first bfpr_arh-fin-doc-an-nal-obj where bfpr_arh-fin-doc-an-nal-obj.host-code         = parhost-code          and
                                                 bfpr_arh-fin-doc-an-nal-obj.obj-type          = parobj-type           and
                                                 bfpr_arh-fin-doc-an-nal-obj.obj-code          = parobj-code           and
                                                 bfpr_arh-fin-doc-an-nal-obj.cli-type          = parpayer-type         and
                                                 bfpr_arh-fin-doc-an-nal-obj.cli-code          = parpayer-code         and
                                                 bfpr_arh-fin-doc-an-nal-obj.fin-code-acc      = parpayer-fin-code-acc and
                                                 bfpr_arh-fin-doc-an-nal-obj.curr-code         = parcurr-code          and
                                                 bfpr_arh-fin-doc-an-nal-obj.fin-ext-doc-type  = parfin-ext-doc-type   and
                                                 bfpr_arh-fin-doc-an-nal-obj.fin-code-an-uchet = parfin-code-an-uchet  and
                                                 bfpr_arh-fin-doc-an-nal-obj.fin-code-cel-nazn = parfin-code-cel-nazn  and
                                                 bfpr_arh-fin-doc-an-nal-obj.fin-code-cor-acc  = parfin-code-cor-acc   and
                                                 bfpr_arh-fin-doc-an-nal-obj.calc-curr-code    = 0                     and
                                                 bfpr_arh-fin-doc-an-nal-obj.sum-type          = parsum-type           and
                                                 bfpr_arh-fin-doc-an-nal-obj.fact-order        = parfact-order         exclusive-lock.
  end.
  for each rbfpr_arh-fin-doc-an-nal-obj where rbfpr_arh-fin-doc-an-nal-obj.host-code         = bfpr_arh-fin-doc-an-nal-obj.host-code         and
                                              rbfpr_arh-fin-doc-an-nal-obj.obj-type          = bfpr_arh-fin-doc-an-nal-obj.obj-type          and
                                              rbfpr_arh-fin-doc-an-nal-obj.obj-code          = bfpr_arh-fin-doc-an-nal-obj.obj-code          and
                                              rbfpr_arh-fin-doc-an-nal-obj.cli-type          = parpayer-type                                 and
                                              rbfpr_arh-fin-doc-an-nal-obj.cli-code          = parpayer-code                                 and
                                              rbfpr_arh-fin-doc-an-nal-obj.fin-code-acc      = bfpr_arh-fin-doc-an-nal-obj.fin-code-acc      and
                                              rbfpr_arh-fin-doc-an-nal-obj.curr-code         = bfpr_arh-fin-doc-an-nal-obj.curr-code         and
                                              rbfpr_arh-fin-doc-an-nal-obj.fin-ext-doc-type  = bfpr_arh-fin-doc-an-nal-obj.fin-ext-doc-type  and
                                              rbfpr_arh-fin-doc-an-nal-obj.fin-code-an-uchet = bfpr_arh-fin-doc-an-nal-obj.fin-code-an-uchet and
                                              rbfpr_arh-fin-doc-an-nal-obj.fin-code-cel-nazn = bfpr_arh-fin-doc-an-nal-obj.fin-code-cel-nazn and
                                              rbfpr_arh-fin-doc-an-nal-obj.fin-code-cor-acc  = bfpr_arh-fin-doc-an-nal-obj.fin-code-cor-acc  and
                                              rbfpr_arh-fin-doc-an-nal-obj.calc-curr-code    = bfpr_arh-fin-doc-an-nal-obj.calc-curr-code    and
                                              rbfpr_arh-fin-doc-an-nal-obj.sum-type          = bfpr_arh-fin-doc-an-nal-obj.sum-type          and
                                              rbfpr_arh-fin-doc-an-nal-obj.fact-order        > bfpr_arh-fin-doc-an-nal-obj.fact-order        use-index pi on error undo, return error return-value :
    assign
      rbfpr_arh-fin-doc-an-nal-obj.expense     = rbfpr_arh-fin-doc-an-nal-obj.expense     + parsum-rubl
      rbfpr_arh-fin-doc-an-nal-obj.expense-vat = rbfpr_arh-fin-doc-an-nal-obj.expense-vat + parsum-vat-rubl
      rbfpr_arh-fin-doc-an-nal-obj.expense-slt = rbfpr_arh-fin-doc-an-nal-obj.expense-slt + parsum-slt-rubl
    .
  end.
  if parmode = "close":u then do:
    find last borr_arh-fin-doc-an-nal-obj where borr_arh-fin-doc-an-nal-obj.host-code         = parhost-code             and
                                                borr_arh-fin-doc-an-nal-obj.obj-type          = parobj-type              and
                                                borr_arh-fin-doc-an-nal-obj.obj-code          = parobj-code              and
                                                borr_arh-fin-doc-an-nal-obj.cli-type          = parreceiver-type         and
                                                borr_arh-fin-doc-an-nal-obj.cli-code          = parreceiver-code         and
                                                borr_arh-fin-doc-an-nal-obj.fin-code-acc      = parreceiver-fin-code-acc and
                                                borr_arh-fin-doc-an-nal-obj.curr-code         = parcurr-code             and
                                                borr_arh-fin-doc-an-nal-obj.fin-ext-doc-type  = parfin-ext-doc-type      and
                                                borr_arh-fin-doc-an-nal-obj.fin-code-an-uchet = parfin-code-an-uchet     and
                                                borr_arh-fin-doc-an-nal-obj.fin-code-cel-nazn = parfin-code-cel-nazn     and
                                                borr_arh-fin-doc-an-nal-obj.fin-code-cor-acc  = parfin-code-cor-acc      and
                                                borr_arh-fin-doc-an-nal-obj.calc-curr-code    = 0                        and
                                                borr_arh-fin-doc-an-nal-obj.sum-type          = parsum-type              and
                                                borr_arh-fin-doc-an-nal-obj.fact-order        < parfact-order            use-index pi no-error.
    create bfrr_arh-fin-doc-an-nal-obj.
    assign
      bfrr_arh-fin-doc-an-nal-obj.host-code         = parhost-code
      bfrr_arh-fin-doc-an-nal-obj.obj-type          = parobj-type
      bfrr_arh-fin-doc-an-nal-obj.obj-code          = parobj-code
      bfrr_arh-fin-doc-an-nal-obj.cli-type          = parreceiver-type
      bfrr_arh-fin-doc-an-nal-obj.cli-code          = parreceiver-code
      bfrr_arh-fin-doc-an-nal-obj.fin-code-acc      = parreceiver-fin-code-acc
      bfrr_arh-fin-doc-an-nal-obj.curr-code         = parcurr-code
      bfrr_arh-fin-doc-an-nal-obj.fin-ext-doc-type  = parfin-ext-doc-type
      bfrr_arh-fin-doc-an-nal-obj.fin-code-an-uchet = parfin-code-an-uchet
      bfrr_arh-fin-doc-an-nal-obj.fin-code-cel-nazn = parfin-code-cel-nazn
      bfrr_arh-fin-doc-an-nal-obj.fin-code-cor-acc  = parfin-code-cor-acc
      bfrr_arh-fin-doc-an-nal-obj.calc-curr-code    = 0
      bfrr_arh-fin-doc-an-nal-obj.sum-type          = parsum-type
      bfrr_arh-fin-doc-an-nal-obj.cource-des        = "r":u
      bfrr_arh-fin-doc-an-nal-obj.fact-order        = parfact-order
      bfrr_arh-fin-doc-an-nal-obj.fin-doc-code      = parfin-doc-code
      bfrr_arh-fin-doc-an-nal-obj.fact-date         = parfact-date
      bfrr_arh-fin-doc-an-nal-obj.curr-code         = parcurr-code
     .
    assign
      bfrr_arh-fin-doc-an-nal-obj.expense           = (if available borr_arh-fin-doc-an-nal-obj then borr_arh-fin-doc-an-nal-obj.expense     else 0)
      bfrr_arh-fin-doc-an-nal-obj.expense-vat       = (if available borr_arh-fin-doc-an-nal-obj then borr_arh-fin-doc-an-nal-obj.expense-vat else 0)
      bfrr_arh-fin-doc-an-nal-obj.expense-slt       = (if available borr_arh-fin-doc-an-nal-obj then borr_arh-fin-doc-an-nal-obj.expense-slt else 0)
      bfrr_arh-fin-doc-an-nal-obj.income            = (if available borr_arh-fin-doc-an-nal-obj then borr_arh-fin-doc-an-nal-obj.income      else 0) + parsum-rubl
      bfrr_arh-fin-doc-an-nal-obj.income-vat        = (if available borr_arh-fin-doc-an-nal-obj then borr_arh-fin-doc-an-nal-obj.income-vat  else 0) + parsum-vat-rubl
      bfrr_arh-fin-doc-an-nal-obj.income-slt        = (if available borr_arh-fin-doc-an-nal-obj then borr_arh-fin-doc-an-nal-obj.income-slt  else 0) + parsum-slt-rubl
    .
  end.
  else do:
    find last bfrr_arh-fin-doc-an-nal-obj where bfrr_arh-fin-doc-an-nal-obj.host-code         = parhost-code             and
                                                bfrr_arh-fin-doc-an-nal-obj.obj-type          = parobj-type              and
                                                bfrr_arh-fin-doc-an-nal-obj.obj-code          = parobj-code              and
                                                bfrr_arh-fin-doc-an-nal-obj.cli-type          = parreceiver-type         and
                                                bfrr_arh-fin-doc-an-nal-obj.cli-code          = parreceiver-code         and
                                                bfrr_arh-fin-doc-an-nal-obj.fin-code-acc      = parreceiver-fin-code-acc and
                                                bfrr_arh-fin-doc-an-nal-obj.curr-code         = parcurr-code             and
                                                bfrr_arh-fin-doc-an-nal-obj.fin-ext-doc-type  = parfin-ext-doc-type      and
                                                bfrr_arh-fin-doc-an-nal-obj.fin-code-an-uchet = parfin-code-an-uchet     and
                                                bfrr_arh-fin-doc-an-nal-obj.fin-code-cel-nazn = parfin-code-cel-nazn     and
                                                bfrr_arh-fin-doc-an-nal-obj.fin-code-cor-acc  = parfin-code-cor-acc      and
                                                bfrr_arh-fin-doc-an-nal-obj.calc-curr-code    = 0                        and
                                                bfrr_arh-fin-doc-an-nal-obj.sum-type          = parsum-type              and
                                                bfrr_arh-fin-doc-an-nal-obj.fact-order        = parfact-order            exclusive-lock.
  end.
  for each rbfrr_arh-fin-doc-an-nal-obj where rbfrr_arh-fin-doc-an-nal-obj.host-code         = bfrr_arh-fin-doc-an-nal-obj.host-code         and
                                              rbfrr_arh-fin-doc-an-nal-obj.obj-type          = bfrr_arh-fin-doc-an-nal-obj.obj-type          and
                                              rbfrr_arh-fin-doc-an-nal-obj.obj-code          = bfrr_arh-fin-doc-an-nal-obj.obj-code          and
                                              rbfrr_arh-fin-doc-an-nal-obj.cli-type          = parreceiver-type                              and
                                              rbfrr_arh-fin-doc-an-nal-obj.cli-code          = parreceiver-code                              and
                                              rbfrr_arh-fin-doc-an-nal-obj.fin-code-acc      = bfrr_arh-fin-doc-an-nal-obj.fin-code-acc      and
                                              rbfrr_arh-fin-doc-an-nal-obj.curr-code         = bfrr_arh-fin-doc-an-nal-obj.curr-code         and
                                              rbfrr_arh-fin-doc-an-nal-obj.fin-ext-doc-type  = bfrr_arh-fin-doc-an-nal-obj.fin-ext-doc-type  and
                                              rbfrr_arh-fin-doc-an-nal-obj.fin-code-an-uchet = bfrr_arh-fin-doc-an-nal-obj.fin-code-an-uchet and
                                              rbfrr_arh-fin-doc-an-nal-obj.fin-code-cel-nazn = bfrr_arh-fin-doc-an-nal-obj.fin-code-cel-nazn and
                                              rbfrr_arh-fin-doc-an-nal-obj.fin-code-cor-acc  = bfrr_arh-fin-doc-an-nal-obj.fin-code-cor-acc  and
                                              rbfrr_arh-fin-doc-an-nal-obj.calc-curr-code    = bfrr_arh-fin-doc-an-nal-obj.calc-curr-code    and
                                              rbfrr_arh-fin-doc-an-nal-obj.sum-type          = bfrr_arh-fin-doc-an-nal-obj.sum-type          and
                                              rbfrr_arh-fin-doc-an-nal-obj.fact-order        > bfrr_arh-fin-doc-an-nal-obj.fact-order        use-index pi exclusive-lock on error undo, return error return-value :
    assign
      rbfrr_arh-fin-doc-an-nal-obj.income     = rbfrr_arh-fin-doc-an-nal-obj.income     + parsum-rubl
      rbfrr_arh-fin-doc-an-nal-obj.income-vat = rbfrr_arh-fin-doc-an-nal-obj.income-vat + parsum-vat-rubl
      rbfrr_arh-fin-doc-an-nal-obj.income-slt = rbfrr_arh-fin-doc-an-nal-obj.income-slt + parsum-slt-rubl
    .
  end.
  if parmode = "delete":u then do:
    delete bfpr_arh-fin-doc-an-nal-obj.
    delete bfrr_arh-fin-doc-an-nal-obj.
  end.
end.
if parbase-code <> parcurr-code and
   parbase-code <> 0            then do:
  if parmode = "close":u then do:
    find last bopb_arh-fin-doc-an-nal-obj where bopb_arh-fin-doc-an-nal-obj.host-code         = parhost-code          and
                                                bopb_arh-fin-doc-an-nal-obj.obj-type          = parobj-type           and
                                                bopb_arh-fin-doc-an-nal-obj.obj-code          = parobj-code           and
                                                bopb_arh-fin-doc-an-nal-obj.cli-type          = parpayer-type         and
                                                bopb_arh-fin-doc-an-nal-obj.cli-code          = parpayer-code         and
                                                bopb_arh-fin-doc-an-nal-obj.fin-code-acc      = parpayer-fin-code-acc and
                                                bopb_arh-fin-doc-an-nal-obj.curr-code         = parcurr-code          and
                                                bopb_arh-fin-doc-an-nal-obj.fin-ext-doc-type  = parfin-ext-doc-type   and
                                                bopb_arh-fin-doc-an-nal-obj.fin-code-an-uchet = parfin-code-an-uchet  and
                                                bopb_arh-fin-doc-an-nal-obj.fin-code-cel-nazn = parfin-code-cel-nazn  and
                                                bopb_arh-fin-doc-an-nal-obj.fin-code-cor-acc  = parfin-code-cor-acc   and
                                                bopb_arh-fin-doc-an-nal-obj.calc-curr-code    = parbase-code          and
                                                bopb_arh-fin-doc-an-nal-obj.sum-type          = parsum-type           and
                                                bopb_arh-fin-doc-an-nal-obj.fact-order        < parfact-order         use-index pi no-error.
    create bfpb_arh-fin-doc-an-nal-obj.
    assign
      bfpb_arh-fin-doc-an-nal-obj.host-code         = parhost-code
      bfpb_arh-fin-doc-an-nal-obj.obj-type          = parobj-type
      bfpb_arh-fin-doc-an-nal-obj.obj-code          = parobj-code
      bfpb_arh-fin-doc-an-nal-obj.cli-type          = parpayer-type
      bfpb_arh-fin-doc-an-nal-obj.cli-code          = parpayer-code
      bfpb_arh-fin-doc-an-nal-obj.fin-code-acc      = parpayer-fin-code-acc
      bfpb_arh-fin-doc-an-nal-obj.curr-code         = parcurr-code
      bfpb_arh-fin-doc-an-nal-obj.fin-ext-doc-type  = parfin-ext-doc-type
      bfpb_arh-fin-doc-an-nal-obj.fin-code-an-uchet = parfin-code-an-uchet
      bfpb_arh-fin-doc-an-nal-obj.fin-code-cel-nazn = parfin-code-cel-nazn
      bfpb_arh-fin-doc-an-nal-obj.fin-code-cor-acc  = parfin-code-cor-acc
      bfpb_arh-fin-doc-an-nal-obj.calc-curr-code    = parbase-code
      bfpb_arh-fin-doc-an-nal-obj.sum-type          = parsum-type
      bfpb_arh-fin-doc-an-nal-obj.cource-des        = "b":u
      bfpb_arh-fin-doc-an-nal-obj.fact-order        = parfact-order
      bfpb_arh-fin-doc-an-nal-obj.fin-doc-code      = parfin-doc-code
      bfpb_arh-fin-doc-an-nal-obj.fact-date         = parfact-date
      bfpb_arh-fin-doc-an-nal-obj.curr-code         = parcurr-code
      bfpb_arh-fin-doc-an-nal-obj.income            = (if available bopb_arh-fin-doc-an-nal-obj then bopb_arh-fin-doc-an-nal-obj.income      else 0)
      bfpb_arh-fin-doc-an-nal-obj.income-vat        = (if available bopb_arh-fin-doc-an-nal-obj then bopb_arh-fin-doc-an-nal-obj.income-vat  else 0)
      bfpb_arh-fin-doc-an-nal-obj.income-slt        = (if available bopb_arh-fin-doc-an-nal-obj then bopb_arh-fin-doc-an-nal-obj.income-slt  else 0)
      bfpb_arh-fin-doc-an-nal-obj.expense           = (if available bopb_arh-fin-doc-an-nal-obj then bopb_arh-fin-doc-an-nal-obj.expense     else 0) + parsum-base
      bfpb_arh-fin-doc-an-nal-obj.expense-vat       = (if available bopb_arh-fin-doc-an-nal-obj then bopb_arh-fin-doc-an-nal-obj.expense-vat else 0) + parsum-vat-base
      bfpb_arh-fin-doc-an-nal-obj.expense-slt       = (if available bopb_arh-fin-doc-an-nal-obj then bopb_arh-fin-doc-an-nal-obj.expense-slt else 0) + parsum-slt-base
    .
  end.
  else do:
    find first bfpb_arh-fin-doc-an-nal-obj where bfpb_arh-fin-doc-an-nal-obj.host-code         = parhost-code          and
                                                 bfpb_arh-fin-doc-an-nal-obj.obj-type          = parobj-type           and
                                                 bfpb_arh-fin-doc-an-nal-obj.obj-code          = parobj-code           and
                                                 bfpb_arh-fin-doc-an-nal-obj.cli-type          = parpayer-type         and
                                                 bfpb_arh-fin-doc-an-nal-obj.cli-code          = parpayer-code         and
                                                 bfpb_arh-fin-doc-an-nal-obj.fin-code-acc      = parpayer-fin-code-acc and
                                                 bfpb_arh-fin-doc-an-nal-obj.curr-code         = parcurr-code          and
                                                 bfpb_arh-fin-doc-an-nal-obj.fin-ext-doc-type  = parfin-ext-doc-type   and
                                                 bfpb_arh-fin-doc-an-nal-obj.fin-code-an-uchet = parfin-code-an-uchet  and
                                                 bfpb_arh-fin-doc-an-nal-obj.fin-code-cel-nazn = parfin-code-cel-nazn  and
                                                 bfpb_arh-fin-doc-an-nal-obj.fin-code-cor-acc  = parfin-code-cor-acc   and
                                                 bfpb_arh-fin-doc-an-nal-obj.calc-curr-code    = parbase-code          and
                                                 bfpb_arh-fin-doc-an-nal-obj.sum-type          = parsum-type           and
                                                 bfpb_arh-fin-doc-an-nal-obj.fact-order        = parfact-order         exclusive-lock.
  end.
  for each rbfpb_arh-fin-doc-an-nal-obj where rbfpb_arh-fin-doc-an-nal-obj.host-code         = bfpb_arh-fin-doc-an-nal-obj.host-code         and
                                              rbfpb_arh-fin-doc-an-nal-obj.obj-type          = bfpb_arh-fin-doc-an-nal-obj.obj-type          and
                                              rbfpb_arh-fin-doc-an-nal-obj.obj-code          = bfpb_arh-fin-doc-an-nal-obj.obj-code          and
                                              rbfpb_arh-fin-doc-an-nal-obj.cli-type          = parpayer-type                                 and
                                              rbfpb_arh-fin-doc-an-nal-obj.cli-code          = parpayer-code                                 and
                                              rbfpb_arh-fin-doc-an-nal-obj.fin-code-acc      = bfpb_arh-fin-doc-an-nal-obj.fin-code-acc      and
                                              rbfpb_arh-fin-doc-an-nal-obj.curr-code         = bfpb_arh-fin-doc-an-nal-obj.curr-code         and
                                              rbfpb_arh-fin-doc-an-nal-obj.fin-ext-doc-type  = bfpb_arh-fin-doc-an-nal-obj.fin-ext-doc-type  and
                                              rbfpb_arh-fin-doc-an-nal-obj.fin-code-an-uchet = bfpb_arh-fin-doc-an-nal-obj.fin-code-an-uchet and
                                              rbfpb_arh-fin-doc-an-nal-obj.fin-code-cel-nazn = bfpb_arh-fin-doc-an-nal-obj.fin-code-cel-nazn and
                                              rbfpb_arh-fin-doc-an-nal-obj.fin-code-cor-acc  = bfpb_arh-fin-doc-an-nal-obj.fin-code-cor-acc  and
                                              rbfpb_arh-fin-doc-an-nal-obj.calc-curr-code    = bfpb_arh-fin-doc-an-nal-obj.calc-curr-code    and
                                              rbfpb_arh-fin-doc-an-nal-obj.sum-type          = bfpb_arh-fin-doc-an-nal-obj.sum-type          and
                                              rbfpb_arh-fin-doc-an-nal-obj.fact-order        > bfpb_arh-fin-doc-an-nal-obj.fact-order        use-index pi exclusive-lock on error undo, return error return-value :
    assign
      rbfpb_arh-fin-doc-an-nal-obj.expense     = rbfpb_arh-fin-doc-an-nal-obj.expense     + parsum-base
      rbfpb_arh-fin-doc-an-nal-obj.expense-vat = rbfpb_arh-fin-doc-an-nal-obj.expense-vat + parsum-vat-base
      rbfpb_arh-fin-doc-an-nal-obj.expense-slt = rbfpb_arh-fin-doc-an-nal-obj.expense-slt + parsum-slt-base
    .
  end.
  if parmode = "close":u then do:
    find last borb_arh-fin-doc-an-nal-obj where borb_arh-fin-doc-an-nal-obj.host-code         = parhost-code             and
                                                borb_arh-fin-doc-an-nal-obj.obj-type          = parobj-type              and
                                                borb_arh-fin-doc-an-nal-obj.obj-code          = parobj-code              and
                                                borb_arh-fin-doc-an-nal-obj.cli-type          = parreceiver-type         and
                                                borb_arh-fin-doc-an-nal-obj.cli-code          = parreceiver-code         and
                                                borb_arh-fin-doc-an-nal-obj.fin-code-acc      = parreceiver-fin-code-acc and
                                                borb_arh-fin-doc-an-nal-obj.curr-code         = parcurr-code             and
                                                borb_arh-fin-doc-an-nal-obj.fin-ext-doc-type  = parfin-ext-doc-type      and
                                                borb_arh-fin-doc-an-nal-obj.fin-code-an-uchet = parfin-code-an-uchet     and
                                                borb_arh-fin-doc-an-nal-obj.fin-code-cel-nazn = parfin-code-cel-nazn     and
                                                borb_arh-fin-doc-an-nal-obj.fin-code-cor-acc  = parfin-code-cor-acc      and
                                                borb_arh-fin-doc-an-nal-obj.calc-curr-code    = parbase-code             and
                                                borb_arh-fin-doc-an-nal-obj.sum-type          = parsum-type              and
                                                borb_arh-fin-doc-an-nal-obj.fact-order        < parfact-order            use-index pi no-error.
    create bfrb_arh-fin-doc-an-nal-obj.
    assign
      bfrb_arh-fin-doc-an-nal-obj.host-code         = parhost-code
      bfrb_arh-fin-doc-an-nal-obj.obj-type          = parobj-type
      bfrb_arh-fin-doc-an-nal-obj.obj-code          = parobj-code
      bfrb_arh-fin-doc-an-nal-obj.cli-type          = parreceiver-type
      bfrb_arh-fin-doc-an-nal-obj.cli-code          = parreceiver-code
      bfrb_arh-fin-doc-an-nal-obj.fin-code-acc      = parreceiver-fin-code-acc
      bfrb_arh-fin-doc-an-nal-obj.curr-code         = parcurr-code
      bfrb_arh-fin-doc-an-nal-obj.fin-ext-doc-type  = parfin-ext-doc-type
      bfrb_arh-fin-doc-an-nal-obj.fin-code-an-uchet = parfin-code-an-uchet
      bfrb_arh-fin-doc-an-nal-obj.fin-code-cel-nazn = parfin-code-cel-nazn
      bfrb_arh-fin-doc-an-nal-obj.fin-code-cor-acc  = parfin-code-cor-acc
      bfrb_arh-fin-doc-an-nal-obj.calc-curr-code    = parbase-code
      bfrb_arh-fin-doc-an-nal-obj.sum-type          = parsum-type
      bfrb_arh-fin-doc-an-nal-obj.cource-des        = "b":u
      bfrb_arh-fin-doc-an-nal-obj.fact-order        = parfact-order
      bfrb_arh-fin-doc-an-nal-obj.fin-doc-code      = parfin-doc-code
      bfrb_arh-fin-doc-an-nal-obj.fact-date         = parfact-date
      bfrb_arh-fin-doc-an-nal-obj.curr-code         = parcurr-code
    .
    assign
      bfrb_arh-fin-doc-an-nal-obj.expense           = (if available borb_arh-fin-doc-an-nal-obj then borb_arh-fin-doc-an-nal-obj.expense     else 0)
      bfrb_arh-fin-doc-an-nal-obj.expense-vat       = (if available borb_arh-fin-doc-an-nal-obj then borb_arh-fin-doc-an-nal-obj.expense-vat else 0)
      bfrb_arh-fin-doc-an-nal-obj.expense-slt       = (if available borb_arh-fin-doc-an-nal-obj then borb_arh-fin-doc-an-nal-obj.expense-slt else 0)
      bfrb_arh-fin-doc-an-nal-obj.income            = (if available borb_arh-fin-doc-an-nal-obj then borb_arh-fin-doc-an-nal-obj.income      else 0) + parsum-base
      bfrb_arh-fin-doc-an-nal-obj.income-vat        = (if available borb_arh-fin-doc-an-nal-obj then borb_arh-fin-doc-an-nal-obj.income-vat  else 0) + parsum-vat-base
      bfrb_arh-fin-doc-an-nal-obj.income-slt        = (if available borb_arh-fin-doc-an-nal-obj then borb_arh-fin-doc-an-nal-obj.income-slt  else 0) + parsum-slt-base
    .
  end.
  else do:
    find first bfrb_arh-fin-doc-an-nal-obj where bfrb_arh-fin-doc-an-nal-obj.host-code         = parhost-code             and
                                                 bfrb_arh-fin-doc-an-nal-obj.obj-type          = parobj-type              and
                                                 bfrb_arh-fin-doc-an-nal-obj.obj-code          = parobj-code              and
                                                 bfrb_arh-fin-doc-an-nal-obj.cli-type          = parreceiver-type         and
                                                 bfrb_arh-fin-doc-an-nal-obj.cli-code          = parreceiver-code         and
                                                 bfrb_arh-fin-doc-an-nal-obj.fin-code-acc      = parreceiver-fin-code-acc and
                                                 bfrb_arh-fin-doc-an-nal-obj.curr-code         = parcurr-code             and
                                                 bfrb_arh-fin-doc-an-nal-obj.fin-ext-doc-type  = parfin-ext-doc-type      and
                                                 bfrb_arh-fin-doc-an-nal-obj.fin-code-an-uchet = parfin-code-an-uchet     and
                                                 bfrb_arh-fin-doc-an-nal-obj.fin-code-cel-nazn = parfin-code-cel-nazn     and
                                                 bfrb_arh-fin-doc-an-nal-obj.fin-code-cor-acc  = parfin-code-cor-acc      and
                                                 bfrb_arh-fin-doc-an-nal-obj.calc-curr-code    = parbase-code             and
                                                 bfrb_arh-fin-doc-an-nal-obj.sum-type          = parsum-type              and
                                                 bfrb_arh-fin-doc-an-nal-obj.fact-order        = parfact-order            exclusive-lock.
  end.
  for each rbfrb_arh-fin-doc-an-nal-obj where rbfrb_arh-fin-doc-an-nal-obj.host-code         = bfrb_arh-fin-doc-an-nal-obj.host-code         and
                                              rbfrb_arh-fin-doc-an-nal-obj.obj-type          = bfrb_arh-fin-doc-an-nal-obj.obj-type          and
                                              rbfrb_arh-fin-doc-an-nal-obj.obj-code          = bfrb_arh-fin-doc-an-nal-obj.obj-code          and
                                              rbfrb_arh-fin-doc-an-nal-obj.cli-type          = parreceiver-type                              and
                                              rbfrb_arh-fin-doc-an-nal-obj.cli-code          = parreceiver-code                              and
                                              rbfrb_arh-fin-doc-an-nal-obj.fin-code-acc      = bfrb_arh-fin-doc-an-nal-obj.fin-code-acc      and
                                              rbfrb_arh-fin-doc-an-nal-obj.curr-code         = bfrb_arh-fin-doc-an-nal-obj.curr-code         and
                                              rbfrb_arh-fin-doc-an-nal-obj.fin-ext-doc-type  = bfrb_arh-fin-doc-an-nal-obj.fin-ext-doc-type  and
                                              rbfrb_arh-fin-doc-an-nal-obj.fin-code-an-uchet = bfrb_arh-fin-doc-an-nal-obj.fin-code-an-uchet and
                                              rbfrb_arh-fin-doc-an-nal-obj.fin-code-cel-nazn = bfrb_arh-fin-doc-an-nal-obj.fin-code-cel-nazn and
                                              rbfrb_arh-fin-doc-an-nal-obj.fin-code-cor-acc  = bfrb_arh-fin-doc-an-nal-obj.fin-code-cor-acc  and
                                              rbfrb_arh-fin-doc-an-nal-obj.calc-curr-code    = bfrb_arh-fin-doc-an-nal-obj.calc-curr-code    and
                                              rbfrb_arh-fin-doc-an-nal-obj.sum-type          = bfrb_arh-fin-doc-an-nal-obj.sum-type          and
                                              rbfrb_arh-fin-doc-an-nal-obj.fact-order        > bfrb_arh-fin-doc-an-nal-obj.fact-order        use-index pi exclusive-lock on error undo, return error return-value :
   assign
     rbfrb_arh-fin-doc-an-nal-obj.income     = rbfrb_arh-fin-doc-an-nal-obj.income     + parsum-base
     rbfrb_arh-fin-doc-an-nal-obj.income-vat = rbfrb_arh-fin-doc-an-nal-obj.income-vat + parsum-vat-base
     rbfrb_arh-fin-doc-an-nal-obj.income-slt = rbfrb_arh-fin-doc-an-nal-obj.income-slt + parsum-slt-base
   .
  end.
  if parmode = "delete":u then do:
    delete bfpb_arh-fin-doc-an-nal-obj.
    delete bfrb_arh-fin-doc-an-nal-obj.
  end.
end.
if parrel-dog-code  =  yes          and
   parcurr-dog-code <> parcurr-code and
   parcurr-dog-code <> 0            and
   parcurr-dog-code <> parbase-code then do:
  if parmode = "close":u then do:
    find last bopc_arh-fin-doc-an-nal-obj where bopc_arh-fin-doc-an-nal-obj.host-code         = parhost-code          and
                                                bopc_arh-fin-doc-an-nal-obj.obj-type          = parobj-type           and
                                                bopc_arh-fin-doc-an-nal-obj.obj-code          = parobj-code           and
                                                bopc_arh-fin-doc-an-nal-obj.cli-type          = parpayer-type         and
                                                bopc_arh-fin-doc-an-nal-obj.cli-code          = parpayer-code         and
                                                bopc_arh-fin-doc-an-nal-obj.fin-code-acc      = parpayer-fin-code-acc and
                                                bopc_arh-fin-doc-an-nal-obj.curr-code         = parcurr-code          and
                                                bopc_arh-fin-doc-an-nal-obj.fin-ext-doc-type  = parfin-ext-doc-type   and
                                                bopc_arh-fin-doc-an-nal-obj.fin-code-an-uchet = parfin-code-an-uchet  and
                                                bopc_arh-fin-doc-an-nal-obj.fin-code-cel-nazn = parfin-code-cel-nazn  and
                                                bopc_arh-fin-doc-an-nal-obj.fin-code-cor-acc  = parfin-code-cor-acc   and
                                                bopc_arh-fin-doc-an-nal-obj.calc-curr-code    = parcurr-dog-code      and
                                                bopc_arh-fin-doc-an-nal-obj.sum-type          = parsum-type           and
                                                bopc_arh-fin-doc-an-nal-obj.fact-order        < parfact-order         use-index pi no-error.
    create bfpc_arh-fin-doc-an-nal-obj.
    assign
      bfpc_arh-fin-doc-an-nal-obj.host-code         = parhost-code
      bfpc_arh-fin-doc-an-nal-obj.obj-type          = parobj-type
      bfpc_arh-fin-doc-an-nal-obj.obj-code          = parobj-code
      bfpc_arh-fin-doc-an-nal-obj.cli-type          = parpayer-type
      bfpc_arh-fin-doc-an-nal-obj.cli-code          = parpayer-code
      bfpc_arh-fin-doc-an-nal-obj.fin-code-acc      = parpayer-fin-code-acc
      bfpc_arh-fin-doc-an-nal-obj.curr-code         = parcurr-code
      bfpc_arh-fin-doc-an-nal-obj.fin-ext-doc-type  = parfin-ext-doc-type
      bfpc_arh-fin-doc-an-nal-obj.fin-code-an-uchet = parfin-code-an-uchet
      bfpc_arh-fin-doc-an-nal-obj.fin-code-cel-nazn = parfin-code-cel-nazn
      bfpc_arh-fin-doc-an-nal-obj.fin-code-cor-acc  = parfin-code-cor-acc
      bfpc_arh-fin-doc-an-nal-obj.calc-curr-code    = parcurr-dog-code
      bfpc_arh-fin-doc-an-nal-obj.sum-type          = parsum-type
      bfpc_arh-fin-doc-an-nal-obj.cource-des        = "c":u
      bfpc_arh-fin-doc-an-nal-obj.fact-order        = parfact-order
      bfpc_arh-fin-doc-an-nal-obj.fin-doc-code      = parfin-doc-code
      bfpc_arh-fin-doc-an-nal-obj.fact-date         = parfact-date
      bfpc_arh-fin-doc-an-nal-obj.curr-code         = parcurr-code
      bfpc_arh-fin-doc-an-nal-obj.income            = (if available bopc_arh-fin-doc-an-nal-obj then bopc_arh-fin-doc-an-nal-obj.income      else 0)
      bfpc_arh-fin-doc-an-nal-obj.income-vat        = (if available bopc_arh-fin-doc-an-nal-obj then bopc_arh-fin-doc-an-nal-obj.income-vat  else 0)
      bfpc_arh-fin-doc-an-nal-obj.income-slt        = (if available bopc_arh-fin-doc-an-nal-obj then bopc_arh-fin-doc-an-nal-obj.income-slt  else 0)
      bfpc_arh-fin-doc-an-nal-obj.expense           = (if available bopc_arh-fin-doc-an-nal-obj then bopc_arh-fin-doc-an-nal-obj.expense     else 0) + parsum-contr
      bfpc_arh-fin-doc-an-nal-obj.expense-vat       = (if available bopc_arh-fin-doc-an-nal-obj then bopc_arh-fin-doc-an-nal-obj.expense-vat else 0) + parsum-vat-contr
      bfpc_arh-fin-doc-an-nal-obj.expense-slt       = (if available bopc_arh-fin-doc-an-nal-obj then bopc_arh-fin-doc-an-nal-obj.expense-slt else 0) + parsum-slt-contr
    .
  end.
  else do:
    find first bfpc_arh-fin-doc-an-nal-obj where bfpc_arh-fin-doc-an-nal-obj.host-code         = parhost-code          and
                                                 bfpc_arh-fin-doc-an-nal-obj.obj-type          = parobj-type           and
                                                 bfpc_arh-fin-doc-an-nal-obj.obj-code          = parobj-code           and
                                                 bfpc_arh-fin-doc-an-nal-obj.cli-type          = parpayer-type         and
                                                 bfpc_arh-fin-doc-an-nal-obj.cli-code          = parpayer-code         and
                                                 bfpc_arh-fin-doc-an-nal-obj.fin-code-acc      = parpayer-fin-code-acc and
                                                 bfpc_arh-fin-doc-an-nal-obj.curr-code         = parcurr-code          and
                                                 bfpc_arh-fin-doc-an-nal-obj.fin-ext-doc-type  = parfin-ext-doc-type   and
                                                 bfpc_arh-fin-doc-an-nal-obj.fin-code-an-uchet = parfin-code-an-uchet  and
                                                 bfpc_arh-fin-doc-an-nal-obj.fin-code-cel-nazn = parfin-code-cel-nazn  and
                                                 bfpc_arh-fin-doc-an-nal-obj.fin-code-cor-acc  = parfin-code-cor-acc   and
                                                 bfpc_arh-fin-doc-an-nal-obj.calc-curr-code    = parcurr-dog-code      and
                                                 bfpc_arh-fin-doc-an-nal-obj.sum-type          = parsum-type           and
                                                 bfpc_arh-fin-doc-an-nal-obj.fact-order        = parfact-order         exclusive-lock.
  end.
  for each rbfpc_arh-fin-doc-an-nal-obj where rbfpc_arh-fin-doc-an-nal-obj.host-code         = bfpc_arh-fin-doc-an-nal-obj.host-code         and
                                              rbfpc_arh-fin-doc-an-nal-obj.obj-type          = bfpc_arh-fin-doc-an-nal-obj.obj-type          and
                                              rbfpc_arh-fin-doc-an-nal-obj.obj-code          = bfpc_arh-fin-doc-an-nal-obj.obj-code          and
                                              rbfpc_arh-fin-doc-an-nal-obj.cli-type          = parpayer-type                                 and
                                              rbfpc_arh-fin-doc-an-nal-obj.cli-code          = parpayer-code                                 and
                                              rbfpc_arh-fin-doc-an-nal-obj.fin-code-acc      = bfpc_arh-fin-doc-an-nal-obj.fin-code-acc      and
                                              rbfpc_arh-fin-doc-an-nal-obj.curr-code         = bfpc_arh-fin-doc-an-nal-obj.curr-code         and
                                              rbfpc_arh-fin-doc-an-nal-obj.fin-ext-doc-type  = bfpc_arh-fin-doc-an-nal-obj.fin-ext-doc-type  and
                                              rbfpc_arh-fin-doc-an-nal-obj.fin-code-an-uchet = bfpc_arh-fin-doc-an-nal-obj.fin-code-an-uchet and
                                              rbfpc_arh-fin-doc-an-nal-obj.fin-code-cel-nazn = bfpc_arh-fin-doc-an-nal-obj.fin-code-cel-nazn and
                                              rbfpc_arh-fin-doc-an-nal-obj.fin-code-cor-acc  = bfpc_arh-fin-doc-an-nal-obj.fin-code-cor-acc  and
                                              rbfpc_arh-fin-doc-an-nal-obj.calc-curr-code    = bfpc_arh-fin-doc-an-nal-obj.calc-curr-code    and
                                              rbfpc_arh-fin-doc-an-nal-obj.sum-type          = bfpc_arh-fin-doc-an-nal-obj.sum-type          and
                                              rbfpc_arh-fin-doc-an-nal-obj.fact-order        > bfpc_arh-fin-doc-an-nal-obj.fact-order        use-index pi exclusive-lock on error undo, return error return-value :
    assign
      rbfpc_arh-fin-doc-an-nal-obj.expense     = rbfpc_arh-fin-doc-an-nal-obj.expense     + parsum-contr
      rbfpc_arh-fin-doc-an-nal-obj.expense-vat = rbfpc_arh-fin-doc-an-nal-obj.expense-vat + parsum-vat-contr
      rbfpc_arh-fin-doc-an-nal-obj.expense-slt = rbfpc_arh-fin-doc-an-nal-obj.expense-slt + parsum-slt-contr
    .
  end.
  if parmode = "close":u then do:
    find last borc_arh-fin-doc-an-nal-obj where borc_arh-fin-doc-an-nal-obj.host-code         = parhost-code             and
                                                borc_arh-fin-doc-an-nal-obj.obj-type          = parobj-type              and
                                                borc_arh-fin-doc-an-nal-obj.obj-code          = parobj-code              and
                                                borc_arh-fin-doc-an-nal-obj.cli-type          = parreceiver-type         and
                                                borc_arh-fin-doc-an-nal-obj.cli-code          = parreceiver-code         and
                                                borc_arh-fin-doc-an-nal-obj.fin-code-acc      = parreceiver-fin-code-acc and
                                                borc_arh-fin-doc-an-nal-obj.curr-code         = parcurr-code             and
                                                borc_arh-fin-doc-an-nal-obj.fin-ext-doc-type  = parfin-ext-doc-type      and
                                                borc_arh-fin-doc-an-nal-obj.fin-code-an-uchet = parfin-code-an-uchet     and
                                                borc_arh-fin-doc-an-nal-obj.fin-code-cel-nazn = parfin-code-cel-nazn     and
                                                borc_arh-fin-doc-an-nal-obj.fin-code-cor-acc  = parfin-code-cor-acc      and
                                                borc_arh-fin-doc-an-nal-obj.calc-curr-code    = parcurr-dog-code         and
                                                borc_arh-fin-doc-an-nal-obj.sum-type          = parsum-type              and
                                                borc_arh-fin-doc-an-nal-obj.fact-order        < parfact-order            use-index pi no-error.
    create bfrc_arh-fin-doc-an-nal-obj.
    assign
      bfrc_arh-fin-doc-an-nal-obj.host-code         = parhost-code
      bfrc_arh-fin-doc-an-nal-obj.obj-type          = parobj-type
      bfrc_arh-fin-doc-an-nal-obj.obj-code          = parobj-code
      bfrc_arh-fin-doc-an-nal-obj.cli-type          = parreceiver-type
      bfrc_arh-fin-doc-an-nal-obj.cli-code          = parreceiver-code
      bfrc_arh-fin-doc-an-nal-obj.fin-code-acc      = parreceiver-fin-code-acc
      bfrc_arh-fin-doc-an-nal-obj.curr-code         = parcurr-code
      bfrc_arh-fin-doc-an-nal-obj.fin-ext-doc-type  = parfin-ext-doc-type
      bfrc_arh-fin-doc-an-nal-obj.fin-code-an-uchet = parfin-code-an-uchet
      bfrc_arh-fin-doc-an-nal-obj.fin-code-cel-nazn = parfin-code-cel-nazn
      bfrc_arh-fin-doc-an-nal-obj.fin-code-cor-acc  = parfin-code-cor-acc
      bfrc_arh-fin-doc-an-nal-obj.calc-curr-code    = parcurr-dog-code
      bfrc_arh-fin-doc-an-nal-obj.sum-type          = parsum-type
      bfrc_arh-fin-doc-an-nal-obj.cource-des        = "c":u
      bfrc_arh-fin-doc-an-nal-obj.fact-order        = parfact-order
      bfrc_arh-fin-doc-an-nal-obj.fin-doc-code      = parfin-doc-code
      bfrc_arh-fin-doc-an-nal-obj.fact-date         = parfact-date
      bfrc_arh-fin-doc-an-nal-obj.curr-code         = parcurr-code
    .
    assign
      bfrc_arh-fin-doc-an-nal-obj.expense           = (if available borc_arh-fin-doc-an-nal-obj then borc_arh-fin-doc-an-nal-obj.expense     else 0)
      bfrc_arh-fin-doc-an-nal-obj.expense-vat       = (if available borc_arh-fin-doc-an-nal-obj then borc_arh-fin-doc-an-nal-obj.expense-vat else 0)
      bfrc_arh-fin-doc-an-nal-obj.expense-slt       = (if available borc_arh-fin-doc-an-nal-obj then borc_arh-fin-doc-an-nal-obj.expense-slt else 0)
      bfrc_arh-fin-doc-an-nal-obj.income            = (if available borc_arh-fin-doc-an-nal-obj then borc_arh-fin-doc-an-nal-obj.income      else 0) + parsum-contr
      bfrc_arh-fin-doc-an-nal-obj.income-vat        = (if available borc_arh-fin-doc-an-nal-obj then borc_arh-fin-doc-an-nal-obj.income-vat  else 0) + parsum-vat-contr
      bfrc_arh-fin-doc-an-nal-obj.income-slt        = (if available borc_arh-fin-doc-an-nal-obj then borc_arh-fin-doc-an-nal-obj.income-slt  else 0) + parsum-slt-contr
    .
  end.
  else do:
    find first bfrc_arh-fin-doc-an-nal-obj where bfrc_arh-fin-doc-an-nal-obj.host-code         = parhost-code             and
                                                 bfrc_arh-fin-doc-an-nal-obj.obj-type          = parobj-type              and
                                                 bfrc_arh-fin-doc-an-nal-obj.obj-code          = parobj-code              and
                                                 bfrc_arh-fin-doc-an-nal-obj.cli-type          = parreceiver-type         and
                                                 bfrc_arh-fin-doc-an-nal-obj.cli-code          = parreceiver-code         and
                                                 bfrc_arh-fin-doc-an-nal-obj.fin-code-acc      = parreceiver-fin-code-acc and
                                                 bfrc_arh-fin-doc-an-nal-obj.curr-code         = parcurr-code             and
                                                 bfrc_arh-fin-doc-an-nal-obj.fin-ext-doc-type  = parfin-ext-doc-type      and
                                                 bfrc_arh-fin-doc-an-nal-obj.fin-code-an-uchet = parfin-code-an-uchet     and
                                                 bfrc_arh-fin-doc-an-nal-obj.fin-code-cel-nazn = parfin-code-cel-nazn     and
                                                 bfrc_arh-fin-doc-an-nal-obj.fin-code-cor-acc  = parfin-code-cor-acc      and
                                                 bfrc_arh-fin-doc-an-nal-obj.calc-curr-code    = parcurr-dog-code         and
                                                 bfrc_arh-fin-doc-an-nal-obj.sum-type          = parsum-type              and
                                                 bfrc_arh-fin-doc-an-nal-obj.fact-order        = parfact-order            exclusive-lock.
  end.
  for each rbfrc_arh-fin-doc-an-nal-obj where rbfrc_arh-fin-doc-an-nal-obj.host-code         = bfrc_arh-fin-doc-an-nal-obj.host-code         and
                                              rbfrc_arh-fin-doc-an-nal-obj.obj-type          = bfrc_arh-fin-doc-an-nal-obj.obj-type          and
                                              rbfrc_arh-fin-doc-an-nal-obj.obj-code          = bfrc_arh-fin-doc-an-nal-obj.obj-code          and
                                              rbfrc_arh-fin-doc-an-nal-obj.cli-type          = parreceiver-type                              and
                                              rbfrc_arh-fin-doc-an-nal-obj.cli-code          = parreceiver-code                              and
                                              rbfrc_arh-fin-doc-an-nal-obj.fin-code-acc      = bfrc_arh-fin-doc-an-nal-obj.fin-code-acc      and
                                              rbfrc_arh-fin-doc-an-nal-obj.curr-code         = bfrc_arh-fin-doc-an-nal-obj.curr-code         and
                                              rbfrc_arh-fin-doc-an-nal-obj.fin-ext-doc-type  = bfrc_arh-fin-doc-an-nal-obj.fin-ext-doc-type  and
                                              rbfrc_arh-fin-doc-an-nal-obj.fin-code-an-uchet = bfrc_arh-fin-doc-an-nal-obj.fin-code-an-uchet and
                                              rbfrc_arh-fin-doc-an-nal-obj.fin-code-cel-nazn = bfrc_arh-fin-doc-an-nal-obj.fin-code-cel-nazn and
                                              rbfrc_arh-fin-doc-an-nal-obj.fin-code-cor-acc  = bfrc_arh-fin-doc-an-nal-obj.fin-code-cor-acc  and
                                              rbfrc_arh-fin-doc-an-nal-obj.calc-curr-code    = bfrc_arh-fin-doc-an-nal-obj.calc-curr-code    and
                                              rbfrc_arh-fin-doc-an-nal-obj.sum-type          = bfrc_arh-fin-doc-an-nal-obj.sum-type          and
                                              rbfrc_arh-fin-doc-an-nal-obj.fact-order        > bfrc_arh-fin-doc-an-nal-obj.fact-order        use-index pi exclusive-lock on error undo, return error return-value :
    assign
      rbfrc_arh-fin-doc-an-nal-obj.income     = rbfrc_arh-fin-doc-an-nal-obj.income     + parsum-contr
      rbfrc_arh-fin-doc-an-nal-obj.income-vat = rbfrc_arh-fin-doc-an-nal-obj.income-vat + parsum-vat-contr
      rbfrc_arh-fin-doc-an-nal-obj.income-slt = rbfrc_arh-fin-doc-an-nal-obj.income-slt + parsum-slt-contr
    .
  end.
  if parmode = "delete":u then do:
    delete bfpc_arh-fin-doc-an-nal-obj.
    delete bfrc_arh-fin-doc-an-nal-obj.
  end.
end.
end.
end procedure.
procedure libfarpo_calc-arh-fin-doc-contr-schet-n-obj :
define input parameter parmode                    as   character                    no-undo.
define input parameter parhost-code               like ub.fin-doc.host-code         no-undo.
define input parameter parobj-type                like ub.fin-doc.obj-type          no-undo.
define input parameter parobj-code                like ub.fin-doc.obj-code          no-undo.
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
define buffer bfps_arh-fin-doc-contr-s-nal-obj for ub.arh-fin-doc-contr-s-nal-obj.
define buffer bfrs_arh-fin-doc-contr-s-nal-obj for ub.arh-fin-doc-contr-s-nal-obj.
define buffer rbfps_arh-fin-doc-contr-s-n-obj  for ub.arh-fin-doc-contr-s-nal-obj.
define buffer rbfrs_arh-fin-doc-contr-s-n-obj  for ub.arh-fin-doc-contr-s-nal-obj.
define buffer bops_arh-fin-doc-contr-s-nal-obj for ub.arh-fin-doc-contr-s-nal-obj.
define buffer bors_arh-fin-doc-contr-s-nal-obj for ub.arh-fin-doc-contr-s-nal-obj.
define buffer bfpr_arh-fin-doc-contr-s-nal-obj for ub.arh-fin-doc-contr-s-nal-obj.
define buffer bfrr_arh-fin-doc-contr-s-nal-obj for ub.arh-fin-doc-contr-s-nal-obj.
define buffer rbfpr_arh-fin-doc-contr-s-n-obj  for ub.arh-fin-doc-contr-s-nal-obj.
define buffer rbfrr_arh-fin-doc-contr-s-n-obj  for ub.arh-fin-doc-contr-s-nal-obj.
define buffer bopr_arh-fin-doc-contr-s-nal-obj for ub.arh-fin-doc-contr-s-nal-obj.
define buffer borr_arh-fin-doc-contr-s-nal-obj for ub.arh-fin-doc-contr-s-nal-obj.
define buffer bfpb_arh-fin-doc-contr-s-nal-obj for ub.arh-fin-doc-contr-s-nal-obj.
define buffer bfrb_arh-fin-doc-contr-s-nal-obj for ub.arh-fin-doc-contr-s-nal-obj.
define buffer rbfpb_arh-fin-doc-contr-s-n-obj  for ub.arh-fin-doc-contr-s-nal-obj.
define buffer rbfrb_arh-fin-doc-contr-s-n-obj  for ub.arh-fin-doc-contr-s-nal-obj.
define buffer bopb_arh-fin-doc-contr-s-nal-obj for ub.arh-fin-doc-contr-s-nal-obj.
define buffer borb_arh-fin-doc-contr-s-nal-obj for ub.arh-fin-doc-contr-s-nal-obj.
define buffer bfpc_arh-fin-doc-contr-s-nal-obj for ub.arh-fin-doc-contr-s-nal-obj.
define buffer bfrc_arh-fin-doc-contr-s-nal-obj for ub.arh-fin-doc-contr-s-nal-obj.
define buffer rbfpc_arh-fin-doc-contr-s-n-obj  for ub.arh-fin-doc-contr-s-nal-obj.
define buffer rbfrc_arh-fin-doc-contr-s-n-obj  for ub.arh-fin-doc-contr-s-nal-obj.
define buffer bopc_arh-fin-doc-contr-s-nal-obj for ub.arh-fin-doc-contr-s-nal-obj.
define buffer borc_arh-fin-doc-contr-s-nal-obj for ub.arh-fin-doc-contr-s-nal-obj.
do on error undo, return error substitute ("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
if parmode = "close":u then do:
  find last bops_arh-fin-doc-contr-s-nal-obj where bops_arh-fin-doc-contr-s-nal-obj.host-code        = parhost-code          and
                                                   bops_arh-fin-doc-contr-s-nal-obj.obj-type         = parobj-type           and
                                                   bops_arh-fin-doc-contr-s-nal-obj.obj-code         = parobj-code           and
                                                   bops_arh-fin-doc-contr-s-nal-obj.cli-type         = parpayer-type         and
                                                   bops_arh-fin-doc-contr-s-nal-obj.cli-code         = parpayer-code         and
                                                   bops_arh-fin-doc-contr-s-nal-obj.contract-code    = parcontract-code      and
                                                   bops_arh-fin-doc-contr-s-nal-obj.fin-code-acc     = parpayer-fin-code-acc and
                                                   bops_arh-fin-doc-contr-s-nal-obj.curr-code        = parcurr-code          and
                                                   bops_arh-fin-doc-contr-s-nal-obj.fin-ext-doc-type = parfin-ext-doc-type   and
                                                   bops_arh-fin-doc-contr-s-nal-obj.calc-curr-code   = parcurr-code          and
                                                   bops_arh-fin-doc-contr-s-nal-obj.sum-type         = parsum-type           and
                                                   bops_arh-fin-doc-contr-s-nal-obj.fact-order       < parfact-order         use-index pi no-error.
  create bfps_arh-fin-doc-contr-s-nal-obj.
  assign
    bfps_arh-fin-doc-contr-s-nal-obj.host-code        = parhost-code
    bfps_arh-fin-doc-contr-s-nal-obj.obj-type         = parobj-type
    bfps_arh-fin-doc-contr-s-nal-obj.obj-code         = parobj-code
    bfps_arh-fin-doc-contr-s-nal-obj.cli-type         = parpayer-type
    bfps_arh-fin-doc-contr-s-nal-obj.cli-code         = parpayer-code
    bfps_arh-fin-doc-contr-s-nal-obj.contract-code    = parcontract-code
    bfps_arh-fin-doc-contr-s-nal-obj.fin-code-acc     = parpayer-fin-code-acc
    bfps_arh-fin-doc-contr-s-nal-obj.curr-code        = parcurr-code
    bfps_arh-fin-doc-contr-s-nal-obj.fin-ext-doc-type = parfin-ext-doc-type
    bfps_arh-fin-doc-contr-s-nal-obj.calc-curr-code   = parcurr-code
    bfps_arh-fin-doc-contr-s-nal-obj.sum-type         = parsum-type
    bfps_arh-fin-doc-contr-s-nal-obj.cource-des       = "s":u
    bfps_arh-fin-doc-contr-s-nal-obj.fact-order       = parfact-order
    bfps_arh-fin-doc-contr-s-nal-obj.fin-doc-code     = parfin-doc-code
    bfps_arh-fin-doc-contr-s-nal-obj.fact-date        = parfact-date
    bfps_arh-fin-doc-contr-s-nal-obj.curr-code        = parcurr-code
    bfps_arh-fin-doc-contr-s-nal-obj.income           = (if available bops_arh-fin-doc-contr-s-nal-obj then bops_arh-fin-doc-contr-s-nal-obj.income      else 0)
    bfps_arh-fin-doc-contr-s-nal-obj.income-vat       = (if available bops_arh-fin-doc-contr-s-nal-obj then bops_arh-fin-doc-contr-s-nal-obj.income-vat  else 0)
    bfps_arh-fin-doc-contr-s-nal-obj.income-slt       = (if available bops_arh-fin-doc-contr-s-nal-obj then bops_arh-fin-doc-contr-s-nal-obj.income-slt  else 0)
    bfps_arh-fin-doc-contr-s-nal-obj.expense          = (if available bops_arh-fin-doc-contr-s-nal-obj then bops_arh-fin-doc-contr-s-nal-obj.expense     else 0) + parsum-doc
    bfps_arh-fin-doc-contr-s-nal-obj.expense-vat      = (if available bops_arh-fin-doc-contr-s-nal-obj then bops_arh-fin-doc-contr-s-nal-obj.expense-vat else 0) + parsum-vat-doc
    bfps_arh-fin-doc-contr-s-nal-obj.expense-slt      = (if available bops_arh-fin-doc-contr-s-nal-obj then bops_arh-fin-doc-contr-s-nal-obj.expense-slt else 0) + parsum-slt-doc
  .
end.
else do:
  find first bfps_arh-fin-doc-contr-s-nal-obj where bfps_arh-fin-doc-contr-s-nal-obj.host-code        = parhost-code          and
                                                    bfps_arh-fin-doc-contr-s-nal-obj.obj-type         = parobj-type           and
                                                    bfps_arh-fin-doc-contr-s-nal-obj.obj-code         = parobj-code           and
                                                    bfps_arh-fin-doc-contr-s-nal-obj.cli-type         = parpayer-type         and
                                                    bfps_arh-fin-doc-contr-s-nal-obj.cli-code         = parpayer-code         and
                                                    bfps_arh-fin-doc-contr-s-nal-obj.contract-code    = parcontract-code      and
                                                    bfps_arh-fin-doc-contr-s-nal-obj.fin-code-acc     = parpayer-fin-code-acc and
                                                    bfps_arh-fin-doc-contr-s-nal-obj.curr-code        = parcurr-code          and
                                                    bfps_arh-fin-doc-contr-s-nal-obj.fin-ext-doc-type = parfin-ext-doc-type   and
                                                    bfps_arh-fin-doc-contr-s-nal-obj.calc-curr-code   = parcurr-code          and
                                                    bfps_arh-fin-doc-contr-s-nal-obj.sum-type         = parsum-type           and
                                                    bfps_arh-fin-doc-contr-s-nal-obj.fact-order       = parfact-order         exclusive-lock.
end.
for each rbfps_arh-fin-doc-contr-s-n-obj where rbfps_arh-fin-doc-contr-s-n-obj.host-code        = bfps_arh-fin-doc-contr-s-nal-obj.host-code        and
                                               rbfps_arh-fin-doc-contr-s-n-obj.obj-type         = bfps_arh-fin-doc-contr-s-nal-obj.obj-type         and
                                               rbfps_arh-fin-doc-contr-s-n-obj.obj-code         = bfps_arh-fin-doc-contr-s-nal-obj.obj-code         and
                                               rbfps_arh-fin-doc-contr-s-n-obj.cli-type         = parpayer-type                                     and
                                               rbfps_arh-fin-doc-contr-s-n-obj.cli-code         = parpayer-code                                     and
                                               rbfps_arh-fin-doc-contr-s-n-obj.contract-code    = bfps_arh-fin-doc-contr-s-nal-obj.contract-code    and
                                               rbfps_arh-fin-doc-contr-s-n-obj.fin-code-acc     = bfps_arh-fin-doc-contr-s-nal-obj.fin-code-acc     and
                                               rbfps_arh-fin-doc-contr-s-n-obj.curr-code        = bfps_arh-fin-doc-contr-s-nal-obj.curr-code        and
                                               rbfps_arh-fin-doc-contr-s-n-obj.fin-ext-doc-type = bfps_arh-fin-doc-contr-s-nal-obj.fin-ext-doc-type and
                                               rbfps_arh-fin-doc-contr-s-n-obj.calc-curr-code   = bfps_arh-fin-doc-contr-s-nal-obj.calc-curr-code   and
                                               rbfps_arh-fin-doc-contr-s-n-obj.sum-type         = bfps_arh-fin-doc-contr-s-nal-obj.sum-type         and
                                               rbfps_arh-fin-doc-contr-s-n-obj.fact-order       > bfps_arh-fin-doc-contr-s-nal-obj.fact-order       use-index pi exclusive-lock on error undo, return error return-value :
  assign
    rbfps_arh-fin-doc-contr-s-n-obj.expense     = rbfps_arh-fin-doc-contr-s-n-obj.expense     + parsum-doc
    rbfps_arh-fin-doc-contr-s-n-obj.expense-vat = rbfps_arh-fin-doc-contr-s-n-obj.expense-vat + parsum-vat-doc
    rbfps_arh-fin-doc-contr-s-n-obj.expense-slt = rbfps_arh-fin-doc-contr-s-n-obj.expense-slt + parsum-slt-doc
  .
end.
if parmode = "close":u then do:
  find last bors_arh-fin-doc-contr-s-nal-obj where bors_arh-fin-doc-contr-s-nal-obj.host-code        = parhost-code             and
                                                   bors_arh-fin-doc-contr-s-nal-obj.obj-type         = parobj-type              and
                                                   bors_arh-fin-doc-contr-s-nal-obj.obj-code         = parobj-code              and
                                                   bors_arh-fin-doc-contr-s-nal-obj.cli-type         = parreceiver-type         and
                                                   bors_arh-fin-doc-contr-s-nal-obj.cli-code         = parreceiver-code         and
                                                   bors_arh-fin-doc-contr-s-nal-obj.contract-code    = parcontract-code         and
                                                   bors_arh-fin-doc-contr-s-nal-obj.fin-code-acc     = parreceiver-fin-code-acc and
                                                   bors_arh-fin-doc-contr-s-nal-obj.curr-code        = parcurr-code             and
                                                   bors_arh-fin-doc-contr-s-nal-obj.fin-ext-doc-type = parfin-ext-doc-type      and
                                                   bors_arh-fin-doc-contr-s-nal-obj.calc-curr-code   = parcurr-code             and
                                                   bors_arh-fin-doc-contr-s-nal-obj.sum-type         = parsum-type              and
                                                   bors_arh-fin-doc-contr-s-nal-obj.fact-order       < parfact-order            use-index pi no-error.
  create bfrs_arh-fin-doc-contr-s-nal-obj.
  assign
    bfrs_arh-fin-doc-contr-s-nal-obj.host-code        = parhost-code
    bfrs_arh-fin-doc-contr-s-nal-obj.obj-type         = parobj-type
    bfrs_arh-fin-doc-contr-s-nal-obj.obj-code         = parobj-code
    bfrs_arh-fin-doc-contr-s-nal-obj.cli-type         = parreceiver-type
    bfrs_arh-fin-doc-contr-s-nal-obj.cli-code         = parreceiver-code
    bfrs_arh-fin-doc-contr-s-nal-obj.contract-code    = parcontract-code
    bfrs_arh-fin-doc-contr-s-nal-obj.fin-code-acc     = parreceiver-fin-code-acc
    bfrs_arh-fin-doc-contr-s-nal-obj.curr-code        = parcurr-code
    bfrs_arh-fin-doc-contr-s-nal-obj.fin-ext-doc-type = parfin-ext-doc-type
    bfrs_arh-fin-doc-contr-s-nal-obj.calc-curr-code   = parcurr-code
    bfrs_arh-fin-doc-contr-s-nal-obj.sum-type         = parsum-type
    bfrs_arh-fin-doc-contr-s-nal-obj.cource-des       = "s":u
    bfrs_arh-fin-doc-contr-s-nal-obj.fact-order       = parfact-order
    bfrs_arh-fin-doc-contr-s-nal-obj.fin-doc-code     = parfin-doc-code
    bfrs_arh-fin-doc-contr-s-nal-obj.fact-date        = parfact-date
    bfrs_arh-fin-doc-contr-s-nal-obj.curr-code        = parcurr-code
  .
  assign
    bfrs_arh-fin-doc-contr-s-nal-obj.expense          = (if available bors_arh-fin-doc-contr-s-nal-obj then bors_arh-fin-doc-contr-s-nal-obj.expense     else 0)
    bfrs_arh-fin-doc-contr-s-nal-obj.expense-vat      = (if available bors_arh-fin-doc-contr-s-nal-obj then bors_arh-fin-doc-contr-s-nal-obj.expense-vat else 0)
    bfrs_arh-fin-doc-contr-s-nal-obj.expense-slt      = (if available bors_arh-fin-doc-contr-s-nal-obj then bors_arh-fin-doc-contr-s-nal-obj.expense-slt else 0)
    bfrs_arh-fin-doc-contr-s-nal-obj.income           = (if available bors_arh-fin-doc-contr-s-nal-obj then bors_arh-fin-doc-contr-s-nal-obj.income      else 0) + parsum-doc
    bfrs_arh-fin-doc-contr-s-nal-obj.income-vat       = (if available bors_arh-fin-doc-contr-s-nal-obj then bors_arh-fin-doc-contr-s-nal-obj.income-vat  else 0) + parsum-vat-doc
    bfrs_arh-fin-doc-contr-s-nal-obj.income-slt       = (if available bors_arh-fin-doc-contr-s-nal-obj then bors_arh-fin-doc-contr-s-nal-obj.income-slt  else 0) + parsum-slt-doc
  .
end.
else do:
  find first bfrs_arh-fin-doc-contr-s-nal-obj where bfrs_arh-fin-doc-contr-s-nal-obj.host-code        = parhost-code             and
                                                    bfrs_arh-fin-doc-contr-s-nal-obj.obj-type         = parobj-type              and
                                                    bfrs_arh-fin-doc-contr-s-nal-obj.obj-code         = parobj-code              and
                                                    bfrs_arh-fin-doc-contr-s-nal-obj.cli-type         = parreceiver-type         and
                                                    bfrs_arh-fin-doc-contr-s-nal-obj.cli-code         = parreceiver-code         and
                                                    bfrs_arh-fin-doc-contr-s-nal-obj.contract-code    = parcontract-code         and
                                                    bfrs_arh-fin-doc-contr-s-nal-obj.fin-code-acc     = parreceiver-fin-code-acc and
                                                    bfrs_arh-fin-doc-contr-s-nal-obj.curr-code        = parcurr-code             and
                                                    bfrs_arh-fin-doc-contr-s-nal-obj.fin-ext-doc-type = parfin-ext-doc-type      and
                                                    bfrs_arh-fin-doc-contr-s-nal-obj.calc-curr-code   = parcurr-code             and
                                                    bfrs_arh-fin-doc-contr-s-nal-obj.sum-type         = parsum-type              and
                                                    bfrs_arh-fin-doc-contr-s-nal-obj.fact-order       = parfact-order            exclusive-lock.
end.
for each rbfrs_arh-fin-doc-contr-s-n-obj where rbfrs_arh-fin-doc-contr-s-n-obj.host-code        = bfrs_arh-fin-doc-contr-s-nal-obj.host-code        and
                                               rbfrs_arh-fin-doc-contr-s-n-obj.obj-type         = bfrs_arh-fin-doc-contr-s-nal-obj.obj-type         and
                                               rbfrs_arh-fin-doc-contr-s-n-obj.obj-code         = bfrs_arh-fin-doc-contr-s-nal-obj.obj-code         and
                                               rbfrs_arh-fin-doc-contr-s-n-obj.cli-type         = parreceiver-type                                  and
                                               rbfrs_arh-fin-doc-contr-s-n-obj.cli-code         = parreceiver-code                                  and
                                               rbfrs_arh-fin-doc-contr-s-n-obj.contract-code    = bfrs_arh-fin-doc-contr-s-nal-obj.contract-code    and
                                               rbfrs_arh-fin-doc-contr-s-n-obj.fin-code-acc     = bfrs_arh-fin-doc-contr-s-nal-obj.fin-code-acc     and
                                               rbfrs_arh-fin-doc-contr-s-n-obj.curr-code        = bfrs_arh-fin-doc-contr-s-nal-obj.curr-code        and
                                               rbfrs_arh-fin-doc-contr-s-n-obj.fin-ext-doc-type = bfrs_arh-fin-doc-contr-s-nal-obj.fin-ext-doc-type and
                                               rbfrs_arh-fin-doc-contr-s-n-obj.calc-curr-code   = bfrs_arh-fin-doc-contr-s-nal-obj.calc-curr-code   and
                                               rbfrs_arh-fin-doc-contr-s-n-obj.sum-type         = bfrs_arh-fin-doc-contr-s-nal-obj.sum-type         and
                                               rbfrs_arh-fin-doc-contr-s-n-obj.fact-order       > bfrs_arh-fin-doc-contr-s-nal-obj.fact-order       use-index pi on error undo, return error return-value :
  assign
    rbfrs_arh-fin-doc-contr-s-n-obj.income     = rbfrs_arh-fin-doc-contr-s-n-obj.income     + parsum-doc
    rbfrs_arh-fin-doc-contr-s-n-obj.income-vat = rbfrs_arh-fin-doc-contr-s-n-obj.income-vat + parsum-vat-doc
    rbfrs_arh-fin-doc-contr-s-n-obj.income-slt = rbfrs_arh-fin-doc-contr-s-n-obj.income-slt + parsum-slt-doc
  .
end.
if parmode = "delete":u then do:
  delete bfps_arh-fin-doc-contr-s-nal-obj.
  delete bfrs_arh-fin-doc-contr-s-nal-obj.
end.
if parcurr-code <> 0 then do:
  if parmode = "close":u then do:
    find last bopr_arh-fin-doc-contr-s-nal-obj where bopr_arh-fin-doc-contr-s-nal-obj.host-code        = parhost-code          and
                                                     bopr_arh-fin-doc-contr-s-nal-obj.obj-type         = parobj-type           and
                                                     bopr_arh-fin-doc-contr-s-nal-obj.obj-code         = parobj-code           and
                                                     bopr_arh-fin-doc-contr-s-nal-obj.cli-type         = parpayer-type         and
                                                     bopr_arh-fin-doc-contr-s-nal-obj.cli-code         = parpayer-code         and
                                                     bopr_arh-fin-doc-contr-s-nal-obj.contract-code    = parcontract-code      and
                                                     bopr_arh-fin-doc-contr-s-nal-obj.fin-code-acc     = parpayer-fin-code-acc and
                                                     bopr_arh-fin-doc-contr-s-nal-obj.curr-code        = parcurr-code          and
                                                     bopr_arh-fin-doc-contr-s-nal-obj.fin-ext-doc-type = parfin-ext-doc-type   and
                                                     bopr_arh-fin-doc-contr-s-nal-obj.calc-curr-code   = 0                     and
                                                     bopr_arh-fin-doc-contr-s-nal-obj.sum-type         = parsum-type           and
                                                     bopr_arh-fin-doc-contr-s-nal-obj.fact-order       < parfact-order         use-index pi no-error.
    create bfpr_arh-fin-doc-contr-s-nal-obj.
    assign
      bfpr_arh-fin-doc-contr-s-nal-obj.host-code        = parhost-code
      bfpr_arh-fin-doc-contr-s-nal-obj.obj-type         = parobj-type
      bfpr_arh-fin-doc-contr-s-nal-obj.obj-code         = parobj-code
      bfpr_arh-fin-doc-contr-s-nal-obj.cli-type         = parpayer-type
      bfpr_arh-fin-doc-contr-s-nal-obj.cli-code         = parpayer-code
      bfpr_arh-fin-doc-contr-s-nal-obj.contract-code    = parcontract-code
      bfpr_arh-fin-doc-contr-s-nal-obj.fin-code-acc     = parpayer-fin-code-acc
      bfpr_arh-fin-doc-contr-s-nal-obj.curr-code        = parcurr-code
      bfpr_arh-fin-doc-contr-s-nal-obj.fin-ext-doc-type = parfin-ext-doc-type
      bfpr_arh-fin-doc-contr-s-nal-obj.calc-curr-code   = 0
      bfpr_arh-fin-doc-contr-s-nal-obj.sum-type         = parsum-type
      bfpr_arh-fin-doc-contr-s-nal-obj.cource-des       = "r":u
      bfpr_arh-fin-doc-contr-s-nal-obj.fact-order       = parfact-order
      bfpr_arh-fin-doc-contr-s-nal-obj.fin-doc-code     = parfin-doc-code
      bfpr_arh-fin-doc-contr-s-nal-obj.fact-date        = parfact-date
      bfpr_arh-fin-doc-contr-s-nal-obj.curr-code        = parcurr-code
      bfpr_arh-fin-doc-contr-s-nal-obj.income           = (if available bopr_arh-fin-doc-contr-s-nal-obj then bopr_arh-fin-doc-contr-s-nal-obj.income      else 0)
      bfpr_arh-fin-doc-contr-s-nal-obj.income-vat       = (if available bopr_arh-fin-doc-contr-s-nal-obj then bopr_arh-fin-doc-contr-s-nal-obj.income-vat  else 0)
      bfpr_arh-fin-doc-contr-s-nal-obj.income-slt       = (if available bopr_arh-fin-doc-contr-s-nal-obj then bopr_arh-fin-doc-contr-s-nal-obj.income-slt  else 0)
      bfpr_arh-fin-doc-contr-s-nal-obj.expense          = (if available bopr_arh-fin-doc-contr-s-nal-obj then bopr_arh-fin-doc-contr-s-nal-obj.expense     else 0) + parsum-rubl
      bfpr_arh-fin-doc-contr-s-nal-obj.expense-vat      = (if available bopr_arh-fin-doc-contr-s-nal-obj then bopr_arh-fin-doc-contr-s-nal-obj.expense-vat else 0) + parsum-vat-rubl
      bfpr_arh-fin-doc-contr-s-nal-obj.expense-slt      = (if available bopr_arh-fin-doc-contr-s-nal-obj then bopr_arh-fin-doc-contr-s-nal-obj.expense-slt else 0) + parsum-slt-rubl
    .
  end.
  else do:
    find first bfpr_arh-fin-doc-contr-s-nal-obj where bfpr_arh-fin-doc-contr-s-nal-obj.host-code        = parhost-code          and
                                                      bfpr_arh-fin-doc-contr-s-nal-obj.obj-type         = parobj-type           and
                                                      bfpr_arh-fin-doc-contr-s-nal-obj.obj-code         = parobj-code           and
                                                      bfpr_arh-fin-doc-contr-s-nal-obj.cli-type         = parpayer-type         and
                                                      bfpr_arh-fin-doc-contr-s-nal-obj.cli-code         = parpayer-code         and
                                                      bfpr_arh-fin-doc-contr-s-nal-obj.contract-code    = parcontract-code      and
                                                      bfpr_arh-fin-doc-contr-s-nal-obj.fin-code-acc     = parpayer-fin-code-acc and
                                                      bfpr_arh-fin-doc-contr-s-nal-obj.curr-code        = parcurr-code          and
                                                      bfpr_arh-fin-doc-contr-s-nal-obj.fin-ext-doc-type = parfin-ext-doc-type   and
                                                      bfpr_arh-fin-doc-contr-s-nal-obj.calc-curr-code   = 0                     and
                                                      bfpr_arh-fin-doc-contr-s-nal-obj.sum-type         = parsum-type           and
                                                      bfpr_arh-fin-doc-contr-s-nal-obj.fact-order       = parfact-order         exclusive-lock.
  end.
  for each rbfpr_arh-fin-doc-contr-s-n-obj where rbfpr_arh-fin-doc-contr-s-n-obj.host-code        = bfpr_arh-fin-doc-contr-s-nal-obj.host-code        and
                                                 rbfpr_arh-fin-doc-contr-s-n-obj.obj-type         = bfpr_arh-fin-doc-contr-s-nal-obj.obj-type         and
                                                 rbfpr_arh-fin-doc-contr-s-n-obj.obj-code         = bfpr_arh-fin-doc-contr-s-nal-obj.obj-code         and
                                                 rbfpr_arh-fin-doc-contr-s-n-obj.cli-type         = parpayer-type                                     and
                                                 rbfpr_arh-fin-doc-contr-s-n-obj.cli-code         = parpayer-code                                     and
                                                 rbfpr_arh-fin-doc-contr-s-n-obj.contract-code    = bfpr_arh-fin-doc-contr-s-nal-obj.contract-code    and
                                                 rbfpr_arh-fin-doc-contr-s-n-obj.fin-code-acc     = bfpr_arh-fin-doc-contr-s-nal-obj.fin-code-acc     and
                                                 rbfpr_arh-fin-doc-contr-s-n-obj.curr-code        = bfpr_arh-fin-doc-contr-s-nal-obj.curr-code        and
                                                 rbfpr_arh-fin-doc-contr-s-n-obj.fin-ext-doc-type = bfpr_arh-fin-doc-contr-s-nal-obj.fin-ext-doc-type and
                                                 rbfpr_arh-fin-doc-contr-s-n-obj.calc-curr-code   = bfpr_arh-fin-doc-contr-s-nal-obj.calc-curr-code   and
                                                 rbfpr_arh-fin-doc-contr-s-n-obj.sum-type         = bfpr_arh-fin-doc-contr-s-nal-obj.sum-type         and
                                                 rbfpr_arh-fin-doc-contr-s-n-obj.fact-order       > bfpr_arh-fin-doc-contr-s-nal-obj.fact-order       use-index pi exclusive-lock on error undo, return error return-value :
    assign
      rbfpr_arh-fin-doc-contr-s-n-obj.expense     = rbfpr_arh-fin-doc-contr-s-n-obj.expense     + parsum-rubl
      rbfpr_arh-fin-doc-contr-s-n-obj.expense-vat = rbfpr_arh-fin-doc-contr-s-n-obj.expense-vat + parsum-vat-rubl
      rbfpr_arh-fin-doc-contr-s-n-obj.expense-slt = rbfpr_arh-fin-doc-contr-s-n-obj.expense-slt + parsum-slt-rubl
    .
  end.
  if parmode = "close":u then do:
    find last borr_arh-fin-doc-contr-s-nal-obj where borr_arh-fin-doc-contr-s-nal-obj.host-code        = parhost-code             and
                                                     borr_arh-fin-doc-contr-s-nal-obj.obj-type         = parobj-type              and
                                                     borr_arh-fin-doc-contr-s-nal-obj.obj-code         = parobj-code              and
                                                     borr_arh-fin-doc-contr-s-nal-obj.cli-type         = parreceiver-type         and
                                                     borr_arh-fin-doc-contr-s-nal-obj.cli-code         = parreceiver-code         and
                                                     borr_arh-fin-doc-contr-s-nal-obj.contract-code    = parcontract-code         and
                                                     borr_arh-fin-doc-contr-s-nal-obj.fin-code-acc     = parreceiver-fin-code-acc and
                                                     borr_arh-fin-doc-contr-s-nal-obj.curr-code        = parcurr-code             and
                                                     borr_arh-fin-doc-contr-s-nal-obj.fin-ext-doc-type = parfin-ext-doc-type      and
                                                     borr_arh-fin-doc-contr-s-nal-obj.calc-curr-code   = 0                        and
                                                     borr_arh-fin-doc-contr-s-nal-obj.sum-type         = parsum-type              and
                                                     borr_arh-fin-doc-contr-s-nal-obj.fact-order       < parfact-order            use-index pi no-error.
    create bfrr_arh-fin-doc-contr-s-nal-obj.
    assign
      bfrr_arh-fin-doc-contr-s-nal-obj.host-code        = parhost-code
      bfrr_arh-fin-doc-contr-s-nal-obj.obj-type         = parobj-type
      bfrr_arh-fin-doc-contr-s-nal-obj.obj-code         = parobj-code
      bfrr_arh-fin-doc-contr-s-nal-obj.cli-type         = parreceiver-type
      bfrr_arh-fin-doc-contr-s-nal-obj.cli-code         = parreceiver-code
      bfrr_arh-fin-doc-contr-s-nal-obj.contract-code    = parcontract-code
      bfrr_arh-fin-doc-contr-s-nal-obj.fin-code-acc     = parreceiver-fin-code-acc
      bfrr_arh-fin-doc-contr-s-nal-obj.curr-code        = parcurr-code
      bfrr_arh-fin-doc-contr-s-nal-obj.fin-ext-doc-type = parfin-ext-doc-type
      bfrr_arh-fin-doc-contr-s-nal-obj.calc-curr-code   = 0
      bfrr_arh-fin-doc-contr-s-nal-obj.sum-type         = parsum-type
      bfrr_arh-fin-doc-contr-s-nal-obj.cource-des       = "r":u
      bfrr_arh-fin-doc-contr-s-nal-obj.fact-order       = parfact-order
      bfrr_arh-fin-doc-contr-s-nal-obj.fin-doc-code     = parfin-doc-code
      bfrr_arh-fin-doc-contr-s-nal-obj.fact-date        = parfact-date
      bfrr_arh-fin-doc-contr-s-nal-obj.curr-code        = parcurr-code
    .
    assign
      bfrr_arh-fin-doc-contr-s-nal-obj.expense          = (if available borr_arh-fin-doc-contr-s-nal-obj then borr_arh-fin-doc-contr-s-nal-obj.expense     else 0)
      bfrr_arh-fin-doc-contr-s-nal-obj.expense-vat      = (if available borr_arh-fin-doc-contr-s-nal-obj then borr_arh-fin-doc-contr-s-nal-obj.expense-vat else 0)
      bfrr_arh-fin-doc-contr-s-nal-obj.expense-slt      = (if available borr_arh-fin-doc-contr-s-nal-obj then borr_arh-fin-doc-contr-s-nal-obj.expense-slt else 0)
      bfrr_arh-fin-doc-contr-s-nal-obj.income           = (if available borr_arh-fin-doc-contr-s-nal-obj then borr_arh-fin-doc-contr-s-nal-obj.income      else 0) + parsum-rubl
      bfrr_arh-fin-doc-contr-s-nal-obj.income-vat       = (if available borr_arh-fin-doc-contr-s-nal-obj then borr_arh-fin-doc-contr-s-nal-obj.income-vat  else 0) + parsum-vat-rubl
      bfrr_arh-fin-doc-contr-s-nal-obj.income-slt       = (if available borr_arh-fin-doc-contr-s-nal-obj then borr_arh-fin-doc-contr-s-nal-obj.income-slt  else 0) + parsum-slt-rubl
    .
  end.
  else do:
    find first bfrr_arh-fin-doc-contr-s-nal-obj where bfrr_arh-fin-doc-contr-s-nal-obj.host-code        = parhost-code             and
                                                      bfrr_arh-fin-doc-contr-s-nal-obj.obj-type         = parobj-type              and
                                                      bfrr_arh-fin-doc-contr-s-nal-obj.obj-code         = parobj-code              and
                                                      bfrr_arh-fin-doc-contr-s-nal-obj.cli-type         = parreceiver-type         and
                                                      bfrr_arh-fin-doc-contr-s-nal-obj.cli-code         = parreceiver-code         and
                                                      bfrr_arh-fin-doc-contr-s-nal-obj.contract-code    = parcontract-code         and
                                                      bfrr_arh-fin-doc-contr-s-nal-obj.fin-code-acc     = parreceiver-fin-code-acc and
                                                      bfrr_arh-fin-doc-contr-s-nal-obj.curr-code        = parcurr-code             and
                                                      bfrr_arh-fin-doc-contr-s-nal-obj.fin-ext-doc-type = parfin-ext-doc-type      and
                                                      bfrr_arh-fin-doc-contr-s-nal-obj.calc-curr-code   = 0                        and
                                                      bfrr_arh-fin-doc-contr-s-nal-obj.sum-type         = parsum-type              and
                                                      bfrr_arh-fin-doc-contr-s-nal-obj.fact-order       = parfact-order            exclusive-lock.
  end.
  for each rbfrr_arh-fin-doc-contr-s-n-obj where rbfrr_arh-fin-doc-contr-s-n-obj.host-code        = bfrr_arh-fin-doc-contr-s-nal-obj.host-code        and
                                                 rbfrr_arh-fin-doc-contr-s-n-obj.obj-type         = bfrr_arh-fin-doc-contr-s-nal-obj.obj-type         and
                                                 rbfrr_arh-fin-doc-contr-s-n-obj.obj-code         = bfrr_arh-fin-doc-contr-s-nal-obj.obj-code         and
                                                 rbfrr_arh-fin-doc-contr-s-n-obj.cli-type         = parreceiver-type                                  and
                                                 rbfrr_arh-fin-doc-contr-s-n-obj.cli-code         = parreceiver-code                                  and
                                                 rbfrr_arh-fin-doc-contr-s-n-obj.contract-code    = bfrr_arh-fin-doc-contr-s-nal-obj.contract-code    and
                                                 rbfrr_arh-fin-doc-contr-s-n-obj.fin-code-acc     = bfrr_arh-fin-doc-contr-s-nal-obj.fin-code-acc     and
                                                 rbfrr_arh-fin-doc-contr-s-n-obj.curr-code        = bfrr_arh-fin-doc-contr-s-nal-obj.curr-code        and
                                                 rbfrr_arh-fin-doc-contr-s-n-obj.fin-ext-doc-type = bfrr_arh-fin-doc-contr-s-nal-obj.fin-ext-doc-type and
                                                 rbfrr_arh-fin-doc-contr-s-n-obj.calc-curr-code   = bfrr_arh-fin-doc-contr-s-nal-obj.calc-curr-code   and
                                                 rbfrr_arh-fin-doc-contr-s-n-obj.sum-type         = bfrr_arh-fin-doc-contr-s-nal-obj.sum-type         and
                                                 rbfrr_arh-fin-doc-contr-s-n-obj.fact-order       > bfrr_arh-fin-doc-contr-s-nal-obj.fact-order       use-index pi on error undo, return error return-value :
    assign
      rbfrr_arh-fin-doc-contr-s-n-obj.income     = rbfrr_arh-fin-doc-contr-s-n-obj.income     + parsum-rubl
      rbfrr_arh-fin-doc-contr-s-n-obj.income-vat = rbfrr_arh-fin-doc-contr-s-n-obj.income-vat + parsum-vat-rubl
      rbfrr_arh-fin-doc-contr-s-n-obj.income-slt = rbfrr_arh-fin-doc-contr-s-n-obj.income-slt + parsum-slt-rubl
    .
  end.
  if parmode = "delete":u then do:
    delete bfpr_arh-fin-doc-contr-s-nal-obj.
    delete bfrr_arh-fin-doc-contr-s-nal-obj.
  end.
end.
if parbase-code <> parcurr-code and
   parbase-code <> 0            then do:
  if parmode = "close":u then do:
    find last bopb_arh-fin-doc-contr-s-nal-obj where bopb_arh-fin-doc-contr-s-nal-obj.host-code        = parhost-code          and
                                                     bopb_arh-fin-doc-contr-s-nal-obj.obj-type         = parobj-type           and
                                                     bopb_arh-fin-doc-contr-s-nal-obj.obj-code         = parobj-code           and
                                                     bopb_arh-fin-doc-contr-s-nal-obj.cli-type         = parpayer-type         and
                                                     bopb_arh-fin-doc-contr-s-nal-obj.cli-code         = parpayer-code         and
                                                     bopb_arh-fin-doc-contr-s-nal-obj.contract-code    = parcontract-code      and
                                                     bopb_arh-fin-doc-contr-s-nal-obj.fin-code-acc     = parpayer-fin-code-acc and
                                                     bopb_arh-fin-doc-contr-s-nal-obj.curr-code        = parcurr-code          and
                                                     bopb_arh-fin-doc-contr-s-nal-obj.fin-ext-doc-type = parfin-ext-doc-type   and
                                                     bopb_arh-fin-doc-contr-s-nal-obj.calc-curr-code   = parbase-code          and
                                                     bopb_arh-fin-doc-contr-s-nal-obj.sum-type         = parsum-type           and
                                                     bopb_arh-fin-doc-contr-s-nal-obj.fact-order       < parfact-order         use-index pi no-error.
    create bfpb_arh-fin-doc-contr-s-nal-obj.
    assign
      bfpb_arh-fin-doc-contr-s-nal-obj.host-code        = parhost-code
      bfpb_arh-fin-doc-contr-s-nal-obj.obj-type         = parobj-type
      bfpb_arh-fin-doc-contr-s-nal-obj.obj-code         = parobj-code
      bfpb_arh-fin-doc-contr-s-nal-obj.cli-type         = parpayer-type
      bfpb_arh-fin-doc-contr-s-nal-obj.cli-code         = parpayer-code
      bfpb_arh-fin-doc-contr-s-nal-obj.contract-code    = parcontract-code
      bfpb_arh-fin-doc-contr-s-nal-obj.fin-code-acc     = parpayer-fin-code-acc
      bfpb_arh-fin-doc-contr-s-nal-obj.curr-code        = parcurr-code
      bfpb_arh-fin-doc-contr-s-nal-obj.fin-ext-doc-type = parfin-ext-doc-type
      bfpb_arh-fin-doc-contr-s-nal-obj.calc-curr-code   = parbase-code
      bfpb_arh-fin-doc-contr-s-nal-obj.sum-type         = parsum-type
      bfpb_arh-fin-doc-contr-s-nal-obj.cource-des       = "b":u
      bfpb_arh-fin-doc-contr-s-nal-obj.fact-order       = parfact-order
      bfpb_arh-fin-doc-contr-s-nal-obj.fin-doc-code     = parfin-doc-code
      bfpb_arh-fin-doc-contr-s-nal-obj.fact-date        = parfact-date
      bfpb_arh-fin-doc-contr-s-nal-obj.curr-code        = parcurr-code
      bfpb_arh-fin-doc-contr-s-nal-obj.income           = (if available bopb_arh-fin-doc-contr-s-nal-obj then bopb_arh-fin-doc-contr-s-nal-obj.income      else 0)
      bfpb_arh-fin-doc-contr-s-nal-obj.income-vat       = (if available bopb_arh-fin-doc-contr-s-nal-obj then bopb_arh-fin-doc-contr-s-nal-obj.income-vat  else 0)
      bfpb_arh-fin-doc-contr-s-nal-obj.income-slt       = (if available bopb_arh-fin-doc-contr-s-nal-obj then bopb_arh-fin-doc-contr-s-nal-obj.income-slt  else 0)
      bfpb_arh-fin-doc-contr-s-nal-obj.expense          = (if available bopb_arh-fin-doc-contr-s-nal-obj then bopb_arh-fin-doc-contr-s-nal-obj.expense     else 0) + parsum-base
      bfpb_arh-fin-doc-contr-s-nal-obj.expense-vat      = (if available bopb_arh-fin-doc-contr-s-nal-obj then bopb_arh-fin-doc-contr-s-nal-obj.expense-vat else 0) + parsum-vat-base
      bfpb_arh-fin-doc-contr-s-nal-obj.expense-slt      = (if available bopb_arh-fin-doc-contr-s-nal-obj then bopb_arh-fin-doc-contr-s-nal-obj.expense-slt else 0) + parsum-slt-base
    .
  end.
  else do:
    find first bfpb_arh-fin-doc-contr-s-nal-obj where bfpb_arh-fin-doc-contr-s-nal-obj.host-code        = parhost-code          and
                                                      bfpb_arh-fin-doc-contr-s-nal-obj.obj-type         = parobj-type           and
                                                      bfpb_arh-fin-doc-contr-s-nal-obj.obj-code         = parobj-code           and
                                                      bfpb_arh-fin-doc-contr-s-nal-obj.cli-type         = parpayer-type         and
                                                      bfpb_arh-fin-doc-contr-s-nal-obj.cli-code         = parpayer-code         and
                                                      bfpb_arh-fin-doc-contr-s-nal-obj.contract-code    = parcontract-code      and
                                                      bfpb_arh-fin-doc-contr-s-nal-obj.fin-code-acc     = parpayer-fin-code-acc and
                                                      bfpb_arh-fin-doc-contr-s-nal-obj.curr-code        = parcurr-code          and
                                                      bfpb_arh-fin-doc-contr-s-nal-obj.fin-ext-doc-type = parfin-ext-doc-type   and
                                                      bfpb_arh-fin-doc-contr-s-nal-obj.calc-curr-code   = parbase-code          and
                                                      bfpb_arh-fin-doc-contr-s-nal-obj.sum-type         = parsum-type           and
                                                      bfpb_arh-fin-doc-contr-s-nal-obj.fact-order       = parfact-order         exclusive-lock.
  end.
  for each rbfpb_arh-fin-doc-contr-s-n-obj where rbfpb_arh-fin-doc-contr-s-n-obj.host-code        = bfpb_arh-fin-doc-contr-s-nal-obj.host-code        and
                                                 rbfpb_arh-fin-doc-contr-s-n-obj.obj-type         = bfpb_arh-fin-doc-contr-s-nal-obj.obj-type         and
                                                 rbfpb_arh-fin-doc-contr-s-n-obj.obj-code         = bfpb_arh-fin-doc-contr-s-nal-obj.obj-code         and
                                                 rbfpb_arh-fin-doc-contr-s-n-obj.cli-type         = parpayer-type                                     and
                                                 rbfpb_arh-fin-doc-contr-s-n-obj.cli-code         = parpayer-code                                     and
                                                 rbfpb_arh-fin-doc-contr-s-n-obj.contract-code    = bfpb_arh-fin-doc-contr-s-nal-obj.contract-code    and
                                                 rbfpb_arh-fin-doc-contr-s-n-obj.fin-code-acc     = bfpb_arh-fin-doc-contr-s-nal-obj.fin-code-acc     and
                                                 rbfpb_arh-fin-doc-contr-s-n-obj.curr-code        = bfpb_arh-fin-doc-contr-s-nal-obj.curr-code        and
                                                 rbfpb_arh-fin-doc-contr-s-n-obj.fin-ext-doc-type = bfpb_arh-fin-doc-contr-s-nal-obj.fin-ext-doc-type and
                                                 rbfpb_arh-fin-doc-contr-s-n-obj.calc-curr-code   = bfpb_arh-fin-doc-contr-s-nal-obj.calc-curr-code   and
                                                 rbfpb_arh-fin-doc-contr-s-n-obj.sum-type         = bfpb_arh-fin-doc-contr-s-nal-obj.sum-type         and
                                                 rbfpb_arh-fin-doc-contr-s-n-obj.fact-order       > bfpb_arh-fin-doc-contr-s-nal-obj.fact-order       use-index pi exclusive-lock on error undo, return error return-value :
    assign
      rbfpb_arh-fin-doc-contr-s-n-obj.expense     = rbfpb_arh-fin-doc-contr-s-n-obj.expense     + parsum-base
      rbfpb_arh-fin-doc-contr-s-n-obj.expense-vat = rbfpb_arh-fin-doc-contr-s-n-obj.expense-vat + parsum-vat-base
      rbfpb_arh-fin-doc-contr-s-n-obj.expense-slt = rbfpb_arh-fin-doc-contr-s-n-obj.expense-slt + parsum-slt-base
    .
  end.
  if parmode = "close":u then do:
    find last borb_arh-fin-doc-contr-s-nal-obj where borb_arh-fin-doc-contr-s-nal-obj.host-code        = parhost-code             and
                                                     borb_arh-fin-doc-contr-s-nal-obj.obj-type         = parobj-type              and
                                                     borb_arh-fin-doc-contr-s-nal-obj.obj-code         = parobj-code              and
                                                     borb_arh-fin-doc-contr-s-nal-obj.cli-type         = parreceiver-type         and
                                                     borb_arh-fin-doc-contr-s-nal-obj.cli-code         = parreceiver-code         and
                                                     borb_arh-fin-doc-contr-s-nal-obj.contract-code    = parcontract-code         and
                                                     borb_arh-fin-doc-contr-s-nal-obj.fin-code-acc     = parreceiver-fin-code-acc and
                                                     borb_arh-fin-doc-contr-s-nal-obj.curr-code        = parcurr-code             and
                                                     borb_arh-fin-doc-contr-s-nal-obj.fin-ext-doc-type = parfin-ext-doc-type      and
                                                     borb_arh-fin-doc-contr-s-nal-obj.calc-curr-code   = parbase-code             and
                                                     borb_arh-fin-doc-contr-s-nal-obj.sum-type         = parsum-type              and
                                                     borb_arh-fin-doc-contr-s-nal-obj.fact-order       < parfact-order            use-index pi no-error.
    create bfrb_arh-fin-doc-contr-s-nal-obj.
    assign
      bfrb_arh-fin-doc-contr-s-nal-obj.host-code        = parhost-code
      bfrb_arh-fin-doc-contr-s-nal-obj.obj-type         = parobj-type
      bfrb_arh-fin-doc-contr-s-nal-obj.obj-code         = parobj-code
      bfrb_arh-fin-doc-contr-s-nal-obj.cli-type         = parreceiver-type
      bfrb_arh-fin-doc-contr-s-nal-obj.cli-code         = parreceiver-code
      bfrb_arh-fin-doc-contr-s-nal-obj.contract-code    = parcontract-code
      bfrb_arh-fin-doc-contr-s-nal-obj.fin-code-acc     = parreceiver-fin-code-acc
      bfrb_arh-fin-doc-contr-s-nal-obj.curr-code        = parcurr-code
      bfrb_arh-fin-doc-contr-s-nal-obj.fin-ext-doc-type = parfin-ext-doc-type
      bfrb_arh-fin-doc-contr-s-nal-obj.calc-curr-code   = parbase-code
      bfrb_arh-fin-doc-contr-s-nal-obj.sum-type         = parsum-type
      bfrb_arh-fin-doc-contr-s-nal-obj.cource-des       = "b":u
      bfrb_arh-fin-doc-contr-s-nal-obj.fact-order       = parfact-order
      bfrb_arh-fin-doc-contr-s-nal-obj.fin-doc-code     = parfin-doc-code
      bfrb_arh-fin-doc-contr-s-nal-obj.fact-date        = parfact-date
      bfrb_arh-fin-doc-contr-s-nal-obj.curr-code        = parcurr-code
    .
    assign
      bfrb_arh-fin-doc-contr-s-nal-obj.expense          = (if available borb_arh-fin-doc-contr-s-nal-obj then borb_arh-fin-doc-contr-s-nal-obj.expense     else 0)
      bfrb_arh-fin-doc-contr-s-nal-obj.expense-vat      = (if available borb_arh-fin-doc-contr-s-nal-obj then borb_arh-fin-doc-contr-s-nal-obj.expense-vat else 0)
      bfrb_arh-fin-doc-contr-s-nal-obj.expense-slt      = (if available borb_arh-fin-doc-contr-s-nal-obj then borb_arh-fin-doc-contr-s-nal-obj.expense-slt else 0)
      bfrb_arh-fin-doc-contr-s-nal-obj.income           = (if available borb_arh-fin-doc-contr-s-nal-obj then borb_arh-fin-doc-contr-s-nal-obj.income      else 0) + parsum-base
      bfrb_arh-fin-doc-contr-s-nal-obj.income-vat       = (if available borb_arh-fin-doc-contr-s-nal-obj then borb_arh-fin-doc-contr-s-nal-obj.income-vat  else 0) + parsum-vat-base
      bfrb_arh-fin-doc-contr-s-nal-obj.income-slt       = (if available borb_arh-fin-doc-contr-s-nal-obj then borb_arh-fin-doc-contr-s-nal-obj.income-slt  else 0) + parsum-slt-base
    .
  end.
  else do:
    find first bfrb_arh-fin-doc-contr-s-nal-obj where bfrb_arh-fin-doc-contr-s-nal-obj.host-code        = parhost-code             and
                                                      bfrb_arh-fin-doc-contr-s-nal-obj.obj-type         = parobj-type              and
                                                      bfrb_arh-fin-doc-contr-s-nal-obj.obj-code         = parobj-code              and
                                                      bfrb_arh-fin-doc-contr-s-nal-obj.cli-type         = parreceiver-type         and
                                                      bfrb_arh-fin-doc-contr-s-nal-obj.cli-code         = parreceiver-code         and
                                                      bfrb_arh-fin-doc-contr-s-nal-obj.contract-code    = parcontract-code         and
                                                      bfrb_arh-fin-doc-contr-s-nal-obj.fin-code-acc     = parreceiver-fin-code-acc and
                                                      bfrb_arh-fin-doc-contr-s-nal-obj.curr-code        = parcurr-code             and
                                                      bfrb_arh-fin-doc-contr-s-nal-obj.fin-ext-doc-type = parfin-ext-doc-type      and
                                                      bfrb_arh-fin-doc-contr-s-nal-obj.calc-curr-code   = parbase-code             and
                                                      bfrb_arh-fin-doc-contr-s-nal-obj.sum-type         = parsum-type              and
                                                      bfrb_arh-fin-doc-contr-s-nal-obj.fact-order       = parfact-order            exclusive-lock.
  end.
  for each rbfrb_arh-fin-doc-contr-s-n-obj where rbfrb_arh-fin-doc-contr-s-n-obj.host-code        = bfrb_arh-fin-doc-contr-s-nal-obj.host-code        and
                                                 rbfrb_arh-fin-doc-contr-s-n-obj.obj-type         = bfrb_arh-fin-doc-contr-s-nal-obj.obj-type         and
                                                 rbfrb_arh-fin-doc-contr-s-n-obj.obj-code         = bfrb_arh-fin-doc-contr-s-nal-obj.obj-code         and
                                                 rbfrb_arh-fin-doc-contr-s-n-obj.cli-type         = parreceiver-type                                  and
                                                 rbfrb_arh-fin-doc-contr-s-n-obj.cli-code         = parreceiver-code                                  and
                                                 rbfrb_arh-fin-doc-contr-s-n-obj.contract-code    = bfrb_arh-fin-doc-contr-s-nal-obj.contract-code    and
                                                 rbfrb_arh-fin-doc-contr-s-n-obj.fin-code-acc     = bfrb_arh-fin-doc-contr-s-nal-obj.fin-code-acc     and
                                                 rbfrb_arh-fin-doc-contr-s-n-obj.curr-code        = bfrb_arh-fin-doc-contr-s-nal-obj.curr-code        and
                                                 rbfrb_arh-fin-doc-contr-s-n-obj.fin-ext-doc-type = bfrb_arh-fin-doc-contr-s-nal-obj.fin-ext-doc-type and
                                                 rbfrb_arh-fin-doc-contr-s-n-obj.calc-curr-code   = bfrb_arh-fin-doc-contr-s-nal-obj.calc-curr-code   and
                                                 rbfrb_arh-fin-doc-contr-s-n-obj.sum-type         = bfrb_arh-fin-doc-contr-s-nal-obj.sum-type         and
                                                 rbfrb_arh-fin-doc-contr-s-n-obj.fact-order       > bfrb_arh-fin-doc-contr-s-nal-obj.fact-order       use-index pi on error undo, return error return-value :
    assign
      rbfrb_arh-fin-doc-contr-s-n-obj.income     = rbfrb_arh-fin-doc-contr-s-n-obj.income     + parsum-base
      rbfrb_arh-fin-doc-contr-s-n-obj.income-vat = rbfrb_arh-fin-doc-contr-s-n-obj.income-vat + parsum-vat-base
      rbfrb_arh-fin-doc-contr-s-n-obj.income-slt = rbfrb_arh-fin-doc-contr-s-n-obj.income-slt + parsum-slt-base
    .
  end.
  if parmode = "delete":u then do:
    delete bfpb_arh-fin-doc-contr-s-nal-obj.
    delete bfrb_arh-fin-doc-contr-s-nal-obj.
  end.
end.
if parrel-dog-code  =  yes          and
   parcurr-dog-code <> parcurr-code and
   parcurr-dog-code <> 0            and
   parcurr-dog-code <> parbase-code then do:
  if parmode = "close":u then do:
    find last bopc_arh-fin-doc-contr-s-nal-obj where bopc_arh-fin-doc-contr-s-nal-obj.host-code        = parhost-code          and
                                                     bopc_arh-fin-doc-contr-s-nal-obj.obj-type         = parobj-type           and
                                                     bopc_arh-fin-doc-contr-s-nal-obj.obj-code         = parobj-code           and
                                                     bopc_arh-fin-doc-contr-s-nal-obj.cli-type         = parpayer-type         and
                                                     bopc_arh-fin-doc-contr-s-nal-obj.cli-code         = parpayer-code         and
                                                     bopc_arh-fin-doc-contr-s-nal-obj.contract-code    = parcontract-code      and
                                                     bopc_arh-fin-doc-contr-s-nal-obj.fin-code-acc     = parpayer-fin-code-acc and
                                                     bopc_arh-fin-doc-contr-s-nal-obj.curr-code        = parcurr-code          and
                                                     bopc_arh-fin-doc-contr-s-nal-obj.fin-ext-doc-type = parfin-ext-doc-type   and
                                                     bopc_arh-fin-doc-contr-s-nal-obj.calc-curr-code   = parcurr-dog-code      and
                                                     bopc_arh-fin-doc-contr-s-nal-obj.sum-type         = parsum-type           and
                                                     bopc_arh-fin-doc-contr-s-nal-obj.fact-order       < parfact-order         use-index pi no-error.
    create bfpc_arh-fin-doc-contr-s-nal-obj.
    assign
      bfpc_arh-fin-doc-contr-s-nal-obj.host-code        = parhost-code
      bfpc_arh-fin-doc-contr-s-nal-obj.obj-type         = parobj-type
      bfpc_arh-fin-doc-contr-s-nal-obj.obj-code         = parobj-code
      bfpc_arh-fin-doc-contr-s-nal-obj.cli-type         = parpayer-type
      bfpc_arh-fin-doc-contr-s-nal-obj.cli-code         = parpayer-code
      bfpc_arh-fin-doc-contr-s-nal-obj.contract-code    = parcontract-code
      bfpc_arh-fin-doc-contr-s-nal-obj.fin-code-acc     = parpayer-fin-code-acc
      bfpc_arh-fin-doc-contr-s-nal-obj.curr-code        = parcurr-code
      bfpc_arh-fin-doc-contr-s-nal-obj.fin-ext-doc-type = parfin-ext-doc-type
      bfpc_arh-fin-doc-contr-s-nal-obj.calc-curr-code   = parcurr-dog-code
      bfpc_arh-fin-doc-contr-s-nal-obj.sum-type         = parsum-type
      bfpc_arh-fin-doc-contr-s-nal-obj.cource-des       = "c":u
      bfpc_arh-fin-doc-contr-s-nal-obj.fact-order       = parfact-order
      bfpc_arh-fin-doc-contr-s-nal-obj.fin-doc-code     = parfin-doc-code
      bfpc_arh-fin-doc-contr-s-nal-obj.fact-date        = parfact-date
      bfpc_arh-fin-doc-contr-s-nal-obj.curr-code        = parcurr-code
      bfpc_arh-fin-doc-contr-s-nal-obj.income           = (if available bopc_arh-fin-doc-contr-s-nal-obj then bopc_arh-fin-doc-contr-s-nal-obj.income     else 0)
      bfpc_arh-fin-doc-contr-s-nal-obj.income-vat       = (if available bopc_arh-fin-doc-contr-s-nal-obj then bopc_arh-fin-doc-contr-s-nal-obj.income-vat else 0)
      bfpc_arh-fin-doc-contr-s-nal-obj.income-slt       = (if available bopc_arh-fin-doc-contr-s-nal-obj then bopc_arh-fin-doc-contr-s-nal-obj.income-slt else 0)
      bfpc_arh-fin-doc-contr-s-nal-obj.expense          = (if available bopc_arh-fin-doc-contr-s-nal-obj then bopc_arh-fin-doc-contr-s-nal-obj.expense     else 0) + parsum-contr
      bfpc_arh-fin-doc-contr-s-nal-obj.expense-vat      = (if available bopc_arh-fin-doc-contr-s-nal-obj then bopc_arh-fin-doc-contr-s-nal-obj.expense-vat else 0) + parsum-vat-contr
      bfpc_arh-fin-doc-contr-s-nal-obj.expense-slt      = (if available bopc_arh-fin-doc-contr-s-nal-obj then bopc_arh-fin-doc-contr-s-nal-obj.expense-slt else 0) + parsum-slt-contr
    .
  end.
  else do:
    find first bfpc_arh-fin-doc-contr-s-nal-obj where bfpc_arh-fin-doc-contr-s-nal-obj.host-code        = parhost-code          and
                                                      bfpc_arh-fin-doc-contr-s-nal-obj.obj-type         = parobj-type           and
                                                      bfpc_arh-fin-doc-contr-s-nal-obj.obj-code         = parobj-code           and
                                                      bfpc_arh-fin-doc-contr-s-nal-obj.cli-type         = parpayer-type         and
                                                      bfpc_arh-fin-doc-contr-s-nal-obj.cli-code         = parpayer-code         and
                                                      bfpc_arh-fin-doc-contr-s-nal-obj.contract-code    = parcontract-code      and
                                                      bfpc_arh-fin-doc-contr-s-nal-obj.fin-code-acc     = parpayer-fin-code-acc and
                                                      bfpc_arh-fin-doc-contr-s-nal-obj.curr-code        = parcurr-code          and
                                                      bfpc_arh-fin-doc-contr-s-nal-obj.fin-ext-doc-type = parfin-ext-doc-type   and
                                                      bfpc_arh-fin-doc-contr-s-nal-obj.calc-curr-code   = parcurr-dog-code      and
                                                      bfpc_arh-fin-doc-contr-s-nal-obj.sum-type         = parsum-type           and
                                                      bfpc_arh-fin-doc-contr-s-nal-obj.fact-order       = parfact-order         exclusive-lock.
  end.
  for each rbfpc_arh-fin-doc-contr-s-n-obj where rbfpc_arh-fin-doc-contr-s-n-obj.host-code        = bfpc_arh-fin-doc-contr-s-nal-obj.host-code        and
                                                 rbfpc_arh-fin-doc-contr-s-n-obj.obj-type         = bfpc_arh-fin-doc-contr-s-nal-obj.obj-type         and
                                                 rbfpc_arh-fin-doc-contr-s-n-obj.obj-code         = bfpc_arh-fin-doc-contr-s-nal-obj.obj-code         and
                                                 rbfpc_arh-fin-doc-contr-s-n-obj.cli-type         = parpayer-type                                     and
                                                 rbfpc_arh-fin-doc-contr-s-n-obj.cli-code         = parpayer-code                                     and
                                                 rbfpc_arh-fin-doc-contr-s-n-obj.contract-code    = bfpc_arh-fin-doc-contr-s-nal-obj.contract-code    and
                                                 rbfpc_arh-fin-doc-contr-s-n-obj.fin-code-acc     = bfpc_arh-fin-doc-contr-s-nal-obj.fin-code-acc     and
                                                 rbfpc_arh-fin-doc-contr-s-n-obj.curr-code        = bfpc_arh-fin-doc-contr-s-nal-obj.curr-code        and
                                                 rbfpc_arh-fin-doc-contr-s-n-obj.fin-ext-doc-type = bfpc_arh-fin-doc-contr-s-nal-obj.fin-ext-doc-type and
                                                 rbfpc_arh-fin-doc-contr-s-n-obj.calc-curr-code   = bfpc_arh-fin-doc-contr-s-nal-obj.calc-curr-code   and
                                                 rbfpc_arh-fin-doc-contr-s-n-obj.sum-type         = bfpc_arh-fin-doc-contr-s-nal-obj.sum-type         and
                                                 rbfpc_arh-fin-doc-contr-s-n-obj.fact-order       > bfpc_arh-fin-doc-contr-s-nal-obj.fact-order       use-index pi exclusive-lock on error undo, return error return-value :
    assign
      rbfpc_arh-fin-doc-contr-s-n-obj.expense     = rbfpc_arh-fin-doc-contr-s-n-obj.expense     + parsum-contr
      rbfpc_arh-fin-doc-contr-s-n-obj.expense-vat = rbfpc_arh-fin-doc-contr-s-n-obj.expense-vat + parsum-vat-contr
      rbfpc_arh-fin-doc-contr-s-n-obj.expense-slt = rbfpc_arh-fin-doc-contr-s-n-obj.expense-slt + parsum-slt-contr
    .
  end.
  if parmode = "close":u then do:
    find last borc_arh-fin-doc-contr-s-nal-obj where borc_arh-fin-doc-contr-s-nal-obj.host-code        = parhost-code             and
                                                     borc_arh-fin-doc-contr-s-nal-obj.obj-type         = parobj-type              and
                                                     borc_arh-fin-doc-contr-s-nal-obj.obj-code         = parobj-code              and
                                                     borc_arh-fin-doc-contr-s-nal-obj.cli-type         = parreceiver-type         and
                                                     borc_arh-fin-doc-contr-s-nal-obj.cli-code         = parreceiver-code         and
                                                     borc_arh-fin-doc-contr-s-nal-obj.contract-code    = parcontract-code         and
                                                     borc_arh-fin-doc-contr-s-nal-obj.fin-code-acc     = parreceiver-fin-code-acc and
                                                     borc_arh-fin-doc-contr-s-nal-obj.curr-code        = parcurr-code             and
                                                     borc_arh-fin-doc-contr-s-nal-obj.fin-ext-doc-type = parfin-ext-doc-type      and
                                                     borc_arh-fin-doc-contr-s-nal-obj.calc-curr-code   = parcurr-dog-code         and
                                                     borc_arh-fin-doc-contr-s-nal-obj.sum-type         = parsum-type              and
                                                     borc_arh-fin-doc-contr-s-nal-obj.fact-order       < parfact-order            use-index pi no-error.
    create bfrc_arh-fin-doc-contr-s-nal-obj.
    assign
      bfrc_arh-fin-doc-contr-s-nal-obj.host-code        = parhost-code
      bfrc_arh-fin-doc-contr-s-nal-obj.obj-type         = parobj-type
      bfrc_arh-fin-doc-contr-s-nal-obj.obj-code         = parobj-code
      bfrc_arh-fin-doc-contr-s-nal-obj.cli-type         = parreceiver-type
      bfrc_arh-fin-doc-contr-s-nal-obj.cli-code         = parreceiver-code
      bfrc_arh-fin-doc-contr-s-nal-obj.contract-code    = parcontract-code
      bfrc_arh-fin-doc-contr-s-nal-obj.fin-code-acc     = parreceiver-fin-code-acc
      bfrc_arh-fin-doc-contr-s-nal-obj.curr-code        = parcurr-code
      bfrc_arh-fin-doc-contr-s-nal-obj.fin-ext-doc-type = parfin-ext-doc-type
      bfrc_arh-fin-doc-contr-s-nal-obj.calc-curr-code   = parcurr-dog-code
      bfrc_arh-fin-doc-contr-s-nal-obj.sum-type         = parsum-type
      bfrc_arh-fin-doc-contr-s-nal-obj.cource-des       = "c":u
      bfrc_arh-fin-doc-contr-s-nal-obj.fact-order       = parfact-order
      bfrc_arh-fin-doc-contr-s-nal-obj.fin-doc-code     = parfin-doc-code
      bfrc_arh-fin-doc-contr-s-nal-obj.fact-date        = parfact-date
      bfrc_arh-fin-doc-contr-s-nal-obj.curr-code        = parcurr-code
    .
    assign
      bfrc_arh-fin-doc-contr-s-nal-obj.expense          = (if available borc_arh-fin-doc-contr-s-nal-obj then borc_arh-fin-doc-contr-s-nal-obj.expense     else 0)
      bfrc_arh-fin-doc-contr-s-nal-obj.expense-vat      = (if available borc_arh-fin-doc-contr-s-nal-obj then borc_arh-fin-doc-contr-s-nal-obj.expense-vat else 0)
      bfrc_arh-fin-doc-contr-s-nal-obj.expense-slt      = (if available borc_arh-fin-doc-contr-s-nal-obj then borc_arh-fin-doc-contr-s-nal-obj.expense-slt else 0)
      bfrc_arh-fin-doc-contr-s-nal-obj.income           = (if available borc_arh-fin-doc-contr-s-nal-obj then borc_arh-fin-doc-contr-s-nal-obj.income      else 0) + parsum-contr
      bfrc_arh-fin-doc-contr-s-nal-obj.income-vat       = (if available borc_arh-fin-doc-contr-s-nal-obj then borc_arh-fin-doc-contr-s-nal-obj.income-vat  else 0) + parsum-vat-contr
      bfrc_arh-fin-doc-contr-s-nal-obj.income-slt       = (if available borc_arh-fin-doc-contr-s-nal-obj then borc_arh-fin-doc-contr-s-nal-obj.income-slt  else 0) + parsum-slt-contr
    .
  end.
  else do:
    find first bfrc_arh-fin-doc-contr-s-nal-obj where bfrc_arh-fin-doc-contr-s-nal-obj.host-code        = parhost-code             and
                                                      bfrc_arh-fin-doc-contr-s-nal-obj.obj-type         = parobj-type              and
                                                      bfrc_arh-fin-doc-contr-s-nal-obj.obj-code         = parobj-code              and
                                                      bfrc_arh-fin-doc-contr-s-nal-obj.cli-type         = parreceiver-type         and
                                                      bfrc_arh-fin-doc-contr-s-nal-obj.cli-code         = parreceiver-code         and
                                                      bfrc_arh-fin-doc-contr-s-nal-obj.contract-code    = parcontract-code         and
                                                      bfrc_arh-fin-doc-contr-s-nal-obj.fin-code-acc     = parreceiver-fin-code-acc and
                                                      bfrc_arh-fin-doc-contr-s-nal-obj.curr-code        = parcurr-code             and
                                                      bfrc_arh-fin-doc-contr-s-nal-obj.fin-ext-doc-type = parfin-ext-doc-type      and
                                                      bfrc_arh-fin-doc-contr-s-nal-obj.calc-curr-code   = parcurr-dog-code         and
                                                      bfrc_arh-fin-doc-contr-s-nal-obj.sum-type         = parsum-type              and
                                                      bfrc_arh-fin-doc-contr-s-nal-obj.fact-order       = parfact-order            exclusive-lock.
  end.
  for each rbfrc_arh-fin-doc-contr-s-n-obj where rbfrc_arh-fin-doc-contr-s-n-obj.host-code        = bfrc_arh-fin-doc-contr-s-nal-obj.host-code        and
                                                 rbfrc_arh-fin-doc-contr-s-n-obj.obj-type         = bfrc_arh-fin-doc-contr-s-nal-obj.obj-type         and
                                                 rbfrc_arh-fin-doc-contr-s-n-obj.obj-code         = bfrc_arh-fin-doc-contr-s-nal-obj.obj-code         and
                                                 rbfrc_arh-fin-doc-contr-s-n-obj.cli-type         = parreceiver-type                                  and
                                                 rbfrc_arh-fin-doc-contr-s-n-obj.cli-code         = parreceiver-code                                  and
                                                 rbfrc_arh-fin-doc-contr-s-n-obj.contract-code    = bfrc_arh-fin-doc-contr-s-nal-obj.contract-code    and
                                                 rbfrc_arh-fin-doc-contr-s-n-obj.fin-code-acc     = bfrc_arh-fin-doc-contr-s-nal-obj.fin-code-acc     and
                                                 rbfrc_arh-fin-doc-contr-s-n-obj.curr-code        = bfrc_arh-fin-doc-contr-s-nal-obj.curr-code        and
                                                 rbfrc_arh-fin-doc-contr-s-n-obj.fin-ext-doc-type = bfrc_arh-fin-doc-contr-s-nal-obj.fin-ext-doc-type and
                                                 rbfrc_arh-fin-doc-contr-s-n-obj.calc-curr-code   = bfrc_arh-fin-doc-contr-s-nal-obj.calc-curr-code   and
                                                 rbfrc_arh-fin-doc-contr-s-n-obj.sum-type         = bfrc_arh-fin-doc-contr-s-nal-obj.sum-type         and
                                                 rbfrc_arh-fin-doc-contr-s-n-obj.fact-order       > bfrc_arh-fin-doc-contr-s-nal-obj.fact-order       use-index pi on error undo, return error return-value :
    assign
      rbfrc_arh-fin-doc-contr-s-n-obj.income     = rbfrc_arh-fin-doc-contr-s-n-obj.income     + parsum-contr
      rbfrc_arh-fin-doc-contr-s-n-obj.income-vat = rbfrc_arh-fin-doc-contr-s-n-obj.income-vat + parsum-vat-contr
      rbfrc_arh-fin-doc-contr-s-n-obj.income-slt = rbfrc_arh-fin-doc-contr-s-n-obj.income-slt + parsum-slt-contr
    .
  end.
  if parmode = "delete":u then do:
    delete bfpc_arh-fin-doc-contr-s-nal-obj.
    delete bfrc_arh-fin-doc-contr-s-nal-obj.
  end.
end.
end.
end procedure.
procedure libfarpo_calc-arh-fin-doc-contr-schet-tax-n-obj :
define input parameter parmode                    as   character                    no-undo.
define input parameter parhost-code               like ub.fin-doc.host-code         no-undo.
define input parameter parobj-type                like ub.fin-doc.obj-type          no-undo.
define input parameter parobj-code                like ub.fin-doc.obj-code          no-undo.
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
define buffer bfps_arh-fin-doc-c-s-tax-nal-obj for ub.arh-fin-doc-c-s-tax-nal-obj.
define buffer bfrs_arh-fin-doc-c-s-tax-nal-obj for ub.arh-fin-doc-c-s-tax-nal-obj.
define buffer rbfps_arh-fin-doc-c-s-tax-n-obj for ub.arh-fin-doc-c-s-tax-nal-obj.
define buffer rbfrs_arh-fin-doc-c-s-tax-n-obj for ub.arh-fin-doc-c-s-tax-nal-obj.
define buffer bops_arh-fin-doc-c-s-tax-nal-obj for ub.arh-fin-doc-c-s-tax-nal-obj.
define buffer bors_arh-fin-doc-c-s-tax-nal-obj for ub.arh-fin-doc-c-s-tax-nal-obj.
define buffer bfpr_arh-fin-doc-c-s-tax-nal-obj for ub.arh-fin-doc-c-s-tax-nal-obj.
define buffer bfrr_arh-fin-doc-c-s-tax-nal-obj for ub.arh-fin-doc-c-s-tax-nal-obj.
define buffer rbfpr_arh-fin-doc-c-s-tax-n-obj for ub.arh-fin-doc-c-s-tax-nal-obj.
define buffer rbfrr_arh-fin-doc-c-s-tax-n-obj for ub.arh-fin-doc-c-s-tax-nal-obj.
define buffer bopr_arh-fin-doc-c-s-tax-nal-obj for ub.arh-fin-doc-c-s-tax-nal-obj.
define buffer borr_arh-fin-doc-c-s-tax-nal-obj for ub.arh-fin-doc-c-s-tax-nal-obj.
define buffer bfpb_arh-fin-doc-c-s-tax-nal-obj for ub.arh-fin-doc-c-s-tax-nal-obj.
define buffer bfrb_arh-fin-doc-c-s-tax-nal-obj for ub.arh-fin-doc-c-s-tax-nal-obj.
define buffer rbfpb_arh-fin-doc-c-s-tax-n-obj for ub.arh-fin-doc-c-s-tax-nal-obj.
define buffer rbfrb_arh-fin-doc-c-s-tax-n-obj for ub.arh-fin-doc-c-s-tax-nal-obj.
define buffer bopb_arh-fin-doc-c-s-tax-nal-obj for ub.arh-fin-doc-c-s-tax-nal-obj.
define buffer borb_arh-fin-doc-c-s-tax-nal-obj for ub.arh-fin-doc-c-s-tax-nal-obj.
define buffer bfpc_arh-fin-doc-c-s-tax-nal-obj for ub.arh-fin-doc-c-s-tax-nal-obj.
define buffer bfrc_arh-fin-doc-c-s-tax-nal-obj for ub.arh-fin-doc-c-s-tax-nal-obj.
define buffer rbfpc_arh-fin-doc-c-s-tax-n-obj for ub.arh-fin-doc-c-s-tax-nal-obj.
define buffer rbfrc_arh-fin-doc-c-s-tax-n-obj for ub.arh-fin-doc-c-s-tax-nal-obj.
define buffer bopc_arh-fin-doc-c-s-tax-nal-obj for ub.arh-fin-doc-c-s-tax-nal-obj.
define buffer borc_arh-fin-doc-c-s-tax-nal-obj for ub.arh-fin-doc-c-s-tax-nal-obj.
do on error undo, return error substitute ("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
if parmode = "close":u then do:
  find last bops_arh-fin-doc-c-s-tax-nal-obj where bops_arh-fin-doc-c-s-tax-nal-obj.host-code        = parhost-code          and
                                                   bops_arh-fin-doc-c-s-tax-nal-obj.obj-type         = parobj-type           and
                                                   bops_arh-fin-doc-c-s-tax-nal-obj.obj-code         = parobj-code           and
                                                   bops_arh-fin-doc-c-s-tax-nal-obj.cli-type         = parpayer-type         and
                                                   bops_arh-fin-doc-c-s-tax-nal-obj.cli-code         = parpayer-code         and
                                                   bops_arh-fin-doc-c-s-tax-nal-obj.contract-code    = parcontract-code      and
                                                   bops_arh-fin-doc-c-s-tax-nal-obj.fin-code-acc     = parpayer-fin-code-acc and
                                                   bops_arh-fin-doc-c-s-tax-nal-obj.curr-code        = parcurr-code          and
                                                   bops_arh-fin-doc-c-s-tax-nal-obj.fin-ext-doc-type = parfin-ext-doc-type   and
                                                   bops_arh-fin-doc-c-s-tax-nal-obj.calc-curr-code   = parcurr-code          and
                                                   bops_arh-fin-doc-c-s-tax-nal-obj.vat-pc           = parvat-pc             and
                                                   bops_arh-fin-doc-c-s-tax-nal-obj.slt-pc           = parslt-pc             and
                                                   bops_arh-fin-doc-c-s-tax-nal-obj.with-vat         = parwith-vat           and
                                                   bops_arh-fin-doc-c-s-tax-nal-obj.with-slt         = parwith-slt           and
                                                   bops_arh-fin-doc-c-s-tax-nal-obj.sum-type         = parsum-type           and
                                                   bops_arh-fin-doc-c-s-tax-nal-obj.fact-order       < parfact-order         no-error.
  create bfps_arh-fin-doc-c-s-tax-nal-obj.
  assign
    bfps_arh-fin-doc-c-s-tax-nal-obj.host-code        = parhost-code
    bfps_arh-fin-doc-c-s-tax-nal-obj.obj-type         = parobj-type
    bfps_arh-fin-doc-c-s-tax-nal-obj.obj-code         = parobj-code
    bfps_arh-fin-doc-c-s-tax-nal-obj.cli-type         = parpayer-type
    bfps_arh-fin-doc-c-s-tax-nal-obj.cli-code         = parpayer-code
    bfps_arh-fin-doc-c-s-tax-nal-obj.contract-code    = parcontract-code
    bfps_arh-fin-doc-c-s-tax-nal-obj.fin-code-acc     = parpayer-fin-code-acc
    bfps_arh-fin-doc-c-s-tax-nal-obj.curr-code        = parcurr-code
    bfps_arh-fin-doc-c-s-tax-nal-obj.fin-ext-doc-type = parfin-ext-doc-type
    bfps_arh-fin-doc-c-s-tax-nal-obj.calc-curr-code   = parcurr-code
    bfps_arh-fin-doc-c-s-tax-nal-obj.vat-pc           = parvat-pc
    bfps_arh-fin-doc-c-s-tax-nal-obj.slt-pc           = parslt-pc
    bfps_arh-fin-doc-c-s-tax-nal-obj.with-vat         = parwith-vat
    bfps_arh-fin-doc-c-s-tax-nal-obj.with-slt         = parwith-slt
    bfps_arh-fin-doc-c-s-tax-nal-obj.sum-type         = parsum-type
    bfps_arh-fin-doc-c-s-tax-nal-obj.cource-des       = "s":u
    bfps_arh-fin-doc-c-s-tax-nal-obj.fact-order       = parfact-order
    bfps_arh-fin-doc-c-s-tax-nal-obj.fin-doc-code     = parfin-doc-code
    bfps_arh-fin-doc-c-s-tax-nal-obj.fact-date        = parfact-date
    bfps_arh-fin-doc-c-s-tax-nal-obj.curr-code        = parcurr-code
    bfps_arh-fin-doc-c-s-tax-nal-obj.income           = (if available bops_arh-fin-doc-c-s-tax-nal-obj then bops_arh-fin-doc-c-s-tax-nal-obj.income      else 0)
    bfps_arh-fin-doc-c-s-tax-nal-obj.income-vat       = (if available bops_arh-fin-doc-c-s-tax-nal-obj then bops_arh-fin-doc-c-s-tax-nal-obj.income-vat  else 0)
    bfps_arh-fin-doc-c-s-tax-nal-obj.income-slt       = (if available bops_arh-fin-doc-c-s-tax-nal-obj then bops_arh-fin-doc-c-s-tax-nal-obj.income-slt  else 0)
    bfps_arh-fin-doc-c-s-tax-nal-obj.expense          = (if available bops_arh-fin-doc-c-s-tax-nal-obj then bops_arh-fin-doc-c-s-tax-nal-obj.expense     else 0) + parsum-doc
    bfps_arh-fin-doc-c-s-tax-nal-obj.expense-vat      = (if available bops_arh-fin-doc-c-s-tax-nal-obj then bops_arh-fin-doc-c-s-tax-nal-obj.expense-vat else 0) + parsum-vat-doc
    bfps_arh-fin-doc-c-s-tax-nal-obj.expense-slt      = (if available bops_arh-fin-doc-c-s-tax-nal-obj then bops_arh-fin-doc-c-s-tax-nal-obj.expense-slt else 0) + parsum-slt-doc
  .
end.
else do:
  find first bfps_arh-fin-doc-c-s-tax-nal-obj where bfps_arh-fin-doc-c-s-tax-nal-obj.host-code        = parhost-code          and
                                                    bfps_arh-fin-doc-c-s-tax-nal-obj.obj-type         = parobj-type           and
                                                    bfps_arh-fin-doc-c-s-tax-nal-obj.obj-code         = parobj-code           and
                                                    bfps_arh-fin-doc-c-s-tax-nal-obj.cli-type         = parpayer-type         and
                                                    bfps_arh-fin-doc-c-s-tax-nal-obj.cli-code         = parpayer-code         and
                                                    bfps_arh-fin-doc-c-s-tax-nal-obj.contract-code    = parcontract-code      and
                                                    bfps_arh-fin-doc-c-s-tax-nal-obj.fin-code-acc     = parpayer-fin-code-acc and
                                                    bfps_arh-fin-doc-c-s-tax-nal-obj.curr-code        = parcurr-code          and
                                                    bfps_arh-fin-doc-c-s-tax-nal-obj.fin-ext-doc-type = parfin-ext-doc-type   and
                                                    bfps_arh-fin-doc-c-s-tax-nal-obj.calc-curr-code   = parcurr-code          and
                                                    bfps_arh-fin-doc-c-s-tax-nal-obj.vat-pc           = parvat-pc             and
                                                    bfps_arh-fin-doc-c-s-tax-nal-obj.slt-pc           = parslt-pc             and
                                                    bfps_arh-fin-doc-c-s-tax-nal-obj.with-vat         = parwith-vat           and
                                                    bfps_arh-fin-doc-c-s-tax-nal-obj.with-slt         = parwith-slt           and
                                                    bfps_arh-fin-doc-c-s-tax-nal-obj.sum-type         = parsum-type           and
                                                    bfps_arh-fin-doc-c-s-tax-nal-obj.fact-order       = parfact-order         exclusive-lock.
end.
for each rbfps_arh-fin-doc-c-s-tax-n-obj where rbfps_arh-fin-doc-c-s-tax-n-obj.host-code        = bfps_arh-fin-doc-c-s-tax-nal-obj.host-code        and
                                               rbfps_arh-fin-doc-c-s-tax-n-obj.obj-type         = bfps_arh-fin-doc-c-s-tax-nal-obj.obj-type         and
                                               rbfps_arh-fin-doc-c-s-tax-n-obj.obj-code         = bfps_arh-fin-doc-c-s-tax-nal-obj.obj-code         and
                                               rbfps_arh-fin-doc-c-s-tax-n-obj.cli-type         = parpayer-type                                     and
                                               rbfps_arh-fin-doc-c-s-tax-n-obj.cli-code         = parpayer-code                                     and
                                               rbfps_arh-fin-doc-c-s-tax-n-obj.contract-code    = bfps_arh-fin-doc-c-s-tax-nal-obj.contract-code    and
                                               rbfps_arh-fin-doc-c-s-tax-n-obj.fin-code-acc     = bfps_arh-fin-doc-c-s-tax-nal-obj.fin-code-acc     and
                                               rbfps_arh-fin-doc-c-s-tax-n-obj.curr-code        = bfps_arh-fin-doc-c-s-tax-nal-obj.curr-code        and
                                               rbfps_arh-fin-doc-c-s-tax-n-obj.fin-ext-doc-type = bfps_arh-fin-doc-c-s-tax-nal-obj.fin-ext-doc-type and
                                               rbfps_arh-fin-doc-c-s-tax-n-obj.calc-curr-code   = bfps_arh-fin-doc-c-s-tax-nal-obj.calc-curr-code   and
                                               rbfps_arh-fin-doc-c-s-tax-n-obj.vat-pc           = bfps_arh-fin-doc-c-s-tax-nal-obj.vat-pc           and
                                               rbfps_arh-fin-doc-c-s-tax-n-obj.slt-pc           = bfps_arh-fin-doc-c-s-tax-nal-obj.slt-pc           and
                                               rbfps_arh-fin-doc-c-s-tax-n-obj.with-vat         = bfps_arh-fin-doc-c-s-tax-nal-obj.with-vat         and
                                               rbfps_arh-fin-doc-c-s-tax-n-obj.with-slt         = bfps_arh-fin-doc-c-s-tax-nal-obj.with-slt         and
                                               rbfps_arh-fin-doc-c-s-tax-n-obj.sum-type         = bfps_arh-fin-doc-c-s-tax-nal-obj.sum-type         and
                                               rbfps_arh-fin-doc-c-s-tax-n-obj.fact-order       > bfps_arh-fin-doc-c-s-tax-nal-obj.fact-order       use-index pi exclusive-lock on error undo, return error return-value :
  assign
    rbfps_arh-fin-doc-c-s-tax-n-obj.expense     = rbfps_arh-fin-doc-c-s-tax-n-obj.expense     + parsum-doc
    rbfps_arh-fin-doc-c-s-tax-n-obj.expense-vat = rbfps_arh-fin-doc-c-s-tax-n-obj.expense-vat + parsum-vat-doc
    rbfps_arh-fin-doc-c-s-tax-n-obj.expense-slt = rbfps_arh-fin-doc-c-s-tax-n-obj.expense-slt + parsum-slt-doc
  .
end.
if parmode = "close":u then do:
  find last bors_arh-fin-doc-c-s-tax-nal-obj where bors_arh-fin-doc-c-s-tax-nal-obj.host-code         = parhost-code             and
                                                   bors_arh-fin-doc-c-s-tax-nal-obj.obj-type          = parobj-type              and
                                                   bors_arh-fin-doc-c-s-tax-nal-obj.obj-code          = parobj-code              and
                                                   bors_arh-fin-doc-c-s-tax-nal-obj.cli-type          = parreceiver-type         and
                                                   bors_arh-fin-doc-c-s-tax-nal-obj.cli-code          = parreceiver-code         and
                                                   bors_arh-fin-doc-c-s-tax-nal-obj.contract-code     = parcontract-code         and
                                                   bors_arh-fin-doc-c-s-tax-nal-obj.fin-code-acc      = parreceiver-fin-code-acc and
                                                   bors_arh-fin-doc-c-s-tax-nal-obj.curr-code         = parcurr-code             and
                                                   bors_arh-fin-doc-c-s-tax-nal-obj.fin-ext-doc-type  = parfin-ext-doc-type      and
                                                   bors_arh-fin-doc-c-s-tax-nal-obj.calc-curr-code    = parcurr-code             and
                                                   bors_arh-fin-doc-c-s-tax-nal-obj.vat-pc            = parvat-pc                and
                                                   bors_arh-fin-doc-c-s-tax-nal-obj.slt-pc            = parslt-pc                and
                                                   bors_arh-fin-doc-c-s-tax-nal-obj.with-vat          = parwith-vat              and
                                                   bors_arh-fin-doc-c-s-tax-nal-obj.with-slt          = parwith-slt              and
                                                   bors_arh-fin-doc-c-s-tax-nal-obj.sum-type          = parsum-type              and
                                                   bors_arh-fin-doc-c-s-tax-nal-obj.fact-order        < parfact-order            no-error.
  create bfrs_arh-fin-doc-c-s-tax-nal-obj.
  assign
    bfrs_arh-fin-doc-c-s-tax-nal-obj.host-code        = parhost-code
    bfrs_arh-fin-doc-c-s-tax-nal-obj.obj-type         = parobj-type
    bfrs_arh-fin-doc-c-s-tax-nal-obj.obj-code         = parobj-code
    bfrs_arh-fin-doc-c-s-tax-nal-obj.cli-type         = parreceiver-type
    bfrs_arh-fin-doc-c-s-tax-nal-obj.cli-code         = parreceiver-code
    bfrs_arh-fin-doc-c-s-tax-nal-obj.contract-code    = parcontract-code
    bfrs_arh-fin-doc-c-s-tax-nal-obj.fin-code-acc     = parreceiver-fin-code-acc
    bfrs_arh-fin-doc-c-s-tax-nal-obj.curr-code        = parcurr-code
    bfrs_arh-fin-doc-c-s-tax-nal-obj.fin-ext-doc-type = parfin-ext-doc-type
    bfrs_arh-fin-doc-c-s-tax-nal-obj.calc-curr-code   = parcurr-code
    bfrs_arh-fin-doc-c-s-tax-nal-obj.vat-pc           = parvat-pc
    bfrs_arh-fin-doc-c-s-tax-nal-obj.slt-pc           = parslt-pc
    bfrs_arh-fin-doc-c-s-tax-nal-obj.with-vat         = parwith-vat
    bfrs_arh-fin-doc-c-s-tax-nal-obj.with-slt         = parwith-slt
    bfrs_arh-fin-doc-c-s-tax-nal-obj.sum-type         = parsum-type
    bfrs_arh-fin-doc-c-s-tax-nal-obj.cource-des       = "s":u
    bfrs_arh-fin-doc-c-s-tax-nal-obj.fact-order       = parfact-order
    bfrs_arh-fin-doc-c-s-tax-nal-obj.fin-doc-code     = parfin-doc-code
    bfrs_arh-fin-doc-c-s-tax-nal-obj.fact-date        = parfact-date
    bfrs_arh-fin-doc-c-s-tax-nal-obj.curr-code        = parcurr-code
  .
  assign
    bfrs_arh-fin-doc-c-s-tax-nal-obj.expense          = (if available bors_arh-fin-doc-c-s-tax-nal-obj then bors_arh-fin-doc-c-s-tax-nal-obj.expense     else 0)
    bfrs_arh-fin-doc-c-s-tax-nal-obj.expense-vat      = (if available bors_arh-fin-doc-c-s-tax-nal-obj then bors_arh-fin-doc-c-s-tax-nal-obj.expense-vat else 0)
    bfrs_arh-fin-doc-c-s-tax-nal-obj.expense-slt      = (if available bors_arh-fin-doc-c-s-tax-nal-obj then bors_arh-fin-doc-c-s-tax-nal-obj.expense-slt else 0)
    bfrs_arh-fin-doc-c-s-tax-nal-obj.income           = (if available bors_arh-fin-doc-c-s-tax-nal-obj then bors_arh-fin-doc-c-s-tax-nal-obj.income      else 0) + parsum-doc
    bfrs_arh-fin-doc-c-s-tax-nal-obj.income-vat       = (if available bors_arh-fin-doc-c-s-tax-nal-obj then bors_arh-fin-doc-c-s-tax-nal-obj.income-vat  else 0) + parsum-vat-doc
    bfrs_arh-fin-doc-c-s-tax-nal-obj.income-slt       = (if available bors_arh-fin-doc-c-s-tax-nal-obj then bors_arh-fin-doc-c-s-tax-nal-obj.income-slt  else 0) + parsum-slt-doc
  .
end.
else do:
  find first bfrs_arh-fin-doc-c-s-tax-nal-obj where bfrs_arh-fin-doc-c-s-tax-nal-obj.host-code         = parhost-code             and
                                                    bfrs_arh-fin-doc-c-s-tax-nal-obj.obj-type          = parobj-type              and
                                                    bfrs_arh-fin-doc-c-s-tax-nal-obj.obj-code          = parobj-code              and
                                                    bfrs_arh-fin-doc-c-s-tax-nal-obj.cli-type          = parreceiver-type         and
                                                    bfrs_arh-fin-doc-c-s-tax-nal-obj.cli-code          = parreceiver-code         and
                                                    bfrs_arh-fin-doc-c-s-tax-nal-obj.contract-code     = parcontract-code         and
                                                    bfrs_arh-fin-doc-c-s-tax-nal-obj.fin-code-acc      = parreceiver-fin-code-acc and
                                                    bfrs_arh-fin-doc-c-s-tax-nal-obj.curr-code         = parcurr-code             and
                                                    bfrs_arh-fin-doc-c-s-tax-nal-obj.fin-ext-doc-type  = parfin-ext-doc-type      and
                                                    bfrs_arh-fin-doc-c-s-tax-nal-obj.calc-curr-code    = parcurr-code             and
                                                    bfrs_arh-fin-doc-c-s-tax-nal-obj.vat-pc            = parvat-pc                and
                                                    bfrs_arh-fin-doc-c-s-tax-nal-obj.slt-pc            = parslt-pc                and
                                                    bfrs_arh-fin-doc-c-s-tax-nal-obj.with-vat          = parwith-vat              and
                                                    bfrs_arh-fin-doc-c-s-tax-nal-obj.with-slt          = parwith-slt              and
                                                    bfrs_arh-fin-doc-c-s-tax-nal-obj.sum-type          = parsum-type              and
                                                    bfrs_arh-fin-doc-c-s-tax-nal-obj.fact-order        = parfact-order            exclusive-lock.
end.
for each rbfrs_arh-fin-doc-c-s-tax-n-obj where rbfrs_arh-fin-doc-c-s-tax-n-obj.host-code        = bfrs_arh-fin-doc-c-s-tax-nal-obj.host-code        and
                                               rbfrs_arh-fin-doc-c-s-tax-n-obj.obj-type         = bfrs_arh-fin-doc-c-s-tax-nal-obj.obj-type         and
                                               rbfrs_arh-fin-doc-c-s-tax-n-obj.obj-code         = bfrs_arh-fin-doc-c-s-tax-nal-obj.obj-code         and
                                               rbfrs_arh-fin-doc-c-s-tax-n-obj.cli-type         = parreceiver-type                                  and
                                               rbfrs_arh-fin-doc-c-s-tax-n-obj.cli-code         = parreceiver-code                                  and
                                               rbfrs_arh-fin-doc-c-s-tax-n-obj.contract-code    = bfrs_arh-fin-doc-c-s-tax-nal-obj.contract-code    and
                                               rbfrs_arh-fin-doc-c-s-tax-n-obj.fin-code-acc     = bfrs_arh-fin-doc-c-s-tax-nal-obj.fin-code-acc     and
                                               rbfrs_arh-fin-doc-c-s-tax-n-obj.curr-code        = bfrs_arh-fin-doc-c-s-tax-nal-obj.curr-code        and
                                               rbfrs_arh-fin-doc-c-s-tax-n-obj.fin-ext-doc-type = bfrs_arh-fin-doc-c-s-tax-nal-obj.fin-ext-doc-type and
                                               rbfrs_arh-fin-doc-c-s-tax-n-obj.calc-curr-code   = bfrs_arh-fin-doc-c-s-tax-nal-obj.calc-curr-code   and
                                               rbfrs_arh-fin-doc-c-s-tax-n-obj.vat-pc           = bfrs_arh-fin-doc-c-s-tax-nal-obj.vat-pc           and
                                               rbfrs_arh-fin-doc-c-s-tax-n-obj.slt-pc           = bfrs_arh-fin-doc-c-s-tax-nal-obj.slt-pc           and
                                               rbfrs_arh-fin-doc-c-s-tax-n-obj.with-vat         = bfrs_arh-fin-doc-c-s-tax-nal-obj.with-vat         and
                                               rbfrs_arh-fin-doc-c-s-tax-n-obj.with-slt         = bfrs_arh-fin-doc-c-s-tax-nal-obj.with-slt         and
                                               rbfrs_arh-fin-doc-c-s-tax-n-obj.sum-type         = bfrs_arh-fin-doc-c-s-tax-nal-obj.sum-type         and
                                               rbfrs_arh-fin-doc-c-s-tax-n-obj.fact-order       > bfrs_arh-fin-doc-c-s-tax-nal-obj.fact-order       use-index pi exclusive-lock on error undo, return error return-value :
  assign
    rbfrs_arh-fin-doc-c-s-tax-n-obj.income     = rbfrs_arh-fin-doc-c-s-tax-n-obj.income     + parsum-doc
    rbfrs_arh-fin-doc-c-s-tax-n-obj.income-vat = rbfrs_arh-fin-doc-c-s-tax-n-obj.income-vat + parsum-vat-doc
    rbfrs_arh-fin-doc-c-s-tax-n-obj.income-slt = rbfrs_arh-fin-doc-c-s-tax-n-obj.income-slt + parsum-slt-doc
  .
end.
if parmode = "delete":u then do:
  delete bfps_arh-fin-doc-c-s-tax-nal-obj.
  delete bfrs_arh-fin-doc-c-s-tax-nal-obj.
end.
if parcurr-code <> 0 then do:
  if parmode = "close":u then do:
    find last bopr_arh-fin-doc-c-s-tax-nal-obj where bopr_arh-fin-doc-c-s-tax-nal-obj.host-code        = parhost-code          and
                                                     bopr_arh-fin-doc-c-s-tax-nal-obj.obj-type         = parobj-type           and
                                                     bopr_arh-fin-doc-c-s-tax-nal-obj.obj-code         = parobj-code           and
                                                     bopr_arh-fin-doc-c-s-tax-nal-obj.cli-type         = parpayer-type         and
                                                     bopr_arh-fin-doc-c-s-tax-nal-obj.cli-code         = parpayer-code         and
                                                     bopr_arh-fin-doc-c-s-tax-nal-obj.contract-code    = parcontract-code      and
                                                     bopr_arh-fin-doc-c-s-tax-nal-obj.fin-code-acc     = parpayer-fin-code-acc and
                                                     bopr_arh-fin-doc-c-s-tax-nal-obj.curr-code        = parcurr-code          and
                                                     bopr_arh-fin-doc-c-s-tax-nal-obj.fin-ext-doc-type = parfin-ext-doc-type   and
                                                     bopr_arh-fin-doc-c-s-tax-nal-obj.calc-curr-code   = 0                     and
                                                     bopr_arh-fin-doc-c-s-tax-nal-obj.vat-pc           = parvat-pc             and
                                                     bopr_arh-fin-doc-c-s-tax-nal-obj.slt-pc           = parslt-pc             and
                                                     bopr_arh-fin-doc-c-s-tax-nal-obj.with-vat         = parwith-vat           and
                                                     bopr_arh-fin-doc-c-s-tax-nal-obj.with-slt         = parwith-slt           and
                                                     bopr_arh-fin-doc-c-s-tax-nal-obj.sum-type         = parsum-type           and
                                                     bopr_arh-fin-doc-c-s-tax-nal-obj.fact-order       < parfact-order         no-error.
    create bfpr_arh-fin-doc-c-s-tax-nal-obj.
    assign
      bfpr_arh-fin-doc-c-s-tax-nal-obj.host-code        = parhost-code
      bfpr_arh-fin-doc-c-s-tax-nal-obj.obj-type         = parobj-type
      bfpr_arh-fin-doc-c-s-tax-nal-obj.obj-code         = parobj-code
      bfpr_arh-fin-doc-c-s-tax-nal-obj.cli-type         = parpayer-type
      bfpr_arh-fin-doc-c-s-tax-nal-obj.cli-code         = parpayer-code
      bfpr_arh-fin-doc-c-s-tax-nal-obj.contract-code    = parcontract-code
      bfpr_arh-fin-doc-c-s-tax-nal-obj.fin-code-acc     = parpayer-fin-code-acc
      bfpr_arh-fin-doc-c-s-tax-nal-obj.curr-code        = parcurr-code
      bfpr_arh-fin-doc-c-s-tax-nal-obj.fin-ext-doc-type = parfin-ext-doc-type
      bfpr_arh-fin-doc-c-s-tax-nal-obj.calc-curr-code   = 0
      bfpr_arh-fin-doc-c-s-tax-nal-obj.vat-pc           = parvat-pc
      bfpr_arh-fin-doc-c-s-tax-nal-obj.slt-pc           = parslt-pc
      bfpr_arh-fin-doc-c-s-tax-nal-obj.with-vat         = parwith-vat
      bfpr_arh-fin-doc-c-s-tax-nal-obj.with-slt         = parwith-slt
      bfpr_arh-fin-doc-c-s-tax-nal-obj.sum-type         = parsum-type
      bfpr_arh-fin-doc-c-s-tax-nal-obj.cource-des       = "r":u
      bfpr_arh-fin-doc-c-s-tax-nal-obj.fact-order       = parfact-order
      bfpr_arh-fin-doc-c-s-tax-nal-obj.fin-doc-code     = parfin-doc-code
      bfpr_arh-fin-doc-c-s-tax-nal-obj.fact-date        = parfact-date
      bfpr_arh-fin-doc-c-s-tax-nal-obj.curr-code        = parcurr-code
      bfpr_arh-fin-doc-c-s-tax-nal-obj.income           = (if available bopr_arh-fin-doc-c-s-tax-nal-obj then bopr_arh-fin-doc-c-s-tax-nal-obj.income      else 0)
      bfpr_arh-fin-doc-c-s-tax-nal-obj.income-vat       = (if available bopr_arh-fin-doc-c-s-tax-nal-obj then bopr_arh-fin-doc-c-s-tax-nal-obj.income-vat  else 0)
      bfpr_arh-fin-doc-c-s-tax-nal-obj.income-slt       = (if available bopr_arh-fin-doc-c-s-tax-nal-obj then bopr_arh-fin-doc-c-s-tax-nal-obj.income-slt  else 0)
      bfpr_arh-fin-doc-c-s-tax-nal-obj.expense          = (if available bopr_arh-fin-doc-c-s-tax-nal-obj then bopr_arh-fin-doc-c-s-tax-nal-obj.expense     else 0) + parsum-rubl
      bfpr_arh-fin-doc-c-s-tax-nal-obj.expense-vat      = (if available bopr_arh-fin-doc-c-s-tax-nal-obj then bopr_arh-fin-doc-c-s-tax-nal-obj.expense-vat else 0) + parsum-vat-rubl
      bfpr_arh-fin-doc-c-s-tax-nal-obj.expense-slt      = (if available bopr_arh-fin-doc-c-s-tax-nal-obj then bopr_arh-fin-doc-c-s-tax-nal-obj.expense-slt else 0) + parsum-slt-rubl
    .
  end.
  else do:
    find first bfpr_arh-fin-doc-c-s-tax-nal-obj where bfpr_arh-fin-doc-c-s-tax-nal-obj.host-code        = parhost-code          and
                                                      bfpr_arh-fin-doc-c-s-tax-nal-obj.obj-type         = parobj-type           and
                                                      bfpr_arh-fin-doc-c-s-tax-nal-obj.obj-code         = parobj-code           and
                                                      bfpr_arh-fin-doc-c-s-tax-nal-obj.cli-type         = parpayer-type         and
                                                      bfpr_arh-fin-doc-c-s-tax-nal-obj.cli-code         = parpayer-code         and
                                                      bfpr_arh-fin-doc-c-s-tax-nal-obj.contract-code    = parcontract-code      and
                                                      bfpr_arh-fin-doc-c-s-tax-nal-obj.fin-code-acc     = parpayer-fin-code-acc and
                                                      bfpr_arh-fin-doc-c-s-tax-nal-obj.curr-code        = parcurr-code          and
                                                      bfpr_arh-fin-doc-c-s-tax-nal-obj.fin-ext-doc-type = parfin-ext-doc-type   and
                                                      bfpr_arh-fin-doc-c-s-tax-nal-obj.calc-curr-code   = 0                     and
                                                      bfpr_arh-fin-doc-c-s-tax-nal-obj.vat-pc           = parvat-pc             and
                                                      bfpr_arh-fin-doc-c-s-tax-nal-obj.slt-pc           = parslt-pc             and
                                                      bfpr_arh-fin-doc-c-s-tax-nal-obj.with-vat         = parwith-vat           and
                                                      bfpr_arh-fin-doc-c-s-tax-nal-obj.with-slt         = parwith-slt           and
                                                      bfpr_arh-fin-doc-c-s-tax-nal-obj.sum-type         = parsum-type           and
                                                      bfpr_arh-fin-doc-c-s-tax-nal-obj.fact-order       = parfact-order         exclusive-lock.
  end.
  for each rbfpr_arh-fin-doc-c-s-tax-n-obj where rbfpr_arh-fin-doc-c-s-tax-n-obj.host-code        = bfpr_arh-fin-doc-c-s-tax-nal-obj.host-code        and
                                                 rbfpr_arh-fin-doc-c-s-tax-n-obj.obj-type         = bfpr_arh-fin-doc-c-s-tax-nal-obj.obj-type         and
                                                 rbfpr_arh-fin-doc-c-s-tax-n-obj.obj-code         = bfpr_arh-fin-doc-c-s-tax-nal-obj.obj-code         and
                                                 rbfpr_arh-fin-doc-c-s-tax-n-obj.cli-type         = parpayer-type                                     and
                                                 rbfpr_arh-fin-doc-c-s-tax-n-obj.cli-code         = parpayer-code                                     and
                                                 rbfpr_arh-fin-doc-c-s-tax-n-obj.contract-code    = bfpr_arh-fin-doc-c-s-tax-nal-obj.contract-code    and
                                                 rbfpr_arh-fin-doc-c-s-tax-n-obj.fin-code-acc     = bfpr_arh-fin-doc-c-s-tax-nal-obj.fin-code-acc     and
                                                 rbfpr_arh-fin-doc-c-s-tax-n-obj.curr-code        = bfpr_arh-fin-doc-c-s-tax-nal-obj.curr-code        and
                                                 rbfpr_arh-fin-doc-c-s-tax-n-obj.fin-ext-doc-type = bfpr_arh-fin-doc-c-s-tax-nal-obj.fin-ext-doc-type and
                                                 rbfpr_arh-fin-doc-c-s-tax-n-obj.calc-curr-code   = bfpr_arh-fin-doc-c-s-tax-nal-obj.calc-curr-code   and
                                                 rbfpr_arh-fin-doc-c-s-tax-n-obj.vat-pc           = bfpr_arh-fin-doc-c-s-tax-nal-obj.vat-pc           and
                                                 rbfpr_arh-fin-doc-c-s-tax-n-obj.slt-pc           = bfpr_arh-fin-doc-c-s-tax-nal-obj.slt-pc           and
                                                 rbfpr_arh-fin-doc-c-s-tax-n-obj.with-vat         = bfpr_arh-fin-doc-c-s-tax-nal-obj.with-vat         and
                                                 rbfpr_arh-fin-doc-c-s-tax-n-obj.with-slt         = bfpr_arh-fin-doc-c-s-tax-nal-obj.with-slt         and
                                                 rbfpr_arh-fin-doc-c-s-tax-n-obj.sum-type         = bfpr_arh-fin-doc-c-s-tax-nal-obj.sum-type         and
                                                 rbfpr_arh-fin-doc-c-s-tax-n-obj.fact-order       > bfpr_arh-fin-doc-c-s-tax-nal-obj.fact-order       use-index pi exclusive-lock on error undo, return error return-value :
    assign
      rbfpr_arh-fin-doc-c-s-tax-n-obj.expense     = rbfpr_arh-fin-doc-c-s-tax-n-obj.expense     + parsum-rubl
      rbfpr_arh-fin-doc-c-s-tax-n-obj.expense-vat = rbfpr_arh-fin-doc-c-s-tax-n-obj.expense-vat + parsum-vat-rubl
      rbfpr_arh-fin-doc-c-s-tax-n-obj.expense-slt = rbfpr_arh-fin-doc-c-s-tax-n-obj.expense-slt + parsum-slt-rubl
    .
  end.
  if parmode = "close":u then do:
    find last borr_arh-fin-doc-c-s-tax-nal-obj where borr_arh-fin-doc-c-s-tax-nal-obj.host-code        = parhost-code             and
                                                     borr_arh-fin-doc-c-s-tax-nal-obj.obj-type         = parobj-type              and
                                                     borr_arh-fin-doc-c-s-tax-nal-obj.obj-code         = parobj-code              and
                                                     borr_arh-fin-doc-c-s-tax-nal-obj.cli-type         = parreceiver-type         and
                                                     borr_arh-fin-doc-c-s-tax-nal-obj.cli-code         = parreceiver-code         and
                                                     borr_arh-fin-doc-c-s-tax-nal-obj.contract-code    = parcontract-code         and
                                                     borr_arh-fin-doc-c-s-tax-nal-obj.fin-code-acc     = parreceiver-fin-code-acc and
                                                     borr_arh-fin-doc-c-s-tax-nal-obj.curr-code        = parcurr-code             and
                                                     borr_arh-fin-doc-c-s-tax-nal-obj.fin-ext-doc-type = parfin-ext-doc-type      and
                                                     borr_arh-fin-doc-c-s-tax-nal-obj.calc-curr-code   = 0                        and
                                                     borr_arh-fin-doc-c-s-tax-nal-obj.vat-pc           = parvat-pc                and
                                                     borr_arh-fin-doc-c-s-tax-nal-obj.slt-pc           = parslt-pc                and
                                                     borr_arh-fin-doc-c-s-tax-nal-obj.with-vat         = parwith-vat              and
                                                     borr_arh-fin-doc-c-s-tax-nal-obj.with-slt         = parwith-slt              and
                                                     borr_arh-fin-doc-c-s-tax-nal-obj.sum-type         = parsum-type              and
                                                     borr_arh-fin-doc-c-s-tax-nal-obj.fact-order       < parfact-order            no-error.
    create bfrr_arh-fin-doc-c-s-tax-nal-obj.
    assign
      bfrr_arh-fin-doc-c-s-tax-nal-obj.host-code        = parhost-code
      bfrr_arh-fin-doc-c-s-tax-nal-obj.obj-type         = parobj-type
      bfrr_arh-fin-doc-c-s-tax-nal-obj.obj-code         = parobj-code
      bfrr_arh-fin-doc-c-s-tax-nal-obj.cli-type         = parreceiver-type
      bfrr_arh-fin-doc-c-s-tax-nal-obj.cli-code         = parreceiver-code
      bfrr_arh-fin-doc-c-s-tax-nal-obj.contract-code    = parcontract-code
      bfrr_arh-fin-doc-c-s-tax-nal-obj.fin-code-acc     = parreceiver-fin-code-acc
      bfrr_arh-fin-doc-c-s-tax-nal-obj.curr-code        = parcurr-code
      bfrr_arh-fin-doc-c-s-tax-nal-obj.fin-ext-doc-type = parfin-ext-doc-type
      bfrr_arh-fin-doc-c-s-tax-nal-obj.calc-curr-code   = 0
      bfrr_arh-fin-doc-c-s-tax-nal-obj.vat-pc           = parvat-pc
      bfrr_arh-fin-doc-c-s-tax-nal-obj.slt-pc           = parslt-pc
      bfrr_arh-fin-doc-c-s-tax-nal-obj.with-vat         = parwith-vat
      bfrr_arh-fin-doc-c-s-tax-nal-obj.with-slt         = parwith-slt
      bfrr_arh-fin-doc-c-s-tax-nal-obj.sum-type         = parsum-type
      bfrr_arh-fin-doc-c-s-tax-nal-obj.cource-des       = "r":u
      bfrr_arh-fin-doc-c-s-tax-nal-obj.fact-order       = parfact-order
      bfrr_arh-fin-doc-c-s-tax-nal-obj.fin-doc-code     = parfin-doc-code
      bfrr_arh-fin-doc-c-s-tax-nal-obj.fact-date        = parfact-date
      bfrr_arh-fin-doc-c-s-tax-nal-obj.curr-code        = parcurr-code
    .
    assign
      bfrr_arh-fin-doc-c-s-tax-nal-obj.expense          = (if available borr_arh-fin-doc-c-s-tax-nal-obj then borr_arh-fin-doc-c-s-tax-nal-obj.expense     else 0)
      bfrr_arh-fin-doc-c-s-tax-nal-obj.expense-vat      = (if available borr_arh-fin-doc-c-s-tax-nal-obj then borr_arh-fin-doc-c-s-tax-nal-obj.expense-vat else 0)
      bfrr_arh-fin-doc-c-s-tax-nal-obj.expense-slt      = (if available borr_arh-fin-doc-c-s-tax-nal-obj then borr_arh-fin-doc-c-s-tax-nal-obj.expense-slt else 0)
      bfrr_arh-fin-doc-c-s-tax-nal-obj.income           = (if available borr_arh-fin-doc-c-s-tax-nal-obj then borr_arh-fin-doc-c-s-tax-nal-obj.income      else 0) + parsum-rubl
      bfrr_arh-fin-doc-c-s-tax-nal-obj.income-vat       = (if available borr_arh-fin-doc-c-s-tax-nal-obj then borr_arh-fin-doc-c-s-tax-nal-obj.income-vat  else 0) + parsum-vat-rubl
      bfrr_arh-fin-doc-c-s-tax-nal-obj.income-slt       = (if available borr_arh-fin-doc-c-s-tax-nal-obj then borr_arh-fin-doc-c-s-tax-nal-obj.income-slt  else 0) + parsum-slt-rubl
    .
  end.
  else do:
    find first bfrr_arh-fin-doc-c-s-tax-nal-obj where bfrr_arh-fin-doc-c-s-tax-nal-obj.host-code        = parhost-code             and
                                                      bfrr_arh-fin-doc-c-s-tax-nal-obj.obj-type         = parobj-type              and
                                                      bfrr_arh-fin-doc-c-s-tax-nal-obj.obj-code         = parobj-code              and
                                                      bfrr_arh-fin-doc-c-s-tax-nal-obj.cli-type         = parreceiver-type         and
                                                      bfrr_arh-fin-doc-c-s-tax-nal-obj.cli-code         = parreceiver-code         and
                                                      bfrr_arh-fin-doc-c-s-tax-nal-obj.contract-code    = parcontract-code         and
                                                      bfrr_arh-fin-doc-c-s-tax-nal-obj.fin-code-acc     = parreceiver-fin-code-acc and
                                                      bfrr_arh-fin-doc-c-s-tax-nal-obj.curr-code        = parcurr-code             and
                                                      bfrr_arh-fin-doc-c-s-tax-nal-obj.fin-ext-doc-type = parfin-ext-doc-type      and
                                                      bfrr_arh-fin-doc-c-s-tax-nal-obj.calc-curr-code   = 0                        and
                                                      bfrr_arh-fin-doc-c-s-tax-nal-obj.vat-pc           = parvat-pc                and
                                                      bfrr_arh-fin-doc-c-s-tax-nal-obj.slt-pc           = parslt-pc                and
                                                      bfrr_arh-fin-doc-c-s-tax-nal-obj.with-vat         = parwith-vat              and
                                                      bfrr_arh-fin-doc-c-s-tax-nal-obj.with-slt         = parwith-slt              and
                                                      bfrr_arh-fin-doc-c-s-tax-nal-obj.sum-type         = parsum-type              and
                                                      bfrr_arh-fin-doc-c-s-tax-nal-obj.fact-order       = parfact-order            exclusive-lock.
  end.
  for each rbfrr_arh-fin-doc-c-s-tax-n-obj where rbfrr_arh-fin-doc-c-s-tax-n-obj.host-code        = bfrr_arh-fin-doc-c-s-tax-nal-obj.host-code        and
                                                 rbfrr_arh-fin-doc-c-s-tax-n-obj.obj-type         = bfrr_arh-fin-doc-c-s-tax-nal-obj.obj-type         and
                                                 rbfrr_arh-fin-doc-c-s-tax-n-obj.obj-code         = bfrr_arh-fin-doc-c-s-tax-nal-obj.obj-code         and
                                                 rbfrr_arh-fin-doc-c-s-tax-n-obj.cli-type         = parreceiver-type                                  and
                                                 rbfrr_arh-fin-doc-c-s-tax-n-obj.cli-code         = parreceiver-code                                  and
                                                 rbfrr_arh-fin-doc-c-s-tax-n-obj.contract-code    = bfrr_arh-fin-doc-c-s-tax-nal-obj.contract-code    and
                                                 rbfrr_arh-fin-doc-c-s-tax-n-obj.fin-code-acc     = bfrr_arh-fin-doc-c-s-tax-nal-obj.fin-code-acc     and
                                                 rbfrr_arh-fin-doc-c-s-tax-n-obj.curr-code        = bfrr_arh-fin-doc-c-s-tax-nal-obj.curr-code        and
                                                 rbfrr_arh-fin-doc-c-s-tax-n-obj.fin-ext-doc-type = bfrr_arh-fin-doc-c-s-tax-nal-obj.fin-ext-doc-type and
                                                 rbfrr_arh-fin-doc-c-s-tax-n-obj.calc-curr-code   = bfrr_arh-fin-doc-c-s-tax-nal-obj.calc-curr-code   and
                                                 rbfrr_arh-fin-doc-c-s-tax-n-obj.vat-pc           = bfrr_arh-fin-doc-c-s-tax-nal-obj.vat-pc           and
                                                 rbfrr_arh-fin-doc-c-s-tax-n-obj.slt-pc           = bfrr_arh-fin-doc-c-s-tax-nal-obj.slt-pc           and
                                                 rbfrr_arh-fin-doc-c-s-tax-n-obj.with-vat         = bfrr_arh-fin-doc-c-s-tax-nal-obj.with-vat         and
                                                 rbfrr_arh-fin-doc-c-s-tax-n-obj.with-slt         = bfrr_arh-fin-doc-c-s-tax-nal-obj.with-slt         and
                                                 rbfrr_arh-fin-doc-c-s-tax-n-obj.sum-type         = bfrr_arh-fin-doc-c-s-tax-nal-obj.sum-type         and
                                                 rbfrr_arh-fin-doc-c-s-tax-n-obj.fact-order       > bfrr_arh-fin-doc-c-s-tax-nal-obj.fact-order       use-index pi exclusive-lock on error undo, return error return-value :
    assign
      rbfrr_arh-fin-doc-c-s-tax-n-obj.income     = rbfrr_arh-fin-doc-c-s-tax-n-obj.income     + parsum-rubl
      rbfrr_arh-fin-doc-c-s-tax-n-obj.income-vat = rbfrr_arh-fin-doc-c-s-tax-n-obj.income-vat + parsum-vat-rubl
      rbfrr_arh-fin-doc-c-s-tax-n-obj.income-slt = rbfrr_arh-fin-doc-c-s-tax-n-obj.income-slt + parsum-slt-rubl
    .
  end.
  if parmode = "delete":u then do:
    delete bfpr_arh-fin-doc-c-s-tax-nal-obj.
    delete bfrr_arh-fin-doc-c-s-tax-nal-obj.
  end.
end.
if parbase-code <> parcurr-code and
   parbase-code <> 0            then do:
  if parmode = "close":u then do:
    find last bopb_arh-fin-doc-c-s-tax-nal-obj where bopb_arh-fin-doc-c-s-tax-nal-obj.host-code        = parhost-code          and
                                                     bopb_arh-fin-doc-c-s-tax-nal-obj.obj-type         = parobj-type           and
                                                     bopb_arh-fin-doc-c-s-tax-nal-obj.obj-code         = parobj-code           and
                                                     bopb_arh-fin-doc-c-s-tax-nal-obj.cli-type         = parpayer-type         and
                                                     bopb_arh-fin-doc-c-s-tax-nal-obj.cli-code         = parpayer-code         and
                                                     bopb_arh-fin-doc-c-s-tax-nal-obj.contract-code    = parcontract-code      and
                                                     bopb_arh-fin-doc-c-s-tax-nal-obj.fin-code-acc     = parpayer-fin-code-acc and
                                                     bopb_arh-fin-doc-c-s-tax-nal-obj.curr-code        = parcurr-code          and
                                                     bopb_arh-fin-doc-c-s-tax-nal-obj.fin-ext-doc-type = parfin-ext-doc-type   and
                                                     bopb_arh-fin-doc-c-s-tax-nal-obj.calc-curr-code   = parbase-code          and
                                                     bopb_arh-fin-doc-c-s-tax-nal-obj.vat-pc           = parvat-pc             and
                                                     bopb_arh-fin-doc-c-s-tax-nal-obj.slt-pc           = parslt-pc             and
                                                     bopb_arh-fin-doc-c-s-tax-nal-obj.with-vat         = parwith-vat           and
                                                     bopb_arh-fin-doc-c-s-tax-nal-obj.with-slt         = parwith-slt           and
                                                     bopb_arh-fin-doc-c-s-tax-nal-obj.sum-type         = parsum-type           and
                                                     bopb_arh-fin-doc-c-s-tax-nal-obj.fact-order       < parfact-order         no-error.
    create bfpb_arh-fin-doc-c-s-tax-nal-obj.
    assign
      bfpb_arh-fin-doc-c-s-tax-nal-obj.host-code        = parhost-code
      bfpb_arh-fin-doc-c-s-tax-nal-obj.obj-type         = parobj-type
      bfpb_arh-fin-doc-c-s-tax-nal-obj.obj-code         = parobj-code
      bfpb_arh-fin-doc-c-s-tax-nal-obj.cli-type         = parpayer-type
      bfpb_arh-fin-doc-c-s-tax-nal-obj.cli-code         = parpayer-code
      bfpb_arh-fin-doc-c-s-tax-nal-obj.contract-code    = parcontract-code
      bfpb_arh-fin-doc-c-s-tax-nal-obj.fin-code-acc     = parpayer-fin-code-acc
      bfpb_arh-fin-doc-c-s-tax-nal-obj.curr-code        = parcurr-code
      bfpb_arh-fin-doc-c-s-tax-nal-obj.fin-ext-doc-type = parfin-ext-doc-type
      bfpb_arh-fin-doc-c-s-tax-nal-obj.calc-curr-code   = parbase-code
      bfpb_arh-fin-doc-c-s-tax-nal-obj.vat-pc           = parvat-pc
      bfpb_arh-fin-doc-c-s-tax-nal-obj.slt-pc           = parslt-pc
      bfpb_arh-fin-doc-c-s-tax-nal-obj.with-vat         = parwith-vat
      bfpb_arh-fin-doc-c-s-tax-nal-obj.with-slt         = parwith-slt
      bfpb_arh-fin-doc-c-s-tax-nal-obj.sum-type         = parsum-type
      bfpb_arh-fin-doc-c-s-tax-nal-obj.cource-des       = "b":u
      bfpb_arh-fin-doc-c-s-tax-nal-obj.fact-order       = parfact-order
      bfpb_arh-fin-doc-c-s-tax-nal-obj.fin-doc-code     = parfin-doc-code
      bfpb_arh-fin-doc-c-s-tax-nal-obj.fact-date        = parfact-date
      bfpb_arh-fin-doc-c-s-tax-nal-obj.curr-code        = parcurr-code
      bfpb_arh-fin-doc-c-s-tax-nal-obj.income           = (if available bopb_arh-fin-doc-c-s-tax-nal-obj then bopb_arh-fin-doc-c-s-tax-nal-obj.income      else 0)
      bfpb_arh-fin-doc-c-s-tax-nal-obj.income-vat       = (if available bopb_arh-fin-doc-c-s-tax-nal-obj then bopb_arh-fin-doc-c-s-tax-nal-obj.income-vat  else 0)
      bfpb_arh-fin-doc-c-s-tax-nal-obj.income-slt       = (if available bopb_arh-fin-doc-c-s-tax-nal-obj then bopb_arh-fin-doc-c-s-tax-nal-obj.income-slt  else 0)
      bfpb_arh-fin-doc-c-s-tax-nal-obj.expense          = (if available bopb_arh-fin-doc-c-s-tax-nal-obj then bopb_arh-fin-doc-c-s-tax-nal-obj.expense     else 0) + parsum-base
      bfpb_arh-fin-doc-c-s-tax-nal-obj.expense-vat      = (if available bopb_arh-fin-doc-c-s-tax-nal-obj then bopb_arh-fin-doc-c-s-tax-nal-obj.expense-vat else 0) + parsum-vat-base
      bfpb_arh-fin-doc-c-s-tax-nal-obj.expense-slt      = (if available bopb_arh-fin-doc-c-s-tax-nal-obj then bopb_arh-fin-doc-c-s-tax-nal-obj.expense-slt else 0) + parsum-slt-base
    .
  end.
  else do:
    find first bfpb_arh-fin-doc-c-s-tax-nal-obj where bfpb_arh-fin-doc-c-s-tax-nal-obj.host-code        = parhost-code          and
                                                      bfpb_arh-fin-doc-c-s-tax-nal-obj.obj-type         = parobj-type           and
                                                      bfpb_arh-fin-doc-c-s-tax-nal-obj.obj-code         = parobj-code           and
                                                      bfpb_arh-fin-doc-c-s-tax-nal-obj.cli-type         = parpayer-type         and
                                                      bfpb_arh-fin-doc-c-s-tax-nal-obj.cli-code         = parpayer-code         and
                                                      bfpb_arh-fin-doc-c-s-tax-nal-obj.contract-code    = parcontract-code      and
                                                      bfpb_arh-fin-doc-c-s-tax-nal-obj.fin-code-acc     = parpayer-fin-code-acc and
                                                      bfpb_arh-fin-doc-c-s-tax-nal-obj.curr-code        = parcurr-code          and
                                                      bfpb_arh-fin-doc-c-s-tax-nal-obj.fin-ext-doc-type = parfin-ext-doc-type   and
                                                      bfpb_arh-fin-doc-c-s-tax-nal-obj.calc-curr-code   = parbase-code          and
                                                      bfpb_arh-fin-doc-c-s-tax-nal-obj.vat-pc           = parvat-pc             and
                                                      bfpb_arh-fin-doc-c-s-tax-nal-obj.slt-pc           = parslt-pc             and
                                                      bfpb_arh-fin-doc-c-s-tax-nal-obj.with-vat         = parwith-vat           and
                                                      bfpb_arh-fin-doc-c-s-tax-nal-obj.with-slt         = parwith-slt           and
                                                      bfpb_arh-fin-doc-c-s-tax-nal-obj.sum-type         = parsum-type           and
                                                      bfpb_arh-fin-doc-c-s-tax-nal-obj.fact-order       = parfact-order         exclusive-lock.
  end.
  for each rbfpb_arh-fin-doc-c-s-tax-n-obj where rbfpb_arh-fin-doc-c-s-tax-n-obj.host-code        = bfpb_arh-fin-doc-c-s-tax-nal-obj.host-code        and
                                                 rbfpb_arh-fin-doc-c-s-tax-n-obj.obj-type         = bfpb_arh-fin-doc-c-s-tax-nal-obj.obj-type         and
                                                 rbfpb_arh-fin-doc-c-s-tax-n-obj.obj-code         = bfpb_arh-fin-doc-c-s-tax-nal-obj.obj-code         and
                                                 rbfpb_arh-fin-doc-c-s-tax-n-obj.cli-type         = parpayer-type                                     and
                                                 rbfpb_arh-fin-doc-c-s-tax-n-obj.cli-code         = parpayer-code                                     and
                                                 rbfpb_arh-fin-doc-c-s-tax-n-obj.contract-code    = bfpb_arh-fin-doc-c-s-tax-nal-obj.contract-code    and
                                                 rbfpb_arh-fin-doc-c-s-tax-n-obj.fin-code-acc     = bfpb_arh-fin-doc-c-s-tax-nal-obj.fin-code-acc     and
                                                 rbfpb_arh-fin-doc-c-s-tax-n-obj.curr-code        = bfpb_arh-fin-doc-c-s-tax-nal-obj.curr-code        and
                                                 rbfpb_arh-fin-doc-c-s-tax-n-obj.fin-ext-doc-type = bfpb_arh-fin-doc-c-s-tax-nal-obj.fin-ext-doc-type and
                                                 rbfpb_arh-fin-doc-c-s-tax-n-obj.calc-curr-code   = bfpb_arh-fin-doc-c-s-tax-nal-obj.calc-curr-code   and
                                                 rbfpb_arh-fin-doc-c-s-tax-n-obj.vat-pc           = bfpb_arh-fin-doc-c-s-tax-nal-obj.vat-pc           and
                                                 rbfpb_arh-fin-doc-c-s-tax-n-obj.slt-pc           = bfpb_arh-fin-doc-c-s-tax-nal-obj.slt-pc           and
                                                 rbfpb_arh-fin-doc-c-s-tax-n-obj.with-vat         = bfpb_arh-fin-doc-c-s-tax-nal-obj.with-vat         and
                                                 rbfpb_arh-fin-doc-c-s-tax-n-obj.with-slt         = bfpb_arh-fin-doc-c-s-tax-nal-obj.with-slt         and
                                                 rbfpb_arh-fin-doc-c-s-tax-n-obj.sum-type         = bfpb_arh-fin-doc-c-s-tax-nal-obj.sum-type         and
                                                 rbfpb_arh-fin-doc-c-s-tax-n-obj.fact-order       > bfpb_arh-fin-doc-c-s-tax-nal-obj.fact-order       use-index pi exclusive-lock on error undo, return error return-value :
    assign
      rbfpb_arh-fin-doc-c-s-tax-n-obj.expense     = rbfpb_arh-fin-doc-c-s-tax-n-obj.expense     + parsum-base
      rbfpb_arh-fin-doc-c-s-tax-n-obj.expense-vat = rbfpb_arh-fin-doc-c-s-tax-n-obj.expense-vat + parsum-vat-base
      rbfpb_arh-fin-doc-c-s-tax-n-obj.expense-slt = rbfpb_arh-fin-doc-c-s-tax-n-obj.expense-slt + parsum-slt-base
    .
  end.
  if parmode = "close":u then do:
    find last borb_arh-fin-doc-c-s-tax-nal-obj where borb_arh-fin-doc-c-s-tax-nal-obj.host-code        = parhost-code             and
                                                     borb_arh-fin-doc-c-s-tax-nal-obj.obj-type         = parobj-type              and
                                                     borb_arh-fin-doc-c-s-tax-nal-obj.obj-code         = parobj-code              and
                                                     borb_arh-fin-doc-c-s-tax-nal-obj.cli-type         = parreceiver-type         and
                                                     borb_arh-fin-doc-c-s-tax-nal-obj.cli-code         = parreceiver-code         and
                                                     borb_arh-fin-doc-c-s-tax-nal-obj.contract-code    = parcontract-code         and
                                                     borb_arh-fin-doc-c-s-tax-nal-obj.fin-code-acc     = parreceiver-fin-code-acc and
                                                     borb_arh-fin-doc-c-s-tax-nal-obj.curr-code        = parcurr-code             and
                                                     borb_arh-fin-doc-c-s-tax-nal-obj.fin-ext-doc-type = parfin-ext-doc-type      and
                                                     borb_arh-fin-doc-c-s-tax-nal-obj.calc-curr-code   = parbase-code             and
                                                     borb_arh-fin-doc-c-s-tax-nal-obj.vat-pc           = parvat-pc                and
                                                     borb_arh-fin-doc-c-s-tax-nal-obj.slt-pc           = parslt-pc                and
                                                     borb_arh-fin-doc-c-s-tax-nal-obj.with-vat         = parwith-vat              and
                                                     borb_arh-fin-doc-c-s-tax-nal-obj.with-slt         = parwith-slt              and
                                                     borb_arh-fin-doc-c-s-tax-nal-obj.sum-type         = parsum-type              and
                                                     borb_arh-fin-doc-c-s-tax-nal-obj.fact-order       < parfact-order            no-error.
    create bfrb_arh-fin-doc-c-s-tax-nal-obj.
    assign
      bfrb_arh-fin-doc-c-s-tax-nal-obj.host-code        = parhost-code
      bfrb_arh-fin-doc-c-s-tax-nal-obj.obj-type         = parobj-type
      bfrb_arh-fin-doc-c-s-tax-nal-obj.obj-code         = parobj-code
      bfrb_arh-fin-doc-c-s-tax-nal-obj.cli-type         = parreceiver-type
      bfrb_arh-fin-doc-c-s-tax-nal-obj.cli-code         = parreceiver-code
      bfrb_arh-fin-doc-c-s-tax-nal-obj.contract-code    = parcontract-code
      bfrb_arh-fin-doc-c-s-tax-nal-obj.fin-code-acc     = parreceiver-fin-code-acc
      bfrb_arh-fin-doc-c-s-tax-nal-obj.curr-code        = parcurr-code
      bfrb_arh-fin-doc-c-s-tax-nal-obj.fin-ext-doc-type = parfin-ext-doc-type
      bfrb_arh-fin-doc-c-s-tax-nal-obj.calc-curr-code   = parbase-code
      bfrb_arh-fin-doc-c-s-tax-nal-obj.vat-pc           = parvat-pc
      bfrb_arh-fin-doc-c-s-tax-nal-obj.slt-pc           = parslt-pc
      bfrb_arh-fin-doc-c-s-tax-nal-obj.with-vat         = parwith-vat
      bfrb_arh-fin-doc-c-s-tax-nal-obj.with-slt         = parwith-slt
      bfrb_arh-fin-doc-c-s-tax-nal-obj.sum-type         = parsum-type
      bfrb_arh-fin-doc-c-s-tax-nal-obj.cource-des       = "b":u
      bfrb_arh-fin-doc-c-s-tax-nal-obj.fact-order       = parfact-order
      bfrb_arh-fin-doc-c-s-tax-nal-obj.fin-doc-code     = parfin-doc-code
      bfrb_arh-fin-doc-c-s-tax-nal-obj.fact-date        = parfact-date
      bfrb_arh-fin-doc-c-s-tax-nal-obj.curr-code        = parcurr-code
    .
    assign
      bfrb_arh-fin-doc-c-s-tax-nal-obj.expense          = (if available borb_arh-fin-doc-c-s-tax-nal-obj then borb_arh-fin-doc-c-s-tax-nal-obj.expense     else 0)
      bfrb_arh-fin-doc-c-s-tax-nal-obj.expense-vat      = (if available borb_arh-fin-doc-c-s-tax-nal-obj then borb_arh-fin-doc-c-s-tax-nal-obj.expense-vat else 0)
      bfrb_arh-fin-doc-c-s-tax-nal-obj.expense-slt      = (if available borb_arh-fin-doc-c-s-tax-nal-obj then borb_arh-fin-doc-c-s-tax-nal-obj.expense-slt else 0)
      bfrb_arh-fin-doc-c-s-tax-nal-obj.income           = (if available borb_arh-fin-doc-c-s-tax-nal-obj then borb_arh-fin-doc-c-s-tax-nal-obj.income      else 0) + parsum-base
      bfrb_arh-fin-doc-c-s-tax-nal-obj.income-vat       = (if available borb_arh-fin-doc-c-s-tax-nal-obj then borb_arh-fin-doc-c-s-tax-nal-obj.income-vat  else 0) + parsum-vat-base
      bfrb_arh-fin-doc-c-s-tax-nal-obj.income-slt       = (if available borb_arh-fin-doc-c-s-tax-nal-obj then borb_arh-fin-doc-c-s-tax-nal-obj.income-slt  else 0) + parsum-slt-base
    .
  end.
  else do:
    find first bfrb_arh-fin-doc-c-s-tax-nal-obj where bfrb_arh-fin-doc-c-s-tax-nal-obj.host-code        = parhost-code             and
                                                      bfrb_arh-fin-doc-c-s-tax-nal-obj.obj-type         = parobj-type              and
                                                      bfrb_arh-fin-doc-c-s-tax-nal-obj.obj-code         = parobj-code              and
                                                      bfrb_arh-fin-doc-c-s-tax-nal-obj.cli-type         = parreceiver-type         and
                                                      bfrb_arh-fin-doc-c-s-tax-nal-obj.cli-code         = parreceiver-code         and
                                                      bfrb_arh-fin-doc-c-s-tax-nal-obj.contract-code    = parcontract-code         and
                                                      bfrb_arh-fin-doc-c-s-tax-nal-obj.fin-code-acc     = parreceiver-fin-code-acc and
                                                      bfrb_arh-fin-doc-c-s-tax-nal-obj.curr-code        = parcurr-code             and
                                                      bfrb_arh-fin-doc-c-s-tax-nal-obj.fin-ext-doc-type = parfin-ext-doc-type      and
                                                      bfrb_arh-fin-doc-c-s-tax-nal-obj.calc-curr-code   = parbase-code             and
                                                      bfrb_arh-fin-doc-c-s-tax-nal-obj.vat-pc           = parvat-pc                and
                                                      bfrb_arh-fin-doc-c-s-tax-nal-obj.slt-pc           = parslt-pc                and
                                                      bfrb_arh-fin-doc-c-s-tax-nal-obj.with-vat         = parwith-vat              and
                                                      bfrb_arh-fin-doc-c-s-tax-nal-obj.with-slt         = parwith-slt              and
                                                      bfrb_arh-fin-doc-c-s-tax-nal-obj.sum-type         = parsum-type              and
                                                      bfrb_arh-fin-doc-c-s-tax-nal-obj.fact-order       = parfact-order            exclusive-lock.
  end.
  for each rbfrb_arh-fin-doc-c-s-tax-n-obj where rbfrb_arh-fin-doc-c-s-tax-n-obj.host-code        = bfrb_arh-fin-doc-c-s-tax-nal-obj.host-code        and
                                                 rbfrb_arh-fin-doc-c-s-tax-n-obj.obj-type         = bfrb_arh-fin-doc-c-s-tax-nal-obj.obj-type         and
                                                 rbfrb_arh-fin-doc-c-s-tax-n-obj.obj-code         = bfrb_arh-fin-doc-c-s-tax-nal-obj.obj-code         and
                                                 rbfrb_arh-fin-doc-c-s-tax-n-obj.cli-type         = parreceiver-type                                  and
                                                 rbfrb_arh-fin-doc-c-s-tax-n-obj.cli-code         = parreceiver-code                                  and
                                                 rbfrb_arh-fin-doc-c-s-tax-n-obj.contract-code    = bfrb_arh-fin-doc-c-s-tax-nal-obj.contract-code    and
                                                 rbfrb_arh-fin-doc-c-s-tax-n-obj.fin-code-acc     = bfrb_arh-fin-doc-c-s-tax-nal-obj.fin-code-acc     and
                                                 rbfrb_arh-fin-doc-c-s-tax-n-obj.curr-code        = bfrb_arh-fin-doc-c-s-tax-nal-obj.curr-code        and
                                                 rbfrb_arh-fin-doc-c-s-tax-n-obj.fin-ext-doc-type = bfrb_arh-fin-doc-c-s-tax-nal-obj.fin-ext-doc-type and
                                                 rbfrb_arh-fin-doc-c-s-tax-n-obj.calc-curr-code   = bfrb_arh-fin-doc-c-s-tax-nal-obj.calc-curr-code   and
                                                 rbfrb_arh-fin-doc-c-s-tax-n-obj.vat-pc           = bfrb_arh-fin-doc-c-s-tax-nal-obj.vat-pc           and
                                                 rbfrb_arh-fin-doc-c-s-tax-n-obj.slt-pc           = bfrb_arh-fin-doc-c-s-tax-nal-obj.slt-pc           and
                                                 rbfrb_arh-fin-doc-c-s-tax-n-obj.with-vat         = bfrb_arh-fin-doc-c-s-tax-nal-obj.with-vat         and
                                                 rbfrb_arh-fin-doc-c-s-tax-n-obj.with-slt         = bfrb_arh-fin-doc-c-s-tax-nal-obj.with-slt         and
                                                 rbfrb_arh-fin-doc-c-s-tax-n-obj.sum-type         = bfrb_arh-fin-doc-c-s-tax-nal-obj.sum-type         and
                                                 rbfrb_arh-fin-doc-c-s-tax-n-obj.fact-order       > bfrb_arh-fin-doc-c-s-tax-nal-obj.fact-order       use-index pi exclusive-lock on error undo, return error return-value :
    assign
      rbfrb_arh-fin-doc-c-s-tax-n-obj.income     = rbfrb_arh-fin-doc-c-s-tax-n-obj.income     + parsum-base
      rbfrb_arh-fin-doc-c-s-tax-n-obj.income-vat = rbfrb_arh-fin-doc-c-s-tax-n-obj.income-vat + parsum-vat-base
      rbfrb_arh-fin-doc-c-s-tax-n-obj.income-slt = rbfrb_arh-fin-doc-c-s-tax-n-obj.income-slt + parsum-slt-base
    .
  end.
  if parmode = "delete":u then do:
    delete bfpb_arh-fin-doc-c-s-tax-nal-obj.
    delete bfrb_arh-fin-doc-c-s-tax-nal-obj.
  end.
end.
if parrel-dog-code  =  yes          and
   parcurr-dog-code <> parcurr-code and
   parcurr-dog-code <> 0            and
   parcurr-dog-code <> parbase-code then do:
  if parmode = "close":u then do:
    find last bopc_arh-fin-doc-c-s-tax-nal-obj where bopc_arh-fin-doc-c-s-tax-nal-obj.host-code        = parhost-code          and
                                                     bopc_arh-fin-doc-c-s-tax-nal-obj.obj-type         = parobj-type           and
                                                     bopc_arh-fin-doc-c-s-tax-nal-obj.obj-code         = parobj-code           and
                                                     bopc_arh-fin-doc-c-s-tax-nal-obj.cli-type         = parpayer-type         and
                                                     bopc_arh-fin-doc-c-s-tax-nal-obj.cli-code         = parpayer-code         and
                                                     bopc_arh-fin-doc-c-s-tax-nal-obj.contract-code    = parcontract-code      and
                                                     bopc_arh-fin-doc-c-s-tax-nal-obj.fin-code-acc     = parpayer-fin-code-acc and
                                                     bopc_arh-fin-doc-c-s-tax-nal-obj.curr-code        = parcurr-code          and
                                                     bopc_arh-fin-doc-c-s-tax-nal-obj.fin-ext-doc-type = parfin-ext-doc-type   and
                                                     bopc_arh-fin-doc-c-s-tax-nal-obj.calc-curr-code   = parcurr-dog-code      and
                                                     bopc_arh-fin-doc-c-s-tax-nal-obj.vat-pc           = parvat-pc             and
                                                     bopc_arh-fin-doc-c-s-tax-nal-obj.slt-pc           = parslt-pc             and
                                                     bopc_arh-fin-doc-c-s-tax-nal-obj.with-vat         = parwith-vat           and
                                                     bopc_arh-fin-doc-c-s-tax-nal-obj.with-slt         = parwith-slt           and
                                                     bopc_arh-fin-doc-c-s-tax-nal-obj.sum-type         = parsum-type           and
                                                     bopc_arh-fin-doc-c-s-tax-nal-obj.fact-order       < parfact-order         no-error.
    create bfpc_arh-fin-doc-c-s-tax-nal-obj.
    assign
      bfpc_arh-fin-doc-c-s-tax-nal-obj.host-code        = parhost-code
      bfpc_arh-fin-doc-c-s-tax-nal-obj.obj-type         = parobj-type
      bfpc_arh-fin-doc-c-s-tax-nal-obj.obj-code         = parobj-code
      bfpc_arh-fin-doc-c-s-tax-nal-obj.cli-type         = parpayer-type
      bfpc_arh-fin-doc-c-s-tax-nal-obj.cli-code         = parpayer-code
      bfpc_arh-fin-doc-c-s-tax-nal-obj.contract-code    = parcontract-code
      bfpc_arh-fin-doc-c-s-tax-nal-obj.fin-code-acc     = parpayer-fin-code-acc
      bfpc_arh-fin-doc-c-s-tax-nal-obj.curr-code        = parcurr-code
      bfpc_arh-fin-doc-c-s-tax-nal-obj.fin-ext-doc-type = parfin-ext-doc-type
      bfpc_arh-fin-doc-c-s-tax-nal-obj.calc-curr-code   = parcurr-dog-code
      bfpc_arh-fin-doc-c-s-tax-nal-obj.vat-pc           = parvat-pc
      bfpc_arh-fin-doc-c-s-tax-nal-obj.slt-pc           = parslt-pc
      bfpc_arh-fin-doc-c-s-tax-nal-obj.with-vat         = parwith-vat
      bfpc_arh-fin-doc-c-s-tax-nal-obj.with-slt         = parwith-slt
      bfpc_arh-fin-doc-c-s-tax-nal-obj.sum-type         = parsum-type
      bfpc_arh-fin-doc-c-s-tax-nal-obj.cource-des       = "c":u
      bfpc_arh-fin-doc-c-s-tax-nal-obj.fact-order       = parfact-order
      bfpc_arh-fin-doc-c-s-tax-nal-obj.fin-doc-code     = parfin-doc-code
      bfpc_arh-fin-doc-c-s-tax-nal-obj.fact-date        = parfact-date
      bfpc_arh-fin-doc-c-s-tax-nal-obj.curr-code        = parcurr-code
      bfpc_arh-fin-doc-c-s-tax-nal-obj.income           = (if available bopc_arh-fin-doc-c-s-tax-nal-obj then bopc_arh-fin-doc-c-s-tax-nal-obj.income      else 0)
      bfpc_arh-fin-doc-c-s-tax-nal-obj.income-vat       = (if available bopc_arh-fin-doc-c-s-tax-nal-obj then bopc_arh-fin-doc-c-s-tax-nal-obj.income-vat  else 0)
      bfpc_arh-fin-doc-c-s-tax-nal-obj.income-slt       = (if available bopc_arh-fin-doc-c-s-tax-nal-obj then bopc_arh-fin-doc-c-s-tax-nal-obj.income-slt  else 0)
      bfpc_arh-fin-doc-c-s-tax-nal-obj.expense          = (if available bopc_arh-fin-doc-c-s-tax-nal-obj then bopc_arh-fin-doc-c-s-tax-nal-obj.expense     else 0) + parsum-contr
      bfpc_arh-fin-doc-c-s-tax-nal-obj.expense-vat      = (if available bopc_arh-fin-doc-c-s-tax-nal-obj then bopc_arh-fin-doc-c-s-tax-nal-obj.expense-vat else 0) + parsum-vat-contr
      bfpc_arh-fin-doc-c-s-tax-nal-obj.expense-slt      = (if available bopc_arh-fin-doc-c-s-tax-nal-obj then bopc_arh-fin-doc-c-s-tax-nal-obj.expense-slt else 0) + parsum-slt-contr
    .
  end.
  else do:
    find first bfpc_arh-fin-doc-c-s-tax-nal-obj where bfpc_arh-fin-doc-c-s-tax-nal-obj.host-code        = parhost-code          and
                                                      bfpc_arh-fin-doc-c-s-tax-nal-obj.obj-type         = parobj-type           and
                                                      bfpc_arh-fin-doc-c-s-tax-nal-obj.obj-code         = parobj-code           and
                                                      bfpc_arh-fin-doc-c-s-tax-nal-obj.cli-type         = parpayer-type         and
                                                      bfpc_arh-fin-doc-c-s-tax-nal-obj.cli-code         = parpayer-code         and
                                                      bfpc_arh-fin-doc-c-s-tax-nal-obj.contract-code    = parcontract-code      and
                                                      bfpc_arh-fin-doc-c-s-tax-nal-obj.fin-code-acc     = parpayer-fin-code-acc and
                                                      bfpc_arh-fin-doc-c-s-tax-nal-obj.curr-code        = parcurr-code          and
                                                      bfpc_arh-fin-doc-c-s-tax-nal-obj.fin-ext-doc-type = parfin-ext-doc-type   and
                                                      bfpc_arh-fin-doc-c-s-tax-nal-obj.calc-curr-code   = parcurr-dog-code      and
                                                      bfpc_arh-fin-doc-c-s-tax-nal-obj.vat-pc           = parvat-pc             and
                                                      bfpc_arh-fin-doc-c-s-tax-nal-obj.slt-pc           = parslt-pc             and
                                                      bfpc_arh-fin-doc-c-s-tax-nal-obj.with-vat         = parwith-vat           and
                                                      bfpc_arh-fin-doc-c-s-tax-nal-obj.with-slt         = parwith-slt           and
                                                      bfpc_arh-fin-doc-c-s-tax-nal-obj.sum-type         = parsum-type           and
                                                      bfpc_arh-fin-doc-c-s-tax-nal-obj.fact-order       = parfact-order         exclusive-lock.
  end.
  for each rbfpc_arh-fin-doc-c-s-tax-n-obj where rbfpc_arh-fin-doc-c-s-tax-n-obj.host-code        = bfpc_arh-fin-doc-c-s-tax-nal-obj.host-code        and
                                                 rbfpc_arh-fin-doc-c-s-tax-n-obj.obj-type         = bfpc_arh-fin-doc-c-s-tax-nal-obj.obj-type         and
                                                 rbfpc_arh-fin-doc-c-s-tax-n-obj.obj-code         = bfpc_arh-fin-doc-c-s-tax-nal-obj.obj-code         and
                                                 rbfpc_arh-fin-doc-c-s-tax-n-obj.cli-type         = parpayer-type                                     and
                                                 rbfpc_arh-fin-doc-c-s-tax-n-obj.cli-code         = parpayer-code                                     and
                                                 rbfpc_arh-fin-doc-c-s-tax-n-obj.contract-code    = bfpc_arh-fin-doc-c-s-tax-nal-obj.contract-code    and
                                                 rbfpc_arh-fin-doc-c-s-tax-n-obj.fin-code-acc     = bfpc_arh-fin-doc-c-s-tax-nal-obj.fin-code-acc     and
                                                 rbfpc_arh-fin-doc-c-s-tax-n-obj.curr-code        = bfpc_arh-fin-doc-c-s-tax-nal-obj.curr-code        and
                                                 rbfpc_arh-fin-doc-c-s-tax-n-obj.fin-ext-doc-type = bfpc_arh-fin-doc-c-s-tax-nal-obj.fin-ext-doc-type and
                                                 rbfpc_arh-fin-doc-c-s-tax-n-obj.calc-curr-code   = bfpc_arh-fin-doc-c-s-tax-nal-obj.calc-curr-code   and
                                                 rbfpc_arh-fin-doc-c-s-tax-n-obj.vat-pc           = bfpc_arh-fin-doc-c-s-tax-nal-obj.vat-pc           and
                                                 rbfpc_arh-fin-doc-c-s-tax-n-obj.slt-pc           = bfpc_arh-fin-doc-c-s-tax-nal-obj.slt-pc           and
                                                 rbfpc_arh-fin-doc-c-s-tax-n-obj.with-vat         = bfpc_arh-fin-doc-c-s-tax-nal-obj.with-vat         and
                                                 rbfpc_arh-fin-doc-c-s-tax-n-obj.with-slt         = bfpc_arh-fin-doc-c-s-tax-nal-obj.with-slt         and
                                                 rbfpc_arh-fin-doc-c-s-tax-n-obj.sum-type         = bfpc_arh-fin-doc-c-s-tax-nal-obj.sum-type         and
                                                 rbfpc_arh-fin-doc-c-s-tax-n-obj.fact-order       > bfpc_arh-fin-doc-c-s-tax-nal-obj.fact-order       use-index pi exclusive-lock on error undo, return error return-value :
    assign
      rbfpc_arh-fin-doc-c-s-tax-n-obj.expense     = rbfpc_arh-fin-doc-c-s-tax-n-obj.expense     + parsum-contr
      rbfpc_arh-fin-doc-c-s-tax-n-obj.expense-vat = rbfpc_arh-fin-doc-c-s-tax-n-obj.expense-vat + parsum-vat-contr
      rbfpc_arh-fin-doc-c-s-tax-n-obj.expense-slt = rbfpc_arh-fin-doc-c-s-tax-n-obj.expense-slt + parsum-slt-contr
    .
  end.
  if parmode = "close":u then do:
    find last borc_arh-fin-doc-c-s-tax-nal-obj where borc_arh-fin-doc-c-s-tax-nal-obj.host-code        = parhost-code             and
                                                     borc_arh-fin-doc-c-s-tax-nal-obj.obj-type         = parobj-type              and
                                                     borc_arh-fin-doc-c-s-tax-nal-obj.obj-code         = parobj-code              and
                                                     borc_arh-fin-doc-c-s-tax-nal-obj.cli-type         = parreceiver-type         and
                                                     borc_arh-fin-doc-c-s-tax-nal-obj.cli-code         = parreceiver-code         and
                                                     borc_arh-fin-doc-c-s-tax-nal-obj.contract-code    = parcontract-code         and
                                                     borc_arh-fin-doc-c-s-tax-nal-obj.fin-code-acc     = parreceiver-fin-code-acc and
                                                     borc_arh-fin-doc-c-s-tax-nal-obj.curr-code        = parcurr-code             and
                                                     borc_arh-fin-doc-c-s-tax-nal-obj.fin-ext-doc-type = parfin-ext-doc-type      and
                                                     borc_arh-fin-doc-c-s-tax-nal-obj.calc-curr-code   = parcurr-dog-code         and
                                                     borc_arh-fin-doc-c-s-tax-nal-obj.vat-pc           = parvat-pc                and
                                                     borc_arh-fin-doc-c-s-tax-nal-obj.slt-pc           = parslt-pc                and
                                                     borc_arh-fin-doc-c-s-tax-nal-obj.with-vat         = parwith-vat              and
                                                     borc_arh-fin-doc-c-s-tax-nal-obj.with-slt         = parwith-slt              and
                                                     borc_arh-fin-doc-c-s-tax-nal-obj.sum-type         = parsum-type              and
                                                     borc_arh-fin-doc-c-s-tax-nal-obj.fact-order       < parfact-order            no-error.
    create bfrc_arh-fin-doc-c-s-tax-nal-obj.
    assign
      bfrc_arh-fin-doc-c-s-tax-nal-obj.host-code        = parhost-code
      bfrc_arh-fin-doc-c-s-tax-nal-obj.obj-type         = parobj-type
      bfrc_arh-fin-doc-c-s-tax-nal-obj.obj-code         = parobj-code
      bfrc_arh-fin-doc-c-s-tax-nal-obj.cli-type         = parreceiver-type
      bfrc_arh-fin-doc-c-s-tax-nal-obj.cli-code         = parreceiver-code
      bfrc_arh-fin-doc-c-s-tax-nal-obj.contract-code    = parcontract-code
      bfrc_arh-fin-doc-c-s-tax-nal-obj.fin-code-acc     = parreceiver-fin-code-acc
      bfrc_arh-fin-doc-c-s-tax-nal-obj.curr-code        = parcurr-code
      bfrc_arh-fin-doc-c-s-tax-nal-obj.fin-ext-doc-type = parfin-ext-doc-type
      bfrc_arh-fin-doc-c-s-tax-nal-obj.calc-curr-code   = parcurr-dog-code
      bfrc_arh-fin-doc-c-s-tax-nal-obj.vat-pc           = parvat-pc
      bfrc_arh-fin-doc-c-s-tax-nal-obj.slt-pc           = parslt-pc
      bfrc_arh-fin-doc-c-s-tax-nal-obj.with-vat         = parwith-vat
      bfrc_arh-fin-doc-c-s-tax-nal-obj.with-slt         = parwith-slt
      bfrc_arh-fin-doc-c-s-tax-nal-obj.sum-type         = parsum-type
      bfrc_arh-fin-doc-c-s-tax-nal-obj.cource-des       = "c":u
      bfrc_arh-fin-doc-c-s-tax-nal-obj.fact-order       = parfact-order
      bfrc_arh-fin-doc-c-s-tax-nal-obj.fin-doc-code     = parfin-doc-code
      bfrc_arh-fin-doc-c-s-tax-nal-obj.fact-date        = parfact-date
      bfrc_arh-fin-doc-c-s-tax-nal-obj.curr-code        = parcurr-code
    .
    assign
      bfrc_arh-fin-doc-c-s-tax-nal-obj.expense          = (if available borc_arh-fin-doc-c-s-tax-nal-obj then borc_arh-fin-doc-c-s-tax-nal-obj.expense     else 0)
      bfrc_arh-fin-doc-c-s-tax-nal-obj.expense-vat      = (if available borc_arh-fin-doc-c-s-tax-nal-obj then borc_arh-fin-doc-c-s-tax-nal-obj.expense-vat else 0)
      bfrc_arh-fin-doc-c-s-tax-nal-obj.expense-slt      = (if available borc_arh-fin-doc-c-s-tax-nal-obj then borc_arh-fin-doc-c-s-tax-nal-obj.expense-slt else 0)
      bfrc_arh-fin-doc-c-s-tax-nal-obj.income           = (if available borc_arh-fin-doc-c-s-tax-nal-obj then borc_arh-fin-doc-c-s-tax-nal-obj.income      else 0) + parsum-contr
      bfrc_arh-fin-doc-c-s-tax-nal-obj.income-vat       = (if available borc_arh-fin-doc-c-s-tax-nal-obj then borc_arh-fin-doc-c-s-tax-nal-obj.income-vat  else 0) + parsum-vat-contr
      bfrc_arh-fin-doc-c-s-tax-nal-obj.income-slt       = (if available borc_arh-fin-doc-c-s-tax-nal-obj then borc_arh-fin-doc-c-s-tax-nal-obj.income-slt  else 0) + parsum-slt-contr
    .
  end.
  else do:
    find first bfrc_arh-fin-doc-c-s-tax-nal-obj where bfrc_arh-fin-doc-c-s-tax-nal-obj.host-code        = parhost-code             and
                                                      bfrc_arh-fin-doc-c-s-tax-nal-obj.obj-type         = parobj-type              and
                                                      bfrc_arh-fin-doc-c-s-tax-nal-obj.obj-code         = parobj-code              and
                                                      bfrc_arh-fin-doc-c-s-tax-nal-obj.cli-type         = parreceiver-type         and
                                                      bfrc_arh-fin-doc-c-s-tax-nal-obj.cli-code         = parreceiver-code         and
                                                      bfrc_arh-fin-doc-c-s-tax-nal-obj.contract-code    = parcontract-code         and
                                                      bfrc_arh-fin-doc-c-s-tax-nal-obj.fin-code-acc     = parreceiver-fin-code-acc and
                                                      bfrc_arh-fin-doc-c-s-tax-nal-obj.curr-code        = parcurr-code             and
                                                      bfrc_arh-fin-doc-c-s-tax-nal-obj.fin-ext-doc-type = parfin-ext-doc-type      and
                                                      bfrc_arh-fin-doc-c-s-tax-nal-obj.calc-curr-code   = parcurr-dog-code         and
                                                      bfrc_arh-fin-doc-c-s-tax-nal-obj.vat-pc           = parvat-pc                and
                                                      bfrc_arh-fin-doc-c-s-tax-nal-obj.slt-pc           = parslt-pc                and
                                                      bfrc_arh-fin-doc-c-s-tax-nal-obj.with-vat         = parwith-vat              and
                                                      bfrc_arh-fin-doc-c-s-tax-nal-obj.with-slt         = parwith-slt              and
                                                      bfrc_arh-fin-doc-c-s-tax-nal-obj.sum-type         = parsum-type              and
                                                      bfrc_arh-fin-doc-c-s-tax-nal-obj.fact-order       = parfact-order            exclusive-lock.
  end.
  for each rbfrc_arh-fin-doc-c-s-tax-n-obj where rbfrc_arh-fin-doc-c-s-tax-n-obj.host-code        = bfrc_arh-fin-doc-c-s-tax-nal-obj.host-code        and
                                                 rbfrc_arh-fin-doc-c-s-tax-n-obj.obj-type         = bfrc_arh-fin-doc-c-s-tax-nal-obj.obj-type         and
                                                 rbfrc_arh-fin-doc-c-s-tax-n-obj.obj-code         = bfrc_arh-fin-doc-c-s-tax-nal-obj.obj-code         and
                                                 rbfrc_arh-fin-doc-c-s-tax-n-obj.cli-type         = parreceiver-type                                  and
                                                 rbfrc_arh-fin-doc-c-s-tax-n-obj.cli-code         = parreceiver-code                                  and
                                                 rbfrc_arh-fin-doc-c-s-tax-n-obj.contract-code    = bfrc_arh-fin-doc-c-s-tax-nal-obj.contract-code    and
                                                 rbfrc_arh-fin-doc-c-s-tax-n-obj.fin-code-acc     = bfrc_arh-fin-doc-c-s-tax-nal-obj.fin-code-acc     and
                                                 rbfrc_arh-fin-doc-c-s-tax-n-obj.curr-code        = bfrc_arh-fin-doc-c-s-tax-nal-obj.curr-code        and
                                                 rbfrc_arh-fin-doc-c-s-tax-n-obj.fin-ext-doc-type = bfrc_arh-fin-doc-c-s-tax-nal-obj.fin-ext-doc-type and
                                                 rbfrc_arh-fin-doc-c-s-tax-n-obj.calc-curr-code   = bfrc_arh-fin-doc-c-s-tax-nal-obj.calc-curr-code   and
                                                 rbfrc_arh-fin-doc-c-s-tax-n-obj.vat-pc           = bfrc_arh-fin-doc-c-s-tax-nal-obj.vat-pc           and
                                                 rbfrc_arh-fin-doc-c-s-tax-n-obj.slt-pc           = bfrc_arh-fin-doc-c-s-tax-nal-obj.slt-pc           and
                                                 rbfrc_arh-fin-doc-c-s-tax-n-obj.with-vat         = bfrc_arh-fin-doc-c-s-tax-nal-obj.with-vat         and
                                                 rbfrc_arh-fin-doc-c-s-tax-n-obj.with-slt         = bfrc_arh-fin-doc-c-s-tax-nal-obj.with-slt         and
                                                 rbfrc_arh-fin-doc-c-s-tax-n-obj.sum-type         = bfrc_arh-fin-doc-c-s-tax-nal-obj.sum-type         and
                                                 rbfrc_arh-fin-doc-c-s-tax-n-obj.fact-order       > bfrc_arh-fin-doc-c-s-tax-nal-obj.fact-order       use-index pi exclusive-lock on error undo, return error return-value :
    assign
      rbfrc_arh-fin-doc-c-s-tax-n-obj.income     = rbfrc_arh-fin-doc-c-s-tax-n-obj.income     + parsum-contr
      rbfrc_arh-fin-doc-c-s-tax-n-obj.income-vat = rbfrc_arh-fin-doc-c-s-tax-n-obj.income-vat + parsum-vat-contr
      rbfrc_arh-fin-doc-c-s-tax-n-obj.income-slt = rbfrc_arh-fin-doc-c-s-tax-n-obj.income-slt + parsum-slt-contr
    .
  end.
  if parmode = "delete":u then do:
    delete bfpc_arh-fin-doc-c-s-tax-nal-obj.
    delete bfrc_arh-fin-doc-c-s-tax-nal-obj.
  end.
end.
end.
end procedure.
procedure libfarpo_calc-arh-fin-doc-schet-obj :
define input parameter parmode                    as   character                   no-undo.
define input parameter parhost-code               like ub.fin-doc.host-code        no-undo.
define input parameter parobj-type                like ub.fin-doc.obj-type         no-undo.
define input parameter parobj-code                like ub.fin-doc.obj-code         no-undo.
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
define input parameter parshift-date              like ub.fin-doc.shift-date       no-undo.
define input parameter parshift-num               like ub.fin-doc.shift-num        no-undo.
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
define buffer bfps_arh-fin-doc-schet-obj  for ub.arh-fin-doc-schet-obj.
define buffer bfrs_arh-fin-doc-schet-obj  for ub.arh-fin-doc-schet-obj.
define buffer rbfps_arh-fin-doc-schet-obj for ub.arh-fin-doc-schet-obj.
define buffer rbfrs_arh-fin-doc-schet-obj for ub.arh-fin-doc-schet-obj.
define buffer bops_arh-fin-doc-schet-obj  for ub.arh-fin-doc-schet-obj.
define buffer bors_arh-fin-doc-schet-obj  for ub.arh-fin-doc-schet-obj.
define buffer bfpr_arh-fin-doc-schet-obj  for ub.arh-fin-doc-schet-obj.
define buffer bfrr_arh-fin-doc-schet-obj  for ub.arh-fin-doc-schet-obj.
define buffer rbfpr_arh-fin-doc-schet-obj for ub.arh-fin-doc-schet-obj.
define buffer rbfrr_arh-fin-doc-schet-obj for ub.arh-fin-doc-schet-obj.
define buffer bopr_arh-fin-doc-schet-obj  for ub.arh-fin-doc-schet-obj.
define buffer borr_arh-fin-doc-schet-obj  for ub.arh-fin-doc-schet-obj.
define buffer bfpb_arh-fin-doc-schet-obj  for ub.arh-fin-doc-schet-obj.
define buffer bfrb_arh-fin-doc-schet-obj  for ub.arh-fin-doc-schet-obj.
define buffer rbfpb_arh-fin-doc-schet-obj for ub.arh-fin-doc-schet-obj.
define buffer rbfrb_arh-fin-doc-schet-obj for ub.arh-fin-doc-schet-obj.
define buffer bopb_arh-fin-doc-schet-obj  for ub.arh-fin-doc-schet-obj.
define buffer borb_arh-fin-doc-schet-obj  for ub.arh-fin-doc-schet-obj.
define buffer bfpc_arh-fin-doc-schet-obj  for ub.arh-fin-doc-schet-obj.
define buffer bfrc_arh-fin-doc-schet-obj  for ub.arh-fin-doc-schet-obj.
define buffer rbfpc_arh-fin-doc-schet-obj for ub.arh-fin-doc-schet-obj.
define buffer rbfrc_arh-fin-doc-schet-obj for ub.arh-fin-doc-schet-obj.
define buffer bopc_arh-fin-doc-schet-obj  for ub.arh-fin-doc-schet-obj.
define buffer borc_arh-fin-doc-schet-obj  for ub.arh-fin-doc-schet-obj.
do on error undo, return error substitute ("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
if parmode = "close":u then do:
  find last bops_arh-fin-doc-schet-obj where bops_arh-fin-doc-schet-obj.host-code        = parhost-code         and
                                             bops_arh-fin-doc-schet-obj.obj-type         = parobj-type          and
                                             bops_arh-fin-doc-schet-obj.obj-code         = parobj-code          and
                                             bops_arh-fin-doc-schet-obj.cli-type         = parpayer-type        and
                                             bops_arh-fin-doc-schet-obj.cli-code         = parpayer-code        and
                                             bops_arh-fin-doc-schet-obj.code-schet       = parpayer-code-schet  and
                                             bops_arh-fin-doc-schet-obj.fin-ext-doc-type = parfin-ext-doc-type  and
                                             bops_arh-fin-doc-schet-obj.calc-curr-code   = parcurr-code         and
                                             bops_arh-fin-doc-schet-obj.sum-type         = parsum-type          and
                                             bops_arh-fin-doc-schet-obj.fact-order       < parfact-order        use-index pi no-error.
  create bfps_arh-fin-doc-schet-obj.
  assign
    bfps_arh-fin-doc-schet-obj.host-code        = parhost-code
    bfps_arh-fin-doc-schet-obj.obj-type         = parobj-type
    bfps_arh-fin-doc-schet-obj.obj-code         = parobj-code
    bfps_arh-fin-doc-schet-obj.cli-type         = parpayer-type
    bfps_arh-fin-doc-schet-obj.cli-code         = parpayer-code
    bfps_arh-fin-doc-schet-obj.code-schet       = parpayer-code-schet
    bfps_arh-fin-doc-schet-obj.fin-ext-doc-type = parfin-ext-doc-type
    bfps_arh-fin-doc-schet-obj.calc-curr-code   = parcurr-code
    bfps_arh-fin-doc-schet-obj.sum-type         = parsum-type
    bfps_arh-fin-doc-schet-obj.cource-des       = "s":u
    bfps_arh-fin-doc-schet-obj.fact-order       = parfact-order
    bfps_arh-fin-doc-schet-obj.fin-doc-code     = parfin-doc-code
    bfps_arh-fin-doc-schet-obj.fact-date        = parfact-date
    bfps_arh-fin-doc-schet-obj.shift-date       = parshift-date
    bfps_arh-fin-doc-schet-obj.shift-num        = parshift-num
    bfps_arh-fin-doc-schet-obj.curr-code        = parcurr-code
    bfps_arh-fin-doc-schet-obj.income           = (if available bops_arh-fin-doc-schet-obj then bops_arh-fin-doc-schet-obj.income      else 0)
    bfps_arh-fin-doc-schet-obj.income-vat       = (if available bops_arh-fin-doc-schet-obj then bops_arh-fin-doc-schet-obj.income-vat  else 0)
    bfps_arh-fin-doc-schet-obj.income-slt       = (if available bops_arh-fin-doc-schet-obj then bops_arh-fin-doc-schet-obj.income-slt  else 0)
    bfps_arh-fin-doc-schet-obj.expense          = (if available bops_arh-fin-doc-schet-obj then bops_arh-fin-doc-schet-obj.expense     else 0) + parsum-doc
    bfps_arh-fin-doc-schet-obj.expense-vat      = (if available bops_arh-fin-doc-schet-obj then bops_arh-fin-doc-schet-obj.expense-vat else 0) + parsum-vat-doc
    bfps_arh-fin-doc-schet-obj.expense-slt      = (if available bops_arh-fin-doc-schet-obj then bops_arh-fin-doc-schet-obj.expense-slt else 0) + parsum-slt-doc
  .
end.
else do:
  find first bfps_arh-fin-doc-schet-obj where bfps_arh-fin-doc-schet-obj.host-code        = parhost-code         and
                                              bfps_arh-fin-doc-schet-obj.obj-type         = parobj-type          and
                                              bfps_arh-fin-doc-schet-obj.obj-code         = parobj-code          and
                                              bfps_arh-fin-doc-schet-obj.cli-type         = parpayer-type        and
                                              bfps_arh-fin-doc-schet-obj.cli-code         = parpayer-code        and
                                              bfps_arh-fin-doc-schet-obj.code-schet       = parpayer-code-schet  and
                                              bfps_arh-fin-doc-schet-obj.fin-ext-doc-type = parfin-ext-doc-type  and
                                              bfps_arh-fin-doc-schet-obj.calc-curr-code   = parcurr-code         and
                                              bfps_arh-fin-doc-schet-obj.sum-type         = parsum-type          and
                                              bfps_arh-fin-doc-schet-obj.fact-order       = parfact-order        exclusive-lock.
end.
for each rbfps_arh-fin-doc-schet-obj where rbfps_arh-fin-doc-schet-obj.host-code        = bfps_arh-fin-doc-schet-obj.host-code        and
                                           rbfps_arh-fin-doc-schet-obj.obj-type         = bfps_arh-fin-doc-schet-obj.obj-type         and
                                           rbfps_arh-fin-doc-schet-obj.obj-code         = bfps_arh-fin-doc-schet-obj.obj-code         and
                                           rbfps_arh-fin-doc-schet-obj.cli-type         = parpayer-type                               and
                                           rbfps_arh-fin-doc-schet-obj.cli-code         = parpayer-code                               and
                                           rbfps_arh-fin-doc-schet-obj.code-schet       = bfps_arh-fin-doc-schet-obj.code-schet       and
                                           rbfps_arh-fin-doc-schet-obj.fin-ext-doc-type = bfps_arh-fin-doc-schet-obj.fin-ext-doc-type and
                                           rbfps_arh-fin-doc-schet-obj.calc-curr-code   = bfps_arh-fin-doc-schet-obj.calc-curr-code   and
                                           rbfps_arh-fin-doc-schet-obj.sum-type         = bfps_arh-fin-doc-schet-obj.sum-type         and
                                           rbfps_arh-fin-doc-schet-obj.fact-order       > bfps_arh-fin-doc-schet-obj.fact-order       use-index pi exclusive-lock on error undo, return error return-value :
  assign
    rbfps_arh-fin-doc-schet-obj.expense     = rbfps_arh-fin-doc-schet-obj.expense     + parsum-doc
    rbfps_arh-fin-doc-schet-obj.expense-vat = rbfps_arh-fin-doc-schet-obj.expense-vat + parsum-vat-doc
    rbfps_arh-fin-doc-schet-obj.expense-slt = rbfps_arh-fin-doc-schet-obj.expense-slt + parsum-slt-doc
  .
end.
if parmode = "close":u then do:
  find last bors_arh-fin-doc-schet-obj where bors_arh-fin-doc-schet-obj.host-code        = parhost-code            and
                                             bors_arh-fin-doc-schet-obj.obj-type         = parobj-type             and
                                             bors_arh-fin-doc-schet-obj.obj-code         = parobj-code             and
                                             bors_arh-fin-doc-schet-obj.cli-type         = parreceiver-type        and
                                             bors_arh-fin-doc-schet-obj.cli-code         = parreceiver-code        and
                                             bors_arh-fin-doc-schet-obj.code-schet       = parreceiver-code-schet  and
                                             bors_arh-fin-doc-schet-obj.fin-ext-doc-type = parfin-ext-doc-type     and
                                             bors_arh-fin-doc-schet-obj.calc-curr-code   = parcurr-code            and
                                             bors_arh-fin-doc-schet-obj.sum-type         = parsum-type             and
                                             bors_arh-fin-doc-schet-obj.fact-order       < parfact-order           use-index pi no-error.
  create bfrs_arh-fin-doc-schet-obj.
  assign
    bfrs_arh-fin-doc-schet-obj.host-code        = parhost-code
    bfrs_arh-fin-doc-schet-obj.obj-type         = parobj-type
    bfrs_arh-fin-doc-schet-obj.obj-code         = parobj-code
    bfrs_arh-fin-doc-schet-obj.cli-type         = parreceiver-type
    bfrs_arh-fin-doc-schet-obj.cli-code         = parreceiver-code
    bfrs_arh-fin-doc-schet-obj.code-schet       = parreceiver-code-schet
    bfrs_arh-fin-doc-schet-obj.fin-ext-doc-type = parfin-ext-doc-type
    bfrs_arh-fin-doc-schet-obj.calc-curr-code   = parcurr-code
    bfrs_arh-fin-doc-schet-obj.sum-type         = parsum-type
    bfps_arh-fin-doc-schet-obj.cource-des       = "s":u
    bfrs_arh-fin-doc-schet-obj.fact-order       = parfact-order
    bfrs_arh-fin-doc-schet-obj.fin-doc-code     = parfin-doc-code
    bfrs_arh-fin-doc-schet-obj.fact-date        = parfact-date
    bfrs_arh-fin-doc-schet-obj.shift-date       = parshift-date
    bfrs_arh-fin-doc-schet-obj.shift-num        = parshift-num
    bfrs_arh-fin-doc-schet-obj.curr-code        = parcurr-code
  .
  assign
    bfrs_arh-fin-doc-schet-obj.expense          = (if available bors_arh-fin-doc-schet-obj then bors_arh-fin-doc-schet-obj.expense     else 0)
    bfrs_arh-fin-doc-schet-obj.expense-vat      = (if available bors_arh-fin-doc-schet-obj then bors_arh-fin-doc-schet-obj.expense-vat else 0)
    bfrs_arh-fin-doc-schet-obj.expense-slt      = (if available bors_arh-fin-doc-schet-obj then bors_arh-fin-doc-schet-obj.expense-slt else 0)
    bfrs_arh-fin-doc-schet-obj.income           = (if available bors_arh-fin-doc-schet-obj then bors_arh-fin-doc-schet-obj.income      else 0) + parsum-doc
    bfrs_arh-fin-doc-schet-obj.income-vat       = (if available bors_arh-fin-doc-schet-obj then bors_arh-fin-doc-schet-obj.income-vat  else 0) + parsum-vat-doc
    bfrs_arh-fin-doc-schet-obj.income-slt       = (if available bors_arh-fin-doc-schet-obj then bors_arh-fin-doc-schet-obj.income-slt  else 0) + parsum-slt-doc
  .
end.
else do:
  find first bfrs_arh-fin-doc-schet-obj where bfrs_arh-fin-doc-schet-obj.host-code        = parhost-code            and
                                              bfrs_arh-fin-doc-schet-obj.obj-type         = parobj-type             and
                                              bfrs_arh-fin-doc-schet-obj.obj-code         = parobj-code             and
                                              bfrs_arh-fin-doc-schet-obj.cli-type         = parreceiver-type        and
                                              bfrs_arh-fin-doc-schet-obj.cli-code         = parreceiver-code        and
                                              bfrs_arh-fin-doc-schet-obj.code-schet       = parreceiver-code-schet  and
                                              bfrs_arh-fin-doc-schet-obj.fin-ext-doc-type = parfin-ext-doc-type     and
                                              bfrs_arh-fin-doc-schet-obj.calc-curr-code   = parcurr-code            and
                                              bfrs_arh-fin-doc-schet-obj.sum-type         = parsum-type             and
                                              bfrs_arh-fin-doc-schet-obj.fact-order       = parfact-order           exclusive-lock.
end.
for each rbfrs_arh-fin-doc-schet-obj where rbfrs_arh-fin-doc-schet-obj.host-code        = bfrs_arh-fin-doc-schet-obj.host-code        and
                                           rbfrs_arh-fin-doc-schet-obj.obj-type         = bfrs_arh-fin-doc-schet-obj.obj-type         and
                                           rbfrs_arh-fin-doc-schet-obj.obj-code         = bfrs_arh-fin-doc-schet-obj.obj-code         and
                                           rbfrs_arh-fin-doc-schet-obj.cli-type         = parreceiver-type                            and
                                           rbfrs_arh-fin-doc-schet-obj.cli-code         = parreceiver-code                            and
                                           rbfrs_arh-fin-doc-schet-obj.code-schet       = bfrs_arh-fin-doc-schet-obj.code-schet       and
                                           rbfrs_arh-fin-doc-schet-obj.fin-ext-doc-type = bfrs_arh-fin-doc-schet-obj.fin-ext-doc-type and
                                           rbfrs_arh-fin-doc-schet-obj.calc-curr-code   = bfrs_arh-fin-doc-schet-obj.calc-curr-code   and
                                           rbfrs_arh-fin-doc-schet-obj.sum-type         = bfrs_arh-fin-doc-schet-obj.sum-type         and
                                           rbfrs_arh-fin-doc-schet-obj.fact-order       > bfrs_arh-fin-doc-schet-obj.fact-order       use-index pi exclusive-lock on error undo, return error return-value :
  assign
    rbfrs_arh-fin-doc-schet-obj.income     = rbfrs_arh-fin-doc-schet-obj.income     + parsum-doc
    rbfrs_arh-fin-doc-schet-obj.income-vat = rbfrs_arh-fin-doc-schet-obj.income-vat + parsum-vat-doc
    rbfrs_arh-fin-doc-schet-obj.income-slt = rbfrs_arh-fin-doc-schet-obj.income-slt + parsum-slt-doc
  .
end.
if parmode = "delete":u then do:
  delete bfps_arh-fin-doc-schet-obj.
  delete bfrs_arh-fin-doc-schet-obj.
end.
if parcurr-code <> 0 then do:
  if parmode = "close":u then do:
    find last bopr_arh-fin-doc-schet-obj where bopr_arh-fin-doc-schet-obj.host-code        = parhost-code         and
                                               bopr_arh-fin-doc-schet-obj.obj-type         = parobj-type          and
                                               bopr_arh-fin-doc-schet-obj.obj-code         = parobj-code          and
                                               bopr_arh-fin-doc-schet-obj.cli-type         = parpayer-type        and
                                               bopr_arh-fin-doc-schet-obj.cli-code         = parpayer-code        and
                                               bopr_arh-fin-doc-schet-obj.code-schet       = parpayer-code-schet  and
                                               bopr_arh-fin-doc-schet-obj.fin-ext-doc-type = parfin-ext-doc-type  and
                                               bopr_arh-fin-doc-schet-obj.calc-curr-code   = 0                    and
                                               bopr_arh-fin-doc-schet-obj.sum-type         = parsum-type          and
                                               bopr_arh-fin-doc-schet-obj.fact-order       < parfact-order        use-index pi no-error.
    create bfpr_arh-fin-doc-schet-obj.
    assign
      bfpr_arh-fin-doc-schet-obj.host-code        = parhost-code
      bfpr_arh-fin-doc-schet-obj.obj-type         = parobj-type
      bfpr_arh-fin-doc-schet-obj.obj-code         = parobj-code
      bfpr_arh-fin-doc-schet-obj.cli-type         = parpayer-type
      bfpr_arh-fin-doc-schet-obj.cli-code         = parpayer-code
      bfpr_arh-fin-doc-schet-obj.code-schet       = parpayer-code-schet
      bfpr_arh-fin-doc-schet-obj.fin-ext-doc-type = parfin-ext-doc-type
      bfpr_arh-fin-doc-schet-obj.calc-curr-code   = 0
      bfpr_arh-fin-doc-schet-obj.sum-type         = parsum-type
      bfpr_arh-fin-doc-schet-obj.cource-des       = "r":u
      bfpr_arh-fin-doc-schet-obj.fact-order       = parfact-order
      bfpr_arh-fin-doc-schet-obj.fin-doc-code     = parfin-doc-code
      bfpr_arh-fin-doc-schet-obj.fact-date        = parfact-date
      bfpr_arh-fin-doc-schet-obj.shift-date       = parshift-date
      bfpr_arh-fin-doc-schet-obj.shift-num        = parshift-num
      bfpr_arh-fin-doc-schet-obj.curr-code        = parcurr-code
      bfpr_arh-fin-doc-schet-obj.income           = (if available bopr_arh-fin-doc-schet-obj then bopr_arh-fin-doc-schet-obj.income      else 0)
      bfpr_arh-fin-doc-schet-obj.income-vat       = (if available bopr_arh-fin-doc-schet-obj then bopr_arh-fin-doc-schet-obj.income-vat  else 0)
      bfpr_arh-fin-doc-schet-obj.income-slt       = (if available bopr_arh-fin-doc-schet-obj then bopr_arh-fin-doc-schet-obj.income-slt  else 0)
      bfpr_arh-fin-doc-schet-obj.expense          = (if available bopr_arh-fin-doc-schet-obj then bopr_arh-fin-doc-schet-obj.expense     else 0) + parsum-rubl
      bfpr_arh-fin-doc-schet-obj.expense-vat      = (if available bopr_arh-fin-doc-schet-obj then bopr_arh-fin-doc-schet-obj.expense-vat else 0) + parsum-vat-rubl
      bfpr_arh-fin-doc-schet-obj.expense-slt      = (if available bopr_arh-fin-doc-schet-obj then bopr_arh-fin-doc-schet-obj.expense-slt else 0) + parsum-slt-rubl
    .
  end.
  else do:
    find first bfpr_arh-fin-doc-schet-obj where bfpr_arh-fin-doc-schet-obj.host-code        = parhost-code         and
                                                bfpr_arh-fin-doc-schet-obj.obj-type         = parobj-type          and
                                                bfpr_arh-fin-doc-schet-obj.obj-code         = parobj-code          and
                                                bfpr_arh-fin-doc-schet-obj.cli-type         = parpayer-type        and
                                                bfpr_arh-fin-doc-schet-obj.cli-code         = parpayer-code        and
                                                bfpr_arh-fin-doc-schet-obj.code-schet       = parpayer-code-schet  and
                                                bfpr_arh-fin-doc-schet-obj.fin-ext-doc-type = parfin-ext-doc-type  and
                                                bfpr_arh-fin-doc-schet-obj.calc-curr-code   = 0                    and
                                                bfpr_arh-fin-doc-schet-obj.sum-type         = parsum-type          and
                                                bfpr_arh-fin-doc-schet-obj.fact-order       = parfact-order        exclusive-lock.
  end.
  for each rbfpr_arh-fin-doc-schet-obj where rbfpr_arh-fin-doc-schet-obj.host-code        = bfpr_arh-fin-doc-schet-obj.host-code        and
                                             rbfpr_arh-fin-doc-schet-obj.obj-type         = bfpr_arh-fin-doc-schet-obj.obj-type         and
                                             rbfpr_arh-fin-doc-schet-obj.obj-code         = bfpr_arh-fin-doc-schet-obj.obj-code         and
                                             rbfpr_arh-fin-doc-schet-obj.cli-type         = parpayer-type                               and
                                             rbfpr_arh-fin-doc-schet-obj.cli-code         = parpayer-code                               and
                                             rbfpr_arh-fin-doc-schet-obj.code-schet       = bfpr_arh-fin-doc-schet-obj.code-schet       and
                                             rbfpr_arh-fin-doc-schet-obj.fin-ext-doc-type = bfpr_arh-fin-doc-schet-obj.fin-ext-doc-type and
                                             rbfpr_arh-fin-doc-schet-obj.calc-curr-code   = bfpr_arh-fin-doc-schet-obj.calc-curr-code   and
                                             rbfpr_arh-fin-doc-schet-obj.sum-type         = bfpr_arh-fin-doc-schet-obj.sum-type         and
                                             rbfpr_arh-fin-doc-schet-obj.fact-order       > bfpr_arh-fin-doc-schet-obj.fact-order       use-index pi exclusive-lock on error undo, return error return-value :
    assign
      rbfpr_arh-fin-doc-schet-obj.expense     = rbfpr_arh-fin-doc-schet-obj.expense     + parsum-rubl
      rbfpr_arh-fin-doc-schet-obj.expense-vat = rbfpr_arh-fin-doc-schet-obj.expense-vat + parsum-vat-rubl
      rbfpr_arh-fin-doc-schet-obj.expense-slt = rbfpr_arh-fin-doc-schet-obj.expense-slt + parsum-slt-rubl
    .
  end.
  if parmode = "close":u then do:
    find last borr_arh-fin-doc-schet-obj where borr_arh-fin-doc-schet-obj.host-code        = parhost-code            and
                                               borr_arh-fin-doc-schet-obj.obj-type         = parobj-type             and
                                               borr_arh-fin-doc-schet-obj.obj-code         = parobj-code             and
                                               borr_arh-fin-doc-schet-obj.cli-type         = parreceiver-type        and
                                               borr_arh-fin-doc-schet-obj.cli-code         = parreceiver-code        and
                                               borr_arh-fin-doc-schet-obj.code-schet       = parreceiver-code-schet  and
                                               borr_arh-fin-doc-schet-obj.fin-ext-doc-type = parfin-ext-doc-type     and
                                               borr_arh-fin-doc-schet-obj.calc-curr-code   = 0                       and
                                               borr_arh-fin-doc-schet-obj.sum-type         = parsum-type             and
                                               borr_arh-fin-doc-schet-obj.fact-order       < parfact-order           use-index pi no-error.
    create bfrr_arh-fin-doc-schet-obj.
    assign
      bfrr_arh-fin-doc-schet-obj.host-code        = parhost-code
      bfrr_arh-fin-doc-schet-obj.obj-type         = parobj-type
      bfrr_arh-fin-doc-schet-obj.obj-code         = parobj-code
      bfrr_arh-fin-doc-schet-obj.cli-type         = parreceiver-type
      bfrr_arh-fin-doc-schet-obj.cli-code         = parreceiver-code
      bfrr_arh-fin-doc-schet-obj.code-schet       = parreceiver-code-schet
      bfrr_arh-fin-doc-schet-obj.fin-ext-doc-type = parfin-ext-doc-type
      bfrr_arh-fin-doc-schet-obj.calc-curr-code   = 0
      bfrr_arh-fin-doc-schet-obj.sum-type         = parsum-type
      bfrr_arh-fin-doc-schet-obj.cource-des       = "r":u
      bfrr_arh-fin-doc-schet-obj.fact-order       = parfact-order
      bfrr_arh-fin-doc-schet-obj.fin-doc-code     = parfin-doc-code
      bfrr_arh-fin-doc-schet-obj.fact-date        = parfact-date
      bfrr_arh-fin-doc-schet-obj.shift-date       = parshift-date
      bfrr_arh-fin-doc-schet-obj.shift-num        = parshift-num
      bfrr_arh-fin-doc-schet-obj.curr-code        = parcurr-code
    .
    assign
      bfrr_arh-fin-doc-schet-obj.expense          = (if available borr_arh-fin-doc-schet-obj then borr_arh-fin-doc-schet-obj.expense     else 0)
      bfrr_arh-fin-doc-schet-obj.expense-vat      = (if available borr_arh-fin-doc-schet-obj then borr_arh-fin-doc-schet-obj.expense-vat else 0)
      bfrr_arh-fin-doc-schet-obj.expense-slt      = (if available borr_arh-fin-doc-schet-obj then borr_arh-fin-doc-schet-obj.expense-slt else 0)
      bfrr_arh-fin-doc-schet-obj.income           = (if available borr_arh-fin-doc-schet-obj then borr_arh-fin-doc-schet-obj.income      else 0) + parsum-rubl
      bfrr_arh-fin-doc-schet-obj.income-vat       = (if available borr_arh-fin-doc-schet-obj then borr_arh-fin-doc-schet-obj.income-vat  else 0) + parsum-vat-rubl
      bfrr_arh-fin-doc-schet-obj.income-slt       = (if available borr_arh-fin-doc-schet-obj then borr_arh-fin-doc-schet-obj.income-slt  else 0) + parsum-slt-rubl
    .
  end.
  else do:
    find first borr_arh-fin-doc-schet-obj where bfrr_arh-fin-doc-schet-obj.host-code        = parhost-code            and
                                                bfrr_arh-fin-doc-schet-obj.obj-type         = parobj-type             and
                                                bfrr_arh-fin-doc-schet-obj.obj-code         = parobj-code             and
                                                bfrr_arh-fin-doc-schet-obj.cli-type         = parreceiver-type        and
                                                bfrr_arh-fin-doc-schet-obj.cli-code         = parreceiver-code        and
                                                bfrr_arh-fin-doc-schet-obj.code-schet       = parreceiver-code-schet  and
                                                bfrr_arh-fin-doc-schet-obj.fin-ext-doc-type = parfin-ext-doc-type     and
                                                bfrr_arh-fin-doc-schet-obj.calc-curr-code   = 0                       and
                                                bfrr_arh-fin-doc-schet-obj.sum-type         = parsum-type             and
                                                bfrr_arh-fin-doc-schet-obj.fact-order       = parfact-order           exclusive-lock.
  end.
  for each rbfrr_arh-fin-doc-schet-obj where rbfrr_arh-fin-doc-schet-obj.host-code        = bfrr_arh-fin-doc-schet-obj.host-code        and
                                             rbfrr_arh-fin-doc-schet-obj.obj-type         = bfrr_arh-fin-doc-schet-obj.obj-type         and
                                             rbfrr_arh-fin-doc-schet-obj.obj-code         = bfrr_arh-fin-doc-schet-obj.obj-code         and
                                             rbfrr_arh-fin-doc-schet-obj.cli-type         = parreceiver-type                            and
                                             rbfrr_arh-fin-doc-schet-obj.cli-code         = parreceiver-code                            and
                                             rbfrr_arh-fin-doc-schet-obj.code-schet       = bfrr_arh-fin-doc-schet-obj.code-schet       and
                                             rbfrr_arh-fin-doc-schet-obj.fin-ext-doc-type = bfrr_arh-fin-doc-schet-obj.fin-ext-doc-type and
                                             rbfrr_arh-fin-doc-schet-obj.calc-curr-code   = bfrr_arh-fin-doc-schet-obj.calc-curr-code   and
                                             rbfrr_arh-fin-doc-schet-obj.sum-type         = bfrr_arh-fin-doc-schet-obj.sum-type         and
                                             rbfrr_arh-fin-doc-schet-obj.fact-order       > bfrr_arh-fin-doc-schet-obj.fact-order       use-index pi exclusive-lock on error undo, return error return-value :
    assign
      rbfrr_arh-fin-doc-schet-obj.income     = rbfrr_arh-fin-doc-schet-obj.income     + parsum-rubl
      rbfrr_arh-fin-doc-schet-obj.income-vat = rbfrr_arh-fin-doc-schet-obj.income-vat + parsum-vat-rubl
      rbfrr_arh-fin-doc-schet-obj.income-slt = rbfrr_arh-fin-doc-schet-obj.income-slt + parsum-slt-rubl
    .
  end.
  if parmode = "delete":u then do:
    delete bfpr_arh-fin-doc-schet-obj.
    delete bfrr_arh-fin-doc-schet-obj.
  end.
end.
if parbase-code <> parcurr-code and
   parbase-code <> 0            then do:
  if parmode = "close":u then do:
    find last bopb_arh-fin-doc-schet-obj where bopb_arh-fin-doc-schet-obj.host-code        = parhost-code         and
                                               bopb_arh-fin-doc-schet-obj.obj-type         = parobj-type          and
                                               bopb_arh-fin-doc-schet-obj.obj-code         = parobj-code          and
                                               bopb_arh-fin-doc-schet-obj.cli-type         = parpayer-type        and
                                               bopb_arh-fin-doc-schet-obj.cli-code         = parpayer-code        and
                                               bopb_arh-fin-doc-schet-obj.code-schet       = parpayer-code-schet  and
                                               bopb_arh-fin-doc-schet-obj.fin-ext-doc-type = parfin-ext-doc-type  and
                                               bopb_arh-fin-doc-schet-obj.calc-curr-code   = parbase-code         and
                                               bopb_arh-fin-doc-schet-obj.sum-type         = parsum-type          and
                                               bopb_arh-fin-doc-schet-obj.fact-order       < parfact-order        use-index pi no-error.
    create bfpb_arh-fin-doc-schet-obj.
    assign
      bfpb_arh-fin-doc-schet-obj.host-code        = parhost-code
      bfpb_arh-fin-doc-schet-obj.obj-type         = parobj-type
      bfpb_arh-fin-doc-schet-obj.obj-code         = parobj-code
      bfpb_arh-fin-doc-schet-obj.cli-type         = parpayer-type
      bfpb_arh-fin-doc-schet-obj.cli-code         = parpayer-code
      bfpb_arh-fin-doc-schet-obj.code-schet       = parpayer-code-schet
      bfpb_arh-fin-doc-schet-obj.fin-ext-doc-type = parfin-ext-doc-type
      bfpb_arh-fin-doc-schet-obj.calc-curr-code   = parbase-code
      bfpb_arh-fin-doc-schet-obj.sum-type         = parsum-type
      bfpb_arh-fin-doc-schet-obj.cource-des       = "b":u
      bfpb_arh-fin-doc-schet-obj.fact-order       = parfact-order
      bfpb_arh-fin-doc-schet-obj.fin-doc-code     = parfin-doc-code
      bfpb_arh-fin-doc-schet-obj.fact-date        = parfact-date
      bfpb_arh-fin-doc-schet-obj.shift-date       = parshift-date
      bfpb_arh-fin-doc-schet-obj.shift-num        = parshift-num
      bfpb_arh-fin-doc-schet-obj.curr-code        = parcurr-code
      bfpb_arh-fin-doc-schet-obj.income           = (if available bopb_arh-fin-doc-schet-obj then bopb_arh-fin-doc-schet-obj.income      else 0)
      bfpb_arh-fin-doc-schet-obj.income-vat       = (if available bopb_arh-fin-doc-schet-obj then bopb_arh-fin-doc-schet-obj.income-vat  else 0)
      bfpb_arh-fin-doc-schet-obj.income-slt       = (if available bopb_arh-fin-doc-schet-obj then bopb_arh-fin-doc-schet-obj.income-slt  else 0)
      bfpb_arh-fin-doc-schet-obj.expense          = (if available bopb_arh-fin-doc-schet-obj then bopb_arh-fin-doc-schet-obj.expense     else 0) + parsum-base
      bfpb_arh-fin-doc-schet-obj.expense-vat      = (if available bopb_arh-fin-doc-schet-obj then bopb_arh-fin-doc-schet-obj.expense-vat else 0) + parsum-vat-base
      bfpb_arh-fin-doc-schet-obj.expense-slt      = (if available bopb_arh-fin-doc-schet-obj then bopb_arh-fin-doc-schet-obj.expense-slt else 0) + parsum-slt-base
    .
  end.
  else do:
    find first bfpb_arh-fin-doc-schet-obj where bfpb_arh-fin-doc-schet-obj.host-code        = parhost-code         and
                                                bfpb_arh-fin-doc-schet-obj.obj-type         = parobj-type          and
                                                bfpb_arh-fin-doc-schet-obj.obj-code         = parobj-code          and
                                                bfpb_arh-fin-doc-schet-obj.cli-type         = parpayer-type        and
                                                bfpb_arh-fin-doc-schet-obj.cli-code         = parpayer-code        and
                                                bfpb_arh-fin-doc-schet-obj.code-schet       = parpayer-code-schet  and
                                                bfpb_arh-fin-doc-schet-obj.fin-ext-doc-type = parfin-ext-doc-type  and
                                                bfpb_arh-fin-doc-schet-obj.calc-curr-code   = parbase-code         and
                                                bfpb_arh-fin-doc-schet-obj.sum-type         = parsum-type          and
                                                bfpb_arh-fin-doc-schet-obj.fact-order       = parfact-order        exclusive-lock.
  end.
  for each rbfpb_arh-fin-doc-schet-obj where rbfpb_arh-fin-doc-schet-obj.host-code        = bfpb_arh-fin-doc-schet-obj.host-code        and
                                             rbfpb_arh-fin-doc-schet-obj.obj-type         = bfpb_arh-fin-doc-schet-obj.obj-type         and
                                             rbfpb_arh-fin-doc-schet-obj.obj-code         = bfpb_arh-fin-doc-schet-obj.obj-code         and
                                             rbfpb_arh-fin-doc-schet-obj.cli-type         = parpayer-type                               and
                                             rbfpb_arh-fin-doc-schet-obj.cli-code         = parpayer-code                               and
                                             rbfpb_arh-fin-doc-schet-obj.code-schet       = bfpb_arh-fin-doc-schet-obj.code-schet       and
                                             rbfpb_arh-fin-doc-schet-obj.fin-ext-doc-type = bfpb_arh-fin-doc-schet-obj.fin-ext-doc-type and
                                             rbfpb_arh-fin-doc-schet-obj.calc-curr-code   = bfpb_arh-fin-doc-schet-obj.calc-curr-code   and
                                             rbfpb_arh-fin-doc-schet-obj.sum-type         = bfpb_arh-fin-doc-schet-obj.sum-type         and
                                             rbfpb_arh-fin-doc-schet-obj.fact-order       > bfpb_arh-fin-doc-schet-obj.fact-order       use-index pi exclusive-lock on error undo, return error return-value :
    assign
      rbfpb_arh-fin-doc-schet-obj.expense     = rbfpb_arh-fin-doc-schet-obj.expense     + parsum-base
      rbfpb_arh-fin-doc-schet-obj.expense-vat = rbfpb_arh-fin-doc-schet-obj.expense-vat + parsum-vat-base
      rbfpb_arh-fin-doc-schet-obj.expense-slt = rbfpb_arh-fin-doc-schet-obj.expense-slt + parsum-slt-base
    .
  end.
  if parmode = "close":u then do:
    find last borb_arh-fin-doc-schet-obj where borb_arh-fin-doc-schet-obj.host-code        = parhost-code            and
                                               borb_arh-fin-doc-schet-obj.obj-type         = parobj-type             and
                                               borb_arh-fin-doc-schet-obj.obj-code         = parobj-code             and
                                               borb_arh-fin-doc-schet-obj.cli-type         = parreceiver-type        and
                                               borb_arh-fin-doc-schet-obj.cli-code         = parreceiver-code        and
                                               borb_arh-fin-doc-schet-obj.code-schet       = parreceiver-code-schet  and
                                               borb_arh-fin-doc-schet-obj.fin-ext-doc-type = parfin-ext-doc-type     and
                                               borb_arh-fin-doc-schet-obj.calc-curr-code   = parbase-code            and
                                               borb_arh-fin-doc-schet-obj.sum-type         = parsum-type             and
                                               borb_arh-fin-doc-schet-obj.fact-order       < parfact-order           use-index pi no-error.
    create bfrb_arh-fin-doc-schet-obj.
    assign
      bfrb_arh-fin-doc-schet-obj.host-code        = parhost-code
      bfrb_arh-fin-doc-schet-obj.obj-type         = parobj-type
      bfrb_arh-fin-doc-schet-obj.obj-code         = parobj-code
      bfrb_arh-fin-doc-schet-obj.cli-type         = parreceiver-type
      bfrb_arh-fin-doc-schet-obj.cli-code         = parreceiver-code
      bfrb_arh-fin-doc-schet-obj.code-schet       = parreceiver-code-schet
      bfrb_arh-fin-doc-schet-obj.fin-ext-doc-type = parfin-ext-doc-type
      bfrb_arh-fin-doc-schet-obj.calc-curr-code   = parbase-code
      bfrb_arh-fin-doc-schet-obj.sum-type         = parsum-type
      bfrb_arh-fin-doc-schet-obj.cource-des       = "b":u
      bfrb_arh-fin-doc-schet-obj.fact-order       = parfact-order
      bfrb_arh-fin-doc-schet-obj.fin-doc-code     = parfin-doc-code
      bfrb_arh-fin-doc-schet-obj.fact-date        = parfact-date
      bfrb_arh-fin-doc-schet-obj.shift-date       = parshift-date
      bfrb_arh-fin-doc-schet-obj.shift-num        = parshift-num
      bfrb_arh-fin-doc-schet-obj.curr-code        = parcurr-code
    .
    assign
      bfrb_arh-fin-doc-schet-obj.expense          = (if available borb_arh-fin-doc-schet-obj then borb_arh-fin-doc-schet-obj.expense     else 0)
      bfrb_arh-fin-doc-schet-obj.expense-vat      = (if available borb_arh-fin-doc-schet-obj then borb_arh-fin-doc-schet-obj.expense-vat else 0)
      bfrb_arh-fin-doc-schet-obj.expense-slt      = (if available borb_arh-fin-doc-schet-obj then borb_arh-fin-doc-schet-obj.expense-slt else 0)
      bfrb_arh-fin-doc-schet-obj.income           = (if available borb_arh-fin-doc-schet-obj then borb_arh-fin-doc-schet-obj.income      else 0) + parsum-base
      bfrb_arh-fin-doc-schet-obj.income-vat       = (if available borb_arh-fin-doc-schet-obj then borb_arh-fin-doc-schet-obj.income-vat  else 0) + parsum-vat-base
      bfrb_arh-fin-doc-schet-obj.income-slt       = (if available borb_arh-fin-doc-schet-obj then borb_arh-fin-doc-schet-obj.income-slt  else 0) + parsum-slt-base
    .
  end.
  else do:
    find first bfrb_arh-fin-doc-schet-obj where bfrb_arh-fin-doc-schet-obj.host-code        = parhost-code            and
                                                bfrb_arh-fin-doc-schet-obj.obj-type         = parobj-type             and
                                                bfrb_arh-fin-doc-schet-obj.obj-code         = parobj-code             and
                                                bfrb_arh-fin-doc-schet-obj.cli-type         = parreceiver-type        and
                                                bfrb_arh-fin-doc-schet-obj.cli-code         = parreceiver-code        and
                                                bfrb_arh-fin-doc-schet-obj.code-schet       = parreceiver-code-schet  and
                                                bfrb_arh-fin-doc-schet-obj.fin-ext-doc-type = parfin-ext-doc-type     and
                                                bfrb_arh-fin-doc-schet-obj.calc-curr-code   = parbase-code            and
                                                bfrb_arh-fin-doc-schet-obj.sum-type         = parsum-type             and
                                                bfrb_arh-fin-doc-schet-obj.fact-order       = parfact-order           exclusive-lock.
  end.
  for each rbfrb_arh-fin-doc-schet-obj where rbfrb_arh-fin-doc-schet-obj.host-code        = bfrb_arh-fin-doc-schet-obj.host-code        and
                                             rbfrb_arh-fin-doc-schet-obj.obj-type         = bfrb_arh-fin-doc-schet-obj.obj-type         and
                                             rbfrb_arh-fin-doc-schet-obj.obj-code         = bfrb_arh-fin-doc-schet-obj.obj-code         and
                                             rbfrb_arh-fin-doc-schet-obj.cli-type         = parreceiver-type                            and
                                             rbfrb_arh-fin-doc-schet-obj.cli-code         = parreceiver-code                            and
                                             rbfrb_arh-fin-doc-schet-obj.code-schet       = bfrb_arh-fin-doc-schet-obj.code-schet       and
                                             rbfrb_arh-fin-doc-schet-obj.fin-ext-doc-type = bfrb_arh-fin-doc-schet-obj.fin-ext-doc-type and
                                             rbfrb_arh-fin-doc-schet-obj.calc-curr-code   = bfrb_arh-fin-doc-schet-obj.calc-curr-code   and
                                             rbfrb_arh-fin-doc-schet-obj.sum-type         = bfrb_arh-fin-doc-schet-obj.sum-type         and
                                             rbfrb_arh-fin-doc-schet-obj.fact-order       > bfrb_arh-fin-doc-schet-obj.fact-order       use-index pi exclusive-lock on error undo, return error return-value :
    assign
      rbfrb_arh-fin-doc-schet-obj.income     = rbfrb_arh-fin-doc-schet-obj.income     + parsum-base
      rbfrb_arh-fin-doc-schet-obj.income-vat = rbfrb_arh-fin-doc-schet-obj.income-vat + parsum-vat-base
      rbfrb_arh-fin-doc-schet-obj.income-slt = rbfrb_arh-fin-doc-schet-obj.income-slt + parsum-slt-base
    .
  end.
  if parmode = "delete":u then do:
    delete bfpb_arh-fin-doc-schet-obj.
    delete bfrb_arh-fin-doc-schet-obj.
  end.
end.
end.
end procedure.
procedure libfarpo_calc-arh-fin-doc-schet-n-obj :
define input parameter parmode                    as   character                    no-undo.
define input parameter parhost-code               like ub.fin-doc.host-code         no-undo.
define input parameter parobj-type                like ub.fin-doc.obj-type          no-undo.
define input parameter parobj-code                like ub.fin-doc.obj-code          no-undo.
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
define input parameter parshift-date              like ub.fin-doc.shift-date        no-undo.
define input parameter parshift-num               like ub.fin-doc.shift-num         no-undo.
define input parameter parcurr-code               like ub.fin-doc.curr-code         no-undo.
define input parameter parcashbookid              like ub.fin-doc.cashbookid        no-undo.
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
define buffer bfps_arh-fin-doc-schet-nal-obj  for ub.arh-fin-doc-schet-nal-obj.
define buffer bfrs_arh-fin-doc-schet-nal-obj  for ub.arh-fin-doc-schet-nal-obj.
define buffer rbfps_arh-fin-doc-schet-nal-obj for ub.arh-fin-doc-schet-nal-obj.
define buffer rbfrs_arh-fin-doc-schet-nal-obj for ub.arh-fin-doc-schet-nal-obj.
define buffer bops_arh-fin-doc-schet-nal-obj  for ub.arh-fin-doc-schet-nal-obj.
define buffer bors_arh-fin-doc-schet-nal-obj  for ub.arh-fin-doc-schet-nal-obj.
define buffer bfpr_arh-fin-doc-schet-nal-obj  for ub.arh-fin-doc-schet-nal-obj.
define buffer bfrr_arh-fin-doc-schet-nal-obj  for ub.arh-fin-doc-schet-nal-obj.
define buffer rbfpr_arh-fin-doc-schet-nal-obj for ub.arh-fin-doc-schet-nal-obj.
define buffer rbfrr_arh-fin-doc-schet-nal-obj for ub.arh-fin-doc-schet-nal-obj.
define buffer bopr_arh-fin-doc-schet-nal-obj  for ub.arh-fin-doc-schet-nal-obj.
define buffer borr_arh-fin-doc-schet-nal-obj  for ub.arh-fin-doc-schet-nal-obj.
define buffer bfpb_arh-fin-doc-schet-nal-obj  for ub.arh-fin-doc-schet-nal-obj.
define buffer bfrb_arh-fin-doc-schet-nal-obj  for ub.arh-fin-doc-schet-nal-obj.
define buffer rbfpb_arh-fin-doc-schet-nal-obj for ub.arh-fin-doc-schet-nal-obj.
define buffer rbfrb_arh-fin-doc-schet-nal-obj for ub.arh-fin-doc-schet-nal-obj.
define buffer bopb_arh-fin-doc-schet-nal-obj  for ub.arh-fin-doc-schet-nal-obj.
define buffer borb_arh-fin-doc-schet-nal-obj  for ub.arh-fin-doc-schet-nal-obj.
define buffer bfpc_arh-fin-doc-schet-nal-obj  for ub.arh-fin-doc-schet-nal-obj.
define buffer bfrc_arh-fin-doc-schet-nal-obj  for ub.arh-fin-doc-schet-nal-obj.
define buffer rbfpc_arh-fin-doc-schet-nal-obj for ub.arh-fin-doc-schet-nal-obj.
define buffer rbfrc_arh-fin-doc-schet-nal-obj for ub.arh-fin-doc-schet-nal-obj.
define buffer bopc_arh-fin-doc-schet-nal-obj  for ub.arh-fin-doc-schet-nal-obj.
define buffer borc_arh-fin-doc-schet-nal-obj  for ub.arh-fin-doc-schet-nal-obj.
do on error undo, return error substitute ("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
if parpayer-code <> 0 then do:
if parmode = "close":u then do:
  find last bops_arh-fin-doc-schet-nal-obj where bops_arh-fin-doc-schet-nal-obj.host-code        = parhost-code          and
                                                 bops_arh-fin-doc-schet-nal-obj.obj-type         = parobj-type           and
                                                 bops_arh-fin-doc-schet-nal-obj.obj-code         = parobj-code           and
                                                 bops_arh-fin-doc-schet-nal-obj.cli-type         = parpayer-type         and
                                                 bops_arh-fin-doc-schet-nal-obj.cli-code         = parpayer-code         and
                                                 bops_arh-fin-doc-schet-nal-obj.fin-code-acc     = parpayer-fin-code-acc and
                                                 bops_arh-fin-doc-schet-nal-obj.curr-code        = parcurr-code          and
                                                 bops_arh-fin-doc-schet-nal-obj.fin-ext-doc-type = parfin-ext-doc-type   and
                                                 bops_arh-fin-doc-schet-nal-obj.calc-curr-code   = parcurr-code          and
                                                 bops_arh-fin-doc-schet-nal-obj.sum-type         = parsum-type           and
                                                 bops_arh-fin-doc-schet-nal-obj.cashbookid       = parcashbookid         and
                                                 bops_arh-fin-doc-schet-nal-obj.fact-order       < parfact-order         use-index pi no-error.
  create bfps_arh-fin-doc-schet-nal-obj.
  assign
    bfps_arh-fin-doc-schet-nal-obj.host-code        = parhost-code
    bfps_arh-fin-doc-schet-nal-obj.obj-type         = parobj-type
    bfps_arh-fin-doc-schet-nal-obj.obj-code         = parobj-code
    bfps_arh-fin-doc-schet-nal-obj.cli-type         = parpayer-type
    bfps_arh-fin-doc-schet-nal-obj.cli-code         = parpayer-code
    bfps_arh-fin-doc-schet-nal-obj.fin-code-acc     = parpayer-fin-code-acc
    bfps_arh-fin-doc-schet-nal-obj.curr-code        = parcurr-code
    bfps_arh-fin-doc-schet-nal-obj.fin-ext-doc-type = parfin-ext-doc-type
    bfps_arh-fin-doc-schet-nal-obj.calc-curr-code   = parcurr-code
    bfps_arh-fin-doc-schet-nal-obj.sum-type         = parsum-type
    bfps_arh-fin-doc-schet-nal-obj.cource-des       = "s":u
    bfps_arh-fin-doc-schet-nal-obj.fact-order       = parfact-order
    bfps_arh-fin-doc-schet-nal-obj.fin-doc-code     = parfin-doc-code
    bfps_arh-fin-doc-schet-nal-obj.fact-date        = parfact-date
    bfps_arh-fin-doc-schet-nal-obj.shift-date       = parshift-date
    bfps_arh-fin-doc-schet-nal-obj.shift-num        = parshift-num
    bfps_arh-fin-doc-schet-nal-obj.curr-code        = parcurr-code
    bfps_arh-fin-doc-schet-nal-obj.cashbookid       = parcashbookid
    bfps_arh-fin-doc-schet-nal-obj.income           = (if available bops_arh-fin-doc-schet-nal-obj then bops_arh-fin-doc-schet-nal-obj.income      else 0)
    bfps_arh-fin-doc-schet-nal-obj.income-vat       = (if available bops_arh-fin-doc-schet-nal-obj then bops_arh-fin-doc-schet-nal-obj.income-vat  else 0)
    bfps_arh-fin-doc-schet-nal-obj.income-slt       = (if available bops_arh-fin-doc-schet-nal-obj then bops_arh-fin-doc-schet-nal-obj.income-slt  else 0)
    bfps_arh-fin-doc-schet-nal-obj.expense          = (if available bops_arh-fin-doc-schet-nal-obj then bops_arh-fin-doc-schet-nal-obj.expense     else 0) + parsum-doc
    bfps_arh-fin-doc-schet-nal-obj.expense-vat      = (if available bops_arh-fin-doc-schet-nal-obj then bops_arh-fin-doc-schet-nal-obj.expense-vat else 0) + parsum-vat-doc
    bfps_arh-fin-doc-schet-nal-obj.expense-slt      = (if available bops_arh-fin-doc-schet-nal-obj then bops_arh-fin-doc-schet-nal-obj.expense-slt else 0) + parsum-slt-doc
  .
end.
else do:
  find first bfps_arh-fin-doc-schet-nal-obj where bfps_arh-fin-doc-schet-nal-obj.host-code        = parhost-code          and
                                                  bfps_arh-fin-doc-schet-nal-obj.obj-type         = parobj-type           and
                                                  bfps_arh-fin-doc-schet-nal-obj.obj-code         = parobj-code           and
                                                  bfps_arh-fin-doc-schet-nal-obj.cli-type         = parpayer-type         and
                                                  bfps_arh-fin-doc-schet-nal-obj.cli-code         = parpayer-code         and
                                                  bfps_arh-fin-doc-schet-nal-obj.fin-code-acc     = parpayer-fin-code-acc and
                                                  bfps_arh-fin-doc-schet-nal-obj.curr-code        = parcurr-code          and
                                                  bfps_arh-fin-doc-schet-nal-obj.fin-ext-doc-type = parfin-ext-doc-type   and
                                                  bfps_arh-fin-doc-schet-nal-obj.calc-curr-code   = parcurr-code          and
                                                  bfps_arh-fin-doc-schet-nal-obj.sum-type         = parsum-type           and
                                                  bfps_arh-fin-doc-schet-nal-obj.cashbookid       = parcashbookid         and
                                                  bfps_arh-fin-doc-schet-nal-obj.fact-order       = parfact-order         exclusive-lock.
end.
for each rbfps_arh-fin-doc-schet-nal-obj where rbfps_arh-fin-doc-schet-nal-obj.host-code        = bfps_arh-fin-doc-schet-nal-obj.host-code        and
                                               rbfps_arh-fin-doc-schet-nal-obj.obj-type         = bfps_arh-fin-doc-schet-nal-obj.obj-type         and
                                               rbfps_arh-fin-doc-schet-nal-obj.obj-code         = bfps_arh-fin-doc-schet-nal-obj.obj-code         and
                                               rbfps_arh-fin-doc-schet-nal-obj.cli-type         = parpayer-type                                   and
                                               rbfps_arh-fin-doc-schet-nal-obj.cli-code         = parpayer-code                                   and
                                               rbfps_arh-fin-doc-schet-nal-obj.fin-code-acc     = bfps_arh-fin-doc-schet-nal-obj.fin-code-acc     and
                                               rbfps_arh-fin-doc-schet-nal-obj.curr-code        = bfps_arh-fin-doc-schet-nal-obj.curr-code        and
                                               rbfps_arh-fin-doc-schet-nal-obj.fin-ext-doc-type = bfps_arh-fin-doc-schet-nal-obj.fin-ext-doc-type and
                                               rbfps_arh-fin-doc-schet-nal-obj.calc-curr-code   = bfps_arh-fin-doc-schet-nal-obj.calc-curr-code   and
                                               rbfps_arh-fin-doc-schet-nal-obj.sum-type         = bfps_arh-fin-doc-schet-nal-obj.sum-type         and
                                               rbfps_arh-fin-doc-schet-nal-obj.cashbookid       = parcashbookid                                   and
                                               rbfps_arh-fin-doc-schet-nal-obj.fact-order       > bfps_arh-fin-doc-schet-nal-obj.fact-order       use-index pi exclusive-lock on error undo, return error return-value :
  assign
    rbfps_arh-fin-doc-schet-nal-obj.expense     = rbfps_arh-fin-doc-schet-nal-obj.expense     + parsum-doc
    rbfps_arh-fin-doc-schet-nal-obj.expense-vat = rbfps_arh-fin-doc-schet-nal-obj.expense-vat + parsum-vat-doc
    rbfps_arh-fin-doc-schet-nal-obj.expense-slt = rbfps_arh-fin-doc-schet-nal-obj.expense-slt + parsum-slt-doc
  .
end.
end.
if parreceiver-code <> 0 then do:
if parmode = "close":u then do:
  find last bors_arh-fin-doc-schet-nal-obj where bors_arh-fin-doc-schet-nal-obj.host-code        = parhost-code             and
                                                 bors_arh-fin-doc-schet-nal-obj.obj-type         = parobj-type              and
                                                 bors_arh-fin-doc-schet-nal-obj.obj-code         = parobj-code              and
                                                 bors_arh-fin-doc-schet-nal-obj.cli-type         = parreceiver-type         and
                                                 bors_arh-fin-doc-schet-nal-obj.cli-code         = parreceiver-code         and
                                                 bors_arh-fin-doc-schet-nal-obj.fin-code-acc     = parreceiver-fin-code-acc and
                                                 bors_arh-fin-doc-schet-nal-obj.curr-code        = parcurr-code             and
                                                 bors_arh-fin-doc-schet-nal-obj.fin-ext-doc-type = parfin-ext-doc-type      and
                                                 bors_arh-fin-doc-schet-nal-obj.calc-curr-code   = parcurr-code             and
                                                 bors_arh-fin-doc-schet-nal-obj.sum-type         = parsum-type              and
                                                 bors_arh-fin-doc-schet-nal-obj.cashbookid       = parcashbookid            and
                                                 bors_arh-fin-doc-schet-nal-obj.fact-order       < parfact-order            use-index pi no-error.
  create bfrs_arh-fin-doc-schet-nal-obj.
  assign
    bfrs_arh-fin-doc-schet-nal-obj.host-code        = parhost-code
    bfrs_arh-fin-doc-schet-nal-obj.obj-type         = parobj-type
    bfrs_arh-fin-doc-schet-nal-obj.obj-code         = parobj-code
    bfrs_arh-fin-doc-schet-nal-obj.cli-type         = parreceiver-type
    bfrs_arh-fin-doc-schet-nal-obj.cli-code         = parreceiver-code
    bfrs_arh-fin-doc-schet-nal-obj.fin-code-acc     = parreceiver-fin-code-acc
    bfrs_arh-fin-doc-schet-nal-obj.curr-code        = parcurr-code
    bfrs_arh-fin-doc-schet-nal-obj.fin-ext-doc-type = parfin-ext-doc-type
    bfrs_arh-fin-doc-schet-nal-obj.calc-curr-code   = parcurr-code
    bfrs_arh-fin-doc-schet-nal-obj.sum-type         = parsum-type
    bfrs_arh-fin-doc-schet-nal-obj.cource-des       = "s":u
    bfrs_arh-fin-doc-schet-nal-obj.fact-order       = parfact-order
    bfrs_arh-fin-doc-schet-nal-obj.shift-date       = parshift-date
    bfrs_arh-fin-doc-schet-nal-obj.shift-num        = parshift-num
    bfrs_arh-fin-doc-schet-nal-obj.fin-doc-code     = parfin-doc-code
    bfrs_arh-fin-doc-schet-nal-obj.fact-date        = parfact-date
    bfrs_arh-fin-doc-schet-nal-obj.curr-code        = parcurr-code
    bfrs_arh-fin-doc-schet-nal-obj.cashbookid       = parcashbookid
  .
  assign
    bfrs_arh-fin-doc-schet-nal-obj.expense          = (if available bors_arh-fin-doc-schet-nal-obj then bors_arh-fin-doc-schet-nal-obj.expense     else 0)
    bfrs_arh-fin-doc-schet-nal-obj.expense-vat      = (if available bors_arh-fin-doc-schet-nal-obj then bors_arh-fin-doc-schet-nal-obj.expense-vat else 0)
    bfrs_arh-fin-doc-schet-nal-obj.expense-slt      = (if available bors_arh-fin-doc-schet-nal-obj then bors_arh-fin-doc-schet-nal-obj.expense-slt else 0)
    bfrs_arh-fin-doc-schet-nal-obj.income           = (if available bors_arh-fin-doc-schet-nal-obj then bors_arh-fin-doc-schet-nal-obj.income      else 0) + parsum-doc
    bfrs_arh-fin-doc-schet-nal-obj.income-vat       = (if available bors_arh-fin-doc-schet-nal-obj then bors_arh-fin-doc-schet-nal-obj.income-vat  else 0) + parsum-vat-doc
    bfrs_arh-fin-doc-schet-nal-obj.income-slt       = (if available bors_arh-fin-doc-schet-nal-obj then bors_arh-fin-doc-schet-nal-obj.income-slt  else 0) + parsum-slt-doc
  .
end.
else do:
  find first bfrs_arh-fin-doc-schet-nal-obj where bfrs_arh-fin-doc-schet-nal-obj.host-code        = parhost-code             and
                                                  bfrs_arh-fin-doc-schet-nal-obj.obj-type         = parobj-type              and
                                                  bfrs_arh-fin-doc-schet-nal-obj.obj-code         = parobj-code              and
                                                  bfrs_arh-fin-doc-schet-nal-obj.cli-type         = parreceiver-type         and
                                                  bfrs_arh-fin-doc-schet-nal-obj.cli-code         = parreceiver-code         and
                                                  bfrs_arh-fin-doc-schet-nal-obj.fin-code-acc     = parreceiver-fin-code-acc and
                                                  bfrs_arh-fin-doc-schet-nal-obj.curr-code        = parcurr-code             and
                                                  bfrs_arh-fin-doc-schet-nal-obj.fin-ext-doc-type = parfin-ext-doc-type      and
                                                  bfrs_arh-fin-doc-schet-nal-obj.calc-curr-code   = parcurr-code             and
                                                  bfrs_arh-fin-doc-schet-nal-obj.sum-type         = parsum-type              and
                                                  bfrs_arh-fin-doc-schet-nal-obj.cashbookid       = parcashbookid            and
                                                  bfrs_arh-fin-doc-schet-nal-obj.fact-order       = parfact-order            exclusive-lock.
end.
for each rbfrs_arh-fin-doc-schet-nal-obj where rbfrs_arh-fin-doc-schet-nal-obj.host-code        = bfrs_arh-fin-doc-schet-nal-obj.host-code        and
                                               rbfrs_arh-fin-doc-schet-nal-obj.obj-type         = bfrs_arh-fin-doc-schet-nal-obj.obj-type         and
                                               rbfrs_arh-fin-doc-schet-nal-obj.obj-code         = bfrs_arh-fin-doc-schet-nal-obj.obj-code         and
                                               rbfrs_arh-fin-doc-schet-nal-obj.cli-type         = parreceiver-type                                and
                                               rbfrs_arh-fin-doc-schet-nal-obj.cli-code         = parreceiver-code                                and
                                               rbfrs_arh-fin-doc-schet-nal-obj.fin-code-acc     = bfrs_arh-fin-doc-schet-nal-obj.fin-code-acc     and
                                               rbfrs_arh-fin-doc-schet-nal-obj.curr-code        = bfrs_arh-fin-doc-schet-nal-obj.curr-code        and
                                               rbfrs_arh-fin-doc-schet-nal-obj.fin-ext-doc-type = bfrs_arh-fin-doc-schet-nal-obj.fin-ext-doc-type and
                                               rbfrs_arh-fin-doc-schet-nal-obj.calc-curr-code   = bfrs_arh-fin-doc-schet-nal-obj.calc-curr-code   and
                                               rbfrs_arh-fin-doc-schet-nal-obj.sum-type         = bfrs_arh-fin-doc-schet-nal-obj.sum-type         and
                                               rbfrs_arh-fin-doc-schet-nal-obj.cashbookid       = parcashbookid                                   and
                                               rbfrs_arh-fin-doc-schet-nal-obj.fact-order       > bfrs_arh-fin-doc-schet-nal-obj.fact-order       use-index pi exclusive-lock on error undo, return error return-value :
  assign
    rbfrs_arh-fin-doc-schet-nal-obj.income     = rbfrs_arh-fin-doc-schet-nal-obj.income     + parsum-doc
    rbfrs_arh-fin-doc-schet-nal-obj.income-vat = rbfrs_arh-fin-doc-schet-nal-obj.income-vat + parsum-vat-doc
    rbfrs_arh-fin-doc-schet-nal-obj.income-slt = rbfrs_arh-fin-doc-schet-nal-obj.income-slt + parsum-slt-doc
  .
end.
end.
if parmode = "delete":u then do:
  if parpayer-code <> 0 then do:
  delete bfps_arh-fin-doc-schet-nal-obj.
  end.
  if parreceiver-code <> 0 then do:
  delete bfrs_arh-fin-doc-schet-nal-obj.
end.
end.
if parcurr-code <> 0 then do:
  if parpayer-code <> 0 then do:
  if parmode = "close":u then do:
    find last bopr_arh-fin-doc-schet-nal-obj where bopr_arh-fin-doc-schet-nal-obj.host-code        = parhost-code          and
                                                   bopr_arh-fin-doc-schet-nal-obj.obj-type         = parobj-type           and
                                                   bopr_arh-fin-doc-schet-nal-obj.obj-code         = parobj-code           and
                                                   bopr_arh-fin-doc-schet-nal-obj.cli-type         = parpayer-type         and
                                                   bopr_arh-fin-doc-schet-nal-obj.cli-code         = parpayer-code         and
                                                   bopr_arh-fin-doc-schet-nal-obj.fin-code-acc     = parpayer-fin-code-acc and
                                                   bopr_arh-fin-doc-schet-nal-obj.curr-code        = parcurr-code          and
                                                   bopr_arh-fin-doc-schet-nal-obj.fin-ext-doc-type = parfin-ext-doc-type   and
                                                   bopr_arh-fin-doc-schet-nal-obj.calc-curr-code   = 0                     and
                                                   bopr_arh-fin-doc-schet-nal-obj.sum-type         = parsum-type           and
                                                   bopr_arh-fin-doc-schet-nal-obj.cashbookid       = parcashbookid         and
                                                   bopr_arh-fin-doc-schet-nal-obj.fact-order       < parfact-order         use-index pi no-error.
    create bfpr_arh-fin-doc-schet-nal-obj.
    assign
      bfpr_arh-fin-doc-schet-nal-obj.host-code        = parhost-code
      bfpr_arh-fin-doc-schet-nal-obj.obj-type         = parobj-type
      bfpr_arh-fin-doc-schet-nal-obj.obj-code         = parobj-code
      bfpr_arh-fin-doc-schet-nal-obj.cli-type         = parpayer-type
      bfpr_arh-fin-doc-schet-nal-obj.cli-code         = parpayer-code
      bfpr_arh-fin-doc-schet-nal-obj.fin-code-acc     = parpayer-fin-code-acc
      bfpr_arh-fin-doc-schet-nal-obj.curr-code        = parcurr-code
      bfpr_arh-fin-doc-schet-nal-obj.fin-ext-doc-type = parfin-ext-doc-type
      bfpr_arh-fin-doc-schet-nal-obj.calc-curr-code   = 0
      bfpr_arh-fin-doc-schet-nal-obj.sum-type         = parsum-type
      bfpr_arh-fin-doc-schet-nal-obj.cource-des       = "r":u
      bfpr_arh-fin-doc-schet-nal-obj.fact-order       = parfact-order
      bfpr_arh-fin-doc-schet-nal-obj.fin-doc-code     = parfin-doc-code
      bfpr_arh-fin-doc-schet-nal-obj.fact-date        = parfact-date
      bfpr_arh-fin-doc-schet-nal-obj.shift-date       = parshift-date
      bfpr_arh-fin-doc-schet-nal-obj.shift-num        = parshift-num
      bfpr_arh-fin-doc-schet-nal-obj.curr-code        = parcurr-code
      bfpr_arh-fin-doc-schet-nal-obj.cashbookid       = parcashbookid
      bfpr_arh-fin-doc-schet-nal-obj.income           = (if available bopr_arh-fin-doc-schet-nal-obj then bopr_arh-fin-doc-schet-nal-obj.income      else 0)
      bfpr_arh-fin-doc-schet-nal-obj.income-vat       = (if available bopr_arh-fin-doc-schet-nal-obj then bopr_arh-fin-doc-schet-nal-obj.income-vat  else 0)
      bfpr_arh-fin-doc-schet-nal-obj.income-slt       = (if available bopr_arh-fin-doc-schet-nal-obj then bopr_arh-fin-doc-schet-nal-obj.income-slt  else 0)
      bfpr_arh-fin-doc-schet-nal-obj.expense          = (if available bopr_arh-fin-doc-schet-nal-obj then bopr_arh-fin-doc-schet-nal-obj.expense     else 0) + parsum-rubl
      bfpr_arh-fin-doc-schet-nal-obj.expense-vat      = (if available bopr_arh-fin-doc-schet-nal-obj then bopr_arh-fin-doc-schet-nal-obj.expense-vat else 0) + parsum-vat-rubl
      bfpr_arh-fin-doc-schet-nal-obj.expense-slt      = (if available bopr_arh-fin-doc-schet-nal-obj then bopr_arh-fin-doc-schet-nal-obj.expense-slt else 0) + parsum-slt-rubl
    .
  end.
  else do:
    find first bfpr_arh-fin-doc-schet-nal-obj where bfpr_arh-fin-doc-schet-nal-obj.host-code        = parhost-code          and
                                                    bfpr_arh-fin-doc-schet-nal-obj.obj-type         = parobj-type           and
                                                    bfpr_arh-fin-doc-schet-nal-obj.obj-code         = parobj-code           and
                                                    bfpr_arh-fin-doc-schet-nal-obj.cli-type         = parpayer-type         and
                                                    bfpr_arh-fin-doc-schet-nal-obj.cli-code         = parpayer-code         and
                                                    bfpr_arh-fin-doc-schet-nal-obj.fin-code-acc     = parpayer-fin-code-acc and
                                                    bfpr_arh-fin-doc-schet-nal-obj.curr-code        = parcurr-code          and
                                                    bfpr_arh-fin-doc-schet-nal-obj.fin-ext-doc-type = parfin-ext-doc-type   and
                                                    bfpr_arh-fin-doc-schet-nal-obj.calc-curr-code   = 0                     and
                                                    bfpr_arh-fin-doc-schet-nal-obj.sum-type         = parsum-type           and
                                                    bfpr_arh-fin-doc-schet-nal-obj.cashbookid       = parcashbookid         and
                                                    bfpr_arh-fin-doc-schet-nal-obj.fact-order       = parfact-order         exclusive-lock.
  end.
  for each rbfpr_arh-fin-doc-schet-nal-obj where rbfpr_arh-fin-doc-schet-nal-obj.host-code        = bfpr_arh-fin-doc-schet-nal-obj.host-code        and
                                                 rbfpr_arh-fin-doc-schet-nal-obj.obj-type         = bfpr_arh-fin-doc-schet-nal-obj.obj-type         and
                                                 rbfpr_arh-fin-doc-schet-nal-obj.obj-code         = bfpr_arh-fin-doc-schet-nal-obj.obj-code         and
                                                 rbfpr_arh-fin-doc-schet-nal-obj.cli-type         = parpayer-type                                   and
                                                 rbfpr_arh-fin-doc-schet-nal-obj.cli-code         = parpayer-code                                   and
                                                 rbfpr_arh-fin-doc-schet-nal-obj.fin-code-acc     = bfpr_arh-fin-doc-schet-nal-obj.fin-code-acc     and
                                                 rbfpr_arh-fin-doc-schet-nal-obj.curr-code        = bfpr_arh-fin-doc-schet-nal-obj.curr-code        and
                                                 rbfpr_arh-fin-doc-schet-nal-obj.fin-ext-doc-type = bfpr_arh-fin-doc-schet-nal-obj.fin-ext-doc-type and
                                                 rbfpr_arh-fin-doc-schet-nal-obj.calc-curr-code   = bfpr_arh-fin-doc-schet-nal-obj.calc-curr-code   and
                                                 rbfpr_arh-fin-doc-schet-nal-obj.sum-type         = bfpr_arh-fin-doc-schet-nal-obj.sum-type         and
                                                 rbfpr_arh-fin-doc-schet-nal-obj.cashbookid       = parcashbookid                                   and
                                                 rbfpr_arh-fin-doc-schet-nal-obj.fact-order       > bfpr_arh-fin-doc-schet-nal-obj.fact-order       use-index pi exclusive-lock on error undo, return error return-value :
    assign
      rbfpr_arh-fin-doc-schet-nal-obj.expense     = rbfpr_arh-fin-doc-schet-nal-obj.expense     + parsum-rubl
      rbfpr_arh-fin-doc-schet-nal-obj.expense-vat = rbfpr_arh-fin-doc-schet-nal-obj.expense-vat + parsum-vat-rubl
      rbfpr_arh-fin-doc-schet-nal-obj.expense-slt = rbfpr_arh-fin-doc-schet-nal-obj.expense-slt + parsum-slt-rubl
    .
  end.
  end.
  if parreceiver-code <> 0 then do:
  if parmode = "close":u then do:
    find last borr_arh-fin-doc-schet-nal-obj where borr_arh-fin-doc-schet-nal-obj.host-code        = parhost-code             and
                                                   borr_arh-fin-doc-schet-nal-obj.obj-type         = parobj-type              and
                                                   borr_arh-fin-doc-schet-nal-obj.obj-code         = parobj-code              and
                                                   borr_arh-fin-doc-schet-nal-obj.cli-type         = parreceiver-type         and
                                                   borr_arh-fin-doc-schet-nal-obj.cli-code         = parreceiver-code         and
                                                   borr_arh-fin-doc-schet-nal-obj.fin-code-acc     = parreceiver-fin-code-acc and
                                                   borr_arh-fin-doc-schet-nal-obj.curr-code        = parcurr-code             and
                                                   borr_arh-fin-doc-schet-nal-obj.fin-ext-doc-type = parfin-ext-doc-type      and
                                                   borr_arh-fin-doc-schet-nal-obj.calc-curr-code   = 0                        and
                                                   borr_arh-fin-doc-schet-nal-obj.sum-type         = parsum-type              and
                                                   borr_arh-fin-doc-schet-nal-obj.cashbookid       = parcashbookid            and
                                                   borr_arh-fin-doc-schet-nal-obj.fact-order       < parfact-order            use-index pi no-error.
    create bfrr_arh-fin-doc-schet-nal-obj.
    assign
      bfrr_arh-fin-doc-schet-nal-obj.host-code        = parhost-code
      bfrr_arh-fin-doc-schet-nal-obj.obj-type         = parobj-type
      bfrr_arh-fin-doc-schet-nal-obj.obj-code         = parobj-code
      bfrr_arh-fin-doc-schet-nal-obj.cli-type         = parreceiver-type
      bfrr_arh-fin-doc-schet-nal-obj.cli-code         = parreceiver-code
      bfrr_arh-fin-doc-schet-nal-obj.fin-code-acc     = parreceiver-fin-code-acc
      bfrr_arh-fin-doc-schet-nal-obj.curr-code        = parcurr-code
      bfrr_arh-fin-doc-schet-nal-obj.fin-ext-doc-type = parfin-ext-doc-type
      bfrr_arh-fin-doc-schet-nal-obj.calc-curr-code   = 0
      bfrr_arh-fin-doc-schet-nal-obj.sum-type         = parsum-type
      bfrr_arh-fin-doc-schet-nal-obj.cource-des       = "r":u
      bfrr_arh-fin-doc-schet-nal-obj.fact-order       = parfact-order
      bfrr_arh-fin-doc-schet-nal-obj.shift-date       = parshift-date
      bfrr_arh-fin-doc-schet-nal-obj.shift-num        = parshift-num
      bfrr_arh-fin-doc-schet-nal-obj.fin-doc-code     = parfin-doc-code
      bfrr_arh-fin-doc-schet-nal-obj.fact-date        = parfact-date
      bfrr_arh-fin-doc-schet-nal-obj.curr-code        = parcurr-code
      bfrr_arh-fin-doc-schet-nal-obj.cashbookid       = parcashbookid
    .
    assign
      bfrr_arh-fin-doc-schet-nal-obj.expense          = (if available borr_arh-fin-doc-schet-nal-obj then borr_arh-fin-doc-schet-nal-obj.expense     else 0)
      bfrr_arh-fin-doc-schet-nal-obj.expense-vat      = (if available borr_arh-fin-doc-schet-nal-obj then borr_arh-fin-doc-schet-nal-obj.expense-vat else 0)
      bfrr_arh-fin-doc-schet-nal-obj.expense-slt      = (if available borr_arh-fin-doc-schet-nal-obj then borr_arh-fin-doc-schet-nal-obj.expense-slt else 0)
      bfrr_arh-fin-doc-schet-nal-obj.income           = (if available borr_arh-fin-doc-schet-nal-obj then borr_arh-fin-doc-schet-nal-obj.income      else 0) + parsum-rubl
      bfrr_arh-fin-doc-schet-nal-obj.income-vat       = (if available borr_arh-fin-doc-schet-nal-obj then borr_arh-fin-doc-schet-nal-obj.income-vat  else 0) + parsum-vat-rubl
      bfrr_arh-fin-doc-schet-nal-obj.income-slt       = (if available borr_arh-fin-doc-schet-nal-obj then borr_arh-fin-doc-schet-nal-obj.income-slt  else 0) + parsum-slt-rubl
    .
  end.
  else do:
    find first bfrr_arh-fin-doc-schet-nal-obj where bfrr_arh-fin-doc-schet-nal-obj.host-code        = parhost-code             and
                                                    bfrr_arh-fin-doc-schet-nal-obj.obj-type         = parobj-type              and
                                                    bfrr_arh-fin-doc-schet-nal-obj.obj-code         = parobj-code              and
                                                    bfrr_arh-fin-doc-schet-nal-obj.cli-type         = parreceiver-type         and
                                                    bfrr_arh-fin-doc-schet-nal-obj.cli-code         = parreceiver-code         and
                                                    bfrr_arh-fin-doc-schet-nal-obj.fin-code-acc     = parreceiver-fin-code-acc and
                                                    bfrr_arh-fin-doc-schet-nal-obj.curr-code        = parcurr-code             and
                                                    bfrr_arh-fin-doc-schet-nal-obj.fin-ext-doc-type = parfin-ext-doc-type      and
                                                    bfrr_arh-fin-doc-schet-nal-obj.calc-curr-code   = 0                        and
                                                    bfrr_arh-fin-doc-schet-nal-obj.sum-type         = parsum-type              and
                                                    bfrr_arh-fin-doc-schet-nal-obj.cashbookid       = parcashbookid            and
                                                    bfrr_arh-fin-doc-schet-nal-obj.fact-order       = parfact-order            exclusive-lock.
  end.
  for each rbfrr_arh-fin-doc-schet-nal-obj where rbfrr_arh-fin-doc-schet-nal-obj.host-code        = bfrr_arh-fin-doc-schet-nal-obj.host-code        and
                                                 rbfrr_arh-fin-doc-schet-nal-obj.obj-type         = bfrr_arh-fin-doc-schet-nal-obj.obj-type         and
                                                 rbfrr_arh-fin-doc-schet-nal-obj.obj-code         = bfrr_arh-fin-doc-schet-nal-obj.obj-code         and
                                                 rbfrr_arh-fin-doc-schet-nal-obj.cli-type         = parreceiver-type                                and
                                                 rbfrr_arh-fin-doc-schet-nal-obj.cli-code         = parreceiver-code                                and
                                                 rbfrr_arh-fin-doc-schet-nal-obj.fin-code-acc     = bfrr_arh-fin-doc-schet-nal-obj.fin-code-acc     and
                                                 rbfrr_arh-fin-doc-schet-nal-obj.curr-code        = bfrr_arh-fin-doc-schet-nal-obj.curr-code        and
                                                 rbfrr_arh-fin-doc-schet-nal-obj.fin-ext-doc-type = bfrr_arh-fin-doc-schet-nal-obj.fin-ext-doc-type and
                                                 rbfrr_arh-fin-doc-schet-nal-obj.calc-curr-code   = bfrr_arh-fin-doc-schet-nal-obj.calc-curr-code   and
                                                 rbfrr_arh-fin-doc-schet-nal-obj.sum-type         = bfrr_arh-fin-doc-schet-nal-obj.sum-type         and
                                                 rbfrr_arh-fin-doc-schet-nal-obj.cashbookid       = parcashbookid                                   and
                                                 rbfrr_arh-fin-doc-schet-nal-obj.fact-order       > bfrr_arh-fin-doc-schet-nal-obj.fact-order       use-index pi exclusive-lock on error undo, return error return-value :
    assign
      rbfrr_arh-fin-doc-schet-nal-obj.income     = rbfrr_arh-fin-doc-schet-nal-obj.income     + parsum-doc
      rbfrr_arh-fin-doc-schet-nal-obj.income-vat = rbfrr_arh-fin-doc-schet-nal-obj.income-vat + parsum-vat-doc
      rbfrr_arh-fin-doc-schet-nal-obj.income-slt = rbfrr_arh-fin-doc-schet-nal-obj.income-slt + parsum-slt-doc
    .
  end.
  if parmode = "delete":u then do:
    if parpayer-code <> 0 then do:
    delete bfpr_arh-fin-doc-schet-nal-obj.
    end.
    if parreceiver-code <> 0 then do:
    delete bfrr_arh-fin-doc-schet-nal-obj.
  end.
end.
  end.
end.
if parbase-code <> parcurr-code and
   parbase-code <> 0            then do:
  if parpayer-code <> 0 then do:
  if parmode = "close":u then do:
    find last bopb_arh-fin-doc-schet-nal-obj where bopb_arh-fin-doc-schet-nal-obj.host-code        = parhost-code          and
                                                   bopb_arh-fin-doc-schet-nal-obj.obj-type         = parobj-type           and
                                                   bopb_arh-fin-doc-schet-nal-obj.obj-code         = parobj-code           and
                                                   bopb_arh-fin-doc-schet-nal-obj.cli-type         = parpayer-type         and
                                                   bopb_arh-fin-doc-schet-nal-obj.cli-code         = parpayer-code         and
                                                   bopb_arh-fin-doc-schet-nal-obj.fin-code-acc     = parpayer-fin-code-acc and
                                                   bopb_arh-fin-doc-schet-nal-obj.curr-code        = parcurr-code          and
                                                   bopb_arh-fin-doc-schet-nal-obj.fin-ext-doc-type = parfin-ext-doc-type   and
                                                   bopb_arh-fin-doc-schet-nal-obj.calc-curr-code   = parbase-code          and
                                                   bopb_arh-fin-doc-schet-nal-obj.sum-type         = parsum-type           and
                                                   bopb_arh-fin-doc-schet-nal-obj.cashbookid       = parcashbookid         and
                                                   bopb_arh-fin-doc-schet-nal-obj.fact-order       < parfact-order         use-index pi no-error.
    create bfpb_arh-fin-doc-schet-nal-obj.
    assign
      bfpb_arh-fin-doc-schet-nal-obj.host-code        = parhost-code
      bfpb_arh-fin-doc-schet-nal-obj.obj-type         = parobj-type
      bfpb_arh-fin-doc-schet-nal-obj.obj-code         = parobj-code
      bfpb_arh-fin-doc-schet-nal-obj.cli-type         = parpayer-type
      bfpb_arh-fin-doc-schet-nal-obj.cli-code         = parpayer-code
      bfpb_arh-fin-doc-schet-nal-obj.fin-code-acc     = parpayer-fin-code-acc
      bfpb_arh-fin-doc-schet-nal-obj.curr-code        = parcurr-code
      bfpb_arh-fin-doc-schet-nal-obj.fin-ext-doc-type = parfin-ext-doc-type
      bfpb_arh-fin-doc-schet-nal-obj.calc-curr-code   = parbase-code
      bfpb_arh-fin-doc-schet-nal-obj.sum-type         = parsum-type
      bfpb_arh-fin-doc-schet-nal-obj.cource-des       = "b":u
      bfpb_arh-fin-doc-schet-nal-obj.fact-order       = parfact-order
      bfpb_arh-fin-doc-schet-nal-obj.shift-date       = parshift-date
      bfpb_arh-fin-doc-schet-nal-obj.shift-num        = parshift-num
      bfpb_arh-fin-doc-schet-nal-obj.fin-doc-code     = parfin-doc-code
      bfpb_arh-fin-doc-schet-nal-obj.fact-date        = parfact-date
      bfpb_arh-fin-doc-schet-nal-obj.curr-code        = parcurr-code
      bfpb_arh-fin-doc-schet-nal-obj.cashbookid       = parcashbookid
      bfpb_arh-fin-doc-schet-nal-obj.income           = (if available bopb_arh-fin-doc-schet-nal-obj then bopb_arh-fin-doc-schet-nal-obj.income      else 0)
      bfpb_arh-fin-doc-schet-nal-obj.income-vat       = (if available bopb_arh-fin-doc-schet-nal-obj then bopb_arh-fin-doc-schet-nal-obj.income-vat  else 0)
      bfpb_arh-fin-doc-schet-nal-obj.income-slt       = (if available bopb_arh-fin-doc-schet-nal-obj then bopb_arh-fin-doc-schet-nal-obj.income-slt  else 0)
      bfpb_arh-fin-doc-schet-nal-obj.expense          = (if available bopb_arh-fin-doc-schet-nal-obj then bopb_arh-fin-doc-schet-nal-obj.expense     else 0) + parsum-base
      bfpb_arh-fin-doc-schet-nal-obj.expense-vat      = (if available bopb_arh-fin-doc-schet-nal-obj then bopb_arh-fin-doc-schet-nal-obj.expense-vat else 0) + parsum-vat-base
      bfpb_arh-fin-doc-schet-nal-obj.expense-slt      = (if available bopb_arh-fin-doc-schet-nal-obj then bopb_arh-fin-doc-schet-nal-obj.expense-slt else 0) + parsum-slt-base
    .
  end.
  else do:
    find first bfpb_arh-fin-doc-schet-nal-obj where bfpb_arh-fin-doc-schet-nal-obj.host-code        = parhost-code          and
                                                    bfpb_arh-fin-doc-schet-nal-obj.obj-type         = parobj-type           and
                                                    bfpb_arh-fin-doc-schet-nal-obj.obj-code         = parobj-code           and
                                                    bfpb_arh-fin-doc-schet-nal-obj.cli-type         = parpayer-type         and
                                                    bfpb_arh-fin-doc-schet-nal-obj.cli-code         = parpayer-code         and
                                                    bfpb_arh-fin-doc-schet-nal-obj.fin-code-acc     = parpayer-fin-code-acc and
                                                    bfpb_arh-fin-doc-schet-nal-obj.curr-code        = parcurr-code          and
                                                    bfpb_arh-fin-doc-schet-nal-obj.fin-ext-doc-type = parfin-ext-doc-type   and
                                                    bfpb_arh-fin-doc-schet-nal-obj.calc-curr-code   = parbase-code          and
                                                    bfpb_arh-fin-doc-schet-nal-obj.sum-type         = parsum-type           and
                                                    bfpb_arh-fin-doc-schet-nal-obj.cashbookid       = parcashbookid         and
                                                    bfpb_arh-fin-doc-schet-nal-obj.fact-order       = parfact-order         exclusive-lock.
  end.
  for each rbfpb_arh-fin-doc-schet-nal-obj where rbfpb_arh-fin-doc-schet-nal-obj.host-code        = bfpb_arh-fin-doc-schet-nal-obj.host-code        and
                                                 rbfpb_arh-fin-doc-schet-nal-obj.obj-type         = bfpb_arh-fin-doc-schet-nal-obj.obj-type         and
                                                 rbfpb_arh-fin-doc-schet-nal-obj.obj-code         = bfpb_arh-fin-doc-schet-nal-obj.obj-code         and
                                                 rbfpb_arh-fin-doc-schet-nal-obj.cli-type         = parpayer-type                                   and
                                                 rbfpb_arh-fin-doc-schet-nal-obj.cli-code         = parpayer-code                                   and
                                                 rbfpb_arh-fin-doc-schet-nal-obj.fin-code-acc     = bfpb_arh-fin-doc-schet-nal-obj.fin-code-acc     and
                                                 rbfpb_arh-fin-doc-schet-nal-obj.curr-code        = bfpb_arh-fin-doc-schet-nal-obj.curr-code        and
                                                 rbfpb_arh-fin-doc-schet-nal-obj.fin-ext-doc-type = bfpb_arh-fin-doc-schet-nal-obj.fin-ext-doc-type and
                                                 rbfpb_arh-fin-doc-schet-nal-obj.calc-curr-code   = bfpb_arh-fin-doc-schet-nal-obj.calc-curr-code   and
                                                 rbfpb_arh-fin-doc-schet-nal-obj.sum-type         = bfpb_arh-fin-doc-schet-nal-obj.sum-type         and
                                                 rbfpb_arh-fin-doc-schet-nal-obj.cashbookid       = parcashbookid                                   and
                                                 rbfpb_arh-fin-doc-schet-nal-obj.fact-order       > bfpb_arh-fin-doc-schet-nal-obj.fact-order       use-index pi exclusive-lock on error undo, return error return-value :
    assign
      rbfpb_arh-fin-doc-schet-nal-obj.expense     = rbfpb_arh-fin-doc-schet-nal-obj.expense     + parsum-base
      rbfpb_arh-fin-doc-schet-nal-obj.expense-vat = rbfpb_arh-fin-doc-schet-nal-obj.expense-vat + parsum-vat-base
      rbfpb_arh-fin-doc-schet-nal-obj.expense-slt = rbfpb_arh-fin-doc-schet-nal-obj.expense-slt + parsum-slt-base
    .
  end.
  end.
  if parreceiver-code <> 0 then do:
  if parmode = "close":u then do:
    find last borb_arh-fin-doc-schet-nal-obj where borb_arh-fin-doc-schet-nal-obj.host-code        = parhost-code             and
                                                   borb_arh-fin-doc-schet-nal-obj.obj-type         = parobj-type              and
                                                   borb_arh-fin-doc-schet-nal-obj.obj-code         = parobj-code              and
                                                   borb_arh-fin-doc-schet-nal-obj.cli-type         = parreceiver-type         and
                                                   borb_arh-fin-doc-schet-nal-obj.cli-code         = parreceiver-code         and
                                                   borb_arh-fin-doc-schet-nal-obj.fin-code-acc     = parreceiver-fin-code-acc and
                                                   borb_arh-fin-doc-schet-nal-obj.curr-code        = parcurr-code             and
                                                   borb_arh-fin-doc-schet-nal-obj.fin-ext-doc-type = parfin-ext-doc-type      and
                                                   borb_arh-fin-doc-schet-nal-obj.calc-curr-code   = parbase-code             and
                                                   borb_arh-fin-doc-schet-nal-obj.sum-type         = parsum-type              and
                                                   borb_arh-fin-doc-schet-nal-obj.cashbookid       = parcashbookid            and
                                                   borb_arh-fin-doc-schet-nal-obj.fact-order       < parfact-order            use-index pi no-error.
    create bfrb_arh-fin-doc-schet-nal-obj.
    assign
      bfrb_arh-fin-doc-schet-nal-obj.host-code        = parhost-code
      bfrb_arh-fin-doc-schet-nal-obj.obj-type         = parobj-type
      bfrb_arh-fin-doc-schet-nal-obj.obj-code         = parobj-code
      bfrb_arh-fin-doc-schet-nal-obj.cli-type         = parreceiver-type
      bfrb_arh-fin-doc-schet-nal-obj.cli-code         = parreceiver-code
      bfrb_arh-fin-doc-schet-nal-obj.fin-code-acc     = parreceiver-fin-code-acc
      bfrb_arh-fin-doc-schet-nal-obj.curr-code        = parcurr-code
      bfrb_arh-fin-doc-schet-nal-obj.fin-ext-doc-type = parfin-ext-doc-type
      bfrb_arh-fin-doc-schet-nal-obj.calc-curr-code   = parbase-code
      bfrb_arh-fin-doc-schet-nal-obj.sum-type         = parsum-type
      bfrb_arh-fin-doc-schet-nal-obj.cource-des       = "b":u
      bfrb_arh-fin-doc-schet-nal-obj.fact-order       = parfact-order
      bfrb_arh-fin-doc-schet-nal-obj.shift-date       = parshift-date
      bfrb_arh-fin-doc-schet-nal-obj.shift-num        = parshift-num
      bfrb_arh-fin-doc-schet-nal-obj.fin-doc-code     = parfin-doc-code
      bfrb_arh-fin-doc-schet-nal-obj.fact-date        = parfact-date
      bfrb_arh-fin-doc-schet-nal-obj.curr-code        = parcurr-code
      bfrb_arh-fin-doc-schet-nal-obj.cashbookid       = parcashbookid
    .
    assign
      bfrb_arh-fin-doc-schet-nal-obj.expense          = (if available borb_arh-fin-doc-schet-nal-obj then borb_arh-fin-doc-schet-nal-obj.expense     else 0)
      bfrb_arh-fin-doc-schet-nal-obj.expense-vat      = (if available borb_arh-fin-doc-schet-nal-obj then borb_arh-fin-doc-schet-nal-obj.expense-vat else 0)
      bfrb_arh-fin-doc-schet-nal-obj.expense-slt      = (if available borb_arh-fin-doc-schet-nal-obj then borb_arh-fin-doc-schet-nal-obj.expense-slt else 0)
      bfrb_arh-fin-doc-schet-nal-obj.income           = (if available borb_arh-fin-doc-schet-nal-obj then borb_arh-fin-doc-schet-nal-obj.income      else 0) + parsum-base
      bfrb_arh-fin-doc-schet-nal-obj.income-vat       = (if available borb_arh-fin-doc-schet-nal-obj then borb_arh-fin-doc-schet-nal-obj.income-vat  else 0) + parsum-vat-base
      bfrb_arh-fin-doc-schet-nal-obj.income-slt       = (if available borb_arh-fin-doc-schet-nal-obj then borb_arh-fin-doc-schet-nal-obj.income-slt  else 0) + parsum-slt-base
    .
  end.
  else do:
    find first bfrb_arh-fin-doc-schet-nal-obj where bfrb_arh-fin-doc-schet-nal-obj.host-code        = parhost-code             and
                                                    bfrb_arh-fin-doc-schet-nal-obj.obj-type         = parobj-type              and
                                                    bfrb_arh-fin-doc-schet-nal-obj.obj-code         = parobj-code              and
                                                    bfrb_arh-fin-doc-schet-nal-obj.cli-type         = parreceiver-type         and
                                                    bfrb_arh-fin-doc-schet-nal-obj.cli-code         = parreceiver-code         and
                                                    bfrb_arh-fin-doc-schet-nal-obj.fin-code-acc     = parreceiver-fin-code-acc and
                                                    bfrb_arh-fin-doc-schet-nal-obj.curr-code        = parcurr-code             and
                                                    bfrb_arh-fin-doc-schet-nal-obj.fin-ext-doc-type = parfin-ext-doc-type      and
                                                    bfrb_arh-fin-doc-schet-nal-obj.calc-curr-code   = parbase-code             and
                                                    bfrb_arh-fin-doc-schet-nal-obj.sum-type         = parsum-type              and
                                                    bfrb_arh-fin-doc-schet-nal-obj.cashbookid       = parcashbookid            and
                                                    bfrb_arh-fin-doc-schet-nal-obj.fact-order       = parfact-order            exclusive-lock.
  end.
  for each rbfrb_arh-fin-doc-schet-nal-obj where rbfrb_arh-fin-doc-schet-nal-obj.host-code        = bfrb_arh-fin-doc-schet-nal-obj.host-code        and
                                                 rbfrb_arh-fin-doc-schet-nal-obj.obj-type         = bfrb_arh-fin-doc-schet-nal-obj.obj-type         and
                                                 rbfrb_arh-fin-doc-schet-nal-obj.obj-code         = bfrb_arh-fin-doc-schet-nal-obj.obj-code         and
                                                 rbfrb_arh-fin-doc-schet-nal-obj.cli-type         = parreceiver-type                                and
                                                 rbfrb_arh-fin-doc-schet-nal-obj.cli-code         = parreceiver-code                                and
                                                 rbfrb_arh-fin-doc-schet-nal-obj.fin-code-acc     = bfrb_arh-fin-doc-schet-nal-obj.fin-code-acc     and
                                                 rbfrb_arh-fin-doc-schet-nal-obj.curr-code        = bfrb_arh-fin-doc-schet-nal-obj.curr-code        and
                                                 rbfrb_arh-fin-doc-schet-nal-obj.fin-ext-doc-type = bfrb_arh-fin-doc-schet-nal-obj.fin-ext-doc-type and
                                                 rbfrb_arh-fin-doc-schet-nal-obj.calc-curr-code   = bfrb_arh-fin-doc-schet-nal-obj.calc-curr-code   and
                                                 rbfrb_arh-fin-doc-schet-nal-obj.sum-type         = bfrb_arh-fin-doc-schet-nal-obj.sum-type         and
                                                 rbfrb_arh-fin-doc-schet-nal-obj.cashbookid       = parcashbookid                                   and
                                                 rbfrb_arh-fin-doc-schet-nal-obj.fact-order       > bfrb_arh-fin-doc-schet-nal-obj.fact-order       use-index pi exclusive-lock on error undo, return error return-value :
    assign
      rbfrb_arh-fin-doc-schet-nal-obj.income     = rbfrb_arh-fin-doc-schet-nal-obj.income     + parsum-base
      rbfrb_arh-fin-doc-schet-nal-obj.income-vat = rbfrb_arh-fin-doc-schet-nal-obj.income-vat + parsum-vat-base
      rbfrb_arh-fin-doc-schet-nal-obj.income-slt = rbfrb_arh-fin-doc-schet-nal-obj.income-slt + parsum-slt-base
    .
  end.
  end.
  if parmode = "delete":u then do:
    if parpayer-code <> 0 then do:
    delete bfpb_arh-fin-doc-schet-nal-obj.
    end.
    if parreceiver-code <> 0 then do:
    delete bfrb_arh-fin-doc-schet-nal-obj.
  end.
end.
end.
end.
end procedure.
procedure libfarpo_calc-arh-fin-doc-schet-tax-obj :
define input parameter parmode                    as   character                   no-undo.
define input parameter parhost-code               like ub.fin-doc.host-code        no-undo.
define input parameter parobj-type                like ub.fin-doc.obj-type         no-undo.
define input parameter parobj-code                like ub.fin-doc.obj-code         no-undo.
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
define buffer bfps_arh-fin-doc-schet-tax-obj  for ub.arh-fin-doc-schet-tax-obj.
define buffer bfrs_arh-fin-doc-schet-tax-obj  for ub.arh-fin-doc-schet-tax-obj.
define buffer rbfps_arh-fin-doc-schet-tax-obj for ub.arh-fin-doc-schet-tax-obj.
define buffer rbfrs_arh-fin-doc-schet-tax-obj for ub.arh-fin-doc-schet-tax-obj.
define buffer bops_arh-fin-doc-schet-tax-obj  for ub.arh-fin-doc-schet-tax-obj.
define buffer bors_arh-fin-doc-schet-tax-obj  for ub.arh-fin-doc-schet-tax-obj.
define buffer bfpr_arh-fin-doc-schet-tax-obj  for ub.arh-fin-doc-schet-tax-obj.
define buffer bfrr_arh-fin-doc-schet-tax-obj  for ub.arh-fin-doc-schet-tax-obj.
define buffer rbfpr_arh-fin-doc-schet-tax-obj for ub.arh-fin-doc-schet-tax-obj.
define buffer rbfrr_arh-fin-doc-schet-tax-obj for ub.arh-fin-doc-schet-tax-obj.
define buffer bopr_arh-fin-doc-schet-tax-obj  for ub.arh-fin-doc-schet-tax-obj.
define buffer borr_arh-fin-doc-schet-tax-obj  for ub.arh-fin-doc-schet-tax-obj.
define buffer bfpb_arh-fin-doc-schet-tax-obj  for ub.arh-fin-doc-schet-tax-obj.
define buffer bfrb_arh-fin-doc-schet-tax-obj  for ub.arh-fin-doc-schet-tax-obj.
define buffer rbfpb_arh-fin-doc-schet-tax-obj for ub.arh-fin-doc-schet-tax-obj.
define buffer rbfrb_arh-fin-doc-schet-tax-obj for ub.arh-fin-doc-schet-tax-obj.
define buffer bopb_arh-fin-doc-schet-tax-obj  for ub.arh-fin-doc-schet-tax-obj.
define buffer borb_arh-fin-doc-schet-tax-obj  for ub.arh-fin-doc-schet-tax-obj.
define buffer bfpc_arh-fin-doc-schet-tax-obj  for ub.arh-fin-doc-schet-tax-obj.
define buffer bfrc_arh-fin-doc-schet-tax-obj  for ub.arh-fin-doc-schet-tax-obj.
define buffer rbfpc_arh-fin-doc-schet-tax-obj for ub.arh-fin-doc-schet-tax-obj.
define buffer rbfrc_arh-fin-doc-schet-tax-obj for ub.arh-fin-doc-schet-tax-obj.
define buffer bopc_arh-fin-doc-schet-tax-obj  for ub.arh-fin-doc-schet-tax-obj.
define buffer borc_arh-fin-doc-schet-tax-obj  for ub.arh-fin-doc-schet-tax-obj.
do on error undo, return error substitute ("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
if parmode = "close":u then do:
  find last bops_arh-fin-doc-schet-tax-obj where bops_arh-fin-doc-schet-tax-obj.host-code        = parhost-code         and
                                                 bops_arh-fin-doc-schet-tax-obj.obj-type         = parobj-type          and
                                                 bops_arh-fin-doc-schet-tax-obj.obj-code         = parobj-code          and
                                                 bops_arh-fin-doc-schet-tax-obj.cli-type         = parpayer-type        and
                                                 bops_arh-fin-doc-schet-tax-obj.cli-code         = parpayer-code        and
                                                 bops_arh-fin-doc-schet-tax-obj.code-schet       = parpayer-code-schet  and
                                                 bops_arh-fin-doc-schet-tax-obj.fin-ext-doc-type = parfin-ext-doc-type  and
                                                 bops_arh-fin-doc-schet-tax-obj.calc-curr-code   = parcurr-code         and
                                                 bops_arh-fin-doc-schet-tax-obj.vat-pc           = parvat-pc            and
                                                 bops_arh-fin-doc-schet-tax-obj.slt-pc           = parslt-pc            and
                                                 bops_arh-fin-doc-schet-tax-obj.with-vat         = parwith-vat          and
                                                 bops_arh-fin-doc-schet-tax-obj.with-slt         = parwith-slt          and
                                                 bops_arh-fin-doc-schet-tax-obj.sum-type         = parsum-type          and
                                                 bops_arh-fin-doc-schet-tax-obj.fact-order       < parfact-order        use-index pi no-error.
  create bfps_arh-fin-doc-schet-tax-obj.
  assign
    bfps_arh-fin-doc-schet-tax-obj.host-code        = parhost-code
    bfps_arh-fin-doc-schet-tax-obj.obj-type         = parobj-type
    bfps_arh-fin-doc-schet-tax-obj.obj-code         = parobj-code
    bfps_arh-fin-doc-schet-tax-obj.cli-type         = parpayer-type
    bfps_arh-fin-doc-schet-tax-obj.cli-code         = parpayer-code
    bfps_arh-fin-doc-schet-tax-obj.code-schet       = parpayer-code-schet
    bfps_arh-fin-doc-schet-tax-obj.fin-ext-doc-type = parfin-ext-doc-type
    bfps_arh-fin-doc-schet-tax-obj.calc-curr-code   = parcurr-code
    bfps_arh-fin-doc-schet-tax-obj.vat-pc           = parvat-pc
    bfps_arh-fin-doc-schet-tax-obj.slt-pc           = parslt-pc
    bfps_arh-fin-doc-schet-tax-obj.with-vat         = parwith-vat
    bfps_arh-fin-doc-schet-tax-obj.with-slt         = parwith-slt
    bfps_arh-fin-doc-schet-tax-obj.sum-type         = parsum-type
    bfps_arh-fin-doc-schet-tax-obj.cource-des       = "s":u
    bfps_arh-fin-doc-schet-tax-obj.fact-order       = parfact-order
    bfps_arh-fin-doc-schet-tax-obj.fin-doc-code     = parfin-doc-code
    bfps_arh-fin-doc-schet-tax-obj.fact-date        = parfact-date
    bfps_arh-fin-doc-schet-tax-obj.curr-code        = parcurr-code
    bfps_arh-fin-doc-schet-tax-obj.income           = (if available bops_arh-fin-doc-schet-tax-obj then bops_arh-fin-doc-schet-tax-obj.income      else 0)
    bfps_arh-fin-doc-schet-tax-obj.income-vat       = (if available bops_arh-fin-doc-schet-tax-obj then bops_arh-fin-doc-schet-tax-obj.income-vat  else 0)
    bfps_arh-fin-doc-schet-tax-obj.income-slt       = (if available bops_arh-fin-doc-schet-tax-obj then bops_arh-fin-doc-schet-tax-obj.income-slt  else 0)
    bfps_arh-fin-doc-schet-tax-obj.expense          = (if available bops_arh-fin-doc-schet-tax-obj then bops_arh-fin-doc-schet-tax-obj.expense     else 0) + parsum-doc
    bfps_arh-fin-doc-schet-tax-obj.expense-vat      = (if available bops_arh-fin-doc-schet-tax-obj then bops_arh-fin-doc-schet-tax-obj.expense-vat else 0) + parsum-vat-doc
    bfps_arh-fin-doc-schet-tax-obj.expense-slt      = (if available bops_arh-fin-doc-schet-tax-obj then bops_arh-fin-doc-schet-tax-obj.expense-slt else 0) + parsum-slt-doc
  .
end.
else do:
  find first bfps_arh-fin-doc-schet-tax-obj where bfps_arh-fin-doc-schet-tax-obj.host-code        = parhost-code         and
                                                  bfps_arh-fin-doc-schet-tax-obj.obj-type         = parobj-type          and
                                                  bfps_arh-fin-doc-schet-tax-obj.obj-code         = parobj-code          and
                                                  bfps_arh-fin-doc-schet-tax-obj.cli-type         = parpayer-type        and
                                                  bfps_arh-fin-doc-schet-tax-obj.cli-code         = parpayer-code        and
                                                  bfps_arh-fin-doc-schet-tax-obj.code-schet       = parpayer-code-schet  and
                                                  bfps_arh-fin-doc-schet-tax-obj.fin-ext-doc-type = parfin-ext-doc-type  and
                                                  bfps_arh-fin-doc-schet-tax-obj.calc-curr-code   = parcurr-code         and
                                                  bfps_arh-fin-doc-schet-tax-obj.vat-pc           = parvat-pc            and
                                                  bfps_arh-fin-doc-schet-tax-obj.slt-pc           = parslt-pc            and
                                                  bfps_arh-fin-doc-schet-tax-obj.with-vat         = parwith-vat          and
                                                  bfps_arh-fin-doc-schet-tax-obj.with-slt         = parwith-slt          and
                                                  bfps_arh-fin-doc-schet-tax-obj.sum-type         = parsum-type          and
                                                  bfps_arh-fin-doc-schet-tax-obj.fact-order       = parfact-order        exclusive-lock.
end.
for each rbfps_arh-fin-doc-schet-tax-obj where rbfps_arh-fin-doc-schet-tax-obj.host-code        = bfps_arh-fin-doc-schet-tax-obj.host-code        and
                                               rbfps_arh-fin-doc-schet-tax-obj.obj-type         = bfps_arh-fin-doc-schet-tax-obj.obj-type         and
                                               rbfps_arh-fin-doc-schet-tax-obj.obj-code         = bfps_arh-fin-doc-schet-tax-obj.obj-code         and
                                               rbfps_arh-fin-doc-schet-tax-obj.cli-type         = parpayer-type                                   and
                                               rbfps_arh-fin-doc-schet-tax-obj.cli-code         = parpayer-code                                   and
                                               rbfps_arh-fin-doc-schet-tax-obj.code-schet       = bfps_arh-fin-doc-schet-tax-obj.code-schet       and
                                               rbfps_arh-fin-doc-schet-tax-obj.fin-ext-doc-type = bfps_arh-fin-doc-schet-tax-obj.fin-ext-doc-type and
                                               rbfps_arh-fin-doc-schet-tax-obj.calc-curr-code   = bfps_arh-fin-doc-schet-tax-obj.calc-curr-code   and
                                               rbfps_arh-fin-doc-schet-tax-obj.vat-pc           = bfps_arh-fin-doc-schet-tax-obj.vat-pc           and
                                               rbfps_arh-fin-doc-schet-tax-obj.slt-pc           = bfps_arh-fin-doc-schet-tax-obj.slt-pc           and
                                               rbfps_arh-fin-doc-schet-tax-obj.with-vat         = bfps_arh-fin-doc-schet-tax-obj.with-vat         and
                                               rbfps_arh-fin-doc-schet-tax-obj.with-slt         = bfps_arh-fin-doc-schet-tax-obj.with-slt         and
                                               rbfps_arh-fin-doc-schet-tax-obj.sum-type         = bfps_arh-fin-doc-schet-tax-obj.sum-type         and
                                               rbfps_arh-fin-doc-schet-tax-obj.fact-order       > bfps_arh-fin-doc-schet-tax-obj.fact-order       use-index pi exclusive-lock on error undo, return error return-value :
  assign
    rbfps_arh-fin-doc-schet-tax-obj.expense     = rbfps_arh-fin-doc-schet-tax-obj.expense     + parsum-doc
    rbfps_arh-fin-doc-schet-tax-obj.expense-vat = rbfps_arh-fin-doc-schet-tax-obj.expense-vat + parsum-vat-doc
    rbfps_arh-fin-doc-schet-tax-obj.expense-slt = rbfps_arh-fin-doc-schet-tax-obj.expense-slt + parsum-slt-doc
  .
end.
if parmode = "close":u then do:
  find last bors_arh-fin-doc-schet-tax-obj where bors_arh-fin-doc-schet-tax-obj.host-code         = parhost-code           and
                                                 bors_arh-fin-doc-schet-tax-obj.obj-type          = parobj-type            and
                                                 bors_arh-fin-doc-schet-tax-obj.obj-code          = parobj-code            and
                                                 bors_arh-fin-doc-schet-tax-obj.cli-type          = parreceiver-type       and
                                                 bors_arh-fin-doc-schet-tax-obj.cli-code          = parreceiver-code       and
                                                 bors_arh-fin-doc-schet-tax-obj.code-schet        = parreceiver-code-schet and
                                                 bors_arh-fin-doc-schet-tax-obj.fin-ext-doc-type  = parfin-ext-doc-type    and
                                                 bors_arh-fin-doc-schet-tax-obj.calc-curr-code    = parcurr-code           and
                                                 bors_arh-fin-doc-schet-tax-obj.vat-pc            = parvat-pc              and
                                                 bors_arh-fin-doc-schet-tax-obj.slt-pc            = parslt-pc              and
                                                 bors_arh-fin-doc-schet-tax-obj.with-vat          = parwith-vat            and
                                                 bors_arh-fin-doc-schet-tax-obj.with-slt          = parwith-slt            and
                                                 bors_arh-fin-doc-schet-tax-obj.sum-type          = parsum-type            and
                                                 bors_arh-fin-doc-schet-tax-obj.fact-order        < parfact-order          use-index pi no-error.
  create bfrs_arh-fin-doc-schet-tax-obj.
  assign
    bfrs_arh-fin-doc-schet-tax-obj.host-code        = parhost-code
    bfrs_arh-fin-doc-schet-tax-obj.obj-type         = parobj-type
    bfrs_arh-fin-doc-schet-tax-obj.obj-code         = parobj-code
    bfrs_arh-fin-doc-schet-tax-obj.cli-type         = parreceiver-type
    bfrs_arh-fin-doc-schet-tax-obj.cli-code         = parreceiver-code
    bfrs_arh-fin-doc-schet-tax-obj.code-schet       = parreceiver-code-schet
    bfrs_arh-fin-doc-schet-tax-obj.fin-ext-doc-type = parfin-ext-doc-type
    bfrs_arh-fin-doc-schet-tax-obj.calc-curr-code   = parcurr-code
    bfrs_arh-fin-doc-schet-tax-obj.vat-pc           = parvat-pc
    bfrs_arh-fin-doc-schet-tax-obj.slt-pc           = parslt-pc
    bfrs_arh-fin-doc-schet-tax-obj.with-vat         = parwith-vat
    bfrs_arh-fin-doc-schet-tax-obj.with-slt         = parwith-slt
    bfrs_arh-fin-doc-schet-tax-obj.sum-type         = parsum-type
    bfrs_arh-fin-doc-schet-tax-obj.cource-des       = "s":u
    bfrs_arh-fin-doc-schet-tax-obj.fact-order       = parfact-order
    bfrs_arh-fin-doc-schet-tax-obj.fin-doc-code     = parfin-doc-code
    bfrs_arh-fin-doc-schet-tax-obj.fact-date        = parfact-date
    bfrs_arh-fin-doc-schet-tax-obj.curr-code        = parcurr-code
  .
  assign
    bfrs_arh-fin-doc-schet-tax-obj.expense          = (if available bors_arh-fin-doc-schet-tax-obj then bors_arh-fin-doc-schet-tax-obj.expense     else 0)
    bfrs_arh-fin-doc-schet-tax-obj.expense-vat      = (if available bors_arh-fin-doc-schet-tax-obj then bors_arh-fin-doc-schet-tax-obj.expense-vat else 0)
    bfrs_arh-fin-doc-schet-tax-obj.expense-slt      = (if available bors_arh-fin-doc-schet-tax-obj then bors_arh-fin-doc-schet-tax-obj.expense-slt else 0)
    bfrs_arh-fin-doc-schet-tax-obj.income           = (if available bors_arh-fin-doc-schet-tax-obj then bors_arh-fin-doc-schet-tax-obj.income      else 0) + parsum-doc
    bfrs_arh-fin-doc-schet-tax-obj.income-vat       = (if available bors_arh-fin-doc-schet-tax-obj then bors_arh-fin-doc-schet-tax-obj.income-vat  else 0) + parsum-vat-doc
    bfrs_arh-fin-doc-schet-tax-obj.income-slt       = (if available bors_arh-fin-doc-schet-tax-obj then bors_arh-fin-doc-schet-tax-obj.income-slt  else 0) + parsum-slt-doc
  .
end.
else do:
  find first bfrs_arh-fin-doc-schet-tax-obj where bfrs_arh-fin-doc-schet-tax-obj.host-code         = parhost-code           and
                                                  bfrs_arh-fin-doc-schet-tax-obj.obj-type          = parobj-type            and
                                                  bfrs_arh-fin-doc-schet-tax-obj.obj-code          = parobj-code            and
                                                  bfrs_arh-fin-doc-schet-tax-obj.cli-type          = parreceiver-type       and
                                                  bfrs_arh-fin-doc-schet-tax-obj.cli-code          = parreceiver-code       and
                                                  bfrs_arh-fin-doc-schet-tax-obj.code-schet        = parreceiver-code-schet and
                                                  bfrs_arh-fin-doc-schet-tax-obj.fin-ext-doc-type  = parfin-ext-doc-type    and
                                                  bfrs_arh-fin-doc-schet-tax-obj.calc-curr-code    = parcurr-code           and
                                                  bfrs_arh-fin-doc-schet-tax-obj.vat-pc            = parvat-pc              and
                                                  bfrs_arh-fin-doc-schet-tax-obj.slt-pc            = parslt-pc              and
                                                  bfrs_arh-fin-doc-schet-tax-obj.with-vat          = parwith-vat            and
                                                  bfrs_arh-fin-doc-schet-tax-obj.with-slt          = parwith-slt            and
                                                  bfrs_arh-fin-doc-schet-tax-obj.sum-type          = parsum-type            and
                                                  bfrs_arh-fin-doc-schet-tax-obj.fact-order        = parfact-order          exclusive-lock.
end.
for each rbfrs_arh-fin-doc-schet-tax-obj where rbfrs_arh-fin-doc-schet-tax-obj.host-code        = bfrs_arh-fin-doc-schet-tax-obj.host-code        and
                                               rbfrs_arh-fin-doc-schet-tax-obj.obj-type         = bfrs_arh-fin-doc-schet-tax-obj.obj-type         and
                                               rbfrs_arh-fin-doc-schet-tax-obj.obj-code         = bfrs_arh-fin-doc-schet-tax-obj.obj-code         and
                                               rbfrs_arh-fin-doc-schet-tax-obj.cli-type         = parreceiver-type                                and
                                               rbfrs_arh-fin-doc-schet-tax-obj.cli-code         = parreceiver-code                                and
                                               rbfrs_arh-fin-doc-schet-tax-obj.code-schet       = bfrs_arh-fin-doc-schet-tax-obj.code-schet       and
                                               rbfrs_arh-fin-doc-schet-tax-obj.fin-ext-doc-type = bfrs_arh-fin-doc-schet-tax-obj.fin-ext-doc-type and
                                               rbfrs_arh-fin-doc-schet-tax-obj.calc-curr-code   = bfrs_arh-fin-doc-schet-tax-obj.calc-curr-code   and
                                               rbfrs_arh-fin-doc-schet-tax-obj.vat-pc           = bfrs_arh-fin-doc-schet-tax-obj.vat-pc           and
                                               rbfrs_arh-fin-doc-schet-tax-obj.slt-pc           = bfrs_arh-fin-doc-schet-tax-obj.slt-pc           and
                                               rbfrs_arh-fin-doc-schet-tax-obj.with-vat         = bfrs_arh-fin-doc-schet-tax-obj.with-vat         and
                                               rbfrs_arh-fin-doc-schet-tax-obj.with-slt         = bfrs_arh-fin-doc-schet-tax-obj.with-slt         and
                                               rbfrs_arh-fin-doc-schet-tax-obj.sum-type         = bfrs_arh-fin-doc-schet-tax-obj.sum-type         and
                                               rbfrs_arh-fin-doc-schet-tax-obj.fact-order       > bfrs_arh-fin-doc-schet-tax-obj.fact-order       use-index pi exclusive-lock on error undo, return error return-value :
  assign
    rbfrs_arh-fin-doc-schet-tax-obj.income     = rbfrs_arh-fin-doc-schet-tax-obj.income     + parsum-doc
    rbfrs_arh-fin-doc-schet-tax-obj.income-vat = rbfrs_arh-fin-doc-schet-tax-obj.income-vat + parsum-vat-doc
    rbfrs_arh-fin-doc-schet-tax-obj.income-slt = rbfrs_arh-fin-doc-schet-tax-obj.income-slt + parsum-slt-doc
  .
end.
if parmode = "delete":u then do:
  delete bfps_arh-fin-doc-schet-tax-obj.
  delete bfrs_arh-fin-doc-schet-tax-obj.
end.
if parcurr-code <> 0 then do:
  if parmode = "close":u then do:
    find last bopr_arh-fin-doc-schet-tax-obj where bopr_arh-fin-doc-schet-tax-obj.host-code        = parhost-code         and
                                                   bopr_arh-fin-doc-schet-tax-obj.obj-type         = parobj-type          and
                                                   bopr_arh-fin-doc-schet-tax-obj.obj-code         = parobj-code          and
                                                   bopr_arh-fin-doc-schet-tax-obj.cli-type         = parpayer-type        and
                                                   bopr_arh-fin-doc-schet-tax-obj.cli-code         = parpayer-code        and
                                                   bopr_arh-fin-doc-schet-tax-obj.code-schet       = parpayer-code-schet  and
                                                   bopr_arh-fin-doc-schet-tax-obj.fin-ext-doc-type = parfin-ext-doc-type  and
                                                   bopr_arh-fin-doc-schet-tax-obj.calc-curr-code   = 0                    and
                                                   bopr_arh-fin-doc-schet-tax-obj.vat-pc           = parvat-pc            and
                                                   bopr_arh-fin-doc-schet-tax-obj.slt-pc           = parslt-pc            and
                                                   bopr_arh-fin-doc-schet-tax-obj.with-vat         = parwith-vat          and
                                                   bopr_arh-fin-doc-schet-tax-obj.with-slt         = parwith-slt          and
                                                   bopr_arh-fin-doc-schet-tax-obj.sum-type         = parsum-type          and
                                                   bopr_arh-fin-doc-schet-tax-obj.fact-order       < parfact-order        use-index pi no-error.
    create bfpr_arh-fin-doc-schet-tax-obj.
    assign
      bfpr_arh-fin-doc-schet-tax-obj.host-code        = parhost-code
      bfpr_arh-fin-doc-schet-tax-obj.obj-type         = parobj-type
      bfpr_arh-fin-doc-schet-tax-obj.obj-code         = parobj-code
      bfpr_arh-fin-doc-schet-tax-obj.cli-type         = parpayer-type
      bfpr_arh-fin-doc-schet-tax-obj.cli-code         = parpayer-code
      bfpr_arh-fin-doc-schet-tax-obj.code-schet       = parpayer-code-schet
      bfpr_arh-fin-doc-schet-tax-obj.fin-ext-doc-type = parfin-ext-doc-type
      bfpr_arh-fin-doc-schet-tax-obj.calc-curr-code   = 0
      bfpr_arh-fin-doc-schet-tax-obj.vat-pc           = parvat-pc
      bfpr_arh-fin-doc-schet-tax-obj.slt-pc           = parslt-pc
      bfpr_arh-fin-doc-schet-tax-obj.with-vat         = parwith-vat
      bfpr_arh-fin-doc-schet-tax-obj.with-slt         = parwith-slt
      bfpr_arh-fin-doc-schet-tax-obj.sum-type         = parsum-type
      bfpr_arh-fin-doc-schet-tax-obj.cource-des       = "r":u
      bfpr_arh-fin-doc-schet-tax-obj.fact-order       = parfact-order
      bfpr_arh-fin-doc-schet-tax-obj.fin-doc-code     = parfin-doc-code
      bfpr_arh-fin-doc-schet-tax-obj.fact-date        = parfact-date
      bfpr_arh-fin-doc-schet-tax-obj.curr-code        = parcurr-code
      bfpr_arh-fin-doc-schet-tax-obj.income           = (if available bopr_arh-fin-doc-schet-tax-obj then bopr_arh-fin-doc-schet-tax-obj.income      else 0)
      bfpr_arh-fin-doc-schet-tax-obj.income-vat       = (if available bopr_arh-fin-doc-schet-tax-obj then bopr_arh-fin-doc-schet-tax-obj.income-vat  else 0)
      bfpr_arh-fin-doc-schet-tax-obj.income-slt       = (if available bopr_arh-fin-doc-schet-tax-obj then bopr_arh-fin-doc-schet-tax-obj.income-slt  else 0)
      bfpr_arh-fin-doc-schet-tax-obj.expense          = (if available bopr_arh-fin-doc-schet-tax-obj then bopr_arh-fin-doc-schet-tax-obj.expense     else 0) + parsum-rubl
      bfpr_arh-fin-doc-schet-tax-obj.expense-vat      = (if available bopr_arh-fin-doc-schet-tax-obj then bopr_arh-fin-doc-schet-tax-obj.expense-vat else 0) + parsum-vat-rubl
      bfpr_arh-fin-doc-schet-tax-obj.expense-slt      = (if available bopr_arh-fin-doc-schet-tax-obj then bopr_arh-fin-doc-schet-tax-obj.expense-slt else 0) + parsum-slt-rubl
    .
  end.
  else do:
    find first bfpr_arh-fin-doc-schet-tax-obj where bfpr_arh-fin-doc-schet-tax-obj.host-code        = parhost-code         and
                                                    bfpr_arh-fin-doc-schet-tax-obj.obj-type         = parobj-type          and
                                                    bfpr_arh-fin-doc-schet-tax-obj.obj-code         = parobj-code          and
                                                    bfpr_arh-fin-doc-schet-tax-obj.cli-type         = parpayer-type        and
                                                    bfpr_arh-fin-doc-schet-tax-obj.cli-code         = parpayer-code        and
                                                    bfpr_arh-fin-doc-schet-tax-obj.code-schet       = parpayer-code-schet  and
                                                    bfpr_arh-fin-doc-schet-tax-obj.fin-ext-doc-type = parfin-ext-doc-type  and
                                                    bfpr_arh-fin-doc-schet-tax-obj.calc-curr-code   = 0                    and
                                                    bfpr_arh-fin-doc-schet-tax-obj.vat-pc           = parvat-pc            and
                                                    bfpr_arh-fin-doc-schet-tax-obj.slt-pc           = parslt-pc            and
                                                    bfpr_arh-fin-doc-schet-tax-obj.with-vat         = parwith-vat          and
                                                    bfpr_arh-fin-doc-schet-tax-obj.with-slt         = parwith-slt          and
                                                    bfpr_arh-fin-doc-schet-tax-obj.sum-type         = parsum-type          and
                                                    bfpr_arh-fin-doc-schet-tax-obj.fact-order       = parfact-order        exclusive-lock.
  end.
  for each rbfpr_arh-fin-doc-schet-tax-obj where rbfpr_arh-fin-doc-schet-tax-obj.host-code        = bfpr_arh-fin-doc-schet-tax-obj.host-code        and
                                                 rbfpr_arh-fin-doc-schet-tax-obj.obj-type         = bfpr_arh-fin-doc-schet-tax-obj.obj-type         and
                                                 rbfpr_arh-fin-doc-schet-tax-obj.obj-code         = bfpr_arh-fin-doc-schet-tax-obj.obj-code         and
                                                 rbfpr_arh-fin-doc-schet-tax-obj.cli-type         = parpayer-type                                   and
                                                 rbfpr_arh-fin-doc-schet-tax-obj.cli-code         = parpayer-code                                   and
                                                 rbfpr_arh-fin-doc-schet-tax-obj.code-schet       = bfpr_arh-fin-doc-schet-tax-obj.code-schet       and
                                                 rbfpr_arh-fin-doc-schet-tax-obj.fin-ext-doc-type = bfpr_arh-fin-doc-schet-tax-obj.fin-ext-doc-type and
                                                 rbfpr_arh-fin-doc-schet-tax-obj.calc-curr-code   = bfpr_arh-fin-doc-schet-tax-obj.calc-curr-code   and
                                                 rbfpr_arh-fin-doc-schet-tax-obj.vat-pc           = bfpr_arh-fin-doc-schet-tax-obj.vat-pc           and
                                                 rbfpr_arh-fin-doc-schet-tax-obj.slt-pc           = bfpr_arh-fin-doc-schet-tax-obj.slt-pc           and
                                                 rbfpr_arh-fin-doc-schet-tax-obj.with-vat         = bfpr_arh-fin-doc-schet-tax-obj.with-vat         and
                                                 rbfpr_arh-fin-doc-schet-tax-obj.with-slt         = bfpr_arh-fin-doc-schet-tax-obj.with-slt         and
                                                 rbfpr_arh-fin-doc-schet-tax-obj.sum-type         = bfpr_arh-fin-doc-schet-tax-obj.sum-type         and
                                                 rbfpr_arh-fin-doc-schet-tax-obj.fact-order       > bfpr_arh-fin-doc-schet-tax-obj.fact-order       use-index pi exclusive-lock on error undo, return error return-value :
    assign
      rbfpr_arh-fin-doc-schet-tax-obj.expense     = rbfpr_arh-fin-doc-schet-tax-obj.expense     + parsum-rubl
      rbfpr_arh-fin-doc-schet-tax-obj.expense-vat = rbfpr_arh-fin-doc-schet-tax-obj.expense-vat + parsum-vat-rubl
      rbfpr_arh-fin-doc-schet-tax-obj.expense-slt = rbfpr_arh-fin-doc-schet-tax-obj.expense-slt + parsum-slt-rubl
    .
  end.
  if parmode = "close":u then do:
    find last borr_arh-fin-doc-schet-tax-obj where borr_arh-fin-doc-schet-tax-obj.host-code        = parhost-code            and
                                                   borr_arh-fin-doc-schet-tax-obj.obj-type         = parobj-type             and
                                                   borr_arh-fin-doc-schet-tax-obj.obj-code         = parobj-code             and
                                                   borr_arh-fin-doc-schet-tax-obj.cli-type         = parreceiver-type        and
                                                   borr_arh-fin-doc-schet-tax-obj.cli-code         = parreceiver-code        and
                                                   borr_arh-fin-doc-schet-tax-obj.code-schet       = parreceiver-code-schet  and
                                                   borr_arh-fin-doc-schet-tax-obj.fin-ext-doc-type = parfin-ext-doc-type     and
                                                   borr_arh-fin-doc-schet-tax-obj.calc-curr-code   = 0                       and
                                                   borr_arh-fin-doc-schet-tax-obj.vat-pc           = parvat-pc               and
                                                   borr_arh-fin-doc-schet-tax-obj.slt-pc           = parslt-pc               and
                                                   borr_arh-fin-doc-schet-tax-obj.with-vat         = parwith-vat             and
                                                   borr_arh-fin-doc-schet-tax-obj.with-slt         = parwith-slt             and
                                                   borr_arh-fin-doc-schet-tax-obj.sum-type         = parsum-type             and
                                                   borr_arh-fin-doc-schet-tax-obj.fact-order       < parfact-order           use-index pi no-error.
    create bfrr_arh-fin-doc-schet-tax-obj.
    assign
      bfrr_arh-fin-doc-schet-tax-obj.host-code        = parhost-code
      bfrr_arh-fin-doc-schet-tax-obj.obj-type         = parobj-type
      bfrr_arh-fin-doc-schet-tax-obj.obj-code         = parobj-code
      bfrr_arh-fin-doc-schet-tax-obj.cli-type         = parreceiver-type
      bfrr_arh-fin-doc-schet-tax-obj.cli-code         = parreceiver-code
      bfrr_arh-fin-doc-schet-tax-obj.code-schet       = parreceiver-code-schet
      bfrr_arh-fin-doc-schet-tax-obj.fin-ext-doc-type = parfin-ext-doc-type
      bfrr_arh-fin-doc-schet-tax-obj.calc-curr-code   = 0
      bfrr_arh-fin-doc-schet-tax-obj.vat-pc           = parvat-pc
      bfrr_arh-fin-doc-schet-tax-obj.slt-pc           = parslt-pc
      bfrr_arh-fin-doc-schet-tax-obj.with-vat         = parwith-vat
      bfrr_arh-fin-doc-schet-tax-obj.with-slt         = parwith-slt
      bfrr_arh-fin-doc-schet-tax-obj.sum-type         = parsum-type
      bfrr_arh-fin-doc-schet-tax-obj.cource-des       = "r":u
      bfrr_arh-fin-doc-schet-tax-obj.fact-order       = parfact-order
      bfrr_arh-fin-doc-schet-tax-obj.fin-doc-code     = parfin-doc-code
      bfrr_arh-fin-doc-schet-tax-obj.fact-date        = parfact-date
      bfrr_arh-fin-doc-schet-tax-obj.curr-code        = parcurr-code
    .
    assign
      bfrr_arh-fin-doc-schet-tax-obj.expense          = (if available borr_arh-fin-doc-schet-tax-obj then borr_arh-fin-doc-schet-tax-obj.expense     else 0)
      bfrr_arh-fin-doc-schet-tax-obj.expense-vat      = (if available borr_arh-fin-doc-schet-tax-obj then borr_arh-fin-doc-schet-tax-obj.expense-vat else 0)
      bfrr_arh-fin-doc-schet-tax-obj.expense-slt      = (if available borr_arh-fin-doc-schet-tax-obj then borr_arh-fin-doc-schet-tax-obj.expense-slt else 0)
      bfrr_arh-fin-doc-schet-tax-obj.income           = (if available borr_arh-fin-doc-schet-tax-obj then borr_arh-fin-doc-schet-tax-obj.income      else 0) + parsum-rubl
      bfrr_arh-fin-doc-schet-tax-obj.income-vat       = (if available borr_arh-fin-doc-schet-tax-obj then borr_arh-fin-doc-schet-tax-obj.income-vat  else 0) + parsum-vat-rubl
      bfrr_arh-fin-doc-schet-tax-obj.income-slt       = (if available borr_arh-fin-doc-schet-tax-obj then borr_arh-fin-doc-schet-tax-obj.income-slt  else 0) + parsum-slt-rubl
    .
  end.
  else do:
    find first bfrr_arh-fin-doc-schet-tax-obj where bfrr_arh-fin-doc-schet-tax-obj.host-code        = parhost-code            and
                                                    bfrr_arh-fin-doc-schet-tax-obj.obj-type         = parobj-type             and
                                                    bfrr_arh-fin-doc-schet-tax-obj.obj-code         = parobj-code             and
                                                    bfrr_arh-fin-doc-schet-tax-obj.cli-type         = parreceiver-type        and
                                                    bfrr_arh-fin-doc-schet-tax-obj.cli-code         = parreceiver-code        and
                                                    bfrr_arh-fin-doc-schet-tax-obj.code-schet       = parreceiver-code-schet  and
                                                    bfrr_arh-fin-doc-schet-tax-obj.fin-ext-doc-type = parfin-ext-doc-type     and
                                                    bfrr_arh-fin-doc-schet-tax-obj.calc-curr-code   = 0                       and
                                                    bfrr_arh-fin-doc-schet-tax-obj.vat-pc           = parvat-pc               and
                                                    bfrr_arh-fin-doc-schet-tax-obj.slt-pc           = parslt-pc               and
                                                    bfrr_arh-fin-doc-schet-tax-obj.with-vat         = parwith-vat             and
                                                    bfrr_arh-fin-doc-schet-tax-obj.with-slt         = parwith-slt             and
                                                    bfrr_arh-fin-doc-schet-tax-obj.sum-type         = parsum-type             and
                                                    bfrr_arh-fin-doc-schet-tax-obj.fact-order       = parfact-order           exclusive-lock.
  end.
  for each rbfrr_arh-fin-doc-schet-tax-obj where rbfrr_arh-fin-doc-schet-tax-obj.host-code        = bfrr_arh-fin-doc-schet-tax-obj.host-code        and
                                                 rbfrr_arh-fin-doc-schet-tax-obj.obj-type         = bfrr_arh-fin-doc-schet-tax-obj.obj-type         and
                                                 rbfrr_arh-fin-doc-schet-tax-obj.obj-code         = bfrr_arh-fin-doc-schet-tax-obj.obj-code         and
                                                 rbfrr_arh-fin-doc-schet-tax-obj.cli-type         = parreceiver-type                                and
                                                 rbfrr_arh-fin-doc-schet-tax-obj.cli-code         = parreceiver-code                                and
                                                 rbfrr_arh-fin-doc-schet-tax-obj.code-schet       = bfrr_arh-fin-doc-schet-tax-obj.code-schet       and
                                                 rbfrr_arh-fin-doc-schet-tax-obj.fin-ext-doc-type = bfrr_arh-fin-doc-schet-tax-obj.fin-ext-doc-type and
                                                 rbfrr_arh-fin-doc-schet-tax-obj.calc-curr-code   = bfrr_arh-fin-doc-schet-tax-obj.calc-curr-code   and
                                                 rbfrr_arh-fin-doc-schet-tax-obj.vat-pc           = bfrr_arh-fin-doc-schet-tax-obj.vat-pc           and
                                                 rbfrr_arh-fin-doc-schet-tax-obj.slt-pc           = bfrr_arh-fin-doc-schet-tax-obj.slt-pc           and
                                                 rbfrr_arh-fin-doc-schet-tax-obj.with-vat         = bfrr_arh-fin-doc-schet-tax-obj.with-vat         and
                                                 rbfrr_arh-fin-doc-schet-tax-obj.with-slt         = bfrr_arh-fin-doc-schet-tax-obj.with-slt         and
                                                 rbfrr_arh-fin-doc-schet-tax-obj.sum-type         = bfrr_arh-fin-doc-schet-tax-obj.sum-type         and
                                                 rbfrr_arh-fin-doc-schet-tax-obj.fact-order       > bfrr_arh-fin-doc-schet-tax-obj.fact-order       use-index pi exclusive-lock on error undo, return error return-value :
    assign
      rbfrr_arh-fin-doc-schet-tax-obj.income     = rbfrr_arh-fin-doc-schet-tax-obj.income     + parsum-rubl
      rbfrr_arh-fin-doc-schet-tax-obj.income-vat = rbfrr_arh-fin-doc-schet-tax-obj.income-vat + parsum-vat-rubl
      rbfrr_arh-fin-doc-schet-tax-obj.income-slt = rbfrr_arh-fin-doc-schet-tax-obj.income-slt + parsum-slt-rubl
    .
  end.
  if parmode = "delete":u then do:
    delete bfpr_arh-fin-doc-schet-tax-obj.
    delete bfrr_arh-fin-doc-schet-tax-obj.
  end.
end.
if parbase-code <> parcurr-code and
   parbase-code <> 0            then do:
  if parmode = "close":u then do:
    find last bopb_arh-fin-doc-schet-tax-obj where bopb_arh-fin-doc-schet-tax-obj.host-code        = parhost-code         and
                                                   bopb_arh-fin-doc-schet-tax-obj.obj-type         = parobj-type          and
                                                   bopb_arh-fin-doc-schet-tax-obj.obj-code         = parobj-code          and
                                                   bopb_arh-fin-doc-schet-tax-obj.cli-type         = parpayer-type        and
                                                   bopb_arh-fin-doc-schet-tax-obj.cli-code         = parpayer-code        and
                                                   bopb_arh-fin-doc-schet-tax-obj.code-schet       = parpayer-code-schet  and
                                                   bopb_arh-fin-doc-schet-tax-obj.fin-ext-doc-type = parfin-ext-doc-type  and
                                                   bopb_arh-fin-doc-schet-tax-obj.calc-curr-code   = parbase-code         and
                                                   bopb_arh-fin-doc-schet-tax-obj.vat-pc           = parvat-pc            and
                                                   bopb_arh-fin-doc-schet-tax-obj.slt-pc           = parslt-pc            and
                                                   bopb_arh-fin-doc-schet-tax-obj.with-vat         = parwith-vat          and
                                                   bopb_arh-fin-doc-schet-tax-obj.with-slt         = parwith-slt          and
                                                   bopb_arh-fin-doc-schet-tax-obj.sum-type         = parsum-type          and
                                                   bopb_arh-fin-doc-schet-tax-obj.fact-order       < parfact-order        use-index pi no-error.
    create bfpb_arh-fin-doc-schet-tax-obj.
    assign
      bfpb_arh-fin-doc-schet-tax-obj.host-code        = parhost-code
      bfpb_arh-fin-doc-schet-tax-obj.obj-type         = parobj-type
      bfpb_arh-fin-doc-schet-tax-obj.obj-code         = parobj-code
      bfpb_arh-fin-doc-schet-tax-obj.cli-type         = parpayer-type
      bfpb_arh-fin-doc-schet-tax-obj.cli-code         = parpayer-code
      bfpb_arh-fin-doc-schet-tax-obj.code-schet       = parpayer-code-schet
      bfpb_arh-fin-doc-schet-tax-obj.fin-ext-doc-type = parfin-ext-doc-type
      bfpb_arh-fin-doc-schet-tax-obj.calc-curr-code   = parbase-code
      bfpb_arh-fin-doc-schet-tax-obj.vat-pc           = parvat-pc
      bfpb_arh-fin-doc-schet-tax-obj.slt-pc           = parslt-pc
      bfpb_arh-fin-doc-schet-tax-obj.with-vat         = parwith-vat
      bfpb_arh-fin-doc-schet-tax-obj.with-slt         = parwith-slt
      bfpb_arh-fin-doc-schet-tax-obj.sum-type         = parsum-type
      bfpb_arh-fin-doc-schet-tax-obj.cource-des       = "b":u
      bfpb_arh-fin-doc-schet-tax-obj.fact-order       = parfact-order
      bfpb_arh-fin-doc-schet-tax-obj.fin-doc-code     = parfin-doc-code
      bfpb_arh-fin-doc-schet-tax-obj.fact-date        = parfact-date
      bfpb_arh-fin-doc-schet-tax-obj.curr-code        = parcurr-code
      bfpb_arh-fin-doc-schet-tax-obj.income           = (if available bopb_arh-fin-doc-schet-tax-obj then bopb_arh-fin-doc-schet-tax-obj.income      else 0)
      bfpb_arh-fin-doc-schet-tax-obj.income-vat       = (if available bopb_arh-fin-doc-schet-tax-obj then bopb_arh-fin-doc-schet-tax-obj.income-vat  else 0)
      bfpb_arh-fin-doc-schet-tax-obj.income-slt       = (if available bopb_arh-fin-doc-schet-tax-obj then bopb_arh-fin-doc-schet-tax-obj.income-slt  else 0)
      bfpb_arh-fin-doc-schet-tax-obj.expense          = (if available bopb_arh-fin-doc-schet-tax-obj then bopb_arh-fin-doc-schet-tax-obj.expense     else 0) + parsum-base
      bfpb_arh-fin-doc-schet-tax-obj.expense-vat      = (if available bopb_arh-fin-doc-schet-tax-obj then bopb_arh-fin-doc-schet-tax-obj.expense-vat else 0) + parsum-vat-base
      bfpb_arh-fin-doc-schet-tax-obj.expense-slt      = (if available bopb_arh-fin-doc-schet-tax-obj then bopb_arh-fin-doc-schet-tax-obj.expense-slt else 0) + parsum-slt-base
    .
  end.
  else do:
    find first bfpb_arh-fin-doc-schet-tax-obj where bfpb_arh-fin-doc-schet-tax-obj.host-code        = parhost-code         and
                                                    bfpb_arh-fin-doc-schet-tax-obj.obj-type         = parobj-type          and
                                                    bfpb_arh-fin-doc-schet-tax-obj.obj-code         = parobj-code          and
                                                    bfpb_arh-fin-doc-schet-tax-obj.cli-type         = parpayer-type        and
                                                    bfpb_arh-fin-doc-schet-tax-obj.cli-code         = parpayer-code        and
                                                    bfpb_arh-fin-doc-schet-tax-obj.code-schet       = parpayer-code-schet  and
                                                    bfpb_arh-fin-doc-schet-tax-obj.fin-ext-doc-type = parfin-ext-doc-type  and
                                                    bfpb_arh-fin-doc-schet-tax-obj.calc-curr-code   = parbase-code         and
                                                    bfpb_arh-fin-doc-schet-tax-obj.vat-pc           = parvat-pc            and
                                                    bfpb_arh-fin-doc-schet-tax-obj.slt-pc           = parslt-pc            and
                                                    bfpb_arh-fin-doc-schet-tax-obj.with-vat         = parwith-vat          and
                                                    bfpb_arh-fin-doc-schet-tax-obj.with-slt         = parwith-slt          and
                                                    bfpb_arh-fin-doc-schet-tax-obj.sum-type         = parsum-type          and
                                                    bfpb_arh-fin-doc-schet-tax-obj.fact-order       = parfact-order        exclusive-lock.
  end.
  for each rbfpb_arh-fin-doc-schet-tax-obj where rbfpb_arh-fin-doc-schet-tax-obj.host-code        = bfpb_arh-fin-doc-schet-tax-obj.host-code        and
                                                 rbfpb_arh-fin-doc-schet-tax-obj.obj-type         = bfpb_arh-fin-doc-schet-tax-obj.obj-type         and
                                                 rbfpb_arh-fin-doc-schet-tax-obj.obj-code         = bfpb_arh-fin-doc-schet-tax-obj.obj-code         and
                                                 rbfpb_arh-fin-doc-schet-tax-obj.cli-type         = parpayer-type                                   and
                                                 rbfpb_arh-fin-doc-schet-tax-obj.cli-code         = parpayer-code                                   and
                                                 rbfpb_arh-fin-doc-schet-tax-obj.code-schet       = bfpb_arh-fin-doc-schet-tax-obj.code-schet       and
                                                 rbfpb_arh-fin-doc-schet-tax-obj.fin-ext-doc-type = bfpb_arh-fin-doc-schet-tax-obj.fin-ext-doc-type and
                                                 rbfpb_arh-fin-doc-schet-tax-obj.calc-curr-code   = bfpb_arh-fin-doc-schet-tax-obj.calc-curr-code   and
                                                 rbfpb_arh-fin-doc-schet-tax-obj.vat-pc           = bfpb_arh-fin-doc-schet-tax-obj.vat-pc           and
                                                 rbfpb_arh-fin-doc-schet-tax-obj.slt-pc           = bfpb_arh-fin-doc-schet-tax-obj.slt-pc           and
                                                 rbfpb_arh-fin-doc-schet-tax-obj.with-vat         = bfpb_arh-fin-doc-schet-tax-obj.with-vat         and
                                                 rbfpb_arh-fin-doc-schet-tax-obj.with-slt         = bfpb_arh-fin-doc-schet-tax-obj.with-slt         and
                                                 rbfpb_arh-fin-doc-schet-tax-obj.sum-type         = bfpb_arh-fin-doc-schet-tax-obj.sum-type         and
                                                 rbfpb_arh-fin-doc-schet-tax-obj.fact-order       > bfpb_arh-fin-doc-schet-tax-obj.fact-order       use-index pi exclusive-lock on error undo, return error return-value :
    assign
      rbfpb_arh-fin-doc-schet-tax-obj.expense     = rbfpb_arh-fin-doc-schet-tax-obj.expense     + parsum-base
      rbfpb_arh-fin-doc-schet-tax-obj.expense-vat = rbfpb_arh-fin-doc-schet-tax-obj.expense-vat + parsum-vat-base
      rbfpb_arh-fin-doc-schet-tax-obj.expense-slt = rbfpb_arh-fin-doc-schet-tax-obj.expense-slt + parsum-slt-base
    .
  end.
  if parmode = "close":u then do:
    find last borb_arh-fin-doc-schet-tax-obj where borb_arh-fin-doc-schet-tax-obj.host-code        = parhost-code            and
                                                   borb_arh-fin-doc-schet-tax-obj.obj-type         = parobj-type             and
                                                   borb_arh-fin-doc-schet-tax-obj.obj-code         = parobj-code             and
                                                   borb_arh-fin-doc-schet-tax-obj.cli-type         = parreceiver-type        and
                                                   borb_arh-fin-doc-schet-tax-obj.cli-code         = parreceiver-code        and
                                                   borb_arh-fin-doc-schet-tax-obj.code-schet       = parreceiver-code-schet  and
                                                   borb_arh-fin-doc-schet-tax-obj.fin-ext-doc-type = parfin-ext-doc-type     and
                                                   borb_arh-fin-doc-schet-tax-obj.calc-curr-code   = parbase-code            and
                                                   borb_arh-fin-doc-schet-tax-obj.vat-pc           = parvat-pc               and
                                                   borb_arh-fin-doc-schet-tax-obj.slt-pc           = parslt-pc               and
                                                   borb_arh-fin-doc-schet-tax-obj.with-vat         = parwith-vat             and
                                                   borb_arh-fin-doc-schet-tax-obj.with-slt         = parwith-slt             and
                                                   borb_arh-fin-doc-schet-tax-obj.sum-type         = parsum-type             and
                                                   borb_arh-fin-doc-schet-tax-obj.fact-order       < parfact-order           use-index pi no-error.
    create bfrb_arh-fin-doc-schet-tax-obj.
    assign
      bfrb_arh-fin-doc-schet-tax-obj.host-code        = parhost-code
      bfrb_arh-fin-doc-schet-tax-obj.obj-type         = parobj-type
      bfrb_arh-fin-doc-schet-tax-obj.obj-code         = parobj-code
      bfrb_arh-fin-doc-schet-tax-obj.cli-type         = parreceiver-type
      bfrb_arh-fin-doc-schet-tax-obj.cli-code         = parreceiver-code
      bfrb_arh-fin-doc-schet-tax-obj.code-schet       = parreceiver-code-schet
      bfrb_arh-fin-doc-schet-tax-obj.fin-ext-doc-type = parfin-ext-doc-type
      bfrb_arh-fin-doc-schet-tax-obj.calc-curr-code   = parbase-code
      bfrb_arh-fin-doc-schet-tax-obj.vat-pc           = parvat-pc
      bfrb_arh-fin-doc-schet-tax-obj.slt-pc           = parslt-pc
      bfrb_arh-fin-doc-schet-tax-obj.with-vat         = parwith-vat
      bfrb_arh-fin-doc-schet-tax-obj.with-slt         = parwith-slt
      bfrb_arh-fin-doc-schet-tax-obj.sum-type         = parsum-type
      bfrb_arh-fin-doc-schet-tax-obj.cource-des       = "b":u
      bfrb_arh-fin-doc-schet-tax-obj.fact-order       = parfact-order
      bfrb_arh-fin-doc-schet-tax-obj.fin-doc-code     = parfin-doc-code
      bfrb_arh-fin-doc-schet-tax-obj.fact-date        = parfact-date
      bfrb_arh-fin-doc-schet-tax-obj.curr-code        = parcurr-code
    .
    assign
      bfrb_arh-fin-doc-schet-tax-obj.expense          = (if available borb_arh-fin-doc-schet-tax-obj then borb_arh-fin-doc-schet-tax-obj.expense     else 0)
      bfrb_arh-fin-doc-schet-tax-obj.expense-vat      = (if available borb_arh-fin-doc-schet-tax-obj then borb_arh-fin-doc-schet-tax-obj.expense-vat else 0)
      bfrb_arh-fin-doc-schet-tax-obj.expense-slt      = (if available borb_arh-fin-doc-schet-tax-obj then borb_arh-fin-doc-schet-tax-obj.expense-slt else 0)
      bfrb_arh-fin-doc-schet-tax-obj.income           = (if available borb_arh-fin-doc-schet-tax-obj then borb_arh-fin-doc-schet-tax-obj.income      else 0) + parsum-base
      bfrb_arh-fin-doc-schet-tax-obj.income-vat       = (if available borb_arh-fin-doc-schet-tax-obj then borb_arh-fin-doc-schet-tax-obj.income-vat  else 0) + parsum-vat-base
      bfrb_arh-fin-doc-schet-tax-obj.income-slt       = (if available borb_arh-fin-doc-schet-tax-obj then borb_arh-fin-doc-schet-tax-obj.income-slt  else 0) + parsum-slt-base
    .
  end.
  else do:
    find first bfrb_arh-fin-doc-schet-tax-obj where bfrb_arh-fin-doc-schet-tax-obj.host-code        = parhost-code            and
                                                    bfrb_arh-fin-doc-schet-tax-obj.obj-type         = parobj-type             and
                                                    bfrb_arh-fin-doc-schet-tax-obj.obj-code         = parobj-code             and
                                                    bfrb_arh-fin-doc-schet-tax-obj.cli-type         = parreceiver-type        and
                                                    bfrb_arh-fin-doc-schet-tax-obj.cli-code         = parreceiver-code        and
                                                    bfrb_arh-fin-doc-schet-tax-obj.code-schet       = parreceiver-code-schet  and
                                                    bfrb_arh-fin-doc-schet-tax-obj.fin-ext-doc-type = parfin-ext-doc-type     and
                                                    bfrb_arh-fin-doc-schet-tax-obj.calc-curr-code   = parbase-code            and
                                                    bfrb_arh-fin-doc-schet-tax-obj.vat-pc           = parvat-pc               and
                                                    bfrb_arh-fin-doc-schet-tax-obj.slt-pc           = parslt-pc               and
                                                    bfrb_arh-fin-doc-schet-tax-obj.with-vat         = parwith-vat             and
                                                    bfrb_arh-fin-doc-schet-tax-obj.with-slt         = parwith-slt             and
                                                    bfrb_arh-fin-doc-schet-tax-obj.sum-type         = parsum-type             and
                                                    bfrb_arh-fin-doc-schet-tax-obj.fact-order       = parfact-order           exclusive-lock.
  end.
  for each rbfrb_arh-fin-doc-schet-tax-obj where rbfrb_arh-fin-doc-schet-tax-obj.host-code        = bfrb_arh-fin-doc-schet-tax-obj.host-code        and
                                                 rbfrb_arh-fin-doc-schet-tax-obj.obj-type         = bfrb_arh-fin-doc-schet-tax-obj.obj-type         and
                                                 rbfrb_arh-fin-doc-schet-tax-obj.obj-code         = bfrb_arh-fin-doc-schet-tax-obj.obj-code         and
                                                 rbfrb_arh-fin-doc-schet-tax-obj.cli-type         = parreceiver-type                                and
                                                 rbfrb_arh-fin-doc-schet-tax-obj.cli-code         = parreceiver-code                                and
                                                 rbfrb_arh-fin-doc-schet-tax-obj.code-schet       = bfrb_arh-fin-doc-schet-tax-obj.code-schet       and
                                                 rbfrb_arh-fin-doc-schet-tax-obj.fin-ext-doc-type = bfrb_arh-fin-doc-schet-tax-obj.fin-ext-doc-type and
                                                 rbfrb_arh-fin-doc-schet-tax-obj.calc-curr-code   = bfrb_arh-fin-doc-schet-tax-obj.calc-curr-code   and
                                                 rbfrb_arh-fin-doc-schet-tax-obj.vat-pc           = bfrb_arh-fin-doc-schet-tax-obj.vat-pc           and
                                                 rbfrb_arh-fin-doc-schet-tax-obj.slt-pc           = bfrb_arh-fin-doc-schet-tax-obj.slt-pc           and
                                                 rbfrb_arh-fin-doc-schet-tax-obj.with-vat         = bfrb_arh-fin-doc-schet-tax-obj.with-vat         and
                                                 rbfrb_arh-fin-doc-schet-tax-obj.with-slt         = bfrb_arh-fin-doc-schet-tax-obj.with-slt         and
                                                 rbfrb_arh-fin-doc-schet-tax-obj.sum-type         = bfrb_arh-fin-doc-schet-tax-obj.sum-type         and
                                                 rbfrb_arh-fin-doc-schet-tax-obj.fact-order       > bfrb_arh-fin-doc-schet-tax-obj.fact-order       use-index pi exclusive-lock on error undo, return error return-value :
    assign
      rbfrb_arh-fin-doc-schet-tax-obj.income     = rbfrb_arh-fin-doc-schet-tax-obj.income     + parsum-base
      rbfrb_arh-fin-doc-schet-tax-obj.income-vat = rbfrb_arh-fin-doc-schet-tax-obj.income-vat + parsum-vat-base
      rbfrb_arh-fin-doc-schet-tax-obj.income-slt = rbfrb_arh-fin-doc-schet-tax-obj.income-slt + parsum-slt-base
    .
  end.
  if parmode = "delete":u then do:
    delete bfpb_arh-fin-doc-schet-tax-obj.
    delete bfrb_arh-fin-doc-schet-tax-obj.
  end.
end.
end.
end procedure.
procedure libfarpo_calc-arh-fin-doc-schet-tax-n-obj :
define input parameter parmode                    as   character                    no-undo.
define input parameter parhost-code               like ub.fin-doc.host-code         no-undo.
define input parameter parobj-type                like ub.fin-doc.obj-type          no-undo.
define input parameter parobj-code                like ub.fin-doc.obj-code          no-undo.
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
define buffer bfps_arh-fin-doc-s-tax-nal-obj  for ub.arh-fin-doc-s-tax-nal-obj.
define buffer bfrs_arh-fin-doc-s-tax-nal-obj  for ub.arh-fin-doc-s-tax-nal-obj.
define buffer rbfps_arh-fin-doc-s-tax-nal-obj for ub.arh-fin-doc-s-tax-nal-obj.
define buffer rbfrs_arh-fin-doc-s-tax-nal-obj for ub.arh-fin-doc-s-tax-nal-obj.
define buffer bops_arh-fin-doc-s-tax-nal-obj  for ub.arh-fin-doc-s-tax-nal-obj.
define buffer bors_arh-fin-doc-s-tax-nal-obj  for ub.arh-fin-doc-s-tax-nal-obj.
define buffer bfpr_arh-fin-doc-s-tax-nal-obj  for ub.arh-fin-doc-s-tax-nal-obj.
define buffer bfrr_arh-fin-doc-s-tax-nal-obj  for ub.arh-fin-doc-s-tax-nal-obj.
define buffer rbfpr_arh-fin-doc-s-tax-nal-obj for ub.arh-fin-doc-s-tax-nal-obj.
define buffer rbfrr_arh-fin-doc-s-tax-nal-obj for ub.arh-fin-doc-s-tax-nal-obj.
define buffer bopr_arh-fin-doc-s-tax-nal-obj  for ub.arh-fin-doc-s-tax-nal-obj.
define buffer borr_arh-fin-doc-s-tax-nal-obj  for ub.arh-fin-doc-s-tax-nal-obj.
define buffer bfpb_arh-fin-doc-s-tax-nal-obj  for ub.arh-fin-doc-s-tax-nal-obj.
define buffer bfrb_arh-fin-doc-s-tax-nal-obj  for ub.arh-fin-doc-s-tax-nal-obj.
define buffer rbfpb_arh-fin-doc-s-tax-nal-obj for ub.arh-fin-doc-s-tax-nal-obj.
define buffer rbfrb_arh-fin-doc-s-tax-nal-obj for ub.arh-fin-doc-s-tax-nal-obj.
define buffer bopb_arh-fin-doc-s-tax-nal-obj  for ub.arh-fin-doc-s-tax-nal-obj.
define buffer borb_arh-fin-doc-s-tax-nal-obj  for ub.arh-fin-doc-s-tax-nal-obj.
define buffer bfpc_arh-fin-doc-s-tax-nal-obj  for ub.arh-fin-doc-s-tax-nal-obj.
define buffer bfrc_arh-fin-doc-s-tax-nal-obj  for ub.arh-fin-doc-s-tax-nal-obj.
define buffer rbfpc_arh-fin-doc-s-tax-nal-obj for ub.arh-fin-doc-s-tax-nal-obj.
define buffer rbfrc_arh-fin-doc-s-tax-nal-obj for ub.arh-fin-doc-s-tax-nal-obj.
define buffer bopc_arh-fin-doc-s-tax-nal-obj  for ub.arh-fin-doc-s-tax-nal-obj.
define buffer borc_arh-fin-doc-s-tax-nal-obj  for ub.arh-fin-doc-s-tax-nal-obj.
do on error undo, return error substitute ("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
if parmode = "close":u then do:
  find last bops_arh-fin-doc-s-tax-nal-obj where bops_arh-fin-doc-s-tax-nal-obj.host-code        = parhost-code          and
                                                 bops_arh-fin-doc-s-tax-nal-obj.obj-type         = parobj-type           and
                                                 bops_arh-fin-doc-s-tax-nal-obj.obj-code         = parobj-code           and
                                                 bops_arh-fin-doc-s-tax-nal-obj.cli-type         = parpayer-type         and
                                                 bops_arh-fin-doc-s-tax-nal-obj.cli-code         = parpayer-code         and
                                                 bops_arh-fin-doc-s-tax-nal-obj.fin-code-acc     = parpayer-fin-code-acc and
                                                 bops_arh-fin-doc-s-tax-nal-obj.curr-code        = parcurr-code          and
                                                 bops_arh-fin-doc-s-tax-nal-obj.fin-ext-doc-type = parfin-ext-doc-type   and
                                                 bops_arh-fin-doc-s-tax-nal-obj.calc-curr-code   = parcurr-code          and
                                                 bops_arh-fin-doc-s-tax-nal-obj.vat-pc           = parvat-pc             and
                                                 bops_arh-fin-doc-s-tax-nal-obj.slt-pc           = parslt-pc             and
                                                 bops_arh-fin-doc-s-tax-nal-obj.with-vat         = parwith-vat           and
                                                 bops_arh-fin-doc-s-tax-nal-obj.with-slt         = parwith-slt           and
                                                 bops_arh-fin-doc-s-tax-nal-obj.sum-type         = parsum-type           and
                                                 bops_arh-fin-doc-s-tax-nal-obj.fact-order       < parfact-order         use-index pi no-error.
  create bfps_arh-fin-doc-s-tax-nal-obj.
  assign
    bfps_arh-fin-doc-s-tax-nal-obj.host-code        = parhost-code
    bfps_arh-fin-doc-s-tax-nal-obj.obj-type         = parobj-type
    bfps_arh-fin-doc-s-tax-nal-obj.obj-code         = parobj-code
    bfps_arh-fin-doc-s-tax-nal-obj.cli-type         = parpayer-type
    bfps_arh-fin-doc-s-tax-nal-obj.cli-code         = parpayer-code
    bfps_arh-fin-doc-s-tax-nal-obj.fin-code-acc     = parpayer-fin-code-acc
    bfps_arh-fin-doc-s-tax-nal-obj.curr-code        = parcurr-code
    bfps_arh-fin-doc-s-tax-nal-obj.fin-ext-doc-type = parfin-ext-doc-type
    bfps_arh-fin-doc-s-tax-nal-obj.calc-curr-code   = parcurr-code
    bfps_arh-fin-doc-s-tax-nal-obj.vat-pc           = parvat-pc
    bfps_arh-fin-doc-s-tax-nal-obj.slt-pc           = parslt-pc
    bfps_arh-fin-doc-s-tax-nal-obj.with-vat         = parwith-vat
    bfps_arh-fin-doc-s-tax-nal-obj.with-slt         = parwith-slt
    bfps_arh-fin-doc-s-tax-nal-obj.sum-type         = parsum-type
    bfps_arh-fin-doc-s-tax-nal-obj.cource-des       = "s":u
    bfps_arh-fin-doc-s-tax-nal-obj.fact-order       = parfact-order
    bfps_arh-fin-doc-s-tax-nal-obj.fin-doc-code     = parfin-doc-code
    bfps_arh-fin-doc-s-tax-nal-obj.fact-date        = parfact-date
    bfps_arh-fin-doc-s-tax-nal-obj.curr-code        = parcurr-code
    bfps_arh-fin-doc-s-tax-nal-obj.income           = (if available bops_arh-fin-doc-s-tax-nal-obj then bops_arh-fin-doc-s-tax-nal-obj.income      else 0)
    bfps_arh-fin-doc-s-tax-nal-obj.income-vat       = (if available bops_arh-fin-doc-s-tax-nal-obj then bops_arh-fin-doc-s-tax-nal-obj.income-vat  else 0)
    bfps_arh-fin-doc-s-tax-nal-obj.income-slt       = (if available bops_arh-fin-doc-s-tax-nal-obj then bops_arh-fin-doc-s-tax-nal-obj.income-slt  else 0)
    bfps_arh-fin-doc-s-tax-nal-obj.expense          = (if available bops_arh-fin-doc-s-tax-nal-obj then bops_arh-fin-doc-s-tax-nal-obj.expense     else 0) + parsum-doc
    bfps_arh-fin-doc-s-tax-nal-obj.expense-vat      = (if available bops_arh-fin-doc-s-tax-nal-obj then bops_arh-fin-doc-s-tax-nal-obj.expense-vat else 0) + parsum-vat-doc
    bfps_arh-fin-doc-s-tax-nal-obj.expense-slt      = (if available bops_arh-fin-doc-s-tax-nal-obj then bops_arh-fin-doc-s-tax-nal-obj.expense-slt else 0) + parsum-slt-doc
  .
end.
else do:
  find first bfps_arh-fin-doc-s-tax-nal-obj where bfps_arh-fin-doc-s-tax-nal-obj.host-code        = parhost-code          and
                                                  bfps_arh-fin-doc-s-tax-nal-obj.obj-type         = parobj-type           and
                                                  bfps_arh-fin-doc-s-tax-nal-obj.obj-code         = parobj-code           and
                                                  bfps_arh-fin-doc-s-tax-nal-obj.cli-type         = parpayer-type         and
                                                  bfps_arh-fin-doc-s-tax-nal-obj.cli-code         = parpayer-code         and
                                                  bfps_arh-fin-doc-s-tax-nal-obj.fin-code-acc     = parpayer-fin-code-acc and
                                                  bfps_arh-fin-doc-s-tax-nal-obj.curr-code        = parcurr-code          and
                                                  bfps_arh-fin-doc-s-tax-nal-obj.fin-ext-doc-type = parfin-ext-doc-type   and
                                                  bfps_arh-fin-doc-s-tax-nal-obj.calc-curr-code   = parcurr-code          and
                                                  bfps_arh-fin-doc-s-tax-nal-obj.vat-pc           = parvat-pc             and
                                                  bfps_arh-fin-doc-s-tax-nal-obj.slt-pc           = parslt-pc             and
                                                  bfps_arh-fin-doc-s-tax-nal-obj.with-vat         = parwith-vat           and
                                                  bfps_arh-fin-doc-s-tax-nal-obj.with-slt         = parwith-slt           and
                                                  bfps_arh-fin-doc-s-tax-nal-obj.sum-type         = parsum-type           and
                                                  bfps_arh-fin-doc-s-tax-nal-obj.fact-order       = parfact-order         exclusive-lock.
end.
for each rbfps_arh-fin-doc-s-tax-nal-obj where rbfps_arh-fin-doc-s-tax-nal-obj.host-code        = bfps_arh-fin-doc-s-tax-nal-obj.host-code        and
                                               rbfps_arh-fin-doc-s-tax-nal-obj.obj-type         = bfps_arh-fin-doc-s-tax-nal-obj.obj-type         and
                                               rbfps_arh-fin-doc-s-tax-nal-obj.obj-code         = bfps_arh-fin-doc-s-tax-nal-obj.obj-code         and
                                               rbfps_arh-fin-doc-s-tax-nal-obj.cli-type         = parpayer-type                                   and
                                               rbfps_arh-fin-doc-s-tax-nal-obj.cli-code         = parpayer-code                                   and
                                               rbfps_arh-fin-doc-s-tax-nal-obj.fin-code-acc     = bfps_arh-fin-doc-s-tax-nal-obj.fin-code-acc     and
                                               rbfps_arh-fin-doc-s-tax-nal-obj.curr-code        = bfps_arh-fin-doc-s-tax-nal-obj.curr-code        and
                                               rbfps_arh-fin-doc-s-tax-nal-obj.fin-ext-doc-type = bfps_arh-fin-doc-s-tax-nal-obj.fin-ext-doc-type and
                                               rbfps_arh-fin-doc-s-tax-nal-obj.calc-curr-code   = bfps_arh-fin-doc-s-tax-nal-obj.calc-curr-code   and
                                               rbfps_arh-fin-doc-s-tax-nal-obj.vat-pc           = bfps_arh-fin-doc-s-tax-nal-obj.vat-pc           and
                                               rbfps_arh-fin-doc-s-tax-nal-obj.slt-pc           = bfps_arh-fin-doc-s-tax-nal-obj.slt-pc           and
                                               rbfps_arh-fin-doc-s-tax-nal-obj.with-vat         = bfps_arh-fin-doc-s-tax-nal-obj.with-vat         and
                                               rbfps_arh-fin-doc-s-tax-nal-obj.with-slt         = bfps_arh-fin-doc-s-tax-nal-obj.with-slt         and
                                               rbfps_arh-fin-doc-s-tax-nal-obj.sum-type         = bfps_arh-fin-doc-s-tax-nal-obj.sum-type         and
                                               rbfps_arh-fin-doc-s-tax-nal-obj.fact-order       > bfps_arh-fin-doc-s-tax-nal-obj.fact-order       use-index pi exclusive-lock on error undo, return error return-value :
   assign
     rbfps_arh-fin-doc-s-tax-nal-obj.expense     = rbfps_arh-fin-doc-s-tax-nal-obj.expense     + parsum-doc
     rbfps_arh-fin-doc-s-tax-nal-obj.expense-vat = rbfps_arh-fin-doc-s-tax-nal-obj.expense-vat + parsum-vat-doc
     rbfps_arh-fin-doc-s-tax-nal-obj.expense-slt = rbfps_arh-fin-doc-s-tax-nal-obj.expense-slt + parsum-slt-doc
   .
end.
if parmode = "close":u then do:
  find last bors_arh-fin-doc-s-tax-nal-obj where bors_arh-fin-doc-s-tax-nal-obj.host-code         = parhost-code             and
                                                 bors_arh-fin-doc-s-tax-nal-obj.obj-type          = parobj-type              and
                                                 bors_arh-fin-doc-s-tax-nal-obj.obj-code          = parobj-code              and
                                                 bors_arh-fin-doc-s-tax-nal-obj.cli-type          = parreceiver-type         and
                                                 bors_arh-fin-doc-s-tax-nal-obj.cli-code          = parreceiver-code         and
                                                 bors_arh-fin-doc-s-tax-nal-obj.fin-code-acc      = parreceiver-fin-code-acc and
                                                 bors_arh-fin-doc-s-tax-nal-obj.curr-code         = parcurr-code             and
                                                 bors_arh-fin-doc-s-tax-nal-obj.fin-ext-doc-type  = parfin-ext-doc-type      and
                                                 bors_arh-fin-doc-s-tax-nal-obj.calc-curr-code    = parcurr-code             and
                                                 bors_arh-fin-doc-s-tax-nal-obj.vat-pc            = parvat-pc                and
                                                 bors_arh-fin-doc-s-tax-nal-obj.slt-pc            = parslt-pc                and
                                                 bors_arh-fin-doc-s-tax-nal-obj.with-vat          = parwith-vat              and
                                                 bors_arh-fin-doc-s-tax-nal-obj.with-slt          = parwith-slt              and
                                                 bors_arh-fin-doc-s-tax-nal-obj.sum-type          = parsum-type              and
                                                 bors_arh-fin-doc-s-tax-nal-obj.fact-order        < parfact-order            use-index pi no-error.
  create bfrs_arh-fin-doc-s-tax-nal-obj.
  assign
    bfrs_arh-fin-doc-s-tax-nal-obj.host-code        = parhost-code
    bfrs_arh-fin-doc-s-tax-nal-obj.obj-type         = parobj-type
    bfrs_arh-fin-doc-s-tax-nal-obj.obj-code         = parobj-code
    bfrs_arh-fin-doc-s-tax-nal-obj.cli-type         = parreceiver-type
    bfrs_arh-fin-doc-s-tax-nal-obj.cli-code         = parreceiver-code
    bfrs_arh-fin-doc-s-tax-nal-obj.fin-code-acc     = parreceiver-fin-code-acc
    bfrs_arh-fin-doc-s-tax-nal-obj.curr-code        = parcurr-code
    bfrs_arh-fin-doc-s-tax-nal-obj.fin-ext-doc-type = parfin-ext-doc-type
    bfrs_arh-fin-doc-s-tax-nal-obj.calc-curr-code   = parcurr-code
    bfrs_arh-fin-doc-s-tax-nal-obj.vat-pc           = parvat-pc
    bfrs_arh-fin-doc-s-tax-nal-obj.slt-pc           = parslt-pc
    bfrs_arh-fin-doc-s-tax-nal-obj.with-vat         = parwith-vat
    bfrs_arh-fin-doc-s-tax-nal-obj.with-slt         = parwith-slt
    bfrs_arh-fin-doc-s-tax-nal-obj.sum-type         = parsum-type
    bfrs_arh-fin-doc-s-tax-nal-obj.cource-des       = "s":u
    bfrs_arh-fin-doc-s-tax-nal-obj.fact-order       = parfact-order
    bfrs_arh-fin-doc-s-tax-nal-obj.fin-doc-code     = parfin-doc-code
    bfrs_arh-fin-doc-s-tax-nal-obj.fact-date        = parfact-date
    bfrs_arh-fin-doc-s-tax-nal-obj.curr-code        = parcurr-code
  .
  assign
    bfrs_arh-fin-doc-s-tax-nal-obj.expense          = (if available bors_arh-fin-doc-s-tax-nal-obj then bors_arh-fin-doc-s-tax-nal-obj.expense     else 0)
    bfrs_arh-fin-doc-s-tax-nal-obj.expense-vat      = (if available bors_arh-fin-doc-s-tax-nal-obj then bors_arh-fin-doc-s-tax-nal-obj.expense-vat else 0)
    bfrs_arh-fin-doc-s-tax-nal-obj.expense-slt      = (if available bors_arh-fin-doc-s-tax-nal-obj then bors_arh-fin-doc-s-tax-nal-obj.expense-slt else 0)
    bfrs_arh-fin-doc-s-tax-nal-obj.income           = (if available bors_arh-fin-doc-s-tax-nal-obj then bors_arh-fin-doc-s-tax-nal-obj.income      else 0) + parsum-doc
    bfrs_arh-fin-doc-s-tax-nal-obj.income-vat       = (if available bors_arh-fin-doc-s-tax-nal-obj then bors_arh-fin-doc-s-tax-nal-obj.income-vat  else 0) + parsum-vat-doc
    bfrs_arh-fin-doc-s-tax-nal-obj.income-slt       = (if available bors_arh-fin-doc-s-tax-nal-obj then bors_arh-fin-doc-s-tax-nal-obj.income-slt  else 0) + parsum-slt-doc
  .
end.
else do:
  find first bfrs_arh-fin-doc-s-tax-nal-obj where bfrs_arh-fin-doc-s-tax-nal-obj.host-code         = parhost-code             and
                                                  bfrs_arh-fin-doc-s-tax-nal-obj.obj-type          = parobj-type              and
                                                  bfrs_arh-fin-doc-s-tax-nal-obj.obj-code          = parobj-code              and
                                                  bfrs_arh-fin-doc-s-tax-nal-obj.cli-type          = parreceiver-type         and
                                                  bfrs_arh-fin-doc-s-tax-nal-obj.cli-code          = parreceiver-code         and
                                                  bfrs_arh-fin-doc-s-tax-nal-obj.fin-code-acc      = parreceiver-fin-code-acc and
                                                  bfrs_arh-fin-doc-s-tax-nal-obj.curr-code         = parcurr-code             and
                                                  bfrs_arh-fin-doc-s-tax-nal-obj.fin-ext-doc-type  = parfin-ext-doc-type      and
                                                  bfrs_arh-fin-doc-s-tax-nal-obj.calc-curr-code    = parcurr-code             and
                                                  bfrs_arh-fin-doc-s-tax-nal-obj.vat-pc            = parvat-pc                and
                                                  bfrs_arh-fin-doc-s-tax-nal-obj.slt-pc            = parslt-pc                and
                                                  bfrs_arh-fin-doc-s-tax-nal-obj.with-vat          = parwith-vat              and
                                                  bfrs_arh-fin-doc-s-tax-nal-obj.with-slt          = parwith-slt              and
                                                  bfrs_arh-fin-doc-s-tax-nal-obj.sum-type          = parsum-type              and
                                                  bfrs_arh-fin-doc-s-tax-nal-obj.fact-order        = parfact-order            exclusive-lock.
end.
for each rbfrs_arh-fin-doc-s-tax-nal-obj where rbfrs_arh-fin-doc-s-tax-nal-obj.host-code        = bfrs_arh-fin-doc-s-tax-nal-obj.host-code        and
                                               rbfrs_arh-fin-doc-s-tax-nal-obj.obj-type         = bfrs_arh-fin-doc-s-tax-nal-obj.obj-type         and
                                               rbfrs_arh-fin-doc-s-tax-nal-obj.obj-code         = bfrs_arh-fin-doc-s-tax-nal-obj.obj-code         and
                                               rbfrs_arh-fin-doc-s-tax-nal-obj.cli-type         = parreceiver-type                                and
                                               rbfrs_arh-fin-doc-s-tax-nal-obj.cli-code         = parreceiver-code                                and
                                               rbfrs_arh-fin-doc-s-tax-nal-obj.fin-code-acc     = bfrs_arh-fin-doc-s-tax-nal-obj.fin-code-acc     and
                                               rbfrs_arh-fin-doc-s-tax-nal-obj.curr-code        = bfrs_arh-fin-doc-s-tax-nal-obj.curr-code        and
                                               rbfrs_arh-fin-doc-s-tax-nal-obj.fin-ext-doc-type = bfrs_arh-fin-doc-s-tax-nal-obj.fin-ext-doc-type and
                                               rbfrs_arh-fin-doc-s-tax-nal-obj.calc-curr-code   = bfrs_arh-fin-doc-s-tax-nal-obj.calc-curr-code   and
                                               rbfrs_arh-fin-doc-s-tax-nal-obj.vat-pc           = bfrs_arh-fin-doc-s-tax-nal-obj.vat-pc           and
                                               rbfrs_arh-fin-doc-s-tax-nal-obj.slt-pc           = bfrs_arh-fin-doc-s-tax-nal-obj.slt-pc           and
                                               rbfrs_arh-fin-doc-s-tax-nal-obj.with-vat         = bfrs_arh-fin-doc-s-tax-nal-obj.with-vat         and
                                               rbfrs_arh-fin-doc-s-tax-nal-obj.with-slt         = bfrs_arh-fin-doc-s-tax-nal-obj.with-slt         and
                                               rbfrs_arh-fin-doc-s-tax-nal-obj.sum-type         = bfrs_arh-fin-doc-s-tax-nal-obj.sum-type         and
                                               rbfrs_arh-fin-doc-s-tax-nal-obj.fact-order       > bfrs_arh-fin-doc-s-tax-nal-obj.fact-order       use-index pi exclusive-lock on error undo, return error return-value:
  assign
    rbfrs_arh-fin-doc-s-tax-nal-obj.income     = rbfrs_arh-fin-doc-s-tax-nal-obj.income     + parsum-doc
    rbfrs_arh-fin-doc-s-tax-nal-obj.income-vat = rbfrs_arh-fin-doc-s-tax-nal-obj.income-vat + parsum-vat-doc
    rbfrs_arh-fin-doc-s-tax-nal-obj.income-slt = rbfrs_arh-fin-doc-s-tax-nal-obj.income-slt + parsum-slt-doc
  .
end.
if parmode = "delete":u then do:
  delete bfps_arh-fin-doc-s-tax-nal-obj.
  delete bfrs_arh-fin-doc-s-tax-nal-obj.
end.
if parcurr-code <> 0 then do:
  if parmode = "close":u then do:
    find last bopr_arh-fin-doc-s-tax-nal-obj where bopr_arh-fin-doc-s-tax-nal-obj.host-code        = parhost-code          and
                                                   bopr_arh-fin-doc-s-tax-nal-obj.obj-type         = parobj-type           and
                                                   bopr_arh-fin-doc-s-tax-nal-obj.obj-code         = parobj-code           and
                                                   bopr_arh-fin-doc-s-tax-nal-obj.cli-type         = parpayer-type         and
                                                   bopr_arh-fin-doc-s-tax-nal-obj.cli-code         = parpayer-code         and
                                                   bopr_arh-fin-doc-s-tax-nal-obj.fin-code-acc     = parpayer-fin-code-acc and
                                                   bopr_arh-fin-doc-s-tax-nal-obj.curr-code        = parcurr-code          and
                                                   bopr_arh-fin-doc-s-tax-nal-obj.fin-ext-doc-type = parfin-ext-doc-type   and
                                                   bopr_arh-fin-doc-s-tax-nal-obj.calc-curr-code   = 0                     and
                                                   bopr_arh-fin-doc-s-tax-nal-obj.vat-pc           = parvat-pc             and
                                                   bopr_arh-fin-doc-s-tax-nal-obj.slt-pc           = parslt-pc             and
                                                   bopr_arh-fin-doc-s-tax-nal-obj.with-vat         = parwith-vat           and
                                                   bopr_arh-fin-doc-s-tax-nal-obj.with-slt         = parwith-slt           and
                                                   bopr_arh-fin-doc-s-tax-nal-obj.sum-type         = parsum-type           and
                                                   bopr_arh-fin-doc-s-tax-nal-obj.fact-order       < parfact-order         use-index pi no-error.
    create bfpr_arh-fin-doc-s-tax-nal-obj.
    assign
      bfpr_arh-fin-doc-s-tax-nal-obj.host-code        = parhost-code
      bfpr_arh-fin-doc-s-tax-nal-obj.obj-type         = parobj-type
      bfpr_arh-fin-doc-s-tax-nal-obj.obj-code         = parobj-code
      bfpr_arh-fin-doc-s-tax-nal-obj.cli-type         = parpayer-type
      bfpr_arh-fin-doc-s-tax-nal-obj.cli-code         = parpayer-code
      bfpr_arh-fin-doc-s-tax-nal-obj.fin-code-acc     = parpayer-fin-code-acc
      bfpr_arh-fin-doc-s-tax-nal-obj.curr-code        = parcurr-code
      bfpr_arh-fin-doc-s-tax-nal-obj.fin-ext-doc-type = parfin-ext-doc-type
      bfpr_arh-fin-doc-s-tax-nal-obj.calc-curr-code   = 0
      bfpr_arh-fin-doc-s-tax-nal-obj.vat-pc           = parvat-pc
      bfpr_arh-fin-doc-s-tax-nal-obj.slt-pc           = parslt-pc
      bfpr_arh-fin-doc-s-tax-nal-obj.with-vat         = parwith-vat
      bfpr_arh-fin-doc-s-tax-nal-obj.with-slt         = parwith-slt
      bfpr_arh-fin-doc-s-tax-nal-obj.sum-type         = parsum-type
      bfpr_arh-fin-doc-s-tax-nal-obj.cource-des       = "r":u
      bfpr_arh-fin-doc-s-tax-nal-obj.fact-order       = parfact-order
      bfpr_arh-fin-doc-s-tax-nal-obj.fin-doc-code     = parfin-doc-code
      bfpr_arh-fin-doc-s-tax-nal-obj.fact-date        = parfact-date
      bfpr_arh-fin-doc-s-tax-nal-obj.curr-code        = parcurr-code
      bfpr_arh-fin-doc-s-tax-nal-obj.income           = (if available bopr_arh-fin-doc-s-tax-nal-obj then bopr_arh-fin-doc-s-tax-nal-obj.income      else 0)
      bfpr_arh-fin-doc-s-tax-nal-obj.income-vat       = (if available bopr_arh-fin-doc-s-tax-nal-obj then bopr_arh-fin-doc-s-tax-nal-obj.income-vat  else 0)
      bfpr_arh-fin-doc-s-tax-nal-obj.income-slt       = (if available bopr_arh-fin-doc-s-tax-nal-obj then bopr_arh-fin-doc-s-tax-nal-obj.income-slt  else 0)
      bfpr_arh-fin-doc-s-tax-nal-obj.expense          = (if available bopr_arh-fin-doc-s-tax-nal-obj then bopr_arh-fin-doc-s-tax-nal-obj.expense     else 0) + parsum-rubl
      bfpr_arh-fin-doc-s-tax-nal-obj.expense-vat      = (if available bopr_arh-fin-doc-s-tax-nal-obj then bopr_arh-fin-doc-s-tax-nal-obj.expense-vat else 0) + parsum-vat-rubl
      bfpr_arh-fin-doc-s-tax-nal-obj.expense-slt      = (if available bopr_arh-fin-doc-s-tax-nal-obj then bopr_arh-fin-doc-s-tax-nal-obj.expense-slt else 0) + parsum-slt-rubl
    .
  end.
  else do:
    find first bfpr_arh-fin-doc-s-tax-nal-obj where bfpr_arh-fin-doc-s-tax-nal-obj.host-code        = parhost-code          and
                                                    bfpr_arh-fin-doc-s-tax-nal-obj.obj-type         = parobj-type           and
                                                    bfpr_arh-fin-doc-s-tax-nal-obj.obj-code         = parobj-code           and
                                                    bfpr_arh-fin-doc-s-tax-nal-obj.cli-type         = parpayer-type         and
                                                    bfpr_arh-fin-doc-s-tax-nal-obj.cli-code         = parpayer-code         and
                                                    bfpr_arh-fin-doc-s-tax-nal-obj.fin-code-acc     = parpayer-fin-code-acc and
                                                    bfpr_arh-fin-doc-s-tax-nal-obj.curr-code        = parcurr-code          and
                                                    bfpr_arh-fin-doc-s-tax-nal-obj.fin-ext-doc-type = parfin-ext-doc-type   and
                                                    bfpr_arh-fin-doc-s-tax-nal-obj.calc-curr-code   = 0                     and
                                                    bfpr_arh-fin-doc-s-tax-nal-obj.vat-pc           = parvat-pc             and
                                                    bfpr_arh-fin-doc-s-tax-nal-obj.slt-pc           = parslt-pc             and
                                                    bfpr_arh-fin-doc-s-tax-nal-obj.with-vat         = parwith-vat           and
                                                    bfpr_arh-fin-doc-s-tax-nal-obj.with-slt         = parwith-slt           and
                                                    bfpr_arh-fin-doc-s-tax-nal-obj.sum-type         = parsum-type           and
                                                    bfpr_arh-fin-doc-s-tax-nal-obj.fact-order       = parfact-order         exclusive-lock.
  end.
  for each rbfpr_arh-fin-doc-s-tax-nal-obj where rbfpr_arh-fin-doc-s-tax-nal-obj.host-code        = bfpr_arh-fin-doc-s-tax-nal-obj.host-code        and
                                                 rbfpr_arh-fin-doc-s-tax-nal-obj.obj-type         = bfpr_arh-fin-doc-s-tax-nal-obj.obj-type         and
                                                 rbfpr_arh-fin-doc-s-tax-nal-obj.obj-code         = bfpr_arh-fin-doc-s-tax-nal-obj.obj-code         and
                                                 rbfpr_arh-fin-doc-s-tax-nal-obj.cli-type         = parpayer-type                                   and
                                                 rbfpr_arh-fin-doc-s-tax-nal-obj.cli-code         = parpayer-code                                   and
                                                 rbfpr_arh-fin-doc-s-tax-nal-obj.fin-code-acc     = bfpr_arh-fin-doc-s-tax-nal-obj.fin-code-acc     and
                                                 rbfpr_arh-fin-doc-s-tax-nal-obj.curr-code        = bfpr_arh-fin-doc-s-tax-nal-obj.curr-code        and
                                                 rbfpr_arh-fin-doc-s-tax-nal-obj.fin-ext-doc-type = bfpr_arh-fin-doc-s-tax-nal-obj.fin-ext-doc-type and
                                                 rbfpr_arh-fin-doc-s-tax-nal-obj.calc-curr-code   = bfpr_arh-fin-doc-s-tax-nal-obj.calc-curr-code   and
                                                 rbfpr_arh-fin-doc-s-tax-nal-obj.vat-pc           = bfpr_arh-fin-doc-s-tax-nal-obj.vat-pc           and
                                                 rbfpr_arh-fin-doc-s-tax-nal-obj.slt-pc           = bfpr_arh-fin-doc-s-tax-nal-obj.slt-pc           and
                                                 rbfpr_arh-fin-doc-s-tax-nal-obj.with-vat         = bfpr_arh-fin-doc-s-tax-nal-obj.with-vat         and
                                                 rbfpr_arh-fin-doc-s-tax-nal-obj.with-slt         = bfpr_arh-fin-doc-s-tax-nal-obj.with-slt         and
                                                 rbfpr_arh-fin-doc-s-tax-nal-obj.sum-type         = bfpr_arh-fin-doc-s-tax-nal-obj.sum-type         and
                                                 rbfpr_arh-fin-doc-s-tax-nal-obj.fact-order       > bfpr_arh-fin-doc-s-tax-nal-obj.fact-order       use-index pi exclusive-lock on error undo, return error return-value :
    assign
      rbfpr_arh-fin-doc-s-tax-nal-obj.expense     = rbfpr_arh-fin-doc-s-tax-nal-obj.expense     + parsum-rubl
      rbfpr_arh-fin-doc-s-tax-nal-obj.expense-vat = rbfpr_arh-fin-doc-s-tax-nal-obj.expense-vat + parsum-vat-rubl
      rbfpr_arh-fin-doc-s-tax-nal-obj.expense-slt = rbfpr_arh-fin-doc-s-tax-nal-obj.expense-slt + parsum-slt-rubl
    .
  end.
  if parmode = "close":u then do:
    find last borr_arh-fin-doc-s-tax-nal-obj where borr_arh-fin-doc-s-tax-nal-obj.host-code        = parhost-code             and
                                                   borr_arh-fin-doc-s-tax-nal-obj.obj-type         = parobj-type              and
                                                   borr_arh-fin-doc-s-tax-nal-obj.obj-code         = parobj-code              and
                                                   borr_arh-fin-doc-s-tax-nal-obj.cli-type         = parreceiver-type         and
                                                   borr_arh-fin-doc-s-tax-nal-obj.cli-code         = parreceiver-code         and
                                                   borr_arh-fin-doc-s-tax-nal-obj.fin-code-acc     = parreceiver-fin-code-acc and
                                                   borr_arh-fin-doc-s-tax-nal-obj.curr-code        = parcurr-code             and
                                                   borr_arh-fin-doc-s-tax-nal-obj.fin-ext-doc-type = parfin-ext-doc-type      and
                                                   borr_arh-fin-doc-s-tax-nal-obj.calc-curr-code   = 0                        and
                                                   borr_arh-fin-doc-s-tax-nal-obj.vat-pc           = parvat-pc                and
                                                   borr_arh-fin-doc-s-tax-nal-obj.slt-pc           = parslt-pc                and
                                                   borr_arh-fin-doc-s-tax-nal-obj.with-vat         = parwith-vat              and
                                                   borr_arh-fin-doc-s-tax-nal-obj.with-slt         = parwith-slt              and
                                                   borr_arh-fin-doc-s-tax-nal-obj.sum-type         = parsum-type              and
                                                   borr_arh-fin-doc-s-tax-nal-obj.fact-order       < parfact-order            use-index pi no-error.
    create bfrr_arh-fin-doc-s-tax-nal-obj.
    assign
      bfrr_arh-fin-doc-s-tax-nal-obj.host-code        = parhost-code
      bfrr_arh-fin-doc-s-tax-nal-obj.obj-type         = parobj-type
      bfrr_arh-fin-doc-s-tax-nal-obj.obj-code         = parobj-code
      bfrr_arh-fin-doc-s-tax-nal-obj.cli-type         = parreceiver-type
      bfrr_arh-fin-doc-s-tax-nal-obj.cli-code         = parreceiver-code
      bfrr_arh-fin-doc-s-tax-nal-obj.fin-code-acc     = parreceiver-fin-code-acc
      bfrr_arh-fin-doc-s-tax-nal-obj.curr-code        = parcurr-code
      bfrr_arh-fin-doc-s-tax-nal-obj.fin-ext-doc-type = parfin-ext-doc-type
      bfrr_arh-fin-doc-s-tax-nal-obj.calc-curr-code   = 0
      bfrr_arh-fin-doc-s-tax-nal-obj.vat-pc           = parvat-pc
      bfrr_arh-fin-doc-s-tax-nal-obj.slt-pc           = parslt-pc
      bfrr_arh-fin-doc-s-tax-nal-obj.with-vat         = parwith-vat
      bfrr_arh-fin-doc-s-tax-nal-obj.with-slt         = parwith-slt
      bfrr_arh-fin-doc-s-tax-nal-obj.sum-type         = parsum-type
      bfrr_arh-fin-doc-s-tax-nal-obj.cource-des       = "r":u
      bfrr_arh-fin-doc-s-tax-nal-obj.fact-order       = parfact-order
      bfrr_arh-fin-doc-s-tax-nal-obj.fin-doc-code     = parfin-doc-code
      bfrr_arh-fin-doc-s-tax-nal-obj.fact-date        = parfact-date
      bfrr_arh-fin-doc-s-tax-nal-obj.curr-code        = parcurr-code
    .
    assign
      bfrr_arh-fin-doc-s-tax-nal-obj.expense          = (if available borr_arh-fin-doc-s-tax-nal-obj then borr_arh-fin-doc-s-tax-nal-obj.expense     else 0)
      bfrr_arh-fin-doc-s-tax-nal-obj.expense-vat      = (if available borr_arh-fin-doc-s-tax-nal-obj then borr_arh-fin-doc-s-tax-nal-obj.expense-vat else 0)
      bfrr_arh-fin-doc-s-tax-nal-obj.expense-slt      = (if available borr_arh-fin-doc-s-tax-nal-obj then borr_arh-fin-doc-s-tax-nal-obj.expense-slt else 0)
      bfrr_arh-fin-doc-s-tax-nal-obj.income           = (if available borr_arh-fin-doc-s-tax-nal-obj then borr_arh-fin-doc-s-tax-nal-obj.income      else 0) + parsum-rubl
      bfrr_arh-fin-doc-s-tax-nal-obj.income-vat       = (if available borr_arh-fin-doc-s-tax-nal-obj then borr_arh-fin-doc-s-tax-nal-obj.income-vat  else 0) + parsum-vat-rubl
      bfrr_arh-fin-doc-s-tax-nal-obj.income-slt       = (if available borr_arh-fin-doc-s-tax-nal-obj then borr_arh-fin-doc-s-tax-nal-obj.income-slt  else 0) + parsum-slt-rubl
    .
  end.
  else do:
    find first bfrr_arh-fin-doc-s-tax-nal-obj where bfrr_arh-fin-doc-s-tax-nal-obj.host-code        = parhost-code             and
                                                    bfrr_arh-fin-doc-s-tax-nal-obj.obj-type         = parobj-type              and
                                                    bfrr_arh-fin-doc-s-tax-nal-obj.obj-code         = parobj-code              and
                                                    bfrr_arh-fin-doc-s-tax-nal-obj.cli-type         = parreceiver-type         and
                                                    bfrr_arh-fin-doc-s-tax-nal-obj.cli-code         = parreceiver-code         and
                                                    bfrr_arh-fin-doc-s-tax-nal-obj.fin-code-acc     = parreceiver-fin-code-acc and
                                                    bfrr_arh-fin-doc-s-tax-nal-obj.curr-code        = parcurr-code             and
                                                    bfrr_arh-fin-doc-s-tax-nal-obj.fin-ext-doc-type = parfin-ext-doc-type      and
                                                    bfrr_arh-fin-doc-s-tax-nal-obj.calc-curr-code   = 0                        and
                                                    bfrr_arh-fin-doc-s-tax-nal-obj.vat-pc           = parvat-pc                and
                                                    bfrr_arh-fin-doc-s-tax-nal-obj.slt-pc           = parslt-pc                and
                                                    bfrr_arh-fin-doc-s-tax-nal-obj.with-vat         = parwith-vat              and
                                                    bfrr_arh-fin-doc-s-tax-nal-obj.with-slt         = parwith-slt              and
                                                    bfrr_arh-fin-doc-s-tax-nal-obj.sum-type         = parsum-type              and
                                                    bfrr_arh-fin-doc-s-tax-nal-obj.fact-order       = parfact-order            exclusive-lock.
  end.
  for each rbfrr_arh-fin-doc-s-tax-nal-obj where rbfrr_arh-fin-doc-s-tax-nal-obj.host-code        = bfrr_arh-fin-doc-s-tax-nal-obj.host-code        and
                                                 rbfrr_arh-fin-doc-s-tax-nal-obj.obj-type         = bfrr_arh-fin-doc-s-tax-nal-obj.obj-type         and
                                                 rbfrr_arh-fin-doc-s-tax-nal-obj.obj-code         = bfrr_arh-fin-doc-s-tax-nal-obj.obj-code         and
                                                 rbfrr_arh-fin-doc-s-tax-nal-obj.cli-type         = parreceiver-type                                and
                                                 rbfrr_arh-fin-doc-s-tax-nal-obj.cli-code         = parreceiver-code                                and
                                                 rbfrr_arh-fin-doc-s-tax-nal-obj.fin-code-acc     = bfrr_arh-fin-doc-s-tax-nal-obj.fin-code-acc     and
                                                 rbfrr_arh-fin-doc-s-tax-nal-obj.curr-code        = bfrr_arh-fin-doc-s-tax-nal-obj.curr-code        and
                                                 rbfrr_arh-fin-doc-s-tax-nal-obj.fin-ext-doc-type = bfrr_arh-fin-doc-s-tax-nal-obj.fin-ext-doc-type and
                                                 rbfrr_arh-fin-doc-s-tax-nal-obj.calc-curr-code   = bfrr_arh-fin-doc-s-tax-nal-obj.calc-curr-code   and
                                                 rbfrr_arh-fin-doc-s-tax-nal-obj.vat-pc           = bfrr_arh-fin-doc-s-tax-nal-obj.vat-pc           and
                                                 rbfrr_arh-fin-doc-s-tax-nal-obj.slt-pc           = bfrr_arh-fin-doc-s-tax-nal-obj.slt-pc           and
                                                 rbfrr_arh-fin-doc-s-tax-nal-obj.with-vat         = bfrr_arh-fin-doc-s-tax-nal-obj.with-vat         and
                                                 rbfrr_arh-fin-doc-s-tax-nal-obj.with-slt         = bfrr_arh-fin-doc-s-tax-nal-obj.with-slt         and
                                                 rbfrr_arh-fin-doc-s-tax-nal-obj.sum-type         = bfrr_arh-fin-doc-s-tax-nal-obj.sum-type         and
                                                 rbfrr_arh-fin-doc-s-tax-nal-obj.fact-order       > bfrr_arh-fin-doc-s-tax-nal-obj.fact-order       use-index pi exclusive-lock on error undo, return error return-value:
    assign
      rbfrr_arh-fin-doc-s-tax-nal-obj.income     = rbfrr_arh-fin-doc-s-tax-nal-obj.income     + parsum-rubl
      rbfrr_arh-fin-doc-s-tax-nal-obj.income-vat = rbfrr_arh-fin-doc-s-tax-nal-obj.income-vat + parsum-vat-rubl
      rbfrr_arh-fin-doc-s-tax-nal-obj.income-slt = rbfrr_arh-fin-doc-s-tax-nal-obj.income-slt + parsum-slt-rubl
    .
  end.
  if parmode = "delete":u then do:
    delete bfpr_arh-fin-doc-s-tax-nal-obj.
    delete bfrr_arh-fin-doc-s-tax-nal-obj.
  end.
end.
if parbase-code <> parcurr-code and
   parbase-code <> 0            then do:
  if parmode = "close":u then do:
    find last bopb_arh-fin-doc-s-tax-nal-obj where bopb_arh-fin-doc-s-tax-nal-obj.host-code        = parhost-code          and
                                                   bopb_arh-fin-doc-s-tax-nal-obj.obj-type         = parobj-type           and
                                                   bopb_arh-fin-doc-s-tax-nal-obj.obj-code         = parobj-code           and
                                                   bopb_arh-fin-doc-s-tax-nal-obj.cli-type         = parpayer-type         and
                                                   bopb_arh-fin-doc-s-tax-nal-obj.cli-code         = parpayer-code         and
                                                   bopb_arh-fin-doc-s-tax-nal-obj.fin-code-acc     = parpayer-fin-code-acc and
                                                   bopb_arh-fin-doc-s-tax-nal-obj.curr-code        = parcurr-code          and
                                                   bopb_arh-fin-doc-s-tax-nal-obj.fin-ext-doc-type = parfin-ext-doc-type   and
                                                   bopb_arh-fin-doc-s-tax-nal-obj.calc-curr-code   = parbase-code          and
                                                   bopb_arh-fin-doc-s-tax-nal-obj.vat-pc           = parvat-pc             and
                                                   bopb_arh-fin-doc-s-tax-nal-obj.slt-pc           = parslt-pc             and
                                                   bopb_arh-fin-doc-s-tax-nal-obj.with-vat         = parwith-vat           and
                                                   bopb_arh-fin-doc-s-tax-nal-obj.with-slt         = parwith-slt           and
                                                   bopb_arh-fin-doc-s-tax-nal-obj.sum-type         = parsum-type           and
                                                   bopb_arh-fin-doc-s-tax-nal-obj.fact-order       < parfact-order         use-index pi no-error.
    create bfpb_arh-fin-doc-s-tax-nal-obj.
    assign
      bfpb_arh-fin-doc-s-tax-nal-obj.host-code        = parhost-code
      bfpb_arh-fin-doc-s-tax-nal-obj.obj-type         = parobj-type
      bfpb_arh-fin-doc-s-tax-nal-obj.obj-code         = parobj-code
      bfpb_arh-fin-doc-s-tax-nal-obj.cli-type         = parpayer-type
      bfpb_arh-fin-doc-s-tax-nal-obj.cli-code         = parpayer-code
      bfpb_arh-fin-doc-s-tax-nal-obj.fin-code-acc     = parpayer-fin-code-acc
      bfpb_arh-fin-doc-s-tax-nal-obj.curr-code        = parcurr-code
      bfpb_arh-fin-doc-s-tax-nal-obj.fin-ext-doc-type = parfin-ext-doc-type
      bfpb_arh-fin-doc-s-tax-nal-obj.calc-curr-code   = parbase-code
      bfpb_arh-fin-doc-s-tax-nal-obj.vat-pc           = parvat-pc
      bfpb_arh-fin-doc-s-tax-nal-obj.slt-pc           = parslt-pc
      bfpb_arh-fin-doc-s-tax-nal-obj.with-vat         = parwith-vat
      bfpb_arh-fin-doc-s-tax-nal-obj.with-slt         = parwith-slt
      bfpb_arh-fin-doc-s-tax-nal-obj.sum-type         = parsum-type
      bfpb_arh-fin-doc-s-tax-nal-obj.cource-des       = "b":u
      bfpb_arh-fin-doc-s-tax-nal-obj.fact-order       = parfact-order
      bfpb_arh-fin-doc-s-tax-nal-obj.fin-doc-code     = parfin-doc-code
      bfpb_arh-fin-doc-s-tax-nal-obj.fact-date        = parfact-date
      bfpb_arh-fin-doc-s-tax-nal-obj.curr-code        = parcurr-code
      bfpb_arh-fin-doc-s-tax-nal-obj.income           = (if available bopb_arh-fin-doc-s-tax-nal-obj then bopb_arh-fin-doc-s-tax-nal-obj.income      else 0)
      bfpb_arh-fin-doc-s-tax-nal-obj.income-vat       = (if available bopb_arh-fin-doc-s-tax-nal-obj then bopb_arh-fin-doc-s-tax-nal-obj.income-vat  else 0)
      bfpb_arh-fin-doc-s-tax-nal-obj.income-slt       = (if available bopb_arh-fin-doc-s-tax-nal-obj then bopb_arh-fin-doc-s-tax-nal-obj.income-slt  else 0)
      bfpb_arh-fin-doc-s-tax-nal-obj.expense          = (if available bopb_arh-fin-doc-s-tax-nal-obj then bopb_arh-fin-doc-s-tax-nal-obj.expense     else 0) + parsum-base
      bfpb_arh-fin-doc-s-tax-nal-obj.expense-vat      = (if available bopb_arh-fin-doc-s-tax-nal-obj then bopb_arh-fin-doc-s-tax-nal-obj.expense-vat else 0) + parsum-vat-base
      bfpb_arh-fin-doc-s-tax-nal-obj.expense-slt      = (if available bopb_arh-fin-doc-s-tax-nal-obj then bopb_arh-fin-doc-s-tax-nal-obj.expense-slt else 0) + parsum-slt-base
    .
  end.
  else do:
    find first bfpb_arh-fin-doc-s-tax-nal-obj where bfpb_arh-fin-doc-s-tax-nal-obj.host-code        = parhost-code          and
                                                    bfpb_arh-fin-doc-s-tax-nal-obj.obj-type         = parobj-type           and
                                                    bfpb_arh-fin-doc-s-tax-nal-obj.obj-code         = parobj-code           and
                                                    bfpb_arh-fin-doc-s-tax-nal-obj.cli-type         = parpayer-type         and
                                                    bfpb_arh-fin-doc-s-tax-nal-obj.cli-code         = parpayer-code         and
                                                    bfpb_arh-fin-doc-s-tax-nal-obj.fin-code-acc     = parpayer-fin-code-acc and
                                                    bfpb_arh-fin-doc-s-tax-nal-obj.curr-code        = parcurr-code          and
                                                    bfpb_arh-fin-doc-s-tax-nal-obj.fin-ext-doc-type = parfin-ext-doc-type   and
                                                    bfpb_arh-fin-doc-s-tax-nal-obj.calc-curr-code   = parbase-code          and
                                                    bfpb_arh-fin-doc-s-tax-nal-obj.vat-pc           = parvat-pc             and
                                                    bfpb_arh-fin-doc-s-tax-nal-obj.slt-pc           = parslt-pc             and
                                                    bfpb_arh-fin-doc-s-tax-nal-obj.with-vat         = parwith-vat           and
                                                    bfpb_arh-fin-doc-s-tax-nal-obj.with-slt         = parwith-slt           and
                                                    bfpb_arh-fin-doc-s-tax-nal-obj.sum-type         = parsum-type           and
                                                    bfpb_arh-fin-doc-s-tax-nal-obj.fact-order       = parfact-order         exclusive-lock.
  end.
  for each rbfpb_arh-fin-doc-s-tax-nal-obj where rbfpb_arh-fin-doc-s-tax-nal-obj.host-code        = bfpb_arh-fin-doc-s-tax-nal-obj.host-code        and
                                                 rbfpb_arh-fin-doc-s-tax-nal-obj.obj-type         = bfpb_arh-fin-doc-s-tax-nal-obj.obj-type         and
                                                 rbfpb_arh-fin-doc-s-tax-nal-obj.obj-code         = bfpb_arh-fin-doc-s-tax-nal-obj.obj-code         and
                                                 rbfpb_arh-fin-doc-s-tax-nal-obj.cli-type         = parpayer-type                                   and
                                                 rbfpb_arh-fin-doc-s-tax-nal-obj.cli-code         = parpayer-code                                   and
                                                 rbfpb_arh-fin-doc-s-tax-nal-obj.fin-code-acc     = bfpb_arh-fin-doc-s-tax-nal-obj.fin-code-acc     and
                                                 rbfpb_arh-fin-doc-s-tax-nal-obj.curr-code        = bfpb_arh-fin-doc-s-tax-nal-obj.curr-code        and
                                                 rbfpb_arh-fin-doc-s-tax-nal-obj.fin-ext-doc-type = bfpb_arh-fin-doc-s-tax-nal-obj.fin-ext-doc-type and
                                                 rbfpb_arh-fin-doc-s-tax-nal-obj.calc-curr-code   = bfpb_arh-fin-doc-s-tax-nal-obj.calc-curr-code   and
                                                 rbfpb_arh-fin-doc-s-tax-nal-obj.vat-pc           = bfpb_arh-fin-doc-s-tax-nal-obj.vat-pc           and
                                                 rbfpb_arh-fin-doc-s-tax-nal-obj.slt-pc           = bfpb_arh-fin-doc-s-tax-nal-obj.slt-pc           and
                                                 rbfpb_arh-fin-doc-s-tax-nal-obj.with-vat         = bfpb_arh-fin-doc-s-tax-nal-obj.with-vat         and
                                                 rbfpb_arh-fin-doc-s-tax-nal-obj.with-slt         = bfpb_arh-fin-doc-s-tax-nal-obj.with-slt         and
                                                 rbfpb_arh-fin-doc-s-tax-nal-obj.sum-type         = bfpb_arh-fin-doc-s-tax-nal-obj.sum-type         and
                                                 rbfpb_arh-fin-doc-s-tax-nal-obj.fact-order       > bfpb_arh-fin-doc-s-tax-nal-obj.fact-order       use-index pi exclusive-lock on error undo, return error return-value :
     assign
       rbfpb_arh-fin-doc-s-tax-nal-obj.expense     = rbfpb_arh-fin-doc-s-tax-nal-obj.expense     + parsum-base
       rbfpb_arh-fin-doc-s-tax-nal-obj.expense-vat = rbfpb_arh-fin-doc-s-tax-nal-obj.expense-vat + parsum-vat-base
       rbfpb_arh-fin-doc-s-tax-nal-obj.expense-slt = rbfpb_arh-fin-doc-s-tax-nal-obj.expense-slt + parsum-slt-base
     .
  end.
  if parmode = "close":u then do:
    find last borb_arh-fin-doc-s-tax-nal-obj where borb_arh-fin-doc-s-tax-nal-obj.host-code        = parhost-code             and
                                                   borb_arh-fin-doc-s-tax-nal-obj.obj-type         = parobj-type              and
                                                   borb_arh-fin-doc-s-tax-nal-obj.obj-code         = parobj-code              and
                                                   borb_arh-fin-doc-s-tax-nal-obj.cli-type         = parreceiver-type         and
                                                   borb_arh-fin-doc-s-tax-nal-obj.cli-code         = parreceiver-code         and
                                                   borb_arh-fin-doc-s-tax-nal-obj.fin-code-acc     = parreceiver-fin-code-acc and
                                                   borb_arh-fin-doc-s-tax-nal-obj.curr-code        = parcurr-code             and
                                                   borb_arh-fin-doc-s-tax-nal-obj.fin-ext-doc-type = parfin-ext-doc-type      and
                                                   borb_arh-fin-doc-s-tax-nal-obj.calc-curr-code   = parbase-code             and
                                                   borb_arh-fin-doc-s-tax-nal-obj.vat-pc           = parvat-pc                and
                                                   borb_arh-fin-doc-s-tax-nal-obj.slt-pc           = parslt-pc                and
                                                   borb_arh-fin-doc-s-tax-nal-obj.with-vat         = parwith-vat              and
                                                   borb_arh-fin-doc-s-tax-nal-obj.with-slt         = parwith-slt              and
                                                   borb_arh-fin-doc-s-tax-nal-obj.sum-type         = parsum-type              and
                                                   borb_arh-fin-doc-s-tax-nal-obj.fact-order       < parfact-order            use-index pi no-error.
    create bfrb_arh-fin-doc-s-tax-nal-obj.
    assign
      bfrb_arh-fin-doc-s-tax-nal-obj.host-code        = parhost-code
      bfrb_arh-fin-doc-s-tax-nal-obj.obj-type         = parobj-type
      bfrb_arh-fin-doc-s-tax-nal-obj.obj-code         = parobj-code
      bfrb_arh-fin-doc-s-tax-nal-obj.cli-type         = parreceiver-type
      bfrb_arh-fin-doc-s-tax-nal-obj.cli-code         = parreceiver-code
      bfrb_arh-fin-doc-s-tax-nal-obj.fin-code-acc     = parreceiver-fin-code-acc
      bfrb_arh-fin-doc-s-tax-nal-obj.curr-code        = parcurr-code
      bfrb_arh-fin-doc-s-tax-nal-obj.fin-ext-doc-type = parfin-ext-doc-type
      bfrb_arh-fin-doc-s-tax-nal-obj.calc-curr-code   = parbase-code
      bfrb_arh-fin-doc-s-tax-nal-obj.vat-pc           = parvat-pc
      bfrb_arh-fin-doc-s-tax-nal-obj.slt-pc           = parslt-pc
      bfrb_arh-fin-doc-s-tax-nal-obj.with-vat         = parwith-vat
      bfrb_arh-fin-doc-s-tax-nal-obj.with-slt         = parwith-slt
      bfrb_arh-fin-doc-s-tax-nal-obj.sum-type         = parsum-type
      bfrb_arh-fin-doc-s-tax-nal-obj.cource-des       = "b":u
      bfrb_arh-fin-doc-s-tax-nal-obj.fact-order       = parfact-order
      bfrb_arh-fin-doc-s-tax-nal-obj.fin-doc-code     = parfin-doc-code
      bfrb_arh-fin-doc-s-tax-nal-obj.fact-date        = parfact-date
      bfrb_arh-fin-doc-s-tax-nal-obj.curr-code        = parcurr-code
    .
    assign
      bfrb_arh-fin-doc-s-tax-nal-obj.expense          = (if available borb_arh-fin-doc-s-tax-nal-obj then borb_arh-fin-doc-s-tax-nal-obj.expense     else 0)
      bfrb_arh-fin-doc-s-tax-nal-obj.expense-vat      = (if available borb_arh-fin-doc-s-tax-nal-obj then borb_arh-fin-doc-s-tax-nal-obj.expense-vat else 0)
      bfrb_arh-fin-doc-s-tax-nal-obj.expense-slt      = (if available borb_arh-fin-doc-s-tax-nal-obj then borb_arh-fin-doc-s-tax-nal-obj.expense-slt else 0)
      bfrb_arh-fin-doc-s-tax-nal-obj.income           = (if available borb_arh-fin-doc-s-tax-nal-obj then borb_arh-fin-doc-s-tax-nal-obj.income      else 0) + parsum-base
      bfrb_arh-fin-doc-s-tax-nal-obj.income-vat       = (if available borb_arh-fin-doc-s-tax-nal-obj then borb_arh-fin-doc-s-tax-nal-obj.income-vat  else 0) + parsum-vat-base
      bfrb_arh-fin-doc-s-tax-nal-obj.income-slt       = (if available borb_arh-fin-doc-s-tax-nal-obj then borb_arh-fin-doc-s-tax-nal-obj.income-slt  else 0) + parsum-slt-base
    .
  end.
  else do:
    find first bfrb_arh-fin-doc-s-tax-nal-obj where bfrb_arh-fin-doc-s-tax-nal-obj.host-code        = parhost-code             and
                                                    bfrb_arh-fin-doc-s-tax-nal-obj.obj-type         = parobj-type              and
                                                    bfrb_arh-fin-doc-s-tax-nal-obj.obj-code         = parobj-code              and
                                                    bfrb_arh-fin-doc-s-tax-nal-obj.cli-type         = parreceiver-type         and
                                                    bfrb_arh-fin-doc-s-tax-nal-obj.cli-code         = parreceiver-code         and
                                                    bfrb_arh-fin-doc-s-tax-nal-obj.fin-code-acc     = parreceiver-fin-code-acc and
                                                    bfrb_arh-fin-doc-s-tax-nal-obj.curr-code        = parcurr-code             and
                                                    bfrb_arh-fin-doc-s-tax-nal-obj.fin-ext-doc-type = parfin-ext-doc-type      and
                                                    bfrb_arh-fin-doc-s-tax-nal-obj.calc-curr-code   = parbase-code             and
                                                    bfrb_arh-fin-doc-s-tax-nal-obj.vat-pc           = parvat-pc                and
                                                    bfrb_arh-fin-doc-s-tax-nal-obj.slt-pc           = parslt-pc                and
                                                    bfrb_arh-fin-doc-s-tax-nal-obj.with-vat         = parwith-vat              and
                                                    bfrb_arh-fin-doc-s-tax-nal-obj.with-slt         = parwith-slt              and
                                                    bfrb_arh-fin-doc-s-tax-nal-obj.sum-type         = parsum-type              and
                                                    bfrb_arh-fin-doc-s-tax-nal-obj.fact-order       = parfact-order            exclusive-lock.
  end.
  for each rbfrb_arh-fin-doc-s-tax-nal-obj where rbfrb_arh-fin-doc-s-tax-nal-obj.host-code        = bfrb_arh-fin-doc-s-tax-nal-obj.host-code        and
                                                 rbfrb_arh-fin-doc-s-tax-nal-obj.obj-type         = bfrb_arh-fin-doc-s-tax-nal-obj.obj-type         and
                                                 rbfrb_arh-fin-doc-s-tax-nal-obj.obj-code         = bfrb_arh-fin-doc-s-tax-nal-obj.obj-code         and
                                                 rbfrb_arh-fin-doc-s-tax-nal-obj.cli-type         = parreceiver-type                                and
                                                 rbfrb_arh-fin-doc-s-tax-nal-obj.cli-code         = parreceiver-code                                and
                                                 rbfrb_arh-fin-doc-s-tax-nal-obj.fin-code-acc     = bfrb_arh-fin-doc-s-tax-nal-obj.fin-code-acc     and
                                                 rbfrb_arh-fin-doc-s-tax-nal-obj.curr-code        = bfrb_arh-fin-doc-s-tax-nal-obj.curr-code        and
                                                 rbfrb_arh-fin-doc-s-tax-nal-obj.fin-ext-doc-type = bfrb_arh-fin-doc-s-tax-nal-obj.fin-ext-doc-type and
                                                 rbfrb_arh-fin-doc-s-tax-nal-obj.calc-curr-code   = bfrb_arh-fin-doc-s-tax-nal-obj.calc-curr-code   and
                                                 rbfrb_arh-fin-doc-s-tax-nal-obj.vat-pc           = bfrb_arh-fin-doc-s-tax-nal-obj.vat-pc           and
                                                 rbfrb_arh-fin-doc-s-tax-nal-obj.slt-pc           = bfrb_arh-fin-doc-s-tax-nal-obj.slt-pc           and
                                                 rbfrb_arh-fin-doc-s-tax-nal-obj.with-vat         = bfrb_arh-fin-doc-s-tax-nal-obj.with-vat         and
                                                 rbfrb_arh-fin-doc-s-tax-nal-obj.with-slt         = bfrb_arh-fin-doc-s-tax-nal-obj.with-slt         and
                                                 rbfrb_arh-fin-doc-s-tax-nal-obj.sum-type         = bfrb_arh-fin-doc-s-tax-nal-obj.sum-type         and
                                                 rbfrb_arh-fin-doc-s-tax-nal-obj.fact-order       > bfrb_arh-fin-doc-s-tax-nal-obj.fact-order       use-index pi exclusive-lock on error undo, return error return-value:
    assign
      rbfrb_arh-fin-doc-s-tax-nal-obj.income     = rbfrb_arh-fin-doc-s-tax-nal-obj.income     + parsum-base
      rbfrb_arh-fin-doc-s-tax-nal-obj.income-vat = rbfrb_arh-fin-doc-s-tax-nal-obj.income-vat + parsum-vat-base
      rbfrb_arh-fin-doc-s-tax-nal-obj.income-slt = rbfrb_arh-fin-doc-s-tax-nal-obj.income-slt + parsum-slt-base
    .
  end.
  if parmode = "delete":u then do:
    delete bfpb_arh-fin-doc-s-tax-nal-obj.
    delete bfrb_arh-fin-doc-s-tax-nal-obj.
  end.
end.
end.
end procedure.
