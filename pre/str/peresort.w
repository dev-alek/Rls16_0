define input        parameter parparentproc    as handle    no-undo.
define input-output parameter pardoc-rec       as recid     no-undo.
define input        parameter pardoc-mode      as character no-undo.
define input        parameter parext-doc-type  as character no-undo.
define input-output parameter parnext-prev     as logical   no-undo.
define input-output parameter line-rec         as recid     no-undo.
define input        parameter br-handle        as handle    no-undo.
define input        parameter bf-handle        as handle    no-undo.
define input        parameter parobj-type      as character no-undo.
define input        parameter parobj-code      as integer   no-undo.
define input        parameter parcli-type      as character no-undo.
define input        parameter parcli-code      as integer   no-undo.
define input        parameter parold-supp-cntr as logical   no-undo.
define input        parameter parcontract-code as integer   no-undo.
define variable vss-revision    as character no-undo initial "$Revision$":U .
define variable vss-author      as character no-undo initial "$Author$":U .
define variable vss-date        as character no-undo initial "$Date$":U .
define variable vss-workfile    as character no-undo initial "$Workfile$":U .
define variable vss-archive     as character no-undo initial "$Archive$":U .
define variable vss-description as character no-undo initial "Документ пересортица":U .
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#trdcalib as handle no-undo.
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
def var vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$".
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$".
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
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$".
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
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$".
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
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$".
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
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$".
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
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
      vss-include-info1 skip
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
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-waitfram-action01         as character   no-undo .
define variable v-waitfram-action02         as character   no-undo .
define variable v-waitfram-action03         as character   no-undo .
define variable mWaitFramTextBeg            as character   no-undo.
define variable mWaitFramTextEnd            as character   no-undo.
define variable mWaitFramView               as logical     no-undo.
define variable mWaitProcEvent              as logical     no-undo init yes.
define variable mWaitFramInterval           as integer     no-undo init 1 .
define variable mWaitFramStop               as logical     no-undo.
define variable mWaitFramStopUser           as logical     no-undo.
define variable mWaitFramStopTimeOut        as logical     no-undo.
define variable mWaitFramStartProc          as datetime-tz no-undo.
define variable mWaitFramTimeOut            as decimal     no-undo init ?.
define button B-WaitFramStop auto-end-key
     label "Стоп"
     size 10 by 1 tooltip "Остоновить процесс".
define button B-viewProcInfo
     label "Информация"
     size 15 by 1 tooltip "Информация о процесс".
define frame waitfram
  v-waitfram-action01 format "x(72)" no-label skip
  v-waitfram-action02 format "x(72)" no-label skip
  v-waitfram-action03 format "x(72)" no-label skip
  B-viewProcInfo
  B-WaitFramStop at row 4 col 30
  with view-as dialog-box side-labels three-d cancel-button B-WaitFramStop
  .
define new global shared variable mBatchMode as logical no-undo init ?.
define variable mFramBachModHandle as handle no-undo.
mFramBachModHandle = frame waitfram:handle.
define variable mFameOldVis as logical no-undo.
define variable mVisCUrentVin as logical no-undo.
if session:batch-mode
then
   mBatchMode = yes.
if mBatchMode = ? then do:
  mVisCUrentVin = current-window:visible.
  mFameOldVis = mFramBachModHandle:visible.
  mFramBachModHandle:visible  = yes.
  mBatchMode = mFramBachModHandle:visible ne yes.
  mFramBachModHandle:visible = mFameOldVis.
  current-window:visible = mVisCUrentVin.
end.
 if  log-manager:logfile-name ne ?
  then DO:
      log-manager:write-message("Logname=" + log-manager:logfile-name , "frameRepError").
      log-manager:write-message("Batch-mod=" + string(session:batch-mode) , "frameRepError").
      log-manager:write-message("visible-frame-mod=" + string(mFramBachModHandle:visible), "frameRepError").
  end.
on choose of B-WaitFramStop in frame waitfram
do:
  mWaitFramStop = yes.
  mWaitFramStopUser = yes.
end.
function waitfram-check-timeout returns logical():
   define variable vtime as int64 no-undo.
   if mWaitFramStopTimeOut
   then
      return yes.
   vtime = ( now - mWaitFramStartProc ) / 1000 .
   if     mWaitFramTimeOut ne ?
      and mWaitFramTimeOut ne 0
      and mWaitFramTimeOut lt vtime
   then do:
      mWaitFramStopTimeOut = yes.
   end.
   return mWaitFramStopTimeOut.
end.
procedure waitfram-hide :
  if not session:batch-mode
  then do
  on error undo, return error return-value
  :
    pause 0 before-hide .
    if not mBatchMode then
      hide frame waitfram .
  end.
end procedure.
procedure waitfram-show :
  define input  parameter p-message as character no-undo .
  define variable v-left-margin as integer   no-undo .
  if not session:batch-mode
  then do
  on error undo, return error return-value
  :
    if length(p-message) <= 70 then do:
      assign
        v-left-margin = integer((70 - length(p-message)) / 2)
      .
      assign
        v-left-margin = max(0, v-left-margin - (v-left-margin mod 5))
      .
      assign
        v-waitfram-action01 = " "
        v-waitfram-action02 = " "
                                 + fill(" ", v-left-margin)
                                 + p-message
        v-waitfram-action03 = " "
      .
    end.
    else do:
      define variable vRindex1 as integer no-undo.
      define variable vRindex2 as integer no-undo.
      vRindex1 = r-index(p-message," ",70).
      if vRindex1 = 0
      then
         vRindex1 = 70.
      if length(p-message)  <= vRindex1 + 70 then do:
        assign
          v-waitfram-action01 = " "
          v-waitfram-action02 = " " + substring(p-message,   1          , vRindex1)
          v-waitfram-action03 = " " + substring(p-message,  vRindex1 + 1, 70      )
        .
      end.
      else do:
        vRindex2 = r-index(p-message," ",vRindex1 + 70).
        if vRindex2 <= vRindex1
        then
           vRindex2 = vRindex1 + 70.
        assign
          v-waitfram-action01 = " " + substring(p-message,   1          , vRindex1)
          v-waitfram-action02 = " " + substring(p-message,  vRindex1 + 1, vRindex2 - vRindex1 )
          v-waitfram-action03 = " " + substring(p-message,  vRindex2 + 1, 70)
        .
      end.
    end.
    B-viewProcInfo:visible   in frame waitfram = no.
    B-viewProcInfo:sensitive in frame waitfram = no.
    B-WaitFramStop:visible   in frame waitfram = if not mBatchMode and mWaitFramView then yes else no .
    B-WaitFramStop:sensitive in frame waitfram = if not mBatchMode and mWaitFramView then yes else no .
    if  (   mWaitFramView
       or  mWaitProcEvent)
       and not mBatchMode
    then
       display
          v-waitfram-action01 skip
          v-waitfram-action02 skip
          v-waitfram-action03 skip
       with frame waitfram .
  end.
end procedure.
   procedure waitfram-show-this:
      define input  parameter iInterval as int64 no-undo.
      define variable vtime as int64 no-undo.
      vtime = ( now - mWaitFramStartProc  ) / 1000 .
      mWaitFramInterval = iInterval.
      run waitfram-show (substitute("&1&2 &3&4" ,
                                    mWaitFramTextBeg ,
                                    if vtime eq ? then "" else substitute (" Прошло: &1 сек" , string( vtime)),
                                    if mWaitFramTimeOut ne 0 and mWaitFramTimeOut ne ? then " из " + string(mWaitFramTimeOut) + " сек. " else "",
                                    mWaitFramTextEnd
                                   )
                        ).
   end.
   procedure WaitFramRunPause:
      define input  parameter iInterval as dec no-undo.
      define variable vStart  as datetime-tz no-undo.
      define variable vend    as datetime-tz no-undo.
      define variable vint as int64 no-undo.
      define variable vOk as logical no-undo.
      vStart = now.
      vend   = vStart.
      publish "WaitFramPause" (iInterval,output vOk).
      vend   =  now.
      vint = vend - vStart.
      vint = iInterval - vint / 1000.
      if     not mWaitFramStop
         and (   vint > 0
              or (    not vOk
                  and iInterval eq ?
                  )
              )
      then
         run waitfram-show-this (iInterval).
      vend   =  now.
      vint = vend - vStart.
      vint = iInterval - vint / 1000.
      if     not mWaitFramStop
         and vint > 0
      then do:
         run gbl/pause.p (vint * 1000).
      end.
      if iInterval ne ?
      then
         publish "WaitFramStop".
      waitfram-check-timeout().
   end.
   procedure WaitFramWaitFor:
      define input  parameter iInterval as dec no-undo.
      assign
         mWaitFramStartProc   = now
         mWaitFramStopUser    = no
         mWaitFramStopTimeOut = no
      .
      block-wait:
      do while not mWaitFramStop:
         run WaitFramRunPause (iInterval).
         if  waitfram-check-timeout()
         then do:
            leave block-wait.
         end.
      end.
      run waitfram-hide.
   end.
procedure waitfram-join :
  define input  parameter p-line-1  as character no-undo .
  define input  parameter p-line-2  as character no-undo .
  define input  parameter p-line-3  as character no-undo .
  define output parameter p-message as character no-undo .
  do
  on error undo, return error return-value
  :
    assign
      p-message = substring(p-line-1 + fill(' ', 70), 1, 70)
                + substring(p-line-2 + fill(' ', 70), 1, 70)
                + substring(p-line-3 + fill(' ', 70), 1, 70)
    .
  end.
end procedure.
function waitfram-join-function returns character
  (input p-line-1 as character
  ,input p-line-2 as character
  ,input p-line-3 as character
  ).
  define variable v-message as character no-undo .
  run waitfram-join in this-procedure
    (input  p-line-1
    ,input  p-line-2
    ,input  p-line-3
    ,output v-message
    ) .
  return v-message .
end function .
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure doc-code:
define input  parameter parmode          as   character           no-undo.
define input  parameter parobj-type      like ub.clients.obj-type no-undo.
define input  parameter parobj-code      like ub.clients.obj-code no-undo.
define input  parameter parroot-doc-code like ub.trn-doc.doc-code no-undo.
define output parameter pardoc-code      like ub.trn-doc.doc-code no-undo.
define buffer buf_sys-ctrl for ub.sys-ctrl  .
define variable vardb-remote     as   logical             no-undo.
define variable vartemp-doc-code like ub.trn-doc.doc-code no-undo.
define variable v-delimiter as character no-undo .
do
on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
:
find first buf_sys-ctrl no-lock .
vardb-remote = buf_sys-ctrl.db-num <> 0 .
  CASE parmode:
    when "main":u then do:
      if vardb-remote then do:
        assign
          pardoc-code = trim (string (next-value (s-trn-doc, ub), ">>>>>>>>>9")) + "-" + trim (string (parobj-code, ">>>>9")) + substring (parobj-type, (if g#language = "RUS" then 1 else 2), 1).
      end.
      else do:
        assign
          pardoc-code = trim (string (next-value (s-trn-doc, ub), ">>>>>>>>>9")) + "-".
      end.
    end.
    when "trio" then do:
      assign
        pardoc-code = replace (parroot-doc-code, "=", "*").
    end.
    otherwise do:
      assign
      v-delimiter = entry(lookup(entry(1, parmode), "main,chip,pair,flora,trio-m,quadro,stock-up,stock-down,stock-fix," +                          "main_s,chip_s,pair_s,trio-m_s,quadro_s,stock-up_s,stock-down_s,stock-fix_s":U), ("-,-,=,#,*,^,+,`,":U + chr(126) + ",у-,у-,у=,у*,у^,у+,у`,у" + chr(126)))
      no-error
      .
      if error-status:error  then do:
        undo, return error substitute("Ошибка при генерации номера документа&1Неверное значение параметра parmode &2"
                                      ,chr(10)
                                      ,parmode
                                      ).
      end.
      if num-entries(parmode) = 1
      and parmode <> "chip":U
      and parmode <> "chip_s":U
      then do:
        assign
        pardoc-code = replace (parroot-doc-code, "-", v-delimiter).
      end.
      else if (lookup("chip":U, parmode) > 0
               or
               lookup("chip_s":U, parmode) > 0) then do:
        assign
          vartemp-doc-code = parroot-doc-code.
        do while true:
          if index (vartemp-doc-code , ".") = 0 then
            vartemp-doc-code  = replace (vartemp-doc-code , v-delimiter, v-delimiter + "1.").
          else
            vartemp-doc-code  =
            substring (vartemp-doc-code , 1, index (vartemp-doc-code, v-delimiter)) +
            string (integer (substring (vartemp-doc-code, index (vartemp-doc-code, v-delimiter) + 1, index (vartemp-doc-code, ".") - index (vartemp-doc-code, v-delimiter) - 1)) + 1) +
            substring (vartemp-doc-code, index (vartemp-doc-code, ".")).
          if not can-find (ub.trn-doc where ub.trn-doc.doc-code = vartemp-doc-code no-lock) then leave.
        end.
        assign
          pardoc-code = vartemp-doc-code.
      end.
    end.
  end CASE.
  if pardoc-code = '':U
  or (parroot-doc-code <> '':U
  and pardoc-code = parroot-doc-code) then do:
    undo, return error substitute("Ошибка при генерации номера документа&1"
                                  ,chr(10)).
  end.
end.
end. // procedure/method
function get-doc-code-int64 returns int64
  ( input p-doc-code as character ) :
  define variable v-ind              as integer   no-undo .
  define variable v-num-entries      as integer   no-undo .
  define variable v-doc-code-int64   as int64     no-undo .
  define variable v-canonic-doc-code as character no-undo .
  assign
    v-num-entries      = num-entries( ("-,-,=,#,*,^,+,`,":U + chr(126) + ",у-,у-,у=,у*,у^,у+,у`,у" + chr(126)) )
    v-canonic-doc-code = p-doc-code
  .
  do v-ind = 1 to v-num-entries
  :
    assign
      v-canonic-doc-code = entry(1, v-canonic-doc-code, entry( v-ind, ("-,-,=,#,*,^,+,`,":U + chr(126) + ",у-,у-,у=,у*,у^,у+,у`,у" + chr(126)) ) )
    .
  end.
  assign
    v-doc-code-int64 = int64(v-canonic-doc-code) no-error
  .
  return v-doc-code-int64 .
end. // function/method
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure holdprts-create-parts-supp :
  define input  parameter p-orig-in-code   like ub.parts-supp.orig-in-code   no-undo .
  define input  parameter p-orig-part-code like ub.parts-supp.orig-part-code no-undo .
  define input  parameter p-in-code        like ub.parts-supp.in-code        no-undo .
  define input  parameter p-artic          like ub.parts-supp.artic          no-undo .
  define input  parameter p-prod-type      like ub.parts-supp.prod-type      no-undo .
  define input  parameter p-prod-code      like ub.parts-supp.prod-code      no-undo .
  define input  parameter p-part-code      like ub.parts-supp.part-code      no-undo .
  define variable vss-description as character no-undo init "holdprts-create-parts-supp-01: скопировать атрибут партии".
  define buffer buf_parent_trn-doc  for ub.trn-doc .
  define buffer buf_child_trn-doc   for ub.trn-doc .
  define buffer buf_parts           for ub.parts .
  define buffer buf_parts-supp      for ub.parts-supp .
  define buffer buf_orig_parts-supp for ub.parts-supp .
  define buffer buf_income_trn-doc  for ub.trn-doc .
  define buffer buf_income_doc-line for ub.doc-line .
  define buffer buf_goods           for ub.goods .
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
  do
  on error undo, return error return-value
  :
    find first buf_child_trn-doc no-lock
      where buf_child_trn-doc.doc-code = p-in-code
      no-error .
    if not available buf_child_trn-doc
    then do:
      return substitute("Не найден исходный документ &1", p-in-code) .
    end.
    find first buf_parent_trn-doc no-lock
      where buf_parent_trn-doc.doc-code = buf_child_trn-doc.hold-doc-code-parent
      no-error .
    if not available buf_parent_trn-doc
    then do:
      return substitute("Не найден приходный документ &1", buf_child_trn-doc.hold-doc-code-parent) .
    end.
    find first buf_parts-supp exclusive-lock
      where buf_parts-supp.in-code   = p-in-code
        and buf_parts-supp.artic     = p-artic
        and buf_parts-supp.prod-type = p-prod-type
        and buf_parts-supp.prod-code = p-prod-code
        and buf_parts-supp.part-code = p-part-code
      no-error .
    if available buf_parts-supp
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info18 skip
        "Попытка повторного создания партии атрибутов" skip
        "Документ прихода" p-in-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "Код партии" p-part-code skip
        "Исходный код партии" p-orig-in-code skip
        "Исходный код документа" p-orig-part-code skip
        view-as alert-box error .
      undo, return error .
    end.
    create buf_parts-supp .
    assign
      buf_parts-supp.in-code   = p-in-code
      buf_parts-supp.artic     = p-artic
      buf_parts-supp.prod-type = p-prod-type
      buf_parts-supp.prod-code = p-prod-code
      buf_parts-supp.part-code = p-part-code
    .
    assign
      buf_parts-supp.orig-in-code   = p-orig-in-code
      buf_parts-supp.orig-part-code = p-orig-part-code
    .
    find first buf_orig_parts-supp share-lock
      where buf_orig_parts-supp.in-code   = p-orig-in-code
        and buf_orig_parts-supp.artic     = p-artic
        and buf_orig_parts-supp.prod-type = p-prod-type
        and buf_orig_parts-supp.prod-code = p-prod-code
        and buf_orig_parts-supp.part-code = p-orig-part-code
      no-error .
    if available buf_orig_parts-supp
    then do:
      buffer-copy buf_orig_parts-supp
      except
        buf_orig_parts-supp.in-code
        buf_orig_parts-supp.artic
        buf_orig_parts-supp.prod-type
        buf_orig_parts-supp.prod-code
        buf_orig_parts-supp.part-code
        buf_orig_parts-supp.orig-in-code
        buf_orig_parts-supp.orig-part-code
      to buf_parts-supp.
    end.
    else do:
      find first buf_parts share-lock
        where buf_parts.obj-type  = buf_parent_trn-doc.obj-type
          and buf_parts.obj-code  = buf_parent_trn-doc.obj-code
          and buf_parts.artic     = p-artic
          and buf_parts.prod-type = p-prod-type
          and buf_parts.prod-code = p-prod-code
          and buf_parts.in-code   = p-orig-in-code
          and buf_parts.out-code  = buf_parent_trn-doc.doc-code
          and buf_parts.part-code = p-orig-part-code
        no-error .
      if not available buf_parts
      then do:
        message
          vss-workfile vss-revision vss-description skip
          vss-include-info18 skip
          "Ошибка задания входных параметров" skip
          "Не найдена исходная партия" skip
          "Исходный документ" p-orig-in-code skip
          "Артикул" p-artic p-prod-type p-prod-code skip
          "Код партии" p-orig-part-code skip
          view-as alert-box error .
        undo, return error .
      end.
      define variable v-base-rate         as decimal   no-undo .
      define variable v-base-scale        as integer   no-undo .
      define variable v-exch-rate         as decimal   no-undo .
      define variable v-exch-scale        as integer   no-undo .
      define variable v-extended-doc-type as character no-undo .
      define variable v-unit-cli          as character no-undo .
      find first buf_income_trn-doc no-lock
        where buf_income_trn-doc.doc-code = p-orig-in-code
        no-error .
      if available buf_income_trn-doc
      then do:
        find first buf_income_doc-line no-lock
          where buf_income_doc-line.doc-code  = p-orig-in-code
            and buf_income_doc-line.artic     = p-artic
            and buf_income_doc-line.prod-type = p-prod-type
            and buf_income_doc-line.prod-code = p-prod-code
          no-error .
        if not available buf_income_doc-line
        then do:
          message
            vss-workfile vss-revision vss-description skip
            vss-include-info18 skip
            "Не найдена исходная строка документа прихода" skip
            "Исходный документ" p-orig-in-code skip
            "Артикул" p-artic p-prod-type p-prod-code skip
            "Код партии" p-orig-part-code skip
            view-as alert-box error .
          undo, return error .
        end.
        assign
          v-base-rate         = buf_income_trn-doc.base-rate
          v-base-scale        = buf_income_trn-doc.base-scale
          v-exch-rate         = buf_income_trn-doc.exch-rate
          v-exch-scale        = buf_income_trn-doc.exch-scale
          v-extended-doc-type = buf_income_trn-doc.ext-doc-type
          v-unit-cli          = buf_income_doc-line.unit-cli
        .
      end.
      else do:
        find first buf_goods no-lock
          where buf_goods.artic     = buf_parts.artic
            and buf_goods.prod-type = buf_parts.prod-type
            and buf_goods.prod-code = buf_parts.prod-code
          .
        assign
          v-base-rate         = buf_parts.price-rubl / buf_parts.price-base
          v-base-scale        = 1
          v-exch-rate         = buf_parts.price-rubl / (buf_parts.price-cli * buf_parts.cli-base-rate)
          v-exch-scale        = 1
          v-extended-doc-type = 'ie':U
          v-unit-cli          = buf_goods.unit-cli
        .
      end.
       if v-base-rate = ? then v-base-rate = 1.
       if v-exch-rate = ? then v-exch-rate = 1.
assign
  price-rubl-with-tax-loc = buf_parts.price-rubl
  price-base-with-tax-loc = buf_parts.price-base
.
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprb
  )  .
  if buf_parts.out-code = 'free-zone':U     or
     buf_parts.out-code = 'out-zone':U   or
     buf_parts.doc-type = 'акт':U then do:
    assign
      in-vatp-have-vat-slt = yes.
  end.
  else do:
    find first in-vatp_doc-attr no-lock
      where in-vatp_doc-attr.doc-code  = buf_parts.out-code
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
   price-cli-with-tax-loc = buf_parts.price-cli
   cli-base-rate          = buf_parts.cli-base-rate.
  ASSIGN   road-tax-base-loc  = (if buf_parts.road-tax-base  = ? then 0 else buf_parts.road-tax-base)
           road-tax-rubl-loc  = (if buf_parts.road-tax-rubl  = ? then 0 else buf_parts.road-tax-rubl).
  ASSIGN  transport-base-loc = (if buf_parts.transport-base = ? then 0 else buf_parts.transport-base)
          transport-rubl-loc = (if buf_parts.transport-rubl = ? then 0 else buf_parts.transport-rubl)
          other-base-loc     = (if buf_parts.other-base     = ? then 0 else buf_parts.other-base)
          other-rubl-loc     = (if buf_parts.other-rubl     = ? then 0 else buf_parts.other-rubl)
          vat-pc-loc         = (if buf_parts.vat-pc         = ? then 0 else buf_parts.vat-pc)
          slt-pc-loc         = (if buf_parts.slt-pc         = ? then 0 else buf_parts.slt-pc).
          ASSIGN   slt-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
    ASSIGN   slt-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
  assign
    exch-rate-cli-loc = (buf_parts.price-rubl - transport-rubl-loc - other-rubl-loc - road-tax-rubl-loc - (if buf_parts.vat-type <> 'в т. ч.':U then vat-rubl-loc else 0) - (if buf_parts.slt-type <> 'в т. ч.':U then slt-rubl-loc else 0)) / buf_parts.price-cli .
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
        buf_parts-supp.PS                = buf_parts.PS
        buf_parts-supp.SLT-type          = buf_parts.SLT-type
        buf_parts-supp.VAT-type          = buf_parts.VAT-type
        buf_parts-supp.base-rate         = v-base-rate
        buf_parts-supp.base-scale        = v-base-scale
        buf_parts-supp.cli-qnty          = buf_parts.cli-qnty
        buf_parts-supp.cst-code          = buf_parts.cst-code
        buf_parts-supp.doc-qnty          = buf_parts.qnty
        buf_parts-supp.exch-code         = buf_parts.exch-code
        buf_parts-supp.exch-rate         = v-exch-rate
        buf_parts-supp.exch-scale        = v-exch-scale
        buf_parts-supp.extended-doc-type = v-extended-doc-type
        buf_parts-supp.fact-date         = buf_parts.fact-date
        buf_parts-supp.fact-qnty         = buf_parts.fact-qnty
        buf_parts-supp.last-date         = buf_parts.last-date
        buf_parts-supp.pay-code          = buf_parts.pay-code
        buf_parts-supp.price-cli         = buf_parts.price-cli
        buf_parts-supp.purch-code        = buf_parts.purch-code
        buf_parts-supp.supp-code         = buf_parts.supp-code
        buf_parts-supp.supp-type         = buf_parts.supp-type
        buf_parts-supp.unit-cli          = v-unit-cli
      .
      assign
        buf_parts-supp.vat-pc         = vat-pc-loc
        buf_parts-supp.slt-pc         = slt-pc-loc
        buf_parts-supp.price-base     = price-base-with-tax-loc
        buf_parts-supp.price-rubl     = price-rubl-with-tax-loc
        buf_parts-supp.vat-base       = vat-base-loc
        buf_parts-supp.vat-rubl       = vat-rubl-loc
        buf_parts-supp.slt-base       = slt-base-loc
        buf_parts-supp.slt-rubl       = slt-rubl-loc
        buf_parts-supp.road-tax-base  = road-tax-base-loc
        buf_parts-supp.road-tax-rubl  = road-tax-rubl-loc
        buf_parts-supp.transport-base = transport-base-loc
        buf_parts-supp.transport-rubl = transport-rubl-loc
        buf_parts-supp.other-base     = other-base-loc
        buf_parts-supp.other-rubl     = other-rubl-loc
      .
    end.
  end.
end procedure.
procedure holdprts-get-part-code :
  define input  parameter p-doc-code       as character no-undo .
  define output parameter p-hold-part-code as integer   no-undo .
  define variable vss-description as character no-undo init "holdprts-get-part-code-01: создать уникальный код партии внутри документа".
  define variable v-attr-value as character no-undo .
  define variable v-attr-type  as character no-undo .
  define buffer buf_trn-doc for ub.trn-doc .
  do
  on error undo, return error return-value
  :
    find first buf_trn-doc exclusive-lock
      where buf_trn-doc.doc-code = p-doc-code
      no-error .
    if not available buf_trn-doc
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info18 skip
        "Ошибка задания входных параметров" skip
        "Не найден документ" p-doc-code skip
        view-as alert-box error .
      undo, return error .
    end.
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input p-doc-code ,
                        input 'hold-part-code':U ,
                       output v-attr-value ,
                       output v-attr-type )  .
    assign
      p-hold-part-code = integer(v-attr-value) + 1
    .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-wrt in g#trdcalib ( input p-doc-code ,
                       input 'hold-part-code':U ,
                       input string(p-hold-part-code) )  .
  end.
end procedure.
procedure holdprts-validate-document :
  define input  parameter p-doc-code as character no-undo .
  define variable vss-description as character no-undo init "holdprts-validate-document-01: проверить правильность документа".
  define buffer buf_trn-doc    for ub.trn-doc .
  define buffer parent_trn-doc for ub.trn-doc .
  define buffer buf_parts      for ub.parts .
  define buffer buf_parts-supp for ub.parts-supp .
  do
  on error undo, return error return-value
  :
    find first buf_trn-doc exclusive-lock
      where buf_trn-doc.doc-code = p-doc-code
      no-error .
    if not available buf_trn-doc
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info18 skip
        "Ошибка задания входных параметров" skip
        "Не найден документ" p-doc-code skip
        view-as alert-box error .
      undo, return error .
    end.
    find first parent_trn-doc exclusive-lock
      where parent_trn-doc.doc-code = buf_trn-doc.hold-doc-code-parent
      no-error .
    if not available parent_trn-doc
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info18 skip
        "Не найден родительский документ" skip
        "Документ" buf_trn-doc.doc-code skip
        "Родительский документ" buf_trn-doc.hold-doc-code-parent skip
        view-as alert-box error .
      undo, return error .
    end.
    if buf_trn-doc.ext-doc-type <> 'ie':U
    then do:
      return .
    end.
    for each buf_parts share-lock
      where buf_parts.out-code = buf_trn-doc.doc-code
    on error undo, return error
    :
      find first buf_parts-supp share-lock
        where buf_parts-supp.in-code   = buf_parts.in-code
          and buf_parts-supp.artic     = buf_parts.artic
          and buf_parts-supp.prod-type = buf_parts.prod-type
          and buf_parts-supp.prod-code = buf_parts.prod-code
          and buf_parts-supp.part-code = buf_parts.part-code
        no-error .
      if not available buf_parts-supp
      then do:
        message
          vss-workfile vss-revision vss-description skip
          vss-include-info18 skip
          "Не найдена информация о поставщике" skip
          "Документ" buf_trn-doc.doc-code skip
          "Родительский документ" buf_trn-doc.hold-doc-code-parent skip
          "Артикул" buf_parts.artic buf_parts.prod-type buf_parts.prod-code skip
          "Номер партии" buf_parts.part-code skip
          view-as alert-box error .
        undo, return error .
      end.
    end.
    for each buf_parts-supp share-lock
      where buf_parts-supp.in-code = buf_trn-doc.doc-code
    on error undo, return error
    :
      find first buf_parts share-lock
        where buf_parts.out-code  = buf_parts-supp.in-code
          and buf_parts.obj-type  = buf_trn-doc.obj-type
          and buf_parts.obj-code  = buf_trn-doc.obj-code
          and buf_parts.artic     = buf_parts-supp.artic
          and buf_parts.prod-type = buf_parts-supp.prod-type
          and buf_parts.prod-code = buf_parts-supp.prod-code
          and buf_parts.part-code = buf_parts-supp.part-code
        no-error .
      if not available buf_parts
      then do:
        message
          vss-workfile vss-revision vss-description skip
          vss-include-info18 skip
          "Задана информация о поставщике для неизвестной партии" skip
          "Документ" buf_trn-doc.doc-code skip
          "Родительский документ" buf_trn-doc.hold-doc-code-parent skip
          "Артикул" buf_parts.artic buf_parts.prod-type buf_parts.prod-code skip
          "Номер партии" buf_parts.part-code skip
          view-as alert-box error .
        undo, return error .
      end.
    end.
    for each buf_parts share-lock
      where buf_parts.out-code = buf_trn-doc.hold-doc-code-parent
    on error undo, return error
    :
      if  buf_trn-doc.doc-type = 'при':U
      and buf_parts.qnty = buf_parts.fact-qnty
      then do:
        next.
      end.
      find first buf_parts-supp share-lock
        where buf_parts-supp.orig-in-code   = buf_parts.in-code
          and buf_parts-supp.artic          = buf_parts.artic
          and buf_parts-supp.prod-type      = buf_parts.prod-type
          and buf_parts-supp.prod-code      = buf_parts.prod-code
          and buf_parts-supp.orig-part-code = buf_parts.part-code
        no-error .
      if not available buf_parts-supp
      then do:
        message
          vss-workfile vss-revision vss-description skip
          vss-include-info18 skip
          "Не найдена информация о поставщике для исходной накладной" skip
          "Документ" buf_trn-doc.doc-code skip
          "Родительский документ" buf_trn-doc.hold-doc-code-parent skip
          "Артикул" buf_parts.artic buf_parts.prod-type buf_parts.prod-code skip
          "Номер партии" buf_parts.part-code skip
          view-as alert-box error .
        undo, return error .
      end.
    end.
  end.
end procedure.
procedure holdprts-doc-type :
  define input  parameter p-cat-code as integer   no-undo .
  define input  parameter p-doc-code as character no-undo .
  define output parameter p-is-sale  as logical   no-undo .
  define output parameter p-is-purch as logical   no-undo .
  define variable vss-description as character no-undo init "holdprts-doc-type-01: определение типа документа для межфирменного архива".
  define buffer buf_trn-doc for ub.trn-doc .
  do
  on error undo, return error return-value
  :
    find first buf_trn-doc no-lock
      where buf_trn-doc.doc-code = p-doc-code
      no-error .
    if not available buf_trn-doc
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info18 skip
        "Ошибка задания входных параметров" skip
        "Не найден документ" skip
        "Документ" p-doc-code skip
        "Тип архива" p-cat-code skip
        view-as alert-box error .
      undo, return error .
    end.
    case p-cat-code :
      when 1
      then do:
        define variable v-is-hold as logical   no-undo .
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hold-doc in g#library
  (input  buf_trn-doc.doc-code
  ,output v-is-hold
  )  .
        if v-is-hold = true
        then do:
          assign
            p-is-sale  = false
            p-is-purch = false
          .
        end.
        else do:
          case buf_trn-doc.ext-doc-type :
            when 'ie':U or
            when 'ep':U
            then do:
              assign
                p-is-sale  = false
                p-is-purch = true
              .
            end.
            when 'ee':U or
            when 'es':U or
            when 're':U or
            when 'rs':U
            then do:
              assign
                p-is-sale  = true
                p-is-purch = false
              .
            end.
            when 'we':U or
            when 'vt':U or
            when 'vp':U or
            when 'ap':U or
            when 'mp':U or
            when 'pc':U or
            when 'iv':U or
            when 'ev':U or
            when 'io':U or
            when 'eo':U or
            when 'rv':U or
            when 'em':U or
            when 'wm':U or
            when 'im':U
            then do:
              assign
                p-is-sale  = false
                p-is-purch = false
              .
            end.
            otherwise do:
              message
                vss-workfile vss-revision vss-description skip
                vss-include-info18 skip
                "Неизвестный тип документа" skip
                "Документ" buf_trn-doc.doc-code skip
                "Тип документа" buf_trn-doc.ext-doc-type skip
                "Тип архива" p-cat-code skip
                view-as alert-box error .
              undo, return error .
            end.
          end.
        end.
      end.
      when 2
      then do:
        case buf_trn-doc.ext-doc-type :
          when 'vt':U or
          when 'vp':U
          then do:
            assign
              p-is-sale  = false
              p-is-purch = true
            .
          end.
          otherwise do:
            assign
              p-is-sale  = false
              p-is-purch = false
            .
          end.
        end.
      end.
      when 3
      then do:
        case buf_trn-doc.ext-doc-type :
          when 'we':U
          then do:
            assign
              p-is-sale  = false
              p-is-purch = true
            .
          end.
          otherwise do:
            assign
              p-is-sale  = false
              p-is-purch = false
            .
          end.
        end.
      end.
      otherwise do:
        message
          vss-workfile vss-revision vss-description skip
          "Неизвестный тип архивов" skip
          "Документ" buf_trn-doc.doc-code skip
          "Тип документа" buf_trn-doc.ext-doc-type skip
          "Тип архива" p-cat-code skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end.
  end.
end procedure.
procedure holdprts-purch-values :
  define input  parameter p-doc-code             like ub.doc-line.doc-code  no-undo .
  define input  parameter p-artic                like ub.doc-line.artic     no-undo .
  define input  parameter p-prod-type            like ub.doc-line.prod-type no-undo .
  define input  parameter p-prod-code            like ub.doc-line.prod-code no-undo .
  define output parameter p-fact-qnty            as decimal   no-undo .
  define output parameter p-purch-sum-base       as decimal   no-undo .
  define output parameter p-purch-sum-rubl       as decimal   no-undo .
  define output parameter p-purch-VAT-base       as decimal   no-undo .
  define output parameter p-purch-VAT-rubl       as decimal   no-undo .
  define output parameter p-purch-SLT-base       as decimal   no-undo .
  define output parameter p-purch-SLT-rubl       as decimal   no-undo .
  define output parameter p-purch-road-tax-base  as decimal   no-undo .
  define output parameter p-purch-road-tax-rubl  as decimal   no-undo .
  define output parameter p-purch-excise-base    as decimal   no-undo .
  define output parameter p-purch-excise-rubl    as decimal   no-undo .
  define output parameter p-purch-transport-base as decimal   no-undo .
  define output parameter p-purch-transport-rubl as decimal   no-undo .
  define output parameter p-purch-other-base     as decimal   no-undo .
  define output parameter p-purch-other-rubl     as decimal   no-undo .
  define output parameter p-purch-discnt-base    as decimal   no-undo .
  define output parameter p-purch-discnt-rubl    as decimal   no-undo .
  define variable vss-description as character no-undo init "holdprts-purch-values-01: параметры закупки товара".
  define variable v-price-base     as decimal   no-undo .
  define variable v-price-rubl     as decimal   no-undo .
  define variable v-VAT-base       as decimal   no-undo .
  define variable v-VAT-rubl       as decimal   no-undo .
  define variable v-SLT-base       as decimal   no-undo .
  define variable v-SLT-rubl       as decimal   no-undo .
  define variable v-road-tax-base  as decimal   no-undo .
  define variable v-road-tax-rubl  as decimal   no-undo .
  define variable v-transport-base as decimal   no-undo .
  define variable v-transport-rubl as decimal   no-undo .
  define variable v-other-base     as decimal   no-undo .
  define variable v-other-rubl     as decimal   no-undo .
  define buffer buf_trn-doc        for ub.trn-doc .
  define buffer buf_parts          for ub.parts .
  define buffer buf_parts-supp     for ub.parts-supp .
  define buffer buf_doc-line       for ub.doc-line .
  define buffer buf_income_trn-doc for ub.trn-doc .
  do
  on error undo, return error return-value
  :
    find first buf_trn-doc no-lock
      where buf_trn-doc.doc-code = p-doc-code
      no-error .
    if not available buf_trn-doc
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info18 skip
        "Ошибка задания входных параметров" skip
        "Не найден документ" skip
        "Документ" p-doc-code skip
        view-as alert-box error .
      undo, return error .
    end.
    find first buf_doc-line no-lock
      where buf_doc-line.doc-code  = p-doc-code
        and buf_doc-line.artic     = p-artic
        and buf_doc-line.prod-type = p-prod-type
        and buf_doc-line.prod-code = p-prod-code
      no-error .
    if not available buf_doc-line
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info18 skip
        "Ошибка задания входных параметров" skip
        "Не найдена строка документа" skip
        "Документ" p-doc-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        view-as alert-box error .
      undo, return error .
    end.
    assign
      p-fact-qnty            = 0
      p-purch-sum-base       = 0
      p-purch-sum-rubl       = 0
      p-purch-VAT-base       = 0
      p-purch-VAT-rubl       = 0
      p-purch-SLT-base       = 0
      p-purch-SLT-rubl       = 0
      p-purch-road-tax-base  = 0
      p-purch-road-tax-rubl  = 0
      p-purch-excise-base    = 0
      p-purch-excise-rubl    = 0
      p-purch-transport-base = 0
      p-purch-transport-rubl = 0
      p-purch-other-base     = 0
      p-purch-other-rubl     = 0
      p-purch-discnt-base    = 0
      p-purch-discnt-rubl    = 0
    .
    for each buf_parts no-lock
      where buf_parts.out-code  = buf_doc-line.doc-code
        and buf_parts.obj-type  = buf_doc-line.obj-type
        and buf_parts.obj-code  = buf_doc-line.obj-code
        and buf_parts.artic     = buf_doc-line.artic
        and buf_parts.prod-type = buf_doc-line.prod-type
        and buf_parts.prod-code = buf_doc-line.prod-code
    on error undo, return error
    :
      define variable v-parts-qnty as decimal   no-undo .
      assign
        v-parts-qnty = buf_parts.fact-qnty
                     * ( if lookup(buf_trn-doc.doc-type, 'рас,спи':U ) > 0
                         then -1
                         else 1
                       )
      .
      find first buf_parts-supp no-lock
        where buf_parts-supp.in-code   = buf_parts.in-code
          and buf_parts-supp.artic     = buf_parts.artic
          and buf_parts-supp.prod-type = buf_parts.prod-type
          and buf_parts-supp.prod-code = buf_parts.prod-code
          and buf_parts-supp.part-code = buf_parts.part-code
        no-error .
      if available buf_parts-supp
      then do:
        assign
          v-price-base     = buf_parts-supp.price-base
          v-price-rubl     = buf_parts-supp.price-rubl
          v-VAT-base       = buf_parts-supp.VAT-base
          v-VAT-rubl       = buf_parts-supp.VAT-rubl
          v-SLT-base       = buf_parts-supp.SLT-base
          v-SLT-rubl       = buf_parts-supp.SLT-rubl
          v-road-tax-base  = buf_parts-supp.road-tax-base
          v-road-tax-rubl  = buf_parts-supp.road-tax-rubl
          v-transport-base = buf_parts-supp.transport-base
          v-transport-rubl = buf_parts-supp.transport-rubl
          v-other-base     = buf_parts-supp.other-base
          v-other-rubl     = buf_parts-supp.other-rubl
        .
      end.
      else do:
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
assign
  price-rubl-with-tax-loc = buf_parts.price-rubl
  price-base-with-tax-loc = buf_parts.price-base
.
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprb
  )  .
  if buf_parts.out-code = 'free-zone':U     or
     buf_parts.out-code = 'out-zone':U   or
     buf_parts.doc-type = 'акт':U then do:
    assign
      in-vatp-have-vat-slt = yes.
  end.
  else do:
    find first in-vatp_doc-attr no-lock
      where in-vatp_doc-attr.doc-code  = buf_parts.out-code
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
   price-cli-with-tax-loc = buf_parts.price-cli
   cli-base-rate          = buf_parts.cli-base-rate.
  ASSIGN   road-tax-base-loc  = (if buf_parts.road-tax-base  = ? then 0 else buf_parts.road-tax-base)
           road-tax-rubl-loc  = (if buf_parts.road-tax-rubl  = ? then 0 else buf_parts.road-tax-rubl).
  ASSIGN  transport-base-loc = (if buf_parts.transport-base = ? then 0 else buf_parts.transport-base)
          transport-rubl-loc = (if buf_parts.transport-rubl = ? then 0 else buf_parts.transport-rubl)
          other-base-loc     = (if buf_parts.other-base     = ? then 0 else buf_parts.other-base)
          other-rubl-loc     = (if buf_parts.other-rubl     = ? then 0 else buf_parts.other-rubl)
          vat-pc-loc         = (if buf_parts.vat-pc         = ? then 0 else buf_parts.vat-pc)
          slt-pc-loc         = (if buf_parts.slt-pc         = ? then 0 else buf_parts.slt-pc).
          ASSIGN   slt-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
    ASSIGN   slt-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
  assign
    exch-rate-cli-loc = (buf_parts.price-rubl - transport-rubl-loc - other-rubl-loc - road-tax-rubl-loc - (if buf_parts.vat-type <> 'в т. ч.':U then vat-rubl-loc else 0) - (if buf_parts.slt-type <> 'в т. ч.':U then slt-rubl-loc else 0)) / buf_parts.price-cli .
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
          v-price-base     = price-base-with-tax-loc
          v-price-rubl     = price-rubl-with-tax-loc
          v-VAT-base       = vat-base-loc
          v-VAT-rubl       = vat-rubl-loc
          v-SLT-base       = slt-base-loc
          v-SLT-rubl       = slt-rubl-loc
          v-road-tax-base  = road-tax-base-loc
          v-road-tax-rubl  = road-tax-rubl-loc
          v-transport-base = transport-base-loc
          v-transport-rubl = transport-rubl-loc
          v-other-base     = other-base-loc
          v-other-rubl     = other-rubl-loc
        .
      end.
      assign
        p-fact-qnty            = p-fact-qnty            + v-parts-qnty
        p-purch-sum-base       = p-purch-sum-base       + v-price-base     * v-parts-qnty
        p-purch-sum-rubl       = p-purch-sum-rubl       + v-price-rubl     * v-parts-qnty
        p-purch-VAT-base       = p-purch-VAT-base       + v-VAT-base       * v-parts-qnty
        p-purch-VAT-rubl       = p-purch-VAT-rubl       + v-VAT-rubl       * v-parts-qnty
        p-purch-SLT-base       = p-purch-SLT-base       + v-SLT-base       * v-parts-qnty
        p-purch-SLT-rubl       = p-purch-SLT-rubl       + v-SLT-rubl       * v-parts-qnty
        p-purch-road-tax-base  = p-purch-road-tax-base  + v-road-tax-base  * v-parts-qnty
        p-purch-road-tax-rubl  = p-purch-road-tax-rubl  + v-road-tax-rubl  * v-parts-qnty
        p-purch-excise-base    = p-purch-excise-base    + 0
        p-purch-excise-rubl    = p-purch-excise-rubl    + 0
        p-purch-transport-base = p-purch-transport-base + v-transport-base * v-parts-qnty
        p-purch-transport-rubl = p-purch-transport-rubl + v-transport-rubl * v-parts-qnty
        p-purch-other-base     = p-purch-other-base     + v-other-base     * v-parts-qnty
        p-purch-other-rubl     = p-purch-other-rubl     + v-other-rubl     * v-parts-qnty
        p-purch-discnt-base    = p-purch-discnt-base    + 0
        p-purch-discnt-rubl    = p-purch-discnt-rubl    + 0
      .
    end.
  end.
end procedure.
procedure holdprts-sale-values :
  define input  parameter p-doc-code            like ub.doc-line.doc-code  no-undo .
  define input  parameter p-artic               like ub.doc-line.artic     no-undo .
  define input  parameter p-prod-type           like ub.doc-line.prod-type no-undo .
  define input  parameter p-prod-code           like ub.doc-line.prod-code no-undo .
  define output parameter p-fact-qnty           as decimal   no-undo .
  define output parameter p-sale-sum-base       as decimal   no-undo .
  define output parameter p-sale-sum-rubl       as decimal   no-undo .
  define output parameter p-sale-VAT-base       as decimal   no-undo .
  define output parameter p-sale-VAT-rubl       as decimal   no-undo .
  define output parameter p-sale-SLT-base       as decimal   no-undo .
  define output parameter p-sale-SLT-rubl       as decimal   no-undo .
  define output parameter p-sale-road-tax-base  as decimal   no-undo .
  define output parameter p-sale-road-tax-rubl  as decimal   no-undo .
  define output parameter p-sale-excise-base    as decimal   no-undo .
  define output parameter p-sale-excise-rubl    as decimal   no-undo .
  define output parameter p-sale-transport-base as decimal   no-undo .
  define output parameter p-sale-transport-rubl as decimal   no-undo .
  define output parameter p-sale-other-base     as decimal   no-undo .
  define output parameter p-sale-other-rubl     as decimal   no-undo .
  define output parameter p-sale-discnt-base    as decimal   no-undo .
  define output parameter p-sale-discnt-rubl    as decimal   no-undo .
  define variable vss-description as character no-undo init "holdprts-sale-values-01: параметры продажи товара".
  define variable v-gds-dtl-fact-qnty as decimal   no-undo .
  define buffer buf_doc-line for ub.doc-line .
  define buffer buf_gds-dtl  for ub.gds-dtl.
  define buffer buf_goods    for ub.goods.
  define buffer buf_trn-doc  for ub.trn-doc.
    define  variable price-rubl-with-tax-sale    like ub.doc-line.price-rubl no-undo.
    define  variable price-base-with-tax-sale    like ub.doc-line.price-base no-undo.
    define  variable price-rubl-without-tax-sale like ub.doc-line.price-rubl no-undo.
    define  variable price-base-without-tax-sale like ub.doc-line.price-base no-undo.
    define  variable vat-base-sale               like ub.doc-line.price-base no-undo.
    define  variable vat-rubl-sale               like ub.doc-line.price-rubl no-undo.
    define  variable vat-base-buyer              like ub.doc-line.price-base no-undo.
    define  variable vat-rubl-buyer              like ub.doc-line.price-rubl no-undo.
    define  variable slt-base-sale               like ub.doc-line.price-base no-undo.
    define  variable slt-rubl-sale               like ub.doc-line.price-rubl no-undo.
    define  variable road-tax-base-sale          like ub.doc-line.road-tax   no-undo.
    define  variable road-tax-rubl-sale          like ub.doc-line.road-tax   no-undo.
    define  variable excise-base-sale            like ub.doc-line.price-base no-undo.
    define  variable excise-rubl-sale            like ub.doc-line.price-rubl no-undo.
    define  variable discnt-base-sale            like ub.gds-dtl.discnt-base no-undo.
    define  variable discnt-rubl-sale            like ub.gds-dtl.discnt-rubl no-undo.
    define buffer out-vatp_gds-dtl     for ub.gds-dtl.
    define buffer buf_out-vatp_gds-dtl for ub.gds-dtl.
    define buffer out-vatp_parts       for ub.parts.
    define buffer out-vatp_sysconf     for ub.sysconf.
    define buffer out-vatp_doc-line    for ub.doc-line.
    define buffer out-vatp_goods       for ub.goods.
    define buffer out-vatp_trn-doc     for ub.trn-doc.
    define buffer out-vatp_doc-attr    for ub.doc-attr.
    define variable varprice-base-cons      like ub.doc-line.price-base initial 0.00 no-undo.
    define variable varprice-rubl-cons      like ub.doc-line.price-rubl initial 0.00 no-undo.
    define variable varfrm-cnsv-type         as   character                           no-undo.
    define variable varfrm-cnsv              as   character                           no-undo.
    define variable varroot-node             as   integer                             no-undo.
    define variable varempty-scale           as   logical                             no-undo.
    define variable varis-cons-parts-have    as   logical                             no-undo.
    define variable varsum-base-factovp      like ub.gds-dtl.price-base               no-undo.
    define variable varslt-base-factovp      like ub.gds-dtl.price-base               no-undo.
    define variable varvat-base-factovp      like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-base-factovp  like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-base-factovp      like ub.gds-dtl.price-base               no-undo.
    define variable varsum-base-docovp       like ub.gds-dtl.price-base               no-undo.
    define variable varslt-base-docovp       like ub.gds-dtl.price-base               no-undo.
    define variable varvat-base-docovp       like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-base-docovp   like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-base-docovp       like ub.gds-dtl.price-base               no-undo.
    define variable varsum-rubl-factovp      like ub.gds-dtl.price-base               no-undo.
    define variable varslt-rubl-factovp      like ub.gds-dtl.price-base               no-undo.
    define variable varvat-rubl-factovp      like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-rubl-factovp  like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-rubl-factovp      like ub.gds-dtl.price-base               no-undo.
    define variable varsum-rubl-docovp       like ub.gds-dtl.price-base               no-undo.
    define variable varslt-rubl-docovp       like ub.gds-dtl.price-base               no-undo.
    define variable varvat-rubl-docovp       like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-rubl-docovp   like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-rubl-docovp       like ub.gds-dtl.price-base               no-undo.
    define variable varfact-qnty             like ub.parts.fact-qnty                  no-undo.
    define variable varcons-qnty             like ub.parts.fact-qnty                  no-undo.
    define variable varis-one-gds-dtl        as   logical                             no-undo.
    define variable varcurprice-base         like ub.gds-dtl.cur-base                 no-undo.
    define variable varcurprice-rubl         like ub.gds-dtl.price-base               no-undo.
    define variable varcurdiscnt-base        like ub.gds-dtl.cur-base                 no-undo.
    define variable varcurdiscnt-rubl        like ub.gds-dtl.price-base               no-undo.
    define variable varoutvprb               as   character                           no-undo.
    define variable out-vatp-have-vat-slt    as   logical initial yes                 no-undo.
    define buffer   in-vatp-trn-doco  for ub.trn-doc .
    define buffer   in-vatp-partso    for ub.parts   .
    define buffer   in-vatp-doco      for ub.trn-doc .
    define buffer   in-vatp-goodso    for ub.goods   .
    define buffer   in-vatp-sysconfo  for ub.sysconf .
    define buffer   in-vatp_doc-attro for ub.doc-attr.
    define variable in-vatp-have-vat-slto       as   logical initial yes    no-undo.
    define variable vat-pc-loco                 like ub.doc-line.vat-pc     no-undo.
    define variable varinvprbo                  as   character              no-undo.
    define variable slt-pc-loco                 like ub.doc-line.slt-pc     no-undo.
    define variable cli-base-rateo              as   decimal                no-undo.
    define variable price-rubl-with-tax-loco    like ub.doc-line.price-rubl no-undo.
    define variable price-base-with-tax-loco    like ub.doc-line.price-base no-undo.
    define variable price-cli-with-tax-loco     like ub.doc-line.price-cli  no-undo.
    define variable price-rubl-without-tax-loco like ub.doc-line.price-rubl no-undo.
    define variable price-base-without-tax-loco like ub.doc-line.price-base no-undo.
    define variable price-cli-without-tax-loco  like ub.doc-line.price-base no-undo.
    define variable vat-base-loco               like ub.doc-line.price-base no-undo.
    define variable vat-rubl-loco               like ub.doc-line.price-rubl no-undo.
    define variable vat-cli-loco                like ub.doc-line.price-rubl no-undo.
    define variable slt-base-loco               like ub.doc-line.price-base no-undo.
    define variable slt-rubl-loco               like ub.doc-line.price-rubl no-undo.
    define variable slt-cli-loco                like ub.doc-line.price-rubl no-undo.
    define variable road-tax-base-loco          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-rubl-loco          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-cli-loco           like ub.doc-line.road-tax   no-undo.
    define variable transport-base-loco         like ub.doc-line.price-base no-undo.
    define variable transport-rubl-loco         like ub.doc-line.price-rubl no-undo.
    define variable transport-cli-loco          like ub.doc-line.price-rubl no-undo.
    define variable other-base-loco             like ub.doc-line.price-base no-undo.
    define variable other-rubl-loco             like ub.doc-line.price-rubl no-undo.
    define variable other-cli-loco              like ub.doc-line.price-rubl no-undo.
    define variable exch-rate-cli-loco          like ub.trn-doc.exch-rate   no-undo.
    define variable varinvatp-envdo             as   character              no-undo.
    define variable varinvatp-typeo             as   character              no-undo.
  do
  on error undo, return error return-value
  :
    find first buf_trn-doc no-lock
      where buf_trn-doc.doc-code = p-doc-code
    no-error .
    if not available buf_trn-doc
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info18 skip
        "Ошибка задания входных параметров" skip
        "Не найден документ" skip
        "Документ" p-doc-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        view-as alert-box error .
      undo, return error .
    end.
    find first buf_doc-line no-lock
      where buf_doc-line.doc-code  = p-doc-code
        and buf_doc-line.artic     = p-artic
        and buf_doc-line.prod-type = p-prod-type
        and buf_doc-line.prod-code = p-prod-code
      no-error .
    if not available buf_doc-line
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info18 skip
        "Ошибка задания входных параметров" skip
        "Не найдена строка документа" skip
        "Документ" p-doc-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        view-as alert-box error .
      undo, return error .
    end.
    for each buf_gds-dtl no-lock
      where buf_gds-dtl.doc-code  = buf_doc-line.doc-code
        and buf_gds-dtl.artic     = buf_doc-line.artic
        and buf_gds-dtl.prod-type = buf_doc-line.prod-type
        and buf_gds-dtl.prod-code = buf_doc-line.prod-code
    on error undo, return error
    :
      if buf_trn-doc.doc-type <> 'инв':U
      then do:
        if buf_trn-doc.doc-type = 'при':U
        or buf_trn-doc.doc-type = 'возврат':U
        then do:
          assign
            v-gds-dtl-fact-qnty = buf_gds-dtl.fact-qnty
          .
        end.
        else do:
          assign
            v-gds-dtl-fact-qnty = - buf_gds-dtl.fact-qnty
          .
        end.
      end.
      else do:
        assign
          v-gds-dtl-fact-qnty = buf_gds-dtl.doc-qnty
        .
      end.
      if v-gds-dtl-fact-qnty <> 0
      then do:
if buf_trn-doc.ext-doc-type = 'ot':U or
   buf_trn-doc.ext-doc-type = ?                 then do:
  assign
   out-vatp-have-vat-slt = yes.
end.
else do:
  find first out-vatp_doc-attr no-lock
    where out-vatp_doc-attr.doc-code  = buf_trn-doc.doc-code
      and out-vatp_doc-attr.attr-code = 'envd':U
      no-error .
  if not available out-vatp_doc-attr then do:
    assign
      out-vatp-have-vat-slt = yes.
  end.
  else do:
     out-vatp-have-vat-slt = no.
  end.
end.
find first out-vatp_goods where out-vatp_goods.artic     = buf_doc-line.artic     and
                                   out-vatp_goods.prod-type = buf_doc-line.prod-type and
                                   out-vatp_goods.prod-code = buf_doc-line.prod-code no-lock.
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rootnode in g#library
  (input  buf_doc-line.artic
  ,input  buf_doc-line.prod-type
  ,input  buf_doc-line.prod-code
  ,output varroot-node
  ) no-error .
if error-status :error then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка при определении корневого признака товара" skip
    "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  undo, return error .
end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prtat in g#library
  (input  varroot-node
  ,input  'empty-scale=request'
  ,output varempty-scale
  ) no-error .
if error-status :error then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка при определении атрибута признака" skip
    "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
    "Признак" varroot-node skip
    "Запрашивался атрибут" "empty-scale=request" skip
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  undo, return error .
end.
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varoutvprb
  )  .
if varoutvprb = "base":u then do:
  assign
        road-tax-base-sale    =  (if buf_doc-line.road-tax = ? then 0 else buf_doc-line.road-tax * 1)
    excise-base-sale      =  (if buf_doc-line.excise   = ? then 0 else buf_doc-line.excise   * 1)
  .
end.
else do:
  assign
        road-tax-base-sale    =  (if buf_doc-line.road-tax = ? then 0 else buf_doc-line.road-tax / buf_trn-doc.base-rate * buf_trn-doc.base-scale)
    excise-base-sale      =  (if buf_doc-line.excise   = ? then 0 else buf_doc-line.excise   / buf_trn-doc.base-rate * buf_trn-doc.base-scale)
  .
end.
if varoutvprb = "rubl":u then do:
  assign
        road-tax-rubl-sale    = (if buf_doc-line.road-tax = ? then 0 else buf_doc-line.road-tax * 1)
    excise-rubl-sale      = (if buf_doc-line.excise   = ? then 0 else buf_doc-line.excise   * 1) .
end.
else do:
  assign
        road-tax-rubl-sale    = (if buf_doc-line.road-tax = ? then 0 else buf_doc-line.road-tax * buf_trn-doc.base-rate / buf_trn-doc.base-scale)
    excise-rubl-sale      = (if buf_doc-line.excise   = ? then 0 else buf_doc-line.excise   * buf_trn-doc.base-rate / buf_trn-doc.base-scale) .
end.
assign
  varis-cons-parts-have =  no.
assign
  varfact-qnty       = 0
  varcons-qnty       = 0
  varprice-base-cons = 0
  varprice-rubl-cons = 0.
find first out-vatp_doc-line where
           out-vatp_doc-line.doc-code   = buf_trn-doc.doc-code
       and out-vatp_doc-line.artic      = buf_doc-line.artic
       and out-vatp_doc-line.prod-type  = buf_doc-line.prod-type
       and out-vatp_doc-line.prod-code  = buf_doc-line.prod-code no-lock no-error.
if available out-vatp_doc-line           and
  (out-vatp_doc-line.status_ = 'запрос':U or out-vatp_goods.gds-type = 'у':U) then do:
  assign
    varfact-qnty = out-vatp_doc-line.fact-qnty.
end.
else do:
  for each out-vatp_parts where out-vatp_parts.out-code   = buf_trn-doc.doc-code
                               and out-vatp_parts.obj-type   = buf_trn-doc.obj-type
                               and out-vatp_parts.obj-code   = buf_trn-doc.obj-code
                               and out-vatp_parts.artic      = buf_doc-line.artic
                               and out-vatp_parts.prod-type  = buf_doc-line.prod-type
                               and out-vatp_parts.prod-code  = buf_doc-line.prod-code no-lock :
    if out-vatp_parts.purch-code = 2 then do:
assign
  price-rubl-with-tax-loco = out-vatp_parts.price-rubl
  price-base-with-tax-loco = out-vatp_parts.price-base
.
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprbo
  )  .
  if out-vatp_parts.out-code = 'free-zone':U     or
     out-vatp_parts.out-code = 'out-zone':U   or
     out-vatp_parts.doc-type = 'акт':U then do:
    assign
      in-vatp-have-vat-slto = yes.
  end.
  else do:
    find first in-vatp_doc-attro no-lock
      where in-vatp_doc-attro.doc-code  = out-vatp_parts.out-code
        and in-vatp_doc-attro.attr-code = 'envd':U
      no-error .
    if not available in-vatp_doc-attro then do:
      assign
        in-vatp-have-vat-slto = yes.
    end.
    else do:
         in-vatp-have-vat-slto = no.
    end.
  end.
  assign
   price-cli-with-tax-loco = out-vatp_parts.price-cli
   cli-base-rateo          = out-vatp_parts.cli-base-rate.
  ASSIGN   road-tax-base-loco  = (if out-vatp_parts.road-tax-base  = ? then 0 else out-vatp_parts.road-tax-base)
           road-tax-rubl-loco  = (if out-vatp_parts.road-tax-rubl  = ? then 0 else out-vatp_parts.road-tax-rubl).
  ASSIGN  transport-base-loco = (if out-vatp_parts.transport-base = ? then 0 else out-vatp_parts.transport-base)
          transport-rubl-loco = (if out-vatp_parts.transport-rubl = ? then 0 else out-vatp_parts.transport-rubl)
          other-base-loco     = (if out-vatp_parts.other-base     = ? then 0 else out-vatp_parts.other-base)
          other-rubl-loco     = (if out-vatp_parts.other-rubl     = ? then 0 else out-vatp_parts.other-rubl)
          vat-pc-loco         = (if out-vatp_parts.vat-pc         = ? then 0 else out-vatp_parts.vat-pc)
          slt-pc-loco         = (if out-vatp_parts.slt-pc         = ? then 0 else out-vatp_parts.slt-pc).
          ASSIGN   slt-base-loco    = (if in-vatp-have-vat-slto = no then 0 else (price-base-with-tax-loco - ((if road-tax-base-loco  = ? then 0 else road-tax-base-loco) + (if transport-base-loco = ? then 0 else transport-base-loco) + (if other-base-loco = ? then 0 else other-base-loco)))                           * slt-pc-loco / (100 + slt-pc-loco))                        vat-base-loco    = (if in-vatp-have-vat-slto = no then 0 else (price-base-with-tax-loco - ((if road-tax-base-loco  = ? then 0 else road-tax-base-loco) + (if transport-base-loco = ? then 0 else transport-base-loco) + (if other-base-loco = ? then 0 else other-base-loco))) * (1 - slt-pc-loco / (100 + slt-pc-loco)) * vat-pc-loco / (100 + vat-pc-loco)).
    ASSIGN   slt-rubl-loco    = (if in-vatp-have-vat-slto = no then 0 else (price-rubl-with-tax-loco - ((if road-tax-rubl-loco  = ? then 0 else road-tax-rubl-loco) + (if transport-rubl-loco = ? then 0 else transport-rubl-loco) + (if other-rubl-loco = ? then 0 else other-rubl-loco)))                           * slt-pc-loco / (100 + slt-pc-loco))                        vat-rubl-loco    = (if in-vatp-have-vat-slto = no then 0 else (price-rubl-with-tax-loco - ((if road-tax-rubl-loco  = ? then 0 else road-tax-rubl-loco) + (if transport-rubl-loco = ? then 0 else transport-rubl-loco) + (if other-rubl-loco = ? then 0 else other-rubl-loco))) * (1 - slt-pc-loco / (100 + slt-pc-loco)) * vat-pc-loco / (100 + vat-pc-loco)).
  assign
    exch-rate-cli-loco = (out-vatp_parts.price-rubl - transport-rubl-loco - other-rubl-loco - road-tax-rubl-loco - (if out-vatp_parts.vat-type <> 'в т. ч.':U then vat-rubl-loco else 0) - (if out-vatp_parts.slt-type <> 'в т. ч.':U then slt-rubl-loco else 0)) / out-vatp_parts.price-cli .
  assign
    slt-cli-loco        = slt-rubl-loco       / exch-rate-cli-loco
    vat-cli-loco        = vat-rubl-loco       / exch-rate-cli-loco
    road-tax-cli-loco   = road-tax-rubl-loco  / exch-rate-cli-loco
    transport-cli-loco  = 0
    other-cli-loco      = 0
  .
ASSIGN
          price-base-without-tax-loco = price-base-with-tax-loco - vat-base-loco - slt-base-loco - ((if road-tax-base-loco  = ? then 0 else road-tax-base-loco) + (if transport-base-loco = ? then 0 else transport-base-loco) + (if other-base-loco = ? then 0 else other-base-loco))
    price-rubl-without-tax-loco = price-rubl-with-tax-loco - vat-rubl-loco - slt-rubl-loco - ((if road-tax-rubl-loco  = ? then 0 else road-tax-rubl-loco) + (if transport-rubl-loco = ? then 0 else transport-rubl-loco) + (if other-rubl-loco = ? then 0 else other-rubl-loco))
.
      assign
        varprice-base-cons = varprice-base-cons + (price-base-with-tax-loco - (if road-tax-base-loco = ? then 0 else road-tax-base-loco))* out-vatp_parts.fact-qnty
        varprice-rubl-cons = varprice-rubl-cons + (price-rubl-with-tax-loco - (if road-tax-rubl-loco = ? then 0 else road-tax-rubl-loco))* out-vatp_parts.fact-qnty.
      assign
        varis-cons-parts-have = yes
        varcons-qnty          = varcons-qnty + out-vatp_parts.fact-qnty.
    end.
    assign
      varfact-qnty = varfact-qnty + out-vatp_parts.fact-qnty.
  end.
end.
assign
  varprice-base-cons = varprice-base-cons / varcons-qnty
  varprice-rubl-cons = varprice-rubl-cons / varcons-qnty.
if varprice-base-cons = ? then do:
  assign
    varprice-base-cons = 0.
end.
if varprice-rubl-cons = ? then do:
  assign
    varprice-rubl-cons = 0.
end.
assign
    slt-base-sale               = (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-base - buf_gds-dtl.discnt-base                - road-tax-base-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc)
  vat-base-buyer              = (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-base - buf_gds-dtl.discnt-base - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-base - buf_gds-dtl.discnt-base                - road-tax-base-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-base-sale) * buf_doc-line.vat-pc / (100 + buf_doc-line.vat-pc)
  discnt-base-sale            = buf_gds-dtl.discnt-base
  price-base-with-tax-sale    = (buf_gds-dtl.price-base - buf_gds-dtl.discnt-base)
    slt-rubl-sale               = (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc)
  vat-rubl-buyer              = (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-rubl-sale) * buf_doc-line.vat-pc / (100 + buf_doc-line.vat-pc)
  discnt-rubl-sale            = buf_gds-dtl.discnt-rubl
  price-rubl-with-tax-sale    = (buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl)
  .
if buf_trn-doc.doc-type = 'инв':U then do:
  assign
    varfact-qnty = buf_gds-dtl.doc-qnty.
end.
else do:
  assign
    varfact-qnty = buf_gds-dtl.fact-qnty.
end.
if varis-cons-parts-have = no then do:
  assign
        vat-base-sale               = (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-base - buf_gds-dtl.discnt-base - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-base - buf_gds-dtl.discnt-base                - road-tax-base-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-base-sale) * buf_doc-line.vat-pc / (100 + buf_doc-line.vat-pc)
        vat-rubl-sale               = (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-rubl-sale) * buf_doc-line.vat-pc / (100 + buf_doc-line.vat-pc).
end.
else do:
  if buf_trn-doc.doc-type = 'инв':U then do:
    assign
            vat-base-sale               = (if out-vatp-have-vat-slt = no then 0 else (((buf_gds-dtl.price-base - buf_gds-dtl.discnt-base) - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-base - buf_gds-dtl.discnt-base                - road-tax-base-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-base-sale - varprice-base-cons) * buf_doc-line.cons-vat-pc / (100 + buf_doc-line.cons-vat-pc) * buf_gds-dtl.doc-qnty * varcons-qnty / varfact-qnty + ((buf_gds-dtl.price-base - buf_gds-dtl.discnt-base) - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-base - buf_gds-dtl.discnt-base                - road-tax-base-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-base-sale) * buf_doc-line.vat-pc / (100 + buf_doc-line.vat-pc) * buf_gds-dtl.doc-qnty * (varfact-qnty - varcons-qnty) / varfact-qnty) / varfact-qnty)
            vat-rubl-sale               = (if out-vatp-have-vat-slt = no then 0 else (((buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-rubl-sale - varprice-rubl-cons) * buf_doc-line.cons-vat-pc / (100 + buf_doc-line.cons-vat-pc) * buf_gds-dtl.doc-qnty * varcons-qnty / varfact-qnty + ((buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-rubl-sale) * buf_doc-line.vat-pc / (100 + buf_doc-line.vat-pc) * buf_gds-dtl.doc-qnty * (varfact-qnty - varcons-qnty) / varfact-qnty) / varfact-qnty)
     .
  end.
  else do:
    assign
            vat-base-sale               = (if out-vatp-have-vat-slt = no then 0 else (((buf_gds-dtl.price-base - buf_gds-dtl.discnt-base) - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-base - buf_gds-dtl.discnt-base                - road-tax-base-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-base-sale - varprice-base-cons) * buf_doc-line.cons-vat-pc / (100 + buf_doc-line.cons-vat-pc) * buf_gds-dtl.fact-qnty * varcons-qnty / varfact-qnty + ((buf_gds-dtl.price-base - buf_gds-dtl.discnt-base) - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-base - buf_gds-dtl.discnt-base                - road-tax-base-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - varprice-base-cons) * buf_doc-line.vat-pc / (100 + buf_doc-line.vat-pc) * buf_gds-dtl.fact-qnty * (varfact-qnty - varcons-qnty) / varfact-qnty) / varfact-qnty)
            vat-rubl-sale               = (if out-vatp-have-vat-slt = no then 0 else (((buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-rubl-sale - varprice-rubl-cons) * buf_doc-line.cons-vat-pc / (100 + buf_doc-line.cons-vat-pc) * buf_gds-dtl.fact-qnty * varcons-qnty / varfact-qnty + ((buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - varprice-rubl-cons) * buf_doc-line.vat-pc / (100 + buf_doc-line.vat-pc) * buf_gds-dtl.fact-qnty * (varfact-qnty - varcons-qnty) / varfact-qnty) / varfact-qnty)
     .
  end.
end.
assign
price-base-without-tax-sale = price-base-with-tax-sale - vat-base-sale - slt-base-sale - road-tax-base-sale
price-rubl-without-tax-sale = price-rubl-with-tax-sale - vat-rubl-sale - slt-rubl-sale - road-tax-rubl-sale.
        assign
          p-fact-qnty           = p-fact-qnty          + v-gds-dtl-fact-qnty
          p-sale-sum-base       = p-sale-sum-base      + price-base-with-tax-sale  * v-gds-dtl-fact-qnty
          p-sale-sum-rubl       = p-sale-sum-rubl      + price-rubl-with-tax-sale  * v-gds-dtl-fact-qnty
          p-sale-vat-base       = p-sale-vat-base      + vat-base-sale             * v-gds-dtl-fact-qnty
          p-sale-vat-rubl       = p-sale-vat-rubl      + vat-rubl-sale             * v-gds-dtl-fact-qnty
          p-sale-slt-base       = p-sale-slt-base      + slt-base-sale             * v-gds-dtl-fact-qnty
          p-sale-slt-rubl       = p-sale-slt-rubl      + slt-rubl-sale             * v-gds-dtl-fact-qnty
          p-sale-road-tax-base  = p-sale-road-tax-base + road-tax-base-sale        * v-gds-dtl-fact-qnty
          p-sale-road-tax-rubl  = p-sale-road-tax-rubl + road-tax-rubl-sale        * v-gds-dtl-fact-qnty
          p-sale-excise-base    = p-sale-excise-base   + excise-base-sale          * v-gds-dtl-fact-qnty
          p-sale-excise-rubl    = p-sale-excise-rubl   + excise-rubl-sale          * v-gds-dtl-fact-qnty
          p-sale-discnt-base    = p-sale-discnt-base   + discnt-base-sale          * v-gds-dtl-fact-qnty
          p-sale-discnt-rubl    = p-sale-discnt-rubl   + discnt-rubl-sale          * v-gds-dtl-fact-qnty
        .
      end.
    end.
    assign
      p-sale-transport-base = 0
      p-sale-transport-rubl = 0
      p-sale-other-base     = 0
      p-sale-other-rubl     = 0
    .
  end.
end procedure.
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure factord :
  define input  parameter p-fact-date            as date    no-undo .
  define input  parameter p-fact-time            as integer no-undo .
  define input  parameter p-fact-num             as integer no-undo .
  define input  parameter p-shift-date           as date    no-undo .
  define input  parameter p-shift-num            as integer no-undo .
  define input  parameter p-shift-on             as logical no-undo .
  define output parameter p-fact-order           as decimal no-undo .
  define output parameter p-shift-end-fact-order as decimal no-undo .
  define output parameter p-day-end-fact-order   as decimal no-undo .
  define variable vss-description as character no-undo init "factord: Определение порядкового номера документа".
  if p-fact-date = ?
  then do:
    return error "Не указана фактическая дата" .
  end.
  define variable v-fact-date-num as integer no-undo .
  assign
    v-fact-date-num = integer(p-fact-date)
  .
  if p-fact-num = ?
  or p-fact-num = 0
  then do:
    return error "Не задан p-fact-num " + string(p-fact-num) .
  end.
  if p-fact-num < 0
  then do:
    return error "Отрицательный fact-num " + string(p-fact-num) .
  end.
  if p-fact-num >= 100000000
  then do:
    return error "Недопустимо большой fact-num " + string(p-fact-num) .
  end.
  if p-shift-on = true
  then do:
    if p-shift-date = ?
    then do:
      return error "Не задана дата смены" .
    end.
    if p-shift-num = ?
    or p-shift-num = 0
    then do:
      return error "Не задан номер смены" .
    end.
  end.
  else do:
    assign
      p-shift-date = p-fact-date
      p-shift-num  = 24
    .
  end.
  define variable v-shift-offset as integer no-undo .
  if p-shift-date = p-fact-date
  then do:
    assign
      v-shift-offset = 1
    .
  end.
  if p-shift-date < p-fact-date
  then do:
    assign
      v-shift-offset = 0
    .
  end.
  if p-shift-date > p-fact-date
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Неправильная дата закрытия смены" skip
      "Дата закрытия не смены не может быть раньше чем дата открытия смены" skip
      view-as alert-box error .
    undo, return error
      substitute("Дата закрытия не смены &1 не может быть раньше чем дата открытия смены &2"
        ,string(p-fact-date, '99/99/9999':U)
        ,string(p-shift-date, '99/99/9999':U)
        )
    .
  end.
  if p-shift-num < 1
  or p-shift-num > 24
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Неправильный номер смены" skip
      "p-shift-num" p-shift-num skip
      view-as alert-box error .
    undo, return error return-value .
  end.
  assign
    p-fact-order           = v-fact-date-num
                           + v-shift-offset * 0.5
                           + p-shift-num    * 0.02 - 0.01
                           + p-fact-num     * 0.0000000001
    p-shift-end-fact-order = v-fact-date-num
                           + v-shift-offset * 0.5
                           + p-shift-num    * 0.02
    p-day-end-fact-order   = v-fact-date-num
                           + 0.99
  .
  if p-fact-order           <= v-fact-date-num
  or p-shift-end-fact-order <= v-fact-date-num
  or p-fact-order           >= p-shift-end-fact-order - 0.0000000001
  or p-shift-end-fact-order >= p-day-end-fact-order
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Внутренняя ошибка при генерации фактического номера" skip
      "p-fact-date"            p-fact-date            skip
      "p-fact-time"            p-fact-time            skip
      "p-fact-num"             p-fact-num             skip
      "p-shift-date"           p-shift-date           skip
      "p-shift-num"            p-shift-num            skip
      "p-shift-on"             p-shift-on             skip
      "p-shift-end-fact-order" p-shift-end-fact-order skip
      "p-day-end-fact-order"   p-day-end-fact-order   skip
      "v-fact-date-num"        v-fact-date-num        skip
      view-as alert-box error .
    undo, return error return-value .
  end.
end procedure.
procedure day-begin-fact-order :
  define input  parameter p-fact-date            as date    no-undo .
  define output parameter p-day-begin-fact-order as decimal no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-date = ?
    then do:
      assign
        p-day-begin-fact-order = 0
      .
    end.
    else do:
      assign
        p-day-begin-fact-order = integer(p-fact-date)
      .
    end.
  end.
end procedure.
procedure factord-max-fact-order :
  define output parameter p-max-fact-order as decimal   no-undo .
  do
  on error undo, return error return-value
  :
    run day-begin-fact-order in this-procedure
      (input  date(1, 1, 5000)
      ,output p-max-fact-order
      ) .
  end.
end procedure.
procedure factord-cut-archive :
  define input  parameter p-obj-type             as character no-undo .
  define input  parameter p-obj-code             as integer   no-undo .
  define input  parameter p-fact-date            as date      no-undo .
  define output parameter p-shift-on             as logical   no-undo .
  define output parameter p-shift-date           as date      no-undo .
  define output parameter p-shift-num            as integer   no-undo .
  define output parameter p-day-end-fact-order   as decimal   no-undo .
  define output parameter p-shift-end-fact-order as decimal   no-undo .
  define variable v-fact-order as decimal   no-undo .
  define buffer buf_shift-obj for ub.shift-obj .
  do
  on error undo, return error return-value
  :
define variable vss-include-info26 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  'shift-on=request'
  ,output p-shift-on
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при определении атрибута объекта" skip
        "Объект" p-obj-type p-obj-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if p-shift-on = false
    then do:
      assign
        p-shift-date               = ?
        p-shift-num                = 0
      .
    end.
    else do:
      find first buf_shift-obj share-lock
        where buf_shift-obj.obj-type   = p-obj-type
          and buf_shift-obj.obj-code   = p-obj-code
          and buf_shift-obj.shift-date > p-fact-date
        use-index pi
        no-error .
      if not available buf_shift-obj
      or buf_shift-obj.status_ <> 'зкр':U
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Невозможно вычислить последнюю смену" skip
          "Отсутствует закрытая смена с датой большей чем дата инициализации архива" skip
          "Объект" p-obj-type p-obj-code skip
          "Дата" p-fact-date skip
          view-as alert-box error .
        undo, return error return-value .
      end.
      find last buf_shift-obj share-lock
        where buf_shift-obj.obj-type = p-obj-type
          and buf_shift-obj.obj-code = p-obj-code
          and buf_shift-obj.shift-date <= p-fact-date
        use-index pi
        no-error .
      if available buf_shift-obj
      then do:
        if  buf_shift-obj.status_ = 'зкр':U
        then do:
          assign
            p-shift-date = buf_shift-obj.shift-date
            p-shift-num  = buf_shift-obj.shift-num
          .
        end.
        else do:
          message
            vss-workfile vss-revision vss-description skip
            "Невозможно вычислить последнюю смену" skip
            "Статус смены отличен от статуса" 'зкр':U skip
            "Объект" p-obj-type p-obj-code skip
            "Дата" p-fact-date skip
            "Смена" buf_shift-obj.shift-date buf_shift-obj.shift-num skip
            view-as alert-box error .
          undo, return error return-value .
        end.
      end.
      else do:
        assign
          p-shift-date = p-fact-date - 1
          p-shift-num  = 1
        .
      end.
    end.
    run factord in this-procedure
      (input  p-fact-date
      ,input  1
      ,input  1
      ,input  p-shift-date
      ,input  p-shift-num
      ,input  p-shift-on
      ,output v-fact-order
      ,output p-shift-end-fact-order
      ,output p-day-end-fact-order
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры factord"
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
  end.
end procedure.
procedure factord-lock-shift :
  define input  parameter p-obj-type  as character no-undo .
  define input  parameter p-obj-code  as integer   no-undo .
  define input  parameter p-fact-date as date      no-undo .
  define parameter buffer buf_shift-obj for ub.shift-obj .
  define variable v-shift-on      as logical   no-undo .
  define variable v-extra-message as character no-undo .
  define variable v-error as character no-undo .
  do
  on error undo, return error return-value
  :
define variable vss-include-info27 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  'shift-on=request'
  ,output v-shift-on
  ) no-error .
    if error-status :error
    then do:
      v-error = substitute("Ошибка при определении атрибута объекта  &1 &2 &3 &4" ,p-obj-type , p-obj-code  , error-status :get-message(1) , return-value) .
      undo, return error v-error .
    end.
    if v-shift-on = true
    then do:
      find first buf_shift-obj share-lock
        where buf_shift-obj.obj-type   = p-obj-type
          and buf_shift-obj.obj-code   = p-obj-code
          and buf_shift-obj.shift-date > p-fact-date
        use-index pi
        no-error .
      if not available buf_shift-obj
      or buf_shift-obj.status_ <> 'зкр':U
      then do:
        find last buf_shift-obj
          where buf_shift-obj.obj-type = p-obj-type
            and buf_shift-obj.obj-code = p-obj-code
            and buf_shift-obj.status_  = 'зкр':U
          use-index stts
          no-error .
        if available buf_shift-obj
        then do:
          assign
            v-extra-message =
                  substitute("Дата начала последеней закрытой смены на объекте &1"
                            ,string(buf_shift-obj.shift-date, '99/99/9999':u)
                            )
          .
        end.
        v-error = substitute("Ошибка при блокировке смены объекта  &1 &2 Отсутствует закрытая смена с датой большей чем указанная дата  &5  &3 &4" ,p-obj-type , p-obj-code  , error-status :get-message(1) , return-value , p-fact-date) .
        undo, return error v-error .
      end.
    end.
  end.
end procedure.
procedure factord-end-day :
  define input  parameter p-fact-date            as date    no-undo .
  define output parameter p-day-end-fact-order   as decimal no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-date = ?
    then do:
      return error "Не указана фактическая дата" .
    end.
    assign
      p-day-end-fact-order = integer(p-fact-date) + 0.99
    .
  end.
end procedure.
procedure factord-to-date :
  define input  parameter p-fact-order as decimal no-undo .
  define output parameter p-fact-date  as date    no-undo .
  define variable v-ref-date  as date      no-undo .
  define variable v-ref-delta as integer   no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-order = ?
    or p-fact-order = 0
    then do:
      return error "Не указан fact-order" .
    end.
    assign
      v-ref-date  = date(1, 1, 2000)
    .
    assign
      v-ref-delta = integer(truncate(p-fact-order, 0)) - integer(v-ref-date)
    .
    assign
      p-fact-date = v-ref-date + v-ref-delta
    .
  end.
end procedure.
procedure factord-to-fact-num :
  define input  parameter p-fact-order as decimal no-undo .
  define output parameter p-fact-num   as integer no-undo .
  define variable v-fact-order-trunc as decimal no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-order = ?
    or p-fact-order = 0
    then do:
      return error "Не указан fact-order" .
    end.
    assign
     v-fact-order-trunc = truncate(p-fact-order, 2)
    .
    assign
      p-fact-num = (p-fact-order - v-fact-order-trunc ) * 10000000000
    .
  end.
end procedure.
procedure factord-to-shift-num :
  define input  parameter p-fact-order as decimal no-undo .
  define output parameter p-shift-num   as integer no-undo .
  define variable  p-shift-numd  as decimal   no-undo .
  define variable v-fact-order-trunc as decimal no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-order = ?
    or p-fact-order = 0
    then do:
      return error "Не указан fact-order" .
    end.
    assign
     v-fact-order-trunc = truncate(p-fact-order, 2)  - truncate(p-fact-order,0)
    .
    if v-fact-order-trunc < 0.5 then do:
      v-fact-order-trunc = v-fact-order-trunc + 0.5.
    end.
    assign
      p-shift-numd = (( v-fact-order-trunc  * 100 - 50 ) + 1 ) / 2
      .
     assign
      p-shift-num = truncate (p-shift-numd , 0)
    .
  end.
end procedure.
define temp-table tt-gds-dtl no-undo
field gds-code like ub.goods.gds-code
field prt-code like ub.gds-dtl.prt-code
field qnty     as   decimal
index pi is unique primary gds-code prt-code.
define temp-table tt-gds-dtl-plus no-undo
field gds-code like ub.goods.gds-code
field prt-code like ub.gds-dtl.prt-code
field qnty     as   decimal
index pi is unique primary gds-code prt-code.
define temp-table tt-pl-qty no-undo
field pl-code like ub.place.pl-code
field qnty-l  as   decimal
field qnty-kg as   decimal
index pi is unique primary pl-code.
define temp-table tt-pl-qty-plus no-undo
field pl-code like ub.place.pl-code
field qnty-l  as   decimal
field rsrv-l  as   decimal
field qnty-kg as   decimal
index pi is unique primary pl-code.
define variable vss-include-info28 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function octal-to-char return character
( p-string as character ) :
  def var v-asc     as integer no-undo .
  def var v-new-asc as integer no-undo .
  def var ind       as integer no-undo .
  if length(p-string) <> 3 then do:
    return ? .
  end.
  assign
    v-asc = 0
  .
  do ind = 1 to length(p-string)
  :
    assign
      v-new-asc = asc(substring(p-string, ind, 1)) - asc('0')
    .
    if v-new-asc < 0 or v-new-asc >= 8 then do:
      return ? .
    end.
    assign
      v-asc = v-asc * 8 + v-new-asc
    .
  end.
  return chr(v-asc) .
end function .
function char-to-octal return character
( p-chr as character ) :
  def var v-asc    as integer   no-undo .
  def var ind      as integer   no-undo .
  def var v-string as character no-undo .
  if length(p-chr) <> 1 then do:
    return ? .
  end.
  assign
    v-asc    = asc(p-chr)
    v-string = ""
  .
  do ind = 1 to 3
  :
    assign
      v-string = chr( v-asc mod 8 + asc('0')) + v-string
    .
    assign
      v-asc = truncate(v-asc / 8, 0)
    .
  end.
  return v-string .
end.
function str-encode return character
(   p-init-string       as character
  , p-encode-char       as character
  , p-special-char-list as character
) :
  def var p-encode-string as character no-undo .
  def var ind                as integer no-undo .
  def var v-num-special-char as integer no-undo .
  def var v-special-char     as character no-undo .
  if p-encode-char = ?
  or p-encode-char = "" then do:
    assign
      p-encode-char = "~~"
    .
  end.
  if p-init-string = ? then do:
    return "?" .
  end.
  if p-init-string = "?" then do:
    return p-encode-char + char-to-octal("?") .
  end.
  assign
    v-num-special-char = length(p-special-char-list)
    p-encode-string    = replace(p-init-string
                                ,p-encode-char
                                ,p-encode-char + char-to-octal(p-encode-char)
                                )
  .
  do ind = 1 to v-num-special-char
  :
    assign
      v-special-char = substring(p-special-char-list, ind, 1)
    .
    if v-special-char <> p-encode-char then do:
      assign
        p-encode-string = replace (p-encode-string
                                  ,v-special-char
                                  ,p-encode-char + char-to-octal(v-special-char)
                                  )
      .
    end.
  end.
  return p-encode-string .
end.
function str-decode returns character
  (p-init-string   as character
  ,p-encode-char   as character
  ) :
  def var p-decode-string as character no-undo .
  def var ind                       as integer no-undo .
  def var v-num-entries-init-string as integer no-undo .
  def var v-sub-phrase              as character no-undo .
  def var v-special-char            as character no-undo .
  if p-encode-char = ?
  or p-encode-char = "" then do:
    assign
      p-encode-char = "~~"
    .
  end.
  if p-init-string = "?" then do:
    return ? .
  end.
  assign
    v-num-entries-init-string = num-entries(p-init-string, p-encode-char)
  .
  if v-num-entries-init-string > 1 then do:
    assign
      p-decode-string = entry(1, p-init-string, p-encode-char)
    .
    do ind = 2 to v-num-entries-init-string
    :
      assign
        v-sub-phrase = entry(ind, p-init-string, p-encode-char)
      .
      assign
        v-special-char = octal-to-char(substring(v-sub-phrase, 1, 3))
      .
      if v-special-char <> ? then do:
        assign
          p-decode-string = p-decode-string
                          + v-special-char
                          + substring(v-sub-phrase, 4)
        .
      end.
      else do:
        assign
          p-decode-string = p-decode-string
                          + p-encode-char
                          + v-sub-phrase
        .
      end.
    end.
  end.
  else do:
    assign
      p-decode-string = p-init-string
    .
  end.
  return p-decode-string .
end.
define variable vss-include-info29 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info30 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
define variable par-type          as character no-undo.
define variable v-value-character as character no-undo .
define variable v-value-date      as date      no-undo .
define variable v-value-decimal   as decimal   no-undo .
define variable v-value-integer   as integer   no-undo .
define variable v-value-logical   as logical   no-undo .
define buffer bf_trn-doc         for ub.trn-doc.
define buffer bf_doc-line        for ub.doc-line.
define buffer bf_goods           for ub.goods.
define buffer bf-plus_doc-line   for ub.doc-line.
define buffer bf-plus_goods      for ub.goods.
define buffer bf_parts           for ub.parts.
define buffer bf-plus_parts      for ub.parts.
define buffer bf_parts-root      for ub.parts-root.
define buffer bf_sysconf         for ub.sysconf.
define buffer bf-obj_clients     for ub.clients.
define buffer bf-host_clients    for ub.clients.
define variable varmark                      as character no-undo.
define variable varwrite-off-qnty            as decimal   no-undo.
define variable varwrite-off-sum-rubl        as decimal   no-undo.
define variable varwrite-off-sum-base        as decimal   no-undo.
define variable varwrite-off-vat-rubl        as decimal   no-undo.
define variable varwrite-off-vat-base        as decimal   no-undo.
define variable varincome-qnty               as decimal   no-undo.
define variable varincome-sum-rubl           as decimal   no-undo.
define variable varincome-sum-base           as decimal   no-undo.
define variable varincome-vat-rubl           as decimal   no-undo.
define variable varincome-vat-base           as decimal   no-undo.
define variable vardeviation-percent         as decimal   no-undo.
define variable vardeviation-abs-rub         as decimal   no-undo.
define variable vardeviation-abs-base        as decimal   no-undo.
define variable varwrite-off-for-income-qnty as decimal   no-undo.
define variable list-mode                    as character no-undo.
define variable g#log                        as logical   no-undo.
define variable prt-rec                      as recid     no-undo.
define variable varconf-attr                 as character no-undo.
define variable varpar-type                  as character no-undo.
define variable varlog                       as logical   no-undo.
define variable varprice                     as decimal   no-undo.
define variable varprice-plus                as decimal   no-undo.
define variable varr-b                       as character no-undo.
define variable varoldfact-qnty-exp           like ub.doc-line-sum.fact-qnty           no-undo.
define variable varoldcost-sum-base-exp       like ub.doc-line-sum.cost-sum-base       no-undo.
define variable varoldcost-sum-rubl-exp       like ub.doc-line-sum.cost-sum-rubl       no-undo.
define variable varoldcost-vat-base-exp       like ub.doc-line-sum.cost-vat-base       no-undo.
define variable varoldcost-vat-rubl-exp       like ub.doc-line-sum.cost-vat-rubl       no-undo.
define variable varoldcost-slt-base-exp       like ub.doc-line-sum.cost-slt-base       no-undo.
define variable varoldcost-slt-rubl-exp       like ub.doc-line-sum.cost-slt-rubl       no-undo.
define variable varoldcost-road-tax-base-exp  like ub.doc-line-sum.cost-road-tax-base  no-undo.
define variable varoldcost-road-tax-rubl-exp  like ub.doc-line-sum.cost-road-tax-rubl  no-undo.
define variable varoldcost-excise-base-exp    like ub.doc-line-sum.cost-excise-base    no-undo.
define variable varoldcost-excise-rubl-exp    like ub.doc-line-sum.cost-excise-rubl    no-undo.
define variable varoldcost-transport-base-exp like ub.doc-line-sum.cost-transport-base no-undo.
define variable varoldcost-transport-rubl-exp like ub.doc-line-sum.cost-transport-rubl no-undo.
define variable varoldcost-other-base-exp     like ub.doc-line-sum.cost-other-base     no-undo.
define variable varoldcost-other-rubl-exp     like ub.doc-line-sum.cost-other-rubl     no-undo.
define variable varoldsale-sum-base-exp       like ub.doc-line-sum.sale-sum-base       no-undo.
define variable varoldsale-sum-rubl-exp       like ub.doc-line-sum.sale-sum-rubl       no-undo.
define variable varoldsale-vat-base-exp       like ub.doc-line-sum.sale-vat-base       no-undo.
define variable varoldsale-vat-rubl-exp       like ub.doc-line-sum.sale-vat-rubl       no-undo.
define variable varoldsale-slt-base-exp       like ub.doc-line-sum.sale-slt-base       no-undo.
define variable varoldsale-slt-rubl-exp       like ub.doc-line-sum.sale-slt-rubl       no-undo.
define variable varoldsale-road-tax-base-exp  like ub.doc-line-sum.sale-road-tax-base  no-undo.
define variable varoldsale-road-tax-rubl-exp  like ub.doc-line-sum.sale-road-tax-rubl  no-undo.
define variable varoldsale-excise-base-exp    like ub.doc-line-sum.sale-excise-base    no-undo.
define variable varoldsale-excise-rubl-exp    like ub.doc-line-sum.sale-excise-rubl    no-undo.
define variable varoldsale-transport-base-exp like ub.doc-line-sum.sale-transport-base no-undo.
define variable varoldsale-transport-rubl-exp like ub.doc-line-sum.sale-transport-rubl no-undo.
define variable varoldsale-other-base-exp     like ub.doc-line-sum.sale-other-base     no-undo.
define variable varoldsale-other-rubl-exp     like ub.doc-line-sum.sale-other-rubl     no-undo.
define variable varoldfact-qnty-inp           like ub.doc-line-sum.fact-qnty           no-undo.
define variable varoldcost-sum-base-inp       like ub.doc-line-sum.cost-sum-base       no-undo.
define variable varoldcost-sum-rubl-inp       like ub.doc-line-sum.cost-sum-rubl       no-undo.
define variable varoldcost-vat-base-inp       like ub.doc-line-sum.cost-vat-base       no-undo.
define variable varoldcost-vat-rubl-inp       like ub.doc-line-sum.cost-vat-rubl       no-undo.
define variable varoldcost-slt-base-inp       like ub.doc-line-sum.cost-slt-base       no-undo.
define variable varoldcost-slt-rubl-inp       like ub.doc-line-sum.cost-slt-rubl       no-undo.
define variable varoldcost-road-tax-base-inp  like ub.doc-line-sum.cost-road-tax-base  no-undo.
define variable varoldcost-road-tax-rubl-inp  like ub.doc-line-sum.cost-road-tax-rubl  no-undo.
define variable varoldcost-excise-base-inp    like ub.doc-line-sum.cost-excise-base    no-undo.
define variable varoldcost-excise-rubl-inp    like ub.doc-line-sum.cost-excise-rubl    no-undo.
define variable varoldcost-transport-base-inp like ub.doc-line-sum.cost-transport-base no-undo.
define variable varoldcost-transport-rubl-inp like ub.doc-line-sum.cost-transport-rubl no-undo.
define variable varoldcost-other-base-inp     like ub.doc-line-sum.cost-other-base     no-undo.
define variable varoldcost-other-rubl-inp     like ub.doc-line-sum.cost-other-rubl     no-undo.
define variable varoldsale-sum-base-inp       like ub.doc-line-sum.sale-sum-base       no-undo.
define variable varoldsale-sum-rubl-inp       like ub.doc-line-sum.sale-sum-rubl       no-undo.
define variable varoldsale-vat-base-inp       like ub.doc-line-sum.sale-vat-base       no-undo.
define variable varoldsale-vat-rubl-inp       like ub.doc-line-sum.sale-vat-rubl       no-undo.
define variable varoldsale-slt-base-inp       like ub.doc-line-sum.sale-slt-base       no-undo.
define variable varoldsale-slt-rubl-inp       like ub.doc-line-sum.sale-slt-rubl       no-undo.
define variable varoldsale-road-tax-base-inp  like ub.doc-line-sum.sale-road-tax-base  no-undo.
define variable varoldsale-road-tax-rubl-inp  like ub.doc-line-sum.sale-road-tax-rubl  no-undo.
define variable varoldsale-excise-base-inp    like ub.doc-line-sum.sale-excise-base    no-undo.
define variable varoldsale-excise-rubl-inp    like ub.doc-line-sum.sale-excise-rubl    no-undo.
define variable varoldsale-transport-base-inp like ub.doc-line-sum.sale-transport-base no-undo.
define variable varoldsale-transport-rubl-inp like ub.doc-line-sum.sale-transport-rubl no-undo.
define variable varoldsale-other-base-inp     like ub.doc-line-sum.sale-other-base     no-undo.
define variable varoldsale-other-rubl-inp     like ub.doc-line-sum.sale-other-rubl     no-undo.
define variable vartot-docold                  like ub.trn-doc.tot-doc                    no-undo.
define variable vartot-rublold                 like ub.trn-doc.tot-rubl                   no-undo.
define variable vartotal-doc-line_tot-ovold    like ub.trn-doc.tot-ov                     no-undo.
define variable vartotal-doc-line_fact-rublold like ub.trn-doc.fact-rubl                  no-undo.
define variable vartotal-doc-line_fact-baseold like ub.trn-doc.fact-base                  no-undo.
define variable vartotal-doc-line_fact-qntyold like ub.trn-doc.fact-qnty                  no-undo.
define variable vartotal-doc-line_doc-qntyold  like ub.trn-doc.doc-qnty                   no-undo.
define variable vartotal-doc-line_cli-qntyold  like ub.trn-doc.cli-qnty                   no-undo.
define variable vartotal-parts_fact-baseold    as   decimal                               no-undo.
define variable vartotal-parts_fact-rublold    as   decimal                               no-undo.
define variable vartotal-parts_fact-qntyold    as   decimal                               no-undo.
define variable parext-doc-mode                as   character                             no-undo.
define variable varpstunqtn as character no-undo.
define variable varpstunqtn-log as logical no-undo.
define variable varmxpcicp-dec  as decimal no-undo.
define variable varmxpcdcp-dec  as decimal no-undo.
define variable varmxsmicp-dec  as decimal no-undo.
define variable varmxsmdcp-dec  as decimal no-undo.
define variable vargrp-is-eq    as logical no-undo.
define variable varpstunit      as logical no-undo.
define temp-table tt-del-list no-undo
field rec-id as recid
index rec-id is unique primary rec-id.
define temp-table tt-doc-line-cashe no-undo
field doc-code  like ub.doc-line.doc-code
field artic     like ub.doc-line.artic
field prod-type like ub.doc-line.prod-type
field prod-code like ub.doc-line.prod-code
field qnty      as   decimal
field sum-rubl  as   decimal
field sum-base  as   decimal
field vat-rubl  as   decimal
field vat-base  as   decimal
index pi is unique primary doc-code artic prod-type prod-code.
define temp-table tt-doc-line-cashe-plus no-undo
field doc-code     like ub.doc-line.doc-code
field wf-artic     like ub.doc-line.artic
field wf-prod-type like ub.doc-line.prod-type
field wf-prod-code like ub.doc-line.prod-code
field artic     like ub.doc-line.artic
field prod-type like ub.doc-line.prod-type
field prod-code like ub.doc-line.prod-code
field qnty               as decimal
field sum-rubl           as decimal
field sum-base           as decimal
field vat-rubl           as decimal
field vat-base           as decimal
FIELD write-off-qnty     AS DECIMAL
FIELD write-off-sum-rubl AS DECIMAL
FIELD write-off-sum-base AS DECIMAL
index pi is unique primary doc-code wf-artic wf-prod-type wf-prod-code artic prod-type prod-code.
define temp-table tt-recalc-line no-undo like ub.doc-line.
define variable vss-include-info31 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run mainmenu_getcntxt in parparentproc
    (output v-cntxt-db-num
    ,output v-cntxt-userid
    ,output v-cntxt-level
    ,output v-cntxt-host-code-obj
    ,output v-cntxt-obj-type
    ,output v-cntxt-obj-code
    ,output v-cntxt-db-num-obj
    ,output v-cntxt-is-admin
    ) .
FUNCTION get-deviation-abs-base RETURNS DECIMAL
    ( BUFFER local-doc-line FOR ub.doc-line, BUFFER local-doc-line-plus FOR ub.doc-line )  FORWARD.
FUNCTION get-deviation-abs-rubl RETURNS DECIMAL
    ( BUFFER local-doc-line FOR ub.doc-line, BUFFER local-doc-line-plus FOR ub.doc-line )  FORWARD.
FUNCTION get-deviation-percent RETURNS DECIMAL
    ( BUFFER local-doc-line FOR ub.doc-line, BUFFER local-doc-line-plus FOR ub.doc-line )  FORWARD.
FUNCTION get-income-qnty RETURNS DECIMAL
  ( BUFFER local-doc-line FOR ub.doc-line, BUFFER local-doc-line-plus FOR ub.doc-line )  FORWARD.
FUNCTION get-income-sum-base RETURNS DECIMAL
    ( BUFFER local-doc-line FOR ub.doc-line, BUFFER local-doc-line-plus FOR ub.doc-line )  FORWARD.
FUNCTION get-income-sum-rubl RETURNS DECIMAL
    ( BUFFER local-doc-line FOR ub.doc-line, BUFFER local-doc-line-plus FOR ub.doc-line )  FORWARD.
FUNCTION get-income-vat-base RETURNS DECIMAL
    ( BUFFER local-doc-line FOR ub.doc-line, BUFFER local-doc-line-plus FOR ub.doc-line )  FORWARD.
FUNCTION get-income-vat-rubl RETURNS DECIMAL
    ( BUFFER local-doc-line FOR ub.doc-line, BUFFER local-doc-line-plus FOR ub.doc-line )  FORWARD.
FUNCTION get-mark RETURNS CHARACTER
  (buffer local-doc-line for ub.doc-line)  FORWARD.
FUNCTION get-price RETURNS DECIMAL
(BUFFER local-goods FOR ub.goods) FORWARD.
FUNCTION get-write-off-for-income-qnty RETURNS DECIMAL
    ( BUFFER local-doc-line FOR ub.doc-line, BUFFER local-doc-line-plus FOR ub.doc-line )  FORWARD.
FUNCTION get-write-off-qnty RETURNS DECIMAL
  ( buffer local-doc-line for ub.doc-line )  FORWARD.
FUNCTION get-write-off-sum-base RETURNS DECIMAL
  ( buffer local-doc-line for ub.doc-line )  FORWARD.
FUNCTION get-write-off-sum-rubl RETURNS DECIMAL
  ( buffer local-doc-line for ub.doc-line )  FORWARD.
FUNCTION get-write-off-vat-base RETURNS DECIMAL
  ( buffer local-doc-line for ub.doc-line )  FORWARD.
FUNCTION get-write-off-vat-rubl RETURNS DECIMAL
  ( buffer local-doc-line for ub.doc-line )  FORWARD.
DEFINE BUTTON b-add
     LABEL "&Добавить"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-arch
     LABEL "&Учет"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-chg
     LABEL "&Изменить"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-cnt
     LABEL "&ДогП"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-del
     LABEL "&Удалить"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-help
     LABEL "&Помощь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-lkp
     LABEL "&Просмотр"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-history
     LABEL "&История"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-mark
     LABEL "*"
     SIZE 3 BY 1.
DEFINE BUTTON b-next AUTO-GO
     LABEL "&>>"
     SIZE 3 BY 1.
DEFINE BUTTON b-notes
     LABEL "При&меч"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-parts
     LABEL "&ПартСпис"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-parts-plus
     LABEL "&ПартОприх"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-prev AUTO-GO
     LABEL "&<<"
     SIZE 3 BY 1.
DEFINE BUTTON b-sum-doc
     LABEL "&СумДок"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-sum-goods
     LABEL "&СумТовСп"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-sum-goods-plus
     LABEL "&СумТовОп"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON r-agnt
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY .88.
DEFINE BUTTON r-boss
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY .88.
DEFINE BUTTON r-reas
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY .88.
DEFINE BUTTON r-sht
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY .88.
DEFINE BUTTON r-wrkr
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY .88.
DEFINE VARIABLE varagnt AS INTEGER FORMAT "999999999" INITIAL ?
     LABEL "И&сп"
     VIEW-AS FILL-IN
     SIZE 10 BY 1 NO-UNDO.
DEFINE VARIABLE varagnt-name AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 18 BY 1 NO-UNDO.
DEFINE VARIABLE varboss AS INTEGER FORMAT "999999999" INITIAL ?
     LABEL "&М-р"
     VIEW-AS FILL-IN
     SIZE 10 BY 1 NO-UNDO.
DEFINE VARIABLE varboss-name AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 18 BY 1 NO-UNDO.
DEFINE VARIABLE varcli-code AS INTEGER FORMAT ">>>>>>>>9":U INITIAL 0
     LABEL "&Поставщик"
     VIEW-AS FILL-IN
     SIZE 10 BY 1 NO-UNDO.
DEFINE VARIABLE varcli-name AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 36.5 BY 1 NO-UNDO.
DEFINE VARIABLE varcli-type AS CHARACTER FORMAT "X(3)":U
     VIEW-AS FILL-IN
     SIZE 4 BY 1 NO-UNDO.
DEFINE VARIABLE varcontract-name AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 68.5 BY 1 NO-UNDO.
DEFINE VARIABLE varcontract-prn-code AS CHARACTER FORMAT "X(16)":U INITIAL "БЕЗ ДОГОВОРА"
     LABEL "&Договор"
     VIEW-AS FILL-IN
     SIZE 17 BY 1 NO-UNDO.
DEFINE VARIABLE vardoc-date AS DATE FORMAT "99/99/99":U
     LABEL "Дата"
     VIEW-AS FILL-IN
     SIZE 10 BY 1 NO-UNDO.
DEFINE VARIABLE varfact-date AS DATE FORMAT "99/99/99":U
     LABEL "Факт"
     VIEW-AS FILL-IN
     SIZE 10 BY 1 NO-UNDO.
DEFINE VARIABLE varinformation AS CHARACTER FORMAT "X(256)":U INITIAL "ПО ТЕМ ЖЕ ПОСТАВЩИКАМ и ДОГОВОРАМ"
     VIEW-AS FILL-IN
     SIZE 34.5 BY 1
     FGCOLOR 3  NO-UNDO.
DEFINE VARIABLE varreason-code AS INTEGER FORMAT ">>>>>>>>>9":U INITIAL 0
     LABEL "Код основания"
      VIEW-AS TEXT
     SIZE 11 BY .67 NO-UNDO.
DEFINE VARIABLE varreason-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
      SIZE 42 BY .67
      FGCOLOR 3
      NO-UNDO.
DEFINE VARIABLE varshift-date AS DATE FORMAT "99/99/99":U
     LABEL "Смена"
     VIEW-AS FILL-IN
     SIZE 10 BY 1 NO-UNDO.
DEFINE VARIABLE varshift-name AS CHARACTER FORMAT "X(2)":U
     LABEL "№"
     VIEW-AS FILL-IN
     SIZE 3 BY 1 NO-UNDO.
DEFINE VARIABLE varshift-num AS INTEGER FORMAT ">9":U INITIAL 0
     LABEL "П"
     VIEW-AS FILL-IN
     SIZE 3 BY 1 NO-UNDO.
DEFINE VARIABLE varwrkr AS INTEGER FORMAT "999999999" INITIAL ?
     LABEL "К&л-к"
     VIEW-AS FILL-IN
     SIZE 10 BY 1.
DEFINE VARIABLE varwrkr-name AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 18 BY 1 NO-UNDO.
DEFINE QUERY b-goods FOR
      bf-plus_doc-line,
      bf-plus_goods,
      bf_parts-root SCROLLING.
DEFINE QUERY b-goods- FOR
      bf_doc-line,
      bf_goods,
      bf_parts SCROLLING.
DEFINE BROWSE b-goods
  QUERY b-goods DISPLAY
      bf-plus_doc-line.artic                                   column-label 'Артикул'
  bf-plus_goods.gds-name                                   column-label 'Название товара' format "x(48)"
  bf-plus_doc-line.prod-type                                   column-label 'Тип' format "x(3)"
  bf-plus_doc-line.prod-code                                   column-label 'Код произ'
  get-price (buffer bf-plus_goods)    @ varprice-plus                column-label 'Цена' FORMAT ">,>>>,>>9.999"
  get-income-qnty (BUFFER bf_doc-line, BUFFER bf-plus_doc-line)    @ varincome-qnty               column-label 'Оприх.кол-во'
  get-income-sum-rubl (BUFFER bf_doc-line, BUFFER bf-plus_doc-line)    @ varincome-sum-rubl           column-label 'Оприх. сумма (руб)'     FORMAT ">>,>>>,>>>,>>9.99"
  get-income-sum-base (BUFFER bf_doc-line, BUFFER bf-plus_doc-line)    @ varincome-sum-base           column-label 'Оприх. сумма (вал)'     FORMAT ">>,>>>,>>>,>>9.99"
  get-income-vat-rubl (BUFFER bf_doc-line, BUFFER bf-plus_doc-line)    @ varincome-vat-rubl           column-label 'Оприх. НДС (руб)'     FORMAT ">>,>>>,>>>,>>9.99"
  get-income-vat-base (BUFFER bf_doc-line, BUFFER bf-plus_doc-line)   @ varincome-vat-base           column-label 'Оприх. НДС (вал)'    FORMAT ">>,>>>,>>>,>>9.99"
  get-deviation-percent (BUFFER bf_doc-line, BUFFER bf-plus_doc-line)   @ vardeviation-percent         COLUMN-LABEL 'Отклонение %'
  get-deviation-abs-rubl (BUFFER bf_doc-line, BUFFER bf-plus_doc-line)   @ vardeviation-abs-rub         COLUMN-LABEL 'Отклонение (руб)'
  get-deviation-abs-base (BUFFER bf_doc-line, BUFFER bf-plus_doc-line)   @ vardeviation-abs-base        COLUMN-LABEL 'Отклонение (вал)'
  get-write-off-for-income-qnty (BUFFER bf_doc-line, BUFFER bf-plus_doc-line)   @ varwrite-off-for-income-qnty COLUMN-LABEL 'Спис. кол-во для оприх.кол-ва'
    WITH NO-ROW-MARKERS SEPARATORS SIZE 97.5 BY 7
         TITLE "Оприходованные товары" EXPANDABLE.
DEFINE BROWSE b-goods-
  QUERY b-goods- DISPLAY
      get-mark (buffer bf_doc-line)    @ varmark               column-label '*' format "x(1)"
  bf_doc-line.artic                            column-label 'Артикул'
  bf_goods.gds-name                            column-label 'Название товара' format "x(48)"
  bf_doc-line.prod-type                            column-label 'Тип' format "x(3)"
  bf_doc-line.prod-code                            column-label 'Код произ'
  get-price (buffer bf_goods)    @ varprice              column-label 'Цена' FORMAT ">,>>>,>>9.999"
  get-write-off-qnty (BUFFER bf_doc-line)    @ varwrite-off-qnty     column-label 'Спис. кол-во'
  get-write-off-sum-rubl (BUFFER bf_doc-line)    @ varwrite-off-sum-rubl column-label 'Спис. сумма (руб)'    FORMAT ">>,>>>,>>>,>>9.99"
  get-write-off-sum-base (BUFFER bf_doc-line)    @ varwrite-off-sum-base column-label 'Спис. сумма (вал)'    FORMAT ">>,>>>,>>>,>>9.99"
  get-write-off-vat-rubl (BUFFER bf_doc-line)   @ varwrite-off-vat-rubl column-label 'Спис. НДС (руб)'   FORMAT ">>,>>>,>>>,>>9.99"
  get-write-off-vat-base (BUFFER bf_doc-line)   @ varwrite-off-vat-base column-label 'Спис. НДС (вал)'   FORMAT ">>,>>>,>>>,>>9.99"
    WITH NO-ROW-MARKERS SEPARATORS SIZE 97.5 BY 7
         TITLE "Списанные товары" EXPANDABLE.
DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     b-prev AT ROW 1 COL 11
     b-next AT ROW 1 COL 14
     b-sum-doc AT ROW 1 COL 17
     b-arch AT ROW 1 COL 27
     b-notes AT ROW 1 COL 37
     b-cnt AT ROW 1 COL 47
     b-history AT ROW 1 COL 57
     b-help AT ROW 1 COL 87
     b-mark AT ROW 2 COL 14
     b-add AT ROW 2 COL 17
     b-lkp AT ROW 2 COL 27
     b-chg AT ROW 2 COL 37
     b-del AT ROW 2 COL 47
     b-parts AT ROW 2 COL 57
     b-parts-plus AT ROW 2 COL 67
     b-sum-goods AT ROW 2 COL 77
     b-sum-goods-plus AT ROW 2 COL 87
     varcli-code AT ROW 3 COL 10 COLON-ALIGNED
     varcli-type AT ROW 3 COL 20.5 COLON-ALIGNED NO-LABEL
     varcli-name AT ROW 3 COL 25 COLON-ALIGNED NO-LABEL
     varinformation AT ROW 3 COL 63.5 NO-LABEL
     varcontract-prn-code AT ROW 4 COL 10 COLON-ALIGNED
     varcontract-name AT ROW 4 COL 27.5 COLON-ALIGNED NO-LABEL
     varwrkr AT ROW 5 COL 5 COLON-ALIGNED
     varwrkr-name AT ROW 5 COL 15 COLON-ALIGNED NO-LABEL
     r-wrkr AT ROW 5 COL 35.5
     vardoc-date AT ROW 5 COL 43.5 COLON-ALIGNED
     r-reas AT ROW 5 COL 82
     varagnt AT ROW 6 COL 5 COLON-ALIGNED
     varagnt-name AT ROW 6 COL 15 COLON-ALIGNED NO-LABEL
     r-agnt AT ROW 6 COL 35.5
     varfact-date AT ROW 6 COL 43.5 COLON-ALIGNED
     varboss AT ROW 7 COL 5 COLON-ALIGNED
     varboss-name AT ROW 7 COL 15 COLON-ALIGNED NO-LABEL
     r-boss AT ROW 7 COL 35.5
     varshift-date AT ROW 7 COL 43.5 COLON-ALIGNED
     varshift-name AT ROW 7 COL 57.5 COLON-ALIGNED
     varshift-num AT ROW 7 COL 64 COLON-ALIGNED
     r-sht AT ROW 7 COL 69
     b-goods- AT ROW 8 COL 1
     b-goods AT ROW 15 COL 1
     varreason-code AT ROW 5 COL 69 COLON-ALIGNED
     varreason-name AT ROW 6 COL 54 COLON-ALIGNED NO-LABEL
     SPACE(0.50) SKIP(15.33)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "<insert dialog title>"
         DEFAULT-BUTTON b-exit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE.
ASSIGN
       varcli-code:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       varcli-name:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       varcli-type:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       varcontract-name:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       varcontract-prn-code:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       varinformation:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ON end-error OF FRAME Dialog-Frame
DO:
  apply "choose" to b-exit in frame Dialog-Frame.
  return no-apply.
END.
ON GO OF FRAME Dialog-Frame
DO:
  run proc-exit in this-procedure no-error.
  if error-status :error then do:
    return no-apply.
  end.
END.
ON stop OF FRAME Dialog-Frame
DO:
  apply "choose" to b-exit in frame Dialog-Frame.
  return no-apply.
END.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-add IN FRAME Dialog-Frame
DO:
define variable vss-include-info32 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
  run local-add in this-procedure no-error.
  if error-status:error then do:
    message "Ошибка при добавлении строк пересортицы." skip
    return-value
    view-as alert-box error.
    return no-apply.
  end.
  run ui-on in this-procedure ("":u) .
END.
ON CHOOSE OF b-arch IN FRAME Dialog-Frame
DO:
define variable vss-include-info33 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
  define variable varlog as logical no-undo.
define variable vss-include-info34 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_archive_cost':U
    ,input  'object':U
    ,input  bf_trn-doc.host-code
    ,input  bf_trn-doc.obj-type
    ,input  bf_trn-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output varlog
    )  .
end.
  if not varlog then do:
    return no-apply.
  end.
  run str/docsuppn.w
    (input  parparentproc
    ,input  recid( bf_trn-doc )
    ).
END.
ON CHOOSE OF b-chg IN FRAME Dialog-Frame
DO:
define variable vss-include-info35 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
  define variable varis-petrol      as logical no-undo.
  define variable varis-pieces      as logical no-undo.
  define variable varis-petrol-plus as logical no-undo.
  define variable varis-pieces-plus as logical no-undo.
  define buffer bf-trb_parts      for ub.parts.
  define buffer bf-trb_parts-root for ub.parts-root.
  define buffer bf_gds-prt      for ub.gds-prt.
  define buffer bf-plus_gds-prt for ub.gds-prt.
  define variable varhave-another-goods as logical no-undo.
  if not available bf_goods then do:
    message "Не выбрана линия списываемого товара." view-as alert-box.
    return no-apply.
  end.
  if not available bf-plus_goods then do:
    message "Не выбрана линия оприходуемого товара." view-as alert-box.
    return no-apply.
  end.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_is-petrl in g#lib-trn
  (
     input bf_goods.artic
  ,  input bf_goods.prod-type
  ,  input bf_goods.prod-code
  , output varis-petrol
  , output varis-pieces
  ) .
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_is-petrl in g#lib-trn
  (
     input bf-plus_goods.artic
  ,  input bf-plus_goods.prod-type
  ,  input bf-plus_goods.prod-code
  , output varis-petrol-plus
  , output varis-pieces-plus
  ) .
  if varis-petrol and
     not varis-pieces then do:
    message "Товар " bf_goods.artic " " bf_goods.prod-type " " bf_goods.prod-code " " bf_goods.gds-name " - топливо." skip
            "Редактирование возможно через удаление и добавление."
    view-as alert-box.
    return no-apply.
  end.
  if varis-petrol-plus and
     not varis-pieces-plus then do:
    message "По топливу " bf-plus_goods.artic " " bf-plus_goods.prod-type " " bf-plus_goods.prod-code " " bf-plus_goods.gds-name " -топливо." skip
            "Редактирование возможно через удаление и добавление."
    view-as alert-box.
    return no-apply.
  end.
  find first bf_gds-prt where bf_gds-prt.upper-code = bf_goods.prt-root no-lock.
  if bf_gds-prt.node-name <> '_Пустая шкала':U then do:
    find first bf-trb_parts where bf-trb_parts.out-code  = bf_trn-doc.doc-code and
                                  bf-trb_parts.obj-type  = bf_trn-doc.obj-type and
                                  bf-trb_parts.obj-code  = bf_trn-doc.obj-code and
                                  bf-trb_parts.artic     = bf_goods.artic      and
                                  bf-trb_parts.prod-type = bf_goods.prod-type  and
                                  bf-trb_parts.prod-code = bf_goods.prod-code  and
                                  bf-trb_parts.fact-qnty > 0                   no-error.
    if available bf-trb_parts then do:
      message "По товару с признаками " bf_goods.artic " " bf_goods.prod-type " " bf_goods.prod-code " " bf_goods.gds-name " есть оприходования." skip
              "Редактирование возможно через удаление и добавление."
      view-as alert-box.
      return no-apply.
    end.
    assign
      varhave-another-goods =no.
    for each bf-trb_parts-root where bf-trb_parts-root.doc-code      = bf_trn-doc.doc-code    and
                                     bf-trb_parts-root.orig-gds-code = bf_goods.gds-code      and
                                     bf-trb_parts-root.gds-code     <> bf-plus_goods.gds-code on error undo, return no-apply return-value :
      assign
        varhave-another-goods = yes.
    end.
    if varhave-another-goods then do:
      message "По товару с признаками " bf_goods.artic " " bf_goods.prod-type " " bf_goods.prod-code " " bf_goods.gds-name " есть списания в связке с другим товарам." skip
              "Редактирование возможно через удаление и добавление."
      view-as alert-box.
      return no-apply.
    end.
  end.
  find first bf-plus_gds-prt where bf-plus_gds-prt.upper-code = bf-plus_goods.prt-root no-lock.
  if bf_gds-prt.node-name <> '_Пустая шкала':U then do:
    find first bf-trb_parts where bf-trb_parts.out-code  = bf_trn-doc.doc-code      and
                                  bf-trb_parts.obj-type  = bf_trn-doc.obj-type      and
                                  bf-trb_parts.obj-code  = bf_trn-doc.obj-code      and
                                  bf-trb_parts.artic     = bf-plus_goods.artic      and
                                  bf-trb_parts.prod-type = bf-plus_goods.prod-type  and
                                  bf-trb_parts.prod-code = bf-plus_goods.prod-code  and
                                  bf-trb_parts.fact-qnty < 0                        no-error.
    if available bf-trb_parts then do:
      message "По товару с признаками " bf-plus_goods.artic " " bf-plus_goods.prod-type " " bf-plus_goods.prod-code " " bf-plus_goods.gds-name " есть списания." skip
              "Редактирование возможно через удаление и добавление."
      view-as alert-box.
      return no-apply.
    end.
    assign
      varhave-another-goods =no.
    for each bf-trb_parts-root where bf-trb_parts-root.doc-code       = bf_trn-doc.doc-code    and
                                     bf-trb_parts-root.gds-code       = bf-plus_goods.gds-code and
                                     bf-trb_parts-root.orig-gds-code <> bf_goods.gds-code      on error undo, return no-apply return-value :
      assign
        varhave-another-goods = yes.
    end.
    if varhave-another-goods then do:
      message "По товару с признаками " bf-plus_goods.artic " " bf-plus_goods.prod-type " " bf-plus_goods.prod-code " " bf-plus_goods.gds-name " есть оприходования в связке другим товарам." skip
              "Редактирование возможно через удаление и добавление."
      view-as alert-box.
      return no-apply.
    end.
  end.
  run local-chg in this-procedure no-error.
  if error-status:error then do:
    message "Ошибка при изменении строк пересортицы." skip
    return-value
    view-as alert-box error.
    return no-apply.
  end.
  run proc-get-write-off in this-procedure (buffer bf_doc-line).
  run ui-on in this-procedure ("":u) .
END.
ON CHOOSE OF b-cnt IN FRAME Dialog-Frame
DO:
define variable vss-include-info36 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
  define variable varlog as logical no-undo.
define variable vss-include-info37 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_archive_cost':U
    ,input  'object':U
    ,input  bf_trn-doc.host-code
    ,input  bf_trn-doc.obj-type
    ,input  bf_trn-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output varlog
    )  .
end.
  if not varlog then do:
    return no-apply.
  end.
  run str/scntdoc.w ( input bf_trn-doc.doc-code, input ( v-cntxt-db-num = bf_sysconf.firm-db-num ) ).
END.
ON CHOOSE OF b-del IN FRAME Dialog-Frame
DO:
define variable vss-include-info38 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
define variable varrep-rec as recid no-undo.
run local-del in this-procedure (output varrep-rec) no-error.
if error-status:error then do:
  message
  "Ошибка при удалении строк пересортицы."  skip
  return-value
  view-as alert-box error.
  return no-apply.
end.
run ui-on IN THIS-PROCEDURE ("":u).
apply "entry" to b-goods- in frame Dialog-Frame .
if varrep-rec <> ? then do:
  reposition b-goods- to recid varrep-rec no-error.
end.
APPLY "value-changed" TO b-goods- IN FRAME Dialog-Frame.
END.
ON CHOOSE OF b-exit IN FRAME Dialog-Frame
DO:
define variable vss-include-info39 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
    parnext-prev = ? .
END.
ON F9 OF b-goods IN FRAME Dialog-Frame
DO:
  define buffer bfl_goods for ub.goods.
  if not available bf-plus_doc-line THEN do:
    return no-apply.
  END.
  find first bfl_goods where bfl_goods.artic     = bf-plus_doc-line.artic     and
                             bfl_goods.prod-type = bf-plus_doc-line.prod-type and
                             bfl_goods.prod-code = bf-plus_doc-line.prod-code no-lock.
  run str/showgds.p
    (input parparentproc
    ,input ?
    ,input bfl_goods.gds-code
    ,input 'ПРОСМОТР':U
    ).
  apply "entry" to b-goods- in frame Dialog-Frame.
  return no-apply.
END.
ON F9 OF b-goods- IN FRAME Dialog-Frame
DO:
  define buffer bfl_goods for ub.goods.
  if not available bf_doc-line THEN do:
    return no-apply.
  END.
  find first bfl_goods where bfl_goods.artic     = bf_doc-line.artic     and
                             bfl_goods.prod-type = bf_doc-line.prod-type and
                             bfl_goods.prod-code = bf_doc-line.prod-code no-lock.
  run str/showgds.p
    (input parparentproc
    ,input ?
    ,input bfl_goods.gds-code
    ,input 'ПРОСМОТР':U
    ).
  apply "entry" to b-goods- in frame Dialog-Frame.
  return no-apply.
END.
ON VALUE-CHANGED OF b-goods- IN FRAME Dialog-Frame
DO:
  OPEN QUERY b-goods FOR EACH bf-plus_doc-line WHERE bf-plus_doc-line.doc-code = bf_trn-doc.doc-code NO-LOCK,            FIRST bf-plus_goods WHERE bf-plus_goods.artic     = bf-plus_doc-line.artic     AND                               bf-plus_goods.prod-type = bf-plus_doc-line.prod-type AND                               bf-plus_goods.prod-code = bf-plus_doc-line.prod-code NO-LOCK,            FIRST bf_parts-root WHERE bf_parts-root.doc-code      = bf-plus_doc-line.doc-code AND                               bf_parts-root.gds-code      = bf-plus_goods.gds-code    AND                               bf_parts-root.orig-gds-code = bf_goods.gds-code   NO-LOCK.
END.
ON CHOOSE OF b-lkp IN FRAME Dialog-Frame
DO:
define variable varoutgds-code      like ub.goods.gds-code no-undo.
define variable varoutgds-code-plus like ub.goods.gds-code no-undo.
define variable varqnty             as   decimal           no-undo.
define variable varqnty-kg          as   decimal           no-undo.
define variable varqnty-plus        as   decimal           no-undo.
define variable varqnty-kg-plus     as   decimal           no-undo.
define variable varoutqnty          as   decimal           no-undo.
define variable varoutqnty-plus     as   decimal           no-undo.
define variable varoutqnty-kg       as   decimal           no-undo.
define variable varoutqnty-kg-plus  as   decimal           no-undo.
define variable varset              as   logical           no-undo.
DEFINE BUFFER bf_parts-root FOR ub.parts-root.
DEFINE BUFFER bf_parts FOR ub.parts.
IF NOT AVAILABLE bf_goods THEN DO:
  MESSAGE "Не выбрана линия списываемого товара." VIEW-AS ALERT-BOX.
  RETURN NO-APPLY.
END.
IF NOT AVAILABLE bf-plus_goods THEN DO:
  MESSAGE "Не выбрана линия оприходуемого товара." VIEW-AS ALERT-BOX.
  RETURN NO-APPLY.
END.
ASSIGN
  varqnty      = 0.00
  varqnty-plus = 0.00.
FOR EACH bf_parts-root WHERE bf_parts-root.doc-code      = bf_trn-doc.doc-code AND
                             bf_parts-root.orig-gds-code = bf_goods.gds-code   AND
                             bf_parts-root.gds-code      = bf-plus_goods.gds-code
                             USE-INDEX pi ON ERROR UNDO, RETURN NO-APPLY RETURN-VALUE :
  FIND FIRST bf_parts WHERE bf_parts.obj-type  = bf_trn-doc.obj-type      AND
                            bf_parts.obj-code  = bf_trn-doc.obj-code      AND
                            bf_parts.artic     = bf-plus_goods.artic      AND
                            bf_parts.prod-type = bf-plus_goods.prod-type  AND
                            bf_parts.prod-code = bf-plus_goods.prod-code  AND
                            bf_parts.in-code   = bf_parts-root.in-code    AND
                            bf_parts.out-code  = bf_parts-root.doc-code   AND
                            bf_parts.part-code = bf_parts-root.part-code  .
  ASSIGN
    varqnty      = varqnty      + bf_parts.real-qnty
    varqnty-plus = varqnty-plus + bf_parts.fact-qnty.
END.
run str/prst-gds.w (input  parparentproc,
                input  bf_trn-doc.doc-code,
                input  'ПРОСМОТР':U,
                input  bf_trn-doc.obj-type,
                input  bf_trn-doc.obj-code,
                input  bf_goods.gds-code,
                input  bf-plus_goods.gds-code,
                input  varqnty,
                input  ?,
                input  varqnty-plus,
                input  ?,
                input  varpstunqtn-log,
                input  varpstunit,
                input  varmxpcicp-dec,
                input  varmxpcdcp-dec,
                input  varmxsmicp-dec,
                input  varmxsmdcp-dec,
                output varoutgds-code,
                output varoutgds-code-plus,
                output table tt-gds-dtl,
                output table tt-pl-qty,
                output varoutqnty,
                output varoutqnty-plus,
                output varoutqnty-kg,
                output varoutqnty-kg-plus,
                output table tt-gds-dtl-plus,
                output table tt-pl-qty-plus,
                output varset).
END.
ON CHOOSE OF b-history IN FRAME Dialog-Frame
DO:
define variable vss-include-info40 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
  run proc-history in this-procedure no-error.
  if error-status :error then do: return no-apply. end.
END.
ON CHOOSE OF b-mark IN FRAME Dialog-Frame
DO:
  run mark-list in this-procedure.
END.
ON CHOOSE OF b-notes IN FRAME Dialog-Frame
DO:
define variable vss-include-info41 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
  run notes-tr in this-procedure.
END.
ON CHOOSE OF b-parts IN FRAME Dialog-Frame
DO:
  DEFINE VARIABLE varprt-rec AS RECID NO-UNDO.
  if not available bf_doc-line then do:
    message "Неправильный выбор строки - партии недоступны."
            view-as alert-box.
    return NO-APPLY.
  end.
  assign
    line-rec = recid( bf_doc-line )
  .
  run str/parts-l.w
    (  input parparentproc
    ,  input bf_trn-doc.obj-type
    ,  input bf_trn-doc.obj-code
    ,  input bf_goods.gds-code
    ,  input bf_doc-line.doc-code
    ,  input 'ПРОСМОТР':U
    ,  input 'документ':U
    ,  input 'текущий':U
    , input 'документ':U
    , output varprt-rec
    ) .
END.
ON CHOOSE OF b-parts-plus IN FRAME Dialog-Frame
DO:
  DEFINE VARIABLE varprt-rec AS RECID NO-UNDO.
  if not available bf-plus_doc-line then do:
    message "Неправильный выбор строки - партии недоступны."
            view-as alert-box.
    return NO-APPLY.
  end.
  assign
    line-rec = recid( bf-plus_doc-line )
  .
  run str/parts-l.w
    (  input parparentproc
    ,  input bf_trn-doc.obj-type
    ,  input bf_trn-doc.obj-code
    ,  input bf-plus_goods.gds-code
    ,  input bf-plus_doc-line.doc-code
    ,  input 'ПРОСМОТР':U
    ,  input 'документ':U
    ,  input 'текущий':U
    ,  input 'документ':U
    , output varprt-rec
    ) .
END.
ON CHOOSE OF b-sum-doc IN FRAME Dialog-Frame
DO:
  run str/vsumtype.w ( input yes, input bf_trn-doc.doc-code, input ? ).
END.
ON CHOOSE OF b-sum-goods IN FRAME Dialog-Frame
DO:
  if available bf_goods then do:
    run str/vsumtype.w ( input no, input bf_trn-doc.doc-code, input bf_goods.gds-code ).
  end.
  ELSE DO:
    MESSAGE "Не выбрана строка списываемого товара." VIEW-AS ALERT-BOX.
  END.
END.
ON CHOOSE OF b-sum-goods-plus IN FRAME Dialog-Frame
DO:
  if available bf-plus_goods then do:
    run str/vsumtype.w ( input no, input bf_trn-doc.doc-code, input bf-plus_goods.gds-code ).
  end.
  ELSE DO:
    MESSAGE "Не выбрана строка оприходуемого товара." VIEW-AS ALERT-BOX.
  END.
END.
ON CHOOSE OF r-agnt IN FRAME Dialog-Frame
DO:
  RUN local-psn-chk in this-procedure ("agnt", "button").
  apply "entry" to varboss in frame Dialog-Frame.
  return no-apply.
END.
ON CHOOSE OF r-boss IN FRAME Dialog-Frame
DO:
  RUN local-psn-chk in this-procedure ("boss", "button").
  apply "entry" to b-exit in frame Dialog-Frame.
  return no-apply.
END.
ON CHOOSE OF r-reas IN FRAME Dialog-Frame
DO:
  run select-reason in this-procedure.
END.
ON CHOOSE OF r-sht IN FRAME Dialog-Frame
DO:
  define buffer bf-chk_doc-line for ub.doc-line.
  find first bf-chk_doc-line where bf-chk_doc-line.doc-code = bf_trn-doc.doc-code no-error.
  if available bf-chk_doc-line then do:
    message "В документе уже есть строки. Не допускается изменение фактической даты." view-as alert-box.
    return no-apply.
  end.
  run proc-shift-num in this-procedure no-error.
  if error-status:error then do:
    return no-apply.
  end.
  run proc-sht in this-procedure no-error.
END.
ON CHOOSE OF r-wrkr IN FRAME Dialog-Frame
DO:
  run local-psn-chk in this-procedure ("wrkr", "button").
  apply "entry" to varagnt in frame Dialog-Frame.
  return no-apply.
END.
ON LEAVE OF varagnt IN FRAME Dialog-Frame
DO:
  if input frame Dialog-Frame varagnt <> varagnt then do:
    run local-psn-chk in this-procedure ("agnt", "leave").
    apply "entry" to varboss in frame Dialog-Frame.
    return no-apply.
  end.
END.
ON MOUSE-SELECT-DBLCLICK OF varagnt IN FRAME Dialog-Frame
DO:
    run local-psn-chk in this-procedure ("agnt", "ret-mouse").
    apply "entry" to varboss in frame Dialog-Frame.
    return no-apply.
END.
ON return OF varagnt IN FRAME Dialog-Frame
DO:
  run local-psn-chk in this-procedure ("agnt", "ret-mouse").
  apply "entry" to varboss in frame Dialog-Frame.
  return no-apply.
END.
ON LEAVE OF varboss IN FRAME Dialog-Frame
DO:
  if input frame Dialog-Frame varboss <> varboss then do:
    run local-psn-chk in this-procedure ("boss", "leave").
    apply "entry" to b-exit in frame Dialog-Frame.
    return no-apply.
  end.
END.
ON MOUSE-SELECT-DBLCLICK OF varboss IN FRAME Dialog-Frame
DO:
  RUN local-psn-chk in this-procedure ("boss", "ret-mouse").
  apply "entry" to b-exit in frame Dialog-Frame.
  return no-apply.
END.
ON RETURN OF varboss IN FRAME Dialog-Frame
DO:
    RUN local-psn-chk in this-procedure ("boss", "ret-mouse").
  apply "entry" to b-exit in frame Dialog-Frame.
  return no-apply.
END.
ON LEAVE OF varfact-date IN FRAME Dialog-Frame
DO:
  run chk-upd-date IN THIS-PROCEDURE .
END.
ON LEAVE OF varshift-date IN FRAME Dialog-Frame
DO:
  define buffer bf-chk_doc-line for ub.doc-line.
  if input frame Dialog-Frame varshift-date <> varshift-date then do:
    assign
      varshift-name   = ""
      bf_trn-doc.shift-num = 0.
    display varshift-name bf_trn-doc.shift-num @ varshift-num with frame Dialog-Frame.
    apply "entry" to varshift-name in frame Dialog-Frame.
    return no-apply.
  end.
end.
ON return OF varshift-date IN FRAME Dialog-Frame
DO:
  apply "entry" to varshift-name in frame Dialog-Frame.
  return no-apply.
END.
ON LEAVE OF varshift-name IN FRAME Dialog-Frame
DO:
  DEFINE BUFFER bf-chk_doc-line FOR ub.doc-line.
  IF INPUT FRAME Dialog-Frame varshift-name <> varshift-name THEN DO:
    run proc-shift-name in this-procedure no-error.
    if error-status:error then do:
      return no-apply.
    end.
  END.
END.
ON return OF varshift-name IN FRAME Dialog-Frame
DO:
    apply "entry" to b-add in frame Dialog-Frame.
  return no-apply.
END.
ON LEAVE OF varshift-num IN FRAME Dialog-Frame
DO:
define buffer bf-chk_doc-line for ub.doc-line.
if input frame Dialog-Frame varshift-num <> varshift-num then do:
  run proc-shift-num in this-procedure no-error.
  if error-status:error then do:
    return no-apply.
  end.
end.
END.
ON return OF varshift-num IN FRAME Dialog-Frame
DO:
  apply "entry" to b-add in frame Dialog-Frame.
  return no-apply.
END.
ON LEAVE OF varwrkr IN FRAME Dialog-Frame
DO:
  if input frame Dialog-Frame varwrkr <> varwrkr then do:
    run local-psn-chk in this-procedure ("wrkr", "leave").
    apply "entry" to varagnt in frame Dialog-Frame.
    return no-apply.
  end.
END.
ON MOUSE-SELECT-DBLCLICK OF varwrkr IN FRAME Dialog-Frame
DO:
    RUN local-psn-chk in this-procedure ("wrkr", "ret-mouse").
  apply "entry" to varagnt in frame Dialog-Frame.
  return no-apply.
END.
ON RETURN OF varwrkr IN FRAME Dialog-Frame
DO:
    RUN local-psn-chk in this-procedure ("wrkr", "ret-mouse").
  apply "entry" to varagnt in frame Dialog-Frame.
  return no-apply.
END.
assign
  r-reas         :tooltip in frame Dialog-Frame = "Основание (причина) создания документа. Вызов справочника"
  varreason-code :tooltip in frame Dialog-Frame = "Основание (причина) создания документа. Ввод кода"
  varreason-name :tooltip in frame Dialog-Frame = "Основание (причина) создания документа"
.
define variable vss-include-info42 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEF VAR cur-clmn-numb-goods- as INT EXTENT 11 no-undo.
DEF VAR varmvib-goods-       as INT no-undo.
DEF VAR varmvjb-goods-       as INT no-undo.
DEF VAR varmvkb-goods-       as INT no-undo.
DEF VAR varmvlb-goods-       as INT no-undo.
DEF VAR move-elementb-goods- as INT no-undo.
def var jjb-goods-           as int no-undo.
do varmvib-goods- = 1 to EXTENT(cur-clmn-numb-goods-):
  ASSIGN cur-clmn-numb-goods-[varmvib-goods-] = varmvib-goods-.
END.
RUN start-mv-clmnb-goods-.
PROCEDURE start-mv-clmnb-goods-:
def var old-session as logical no-undo.
   old-session = SESSION:IMMEDIATE-DISPLAY.
   IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
   SESSION:IMMEDIATE-DISPLAY = old-session.
END.
ON ctrl-cursor-right OF BROWSE b-goods- do:
  RUN re-move-clmnb-goods- ( 3, 11).
END.
ON ctrl-cursor-left OF BROWSE b-goods- do:
  RUN re-move-clmnb-goods- (11, 3).
END.
PROCEDURE re-move-clmnb-goods-:
  DEFINE INPUT PARAMETER source-column as INTEGER NO-UNDO.
  DEFINE INPUT PARAMETER target-column as INTEGER NO-UNDO.
  DO varmvib-goods- = 1 TO EXTENT(cur-clmn-numb-goods-):
    if cur-clmn-numb-goods-[varmvib-goods-] = source-column THEN cur-clmn-numb-goods-[varmvib-goods-] = -1.
  END.
  if b-goods-:MOVE-COLUMN(source-column, target-column) IN FRAME Dialog-Frame then.
  if source-column > target-column THEN
  DO varmvjb-goods- = source-column - 1 to target-column BY -1:
    DO varmvib-goods- = 1 TO EXTENT(cur-clmn-numb-goods-):
        if cur-clmn-numb-goods-[varmvib-goods-] = varmvjb-goods- THEN DO:
          cur-clmn-numb-goods-[varmvib-goods-] = cur-clmn-numb-goods-[varmvib-goods-] + 1.
        END.
    END.
  END.
  ELSE
  DO varmvjb-goods- = source-column + 1 to target-column:
    DO varmvib-goods- = 1 TO EXTENT(cur-clmn-numb-goods-):
      if cur-clmn-numb-goods-[varmvib-goods-] = varmvjb-goods- THEN DO:
        cur-clmn-numb-goods-[varmvib-goods-] = cur-clmn-numb-goods-[varmvib-goods-] - 1.
      END.
    END.
  END.
  DO varmvib-goods- = 1 TO EXTENT(cur-clmn-numb-goods-):
    if cur-clmn-numb-goods-[varmvib-goods-] = -1 THEN cur-clmn-numb-goods-[varmvib-goods-] = target-column.
  END.
END PROCEDURE.
PROCEDURE ch-clmnb-goods-:
  DEFINE INPUT PARAMETER cur-clmn-loc as INTEGER NO-UNDO.
  if cur-clmn-loc <= 3 then do:
    return .
  end.
  DO varmvib-goods- = 1 TO EXTENT(cur-clmn-numb-goods-):
    if cur-clmn-numb-goods-[varmvib-goods-] = cur-clmn-loc THEN move-elementb-goods- = varmvib-goods-.
  END.
  RUN re-move-clmnb-goods- (cur-clmn-loc, 3).
END PROCEDURE.
PROCEDURE mv-brw-defaultb-goods-:
def var old-session as logical no-undo.
  old-session = SESSION:IMMEDIATE-DISPLAY.
  IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
  do varmvlb-goods- = 3 to EXTENT(cur-clmn-numb-goods-):
    RUN re-move-clmnb-goods- (cur-clmn-numb-goods-[varmvlb-goods-], varmvlb-goods-).
  END.
  RUN start-mv-clmnb-goods-.
  SESSION:IMMEDIATE-DISPLAY = old-session.
END PROCEDURE.
.
define variable vss-include-info43 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEF VAR cur-clmn-numb-goods as INT EXTENT 14 no-undo.
DEF VAR varmvib-goods       as INT no-undo.
DEF VAR varmvjb-goods       as INT no-undo.
DEF VAR varmvkb-goods       as INT no-undo.
DEF VAR varmvlb-goods       as INT no-undo.
DEF VAR move-elementb-goods as INT no-undo.
def var jjb-goods           as int no-undo.
do varmvib-goods = 1 to EXTENT(cur-clmn-numb-goods):
  ASSIGN cur-clmn-numb-goods[varmvib-goods] = varmvib-goods.
END.
RUN start-mv-clmnb-goods.
PROCEDURE start-mv-clmnb-goods:
def var old-session as logical no-undo.
   old-session = SESSION:IMMEDIATE-DISPLAY.
   IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
   SESSION:IMMEDIATE-DISPLAY = old-session.
END.
ON ctrl-cursor-right OF BROWSE b-goods do:
  RUN re-move-clmnb-goods ( 2, 14).
END.
ON ctrl-cursor-left OF BROWSE b-goods do:
  RUN re-move-clmnb-goods (14, 2).
END.
PROCEDURE re-move-clmnb-goods:
  DEFINE INPUT PARAMETER source-column as INTEGER NO-UNDO.
  DEFINE INPUT PARAMETER target-column as INTEGER NO-UNDO.
  DO varmvib-goods = 1 TO EXTENT(cur-clmn-numb-goods):
    if cur-clmn-numb-goods[varmvib-goods] = source-column THEN cur-clmn-numb-goods[varmvib-goods] = -1.
  END.
  if b-goods:MOVE-COLUMN(source-column, target-column) IN FRAME Dialog-Frame then.
  if source-column > target-column THEN
  DO varmvjb-goods = source-column - 1 to target-column BY -1:
    DO varmvib-goods = 1 TO EXTENT(cur-clmn-numb-goods):
        if cur-clmn-numb-goods[varmvib-goods] = varmvjb-goods THEN DO:
          cur-clmn-numb-goods[varmvib-goods] = cur-clmn-numb-goods[varmvib-goods] + 1.
        END.
    END.
  END.
  ELSE
  DO varmvjb-goods = source-column + 1 to target-column:
    DO varmvib-goods = 1 TO EXTENT(cur-clmn-numb-goods):
      if cur-clmn-numb-goods[varmvib-goods] = varmvjb-goods THEN DO:
        cur-clmn-numb-goods[varmvib-goods] = cur-clmn-numb-goods[varmvib-goods] - 1.
      END.
    END.
  END.
  DO varmvib-goods = 1 TO EXTENT(cur-clmn-numb-goods):
    if cur-clmn-numb-goods[varmvib-goods] = -1 THEN cur-clmn-numb-goods[varmvib-goods] = target-column.
  END.
END PROCEDURE.
PROCEDURE ch-clmnb-goods:
  DEFINE INPUT PARAMETER cur-clmn-loc as INTEGER NO-UNDO.
  if cur-clmn-loc <= 2 then do:
    return .
  end.
  DO varmvib-goods = 1 TO EXTENT(cur-clmn-numb-goods):
    if cur-clmn-numb-goods[varmvib-goods] = cur-clmn-loc THEN move-elementb-goods = varmvib-goods.
  END.
  RUN re-move-clmnb-goods (cur-clmn-loc, 2).
END PROCEDURE.
PROCEDURE mv-brw-defaultb-goods:
def var old-session as logical no-undo.
  old-session = SESSION:IMMEDIATE-DISPLAY.
  IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
  do varmvlb-goods = 2 to EXTENT(cur-clmn-numb-goods):
    RUN re-move-clmnb-goods (cur-clmn-numb-goods[varmvlb-goods], varmvlb-goods).
  END.
  RUN start-mv-clmnb-goods.
  SESSION:IMMEDIATE-DISPLAY = old-session.
END PROCEDURE.
.
def var sort-labelb-goods-   as character no-undo .
def var sort-clmnb-goods-    as handle    no-undo .
def var cur-clmnb-goods-     as handle    no-undo .
def var cur-clmn-locb-goods- as integer   no-undo .
def var re-queryb-goods-     as logical   initial no no-undo .
on start-search, ctrl-o of b-goods- in frame Dialog-Frame do:
   run sort-brb-goods-
     (input (if available bf_doc-line
             then recid(bf_doc-line)
             else ?
            )
     ).
end.
PROCEDURE sort-brb-goods- :
  define input parameter p-recid as recid no-undo .
  if re-queryb-goods- = no then do:
    assign
       cur-clmnb-goods- = b-goods-:current-column in frame Dialog-Frame
    .
    if sort-clmnb-goods- <> ? then sort-clmnb-goods-:column-fgcolor = 0.
    if cur-clmnb-goods- = sort-clmnb-goods- then do:
      assign
         sort-labelb-goods- = ""
         sort-clmnb-goods- = ?
      .
     end.
     else do:
       assign
         sort-labelb-goods- = cur-clmnb-goods-:label
         sort-clmnb-goods-  = cur-clmnb-goods-
         sort-clmnb-goods-:column-fgcolor = 4
       .
     end.
   end.
  assign
    cur-clmn-locb-goods- = 1
  .
  def var column-handle as handle no-undo .
  column-handle = b-goods-:first-column.
  do while valid-handle(column-handle) :
    if column-handle = cur-clmnb-goods- then do:
      leave .
    end.
    column-handle = column-handle:NEXT-COLUMN.
    assign
      cur-clmn-locb-goods- = cur-clmn-locb-goods- + 1
    .
  end.
  case sort-labelb-goods-:
        when '*'  then DO:   open query b-goods- FOR EACH bf_doc-line WHERE bf_doc-line.doc-code = bf_trn-doc.doc-code NO-LOCK,           FIRST bf_goods WHERE bf_goods.artic     = bf_doc-line.artic     AND                          bf_goods.prod-type = bf_doc-line.prod-type AND                          bf_goods.prod-code = bf_doc-line.prod-code NO-LOCK,           FIRST bf_parts WHERE bf_parts.out-code  = bf_doc-line.doc-code  AND                          bf_parts.obj-type  = bf_doc-line.obj-type  AND                          bf_parts.obj-code  = bf_doc-line.obj-code  AND                          bf_parts.artic     = bf_doc-line.artic     AND                          bf_parts.prod-type = bf_doc-line.prod-type AND                          bf_parts.prod-code = bf_doc-line.prod-code AND                          bf_parts.fact-qnty < 0 NO-LOCK by get-mark (buffer bf_doc-line) .   . END.
        when 'Артикул'  then DO:   open query b-goods- FOR EACH bf_doc-line WHERE bf_doc-line.doc-code = bf_trn-doc.doc-code NO-LOCK,           FIRST bf_goods WHERE bf_goods.artic     = bf_doc-line.artic     AND                          bf_goods.prod-type = bf_doc-line.prod-type AND                          bf_goods.prod-code = bf_doc-line.prod-code NO-LOCK,           FIRST bf_parts WHERE bf_parts.out-code  = bf_doc-line.doc-code  AND                          bf_parts.obj-type  = bf_doc-line.obj-type  AND                          bf_parts.obj-code  = bf_doc-line.obj-code  AND                          bf_parts.artic     = bf_doc-line.artic     AND                          bf_parts.prod-type = bf_doc-line.prod-type AND                          bf_parts.prod-code = bf_doc-line.prod-code AND                          bf_parts.fact-qnty < 0 NO-LOCK by bf_doc-line.artic .   . END.
        when 'Название товара'  then DO:   open query b-goods- FOR EACH bf_doc-line WHERE bf_doc-line.doc-code = bf_trn-doc.doc-code NO-LOCK,           FIRST bf_goods WHERE bf_goods.artic     = bf_doc-line.artic     AND                          bf_goods.prod-type = bf_doc-line.prod-type AND                          bf_goods.prod-code = bf_doc-line.prod-code NO-LOCK,           FIRST bf_parts WHERE bf_parts.out-code  = bf_doc-line.doc-code  AND                          bf_parts.obj-type  = bf_doc-line.obj-type  AND                          bf_parts.obj-code  = bf_doc-line.obj-code  AND                          bf_parts.artic     = bf_doc-line.artic     AND                          bf_parts.prod-type = bf_doc-line.prod-type AND                          bf_parts.prod-code = bf_doc-line.prod-code AND                          bf_parts.fact-qnty < 0 NO-LOCK by bf_goods.gds-name .   . END.
        when 'Тип'  then DO:   open query b-goods- FOR EACH bf_doc-line WHERE bf_doc-line.doc-code = bf_trn-doc.doc-code NO-LOCK,           FIRST bf_goods WHERE bf_goods.artic     = bf_doc-line.artic     AND                          bf_goods.prod-type = bf_doc-line.prod-type AND                          bf_goods.prod-code = bf_doc-line.prod-code NO-LOCK,           FIRST bf_parts WHERE bf_parts.out-code  = bf_doc-line.doc-code  AND                          bf_parts.obj-type  = bf_doc-line.obj-type  AND                          bf_parts.obj-code  = bf_doc-line.obj-code  AND                          bf_parts.artic     = bf_doc-line.artic     AND                          bf_parts.prod-type = bf_doc-line.prod-type AND                          bf_parts.prod-code = bf_doc-line.prod-code AND                          bf_parts.fact-qnty < 0 NO-LOCK by bf_doc-line.prod-type .   . END.
        when 'Код произ'  then DO:   open query b-goods- FOR EACH bf_doc-line WHERE bf_doc-line.doc-code = bf_trn-doc.doc-code NO-LOCK,           FIRST bf_goods WHERE bf_goods.artic     = bf_doc-line.artic     AND                          bf_goods.prod-type = bf_doc-line.prod-type AND                          bf_goods.prod-code = bf_doc-line.prod-code NO-LOCK,           FIRST bf_parts WHERE bf_parts.out-code  = bf_doc-line.doc-code  AND                          bf_parts.obj-type  = bf_doc-line.obj-type  AND                          bf_parts.obj-code  = bf_doc-line.obj-code  AND                          bf_parts.artic     = bf_doc-line.artic     AND                          bf_parts.prod-type = bf_doc-line.prod-type AND                          bf_parts.prod-code = bf_doc-line.prod-code AND                          bf_parts.fact-qnty < 0 NO-LOCK by bf_doc-line.prod-code .   . END.
        when 'Цена'  then DO:   open query b-goods- FOR EACH bf_doc-line WHERE bf_doc-line.doc-code = bf_trn-doc.doc-code NO-LOCK,           FIRST bf_goods WHERE bf_goods.artic     = bf_doc-line.artic     AND                          bf_goods.prod-type = bf_doc-line.prod-type AND                          bf_goods.prod-code = bf_doc-line.prod-code NO-LOCK,           FIRST bf_parts WHERE bf_parts.out-code  = bf_doc-line.doc-code  AND                          bf_parts.obj-type  = bf_doc-line.obj-type  AND                          bf_parts.obj-code  = bf_doc-line.obj-code  AND                          bf_parts.artic     = bf_doc-line.artic     AND                          bf_parts.prod-type = bf_doc-line.prod-type AND                          bf_parts.prod-code = bf_doc-line.prod-code AND                          bf_parts.fact-qnty < 0 NO-LOCK by get-price (buffer bf_goods) .   . END.
        when 'Спис. кол-во'  then DO:   open query b-goods- FOR EACH bf_doc-line WHERE bf_doc-line.doc-code = bf_trn-doc.doc-code NO-LOCK,           FIRST bf_goods WHERE bf_goods.artic     = bf_doc-line.artic     AND                          bf_goods.prod-type = bf_doc-line.prod-type AND                          bf_goods.prod-code = bf_doc-line.prod-code NO-LOCK,           FIRST bf_parts WHERE bf_parts.out-code  = bf_doc-line.doc-code  AND                          bf_parts.obj-type  = bf_doc-line.obj-type  AND                          bf_parts.obj-code  = bf_doc-line.obj-code  AND                          bf_parts.artic     = bf_doc-line.artic     AND                          bf_parts.prod-type = bf_doc-line.prod-type AND                          bf_parts.prod-code = bf_doc-line.prod-code AND                          bf_parts.fact-qnty < 0 NO-LOCK by get-write-off-qnty (BUFFER bf_doc-line) .   . END.
        when 'Спис. сумма (руб)'  then DO:   open query b-goods- FOR EACH bf_doc-line WHERE bf_doc-line.doc-code = bf_trn-doc.doc-code NO-LOCK,           FIRST bf_goods WHERE bf_goods.artic     = bf_doc-line.artic     AND                          bf_goods.prod-type = bf_doc-line.prod-type AND                          bf_goods.prod-code = bf_doc-line.prod-code NO-LOCK,           FIRST bf_parts WHERE bf_parts.out-code  = bf_doc-line.doc-code  AND                          bf_parts.obj-type  = bf_doc-line.obj-type  AND                          bf_parts.obj-code  = bf_doc-line.obj-code  AND                          bf_parts.artic     = bf_doc-line.artic     AND                          bf_parts.prod-type = bf_doc-line.prod-type AND                          bf_parts.prod-code = bf_doc-line.prod-code AND                          bf_parts.fact-qnty < 0 NO-LOCK by get-write-off-sum-rubl (BUFFER bf_doc-line) .   . END.
        when 'Спис. сумма (вал)'  then DO:   open query b-goods- FOR EACH bf_doc-line WHERE bf_doc-line.doc-code = bf_trn-doc.doc-code NO-LOCK,           FIRST bf_goods WHERE bf_goods.artic     = bf_doc-line.artic     AND                          bf_goods.prod-type = bf_doc-line.prod-type AND                          bf_goods.prod-code = bf_doc-line.prod-code NO-LOCK,           FIRST bf_parts WHERE bf_parts.out-code  = bf_doc-line.doc-code  AND                          bf_parts.obj-type  = bf_doc-line.obj-type  AND                          bf_parts.obj-code  = bf_doc-line.obj-code  AND                          bf_parts.artic     = bf_doc-line.artic     AND                          bf_parts.prod-type = bf_doc-line.prod-type AND                          bf_parts.prod-code = bf_doc-line.prod-code AND                          bf_parts.fact-qnty < 0 NO-LOCK by get-write-off-sum-base (BUFFER bf_doc-line) .   . END.
        when 'Спис. НДС (руб)'  then DO:   open query b-goods- FOR EACH bf_doc-line WHERE bf_doc-line.doc-code = bf_trn-doc.doc-code NO-LOCK,           FIRST bf_goods WHERE bf_goods.artic     = bf_doc-line.artic     AND                          bf_goods.prod-type = bf_doc-line.prod-type AND                          bf_goods.prod-code = bf_doc-line.prod-code NO-LOCK,           FIRST bf_parts WHERE bf_parts.out-code  = bf_doc-line.doc-code  AND                          bf_parts.obj-type  = bf_doc-line.obj-type  AND                          bf_parts.obj-code  = bf_doc-line.obj-code  AND                          bf_parts.artic     = bf_doc-line.artic     AND                          bf_parts.prod-type = bf_doc-line.prod-type AND                          bf_parts.prod-code = bf_doc-line.prod-code AND                          bf_parts.fact-qnty < 0 NO-LOCK by get-write-off-vat-rubl (BUFFER bf_doc-line) .   . END.
        when 'Спис. НДС (вал)'  then DO:   open query b-goods- FOR EACH bf_doc-line WHERE bf_doc-line.doc-code = bf_trn-doc.doc-code NO-LOCK,           FIRST bf_goods WHERE bf_goods.artic     = bf_doc-line.artic     AND                          bf_goods.prod-type = bf_doc-line.prod-type AND                          bf_goods.prod-code = bf_doc-line.prod-code NO-LOCK,           FIRST bf_parts WHERE bf_parts.out-code  = bf_doc-line.doc-code  AND                          bf_parts.obj-type  = bf_doc-line.obj-type  AND                          bf_parts.obj-code  = bf_doc-line.obj-code  AND                          bf_parts.artic     = bf_doc-line.artic     AND                          bf_parts.prod-type = bf_doc-line.prod-type AND                          bf_parts.prod-code = bf_doc-line.prod-code AND                          bf_parts.fact-qnty < 0 NO-LOCK by get-write-off-vat-base (BUFFER bf_doc-line) .   . END.
    otherwise do:
      OPEN QUERY b-goods- FOR EACH bf_doc-line WHERE bf_doc-line.doc-code = bf_trn-doc.doc-code NO-LOCK,           FIRST bf_goods WHERE bf_goods.artic     = bf_doc-line.artic     AND                          bf_goods.prod-type = bf_doc-line.prod-type AND                          bf_goods.prod-code = bf_doc-line.prod-code NO-LOCK,           FIRST bf_parts WHERE bf_parts.out-code  = bf_doc-line.doc-code  AND                          bf_parts.obj-type  = bf_doc-line.obj-type  AND                          bf_parts.obj-code  = bf_doc-line.obj-code  AND                          bf_parts.artic     = bf_doc-line.artic     AND                          bf_parts.prod-type = bf_doc-line.prod-type AND                          bf_parts.prod-code = bf_doc-line.prod-code AND                          bf_parts.fact-qnty < 0 NO-LOCK.
        if can-do( this-procedure:internal-entries, 'mv-brw-defaultb-goods-') then do:
          run mv-brw-defaultb-goods-.
        end.
      if sort-labelb-goods- <> "" then do:
        assign
          cur-clmnb-goods-:column-fgcolor = 0
        .
      end.
      assign
        cur-clmn-locb-goods- = ?
      .
    end.
  end case.
    if cur-clmn-locb-goods- <> ? then do:
      if can-do( this-procedure:internal-entries, 'ch-clmnb-goods-') then do:
        run ch-clmnb-goods- in this-procedure (cur-clmn-locb-goods-).
      end.
    end.
  if p-recid <> ? then do:
    reposition b-goods- to recid p-recid no-error.
    apply "value-changed" to b-goods- in frame Dialog-Frame.
  end.
  apply "entry" to b-goods- in frame Dialog-Frame.
END PROCEDURE.
procedure re-open-query-srt-clmnb-goods-:
if cur-clmnb-goods- = ? then do:
   OPEN QUERY b-goods- FOR EACH bf_doc-line WHERE bf_doc-line.doc-code = bf_trn-doc.doc-code NO-LOCK,           FIRST bf_goods WHERE bf_goods.artic     = bf_doc-line.artic     AND                          bf_goods.prod-type = bf_doc-line.prod-type AND                          bf_goods.prod-code = bf_doc-line.prod-code NO-LOCK,           FIRST bf_parts WHERE bf_parts.out-code  = bf_doc-line.doc-code  AND                          bf_parts.obj-type  = bf_doc-line.obj-type  AND                          bf_parts.obj-code  = bf_doc-line.obj-code  AND                          bf_parts.artic     = bf_doc-line.artic     AND                          bf_parts.prod-type = bf_doc-line.prod-type AND                          bf_parts.prod-code = bf_doc-line.prod-code AND                          bf_parts.fact-qnty < 0 NO-LOCK.
end.
else do:
   assign re-queryb-goods- = yes.
   run sort-brb-goods-
     (input (if available bf_doc-line
             then recid(bf_doc-line)
             else ?
            )
     ).
   assign re-queryb-goods- = no.
end.
end.
def var sort-labelb-goods   as character no-undo .
def var sort-clmnb-goods    as handle    no-undo .
def var cur-clmnb-goods     as handle    no-undo .
def var cur-clmn-locb-goods as integer   no-undo .
def var re-queryb-goods     as logical   initial no no-undo .
on start-search, ctrl-o of b-goods in frame Dialog-Frame do:
   run sort-brb-goods
     (input (if available bf-plus_doc-line
             then recid(bf-plus_doc-line)
             else ?
            )
     ).
end.
PROCEDURE sort-brb-goods :
  define input parameter p-recid as recid no-undo .
  if re-queryb-goods = no then do:
    assign
       cur-clmnb-goods = b-goods:current-column in frame Dialog-Frame
    .
    if sort-clmnb-goods <> ? then sort-clmnb-goods:column-fgcolor = 0.
    if cur-clmnb-goods = sort-clmnb-goods then do:
      assign
         sort-labelb-goods = ""
         sort-clmnb-goods = ?
      .
     end.
     else do:
       assign
         sort-labelb-goods = cur-clmnb-goods:label
         sort-clmnb-goods  = cur-clmnb-goods
         sort-clmnb-goods:column-fgcolor = 4
       .
     end.
   end.
  assign
    cur-clmn-locb-goods = 1
  .
  def var column-handle as handle no-undo .
  column-handle = b-goods:first-column.
  do while valid-handle(column-handle) :
    if column-handle = cur-clmnb-goods then do:
      leave .
    end.
    column-handle = column-handle:NEXT-COLUMN.
    assign
      cur-clmn-locb-goods = cur-clmn-locb-goods + 1
    .
  end.
  case sort-labelb-goods:
        when 'Артикул'  then DO:   open query b-goods FOR EACH bf-plus_doc-line WHERE bf-plus_doc-line.doc-code = bf_trn-doc.doc-code NO-LOCK,            FIRST bf-plus_goods WHERE bf-plus_goods.artic     = bf-plus_doc-line.artic     AND                               bf-plus_goods.prod-type = bf-plus_doc-line.prod-type AND                               bf-plus_goods.prod-code = bf-plus_doc-line.prod-code NO-LOCK,            FIRST bf_parts-root WHERE bf_parts-root.doc-code      = bf-plus_doc-line.doc-code AND                               bf_parts-root.gds-code      = bf-plus_goods.gds-code    AND                               bf_parts-root.orig-gds-code = bf_goods.gds-code   NO-LOCK by bf-plus_doc-line.artic .   . END.
        when 'Название товара'  then DO:   open query b-goods FOR EACH bf-plus_doc-line WHERE bf-plus_doc-line.doc-code = bf_trn-doc.doc-code NO-LOCK,            FIRST bf-plus_goods WHERE bf-plus_goods.artic     = bf-plus_doc-line.artic     AND                               bf-plus_goods.prod-type = bf-plus_doc-line.prod-type AND                               bf-plus_goods.prod-code = bf-plus_doc-line.prod-code NO-LOCK,            FIRST bf_parts-root WHERE bf_parts-root.doc-code      = bf-plus_doc-line.doc-code AND                               bf_parts-root.gds-code      = bf-plus_goods.gds-code    AND                               bf_parts-root.orig-gds-code = bf_goods.gds-code   NO-LOCK by bf-plus_goods.gds-name .   . END.
        when 'Тип'  then DO:   open query b-goods FOR EACH bf-plus_doc-line WHERE bf-plus_doc-line.doc-code = bf_trn-doc.doc-code NO-LOCK,            FIRST bf-plus_goods WHERE bf-plus_goods.artic     = bf-plus_doc-line.artic     AND                               bf-plus_goods.prod-type = bf-plus_doc-line.prod-type AND                               bf-plus_goods.prod-code = bf-plus_doc-line.prod-code NO-LOCK,            FIRST bf_parts-root WHERE bf_parts-root.doc-code      = bf-plus_doc-line.doc-code AND                               bf_parts-root.gds-code      = bf-plus_goods.gds-code    AND                               bf_parts-root.orig-gds-code = bf_goods.gds-code   NO-LOCK by bf-plus_doc-line.prod-type .   . END.
        when 'Код произ'  then DO:   open query b-goods FOR EACH bf-plus_doc-line WHERE bf-plus_doc-line.doc-code = bf_trn-doc.doc-code NO-LOCK,            FIRST bf-plus_goods WHERE bf-plus_goods.artic     = bf-plus_doc-line.artic     AND                               bf-plus_goods.prod-type = bf-plus_doc-line.prod-type AND                               bf-plus_goods.prod-code = bf-plus_doc-line.prod-code NO-LOCK,            FIRST bf_parts-root WHERE bf_parts-root.doc-code      = bf-plus_doc-line.doc-code AND                               bf_parts-root.gds-code      = bf-plus_goods.gds-code    AND                               bf_parts-root.orig-gds-code = bf_goods.gds-code   NO-LOCK by bf-plus_doc-line.prod-code .   . END.
        when 'Цена'  then DO:   open query b-goods FOR EACH bf-plus_doc-line WHERE bf-plus_doc-line.doc-code = bf_trn-doc.doc-code NO-LOCK,            FIRST bf-plus_goods WHERE bf-plus_goods.artic     = bf-plus_doc-line.artic     AND                               bf-plus_goods.prod-type = bf-plus_doc-line.prod-type AND                               bf-plus_goods.prod-code = bf-plus_doc-line.prod-code NO-LOCK,            FIRST bf_parts-root WHERE bf_parts-root.doc-code      = bf-plus_doc-line.doc-code AND                               bf_parts-root.gds-code      = bf-plus_goods.gds-code    AND                               bf_parts-root.orig-gds-code = bf_goods.gds-code   NO-LOCK by get-price (buffer bf-plus_goods) .   . END.
        when 'Оприх.кол-во'  then DO:   open query b-goods FOR EACH bf-plus_doc-line WHERE bf-plus_doc-line.doc-code = bf_trn-doc.doc-code NO-LOCK,            FIRST bf-plus_goods WHERE bf-plus_goods.artic     = bf-plus_doc-line.artic     AND                               bf-plus_goods.prod-type = bf-plus_doc-line.prod-type AND                               bf-plus_goods.prod-code = bf-plus_doc-line.prod-code NO-LOCK,            FIRST bf_parts-root WHERE bf_parts-root.doc-code      = bf-plus_doc-line.doc-code AND                               bf_parts-root.gds-code      = bf-plus_goods.gds-code    AND                               bf_parts-root.orig-gds-code = bf_goods.gds-code   NO-LOCK by get-income-qnty (BUFFER bf_doc-line, BUFFER bf-plus_doc-line) .   . END.
        when 'Оприх. сумма (руб)'  then DO:   open query b-goods FOR EACH bf-plus_doc-line WHERE bf-plus_doc-line.doc-code = bf_trn-doc.doc-code NO-LOCK,            FIRST bf-plus_goods WHERE bf-plus_goods.artic     = bf-plus_doc-line.artic     AND                               bf-plus_goods.prod-type = bf-plus_doc-line.prod-type AND                               bf-plus_goods.prod-code = bf-plus_doc-line.prod-code NO-LOCK,            FIRST bf_parts-root WHERE bf_parts-root.doc-code      = bf-plus_doc-line.doc-code AND                               bf_parts-root.gds-code      = bf-plus_goods.gds-code    AND                               bf_parts-root.orig-gds-code = bf_goods.gds-code   NO-LOCK by get-income-sum-rubl (BUFFER bf_doc-line, BUFFER bf-plus_doc-line) .   . END.
        when 'Оприх. сумма (вал)'  then DO:   open query b-goods FOR EACH bf-plus_doc-line WHERE bf-plus_doc-line.doc-code = bf_trn-doc.doc-code NO-LOCK,            FIRST bf-plus_goods WHERE bf-plus_goods.artic     = bf-plus_doc-line.artic     AND                               bf-plus_goods.prod-type = bf-plus_doc-line.prod-type AND                               bf-plus_goods.prod-code = bf-plus_doc-line.prod-code NO-LOCK,            FIRST bf_parts-root WHERE bf_parts-root.doc-code      = bf-plus_doc-line.doc-code AND                               bf_parts-root.gds-code      = bf-plus_goods.gds-code    AND                               bf_parts-root.orig-gds-code = bf_goods.gds-code   NO-LOCK by get-income-sum-base (BUFFER bf_doc-line, BUFFER bf-plus_doc-line) .   . END.
        when 'Оприх. НДС (руб)'  then DO:   open query b-goods FOR EACH bf-plus_doc-line WHERE bf-plus_doc-line.doc-code = bf_trn-doc.doc-code NO-LOCK,            FIRST bf-plus_goods WHERE bf-plus_goods.artic     = bf-plus_doc-line.artic     AND                               bf-plus_goods.prod-type = bf-plus_doc-line.prod-type AND                               bf-plus_goods.prod-code = bf-plus_doc-line.prod-code NO-LOCK,            FIRST bf_parts-root WHERE bf_parts-root.doc-code      = bf-plus_doc-line.doc-code AND                               bf_parts-root.gds-code      = bf-plus_goods.gds-code    AND                               bf_parts-root.orig-gds-code = bf_goods.gds-code   NO-LOCK by get-income-vat-rubl (BUFFER bf_doc-line, BUFFER bf-plus_doc-line) .   . END.
        when 'Оприх. НДС (вал)'  then DO:   open query b-goods FOR EACH bf-plus_doc-line WHERE bf-plus_doc-line.doc-code = bf_trn-doc.doc-code NO-LOCK,            FIRST bf-plus_goods WHERE bf-plus_goods.artic     = bf-plus_doc-line.artic     AND                               bf-plus_goods.prod-type = bf-plus_doc-line.prod-type AND                               bf-plus_goods.prod-code = bf-plus_doc-line.prod-code NO-LOCK,            FIRST bf_parts-root WHERE bf_parts-root.doc-code      = bf-plus_doc-line.doc-code AND                               bf_parts-root.gds-code      = bf-plus_goods.gds-code    AND                               bf_parts-root.orig-gds-code = bf_goods.gds-code   NO-LOCK by get-income-vat-base (BUFFER bf_doc-line, BUFFER bf-plus_doc-line) .   . END.
        when 'Отклонение %'  then DO:   open query b-goods FOR EACH bf-plus_doc-line WHERE bf-plus_doc-line.doc-code = bf_trn-doc.doc-code NO-LOCK,            FIRST bf-plus_goods WHERE bf-plus_goods.artic     = bf-plus_doc-line.artic     AND                               bf-plus_goods.prod-type = bf-plus_doc-line.prod-type AND                               bf-plus_goods.prod-code = bf-plus_doc-line.prod-code NO-LOCK,            FIRST bf_parts-root WHERE bf_parts-root.doc-code      = bf-plus_doc-line.doc-code AND                               bf_parts-root.gds-code      = bf-plus_goods.gds-code    AND                               bf_parts-root.orig-gds-code = bf_goods.gds-code   NO-LOCK by get-deviation-percent (BUFFER bf_doc-line, BUFFER bf-plus_doc-line) .   . END.
        when 'Отклонение (руб)'  then DO:   open query b-goods FOR EACH bf-plus_doc-line WHERE bf-plus_doc-line.doc-code = bf_trn-doc.doc-code NO-LOCK,            FIRST bf-plus_goods WHERE bf-plus_goods.artic     = bf-plus_doc-line.artic     AND                               bf-plus_goods.prod-type = bf-plus_doc-line.prod-type AND                               bf-plus_goods.prod-code = bf-plus_doc-line.prod-code NO-LOCK,            FIRST bf_parts-root WHERE bf_parts-root.doc-code      = bf-plus_doc-line.doc-code AND                               bf_parts-root.gds-code      = bf-plus_goods.gds-code    AND                               bf_parts-root.orig-gds-code = bf_goods.gds-code   NO-LOCK by get-deviation-abs-rubl (BUFFER bf_doc-line, BUFFER bf-plus_doc-line) .   . END.
        when 'Отклонение (вал)'  then DO:   open query b-goods FOR EACH bf-plus_doc-line WHERE bf-plus_doc-line.doc-code = bf_trn-doc.doc-code NO-LOCK,            FIRST bf-plus_goods WHERE bf-plus_goods.artic     = bf-plus_doc-line.artic     AND                               bf-plus_goods.prod-type = bf-plus_doc-line.prod-type AND                               bf-plus_goods.prod-code = bf-plus_doc-line.prod-code NO-LOCK,            FIRST bf_parts-root WHERE bf_parts-root.doc-code      = bf-plus_doc-line.doc-code AND                               bf_parts-root.gds-code      = bf-plus_goods.gds-code    AND                               bf_parts-root.orig-gds-code = bf_goods.gds-code   NO-LOCK by get-deviation-abs-base (BUFFER bf_doc-line, BUFFER bf-plus_doc-line) .   . END.
        when 'Спис. кол-во для оприх.кол-ва'  then DO:   open query b-goods FOR EACH bf-plus_doc-line WHERE bf-plus_doc-line.doc-code = bf_trn-doc.doc-code NO-LOCK,            FIRST bf-plus_goods WHERE bf-plus_goods.artic     = bf-plus_doc-line.artic     AND                               bf-plus_goods.prod-type = bf-plus_doc-line.prod-type AND                               bf-plus_goods.prod-code = bf-plus_doc-line.prod-code NO-LOCK,            FIRST bf_parts-root WHERE bf_parts-root.doc-code      = bf-plus_doc-line.doc-code AND                               bf_parts-root.gds-code      = bf-plus_goods.gds-code    AND                               bf_parts-root.orig-gds-code = bf_goods.gds-code   NO-LOCK by get-write-off-for-income-qnty (BUFFER bf_doc-line, BUFFER bf-plus_doc-line) .   . END.
    otherwise do:
      OPEN QUERY b-goods FOR EACH bf-plus_doc-line WHERE bf-plus_doc-line.doc-code = bf_trn-doc.doc-code NO-LOCK,            FIRST bf-plus_goods WHERE bf-plus_goods.artic     = bf-plus_doc-line.artic     AND                               bf-plus_goods.prod-type = bf-plus_doc-line.prod-type AND                               bf-plus_goods.prod-code = bf-plus_doc-line.prod-code NO-LOCK,            FIRST bf_parts-root WHERE bf_parts-root.doc-code      = bf-plus_doc-line.doc-code AND                               bf_parts-root.gds-code      = bf-plus_goods.gds-code    AND                               bf_parts-root.orig-gds-code = bf_goods.gds-code   NO-LOCK.
        if can-do( this-procedure:internal-entries, 'mv-brw-defaultb-goods') then do:
          run mv-brw-defaultb-goods.
        end.
      if sort-labelb-goods <> "" then do:
        assign
          cur-clmnb-goods:column-fgcolor = 0
        .
      end.
      assign
        cur-clmn-locb-goods = ?
      .
    end.
  end case.
    if cur-clmn-locb-goods <> ? then do:
      if can-do( this-procedure:internal-entries, 'ch-clmnb-goods') then do:
        run ch-clmnb-goods in this-procedure (cur-clmn-locb-goods).
      end.
    end.
  if p-recid <> ? then do:
    reposition b-goods to recid p-recid no-error.
    apply "value-changed" to b-goods in frame Dialog-Frame.
  end.
  apply "entry" to b-goods in frame Dialog-Frame.
END PROCEDURE.
procedure re-open-query-srt-clmnb-goods:
if cur-clmnb-goods = ? then do:
   OPEN QUERY b-goods FOR EACH bf-plus_doc-line WHERE bf-plus_doc-line.doc-code = bf_trn-doc.doc-code NO-LOCK,            FIRST bf-plus_goods WHERE bf-plus_goods.artic     = bf-plus_doc-line.artic     AND                               bf-plus_goods.prod-type = bf-plus_doc-line.prod-type AND                               bf-plus_goods.prod-code = bf-plus_doc-line.prod-code NO-LOCK,            FIRST bf_parts-root WHERE bf_parts-root.doc-code      = bf-plus_doc-line.doc-code AND                               bf_parts-root.gds-code      = bf-plus_goods.gds-code    AND                               bf_parts-root.orig-gds-code = bf_goods.gds-code   NO-LOCK.
end.
else do:
   assign re-queryb-goods = yes.
   run sort-brb-goods
     (input (if available bf-plus_doc-line
             then recid(bf-plus_doc-line)
             else ?
            )
     ).
   assign re-queryb-goods = no.
end.
end.
define variable vss-include-info44 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F3 of frame Dialog-Frame anywhere do:
  if b-lkp :sensitive then DO: apply "CHOOSE":U to b-lkp in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info45 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on CTRL-N, CTRL-Т of frame Dialog-Frame anywhere do:
  if b-add :sensitive then DO: apply "CHOOSE":U to b-add in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info46 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F4 of frame Dialog-Frame anywhere do:
  if b-chg :sensitive then DO: apply "CHOOSE":U to b-chg in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info47 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F8 of frame Dialog-Frame anywhere do:
  if b-del :sensitive then DO: apply "CHOOSE":U to b-del in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info48 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on INS of frame Dialog-Frame anywhere do:
  if b-mark :sensitive then DO: apply "CHOOSE":U to b-mark in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info49 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on ' ' of varfact-date in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.
on delete-character of varfact-date in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.
on ctrl-d of varfact-date in frame Dialog-Frame
do:
  define variable v-curr-sv-date as date no-undo .
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    run gbl/getcurdt.p
      (output v-curr-sv-date
      ) .
    assign
      self :screen-value = string(v-curr-sv-date) .
    .
  end.
  return no-apply.
end.
on ctrl-b of varfact-date in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      assign
        v-new-sv-date = date( month(v-curr-sv-date), 1, year(v-curr-sv-date))
      .
      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.
  return no-apply .
end.
on ctrl-e of varfact-date in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      run gbl/lastdate.p
        (input  v-curr-sv-date
        ,output v-new-sv-date
        ).
      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.
  return no-apply .
end.
on ctrl-f of varfact-date in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-ok            as logical   no-undo .
    define variable v-curr-sv-date  as date      no-undo .
    define variable v-description   as character no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      run gbl/d-inpday.w
        (input ?
        ,input "Выбор даты"
        ,input v-description
        ,input ""
        ,input-output v-curr-sv-date
        ,output v-ok
        ).
      if v-ok = true
      then do:
        assign
          self :screen-value = string(v-curr-sv-date) .
        .
      end.
    end.
  end.
  return no-apply .
end.
  define MENU m-ed-date50
    MENU-ITEM m-ed-date50-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date50-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date50-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date50-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if varfact-date :POPUP-MENU in frame Dialog-Frame = ?
  then do:
    ASSIGN
      varfact-date :POPUP-MENU in frame Dialog-Frame = MENU m-ed-date50 :HANDLE
      varfact-date :MENU-MOUSE in frame Dialog-Frame = 3
    .
  end.
  define variable v-label-handle50 as handle no-undo .
  assign
    v-label-handle50 = varfact-date :side-label-handle in frame Dialog-Frame
  .
  if valid-handle (v-label-handle50)
  then do:
    if v-label-handle50 :tooltip = ""
    or v-label-handle50 :tooltip = ?
    then do:
      assign
        v-label-handle50 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date50-1 in menu m-ed-date50 DO:
    apply "ctrl-b":U to varfact-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date50-2 in menu m-ed-date50 DO:
    apply "ctrl-d":U to varfact-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date50-3 in menu m-ed-date50 DO:
    apply "ctrl-e":U to varfact-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date50-4 in menu m-ed-date50 DO:
    apply "ctrl-f":U to varfact-date in frame Dialog-Frame .
  END.
define variable vss-include-info51 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on ' ' of varshift-date in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.
on delete-character of varshift-date in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.
on ctrl-d of varshift-date in frame Dialog-Frame
do:
  define variable v-curr-sv-date as date no-undo .
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    run gbl/getcurdt.p
      (output v-curr-sv-date
      ) .
    assign
      self :screen-value = string(v-curr-sv-date) .
    .
  end.
  return no-apply.
end.
on ctrl-b of varshift-date in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      assign
        v-new-sv-date = date( month(v-curr-sv-date), 1, year(v-curr-sv-date))
      .
      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.
  return no-apply .
end.
on ctrl-e of varshift-date in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      run gbl/lastdate.p
        (input  v-curr-sv-date
        ,output v-new-sv-date
        ).
      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.
  return no-apply .
end.
on ctrl-f of varshift-date in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-ok            as logical   no-undo .
    define variable v-curr-sv-date  as date      no-undo .
    define variable v-description   as character no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      run gbl/d-inpday.w
        (input ?
        ,input "Выбор даты"
        ,input v-description
        ,input ""
        ,input-output v-curr-sv-date
        ,output v-ok
        ).
      if v-ok = true
      then do:
        assign
          self :screen-value = string(v-curr-sv-date) .
        .
      end.
    end.
  end.
  return no-apply .
end.
  define MENU m-ed-date52
    MENU-ITEM m-ed-date52-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date52-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date52-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date52-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if varshift-date :POPUP-MENU in frame Dialog-Frame = ?
  then do:
    ASSIGN
      varshift-date :POPUP-MENU in frame Dialog-Frame = MENU m-ed-date52 :HANDLE
      varshift-date :MENU-MOUSE in frame Dialog-Frame = 3
    .
  end.
  define variable v-label-handle52 as handle no-undo .
  assign
    v-label-handle52 = varshift-date :side-label-handle in frame Dialog-Frame
  .
  if valid-handle (v-label-handle52)
  then do:
    if v-label-handle52 :tooltip = ""
    or v-label-handle52 :tooltip = ?
    then do:
      assign
        v-label-handle52 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date52-1 in menu m-ed-date52 DO:
    apply "ctrl-b":U to varshift-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date52-2 in menu m-ed-date52 DO:
    apply "ctrl-d":U to varshift-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date52-3 in menu m-ed-date52 DO:
    apply "ctrl-e":U to varshift-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date52-4 in menu m-ed-date52 DO:
    apply "ctrl-f":U to varshift-date in frame Dialog-Frame .
  END.
ON CHOOSE OF b-next IN FRAME Dialog-Frame
DO:
  RUN step-next in this-procedure .
END.
procedure step-next:
define variable cur-form as char no-undo.
define variable new-form as char no-undo.
define buffer new_trn-doc for ub.trn-doc  .
case bf_trn-doc.doc-type:
  when 'при':U then
    cur-form = if bf_trn-doc.internal then 'рас':U else 'при':U.
  when 'рас':U or when 'возврат':U or when 'спи':U then
    cur-form = 'рас':U.
  when 'инв':U then cur-form = 'инв':U.
end case.
if bf-handle = ? then return .
if valid-handle (br-handle) then do:
  varlog = br-handle:select-next-row().
  find first new_trn-doc no-lock where  recid( new_trn-doc ) = bf-handle:recid no-error .
  if not varlog then message "Это последний документ списка.".
end.
case new_trn-doc.doc-type:
  when 'при':U then
    new-form = if new_trn-doc.internal then 'рас':U else 'при':U.
  when 'рас':U or when 'возврат':U or when 'спи':U then
    new-form = 'рас':U.
  when 'инв':U then new-form = 'инв':U.
end case.
assign
    pardoc-rec   = bf-handle:recid
    parnext-prev = ( cur-form = new-form ) .
end procedure.
ON CHOOSE OF b-prev IN FRAME Dialog-Frame
DO:
  run step-prev in this-procedure .
END.
procedure step-prev:
define variable cur-form as char no-undo.
define variable new-form as char no-undo.
define buffer new_trn-doc for ub.trn-doc  .
case bf_trn-doc.doc-type:
  when 'при':U then if bf_trn-doc.internal then cur-form = 'рас':U. else cur-form = 'при':U.
  when 'рас':U or when 'возврат':U or when 'спи':U then cur-form = 'рас':U.
  when 'инв':U then cur-form = 'инв':U.
end case.
if bf-handle = ? then return .
if valid-handle (br-handle) then do:
  varlog = br-handle:select-prev-row().
  find first new_trn-doc no-lock where  recid( new_trn-doc ) = bf-handle:recid no-error .
  if not varlog then message "Это первый документ списка.".
end.
case new_trn-doc.doc-type :
  when 'при':U then if new_trn-doc.internal then new-form = 'рас':U. else new-form = 'при':U.
  when 'рас':U or when 'возврат':U or when 'спи':U then  new-form = 'рас':U.
  when 'инв':U then new-form = 'инв':U.
end case.
assign
  pardoc-rec   = bf-handle:recid
  parnext-prev = (cur-form = new-form)
.
end procedure.
assign
  b-goods-:allow-column-searching in frame  Dialog-Frame  = yes
  b-goods:allow-column-searching  in frame  Dialog-Frame  = yes
  b-goods-:num-locked-columns     in frame  Dialog-Frame  = 2
  b-goods:num-locked-columns      in frame  Dialog-Frame  = 1
  bf_goods.gds-name:resizable     in browse b-goods-       = yes
  bf_goods.gds-name:width-chars   in browse b-goods-       = 20
  bf-plus_goods.gds-name:resizable      in browse b-goods        = yes
  bf-plus_goods.gds-name:width-chars    in browse b-goods        = 20
  frame Dialog-Frame:scrollable                           = false
  parext-doc-mode =
    ( if num-entries( pardoc-mode, '*':U ) > 1 then entry( 2, pardoc-mode, '*':U ) else '':U )
  pardoc-mode     = entry( 1, pardoc-mode, '*':U )
.
.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info53 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info54 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
assign parnext-prev = yes.
n-p:
do while parnext-prev :
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
define variable vss-include-info55 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varr-b
  )  .
  find first bf-obj_clients where bf-obj_clients.obj-type = parobj-type and
                                  bf-obj_clients.obj-code = parobj-code no-lock.
  find first bf-host_clients where bf-host_clients.obj-type = 'орг':U                   and
                                   bf-host_clients.obj-code = bf-obj_clients.host-code no-lock.
  find first bf_sysconf where bf_sysconf.host-code = bf-obj_clients.host-code no-lock.
  run mode-on in this-procedure no-error.
  if error-status:error then do:
    assign
      parnext-prev = no.
    return error.
  end.
  run ui-on in this-procedure ( input "":U ) no-error.
  if error-status:error then do:
    assign
      parnext-prev = no.
    return error.
  end.
  run enable_ui no-error.
  if error-status:error then do:
    assign
      parnext-prev = no.
    return error.
  end.
define variable vss-include-info56 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
empty temp-table thbjattr_thbj-attr.
run adm/shattri.p (
   input "get":U
  ,input bf_trn-doc.obj-type
  ,input bf_trn-doc.obj-code
  ,input 'inv-obj':U
  ,input  ""
  ,output v-value-character
  ,output v-value-date
  ,output v-value-decimal
  ,output v-value-integer
  ,output v-value-logical
  ,output par-type
  ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
  ) no-error .
    for each thbjattr_thbj-attr :
        if thbjattr_thbj-attr.prop-code = 'pstgrp' then vargrp-is-eq = thbjattr_thbj-attr.property-value-logical.
        if thbjattr_thbj-attr.prop-code = 'pstunit' then varpstunit = thbjattr_thbj-attr.property-value-logical.
        if thbjattr_thbj-attr.prop-code = 'pstunqtn' then varpstunqtn-log = thbjattr_thbj-attr.property-value-logical.
        if thbjattr_thbj-attr.prop-code = 'mxpcicp' then varmxpcicp-dec = thbjattr_thbj-attr.property-value-decimal.
        if thbjattr_thbj-attr.prop-code = 'mxpcdcp' then varmxpcdcp-dec = thbjattr_thbj-attr.property-value-decimal.
        if thbjattr_thbj-attr.prop-code = 'mxsmicp' then varmxsmicp-dec = thbjattr_thbj-attr.property-value-decimal.
        if thbjattr_thbj-attr.prop-code = 'mxsmdcp' then varmxsmdcp-dec = thbjattr_thbj-attr.property-value-decimal.
    end.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
END.
RUN disable_UI.
PROCEDURE add-doc :
define output parameter parrecid as recid no-undo.
define variable vardoc-code   like ub.trn-doc.doc-code    no-undo.
define variable v-today       as date                     no-undo.
define variable varbase-rate  as decimal no-undo.
define variable varbase-scale as decimal no-undo.
define variable varsupp-code  as integer   no-undo.
define variable varsupp-type  as character no-undo.
define variable varsupp-name  as character no-undo.
define buffer bf_pay-type     for ub.pay-type.
define buffer bf-supp_clients for ub.clients.
define buffer bf_sys-ctrl     for ub.sys-ctrl.
define buffer bf_store for ub.store.
define buffer bf_shop  for ub.shop.
do on error undo, return error RETURN-VALUE :
  if not parold-supp-cntr then do:
    FIND FIRST bf-supp_clients WHERE bf-supp_clients.obj-type = parcli-type AND
                                     bf-supp_clients.obj-code = parcli-code NO-LOCK.
    ASSIGN
      varcli-type = bf-supp_clients.obj-type
      varcli-code = bf-supp_clients.obj-code
      varcli-name = bf-supp_clients.obj-name.
  end.
  if bf-obj_clients.obj-type = 'маг':U then do:
    find first bf_shop where bf_shop.obj-code = bf-obj_clients.obj-code no-lock.
    FIND FIRST bf_pay-type where bf_pay-type.obj-code = bf_shop.inv-pay NO-LOCK NO-ERROR.
  end.
  else do:
    find first bf_store where bf_store.obj-code = bf-obj_clients.obj-code no-lock.
    FIND FIRST bf_pay-type where bf_pay-type.obj-code = bf_store.inv-pay NO-LOCK NO-ERROR.
  end.
  if not AVAILABLE bf_pay-type then do:
    message "Не задан код оплаты для инвентаризации в настройках по текущему объекту." VIEW-AS ALERT-BOX.
    return error.
  end.
  find first bf_sys-ctrl no-lock.
  run doc-code in this-procedure
  (input  "main",
   input  parobj-type,
   input  parobj-code,
   input  ?,
   output vardoc-code ) no-error.
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при генерации номера документа." skip
      return-value skip
      view-as alert-box error.
    undo, return error .
  end.
define variable vss-include-info57 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curobjdt in g#library
  (input  parobj-type
  ,input  parobj-code
  ,output v-today
  ) NO-ERROR .
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при определении даты объекта." skip
      return-value skip
      view-as alert-box error.
    undo, return error .
  end.
define variable vss-include-info58 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run baserate in g#library
  (input  bf-obj_clients.host-code
  ,input  v-today
  ,output varbase-rate
  ,output varbase-scale
  ) NO-ERROR .
  if not parold-supp-cntr then do:
    assign
      varsupp-code = bf-supp_clients.obj-code
      varsupp-type = bf-supp_clients.obj-type
      varsupp-name = bf-supp_clients.obj-name
    .
  end.
  else do:
    assign
      varsupp-code = bf-host_clients.obj-code
      varsupp-type = bf-host_clients.obj-type
      varsupp-name = bf-host_clients.obj-name
    .
  end.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_crtrndoc in g#lib-trn
(input ?
,input ?
,input varbase-rate
,input varbase-scale
,input varsupp-code
,input varsupp-type
,input varsupp-name
,input v-cntxt-db-num
,input v-cntxt-userid
,input ' '
,input vardoc-code
,input v-today
,input 'инв':U
,input no
,input bf-host_clients.obj-code
,input no
,input parobj-code
,input parobj-type
,input no
,input bf_pay-type.obj-code
,input '@  '
,input no
,input 'без':U
,input 'накл':U
,input 'в т. ч.':U
,input 'vp':U
,input ?
) no-error
.
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка создания документа." skip
      return-value skip
      view-as alert-box error.
    undo, return error .
  end.
  find bf_trn-doc where bf_trn-doc.doc-code = vardoc-code EXCLUSIVE-LOCK.
  if not parold-supp-cntr then do:
    ASSIGN
      bf_trn-doc.contract-code = parcontract-code.
  end.
  else do:
    assign
      bf_trn-doc.contract-code = 0.
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-wrt in g#trdcalib ( input bf_trn-doc.doc-code ,
                       input 'olsuppcntr':U ,
                       input 'yes' )  .
  end.
  assign
    pardoc-rec  = recid( bf_trn-doc )
    pardoc-mode = 'ИЗМЕНЕНИЕ':U.
  assign parrecid = recid( bf_trn-doc ).
end.
END PROCEDURE.
PROCEDURE chk-upd-date :
define variable vartoday as date      no-undo.
define variable vartime  as integer   no-undo.
DEFINE VARIABLE varlog   AS LOGICAL   NO-UNDO.
if input frame Dialog-Frame varfact-date  <> varfact-date then do:
define variable vss-include-info59 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curobjdt in g#library
  (input  bf_trn-doc.obj-type
  ,input  bf_trn-doc.obj-code
  ,output vartoday
  )  .
  if input frame Dialog-Frame varfact-date > vartoday then do:
     message "Дата больше сегодняшней даты на объекте." view-as alert-box error.
     display varfact-date with frame Dialog-Frame.
     return error.
  end.
  if input frame Dialog-Frame varfact-date < vartoday - 7 then do:
     ASSIGN
       varlog = yes.
     message "Заведенная факт дата отличается более чем на 7 дней от сегодняшней даты на объекте."
             "Отказаться от заведения даты?" view-as alert-box question
             buttons yes-no update varlog.
     if varlog then do:
        display varfact-date with frame Dialog-Frame.
        return error.
     end.
  end.
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
          ,input v-cntxt-obj-type
          ,input v-cntxt-obj-code
          ,input 'nakl_par':U
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
      message "Запрещено работать задним числом !" view-as alert-box information .
      display varfact-date with frame Dialog-Frame.
      return error.
    end.
  assign
    varlog = no
  .
define variable vss-include-info60 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_tdedt-peresort_add-back-date':u
    ,input  'object':U
    ,input  bf_trn-doc.host-code
    ,input  bf_trn-doc.obj-type
    ,input  bf_trn-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output varlog
    )  .
end.
  if varlog <> YES then do:
     display varfact-date with frame Dialog-Frame.
     return error.
  end.
  ASSIGN
    varlog = no.
  message "Вы хотите изменить фактическую дату?" skip
          "Если дату задать как '?' она при закрытии на факт проставится днем закрытия."
  view-as alert-box question buttons yes-no update varlog.
  if not varlog then do:
    display varfact-date with frame Dialog-Frame.
    return error.
  end.
  assign frame Dialog-Frame
    varfact-date.
  assign
    bf_trn-doc.fact-date = varfact-date
    bf_trn-doc.fact-time = (24 * 60 * 60).
end.
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY varwrkr varwrkr-name vardoc-date varagnt varagnt-name varfact-date
          varboss varboss-name varshift-date varshift-name varshift-num
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-prev b-next b-sum-doc b-arch b-notes b-cnt b-history b-help
         b-lkp b-parts b-parts-plus b-sum-goods b-sum-goods-plus b-goods-
         b-goods
      WITH FRAME Dialog-Frame.
  OPEN QUERY b-goods FOR EACH bf-plus_doc-line WHERE bf-plus_doc-line.doc-code = bf_trn-doc.doc-code NO-LOCK,            FIRST bf-plus_goods WHERE bf-plus_goods.artic     = bf-plus_doc-line.artic     AND                               bf-plus_goods.prod-type = bf-plus_doc-line.prod-type AND                               bf-plus_goods.prod-code = bf-plus_doc-line.prod-code NO-LOCK,            FIRST bf_parts-root WHERE bf_parts-root.doc-code      = bf-plus_doc-line.doc-code AND                               bf_parts-root.gds-code      = bf-plus_goods.gds-code    AND                               bf_parts-root.orig-gds-code = bf_goods.gds-code   NO-LOCK.    OPEN QUERY b-goods- FOR EACH bf_doc-line WHERE bf_doc-line.doc-code = bf_trn-doc.doc-code NO-LOCK,           FIRST bf_goods WHERE bf_goods.artic     = bf_doc-line.artic     AND                          bf_goods.prod-type = bf_doc-line.prod-type AND                          bf_goods.prod-code = bf_doc-line.prod-code NO-LOCK,           FIRST bf_parts WHERE bf_parts.out-code  = bf_doc-line.doc-code  AND                          bf_parts.obj-type  = bf_doc-line.obj-type  AND                          bf_parts.obj-code  = bf_doc-line.obj-code  AND                          bf_parts.artic     = bf_doc-line.artic     AND                          bf_parts.prod-type = bf_doc-line.prod-type AND                          bf_parts.prod-code = bf_doc-line.prod-code AND                          bf_parts.fact-qnty < 0 NO-LOCK.
END PROCEDURE.
PROCEDURE local-add :
define variable varrec-minus-line as recid no-undo.
define variable varrec-plus-line  as recid no-undo.
define variable varadd as logical no-undo.
define buffer bf-add_doc-line      for ub.doc-line.
define buffer bf-add-plus_doc-line for ub.doc-line.
run str/pstlnadd.p
  (input  parparentproc,
   input  this-procedure,
   input  bf_trn-doc.doc-code,
   input  parold-supp-cntr,
   input  varpstunqtn-log,
   input  varmxpcicp-dec,
   input  varmxpcdcp-dec,
   input  varmxsmicp-dec,
   input  varmxsmdcp-dec,
   input  vargrp-is-eq,
   input  varpstunit,
   output varrec-minus-line,
   output varrec-plus-line,
   output varadd)         no-error.
if error-status:error then do:
  return error return-value.
end.
if varadd = yes then do:
  for each tt-recalc-line on error undo, return error return-value :
    delete tt-recalc-line.
  end.
  find first bf-add_doc-line      where recid(bf-add_doc-line)      = varrec-minus-line.
  run proc-get-write-off in this-procedure (buffer bf-add_doc-line).
  create tt-recalc-line.
  buffer-copy bf-add_doc-line to tt-recalc-line.
  find first bf-add-plus_doc-line where recid(bf-add-plus_doc-line) = varrec-plus-line.
  run proc-get-write-off in this-procedure (buffer bf-add-plus_doc-line).
  create tt-recalc-line.
  buffer-copy bf-add-plus_doc-line to tt-recalc-line.
  run recalc-line in this-procedure no-error.
  if error-status:error then do:
    return error substitute ("Ошибка при пересчете строк документа: ", return-value).
  end.
  run ui-on in this-procedure ("":u) .
  reposition b-goods- to recid varrec-minus-line.
  APPLY "value-changed" TO b-goods- IN FRAME Dialog-Frame.
end.
END PROCEDURE.
PROCEDURE local-chg :
define variable varchg as logical no-undo.
do on error undo, return error return-value :
run str/pstlnupd.p
  (input  parparentproc,
   input  this-procedure,
   input  bf_trn-doc.doc-code,
   input  parold-supp-cntr,
   input  varpstunqtn-log,
   input  varpstunit,
   input  varmxpcicp-dec,
   input  varmxpcdcp-dec,
   input  varmxsmicp-dec,
   input  varmxsmdcp-dec,
   input  recid(bf_doc-line),
   input  recid(bf-plus_doc-line),
   output varchg) no-error.
if error-status:error then do:
  return error return-value.
end.
if varchg = yes then do:
  for each tt-recalc-line on error undo, return error return-value :
    delete tt-recalc-line.
  end.
  create tt-recalc-line.
  buffer-copy bf_doc-line to tt-recalc-line.
  create tt-recalc-line.
  buffer-copy bf-plus_doc-line to tt-recalc-line.
  run recalc-line in this-procedure no-error.
  if error-status:error then do:
    return error substitute ("Ошибка при пересчете строк документа: ", return-value).
  end.
end.
end.
END PROCEDURE.
PROCEDURE local-del :
do on error undo, return error return-value :
define output parameter parrep-rec as recid no-undo.
define variable vartemp-rec as recid no-undo.
define buffer bf-del_parts             for ub.parts.
define buffer bf-del_doc-line          for ub.doc-line.
define buffer bf-del_goods             for ub.goods.
define buffer bf-del_gds-prt           for ub.gds-prt.
define buffer bf-del_gds-dtl           for ub.gds-dtl.
define buffer bf-del_parts-root        for ub.parts-root.
define buffer bf-del-plus_parts        for ub.parts.
define buffer bf-del-plus_doc-line     for ub.doc-line.
define buffer bf-del-plus_goods        for ub.goods.
define buffer bf-del-plus_gds-prt      for ub.gds-prt.
define buffer bf-del-check_parts       for ub.parts.
define buffer bf-del-check-plus_parts  for ub.parts.
define buffer bf-del_doc-pl            for ub.doc-pl.
define buffer bf-del-plus_doc-pl       for ub.doc-pl.
define variable vardel-one-sheaf          as logical initial no no-undo.
define variable varrecdoc-line            as recid              no-undo.
define variable varrecdoc-line-plus       as recid              no-undo.
define variable vargoods-num              as integer            no-undo.
define variable varrsrv-qnty              as decimal            no-undo.
define variable varmem-qnty               as decimal            no-undo.
define variable varchg-qnty               as decimal            no-undo.
define variable vargoods-plus             as integer            no-undo.
define variable varnum                    as integer            no-undo.
define variable varlog                    as logical            no-undo.
define variable varrsrv-plus-parts-real   as decimal            no-undo.
define variable varrsrv-plus-parts        as decimal            no-undo.
define variable varrsrv-plus-qnty         as decimal            no-undo.
define variable varis-petrol              as logical            no-undo.
define variable varis-pieces              as logical            no-undo.
define variable varis-petrol-plus         as logical            no-undo.
define variable varis-pieces-plus         as logical            no-undo.
define variable vardensity-doc-pl         as decimal            no-undo.
define variable varone-line               as logical            no-undo.
do on error undo, return error return-value :
for each tt-recalc-line on error undo, return error return-value :
  delete tt-recalc-line.
end.
find first tt-del-list no-error.
if not available tt-del-list then do:
  if not available bf_doc-line then do:
    return error "Неправильный выбор строки списанного товара.".
  end.
  find first bf-del_doc-line where recid(bf-del_doc-line) = recid(bf_doc-line) exclusive-lock.
  find first bf-del_goods where bf-del_goods.artic     = bf-del_doc-line.artic     and
                                bf-del_goods.prod-type = bf-del_doc-line.prod-type and
                                bf-del_goods.prod-code = bf-del_doc-line.prod-code no-lock.
  assign
    vargoods-plus = 0.
  for each bf-del_parts-root where bf-del_parts-root.doc-code       = bf_trn-doc.doc-code   and
                                   bf-del_parts-root.orig-gds-code  = bf-del_goods.gds-code
                                   use-index pi break by bf-del_parts-root.gds-code on error undo, return error return-value :
    if first-of(bf-del_parts-root.gds-code) then do:
      assign
        vargoods-plus = vargoods-plus + 1.
    end.
  end.
  if vargoods-plus > 1 then do:
    if not available bf-plus_doc-line then do:
      return error "Неправильный выбор строки оприходованного товара.".
    end.
    find first bf-del-plus_doc-line where recid(bf-del-plus_doc-line) = recid(bf-plus_doc-line) exclusive-lock.
    find first bf-del-plus_goods where bf-del-plus_goods.artic     = bf-del-plus_doc-line.artic     and
                                       bf-del-plus_goods.prod-type = bf-del-plus_doc-line.prod-type and
                                       bf-del-plus_goods.prod-code = bf-del-plus_doc-line.prod-code no-lock.
    assign
      varone-line = yes.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_is-petrl in g#lib-trn
  (
     input bf-del_goods.artic
  ,  input bf-del_goods.prod-type
  ,  input bf-del_goods.prod-code
  , output varis-petrol
  , output varis-pieces
  ) .
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_is-petrl in g#lib-trn
  (
     input bf-del-plus_goods.artic
  ,  input bf-del-plus_goods.prod-type
  ,  input bf-del-plus_goods.prod-code
  , output varis-petrol-plus
  , output varis-pieces-plus
  ) .
    if varis-petrol     and
       not varis-pieces then do:
      assign
        varone-line = no.
    end.
    if varis-petrol-plus and
       not varis-pieces-plus then do:
      assign
        varone-line = no.
    end.
    find first bf-del_gds-prt where bf-del_gds-prt.upper-code = bf-del_goods.prt-root no-lock.
    if bf-del_gds-prt.node-name <> '_Пустая шкала':U then do:
      assign
        varone-line = no.
    end.
    find first bf-del-plus_gds-prt where bf-del-plus_gds-prt.upper-code = bf-del-plus_goods.prt-root no-lock.
    if bf-del-plus_gds-prt.node-name <> '_Пустая шкала':U then do:
      assign
        varone-line = no.
    end.
    if varone-line = yes then do:
      run gbl/d-askw.w
        (input "Удаление в документе пересортицы"
        ,input "Товар для списания "                         +
               bf-del_goods.artic                            + " " +
               bf-del_goods.prod-type                        + " " +
               string(bf-del_goods.prod-code)                + " " +
               substring(bf-del_goods.gds-name, 1, 30)       +
               "Спозиционированный товар для оприходования " +
               bf-del-plus_goods.artic                       + " " +
               bf-del-plus_goods.prod-type                   + " " +
               string(bf-del-plus_goods.prod-code)           + " " +
               substring(bf-del-plus_goods.gds-name, 1, 30)
        ,input "|^"
        ,input "Все|Только спозиц.|Отменить"
        ,input "Всем товарам для оприходования|"
             + "Только спозиционированному товару|"
             + "Отменить удаление"
        ,input 1
        ,input 3
        ,output varnum
        ).
      case varnum:
        when 1 then do:
          assign
            vartemp-rec =  recid (bf-del_doc-line).
          create tt-del-list.
          assign
            tt-del-list.rec-id = recid (bf-del_doc-line).
        end.
        when 2 then do:
          assign
            vardel-one-sheaf    = yes
            varrecdoc-line      = recid (bf-del_doc-line)
            varrecdoc-line-plus = recid (bf-del-plus_doc-line)
          .
        end.
        when 3 then do:
          return error.
        end.
      end case.
    end.
    else do:
      assign
        varlog = no.
      message "Удалить строку из документа? Вы уверены?"
              view-as alert-box question buttons ok-cancel update varlog.
      if not varlog then return error.
      assign
        vartemp-rec =  recid (bf-del_doc-line).
      create tt-del-list.
      assign
        tt-del-list.rec-id = recid (bf-del_doc-line).
    end.
  end.
  else do:
    assign
      varlog = no.
    message "Удалить строку из документа? Вы уверены?"
            view-as alert-box question buttons ok-cancel update varlog.
    if not varlog then return error.
    assign
      vartemp-rec =  recid (bf-del_doc-line).
    create tt-del-list.
    assign
      tt-del-list.rec-id = recid (bf-del_doc-line).
  end.
  get next b-goods-.
  if available bf_doc-line then do:
    assign
      parrep-rec = recid (bf_doc-line).
  end.
  else do:
    reposition b-goods- to recid vartemp-rec no-error.
    get prev b-goods-.
    assign
      parrep-rec = recid (bf_doc-line).
  end.
end.
else do:
  assign
    varlog = no.
  message "УДАЛИТЬ ВСЕ ОТМЕЧЕННЫЕ строки документа? Вы уверены ?"
  view-as alert-box question buttons ok-cancel update varlog.
  if not varlog then do:
    return error.
  end.
  assign
    parrep-rec = ?.
end.
if vardel-one-sheaf <> yes then do:
  for each tt-del-list on error undo, return error return-value :
    find first bf-del_doc-line where recid (bf-del_doc-line) = tt-del-list.rec-id exclusive-lock no-error.
    if not available bf-del_doc-line then do:
      undo, return error "Ошибка при удалении линии. Не найдена линия для удаления.".
    end.
    find first bf-del_goods where bf-del_goods.artic     = bf-del_doc-line.artic     and
                                  bf-del_goods.prod-type = bf-del_doc-line.prod-type and
                                  bf-del_goods.prod-code = bf-del_doc-line.prod-code no-lock.
    run local-recalc in this-procedure (input "old":u,
                                        input recid(bf-del_doc-line),
                                        input yes) no-error.
    if error-status:error then do:
      undo, return error substitute ("Ошибка при пересчете строки документа: &1.", return-value).
    end.
    assign
      varrsrv-qnty = 0.00.
    for each bf-del_parts where bf-del_parts.out-code  = bf_trn-doc.doc-code       and
                                bf-del_parts.obj-type  = bf_trn-doc.obj-type       and
                                bf-del_parts.obj-code  = bf_trn-doc.obj-code       and
                                bf-del_parts.artic     = bf-del_doc-line.artic     and
                                bf-del_parts.prod-type = bf-del_doc-line.prod-type and
                                bf-del_parts.prod-code = bf-del_doc-line.prod-code and
                                bf-del_parts.fact-qnty < 0                         exclusive-lock on error undo, return error return-value :
      if varis-petrol     and
         not varis-pieces then do:
        find first bf-del_doc-pl where bf-del_doc-pl.obj-type  = bf-del_doc-line.obj-type and
                                       bf-del_doc-pl.obj-code  = bf-del_doc-line.obj-code and
                                       bf-del_doc-pl.pl-code   = bf-del_parts.pl-code     and
                                       bf-del_doc-pl.out-code  = bf-del_doc-line.doc-code and
                                       bf-del_doc-pl.gds-code  = bf-del_goods.gds-code    exclusive-lock.
        assign
          vardensity-doc-pl = bf-del_doc-pl.cli-fact-qnty / bf-del_doc-pl.fact-qnty.
      end.
      assign
        varmem-qnty = - bf-del_parts.fact-qnty
        varchg-qnty = varmem-qnty.
      find first bf-del_gds-dtl where bf-del_gds-dtl.doc-code  = bf_trn-doc.doc-code    and
                                      bf-del_gds-dtl.artic     = bf-del_parts.artic     and
                                      bf-del_gds-dtl.prod-type = bf-del_parts.prod-type and
                                      bf-del_gds-dtl.prod-code = bf-del_parts.prod-code .
      run trg/rsrv-dtl.p (input parparentproc,
                      'reserv':U + ',' + 'negative-check':U + "=2"
                      + "," + 'rsrv-single-part':U
                      + "," + 'rsrv-in-code':U   + "=" + str-encode(bf-del_parts.in-code,   "":u, ",=":u)
                      + "," + 'rsrv-part-code':U + "=" + str-encode(bf-del_parts.part-code, "":u, ",=":u)
                      ,
                      buffer bf-del_gds-dtl,
                      input-output varchg-qnty,
                      input-output bf-del_doc-line.price-base,
                      input-output bf-del_doc-line.price-rubl,
                      -1, "") no-error.
      if error-status:error then do:
        undo, return error substitute ("Ошибка при снятии резервировов по списанному товару &1 &2 &3 &4: &5.", bf-del_goods.artic, bf-del_goods.prod-type, bf-del_goods.prod-code, bf-del_goods.gds-name, return-value).
      end.
      if varmem-qnty <> varchg-qnty then do:
        undo, return error substitute("Не все резервы были сняты по списанному товару: &1 &2 &3 &4. Количество для снятия резерва: &5. Снято резервов: &6.", bf-del_goods.artic, bf-del_goods.prod-type, bf-del_goods.prod-code, bf-del_goods.gds-name, varmem-qnty, varchg-qnty).
      end.
      assign
        varrsrv-qnty               = varrsrv-qnty              + varchg-qnty
        bf-del_doc-line.fact-qnty  = bf-del_doc-line.fact-qnty + varchg-qnty
      .
      if varis-petrol     and
         not varis-pieces then do:
        assign
          bf-del_doc-pl.doc-qnty      = bf-del_doc-pl.doc-qnty + varchg-qnty
          bf-del_doc-pl.fact-qnty     = bf-del_doc-pl.doc-qnty
          bf-del_doc-pl.cli-qnty      = bf-del_doc-pl.doc-qnty * vardensity-doc-pl
          bf-del_doc-pl.cli-doc-qnty  = bf-del_doc-pl.cli-qnty
          bf-del_doc-pl.cli-fact-qnty = bf-del_doc-pl.cli-doc-qnty
        .
        assign
          bf-del_doc-line.cli-qnty = bf-del_doc-line.cli-qnty + varchg-qnty * vardensity-doc-pl.
      end.
      find first tt-recalc-line where tt-recalc-line.doc-code  = bf-del_doc-line.doc-code  and
                                      tt-recalc-line.artic     = bf-del_doc-line.artic     and
                                      tt-recalc-line.prod-type = bf-del_doc-line.prod-type and
                                      tt-recalc-line.prod-code = bf-del_doc-line.prod-code no-error.
      if not available tt-recalc-line then do:
        create tt-recalc-line.
        buffer-copy bf-del_doc-line to tt-recalc-line.
      end.
    end.
    find first bf-del-check_parts where bf-del-check_parts.out-code  = bf-del_doc-line.doc-code  and
                                        bf-del-check_parts.obj-type  = bf-del_doc-line.obj-type  and
                                        bf-del-check_parts.obj-code  = bf-del_doc-line.obj-code  and
                                        bf-del-check_parts.artic     = bf-del_doc-line.artic     and
                                        bf-del-check_parts.prod-type = bf-del_doc-line.prod-type and
                                        bf-del-check_parts.prod-code = bf-del_doc-line.prod-code no-error.
    run rsrv-gds-dtl in this-procedure (input bf-del_doc-line.doc-code,
                                        input bf-del_doc-line.artic,
                                        input bf-del_doc-line.prod-type,
                                        input bf-del_doc-line.prod-code,
                                        input (if available bf-del-check_parts then yes else no),
                                        input varrsrv-qnty) no-error.
    if error-status:error then do:
      return error return-value.
    end.
    if bf-del_doc-line.fact-qnty = 0    and
       not available bf-del-check_parts then do:
      run local-recalc in this-procedure (input "delete":u,
                                          input recid(bf-del_doc-line),
                                          input yes) no-error.
      if error-status:error then do:
        undo, return error substitute ("Ошибка при пересчете строки документа. Списываемый товар: &1 &2 &3.", bf-del_doc-line.artic, bf-del_doc-line.prod-type, bf-del_doc-line.prod-code).
      end.
      run local-line-delete in this-procedure (input recid(bf-del_doc-line)) no-error.
      if error-status:error then do:
        undo, return error substitute ("Ошибка при удалении строки документа. Списываемый товар: &1 &2 &3.", bf-del_doc-line.artic, bf-del_doc-line.prod-type, bf-del_doc-line.prod-code).
      end.
    end.
    else do:
      run local-recalc in this-procedure (input "update":u,
                                          input recid(bf-del_doc-line),
                                          input yes) no-error.
      if error-status:error then do:
        undo, return error substitute ("Ошибка при пересчете строки документа по списанным товарам: &1", return-value).
      end.
     find first bf-del_gds-dtl where bf-del_gds-dtl.doc-code  = bf-del_doc-line.doc-code  and
                                     bf-del_gds-dtl.artic     = bf-del_doc-line.artic     and
                                     bf-del_gds-dtl.prod-type = bf-del_doc-line.prod-type and
                                     bf-del_gds-dtl.prod-code = bf-del_doc-line.prod-code and
                                     bf-del_gds-dtl.doc-qnty <> 0                              no-error.
     if available bf-del_gds-dtl then do:
       for each bf-del_gds-dtl where bf-del_gds-dtl.doc-code  = bf-del-plus_doc-line.doc-code  and
                                     bf-del_gds-dtl.artic     = bf-del-plus_doc-line.artic     and
                                     bf-del_gds-dtl.prod-type = bf-del-plus_doc-line.prod-type and
                                     bf-del_gds-dtl.prod-code = bf-del-plus_doc-line.prod-code and
                                     bf-del_gds-dtl.doc-qnty  = 0                              on error undo, return error return-value :
         delete bf-del_gds-dtl.
        end.
      end.
    end.
    assign
      varrsrv-plus-parts-real = 0.00
      varrsrv-plus-parts      = 0.00.
    for each bf-del_parts-root where bf-del_parts-root.doc-code      = bf_trn-doc.doc-code   and
                                     bf-del_parts-root.orig-gds-code = bf-del_goods.gds-code use-index pi on error undo, return error return-value :
      find first bf-del-plus_goods where bf-del-plus_goods.gds-code = bf-del_parts-root.gds-code no-lock.
      find first bf-del-plus_doc-line where bf-del-plus_doc-line.doc-code  = bf_trn-doc.doc-code         and
                                            bf-del-plus_doc-line.artic     = bf-del-plus_goods.artic     and
                                            bf-del-plus_doc-line.prod-type = bf-del-plus_goods.prod-type and
                                            bf-del-plus_doc-line.prod-code = bf-del-plus_goods.prod-code exclusive-lock.
      run local-recalc in this-procedure (input "old":u,
                                          input recid(bf-del-plus_doc-line),
                                          input no) no-error.
      if error-status:error then do:
        undo, return error substitute ("Ошибка при пересчете строки документа по оприходованным товарам: &1", return-value).
      end.
      find first tt-recalc-line where tt-recalc-line.doc-code  = bf-del-plus_doc-line.doc-code  and
                                      tt-recalc-line.artic     = bf-del-plus_doc-line.artic     and
                                      tt-recalc-line.prod-type = bf-del-plus_doc-line.prod-type and
                                      tt-recalc-line.prod-code = bf-del-plus_doc-line.prod-code no-error.
      if not available tt-recalc-line then do:
        create tt-recalc-line.
        buffer-copy bf-del-plus_doc-line to tt-recalc-line.
      end.
      find first bf-del-plus_parts where bf-del-plus_parts.obj-type  = bf_trn-doc.obj-type         and
                                         bf-del-plus_parts.obj-code  = bf_trn-doc.obj-code         and
                                         bf-del-plus_parts.artic     = bf-del-plus_goods.artic     and
                                         bf-del-plus_parts.prod-type = bf-del-plus_goods.prod-type and
                                         bf-del-plus_parts.prod-code = bf-del-plus_goods.prod-code and
                                         bf-del-plus_parts.in-code   = bf-del_parts-root.in-code   and
                                         bf-del-plus_parts.out-code  = bf-del_parts-root.doc-code  and
                                         bf-del-plus_parts.part-code = bf-del_parts-root.part-code exclusive-lock.
      assign
        varrsrv-plus-parts-real = varrsrv-plus-parts-real + bf-del-plus_parts.real-qnty.
      assign
        varrsrv-plus-qnty = bf-del-plus_parts.fact-qnty.
      assign
        bf-del-plus_doc-line.fact-qnty  = bf-del-plus_doc-line.fact-qnty - bf-del-plus_parts.fact-qnty.
      if varis-petrol-plus and
         not varis-pieces  then do:
        find first bf-del-plus_doc-pl where bf-del-plus_doc-pl.obj-type  = bf-del-plus_doc-line.obj-type and
                                            bf-del-plus_doc-pl.obj-code  = bf-del-plus_doc-line.obj-code and
                                            bf-del-plus_doc-pl.pl-code   = bf-del-plus_parts.pl-code     and
                                            bf-del-plus_doc-pl.out-code  = bf-del-plus_doc-line.doc-code and
                                            bf-del-plus_doc-pl.gds-code  = bf-del-plus_goods.gds-code    exclusive-lock.
        assign
          vardensity-doc-pl = bf-del-plus_doc-pl.cli-fact-qnty / bf-del-plus_doc-pl.fact-qnty.
        assign
          bf-del-plus_doc-pl.doc-qnty      = bf-del-plus_doc-pl.doc-qnty - bf-del-plus_parts.fact-qnty
          bf-del-plus_doc-pl.fact-qnty     = bf-del-plus_doc-pl.doc-qnty
          bf-del-plus_doc-pl.cli-qnty      = bf-del-plus_doc-pl.doc-qnty * vardensity-doc-pl
          bf-del-plus_doc-pl.cli-doc-qnty  = bf-del-plus_doc-pl.cli-qnty
          bf-del-plus_doc-pl.cli-fact-qnty = bf-del-plus_doc-pl.cli-qnty
          bf-del-plus_doc-line.cli-qnty    = bf-del-plus_doc-line.cli-qnty - bf-del-plus_parts.fact-qnty * vardensity-doc-pl.
      end.
      delete bf-del-plus_parts.
      delete bf-del_parts-root.
     find first bf-del-check-plus_parts where bf-del-check-plus_parts.out-code  = bf-del-plus_doc-line.doc-code  and
                                              bf-del-check-plus_parts.obj-type  = bf-del-plus_doc-line.obj-type  and
                                              bf-del-check-plus_parts.obj-code  = bf-del-plus_doc-line.obj-code  and
                                              bf-del-check-plus_parts.artic     = bf-del-plus_doc-line.artic     and
                                              bf-del-check-plus_parts.prod-type = bf-del-plus_doc-line.prod-type and
                                              bf-del-check-plus_parts.prod-code = bf-del-plus_doc-line.prod-code no-error.
      run rsrv-gds-dtl-plus in this-procedure (input bf-del-plus_doc-line.doc-code,
                                               input bf-del-plus_doc-line.artic,
                                               input bf-del-plus_doc-line.prod-type,
                                               input bf-del-plus_doc-line.prod-code,
                                               input available bf-del-check-plus_parts,
                                               input varrsrv-plus-qnty) no-error.
      if error-status:error then do:
        return error return-value.
      end.
    end.
    if varrsrv-plus-parts-real <> varrsrv-qnty then do:
      undo, return error substitute ("Ошибка при резервировании. Списываемый товар &1 &2 &3. Количество &4. Количество по оприходованным товарам &5.", bf-del_goods.artic, bf-del_goods.prod-type, bf-del_goods.prod-code, varrsrv-qnty, varrsrv-plus-parts-real).
    end.
  end.
end.
else do:
  find first bf-del_doc-line      where recid(bf-del_doc-line)      = varrecdoc-line      exclusive-lock.
  find first bf-del_goods         where bf-del_goods.artic          = bf-del_doc-line.artic     and
                                        bf-del_goods.prod-type      = bf-del_doc-line.prod-type and
                                        bf-del_goods.prod-code      = bf-del_doc-line.prod-code no-lock.
  find first bf-del-plus_doc-line where recid(bf-del-plus_doc-line) = varrecdoc-line-plus exclusive-lock.
  find first bf-del-plus_goods    where bf-del-plus_goods.artic     = bf-del-plus_doc-line.artic     and
                                        bf-del-plus_goods.prod-type = bf-del-plus_doc-line.prod-type and
                                        bf-del-plus_goods.prod-code = bf-del-plus_doc-line.prod-code no-lock.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_is-petrl in g#lib-trn
  (
     input bf-del_goods.artic
  ,  input bf-del_goods.prod-type
  ,  input bf-del_goods.prod-code
  , output varis-petrol
  , output varis-pieces
  ) no-error.
  if error-status:error then do:
    undo, return error substitute ("Ошибка при определении топлива: &1.", return-value).
  end.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_is-petrl in g#lib-trn
  (
     input bf-del-plus_goods.artic
  ,  input bf-del-plus_goods.prod-type
  ,  input bf-del-plus_goods.prod-code
  , output varis-petrol-plus
  , output varis-pieces-plus
  ) no-error.
  if error-status:error then do:
    undo, return error substitute ("Ошибка при определении топлива: &1.", return-value).
  end.
  for each bf-del_parts-root where bf-del_parts-root.doc-code      = bf_trn-doc.doc-code        and
                                   bf-del_parts-root.orig-gds-code = bf-del_goods.gds-code      and
                                   bf-del_parts-root.gds-code      = bf-del-plus_goods.gds-code use-index pi exclusive-lock on error undo, return error return-value :
    run local-recalc in this-procedure (input "old":u,
                                        input recid(bf-del_doc-line),
                                        input yes) no-error.
    if error-status:error then do:
      undo, return error substitute ("Ошибка при пересчете строки документа: &1.", return-value).
    end.
    find first tt-recalc-line where tt-recalc-line.doc-code  = bf-del_doc-line.doc-code  and
                                    tt-recalc-line.artic     = bf-del_doc-line.artic     and
                                    tt-recalc-line.prod-type = bf-del_doc-line.prod-type and
                                    tt-recalc-line.prod-code = bf-del_doc-line.prod-code no-error.
    if not available tt-recalc-line then do:
      create tt-recalc-line.
      buffer-copy bf-del_doc-line to tt-recalc-line.
    end.
    find first tt-recalc-line where tt-recalc-line.doc-code  = bf-del-plus_doc-line.doc-code  and
                                    tt-recalc-line.artic     = bf-del-plus_doc-line.artic     and
                                    tt-recalc-line.prod-type = bf-del-plus_doc-line.prod-type and
                                    tt-recalc-line.prod-code = bf-del-plus_doc-line.prod-code no-error.
    if not available tt-recalc-line then do:
      create tt-recalc-line.
      buffer-copy bf-del-plus_doc-line to tt-recalc-line.
    end.
    find first bf-del_parts where bf-del_parts.obj-type  = bf_trn-doc.obj-type              and
                                  bf-del_parts.obj-code  = bf_trn-doc.obj-code              and
                                  bf-del_parts.artic     = bf-del_goods.artic               and
                                  bf-del_parts.prod-type = bf-del_goods.prod-type           and
                                  bf-del_parts.prod-code = bf-del_goods.prod-code           and
                                  bf-del_parts.in-code   = bf-del_parts-root.orig-in-code   and
                                  bf-del_parts.out-code  = bf_trn-doc.doc-code              and
                                  bf-del_parts.part-code = bf-del_parts-root.orig-part-code exclusive-lock.
    find first bf-del_gds-dtl where bf-del_gds-dtl.doc-code  = bf-del_doc-line.doc-code  and
                                    bf-del_gds-dtl.artic     = bf-del_doc-line.artic     and
                                    bf-del_gds-dtl.prod-type = bf-del_doc-line.prod-type and
                                    bf-del_gds-dtl.prod-code = bf-del_doc-line.prod-code.
    find first bf-del-plus_parts where bf-del-plus_parts.obj-type  = bf_trn-doc.obj-type         and
                                       bf-del-plus_parts.obj-code  = bf_trn-doc.obj-code         and
                                       bf-del-plus_parts.artic     = bf-del-plus_goods.artic     and
                                       bf-del-plus_parts.prod-type = bf-del-plus_goods.prod-type and
                                       bf-del-plus_parts.prod-code = bf-del-plus_goods.prod-code and
                                       bf-del-plus_parts.in-code   = bf-del_parts-root.in-code   and
                                       bf-del-plus_parts.out-code  = bf_trn-doc.doc-code         and
                                       bf-del-plus_parts.part-code = bf-del_parts-root.part-code exclusive-lock.
    assign
      varmem-qnty = bf-del-plus_parts.real-qnty
      varchg-qnty = varmem-qnty.
     if varis-petrol     and
        not varis-pieces then do:
       find first bf-del_doc-pl where bf-del_doc-pl.obj-type  = bf-del_doc-line.obj-type and
                                      bf-del_doc-pl.obj-code  = bf-del_doc-line.obj-code and
                                      bf-del_doc-pl.pl-code   = bf-del_parts.pl-code     and
                                      bf-del_doc-pl.out-code  = bf-del_doc-line.doc-code and
                                      bf-del_doc-pl.gds-code  = bf-del_goods.gds-code    exclusive-lock.
        assign
          vardensity-doc-pl = bf-del_doc-pl.cli-fact-qnty / bf-del_doc-pl.fact-qnty.
     end.
     run trg/rsrv-dtl.p (input parparentproc,
                     'reserv':U
                     + ',' + 'negative-check':U + "=2"
                     + "," + 'rsrv-single-part':U
                     + "," + 'rsrv-in-code':U   + "=" + str-encode(bf-del_parts.in-code,   "":u, ",=":u)
                     + "," + 'rsrv-part-code':U + "=" + str-encode(bf-del_parts.part-code, "":u, ",=":u)
                     ,
                     buffer bf-del_gds-dtl,
                     input-output varchg-qnty,
                     input-output bf-del_doc-line.price-base,
                     input-output bf-del_doc-line.price-rubl,
                     -1, "") no-error.
     if error-status:error then do:
       undo, return error substitute ("Ошибка при снятии резервировов по списанному товару &1 &2 &3 &4: &5.", bf-del_goods.artic, bf-del_goods.prod-type, bf-del_goods.prod-code, bf-del_goods.gds-name, return-value).
     end.
     if varmem-qnty <> varchg-qnty then do:
       undo, return error substitute("Не все резервы были сняты по списанному товару: &1 &2 &3 &4. Количество для снятия резерва: &5. Снято резервов: &6.", bf-del_goods.artic, bf-del_goods.prod-type, bf-del_goods.prod-code, bf-del_goods.gds-name, varmem-qnty, varchg-qnty).
     end.
     assign
       bf-del_doc-line.fact-qnty  = bf-del_doc-line.fact-qnty + varchg-qnty
     .
     if varis-petrol     and
       not varis-pieces then do:
       assign
         bf-del_doc-pl.doc-qnty      = bf-del_doc-pl.doc-qnty + varchg-qnty
         bf-del_doc-pl.fact-qnty     = bf-del_doc-pl.doc-qnty
         bf-del_doc-pl.cli-qnty      = bf-del_doc-pl.doc-qnty * vardensity-doc-pl
         bf-del_doc-pl.cli-doc-qnty  = bf-del_doc-pl.cli-qnty
         bf-del_doc-pl.cli-fact-qnty = bf-del_doc-pl.cli-doc-qnty
       .
       assign
         bf-del_doc-line.cli-qnty = bf-del_doc-line.cli-qnty + varchg-qnty * vardensity-doc-pl.
     end.
     find first bf-del-check_parts where bf-del-check_parts.out-code  = bf-del_doc-line.doc-code  and
                                         bf-del-check_parts.obj-type  = bf-del_doc-line.obj-type  and
                                         bf-del-check_parts.obj-code  = bf-del_doc-line.obj-code  and
                                         bf-del-check_parts.artic     = bf-del_doc-line.artic     and
                                         bf-del-check_parts.prod-type = bf-del_doc-line.prod-type and
                                         bf-del-check_parts.prod-code = bf-del_doc-line.prod-code no-error.
     run rsrv-gds-dtl in this-procedure (input bf-del_doc-line.doc-code,
                                         input bf-del_doc-line.artic,
                                         input bf-del_doc-line.prod-type,
                                         input bf-del_doc-line.prod-code,
                                         input available bf-del-check_parts,
                                         input varchg-qnty) no-error.
     if error-status:error then do:
       return error return-value.
     end.
     if bf-del_doc-line.fact-qnty = 0    and
        not available bf-del-check_parts then do:
       run local-recalc in this-procedure (input "delete":u,
                                           input recid(bf-del_doc-line),
                                           input yes) no-error.
       if error-status:error then do:
         undo, return error substitute ("Ошибка при пересчете строки документа. Списываемый товар: &1 &2 &3.", bf-del_doc-line.artic, bf-del_doc-line.prod-type, bf-del_doc-line.prod-code).
       end.
       run local-line-delete in this-procedure (input recid(bf-del_doc-line)) no-error.
       if error-status:error then do:
         undo, return error substitute ("Ошибка при удалении строки документа. Списываемый товар: &1 &2 &3.", bf-del_doc-line.artic, bf-del_doc-line.prod-type, bf-del_doc-line.prod-code).
       end.
     end.
     else do:
       run local-recalc in this-procedure (input "update":u,
                                           input recid(bf-del_doc-line),
                                           input yes) no-error.
       if error-status:error then do:
         undo, return error substitute ("Ошибка при пересчете строки документа по списанным товарам: &1", return-value).
       end.
       run proc-get-write-off (buffer bf-del_doc-line).
      find first bf-del_gds-dtl where bf-del_gds-dtl.doc-code  = bf-del_doc-line.doc-code  and
                                      bf-del_gds-dtl.artic     = bf-del_doc-line.artic     and
                                      bf-del_gds-dtl.prod-type = bf-del_doc-line.prod-type and
                                      bf-del_gds-dtl.prod-code = bf-del_doc-line.prod-code and
                                      bf-del_gds-dtl.doc-qnty <> 0                              no-error.
      if available bf-del_gds-dtl then do:
        for each bf-del_gds-dtl where bf-del_gds-dtl.doc-code  = bf-del-plus_doc-line.doc-code  and
                                      bf-del_gds-dtl.artic     = bf-del-plus_doc-line.artic     and
                                      bf-del_gds-dtl.prod-type = bf-del-plus_doc-line.prod-type and
                                      bf-del_gds-dtl.prod-code = bf-del-plus_doc-line.prod-code and
                                      bf-del_gds-dtl.doc-qnty  = 0                              on error undo, return error return-value :
          delete bf-del_gds-dtl.
        end.
      end.
    end.
    if varis-petrol-plus and
      not varis-pieces  then do:
      find first bf-del-plus_doc-pl where bf-del-plus_doc-pl.obj-type  = bf-del-plus_doc-line.obj-type and
                                          bf-del-plus_doc-pl.obj-code  = bf-del-plus_doc-line.obj-code and
                                          bf-del-plus_doc-pl.pl-code   = bf-del-plus_parts.pl-code     and
                                          bf-del-plus_doc-pl.out-code  = bf-del-plus_doc-line.doc-code and
                                          bf-del-plus_doc-pl.gds-code  = bf-del-plus_goods.gds-code    exclusive-lock.
      assign
        vardensity-doc-pl = bf-del-plus_doc-pl.cli-fact-qnty / bf-del-plus_doc-pl.fact-qnty.
      assign
        bf-del-plus_doc-pl.doc-qnty      = bf-del-plus_doc-pl.doc-qnty - bf-del-plus_parts.fact-qnty
        bf-del-plus_doc-pl.fact-qnty     = bf-del-plus_doc-pl.doc-qnty
        bf-del-plus_doc-pl.cli-qnty      = bf-del-plus_doc-pl.doc-qnty * vardensity-doc-pl
        bf-del-plus_doc-pl.cli-doc-qnty  = bf-del-plus_doc-pl.cli-qnty
        bf-del-plus_doc-pl.cli-fact-qnty = bf-del-plus_doc-pl.cli-qnty
        bf-del-plus_doc-line.cli-qnty    = bf-del-plus_doc-line.cli-qnty - bf-del-plus_parts.fact-qnty * vardensity-doc-pl.
    end.
    assign
      bf-del-plus_doc-line.fact-qnty  = bf-del-plus_doc-line.fact-qnty - bf-del-plus_parts.fact-qnty
    .
    assign
      varrsrv-plus-qnty = bf-del-plus_parts.fact-qnty.
    delete bf-del-plus_parts.
    delete bf-del_parts-root.
    find first bf-del-check-plus_parts where bf-del-check-plus_parts.out-code  = bf-del-plus_doc-line.doc-code  and
                                             bf-del-check-plus_parts.obj-type  = bf-del-plus_doc-line.obj-type  and
                                             bf-del-check-plus_parts.obj-code  = bf-del-plus_doc-line.obj-code  and
                                             bf-del-check-plus_parts.artic     = bf-del-plus_doc-line.artic     and
                                             bf-del-check-plus_parts.prod-type = bf-del-plus_doc-line.prod-type and
                                             bf-del-check-plus_parts.prod-code = bf-del-plus_doc-line.prod-code no-error.
    run rsrv-gds-dtl-plus in this-procedure (input bf-del-plus_doc-line.doc-code,
                                             input bf-del-plus_doc-line.artic,
                                             input bf-del-plus_doc-line.prod-type,
                                             input bf-del-plus_doc-line.prod-code,
                                             input available bf-del-check-plus_parts,
                                             input varrsrv-plus-qnty) no-error.
    if error-status:error then do:
      return error return-value.
    end.
  end.
end.
run recalc-line in this-procedure no-error.
if error-status:error then do:
  undo, return error substitute ("Ошибка при пересчете строк документа: ", return-value).
end.
end.
end.
END PROCEDURE.
PROCEDURE local-line-delete :
define input parameter parrec-line as recid no-undo.
define buffer bf_doc-line for ub.doc-line.
DEFINE BUFFER bf_gds-dtl  FOR ub.gds-dtl.
define variable l-inv-on as logical no-undo.
do on error undo, return error return-value :
find first bf_doc-line where recid(bf_doc-line) = parrec-line.
FOR EACH bf_gds-dtl WHERE bf_gds-dtl.doc-code  = bf_doc-line.doc-code  AND
                          bf_gds-dtl.artic     = bf_doc-line.artic     AND
                          bf_gds-dtl.prod-type = bf_doc-line.prod-type AND
                          bf_gds-dtl.prod-code = bf_doc-line.prod-code EXCLUSIVE-LOCK ON ERROR UNDO, RETURN ERROR RETURN-VALUE :
  DELETE bf_gds-dtl.
END.
define variable vss-include-info61 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjat in g#library
  (input  bf_doc-line.obj-type
  ,input  bf_doc-line.obj-code
  ,input  bf_doc-line.artic
  ,input  bf_doc-line.prod-type
  ,input  bf_doc-line.prod-code
  ,input  'inv-on=false'
  ,output l-inv-on
  ) no-error .
if error-status :error then do:
  undo, return error SUBSTITUTE ("Ошибка установки атрибута товара на объекте. Документ &1. Объект &2 &3. Артикул &4 &5 &6. Признак товара в инвентаризации &7.",
                                 bf_doc-line.doc-code, bf_doc-line.obj-type, bf_doc-line.obj-code, bf_doc-line.artic, bf_doc-line.prod-type, bf_doc-line.prod-code, l-inv-on).
end.
find first tt-recalc-line where tt-recalc-line.doc-code  = bf_doc-line.doc-code  and
                                tt-recalc-line.artic     = bf_doc-line.artic     and
                                tt-recalc-line.prod-type = bf_doc-line.prod-type and
                                tt-recalc-line.prod-code = bf_doc-line.prod-code no-error.
if available tt-recalc-line then do:
  delete tt-recalc-line.
end.
delete bf_doc-line.
end.
END PROCEDURE.
PROCEDURE local-psn-chk :
define input parameter parman    as character no-undo.
define input parameter paraction as character no-undo.
DEFINE BUFFER cli-buf FOR ub.clients.
DEFINE VARIABLE ref-list AS CHARACTER NO-UNDO.
DEFINE VARIABLE ref-rec  AS RECID     NO-UNDO.
if parman = "agnt" and paraction = "ret-mouse" then do:
  find cli-buf where cli-buf.obj-code = input frame Dialog-Frame varagnt                                                 and cli-buf.obj-type = 'чел':U no-lock no-error.
  if not available cli-buf or ( NOT can-do( 'чел':U, cli-buf.obj-type ) ) then do:     if input frame Dialog-Frame varagnt <> ""                                      and input frame Dialog-Frame varagnt <> ? THEN DO:                           message "Из справочника клиентов Вы должны выбрать человека.".              END.                                                                                run ref/cli-all.w (  input parparentproc                                                                  ,  input "b-sel"                                                                        ,  input 'чел':U                                                                         ,  input ?                                                                              ,  input ?                                                                              ,  input ref-rec                                                                        ,  input ?                                                                              ,  input ?                                                                              , output ref-list ) .                                                 assign ref-rec = integer (ref-list).                                                find cli-buf where recid (cli-buf) = ref-rec no-lock no-error.                      if not available cli-buf or ( NOT can-do( 'чел':U, cli-buf.obj-type ) ) then do:            find cli-buf where cli-buf.obj-code = input frame Dialog-Frame varagnt                                  and cli-buf.obj-type = 'чел':U no-lock no-error.                     end.                                                                                       end.
  if available cli-buf and can-do('чел':U, cli-buf.obj-type) then do:                                                                                                 disp cli-buf.obj-code @ varagnt cli-buf.obj-name @ varagnt-name with frame Dialog-Frame.                                      assign frame Dialog-Frame varagnt.                                         DO TRANSACTION ON ERROR UNDO, RETURN ERROR RETURN-VALUE :                                        ASSIGN                                         bf_trn-doc.agnt = varagnt.                                      END.                                   end.                                                                                                                       else do:                                                                                                                     disp ? @ varagnt ? @ varagnt-name with frame Dialog-Frame.                                            END.
end.
if parman = "agnt" and paraction = "button" then do:
  find FIRST cli-buf where cli-buf.obj-code = input frame Dialog-Frame varagnt                                                       and cli-buf.obj-type = 'чел':U no-lock no-error.                                  assign ref-rec = ( if available cli-buf then recid( cli-buf ) else ? ).                                                 release cli-buf.
  if not available cli-buf or ( NOT can-do( 'чел':U, cli-buf.obj-type ) ) then do:     if input frame Dialog-Frame varagnt <> ""                                      and input frame Dialog-Frame varagnt <> ? THEN DO:                           message "Из справочника клиентов Вы должны выбрать человека.".              END.                                                                                run ref/cli-all.w (  input parparentproc                                                                  ,  input "b-sel"                                                                        ,  input 'чел':U                                                                         ,  input ?                                                                              ,  input ?                                                                              ,  input ref-rec                                                                        ,  input ?                                                                              ,  input ?                                                                              , output ref-list ) .                                                 assign ref-rec = integer (ref-list).                                                find cli-buf where recid (cli-buf) = ref-rec no-lock no-error.                      if not available cli-buf or ( NOT can-do( 'чел':U, cli-buf.obj-type ) ) then do:            find cli-buf where cli-buf.obj-code = input frame Dialog-Frame varagnt                                  and cli-buf.obj-type = 'чел':U no-lock no-error.                     end.                                                                                       end.
  if available cli-buf and can-do('чел':U, cli-buf.obj-type) then do:                                                                                                 disp cli-buf.obj-code @ varagnt cli-buf.obj-name @ varagnt-name with frame Dialog-Frame.                                      assign frame Dialog-Frame varagnt.                                         DO TRANSACTION ON ERROR UNDO, RETURN ERROR RETURN-VALUE :                                        ASSIGN                                         bf_trn-doc.agnt = varagnt.                                      END.                                   end.                                                                                                                       else do:                                                                                                                     disp ? @ varagnt ? @ varagnt-name with frame Dialog-Frame.                                            END.
end.
if parman = "agnt" and paraction = "leave" then do:
  find cli-buf where cli-buf.obj-code = input frame Dialog-Frame varagnt                                                 and cli-buf.obj-type = 'чел':U no-lock no-error.
  if available cli-buf and can-do('чел':U, cli-buf.obj-type) then do:                                                                                                 disp cli-buf.obj-code @ varagnt cli-buf.obj-name @ varagnt-name with frame Dialog-Frame.                                      assign frame Dialog-Frame varagnt.                                         DO TRANSACTION ON ERROR UNDO, RETURN ERROR RETURN-VALUE :                                        ASSIGN                                         bf_trn-doc.agnt = varagnt.                                      END.                                   end.                                                                                                                       else do:                                                                                                                     disp ? @ varagnt ? @ varagnt-name with frame Dialog-Frame.                                            END.
end.
if parman = "boss" and paraction = "ret-mouse" then do:
  find cli-buf where cli-buf.obj-code = input frame Dialog-Frame varboss                                                 and cli-buf.obj-type = 'чел':U no-lock no-error.
  if not available cli-buf or ( NOT can-do( 'чел':U, cli-buf.obj-type ) ) then do:     if input frame Dialog-Frame varboss <> ""                                      and input frame Dialog-Frame varboss <> ? THEN DO:                           message "Из справочника клиентов Вы должны выбрать человека.".              END.                                                                                run ref/cli-all.w (  input parparentproc                                                                  ,  input "b-sel"                                                                        ,  input 'чел':U                                                                         ,  input ?                                                                              ,  input ?                                                                              ,  input ref-rec                                                                        ,  input ?                                                                              ,  input ?                                                                              , output ref-list ) .                                                 assign ref-rec = integer (ref-list).                                                find cli-buf where recid (cli-buf) = ref-rec no-lock no-error.                      if not available cli-buf or ( NOT can-do( 'чел':U, cli-buf.obj-type ) ) then do:            find cli-buf where cli-buf.obj-code = input frame Dialog-Frame varboss                                  and cli-buf.obj-type = 'чел':U no-lock no-error.                     end.                                                                                       end.
  if available cli-buf and can-do('чел':U, cli-buf.obj-type) then do:                                                                                                 disp cli-buf.obj-code @ varboss cli-buf.obj-name @ varboss-name with frame Dialog-Frame.                                      assign frame Dialog-Frame varboss.                                         DO TRANSACTION ON ERROR UNDO, RETURN ERROR RETURN-VALUE :                                        ASSIGN                                         bf_trn-doc.boss = varboss.                                      END.                                   end.                                                                                                                       else do:                                                                                                                     disp ? @ varboss ? @ varboss-name with frame Dialog-Frame.                                            END.
end.
if parman = "boss" and paraction = "button" then do:
  find FIRST cli-buf where cli-buf.obj-code = input frame Dialog-Frame varboss                                                       and cli-buf.obj-type = 'чел':U no-lock no-error.                                  assign ref-rec = ( if available cli-buf then recid( cli-buf ) else ? ).                                                 release cli-buf.
  if not available cli-buf or ( NOT can-do( 'чел':U, cli-buf.obj-type ) ) then do:     if input frame Dialog-Frame varboss <> ""                                      and input frame Dialog-Frame varboss <> ? THEN DO:                           message "Из справочника клиентов Вы должны выбрать человека.".              END.                                                                                run ref/cli-all.w (  input parparentproc                                                                  ,  input "b-sel"                                                                        ,  input 'чел':U                                                                         ,  input ?                                                                              ,  input ?                                                                              ,  input ref-rec                                                                        ,  input ?                                                                              ,  input ?                                                                              , output ref-list ) .                                                 assign ref-rec = integer (ref-list).                                                find cli-buf where recid (cli-buf) = ref-rec no-lock no-error.                      if not available cli-buf or ( NOT can-do( 'чел':U, cli-buf.obj-type ) ) then do:            find cli-buf where cli-buf.obj-code = input frame Dialog-Frame varboss                                  and cli-buf.obj-type = 'чел':U no-lock no-error.                     end.                                                                                       end.
  if available cli-buf and can-do('чел':U, cli-buf.obj-type) then do:                                                                                                 disp cli-buf.obj-code @ varboss cli-buf.obj-name @ varboss-name with frame Dialog-Frame.                                      assign frame Dialog-Frame varboss.                                         DO TRANSACTION ON ERROR UNDO, RETURN ERROR RETURN-VALUE :                                        ASSIGN                                         bf_trn-doc.boss = varboss.                                      END.                                   end.                                                                                                                       else do:                                                                                                                     disp ? @ varboss ? @ varboss-name with frame Dialog-Frame.                                            END.
end.
if parman = "boss" and paraction = "leave" then do:
  find cli-buf where cli-buf.obj-code = input frame Dialog-Frame varboss                                                 and cli-buf.obj-type = 'чел':U no-lock no-error.
  if available cli-buf and can-do('чел':U, cli-buf.obj-type) then do:                                                                                                 disp cli-buf.obj-code @ varboss cli-buf.obj-name @ varboss-name with frame Dialog-Frame.                                      assign frame Dialog-Frame varboss.                                         DO TRANSACTION ON ERROR UNDO, RETURN ERROR RETURN-VALUE :                                        ASSIGN                                         bf_trn-doc.boss = varboss.                                      END.                                   end.                                                                                                                       else do:                                                                                                                     disp ? @ varboss ? @ varboss-name with frame Dialog-Frame.                                            END.
end.
if parman = "wrkr" and paraction = "ret-mouse" then do:
  find cli-buf where cli-buf.obj-code = input frame Dialog-Frame varwrkr                                                 and cli-buf.obj-type = 'чел':U no-lock no-error.
  if not available cli-buf or ( NOT can-do( 'чел':U, cli-buf.obj-type ) ) then do:     if input frame Dialog-Frame varwrkr <> ""                                      and input frame Dialog-Frame varwrkr <> ? THEN DO:                           message "Из справочника клиентов Вы должны выбрать человека.".              END.                                                                                run ref/cli-all.w (  input parparentproc                                                                  ,  input "b-sel"                                                                        ,  input 'чел':U                                                                         ,  input ?                                                                              ,  input ?                                                                              ,  input ref-rec                                                                        ,  input ?                                                                              ,  input ?                                                                              , output ref-list ) .                                                 assign ref-rec = integer (ref-list).                                                find cli-buf where recid (cli-buf) = ref-rec no-lock no-error.                      if not available cli-buf or ( NOT can-do( 'чел':U, cli-buf.obj-type ) ) then do:            find cli-buf where cli-buf.obj-code = input frame Dialog-Frame varwrkr                                  and cli-buf.obj-type = 'чел':U no-lock no-error.                     end.                                                                                       end.
  if available cli-buf and can-do('чел':U, cli-buf.obj-type) then do:                                                                                                 disp cli-buf.obj-code @ varwrkr cli-buf.obj-name @ varwrkr-name with frame Dialog-Frame.                                      assign frame Dialog-Frame varwrkr.                                         DO TRANSACTION ON ERROR UNDO, RETURN ERROR RETURN-VALUE :                                        ASSIGN                                         bf_trn-doc.wrkr = varwrkr.                                      END.                                   end.                                                                                                                       else do:                                                                                                                     disp ? @ varwrkr ? @ varwrkr-name with frame Dialog-Frame.                                            END.
end.
if parman = "wrkr" and paraction = "button" then do:
  find FIRST cli-buf where cli-buf.obj-code = input frame Dialog-Frame varwrkr                                                       and cli-buf.obj-type = 'чел':U no-lock no-error.                                  assign ref-rec = ( if available cli-buf then recid( cli-buf ) else ? ).                                                 release cli-buf.
  if not available cli-buf or ( NOT can-do( 'чел':U, cli-buf.obj-type ) ) then do:     if input frame Dialog-Frame varwrkr <> ""                                      and input frame Dialog-Frame varwrkr <> ? THEN DO:                           message "Из справочника клиентов Вы должны выбрать человека.".              END.                                                                                run ref/cli-all.w (  input parparentproc                                                                  ,  input "b-sel"                                                                        ,  input 'чел':U                                                                         ,  input ?                                                                              ,  input ?                                                                              ,  input ref-rec                                                                        ,  input ?                                                                              ,  input ?                                                                              , output ref-list ) .                                                 assign ref-rec = integer (ref-list).                                                find cli-buf where recid (cli-buf) = ref-rec no-lock no-error.                      if not available cli-buf or ( NOT can-do( 'чел':U, cli-buf.obj-type ) ) then do:            find cli-buf where cli-buf.obj-code = input frame Dialog-Frame varwrkr                                  and cli-buf.obj-type = 'чел':U no-lock no-error.                     end.                                                                                       end.
  if available cli-buf and can-do('чел':U, cli-buf.obj-type) then do:                                                                                                 disp cli-buf.obj-code @ varwrkr cli-buf.obj-name @ varwrkr-name with frame Dialog-Frame.                                      assign frame Dialog-Frame varwrkr.                                         DO TRANSACTION ON ERROR UNDO, RETURN ERROR RETURN-VALUE :                                        ASSIGN                                         bf_trn-doc.wrkr = varwrkr.                                      END.                                   end.                                                                                                                       else do:                                                                                                                     disp ? @ varwrkr ? @ varwrkr-name with frame Dialog-Frame.                                            END.
end.
if parman = "wrkr" and paraction = "leave" then do:
  find cli-buf where cli-buf.obj-code = input frame Dialog-Frame varwrkr                                                 and cli-buf.obj-type = 'чел':U no-lock no-error.
  if available cli-buf and can-do('чел':U, cli-buf.obj-type) then do:                                                                                                 disp cli-buf.obj-code @ varwrkr cli-buf.obj-name @ varwrkr-name with frame Dialog-Frame.                                      assign frame Dialog-Frame varwrkr.                                         DO TRANSACTION ON ERROR UNDO, RETURN ERROR RETURN-VALUE :                                        ASSIGN                                         bf_trn-doc.wrkr = varwrkr.                                      END.                                   end.                                                                                                                       else do:                                                                                                                     disp ? @ varwrkr ? @ varwrkr-name with frame Dialog-Frame.                                            END.
end.
END PROCEDURE.
PROCEDURE local-recalc :
define variable vss-include-info62 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define input parameter parmode     as character          no-undo.
define input parameter parrec-line as recid              no-undo.
define input parameter parhave-exp as logical initial no no-undo.
define variable varvalue                        as   character                             no-undo.
define variable vartype                         as   character                             no-undo.
define buffer bf-rc_doc-line       for ub.doc-line.
define buffer bf-rc_goods          for ub.goods.
define buffer bf-rc_parts          for ub.parts.
define buffer bf-rc-exp_parts      for ub.parts.
define buffer bf-rc-inc_parts      for ub.parts.
define buffer bf-expp_trn-doc-sum  for ub.trn-doc-sum.
define buffer bf-incp_trn-doc-sum  for ub.trn-doc-sum.
define buffer bf-expp_doc-line-sum for ub.doc-line-sum.
define buffer bf-incp_doc-line-sum for ub.doc-line-sum.
do on error undo, return error return-value :
find first bf-rc_doc-line where recid(bf-rc_doc-line) = parrec-line.
find first bf-rc_goods    where bf-rc_goods.artic     = bf-rc_doc-line.artic     and
                                bf-rc_goods.prod-type = bf-rc_doc-line.prod-type and
                                bf-rc_goods.prod-code = bf-rc_doc-line.prod-code no-lock.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn2) <> true) then do:   run str/lib-trn2.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn2) <> true) then do:     message       "Error starting lib-trn2.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn2 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn2 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn2_reclcinv in g#lib-trn2
(
input        parmode,
input        parrec-line,
input        bf_trn-doc.doc-code,
input-output vartot-docold,
input-output vartot-rublold,
input-output vartotal-doc-line_tot-ovold,
input-output vartotal-doc-line_fact-rublold,
input-output vartotal-doc-line_fact-baseold,
input-output vartotal-doc-line_fact-qntyold,
input-output vartotal-doc-line_doc-qntyold,
input-output vartotal-doc-line_cli-qntyold,
input-output vartotal-parts_fact-baseold,
input-output vartotal-parts_fact-rublold,
input-output vartotal-parts_fact-qntyold
) no-error.
if error-status:error then do:
  undo, return error substitute("Ошибка при обсчете линии по товару ", bf-rc_doc-line.artic, bf-rc_doc-line.prod-type, bf-rc_doc-line.prod-code) .
end.
if parmode <> "delete" then do:
  find first bf-expp_doc-line-sum where bf-expp_doc-line-sum.doc-code = bf-rc_doc-line.doc-code
                                    and bf-expp_doc-line-sum.gds-code = bf-rc_goods.gds-code
                                    and bf-expp_doc-line-sum.sum-type = 'exp':U exclusive-lock no-error.
  if not available bf-expp_doc-line-sum and
     parhave-exp = yes              then do:
    create bf-expp_doc-line-sum.
    assign
      bf-expp_doc-line-sum.doc-code     = bf_trn-doc.doc-code
      bf-expp_doc-line-sum.ext-doc-type = bf_trn-doc.ext-doc-type
      bf-expp_doc-line-sum.obj-type     = bf_trn-doc.obj-type
      bf-expp_doc-line-sum.obj-code     = bf_trn-doc.obj-code
      bf-expp_doc-line-sum.gds-code     = bf-rc_goods.gds-code
      bf-expp_doc-line-sum.sum-type     = 'exp':U
    .
  end.
  find first bf-incp_doc-line-sum where bf-incp_doc-line-sum.doc-code = bf-rc_doc-line.doc-code
                                    and bf-incp_doc-line-sum.gds-code = bf-rc_goods.gds-code
                                    and bf-incp_doc-line-sum.sum-type = 'inp':U exclusive-lock no-error.
  if not available bf-incp_doc-line-sum and
     not parhave-exp                        then do:
    create bf-incp_doc-line-sum.
    assign
      bf-incp_doc-line-sum.doc-code     = bf_trn-doc.doc-code
      bf-incp_doc-line-sum.ext-doc-type = bf_trn-doc.ext-doc-type
      bf-incp_doc-line-sum.obj-type     = bf_trn-doc.obj-type
      bf-incp_doc-line-sum.obj-code     = bf_trn-doc.obj-code
      bf-incp_doc-line-sum.gds-code     = bf-rc_goods.gds-code
      bf-incp_doc-line-sum.sum-type     = 'inp':U
    .
  end.
end.
if parmode <> "old":u then do:
  if parmode <> "delete" then do:
    if parhave-exp = yes then do:
      assign
        bf-expp_doc-line-sum.fact-qnty           = 0
        bf-expp_doc-line-sum.cost-sum-base       = 0
        bf-expp_doc-line-sum.cost-sum-rubl       = 0
        bf-expp_doc-line-sum.cost-vat-base       = 0
        bf-expp_doc-line-sum.cost-vat-rubl       = 0
        bf-expp_doc-line-sum.cost-slt-base       = 0
        bf-expp_doc-line-sum.cost-slt-rubl       = 0
        bf-expp_doc-line-sum.cost-road-tax-base  = 0
        bf-expp_doc-line-sum.cost-road-tax-rubl  = 0
        bf-expp_doc-line-sum.cost-excise-base    = 0
        bf-expp_doc-line-sum.cost-excise-rubl    = 0
        bf-expp_doc-line-sum.cost-transport-base = 0
        bf-expp_doc-line-sum.cost-transport-rubl = 0
        bf-expp_doc-line-sum.cost-other-base     = 0
        bf-expp_doc-line-sum.cost-other-rubl     = 0
        bf-expp_doc-line-sum.sale-sum-base       = 0
        bf-expp_doc-line-sum.sale-sum-rubl       = 0
        bf-expp_doc-line-sum.sale-vat-base       = 0
        bf-expp_doc-line-sum.sale-vat-rubl       = 0
        bf-expp_doc-line-sum.sale-slt-base       = 0
        bf-expp_doc-line-sum.sale-slt-rubl       = 0
        bf-expp_doc-line-sum.sale-road-tax-base  = 0
        bf-expp_doc-line-sum.sale-road-tax-rubl  = 0
        bf-expp_doc-line-sum.sale-excise-base    = 0
        bf-expp_doc-line-sum.sale-excise-rubl    = 0
        bf-expp_doc-line-sum.sale-transport-base = 0
        bf-expp_doc-line-sum.sale-transport-rubl = 0
        bf-expp_doc-line-sum.sale-other-base     = 0
        bf-expp_doc-line-sum.sale-other-rubl     = 0
      .
    end.
    else do:
      assign
        bf-incp_doc-line-sum.fact-qnty           = 0
        bf-incp_doc-line-sum.cost-sum-base       = 0
        bf-incp_doc-line-sum.cost-sum-rubl       = 0
        bf-incp_doc-line-sum.cost-vat-base       = 0
        bf-incp_doc-line-sum.cost-vat-rubl       = 0
        bf-incp_doc-line-sum.cost-slt-base       = 0
        bf-incp_doc-line-sum.cost-slt-rubl       = 0
        bf-incp_doc-line-sum.cost-road-tax-base  = 0
        bf-incp_doc-line-sum.cost-road-tax-rubl  = 0
        bf-incp_doc-line-sum.cost-excise-base    = 0
        bf-incp_doc-line-sum.cost-excise-rubl    = 0
        bf-incp_doc-line-sum.cost-transport-base = 0
        bf-incp_doc-line-sum.cost-transport-rubl = 0
        bf-incp_doc-line-sum.cost-other-base     = 0
        bf-incp_doc-line-sum.cost-other-rubl     = 0
        bf-incp_doc-line-sum.sale-sum-base       = 0
        bf-incp_doc-line-sum.sale-sum-rubl       = 0
        bf-incp_doc-line-sum.sale-vat-base       = 0
        bf-incp_doc-line-sum.sale-vat-rubl       = 0
        bf-incp_doc-line-sum.sale-slt-base       = 0
        bf-incp_doc-line-sum.sale-slt-rubl       = 0
        bf-incp_doc-line-sum.sale-road-tax-base  = 0
        bf-incp_doc-line-sum.sale-road-tax-rubl  = 0
        bf-incp_doc-line-sum.sale-excise-base    = 0
        bf-incp_doc-line-sum.sale-excise-rubl    = 0
        bf-incp_doc-line-sum.sale-transport-base = 0
        bf-incp_doc-line-sum.sale-transport-rubl = 0
        bf-incp_doc-line-sum.sale-other-base     = 0
        bf-incp_doc-line-sum.sale-other-rubl     = 0
      .
    end.
    for each bf-rc_parts where bf-rc_parts.out-code  = bf_trn-doc.doc-code   and
                               bf-rc_parts.obj-type  = bf_trn-doc.obj-type   and
                               bf-rc_parts.obj-code  = bf_trn-doc.obj-code   and
                               bf-rc_parts.artic     = bf-rc_goods.artic     and
                               bf-rc_parts.prod-type = bf-rc_goods.prod-type and
                               bf-rc_parts.prod-code = bf-rc_goods.prod-code on error undo, return error return-value :
      for each tt-clcparts :
        delete tt-clcparts.
      end.
      create tt-clcparts.
      buffer-copy bf-rc_parts to tt-clcparts.
      run clcprtsl_calc-parts in this-procedure
         (input recid(tt-clcparts),
          input yes,
          input no,
          input bf-rc_doc-line.road-tax,
          input bf-rc_doc-line.excise,
          input bf-rc_doc-line.VAT-pc,
          input bf-rc_doc-line.cons-vat-pc,
          input bf-rc_doc-line.SLT-pc,
          input bf_trn-doc.base-rate,
          input bf_trn-doc.base-scale,
          input ?,
          input ?,
          input ?,
          input ?,
          input ?,
          input ?,
          input ?
         ).
      find first tt-allsum where tt-allsum.sum-type = 'основная_сумма':U.
      if bf-rc_parts.in-code <> bf-rc_parts.out-code then do:
        if parhave-exp = yes then do:
          assign
            bf-expp_doc-line-sum.fact-qnty           = bf-expp_doc-line-sum.fact-qnty            - tt-allsum.fact-qnty
            bf-expp_doc-line-sum.cost-sum-base       = bf-expp_doc-line-sum.cost-sum-base        - tt-allsum.sum-dsc-base-acc
            bf-expp_doc-line-sum.cost-sum-rubl       = bf-expp_doc-line-sum.cost-sum-rubl        - tt-allsum.sum-dsc-rubl-acc
            bf-expp_doc-line-sum.cost-vat-base       = bf-expp_doc-line-sum.cost-vat-base        - tt-allsum.vat-base-acc
            bf-expp_doc-line-sum.cost-vat-rubl       = bf-expp_doc-line-sum.cost-vat-rubl        - tt-allsum.vat-rubl-acc
            bf-expp_doc-line-sum.cost-slt-base       = bf-expp_doc-line-sum.cost-slt-base        - tt-allsum.slt-base-acc
            bf-expp_doc-line-sum.cost-slt-rubl       = bf-expp_doc-line-sum.cost-slt-rubl        - tt-allsum.slt-rubl-acc
            bf-expp_doc-line-sum.cost-road-tax-base  = bf-expp_doc-line-sum.cost-road-tax-base   - tt-allsum.road-tax-base-acc
            bf-expp_doc-line-sum.cost-road-tax-rubl  = bf-expp_doc-line-sum.cost-road-tax-rubl   - tt-allsum.road-tax-rubl-acc
            bf-expp_doc-line-sum.cost-excise-base    = bf-expp_doc-line-sum.cost-excise-base     - tt-allsum.excise-base-acc
            bf-expp_doc-line-sum.cost-excise-rubl    = bf-expp_doc-line-sum.cost-excise-rubl     - tt-allsum.excise-rubl-acc
            bf-expp_doc-line-sum.cost-transport-base = bf-expp_doc-line-sum.cost-transport-base  - tt-allsum.transport-base-acc
            bf-expp_doc-line-sum.cost-transport-rubl = bf-expp_doc-line-sum.cost-transport-rubl  - tt-allsum.transport-rubl-acc
            bf-expp_doc-line-sum.cost-other-base     = bf-expp_doc-line-sum.cost-other-base      - tt-allsum.other-base-acc
            bf-expp_doc-line-sum.cost-other-rubl     = bf-expp_doc-line-sum.cost-other-rubl      - tt-allsum.other-rubl-acc
            bf-expp_doc-line-sum.sale-sum-base       = bf-expp_doc-line-sum.sale-sum-base        - tt-allsum.sum-dsc-base-doc
            bf-expp_doc-line-sum.sale-sum-rubl       = bf-expp_doc-line-sum.sale-sum-rubl        - tt-allsum.sum-dsc-rubl-doc
            bf-expp_doc-line-sum.sale-vat-base       = bf-expp_doc-line-sum.sale-vat-base        - tt-allsum.vat-base-doc
            bf-expp_doc-line-sum.sale-vat-rubl       = bf-expp_doc-line-sum.sale-vat-rubl        - tt-allsum.vat-rubl-doc
            bf-expp_doc-line-sum.sale-slt-base       = bf-expp_doc-line-sum.sale-slt-base        - tt-allsum.slt-base-doc
            bf-expp_doc-line-sum.sale-slt-rubl       = bf-expp_doc-line-sum.sale-slt-rubl        - tt-allsum.slt-rubl-doc
            bf-expp_doc-line-sum.sale-road-tax-base  = bf-expp_doc-line-sum.sale-road-tax-base   - tt-allsum.road-tax-base-doc
            bf-expp_doc-line-sum.sale-road-tax-rubl  = bf-expp_doc-line-sum.sale-road-tax-rubl   - tt-allsum.road-tax-rubl-doc
            bf-expp_doc-line-sum.sale-excise-base    = bf-expp_doc-line-sum.sale-excise-base     - tt-allsum.excise-base-doc
            bf-expp_doc-line-sum.sale-excise-rubl    = bf-expp_doc-line-sum.sale-excise-rubl     - tt-allsum.excise-rubl-doc
          .
        end.
      end.
      else do:
        if not parhave-exp = yes then do:
          assign
            bf-incp_doc-line-sum.fact-qnty           = bf-incp_doc-line-sum.fact-qnty            + tt-allsum.fact-qnty
            bf-incp_doc-line-sum.cost-sum-base       = bf-incp_doc-line-sum.cost-sum-base        + tt-allsum.sum-dsc-base-acc
            bf-incp_doc-line-sum.cost-sum-rubl       = bf-incp_doc-line-sum.cost-sum-rubl        + tt-allsum.sum-dsc-rubl-acc
            bf-incp_doc-line-sum.cost-vat-base       = bf-incp_doc-line-sum.cost-vat-base        + tt-allsum.vat-base-acc
            bf-incp_doc-line-sum.cost-vat-rubl       = bf-incp_doc-line-sum.cost-vat-rubl        + tt-allsum.vat-rubl-acc
            bf-incp_doc-line-sum.cost-slt-base       = bf-incp_doc-line-sum.cost-slt-base        + tt-allsum.slt-base-acc
            bf-incp_doc-line-sum.cost-slt-rubl       = bf-incp_doc-line-sum.cost-slt-rubl        + tt-allsum.slt-rubl-acc
            bf-incp_doc-line-sum.cost-road-tax-base  = bf-incp_doc-line-sum.cost-road-tax-base   + tt-allsum.road-tax-base-acc
            bf-incp_doc-line-sum.cost-road-tax-rubl  = bf-incp_doc-line-sum.cost-road-tax-rubl   + tt-allsum.road-tax-rubl-acc
            bf-incp_doc-line-sum.cost-excise-base    = bf-incp_doc-line-sum.cost-excise-base     + tt-allsum.excise-base-acc
            bf-incp_doc-line-sum.cost-excise-rubl    = bf-incp_doc-line-sum.cost-excise-rubl     + tt-allsum.excise-rubl-acc
            bf-incp_doc-line-sum.cost-transport-base = bf-incp_doc-line-sum.cost-transport-base  + tt-allsum.transport-base-acc
            bf-incp_doc-line-sum.cost-transport-rubl = bf-incp_doc-line-sum.cost-transport-rubl  + tt-allsum.transport-rubl-acc
            bf-incp_doc-line-sum.cost-other-base     = bf-incp_doc-line-sum.cost-other-base      + tt-allsum.other-base-acc
            bf-incp_doc-line-sum.cost-other-rubl     = bf-incp_doc-line-sum.cost-other-rubl      + tt-allsum.other-rubl-acc
            bf-incp_doc-line-sum.sale-sum-base       = bf-incp_doc-line-sum.sale-sum-base        + tt-allsum.sum-dsc-base-doc
            bf-incp_doc-line-sum.sale-sum-rubl       = bf-incp_doc-line-sum.sale-sum-rubl        + tt-allsum.sum-dsc-rubl-doc
            bf-incp_doc-line-sum.sale-vat-base       = bf-incp_doc-line-sum.sale-vat-base        + tt-allsum.vat-base-doc
            bf-incp_doc-line-sum.sale-vat-rubl       = bf-incp_doc-line-sum.sale-vat-rubl        + tt-allsum.vat-rubl-doc
            bf-incp_doc-line-sum.sale-slt-base       = bf-incp_doc-line-sum.sale-slt-base        + tt-allsum.slt-base-doc
            bf-incp_doc-line-sum.sale-slt-rubl       = bf-incp_doc-line-sum.sale-slt-rubl        + tt-allsum.slt-rubl-doc
            bf-incp_doc-line-sum.sale-road-tax-base  = bf-incp_doc-line-sum.sale-road-tax-base   + tt-allsum.road-tax-base-doc
            bf-incp_doc-line-sum.sale-road-tax-rubl  = bf-incp_doc-line-sum.sale-road-tax-rubl   + tt-allsum.road-tax-rubl-doc
            bf-incp_doc-line-sum.sale-excise-base    = bf-incp_doc-line-sum.sale-excise-base     + tt-allsum.excise-base-doc
            bf-incp_doc-line-sum.sale-excise-rubl    = bf-incp_doc-line-sum.sale-excise-rubl     + tt-allsum.excise-rubl-doc
          .
        end.
      end.
    end.
  end.
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input bf_trn-doc.doc-code ,
                        input 'addsum':U ,
                       output varvalue ,
                       output vartype )  .
  if lookup ('exp':U, varvalue) = 0 then do:
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-wrt in g#trdcalib ( input bf_trn-doc.doc-code ,
                       input 'addsum':U ,
                       input varvalue + min(varvalue, ',') + 'exp':U )  .
  end.
  find first bf-expp_trn-doc-sum where bf-expp_trn-doc-sum.doc-code = bf_trn-doc.doc-code  and
                                       bf-expp_trn-doc-sum.sum-type = 'exp':U exclusive-lock no-error.
  if not available bf-expp_trn-doc-sum then do:
    create bf-expp_trn-doc-sum.
    assign
      bf-expp_trn-doc-sum.doc-code     = bf_trn-doc.doc-code
      bf-expp_trn-doc-sum.ext-doc-type = bf_trn-doc.ext-doc-type
      bf-expp_trn-doc-sum.obj-type     = bf_trn-doc.obj-type
      bf-expp_trn-doc-sum.obj-code     = bf_trn-doc.obj-code
      bf-expp_trn-doc-sum.sum-type     = 'exp':U.
  end.
  if lookup ('inp':U, varvalue) = 0 then do:
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-wrt in g#trdcalib ( input bf_trn-doc.doc-code ,
                       input 'addsum':U ,
                       input varvalue + min(varvalue, ',') + 'inp':U )  .
  end.
  find first bf-incp_trn-doc-sum where bf-incp_trn-doc-sum.doc-code = bf_trn-doc.doc-code and
                                       bf-incp_trn-doc-sum.sum-type = 'inp':U exclusive-lock no-error.
  if not available bf-incp_trn-doc-sum then do:
    create bf-incp_trn-doc-sum.
    assign
      bf-incp_trn-doc-sum.doc-code     = bf_trn-doc.doc-code
      bf-incp_trn-doc-sum.ext-doc-type = bf_trn-doc.ext-doc-type
      bf-incp_trn-doc-sum.obj-type     = bf_trn-doc.obj-type
      bf-incp_trn-doc-sum.obj-code     = bf_trn-doc.obj-code
      bf-incp_trn-doc-sum.sum-type     = 'inp':U.
  end.
  if parhave-exp = yes then do:
    assign
      bf-expp_trn-doc-sum.fact-qnty           = bf-expp_trn-doc-sum.fact-qnty           +  (if parmode <> "delete" then bf-expp_doc-line-sum.fact-qnty           else 0) - varoldfact-qnty-exp
      bf-expp_trn-doc-sum.cost-sum-base       = bf-expp_trn-doc-sum.cost-sum-base       +  (if parmode <> "delete" then bf-expp_doc-line-sum.cost-sum-base       else 0) - varoldcost-sum-base-exp
      bf-expp_trn-doc-sum.cost-sum-rubl       = bf-expp_trn-doc-sum.cost-sum-rubl       +  (if parmode <> "delete" then bf-expp_doc-line-sum.cost-sum-rubl       else 0) - varoldcost-sum-rubl-exp
      bf-expp_trn-doc-sum.cost-vat-base       = bf-expp_trn-doc-sum.cost-vat-base       +  (if parmode <> "delete" then bf-expp_doc-line-sum.cost-vat-base       else 0) - varoldcost-vat-base-exp
      bf-expp_trn-doc-sum.cost-vat-rubl       = bf-expp_trn-doc-sum.cost-vat-rubl       +  (if parmode <> "delete" then bf-expp_doc-line-sum.cost-vat-rubl       else 0) - varoldcost-vat-rubl-exp
      bf-expp_trn-doc-sum.cost-slt-base       = bf-expp_trn-doc-sum.cost-slt-base       +  (if parmode <> "delete" then bf-expp_doc-line-sum.cost-slt-base       else 0) - varoldcost-slt-base-exp
      bf-expp_trn-doc-sum.cost-slt-rubl       = bf-expp_trn-doc-sum.cost-slt-rubl       +  (if parmode <> "delete" then bf-expp_doc-line-sum.cost-slt-rubl       else 0) - varoldcost-slt-rubl-exp
      bf-expp_trn-doc-sum.cost-road-tax-base  = bf-expp_trn-doc-sum.cost-road-tax-base  +  (if parmode <> "delete" then bf-expp_doc-line-sum.cost-road-tax-base  else 0) - varoldcost-road-tax-base-exp
      bf-expp_trn-doc-sum.cost-road-tax-rubl  = bf-expp_trn-doc-sum.cost-road-tax-rubl  +  (if parmode <> "delete" then bf-expp_doc-line-sum.cost-road-tax-rubl  else 0) - varoldcost-road-tax-rubl-exp
      bf-expp_trn-doc-sum.cost-excise-base    = bf-expp_trn-doc-sum.cost-excise-base    +  (if parmode <> "delete" then bf-expp_doc-line-sum.cost-excise-base    else 0) - varoldcost-excise-base-exp
      bf-expp_trn-doc-sum.cost-excise-rubl    = bf-expp_trn-doc-sum.cost-excise-rubl    +  (if parmode <> "delete" then bf-expp_doc-line-sum.cost-excise-rubl    else 0) - varoldcost-excise-rubl-exp
      bf-expp_trn-doc-sum.cost-transport-base = bf-expp_trn-doc-sum.cost-transport-base +  (if parmode <> "delete" then bf-expp_doc-line-sum.cost-transport-base else 0) - varoldcost-transport-base-exp
      bf-expp_trn-doc-sum.cost-transport-rubl = bf-expp_trn-doc-sum.cost-transport-rubl +  (if parmode <> "delete" then bf-expp_doc-line-sum.cost-transport-rubl else 0) - varoldcost-transport-rubl-exp
      bf-expp_trn-doc-sum.cost-other-base     = bf-expp_trn-doc-sum.cost-other-base     +  (if parmode <> "delete" then bf-expp_doc-line-sum.cost-other-base     else 0) - varoldcost-other-base-exp
      bf-expp_trn-doc-sum.cost-other-rubl     = bf-expp_trn-doc-sum.cost-other-rubl     +  (if parmode <> "delete" then bf-expp_doc-line-sum.cost-other-rubl     else 0) - varoldcost-other-rubl-exp
      bf-expp_trn-doc-sum.sale-sum-base       = bf-expp_trn-doc-sum.sale-sum-base       +  (if parmode <> "delete" then bf-expp_doc-line-sum.sale-sum-base       else 0) - varoldsale-sum-base-exp
      bf-expp_trn-doc-sum.sale-sum-rubl       = bf-expp_trn-doc-sum.sale-sum-rubl       +  (if parmode <> "delete" then bf-expp_doc-line-sum.sale-sum-rubl       else 0) - varoldsale-sum-rubl-exp
      bf-expp_trn-doc-sum.sale-vat-base       = bf-expp_trn-doc-sum.sale-vat-base       +  (if parmode <> "delete" then bf-expp_doc-line-sum.sale-vat-base       else 0) - varoldsale-vat-base-exp
      bf-expp_trn-doc-sum.sale-vat-rubl       = bf-expp_trn-doc-sum.sale-vat-rubl       +  (if parmode <> "delete" then bf-expp_doc-line-sum.sale-vat-rubl       else 0) - varoldsale-vat-rubl-exp
      bf-expp_trn-doc-sum.sale-slt-base       = bf-expp_trn-doc-sum.sale-slt-base       +  (if parmode <> "delete" then bf-expp_doc-line-sum.sale-slt-base       else 0) - varoldsale-slt-base-exp
      bf-expp_trn-doc-sum.sale-slt-rubl       = bf-expp_trn-doc-sum.sale-slt-rubl       +  (if parmode <> "delete" then bf-expp_doc-line-sum.sale-slt-rubl       else 0) - varoldsale-slt-rubl-exp
      bf-expp_trn-doc-sum.sale-road-tax-base  = bf-expp_trn-doc-sum.sale-road-tax-base  +  (if parmode <> "delete" then bf-expp_doc-line-sum.sale-road-tax-base  else 0) - varoldsale-road-tax-base-exp
      bf-expp_trn-doc-sum.sale-road-tax-rubl  = bf-expp_trn-doc-sum.sale-road-tax-rubl  +  (if parmode <> "delete" then bf-expp_doc-line-sum.sale-road-tax-rubl  else 0) - varoldsale-road-tax-rubl-exp
      bf-expp_trn-doc-sum.sale-excise-base    = bf-expp_trn-doc-sum.sale-excise-base    +  (if parmode <> "delete" then bf-expp_doc-line-sum.sale-excise-base    else 0) - varoldsale-excise-base-exp
      bf-expp_trn-doc-sum.sale-excise-rubl    = bf-expp_trn-doc-sum.sale-excise-rubl    +  (if parmode <> "delete" then bf-expp_doc-line-sum.sale-excise-rubl    else 0) - varoldsale-excise-rubl-exp
      bf-expp_trn-doc-sum.sale-transport-base = bf-expp_trn-doc-sum.sale-transport-base +  (if parmode <> "delete" then bf-expp_doc-line-sum.sale-transport-base else 0) - varoldsale-transport-base-exp
      bf-expp_trn-doc-sum.sale-transport-rubl = bf-expp_trn-doc-sum.sale-transport-rubl +  (if parmode <> "delete" then bf-expp_doc-line-sum.sale-transport-rubl else 0) - varoldsale-transport-rubl-exp
      bf-expp_trn-doc-sum.sale-other-base     = bf-expp_trn-doc-sum.sale-other-base     +  (if parmode <> "delete" then bf-expp_doc-line-sum.sale-other-base     else 0) - varoldsale-other-base-exp
      bf-expp_trn-doc-sum.sale-other-rubl     = bf-expp_trn-doc-sum.sale-other-rubl     +  (if parmode <> "delete" then bf-expp_doc-line-sum.sale-other-rubl     else 0) - varoldsale-other-rubl-exp
    .
  end.
  else do:
    assign
      bf-incp_trn-doc-sum.fact-qnty           = bf-incp_trn-doc-sum.fact-qnty           +  (if parmode <> "delete" then bf-incp_doc-line-sum.fact-qnty           else 0) - varoldfact-qnty-inp
      bf-incp_trn-doc-sum.cost-sum-base       = bf-incp_trn-doc-sum.cost-sum-base       +  (if parmode <> "delete" then bf-incp_doc-line-sum.cost-sum-base       else 0) - varoldcost-sum-base-inp
      bf-incp_trn-doc-sum.cost-sum-rubl       = bf-incp_trn-doc-sum.cost-sum-rubl       +  (if parmode <> "delete" then bf-incp_doc-line-sum.cost-sum-rubl       else 0) - varoldcost-sum-rubl-inp
      bf-incp_trn-doc-sum.cost-vat-base       = bf-incp_trn-doc-sum.cost-vat-base       +  (if parmode <> "delete" then bf-incp_doc-line-sum.cost-vat-base       else 0) - varoldcost-vat-base-inp
      bf-incp_trn-doc-sum.cost-vat-rubl       = bf-incp_trn-doc-sum.cost-vat-rubl       +  (if parmode <> "delete" then bf-incp_doc-line-sum.cost-vat-rubl       else 0) - varoldcost-vat-rubl-inp
      bf-incp_trn-doc-sum.cost-slt-base       = bf-incp_trn-doc-sum.cost-slt-base       +  (if parmode <> "delete" then bf-incp_doc-line-sum.cost-slt-base       else 0) - varoldcost-slt-base-inp
      bf-incp_trn-doc-sum.cost-slt-rubl       = bf-incp_trn-doc-sum.cost-slt-rubl       +  (if parmode <> "delete" then bf-incp_doc-line-sum.cost-slt-rubl       else 0) - varoldcost-slt-rubl-inp
      bf-incp_trn-doc-sum.cost-road-tax-base  = bf-incp_trn-doc-sum.cost-road-tax-base  +  (if parmode <> "delete" then bf-incp_doc-line-sum.cost-road-tax-base  else 0) - varoldcost-road-tax-base-inp
      bf-incp_trn-doc-sum.cost-road-tax-rubl  = bf-incp_trn-doc-sum.cost-road-tax-rubl  +  (if parmode <> "delete" then bf-incp_doc-line-sum.cost-road-tax-rubl  else 0) - varoldcost-road-tax-rubl-inp
      bf-incp_trn-doc-sum.cost-excise-base    = bf-incp_trn-doc-sum.cost-excise-base    +  (if parmode <> "delete" then bf-incp_doc-line-sum.cost-excise-base    else 0) - varoldcost-excise-base-inp
      bf-incp_trn-doc-sum.cost-excise-rubl    = bf-incp_trn-doc-sum.cost-excise-rubl    +  (if parmode <> "delete" then bf-incp_doc-line-sum.cost-excise-rubl    else 0) - varoldcost-excise-rubl-inp
      bf-incp_trn-doc-sum.cost-transport-base = bf-incp_trn-doc-sum.cost-transport-base +  (if parmode <> "delete" then bf-incp_doc-line-sum.cost-transport-base else 0) - varoldcost-transport-base-inp
      bf-incp_trn-doc-sum.cost-transport-rubl = bf-incp_trn-doc-sum.cost-transport-rubl +  (if parmode <> "delete" then bf-incp_doc-line-sum.cost-transport-rubl else 0) - varoldcost-transport-rubl-inp
      bf-incp_trn-doc-sum.cost-other-base     = bf-incp_trn-doc-sum.cost-other-base     +  (if parmode <> "delete" then bf-incp_doc-line-sum.cost-other-base     else 0) - varoldcost-other-base-inp
      bf-incp_trn-doc-sum.cost-other-rubl     = bf-incp_trn-doc-sum.cost-other-rubl     +  (if parmode <> "delete" then bf-incp_doc-line-sum.cost-other-rubl     else 0) - varoldcost-other-rubl-inp
      bf-incp_trn-doc-sum.sale-sum-base       = bf-incp_trn-doc-sum.sale-sum-base       +  (if parmode <> "delete" then bf-incp_doc-line-sum.sale-sum-base       else 0) - varoldsale-sum-base-inp
      bf-incp_trn-doc-sum.sale-sum-rubl       = bf-incp_trn-doc-sum.sale-sum-rubl       +  (if parmode <> "delete" then bf-incp_doc-line-sum.sale-sum-rubl       else 0) - varoldsale-sum-rubl-inp
      bf-incp_trn-doc-sum.sale-vat-base       = bf-incp_trn-doc-sum.sale-vat-base       +  (if parmode <> "delete" then bf-incp_doc-line-sum.sale-vat-base       else 0) - varoldsale-vat-base-inp
      bf-incp_trn-doc-sum.sale-vat-rubl       = bf-incp_trn-doc-sum.sale-vat-rubl       +  (if parmode <> "delete" then bf-incp_doc-line-sum.sale-vat-rubl       else 0) - varoldsale-vat-rubl-inp
      bf-incp_trn-doc-sum.sale-slt-base       = bf-incp_trn-doc-sum.sale-slt-base       +  (if parmode <> "delete" then bf-incp_doc-line-sum.sale-slt-base       else 0) - varoldsale-slt-base-inp
      bf-incp_trn-doc-sum.sale-slt-rubl       = bf-incp_trn-doc-sum.sale-slt-rubl       +  (if parmode <> "delete" then bf-incp_doc-line-sum.sale-slt-rubl       else 0) - varoldsale-slt-rubl-inp
      bf-incp_trn-doc-sum.sale-road-tax-base  = bf-incp_trn-doc-sum.sale-road-tax-base  +  (if parmode <> "delete" then bf-incp_doc-line-sum.sale-road-tax-base  else 0) - varoldsale-road-tax-base-inp
      bf-incp_trn-doc-sum.sale-road-tax-rubl  = bf-incp_trn-doc-sum.sale-road-tax-rubl  +  (if parmode <> "delete" then bf-incp_doc-line-sum.sale-road-tax-rubl  else 0) - varoldsale-road-tax-rubl-inp
      bf-incp_trn-doc-sum.sale-excise-base    = bf-incp_trn-doc-sum.sale-excise-base    +  (if parmode <> "delete" then bf-incp_doc-line-sum.sale-excise-base    else 0) - varoldsale-excise-base-inp
      bf-incp_trn-doc-sum.sale-excise-rubl    = bf-incp_trn-doc-sum.sale-excise-rubl    +  (if parmode <> "delete" then bf-incp_doc-line-sum.sale-excise-rubl    else 0) - varoldsale-excise-rubl-inp
      bf-incp_trn-doc-sum.sale-transport-base = bf-incp_trn-doc-sum.sale-transport-base +  (if parmode <> "delete" then bf-incp_doc-line-sum.sale-transport-base else 0) - varoldsale-transport-base-inp
      bf-incp_trn-doc-sum.sale-transport-rubl = bf-incp_trn-doc-sum.sale-transport-rubl +  (if parmode <> "delete" then bf-incp_doc-line-sum.sale-transport-rubl else 0) - varoldsale-transport-rubl-inp
      bf-incp_trn-doc-sum.sale-other-base     = bf-incp_trn-doc-sum.sale-other-base     +  (if parmode <> "delete" then bf-incp_doc-line-sum.sale-other-base     else 0) - varoldsale-other-base-inp
      bf-incp_trn-doc-sum.sale-other-rubl     = bf-incp_trn-doc-sum.sale-other-rubl     +  (if parmode <> "delete" then bf-incp_doc-line-sum.sale-other-rubl     else 0) - varoldsale-other-rubl-inp
    .
  end.
end.
else do:
  if parhave-exp then do:
    assign
      varoldfact-qnty-exp            = bf-expp_doc-line-sum.fact-qnty
      varoldcost-sum-base-exp        = bf-expp_doc-line-sum.cost-sum-base
      varoldcost-sum-rubl-exp        = bf-expp_doc-line-sum.cost-sum-rubl
      varoldcost-vat-base-exp        = bf-expp_doc-line-sum.cost-vat-base
      varoldcost-vat-rubl-exp        = bf-expp_doc-line-sum.cost-vat-rubl
      varoldcost-slt-base-exp        = bf-expp_doc-line-sum.cost-slt-base
      varoldcost-slt-rubl-exp        = bf-expp_doc-line-sum.cost-slt-rubl
      varoldcost-road-tax-base-exp   = bf-expp_doc-line-sum.cost-road-tax-base
      varoldcost-road-tax-rubl-exp   = bf-expp_doc-line-sum.cost-road-tax-rubl
      varoldcost-excise-base-exp     = bf-expp_doc-line-sum.cost-excise-base
      varoldcost-excise-rubl-exp     = bf-expp_doc-line-sum.cost-excise-rubl
      varoldcost-transport-base-exp  = bf-expp_doc-line-sum.cost-transport-base
      varoldcost-transport-rubl-exp  = bf-expp_doc-line-sum.cost-transport-rubl
      varoldcost-other-base-exp      = bf-expp_doc-line-sum.cost-other-base
      varoldcost-other-rubl-exp      = bf-expp_doc-line-sum.cost-other-rubl
      varoldsale-sum-base-exp        = bf-expp_doc-line-sum.sale-sum-base
      varoldsale-sum-rubl-exp        = bf-expp_doc-line-sum.sale-sum-rubl
      varoldsale-vat-base-exp        = bf-expp_doc-line-sum.sale-vat-base
      varoldsale-vat-rubl-exp        = bf-expp_doc-line-sum.sale-vat-rubl
      varoldsale-slt-base-exp        = bf-expp_doc-line-sum.sale-slt-base
      varoldsale-slt-rubl-exp        = bf-expp_doc-line-sum.sale-slt-rubl
      varoldsale-road-tax-base-exp   = bf-expp_doc-line-sum.sale-road-tax-base
      varoldsale-road-tax-rubl-exp   = bf-expp_doc-line-sum.sale-road-tax-rubl
      varoldsale-excise-base-exp     = bf-expp_doc-line-sum.sale-excise-base
      varoldsale-excise-rubl-exp     = bf-expp_doc-line-sum.sale-excise-rubl
      varoldsale-transport-base-exp  = bf-expp_doc-line-sum.sale-transport-base
      varoldsale-transport-rubl-exp  = bf-expp_doc-line-sum.sale-transport-rubl
      varoldsale-other-base-exp      = bf-expp_doc-line-sum.sale-other-base
      varoldsale-other-rubl-exp      = bf-expp_doc-line-sum.sale-other-rubl
     .
   end.
   else do:
    assign
      varoldfact-qnty-exp            = 0
      varoldcost-sum-base-exp        = 0
      varoldcost-sum-rubl-exp        = 0
      varoldcost-vat-base-exp        = 0
      varoldcost-vat-rubl-exp        = 0
      varoldcost-slt-base-exp        = 0
      varoldcost-slt-rubl-exp        = 0
      varoldcost-road-tax-base-exp   = 0
      varoldcost-road-tax-rubl-exp   = 0
      varoldcost-excise-base-exp     = 0
      varoldcost-excise-rubl-exp     = 0
      varoldcost-transport-base-exp  = 0
      varoldcost-transport-rubl-exp  = 0
      varoldcost-other-base-exp      = 0
      varoldcost-other-rubl-exp      = 0
      varoldsale-sum-base-exp        = 0
      varoldsale-sum-rubl-exp        = 0
      varoldsale-vat-base-exp        = 0
      varoldsale-vat-rubl-exp        = 0
      varoldsale-slt-base-exp        = 0
      varoldsale-slt-rubl-exp        = 0
      varoldsale-road-tax-base-exp   = 0
      varoldsale-road-tax-rubl-exp   = 0
      varoldsale-excise-base-exp     = 0
      varoldsale-excise-rubl-exp     = 0
      varoldsale-transport-base-exp  = 0
      varoldsale-transport-rubl-exp  = 0
      varoldsale-other-base-exp      = 0
      varoldsale-other-rubl-exp      = 0
     .
   end.
   if not parhave-exp then do:
     assign
       varoldfact-qnty-inp            =   bf-incp_doc-line-sum.fact-qnty
       varoldcost-sum-base-inp        =   bf-incp_doc-line-sum.cost-sum-base
       varoldcost-sum-rubl-inp        =   bf-incp_doc-line-sum.cost-sum-rubl
       varoldcost-vat-base-inp        =   bf-incp_doc-line-sum.cost-vat-base
       varoldcost-vat-rubl-inp        =   bf-incp_doc-line-sum.cost-vat-rubl
       varoldcost-slt-base-inp        =   bf-incp_doc-line-sum.cost-slt-base
       varoldcost-slt-rubl-inp        =   bf-incp_doc-line-sum.cost-slt-rubl
       varoldcost-road-tax-base-inp   =   bf-incp_doc-line-sum.cost-road-tax-base
       varoldcost-road-tax-rubl-inp   =   bf-incp_doc-line-sum.cost-road-tax-rubl
       varoldcost-excise-base-inp     =   bf-incp_doc-line-sum.cost-excise-base
       varoldcost-excise-rubl-inp     =   bf-incp_doc-line-sum.cost-excise-rubl
       varoldcost-transport-base-inp  =   bf-incp_doc-line-sum.cost-transport-base
       varoldcost-transport-rubl-inp  =   bf-incp_doc-line-sum.cost-transport-rubl
       varoldcost-other-base-inp      =   bf-incp_doc-line-sum.cost-other-base
       varoldcost-other-rubl-inp      =   bf-incp_doc-line-sum.cost-other-rubl
       varoldsale-sum-base-inp        =   bf-incp_doc-line-sum.sale-sum-base
       varoldsale-sum-rubl-inp        =   bf-incp_doc-line-sum.sale-sum-rubl
       varoldsale-vat-base-inp        =   bf-incp_doc-line-sum.sale-vat-base
       varoldsale-vat-rubl-inp        =   bf-incp_doc-line-sum.sale-vat-rubl
       varoldsale-slt-base-inp        =   bf-incp_doc-line-sum.sale-slt-base
       varoldsale-slt-rubl-inp        =   bf-incp_doc-line-sum.sale-slt-rubl
       varoldsale-road-tax-base-inp   =   bf-incp_doc-line-sum.sale-road-tax-base
       varoldsale-road-tax-rubl-inp   =   bf-incp_doc-line-sum.sale-road-tax-rubl
       varoldsale-excise-base-inp     =   bf-incp_doc-line-sum.sale-excise-base
       varoldsale-excise-rubl-inp     =   bf-incp_doc-line-sum.sale-excise-rubl
       varoldsale-transport-base-inp  =   bf-incp_doc-line-sum.sale-transport-base
       varoldsale-transport-rubl-inp  =   bf-incp_doc-line-sum.sale-transport-rubl
       varoldsale-other-base-inp      =   bf-incp_doc-line-sum.sale-other-base
       varoldsale-other-rubl-inp      =   bf-incp_doc-line-sum.sale-other-rubl
     .
  end.
  else do:
     assign
       varoldfact-qnty-inp            = 0
       varoldcost-sum-base-inp        = 0
       varoldcost-sum-rubl-inp        = 0
       varoldcost-vat-base-inp        = 0
       varoldcost-vat-rubl-inp        = 0
       varoldcost-slt-base-inp        = 0
       varoldcost-slt-rubl-inp        = 0
       varoldcost-road-tax-base-inp   = 0
       varoldcost-road-tax-rubl-inp   = 0
       varoldcost-excise-base-inp     = 0
       varoldcost-excise-rubl-inp     = 0
       varoldcost-transport-base-inp  = 0
       varoldcost-transport-rubl-inp  = 0
       varoldcost-other-base-inp      = 0
       varoldcost-other-rubl-inp      = 0
       varoldsale-sum-base-inp        = 0
       varoldsale-sum-rubl-inp        = 0
       varoldsale-vat-base-inp        = 0
       varoldsale-vat-rubl-inp        = 0
       varoldsale-slt-base-inp        = 0
       varoldsale-slt-rubl-inp        = 0
       varoldsale-road-tax-base-inp   = 0
       varoldsale-road-tax-rubl-inp   = 0
       varoldsale-excise-base-inp     = 0
       varoldsale-excise-rubl-inp     = 0
       varoldsale-transport-base-inp  = 0
       varoldsale-transport-rubl-inp  = 0
       varoldsale-other-base-inp      = 0
       varoldsale-other-rubl-inp      = 0
     .
  end.
end.
end.
END PROCEDURE.
PROCEDURE mark-list :
DEFINE VARIABLE varlog AS LOGICAL NO-UNDO.
do on error undo, return error return-value :
if not available bf_doc-line then do:
  message "Неправильный выбор строки.".
  return ERROR.
end.
find first tt-del-list where tt-del-list.rec-id = recid( bf_doc-line ) no-error.
if available tt-del-list then do:
  delete tt-del-list.
end.
else do:
  create tt-del-list.
  assign
    tt-del-list.rec-id = recid( bf_doc-line ).
end.
b-goods-:refresh() in frame Dialog-Frame.
varlog = b-goods-:select-next-row () in frame Dialog-Frame.
apply "entry" to b-goods- in frame Dialog-Frame.
end.
END PROCEDURE.
PROCEDURE mode-on :
define variable varrecid as recid no-undo.
do on error undo, return error :
if pardoc-mode = 'ДОБАВЛЕНИЕ':U then do:
   RUN add-doc in this-procedure ( output varrecid ) no-error.
   if error-status :error then do:
     message
       vss-workfile vss-revision vss-description skip
       "Ошибка при добавлении документа." skip
       return-value skip
       trim(error-status :get-message(1))
       view-as alert-box error.
     undo, return error .
   end.
end.
else do:
  find first bf_trn-doc where recid(bf_trn-doc) = pardoc-rec no-lock.
  if available bf_trn-doc then do:
    if pardoc-mode = 'ИЗМЕНЕНИЕ':U then do:
      if bf_trn-doc.status_ <> 'накл':U then do:
        message "Документ закрыт." skip (1)
                "Редактирование невозможно."
                view-as alert-box error.
        return error.
      end.
      else do:
        if v-cntxt-db-num <> bf-obj_clients.db-num then do:
          message
            vss-workfile vss-revision vss-description skip
            "Редактирование документа возможно только на активной стороне." skip
            return-value skip
            trim(error-status :get-message(1))
            view-as alert-box error.
          undo, return error .
        end.
      end.
    end.
  end.
  else do:
    message "Неправильный выбор документа.".
    return error.
  end.
end.
end.
END PROCEDURE.
PROCEDURE notes-tr :
define variable varnotes as character no-undo.
assign
  varnotes = bf_trn-doc.PS.
run gbl/d-prompt.w (
    'title=Примечание\'
  + 'type=editor\'
  + 'fillin_width=96\'
  + 'fillin_height=15\'
  + (if pardoc-mode = 'ПРОСМОТР':U then 'readonly=yes\' else '':U)
  , input-output varnotes).
if pardoc-mode <> 'ПРОСМОТР':U then do:
  if return-value = 'false':u
  then do:
    return .
  end.
  if bf_trn-doc.PS <> varnotes then do:
    do transaction on error undo, return error return-value :
      find CURRENT bf_trn-doc exclusive-lock.
      assign
        bf_trn-doc.PS = varnotes.
    end.
  end.
end.
END PROCEDURE.
PROCEDURE proc-exit :
DEFINE BUFFER bf-f_doc-line FOR ub.doc-line.
DEFINE VARIABLE varlog AS LOGICAL NO-UNDO.
if pardoc-mode = 'ИЗМЕНЕНИЕ':U or pardoc-mode = 'ДОБАВЛЕНИЕ':U then do:
  parnext-prev = ?.
  if not can-find (first bf-f_doc-line where bf-f_doc-line.doc-code = bf_trn-doc.doc-code no-lock) then do:
    varlog = yes.
    message "В документе нет строк, поэтому он удаляется." view-as alert-box
      question buttons OK-Cancel update varlog.
    if varlog then do:
      delete bf_trn-doc.
      assign pardoc-rec = ?.
      return.
    end.
    else do:
      return error.
    end.
  end.
  else do:
    assign
      bf_trn-doc.reason-code = varreason-code
      bf_trn-doc.wrkr = varwrkr
      bf_trn-doc.agnt = varagnt
      bf_trn-doc.boss = varboss.
   end.
end.
END PROCEDURE.
PROCEDURE proc-get-write-off :
DEFINE PARAMETER BUFFER bf-loc_doc-line FOR ub.doc-line.
DEFINE BUFFER bf-loc-plus_doc-line FOR ub.doc-line.
DEFINE BUFFER bf-loc_parts         FOR ub.parts.
DEFINE BUFFER bf-loc_parts-root    FOR ub.parts-root.
DEFINE BUFFER bf-loc-plus_parts    FOR ub.parts.
DEFINE BUFFER bf-loc_goods         FOR ub.goods.
DEFINE BUFFER bf-loc-plus_goods    FOR ub.goods.
DEFINE VARIABLE varprice-rubl-parts AS DECIMAL NO-UNDO.
DEFINE VARIABLE varprice-base-parts AS DECIMAL NO-UNDO.
FIND FIRST bf-loc_goods WHERE bf-loc_goods.artic     = bf-loc_doc-line.artic     AND
                              bf-loc_goods.prod-type = bf-loc_doc-line.prod-type AND
                              bf-loc_goods.prod-code = bf-loc_doc-line.prod-code NO-LOCK.
FIND FIRST tt-doc-line-cashe WHERE tt-doc-line-cashe.doc-code  = bf-loc_doc-line.doc-code  AND
                                   tt-doc-line-cashe.artic     = bf-loc_doc-line.artic     AND
                                   tt-doc-line-cashe.prod-type = bf-loc_doc-line.prod-type AND
                                   tt-doc-line-cashe.prod-code = bf-loc_doc-line.prod-code NO-ERROR.
IF NOT AVAILABLE tt-doc-line-cashe THEN DO:
  CREATE tt-doc-line-cashe.
  ASSIGN
    tt-doc-line-cashe.doc-code  = bf-loc_doc-line.doc-code
    tt-doc-line-cashe.artic     = bf-loc_doc-line.artic
    tt-doc-line-cashe.prod-type = bf-loc_doc-line.prod-type
    tt-doc-line-cashe.prod-code = bf-loc_doc-line.prod-code .
END.
ELSE DO:
  ASSIGN
    tt-doc-line-cashe.qnty     = 0.00
    tt-doc-line-cashe.sum-rubl = 0.00
    tt-doc-line-cashe.sum-base = 0.00
    tt-doc-line-cashe.vat-rubl = 0.00
    tt-doc-line-cashe.vat-base = 0.00.
  FOR EACH tt-doc-line-cashe-plus WHERE tt-doc-line-cashe-plus.doc-code     = tt-doc-line-cashe.doc-code  AND
                                        tt-doc-line-cashe-plus.wf-artic     = tt-doc-line-cashe.artic     AND
                                        tt-doc-line-cashe-plus.wf-prod-type = tt-doc-line-cashe.prod-type AND
                                        tt-doc-line-cashe-plus.wf-prod-code = tt-doc-line-cashe.prod-code :
    DELETE tt-doc-line-cashe-plus.
  END.
END.
FOR EACH bf-loc_parts WHERE bf-loc_parts.out-code  = bf-loc_doc-line.doc-code  AND
                            bf-loc_parts.obj-type  = bf-loc_doc-line.obj-type  AND
                            bf-loc_parts.obj-code  = bf-loc_doc-line.obj-code  AND
                            bf-loc_parts.artic     = bf-loc_doc-line.artic     AND
                            bf-loc_parts.prod-type = bf-loc_doc-line.prod-type AND
                            bf-loc_parts.prod-code = bf-loc_doc-line.prod-code AND
                            bf-loc_parts.fact-qnty < 0 NO-LOCK :
  FOR EACH tt-clcparts :
    DELETE tt-clcparts.
  END.
  CREATE tt-clcparts.
  BUFFER-COPY bf-loc_parts TO tt-clcparts.
  run clcprtsl_calc-parts in this-procedure (
                                  input recid( tt-clcparts )
                                , input yes
                                , input no
                                , input bf-loc_doc-line.road-tax
                                , input bf-loc_doc-line.excise
                                , input bf-loc_doc-line.VAT-pc
                                , input bf-loc_doc-line.cons-vat-pc
                                , input bf-loc_doc-line.SLT-pc
                                , input bf_trn-doc.base-rate
                                , input bf_trn-doc.base-scale
                                , input "":U
                                , input 0.0
                                , input 0.0
                                , input 0.0
                                , input 0.0
                                , input 0.0
                                , input 0.0
                            ).
  FIND FIRST tt-allsum WHERE tt-allsum.sum-type = 'основная_сумма':U NO-ERROR.
  if available tt-allsum then do:
    ASSIGN
      tt-doc-line-cashe.qnty     = tt-doc-line-cashe.qnty     - tt-allsum.fact-qnty
      tt-doc-line-cashe.sum-rubl = tt-doc-line-cashe.sum-rubl - tt-allsum.sum-dsc-rubl-doc
      tt-doc-line-cashe.sum-base = tt-doc-line-cashe.sum-base - tt-allsum.sum-dsc-base-doc
      tt-doc-line-cashe.vat-rubl = tt-doc-line-cashe.vat-rubl - tt-allsum.vat-rubl-doc
      tt-doc-line-cashe.vat-base = tt-doc-line-cashe.vat-base - tt-allsum.vat-base-doc.
    ASSIGN
      varprice-rubl-parts = tt-allsum.sum-dsc-rubl-doc / tt-allsum.fact-qnty
      varprice-base-parts = tt-allsum.sum-dsc-base-doc / tt-allsum.fact-qnty.
    FOR EACH bf-loc_parts-root WHERE bf-loc_parts-root.doc-code       = bf-loc_parts.out-code   AND
                                     bf-loc_parts-root.orig-in-code   = bf-loc_parts.in-code    AND
                                     bf-loc_parts-root.orig-gds-code  = bf-loc_goods.gds-code   AND
                                     bf-loc_parts-root.orig-part-code = bf-loc_parts.part-code  NO-LOCK :
      FIND FIRST bf-loc-plus_goods WHERE bf-loc-plus_goods.gds-code  = bf-loc_parts-root.gds-code NO-LOCK.
      FIND FIRST bf-loc-plus_parts WHERE bf-loc-plus_parts.obj-type  = bf-loc_doc-line.obj-type    AND
                                         bf-loc-plus_parts.obj-code  = bf-loc_doc-line.obj-code    AND
                                         bf-loc-plus_parts.artic     = bf-loc-plus_goods.artic     AND
                                         bf-loc-plus_parts.prod-type = bf-loc-plus_goods.prod-type AND
                                         bf-loc-plus_parts.prod-code = bf-loc-plus_goods.prod-code AND
                                         bf-loc-plus_parts.in-code   = bf-loc_parts-root.in-code   AND
                                         bf-loc-plus_parts.out-code  = bf-loc_doc-line.doc-code    AND
                                         bf-loc-plus_parts.part-code = bf-loc_parts-root.part-code NO-LOCK.
      FIND FIRST bf-loc-plus_doc-line WHERE bf-loc-plus_doc-line.doc-code  = bf-loc-plus_parts.out-code  AND
                                            bf-loc-plus_doc-line.artic     = bf-loc-plus_parts.artic     AND
                                            bf-loc-plus_doc-line.prod-type = bf-loc-plus_parts.prod-type AND
                                            bf-loc-plus_doc-line.prod-code = bf-loc-plus_parts.prod-code .
      FIND FIRST tt-doc-line-cashe-plus WHERE tt-doc-line-cashe-plus.doc-code     = tt-doc-line-cashe.doc-code  AND
                                              tt-doc-line-cashe-plus.wf-artic     = tt-doc-line-cashe.artic     AND
                                              tt-doc-line-cashe-plus.wf-prod-type = tt-doc-line-cashe.prod-type AND
                                              tt-doc-line-cashe-plus.wf-prod-code = tt-doc-line-cashe.prod-code AND
                                              tt-doc-line-cashe-plus.artic        = bf-loc-plus_goods.artic      AND
                                              tt-doc-line-cashe-plus.prod-type    = bf-loc-plus_goods.prod-type  AND
                                              tt-doc-line-cashe-plus.prod-code    = bf-loc-plus_goods.prod-code  NO-ERROR.
      IF NOT AVAILABLE tt-doc-line-cashe-plus THEN DO:
        create tt-doc-line-cashe-plus.
        ASSIGN
          tt-doc-line-cashe-plus.doc-code     = tt-doc-line-cashe.doc-code
          tt-doc-line-cashe-plus.wf-artic     = tt-doc-line-cashe.artic
          tt-doc-line-cashe-plus.wf-prod-type = tt-doc-line-cashe.prod-type
          tt-doc-line-cashe-plus.wf-prod-code = tt-doc-line-cashe.prod-code
          tt-doc-line-cashe-plus.artic        = bf-loc-plus_goods.artic
          tt-doc-line-cashe-plus.prod-type    = bf-loc-plus_goods.prod-type
          tt-doc-line-cashe-plus.prod-code    = bf-loc-plus_goods.prod-code .
      END.
      FOR EACH tt-clcparts :
        DELETE tt-clcparts.
      END.
      CREATE tt-clcparts.
      BUFFER-COPY bf-loc-plus_parts TO tt-clcparts.
      run clcprtsl_calc-parts in this-procedure (
                                      input recid( tt-clcparts )
                                    , input yes
                                    , input no
                                    , input bf-loc-plus_doc-line.road-tax
                                    , input bf-loc-plus_doc-line.excise
                                    , input bf-loc-plus_doc-line.VAT-pc
                                    , input bf-loc-plus_doc-line.cons-vat-pc
                                    , input bf-loc-plus_doc-line.SLT-pc
                                    , input bf_trn-doc.base-rate
                                    , input bf_trn-doc.base-scale
                                    , input "":U
                                    , input 0.0
                                    , input 0.0
                                    , input 0.0
                                    , input 0.0
                                    , input 0.0
                                    , input 0.0
                                ).
      FIND FIRST tt-allsum WHERE tt-allsum.sum-type = 'основная_сумма':U NO-ERROR.
      if available tt-allsum then do:
        ASSIGN
          tt-doc-line-cashe-plus.qnty               = tt-doc-line-cashe-plus.qnty               + tt-allsum.fact-qnty
          tt-doc-line-cashe-plus.sum-rubl           = tt-doc-line-cashe-plus.sum-rubl           + tt-allsum.sum-dsc-rubl-doc
          tt-doc-line-cashe-plus.sum-base           = tt-doc-line-cashe-plus.sum-base           + tt-allsum.sum-dsc-base-doc
          tt-doc-line-cashe-plus.vat-rubl           = tt-doc-line-cashe-plus.vat-rubl           + tt-allsum.vat-rubl-doc
          tt-doc-line-cashe-plus.vat-base           = tt-doc-line-cashe-plus.vat-base           + tt-allsum.vat-base-doc
          tt-doc-line-cashe-plus.write-off-qnty     = tt-doc-line-cashe-plus.write-off-qnty     + tt-clcparts.real-qnty
          tt-doc-line-cashe-plus.write-off-sum-rubl = tt-doc-line-cashe-plus.write-off-sum-rubl + varprice-rubl-parts * tt-clcparts.real-qnty
          tt-doc-line-cashe-plus.write-off-sum-base = tt-doc-line-cashe-plus.write-off-sum-base + varprice-base-parts * tt-clcparts.real-qnty
        .
      END.
    END.
  END.
END.
END PROCEDURE.
PROCEDURE proc-history :
define variable loc-ref-list as character no-undo.
  do on error undo, return error return-value :
    if not available doc-line then do:
      return error.
    end.
    run str/docclins.w ( input        parparentproc,
                     input        "":U,
                     input        "doc",
                     input        doc-line.obj-type,
                     input        doc-line.obj-code,
                     input        doc-line.doc-code,
                     input        doc-line.artic,
                     input        doc-line.prod-type,
                     input        doc-line.prod-code,
                     input-output loc-ref-list             ).
    apply "ENTRY":U to b-goods in frame Dialog-Frame.
  end.
  END PROCEDURE.
PROCEDURE proc-shift-name :
define buffer bf_shift-obj   for ub.shift-obj.
  define buffer bf_shift-staff for ub.shift-staff.
  define variable varfind-shift as integer initial 0.
  define variable varshift-date-mem like ub.shift-obj.shift-date no-undo.
  define variable varshift-num-mem  like ub.shift-obj.shift-num  no-undo.
  if input frame Dialog-Frame varshift-date <> ? then do:
    for each  bf_shift-obj where bf_shift-obj.obj-type   = bf_trn-doc.obj-type                             and
                                 bf_shift-obj.obj-code   = bf_trn-doc.obj-code                             and
                                 bf_shift-obj.shift-date = input frame Dialog-Frame varshift-date no-lock on error undo, return error return-value :
      assign
        varfind-shift = varfind-shift + 1
        varshift-date-mem = bf_shift-obj.shift-date
        varshift-num-mem  = bf_shift-obj.shift-num.
    end.
    if varfind-shift = 0 or varfind-shift > 1 then do:
      if varfind-shift = 0 then do:
        message "Не найдена смена: " bf_trn-doc.obj-type " " bf_trn-doc.obj-code
                " Дата " input frame Dialog-Frame varshift-date
                 " Номер смены " input frame Dialog-Frame varshift-name " ."
        view-as alert-box error.
      end.
      else do:
        message "Найдено более одной смены с одним номером в сменном дне. Объект: " bf_trn-doc.obj-type " " bf_trn-doc.obj-code
                " Дата " input frame Dialog-Frame varshift-date " Номер смены " input frame Dialog-Frame varshift-name " ."
        view-as alert-box error.
      end.
      display varshift-name with frame Dialog-Frame.
      run proc-sht no-error.
      if error-status:error then do: return error. end.
    end.
    else do:
      assign frame Dialog-Frame
        varshift-name.
      assign
        bf_trn-doc.shift-date = varshift-date-mem
        bf_trn-doc.shift-num  = varshift-num-mem
        varshift-date = varshift-date-mem
        varshift-num = varshift-num-mem.
      display bf_trn-doc.shift-date @ varshift-date
              bf_trn-doc.shift-num  @ varshift-num
              varshift-name with frame Dialog-Frame.
      if bf_trn-doc.fact-date = ? then do:
        assign bf_trn-doc.fact-date = bf_trn-doc.shift-date
               bf_trn-doc.fact-time = (24 * 60 * 60).
        display bf_trn-doc.fact-date @ varfact-date with frame Dialog-Frame.
       end.
    end.
  end.
END PROCEDURE.
PROCEDURE proc-shift-num :
define buffer bf_shift-obj   for ub.shift-obj.
  define buffer bf_shift-staff for ub.shift-staff.
  if input frame Dialog-Frame varshift-date <> ? then do:
    find first bf_shift-obj where bf_shift-obj.obj-type   = bf_trn-doc.obj-type                     and
                                  bf_shift-obj.obj-code   = bf_trn-doc.obj-code                     and
                                  bf_shift-obj.shift-date = input frame Dialog-Frame varshift-date AND
                                  bf_shift-obj.shift-num  = input frame Dialog-Frame varshift-num  no-lock no-error.
    if not available bf_shift-obj then do:
      message "Не найдена смена на объекте: " bf_trn-doc.obj-type " " bf_trn-doc.obj-code
              " Дата " input frame Dialog-Frame varshift-date " Порядок смены " varshift-num " ."
      view-as alert-box error.
      display varshift-num with frame Dialog-Frame.
      run proc-sht in this-procedure no-error.
      if error-status:error then do:
        return error.
      end.
    end.
    else do:
      assign
        bf_trn-doc.shift-date = bf_shift-obj.shift-date
        bf_trn-doc.shift-num  = bf_shift-obj.shift-num
        varshift-name    = bf_shift-obj.shift-name
        varshift-date = bf_shift-obj.shift-date.
      display bf_trn-doc.shift-date @ varshift-date
              bf_trn-doc.shift-num  @ varshift-num
              varshift-name with frame Dialog-Frame.
      if bf_trn-doc.fact-date = ? then do:
        assign
          bf_trn-doc.fact-date = bf_trn-doc.shift-date
          bf_trn-doc.fact-time = (24 * 60 * 60).
        display bf_trn-doc.fact-date @ varfact-date with frame Dialog-Frame.
      end.
    end.
  end.
END PROCEDURE.
PROCEDURE proc-sht :
define buffer bf_shift-obj   for ub.shift-obj.
  define buffer bf_shift-staff for ub.shift-staff.
  define variable varrid-list as character no-undo.
  define variable varrecid    as recid     no-undo.
  assign
    varrid-list = "".
  run str/sht-all.w (INPUT parparentproc,
                 INPUT bf_trn-doc.obj-type,
                 INPUT bf_trn-doc.obj-code,
                 INPUT 'b-sel',
                 INPUT 'obj',
                 INPUT bf_trn-doc.obj-type,
                 INPUT bf_trn-doc.obj-code,
                 INPUT '':u,
                 input-output varrid-list)
  no-error.
  if error-status:error or varrid-list = "":u then do:
    return error.
  end.
  else do:
    assign
      varrecid = integer (entry(1, varrid-list)).
    find first bf_shift-obj where recid(bf_shift-obj) = varrecid no-lock no-error.
    if available bf_shift-obj then do:
      assign
        bf_trn-doc.shift-date = bf_shift-obj.shift-date
        bf_trn-doc.shift-num  = bf_shift-obj.shift-num
        varshift-name    = bf_shift-obj.shift-name
        varshift-date = bf_shift-obj.shift-date
        varshift-num = bf_shift-obj.shift-num.
      display bf_trn-doc.shift-date @ varshift-date
              bf_trn-doc.shift-num  @ varshift-num
              varshift-name with frame Dialog-Frame.
        assign
          bf_trn-doc.fact-date = bf_trn-doc.shift-date
          bf_trn-doc.fact-time = (24 * 60 * 60).
        display bf_trn-doc.fact-date @ varfact-date with frame Dialog-Frame.
    end.
  end.
END PROCEDURE.
PROCEDURE recalc-line :
DEFINE BUFFER bf-recalc_doc-line FOR ub.doc-line.
DEFINE BUFFER bf-recalc_parts    FOR ub.parts.
DEFINE VARIABLE varsum-base  LIKE ub.parts.price-base.
DEFINE VARIABLE varsum-rubl  LIKE ub.parts.price-rubl.
DEFINE VARIABLE varfact-qnty LIKE ub.parts.fact-qnty.
DO ON ERROR UNDO, RETURN ERROR RETURN-VALUE :
FOR EACH tt-recalc-line ON ERROR UNDO, RETURN ERROR RETURN-VALUE :
  FIND FIRST bf-recalc_doc-line WHERE bf-recalc_doc-line.doc-code  = tt-recalc-line.doc-code  AND
                                      bf-recalc_doc-line.artic     = tt-recalc-line.artic     AND
                                      bf-recalc_doc-line.prod-type = tt-recalc-line.prod-type AND
                                      bf-recalc_doc-line.prod-code = tt-recalc-line.prod-code EXCLUSIVE-LOCK.
  assign
    varsum-base  = 0.00
    varsum-rubl  = 0.00
    varfact-qnty = 0.00
  .
  FOR EACH bf-recalc_parts WHERE bf-recalc_parts.out-code  = bf-recalc_doc-line.doc-code  AND
                                 bf-recalc_parts.obj-type  = bf-recalc_doc-line.obj-type  AND
                                 bf-recalc_parts.obj-code  = bf-recalc_doc-line.obj-code  AND
                                 bf-recalc_parts.artic     = bf-recalc_doc-line.artic     AND
                                 bf-recalc_parts.prod-type = bf-recalc_doc-line.prod-type AND
                                 bf-recalc_parts.prod-code = bf-recalc_doc-line.prod-code ON ERROR UNDO, RETURN ERROR RETURN-VALUE :
    ASSIGN
      varsum-base  = varsum-base  + bf-recalc_parts.price-base * bf-recalc_parts.fact-qnty
      varsum-rubl  = varsum-rubl  + bf-recalc_parts.price-rubl * bf-recalc_parts.fact-qnty
      varfact-qnty = varfact-qnty + bf-recalc_parts.fact-qnty.
  END.
  ASSIGN
    bf-recalc_doc-line.price-base = varsum-base / varfact-qnty
    bf-recalc_doc-line.price-rubl = varsum-rubl / varfact-qnty.
END.
END.
END PROCEDURE.
PROCEDURE rsrv-gds-dtl :
DEFINE INPUT PARAMETER pardoc-code  LIKE ub.doc-line.doc-code  NO-UNDO.
DEFINE INPUT PARAMETER parartic     LIKE ub.doc-line.artic     NO-UNDO.
DEFINE INPUT PARAMETER parprod-type LIKE ub.doc-line.prod-type NO-UNDO.
DEFINE INPUT PARAMETER parprod-code LIKE ub.doc-line.prod-code NO-UNDO.
DEFINE INPUT PARAMETER paravaiparts AS   LOGICAL               NO-UNDO.
DEFINE INPUT PARAMETER parrsrv-qnty AS   DECIMAL               NO-UNDO.
DEFINE BUFFER bf-del_doc-line     FOR ub.doc-line.
DEFINE BUFFER bf-del_goods        FOR ub.goods.
DEFINE BUFFER bf-del_gds-dtl      FOR ub.gds-dtl.
define buffer bf-del-next_gds-dtl for ub.gds-dtl.
define variable varrsrv-qnty-gds-dtl as decimal no-undo.
define variable vargds-dtl-doc-qnty  as decimal no-undo.
do on error undo, return error return-value :
FIND FIRST bf-del_doc-line WHERE bf-del_doc-line.doc-code  = pardoc-code  AND
                                 bf-del_doc-line.artic     = parartic     AND
                                 bf-del_doc-line.prod-type = parprod-type AND
                                 bf-del_doc-line.prod-code = parprod-code EXCLUSIVE-LOCK.
FIND FIRST bf-del_goods WHERE bf-del_goods.artic     = bf-del_doc-line.artic     AND
                              bf-del_goods.prod-type = bf-del_doc-line.prod-type AND
                              bf-del_goods.prod-code = bf-del_doc-line.prod-code NO-LOCK.
  if bf-del_doc-line.fact-qnty = 0    and
     not paravaiparts then do:
  end.
  else do:
    assign
      varrsrv-qnty-gds-dtl = 0.00.
    cycle-gds-dtl:
    for each bf-del_gds-dtl where bf-del_gds-dtl.doc-code  = bf_trn-doc.doc-code    and
                                  bf-del_gds-dtl.artic     = bf-del_goods.artic     and
                                  bf-del_gds-dtl.prod-type = bf-del_goods.prod-type and
                                  bf-del_gds-dtl.prod-code = bf-del_goods.prod-code
                                  exclusive-lock
                                  break by bf-del_gds-dtl.doc-qnty descending
                                  on error undo, return error return-value :
      if bf-del_gds-dtl.doc-qnty < 0 then do:
        if - bf-del_gds-dtl.doc-qnty >= (parrsrv-qnty - varrsrv-qnty-gds-dtl) then do:
          assign
            bf-del_gds-dtl.doc-qnty  = bf-del_gds-dtl.doc-qnty + (parrsrv-qnty - varrsrv-qnty-gds-dtl)
          .
          leave cycle-gds-dtl.
        end.
        else do:
          assign
            varrsrv-qnty-gds-dtl = varrsrv-qnty-gds-dtl + (- bf-del_gds-dtl.doc-qnty)
            bf-del_gds-dtl.doc-qnty  = 0
            .
        end.
      end.
      else do:
        assign
          bf-del_gds-dtl.doc-qnty  = bf-del_gds-dtl.doc-qnty + (parrsrv-qnty - varrsrv-qnty-gds-dtl)
        .
        leave cycle-gds-dtl.
      end.
    end.
    assign
      vargds-dtl-doc-qnty  = 0.00.
    for each bf-del_gds-dtl where bf-del_gds-dtl.doc-code  = bf_trn-doc.doc-code    and
                                  bf-del_gds-dtl.artic     = bf-del_goods.artic     and
                                  bf-del_gds-dtl.prod-type = bf-del_goods.prod-type and
                                  bf-del_gds-dtl.prod-code = bf-del_goods.prod-code on error undo, return error return-value :
      assign
        vargds-dtl-doc-qnty  = vargds-dtl-doc-qnty  + bf-del_gds-dtl.doc-qnty.
    end.
    if bf-del_doc-line.fact-qnty <> vargds-dtl-doc-qnty then do:
       undo, return error substitute ("Ошибочно произведено разрезервирование по признакам для товара списания. Товар &1 &2 &3 &4. Количество по строке &5. Количество по признакам &6.",
                                      bf-del_goods.artic,
                                      bf-del_goods.prod-type,
                                      bf-del_goods.prod-code,
                                      bf-del_goods.gds-name,
                                      bf-del_doc-line.fact-qnty,
                                      vargds-dtl-doc-qnty).
    end.
    FIND FIRST bf-del_gds-dtl WHERE bf-del_gds-dtl.doc-code  = bf-del_doc-line.doc-code  AND
                                    bf-del_gds-dtl.artic     = bf-del_doc-line.artic     AND
                                    bf-del_gds-dtl.prod-type = bf-del_doc-line.prod-type AND
                                    bf-del_gds-dtl.prod-code = bf-del_doc-line.prod-code AND
                                    bf-del_gds-dtl.doc-qnty  <> 0                        NO-ERROR.
    IF AVAILABLE bf-del_gds-dtl THEN DO:
      FOR EACH bf-del_gds-dtl WHERE bf-del_gds-dtl.doc-code  = bf-del_doc-line.doc-code  AND
                                    bf-del_gds-dtl.artic     = bf-del_doc-line.artic     AND
                                    bf-del_gds-dtl.prod-type = bf-del_doc-line.prod-type AND
                                    bf-del_gds-dtl.prod-code = bf-del_doc-line.prod-code AND
                                    bf-del_gds-dtl.doc-qnty = 0                         ON ERROR UNDO, RETURN ERROR RETURN-VALUE :
        DELETE bf-del_gds-dtl.
      END.
    END.
  end.
end.
END PROCEDURE.
PROCEDURE rsrv-gds-dtl-plus :
define input parameter pardoc-code  like ub.doc-line.doc-code  no-undo.
define input parameter parartic     like ub.doc-line.artic     no-undo.
define input parameter parprod-type like ub.doc-line.prod-type no-undo.
define input parameter parprod-code like ub.doc-line.prod-code no-undo.
define input parameter paravaiparts as   logical               no-undo.
define input parameter parrsrv-qnty as   decimal               no-undo.
define variable varrsrv-qnty-gds-dtl-plus as decimal            no-undo.
define buffer bf-del-plus_doc-line for ub.doc-line.
define buffer bf-del-plus_gds-dtl      for ub.gds-dtl.
define buffer bf-del-next-plus_gds-dtl for ub.gds-dtl.
do on error undo, return error return-value :
find first bf-del-plus_doc-line where bf-del-plus_doc-line.doc-code  = pardoc-code  and
                                      bf-del-plus_doc-line.artic     = parartic     and
                                      bf-del-plus_doc-line.prod-type = parprod-type and
                                      bf-del-plus_doc-line.prod-code = parprod-code exclusive-lock.
assign
  varrsrv-qnty-gds-dtl-plus = 0.00.
cycle-gds-dtl-plus:
for each bf-del-plus_gds-dtl where bf-del-plus_gds-dtl.doc-code  = pardoc-code         and
                                   bf-del-plus_gds-dtl.artic     = parartic     and
                                   bf-del-plus_gds-dtl.prod-type = parprod-type and
                                   bf-del-plus_gds-dtl.prod-code = parprod-code
                                   exclusive-lock
                                   break by bf-del-plus_gds-dtl.doc-qnty descending
                                   on error undo, return error return-value :
  if bf-del-plus_gds-dtl.doc-qnty > 0 then do:
    if bf-del-plus_gds-dtl.doc-qnty >= (parrsrv-qnty - varrsrv-qnty-gds-dtl-plus) then do:
      assign
        bf-del-plus_gds-dtl.doc-qnty = bf-del-plus_gds-dtl.doc-qnty - (parrsrv-qnty - varrsrv-qnty-gds-dtl-plus).
      leave cycle-gds-dtl-plus.
    end.
    else do:
      assign
        varrsrv-qnty-gds-dtl-plus = varrsrv-qnty-gds-dtl-plus + bf-del-plus_gds-dtl.doc-qnty.
      assign
        bf-del-plus_gds-dtl.doc-qnty  = 0.00
      .
    end.
  end.
  else do:
    assign
      bf-del-plus_gds-dtl.doc-qnty = bf-del-plus_gds-dtl.doc-qnty - (parrsrv-qnty - varrsrv-qnty-gds-dtl-plus).
    leave cycle-gds-dtl-plus.
  end.
end.
if bf-del-plus_doc-line.fact-qnty = 0    and
   not paravaiparts then do:
  run local-recalc in this-procedure (input "delete":u,
                                      input recid(bf-del-plus_doc-line),
                                      input no) no-error.
  if error-status:error then do:
    undo, return error substitute ("Ошибка при пересчете строки документа: &1", return-value).
  end.
  run local-line-delete in this-procedure (input recid(bf-del-plus_doc-line)) no-error.
  if error-status:error then do:
    undo, return error substitute ("Ошибка при удалении строки документа. Оприходованный товар: &1 &2 &3.", bf-del-plus_doc-line.artic, bf-del-plus_doc-line.prod-type, bf-del-plus_doc-line.prod-code).
  end.
end.
else do:
  run local-recalc in this-procedure (input "update":u,
                                      input recid(bf-del-plus_doc-line),
                                      input no) no-error.
  if error-status:error then do:
    undo, return error substitute ("Ошибка при пересчете строки документа по оприходованным товарам: &1", return-value).
  end.
  find first bf-del-plus_gds-dtl where bf-del-plus_gds-dtl.doc-code  = bf-del-plus_doc-line.doc-code  and
                                       bf-del-plus_gds-dtl.artic     = bf-del-plus_doc-line.artic     and
                                       bf-del-plus_gds-dtl.prod-type = bf-del-plus_doc-line.prod-type and
                                       bf-del-plus_gds-dtl.prod-code = bf-del-plus_doc-line.prod-code and
                                       bf-del-plus_gds-dtl.doc-qnty <> 0                              no-error.
  if available bf-del-plus_gds-dtl then do:
    for each bf-del-plus_gds-dtl where bf-del-plus_gds-dtl.doc-code  = bf-del-plus_doc-line.doc-code  and
                                       bf-del-plus_gds-dtl.artic     = bf-del-plus_doc-line.artic     and
                                       bf-del-plus_gds-dtl.prod-type = bf-del-plus_doc-line.prod-type and
                                       bf-del-plus_gds-dtl.prod-code = bf-del-plus_doc-line.prod-code and
                                       bf-del-plus_gds-dtl.doc-qnty  = 0                              on error undo, return error return-value :
      delete bf-del-plus_gds-dtl.
    end.
  end.
end.
end.
end procedure.
PROCEDURE select-reason :
  define variable j-rsn-code like ub.trn-reason.reason-code no-undo.
  define buffer bf_trn-reason for ub.trn-reason.
  do on error undo, return error return-value :
    assign
      j-rsn-code = ( input frame Dialog-Frame varreason-code )
    .
    run str/trn-reas.w ( input ParParentProc, input 'выбор':U, input-output j-rsn-code ).
    find first bf_trn-reason no-lock where
               bf_trn-reason.reason-code = j-rsn-code no-error.
    if available bf_trn-reason then do:
      assign
        varreason-name    = bf_trn-reason.reason-name
        bf_trn-doc.reason-code = bf_trn-reason.reason-code
        varreason-code    = bf_trn-reason.reason-code
      .
      display varreason-code
              varreason-name
      with frame Dialog-Frame.
    end.
  end.
END PROCEDURE.
PROCEDURE ui-on :
define input parameter fnc as character no-undo.
define buffer bf_contract for ub.contract.
define buffer bf_clients  for ub.clients.
define variable varhave-shift     as logical   no-undo.
define variable varadd-back-date  as logical   no-undo.
do on error undo, return error return-value :
  for each tt-del-list on error undo, return error return-value :
    delete tt-del-list.
  end.
  case pardoc-mode :
    when 'ПРОСМОТР':U then do:
        if parext-doc-mode = "reason-code" then do:
          enable r-reas with frame Dialog-Frame.
        end.
    end.
    otherwise do:
      enable b-mark b-add b-chg b-del
             varwrkr varagnt varboss
             r-wrkr r-agnt r-boss
             r-reas
      with frame Dialog-Frame.
define variable vss-include-info63 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_tdedt-peresort_add-back-date':u
    ,input  'object':U
    ,input  bf_trn-doc.host-code
    ,input  bf_trn-doc.obj-type
    ,input  bf_trn-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output varadd-back-date
    )  .
end.
      if varadd-back-date then do:
        enable varfact-date with frame Dialog-Frame.
      end.
define variable vss-include-info64 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  bf_trn-doc.obj-type
  ,input  bf_trn-doc.obj-code
  ,input  'shift-on=request'
  ,output varhave-shift
  ) no-error .
      if error-status :error then do:
        message
        vss-workfile vss-revision vss-description skip
        "Ошибка при запуске процедуры objat" skip
        return-value skip
        view-as alert-box error .
        return error.
      end.
      if not varhave-shift then do:
       hide varshift-date varshift-num varshift-name r-sht in frame Dialog-Frame.
      end.
      ELSE DO:
        if varadd-back-date then do:
          ENABLE varshift-date varshift-num varshift-name r-sht WITH frame Dialog-Frame.
        end.
      END.
    end.
  end case.
  if not parold-supp-cntr then do:
    if bf_trn-doc.contract-code <> 0 then do:
      find first bf_contract where bf_contract.host-code     = bf_trn-doc.host-code     and
                                   bf_contract.contract-code = bf_trn-doc.contract-code no-lock.
      assign
        varcontract-prn-code = bf_contract.contract-prn-code
        varcontract-name     = bf_contract.contract-name
       .
    end.
    assign
      vardoc-date  = bf_trn-doc.doc-date
      varfact-date = bf_trn-doc.fact-date
      varcli-type  = bf_trn-doc.cli-type
      varcli-code  = bf_trn-doc.cli-code
      varcli-name  = bf_trn-doc.cli-name .
    display vardoc-date
            varfact-date
            varcli-type
            varcli-code
            varcli-name
            varcontract-prn-code
            varcontract-name
    with frame Dialog-Frame.
  end.
  else do:
    display varinformation with frame Dialog-Frame.
  end.
  IF varhave-shift THEN DO:
    if bf_trn-doc.shift-date <> ? then do:
      assign
        varshift-date = bf_trn-doc.shift-date
        varshift-num  = bf_trn-doc.shift-num
        varshift-name = bf_trn-doc.shift-name
      .
      display varshift-date varshift-num  varshift-name  with frame Dialog-Frame.
    end.
  end.
  assign
    varfact-date = bf_trn-doc.fact-date.
  display varfact-date with frame Dialog-Frame.
  assign
    frame Dialog-Frame :title = bf_trn-doc.obj-type + " " + string( bf_trn-doc.obj-code, ">>>>9":U ) + "  : ПЕРЕСОРТИЦА " +
    bf_trn-doc.status_ + " " + string( bf_trn-doc.flag_, "+/-":U ) + " № " + bf_trn-doc.doc-code + "   - " + pardoc-mode.
  ASSIGN
    varwrkr = bf_trn-doc.wrkr
    varagnt = bf_trn-doc.agnt
    varboss = bf_trn-doc.boss
   .
  display varwrkr varagnt varboss with frame Dialog-Frame.
  find first bf_clients where bf_clients.obj-type = 'чел':U  and
                              bf_clients.obj-code = varwrkr no-lock no-error.
  if available bf_clients then do:
    display bf_clients.obj-name @ varwrkr-name with frame Dialog-Frame.
  end.
  find first bf_clients where bf_clients.obj-type = 'чел':U  and
                              bf_clients.obj-code = varagnt no-lock no-error.
  if available bf_clients then do:
    display bf_clients.obj-name @ varagnt-name with frame Dialog-Frame.
  end.
  find first bf_clients where bf_clients.obj-type = 'чел':U  and
                              bf_clients.obj-code = varboss no-lock no-error.
  if available bf_clients then do:
    display bf_clients.obj-name @ varboss-name with frame Dialog-Frame.
  end.
  define buffer bf_trn-reason for ub.trn-reason  .
  find bf_trn-reason no-lock where
       bf_trn-reason.reason-code = bf_trn-doc.reason-code no-error.
  assign
    varreason-name = ( if available bf_trn-reason then bf_trn-reason.reason-name else "":U )
    varreason-code  = bf_trn-doc.reason-code
  .
  display
  varreason-name
  varreason-code
  with frame Dialog-Frame .
  OPEN QUERY b-goods- FOR EACH bf_doc-line WHERE bf_doc-line.doc-code = bf_trn-doc.doc-code NO-LOCK,           FIRST bf_goods WHERE bf_goods.artic     = bf_doc-line.artic     AND                          bf_goods.prod-type = bf_doc-line.prod-type AND                          bf_goods.prod-code = bf_doc-line.prod-code NO-LOCK,           FIRST bf_parts WHERE bf_parts.out-code  = bf_doc-line.doc-code  AND                          bf_parts.obj-type  = bf_doc-line.obj-type  AND                          bf_parts.obj-code  = bf_doc-line.obj-code  AND                          bf_parts.artic     = bf_doc-line.artic     AND                          bf_parts.prod-type = bf_doc-line.prod-type AND                          bf_parts.prod-code = bf_doc-line.prod-code AND                          bf_parts.fact-qnty < 0 NO-LOCK.
  OPEN QUERY b-goods FOR EACH bf-plus_doc-line WHERE bf-plus_doc-line.doc-code = bf_trn-doc.doc-code NO-LOCK,            FIRST bf-plus_goods WHERE bf-plus_goods.artic     = bf-plus_doc-line.artic     AND                               bf-plus_goods.prod-type = bf-plus_doc-line.prod-type AND                               bf-plus_goods.prod-code = bf-plus_doc-line.prod-code NO-LOCK,            FIRST bf_parts-root WHERE bf_parts-root.doc-code      = bf-plus_doc-line.doc-code AND                               bf_parts-root.gds-code      = bf-plus_goods.gds-code    AND                               bf_parts-root.orig-gds-code = bf_goods.gds-code   NO-LOCK.
end.
END PROCEDURE.
FUNCTION get-deviation-abs-base RETURNS DECIMAL
    ( BUFFER local-doc-line FOR ub.doc-line, BUFFER local-doc-line-plus FOR ub.doc-line ) :
   FIND FIRST tt-doc-line-cashe-plus WHERE tt-doc-line-cashe-plus.doc-code     = local-doc-line.doc-code       AND
                                           tt-doc-line-cashe-plus.wf-artic     = local-doc-line.artic          AND
                                           tt-doc-line-cashe-plus.wf-prod-type = local-doc-line.prod-type      AND
                                           tt-doc-line-cashe-plus.wf-prod-code = local-doc-line.prod-code      and
                                           tt-doc-line-cashe-plus.artic        = local-doc-line-plus.artic     AND
                                           tt-doc-line-cashe-plus.prod-type    = local-doc-line-plus.prod-type AND
                                           tt-doc-line-cashe-plus.prod-code    = local-doc-line-plus.prod-code NO-ERROR.
   IF NOT AVAILABLE tt-doc-line-cashe-plus THEN DO:
     RUN proc-get-write-off in this-procedure (BUFFER local-doc-line).
     FIND FIRST tt-doc-line-cashe-plus WHERE tt-doc-line-cashe-plus.doc-code     = local-doc-line.doc-code       AND
                                             tt-doc-line-cashe-plus.wf-artic     = local-doc-line.artic          AND
                                             tt-doc-line-cashe-plus.wf-prod-type = local-doc-line.prod-type      AND
                                             tt-doc-line-cashe-plus.wf-prod-code = local-doc-line.prod-code      and
                                             tt-doc-line-cashe-plus.artic        = local-doc-line-plus.artic     AND
                                             tt-doc-line-cashe-plus.prod-type    = local-doc-line-plus.prod-type AND
                                             tt-doc-line-cashe-plus.prod-code    = local-doc-line-plus.prod-code .
   END.
   RETURN tt-doc-line-cashe-plus.sum-base - tt-doc-line-cashe-plus.write-off-sum-base.
END FUNCTION.
FUNCTION get-deviation-abs-rubl RETURNS DECIMAL
    ( BUFFER local-doc-line FOR ub.doc-line, BUFFER local-doc-line-plus FOR ub.doc-line ) :
    FIND FIRST tt-doc-line-cashe-plus WHERE tt-doc-line-cashe-plus.doc-code     = local-doc-line.doc-code       AND
                                            tt-doc-line-cashe-plus.wf-artic     = local-doc-line.artic          AND
                                            tt-doc-line-cashe-plus.wf-prod-type = local-doc-line.prod-type      AND
                                            tt-doc-line-cashe-plus.wf-prod-code = local-doc-line.prod-code      and
                                            tt-doc-line-cashe-plus.artic        = local-doc-line-plus.artic     AND
                                            tt-doc-line-cashe-plus.prod-type    = local-doc-line-plus.prod-type AND
                                            tt-doc-line-cashe-plus.prod-code    = local-doc-line-plus.prod-code NO-ERROR.
    IF NOT AVAILABLE tt-doc-line-cashe-plus THEN DO:
      RUN proc-get-write-off in this-procedure (BUFFER local-doc-line).
      FIND FIRST tt-doc-line-cashe-plus WHERE tt-doc-line-cashe-plus.doc-code     = local-doc-line.doc-code       AND
                                              tt-doc-line-cashe-plus.wf-artic     = local-doc-line.artic          AND
                                              tt-doc-line-cashe-plus.wf-prod-type = local-doc-line.prod-type      AND
                                              tt-doc-line-cashe-plus.wf-prod-code = local-doc-line.prod-code      and
                                              tt-doc-line-cashe-plus.artic        = local-doc-line-plus.artic     AND
                                              tt-doc-line-cashe-plus.prod-type    = local-doc-line-plus.prod-type AND
                                              tt-doc-line-cashe-plus.prod-code    = local-doc-line-plus.prod-code .
    END.
    RETURN tt-doc-line-cashe-plus.sum-rubl - tt-doc-line-cashe-plus.write-off-sum-rubl.
END FUNCTION.
FUNCTION get-deviation-percent RETURNS DECIMAL
    ( BUFFER local-doc-line FOR ub.doc-line, BUFFER local-doc-line-plus FOR ub.doc-line ) :
    FIND FIRST tt-doc-line-cashe-plus WHERE tt-doc-line-cashe-plus.doc-code     = local-doc-line.doc-code       AND
                                            tt-doc-line-cashe-plus.wf-artic     = local-doc-line.artic          AND
                                            tt-doc-line-cashe-plus.wf-prod-type = local-doc-line.prod-type      AND
                                            tt-doc-line-cashe-plus.wf-prod-code = local-doc-line.prod-code      and
                                            tt-doc-line-cashe-plus.artic        = local-doc-line-plus.artic     AND
                                            tt-doc-line-cashe-plus.prod-type    = local-doc-line-plus.prod-type AND
                                            tt-doc-line-cashe-plus.prod-code    = local-doc-line-plus.prod-code NO-ERROR.
    IF NOT AVAILABLE tt-doc-line-cashe-plus THEN DO:
      RUN proc-get-write-off in this-procedure (BUFFER local-doc-line).
      FIND FIRST tt-doc-line-cashe-plus WHERE tt-doc-line-cashe-plus.doc-code     = local-doc-line.doc-code       AND
                                              tt-doc-line-cashe-plus.wf-artic     = local-doc-line.artic          AND
                                              tt-doc-line-cashe-plus.wf-prod-type = local-doc-line.prod-type      AND
                                              tt-doc-line-cashe-plus.wf-prod-code = local-doc-line.prod-code      and
                                              tt-doc-line-cashe-plus.artic        = local-doc-line-plus.artic     AND
                                              tt-doc-line-cashe-plus.prod-type    = local-doc-line-plus.prod-type AND
                                              tt-doc-line-cashe-plus.prod-code    = local-doc-line-plus.prod-code .
    END.
    RETURN (tt-doc-line-cashe-plus.sum-rubl - tt-doc-line-cashe-plus.write-off-sum-rubl) / tt-doc-line-cashe-plus.sum-rubl * 100.00.
END FUNCTION.
FUNCTION get-income-qnty RETURNS DECIMAL
  ( BUFFER local-doc-line FOR ub.doc-line, BUFFER local-doc-line-plus FOR ub.doc-line ) :
   FIND FIRST tt-doc-line-cashe-plus WHERE tt-doc-line-cashe-plus.doc-code     = local-doc-line.doc-code       AND
                                           tt-doc-line-cashe-plus.wf-artic     = local-doc-line.artic          AND
                                           tt-doc-line-cashe-plus.wf-prod-type = local-doc-line.prod-type      AND
                                           tt-doc-line-cashe-plus.wf-prod-code = local-doc-line.prod-code      and
                                           tt-doc-line-cashe-plus.artic        = local-doc-line-plus.artic     AND
                                           tt-doc-line-cashe-plus.prod-type    = local-doc-line-plus.prod-type AND
                                           tt-doc-line-cashe-plus.prod-code    = local-doc-line-plus.prod-code NO-ERROR.
   IF NOT AVAILABLE tt-doc-line-cashe-plus THEN DO:
     RUN proc-get-write-off in this-procedure (BUFFER local-doc-line).
     FIND FIRST tt-doc-line-cashe-plus WHERE tt-doc-line-cashe-plus.doc-code     = local-doc-line.doc-code       AND
                                             tt-doc-line-cashe-plus.wf-artic     = local-doc-line.artic          AND
                                             tt-doc-line-cashe-plus.wf-prod-type = local-doc-line.prod-type      AND
                                             tt-doc-line-cashe-plus.wf-prod-code = local-doc-line.prod-code      and
                                             tt-doc-line-cashe-plus.artic        = local-doc-line-plus.artic     AND
                                             tt-doc-line-cashe-plus.prod-type    = local-doc-line-plus.prod-type AND
                                             tt-doc-line-cashe-plus.prod-code    = local-doc-line-plus.prod-code .
   END.
   RETURN tt-doc-line-cashe-plus.qnty.
END FUNCTION.
FUNCTION get-income-sum-base RETURNS DECIMAL
    ( BUFFER local-doc-line FOR ub.doc-line, BUFFER local-doc-line-plus FOR ub.doc-line ) :
     FIND FIRST tt-doc-line-cashe-plus WHERE tt-doc-line-cashe-plus.doc-code     = local-doc-line.doc-code       AND
                                             tt-doc-line-cashe-plus.wf-artic     = local-doc-line.artic          AND
                                             tt-doc-line-cashe-plus.wf-prod-type = local-doc-line.prod-type      AND
                                             tt-doc-line-cashe-plus.wf-prod-code = local-doc-line.prod-code      and
                                             tt-doc-line-cashe-plus.artic        = local-doc-line-plus.artic     AND
                                             tt-doc-line-cashe-plus.prod-type    = local-doc-line-plus.prod-type AND
                                             tt-doc-line-cashe-plus.prod-code    = local-doc-line-plus.prod-code NO-ERROR.
     IF NOT AVAILABLE tt-doc-line-cashe-plus THEN DO:
       RUN proc-get-write-off in this-procedure (BUFFER local-doc-line).
       FIND FIRST tt-doc-line-cashe-plus WHERE tt-doc-line-cashe-plus.doc-code     = local-doc-line.doc-code       AND
                                               tt-doc-line-cashe-plus.wf-artic     = local-doc-line.artic          AND
                                               tt-doc-line-cashe-plus.wf-prod-type = local-doc-line.prod-type      AND
                                               tt-doc-line-cashe-plus.wf-prod-code = local-doc-line.prod-code      and
                                               tt-doc-line-cashe-plus.artic        = local-doc-line-plus.artic     AND
                                               tt-doc-line-cashe-plus.prod-type    = local-doc-line-plus.prod-type AND
                                               tt-doc-line-cashe-plus.prod-code    = local-doc-line-plus.prod-code .
     END.
     RETURN tt-doc-line-cashe-plus.sum-base.
END FUNCTION.
FUNCTION get-income-sum-rubl RETURNS DECIMAL
    ( BUFFER local-doc-line FOR ub.doc-line, BUFFER local-doc-line-plus FOR ub.doc-line ) :
     FIND FIRST tt-doc-line-cashe-plus WHERE tt-doc-line-cashe-plus.doc-code     = local-doc-line.doc-code       AND
                                             tt-doc-line-cashe-plus.wf-artic     = local-doc-line.artic          AND
                                             tt-doc-line-cashe-plus.wf-prod-type = local-doc-line.prod-type      AND
                                             tt-doc-line-cashe-plus.wf-prod-code = local-doc-line.prod-code      and
                                             tt-doc-line-cashe-plus.artic        = local-doc-line-plus.artic     AND
                                             tt-doc-line-cashe-plus.prod-type    = local-doc-line-plus.prod-type AND
                                             tt-doc-line-cashe-plus.prod-code    = local-doc-line-plus.prod-code NO-ERROR.
     IF NOT AVAILABLE tt-doc-line-cashe-plus THEN DO:
       RUN proc-get-write-off in this-procedure (BUFFER local-doc-line).
       FIND FIRST tt-doc-line-cashe-plus WHERE tt-doc-line-cashe-plus.doc-code     = local-doc-line.doc-code       AND
                                               tt-doc-line-cashe-plus.wf-artic     = local-doc-line.artic          AND
                                               tt-doc-line-cashe-plus.wf-prod-type = local-doc-line.prod-type      AND
                                               tt-doc-line-cashe-plus.wf-prod-code = local-doc-line.prod-code      and
                                               tt-doc-line-cashe-plus.artic        = local-doc-line-plus.artic     AND
                                               tt-doc-line-cashe-plus.prod-type    = local-doc-line-plus.prod-type AND
                                               tt-doc-line-cashe-plus.prod-code    = local-doc-line-plus.prod-code .
     END.
     RETURN tt-doc-line-cashe-plus.sum-rubl.
END FUNCTION.
FUNCTION get-income-vat-base RETURNS DECIMAL
    ( BUFFER local-doc-line FOR ub.doc-line, BUFFER local-doc-line-plus FOR ub.doc-line ) :
     FIND FIRST tt-doc-line-cashe-plus WHERE tt-doc-line-cashe-plus.doc-code     = local-doc-line.doc-code       AND
                                             tt-doc-line-cashe-plus.wf-artic     = local-doc-line.artic          AND
                                             tt-doc-line-cashe-plus.wf-prod-type = local-doc-line.prod-type      AND
                                             tt-doc-line-cashe-plus.wf-prod-code = local-doc-line.prod-code      and
                                             tt-doc-line-cashe-plus.artic        = local-doc-line-plus.artic     AND
                                             tt-doc-line-cashe-plus.prod-type    = local-doc-line-plus.prod-type AND
                                             tt-doc-line-cashe-plus.prod-code    = local-doc-line-plus.prod-code NO-ERROR.
     IF NOT AVAILABLE tt-doc-line-cashe-plus THEN DO:
       RUN proc-get-write-off in this-procedure (BUFFER local-doc-line).
       FIND FIRST tt-doc-line-cashe-plus WHERE tt-doc-line-cashe-plus.doc-code     = local-doc-line.doc-code       AND
                                               tt-doc-line-cashe-plus.wf-artic     = local-doc-line.artic          AND
                                               tt-doc-line-cashe-plus.wf-prod-type = local-doc-line.prod-type      AND
                                               tt-doc-line-cashe-plus.wf-prod-code = local-doc-line.prod-code      and
                                               tt-doc-line-cashe-plus.artic        = local-doc-line-plus.artic     AND
                                               tt-doc-line-cashe-plus.prod-type    = local-doc-line-plus.prod-type AND
                                               tt-doc-line-cashe-plus.prod-code    = local-doc-line-plus.prod-code .
     END.
     RETURN tt-doc-line-cashe-plus.vat-base.
END FUNCTION.
FUNCTION get-income-vat-rubl RETURNS DECIMAL
    ( BUFFER local-doc-line FOR ub.doc-line, BUFFER local-doc-line-plus FOR ub.doc-line ) :
     FIND FIRST tt-doc-line-cashe-plus WHERE tt-doc-line-cashe-plus.doc-code     = local-doc-line.doc-code       AND
                                             tt-doc-line-cashe-plus.wf-artic     = local-doc-line.artic          AND
                                             tt-doc-line-cashe-plus.wf-prod-type = local-doc-line.prod-type      AND
                                             tt-doc-line-cashe-plus.wf-prod-code = local-doc-line.prod-code      and
                                             tt-doc-line-cashe-plus.artic        = local-doc-line-plus.artic     AND
                                             tt-doc-line-cashe-plus.prod-type    = local-doc-line-plus.prod-type AND
                                             tt-doc-line-cashe-plus.prod-code    = local-doc-line-plus.prod-code NO-ERROR.
     IF NOT AVAILABLE tt-doc-line-cashe-plus THEN DO:
       RUN proc-get-write-off in this-procedure (BUFFER local-doc-line).
       FIND FIRST tt-doc-line-cashe-plus WHERE tt-doc-line-cashe-plus.doc-code     = local-doc-line.doc-code       AND
                                               tt-doc-line-cashe-plus.wf-artic     = local-doc-line.artic          AND
                                               tt-doc-line-cashe-plus.wf-prod-type = local-doc-line.prod-type      AND
                                               tt-doc-line-cashe-plus.wf-prod-code = local-doc-line.prod-code      and
                                               tt-doc-line-cashe-plus.artic        = local-doc-line-plus.artic     AND
                                               tt-doc-line-cashe-plus.prod-type    = local-doc-line-plus.prod-type AND
                                               tt-doc-line-cashe-plus.prod-code    = local-doc-line-plus.prod-code .
     END.
     RETURN tt-doc-line-cashe-plus.vat-rubl.
END FUNCTION.
FUNCTION get-mark RETURNS CHARACTER
  (buffer local-doc-line for ub.doc-line) :
find first tt-del-list where tt-del-list.rec-id = recid (local-doc-line) no-error.
if available tt-del-list then do:
  return "*".
end.
else do:
  return "".
end.
END FUNCTION.
FUNCTION get-price RETURNS DECIMAL
(BUFFER local-goods FOR ub.goods):
DEFINE BUFFER bf-fnc_gds-dtl      FOR ub.gds-dtl.
DEFINE BUFFER bf-fnc-spec_gds-dtl FOR ub.gds-dtl.
DEFINE BUFFER bf-fnc_gds-prt      FOR ub.gds-prt.
DEFINE VARIABLE varqnty AS DECIMAL NO-UNDO.
DEFINE VARIABLE varsum  AS DECIMAL NO-UNDO.
FIND FIRST bf-fnc_gds-dtl WHERE bf-fnc_gds-dtl.doc-code   = bf_trn-doc.doc-code   AND
                                bf-fnc_gds-dtl.artic      = local-goods.artic     AND
                                bf-fnc_gds-dtl.prod-type  = local-goods.prod-type AND
                                bf-fnc_gds-dtl.prod-code  = local-goods.prod-code NO-LOCK.
find first bf-fnc_gds-prt where bf-fnc_gds-prt.upper-code = local-goods.prt-root no-lock.
if bf-fnc_gds-prt.node-name = '_Пустая шкала':U then do:
  IF varr-b = "rubl" THEN DO:
    RETURN bf-fnc_gds-dtl.price-rubl.
  END.
  ELSE DO:
    RETURN bf-fnc_gds-dtl.price-base.
  END.
END.
ELSE DO:
  FIND FIRST bf-fnc-spec_gds-dtl WHERE bf-fnc-spec_gds-dtl.doc-code    = bf_trn-doc.doc-code   AND
                                       bf-fnc-spec_gds-dtl.artic       = local-goods.artic     AND
                                       bf-fnc-spec_gds-dtl.prod-type   = local-goods.prod-type AND
                                       bf-fnc-spec_gds-dtl.prod-code   = local-goods.prod-code AND
                                       bf-fnc-spec_gds-dtl.price-rubl <> bf-fnc_gds-dtl.price-rubl NO-LOCK NO-ERROR.
  IF NOT AVAILABLE bf-fnc-spec_gds-dtl THEN DO:
    IF varr-b = "rubl" THEN DO:
      RETURN bf-fnc_gds-dtl.price-rubl.
    END.
    ELSE DO:
      RETURN bf-fnc_gds-dtl.price-base.
    END.
  END.
  ELSE DO:
    ASSIGN
      varqnty = 0.00
      varsum  = 0.00.
    FOR EACH bf-fnc_gds-dtl WHERE bf-fnc_gds-dtl.doc-code   = bf_trn-doc.doc-code   AND
                                  bf-fnc_gds-dtl.artic      = local-goods.artic     AND
                                  bf-fnc_gds-dtl.prod-type  = local-goods.prod-type AND
                                  bf-fnc_gds-dtl.prod-code  = local-goods.prod-code NO-LOCK :
      ASSIGN
        varqnty = VARqnty + bf-fnc_gds-dtl.fact-qnty
        varsum  = varsum + (IF varr-b = "rubl" THEN bf-fnc_gds-dtl.price-rubl ELSE bf-fnc_gds-dtl.price-base) * bf-fnc_gds-dtl.fact-qnty.
    END.
    RETURN ABS (varsum / varqnty).
  END.
END.
END FUNCTION.
FUNCTION get-write-off-for-income-qnty RETURNS DECIMAL
    ( BUFFER local-doc-line FOR ub.doc-line, BUFFER local-doc-line-plus FOR ub.doc-line ) :
    FIND FIRST tt-doc-line-cashe-plus WHERE tt-doc-line-cashe-plus.doc-code     = local-doc-line.doc-code       AND
                                            tt-doc-line-cashe-plus.wf-artic     = local-doc-line.artic          AND
                                            tt-doc-line-cashe-plus.wf-prod-type = local-doc-line.prod-type      AND
                                            tt-doc-line-cashe-plus.wf-prod-code = local-doc-line.prod-code      and
                                            tt-doc-line-cashe-plus.artic        = local-doc-line-plus.artic     AND
                                            tt-doc-line-cashe-plus.prod-type    = local-doc-line-plus.prod-type AND
                                            tt-doc-line-cashe-plus.prod-code    = local-doc-line-plus.prod-code NO-ERROR.
    IF NOT AVAILABLE tt-doc-line-cashe-plus THEN DO:
      RUN proc-get-write-off in this-procedure (BUFFER local-doc-line).
      FIND FIRST tt-doc-line-cashe-plus WHERE tt-doc-line-cashe-plus.doc-code     = local-doc-line.doc-code       AND
                                              tt-doc-line-cashe-plus.wf-artic     = local-doc-line.artic          AND
                                              tt-doc-line-cashe-plus.wf-prod-type = local-doc-line.prod-type      AND
                                              tt-doc-line-cashe-plus.wf-prod-code = local-doc-line.prod-code      and
                                              tt-doc-line-cashe-plus.artic        = local-doc-line-plus.artic     AND
                                              tt-doc-line-cashe-plus.prod-type    = local-doc-line-plus.prod-type AND
                                              tt-doc-line-cashe-plus.prod-code    = local-doc-line-plus.prod-code .
    END.
    RETURN tt-doc-line-cashe-plus.write-off-qnty.
END FUNCTION.
FUNCTION get-write-off-qnty RETURNS DECIMAL
  ( buffer local-doc-line for ub.doc-line ) :
      FIND FIRST tt-doc-line-cashe WHERE tt-doc-line-cashe.doc-code  = local-doc-line.doc-code  AND
                                         tt-doc-line-cashe.artic     = local-doc-line.artic     AND
                                         tt-doc-line-cashe.prod-type = local-doc-line.prod-type AND
                                         tt-doc-line-cashe.prod-code = local-doc-line.prod-code NO-ERROR.
      IF NOT AVAILABLE tt-doc-line-cashe THEN DO:
        RUN proc-get-write-off in this-procedure (BUFFER local-doc-line).
        FIND FIRST tt-doc-line-cashe WHERE tt-doc-line-cashe.doc-code  = local-doc-line.doc-code  AND
                                           tt-doc-line-cashe.artic     = local-doc-line.artic     AND
                                           tt-doc-line-cashe.prod-type = local-doc-line.prod-type AND
                                           tt-doc-line-cashe.prod-code = local-doc-line.prod-code .
      END.
      RETURN tt-doc-line-cashe.qnty.
END FUNCTION.
FUNCTION get-write-off-sum-base RETURNS DECIMAL
  ( buffer local-doc-line for ub.doc-line ) :
      FIND FIRST tt-doc-line-cashe WHERE tt-doc-line-cashe.doc-code  = local-doc-line.doc-code  AND
                                         tt-doc-line-cashe.artic     = local-doc-line.artic     AND
                                         tt-doc-line-cashe.prod-type = local-doc-line.prod-type AND
                                         tt-doc-line-cashe.prod-code = local-doc-line.prod-code NO-ERROR.
      IF NOT AVAILABLE tt-doc-line-cashe THEN DO:
        RUN proc-get-write-off in this-procedure (BUFFER local-doc-line).
        FIND FIRST tt-doc-line-cashe WHERE tt-doc-line-cashe.doc-code  = local-doc-line.doc-code  AND
                                           tt-doc-line-cashe.artic     = local-doc-line.artic     AND
                                           tt-doc-line-cashe.prod-type = local-doc-line.prod-type AND
                                           tt-doc-line-cashe.prod-code = local-doc-line.prod-code .
      END.
      RETURN tt-doc-line-cashe.sum-base.
END FUNCTION.
FUNCTION get-write-off-sum-rubl RETURNS DECIMAL
  ( buffer local-doc-line for ub.doc-line ) :
      FIND FIRST tt-doc-line-cashe WHERE tt-doc-line-cashe.doc-code  = local-doc-line.doc-code  AND
                                         tt-doc-line-cashe.artic     = local-doc-line.artic     AND
                                         tt-doc-line-cashe.prod-type = local-doc-line.prod-type AND
                                         tt-doc-line-cashe.prod-code = local-doc-line.prod-code NO-ERROR.
      IF NOT AVAILABLE tt-doc-line-cashe THEN DO:
        RUN proc-get-write-off in this-procedure (BUFFER local-doc-line).
        FIND FIRST tt-doc-line-cashe WHERE tt-doc-line-cashe.doc-code  = local-doc-line.doc-code  AND
                                           tt-doc-line-cashe.artic     = local-doc-line.artic     AND
                                           tt-doc-line-cashe.prod-type = local-doc-line.prod-type AND
                                           tt-doc-line-cashe.prod-code = local-doc-line.prod-code .
      END.
      RETURN tt-doc-line-cashe.sum-rubl.
END FUNCTION.
FUNCTION get-write-off-vat-base RETURNS DECIMAL
  ( buffer local-doc-line for ub.doc-line ) :
      FIND FIRST tt-doc-line-cashe WHERE tt-doc-line-cashe.doc-code  = local-doc-line.doc-code  AND
                                         tt-doc-line-cashe.artic     = local-doc-line.artic     AND
                                         tt-doc-line-cashe.prod-type = local-doc-line.prod-type AND
                                         tt-doc-line-cashe.prod-code = local-doc-line.prod-code NO-ERROR.
      IF NOT AVAILABLE tt-doc-line-cashe THEN DO:
        RUN proc-get-write-off in this-procedure (BUFFER local-doc-line).
        FIND FIRST tt-doc-line-cashe WHERE tt-doc-line-cashe.doc-code  = local-doc-line.doc-code  AND
                                           tt-doc-line-cashe.artic     = local-doc-line.artic     AND
                                           tt-doc-line-cashe.prod-type = local-doc-line.prod-type AND
                                           tt-doc-line-cashe.prod-code = local-doc-line.prod-code .
       END.
       RETURN tt-doc-line-cashe.vat-base.
END FUNCTION.
FUNCTION get-write-off-vat-rubl RETURNS DECIMAL
  ( buffer local-doc-line for ub.doc-line ) :
      FIND FIRST tt-doc-line-cashe WHERE tt-doc-line-cashe.doc-code  = local-doc-line.doc-code  AND
                                         tt-doc-line-cashe.artic     = local-doc-line.artic     AND
                                         tt-doc-line-cashe.prod-type = local-doc-line.prod-type AND
                                         tt-doc-line-cashe.prod-code = local-doc-line.prod-code NO-ERROR.
      IF NOT AVAILABLE tt-doc-line-cashe THEN DO:
        RUN proc-get-write-off in this-procedure (BUFFER local-doc-line).
        FIND FIRST tt-doc-line-cashe WHERE tt-doc-line-cashe.doc-code  = local-doc-line.doc-code  AND
                                           tt-doc-line-cashe.artic     = local-doc-line.artic     AND
                                           tt-doc-line-cashe.prod-type = local-doc-line.prod-type AND
                                           tt-doc-line-cashe.prod-code = local-doc-line.prod-code .
      END.
      RETURN tt-doc-line-cashe.vat-rubl.
END FUNCTION.
