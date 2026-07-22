define temp-table tt-chs-parts no-undo like ub.parts.
define input  parameter parmode               as   character              no-undo.
define input  parameter pargds-code           like ub.goods.gds-code      no-undo.
define input  parameter parcli-type           like ub.trn-doc.cli-type    no-undo.
define input  parameter parcli-code           like ub.trn-doc.cli-code    no-undo.
define input  parameter parobj-type           like ub.clients.obj-type    no-undo.
define input  parameter parobj-code           like ub.clients.obj-code    no-undo.
define input  parameter parin-code            like ub.parts.in-code       no-undo.
define input  parameter parout-code           like ub.parts.out-code      no-undo.
define input  parameter parpart-code          like ub.parts.part-code     no-undo.
define input  parameter parbase-rate          like ub.trn-doc.base-rate   no-undo.
define input  parameter parbase-scale         like ub.trn-doc.base-scale  no-undo.
define input  parameter parexch-code          like ub.trn-doc.exch-code   no-undo.
define input  parameter parexch-rate          like ub.trn-doc.exch-rate   no-undo.
define input  parameter parexch-scale         like ub.trn-doc.exch-scale  no-undo.
define input  parameter paris-slt             as   logical                no-undo.
define input  parameter paris-road-tax        as   logical                no-undo.
define input  parameter parcontract-code      like ub.trn-doc.contract-code no-undo.
define input  parameter table for tt-chs-parts.
define output parameter parprice-base         like ub.parts.price-base    no-undo.
define output parameter parsum-base           as   decimal                no-undo.
define output parameter parprice-rubl         like ub.parts.price-rubl    no-undo.
define output parameter parsum-rubl           as   decimal                no-undo.
define input-output parameter parcli-base-rate      like ub.parts.cli-base-rate no-undo.
define input-output parameter parvat-type           like ub.parts.vat-type      no-undo.
define input-output parameter parslt-type           like ub.parts.slt-type      no-undo.
define output parameter parprice-cli          like ub.parts.price-rubl    no-undo.
define output parameter parsum-cli            as   decimal                no-undo.
define output parameter parvat-pc             like ub.parts.vat-pc        no-undo.
define output parameter parvat-base           as   decimal                no-undo.
define output parameter parsum-vat-base       as   decimal                no-undo.
define output parameter parvat-rubl           as   decimal                no-undo.
define output parameter parsum-vat-rubl       as   decimal                no-undo.
define output parameter parvat-cli            as   decimal                no-undo.
define output parameter parsum-vat-cli        as   decimal                no-undo.
define output parameter parslt-pc             like ub.parts.vat-pc        no-undo.
define output parameter parslt-base           as   decimal                no-undo.
define output parameter parsum-slt-base       as   decimal                no-undo.
define output parameter parslt-rubl           as   decimal                no-undo.
define output parameter parsum-slt-rubl       as   decimal                no-undo.
define output parameter parslt-cli            as   decimal                no-undo.
define output parameter parsum-slt-cli        as   decimal                no-undo.
define output parameter parroad-tax-base      like ub.parts.road-tax-base no-undo.
define output parameter parsum-road-tax-base  as   decimal                no-undo.
define output parameter parroad-tax-rubl      like ub.parts.road-tax-rubl no-undo.
define output parameter parsum-road-tax-rubl  as   decimal                no-undo.
define output parameter parroad-tax-cli       as   decimal                no-undo.
define output parameter parsum-road-tax-cli   as   decimal                no-undo.
define output parameter partransport-base     like ub.parts.road-tax-base no-undo.
define output parameter parsum-transport-base as   decimal                no-undo.
define output parameter partransport-rubl     like ub.parts.road-tax-rubl no-undo.
define output parameter parsum-transport-rubl as   decimal                no-undo.
define output parameter parother-base         like ub.parts.road-tax-base no-undo.
define output parameter parsum-other-base     as   decimal                no-undo.
define output parameter parother-rubl         like ub.parts.road-tax-rubl no-undo.
define output parameter parsum-other-rubl     as   decimal                no-undo.
define output parameter parpurch-code         like ub.parts.purch-code    no-undo.
define output parameter paris-ok as logical initial no no-undo.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Общий экран изменения цен".
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
procedure proc-alt-shift-f2:
  if not ibs.th.gbl.gbl-var:rcode
then
  run gbl\inidebug.p .
end.
procedure proc-alt-shift-f3:
  run gbl/prvssinf.p
    ( input this-procedure
    ) .
end.
define variable v-inform-launched as logical no-undo initial false .
procedure proc-alt-shift-f4:
  define variable v-action as character no-undo .
  if v-inform-launched = false then do:
    assign
      v-inform-launched = true
    .
    run gbl/d-inform.w
      (  input self
      ,  input this-procedure
      , output v-action
      ) no-error .
    run gbl/infrmact.p (input self, input this-procedure, input v-action) no-error .
    assign
      v-inform-launched = false
    .
  end.
end.
procedure proc-alt-f1:
  run gbl/corrhelp.p
    (input this-procedure
    ) .
end .
on alt-shift-f2 anywhere do:
  run proc-alt-shift-f2.
end.
on alt-shift-f3 anywhere do:
  run proc-alt-shift-f3 in this-procedure .
end.
on alt-shift-f4 anywhere do:
  run proc-alt-shift-f4 in this-procedure.
end.
on alt-f1 anywhere do:
  run proc-alt-f1 in this-procedure .
end.
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
def var vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
define temp-table tt-allsum-line      no-undo
field sum-type           as   character
field fact-qnty          like ub.doc-line.fact-qnty
field cli-qnty           like ub.doc-line.cli-qnty
field sum-dsc-base-doc   like ub.doc-line.price-base
field sum-dsc-rubl-doc   like ub.doc-line.price-base
field dsc-base-doc       like ub.doc-line.price-base
field dsc-rubl-doc       like ub.doc-line.price-base
field vat-base-doc       like ub.doc-line.price-base
field vat-rubl-doc       like ub.doc-line.price-base
field vat-base-buyer-doc like ub.doc-line.price-base
field vat-rubl-buyer-doc like ub.doc-line.price-base
field slt-base-doc       like ub.doc-line.price-base
field slt-rubl-doc       like ub.doc-line.price-base
field road-tax-base-doc  like ub.doc-line.price-base
field road-tax-rubl-doc  like ub.doc-line.price-base
field excise-base-doc    like ub.doc-line.price-base
field excise-rubl-doc    like ub.doc-line.price-base
field sum-dsc-base-acc   like ub.doc-line.price-base
field sum-dsc-rubl-acc   like ub.doc-line.price-base
field sum-dsc-cli-acc    like ub.doc-line.price-cli
field dsc-base-acc       like ub.doc-line.price-base
field dsc-rubl-acc       like ub.doc-line.price-base
field dsc-cli-acc        like ub.doc-line.price-cli
field vat-base-acc       like ub.doc-line.price-base
field vat-rubl-acc       like ub.doc-line.price-base
field vat-cli-acc        like ub.doc-line.price-cli
field slt-base-acc       like ub.doc-line.price-base
field slt-rubl-acc       like ub.doc-line.price-base
field slt-cli-acc        like ub.doc-line.price-cli
field road-tax-base-acc  like ub.doc-line.price-base
field road-tax-rubl-acc  like ub.doc-line.price-base
field road-tax-cli-acc   like ub.doc-line.price-cli
field excise-base-acc    like ub.doc-line.price-base
field excise-rubl-acc    like ub.doc-line.price-base
field excise-cli-acc     like ub.doc-line.price-cli
field transport-base-acc like ub.doc-line.price-base
field transport-rubl-acc like ub.doc-line.price-base
field transport-cli-acc  like ub.doc-line.price-cli
field other-base-acc     like ub.doc-line.price-base
field other-rubl-acc     like ub.doc-line.price-base
field other-cli-acc      like ub.doc-line.price-cli
field sum-dsc-base-cur   like ub.doc-line.price-base
field sum-dsc-rubl-cur   like ub.doc-line.price-base
field dsc-base-cur       like ub.doc-line.price-base
field dsc-rubl-cur       like ub.doc-line.price-base
field vat-base-cur       like ub.doc-line.price-base
field vat-rubl-cur       like ub.doc-line.price-base
field vat-base-buyer-cur like ub.doc-line.price-base
field vat-rubl-buyer-cur like ub.doc-line.price-base
field slt-base-cur       like ub.doc-line.price-base
field slt-rubl-cur       like ub.doc-line.price-base
field road-tax-base-cur  like ub.doc-line.price-base
field road-tax-rubl-cur  like ub.doc-line.price-base
field excise-base-cur    like ub.doc-line.price-base
field excise-rubl-cur    like ub.doc-line.price-base
index sum-type is primary unique sum-type.
.
define temp-table tt-allsum no-undo
field sum-type           as   character
field fact-qnty             as decimal
field cli-qnty              as decimal
field sum-dsc-base-doc      as decimal
field sum-dsc-rubl-doc      as decimal
field dsc-base-doc          as decimal
field dsc-rubl-doc          as decimal
field vat-base-doc          as decimal
field vat-rubl-doc          as decimal
field vat-base-buyer-doc    as decimal
field vat-rubl-buyer-doc    as decimal
field slt-base-doc          as decimal
field slt-rubl-doc          as decimal
field road-tax-base-doc     as decimal
field road-tax-rubl-doc     as decimal
field excise-base-doc       as decimal
field excise-rubl-doc       as decimal
field sum-dsc-base-acc      as decimal
field sum-dsc-rubl-acc      as decimal
field sum-dsc-cli-acc       as decimal
field dsc-base-acc          as decimal
field dsc-rubl-acc          as decimal
field dsc-cli-acc           as decimal
field vat-base-acc          as decimal
field vat-rubl-acc          as decimal
field vat-cli-acc           as decimal
field slt-base-acc          as decimal
field slt-rubl-acc          as decimal
field slt-cli-acc           as decimal
field road-tax-base-acc     as decimal
field road-tax-rubl-acc     as decimal
field road-tax-cli-acc      as decimal
field excise-base-acc       as decimal
field excise-rubl-acc       as decimal
field excise-cli-acc        as decimal
field transport-base-acc    as decimal
field transport-rubl-acc    as decimal
field transport-cli-acc     as decimal
field other-base-acc        as decimal
field other-rubl-acc        as decimal
field other-cli-acc         as decimal
field sum-dsc-base-cur      as decimal
field sum-dsc-rubl-cur      as decimal
field dsc-base-cur          as decimal
field dsc-rubl-cur          as decimal
field vat-base-cur          as decimal
field vat-rubl-cur          as decimal
field vat-base-buyer-cur    as decimal
field vat-rubl-buyer-cur    as decimal
field slt-base-cur          as decimal
field slt-rubl-cur          as decimal
field road-tax-base-cur     as decimal
field road-tax-rubl-cur     as decimal
field excise-base-cur       as decimal
field excise-rubl-cur       as decimal
index sum-type is primary unique sum-type.
define temp-table tt-clcparts no-undo like ub.parts
field part-cur-base like ub.gds-dtl.price-base
field part-cur-road-tax like ub.gds-dtl.price-base
field part-cur-excise like ub.gds-dtl.price-base
.
define variable v-calcbypart as log no-undo.
procedure clcprtsl_calc-parts :
define input parameter parrec-parts        as   recid                   no-undo.
define input parameter paris-doc           as   logical                 no-undo.
define input parameter paris-cur           as   logical                 no-undo.
define input parameter parroad-tax         like ub.doc-line.road-tax    no-undo.
define input parameter parexcise           like ub.doc-line.excise      no-undo.
define input parameter parvat-pc           like ub.doc-line.vat-pc      no-undo.
define input parameter parcons-vat-pc      like ub.doc-line.cons-vat-pc no-undo.
define input parameter parslt-pc           like ub.doc-line.slt-pc      no-undo.
define input parameter parbase-rate        like ub.trn-doc.base-rate    no-undo.
define input parameter parbase-scale       like ub.trn-doc.base-scale   no-undo.
define input parameter parr-b              as   character               no-undo.
define input parameter parcur-base         like ub.gds-dtl.cur-base     no-undo.
define input parameter parcurroad-tax      like ub.doc-line.road-tax    no-undo.
define input parameter parcurexcise        like ub.doc-line.excise      no-undo.
define input parameter parcurvat-pc        like ub.doc-line.vat-pc      no-undo.
define input parameter parcurcons-vat-pc   like ub.doc-line.cons-vat-pc no-undo.
define input parameter parcurslt-pc        like ub.doc-line.slt-pc      no-undo.
define variable parartic        like ub.parts.artic         no-undo.
define variable parprod-type    like ub.parts.prod-type     no-undo.
define variable parprod-code    like ub.parts.prod-code     no-undo.
define variable pardoc-type     like ub.parts.doc-type      no-undo.
define variable pardoc-code     like ub.parts.out-code      no-undo.
define variable parobj-type     like ub.parts.obj-type      no-undo.
define variable parobj-code     like ub.parts.obj-code      no-undo.
define variable parprice-base   like ub.gds-dtl.price-base  no-undo.
define variable parprice-rubl   like ub.gds-dtl.price-rubl  no-undo.
define variable pardiscnt-base  like ub.gds-dtl.discnt-base no-undo.
define variable pardiscnt-rubl  like ub.gds-dtl.discnt-rubl no-undo.
define variable parfact-qnty    like ub.parts.fact-qnty     no-undo.
define variable parcli-qnty     like ub.parts.cli-qnty      no-undo.
define variable pardoc-qnty     like ub.parts.qnty          no-undo.
define variable parext-doc-type like ub.trn-doc.ext-doc-type no-undo.
define variable parcurartic        like ub.parts.artic         no-undo.
define variable parcurprod-type    like ub.parts.prod-type     no-undo.
define variable parcurprod-code    like ub.parts.prod-code     no-undo.
define variable parcurdoc-type     like ub.parts.doc-type      no-undo.
define variable parcurdoc-code     like ub.parts.out-code      no-undo.
define variable parcurobj-type     like ub.parts.obj-type      no-undo.
define variable parcurobj-code     like ub.parts.obj-code      no-undo.
define variable parcurprice-base   like ub.gds-dtl.price-base  no-undo.
define variable parcurprice-rubl   like ub.gds-dtl.price-rubl  no-undo.
define variable parcurdiscnt-base  like ub.gds-dtl.discnt-base no-undo.
define variable parcurdiscnt-rubl  like ub.gds-dtl.discnt-rubl no-undo.
define variable parcurfact-qnty    like ub.parts.fact-qnty     no-undo.
define variable parcurcli-qnty     like ub.parts.cli-qnty      no-undo.
define variable parcurdoc-qnty     like ub.parts.qnty          no-undo.
define variable parcurbase-rate    like ub.trn-doc.base-rate   no-undo.
define variable parcurbase-scale   like ub.trn-doc.base-scale  no-undo.
define variable parcurext-doc-type like ub.trn-doc.ext-doc-type no-undo.
define buffer bf_tt-allsum     for tt-allsum.
define buffer bfs_tt-allsum    for tt-allsum.
define buffer bfpc_tt-allsum   for tt-allsum.
define buffer bfspc_tt-allsum  for tt-allsum.
define buffer bfacc_tt-allsum  for tt-allsum.
define buffer bfsacc_tt-allsum for tt-allsum.
define buffer cl_tt-clcparts   for tt-clcparts.
define buffer bf_trn-doc       for ub.trn-doc.
define buffer bf_sysconf       for ub.sysconf.
    define buffer   in-vatp-trn-doccl  for ub.trn-doc .
    define buffer   in-vatp-partscl    for ub.parts   .
    define buffer   in-vatp-doccl      for ub.trn-doc .
    define buffer   in-vatp-goodscl    for ub.goods   .
    define buffer   in-vatp-sysconfcl  for ub.sysconf .
    define buffer   in-vatp_doc-attrcl for ub.doc-attr.
    define variable in-vatp-have-vat-sltcl       as   logical initial yes    no-undo.
    define variable vat-pc-loccl                 like ub.doc-line.vat-pc     no-undo.
    define variable varinvprbcl                  as   character              no-undo.
    define variable slt-pc-loccl                 like ub.doc-line.slt-pc     no-undo.
    define variable cli-base-ratecl              as   decimal                no-undo.
    define variable price-rubl-with-tax-loccl    like ub.doc-line.price-rubl no-undo.
    define variable price-base-with-tax-loccl    like ub.doc-line.price-base no-undo.
    define variable price-cli-with-tax-loccl     like ub.doc-line.price-cli  no-undo.
    define variable price-rubl-without-tax-loccl like ub.doc-line.price-rubl no-undo.
    define variable price-base-without-tax-loccl like ub.doc-line.price-base no-undo.
    define variable price-cli-without-tax-loccl  like ub.doc-line.price-base no-undo.
    define variable vat-base-loccl               like ub.doc-line.price-base no-undo.
    define variable vat-rubl-loccl               like ub.doc-line.price-rubl no-undo.
    define variable vat-cli-loccl                like ub.doc-line.price-rubl no-undo.
    define variable slt-base-loccl               like ub.doc-line.price-base no-undo.
    define variable slt-rubl-loccl               like ub.doc-line.price-rubl no-undo.
    define variable slt-cli-loccl                like ub.doc-line.price-rubl no-undo.
    define variable road-tax-base-loccl          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-rubl-loccl          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-cli-loccl           like ub.doc-line.road-tax   no-undo.
    define variable transport-base-loccl         like ub.doc-line.price-base no-undo.
    define variable transport-rubl-loccl         like ub.doc-line.price-rubl no-undo.
    define variable transport-cli-loccl          like ub.doc-line.price-rubl no-undo.
    define variable other-base-loccl             like ub.doc-line.price-base no-undo.
    define variable other-rubl-loccl             like ub.doc-line.price-rubl no-undo.
    define variable other-cli-loccl              like ub.doc-line.price-rubl no-undo.
    define variable exch-rate-cli-loccl          like ub.trn-doc.exch-rate   no-undo.
    define variable varinvatp-envdcl             as   character              no-undo.
    define variable varinvatp-typecl             as   character              no-undo.
    define  variable price-rubl-with-tax-salecl    like ub.doc-line.price-rubl no-undo.
    define  variable price-base-with-tax-salecl    like ub.doc-line.price-base no-undo.
    define  variable price-rubl-without-tax-salecl like ub.doc-line.price-rubl no-undo.
    define  variable price-base-without-tax-salecl like ub.doc-line.price-base no-undo.
    define  variable vat-base-salecl               like ub.doc-line.price-base no-undo.
    define  variable vat-rubl-salecl               like ub.doc-line.price-rubl no-undo.
    define  variable vat-base-buyercl              like ub.doc-line.price-base no-undo.
    define  variable vat-rubl-buyercl              like ub.doc-line.price-rubl no-undo.
    define  variable slt-base-salecl               like ub.doc-line.price-base no-undo.
    define  variable slt-rubl-salecl               like ub.doc-line.price-rubl no-undo.
    define  variable road-tax-base-salecl          like ub.doc-line.road-tax   no-undo.
    define  variable road-tax-rubl-salecl          like ub.doc-line.road-tax   no-undo.
    define  variable excise-base-salecl            like ub.doc-line.price-base no-undo.
    define  variable excise-rubl-salecl            like ub.doc-line.price-rubl no-undo.
    define  variable discnt-base-salecl            like ub.gds-dtl.discnt-base no-undo.
    define  variable discnt-rubl-salecl            like ub.gds-dtl.discnt-rubl no-undo.
    define buffer out-vatp_gds-dtlcl     for ub.gds-dtl.
    define buffer buf_out-vatp_gds-dtlcl for ub.gds-dtl.
    define buffer out-vatp_partscl       for ub.parts.
    define buffer out-vatp_sysconfcl     for ub.sysconf.
    define buffer out-vatp_doc-linecl    for ub.doc-line.
    define buffer out-vatp_goodscl       for ub.goods.
    define buffer out-vatp_trn-doccl     for ub.trn-doc.
    define buffer out-vatp_doc-attrcl    for ub.doc-attr.
    define variable varprice-base-conscl      like ub.doc-line.price-base initial 0.00 no-undo.
    define variable varprice-rubl-conscl      like ub.doc-line.price-rubl initial 0.00 no-undo.
    define variable varfrm-cnsv-typecl         as   character                           no-undo.
    define variable varfrm-cnsvcl              as   character                           no-undo.
    define variable varroot-nodecl             as   integer                             no-undo.
    define variable varempty-scalecl           as   logical                             no-undo.
    define variable varis-cons-parts-havecl    as   logical                             no-undo.
    define variable varsum-base-factovpcl      like ub.gds-dtl.price-base               no-undo.
    define variable varslt-base-factovpcl      like ub.gds-dtl.price-base               no-undo.
    define variable varvat-base-factovpcl      like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-base-factovpcl  like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-base-factovpcl      like ub.gds-dtl.price-base               no-undo.
    define variable varsum-base-docovpcl       like ub.gds-dtl.price-base               no-undo.
    define variable varslt-base-docovpcl       like ub.gds-dtl.price-base               no-undo.
    define variable varvat-base-docovpcl       like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-base-docovpcl   like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-base-docovpcl       like ub.gds-dtl.price-base               no-undo.
    define variable varsum-rubl-factovpcl      like ub.gds-dtl.price-base               no-undo.
    define variable varslt-rubl-factovpcl      like ub.gds-dtl.price-base               no-undo.
    define variable varvat-rubl-factovpcl      like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-rubl-factovpcl  like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-rubl-factovpcl      like ub.gds-dtl.price-base               no-undo.
    define variable varsum-rubl-docovpcl       like ub.gds-dtl.price-base               no-undo.
    define variable varslt-rubl-docovpcl       like ub.gds-dtl.price-base               no-undo.
    define variable varvat-rubl-docovpcl       like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-rubl-docovpcl   like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-rubl-docovpcl       like ub.gds-dtl.price-base               no-undo.
    define variable varfact-qntycl             like ub.parts.fact-qnty                  no-undo.
    define variable varcons-qntycl             like ub.parts.fact-qnty                  no-undo.
    define variable varis-one-gds-dtlcl        as   logical                             no-undo.
    define variable varcurclprice-base         like ub.gds-dtl.cur-base                 no-undo.
    define variable varcurclprice-rubl         like ub.gds-dtl.price-base               no-undo.
    define variable varcurcldiscnt-base        like ub.gds-dtl.cur-base                 no-undo.
    define variable varcurcldiscnt-rubl        like ub.gds-dtl.price-base               no-undo.
    define variable varoutvprbcl               as   character                           no-undo.
    define variable out-vatp-have-vat-sltcl    as   logical initial yes                 no-undo.
    define buffer   in-vatp-trn-dococl  for ub.trn-doc .
    define buffer   in-vatp-partsocl    for ub.parts   .
    define buffer   in-vatp-dococl      for ub.trn-doc .
    define buffer   in-vatp-goodsocl    for ub.goods   .
    define buffer   in-vatp-sysconfocl  for ub.sysconf .
    define buffer   in-vatp_doc-attrocl for ub.doc-attr.
    define variable in-vatp-have-vat-sltocl       as   logical initial yes    no-undo.
    define variable vat-pc-lococl                 like ub.doc-line.vat-pc     no-undo.
    define variable varinvprbocl                  as   character              no-undo.
    define variable slt-pc-lococl                 like ub.doc-line.slt-pc     no-undo.
    define variable cli-base-rateocl              as   decimal                no-undo.
    define variable price-rubl-with-tax-lococl    like ub.doc-line.price-rubl no-undo.
    define variable price-base-with-tax-lococl    like ub.doc-line.price-base no-undo.
    define variable price-cli-with-tax-lococl     like ub.doc-line.price-cli  no-undo.
    define variable price-rubl-without-tax-lococl like ub.doc-line.price-rubl no-undo.
    define variable price-base-without-tax-lococl like ub.doc-line.price-base no-undo.
    define variable price-cli-without-tax-lococl  like ub.doc-line.price-base no-undo.
    define variable vat-base-lococl               like ub.doc-line.price-base no-undo.
    define variable vat-rubl-lococl               like ub.doc-line.price-rubl no-undo.
    define variable vat-cli-lococl                like ub.doc-line.price-rubl no-undo.
    define variable slt-base-lococl               like ub.doc-line.price-base no-undo.
    define variable slt-rubl-lococl               like ub.doc-line.price-rubl no-undo.
    define variable slt-cli-lococl                like ub.doc-line.price-rubl no-undo.
    define variable road-tax-base-lococl          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-rubl-lococl          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-cli-lococl           like ub.doc-line.road-tax   no-undo.
    define variable transport-base-lococl         like ub.doc-line.price-base no-undo.
    define variable transport-rubl-lococl         like ub.doc-line.price-rubl no-undo.
    define variable transport-cli-lococl          like ub.doc-line.price-rubl no-undo.
    define variable other-base-lococl             like ub.doc-line.price-base no-undo.
    define variable other-rubl-lococl             like ub.doc-line.price-rubl no-undo.
    define variable other-cli-lococl              like ub.doc-line.price-rubl no-undo.
    define variable exch-rate-cli-lococl          like ub.trn-doc.exch-rate   no-undo.
    define variable varinvatp-envdocl             as   character              no-undo.
    define variable varinvatp-typeocl             as   character              no-undo.
    define  variable price-rubl-with-tax-salecur    like ub.doc-line.price-rubl no-undo.
    define  variable price-base-with-tax-salecur    like ub.doc-line.price-base no-undo.
    define  variable price-rubl-without-tax-salecur like ub.doc-line.price-rubl no-undo.
    define  variable price-base-without-tax-salecur like ub.doc-line.price-base no-undo.
    define  variable vat-base-salecur               like ub.doc-line.price-base no-undo.
    define  variable vat-rubl-salecur               like ub.doc-line.price-rubl no-undo.
    define  variable vat-base-buyercur              like ub.doc-line.price-base no-undo.
    define  variable vat-rubl-buyercur              like ub.doc-line.price-rubl no-undo.
    define  variable slt-base-salecur               like ub.doc-line.price-base no-undo.
    define  variable slt-rubl-salecur               like ub.doc-line.price-rubl no-undo.
    define  variable road-tax-base-salecur          like ub.doc-line.road-tax   no-undo.
    define  variable road-tax-rubl-salecur          like ub.doc-line.road-tax   no-undo.
    define  variable excise-base-salecur            like ub.doc-line.price-base no-undo.
    define  variable excise-rubl-salecur            like ub.doc-line.price-rubl no-undo.
    define  variable discnt-base-salecur            like ub.gds-dtl.discnt-base no-undo.
    define  variable discnt-rubl-salecur            like ub.gds-dtl.discnt-rubl no-undo.
    define buffer out-vatp_gds-dtlcur     for ub.gds-dtl.
    define buffer buf_out-vatp_gds-dtlcur for ub.gds-dtl.
    define buffer out-vatp_partscur       for ub.parts.
    define buffer out-vatp_sysconfcur     for ub.sysconf.
    define buffer out-vatp_doc-linecur    for ub.doc-line.
    define buffer out-vatp_goodscur       for ub.goods.
    define buffer out-vatp_trn-doccur     for ub.trn-doc.
    define buffer out-vatp_doc-attrcur    for ub.doc-attr.
    define variable varprice-base-conscur      like ub.doc-line.price-base initial 0.00 no-undo.
    define variable varprice-rubl-conscur      like ub.doc-line.price-rubl initial 0.00 no-undo.
    define variable varfrm-cnsv-typecur         as   character                           no-undo.
    define variable varfrm-cnsvcur              as   character                           no-undo.
    define variable varroot-nodecur             as   integer                             no-undo.
    define variable varempty-scalecur           as   logical                             no-undo.
    define variable varis-cons-parts-havecur    as   logical                             no-undo.
    define variable varsum-base-factovpcur      like ub.gds-dtl.price-base               no-undo.
    define variable varslt-base-factovpcur      like ub.gds-dtl.price-base               no-undo.
    define variable varvat-base-factovpcur      like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-base-factovpcur  like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-base-factovpcur      like ub.gds-dtl.price-base               no-undo.
    define variable varsum-base-docovpcur       like ub.gds-dtl.price-base               no-undo.
    define variable varslt-base-docovpcur       like ub.gds-dtl.price-base               no-undo.
    define variable varvat-base-docovpcur       like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-base-docovpcur   like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-base-docovpcur       like ub.gds-dtl.price-base               no-undo.
    define variable varsum-rubl-factovpcur      like ub.gds-dtl.price-base               no-undo.
    define variable varslt-rubl-factovpcur      like ub.gds-dtl.price-base               no-undo.
    define variable varvat-rubl-factovpcur      like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-rubl-factovpcur  like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-rubl-factovpcur      like ub.gds-dtl.price-base               no-undo.
    define variable varsum-rubl-docovpcur       like ub.gds-dtl.price-base               no-undo.
    define variable varslt-rubl-docovpcur       like ub.gds-dtl.price-base               no-undo.
    define variable varvat-rubl-docovpcur       like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-rubl-docovpcur   like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-rubl-docovpcur       like ub.gds-dtl.price-base               no-undo.
    define variable varfact-qntycur             like ub.parts.fact-qnty                  no-undo.
    define variable varcons-qntycur             like ub.parts.fact-qnty                  no-undo.
    define variable varis-one-gds-dtlcur        as   logical                             no-undo.
    define variable varcurcurprice-base         like ub.gds-dtl.cur-base                 no-undo.
    define variable varcurcurprice-rubl         like ub.gds-dtl.price-base               no-undo.
    define variable varcurcurdiscnt-base        like ub.gds-dtl.cur-base                 no-undo.
    define variable varcurcurdiscnt-rubl        like ub.gds-dtl.price-base               no-undo.
    define variable varoutvprbcur               as   character                           no-undo.
    define variable out-vatp-have-vat-sltcur    as   logical initial yes                 no-undo.
    define buffer   in-vatp-trn-dococur  for ub.trn-doc .
    define buffer   in-vatp-partsocur    for ub.parts   .
    define buffer   in-vatp-dococur      for ub.trn-doc .
    define buffer   in-vatp-goodsocur    for ub.goods   .
    define buffer   in-vatp-sysconfocur  for ub.sysconf .
    define buffer   in-vatp_doc-attrocur for ub.doc-attr.
    define variable in-vatp-have-vat-sltocur       as   logical initial yes    no-undo.
    define variable vat-pc-lococur                 like ub.doc-line.vat-pc     no-undo.
    define variable varinvprbocur                  as   character              no-undo.
    define variable slt-pc-lococur                 like ub.doc-line.slt-pc     no-undo.
    define variable cli-base-rateocur              as   decimal                no-undo.
    define variable price-rubl-with-tax-lococur    like ub.doc-line.price-rubl no-undo.
    define variable price-base-with-tax-lococur    like ub.doc-line.price-base no-undo.
    define variable price-cli-with-tax-lococur     like ub.doc-line.price-cli  no-undo.
    define variable price-rubl-without-tax-lococur like ub.doc-line.price-rubl no-undo.
    define variable price-base-without-tax-lococur like ub.doc-line.price-base no-undo.
    define variable price-cli-without-tax-lococur  like ub.doc-line.price-base no-undo.
    define variable vat-base-lococur               like ub.doc-line.price-base no-undo.
    define variable vat-rubl-lococur               like ub.doc-line.price-rubl no-undo.
    define variable vat-cli-lococur                like ub.doc-line.price-rubl no-undo.
    define variable slt-base-lococur               like ub.doc-line.price-base no-undo.
    define variable slt-rubl-lococur               like ub.doc-line.price-rubl no-undo.
    define variable slt-cli-lococur                like ub.doc-line.price-rubl no-undo.
    define variable road-tax-base-lococur          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-rubl-lococur          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-cli-lococur           like ub.doc-line.road-tax   no-undo.
    define variable transport-base-lococur         like ub.doc-line.price-base no-undo.
    define variable transport-rubl-lococur         like ub.doc-line.price-rubl no-undo.
    define variable transport-cli-lococur          like ub.doc-line.price-rubl no-undo.
    define variable other-base-lococur             like ub.doc-line.price-base no-undo.
    define variable other-rubl-lococur             like ub.doc-line.price-rubl no-undo.
    define variable other-cli-lococur              like ub.doc-line.price-rubl no-undo.
    define variable exch-rate-cli-lococur          like ub.trn-doc.exch-rate   no-undo.
    define variable varinvatp-envdocur             as   character              no-undo.
    define variable varinvatp-typeocur             as   character              no-undo.
do on error undo, return error return-value :
find first cl_tt-clcparts where recid(cl_tt-clcparts) = parrec-parts no-lock.
for each bf_tt-allsum on error undo, return error return-value :
  delete bf_tt-allsum.
end.
assign
  price-rubl-with-tax-loccl = cl_tt-clcparts.price-rubl
  price-base-with-tax-loccl = cl_tt-clcparts.price-base
.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprbcl
  )  .
  if cl_tt-clcparts.out-code = 'free-zone':U     or
     cl_tt-clcparts.out-code = 'out-zone':U   or
     cl_tt-clcparts.doc-type = 'акт':U then do:
    assign
      in-vatp-have-vat-sltcl = yes.
  end.
  else do:
    find first in-vatp_doc-attrcl no-lock
      where in-vatp_doc-attrcl.doc-code  = cl_tt-clcparts.out-code
        and in-vatp_doc-attrcl.attr-code = 'envd':U
      no-error .
    if not available in-vatp_doc-attrcl then do:
      assign
        in-vatp-have-vat-sltcl = yes.
    end.
    else do:
         in-vatp-have-vat-sltcl = no.
    end.
  end.
  assign
   price-cli-with-tax-loccl = cl_tt-clcparts.price-cli
   cli-base-ratecl          = cl_tt-clcparts.cli-base-rate.
  ASSIGN   road-tax-base-loccl  = (if cl_tt-clcparts.road-tax-base  = ? then 0 else cl_tt-clcparts.road-tax-base)
           road-tax-rubl-loccl  = (if cl_tt-clcparts.road-tax-rubl  = ? then 0 else cl_tt-clcparts.road-tax-rubl).
  ASSIGN  transport-base-loccl = (if cl_tt-clcparts.transport-base = ? then 0 else cl_tt-clcparts.transport-base)
          transport-rubl-loccl = (if cl_tt-clcparts.transport-rubl = ? then 0 else cl_tt-clcparts.transport-rubl)
          other-base-loccl     = (if cl_tt-clcparts.other-base     = ? then 0 else cl_tt-clcparts.other-base)
          other-rubl-loccl     = (if cl_tt-clcparts.other-rubl     = ? then 0 else cl_tt-clcparts.other-rubl)
          vat-pc-loccl         = (if cl_tt-clcparts.vat-pc         = ? then 0 else cl_tt-clcparts.vat-pc)
          slt-pc-loccl         = (if cl_tt-clcparts.slt-pc         = ? then 0 else cl_tt-clcparts.slt-pc).
          ASSIGN   slt-base-loccl    = (if in-vatp-have-vat-sltcl = no then 0 else (price-base-with-tax-loccl - ((if road-tax-base-loccl  = ? then 0 else road-tax-base-loccl) + (if transport-base-loccl = ? then 0 else transport-base-loccl) + (if other-base-loccl = ? then 0 else other-base-loccl)))                           * slt-pc-loccl / (100 + slt-pc-loccl))                        vat-base-loccl    = (if in-vatp-have-vat-sltcl = no then 0 else (price-base-with-tax-loccl - ((if road-tax-base-loccl  = ? then 0 else road-tax-base-loccl) + (if transport-base-loccl = ? then 0 else transport-base-loccl) + (if other-base-loccl = ? then 0 else other-base-loccl))) * (1 - slt-pc-loccl / (100 + slt-pc-loccl)) * vat-pc-loccl / (100 + vat-pc-loccl)).
    ASSIGN   slt-rubl-loccl    = (if in-vatp-have-vat-sltcl = no then 0 else (price-rubl-with-tax-loccl - ((if road-tax-rubl-loccl  = ? then 0 else road-tax-rubl-loccl) + (if transport-rubl-loccl = ? then 0 else transport-rubl-loccl) + (if other-rubl-loccl = ? then 0 else other-rubl-loccl)))                           * slt-pc-loccl / (100 + slt-pc-loccl))                        vat-rubl-loccl    = (if in-vatp-have-vat-sltcl = no then 0 else (price-rubl-with-tax-loccl - ((if road-tax-rubl-loccl  = ? then 0 else road-tax-rubl-loccl) + (if transport-rubl-loccl = ? then 0 else transport-rubl-loccl) + (if other-rubl-loccl = ? then 0 else other-rubl-loccl))) * (1 - slt-pc-loccl / (100 + slt-pc-loccl)) * vat-pc-loccl / (100 + vat-pc-loccl)).
  assign
    exch-rate-cli-loccl = (cl_tt-clcparts.price-rubl - transport-rubl-loccl - other-rubl-loccl - road-tax-rubl-loccl - (if cl_tt-clcparts.vat-type <> 'в т. ч.':U then vat-rubl-loccl else 0) - (if cl_tt-clcparts.slt-type <> 'в т. ч.':U then slt-rubl-loccl else 0)) / cl_tt-clcparts.price-cli .
  assign
    slt-cli-loccl        = slt-rubl-loccl       / exch-rate-cli-loccl
    vat-cli-loccl        = vat-rubl-loccl       / exch-rate-cli-loccl
    road-tax-cli-loccl   = road-tax-rubl-loccl  / exch-rate-cli-loccl
    transport-cli-loccl  = 0
    other-cli-loccl      = 0
  .
ASSIGN
          price-base-without-tax-loccl = price-base-with-tax-loccl - vat-base-loccl - slt-base-loccl - ((if road-tax-base-loccl  = ? then 0 else road-tax-base-loccl) + (if transport-base-loccl = ? then 0 else transport-base-loccl) + (if other-base-loccl = ? then 0 else other-base-loccl))
    price-rubl-without-tax-loccl = price-rubl-with-tax-loccl - vat-rubl-loccl - slt-rubl-loccl - ((if road-tax-rubl-loccl  = ? then 0 else road-tax-rubl-loccl) + (if transport-rubl-loccl = ? then 0 else transport-rubl-loccl) + (if other-rubl-loccl = ? then 0 else other-rubl-loccl))
.
if paris-doc then do:
  assign
    parartic     = cl_tt-clcparts.artic
    parprod-type = cl_tt-clcparts.prod-type
    parprod-code = cl_tt-clcparts.prod-code
    pardoc-type  = cl_tt-clcparts.doc-type
    pardoc-code  = cl_tt-clcparts.out-code
    parobj-type  = cl_tt-clcparts.obj-type
    parobj-code  = cl_tt-clcparts.obj-code.
if parext-doc-type = 'ot':U or
   parext-doc-type = ?                 then do:
  assign
   out-vatp-have-vat-sltcl = yes.
end.
else do:
  find first out-vatp_doc-attrcl no-lock
    where out-vatp_doc-attrcl.doc-code  = pardoc-code
      and out-vatp_doc-attrcl.attr-code = 'envd':U
      no-error .
  if not available out-vatp_doc-attrcl then do:
    assign
      out-vatp-have-vat-sltcl = yes.
  end.
  else do:
     out-vatp-have-vat-sltcl = no.
  end.
end.
find first out-vatp_goodscl where out-vatp_goodscl.artic     = parartic     and
                                   out-vatp_goodscl.prod-type = parprod-type and
                                   out-vatp_goodscl.prod-code = parprod-code no-lock.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rootnode in g#library
  (input  parartic
  ,input  parprod-type
  ,input  parprod-code
  ,output varroot-nodecl
  ) no-error .
if error-status :error then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка при определении корневого признака товара" skip
    "Артикул" parartic parprod-type parprod-code skip
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  undo, return error .
end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prtat in g#library
  (input  varroot-nodecl
  ,input  'empty-scale=request'
  ,output varempty-scalecl
  ) no-error .
if error-status :error then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка при определении атрибута признака" skip
    "Артикул" parartic parprod-type parprod-code skip
    "Признак" varroot-nodecl skip
    "Запрашивался атрибут" "empty-scale=request" skip
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  undo, return error .
end.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varoutvprbcl
  )  .
if varoutvprbcl = "base":u then do:
  assign
        road-tax-base-salecl    =  (if parroad-tax = ? then 0 else parroad-tax * 1)
    excise-base-salecl      =  (if parexcise   = ? then 0 else parexcise   * 1)
  .
end.
else do:
  assign
        road-tax-base-salecl    =  (if parroad-tax = ? then 0 else parroad-tax / parbase-rate * parbase-scale)
    excise-base-salecl      =  (if parexcise   = ? then 0 else parexcise   / parbase-rate * parbase-scale)
  .
end.
if varoutvprbcl = "rubl":u then do:
  assign
        road-tax-rubl-salecl    = (if parroad-tax = ? then 0 else parroad-tax * 1)
    excise-rubl-salecl      = (if parexcise   = ? then 0 else parexcise   * 1) .
end.
else do:
  assign
        road-tax-rubl-salecl    = (if parroad-tax = ? then 0 else parroad-tax * parbase-rate / parbase-scale)
    excise-rubl-salecl      = (if parexcise   = ? then 0 else parexcise   * parbase-rate / parbase-scale) .
end.
assign
  varis-cons-parts-havecl =  no.
assign
  varfact-qntycl       = 0
  varcons-qntycl       = 0
  varprice-base-conscl = 0
  varprice-rubl-conscl = 0.
find first out-vatp_doc-linecl where
           out-vatp_doc-linecl.doc-code   = pardoc-code
       and out-vatp_doc-linecl.artic      = parartic
       and out-vatp_doc-linecl.prod-type  = parprod-type
       and out-vatp_doc-linecl.prod-code  = parprod-code no-lock no-error.
if available out-vatp_doc-linecl           and
  (out-vatp_doc-linecl.status_ = 'запрос':U or out-vatp_goodscl.gds-type = 'у':U) then do:
  assign
    varfact-qntycl = out-vatp_doc-linecl.fact-qnty.
end.
else do:
  for each out-vatp_partscl where out-vatp_partscl.out-code   = pardoc-code
                               and out-vatp_partscl.obj-type   = parobj-type
                               and out-vatp_partscl.obj-code   = parobj-code
                               and out-vatp_partscl.artic      = parartic
                               and out-vatp_partscl.prod-type  = parprod-type
                               and out-vatp_partscl.prod-code  = parprod-code no-lock :
    if out-vatp_partscl.purch-code = 2 then do:
assign
  price-rubl-with-tax-lococl = out-vatp_partscl.price-rubl
  price-base-with-tax-lococl = out-vatp_partscl.price-base
.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprbocl
  )  .
  if out-vatp_partscl.out-code = 'free-zone':U     or
     out-vatp_partscl.out-code = 'out-zone':U   or
     out-vatp_partscl.doc-type = 'акт':U then do:
    assign
      in-vatp-have-vat-sltocl = yes.
  end.
  else do:
    find first in-vatp_doc-attrocl no-lock
      where in-vatp_doc-attrocl.doc-code  = out-vatp_partscl.out-code
        and in-vatp_doc-attrocl.attr-code = 'envd':U
      no-error .
    if not available in-vatp_doc-attrocl then do:
      assign
        in-vatp-have-vat-sltocl = yes.
    end.
    else do:
         in-vatp-have-vat-sltocl = no.
    end.
  end.
  assign
   price-cli-with-tax-lococl = out-vatp_partscl.price-cli
   cli-base-rateocl          = out-vatp_partscl.cli-base-rate.
  ASSIGN   road-tax-base-lococl  = (if out-vatp_partscl.road-tax-base  = ? then 0 else out-vatp_partscl.road-tax-base)
           road-tax-rubl-lococl  = (if out-vatp_partscl.road-tax-rubl  = ? then 0 else out-vatp_partscl.road-tax-rubl).
  ASSIGN  transport-base-lococl = (if out-vatp_partscl.transport-base = ? then 0 else out-vatp_partscl.transport-base)
          transport-rubl-lococl = (if out-vatp_partscl.transport-rubl = ? then 0 else out-vatp_partscl.transport-rubl)
          other-base-lococl     = (if out-vatp_partscl.other-base     = ? then 0 else out-vatp_partscl.other-base)
          other-rubl-lococl     = (if out-vatp_partscl.other-rubl     = ? then 0 else out-vatp_partscl.other-rubl)
          vat-pc-lococl         = (if out-vatp_partscl.vat-pc         = ? then 0 else out-vatp_partscl.vat-pc)
          slt-pc-lococl         = (if out-vatp_partscl.slt-pc         = ? then 0 else out-vatp_partscl.slt-pc).
          ASSIGN   slt-base-lococl    = (if in-vatp-have-vat-sltocl = no then 0 else (price-base-with-tax-lococl - ((if road-tax-base-lococl  = ? then 0 else road-tax-base-lococl) + (if transport-base-lococl = ? then 0 else transport-base-lococl) + (if other-base-lococl = ? then 0 else other-base-lococl)))                           * slt-pc-lococl / (100 + slt-pc-lococl))                        vat-base-lococl    = (if in-vatp-have-vat-sltocl = no then 0 else (price-base-with-tax-lococl - ((if road-tax-base-lococl  = ? then 0 else road-tax-base-lococl) + (if transport-base-lococl = ? then 0 else transport-base-lococl) + (if other-base-lococl = ? then 0 else other-base-lococl))) * (1 - slt-pc-lococl / (100 + slt-pc-lococl)) * vat-pc-lococl / (100 + vat-pc-lococl)).
    ASSIGN   slt-rubl-lococl    = (if in-vatp-have-vat-sltocl = no then 0 else (price-rubl-with-tax-lococl - ((if road-tax-rubl-lococl  = ? then 0 else road-tax-rubl-lococl) + (if transport-rubl-lococl = ? then 0 else transport-rubl-lococl) + (if other-rubl-lococl = ? then 0 else other-rubl-lococl)))                           * slt-pc-lococl / (100 + slt-pc-lococl))                        vat-rubl-lococl    = (if in-vatp-have-vat-sltocl = no then 0 else (price-rubl-with-tax-lococl - ((if road-tax-rubl-lococl  = ? then 0 else road-tax-rubl-lococl) + (if transport-rubl-lococl = ? then 0 else transport-rubl-lococl) + (if other-rubl-lococl = ? then 0 else other-rubl-lococl))) * (1 - slt-pc-lococl / (100 + slt-pc-lococl)) * vat-pc-lococl / (100 + vat-pc-lococl)).
  assign
    exch-rate-cli-lococl = (out-vatp_partscl.price-rubl - transport-rubl-lococl - other-rubl-lococl - road-tax-rubl-lococl - (if out-vatp_partscl.vat-type <> 'в т. ч.':U then vat-rubl-lococl else 0) - (if out-vatp_partscl.slt-type <> 'в т. ч.':U then slt-rubl-lococl else 0)) / out-vatp_partscl.price-cli .
  assign
    slt-cli-lococl        = slt-rubl-lococl       / exch-rate-cli-lococl
    vat-cli-lococl        = vat-rubl-lococl       / exch-rate-cli-lococl
    road-tax-cli-lococl   = road-tax-rubl-lococl  / exch-rate-cli-lococl
    transport-cli-lococl  = 0
    other-cli-lococl      = 0
  .
ASSIGN
          price-base-without-tax-lococl = price-base-with-tax-lococl - vat-base-lococl - slt-base-lococl - ((if road-tax-base-lococl  = ? then 0 else road-tax-base-lococl) + (if transport-base-lococl = ? then 0 else transport-base-lococl) + (if other-base-lococl = ? then 0 else other-base-lococl))
    price-rubl-without-tax-lococl = price-rubl-with-tax-lococl - vat-rubl-lococl - slt-rubl-lococl - ((if road-tax-rubl-lococl  = ? then 0 else road-tax-rubl-lococl) + (if transport-rubl-lococl = ? then 0 else transport-rubl-lococl) + (if other-rubl-lococl = ? then 0 else other-rubl-lococl))
.
      assign
        varprice-base-conscl = varprice-base-conscl + (price-base-with-tax-lococl - (if road-tax-base-lococl = ? then 0 else road-tax-base-lococl))* out-vatp_partscl.fact-qnty
        varprice-rubl-conscl = varprice-rubl-conscl + (price-rubl-with-tax-lococl - (if road-tax-rubl-lococl = ? then 0 else road-tax-rubl-lococl))* out-vatp_partscl.fact-qnty.
      assign
        varis-cons-parts-havecl = yes
        varcons-qntycl          = varcons-qntycl + out-vatp_partscl.fact-qnty.
    end.
    assign
      varfact-qntycl = varfact-qntycl + out-vatp_partscl.fact-qnty.
  end.
end.
assign
  varprice-base-conscl = varprice-base-conscl / varcons-qntycl
  varprice-rubl-conscl = varprice-rubl-conscl / varcons-qntycl.
if varprice-base-conscl = ? then do:
  assign
    varprice-base-conscl = 0.
end.
if varprice-rubl-conscl = ? then do:
  assign
    varprice-rubl-conscl = 0.
end.
assign
  varsum-base-factovpcl     = 0
  varslt-base-factovpcl     = 0
  varvat-base-factovpcl     = 0
  varvatcons-base-factovpcl = 0
  vardsc-base-factovpcl     = 0
  varsum-base-docovpcl      = 0
  varslt-base-docovpcl      = 0
  varvat-base-docovpcl      = 0
  varvatcons-base-docovpcl  = 0
  vardsc-base-docovpcl      = 0
  varsum-rubl-factovpcl     = 0
  varslt-rubl-factovpcl     = 0
  varvat-rubl-factovpcl     = 0
  varvatcons-rubl-factovpcl = 0
  vardsc-rubl-factovpcl     = 0
  varsum-rubl-docovpcl      = 0
  varslt-rubl-docovpcl      = 0
  varvat-rubl-docovpcl      = 0
  varvatcons-rubl-docovpcl  = 0
  vardsc-rubl-docovpcl      = 0.
assign
  varis-one-gds-dtlcl = no.
find first out-vatp_gds-dtlcl where out-vatp_gds-dtlcl.doc-code  = pardoc-code  and
                                     out-vatp_gds-dtlcl.artic     = parartic     and
                                     out-vatp_gds-dtlcl.prod-type = parprod-type and
                                     out-vatp_gds-dtlcl.prod-code = parprod-code no-lock no-error.
if available out-vatp_gds-dtlcl then do:
  find first buf_out-vatp_gds-dtlcl where buf_out-vatp_gds-dtlcl.doc-code  =  pardoc-code                and
                                           buf_out-vatp_gds-dtlcl.artic     =  parartic                   and
                                           buf_out-vatp_gds-dtlcl.prod-type =  parprod-type               and
                                           buf_out-vatp_gds-dtlcl.prod-code =  parprod-code               and
                                           recid(buf_out-vatp_gds-dtlcl)    <> recid(out-vatp_gds-dtlcl) no-lock no-error.
  if not available buf_out-vatp_gds-dtlcl then do:
    assign
      varis-one-gds-dtlcl = yes.
  end.
  if varoutvprbcl = "base":u then do:
    assign
      varcurclprice-base = out-vatp_gds-dtlcl.cur-base
      varcurclprice-rubl = out-vatp_gds-dtlcl.cur-base * ((out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl) / (out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base)).
  end.
  else do:
    assign
      varcurclprice-base = out-vatp_gds-dtlcl.cur-base / ((out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl) / (out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base))
      varcurclprice-rubl = out-vatp_gds-dtlcl.cur-base.
  end.
  if varempty-scalecl    = yes or
     varis-one-gds-dtlcl = yes   then do:
    assign
                price-base-with-tax-salecl    = (out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base)
        slt-base-salecl               = (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base                - road-tax-base-salecl) * parSLT-pc / (100 + parSLT-pc)
        vat-base-buyercl              = (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base                - road-tax-base-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-base-salecl) * parvat-pc / (100 + parvat-pc)
        discnt-base-salecl            = out-vatp_gds-dtlcl.discnt-base
                price-rubl-with-tax-salecl    = (out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl)
        slt-rubl-salecl               = (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl                - road-tax-rubl-salecl) * parSLT-pc / (100 + parSLT-pc)
        vat-rubl-buyercl              = (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl                - road-tax-rubl-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-rubl-salecl) * parvat-pc / (100 + parvat-pc)
        discnt-rubl-salecl            = out-vatp_gds-dtlcl.discnt-rubl
        .
    if pardoc-type = 'инв':U then do:
      ASSIGN
                vat-base-salecl               = (if out-vatp-have-vat-sltcl = no then 0 else (((out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base) - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base                - road-tax-base-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-base-salecl - varprice-base-conscl) * parcons-vat-pc / (100 + parcons-vat-pc) * out-vatp_gds-dtlcl.doc-qnty * varcons-qntycl / varfact-qntycl + ((out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base) - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base                - road-tax-base-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-base-salecl) * parvat-pc / (100 + parvat-pc) * out-vatp_gds-dtlcl.doc-qnty * (varfact-qntycl - varcons-qntycl) / varfact-qntycl) / varfact-qntycl)
                vat-rubl-salecl               = (if out-vatp-have-vat-sltcl = no then 0 else (((out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl) - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl                - road-tax-rubl-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-rubl-salecl - varprice-rubl-conscl) * parcons-vat-pc / (100 + parcons-vat-pc) * out-vatp_gds-dtlcl.doc-qnty * varcons-qntycl / varfact-qntycl + ((out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl) - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl                - road-tax-rubl-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-rubl-salecl) * parvat-pc / (100 + parvat-pc) * out-vatp_gds-dtlcl.doc-qnty * (varfact-qntycl - varcons-qntycl) / varfact-qntycl) / varfact-qntycl)
        .
    end.
    else do:
      ASSIGN
                vat-base-salecl               = (if out-vatp-have-vat-sltcl = no then 0 else (((out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base) - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base                - road-tax-base-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-base-salecl - varprice-base-conscl) * parcons-vat-pc / (100 + parcons-vat-pc) * out-vatp_gds-dtlcl.fact-qnty * varcons-qntycl / varfact-qntycl + ((out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base) - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base                - road-tax-base-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-base-salecl ) * parvat-pc / (100 + parvat-pc) * out-vatp_gds-dtlcl.fact-qnty * (varfact-qntycl - varcons-qntycl) / varfact-qntycl) / varfact-qntycl)
                vat-rubl-salecl               = (if out-vatp-have-vat-sltcl = no then 0 else (((out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl) - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl                - road-tax-rubl-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-rubl-salecl - varprice-rubl-conscl) * parcons-vat-pc / (100 + parcons-vat-pc) * out-vatp_gds-dtlcl.fact-qnty * varcons-qntycl / varfact-qntycl + ((out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl) - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl                - road-tax-rubl-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-rubl-salecl) * parvat-pc / (100 + parvat-pc) * out-vatp_gds-dtlcl.fact-qnty * (varfact-qntycl - varcons-qntycl) / varfact-qntycl) / varfact-qntycl)
        .
    end.
  end.
  else do:
    for each out-vatp_gds-dtlcl where out-vatp_gds-dtlcl.doc-code  = pardoc-code  and
                                       out-vatp_gds-dtlcl.artic     = parartic     and
                                       out-vatp_gds-dtlcl.prod-type = parprod-type and
                                       out-vatp_gds-dtlcl.prod-code = parprod-code no-lock :
      if varoutvprbcl = "base":u then do:
        assign
          varcurclprice-base = out-vatp_gds-dtlcl.cur-base
          varcurclprice-rubl = out-vatp_gds-dtlcl.cur-base * ((out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl) / (out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base)).
      end.
      else do:
        assign
          varcurclprice-base = out-vatp_gds-dtlcl.cur-base / ((out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl) / (out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base))
          varcurclprice-rubl = out-vatp_gds-dtlcl.cur-base.
      end.
      assign
             varsum-base-factovpcl = varsum-base-factovpcl + (out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base)                 * out-vatp_gds-dtlcl.fact-qnty
       varslt-base-factovpcl = varslt-base-factovpcl + (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base                - road-tax-base-salecl) * parSLT-pc / (100 + parSLT-pc)                   * out-vatp_gds-dtlcl.fact-qnty
       varvat-base-factovpcl = varvat-base-factovpcl + (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base                - road-tax-base-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-base-salecl) * parvat-pc / (100 + parvat-pc)                   * out-vatp_gds-dtlcl.fact-qnty
       varvatcons-base-factovpcl = varvatcons-base-factovpcl + (((out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base) - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base                - road-tax-base-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-base-salecl - varprice-base-conscl) * parcons-vat-pc / (100 + parcons-vat-pc) * out-vatp_gds-dtlcl.fact-qnty * varcons-qntycl / varfact-qntycl + ((out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base) - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base                - road-tax-base-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-base-salecl) * parvat-pc / (100 + parvat-pc) * out-vatp_gds-dtlcl.fact-qnty * (varfact-qntycl - varcons-qntycl) / varfact-qntycl)
       vardsc-base-factovpcl = vardsc-base-factovpcl + out-vatp_gds-dtlcl.discnt-base * out-vatp_gds-dtlcl.fact-qnty
       varsum-base-docovpcl  = varsum-base-docovpcl  + (out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base)                 * out-vatp_gds-dtlcl.doc-qnty
       varslt-base-docovpcl  = varslt-base-docovpcl  + (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base                - road-tax-base-salecl) * parSLT-pc / (100 + parSLT-pc)                   * out-vatp_gds-dtlcl.doc-qnty
       varvat-base-docovpcl  = varvat-base-docovpcl  + (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base                - road-tax-base-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-base-salecl) * parvat-pc / (100 + parvat-pc)                   * out-vatp_gds-dtlcl.doc-qnty
       varvatcons-base-docovpcl  = varvatcons-base-docovpcl  + (((out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base) - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base                - road-tax-base-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-base-salecl - varprice-base-conscl) * parcons-vat-pc / (100 + parcons-vat-pc) * out-vatp_gds-dtlcl.doc-qnty * varcons-qntycl / varfact-qntycl + ((out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base) - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base                - road-tax-base-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-base-salecl) * parvat-pc / (100 + parvat-pc) * out-vatp_gds-dtlcl.doc-qnty * (varfact-qntycl - varcons-qntycl) / varfact-qntycl)
       vardsc-base-docovpcl  = vardsc-base-docovpcl  + out-vatp_gds-dtlcl.discnt-base * out-vatp_gds-dtlcl.doc-qnty
      .
      assign
             varsum-rubl-factovpcl = varsum-rubl-factovpcl + (out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl)                 * out-vatp_gds-dtlcl.fact-qnty
       varslt-rubl-factovpcl = varslt-rubl-factovpcl + (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl                - road-tax-rubl-salecl) * parSLT-pc / (100 + parSLT-pc)                   * out-vatp_gds-dtlcl.fact-qnty
       varvat-rubl-factovpcl = varvat-rubl-factovpcl + (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl                - road-tax-rubl-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-rubl-salecl) * parvat-pc / (100 + parvat-pc)                   * out-vatp_gds-dtlcl.fact-qnty
       varvatcons-rubl-factovpcl = varvatcons-rubl-factovpcl + (((out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl) - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl                - road-tax-rubl-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-rubl-salecl - varprice-rubl-conscl) * parcons-vat-pc / (100 + parcons-vat-pc) * out-vatp_gds-dtlcl.fact-qnty * varcons-qntycl / varfact-qntycl + ((out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl) - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl                - road-tax-rubl-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-rubl-salecl) * parvat-pc / (100 + parvat-pc) * out-vatp_gds-dtlcl.fact-qnty * (varfact-qntycl - varcons-qntycl) / varfact-qntycl)
       vardsc-rubl-factovpcl = vardsc-rubl-factovpcl + out-vatp_gds-dtlcl.discnt-rubl * out-vatp_gds-dtlcl.fact-qnty
       varsum-rubl-docovpcl  = varsum-rubl-docovpcl  + (out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl)                 * out-vatp_gds-dtlcl.doc-qnty
       varslt-rubl-docovpcl  = varslt-rubl-docovpcl  + (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl                - road-tax-rubl-salecl) * parSLT-pc / (100 + parSLT-pc)                   * out-vatp_gds-dtlcl.doc-qnty
       varvat-rubl-docovpcl  = varvat-rubl-docovpcl  + (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl                - road-tax-rubl-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-rubl-salecl) * parvat-pc / (100 + parvat-pc)                   * out-vatp_gds-dtlcl.doc-qnty
       varvatcons-rubl-docovpcl  = varvatcons-rubl-docovpcl  + (((out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl) - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl                - road-tax-rubl-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-rubl-salecl - varprice-rubl-conscl) * parcons-vat-pc / (100 + parcons-vat-pc) * out-vatp_gds-dtlcl.doc-qnty * varcons-qntycl / varfact-qntycl + ((out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl) - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl                - road-tax-rubl-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-rubl-salecl) * parvat-pc / (100 + parvat-pc) * out-vatp_gds-dtlcl.doc-qnty * (varfact-qntycl - varcons-qntycl) / varfact-qntycl)
       vardsc-rubl-docovpcl  = vardsc-rubl-docovpcl  + out-vatp_gds-dtlcl.discnt-rubl * out-vatp_gds-dtlcl.doc-qnty   .
    end.
    if pardoc-type = 'инв':U then do:
      ASSIGN
                price-base-with-tax-salecl    = varsum-base-docovpcl / varfact-qntycl
        slt-base-salecl               = varslt-base-docovpcl / varfact-qntycl
        vat-base-buyercl              = varvat-base-docovpcl / varfact-qntycl
        discnt-base-salecl            = vardsc-base-docovpcl / varfact-qntycl
        vat-base-salecl               = varvatcons-base-docovpcl / varfact-qntycl
                price-rubl-with-tax-salecl    = varsum-rubl-docovpcl / varfact-qntycl
        slt-rubl-salecl               = varslt-rubl-docovpcl / varfact-qntycl
        vat-rubl-buyercl              = varvat-rubl-docovpcl / varfact-qntycl
        discnt-rubl-salecl            = vardsc-rubl-docovpcl / varfact-qntycl
        vat-rubl-salecl               = varvatcons-rubl-docovpcl / varfact-qntycl.
    end.
    else do:
      ASSIGN
                price-base-with-tax-salecl    = varsum-base-factovpcl / varfact-qntycl
        slt-base-salecl               = varslt-base-factovpcl / varfact-qntycl
        vat-base-buyercl              = varvat-base-factovpcl / varfact-qntycl
        discnt-base-salecl            = vardsc-base-factovpcl / varfact-qntycl
        vat-base-salecl               = varvatcons-base-factovpcl / varfact-qntycl
                price-rubl-with-tax-salecl    = varsum-rubl-factovpcl / varfact-qntycl
        slt-rubl-salecl               = varslt-rubl-factovpcl / varfact-qntycl
        vat-rubl-buyercl              = varvat-rubl-factovpcl / varfact-qntycl
        discnt-rubl-salecl            = vardsc-rubl-factovpcl / varfact-qntycl
        vat-rubl-salecl               = varvatcons-rubl-factovpcl / varfact-qntycl.
    end.
  end.
end.
assign
  price-base-without-tax-salecl = price-base-with-tax-salecl - vat-base-salecl - slt-base-salecl - road-tax-base-salecl
  price-rubl-without-tax-salecl = price-rubl-with-tax-salecl - vat-rubl-salecl - slt-rubl-salecl - road-tax-rubl-salecl.
end.
if paris-cur then do:
  assign
    parcurartic      = cl_tt-clcparts.artic
    parcurprod-type  = cl_tt-clcparts.prod-type
    parcurprod-code  = cl_tt-clcparts.prod-code
    parcurdoc-type   = cl_tt-clcparts.doc-type
    parcurdoc-code   = cl_tt-clcparts.out-code
    parcurobj-type   = cl_tt-clcparts.obj-type
    parcurobj-code   = cl_tt-clcparts.obj-code.
  if parr-b = "base" then do:
    assign
      parcurprice-base = parcur-base
      parcurprice-rubl = parcur-base * parbase-rate / parbase-scale.
  end.
  else do:
    assign
      parcurprice-base = parcur-base / parbase-rate * parbase-scale
      parcurprice-rubl = parcur-base.
  end.
  assign
    parcurbase-rate   = parbase-rate
    parcurbase-scale  = parbase-scale
    parcurdiscnt-base = 0
    parcurdiscnt-rubl = 0
    parcurfact-qnty   = cl_tt-clcparts.fact-qnty
    parcurcli-qnty    = cl_tt-clcparts.cli-qnty
    parcurdoc-qnty    = cl_tt-clcparts.qnty.
if parcurext-doc-type = 'ot':U or
   parcurext-doc-type = ?                 then do:
  assign
   out-vatp-have-vat-sltcur = yes.
end.
else do:
  find first out-vatp_doc-attrcur no-lock
    where out-vatp_doc-attrcur.doc-code  = parcurdoc-code
      and out-vatp_doc-attrcur.attr-code = 'envd':U
      no-error .
  if not available out-vatp_doc-attrcur then do:
    assign
      out-vatp-have-vat-sltcur = yes.
  end.
  else do:
     out-vatp-have-vat-sltcur = no.
  end.
end.
find first out-vatp_goodscur where out-vatp_goodscur.artic     = parcurartic     and
                                   out-vatp_goodscur.prod-type = parcurprod-type and
                                   out-vatp_goodscur.prod-code = parcurprod-code no-lock.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rootnode in g#library
  (input  parcurartic
  ,input  parcurprod-type
  ,input  parcurprod-code
  ,output varroot-nodecur
  ) no-error .
if error-status :error then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка при определении корневого признака товара" skip
    "Артикул" parcurartic parcurprod-type parcurprod-code skip
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  undo, return error .
end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prtat in g#library
  (input  varroot-nodecur
  ,input  'empty-scale=request'
  ,output varempty-scalecur
  ) no-error .
if error-status :error then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка при определении атрибута признака" skip
    "Артикул" parcurartic parcurprod-type parcurprod-code skip
    "Признак" varroot-nodecur skip
    "Запрашивался атрибут" "empty-scale=request" skip
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  undo, return error .
end.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varoutvprbcur
  )  .
if varoutvprbcur = "base":u then do:
  assign
        road-tax-base-salecur    =  (if parcurroad-tax = ? then 0 else parcurroad-tax * 1)
    excise-base-salecur      =  (if parcurexcise   = ? then 0 else parcurexcise   * 1)
  .
end.
else do:
  assign
        road-tax-base-salecur    =  (if parcurroad-tax = ? then 0 else parcurroad-tax / parcurbase-rate * parcurbase-scale)
    excise-base-salecur      =  (if parcurexcise   = ? then 0 else parcurexcise   / parcurbase-rate * parcurbase-scale)
  .
end.
if varoutvprbcur = "rubl":u then do:
  assign
        road-tax-rubl-salecur    = (if parcurroad-tax = ? then 0 else parcurroad-tax * 1)
    excise-rubl-salecur      = (if parcurexcise   = ? then 0 else parcurexcise   * 1) .
end.
else do:
  assign
        road-tax-rubl-salecur    = (if parcurroad-tax = ? then 0 else parcurroad-tax * parcurbase-rate / parcurbase-scale)
    excise-rubl-salecur      = (if parcurexcise   = ? then 0 else parcurexcise   * parcurbase-rate / parcurbase-scale) .
end.
assign
  varis-cons-parts-havecur =  no.
assign
  varfact-qntycur       = 0
  varcons-qntycur       = 0
  varprice-base-conscur = 0
  varprice-rubl-conscur = 0.
if cl_tt-clcparts.purch-code = 2 then do:
assign
  price-rubl-with-tax-lococur = cl_tt-clcparts.price-rubl
  price-base-with-tax-lococur = cl_tt-clcparts.price-base
.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprbocur
  )  .
  if cl_tt-clcparts.out-code = 'free-zone':U     or
     cl_tt-clcparts.out-code = 'out-zone':U   or
     cl_tt-clcparts.doc-type = 'акт':U then do:
    assign
      in-vatp-have-vat-sltocur = yes.
  end.
  else do:
    find first in-vatp_doc-attrocur no-lock
      where in-vatp_doc-attrocur.doc-code  = cl_tt-clcparts.out-code
        and in-vatp_doc-attrocur.attr-code = 'envd':U
      no-error .
    if not available in-vatp_doc-attrocur then do:
      assign
        in-vatp-have-vat-sltocur = yes.
    end.
    else do:
         in-vatp-have-vat-sltocur = no.
    end.
  end.
  assign
   price-cli-with-tax-lococur = cl_tt-clcparts.price-cli
   cli-base-rateocur          = cl_tt-clcparts.cli-base-rate.
  ASSIGN   road-tax-base-lococur  = (if cl_tt-clcparts.road-tax-base  = ? then 0 else cl_tt-clcparts.road-tax-base)
           road-tax-rubl-lococur  = (if cl_tt-clcparts.road-tax-rubl  = ? then 0 else cl_tt-clcparts.road-tax-rubl).
  ASSIGN  transport-base-lococur = (if cl_tt-clcparts.transport-base = ? then 0 else cl_tt-clcparts.transport-base)
          transport-rubl-lococur = (if cl_tt-clcparts.transport-rubl = ? then 0 else cl_tt-clcparts.transport-rubl)
          other-base-lococur     = (if cl_tt-clcparts.other-base     = ? then 0 else cl_tt-clcparts.other-base)
          other-rubl-lococur     = (if cl_tt-clcparts.other-rubl     = ? then 0 else cl_tt-clcparts.other-rubl)
          vat-pc-lococur         = (if cl_tt-clcparts.vat-pc         = ? then 0 else cl_tt-clcparts.vat-pc)
          slt-pc-lococur         = (if cl_tt-clcparts.slt-pc         = ? then 0 else cl_tt-clcparts.slt-pc).
          ASSIGN   slt-base-lococur    = (if in-vatp-have-vat-sltocur = no then 0 else (price-base-with-tax-lococur - ((if road-tax-base-lococur  = ? then 0 else road-tax-base-lococur) + (if transport-base-lococur = ? then 0 else transport-base-lococur) + (if other-base-lococur = ? then 0 else other-base-lococur)))                           * slt-pc-lococur / (100 + slt-pc-lococur))                        vat-base-lococur    = (if in-vatp-have-vat-sltocur = no then 0 else (price-base-with-tax-lococur - ((if road-tax-base-lococur  = ? then 0 else road-tax-base-lococur) + (if transport-base-lococur = ? then 0 else transport-base-lococur) + (if other-base-lococur = ? then 0 else other-base-lococur))) * (1 - slt-pc-lococur / (100 + slt-pc-lococur)) * vat-pc-lococur / (100 + vat-pc-lococur)).
    ASSIGN   slt-rubl-lococur    = (if in-vatp-have-vat-sltocur = no then 0 else (price-rubl-with-tax-lococur - ((if road-tax-rubl-lococur  = ? then 0 else road-tax-rubl-lococur) + (if transport-rubl-lococur = ? then 0 else transport-rubl-lococur) + (if other-rubl-lococur = ? then 0 else other-rubl-lococur)))                           * slt-pc-lococur / (100 + slt-pc-lococur))                        vat-rubl-lococur    = (if in-vatp-have-vat-sltocur = no then 0 else (price-rubl-with-tax-lococur - ((if road-tax-rubl-lococur  = ? then 0 else road-tax-rubl-lococur) + (if transport-rubl-lococur = ? then 0 else transport-rubl-lococur) + (if other-rubl-lococur = ? then 0 else other-rubl-lococur))) * (1 - slt-pc-lococur / (100 + slt-pc-lococur)) * vat-pc-lococur / (100 + vat-pc-lococur)).
  assign
    exch-rate-cli-lococur = (cl_tt-clcparts.price-rubl - transport-rubl-lococur - other-rubl-lococur - road-tax-rubl-lococur - (if cl_tt-clcparts.vat-type <> 'в т. ч.':U then vat-rubl-lococur else 0) - (if cl_tt-clcparts.slt-type <> 'в т. ч.':U then slt-rubl-lococur else 0)) / cl_tt-clcparts.price-cli .
  assign
    slt-cli-lococur        = slt-rubl-lococur       / exch-rate-cli-lococur
    vat-cli-lococur        = vat-rubl-lococur       / exch-rate-cli-lococur
    road-tax-cli-lococur   = road-tax-rubl-lococur  / exch-rate-cli-lococur
    transport-cli-lococur  = 0
    other-cli-lococur      = 0
  .
ASSIGN
          price-base-without-tax-lococur = price-base-with-tax-lococur - vat-base-lococur - slt-base-lococur - ((if road-tax-base-lococur  = ? then 0 else road-tax-base-lococur) + (if transport-base-lococur = ? then 0 else transport-base-lococur) + (if other-base-lococur = ? then 0 else other-base-lococur))
    price-rubl-without-tax-lococur = price-rubl-with-tax-lococur - vat-rubl-lococur - slt-rubl-lococur - ((if road-tax-rubl-lococur  = ? then 0 else road-tax-rubl-lococur) + (if transport-rubl-lococur = ? then 0 else transport-rubl-lococur) + (if other-rubl-lococur = ? then 0 else other-rubl-lococur))
.
  assign
    varprice-base-conscur    = varprice-base-conscur + (price-base-with-tax-lococur - (if road-tax-base-lococur = ? then 0 else road-tax-base-lococur))* cl_tt-clcparts.fact-qnty
    varprice-rubl-conscur    = varprice-rubl-conscur + (price-rubl-with-tax-lococur - (if road-tax-rubl-lococur = ? then 0 else road-tax-rubl-lococur))* cl_tt-clcparts.fact-qnty
    varis-cons-parts-havecur = yes
    varcons-qntycur          = varcons-qntycur + cl_tt-clcparts.fact-qnty.
end.
assign
  varfact-qntycur = cl_tt-clcparts.fact-qnty.
assign
  varprice-base-conscur = varprice-base-conscur / varcons-qntycur
  varprice-rubl-conscur = varprice-rubl-conscur / varcons-qntycur.
if varprice-base-conscur = ? then do:
  assign
    varprice-base-conscur = 0.
end.
if varprice-rubl-conscur = ? then do:
  assign
    varprice-rubl-conscur = 0.
end.
assign
    slt-base-salecur               = (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-base - parcurdiscnt-base                - road-tax-base-salecur) * parcurSLT-pc / (100 + parcurSLT-pc)
  vat-base-buyercur              = (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-base - parcurdiscnt-base - (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-base - parcurdiscnt-base                - road-tax-base-salecur) * parcurSLT-pc / (100 + parcurSLT-pc) - road-tax-base-salecur) * parcurvat-pc / (100 + parcurvat-pc)
  discnt-base-salecur            = parcurdiscnt-base
  price-base-with-tax-salecur    = (parcurprice-base - parcurdiscnt-base)
    slt-rubl-salecur               = (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-rubl - parcurdiscnt-rubl                - road-tax-rubl-salecur) * parcurSLT-pc / (100 + parcurSLT-pc)
  vat-rubl-buyercur              = (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-rubl - parcurdiscnt-rubl - (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-rubl - parcurdiscnt-rubl                - road-tax-rubl-salecur) * parcurSLT-pc / (100 + parcurSLT-pc) - road-tax-rubl-salecur) * parcurvat-pc / (100 + parcurvat-pc)
  discnt-rubl-salecur            = parcurdiscnt-rubl
  price-rubl-with-tax-salecur    = (parcurprice-rubl - parcurdiscnt-rubl)
  .
if parcurdoc-type = 'инв':U then do:
  assign
    varfact-qntycur = parcurdoc-qnty.
end.
else do:
  assign
    varfact-qntycur = parcurfact-qnty.
end.
if varis-cons-parts-havecur = no then do:
  assign
        vat-base-salecur               = (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-base - parcurdiscnt-base - (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-base - parcurdiscnt-base                - road-tax-base-salecur) * parcurSLT-pc / (100 + parcurSLT-pc) - road-tax-base-salecur) * parcurvat-pc / (100 + parcurvat-pc)
        vat-rubl-salecur               = (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-rubl - parcurdiscnt-rubl - (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-rubl - parcurdiscnt-rubl                - road-tax-rubl-salecur) * parcurSLT-pc / (100 + parcurSLT-pc) - road-tax-rubl-salecur) * parcurvat-pc / (100 + parcurvat-pc).
end.
else do:
  if parcurdoc-type = 'инв':U then do:
    assign
            vat-base-salecur               = (if out-vatp-have-vat-sltcur = no then 0 else (((parcurprice-base - parcurdiscnt-base) - (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-base - parcurdiscnt-base                - road-tax-base-salecur) * parcurSLT-pc / (100 + parcurSLT-pc) - road-tax-base-salecur - varprice-base-conscur) * parcurcons-vat-pc / (100 + parcurcons-vat-pc) * parcurdoc-qnty * varcons-qntycur / varfact-qntycur + ((parcurprice-base - parcurdiscnt-base) - (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-base - parcurdiscnt-base                - road-tax-base-salecur) * parcurSLT-pc / (100 + parcurSLT-pc) - road-tax-base-salecur) * parcurvat-pc / (100 + parcurvat-pc) * parcurdoc-qnty * (varfact-qntycur - varcons-qntycur) / varfact-qntycur) / varfact-qntycur)
            vat-rubl-salecur               = (if out-vatp-have-vat-sltcur = no then 0 else (((parcurprice-rubl - parcurdiscnt-rubl) - (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-rubl - parcurdiscnt-rubl                - road-tax-rubl-salecur) * parcurSLT-pc / (100 + parcurSLT-pc) - road-tax-rubl-salecur - varprice-rubl-conscur) * parcurcons-vat-pc / (100 + parcurcons-vat-pc) * parcurdoc-qnty * varcons-qntycur / varfact-qntycur + ((parcurprice-rubl - parcurdiscnt-rubl) - (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-rubl - parcurdiscnt-rubl                - road-tax-rubl-salecur) * parcurSLT-pc / (100 + parcurSLT-pc) - road-tax-rubl-salecur) * parcurvat-pc / (100 + parcurvat-pc) * parcurdoc-qnty * (varfact-qntycur - varcons-qntycur) / varfact-qntycur) / varfact-qntycur)
     .
  end.
  else do:
    assign
            vat-base-salecur               = (if out-vatp-have-vat-sltcur = no then 0 else (((parcurprice-base - parcurdiscnt-base) - (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-base - parcurdiscnt-base                - road-tax-base-salecur) * parcurSLT-pc / (100 + parcurSLT-pc) - road-tax-base-salecur - varprice-base-conscur) * parcurcons-vat-pc / (100 + parcurcons-vat-pc) * parcurfact-qnty * varcons-qntycur / varfact-qntycur + ((parcurprice-base - parcurdiscnt-base) - (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-base - parcurdiscnt-base                - road-tax-base-salecur) * parcurSLT-pc / (100 + parcurSLT-pc) - varprice-base-conscur) * parcurvat-pc / (100 + parcurvat-pc) * parcurfact-qnty * (varfact-qntycur - varcons-qntycur) / varfact-qntycur) / varfact-qntycur)
            vat-rubl-salecur               = (if out-vatp-have-vat-sltcur = no then 0 else (((parcurprice-rubl - parcurdiscnt-rubl) - (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-rubl - parcurdiscnt-rubl                - road-tax-rubl-salecur) * parcurSLT-pc / (100 + parcurSLT-pc) - road-tax-rubl-salecur - varprice-rubl-conscur) * parcurcons-vat-pc / (100 + parcurcons-vat-pc) * parcurfact-qnty * varcons-qntycur / varfact-qntycur + ((parcurprice-rubl - parcurdiscnt-rubl) - (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-rubl - parcurdiscnt-rubl                - road-tax-rubl-salecur) * parcurSLT-pc / (100 + parcurSLT-pc) - varprice-rubl-conscur) * parcurvat-pc / (100 + parcurvat-pc) * parcurfact-qnty * (varfact-qntycur - varcons-qntycur) / varfact-qntycur) / varfact-qntycur)
     .
  end.
end.
assign
price-base-without-tax-salecur = price-base-with-tax-salecur - vat-base-salecur - slt-base-salecur - road-tax-base-salecur
price-rubl-without-tax-salecur = price-rubl-with-tax-salecur - vat-rubl-salecur - slt-rubl-salecur - road-tax-rubl-salecur.
end.
create bf_tt-allsum.
assign
  bf_tt-allsum.sum-type = 'основная_сумма':U.
assign
  bf_tt-allsum.fact-qnty          =  cl_tt-clcparts.fact-qnty
  bf_tt-allsum.cli-qnty           =  cl_tt-clcparts.cli-qnty
  bf_tt-allsum.sum-dsc-base-doc   =  (if price-base-with-tax-salecl  = ? then 0 else price-base-with-tax-salecl  * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.sum-dsc-rubl-doc   =  (if price-rubl-with-tax-salecl  = ? then 0 else price-rubl-with-tax-salecl  * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.dsc-base-doc       =  (if discnt-base-salecl          = ? then 0 else discnt-base-salecl          * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.dsc-rubl-doc       =  (if discnt-rubl-salecl          = ? then 0 else discnt-rubl-salecl          * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.slt-base-doc       =  (if slt-base-salecl             = ? then 0 else slt-base-salecl             * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.slt-rubl-doc       =  (if slt-rubl-salecl             = ? then 0 else slt-rubl-salecl             * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.vat-base-buyer-doc =  (if vat-base-buyercl            = ? then 0 else vat-base-buyercl            * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.vat-rubl-buyer-doc =  (if vat-rubl-buyercl            = ? then 0 else vat-rubl-buyercl            * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.road-tax-base-doc  =  (if road-tax-base-salecl        = ? then 0 else road-tax-base-salecl        * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.road-tax-rubl-doc  =  (if road-tax-rubl-salecl        = ? then 0 else road-tax-rubl-salecl        * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.excise-base-doc    =  (if excise-base-salecl          = ? then 0 else excise-base-salecl          * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.excise-rubl-doc    =  (if excise-rubl-salecl          = ? then 0 else excise-rubl-salecl          * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.sum-dsc-base-cur   =  (if price-base-with-tax-salecur = ? then 0 else price-base-with-tax-salecur * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.sum-dsc-rubl-cur   =  (if price-rubl-with-tax-salecur = ? then 0 else price-rubl-with-tax-salecur * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.dsc-base-cur       =  (if discnt-base-salecur         = ? then 0 else discnt-base-salecur         * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.dsc-rubl-cur       =  (if discnt-rubl-salecur         = ? then 0 else discnt-rubl-salecur         * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.slt-base-cur       =  (if slt-base-salecur            = ? then 0 else slt-base-salecur            * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.slt-rubl-cur       =  (if slt-rubl-salecur            = ? then 0 else slt-rubl-salecur            * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.vat-base-buyer-cur =  (if vat-base-buyercur           = ? then 0 else vat-base-buyercur           * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.vat-rubl-buyer-cur =  (if vat-rubl-buyercur           = ? then 0 else vat-rubl-buyercur           * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.road-tax-base-cur  =  (if road-tax-base-salecur       = ? then 0 else road-tax-base-salecur       * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.road-tax-rubl-cur  =  (if road-tax-rubl-salecur       = ? then 0 else road-tax-rubl-salecur       * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.excise-base-cur    =  (if excise-base-salecur         = ? then 0 else excise-base-salecur         * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.excise-rubl-cur    =  (if excise-rubl-salecur         = ? then 0 else excise-rubl-salecur         * cl_tt-clcparts.fact-qnty)
  .
if cl_tt-clcparts.purch-code = integer('2':U) then do:
  assign
    bf_tt-allsum.vat-base-doc = (if out-vatp-have-vat-sltcur <> yes then 0 else (price-base-with-tax-salecl  - road-tax-base-salecl  - slt-base-salecl  - (cl_tt-clcparts.price-base - cl_tt-clcparts.road-tax-base)) * parcons-vat-pc / (100 + parcons-vat-pc) * cl_tt-clcparts.fact-qnty)
    bf_tt-allsum.vat-rubl-doc = (if out-vatp-have-vat-sltcur <> yes then 0 else (price-rubl-with-tax-salecl  - road-tax-rubl-salecl  - slt-rubl-salecl  - (cl_tt-clcparts.price-rubl - cl_tt-clcparts.road-tax-rubl)) * parcons-vat-pc / (100 + parcons-vat-pc) * cl_tt-clcparts.fact-qnty)
    bf_tt-allsum.vat-base-cur = (if out-vatp-have-vat-sltcur <> yes then 0 else (price-base-with-tax-salecur - road-tax-base-salecur - slt-base-salecur - (cl_tt-clcparts.price-base - cl_tt-clcparts.road-tax-base)) * parcurcons-vat-pc / (100 + parcurcons-vat-pc) * cl_tt-clcparts.fact-qnty)
    bf_tt-allsum.vat-rubl-cur = (if out-vatp-have-vat-sltcur <> yes then 0 else (price-rubl-with-tax-salecur - road-tax-rubl-salecur - slt-rubl-salecur - (cl_tt-clcparts.price-rubl - cl_tt-clcparts.road-tax-rubl)) * parcurcons-vat-pc / (100 + parcurcons-vat-pc) * cl_tt-clcparts.fact-qnty)
    .
end.
else do:
  assign
    bf_tt-allsum.vat-base-doc = (if out-vatp-have-vat-sltcur <> yes then 0 else (price-base-with-tax-salecl  - road-tax-base-salecl  - slt-base-salecl ) * parvat-pc / (100 + parvat-pc) * cl_tt-clcparts.fact-qnty)
    bf_tt-allsum.vat-rubl-doc = (if out-vatp-have-vat-sltcur <> yes then 0 else (price-rubl-with-tax-salecl  - road-tax-rubl-salecl  - slt-rubl-salecl ) * parvat-pc / (100 + parvat-pc) * cl_tt-clcparts.fact-qnty)
    bf_tt-allsum.vat-base-cur = (if out-vatp-have-vat-sltcur <> yes then 0 else (price-base-with-tax-salecur - road-tax-base-salecur - slt-base-salecur) * parcurvat-pc / (100 + parcurvat-pc) * cl_tt-clcparts.fact-qnty)
    bf_tt-allsum.vat-rubl-cur = (if out-vatp-have-vat-sltcur <> yes then 0 else (price-rubl-with-tax-salecur - road-tax-rubl-salecur - slt-rubl-salecur) * parcurvat-pc / (100 + parcurvat-pc) * cl_tt-clcparts.fact-qnty)
    .
end.
if bf_tt-allsum.vat-base-doc = ? then bf_tt-allsum.vat-base-doc = 0.
if bf_tt-allsum.vat-rubl-doc = ? then bf_tt-allsum.vat-rubl-doc = 0.
assign
  bf_tt-allsum.sum-dsc-base-acc     = (if price-base-with-tax-loccl    = ? then 0 else price-base-with-tax-loccl    * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.sum-dsc-rubl-acc     = (if price-rubl-with-tax-loccl    = ? then 0 else price-rubl-with-tax-loccl    * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.sum-dsc-cli-acc      = (if (price-cli-with-tax-loccl +
                                           road-tax-cli-loccl       +
                                           (if cl_tt-clcparts.vat-type <> 'в т. ч.':U then vat-cli-loccl else 0) +
                                           (if cl_tt-clcparts.slt-type <> 'в т. ч.':U then slt-cli-loccl else 0)
                                           ) / cli-base-ratecl = ? then 0
                                        else
                                          (price-cli-with-tax-loccl +
                                           road-tax-cli-loccl       +
                                           (if cl_tt-clcparts.vat-type <> 'в т. ч.':U then vat-cli-loccl else 0) +
                                           (if cl_tt-clcparts.slt-type <> 'в т. ч.':U then slt-cli-loccl else 0)
                                           ) / cli-base-ratecl * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.dsc-base-acc         = 0
  bf_tt-allsum.dsc-rubl-acc         = 0
  bf_tt-allsum.dsc-cli-acc          = 0
  bf_tt-allsum.vat-base-acc         = (if vat-base-loccl      = ? then 0 else vat-base-loccl      * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.vat-rubl-acc         = (if vat-rubl-loccl      = ? then 0 else vat-rubl-loccl      * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.vat-cli-acc          = (if vat-cli-loccl / cli-base-ratecl      = ? then 0 else vat-cli-loccl / cli-base-ratecl      * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.slt-base-acc         = (if slt-base-loccl      = ? then 0 else slt-base-loccl      * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.slt-rubl-acc         = (if slt-rubl-loccl      = ? then 0 else slt-rubl-loccl      * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.slt-cli-acc          = (if slt-cli-loccl / cli-base-ratecl      = ? then 0 else slt-cli-loccl / cli-base-ratecl      * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.road-tax-base-acc    = (if road-tax-base-loccl = ? then 0 else road-tax-base-loccl * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.road-tax-rubl-acc    = (if road-tax-rubl-loccl = ? then 0 else road-tax-rubl-loccl * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.road-tax-cli-acc     = (if road-tax-cli-loccl / cli-base-ratecl = ? then 0 else road-tax-cli-loccl / cli-base-ratecl * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.excise-base-acc      = 0
  bf_tt-allsum.excise-rubl-acc      = 0
  bf_tt-allsum.excise-cli-acc       = 0
  bf_tt-allsum.transport-base-acc   = (if transport-base-loccl   = ? then 0 else transport-base-loccl  * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.transport-rubl-acc   = (if transport-rubl-loccl   = ? then 0 else transport-rubl-loccl  * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.transport-cli-acc    = (if transport-cli-loccl / cli-base-ratecl   = ? then 0 else transport-cli-loccl / cli-base-ratecl  * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.other-base-acc       = (if other-base-loccl       = ? then 0 else other-base-loccl      * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.other-rubl-acc       = (if other-rubl-loccl       = ? then 0 else other-rubl-loccl      * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.other-cli-acc        = (if other-cli-loccl / cli-base-ratecl       = ? then 0 else other-cli-loccl     / cli-base-ratecl  * cl_tt-clcparts.fact-qnty).
create bfs_tt-allsum.
assign
  bfs_tt-allsum.sum-type = 'основная_сумма_со_знаком':U.
if pardoc-type = 'инв':U or
   pardoc-type = 'при':U    or
   pardoc-type = 'возврат':U    then do:
   buffer-copy bf_tt-allsum except bf_tt-allsum.sum-type to bfs_tt-allsum.
end.
else do:
  assign
    bfs_tt-allsum.fact-qnty           =  - bf_tt-allsum.fact-qnty
    bfs_tt-allsum.cli-qnty            =  - bf_tt-allsum.cli-qnty
    bfs_tt-allsum.sum-dsc-base-doc    =  - bf_tt-allsum.sum-dsc-base-doc
    bfs_tt-allsum.sum-dsc-rubl-doc    =  - bf_tt-allsum.sum-dsc-rubl-doc
    bfs_tt-allsum.dsc-base-doc        =  - bf_tt-allsum.dsc-base-doc
    bfs_tt-allsum.dsc-rubl-doc        =  - bf_tt-allsum.dsc-rubl-doc
    bfs_tt-allsum.vat-base-doc        =  - bf_tt-allsum.vat-base-doc
    bfs_tt-allsum.vat-rubl-doc        =  - bf_tt-allsum.vat-rubl-doc
    bfs_tt-allsum.vat-base-buyer-doc  =  - bf_tt-allsum.vat-base-buyer-doc
    bfs_tt-allsum.vat-rubl-buyer-doc  =  - bf_tt-allsum.vat-rubl-buyer-doc
    bfs_tt-allsum.slt-base-doc        =  - bf_tt-allsum.slt-base-doc
    bfs_tt-allsum.slt-rubl-doc        =  - bf_tt-allsum.slt-rubl-doc
    bfs_tt-allsum.road-tax-base-doc   =  - bf_tt-allsum.road-tax-base-doc
    bfs_tt-allsum.road-tax-rubl-doc   =  - bf_tt-allsum.road-tax-rubl-doc
    bfs_tt-allsum.excise-base-doc     =  - bf_tt-allsum.excise-base-doc
    bfs_tt-allsum.excise-rubl-doc     =  - bf_tt-allsum.excise-rubl-doc
    bfs_tt-allsum.sum-dsc-base-cur    =  - bf_tt-allsum.sum-dsc-base-cur
    bfs_tt-allsum.sum-dsc-rubl-cur    =  - bf_tt-allsum.sum-dsc-rubl-cur
    bfs_tt-allsum.dsc-base-cur        =  - bf_tt-allsum.dsc-base-cur
    bfs_tt-allsum.dsc-rubl-cur        =  - bf_tt-allsum.dsc-rubl-cur
    bfs_tt-allsum.vat-base-cur        =  - bf_tt-allsum.vat-base-cur
    bfs_tt-allsum.vat-rubl-cur        =  - bf_tt-allsum.vat-rubl-cur
    bfs_tt-allsum.vat-base-buyer-cur  =  - bf_tt-allsum.vat-base-buyer-cur
    bfs_tt-allsum.vat-rubl-buyer-cur  =  - bf_tt-allsum.vat-rubl-buyer-cur
    bfs_tt-allsum.slt-base-cur        =  - bf_tt-allsum.slt-base-cur
    bfs_tt-allsum.slt-rubl-cur        =  - bf_tt-allsum.slt-rubl-cur
    bfs_tt-allsum.road-tax-base-cur   =  - bf_tt-allsum.road-tax-base-cur
    bfs_tt-allsum.road-tax-rubl-cur   =  - bf_tt-allsum.road-tax-rubl-cur
    bfs_tt-allsum.excise-base-cur     =  - bf_tt-allsum.excise-base-cur
    bfs_tt-allsum.excise-rubl-cur     =  - bf_tt-allsum.excise-rubl-cur
    bfs_tt-allsum.sum-dsc-base-acc    =  - bf_tt-allsum.sum-dsc-base-acc
    bfs_tt-allsum.sum-dsc-rubl-acc    =  - bf_tt-allsum.sum-dsc-rubl-acc
    bfs_tt-allsum.sum-dsc-cli-acc     =  - bf_tt-allsum.sum-dsc-cli-acc
    bfs_tt-allsum.dsc-base-acc        =  - bf_tt-allsum.dsc-base-acc
    bfs_tt-allsum.dsc-rubl-acc        =  - bf_tt-allsum.dsc-rubl-acc
    bfs_tt-allsum.dsc-cli-acc         =  - bf_tt-allsum.dsc-cli-acc
    bfs_tt-allsum.vat-base-acc        =  - bf_tt-allsum.vat-base-acc
    bfs_tt-allsum.vat-rubl-acc        =  - bf_tt-allsum.vat-rubl-acc
    bfs_tt-allsum.vat-cli-acc         =  - bf_tt-allsum.vat-cli-acc
    bfs_tt-allsum.slt-base-acc        =  - bf_tt-allsum.slt-base-acc
    bfs_tt-allsum.slt-rubl-acc        =  - bf_tt-allsum.slt-rubl-acc
    bfs_tt-allsum.slt-cli-acc         =  - bf_tt-allsum.slt-cli-acc
    bfs_tt-allsum.road-tax-base-acc   =  - bf_tt-allsum.road-tax-base-acc
    bfs_tt-allsum.road-tax-rubl-acc   =  - bf_tt-allsum.road-tax-rubl-acc
    bfs_tt-allsum.road-tax-cli-acc    =  - bf_tt-allsum.road-tax-cli-acc
    bfs_tt-allsum.excise-base-acc     =  - bf_tt-allsum.excise-base-acc
    bfs_tt-allsum.excise-rubl-acc     =  - bf_tt-allsum.excise-rubl-acc
    bfs_tt-allsum.excise-cli-acc      =  - bf_tt-allsum.excise-cli-acc
    bfs_tt-allsum.transport-base-acc  =  - bf_tt-allsum.transport-base-acc
    bfs_tt-allsum.transport-rubl-acc  =  - bf_tt-allsum.transport-rubl-acc
    bfs_tt-allsum.transport-cli-acc   =  - bf_tt-allsum.transport-cli-acc
    bfs_tt-allsum.other-base-acc      =  - bf_tt-allsum.other-base-acc
    bfs_tt-allsum.other-rubl-acc      =  - bf_tt-allsum.other-rubl-acc
    bfs_tt-allsum.other-cli-acc       =  - bf_tt-allsum.other-cli-acc.
end.
create bfpc_tt-allsum.
create bfspc_tt-allsum.
case cl_tt-clcparts.purch-code :
when 1           then do:
  assign
    bfpc_tt-allsum.sum-type  = 'сумма_по_выкупу':U
    bfspc_tt-allsum.sum-type = 'сумма_по_выкупу_со_знаком':U.
  buffer-copy bf_tt-allsum  except bf_tt-allsum.sum-type  to bfpc_tt-allsum.
  buffer-copy bfs_tt-allsum except bfs_tt-allsum.sum-type to bfspc_tt-allsum.
end.
when 4    then do:
  assign
    bfpc_tt-allsum.sum-type  = 'сумма_по_старой_консигнации':U
    bfspc_tt-allsum.sum-type = 'сумма_по_старой_консигнации_со_знаком':U.
  buffer-copy bf_tt-allsum  except bf_tt-allsum.sum-type  to bfpc_tt-allsum.
  buffer-copy bfs_tt-allsum except bfs_tt-allsum.sum-type to bfspc_tt-allsum.
end.
when 3 then do:
  assign
    bfpc_tt-allsum.sum-type  = 'сумма_по_ответственному_хранению':U
    bfspc_tt-allsum.sum-type = 'сумма_по_ответственному_хранению_со_знаком':U.
  buffer-copy bf_tt-allsum  except bf_tt-allsum.sum-type  to bfpc_tt-allsum.
  buffer-copy bfs_tt-allsum except bfs_tt-allsum.sum-type to bfspc_tt-allsum.
end.
when 2 then do:
  assign
    bfpc_tt-allsum.sum-type  = 'сумма_по_консигнации_выгода':U
    bfspc_tt-allsum.sum-type = 'сумма_по_консигнации_выгода_со_знаком':U.
  assign
    bfpc_tt-allsum.fact-qnty           = bf_tt-allsum.fact-qnty
    bfpc_tt-allsum.cli-qnty            = bf_tt-allsum.cli-qnty
    bfpc_tt-allsum.sum-dsc-base-doc    = bf_tt-allsum.sum-dsc-base-doc    - bf_tt-allsum.sum-dsc-base-acc
    bfpc_tt-allsum.sum-dsc-rubl-doc    = bf_tt-allsum.sum-dsc-rubl-doc    - bf_tt-allsum.sum-dsc-rubl-acc
    bfpc_tt-allsum.dsc-base-doc        = bf_tt-allsum.dsc-base-doc        - bf_tt-allsum.dsc-base-acc
    bfpc_tt-allsum.dsc-rubl-doc        = bf_tt-allsum.dsc-rubl-doc        - bf_tt-allsum.dsc-rubl-acc
    bfpc_tt-allsum.vat-base-doc        = bf_tt-allsum.vat-base-doc
    bfpc_tt-allsum.vat-rubl-doc        = bf_tt-allsum.vat-rubl-doc
    bfpc_tt-allsum.vat-base-buyer-doc  = bf_tt-allsum.vat-base-buyer-doc  - bf_tt-allsum.vat-base-acc
    bfpc_tt-allsum.vat-rubl-buyer-doc  = bf_tt-allsum.vat-rubl-buyer-doc  - bf_tt-allsum.vat-rubl-acc
    bfpc_tt-allsum.slt-base-doc        = bf_tt-allsum.slt-base-doc        - bf_tt-allsum.slt-base-acc
    bfpc_tt-allsum.slt-rubl-doc        = bf_tt-allsum.slt-rubl-doc        - bf_tt-allsum.slt-rubl-acc
    bfpc_tt-allsum.road-tax-base-doc   = bf_tt-allsum.road-tax-base-doc   - bf_tt-allsum.road-tax-base-acc
    bfpc_tt-allsum.road-tax-rubl-doc   = bf_tt-allsum.road-tax-rubl-doc   - bf_tt-allsum.road-tax-rubl-acc
    bfpc_tt-allsum.excise-base-doc     = bf_tt-allsum.excise-base-doc
    bfpc_tt-allsum.excise-rubl-doc     = bf_tt-allsum.excise-rubl-doc
    bfpc_tt-allsum.sum-dsc-base-cur    = bf_tt-allsum.sum-dsc-base-cur    - bf_tt-allsum.sum-dsc-base-acc
    bfpc_tt-allsum.sum-dsc-rubl-cur    = bf_tt-allsum.sum-dsc-rubl-cur    - bf_tt-allsum.sum-dsc-rubl-acc
    bfpc_tt-allsum.dsc-base-cur        = bf_tt-allsum.dsc-base-cur        - bf_tt-allsum.dsc-base-acc
    bfpc_tt-allsum.dsc-rubl-cur        = bf_tt-allsum.dsc-rubl-cur        - bf_tt-allsum.dsc-rubl-acc
    bfpc_tt-allsum.vat-base-cur        = bf_tt-allsum.vat-base-cur
    bfpc_tt-allsum.vat-rubl-cur        = bf_tt-allsum.vat-rubl-cur
    bfpc_tt-allsum.vat-base-buyer-cur  = bf_tt-allsum.vat-base-buyer-cur  - bf_tt-allsum.vat-base-acc
    bfpc_tt-allsum.vat-rubl-buyer-cur  = bf_tt-allsum.vat-rubl-buyer-cur  - bf_tt-allsum.vat-rubl-acc
    bfpc_tt-allsum.slt-base-cur        = bf_tt-allsum.slt-base-cur        - bf_tt-allsum.slt-base-acc
    bfpc_tt-allsum.slt-rubl-cur        = bf_tt-allsum.slt-rubl-cur        - bf_tt-allsum.slt-rubl-acc
    bfpc_tt-allsum.road-tax-base-cur   = bf_tt-allsum.road-tax-base-cur   - bf_tt-allsum.road-tax-base-acc
    bfpc_tt-allsum.road-tax-rubl-cur   = bf_tt-allsum.road-tax-rubl-cur   - bf_tt-allsum.road-tax-rubl-acc
    bfpc_tt-allsum.excise-base-cur     = bf_tt-allsum.excise-base-cur
    bfpc_tt-allsum.excise-rubl-cur     = bf_tt-allsum.excise-rubl-cur
    bfpc_tt-allsum.sum-dsc-base-acc    = 0
    bfpc_tt-allsum.sum-dsc-rubl-acc    = 0
    bfpc_tt-allsum.sum-dsc-cli-acc     = 0
    bfpc_tt-allsum.dsc-base-acc        = 0
    bfpc_tt-allsum.dsc-rubl-acc        = 0
    bfpc_tt-allsum.dsc-cli-acc         = 0
    bfpc_tt-allsum.vat-base-acc        = 0
    bfpc_tt-allsum.vat-rubl-acc        = 0
    bfpc_tt-allsum.vat-cli-acc         = 0
    bfpc_tt-allsum.slt-base-acc        = 0
    bfpc_tt-allsum.slt-rubl-acc        = 0
    bfpc_tt-allsum.slt-cli-acc         = 0
    bfpc_tt-allsum.road-tax-base-acc   = 0
    bfpc_tt-allsum.road-tax-rubl-acc   = 0
    bfpc_tt-allsum.road-tax-cli-acc    = 0
    bfpc_tt-allsum.excise-base-acc     = 0
    bfpc_tt-allsum.excise-rubl-acc     = 0
    bfpc_tt-allsum.excise-cli-acc      = 0
    bfpc_tt-allsum.transport-base-acc  = 0
    bfpc_tt-allsum.transport-rubl-acc  = 0
    bfpc_tt-allsum.transport-cli-acc   = 0
    bfpc_tt-allsum.other-base-acc      = 0
    bfpc_tt-allsum.other-rubl-acc      = 0
    bfpc_tt-allsum.other-cli-acc       = 0
    .
  assign
    bfspc_tt-allsum.fact-qnty           = bfs_tt-allsum.fact-qnty
    bfspc_tt-allsum.cli-qnty            = bfs_tt-allsum.cli-qnty
    bfspc_tt-allsum.sum-dsc-base-doc    = bfs_tt-allsum.sum-dsc-base-doc    - bfs_tt-allsum.sum-dsc-base-acc
    bfspc_tt-allsum.sum-dsc-rubl-doc    = bfs_tt-allsum.sum-dsc-rubl-doc    - bfs_tt-allsum.sum-dsc-rubl-acc
    bfspc_tt-allsum.dsc-base-doc        = bfs_tt-allsum.dsc-base-doc        - bfs_tt-allsum.dsc-base-acc
    bfspc_tt-allsum.dsc-rubl-doc        = bfs_tt-allsum.dsc-rubl-doc        - bfs_tt-allsum.dsc-rubl-acc
    bfspc_tt-allsum.vat-base-doc        = bfs_tt-allsum.vat-base-doc
    bfspc_tt-allsum.vat-rubl-doc        = bfs_tt-allsum.vat-rubl-doc
    bfspc_tt-allsum.vat-base-buyer-doc  = bfs_tt-allsum.vat-base-buyer-doc  - bfs_tt-allsum.vat-base-acc
    bfspc_tt-allsum.vat-rubl-buyer-doc  = bfs_tt-allsum.vat-rubl-buyer-doc  - bfs_tt-allsum.vat-rubl-acc
    bfspc_tt-allsum.slt-base-doc        = bfs_tt-allsum.slt-base-doc        - bfs_tt-allsum.slt-base-acc
    bfspc_tt-allsum.slt-rubl-doc        = bfs_tt-allsum.slt-rubl-doc        - bfs_tt-allsum.slt-rubl-acc
    bfspc_tt-allsum.road-tax-base-doc   = bfs_tt-allsum.road-tax-base-doc   - bfs_tt-allsum.road-tax-base-acc
    bfspc_tt-allsum.road-tax-rubl-doc   = bfs_tt-allsum.road-tax-rubl-doc   - bfs_tt-allsum.road-tax-rubl-acc
    bfspc_tt-allsum.excise-base-doc     = bfs_tt-allsum.excise-base-doc
    bfspc_tt-allsum.excise-rubl-doc     = bfs_tt-allsum.excise-rubl-doc
    bfspc_tt-allsum.sum-dsc-base-cur    = bfs_tt-allsum.sum-dsc-base-cur    - bfs_tt-allsum.sum-dsc-base-acc
    bfspc_tt-allsum.sum-dsc-rubl-cur    = bfs_tt-allsum.sum-dsc-rubl-cur    - bfs_tt-allsum.sum-dsc-rubl-acc
    bfspc_tt-allsum.dsc-base-cur        = bfs_tt-allsum.dsc-base-cur        - bfs_tt-allsum.dsc-base-acc
    bfspc_tt-allsum.dsc-rubl-cur        = bfs_tt-allsum.dsc-rubl-cur        - bfs_tt-allsum.dsc-rubl-acc
    bfspc_tt-allsum.vat-base-cur        = bfs_tt-allsum.vat-base-cur
    bfspc_tt-allsum.vat-rubl-cur        = bfs_tt-allsum.vat-rubl-cur
    bfspc_tt-allsum.vat-base-buyer-cur  = bfs_tt-allsum.vat-base-buyer-cur  - bfs_tt-allsum.vat-base-acc
    bfspc_tt-allsum.vat-rubl-buyer-cur  = bfs_tt-allsum.vat-rubl-buyer-cur  - bfs_tt-allsum.vat-rubl-acc
    bfspc_tt-allsum.slt-base-cur        = bfs_tt-allsum.slt-base-cur        - bfs_tt-allsum.slt-base-acc
    bfspc_tt-allsum.slt-rubl-cur        = bfs_tt-allsum.slt-rubl-cur        - bfs_tt-allsum.slt-rubl-acc
    bfspc_tt-allsum.road-tax-base-cur   = bfs_tt-allsum.road-tax-base-cur   - bfs_tt-allsum.road-tax-base-acc
    bfspc_tt-allsum.road-tax-rubl-cur   = bfs_tt-allsum.road-tax-rubl-cur   - bfs_tt-allsum.road-tax-rubl-acc
    bfspc_tt-allsum.excise-base-cur     = bfs_tt-allsum.excise-base-cur
    bfspc_tt-allsum.excise-rubl-cur     = bfs_tt-allsum.excise-rubl-cur
    bfspc_tt-allsum.sum-dsc-base-acc    = 0
    bfspc_tt-allsum.sum-dsc-rubl-acc    = 0
    bfspc_tt-allsum.sum-dsc-cli-acc     = 0
    bfspc_tt-allsum.dsc-base-acc        = 0
    bfspc_tt-allsum.dsc-rubl-acc        = 0
    bfspc_tt-allsum.dsc-cli-acc         = 0
    bfspc_tt-allsum.vat-base-acc        = 0
    bfspc_tt-allsum.vat-rubl-acc        = 0
    bfspc_tt-allsum.vat-cli-acc         = 0
    bfspc_tt-allsum.slt-base-acc        = 0
    bfspc_tt-allsum.slt-rubl-acc        = 0
    bfspc_tt-allsum.slt-cli-acc         = 0
    bfspc_tt-allsum.road-tax-base-acc   = 0
    bfspc_tt-allsum.road-tax-rubl-acc   = 0
    bfspc_tt-allsum.road-tax-cli-acc    = 0
    bfspc_tt-allsum.excise-base-acc     = 0
    bfspc_tt-allsum.excise-rubl-acc     = 0
    bfspc_tt-allsum.excise-cli-acc      = 0
    bfspc_tt-allsum.transport-base-acc  = 0
    bfspc_tt-allsum.transport-rubl-acc  = 0
    bfspc_tt-allsum.transport-cli-acc   = 0
    bfspc_tt-allsum.other-base-acc      = 0
    bfspc_tt-allsum.other-rubl-acc      = 0
    bfspc_tt-allsum.other-cli-acc       = 0
    .
  create bfacc_tt-allsum.
  assign
    bfacc_tt-allsum.sum-type = 'сумма_по_консигнации_закупка':U.
  create bfsacc_tt-allsum.
  assign
    bfsacc_tt-allsum.sum-type = 'сумма_по_консигнации_закупка_со_знаком':U.
  assign
    bfacc_tt-allsum.fact-qnty           = bf_tt-allsum.fact-qnty
    bfacc_tt-allsum.cli-qnty            = bf_tt-allsum.cli-qnty
    bfacc_tt-allsum.sum-dsc-base-doc    = bf_tt-allsum.sum-dsc-base-acc
    bfacc_tt-allsum.sum-dsc-rubl-doc    = bf_tt-allsum.sum-dsc-rubl-acc
    bfacc_tt-allsum.dsc-base-doc        = bf_tt-allsum.dsc-base-acc
    bfacc_tt-allsum.dsc-rubl-doc        = bf_tt-allsum.dsc-rubl-acc
    bfacc_tt-allsum.vat-base-doc        = 0
    bfacc_tt-allsum.vat-rubl-doc        = 0
    bfacc_tt-allsum.vat-base-buyer-doc  = bf_tt-allsum.vat-base-acc
    bfacc_tt-allsum.vat-rubl-buyer-doc  = bf_tt-allsum.vat-rubl-acc
    bfacc_tt-allsum.slt-base-doc        = bf_tt-allsum.slt-base-acc
    bfacc_tt-allsum.slt-rubl-doc        = bf_tt-allsum.slt-rubl-acc
    bfacc_tt-allsum.road-tax-base-doc   = bf_tt-allsum.road-tax-base-acc
    bfacc_tt-allsum.road-tax-rubl-doc   = bf_tt-allsum.road-tax-rubl-acc
    bfacc_tt-allsum.excise-base-doc     = bf_tt-allsum.excise-base-acc
    bfacc_tt-allsum.excise-rubl-doc     = bf_tt-allsum.excise-rubl-acc
    bfacc_tt-allsum.sum-dsc-base-cur    = bf_tt-allsum.sum-dsc-base-acc
    bfacc_tt-allsum.sum-dsc-rubl-cur    = bf_tt-allsum.sum-dsc-rubl-acc
    bfacc_tt-allsum.dsc-base-cur        = bf_tt-allsum.dsc-base-acc
    bfacc_tt-allsum.dsc-rubl-cur        = bf_tt-allsum.dsc-rubl-acc
    bfacc_tt-allsum.vat-base-cur        = 0
    bfacc_tt-allsum.vat-rubl-cur        = 0
    bfacc_tt-allsum.vat-base-buyer-cur  = bf_tt-allsum.vat-base-acc
    bfacc_tt-allsum.vat-rubl-buyer-cur  = bf_tt-allsum.vat-rubl-acc
    bfacc_tt-allsum.slt-base-cur        = bf_tt-allsum.slt-base-acc
    bfacc_tt-allsum.slt-rubl-cur        = bf_tt-allsum.slt-rubl-acc
    bfacc_tt-allsum.road-tax-base-cur   = bf_tt-allsum.road-tax-base-acc
    bfacc_tt-allsum.road-tax-rubl-cur   = bf_tt-allsum.road-tax-rubl-acc
    bfacc_tt-allsum.excise-base-cur     = bf_tt-allsum.excise-base-acc
    bfacc_tt-allsum.excise-rubl-cur     = bf_tt-allsum.excise-rubl-acc
    bfacc_tt-allsum.sum-dsc-base-acc    = bf_tt-allsum.sum-dsc-base-acc
    bfacc_tt-allsum.sum-dsc-rubl-acc    = bf_tt-allsum.sum-dsc-rubl-acc
    bfacc_tt-allsum.sum-dsc-cli-acc     = bf_tt-allsum.sum-dsc-cli-acc
    bfacc_tt-allsum.dsc-base-acc        = bf_tt-allsum.dsc-base-acc
    bfacc_tt-allsum.dsc-rubl-acc        = bf_tt-allsum.dsc-rubl-acc
    bfacc_tt-allsum.dsc-cli-acc         = bf_tt-allsum.dsc-cli-acc
    bfacc_tt-allsum.vat-base-acc        = bf_tt-allsum.vat-base-acc
    bfacc_tt-allsum.vat-rubl-acc        = bf_tt-allsum.vat-rubl-acc
    bfacc_tt-allsum.vat-cli-acc         = bf_tt-allsum.vat-cli-acc
    bfacc_tt-allsum.slt-base-acc        = bf_tt-allsum.slt-base-acc
    bfacc_tt-allsum.slt-rubl-acc        = bf_tt-allsum.slt-rubl-acc
    bfacc_tt-allsum.slt-cli-acc         = bf_tt-allsum.slt-cli-acc
    bfacc_tt-allsum.excise-base-acc     = bf_tt-allsum.excise-base-acc
    bfacc_tt-allsum.excise-rubl-acc     = bf_tt-allsum.excise-rubl-acc
    bfacc_tt-allsum.excise-cli-acc      = bf_tt-allsum.excise-cli-acc
    bfacc_tt-allsum.road-tax-base-acc   = bf_tt-allsum.road-tax-base-acc
    bfacc_tt-allsum.road-tax-rubl-acc   = bf_tt-allsum.road-tax-rubl-acc
    bfacc_tt-allsum.road-tax-cli-acc    = bf_tt-allsum.road-tax-cli-acc
    bfacc_tt-allsum.transport-base-acc  = bf_tt-allsum.transport-base-acc
    bfacc_tt-allsum.transport-rubl-acc  = bf_tt-allsum.transport-rubl-acc
    bfacc_tt-allsum.transport-cli-acc   = bf_tt-allsum.transport-cli-acc
    bfacc_tt-allsum.other-base-acc      = bf_tt-allsum.other-base-acc
    bfacc_tt-allsum.other-rubl-acc      = bf_tt-allsum.other-rubl-acc
    bfacc_tt-allsum.other-cli-acc       = bf_tt-allsum.other-cli-acc
    .
  assign
    bfsacc_tt-allsum.fact-qnty           = bfs_tt-allsum.fact-qnty
    bfsacc_tt-allsum.cli-qnty            = bfs_tt-allsum.cli-qnty
    bfsacc_tt-allsum.sum-dsc-base-doc    = bfs_tt-allsum.sum-dsc-base-acc
    bfsacc_tt-allsum.sum-dsc-rubl-doc    = bfs_tt-allsum.sum-dsc-rubl-acc
    bfsacc_tt-allsum.dsc-base-doc        = bfs_tt-allsum.dsc-base-acc
    bfsacc_tt-allsum.dsc-rubl-doc        = bfs_tt-allsum.dsc-rubl-acc
    bfsacc_tt-allsum.vat-base-doc        = 0
    bfsacc_tt-allsum.vat-rubl-doc        = 0
    bfsacc_tt-allsum.vat-base-buyer-doc  = bfs_tt-allsum.vat-base-acc
    bfsacc_tt-allsum.vat-rubl-buyer-doc  = bfs_tt-allsum.vat-rubl-acc
    bfsacc_tt-allsum.slt-base-doc        = bfs_tt-allsum.slt-base-acc
    bfsacc_tt-allsum.slt-rubl-doc        = bfs_tt-allsum.slt-rubl-acc
    bfsacc_tt-allsum.road-tax-base-doc   = bfs_tt-allsum.road-tax-base-acc
    bfsacc_tt-allsum.road-tax-rubl-doc   = bfs_tt-allsum.road-tax-rubl-acc
    bfsacc_tt-allsum.excise-base-doc     = bfs_tt-allsum.excise-base-acc
    bfsacc_tt-allsum.excise-rubl-doc     = bfs_tt-allsum.excise-rubl-acc
    bfsacc_tt-allsum.sum-dsc-base-cur    = bfs_tt-allsum.sum-dsc-base-acc
    bfsacc_tt-allsum.sum-dsc-rubl-cur    = bfs_tt-allsum.sum-dsc-rubl-acc
    bfsacc_tt-allsum.dsc-base-cur        = bfs_tt-allsum.dsc-base-acc
    bfsacc_tt-allsum.dsc-rubl-cur        = bfs_tt-allsum.dsc-rubl-acc
    bfsacc_tt-allsum.vat-base-cur        = 0
    bfsacc_tt-allsum.vat-rubl-cur        = 0
    bfsacc_tt-allsum.vat-base-buyer-cur  = bfs_tt-allsum.vat-base-acc
    bfsacc_tt-allsum.vat-rubl-buyer-cur  = bfs_tt-allsum.vat-rubl-acc
    bfsacc_tt-allsum.slt-base-cur        = bfs_tt-allsum.slt-base-acc
    bfsacc_tt-allsum.slt-rubl-cur        = bfs_tt-allsum.slt-rubl-acc
    bfsacc_tt-allsum.road-tax-base-cur   = bfs_tt-allsum.road-tax-base-acc
    bfsacc_tt-allsum.road-tax-rubl-cur   = bfs_tt-allsum.road-tax-rubl-acc
    bfsacc_tt-allsum.excise-base-cur     = bfs_tt-allsum.excise-base-acc
    bfsacc_tt-allsum.excise-rubl-cur     = bfs_tt-allsum.excise-rubl-acc
    bfsacc_tt-allsum.sum-dsc-base-acc    = bfs_tt-allsum.sum-dsc-base-acc
    bfsacc_tt-allsum.sum-dsc-rubl-acc    = bfs_tt-allsum.sum-dsc-rubl-acc
    bfsacc_tt-allsum.sum-dsc-cli-acc     = bfs_tt-allsum.sum-dsc-cli-acc
    bfsacc_tt-allsum.dsc-base-acc        = bfs_tt-allsum.dsc-base-acc
    bfsacc_tt-allsum.dsc-rubl-acc        = bfs_tt-allsum.dsc-rubl-acc
    bfsacc_tt-allsum.dsc-cli-acc         = bfs_tt-allsum.dsc-cli-acc
    bfsacc_tt-allsum.vat-base-acc        = bfs_tt-allsum.vat-base-acc
    bfsacc_tt-allsum.vat-rubl-acc        = bfs_tt-allsum.vat-rubl-acc
    bfsacc_tt-allsum.vat-cli-acc         = bfs_tt-allsum.vat-cli-acc
    bfsacc_tt-allsum.slt-base-acc        = bfs_tt-allsum.slt-base-acc
    bfsacc_tt-allsum.slt-rubl-acc        = bfs_tt-allsum.slt-rubl-acc
    bfsacc_tt-allsum.slt-cli-acc         = bfs_tt-allsum.slt-cli-acc
    bfsacc_tt-allsum.excise-base-acc     = bfs_tt-allsum.excise-base-acc
    bfsacc_tt-allsum.excise-rubl-acc     = bfs_tt-allsum.excise-rubl-acc
    bfsacc_tt-allsum.excise-cli-acc      = bfs_tt-allsum.excise-cli-acc
    bfsacc_tt-allsum.road-tax-base-acc   = bfs_tt-allsum.road-tax-base-acc
    bfsacc_tt-allsum.road-tax-rubl-acc   = bfs_tt-allsum.road-tax-rubl-acc
    bfsacc_tt-allsum.road-tax-cli-acc    = bfs_tt-allsum.road-tax-cli-acc
    bfsacc_tt-allsum.transport-base-acc  = bfs_tt-allsum.transport-base-acc
    bfsacc_tt-allsum.transport-rubl-acc  = bfs_tt-allsum.transport-rubl-acc
    bfsacc_tt-allsum.transport-cli-acc   = bfs_tt-allsum.transport-cli-acc
    bfsacc_tt-allsum.other-base-acc      = bfs_tt-allsum.other-base-acc
    bfsacc_tt-allsum.other-rubl-acc      = bfs_tt-allsum.other-rubl-acc
    bfsacc_tt-allsum.other-cli-acc       = bfs_tt-allsum.other-cli-acc
    .
end.
otherwise do:
  return error substitute ("Неизвестный тип приобретения &1 по партии с кодом &2 по документу &3, порожденную документом &4 по товару &5 &6 &7.",
                           cl_tt-clcparts.purch-code,
                           cl_tt-clcparts.part-code,
                           cl_tt-clcparts.out-code,
                           cl_tt-clcparts.in-code,
                           cl_tt-clcparts.artic,
                           cl_tt-clcparts.prod-type,
                           cl_tt-clcparts.prod-code).
end.
end case.
end.
end procedure.
procedure clcprtsl_calc-line :
define input  parameter parrec-line as recid no-undo.
define variable v-tax-date         as   date                     no-undo.
define variable v-vat-pc           like ub.doc-line.vat-pc       no-undo.
define variable varr-b             as   character                no-undo.
define variable varr-btype         as   character                no-undo.
define variable varcur-base        like ub.gds-dtl.price-base    no-undo.
define variable varcur-road-tax    like ub.doc-line.road-tax     no-undo.
define variable varcur-excise      like ub.doc-line.excise       no-undo.
define variable varcur-vat-pc      like ub.doc-line.vat-pc       no-undo.
define variable varcur-cons-vat-pc like ub.doc-line.cons-vat-pc  no-undo.
define variable varcur-slt-pc      like ub.doc-line.slt-pc       no-undo.
define variable varcur-fact-qnty   like ub.gds-dtl.fact-qnty     no-undo.
define variable varb-code          like ub.bar-code.b-code       no-undo.
define variable vardoc-num         like ub.price-doc.doc-num     no-undo.
define variable varprice-sale      like ub.price-list.price-sale no-undo.
define variable varroad-tax        like ub.price-list.road-tax   no-undo.
define variable varexcise          like ub.price-list.excise     no-undo.
define variable varlastcur-base        like ub.gds-dtl.price-base no-undo.
define variable varlastcur-road-tax    like ub.gds-dtl.price-base no-undo.
define variable varlastcur-excise      like ub.gds-dtl.price-base     no-undo.
define variable v-b-pcode          like ub.bar-code.b-code     no-undo.
define variable v-varsum           as decimal                  no-undo.
define variable varprice-salef as decimal   no-undo .
define buffer bf_trn-doc             for ub.trn-doc.
define buffer bf_doc-line            for ub.doc-line.
define buffer bf_gds-dtl             for ub.gds-dtl.
define buffer bf_goods               for ub.goods.
define buffer bf_parts               for ub.parts.
define buffer bf_sysconf             for ub.sysconf.
define buffer bf_tt-allsum-line      for tt-allsum-line.
define buffer bfs_tt-allsum-line     for tt-allsum-line.
define buffer bfo_tt-allsum-line     for tt-allsum-line.
define buffer bfos_tt-allsum-line    for tt-allsum-line.
define buffer buf_parts        for ub.parts.
v-calcbypart = no.
do on error undo, return error return-value :
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varr-b
  )  .
  find first bf_doc-line where recid (bf_doc-line) = parrec-line no-lock.
  find first bf_trn-doc where bf_trn-doc.doc-code = bf_doc-line.doc-code no-lock.
  find first bf_goods where bf_goods.artic     = bf_doc-line.artic     and
                            bf_goods.prod-type = bf_doc-line.prod-type and
                            bf_goods.prod-code = bf_doc-line.prod-code no-lock.
  if bf_trn-doc.fact-date <> ?        then do:
    assign v-tax-date = bf_trn-doc.fact-date.
  end.
  else do:
    assign v-tax-date = ?.
  end.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  bf_goods.gds-code
  ,input  '1':U
  ,input  v-tax-date
  ,input  bf_trn-doc.host-code
  ,input  bf_trn-doc.obj-type
  ,input  bf_trn-doc.obj-code
  ,output v-vat-pc
  ) no-error .
  if error-status :error
  or v-vat-pc = ? then do:
     return error substitute ("Ошибка при поиске НДС для товара &1 &2 &3", bf_goods.artic, bf_goods.prod-type, bf_goods.prod-code).
  end.
  if bf_goods.gds-type = 'у':U or
     bf_trn-doc.status_ = 'запрос':U then do:
    for each bf_tt-allsum-line
    on error undo, return error return-value
     :
      delete bf_tt-allsum-line.
    end.
    create bf_tt-allsum-line.
    assign
     bf_tt-allsum-line.sum-type = 'основная_сумма':U.
    for each bf_gds-dtl where bf_gds-dtl.doc-code  = bf_doc-line.doc-code  and
                              bf_gds-dtl.artic     = bf_doc-line.artic     and
                              bf_gds-dtl.prod-type = bf_doc-line.prod-type and
                              bf_gds-dtl.prod-code = bf_doc-line.prod-code no-lock on error undo, return error return-value :
      assign
        bf_tt-allsum-line.fact-qnty            =  bf_tt-allsum-line.fact-qnty        + bf_gds-dtl.fact-qnty
        bf_tt-allsum-line.sum-dsc-base-doc     =  bf_tt-allsum-line.sum-dsc-base-doc + (bf_gds-dtl.price-base - bf_gds-dtl.discnt-base) * bf_gds-dtl.fact-qnty
        bf_tt-allsum-line.sum-dsc-rubl-doc     =  bf_tt-allsum-line.sum-dsc-rubl-doc + (bf_gds-dtl.price-rubl - bf_gds-dtl.discnt-rubl) * bf_gds-dtl.fact-qnty
        bf_tt-allsum-line.dsc-base-doc         =  bf_tt-allsum-line.dsc-base-doc     + bf_gds-dtl.discnt-base * bf_gds-dtl.fact-qnty
        bf_tt-allsum-line.dsc-rubl-doc         =  bf_tt-allsum-line.dsc-rubl-doc     + bf_gds-dtl.discnt-rubl * bf_gds-dtl.fact-qnty
        bf_tt-allsum-line.sum-dsc-base-cur     =  bf_tt-allsum-line.sum-dsc-base-cur + (if varr-b = "base" then bf_gds-dtl.cur-base else bf_gds-dtl.cur-base / bf_trn-doc.exch-rate * bf_trn-doc.exch-scale) * bf_gds-dtl.fact-qnty
        bf_tt-allsum-line.sum-dsc-rubl-cur     =  bf_tt-allsum-line.sum-dsc-rubl-cur + (if varr-b = "rubl" then bf_gds-dtl.cur-base else bf_gds-dtl.cur-base * bf_trn-doc.exch-rate / bf_trn-doc.exch-scale) * bf_gds-dtl.fact-qnty
        bf_tt-allsum-line.sum-dsc-base-acc     =  bf_tt-allsum-line.sum-dsc-base-acc + bf_doc-line.price-base * bf_gds-dtl.fact-qnty
        bf_tt-allsum-line.sum-dsc-rubl-acc     =  bf_tt-allsum-line.sum-dsc-rubl-acc + bf_doc-line.price-rubl * bf_gds-dtl.fact-qnty
        bf_tt-allsum-line.sum-dsc-cli-acc      =  ?
        bf_tt-allsum-line.vat-base-acc         =  bf_tt-allsum-line.vat-base-acc     + bf_doc-line.price-base * v-vat-pc / (100 + v-vat-pc) * bf_gds-dtl.fact-qnty
        bf_tt-allsum-line.vat-rubl-acc         =  bf_tt-allsum-line.vat-rubl-acc     + bf_doc-line.price-rubl * v-vat-pc / (100 + v-vat-pc) * bf_gds-dtl.fact-qnty
        bf_tt-allsum-line.vat-cli-acc          =  ?
        .
    end.
    assign
      bf_tt-allsum-line.cli-qnty             =  ?
      bf_tt-allsum-line.slt-base-doc         =  bf_tt-allsum-line.sum-dsc-base-doc * bf_doc-line.slt-pc / (100 + bf_doc-line.slt-pc)
      bf_tt-allsum-line.slt-rubl-doc         =  bf_tt-allsum-line.sum-dsc-rubl-doc * bf_doc-line.slt-pc / (100 + bf_doc-line.slt-pc)
      bf_tt-allsum-line.vat-base-buyer-doc   =  (bf_tt-allsum-line.sum-dsc-base-doc - bf_tt-allsum-line.slt-base-doc) * bf_doc-line.vat-pc / (100 + bf_doc-line.vat-pc)
      bf_tt-allsum-line.vat-rubl-buyer-doc   =  (bf_tt-allsum-line.sum-dsc-rubl-doc - bf_tt-allsum-line.slt-rubl-doc) * bf_doc-line.vat-pc / (100 + bf_doc-line.vat-pc)
      bf_tt-allsum-line.road-tax-base-doc    =  0
      bf_tt-allsum-line.road-tax-rubl-doc    =  0
      bf_tt-allsum-line.excise-base-doc      =  0
      bf_tt-allsum-line.excise-rubl-doc      =  0
      bf_tt-allsum-line.vat-base-doc         =  bf_tt-allsum-line.vat-base-buyer-doc
      bf_tt-allsum-line.vat-rubl-doc         =  bf_tt-allsum-line.vat-rubl-buyer-doc
      bf_tt-allsum-line.dsc-base-cur         =  0
      bf_tt-allsum-line.dsc-rubl-cur         =  0
      bf_tt-allsum-line.slt-base-cur         =  bf_tt-allsum-line.sum-dsc-base-cur * bf_doc-line.slt-pc / (100 + bf_doc-line.slt-pc)
      bf_tt-allsum-line.slt-rubl-cur         =  bf_tt-allsum-line.sum-dsc-rubl-cur * bf_doc-line.slt-pc / (100 + bf_doc-line.slt-pc)
      bf_tt-allsum-line.vat-base-buyer-cur   =  (bf_tt-allsum-line.sum-dsc-base-cur - bf_tt-allsum-line.slt-base-cur) * bf_doc-line.vat-pc / (100 + bf_doc-line.vat-pc)
      bf_tt-allsum-line.vat-rubl-buyer-cur   =  (bf_tt-allsum-line.sum-dsc-rubl-cur - bf_tt-allsum-line.slt-rubl-cur) * bf_doc-line.vat-pc / (100 + bf_doc-line.vat-pc)
      bf_tt-allsum-line.road-tax-base-cur    =  0
      bf_tt-allsum-line.road-tax-rubl-cur    =  0
      bf_tt-allsum-line.excise-base-cur      =  0
      bf_tt-allsum-line.excise-rubl-cur      =  0
      bf_tt-allsum-line.vat-base-cur         =  bf_tt-allsum-line.vat-base-buyer-cur
      bf_tt-allsum-line.vat-rubl-cur         =  bf_tt-allsum-line.vat-rubl-buyer-cur
      bf_tt-allsum-line.dsc-base-acc         =  0
      bf_tt-allsum-line.dsc-rubl-acc         =  0
      bf_tt-allsum-line.dsc-cli-acc          =  0
      bf_tt-allsum-line.slt-base-acc         =  0
      bf_tt-allsum-line.slt-rubl-acc         =  0
      bf_tt-allsum-line.slt-cli-acc          =  0
      bf_tt-allsum-line.road-tax-base-acc    =  0
      bf_tt-allsum-line.road-tax-rubl-acc    =  0
      bf_tt-allsum-line.road-tax-cli-acc     =  0
      bf_tt-allsum-line.excise-base-acc      =  0
      bf_tt-allsum-line.excise-rubl-acc      =  0
      bf_tt-allsum-line.excise-cli-acc       =  0
      bf_tt-allsum-line.transport-base-acc   =  0
      bf_tt-allsum-line.transport-rubl-acc   =  0
      bf_tt-allsum-line.transport-cli-acc    =  0
      bf_tt-allsum-line.other-base-acc       =  0
      bf_tt-allsum-line.other-rubl-acc       =  0
      bf_tt-allsum-line.other-cli-acc        =  0
      .
    create bfs_tt-allsum-line.
    assign
    bfs_tt-allsum-line.sum-type = 'основная_сумма_со_знаком':U.
    if bf_trn-doc.doc-type = 'инв':U or
       bf_trn-doc.doc-type = 'при':U    or
       bf_trn-doc.doc-type = 'возврат':U    then do:
       buffer-copy bf_tt-allsum-line except bf_tt-allsum-line.sum-type to bfs_tt-allsum-line.
    end.
    else do:
      assign
        bfs_tt-allsum-line.fact-qnty           =  - bf_tt-allsum-line.fact-qnty
        bfs_tt-allsum-line.cli-qnty            =  - bf_tt-allsum-line.cli-qnty
        bfs_tt-allsum-line.sum-dsc-base-doc    =  - bf_tt-allsum-line.sum-dsc-base-doc
        bfs_tt-allsum-line.sum-dsc-rubl-doc    =  - bf_tt-allsum-line.sum-dsc-rubl-doc
        bfs_tt-allsum-line.dsc-base-doc        =  - bf_tt-allsum-line.dsc-base-doc
        bfs_tt-allsum-line.dsc-rubl-doc        =  - bf_tt-allsum-line.dsc-rubl-doc
        bfs_tt-allsum-line.vat-base-doc        =  - bf_tt-allsum-line.vat-base-doc
        bfs_tt-allsum-line.vat-rubl-doc        =  - bf_tt-allsum-line.vat-rubl-doc
        bfs_tt-allsum-line.vat-base-buyer-doc  =  - bf_tt-allsum-line.vat-base-buyer-doc
        bfs_tt-allsum-line.vat-rubl-buyer-doc  =  - bf_tt-allsum-line.vat-rubl-buyer-doc
        bfs_tt-allsum-line.slt-base-doc        =  - bf_tt-allsum-line.slt-base-doc
        bfs_tt-allsum-line.slt-rubl-doc        =  - bf_tt-allsum-line.slt-rubl-doc
        bfs_tt-allsum-line.road-tax-base-doc   =  - bf_tt-allsum-line.road-tax-base-doc
        bfs_tt-allsum-line.road-tax-rubl-doc   =  - bf_tt-allsum-line.road-tax-rubl-doc
        bfs_tt-allsum-line.excise-base-doc     =  - bf_tt-allsum-line.excise-base-doc
        bfs_tt-allsum-line.excise-rubl-doc     =  - bf_tt-allsum-line.excise-rubl-doc
        bfs_tt-allsum-line.sum-dsc-base-cur    =  - bf_tt-allsum-line.sum-dsc-base-cur
        bfs_tt-allsum-line.sum-dsc-rubl-cur    =  - bf_tt-allsum-line.sum-dsc-rubl-cur
        bfs_tt-allsum-line.dsc-base-cur        =  - bf_tt-allsum-line.dsc-base-cur
        bfs_tt-allsum-line.dsc-rubl-cur        =  - bf_tt-allsum-line.dsc-rubl-cur
        bfs_tt-allsum-line.vat-base-cur        =  - bf_tt-allsum-line.vat-base-cur
        bfs_tt-allsum-line.vat-rubl-cur        =  - bf_tt-allsum-line.vat-rubl-cur
        bfs_tt-allsum-line.vat-base-buyer-cur  =  - bf_tt-allsum-line.vat-base-buyer-cur
        bfs_tt-allsum-line.vat-rubl-buyer-cur  =  - bf_tt-allsum-line.vat-rubl-buyer-cur
        bfs_tt-allsum-line.slt-base-cur        =  - bf_tt-allsum-line.slt-base-cur
        bfs_tt-allsum-line.slt-rubl-cur        =  - bf_tt-allsum-line.slt-rubl-cur
        bfs_tt-allsum-line.road-tax-base-cur   =  - bf_tt-allsum-line.road-tax-base-cur
        bfs_tt-allsum-line.road-tax-rubl-cur   =  - bf_tt-allsum-line.road-tax-rubl-cur
        bfs_tt-allsum-line.excise-base-cur     =  - bf_tt-allsum-line.excise-base-cur
        bfs_tt-allsum-line.excise-rubl-cur     =  - bf_tt-allsum-line.excise-rubl-cur
        bfs_tt-allsum-line.sum-dsc-base-acc    =  - bf_tt-allsum-line.sum-dsc-base-acc
        bfs_tt-allsum-line.sum-dsc-rubl-acc    =  - bf_tt-allsum-line.sum-dsc-rubl-acc
        bfs_tt-allsum-line.sum-dsc-cli-acc     =  - bf_tt-allsum-line.sum-dsc-cli-acc
        bfs_tt-allsum-line.dsc-base-acc        =  - bf_tt-allsum-line.dsc-base-acc
        bfs_tt-allsum-line.dsc-rubl-acc        =  - bf_tt-allsum-line.dsc-rubl-acc
        bfs_tt-allsum-line.dsc-cli-acc         =  - bf_tt-allsum-line.dsc-cli-acc
        bfs_tt-allsum-line.vat-base-acc        =  - bf_tt-allsum-line.vat-base-acc
        bfs_tt-allsum-line.vat-rubl-acc        =  - bf_tt-allsum-line.vat-rubl-acc
        bfs_tt-allsum-line.vat-cli-acc         =  - bf_tt-allsum-line.vat-cli-acc
        bfs_tt-allsum-line.slt-base-acc        =  - bf_tt-allsum-line.slt-base-acc
        bfs_tt-allsum-line.slt-rubl-acc        =  - bf_tt-allsum-line.slt-rubl-acc
        bfs_tt-allsum-line.slt-cli-acc         =  - bf_tt-allsum-line.slt-cli-acc
        bfs_tt-allsum-line.road-tax-base-acc   =  - bf_tt-allsum-line.road-tax-base-acc
        bfs_tt-allsum-line.road-tax-rubl-acc   =  - bf_tt-allsum-line.road-tax-rubl-acc
        bfs_tt-allsum-line.road-tax-cli-acc    =  - bf_tt-allsum-line.road-tax-cli-acc
        bfs_tt-allsum-line.excise-base-acc     =  - bf_tt-allsum-line.excise-base-acc
        bfs_tt-allsum-line.excise-rubl-acc     =  - bf_tt-allsum-line.excise-rubl-acc
        bfs_tt-allsum-line.excise-cli-acc      =  - bf_tt-allsum-line.excise-cli-acc
        bfs_tt-allsum-line.transport-base-acc  =  - bf_tt-allsum-line.transport-base-acc
        bfs_tt-allsum-line.transport-rubl-acc  =  - bf_tt-allsum-line.transport-rubl-acc
        bfs_tt-allsum-line.transport-cli-acc   =  - bf_tt-allsum-line.transport-cli-acc
        bfs_tt-allsum-line.other-base-acc      =  - bf_tt-allsum-line.other-base-acc
        bfs_tt-allsum-line.other-rubl-acc      =  - bf_tt-allsum-line.other-rubl-acc
        bfs_tt-allsum-line.other-cli-acc       =  - bf_tt-allsum-line.other-cli-acc
        .
    end.
    create bfo_tt-allsum-line.
    assign
      bfo_tt-allsum-line.sum-type = 'сумма_по_услуге':U.
    buffer-copy bf_tt-allsum-line except bf_tt-allsum-line.sum-type to bfo_tt-allsum-line.
    create bfos_tt-allsum-line.
    assign
      bfos_tt-allsum-line.sum-type = 'сумма_по_услуге_со_знаком':U.
    buffer-copy bfs_tt-allsum-line except bfs_tt-allsum-line.sum-type to bfos_tt-allsum-line.
  end.
  else do:
    assign
      varlastcur-base      = 0
      varlastcur-road-tax  = 0
      varlastcur-excise    = 0
      varcur-base          = 0
      varcur-road-tax      = 0
      varcur-excise        = 0
      varcur-vat-pc        = 0
      varcur-slt-pc        = 0
      varcur-fact-qnty     = 0
    .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  bf_goods.gds-code
  ,input  ?
  ,output varb-code
  )  .
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcprcex in g#library
  (input  bf_trn-doc.obj-type
  ,input  bf_trn-doc.obj-code
  ,input  varb-code
  ,input  0
  ,input  bf_trn-doc.fact-order
  ,output vardoc-num
  ,output varprice-sale
  ,output varroad-tax
  ,output varexcise
  ,output varcur-vat-pc
  ,output varcur-slt-pc
  )  .
    if varprice-sale = ?
    then do:
      assign
        varcur-vat-pc = 0
        varcur-slt-pc = 0
      .
    end.
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  bf_goods.gds-code
  ,input  '1':U
  ,input  bf_trn-doc.fact-date
  ,input  bf_trn-doc.host-code
  ,input  bf_trn-doc.obj-type
  ,input  bf_trn-doc.obj-code
  ,output varcur-vat-pc
  ) no-error .
    if varcur-vat-pc = ?
    then do:
      return error substitute ("Ошибка при поиске НДС для товара &1 &2 &3 документ &4", bf_goods.artic, bf_goods.prod-type, bf_goods.prod-code, bf_trn-doc.doc-code).
    end.
    if varcur-slt-pc = ?
    then do:
      return error substitute ("Ошибка при поиске НДС для товара &1 &2 &3 документ &4", bf_goods.artic, bf_goods.prod-type, bf_goods.prod-code, bf_trn-doc.doc-code).
    end.
    v-calcbypart = no.
    if bf_doc-line.whole-send-news = integer('1':U)   then
    v-calcbypart = yes.
    else do:
    for each bf_gds-dtl no-lock
      where bf_gds-dtl.doc-code  = bf_doc-line.doc-code
        and bf_gds-dtl.artic     = bf_doc-line.artic
        and bf_gds-dtl.prod-type = bf_doc-line.prod-type
        and bf_gds-dtl.prod-code = bf_doc-line.prod-code
    on error undo, return error return-value
    :
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  bf_goods.gds-code
  ,input  bf_gds-dtl.prt-code
  ,output varb-code
  ) no-error .
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  bf_trn-doc.obj-type
  ,input  bf_trn-doc.obj-code
  ,input  varb-code
  ,input  0
  ,input  bf_trn-doc.fact-order
  ,output vardoc-num
  ,output varprice-sale
  ,output varroad-tax
  ,output varexcise
  )  .
          if varprice-sale = ?
          then do:
            assign
              varprice-sale = 0
              varroad-tax   = 0
              varexcise     = 0
            .
          end.
          assign
            varlastcur-base     = varprice-sale
            varlastcur-road-tax = varroad-tax
            varlastcur-excise   = varexcise
            varcur-base         = varcur-base      + varprice-sale * bf_gds-dtl.fact-qnty
            varcur-road-tax     = varcur-road-tax  + varroad-tax   * bf_gds-dtl.fact-qnty
            varcur-excise       = varcur-excise    + varexcise     * bf_gds-dtl.fact-qnty
            varcur-fact-qnty    = varcur-fact-qnty + bf_gds-dtl.fact-qnty
          .
      end.
    end.
    if varcur-fact-qnty = 0 then do:
      assign
        varcur-base      = varlastcur-base
        varcur-road-tax  = varlastcur-road-tax
        varcur-excise    = varlastcur-excise
      .
    end.
    else do:
      assign
        varcur-base      = varcur-base      / varcur-fact-qnty
        varcur-road-tax  = varcur-road-tax  / varcur-fact-qnty
        varcur-excise    = varcur-excise    / varcur-fact-qnty
      .
    end.
    if varcur-vat-pc = ?
    then do:
      return error substitute ("Нет текущего продажного НДС по товару &1 &2 &3", bf_goods.artic, bf_goods.prod-type, bf_goods.prod-code).
    end.
    if varcur-slt-pc = ?
    then do:
      return error substitute ("Нет текущего продажного НП по товару &1 &2 &3", bf_goods.artic, bf_goods.prod-type, bf_goods.prod-code).
    end.
    find first bf_sysconf where bf_sysconf.host-code = bf_trn-doc.host-code no-lock.
    assign
      varcur-cons-vat-pc = bf_sysconf.cons-vat-pc.
    if varcur-cons-vat-pc = ? then do:
      return error substitute ("Нет текущего продажного консигнационного НДС по фирме &1", bf_trn-doc.host-code).
    end.
    define buffer buf_tt-clcparts for tt-clcparts .
    for each buf_tt-clcparts
    on error undo, return error return-value
    :
      delete buf_tt-clcparts.
    end.
    for each bf_parts no-lock
      where bf_parts.out-code  = bf_doc-line.doc-code
        and bf_parts.obj-type  = bf_doc-line.obj-type
        and bf_parts.obj-code  = bf_doc-line.obj-code
        and bf_parts.artic     = bf_doc-line.artic
        and bf_parts.prod-type = bf_doc-line.prod-type
        and bf_parts.prod-code = bf_doc-line.prod-code
    on error undo, return error return-value
    :
      create buf_tt-clcparts .
      buffer-copy bf_parts to buf_tt-clcparts .
      if v-calcbypart = yes   then do:
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run partbcod in g#library
  (buffer bf_parts
  ,output v-b-pcode
  ) no-error .
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  bf_parts.obj-type
  ,input  bf_parts.obj-code
  ,input  v-b-pcode
  ,input  0
  ,input  bf_trn-doc.fact-order
  ,output vardoc-num
  ,output varprice-salef
  ,output varroad-tax
  ,output varexcise
  ) no-error .
          if varprice-sale = ?
          then do:
            assign
              varprice-salef = 0
              varroad-tax   = 0
              varexcise     = 0
            .
          end.
          assign
          part-cur-base  = varprice-salef
          part-cur-road-tax  = varroad-tax
          part-cur-excise = varexcise.
      end.
    end.
    run clcprtsl_calc-ttable in this-procedure
      (input yes,
       input yes,
       input bf_doc-line.road-tax,
       input bf_doc-line.excise,
       input bf_doc-line.vat-pc,
       input bf_doc-line.cons-vat-pc,
       input bf_doc-line.slt-pc,
       input bf_trn-doc.base-rate,
       input bf_trn-doc.base-scale,
       input varr-b,
       input varcur-base,
       input varcur-road-tax,
       input varcur-excise,
       input varcur-vat-pc,
       input varcur-cons-vat-pc,
       input varcur-slt-pc
       ) no-error.
    if error-status:error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры clcprtsl_calc-ttable." skip
        return-value skip
        trim(error-status :get-message(1))
        trim(error-status :get-message(2))
        trim(error-status :get-message(3))
        trim(error-status :get-message(4))
        trim(error-status :get-message(5)) skip
        view-as alert-box error.
      undo, return error .
    end.
  end.
end.
end.
procedure clcprtsl_calc-ttable :
define input parameter paris-doc           as   logical                 no-undo.
define input parameter paris-cur           as   logical                 no-undo.
define input parameter parroad-tax         like ub.doc-line.road-tax    no-undo.
define input parameter parexcise           like ub.doc-line.excise      no-undo.
define input parameter parvat-pc           like ub.doc-line.vat-pc      no-undo.
define input parameter parcons-vat-pc      like ub.doc-line.cons-vat-pc no-undo.
define input parameter parslt-pc           like ub.doc-line.slt-pc      no-undo.
define input parameter parbase-rate        like ub.trn-doc.base-rate    no-undo.
define input parameter parbase-scale       like ub.trn-doc.base-scale   no-undo.
define input parameter parr-b              as   character               no-undo.
define input parameter parcur-base         like ub.gds-dtl.cur-base     no-undo.
define input parameter parcur-road-tax     like ub.doc-line.road-tax    no-undo.
define input parameter parcur-excise       like ub.doc-line.excise      no-undo.
define input parameter parcur-vat-pc       like ub.doc-line.vat-pc      no-undo.
define input parameter parcurcons-vat-pc   like ub.doc-line.cons-vat-pc no-undo.
define input parameter parcurslt-pc        like ub.doc-line.slt-pc      no-undo.
define buffer bf_tt-allsum      for tt-allsum.
define buffer bf_tt-clcparts    for tt-clcparts.
define buffer bf_tt-allsum-line for tt-allsum-line.
define variable v-b-pcode          like ub.bar-code.b-code     no-undo.
define variable vardoc-num         like ub.price-doc.doc-num     no-undo.
define variable varprice-sale      like ub.price-list.price-sale no-undo.
define variable varroad-tax        like ub.price-list.road-tax   no-undo.
define variable varexcise          like ub.price-list.excise     no-undo.
do on error undo, return error return-value :
for each bf_tt-allsum-line
on error undo, return error return-value
 :
  delete bf_tt-allsum-line.
end.
for each bf_tt-allsum
on error undo, return error return-value
:
  delete bf_tt-allsum.
end.
for each bf_tt-clcparts
on error undo, return error return-value
:
if v-calcbypart then do:
          assign
          parcur-base =   bf_tt-clcparts.part-cur-base
          parcur-road-tax = bf_tt-clcparts.part-cur-road-tax
          parcur-excise =   bf_tt-clcparts.part-cur-excise
          .
end.
   run clcprtsl_calc-parts in this-procedure (
     input recid(bf_tt-clcparts),
     input paris-doc,
     input paris-cur,
     input parroad-tax,
     input parexcise,
     input parvat-pc,
     input parcons-vat-pc,
     input parslt-pc,
     input parbase-rate,
     input parbase-scale,
     input parr-b,
     input parcur-base,
     input parcur-road-tax,
     input parcur-excise,
     input parcur-vat-pc,
     input parcurcons-vat-pc,
     input parcurslt-pc
     ) no-error.
  if error-status:error then do:
    message
      vss-workfile vss-revision vss-description skip
      vss-include-info0 skip
      "Ошибка при обсчете партии" skip
      "Документ партии " bf_tt-clcparts.out-code skip
      "Товар" bf_tt-clcparts.artic bf_tt-clcparts.prod-type bf_tt-clcparts.prod-code skip
      return-value skip
      error-status:get-message(1) skip
      error-status:get-message(2) skip
      error-status:get-message(3) skip
      view-as alert-box error .
    undo, return error .
  end.
  for each bf_tt-allsum on error undo, return error return-value :
    find first bf_tt-allsum-line where bf_tt-allsum-line.sum-type = bf_tt-allsum.sum-type no-error.
    if not available bf_tt-allsum-line then do:
      create bf_tt-allsum-line.
      assign
        bf_tt-allsum-line.sum-type = bf_tt-allsum.sum-type.
    end.
    assign
      bf_tt-allsum-line.fact-qnty              = bf_tt-allsum-line.fact-qnty            + bf_tt-allsum.fact-qnty
      bf_tt-allsum-line.cli-qnty               = bf_tt-allsum-line.cli-qnty             + bf_tt-allsum.cli-qnty
      bf_tt-allsum-line.sum-dsc-base-doc       = bf_tt-allsum-line.sum-dsc-base-doc     + bf_tt-allsum.sum-dsc-base-doc
      bf_tt-allsum-line.sum-dsc-rubl-doc       = bf_tt-allsum-line.sum-dsc-rubl-doc     + bf_tt-allsum.sum-dsc-rubl-doc
      bf_tt-allsum-line.dsc-base-doc           = bf_tt-allsum-line.dsc-base-doc         + bf_tt-allsum.dsc-base-doc
      bf_tt-allsum-line.dsc-rubl-doc           = bf_tt-allsum-line.dsc-rubl-doc         + bf_tt-allsum.dsc-rubl-doc
      bf_tt-allsum-line.vat-base-doc           = bf_tt-allsum-line.vat-base-doc         + bf_tt-allsum.vat-base-doc
      bf_tt-allsum-line.vat-rubl-doc           = bf_tt-allsum-line.vat-rubl-doc         + bf_tt-allsum.vat-rubl-doc
      bf_tt-allsum-line.vat-base-buyer-doc     = bf_tt-allsum-line.vat-base-buyer-doc   + bf_tt-allsum.vat-base-buyer-doc
      bf_tt-allsum-line.vat-rubl-buyer-doc     = bf_tt-allsum-line.vat-rubl-buyer-doc   + bf_tt-allsum.vat-rubl-buyer-doc
      bf_tt-allsum-line.slt-base-doc           = bf_tt-allsum-line.slt-base-doc         + bf_tt-allsum.slt-base-doc
      bf_tt-allsum-line.slt-rubl-doc           = bf_tt-allsum-line.slt-rubl-doc         + bf_tt-allsum.slt-rubl-doc
      bf_tt-allsum-line.road-tax-base-doc      = bf_tt-allsum-line.road-tax-base-doc    + bf_tt-allsum.road-tax-base-doc
      bf_tt-allsum-line.road-tax-rubl-doc      = bf_tt-allsum-line.road-tax-rubl-doc    + bf_tt-allsum.road-tax-rubl-doc
      bf_tt-allsum-line.excise-base-doc        = bf_tt-allsum-line.excise-base-doc      + bf_tt-allsum.excise-base-doc
      bf_tt-allsum-line.excise-rubl-doc        = bf_tt-allsum-line.excise-rubl-doc      + bf_tt-allsum.excise-rubl-doc
      bf_tt-allsum-line.sum-dsc-base-cur       = bf_tt-allsum-line.sum-dsc-base-cur     + bf_tt-allsum.sum-dsc-base-cur
      bf_tt-allsum-line.sum-dsc-rubl-cur       = bf_tt-allsum-line.sum-dsc-rubl-cur     + bf_tt-allsum.sum-dsc-rubl-cur
      bf_tt-allsum-line.dsc-base-cur           = bf_tt-allsum-line.dsc-base-cur         + bf_tt-allsum.dsc-base-cur
      bf_tt-allsum-line.dsc-rubl-cur           = bf_tt-allsum-line.dsc-rubl-cur         + bf_tt-allsum.dsc-rubl-cur
      bf_tt-allsum-line.vat-base-cur           = bf_tt-allsum-line.vat-base-cur         + bf_tt-allsum.vat-base-cur
      bf_tt-allsum-line.vat-rubl-cur           = bf_tt-allsum-line.vat-rubl-cur         + bf_tt-allsum.vat-rubl-cur
      bf_tt-allsum-line.vat-base-buyer-cur     = bf_tt-allsum-line.vat-base-buyer-cur   + bf_tt-allsum.vat-base-buyer-cur
      bf_tt-allsum-line.vat-rubl-buyer-cur     = bf_tt-allsum-line.vat-rubl-buyer-cur   + bf_tt-allsum.vat-rubl-buyer-cur
      bf_tt-allsum-line.slt-base-cur           = bf_tt-allsum-line.slt-base-cur         + bf_tt-allsum.slt-base-cur
      bf_tt-allsum-line.slt-rubl-cur           = bf_tt-allsum-line.slt-rubl-cur         + bf_tt-allsum.slt-rubl-cur
      bf_tt-allsum-line.road-tax-base-cur      = bf_tt-allsum-line.road-tax-base-cur    + bf_tt-allsum.road-tax-base-cur
      bf_tt-allsum-line.road-tax-rubl-cur      = bf_tt-allsum-line.road-tax-rubl-cur    + bf_tt-allsum.road-tax-rubl-cur
      bf_tt-allsum-line.excise-base-cur        = bf_tt-allsum-line.excise-base-cur      + bf_tt-allsum.excise-base-cur
      bf_tt-allsum-line.excise-rubl-cur        = bf_tt-allsum-line.excise-rubl-cur      + bf_tt-allsum.excise-rubl-cur
      bf_tt-allsum-line.sum-dsc-base-acc       = bf_tt-allsum-line.sum-dsc-base-acc     + bf_tt-allsum.sum-dsc-base-acc
      bf_tt-allsum-line.sum-dsc-rubl-acc       = bf_tt-allsum-line.sum-dsc-rubl-acc     + bf_tt-allsum.sum-dsc-rubl-acc
      bf_tt-allsum-line.sum-dsc-cli-acc        = bf_tt-allsum-line.sum-dsc-cli-acc      + bf_tt-allsum.sum-dsc-cli-acc
      bf_tt-allsum-line.dsc-base-acc           = bf_tt-allsum-line.dsc-base-acc         + bf_tt-allsum.dsc-base-acc
      bf_tt-allsum-line.dsc-rubl-acc           = bf_tt-allsum-line.dsc-rubl-acc         + bf_tt-allsum.dsc-rubl-acc
      bf_tt-allsum-line.dsc-cli-acc            = bf_tt-allsum-line.dsc-cli-acc          + bf_tt-allsum.dsc-cli-acc
      bf_tt-allsum-line.vat-base-acc           = bf_tt-allsum-line.vat-base-acc         + bf_tt-allsum.vat-base-acc
      bf_tt-allsum-line.vat-rubl-acc           = bf_tt-allsum-line.vat-rubl-acc         + bf_tt-allsum.vat-rubl-acc
      bf_tt-allsum-line.vat-cli-acc            = bf_tt-allsum-line.vat-cli-acc          + bf_tt-allsum.vat-cli-acc
      bf_tt-allsum-line.slt-base-acc           = bf_tt-allsum-line.slt-base-acc         + bf_tt-allsum.slt-base-acc
      bf_tt-allsum-line.slt-rubl-acc           = bf_tt-allsum-line.slt-rubl-acc         + bf_tt-allsum.slt-rubl-acc
      bf_tt-allsum-line.slt-cli-acc            = bf_tt-allsum-line.slt-cli-acc          + bf_tt-allsum.slt-cli-acc
      bf_tt-allsum-line.road-tax-base-acc      = bf_tt-allsum-line.road-tax-base-acc    + bf_tt-allsum.road-tax-base-acc
      bf_tt-allsum-line.road-tax-rubl-acc      = bf_tt-allsum-line.road-tax-rubl-acc    + bf_tt-allsum.road-tax-rubl-acc
      bf_tt-allsum-line.road-tax-cli-acc       = bf_tt-allsum-line.road-tax-cli-acc     + bf_tt-allsum.road-tax-cli-acc
      bf_tt-allsum-line.excise-base-acc        = bf_tt-allsum-line.excise-base-acc      + bf_tt-allsum.excise-base-acc
      bf_tt-allsum-line.excise-rubl-acc        = bf_tt-allsum-line.excise-rubl-acc      + bf_tt-allsum.excise-rubl-acc
      bf_tt-allsum-line.excise-cli-acc         = bf_tt-allsum-line.excise-cli-acc       + bf_tt-allsum.excise-cli-acc
      bf_tt-allsum-line.transport-base-acc     = bf_tt-allsum-line.transport-base-acc   + bf_tt-allsum.transport-base-acc
      bf_tt-allsum-line.transport-rubl-acc     = bf_tt-allsum-line.transport-rubl-acc   + bf_tt-allsum.transport-rubl-acc
      bf_tt-allsum-line.transport-cli-acc      = bf_tt-allsum-line.transport-cli-acc    + bf_tt-allsum.transport-cli-acc
      bf_tt-allsum-line.other-base-acc         = bf_tt-allsum-line.other-base-acc       + bf_tt-allsum.other-base-acc
      bf_tt-allsum-line.other-rubl-acc         = bf_tt-allsum-line.other-rubl-acc       + bf_tt-allsum.other-rubl-acc
      bf_tt-allsum-line.other-cli-acc          = bf_tt-allsum-line.other-cli-acc        + bf_tt-allsum.other-cli-acc
      .
  end.
end.
end.
end procedure.
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table temp-parts no-undo   like ub.parts   field free-qnty as decimal   field free-cli-qnty as decimal .
procedure partslib-clear-temp-parts :
  define buffer buf_temp-parts for temp-parts .
  do
  on error undo, return error
  :
    for each buf_temp-parts
    on error undo, return error
    :
      delete buf_temp-parts .
    end.
  end.
end procedure.
procedure partslib-create-temp-parts :
  define parameter buffer buf_parts       for ub.parts .
  define parameter buffer buf_temp-parts  for temp-parts .
  define input  parameter p-goods-twounit as logical   no-undo .
  define variable v-base-part-code as character no-undo .
  do
  on error undo, return error
  :
    if p-goods-twounit = true
    then do:
      assign
        v-base-part-code = entry(1, buf_parts.part-code, '#':U)
      .
    end.
    else do:
      assign
        v-base-part-code = buf_parts.part-code
      .
    end.
    find first buf_temp-parts exclusive-lock
      where buf_temp-parts.obj-type  = buf_parts.obj-type
        and buf_temp-parts.obj-code  = buf_parts.obj-code
        and buf_temp-parts.artic     = buf_parts.artic
        and buf_temp-parts.prod-type = buf_parts.prod-type
        and buf_temp-parts.prod-code = buf_parts.prod-code
        and buf_temp-parts.in-code   = buf_parts.in-code
        and buf_temp-parts.out-code  = 'free-zone':U
        and buf_temp-parts.part-code = v-base-part-code
      no-error.
    if not available buf_temp-parts
    then do:
      create buf_temp-parts .
      buffer-copy buf_parts to buf_temp-parts
      assign
        buf_temp-parts.out-code  = 'free-zone':U
        buf_temp-parts.part-code = v-base-part-code
        buf_temp-parts.rsrv-free = yes
        buf_temp-parts.status_   = no
        buf_temp-parts.qnty      = 0
        buf_temp-parts.fact-qnty = 0
        buf_temp-parts.real-qnty = 0
        buf_temp-parts.cli-qnty  = 0
      .
    end.
  end.
end procedure.
procedure partslib-init-temp-parts :
  define input parameter p-obj-type        like ub.parts.obj-type  no-undo .
  define input parameter p-obj-code        like ub.parts.obj-code  no-undo .
  define input parameter p-artic           like ub.parts.artic     no-undo .
  define input parameter p-prod-type       like ub.parts.prod-type no-undo .
  define input parameter p-prod-code       like ub.parts.prod-code no-undo .
  define buffer buf_parts      for ub.parts .
  define buffer buf_temp-parts for temp-parts .
  define variable v-goods-twounit    as logical   no-undo .
  do
  on error undo, return error
  :
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsat in g#library
  (input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,input  'twounit=request':u
  ,output v-goods-twounit
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info14 skip
        "Ошибка при определении атрибута товара" skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "twounit=request" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    run partslib-clear-temp-parts in this-procedure .
    for each buf_parts
      where buf_parts.obj-type  = p-obj-type
        and buf_parts.obj-code  = p-obj-code
        and buf_parts.artic     = p-artic
        and buf_parts.prod-type = p-prod-type
        and buf_parts.prod-code = p-prod-code
        and buf_parts.rsrv-free = yes
        and buf_parts.status_   = no
        and buf_parts.in-code   <> buf_parts.out-code
    on error undo, return error
    :
      run partslib-create-temp-parts in this-procedure
        (buffer buf_parts
        ,buffer buf_temp-parts
        ,input  v-goods-twounit
        ) .
      define variable v-parts-qnty          as decimal   no-undo .
      define variable v-parts-cli-qnty      as decimal   no-undo .
      define variable v-parts-free-qnty     as decimal   no-undo .
      define variable v-parts-free-cli-qnty as decimal   no-undo .
      if buf_parts.out-code = 'free-zone':U
      then do:
        assign
          v-parts-qnty          = buf_parts.qnty
          v-parts-cli-qnty      = buf_parts.cli-qnty
          v-parts-free-qnty     = buf_parts.qnty
          v-parts-free-cli-qnty = buf_parts.cli-qnty
        .
      end.
      else do:
        assign
          v-parts-qnty          = abs(buf_parts.qnty)
          v-parts-cli-qnty      = abs(buf_parts.cli-qnty)
          v-parts-free-qnty     = 0
          v-parts-free-cli-qnty = 0
        .
      end.
      assign
        buf_temp-parts.qnty          = buf_temp-parts.qnty          + v-parts-qnty
        buf_temp-parts.fact-qnty     = buf_temp-parts.fact-qnty     + v-parts-qnty
        buf_temp-parts.real-qnty     = 0
        buf_temp-parts.cli-qnty      = buf_temp-parts.cli-qnty      + v-parts-cli-qnty
        buf_temp-parts.free-qnty     = buf_temp-parts.free-qnty     + v-parts-free-qnty
        buf_temp-parts.free-cli-qnty = buf_temp-parts.free-cli-qnty + v-parts-free-cli-qnty
      .
    end.
  end.
end procedure.
procedure partslib-init-temp-parts-by-factord :
  define input parameter p-obj-type           like ub.parts.obj-type  no-undo .
  define input parameter p-obj-code           like ub.parts.obj-code  no-undo .
  define input parameter p-artic              like ub.parts.artic     no-undo .
  define input parameter p-prod-type          like ub.parts.prod-type no-undo .
  define input parameter p-prod-code          like ub.parts.prod-code no-undo .
  define input parameter p-fact-order         as decimal   no-undo .
  define input parameter p-include-fact-order as logical   no-undo .
  define variable vss-description as character no-undo init "partslib-init-temp-parts-by-factord: определение партий свободной зоны на любую дату".
  define buffer buf_gds-obj  for ub.gds-obj .
  do
  on error undo, return error
  :
    do transaction
    on error undo, return error
    :
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjcr in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,buffer buf_gds-obj
  ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          vss-include-info14 skip
          "Невозможно найти товар на объекте" skip
          "Объект" p-obj-type p-obj-code skip
          "Артикул" p-artic p-prod-type p-prod-code skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error .
      end.
      find current buf_gds-obj exclusive-lock .
    end.
    run partslib-init-temp-parts in this-procedure
      (input p-obj-type
      ,input p-obj-code
      ,input p-artic
      ,input p-prod-type
      ,input p-prod-code
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info14 skip
        "Ошибка при инициализации текущего остатка по партиям свободной зоны" skip
        "Объект" p-obj-type p-obj-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "p-fact-order" p-fact-order skip
        view-as alert-box error .
      undo, return error .
    end.
    if p-include-fact-order = true
    then do:
      assign
        p-fact-order = p-fact-order - 0.0000000001
      .
    end.
    define variable v-max-fact-order as character no-undo .
    run factord-max-fact-order in this-procedure
      (output v-max-fact-order
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info14 skip
        "Ошибка при вызове процедуры factord-max-fact-order" skip
        "Объект" p-obj-type p-obj-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "p-fact-order" p-fact-order skip
        view-as alert-box error .
      undo, return error .
    end.
    run partslib-update-by-factord in this-procedure
      (input p-obj-type
      ,input p-obj-code
      ,input p-artic
      ,input p-prod-type
      ,input p-prod-code
      ,input p-fact-order
      ,input v-max-fact-order
      ,input false
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info14 skip
        "Ошибка при вызове процедуры partslib-update-by-factord" skip
        "Объект" p-obj-type p-obj-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "p-fact-order" p-fact-order skip
        "v-max-fact-order" v-max-fact-order skip
        view-as alert-box error .
      undo, return error .
    end.
  end.
end procedure.
procedure partslib-update-by-factord :
  define input parameter p-obj-type           like ub.parts.obj-type  no-undo .
  define input parameter p-obj-code           like ub.parts.obj-code  no-undo .
  define input parameter p-artic              like ub.parts.artic     no-undo .
  define input parameter p-prod-type          like ub.parts.prod-type no-undo .
  define input parameter p-prod-code          like ub.parts.prod-code no-undo .
  define input parameter p-start-fact-order   as decimal   no-undo .
  define input parameter p-end-fact-order     as decimal   no-undo .
  define input parameter p-lock-gds-obj       as logical   no-undo .
  define variable vss-description as character no-undo init "partslib-init-temp-parts-by-factord: определение партий свободной зоны на любую дату".
  define buffer buf_gds-obj  for ub.gds-obj .
  define buffer buf_doc-line for ub.doc-line .
  define variable v-total-parts-qnty as decimal   no-undo .
  define variable v-goods-gds-goods  as logical   no-undo .
  define variable v-goods-twounit    as logical   no-undo .
  do
  on error undo, return error
  :
    if p-start-fact-order > p-end-fact-order
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info14 skip
        "Ошибка задания входных параметров" skip
        "Начало интервала превышает конец интервала" skip
        "Объект" p-obj-type p-obj-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "p-start-fact-order" p-start-fact-order skip
        "p-end-fact-order"   p-end-fact-order skip
        view-as alert-box error .
      undo, return error .
    end.
    if p-lock-gds-obj = true
    then do:
      do transaction
      on error undo, return error
      :
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjcr in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,buffer buf_gds-obj
  ) no-error .
        if error-status :error
        then do:
          message
            vss-workfile vss-revision vss-description skip
            vss-include-info14 skip
            "Невозможно найти gds-obj" skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo, return error .
        end.
        find current buf_gds-obj exclusive-lock .
      end.
    end.
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsat in g#library
  (input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,input  'gds-goods=request':u
  ,output v-goods-gds-goods
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info14 skip
        "Ошибка при определении атрибута товара" skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "gds-goods=request" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsat in g#library
  (input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,input  'twounit=request':u
  ,output v-goods-twounit
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info14 skip
        "Ошибка при определении атрибута товара" skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "twounit=request" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    for each buf_doc-line no-lock
      where buf_doc-line.obj-type   = p-obj-type
        and buf_doc-line.obj-code   = p-obj-code
        and buf_doc-line.artic      = p-artic
        and buf_doc-line.prod-type  = p-prod-type
        and buf_doc-line.prod-code  = p-prod-code
        and buf_doc-line.status_    = 'факт':U
        and buf_doc-line.fact-order > p-start-fact-order
        and buf_doc-line.fact-order <= p-end-fact-order
    on error undo, return error
    :
      run partslib-process-document in this-procedure
        (input  buf_doc-line.doc-code
        ,input  p-obj-type
        ,input  p-obj-code
        ,input  p-artic
        ,input  p-prod-type
        ,input  p-prod-code
        ,input  v-goods-gds-goods
        ,input  v-goods-twounit
        ,output v-total-parts-qnty
        ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          vss-include-info14 skip
          "Ошибка при вызове процедуры partslib-process-document" skip
          "Документ" buf_doc-line.doc-code skip
          "Объект" p-obj-type p-obj-code skip
          "Артикул" p-artic p-prod-type p-prod-code skip
          "p-start-fact-order" p-start-fact-order skip
          "p-end-fact-order" p-end-fact-order skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end.
  end.
end procedure.
procedure partslib-process-document :
  define input  parameter p-doc-code         as character no-undo .
  define input  parameter p-obj-type         as character no-undo .
  define input  parameter p-obj-code         as integer   no-undo .
  define input  parameter p-artic            as character no-undo .
  define input  parameter p-prod-type        as character no-undo .
  define input  parameter p-prod-code        as integer   no-undo .
  define input  parameter p-goods-gds-goods  as logical   no-undo .
  define input  parameter p-goods-twounit    as logical   no-undo .
  define output parameter p-total-parts-qnty as decimal   no-undo .
  define variable v-parts-sign as integer   no-undo .
  define buffer buf_trn-doc    for ub.trn-doc .
  define buffer buf_doc-line   for ub.doc-line .
  define buffer buf_parts      for ub.parts .
  define buffer buf_temp-parts for temp-parts .
  do
  on error undo, return error return-value
  :
    find first buf_trn-doc no-lock
      where buf_trn-doc.doc-code = p-doc-code
      no-error .
    if not available buf_trn-doc
    then do:
      undo, return error substitute("Ошибка при поиске документа. Документ &1"
                                   ,p-doc-code
                                   ) .
    end.
    case buf_trn-doc.doc-type
    :
      when 'при':U or
      when 'возврат':U or
      when 'инв':U
      then do:
        assign
          v-parts-sign = -1
        .
      end.
      when 'рас':U or
      when 'спи':U
      then do:
        assign
          v-parts-sign = 1
        .
      end.
      otherwise do:
        undo, return error substitute("Неизвестный тип документа &1"
                                    ,buf_trn-doc.doc-type
                                    ) .
      end.
    end.
    find first buf_doc-line no-lock
      where buf_doc-line.doc-code  = p-doc-code
        and buf_doc-line.artic     = p-artic
        and buf_doc-line.prod-type = p-prod-type
        and buf_doc-line.prod-code = p-prod-code
      no-error .
    if not available buf_doc-line
    then do:
      undo, return error substitute("Ошибка при поиске строки документа. Документ &1. Артикул &2 &3 &4"
                                   ,p-doc-code
                                   ,artic
                                   ,prod-type
                                   ,prod-code
                                   ) .
    end.
    assign
      p-total-parts-qnty = 0
    .
    if p-goods-gds-goods = true
    then do:
      for each buf_parts no-lock
        where buf_parts.out-code  = p-doc-code
          and buf_parts.obj-type  = p-obj-type
          and buf_parts.obj-code  = p-obj-code
          and buf_parts.artic     = p-artic
          and buf_parts.prod-type = p-prod-type
          and buf_parts.prod-code = p-prod-code
      on error undo, return error
      :
        run partslib-create-temp-parts in this-procedure
          (buffer buf_parts
          ,buffer buf_temp-parts
          ,input  p-goods-twounit
          ) .
        assign
          p-total-parts-qnty        = p-total-parts-qnty
                                    + v-parts-sign * buf_parts.fact-qnty
          buf_temp-parts.qnty       = buf_temp-parts.qnty
                                    + v-parts-sign * buf_parts.fact-qnty
          buf_temp-parts.fact-qnty  = buf_temp-parts.fact-qnty
                                    + v-parts-sign * buf_parts.fact-qnty
          buf_temp-parts.cli-qnty   = buf_temp-parts.cli-qnty
                                    + v-parts-sign * buf_parts.cli-qnty
        .
        if buf_temp-parts.qnty = 0
        then do:
          delete buf_temp-parts .
        end.
      end.
    end.
    else do:
      assign
        p-total-parts-qnty = p-total-parts-qnty
                           + v-parts-sign * buf_doc-line.fact-qnty
      .
    end.
  end.
end procedure.
procedure partslib-init-temp-parts-by-date :
  define input parameter p-obj-type        like ub.parts.obj-type  no-undo .
  define input parameter p-obj-code        like ub.parts.obj-code  no-undo .
  define input parameter p-artic           like ub.parts.artic     no-undo .
  define input parameter p-prod-type       like ub.parts.prod-type no-undo .
  define input parameter p-prod-code       like ub.parts.prod-code no-undo .
  define input parameter p-fact-date       as date      no-undo .
  define variable vss-description as character no-undo init "partslib-init-temp-parts-by-date: определение партий свободной зоны на любую дату".
  do
  on error undo, return error
  :
    define variable v-fact-order                as decimal   no-undo .
    define variable v-shift-end-fact-order      as decimal   no-undo .
    define variable v-day-end-fact-order        as decimal   no-undo .
    run factord in this-procedure
      (input  p-fact-date
      ,input  1
      ,input  1
      ,input  ?
      ,input  0
      ,input  false
      ,output v-fact-order
      ,output v-shift-end-fact-order
      ,output v-day-end-fact-order
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info14 skip
        "Ошибка при определении момента времени, на который требуется остаток" skip
        "Объект" p-obj-type p-obj-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "Дата" p-fact-date skip
        view-as alert-box error .
      undo, return error .
    end.
    run partslib-init-temp-parts-by-factord in this-procedure
      (input p-obj-type
      ,input p-obj-code
      ,input p-artic
      ,input p-prod-type
      ,input p-prod-code
      ,input v-day-end-fact-order
      ,input false
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info14 skip
        "Ошибка при вызове метода partslib-init-temp-parts-by-factord" skip
        "Объект" p-obj-type p-obj-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "Дата" p-fact-date skip
        view-as alert-box error .
      undo, return error .
    end.
  end.
end procedure.
procedure partslib-calc-cost :
  define output parameter p-fact-qnty      as decimal   no-undo .
  define output parameter p-vat-pc         as decimal   no-undo .
  define output parameter p-slt-pc         as decimal   no-undo .
  define output parameter p-sum-base       as decimal   no-undo .
  define output parameter p-sum-rubl       as decimal   no-undo .
  define output parameter p-vat-base       as decimal   no-undo .
  define output parameter p-vat-rubl       as decimal   no-undo .
  define output parameter p-slt-base       as decimal   no-undo .
  define output parameter p-slt-rubl       as decimal   no-undo .
  define output parameter p-road-tax-base  as decimal   no-undo .
  define output parameter p-road-tax-rubl  as decimal   no-undo .
  define output parameter p-transport-base as decimal   no-undo .
  define output parameter p-transport-rubl as decimal   no-undo .
  define output parameter p-other-base     as decimal   no-undo .
  define output parameter p-other-rubl     as decimal   no-undo .
  define output parameter p-excise-base    as decimal   no-undo .
  define output parameter p-excise-rubl    as decimal   no-undo .
  define variable vss-description as character no-undo init "partslib-calc-cost: расчет сумм в учетных ценах".
  do
  on error undo, return error return-value
  :
    define buffer buf_temp-parts for temp-parts .
    define buffer   in-vatp-trn-doc  for ub.trn-doc .
    define buffer   in-vatp-parts    for ub.parts   .
    define buffer   in-vatp-doc      for ub.trn-doc .
    define buffer   in-vatp-goods    for ub.goods   .
    define buffer   in-vatp-sysconf  for ub.sysconf .
    define buffer   in-vatp_doc-attr for ub.doc-attr.
    define variable in-vatp-have-vat-slt       as   logical initial yes    no-undo.
    define variable vat-pc-loc                 like ub.doc-line.vat-pc     no-undo.
    define variable varinvprb                  as   character              no-undo.
    define variable slt-pc-loc                 like ub.doc-line.slt-pc     no-undo.
    define variable cli-base-rate              as   decimal                no-undo.
    define variable price-rubl-with-tax-loc    like ub.doc-line.price-rubl no-undo.
    define variable price-base-with-tax-loc    like ub.doc-line.price-base no-undo.
    define variable price-cli-with-tax-loc     like ub.doc-line.price-cli  no-undo.
    define variable price-rubl-without-tax-loc like ub.doc-line.price-rubl no-undo.
    define variable price-base-without-tax-loc like ub.doc-line.price-base no-undo.
    define variable price-cli-without-tax-loc  like ub.doc-line.price-base no-undo.
    define variable vat-base-loc               like ub.doc-line.price-base no-undo.
    define variable vat-rubl-loc               like ub.doc-line.price-rubl no-undo.
    define variable vat-cli-loc                like ub.doc-line.price-rubl no-undo.
    define variable slt-base-loc               like ub.doc-line.price-base no-undo.
    define variable slt-rubl-loc               like ub.doc-line.price-rubl no-undo.
    define variable slt-cli-loc                like ub.doc-line.price-rubl no-undo.
    define variable road-tax-base-loc          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-rubl-loc          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-cli-loc           like ub.doc-line.road-tax   no-undo.
    define variable transport-base-loc         like ub.doc-line.price-base no-undo.
    define variable transport-rubl-loc         like ub.doc-line.price-rubl no-undo.
    define variable transport-cli-loc          like ub.doc-line.price-rubl no-undo.
    define variable other-base-loc             like ub.doc-line.price-base no-undo.
    define variable other-rubl-loc             like ub.doc-line.price-rubl no-undo.
    define variable other-cli-loc              like ub.doc-line.price-rubl no-undo.
    define variable exch-rate-cli-loc          like ub.trn-doc.exch-rate   no-undo.
    define variable varinvatp-envd             as   character              no-undo.
    define variable varinvatp-type             as   character              no-undo.
    for each buf_temp-parts
    on error undo, return error
    :
assign
  price-rubl-with-tax-loc = buf_temp-parts.price-rubl
  price-base-with-tax-loc = buf_temp-parts.price-base
.
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprb
  )  .
  if buf_temp-parts.out-code = 'free-zone':U     or
     buf_temp-parts.out-code = 'out-zone':U   or
     buf_temp-parts.doc-type = 'акт':U then do:
    assign
      in-vatp-have-vat-slt = yes.
  end.
  else do:
    find first in-vatp_doc-attr no-lock
      where in-vatp_doc-attr.doc-code  = buf_temp-parts.out-code
        and in-vatp_doc-attr.attr-code = 'envd':U
      no-error .
    if not available in-vatp_doc-attr then do:
      assign
        in-vatp-have-vat-slt = yes.
    end.
    else do:
         in-vatp-have-vat-slt = no.
    end.
  end.
  assign
   price-cli-with-tax-loc = buf_temp-parts.price-cli
   cli-base-rate          = buf_temp-parts.cli-base-rate.
  ASSIGN   road-tax-base-loc  = (if buf_temp-parts.road-tax-base  = ? then 0 else buf_temp-parts.road-tax-base)
           road-tax-rubl-loc  = (if buf_temp-parts.road-tax-rubl  = ? then 0 else buf_temp-parts.road-tax-rubl).
  ASSIGN  transport-base-loc = (if buf_temp-parts.transport-base = ? then 0 else buf_temp-parts.transport-base)
          transport-rubl-loc = (if buf_temp-parts.transport-rubl = ? then 0 else buf_temp-parts.transport-rubl)
          other-base-loc     = (if buf_temp-parts.other-base     = ? then 0 else buf_temp-parts.other-base)
          other-rubl-loc     = (if buf_temp-parts.other-rubl     = ? then 0 else buf_temp-parts.other-rubl)
          vat-pc-loc         = (if buf_temp-parts.vat-pc         = ? then 0 else buf_temp-parts.vat-pc)
          slt-pc-loc         = (if buf_temp-parts.slt-pc         = ? then 0 else buf_temp-parts.slt-pc).
          ASSIGN   slt-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
    ASSIGN   slt-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
  assign
    exch-rate-cli-loc = (buf_temp-parts.price-rubl - transport-rubl-loc - other-rubl-loc - road-tax-rubl-loc - (if buf_temp-parts.vat-type <> 'в т. ч.':U then vat-rubl-loc else 0) - (if buf_temp-parts.slt-type <> 'в т. ч.':U then slt-rubl-loc else 0)) / buf_temp-parts.price-cli .
  assign
    slt-cli-loc        = slt-rubl-loc       / exch-rate-cli-loc
    vat-cli-loc        = vat-rubl-loc       / exch-rate-cli-loc
    road-tax-cli-loc   = road-tax-rubl-loc  / exch-rate-cli-loc
    transport-cli-loc  = 0
    other-cli-loc      = 0
  .
ASSIGN
          price-base-without-tax-loc = price-base-with-tax-loc - vat-base-loc - slt-base-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))
    price-rubl-without-tax-loc = price-rubl-with-tax-loc - vat-rubl-loc - slt-rubl-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))
.
      assign
        p-fact-qnty      = p-fact-qnty      + buf_temp-parts.fact-qnty
        p-vat-pc         = p-vat-pc         + vat-pc-loc
        p-slt-pc         = p-slt-pc         + slt-pc-loc
        p-sum-base       = p-sum-base       + price-base-with-tax-loc * buf_temp-parts.fact-qnty
        p-sum-rubl       = p-sum-rubl       + price-rubl-with-tax-loc * buf_temp-parts.fact-qnty
        p-vat-base       = p-vat-base       + vat-base-loc            * buf_temp-parts.fact-qnty
        p-vat-rubl       = p-vat-rubl       + vat-rubl-loc            * buf_temp-parts.fact-qnty
        p-slt-base       = p-slt-base       + slt-base-loc            * buf_temp-parts.fact-qnty
        p-slt-rubl       = p-slt-rubl       + slt-rubl-loc            * buf_temp-parts.fact-qnty
        p-road-tax-base  = p-road-tax-base  + road-tax-base-loc       * buf_temp-parts.fact-qnty
        p-road-tax-rubl  = p-road-tax-rubl  + road-tax-rubl-loc       * buf_temp-parts.fact-qnty
        p-transport-base = p-transport-base + transport-base-loc      * buf_temp-parts.fact-qnty
        p-transport-rubl = p-transport-rubl + transport-rubl-loc      * buf_temp-parts.fact-qnty
        p-other-base     = p-other-base     + other-base-loc          * buf_temp-parts.fact-qnty
        p-other-rubl     = p-other-rubl     + other-rubl-loc          * buf_temp-parts.fact-qnty
        p-excise-base    = p-excise-base    + 0
        p-excise-rubl    = p-excise-rubl    + 0
      .
    end.
    if p-fact-qnty      = ?
    or p-sum-base       = ?
    or p-sum-rubl       = ?
    or p-vat-base       = ?
    or p-vat-rubl       = ?
    or p-slt-base       = ?
    or p-slt-rubl       = ?
    or p-road-tax-base  = ?
    or p-road-tax-rubl  = ?
    or p-transport-base = ?
    or p-transport-rubl = ?
    or p-other-base     = ?
    or p-other-rubl     = ?
    or p-excise-base    = ?
    or p-excise-rubl    = ?
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info14 skip
        "Программа in-vatp.i вернула неопределенные значения" skip
        "p-fact-qnty"      p-fact-qnty      skip
        "p-sum-base"       p-sum-base       skip
        "p-sum-rubl"       p-sum-rubl       skip
        "p-vat-base"       p-vat-base       skip
        "p-vat-rubl"       p-vat-rubl       skip
        "p-slt-base"       p-slt-base       skip
        "p-slt-rubl"       p-slt-rubl       skip
        "p-road-tax-base"  p-road-tax-base  skip
        "p-road-tax-rubl"  p-road-tax-rubl  skip
        "p-transport-base" p-transport-base skip
        "p-transport-rubl" p-transport-rubl skip
        "p-other-base"     p-other-base     skip
        "p-other-rubl"     p-other-rubl     skip
        "p-excise-base"    p-excise-base    skip
        "p-excise-rubl"    p-excise-rubl    skip
        view-as alert-box error .
      undo, return error .
    end.
  end.
end procedure.
def var vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure tax-name:
define input  parameter pardef-tax  as character           no-undo.
define output parameter parname-tax as character initial ? no-undo.
define buffer bf_tax for ub.tax.
do on error undo, return error :
   case pardef-tax:
      when 'vat':U then do:
                  find first bf_tax where bf_tax.tax-code = integer('1':U) no-lock no-error.                     if available bf_tax then do:                                                                              assign parname-tax = bf_tax.tax-name.                                                               end.                                                                                                   else assign parname-tax = "Налог '1':U(не задействован)".
      end.
      when 'slt':U then do:
                  find first bf_tax where bf_tax.tax-code = integer('2':U) no-lock no-error.                     if available bf_tax then do:                                                                              assign parname-tax = bf_tax.tax-name.                                                               end.                                                                                                   else assign parname-tax = "Налог '2':U(не задействован)".
      end.
      when 'rdt':U then do:
                  find first bf_tax where bf_tax.tax-code = integer('3':U) no-lock no-error.                     if available bf_tax then do:                                                                              assign parname-tax = bf_tax.tax-name.                                                               end.                                                                                                   else assign parname-tax = "Налог '3':U(не задействован)".
      end.
      when 'exc':U then do:
                  find first bf_tax where bf_tax.tax-code = integer('4':U) no-lock no-error.                     if available bf_tax then do:                                                                              assign parname-tax = bf_tax.tax-name.                                                               end.                                                                                                   else assign parname-tax = "Налог '4':U(не задействован)".
      end.
      otherwise do:
         return error "Задан неверный параметр " + pardef-tax + " .".
      end.
   end case.
end.
end procedure.
define buffer bf_goods           for ub.goods.
define buffer bf-cur-obj_clients for ub.clients.
define buffer bf-supp_clients    for ub.clients.
define buffer bf_gds-obj         for ub.gds-obj.
define buffer bf_parts-attr      for ub.parts-attr.
define buffer bf_parts           for ub.parts.
define buffer bf_tt-allsum-line  for tt-allsum-line.
define buffer bf_clients         for ub.clients.
define buffer bf-host_clients    for ub.clients.
define buffer bf-sysconf         for ub.sysconf.
define variable varrate-correct      as logical no-undo.
define variable varrate-exch-correct as logical no-undo.
DEFINE BUFFER tt-chs-parts-another FOR tt-chs-parts.
    define buffer   in-vatp-trn-doc  for ub.trn-doc .
    define buffer   in-vatp-parts    for ub.parts   .
    define buffer   in-vatp-doc      for ub.trn-doc .
    define buffer   in-vatp-goods    for ub.goods   .
    define buffer   in-vatp-sysconf  for ub.sysconf .
    define buffer   in-vatp_doc-attr for ub.doc-attr.
    define variable in-vatp-have-vat-slt       as   logical initial yes    no-undo.
    define variable vat-pc-loc                 like ub.doc-line.vat-pc     no-undo.
    define variable varinvprb                  as   character              no-undo.
    define variable slt-pc-loc                 like ub.doc-line.slt-pc     no-undo.
    define variable cli-base-rate              as   decimal                no-undo.
    define variable price-rubl-with-tax-loc    like ub.doc-line.price-rubl no-undo.
    define variable price-base-with-tax-loc    like ub.doc-line.price-base no-undo.
    define variable price-cli-with-tax-loc     like ub.doc-line.price-cli  no-undo.
    define variable price-rubl-without-tax-loc like ub.doc-line.price-rubl no-undo.
    define variable price-base-without-tax-loc like ub.doc-line.price-base no-undo.
    define variable price-cli-without-tax-loc  like ub.doc-line.price-base no-undo.
    define variable vat-base-loc               like ub.doc-line.price-base no-undo.
    define variable vat-rubl-loc               like ub.doc-line.price-rubl no-undo.
    define variable vat-cli-loc                like ub.doc-line.price-rubl no-undo.
    define variable slt-base-loc               like ub.doc-line.price-base no-undo.
    define variable slt-rubl-loc               like ub.doc-line.price-rubl no-undo.
    define variable slt-cli-loc                like ub.doc-line.price-rubl no-undo.
    define variable road-tax-base-loc          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-rubl-loc          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-cli-loc           like ub.doc-line.road-tax   no-undo.
    define variable transport-base-loc         like ub.doc-line.price-base no-undo.
    define variable transport-rubl-loc         like ub.doc-line.price-rubl no-undo.
    define variable transport-cli-loc          like ub.doc-line.price-rubl no-undo.
    define variable other-base-loc             like ub.doc-line.price-base no-undo.
    define variable other-rubl-loc             like ub.doc-line.price-rubl no-undo.
    define variable other-cli-loc              like ub.doc-line.price-rubl no-undo.
    define variable exch-rate-cli-loc          like ub.trn-doc.exch-rate   no-undo.
    define variable varinvatp-envd             as   character              no-undo.
    define variable varinvatp-type             as   character              no-undo.
define variable varroad-tax-base  like ub.doc-line.road-tax  no-undo.
define variable varroad-tax-rubl  like ub.doc-line.road-tax  no-undo.
define variable varroad-tax-cli   like ub.doc-line.road-tax  no-undo.
define variable vartransport-base like ub.doc-line.road-tax  no-undo.
define variable vartransport-rubl like ub.doc-line.road-tax  no-undo.
define variable vartransport-cli  like ub.doc-line.road-tax  no-undo.
define variable varother-base     like ub.doc-line.road-tax  no-undo.
define variable varother-rubl     like ub.doc-line.road-tax  no-undo.
define variable varother-cli      like ub.doc-line.road-tax  no-undo.
define variable varbaseeqrubl     as   logical               no-undo.
define variable varexcheqrubl     as   logical               no-undo.
define variable varexcheqbase     as   logical               no-undo.
define variable varhost-code      like ub.clients.obj-code   no-undo.
define variable varbase-code      like ub.currency.curr-code no-undo.
define variable varexch-code      like ub.currency.curr-code no-undo.
define variable vartemp-rate      like ub.trn-doc.exch-rate  no-undo.
define variable vartemp-scale     like ub.trn-doc.exch-scale no-undo.
define variable varno-change      as   character initial "не изменять":u no-undo.
define variable varout-code       like ub.trn-doc.doc-code   no-undo.
define variable vardoc-type       like ub.parts.doc-type     no-undo.
assign
  varout-code = parout-code
  vardoc-type = 'акт':U.
DEFINE BUTTON b-calc-base-t-rubl
     LABEL ">"
     SIZE 5 BY .75.
DEFINE BUTTON b-calc-cli-t-rubl
     LABEL "<"
     SIZE 5 BY .75.
DEFINE BUTTON b-calc-exch-rate
     LABEL "Расчет"
     SIZE 6.5 BY 1.
DEFINE BUTTON b-calc-rate
     LABEL "Расчет"
     SIZE 6.5 BY 1.
DEFINE BUTTON b-calc-rubl-t-base
     LABEL "<"
     SIZE 5 BY .75.
DEFINE BUTTON b-calc-rubl-t-cli
     LABEL ">"
     SIZE 5 BY .75.
DEFINE BUTTON b-cancel
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-cur-exch-rate
     LABEL "Уст"
     SIZE 3.5 BY 1.
DEFINE BUTTON b-cur-rate
     LABEL "Уст"
     SIZE 3.5 BY 1.
DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-save AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE VARIABLE varpurch-code-name AS CHARACTER FORMAT "X(256)":U
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEMS "Item 1"
     DROP-DOWN-LIST
     SIZE 31 BY 1 NO-UNDO.
DEFINE VARIABLE v-rubli-firstshift AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 6 BY .67
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE varartic AS CHARACTER FORMAT "X(16)":U
     LABEL "Товар"
     VIEW-AS FILL-IN
     SIZE 17 BY 1 NO-UNDO.
DEFINE VARIABLE varbase-rate AS DECIMAL FORMAT ">>,>>9.9999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 8.25 BY 1 NO-UNDO.
DEFINE VARIABLE varbase-scale AS INTEGER FORMAT ">>>9":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 4.38 BY 1 NO-UNDO.
DEFINE VARIABLE varcli-base-rate AS DECIMAL FORMAT ">>,>>9.9999":U INITIAL 0
     LABEL "Единица поставщика"
     VIEW-AS FILL-IN
     SIZE 10 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE varcur-base-name AS CHARACTER FORMAT "X(3)":U
     VIEW-AS FILL-IN
     SIZE 4 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE varcur-base-rate AS DECIMAL FORMAT ">>,>>9.9999":U INITIAL 0
     LABEL "Тек"
     VIEW-AS FILL-IN
     SIZE 8.25 BY 1 NO-UNDO.
DEFINE VARIABLE varcur-base-scale AS INTEGER FORMAT ">>>9":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 5 BY 1 NO-UNDO.
DEFINE VARIABLE varcur-cli-name AS CHARACTER FORMAT "X(3)":U
     VIEW-AS FILL-IN
     SIZE 4 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE varcur-exch-rate AS DECIMAL FORMAT ">>,>>9.9999":U INITIAL 0
     LABEL "Тек"
     VIEW-AS FILL-IN
     SIZE 8.25 BY 1 NO-UNDO.
DEFINE VARIABLE varcur-exch-scale AS INTEGER FORMAT ">>>9":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 5 BY 1 NO-UNDO.
DEFINE VARIABLE varexch-rate AS DECIMAL FORMAT ">>,>>9.9999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 8.25 BY 1 NO-UNDO.
DEFINE VARIABLE varexch-scale AS INTEGER FORMAT ">>>9":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 4.38 BY 1 NO-UNDO.
DEFINE VARIABLE varfact-qnty AS DECIMAL FORMAT "->>,>>>,>>9.999":U INITIAL 0
     LABEL "Факт"
     VIEW-AS FILL-IN
     SIZE 23.5 BY 1 NO-UNDO.
DEFINE VARIABLE vargds-name AS CHARACTER FORMAT "X(48)":U
     VIEW-AS FILL-IN
     SIZE 25 BY 1 NO-UNDO.
DEFINE VARIABLE varin-code AS CHARACTER FORMAT "X(14)":U
     LABEL "ПН"
     VIEW-AS FILL-IN
     SIZE 15 BY 1 NO-UNDO.
DEFINE VARIABLE varincome-in-code AS CHARACTER FORMAT "X(14)":U
     LABEL "ВнПН"
     VIEW-AS FILL-IN
     SIZE 15 BY 1 NO-UNDO.
DEFINE VARIABLE varobj-code AS INTEGER FORMAT ">>>>>>>>9":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 6 BY 1 NO-UNDO.
DEFINE VARIABLE varobj-name AS CHARACTER FORMAT "X(40)":U
     VIEW-AS FILL-IN
     SIZE 13 BY 1 NO-UNDO.
DEFINE VARIABLE varobj-type AS CHARACTER FORMAT "X(3)":U
     VIEW-AS FILL-IN
     SIZE 4 BY 1 NO-UNDO.
DEFINE VARIABLE varold-base-rate AS DECIMAL FORMAT ">>,>>9.9999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 12.38 BY 1 NO-UNDO.
DEFINE VARIABLE varold-exch-rate AS DECIMAL FORMAT ">>,>>9.9999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 12.38 BY 1 NO-UNDO.
DEFINE VARIABLE varold-price-base AS DECIMAL FORMAT "->,>>>,>>9.9999999999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 15.5 BY 1 NO-UNDO.
DEFINE VARIABLE varold-price-base-other AS DECIMAL FORMAT "->,>>>,>>9.9999999999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 15.5 BY 1 NO-UNDO.
DEFINE VARIABLE varold-price-base-road-tax AS DECIMAL FORMAT "->,>>>,>>9.9999999999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 15.5 BY 1 NO-UNDO.
DEFINE VARIABLE varold-price-base-slt AS DECIMAL FORMAT "->,>>>,>>9.9999999999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 15.5 BY 1 NO-UNDO.
DEFINE VARIABLE varold-price-base-transport AS DECIMAL FORMAT "->,>>>,>>9.9999999999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 15.5 BY 1 NO-UNDO.
DEFINE VARIABLE varold-price-base-vat AS DECIMAL FORMAT "->,>>>,>>9.9999999999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 15.5 BY 1 NO-UNDO.
DEFINE VARIABLE varold-price-cli AS DECIMAL FORMAT "->,>>>,>>9.9999999999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 15.5 BY 1 NO-UNDO.
DEFINE VARIABLE varold-price-cli-road-tax AS DECIMAL FORMAT "->,>>>,>>9.9999999999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 15.5 BY 1 NO-UNDO.
DEFINE VARIABLE varold-price-cli-slt AS DECIMAL FORMAT "->,>>>,>>9.9999999999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 15.5 BY 1 NO-UNDO.
DEFINE VARIABLE varold-price-cli-vat AS DECIMAL FORMAT "->,>>>,>>9.9999999999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 15.5 BY 1 NO-UNDO.
DEFINE VARIABLE varold-price-rubl AS DECIMAL FORMAT "->,>>>,>>9.9999999999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 15.5 BY 1 NO-UNDO.
DEFINE VARIABLE varold-price-rubl-other AS DECIMAL FORMAT "->,>>>,>>9.9999999999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 15.5 BY 1 NO-UNDO.
DEFINE VARIABLE varold-price-rubl-road-tax AS DECIMAL FORMAT "->,>>>,>>9.9999999999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 15.5 BY 1 NO-UNDO.
DEFINE VARIABLE varold-price-rubl-slt AS DECIMAL FORMAT "->,>>>,>>9.9999999999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 15.5 BY 1 NO-UNDO.
DEFINE VARIABLE varold-price-rubl-transport AS DECIMAL FORMAT "->,>>>,>>9.9999999999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 15.5 BY 1 NO-UNDO.
DEFINE VARIABLE varold-price-rubl-vat AS DECIMAL FORMAT "->,>>>,>>9.9999999999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 15.5 BY 1 NO-UNDO.
DEFINE VARIABLE varold-purch-code-name AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 31 BY 1 NO-UNDO.
DEFINE VARIABLE varold-slt-pc AS DECIMAL FORMAT ">9.99":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 6 BY 1 NO-UNDO.
DEFINE VARIABLE varold-sum-base AS DECIMAL FORMAT "->>>,>>>,>>9.9999999999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 17 BY 1 NO-UNDO.
DEFINE VARIABLE varold-sum-base-other AS DECIMAL FORMAT "->>>,>>>,>>9.9999999999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 17 BY 1 NO-UNDO.
DEFINE VARIABLE varold-sum-base-road-tax AS DECIMAL FORMAT "->>>,>>>,>>9.9999999999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 17 BY 1 NO-UNDO.
DEFINE VARIABLE varold-sum-base-slt AS DECIMAL FORMAT "->>>,>>>,>>9.9999999999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 17 BY 1 NO-UNDO.
DEFINE VARIABLE varold-sum-base-transport AS DECIMAL FORMAT "->>>,>>>,>>9.9999999999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 17 BY 1 NO-UNDO.
DEFINE VARIABLE varold-sum-base-vat AS DECIMAL FORMAT "->>>,>>>,>>9.9999999999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 17 BY 1 NO-UNDO.
DEFINE VARIABLE varold-sum-cli AS DECIMAL FORMAT "->>>,>>>,>>9.9999999999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 17 BY 1 NO-UNDO.
DEFINE VARIABLE varold-sum-cli-road-tax AS DECIMAL FORMAT "->>>,>>>,>>9.9999999999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 17 BY 1 NO-UNDO.
DEFINE VARIABLE varold-sum-cli-slt AS DECIMAL FORMAT "->>>,>>>,>>9.9999999999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 17 BY 1 NO-UNDO.
DEFINE VARIABLE varold-sum-cli-vat AS DECIMAL FORMAT "->>>,>>>,>>9.9999999999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 17 BY 1 NO-UNDO.
DEFINE VARIABLE varold-sum-rubl AS DECIMAL FORMAT "->>>,>>>,>>9.9999999999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 17 BY 1 NO-UNDO.
DEFINE VARIABLE varold-sum-rubl-other AS DECIMAL FORMAT "->>>,>>>,>>9.9999999999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 17 BY 1 NO-UNDO.
DEFINE VARIABLE varold-sum-rubl-road-tax AS DECIMAL FORMAT "->>>,>>>,>>9.9999999999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 17 BY 1 NO-UNDO.
DEFINE VARIABLE varold-sum-rubl-slt AS DECIMAL FORMAT "->>>,>>>,>>9.9999999999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 17 BY 1 NO-UNDO.
DEFINE VARIABLE varold-sum-rubl-transport AS DECIMAL FORMAT "->>>,>>>,>>9.9999999999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 17 BY 1 NO-UNDO.
DEFINE VARIABLE varold-sum-rubl-vat AS DECIMAL FORMAT "->>>,>>>,>>9.9999999999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 17 BY 1 NO-UNDO.
DEFINE VARIABLE varold-vat-pc AS DECIMAL FORMAT ">9.99":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 6 BY 1 NO-UNDO.
DEFINE VARIABLE varpart-code AS CHARACTER FORMAT "X(20)":U
     LABEL "Код"
     VIEW-AS FILL-IN
     SIZE 21 BY 1 NO-UNDO.
DEFINE VARIABLE varprice-base AS DECIMAL FORMAT "->,>>>,>>9.9999999999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 15.5 BY 1 NO-UNDO.
DEFINE VARIABLE varprice-base-other AS DECIMAL FORMAT "->,>>>,>>9.9999999999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 15.5 BY 1 NO-UNDO.
DEFINE VARIABLE varprice-base-road-tax AS DECIMAL FORMAT "->,>>>,>>9.9999999999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 15.5 BY 1 NO-UNDO.
DEFINE VARIABLE varprice-base-slt AS DECIMAL FORMAT "->,>>>,>>9.9999999999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 15.5 BY 1 NO-UNDO.
DEFINE VARIABLE varprice-base-transport AS DECIMAL FORMAT "->,>>>,>>9.9999999999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 15.5 BY 1 NO-UNDO.
DEFINE VARIABLE varprice-base-vat AS DECIMAL FORMAT "->,>>>,>>9.9999999999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 15.5 BY 1 NO-UNDO.
DEFINE VARIABLE varprice-cli AS DECIMAL FORMAT "->,>>>,>>9.9999999999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 15.5 BY 1 NO-UNDO.
DEFINE VARIABLE varprice-cli-road-tax AS DECIMAL FORMAT "->,>>>,>>9.9999999999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 15.5 BY 1 NO-UNDO.
DEFINE VARIABLE varprice-cli-slt AS DECIMAL FORMAT "->,>>>,>>9.9999999999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 15.5 BY 1 NO-UNDO.
DEFINE VARIABLE varprice-cli-vat AS DECIMAL FORMAT "->,>>>,>>9.9999999999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 15.5 BY 1 NO-UNDO.
DEFINE VARIABLE varprice-rubl AS DECIMAL FORMAT "->,>>>,>>9.9999999999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 15.5 BY 1 NO-UNDO.
DEFINE VARIABLE varprice-rubl-other AS DECIMAL FORMAT "->,>>>,>>9.9999999999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 15.5 BY 1 NO-UNDO.
DEFINE VARIABLE varprice-rubl-road-tax AS DECIMAL FORMAT "->,>>>,>>9.9999999999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 15.5 BY 1 NO-UNDO.
DEFINE VARIABLE varprice-rubl-slt AS DECIMAL FORMAT "->,>>>,>>9.9999999999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 15.5 BY 1 NO-UNDO.
DEFINE VARIABLE varprice-rubl-transport AS DECIMAL FORMAT "->,>>>,>>9.9999999999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 15.5 BY 1 NO-UNDO.
DEFINE VARIABLE varprice-rubl-vat AS DECIMAL FORMAT "->,>>>,>>9.9999999999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 15.5 BY 1 NO-UNDO.
DEFINE VARIABLE varprod-code AS INTEGER FORMAT ">>>>>>>>9":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 10 BY 1 NO-UNDO.
DEFINE VARIABLE varprod-type AS CHARACTER FORMAT "X(3)":U
     VIEW-AS FILL-IN
     SIZE 4 BY 1 NO-UNDO.
DEFINE VARIABLE varslt-pc AS DECIMAL FORMAT ">9.99":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 6 BY 1 NO-UNDO.
DEFINE VARIABLE varslt-type AS CHARACTER FORMAT "X(256)":U
     LABEL "НП"
     VIEW-AS FILL-IN
     SIZE 12.5 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE varsum-base AS DECIMAL FORMAT "->>>,>>>,>>9.9999999999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 17 BY 1 NO-UNDO.
DEFINE VARIABLE varsum-base-other AS DECIMAL FORMAT "->>>,>>>,>>9.9999999999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 17 BY 1 NO-UNDO.
DEFINE VARIABLE varsum-base-road-tax AS DECIMAL FORMAT "->>>,>>>,>>9.9999999999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 17 BY 1 NO-UNDO.
DEFINE VARIABLE varsum-base-slt AS DECIMAL FORMAT "->>>,>>>,>>9.9999999999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 17 BY 1 NO-UNDO.
DEFINE VARIABLE varsum-base-transport AS DECIMAL FORMAT "->>>,>>>,>>9.9999999999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 17 BY 1 NO-UNDO.
DEFINE VARIABLE varsum-base-vat AS DECIMAL FORMAT "->>>,>>>,>>9.9999999999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 17 BY 1 NO-UNDO.
DEFINE VARIABLE varsum-cli AS DECIMAL FORMAT "->>>,>>>,>>9.9999999999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 17 BY 1 NO-UNDO.
DEFINE VARIABLE varsum-cli-road-tax AS DECIMAL FORMAT "->>>,>>>,>>9.9999999999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 17 BY 1 NO-UNDO.
DEFINE VARIABLE varsum-cli-slt AS DECIMAL FORMAT "->>>,>>>,>>9.9999999999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 17 BY 1 NO-UNDO.
DEFINE VARIABLE varsum-cli-vat AS DECIMAL FORMAT "->>>,>>>,>>9.9999999999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 17 BY 1 NO-UNDO.
DEFINE VARIABLE varsum-rubl AS DECIMAL FORMAT "->>>,>>>,>>9.9999999999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 17 BY 1 NO-UNDO.
DEFINE VARIABLE varsum-rubl-other AS DECIMAL FORMAT "->>>,>>>,>>9.9999999999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 17 BY 1 NO-UNDO.
DEFINE VARIABLE varsum-rubl-road-tax AS DECIMAL FORMAT "->>>,>>>,>>9.9999999999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 17 BY 1 NO-UNDO.
DEFINE VARIABLE varsum-rubl-slt AS DECIMAL FORMAT "->>>,>>>,>>9.9999999999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 17 BY 1 NO-UNDO.
DEFINE VARIABLE varsum-rubl-transport AS DECIMAL FORMAT "->>>,>>>,>>9.9999999999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 17 BY 1 NO-UNDO.
DEFINE VARIABLE varsum-rubl-vat AS DECIMAL FORMAT "->>>,>>>,>>9.9999999999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 17 BY 1 NO-UNDO.
DEFINE VARIABLE varsupp-code AS INTEGER FORMAT ">>>>>>>>9":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 6 BY 1 NO-UNDO.
DEFINE VARIABLE varsupp-name AS CHARACTER FORMAT "X(40)":U
     VIEW-AS FILL-IN
     SIZE 15 BY 1 NO-UNDO.
DEFINE VARIABLE varsupp-type AS CHARACTER FORMAT "X(3)":U
     VIEW-AS FILL-IN
     SIZE 4 BY 1 NO-UNDO.
DEFINE VARIABLE vartitle-road-tax AS CHARACTER FORMAT "X(256)":U INITIAL "Стеклопосуда"
      VIEW-AS TEXT
     SIZE 14 BY .67
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE varvat-pc AS DECIMAL FORMAT ">9.99":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 6 BY 1 NO-UNDO.
DEFINE VARIABLE varvat-type AS CHARACTER FORMAT "X(256)":U
     LABEL "НДС"
     VIEW-AS FILL-IN
     SIZE 12.5 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 32 BY 4.88.
DEFINE RECTANGLE RECT-goods
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 98 BY 1.42.
DEFINE RECTANGLE RECT-object
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 66.5 BY 1.42.
DEFINE RECTANGLE RECT-other
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 66.13 BY 2.17.
DEFINE RECTANGLE RECT-part
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 67.38 BY 1.42.
DEFINE RECTANGLE RECT-part-2
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 67.38 BY 2.5.
DEFINE RECTANGLE RECT-price
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 98 BY 2.5.
DEFINE RECTANGLE RECT-road-tax
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 98 BY 2.42.
DEFINE RECTANGLE RECT-slt
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 98 BY 2.46.
DEFINE RECTANGLE RECT-transport
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 66.13 BY 2.33.
DEFINE RECTANGLE RECT-vat
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 98 BY 2.38.
DEFINE FRAME Dialog-Frame
     b-save AT ROW 1 COL 1
     b-cancel AT ROW 1 COL 11
     b-help AT ROW 1 COL 21
     varobj-type AT ROW 1.25 COL 37.25 COLON-ALIGNED NO-LABEL
     varobj-code AT ROW 1.25 COL 41.75 COLON-ALIGNED NO-LABEL
     varobj-name AT ROW 1.25 COL 47.88 COLON-ALIGNED NO-LABEL
     varsupp-type AT ROW 1.25 COL 71.25 COLON-ALIGNED NO-LABEL
     varsupp-code AT ROW 1.25 COL 75.5 COLON-ALIGNED NO-LABEL
     varsupp-name AT ROW 1.25 COL 81.75 COLON-ALIGNED NO-LABEL
     varfact-qnty AT ROW 2.5 COL 72.5 COLON-ALIGNED
     varartic AT ROW 2.63 COL 7.5 COLON-ALIGNED
     varprod-type AT ROW 2.63 COL 25 COLON-ALIGNED NO-LABEL
     varprod-code AT ROW 2.63 COL 29.63 COLON-ALIGNED NO-LABEL
     vargds-name AT ROW 2.63 COL 40 COLON-ALIGNED NO-LABEL
     varvat-type AT ROW 4 COL 71.5 COLON-ALIGNED
     varold-vat-pc AT ROW 4 COL 84 COLON-ALIGNED NO-LABEL
     varvat-pc AT ROW 4 COL 90.5 COLON-ALIGNED NO-LABEL
     varincome-in-code AT ROW 4.25 COL 6 COLON-ALIGNED
     varin-code AT ROW 4.25 COL 25 COLON-ALIGNED
     varpart-code AT ROW 4.25 COL 45 COLON-ALIGNED
     varslt-type AT ROW 5.25 COL 71.5 COLON-ALIGNED
     varold-slt-pc AT ROW 5.25 COL 84 COLON-ALIGNED NO-LABEL
     varslt-pc AT ROW 5.25 COL 90.5 COLON-ALIGNED NO-LABEL
     varcur-base-name AT ROW 5.5 COL 9.5 NO-LABEL
     varcur-base-rate AT ROW 5.5 COL 16.5 COLON-ALIGNED
     varcur-base-scale AT ROW 5.5 COL 25 COLON-ALIGNED NO-LABEL
     b-cur-rate AT ROW 5.5 COL 32
     varold-base-rate AT ROW 5.5 COL 33.5 COLON-ALIGNED NO-LABEL
     varbase-rate AT ROW 5.5 COL 46.5 COLON-ALIGNED NO-LABEL
     varbase-scale AT ROW 5.5 COL 55 COLON-ALIGNED NO-LABEL
     b-calc-rate AT ROW 5.5 COL 61.5
     varcur-cli-name AT ROW 6.5 COL 9.5 NO-LABEL
     varcur-exch-rate AT ROW 6.5 COL 16.5 COLON-ALIGNED
     varcur-exch-scale AT ROW 6.5 COL 25 COLON-ALIGNED NO-LABEL
     b-cur-exch-rate AT ROW 6.5 COL 32
     varold-exch-rate AT ROW 6.5 COL 33.5 COLON-ALIGNED NO-LABEL
     varexch-rate AT ROW 6.5 COL 46.5 COLON-ALIGNED NO-LABEL
     varexch-scale AT ROW 6.5 COL 55 COLON-ALIGNED NO-LABEL
     b-calc-exch-rate AT ROW 6.5 COL 61.5
     varcli-base-rate AT ROW 6.5 COL 87 COLON-ALIGNED
     b-calc-cli-t-rubl AT ROW 7.75 COL 28.5
     b-calc-rubl-t-cli AT ROW 7.75 COL 33.5
     b-calc-rubl-t-base AT ROW 7.75 COL 61
     b-calc-base-t-rubl AT ROW 7.75 COL 66
     varold-price-cli AT ROW 8.5 COL 1 NO-LABEL
     varold-sum-cli AT ROW 8.5 COL 14.5 COLON-ALIGNED NO-LABEL
     varold-price-rubl AT ROW 8.5 COL 31.5 COLON-ALIGNED NO-LABEL
     varold-sum-rubl AT ROW 8.5 COL 47 COLON-ALIGNED NO-LABEL
     varold-price-base AT ROW 8.5 COL 64 COLON-ALIGNED NO-LABEL
     varold-sum-base AT ROW 8.5 COL 79.75 COLON-ALIGNED NO-LABEL
     varsum-rubl AT ROW 9.5 COL 47 COLON-ALIGNED NO-LABEL
     varprice-base AT ROW 9.5 COL 64 COLON-ALIGNED NO-LABEL
     varsum-base AT ROW 9.5 COL 79.75 COLON-ALIGNED NO-LABEL
     varprice-cli AT ROW 9.54 COL 1 NO-LABEL
     varsum-cli AT ROW 9.54 COL 14.5 COLON-ALIGNED NO-LABEL
     varprice-rubl AT ROW 9.54 COL 31.5 COLON-ALIGNED NO-LABEL
     varold-price-base-vat AT ROW 11.17 COL 64 COLON-ALIGNED NO-LABEL
     varold-sum-base-vat AT ROW 11.17 COL 79.75 COLON-ALIGNED NO-LABEL
     varold-price-cli-vat AT ROW 11.21 COL 1 NO-LABEL
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         DEFAULT-BUTTON b-save CANCEL-BUTTON b-cancel.
DEFINE FRAME Dialog-Frame
     varold-sum-cli-vat AT ROW 11.21 COL 14.5 COLON-ALIGNED NO-LABEL
     varold-price-rubl-vat AT ROW 11.21 COL 31.5 COLON-ALIGNED NO-LABEL
     varold-sum-rubl-vat AT ROW 11.21 COL 47 COLON-ALIGNED NO-LABEL
     varprice-base-vat AT ROW 12.08 COL 64 COLON-ALIGNED NO-LABEL
     varsum-base-vat AT ROW 12.08 COL 79.75 COLON-ALIGNED NO-LABEL
     varprice-cli-vat AT ROW 12.13 COL 1 NO-LABEL
     varsum-cli-vat AT ROW 12.13 COL 14.5 COLON-ALIGNED NO-LABEL
     varprice-rubl-vat AT ROW 12.13 COL 31.5 COLON-ALIGNED NO-LABEL
     varsum-rubl-vat AT ROW 12.13 COL 47 COLON-ALIGNED NO-LABEL
     varold-price-base-slt AT ROW 13.67 COL 64 COLON-ALIGNED NO-LABEL
     varold-sum-base-slt AT ROW 13.67 COL 79.75 COLON-ALIGNED NO-LABEL
     varold-price-cli-slt AT ROW 13.71 COL 1 NO-LABEL
     varold-sum-cli-slt AT ROW 13.71 COL 14.5 COLON-ALIGNED NO-LABEL
     varold-price-rubl-slt AT ROW 13.71 COL 31.5 COLON-ALIGNED NO-LABEL
     varold-sum-rubl-slt AT ROW 13.71 COL 47 COLON-ALIGNED NO-LABEL
     varprice-base-slt AT ROW 14.71 COL 64 COLON-ALIGNED NO-LABEL
     varsum-base-slt AT ROW 14.71 COL 79.75 COLON-ALIGNED NO-LABEL
     varprice-cli-slt AT ROW 14.75 COL 1 NO-LABEL
     varsum-cli-slt AT ROW 14.75 COL 14.5 COLON-ALIGNED NO-LABEL
     varprice-rubl-slt AT ROW 14.75 COL 31.5 COLON-ALIGNED NO-LABEL
     varsum-rubl-slt AT ROW 14.75 COL 47 COLON-ALIGNED NO-LABEL
     varold-price-base-road-tax AT ROW 16.25 COL 64 COLON-ALIGNED NO-LABEL
     varold-sum-base-road-tax AT ROW 16.25 COL 79.75 COLON-ALIGNED NO-LABEL
     varold-price-cli-road-tax AT ROW 16.29 COL 1 NO-LABEL
     varold-sum-cli-road-tax AT ROW 16.29 COL 14.5 COLON-ALIGNED NO-LABEL
     varold-price-rubl-road-tax AT ROW 16.29 COL 31.5 COLON-ALIGNED NO-LABEL
     varold-sum-rubl-road-tax AT ROW 16.29 COL 47 COLON-ALIGNED NO-LABEL
     varprice-base-road-tax AT ROW 17.33 COL 64 COLON-ALIGNED NO-LABEL
     varsum-base-road-tax AT ROW 17.33 COL 79.75 COLON-ALIGNED NO-LABEL
     varprice-cli-road-tax AT ROW 17.38 COL 1 NO-LABEL
     varsum-cli-road-tax AT ROW 17.38 COL 14.5 COLON-ALIGNED NO-LABEL
     varprice-rubl-road-tax AT ROW 17.38 COL 33.5 NO-LABEL
     varsum-rubl-road-tax AT ROW 17.38 COL 47 COLON-ALIGNED NO-LABEL
     varold-price-base-transport AT ROW 19 COL 64 COLON-ALIGNED NO-LABEL
     varold-sum-base-transport AT ROW 19 COL 79.75 COLON-ALIGNED NO-LABEL
     varold-price-rubl-transport AT ROW 19.04 COL 31.5 COLON-ALIGNED NO-LABEL
     varold-sum-rubl-transport AT ROW 19.04 COL 47 COLON-ALIGNED NO-LABEL
     varold-purch-code-name AT ROW 19.75 COL 1.5 NO-LABEL
     varprice-base-transport AT ROW 19.92 COL 64 COLON-ALIGNED NO-LABEL
     varsum-base-transport AT ROW 19.92 COL 79.75 COLON-ALIGNED NO-LABEL
     varprice-rubl-transport AT ROW 19.96 COL 33.5 NO-LABEL
     varsum-rubl-transport AT ROW 19.96 COL 47 COLON-ALIGNED NO-LABEL
     varpurch-code-name AT ROW 21.5 COL 1.5 NO-LABEL
     varold-price-base-other AT ROW 21.67 COL 64 COLON-ALIGNED NO-LABEL
     varold-sum-base-other AT ROW 21.67 COL 79.75 COLON-ALIGNED NO-LABEL
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         DEFAULT-BUTTON b-save CANCEL-BUTTON b-cancel.
DEFINE FRAME Dialog-Frame
     varold-price-rubl-other AT ROW 21.71 COL 31.5 COLON-ALIGNED NO-LABEL
     varold-sum-rubl-other AT ROW 21.71 COL 47 COLON-ALIGNED NO-LABEL
     varprice-base-other AT ROW 22.58 COL 64 COLON-ALIGNED NO-LABEL
     varsum-base-other AT ROW 22.58 COL 79.75 COLON-ALIGNED NO-LABEL
     varprice-rubl-other AT ROW 22.63 COL 33.5 NO-LABEL
     varsum-rubl-other AT ROW 22.63 COL 47 COLON-ALIGNED NO-LABEL
     v-rubli-firstshift AT ROW 7.75 COL 45 NO-LABEL
     vartitle-road-tax AT ROW 15.71 COL 1.5 NO-LABEL
     "Цена" VIEW-AS TEXT
          SIZE 4.5 BY .67 AT ROW 7.75 COL 40
          BGCOLOR 3 FGCOLOR 15
     "Сумма" VIEW-AS TEXT
          SIZE 5.5 BY .67 AT ROW 7.75 COL 91.5
          BGCOLOR 3 FGCOLOR 15
     "Транспортные расходы" VIEW-AS TEXT
          SIZE 21.25 BY .67 AT ROW 18.25 COL 33
          BGCOLOR 3 FGCOLOR 15
     "НДС" VIEW-AS TEXT
          SIZE 4 BY .67 AT ROW 10.46 COL 1.38
          BGCOLOR 3 FGCOLOR 15
     "Сумма" VIEW-AS TEXT
          SIZE 5.5 BY .67 AT ROW 7.75 COL 22.5
          BGCOLOR 3 FGCOLOR 15
     "Цена" VIEW-AS TEXT
          SIZE 4.5 BY .67 AT ROW 7.75 COL 71.5
          BGCOLOR 3 FGCOLOR 15
     "Цена" VIEW-AS TEXT
          SIZE 4.5 BY .67 AT ROW 7.75 COL 1.5
          BGCOLOR 3 FGCOLOR 15
     "ВалПост" VIEW-AS TEXT
          SIZE 7.5 BY .67 AT ROW 6.75 COL 1.5
          BGCOLOR 3 FGCOLOR 15
     "Базовая валюта" VIEW-AS TEXT
          SIZE 14.5 BY .67 AT ROW 7.75 COL 76.5
          BGCOLOR 3 FGCOLOR 15
     "Объект" VIEW-AS TEXT
          SIZE 6.25 BY .67 AT ROW 1.42 COL 33
     "Сумма" VIEW-AS TEXT
          SIZE 5.5 BY .67 AT ROW 7.75 COL 51.5
          BGCOLOR 3 FGCOLOR 15
     "Прочие расходы" VIEW-AS TEXT
          SIZE 15.13 BY .67 AT ROW 21 COL 33
          BGCOLOR 3 FGCOLOR 15
     "Поставщик" VIEW-AS TEXT
          SIZE 9.75 BY .67 AT ROW 1.42 COL 63.13
     "Валюта пост." VIEW-AS TEXT
          SIZE 12.5 BY .67 AT ROW 7.75 COL 9
          BGCOLOR 3 FGCOLOR 15
     "НП" VIEW-AS TEXT
          SIZE 4 BY .67 AT ROW 12.96 COL 1.38
          BGCOLOR 3 FGCOLOR 15
     "Тип приобретения" VIEW-AS TEXT
          SIZE 16.5 BY .67 AT ROW 18.5 COL 9.5
          BGCOLOR 3 FGCOLOR 15
     "БазВал" VIEW-AS TEXT
          SIZE 7.5 BY .67 AT ROW 5.75 COL 1.5
          BGCOLOR 3 FGCOLOR 15
     RECT-goods AT ROW 2.46 COL 1.13
     RECT-transport AT ROW 18.79 COL 33
     RECT-object AT ROW 1 COL 32.5
     RECT-part AT ROW 4.04 COL 1
     RECT-other AT ROW 21.46 COL 33
     RECT-road-tax AT ROW 16.04 COL 1.13
     RECT-price AT ROW 8.25 COL 1
     RECT-slt AT ROW 13.46 COL 1.13
     RECT-vat AT ROW 10.83 COL 1.13
     RECT-part-2 AT ROW 5.25 COL 1
     RECT-1 AT ROW 18.79 COL 1
     SPACE(66.13) SKIP(0.49)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Установка цены"
         DEFAULT-BUTTON b-save CANCEL-BUTTON b-cancel.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON return OF FRAME Dialog-Frame
DO:
  return no-apply.
END.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-calc-base-t-rubl IN FRAME Dialog-Frame
DO:
  run proc-calc-base-rubl in THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
    MESSAGE "Ошибка при пересчете значений в базовой валюте." SKIP
            RETURN-VALUE SKIP
            ERROR-STATUS:GET-MESSAGE(1) SKIP
    VIEW-AS ALERT-BOX ERROR.
    RETURN NO-APPLY.
  END.
END.
ON CHOOSE OF b-calc-cli-t-rubl IN FRAME Dialog-Frame
DO:
  run proc-calc-cli-rubl in THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
     MESSAGE "Ошибка при пересчете значений в валюте клиента." SKIP
             RETURN-VALUE SKIP
             ERROR-STATUS:GET-MESSAGE(1) SKIP
     VIEW-AS ALERT-BOX ERROR.
     RETURN NO-APPLY.
   END.
END.
ON CHOOSE OF b-calc-exch-rate IN FRAME Dialog-Frame
DO:
  run proc-calc-exch-rate in this-procedure no-error.
  if error-status:error then do:
    message "Ошибка при пересчете курса валюты поставщика." skip
            return-value skip
            error-status:get-message(1)
    view-as alert-box error.
    return no-apply.
  end.
END.
ON CHOOSE OF b-calc-rate IN FRAME Dialog-Frame
DO:
  run proc-calc-rate in THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
    MESSAGE "Ошибка при расчете по новому курсу базовой валюты." SKIP
            RETURN-VALUE SKIP
            ERROR-STATUS:GET-MESSAGE(1) SKIP
            ERROR-STATUS:GET-MESSAGE(2)
    VIEW-AS ALERT-BOX ERROR.
    RETURN NO-APPLY.
  END.
END.
ON CHOOSE OF b-calc-rubl-t-base IN FRAME Dialog-Frame
DO:
  run proc-calc-rubl-base in THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
    MESSAGE "Ошибка при пересчете значений в рублях." SKIP
            RETURN-VALUE SKIP
            ERROR-STATUS:GET-MESSAGE(1) SKIP
    VIEW-AS ALERT-BOX ERROR.
    RETURN NO-APPLY.
  END.
if varexcheqrubl then do:
  run proc-calc-cli-rubl in THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
     MESSAGE "Ошибка при пересчете значений в валюте." SKIP
             RETURN-VALUE SKIP
             ERROR-STATUS:GET-MESSAGE(1) SKIP
     VIEW-AS ALERT-BOX ERROR.
     RETURN NO-APPLY.
  END.
END.
END.
ON CHOOSE OF b-calc-rubl-t-cli IN FRAME Dialog-Frame
DO:
run proc-calc-rubl-cli in THIS-PROCEDURE NO-ERROR.
IF ERROR-STATUS:ERROR THEN DO:
   MESSAGE "Ошибка при пересчете значений в рублях." SKIP
           RETURN-VALUE SKIP
           ERROR-STATUS:GET-MESSAGE(1) SKIP
   VIEW-AS ALERT-BOX ERROR.
   RETURN NO-APPLY.
END.
if varbaseeqrubl then do:
  run proc-calc-base-rubl in THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
     MESSAGE "Ошибка при пересчете значений в валюте." SKIP
             RETURN-VALUE SKIP
             ERROR-STATUS:GET-MESSAGE(1) SKIP
     VIEW-AS ALERT-BOX ERROR.
     RETURN NO-APPLY.
  END.
end.
END.
ON CHOOSE OF b-cancel IN FRAME Dialog-Frame
DO:
  assign
    paris-ok = false.
  apply "go" to frame Dialog-Frame.
END.
ON CHOOSE OF b-cur-exch-rate IN FRAME Dialog-Frame
DO:
  run state-cur-exch-rate in this-procedure no-error.
  if error-status:error then do:
    message "Ошибка при установке текущего курса." skip
            return-value skip
            error-status:get-message(1) skip
            error-status:get-message(2)
     view-as alert-box.
  end.
END.
ON CHOOSE OF b-cur-rate IN FRAME Dialog-Frame
DO:
  run state-cur-rate in this-procedure no-error.
  if error-status:error then do:
    message "Ошибка при установке текущего курса." skip
            return-value skip
            error-status:get-message(1) skip
            error-status:get-message(2)
     view-as alert-box.
  end.
END.
ON CHOOSE OF b-save IN FRAME Dialog-Frame
DO:
  run rate-correct (output varrate-correct) no-error.                             if error-status:error then do:                               message "Ошибка при вызове процедуры rate-correct." skip                                       return-value                                       error-status:get-message(1)                                       error-status:get-message(2)                               view-as alert-box error.                               return no-apply.                             end.                             if varrate-correct = no then do:                               message "Курс в партии не согласован с рублевой и валютной ценой." skip                                       "Рублевая цена: "         varprice-rubl skip                                       "Цена в базовой валюте: " varprice-base skip                                       "Курс базовой валюты: "   varbase-rate  skip                                       "Шкала базовой валюты: "  varbase-scale                                    view-as alert-box information.                               if b-calc-rate:sensitive then do:                                 apply "entry" to b-calc-rate.                              end.                               else do:                                 if b-calc-exch-rate:sensitive then do:                                   apply "entry" to b-calc-exch-rate.                                 end.                                 else do:                                   apply "entry" to varprice-cli.                                end.                               end.                               return no-apply.                             end.
  run rate-exch-correct (output varrate-exch-correct) no-error.                                  if error-status:error then do:                                    message "Ошибка при вызове процедуры rate-exch-correct." skip                                            return-value                                            error-status:get-message(1)                                            error-status:get-message(2)                                    view-as alert-box error.                                    return no-apply.                                  end.                                  if varrate-exch-correct = no then do:                                    message "Курс в партии не согласован с рублевой и ценой в валюте поставщика (договора)." skip                                            "Рублевая цена: "            varprice-rubl    skip                                            "Цена в валюте поставщика: " varprice-cli     skip                                            "Единица поставщика: "       varcli-base-rate skip                                            "Курс валюты поставщика: "   varexch-rate     skip                                            "Шкала валюты поставщика: "  varexch-scale                                    view-as alert-box information.                                    if b-calc-exch-rate:sensitive then do:                                      apply "entry" to b-calc-exch-rate.                                   end.                                    else do:                                      apply "entry" to varprice-cli.                                    end.                                    return no-apply.                                  end.
  if round(varbase-rate           , 4) <> input frame Dialog-Frame varbase-rate             then apply "leave" to varbase-rate            in frame Dialog-Frame.
  if       varbase-scale               <> input frame Dialog-Frame varbase-scale            then apply "leave" to varbase-scale           in frame Dialog-Frame.
  if varprice-base           <> input frame Dialog-Frame varprice-base            then apply "leave" to varprice-base           in frame Dialog-Frame.
  if varsum-base             <> input frame Dialog-Frame varsum-base              then apply "leave" to varsum-base             in frame Dialog-Frame.
  if varprice-rubl           <> input frame Dialog-Frame varprice-rubl            then apply "leave" to varprice-rubl           in frame Dialog-Frame.
  if varsum-rubl             <> input frame Dialog-Frame varsum-rubl              then apply "leave" to varsum-rubl             in frame Dialog-Frame.
  if varprice-cli            <> input frame Dialog-Frame varprice-cli             then apply "leave" to varprice-cli            in frame Dialog-Frame.
  if varsum-cli              <> input frame Dialog-Frame varsum-cli               then apply "leave" to varsum-cli              in frame Dialog-Frame.
  if round (varvat-pc, 2)    <> input frame Dialog-Frame varvat-pc                then apply "leave" to varvat-pc               in frame Dialog-Frame.
  if varprice-base-vat       <> input frame Dialog-Frame varprice-base-vat        then apply "leave" to varprice-base-vat       in frame Dialog-Frame.
  if varsum-base-vat         <> input frame Dialog-Frame varsum-base-vat          then apply "leave" to varsum-base-vat         in frame Dialog-Frame.
  if varprice-rubl-vat       <> input frame Dialog-Frame varprice-rubl-vat        then apply "leave" to varprice-rubl-vat       in frame Dialog-Frame.
  if varsum-rubl-vat         <> input frame Dialog-Frame varsum-rubl-vat          then apply "leave" to varsum-rubl-vat         in frame Dialog-Frame.
  if varprice-cli-vat        <> input frame Dialog-Frame varprice-cli-vat         then apply "leave" to varprice-cli-vat        in frame Dialog-Frame.
  if varsum-cli-vat          <> input frame Dialog-Frame varsum-cli-vat           then apply "leave" to varsum-cli-vat          in frame Dialog-Frame.
  if round(varslt-pc, 2)     <> input frame Dialog-Frame varslt-pc                then apply "leave" to varslt-pc               in frame Dialog-Frame.
  if varprice-base-slt       <> input frame Dialog-Frame varprice-base-slt        then apply "leave" to varprice-base-slt       in frame Dialog-Frame.
  if varsum-base-slt         <> input frame Dialog-Frame varsum-base-slt          then apply "leave" to varsum-base-slt         in frame Dialog-Frame.
  if varprice-rubl-slt       <> input frame Dialog-Frame varprice-rubl-slt        then apply "leave" to varprice-rubl-slt       in frame Dialog-Frame.
  if varsum-rubl-slt         <> input frame Dialog-Frame varsum-rubl-slt          then apply "leave" to varsum-rubl-slt         in frame Dialog-Frame.
  if varprice-cli-slt        <> input frame Dialog-Frame varprice-cli-slt         then apply "leave" to varprice-cli-slt        in frame Dialog-Frame.
  if varsum-cli-slt          <> input frame Dialog-Frame varsum-cli-slt           then apply "leave" to varsum-cli-slt          in frame Dialog-Frame.
  if varprice-base-road-tax  <> input frame Dialog-Frame varprice-base-road-tax   then apply "leave" to varprice-base-road-tax  in frame Dialog-Frame.
  if varsum-base-road-tax    <> input frame Dialog-Frame varsum-base-road-tax     then apply "leave" to varsum-base-road-tax    in frame Dialog-Frame.
  if varprice-rubl-road-tax  <> input frame Dialog-Frame varprice-rubl-road-tax   then apply "leave" to varprice-rubl-road-tax  in frame Dialog-Frame.
  if varsum-rubl-road-tax    <> input frame Dialog-Frame varsum-rubl-road-tax     then apply "leave" to varsum-rubl-road-tax    in frame Dialog-Frame.
  if varprice-cli-road-tax   <> input frame Dialog-Frame varprice-cli-road-tax    then apply "leave" to varprice-cli-road-tax   in frame Dialog-Frame.
  if varsum-cli-road-tax     <> input frame Dialog-Frame varsum-cli-road-tax      then apply "leave" to varsum-cli-road-tax     in frame Dialog-Frame.
  if varprice-base-transport <> input frame Dialog-Frame varprice-base-transport  then apply "leave" to varprice-base-transport in frame Dialog-Frame.
  if varsum-base-transport   <> input frame Dialog-Frame varsum-base-transport    then apply "leave" to varsum-base-transport   in frame Dialog-Frame.
  if varprice-rubl-transport <> input frame Dialog-Frame varprice-rubl-transport  then apply "leave" to varprice-rubl-transport in frame Dialog-Frame.
  if varsum-rubl-transport   <> input frame Dialog-Frame varsum-rubl-transport    then apply "leave" to varsum-rubl-transport   in frame Dialog-Frame.
  if varprice-base-other     <> input frame Dialog-Frame varprice-base-other      then apply "leave" to varprice-base-other     in frame Dialog-Frame.
  if varsum-base-other       <> input frame Dialog-Frame varsum-base-other        then apply "leave" to varsum-base-other       in frame Dialog-Frame.
  if varprice-rubl-other     <> input frame Dialog-Frame varprice-rubl-other      then apply "leave" to varprice-rubl-other     in frame Dialog-Frame.
  if varsum-rubl-other       <> input frame Dialog-Frame varsum-rubl-other        then apply "leave" to varsum-rubl-other       in frame Dialog-Frame.
  IF varpurch-code-name      <> INPUT FRAME Dialog-Frame varpurch-code-name       THEN APPLY "leave" TO varpurch-code-name      IN FRAME Dialog-Frame.
  if varbase-rate            < 0                      or varbase-rate         = ?  then do: message "Неверный курс базовой валюты: "                                                varbase-rate            view-as alert-box. apply "entry" to varbase-rate            in frame Dialog-Frame. return no-apply. end.
  if varbase-scale           < 0                      or varbase-scale        = ?  then do: message "Неверная шкала курса базовой валюты: "                                         varbase-scale           view-as alert-box. apply "entry" to varbase-scale           in frame Dialog-Frame. return no-apply. end.
  if varprice-base           < 0                      or varprice-base        = ?  then do: message "Неверная цена в базовой валюте: "                                              varprice-base           view-as alert-box. apply "entry" to varprice-base           in frame Dialog-Frame. return no-apply. end.
  if varsum-base             < 0                      or varsum-base          = ?  then do: message "Неверная сумма в базовой валюте: "                                             varsum-base             view-as alert-box. apply "entry" to varsum-base             in frame Dialog-Frame. return no-apply. end.
  if varprice-rubl           < 0                      or varprice-rubl        = ?  then do: message "Неверная цена в рублях "                                                       varprice-rubl           view-as alert-box. apply "entry" to varprice-rubl           in frame Dialog-Frame. return no-apply. end.
  if varsum-rubl             < 0                      or varsum-rubl          = ?  then do: message "Неверная сумма в рублях: "                                                     varsum-rubl             view-as alert-box. apply "entry" to varsum-rubl             in frame Dialog-Frame. return no-apply. end.
  if varprice-cli            < 0                      or varprice-cli         = ?  then do: message "Неверная цена в валюте поставщика "                                            varprice-cli            view-as alert-box. apply "entry" to varprice-cli            in frame Dialog-Frame. return no-apply. end.
  if varsum-cli              < 0                      or varsum-cli           = ?  then do: message "Неверная сумма в валюте поставщика: "                                          varsum-cli              view-as alert-box. apply "entry" to varsum-cli              in frame Dialog-Frame. return no-apply. end.
  if varvat-pc               < 0 or varvat-pc > 100.0 or varvat-pc            = ?  then do: message "Неверный процент НДС: "                                                        varvat-pc               view-as alert-box. apply "entry" to varvat-pc               in frame Dialog-Frame. return no-apply. end.
  if varprice-base-vat       < 0                      or varprice-base-vat    = ?  then do: message "Неверная ценовая компонента НДС в базовой валюте: "                            varprice-base-vat       view-as alert-box. apply "entry" to varprice-base-vat       in frame Dialog-Frame. return no-apply. end.
  if varsum-base-vat         < 0                      or varsum-base-vat      = ?  then do: message "Неверная сумма НДС в базовой валюте: "                                         varsum-base-vat         view-as alert-box. apply "entry" to varsum-base-vat         in frame Dialog-Frame. return no-apply. end.
  if varprice-rubl-vat       < 0                      or varprice-rubl-vat    = ?  then do: message "Неверная ценовая компонента НДС в рублях: "                                    varprice-rubl-vat       view-as alert-box. apply "entry" to varprice-rubl-vat       in frame Dialog-Frame. return no-apply. end.
  if varsum-rubl-vat         < 0                      or varsum-rubl-vat      = ?  then do: message "Неверная сумма НДС в рублях: "                                                 varsum-rubl-vat         view-as alert-box. apply "entry" to varsum-rubl-vat         in frame Dialog-Frame. return no-apply. end.
  if varprice-cli-vat        < 0                      or varprice-cli-vat     = ?  then do: message "Неверная ценовая компонента НДС в валюте поставщика: "                         varprice-cli-vat        view-as alert-box. apply "entry" to varprice-cli-vat        in frame Dialog-Frame. return no-apply. end.
  if varsum-cli-vat          < 0                      or varsum-cli-vat       = ?  then do: message "Неверная сумма НДС в валюте поставщика: "                                      varsum-cli-vat          view-as alert-box. apply "entry" to varsum-cli-vat          in frame Dialog-Frame. return no-apply. end.
  if varslt-pc               < 0 or varslt-pc > 100.0 or varslt-pc            = ?  then do: message "Неверный процент НП: "                                                         varslt-pc               view-as alert-box. apply "entry" to varslt-pc               in frame Dialog-Frame. return no-apply. end.
  if varprice-base-slt       < 0                      or varprice-base-slt    = ?  then do: message "Неверная ценовая компонента НП в базовой валюте: "                             varprice-base-slt       view-as alert-box. apply "entry" to varprice-base-slt       in frame Dialog-Frame. return no-apply. end.
  if varsum-base-slt         < 0                      or varsum-base-slt      = ?  then do: message "Неверная сумма НП в базовой валюте: "                                          varsum-base-slt         view-as alert-box. apply "entry" to varsum-base-slt         in frame Dialog-Frame. return no-apply. end.
  if varprice-rubl-slt       < 0                      or varprice-rubl-slt    = ?  then do: message "Неверная ценовая компонента НП в рублях: "                                     varprice-rubl-slt       view-as alert-box. apply "entry" to varprice-rubl-slt       in frame Dialog-Frame. return no-apply. end.
  if varsum-rubl-slt         < 0                      or varsum-rubl-slt      = ?  then do: message "Неверная сумма НП в рублях: "                                                  varsum-rubl-slt         view-as alert-box. apply "entry" to varsum-rubl-slt         in frame Dialog-Frame. return no-apply. end.
  if varprice-cli-slt        < 0                      or varprice-cli-slt     = ?  then do: message "Неверная ценовая компонента НП в валюте поставщика: "                          varprice-cli-slt        view-as alert-box. apply "entry" to varprice-cli-slt        in frame Dialog-Frame. return no-apply. end.
  if varsum-cli-slt          < 0                      or varsum-cli-slt       = ?  then do: message "Неверная сумма НП в валюте поставщика: "                                       varsum-cli-slt          view-as alert-box. apply "entry" to varsum-cli-slt          in frame Dialog-Frame. return no-apply. end.
  if varprice-base-road-tax  < 0                      or varprice-base-road-tax  = ? then do: message "Неверная ценовая компонента налога <" vartitle-road-tax "> в базовой валюте: " varprice-base-road-tax  view-as alert-box. apply "entry" to varprice-base-road-tax  in frame Dialog-Frame. return no-apply. end.
  if varsum-base-road-tax    < 0                      or varsum-base-road-tax    = ? then do: message "Неверная сумма налога <"              vartitle-road-tax "> в базовой валюте: " varsum-base-road-tax    view-as alert-box. apply "entry" to varsum-base-road-tax    in frame Dialog-Frame. return no-apply. end.
  if varprice-rubl-road-tax  < 0                      or varprice-rubl-road-tax  = ? then do: message "Неверная ценовая компонента налога <" vartitle-road-tax "> в рублях: "         varprice-rubl-road-tax  view-as alert-box. apply "entry" to varprice-rubl-road-tax  in frame Dialog-Frame. return no-apply. end.
  if varsum-rubl-road-tax    < 0                      or varsum-rubl-road-tax    = ? then do: message "Неверная сумма налога <"              vartitle-road-tax "> в рублях: "         varsum-rubl-road-tax    view-as alert-box. apply "entry" to varsum-rubl-road-tax    in frame Dialog-Frame. return no-apply. end.
  if varprice-cli-road-tax   < 0                      or varprice-cli-road-tax   = ? then do: message "Неверная ценовая компонента налога <" vartitle-road-tax "> в валюте поставщика: " varprice-rubl-road-tax  view-as alert-box. apply "entry" to varprice-rubl-road-tax  in frame Dialog-Frame. return no-apply. end.
  if varsum-cli-road-tax     < 0                      or varsum-cli-road-tax     = ? then do: message "Неверная сумма налога <"              vartitle-road-tax "> в валюте поставщика: " varsum-rubl-road-tax    view-as alert-box. apply "entry" to varsum-rubl-road-tax    in frame Dialog-Frame. return no-apply. end.
  if varprice-base-transport < 0                      or varprice-base-transport = ? then do: message "Неверная ценовая компонента транспортного расхода в базовой валюте: "          varprice-base-transport view-as alert-box. apply "entry" to varprice-base-transport in frame Dialog-Frame. return no-apply. end.
  if varsum-base-transport   < 0                      or varsum-base-transport   = ? then do: message "Неверная сумма транспортного расхода в базовой валюте: "                       varsum-base-transport   view-as alert-box. apply "entry" to varsum-base-transport   in frame Dialog-Frame. return no-apply. end.
  if varprice-rubl-transport < 0                      or varprice-rubl-transport = ? then do: message "Неверная ценовая компонента транспортного расхода в рублях: "                  varprice-rubl-transport view-as alert-box. apply "entry" to varprice-rubl-transport in frame Dialog-Frame. return no-apply. end.
  if varsum-rubl-transport   < 0                      or varsum-rubl-transport   = ? then do: message "Неверная сумма транспортного расхода в рублях: "                               varsum-rubl-transport   view-as alert-box. apply "entry" to varsum-rubl-transport   in frame Dialog-Frame. return no-apply. end.
  if varprice-base-other     < 0                      or varprice-base-other     = ? then do: message "Неверная ценовая компонента прочего расхода в базовой валюте: "                varprice-base-other     view-as alert-box. apply "entry" to varprice-base-other     in frame Dialog-Frame. return no-apply. end.
  if varsum-base-other       < 0                      or varsum-base-other       = ? then do: message "Неверная сумма прочего расхода в базовой валюте: "                             varsum-base-other       view-as alert-box. apply "entry" to varsum-base-other       in frame Dialog-Frame. return no-apply. end.
  if varprice-rubl-other     < 0                      or varprice-rubl-other     = ? then do: message "Неверная ценовая компонента прочего расхода в рублях: "                        varprice-rubl-other     view-as alert-box. apply "entry" to varprice-rubl-other     in frame Dialog-Frame. return no-apply. end.
  if varsum-rubl-other       < 0                      or varsum-rubl-other       = ? then do: message "Неверная сумма прочего расхода в рублях: "                                     varsum-rubl-other       view-as alert-box. apply "entry" to varsum-rubl-other       in frame Dialog-Frame. return no-apply. end.
  assign
    parprice-base         = varprice-base
    parsum-base           = varsum-base
    parprice-rubl         = varprice-rubl
    parsum-rubl           = varsum-rubl
    parprice-cli          = varprice-cli
    parsum-cli            = varsum-cli
    parvat-pc             = varvat-pc
    parvat-base           = varprice-base-vat
    parsum-vat-base       = varsum-base-vat
    parvat-rubl           = varprice-rubl-vat
    parsum-vat-rubl       = varsum-rubl-vat
    parvat-cli            = varprice-cli-vat
    parsum-vat-cli        = varsum-cli-vat
    parslt-pc             = varslt-pc
    parslt-base           = varprice-base-slt
    parsum-slt-base       = varsum-base-slt
    parslt-rubl           = varprice-rubl-slt
    parsum-slt-rubl       = varsum-rubl-slt
    parslt-cli            = varprice-cli-slt
    parsum-slt-cli        = varsum-cli-slt
    parroad-tax-base      = varprice-base-road-tax
    parsum-road-tax-base  = varsum-base-road-tax
    parroad-tax-rubl      = varprice-rubl-road-tax
    parsum-road-tax-rubl  = varsum-rubl-road-tax
    parroad-tax-cli       = varprice-cli-road-tax
    parsum-road-tax-cli   = varsum-cli-road-tax
    partransport-base     = varprice-base-transport
    parsum-transport-base = varsum-base-transport
    partransport-rubl     = varprice-rubl-transport
    parsum-transport-rubl = varsum-rubl-transport
    parother-base         = varprice-base-other
    parsum-other-base     = varsum-base-other
    parother-rubl         = varprice-rubl-other
    parsum-other-rubl     = varsum-rubl-other
    parpurch-code         = (IF varpurch-code-name <> varno-change THEN LOOKUP (varpurch-code-name, 'выкуп,консигнация,ответственное хранение,старая консигнация':U) ELSE ?)
    paris-ok              = true
    .
END.
ON LEAVE OF varbase-rate IN FRAME Dialog-Frame
DO:
  if input frame Dialog-Frame varbase-rate <> round (varbase-rate, 4) then do:
    assign
      frame Dialog-Frame
      varbase-rate.
  end.
END.
ON return OF varbase-rate IN FRAME Dialog-Frame
DO:
    return no-apply.
END.
ON LEAVE OF varbase-scale IN FRAME Dialog-Frame
DO:
  if input frame Dialog-Frame varbase-scale <> varbase-scale then do:
    assign
      frame Dialog-Frame
      varbase-scale.
  end.
END.
ON return OF varbase-scale IN FRAME Dialog-Frame
DO:
  return no-apply.
END.
ON return OF varcli-base-rate IN FRAME Dialog-Frame
DO:
  return no-apply.
END.
ON LEAVE OF varexch-rate IN FRAME Dialog-Frame
DO:
  if input frame Dialog-Frame varexch-rate <> round (varexch-rate, 4) then do:
    assign
      frame Dialog-Frame
      varexch-rate.
  end.
END.
ON return OF varexch-rate IN FRAME Dialog-Frame
DO:
  return no-apply.
END.
ON LEAVE OF varexch-scale IN FRAME Dialog-Frame
DO:
  if input frame Dialog-Frame varexch-scale <> varexch-scale then do:
    assign
      frame Dialog-Frame
      varexch-scale.
  end.
END.
ON return OF varexch-scale IN FRAME Dialog-Frame
DO:
  return no-apply.
END.
ON LEAVE OF varprice-base IN FRAME Dialog-Frame
DO:
if input frame Dialog-Frame varprice-base <> varprice-base then do:
  assign
    frame Dialog-Frame varprice-base.
  assign varsum-base = varprice-base / varfact-qnty.
  display varsum-base with frame Dialog-Frame.
end.
END.
ON return OF varprice-base IN FRAME Dialog-Frame
DO:
  return no-apply.
END.
ON ENTRY OF varprice-base-other IN FRAME Dialog-Frame
DO:
  run rate-correct (output varrate-correct) no-error.                             if error-status:error then do:                               message "Ошибка при вызове процедуры rate-correct." skip                                       return-value                                       error-status:get-message(1)                                       error-status:get-message(2)                               view-as alert-box error.                               return no-apply.                             end.                             if varrate-correct = no then do:                               message "Курс в партии не согласован с рублевой и валютной ценой." skip                                       "Рублевая цена: "         varprice-rubl skip                                       "Цена в базовой валюте: " varprice-base skip                                       "Курс базовой валюты: "   varbase-rate  skip                                       "Шкала базовой валюты: "  varbase-scale                                    view-as alert-box information.                               if b-calc-rate:sensitive then do:                                 apply "entry" to b-calc-rate.                              end.                               else do:                                 if b-calc-exch-rate:sensitive then do:                                   apply "entry" to b-calc-exch-rate.                                 end.                                 else do:                                   apply "entry" to varprice-cli.                                end.                               end.                               return no-apply.                             end.
  run rate-exch-correct (output varrate-exch-correct) no-error.                                  if error-status:error then do:                                    message "Ошибка при вызове процедуры rate-exch-correct." skip                                            return-value                                            error-status:get-message(1)                                            error-status:get-message(2)                                    view-as alert-box error.                                    return no-apply.                                  end.                                  if varrate-exch-correct = no then do:                                    message "Курс в партии не согласован с рублевой и ценой в валюте поставщика (договора)." skip                                            "Рублевая цена: "            varprice-rubl    skip                                            "Цена в валюте поставщика: " varprice-cli     skip                                            "Единица поставщика: "       varcli-base-rate skip                                            "Курс валюты поставщика: "   varexch-rate     skip                                            "Шкала валюты поставщика: "  varexch-scale                                    view-as alert-box information.                                    if b-calc-exch-rate:sensitive then do:                                      apply "entry" to b-calc-exch-rate.                                   end.                                    else do:                                      apply "entry" to varprice-cli.                                    end.                                    return no-apply.                                  end.
END.
ON LEAVE OF varprice-base-other IN FRAME Dialog-Frame
DO:
define variable varmem-price-rubl-other like varprice-rubl-other no-undo.
define variable varmem-sum-rubl-other   like varsum-rubl-other   no-undo.
define variable varmem-price-base-other like varprice-base-other no-undo.
define variable varmem-sum-base-other   like varsum-base-other   no-undo.
if input frame Dialog-Frame varprice-base-other <> varprice-base-other then do:
  assign
    varmem-price-rubl-other = varprice-rubl-other
    varmem-sum-rubl-other   = varsum-rubl-other
    varmem-price-base-other = varprice-base-other
    varmem-sum-base-other   = varsum-base-other
  .
  assign frame Dialog-Frame varprice-base-other.
  assign
    varprice-rubl-other = varprice-base-other * varbase-rate / varbase-scale
    varsum-rubl-other   = varprice-rubl-other * varfact-qnty
    varsum-base-other   = varprice-base-other * varfact-qnty
    .
  run chg-abs in this-procedure no-error.
  if error-status:error then do:
    message "Ошибка при установке абсолютных налогов."  skip
            return-value skip
            error-status:get-message(1) skip
            error-status:get-message(2)
    view-as alert-box error.
    assign
      varprice-rubl-other = varmem-price-rubl-other
      varsum-rubl-other   = varmem-sum-rubl-other
      varprice-base-other = varmem-price-base-other
      varsum-base-other   = varmem-sum-base-other
    .
  end.
end.
display varprice-rubl-other varsum-rubl-other varprice-base-other varsum-base-other with frame Dialog-Frame.
END.
ON return OF varprice-base-other IN FRAME Dialog-Frame
DO:
    return no-apply.
END.
ON ENTRY OF varprice-base-road-tax IN FRAME Dialog-Frame
DO:
  run rate-correct (output varrate-correct) no-error.                             if error-status:error then do:                               message "Ошибка при вызове процедуры rate-correct." skip                                       return-value                                       error-status:get-message(1)                                       error-status:get-message(2)                               view-as alert-box error.                               return no-apply.                             end.                             if varrate-correct = no then do:                               message "Курс в партии не согласован с рублевой и валютной ценой." skip                                       "Рублевая цена: "         varprice-rubl skip                                       "Цена в базовой валюте: " varprice-base skip                                       "Курс базовой валюты: "   varbase-rate  skip                                       "Шкала базовой валюты: "  varbase-scale                                    view-as alert-box information.                               if b-calc-rate:sensitive then do:                                 apply "entry" to b-calc-rate.                              end.                               else do:                                 if b-calc-exch-rate:sensitive then do:                                   apply "entry" to b-calc-exch-rate.                                 end.                                 else do:                                   apply "entry" to varprice-cli.                                end.                               end.                               return no-apply.                             end.
  run rate-exch-correct (output varrate-exch-correct) no-error.                                  if error-status:error then do:                                    message "Ошибка при вызове процедуры rate-exch-correct." skip                                            return-value                                            error-status:get-message(1)                                            error-status:get-message(2)                                    view-as alert-box error.                                    return no-apply.                                  end.                                  if varrate-exch-correct = no then do:                                    message "Курс в партии не согласован с рублевой и ценой в валюте поставщика (договора)." skip                                            "Рублевая цена: "            varprice-rubl    skip                                            "Цена в валюте поставщика: " varprice-cli     skip                                            "Единица поставщика: "       varcli-base-rate skip                                            "Курс валюты поставщика: "   varexch-rate     skip                                            "Шкала валюты поставщика: "  varexch-scale                                    view-as alert-box information.                                    if b-calc-exch-rate:sensitive then do:                                      apply "entry" to b-calc-exch-rate.                                   end.                                    else do:                                      apply "entry" to varprice-cli.                                    end.                                    return no-apply.                                  end.
END.
ON LEAVE OF varprice-base-road-tax IN FRAME Dialog-Frame
DO:
define variable varmem-price-rubl-road-tax like varprice-rubl-road-tax no-undo.
define variable varmem-sum-rubl-road-tax   like varsum-rubl-road-tax   no-undo.
define variable varmem-price-base-road-tax like varprice-base-road-tax no-undo.
define variable varmem-sum-base-road-tax   like varsum-base-road-tax   no-undo.
define variable varmem-price-cli-road-tax  like varprice-cli-road-tax  no-undo.
define variable varmem-sum-cli-road-tax    like varsum-cli-road-tax    no-undo.
if input frame Dialog-Frame varprice-base-road-tax <> varprice-base-road-tax then do:
  assign
    varmem-price-rubl-road-tax = varprice-rubl-road-tax
    varmem-sum-rubl-road-tax   = varsum-rubl-road-tax
    varmem-price-base-road-tax = varprice-base-road-tax
    varmem-sum-base-road-tax   = varsum-base-road-tax
    varmem-price-cli-road-tax  = varprice-cli-road-tax
    varmem-sum-cli-road-tax    = varsum-cli-road-tax
  .
  assign frame Dialog-Frame varprice-base-road-tax.
  assign
    varprice-rubl-road-tax = varprice-base-road-tax * varbase-rate / varbase-scale
    varsum-rubl-road-tax   = varprice-rubl-road-tax * varfact-qnty
    varsum-base-road-tax   = varprice-base-road-tax * varfact-qnty
    varprice-cli-road-tax  = varprice-rubl-road-tax / varexch-rate * varexch-scale * varcli-base-rate
    varsum-cli-road-tax    = varprice-rubl-road-tax / varexch-rate * varexch-scale * varfact-qnty
    .
  run chg-abs in this-procedure no-error.
  if error-status:error then do:
    message "Ошибка при установке абсолютных налогов."  skip
            return-value skip
            error-status:get-message(1) skip
            error-status:get-message(2)
    view-as alert-box error.
    assign
      varprice-rubl-road-tax = varmem-price-rubl-road-tax
      varsum-rubl-road-tax   = varmem-sum-rubl-road-tax
      varprice-base-road-tax = varmem-price-base-road-tax
      varsum-base-road-tax   = varmem-sum-base-road-tax
      varprice-cli-road-tax  = varmem-price-cli-road-tax
      varsum-cli-road-tax    = varmem-sum-cli-road-tax
    .
  end.
end.
display varprice-rubl-road-tax varsum-rubl-road-tax varprice-base-road-tax varsum-base-road-tax varprice-cli-road-tax varsum-cli-road-tax with frame Dialog-Frame.
END.
ON return OF varprice-base-road-tax IN FRAME Dialog-Frame
DO:
    return no-apply.
END.
ON ENTRY OF varprice-base-slt IN FRAME Dialog-Frame
DO:
  run rate-correct (output varrate-correct) no-error.                             if error-status:error then do:                               message "Ошибка при вызове процедуры rate-correct." skip                                       return-value                                       error-status:get-message(1)                                       error-status:get-message(2)                               view-as alert-box error.                               return no-apply.                             end.                             if varrate-correct = no then do:                               message "Курс в партии не согласован с рублевой и валютной ценой." skip                                       "Рублевая цена: "         varprice-rubl skip                                       "Цена в базовой валюте: " varprice-base skip                                       "Курс базовой валюты: "   varbase-rate  skip                                       "Шкала базовой валюты: "  varbase-scale                                    view-as alert-box information.                               if b-calc-rate:sensitive then do:                                 apply "entry" to b-calc-rate.                              end.                               else do:                                 if b-calc-exch-rate:sensitive then do:                                   apply "entry" to b-calc-exch-rate.                                 end.                                 else do:                                   apply "entry" to varprice-cli.                                end.                               end.                               return no-apply.                             end.
  run rate-exch-correct (output varrate-exch-correct) no-error.                                  if error-status:error then do:                                    message "Ошибка при вызове процедуры rate-exch-correct." skip                                            return-value                                            error-status:get-message(1)                                            error-status:get-message(2)                                    view-as alert-box error.                                    return no-apply.                                  end.                                  if varrate-exch-correct = no then do:                                    message "Курс в партии не согласован с рублевой и ценой в валюте поставщика (договора)." skip                                            "Рублевая цена: "            varprice-rubl    skip                                            "Цена в валюте поставщика: " varprice-cli     skip                                            "Единица поставщика: "       varcli-base-rate skip                                            "Курс валюты поставщика: "   varexch-rate     skip                                            "Шкала валюты поставщика: "  varexch-scale                                    view-as alert-box information.                                    if b-calc-exch-rate:sensitive then do:                                      apply "entry" to b-calc-exch-rate.                                   end.                                    else do:                                      apply "entry" to varprice-cli.                                    end.                                    return no-apply.                                  end.
END.
ON LEAVE OF varprice-base-slt IN FRAME Dialog-Frame
DO:
define variable varmem-price-rubl-slt like ub.doc-line.price-rubl no-undo.
define variable varmem-sum-rubl-slt   like ub.doc-line.price-rubl no-undo.
define variable varmem-price-base-slt like ub.doc-line.price-rubl no-undo.
define variable varmem-sum-base-slt   like ub.doc-line.price-rubl no-undo.
define variable varmem-price-cli-slt  like ub.doc-line.price-rubl no-undo.
define variable varmem-sum-cli-slt    like ub.doc-line.price-rubl no-undo.
define variable varmem-slt-pc         like ub.doc-line.vat-pc     no-undo.
if input frame Dialog-Frame varprice-base-slt <> varprice-base-slt then do:
  assign
    varmem-price-rubl-slt = varprice-rubl-slt
    varmem-sum-rubl-slt   = varsum-rubl-slt
    varmem-price-base-slt = varprice-base-slt
    varmem-sum-base-slt   = varsum-base-slt
    varmem-price-cli-slt  = varprice-cli-slt
    varmem-sum-cli-slt    = varsum-cli-slt
    varmem-slt-pc         = varslt-pc
   .
  assign frame Dialog-Frame
    varprice-base-slt.
  assign
    varsum-base-slt   = varprice-base-slt * varfact-qnty
    varprice-rubl-slt = varprice-base-slt * varbase-rate / varbase-scale
    varsum-rubl-slt   = varprice-rubl-slt * varfact-qnty
    varprice-cli-slt  = varprice-rubl-slt / varexch-rate * varexch-scale * varcli-base-rate
    varsum-cli-slt    = varprice-rubl-slt / varexch-rate * varexch-scale * varfact-qnty
    varslt-pc         = (varprice-base-slt / (varprice-base - varprice-base-other - varprice-base-transport - varprice-base-road-tax - varprice-base-slt)) * 100
  .
  run chg-slt-pc in this-procedure no-error.
  if error-status:error then do:
    message "Ошибка при изменении процента НП." skip
            return-value skip
            error-status:get-message(1)
    view-as alert-box.
    assign
     varprice-rubl-slt = varmem-price-rubl-slt
     varsum-rubl-slt   = varmem-sum-rubl-slt
     varprice-base-slt = varmem-price-base-slt
     varsum-base-slt   = varmem-sum-base-slt
     varprice-cli-slt  = varmem-price-cli-slt
     varsum-cli-slt    = varmem-sum-cli-slt
     varslt-pc         = varmem-slt-pc
     .
    display varprice-rubl-slt varsum-rubl-slt varprice-base-slt varsum-base-slt varprice-cli-slt varsum-cli-slt varslt-pc with frame Dialog-Frame.
  end.
  display varslt-pc with frame Dialog-Frame.
end.
END.
ON return OF varprice-base-slt IN FRAME Dialog-Frame
DO:
    return no-apply.
END.
ON ENTRY OF varprice-base-transport IN FRAME Dialog-Frame
DO:
  run rate-correct (output varrate-correct) no-error.                             if error-status:error then do:                               message "Ошибка при вызове процедуры rate-correct." skip                                       return-value                                       error-status:get-message(1)                                       error-status:get-message(2)                               view-as alert-box error.                               return no-apply.                             end.                             if varrate-correct = no then do:                               message "Курс в партии не согласован с рублевой и валютной ценой." skip                                       "Рублевая цена: "         varprice-rubl skip                                       "Цена в базовой валюте: " varprice-base skip                                       "Курс базовой валюты: "   varbase-rate  skip                                       "Шкала базовой валюты: "  varbase-scale                                    view-as alert-box information.                               if b-calc-rate:sensitive then do:                                 apply "entry" to b-calc-rate.                              end.                               else do:                                 if b-calc-exch-rate:sensitive then do:                                   apply "entry" to b-calc-exch-rate.                                 end.                                 else do:                                   apply "entry" to varprice-cli.                                end.                               end.                               return no-apply.                             end.
  run rate-exch-correct (output varrate-exch-correct) no-error.                                  if error-status:error then do:                                    message "Ошибка при вызове процедуры rate-exch-correct." skip                                            return-value                                            error-status:get-message(1)                                            error-status:get-message(2)                                    view-as alert-box error.                                    return no-apply.                                  end.                                  if varrate-exch-correct = no then do:                                    message "Курс в партии не согласован с рублевой и ценой в валюте поставщика (договора)." skip                                            "Рублевая цена: "            varprice-rubl    skip                                            "Цена в валюте поставщика: " varprice-cli     skip                                            "Единица поставщика: "       varcli-base-rate skip                                            "Курс валюты поставщика: "   varexch-rate     skip                                            "Шкала валюты поставщика: "  varexch-scale                                    view-as alert-box information.                                    if b-calc-exch-rate:sensitive then do:                                      apply "entry" to b-calc-exch-rate.                                   end.                                    else do:                                      apply "entry" to varprice-cli.                                    end.                                    return no-apply.                                  end.
END.
ON LEAVE OF varprice-base-transport IN FRAME Dialog-Frame
DO:
define variable varmem-price-rubl-transport like varprice-rubl-transport no-undo.
define variable varmem-sum-rubl-transport   like varsum-rubl-transport   no-undo.
define variable varmem-price-base-transport like varprice-base-transport no-undo.
define variable varmem-sum-base-transport   like varsum-base-transport   no-undo.
if input frame Dialog-Frame varprice-base-transport <> varprice-base-transport then do:
  assign
    varmem-price-rubl-transport = varprice-rubl-transport
    varmem-sum-rubl-transport   = varsum-rubl-transport
    varmem-price-base-transport = varprice-base-transport
    varmem-sum-base-transport   = varsum-base-transport
  .
  assign frame Dialog-Frame varprice-base-transport.
  assign
    varprice-rubl-transport = varprice-base-transport * varbase-rate / varbase-scale
    varsum-rubl-transport   = varprice-rubl-transport * varfact-qnty
    varsum-base-transport   = varprice-base-transport * varfact-qnty
    .
  run chg-abs in this-procedure no-error.
  if error-status:error then do:
    message "Ошибка при установке абсолютных налогов."  skip
            return-value skip
            error-status:get-message(1) skip
            error-status:get-message(2)
    view-as alert-box error.
    assign
      varprice-rubl-transport = varmem-price-rubl-transport
      varsum-rubl-transport   = varmem-sum-rubl-transport
      varprice-base-transport = varmem-price-base-transport
      varsum-base-transport   = varmem-sum-base-transport
    .
  end.
end.
display varprice-rubl-transport varsum-rubl-transport varprice-base-transport varsum-base-transport with frame Dialog-Frame.
END.
ON return OF varprice-base-transport IN FRAME Dialog-Frame
DO:
    return no-apply.
END.
ON ENTRY OF varprice-base-vat IN FRAME Dialog-Frame
DO:
  run rate-correct (output varrate-correct) no-error.                             if error-status:error then do:                               message "Ошибка при вызове процедуры rate-correct." skip                                       return-value                                       error-status:get-message(1)                                       error-status:get-message(2)                               view-as alert-box error.                               return no-apply.                             end.                             if varrate-correct = no then do:                               message "Курс в партии не согласован с рублевой и валютной ценой." skip                                       "Рублевая цена: "         varprice-rubl skip                                       "Цена в базовой валюте: " varprice-base skip                                       "Курс базовой валюты: "   varbase-rate  skip                                       "Шкала базовой валюты: "  varbase-scale                                    view-as alert-box information.                               if b-calc-rate:sensitive then do:                                 apply "entry" to b-calc-rate.                              end.                               else do:                                 if b-calc-exch-rate:sensitive then do:                                   apply "entry" to b-calc-exch-rate.                                 end.                                 else do:                                   apply "entry" to varprice-cli.                                end.                               end.                               return no-apply.                             end.
  run rate-exch-correct (output varrate-exch-correct) no-error.                                  if error-status:error then do:                                    message "Ошибка при вызове процедуры rate-exch-correct." skip                                            return-value                                            error-status:get-message(1)                                            error-status:get-message(2)                                    view-as alert-box error.                                    return no-apply.                                  end.                                  if varrate-exch-correct = no then do:                                    message "Курс в партии не согласован с рублевой и ценой в валюте поставщика (договора)." skip                                            "Рублевая цена: "            varprice-rubl    skip                                            "Цена в валюте поставщика: " varprice-cli     skip                                            "Единица поставщика: "       varcli-base-rate skip                                            "Курс валюты поставщика: "   varexch-rate     skip                                            "Шкала валюты поставщика: "  varexch-scale                                    view-as alert-box information.                                    if b-calc-exch-rate:sensitive then do:                                      apply "entry" to b-calc-exch-rate.                                   end.                                    else do:                                      apply "entry" to varprice-cli.                                    end.                                    return no-apply.                                  end.
END.
ON LEAVE OF varprice-base-vat IN FRAME Dialog-Frame
DO:
if input frame Dialog-Frame varprice-base-vat <> varprice-base-vat then do:
if (input frame Dialog-Frame varprice-base-vat / (varprice-base - varother-base - vartransport-base - varroad-tax-base - varprice-base-slt - varprice-base-vat)) * 100 < 0   or
   (input frame Dialog-Frame varprice-base-vat / (varprice-base - varother-base - vartransport-base - varroad-tax-base - varprice-base-slt - varprice-base-vat)) * 100 > 100 then do:
   message "При такой ценовой компоненте НДС получится неверный процент НДС: " (input frame Dialog-Frame varprice-base-vat / (varprice-base - varother-base - vartransport-base - varroad-tax-base - varprice-base-slt - varprice-base-vat)) * 100 " ."
   view-as alert-box.
   return no-apply.
end.
run calc-price-base-vat in this-procedure.
end.
END.
ON return OF varprice-base-vat IN FRAME Dialog-Frame
DO:
  return no-apply.
END.
ON LEAVE OF varprice-cli IN FRAME Dialog-Frame
DO:
define variable varmemprice-cli like varprice-cli no-undo.
if input frame Dialog-Frame varprice-cli <> varprice-cli then do:
   assign
     varmemprice-cli = varprice-cli.
  assign
    frame Dialog-Frame
    varprice-cli.
  if varexcheqrubl = yes then do:
    run proc-calc-rubl-cli in this-procedure no-error.
    if error-status:error then do:
      message "Ошибка при пересчете части в рублях." skip
              return-value
      view-as alert-box error.
      assign
        varprice-cli = varmemprice-cli.
    end.
  end.
  if varexcheqbase = yes then do:
    run proc-calc-baseeqcli in this-procedure no-error.
    if error-status:error then do:
       message "Ошибка при пересчете части в базовой валюте." skip
               return-value
       view-as alert-box error.
       assign
         varprice-cli = varmemprice-cli.
    end.
  end.
  assign varsum-cli = (varprice-cli + varprice-cli-road-tax +
                       (if varvat-type <> 'в т. ч.':U then varprice-cli-vat else 0) +
                       (if varslt-type <> 'в т. ч.':U then varprice-cli-slt else 0)
                      ) * varfact-qnty / varcli-base-rate.
  display varsum-cli with frame Dialog-Frame.
end.
END.
ON return OF varprice-cli IN FRAME Dialog-Frame
DO:
  return no-apply.
END.
ON ENTRY OF varprice-cli-road-tax IN FRAME Dialog-Frame
DO:
  run rate-correct (output varrate-correct) no-error.                             if error-status:error then do:                               message "Ошибка при вызове процедуры rate-correct." skip                                       return-value                                       error-status:get-message(1)                                       error-status:get-message(2)                               view-as alert-box error.                               return no-apply.                             end.                             if varrate-correct = no then do:                               message "Курс в партии не согласован с рублевой и валютной ценой." skip                                       "Рублевая цена: "         varprice-rubl skip                                       "Цена в базовой валюте: " varprice-base skip                                       "Курс базовой валюты: "   varbase-rate  skip                                       "Шкала базовой валюты: "  varbase-scale                                    view-as alert-box information.                               if b-calc-rate:sensitive then do:                                 apply "entry" to b-calc-rate.                              end.                               else do:                                 if b-calc-exch-rate:sensitive then do:                                   apply "entry" to b-calc-exch-rate.                                 end.                                 else do:                                   apply "entry" to varprice-cli.                                end.                               end.                               return no-apply.                             end.
  run rate-exch-correct (output varrate-exch-correct) no-error.                                  if error-status:error then do:                                    message "Ошибка при вызове процедуры rate-exch-correct." skip                                            return-value                                            error-status:get-message(1)                                            error-status:get-message(2)                                    view-as alert-box error.                                    return no-apply.                                  end.                                  if varrate-exch-correct = no then do:                                    message "Курс в партии не согласован с рублевой и ценой в валюте поставщика (договора)." skip                                            "Рублевая цена: "            varprice-rubl    skip                                            "Цена в валюте поставщика: " varprice-cli     skip                                            "Единица поставщика: "       varcli-base-rate skip                                            "Курс валюты поставщика: "   varexch-rate     skip                                            "Шкала валюты поставщика: "  varexch-scale                                    view-as alert-box information.                                    if b-calc-exch-rate:sensitive then do:                                      apply "entry" to b-calc-exch-rate.                                   end.                                    else do:                                      apply "entry" to varprice-cli.                                    end.                                    return no-apply.                                  end.
END.
ON LEAVE OF varprice-cli-road-tax IN FRAME Dialog-Frame
DO:
define variable varmem-price-rubl-road-tax like varprice-rubl-road-tax no-undo.
define variable varmem-sum-rubl-road-tax   like varsum-rubl-road-tax   no-undo.
define variable varmem-price-base-road-tax like varprice-base-road-tax no-undo.
define variable varmem-sum-base-road-tax   like varsum-base-road-tax   no-undo.
define variable varmem-price-cli-road-tax  like varprice-cli-road-tax  no-undo.
define variable varmem-sum-cli-road-tax    like varsum-cli-road-tax    no-undo.
if input frame Dialog-Frame varprice-cli-road-tax <> varprice-cli-road-tax then do:
  assign
    varmem-price-rubl-road-tax = varprice-rubl-road-tax
    varmem-sum-rubl-road-tax   = varsum-rubl-road-tax
    varmem-price-base-road-tax = varprice-base-road-tax
    varmem-sum-base-road-tax   = varsum-base-road-tax
    varmem-price-cli-road-tax  = varprice-cli-road-tax
    varmem-sum-cli-road-tax    = varsum-cli-road-tax
  .
  assign frame Dialog-Frame varprice-cli-road-tax.
  assign
    varprice-rubl-road-tax = varprice-cli-road-tax  / varcli-base-rate * varexch-rate / varexch-scale
    varsum-rubl-road-tax   = varprice-rubl-road-tax * varfact-qnty
    varsum-cli-road-tax    = varprice-cli-road-tax / varcli-base-rate * varfact-qnty
    varprice-base-road-tax = varprice-rubl-road-tax / varbase-rate * varbase-scale
    varsum-base-road-tax   = varprice-base-road-tax * varfact-qnty
    .
  run chg-abs in this-procedure no-error.
  if error-status:error then do:
    message "Ошибка при установке абсолютных налогов."  skip
            return-value skip
            error-status:get-message(1) skip
            error-status:get-message(2)
    view-as alert-box error.
    assign
      varprice-rubl-road-tax = varmem-price-rubl-road-tax
      varsum-rubl-road-tax   = varmem-sum-rubl-road-tax
      varprice-base-road-tax = varmem-price-base-road-tax
      varsum-base-road-tax   = varmem-sum-base-road-tax
      varprice-cli-road-tax  = varmem-price-cli-road-tax
      varsum-cli-road-tax    = varmem-sum-cli-road-tax
    .
  end.
end.
display varprice-rubl-road-tax varsum-rubl-road-tax varprice-base-road-tax varsum-base-road-tax varprice-cli-road-tax varsum-cli-road-tax with frame Dialog-Frame.
END.
ON return OF varprice-cli-road-tax IN FRAME Dialog-Frame
DO:
  return no-apply.
END.
ON ENTRY OF varprice-cli-slt IN FRAME Dialog-Frame
DO:
  run rate-correct (output varrate-correct) no-error.                             if error-status:error then do:                               message "Ошибка при вызове процедуры rate-correct." skip                                       return-value                                       error-status:get-message(1)                                       error-status:get-message(2)                               view-as alert-box error.                               return no-apply.                             end.                             if varrate-correct = no then do:                               message "Курс в партии не согласован с рублевой и валютной ценой." skip                                       "Рублевая цена: "         varprice-rubl skip                                       "Цена в базовой валюте: " varprice-base skip                                       "Курс базовой валюты: "   varbase-rate  skip                                       "Шкала базовой валюты: "  varbase-scale                                    view-as alert-box information.                               if b-calc-rate:sensitive then do:                                 apply "entry" to b-calc-rate.                              end.                               else do:                                 if b-calc-exch-rate:sensitive then do:                                   apply "entry" to b-calc-exch-rate.                                 end.                                 else do:                                   apply "entry" to varprice-cli.                                end.                               end.                               return no-apply.                             end.
  run rate-exch-correct (output varrate-exch-correct) no-error.                                  if error-status:error then do:                                    message "Ошибка при вызове процедуры rate-exch-correct." skip                                            return-value                                            error-status:get-message(1)                                            error-status:get-message(2)                                    view-as alert-box error.                                    return no-apply.                                  end.                                  if varrate-exch-correct = no then do:                                    message "Курс в партии не согласован с рублевой и ценой в валюте поставщика (договора)." skip                                            "Рублевая цена: "            varprice-rubl    skip                                            "Цена в валюте поставщика: " varprice-cli     skip                                            "Единица поставщика: "       varcli-base-rate skip                                            "Курс валюты поставщика: "   varexch-rate     skip                                            "Шкала валюты поставщика: "  varexch-scale                                    view-as alert-box information.                                    if b-calc-exch-rate:sensitive then do:                                      apply "entry" to b-calc-exch-rate.                                   end.                                    else do:                                      apply "entry" to varprice-cli.                                    end.                                    return no-apply.                                  end.
END.
ON LEAVE OF varprice-cli-slt IN FRAME Dialog-Frame
DO:
define variable varmem-price-rubl-slt like ub.doc-line.price-rubl no-undo.
define variable varmem-sum-rubl-slt   like ub.doc-line.price-rubl no-undo.
define variable varmem-price-base-slt like ub.doc-line.price-rubl no-undo.
define variable varmem-sum-base-slt   like ub.doc-line.price-rubl no-undo.
define variable varmem-price-cli-slt  like ub.doc-line.price-rubl no-undo.
define variable varmem-sum-cli-slt    like ub.doc-line.price-rubl no-undo.
define variable varmem-slt-pc         like ub.doc-line.vat-pc     no-undo.
if input frame Dialog-Frame varprice-cli-slt <> varprice-cli-slt then do:
  assign
    varmem-price-rubl-slt = varprice-rubl-slt
    varmem-sum-rubl-slt   = varsum-rubl-slt
    varmem-price-base-slt = varprice-base-slt
    varmem-sum-base-slt   = varsum-base-slt
    varmem-price-cli-slt  = varprice-cli-slt
    varmem-sum-cli-slt    = varsum-cli-slt
    varmem-slt-pc         = varslt-pc
   .
  assign frame Dialog-Frame
    varprice-cli-slt.
  assign
    varsum-cli-slt    = varprice-cli-slt / varcli-base-rate * varfact-qnty
    varprice-rubl-slt = varprice-cli-slt / varcli-base-rate * varexch-rate / varexch-scale
    varsum-rubl-slt   = varprice-rubl-slt * varfact-qnty
    varprice-base-slt = varprice-rubl-slt / varbase-rate * varbase-scale
    varsum-base-slt   = varprice-base-slt * varfact-qnty
    varslt-pc         = varprice-cli-slt / (varprice-cli + varprice-cli-road-tax + (if varvat-type <> 'в т. ч.':U then varprice-cli-vat else 0) + (if varslt-type <> 'в т. ч.':U then varprice-cli-slt else 0) - varprice-cli-slt) * 100
  .
  run chg-slt-pc in this-procedure no-error.
  if error-status:error then do:
    message "Ошибка при изменении процента НП." skip
            return-value skip
            error-status:get-message(1)
    view-as alert-box.
    assign
     varprice-rubl-slt = varmem-price-rubl-slt
     varsum-rubl-slt   = varmem-sum-rubl-slt
     varprice-base-slt = varmem-price-base-slt
     varsum-base-slt   = varmem-sum-base-slt
     varprice-cli-slt  = varmem-price-cli-slt
     varsum-cli-slt    = varmem-sum-cli-slt
     varslt-pc         = varmem-slt-pc
     .
    display varprice-rubl-slt varsum-rubl-slt varprice-base-slt varsum-base-slt varprice-cli-slt varsum-cli-slt varslt-pc with frame Dialog-Frame.
  end.
  display varslt-pc with frame Dialog-Frame.
end.
END.
ON return OF varprice-cli-slt IN FRAME Dialog-Frame
DO:
    return no-apply.
END.
ON ENTRY OF varprice-cli-vat IN FRAME Dialog-Frame
DO:
  run rate-correct (output varrate-correct) no-error.                             if error-status:error then do:                               message "Ошибка при вызове процедуры rate-correct." skip                                       return-value                                       error-status:get-message(1)                                       error-status:get-message(2)                               view-as alert-box error.                               return no-apply.                             end.                             if varrate-correct = no then do:                               message "Курс в партии не согласован с рублевой и валютной ценой." skip                                       "Рублевая цена: "         varprice-rubl skip                                       "Цена в базовой валюте: " varprice-base skip                                       "Курс базовой валюты: "   varbase-rate  skip                                       "Шкала базовой валюты: "  varbase-scale                                    view-as alert-box information.                               if b-calc-rate:sensitive then do:                                 apply "entry" to b-calc-rate.                              end.                               else do:                                 if b-calc-exch-rate:sensitive then do:                                   apply "entry" to b-calc-exch-rate.                                 end.                                 else do:                                   apply "entry" to varprice-cli.                                end.                               end.                               return no-apply.                             end.
  run rate-exch-correct (output varrate-exch-correct) no-error.                                  if error-status:error then do:                                    message "Ошибка при вызове процедуры rate-exch-correct." skip                                            return-value                                            error-status:get-message(1)                                            error-status:get-message(2)                                    view-as alert-box error.                                    return no-apply.                                  end.                                  if varrate-exch-correct = no then do:                                    message "Курс в партии не согласован с рублевой и ценой в валюте поставщика (договора)." skip                                            "Рублевая цена: "            varprice-rubl    skip                                            "Цена в валюте поставщика: " varprice-cli     skip                                            "Единица поставщика: "       varcli-base-rate skip                                            "Курс валюты поставщика: "   varexch-rate     skip                                            "Шкала валюты поставщика: "  varexch-scale                                    view-as alert-box information.                                    if b-calc-exch-rate:sensitive then do:                                      apply "entry" to b-calc-exch-rate.                                   end.                                    else do:                                      apply "entry" to varprice-cli.                                    end.                                    return no-apply.                                  end.
END.
ON LEAVE OF varprice-cli-vat IN FRAME Dialog-Frame
DO:
if input frame Dialog-Frame varprice-cli-vat <> varprice-cli-vat then do:
if (input frame Dialog-Frame varprice-cli-vat / (varprice-cli + (if varvat-type <> 'в т. ч.':U then varprice-cli-vat else 0) + (if varslt-type <> 'в т. ч.':U then varprice-cli-slt else 0) - varprice-cli-slt - varprice-cli-vat)) * 100 < 0   or
   (input frame Dialog-Frame varprice-cli-vat / (varprice-cli + (if varvat-type <> 'в т. ч.':U then varprice-cli-vat else 0) + (if varslt-type <> 'в т. ч.':U then varprice-cli-slt else 0) - varprice-cli-slt - varprice-cli-vat)) * 100 > 100 then do:
   message "При такой ценовой компоненте НДС получится неверный процент НДС: " (input frame Dialog-Frame varprice-cli-vat / (varprice-cli + (if varvat-type <> 'в т. ч.':U then varprice-cli-vat else 0) + (if varslt-type <> 'в т. ч.':U then varprice-cli-slt else 0) - varprice-cli-slt - varprice-cli-vat)) * 100 " ."
   view-as alert-box.
   return no-apply.
end.
run calc-price-cli-vat in this-procedure.
end.
END.
ON return OF varprice-cli-vat IN FRAME Dialog-Frame
DO:
    return no-apply.
END.
ON LEAVE OF varprice-rubl IN FRAME Dialog-Frame
DO:
define variable varmemprice-rubl like varprice-rubl no-undo.
if input frame Dialog-Frame varprice-rubl <> varprice-rubl then do:
   assign
     varmemprice-rubl = varprice-rubl.
  assign
    frame Dialog-Frame
    varprice-rubl.
  if varbaseeqrubl = yes then do:
    run proc-calc-base-rubl in this-procedure no-error.
    if error-status:error then do:
       message "Ошибка при пересчете валютной части." skip
               return-value
       view-as alert-box error.
       assign
         varprice-rubl = varmemprice-rubl.
    end.
  end.
  assign varsum-rubl = varprice-rubl * varfact-qnty.
  display varsum-rubl with frame Dialog-Frame.
end.
END.
ON return OF varprice-rubl IN FRAME Dialog-Frame
DO:
  return no-apply.
END.
ON ENTRY OF varprice-rubl-other IN FRAME Dialog-Frame
DO:
  run rate-correct (output varrate-correct) no-error.                             if error-status:error then do:                               message "Ошибка при вызове процедуры rate-correct." skip                                       return-value                                       error-status:get-message(1)                                       error-status:get-message(2)                               view-as alert-box error.                               return no-apply.                             end.                             if varrate-correct = no then do:                               message "Курс в партии не согласован с рублевой и валютной ценой." skip                                       "Рублевая цена: "         varprice-rubl skip                                       "Цена в базовой валюте: " varprice-base skip                                       "Курс базовой валюты: "   varbase-rate  skip                                       "Шкала базовой валюты: "  varbase-scale                                    view-as alert-box information.                               if b-calc-rate:sensitive then do:                                 apply "entry" to b-calc-rate.                              end.                               else do:                                 if b-calc-exch-rate:sensitive then do:                                   apply "entry" to b-calc-exch-rate.                                 end.                                 else do:                                   apply "entry" to varprice-cli.                                end.                               end.                               return no-apply.                             end.
  run rate-exch-correct (output varrate-exch-correct) no-error.                                  if error-status:error then do:                                    message "Ошибка при вызове процедуры rate-exch-correct." skip                                            return-value                                            error-status:get-message(1)                                            error-status:get-message(2)                                    view-as alert-box error.                                    return no-apply.                                  end.                                  if varrate-exch-correct = no then do:                                    message "Курс в партии не согласован с рублевой и ценой в валюте поставщика (договора)." skip                                            "Рублевая цена: "            varprice-rubl    skip                                            "Цена в валюте поставщика: " varprice-cli     skip                                            "Единица поставщика: "       varcli-base-rate skip                                            "Курс валюты поставщика: "   varexch-rate     skip                                            "Шкала валюты поставщика: "  varexch-scale                                    view-as alert-box information.                                    if b-calc-exch-rate:sensitive then do:                                      apply "entry" to b-calc-exch-rate.                                   end.                                    else do:                                      apply "entry" to varprice-cli.                                    end.                                    return no-apply.                                  end.
END.
ON LEAVE OF varprice-rubl-other IN FRAME Dialog-Frame
DO:
define variable varmem-price-rubl-other  like varprice-rubl-other no-undo.
define variable varmem-sum-rubl-other    like varsum-rubl-other no-undo.
define variable varmem-price-base-other  like varprice-base-other no-undo.
define variable varmem-sum-base-other    like varsum-base-other no-undo.
if input frame Dialog-Frame varprice-rubl-other <> varprice-rubl-other then do:
  assign
    varmem-price-rubl-other = varprice-rubl-other
    varmem-sum-rubl-other   = varsum-rubl-other
    varmem-price-base-other = varprice-base-other
    varmem-sum-base-other   = varsum-base-other
    .
  assign frame Dialog-Frame varprice-rubl-other.
  assign
    varsum-rubl-other   = varprice-rubl-other * varfact-qnty
    varprice-base-other = varprice-rubl-other / varbase-rate * varbase-scale
    varsum-base-other   = varprice-base-other * varfact-qnty
  .
  run chg-abs in this-procedure no-error.
  if error-status:error then do:
    message "Ошибка при установке абсолютных налогов."  skip
            return-value skip
            error-status:get-message(1) skip
            error-status:get-message(2)
    view-as alert-box error.
    assign
    varprice-rubl-other = varmem-price-rubl-other
    varsum-rubl-other   = varmem-sum-rubl-other
    varprice-base-other = varmem-price-base-other
    varsum-base-other   = varmem-sum-base-other
.
end.
end.
display varprice-rubl-other varsum-rubl-other varprice-base-other varsum-base-other with frame Dialog-Frame.
END.
ON return OF varprice-rubl-other IN FRAME Dialog-Frame
DO:
    return no-apply.
END.
ON ENTRY OF varprice-rubl-road-tax IN FRAME Dialog-Frame
DO:
  run rate-correct (output varrate-correct) no-error.                             if error-status:error then do:                               message "Ошибка при вызове процедуры rate-correct." skip                                       return-value                                       error-status:get-message(1)                                       error-status:get-message(2)                               view-as alert-box error.                               return no-apply.                             end.                             if varrate-correct = no then do:                               message "Курс в партии не согласован с рублевой и валютной ценой." skip                                       "Рублевая цена: "         varprice-rubl skip                                       "Цена в базовой валюте: " varprice-base skip                                       "Курс базовой валюты: "   varbase-rate  skip                                       "Шкала базовой валюты: "  varbase-scale                                    view-as alert-box information.                               if b-calc-rate:sensitive then do:                                 apply "entry" to b-calc-rate.                              end.                               else do:                                 if b-calc-exch-rate:sensitive then do:                                   apply "entry" to b-calc-exch-rate.                                 end.                                 else do:                                   apply "entry" to varprice-cli.                                end.                               end.                               return no-apply.                             end.
  run rate-exch-correct (output varrate-exch-correct) no-error.                                  if error-status:error then do:                                    message "Ошибка при вызове процедуры rate-exch-correct." skip                                            return-value                                            error-status:get-message(1)                                            error-status:get-message(2)                                    view-as alert-box error.                                    return no-apply.                                  end.                                  if varrate-exch-correct = no then do:                                    message "Курс в партии не согласован с рублевой и ценой в валюте поставщика (договора)." skip                                            "Рублевая цена: "            varprice-rubl    skip                                            "Цена в валюте поставщика: " varprice-cli     skip                                            "Единица поставщика: "       varcli-base-rate skip                                            "Курс валюты поставщика: "   varexch-rate     skip                                            "Шкала валюты поставщика: "  varexch-scale                                    view-as alert-box information.                                    if b-calc-exch-rate:sensitive then do:                                      apply "entry" to b-calc-exch-rate.                                   end.                                    else do:                                      apply "entry" to varprice-cli.                                    end.                                    return no-apply.                                  end.
END.
ON LEAVE OF varprice-rubl-road-tax IN FRAME Dialog-Frame
DO:
define variable varmem-price-rubl-road-tax  like varprice-rubl-road-tax no-undo.
define variable varmem-sum-rubl-road-tax    like varsum-rubl-road-tax no-undo.
define variable varmem-price-base-road-tax  like varprice-base-road-tax no-undo.
define variable varmem-sum-base-road-tax    like varsum-base-road-tax no-undo.
define variable varmem-price-cli-road-tax   like varprice-base-road-tax no-undo.
define variable varmem-sum-cli-road-tax     like varsum-base-road-tax no-undo.
if input frame Dialog-Frame varprice-rubl-road-tax <> varprice-rubl-road-tax then do:
  assign
    varmem-price-rubl-road-tax = varprice-rubl-road-tax
    varmem-sum-rubl-road-tax   = varsum-rubl-road-tax
    varmem-price-base-road-tax = varprice-base-road-tax
    varmem-sum-base-road-tax   = varsum-base-road-tax
    varmem-price-cli-road-tax  = varprice-cli-road-tax
    varmem-sum-cli-road-tax    = varsum-cli-road-tax
    .
  assign frame Dialog-Frame varprice-rubl-road-tax.
  assign
    varsum-rubl-road-tax   = varprice-rubl-road-tax * varfact-qnty
    varprice-base-road-tax = varprice-rubl-road-tax / varbase-rate * varbase-scale
    varsum-base-road-tax   = varprice-base-road-tax * varfact-qnty
    varprice-cli-road-tax  = varprice-rubl-road-tax / varexch-rate * varexch-scale * varcli-base-rate
    varsum-cli-road-tax    = varprice-rubl-road-tax / varexch-rate * varexch-scale * varfact-qnty.
  run chg-abs in this-procedure no-error.
  if error-status:error then do:
    message "Ошибка при установке абсолютных налогов."  skip
            return-value skip
            error-status:get-message(1) skip
            error-status:get-message(2)
    view-as alert-box error.
    assign
    varprice-rubl-road-tax = varmem-price-rubl-road-tax
    varsum-rubl-road-tax   = varmem-sum-rubl-road-tax
    varprice-base-road-tax = varmem-price-base-road-tax
    varsum-base-road-tax   = varmem-sum-base-road-tax
    varprice-cli-road-tax  = varmem-price-cli-road-tax
    varsum-cli-road-tax    = varmem-sum-cli-road-tax
.
end.
end.
display varprice-rubl-road-tax varsum-rubl-road-tax varprice-base-road-tax varsum-base-road-tax varprice-cli-road-tax varsum-cli-road-tax with frame Dialog-Frame.
END.
ON return OF varprice-rubl-road-tax IN FRAME Dialog-Frame
DO:
  return no-apply.
END.
ON ENTRY OF varprice-rubl-slt IN FRAME Dialog-Frame
DO:
  run rate-correct (output varrate-correct) no-error.                             if error-status:error then do:                               message "Ошибка при вызове процедуры rate-correct." skip                                       return-value                                       error-status:get-message(1)                                       error-status:get-message(2)                               view-as alert-box error.                               return no-apply.                             end.                             if varrate-correct = no then do:                               message "Курс в партии не согласован с рублевой и валютной ценой." skip                                       "Рублевая цена: "         varprice-rubl skip                                       "Цена в базовой валюте: " varprice-base skip                                       "Курс базовой валюты: "   varbase-rate  skip                                       "Шкала базовой валюты: "  varbase-scale                                    view-as alert-box information.                               if b-calc-rate:sensitive then do:                                 apply "entry" to b-calc-rate.                              end.                               else do:                                 if b-calc-exch-rate:sensitive then do:                                   apply "entry" to b-calc-exch-rate.                                 end.                                 else do:                                   apply "entry" to varprice-cli.                                end.                               end.                               return no-apply.                             end.
  run rate-exch-correct (output varrate-exch-correct) no-error.                                  if error-status:error then do:                                    message "Ошибка при вызове процедуры rate-exch-correct." skip                                            return-value                                            error-status:get-message(1)                                            error-status:get-message(2)                                    view-as alert-box error.                                    return no-apply.                                  end.                                  if varrate-exch-correct = no then do:                                    message "Курс в партии не согласован с рублевой и ценой в валюте поставщика (договора)." skip                                            "Рублевая цена: "            varprice-rubl    skip                                            "Цена в валюте поставщика: " varprice-cli     skip                                            "Единица поставщика: "       varcli-base-rate skip                                            "Курс валюты поставщика: "   varexch-rate     skip                                            "Шкала валюты поставщика: "  varexch-scale                                    view-as alert-box information.                                    if b-calc-exch-rate:sensitive then do:                                      apply "entry" to b-calc-exch-rate.                                   end.                                    else do:                                      apply "entry" to varprice-cli.                                    end.                                    return no-apply.                                  end.
END.
ON LEAVE OF varprice-rubl-slt IN FRAME Dialog-Frame
DO:
define variable varmem-price-rubl-slt like ub.doc-line.price-rubl no-undo.
define variable varmem-sum-rubl-slt   like ub.doc-line.price-rubl no-undo.
define variable varmem-price-base-slt like ub.doc-line.price-rubl no-undo.
define variable varmem-sum-base-slt   like ub.doc-line.price-rubl no-undo.
define variable varmem-price-cli-slt  like ub.doc-line.price-rubl no-undo.
define variable varmem-sum-cli-slt    like ub.doc-line.price-rubl no-undo.
define variable varmem-slt-pc         like ub.doc-line.vat-pc     no-undo.
if input frame Dialog-Frame varprice-rubl-slt <> varprice-rubl-slt then do:
assign
   varmem-price-rubl-slt = varprice-rubl-slt
   varmem-sum-rubl-slt   = varsum-rubl-slt
   varmem-price-base-slt = varprice-base-slt
   varmem-sum-base-slt   = varsum-base-slt
   varmem-price-cli-slt  = varprice-cli-slt
   varmem-sum-cli-slt    = varsum-cli-slt
   varmem-slt-pc         = varslt-pc
   .
assign frame Dialog-Frame
   varprice-rubl-slt.
assign
  varsum-rubl-slt   = varprice-rubl-slt * varfact-qnty
  varprice-base-slt = varprice-rubl-slt / varbase-rate * varbase-scale
  varsum-base-slt   = varprice-base-slt * varfact-qnty
  varprice-cli-slt  = varprice-rubl-slt / varexch-rate * varexch-scale * varcli-base-rate
  varsum-cli-slt    = varprice-rubl-slt / varexch-rate * varexch-scale * varfact-qnty
  varslt-pc         = (varprice-rubl-slt / (varprice-rubl - varprice-rubl-other - varprice-rubl-transport - varprice-rubl-road-tax - varprice-rubl-slt)) * 100
  .
run chg-slt-pc in this-procedure no-error.
if error-status:error then do:
  message "Ошибка при изменении процента НП." skip
          return-value skip
          error-status:get-message(1)
  view-as alert-box.
  assign
   varprice-rubl-slt = varmem-price-rubl-slt
   varsum-rubl-slt   = varmem-sum-rubl-slt
   varprice-base-slt = varmem-price-base-slt
   varsum-base-slt   = varmem-sum-base-slt
   varprice-cli-slt  = varmem-price-cli-slt
   varsum-cli-slt    = varmem-sum-cli-slt
   varslt-pc         = varmem-slt-pc
   .
  display varprice-rubl-slt varsum-rubl-slt varprice-base-slt varsum-base-slt varprice-cli-slt varsum-cli-slt varslt-pc with frame Dialog-Frame.
end.
DISPLAY varslt-pc WITH FRAME Dialog-Frame.
end.
END.
ON return OF varprice-rubl-slt IN FRAME Dialog-Frame
DO:
    return no-apply.
END.
ON ENTRY OF varprice-rubl-transport IN FRAME Dialog-Frame
DO:
  run rate-correct (output varrate-correct) no-error.                             if error-status:error then do:                               message "Ошибка при вызове процедуры rate-correct." skip                                       return-value                                       error-status:get-message(1)                                       error-status:get-message(2)                               view-as alert-box error.                               return no-apply.                             end.                             if varrate-correct = no then do:                               message "Курс в партии не согласован с рублевой и валютной ценой." skip                                       "Рублевая цена: "         varprice-rubl skip                                       "Цена в базовой валюте: " varprice-base skip                                       "Курс базовой валюты: "   varbase-rate  skip                                       "Шкала базовой валюты: "  varbase-scale                                    view-as alert-box information.                               if b-calc-rate:sensitive then do:                                 apply "entry" to b-calc-rate.                              end.                               else do:                                 if b-calc-exch-rate:sensitive then do:                                   apply "entry" to b-calc-exch-rate.                                 end.                                 else do:                                   apply "entry" to varprice-cli.                                end.                               end.                               return no-apply.                             end.
  run rate-exch-correct (output varrate-exch-correct) no-error.                                  if error-status:error then do:                                    message "Ошибка при вызове процедуры rate-exch-correct." skip                                            return-value                                            error-status:get-message(1)                                            error-status:get-message(2)                                    view-as alert-box error.                                    return no-apply.                                  end.                                  if varrate-exch-correct = no then do:                                    message "Курс в партии не согласован с рублевой и ценой в валюте поставщика (договора)." skip                                            "Рублевая цена: "            varprice-rubl    skip                                            "Цена в валюте поставщика: " varprice-cli     skip                                            "Единица поставщика: "       varcli-base-rate skip                                            "Курс валюты поставщика: "   varexch-rate     skip                                            "Шкала валюты поставщика: "  varexch-scale                                    view-as alert-box information.                                    if b-calc-exch-rate:sensitive then do:                                      apply "entry" to b-calc-exch-rate.                                   end.                                    else do:                                      apply "entry" to varprice-cli.                                    end.                                    return no-apply.                                  end.
END.
ON LEAVE OF varprice-rubl-transport IN FRAME Dialog-Frame
DO:
define variable varmem-price-rubl-transport  like varprice-rubl-transport no-undo.
define variable varmem-sum-rubl-transport    like varsum-rubl-transport no-undo.
define variable varmem-price-base-transport  like varprice-base-transport no-undo.
define variable varmem-sum-base-transport    like varsum-base-transport no-undo.
if input frame Dialog-Frame varprice-rubl-transport <> varprice-rubl-transport then do:
  assign
    varmem-price-rubl-transport = varprice-rubl-transport
    varmem-sum-rubl-transport   = varsum-rubl-transport
    varmem-price-base-transport = varprice-base-transport
    varmem-sum-base-transport   = varsum-base-transport
   .
  assign frame Dialog-Frame varprice-rubl-transport.
  assign
    varsum-rubl-transport   = varprice-rubl-transport * varfact-qnty
    varprice-base-transport = varprice-rubl-transport / varbase-rate * varbase-scale
    varsum-base-transport   = varprice-base-transport * varfact-qnty
  .
  run chg-abs in this-procedure no-error.
  if error-status:error then do:
    message "Ошибка при установке абсолютных налогов."  skip
            return-value skip
            error-status:get-message(1) skip
            error-status:get-message(2)
    view-as alert-box error.
    assign
    varprice-rubl-transport = varmem-price-rubl-transport
    varsum-rubl-transport   = varmem-sum-rubl-transport
    varprice-base-transport = varmem-price-base-transport
    varsum-base-transport   = varmem-sum-base-transport
.
end.
end.
display varprice-rubl-transport varsum-rubl-transport varprice-base-transport varsum-base-transport with frame Dialog-Frame.
END.
ON return OF varprice-rubl-transport IN FRAME Dialog-Frame
DO:
  return no-apply.
END.
ON ENTRY OF varprice-rubl-vat IN FRAME Dialog-Frame
DO:
  run rate-correct (output varrate-correct) no-error.                             if error-status:error then do:                               message "Ошибка при вызове процедуры rate-correct." skip                                       return-value                                       error-status:get-message(1)                                       error-status:get-message(2)                               view-as alert-box error.                               return no-apply.                             end.                             if varrate-correct = no then do:                               message "Курс в партии не согласован с рублевой и валютной ценой." skip                                       "Рублевая цена: "         varprice-rubl skip                                       "Цена в базовой валюте: " varprice-base skip                                       "Курс базовой валюты: "   varbase-rate  skip                                       "Шкала базовой валюты: "  varbase-scale                                    view-as alert-box information.                               if b-calc-rate:sensitive then do:                                 apply "entry" to b-calc-rate.                              end.                               else do:                                 if b-calc-exch-rate:sensitive then do:                                   apply "entry" to b-calc-exch-rate.                                 end.                                 else do:                                   apply "entry" to varprice-cli.                                end.                               end.                               return no-apply.                             end.
  run rate-exch-correct (output varrate-exch-correct) no-error.                                  if error-status:error then do:                                    message "Ошибка при вызове процедуры rate-exch-correct." skip                                            return-value                                            error-status:get-message(1)                                            error-status:get-message(2)                                    view-as alert-box error.                                    return no-apply.                                  end.                                  if varrate-exch-correct = no then do:                                    message "Курс в партии не согласован с рублевой и ценой в валюте поставщика (договора)." skip                                            "Рублевая цена: "            varprice-rubl    skip                                            "Цена в валюте поставщика: " varprice-cli     skip                                            "Единица поставщика: "       varcli-base-rate skip                                            "Курс валюты поставщика: "   varexch-rate     skip                                            "Шкала валюты поставщика: "  varexch-scale                                    view-as alert-box information.                                    if b-calc-exch-rate:sensitive then do:                                      apply "entry" to b-calc-exch-rate.                                   end.                                    else do:                                      apply "entry" to varprice-cli.                                    end.                                    return no-apply.                                  end.
END.
ON LEAVE OF varprice-rubl-vat IN FRAME Dialog-Frame
DO:
if input frame Dialog-Frame varprice-rubl-vat <> varprice-rubl-vat then do:
if (input frame Dialog-Frame varprice-rubl-vat / (varprice-rubl - varprice-rubl-other - varprice-rubl-transport - varprice-rubl-road-tax - varprice-rubl-slt - varprice-rubl-vat)) * 100 < 0   or
   (input frame Dialog-Frame varprice-rubl-vat / (varprice-rubl - varprice-rubl-other - varprice-rubl-transport - varprice-rubl-road-tax - varprice-rubl-slt - varprice-rubl-vat)) * 100 > 100 then do:
   message "При такой ценовой компоненте НДС получится неверный процент НДС: " (input frame Dialog-Frame varprice-rubl-vat / (varprice-rubl - varprice-rubl-other - varprice-rubl-transport - varprice-rubl-road-tax - varprice-rubl-slt - varprice-rubl-vat)) * 100 " ."
   view-as alert-box.
   return no-apply.
end.
run calc-price-rubl-vat in this-procedure.
end.
END.
ON return OF varprice-rubl-vat IN FRAME Dialog-Frame
DO:
    return no-apply.
END.
ON VALUE-CHANGED OF varpurch-code-name IN FRAME Dialog-Frame
DO:
  ASSIGN FRAME Dialog-Frame varpurch-code-name.
END.
ON ENTRY OF varslt-pc IN FRAME Dialog-Frame
DO:
  run rate-correct (output varrate-correct) no-error.                             if error-status:error then do:                               message "Ошибка при вызове процедуры rate-correct." skip                                       return-value                                       error-status:get-message(1)                                       error-status:get-message(2)                               view-as alert-box error.                               return no-apply.                             end.                             if varrate-correct = no then do:                               message "Курс в партии не согласован с рублевой и валютной ценой." skip                                       "Рублевая цена: "         varprice-rubl skip                                       "Цена в базовой валюте: " varprice-base skip                                       "Курс базовой валюты: "   varbase-rate  skip                                       "Шкала базовой валюты: "  varbase-scale                                    view-as alert-box information.                               if b-calc-rate:sensitive then do:                                 apply "entry" to b-calc-rate.                              end.                               else do:                                 if b-calc-exch-rate:sensitive then do:                                   apply "entry" to b-calc-exch-rate.                                 end.                                 else do:                                   apply "entry" to varprice-cli.                                end.                               end.                               return no-apply.                             end.
  run rate-exch-correct (output varrate-exch-correct) no-error.                                  if error-status:error then do:                                    message "Ошибка при вызове процедуры rate-exch-correct." skip                                            return-value                                            error-status:get-message(1)                                            error-status:get-message(2)                                    view-as alert-box error.                                    return no-apply.                                  end.                                  if varrate-exch-correct = no then do:                                    message "Курс в партии не согласован с рублевой и ценой в валюте поставщика (договора)." skip                                            "Рублевая цена: "            varprice-rubl    skip                                            "Цена в валюте поставщика: " varprice-cli     skip                                            "Единица поставщика: "       varcli-base-rate skip                                            "Курс валюты поставщика: "   varexch-rate     skip                                            "Шкала валюты поставщика: "  varexch-scale                                    view-as alert-box information.                                    if b-calc-exch-rate:sensitive then do:                                      apply "entry" to b-calc-exch-rate.                                   end.                                    else do:                                      apply "entry" to varprice-cli.                                    end.                                    return no-apply.                                  end.
END.
ON LEAVE OF varslt-pc IN FRAME Dialog-Frame
DO:
define variable varmem-slt-pc like ub.doc-line.slt-pc no-undo.
if input frame Dialog-Frame varslt-pc <> round (varslt-pc, 2) then do:
assign
  varmem-slt-pc = varslt-pc.
assign
   frame Dialog-Frame
   varslt-pc.
run chg-slt-pc in this-procedure no-error.
if error-status:error then do:
  message "Ошибка при изменении процента НП." skip
          return-value skip
          error-status:get-message(1)
  view-as alert-box.
  assign
    varslt-pc = varmem-slt-pc.
  display varslt-pc with frame Dialog-Frame.
end.
end.
END.
ON return OF varslt-pc IN FRAME Dialog-Frame
DO:
    return no-apply.
END.
ON LEAVE OF varsum-base IN FRAME Dialog-Frame
DO:
if input frame Dialog-Frame varsum-base <> varsum-base then do:
  assign frame Dialog-Frame varsum-base.
  assign varprice-base = varsum-base / varfact-qnty.
  display varprice-base with frame Dialog-Frame.
end.
END.
ON return OF varsum-base IN FRAME Dialog-Frame
DO:
    return no-apply.
END.
ON ENTRY OF varsum-base-other IN FRAME Dialog-Frame
DO:
  run rate-correct (output varrate-correct) no-error.                             if error-status:error then do:                               message "Ошибка при вызове процедуры rate-correct." skip                                       return-value                                       error-status:get-message(1)                                       error-status:get-message(2)                               view-as alert-box error.                               return no-apply.                             end.                             if varrate-correct = no then do:                               message "Курс в партии не согласован с рублевой и валютной ценой." skip                                       "Рублевая цена: "         varprice-rubl skip                                       "Цена в базовой валюте: " varprice-base skip                                       "Курс базовой валюты: "   varbase-rate  skip                                       "Шкала базовой валюты: "  varbase-scale                                    view-as alert-box information.                               if b-calc-rate:sensitive then do:                                 apply "entry" to b-calc-rate.                              end.                               else do:                                 if b-calc-exch-rate:sensitive then do:                                   apply "entry" to b-calc-exch-rate.                                 end.                                 else do:                                   apply "entry" to varprice-cli.                                end.                               end.                               return no-apply.                             end.
  run rate-exch-correct (output varrate-exch-correct) no-error.                                  if error-status:error then do:                                    message "Ошибка при вызове процедуры rate-exch-correct." skip                                            return-value                                            error-status:get-message(1)                                            error-status:get-message(2)                                    view-as alert-box error.                                    return no-apply.                                  end.                                  if varrate-exch-correct = no then do:                                    message "Курс в партии не согласован с рублевой и ценой в валюте поставщика (договора)." skip                                            "Рублевая цена: "            varprice-rubl    skip                                            "Цена в валюте поставщика: " varprice-cli     skip                                            "Единица поставщика: "       varcli-base-rate skip                                            "Курс валюты поставщика: "   varexch-rate     skip                                            "Шкала валюты поставщика: "  varexch-scale                                    view-as alert-box information.                                    if b-calc-exch-rate:sensitive then do:                                      apply "entry" to b-calc-exch-rate.                                   end.                                    else do:                                      apply "entry" to varprice-cli.                                    end.                                    return no-apply.                                  end.
END.
ON LEAVE OF varsum-base-other IN FRAME Dialog-Frame
DO:
define variable varmem-price-rubl-other like varprice-rubl-other no-undo.
define variable varmem-sum-rubl-other   like varsum-rubl-other   no-undo.
define variable varmem-price-base-other like varprice-base-other no-undo.
define variable varmem-sum-base-other   like varsum-base-other   no-undo.
if input frame Dialog-Frame varsum-base-other <> varsum-base-other then do:
  assign
    varmem-price-rubl-other = varprice-rubl-other
    varmem-sum-rubl-other   = varsum-rubl-other
    varmem-price-base-other = varprice-base-other
    varmem-sum-base-other   = varsum-base-other
  .
  assign frame Dialog-Frame varsum-base-other.
  assign
    varprice-base-other = varsum-base-other / varfact-qnty
    varprice-rubl-other = varprice-base-other * varbase-rate / varbase-scale
    varsum-rubl-other   = varprice-rubl-other * varfact-qnty
  .
  run chg-abs in this-procedure no-error.
  if error-status:error then do:
    message "Ошибка при установке абсолютных налогов."  skip
            return-value skip
            error-status:get-message(1) skip
            error-status:get-message(2)
    view-as alert-box error.
    assign
    varprice-rubl-other = varmem-price-rubl-other
    varsum-rubl-other   = varmem-sum-rubl-other
    varprice-base-other = varmem-price-base-other
    varsum-base-other   = varmem-sum-base-other
    .
  end.
end.
display varprice-rubl-other varsum-rubl-other varprice-base-other varsum-base-other with frame Dialog-Frame.
END.
ON return OF varsum-base-other IN FRAME Dialog-Frame
DO:
    return no-apply.
END.
ON ENTRY OF varsum-base-road-tax IN FRAME Dialog-Frame
DO:
  run rate-correct (output varrate-correct) no-error.                             if error-status:error then do:                               message "Ошибка при вызове процедуры rate-correct." skip                                       return-value                                       error-status:get-message(1)                                       error-status:get-message(2)                               view-as alert-box error.                               return no-apply.                             end.                             if varrate-correct = no then do:                               message "Курс в партии не согласован с рублевой и валютной ценой." skip                                       "Рублевая цена: "         varprice-rubl skip                                       "Цена в базовой валюте: " varprice-base skip                                       "Курс базовой валюты: "   varbase-rate  skip                                       "Шкала базовой валюты: "  varbase-scale                                    view-as alert-box information.                               if b-calc-rate:sensitive then do:                                 apply "entry" to b-calc-rate.                              end.                               else do:                                 if b-calc-exch-rate:sensitive then do:                                   apply "entry" to b-calc-exch-rate.                                 end.                                 else do:                                   apply "entry" to varprice-cli.                                end.                               end.                               return no-apply.                             end.
  run rate-exch-correct (output varrate-exch-correct) no-error.                                  if error-status:error then do:                                    message "Ошибка при вызове процедуры rate-exch-correct." skip                                            return-value                                            error-status:get-message(1)                                            error-status:get-message(2)                                    view-as alert-box error.                                    return no-apply.                                  end.                                  if varrate-exch-correct = no then do:                                    message "Курс в партии не согласован с рублевой и ценой в валюте поставщика (договора)." skip                                            "Рублевая цена: "            varprice-rubl    skip                                            "Цена в валюте поставщика: " varprice-cli     skip                                            "Единица поставщика: "       varcli-base-rate skip                                            "Курс валюты поставщика: "   varexch-rate     skip                                            "Шкала валюты поставщика: "  varexch-scale                                    view-as alert-box information.                                    if b-calc-exch-rate:sensitive then do:                                      apply "entry" to b-calc-exch-rate.                                   end.                                    else do:                                      apply "entry" to varprice-cli.                                    end.                                    return no-apply.                                  end.
END.
ON LEAVE OF varsum-base-road-tax IN FRAME Dialog-Frame
DO:
define variable varmem-price-rubl-road-tax like varprice-rubl-road-tax no-undo.
define variable varmem-sum-rubl-road-tax   like varsum-rubl-road-tax   no-undo.
define variable varmem-price-base-road-tax like varprice-base-road-tax no-undo.
define variable varmem-sum-base-road-tax   like varsum-base-road-tax   no-undo.
define variable varmem-price-cli-road-tax  like varprice-cli-road-tax  no-undo.
define variable varmem-sum-cli-road-tax    like varsum-cli-road-tax    no-undo.
if input frame Dialog-Frame varsum-base-road-tax <> varsum-base-road-tax then do:
  assign
    varmem-price-rubl-road-tax = varprice-rubl-road-tax
    varmem-sum-rubl-road-tax   = varsum-rubl-road-tax
    varmem-price-base-road-tax = varprice-base-road-tax
    varmem-sum-base-road-tax   = varsum-base-road-tax
    varmem-price-cli-road-tax  = varprice-cli-road-tax
    varmem-sum-cli-road-tax    = varsum-cli-road-tax
  .
  assign frame Dialog-Frame varsum-base-road-tax.
  assign
    varprice-base-road-tax = varsum-base-road-tax / varfact-qnty
    varprice-rubl-road-tax = varprice-base-road-tax * varbase-rate / varbase-scale
    varsum-rubl-road-tax   = varprice-rubl-road-tax * varfact-qnty
    varprice-cli-road-tax  = varprice-rubl-road-tax / varexch-rate * varexch-scale * varcli-base-rate
    varsum-cli-road-tax    = varprice-rubl-road-tax / varexch-rate * varexch-scale * varfact-qnty
  .
  run chg-abs in this-procedure no-error.
  if error-status:error then do:
    message "Ошибка при установке абсолютных налогов."  skip
            return-value skip
            error-status:get-message(1) skip
            error-status:get-message(2)
    view-as alert-box error.
    assign
    varprice-rubl-road-tax = varmem-price-rubl-road-tax
    varsum-rubl-road-tax   = varmem-sum-rubl-road-tax
    varprice-base-road-tax = varmem-price-base-road-tax
    varsum-base-road-tax   = varmem-sum-base-road-tax
    varprice-cli-road-tax  = varmem-price-cli-road-tax
    varsum-cli-road-tax    = varmem-sum-cli-road-tax
    .
  end.
end.
display varprice-rubl-road-tax varsum-rubl-road-tax varprice-base-road-tax varsum-base-road-tax varprice-cli-road-tax varsum-cli-road-tax with frame Dialog-Frame.
END.
ON return OF varsum-base-road-tax IN FRAME Dialog-Frame
DO:
  return no-apply.
END.
ON ENTRY OF varsum-base-slt IN FRAME Dialog-Frame
DO:
  run rate-correct (output varrate-correct) no-error.                             if error-status:error then do:                               message "Ошибка при вызове процедуры rate-correct." skip                                       return-value                                       error-status:get-message(1)                                       error-status:get-message(2)                               view-as alert-box error.                               return no-apply.                             end.                             if varrate-correct = no then do:                               message "Курс в партии не согласован с рублевой и валютной ценой." skip                                       "Рублевая цена: "         varprice-rubl skip                                       "Цена в базовой валюте: " varprice-base skip                                       "Курс базовой валюты: "   varbase-rate  skip                                       "Шкала базовой валюты: "  varbase-scale                                    view-as alert-box information.                               if b-calc-rate:sensitive then do:                                 apply "entry" to b-calc-rate.                              end.                               else do:                                 if b-calc-exch-rate:sensitive then do:                                   apply "entry" to b-calc-exch-rate.                                 end.                                 else do:                                   apply "entry" to varprice-cli.                                end.                               end.                               return no-apply.                             end.
  run rate-exch-correct (output varrate-exch-correct) no-error.                                  if error-status:error then do:                                    message "Ошибка при вызове процедуры rate-exch-correct." skip                                            return-value                                            error-status:get-message(1)                                            error-status:get-message(2)                                    view-as alert-box error.                                    return no-apply.                                  end.                                  if varrate-exch-correct = no then do:                                    message "Курс в партии не согласован с рублевой и ценой в валюте поставщика (договора)." skip                                            "Рублевая цена: "            varprice-rubl    skip                                            "Цена в валюте поставщика: " varprice-cli     skip                                            "Единица поставщика: "       varcli-base-rate skip                                            "Курс валюты поставщика: "   varexch-rate     skip                                            "Шкала валюты поставщика: "  varexch-scale                                    view-as alert-box information.                                    if b-calc-exch-rate:sensitive then do:                                      apply "entry" to b-calc-exch-rate.                                   end.                                    else do:                                      apply "entry" to varprice-cli.                                    end.                                    return no-apply.                                  end.
END.
ON LEAVE OF varsum-base-slt IN FRAME Dialog-Frame
DO:
define variable varmem-price-rubl-slt like ub.doc-line.price-rubl no-undo.
define variable varmem-sum-rubl-slt   like ub.doc-line.price-rubl no-undo.
define variable varmem-price-base-slt like ub.doc-line.price-rubl no-undo.
define variable varmem-sum-base-slt   like ub.doc-line.price-rubl no-undo.
define variable varmem-price-cli-slt  like ub.doc-line.price-rubl no-undo.
define variable varmem-sum-cli-slt    like ub.doc-line.price-rubl no-undo.
define variable varmem-slt-pc         like ub.doc-line.vat-pc no-undo.
if input frame Dialog-Frame varsum-base-slt <> varsum-base-slt then do:
assign
   varmem-price-rubl-slt = varprice-rubl-slt
   varmem-sum-rubl-slt   = varsum-rubl-slt
   varmem-price-base-slt = varprice-base-slt
   varmem-sum-base-slt   = varsum-base-slt
   varmem-price-cli-slt  = varprice-cli-slt
   varmem-sum-cli-slt    = varsum-cli-slt
   varmem-slt-pc         = varslt-pc
   .
assign frame Dialog-Frame
   varsum-base-slt.
assign
  varprice-base-slt = varsum-base-slt / varfact-qnty
  varprice-rubl-slt = varprice-base-slt * varbase-rate / varbase-scale
  varsum-rubl-slt   = varprice-rubl-slt * varfact-qnty
  varprice-cli-slt  = varprice-rubl-slt / varexch-rate * varexch-scale * varcli-base-rate
  varsum-cli-slt    = varprice-rubl-slt / varexch-rate * varexch-scale * varfact-qnty
  varslt-pc         = (varsum-base-slt / (varsum-base - varsum-base-other - varsum-base-transport - varsum-base-road-tax - varsum-base-slt)) * 100
  .
run chg-slt-pc in this-procedure no-error.
if error-status:error then do:
  message "Ошибка при изменении процента НП." skip
          return-value skip
          error-status:get-message(1)
  view-as alert-box.
  assign
   varprice-rubl-slt = varmem-price-rubl-slt
   varsum-rubl-slt   = varmem-sum-rubl-slt
   varprice-base-slt = varmem-price-base-slt
   varsum-base-slt   = varmem-sum-base-slt
   varprice-cli-slt  = varmem-price-cli-slt
   varsum-cli-slt    = varmem-sum-cli-slt
   varslt-pc         = varmem-slt-pc
   .
  display varprice-rubl-slt varsum-rubl-slt varprice-base-slt varsum-base-slt varprice-cli-slt varsum-cli-slt varslt-pc with frame Dialog-Frame.
end.
display varslt-pc with frame Dialog-Frame.
end.
END.
ON return OF varsum-base-slt IN FRAME Dialog-Frame
DO:
  return no-apply.
END.
ON ENTRY OF varsum-base-transport IN FRAME Dialog-Frame
DO:
  run rate-correct (output varrate-correct) no-error.                             if error-status:error then do:                               message "Ошибка при вызове процедуры rate-correct." skip                                       return-value                                       error-status:get-message(1)                                       error-status:get-message(2)                               view-as alert-box error.                               return no-apply.                             end.                             if varrate-correct = no then do:                               message "Курс в партии не согласован с рублевой и валютной ценой." skip                                       "Рублевая цена: "         varprice-rubl skip                                       "Цена в базовой валюте: " varprice-base skip                                       "Курс базовой валюты: "   varbase-rate  skip                                       "Шкала базовой валюты: "  varbase-scale                                    view-as alert-box information.                               if b-calc-rate:sensitive then do:                                 apply "entry" to b-calc-rate.                              end.                               else do:                                 if b-calc-exch-rate:sensitive then do:                                   apply "entry" to b-calc-exch-rate.                                 end.                                 else do:                                   apply "entry" to varprice-cli.                                end.                               end.                               return no-apply.                             end.
  run rate-exch-correct (output varrate-exch-correct) no-error.                                  if error-status:error then do:                                    message "Ошибка при вызове процедуры rate-exch-correct." skip                                            return-value                                            error-status:get-message(1)                                            error-status:get-message(2)                                    view-as alert-box error.                                    return no-apply.                                  end.                                  if varrate-exch-correct = no then do:                                    message "Курс в партии не согласован с рублевой и ценой в валюте поставщика (договора)." skip                                            "Рублевая цена: "            varprice-rubl    skip                                            "Цена в валюте поставщика: " varprice-cli     skip                                            "Единица поставщика: "       varcli-base-rate skip                                            "Курс валюты поставщика: "   varexch-rate     skip                                            "Шкала валюты поставщика: "  varexch-scale                                    view-as alert-box information.                                    if b-calc-exch-rate:sensitive then do:                                      apply "entry" to b-calc-exch-rate.                                   end.                                    else do:                                      apply "entry" to varprice-cli.                                    end.                                    return no-apply.                                  end.
END.
ON LEAVE OF varsum-base-transport IN FRAME Dialog-Frame
DO:
define variable varmem-price-rubl-transport like varprice-rubl-transport no-undo.
define variable varmem-sum-rubl-transport   like varsum-rubl-transport   no-undo.
define variable varmem-price-base-transport like varprice-base-transport no-undo.
define variable varmem-sum-base-transport   like varsum-base-transport   no-undo.
if input frame Dialog-Frame varsum-base-transport <> varsum-base-transport then do:
  assign
    varmem-price-rubl-transport = varprice-rubl-transport
    varmem-sum-rubl-transport   = varsum-rubl-transport
    varmem-price-base-transport = varprice-base-transport
    varmem-sum-base-transport   = varsum-base-transport
  .
  assign frame Dialog-Frame varsum-base-transport.
  assign
    varprice-base-transport = varsum-base-transport / varfact-qnty
    varprice-rubl-transport = varprice-base-transport * varbase-rate / varbase-scale
    varsum-rubl-transport   = varprice-rubl-transport * varfact-qnty
  .
  run chg-abs in this-procedure no-error.
  if error-status:error then do:
    message "Ошибка при установке абсолютных налогов."  skip
            return-value skip
            error-status:get-message(1) skip
            error-status:get-message(2)
    view-as alert-box error.
    assign
    varprice-rubl-transport = varmem-price-rubl-transport
    varsum-rubl-transport   = varmem-sum-rubl-transport
    varprice-base-transport = varmem-price-base-transport
    varsum-base-transport   = varmem-sum-base-transport
    .
  end.
end.
display varprice-rubl-transport varsum-rubl-transport varprice-base-transport varsum-base-transport with frame Dialog-Frame.
END.
ON return OF varsum-base-transport IN FRAME Dialog-Frame
DO:
  return no-apply.
END.
ON ENTRY OF varsum-base-vat IN FRAME Dialog-Frame
DO:
  run rate-correct (output varrate-correct) no-error.                             if error-status:error then do:                               message "Ошибка при вызове процедуры rate-correct." skip                                       return-value                                       error-status:get-message(1)                                       error-status:get-message(2)                               view-as alert-box error.                               return no-apply.                             end.                             if varrate-correct = no then do:                               message "Курс в партии не согласован с рублевой и валютной ценой." skip                                       "Рублевая цена: "         varprice-rubl skip                                       "Цена в базовой валюте: " varprice-base skip                                       "Курс базовой валюты: "   varbase-rate  skip                                       "Шкала базовой валюты: "  varbase-scale                                    view-as alert-box information.                               if b-calc-rate:sensitive then do:                                 apply "entry" to b-calc-rate.                              end.                               else do:                                 if b-calc-exch-rate:sensitive then do:                                   apply "entry" to b-calc-exch-rate.                                 end.                                 else do:                                   apply "entry" to varprice-cli.                                end.                               end.                               return no-apply.                             end.
  run rate-exch-correct (output varrate-exch-correct) no-error.                                  if error-status:error then do:                                    message "Ошибка при вызове процедуры rate-exch-correct." skip                                            return-value                                            error-status:get-message(1)                                            error-status:get-message(2)                                    view-as alert-box error.                                    return no-apply.                                  end.                                  if varrate-exch-correct = no then do:                                    message "Курс в партии не согласован с рублевой и ценой в валюте поставщика (договора)." skip                                            "Рублевая цена: "            varprice-rubl    skip                                            "Цена в валюте поставщика: " varprice-cli     skip                                            "Единица поставщика: "       varcli-base-rate skip                                            "Курс валюты поставщика: "   varexch-rate     skip                                            "Шкала валюты поставщика: "  varexch-scale                                    view-as alert-box information.                                    if b-calc-exch-rate:sensitive then do:                                      apply "entry" to b-calc-exch-rate.                                   end.                                    else do:                                      apply "entry" to varprice-cli.                                    end.                                    return no-apply.                                  end.
END.
ON LEAVE OF varsum-base-vat IN FRAME Dialog-Frame
DO:
if input frame Dialog-Frame varsum-base-vat <> varsum-base-vat then do:
if (input frame Dialog-Frame varsum-base-vat / (varsum-base - varsum-base-other - varsum-base-transport - varsum-base-road-tax - varsum-base-slt - varsum-base-vat)) * 100 < 0   or
   (input frame Dialog-Frame varsum-base-vat / (varsum-base - varsum-base-other - varsum-base-transport - varsum-base-road-tax - varsum-base-slt - varsum-base-vat)) * 100 > 100 then do:
   message "При такой сумовой компоненте НДС получится неверный процент НДС: " (input frame Dialog-Frame varsum-base-vat / (varsum-base - varsum-base-other - varsum-base-transport - varsum-base-road-tax - varsum-base-slt - varsum-base-vat)) * 100 " ."
   view-as alert-box.
   return no-apply.
end.
run calc-sum-base-vat in this-procedure.
end.
END.
ON return OF varsum-base-vat IN FRAME Dialog-Frame
DO:
  return no-apply.
END.
ON LEAVE OF varsum-cli IN FRAME Dialog-Frame
DO:
define variable varmemsum-cli    like varsum-cli   no-undo.
DEFINE VARIABLE varmem-price-cli LIKE varprice-cli NO-UNDO.
if input frame Dialog-Frame varsum-cli <> varsum-cli then do:
  assign
    varmemsum-cli   = varsum-cli
    varmem-price-cli = varprice-cli.
  assign frame Dialog-Frame varsum-cli.
  assign varprice-cli = varsum-cli / varfact-qnty * varcli-base-rate -
                        varprice-cli-road-tax -
                        (if varvat-type <> 'в т. ч.':U then varprice-cli-vat else 0) -
                        (if varslt-type <> 'в т. ч.':U then varprice-cli-slt else 0).
  display varprice-cli with frame Dialog-Frame.
  IF varexcheqrubl = YES THEN DO:
    RUN proc-calc-rubl-cli IN THIS-PROCEDURE NO-ERROR.
    IF ERROR-STATUS:ERROR THEN DO:
      MESSAGE "Ошибка при пересчете части в рублях." SKIP
              RETURN-VALUE
      VIEW-AS ALERT-BOX ERROR.
      ASSIGN
        varsum-cli   = varmemsum-cli
        varprice-cli = varmem-price-cli.
    END.
  END.
  if varexcheqbase = yes then do:
    run proc-calc-baseeqcli in this-procedure no-error.
    if error-status:error then do:
      message "Ошибка при пересчете части в базовой валюте." skip
                   return-value
      view-as alert-box error.
      assign
         varsum-cli = varmemsum-cli
         varprice-cli = varmem-price-cli.
    end.
  end.
end.
END.
ON return OF varsum-cli IN FRAME Dialog-Frame
DO:
  return no-apply.
END.
ON ENTRY OF varsum-cli-road-tax IN FRAME Dialog-Frame
DO:
  run rate-correct (output varrate-correct) no-error.                             if error-status:error then do:                               message "Ошибка при вызове процедуры rate-correct." skip                                       return-value                                       error-status:get-message(1)                                       error-status:get-message(2)                               view-as alert-box error.                               return no-apply.                             end.                             if varrate-correct = no then do:                               message "Курс в партии не согласован с рублевой и валютной ценой." skip                                       "Рублевая цена: "         varprice-rubl skip                                       "Цена в базовой валюте: " varprice-base skip                                       "Курс базовой валюты: "   varbase-rate  skip                                       "Шкала базовой валюты: "  varbase-scale                                    view-as alert-box information.                               if b-calc-rate:sensitive then do:                                 apply "entry" to b-calc-rate.                              end.                               else do:                                 if b-calc-exch-rate:sensitive then do:                                   apply "entry" to b-calc-exch-rate.                                 end.                                 else do:                                   apply "entry" to varprice-cli.                                end.                               end.                               return no-apply.                             end.
  run rate-exch-correct (output varrate-exch-correct) no-error.                                  if error-status:error then do:                                    message "Ошибка при вызове процедуры rate-exch-correct." skip                                            return-value                                            error-status:get-message(1)                                            error-status:get-message(2)                                    view-as alert-box error.                                    return no-apply.                                  end.                                  if varrate-exch-correct = no then do:                                    message "Курс в партии не согласован с рублевой и ценой в валюте поставщика (договора)." skip                                            "Рублевая цена: "            varprice-rubl    skip                                            "Цена в валюте поставщика: " varprice-cli     skip                                            "Единица поставщика: "       varcli-base-rate skip                                            "Курс валюты поставщика: "   varexch-rate     skip                                            "Шкала валюты поставщика: "  varexch-scale                                    view-as alert-box information.                                    if b-calc-exch-rate:sensitive then do:                                      apply "entry" to b-calc-exch-rate.                                   end.                                    else do:                                      apply "entry" to varprice-cli.                                    end.                                    return no-apply.                                  end.
END.
ON LEAVE OF varsum-cli-road-tax IN FRAME Dialog-Frame
DO:
define variable varmem-price-rubl-road-tax like varprice-rubl-road-tax no-undo.
define variable varmem-sum-rubl-road-tax   like varsum-rubl-road-tax   no-undo.
define variable varmem-price-base-road-tax like varprice-base-road-tax no-undo.
define variable varmem-sum-base-road-tax   like varsum-base-road-tax   no-undo.
define variable varmem-price-cli-road-tax  like varprice-cli-road-tax  no-undo.
define variable varmem-sum-cli-road-tax    like varsum-cli-road-tax    no-undo.
if input frame Dialog-Frame varsum-cli-road-tax <> varsum-cli-road-tax then do:
  assign
    varmem-price-rubl-road-tax = varprice-rubl-road-tax
    varmem-sum-rubl-road-tax   = varsum-rubl-road-tax
    varmem-price-base-road-tax = varprice-base-road-tax
    varmem-sum-base-road-tax   = varsum-base-road-tax
    varmem-price-cli-road-tax  = varprice-cli-road-tax
    varmem-sum-cli-road-tax    = varsum-cli-road-tax
  .
  assign frame Dialog-Frame varsum-cli-road-tax.
  assign
    varprice-cli-road-tax  = varsum-cli-road-tax / varfact-qnty * varcli-base-rate
    varprice-rubl-road-tax = varprice-cli-road-tax / varcli-base-rate * varexch-rate / varexch-scale
    varsum-rubl-road-tax   = varprice-rubl-road-tax * varfact-qnty
    varprice-base-road-tax = varprice-rubl-road-tax / varbase-rate * varbase-scale
    varsum-base-road-tax   = varprice-base-road-tax * varfact-qnty
  .
  run chg-abs in this-procedure no-error.
  if error-status:error then do:
    message "Ошибка при установке абсолютных налогов."  skip
            return-value skip
            error-status:get-message(1) skip
            error-status:get-message(2)
    view-as alert-box error.
    assign
    varprice-rubl-road-tax = varmem-price-rubl-road-tax
    varsum-rubl-road-tax   = varmem-sum-rubl-road-tax
    varprice-base-road-tax = varmem-price-base-road-tax
    varsum-base-road-tax   = varmem-sum-base-road-tax
    varprice-cli-road-tax  = varmem-price-cli-road-tax
    varsum-cli-road-tax    = varmem-sum-cli-road-tax
    .
  end.
end.
display varprice-rubl-road-tax varsum-rubl-road-tax varprice-base-road-tax varsum-base-road-tax varprice-cli-road-tax varsum-cli-road-tax with frame Dialog-Frame.
END.
ON return OF varsum-cli-road-tax IN FRAME Dialog-Frame
DO:
  return no-apply.
END.
ON ENTRY OF varsum-cli-slt IN FRAME Dialog-Frame
DO:
  run rate-correct (output varrate-correct) no-error.                             if error-status:error then do:                               message "Ошибка при вызове процедуры rate-correct." skip                                       return-value                                       error-status:get-message(1)                                       error-status:get-message(2)                               view-as alert-box error.                               return no-apply.                             end.                             if varrate-correct = no then do:                               message "Курс в партии не согласован с рублевой и валютной ценой." skip                                       "Рублевая цена: "         varprice-rubl skip                                       "Цена в базовой валюте: " varprice-base skip                                       "Курс базовой валюты: "   varbase-rate  skip                                       "Шкала базовой валюты: "  varbase-scale                                    view-as alert-box information.                               if b-calc-rate:sensitive then do:                                 apply "entry" to b-calc-rate.                              end.                               else do:                                 if b-calc-exch-rate:sensitive then do:                                   apply "entry" to b-calc-exch-rate.                                 end.                                 else do:                                   apply "entry" to varprice-cli.                                end.                               end.                               return no-apply.                             end.
  run rate-exch-correct (output varrate-exch-correct) no-error.                                  if error-status:error then do:                                    message "Ошибка при вызове процедуры rate-exch-correct." skip                                            return-value                                            error-status:get-message(1)                                            error-status:get-message(2)                                    view-as alert-box error.                                    return no-apply.                                  end.                                  if varrate-exch-correct = no then do:                                    message "Курс в партии не согласован с рублевой и ценой в валюте поставщика (договора)." skip                                            "Рублевая цена: "            varprice-rubl    skip                                            "Цена в валюте поставщика: " varprice-cli     skip                                            "Единица поставщика: "       varcli-base-rate skip                                            "Курс валюты поставщика: "   varexch-rate     skip                                            "Шкала валюты поставщика: "  varexch-scale                                    view-as alert-box information.                                    if b-calc-exch-rate:sensitive then do:                                      apply "entry" to b-calc-exch-rate.                                   end.                                    else do:                                      apply "entry" to varprice-cli.                                    end.                                    return no-apply.                                  end.
END.
ON LEAVE OF varsum-cli-slt IN FRAME Dialog-Frame
DO:
    define variable varmem-price-rubl-slt like ub.doc-line.price-rubl no-undo.
    define variable varmem-sum-rubl-slt   like ub.doc-line.price-rubl no-undo.
    define variable varmem-price-base-slt like ub.doc-line.price-rubl no-undo.
    define variable varmem-sum-base-slt   like ub.doc-line.price-rubl no-undo.
    define variable varmem-price-cli-slt  like ub.doc-line.price-rubl no-undo.
    define variable varmem-sum-cli-slt    like ub.doc-line.price-rubl no-undo.
    define variable varmem-slt-pc         like ub.doc-line.vat-pc no-undo.
    if input frame Dialog-Frame varsum-cli-slt <> varsum-cli-slt then do:
    assign
       varmem-price-rubl-slt = varprice-rubl-slt
       varmem-sum-rubl-slt   = varsum-rubl-slt
       varmem-price-base-slt = varprice-base-slt
       varmem-sum-base-slt   = varsum-base-slt
       varmem-price-cli-slt  = varprice-cli-slt
       varmem-sum-cli-slt    = varsum-cli-slt
       varmem-slt-pc         = varslt-pc
       .
    assign frame Dialog-Frame
       varsum-cli-slt.
    assign
      varprice-cli-slt  = varsum-cli-slt / varfact-qnty * varcli-base-rate
      varprice-rubl-slt = varprice-cli-slt / varcli-base-rate * varexch-rate / varexch-scale
      varsum-rubl-slt   = varprice-rubl-slt * varfact-qnty
      varprice-base-slt = varprice-rubl-slt / varbase-rate * varbase-scale
      varsum-base-slt   = varprice-base-slt * varfact-qnty
      varslt-pc         = varsum-cli-slt / (varsum-cli - varsum-cli-slt) * 100
      .
    run chg-slt-pc in this-procedure no-error.
    if error-status:error then do:
      message "Ошибка при изменении процента НП." skip
              return-value skip
              error-status:get-message(1)
      view-as alert-box.
      assign
       varprice-rubl-slt = varmem-price-rubl-slt
       varsum-rubl-slt   = varmem-sum-rubl-slt
       varprice-base-slt = varmem-price-base-slt
       varsum-base-slt   = varmem-sum-base-slt
       varprice-cli-slt  = varmem-price-cli-slt
       varsum-cli-slt    = varmem-sum-cli-slt
       varslt-pc         = varmem-slt-pc
       .
      display varprice-rubl-slt varsum-rubl-slt varprice-base-slt varsum-base-slt varprice-cli-slt varsum-cli-slt varslt-pc with frame Dialog-Frame.
    end.
    display varslt-pc with frame Dialog-Frame.
    end.
END.
ON return OF varsum-cli-slt IN FRAME Dialog-Frame
DO:
  return no-apply.
END.
ON ENTRY OF varsum-cli-vat IN FRAME Dialog-Frame
DO:
  run rate-correct (output varrate-correct) no-error.                             if error-status:error then do:                               message "Ошибка при вызове процедуры rate-correct." skip                                       return-value                                       error-status:get-message(1)                                       error-status:get-message(2)                               view-as alert-box error.                               return no-apply.                             end.                             if varrate-correct = no then do:                               message "Курс в партии не согласован с рублевой и валютной ценой." skip                                       "Рублевая цена: "         varprice-rubl skip                                       "Цена в базовой валюте: " varprice-base skip                                       "Курс базовой валюты: "   varbase-rate  skip                                       "Шкала базовой валюты: "  varbase-scale                                    view-as alert-box information.                               if b-calc-rate:sensitive then do:                                 apply "entry" to b-calc-rate.                              end.                               else do:                                 if b-calc-exch-rate:sensitive then do:                                   apply "entry" to b-calc-exch-rate.                                 end.                                 else do:                                   apply "entry" to varprice-cli.                                end.                               end.                               return no-apply.                             end.
  run rate-exch-correct (output varrate-exch-correct) no-error.                                  if error-status:error then do:                                    message "Ошибка при вызове процедуры rate-exch-correct." skip                                            return-value                                            error-status:get-message(1)                                            error-status:get-message(2)                                    view-as alert-box error.                                    return no-apply.                                  end.                                  if varrate-exch-correct = no then do:                                    message "Курс в партии не согласован с рублевой и ценой в валюте поставщика (договора)." skip                                            "Рублевая цена: "            varprice-rubl    skip                                            "Цена в валюте поставщика: " varprice-cli     skip                                            "Единица поставщика: "       varcli-base-rate skip                                            "Курс валюты поставщика: "   varexch-rate     skip                                            "Шкала валюты поставщика: "  varexch-scale                                    view-as alert-box information.                                    if b-calc-exch-rate:sensitive then do:                                      apply "entry" to b-calc-exch-rate.                                   end.                                    else do:                                      apply "entry" to varprice-cli.                                    end.                                    return no-apply.                                  end.
END.
ON LEAVE OF varsum-cli-vat IN FRAME Dialog-Frame
DO:
if input frame Dialog-Frame varsum-cli-vat <> varsum-cli-vat then do:
  if (input frame Dialog-Frame varsum-cli-vat / (varsum-cli - varsum-cli-road-tax - varsum-cli-vat)) * 100 < 0   or
     (input frame Dialog-Frame varsum-cli-vat / (varsum-cli - varsum-cli-road-tax - varsum-cli-vat)) * 100 > 100 then do:
     message "При такой сумовой компоненте НДС получится неверный процент НДС: " (input frame Dialog-Frame varsum-cli-vat / (varsum-cli - varsum-cli-road-tax - varsum-cli-vat)) * 100 " ."
     view-as alert-box.
     return no-apply.
  end.
  run calc-sum-cli-vat in this-procedure.
end.
END.
ON return OF varsum-cli-vat IN FRAME Dialog-Frame
DO:
  return no-apply.
END.
ON LEAVE OF varsum-rubl IN FRAME Dialog-Frame
DO:
define variable varmemsum-rubl like varsum-rubl no-undo.
if input frame Dialog-Frame varsum-rubl <> varsum-rubl then do:
  assign varmemsum-rubl = varsum-rubl.
  assign frame Dialog-Frame varsum-rubl.
  if varbaseeqrubl = yes then do:
    run proc-calc-base-rubl in this-procedure no-error.
    if error-status:error then do:
      message "Ошибка при пересчете валютной части." skip
                   return-value
      view-as alert-box error.
      assign
         varsum-rubl = varmemsum-rubl.
    end.
  end.
  assign varprice-rubl = varsum-rubl / varfact-qnty.
  display varprice-rubl with frame Dialog-Frame.
end.
END.
ON return OF varsum-rubl IN FRAME Dialog-Frame
DO:
  return no-apply.
END.
ON ENTRY OF varsum-rubl-other IN FRAME Dialog-Frame
DO:
  run rate-correct (output varrate-correct) no-error.                             if error-status:error then do:                               message "Ошибка при вызове процедуры rate-correct." skip                                       return-value                                       error-status:get-message(1)                                       error-status:get-message(2)                               view-as alert-box error.                               return no-apply.                             end.                             if varrate-correct = no then do:                               message "Курс в партии не согласован с рублевой и валютной ценой." skip                                       "Рублевая цена: "         varprice-rubl skip                                       "Цена в базовой валюте: " varprice-base skip                                       "Курс базовой валюты: "   varbase-rate  skip                                       "Шкала базовой валюты: "  varbase-scale                                    view-as alert-box information.                               if b-calc-rate:sensitive then do:                                 apply "entry" to b-calc-rate.                              end.                               else do:                                 if b-calc-exch-rate:sensitive then do:                                   apply "entry" to b-calc-exch-rate.                                 end.                                 else do:                                   apply "entry" to varprice-cli.                                end.                               end.                               return no-apply.                             end.
  run rate-exch-correct (output varrate-exch-correct) no-error.                                  if error-status:error then do:                                    message "Ошибка при вызове процедуры rate-exch-correct." skip                                            return-value                                            error-status:get-message(1)                                            error-status:get-message(2)                                    view-as alert-box error.                                    return no-apply.                                  end.                                  if varrate-exch-correct = no then do:                                    message "Курс в партии не согласован с рублевой и ценой в валюте поставщика (договора)." skip                                            "Рублевая цена: "            varprice-rubl    skip                                            "Цена в валюте поставщика: " varprice-cli     skip                                            "Единица поставщика: "       varcli-base-rate skip                                            "Курс валюты поставщика: "   varexch-rate     skip                                            "Шкала валюты поставщика: "  varexch-scale                                    view-as alert-box information.                                    if b-calc-exch-rate:sensitive then do:                                      apply "entry" to b-calc-exch-rate.                                   end.                                    else do:                                      apply "entry" to varprice-cli.                                    end.                                    return no-apply.                                  end.
END.
ON LEAVE OF varsum-rubl-other IN FRAME Dialog-Frame
DO:
define variable varmem-price-rubl-other  like varprice-rubl-other no-undo.
define variable varmem-sum-rubl-other    like varsum-rubl-other   no-undo.
define variable varmem-price-base-other  like varprice-base-other no-undo.
define variable varmem-sum-base-other    like varsum-base-other   no-undo.
if input frame Dialog-Frame varsum-rubl-other <> varsum-rubl-other then do:
  assign
    varmem-price-rubl-other = varprice-rubl-other
    varmem-sum-rubl-other   = varsum-rubl-other
    varmem-price-base-other = varprice-base-other
    varmem-sum-base-other   = varsum-base-other
  .
  assign frame Dialog-Frame varsum-rubl-other.
  assign
    varprice-rubl-other = varsum-rubl-other   / varfact-qnty
    varprice-base-other = varprice-rubl-other / varbase-rate * varbase-scale
    varsum-base-other   = varprice-base-other * varfact-qnty
    .
  run chg-abs in this-procedure no-error.
  if error-status:error then do:
    message "Ошибка при установке абсолютных налогов."  skip
            return-value skip
            error-status:get-message(1) skip
            error-status:get-message(2)
    view-as alert-box error.
    assign
      varprice-rubl-other = varmem-price-rubl-other
      varsum-rubl-other   = varmem-sum-rubl-other
      varprice-base-other = varmem-price-base-other
      varsum-base-other   = varmem-sum-base-other
    .
  end.
end.
display varprice-rubl-other varsum-rubl-other varprice-base-other varsum-base-other with frame Dialog-Frame.
END.
ON return OF varsum-rubl-other IN FRAME Dialog-Frame
DO:
  return no-apply.
END.
ON ENTRY OF varsum-rubl-road-tax IN FRAME Dialog-Frame
DO:
  run rate-correct (output varrate-correct) no-error.                             if error-status:error then do:                               message "Ошибка при вызове процедуры rate-correct." skip                                       return-value                                       error-status:get-message(1)                                       error-status:get-message(2)                               view-as alert-box error.                               return no-apply.                             end.                             if varrate-correct = no then do:                               message "Курс в партии не согласован с рублевой и валютной ценой." skip                                       "Рублевая цена: "         varprice-rubl skip                                       "Цена в базовой валюте: " varprice-base skip                                       "Курс базовой валюты: "   varbase-rate  skip                                       "Шкала базовой валюты: "  varbase-scale                                    view-as alert-box information.                               if b-calc-rate:sensitive then do:                                 apply "entry" to b-calc-rate.                              end.                               else do:                                 if b-calc-exch-rate:sensitive then do:                                   apply "entry" to b-calc-exch-rate.                                 end.                                 else do:                                   apply "entry" to varprice-cli.                                end.                               end.                               return no-apply.                             end.
  run rate-exch-correct (output varrate-exch-correct) no-error.                                  if error-status:error then do:                                    message "Ошибка при вызове процедуры rate-exch-correct." skip                                            return-value                                            error-status:get-message(1)                                            error-status:get-message(2)                                    view-as alert-box error.                                    return no-apply.                                  end.                                  if varrate-exch-correct = no then do:                                    message "Курс в партии не согласован с рублевой и ценой в валюте поставщика (договора)." skip                                            "Рублевая цена: "            varprice-rubl    skip                                            "Цена в валюте поставщика: " varprice-cli     skip                                            "Единица поставщика: "       varcli-base-rate skip                                            "Курс валюты поставщика: "   varexch-rate     skip                                            "Шкала валюты поставщика: "  varexch-scale                                    view-as alert-box information.                                    if b-calc-exch-rate:sensitive then do:                                      apply "entry" to b-calc-exch-rate.                                   end.                                    else do:                                      apply "entry" to varprice-cli.                                    end.                                    return no-apply.                                  end.
END.
ON LEAVE OF varsum-rubl-road-tax IN FRAME Dialog-Frame
DO:
define variable varmem-price-rubl-road-tax  like varprice-rubl-road-tax no-undo.
define variable varmem-sum-rubl-road-tax    like varsum-rubl-road-tax   no-undo.
define variable varmem-price-base-road-tax  like varprice-base-road-tax no-undo.
define variable varmem-sum-base-road-tax    like varsum-base-road-tax   no-undo.
define variable varmem-price-cli-road-tax   like varprice-cli-road-tax  no-undo.
define variable varmem-sum-cli-road-tax     like varsum-cli-road-tax    no-undo.
if input frame Dialog-Frame varsum-rubl-road-tax <> varsum-rubl-road-tax then do:
  assign
    varmem-price-rubl-road-tax = varprice-rubl-road-tax
    varmem-sum-rubl-road-tax   = varsum-rubl-road-tax
    varmem-price-base-road-tax = varprice-base-road-tax
    varmem-sum-base-road-tax   = varsum-base-road-tax
    varmem-price-cli-road-tax  = varprice-cli-road-tax
    varmem-sum-cli-road-tax    = varsum-cli-road-tax
  .
  assign frame Dialog-Frame varsum-rubl-road-tax.
  assign
    varprice-rubl-road-tax = varsum-rubl-road-tax   / varfact-qnty
    varprice-base-road-tax = varprice-rubl-road-tax / varbase-rate * varbase-scale
    varsum-base-road-tax   = varprice-base-road-tax * varfact-qnty
    varprice-cli-road-tax  = varprice-rubl-road-tax / varexch-rate * varexch-scale * varcli-base-rate
    varsum-cli-road-tax    = varprice-rubl-road-tax / varexch-rate * varexch-scale * varfact-qnty
    .
  run chg-abs in this-procedure no-error.
  if error-status:error then do:
    message "Ошибка при установке абсолютных налогов."  skip
            return-value skip
            error-status:get-message(1) skip
            error-status:get-message(2)
    view-as alert-box error.
    assign
      varprice-rubl-road-tax = varmem-price-rubl-road-tax
      varsum-rubl-road-tax   = varmem-sum-rubl-road-tax
      varprice-base-road-tax = varmem-price-base-road-tax
      varsum-base-road-tax   = varmem-sum-base-road-tax
      varprice-cli-road-tax  = varmem-price-cli-road-tax
      varsum-cli-road-tax    = varmem-sum-cli-road-tax
    .
  end.
end.
display varprice-rubl-road-tax varsum-rubl-road-tax varprice-base-road-tax varsum-base-road-tax varprice-cli-road-tax varsum-cli-road-tax with frame Dialog-Frame.
END.
ON return OF varsum-rubl-road-tax IN FRAME Dialog-Frame
DO:
  return no-apply.
END.
ON ENTRY OF varsum-rubl-slt IN FRAME Dialog-Frame
DO:
  run rate-correct (output varrate-correct) no-error.                             if error-status:error then do:                               message "Ошибка при вызове процедуры rate-correct." skip                                       return-value                                       error-status:get-message(1)                                       error-status:get-message(2)                               view-as alert-box error.                               return no-apply.                             end.                             if varrate-correct = no then do:                               message "Курс в партии не согласован с рублевой и валютной ценой." skip                                       "Рублевая цена: "         varprice-rubl skip                                       "Цена в базовой валюте: " varprice-base skip                                       "Курс базовой валюты: "   varbase-rate  skip                                       "Шкала базовой валюты: "  varbase-scale                                    view-as alert-box information.                               if b-calc-rate:sensitive then do:                                 apply "entry" to b-calc-rate.                              end.                               else do:                                 if b-calc-exch-rate:sensitive then do:                                   apply "entry" to b-calc-exch-rate.                                 end.                                 else do:                                   apply "entry" to varprice-cli.                                end.                               end.                               return no-apply.                             end.
  run rate-exch-correct (output varrate-exch-correct) no-error.                                  if error-status:error then do:                                    message "Ошибка при вызове процедуры rate-exch-correct." skip                                            return-value                                            error-status:get-message(1)                                            error-status:get-message(2)                                    view-as alert-box error.                                    return no-apply.                                  end.                                  if varrate-exch-correct = no then do:                                    message "Курс в партии не согласован с рублевой и ценой в валюте поставщика (договора)." skip                                            "Рублевая цена: "            varprice-rubl    skip                                            "Цена в валюте поставщика: " varprice-cli     skip                                            "Единица поставщика: "       varcli-base-rate skip                                            "Курс валюты поставщика: "   varexch-rate     skip                                            "Шкала валюты поставщика: "  varexch-scale                                    view-as alert-box information.                                    if b-calc-exch-rate:sensitive then do:                                      apply "entry" to b-calc-exch-rate.                                   end.                                    else do:                                      apply "entry" to varprice-cli.                                    end.                                    return no-apply.                                  end.
END.
ON LEAVE OF varsum-rubl-slt IN FRAME Dialog-Frame
DO:
define variable varmem-price-rubl-slt like ub.doc-line.price-rubl no-undo.
define variable varmem-sum-rubl-slt   like ub.doc-line.price-rubl no-undo.
define variable varmem-price-base-slt like ub.doc-line.price-rubl no-undo.
define variable varmem-sum-base-slt   like ub.doc-line.price-rubl no-undo.
define variable varmem-price-cli-slt  like ub.doc-line.price-rubl no-undo.
define variable varmem-sum-cli-slt    like ub.doc-line.price-rubl no-undo.
define variable varmem-slt-pc         like ub.doc-line.vat-pc     no-undo.
if input frame Dialog-Frame varsum-rubl-slt <> varsum-rubl-slt then do:
  assign
    varmem-price-rubl-slt = varprice-rubl-slt
    varmem-sum-rubl-slt   = varsum-rubl-slt
    varmem-price-base-slt = varprice-base-slt
    varmem-sum-base-slt   = varsum-base-slt
    varmem-price-cli-slt  = varprice-cli-slt
    varmem-sum-cli-slt    = varsum-cli-slt
    varmem-slt-pc         = varslt-pc
   .
  assign frame Dialog-Frame
    varsum-rubl-slt.
  assign
    varprice-rubl-slt = varsum-rubl-slt / varfact-qnty
    varprice-base-slt = varprice-rubl-slt / varbase-rate * varbase-scale
    varsum-base-slt   = varprice-base-slt * varfact-qnty
    varprice-cli-slt  = varprice-rubl-slt / varexch-rate * varexch-scale * varcli-base-rate
    varsum-cli-slt    = varprice-rubl-slt / varexch-rate * varexch-scale * varfact-qnty
    varslt-pc         = (varsum-rubl-slt / (varsum-rubl - varsum-rubl-other - varsum-rubl-transport - varsum-rubl-road-tax - varsum-rubl-slt)) * 100
  .
  run chg-slt-pc in this-procedure no-error.
  if error-status:error then do:
    message "Ошибка при изменении процента НП." skip
            return-value skip
            error-status:get-message(1)
    view-as alert-box.
    assign
     varprice-rubl-slt = varmem-price-rubl-slt
     varsum-rubl-slt   = varmem-sum-rubl-slt
     varprice-base-slt = varmem-price-base-slt
     varsum-base-slt   = varmem-sum-base-slt
     varprice-cli-slt  = varmem-price-cli-slt
     varsum-cli-slt    = varmem-sum-cli-slt
     varslt-pc         = varmem-slt-pc
     .
    display varprice-rubl-slt varsum-rubl-slt varprice-base-slt varsum-base-slt varprice-cli-slt varsum-cli-slt varslt-pc with frame Dialog-Frame.
  end.
  display varslt-pc with frame Dialog-Frame.
end.
END.
ON return OF varsum-rubl-slt IN FRAME Dialog-Frame
DO:
  return no-apply.
END.
ON ENTRY OF varsum-rubl-transport IN FRAME Dialog-Frame
DO:
  run rate-correct (output varrate-correct) no-error.                             if error-status:error then do:                               message "Ошибка при вызове процедуры rate-correct." skip                                       return-value                                       error-status:get-message(1)                                       error-status:get-message(2)                               view-as alert-box error.                               return no-apply.                             end.                             if varrate-correct = no then do:                               message "Курс в партии не согласован с рублевой и валютной ценой." skip                                       "Рублевая цена: "         varprice-rubl skip                                       "Цена в базовой валюте: " varprice-base skip                                       "Курс базовой валюты: "   varbase-rate  skip                                       "Шкала базовой валюты: "  varbase-scale                                    view-as alert-box information.                               if b-calc-rate:sensitive then do:                                 apply "entry" to b-calc-rate.                              end.                               else do:                                 if b-calc-exch-rate:sensitive then do:                                   apply "entry" to b-calc-exch-rate.                                 end.                                 else do:                                   apply "entry" to varprice-cli.                                end.                               end.                               return no-apply.                             end.
  run rate-exch-correct (output varrate-exch-correct) no-error.                                  if error-status:error then do:                                    message "Ошибка при вызове процедуры rate-exch-correct." skip                                            return-value                                            error-status:get-message(1)                                            error-status:get-message(2)                                    view-as alert-box error.                                    return no-apply.                                  end.                                  if varrate-exch-correct = no then do:                                    message "Курс в партии не согласован с рублевой и ценой в валюте поставщика (договора)." skip                                            "Рублевая цена: "            varprice-rubl    skip                                            "Цена в валюте поставщика: " varprice-cli     skip                                            "Единица поставщика: "       varcli-base-rate skip                                            "Курс валюты поставщика: "   varexch-rate     skip                                            "Шкала валюты поставщика: "  varexch-scale                                    view-as alert-box information.                                    if b-calc-exch-rate:sensitive then do:                                      apply "entry" to b-calc-exch-rate.                                   end.                                    else do:                                      apply "entry" to varprice-cli.                                    end.                                    return no-apply.                                  end.
END.
ON LEAVE OF varsum-rubl-transport IN FRAME Dialog-Frame
DO:
define variable varmem-price-rubl-transport  like varprice-rubl-transport no-undo.
define variable varmem-sum-rubl-transport    like varsum-rubl-transport   no-undo.
define variable varmem-price-base-transport  like varprice-base-transport no-undo.
define variable varmem-sum-base-transport    like varsum-base-transport   no-undo.
if input frame Dialog-Frame varsum-rubl-transport <> varsum-rubl-transport then do:
  assign
    varmem-price-rubl-transport = varprice-rubl-transport
    varmem-sum-rubl-transport   = varsum-rubl-transport
    varmem-price-base-transport = varprice-base-transport
    varmem-sum-base-transport   = varsum-base-transport
  .
  assign frame Dialog-Frame varsum-rubl-transport.
  assign
    varprice-rubl-transport = varsum-rubl-transport   / varfact-qnty
    varprice-base-transport = varprice-rubl-transport / varbase-rate * varbase-scale
    varsum-base-transport   = varprice-base-transport * varfact-qnty
    .
  run chg-abs in this-procedure no-error.
  if error-status:error then do:
    message "Ошибка при установке абсолютных налогов."  skip
            return-value skip
            error-status:get-message(1) skip
            error-status:get-message(2)
    view-as alert-box error.
    assign
      varprice-rubl-transport = varmem-price-rubl-transport
      varsum-rubl-transport   = varmem-sum-rubl-transport
      varprice-base-transport = varmem-price-base-transport
      varsum-base-transport   = varmem-sum-base-transport
    .
  end.
end.
display varprice-rubl-transport varsum-rubl-transport varprice-base-transport varsum-base-transport with frame Dialog-Frame.
END.
ON return OF varsum-rubl-transport IN FRAME Dialog-Frame
DO:
  return no-apply.
END.
ON ENTRY OF varsum-rubl-vat IN FRAME Dialog-Frame
DO:
  run rate-correct (output varrate-correct) no-error.                             if error-status:error then do:                               message "Ошибка при вызове процедуры rate-correct." skip                                       return-value                                       error-status:get-message(1)                                       error-status:get-message(2)                               view-as alert-box error.                               return no-apply.                             end.                             if varrate-correct = no then do:                               message "Курс в партии не согласован с рублевой и валютной ценой." skip                                       "Рублевая цена: "         varprice-rubl skip                                       "Цена в базовой валюте: " varprice-base skip                                       "Курс базовой валюты: "   varbase-rate  skip                                       "Шкала базовой валюты: "  varbase-scale                                    view-as alert-box information.                               if b-calc-rate:sensitive then do:                                 apply "entry" to b-calc-rate.                              end.                               else do:                                 if b-calc-exch-rate:sensitive then do:                                   apply "entry" to b-calc-exch-rate.                                 end.                                 else do:                                   apply "entry" to varprice-cli.                                end.                               end.                               return no-apply.                             end.
  run rate-exch-correct (output varrate-exch-correct) no-error.                                  if error-status:error then do:                                    message "Ошибка при вызове процедуры rate-exch-correct." skip                                            return-value                                            error-status:get-message(1)                                            error-status:get-message(2)                                    view-as alert-box error.                                    return no-apply.                                  end.                                  if varrate-exch-correct = no then do:                                    message "Курс в партии не согласован с рублевой и ценой в валюте поставщика (договора)." skip                                            "Рублевая цена: "            varprice-rubl    skip                                            "Цена в валюте поставщика: " varprice-cli     skip                                            "Единица поставщика: "       varcli-base-rate skip                                            "Курс валюты поставщика: "   varexch-rate     skip                                            "Шкала валюты поставщика: "  varexch-scale                                    view-as alert-box information.                                    if b-calc-exch-rate:sensitive then do:                                      apply "entry" to b-calc-exch-rate.                                   end.                                    else do:                                      apply "entry" to varprice-cli.                                    end.                                    return no-apply.                                  end.
END.
ON LEAVE OF varsum-rubl-vat IN FRAME Dialog-Frame
DO:
if input frame Dialog-Frame varsum-rubl-vat <> varsum-rubl-vat then do:
  if (input frame Dialog-Frame varsum-rubl-vat / (varsum-rubl - varsum-rubl-other - varsum-rubl-transport - varsum-rubl-road-tax - varsum-rubl-slt - varsum-rubl-vat)) * 100 < 0   or
     (input frame Dialog-Frame varsum-rubl-vat / (varsum-rubl - varsum-rubl-other - varsum-rubl-transport - varsum-rubl-road-tax - varsum-rubl-slt - varsum-rubl-vat)) * 100 > 100 then do:
     message "При такой сумовой компоненте НДС получится неверный процент НДС: " (input frame Dialog-Frame varsum-rubl-vat / (varsum-rubl - varsum-rubl-other - varsum-rubl-transport - varsum-rubl-road-tax - varsum-rubl-slt - varsum-rubl-vat)) * 100 < 0 " ."
     view-as alert-box.
     return no-apply.
  end.
  run calc-sum-rubl-vat in this-procedure.
end.
END.
ON return OF varsum-rubl-vat IN FRAME Dialog-Frame
DO:
  return no-apply.
END.
ON ENTRY OF varvat-pc IN FRAME Dialog-Frame
DO:
  run rate-correct (output varrate-correct) no-error.                             if error-status:error then do:                               message "Ошибка при вызове процедуры rate-correct." skip                                       return-value                                       error-status:get-message(1)                                       error-status:get-message(2)                               view-as alert-box error.                               return no-apply.                             end.                             if varrate-correct = no then do:                               message "Курс в партии не согласован с рублевой и валютной ценой." skip                                       "Рублевая цена: "         varprice-rubl skip                                       "Цена в базовой валюте: " varprice-base skip                                       "Курс базовой валюты: "   varbase-rate  skip                                       "Шкала базовой валюты: "  varbase-scale                                    view-as alert-box information.                               if b-calc-rate:sensitive then do:                                 apply "entry" to b-calc-rate.                              end.                               else do:                                 if b-calc-exch-rate:sensitive then do:                                   apply "entry" to b-calc-exch-rate.                                 end.                                 else do:                                   apply "entry" to varprice-cli.                                end.                               end.                               return no-apply.                             end.
  run rate-exch-correct (output varrate-exch-correct) no-error.                                  if error-status:error then do:                                    message "Ошибка при вызове процедуры rate-exch-correct." skip                                            return-value                                            error-status:get-message(1)                                            error-status:get-message(2)                                    view-as alert-box error.                                    return no-apply.                                  end.                                  if varrate-exch-correct = no then do:                                    message "Курс в партии не согласован с рублевой и ценой в валюте поставщика (договора)." skip                                            "Рублевая цена: "            varprice-rubl    skip                                            "Цена в валюте поставщика: " varprice-cli     skip                                            "Единица поставщика: "       varcli-base-rate skip                                            "Курс валюты поставщика: "   varexch-rate     skip                                            "Шкала валюты поставщика: "  varexch-scale                                    view-as alert-box information.                                    if b-calc-exch-rate:sensitive then do:                                      apply "entry" to b-calc-exch-rate.                                   end.                                    else do:                                      apply "entry" to varprice-cli.                                    end.                                    return no-apply.                                  end.
END.
ON LEAVE OF varvat-pc IN FRAME Dialog-Frame
DO:
if input frame Dialog-Frame varvat-pc <> round (varvat-pc, 2) then do:
  define variable varmem-vat-pc like ub.doc-line.vat-pc no-undo.
  assign frame Dialog-Frame
     varvat-pc.
  run chg-vat-pc in this-procedure no-error.
  if error-status:error then do:
    message "Ошибка при изменении процента НДС." skip
                  return-value skip
                  error-status:get-message(1)
    view-as alert-box.
    assign
      varvat-pc = varmem-vat-pc.
    display varvat-pc with frame Dialog-Frame.
  end.
end.
END.
ON return OF varvat-pc IN FRAME Dialog-Frame
DO:
  return no-apply.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame Dialog-Frame
do:
  run gbl/app_help.p
    (input this-procedure :file-name
    ,input ''
    ,input ?
    ) no-error.
  if error-status :error then do:
    message
      "Ошибка при вызове помощи"
      error-status :get-message(1)
      view-as alert-box .
  end.
end.
run minbtn-set in this-procedure .
on choose of b-help in frame Dialog-Frame
do:
  apply "help":u to frame Dialog-Frame .
end.
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure minbtn-set :
    do
        on error undo, return error return-value
        :
        define variable ii              as integer       no-undo .
        define variable fh              as widget-handle no-undo .
        define variable hh              as widget-handle no-undo .
        define variable v-h             as handle        extent 4 no-undo .
        define variable v-name-button   as character     no-undo .
        define variable v-help-old-x    as decimal       no-undo .
        define variable v-help-old-y    as decimal       no-undo .
        define variable v-help-old-size as decimal       no-undo .
        define variable v-frame-width   as decimal       no-undo .
        define variable jj              as integer       no-undo .
        do
            on error undo, return error
            :
            assign
                v-frame-width = frame Dialog-Frame:width - 0.3
                fh            = frame Dialog-Frame:first-child
                hh            = fh:first-child
                ii            = 1
                .
            do while valid-handle(hh):
                if LOOKUP(lc(hh:name), "b-help,b-print,b-history,b-hist,b-hist-user,b-sch") > 0  then
                do:
                    case lc(hh:name) :
                        when "b-help" then
                            do:
                                hh:load-image-up("cmp/b-help.bmp":u) .
                                hh:load-image-down("cmp/b-help.bmp":u) .
                                hh:load-image-insensitive("cmp/b-help.bmp":u) .
                                hh:TOOLTIP = "Помощь" .
                                v-help-old-x = hh:column .
                                v-help-old-y = hh:row    .
                                v-help-old-size = hh:width .
                                hh:width-chars = 2.5 .
                            end.
                        when "b-print" then
                            do:
                                hh:load-image("cmp/b-print.bmp":u) .
                                hh:TOOLTIP = "Печать" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-history" or
                        when "b-hist" then
                            do:
                                hh:load-image("cmp/b-hist.bmp":u) .
                                hh:TOOLTIP = "История" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-sch" then
                            do:
                                hh:load-image("cmp/b-sch.bmp":u) .
                                hh:TOOLTIP = "Установка Фильтра" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-hist-user" then
                            do:
                                hh:load-image("cmp/b-hist.bmp":u) .
                                hh:TOOLTIP = "История пользователя" .
                                ii = ii + 1 .
                            end.
                    end case.
                end.
                hh = hh:next-sibling.
            end.
            b-help:column = v-frame-width - b-help:width-chars.
            jj = 0.
            repeat ii = 4 to 1 by -1 :
                if valid-handle (v-h[ii] ) then
                do:
                    jj  = jj + 1 .
                    v-h[ii]:column = v-frame-width - b-help:width-chars - ( 3 * jj ).
                    v-h[ii]:row    = v-help-old-y .
                end.
            end.
        end.
    end.
end procedure.
run start-state in this-procedure no-error.
if error-status:error then do:
  message
  "Ошибка при начальной установке сумм." skip
  return-value skip
  error-status:get-message(1)
  view-as alert-box error.
  return error.
end.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  RUN enable_UI.
  if parmode <> "part":u then do:
    hide rect-part varincome-in-code varin-code varpart-code in frame Dialog-Frame.
  end.
  find first bf_clients where bf_clients.obj-type = parobj-type and
                              bf_clients.obj-code = parobj-code no-lock no-error.
  if not available bf_clients then do:
    message
      "Не найден объект " parobj-type " " parobj-code " ." view-as alert-box error.
    undo, return error.
  end.
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  bf_clients.obj-type
  ,input  bf_clients.obj-code
  ,output varhost-code
  ) no-error .
  if error-status:error then do:
    message "Ошибка при поиске фирмы для объекта: " bf_clients.obj-type " " bf_clients.obj-code " ." skip
            return-value skip
            error-status:get-message(1) skip
            error-status:get-message(2)
    view-as alert-box error.
    undo, return error.
  end.
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  varhost-code
  ,output varbase-code
  ) no-error .
  if error-status:error then do:
    message "Ошибка при поиске базовой валюты для фирмы: " varhost-code " ." skip
            return-value skip
            error-status:get-message(1) skip
            error-status:get-message(2)
    view-as alert-box error.
    undo, return error.
  end.
  assign
    varexch-code = parexch-code.
  if varbase-code <> 0 then do:
    assign
      varbaseeqrubl = no.
  end.
  else do:
    assign
      varbaseeqrubl = yes.
  end.
  if varexch-code = 0 then do:
    assign
      varexcheqrubl = yes.
  end.
  else do:
    assign
      varexcheqrubl = no.
  end.
  if varexch-code = varbase-code then do:
    assign
      varexcheqbase = yes.
  end.
  else do:
    assign
      varexcheqbase = no.
  end.
define variable vss-include-info26 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run exchrate in g#library
  (input  varbase-code
  ,input  today
  ,output vartemp-rate
  ,output vartemp-scale
  ,output varcur-base-name
  )  .
define variable vss-include-info27 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run exchrate in g#library
  (input  varexch-code
  ,input  today
  ,output vartemp-rate
  ,output vartemp-scale
  ,output varcur-cli-name
  )  .
  display varcur-base-name varcur-cli-name with frame Dialog-Frame.
  run tax-name in this-procedure ('rdt':U, output vartitle-road-tax) no-error.
  if error-status:error then do:
    message
      "Ошибка при определении названия налога." skip
      return-value skip
      error-status:get-message(1)
      view-as alert-box.
      undo, return error.
  end.
  assign
  v-rubli-firstshift = "Рубли"
  .
  ASSIGN
    varpurch-code-name:LIST-ITEMS IN FRAME Dialog-Frame = varno-change + ",":u + 'выкуп,консигнация,ответственное хранение':U
    varpurch-code-name = varno-change.
  DISPLAY varpurch-code-name WITH FRAME Dialog-Frame.
if paris-road-tax = no then do:
    hide rect-road-tax vartitle-road-tax
    varsum-base-road-tax varprice-base-road-tax varsum-rubl-road-tax varprice-rubl-road-tax varsum-cli-road-tax varprice-cli-road-tax
    varold-sum-base-road-tax varold-price-base-road-tax varold-sum-rubl-road-tax varold-price-rubl-road-tax varold-sum-cli-road-tax varold-price-cli-road-tax
    in frame Dialog-Frame.
  end.
  if varexcheqrubl = yes then do:
    disable varexch-rate varexch-scale varprice-rubl varsum-rubl b-calc-exch-rate b-calc-cli-t-rubl b-calc-rubl-t-cli b-cur-exch-rate
            varprice-rubl-vat varsum-rubl-vat varprice-rubl-slt varsum-rubl-slt varprice-rubl-road-tax varsum-rubl-road-tax
    with frame Dialog-Frame.
  end.
  if varexcheqbase = yes or varbaseeqrubl = yes then do:
    disable varbase-rate varbase-scale varprice-base varsum-base b-calc-rate b-calc-base-t-rubl b-calc-rubl-t-base b-cur-rate
            varprice-base-vat varsum-base-vat varprice-base-slt varsum-base-slt varprice-base-road-tax varsum-base-road-tax
            varprice-base-transport varsum-base-transport varprice-base-other varsum-base-other
    with frame Dialog-Frame.
  end.
  if varvat-type = 'без':U then do:
    disable varvat-pc varprice-cli-vat varsum-cli-vat varprice-rubl-vat varsum-rubl-vat varprice-base-vat varsum-base-vat with frame Dialog-Frame.
  end.
  if varslt-type = 'без':U then do:
    disable varslt-pc varprice-cli-slt varsum-cli-slt varprice-rubl-slt varsum-rubl-slt varprice-base-slt varsum-base-slt with frame Dialog-Frame.
  end.
  IF NOT (parcontract-code = 0 OR
          parcontract-code = ?    )THEN DO:
    DISABLE varpurch-code-name WITH FRAME Dialog-Frame.
  END.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE calc-price-base-vat :
assign frame Dialog-Frame
   varprice-base-vat.
assign
  varsum-base-vat   = varprice-base-vat * varfact-qnty
  varprice-rubl-vat = varprice-base-vat * varbase-rate / varbase-scale
  varsum-rubl-vat   = varprice-rubl-vat * varfact-qnty
  varprice-cli-vat  = varprice-rubl-vat / varexch-rate * varexch-scale / varcli-base-rate
  varsum-cli-vat    = varprice-rubl-vat / varexch-rate * varexch-scale * varfact-qnty
  varvat-pc         = (varprice-base-vat / (varprice-base - varother-base - vartransport-base - varroad-tax-base - varprice-base-slt - varprice-base-vat)) * 100
  .
display varsum-base-vat varprice-rubl-vat varsum-rubl-vat varprice-cli-vat varsum-cli-vat varvat-pc with frame Dialog-Frame.
END PROCEDURE.
PROCEDURE calc-price-cli-vat :
assign frame Dialog-Frame
   varprice-cli-vat.
assign
  varsum-cli-vat    = varprice-cli-vat * varfact-qnty / varcli-base-rate
  varprice-rubl-vat = varprice-cli-vat / varcli-base-rate * varexch-rate / varexch-scale
  varsum-rubl-vat   = varprice-rubl-vat * varfact-qnty
  varprice-base-vat = varprice-rubl-vat / varbase-rate * varbase-scale
  varsum-base-vat   = varprice-base-vat * varfact-qnty
  varvat-pc         = varprice-cli-vat / (varprice-cli + (if varvat-type <> 'в т. ч.':U then varprice-cli-vat else 0) + (if varslt-type <> 'в т. ч.':U then varprice-cli-slt else 0) - varprice-cli-slt - varprice-cli-vat) * 100
  .
display varsum-cli-vat varprice-rubl-vat varsum-rubl-vat varprice-base-vat varsum-base-vat varvat-pc with frame Dialog-Frame.
END PROCEDURE.
PROCEDURE calc-price-rubl-vat :
assign frame Dialog-Frame
   varprice-rubl-vat.
assign
  varsum-rubl-vat   = varprice-rubl-vat * varfact-qnty
  varprice-base-vat = varprice-rubl-vat / varbase-rate * varbase-scale
  varsum-base-vat   = varprice-base-vat * varfact-qnty
  varprice-cli-vat  = varprice-rubl-vat / varexch-rate * varexch-scale / varcli-base-rate
  varsum-cli-vat    = varprice-rubl-vat / varexch-rate * varexch-scale * varfact-qnty
  varvat-pc         = (varprice-rubl-vat / (varprice-rubl - varprice-rubl-other - varprice-rubl-transport - varprice-rubl-road-tax - varprice-rubl-slt - varprice-rubl-vat)) * 100
  .
display varsum-rubl-vat varprice-base-vat varsum-base-vat varprice-cli-vat varsum-cli-vat varvat-pc with frame Dialog-Frame.
END PROCEDURE.
PROCEDURE calc-sum-base-vat :
assign frame Dialog-Frame
   varsum-base-vat.
assign
  varprice-base-vat = varprice-base-vat / varfact-qnty
  varprice-rubl-vat = varprice-base-vat * varbase-rate / varbase-scale
  varsum-rubl-vat   = varprice-rubl-vat * varfact-qnty
  varprice-cli-vat  = varprice-rubl-vat / varexch-rate * varexch-scale / varcli-base-rate
  varsum-cli-vat    = varprice-rubl-vat / varexch-rate * varexch-scale * varfact-qnty
  varvat-pc         = (varsum-base-vat / (varsum-base - varsum-base-other - varsum-base-transport - varsum-base-road-tax - varsum-base-slt - varsum-base-vat)) * 100
  .
display varprice-base-vat varprice-rubl-vat varsum-rubl-vat varprice-cli-vat varsum-cli-vat varvat-pc with frame Dialog-Frame.
END PROCEDURE.
PROCEDURE calc-sum-cli-vat :
assign frame Dialog-Frame
   varsum-cli-vat.
  assign
   varprice-cli-vat  = varsum-cli-vat / varfact-qnty * varcli-base-rate
   varprice-rubl-vat = varprice-cli-vat / varcli-base-rate * varexch-rate / varexch-scale
   varsum-rubl-vat   = varprice-rubl-vat * varfact-qnty
   varprice-base-vat = varprice-rubl-vat / varbase-rate * varbase-scale
   varsum-base-vat   = varprice-base-vat * varfact-qnty
   varvat-pc         = varsum-cli-vat / (varsum-cli - varsum-cli-road-tax - varsum-cli-slt - varsum-cli-vat) * 100
  .
  display varprice-cli-vat varprice-rubl-vat varsum-rubl-vat varprice-base-vat varsum-base-vat varvat-pc with frame Dialog-Frame.
END PROCEDURE.
PROCEDURE calc-sum-rubl-vat :
assign frame Dialog-Frame
   varsum-rubl-vat.
  assign
   varprice-rubl-vat = varsum-rubl-vat / varfact-qnty
   varprice-base-vat = varprice-rubl-vat / varbase-rate * varbase-scale
   varsum-base-vat   = varsum-rubl-vat / varbase-rate * varbase-scale
   varprice-cli-vat  = varprice-rubl-vat / varexch-rate * varexch-scale / varcli-base-rate
   varsum-cli-vat    = varprice-rubl-vat / varexch-rate * varexch-scale * varfact-qnty
   varvat-pc         = (varsum-rubl-vat / (varsum-rubl - varsum-rubl-other - varsum-rubl-transport - varsum-rubl-road-tax - varsum-rubl-slt - varsum-rubl-vat)) * 100
  .
  display varprice-rubl-vat varprice-base-vat varsum-base-vat varprice-cli-vat varsum-cli-vat varvat-pc with frame Dialog-Frame.
END PROCEDURE.
PROCEDURE chg-abs :
assign
  varroad-tax-rubl  = varprice-rubl-road-tax
  vartransport-rubl = varprice-rubl-transport
  varother-rubl     = varprice-rubl-other
  varroad-tax-base  = varprice-base-road-tax
  vartransport-base = varprice-base-transport
  varother-base     = varprice-base-other
  varroad-tax-cli   = varprice-cli-road-tax
.
assign
  price-rubl-with-tax-loc = varprice-rubl
  price-base-with-tax-loc = varprice-base
.
define variable vss-include-info28 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprb
  )  .
  if varout-code = 'free-zone':U     or
     varout-code = 'out-zone':U   or
     vardoc-type = 'акт':U then do:
    assign
      in-vatp-have-vat-slt = yes.
  end.
  else do:
    find first in-vatp_doc-attr no-lock
      where in-vatp_doc-attr.doc-code  = varout-code
        and in-vatp_doc-attr.attr-code = 'envd':U
      no-error .
    if not available in-vatp_doc-attr then do:
      assign
        in-vatp-have-vat-slt = yes.
    end.
    else do:
         in-vatp-have-vat-slt = no.
    end.
  end.
  assign
   price-cli-with-tax-loc = varprice-cli
   cli-base-rate          = varcli-base-rate.
  ASSIGN   road-tax-base-loc  = (if varroad-tax-base  = ? then 0 else varroad-tax-base)
           road-tax-rubl-loc  = (if varroad-tax-rubl  = ? then 0 else varroad-tax-rubl).
  ASSIGN  transport-base-loc = (if vartransport-base = ? then 0 else vartransport-base)
          transport-rubl-loc = (if vartransport-rubl = ? then 0 else vartransport-rubl)
          other-base-loc     = (if varother-base     = ? then 0 else varother-base)
          other-rubl-loc     = (if varother-rubl     = ? then 0 else varother-rubl)
          vat-pc-loc         = (if varvat-pc         = ? then 0 else varvat-pc)
          slt-pc-loc         = (if varslt-pc         = ? then 0 else varslt-pc).
          ASSIGN   slt-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
    ASSIGN   slt-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
  assign
    exch-rate-cli-loc = (varprice-rubl - transport-rubl-loc - other-rubl-loc - road-tax-rubl-loc - (if varvat-type <> 'в т. ч.':U then vat-rubl-loc else 0) - (if varslt-type <> 'в т. ч.':U then slt-rubl-loc else 0)) / varprice-cli .
  assign
    slt-cli-loc        = slt-rubl-loc       / exch-rate-cli-loc
    vat-cli-loc        = vat-rubl-loc       / exch-rate-cli-loc
    road-tax-cli-loc   = road-tax-rubl-loc  / exch-rate-cli-loc
    transport-cli-loc  = 0
    other-cli-loc      = 0
  .
ASSIGN
          price-base-without-tax-loc = price-base-with-tax-loc - vat-base-loc - slt-base-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))
    price-rubl-without-tax-loc = price-rubl-with-tax-loc - vat-rubl-loc - slt-rubl-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))
.
assign
  varprice-rubl-slt = slt-rubl-loc
  varprice-base-slt = slt-base-loc
  varprice-cli-slt  = slt-cli-loc
  varsum-rubl-slt   = varprice-rubl-slt * varfact-qnty
  varsum-base-slt   = varprice-base-slt * varfact-qnty
  varsum-cli-slt    = varprice-cli-slt / varcli-base-rate * varfact-qnty
  varprice-rubl-vat = vat-rubl-loc
  varprice-base-vat = vat-base-loc
  varprice-cli-vat  = vat-cli-loc
  varsum-rubl-vat   = varprice-rubl-vat * varfact-qnty
  varsum-base-vat   = varprice-base-vat * varfact-qnty
  varsum-cli-vat    = varprice-cli-vat / varcli-base-rate * varfact-qnty.
display
varprice-rubl-slt varprice-base-slt varsum-rubl-slt varsum-base-slt varprice-cli-slt varsum-cli-slt
varprice-rubl-vat varprice-base-vat varsum-rubl-vat varsum-base-vat varprice-cli-vat varsum-cli-vat
with frame Dialog-Frame.
run proc-calc-cli-rubl in THIS-PROCEDURE NO-ERROR.
if error-status:error then do:
   message "Ошибка при пересчете значений в валюте клиента." skip
           return-value skip
           error-status:get-message(1) skip
   view-as alert-box error.
   return error.
end.
end procedure.
PROCEDURE chg-slt-pc :
assign
  varroad-tax-rubl  = varprice-rubl-road-tax
  vartransport-rubl = varprice-rubl-transport
  varother-rubl     = varprice-rubl-other
  varroad-tax-base  = varprice-base-road-tax
  vartransport-base = varprice-base-transport
  varother-base     = varprice-base-other
  varroad-tax-cli   = varprice-cli-road-tax
.
assign
  price-rubl-with-tax-loc = varprice-rubl
  price-base-with-tax-loc = varprice-base
.
define variable vss-include-info29 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprb
  )  .
  if varout-code = 'free-zone':U     or
     varout-code = 'out-zone':U   or
     vardoc-type = 'акт':U then do:
    assign
      in-vatp-have-vat-slt = yes.
  end.
  else do:
    find first in-vatp_doc-attr no-lock
      where in-vatp_doc-attr.doc-code  = varout-code
        and in-vatp_doc-attr.attr-code = 'envd':U
      no-error .
    if not available in-vatp_doc-attr then do:
      assign
        in-vatp-have-vat-slt = yes.
    end.
    else do:
         in-vatp-have-vat-slt = no.
    end.
  end.
  assign
   price-cli-with-tax-loc = varprice-cli
   cli-base-rate          = varcli-base-rate.
  ASSIGN   road-tax-base-loc  = (if varroad-tax-base  = ? then 0 else varroad-tax-base)
           road-tax-rubl-loc  = (if varroad-tax-rubl  = ? then 0 else varroad-tax-rubl).
  ASSIGN  transport-base-loc = (if vartransport-base = ? then 0 else vartransport-base)
          transport-rubl-loc = (if vartransport-rubl = ? then 0 else vartransport-rubl)
          other-base-loc     = (if varother-base     = ? then 0 else varother-base)
          other-rubl-loc     = (if varother-rubl     = ? then 0 else varother-rubl)
          vat-pc-loc         = (if varvat-pc         = ? then 0 else varvat-pc)
          slt-pc-loc         = (if varslt-pc         = ? then 0 else varslt-pc).
          ASSIGN   slt-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
    ASSIGN   slt-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
  assign
    exch-rate-cli-loc = (varprice-rubl - transport-rubl-loc - other-rubl-loc - road-tax-rubl-loc - (if varvat-type <> 'в т. ч.':U then vat-rubl-loc else 0) - (if varslt-type <> 'в т. ч.':U then slt-rubl-loc else 0)) / varprice-cli .
  assign
    slt-cli-loc        = slt-rubl-loc       / exch-rate-cli-loc
    vat-cli-loc        = vat-rubl-loc       / exch-rate-cli-loc
    road-tax-cli-loc   = road-tax-rubl-loc  / exch-rate-cli-loc
    transport-cli-loc  = 0
    other-cli-loc      = 0
  .
ASSIGN
          price-base-without-tax-loc = price-base-with-tax-loc - vat-base-loc - slt-base-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))
    price-rubl-without-tax-loc = price-rubl-with-tax-loc - vat-rubl-loc - slt-rubl-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))
.
if varslt-type <> 'в т. ч.':U then do:
  run proc-calc-cli-rubl in THIS-PROCEDURE NO-ERROR.
  if error-status:error then do:
     message "Ошибка при пересчете значений в валюте клиента." skip
             return-value skip
             error-status:get-message(1) skip
     view-as alert-box error.
     return error.
  end.
end.
assign
  price-rubl-with-tax-loc = varprice-rubl
  price-base-with-tax-loc = varprice-base
.
define variable vss-include-info30 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprb
  )  .
  if varout-code = 'free-zone':U     or
     varout-code = 'out-zone':U   or
     vardoc-type = 'акт':U then do:
    assign
      in-vatp-have-vat-slt = yes.
  end.
  else do:
    find first in-vatp_doc-attr no-lock
      where in-vatp_doc-attr.doc-code  = varout-code
        and in-vatp_doc-attr.attr-code = 'envd':U
      no-error .
    if not available in-vatp_doc-attr then do:
      assign
        in-vatp-have-vat-slt = yes.
    end.
    else do:
         in-vatp-have-vat-slt = no.
    end.
  end.
  assign
   price-cli-with-tax-loc = varprice-cli
   cli-base-rate          = varcli-base-rate.
  ASSIGN   road-tax-base-loc  = (if varroad-tax-base  = ? then 0 else varroad-tax-base)
           road-tax-rubl-loc  = (if varroad-tax-rubl  = ? then 0 else varroad-tax-rubl).
  ASSIGN  transport-base-loc = (if vartransport-base = ? then 0 else vartransport-base)
          transport-rubl-loc = (if vartransport-rubl = ? then 0 else vartransport-rubl)
          other-base-loc     = (if varother-base     = ? then 0 else varother-base)
          other-rubl-loc     = (if varother-rubl     = ? then 0 else varother-rubl)
          vat-pc-loc         = (if varvat-pc         = ? then 0 else varvat-pc)
          slt-pc-loc         = (if varslt-pc         = ? then 0 else varslt-pc).
          ASSIGN   slt-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
    ASSIGN   slt-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
  assign
    exch-rate-cli-loc = (varprice-rubl - transport-rubl-loc - other-rubl-loc - road-tax-rubl-loc - (if varvat-type <> 'в т. ч.':U then vat-rubl-loc else 0) - (if varslt-type <> 'в т. ч.':U then slt-rubl-loc else 0)) / varprice-cli .
  assign
    slt-cli-loc        = slt-rubl-loc       / exch-rate-cli-loc
    vat-cli-loc        = vat-rubl-loc       / exch-rate-cli-loc
    road-tax-cli-loc   = road-tax-rubl-loc  / exch-rate-cli-loc
    transport-cli-loc  = 0
    other-cli-loc      = 0
  .
ASSIGN
          price-base-without-tax-loc = price-base-with-tax-loc - vat-base-loc - slt-base-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))
    price-rubl-without-tax-loc = price-rubl-with-tax-loc - vat-rubl-loc - slt-rubl-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))
.
assign
  varprice-rubl-slt = slt-rubl-loc
  varprice-base-slt = slt-base-loc
  varprice-cli-slt  = slt-cli-loc
  varsum-rubl-slt   = varprice-rubl-slt * varfact-qnty
  varsum-base-slt   = varprice-base-slt * varfact-qnty
  varsum-cli-slt    = varprice-cli-slt / varcli-base-rate * varfact-qnty
  varprice-rubl-vat = vat-rubl-loc
  varprice-base-vat = vat-base-loc
  varprice-cli-vat  = vat-cli-loc
  varsum-rubl-vat   = varprice-rubl-vat * varfact-qnty
  varsum-base-vat   = varprice-base-vat * varfact-qnty
  varsum-cli-vat    = varprice-cli-vat / varcli-base-rate * varfact-qnty.
display
varprice-rubl-slt varprice-base-slt varprice-cli-slt varsum-rubl-slt varsum-base-slt varsum-cli-slt
varprice-rubl-vat varprice-base-vat varprice-cli-vat varsum-rubl-vat varsum-base-vat varsum-cli-vat
with frame Dialog-Frame.
END PROCEDURE.
PROCEDURE chg-vat-pc :
assign
  varroad-tax-rubl  = varprice-rubl-road-tax
  vartransport-rubl = varprice-rubl-transport
  varother-rubl     = varprice-rubl-other
  varroad-tax-base  = varprice-base-road-tax
  vartransport-base = varprice-base-transport
  varother-base     = varprice-base-other
  varroad-tax-cli   = varprice-cli-road-tax
.
assign
  price-rubl-with-tax-loc = varprice-rubl
  price-base-with-tax-loc = varprice-base
.
define variable vss-include-info31 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprb
  )  .
  if varout-code = 'free-zone':U     or
     varout-code = 'out-zone':U   or
     vardoc-type = 'акт':U then do:
    assign
      in-vatp-have-vat-slt = yes.
  end.
  else do:
    find first in-vatp_doc-attr no-lock
      where in-vatp_doc-attr.doc-code  = varout-code
        and in-vatp_doc-attr.attr-code = 'envd':U
      no-error .
    if not available in-vatp_doc-attr then do:
      assign
        in-vatp-have-vat-slt = yes.
    end.
    else do:
         in-vatp-have-vat-slt = no.
    end.
  end.
  assign
   price-cli-with-tax-loc = varprice-cli
   cli-base-rate          = varcli-base-rate.
  ASSIGN   road-tax-base-loc  = (if varroad-tax-base  = ? then 0 else varroad-tax-base)
           road-tax-rubl-loc  = (if varroad-tax-rubl  = ? then 0 else varroad-tax-rubl).
  ASSIGN  transport-base-loc = (if vartransport-base = ? then 0 else vartransport-base)
          transport-rubl-loc = (if vartransport-rubl = ? then 0 else vartransport-rubl)
          other-base-loc     = (if varother-base     = ? then 0 else varother-base)
          other-rubl-loc     = (if varother-rubl     = ? then 0 else varother-rubl)
          vat-pc-loc         = (if varvat-pc         = ? then 0 else varvat-pc)
          slt-pc-loc         = (if varslt-pc         = ? then 0 else varslt-pc).
          ASSIGN   slt-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
    ASSIGN   slt-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
  assign
    exch-rate-cli-loc = (varprice-rubl - transport-rubl-loc - other-rubl-loc - road-tax-rubl-loc - (if varvat-type <> 'в т. ч.':U then vat-rubl-loc else 0) - (if varslt-type <> 'в т. ч.':U then slt-rubl-loc else 0)) / varprice-cli .
  assign
    slt-cli-loc        = slt-rubl-loc       / exch-rate-cli-loc
    vat-cli-loc        = vat-rubl-loc       / exch-rate-cli-loc
    road-tax-cli-loc   = road-tax-rubl-loc  / exch-rate-cli-loc
    transport-cli-loc  = 0
    other-cli-loc      = 0
  .
ASSIGN
          price-base-without-tax-loc = price-base-with-tax-loc - vat-base-loc - slt-base-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))
    price-rubl-without-tax-loc = price-rubl-with-tax-loc - vat-rubl-loc - slt-rubl-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))
.
assign
  varprice-rubl-vat = vat-rubl-loc
  varprice-base-vat = vat-base-loc
  varprice-cli-vat  = vat-cli-loc
  varsum-rubl-vat   = varprice-rubl-vat * varfact-qnty
  varsum-base-vat   = varprice-base-vat * varfact-qnty
  varsum-cli-vat    = varprice-cli-vat  / varcli-base-rate * varfact-qnty.
display varprice-rubl-vat varprice-base-vat varprice-cli-vat
        varsum-rubl-vat   varsum-base-vat   varsum-cli-vat   with frame Dialog-Frame.
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY varobj-type varobj-code varobj-name varsupp-type varsupp-code
          varsupp-name varfact-qnty varartic varprod-type varprod-code
          vargds-name varvat-type varold-vat-pc varvat-pc varincome-in-code
          varin-code varpart-code varslt-type varold-slt-pc varslt-pc
          varcur-base-name varcur-base-rate varcur-base-scale varold-base-rate
          varbase-rate varbase-scale varcur-cli-name varcur-exch-rate
          varcur-exch-scale varold-exch-rate varexch-rate varexch-scale
          varcli-base-rate varold-price-cli varold-sum-cli varold-price-rubl
          varold-sum-rubl varold-price-base varold-sum-base varsum-rubl
          varprice-base varsum-base varprice-cli varsum-cli varprice-rubl
          varold-price-base-vat varold-sum-base-vat varold-price-cli-vat
          varold-sum-cli-vat varold-price-rubl-vat varold-sum-rubl-vat
          varprice-base-vat varsum-base-vat varprice-cli-vat varsum-cli-vat
          varprice-rubl-vat varsum-rubl-vat varold-price-base-slt
          varold-sum-base-slt varold-price-cli-slt varold-sum-cli-slt
          varold-price-rubl-slt varold-sum-rubl-slt varprice-base-slt
          varsum-base-slt varprice-cli-slt varsum-cli-slt varprice-rubl-slt
          varsum-rubl-slt varold-price-base-road-tax varold-sum-base-road-tax
          varold-price-cli-road-tax varold-sum-cli-road-tax
          varold-price-rubl-road-tax varold-sum-rubl-road-tax
          varprice-base-road-tax varsum-base-road-tax varprice-cli-road-tax
          varsum-cli-road-tax varprice-rubl-road-tax varsum-rubl-road-tax
          varold-price-base-transport varold-sum-base-transport
          varold-price-rubl-transport varold-sum-rubl-transport
          varold-purch-code-name varprice-base-transport varsum-base-transport
          varprice-rubl-transport varsum-rubl-transport varpurch-code-name
          varold-price-base-other varold-sum-base-other varold-price-rubl-other
          varold-sum-rubl-other varprice-base-other varsum-base-other
          varprice-rubl-other varsum-rubl-other v-rubli-firstshift
          vartitle-road-tax
      WITH FRAME Dialog-Frame.
  ENABLE b-save RECT-goods RECT-transport RECT-object RECT-other RECT-road-tax
         RECT-price RECT-slt RECT-vat RECT-1 b-cancel b-help varvat-pc
         varslt-pc b-cur-rate varbase-rate varbase-scale b-calc-rate
         b-cur-exch-rate varexch-rate varexch-scale b-calc-exch-rate
         b-calc-cli-t-rubl b-calc-rubl-t-cli b-calc-rubl-t-base
         b-calc-base-t-rubl varsum-rubl varprice-base varsum-base varprice-cli
         varsum-cli varprice-rubl varprice-base-vat varsum-base-vat
         varprice-cli-vat varsum-cli-vat varprice-rubl-vat varsum-rubl-vat
         varprice-base-slt varsum-base-slt varprice-cli-slt varsum-cli-slt
         varprice-rubl-slt varsum-rubl-slt varprice-base-road-tax
         varsum-base-road-tax varprice-cli-road-tax varsum-cli-road-tax
         varprice-rubl-road-tax varsum-rubl-road-tax varprice-base-transport
         varsum-base-transport varprice-rubl-transport varsum-rubl-transport
         varpurch-code-name varprice-base-other varsum-base-other
         varprice-rubl-other varsum-rubl-other
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE proc-calc-base-rubl :
assign
    varprice-base           = varprice-rubl           / varbase-rate * varbase-scale
    varsum-base             = varprice-base           * varfact-qnty
    varprice-base-road-tax  = varprice-rubl-road-tax  / varbase-rate * varbase-scale
    varsum-base-road-tax    = varprice-base-road-tax  * varfact-qnty
    varprice-base-transport = varprice-rubl-transport / varbase-rate * varbase-scale
    varsum-base-transport   = varprice-base-transport * varfact-qnty
    varprice-base-other     = varprice-rubl-other     / varbase-rate * varbase-scale
    varsum-base-other       = varprice-base-other     * varfact-qnty.
  assign
    varroad-tax-rubl  = varprice-rubl-road-tax
    vartransport-rubl = varprice-rubl-transport
    varother-rubl     = varprice-rubl-other
    varroad-tax-base  = varprice-base-road-tax
    vartransport-base = varprice-base-transport
    varother-base     = varprice-base-other
  .
assign
  price-rubl-with-tax-loc = varprice-rubl
  price-base-with-tax-loc = varprice-base
.
define variable vss-include-info32 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprb
  )  .
  if varout-code = 'free-zone':U     or
     varout-code = 'out-zone':U   or
     vardoc-type = 'акт':U then do:
    assign
      in-vatp-have-vat-slt = yes.
  end.
  else do:
    find first in-vatp_doc-attr no-lock
      where in-vatp_doc-attr.doc-code  = varout-code
        and in-vatp_doc-attr.attr-code = 'envd':U
      no-error .
    if not available in-vatp_doc-attr then do:
      assign
        in-vatp-have-vat-slt = yes.
    end.
    else do:
         in-vatp-have-vat-slt = no.
    end.
  end.
  assign
   price-cli-with-tax-loc = varprice-cli
   cli-base-rate          = varcli-base-rate.
  ASSIGN   road-tax-base-loc  = (if varroad-tax-base  = ? then 0 else varroad-tax-base)
           road-tax-rubl-loc  = (if varroad-tax-rubl  = ? then 0 else varroad-tax-rubl).
  ASSIGN  transport-base-loc = (if vartransport-base = ? then 0 else vartransport-base)
          transport-rubl-loc = (if vartransport-rubl = ? then 0 else vartransport-rubl)
          other-base-loc     = (if varother-base     = ? then 0 else varother-base)
          other-rubl-loc     = (if varother-rubl     = ? then 0 else varother-rubl)
          vat-pc-loc         = (if varvat-pc         = ? then 0 else varvat-pc)
          slt-pc-loc         = (if varslt-pc         = ? then 0 else varslt-pc).
          ASSIGN   slt-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
    ASSIGN   slt-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
  assign
    exch-rate-cli-loc = (varprice-rubl - transport-rubl-loc - other-rubl-loc - road-tax-rubl-loc - (if varvat-type <> 'в т. ч.':U then vat-rubl-loc else 0) - (if varslt-type <> 'в т. ч.':U then slt-rubl-loc else 0)) / varprice-cli .
  assign
    slt-cli-loc        = slt-rubl-loc       / exch-rate-cli-loc
    vat-cli-loc        = vat-rubl-loc       / exch-rate-cli-loc
    road-tax-cli-loc   = road-tax-rubl-loc  / exch-rate-cli-loc
    transport-cli-loc  = 0
    other-cli-loc      = 0
  .
ASSIGN
          price-base-without-tax-loc = price-base-with-tax-loc - vat-base-loc - slt-base-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))
    price-rubl-without-tax-loc = price-rubl-with-tax-loc - vat-rubl-loc - slt-rubl-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))
.
  assign
    varprice-rubl-slt = slt-rubl-loc
    varprice-base-slt = slt-base-loc
    varsum-rubl-slt   = varprice-rubl-slt * varfact-qnty
    varsum-base-slt   = varprice-base-slt * varfact-qnty
    varprice-rubl-vat = vat-rubl-loc
    varprice-base-vat = vat-base-loc
    varsum-rubl-vat   = varprice-rubl-vat * varfact-qnty
    varsum-base-vat   = varprice-base-vat * varfact-qnty.
  display varprice-base           varsum-base
          varprice-base-vat       varsum-base-vat varprice-rubl-vat varsum-rubl-vat
          varprice-base-slt       varsum-base-slt varprice-rubl-slt varsum-rubl-slt
          varprice-base-road-tax  when paris-road-tax varsum-base-road-tax when paris-road-tax
          varprice-base-transport varsum-base-transport
          varprice-base-other     varsum-base-other
  with frame Dialog-Frame.
END PROCEDURE.
PROCEDURE proc-calc-baseeqcli :
assign
    varprice-base           = (varprice-cli + varprice-cli-road-tax + (if varvat-type <> 'в т. ч.':U then varprice-cli-vat else 0) + (if varslt-type <> 'в т. ч.':U then varprice-cli-slt else 0)) / varcli-base-rate + varprice-base-transport + varprice-base-other
    varsum-base             = varprice-base           * varfact-qnty
    varprice-base-road-tax  = varprice-cli-road-tax   * varcli-base-rate
    varsum-base-road-tax    = varprice-base-road-tax  * varfact-qnty
   .
  assign
    varroad-tax-rubl  = varprice-rubl-road-tax
    vartransport-rubl = varprice-rubl-transport
    varother-rubl     = varprice-rubl-other
    varroad-tax-base  = varprice-base-road-tax
    vartransport-base = varprice-base-transport
    varother-base     = varprice-base-other
    varroad-tax-cli   = varprice-cli-road-tax
  .
assign
  price-rubl-with-tax-loc = varprice-rubl
  price-base-with-tax-loc = varprice-base
.
define variable vss-include-info33 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprb
  )  .
  if varout-code = 'free-zone':U     or
     varout-code = 'out-zone':U   or
     vardoc-type = 'акт':U then do:
    assign
      in-vatp-have-vat-slt = yes.
  end.
  else do:
    find first in-vatp_doc-attr no-lock
      where in-vatp_doc-attr.doc-code  = varout-code
        and in-vatp_doc-attr.attr-code = 'envd':U
      no-error .
    if not available in-vatp_doc-attr then do:
      assign
        in-vatp-have-vat-slt = yes.
    end.
    else do:
         in-vatp-have-vat-slt = no.
    end.
  end.
  assign
   price-cli-with-tax-loc = varprice-cli
   cli-base-rate          = varcli-base-rate.
  ASSIGN   road-tax-base-loc  = (if varroad-tax-base  = ? then 0 else varroad-tax-base)
           road-tax-rubl-loc  = (if varroad-tax-rubl  = ? then 0 else varroad-tax-rubl).
  ASSIGN  transport-base-loc = (if vartransport-base = ? then 0 else vartransport-base)
          transport-rubl-loc = (if vartransport-rubl = ? then 0 else vartransport-rubl)
          other-base-loc     = (if varother-base     = ? then 0 else varother-base)
          other-rubl-loc     = (if varother-rubl     = ? then 0 else varother-rubl)
          vat-pc-loc         = (if varvat-pc         = ? then 0 else varvat-pc)
          slt-pc-loc         = (if varslt-pc         = ? then 0 else varslt-pc).
          ASSIGN   slt-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
    ASSIGN   slt-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
  assign
    exch-rate-cli-loc = (varprice-rubl - transport-rubl-loc - other-rubl-loc - road-tax-rubl-loc - (if varvat-type <> 'в т. ч.':U then vat-rubl-loc else 0) - (if varslt-type <> 'в т. ч.':U then slt-rubl-loc else 0)) / varprice-cli .
  assign
    slt-cli-loc        = slt-rubl-loc       / exch-rate-cli-loc
    vat-cli-loc        = vat-rubl-loc       / exch-rate-cli-loc
    road-tax-cli-loc   = road-tax-rubl-loc  / exch-rate-cli-loc
    transport-cli-loc  = 0
    other-cli-loc      = 0
  .
ASSIGN
          price-base-without-tax-loc = price-base-with-tax-loc - vat-base-loc - slt-base-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))
    price-rubl-without-tax-loc = price-rubl-with-tax-loc - vat-rubl-loc - slt-rubl-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))
.
  assign
    varprice-rubl-slt = slt-rubl-loc
    varprice-base-slt = slt-base-loc
    varprice-cli-slt  = slt-cli-loc
    varsum-rubl-slt   = varprice-rubl-slt * varfact-qnty
    varsum-base-slt   = varprice-base-slt * varfact-qnty
    varsum-cli-slt    = varprice-cli-slt  * varfact-qnty / varcli-base-rate
    varprice-rubl-vat = vat-rubl-loc
    varprice-base-vat = vat-base-loc
    varprice-cli-vat  = vat-cli-loc
    varsum-rubl-vat   = varprice-rubl-vat * varfact-qnty
    varsum-base-vat   = varprice-base-vat * varfact-qnty
    varsum-cli-vat    = varprice-cli-vat  * varfact-qnty / varcli-base-rate.
  display varprice-base           varsum-base
          varprice-base-vat       varsum-base-vat
          varprice-rubl-vat       varsum-rubl-vat
          varprice-cli-vat        varsum-cli-vat
          varprice-base-slt       varsum-base-slt
          varprice-rubl-slt       varsum-rubl-slt
          varprice-cli-slt        varsum-cli-slt
          varprice-base-road-tax  when paris-road-tax
          varsum-base-road-tax    when paris-road-tax
          varprice-base-transport varsum-base-transport
          varprice-base-other     varsum-base-other
  with frame Dialog-Frame.
END PROCEDURE.
PROCEDURE proc-calc-cli-rubl :
assign
    varprice-cli            = (varprice-rubl - varprice-rubl-transport - varprice-rubl-other - varprice-rubl-road-tax - (if varvat-type <> 'в т. ч.':U then varprice-rubl-vat else 0) - (if varslt-type <> 'в т. ч.':U then varprice-cli-slt else 0)) / varexch-rate * varexch-scale * varcli-base-rate
    varsum-cli              = (varprice-rubl - varprice-rubl-transport - varprice-rubl-other - varprice-rubl-road-tax - (if varvat-type <> 'в т. ч.':U then varprice-rubl-vat else 0) - (if varslt-type <> 'в т. ч.':U then varprice-cli-slt else 0)) / varexch-rate * varexch-scale * varfact-qnty
    varprice-cli-road-tax   = varprice-cli-road-tax   / varexch-rate * varexch-scale * varcli-base-rate
    varsum-cli-road-tax     = varprice-cli-road-tax   / varexch-rate * varexch-scale * varfact-qnty
   .
  assign
    varroad-tax-rubl  = varprice-rubl-road-tax
    vartransport-rubl = varprice-rubl-transport
    varother-rubl     = varprice-rubl-other
    varroad-tax-base  = varprice-base-road-tax
    vartransport-base = varprice-base-transport
    varother-base     = varprice-base-other
    varroad-tax-cli   = varprice-cli-road-tax
  .
assign
  price-rubl-with-tax-loc = varprice-rubl
  price-base-with-tax-loc = varprice-base
.
define variable vss-include-info34 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprb
  )  .
  if varout-code = 'free-zone':U     or
     varout-code = 'out-zone':U   or
     vardoc-type = 'акт':U then do:
    assign
      in-vatp-have-vat-slt = yes.
  end.
  else do:
    find first in-vatp_doc-attr no-lock
      where in-vatp_doc-attr.doc-code  = varout-code
        and in-vatp_doc-attr.attr-code = 'envd':U
      no-error .
    if not available in-vatp_doc-attr then do:
      assign
        in-vatp-have-vat-slt = yes.
    end.
    else do:
         in-vatp-have-vat-slt = no.
    end.
  end.
  assign
   price-cli-with-tax-loc = varprice-cli
   cli-base-rate          = varcli-base-rate.
  ASSIGN   road-tax-base-loc  = (if varroad-tax-base  = ? then 0 else varroad-tax-base)
           road-tax-rubl-loc  = (if varroad-tax-rubl  = ? then 0 else varroad-tax-rubl).
  ASSIGN  transport-base-loc = (if vartransport-base = ? then 0 else vartransport-base)
          transport-rubl-loc = (if vartransport-rubl = ? then 0 else vartransport-rubl)
          other-base-loc     = (if varother-base     = ? then 0 else varother-base)
          other-rubl-loc     = (if varother-rubl     = ? then 0 else varother-rubl)
          vat-pc-loc         = (if varvat-pc         = ? then 0 else varvat-pc)
          slt-pc-loc         = (if varslt-pc         = ? then 0 else varslt-pc).
          ASSIGN   slt-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
    ASSIGN   slt-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
  assign
    exch-rate-cli-loc = (varprice-rubl - transport-rubl-loc - other-rubl-loc - road-tax-rubl-loc - (if varvat-type <> 'в т. ч.':U then vat-rubl-loc else 0) - (if varslt-type <> 'в т. ч.':U then slt-rubl-loc else 0)) / varprice-cli .
  assign
    slt-cli-loc        = slt-rubl-loc       / exch-rate-cli-loc
    vat-cli-loc        = vat-rubl-loc       / exch-rate-cli-loc
    road-tax-cli-loc   = road-tax-rubl-loc  / exch-rate-cli-loc
    transport-cli-loc  = 0
    other-cli-loc      = 0
  .
ASSIGN
          price-base-without-tax-loc = price-base-with-tax-loc - vat-base-loc - slt-base-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))
    price-rubl-without-tax-loc = price-rubl-with-tax-loc - vat-rubl-loc - slt-rubl-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))
.
  assign
    varprice-rubl-slt = slt-rubl-loc
    varprice-base-slt = slt-base-loc
    varprice-cli-slt  = slt-cli-loc
    varsum-rubl-slt   = varprice-rubl-slt * varfact-qnty
    varsum-base-slt   = varprice-base-slt * varfact-qnty
    varsum-cli-slt    = varprice-cli-slt  * varfact-qnty / varcli-base-rate
    varprice-rubl-vat = vat-rubl-loc
    varprice-base-vat = vat-base-loc
    varprice-cli-vat  = vat-cli-loc
    varsum-rubl-vat   = varprice-rubl-vat * varfact-qnty
    varsum-base-vat   = varprice-base-vat * varfact-qnty
    varsum-cli-vat    = varprice-cli-vat  * varfact-qnty / varcli-base-rate.
  display varprice-cli            varsum-cli
          varprice-base-vat       varsum-base-vat
          varprice-rubl-vat       varsum-rubl-vat
          varprice-cli-vat        varsum-cli-vat
          varprice-base-slt       varsum-base-slt
          varprice-rubl-slt       varsum-rubl-slt
          varprice-cli-slt        varsum-cli-slt
          varprice-cli-road-tax  when paris-road-tax
          varsum-cli-road-tax    when paris-road-tax
  with frame Dialog-Frame.
END PROCEDURE.
PROCEDURE proc-calc-exch-rate :
assign
     varexch-scale = 1
     varexch-rate  = (varprice-rubl - varprice-rubl-road-tax -
                      (if varvat-type <> 'в т. ч.':U then varprice-rubl-vat else 0) -
                      (if varslt-type <> 'в т. ч.':U then varprice-rubl-slt else 0)
                     )
                     / (varprice-cli / varcli-base-rate).
  display varexch-scale varexch-rate with frame Dialog-Frame.
  assign
     varprice-cli-road-tax   = varprice-rubl-road-tax  / varexch-rate * varexch-scale * varcli-base-rate
     varsum-cli-road-tax     = varprice-rubl-road-tax  / varexch-rate * varexch-scale * varfact-qnty
  .
  assign
    varroad-tax-rubl  = varprice-rubl-road-tax
    vartransport-rubl = varprice-rubl-transport
    varother-rubl     = varprice-rubl-other
    varroad-tax-base  = varprice-base-road-tax
    vartransport-base = varprice-base-transport
    varother-base     = varprice-base-other
    varroad-tax-cli   = varprice-cli-road-tax
  .
assign
  price-rubl-with-tax-loc = varprice-rubl
  price-base-with-tax-loc = varprice-base
.
define variable vss-include-info35 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprb
  )  .
  if varout-code = 'free-zone':U     or
     varout-code = 'out-zone':U   or
     vardoc-type = 'акт':U then do:
    assign
      in-vatp-have-vat-slt = yes.
  end.
  else do:
    find first in-vatp_doc-attr no-lock
      where in-vatp_doc-attr.doc-code  = varout-code
        and in-vatp_doc-attr.attr-code = 'envd':U
      no-error .
    if not available in-vatp_doc-attr then do:
      assign
        in-vatp-have-vat-slt = yes.
    end.
    else do:
         in-vatp-have-vat-slt = no.
    end.
  end.
  assign
   price-cli-with-tax-loc = varprice-cli
   cli-base-rate          = varcli-base-rate.
  ASSIGN   road-tax-base-loc  = (if varroad-tax-base  = ? then 0 else varroad-tax-base)
           road-tax-rubl-loc  = (if varroad-tax-rubl  = ? then 0 else varroad-tax-rubl).
  ASSIGN  transport-base-loc = (if vartransport-base = ? then 0 else vartransport-base)
          transport-rubl-loc = (if vartransport-rubl = ? then 0 else vartransport-rubl)
          other-base-loc     = (if varother-base     = ? then 0 else varother-base)
          other-rubl-loc     = (if varother-rubl     = ? then 0 else varother-rubl)
          vat-pc-loc         = (if varvat-pc         = ? then 0 else varvat-pc)
          slt-pc-loc         = (if varslt-pc         = ? then 0 else varslt-pc).
          ASSIGN   slt-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
    ASSIGN   slt-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
  assign
    exch-rate-cli-loc = (varprice-rubl - transport-rubl-loc - other-rubl-loc - road-tax-rubl-loc - (if varvat-type <> 'в т. ч.':U then vat-rubl-loc else 0) - (if varslt-type <> 'в т. ч.':U then slt-rubl-loc else 0)) / varprice-cli .
  assign
    slt-cli-loc        = slt-rubl-loc       / exch-rate-cli-loc
    vat-cli-loc        = vat-rubl-loc       / exch-rate-cli-loc
    road-tax-cli-loc   = road-tax-rubl-loc  / exch-rate-cli-loc
    transport-cli-loc  = 0
    other-cli-loc      = 0
  .
ASSIGN
          price-base-without-tax-loc = price-base-with-tax-loc - vat-base-loc - slt-base-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))
    price-rubl-without-tax-loc = price-rubl-with-tax-loc - vat-rubl-loc - slt-rubl-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))
.
  assign
    varprice-rubl-slt = slt-rubl-loc
    varprice-base-slt = slt-base-loc
    varprice-cli-slt  = slt-cli-loc
    varsum-rubl-slt   = varprice-rubl-slt * varfact-qnty
    varsum-base-slt   = varprice-base-slt * varfact-qnty
    varsum-cli-slt    = varprice-cli-slt  * varfact-qnty / varcli-base-rate
    varprice-rubl-vat = vat-rubl-loc
    varprice-base-vat = vat-base-loc
    varprice-cli-vat  = vat-cli-loc
    varsum-rubl-vat   = varprice-rubl-vat * varfact-qnty
    varsum-base-vat   = varprice-base-vat * varfact-qnty
    varsum-cli-vat    = varprice-cli-vat  * varfact-qnty / varcli-base-rate .
  display varprice-base-vat       varsum-base-vat
          varprice-rubl-vat       varsum-rubl-vat
          varprice-cli-vat        varsum-cli-vat
          varprice-base-slt       varsum-base-slt
          varprice-rubl-slt       varsum-rubl-slt
          varprice-cli-slt        varsum-cli-slt
          varprice-cli-road-tax   when paris-road-tax
          varsum-cli-road-tax     when paris-road-tax
  with frame Dialog-Frame.
END PROCEDURE.
PROCEDURE proc-calc-rate :
assign
     varbase-scale = 1
     varbase-rate  = varprice-rubl / varprice-base.
  display varbase-scale varbase-rate with frame Dialog-Frame.
  assign
     varprice-base-road-tax  = varprice-rubl-road-tax  / varbase-rate * varbase-scale
     varsum-base-road-tax    = varprice-base-road-tax  * varfact-qnty
     varprice-base-transport = varprice-rubl-transport / varbase-rate * varbase-scale
     varsum-base-transport   = varprice-base-transport * varfact-qnty
     varprice-base-other     = varprice-rubl-other     / varbase-rate * varbase-scale
     varsum-base-other       = varprice-base-other     * varfact-qnty.
  assign
    varroad-tax-rubl  = varprice-rubl-road-tax
    vartransport-rubl = varprice-rubl-transport
    varother-rubl     = varprice-rubl-other
    varroad-tax-base  = varprice-base-road-tax
    vartransport-base = varprice-base-transport
    varother-base     = varprice-base-other
    varroad-tax-cli   = varprice-cli-road-tax
  .
assign
  price-rubl-with-tax-loc = varprice-rubl
  price-base-with-tax-loc = varprice-base
.
define variable vss-include-info36 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprb
  )  .
  if varout-code = 'free-zone':U     or
     varout-code = 'out-zone':U   or
     vardoc-type = 'акт':U then do:
    assign
      in-vatp-have-vat-slt = yes.
  end.
  else do:
    find first in-vatp_doc-attr no-lock
      where in-vatp_doc-attr.doc-code  = varout-code
        and in-vatp_doc-attr.attr-code = 'envd':U
      no-error .
    if not available in-vatp_doc-attr then do:
      assign
        in-vatp-have-vat-slt = yes.
    end.
    else do:
         in-vatp-have-vat-slt = no.
    end.
  end.
  assign
   price-cli-with-tax-loc = varprice-cli
   cli-base-rate          = varcli-base-rate.
  ASSIGN   road-tax-base-loc  = (if varroad-tax-base  = ? then 0 else varroad-tax-base)
           road-tax-rubl-loc  = (if varroad-tax-rubl  = ? then 0 else varroad-tax-rubl).
  ASSIGN  transport-base-loc = (if vartransport-base = ? then 0 else vartransport-base)
          transport-rubl-loc = (if vartransport-rubl = ? then 0 else vartransport-rubl)
          other-base-loc     = (if varother-base     = ? then 0 else varother-base)
          other-rubl-loc     = (if varother-rubl     = ? then 0 else varother-rubl)
          vat-pc-loc         = (if varvat-pc         = ? then 0 else varvat-pc)
          slt-pc-loc         = (if varslt-pc         = ? then 0 else varslt-pc).
          ASSIGN   slt-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
    ASSIGN   slt-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
  assign
    exch-rate-cli-loc = (varprice-rubl - transport-rubl-loc - other-rubl-loc - road-tax-rubl-loc - (if varvat-type <> 'в т. ч.':U then vat-rubl-loc else 0) - (if varslt-type <> 'в т. ч.':U then slt-rubl-loc else 0)) / varprice-cli .
  assign
    slt-cli-loc        = slt-rubl-loc       / exch-rate-cli-loc
    vat-cli-loc        = vat-rubl-loc       / exch-rate-cli-loc
    road-tax-cli-loc   = road-tax-rubl-loc  / exch-rate-cli-loc
    transport-cli-loc  = 0
    other-cli-loc      = 0
  .
ASSIGN
          price-base-without-tax-loc = price-base-with-tax-loc - vat-base-loc - slt-base-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))
    price-rubl-without-tax-loc = price-rubl-with-tax-loc - vat-rubl-loc - slt-rubl-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))
.
  assign
    varprice-rubl-slt = slt-rubl-loc
    varprice-base-slt = slt-base-loc
    varprice-cli-slt  = slt-cli-loc
    varsum-rubl-slt   = varprice-rubl-slt * varfact-qnty
    varsum-base-slt   = varprice-base-slt * varfact-qnty
    varsum-cli-slt    = varprice-cli-slt  * varfact-qnty / varcli-base-rate
    varprice-rubl-vat = vat-rubl-loc
    varprice-base-vat = vat-base-loc
    varprice-cli-vat  = vat-cli-loc
    varsum-rubl-vat   = varprice-rubl-vat * varfact-qnty
    varsum-base-vat   = varprice-base-vat * varfact-qnty
    varsum-cli-vat    = varprice-cli-vat  * varfact-qnty / varcli-base-rate.
  display varprice-base-vat       varsum-base-vat
          varprice-rubl-vat       varsum-rubl-vat
          varprice-cli-vat        varsum-cli-vat
          varprice-base-slt       varsum-base-slt
          varprice-rubl-slt       varsum-rubl-slt
          varprice-cli-slt        varsum-cli-slt
          varprice-base-road-tax  when paris-road-tax
          varsum-base-road-tax    when paris-road-tax
          varprice-base-transport varsum-base-transport
          varprice-base-other     varsum-base-other
  with frame Dialog-Frame.
END PROCEDURE.
PROCEDURE proc-calc-rubl-base :
assign
    varprice-rubl           = varprice-base           * varbase-rate / varbase-scale
    varsum-rubl             = varprice-rubl           * varfact-qnty
    varprice-rubl-road-tax  = varprice-base-road-tax  * varbase-rate / varbase-scale
    varsum-rubl-road-tax    = varprice-rubl-road-tax  * varfact-qnty
    varprice-rubl-transport = varprice-base-transport * varbase-rate / varbase-scale
    varsum-rubl-transport   = varprice-rubl-transport * varfact-qnty
    varprice-rubl-other     = varprice-base-other     * varbase-rate / varbase-scale
    varsum-rubl-other       = varprice-rubl-other     * varfact-qnty.
  assign
    varroad-tax-rubl  = varprice-rubl-road-tax
    vartransport-rubl = varprice-rubl-transport
    varother-rubl     = varprice-rubl-other
    varroad-tax-base  = varprice-base-road-tax
    vartransport-base = varprice-base-transport
    varother-base     = varprice-base-other
  .
assign
  price-rubl-with-tax-loc = varprice-rubl
  price-base-with-tax-loc = varprice-base
.
define variable vss-include-info37 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprb
  )  .
  if varout-code = 'free-zone':U     or
     varout-code = 'out-zone':U   or
     vardoc-type = 'акт':U then do:
    assign
      in-vatp-have-vat-slt = yes.
  end.
  else do:
    find first in-vatp_doc-attr no-lock
      where in-vatp_doc-attr.doc-code  = varout-code
        and in-vatp_doc-attr.attr-code = 'envd':U
      no-error .
    if not available in-vatp_doc-attr then do:
      assign
        in-vatp-have-vat-slt = yes.
    end.
    else do:
         in-vatp-have-vat-slt = no.
    end.
  end.
  assign
   price-cli-with-tax-loc = varprice-cli
   cli-base-rate          = varcli-base-rate.
  ASSIGN   road-tax-base-loc  = (if varroad-tax-base  = ? then 0 else varroad-tax-base)
           road-tax-rubl-loc  = (if varroad-tax-rubl  = ? then 0 else varroad-tax-rubl).
  ASSIGN  transport-base-loc = (if vartransport-base = ? then 0 else vartransport-base)
          transport-rubl-loc = (if vartransport-rubl = ? then 0 else vartransport-rubl)
          other-base-loc     = (if varother-base     = ? then 0 else varother-base)
          other-rubl-loc     = (if varother-rubl     = ? then 0 else varother-rubl)
          vat-pc-loc         = (if varvat-pc         = ? then 0 else varvat-pc)
          slt-pc-loc         = (if varslt-pc         = ? then 0 else varslt-pc).
          ASSIGN   slt-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
    ASSIGN   slt-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
  assign
    exch-rate-cli-loc = (varprice-rubl - transport-rubl-loc - other-rubl-loc - road-tax-rubl-loc - (if varvat-type <> 'в т. ч.':U then vat-rubl-loc else 0) - (if varslt-type <> 'в т. ч.':U then slt-rubl-loc else 0)) / varprice-cli .
  assign
    slt-cli-loc        = slt-rubl-loc       / exch-rate-cli-loc
    vat-cli-loc        = vat-rubl-loc       / exch-rate-cli-loc
    road-tax-cli-loc   = road-tax-rubl-loc  / exch-rate-cli-loc
    transport-cli-loc  = 0
    other-cli-loc      = 0
  .
ASSIGN
          price-base-without-tax-loc = price-base-with-tax-loc - vat-base-loc - slt-base-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))
    price-rubl-without-tax-loc = price-rubl-with-tax-loc - vat-rubl-loc - slt-rubl-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))
.
  assign
    varprice-rubl-slt = slt-rubl-loc
    varprice-base-slt = slt-base-loc
    varsum-rubl-slt   = varprice-rubl-slt * varfact-qnty
    varsum-base-slt   = varprice-base-slt * varfact-qnty
    varprice-rubl-vat = vat-rubl-loc
    varprice-base-vat = vat-base-loc
    varsum-rubl-vat   = varprice-rubl-vat * varfact-qnty
    varsum-base-vat   = varprice-base-vat * varfact-qnty.
  display varprice-rubl           varsum-rubl
          varprice-base-vat       varsum-base-vat varprice-rubl-vat varsum-rubl-vat
          varprice-base-slt       varsum-base-slt varprice-rubl-slt varsum-rubl-slt
          varprice-rubl-road-tax  when paris-road-tax varsum-rubl-road-tax when paris-road-tax
          varprice-rubl-transport varsum-rubl-transport
          varprice-rubl-other     varsum-rubl-other
  with frame Dialog-Frame.
END PROCEDURE.
PROCEDURE proc-calc-rubl-cli :
assign
    varprice-rubl           = (varprice-cli + varprice-cli-road-tax + (if varvat-type <> 'в т. ч.':U then varprice-cli-vat else 0) + (if varslt-type <> 'в т. ч.':U then varprice-cli-slt else 0)) / varcli-base-rate * varexch-rate / varexch-scale + varprice-rubl-transport + varprice-rubl-other
    varsum-rubl             = varprice-rubl           * varfact-qnty
    varprice-rubl-road-tax  = varprice-cli-road-tax / varcli-base-rate * varexch-rate / varexch-scale
    varsum-rubl-road-tax    = varprice-rubl-road-tax  * varfact-qnty
  .
  assign
    varroad-tax-rubl  = varprice-rubl-road-tax
    vartransport-rubl = varprice-rubl-transport
    varother-rubl     = varprice-rubl-other
    varroad-tax-base  = varprice-base-road-tax
    vartransport-base = varprice-base-transport
    varother-base     = varprice-base-other
    varroad-tax-cli   = varprice-cli-road-tax
.
assign
  price-rubl-with-tax-loc = varprice-rubl
  price-base-with-tax-loc = varprice-base
.
define variable vss-include-info38 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprb
  )  .
  if varout-code = 'free-zone':U     or
     varout-code = 'out-zone':U   or
     vardoc-type = 'акт':U then do:
    assign
      in-vatp-have-vat-slt = yes.
  end.
  else do:
    find first in-vatp_doc-attr no-lock
      where in-vatp_doc-attr.doc-code  = varout-code
        and in-vatp_doc-attr.attr-code = 'envd':U
      no-error .
    if not available in-vatp_doc-attr then do:
      assign
        in-vatp-have-vat-slt = yes.
    end.
    else do:
         in-vatp-have-vat-slt = no.
    end.
  end.
  assign
   price-cli-with-tax-loc = varprice-cli
   cli-base-rate          = varcli-base-rate.
  ASSIGN   road-tax-base-loc  = (if varroad-tax-base  = ? then 0 else varroad-tax-base)
           road-tax-rubl-loc  = (if varroad-tax-rubl  = ? then 0 else varroad-tax-rubl).
  ASSIGN  transport-base-loc = (if vartransport-base = ? then 0 else vartransport-base)
          transport-rubl-loc = (if vartransport-rubl = ? then 0 else vartransport-rubl)
          other-base-loc     = (if varother-base     = ? then 0 else varother-base)
          other-rubl-loc     = (if varother-rubl     = ? then 0 else varother-rubl)
          vat-pc-loc         = (if varvat-pc         = ? then 0 else varvat-pc)
          slt-pc-loc         = (if varslt-pc         = ? then 0 else varslt-pc).
          ASSIGN   slt-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
    ASSIGN   slt-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
  assign
    exch-rate-cli-loc = (varprice-rubl - transport-rubl-loc - other-rubl-loc - road-tax-rubl-loc - (if varvat-type <> 'в т. ч.':U then vat-rubl-loc else 0) - (if varslt-type <> 'в т. ч.':U then slt-rubl-loc else 0)) / varprice-cli .
  assign
    slt-cli-loc        = slt-rubl-loc       / exch-rate-cli-loc
    vat-cli-loc        = vat-rubl-loc       / exch-rate-cli-loc
    road-tax-cli-loc   = road-tax-rubl-loc  / exch-rate-cli-loc
    transport-cli-loc  = 0
    other-cli-loc      = 0
  .
ASSIGN
          price-base-without-tax-loc = price-base-with-tax-loc - vat-base-loc - slt-base-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))
    price-rubl-without-tax-loc = price-rubl-with-tax-loc - vat-rubl-loc - slt-rubl-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))
.
  assign
    varprice-rubl-slt = slt-rubl-loc
    varprice-base-slt = slt-base-loc
    varprice-cli-slt  = slt-cli-loc
    varsum-rubl-slt   = varprice-rubl-slt * varfact-qnty
    varsum-base-slt   = varprice-base-slt * varfact-qnty
    varsum-cli-slt    = varprice-cli-slt  * varfact-qnty / varcli-base-rate
    varprice-rubl-vat = vat-rubl-loc
    varprice-base-vat = vat-base-loc
    varprice-cli-vat  = vat-cli-loc
    varsum-rubl-vat   = varprice-rubl-vat * varfact-qnty
    varsum-base-vat   = varprice-base-vat * varfact-qnty
    varsum-cli-vat    = varprice-cli-vat  * varfact-qnty / varcli-base-rate.
  display varprice-rubl           varsum-rubl
          varprice-base-vat       varsum-base-vat
          varprice-rubl-vat       varsum-rubl-vat
          varprice-cli-vat        varsum-cli-vat
          varprice-base-slt       varsum-base-slt
          varprice-rubl-slt       varsum-rubl-slt
          varprice-cli-slt        varsum-cli-slt
          varprice-rubl-road-tax  when paris-road-tax
          varsum-rubl-road-tax    when paris-road-tax
          varprice-rubl-transport varsum-rubl-transport
          varprice-rubl-other     varsum-rubl-other
  with frame Dialog-Frame.
END PROCEDURE.
PROCEDURE rate-correct :
define output parameter parrate-correct as logical no-undo.
if varprice-rubl  = varprice-base * varbase-rate / varbase-scale or
   varprice-base = varprice-rubl / varbase-rate * varbase-scale or
   varbase-rate = varprice-rubl / varprice-base *  varbase-scale then do:
   assign parrate-correct = true.
end.
else do:
  assign parrate-correct = false.
end.
END PROCEDURE.
PROCEDURE rate-exch-correct :
define output parameter parrate-exch-correct as logical no-undo.
if (varprice-rubl - varprice-rubl-road-tax - varprice-rubl-transport - varprice-rubl-other - (if varvat-type <> 'в т. ч.':U then varprice-rubl-vat else 0) - (if varslt-type <> 'в т. ч.':U then varprice-rubl-slt else 0)) = varprice-cli / varcli-base-rate * varexch-rate / varexch-scale         or
   (varprice-cli / varcli-base-rate)  = (varprice-rubl - varprice-rubl-road-tax - varprice-rubl-transport - varprice-rubl-other - (if varvat-type <> 'в т. ч.':U then varprice-rubl-vat else 0) - (if varslt-type <> 'в т. ч.':U then varprice-rubl-slt else 0)) / varexch-rate * varexch-scale      or
   (varexch-rate / varexch-scale)     = (varprice-rubl - varprice-rubl-road-tax - varprice-rubl-transport - varprice-rubl-other - (if varvat-type <> 'в т. ч.':U then varprice-rubl-vat else 0) - (if varslt-type <> 'в т. ч.':U then varprice-rubl-slt else 0)) / (varprice-cli / varcli-base-rate) then do:
   assign parrate-exch-correct = true.
end.
else do:
  assign parrate-exch-correct = false.
end.
END PROCEDURE.
PROCEDURE start-state :
define buffer bf-supp_parts   for ub.parts.
define buffer bf-supp_clients for ub.clients.
define variable varhost-code        like ub.clients.obj-code no-undo.
define variable varhave-parts       as   logical             no-undo.
define variable varno-recalc-vat-pc like ub.parts.vat-pc     no-undo.
define variable varno-recalc-slt-pc like ub.parts.slt-pc     no-undo.
define variable varcount            as   integer             no-undo.
do on error undo, return error return-value :
assign
  varno-recalc-vat-pc = ?
  varno-recalc-slt-pc = ?.
find first bf_goods where bf_goods.gds-code = pargds-code no-lock no-error.
if not available bf_goods then do:
  return error substitute ("Не найден товар с внутренним кодом &1.", pargds-code).
end.
assign
  varartic     = bf_goods.artic
  varprod-type = bf_goods.prod-type
  varprod-code = bf_goods.prod-code
  vargds-name  = bf_goods.gds-name.
find first bf-cur-obj_clients where bf-cur-obj_clients.obj-type = parobj-type and
                                    bf-cur-obj_clients.obj-code = parobj-code no-lock no-error.
if not available bf-cur-obj_clients then do:
  return error substitute ("Не найден объект &1 &2.", parobj-type, parobj-code).
end.
if bf-cur-obj_clients.obj-type <> 'маг':U  and
   bf-cur-obj_clients.obj-type <> 'скл':U then do:
  return error substitute ("Объект &1 &2 не является складом или магазином.", bf-cur-obj_clients.obj-type, bf-cur-obj_clients.obj-code).
end.
define variable vss-include-info39 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  bf-cur-obj_clients.obj-type
  ,input  bf-cur-obj_clients.obj-code
  ,output varhost-code
  )  .
assign
  varobj-type = bf-cur-obj_clients.obj-type
  varobj-code = bf-cur-obj_clients.obj-code
  varobj-name = bf-cur-obj_clients.obj-name.
find first bf-supp_clients where bf-supp_clients.obj-type = parcli-type and
                                 bf-supp_clients.obj-code = parcli-code no-lock no-error.
if not available bf-supp_clients then do:
  return error substitute ("Не найден контрагент &1 &2.", parcli-type, parcli-code).
end.
assign
  varsupp-type = bf-supp_clients.obj-type
  varsupp-code = bf-supp_clients.obj-code
  varsupp-name = bf-supp_clients.obj-name.
if parmode = "part":u then do:
  find first bf_parts where bf_parts.obj-type  = varobj-type  and
                            bf_parts.obj-code  = varobj-code  and
                            bf_parts.artic     = varartic     and
                            bf_parts.prod-type = varprod-type and
                            bf_parts.prod-code = varprod-code and
                            bf_parts.in-code   = parin-code   and
                            bf_parts.out-code  = parout-code  and
                            bf_parts.part-code = parpart-code no-lock no-error.
  if not available bf_parts then do:
    return error substitute ("Не найдена партия. Объект &1 &2. Товар &3 &4 &5. Порожд. накл. &6. Накл. &7. Код партии &8.",
                             varobj-type,
                             varobj-code,
                             varartic,
                             varprod-type,
                             varprod-code,
                             parin-code,
                             parout-code,
                             parpart-code).
  end.
  assign
    varin-code   = parin-code
    varpart-code = parpart-code
    varfact-qnty = bf_parts.fact-qnty.
  find first bf_parts-attr where bf_parts-attr.in-code   = varin-code        and
                                 bf_parts-attr.gds-code  = bf_goods.gds-code and
                                 bf_parts-attr.part-code = varpart-code      no-lock no-error.
  if available bf_parts-attr then do:
    assign
      varincome-in-code = bf_parts-attr.income-in-code.
  end.
  else do:
    assign
      varincome-in-code = varin-code.
  end.
end.
assign
  varcur-base-rate  = parbase-rate
  varcur-base-scale = parbase-scale.
assign
  varcur-exch-rate  = parexch-rate
  varcur-exch-scale = parexch-scale.
if parmode = "goods":u or parmode = "parts":u then do:
  assign
    varfact-qnty  = 0
    varhave-parts = no.
  for each tt-clcparts on error undo, return error return-value :
    delete tt-clcparts.
  end.
  assign
    varcount = 1.
  for each tt-chs-parts on error undo, return error substitute ("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)) :
    if varcount = 1 then do:
      assign
        varno-recalc-vat-pc = tt-chs-parts.vat-pc
        varno-recalc-slt-pc = tt-chs-parts.slt-pc.
    end.
    else do:
      if tt-chs-parts.vat-pc <> varno-recalc-vat-pc then do:
        assign
          varno-recalc-vat-pc = ?.
      end.
      if tt-chs-parts.slt-pc <> varno-recalc-slt-pc then do:
        assign
          varno-recalc-slt-pc = ?.
      end.
    end.
    create tt-clcparts.
    buffer-copy tt-chs-parts to tt-clcparts.
    assign varhave-parts = yes.
  end.
  if varhave-parts = no then do:
    return error substitute ("В свободной зоне нет партий по товару с внутренним кодом &1 от поставщика &2 &3.",
                             pargds-code,
                             parcli-type,
                             parcli-code).
  end.
  find first tt-clcparts no-error.
  if available tt-clcparts then do:
    run clcprtsl_calc-ttable in this-procedure (
                                              input no,
                                              input no,
                                              input 0,
                                              input 0 ,
                                              input 0,
                                              input 0,
                                              input 0,
                                              input 0,
                                              input 0,
                                              input ?,
                                              input 0,
                                              input 0,
                                              input 0,
                                              input 0,
                                              input 0,
                                              input 0 ) no-error.
    if error-status:error then do:
      return error substitute ("Ошибка <&1> при обсчете свободной зоны по товару.", return-value).
    end.
  end.
  else do:
    return error substitute ("По товару &1 &2 &3 нет свободной зоны от данного поставщика на объекте &4 &5. Изменять нечего.",
                             varartic,
                             varprod-type,
                             varprod-code,
                             varobj-type,
                             varobj-code).
  end.
  FIND FIRST tt-chs-parts.
  FIND FIRST tt-chs-parts-another WHERE tt-chs-parts-another.purch-code <> tt-chs-parts.purch-code NO-ERROR.
  IF AVAILABLE tt-chs-parts-another THEN DO:
    ASSIGN
      varold-purch-code-name = "разные".
  END.
  ELSE DO:
        ASSIGN
      varold-purch-code-name = entry (lookup (string(tt-chs-parts.purch-code), '1,2,3,4':U), 'выкуп,консигнация,ответственное хранение,старая консигнация':U).
  END.
end.
else do:
  for each tt-clcparts on error undo, return error return-value :
    delete tt-clcparts.
  end.
  create tt-clcparts.
  buffer-copy bf_parts to tt-clcparts.
  assign
    varno-recalc-vat-pc = tt-clcparts.vat-pc
    varno-recalc-slt-pc = tt-clcparts.slt-pc.
  run clcprtsl_calc-parts in this-procedure (
   input recid(tt-clcparts),
   input no,
   input no,
   input 0,
   input 0,
   input 0,
   input 0,
   input 0,
   input 0,
   input 0,
   input ?,
   input 0,
   input 0,
   input 0,
   input 0,
   input 0,
   input 0) no-error.
  if error-status:error then do:
    return error substitute ("Ошибка <&1> при обсчете партии по товару.", return-value).
  end.
  for each tt-allsum-line on error undo, return error return-value :
    delete tt-allsum-line.
  end.
  for each tt-allsum on error undo, return error return-value :
    create tt-allsum-line.
    buffer-copy tt-allsum to tt-allsum-line.
  end.
    ASSIGN
    varold-purch-code-name = entry (lookup (string(bf_parts.purch-code), '1,2,3,4':U), 'выкуп,консигнация,ответственное хранение,старая консигнация':U).
end.
find first bf_tt-allsum-line where bf_tt-allsum-line.sum-type = 'основная_сумма':U no-error.
if error-status:error then do:
  return error substitute ("Не найдена запись по типу &1 для товара &2 &3 &4.", 'основная_сумма':U, varartic, varprod-type, varprod-code).
end.
assign
   varfact-qnty                = bf_tt-allsum-line.fact-qnty
   varcli-base-rate            = parcli-base-rate
   varvat-type                 = parvat-type
   varslt-type                 = parslt-type
   varold-sum-base             = bf_tt-allsum-line.sum-dsc-base-acc
   varold-price-base           = bf_tt-allsum-line.sum-dsc-base-acc / varfact-qnty
   varold-sum-rubl             = bf_tt-allsum-line.sum-dsc-rubl-acc
   varold-price-rubl           = bf_tt-allsum-line.sum-dsc-rubl-acc / varfact-qnty
   varold-sum-cli              = bf_tt-allsum-line.sum-dsc-cli-acc
   varold-price-cli            = (bf_tt-allsum-line.sum-dsc-cli-acc - bf_tt-allsum-line.road-tax-cli-acc - (if varvat-type <> 'в т. ч.':U then bf_tt-allsum-line.vat-cli-acc else 0) - (if varslt-type <> 'в т. ч.':U then bf_tt-allsum-line.slt-cli-acc else 0)) / varfact-qnty * varcli-base-rate
   varold-base-rate            = (if varold-price-rubl / varold-price-base = ? then 1 else varold-price-rubl / varold-price-base)
   varsum-base                 = varold-sum-base
   varprice-base               = varold-price-base
   varsum-rubl                 = varold-sum-rubl
   varprice-rubl               = varold-price-rubl
   varsum-cli                  = varold-sum-cli
   varprice-cli                = varold-price-cli
   varbase-rate                = varold-base-rate
   varbase-scale               = 1
   varold-sum-base-slt         = bf_tt-allsum-line.slt-base-acc
   varold-price-base-slt       = bf_tt-allsum-line.slt-base-acc / varfact-qnty
   varold-sum-rubl-slt         = bf_tt-allsum-line.slt-rubl-acc
   varold-price-rubl-slt       = bf_tt-allsum-line.slt-rubl-acc / varfact-qnty
   varold-sum-cli-slt          = bf_tt-allsum-line.slt-cli-acc
   varold-price-cli-slt        = bf_tt-allsum-line.slt-cli-acc / varfact-qnty * varcli-base-rate
   varold-slt-pc               = (if varno-recalc-slt-pc <> ? then varno-recalc-slt-pc else (varold-sum-rubl-slt / (varold-sum-rubl - varold-sum-rubl-slt) * 100))
   varsum-base-slt             = varold-sum-base-slt
   varprice-base-slt           = varold-price-base-slt
   varsum-rubl-slt             = varold-sum-rubl-slt
   varprice-rubl-slt           = varold-price-rubl-slt
   varsum-cli-slt              = varold-sum-cli-slt
   varprice-cli-slt            = varold-price-cli-slt
   varslt-pc                   = varold-slt-pc
   varold-sum-base-vat         = bf_tt-allsum-line.vat-base-acc
   varold-price-base-vat       = bf_tt-allsum-line.vat-base-acc / varfact-qnty
   varold-sum-rubl-vat         = bf_tt-allsum-line.vat-rubl-acc
   varold-price-rubl-vat       = bf_tt-allsum-line.vat-rubl-acc / varfact-qnty
   varold-sum-cli-vat          = bf_tt-allsum-line.vat-cli-acc
   varold-price-cli-vat        = bf_tt-allsum-line.vat-cli-acc / varfact-qnty * varcli-base-rate
   varold-vat-pc               = (if varno-recalc-vat-pc <> ? then varno-recalc-vat-pc else (varold-sum-rubl-vat / (varold-sum-rubl - varold-sum-rubl-slt - varold-sum-rubl-vat) * 100))
   varsum-base-vat             = varold-sum-base-vat
   varprice-base-vat           = varold-price-base-vat
   varsum-rubl-vat             = varold-sum-rubl-vat
   varprice-rubl-vat           = varold-price-rubl-vat
   varsum-cli-vat              = varold-sum-cli-vat
   varprice-cli-vat            = varold-price-cli-vat
   varvat-pc                   = varold-vat-pc
   varold-sum-base-road-tax    = bf_tt-allsum-line.road-tax-base-acc
   varold-price-base-road-tax  = bf_tt-allsum-line.road-tax-base-acc / varfact-qnty
   varold-sum-rubl-road-tax    = bf_tt-allsum-line.road-tax-rubl-acc
   varold-price-rubl-road-tax  = bf_tt-allsum-line.road-tax-rubl-acc / varfact-qnty
   varold-sum-cli-road-tax     = bf_tt-allsum-line.road-tax-cli-acc
   varold-price-cli-road-tax   = bf_tt-allsum-line.road-tax-cli-acc / varfact-qnty * varcli-base-rate
   varsum-base-road-tax        = varold-sum-base-road-tax
   varprice-base-road-tax      = varold-price-base-road-tax
   varsum-rubl-road-tax        = varold-sum-rubl-road-tax
   varprice-rubl-road-tax      = varold-price-rubl-road-tax
   varsum-cli-road-tax         = varold-sum-cli-road-tax
   varprice-cli-road-tax       = varold-price-cli-road-tax
   varold-sum-base-transport   = bf_tt-allsum-line.transport-base-acc
   varold-price-base-transport = bf_tt-allsum-line.transport-base-acc / varfact-qnty
   varold-sum-rubl-transport   = bf_tt-allsum-line.transport-rubl-acc
   varold-price-rubl-transport = bf_tt-allsum-line.transport-rubl-acc / varfact-qnty
   varsum-base-transport       = varold-sum-base-transport
   varprice-base-transport     = varold-price-base-transport
   varsum-rubl-transport       = varold-sum-rubl-transport
   varprice-rubl-transport     = varold-price-rubl-transport
   varold-sum-base-other       = bf_tt-allsum-line.other-base-acc
   varold-price-base-other     = bf_tt-allsum-line.other-base-acc / varfact-qnty
   varold-sum-rubl-other       = bf_tt-allsum-line.other-rubl-acc
   varold-price-rubl-other     = bf_tt-allsum-line.other-rubl-acc / varfact-qnty
   varsum-base-other           = varold-sum-base-other
   varprice-base-other         = varold-price-base-other
   varsum-rubl-other           = varold-sum-rubl-other
   varprice-rubl-other         = varold-price-rubl-other
   varold-exch-rate            = (if (varold-sum-rubl - varold-sum-rubl-transport - varold-sum-rubl-other - varold-sum-rubl-road-tax) / varold-sum-cli = ? then 1 else (varold-sum-rubl - varold-sum-rubl-transport - varold-sum-rubl-other - varold-sum-rubl-road-tax) / varold-sum-cli)
   varexch-rate                = varold-exch-rate
   varexch-scale               = 1
  .
end.
end procedure.
PROCEDURE state-cur-exch-rate :
do on error undo, return error return-value:
 assign
   varexch-rate  = varcur-exch-rate
   varexch-scale = varcur-exch-scale.
 display varexch-rate varexch-scale with frame Dialog-Frame.
end.
END PROCEDURE.
PROCEDURE state-cur-rate :
do on error undo, return error return-value:
 assign
   varbase-rate  = varcur-base-rate
   varbase-scale = varcur-base-scale.
 display varbase-rate varbase-scale with frame Dialog-Frame.
end.
END PROCEDURE.
