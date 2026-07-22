block-level on error undo, throw.
define input parameter rec-id     as recid     no-undo.
define input parameter use-table  as character no-undo.
define input parameter mes-on     as logical   no-undo.
define input parameter inv-type   as integer   no-undo.
define input parameter is-wait-on as logical   no-undo.
define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U.
define variable vss-author      as character no-undo initial "$Author: expertek $":U.
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U.
define variable vss-workfile    as character no-undo initial "$Workfile: calc-sup.p $":U.
define variable vss-archive     as character no-undo initial "$Archive: str/calc-sup.p $":U.
define variable vss-description as character no-undo initial "Определение сумм по документу по различным разбиениям ":U.
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
    assign
      p-vss-parameters = substitute('&1|&2|&3|&4|5',rec-id,use-table,mes-on,inv-type,is-wait-on)
    .
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
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#trdcalib as handle no-undo.
def var vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  if     not mWaitFramView
     and mWaitProcEvent
  then
    process events .
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
    if     mWaitFramView
       then do:
          if     mWaitFramInterval ne ?
             and not mBatchMode
          then
             wait-for go of frame waitfram pause mWaitFramInterval.
       end.
       else
          if     mWaitProcEvent
             and not mBatchMode
          then
             process events .
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
define  shared temp-table tt-title no-undo
  field purch-code like ub.parts.purch-code
  field purch-name as   character
  field fact-qnty           like ub.doc-line.price-rubl                        field acc-base            like ub.doc-line.price-rubl                        field acc-rubl            like ub.doc-line.price-rubl                        field acc-vat-base        like ub.doc-line.price-rubl                        field acc-vat-rubl        like ub.doc-line.price-rubl                        field acc-slt-base        like ub.doc-line.price-rubl                        field acc-slt-rubl        like ub.doc-line.price-rubl                        field acc-road-tax-base   like ub.doc-line.price-rubl                        field acc-road-tax-rubl   like ub.doc-line.price-rubl                        field acc-excise-base     like ub.doc-line.price-rubl                        field acc-excise-rubl     like ub.doc-line.price-rubl                        field acc-transport-base  like ub.doc-line.price-rubl                        field acc-transport-rubl  like ub.doc-line.price-rubl                        field acc-other-base      like ub.doc-line.price-rubl                        field acc-other-rubl      like ub.doc-line.price-rubl                        field pay-base            like ub.doc-line.price-rubl                        field pay-rubl            like ub.doc-line.price-rubl                        field no-vat-base         like ub.doc-line.price-rubl                        field no-vat-rubl         like ub.doc-line.price-rubl                        field vat-base            like ub.doc-line.price-rubl                        field vat-rubl            like ub.doc-line.price-rubl                        field vat-base-buyer      like ub.doc-line.price-rubl                        field vat-rubl-buyer      like ub.doc-line.price-rubl                        field slt-base            like ub.doc-line.price-rubl                        field slt-rubl            like ub.doc-line.price-rubl                        field road-tax            like ub.doc-line.price-rubl                        field excise              like ub.doc-line.price-rubl                        field sale-base           like ub.doc-line.price-rubl                        field sale-rubl           like ub.doc-line.price-rubl                        field sale-vat-base       like ub.doc-line.price-rubl                        field sale-vat-rubl       like ub.doc-line.price-rubl                        field sale-vat-buyer-base like ub.doc-line.price-rubl                        field sale-vat-buyer-rubl like ub.doc-line.price-rubl                        field sale-slt-base       like ub.doc-line.price-rubl                        field sale-slt-rubl       like ub.doc-line.price-rubl                        field sale-road-tax-base  like ub.doc-line.price-rubl                        field sale-road-tax-rubl  like ub.doc-line.price-rubl                        field sale-excise-base    like ub.doc-line.price-rubl                        field sale-excise-rubl    like ub.doc-line.price-rubl                        field ov-base             like ub.doc-line.price-rubl                        field ov-vat              like ub.doc-line.price-rubl
  index purch-code is   primary unique purch-code
.
define  shared temp-table d-supp no-undo
  field purch-code like ub.parts.purch-code
  field purch-name as   character
  field supp-name  like ub.clients.obj-name
  field supp-type  like ub.parts.supp-type
  field supp-code  like ub.parts.supp-code
  field fact-qnty           like ub.doc-line.price-rubl                        field acc-base            like ub.doc-line.price-rubl                        field acc-rubl            like ub.doc-line.price-rubl                        field acc-vat-base        like ub.doc-line.price-rubl                        field acc-vat-rubl        like ub.doc-line.price-rubl                        field acc-slt-base        like ub.doc-line.price-rubl                        field acc-slt-rubl        like ub.doc-line.price-rubl                        field acc-road-tax-base   like ub.doc-line.price-rubl                        field acc-road-tax-rubl   like ub.doc-line.price-rubl                        field acc-excise-base     like ub.doc-line.price-rubl                        field acc-excise-rubl     like ub.doc-line.price-rubl                        field acc-transport-base  like ub.doc-line.price-rubl                        field acc-transport-rubl  like ub.doc-line.price-rubl                        field acc-other-base      like ub.doc-line.price-rubl                        field acc-other-rubl      like ub.doc-line.price-rubl                        field pay-base            like ub.doc-line.price-rubl                        field pay-rubl            like ub.doc-line.price-rubl                        field no-vat-base         like ub.doc-line.price-rubl                        field no-vat-rubl         like ub.doc-line.price-rubl                        field vat-base            like ub.doc-line.price-rubl                        field vat-rubl            like ub.doc-line.price-rubl                        field vat-base-buyer      like ub.doc-line.price-rubl                        field vat-rubl-buyer      like ub.doc-line.price-rubl                        field slt-base            like ub.doc-line.price-rubl                        field slt-rubl            like ub.doc-line.price-rubl                        field road-tax            like ub.doc-line.price-rubl                        field excise              like ub.doc-line.price-rubl                        field sale-base           like ub.doc-line.price-rubl                        field sale-rubl           like ub.doc-line.price-rubl                        field sale-vat-base       like ub.doc-line.price-rubl                        field sale-vat-rubl       like ub.doc-line.price-rubl                        field sale-vat-buyer-base like ub.doc-line.price-rubl                        field sale-vat-buyer-rubl like ub.doc-line.price-rubl                        field sale-slt-base       like ub.doc-line.price-rubl                        field sale-slt-rubl       like ub.doc-line.price-rubl                        field sale-road-tax-base  like ub.doc-line.price-rubl                        field sale-road-tax-rubl  like ub.doc-line.price-rubl                        field sale-excise-base    like ub.doc-line.price-rubl                        field sale-excise-rubl    like ub.doc-line.price-rubl                        field ov-base             like ub.doc-line.price-rubl                        field ov-vat              like ub.doc-line.price-rubl
  index supp       is   primary unique supp-type supp-code purch-code
  index i2                                                 purch-code
.
define  shared temp-table d-supp-grp no-undo
  field supp-type  like ub.parts.supp-type
  field supp-code  like ub.parts.supp-code
  field purch-code like ub.parts.purch-code
  field grp-code   like ub.goods.grp-code
  field purch-name as   character
  field supp-name  like ub.clients.obj-name
  field grp-name   like ub.gds-grp.node-name
  field fact-qnty           like ub.doc-line.price-rubl                        field acc-base            like ub.doc-line.price-rubl                        field acc-rubl            like ub.doc-line.price-rubl                        field acc-vat-base        like ub.doc-line.price-rubl                        field acc-vat-rubl        like ub.doc-line.price-rubl                        field acc-slt-base        like ub.doc-line.price-rubl                        field acc-slt-rubl        like ub.doc-line.price-rubl                        field acc-road-tax-base   like ub.doc-line.price-rubl                        field acc-road-tax-rubl   like ub.doc-line.price-rubl                        field acc-excise-base     like ub.doc-line.price-rubl                        field acc-excise-rubl     like ub.doc-line.price-rubl                        field acc-transport-base  like ub.doc-line.price-rubl                        field acc-transport-rubl  like ub.doc-line.price-rubl                        field acc-other-base      like ub.doc-line.price-rubl                        field acc-other-rubl      like ub.doc-line.price-rubl                        field pay-base            like ub.doc-line.price-rubl                        field pay-rubl            like ub.doc-line.price-rubl                        field no-vat-base         like ub.doc-line.price-rubl                        field no-vat-rubl         like ub.doc-line.price-rubl                        field vat-base            like ub.doc-line.price-rubl                        field vat-rubl            like ub.doc-line.price-rubl                        field vat-base-buyer      like ub.doc-line.price-rubl                        field vat-rubl-buyer      like ub.doc-line.price-rubl                        field slt-base            like ub.doc-line.price-rubl                        field slt-rubl            like ub.doc-line.price-rubl                        field road-tax            like ub.doc-line.price-rubl                        field excise              like ub.doc-line.price-rubl                        field sale-base           like ub.doc-line.price-rubl                        field sale-rubl           like ub.doc-line.price-rubl                        field sale-vat-base       like ub.doc-line.price-rubl                        field sale-vat-rubl       like ub.doc-line.price-rubl                        field sale-vat-buyer-base like ub.doc-line.price-rubl                        field sale-vat-buyer-rubl like ub.doc-line.price-rubl                        field sale-slt-base       like ub.doc-line.price-rubl                        field sale-slt-rubl       like ub.doc-line.price-rubl                        field sale-road-tax-base  like ub.doc-line.price-rubl                        field sale-road-tax-rubl  like ub.doc-line.price-rubl                        field sale-excise-base    like ub.doc-line.price-rubl                        field sale-excise-rubl    like ub.doc-line.price-rubl                        field ov-base             like ub.doc-line.price-rubl                        field ov-vat              like ub.doc-line.price-rubl
  index supp       is   primary unique supp-type supp-code purch-code grp-code
  index i2                                                 purch-code
.
define  shared temp-table d-slt-vat no-undo
  field vat-pc  like ub.doc-line.vat-pc
  field slt-pc  like ub.doc-line.slt-pc
  field fact-qnty           like ub.doc-line.price-rubl                        field acc-base            like ub.doc-line.price-rubl                        field acc-rubl            like ub.doc-line.price-rubl                        field acc-vat-base        like ub.doc-line.price-rubl                        field acc-vat-rubl        like ub.doc-line.price-rubl                        field acc-slt-base        like ub.doc-line.price-rubl                        field acc-slt-rubl        like ub.doc-line.price-rubl                        field acc-road-tax-base   like ub.doc-line.price-rubl                        field acc-road-tax-rubl   like ub.doc-line.price-rubl                        field acc-excise-base     like ub.doc-line.price-rubl                        field acc-excise-rubl     like ub.doc-line.price-rubl                        field acc-transport-base  like ub.doc-line.price-rubl                        field acc-transport-rubl  like ub.doc-line.price-rubl                        field acc-other-base      like ub.doc-line.price-rubl                        field acc-other-rubl      like ub.doc-line.price-rubl                        field pay-base            like ub.doc-line.price-rubl                        field pay-rubl            like ub.doc-line.price-rubl                        field no-vat-base         like ub.doc-line.price-rubl                        field no-vat-rubl         like ub.doc-line.price-rubl                        field vat-base            like ub.doc-line.price-rubl                        field vat-rubl            like ub.doc-line.price-rubl                        field vat-base-buyer      like ub.doc-line.price-rubl                        field vat-rubl-buyer      like ub.doc-line.price-rubl                        field slt-base            like ub.doc-line.price-rubl                        field slt-rubl            like ub.doc-line.price-rubl                        field road-tax            like ub.doc-line.price-rubl                        field excise              like ub.doc-line.price-rubl                        field sale-base           like ub.doc-line.price-rubl                        field sale-rubl           like ub.doc-line.price-rubl                        field sale-vat-base       like ub.doc-line.price-rubl                        field sale-vat-rubl       like ub.doc-line.price-rubl                        field sale-vat-buyer-base like ub.doc-line.price-rubl                        field sale-vat-buyer-rubl like ub.doc-line.price-rubl                        field sale-slt-base       like ub.doc-line.price-rubl                        field sale-slt-rubl       like ub.doc-line.price-rubl                        field sale-road-tax-base  like ub.doc-line.price-rubl                        field sale-road-tax-rubl  like ub.doc-line.price-rubl                        field sale-excise-base    like ub.doc-line.price-rubl                        field sale-excise-rubl    like ub.doc-line.price-rubl                        field ov-base             like ub.doc-line.price-rubl                        field ov-vat              like ub.doc-line.price-rubl
  index vat-slt is   primary unique vat-pc slt-pc
.
define  shared temp-table d-slt-vat-cons no-undo
  field vat-pc        like ub.doc-line.vat-pc
  field slt-pc        like ub.doc-line.slt-pc
  field purch-code    like ub.parts.purch-code
  field purch-name    as   character
  field fact-qnty           like ub.doc-line.price-rubl                        field acc-base            like ub.doc-line.price-rubl                        field acc-rubl            like ub.doc-line.price-rubl                        field acc-vat-base        like ub.doc-line.price-rubl                        field acc-vat-rubl        like ub.doc-line.price-rubl                        field acc-slt-base        like ub.doc-line.price-rubl                        field acc-slt-rubl        like ub.doc-line.price-rubl                        field acc-road-tax-base   like ub.doc-line.price-rubl                        field acc-road-tax-rubl   like ub.doc-line.price-rubl                        field acc-excise-base     like ub.doc-line.price-rubl                        field acc-excise-rubl     like ub.doc-line.price-rubl                        field acc-transport-base  like ub.doc-line.price-rubl                        field acc-transport-rubl  like ub.doc-line.price-rubl                        field acc-other-base      like ub.doc-line.price-rubl                        field acc-other-rubl      like ub.doc-line.price-rubl                        field pay-base            like ub.doc-line.price-rubl                        field pay-rubl            like ub.doc-line.price-rubl                        field no-vat-base         like ub.doc-line.price-rubl                        field no-vat-rubl         like ub.doc-line.price-rubl                        field vat-base            like ub.doc-line.price-rubl                        field vat-rubl            like ub.doc-line.price-rubl                        field vat-base-buyer      like ub.doc-line.price-rubl                        field vat-rubl-buyer      like ub.doc-line.price-rubl                        field slt-base            like ub.doc-line.price-rubl                        field slt-rubl            like ub.doc-line.price-rubl                        field road-tax            like ub.doc-line.price-rubl                        field excise              like ub.doc-line.price-rubl                        field sale-base           like ub.doc-line.price-rubl                        field sale-rubl           like ub.doc-line.price-rubl                        field sale-vat-base       like ub.doc-line.price-rubl                        field sale-vat-rubl       like ub.doc-line.price-rubl                        field sale-vat-buyer-base like ub.doc-line.price-rubl                        field sale-vat-buyer-rubl like ub.doc-line.price-rubl                        field sale-slt-base       like ub.doc-line.price-rubl                        field sale-slt-rubl       like ub.doc-line.price-rubl                        field sale-road-tax-base  like ub.doc-line.price-rubl                        field sale-road-tax-rubl  like ub.doc-line.price-rubl                        field sale-excise-base    like ub.doc-line.price-rubl                        field sale-excise-rubl    like ub.doc-line.price-rubl                        field ov-base             like ub.doc-line.price-rubl                        field ov-vat              like ub.doc-line.price-rubl
  index vat-slt-purch is   primary   unique vat-pc slt-pc purch-code
.
define  shared temp-table d-slt-vat-cons-grp no-undo
  field vat-pc        like ub.doc-line.vat-pc
  field slt-pc        like ub.doc-line.slt-pc
  field purch-code    like ub.parts.purch-code
  field purch-name    as   character
  field grp-code      like ub.goods.grp-code
  field grp-name      like ub.gds-grp.node-name
  field fact-qnty           like ub.doc-line.price-rubl                        field acc-base            like ub.doc-line.price-rubl                        field acc-rubl            like ub.doc-line.price-rubl                        field acc-vat-base        like ub.doc-line.price-rubl                        field acc-vat-rubl        like ub.doc-line.price-rubl                        field acc-slt-base        like ub.doc-line.price-rubl                        field acc-slt-rubl        like ub.doc-line.price-rubl                        field acc-road-tax-base   like ub.doc-line.price-rubl                        field acc-road-tax-rubl   like ub.doc-line.price-rubl                        field acc-excise-base     like ub.doc-line.price-rubl                        field acc-excise-rubl     like ub.doc-line.price-rubl                        field acc-transport-base  like ub.doc-line.price-rubl                        field acc-transport-rubl  like ub.doc-line.price-rubl                        field acc-other-base      like ub.doc-line.price-rubl                        field acc-other-rubl      like ub.doc-line.price-rubl                        field pay-base            like ub.doc-line.price-rubl                        field pay-rubl            like ub.doc-line.price-rubl                        field no-vat-base         like ub.doc-line.price-rubl                        field no-vat-rubl         like ub.doc-line.price-rubl                        field vat-base            like ub.doc-line.price-rubl                        field vat-rubl            like ub.doc-line.price-rubl                        field vat-base-buyer      like ub.doc-line.price-rubl                        field vat-rubl-buyer      like ub.doc-line.price-rubl                        field slt-base            like ub.doc-line.price-rubl                        field slt-rubl            like ub.doc-line.price-rubl                        field road-tax            like ub.doc-line.price-rubl                        field excise              like ub.doc-line.price-rubl                        field sale-base           like ub.doc-line.price-rubl                        field sale-rubl           like ub.doc-line.price-rubl                        field sale-vat-base       like ub.doc-line.price-rubl                        field sale-vat-rubl       like ub.doc-line.price-rubl                        field sale-vat-buyer-base like ub.doc-line.price-rubl                        field sale-vat-buyer-rubl like ub.doc-line.price-rubl                        field sale-slt-base       like ub.doc-line.price-rubl                        field sale-slt-rubl       like ub.doc-line.price-rubl                        field sale-road-tax-base  like ub.doc-line.price-rubl                        field sale-road-tax-rubl  like ub.doc-line.price-rubl                        field sale-excise-base    like ub.doc-line.price-rubl                        field sale-excise-rubl    like ub.doc-line.price-rubl                        field ov-base             like ub.doc-line.price-rubl                        field ov-vat              like ub.doc-line.price-rubl
  index vat-slt-purch is   primary   unique vat-pc slt-pc purch-code grp-code
.
define  shared temp-table d-supp-slts-vats-cons no-undo
  field supp-type  like ub.parts.supp-type
  field supp-code  like ub.parts.supp-code
  field supp-name  like ub.clients.obj-name
  field vat-pc     like ub.parts.vat-pc
  field slt-pc     like ub.parts.slt-pc
  field purch-code like ub.parts.purch-code
  field purch-name as   character
  field fact-qnty           like ub.doc-line.price-rubl                        field acc-base            like ub.doc-line.price-rubl                        field acc-rubl            like ub.doc-line.price-rubl                        field acc-vat-base        like ub.doc-line.price-rubl                        field acc-vat-rubl        like ub.doc-line.price-rubl                        field acc-slt-base        like ub.doc-line.price-rubl                        field acc-slt-rubl        like ub.doc-line.price-rubl                        field acc-road-tax-base   like ub.doc-line.price-rubl                        field acc-road-tax-rubl   like ub.doc-line.price-rubl                        field acc-excise-base     like ub.doc-line.price-rubl                        field acc-excise-rubl     like ub.doc-line.price-rubl                        field acc-transport-base  like ub.doc-line.price-rubl                        field acc-transport-rubl  like ub.doc-line.price-rubl                        field acc-other-base      like ub.doc-line.price-rubl                        field acc-other-rubl      like ub.doc-line.price-rubl                        field pay-base            like ub.doc-line.price-rubl                        field pay-rubl            like ub.doc-line.price-rubl                        field no-vat-base         like ub.doc-line.price-rubl                        field no-vat-rubl         like ub.doc-line.price-rubl                        field vat-base            like ub.doc-line.price-rubl                        field vat-rubl            like ub.doc-line.price-rubl                        field vat-base-buyer      like ub.doc-line.price-rubl                        field vat-rubl-buyer      like ub.doc-line.price-rubl                        field slt-base            like ub.doc-line.price-rubl                        field slt-rubl            like ub.doc-line.price-rubl                        field road-tax            like ub.doc-line.price-rubl                        field excise              like ub.doc-line.price-rubl                        field sale-base           like ub.doc-line.price-rubl                        field sale-rubl           like ub.doc-line.price-rubl                        field sale-vat-base       like ub.doc-line.price-rubl                        field sale-vat-rubl       like ub.doc-line.price-rubl                        field sale-vat-buyer-base like ub.doc-line.price-rubl                        field sale-vat-buyer-rubl like ub.doc-line.price-rubl                        field sale-slt-base       like ub.doc-line.price-rubl                        field sale-slt-rubl       like ub.doc-line.price-rubl                        field sale-road-tax-base  like ub.doc-line.price-rubl                        field sale-road-tax-rubl  like ub.doc-line.price-rubl                        field sale-excise-base    like ub.doc-line.price-rubl                        field sale-excise-rubl    like ub.doc-line.price-rubl                        field ov-base             like ub.doc-line.price-rubl                        field ov-vat              like ub.doc-line.price-rubl
  index pi         is   primary   unique supp-type supp-code vat-pc slt-pc purch-code
.
define  shared temp-table d-slts-vats no-undo
  field vat-pc  like ub.parts.vat-pc
  field slt-pc  like ub.parts.slt-pc
  field fact-qnty           like ub.doc-line.price-rubl                        field acc-base            like ub.doc-line.price-rubl                        field acc-rubl            like ub.doc-line.price-rubl                        field acc-vat-base        like ub.doc-line.price-rubl                        field acc-vat-rubl        like ub.doc-line.price-rubl                        field acc-slt-base        like ub.doc-line.price-rubl                        field acc-slt-rubl        like ub.doc-line.price-rubl                        field acc-road-tax-base   like ub.doc-line.price-rubl                        field acc-road-tax-rubl   like ub.doc-line.price-rubl                        field acc-excise-base     like ub.doc-line.price-rubl                        field acc-excise-rubl     like ub.doc-line.price-rubl                        field acc-transport-base  like ub.doc-line.price-rubl                        field acc-transport-rubl  like ub.doc-line.price-rubl                        field acc-other-base      like ub.doc-line.price-rubl                        field acc-other-rubl      like ub.doc-line.price-rubl                        field pay-base            like ub.doc-line.price-rubl                        field pay-rubl            like ub.doc-line.price-rubl                        field no-vat-base         like ub.doc-line.price-rubl                        field no-vat-rubl         like ub.doc-line.price-rubl                        field vat-base            like ub.doc-line.price-rubl                        field vat-rubl            like ub.doc-line.price-rubl                        field vat-base-buyer      like ub.doc-line.price-rubl                        field vat-rubl-buyer      like ub.doc-line.price-rubl                        field slt-base            like ub.doc-line.price-rubl                        field slt-rubl            like ub.doc-line.price-rubl                        field road-tax            like ub.doc-line.price-rubl                        field excise              like ub.doc-line.price-rubl                        field sale-base           like ub.doc-line.price-rubl                        field sale-rubl           like ub.doc-line.price-rubl                        field sale-vat-base       like ub.doc-line.price-rubl                        field sale-vat-rubl       like ub.doc-line.price-rubl                        field sale-vat-buyer-base like ub.doc-line.price-rubl                        field sale-vat-buyer-rubl like ub.doc-line.price-rubl                        field sale-slt-base       like ub.doc-line.price-rubl                        field sale-slt-rubl       like ub.doc-line.price-rubl                        field sale-road-tax-base  like ub.doc-line.price-rubl                        field sale-road-tax-rubl  like ub.doc-line.price-rubl                        field sale-excise-base    like ub.doc-line.price-rubl                        field sale-excise-rubl    like ub.doc-line.price-rubl                        field ov-base             like ub.doc-line.price-rubl                        field ov-vat              like ub.doc-line.price-rubl
  index vat-slt is   primary unique vat-pc slt-pc
.
define  shared temp-table d-slts-vats-cons no-undo
  field vat-pc        like ub.parts.vat-pc
  field slt-pc        like ub.parts.slt-pc
  field purch-code    like ub.parts.purch-code
  field purch-name    as   character
  field fact-qnty           like ub.doc-line.price-rubl                        field acc-base            like ub.doc-line.price-rubl                        field acc-rubl            like ub.doc-line.price-rubl                        field acc-vat-base        like ub.doc-line.price-rubl                        field acc-vat-rubl        like ub.doc-line.price-rubl                        field acc-slt-base        like ub.doc-line.price-rubl                        field acc-slt-rubl        like ub.doc-line.price-rubl                        field acc-road-tax-base   like ub.doc-line.price-rubl                        field acc-road-tax-rubl   like ub.doc-line.price-rubl                        field acc-excise-base     like ub.doc-line.price-rubl                        field acc-excise-rubl     like ub.doc-line.price-rubl                        field acc-transport-base  like ub.doc-line.price-rubl                        field acc-transport-rubl  like ub.doc-line.price-rubl                        field acc-other-base      like ub.doc-line.price-rubl                        field acc-other-rubl      like ub.doc-line.price-rubl                        field pay-base            like ub.doc-line.price-rubl                        field pay-rubl            like ub.doc-line.price-rubl                        field no-vat-base         like ub.doc-line.price-rubl                        field no-vat-rubl         like ub.doc-line.price-rubl                        field vat-base            like ub.doc-line.price-rubl                        field vat-rubl            like ub.doc-line.price-rubl                        field vat-base-buyer      like ub.doc-line.price-rubl                        field vat-rubl-buyer      like ub.doc-line.price-rubl                        field slt-base            like ub.doc-line.price-rubl                        field slt-rubl            like ub.doc-line.price-rubl                        field road-tax            like ub.doc-line.price-rubl                        field excise              like ub.doc-line.price-rubl                        field sale-base           like ub.doc-line.price-rubl                        field sale-rubl           like ub.doc-line.price-rubl                        field sale-vat-base       like ub.doc-line.price-rubl                        field sale-vat-rubl       like ub.doc-line.price-rubl                        field sale-vat-buyer-base like ub.doc-line.price-rubl                        field sale-vat-buyer-rubl like ub.doc-line.price-rubl                        field sale-slt-base       like ub.doc-line.price-rubl                        field sale-slt-rubl       like ub.doc-line.price-rubl                        field sale-road-tax-base  like ub.doc-line.price-rubl                        field sale-road-tax-rubl  like ub.doc-line.price-rubl                        field sale-excise-base    like ub.doc-line.price-rubl                        field sale-excise-rubl    like ub.doc-line.price-rubl                        field ov-base             like ub.doc-line.price-rubl                        field ov-vat              like ub.doc-line.price-rubl
  index vat-slt-purch is   primary   unique vat-pc slt-pc purch-code
.
define  shared temp-table d-slts-vats-cons-grp no-undo
  field vat-pc        like ub.parts.vat-pc
  field slt-pc        like ub.parts.slt-pc
  field purch-code    like ub.parts.purch-code
  field grp-code      like ub.goods.grp-code
  field purch-name    as   character
  field grp-name      like ub.gds-grp.node-name
  field fact-qnty           like ub.doc-line.price-rubl                        field acc-base            like ub.doc-line.price-rubl                        field acc-rubl            like ub.doc-line.price-rubl                        field acc-vat-base        like ub.doc-line.price-rubl                        field acc-vat-rubl        like ub.doc-line.price-rubl                        field acc-slt-base        like ub.doc-line.price-rubl                        field acc-slt-rubl        like ub.doc-line.price-rubl                        field acc-road-tax-base   like ub.doc-line.price-rubl                        field acc-road-tax-rubl   like ub.doc-line.price-rubl                        field acc-excise-base     like ub.doc-line.price-rubl                        field acc-excise-rubl     like ub.doc-line.price-rubl                        field acc-transport-base  like ub.doc-line.price-rubl                        field acc-transport-rubl  like ub.doc-line.price-rubl                        field acc-other-base      like ub.doc-line.price-rubl                        field acc-other-rubl      like ub.doc-line.price-rubl                        field pay-base            like ub.doc-line.price-rubl                        field pay-rubl            like ub.doc-line.price-rubl                        field no-vat-base         like ub.doc-line.price-rubl                        field no-vat-rubl         like ub.doc-line.price-rubl                        field vat-base            like ub.doc-line.price-rubl                        field vat-rubl            like ub.doc-line.price-rubl                        field vat-base-buyer      like ub.doc-line.price-rubl                        field vat-rubl-buyer      like ub.doc-line.price-rubl                        field slt-base            like ub.doc-line.price-rubl                        field slt-rubl            like ub.doc-line.price-rubl                        field road-tax            like ub.doc-line.price-rubl                        field excise              like ub.doc-line.price-rubl                        field sale-base           like ub.doc-line.price-rubl                        field sale-rubl           like ub.doc-line.price-rubl                        field sale-vat-base       like ub.doc-line.price-rubl                        field sale-vat-rubl       like ub.doc-line.price-rubl                        field sale-vat-buyer-base like ub.doc-line.price-rubl                        field sale-vat-buyer-rubl like ub.doc-line.price-rubl                        field sale-slt-base       like ub.doc-line.price-rubl                        field sale-slt-rubl       like ub.doc-line.price-rubl                        field sale-road-tax-base  like ub.doc-line.price-rubl                        field sale-road-tax-rubl  like ub.doc-line.price-rubl                        field sale-excise-base    like ub.doc-line.price-rubl                        field sale-excise-rubl    like ub.doc-line.price-rubl                        field ov-base             like ub.doc-line.price-rubl                        field ov-vat              like ub.doc-line.price-rubl
  index vat-slt-purch is   primary   unique vat-pc slt-pc purch-code grp-code
.
define  shared temp-table tt-title-fin no-undo
  field purch-code    like ub.parts.purch-code
  field purch-name    as   character
  field contract-code like ub.fin-doc.contract-code
  field fact-qnty           like ub.doc-line.price-rubl                        field acc-base            like ub.doc-line.price-rubl                        field acc-rubl            like ub.doc-line.price-rubl                        field acc-vat-base        like ub.doc-line.price-rubl                        field acc-vat-rubl        like ub.doc-line.price-rubl                        field acc-slt-base        like ub.doc-line.price-rubl                        field acc-slt-rubl        like ub.doc-line.price-rubl                        field acc-road-tax-base   like ub.doc-line.price-rubl                        field acc-road-tax-rubl   like ub.doc-line.price-rubl                        field acc-excise-base     like ub.doc-line.price-rubl                        field acc-excise-rubl     like ub.doc-line.price-rubl                        field acc-transport-base  like ub.doc-line.price-rubl                        field acc-transport-rubl  like ub.doc-line.price-rubl                        field acc-other-base      like ub.doc-line.price-rubl                        field acc-other-rubl      like ub.doc-line.price-rubl                        field pay-base            like ub.doc-line.price-rubl                        field pay-rubl            like ub.doc-line.price-rubl                        field no-vat-base         like ub.doc-line.price-rubl                        field no-vat-rubl         like ub.doc-line.price-rubl                        field vat-base            like ub.doc-line.price-rubl                        field vat-rubl            like ub.doc-line.price-rubl                        field vat-base-buyer      like ub.doc-line.price-rubl                        field vat-rubl-buyer      like ub.doc-line.price-rubl                        field slt-base            like ub.doc-line.price-rubl                        field slt-rubl            like ub.doc-line.price-rubl                        field road-tax            like ub.doc-line.price-rubl                        field excise              like ub.doc-line.price-rubl                        field sale-base           like ub.doc-line.price-rubl                        field sale-rubl           like ub.doc-line.price-rubl                        field sale-vat-base       like ub.doc-line.price-rubl                        field sale-vat-rubl       like ub.doc-line.price-rubl                        field sale-vat-buyer-base like ub.doc-line.price-rubl                        field sale-vat-buyer-rubl like ub.doc-line.price-rubl                        field sale-slt-base       like ub.doc-line.price-rubl                        field sale-slt-rubl       like ub.doc-line.price-rubl                        field sale-road-tax-base  like ub.doc-line.price-rubl                        field sale-road-tax-rubl  like ub.doc-line.price-rubl                        field sale-excise-base    like ub.doc-line.price-rubl                        field sale-excise-rubl    like ub.doc-line.price-rubl                        field ov-base             like ub.doc-line.price-rubl                        field ov-vat              like ub.doc-line.price-rubl
  index purch-findoc  is   primary unique contract-code purch-code
.
define  shared temp-table d-supp-fin no-undo
  field purch-code    like ub.parts.purch-code
  field purch-name    as   character
  field supp-name     like ub.clients.obj-name
  field supp-type     like ub.parts.supp-type
  field supp-code     like ub.parts.supp-code
  field contract-code like ub.fin-doc.contract-code
  field fact-qnty           like ub.doc-line.price-rubl                        field acc-base            like ub.doc-line.price-rubl                        field acc-rubl            like ub.doc-line.price-rubl                        field acc-vat-base        like ub.doc-line.price-rubl                        field acc-vat-rubl        like ub.doc-line.price-rubl                        field acc-slt-base        like ub.doc-line.price-rubl                        field acc-slt-rubl        like ub.doc-line.price-rubl                        field acc-road-tax-base   like ub.doc-line.price-rubl                        field acc-road-tax-rubl   like ub.doc-line.price-rubl                        field acc-excise-base     like ub.doc-line.price-rubl                        field acc-excise-rubl     like ub.doc-line.price-rubl                        field acc-transport-base  like ub.doc-line.price-rubl                        field acc-transport-rubl  like ub.doc-line.price-rubl                        field acc-other-base      like ub.doc-line.price-rubl                        field acc-other-rubl      like ub.doc-line.price-rubl                        field pay-base            like ub.doc-line.price-rubl                        field pay-rubl            like ub.doc-line.price-rubl                        field no-vat-base         like ub.doc-line.price-rubl                        field no-vat-rubl         like ub.doc-line.price-rubl                        field vat-base            like ub.doc-line.price-rubl                        field vat-rubl            like ub.doc-line.price-rubl                        field vat-base-buyer      like ub.doc-line.price-rubl                        field vat-rubl-buyer      like ub.doc-line.price-rubl                        field slt-base            like ub.doc-line.price-rubl                        field slt-rubl            like ub.doc-line.price-rubl                        field road-tax            like ub.doc-line.price-rubl                        field excise              like ub.doc-line.price-rubl                        field sale-base           like ub.doc-line.price-rubl                        field sale-rubl           like ub.doc-line.price-rubl                        field sale-vat-base       like ub.doc-line.price-rubl                        field sale-vat-rubl       like ub.doc-line.price-rubl                        field sale-vat-buyer-base like ub.doc-line.price-rubl                        field sale-vat-buyer-rubl like ub.doc-line.price-rubl                        field sale-slt-base       like ub.doc-line.price-rubl                        field sale-slt-rubl       like ub.doc-line.price-rubl                        field sale-road-tax-base  like ub.doc-line.price-rubl                        field sale-road-tax-rubl  like ub.doc-line.price-rubl                        field sale-excise-base    like ub.doc-line.price-rubl                        field sale-excise-rubl    like ub.doc-line.price-rubl                        field ov-base             like ub.doc-line.price-rubl                        field ov-vat              like ub.doc-line.price-rubl
  index supp          is   primary unique contract-code supp-type supp-code purch-code
  index i2                                purch-code
.
define  shared temp-table d-supp-grp-fin no-undo
  field supp-type     like ub.parts.supp-type
  field supp-code     like ub.parts.supp-code
  field purch-code    like ub.parts.purch-code
  field grp-code      like ub.goods.grp-code
  field purch-name    as   character
  field supp-name     like ub.clients.obj-name
  field grp-name      like ub.gds-grp.node-name
  field contract-code like ub.fin-doc.contract-code
  field fact-qnty           like ub.doc-line.price-rubl                        field acc-base            like ub.doc-line.price-rubl                        field acc-rubl            like ub.doc-line.price-rubl                        field acc-vat-base        like ub.doc-line.price-rubl                        field acc-vat-rubl        like ub.doc-line.price-rubl                        field acc-slt-base        like ub.doc-line.price-rubl                        field acc-slt-rubl        like ub.doc-line.price-rubl                        field acc-road-tax-base   like ub.doc-line.price-rubl                        field acc-road-tax-rubl   like ub.doc-line.price-rubl                        field acc-excise-base     like ub.doc-line.price-rubl                        field acc-excise-rubl     like ub.doc-line.price-rubl                        field acc-transport-base  like ub.doc-line.price-rubl                        field acc-transport-rubl  like ub.doc-line.price-rubl                        field acc-other-base      like ub.doc-line.price-rubl                        field acc-other-rubl      like ub.doc-line.price-rubl                        field pay-base            like ub.doc-line.price-rubl                        field pay-rubl            like ub.doc-line.price-rubl                        field no-vat-base         like ub.doc-line.price-rubl                        field no-vat-rubl         like ub.doc-line.price-rubl                        field vat-base            like ub.doc-line.price-rubl                        field vat-rubl            like ub.doc-line.price-rubl                        field vat-base-buyer      like ub.doc-line.price-rubl                        field vat-rubl-buyer      like ub.doc-line.price-rubl                        field slt-base            like ub.doc-line.price-rubl                        field slt-rubl            like ub.doc-line.price-rubl                        field road-tax            like ub.doc-line.price-rubl                        field excise              like ub.doc-line.price-rubl                        field sale-base           like ub.doc-line.price-rubl                        field sale-rubl           like ub.doc-line.price-rubl                        field sale-vat-base       like ub.doc-line.price-rubl                        field sale-vat-rubl       like ub.doc-line.price-rubl                        field sale-vat-buyer-base like ub.doc-line.price-rubl                        field sale-vat-buyer-rubl like ub.doc-line.price-rubl                        field sale-slt-base       like ub.doc-line.price-rubl                        field sale-slt-rubl       like ub.doc-line.price-rubl                        field sale-road-tax-base  like ub.doc-line.price-rubl                        field sale-road-tax-rubl  like ub.doc-line.price-rubl                        field sale-excise-base    like ub.doc-line.price-rubl                        field sale-excise-rubl    like ub.doc-line.price-rubl                        field ov-base             like ub.doc-line.price-rubl                        field ov-vat              like ub.doc-line.price-rubl
  index supp          is   primary unique contract-code supp-type supp-code purch-code grp-code
  index i2                                purch-code
.
define  shared temp-table d-slt-vat-cons-fin no-undo
  field vat-pc        like ub.doc-line.vat-pc
  field slt-pc        like ub.doc-line.slt-pc
  field purch-code    like ub.parts.purch-code
  field purch-name    as   character
  field contract-code like ub.fin-doc.contract-code
  field fact-qnty           like ub.doc-line.price-rubl                        field acc-base            like ub.doc-line.price-rubl                        field acc-rubl            like ub.doc-line.price-rubl                        field acc-vat-base        like ub.doc-line.price-rubl                        field acc-vat-rubl        like ub.doc-line.price-rubl                        field acc-slt-base        like ub.doc-line.price-rubl                        field acc-slt-rubl        like ub.doc-line.price-rubl                        field acc-road-tax-base   like ub.doc-line.price-rubl                        field acc-road-tax-rubl   like ub.doc-line.price-rubl                        field acc-excise-base     like ub.doc-line.price-rubl                        field acc-excise-rubl     like ub.doc-line.price-rubl                        field acc-transport-base  like ub.doc-line.price-rubl                        field acc-transport-rubl  like ub.doc-line.price-rubl                        field acc-other-base      like ub.doc-line.price-rubl                        field acc-other-rubl      like ub.doc-line.price-rubl                        field pay-base            like ub.doc-line.price-rubl                        field pay-rubl            like ub.doc-line.price-rubl                        field no-vat-base         like ub.doc-line.price-rubl                        field no-vat-rubl         like ub.doc-line.price-rubl                        field vat-base            like ub.doc-line.price-rubl                        field vat-rubl            like ub.doc-line.price-rubl                        field vat-base-buyer      like ub.doc-line.price-rubl                        field vat-rubl-buyer      like ub.doc-line.price-rubl                        field slt-base            like ub.doc-line.price-rubl                        field slt-rubl            like ub.doc-line.price-rubl                        field road-tax            like ub.doc-line.price-rubl                        field excise              like ub.doc-line.price-rubl                        field sale-base           like ub.doc-line.price-rubl                        field sale-rubl           like ub.doc-line.price-rubl                        field sale-vat-base       like ub.doc-line.price-rubl                        field sale-vat-rubl       like ub.doc-line.price-rubl                        field sale-vat-buyer-base like ub.doc-line.price-rubl                        field sale-vat-buyer-rubl like ub.doc-line.price-rubl                        field sale-slt-base       like ub.doc-line.price-rubl                        field sale-slt-rubl       like ub.doc-line.price-rubl                        field sale-road-tax-base  like ub.doc-line.price-rubl                        field sale-road-tax-rubl  like ub.doc-line.price-rubl                        field sale-excise-base    like ub.doc-line.price-rubl                        field sale-excise-rubl    like ub.doc-line.price-rubl                        field ov-base             like ub.doc-line.price-rubl                        field ov-vat              like ub.doc-line.price-rubl
  index vat-slt-purch is   primary unique contract-code vat-pc slt-pc purch-code
.
define  shared temp-table d-slt-vat-cons-grp-fin no-undo
  field vat-pc        like ub.doc-line.vat-pc
  field slt-pc        like ub.doc-line.slt-pc
  field purch-code    like ub.parts.purch-code
  field purch-name    as   character
  field grp-code      like ub.goods.grp-code
  field grp-name      like ub.gds-grp.node-name
  field contract-code like ub.fin-doc.contract-code
  field fact-qnty           like ub.doc-line.price-rubl                        field acc-base            like ub.doc-line.price-rubl                        field acc-rubl            like ub.doc-line.price-rubl                        field acc-vat-base        like ub.doc-line.price-rubl                        field acc-vat-rubl        like ub.doc-line.price-rubl                        field acc-slt-base        like ub.doc-line.price-rubl                        field acc-slt-rubl        like ub.doc-line.price-rubl                        field acc-road-tax-base   like ub.doc-line.price-rubl                        field acc-road-tax-rubl   like ub.doc-line.price-rubl                        field acc-excise-base     like ub.doc-line.price-rubl                        field acc-excise-rubl     like ub.doc-line.price-rubl                        field acc-transport-base  like ub.doc-line.price-rubl                        field acc-transport-rubl  like ub.doc-line.price-rubl                        field acc-other-base      like ub.doc-line.price-rubl                        field acc-other-rubl      like ub.doc-line.price-rubl                        field pay-base            like ub.doc-line.price-rubl                        field pay-rubl            like ub.doc-line.price-rubl                        field no-vat-base         like ub.doc-line.price-rubl                        field no-vat-rubl         like ub.doc-line.price-rubl                        field vat-base            like ub.doc-line.price-rubl                        field vat-rubl            like ub.doc-line.price-rubl                        field vat-base-buyer      like ub.doc-line.price-rubl                        field vat-rubl-buyer      like ub.doc-line.price-rubl                        field slt-base            like ub.doc-line.price-rubl                        field slt-rubl            like ub.doc-line.price-rubl                        field road-tax            like ub.doc-line.price-rubl                        field excise              like ub.doc-line.price-rubl                        field sale-base           like ub.doc-line.price-rubl                        field sale-rubl           like ub.doc-line.price-rubl                        field sale-vat-base       like ub.doc-line.price-rubl                        field sale-vat-rubl       like ub.doc-line.price-rubl                        field sale-vat-buyer-base like ub.doc-line.price-rubl                        field sale-vat-buyer-rubl like ub.doc-line.price-rubl                        field sale-slt-base       like ub.doc-line.price-rubl                        field sale-slt-rubl       like ub.doc-line.price-rubl                        field sale-road-tax-base  like ub.doc-line.price-rubl                        field sale-road-tax-rubl  like ub.doc-line.price-rubl                        field sale-excise-base    like ub.doc-line.price-rubl                        field sale-excise-rubl    like ub.doc-line.price-rubl                        field ov-base             like ub.doc-line.price-rubl                        field ov-vat              like ub.doc-line.price-rubl
  index vat-slt-purch is   primary unique contract-code vat-pc slt-pc purch-code grp-code
.
define  shared temp-table d-supp-slts-vats-cons-fin no-undo
  field supp-type     like ub.parts.supp-type
  field supp-code     like ub.parts.supp-code
  field supp-name     like ub.clients.obj-name
  field vat-pc        like ub.parts.vat-pc
  field slt-pc        like ub.parts.slt-pc
  field purch-code    like ub.parts.purch-code
  field purch-name    as   character
  field contract-code like ub.fin-doc.contract-code
  field fact-qnty           like ub.doc-line.price-rubl                        field acc-base            like ub.doc-line.price-rubl                        field acc-rubl            like ub.doc-line.price-rubl                        field acc-vat-base        like ub.doc-line.price-rubl                        field acc-vat-rubl        like ub.doc-line.price-rubl                        field acc-slt-base        like ub.doc-line.price-rubl                        field acc-slt-rubl        like ub.doc-line.price-rubl                        field acc-road-tax-base   like ub.doc-line.price-rubl                        field acc-road-tax-rubl   like ub.doc-line.price-rubl                        field acc-excise-base     like ub.doc-line.price-rubl                        field acc-excise-rubl     like ub.doc-line.price-rubl                        field acc-transport-base  like ub.doc-line.price-rubl                        field acc-transport-rubl  like ub.doc-line.price-rubl                        field acc-other-base      like ub.doc-line.price-rubl                        field acc-other-rubl      like ub.doc-line.price-rubl                        field pay-base            like ub.doc-line.price-rubl                        field pay-rubl            like ub.doc-line.price-rubl                        field no-vat-base         like ub.doc-line.price-rubl                        field no-vat-rubl         like ub.doc-line.price-rubl                        field vat-base            like ub.doc-line.price-rubl                        field vat-rubl            like ub.doc-line.price-rubl                        field vat-base-buyer      like ub.doc-line.price-rubl                        field vat-rubl-buyer      like ub.doc-line.price-rubl                        field slt-base            like ub.doc-line.price-rubl                        field slt-rubl            like ub.doc-line.price-rubl                        field road-tax            like ub.doc-line.price-rubl                        field excise              like ub.doc-line.price-rubl                        field sale-base           like ub.doc-line.price-rubl                        field sale-rubl           like ub.doc-line.price-rubl                        field sale-vat-base       like ub.doc-line.price-rubl                        field sale-vat-rubl       like ub.doc-line.price-rubl                        field sale-vat-buyer-base like ub.doc-line.price-rubl                        field sale-vat-buyer-rubl like ub.doc-line.price-rubl                        field sale-slt-base       like ub.doc-line.price-rubl                        field sale-slt-rubl       like ub.doc-line.price-rubl                        field sale-road-tax-base  like ub.doc-line.price-rubl                        field sale-road-tax-rubl  like ub.doc-line.price-rubl                        field sale-excise-base    like ub.doc-line.price-rubl                        field sale-excise-rubl    like ub.doc-line.price-rubl                        field ov-base             like ub.doc-line.price-rubl                        field ov-vat              like ub.doc-line.price-rubl
  index pi            is   primary unique contract-code supp-type supp-code vat-pc slt-pc purch-code
.
define  shared temp-table d-slts-vats-cons-fin no-undo
  field vat-pc        like ub.parts.vat-pc
  field slt-pc        like ub.parts.slt-pc
  field purch-code    like ub.parts.purch-code
  field purch-name    as   character
  field contract-code like ub.fin-doc.contract-code
  field fact-qnty           like ub.doc-line.price-rubl                        field acc-base            like ub.doc-line.price-rubl                        field acc-rubl            like ub.doc-line.price-rubl                        field acc-vat-base        like ub.doc-line.price-rubl                        field acc-vat-rubl        like ub.doc-line.price-rubl                        field acc-slt-base        like ub.doc-line.price-rubl                        field acc-slt-rubl        like ub.doc-line.price-rubl                        field acc-road-tax-base   like ub.doc-line.price-rubl                        field acc-road-tax-rubl   like ub.doc-line.price-rubl                        field acc-excise-base     like ub.doc-line.price-rubl                        field acc-excise-rubl     like ub.doc-line.price-rubl                        field acc-transport-base  like ub.doc-line.price-rubl                        field acc-transport-rubl  like ub.doc-line.price-rubl                        field acc-other-base      like ub.doc-line.price-rubl                        field acc-other-rubl      like ub.doc-line.price-rubl                        field pay-base            like ub.doc-line.price-rubl                        field pay-rubl            like ub.doc-line.price-rubl                        field no-vat-base         like ub.doc-line.price-rubl                        field no-vat-rubl         like ub.doc-line.price-rubl                        field vat-base            like ub.doc-line.price-rubl                        field vat-rubl            like ub.doc-line.price-rubl                        field vat-base-buyer      like ub.doc-line.price-rubl                        field vat-rubl-buyer      like ub.doc-line.price-rubl                        field slt-base            like ub.doc-line.price-rubl                        field slt-rubl            like ub.doc-line.price-rubl                        field road-tax            like ub.doc-line.price-rubl                        field excise              like ub.doc-line.price-rubl                        field sale-base           like ub.doc-line.price-rubl                        field sale-rubl           like ub.doc-line.price-rubl                        field sale-vat-base       like ub.doc-line.price-rubl                        field sale-vat-rubl       like ub.doc-line.price-rubl                        field sale-vat-buyer-base like ub.doc-line.price-rubl                        field sale-vat-buyer-rubl like ub.doc-line.price-rubl                        field sale-slt-base       like ub.doc-line.price-rubl                        field sale-slt-rubl       like ub.doc-line.price-rubl                        field sale-road-tax-base  like ub.doc-line.price-rubl                        field sale-road-tax-rubl  like ub.doc-line.price-rubl                        field sale-excise-base    like ub.doc-line.price-rubl                        field sale-excise-rubl    like ub.doc-line.price-rubl                        field ov-base             like ub.doc-line.price-rubl                        field ov-vat              like ub.doc-line.price-rubl
  index vat-slt-purch is   primary unique contract-code vat-pc slt-pc purch-code
.
define  shared temp-table d-slts-vats-cons-grp-fin no-undo
  field vat-pc        like ub.parts.vat-pc
  field slt-pc        like ub.parts.slt-pc
  field purch-code    like ub.parts.purch-code
  field grp-code      like ub.goods.grp-code
  field purch-name    as   character
  field grp-name      like ub.gds-grp.node-name
  field contract-code like ub.fin-doc.contract-code
  field fact-qnty           like ub.doc-line.price-rubl                        field acc-base            like ub.doc-line.price-rubl                        field acc-rubl            like ub.doc-line.price-rubl                        field acc-vat-base        like ub.doc-line.price-rubl                        field acc-vat-rubl        like ub.doc-line.price-rubl                        field acc-slt-base        like ub.doc-line.price-rubl                        field acc-slt-rubl        like ub.doc-line.price-rubl                        field acc-road-tax-base   like ub.doc-line.price-rubl                        field acc-road-tax-rubl   like ub.doc-line.price-rubl                        field acc-excise-base     like ub.doc-line.price-rubl                        field acc-excise-rubl     like ub.doc-line.price-rubl                        field acc-transport-base  like ub.doc-line.price-rubl                        field acc-transport-rubl  like ub.doc-line.price-rubl                        field acc-other-base      like ub.doc-line.price-rubl                        field acc-other-rubl      like ub.doc-line.price-rubl                        field pay-base            like ub.doc-line.price-rubl                        field pay-rubl            like ub.doc-line.price-rubl                        field no-vat-base         like ub.doc-line.price-rubl                        field no-vat-rubl         like ub.doc-line.price-rubl                        field vat-base            like ub.doc-line.price-rubl                        field vat-rubl            like ub.doc-line.price-rubl                        field vat-base-buyer      like ub.doc-line.price-rubl                        field vat-rubl-buyer      like ub.doc-line.price-rubl                        field slt-base            like ub.doc-line.price-rubl                        field slt-rubl            like ub.doc-line.price-rubl                        field road-tax            like ub.doc-line.price-rubl                        field excise              like ub.doc-line.price-rubl                        field sale-base           like ub.doc-line.price-rubl                        field sale-rubl           like ub.doc-line.price-rubl                        field sale-vat-base       like ub.doc-line.price-rubl                        field sale-vat-rubl       like ub.doc-line.price-rubl                        field sale-vat-buyer-base like ub.doc-line.price-rubl                        field sale-vat-buyer-rubl like ub.doc-line.price-rubl                        field sale-slt-base       like ub.doc-line.price-rubl                        field sale-slt-rubl       like ub.doc-line.price-rubl                        field sale-road-tax-base  like ub.doc-line.price-rubl                        field sale-road-tax-rubl  like ub.doc-line.price-rubl                        field sale-excise-base    like ub.doc-line.price-rubl                        field sale-excise-rubl    like ub.doc-line.price-rubl                        field ov-base             like ub.doc-line.price-rubl                        field ov-vat              like ub.doc-line.price-rubl
  index vat-slt-purch is   primary unique contract-code vat-pc slt-pc purch-code grp-code
.
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
    define  variable price-rubl-with-tax-sale-cur    like ub.doc-line.price-rubl no-undo.
    define  variable price-base-with-tax-sale-cur    like ub.doc-line.price-base no-undo.
    define  variable price-rubl-without-tax-sale-cur like ub.doc-line.price-rubl no-undo.
    define  variable price-base-without-tax-sale-cur like ub.doc-line.price-base no-undo.
    define  variable vat-base-sale-cur               like ub.doc-line.price-base no-undo.
    define  variable vat-rubl-sale-cur               like ub.doc-line.price-rubl no-undo.
    define  variable vat-base-buyer-cur              like ub.doc-line.price-base no-undo.
    define  variable vat-rubl-buyer-cur              like ub.doc-line.price-rubl no-undo.
    define  variable slt-base-sale-cur               like ub.doc-line.price-base no-undo.
    define  variable slt-rubl-sale-cur               like ub.doc-line.price-rubl no-undo.
    define  variable road-tax-base-sale-cur          like ub.doc-line.road-tax   no-undo.
    define  variable road-tax-rubl-sale-cur          like ub.doc-line.road-tax   no-undo.
    define  variable excise-base-sale-cur            like ub.doc-line.price-base no-undo.
    define  variable excise-rubl-sale-cur            like ub.doc-line.price-rubl no-undo.
    define  variable discnt-base-sale-cur            like ub.gds-dtl.discnt-base no-undo.
    define  variable discnt-rubl-sale-cur            like ub.gds-dtl.discnt-rubl no-undo.
    define buffer out-vatp_gds-dtl-cur     for ub.gds-dtl.
    define buffer buf_out-vatp_gds-dtl-cur for ub.gds-dtl.
    define buffer out-vatp_parts-cur       for ub.parts.
    define buffer out-vatp_sysconf-cur     for ub.sysconf.
    define buffer out-vatp_doc-line-cur    for ub.doc-line.
    define buffer out-vatp_goods-cur       for ub.goods.
    define buffer out-vatp_trn-doc-cur     for ub.trn-doc.
    define buffer out-vatp_doc-attr-cur    for ub.doc-attr.
    define variable varprice-base-cons-cur      like ub.doc-line.price-base initial 0.00 no-undo.
    define variable varprice-rubl-cons-cur      like ub.doc-line.price-rubl initial 0.00 no-undo.
    define variable varfrm-cnsv-type-cur         as   character                           no-undo.
    define variable varfrm-cnsv-cur              as   character                           no-undo.
    define variable varroot-node-cur             as   integer                             no-undo.
    define variable varempty-scale-cur           as   logical                             no-undo.
    define variable varis-cons-parts-have-cur    as   logical                             no-undo.
    define variable varsum-base-factovp-cur      like ub.gds-dtl.price-base               no-undo.
    define variable varslt-base-factovp-cur      like ub.gds-dtl.price-base               no-undo.
    define variable varvat-base-factovp-cur      like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-base-factovp-cur  like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-base-factovp-cur      like ub.gds-dtl.price-base               no-undo.
    define variable varsum-base-docovp-cur       like ub.gds-dtl.price-base               no-undo.
    define variable varslt-base-docovp-cur       like ub.gds-dtl.price-base               no-undo.
    define variable varvat-base-docovp-cur       like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-base-docovp-cur   like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-base-docovp-cur       like ub.gds-dtl.price-base               no-undo.
    define variable varsum-rubl-factovp-cur      like ub.gds-dtl.price-base               no-undo.
    define variable varslt-rubl-factovp-cur      like ub.gds-dtl.price-base               no-undo.
    define variable varvat-rubl-factovp-cur      like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-rubl-factovp-cur  like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-rubl-factovp-cur      like ub.gds-dtl.price-base               no-undo.
    define variable varsum-rubl-docovp-cur       like ub.gds-dtl.price-base               no-undo.
    define variable varslt-rubl-docovp-cur       like ub.gds-dtl.price-base               no-undo.
    define variable varvat-rubl-docovp-cur       like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-rubl-docovp-cur   like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-rubl-docovp-cur       like ub.gds-dtl.price-base               no-undo.
    define variable varfact-qnty-cur             like ub.parts.fact-qnty                  no-undo.
    define variable varcons-qnty-cur             like ub.parts.fact-qnty                  no-undo.
    define variable varis-one-gds-dtl-cur        as   logical                             no-undo.
    define variable varcur-curprice-base         like ub.gds-dtl.cur-base                 no-undo.
    define variable varcur-curprice-rubl         like ub.gds-dtl.price-base               no-undo.
    define variable varcur-curdiscnt-base        like ub.gds-dtl.cur-base                 no-undo.
    define variable varcur-curdiscnt-rubl        like ub.gds-dtl.price-base               no-undo.
    define variable varoutvprb-cur               as   character                           no-undo.
    define variable out-vatp-have-vat-slt-cur    as   logical initial yes                 no-undo.
    define buffer   in-vatp-trn-doco-cur  for ub.trn-doc .
    define buffer   in-vatp-partso-cur    for ub.parts   .
    define buffer   in-vatp-doco-cur      for ub.trn-doc .
    define buffer   in-vatp-goodso-cur    for ub.goods   .
    define buffer   in-vatp-sysconfo-cur  for ub.sysconf .
    define buffer   in-vatp_doc-attro-cur for ub.doc-attr.
    define variable in-vatp-have-vat-slto-cur       as   logical initial yes    no-undo.
    define variable vat-pc-loco-cur                 like ub.doc-line.vat-pc     no-undo.
    define variable varinvprbo-cur                  as   character              no-undo.
    define variable slt-pc-loco-cur                 like ub.doc-line.slt-pc     no-undo.
    define variable cli-base-rateo-cur              as   decimal                no-undo.
    define variable price-rubl-with-tax-loco-cur    like ub.doc-line.price-rubl no-undo.
    define variable price-base-with-tax-loco-cur    like ub.doc-line.price-base no-undo.
    define variable price-cli-with-tax-loco-cur     like ub.doc-line.price-cli  no-undo.
    define variable price-rubl-without-tax-loco-cur like ub.doc-line.price-rubl no-undo.
    define variable price-base-without-tax-loco-cur like ub.doc-line.price-base no-undo.
    define variable price-cli-without-tax-loco-cur  like ub.doc-line.price-base no-undo.
    define variable vat-base-loco-cur               like ub.doc-line.price-base no-undo.
    define variable vat-rubl-loco-cur               like ub.doc-line.price-rubl no-undo.
    define variable vat-cli-loco-cur                like ub.doc-line.price-rubl no-undo.
    define variable slt-base-loco-cur               like ub.doc-line.price-base no-undo.
    define variable slt-rubl-loco-cur               like ub.doc-line.price-rubl no-undo.
    define variable slt-cli-loco-cur                like ub.doc-line.price-rubl no-undo.
    define variable road-tax-base-loco-cur          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-rubl-loco-cur          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-cli-loco-cur           like ub.doc-line.road-tax   no-undo.
    define variable transport-base-loco-cur         like ub.doc-line.price-base no-undo.
    define variable transport-rubl-loco-cur         like ub.doc-line.price-rubl no-undo.
    define variable transport-cli-loco-cur          like ub.doc-line.price-rubl no-undo.
    define variable other-base-loco-cur             like ub.doc-line.price-base no-undo.
    define variable other-rubl-loco-cur             like ub.doc-line.price-rubl no-undo.
    define variable other-cli-loco-cur              like ub.doc-line.price-rubl no-undo.
    define variable exch-rate-cli-loco-cur          like ub.trn-doc.exch-rate   no-undo.
    define variable varinvatp-envdo-cur             as   character              no-undo.
    define variable varinvatp-typeo-cur             as   character              no-undo.
define buffer bf_trn-doc  for ub.trn-doc.
define buffer bf_sysconf  for ub.sysconf.
define buffer bf_doc-line for ub.doc-line.
define buffer bf_goods    for ub.goods.
define buffer bf_parts    for ub.parts.
define buffer bf_clients  for ub.clients.
define buffer bf_gds-dtl  for ub.gds-dtl.
define variable varprice-sale       like ub.price-list.price-sale no-undo.
define variable vardoc-num          like ub.price-doc.doc-num     no-undo.
define variable varb-code           like ub.bar-code.b-code       no-undo.
define variable varr-b              as   character                no-undo.
define variable varr-btype          as   character                no-undo.
define variable varcur-vat-pc       like ub.doc-line.vat-pc       no-undo.
define variable varcur-cons-vat-pc  like ub.doc-line.cons-vat-pc  no-undo.
define variable varcur-slt-pc       like ub.doc-line.slt-pc       no-undo.
define variable varcur-base         like ub.gds-dtl.price-base    no-undo.
define variable varcur-road-tax     like ub.doc-line.road-tax     no-undo.
define variable varcur-excise       like ub.doc-line.excise       no-undo.
define variable varcur-fact-qnty    like ub.gds-dtl.fact-qnty     no-undo.
define variable vartime             as   integer                  no-undo.
define variable varcount            as   integer                  no-undo.
define variable varoutput-string    as   character                no-undo.
define variable varlastcur-base     like ub.gds-dtl.price-base    no-undo.
define variable varlastcur-road-tax like ub.gds-dtl.price-base    no-undo.
define variable varlastcur-excise   like ub.gds-dtl.price-base    no-undo.
define variable varroad-tax         like ub.price-list.road-tax   no-undo.
define variable varexcise           like ub.price-list.excise     no-undo.
define variable varfull-name-grp    as   character                no-undo.
define variable varcalc-title-fin   as   logical                  no-undo initial ?.
define variable sum-price-rubl-with-tax-sale     like ub.doc-line.price-rubl no-undo.
define variable sum-price-base-with-tax-sale     like ub.doc-line.price-base no-undo.
define variable sum-vat-base-sale                like ub.doc-line.price-base no-undo.
define variable sum-vat-rubl-sale                like ub.doc-line.price-rubl no-undo.
define variable sum-vat-base-buyer               like ub.doc-line.price-base no-undo.
define variable sum-vat-rubl-buyer               like ub.doc-line.price-rubl no-undo.
define variable sum-slt-base-sale                like ub.doc-line.price-base no-undo.
define variable sum-slt-rubl-sale                like ub.doc-line.price-rubl no-undo.
define variable sum-road-tax-base-sale           like ub.doc-line.road-tax   no-undo.
define variable sum-road-tax-rubl-sale           like ub.doc-line.road-tax   no-undo.
define variable sum-excise-base-sale             like ub.doc-line.price-base no-undo.
define variable sum-excise-rubl-sale             like ub.doc-line.price-rubl no-undo.
define variable sum-discnt-base-sale             like ub.gds-dtl.discnt-base no-undo.
define variable sum-discnt-rubl-sale             like ub.gds-dtl.discnt-rubl no-undo.
define variable sum-price-rubl-with-tax-sale-cur like ub.doc-line.price-rubl no-undo.
define variable sum-price-base-with-tax-sale-cur like ub.doc-line.price-base no-undo.
define variable sum-vat-base-sale-cur            like ub.doc-line.price-base no-undo.
define variable sum-vat-rubl-sale-cur            like ub.doc-line.price-rubl no-undo.
define variable sum-vat-base-buyer-cur           like ub.doc-line.price-base no-undo.
define variable sum-vat-rubl-buyer-cur           like ub.doc-line.price-rubl no-undo.
define variable sum-slt-base-sale-cur            like ub.doc-line.price-base no-undo.
define variable sum-slt-rubl-sale-cur            like ub.doc-line.price-rubl no-undo.
define variable sum-road-tax-base-sale-cur       like ub.doc-line.road-tax   no-undo.
define variable sum-road-tax-rubl-sale-cur       like ub.doc-line.road-tax   no-undo.
define variable sum-excise-base-sale-cur         like ub.doc-line.price-base no-undo.
define variable sum-excise-rubl-sale-cur         like ub.doc-line.price-rubl no-undo.
define variable sum-discnt-base-sale-cur         like ub.gds-dtl.discnt-base no-undo.
define variable sum-discnt-rubl-sale-cur         like ub.gds-dtl.discnt-rubl no-undo.
define variable varqnty                          as   decimal                no-undo.
define variable varvat-pc-doc                    like ub.doc-line.vat-pc     no-undo.
assign varcalc-title-fin = lookup( "tt-title-fin",              use-table ) > 0 or
                           lookup( "d-supp-fin",                use-table ) > 0 or
                           lookup( "d-supp-grp-fin",            use-table ) > 0 or
                           lookup( "d-slt-vat-cons-fin",        use-table ) > 0 or
                           lookup( "d-slt-vat-cons-grp-fin",    use-table ) > 0 or
                           lookup( "d-supp-slts-vats-cons-fin", use-table ) > 0 or
                           lookup( "d-slts-vats-cons-fin",      use-table ) > 0 or
                           lookup( "d-slts-vats-cons-grp-fin",  use-table ) > 0.
find first bf_trn-doc no-lock where recid( bf_trn-doc ) = rec-id.
find first bf_sysconf no-lock where bf_sysconf.host-code = bf_trn-doc.host-code.
run ClearAllTempTables in this-procedure.
assign vartime  = TIME
       varcount = 0.
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varr-b
  )  .
line:
for each bf_doc-line no-lock where
         bf_doc-line.doc-code = bf_trn-doc.doc-code
on error undo, return error substitute( "&1 &2 &3", return-value, error-status :get-message( 1 ),
                                                                  error-status :get-message( 2 ) ) :
  if is-wait-on then do:
    assign varcount = varcount + 1.
    run waitfram-join in this-procedure (  input substitute( "Расчет по строкам товаров. Товар: &1 &2 &3.",
                                                             bf_doc-line.artic,
                                                             bf_doc-line.prod-type,
                                                             bf_doc-line.prod-code ),
                                           input substitute( "Обработано строк: &1", varcount ),
                                           input substitute( "Время: &1", TIME - vartime ),
                                          output varoutput-string ).
    run waitfram-show in this-procedure (  input varoutput-string ).
  end.
  if ( bf_trn-doc.ext-doc-type = 'vt':U or bf_trn-doc.ext-doc-type = 'vp':U      ) and
     ( inv-type = 2 and bf_doc-line.fact-qnty <= 0 or inv-type = 3 and bf_doc-line.fact-qnty >= 0 ) then do:
    next.
  end.
  find first bf_goods no-lock where
             bf_goods.artic     = bf_doc-line.artic     and
             bf_goods.prod-type = bf_doc-line.prod-type and
             bf_goods.prod-code = bf_doc-line.prod-code.
  run str/fnamegrp.p ( input bf_goods.grp-code, output varfull-name-grp ).
  if bf_trn-doc.office then do:
    run calc-office in this-procedure.
    if is-wait-on then do: run waitfram-hide in this-procedure. end.
    return.
  end.
  find first bf_parts no-lock where
             bf_parts.out-code  = bf_trn-doc.doc-code   and
             bf_parts.obj-type  = bf_trn-doc.obj-type   and
             bf_parts.obj-code  = bf_trn-doc.obj-code   and
             bf_parts.artic     = bf_doc-line.artic     and
             bf_parts.prod-type = bf_doc-line.prod-type and
             bf_parts.prod-code = bf_doc-line.prod-code no-error.
  if not available bf_parts then do:
    run peresortica_gds-dtl in this-procedure.
    if return-value = "line":u then do:
      next line.
    end.
  end.
  assign varlastcur-base      = 0
         varlastcur-road-tax  = 0
         varlastcur-excise    = 0
         varcur-base          = 0
         varcur-road-tax      = 0
         varcur-excise        = 0
         varcur-vat-pc        = 0
         varcur-slt-pc        = 0
         varcur-fact-qnty     = 0.
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
  if varprice-sale = ? then do:
    assign varcur-vat-pc = 0
           varcur-slt-pc = 0.
  end.
  if varcur-vat-pc = ? then do:
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  bf_goods.gds-code
  ,input  '1':U
  ,input  bf_trn-doc.fact-date
  ,input  bf_trn-doc.host-code
  ,input  bf_trn-doc.obj-type
  ,input  bf_trn-doc.obj-code
  ,output varcur-vat-pc
  )  .
  end.
  if varcur-slt-pc = ? then do:
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  bf_goods.gds-code
  ,input  '2':U
  ,input  bf_trn-doc.fact-date
  ,input  bf_trn-doc.host-code
  ,input  bf_trn-doc.obj-type
  ,input  bf_trn-doc.obj-code
  ,output varcur-slt-pc
  )  .
  end.
  if varcur-vat-pc = ? then do:
    return error substitute( "Нет текущего продажного НДС по товару &1 &2 &3", bf_goods.artic,
                                                                               bf_goods.prod-type,
                                                                               bf_goods.prod-code ).
  end.
  if varcur-slt-pc = ? then do:
    return error substitute( "Нет текущего продажного НП по товару &1 &2 &3", bf_goods.artic,
                                                                              bf_goods.prod-type,
                                                                              bf_goods.prod-code ).
  end.
  find first bf_sysconf where bf_sysconf.host-code = bf_trn-doc.host-code no-lock.
  assign varcur-cons-vat-pc = bf_sysconf.cons-vat-pc.
  if varcur-cons-vat-pc = ? then do:
    return error substitute( "Нет текущего продажного консигнационного НДС по фирме &1", bf_trn-doc.host-code ).
  end.
  for each bf_gds-dtl no-lock where
           bf_gds-dtl.doc-code  = bf_doc-line.doc-code  and
           bf_gds-dtl.artic     = bf_doc-line.artic     and
           bf_gds-dtl.prod-type = bf_doc-line.prod-type and
           bf_gds-dtl.prod-code = bf_doc-line.prod-code on error undo, return error return-value :
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  bf_goods.gds-code
  ,input  bf_gds-dtl.prt-code
  ,output varb-code
  ) no-error .
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
    if varprice-sale = ? then do:
      assign varprice-sale = 0
             varroad-tax   = 0
             varexcise     = 0.
    end.
    assign varlastcur-base     = varprice-sale
           varlastcur-road-tax = varroad-tax
           varlastcur-excise   = varexcise
           varcur-base         = varcur-base      + varprice-sale * bf_gds-dtl.fact-qnty
           varcur-road-tax     = varcur-road-tax  + varroad-tax   * bf_gds-dtl.fact-qnty
           varcur-excise       = varcur-excise    + varexcise     * bf_gds-dtl.fact-qnty
           varcur-fact-qnty    = varcur-fact-qnty +                 bf_gds-dtl.fact-qnty.
  end.
  if varcur-fact-qnty = 0 then do:
    assign varcur-base      = varlastcur-base
           varcur-road-tax  = varlastcur-road-tax
           varcur-excise    = varlastcur-excise.
  end.                    else do:
    assign varcur-base      = varcur-base     / varcur-fact-qnty
           varcur-road-tax  = varcur-road-tax / varcur-fact-qnty
           varcur-excise    = varcur-excise   / varcur-fact-qnty.
  end.
  doc-parts:
  for each bf_parts no-lock where
           bf_parts.out-code  = bf_doc-line.doc-code  and
           bf_parts.obj-type  = bf_trn-doc.obj-type   and
           bf_parts.obj-code  = bf_trn-doc.obj-code   and
           bf_parts.artic     = bf_doc-line.artic     and
           bf_parts.prod-type = bf_doc-line.prod-type and
           bf_parts.prod-code = bf_doc-line.prod-code on error undo, return error return-value :
    if ( bf_trn-doc.ext-doc-type = 'ap':U        or
         bf_trn-doc.ext-doc-type = 'pc':U        or
         bf_trn-doc.ext-doc-type = 'mp':U)     and
       ( inv-type = 2 and bf_parts.in-code <> bf_parts.out-code   or
         inv-type = 3 and bf_parts.in-code  = bf_parts.out-code ) then do:
       next doc-parts.
    end.
    find first tt-title where tt-title.purch-code = bf_parts.purch-code no-error.
    if not available tt-title then do:
      create tt-title.
      assign tt-title.purch-code = bf_parts.purch-code
             tt-title.purch-name = entry (lookup (string( bf_parts.purch-code ), '1,2,3,4':U), 'выкуп,консигнация,ответственное хранение,старая консигнация':U).
    end.
    if varcalc-title-fin = yes then do:
      find first tt-title-fin where
                 tt-title-fin.purch-code    = bf_parts.purch-code    and
                 tt-title-fin.contract-code = bf_parts.contract-code no-error.
      if not available tt-title-fin then do:
        create tt-title-fin.
        assign tt-title-fin.purch-code    = bf_parts.purch-code
               tt-title-fin.purch-name    = entry (lookup (string( bf_parts.purch-code ), '1,2,3,4':U), 'выкуп,консигнация,ответственное хранение,старая консигнация':U)
               tt-title-fin.contract-code = bf_parts.contract-code.
      end.
    end.
    assign
      varvat-pc-doc = (if bf_parts.purch-code = 2 and bf_trn-doc.ext-doc-type <> 'ep':U then bf_doc-line.cons-vat-pc else bf_doc-line.vat-pc).
    if lookup( "d-slt-vat", use-table ) > 0 then do:
      find first d-slt-vat where
                 d-slt-vat.vat-pc = varvat-pc-doc      and
                 d-slt-vat.slt-pc = bf_doc-line.slt-pc no-error.
      if not available d-slt-vat then do:
        create d-slt-vat.
        assign d-slt-vat.vat-pc = varvat-pc-doc
               d-slt-vat.slt-pc = bf_doc-line.slt-pc.
      end.
    end.
    if lookup( "d-slt-vat-cons", use-table ) > 0 then do:
      find first d-slt-vat-cons where
                 d-slt-vat-cons.vat-pc     = varvat-pc-doc       and
                 d-slt-vat-cons.slt-pc     = bf_doc-line.slt-pc  and
                 d-slt-vat-cons.purch-code = bf_parts.purch-code no-error.
      if not available d-slt-vat-cons then do:
        create d-slt-vat-cons.
        assign d-slt-vat-cons.vat-pc     = varvat-pc-doc
               d-slt-vat-cons.slt-pc     = bf_doc-line.slt-pc
               d-slt-vat-cons.purch-code = bf_parts.purch-code
               d-slt-vat-cons.purch-name = entry (lookup (string( bf_parts.purch-code ), '1,2,3,4':U), 'выкуп,консигнация,ответственное хранение,старая консигнация':U).
      end.
    end.
    if lookup( "d-slt-vat-cons-fin", use-table ) > 0 then do:
      find first d-slt-vat-cons-fin where
                 d-slt-vat-cons-fin.vat-pc        = varvat-pc-doc          and
                 d-slt-vat-cons-fin.slt-pc        = bf_doc-line.slt-pc     and
                 d-slt-vat-cons-fin.contract-code = bf_parts.contract-code and
                 d-slt-vat-cons-fin.purch-code    = bf_parts.purch-code    no-error.
      if not available d-slt-vat-cons-fin then do:
        create d-slt-vat-cons-fin.
        assign d-slt-vat-cons-fin.vat-pc        = varvat-pc-doc
               d-slt-vat-cons-fin.slt-pc        = bf_doc-line.slt-pc
               d-slt-vat-cons-fin.contract-code = bf_parts.contract-code
               d-slt-vat-cons-fin.purch-code    = bf_parts.purch-code
               d-slt-vat-cons-fin.purch-name    = entry (lookup (string( bf_parts.purch-code ), '1,2,3,4':U), 'выкуп,консигнация,ответственное хранение,старая консигнация':U).
      end.
    end.
    if lookup( "d-slt-vat-cons-grp", use-table ) > 0 then do:
      find first d-slt-vat-cons-grp where
                 d-slt-vat-cons-grp.vat-pc     = varvat-pc-doc       and
                 d-slt-vat-cons-grp.slt-pc     = bf_doc-line.slt-pc  and
                 d-slt-vat-cons-grp.purch-code = bf_parts.purch-code and
                 d-slt-vat-cons-grp.grp-code   = bf_goods.grp-code   no-error.
      if not available d-slt-vat-cons-grp then do:
        create d-slt-vat-cons-grp.
        assign d-slt-vat-cons-grp.vat-pc     = varvat-pc-doc
               d-slt-vat-cons-grp.slt-pc     = bf_doc-line.slt-pc
               d-slt-vat-cons-grp.purch-code = bf_parts.purch-code
               d-slt-vat-cons-grp.purch-name = entry (lookup (string( bf_parts.purch-code ), '1,2,3,4':U), 'выкуп,консигнация,ответственное хранение,старая консигнация':U)
               d-slt-vat-cons-grp.grp-code   = bf_goods.grp-code
               d-slt-vat-cons-grp.grp-name   = varfull-name-grp.
      end.
    end.
    if lookup( "d-slt-vat-cons-grp-fin", use-table ) > 0 then do:
      find first d-slt-vat-cons-grp-fin where
                 d-slt-vat-cons-grp-fin.vat-pc        = varvat-pc-doc          and
                 d-slt-vat-cons-grp-fin.slt-pc        = bf_doc-line.slt-pc     and
                 d-slt-vat-cons-grp-fin.contract-code = bf_parts.contract-code and
                 d-slt-vat-cons-grp-fin.purch-code    = bf_parts.purch-code    and
                 d-slt-vat-cons-grp-fin.grp-code      = bf_goods.grp-code      no-error.
      if not available d-slt-vat-cons-grp-fin then do:
        create d-slt-vat-cons-grp-fin.
        assign d-slt-vat-cons-grp-fin.vat-pc        = varvat-pc-doc
               d-slt-vat-cons-grp-fin.slt-pc        = bf_doc-line.slt-pc
               d-slt-vat-cons-grp-fin.contract-code = bf_parts.contract-code
               d-slt-vat-cons-grp-fin.purch-code    = bf_parts.purch-code
               d-slt-vat-cons-grp-fin.purch-name    = entry (lookup (string( bf_parts.purch-code ), '1,2,3,4':U), 'выкуп,консигнация,ответственное хранение,старая консигнация':U)
               d-slt-vat-cons-grp-fin.grp-code      = bf_goods.grp-code
               d-slt-vat-cons-grp-fin.grp-name      = varfull-name-grp.
      end.
    end.
    if lookup( "d-slts-vats", use-table ) > 0 then do:
      find first d-slts-vats where
                 d-slts-vats.vat-pc = bf_parts.vat-pc and
                 d-slts-vats.slt-pc = bf_parts.slt-pc no-error.
      if not available d-slts-vats then do:
        create d-slts-vats.
        assign d-slts-vats.vat-pc = bf_parts.vat-pc
               d-slts-vats.slt-pc = bf_parts.slt-pc.
      end.
    end.
    if lookup( "d-slts-vats-cons", use-table ) > 0 then do:
      find first d-slts-vats-cons where
                 d-slts-vats-cons.vat-pc     = bf_parts.vat-pc     and
                 d-slts-vats-cons.slt-pc     = bf_parts.slt-pc     and
                 d-slts-vats-cons.purch-code = bf_parts.purch-code no-error.
      if not available d-slts-vats-cons then do:
        create d-slts-vats-cons.
        assign d-slts-vats-cons.vat-pc     = bf_parts.vat-pc
               d-slts-vats-cons.slt-pc     = bf_parts.slt-pc
               d-slts-vats-cons.purch-code = bf_parts.purch-code
               d-slts-vats-cons.purch-name = entry (lookup (string( bf_parts.purch-code ), '1,2,3,4':U), 'выкуп,консигнация,ответственное хранение,старая консигнация':U).
      end.
    end.
    if lookup( "d-slts-vats-cons-fin", use-table ) > 0 then do:
      find first d-slts-vats-cons-fin where
                 d-slts-vats-cons-fin.vat-pc        = bf_parts.vat-pc        and
                 d-slts-vats-cons-fin.slt-pc        = bf_parts.slt-pc        and
                 d-slts-vats-cons-fin.contract-code = bf_parts.contract-code and
                 d-slts-vats-cons-fin.purch-code    = bf_parts.purch-code    no-error.
      if not available d-slts-vats-cons-fin then do:
        create d-slts-vats-cons-fin.
        assign d-slts-vats-cons-fin.vat-pc        = bf_parts.vat-pc
               d-slts-vats-cons-fin.slt-pc        = bf_parts.slt-pc
               d-slts-vats-cons-fin.contract-code = bf_parts.contract-code
               d-slts-vats-cons-fin.purch-code    = bf_parts.purch-code
               d-slts-vats-cons-fin.purch-name    = entry (lookup (string( bf_parts.purch-code ), '1,2,3,4':U), 'выкуп,консигнация,ответственное хранение,старая консигнация':U).
      end.
    end.
    if lookup( "d-slts-vats-cons-grp", use-table ) > 0 then do:
      find first d-slts-vats-cons-grp where
                 d-slts-vats-cons-grp.vat-pc     = bf_parts.vat-pc     and
                 d-slts-vats-cons-grp.slt-pc     = bf_parts.slt-pc     and
                 d-slts-vats-cons-grp.purch-code = bf_parts.purch-code and
                 d-slts-vats-cons-grp.grp-code   = bf_goods.grp-code   no-error.
      if not available d-slts-vats-cons-grp then do:
        create d-slts-vats-cons-grp.
        assign d-slts-vats-cons-grp.vat-pc     = bf_parts.vat-pc
               d-slts-vats-cons-grp.slt-pc     = bf_parts.slt-pc
               d-slts-vats-cons-grp.purch-code = bf_parts.purch-code
               d-slts-vats-cons-grp.purch-name = entry (lookup (string( bf_parts.purch-code ), '1,2,3,4':U), 'выкуп,консигнация,ответственное хранение,старая консигнация':U)
               d-slts-vats-cons-grp.grp-code   = bf_goods.grp-code
               d-slts-vats-cons-grp.grp-name   = varfull-name-grp.
      end.
    end.
    if lookup( "d-slts-vats-cons-grp-fin", use-table ) > 0 then do:
      find first d-slts-vats-cons-grp-fin where
                 d-slts-vats-cons-grp-fin.vat-pc        = bf_parts.vat-pc        and
                 d-slts-vats-cons-grp-fin.slt-pc        = bf_parts.slt-pc        and
                 d-slts-vats-cons-grp-fin.contract-code = bf_parts.contract-code and
                 d-slts-vats-cons-grp-fin.purch-code    = bf_parts.purch-code    and
                 d-slts-vats-cons-grp-fin.grp-code      = bf_goods.grp-code      no-error.
      if not available d-slts-vats-cons-grp-fin then do:
        create d-slts-vats-cons-grp-fin.
        assign d-slts-vats-cons-grp-fin.vat-pc        = bf_parts.vat-pc
               d-slts-vats-cons-grp-fin.slt-pc        = bf_parts.slt-pc
               d-slts-vats-cons-grp-fin.contract-code = bf_parts.contract-code
               d-slts-vats-cons-grp-fin.purch-code    = bf_parts.purch-code
               d-slts-vats-cons-grp-fin.purch-name    = entry (lookup (string( bf_parts.purch-code ), '1,2,3,4':U), 'выкуп,консигнация,ответственное хранение,старая консигнация':U)
               d-slts-vats-cons-grp-fin.grp-code      = bf_goods.grp-code
               d-slts-vats-cons-grp-fin.grp-name      = varfull-name-grp.
      end.
    end.
    if bf_doc-line.fact-qnty   =  0                         and
       bf_trn-doc.ext-doc-type <> 'ap':U   and
       bf_trn-doc.ext-doc-type <> 'pc':U   and
       bf_trn-doc.ext-doc-type <> 'mp':U then do:
      if lookup( "d-supp", use-table ) > 0 then do:
        find first d-supp where
                   d-supp.supp-type = ?                    and
                   d-supp.supp-code = ?                    and
                   d-supp.purch-code = bf_parts.purch-code no-error.
        if not available d-supp then do:
          create d-supp.
          assign d-supp.supp-type  = ?
                 d-supp.supp-code  = ?
                 d-supp.purch-code = bf_parts.purch-code
                 d-supp.supp-name  = "Разница при продаже-возврате"
                 d-supp.purch-name = entry (lookup (string( bf_parts.purch-code ), '1,2,3,4':U), 'выкуп,консигнация,ответственное хранение,старая консигнация':U).
        end.
      end.
      if lookup( "d-supp-fin", use-table ) > 0 then do:
        find first d-supp-fin where
                   d-supp-fin.supp-type     = ?                      and
                   d-supp-fin.supp-code     = ?                      and
                   d-supp-fin.purch-code    = bf_parts.purch-code    and
                   d-supp-fin.contract-code = bf_parts.contract-code no-error.
        if not available d-supp-fin then do:
          create d-supp-fin.
          assign d-supp-fin.supp-type     = ?
                 d-supp-fin.supp-code     = ?
                 d-supp-fin.purch-code    = bf_parts.purch-code
                 d-supp-fin.contract-code = bf_parts.contract-code
                 d-supp-fin.supp-name     = "Разница при продаже-возврате"
                 d-supp-fin.purch-name    = entry (lookup (string( bf_parts.purch-code ), '1,2,3,4':U), 'выкуп,консигнация,ответственное хранение,старая консигнация':U).
        end.
      end.
      if lookup( "d-supp-grp", use-table ) > 0 then do:
        find first d-supp-grp where
                   d-supp-grp.supp-type  = ?                   and
                   d-supp-grp.supp-code  = ?                   and
                   d-supp-grp.purch-code = bf_parts.purch-code and
                   d-supp-grp.grp-code   = bf_goods.grp-code   no-error.
        if not available d-supp-grp then do:
          create d-supp-grp.
          assign d-supp-grp.supp-type  = ?
                 d-supp-grp.supp-code  = ?
                 d-supp-grp.purch-code = bf_parts.purch-code
                 d-supp-grp.grp-code   = bf_goods.grp-code
                 d-supp-grp.supp-name  = "Разница при продаже-возврате"
                 d-supp-grp.purch-name = entry (lookup (string( bf_parts.purch-code ), '1,2,3,4':U), 'выкуп,консигнация,ответственное хранение,старая консигнация':U)
                 d-supp-grp.grp-name   = varfull-name-grp.
        end.
      end.
      if lookup( "d-supp-grp-fin", use-table ) > 0 then do:
        find first d-supp-grp-fin where
                   d-supp-grp-fin.supp-type     = ?                      and
                   d-supp-grp-fin.supp-code     = ?                      and
                   d-supp-grp-fin.contract-code = bf_parts.contract-code and
                   d-supp-grp-fin.purch-code    = bf_parts.purch-code    and
                   d-supp-grp-fin.grp-code      = bf_goods.grp-code      no-error.
        if not available d-supp-grp-fin then do:
          create d-supp-grp-fin.
          assign d-supp-grp-fin.supp-type     = ?
                 d-supp-grp-fin.supp-code     = ?
                 d-supp-grp-fin.contract-code = bf_parts.contract-code
                 d-supp-grp-fin.purch-code    = bf_parts.purch-code
                 d-supp-grp-fin.grp-code      = bf_goods.grp-code
                 d-supp-grp-fin.supp-name     = "Разница при продаже-возврате"
                 d-supp-grp-fin.purch-name    = entry (lookup (string( bf_parts.purch-code ), '1,2,3,4':U), 'выкуп,консигнация,ответственное хранение,старая консигнация':U)
                 d-supp-grp-fin.grp-name      = varfull-name-grp.
        end.
      end.
      if lookup( "d-supp-slts-vats-cons", use-table ) > 0 then do:
        find first d-supp-slts-vats-cons where
                   d-supp-slts-vats-cons.supp-type  = ?                   and
                   d-supp-slts-vats-cons.supp-code  = ?                   and
                   d-supp-slts-vats-cons.vat-pc     = bf_parts.vat-pc     and
                   d-supp-slts-vats-cons.slt-pc     = bf_parts.slt-pc     and
                   d-supp-slts-vats-cons.purch-code = bf_parts.purch-code no-error.
        if not available d-supp-slts-vats-cons then do:
          create d-supp-slts-vats-cons.
          assign d-supp-slts-vats-cons.vat-pc     = bf_parts.vat-pc
                 d-supp-slts-vats-cons.slt-pc     = bf_parts.slt-pc
                 d-supp-slts-vats-cons.supp-type  = ?
                 d-supp-slts-vats-cons.supp-code  = ?
                 d-supp-slts-vats-cons.supp-name  = "Разница при продаже-возврате"
                 d-supp-slts-vats-cons.purch-code = bf_parts.purch-code
                 d-supp-slts-vats-cons.purch-name = entry (lookup (string( bf_parts.purch-code ), '1,2,3,4':U), 'выкуп,консигнация,ответственное хранение,старая консигнация':U).
        end.
      end.
      if lookup( "d-supp-slts-vats-cons-fin", use-table ) > 0 then do:
        find first d-supp-slts-vats-cons-fin where
                   d-supp-slts-vats-cons-fin.supp-type     = ?                      and
                   d-supp-slts-vats-cons-fin.supp-code     = ?                      and
                   d-supp-slts-vats-cons-fin.vat-pc        = bf_parts.vat-pc        and
                   d-supp-slts-vats-cons-fin.slt-pc        = bf_parts.slt-pc        and
                   d-supp-slts-vats-cons-fin.contract-code = bf_parts.contract-code and
                   d-supp-slts-vats-cons-fin.purch-code    = bf_parts.purch-code    no-error.
        if not available d-supp-slts-vats-cons-fin then do:
          create d-supp-slts-vats-cons-fin.
          assign d-supp-slts-vats-cons-fin.vat-pc        = bf_parts.vat-pc
                 d-supp-slts-vats-cons-fin.slt-pc        = bf_parts.slt-pc
                 d-supp-slts-vats-cons-fin.supp-type     = ?
                 d-supp-slts-vats-cons-fin.supp-code     = ?
                 d-supp-slts-vats-cons-fin.contract-code = bf_parts.contract-code
                 d-supp-slts-vats-cons-fin.supp-name     = "Разница при продаже-возврате"
                 d-supp-slts-vats-cons-fin.purch-code    = bf_parts.purch-code
                 d-supp-slts-vats-cons-fin.purch-name    = entry (lookup (string( bf_parts.purch-code ), '1,2,3,4':U), 'выкуп,консигнация,ответственное хранение,старая консигнация':U).
        end.
      end.
    end.
    else do:
      find first bf_clients no-lock where
                 bf_clients.obj-code = bf_parts.supp-code and
                 bf_clients.obj-type = bf_parts.supp-type.
      if lookup( "d-supp", use-table ) > 0 then do:
        find first d-supp where
                   d-supp.supp-type  = bf_parts.supp-type  and
                   d-supp.supp-code  = bf_parts.supp-code  and
                   d-supp.purch-code = bf_parts.purch-code no-error.
        if not available d-supp then do:
          create d-supp.
          assign d-supp.supp-type  = bf_parts.supp-type
                 d-supp.supp-code  = bf_parts.supp-code
                 d-supp.purch-code = bf_parts.purch-code
                 d-supp.supp-name  = bf_clients.obj-name
                 d-supp.purch-name = entry (lookup (string( bf_parts.purch-code ), '1,2,3,4':U), 'выкуп,консигнация,ответственное хранение,старая консигнация':U).
        end.
      end.
      if lookup( "d-supp-fin", use-table ) > 0 then do:
        find first d-supp-fin where
                   d-supp-fin.supp-type     = bf_parts.supp-type     and
                   d-supp-fin.supp-code     = bf_parts.supp-code     and
                   d-supp-fin.contract-code = bf_parts.contract-code and
                   d-supp-fin.purch-code    = bf_parts.purch-code    no-error.
        if not available d-supp-fin then do:
          create d-supp-fin.
          assign d-supp-fin.supp-type     = bf_parts.supp-type
                 d-supp-fin.supp-code     = bf_parts.supp-code
                 d-supp-fin.contract-code = bf_parts.contract-code
                 d-supp-fin.purch-code    = bf_parts.purch-code
                 d-supp-fin.supp-name     = bf_clients.obj-name
                 d-supp-fin.purch-name    = entry (lookup (string( bf_parts.purch-code ), '1,2,3,4':U), 'выкуп,консигнация,ответственное хранение,старая консигнация':U).
        end.
      end.
      if lookup( "d-supp-grp", use-table ) > 0 then do:
        find first d-supp-grp where
                   d-supp-grp.supp-type  = bf_parts.supp-type  and
                   d-supp-grp.supp-code  = bf_parts.supp-code  and
                   d-supp-grp.purch-code = bf_parts.purch-code and
                   d-supp-grp.grp-code   = bf_goods.grp-code   no-error.
        if not available d-supp-grp then do:
          create d-supp-grp.
          assign d-supp-grp.supp-type  = bf_parts.supp-type
                 d-supp-grp.supp-code  = bf_parts.supp-code
                 d-supp-grp.purch-code = bf_parts.purch-code
                 d-supp-grp.grp-code   = bf_goods.grp-code
                 d-supp-grp.supp-name  = bf_clients.obj-name
                 d-supp-grp.purch-name = entry (lookup (string( bf_parts.purch-code ), '1,2,3,4':U), 'выкуп,консигнация,ответственное хранение,старая консигнация':U)
                 d-supp-grp.grp-name   = varfull-name-grp.
        end.
      end.
      if lookup( "d-supp-grp-fin", use-table ) > 0 then do:
        find first d-supp-grp-fin where
                   d-supp-grp-fin.supp-type     = bf_parts.supp-type     and
                   d-supp-grp-fin.supp-code     = bf_parts.supp-code     and
                   d-supp-grp-fin.purch-code    = bf_parts.purch-code    and
                   d-supp-grp-fin.contract-code = bf_parts.contract-code and
                   d-supp-grp-fin.grp-code      = bf_goods.grp-code      no-error.
        if not available d-supp-grp-fin then do:
          create d-supp-grp-fin.
          assign d-supp-grp-fin.supp-type     = bf_parts.supp-type
                 d-supp-grp-fin.supp-code     = bf_parts.supp-code
                 d-supp-grp-fin.purch-code    = bf_parts.purch-code
                 d-supp-grp-fin.contract-code = bf_parts.contract-code
                 d-supp-grp-fin.grp-code      = bf_goods.grp-code
                 d-supp-grp-fin.supp-name     = bf_clients.obj-name
                 d-supp-grp-fin.purch-name    = entry (lookup (string( bf_parts.purch-code ), '1,2,3,4':U), 'выкуп,консигнация,ответственное хранение,старая консигнация':U)
                 d-supp-grp-fin.grp-name      = varfull-name-grp.
        end.
      end.
      if lookup( "d-supp-slts-vats-cons", use-table ) > 0 then do:
        find first d-supp-slts-vats-cons where
                   d-supp-slts-vats-cons.supp-type  = bf_parts.supp-type  and
                   d-supp-slts-vats-cons.supp-code  = bf_parts.supp-code  and
                   d-supp-slts-vats-cons.vat-pc     = bf_parts.vat-pc     and
                   d-supp-slts-vats-cons.slt-pc     = bf_parts.slt-pc     and
                   d-supp-slts-vats-cons.purch-code = bf_parts.purch-code no-error.
        if not available d-supp-slts-vats-cons then do:
          create d-supp-slts-vats-cons.
          assign d-supp-slts-vats-cons.vat-pc     = bf_parts.vat-pc
                 d-supp-slts-vats-cons.slt-pc     = bf_parts.slt-pc
                 d-supp-slts-vats-cons.supp-type  = bf_parts.supp-type
                 d-supp-slts-vats-cons.supp-code  = bf_parts.supp-code
                 d-supp-slts-vats-cons.supp-name  = bf_clients.obj-name
                 d-supp-slts-vats-cons.purch-code = bf_parts.purch-code
                 d-supp-slts-vats-cons.purch-name = entry (lookup (string( bf_parts.purch-code ), '1,2,3,4':U), 'выкуп,консигнация,ответственное хранение,старая консигнация':U).
        end.
      end.
      if lookup( "d-supp-slts-vats-cons-fin", use-table ) > 0 then do:
        find first d-supp-slts-vats-cons-fin where
                   d-supp-slts-vats-cons-fin.supp-type     = bf_parts.supp-type     and
                   d-supp-slts-vats-cons-fin.supp-code     = bf_parts.supp-code     and
                   d-supp-slts-vats-cons-fin.vat-pc        = bf_parts.vat-pc        and
                   d-supp-slts-vats-cons-fin.slt-pc        = bf_parts.slt-pc        and
                   d-supp-slts-vats-cons-fin.contract-code = bf_parts.contract-code and
                   d-supp-slts-vats-cons-fin.purch-code    = bf_parts.purch-code    no-error.
        if not available d-supp-slts-vats-cons-fin then do:
          create d-supp-slts-vats-cons-fin.
          assign d-supp-slts-vats-cons-fin.vat-pc        = bf_parts.vat-pc
                 d-supp-slts-vats-cons-fin.slt-pc        = bf_parts.slt-pc
                 d-supp-slts-vats-cons-fin.supp-type     = bf_parts.supp-type
                 d-supp-slts-vats-cons-fin.supp-code     = bf_parts.supp-code
                 d-supp-slts-vats-cons-fin.contract-code = bf_parts.contract-code
                 d-supp-slts-vats-cons-fin.supp-name     = bf_clients.obj-name
                 d-supp-slts-vats-cons-fin.purch-code    = bf_parts.purch-code
                 d-supp-slts-vats-cons-fin.purch-name    = entry (lookup (string( bf_parts.purch-code ), '1,2,3,4':U), 'выкуп,консигнация,ответственное хранение,старая консигнация':U).
        end.
      end.
    end.
    empty temp-table tt-allsum.
    empty temp-table tt-clcparts.
    create tt-clcparts.
    buffer-copy bf_parts to tt-clcparts.
    run clcprtsl_calc-parts in this-procedure ( input recid( tt-clcparts ),
                                                input yes,
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
                                                input varcur-slt-pc ).
    find first tt-allsum where tt-allsum.sum-type = 'основная_сумма':U.
              assign tt-title.fact-qnty           = tt-title.fact-qnty           + tt-allsum.fact-qnty                            tt-title.acc-base            = tt-title.acc-base            + tt-allsum.sum-dsc-base-acc                           tt-title.acc-rubl            = tt-title.acc-rubl            + tt-allsum.sum-dsc-rubl-acc                           tt-title.acc-vat-base        = tt-title.acc-vat-base        + tt-allsum.vat-base-acc                           tt-title.acc-vat-rubl        = tt-title.acc-vat-rubl        + tt-allsum.vat-rubl-acc                           tt-title.acc-slt-base        = tt-title.acc-slt-base        + tt-allsum.slt-base-acc                           tt-title.acc-slt-rubl        = tt-title.acc-slt-rubl        + tt-allsum.slt-rubl-acc                           tt-title.acc-road-tax-base   = tt-title.acc-road-tax-base   + tt-allsum.road-tax-base-acc                           tt-title.acc-road-tax-rubl   = tt-title.acc-road-tax-rubl   + tt-allsum.road-tax-rubl-acc                           tt-title.acc-excise-base     = tt-title.acc-excise-base     + tt-allsum.excise-base-acc                           tt-title.acc-excise-rubl     = tt-title.acc-excise-rubl     + tt-allsum.excise-rubl-acc                           tt-title.acc-transport-base  = tt-title.acc-transport-base  + tt-allsum.transport-base-acc                           tt-title.acc-transport-rubl  = tt-title.acc-transport-rubl  + tt-allsum.transport-rubl-acc                           tt-title.acc-other-base      = tt-title.acc-other-base      + tt-allsum.other-base-acc                           tt-title.acc-other-rubl      = tt-title.acc-other-rubl      + tt-allsum.other-rubl-acc                           tt-title.pay-base            = tt-title.pay-base            + tt-allsum.sum-dsc-base-doc                           tt-title.pay-rubl            = tt-title.pay-rubl            + tt-allsum.sum-dsc-rubl-doc                           tt-title.no-vat-base         = tt-title.no-vat-base         + tt-allsum.sum-dsc-base-doc - tt-allsum.vat-base-doc                           tt-title.no-vat-rubl         = tt-title.no-vat-rubl         + tt-allsum.sum-dsc-rubl-doc - tt-allsum.vat-rubl-doc                           tt-title.vat-base            = tt-title.vat-base            + tt-allsum.vat-base-doc                           tt-title.vat-rubl            = tt-title.vat-rubl            + tt-allsum.vat-rubl-doc                           tt-title.vat-base-buyer      = tt-title.vat-base-buyer      + tt-allsum.vat-base-buyer-doc                           tt-title.vat-rubl-buyer      = tt-title.vat-rubl-buyer      + tt-allsum.vat-rubl-buyer-doc                           tt-title.slt-base            = tt-title.slt-base            + tt-allsum.slt-base-doc                           tt-title.slt-rubl            = tt-title.slt-rubl            + tt-allsum.slt-rubl-doc                           tt-title.road-tax            = tt-title.road-tax            + (if varr-b = "base" then tt-allsum.road-tax-base-doc else tt-allsum.road-tax-rubl-doc)                           tt-title.excise              = tt-title.excise              + (if varr-b = "base" then tt-allsum.excise-base-doc   else tt-allsum.excise-rubl-doc)                             tt-title.sale-base           = tt-title.sale-base           + tt-allsum.sum-dsc-base-cur                           tt-title.sale-rubl           = tt-title.sale-rubl           + tt-allsum.sum-dsc-rubl-cur                           tt-title.sale-vat-base       = tt-title.sale-vat-base       + tt-allsum.vat-base-cur                               tt-title.sale-vat-rubl       = tt-title.sale-vat-rubl       + tt-allsum.vat-rubl-cur                               tt-title.sale-vat-buyer-base = tt-title.sale-vat-buyer-base + tt-allsum.vat-base-buyer-cur                           tt-title.sale-vat-buyer-rubl = tt-title.sale-vat-buyer-rubl + tt-allsum.vat-rubl-buyer-cur                           tt-title.sale-slt-base       = tt-title.sale-slt-base       + tt-allsum.slt-base-cur                                 tt-title.sale-slt-rubl       = tt-title.sale-slt-rubl       + tt-allsum.slt-rubl-cur                                 tt-title.sale-road-tax-base  = tt-title.sale-road-tax-base  + tt-allsum.road-tax-base-cur                            tt-title.sale-road-tax-rubl  = tt-title.sale-road-tax-rubl  + tt-allsum.road-tax-rubl-cur                            tt-title.sale-excise-base    = tt-title.sale-excise-base    + tt-allsum.excise-base-cur                              tt-title.sale-excise-rubl    = tt-title.sale-excise-rubl    + tt-allsum.excise-rubl-cur                              tt-title.ov-base             = tt-title.ov-base             + (if varr-b = "base" then (tt-allsum.sum-dsc-base-cur - tt-allsum.sum-dsc-base-doc) else (tt-allsum.sum-dsc-rubl-cur - tt-allsum.sum-dsc-rubl-doc))                           tt-title.ov-vat              = tt-title.ov-vat              + (if varr-b = "base" then (tt-allsum.sum-dsc-base-cur - tt-allsum.sum-dsc-base-doc) else (tt-allsum.sum-dsc-rubl-cur - tt-allsum.sum-dsc-rubl-doc)) * bf_doc-line.vat-pc / (100 + bf_doc-line.vat-pc).
          if varcalc-title-fin = yes then do:
       assign tt-title-fin.fact-qnty           = tt-title-fin.fact-qnty           + tt-allsum.fact-qnty                            tt-title-fin.acc-base            = tt-title-fin.acc-base            + tt-allsum.sum-dsc-base-acc                           tt-title-fin.acc-rubl            = tt-title-fin.acc-rubl            + tt-allsum.sum-dsc-rubl-acc                           tt-title-fin.acc-vat-base        = tt-title-fin.acc-vat-base        + tt-allsum.vat-base-acc                           tt-title-fin.acc-vat-rubl        = tt-title-fin.acc-vat-rubl        + tt-allsum.vat-rubl-acc                           tt-title-fin.acc-slt-base        = tt-title-fin.acc-slt-base        + tt-allsum.slt-base-acc                           tt-title-fin.acc-slt-rubl        = tt-title-fin.acc-slt-rubl        + tt-allsum.slt-rubl-acc                           tt-title-fin.acc-road-tax-base   = tt-title-fin.acc-road-tax-base   + tt-allsum.road-tax-base-acc                           tt-title-fin.acc-road-tax-rubl   = tt-title-fin.acc-road-tax-rubl   + tt-allsum.road-tax-rubl-acc                           tt-title-fin.acc-excise-base     = tt-title-fin.acc-excise-base     + tt-allsum.excise-base-acc                           tt-title-fin.acc-excise-rubl     = tt-title-fin.acc-excise-rubl     + tt-allsum.excise-rubl-acc                           tt-title-fin.acc-transport-base  = tt-title-fin.acc-transport-base  + tt-allsum.transport-base-acc                           tt-title-fin.acc-transport-rubl  = tt-title-fin.acc-transport-rubl  + tt-allsum.transport-rubl-acc                           tt-title-fin.acc-other-base      = tt-title-fin.acc-other-base      + tt-allsum.other-base-acc                           tt-title-fin.acc-other-rubl      = tt-title-fin.acc-other-rubl      + tt-allsum.other-rubl-acc                           tt-title-fin.pay-base            = tt-title-fin.pay-base            + tt-allsum.sum-dsc-base-doc                           tt-title-fin.pay-rubl            = tt-title-fin.pay-rubl            + tt-allsum.sum-dsc-rubl-doc                           tt-title-fin.no-vat-base         = tt-title-fin.no-vat-base         + tt-allsum.sum-dsc-base-doc - tt-allsum.vat-base-doc                           tt-title-fin.no-vat-rubl         = tt-title-fin.no-vat-rubl         + tt-allsum.sum-dsc-rubl-doc - tt-allsum.vat-rubl-doc                           tt-title-fin.vat-base            = tt-title-fin.vat-base            + tt-allsum.vat-base-doc                           tt-title-fin.vat-rubl            = tt-title-fin.vat-rubl            + tt-allsum.vat-rubl-doc                           tt-title-fin.vat-base-buyer      = tt-title-fin.vat-base-buyer      + tt-allsum.vat-base-buyer-doc                           tt-title-fin.vat-rubl-buyer      = tt-title-fin.vat-rubl-buyer      + tt-allsum.vat-rubl-buyer-doc                           tt-title-fin.slt-base            = tt-title-fin.slt-base            + tt-allsum.slt-base-doc                           tt-title-fin.slt-rubl            = tt-title-fin.slt-rubl            + tt-allsum.slt-rubl-doc                           tt-title-fin.road-tax            = tt-title-fin.road-tax            + (if varr-b = "base" then tt-allsum.road-tax-base-doc else tt-allsum.road-tax-rubl-doc)                           tt-title-fin.excise              = tt-title-fin.excise              + (if varr-b = "base" then tt-allsum.excise-base-doc   else tt-allsum.excise-rubl-doc)                             tt-title-fin.sale-base           = tt-title-fin.sale-base           + tt-allsum.sum-dsc-base-cur                           tt-title-fin.sale-rubl           = tt-title-fin.sale-rubl           + tt-allsum.sum-dsc-rubl-cur                           tt-title-fin.sale-vat-base       = tt-title-fin.sale-vat-base       + tt-allsum.vat-base-cur                               tt-title-fin.sale-vat-rubl       = tt-title-fin.sale-vat-rubl       + tt-allsum.vat-rubl-cur                               tt-title-fin.sale-vat-buyer-base = tt-title-fin.sale-vat-buyer-base + tt-allsum.vat-base-buyer-cur                           tt-title-fin.sale-vat-buyer-rubl = tt-title-fin.sale-vat-buyer-rubl + tt-allsum.vat-rubl-buyer-cur                           tt-title-fin.sale-slt-base       = tt-title-fin.sale-slt-base       + tt-allsum.slt-base-cur                                 tt-title-fin.sale-slt-rubl       = tt-title-fin.sale-slt-rubl       + tt-allsum.slt-rubl-cur                                 tt-title-fin.sale-road-tax-base  = tt-title-fin.sale-road-tax-base  + tt-allsum.road-tax-base-cur                            tt-title-fin.sale-road-tax-rubl  = tt-title-fin.sale-road-tax-rubl  + tt-allsum.road-tax-rubl-cur                            tt-title-fin.sale-excise-base    = tt-title-fin.sale-excise-base    + tt-allsum.excise-base-cur                              tt-title-fin.sale-excise-rubl    = tt-title-fin.sale-excise-rubl    + tt-allsum.excise-rubl-cur                              tt-title-fin.ov-base             = tt-title-fin.ov-base             + (if varr-b = "base" then (tt-allsum.sum-dsc-base-cur - tt-allsum.sum-dsc-base-doc) else (tt-allsum.sum-dsc-rubl-cur - tt-allsum.sum-dsc-rubl-doc))                           tt-title-fin.ov-vat              = tt-title-fin.ov-vat              + (if varr-b = "base" then (tt-allsum.sum-dsc-base-cur - tt-allsum.sum-dsc-base-doc) else (tt-allsum.sum-dsc-rubl-cur - tt-allsum.sum-dsc-rubl-doc)) * bf_doc-line.vat-pc / (100 + bf_doc-line.vat-pc).
     end.
          if lookup( "d-supp", use-table ) > 0 then do:
       assign d-supp.fact-qnty           = d-supp.fact-qnty           + tt-allsum.fact-qnty                            d-supp.acc-base            = d-supp.acc-base            + tt-allsum.sum-dsc-base-acc                           d-supp.acc-rubl            = d-supp.acc-rubl            + tt-allsum.sum-dsc-rubl-acc                           d-supp.acc-vat-base        = d-supp.acc-vat-base        + tt-allsum.vat-base-acc                           d-supp.acc-vat-rubl        = d-supp.acc-vat-rubl        + tt-allsum.vat-rubl-acc                           d-supp.acc-slt-base        = d-supp.acc-slt-base        + tt-allsum.slt-base-acc                           d-supp.acc-slt-rubl        = d-supp.acc-slt-rubl        + tt-allsum.slt-rubl-acc                           d-supp.acc-road-tax-base   = d-supp.acc-road-tax-base   + tt-allsum.road-tax-base-acc                           d-supp.acc-road-tax-rubl   = d-supp.acc-road-tax-rubl   + tt-allsum.road-tax-rubl-acc                           d-supp.acc-excise-base     = d-supp.acc-excise-base     + tt-allsum.excise-base-acc                           d-supp.acc-excise-rubl     = d-supp.acc-excise-rubl     + tt-allsum.excise-rubl-acc                           d-supp.acc-transport-base  = d-supp.acc-transport-base  + tt-allsum.transport-base-acc                           d-supp.acc-transport-rubl  = d-supp.acc-transport-rubl  + tt-allsum.transport-rubl-acc                           d-supp.acc-other-base      = d-supp.acc-other-base      + tt-allsum.other-base-acc                           d-supp.acc-other-rubl      = d-supp.acc-other-rubl      + tt-allsum.other-rubl-acc                           d-supp.pay-base            = d-supp.pay-base            + tt-allsum.sum-dsc-base-doc                           d-supp.pay-rubl            = d-supp.pay-rubl            + tt-allsum.sum-dsc-rubl-doc                           d-supp.no-vat-base         = d-supp.no-vat-base         + tt-allsum.sum-dsc-base-doc - tt-allsum.vat-base-doc                           d-supp.no-vat-rubl         = d-supp.no-vat-rubl         + tt-allsum.sum-dsc-rubl-doc - tt-allsum.vat-rubl-doc                           d-supp.vat-base            = d-supp.vat-base            + tt-allsum.vat-base-doc                           d-supp.vat-rubl            = d-supp.vat-rubl            + tt-allsum.vat-rubl-doc                           d-supp.vat-base-buyer      = d-supp.vat-base-buyer      + tt-allsum.vat-base-buyer-doc                           d-supp.vat-rubl-buyer      = d-supp.vat-rubl-buyer      + tt-allsum.vat-rubl-buyer-doc                           d-supp.slt-base            = d-supp.slt-base            + tt-allsum.slt-base-doc                           d-supp.slt-rubl            = d-supp.slt-rubl            + tt-allsum.slt-rubl-doc                           d-supp.road-tax            = d-supp.road-tax            + (if varr-b = "base" then tt-allsum.road-tax-base-doc else tt-allsum.road-tax-rubl-doc)                           d-supp.excise              = d-supp.excise              + (if varr-b = "base" then tt-allsum.excise-base-doc   else tt-allsum.excise-rubl-doc)                             d-supp.sale-base           = d-supp.sale-base           + tt-allsum.sum-dsc-base-cur                           d-supp.sale-rubl           = d-supp.sale-rubl           + tt-allsum.sum-dsc-rubl-cur                           d-supp.sale-vat-base       = d-supp.sale-vat-base       + tt-allsum.vat-base-cur                               d-supp.sale-vat-rubl       = d-supp.sale-vat-rubl       + tt-allsum.vat-rubl-cur                               d-supp.sale-vat-buyer-base = d-supp.sale-vat-buyer-base + tt-allsum.vat-base-buyer-cur                           d-supp.sale-vat-buyer-rubl = d-supp.sale-vat-buyer-rubl + tt-allsum.vat-rubl-buyer-cur                           d-supp.sale-slt-base       = d-supp.sale-slt-base       + tt-allsum.slt-base-cur                                 d-supp.sale-slt-rubl       = d-supp.sale-slt-rubl       + tt-allsum.slt-rubl-cur                                 d-supp.sale-road-tax-base  = d-supp.sale-road-tax-base  + tt-allsum.road-tax-base-cur                            d-supp.sale-road-tax-rubl  = d-supp.sale-road-tax-rubl  + tt-allsum.road-tax-rubl-cur                            d-supp.sale-excise-base    = d-supp.sale-excise-base    + tt-allsum.excise-base-cur                              d-supp.sale-excise-rubl    = d-supp.sale-excise-rubl    + tt-allsum.excise-rubl-cur                              d-supp.ov-base             = d-supp.ov-base             + (if varr-b = "base" then (tt-allsum.sum-dsc-base-cur - tt-allsum.sum-dsc-base-doc) else (tt-allsum.sum-dsc-rubl-cur - tt-allsum.sum-dsc-rubl-doc))                           d-supp.ov-vat              = d-supp.ov-vat              + (if varr-b = "base" then (tt-allsum.sum-dsc-base-cur - tt-allsum.sum-dsc-base-doc) else (tt-allsum.sum-dsc-rubl-cur - tt-allsum.sum-dsc-rubl-doc)) * bf_doc-line.vat-pc / (100 + bf_doc-line.vat-pc).
     end.
          if lookup( "d-supp-fin", use-table ) > 0 then do:
       assign d-supp-fin.fact-qnty           = d-supp-fin.fact-qnty           + tt-allsum.fact-qnty                            d-supp-fin.acc-base            = d-supp-fin.acc-base            + tt-allsum.sum-dsc-base-acc                           d-supp-fin.acc-rubl            = d-supp-fin.acc-rubl            + tt-allsum.sum-dsc-rubl-acc                           d-supp-fin.acc-vat-base        = d-supp-fin.acc-vat-base        + tt-allsum.vat-base-acc                           d-supp-fin.acc-vat-rubl        = d-supp-fin.acc-vat-rubl        + tt-allsum.vat-rubl-acc                           d-supp-fin.acc-slt-base        = d-supp-fin.acc-slt-base        + tt-allsum.slt-base-acc                           d-supp-fin.acc-slt-rubl        = d-supp-fin.acc-slt-rubl        + tt-allsum.slt-rubl-acc                           d-supp-fin.acc-road-tax-base   = d-supp-fin.acc-road-tax-base   + tt-allsum.road-tax-base-acc                           d-supp-fin.acc-road-tax-rubl   = d-supp-fin.acc-road-tax-rubl   + tt-allsum.road-tax-rubl-acc                           d-supp-fin.acc-excise-base     = d-supp-fin.acc-excise-base     + tt-allsum.excise-base-acc                           d-supp-fin.acc-excise-rubl     = d-supp-fin.acc-excise-rubl     + tt-allsum.excise-rubl-acc                           d-supp-fin.acc-transport-base  = d-supp-fin.acc-transport-base  + tt-allsum.transport-base-acc                           d-supp-fin.acc-transport-rubl  = d-supp-fin.acc-transport-rubl  + tt-allsum.transport-rubl-acc                           d-supp-fin.acc-other-base      = d-supp-fin.acc-other-base      + tt-allsum.other-base-acc                           d-supp-fin.acc-other-rubl      = d-supp-fin.acc-other-rubl      + tt-allsum.other-rubl-acc                           d-supp-fin.pay-base            = d-supp-fin.pay-base            + tt-allsum.sum-dsc-base-doc                           d-supp-fin.pay-rubl            = d-supp-fin.pay-rubl            + tt-allsum.sum-dsc-rubl-doc                           d-supp-fin.no-vat-base         = d-supp-fin.no-vat-base         + tt-allsum.sum-dsc-base-doc - tt-allsum.vat-base-doc                           d-supp-fin.no-vat-rubl         = d-supp-fin.no-vat-rubl         + tt-allsum.sum-dsc-rubl-doc - tt-allsum.vat-rubl-doc                           d-supp-fin.vat-base            = d-supp-fin.vat-base            + tt-allsum.vat-base-doc                           d-supp-fin.vat-rubl            = d-supp-fin.vat-rubl            + tt-allsum.vat-rubl-doc                           d-supp-fin.vat-base-buyer      = d-supp-fin.vat-base-buyer      + tt-allsum.vat-base-buyer-doc                           d-supp-fin.vat-rubl-buyer      = d-supp-fin.vat-rubl-buyer      + tt-allsum.vat-rubl-buyer-doc                           d-supp-fin.slt-base            = d-supp-fin.slt-base            + tt-allsum.slt-base-doc                           d-supp-fin.slt-rubl            = d-supp-fin.slt-rubl            + tt-allsum.slt-rubl-doc                           d-supp-fin.road-tax            = d-supp-fin.road-tax            + (if varr-b = "base" then tt-allsum.road-tax-base-doc else tt-allsum.road-tax-rubl-doc)                           d-supp-fin.excise              = d-supp-fin.excise              + (if varr-b = "base" then tt-allsum.excise-base-doc   else tt-allsum.excise-rubl-doc)                             d-supp-fin.sale-base           = d-supp-fin.sale-base           + tt-allsum.sum-dsc-base-cur                           d-supp-fin.sale-rubl           = d-supp-fin.sale-rubl           + tt-allsum.sum-dsc-rubl-cur                           d-supp-fin.sale-vat-base       = d-supp-fin.sale-vat-base       + tt-allsum.vat-base-cur                               d-supp-fin.sale-vat-rubl       = d-supp-fin.sale-vat-rubl       + tt-allsum.vat-rubl-cur                               d-supp-fin.sale-vat-buyer-base = d-supp-fin.sale-vat-buyer-base + tt-allsum.vat-base-buyer-cur                           d-supp-fin.sale-vat-buyer-rubl = d-supp-fin.sale-vat-buyer-rubl + tt-allsum.vat-rubl-buyer-cur                           d-supp-fin.sale-slt-base       = d-supp-fin.sale-slt-base       + tt-allsum.slt-base-cur                                 d-supp-fin.sale-slt-rubl       = d-supp-fin.sale-slt-rubl       + tt-allsum.slt-rubl-cur                                 d-supp-fin.sale-road-tax-base  = d-supp-fin.sale-road-tax-base  + tt-allsum.road-tax-base-cur                            d-supp-fin.sale-road-tax-rubl  = d-supp-fin.sale-road-tax-rubl  + tt-allsum.road-tax-rubl-cur                            d-supp-fin.sale-excise-base    = d-supp-fin.sale-excise-base    + tt-allsum.excise-base-cur                              d-supp-fin.sale-excise-rubl    = d-supp-fin.sale-excise-rubl    + tt-allsum.excise-rubl-cur                              d-supp-fin.ov-base             = d-supp-fin.ov-base             + (if varr-b = "base" then (tt-allsum.sum-dsc-base-cur - tt-allsum.sum-dsc-base-doc) else (tt-allsum.sum-dsc-rubl-cur - tt-allsum.sum-dsc-rubl-doc))                           d-supp-fin.ov-vat              = d-supp-fin.ov-vat              + (if varr-b = "base" then (tt-allsum.sum-dsc-base-cur - tt-allsum.sum-dsc-base-doc) else (tt-allsum.sum-dsc-rubl-cur - tt-allsum.sum-dsc-rubl-doc)) * bf_doc-line.vat-pc / (100 + bf_doc-line.vat-pc).
     end.
          if lookup( "d-supp-grp", use-table ) > 0 then do:
       assign d-supp-grp.fact-qnty           = d-supp-grp.fact-qnty           + tt-allsum.fact-qnty                            d-supp-grp.acc-base            = d-supp-grp.acc-base            + tt-allsum.sum-dsc-base-acc                           d-supp-grp.acc-rubl            = d-supp-grp.acc-rubl            + tt-allsum.sum-dsc-rubl-acc                           d-supp-grp.acc-vat-base        = d-supp-grp.acc-vat-base        + tt-allsum.vat-base-acc                           d-supp-grp.acc-vat-rubl        = d-supp-grp.acc-vat-rubl        + tt-allsum.vat-rubl-acc                           d-supp-grp.acc-slt-base        = d-supp-grp.acc-slt-base        + tt-allsum.slt-base-acc                           d-supp-grp.acc-slt-rubl        = d-supp-grp.acc-slt-rubl        + tt-allsum.slt-rubl-acc                           d-supp-grp.acc-road-tax-base   = d-supp-grp.acc-road-tax-base   + tt-allsum.road-tax-base-acc                           d-supp-grp.acc-road-tax-rubl   = d-supp-grp.acc-road-tax-rubl   + tt-allsum.road-tax-rubl-acc                           d-supp-grp.acc-excise-base     = d-supp-grp.acc-excise-base     + tt-allsum.excise-base-acc                           d-supp-grp.acc-excise-rubl     = d-supp-grp.acc-excise-rubl     + tt-allsum.excise-rubl-acc                           d-supp-grp.acc-transport-base  = d-supp-grp.acc-transport-base  + tt-allsum.transport-base-acc                           d-supp-grp.acc-transport-rubl  = d-supp-grp.acc-transport-rubl  + tt-allsum.transport-rubl-acc                           d-supp-grp.acc-other-base      = d-supp-grp.acc-other-base      + tt-allsum.other-base-acc                           d-supp-grp.acc-other-rubl      = d-supp-grp.acc-other-rubl      + tt-allsum.other-rubl-acc                           d-supp-grp.pay-base            = d-supp-grp.pay-base            + tt-allsum.sum-dsc-base-doc                           d-supp-grp.pay-rubl            = d-supp-grp.pay-rubl            + tt-allsum.sum-dsc-rubl-doc                           d-supp-grp.no-vat-base         = d-supp-grp.no-vat-base         + tt-allsum.sum-dsc-base-doc - tt-allsum.vat-base-doc                           d-supp-grp.no-vat-rubl         = d-supp-grp.no-vat-rubl         + tt-allsum.sum-dsc-rubl-doc - tt-allsum.vat-rubl-doc                           d-supp-grp.vat-base            = d-supp-grp.vat-base            + tt-allsum.vat-base-doc                           d-supp-grp.vat-rubl            = d-supp-grp.vat-rubl            + tt-allsum.vat-rubl-doc                           d-supp-grp.vat-base-buyer      = d-supp-grp.vat-base-buyer      + tt-allsum.vat-base-buyer-doc                           d-supp-grp.vat-rubl-buyer      = d-supp-grp.vat-rubl-buyer      + tt-allsum.vat-rubl-buyer-doc                           d-supp-grp.slt-base            = d-supp-grp.slt-base            + tt-allsum.slt-base-doc                           d-supp-grp.slt-rubl            = d-supp-grp.slt-rubl            + tt-allsum.slt-rubl-doc                           d-supp-grp.road-tax            = d-supp-grp.road-tax            + (if varr-b = "base" then tt-allsum.road-tax-base-doc else tt-allsum.road-tax-rubl-doc)                           d-supp-grp.excise              = d-supp-grp.excise              + (if varr-b = "base" then tt-allsum.excise-base-doc   else tt-allsum.excise-rubl-doc)                             d-supp-grp.sale-base           = d-supp-grp.sale-base           + tt-allsum.sum-dsc-base-cur                           d-supp-grp.sale-rubl           = d-supp-grp.sale-rubl           + tt-allsum.sum-dsc-rubl-cur                           d-supp-grp.sale-vat-base       = d-supp-grp.sale-vat-base       + tt-allsum.vat-base-cur                               d-supp-grp.sale-vat-rubl       = d-supp-grp.sale-vat-rubl       + tt-allsum.vat-rubl-cur                               d-supp-grp.sale-vat-buyer-base = d-supp-grp.sale-vat-buyer-base + tt-allsum.vat-base-buyer-cur                           d-supp-grp.sale-vat-buyer-rubl = d-supp-grp.sale-vat-buyer-rubl + tt-allsum.vat-rubl-buyer-cur                           d-supp-grp.sale-slt-base       = d-supp-grp.sale-slt-base       + tt-allsum.slt-base-cur                                 d-supp-grp.sale-slt-rubl       = d-supp-grp.sale-slt-rubl       + tt-allsum.slt-rubl-cur                                 d-supp-grp.sale-road-tax-base  = d-supp-grp.sale-road-tax-base  + tt-allsum.road-tax-base-cur                            d-supp-grp.sale-road-tax-rubl  = d-supp-grp.sale-road-tax-rubl  + tt-allsum.road-tax-rubl-cur                            d-supp-grp.sale-excise-base    = d-supp-grp.sale-excise-base    + tt-allsum.excise-base-cur                              d-supp-grp.sale-excise-rubl    = d-supp-grp.sale-excise-rubl    + tt-allsum.excise-rubl-cur                              d-supp-grp.ov-base             = d-supp-grp.ov-base             + (if varr-b = "base" then (tt-allsum.sum-dsc-base-cur - tt-allsum.sum-dsc-base-doc) else (tt-allsum.sum-dsc-rubl-cur - tt-allsum.sum-dsc-rubl-doc))                           d-supp-grp.ov-vat              = d-supp-grp.ov-vat              + (if varr-b = "base" then (tt-allsum.sum-dsc-base-cur - tt-allsum.sum-dsc-base-doc) else (tt-allsum.sum-dsc-rubl-cur - tt-allsum.sum-dsc-rubl-doc)) * bf_doc-line.vat-pc / (100 + bf_doc-line.vat-pc).
     end.
          if lookup( "d-supp-grp-fin", use-table ) > 0 then do:
       assign d-supp-grp-fin.fact-qnty           = d-supp-grp-fin.fact-qnty           + tt-allsum.fact-qnty                            d-supp-grp-fin.acc-base            = d-supp-grp-fin.acc-base            + tt-allsum.sum-dsc-base-acc                           d-supp-grp-fin.acc-rubl            = d-supp-grp-fin.acc-rubl            + tt-allsum.sum-dsc-rubl-acc                           d-supp-grp-fin.acc-vat-base        = d-supp-grp-fin.acc-vat-base        + tt-allsum.vat-base-acc                           d-supp-grp-fin.acc-vat-rubl        = d-supp-grp-fin.acc-vat-rubl        + tt-allsum.vat-rubl-acc                           d-supp-grp-fin.acc-slt-base        = d-supp-grp-fin.acc-slt-base        + tt-allsum.slt-base-acc                           d-supp-grp-fin.acc-slt-rubl        = d-supp-grp-fin.acc-slt-rubl        + tt-allsum.slt-rubl-acc                           d-supp-grp-fin.acc-road-tax-base   = d-supp-grp-fin.acc-road-tax-base   + tt-allsum.road-tax-base-acc                           d-supp-grp-fin.acc-road-tax-rubl   = d-supp-grp-fin.acc-road-tax-rubl   + tt-allsum.road-tax-rubl-acc                           d-supp-grp-fin.acc-excise-base     = d-supp-grp-fin.acc-excise-base     + tt-allsum.excise-base-acc                           d-supp-grp-fin.acc-excise-rubl     = d-supp-grp-fin.acc-excise-rubl     + tt-allsum.excise-rubl-acc                           d-supp-grp-fin.acc-transport-base  = d-supp-grp-fin.acc-transport-base  + tt-allsum.transport-base-acc                           d-supp-grp-fin.acc-transport-rubl  = d-supp-grp-fin.acc-transport-rubl  + tt-allsum.transport-rubl-acc                           d-supp-grp-fin.acc-other-base      = d-supp-grp-fin.acc-other-base      + tt-allsum.other-base-acc                           d-supp-grp-fin.acc-other-rubl      = d-supp-grp-fin.acc-other-rubl      + tt-allsum.other-rubl-acc                           d-supp-grp-fin.pay-base            = d-supp-grp-fin.pay-base            + tt-allsum.sum-dsc-base-doc                           d-supp-grp-fin.pay-rubl            = d-supp-grp-fin.pay-rubl            + tt-allsum.sum-dsc-rubl-doc                           d-supp-grp-fin.no-vat-base         = d-supp-grp-fin.no-vat-base         + tt-allsum.sum-dsc-base-doc - tt-allsum.vat-base-doc                           d-supp-grp-fin.no-vat-rubl         = d-supp-grp-fin.no-vat-rubl         + tt-allsum.sum-dsc-rubl-doc - tt-allsum.vat-rubl-doc                           d-supp-grp-fin.vat-base            = d-supp-grp-fin.vat-base            + tt-allsum.vat-base-doc                           d-supp-grp-fin.vat-rubl            = d-supp-grp-fin.vat-rubl            + tt-allsum.vat-rubl-doc                           d-supp-grp-fin.vat-base-buyer      = d-supp-grp-fin.vat-base-buyer      + tt-allsum.vat-base-buyer-doc                           d-supp-grp-fin.vat-rubl-buyer      = d-supp-grp-fin.vat-rubl-buyer      + tt-allsum.vat-rubl-buyer-doc                           d-supp-grp-fin.slt-base            = d-supp-grp-fin.slt-base            + tt-allsum.slt-base-doc                           d-supp-grp-fin.slt-rubl            = d-supp-grp-fin.slt-rubl            + tt-allsum.slt-rubl-doc                           d-supp-grp-fin.road-tax            = d-supp-grp-fin.road-tax            + (if varr-b = "base" then tt-allsum.road-tax-base-doc else tt-allsum.road-tax-rubl-doc)                           d-supp-grp-fin.excise              = d-supp-grp-fin.excise              + (if varr-b = "base" then tt-allsum.excise-base-doc   else tt-allsum.excise-rubl-doc)                             d-supp-grp-fin.sale-base           = d-supp-grp-fin.sale-base           + tt-allsum.sum-dsc-base-cur                           d-supp-grp-fin.sale-rubl           = d-supp-grp-fin.sale-rubl           + tt-allsum.sum-dsc-rubl-cur                           d-supp-grp-fin.sale-vat-base       = d-supp-grp-fin.sale-vat-base       + tt-allsum.vat-base-cur                               d-supp-grp-fin.sale-vat-rubl       = d-supp-grp-fin.sale-vat-rubl       + tt-allsum.vat-rubl-cur                               d-supp-grp-fin.sale-vat-buyer-base = d-supp-grp-fin.sale-vat-buyer-base + tt-allsum.vat-base-buyer-cur                           d-supp-grp-fin.sale-vat-buyer-rubl = d-supp-grp-fin.sale-vat-buyer-rubl + tt-allsum.vat-rubl-buyer-cur                           d-supp-grp-fin.sale-slt-base       = d-supp-grp-fin.sale-slt-base       + tt-allsum.slt-base-cur                                 d-supp-grp-fin.sale-slt-rubl       = d-supp-grp-fin.sale-slt-rubl       + tt-allsum.slt-rubl-cur                                 d-supp-grp-fin.sale-road-tax-base  = d-supp-grp-fin.sale-road-tax-base  + tt-allsum.road-tax-base-cur                            d-supp-grp-fin.sale-road-tax-rubl  = d-supp-grp-fin.sale-road-tax-rubl  + tt-allsum.road-tax-rubl-cur                            d-supp-grp-fin.sale-excise-base    = d-supp-grp-fin.sale-excise-base    + tt-allsum.excise-base-cur                              d-supp-grp-fin.sale-excise-rubl    = d-supp-grp-fin.sale-excise-rubl    + tt-allsum.excise-rubl-cur                              d-supp-grp-fin.ov-base             = d-supp-grp-fin.ov-base             + (if varr-b = "base" then (tt-allsum.sum-dsc-base-cur - tt-allsum.sum-dsc-base-doc) else (tt-allsum.sum-dsc-rubl-cur - tt-allsum.sum-dsc-rubl-doc))                           d-supp-grp-fin.ov-vat              = d-supp-grp-fin.ov-vat              + (if varr-b = "base" then (tt-allsum.sum-dsc-base-cur - tt-allsum.sum-dsc-base-doc) else (tt-allsum.sum-dsc-rubl-cur - tt-allsum.sum-dsc-rubl-doc)) * bf_doc-line.vat-pc / (100 + bf_doc-line.vat-pc).
     end.
          if lookup( "d-slt-vat", use-table ) > 0 then do:
       assign d-slt-vat.fact-qnty           = d-slt-vat.fact-qnty           + tt-allsum.fact-qnty                            d-slt-vat.acc-base            = d-slt-vat.acc-base            + tt-allsum.sum-dsc-base-acc                           d-slt-vat.acc-rubl            = d-slt-vat.acc-rubl            + tt-allsum.sum-dsc-rubl-acc                           d-slt-vat.acc-vat-base        = d-slt-vat.acc-vat-base        + tt-allsum.vat-base-acc                           d-slt-vat.acc-vat-rubl        = d-slt-vat.acc-vat-rubl        + tt-allsum.vat-rubl-acc                           d-slt-vat.acc-slt-base        = d-slt-vat.acc-slt-base        + tt-allsum.slt-base-acc                           d-slt-vat.acc-slt-rubl        = d-slt-vat.acc-slt-rubl        + tt-allsum.slt-rubl-acc                           d-slt-vat.acc-road-tax-base   = d-slt-vat.acc-road-tax-base   + tt-allsum.road-tax-base-acc                           d-slt-vat.acc-road-tax-rubl   = d-slt-vat.acc-road-tax-rubl   + tt-allsum.road-tax-rubl-acc                           d-slt-vat.acc-excise-base     = d-slt-vat.acc-excise-base     + tt-allsum.excise-base-acc                           d-slt-vat.acc-excise-rubl     = d-slt-vat.acc-excise-rubl     + tt-allsum.excise-rubl-acc                           d-slt-vat.acc-transport-base  = d-slt-vat.acc-transport-base  + tt-allsum.transport-base-acc                           d-slt-vat.acc-transport-rubl  = d-slt-vat.acc-transport-rubl  + tt-allsum.transport-rubl-acc                           d-slt-vat.acc-other-base      = d-slt-vat.acc-other-base      + tt-allsum.other-base-acc                           d-slt-vat.acc-other-rubl      = d-slt-vat.acc-other-rubl      + tt-allsum.other-rubl-acc                           d-slt-vat.pay-base            = d-slt-vat.pay-base            + tt-allsum.sum-dsc-base-doc                           d-slt-vat.pay-rubl            = d-slt-vat.pay-rubl            + tt-allsum.sum-dsc-rubl-doc                           d-slt-vat.no-vat-base         = d-slt-vat.no-vat-base         + tt-allsum.sum-dsc-base-doc - tt-allsum.vat-base-doc                           d-slt-vat.no-vat-rubl         = d-slt-vat.no-vat-rubl         + tt-allsum.sum-dsc-rubl-doc - tt-allsum.vat-rubl-doc                           d-slt-vat.vat-base            = d-slt-vat.vat-base            + tt-allsum.vat-base-doc                           d-slt-vat.vat-rubl            = d-slt-vat.vat-rubl            + tt-allsum.vat-rubl-doc                           d-slt-vat.vat-base-buyer      = d-slt-vat.vat-base-buyer      + tt-allsum.vat-base-buyer-doc                           d-slt-vat.vat-rubl-buyer      = d-slt-vat.vat-rubl-buyer      + tt-allsum.vat-rubl-buyer-doc                           d-slt-vat.slt-base            = d-slt-vat.slt-base            + tt-allsum.slt-base-doc                           d-slt-vat.slt-rubl            = d-slt-vat.slt-rubl            + tt-allsum.slt-rubl-doc                           d-slt-vat.road-tax            = d-slt-vat.road-tax            + (if varr-b = "base" then tt-allsum.road-tax-base-doc else tt-allsum.road-tax-rubl-doc)                           d-slt-vat.excise              = d-slt-vat.excise              + (if varr-b = "base" then tt-allsum.excise-base-doc   else tt-allsum.excise-rubl-doc)                             d-slt-vat.sale-base           = d-slt-vat.sale-base           + tt-allsum.sum-dsc-base-cur                           d-slt-vat.sale-rubl           = d-slt-vat.sale-rubl           + tt-allsum.sum-dsc-rubl-cur                           d-slt-vat.sale-vat-base       = d-slt-vat.sale-vat-base       + tt-allsum.vat-base-cur                               d-slt-vat.sale-vat-rubl       = d-slt-vat.sale-vat-rubl       + tt-allsum.vat-rubl-cur                               d-slt-vat.sale-vat-buyer-base = d-slt-vat.sale-vat-buyer-base + tt-allsum.vat-base-buyer-cur                           d-slt-vat.sale-vat-buyer-rubl = d-slt-vat.sale-vat-buyer-rubl + tt-allsum.vat-rubl-buyer-cur                           d-slt-vat.sale-slt-base       = d-slt-vat.sale-slt-base       + tt-allsum.slt-base-cur                                 d-slt-vat.sale-slt-rubl       = d-slt-vat.sale-slt-rubl       + tt-allsum.slt-rubl-cur                                 d-slt-vat.sale-road-tax-base  = d-slt-vat.sale-road-tax-base  + tt-allsum.road-tax-base-cur                            d-slt-vat.sale-road-tax-rubl  = d-slt-vat.sale-road-tax-rubl  + tt-allsum.road-tax-rubl-cur                            d-slt-vat.sale-excise-base    = d-slt-vat.sale-excise-base    + tt-allsum.excise-base-cur                              d-slt-vat.sale-excise-rubl    = d-slt-vat.sale-excise-rubl    + tt-allsum.excise-rubl-cur                              d-slt-vat.ov-base             = d-slt-vat.ov-base             + (if varr-b = "base" then (tt-allsum.sum-dsc-base-cur - tt-allsum.sum-dsc-base-doc) else (tt-allsum.sum-dsc-rubl-cur - tt-allsum.sum-dsc-rubl-doc))                           d-slt-vat.ov-vat              = d-slt-vat.ov-vat              + (if varr-b = "base" then (tt-allsum.sum-dsc-base-cur - tt-allsum.sum-dsc-base-doc) else (tt-allsum.sum-dsc-rubl-cur - tt-allsum.sum-dsc-rubl-doc)) * bf_doc-line.vat-pc / (100 + bf_doc-line.vat-pc).
     end.
          if lookup( "d-slt-vat-cons", use-table ) > 0 then do:
       assign d-slt-vat-cons.fact-qnty           = d-slt-vat-cons.fact-qnty           + tt-allsum.fact-qnty                            d-slt-vat-cons.acc-base            = d-slt-vat-cons.acc-base            + tt-allsum.sum-dsc-base-acc                           d-slt-vat-cons.acc-rubl            = d-slt-vat-cons.acc-rubl            + tt-allsum.sum-dsc-rubl-acc                           d-slt-vat-cons.acc-vat-base        = d-slt-vat-cons.acc-vat-base        + tt-allsum.vat-base-acc                           d-slt-vat-cons.acc-vat-rubl        = d-slt-vat-cons.acc-vat-rubl        + tt-allsum.vat-rubl-acc                           d-slt-vat-cons.acc-slt-base        = d-slt-vat-cons.acc-slt-base        + tt-allsum.slt-base-acc                           d-slt-vat-cons.acc-slt-rubl        = d-slt-vat-cons.acc-slt-rubl        + tt-allsum.slt-rubl-acc                           d-slt-vat-cons.acc-road-tax-base   = d-slt-vat-cons.acc-road-tax-base   + tt-allsum.road-tax-base-acc                           d-slt-vat-cons.acc-road-tax-rubl   = d-slt-vat-cons.acc-road-tax-rubl   + tt-allsum.road-tax-rubl-acc                           d-slt-vat-cons.acc-excise-base     = d-slt-vat-cons.acc-excise-base     + tt-allsum.excise-base-acc                           d-slt-vat-cons.acc-excise-rubl     = d-slt-vat-cons.acc-excise-rubl     + tt-allsum.excise-rubl-acc                           d-slt-vat-cons.acc-transport-base  = d-slt-vat-cons.acc-transport-base  + tt-allsum.transport-base-acc                           d-slt-vat-cons.acc-transport-rubl  = d-slt-vat-cons.acc-transport-rubl  + tt-allsum.transport-rubl-acc                           d-slt-vat-cons.acc-other-base      = d-slt-vat-cons.acc-other-base      + tt-allsum.other-base-acc                           d-slt-vat-cons.acc-other-rubl      = d-slt-vat-cons.acc-other-rubl      + tt-allsum.other-rubl-acc                           d-slt-vat-cons.pay-base            = d-slt-vat-cons.pay-base            + tt-allsum.sum-dsc-base-doc                           d-slt-vat-cons.pay-rubl            = d-slt-vat-cons.pay-rubl            + tt-allsum.sum-dsc-rubl-doc                           d-slt-vat-cons.no-vat-base         = d-slt-vat-cons.no-vat-base         + tt-allsum.sum-dsc-base-doc - tt-allsum.vat-base-doc                           d-slt-vat-cons.no-vat-rubl         = d-slt-vat-cons.no-vat-rubl         + tt-allsum.sum-dsc-rubl-doc - tt-allsum.vat-rubl-doc                           d-slt-vat-cons.vat-base            = d-slt-vat-cons.vat-base            + tt-allsum.vat-base-doc                           d-slt-vat-cons.vat-rubl            = d-slt-vat-cons.vat-rubl            + tt-allsum.vat-rubl-doc                           d-slt-vat-cons.vat-base-buyer      = d-slt-vat-cons.vat-base-buyer      + tt-allsum.vat-base-buyer-doc                           d-slt-vat-cons.vat-rubl-buyer      = d-slt-vat-cons.vat-rubl-buyer      + tt-allsum.vat-rubl-buyer-doc                           d-slt-vat-cons.slt-base            = d-slt-vat-cons.slt-base            + tt-allsum.slt-base-doc                           d-slt-vat-cons.slt-rubl            = d-slt-vat-cons.slt-rubl            + tt-allsum.slt-rubl-doc                           d-slt-vat-cons.road-tax            = d-slt-vat-cons.road-tax            + (if varr-b = "base" then tt-allsum.road-tax-base-doc else tt-allsum.road-tax-rubl-doc)                           d-slt-vat-cons.excise              = d-slt-vat-cons.excise              + (if varr-b = "base" then tt-allsum.excise-base-doc   else tt-allsum.excise-rubl-doc)                             d-slt-vat-cons.sale-base           = d-slt-vat-cons.sale-base           + tt-allsum.sum-dsc-base-cur                           d-slt-vat-cons.sale-rubl           = d-slt-vat-cons.sale-rubl           + tt-allsum.sum-dsc-rubl-cur                           d-slt-vat-cons.sale-vat-base       = d-slt-vat-cons.sale-vat-base       + tt-allsum.vat-base-cur                               d-slt-vat-cons.sale-vat-rubl       = d-slt-vat-cons.sale-vat-rubl       + tt-allsum.vat-rubl-cur                               d-slt-vat-cons.sale-vat-buyer-base = d-slt-vat-cons.sale-vat-buyer-base + tt-allsum.vat-base-buyer-cur                           d-slt-vat-cons.sale-vat-buyer-rubl = d-slt-vat-cons.sale-vat-buyer-rubl + tt-allsum.vat-rubl-buyer-cur                           d-slt-vat-cons.sale-slt-base       = d-slt-vat-cons.sale-slt-base       + tt-allsum.slt-base-cur                                 d-slt-vat-cons.sale-slt-rubl       = d-slt-vat-cons.sale-slt-rubl       + tt-allsum.slt-rubl-cur                                 d-slt-vat-cons.sale-road-tax-base  = d-slt-vat-cons.sale-road-tax-base  + tt-allsum.road-tax-base-cur                            d-slt-vat-cons.sale-road-tax-rubl  = d-slt-vat-cons.sale-road-tax-rubl  + tt-allsum.road-tax-rubl-cur                            d-slt-vat-cons.sale-excise-base    = d-slt-vat-cons.sale-excise-base    + tt-allsum.excise-base-cur                              d-slt-vat-cons.sale-excise-rubl    = d-slt-vat-cons.sale-excise-rubl    + tt-allsum.excise-rubl-cur                              d-slt-vat-cons.ov-base             = d-slt-vat-cons.ov-base             + (if varr-b = "base" then (tt-allsum.sum-dsc-base-cur - tt-allsum.sum-dsc-base-doc) else (tt-allsum.sum-dsc-rubl-cur - tt-allsum.sum-dsc-rubl-doc))                           d-slt-vat-cons.ov-vat              = d-slt-vat-cons.ov-vat              + (if varr-b = "base" then (tt-allsum.sum-dsc-base-cur - tt-allsum.sum-dsc-base-doc) else (tt-allsum.sum-dsc-rubl-cur - tt-allsum.sum-dsc-rubl-doc)) * bf_doc-line.vat-pc / (100 + bf_doc-line.vat-pc).
     end.
          if lookup( "d-slt-vat-cons-fin", use-table ) > 0 then do:
       assign d-slt-vat-cons-fin.fact-qnty           = d-slt-vat-cons-fin.fact-qnty           + tt-allsum.fact-qnty                            d-slt-vat-cons-fin.acc-base            = d-slt-vat-cons-fin.acc-base            + tt-allsum.sum-dsc-base-acc                           d-slt-vat-cons-fin.acc-rubl            = d-slt-vat-cons-fin.acc-rubl            + tt-allsum.sum-dsc-rubl-acc                           d-slt-vat-cons-fin.acc-vat-base        = d-slt-vat-cons-fin.acc-vat-base        + tt-allsum.vat-base-acc                           d-slt-vat-cons-fin.acc-vat-rubl        = d-slt-vat-cons-fin.acc-vat-rubl        + tt-allsum.vat-rubl-acc                           d-slt-vat-cons-fin.acc-slt-base        = d-slt-vat-cons-fin.acc-slt-base        + tt-allsum.slt-base-acc                           d-slt-vat-cons-fin.acc-slt-rubl        = d-slt-vat-cons-fin.acc-slt-rubl        + tt-allsum.slt-rubl-acc                           d-slt-vat-cons-fin.acc-road-tax-base   = d-slt-vat-cons-fin.acc-road-tax-base   + tt-allsum.road-tax-base-acc                           d-slt-vat-cons-fin.acc-road-tax-rubl   = d-slt-vat-cons-fin.acc-road-tax-rubl   + tt-allsum.road-tax-rubl-acc                           d-slt-vat-cons-fin.acc-excise-base     = d-slt-vat-cons-fin.acc-excise-base     + tt-allsum.excise-base-acc                           d-slt-vat-cons-fin.acc-excise-rubl     = d-slt-vat-cons-fin.acc-excise-rubl     + tt-allsum.excise-rubl-acc                           d-slt-vat-cons-fin.acc-transport-base  = d-slt-vat-cons-fin.acc-transport-base  + tt-allsum.transport-base-acc                           d-slt-vat-cons-fin.acc-transport-rubl  = d-slt-vat-cons-fin.acc-transport-rubl  + tt-allsum.transport-rubl-acc                           d-slt-vat-cons-fin.acc-other-base      = d-slt-vat-cons-fin.acc-other-base      + tt-allsum.other-base-acc                           d-slt-vat-cons-fin.acc-other-rubl      = d-slt-vat-cons-fin.acc-other-rubl      + tt-allsum.other-rubl-acc                           d-slt-vat-cons-fin.pay-base            = d-slt-vat-cons-fin.pay-base            + tt-allsum.sum-dsc-base-doc                           d-slt-vat-cons-fin.pay-rubl            = d-slt-vat-cons-fin.pay-rubl            + tt-allsum.sum-dsc-rubl-doc                           d-slt-vat-cons-fin.no-vat-base         = d-slt-vat-cons-fin.no-vat-base         + tt-allsum.sum-dsc-base-doc - tt-allsum.vat-base-doc                           d-slt-vat-cons-fin.no-vat-rubl         = d-slt-vat-cons-fin.no-vat-rubl         + tt-allsum.sum-dsc-rubl-doc - tt-allsum.vat-rubl-doc                           d-slt-vat-cons-fin.vat-base            = d-slt-vat-cons-fin.vat-base            + tt-allsum.vat-base-doc                           d-slt-vat-cons-fin.vat-rubl            = d-slt-vat-cons-fin.vat-rubl            + tt-allsum.vat-rubl-doc                           d-slt-vat-cons-fin.vat-base-buyer      = d-slt-vat-cons-fin.vat-base-buyer      + tt-allsum.vat-base-buyer-doc                           d-slt-vat-cons-fin.vat-rubl-buyer      = d-slt-vat-cons-fin.vat-rubl-buyer      + tt-allsum.vat-rubl-buyer-doc                           d-slt-vat-cons-fin.slt-base            = d-slt-vat-cons-fin.slt-base            + tt-allsum.slt-base-doc                           d-slt-vat-cons-fin.slt-rubl            = d-slt-vat-cons-fin.slt-rubl            + tt-allsum.slt-rubl-doc                           d-slt-vat-cons-fin.road-tax            = d-slt-vat-cons-fin.road-tax            + (if varr-b = "base" then tt-allsum.road-tax-base-doc else tt-allsum.road-tax-rubl-doc)                           d-slt-vat-cons-fin.excise              = d-slt-vat-cons-fin.excise              + (if varr-b = "base" then tt-allsum.excise-base-doc   else tt-allsum.excise-rubl-doc)                             d-slt-vat-cons-fin.sale-base           = d-slt-vat-cons-fin.sale-base           + tt-allsum.sum-dsc-base-cur                           d-slt-vat-cons-fin.sale-rubl           = d-slt-vat-cons-fin.sale-rubl           + tt-allsum.sum-dsc-rubl-cur                           d-slt-vat-cons-fin.sale-vat-base       = d-slt-vat-cons-fin.sale-vat-base       + tt-allsum.vat-base-cur                               d-slt-vat-cons-fin.sale-vat-rubl       = d-slt-vat-cons-fin.sale-vat-rubl       + tt-allsum.vat-rubl-cur                               d-slt-vat-cons-fin.sale-vat-buyer-base = d-slt-vat-cons-fin.sale-vat-buyer-base + tt-allsum.vat-base-buyer-cur                           d-slt-vat-cons-fin.sale-vat-buyer-rubl = d-slt-vat-cons-fin.sale-vat-buyer-rubl + tt-allsum.vat-rubl-buyer-cur                           d-slt-vat-cons-fin.sale-slt-base       = d-slt-vat-cons-fin.sale-slt-base       + tt-allsum.slt-base-cur                                 d-slt-vat-cons-fin.sale-slt-rubl       = d-slt-vat-cons-fin.sale-slt-rubl       + tt-allsum.slt-rubl-cur                                 d-slt-vat-cons-fin.sale-road-tax-base  = d-slt-vat-cons-fin.sale-road-tax-base  + tt-allsum.road-tax-base-cur                            d-slt-vat-cons-fin.sale-road-tax-rubl  = d-slt-vat-cons-fin.sale-road-tax-rubl  + tt-allsum.road-tax-rubl-cur                            d-slt-vat-cons-fin.sale-excise-base    = d-slt-vat-cons-fin.sale-excise-base    + tt-allsum.excise-base-cur                              d-slt-vat-cons-fin.sale-excise-rubl    = d-slt-vat-cons-fin.sale-excise-rubl    + tt-allsum.excise-rubl-cur                              d-slt-vat-cons-fin.ov-base             = d-slt-vat-cons-fin.ov-base             + (if varr-b = "base" then (tt-allsum.sum-dsc-base-cur - tt-allsum.sum-dsc-base-doc) else (tt-allsum.sum-dsc-rubl-cur - tt-allsum.sum-dsc-rubl-doc))                           d-slt-vat-cons-fin.ov-vat              = d-slt-vat-cons-fin.ov-vat              + (if varr-b = "base" then (tt-allsum.sum-dsc-base-cur - tt-allsum.sum-dsc-base-doc) else (tt-allsum.sum-dsc-rubl-cur - tt-allsum.sum-dsc-rubl-doc)) * bf_doc-line.vat-pc / (100 + bf_doc-line.vat-pc).
     end.
          if lookup( "d-slt-vat-cons-grp", use-table ) > 0 then do:
       assign d-slt-vat-cons-grp.fact-qnty           = d-slt-vat-cons-grp.fact-qnty           + tt-allsum.fact-qnty                            d-slt-vat-cons-grp.acc-base            = d-slt-vat-cons-grp.acc-base            + tt-allsum.sum-dsc-base-acc                           d-slt-vat-cons-grp.acc-rubl            = d-slt-vat-cons-grp.acc-rubl            + tt-allsum.sum-dsc-rubl-acc                           d-slt-vat-cons-grp.acc-vat-base        = d-slt-vat-cons-grp.acc-vat-base        + tt-allsum.vat-base-acc                           d-slt-vat-cons-grp.acc-vat-rubl        = d-slt-vat-cons-grp.acc-vat-rubl        + tt-allsum.vat-rubl-acc                           d-slt-vat-cons-grp.acc-slt-base        = d-slt-vat-cons-grp.acc-slt-base        + tt-allsum.slt-base-acc                           d-slt-vat-cons-grp.acc-slt-rubl        = d-slt-vat-cons-grp.acc-slt-rubl        + tt-allsum.slt-rubl-acc                           d-slt-vat-cons-grp.acc-road-tax-base   = d-slt-vat-cons-grp.acc-road-tax-base   + tt-allsum.road-tax-base-acc                           d-slt-vat-cons-grp.acc-road-tax-rubl   = d-slt-vat-cons-grp.acc-road-tax-rubl   + tt-allsum.road-tax-rubl-acc                           d-slt-vat-cons-grp.acc-excise-base     = d-slt-vat-cons-grp.acc-excise-base     + tt-allsum.excise-base-acc                           d-slt-vat-cons-grp.acc-excise-rubl     = d-slt-vat-cons-grp.acc-excise-rubl     + tt-allsum.excise-rubl-acc                           d-slt-vat-cons-grp.acc-transport-base  = d-slt-vat-cons-grp.acc-transport-base  + tt-allsum.transport-base-acc                           d-slt-vat-cons-grp.acc-transport-rubl  = d-slt-vat-cons-grp.acc-transport-rubl  + tt-allsum.transport-rubl-acc                           d-slt-vat-cons-grp.acc-other-base      = d-slt-vat-cons-grp.acc-other-base      + tt-allsum.other-base-acc                           d-slt-vat-cons-grp.acc-other-rubl      = d-slt-vat-cons-grp.acc-other-rubl      + tt-allsum.other-rubl-acc                           d-slt-vat-cons-grp.pay-base            = d-slt-vat-cons-grp.pay-base            + tt-allsum.sum-dsc-base-doc                           d-slt-vat-cons-grp.pay-rubl            = d-slt-vat-cons-grp.pay-rubl            + tt-allsum.sum-dsc-rubl-doc                           d-slt-vat-cons-grp.no-vat-base         = d-slt-vat-cons-grp.no-vat-base         + tt-allsum.sum-dsc-base-doc - tt-allsum.vat-base-doc                           d-slt-vat-cons-grp.no-vat-rubl         = d-slt-vat-cons-grp.no-vat-rubl         + tt-allsum.sum-dsc-rubl-doc - tt-allsum.vat-rubl-doc                           d-slt-vat-cons-grp.vat-base            = d-slt-vat-cons-grp.vat-base            + tt-allsum.vat-base-doc                           d-slt-vat-cons-grp.vat-rubl            = d-slt-vat-cons-grp.vat-rubl            + tt-allsum.vat-rubl-doc                           d-slt-vat-cons-grp.vat-base-buyer      = d-slt-vat-cons-grp.vat-base-buyer      + tt-allsum.vat-base-buyer-doc                           d-slt-vat-cons-grp.vat-rubl-buyer      = d-slt-vat-cons-grp.vat-rubl-buyer      + tt-allsum.vat-rubl-buyer-doc                           d-slt-vat-cons-grp.slt-base            = d-slt-vat-cons-grp.slt-base            + tt-allsum.slt-base-doc                           d-slt-vat-cons-grp.slt-rubl            = d-slt-vat-cons-grp.slt-rubl            + tt-allsum.slt-rubl-doc                           d-slt-vat-cons-grp.road-tax            = d-slt-vat-cons-grp.road-tax            + (if varr-b = "base" then tt-allsum.road-tax-base-doc else tt-allsum.road-tax-rubl-doc)                           d-slt-vat-cons-grp.excise              = d-slt-vat-cons-grp.excise              + (if varr-b = "base" then tt-allsum.excise-base-doc   else tt-allsum.excise-rubl-doc)                             d-slt-vat-cons-grp.sale-base           = d-slt-vat-cons-grp.sale-base           + tt-allsum.sum-dsc-base-cur                           d-slt-vat-cons-grp.sale-rubl           = d-slt-vat-cons-grp.sale-rubl           + tt-allsum.sum-dsc-rubl-cur                           d-slt-vat-cons-grp.sale-vat-base       = d-slt-vat-cons-grp.sale-vat-base       + tt-allsum.vat-base-cur                               d-slt-vat-cons-grp.sale-vat-rubl       = d-slt-vat-cons-grp.sale-vat-rubl       + tt-allsum.vat-rubl-cur                               d-slt-vat-cons-grp.sale-vat-buyer-base = d-slt-vat-cons-grp.sale-vat-buyer-base + tt-allsum.vat-base-buyer-cur                           d-slt-vat-cons-grp.sale-vat-buyer-rubl = d-slt-vat-cons-grp.sale-vat-buyer-rubl + tt-allsum.vat-rubl-buyer-cur                           d-slt-vat-cons-grp.sale-slt-base       = d-slt-vat-cons-grp.sale-slt-base       + tt-allsum.slt-base-cur                                 d-slt-vat-cons-grp.sale-slt-rubl       = d-slt-vat-cons-grp.sale-slt-rubl       + tt-allsum.slt-rubl-cur                                 d-slt-vat-cons-grp.sale-road-tax-base  = d-slt-vat-cons-grp.sale-road-tax-base  + tt-allsum.road-tax-base-cur                            d-slt-vat-cons-grp.sale-road-tax-rubl  = d-slt-vat-cons-grp.sale-road-tax-rubl  + tt-allsum.road-tax-rubl-cur                            d-slt-vat-cons-grp.sale-excise-base    = d-slt-vat-cons-grp.sale-excise-base    + tt-allsum.excise-base-cur                              d-slt-vat-cons-grp.sale-excise-rubl    = d-slt-vat-cons-grp.sale-excise-rubl    + tt-allsum.excise-rubl-cur                              d-slt-vat-cons-grp.ov-base             = d-slt-vat-cons-grp.ov-base             + (if varr-b = "base" then (tt-allsum.sum-dsc-base-cur - tt-allsum.sum-dsc-base-doc) else (tt-allsum.sum-dsc-rubl-cur - tt-allsum.sum-dsc-rubl-doc))                           d-slt-vat-cons-grp.ov-vat              = d-slt-vat-cons-grp.ov-vat              + (if varr-b = "base" then (tt-allsum.sum-dsc-base-cur - tt-allsum.sum-dsc-base-doc) else (tt-allsum.sum-dsc-rubl-cur - tt-allsum.sum-dsc-rubl-doc)) * bf_doc-line.vat-pc / (100 + bf_doc-line.vat-pc).
     end.
          if lookup( "d-slt-vat-cons-grp-fin", use-table ) > 0 then do:
       assign d-slt-vat-cons-grp-fin.fact-qnty           = d-slt-vat-cons-grp-fin.fact-qnty           + tt-allsum.fact-qnty                            d-slt-vat-cons-grp-fin.acc-base            = d-slt-vat-cons-grp-fin.acc-base            + tt-allsum.sum-dsc-base-acc                           d-slt-vat-cons-grp-fin.acc-rubl            = d-slt-vat-cons-grp-fin.acc-rubl            + tt-allsum.sum-dsc-rubl-acc                           d-slt-vat-cons-grp-fin.acc-vat-base        = d-slt-vat-cons-grp-fin.acc-vat-base        + tt-allsum.vat-base-acc                           d-slt-vat-cons-grp-fin.acc-vat-rubl        = d-slt-vat-cons-grp-fin.acc-vat-rubl        + tt-allsum.vat-rubl-acc                           d-slt-vat-cons-grp-fin.acc-slt-base        = d-slt-vat-cons-grp-fin.acc-slt-base        + tt-allsum.slt-base-acc                           d-slt-vat-cons-grp-fin.acc-slt-rubl        = d-slt-vat-cons-grp-fin.acc-slt-rubl        + tt-allsum.slt-rubl-acc                           d-slt-vat-cons-grp-fin.acc-road-tax-base   = d-slt-vat-cons-grp-fin.acc-road-tax-base   + tt-allsum.road-tax-base-acc                           d-slt-vat-cons-grp-fin.acc-road-tax-rubl   = d-slt-vat-cons-grp-fin.acc-road-tax-rubl   + tt-allsum.road-tax-rubl-acc                           d-slt-vat-cons-grp-fin.acc-excise-base     = d-slt-vat-cons-grp-fin.acc-excise-base     + tt-allsum.excise-base-acc                           d-slt-vat-cons-grp-fin.acc-excise-rubl     = d-slt-vat-cons-grp-fin.acc-excise-rubl     + tt-allsum.excise-rubl-acc                           d-slt-vat-cons-grp-fin.acc-transport-base  = d-slt-vat-cons-grp-fin.acc-transport-base  + tt-allsum.transport-base-acc                           d-slt-vat-cons-grp-fin.acc-transport-rubl  = d-slt-vat-cons-grp-fin.acc-transport-rubl  + tt-allsum.transport-rubl-acc                           d-slt-vat-cons-grp-fin.acc-other-base      = d-slt-vat-cons-grp-fin.acc-other-base      + tt-allsum.other-base-acc                           d-slt-vat-cons-grp-fin.acc-other-rubl      = d-slt-vat-cons-grp-fin.acc-other-rubl      + tt-allsum.other-rubl-acc                           d-slt-vat-cons-grp-fin.pay-base            = d-slt-vat-cons-grp-fin.pay-base            + tt-allsum.sum-dsc-base-doc                           d-slt-vat-cons-grp-fin.pay-rubl            = d-slt-vat-cons-grp-fin.pay-rubl            + tt-allsum.sum-dsc-rubl-doc                           d-slt-vat-cons-grp-fin.no-vat-base         = d-slt-vat-cons-grp-fin.no-vat-base         + tt-allsum.sum-dsc-base-doc - tt-allsum.vat-base-doc                           d-slt-vat-cons-grp-fin.no-vat-rubl         = d-slt-vat-cons-grp-fin.no-vat-rubl         + tt-allsum.sum-dsc-rubl-doc - tt-allsum.vat-rubl-doc                           d-slt-vat-cons-grp-fin.vat-base            = d-slt-vat-cons-grp-fin.vat-base            + tt-allsum.vat-base-doc                           d-slt-vat-cons-grp-fin.vat-rubl            = d-slt-vat-cons-grp-fin.vat-rubl            + tt-allsum.vat-rubl-doc                           d-slt-vat-cons-grp-fin.vat-base-buyer      = d-slt-vat-cons-grp-fin.vat-base-buyer      + tt-allsum.vat-base-buyer-doc                           d-slt-vat-cons-grp-fin.vat-rubl-buyer      = d-slt-vat-cons-grp-fin.vat-rubl-buyer      + tt-allsum.vat-rubl-buyer-doc                           d-slt-vat-cons-grp-fin.slt-base            = d-slt-vat-cons-grp-fin.slt-base            + tt-allsum.slt-base-doc                           d-slt-vat-cons-grp-fin.slt-rubl            = d-slt-vat-cons-grp-fin.slt-rubl            + tt-allsum.slt-rubl-doc                           d-slt-vat-cons-grp-fin.road-tax            = d-slt-vat-cons-grp-fin.road-tax            + (if varr-b = "base" then tt-allsum.road-tax-base-doc else tt-allsum.road-tax-rubl-doc)                           d-slt-vat-cons-grp-fin.excise              = d-slt-vat-cons-grp-fin.excise              + (if varr-b = "base" then tt-allsum.excise-base-doc   else tt-allsum.excise-rubl-doc)                             d-slt-vat-cons-grp-fin.sale-base           = d-slt-vat-cons-grp-fin.sale-base           + tt-allsum.sum-dsc-base-cur                           d-slt-vat-cons-grp-fin.sale-rubl           = d-slt-vat-cons-grp-fin.sale-rubl           + tt-allsum.sum-dsc-rubl-cur                           d-slt-vat-cons-grp-fin.sale-vat-base       = d-slt-vat-cons-grp-fin.sale-vat-base       + tt-allsum.vat-base-cur                               d-slt-vat-cons-grp-fin.sale-vat-rubl       = d-slt-vat-cons-grp-fin.sale-vat-rubl       + tt-allsum.vat-rubl-cur                               d-slt-vat-cons-grp-fin.sale-vat-buyer-base = d-slt-vat-cons-grp-fin.sale-vat-buyer-base + tt-allsum.vat-base-buyer-cur                           d-slt-vat-cons-grp-fin.sale-vat-buyer-rubl = d-slt-vat-cons-grp-fin.sale-vat-buyer-rubl + tt-allsum.vat-rubl-buyer-cur                           d-slt-vat-cons-grp-fin.sale-slt-base       = d-slt-vat-cons-grp-fin.sale-slt-base       + tt-allsum.slt-base-cur                                 d-slt-vat-cons-grp-fin.sale-slt-rubl       = d-slt-vat-cons-grp-fin.sale-slt-rubl       + tt-allsum.slt-rubl-cur                                 d-slt-vat-cons-grp-fin.sale-road-tax-base  = d-slt-vat-cons-grp-fin.sale-road-tax-base  + tt-allsum.road-tax-base-cur                            d-slt-vat-cons-grp-fin.sale-road-tax-rubl  = d-slt-vat-cons-grp-fin.sale-road-tax-rubl  + tt-allsum.road-tax-rubl-cur                            d-slt-vat-cons-grp-fin.sale-excise-base    = d-slt-vat-cons-grp-fin.sale-excise-base    + tt-allsum.excise-base-cur                              d-slt-vat-cons-grp-fin.sale-excise-rubl    = d-slt-vat-cons-grp-fin.sale-excise-rubl    + tt-allsum.excise-rubl-cur                              d-slt-vat-cons-grp-fin.ov-base             = d-slt-vat-cons-grp-fin.ov-base             + (if varr-b = "base" then (tt-allsum.sum-dsc-base-cur - tt-allsum.sum-dsc-base-doc) else (tt-allsum.sum-dsc-rubl-cur - tt-allsum.sum-dsc-rubl-doc))                           d-slt-vat-cons-grp-fin.ov-vat              = d-slt-vat-cons-grp-fin.ov-vat              + (if varr-b = "base" then (tt-allsum.sum-dsc-base-cur - tt-allsum.sum-dsc-base-doc) else (tt-allsum.sum-dsc-rubl-cur - tt-allsum.sum-dsc-rubl-doc)) * bf_doc-line.vat-pc / (100 + bf_doc-line.vat-pc).
     end.
          if lookup( "d-slts-vats", use-table ) > 0 then do:
       assign d-slts-vats.fact-qnty           = d-slts-vats.fact-qnty           + tt-allsum.fact-qnty                            d-slts-vats.acc-base            = d-slts-vats.acc-base            + tt-allsum.sum-dsc-base-acc                           d-slts-vats.acc-rubl            = d-slts-vats.acc-rubl            + tt-allsum.sum-dsc-rubl-acc                           d-slts-vats.acc-vat-base        = d-slts-vats.acc-vat-base        + tt-allsum.vat-base-acc                           d-slts-vats.acc-vat-rubl        = d-slts-vats.acc-vat-rubl        + tt-allsum.vat-rubl-acc                           d-slts-vats.acc-slt-base        = d-slts-vats.acc-slt-base        + tt-allsum.slt-base-acc                           d-slts-vats.acc-slt-rubl        = d-slts-vats.acc-slt-rubl        + tt-allsum.slt-rubl-acc                           d-slts-vats.acc-road-tax-base   = d-slts-vats.acc-road-tax-base   + tt-allsum.road-tax-base-acc                           d-slts-vats.acc-road-tax-rubl   = d-slts-vats.acc-road-tax-rubl   + tt-allsum.road-tax-rubl-acc                           d-slts-vats.acc-excise-base     = d-slts-vats.acc-excise-base     + tt-allsum.excise-base-acc                           d-slts-vats.acc-excise-rubl     = d-slts-vats.acc-excise-rubl     + tt-allsum.excise-rubl-acc                           d-slts-vats.acc-transport-base  = d-slts-vats.acc-transport-base  + tt-allsum.transport-base-acc                           d-slts-vats.acc-transport-rubl  = d-slts-vats.acc-transport-rubl  + tt-allsum.transport-rubl-acc                           d-slts-vats.acc-other-base      = d-slts-vats.acc-other-base      + tt-allsum.other-base-acc                           d-slts-vats.acc-other-rubl      = d-slts-vats.acc-other-rubl      + tt-allsum.other-rubl-acc                           d-slts-vats.pay-base            = d-slts-vats.pay-base            + tt-allsum.sum-dsc-base-doc                           d-slts-vats.pay-rubl            = d-slts-vats.pay-rubl            + tt-allsum.sum-dsc-rubl-doc                           d-slts-vats.no-vat-base         = d-slts-vats.no-vat-base         + tt-allsum.sum-dsc-base-doc - tt-allsum.vat-base-doc                           d-slts-vats.no-vat-rubl         = d-slts-vats.no-vat-rubl         + tt-allsum.sum-dsc-rubl-doc - tt-allsum.vat-rubl-doc                           d-slts-vats.vat-base            = d-slts-vats.vat-base            + tt-allsum.vat-base-doc                           d-slts-vats.vat-rubl            = d-slts-vats.vat-rubl            + tt-allsum.vat-rubl-doc                           d-slts-vats.vat-base-buyer      = d-slts-vats.vat-base-buyer      + tt-allsum.vat-base-buyer-doc                           d-slts-vats.vat-rubl-buyer      = d-slts-vats.vat-rubl-buyer      + tt-allsum.vat-rubl-buyer-doc                           d-slts-vats.slt-base            = d-slts-vats.slt-base            + tt-allsum.slt-base-doc                           d-slts-vats.slt-rubl            = d-slts-vats.slt-rubl            + tt-allsum.slt-rubl-doc                           d-slts-vats.road-tax            = d-slts-vats.road-tax            + (if varr-b = "base" then tt-allsum.road-tax-base-doc else tt-allsum.road-tax-rubl-doc)                           d-slts-vats.excise              = d-slts-vats.excise              + (if varr-b = "base" then tt-allsum.excise-base-doc   else tt-allsum.excise-rubl-doc)                             d-slts-vats.sale-base           = d-slts-vats.sale-base           + tt-allsum.sum-dsc-base-cur                           d-slts-vats.sale-rubl           = d-slts-vats.sale-rubl           + tt-allsum.sum-dsc-rubl-cur                           d-slts-vats.sale-vat-base       = d-slts-vats.sale-vat-base       + tt-allsum.vat-base-cur                               d-slts-vats.sale-vat-rubl       = d-slts-vats.sale-vat-rubl       + tt-allsum.vat-rubl-cur                               d-slts-vats.sale-vat-buyer-base = d-slts-vats.sale-vat-buyer-base + tt-allsum.vat-base-buyer-cur                           d-slts-vats.sale-vat-buyer-rubl = d-slts-vats.sale-vat-buyer-rubl + tt-allsum.vat-rubl-buyer-cur                           d-slts-vats.sale-slt-base       = d-slts-vats.sale-slt-base       + tt-allsum.slt-base-cur                                 d-slts-vats.sale-slt-rubl       = d-slts-vats.sale-slt-rubl       + tt-allsum.slt-rubl-cur                                 d-slts-vats.sale-road-tax-base  = d-slts-vats.sale-road-tax-base  + tt-allsum.road-tax-base-cur                            d-slts-vats.sale-road-tax-rubl  = d-slts-vats.sale-road-tax-rubl  + tt-allsum.road-tax-rubl-cur                            d-slts-vats.sale-excise-base    = d-slts-vats.sale-excise-base    + tt-allsum.excise-base-cur                              d-slts-vats.sale-excise-rubl    = d-slts-vats.sale-excise-rubl    + tt-allsum.excise-rubl-cur                              d-slts-vats.ov-base             = d-slts-vats.ov-base             + (if varr-b = "base" then (tt-allsum.sum-dsc-base-cur - tt-allsum.sum-dsc-base-doc) else (tt-allsum.sum-dsc-rubl-cur - tt-allsum.sum-dsc-rubl-doc))                           d-slts-vats.ov-vat              = d-slts-vats.ov-vat              + (if varr-b = "base" then (tt-allsum.sum-dsc-base-cur - tt-allsum.sum-dsc-base-doc) else (tt-allsum.sum-dsc-rubl-cur - tt-allsum.sum-dsc-rubl-doc)) * bf_doc-line.vat-pc / (100 + bf_doc-line.vat-pc).
     end.
          if lookup( "d-supp-slts-vats-cons", use-table ) > 0 then do:
       assign d-supp-slts-vats-cons.fact-qnty           = d-supp-slts-vats-cons.fact-qnty           + tt-allsum.fact-qnty                            d-supp-slts-vats-cons.acc-base            = d-supp-slts-vats-cons.acc-base            + tt-allsum.sum-dsc-base-acc                           d-supp-slts-vats-cons.acc-rubl            = d-supp-slts-vats-cons.acc-rubl            + tt-allsum.sum-dsc-rubl-acc                           d-supp-slts-vats-cons.acc-vat-base        = d-supp-slts-vats-cons.acc-vat-base        + tt-allsum.vat-base-acc                           d-supp-slts-vats-cons.acc-vat-rubl        = d-supp-slts-vats-cons.acc-vat-rubl        + tt-allsum.vat-rubl-acc                           d-supp-slts-vats-cons.acc-slt-base        = d-supp-slts-vats-cons.acc-slt-base        + tt-allsum.slt-base-acc                           d-supp-slts-vats-cons.acc-slt-rubl        = d-supp-slts-vats-cons.acc-slt-rubl        + tt-allsum.slt-rubl-acc                           d-supp-slts-vats-cons.acc-road-tax-base   = d-supp-slts-vats-cons.acc-road-tax-base   + tt-allsum.road-tax-base-acc                           d-supp-slts-vats-cons.acc-road-tax-rubl   = d-supp-slts-vats-cons.acc-road-tax-rubl   + tt-allsum.road-tax-rubl-acc                           d-supp-slts-vats-cons.acc-excise-base     = d-supp-slts-vats-cons.acc-excise-base     + tt-allsum.excise-base-acc                           d-supp-slts-vats-cons.acc-excise-rubl     = d-supp-slts-vats-cons.acc-excise-rubl     + tt-allsum.excise-rubl-acc                           d-supp-slts-vats-cons.acc-transport-base  = d-supp-slts-vats-cons.acc-transport-base  + tt-allsum.transport-base-acc                           d-supp-slts-vats-cons.acc-transport-rubl  = d-supp-slts-vats-cons.acc-transport-rubl  + tt-allsum.transport-rubl-acc                           d-supp-slts-vats-cons.acc-other-base      = d-supp-slts-vats-cons.acc-other-base      + tt-allsum.other-base-acc                           d-supp-slts-vats-cons.acc-other-rubl      = d-supp-slts-vats-cons.acc-other-rubl      + tt-allsum.other-rubl-acc                           d-supp-slts-vats-cons.pay-base            = d-supp-slts-vats-cons.pay-base            + tt-allsum.sum-dsc-base-doc                           d-supp-slts-vats-cons.pay-rubl            = d-supp-slts-vats-cons.pay-rubl            + tt-allsum.sum-dsc-rubl-doc                           d-supp-slts-vats-cons.no-vat-base         = d-supp-slts-vats-cons.no-vat-base         + tt-allsum.sum-dsc-base-doc - tt-allsum.vat-base-doc                           d-supp-slts-vats-cons.no-vat-rubl         = d-supp-slts-vats-cons.no-vat-rubl         + tt-allsum.sum-dsc-rubl-doc - tt-allsum.vat-rubl-doc                           d-supp-slts-vats-cons.vat-base            = d-supp-slts-vats-cons.vat-base            + tt-allsum.vat-base-doc                           d-supp-slts-vats-cons.vat-rubl            = d-supp-slts-vats-cons.vat-rubl            + tt-allsum.vat-rubl-doc                           d-supp-slts-vats-cons.vat-base-buyer      = d-supp-slts-vats-cons.vat-base-buyer      + tt-allsum.vat-base-buyer-doc                           d-supp-slts-vats-cons.vat-rubl-buyer      = d-supp-slts-vats-cons.vat-rubl-buyer      + tt-allsum.vat-rubl-buyer-doc                           d-supp-slts-vats-cons.slt-base            = d-supp-slts-vats-cons.slt-base            + tt-allsum.slt-base-doc                           d-supp-slts-vats-cons.slt-rubl            = d-supp-slts-vats-cons.slt-rubl            + tt-allsum.slt-rubl-doc                           d-supp-slts-vats-cons.road-tax            = d-supp-slts-vats-cons.road-tax            + (if varr-b = "base" then tt-allsum.road-tax-base-doc else tt-allsum.road-tax-rubl-doc)                           d-supp-slts-vats-cons.excise              = d-supp-slts-vats-cons.excise              + (if varr-b = "base" then tt-allsum.excise-base-doc   else tt-allsum.excise-rubl-doc)                             d-supp-slts-vats-cons.sale-base           = d-supp-slts-vats-cons.sale-base           + tt-allsum.sum-dsc-base-cur                           d-supp-slts-vats-cons.sale-rubl           = d-supp-slts-vats-cons.sale-rubl           + tt-allsum.sum-dsc-rubl-cur                           d-supp-slts-vats-cons.sale-vat-base       = d-supp-slts-vats-cons.sale-vat-base       + tt-allsum.vat-base-cur                               d-supp-slts-vats-cons.sale-vat-rubl       = d-supp-slts-vats-cons.sale-vat-rubl       + tt-allsum.vat-rubl-cur                               d-supp-slts-vats-cons.sale-vat-buyer-base = d-supp-slts-vats-cons.sale-vat-buyer-base + tt-allsum.vat-base-buyer-cur                           d-supp-slts-vats-cons.sale-vat-buyer-rubl = d-supp-slts-vats-cons.sale-vat-buyer-rubl + tt-allsum.vat-rubl-buyer-cur                           d-supp-slts-vats-cons.sale-slt-base       = d-supp-slts-vats-cons.sale-slt-base       + tt-allsum.slt-base-cur                                 d-supp-slts-vats-cons.sale-slt-rubl       = d-supp-slts-vats-cons.sale-slt-rubl       + tt-allsum.slt-rubl-cur                                 d-supp-slts-vats-cons.sale-road-tax-base  = d-supp-slts-vats-cons.sale-road-tax-base  + tt-allsum.road-tax-base-cur                            d-supp-slts-vats-cons.sale-road-tax-rubl  = d-supp-slts-vats-cons.sale-road-tax-rubl  + tt-allsum.road-tax-rubl-cur                            d-supp-slts-vats-cons.sale-excise-base    = d-supp-slts-vats-cons.sale-excise-base    + tt-allsum.excise-base-cur                              d-supp-slts-vats-cons.sale-excise-rubl    = d-supp-slts-vats-cons.sale-excise-rubl    + tt-allsum.excise-rubl-cur                              d-supp-slts-vats-cons.ov-base             = d-supp-slts-vats-cons.ov-base             + (if varr-b = "base" then (tt-allsum.sum-dsc-base-cur - tt-allsum.sum-dsc-base-doc) else (tt-allsum.sum-dsc-rubl-cur - tt-allsum.sum-dsc-rubl-doc))                           d-supp-slts-vats-cons.ov-vat              = d-supp-slts-vats-cons.ov-vat              + (if varr-b = "base" then (tt-allsum.sum-dsc-base-cur - tt-allsum.sum-dsc-base-doc) else (tt-allsum.sum-dsc-rubl-cur - tt-allsum.sum-dsc-rubl-doc)) * bf_doc-line.vat-pc / (100 + bf_doc-line.vat-pc).
     end.
          if lookup( "d-supp-slts-vats-cons-fin", use-table ) > 0 then do:
       assign d-supp-slts-vats-cons-fin.fact-qnty           = d-supp-slts-vats-cons-fin.fact-qnty           + tt-allsum.fact-qnty                            d-supp-slts-vats-cons-fin.acc-base            = d-supp-slts-vats-cons-fin.acc-base            + tt-allsum.sum-dsc-base-acc                           d-supp-slts-vats-cons-fin.acc-rubl            = d-supp-slts-vats-cons-fin.acc-rubl            + tt-allsum.sum-dsc-rubl-acc                           d-supp-slts-vats-cons-fin.acc-vat-base        = d-supp-slts-vats-cons-fin.acc-vat-base        + tt-allsum.vat-base-acc                           d-supp-slts-vats-cons-fin.acc-vat-rubl        = d-supp-slts-vats-cons-fin.acc-vat-rubl        + tt-allsum.vat-rubl-acc                           d-supp-slts-vats-cons-fin.acc-slt-base        = d-supp-slts-vats-cons-fin.acc-slt-base        + tt-allsum.slt-base-acc                           d-supp-slts-vats-cons-fin.acc-slt-rubl        = d-supp-slts-vats-cons-fin.acc-slt-rubl        + tt-allsum.slt-rubl-acc                           d-supp-slts-vats-cons-fin.acc-road-tax-base   = d-supp-slts-vats-cons-fin.acc-road-tax-base   + tt-allsum.road-tax-base-acc                           d-supp-slts-vats-cons-fin.acc-road-tax-rubl   = d-supp-slts-vats-cons-fin.acc-road-tax-rubl   + tt-allsum.road-tax-rubl-acc                           d-supp-slts-vats-cons-fin.acc-excise-base     = d-supp-slts-vats-cons-fin.acc-excise-base     + tt-allsum.excise-base-acc                           d-supp-slts-vats-cons-fin.acc-excise-rubl     = d-supp-slts-vats-cons-fin.acc-excise-rubl     + tt-allsum.excise-rubl-acc                           d-supp-slts-vats-cons-fin.acc-transport-base  = d-supp-slts-vats-cons-fin.acc-transport-base  + tt-allsum.transport-base-acc                           d-supp-slts-vats-cons-fin.acc-transport-rubl  = d-supp-slts-vats-cons-fin.acc-transport-rubl  + tt-allsum.transport-rubl-acc                           d-supp-slts-vats-cons-fin.acc-other-base      = d-supp-slts-vats-cons-fin.acc-other-base      + tt-allsum.other-base-acc                           d-supp-slts-vats-cons-fin.acc-other-rubl      = d-supp-slts-vats-cons-fin.acc-other-rubl      + tt-allsum.other-rubl-acc                           d-supp-slts-vats-cons-fin.pay-base            = d-supp-slts-vats-cons-fin.pay-base            + tt-allsum.sum-dsc-base-doc                           d-supp-slts-vats-cons-fin.pay-rubl            = d-supp-slts-vats-cons-fin.pay-rubl            + tt-allsum.sum-dsc-rubl-doc                           d-supp-slts-vats-cons-fin.no-vat-base         = d-supp-slts-vats-cons-fin.no-vat-base         + tt-allsum.sum-dsc-base-doc - tt-allsum.vat-base-doc                           d-supp-slts-vats-cons-fin.no-vat-rubl         = d-supp-slts-vats-cons-fin.no-vat-rubl         + tt-allsum.sum-dsc-rubl-doc - tt-allsum.vat-rubl-doc                           d-supp-slts-vats-cons-fin.vat-base            = d-supp-slts-vats-cons-fin.vat-base            + tt-allsum.vat-base-doc                           d-supp-slts-vats-cons-fin.vat-rubl            = d-supp-slts-vats-cons-fin.vat-rubl            + tt-allsum.vat-rubl-doc                           d-supp-slts-vats-cons-fin.vat-base-buyer      = d-supp-slts-vats-cons-fin.vat-base-buyer      + tt-allsum.vat-base-buyer-doc                           d-supp-slts-vats-cons-fin.vat-rubl-buyer      = d-supp-slts-vats-cons-fin.vat-rubl-buyer      + tt-allsum.vat-rubl-buyer-doc                           d-supp-slts-vats-cons-fin.slt-base            = d-supp-slts-vats-cons-fin.slt-base            + tt-allsum.slt-base-doc                           d-supp-slts-vats-cons-fin.slt-rubl            = d-supp-slts-vats-cons-fin.slt-rubl            + tt-allsum.slt-rubl-doc                           d-supp-slts-vats-cons-fin.road-tax            = d-supp-slts-vats-cons-fin.road-tax            + (if varr-b = "base" then tt-allsum.road-tax-base-doc else tt-allsum.road-tax-rubl-doc)                           d-supp-slts-vats-cons-fin.excise              = d-supp-slts-vats-cons-fin.excise              + (if varr-b = "base" then tt-allsum.excise-base-doc   else tt-allsum.excise-rubl-doc)                             d-supp-slts-vats-cons-fin.sale-base           = d-supp-slts-vats-cons-fin.sale-base           + tt-allsum.sum-dsc-base-cur                           d-supp-slts-vats-cons-fin.sale-rubl           = d-supp-slts-vats-cons-fin.sale-rubl           + tt-allsum.sum-dsc-rubl-cur                           d-supp-slts-vats-cons-fin.sale-vat-base       = d-supp-slts-vats-cons-fin.sale-vat-base       + tt-allsum.vat-base-cur                               d-supp-slts-vats-cons-fin.sale-vat-rubl       = d-supp-slts-vats-cons-fin.sale-vat-rubl       + tt-allsum.vat-rubl-cur                               d-supp-slts-vats-cons-fin.sale-vat-buyer-base = d-supp-slts-vats-cons-fin.sale-vat-buyer-base + tt-allsum.vat-base-buyer-cur                           d-supp-slts-vats-cons-fin.sale-vat-buyer-rubl = d-supp-slts-vats-cons-fin.sale-vat-buyer-rubl + tt-allsum.vat-rubl-buyer-cur                           d-supp-slts-vats-cons-fin.sale-slt-base       = d-supp-slts-vats-cons-fin.sale-slt-base       + tt-allsum.slt-base-cur                                 d-supp-slts-vats-cons-fin.sale-slt-rubl       = d-supp-slts-vats-cons-fin.sale-slt-rubl       + tt-allsum.slt-rubl-cur                                 d-supp-slts-vats-cons-fin.sale-road-tax-base  = d-supp-slts-vats-cons-fin.sale-road-tax-base  + tt-allsum.road-tax-base-cur                            d-supp-slts-vats-cons-fin.sale-road-tax-rubl  = d-supp-slts-vats-cons-fin.sale-road-tax-rubl  + tt-allsum.road-tax-rubl-cur                            d-supp-slts-vats-cons-fin.sale-excise-base    = d-supp-slts-vats-cons-fin.sale-excise-base    + tt-allsum.excise-base-cur                              d-supp-slts-vats-cons-fin.sale-excise-rubl    = d-supp-slts-vats-cons-fin.sale-excise-rubl    + tt-allsum.excise-rubl-cur                              d-supp-slts-vats-cons-fin.ov-base             = d-supp-slts-vats-cons-fin.ov-base             + (if varr-b = "base" then (tt-allsum.sum-dsc-base-cur - tt-allsum.sum-dsc-base-doc) else (tt-allsum.sum-dsc-rubl-cur - tt-allsum.sum-dsc-rubl-doc))                           d-supp-slts-vats-cons-fin.ov-vat              = d-supp-slts-vats-cons-fin.ov-vat              + (if varr-b = "base" then (tt-allsum.sum-dsc-base-cur - tt-allsum.sum-dsc-base-doc) else (tt-allsum.sum-dsc-rubl-cur - tt-allsum.sum-dsc-rubl-doc)) * bf_doc-line.vat-pc / (100 + bf_doc-line.vat-pc).
     end.
          if lookup( "d-slts-vats-cons", use-table ) > 0 then do:
       assign d-slts-vats-cons.fact-qnty           = d-slts-vats-cons.fact-qnty           + tt-allsum.fact-qnty                            d-slts-vats-cons.acc-base            = d-slts-vats-cons.acc-base            + tt-allsum.sum-dsc-base-acc                           d-slts-vats-cons.acc-rubl            = d-slts-vats-cons.acc-rubl            + tt-allsum.sum-dsc-rubl-acc                           d-slts-vats-cons.acc-vat-base        = d-slts-vats-cons.acc-vat-base        + tt-allsum.vat-base-acc                           d-slts-vats-cons.acc-vat-rubl        = d-slts-vats-cons.acc-vat-rubl        + tt-allsum.vat-rubl-acc                           d-slts-vats-cons.acc-slt-base        = d-slts-vats-cons.acc-slt-base        + tt-allsum.slt-base-acc                           d-slts-vats-cons.acc-slt-rubl        = d-slts-vats-cons.acc-slt-rubl        + tt-allsum.slt-rubl-acc                           d-slts-vats-cons.acc-road-tax-base   = d-slts-vats-cons.acc-road-tax-base   + tt-allsum.road-tax-base-acc                           d-slts-vats-cons.acc-road-tax-rubl   = d-slts-vats-cons.acc-road-tax-rubl   + tt-allsum.road-tax-rubl-acc                           d-slts-vats-cons.acc-excise-base     = d-slts-vats-cons.acc-excise-base     + tt-allsum.excise-base-acc                           d-slts-vats-cons.acc-excise-rubl     = d-slts-vats-cons.acc-excise-rubl     + tt-allsum.excise-rubl-acc                           d-slts-vats-cons.acc-transport-base  = d-slts-vats-cons.acc-transport-base  + tt-allsum.transport-base-acc                           d-slts-vats-cons.acc-transport-rubl  = d-slts-vats-cons.acc-transport-rubl  + tt-allsum.transport-rubl-acc                           d-slts-vats-cons.acc-other-base      = d-slts-vats-cons.acc-other-base      + tt-allsum.other-base-acc                           d-slts-vats-cons.acc-other-rubl      = d-slts-vats-cons.acc-other-rubl      + tt-allsum.other-rubl-acc                           d-slts-vats-cons.pay-base            = d-slts-vats-cons.pay-base            + tt-allsum.sum-dsc-base-doc                           d-slts-vats-cons.pay-rubl            = d-slts-vats-cons.pay-rubl            + tt-allsum.sum-dsc-rubl-doc                           d-slts-vats-cons.no-vat-base         = d-slts-vats-cons.no-vat-base         + tt-allsum.sum-dsc-base-doc - tt-allsum.vat-base-doc                           d-slts-vats-cons.no-vat-rubl         = d-slts-vats-cons.no-vat-rubl         + tt-allsum.sum-dsc-rubl-doc - tt-allsum.vat-rubl-doc                           d-slts-vats-cons.vat-base            = d-slts-vats-cons.vat-base            + tt-allsum.vat-base-doc                           d-slts-vats-cons.vat-rubl            = d-slts-vats-cons.vat-rubl            + tt-allsum.vat-rubl-doc                           d-slts-vats-cons.vat-base-buyer      = d-slts-vats-cons.vat-base-buyer      + tt-allsum.vat-base-buyer-doc                           d-slts-vats-cons.vat-rubl-buyer      = d-slts-vats-cons.vat-rubl-buyer      + tt-allsum.vat-rubl-buyer-doc                           d-slts-vats-cons.slt-base            = d-slts-vats-cons.slt-base            + tt-allsum.slt-base-doc                           d-slts-vats-cons.slt-rubl            = d-slts-vats-cons.slt-rubl            + tt-allsum.slt-rubl-doc                           d-slts-vats-cons.road-tax            = d-slts-vats-cons.road-tax            + (if varr-b = "base" then tt-allsum.road-tax-base-doc else tt-allsum.road-tax-rubl-doc)                           d-slts-vats-cons.excise              = d-slts-vats-cons.excise              + (if varr-b = "base" then tt-allsum.excise-base-doc   else tt-allsum.excise-rubl-doc)                             d-slts-vats-cons.sale-base           = d-slts-vats-cons.sale-base           + tt-allsum.sum-dsc-base-cur                           d-slts-vats-cons.sale-rubl           = d-slts-vats-cons.sale-rubl           + tt-allsum.sum-dsc-rubl-cur                           d-slts-vats-cons.sale-vat-base       = d-slts-vats-cons.sale-vat-base       + tt-allsum.vat-base-cur                               d-slts-vats-cons.sale-vat-rubl       = d-slts-vats-cons.sale-vat-rubl       + tt-allsum.vat-rubl-cur                               d-slts-vats-cons.sale-vat-buyer-base = d-slts-vats-cons.sale-vat-buyer-base + tt-allsum.vat-base-buyer-cur                           d-slts-vats-cons.sale-vat-buyer-rubl = d-slts-vats-cons.sale-vat-buyer-rubl + tt-allsum.vat-rubl-buyer-cur                           d-slts-vats-cons.sale-slt-base       = d-slts-vats-cons.sale-slt-base       + tt-allsum.slt-base-cur                                 d-slts-vats-cons.sale-slt-rubl       = d-slts-vats-cons.sale-slt-rubl       + tt-allsum.slt-rubl-cur                                 d-slts-vats-cons.sale-road-tax-base  = d-slts-vats-cons.sale-road-tax-base  + tt-allsum.road-tax-base-cur                            d-slts-vats-cons.sale-road-tax-rubl  = d-slts-vats-cons.sale-road-tax-rubl  + tt-allsum.road-tax-rubl-cur                            d-slts-vats-cons.sale-excise-base    = d-slts-vats-cons.sale-excise-base    + tt-allsum.excise-base-cur                              d-slts-vats-cons.sale-excise-rubl    = d-slts-vats-cons.sale-excise-rubl    + tt-allsum.excise-rubl-cur                              d-slts-vats-cons.ov-base             = d-slts-vats-cons.ov-base             + (if varr-b = "base" then (tt-allsum.sum-dsc-base-cur - tt-allsum.sum-dsc-base-doc) else (tt-allsum.sum-dsc-rubl-cur - tt-allsum.sum-dsc-rubl-doc))                           d-slts-vats-cons.ov-vat              = d-slts-vats-cons.ov-vat              + (if varr-b = "base" then (tt-allsum.sum-dsc-base-cur - tt-allsum.sum-dsc-base-doc) else (tt-allsum.sum-dsc-rubl-cur - tt-allsum.sum-dsc-rubl-doc)) * bf_doc-line.vat-pc / (100 + bf_doc-line.vat-pc).
     end.
          if lookup( "d-slts-vats-cons-fin", use-table ) > 0 then do:
       assign d-slts-vats-cons-fin.fact-qnty           = d-slts-vats-cons-fin.fact-qnty           + tt-allsum.fact-qnty                            d-slts-vats-cons-fin.acc-base            = d-slts-vats-cons-fin.acc-base            + tt-allsum.sum-dsc-base-acc                           d-slts-vats-cons-fin.acc-rubl            = d-slts-vats-cons-fin.acc-rubl            + tt-allsum.sum-dsc-rubl-acc                           d-slts-vats-cons-fin.acc-vat-base        = d-slts-vats-cons-fin.acc-vat-base        + tt-allsum.vat-base-acc                           d-slts-vats-cons-fin.acc-vat-rubl        = d-slts-vats-cons-fin.acc-vat-rubl        + tt-allsum.vat-rubl-acc                           d-slts-vats-cons-fin.acc-slt-base        = d-slts-vats-cons-fin.acc-slt-base        + tt-allsum.slt-base-acc                           d-slts-vats-cons-fin.acc-slt-rubl        = d-slts-vats-cons-fin.acc-slt-rubl        + tt-allsum.slt-rubl-acc                           d-slts-vats-cons-fin.acc-road-tax-base   = d-slts-vats-cons-fin.acc-road-tax-base   + tt-allsum.road-tax-base-acc                           d-slts-vats-cons-fin.acc-road-tax-rubl   = d-slts-vats-cons-fin.acc-road-tax-rubl   + tt-allsum.road-tax-rubl-acc                           d-slts-vats-cons-fin.acc-excise-base     = d-slts-vats-cons-fin.acc-excise-base     + tt-allsum.excise-base-acc                           d-slts-vats-cons-fin.acc-excise-rubl     = d-slts-vats-cons-fin.acc-excise-rubl     + tt-allsum.excise-rubl-acc                           d-slts-vats-cons-fin.acc-transport-base  = d-slts-vats-cons-fin.acc-transport-base  + tt-allsum.transport-base-acc                           d-slts-vats-cons-fin.acc-transport-rubl  = d-slts-vats-cons-fin.acc-transport-rubl  + tt-allsum.transport-rubl-acc                           d-slts-vats-cons-fin.acc-other-base      = d-slts-vats-cons-fin.acc-other-base      + tt-allsum.other-base-acc                           d-slts-vats-cons-fin.acc-other-rubl      = d-slts-vats-cons-fin.acc-other-rubl      + tt-allsum.other-rubl-acc                           d-slts-vats-cons-fin.pay-base            = d-slts-vats-cons-fin.pay-base            + tt-allsum.sum-dsc-base-doc                           d-slts-vats-cons-fin.pay-rubl            = d-slts-vats-cons-fin.pay-rubl            + tt-allsum.sum-dsc-rubl-doc                           d-slts-vats-cons-fin.no-vat-base         = d-slts-vats-cons-fin.no-vat-base         + tt-allsum.sum-dsc-base-doc - tt-allsum.vat-base-doc                           d-slts-vats-cons-fin.no-vat-rubl         = d-slts-vats-cons-fin.no-vat-rubl         + tt-allsum.sum-dsc-rubl-doc - tt-allsum.vat-rubl-doc                           d-slts-vats-cons-fin.vat-base            = d-slts-vats-cons-fin.vat-base            + tt-allsum.vat-base-doc                           d-slts-vats-cons-fin.vat-rubl            = d-slts-vats-cons-fin.vat-rubl            + tt-allsum.vat-rubl-doc                           d-slts-vats-cons-fin.vat-base-buyer      = d-slts-vats-cons-fin.vat-base-buyer      + tt-allsum.vat-base-buyer-doc                           d-slts-vats-cons-fin.vat-rubl-buyer      = d-slts-vats-cons-fin.vat-rubl-buyer      + tt-allsum.vat-rubl-buyer-doc                           d-slts-vats-cons-fin.slt-base            = d-slts-vats-cons-fin.slt-base            + tt-allsum.slt-base-doc                           d-slts-vats-cons-fin.slt-rubl            = d-slts-vats-cons-fin.slt-rubl            + tt-allsum.slt-rubl-doc                           d-slts-vats-cons-fin.road-tax            = d-slts-vats-cons-fin.road-tax            + (if varr-b = "base" then tt-allsum.road-tax-base-doc else tt-allsum.road-tax-rubl-doc)                           d-slts-vats-cons-fin.excise              = d-slts-vats-cons-fin.excise              + (if varr-b = "base" then tt-allsum.excise-base-doc   else tt-allsum.excise-rubl-doc)                             d-slts-vats-cons-fin.sale-base           = d-slts-vats-cons-fin.sale-base           + tt-allsum.sum-dsc-base-cur                           d-slts-vats-cons-fin.sale-rubl           = d-slts-vats-cons-fin.sale-rubl           + tt-allsum.sum-dsc-rubl-cur                           d-slts-vats-cons-fin.sale-vat-base       = d-slts-vats-cons-fin.sale-vat-base       + tt-allsum.vat-base-cur                               d-slts-vats-cons-fin.sale-vat-rubl       = d-slts-vats-cons-fin.sale-vat-rubl       + tt-allsum.vat-rubl-cur                               d-slts-vats-cons-fin.sale-vat-buyer-base = d-slts-vats-cons-fin.sale-vat-buyer-base + tt-allsum.vat-base-buyer-cur                           d-slts-vats-cons-fin.sale-vat-buyer-rubl = d-slts-vats-cons-fin.sale-vat-buyer-rubl + tt-allsum.vat-rubl-buyer-cur                           d-slts-vats-cons-fin.sale-slt-base       = d-slts-vats-cons-fin.sale-slt-base       + tt-allsum.slt-base-cur                                 d-slts-vats-cons-fin.sale-slt-rubl       = d-slts-vats-cons-fin.sale-slt-rubl       + tt-allsum.slt-rubl-cur                                 d-slts-vats-cons-fin.sale-road-tax-base  = d-slts-vats-cons-fin.sale-road-tax-base  + tt-allsum.road-tax-base-cur                            d-slts-vats-cons-fin.sale-road-tax-rubl  = d-slts-vats-cons-fin.sale-road-tax-rubl  + tt-allsum.road-tax-rubl-cur                            d-slts-vats-cons-fin.sale-excise-base    = d-slts-vats-cons-fin.sale-excise-base    + tt-allsum.excise-base-cur                              d-slts-vats-cons-fin.sale-excise-rubl    = d-slts-vats-cons-fin.sale-excise-rubl    + tt-allsum.excise-rubl-cur                              d-slts-vats-cons-fin.ov-base             = d-slts-vats-cons-fin.ov-base             + (if varr-b = "base" then (tt-allsum.sum-dsc-base-cur - tt-allsum.sum-dsc-base-doc) else (tt-allsum.sum-dsc-rubl-cur - tt-allsum.sum-dsc-rubl-doc))                           d-slts-vats-cons-fin.ov-vat              = d-slts-vats-cons-fin.ov-vat              + (if varr-b = "base" then (tt-allsum.sum-dsc-base-cur - tt-allsum.sum-dsc-base-doc) else (tt-allsum.sum-dsc-rubl-cur - tt-allsum.sum-dsc-rubl-doc)) * bf_doc-line.vat-pc / (100 + bf_doc-line.vat-pc).
     end.
          if lookup( "d-slts-vats-cons-grp", use-table ) > 0 then do:
       assign d-slts-vats-cons-grp.fact-qnty           = d-slts-vats-cons-grp.fact-qnty           + tt-allsum.fact-qnty                            d-slts-vats-cons-grp.acc-base            = d-slts-vats-cons-grp.acc-base            + tt-allsum.sum-dsc-base-acc                           d-slts-vats-cons-grp.acc-rubl            = d-slts-vats-cons-grp.acc-rubl            + tt-allsum.sum-dsc-rubl-acc                           d-slts-vats-cons-grp.acc-vat-base        = d-slts-vats-cons-grp.acc-vat-base        + tt-allsum.vat-base-acc                           d-slts-vats-cons-grp.acc-vat-rubl        = d-slts-vats-cons-grp.acc-vat-rubl        + tt-allsum.vat-rubl-acc                           d-slts-vats-cons-grp.acc-slt-base        = d-slts-vats-cons-grp.acc-slt-base        + tt-allsum.slt-base-acc                           d-slts-vats-cons-grp.acc-slt-rubl        = d-slts-vats-cons-grp.acc-slt-rubl        + tt-allsum.slt-rubl-acc                           d-slts-vats-cons-grp.acc-road-tax-base   = d-slts-vats-cons-grp.acc-road-tax-base   + tt-allsum.road-tax-base-acc                           d-slts-vats-cons-grp.acc-road-tax-rubl   = d-slts-vats-cons-grp.acc-road-tax-rubl   + tt-allsum.road-tax-rubl-acc                           d-slts-vats-cons-grp.acc-excise-base     = d-slts-vats-cons-grp.acc-excise-base     + tt-allsum.excise-base-acc                           d-slts-vats-cons-grp.acc-excise-rubl     = d-slts-vats-cons-grp.acc-excise-rubl     + tt-allsum.excise-rubl-acc                           d-slts-vats-cons-grp.acc-transport-base  = d-slts-vats-cons-grp.acc-transport-base  + tt-allsum.transport-base-acc                           d-slts-vats-cons-grp.acc-transport-rubl  = d-slts-vats-cons-grp.acc-transport-rubl  + tt-allsum.transport-rubl-acc                           d-slts-vats-cons-grp.acc-other-base      = d-slts-vats-cons-grp.acc-other-base      + tt-allsum.other-base-acc                           d-slts-vats-cons-grp.acc-other-rubl      = d-slts-vats-cons-grp.acc-other-rubl      + tt-allsum.other-rubl-acc                           d-slts-vats-cons-grp.pay-base            = d-slts-vats-cons-grp.pay-base            + tt-allsum.sum-dsc-base-doc                           d-slts-vats-cons-grp.pay-rubl            = d-slts-vats-cons-grp.pay-rubl            + tt-allsum.sum-dsc-rubl-doc                           d-slts-vats-cons-grp.no-vat-base         = d-slts-vats-cons-grp.no-vat-base         + tt-allsum.sum-dsc-base-doc - tt-allsum.vat-base-doc                           d-slts-vats-cons-grp.no-vat-rubl         = d-slts-vats-cons-grp.no-vat-rubl         + tt-allsum.sum-dsc-rubl-doc - tt-allsum.vat-rubl-doc                           d-slts-vats-cons-grp.vat-base            = d-slts-vats-cons-grp.vat-base            + tt-allsum.vat-base-doc                           d-slts-vats-cons-grp.vat-rubl            = d-slts-vats-cons-grp.vat-rubl            + tt-allsum.vat-rubl-doc                           d-slts-vats-cons-grp.vat-base-buyer      = d-slts-vats-cons-grp.vat-base-buyer      + tt-allsum.vat-base-buyer-doc                           d-slts-vats-cons-grp.vat-rubl-buyer      = d-slts-vats-cons-grp.vat-rubl-buyer      + tt-allsum.vat-rubl-buyer-doc                           d-slts-vats-cons-grp.slt-base            = d-slts-vats-cons-grp.slt-base            + tt-allsum.slt-base-doc                           d-slts-vats-cons-grp.slt-rubl            = d-slts-vats-cons-grp.slt-rubl            + tt-allsum.slt-rubl-doc                           d-slts-vats-cons-grp.road-tax            = d-slts-vats-cons-grp.road-tax            + (if varr-b = "base" then tt-allsum.road-tax-base-doc else tt-allsum.road-tax-rubl-doc)                           d-slts-vats-cons-grp.excise              = d-slts-vats-cons-grp.excise              + (if varr-b = "base" then tt-allsum.excise-base-doc   else tt-allsum.excise-rubl-doc)                             d-slts-vats-cons-grp.sale-base           = d-slts-vats-cons-grp.sale-base           + tt-allsum.sum-dsc-base-cur                           d-slts-vats-cons-grp.sale-rubl           = d-slts-vats-cons-grp.sale-rubl           + tt-allsum.sum-dsc-rubl-cur                           d-slts-vats-cons-grp.sale-vat-base       = d-slts-vats-cons-grp.sale-vat-base       + tt-allsum.vat-base-cur                               d-slts-vats-cons-grp.sale-vat-rubl       = d-slts-vats-cons-grp.sale-vat-rubl       + tt-allsum.vat-rubl-cur                               d-slts-vats-cons-grp.sale-vat-buyer-base = d-slts-vats-cons-grp.sale-vat-buyer-base + tt-allsum.vat-base-buyer-cur                           d-slts-vats-cons-grp.sale-vat-buyer-rubl = d-slts-vats-cons-grp.sale-vat-buyer-rubl + tt-allsum.vat-rubl-buyer-cur                           d-slts-vats-cons-grp.sale-slt-base       = d-slts-vats-cons-grp.sale-slt-base       + tt-allsum.slt-base-cur                                 d-slts-vats-cons-grp.sale-slt-rubl       = d-slts-vats-cons-grp.sale-slt-rubl       + tt-allsum.slt-rubl-cur                                 d-slts-vats-cons-grp.sale-road-tax-base  = d-slts-vats-cons-grp.sale-road-tax-base  + tt-allsum.road-tax-base-cur                            d-slts-vats-cons-grp.sale-road-tax-rubl  = d-slts-vats-cons-grp.sale-road-tax-rubl  + tt-allsum.road-tax-rubl-cur                            d-slts-vats-cons-grp.sale-excise-base    = d-slts-vats-cons-grp.sale-excise-base    + tt-allsum.excise-base-cur                              d-slts-vats-cons-grp.sale-excise-rubl    = d-slts-vats-cons-grp.sale-excise-rubl    + tt-allsum.excise-rubl-cur                              d-slts-vats-cons-grp.ov-base             = d-slts-vats-cons-grp.ov-base             + (if varr-b = "base" then (tt-allsum.sum-dsc-base-cur - tt-allsum.sum-dsc-base-doc) else (tt-allsum.sum-dsc-rubl-cur - tt-allsum.sum-dsc-rubl-doc))                           d-slts-vats-cons-grp.ov-vat              = d-slts-vats-cons-grp.ov-vat              + (if varr-b = "base" then (tt-allsum.sum-dsc-base-cur - tt-allsum.sum-dsc-base-doc) else (tt-allsum.sum-dsc-rubl-cur - tt-allsum.sum-dsc-rubl-doc)) * bf_doc-line.vat-pc / (100 + bf_doc-line.vat-pc).
     end.
          if lookup( "d-slts-vats-cons-grp-fin", use-table ) > 0 then do:
       assign d-slts-vats-cons-grp-fin.fact-qnty           = d-slts-vats-cons-grp-fin.fact-qnty           + tt-allsum.fact-qnty                            d-slts-vats-cons-grp-fin.acc-base            = d-slts-vats-cons-grp-fin.acc-base            + tt-allsum.sum-dsc-base-acc                           d-slts-vats-cons-grp-fin.acc-rubl            = d-slts-vats-cons-grp-fin.acc-rubl            + tt-allsum.sum-dsc-rubl-acc                           d-slts-vats-cons-grp-fin.acc-vat-base        = d-slts-vats-cons-grp-fin.acc-vat-base        + tt-allsum.vat-base-acc                           d-slts-vats-cons-grp-fin.acc-vat-rubl        = d-slts-vats-cons-grp-fin.acc-vat-rubl        + tt-allsum.vat-rubl-acc                           d-slts-vats-cons-grp-fin.acc-slt-base        = d-slts-vats-cons-grp-fin.acc-slt-base        + tt-allsum.slt-base-acc                           d-slts-vats-cons-grp-fin.acc-slt-rubl        = d-slts-vats-cons-grp-fin.acc-slt-rubl        + tt-allsum.slt-rubl-acc                           d-slts-vats-cons-grp-fin.acc-road-tax-base   = d-slts-vats-cons-grp-fin.acc-road-tax-base   + tt-allsum.road-tax-base-acc                           d-slts-vats-cons-grp-fin.acc-road-tax-rubl   = d-slts-vats-cons-grp-fin.acc-road-tax-rubl   + tt-allsum.road-tax-rubl-acc                           d-slts-vats-cons-grp-fin.acc-excise-base     = d-slts-vats-cons-grp-fin.acc-excise-base     + tt-allsum.excise-base-acc                           d-slts-vats-cons-grp-fin.acc-excise-rubl     = d-slts-vats-cons-grp-fin.acc-excise-rubl     + tt-allsum.excise-rubl-acc                           d-slts-vats-cons-grp-fin.acc-transport-base  = d-slts-vats-cons-grp-fin.acc-transport-base  + tt-allsum.transport-base-acc                           d-slts-vats-cons-grp-fin.acc-transport-rubl  = d-slts-vats-cons-grp-fin.acc-transport-rubl  + tt-allsum.transport-rubl-acc                           d-slts-vats-cons-grp-fin.acc-other-base      = d-slts-vats-cons-grp-fin.acc-other-base      + tt-allsum.other-base-acc                           d-slts-vats-cons-grp-fin.acc-other-rubl      = d-slts-vats-cons-grp-fin.acc-other-rubl      + tt-allsum.other-rubl-acc                           d-slts-vats-cons-grp-fin.pay-base            = d-slts-vats-cons-grp-fin.pay-base            + tt-allsum.sum-dsc-base-doc                           d-slts-vats-cons-grp-fin.pay-rubl            = d-slts-vats-cons-grp-fin.pay-rubl            + tt-allsum.sum-dsc-rubl-doc                           d-slts-vats-cons-grp-fin.no-vat-base         = d-slts-vats-cons-grp-fin.no-vat-base         + tt-allsum.sum-dsc-base-doc - tt-allsum.vat-base-doc                           d-slts-vats-cons-grp-fin.no-vat-rubl         = d-slts-vats-cons-grp-fin.no-vat-rubl         + tt-allsum.sum-dsc-rubl-doc - tt-allsum.vat-rubl-doc                           d-slts-vats-cons-grp-fin.vat-base            = d-slts-vats-cons-grp-fin.vat-base            + tt-allsum.vat-base-doc                           d-slts-vats-cons-grp-fin.vat-rubl            = d-slts-vats-cons-grp-fin.vat-rubl            + tt-allsum.vat-rubl-doc                           d-slts-vats-cons-grp-fin.vat-base-buyer      = d-slts-vats-cons-grp-fin.vat-base-buyer      + tt-allsum.vat-base-buyer-doc                           d-slts-vats-cons-grp-fin.vat-rubl-buyer      = d-slts-vats-cons-grp-fin.vat-rubl-buyer      + tt-allsum.vat-rubl-buyer-doc                           d-slts-vats-cons-grp-fin.slt-base            = d-slts-vats-cons-grp-fin.slt-base            + tt-allsum.slt-base-doc                           d-slts-vats-cons-grp-fin.slt-rubl            = d-slts-vats-cons-grp-fin.slt-rubl            + tt-allsum.slt-rubl-doc                           d-slts-vats-cons-grp-fin.road-tax            = d-slts-vats-cons-grp-fin.road-tax            + (if varr-b = "base" then tt-allsum.road-tax-base-doc else tt-allsum.road-tax-rubl-doc)                           d-slts-vats-cons-grp-fin.excise              = d-slts-vats-cons-grp-fin.excise              + (if varr-b = "base" then tt-allsum.excise-base-doc   else tt-allsum.excise-rubl-doc)                             d-slts-vats-cons-grp-fin.sale-base           = d-slts-vats-cons-grp-fin.sale-base           + tt-allsum.sum-dsc-base-cur                           d-slts-vats-cons-grp-fin.sale-rubl           = d-slts-vats-cons-grp-fin.sale-rubl           + tt-allsum.sum-dsc-rubl-cur                           d-slts-vats-cons-grp-fin.sale-vat-base       = d-slts-vats-cons-grp-fin.sale-vat-base       + tt-allsum.vat-base-cur                               d-slts-vats-cons-grp-fin.sale-vat-rubl       = d-slts-vats-cons-grp-fin.sale-vat-rubl       + tt-allsum.vat-rubl-cur                               d-slts-vats-cons-grp-fin.sale-vat-buyer-base = d-slts-vats-cons-grp-fin.sale-vat-buyer-base + tt-allsum.vat-base-buyer-cur                           d-slts-vats-cons-grp-fin.sale-vat-buyer-rubl = d-slts-vats-cons-grp-fin.sale-vat-buyer-rubl + tt-allsum.vat-rubl-buyer-cur                           d-slts-vats-cons-grp-fin.sale-slt-base       = d-slts-vats-cons-grp-fin.sale-slt-base       + tt-allsum.slt-base-cur                                 d-slts-vats-cons-grp-fin.sale-slt-rubl       = d-slts-vats-cons-grp-fin.sale-slt-rubl       + tt-allsum.slt-rubl-cur                                 d-slts-vats-cons-grp-fin.sale-road-tax-base  = d-slts-vats-cons-grp-fin.sale-road-tax-base  + tt-allsum.road-tax-base-cur                            d-slts-vats-cons-grp-fin.sale-road-tax-rubl  = d-slts-vats-cons-grp-fin.sale-road-tax-rubl  + tt-allsum.road-tax-rubl-cur                            d-slts-vats-cons-grp-fin.sale-excise-base    = d-slts-vats-cons-grp-fin.sale-excise-base    + tt-allsum.excise-base-cur                              d-slts-vats-cons-grp-fin.sale-excise-rubl    = d-slts-vats-cons-grp-fin.sale-excise-rubl    + tt-allsum.excise-rubl-cur                              d-slts-vats-cons-grp-fin.ov-base             = d-slts-vats-cons-grp-fin.ov-base             + (if varr-b = "base" then (tt-allsum.sum-dsc-base-cur - tt-allsum.sum-dsc-base-doc) else (tt-allsum.sum-dsc-rubl-cur - tt-allsum.sum-dsc-rubl-doc))                           d-slts-vats-cons-grp-fin.ov-vat              = d-slts-vats-cons-grp-fin.ov-vat              + (if varr-b = "base" then (tt-allsum.sum-dsc-base-cur - tt-allsum.sum-dsc-base-doc) else (tt-allsum.sum-dsc-rubl-cur - tt-allsum.sum-dsc-rubl-doc)) * bf_doc-line.vat-pc / (100 + bf_doc-line.vat-pc).
     end.
  end.
end.
if is-wait-on then do: run waitfram-hide in this-procedure. end.
procedure calc-office :
  define buffer bf_gds-dtl for ub.gds-dtl.
  define variable sum-acc-base            as decimal no-undo.
  define variable sum-acc-rubl            as decimal no-undo.
  define variable sum-acc-vat-base        as decimal no-undo.
  define variable sum-acc-vat-rubl        as decimal no-undo.
  define variable sum-acc-slt-base        as decimal no-undo.
  define variable sum-acc-slt-rubl        as decimal no-undo.
  define variable sum-acc-road-tax-base   as decimal no-undo.
  define variable sum-acc-road-tax-rubl   as decimal no-undo.
  define variable sum-acc-excise-base     as decimal no-undo.
  define variable sum-acc-excise-rubl     as decimal no-undo.
  define variable sum-acc-transport-base  as decimal no-undo.
  define variable sum-acc-transport-rubl  as decimal no-undo.
  define variable sum-acc-other-base      as decimal no-undo.
  define variable sum-acc-other-rubl      as decimal no-undo.
  do on error undo, return error return-value :
        for each bf_doc-line no-lock where
             bf_doc-line.doc-code = bf_trn-doc.doc-code on error undo, return error return-value :
      find first bf_gds-dtl no-lock where
                 bf_gds-dtl.doc-code  = bf_doc-line.doc-code  and
                 bf_gds-dtl.artic     = bf_doc-line.artic     and
                 bf_gds-dtl.prod-type = bf_doc-line.prod-type and
                 bf_gds-dtl.prod-code = bf_doc-line.prod-code.
if bf_trn-doc.ext-doc-type = 'ot':U or
   bf_trn-doc.ext-doc-type = ?                 then do:
  assign
   out-vatp-have-vat-slt = yes.
end.
else do:
  find first out-vatp_doc-attr no-lock
    where out-vatp_doc-attr.doc-code  = bf_trn-doc.doc-code
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
find first out-vatp_goods where out-vatp_goods.artic     = bf_doc-line.artic     and
                                   out-vatp_goods.prod-type = bf_doc-line.prod-type and
                                   out-vatp_goods.prod-code = bf_doc-line.prod-code no-lock.
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rootnode in g#library
  (input  bf_doc-line.artic
  ,input  bf_doc-line.prod-type
  ,input  bf_doc-line.prod-code
  ,output varroot-node
  ) no-error .
if error-status :error then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка при определении корневого признака товара" skip
    "Артикул" bf_doc-line.artic bf_doc-line.prod-type bf_doc-line.prod-code skip
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
    "Артикул" bf_doc-line.artic bf_doc-line.prod-type bf_doc-line.prod-code skip
    "Признак" varroot-node skip
    "Запрашивался атрибут" "empty-scale=request" skip
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  undo, return error .
end.
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varoutvprb
  )  .
if varoutvprb = "base":u then do:
  assign
        road-tax-base-sale    =  (if bf_doc-line.road-tax = ? then 0 else bf_doc-line.road-tax * 1)
    excise-base-sale      =  (if bf_doc-line.excise   = ? then 0 else bf_doc-line.excise   * 1)
  .
end.
else do:
  assign
        road-tax-base-sale    =  (if bf_doc-line.road-tax = ? then 0 else bf_doc-line.road-tax / bf_trn-doc.base-rate * bf_trn-doc.base-scale)
    excise-base-sale      =  (if bf_doc-line.excise   = ? then 0 else bf_doc-line.excise   / bf_trn-doc.base-rate * bf_trn-doc.base-scale)
  .
end.
if varoutvprb = "rubl":u then do:
  assign
        road-tax-rubl-sale    = (if bf_doc-line.road-tax = ? then 0 else bf_doc-line.road-tax * 1)
    excise-rubl-sale      = (if bf_doc-line.excise   = ? then 0 else bf_doc-line.excise   * 1) .
end.
else do:
  assign
        road-tax-rubl-sale    = (if bf_doc-line.road-tax = ? then 0 else bf_doc-line.road-tax * bf_trn-doc.base-rate / bf_trn-doc.base-scale)
    excise-rubl-sale      = (if bf_doc-line.excise   = ? then 0 else bf_doc-line.excise   * bf_trn-doc.base-rate / bf_trn-doc.base-scale) .
end.
assign
  varis-cons-parts-have =  no.
assign
  varfact-qnty       = 0
  varcons-qnty       = 0
  varprice-base-cons = 0
  varprice-rubl-cons = 0.
find first out-vatp_doc-line where
           out-vatp_doc-line.doc-code   = bf_trn-doc.doc-code
       and out-vatp_doc-line.artic      = bf_doc-line.artic
       and out-vatp_doc-line.prod-type  = bf_doc-line.prod-type
       and out-vatp_doc-line.prod-code  = bf_doc-line.prod-code no-lock no-error.
if available out-vatp_doc-line           and
  (out-vatp_doc-line.status_ = 'запрос':U or out-vatp_goods.gds-type = 'у':U) then do:
  assign
    varfact-qnty = out-vatp_doc-line.fact-qnty.
end.
else do:
  for each out-vatp_parts where out-vatp_parts.out-code   = bf_trn-doc.doc-code
                               and out-vatp_parts.obj-type   = bf_trn-doc.obj-type
                               and out-vatp_parts.obj-code   = bf_trn-doc.obj-code
                               and out-vatp_parts.artic      = bf_doc-line.artic
                               and out-vatp_parts.prod-type  = bf_doc-line.prod-type
                               and out-vatp_parts.prod-code  = bf_doc-line.prod-code no-lock :
    if out-vatp_parts.purch-code = 2 then do:
assign
  price-rubl-with-tax-loco = out-vatp_parts.price-rubl
  price-base-with-tax-loco = out-vatp_parts.price-base
.
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$".
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
    slt-base-sale               = (if out-vatp-have-vat-slt = no then 0 else bf_gds-dtl.price-base - bf_gds-dtl.discnt-base                - road-tax-base-sale) * bf_doc-line.SLT-pc / (100 + bf_doc-line.SLT-pc)
  vat-base-buyer              = (if out-vatp-have-vat-slt = no then 0 else bf_gds-dtl.price-base - bf_gds-dtl.discnt-base - (if out-vatp-have-vat-slt = no then 0 else bf_gds-dtl.price-base - bf_gds-dtl.discnt-base                - road-tax-base-sale) * bf_doc-line.SLT-pc / (100 + bf_doc-line.SLT-pc) - road-tax-base-sale) * bf_doc-line.vat-pc / (100 + bf_doc-line.vat-pc)
  discnt-base-sale            = bf_gds-dtl.discnt-base
  price-base-with-tax-sale    = (bf_gds-dtl.price-base - bf_gds-dtl.discnt-base)
    slt-rubl-sale               = (if out-vatp-have-vat-slt = no then 0 else bf_gds-dtl.price-rubl - bf_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * bf_doc-line.SLT-pc / (100 + bf_doc-line.SLT-pc)
  vat-rubl-buyer              = (if out-vatp-have-vat-slt = no then 0 else bf_gds-dtl.price-rubl - bf_gds-dtl.discnt-rubl - (if out-vatp-have-vat-slt = no then 0 else bf_gds-dtl.price-rubl - bf_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * bf_doc-line.SLT-pc / (100 + bf_doc-line.SLT-pc) - road-tax-rubl-sale) * bf_doc-line.vat-pc / (100 + bf_doc-line.vat-pc)
  discnt-rubl-sale            = bf_gds-dtl.discnt-rubl
  price-rubl-with-tax-sale    = (bf_gds-dtl.price-rubl - bf_gds-dtl.discnt-rubl)
  .
if bf_trn-doc.doc-type = 'инв':U then do:
  assign
    varfact-qnty = bf_gds-dtl.doc-qnty.
end.
else do:
  assign
    varfact-qnty = bf_gds-dtl.fact-qnty.
end.
if varis-cons-parts-have = no then do:
  assign
        vat-base-sale               = (if out-vatp-have-vat-slt = no then 0 else bf_gds-dtl.price-base - bf_gds-dtl.discnt-base - (if out-vatp-have-vat-slt = no then 0 else bf_gds-dtl.price-base - bf_gds-dtl.discnt-base                - road-tax-base-sale) * bf_doc-line.SLT-pc / (100 + bf_doc-line.SLT-pc) - road-tax-base-sale) * bf_doc-line.vat-pc / (100 + bf_doc-line.vat-pc)
        vat-rubl-sale               = (if out-vatp-have-vat-slt = no then 0 else bf_gds-dtl.price-rubl - bf_gds-dtl.discnt-rubl - (if out-vatp-have-vat-slt = no then 0 else bf_gds-dtl.price-rubl - bf_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * bf_doc-line.SLT-pc / (100 + bf_doc-line.SLT-pc) - road-tax-rubl-sale) * bf_doc-line.vat-pc / (100 + bf_doc-line.vat-pc).
end.
else do:
  if bf_trn-doc.doc-type = 'инв':U then do:
    assign
            vat-base-sale               = (if out-vatp-have-vat-slt = no then 0 else (((bf_gds-dtl.price-base - bf_gds-dtl.discnt-base) - (if out-vatp-have-vat-slt = no then 0 else bf_gds-dtl.price-base - bf_gds-dtl.discnt-base                - road-tax-base-sale) * bf_doc-line.SLT-pc / (100 + bf_doc-line.SLT-pc) - road-tax-base-sale - varprice-base-cons) * bf_doc-line.cons-vat-pc / (100 + bf_doc-line.cons-vat-pc) * bf_gds-dtl.doc-qnty * varcons-qnty / varfact-qnty + ((bf_gds-dtl.price-base - bf_gds-dtl.discnt-base) - (if out-vatp-have-vat-slt = no then 0 else bf_gds-dtl.price-base - bf_gds-dtl.discnt-base                - road-tax-base-sale) * bf_doc-line.SLT-pc / (100 + bf_doc-line.SLT-pc) - road-tax-base-sale) * bf_doc-line.vat-pc / (100 + bf_doc-line.vat-pc) * bf_gds-dtl.doc-qnty * (varfact-qnty - varcons-qnty) / varfact-qnty) / varfact-qnty)
            vat-rubl-sale               = (if out-vatp-have-vat-slt = no then 0 else (((bf_gds-dtl.price-rubl - bf_gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt = no then 0 else bf_gds-dtl.price-rubl - bf_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * bf_doc-line.SLT-pc / (100 + bf_doc-line.SLT-pc) - road-tax-rubl-sale - varprice-rubl-cons) * bf_doc-line.cons-vat-pc / (100 + bf_doc-line.cons-vat-pc) * bf_gds-dtl.doc-qnty * varcons-qnty / varfact-qnty + ((bf_gds-dtl.price-rubl - bf_gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt = no then 0 else bf_gds-dtl.price-rubl - bf_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * bf_doc-line.SLT-pc / (100 + bf_doc-line.SLT-pc) - road-tax-rubl-sale) * bf_doc-line.vat-pc / (100 + bf_doc-line.vat-pc) * bf_gds-dtl.doc-qnty * (varfact-qnty - varcons-qnty) / varfact-qnty) / varfact-qnty)
     .
  end.
  else do:
    assign
            vat-base-sale               = (if out-vatp-have-vat-slt = no then 0 else (((bf_gds-dtl.price-base - bf_gds-dtl.discnt-base) - (if out-vatp-have-vat-slt = no then 0 else bf_gds-dtl.price-base - bf_gds-dtl.discnt-base                - road-tax-base-sale) * bf_doc-line.SLT-pc / (100 + bf_doc-line.SLT-pc) - road-tax-base-sale - varprice-base-cons) * bf_doc-line.cons-vat-pc / (100 + bf_doc-line.cons-vat-pc) * bf_gds-dtl.fact-qnty * varcons-qnty / varfact-qnty + ((bf_gds-dtl.price-base - bf_gds-dtl.discnt-base) - (if out-vatp-have-vat-slt = no then 0 else bf_gds-dtl.price-base - bf_gds-dtl.discnt-base                - road-tax-base-sale) * bf_doc-line.SLT-pc / (100 + bf_doc-line.SLT-pc) - varprice-base-cons) * bf_doc-line.vat-pc / (100 + bf_doc-line.vat-pc) * bf_gds-dtl.fact-qnty * (varfact-qnty - varcons-qnty) / varfact-qnty) / varfact-qnty)
            vat-rubl-sale               = (if out-vatp-have-vat-slt = no then 0 else (((bf_gds-dtl.price-rubl - bf_gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt = no then 0 else bf_gds-dtl.price-rubl - bf_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * bf_doc-line.SLT-pc / (100 + bf_doc-line.SLT-pc) - road-tax-rubl-sale - varprice-rubl-cons) * bf_doc-line.cons-vat-pc / (100 + bf_doc-line.cons-vat-pc) * bf_gds-dtl.fact-qnty * varcons-qnty / varfact-qnty + ((bf_gds-dtl.price-rubl - bf_gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt = no then 0 else bf_gds-dtl.price-rubl - bf_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * bf_doc-line.SLT-pc / (100 + bf_doc-line.SLT-pc) - varprice-rubl-cons) * bf_doc-line.vat-pc / (100 + bf_doc-line.vat-pc) * bf_gds-dtl.fact-qnty * (varfact-qnty - varcons-qnty) / varfact-qnty) / varfact-qnty)
     .
  end.
end.
assign
price-base-without-tax-sale = price-base-with-tax-sale - vat-base-sale - slt-base-sale - road-tax-base-sale
price-rubl-without-tax-sale = price-rubl-with-tax-sale - vat-rubl-sale - slt-rubl-sale - road-tax-rubl-sale.
if bf_trn-doc.ext-doc-type = 'ot':U or
   bf_trn-doc.ext-doc-type = ?                 then do:
  assign
   out-vatp-have-vat-slt-cur = yes.
end.
else do:
  find first out-vatp_doc-attr-cur no-lock
    where out-vatp_doc-attr-cur.doc-code  = bf_trn-doc.doc-code
      and out-vatp_doc-attr-cur.attr-code = 'envd':U
      no-error .
  if not available out-vatp_doc-attr-cur then do:
    assign
      out-vatp-have-vat-slt-cur = yes.
  end.
  else do:
     out-vatp-have-vat-slt-cur = no.
  end.
end.
find first out-vatp_goods-cur where out-vatp_goods-cur.artic     = bf_doc-line.artic     and
                                   out-vatp_goods-cur.prod-type = bf_doc-line.prod-type and
                                   out-vatp_goods-cur.prod-code = bf_doc-line.prod-code no-lock.
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rootnode in g#library
  (input  bf_doc-line.artic
  ,input  bf_doc-line.prod-type
  ,input  bf_doc-line.prod-code
  ,output varroot-node-cur
  ) no-error .
if error-status :error then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка при определении корневого признака товара" skip
    "Артикул" bf_doc-line.artic bf_doc-line.prod-type bf_doc-line.prod-code skip
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  undo, return error .
end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prtat in g#library
  (input  varroot-node-cur
  ,input  'empty-scale=request'
  ,output varempty-scale-cur
  ) no-error .
if error-status :error then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка при определении атрибута признака" skip
    "Артикул" bf_doc-line.artic bf_doc-line.prod-type bf_doc-line.prod-code skip
    "Признак" varroot-node-cur skip
    "Запрашивался атрибут" "empty-scale=request" skip
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  undo, return error .
end.
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varoutvprb-cur
  )  .
if varoutvprb-cur = "base":u then do:
  assign
        road-tax-base-sale-cur    =  (if bf_doc-line.road-tax = ? then 0 else bf_doc-line.road-tax * 1)
    excise-base-sale-cur      =  (if bf_doc-line.excise   = ? then 0 else bf_doc-line.excise   * 1)
  .
end.
else do:
  assign
        road-tax-base-sale-cur    =  (if bf_doc-line.road-tax = ? then 0 else bf_doc-line.road-tax / bf_trn-doc.base-rate * bf_trn-doc.base-scale)
    excise-base-sale-cur      =  (if bf_doc-line.excise   = ? then 0 else bf_doc-line.excise   / bf_trn-doc.base-rate * bf_trn-doc.base-scale)
  .
end.
if varoutvprb-cur = "rubl":u then do:
  assign
        road-tax-rubl-sale-cur    = (if bf_doc-line.road-tax = ? then 0 else bf_doc-line.road-tax * 1)
    excise-rubl-sale-cur      = (if bf_doc-line.excise   = ? then 0 else bf_doc-line.excise   * 1) .
end.
else do:
  assign
        road-tax-rubl-sale-cur    = (if bf_doc-line.road-tax = ? then 0 else bf_doc-line.road-tax * bf_trn-doc.base-rate / bf_trn-doc.base-scale)
    excise-rubl-sale-cur      = (if bf_doc-line.excise   = ? then 0 else bf_doc-line.excise   * bf_trn-doc.base-rate / bf_trn-doc.base-scale) .
end.
assign
  varis-cons-parts-have-cur =  no.
assign
  varfact-qnty-cur       = 0
  varcons-qnty-cur       = 0
  varprice-base-cons-cur = 0
  varprice-rubl-cons-cur = 0.
find first out-vatp_doc-line-cur where
           out-vatp_doc-line-cur.doc-code   = bf_trn-doc.doc-code
       and out-vatp_doc-line-cur.artic      = bf_doc-line.artic
       and out-vatp_doc-line-cur.prod-type  = bf_doc-line.prod-type
       and out-vatp_doc-line-cur.prod-code  = bf_doc-line.prod-code no-lock no-error.
if available out-vatp_doc-line-cur           and
  (out-vatp_doc-line-cur.status_ = 'запрос':U or out-vatp_goods-cur.gds-type = 'у':U) then do:
  assign
    varfact-qnty-cur = out-vatp_doc-line-cur.fact-qnty.
end.
else do:
  for each out-vatp_parts-cur where out-vatp_parts-cur.out-code   = bf_trn-doc.doc-code
                               and out-vatp_parts-cur.obj-type   = bf_trn-doc.obj-type
                               and out-vatp_parts-cur.obj-code   = bf_trn-doc.obj-code
                               and out-vatp_parts-cur.artic      = bf_doc-line.artic
                               and out-vatp_parts-cur.prod-type  = bf_doc-line.prod-type
                               and out-vatp_parts-cur.prod-code  = bf_doc-line.prod-code no-lock :
    if out-vatp_parts-cur.purch-code = 2 then do:
assign
  price-rubl-with-tax-loco-cur = out-vatp_parts-cur.price-rubl
  price-base-with-tax-loco-cur = out-vatp_parts-cur.price-base
.
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprbo-cur
  )  .
  if out-vatp_parts-cur.out-code = 'free-zone':U     or
     out-vatp_parts-cur.out-code = 'out-zone':U   or
     out-vatp_parts-cur.doc-type = 'акт':U then do:
    assign
      in-vatp-have-vat-slto-cur = yes.
  end.
  else do:
    find first in-vatp_doc-attro-cur no-lock
      where in-vatp_doc-attro-cur.doc-code  = out-vatp_parts-cur.out-code
        and in-vatp_doc-attro-cur.attr-code = 'envd':U
      no-error .
    if not available in-vatp_doc-attro-cur then do:
      assign
        in-vatp-have-vat-slto-cur = yes.
    end.
    else do:
         in-vatp-have-vat-slto-cur = no.
    end.
  end.
  assign
   price-cli-with-tax-loco-cur = out-vatp_parts-cur.price-cli
   cli-base-rateo-cur          = out-vatp_parts-cur.cli-base-rate.
  ASSIGN   road-tax-base-loco-cur  = (if out-vatp_parts-cur.road-tax-base  = ? then 0 else out-vatp_parts-cur.road-tax-base)
           road-tax-rubl-loco-cur  = (if out-vatp_parts-cur.road-tax-rubl  = ? then 0 else out-vatp_parts-cur.road-tax-rubl).
  ASSIGN  transport-base-loco-cur = (if out-vatp_parts-cur.transport-base = ? then 0 else out-vatp_parts-cur.transport-base)
          transport-rubl-loco-cur = (if out-vatp_parts-cur.transport-rubl = ? then 0 else out-vatp_parts-cur.transport-rubl)
          other-base-loco-cur     = (if out-vatp_parts-cur.other-base     = ? then 0 else out-vatp_parts-cur.other-base)
          other-rubl-loco-cur     = (if out-vatp_parts-cur.other-rubl     = ? then 0 else out-vatp_parts-cur.other-rubl)
          vat-pc-loco-cur         = (if out-vatp_parts-cur.vat-pc         = ? then 0 else out-vatp_parts-cur.vat-pc)
          slt-pc-loco-cur         = (if out-vatp_parts-cur.slt-pc         = ? then 0 else out-vatp_parts-cur.slt-pc).
          ASSIGN   slt-base-loco-cur    = (if in-vatp-have-vat-slto-cur = no then 0 else (price-base-with-tax-loco-cur - ((if road-tax-base-loco-cur  = ? then 0 else road-tax-base-loco-cur) + (if transport-base-loco-cur = ? then 0 else transport-base-loco-cur) + (if other-base-loco-cur = ? then 0 else other-base-loco-cur)))                           * slt-pc-loco-cur / (100 + slt-pc-loco-cur))                        vat-base-loco-cur    = (if in-vatp-have-vat-slto-cur = no then 0 else (price-base-with-tax-loco-cur - ((if road-tax-base-loco-cur  = ? then 0 else road-tax-base-loco-cur) + (if transport-base-loco-cur = ? then 0 else transport-base-loco-cur) + (if other-base-loco-cur = ? then 0 else other-base-loco-cur))) * (1 - slt-pc-loco-cur / (100 + slt-pc-loco-cur)) * vat-pc-loco-cur / (100 + vat-pc-loco-cur)).
    ASSIGN   slt-rubl-loco-cur    = (if in-vatp-have-vat-slto-cur = no then 0 else (price-rubl-with-tax-loco-cur - ((if road-tax-rubl-loco-cur  = ? then 0 else road-tax-rubl-loco-cur) + (if transport-rubl-loco-cur = ? then 0 else transport-rubl-loco-cur) + (if other-rubl-loco-cur = ? then 0 else other-rubl-loco-cur)))                           * slt-pc-loco-cur / (100 + slt-pc-loco-cur))                        vat-rubl-loco-cur    = (if in-vatp-have-vat-slto-cur = no then 0 else (price-rubl-with-tax-loco-cur - ((if road-tax-rubl-loco-cur  = ? then 0 else road-tax-rubl-loco-cur) + (if transport-rubl-loco-cur = ? then 0 else transport-rubl-loco-cur) + (if other-rubl-loco-cur = ? then 0 else other-rubl-loco-cur))) * (1 - slt-pc-loco-cur / (100 + slt-pc-loco-cur)) * vat-pc-loco-cur / (100 + vat-pc-loco-cur)).
  assign
    exch-rate-cli-loco-cur = (out-vatp_parts-cur.price-rubl - transport-rubl-loco-cur - other-rubl-loco-cur - road-tax-rubl-loco-cur - (if out-vatp_parts-cur.vat-type <> 'в т. ч.':U then vat-rubl-loco-cur else 0) - (if out-vatp_parts-cur.slt-type <> 'в т. ч.':U then slt-rubl-loco-cur else 0)) / out-vatp_parts-cur.price-cli .
  assign
    slt-cli-loco-cur        = slt-rubl-loco-cur       / exch-rate-cli-loco-cur
    vat-cli-loco-cur        = vat-rubl-loco-cur       / exch-rate-cli-loco-cur
    road-tax-cli-loco-cur   = road-tax-rubl-loco-cur  / exch-rate-cli-loco-cur
    transport-cli-loco-cur  = 0
    other-cli-loco-cur      = 0
  .
ASSIGN
          price-base-without-tax-loco-cur = price-base-with-tax-loco-cur - vat-base-loco-cur - slt-base-loco-cur - ((if road-tax-base-loco-cur  = ? then 0 else road-tax-base-loco-cur) + (if transport-base-loco-cur = ? then 0 else transport-base-loco-cur) + (if other-base-loco-cur = ? then 0 else other-base-loco-cur))
    price-rubl-without-tax-loco-cur = price-rubl-with-tax-loco-cur - vat-rubl-loco-cur - slt-rubl-loco-cur - ((if road-tax-rubl-loco-cur  = ? then 0 else road-tax-rubl-loco-cur) + (if transport-rubl-loco-cur = ? then 0 else transport-rubl-loco-cur) + (if other-rubl-loco-cur = ? then 0 else other-rubl-loco-cur))
.
      assign
        varprice-base-cons-cur = varprice-base-cons-cur + (price-base-with-tax-loco-cur - (if road-tax-base-loco-cur = ? then 0 else road-tax-base-loco-cur))* out-vatp_parts-cur.fact-qnty
        varprice-rubl-cons-cur = varprice-rubl-cons-cur + (price-rubl-with-tax-loco-cur - (if road-tax-rubl-loco-cur = ? then 0 else road-tax-rubl-loco-cur))* out-vatp_parts-cur.fact-qnty.
      assign
        varis-cons-parts-have-cur = yes
        varcons-qnty-cur          = varcons-qnty-cur + out-vatp_parts-cur.fact-qnty.
    end.
    assign
      varfact-qnty-cur = varfact-qnty-cur + out-vatp_parts-cur.fact-qnty.
  end.
end.
assign
  varprice-base-cons-cur = varprice-base-cons-cur / varcons-qnty-cur
  varprice-rubl-cons-cur = varprice-rubl-cons-cur / varcons-qnty-cur.
if varprice-base-cons-cur = ? then do:
  assign
    varprice-base-cons-cur = 0.
end.
if varprice-rubl-cons-cur = ? then do:
  assign
    varprice-rubl-cons-cur = 0.
end.
assign
    slt-base-sale-cur               = (if out-vatp-have-vat-slt-cur = no then 0 else bf_gds-dtl.price-base - bf_gds-dtl.discnt-base                - road-tax-base-sale-cur) * bf_doc-line.SLT-pc / (100 + bf_doc-line.SLT-pc)
  vat-base-buyer-cur              = (if out-vatp-have-vat-slt-cur = no then 0 else bf_gds-dtl.price-base - bf_gds-dtl.discnt-base - (if out-vatp-have-vat-slt-cur = no then 0 else bf_gds-dtl.price-base - bf_gds-dtl.discnt-base                - road-tax-base-sale-cur) * bf_doc-line.SLT-pc / (100 + bf_doc-line.SLT-pc) - road-tax-base-sale-cur) * bf_doc-line.vat-pc / (100 + bf_doc-line.vat-pc)
  discnt-base-sale-cur            = bf_gds-dtl.discnt-base
  price-base-with-tax-sale-cur    = (bf_gds-dtl.price-base - bf_gds-dtl.discnt-base)
    slt-rubl-sale-cur               = (if out-vatp-have-vat-slt-cur = no then 0 else bf_gds-dtl.price-rubl - bf_gds-dtl.discnt-rubl                - road-tax-rubl-sale-cur) * bf_doc-line.SLT-pc / (100 + bf_doc-line.SLT-pc)
  vat-rubl-buyer-cur              = (if out-vatp-have-vat-slt-cur = no then 0 else bf_gds-dtl.price-rubl - bf_gds-dtl.discnt-rubl - (if out-vatp-have-vat-slt-cur = no then 0 else bf_gds-dtl.price-rubl - bf_gds-dtl.discnt-rubl                - road-tax-rubl-sale-cur) * bf_doc-line.SLT-pc / (100 + bf_doc-line.SLT-pc) - road-tax-rubl-sale-cur) * bf_doc-line.vat-pc / (100 + bf_doc-line.vat-pc)
  discnt-rubl-sale-cur            = bf_gds-dtl.discnt-rubl
  price-rubl-with-tax-sale-cur    = (bf_gds-dtl.price-rubl - bf_gds-dtl.discnt-rubl)
  .
if bf_trn-doc.doc-type = 'инв':U then do:
  assign
    varfact-qnty-cur = bf_gds-dtl.doc-qnty.
end.
else do:
  assign
    varfact-qnty-cur = bf_gds-dtl.fact-qnty.
end.
if varis-cons-parts-have-cur = no then do:
  assign
        vat-base-sale-cur               = (if out-vatp-have-vat-slt-cur = no then 0 else bf_gds-dtl.price-base - bf_gds-dtl.discnt-base - (if out-vatp-have-vat-slt-cur = no then 0 else bf_gds-dtl.price-base - bf_gds-dtl.discnt-base                - road-tax-base-sale-cur) * bf_doc-line.SLT-pc / (100 + bf_doc-line.SLT-pc) - road-tax-base-sale-cur) * bf_doc-line.vat-pc / (100 + bf_doc-line.vat-pc)
        vat-rubl-sale-cur               = (if out-vatp-have-vat-slt-cur = no then 0 else bf_gds-dtl.price-rubl - bf_gds-dtl.discnt-rubl - (if out-vatp-have-vat-slt-cur = no then 0 else bf_gds-dtl.price-rubl - bf_gds-dtl.discnt-rubl                - road-tax-rubl-sale-cur) * bf_doc-line.SLT-pc / (100 + bf_doc-line.SLT-pc) - road-tax-rubl-sale-cur) * bf_doc-line.vat-pc / (100 + bf_doc-line.vat-pc).
end.
else do:
  if bf_trn-doc.doc-type = 'инв':U then do:
    assign
            vat-base-sale-cur               = (if out-vatp-have-vat-slt-cur = no then 0 else (((bf_gds-dtl.price-base - bf_gds-dtl.discnt-base) - (if out-vatp-have-vat-slt-cur = no then 0 else bf_gds-dtl.price-base - bf_gds-dtl.discnt-base                - road-tax-base-sale-cur) * bf_doc-line.SLT-pc / (100 + bf_doc-line.SLT-pc) - road-tax-base-sale-cur - varprice-base-cons-cur) * bf_doc-line.cons-vat-pc / (100 + bf_doc-line.cons-vat-pc) * bf_gds-dtl.doc-qnty * varcons-qnty-cur / varfact-qnty-cur + ((bf_gds-dtl.price-base - bf_gds-dtl.discnt-base) - (if out-vatp-have-vat-slt-cur = no then 0 else bf_gds-dtl.price-base - bf_gds-dtl.discnt-base                - road-tax-base-sale-cur) * bf_doc-line.SLT-pc / (100 + bf_doc-line.SLT-pc) - road-tax-base-sale-cur) * bf_doc-line.vat-pc / (100 + bf_doc-line.vat-pc) * bf_gds-dtl.doc-qnty * (varfact-qnty-cur - varcons-qnty-cur) / varfact-qnty-cur) / varfact-qnty-cur)
            vat-rubl-sale-cur               = (if out-vatp-have-vat-slt-cur = no then 0 else (((bf_gds-dtl.price-rubl - bf_gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt-cur = no then 0 else bf_gds-dtl.price-rubl - bf_gds-dtl.discnt-rubl                - road-tax-rubl-sale-cur) * bf_doc-line.SLT-pc / (100 + bf_doc-line.SLT-pc) - road-tax-rubl-sale-cur - varprice-rubl-cons-cur) * bf_doc-line.cons-vat-pc / (100 + bf_doc-line.cons-vat-pc) * bf_gds-dtl.doc-qnty * varcons-qnty-cur / varfact-qnty-cur + ((bf_gds-dtl.price-rubl - bf_gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt-cur = no then 0 else bf_gds-dtl.price-rubl - bf_gds-dtl.discnt-rubl                - road-tax-rubl-sale-cur) * bf_doc-line.SLT-pc / (100 + bf_doc-line.SLT-pc) - road-tax-rubl-sale-cur) * bf_doc-line.vat-pc / (100 + bf_doc-line.vat-pc) * bf_gds-dtl.doc-qnty * (varfact-qnty-cur - varcons-qnty-cur) / varfact-qnty-cur) / varfact-qnty-cur)
     .
  end.
  else do:
    assign
            vat-base-sale-cur               = (if out-vatp-have-vat-slt-cur = no then 0 else (((bf_gds-dtl.price-base - bf_gds-dtl.discnt-base) - (if out-vatp-have-vat-slt-cur = no then 0 else bf_gds-dtl.price-base - bf_gds-dtl.discnt-base                - road-tax-base-sale-cur) * bf_doc-line.SLT-pc / (100 + bf_doc-line.SLT-pc) - road-tax-base-sale-cur - varprice-base-cons-cur) * bf_doc-line.cons-vat-pc / (100 + bf_doc-line.cons-vat-pc) * bf_gds-dtl.fact-qnty * varcons-qnty-cur / varfact-qnty-cur + ((bf_gds-dtl.price-base - bf_gds-dtl.discnt-base) - (if out-vatp-have-vat-slt-cur = no then 0 else bf_gds-dtl.price-base - bf_gds-dtl.discnt-base                - road-tax-base-sale-cur) * bf_doc-line.SLT-pc / (100 + bf_doc-line.SLT-pc) - varprice-base-cons-cur) * bf_doc-line.vat-pc / (100 + bf_doc-line.vat-pc) * bf_gds-dtl.fact-qnty * (varfact-qnty-cur - varcons-qnty-cur) / varfact-qnty-cur) / varfact-qnty-cur)
            vat-rubl-sale-cur               = (if out-vatp-have-vat-slt-cur = no then 0 else (((bf_gds-dtl.price-rubl - bf_gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt-cur = no then 0 else bf_gds-dtl.price-rubl - bf_gds-dtl.discnt-rubl                - road-tax-rubl-sale-cur) * bf_doc-line.SLT-pc / (100 + bf_doc-line.SLT-pc) - road-tax-rubl-sale-cur - varprice-rubl-cons-cur) * bf_doc-line.cons-vat-pc / (100 + bf_doc-line.cons-vat-pc) * bf_gds-dtl.fact-qnty * varcons-qnty-cur / varfact-qnty-cur + ((bf_gds-dtl.price-rubl - bf_gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt-cur = no then 0 else bf_gds-dtl.price-rubl - bf_gds-dtl.discnt-rubl                - road-tax-rubl-sale-cur) * bf_doc-line.SLT-pc / (100 + bf_doc-line.SLT-pc) - varprice-rubl-cons-cur) * bf_doc-line.vat-pc / (100 + bf_doc-line.vat-pc) * bf_gds-dtl.fact-qnty * (varfact-qnty-cur - varcons-qnty-cur) / varfact-qnty-cur) / varfact-qnty-cur)
     .
  end.
end.
assign
price-base-without-tax-sale-cur = price-base-with-tax-sale-cur - vat-base-sale-cur - slt-base-sale-cur - road-tax-base-sale-cur
price-rubl-without-tax-sale-cur = price-rubl-with-tax-sale-cur - vat-rubl-sale-cur - slt-rubl-sale-cur - road-tax-rubl-sale-cur.
      assign varqnty                          = bf_gds-dtl.fact-qnty
             sum-price-base-with-tax-sale     = price-base-with-tax-sale     * varqnty
             sum-price-rubl-with-tax-sale     = price-rubl-with-tax-sale     * varqnty
             sum-vat-base-sale                = vat-base-sale                * varqnty
             sum-vat-rubl-sale                = vat-rubl-sale                * varqnty
             sum-vat-base-buyer               = vat-base-buyer               * varqnty
             sum-vat-rubl-buyer               = vat-rubl-buyer               * varqnty
             sum-slt-base-sale                = slt-base-sale                * varqnty
             sum-slt-rubl-sale                = slt-rubl-sale                * varqnty
             sum-road-tax-base-sale           = road-tax-base-sale           * varqnty
             sum-road-tax-rubl-sale           = road-tax-rubl-sale           * varqnty
             sum-excise-base-sale             = excise-base-sale             * varqnty
             sum-excise-rubl-sale             = excise-rubl-sale             * varqnty
             sum-discnt-base-sale             = discnt-base-sale             * varqnty
             sum-discnt-rubl-sale             = discnt-rubl-sale             * varqnty
             sum-price-rubl-with-tax-sale-cur = price-rubl-with-tax-sale-cur * varqnty
             sum-price-base-with-tax-sale-cur = price-base-with-tax-sale-cur * varqnty
             sum-vat-base-sale-cur            = vat-base-sale-cur            * varqnty
             sum-vat-rubl-sale-cur            = vat-rubl-sale-cur            * varqnty
             sum-vat-base-buyer-cur           = vat-base-buyer-cur           * varqnty
             sum-vat-rubl-buyer-cur           = vat-rubl-buyer-cur           * varqnty
             sum-slt-base-sale-cur            = slt-base-sale-cur            * varqnty
             sum-slt-rubl-sale-cur            = slt-rubl-sale-cur            * varqnty
             sum-road-tax-base-sale-cur       = road-tax-base-sale-cur       * varqnty
             sum-road-tax-rubl-sale-cur       = road-tax-rubl-sale-cur       * varqnty
             sum-excise-base-sale-cur         = excise-base-sale-cur         * varqnty
             sum-excise-rubl-sale-cur         = excise-rubl-sale-cur         * varqnty
             sum-discnt-base-sale-cur         = discnt-base-sale-cur         * varqnty
             sum-discnt-rubl-sale-cur         = discnt-rubl-sale-cur         * varqnty
             sum-acc-base                     = bf_doc-line.price-base       * varqnty
             sum-acc-rubl                     = bf_doc-line.price-rubl       * varqnty
             sum-acc-vat-base                 = (bf_doc-line.price-base * varqnty - bf_doc-line.price-base * bf_doc-line.slt-pc / (100 + bf_doc-line.slt-pc) * varqnty) * bf_doc-line.vat-pc / (100 + bf_doc-line.vat-pc)
             sum-acc-vat-rubl                 = (bf_doc-line.price-rubl * varqnty - bf_doc-line.price-rubl * bf_doc-line.slt-pc / (100 + bf_doc-line.slt-pc) * varqnty) * bf_doc-line.vat-pc / (100 + bf_doc-line.vat-pc)
             sum-acc-slt-base                 = bf_doc-line.price-base * bf_doc-line.slt-pc / (100 + bf_doc-line.slt-pc) * varqnty
             sum-acc-slt-rubl                 = bf_doc-line.price-rubl * bf_doc-line.slt-pc / (100 + bf_doc-line.slt-pc) * varqnty
             sum-acc-road-tax-base            = 0
             sum-acc-road-tax-rubl            = 0
             sum-acc-excise-base              = 0
             sum-acc-excise-rubl              = 0
             sum-acc-transport-base           = 0
             sum-acc-transport-rubl           = 0
             sum-acc-other-base               = 0
             sum-acc-other-rubl               = 0.
            find first tt-title where tt-title.purch-code = 1 no-error.
      if not available tt-title then do:
        create tt-title.
        assign tt-title.purch-code = 1
               tt-title.purch-name = 'выкуп':U.
      end.
      assign tt-title.fact-qnty           = tt-title.fact-qnty           + varqnty                                   tt-title.acc-base            = tt-title.acc-base            + sum-acc-base                                            tt-title.acc-rubl            = tt-title.acc-rubl            + sum-acc-rubl                                            tt-title.acc-vat-base        = tt-title.acc-vat-base        + sum-acc-vat-base                                        tt-title.acc-vat-rubl        = tt-title.acc-vat-rubl        + sum-acc-vat-rubl                                        tt-title.acc-slt-base        = tt-title.acc-slt-base        + sum-acc-slt-base                                        tt-title.acc-slt-rubl        = tt-title.acc-slt-rubl        + sum-acc-slt-rubl                                        tt-title.acc-road-tax-base   = tt-title.acc-road-tax-base   + sum-acc-road-tax-base                                   tt-title.acc-road-tax-rubl   = tt-title.acc-road-tax-rubl   + sum-acc-road-tax-rubl                                   tt-title.acc-excise-base     = tt-title.acc-excise-base     + sum-acc-excise-base                                     tt-title.acc-excise-rubl     = tt-title.acc-excise-rubl     + sum-acc-excise-rubl                                     tt-title.acc-transport-base  = tt-title.acc-transport-base  + sum-acc-transport-base                                  tt-title.acc-transport-rubl  = tt-title.acc-transport-rubl  + sum-acc-transport-rubl                                  tt-title.acc-other-base      = tt-title.acc-other-base      + sum-acc-other-base                                      tt-title.acc-other-rubl      = tt-title.acc-other-rubl      + sum-acc-other-rubl                                      tt-title.pay-base            = tt-title.pay-base            + sum-price-base-with-tax-sale                                  tt-title.pay-rubl            = tt-title.pay-rubl            + sum-price-rubl-with-tax-sale                                  tt-title.vat-base            = tt-title.vat-base            + sum-vat-base-sale                                  tt-title.vat-rubl            = tt-title.vat-rubl            + sum-vat-rubl-sale                                  tt-title.no-vat-base         = tt-title.no-vat-base         + sum-price-base-with-tax-sale - sum-vat-base-sale                                  tt-title.no-vat-rubl         = tt-title.no-vat-rubl         + sum-price-rubl-with-tax-sale - sum-vat-rubl-sale                                  tt-title.vat-base-buyer      = tt-title.vat-base-buyer      + sum-vat-base-buyer                                  tt-title.vat-rubl-buyer      = tt-title.vat-rubl-buyer      + sum-vat-rubl-buyer                                  tt-title.slt-base            = tt-title.slt-base            + sum-slt-base-sale                                  tt-title.slt-rubl            = tt-title.slt-rubl            + sum-slt-rubl-sale                                  tt-title.road-tax            = tt-title.road-tax            + (if varr-b = "base" then sum-road-tax-base-sale else sum-road-tax-rubl-sale)                                  tt-title.excise              = tt-title.excise              + (if varr-b = "base" then sum-excise-base-sale   else sum-excise-rubl-sale)                                    tt-title.sale-base           = tt-title.sale-base           + sum-price-base-with-tax-sale-cur                                  tt-title.sale-rubl           = tt-title.sale-rubl           + sum-price-rubl-with-tax-sale-cur                                  tt-title.sale-vat-base       = tt-title.sale-vat-base       + sum-vat-base-sale-cur                                       tt-title.sale-vat-rubl       = tt-title.sale-vat-rubl       + sum-vat-rubl-sale-cur                                       tt-title.sale-vat-buyer-base = tt-title.sale-vat-buyer-base + sum-vat-base-buyer-cur                                      tt-title.sale-vat-buyer-rubl = tt-title.sale-vat-buyer-rubl + sum-vat-rubl-buyer-cur                                      tt-title.sale-slt-base       = tt-title.sale-slt-base       + sum-slt-base-sale-cur                                       tt-title.sale-slt-rubl       = tt-title.sale-slt-rubl       + sum-slt-rubl-sale-cur                                       tt-title.sale-road-tax-base  = tt-title.sale-road-tax-base  + sum-road-tax-base-sale-cur                                  tt-title.sale-road-tax-rubl  = tt-title.sale-road-tax-rubl  + sum-road-tax-rubl-sale-cur                                  tt-title.sale-excise-base    = tt-title.sale-excise-base    + sum-excise-base-sale-cur                                    tt-title.sale-excise-rubl    = tt-title.sale-excise-rubl    + sum-excise-rubl-sale-cur                                    tt-title.ov-base             = tt-title.ov-base             + (if varr-b = "base" then (sum-price-base-with-tax-sale-cur - sum-price-base-with-tax-sale) else (sum-price-rubl-with-tax-sale-cur - sum-price-rubl-with-tax-sale))                                  tt-title.ov-vat              = tt-title.ov-vat              + (if varr-b = "base" then (sum-price-base-with-tax-sale-cur - sum-price-base-with-tax-sale) else (sum-price-rubl-with-tax-sale-cur - sum-price-rubl-with-tax-sale)) * bf_doc-line.vat-pc / (100 + bf_doc-line.vat-pc).
            if varcalc-title-fin = yes then do:
        find first tt-title-fin where
                   tt-title-fin.purch-code    = 1 and
                   tt-title-fin.contract-code = 0                     no-error.
        if not available tt-title-fin then do:
          create tt-title-fin.
          assign tt-title-fin.purch-code    = 1
                 tt-title-fin.contract-code = 0
                 tt-title-fin.purch-name    = 'выкуп':U.
        end.
        assign tt-title-fin.fact-qnty           = tt-title-fin.fact-qnty           + varqnty                                   tt-title-fin.acc-base            = tt-title-fin.acc-base            + sum-acc-base                                            tt-title-fin.acc-rubl            = tt-title-fin.acc-rubl            + sum-acc-rubl                                            tt-title-fin.acc-vat-base        = tt-title-fin.acc-vat-base        + sum-acc-vat-base                                        tt-title-fin.acc-vat-rubl        = tt-title-fin.acc-vat-rubl        + sum-acc-vat-rubl                                        tt-title-fin.acc-slt-base        = tt-title-fin.acc-slt-base        + sum-acc-slt-base                                        tt-title-fin.acc-slt-rubl        = tt-title-fin.acc-slt-rubl        + sum-acc-slt-rubl                                        tt-title-fin.acc-road-tax-base   = tt-title-fin.acc-road-tax-base   + sum-acc-road-tax-base                                   tt-title-fin.acc-road-tax-rubl   = tt-title-fin.acc-road-tax-rubl   + sum-acc-road-tax-rubl                                   tt-title-fin.acc-excise-base     = tt-title-fin.acc-excise-base     + sum-acc-excise-base                                     tt-title-fin.acc-excise-rubl     = tt-title-fin.acc-excise-rubl     + sum-acc-excise-rubl                                     tt-title-fin.acc-transport-base  = tt-title-fin.acc-transport-base  + sum-acc-transport-base                                  tt-title-fin.acc-transport-rubl  = tt-title-fin.acc-transport-rubl  + sum-acc-transport-rubl                                  tt-title-fin.acc-other-base      = tt-title-fin.acc-other-base      + sum-acc-other-base                                      tt-title-fin.acc-other-rubl      = tt-title-fin.acc-other-rubl      + sum-acc-other-rubl                                      tt-title-fin.pay-base            = tt-title-fin.pay-base            + sum-price-base-with-tax-sale                                  tt-title-fin.pay-rubl            = tt-title-fin.pay-rubl            + sum-price-rubl-with-tax-sale                                  tt-title-fin.vat-base            = tt-title-fin.vat-base            + sum-vat-base-sale                                  tt-title-fin.vat-rubl            = tt-title-fin.vat-rubl            + sum-vat-rubl-sale                                  tt-title-fin.no-vat-base         = tt-title-fin.no-vat-base         + sum-price-base-with-tax-sale - sum-vat-base-sale                                  tt-title-fin.no-vat-rubl         = tt-title-fin.no-vat-rubl         + sum-price-rubl-with-tax-sale - sum-vat-rubl-sale                                  tt-title-fin.vat-base-buyer      = tt-title-fin.vat-base-buyer      + sum-vat-base-buyer                                  tt-title-fin.vat-rubl-buyer      = tt-title-fin.vat-rubl-buyer      + sum-vat-rubl-buyer                                  tt-title-fin.slt-base            = tt-title-fin.slt-base            + sum-slt-base-sale                                  tt-title-fin.slt-rubl            = tt-title-fin.slt-rubl            + sum-slt-rubl-sale                                  tt-title-fin.road-tax            = tt-title-fin.road-tax            + (if varr-b = "base" then sum-road-tax-base-sale else sum-road-tax-rubl-sale)                                  tt-title-fin.excise              = tt-title-fin.excise              + (if varr-b = "base" then sum-excise-base-sale   else sum-excise-rubl-sale)                                    tt-title-fin.sale-base           = tt-title-fin.sale-base           + sum-price-base-with-tax-sale-cur                                  tt-title-fin.sale-rubl           = tt-title-fin.sale-rubl           + sum-price-rubl-with-tax-sale-cur                                  tt-title-fin.sale-vat-base       = tt-title-fin.sale-vat-base       + sum-vat-base-sale-cur                                       tt-title-fin.sale-vat-rubl       = tt-title-fin.sale-vat-rubl       + sum-vat-rubl-sale-cur                                       tt-title-fin.sale-vat-buyer-base = tt-title-fin.sale-vat-buyer-base + sum-vat-base-buyer-cur                                      tt-title-fin.sale-vat-buyer-rubl = tt-title-fin.sale-vat-buyer-rubl + sum-vat-rubl-buyer-cur                                      tt-title-fin.sale-slt-base       = tt-title-fin.sale-slt-base       + sum-slt-base-sale-cur                                       tt-title-fin.sale-slt-rubl       = tt-title-fin.sale-slt-rubl       + sum-slt-rubl-sale-cur                                       tt-title-fin.sale-road-tax-base  = tt-title-fin.sale-road-tax-base  + sum-road-tax-base-sale-cur                                  tt-title-fin.sale-road-tax-rubl  = tt-title-fin.sale-road-tax-rubl  + sum-road-tax-rubl-sale-cur                                  tt-title-fin.sale-excise-base    = tt-title-fin.sale-excise-base    + sum-excise-base-sale-cur                                    tt-title-fin.sale-excise-rubl    = tt-title-fin.sale-excise-rubl    + sum-excise-rubl-sale-cur                                    tt-title-fin.ov-base             = tt-title-fin.ov-base             + (if varr-b = "base" then (sum-price-base-with-tax-sale-cur - sum-price-base-with-tax-sale) else (sum-price-rubl-with-tax-sale-cur - sum-price-rubl-with-tax-sale))                                  tt-title-fin.ov-vat              = tt-title-fin.ov-vat              + (if varr-b = "base" then (sum-price-base-with-tax-sale-cur - sum-price-base-with-tax-sale) else (sum-price-rubl-with-tax-sale-cur - sum-price-rubl-with-tax-sale)) * bf_doc-line.vat-pc / (100 + bf_doc-line.vat-pc).
      end.
            if lookup( "d-slt-vat", use-table ) > 0 then do:
        find first d-slt-vat where
                   d-slt-vat.vat-pc = bf_doc-line.vat-pc and
                   d-slt-vat.slt-pc = bf_doc-line.slt-pc no-error.
        if not available d-slt-vat then do:
          create d-slt-vat.
          assign d-slt-vat.vat-pc = bf_doc-line.vat-pc
                 d-slt-vat.slt-pc = bf_doc-line.slt-pc.
        end.
        assign d-slt-vat.fact-qnty           = d-slt-vat.fact-qnty           + varqnty                                   d-slt-vat.acc-base            = d-slt-vat.acc-base            + sum-acc-base                                            d-slt-vat.acc-rubl            = d-slt-vat.acc-rubl            + sum-acc-rubl                                            d-slt-vat.acc-vat-base        = d-slt-vat.acc-vat-base        + sum-acc-vat-base                                        d-slt-vat.acc-vat-rubl        = d-slt-vat.acc-vat-rubl        + sum-acc-vat-rubl                                        d-slt-vat.acc-slt-base        = d-slt-vat.acc-slt-base        + sum-acc-slt-base                                        d-slt-vat.acc-slt-rubl        = d-slt-vat.acc-slt-rubl        + sum-acc-slt-rubl                                        d-slt-vat.acc-road-tax-base   = d-slt-vat.acc-road-tax-base   + sum-acc-road-tax-base                                   d-slt-vat.acc-road-tax-rubl   = d-slt-vat.acc-road-tax-rubl   + sum-acc-road-tax-rubl                                   d-slt-vat.acc-excise-base     = d-slt-vat.acc-excise-base     + sum-acc-excise-base                                     d-slt-vat.acc-excise-rubl     = d-slt-vat.acc-excise-rubl     + sum-acc-excise-rubl                                     d-slt-vat.acc-transport-base  = d-slt-vat.acc-transport-base  + sum-acc-transport-base                                  d-slt-vat.acc-transport-rubl  = d-slt-vat.acc-transport-rubl  + sum-acc-transport-rubl                                  d-slt-vat.acc-other-base      = d-slt-vat.acc-other-base      + sum-acc-other-base                                      d-slt-vat.acc-other-rubl      = d-slt-vat.acc-other-rubl      + sum-acc-other-rubl                                      d-slt-vat.pay-base            = d-slt-vat.pay-base            + sum-price-base-with-tax-sale                                  d-slt-vat.pay-rubl            = d-slt-vat.pay-rubl            + sum-price-rubl-with-tax-sale                                  d-slt-vat.vat-base            = d-slt-vat.vat-base            + sum-vat-base-sale                                  d-slt-vat.vat-rubl            = d-slt-vat.vat-rubl            + sum-vat-rubl-sale                                  d-slt-vat.no-vat-base         = d-slt-vat.no-vat-base         + sum-price-base-with-tax-sale - sum-vat-base-sale                                  d-slt-vat.no-vat-rubl         = d-slt-vat.no-vat-rubl         + sum-price-rubl-with-tax-sale - sum-vat-rubl-sale                                  d-slt-vat.vat-base-buyer      = d-slt-vat.vat-base-buyer      + sum-vat-base-buyer                                  d-slt-vat.vat-rubl-buyer      = d-slt-vat.vat-rubl-buyer      + sum-vat-rubl-buyer                                  d-slt-vat.slt-base            = d-slt-vat.slt-base            + sum-slt-base-sale                                  d-slt-vat.slt-rubl            = d-slt-vat.slt-rubl            + sum-slt-rubl-sale                                  d-slt-vat.road-tax            = d-slt-vat.road-tax            + (if varr-b = "base" then sum-road-tax-base-sale else sum-road-tax-rubl-sale)                                  d-slt-vat.excise              = d-slt-vat.excise              + (if varr-b = "base" then sum-excise-base-sale   else sum-excise-rubl-sale)                                    d-slt-vat.sale-base           = d-slt-vat.sale-base           + sum-price-base-with-tax-sale-cur                                  d-slt-vat.sale-rubl           = d-slt-vat.sale-rubl           + sum-price-rubl-with-tax-sale-cur                                  d-slt-vat.sale-vat-base       = d-slt-vat.sale-vat-base       + sum-vat-base-sale-cur                                       d-slt-vat.sale-vat-rubl       = d-slt-vat.sale-vat-rubl       + sum-vat-rubl-sale-cur                                       d-slt-vat.sale-vat-buyer-base = d-slt-vat.sale-vat-buyer-base + sum-vat-base-buyer-cur                                      d-slt-vat.sale-vat-buyer-rubl = d-slt-vat.sale-vat-buyer-rubl + sum-vat-rubl-buyer-cur                                      d-slt-vat.sale-slt-base       = d-slt-vat.sale-slt-base       + sum-slt-base-sale-cur                                       d-slt-vat.sale-slt-rubl       = d-slt-vat.sale-slt-rubl       + sum-slt-rubl-sale-cur                                       d-slt-vat.sale-road-tax-base  = d-slt-vat.sale-road-tax-base  + sum-road-tax-base-sale-cur                                  d-slt-vat.sale-road-tax-rubl  = d-slt-vat.sale-road-tax-rubl  + sum-road-tax-rubl-sale-cur                                  d-slt-vat.sale-excise-base    = d-slt-vat.sale-excise-base    + sum-excise-base-sale-cur                                    d-slt-vat.sale-excise-rubl    = d-slt-vat.sale-excise-rubl    + sum-excise-rubl-sale-cur                                    d-slt-vat.ov-base             = d-slt-vat.ov-base             + (if varr-b = "base" then (sum-price-base-with-tax-sale-cur - sum-price-base-with-tax-sale) else (sum-price-rubl-with-tax-sale-cur - sum-price-rubl-with-tax-sale))                                  d-slt-vat.ov-vat              = d-slt-vat.ov-vat              + (if varr-b = "base" then (sum-price-base-with-tax-sale-cur - sum-price-base-with-tax-sale) else (sum-price-rubl-with-tax-sale-cur - sum-price-rubl-with-tax-sale)) * bf_doc-line.vat-pc / (100 + bf_doc-line.vat-pc).
      end.
            if lookup( "d-slt-vat-cons", use-table ) > 0 then do:
        find first d-slt-vat-cons where
                   d-slt-vat-cons.vat-pc     = bf_doc-line.vat-pc    and
                   d-slt-vat-cons.slt-pc     = bf_doc-line.slt-pc    and
                   d-slt-vat-cons.purch-code = 1 no-error.
        if not available d-slt-vat-cons then do:
          create d-slt-vat-cons.
          assign d-slt-vat-cons.vat-pc     = bf_doc-line.vat-pc
                 d-slt-vat-cons.slt-pc     = bf_doc-line.slt-pc
                 d-slt-vat-cons.purch-code = 1
                 d-slt-vat-cons.purch-name = 'выкуп':U.
        end.
        assign d-slt-vat-cons.fact-qnty           = d-slt-vat-cons.fact-qnty           + varqnty                                   d-slt-vat-cons.acc-base            = d-slt-vat-cons.acc-base            + sum-acc-base                                            d-slt-vat-cons.acc-rubl            = d-slt-vat-cons.acc-rubl            + sum-acc-rubl                                            d-slt-vat-cons.acc-vat-base        = d-slt-vat-cons.acc-vat-base        + sum-acc-vat-base                                        d-slt-vat-cons.acc-vat-rubl        = d-slt-vat-cons.acc-vat-rubl        + sum-acc-vat-rubl                                        d-slt-vat-cons.acc-slt-base        = d-slt-vat-cons.acc-slt-base        + sum-acc-slt-base                                        d-slt-vat-cons.acc-slt-rubl        = d-slt-vat-cons.acc-slt-rubl        + sum-acc-slt-rubl                                        d-slt-vat-cons.acc-road-tax-base   = d-slt-vat-cons.acc-road-tax-base   + sum-acc-road-tax-base                                   d-slt-vat-cons.acc-road-tax-rubl   = d-slt-vat-cons.acc-road-tax-rubl   + sum-acc-road-tax-rubl                                   d-slt-vat-cons.acc-excise-base     = d-slt-vat-cons.acc-excise-base     + sum-acc-excise-base                                     d-slt-vat-cons.acc-excise-rubl     = d-slt-vat-cons.acc-excise-rubl     + sum-acc-excise-rubl                                     d-slt-vat-cons.acc-transport-base  = d-slt-vat-cons.acc-transport-base  + sum-acc-transport-base                                  d-slt-vat-cons.acc-transport-rubl  = d-slt-vat-cons.acc-transport-rubl  + sum-acc-transport-rubl                                  d-slt-vat-cons.acc-other-base      = d-slt-vat-cons.acc-other-base      + sum-acc-other-base                                      d-slt-vat-cons.acc-other-rubl      = d-slt-vat-cons.acc-other-rubl      + sum-acc-other-rubl                                      d-slt-vat-cons.pay-base            = d-slt-vat-cons.pay-base            + sum-price-base-with-tax-sale                                  d-slt-vat-cons.pay-rubl            = d-slt-vat-cons.pay-rubl            + sum-price-rubl-with-tax-sale                                  d-slt-vat-cons.vat-base            = d-slt-vat-cons.vat-base            + sum-vat-base-sale                                  d-slt-vat-cons.vat-rubl            = d-slt-vat-cons.vat-rubl            + sum-vat-rubl-sale                                  d-slt-vat-cons.no-vat-base         = d-slt-vat-cons.no-vat-base         + sum-price-base-with-tax-sale - sum-vat-base-sale                                  d-slt-vat-cons.no-vat-rubl         = d-slt-vat-cons.no-vat-rubl         + sum-price-rubl-with-tax-sale - sum-vat-rubl-sale                                  d-slt-vat-cons.vat-base-buyer      = d-slt-vat-cons.vat-base-buyer      + sum-vat-base-buyer                                  d-slt-vat-cons.vat-rubl-buyer      = d-slt-vat-cons.vat-rubl-buyer      + sum-vat-rubl-buyer                                  d-slt-vat-cons.slt-base            = d-slt-vat-cons.slt-base            + sum-slt-base-sale                                  d-slt-vat-cons.slt-rubl            = d-slt-vat-cons.slt-rubl            + sum-slt-rubl-sale                                  d-slt-vat-cons.road-tax            = d-slt-vat-cons.road-tax            + (if varr-b = "base" then sum-road-tax-base-sale else sum-road-tax-rubl-sale)                                  d-slt-vat-cons.excise              = d-slt-vat-cons.excise              + (if varr-b = "base" then sum-excise-base-sale   else sum-excise-rubl-sale)                                    d-slt-vat-cons.sale-base           = d-slt-vat-cons.sale-base           + sum-price-base-with-tax-sale-cur                                  d-slt-vat-cons.sale-rubl           = d-slt-vat-cons.sale-rubl           + sum-price-rubl-with-tax-sale-cur                                  d-slt-vat-cons.sale-vat-base       = d-slt-vat-cons.sale-vat-base       + sum-vat-base-sale-cur                                       d-slt-vat-cons.sale-vat-rubl       = d-slt-vat-cons.sale-vat-rubl       + sum-vat-rubl-sale-cur                                       d-slt-vat-cons.sale-vat-buyer-base = d-slt-vat-cons.sale-vat-buyer-base + sum-vat-base-buyer-cur                                      d-slt-vat-cons.sale-vat-buyer-rubl = d-slt-vat-cons.sale-vat-buyer-rubl + sum-vat-rubl-buyer-cur                                      d-slt-vat-cons.sale-slt-base       = d-slt-vat-cons.sale-slt-base       + sum-slt-base-sale-cur                                       d-slt-vat-cons.sale-slt-rubl       = d-slt-vat-cons.sale-slt-rubl       + sum-slt-rubl-sale-cur                                       d-slt-vat-cons.sale-road-tax-base  = d-slt-vat-cons.sale-road-tax-base  + sum-road-tax-base-sale-cur                                  d-slt-vat-cons.sale-road-tax-rubl  = d-slt-vat-cons.sale-road-tax-rubl  + sum-road-tax-rubl-sale-cur                                  d-slt-vat-cons.sale-excise-base    = d-slt-vat-cons.sale-excise-base    + sum-excise-base-sale-cur                                    d-slt-vat-cons.sale-excise-rubl    = d-slt-vat-cons.sale-excise-rubl    + sum-excise-rubl-sale-cur                                    d-slt-vat-cons.ov-base             = d-slt-vat-cons.ov-base             + (if varr-b = "base" then (sum-price-base-with-tax-sale-cur - sum-price-base-with-tax-sale) else (sum-price-rubl-with-tax-sale-cur - sum-price-rubl-with-tax-sale))                                  d-slt-vat-cons.ov-vat              = d-slt-vat-cons.ov-vat              + (if varr-b = "base" then (sum-price-base-with-tax-sale-cur - sum-price-base-with-tax-sale) else (sum-price-rubl-with-tax-sale-cur - sum-price-rubl-with-tax-sale)) * bf_doc-line.vat-pc / (100 + bf_doc-line.vat-pc).
      end.
            if lookup( "d-slt-vat-cons-fin", use-table ) > 0 then do:
        find first d-slt-vat-cons-fin where
                   d-slt-vat-cons-fin.vat-pc        = bf_doc-line.vat-pc    and
                   d-slt-vat-cons-fin.slt-pc        = bf_doc-line.slt-pc    and
                   d-slt-vat-cons-fin.contract-code = 0                     and
                   d-slt-vat-cons-fin.purch-code    = 1 no-error.
        if not available d-slt-vat-cons-fin then do:
          create d-slt-vat-cons-fin.
          assign d-slt-vat-cons-fin.vat-pc        = bf_doc-line.vat-pc
                 d-slt-vat-cons-fin.slt-pc        = bf_doc-line.slt-pc
                 d-slt-vat-cons-fin.contract-code = 0
                 d-slt-vat-cons-fin.purch-code    = 1
                 d-slt-vat-cons-fin.purch-name    = 'выкуп':U.
        end.
        assign d-slt-vat-cons-fin.fact-qnty           = d-slt-vat-cons-fin.fact-qnty           + varqnty                                   d-slt-vat-cons-fin.acc-base            = d-slt-vat-cons-fin.acc-base            + sum-acc-base                                            d-slt-vat-cons-fin.acc-rubl            = d-slt-vat-cons-fin.acc-rubl            + sum-acc-rubl                                            d-slt-vat-cons-fin.acc-vat-base        = d-slt-vat-cons-fin.acc-vat-base        + sum-acc-vat-base                                        d-slt-vat-cons-fin.acc-vat-rubl        = d-slt-vat-cons-fin.acc-vat-rubl        + sum-acc-vat-rubl                                        d-slt-vat-cons-fin.acc-slt-base        = d-slt-vat-cons-fin.acc-slt-base        + sum-acc-slt-base                                        d-slt-vat-cons-fin.acc-slt-rubl        = d-slt-vat-cons-fin.acc-slt-rubl        + sum-acc-slt-rubl                                        d-slt-vat-cons-fin.acc-road-tax-base   = d-slt-vat-cons-fin.acc-road-tax-base   + sum-acc-road-tax-base                                   d-slt-vat-cons-fin.acc-road-tax-rubl   = d-slt-vat-cons-fin.acc-road-tax-rubl   + sum-acc-road-tax-rubl                                   d-slt-vat-cons-fin.acc-excise-base     = d-slt-vat-cons-fin.acc-excise-base     + sum-acc-excise-base                                     d-slt-vat-cons-fin.acc-excise-rubl     = d-slt-vat-cons-fin.acc-excise-rubl     + sum-acc-excise-rubl                                     d-slt-vat-cons-fin.acc-transport-base  = d-slt-vat-cons-fin.acc-transport-base  + sum-acc-transport-base                                  d-slt-vat-cons-fin.acc-transport-rubl  = d-slt-vat-cons-fin.acc-transport-rubl  + sum-acc-transport-rubl                                  d-slt-vat-cons-fin.acc-other-base      = d-slt-vat-cons-fin.acc-other-base      + sum-acc-other-base                                      d-slt-vat-cons-fin.acc-other-rubl      = d-slt-vat-cons-fin.acc-other-rubl      + sum-acc-other-rubl                                      d-slt-vat-cons-fin.pay-base            = d-slt-vat-cons-fin.pay-base            + sum-price-base-with-tax-sale                                  d-slt-vat-cons-fin.pay-rubl            = d-slt-vat-cons-fin.pay-rubl            + sum-price-rubl-with-tax-sale                                  d-slt-vat-cons-fin.vat-base            = d-slt-vat-cons-fin.vat-base            + sum-vat-base-sale                                  d-slt-vat-cons-fin.vat-rubl            = d-slt-vat-cons-fin.vat-rubl            + sum-vat-rubl-sale                                  d-slt-vat-cons-fin.no-vat-base         = d-slt-vat-cons-fin.no-vat-base         + sum-price-base-with-tax-sale - sum-vat-base-sale                                  d-slt-vat-cons-fin.no-vat-rubl         = d-slt-vat-cons-fin.no-vat-rubl         + sum-price-rubl-with-tax-sale - sum-vat-rubl-sale                                  d-slt-vat-cons-fin.vat-base-buyer      = d-slt-vat-cons-fin.vat-base-buyer      + sum-vat-base-buyer                                  d-slt-vat-cons-fin.vat-rubl-buyer      = d-slt-vat-cons-fin.vat-rubl-buyer      + sum-vat-rubl-buyer                                  d-slt-vat-cons-fin.slt-base            = d-slt-vat-cons-fin.slt-base            + sum-slt-base-sale                                  d-slt-vat-cons-fin.slt-rubl            = d-slt-vat-cons-fin.slt-rubl            + sum-slt-rubl-sale                                  d-slt-vat-cons-fin.road-tax            = d-slt-vat-cons-fin.road-tax            + (if varr-b = "base" then sum-road-tax-base-sale else sum-road-tax-rubl-sale)                                  d-slt-vat-cons-fin.excise              = d-slt-vat-cons-fin.excise              + (if varr-b = "base" then sum-excise-base-sale   else sum-excise-rubl-sale)                                    d-slt-vat-cons-fin.sale-base           = d-slt-vat-cons-fin.sale-base           + sum-price-base-with-tax-sale-cur                                  d-slt-vat-cons-fin.sale-rubl           = d-slt-vat-cons-fin.sale-rubl           + sum-price-rubl-with-tax-sale-cur                                  d-slt-vat-cons-fin.sale-vat-base       = d-slt-vat-cons-fin.sale-vat-base       + sum-vat-base-sale-cur                                       d-slt-vat-cons-fin.sale-vat-rubl       = d-slt-vat-cons-fin.sale-vat-rubl       + sum-vat-rubl-sale-cur                                       d-slt-vat-cons-fin.sale-vat-buyer-base = d-slt-vat-cons-fin.sale-vat-buyer-base + sum-vat-base-buyer-cur                                      d-slt-vat-cons-fin.sale-vat-buyer-rubl = d-slt-vat-cons-fin.sale-vat-buyer-rubl + sum-vat-rubl-buyer-cur                                      d-slt-vat-cons-fin.sale-slt-base       = d-slt-vat-cons-fin.sale-slt-base       + sum-slt-base-sale-cur                                       d-slt-vat-cons-fin.sale-slt-rubl       = d-slt-vat-cons-fin.sale-slt-rubl       + sum-slt-rubl-sale-cur                                       d-slt-vat-cons-fin.sale-road-tax-base  = d-slt-vat-cons-fin.sale-road-tax-base  + sum-road-tax-base-sale-cur                                  d-slt-vat-cons-fin.sale-road-tax-rubl  = d-slt-vat-cons-fin.sale-road-tax-rubl  + sum-road-tax-rubl-sale-cur                                  d-slt-vat-cons-fin.sale-excise-base    = d-slt-vat-cons-fin.sale-excise-base    + sum-excise-base-sale-cur                                    d-slt-vat-cons-fin.sale-excise-rubl    = d-slt-vat-cons-fin.sale-excise-rubl    + sum-excise-rubl-sale-cur                                    d-slt-vat-cons-fin.ov-base             = d-slt-vat-cons-fin.ov-base             + (if varr-b = "base" then (sum-price-base-with-tax-sale-cur - sum-price-base-with-tax-sale) else (sum-price-rubl-with-tax-sale-cur - sum-price-rubl-with-tax-sale))                                  d-slt-vat-cons-fin.ov-vat              = d-slt-vat-cons-fin.ov-vat              + (if varr-b = "base" then (sum-price-base-with-tax-sale-cur - sum-price-base-with-tax-sale) else (sum-price-rubl-with-tax-sale-cur - sum-price-rubl-with-tax-sale)) * bf_doc-line.vat-pc / (100 + bf_doc-line.vat-pc).
      end.
            if lookup( "d-slt-vat-cons-grp", use-table ) > 0 then do:
        find first d-slt-vat-cons-grp where
                   d-slt-vat-cons-grp.vat-pc     = bf_doc-line.vat-pc    and
                   d-slt-vat-cons-grp.slt-pc     = bf_doc-line.slt-pc    and
                   d-slt-vat-cons-grp.purch-code = 1 and
                   d-slt-vat-cons-grp.grp-code   = bf_goods.grp-code     no-error.
        if not available d-slt-vat-cons-grp then do:
          create d-slt-vat-cons-grp.
          assign d-slt-vat-cons-grp.vat-pc     = bf_doc-line.vat-pc
                 d-slt-vat-cons-grp.slt-pc     = bf_doc-line.slt-pc
                 d-slt-vat-cons-grp.purch-code = 1
                 d-slt-vat-cons-grp.purch-name = 'выкуп':U
                 d-slt-vat-cons-grp.grp-code   = bf_goods.grp-code
                 d-slt-vat-cons-grp.grp-name   = varfull-name-grp.
        end.
        assign d-slt-vat-cons-grp.fact-qnty           = d-slt-vat-cons-grp.fact-qnty           + varqnty                                   d-slt-vat-cons-grp.acc-base            = d-slt-vat-cons-grp.acc-base            + sum-acc-base                                            d-slt-vat-cons-grp.acc-rubl            = d-slt-vat-cons-grp.acc-rubl            + sum-acc-rubl                                            d-slt-vat-cons-grp.acc-vat-base        = d-slt-vat-cons-grp.acc-vat-base        + sum-acc-vat-base                                        d-slt-vat-cons-grp.acc-vat-rubl        = d-slt-vat-cons-grp.acc-vat-rubl        + sum-acc-vat-rubl                                        d-slt-vat-cons-grp.acc-slt-base        = d-slt-vat-cons-grp.acc-slt-base        + sum-acc-slt-base                                        d-slt-vat-cons-grp.acc-slt-rubl        = d-slt-vat-cons-grp.acc-slt-rubl        + sum-acc-slt-rubl                                        d-slt-vat-cons-grp.acc-road-tax-base   = d-slt-vat-cons-grp.acc-road-tax-base   + sum-acc-road-tax-base                                   d-slt-vat-cons-grp.acc-road-tax-rubl   = d-slt-vat-cons-grp.acc-road-tax-rubl   + sum-acc-road-tax-rubl                                   d-slt-vat-cons-grp.acc-excise-base     = d-slt-vat-cons-grp.acc-excise-base     + sum-acc-excise-base                                     d-slt-vat-cons-grp.acc-excise-rubl     = d-slt-vat-cons-grp.acc-excise-rubl     + sum-acc-excise-rubl                                     d-slt-vat-cons-grp.acc-transport-base  = d-slt-vat-cons-grp.acc-transport-base  + sum-acc-transport-base                                  d-slt-vat-cons-grp.acc-transport-rubl  = d-slt-vat-cons-grp.acc-transport-rubl  + sum-acc-transport-rubl                                  d-slt-vat-cons-grp.acc-other-base      = d-slt-vat-cons-grp.acc-other-base      + sum-acc-other-base                                      d-slt-vat-cons-grp.acc-other-rubl      = d-slt-vat-cons-grp.acc-other-rubl      + sum-acc-other-rubl                                      d-slt-vat-cons-grp.pay-base            = d-slt-vat-cons-grp.pay-base            + sum-price-base-with-tax-sale                                  d-slt-vat-cons-grp.pay-rubl            = d-slt-vat-cons-grp.pay-rubl            + sum-price-rubl-with-tax-sale                                  d-slt-vat-cons-grp.vat-base            = d-slt-vat-cons-grp.vat-base            + sum-vat-base-sale                                  d-slt-vat-cons-grp.vat-rubl            = d-slt-vat-cons-grp.vat-rubl            + sum-vat-rubl-sale                                  d-slt-vat-cons-grp.no-vat-base         = d-slt-vat-cons-grp.no-vat-base         + sum-price-base-with-tax-sale - sum-vat-base-sale                                  d-slt-vat-cons-grp.no-vat-rubl         = d-slt-vat-cons-grp.no-vat-rubl         + sum-price-rubl-with-tax-sale - sum-vat-rubl-sale                                  d-slt-vat-cons-grp.vat-base-buyer      = d-slt-vat-cons-grp.vat-base-buyer      + sum-vat-base-buyer                                  d-slt-vat-cons-grp.vat-rubl-buyer      = d-slt-vat-cons-grp.vat-rubl-buyer      + sum-vat-rubl-buyer                                  d-slt-vat-cons-grp.slt-base            = d-slt-vat-cons-grp.slt-base            + sum-slt-base-sale                                  d-slt-vat-cons-grp.slt-rubl            = d-slt-vat-cons-grp.slt-rubl            + sum-slt-rubl-sale                                  d-slt-vat-cons-grp.road-tax            = d-slt-vat-cons-grp.road-tax            + (if varr-b = "base" then sum-road-tax-base-sale else sum-road-tax-rubl-sale)                                  d-slt-vat-cons-grp.excise              = d-slt-vat-cons-grp.excise              + (if varr-b = "base" then sum-excise-base-sale   else sum-excise-rubl-sale)                                    d-slt-vat-cons-grp.sale-base           = d-slt-vat-cons-grp.sale-base           + sum-price-base-with-tax-sale-cur                                  d-slt-vat-cons-grp.sale-rubl           = d-slt-vat-cons-grp.sale-rubl           + sum-price-rubl-with-tax-sale-cur                                  d-slt-vat-cons-grp.sale-vat-base       = d-slt-vat-cons-grp.sale-vat-base       + sum-vat-base-sale-cur                                       d-slt-vat-cons-grp.sale-vat-rubl       = d-slt-vat-cons-grp.sale-vat-rubl       + sum-vat-rubl-sale-cur                                       d-slt-vat-cons-grp.sale-vat-buyer-base = d-slt-vat-cons-grp.sale-vat-buyer-base + sum-vat-base-buyer-cur                                      d-slt-vat-cons-grp.sale-vat-buyer-rubl = d-slt-vat-cons-grp.sale-vat-buyer-rubl + sum-vat-rubl-buyer-cur                                      d-slt-vat-cons-grp.sale-slt-base       = d-slt-vat-cons-grp.sale-slt-base       + sum-slt-base-sale-cur                                       d-slt-vat-cons-grp.sale-slt-rubl       = d-slt-vat-cons-grp.sale-slt-rubl       + sum-slt-rubl-sale-cur                                       d-slt-vat-cons-grp.sale-road-tax-base  = d-slt-vat-cons-grp.sale-road-tax-base  + sum-road-tax-base-sale-cur                                  d-slt-vat-cons-grp.sale-road-tax-rubl  = d-slt-vat-cons-grp.sale-road-tax-rubl  + sum-road-tax-rubl-sale-cur                                  d-slt-vat-cons-grp.sale-excise-base    = d-slt-vat-cons-grp.sale-excise-base    + sum-excise-base-sale-cur                                    d-slt-vat-cons-grp.sale-excise-rubl    = d-slt-vat-cons-grp.sale-excise-rubl    + sum-excise-rubl-sale-cur                                    d-slt-vat-cons-grp.ov-base             = d-slt-vat-cons-grp.ov-base             + (if varr-b = "base" then (sum-price-base-with-tax-sale-cur - sum-price-base-with-tax-sale) else (sum-price-rubl-with-tax-sale-cur - sum-price-rubl-with-tax-sale))                                  d-slt-vat-cons-grp.ov-vat              = d-slt-vat-cons-grp.ov-vat              + (if varr-b = "base" then (sum-price-base-with-tax-sale-cur - sum-price-base-with-tax-sale) else (sum-price-rubl-with-tax-sale-cur - sum-price-rubl-with-tax-sale)) * bf_doc-line.vat-pc / (100 + bf_doc-line.vat-pc).
      end.
            if lookup( "d-slt-vat-cons-grp-fin", use-table ) > 0 then do:
        find first d-slt-vat-cons-grp-fin where
                   d-slt-vat-cons-grp-fin.vat-pc        = bf_doc-line.vat-pc    and
                   d-slt-vat-cons-grp-fin.slt-pc        = bf_doc-line.slt-pc    and
                   d-slt-vat-cons-grp-fin.contract-code = 0                     and
                   d-slt-vat-cons-grp-fin.purch-code    = 1 and
                   d-slt-vat-cons-grp-fin.grp-code      = bf_goods.grp-code     no-error.
        if not available d-slt-vat-cons-grp-fin then do:
          create d-slt-vat-cons-grp-fin.
          assign d-slt-vat-cons-grp-fin.vat-pc        = bf_doc-line.vat-pc
                 d-slt-vat-cons-grp-fin.slt-pc        = bf_doc-line.slt-pc
                 d-slt-vat-cons-grp-fin.contract-code = 0
                 d-slt-vat-cons-grp-fin.purch-code    = 1
                 d-slt-vat-cons-grp-fin.purch-name    = 'выкуп':U
                 d-slt-vat-cons-grp-fin.grp-code      = bf_goods.grp-code
                 d-slt-vat-cons-grp-fin.grp-name      = varfull-name-grp.
        end.
        assign d-slt-vat-cons-grp-fin.fact-qnty           = d-slt-vat-cons-grp-fin.fact-qnty           + varqnty                                   d-slt-vat-cons-grp-fin.acc-base            = d-slt-vat-cons-grp-fin.acc-base            + sum-acc-base                                            d-slt-vat-cons-grp-fin.acc-rubl            = d-slt-vat-cons-grp-fin.acc-rubl            + sum-acc-rubl                                            d-slt-vat-cons-grp-fin.acc-vat-base        = d-slt-vat-cons-grp-fin.acc-vat-base        + sum-acc-vat-base                                        d-slt-vat-cons-grp-fin.acc-vat-rubl        = d-slt-vat-cons-grp-fin.acc-vat-rubl        + sum-acc-vat-rubl                                        d-slt-vat-cons-grp-fin.acc-slt-base        = d-slt-vat-cons-grp-fin.acc-slt-base        + sum-acc-slt-base                                        d-slt-vat-cons-grp-fin.acc-slt-rubl        = d-slt-vat-cons-grp-fin.acc-slt-rubl        + sum-acc-slt-rubl                                        d-slt-vat-cons-grp-fin.acc-road-tax-base   = d-slt-vat-cons-grp-fin.acc-road-tax-base   + sum-acc-road-tax-base                                   d-slt-vat-cons-grp-fin.acc-road-tax-rubl   = d-slt-vat-cons-grp-fin.acc-road-tax-rubl   + sum-acc-road-tax-rubl                                   d-slt-vat-cons-grp-fin.acc-excise-base     = d-slt-vat-cons-grp-fin.acc-excise-base     + sum-acc-excise-base                                     d-slt-vat-cons-grp-fin.acc-excise-rubl     = d-slt-vat-cons-grp-fin.acc-excise-rubl     + sum-acc-excise-rubl                                     d-slt-vat-cons-grp-fin.acc-transport-base  = d-slt-vat-cons-grp-fin.acc-transport-base  + sum-acc-transport-base                                  d-slt-vat-cons-grp-fin.acc-transport-rubl  = d-slt-vat-cons-grp-fin.acc-transport-rubl  + sum-acc-transport-rubl                                  d-slt-vat-cons-grp-fin.acc-other-base      = d-slt-vat-cons-grp-fin.acc-other-base      + sum-acc-other-base                                      d-slt-vat-cons-grp-fin.acc-other-rubl      = d-slt-vat-cons-grp-fin.acc-other-rubl      + sum-acc-other-rubl                                      d-slt-vat-cons-grp-fin.pay-base            = d-slt-vat-cons-grp-fin.pay-base            + sum-price-base-with-tax-sale                                  d-slt-vat-cons-grp-fin.pay-rubl            = d-slt-vat-cons-grp-fin.pay-rubl            + sum-price-rubl-with-tax-sale                                  d-slt-vat-cons-grp-fin.vat-base            = d-slt-vat-cons-grp-fin.vat-base            + sum-vat-base-sale                                  d-slt-vat-cons-grp-fin.vat-rubl            = d-slt-vat-cons-grp-fin.vat-rubl            + sum-vat-rubl-sale                                  d-slt-vat-cons-grp-fin.no-vat-base         = d-slt-vat-cons-grp-fin.no-vat-base         + sum-price-base-with-tax-sale - sum-vat-base-sale                                  d-slt-vat-cons-grp-fin.no-vat-rubl         = d-slt-vat-cons-grp-fin.no-vat-rubl         + sum-price-rubl-with-tax-sale - sum-vat-rubl-sale                                  d-slt-vat-cons-grp-fin.vat-base-buyer      = d-slt-vat-cons-grp-fin.vat-base-buyer      + sum-vat-base-buyer                                  d-slt-vat-cons-grp-fin.vat-rubl-buyer      = d-slt-vat-cons-grp-fin.vat-rubl-buyer      + sum-vat-rubl-buyer                                  d-slt-vat-cons-grp-fin.slt-base            = d-slt-vat-cons-grp-fin.slt-base            + sum-slt-base-sale                                  d-slt-vat-cons-grp-fin.slt-rubl            = d-slt-vat-cons-grp-fin.slt-rubl            + sum-slt-rubl-sale                                  d-slt-vat-cons-grp-fin.road-tax            = d-slt-vat-cons-grp-fin.road-tax            + (if varr-b = "base" then sum-road-tax-base-sale else sum-road-tax-rubl-sale)                                  d-slt-vat-cons-grp-fin.excise              = d-slt-vat-cons-grp-fin.excise              + (if varr-b = "base" then sum-excise-base-sale   else sum-excise-rubl-sale)                                    d-slt-vat-cons-grp-fin.sale-base           = d-slt-vat-cons-grp-fin.sale-base           + sum-price-base-with-tax-sale-cur                                  d-slt-vat-cons-grp-fin.sale-rubl           = d-slt-vat-cons-grp-fin.sale-rubl           + sum-price-rubl-with-tax-sale-cur                                  d-slt-vat-cons-grp-fin.sale-vat-base       = d-slt-vat-cons-grp-fin.sale-vat-base       + sum-vat-base-sale-cur                                       d-slt-vat-cons-grp-fin.sale-vat-rubl       = d-slt-vat-cons-grp-fin.sale-vat-rubl       + sum-vat-rubl-sale-cur                                       d-slt-vat-cons-grp-fin.sale-vat-buyer-base = d-slt-vat-cons-grp-fin.sale-vat-buyer-base + sum-vat-base-buyer-cur                                      d-slt-vat-cons-grp-fin.sale-vat-buyer-rubl = d-slt-vat-cons-grp-fin.sale-vat-buyer-rubl + sum-vat-rubl-buyer-cur                                      d-slt-vat-cons-grp-fin.sale-slt-base       = d-slt-vat-cons-grp-fin.sale-slt-base       + sum-slt-base-sale-cur                                       d-slt-vat-cons-grp-fin.sale-slt-rubl       = d-slt-vat-cons-grp-fin.sale-slt-rubl       + sum-slt-rubl-sale-cur                                       d-slt-vat-cons-grp-fin.sale-road-tax-base  = d-slt-vat-cons-grp-fin.sale-road-tax-base  + sum-road-tax-base-sale-cur                                  d-slt-vat-cons-grp-fin.sale-road-tax-rubl  = d-slt-vat-cons-grp-fin.sale-road-tax-rubl  + sum-road-tax-rubl-sale-cur                                  d-slt-vat-cons-grp-fin.sale-excise-base    = d-slt-vat-cons-grp-fin.sale-excise-base    + sum-excise-base-sale-cur                                    d-slt-vat-cons-grp-fin.sale-excise-rubl    = d-slt-vat-cons-grp-fin.sale-excise-rubl    + sum-excise-rubl-sale-cur                                    d-slt-vat-cons-grp-fin.ov-base             = d-slt-vat-cons-grp-fin.ov-base             + (if varr-b = "base" then (sum-price-base-with-tax-sale-cur - sum-price-base-with-tax-sale) else (sum-price-rubl-with-tax-sale-cur - sum-price-rubl-with-tax-sale))                                  d-slt-vat-cons-grp-fin.ov-vat              = d-slt-vat-cons-grp-fin.ov-vat              + (if varr-b = "base" then (sum-price-base-with-tax-sale-cur - sum-price-base-with-tax-sale) else (sum-price-rubl-with-tax-sale-cur - sum-price-rubl-with-tax-sale)) * bf_doc-line.vat-pc / (100 + bf_doc-line.vat-pc).
      end.
            if lookup( "d-slts-vats", use-table ) > 0 then do:
        find first d-slts-vats where
                   d-slts-vats.vat-pc = ? and
                   d-slts-vats.slt-pc = ? no-error.
        if not available d-slts-vats then do:
          create d-slts-vats.
          assign d-slts-vats.vat-pc = ?
                 d-slts-vats.slt-pc = ?.
        end.
        assign d-slts-vats.fact-qnty           = d-slts-vats.fact-qnty           + varqnty                                   d-slts-vats.acc-base            = d-slts-vats.acc-base            + sum-acc-base                                            d-slts-vats.acc-rubl            = d-slts-vats.acc-rubl            + sum-acc-rubl                                            d-slts-vats.acc-vat-base        = d-slts-vats.acc-vat-base        + sum-acc-vat-base                                        d-slts-vats.acc-vat-rubl        = d-slts-vats.acc-vat-rubl        + sum-acc-vat-rubl                                        d-slts-vats.acc-slt-base        = d-slts-vats.acc-slt-base        + sum-acc-slt-base                                        d-slts-vats.acc-slt-rubl        = d-slts-vats.acc-slt-rubl        + sum-acc-slt-rubl                                        d-slts-vats.acc-road-tax-base   = d-slts-vats.acc-road-tax-base   + sum-acc-road-tax-base                                   d-slts-vats.acc-road-tax-rubl   = d-slts-vats.acc-road-tax-rubl   + sum-acc-road-tax-rubl                                   d-slts-vats.acc-excise-base     = d-slts-vats.acc-excise-base     + sum-acc-excise-base                                     d-slts-vats.acc-excise-rubl     = d-slts-vats.acc-excise-rubl     + sum-acc-excise-rubl                                     d-slts-vats.acc-transport-base  = d-slts-vats.acc-transport-base  + sum-acc-transport-base                                  d-slts-vats.acc-transport-rubl  = d-slts-vats.acc-transport-rubl  + sum-acc-transport-rubl                                  d-slts-vats.acc-other-base      = d-slts-vats.acc-other-base      + sum-acc-other-base                                      d-slts-vats.acc-other-rubl      = d-slts-vats.acc-other-rubl      + sum-acc-other-rubl                                      d-slts-vats.pay-base            = d-slts-vats.pay-base            + sum-price-base-with-tax-sale                                  d-slts-vats.pay-rubl            = d-slts-vats.pay-rubl            + sum-price-rubl-with-tax-sale                                  d-slts-vats.vat-base            = d-slts-vats.vat-base            + sum-vat-base-sale                                  d-slts-vats.vat-rubl            = d-slts-vats.vat-rubl            + sum-vat-rubl-sale                                  d-slts-vats.no-vat-base         = d-slts-vats.no-vat-base         + sum-price-base-with-tax-sale - sum-vat-base-sale                                  d-slts-vats.no-vat-rubl         = d-slts-vats.no-vat-rubl         + sum-price-rubl-with-tax-sale - sum-vat-rubl-sale                                  d-slts-vats.vat-base-buyer      = d-slts-vats.vat-base-buyer      + sum-vat-base-buyer                                  d-slts-vats.vat-rubl-buyer      = d-slts-vats.vat-rubl-buyer      + sum-vat-rubl-buyer                                  d-slts-vats.slt-base            = d-slts-vats.slt-base            + sum-slt-base-sale                                  d-slts-vats.slt-rubl            = d-slts-vats.slt-rubl            + sum-slt-rubl-sale                                  d-slts-vats.road-tax            = d-slts-vats.road-tax            + (if varr-b = "base" then sum-road-tax-base-sale else sum-road-tax-rubl-sale)                                  d-slts-vats.excise              = d-slts-vats.excise              + (if varr-b = "base" then sum-excise-base-sale   else sum-excise-rubl-sale)                                    d-slts-vats.sale-base           = d-slts-vats.sale-base           + sum-price-base-with-tax-sale-cur                                  d-slts-vats.sale-rubl           = d-slts-vats.sale-rubl           + sum-price-rubl-with-tax-sale-cur                                  d-slts-vats.sale-vat-base       = d-slts-vats.sale-vat-base       + sum-vat-base-sale-cur                                       d-slts-vats.sale-vat-rubl       = d-slts-vats.sale-vat-rubl       + sum-vat-rubl-sale-cur                                       d-slts-vats.sale-vat-buyer-base = d-slts-vats.sale-vat-buyer-base + sum-vat-base-buyer-cur                                      d-slts-vats.sale-vat-buyer-rubl = d-slts-vats.sale-vat-buyer-rubl + sum-vat-rubl-buyer-cur                                      d-slts-vats.sale-slt-base       = d-slts-vats.sale-slt-base       + sum-slt-base-sale-cur                                       d-slts-vats.sale-slt-rubl       = d-slts-vats.sale-slt-rubl       + sum-slt-rubl-sale-cur                                       d-slts-vats.sale-road-tax-base  = d-slts-vats.sale-road-tax-base  + sum-road-tax-base-sale-cur                                  d-slts-vats.sale-road-tax-rubl  = d-slts-vats.sale-road-tax-rubl  + sum-road-tax-rubl-sale-cur                                  d-slts-vats.sale-excise-base    = d-slts-vats.sale-excise-base    + sum-excise-base-sale-cur                                    d-slts-vats.sale-excise-rubl    = d-slts-vats.sale-excise-rubl    + sum-excise-rubl-sale-cur                                    d-slts-vats.ov-base             = d-slts-vats.ov-base             + (if varr-b = "base" then (sum-price-base-with-tax-sale-cur - sum-price-base-with-tax-sale) else (sum-price-rubl-with-tax-sale-cur - sum-price-rubl-with-tax-sale))                                  d-slts-vats.ov-vat              = d-slts-vats.ov-vat              + (if varr-b = "base" then (sum-price-base-with-tax-sale-cur - sum-price-base-with-tax-sale) else (sum-price-rubl-with-tax-sale-cur - sum-price-rubl-with-tax-sale)) * bf_doc-line.vat-pc / (100 + bf_doc-line.vat-pc).
      end.
            if lookup( "d-slts-vats-cons", use-table ) > 0 then do:
        find first d-slts-vats-cons where
                   d-slts-vats-cons.vat-pc     = ?                     and
                   d-slts-vats-cons.slt-pc     = ?                     and
                   d-slts-vats-cons.purch-code = 1 no-error.
        if not available d-slts-vats-cons then do:
          create d-slts-vats-cons.
          assign d-slts-vats-cons.vat-pc     = ?
                 d-slts-vats-cons.slt-pc     = ?
                 d-slts-vats-cons.purch-code = 1
                 d-slts-vats-cons.purch-name = 'выкуп':U.
        end.
        assign d-slts-vats-cons.fact-qnty           = d-slts-vats-cons.fact-qnty           + varqnty                                   d-slts-vats-cons.acc-base            = d-slts-vats-cons.acc-base            + sum-acc-base                                            d-slts-vats-cons.acc-rubl            = d-slts-vats-cons.acc-rubl            + sum-acc-rubl                                            d-slts-vats-cons.acc-vat-base        = d-slts-vats-cons.acc-vat-base        + sum-acc-vat-base                                        d-slts-vats-cons.acc-vat-rubl        = d-slts-vats-cons.acc-vat-rubl        + sum-acc-vat-rubl                                        d-slts-vats-cons.acc-slt-base        = d-slts-vats-cons.acc-slt-base        + sum-acc-slt-base                                        d-slts-vats-cons.acc-slt-rubl        = d-slts-vats-cons.acc-slt-rubl        + sum-acc-slt-rubl                                        d-slts-vats-cons.acc-road-tax-base   = d-slts-vats-cons.acc-road-tax-base   + sum-acc-road-tax-base                                   d-slts-vats-cons.acc-road-tax-rubl   = d-slts-vats-cons.acc-road-tax-rubl   + sum-acc-road-tax-rubl                                   d-slts-vats-cons.acc-excise-base     = d-slts-vats-cons.acc-excise-base     + sum-acc-excise-base                                     d-slts-vats-cons.acc-excise-rubl     = d-slts-vats-cons.acc-excise-rubl     + sum-acc-excise-rubl                                     d-slts-vats-cons.acc-transport-base  = d-slts-vats-cons.acc-transport-base  + sum-acc-transport-base                                  d-slts-vats-cons.acc-transport-rubl  = d-slts-vats-cons.acc-transport-rubl  + sum-acc-transport-rubl                                  d-slts-vats-cons.acc-other-base      = d-slts-vats-cons.acc-other-base      + sum-acc-other-base                                      d-slts-vats-cons.acc-other-rubl      = d-slts-vats-cons.acc-other-rubl      + sum-acc-other-rubl                                      d-slts-vats-cons.pay-base            = d-slts-vats-cons.pay-base            + sum-price-base-with-tax-sale                                  d-slts-vats-cons.pay-rubl            = d-slts-vats-cons.pay-rubl            + sum-price-rubl-with-tax-sale                                  d-slts-vats-cons.vat-base            = d-slts-vats-cons.vat-base            + sum-vat-base-sale                                  d-slts-vats-cons.vat-rubl            = d-slts-vats-cons.vat-rubl            + sum-vat-rubl-sale                                  d-slts-vats-cons.no-vat-base         = d-slts-vats-cons.no-vat-base         + sum-price-base-with-tax-sale - sum-vat-base-sale                                  d-slts-vats-cons.no-vat-rubl         = d-slts-vats-cons.no-vat-rubl         + sum-price-rubl-with-tax-sale - sum-vat-rubl-sale                                  d-slts-vats-cons.vat-base-buyer      = d-slts-vats-cons.vat-base-buyer      + sum-vat-base-buyer                                  d-slts-vats-cons.vat-rubl-buyer      = d-slts-vats-cons.vat-rubl-buyer      + sum-vat-rubl-buyer                                  d-slts-vats-cons.slt-base            = d-slts-vats-cons.slt-base            + sum-slt-base-sale                                  d-slts-vats-cons.slt-rubl            = d-slts-vats-cons.slt-rubl            + sum-slt-rubl-sale                                  d-slts-vats-cons.road-tax            = d-slts-vats-cons.road-tax            + (if varr-b = "base" then sum-road-tax-base-sale else sum-road-tax-rubl-sale)                                  d-slts-vats-cons.excise              = d-slts-vats-cons.excise              + (if varr-b = "base" then sum-excise-base-sale   else sum-excise-rubl-sale)                                    d-slts-vats-cons.sale-base           = d-slts-vats-cons.sale-base           + sum-price-base-with-tax-sale-cur                                  d-slts-vats-cons.sale-rubl           = d-slts-vats-cons.sale-rubl           + sum-price-rubl-with-tax-sale-cur                                  d-slts-vats-cons.sale-vat-base       = d-slts-vats-cons.sale-vat-base       + sum-vat-base-sale-cur                                       d-slts-vats-cons.sale-vat-rubl       = d-slts-vats-cons.sale-vat-rubl       + sum-vat-rubl-sale-cur                                       d-slts-vats-cons.sale-vat-buyer-base = d-slts-vats-cons.sale-vat-buyer-base + sum-vat-base-buyer-cur                                      d-slts-vats-cons.sale-vat-buyer-rubl = d-slts-vats-cons.sale-vat-buyer-rubl + sum-vat-rubl-buyer-cur                                      d-slts-vats-cons.sale-slt-base       = d-slts-vats-cons.sale-slt-base       + sum-slt-base-sale-cur                                       d-slts-vats-cons.sale-slt-rubl       = d-slts-vats-cons.sale-slt-rubl       + sum-slt-rubl-sale-cur                                       d-slts-vats-cons.sale-road-tax-base  = d-slts-vats-cons.sale-road-tax-base  + sum-road-tax-base-sale-cur                                  d-slts-vats-cons.sale-road-tax-rubl  = d-slts-vats-cons.sale-road-tax-rubl  + sum-road-tax-rubl-sale-cur                                  d-slts-vats-cons.sale-excise-base    = d-slts-vats-cons.sale-excise-base    + sum-excise-base-sale-cur                                    d-slts-vats-cons.sale-excise-rubl    = d-slts-vats-cons.sale-excise-rubl    + sum-excise-rubl-sale-cur                                    d-slts-vats-cons.ov-base             = d-slts-vats-cons.ov-base             + (if varr-b = "base" then (sum-price-base-with-tax-sale-cur - sum-price-base-with-tax-sale) else (sum-price-rubl-with-tax-sale-cur - sum-price-rubl-with-tax-sale))                                  d-slts-vats-cons.ov-vat              = d-slts-vats-cons.ov-vat              + (if varr-b = "base" then (sum-price-base-with-tax-sale-cur - sum-price-base-with-tax-sale) else (sum-price-rubl-with-tax-sale-cur - sum-price-rubl-with-tax-sale)) * bf_doc-line.vat-pc / (100 + bf_doc-line.vat-pc).
      end.
            if lookup( "d-slts-vats-cons-fin", use-table ) > 0 then do:
        find first d-slts-vats-cons-fin where
                   d-slts-vats-cons-fin.vat-pc        = ?                     and
                   d-slts-vats-cons-fin.slt-pc        = ?                     and
                   d-slts-vats-cons-fin.contract-code = 0                     and
                   d-slts-vats-cons-fin.purch-code    = 1 no-error.
        if not available d-slts-vats-cons then do:
          create d-slts-vats-cons-fin.
          assign d-slts-vats-cons-fin.vat-pc        = ?
                 d-slts-vats-cons-fin.slt-pc        = ?
                 d-slts-vats-cons-fin.contract-code = 0
                 d-slts-vats-cons-fin.purch-code    = 1
                 d-slts-vats-cons-fin.purch-name    = 'выкуп':U.
        end.
        assign d-slts-vats-cons-fin.fact-qnty           = d-slts-vats-cons-fin.fact-qnty           + varqnty                                   d-slts-vats-cons-fin.acc-base            = d-slts-vats-cons-fin.acc-base            + sum-acc-base                                            d-slts-vats-cons-fin.acc-rubl            = d-slts-vats-cons-fin.acc-rubl            + sum-acc-rubl                                            d-slts-vats-cons-fin.acc-vat-base        = d-slts-vats-cons-fin.acc-vat-base        + sum-acc-vat-base                                        d-slts-vats-cons-fin.acc-vat-rubl        = d-slts-vats-cons-fin.acc-vat-rubl        + sum-acc-vat-rubl                                        d-slts-vats-cons-fin.acc-slt-base        = d-slts-vats-cons-fin.acc-slt-base        + sum-acc-slt-base                                        d-slts-vats-cons-fin.acc-slt-rubl        = d-slts-vats-cons-fin.acc-slt-rubl        + sum-acc-slt-rubl                                        d-slts-vats-cons-fin.acc-road-tax-base   = d-slts-vats-cons-fin.acc-road-tax-base   + sum-acc-road-tax-base                                   d-slts-vats-cons-fin.acc-road-tax-rubl   = d-slts-vats-cons-fin.acc-road-tax-rubl   + sum-acc-road-tax-rubl                                   d-slts-vats-cons-fin.acc-excise-base     = d-slts-vats-cons-fin.acc-excise-base     + sum-acc-excise-base                                     d-slts-vats-cons-fin.acc-excise-rubl     = d-slts-vats-cons-fin.acc-excise-rubl     + sum-acc-excise-rubl                                     d-slts-vats-cons-fin.acc-transport-base  = d-slts-vats-cons-fin.acc-transport-base  + sum-acc-transport-base                                  d-slts-vats-cons-fin.acc-transport-rubl  = d-slts-vats-cons-fin.acc-transport-rubl  + sum-acc-transport-rubl                                  d-slts-vats-cons-fin.acc-other-base      = d-slts-vats-cons-fin.acc-other-base      + sum-acc-other-base                                      d-slts-vats-cons-fin.acc-other-rubl      = d-slts-vats-cons-fin.acc-other-rubl      + sum-acc-other-rubl                                      d-slts-vats-cons-fin.pay-base            = d-slts-vats-cons-fin.pay-base            + sum-price-base-with-tax-sale                                  d-slts-vats-cons-fin.pay-rubl            = d-slts-vats-cons-fin.pay-rubl            + sum-price-rubl-with-tax-sale                                  d-slts-vats-cons-fin.vat-base            = d-slts-vats-cons-fin.vat-base            + sum-vat-base-sale                                  d-slts-vats-cons-fin.vat-rubl            = d-slts-vats-cons-fin.vat-rubl            + sum-vat-rubl-sale                                  d-slts-vats-cons-fin.no-vat-base         = d-slts-vats-cons-fin.no-vat-base         + sum-price-base-with-tax-sale - sum-vat-base-sale                                  d-slts-vats-cons-fin.no-vat-rubl         = d-slts-vats-cons-fin.no-vat-rubl         + sum-price-rubl-with-tax-sale - sum-vat-rubl-sale                                  d-slts-vats-cons-fin.vat-base-buyer      = d-slts-vats-cons-fin.vat-base-buyer      + sum-vat-base-buyer                                  d-slts-vats-cons-fin.vat-rubl-buyer      = d-slts-vats-cons-fin.vat-rubl-buyer      + sum-vat-rubl-buyer                                  d-slts-vats-cons-fin.slt-base            = d-slts-vats-cons-fin.slt-base            + sum-slt-base-sale                                  d-slts-vats-cons-fin.slt-rubl            = d-slts-vats-cons-fin.slt-rubl            + sum-slt-rubl-sale                                  d-slts-vats-cons-fin.road-tax            = d-slts-vats-cons-fin.road-tax            + (if varr-b = "base" then sum-road-tax-base-sale else sum-road-tax-rubl-sale)                                  d-slts-vats-cons-fin.excise              = d-slts-vats-cons-fin.excise              + (if varr-b = "base" then sum-excise-base-sale   else sum-excise-rubl-sale)                                    d-slts-vats-cons-fin.sale-base           = d-slts-vats-cons-fin.sale-base           + sum-price-base-with-tax-sale-cur                                  d-slts-vats-cons-fin.sale-rubl           = d-slts-vats-cons-fin.sale-rubl           + sum-price-rubl-with-tax-sale-cur                                  d-slts-vats-cons-fin.sale-vat-base       = d-slts-vats-cons-fin.sale-vat-base       + sum-vat-base-sale-cur                                       d-slts-vats-cons-fin.sale-vat-rubl       = d-slts-vats-cons-fin.sale-vat-rubl       + sum-vat-rubl-sale-cur                                       d-slts-vats-cons-fin.sale-vat-buyer-base = d-slts-vats-cons-fin.sale-vat-buyer-base + sum-vat-base-buyer-cur                                      d-slts-vats-cons-fin.sale-vat-buyer-rubl = d-slts-vats-cons-fin.sale-vat-buyer-rubl + sum-vat-rubl-buyer-cur                                      d-slts-vats-cons-fin.sale-slt-base       = d-slts-vats-cons-fin.sale-slt-base       + sum-slt-base-sale-cur                                       d-slts-vats-cons-fin.sale-slt-rubl       = d-slts-vats-cons-fin.sale-slt-rubl       + sum-slt-rubl-sale-cur                                       d-slts-vats-cons-fin.sale-road-tax-base  = d-slts-vats-cons-fin.sale-road-tax-base  + sum-road-tax-base-sale-cur                                  d-slts-vats-cons-fin.sale-road-tax-rubl  = d-slts-vats-cons-fin.sale-road-tax-rubl  + sum-road-tax-rubl-sale-cur                                  d-slts-vats-cons-fin.sale-excise-base    = d-slts-vats-cons-fin.sale-excise-base    + sum-excise-base-sale-cur                                    d-slts-vats-cons-fin.sale-excise-rubl    = d-slts-vats-cons-fin.sale-excise-rubl    + sum-excise-rubl-sale-cur                                    d-slts-vats-cons-fin.ov-base             = d-slts-vats-cons-fin.ov-base             + (if varr-b = "base" then (sum-price-base-with-tax-sale-cur - sum-price-base-with-tax-sale) else (sum-price-rubl-with-tax-sale-cur - sum-price-rubl-with-tax-sale))                                  d-slts-vats-cons-fin.ov-vat              = d-slts-vats-cons-fin.ov-vat              + (if varr-b = "base" then (sum-price-base-with-tax-sale-cur - sum-price-base-with-tax-sale) else (sum-price-rubl-with-tax-sale-cur - sum-price-rubl-with-tax-sale)) * bf_doc-line.vat-pc / (100 + bf_doc-line.vat-pc).
      end.
            if lookup( "d-slts-vats-cons-grp", use-table ) > 0 then do:
        find first d-slts-vats-cons-grp where
                   d-slts-vats-cons-grp.vat-pc     = ?                     and
                   d-slts-vats-cons-grp.slt-pc     = ?                     and
                   d-slts-vats-cons-grp.purch-code = 1 and
                   d-slts-vats-cons-grp.grp-code   = bf_goods.grp-code     no-error.
        if not available d-slts-vats-cons-grp then do:
          create d-slts-vats-cons-grp.
          assign d-slts-vats-cons-grp.vat-pc     = ?
                 d-slts-vats-cons-grp.slt-pc     = ?
                 d-slts-vats-cons-grp.purch-code = 1
                 d-slts-vats-cons-grp.purch-name = 'выкуп':U
                 d-slts-vats-cons-grp.grp-code   = bf_goods.grp-code
                 d-slts-vats-cons-grp.grp-name   = varfull-name-grp.
        end.
        assign d-slts-vats-cons-grp.fact-qnty           = d-slts-vats-cons-grp.fact-qnty           + varqnty                                   d-slts-vats-cons-grp.acc-base            = d-slts-vats-cons-grp.acc-base            + sum-acc-base                                            d-slts-vats-cons-grp.acc-rubl            = d-slts-vats-cons-grp.acc-rubl            + sum-acc-rubl                                            d-slts-vats-cons-grp.acc-vat-base        = d-slts-vats-cons-grp.acc-vat-base        + sum-acc-vat-base                                        d-slts-vats-cons-grp.acc-vat-rubl        = d-slts-vats-cons-grp.acc-vat-rubl        + sum-acc-vat-rubl                                        d-slts-vats-cons-grp.acc-slt-base        = d-slts-vats-cons-grp.acc-slt-base        + sum-acc-slt-base                                        d-slts-vats-cons-grp.acc-slt-rubl        = d-slts-vats-cons-grp.acc-slt-rubl        + sum-acc-slt-rubl                                        d-slts-vats-cons-grp.acc-road-tax-base   = d-slts-vats-cons-grp.acc-road-tax-base   + sum-acc-road-tax-base                                   d-slts-vats-cons-grp.acc-road-tax-rubl   = d-slts-vats-cons-grp.acc-road-tax-rubl   + sum-acc-road-tax-rubl                                   d-slts-vats-cons-grp.acc-excise-base     = d-slts-vats-cons-grp.acc-excise-base     + sum-acc-excise-base                                     d-slts-vats-cons-grp.acc-excise-rubl     = d-slts-vats-cons-grp.acc-excise-rubl     + sum-acc-excise-rubl                                     d-slts-vats-cons-grp.acc-transport-base  = d-slts-vats-cons-grp.acc-transport-base  + sum-acc-transport-base                                  d-slts-vats-cons-grp.acc-transport-rubl  = d-slts-vats-cons-grp.acc-transport-rubl  + sum-acc-transport-rubl                                  d-slts-vats-cons-grp.acc-other-base      = d-slts-vats-cons-grp.acc-other-base      + sum-acc-other-base                                      d-slts-vats-cons-grp.acc-other-rubl      = d-slts-vats-cons-grp.acc-other-rubl      + sum-acc-other-rubl                                      d-slts-vats-cons-grp.pay-base            = d-slts-vats-cons-grp.pay-base            + sum-price-base-with-tax-sale                                  d-slts-vats-cons-grp.pay-rubl            = d-slts-vats-cons-grp.pay-rubl            + sum-price-rubl-with-tax-sale                                  d-slts-vats-cons-grp.vat-base            = d-slts-vats-cons-grp.vat-base            + sum-vat-base-sale                                  d-slts-vats-cons-grp.vat-rubl            = d-slts-vats-cons-grp.vat-rubl            + sum-vat-rubl-sale                                  d-slts-vats-cons-grp.no-vat-base         = d-slts-vats-cons-grp.no-vat-base         + sum-price-base-with-tax-sale - sum-vat-base-sale                                  d-slts-vats-cons-grp.no-vat-rubl         = d-slts-vats-cons-grp.no-vat-rubl         + sum-price-rubl-with-tax-sale - sum-vat-rubl-sale                                  d-slts-vats-cons-grp.vat-base-buyer      = d-slts-vats-cons-grp.vat-base-buyer      + sum-vat-base-buyer                                  d-slts-vats-cons-grp.vat-rubl-buyer      = d-slts-vats-cons-grp.vat-rubl-buyer      + sum-vat-rubl-buyer                                  d-slts-vats-cons-grp.slt-base            = d-slts-vats-cons-grp.slt-base            + sum-slt-base-sale                                  d-slts-vats-cons-grp.slt-rubl            = d-slts-vats-cons-grp.slt-rubl            + sum-slt-rubl-sale                                  d-slts-vats-cons-grp.road-tax            = d-slts-vats-cons-grp.road-tax            + (if varr-b = "base" then sum-road-tax-base-sale else sum-road-tax-rubl-sale)                                  d-slts-vats-cons-grp.excise              = d-slts-vats-cons-grp.excise              + (if varr-b = "base" then sum-excise-base-sale   else sum-excise-rubl-sale)                                    d-slts-vats-cons-grp.sale-base           = d-slts-vats-cons-grp.sale-base           + sum-price-base-with-tax-sale-cur                                  d-slts-vats-cons-grp.sale-rubl           = d-slts-vats-cons-grp.sale-rubl           + sum-price-rubl-with-tax-sale-cur                                  d-slts-vats-cons-grp.sale-vat-base       = d-slts-vats-cons-grp.sale-vat-base       + sum-vat-base-sale-cur                                       d-slts-vats-cons-grp.sale-vat-rubl       = d-slts-vats-cons-grp.sale-vat-rubl       + sum-vat-rubl-sale-cur                                       d-slts-vats-cons-grp.sale-vat-buyer-base = d-slts-vats-cons-grp.sale-vat-buyer-base + sum-vat-base-buyer-cur                                      d-slts-vats-cons-grp.sale-vat-buyer-rubl = d-slts-vats-cons-grp.sale-vat-buyer-rubl + sum-vat-rubl-buyer-cur                                      d-slts-vats-cons-grp.sale-slt-base       = d-slts-vats-cons-grp.sale-slt-base       + sum-slt-base-sale-cur                                       d-slts-vats-cons-grp.sale-slt-rubl       = d-slts-vats-cons-grp.sale-slt-rubl       + sum-slt-rubl-sale-cur                                       d-slts-vats-cons-grp.sale-road-tax-base  = d-slts-vats-cons-grp.sale-road-tax-base  + sum-road-tax-base-sale-cur                                  d-slts-vats-cons-grp.sale-road-tax-rubl  = d-slts-vats-cons-grp.sale-road-tax-rubl  + sum-road-tax-rubl-sale-cur                                  d-slts-vats-cons-grp.sale-excise-base    = d-slts-vats-cons-grp.sale-excise-base    + sum-excise-base-sale-cur                                    d-slts-vats-cons-grp.sale-excise-rubl    = d-slts-vats-cons-grp.sale-excise-rubl    + sum-excise-rubl-sale-cur                                    d-slts-vats-cons-grp.ov-base             = d-slts-vats-cons-grp.ov-base             + (if varr-b = "base" then (sum-price-base-with-tax-sale-cur - sum-price-base-with-tax-sale) else (sum-price-rubl-with-tax-sale-cur - sum-price-rubl-with-tax-sale))                                  d-slts-vats-cons-grp.ov-vat              = d-slts-vats-cons-grp.ov-vat              + (if varr-b = "base" then (sum-price-base-with-tax-sale-cur - sum-price-base-with-tax-sale) else (sum-price-rubl-with-tax-sale-cur - sum-price-rubl-with-tax-sale)) * bf_doc-line.vat-pc / (100 + bf_doc-line.vat-pc).
      end.
            if lookup( "d-slts-vats-cons-grp-fin", use-table ) > 0 then do:
        find first d-slts-vats-cons-grp-fin where
                   d-slts-vats-cons-grp-fin.vat-pc        = ?                     and
                   d-slts-vats-cons-grp-fin.slt-pc        = ?                     and
                   d-slts-vats-cons-grp-fin.contract-code = 0                     and
                   d-slts-vats-cons-grp-fin.purch-code    = 1 and
                   d-slts-vats-cons-grp-fin.grp-code      = bf_goods.grp-code     no-error.
        if not available d-slts-vats-cons-grp-fin then do:
          create d-slts-vats-cons-grp-fin.
          assign d-slts-vats-cons-grp-fin.vat-pc        = ?
                 d-slts-vats-cons-grp-fin.slt-pc        = ?
                 d-slts-vats-cons-grp-fin.contract-code = 0
                 d-slts-vats-cons-grp-fin.purch-code    = 1
                 d-slts-vats-cons-grp-fin.purch-name    = 'выкуп':U
                 d-slts-vats-cons-grp-fin.grp-code      = bf_goods.grp-code
                 d-slts-vats-cons-grp-fin.grp-name      = varfull-name-grp.
        end.
        assign d-slts-vats-cons-grp-fin.fact-qnty           = d-slts-vats-cons-grp-fin.fact-qnty           + varqnty                                   d-slts-vats-cons-grp-fin.acc-base            = d-slts-vats-cons-grp-fin.acc-base            + sum-acc-base                                            d-slts-vats-cons-grp-fin.acc-rubl            = d-slts-vats-cons-grp-fin.acc-rubl            + sum-acc-rubl                                            d-slts-vats-cons-grp-fin.acc-vat-base        = d-slts-vats-cons-grp-fin.acc-vat-base        + sum-acc-vat-base                                        d-slts-vats-cons-grp-fin.acc-vat-rubl        = d-slts-vats-cons-grp-fin.acc-vat-rubl        + sum-acc-vat-rubl                                        d-slts-vats-cons-grp-fin.acc-slt-base        = d-slts-vats-cons-grp-fin.acc-slt-base        + sum-acc-slt-base                                        d-slts-vats-cons-grp-fin.acc-slt-rubl        = d-slts-vats-cons-grp-fin.acc-slt-rubl        + sum-acc-slt-rubl                                        d-slts-vats-cons-grp-fin.acc-road-tax-base   = d-slts-vats-cons-grp-fin.acc-road-tax-base   + sum-acc-road-tax-base                                   d-slts-vats-cons-grp-fin.acc-road-tax-rubl   = d-slts-vats-cons-grp-fin.acc-road-tax-rubl   + sum-acc-road-tax-rubl                                   d-slts-vats-cons-grp-fin.acc-excise-base     = d-slts-vats-cons-grp-fin.acc-excise-base     + sum-acc-excise-base                                     d-slts-vats-cons-grp-fin.acc-excise-rubl     = d-slts-vats-cons-grp-fin.acc-excise-rubl     + sum-acc-excise-rubl                                     d-slts-vats-cons-grp-fin.acc-transport-base  = d-slts-vats-cons-grp-fin.acc-transport-base  + sum-acc-transport-base                                  d-slts-vats-cons-grp-fin.acc-transport-rubl  = d-slts-vats-cons-grp-fin.acc-transport-rubl  + sum-acc-transport-rubl                                  d-slts-vats-cons-grp-fin.acc-other-base      = d-slts-vats-cons-grp-fin.acc-other-base      + sum-acc-other-base                                      d-slts-vats-cons-grp-fin.acc-other-rubl      = d-slts-vats-cons-grp-fin.acc-other-rubl      + sum-acc-other-rubl                                      d-slts-vats-cons-grp-fin.pay-base            = d-slts-vats-cons-grp-fin.pay-base            + sum-price-base-with-tax-sale                                  d-slts-vats-cons-grp-fin.pay-rubl            = d-slts-vats-cons-grp-fin.pay-rubl            + sum-price-rubl-with-tax-sale                                  d-slts-vats-cons-grp-fin.vat-base            = d-slts-vats-cons-grp-fin.vat-base            + sum-vat-base-sale                                  d-slts-vats-cons-grp-fin.vat-rubl            = d-slts-vats-cons-grp-fin.vat-rubl            + sum-vat-rubl-sale                                  d-slts-vats-cons-grp-fin.no-vat-base         = d-slts-vats-cons-grp-fin.no-vat-base         + sum-price-base-with-tax-sale - sum-vat-base-sale                                  d-slts-vats-cons-grp-fin.no-vat-rubl         = d-slts-vats-cons-grp-fin.no-vat-rubl         + sum-price-rubl-with-tax-sale - sum-vat-rubl-sale                                  d-slts-vats-cons-grp-fin.vat-base-buyer      = d-slts-vats-cons-grp-fin.vat-base-buyer      + sum-vat-base-buyer                                  d-slts-vats-cons-grp-fin.vat-rubl-buyer      = d-slts-vats-cons-grp-fin.vat-rubl-buyer      + sum-vat-rubl-buyer                                  d-slts-vats-cons-grp-fin.slt-base            = d-slts-vats-cons-grp-fin.slt-base            + sum-slt-base-sale                                  d-slts-vats-cons-grp-fin.slt-rubl            = d-slts-vats-cons-grp-fin.slt-rubl            + sum-slt-rubl-sale                                  d-slts-vats-cons-grp-fin.road-tax            = d-slts-vats-cons-grp-fin.road-tax            + (if varr-b = "base" then sum-road-tax-base-sale else sum-road-tax-rubl-sale)                                  d-slts-vats-cons-grp-fin.excise              = d-slts-vats-cons-grp-fin.excise              + (if varr-b = "base" then sum-excise-base-sale   else sum-excise-rubl-sale)                                    d-slts-vats-cons-grp-fin.sale-base           = d-slts-vats-cons-grp-fin.sale-base           + sum-price-base-with-tax-sale-cur                                  d-slts-vats-cons-grp-fin.sale-rubl           = d-slts-vats-cons-grp-fin.sale-rubl           + sum-price-rubl-with-tax-sale-cur                                  d-slts-vats-cons-grp-fin.sale-vat-base       = d-slts-vats-cons-grp-fin.sale-vat-base       + sum-vat-base-sale-cur                                       d-slts-vats-cons-grp-fin.sale-vat-rubl       = d-slts-vats-cons-grp-fin.sale-vat-rubl       + sum-vat-rubl-sale-cur                                       d-slts-vats-cons-grp-fin.sale-vat-buyer-base = d-slts-vats-cons-grp-fin.sale-vat-buyer-base + sum-vat-base-buyer-cur                                      d-slts-vats-cons-grp-fin.sale-vat-buyer-rubl = d-slts-vats-cons-grp-fin.sale-vat-buyer-rubl + sum-vat-rubl-buyer-cur                                      d-slts-vats-cons-grp-fin.sale-slt-base       = d-slts-vats-cons-grp-fin.sale-slt-base       + sum-slt-base-sale-cur                                       d-slts-vats-cons-grp-fin.sale-slt-rubl       = d-slts-vats-cons-grp-fin.sale-slt-rubl       + sum-slt-rubl-sale-cur                                       d-slts-vats-cons-grp-fin.sale-road-tax-base  = d-slts-vats-cons-grp-fin.sale-road-tax-base  + sum-road-tax-base-sale-cur                                  d-slts-vats-cons-grp-fin.sale-road-tax-rubl  = d-slts-vats-cons-grp-fin.sale-road-tax-rubl  + sum-road-tax-rubl-sale-cur                                  d-slts-vats-cons-grp-fin.sale-excise-base    = d-slts-vats-cons-grp-fin.sale-excise-base    + sum-excise-base-sale-cur                                    d-slts-vats-cons-grp-fin.sale-excise-rubl    = d-slts-vats-cons-grp-fin.sale-excise-rubl    + sum-excise-rubl-sale-cur                                    d-slts-vats-cons-grp-fin.ov-base             = d-slts-vats-cons-grp-fin.ov-base             + (if varr-b = "base" then (sum-price-base-with-tax-sale-cur - sum-price-base-with-tax-sale) else (sum-price-rubl-with-tax-sale-cur - sum-price-rubl-with-tax-sale))                                  d-slts-vats-cons-grp-fin.ov-vat              = d-slts-vats-cons-grp-fin.ov-vat              + (if varr-b = "base" then (sum-price-base-with-tax-sale-cur - sum-price-base-with-tax-sale) else (sum-price-rubl-with-tax-sale-cur - sum-price-rubl-with-tax-sale)) * bf_doc-line.vat-pc / (100 + bf_doc-line.vat-pc).
      end.
            if lookup( "d-supp", use-table ) > 0 then do:
         find first d-supp where
                    d-supp.supp-type  = bf_trn-doc.cli-type   and
                    d-supp.supp-code  = bf_trn-doc.cli-code   and
                    d-supp.purch-code = 1 no-error.
         if not available d-supp then do:
            create d-supp.
            assign d-supp.supp-type  = bf_trn-doc.cli-type
                   d-supp.supp-code  = bf_trn-doc.cli-code
                   d-supp.purch-code = 1
                   d-supp.supp-name  = bf_trn-doc.cli-name
                   d-supp.purch-name = 'выкуп':U.
         end.
         assign d-supp.fact-qnty           = d-supp.fact-qnty           + varqnty                                   d-supp.acc-base            = d-supp.acc-base            + sum-acc-base                                            d-supp.acc-rubl            = d-supp.acc-rubl            + sum-acc-rubl                                            d-supp.acc-vat-base        = d-supp.acc-vat-base        + sum-acc-vat-base                                        d-supp.acc-vat-rubl        = d-supp.acc-vat-rubl        + sum-acc-vat-rubl                                        d-supp.acc-slt-base        = d-supp.acc-slt-base        + sum-acc-slt-base                                        d-supp.acc-slt-rubl        = d-supp.acc-slt-rubl        + sum-acc-slt-rubl                                        d-supp.acc-road-tax-base   = d-supp.acc-road-tax-base   + sum-acc-road-tax-base                                   d-supp.acc-road-tax-rubl   = d-supp.acc-road-tax-rubl   + sum-acc-road-tax-rubl                                   d-supp.acc-excise-base     = d-supp.acc-excise-base     + sum-acc-excise-base                                     d-supp.acc-excise-rubl     = d-supp.acc-excise-rubl     + sum-acc-excise-rubl                                     d-supp.acc-transport-base  = d-supp.acc-transport-base  + sum-acc-transport-base                                  d-supp.acc-transport-rubl  = d-supp.acc-transport-rubl  + sum-acc-transport-rubl                                  d-supp.acc-other-base      = d-supp.acc-other-base      + sum-acc-other-base                                      d-supp.acc-other-rubl      = d-supp.acc-other-rubl      + sum-acc-other-rubl                                      d-supp.pay-base            = d-supp.pay-base            + sum-price-base-with-tax-sale                                  d-supp.pay-rubl            = d-supp.pay-rubl            + sum-price-rubl-with-tax-sale                                  d-supp.vat-base            = d-supp.vat-base            + sum-vat-base-sale                                  d-supp.vat-rubl            = d-supp.vat-rubl            + sum-vat-rubl-sale                                  d-supp.no-vat-base         = d-supp.no-vat-base         + sum-price-base-with-tax-sale - sum-vat-base-sale                                  d-supp.no-vat-rubl         = d-supp.no-vat-rubl         + sum-price-rubl-with-tax-sale - sum-vat-rubl-sale                                  d-supp.vat-base-buyer      = d-supp.vat-base-buyer      + sum-vat-base-buyer                                  d-supp.vat-rubl-buyer      = d-supp.vat-rubl-buyer      + sum-vat-rubl-buyer                                  d-supp.slt-base            = d-supp.slt-base            + sum-slt-base-sale                                  d-supp.slt-rubl            = d-supp.slt-rubl            + sum-slt-rubl-sale                                  d-supp.road-tax            = d-supp.road-tax            + (if varr-b = "base" then sum-road-tax-base-sale else sum-road-tax-rubl-sale)                                  d-supp.excise              = d-supp.excise              + (if varr-b = "base" then sum-excise-base-sale   else sum-excise-rubl-sale)                                    d-supp.sale-base           = d-supp.sale-base           + sum-price-base-with-tax-sale-cur                                  d-supp.sale-rubl           = d-supp.sale-rubl           + sum-price-rubl-with-tax-sale-cur                                  d-supp.sale-vat-base       = d-supp.sale-vat-base       + sum-vat-base-sale-cur                                       d-supp.sale-vat-rubl       = d-supp.sale-vat-rubl       + sum-vat-rubl-sale-cur                                       d-supp.sale-vat-buyer-base = d-supp.sale-vat-buyer-base + sum-vat-base-buyer-cur                                      d-supp.sale-vat-buyer-rubl = d-supp.sale-vat-buyer-rubl + sum-vat-rubl-buyer-cur                                      d-supp.sale-slt-base       = d-supp.sale-slt-base       + sum-slt-base-sale-cur                                       d-supp.sale-slt-rubl       = d-supp.sale-slt-rubl       + sum-slt-rubl-sale-cur                                       d-supp.sale-road-tax-base  = d-supp.sale-road-tax-base  + sum-road-tax-base-sale-cur                                  d-supp.sale-road-tax-rubl  = d-supp.sale-road-tax-rubl  + sum-road-tax-rubl-sale-cur                                  d-supp.sale-excise-base    = d-supp.sale-excise-base    + sum-excise-base-sale-cur                                    d-supp.sale-excise-rubl    = d-supp.sale-excise-rubl    + sum-excise-rubl-sale-cur                                    d-supp.ov-base             = d-supp.ov-base             + (if varr-b = "base" then (sum-price-base-with-tax-sale-cur - sum-price-base-with-tax-sale) else (sum-price-rubl-with-tax-sale-cur - sum-price-rubl-with-tax-sale))                                  d-supp.ov-vat              = d-supp.ov-vat              + (if varr-b = "base" then (sum-price-base-with-tax-sale-cur - sum-price-base-with-tax-sale) else (sum-price-rubl-with-tax-sale-cur - sum-price-rubl-with-tax-sale)) * bf_doc-line.vat-pc / (100 + bf_doc-line.vat-pc).
      end.
            if lookup( "d-supp-fin", use-table ) > 0 then do:
         find first d-supp-fin where
                    d-supp-fin.supp-type     = bf_trn-doc.cli-type   and
                    d-supp-fin.supp-code     = bf_trn-doc.cli-code   and
                    d-supp-fin.contract-code = 0                     and
                    d-supp-fin.purch-code    = 1 no-error.
         if not available d-supp-fin then do:
            create d-supp-fin.
            assign d-supp-fin.supp-type     = bf_trn-doc.cli-type
                   d-supp-fin.supp-code     = bf_trn-doc.cli-code
                   d-supp-fin.contract-code = 0
                   d-supp-fin.purch-code    = 1
                   d-supp-fin.supp-name     = bf_trn-doc.cli-name
                   d-supp-fin.purch-name    = 'выкуп':U.
         end.
         assign d-supp-fin.fact-qnty           = d-supp-fin.fact-qnty           + varqnty                                   d-supp-fin.acc-base            = d-supp-fin.acc-base            + sum-acc-base                                            d-supp-fin.acc-rubl            = d-supp-fin.acc-rubl            + sum-acc-rubl                                            d-supp-fin.acc-vat-base        = d-supp-fin.acc-vat-base        + sum-acc-vat-base                                        d-supp-fin.acc-vat-rubl        = d-supp-fin.acc-vat-rubl        + sum-acc-vat-rubl                                        d-supp-fin.acc-slt-base        = d-supp-fin.acc-slt-base        + sum-acc-slt-base                                        d-supp-fin.acc-slt-rubl        = d-supp-fin.acc-slt-rubl        + sum-acc-slt-rubl                                        d-supp-fin.acc-road-tax-base   = d-supp-fin.acc-road-tax-base   + sum-acc-road-tax-base                                   d-supp-fin.acc-road-tax-rubl   = d-supp-fin.acc-road-tax-rubl   + sum-acc-road-tax-rubl                                   d-supp-fin.acc-excise-base     = d-supp-fin.acc-excise-base     + sum-acc-excise-base                                     d-supp-fin.acc-excise-rubl     = d-supp-fin.acc-excise-rubl     + sum-acc-excise-rubl                                     d-supp-fin.acc-transport-base  = d-supp-fin.acc-transport-base  + sum-acc-transport-base                                  d-supp-fin.acc-transport-rubl  = d-supp-fin.acc-transport-rubl  + sum-acc-transport-rubl                                  d-supp-fin.acc-other-base      = d-supp-fin.acc-other-base      + sum-acc-other-base                                      d-supp-fin.acc-other-rubl      = d-supp-fin.acc-other-rubl      + sum-acc-other-rubl                                      d-supp-fin.pay-base            = d-supp-fin.pay-base            + sum-price-base-with-tax-sale                                  d-supp-fin.pay-rubl            = d-supp-fin.pay-rubl            + sum-price-rubl-with-tax-sale                                  d-supp-fin.vat-base            = d-supp-fin.vat-base            + sum-vat-base-sale                                  d-supp-fin.vat-rubl            = d-supp-fin.vat-rubl            + sum-vat-rubl-sale                                  d-supp-fin.no-vat-base         = d-supp-fin.no-vat-base         + sum-price-base-with-tax-sale - sum-vat-base-sale                                  d-supp-fin.no-vat-rubl         = d-supp-fin.no-vat-rubl         + sum-price-rubl-with-tax-sale - sum-vat-rubl-sale                                  d-supp-fin.vat-base-buyer      = d-supp-fin.vat-base-buyer      + sum-vat-base-buyer                                  d-supp-fin.vat-rubl-buyer      = d-supp-fin.vat-rubl-buyer      + sum-vat-rubl-buyer                                  d-supp-fin.slt-base            = d-supp-fin.slt-base            + sum-slt-base-sale                                  d-supp-fin.slt-rubl            = d-supp-fin.slt-rubl            + sum-slt-rubl-sale                                  d-supp-fin.road-tax            = d-supp-fin.road-tax            + (if varr-b = "base" then sum-road-tax-base-sale else sum-road-tax-rubl-sale)                                  d-supp-fin.excise              = d-supp-fin.excise              + (if varr-b = "base" then sum-excise-base-sale   else sum-excise-rubl-sale)                                    d-supp-fin.sale-base           = d-supp-fin.sale-base           + sum-price-base-with-tax-sale-cur                                  d-supp-fin.sale-rubl           = d-supp-fin.sale-rubl           + sum-price-rubl-with-tax-sale-cur                                  d-supp-fin.sale-vat-base       = d-supp-fin.sale-vat-base       + sum-vat-base-sale-cur                                       d-supp-fin.sale-vat-rubl       = d-supp-fin.sale-vat-rubl       + sum-vat-rubl-sale-cur                                       d-supp-fin.sale-vat-buyer-base = d-supp-fin.sale-vat-buyer-base + sum-vat-base-buyer-cur                                      d-supp-fin.sale-vat-buyer-rubl = d-supp-fin.sale-vat-buyer-rubl + sum-vat-rubl-buyer-cur                                      d-supp-fin.sale-slt-base       = d-supp-fin.sale-slt-base       + sum-slt-base-sale-cur                                       d-supp-fin.sale-slt-rubl       = d-supp-fin.sale-slt-rubl       + sum-slt-rubl-sale-cur                                       d-supp-fin.sale-road-tax-base  = d-supp-fin.sale-road-tax-base  + sum-road-tax-base-sale-cur                                  d-supp-fin.sale-road-tax-rubl  = d-supp-fin.sale-road-tax-rubl  + sum-road-tax-rubl-sale-cur                                  d-supp-fin.sale-excise-base    = d-supp-fin.sale-excise-base    + sum-excise-base-sale-cur                                    d-supp-fin.sale-excise-rubl    = d-supp-fin.sale-excise-rubl    + sum-excise-rubl-sale-cur                                    d-supp-fin.ov-base             = d-supp-fin.ov-base             + (if varr-b = "base" then (sum-price-base-with-tax-sale-cur - sum-price-base-with-tax-sale) else (sum-price-rubl-with-tax-sale-cur - sum-price-rubl-with-tax-sale))                                  d-supp-fin.ov-vat              = d-supp-fin.ov-vat              + (if varr-b = "base" then (sum-price-base-with-tax-sale-cur - sum-price-base-with-tax-sale) else (sum-price-rubl-with-tax-sale-cur - sum-price-rubl-with-tax-sale)) * bf_doc-line.vat-pc / (100 + bf_doc-line.vat-pc).
      end.
            if lookup( "d-supp-grp", use-table ) > 0 then do:
         find first d-supp-grp where
                    d-supp-grp.supp-type  = bf_trn-doc.cli-type   and
                    d-supp-grp.supp-code  = bf_trn-doc.cli-code   and
                    d-supp-grp.purch-code = 1 and
                    d-supp-grp.grp-code   = bf_goods.grp-code     no-error.
         if not available d-supp-grp then do:
            create d-supp-grp.
            assign d-supp-grp.supp-type  = bf_trn-doc.cli-type
                   d-supp-grp.supp-code  = bf_trn-doc.cli-code
                   d-supp-grp.purch-code = 1
                   d-supp-grp.grp-code   = bf_goods.grp-code
                   d-supp-grp.supp-name  = bf_trn-doc.cli-name
                   d-supp-grp.purch-name = 'выкуп':U
                   d-supp-grp.grp-name   = varfull-name-grp.
         end.
         assign d-supp-grp.fact-qnty           = d-supp-grp.fact-qnty           + varqnty                                   d-supp-grp.acc-base            = d-supp-grp.acc-base            + sum-acc-base                                            d-supp-grp.acc-rubl            = d-supp-grp.acc-rubl            + sum-acc-rubl                                            d-supp-grp.acc-vat-base        = d-supp-grp.acc-vat-base        + sum-acc-vat-base                                        d-supp-grp.acc-vat-rubl        = d-supp-grp.acc-vat-rubl        + sum-acc-vat-rubl                                        d-supp-grp.acc-slt-base        = d-supp-grp.acc-slt-base        + sum-acc-slt-base                                        d-supp-grp.acc-slt-rubl        = d-supp-grp.acc-slt-rubl        + sum-acc-slt-rubl                                        d-supp-grp.acc-road-tax-base   = d-supp-grp.acc-road-tax-base   + sum-acc-road-tax-base                                   d-supp-grp.acc-road-tax-rubl   = d-supp-grp.acc-road-tax-rubl   + sum-acc-road-tax-rubl                                   d-supp-grp.acc-excise-base     = d-supp-grp.acc-excise-base     + sum-acc-excise-base                                     d-supp-grp.acc-excise-rubl     = d-supp-grp.acc-excise-rubl     + sum-acc-excise-rubl                                     d-supp-grp.acc-transport-base  = d-supp-grp.acc-transport-base  + sum-acc-transport-base                                  d-supp-grp.acc-transport-rubl  = d-supp-grp.acc-transport-rubl  + sum-acc-transport-rubl                                  d-supp-grp.acc-other-base      = d-supp-grp.acc-other-base      + sum-acc-other-base                                      d-supp-grp.acc-other-rubl      = d-supp-grp.acc-other-rubl      + sum-acc-other-rubl                                      d-supp-grp.pay-base            = d-supp-grp.pay-base            + sum-price-base-with-tax-sale                                  d-supp-grp.pay-rubl            = d-supp-grp.pay-rubl            + sum-price-rubl-with-tax-sale                                  d-supp-grp.vat-base            = d-supp-grp.vat-base            + sum-vat-base-sale                                  d-supp-grp.vat-rubl            = d-supp-grp.vat-rubl            + sum-vat-rubl-sale                                  d-supp-grp.no-vat-base         = d-supp-grp.no-vat-base         + sum-price-base-with-tax-sale - sum-vat-base-sale                                  d-supp-grp.no-vat-rubl         = d-supp-grp.no-vat-rubl         + sum-price-rubl-with-tax-sale - sum-vat-rubl-sale                                  d-supp-grp.vat-base-buyer      = d-supp-grp.vat-base-buyer      + sum-vat-base-buyer                                  d-supp-grp.vat-rubl-buyer      = d-supp-grp.vat-rubl-buyer      + sum-vat-rubl-buyer                                  d-supp-grp.slt-base            = d-supp-grp.slt-base            + sum-slt-base-sale                                  d-supp-grp.slt-rubl            = d-supp-grp.slt-rubl            + sum-slt-rubl-sale                                  d-supp-grp.road-tax            = d-supp-grp.road-tax            + (if varr-b = "base" then sum-road-tax-base-sale else sum-road-tax-rubl-sale)                                  d-supp-grp.excise              = d-supp-grp.excise              + (if varr-b = "base" then sum-excise-base-sale   else sum-excise-rubl-sale)                                    d-supp-grp.sale-base           = d-supp-grp.sale-base           + sum-price-base-with-tax-sale-cur                                  d-supp-grp.sale-rubl           = d-supp-grp.sale-rubl           + sum-price-rubl-with-tax-sale-cur                                  d-supp-grp.sale-vat-base       = d-supp-grp.sale-vat-base       + sum-vat-base-sale-cur                                       d-supp-grp.sale-vat-rubl       = d-supp-grp.sale-vat-rubl       + sum-vat-rubl-sale-cur                                       d-supp-grp.sale-vat-buyer-base = d-supp-grp.sale-vat-buyer-base + sum-vat-base-buyer-cur                                      d-supp-grp.sale-vat-buyer-rubl = d-supp-grp.sale-vat-buyer-rubl + sum-vat-rubl-buyer-cur                                      d-supp-grp.sale-slt-base       = d-supp-grp.sale-slt-base       + sum-slt-base-sale-cur                                       d-supp-grp.sale-slt-rubl       = d-supp-grp.sale-slt-rubl       + sum-slt-rubl-sale-cur                                       d-supp-grp.sale-road-tax-base  = d-supp-grp.sale-road-tax-base  + sum-road-tax-base-sale-cur                                  d-supp-grp.sale-road-tax-rubl  = d-supp-grp.sale-road-tax-rubl  + sum-road-tax-rubl-sale-cur                                  d-supp-grp.sale-excise-base    = d-supp-grp.sale-excise-base    + sum-excise-base-sale-cur                                    d-supp-grp.sale-excise-rubl    = d-supp-grp.sale-excise-rubl    + sum-excise-rubl-sale-cur                                    d-supp-grp.ov-base             = d-supp-grp.ov-base             + (if varr-b = "base" then (sum-price-base-with-tax-sale-cur - sum-price-base-with-tax-sale) else (sum-price-rubl-with-tax-sale-cur - sum-price-rubl-with-tax-sale))                                  d-supp-grp.ov-vat              = d-supp-grp.ov-vat              + (if varr-b = "base" then (sum-price-base-with-tax-sale-cur - sum-price-base-with-tax-sale) else (sum-price-rubl-with-tax-sale-cur - sum-price-rubl-with-tax-sale)) * bf_doc-line.vat-pc / (100 + bf_doc-line.vat-pc).
      end.
            if lookup( "d-supp-grp-fin", use-table ) > 0 then do:
        find first d-supp-grp-fin where
                   d-supp-grp-fin.supp-type     = bf_trn-doc.cli-type   and
                   d-supp-grp-fin.supp-code     = bf_trn-doc.cli-code   and
                   d-supp-grp-fin.contract-code = 0                     and
                   d-supp-grp-fin.purch-code    = 1 and
                   d-supp-grp-fin.grp-code      = bf_goods.grp-code     no-error.
        if not available d-supp-grp-fin then do:
          create d-supp-grp-fin.
          assign d-supp-grp-fin.supp-type     = bf_trn-doc.cli-type
                 d-supp-grp-fin.supp-code     = bf_trn-doc.cli-code
                 d-supp-grp-fin.contract-code = 0
                 d-supp-grp-fin.purch-code    = 1
                 d-supp-grp-fin.grp-code      = bf_goods.grp-code
                 d-supp-grp-fin.supp-name     = bf_trn-doc.cli-name
                 d-supp-grp-fin.purch-name    = 'выкуп':U
                 d-supp-grp-fin.grp-name      = varfull-name-grp.
        end.
        assign d-supp-grp-fin.fact-qnty           = d-supp-grp-fin.fact-qnty           + varqnty                                   d-supp-grp-fin.acc-base            = d-supp-grp-fin.acc-base            + sum-acc-base                                            d-supp-grp-fin.acc-rubl            = d-supp-grp-fin.acc-rubl            + sum-acc-rubl                                            d-supp-grp-fin.acc-vat-base        = d-supp-grp-fin.acc-vat-base        + sum-acc-vat-base                                        d-supp-grp-fin.acc-vat-rubl        = d-supp-grp-fin.acc-vat-rubl        + sum-acc-vat-rubl                                        d-supp-grp-fin.acc-slt-base        = d-supp-grp-fin.acc-slt-base        + sum-acc-slt-base                                        d-supp-grp-fin.acc-slt-rubl        = d-supp-grp-fin.acc-slt-rubl        + sum-acc-slt-rubl                                        d-supp-grp-fin.acc-road-tax-base   = d-supp-grp-fin.acc-road-tax-base   + sum-acc-road-tax-base                                   d-supp-grp-fin.acc-road-tax-rubl   = d-supp-grp-fin.acc-road-tax-rubl   + sum-acc-road-tax-rubl                                   d-supp-grp-fin.acc-excise-base     = d-supp-grp-fin.acc-excise-base     + sum-acc-excise-base                                     d-supp-grp-fin.acc-excise-rubl     = d-supp-grp-fin.acc-excise-rubl     + sum-acc-excise-rubl                                     d-supp-grp-fin.acc-transport-base  = d-supp-grp-fin.acc-transport-base  + sum-acc-transport-base                                  d-supp-grp-fin.acc-transport-rubl  = d-supp-grp-fin.acc-transport-rubl  + sum-acc-transport-rubl                                  d-supp-grp-fin.acc-other-base      = d-supp-grp-fin.acc-other-base      + sum-acc-other-base                                      d-supp-grp-fin.acc-other-rubl      = d-supp-grp-fin.acc-other-rubl      + sum-acc-other-rubl                                      d-supp-grp-fin.pay-base            = d-supp-grp-fin.pay-base            + sum-price-base-with-tax-sale                                  d-supp-grp-fin.pay-rubl            = d-supp-grp-fin.pay-rubl            + sum-price-rubl-with-tax-sale                                  d-supp-grp-fin.vat-base            = d-supp-grp-fin.vat-base            + sum-vat-base-sale                                  d-supp-grp-fin.vat-rubl            = d-supp-grp-fin.vat-rubl            + sum-vat-rubl-sale                                  d-supp-grp-fin.no-vat-base         = d-supp-grp-fin.no-vat-base         + sum-price-base-with-tax-sale - sum-vat-base-sale                                  d-supp-grp-fin.no-vat-rubl         = d-supp-grp-fin.no-vat-rubl         + sum-price-rubl-with-tax-sale - sum-vat-rubl-sale                                  d-supp-grp-fin.vat-base-buyer      = d-supp-grp-fin.vat-base-buyer      + sum-vat-base-buyer                                  d-supp-grp-fin.vat-rubl-buyer      = d-supp-grp-fin.vat-rubl-buyer      + sum-vat-rubl-buyer                                  d-supp-grp-fin.slt-base            = d-supp-grp-fin.slt-base            + sum-slt-base-sale                                  d-supp-grp-fin.slt-rubl            = d-supp-grp-fin.slt-rubl            + sum-slt-rubl-sale                                  d-supp-grp-fin.road-tax            = d-supp-grp-fin.road-tax            + (if varr-b = "base" then sum-road-tax-base-sale else sum-road-tax-rubl-sale)                                  d-supp-grp-fin.excise              = d-supp-grp-fin.excise              + (if varr-b = "base" then sum-excise-base-sale   else sum-excise-rubl-sale)                                    d-supp-grp-fin.sale-base           = d-supp-grp-fin.sale-base           + sum-price-base-with-tax-sale-cur                                  d-supp-grp-fin.sale-rubl           = d-supp-grp-fin.sale-rubl           + sum-price-rubl-with-tax-sale-cur                                  d-supp-grp-fin.sale-vat-base       = d-supp-grp-fin.sale-vat-base       + sum-vat-base-sale-cur                                       d-supp-grp-fin.sale-vat-rubl       = d-supp-grp-fin.sale-vat-rubl       + sum-vat-rubl-sale-cur                                       d-supp-grp-fin.sale-vat-buyer-base = d-supp-grp-fin.sale-vat-buyer-base + sum-vat-base-buyer-cur                                      d-supp-grp-fin.sale-vat-buyer-rubl = d-supp-grp-fin.sale-vat-buyer-rubl + sum-vat-rubl-buyer-cur                                      d-supp-grp-fin.sale-slt-base       = d-supp-grp-fin.sale-slt-base       + sum-slt-base-sale-cur                                       d-supp-grp-fin.sale-slt-rubl       = d-supp-grp-fin.sale-slt-rubl       + sum-slt-rubl-sale-cur                                       d-supp-grp-fin.sale-road-tax-base  = d-supp-grp-fin.sale-road-tax-base  + sum-road-tax-base-sale-cur                                  d-supp-grp-fin.sale-road-tax-rubl  = d-supp-grp-fin.sale-road-tax-rubl  + sum-road-tax-rubl-sale-cur                                  d-supp-grp-fin.sale-excise-base    = d-supp-grp-fin.sale-excise-base    + sum-excise-base-sale-cur                                    d-supp-grp-fin.sale-excise-rubl    = d-supp-grp-fin.sale-excise-rubl    + sum-excise-rubl-sale-cur                                    d-supp-grp-fin.ov-base             = d-supp-grp-fin.ov-base             + (if varr-b = "base" then (sum-price-base-with-tax-sale-cur - sum-price-base-with-tax-sale) else (sum-price-rubl-with-tax-sale-cur - sum-price-rubl-with-tax-sale))                                  d-supp-grp-fin.ov-vat              = d-supp-grp-fin.ov-vat              + (if varr-b = "base" then (sum-price-base-with-tax-sale-cur - sum-price-base-with-tax-sale) else (sum-price-rubl-with-tax-sale-cur - sum-price-rubl-with-tax-sale)) * bf_doc-line.vat-pc / (100 + bf_doc-line.vat-pc).
      end.
            if lookup( "d-supp-slts-vats-cons", use-table ) > 0 then do:
        find first d-supp-slts-vats-cons where
                   d-supp-slts-vats-cons.supp-type  = bf_trn-doc.cli-type   and
                   d-supp-slts-vats-cons.supp-code  = bf_trn-doc.cli-code   and
                   d-supp-slts-vats-cons.vat-pc     = ?                     and
                   d-supp-slts-vats-cons.slt-pc     = ?                     and
                   d-supp-slts-vats-cons.purch-code = 1 no-error.
        if not available d-supp-slts-vats-cons then do:
          create d-supp-slts-vats-cons.
          assign d-supp-slts-vats-cons.vat-pc     = ?
                 d-supp-slts-vats-cons.slt-pc     = ?
                 d-supp-slts-vats-cons.supp-type  = bf_trn-doc.cli-type
                 d-supp-slts-vats-cons.supp-code  = bf_trn-doc.cli-code
                 d-supp-slts-vats-cons.supp-name  = bf_trn-doc.cli-name
                 d-supp-slts-vats-cons.purch-code = 1
                 d-supp-slts-vats-cons.purch-name = 'выкуп':U.
        end.
        assign d-supp-slts-vats-cons.fact-qnty           = d-supp-slts-vats-cons.fact-qnty           + varqnty                                   d-supp-slts-vats-cons.acc-base            = d-supp-slts-vats-cons.acc-base            + sum-acc-base                                            d-supp-slts-vats-cons.acc-rubl            = d-supp-slts-vats-cons.acc-rubl            + sum-acc-rubl                                            d-supp-slts-vats-cons.acc-vat-base        = d-supp-slts-vats-cons.acc-vat-base        + sum-acc-vat-base                                        d-supp-slts-vats-cons.acc-vat-rubl        = d-supp-slts-vats-cons.acc-vat-rubl        + sum-acc-vat-rubl                                        d-supp-slts-vats-cons.acc-slt-base        = d-supp-slts-vats-cons.acc-slt-base        + sum-acc-slt-base                                        d-supp-slts-vats-cons.acc-slt-rubl        = d-supp-slts-vats-cons.acc-slt-rubl        + sum-acc-slt-rubl                                        d-supp-slts-vats-cons.acc-road-tax-base   = d-supp-slts-vats-cons.acc-road-tax-base   + sum-acc-road-tax-base                                   d-supp-slts-vats-cons.acc-road-tax-rubl   = d-supp-slts-vats-cons.acc-road-tax-rubl   + sum-acc-road-tax-rubl                                   d-supp-slts-vats-cons.acc-excise-base     = d-supp-slts-vats-cons.acc-excise-base     + sum-acc-excise-base                                     d-supp-slts-vats-cons.acc-excise-rubl     = d-supp-slts-vats-cons.acc-excise-rubl     + sum-acc-excise-rubl                                     d-supp-slts-vats-cons.acc-transport-base  = d-supp-slts-vats-cons.acc-transport-base  + sum-acc-transport-base                                  d-supp-slts-vats-cons.acc-transport-rubl  = d-supp-slts-vats-cons.acc-transport-rubl  + sum-acc-transport-rubl                                  d-supp-slts-vats-cons.acc-other-base      = d-supp-slts-vats-cons.acc-other-base      + sum-acc-other-base                                      d-supp-slts-vats-cons.acc-other-rubl      = d-supp-slts-vats-cons.acc-other-rubl      + sum-acc-other-rubl                                      d-supp-slts-vats-cons.pay-base            = d-supp-slts-vats-cons.pay-base            + sum-price-base-with-tax-sale                                  d-supp-slts-vats-cons.pay-rubl            = d-supp-slts-vats-cons.pay-rubl            + sum-price-rubl-with-tax-sale                                  d-supp-slts-vats-cons.vat-base            = d-supp-slts-vats-cons.vat-base            + sum-vat-base-sale                                  d-supp-slts-vats-cons.vat-rubl            = d-supp-slts-vats-cons.vat-rubl            + sum-vat-rubl-sale                                  d-supp-slts-vats-cons.no-vat-base         = d-supp-slts-vats-cons.no-vat-base         + sum-price-base-with-tax-sale - sum-vat-base-sale                                  d-supp-slts-vats-cons.no-vat-rubl         = d-supp-slts-vats-cons.no-vat-rubl         + sum-price-rubl-with-tax-sale - sum-vat-rubl-sale                                  d-supp-slts-vats-cons.vat-base-buyer      = d-supp-slts-vats-cons.vat-base-buyer      + sum-vat-base-buyer                                  d-supp-slts-vats-cons.vat-rubl-buyer      = d-supp-slts-vats-cons.vat-rubl-buyer      + sum-vat-rubl-buyer                                  d-supp-slts-vats-cons.slt-base            = d-supp-slts-vats-cons.slt-base            + sum-slt-base-sale                                  d-supp-slts-vats-cons.slt-rubl            = d-supp-slts-vats-cons.slt-rubl            + sum-slt-rubl-sale                                  d-supp-slts-vats-cons.road-tax            = d-supp-slts-vats-cons.road-tax            + (if varr-b = "base" then sum-road-tax-base-sale else sum-road-tax-rubl-sale)                                  d-supp-slts-vats-cons.excise              = d-supp-slts-vats-cons.excise              + (if varr-b = "base" then sum-excise-base-sale   else sum-excise-rubl-sale)                                    d-supp-slts-vats-cons.sale-base           = d-supp-slts-vats-cons.sale-base           + sum-price-base-with-tax-sale-cur                                  d-supp-slts-vats-cons.sale-rubl           = d-supp-slts-vats-cons.sale-rubl           + sum-price-rubl-with-tax-sale-cur                                  d-supp-slts-vats-cons.sale-vat-base       = d-supp-slts-vats-cons.sale-vat-base       + sum-vat-base-sale-cur                                       d-supp-slts-vats-cons.sale-vat-rubl       = d-supp-slts-vats-cons.sale-vat-rubl       + sum-vat-rubl-sale-cur                                       d-supp-slts-vats-cons.sale-vat-buyer-base = d-supp-slts-vats-cons.sale-vat-buyer-base + sum-vat-base-buyer-cur                                      d-supp-slts-vats-cons.sale-vat-buyer-rubl = d-supp-slts-vats-cons.sale-vat-buyer-rubl + sum-vat-rubl-buyer-cur                                      d-supp-slts-vats-cons.sale-slt-base       = d-supp-slts-vats-cons.sale-slt-base       + sum-slt-base-sale-cur                                       d-supp-slts-vats-cons.sale-slt-rubl       = d-supp-slts-vats-cons.sale-slt-rubl       + sum-slt-rubl-sale-cur                                       d-supp-slts-vats-cons.sale-road-tax-base  = d-supp-slts-vats-cons.sale-road-tax-base  + sum-road-tax-base-sale-cur                                  d-supp-slts-vats-cons.sale-road-tax-rubl  = d-supp-slts-vats-cons.sale-road-tax-rubl  + sum-road-tax-rubl-sale-cur                                  d-supp-slts-vats-cons.sale-excise-base    = d-supp-slts-vats-cons.sale-excise-base    + sum-excise-base-sale-cur                                    d-supp-slts-vats-cons.sale-excise-rubl    = d-supp-slts-vats-cons.sale-excise-rubl    + sum-excise-rubl-sale-cur                                    d-supp-slts-vats-cons.ov-base             = d-supp-slts-vats-cons.ov-base             + (if varr-b = "base" then (sum-price-base-with-tax-sale-cur - sum-price-base-with-tax-sale) else (sum-price-rubl-with-tax-sale-cur - sum-price-rubl-with-tax-sale))                                  d-supp-slts-vats-cons.ov-vat              = d-supp-slts-vats-cons.ov-vat              + (if varr-b = "base" then (sum-price-base-with-tax-sale-cur - sum-price-base-with-tax-sale) else (sum-price-rubl-with-tax-sale-cur - sum-price-rubl-with-tax-sale)) * bf_doc-line.vat-pc / (100 + bf_doc-line.vat-pc).
      end.
            if lookup( "d-supp-slts-vats-cons-fin", use-table ) > 0 then do:
        find first d-supp-slts-vats-cons-fin where
                   d-supp-slts-vats-cons-fin.supp-type     = bf_trn-doc.cli-type   and
                   d-supp-slts-vats-cons-fin.supp-code     = bf_trn-doc.cli-code   and
                   d-supp-slts-vats-cons-fin.vat-pc        = ?                     and
                   d-supp-slts-vats-cons-fin.slt-pc        = ?                     and
                   d-supp-slts-vats-cons-fin.contract-code = 0                     and
                   d-supp-slts-vats-cons-fin.purch-code    = 1 no-error.
        if not available d-supp-slts-vats-cons-fin then do:
          create d-supp-slts-vats-cons-fin.
          assign d-supp-slts-vats-cons-fin.vat-pc        = ?
                 d-supp-slts-vats-cons-fin.slt-pc        = ?
                 d-supp-slts-vats-cons-fin.contract-code = 0
                 d-supp-slts-vats-cons-fin.supp-type     = bf_trn-doc.cli-type
                 d-supp-slts-vats-cons-fin.supp-code     = bf_trn-doc.cli-code
                 d-supp-slts-vats-cons-fin.supp-name     = bf_trn-doc.cli-name
                 d-supp-slts-vats-cons-fin.purch-code    = 1
                 d-supp-slts-vats-cons-fin.purch-name    = 'выкуп':U.
        end.
        assign d-supp-slts-vats-cons-fin.fact-qnty           = d-supp-slts-vats-cons-fin.fact-qnty           + varqnty                                   d-supp-slts-vats-cons-fin.acc-base            = d-supp-slts-vats-cons-fin.acc-base            + sum-acc-base                                            d-supp-slts-vats-cons-fin.acc-rubl            = d-supp-slts-vats-cons-fin.acc-rubl            + sum-acc-rubl                                            d-supp-slts-vats-cons-fin.acc-vat-base        = d-supp-slts-vats-cons-fin.acc-vat-base        + sum-acc-vat-base                                        d-supp-slts-vats-cons-fin.acc-vat-rubl        = d-supp-slts-vats-cons-fin.acc-vat-rubl        + sum-acc-vat-rubl                                        d-supp-slts-vats-cons-fin.acc-slt-base        = d-supp-slts-vats-cons-fin.acc-slt-base        + sum-acc-slt-base                                        d-supp-slts-vats-cons-fin.acc-slt-rubl        = d-supp-slts-vats-cons-fin.acc-slt-rubl        + sum-acc-slt-rubl                                        d-supp-slts-vats-cons-fin.acc-road-tax-base   = d-supp-slts-vats-cons-fin.acc-road-tax-base   + sum-acc-road-tax-base                                   d-supp-slts-vats-cons-fin.acc-road-tax-rubl   = d-supp-slts-vats-cons-fin.acc-road-tax-rubl   + sum-acc-road-tax-rubl                                   d-supp-slts-vats-cons-fin.acc-excise-base     = d-supp-slts-vats-cons-fin.acc-excise-base     + sum-acc-excise-base                                     d-supp-slts-vats-cons-fin.acc-excise-rubl     = d-supp-slts-vats-cons-fin.acc-excise-rubl     + sum-acc-excise-rubl                                     d-supp-slts-vats-cons-fin.acc-transport-base  = d-supp-slts-vats-cons-fin.acc-transport-base  + sum-acc-transport-base                                  d-supp-slts-vats-cons-fin.acc-transport-rubl  = d-supp-slts-vats-cons-fin.acc-transport-rubl  + sum-acc-transport-rubl                                  d-supp-slts-vats-cons-fin.acc-other-base      = d-supp-slts-vats-cons-fin.acc-other-base      + sum-acc-other-base                                      d-supp-slts-vats-cons-fin.acc-other-rubl      = d-supp-slts-vats-cons-fin.acc-other-rubl      + sum-acc-other-rubl                                      d-supp-slts-vats-cons-fin.pay-base            = d-supp-slts-vats-cons-fin.pay-base            + sum-price-base-with-tax-sale                                  d-supp-slts-vats-cons-fin.pay-rubl            = d-supp-slts-vats-cons-fin.pay-rubl            + sum-price-rubl-with-tax-sale                                  d-supp-slts-vats-cons-fin.vat-base            = d-supp-slts-vats-cons-fin.vat-base            + sum-vat-base-sale                                  d-supp-slts-vats-cons-fin.vat-rubl            = d-supp-slts-vats-cons-fin.vat-rubl            + sum-vat-rubl-sale                                  d-supp-slts-vats-cons-fin.no-vat-base         = d-supp-slts-vats-cons-fin.no-vat-base         + sum-price-base-with-tax-sale - sum-vat-base-sale                                  d-supp-slts-vats-cons-fin.no-vat-rubl         = d-supp-slts-vats-cons-fin.no-vat-rubl         + sum-price-rubl-with-tax-sale - sum-vat-rubl-sale                                  d-supp-slts-vats-cons-fin.vat-base-buyer      = d-supp-slts-vats-cons-fin.vat-base-buyer      + sum-vat-base-buyer                                  d-supp-slts-vats-cons-fin.vat-rubl-buyer      = d-supp-slts-vats-cons-fin.vat-rubl-buyer      + sum-vat-rubl-buyer                                  d-supp-slts-vats-cons-fin.slt-base            = d-supp-slts-vats-cons-fin.slt-base            + sum-slt-base-sale                                  d-supp-slts-vats-cons-fin.slt-rubl            = d-supp-slts-vats-cons-fin.slt-rubl            + sum-slt-rubl-sale                                  d-supp-slts-vats-cons-fin.road-tax            = d-supp-slts-vats-cons-fin.road-tax            + (if varr-b = "base" then sum-road-tax-base-sale else sum-road-tax-rubl-sale)                                  d-supp-slts-vats-cons-fin.excise              = d-supp-slts-vats-cons-fin.excise              + (if varr-b = "base" then sum-excise-base-sale   else sum-excise-rubl-sale)                                    d-supp-slts-vats-cons-fin.sale-base           = d-supp-slts-vats-cons-fin.sale-base           + sum-price-base-with-tax-sale-cur                                  d-supp-slts-vats-cons-fin.sale-rubl           = d-supp-slts-vats-cons-fin.sale-rubl           + sum-price-rubl-with-tax-sale-cur                                  d-supp-slts-vats-cons-fin.sale-vat-base       = d-supp-slts-vats-cons-fin.sale-vat-base       + sum-vat-base-sale-cur                                       d-supp-slts-vats-cons-fin.sale-vat-rubl       = d-supp-slts-vats-cons-fin.sale-vat-rubl       + sum-vat-rubl-sale-cur                                       d-supp-slts-vats-cons-fin.sale-vat-buyer-base = d-supp-slts-vats-cons-fin.sale-vat-buyer-base + sum-vat-base-buyer-cur                                      d-supp-slts-vats-cons-fin.sale-vat-buyer-rubl = d-supp-slts-vats-cons-fin.sale-vat-buyer-rubl + sum-vat-rubl-buyer-cur                                      d-supp-slts-vats-cons-fin.sale-slt-base       = d-supp-slts-vats-cons-fin.sale-slt-base       + sum-slt-base-sale-cur                                       d-supp-slts-vats-cons-fin.sale-slt-rubl       = d-supp-slts-vats-cons-fin.sale-slt-rubl       + sum-slt-rubl-sale-cur                                       d-supp-slts-vats-cons-fin.sale-road-tax-base  = d-supp-slts-vats-cons-fin.sale-road-tax-base  + sum-road-tax-base-sale-cur                                  d-supp-slts-vats-cons-fin.sale-road-tax-rubl  = d-supp-slts-vats-cons-fin.sale-road-tax-rubl  + sum-road-tax-rubl-sale-cur                                  d-supp-slts-vats-cons-fin.sale-excise-base    = d-supp-slts-vats-cons-fin.sale-excise-base    + sum-excise-base-sale-cur                                    d-supp-slts-vats-cons-fin.sale-excise-rubl    = d-supp-slts-vats-cons-fin.sale-excise-rubl    + sum-excise-rubl-sale-cur                                    d-supp-slts-vats-cons-fin.ov-base             = d-supp-slts-vats-cons-fin.ov-base             + (if varr-b = "base" then (sum-price-base-with-tax-sale-cur - sum-price-base-with-tax-sale) else (sum-price-rubl-with-tax-sale-cur - sum-price-rubl-with-tax-sale))                                  d-supp-slts-vats-cons-fin.ov-vat              = d-supp-slts-vats-cons-fin.ov-vat              + (if varr-b = "base" then (sum-price-base-with-tax-sale-cur - sum-price-base-with-tax-sale) else (sum-price-rubl-with-tax-sale-cur - sum-price-rubl-with-tax-sale)) * bf_doc-line.vat-pc / (100 + bf_doc-line.vat-pc).
      end.
    end.
  end.
end procedure.
procedure ClearAllTempTables :
  do on error undo, return error return-value :
    empty temp-table tt-title.
    empty temp-table d-supp.
    empty temp-table d-supp-grp.
    empty temp-table d-slt-vat.
    empty temp-table d-slt-vat-cons.
    empty temp-table d-slt-vat-cons-grp.
    empty temp-table d-supp-slts-vats-cons.
    empty temp-table d-slts-vats.
    empty temp-table d-slts-vats-cons.
    empty temp-table d-slts-vats-cons-grp.
    empty temp-table tt-title-fin.
    empty temp-table d-supp-fin.
    empty temp-table d-supp-grp-fin.
    empty temp-table d-slt-vat-cons-fin.
    empty temp-table d-slt-vat-cons-grp-fin.
    empty temp-table d-supp-slts-vats-cons-fin.
    empty temp-table d-slts-vats-cons-fin.
    empty temp-table d-slts-vats-cons-grp-fin.
  end.
end procedure.
procedure peresortica_gds-dtl:
do on error undo, return error return-value :
for each bf_gds-dtl no-lock where
         bf_gds-dtl.doc-code  = bf_doc-line.doc-code  and
         bf_gds-dtl.artic     = bf_doc-line.artic     and
         bf_gds-dtl.prod-code = bf_doc-line.prod-code and
         bf_gds-dtl.prod-type = bf_doc-line.prod-type on error undo, return error return-value :
  assign varqnty = ( if bf_trn-doc.doc-type = 'инв':U then bf_gds-dtl.doc-qnty else bf_gds-dtl.fact-qnty ).
if bf_trn-doc.ext-doc-type = 'ot':U or
   bf_trn-doc.ext-doc-type = ?                 then do:
  assign
   out-vatp-have-vat-slt = yes.
end.
else do:
  find first out-vatp_doc-attr no-lock
    where out-vatp_doc-attr.doc-code  = bf_trn-doc.doc-code
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
find first out-vatp_goods where out-vatp_goods.artic     = bf_doc-line.artic     and
                                   out-vatp_goods.prod-type = bf_doc-line.prod-type and
                                   out-vatp_goods.prod-code = bf_doc-line.prod-code no-lock.
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rootnode in g#library
  (input  bf_doc-line.artic
  ,input  bf_doc-line.prod-type
  ,input  bf_doc-line.prod-code
  ,output varroot-node
  ) no-error .
if error-status :error then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка при определении корневого признака товара" skip
    "Артикул" bf_doc-line.artic bf_doc-line.prod-type bf_doc-line.prod-code skip
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
    "Артикул" bf_doc-line.artic bf_doc-line.prod-type bf_doc-line.prod-code skip
    "Признак" varroot-node skip
    "Запрашивался атрибут" "empty-scale=request" skip
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  undo, return error .
end.
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varoutvprb
  )  .
if varoutvprb = "base":u then do:
  assign
        road-tax-base-sale    =  (if bf_doc-line.road-tax = ? then 0 else bf_doc-line.road-tax * 1)
    excise-base-sale      =  (if bf_doc-line.excise   = ? then 0 else bf_doc-line.excise   * 1)
  .
end.
else do:
  assign
        road-tax-base-sale    =  (if bf_doc-line.road-tax = ? then 0 else bf_doc-line.road-tax / bf_trn-doc.base-rate * bf_trn-doc.base-scale)
    excise-base-sale      =  (if bf_doc-line.excise   = ? then 0 else bf_doc-line.excise   / bf_trn-doc.base-rate * bf_trn-doc.base-scale)
  .
end.
if varoutvprb = "rubl":u then do:
  assign
        road-tax-rubl-sale    = (if bf_doc-line.road-tax = ? then 0 else bf_doc-line.road-tax * 1)
    excise-rubl-sale      = (if bf_doc-line.excise   = ? then 0 else bf_doc-line.excise   * 1) .
end.
else do:
  assign
        road-tax-rubl-sale    = (if bf_doc-line.road-tax = ? then 0 else bf_doc-line.road-tax * bf_trn-doc.base-rate / bf_trn-doc.base-scale)
    excise-rubl-sale      = (if bf_doc-line.excise   = ? then 0 else bf_doc-line.excise   * bf_trn-doc.base-rate / bf_trn-doc.base-scale) .
end.
assign
  varis-cons-parts-have =  no.
assign
  varfact-qnty       = 0
  varcons-qnty       = 0
  varprice-base-cons = 0
  varprice-rubl-cons = 0.
find first out-vatp_doc-line where
           out-vatp_doc-line.doc-code   = bf_trn-doc.doc-code
       and out-vatp_doc-line.artic      = bf_doc-line.artic
       and out-vatp_doc-line.prod-type  = bf_doc-line.prod-type
       and out-vatp_doc-line.prod-code  = bf_doc-line.prod-code no-lock no-error.
if available out-vatp_doc-line           and
  (out-vatp_doc-line.status_ = 'запрос':U or out-vatp_goods.gds-type = 'у':U) then do:
  assign
    varfact-qnty = out-vatp_doc-line.fact-qnty.
end.
else do:
  for each out-vatp_parts where out-vatp_parts.out-code   = bf_trn-doc.doc-code
                               and out-vatp_parts.obj-type   = bf_trn-doc.obj-type
                               and out-vatp_parts.obj-code   = bf_trn-doc.obj-code
                               and out-vatp_parts.artic      = bf_doc-line.artic
                               and out-vatp_parts.prod-type  = bf_doc-line.prod-type
                               and out-vatp_parts.prod-code  = bf_doc-line.prod-code no-lock :
    if out-vatp_parts.purch-code = 2 then do:
assign
  price-rubl-with-tax-loco = out-vatp_parts.price-rubl
  price-base-with-tax-loco = out-vatp_parts.price-base
.
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$".
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
    slt-base-sale               = (if out-vatp-have-vat-slt = no then 0 else bf_gds-dtl.price-base - bf_gds-dtl.discnt-base                - road-tax-base-sale) * bf_doc-line.SLT-pc / (100 + bf_doc-line.SLT-pc)
  vat-base-buyer              = (if out-vatp-have-vat-slt = no then 0 else bf_gds-dtl.price-base - bf_gds-dtl.discnt-base - (if out-vatp-have-vat-slt = no then 0 else bf_gds-dtl.price-base - bf_gds-dtl.discnt-base                - road-tax-base-sale) * bf_doc-line.SLT-pc / (100 + bf_doc-line.SLT-pc) - road-tax-base-sale) * bf_doc-line.vat-pc / (100 + bf_doc-line.vat-pc)
  discnt-base-sale            = bf_gds-dtl.discnt-base
  price-base-with-tax-sale    = (bf_gds-dtl.price-base - bf_gds-dtl.discnt-base)
    slt-rubl-sale               = (if out-vatp-have-vat-slt = no then 0 else bf_gds-dtl.price-rubl - bf_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * bf_doc-line.SLT-pc / (100 + bf_doc-line.SLT-pc)
  vat-rubl-buyer              = (if out-vatp-have-vat-slt = no then 0 else bf_gds-dtl.price-rubl - bf_gds-dtl.discnt-rubl - (if out-vatp-have-vat-slt = no then 0 else bf_gds-dtl.price-rubl - bf_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * bf_doc-line.SLT-pc / (100 + bf_doc-line.SLT-pc) - road-tax-rubl-sale) * bf_doc-line.vat-pc / (100 + bf_doc-line.vat-pc)
  discnt-rubl-sale            = bf_gds-dtl.discnt-rubl
  price-rubl-with-tax-sale    = (bf_gds-dtl.price-rubl - bf_gds-dtl.discnt-rubl)
  .
if bf_trn-doc.doc-type = 'инв':U then do:
  assign
    varfact-qnty = bf_gds-dtl.doc-qnty.
end.
else do:
  assign
    varfact-qnty = bf_gds-dtl.fact-qnty.
end.
if varis-cons-parts-have = no then do:
  assign
        vat-base-sale               = (if out-vatp-have-vat-slt = no then 0 else bf_gds-dtl.price-base - bf_gds-dtl.discnt-base - (if out-vatp-have-vat-slt = no then 0 else bf_gds-dtl.price-base - bf_gds-dtl.discnt-base                - road-tax-base-sale) * bf_doc-line.SLT-pc / (100 + bf_doc-line.SLT-pc) - road-tax-base-sale) * bf_doc-line.vat-pc / (100 + bf_doc-line.vat-pc)
        vat-rubl-sale               = (if out-vatp-have-vat-slt = no then 0 else bf_gds-dtl.price-rubl - bf_gds-dtl.discnt-rubl - (if out-vatp-have-vat-slt = no then 0 else bf_gds-dtl.price-rubl - bf_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * bf_doc-line.SLT-pc / (100 + bf_doc-line.SLT-pc) - road-tax-rubl-sale) * bf_doc-line.vat-pc / (100 + bf_doc-line.vat-pc).
end.
else do:
  if bf_trn-doc.doc-type = 'инв':U then do:
    assign
            vat-base-sale               = (if out-vatp-have-vat-slt = no then 0 else (((bf_gds-dtl.price-base - bf_gds-dtl.discnt-base) - (if out-vatp-have-vat-slt = no then 0 else bf_gds-dtl.price-base - bf_gds-dtl.discnt-base                - road-tax-base-sale) * bf_doc-line.SLT-pc / (100 + bf_doc-line.SLT-pc) - road-tax-base-sale - varprice-base-cons) * bf_doc-line.cons-vat-pc / (100 + bf_doc-line.cons-vat-pc) * bf_gds-dtl.doc-qnty * varcons-qnty / varfact-qnty + ((bf_gds-dtl.price-base - bf_gds-dtl.discnt-base) - (if out-vatp-have-vat-slt = no then 0 else bf_gds-dtl.price-base - bf_gds-dtl.discnt-base                - road-tax-base-sale) * bf_doc-line.SLT-pc / (100 + bf_doc-line.SLT-pc) - road-tax-base-sale) * bf_doc-line.vat-pc / (100 + bf_doc-line.vat-pc) * bf_gds-dtl.doc-qnty * (varfact-qnty - varcons-qnty) / varfact-qnty) / varfact-qnty)
            vat-rubl-sale               = (if out-vatp-have-vat-slt = no then 0 else (((bf_gds-dtl.price-rubl - bf_gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt = no then 0 else bf_gds-dtl.price-rubl - bf_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * bf_doc-line.SLT-pc / (100 + bf_doc-line.SLT-pc) - road-tax-rubl-sale - varprice-rubl-cons) * bf_doc-line.cons-vat-pc / (100 + bf_doc-line.cons-vat-pc) * bf_gds-dtl.doc-qnty * varcons-qnty / varfact-qnty + ((bf_gds-dtl.price-rubl - bf_gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt = no then 0 else bf_gds-dtl.price-rubl - bf_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * bf_doc-line.SLT-pc / (100 + bf_doc-line.SLT-pc) - road-tax-rubl-sale) * bf_doc-line.vat-pc / (100 + bf_doc-line.vat-pc) * bf_gds-dtl.doc-qnty * (varfact-qnty - varcons-qnty) / varfact-qnty) / varfact-qnty)
     .
  end.
  else do:
    assign
            vat-base-sale               = (if out-vatp-have-vat-slt = no then 0 else (((bf_gds-dtl.price-base - bf_gds-dtl.discnt-base) - (if out-vatp-have-vat-slt = no then 0 else bf_gds-dtl.price-base - bf_gds-dtl.discnt-base                - road-tax-base-sale) * bf_doc-line.SLT-pc / (100 + bf_doc-line.SLT-pc) - road-tax-base-sale - varprice-base-cons) * bf_doc-line.cons-vat-pc / (100 + bf_doc-line.cons-vat-pc) * bf_gds-dtl.fact-qnty * varcons-qnty / varfact-qnty + ((bf_gds-dtl.price-base - bf_gds-dtl.discnt-base) - (if out-vatp-have-vat-slt = no then 0 else bf_gds-dtl.price-base - bf_gds-dtl.discnt-base                - road-tax-base-sale) * bf_doc-line.SLT-pc / (100 + bf_doc-line.SLT-pc) - varprice-base-cons) * bf_doc-line.vat-pc / (100 + bf_doc-line.vat-pc) * bf_gds-dtl.fact-qnty * (varfact-qnty - varcons-qnty) / varfact-qnty) / varfact-qnty)
            vat-rubl-sale               = (if out-vatp-have-vat-slt = no then 0 else (((bf_gds-dtl.price-rubl - bf_gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt = no then 0 else bf_gds-dtl.price-rubl - bf_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * bf_doc-line.SLT-pc / (100 + bf_doc-line.SLT-pc) - road-tax-rubl-sale - varprice-rubl-cons) * bf_doc-line.cons-vat-pc / (100 + bf_doc-line.cons-vat-pc) * bf_gds-dtl.fact-qnty * varcons-qnty / varfact-qnty + ((bf_gds-dtl.price-rubl - bf_gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt = no then 0 else bf_gds-dtl.price-rubl - bf_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * bf_doc-line.SLT-pc / (100 + bf_doc-line.SLT-pc) - varprice-rubl-cons) * bf_doc-line.vat-pc / (100 + bf_doc-line.vat-pc) * bf_gds-dtl.fact-qnty * (varfact-qnty - varcons-qnty) / varfact-qnty) / varfact-qnty)
     .
  end.
end.
assign
price-base-without-tax-sale = price-base-with-tax-sale - vat-base-sale - slt-base-sale - road-tax-base-sale
price-rubl-without-tax-sale = price-rubl-with-tax-sale - vat-rubl-sale - slt-rubl-sale - road-tax-rubl-sale.
if bf_trn-doc.ext-doc-type = 'ot':U or
   bf_trn-doc.ext-doc-type = ?                 then do:
  assign
   out-vatp-have-vat-slt-cur = yes.
end.
else do:
  find first out-vatp_doc-attr-cur no-lock
    where out-vatp_doc-attr-cur.doc-code  = bf_trn-doc.doc-code
      and out-vatp_doc-attr-cur.attr-code = 'envd':U
      no-error .
  if not available out-vatp_doc-attr-cur then do:
    assign
      out-vatp-have-vat-slt-cur = yes.
  end.
  else do:
     out-vatp-have-vat-slt-cur = no.
  end.
end.
find first out-vatp_goods-cur where out-vatp_goods-cur.artic     = bf_doc-line.artic     and
                                   out-vatp_goods-cur.prod-type = bf_doc-line.prod-type and
                                   out-vatp_goods-cur.prod-code = bf_doc-line.prod-code no-lock.
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rootnode in g#library
  (input  bf_doc-line.artic
  ,input  bf_doc-line.prod-type
  ,input  bf_doc-line.prod-code
  ,output varroot-node-cur
  ) no-error .
if error-status :error then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка при определении корневого признака товара" skip
    "Артикул" bf_doc-line.artic bf_doc-line.prod-type bf_doc-line.prod-code skip
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  undo, return error .
end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prtat in g#library
  (input  varroot-node-cur
  ,input  'empty-scale=request'
  ,output varempty-scale-cur
  ) no-error .
if error-status :error then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка при определении атрибута признака" skip
    "Артикул" bf_doc-line.artic bf_doc-line.prod-type bf_doc-line.prod-code skip
    "Признак" varroot-node-cur skip
    "Запрашивался атрибут" "empty-scale=request" skip
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  undo, return error .
end.
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varoutvprb-cur
  )  .
if varoutvprb-cur = "base":u then do:
  assign
        road-tax-base-sale-cur    =  (if bf_doc-line.road-tax = ? then 0 else bf_doc-line.road-tax * 1)
    excise-base-sale-cur      =  (if bf_doc-line.excise   = ? then 0 else bf_doc-line.excise   * 1)
  .
end.
else do:
  assign
        road-tax-base-sale-cur    =  (if bf_doc-line.road-tax = ? then 0 else bf_doc-line.road-tax / bf_trn-doc.base-rate * bf_trn-doc.base-scale)
    excise-base-sale-cur      =  (if bf_doc-line.excise   = ? then 0 else bf_doc-line.excise   / bf_trn-doc.base-rate * bf_trn-doc.base-scale)
  .
end.
if varoutvprb-cur = "rubl":u then do:
  assign
        road-tax-rubl-sale-cur    = (if bf_doc-line.road-tax = ? then 0 else bf_doc-line.road-tax * 1)
    excise-rubl-sale-cur      = (if bf_doc-line.excise   = ? then 0 else bf_doc-line.excise   * 1) .
end.
else do:
  assign
        road-tax-rubl-sale-cur    = (if bf_doc-line.road-tax = ? then 0 else bf_doc-line.road-tax * bf_trn-doc.base-rate / bf_trn-doc.base-scale)
    excise-rubl-sale-cur      = (if bf_doc-line.excise   = ? then 0 else bf_doc-line.excise   * bf_trn-doc.base-rate / bf_trn-doc.base-scale) .
end.
assign
  varis-cons-parts-have-cur =  no.
assign
  varfact-qnty-cur       = 0
  varcons-qnty-cur       = 0
  varprice-base-cons-cur = 0
  varprice-rubl-cons-cur = 0.
find first out-vatp_doc-line-cur where
           out-vatp_doc-line-cur.doc-code   = bf_trn-doc.doc-code
       and out-vatp_doc-line-cur.artic      = bf_doc-line.artic
       and out-vatp_doc-line-cur.prod-type  = bf_doc-line.prod-type
       and out-vatp_doc-line-cur.prod-code  = bf_doc-line.prod-code no-lock no-error.
if available out-vatp_doc-line-cur           and
  (out-vatp_doc-line-cur.status_ = 'запрос':U or out-vatp_goods-cur.gds-type = 'у':U) then do:
  assign
    varfact-qnty-cur = out-vatp_doc-line-cur.fact-qnty.
end.
else do:
  for each out-vatp_parts-cur where out-vatp_parts-cur.out-code   = bf_trn-doc.doc-code
                               and out-vatp_parts-cur.obj-type   = bf_trn-doc.obj-type
                               and out-vatp_parts-cur.obj-code   = bf_trn-doc.obj-code
                               and out-vatp_parts-cur.artic      = bf_doc-line.artic
                               and out-vatp_parts-cur.prod-type  = bf_doc-line.prod-type
                               and out-vatp_parts-cur.prod-code  = bf_doc-line.prod-code no-lock :
    if out-vatp_parts-cur.purch-code = 2 then do:
assign
  price-rubl-with-tax-loco-cur = out-vatp_parts-cur.price-rubl
  price-base-with-tax-loco-cur = out-vatp_parts-cur.price-base
.
define variable vss-include-info26 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprbo-cur
  )  .
  if out-vatp_parts-cur.out-code = 'free-zone':U     or
     out-vatp_parts-cur.out-code = 'out-zone':U   or
     out-vatp_parts-cur.doc-type = 'акт':U then do:
    assign
      in-vatp-have-vat-slto-cur = yes.
  end.
  else do:
    find first in-vatp_doc-attro-cur no-lock
      where in-vatp_doc-attro-cur.doc-code  = out-vatp_parts-cur.out-code
        and in-vatp_doc-attro-cur.attr-code = 'envd':U
      no-error .
    if not available in-vatp_doc-attro-cur then do:
      assign
        in-vatp-have-vat-slto-cur = yes.
    end.
    else do:
         in-vatp-have-vat-slto-cur = no.
    end.
  end.
  assign
   price-cli-with-tax-loco-cur = out-vatp_parts-cur.price-cli
   cli-base-rateo-cur          = out-vatp_parts-cur.cli-base-rate.
  ASSIGN   road-tax-base-loco-cur  = (if out-vatp_parts-cur.road-tax-base  = ? then 0 else out-vatp_parts-cur.road-tax-base)
           road-tax-rubl-loco-cur  = (if out-vatp_parts-cur.road-tax-rubl  = ? then 0 else out-vatp_parts-cur.road-tax-rubl).
  ASSIGN  transport-base-loco-cur = (if out-vatp_parts-cur.transport-base = ? then 0 else out-vatp_parts-cur.transport-base)
          transport-rubl-loco-cur = (if out-vatp_parts-cur.transport-rubl = ? then 0 else out-vatp_parts-cur.transport-rubl)
          other-base-loco-cur     = (if out-vatp_parts-cur.other-base     = ? then 0 else out-vatp_parts-cur.other-base)
          other-rubl-loco-cur     = (if out-vatp_parts-cur.other-rubl     = ? then 0 else out-vatp_parts-cur.other-rubl)
          vat-pc-loco-cur         = (if out-vatp_parts-cur.vat-pc         = ? then 0 else out-vatp_parts-cur.vat-pc)
          slt-pc-loco-cur         = (if out-vatp_parts-cur.slt-pc         = ? then 0 else out-vatp_parts-cur.slt-pc).
          ASSIGN   slt-base-loco-cur    = (if in-vatp-have-vat-slto-cur = no then 0 else (price-base-with-tax-loco-cur - ((if road-tax-base-loco-cur  = ? then 0 else road-tax-base-loco-cur) + (if transport-base-loco-cur = ? then 0 else transport-base-loco-cur) + (if other-base-loco-cur = ? then 0 else other-base-loco-cur)))                           * slt-pc-loco-cur / (100 + slt-pc-loco-cur))                        vat-base-loco-cur    = (if in-vatp-have-vat-slto-cur = no then 0 else (price-base-with-tax-loco-cur - ((if road-tax-base-loco-cur  = ? then 0 else road-tax-base-loco-cur) + (if transport-base-loco-cur = ? then 0 else transport-base-loco-cur) + (if other-base-loco-cur = ? then 0 else other-base-loco-cur))) * (1 - slt-pc-loco-cur / (100 + slt-pc-loco-cur)) * vat-pc-loco-cur / (100 + vat-pc-loco-cur)).
    ASSIGN   slt-rubl-loco-cur    = (if in-vatp-have-vat-slto-cur = no then 0 else (price-rubl-with-tax-loco-cur - ((if road-tax-rubl-loco-cur  = ? then 0 else road-tax-rubl-loco-cur) + (if transport-rubl-loco-cur = ? then 0 else transport-rubl-loco-cur) + (if other-rubl-loco-cur = ? then 0 else other-rubl-loco-cur)))                           * slt-pc-loco-cur / (100 + slt-pc-loco-cur))                        vat-rubl-loco-cur    = (if in-vatp-have-vat-slto-cur = no then 0 else (price-rubl-with-tax-loco-cur - ((if road-tax-rubl-loco-cur  = ? then 0 else road-tax-rubl-loco-cur) + (if transport-rubl-loco-cur = ? then 0 else transport-rubl-loco-cur) + (if other-rubl-loco-cur = ? then 0 else other-rubl-loco-cur))) * (1 - slt-pc-loco-cur / (100 + slt-pc-loco-cur)) * vat-pc-loco-cur / (100 + vat-pc-loco-cur)).
  assign
    exch-rate-cli-loco-cur = (out-vatp_parts-cur.price-rubl - transport-rubl-loco-cur - other-rubl-loco-cur - road-tax-rubl-loco-cur - (if out-vatp_parts-cur.vat-type <> 'в т. ч.':U then vat-rubl-loco-cur else 0) - (if out-vatp_parts-cur.slt-type <> 'в т. ч.':U then slt-rubl-loco-cur else 0)) / out-vatp_parts-cur.price-cli .
  assign
    slt-cli-loco-cur        = slt-rubl-loco-cur       / exch-rate-cli-loco-cur
    vat-cli-loco-cur        = vat-rubl-loco-cur       / exch-rate-cli-loco-cur
    road-tax-cli-loco-cur   = road-tax-rubl-loco-cur  / exch-rate-cli-loco-cur
    transport-cli-loco-cur  = 0
    other-cli-loco-cur      = 0
  .
ASSIGN
          price-base-without-tax-loco-cur = price-base-with-tax-loco-cur - vat-base-loco-cur - slt-base-loco-cur - ((if road-tax-base-loco-cur  = ? then 0 else road-tax-base-loco-cur) + (if transport-base-loco-cur = ? then 0 else transport-base-loco-cur) + (if other-base-loco-cur = ? then 0 else other-base-loco-cur))
    price-rubl-without-tax-loco-cur = price-rubl-with-tax-loco-cur - vat-rubl-loco-cur - slt-rubl-loco-cur - ((if road-tax-rubl-loco-cur  = ? then 0 else road-tax-rubl-loco-cur) + (if transport-rubl-loco-cur = ? then 0 else transport-rubl-loco-cur) + (if other-rubl-loco-cur = ? then 0 else other-rubl-loco-cur))
.
      assign
        varprice-base-cons-cur = varprice-base-cons-cur + (price-base-with-tax-loco-cur - (if road-tax-base-loco-cur = ? then 0 else road-tax-base-loco-cur))* out-vatp_parts-cur.fact-qnty
        varprice-rubl-cons-cur = varprice-rubl-cons-cur + (price-rubl-with-tax-loco-cur - (if road-tax-rubl-loco-cur = ? then 0 else road-tax-rubl-loco-cur))* out-vatp_parts-cur.fact-qnty.
      assign
        varis-cons-parts-have-cur = yes
        varcons-qnty-cur          = varcons-qnty-cur + out-vatp_parts-cur.fact-qnty.
    end.
    assign
      varfact-qnty-cur = varfact-qnty-cur + out-vatp_parts-cur.fact-qnty.
  end.
end.
assign
  varprice-base-cons-cur = varprice-base-cons-cur / varcons-qnty-cur
  varprice-rubl-cons-cur = varprice-rubl-cons-cur / varcons-qnty-cur.
if varprice-base-cons-cur = ? then do:
  assign
    varprice-base-cons-cur = 0.
end.
if varprice-rubl-cons-cur = ? then do:
  assign
    varprice-rubl-cons-cur = 0.
end.
assign
    slt-base-sale-cur               = (if out-vatp-have-vat-slt-cur = no then 0 else bf_gds-dtl.price-base - bf_gds-dtl.discnt-base                - road-tax-base-sale-cur) * bf_doc-line.SLT-pc / (100 + bf_doc-line.SLT-pc)
  vat-base-buyer-cur              = (if out-vatp-have-vat-slt-cur = no then 0 else bf_gds-dtl.price-base - bf_gds-dtl.discnt-base - (if out-vatp-have-vat-slt-cur = no then 0 else bf_gds-dtl.price-base - bf_gds-dtl.discnt-base                - road-tax-base-sale-cur) * bf_doc-line.SLT-pc / (100 + bf_doc-line.SLT-pc) - road-tax-base-sale-cur) * bf_doc-line.vat-pc / (100 + bf_doc-line.vat-pc)
  discnt-base-sale-cur            = bf_gds-dtl.discnt-base
  price-base-with-tax-sale-cur    = (bf_gds-dtl.price-base - bf_gds-dtl.discnt-base)
    slt-rubl-sale-cur               = (if out-vatp-have-vat-slt-cur = no then 0 else bf_gds-dtl.price-rubl - bf_gds-dtl.discnt-rubl                - road-tax-rubl-sale-cur) * bf_doc-line.SLT-pc / (100 + bf_doc-line.SLT-pc)
  vat-rubl-buyer-cur              = (if out-vatp-have-vat-slt-cur = no then 0 else bf_gds-dtl.price-rubl - bf_gds-dtl.discnt-rubl - (if out-vatp-have-vat-slt-cur = no then 0 else bf_gds-dtl.price-rubl - bf_gds-dtl.discnt-rubl                - road-tax-rubl-sale-cur) * bf_doc-line.SLT-pc / (100 + bf_doc-line.SLT-pc) - road-tax-rubl-sale-cur) * bf_doc-line.vat-pc / (100 + bf_doc-line.vat-pc)
  discnt-rubl-sale-cur            = bf_gds-dtl.discnt-rubl
  price-rubl-with-tax-sale-cur    = (bf_gds-dtl.price-rubl - bf_gds-dtl.discnt-rubl)
  .
if bf_trn-doc.doc-type = 'инв':U then do:
  assign
    varfact-qnty-cur = bf_gds-dtl.doc-qnty.
end.
else do:
  assign
    varfact-qnty-cur = bf_gds-dtl.fact-qnty.
end.
if varis-cons-parts-have-cur = no then do:
  assign
        vat-base-sale-cur               = (if out-vatp-have-vat-slt-cur = no then 0 else bf_gds-dtl.price-base - bf_gds-dtl.discnt-base - (if out-vatp-have-vat-slt-cur = no then 0 else bf_gds-dtl.price-base - bf_gds-dtl.discnt-base                - road-tax-base-sale-cur) * bf_doc-line.SLT-pc / (100 + bf_doc-line.SLT-pc) - road-tax-base-sale-cur) * bf_doc-line.vat-pc / (100 + bf_doc-line.vat-pc)
        vat-rubl-sale-cur               = (if out-vatp-have-vat-slt-cur = no then 0 else bf_gds-dtl.price-rubl - bf_gds-dtl.discnt-rubl - (if out-vatp-have-vat-slt-cur = no then 0 else bf_gds-dtl.price-rubl - bf_gds-dtl.discnt-rubl                - road-tax-rubl-sale-cur) * bf_doc-line.SLT-pc / (100 + bf_doc-line.SLT-pc) - road-tax-rubl-sale-cur) * bf_doc-line.vat-pc / (100 + bf_doc-line.vat-pc).
end.
else do:
  if bf_trn-doc.doc-type = 'инв':U then do:
    assign
            vat-base-sale-cur               = (if out-vatp-have-vat-slt-cur = no then 0 else (((bf_gds-dtl.price-base - bf_gds-dtl.discnt-base) - (if out-vatp-have-vat-slt-cur = no then 0 else bf_gds-dtl.price-base - bf_gds-dtl.discnt-base                - road-tax-base-sale-cur) * bf_doc-line.SLT-pc / (100 + bf_doc-line.SLT-pc) - road-tax-base-sale-cur - varprice-base-cons-cur) * bf_doc-line.cons-vat-pc / (100 + bf_doc-line.cons-vat-pc) * bf_gds-dtl.doc-qnty * varcons-qnty-cur / varfact-qnty-cur + ((bf_gds-dtl.price-base - bf_gds-dtl.discnt-base) - (if out-vatp-have-vat-slt-cur = no then 0 else bf_gds-dtl.price-base - bf_gds-dtl.discnt-base                - road-tax-base-sale-cur) * bf_doc-line.SLT-pc / (100 + bf_doc-line.SLT-pc) - road-tax-base-sale-cur) * bf_doc-line.vat-pc / (100 + bf_doc-line.vat-pc) * bf_gds-dtl.doc-qnty * (varfact-qnty-cur - varcons-qnty-cur) / varfact-qnty-cur) / varfact-qnty-cur)
            vat-rubl-sale-cur               = (if out-vatp-have-vat-slt-cur = no then 0 else (((bf_gds-dtl.price-rubl - bf_gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt-cur = no then 0 else bf_gds-dtl.price-rubl - bf_gds-dtl.discnt-rubl                - road-tax-rubl-sale-cur) * bf_doc-line.SLT-pc / (100 + bf_doc-line.SLT-pc) - road-tax-rubl-sale-cur - varprice-rubl-cons-cur) * bf_doc-line.cons-vat-pc / (100 + bf_doc-line.cons-vat-pc) * bf_gds-dtl.doc-qnty * varcons-qnty-cur / varfact-qnty-cur + ((bf_gds-dtl.price-rubl - bf_gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt-cur = no then 0 else bf_gds-dtl.price-rubl - bf_gds-dtl.discnt-rubl                - road-tax-rubl-sale-cur) * bf_doc-line.SLT-pc / (100 + bf_doc-line.SLT-pc) - road-tax-rubl-sale-cur) * bf_doc-line.vat-pc / (100 + bf_doc-line.vat-pc) * bf_gds-dtl.doc-qnty * (varfact-qnty-cur - varcons-qnty-cur) / varfact-qnty-cur) / varfact-qnty-cur)
     .
  end.
  else do:
    assign
            vat-base-sale-cur               = (if out-vatp-have-vat-slt-cur = no then 0 else (((bf_gds-dtl.price-base - bf_gds-dtl.discnt-base) - (if out-vatp-have-vat-slt-cur = no then 0 else bf_gds-dtl.price-base - bf_gds-dtl.discnt-base                - road-tax-base-sale-cur) * bf_doc-line.SLT-pc / (100 + bf_doc-line.SLT-pc) - road-tax-base-sale-cur - varprice-base-cons-cur) * bf_doc-line.cons-vat-pc / (100 + bf_doc-line.cons-vat-pc) * bf_gds-dtl.fact-qnty * varcons-qnty-cur / varfact-qnty-cur + ((bf_gds-dtl.price-base - bf_gds-dtl.discnt-base) - (if out-vatp-have-vat-slt-cur = no then 0 else bf_gds-dtl.price-base - bf_gds-dtl.discnt-base                - road-tax-base-sale-cur) * bf_doc-line.SLT-pc / (100 + bf_doc-line.SLT-pc) - varprice-base-cons-cur) * bf_doc-line.vat-pc / (100 + bf_doc-line.vat-pc) * bf_gds-dtl.fact-qnty * (varfact-qnty-cur - varcons-qnty-cur) / varfact-qnty-cur) / varfact-qnty-cur)
            vat-rubl-sale-cur               = (if out-vatp-have-vat-slt-cur = no then 0 else (((bf_gds-dtl.price-rubl - bf_gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt-cur = no then 0 else bf_gds-dtl.price-rubl - bf_gds-dtl.discnt-rubl                - road-tax-rubl-sale-cur) * bf_doc-line.SLT-pc / (100 + bf_doc-line.SLT-pc) - road-tax-rubl-sale-cur - varprice-rubl-cons-cur) * bf_doc-line.cons-vat-pc / (100 + bf_doc-line.cons-vat-pc) * bf_gds-dtl.fact-qnty * varcons-qnty-cur / varfact-qnty-cur + ((bf_gds-dtl.price-rubl - bf_gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt-cur = no then 0 else bf_gds-dtl.price-rubl - bf_gds-dtl.discnt-rubl                - road-tax-rubl-sale-cur) * bf_doc-line.SLT-pc / (100 + bf_doc-line.SLT-pc) - varprice-rubl-cons-cur) * bf_doc-line.vat-pc / (100 + bf_doc-line.vat-pc) * bf_gds-dtl.fact-qnty * (varfact-qnty-cur - varcons-qnty-cur) / varfact-qnty-cur) / varfact-qnty-cur)
     .
  end.
end.
assign
price-base-without-tax-sale-cur = price-base-with-tax-sale-cur - vat-base-sale-cur - slt-base-sale-cur - road-tax-base-sale-cur
price-rubl-without-tax-sale-cur = price-rubl-with-tax-sale-cur - vat-rubl-sale-cur - slt-rubl-sale-cur - road-tax-rubl-sale-cur.
  assign sum-price-rubl-with-tax-sale     = sum-price-rubl-with-tax-sale     + price-rubl-with-tax-sale     * varqnty
         sum-price-base-with-tax-sale     = sum-price-base-with-tax-sale     + price-base-with-tax-sale     * varqnty
         sum-vat-base-sale                = sum-vat-base-sale                + vat-base-sale                * varqnty
         sum-vat-rubl-sale                = sum-vat-rubl-sale                + vat-rubl-sale                * varqnty
         sum-vat-base-buyer               = sum-vat-base-buyer               + vat-base-buyer               * varqnty
         sum-vat-rubl-buyer               = sum-vat-rubl-buyer               + vat-rubl-buyer               * varqnty
         sum-slt-base-sale                = sum-slt-base-sale                + slt-base-sale                * varqnty
         sum-slt-rubl-sale                = sum-slt-rubl-sale                + slt-rubl-sale                * varqnty
         sum-road-tax-base-sale           = sum-road-tax-base-sale           + road-tax-base-sale           * varqnty
         sum-road-tax-rubl-sale           = sum-road-tax-rubl-sale           + road-tax-rubl-sale           * varqnty
         sum-excise-base-sale             = sum-excise-base-sale             + excise-base-sale             * varqnty
         sum-excise-rubl-sale             = sum-excise-rubl-sale             + excise-rubl-sale             * varqnty
         sum-discnt-base-sale             = sum-discnt-base-sale             + discnt-base-sale             * varqnty
         sum-discnt-rubl-sale             = sum-discnt-rubl-sale             + discnt-rubl-sale             * varqnty
         sum-price-rubl-with-tax-sale-cur = sum-price-rubl-with-tax-sale-cur + price-rubl-with-tax-sale-cur * varqnty
         sum-price-base-with-tax-sale-cur = sum-price-base-with-tax-sale-cur + price-base-with-tax-sale-cur * varqnty
         sum-vat-base-sale-cur            = sum-vat-base-sale-cur            + vat-base-sale-cur            * varqnty
         sum-vat-rubl-sale-cur            = sum-vat-rubl-sale-cur            + vat-rubl-sale-cur            * varqnty
         sum-vat-base-buyer-cur           = sum-vat-base-buyer-cur           + vat-base-buyer-cur           * varqnty
         sum-vat-rubl-buyer-cur           = sum-vat-rubl-buyer-cur           + vat-rubl-buyer-cur           * varqnty
         sum-slt-base-sale-cur            = sum-slt-base-sale-cur            + slt-base-sale-cur            * varqnty
         sum-slt-rubl-sale-cur            = sum-slt-rubl-sale-cur            + slt-rubl-sale-cur            * varqnty
         sum-road-tax-base-sale-cur       = sum-road-tax-base-sale-cur       + road-tax-base-sale-cur       * varqnty
         sum-road-tax-rubl-sale-cur       = sum-road-tax-rubl-sale-cur       + road-tax-rubl-sale-cur       * varqnty
         sum-excise-base-sale-cur         = sum-excise-base-sale-cur         + excise-base-sale-cur         * varqnty
         sum-excise-rubl-sale-cur         = sum-excise-rubl-sale-cur         + excise-rubl-sale-cur         * varqnty
         sum-discnt-base-sale-cur         = sum-discnt-base-sale-cur         + discnt-base-sale-cur         * varqnty
         sum-discnt-rubl-sale-cur         = sum-discnt-rubl-sale-cur         + discnt-rubl-sale-cur         * varqnty.
end.
if sum-price-rubl-with-tax-sale = 0 and sum-price-rubl-with-tax-sale-cur = 0 then do:
  return "line":u.
end.
else do:
      find first tt-title where tt-title.purch-code = ? no-error.
  if not available tt-title then do:
    create tt-title.
    assign tt-title.purch-code = ?
           tt-title.purch-name = ?.
    assign tt-title.fact-qnty           = 0                             tt-title.acc-base            = 0                             tt-title.acc-rubl            = 0                             tt-title.acc-vat-base        = 0                             tt-title.acc-vat-rubl        = 0                             tt-title.acc-slt-base        = 0                             tt-title.acc-slt-rubl        = 0                             tt-title.acc-road-tax-base   = 0                             tt-title.acc-road-tax-rubl   = 0                             tt-title.acc-excise-base     = 0                             tt-title.acc-excise-rubl     = 0                             tt-title.acc-transport-base  = 0                             tt-title.acc-transport-rubl  = 0                             tt-title.acc-other-base      = 0                             tt-title.acc-other-rubl      = 0                             tt-title.pay-base            = tt-title.pay-base            + sum-price-base-with-tax-sale                             tt-title.pay-rubl            = tt-title.pay-rubl            + sum-price-rubl-with-tax-sale                             tt-title.no-vat-base         = tt-title.no-vat-base         + sum-price-base-with-tax-sale - sum-vat-base-sale                             tt-title.no-vat-rubl         = tt-title.no-vat-rubl         + sum-price-rubl-with-tax-sale - sum-vat-rubl-sale                             tt-title.vat-base            = tt-title.vat-base            + sum-vat-base-sale                              tt-title.vat-rubl            = tt-title.vat-rubl            + sum-vat-rubl-sale                              tt-title.vat-base-buyer      = tt-title.vat-base-buyer      + sum-vat-base-buyer                             tt-title.vat-rubl-buyer      = tt-title.vat-rubl-buyer      + sum-vat-rubl-buyer                             tt-title.slt-base            = tt-title.slt-base            + sum-slt-base-sale                             tt-title.slt-rubl            = tt-title.slt-rubl            + sum-slt-rubl-sale                             tt-title.road-tax            = tt-title.road-tax            + (if varr-b = "base" then sum-road-tax-base-sale else sum-road-tax-rubl-sale)                             tt-title.excise              = tt-title.excise              + (if varr-b = "base" then sum-excise-base-sale   else sum-excise-rubl-sale )                             tt-title.sale-base           = tt-title.sale-base           + sum-price-base-with-tax-sale-cur                             tt-title.sale-rubl           = tt-title.sale-rubl           + sum-price-rubl-with-tax-sale-cur                             tt-title.sale-vat-base       = tt-title.sale-vat-base       + sum-vat-base-sale-cur                                        tt-title.sale-vat-rubl       = tt-title.sale-vat-rubl       + sum-vat-rubl-sale-cur                                        tt-title.sale-vat-buyer-base = tt-title.sale-vat-buyer-base + sum-vat-base-buyer-cur                                       tt-title.sale-vat-buyer-rubl = tt-title.sale-vat-buyer-rubl + sum-vat-rubl-buyer-cur                                       tt-title.sale-slt-base       = tt-title.sale-slt-base       + sum-slt-base-sale-cur                                        tt-title.sale-slt-rubl       = tt-title.sale-slt-rubl       + sum-slt-rubl-sale-cur                                        tt-title.sale-road-tax-base  = tt-title.sale-road-tax-base  + sum-road-tax-base-sale-cur                                   tt-title.sale-road-tax-rubl  = tt-title.sale-road-tax-rubl  + sum-road-tax-rubl-sale-cur                                   tt-title.sale-excise-base    = tt-title.sale-excise-base    + sum-excise-base-sale-cur                                     tt-title.sale-excise-rubl    = tt-title.sale-excise-rubl    + sum-excise-rubl-sale-cur                                     tt-title.ov-base             = tt-title.ov-base             + (if varr-b = "base" then (sum-price-base-with-tax-sale-cur - sum-price-base-with-tax-sale) else (sum-price-rubl-with-tax-sale-cur - sum-price-rubl-with-tax-sale))                             tt-title.ov-vat              = tt-title.ov-vat              + (if varr-b = "base" then (sum-price-base-with-tax-sale-cur - sum-price-base-with-tax-sale) else (sum-price-rubl-with-tax-sale-cur - sum-price-rubl-with-tax-sale)) * bf_doc-line.vat-pc / (100 + bf_doc-line.vat-pc).
  end.
    if varcalc-title-fin = yes then do:
    find first tt-title-fin where
               tt-title-fin.purch-code    = ? and
               tt-title-fin.contract-code = 0 no-error.
    if not available tt-title-fin then do:
      create tt-title-fin.
      assign tt-title-fin.purch-code    = ?
             tt-title-fin.purch-name    = ?
             tt-title-fin.contract-code = 0.
      assign tt-title-fin.fact-qnty           = 0                             tt-title-fin.acc-base            = 0                             tt-title-fin.acc-rubl            = 0                             tt-title-fin.acc-vat-base        = 0                             tt-title-fin.acc-vat-rubl        = 0                             tt-title-fin.acc-slt-base        = 0                             tt-title-fin.acc-slt-rubl        = 0                             tt-title-fin.acc-road-tax-base   = 0                             tt-title-fin.acc-road-tax-rubl   = 0                             tt-title-fin.acc-excise-base     = 0                             tt-title-fin.acc-excise-rubl     = 0                             tt-title-fin.acc-transport-base  = 0                             tt-title-fin.acc-transport-rubl  = 0                             tt-title-fin.acc-other-base      = 0                             tt-title-fin.acc-other-rubl      = 0                             tt-title-fin.pay-base            = tt-title-fin.pay-base            + sum-price-base-with-tax-sale                             tt-title-fin.pay-rubl            = tt-title-fin.pay-rubl            + sum-price-rubl-with-tax-sale                             tt-title-fin.no-vat-base         = tt-title-fin.no-vat-base         + sum-price-base-with-tax-sale - sum-vat-base-sale                             tt-title-fin.no-vat-rubl         = tt-title-fin.no-vat-rubl         + sum-price-rubl-with-tax-sale - sum-vat-rubl-sale                             tt-title-fin.vat-base            = tt-title-fin.vat-base            + sum-vat-base-sale                              tt-title-fin.vat-rubl            = tt-title-fin.vat-rubl            + sum-vat-rubl-sale                              tt-title-fin.vat-base-buyer      = tt-title-fin.vat-base-buyer      + sum-vat-base-buyer                             tt-title-fin.vat-rubl-buyer      = tt-title-fin.vat-rubl-buyer      + sum-vat-rubl-buyer                             tt-title-fin.slt-base            = tt-title-fin.slt-base            + sum-slt-base-sale                             tt-title-fin.slt-rubl            = tt-title-fin.slt-rubl            + sum-slt-rubl-sale                             tt-title-fin.road-tax            = tt-title-fin.road-tax            + (if varr-b = "base" then sum-road-tax-base-sale else sum-road-tax-rubl-sale)                             tt-title-fin.excise              = tt-title-fin.excise              + (if varr-b = "base" then sum-excise-base-sale   else sum-excise-rubl-sale )                             tt-title-fin.sale-base           = tt-title-fin.sale-base           + sum-price-base-with-tax-sale-cur                             tt-title-fin.sale-rubl           = tt-title-fin.sale-rubl           + sum-price-rubl-with-tax-sale-cur                             tt-title-fin.sale-vat-base       = tt-title-fin.sale-vat-base       + sum-vat-base-sale-cur                                        tt-title-fin.sale-vat-rubl       = tt-title-fin.sale-vat-rubl       + sum-vat-rubl-sale-cur                                        tt-title-fin.sale-vat-buyer-base = tt-title-fin.sale-vat-buyer-base + sum-vat-base-buyer-cur                                       tt-title-fin.sale-vat-buyer-rubl = tt-title-fin.sale-vat-buyer-rubl + sum-vat-rubl-buyer-cur                                       tt-title-fin.sale-slt-base       = tt-title-fin.sale-slt-base       + sum-slt-base-sale-cur                                        tt-title-fin.sale-slt-rubl       = tt-title-fin.sale-slt-rubl       + sum-slt-rubl-sale-cur                                        tt-title-fin.sale-road-tax-base  = tt-title-fin.sale-road-tax-base  + sum-road-tax-base-sale-cur                                   tt-title-fin.sale-road-tax-rubl  = tt-title-fin.sale-road-tax-rubl  + sum-road-tax-rubl-sale-cur                                   tt-title-fin.sale-excise-base    = tt-title-fin.sale-excise-base    + sum-excise-base-sale-cur                                     tt-title-fin.sale-excise-rubl    = tt-title-fin.sale-excise-rubl    + sum-excise-rubl-sale-cur                                     tt-title-fin.ov-base             = tt-title-fin.ov-base             + (if varr-b = "base" then (sum-price-base-with-tax-sale-cur - sum-price-base-with-tax-sale) else (sum-price-rubl-with-tax-sale-cur - sum-price-rubl-with-tax-sale))                             tt-title-fin.ov-vat              = tt-title-fin.ov-vat              + (if varr-b = "base" then (sum-price-base-with-tax-sale-cur - sum-price-base-with-tax-sale) else (sum-price-rubl-with-tax-sale-cur - sum-price-rubl-with-tax-sale)) * bf_doc-line.vat-pc / (100 + bf_doc-line.vat-pc).
    end.
  end.
    if lookup( "d-slt-vat", use-table ) > 0 then do:
    find first d-slt-vat where
               d-slt-vat.vat-pc = bf_doc-line.vat-pc and
               d-slt-vat.slt-pc = bf_doc-line.slt-pc no-error.
    if not available d-slt-vat then do:
      create d-slt-vat.
      assign d-slt-vat.vat-pc = bf_doc-line.vat-pc
             d-slt-vat.slt-pc = bf_doc-line.slt-pc.
    end.
    assign d-slt-vat.fact-qnty           = 0                             d-slt-vat.acc-base            = 0                             d-slt-vat.acc-rubl            = 0                             d-slt-vat.acc-vat-base        = 0                             d-slt-vat.acc-vat-rubl        = 0                             d-slt-vat.acc-slt-base        = 0                             d-slt-vat.acc-slt-rubl        = 0                             d-slt-vat.acc-road-tax-base   = 0                             d-slt-vat.acc-road-tax-rubl   = 0                             d-slt-vat.acc-excise-base     = 0                             d-slt-vat.acc-excise-rubl     = 0                             d-slt-vat.acc-transport-base  = 0                             d-slt-vat.acc-transport-rubl  = 0                             d-slt-vat.acc-other-base      = 0                             d-slt-vat.acc-other-rubl      = 0                             d-slt-vat.pay-base            = d-slt-vat.pay-base            + sum-price-base-with-tax-sale                             d-slt-vat.pay-rubl            = d-slt-vat.pay-rubl            + sum-price-rubl-with-tax-sale                             d-slt-vat.no-vat-base         = d-slt-vat.no-vat-base         + sum-price-base-with-tax-sale - sum-vat-base-sale                             d-slt-vat.no-vat-rubl         = d-slt-vat.no-vat-rubl         + sum-price-rubl-with-tax-sale - sum-vat-rubl-sale                             d-slt-vat.vat-base            = d-slt-vat.vat-base            + sum-vat-base-sale                              d-slt-vat.vat-rubl            = d-slt-vat.vat-rubl            + sum-vat-rubl-sale                              d-slt-vat.vat-base-buyer      = d-slt-vat.vat-base-buyer      + sum-vat-base-buyer                             d-slt-vat.vat-rubl-buyer      = d-slt-vat.vat-rubl-buyer      + sum-vat-rubl-buyer                             d-slt-vat.slt-base            = d-slt-vat.slt-base            + sum-slt-base-sale                             d-slt-vat.slt-rubl            = d-slt-vat.slt-rubl            + sum-slt-rubl-sale                             d-slt-vat.road-tax            = d-slt-vat.road-tax            + (if varr-b = "base" then sum-road-tax-base-sale else sum-road-tax-rubl-sale)                             d-slt-vat.excise              = d-slt-vat.excise              + (if varr-b = "base" then sum-excise-base-sale   else sum-excise-rubl-sale )                             d-slt-vat.sale-base           = d-slt-vat.sale-base           + sum-price-base-with-tax-sale-cur                             d-slt-vat.sale-rubl           = d-slt-vat.sale-rubl           + sum-price-rubl-with-tax-sale-cur                             d-slt-vat.sale-vat-base       = d-slt-vat.sale-vat-base       + sum-vat-base-sale-cur                                        d-slt-vat.sale-vat-rubl       = d-slt-vat.sale-vat-rubl       + sum-vat-rubl-sale-cur                                        d-slt-vat.sale-vat-buyer-base = d-slt-vat.sale-vat-buyer-base + sum-vat-base-buyer-cur                                       d-slt-vat.sale-vat-buyer-rubl = d-slt-vat.sale-vat-buyer-rubl + sum-vat-rubl-buyer-cur                                       d-slt-vat.sale-slt-base       = d-slt-vat.sale-slt-base       + sum-slt-base-sale-cur                                        d-slt-vat.sale-slt-rubl       = d-slt-vat.sale-slt-rubl       + sum-slt-rubl-sale-cur                                        d-slt-vat.sale-road-tax-base  = d-slt-vat.sale-road-tax-base  + sum-road-tax-base-sale-cur                                   d-slt-vat.sale-road-tax-rubl  = d-slt-vat.sale-road-tax-rubl  + sum-road-tax-rubl-sale-cur                                   d-slt-vat.sale-excise-base    = d-slt-vat.sale-excise-base    + sum-excise-base-sale-cur                                     d-slt-vat.sale-excise-rubl    = d-slt-vat.sale-excise-rubl    + sum-excise-rubl-sale-cur                                     d-slt-vat.ov-base             = d-slt-vat.ov-base             + (if varr-b = "base" then (sum-price-base-with-tax-sale-cur - sum-price-base-with-tax-sale) else (sum-price-rubl-with-tax-sale-cur - sum-price-rubl-with-tax-sale))                             d-slt-vat.ov-vat              = d-slt-vat.ov-vat              + (if varr-b = "base" then (sum-price-base-with-tax-sale-cur - sum-price-base-with-tax-sale) else (sum-price-rubl-with-tax-sale-cur - sum-price-rubl-with-tax-sale)) * bf_doc-line.vat-pc / (100 + bf_doc-line.vat-pc).
  end.
    if lookup( "d-supp", use-table ) > 0 then do:
    find first d-supp where
               d-supp.supp-type  = ? and
               d-supp.supp-code  = ? and
               d-supp.purch-code = ? no-error.
    if not available d-supp then do:
      create d-supp.
      assign d-supp.supp-type  = ?
             d-supp.supp-code  = ?
             d-supp.purch-code = ?
             d-supp.supp-name  = "Пересортица по признакам"
             d-supp.purch-name = ?.
    end.
    assign d-supp.fact-qnty           = 0                             d-supp.acc-base            = 0                             d-supp.acc-rubl            = 0                             d-supp.acc-vat-base        = 0                             d-supp.acc-vat-rubl        = 0                             d-supp.acc-slt-base        = 0                             d-supp.acc-slt-rubl        = 0                             d-supp.acc-road-tax-base   = 0                             d-supp.acc-road-tax-rubl   = 0                             d-supp.acc-excise-base     = 0                             d-supp.acc-excise-rubl     = 0                             d-supp.acc-transport-base  = 0                             d-supp.acc-transport-rubl  = 0                             d-supp.acc-other-base      = 0                             d-supp.acc-other-rubl      = 0                             d-supp.pay-base            = d-supp.pay-base            + sum-price-base-with-tax-sale                             d-supp.pay-rubl            = d-supp.pay-rubl            + sum-price-rubl-with-tax-sale                             d-supp.no-vat-base         = d-supp.no-vat-base         + sum-price-base-with-tax-sale - sum-vat-base-sale                             d-supp.no-vat-rubl         = d-supp.no-vat-rubl         + sum-price-rubl-with-tax-sale - sum-vat-rubl-sale                             d-supp.vat-base            = d-supp.vat-base            + sum-vat-base-sale                              d-supp.vat-rubl            = d-supp.vat-rubl            + sum-vat-rubl-sale                              d-supp.vat-base-buyer      = d-supp.vat-base-buyer      + sum-vat-base-buyer                             d-supp.vat-rubl-buyer      = d-supp.vat-rubl-buyer      + sum-vat-rubl-buyer                             d-supp.slt-base            = d-supp.slt-base            + sum-slt-base-sale                             d-supp.slt-rubl            = d-supp.slt-rubl            + sum-slt-rubl-sale                             d-supp.road-tax            = d-supp.road-tax            + (if varr-b = "base" then sum-road-tax-base-sale else sum-road-tax-rubl-sale)                             d-supp.excise              = d-supp.excise              + (if varr-b = "base" then sum-excise-base-sale   else sum-excise-rubl-sale )                             d-supp.sale-base           = d-supp.sale-base           + sum-price-base-with-tax-sale-cur                             d-supp.sale-rubl           = d-supp.sale-rubl           + sum-price-rubl-with-tax-sale-cur                             d-supp.sale-vat-base       = d-supp.sale-vat-base       + sum-vat-base-sale-cur                                        d-supp.sale-vat-rubl       = d-supp.sale-vat-rubl       + sum-vat-rubl-sale-cur                                        d-supp.sale-vat-buyer-base = d-supp.sale-vat-buyer-base + sum-vat-base-buyer-cur                                       d-supp.sale-vat-buyer-rubl = d-supp.sale-vat-buyer-rubl + sum-vat-rubl-buyer-cur                                       d-supp.sale-slt-base       = d-supp.sale-slt-base       + sum-slt-base-sale-cur                                        d-supp.sale-slt-rubl       = d-supp.sale-slt-rubl       + sum-slt-rubl-sale-cur                                        d-supp.sale-road-tax-base  = d-supp.sale-road-tax-base  + sum-road-tax-base-sale-cur                                   d-supp.sale-road-tax-rubl  = d-supp.sale-road-tax-rubl  + sum-road-tax-rubl-sale-cur                                   d-supp.sale-excise-base    = d-supp.sale-excise-base    + sum-excise-base-sale-cur                                     d-supp.sale-excise-rubl    = d-supp.sale-excise-rubl    + sum-excise-rubl-sale-cur                                     d-supp.ov-base             = d-supp.ov-base             + (if varr-b = "base" then (sum-price-base-with-tax-sale-cur - sum-price-base-with-tax-sale) else (sum-price-rubl-with-tax-sale-cur - sum-price-rubl-with-tax-sale))                             d-supp.ov-vat              = d-supp.ov-vat              + (if varr-b = "base" then (sum-price-base-with-tax-sale-cur - sum-price-base-with-tax-sale) else (sum-price-rubl-with-tax-sale-cur - sum-price-rubl-with-tax-sale)) * bf_doc-line.vat-pc / (100 + bf_doc-line.vat-pc).
  end.
    if lookup( "d-supp-fin", use-table ) > 0 then do:
    find first d-supp-fin where
               d-supp-fin.supp-type     = ? and
               d-supp-fin.supp-code     = ? and
               d-supp-fin.purch-code    = ? and
               d-supp-fin.contract-code = 0 no-error.
    if not available d-supp-fin then do:
      create d-supp-fin.
      assign d-supp-fin.supp-type     = ?
             d-supp-fin.supp-code     = ?
             d-supp-fin.purch-code    = ?
             d-supp-fin.supp-name     = "Пересортица по признакам"
             d-supp-fin.purch-name    = ?
             d-supp-fin.contract-code = 0.
    end.
    assign d-supp-fin.fact-qnty           = 0                             d-supp-fin.acc-base            = 0                             d-supp-fin.acc-rubl            = 0                             d-supp-fin.acc-vat-base        = 0                             d-supp-fin.acc-vat-rubl        = 0                             d-supp-fin.acc-slt-base        = 0                             d-supp-fin.acc-slt-rubl        = 0                             d-supp-fin.acc-road-tax-base   = 0                             d-supp-fin.acc-road-tax-rubl   = 0                             d-supp-fin.acc-excise-base     = 0                             d-supp-fin.acc-excise-rubl     = 0                             d-supp-fin.acc-transport-base  = 0                             d-supp-fin.acc-transport-rubl  = 0                             d-supp-fin.acc-other-base      = 0                             d-supp-fin.acc-other-rubl      = 0                             d-supp-fin.pay-base            = d-supp-fin.pay-base            + sum-price-base-with-tax-sale                             d-supp-fin.pay-rubl            = d-supp-fin.pay-rubl            + sum-price-rubl-with-tax-sale                             d-supp-fin.no-vat-base         = d-supp-fin.no-vat-base         + sum-price-base-with-tax-sale - sum-vat-base-sale                             d-supp-fin.no-vat-rubl         = d-supp-fin.no-vat-rubl         + sum-price-rubl-with-tax-sale - sum-vat-rubl-sale                             d-supp-fin.vat-base            = d-supp-fin.vat-base            + sum-vat-base-sale                              d-supp-fin.vat-rubl            = d-supp-fin.vat-rubl            + sum-vat-rubl-sale                              d-supp-fin.vat-base-buyer      = d-supp-fin.vat-base-buyer      + sum-vat-base-buyer                             d-supp-fin.vat-rubl-buyer      = d-supp-fin.vat-rubl-buyer      + sum-vat-rubl-buyer                             d-supp-fin.slt-base            = d-supp-fin.slt-base            + sum-slt-base-sale                             d-supp-fin.slt-rubl            = d-supp-fin.slt-rubl            + sum-slt-rubl-sale                             d-supp-fin.road-tax            = d-supp-fin.road-tax            + (if varr-b = "base" then sum-road-tax-base-sale else sum-road-tax-rubl-sale)                             d-supp-fin.excise              = d-supp-fin.excise              + (if varr-b = "base" then sum-excise-base-sale   else sum-excise-rubl-sale )                             d-supp-fin.sale-base           = d-supp-fin.sale-base           + sum-price-base-with-tax-sale-cur                             d-supp-fin.sale-rubl           = d-supp-fin.sale-rubl           + sum-price-rubl-with-tax-sale-cur                             d-supp-fin.sale-vat-base       = d-supp-fin.sale-vat-base       + sum-vat-base-sale-cur                                        d-supp-fin.sale-vat-rubl       = d-supp-fin.sale-vat-rubl       + sum-vat-rubl-sale-cur                                        d-supp-fin.sale-vat-buyer-base = d-supp-fin.sale-vat-buyer-base + sum-vat-base-buyer-cur                                       d-supp-fin.sale-vat-buyer-rubl = d-supp-fin.sale-vat-buyer-rubl + sum-vat-rubl-buyer-cur                                       d-supp-fin.sale-slt-base       = d-supp-fin.sale-slt-base       + sum-slt-base-sale-cur                                        d-supp-fin.sale-slt-rubl       = d-supp-fin.sale-slt-rubl       + sum-slt-rubl-sale-cur                                        d-supp-fin.sale-road-tax-base  = d-supp-fin.sale-road-tax-base  + sum-road-tax-base-sale-cur                                   d-supp-fin.sale-road-tax-rubl  = d-supp-fin.sale-road-tax-rubl  + sum-road-tax-rubl-sale-cur                                   d-supp-fin.sale-excise-base    = d-supp-fin.sale-excise-base    + sum-excise-base-sale-cur                                     d-supp-fin.sale-excise-rubl    = d-supp-fin.sale-excise-rubl    + sum-excise-rubl-sale-cur                                     d-supp-fin.ov-base             = d-supp-fin.ov-base             + (if varr-b = "base" then (sum-price-base-with-tax-sale-cur - sum-price-base-with-tax-sale) else (sum-price-rubl-with-tax-sale-cur - sum-price-rubl-with-tax-sale))                             d-supp-fin.ov-vat              = d-supp-fin.ov-vat              + (if varr-b = "base" then (sum-price-base-with-tax-sale-cur - sum-price-base-with-tax-sale) else (sum-price-rubl-with-tax-sale-cur - sum-price-rubl-with-tax-sale)) * bf_doc-line.vat-pc / (100 + bf_doc-line.vat-pc).
  end.
    if lookup( "d-supp-grp", use-table ) > 0 then do:
    find first d-supp-grp where
               d-supp-grp.supp-type  = ?                 and
               d-supp-grp.supp-code  = ?                 and
               d-supp-grp.purch-code = ?                 and
               d-supp-grp.grp-code   = bf_goods.grp-code no-error.
    if not available d-supp-grp then do:
      create d-supp-grp.
      assign d-supp-grp.supp-type  = ?
             d-supp-grp.supp-code  = ?
             d-supp-grp.purch-code = ?
             d-supp-grp.grp-code   = bf_goods.grp-code
             d-supp-grp.supp-name  = "Пересортица по признакам"
             d-supp-grp.purch-name = ?
             d-supp-grp.grp-name   = varfull-name-grp.
    end.
    assign d-supp-grp.fact-qnty           = 0                             d-supp-grp.acc-base            = 0                             d-supp-grp.acc-rubl            = 0                             d-supp-grp.acc-vat-base        = 0                             d-supp-grp.acc-vat-rubl        = 0                             d-supp-grp.acc-slt-base        = 0                             d-supp-grp.acc-slt-rubl        = 0                             d-supp-grp.acc-road-tax-base   = 0                             d-supp-grp.acc-road-tax-rubl   = 0                             d-supp-grp.acc-excise-base     = 0                             d-supp-grp.acc-excise-rubl     = 0                             d-supp-grp.acc-transport-base  = 0                             d-supp-grp.acc-transport-rubl  = 0                             d-supp-grp.acc-other-base      = 0                             d-supp-grp.acc-other-rubl      = 0                             d-supp-grp.pay-base            = d-supp-grp.pay-base            + sum-price-base-with-tax-sale                             d-supp-grp.pay-rubl            = d-supp-grp.pay-rubl            + sum-price-rubl-with-tax-sale                             d-supp-grp.no-vat-base         = d-supp-grp.no-vat-base         + sum-price-base-with-tax-sale - sum-vat-base-sale                             d-supp-grp.no-vat-rubl         = d-supp-grp.no-vat-rubl         + sum-price-rubl-with-tax-sale - sum-vat-rubl-sale                             d-supp-grp.vat-base            = d-supp-grp.vat-base            + sum-vat-base-sale                              d-supp-grp.vat-rubl            = d-supp-grp.vat-rubl            + sum-vat-rubl-sale                              d-supp-grp.vat-base-buyer      = d-supp-grp.vat-base-buyer      + sum-vat-base-buyer                             d-supp-grp.vat-rubl-buyer      = d-supp-grp.vat-rubl-buyer      + sum-vat-rubl-buyer                             d-supp-grp.slt-base            = d-supp-grp.slt-base            + sum-slt-base-sale                             d-supp-grp.slt-rubl            = d-supp-grp.slt-rubl            + sum-slt-rubl-sale                             d-supp-grp.road-tax            = d-supp-grp.road-tax            + (if varr-b = "base" then sum-road-tax-base-sale else sum-road-tax-rubl-sale)                             d-supp-grp.excise              = d-supp-grp.excise              + (if varr-b = "base" then sum-excise-base-sale   else sum-excise-rubl-sale )                             d-supp-grp.sale-base           = d-supp-grp.sale-base           + sum-price-base-with-tax-sale-cur                             d-supp-grp.sale-rubl           = d-supp-grp.sale-rubl           + sum-price-rubl-with-tax-sale-cur                             d-supp-grp.sale-vat-base       = d-supp-grp.sale-vat-base       + sum-vat-base-sale-cur                                        d-supp-grp.sale-vat-rubl       = d-supp-grp.sale-vat-rubl       + sum-vat-rubl-sale-cur                                        d-supp-grp.sale-vat-buyer-base = d-supp-grp.sale-vat-buyer-base + sum-vat-base-buyer-cur                                       d-supp-grp.sale-vat-buyer-rubl = d-supp-grp.sale-vat-buyer-rubl + sum-vat-rubl-buyer-cur                                       d-supp-grp.sale-slt-base       = d-supp-grp.sale-slt-base       + sum-slt-base-sale-cur                                        d-supp-grp.sale-slt-rubl       = d-supp-grp.sale-slt-rubl       + sum-slt-rubl-sale-cur                                        d-supp-grp.sale-road-tax-base  = d-supp-grp.sale-road-tax-base  + sum-road-tax-base-sale-cur                                   d-supp-grp.sale-road-tax-rubl  = d-supp-grp.sale-road-tax-rubl  + sum-road-tax-rubl-sale-cur                                   d-supp-grp.sale-excise-base    = d-supp-grp.sale-excise-base    + sum-excise-base-sale-cur                                     d-supp-grp.sale-excise-rubl    = d-supp-grp.sale-excise-rubl    + sum-excise-rubl-sale-cur                                     d-supp-grp.ov-base             = d-supp-grp.ov-base             + (if varr-b = "base" then (sum-price-base-with-tax-sale-cur - sum-price-base-with-tax-sale) else (sum-price-rubl-with-tax-sale-cur - sum-price-rubl-with-tax-sale))                             d-supp-grp.ov-vat              = d-supp-grp.ov-vat              + (if varr-b = "base" then (sum-price-base-with-tax-sale-cur - sum-price-base-with-tax-sale) else (sum-price-rubl-with-tax-sale-cur - sum-price-rubl-with-tax-sale)) * bf_doc-line.vat-pc / (100 + bf_doc-line.vat-pc).
  end.
    if lookup( "d-supp-grp-fin", use-table ) > 0 then do:
    find first d-supp-grp-fin where
               d-supp-grp-fin.supp-type     = ?                 and
               d-supp-grp-fin.supp-code     = ?                 and
               d-supp-grp-fin.purch-code    = ?                 and
               d-supp-grp-fin.grp-code      = bf_goods.grp-code and
               d-supp-grp-fin.contract-code = 0                 no-error.
    if not available d-supp-grp-fin then do:
      create d-supp-grp-fin.
      assign d-supp-grp-fin.supp-type     = ?
             d-supp-grp-fin.supp-code     = ?
             d-supp-grp-fin.purch-code    = ?
             d-supp-grp-fin.grp-code      = bf_goods.grp-code
             d-supp-grp-fin.contract-code = 0
             d-supp-grp-fin.supp-name     = "Пересортица по признакам"
             d-supp-grp-fin.purch-name    = ?
             d-supp-grp-fin.grp-name      = varfull-name-grp.
    end.
    assign d-supp-grp-fin.fact-qnty           = 0                             d-supp-grp-fin.acc-base            = 0                             d-supp-grp-fin.acc-rubl            = 0                             d-supp-grp-fin.acc-vat-base        = 0                             d-supp-grp-fin.acc-vat-rubl        = 0                             d-supp-grp-fin.acc-slt-base        = 0                             d-supp-grp-fin.acc-slt-rubl        = 0                             d-supp-grp-fin.acc-road-tax-base   = 0                             d-supp-grp-fin.acc-road-tax-rubl   = 0                             d-supp-grp-fin.acc-excise-base     = 0                             d-supp-grp-fin.acc-excise-rubl     = 0                             d-supp-grp-fin.acc-transport-base  = 0                             d-supp-grp-fin.acc-transport-rubl  = 0                             d-supp-grp-fin.acc-other-base      = 0                             d-supp-grp-fin.acc-other-rubl      = 0                             d-supp-grp-fin.pay-base            = d-supp-grp-fin.pay-base            + sum-price-base-with-tax-sale                             d-supp-grp-fin.pay-rubl            = d-supp-grp-fin.pay-rubl            + sum-price-rubl-with-tax-sale                             d-supp-grp-fin.no-vat-base         = d-supp-grp-fin.no-vat-base         + sum-price-base-with-tax-sale - sum-vat-base-sale                             d-supp-grp-fin.no-vat-rubl         = d-supp-grp-fin.no-vat-rubl         + sum-price-rubl-with-tax-sale - sum-vat-rubl-sale                             d-supp-grp-fin.vat-base            = d-supp-grp-fin.vat-base            + sum-vat-base-sale                              d-supp-grp-fin.vat-rubl            = d-supp-grp-fin.vat-rubl            + sum-vat-rubl-sale                              d-supp-grp-fin.vat-base-buyer      = d-supp-grp-fin.vat-base-buyer      + sum-vat-base-buyer                             d-supp-grp-fin.vat-rubl-buyer      = d-supp-grp-fin.vat-rubl-buyer      + sum-vat-rubl-buyer                             d-supp-grp-fin.slt-base            = d-supp-grp-fin.slt-base            + sum-slt-base-sale                             d-supp-grp-fin.slt-rubl            = d-supp-grp-fin.slt-rubl            + sum-slt-rubl-sale                             d-supp-grp-fin.road-tax            = d-supp-grp-fin.road-tax            + (if varr-b = "base" then sum-road-tax-base-sale else sum-road-tax-rubl-sale)                             d-supp-grp-fin.excise              = d-supp-grp-fin.excise              + (if varr-b = "base" then sum-excise-base-sale   else sum-excise-rubl-sale )                             d-supp-grp-fin.sale-base           = d-supp-grp-fin.sale-base           + sum-price-base-with-tax-sale-cur                             d-supp-grp-fin.sale-rubl           = d-supp-grp-fin.sale-rubl           + sum-price-rubl-with-tax-sale-cur                             d-supp-grp-fin.sale-vat-base       = d-supp-grp-fin.sale-vat-base       + sum-vat-base-sale-cur                                        d-supp-grp-fin.sale-vat-rubl       = d-supp-grp-fin.sale-vat-rubl       + sum-vat-rubl-sale-cur                                        d-supp-grp-fin.sale-vat-buyer-base = d-supp-grp-fin.sale-vat-buyer-base + sum-vat-base-buyer-cur                                       d-supp-grp-fin.sale-vat-buyer-rubl = d-supp-grp-fin.sale-vat-buyer-rubl + sum-vat-rubl-buyer-cur                                       d-supp-grp-fin.sale-slt-base       = d-supp-grp-fin.sale-slt-base       + sum-slt-base-sale-cur                                        d-supp-grp-fin.sale-slt-rubl       = d-supp-grp-fin.sale-slt-rubl       + sum-slt-rubl-sale-cur                                        d-supp-grp-fin.sale-road-tax-base  = d-supp-grp-fin.sale-road-tax-base  + sum-road-tax-base-sale-cur                                   d-supp-grp-fin.sale-road-tax-rubl  = d-supp-grp-fin.sale-road-tax-rubl  + sum-road-tax-rubl-sale-cur                                   d-supp-grp-fin.sale-excise-base    = d-supp-grp-fin.sale-excise-base    + sum-excise-base-sale-cur                                     d-supp-grp-fin.sale-excise-rubl    = d-supp-grp-fin.sale-excise-rubl    + sum-excise-rubl-sale-cur                                     d-supp-grp-fin.ov-base             = d-supp-grp-fin.ov-base             + (if varr-b = "base" then (sum-price-base-with-tax-sale-cur - sum-price-base-with-tax-sale) else (sum-price-rubl-with-tax-sale-cur - sum-price-rubl-with-tax-sale))                             d-supp-grp-fin.ov-vat              = d-supp-grp-fin.ov-vat              + (if varr-b = "base" then (sum-price-base-with-tax-sale-cur - sum-price-base-with-tax-sale) else (sum-price-rubl-with-tax-sale-cur - sum-price-rubl-with-tax-sale)) * bf_doc-line.vat-pc / (100 + bf_doc-line.vat-pc).
  end.
    if lookup( "d-slt-vat-cons", use-table ) > 0 then do:
    find first d-slt-vat-cons where
               d-slt-vat-cons.vat-pc     = bf_doc-line.vat-pc and
               d-slt-vat-cons.slt-pc     = bf_doc-line.slt-pc and
               d-slt-vat-cons.purch-code = ?                  no-error.
    if not available d-slt-vat-cons then do:
      create d-slt-vat-cons.
      assign d-slt-vat-cons.vat-pc     = bf_doc-line.vat-pc
             d-slt-vat-cons.slt-pc     = bf_doc-line.slt-pc
             d-slt-vat-cons.purch-code = ?
             d-slt-vat-cons.purch-name = ?.
    end.
    assign d-slt-vat-cons.fact-qnty           = 0                             d-slt-vat-cons.acc-base            = 0                             d-slt-vat-cons.acc-rubl            = 0                             d-slt-vat-cons.acc-vat-base        = 0                             d-slt-vat-cons.acc-vat-rubl        = 0                             d-slt-vat-cons.acc-slt-base        = 0                             d-slt-vat-cons.acc-slt-rubl        = 0                             d-slt-vat-cons.acc-road-tax-base   = 0                             d-slt-vat-cons.acc-road-tax-rubl   = 0                             d-slt-vat-cons.acc-excise-base     = 0                             d-slt-vat-cons.acc-excise-rubl     = 0                             d-slt-vat-cons.acc-transport-base  = 0                             d-slt-vat-cons.acc-transport-rubl  = 0                             d-slt-vat-cons.acc-other-base      = 0                             d-slt-vat-cons.acc-other-rubl      = 0                             d-slt-vat-cons.pay-base            = d-slt-vat-cons.pay-base            + sum-price-base-with-tax-sale                             d-slt-vat-cons.pay-rubl            = d-slt-vat-cons.pay-rubl            + sum-price-rubl-with-tax-sale                             d-slt-vat-cons.no-vat-base         = d-slt-vat-cons.no-vat-base         + sum-price-base-with-tax-sale - sum-vat-base-sale                             d-slt-vat-cons.no-vat-rubl         = d-slt-vat-cons.no-vat-rubl         + sum-price-rubl-with-tax-sale - sum-vat-rubl-sale                             d-slt-vat-cons.vat-base            = d-slt-vat-cons.vat-base            + sum-vat-base-sale                              d-slt-vat-cons.vat-rubl            = d-slt-vat-cons.vat-rubl            + sum-vat-rubl-sale                              d-slt-vat-cons.vat-base-buyer      = d-slt-vat-cons.vat-base-buyer      + sum-vat-base-buyer                             d-slt-vat-cons.vat-rubl-buyer      = d-slt-vat-cons.vat-rubl-buyer      + sum-vat-rubl-buyer                             d-slt-vat-cons.slt-base            = d-slt-vat-cons.slt-base            + sum-slt-base-sale                             d-slt-vat-cons.slt-rubl            = d-slt-vat-cons.slt-rubl            + sum-slt-rubl-sale                             d-slt-vat-cons.road-tax            = d-slt-vat-cons.road-tax            + (if varr-b = "base" then sum-road-tax-base-sale else sum-road-tax-rubl-sale)                             d-slt-vat-cons.excise              = d-slt-vat-cons.excise              + (if varr-b = "base" then sum-excise-base-sale   else sum-excise-rubl-sale )                             d-slt-vat-cons.sale-base           = d-slt-vat-cons.sale-base           + sum-price-base-with-tax-sale-cur                             d-slt-vat-cons.sale-rubl           = d-slt-vat-cons.sale-rubl           + sum-price-rubl-with-tax-sale-cur                             d-slt-vat-cons.sale-vat-base       = d-slt-vat-cons.sale-vat-base       + sum-vat-base-sale-cur                                        d-slt-vat-cons.sale-vat-rubl       = d-slt-vat-cons.sale-vat-rubl       + sum-vat-rubl-sale-cur                                        d-slt-vat-cons.sale-vat-buyer-base = d-slt-vat-cons.sale-vat-buyer-base + sum-vat-base-buyer-cur                                       d-slt-vat-cons.sale-vat-buyer-rubl = d-slt-vat-cons.sale-vat-buyer-rubl + sum-vat-rubl-buyer-cur                                       d-slt-vat-cons.sale-slt-base       = d-slt-vat-cons.sale-slt-base       + sum-slt-base-sale-cur                                        d-slt-vat-cons.sale-slt-rubl       = d-slt-vat-cons.sale-slt-rubl       + sum-slt-rubl-sale-cur                                        d-slt-vat-cons.sale-road-tax-base  = d-slt-vat-cons.sale-road-tax-base  + sum-road-tax-base-sale-cur                                   d-slt-vat-cons.sale-road-tax-rubl  = d-slt-vat-cons.sale-road-tax-rubl  + sum-road-tax-rubl-sale-cur                                   d-slt-vat-cons.sale-excise-base    = d-slt-vat-cons.sale-excise-base    + sum-excise-base-sale-cur                                     d-slt-vat-cons.sale-excise-rubl    = d-slt-vat-cons.sale-excise-rubl    + sum-excise-rubl-sale-cur                                     d-slt-vat-cons.ov-base             = d-slt-vat-cons.ov-base             + (if varr-b = "base" then (sum-price-base-with-tax-sale-cur - sum-price-base-with-tax-sale) else (sum-price-rubl-with-tax-sale-cur - sum-price-rubl-with-tax-sale))                             d-slt-vat-cons.ov-vat              = d-slt-vat-cons.ov-vat              + (if varr-b = "base" then (sum-price-base-with-tax-sale-cur - sum-price-base-with-tax-sale) else (sum-price-rubl-with-tax-sale-cur - sum-price-rubl-with-tax-sale)) * bf_doc-line.vat-pc / (100 + bf_doc-line.vat-pc).
  end.
    if lookup( "d-slt-vat-cons-fin", use-table ) > 0 then do:
    find first d-slt-vat-cons-fin where
               d-slt-vat-cons-fin.vat-pc        = bf_doc-line.vat-pc and
               d-slt-vat-cons-fin.slt-pc        = bf_doc-line.slt-pc and
               d-slt-vat-cons-fin.contract-code = 0                  and
               d-slt-vat-cons-fin.purch-code    = ?                  no-error.
    if not available d-slt-vat-cons-fin then do:
      create d-slt-vat-cons-fin.
      assign d-slt-vat-cons-fin.vat-pc        = bf_doc-line.vat-pc
             d-slt-vat-cons-fin.slt-pc        = bf_doc-line.slt-pc
             d-slt-vat-cons-fin.purch-code    = ?
             d-slt-vat-cons-fin.contract-code = 0
             d-slt-vat-cons-fin.purch-name    = ?.
    end.
    assign d-slt-vat-cons-fin.fact-qnty           = 0                             d-slt-vat-cons-fin.acc-base            = 0                             d-slt-vat-cons-fin.acc-rubl            = 0                             d-slt-vat-cons-fin.acc-vat-base        = 0                             d-slt-vat-cons-fin.acc-vat-rubl        = 0                             d-slt-vat-cons-fin.acc-slt-base        = 0                             d-slt-vat-cons-fin.acc-slt-rubl        = 0                             d-slt-vat-cons-fin.acc-road-tax-base   = 0                             d-slt-vat-cons-fin.acc-road-tax-rubl   = 0                             d-slt-vat-cons-fin.acc-excise-base     = 0                             d-slt-vat-cons-fin.acc-excise-rubl     = 0                             d-slt-vat-cons-fin.acc-transport-base  = 0                             d-slt-vat-cons-fin.acc-transport-rubl  = 0                             d-slt-vat-cons-fin.acc-other-base      = 0                             d-slt-vat-cons-fin.acc-other-rubl      = 0                             d-slt-vat-cons-fin.pay-base            = d-slt-vat-cons-fin.pay-base            + sum-price-base-with-tax-sale                             d-slt-vat-cons-fin.pay-rubl            = d-slt-vat-cons-fin.pay-rubl            + sum-price-rubl-with-tax-sale                             d-slt-vat-cons-fin.no-vat-base         = d-slt-vat-cons-fin.no-vat-base         + sum-price-base-with-tax-sale - sum-vat-base-sale                             d-slt-vat-cons-fin.no-vat-rubl         = d-slt-vat-cons-fin.no-vat-rubl         + sum-price-rubl-with-tax-sale - sum-vat-rubl-sale                             d-slt-vat-cons-fin.vat-base            = d-slt-vat-cons-fin.vat-base            + sum-vat-base-sale                              d-slt-vat-cons-fin.vat-rubl            = d-slt-vat-cons-fin.vat-rubl            + sum-vat-rubl-sale                              d-slt-vat-cons-fin.vat-base-buyer      = d-slt-vat-cons-fin.vat-base-buyer      + sum-vat-base-buyer                             d-slt-vat-cons-fin.vat-rubl-buyer      = d-slt-vat-cons-fin.vat-rubl-buyer      + sum-vat-rubl-buyer                             d-slt-vat-cons-fin.slt-base            = d-slt-vat-cons-fin.slt-base            + sum-slt-base-sale                             d-slt-vat-cons-fin.slt-rubl            = d-slt-vat-cons-fin.slt-rubl            + sum-slt-rubl-sale                             d-slt-vat-cons-fin.road-tax            = d-slt-vat-cons-fin.road-tax            + (if varr-b = "base" then sum-road-tax-base-sale else sum-road-tax-rubl-sale)                             d-slt-vat-cons-fin.excise              = d-slt-vat-cons-fin.excise              + (if varr-b = "base" then sum-excise-base-sale   else sum-excise-rubl-sale )                             d-slt-vat-cons-fin.sale-base           = d-slt-vat-cons-fin.sale-base           + sum-price-base-with-tax-sale-cur                             d-slt-vat-cons-fin.sale-rubl           = d-slt-vat-cons-fin.sale-rubl           + sum-price-rubl-with-tax-sale-cur                             d-slt-vat-cons-fin.sale-vat-base       = d-slt-vat-cons-fin.sale-vat-base       + sum-vat-base-sale-cur                                        d-slt-vat-cons-fin.sale-vat-rubl       = d-slt-vat-cons-fin.sale-vat-rubl       + sum-vat-rubl-sale-cur                                        d-slt-vat-cons-fin.sale-vat-buyer-base = d-slt-vat-cons-fin.sale-vat-buyer-base + sum-vat-base-buyer-cur                                       d-slt-vat-cons-fin.sale-vat-buyer-rubl = d-slt-vat-cons-fin.sale-vat-buyer-rubl + sum-vat-rubl-buyer-cur                                       d-slt-vat-cons-fin.sale-slt-base       = d-slt-vat-cons-fin.sale-slt-base       + sum-slt-base-sale-cur                                        d-slt-vat-cons-fin.sale-slt-rubl       = d-slt-vat-cons-fin.sale-slt-rubl       + sum-slt-rubl-sale-cur                                        d-slt-vat-cons-fin.sale-road-tax-base  = d-slt-vat-cons-fin.sale-road-tax-base  + sum-road-tax-base-sale-cur                                   d-slt-vat-cons-fin.sale-road-tax-rubl  = d-slt-vat-cons-fin.sale-road-tax-rubl  + sum-road-tax-rubl-sale-cur                                   d-slt-vat-cons-fin.sale-excise-base    = d-slt-vat-cons-fin.sale-excise-base    + sum-excise-base-sale-cur                                     d-slt-vat-cons-fin.sale-excise-rubl    = d-slt-vat-cons-fin.sale-excise-rubl    + sum-excise-rubl-sale-cur                                     d-slt-vat-cons-fin.ov-base             = d-slt-vat-cons-fin.ov-base             + (if varr-b = "base" then (sum-price-base-with-tax-sale-cur - sum-price-base-with-tax-sale) else (sum-price-rubl-with-tax-sale-cur - sum-price-rubl-with-tax-sale))                             d-slt-vat-cons-fin.ov-vat              = d-slt-vat-cons-fin.ov-vat              + (if varr-b = "base" then (sum-price-base-with-tax-sale-cur - sum-price-base-with-tax-sale) else (sum-price-rubl-with-tax-sale-cur - sum-price-rubl-with-tax-sale)) * bf_doc-line.vat-pc / (100 + bf_doc-line.vat-pc).
  end.
    if lookup( "d-slt-vat-cons-grp", use-table ) > 0 then do:
    find first d-slt-vat-cons-grp where
               d-slt-vat-cons-grp.vat-pc     = bf_doc-line.vat-pc and
               d-slt-vat-cons-grp.slt-pc     = bf_doc-line.slt-pc and
               d-slt-vat-cons-grp.purch-code = ?                  and
               d-slt-vat-cons-grp.grp-code   = bf_goods.grp-code  no-error.
    if not available d-slt-vat-cons-grp then do:
      create d-slt-vat-cons-grp.
      assign d-slt-vat-cons-grp.vat-pc     = bf_doc-line.vat-pc
             d-slt-vat-cons-grp.slt-pc     = bf_doc-line.slt-pc
             d-slt-vat-cons-grp.purch-code = ?
             d-slt-vat-cons-grp.purch-name = ?
             d-slt-vat-cons-grp.grp-code   = bf_goods.grp-code
             d-slt-vat-cons-grp.grp-name   = varfull-name-grp.
    end.
    assign d-slt-vat-cons-grp.fact-qnty           = 0                             d-slt-vat-cons-grp.acc-base            = 0                             d-slt-vat-cons-grp.acc-rubl            = 0                             d-slt-vat-cons-grp.acc-vat-base        = 0                             d-slt-vat-cons-grp.acc-vat-rubl        = 0                             d-slt-vat-cons-grp.acc-slt-base        = 0                             d-slt-vat-cons-grp.acc-slt-rubl        = 0                             d-slt-vat-cons-grp.acc-road-tax-base   = 0                             d-slt-vat-cons-grp.acc-road-tax-rubl   = 0                             d-slt-vat-cons-grp.acc-excise-base     = 0                             d-slt-vat-cons-grp.acc-excise-rubl     = 0                             d-slt-vat-cons-grp.acc-transport-base  = 0                             d-slt-vat-cons-grp.acc-transport-rubl  = 0                             d-slt-vat-cons-grp.acc-other-base      = 0                             d-slt-vat-cons-grp.acc-other-rubl      = 0                             d-slt-vat-cons-grp.pay-base            = d-slt-vat-cons-grp.pay-base            + sum-price-base-with-tax-sale                             d-slt-vat-cons-grp.pay-rubl            = d-slt-vat-cons-grp.pay-rubl            + sum-price-rubl-with-tax-sale                             d-slt-vat-cons-grp.no-vat-base         = d-slt-vat-cons-grp.no-vat-base         + sum-price-base-with-tax-sale - sum-vat-base-sale                             d-slt-vat-cons-grp.no-vat-rubl         = d-slt-vat-cons-grp.no-vat-rubl         + sum-price-rubl-with-tax-sale - sum-vat-rubl-sale                             d-slt-vat-cons-grp.vat-base            = d-slt-vat-cons-grp.vat-base            + sum-vat-base-sale                              d-slt-vat-cons-grp.vat-rubl            = d-slt-vat-cons-grp.vat-rubl            + sum-vat-rubl-sale                              d-slt-vat-cons-grp.vat-base-buyer      = d-slt-vat-cons-grp.vat-base-buyer      + sum-vat-base-buyer                             d-slt-vat-cons-grp.vat-rubl-buyer      = d-slt-vat-cons-grp.vat-rubl-buyer      + sum-vat-rubl-buyer                             d-slt-vat-cons-grp.slt-base            = d-slt-vat-cons-grp.slt-base            + sum-slt-base-sale                             d-slt-vat-cons-grp.slt-rubl            = d-slt-vat-cons-grp.slt-rubl            + sum-slt-rubl-sale                             d-slt-vat-cons-grp.road-tax            = d-slt-vat-cons-grp.road-tax            + (if varr-b = "base" then sum-road-tax-base-sale else sum-road-tax-rubl-sale)                             d-slt-vat-cons-grp.excise              = d-slt-vat-cons-grp.excise              + (if varr-b = "base" then sum-excise-base-sale   else sum-excise-rubl-sale )                             d-slt-vat-cons-grp.sale-base           = d-slt-vat-cons-grp.sale-base           + sum-price-base-with-tax-sale-cur                             d-slt-vat-cons-grp.sale-rubl           = d-slt-vat-cons-grp.sale-rubl           + sum-price-rubl-with-tax-sale-cur                             d-slt-vat-cons-grp.sale-vat-base       = d-slt-vat-cons-grp.sale-vat-base       + sum-vat-base-sale-cur                                        d-slt-vat-cons-grp.sale-vat-rubl       = d-slt-vat-cons-grp.sale-vat-rubl       + sum-vat-rubl-sale-cur                                        d-slt-vat-cons-grp.sale-vat-buyer-base = d-slt-vat-cons-grp.sale-vat-buyer-base + sum-vat-base-buyer-cur                                       d-slt-vat-cons-grp.sale-vat-buyer-rubl = d-slt-vat-cons-grp.sale-vat-buyer-rubl + sum-vat-rubl-buyer-cur                                       d-slt-vat-cons-grp.sale-slt-base       = d-slt-vat-cons-grp.sale-slt-base       + sum-slt-base-sale-cur                                        d-slt-vat-cons-grp.sale-slt-rubl       = d-slt-vat-cons-grp.sale-slt-rubl       + sum-slt-rubl-sale-cur                                        d-slt-vat-cons-grp.sale-road-tax-base  = d-slt-vat-cons-grp.sale-road-tax-base  + sum-road-tax-base-sale-cur                                   d-slt-vat-cons-grp.sale-road-tax-rubl  = d-slt-vat-cons-grp.sale-road-tax-rubl  + sum-road-tax-rubl-sale-cur                                   d-slt-vat-cons-grp.sale-excise-base    = d-slt-vat-cons-grp.sale-excise-base    + sum-excise-base-sale-cur                                     d-slt-vat-cons-grp.sale-excise-rubl    = d-slt-vat-cons-grp.sale-excise-rubl    + sum-excise-rubl-sale-cur                                     d-slt-vat-cons-grp.ov-base             = d-slt-vat-cons-grp.ov-base             + (if varr-b = "base" then (sum-price-base-with-tax-sale-cur - sum-price-base-with-tax-sale) else (sum-price-rubl-with-tax-sale-cur - sum-price-rubl-with-tax-sale))                             d-slt-vat-cons-grp.ov-vat              = d-slt-vat-cons-grp.ov-vat              + (if varr-b = "base" then (sum-price-base-with-tax-sale-cur - sum-price-base-with-tax-sale) else (sum-price-rubl-with-tax-sale-cur - sum-price-rubl-with-tax-sale)) * bf_doc-line.vat-pc / (100 + bf_doc-line.vat-pc).
  end.
    if lookup( "d-slt-vat-cons-grp-fin", use-table ) > 0 then do:
    find first d-slt-vat-cons-grp-fin where
               d-slt-vat-cons-grp-fin.vat-pc        = bf_doc-line.vat-pc and
               d-slt-vat-cons-grp-fin.slt-pc        = bf_doc-line.slt-pc and
               d-slt-vat-cons-grp-fin.purch-code    = ?                  and
               d-slt-vat-cons-grp-fin.contract-code = 0                  and
               d-slt-vat-cons-grp-fin.grp-code      = bf_goods.grp-code  no-error.
    if not available d-slt-vat-cons-grp-fin then do:
      create d-slt-vat-cons-grp-fin.
      assign d-slt-vat-cons-grp-fin.vat-pc        = bf_doc-line.vat-pc
             d-slt-vat-cons-grp-fin.slt-pc        = bf_doc-line.slt-pc
             d-slt-vat-cons-grp-fin.purch-code    = ?
             d-slt-vat-cons-grp-fin.purch-name    = ?
             d-slt-vat-cons-grp-fin.grp-code      = bf_goods.grp-code
             d-slt-vat-cons-grp-fin.grp-name      = varfull-name-grp
             d-slt-vat-cons-grp-fin.contract-code = 0.
    end.
    assign d-slt-vat-cons-grp-fin.fact-qnty           = 0                             d-slt-vat-cons-grp-fin.acc-base            = 0                             d-slt-vat-cons-grp-fin.acc-rubl            = 0                             d-slt-vat-cons-grp-fin.acc-vat-base        = 0                             d-slt-vat-cons-grp-fin.acc-vat-rubl        = 0                             d-slt-vat-cons-grp-fin.acc-slt-base        = 0                             d-slt-vat-cons-grp-fin.acc-slt-rubl        = 0                             d-slt-vat-cons-grp-fin.acc-road-tax-base   = 0                             d-slt-vat-cons-grp-fin.acc-road-tax-rubl   = 0                             d-slt-vat-cons-grp-fin.acc-excise-base     = 0                             d-slt-vat-cons-grp-fin.acc-excise-rubl     = 0                             d-slt-vat-cons-grp-fin.acc-transport-base  = 0                             d-slt-vat-cons-grp-fin.acc-transport-rubl  = 0                             d-slt-vat-cons-grp-fin.acc-other-base      = 0                             d-slt-vat-cons-grp-fin.acc-other-rubl      = 0                             d-slt-vat-cons-grp-fin.pay-base            = d-slt-vat-cons-grp-fin.pay-base            + sum-price-base-with-tax-sale                             d-slt-vat-cons-grp-fin.pay-rubl            = d-slt-vat-cons-grp-fin.pay-rubl            + sum-price-rubl-with-tax-sale                             d-slt-vat-cons-grp-fin.no-vat-base         = d-slt-vat-cons-grp-fin.no-vat-base         + sum-price-base-with-tax-sale - sum-vat-base-sale                             d-slt-vat-cons-grp-fin.no-vat-rubl         = d-slt-vat-cons-grp-fin.no-vat-rubl         + sum-price-rubl-with-tax-sale - sum-vat-rubl-sale                             d-slt-vat-cons-grp-fin.vat-base            = d-slt-vat-cons-grp-fin.vat-base            + sum-vat-base-sale                              d-slt-vat-cons-grp-fin.vat-rubl            = d-slt-vat-cons-grp-fin.vat-rubl            + sum-vat-rubl-sale                              d-slt-vat-cons-grp-fin.vat-base-buyer      = d-slt-vat-cons-grp-fin.vat-base-buyer      + sum-vat-base-buyer                             d-slt-vat-cons-grp-fin.vat-rubl-buyer      = d-slt-vat-cons-grp-fin.vat-rubl-buyer      + sum-vat-rubl-buyer                             d-slt-vat-cons-grp-fin.slt-base            = d-slt-vat-cons-grp-fin.slt-base            + sum-slt-base-sale                             d-slt-vat-cons-grp-fin.slt-rubl            = d-slt-vat-cons-grp-fin.slt-rubl            + sum-slt-rubl-sale                             d-slt-vat-cons-grp-fin.road-tax            = d-slt-vat-cons-grp-fin.road-tax            + (if varr-b = "base" then sum-road-tax-base-sale else sum-road-tax-rubl-sale)                             d-slt-vat-cons-grp-fin.excise              = d-slt-vat-cons-grp-fin.excise              + (if varr-b = "base" then sum-excise-base-sale   else sum-excise-rubl-sale )                             d-slt-vat-cons-grp-fin.sale-base           = d-slt-vat-cons-grp-fin.sale-base           + sum-price-base-with-tax-sale-cur                             d-slt-vat-cons-grp-fin.sale-rubl           = d-slt-vat-cons-grp-fin.sale-rubl           + sum-price-rubl-with-tax-sale-cur                             d-slt-vat-cons-grp-fin.sale-vat-base       = d-slt-vat-cons-grp-fin.sale-vat-base       + sum-vat-base-sale-cur                                        d-slt-vat-cons-grp-fin.sale-vat-rubl       = d-slt-vat-cons-grp-fin.sale-vat-rubl       + sum-vat-rubl-sale-cur                                        d-slt-vat-cons-grp-fin.sale-vat-buyer-base = d-slt-vat-cons-grp-fin.sale-vat-buyer-base + sum-vat-base-buyer-cur                                       d-slt-vat-cons-grp-fin.sale-vat-buyer-rubl = d-slt-vat-cons-grp-fin.sale-vat-buyer-rubl + sum-vat-rubl-buyer-cur                                       d-slt-vat-cons-grp-fin.sale-slt-base       = d-slt-vat-cons-grp-fin.sale-slt-base       + sum-slt-base-sale-cur                                        d-slt-vat-cons-grp-fin.sale-slt-rubl       = d-slt-vat-cons-grp-fin.sale-slt-rubl       + sum-slt-rubl-sale-cur                                        d-slt-vat-cons-grp-fin.sale-road-tax-base  = d-slt-vat-cons-grp-fin.sale-road-tax-base  + sum-road-tax-base-sale-cur                                   d-slt-vat-cons-grp-fin.sale-road-tax-rubl  = d-slt-vat-cons-grp-fin.sale-road-tax-rubl  + sum-road-tax-rubl-sale-cur                                   d-slt-vat-cons-grp-fin.sale-excise-base    = d-slt-vat-cons-grp-fin.sale-excise-base    + sum-excise-base-sale-cur                                     d-slt-vat-cons-grp-fin.sale-excise-rubl    = d-slt-vat-cons-grp-fin.sale-excise-rubl    + sum-excise-rubl-sale-cur                                     d-slt-vat-cons-grp-fin.ov-base             = d-slt-vat-cons-grp-fin.ov-base             + (if varr-b = "base" then (sum-price-base-with-tax-sale-cur - sum-price-base-with-tax-sale) else (sum-price-rubl-with-tax-sale-cur - sum-price-rubl-with-tax-sale))                             d-slt-vat-cons-grp-fin.ov-vat              = d-slt-vat-cons-grp-fin.ov-vat              + (if varr-b = "base" then (sum-price-base-with-tax-sale-cur - sum-price-base-with-tax-sale) else (sum-price-rubl-with-tax-sale-cur - sum-price-rubl-with-tax-sale)) * bf_doc-line.vat-pc / (100 + bf_doc-line.vat-pc).
  end.
    if lookup( "d-supp-slts-vats-cons", use-table ) > 0 then do:
    find first d-supp-slts-vats-cons where
               d-supp-slts-vats-cons.supp-type  = ? and
               d-supp-slts-vats-cons.supp-code  = ? and
               d-supp-slts-vats-cons.vat-pc     = ? and
               d-supp-slts-vats-cons.slt-pc     = ? and
               d-supp-slts-vats-cons.purch-code = ? no-error.
    if not available d-supp-slts-vats-cons then do:
      create d-supp-slts-vats-cons.
      assign d-supp-slts-vats-cons.vat-pc     = ?
             d-supp-slts-vats-cons.slt-pc     = ?
             d-supp-slts-vats-cons.supp-type  = ?
             d-supp-slts-vats-cons.supp-code  = ?
             d-supp-slts-vats-cons.supp-name  = "пересортица по признакам"
             d-supp-slts-vats-cons.purch-code = ?
             d-supp-slts-vats-cons.purch-name = ?.
    end.
    assign d-supp-slts-vats-cons.fact-qnty           = 0                             d-supp-slts-vats-cons.acc-base            = 0                             d-supp-slts-vats-cons.acc-rubl            = 0                             d-supp-slts-vats-cons.acc-vat-base        = 0                             d-supp-slts-vats-cons.acc-vat-rubl        = 0                             d-supp-slts-vats-cons.acc-slt-base        = 0                             d-supp-slts-vats-cons.acc-slt-rubl        = 0                             d-supp-slts-vats-cons.acc-road-tax-base   = 0                             d-supp-slts-vats-cons.acc-road-tax-rubl   = 0                             d-supp-slts-vats-cons.acc-excise-base     = 0                             d-supp-slts-vats-cons.acc-excise-rubl     = 0                             d-supp-slts-vats-cons.acc-transport-base  = 0                             d-supp-slts-vats-cons.acc-transport-rubl  = 0                             d-supp-slts-vats-cons.acc-other-base      = 0                             d-supp-slts-vats-cons.acc-other-rubl      = 0                             d-supp-slts-vats-cons.pay-base            = d-supp-slts-vats-cons.pay-base            + sum-price-base-with-tax-sale                             d-supp-slts-vats-cons.pay-rubl            = d-supp-slts-vats-cons.pay-rubl            + sum-price-rubl-with-tax-sale                             d-supp-slts-vats-cons.no-vat-base         = d-supp-slts-vats-cons.no-vat-base         + sum-price-base-with-tax-sale - sum-vat-base-sale                             d-supp-slts-vats-cons.no-vat-rubl         = d-supp-slts-vats-cons.no-vat-rubl         + sum-price-rubl-with-tax-sale - sum-vat-rubl-sale                             d-supp-slts-vats-cons.vat-base            = d-supp-slts-vats-cons.vat-base            + sum-vat-base-sale                              d-supp-slts-vats-cons.vat-rubl            = d-supp-slts-vats-cons.vat-rubl            + sum-vat-rubl-sale                              d-supp-slts-vats-cons.vat-base-buyer      = d-supp-slts-vats-cons.vat-base-buyer      + sum-vat-base-buyer                             d-supp-slts-vats-cons.vat-rubl-buyer      = d-supp-slts-vats-cons.vat-rubl-buyer      + sum-vat-rubl-buyer                             d-supp-slts-vats-cons.slt-base            = d-supp-slts-vats-cons.slt-base            + sum-slt-base-sale                             d-supp-slts-vats-cons.slt-rubl            = d-supp-slts-vats-cons.slt-rubl            + sum-slt-rubl-sale                             d-supp-slts-vats-cons.road-tax            = d-supp-slts-vats-cons.road-tax            + (if varr-b = "base" then sum-road-tax-base-sale else sum-road-tax-rubl-sale)                             d-supp-slts-vats-cons.excise              = d-supp-slts-vats-cons.excise              + (if varr-b = "base" then sum-excise-base-sale   else sum-excise-rubl-sale )                             d-supp-slts-vats-cons.sale-base           = d-supp-slts-vats-cons.sale-base           + sum-price-base-with-tax-sale-cur                             d-supp-slts-vats-cons.sale-rubl           = d-supp-slts-vats-cons.sale-rubl           + sum-price-rubl-with-tax-sale-cur                             d-supp-slts-vats-cons.sale-vat-base       = d-supp-slts-vats-cons.sale-vat-base       + sum-vat-base-sale-cur                                        d-supp-slts-vats-cons.sale-vat-rubl       = d-supp-slts-vats-cons.sale-vat-rubl       + sum-vat-rubl-sale-cur                                        d-supp-slts-vats-cons.sale-vat-buyer-base = d-supp-slts-vats-cons.sale-vat-buyer-base + sum-vat-base-buyer-cur                                       d-supp-slts-vats-cons.sale-vat-buyer-rubl = d-supp-slts-vats-cons.sale-vat-buyer-rubl + sum-vat-rubl-buyer-cur                                       d-supp-slts-vats-cons.sale-slt-base       = d-supp-slts-vats-cons.sale-slt-base       + sum-slt-base-sale-cur                                        d-supp-slts-vats-cons.sale-slt-rubl       = d-supp-slts-vats-cons.sale-slt-rubl       + sum-slt-rubl-sale-cur                                        d-supp-slts-vats-cons.sale-road-tax-base  = d-supp-slts-vats-cons.sale-road-tax-base  + sum-road-tax-base-sale-cur                                   d-supp-slts-vats-cons.sale-road-tax-rubl  = d-supp-slts-vats-cons.sale-road-tax-rubl  + sum-road-tax-rubl-sale-cur                                   d-supp-slts-vats-cons.sale-excise-base    = d-supp-slts-vats-cons.sale-excise-base    + sum-excise-base-sale-cur                                     d-supp-slts-vats-cons.sale-excise-rubl    = d-supp-slts-vats-cons.sale-excise-rubl    + sum-excise-rubl-sale-cur                                     d-supp-slts-vats-cons.ov-base             = d-supp-slts-vats-cons.ov-base             + (if varr-b = "base" then (sum-price-base-with-tax-sale-cur - sum-price-base-with-tax-sale) else (sum-price-rubl-with-tax-sale-cur - sum-price-rubl-with-tax-sale))                             d-supp-slts-vats-cons.ov-vat              = d-supp-slts-vats-cons.ov-vat              + (if varr-b = "base" then (sum-price-base-with-tax-sale-cur - sum-price-base-with-tax-sale) else (sum-price-rubl-with-tax-sale-cur - sum-price-rubl-with-tax-sale)) * bf_doc-line.vat-pc / (100 + bf_doc-line.vat-pc).
  end.
    if lookup( "d-supp-slts-vats-cons-fin", use-table ) > 0 then do:
    find first d-supp-slts-vats-cons-fin where
               d-supp-slts-vats-cons-fin.supp-type     = ? and
               d-supp-slts-vats-cons-fin.supp-code     = ? and
               d-supp-slts-vats-cons-fin.vat-pc        = ? and
               d-supp-slts-vats-cons-fin.slt-pc        = ? and
               d-supp-slts-vats-cons-fin.purch-code    = ? and
               d-supp-slts-vats-cons-fin.contract-code = 0 no-error.
    if not available d-supp-slts-vats-cons-fin then do:
      create d-supp-slts-vats-cons-fin.
      assign d-supp-slts-vats-cons-fin.vat-pc        = ?
             d-supp-slts-vats-cons-fin.slt-pc        = ?
             d-supp-slts-vats-cons-fin.supp-type     = ?
             d-supp-slts-vats-cons-fin.supp-code     = ?
             d-supp-slts-vats-cons-fin.supp-name     = "пересортица по признакам"
             d-supp-slts-vats-cons-fin.purch-code    = ?
             d-supp-slts-vats-cons-fin.purch-name    = ?
             d-supp-slts-vats-cons-fin.contract-code = 0.
    end.
    assign d-supp-slts-vats-cons-fin.fact-qnty           = 0                             d-supp-slts-vats-cons-fin.acc-base            = 0                             d-supp-slts-vats-cons-fin.acc-rubl            = 0                             d-supp-slts-vats-cons-fin.acc-vat-base        = 0                             d-supp-slts-vats-cons-fin.acc-vat-rubl        = 0                             d-supp-slts-vats-cons-fin.acc-slt-base        = 0                             d-supp-slts-vats-cons-fin.acc-slt-rubl        = 0                             d-supp-slts-vats-cons-fin.acc-road-tax-base   = 0                             d-supp-slts-vats-cons-fin.acc-road-tax-rubl   = 0                             d-supp-slts-vats-cons-fin.acc-excise-base     = 0                             d-supp-slts-vats-cons-fin.acc-excise-rubl     = 0                             d-supp-slts-vats-cons-fin.acc-transport-base  = 0                             d-supp-slts-vats-cons-fin.acc-transport-rubl  = 0                             d-supp-slts-vats-cons-fin.acc-other-base      = 0                             d-supp-slts-vats-cons-fin.acc-other-rubl      = 0                             d-supp-slts-vats-cons-fin.pay-base            = d-supp-slts-vats-cons-fin.pay-base            + sum-price-base-with-tax-sale                             d-supp-slts-vats-cons-fin.pay-rubl            = d-supp-slts-vats-cons-fin.pay-rubl            + sum-price-rubl-with-tax-sale                             d-supp-slts-vats-cons-fin.no-vat-base         = d-supp-slts-vats-cons-fin.no-vat-base         + sum-price-base-with-tax-sale - sum-vat-base-sale                             d-supp-slts-vats-cons-fin.no-vat-rubl         = d-supp-slts-vats-cons-fin.no-vat-rubl         + sum-price-rubl-with-tax-sale - sum-vat-rubl-sale                             d-supp-slts-vats-cons-fin.vat-base            = d-supp-slts-vats-cons-fin.vat-base            + sum-vat-base-sale                              d-supp-slts-vats-cons-fin.vat-rubl            = d-supp-slts-vats-cons-fin.vat-rubl            + sum-vat-rubl-sale                              d-supp-slts-vats-cons-fin.vat-base-buyer      = d-supp-slts-vats-cons-fin.vat-base-buyer      + sum-vat-base-buyer                             d-supp-slts-vats-cons-fin.vat-rubl-buyer      = d-supp-slts-vats-cons-fin.vat-rubl-buyer      + sum-vat-rubl-buyer                             d-supp-slts-vats-cons-fin.slt-base            = d-supp-slts-vats-cons-fin.slt-base            + sum-slt-base-sale                             d-supp-slts-vats-cons-fin.slt-rubl            = d-supp-slts-vats-cons-fin.slt-rubl            + sum-slt-rubl-sale                             d-supp-slts-vats-cons-fin.road-tax            = d-supp-slts-vats-cons-fin.road-tax            + (if varr-b = "base" then sum-road-tax-base-sale else sum-road-tax-rubl-sale)                             d-supp-slts-vats-cons-fin.excise              = d-supp-slts-vats-cons-fin.excise              + (if varr-b = "base" then sum-excise-base-sale   else sum-excise-rubl-sale )                             d-supp-slts-vats-cons-fin.sale-base           = d-supp-slts-vats-cons-fin.sale-base           + sum-price-base-with-tax-sale-cur                             d-supp-slts-vats-cons-fin.sale-rubl           = d-supp-slts-vats-cons-fin.sale-rubl           + sum-price-rubl-with-tax-sale-cur                             d-supp-slts-vats-cons-fin.sale-vat-base       = d-supp-slts-vats-cons-fin.sale-vat-base       + sum-vat-base-sale-cur                                        d-supp-slts-vats-cons-fin.sale-vat-rubl       = d-supp-slts-vats-cons-fin.sale-vat-rubl       + sum-vat-rubl-sale-cur                                        d-supp-slts-vats-cons-fin.sale-vat-buyer-base = d-supp-slts-vats-cons-fin.sale-vat-buyer-base + sum-vat-base-buyer-cur                                       d-supp-slts-vats-cons-fin.sale-vat-buyer-rubl = d-supp-slts-vats-cons-fin.sale-vat-buyer-rubl + sum-vat-rubl-buyer-cur                                       d-supp-slts-vats-cons-fin.sale-slt-base       = d-supp-slts-vats-cons-fin.sale-slt-base       + sum-slt-base-sale-cur                                        d-supp-slts-vats-cons-fin.sale-slt-rubl       = d-supp-slts-vats-cons-fin.sale-slt-rubl       + sum-slt-rubl-sale-cur                                        d-supp-slts-vats-cons-fin.sale-road-tax-base  = d-supp-slts-vats-cons-fin.sale-road-tax-base  + sum-road-tax-base-sale-cur                                   d-supp-slts-vats-cons-fin.sale-road-tax-rubl  = d-supp-slts-vats-cons-fin.sale-road-tax-rubl  + sum-road-tax-rubl-sale-cur                                   d-supp-slts-vats-cons-fin.sale-excise-base    = d-supp-slts-vats-cons-fin.sale-excise-base    + sum-excise-base-sale-cur                                     d-supp-slts-vats-cons-fin.sale-excise-rubl    = d-supp-slts-vats-cons-fin.sale-excise-rubl    + sum-excise-rubl-sale-cur                                     d-supp-slts-vats-cons-fin.ov-base             = d-supp-slts-vats-cons-fin.ov-base             + (if varr-b = "base" then (sum-price-base-with-tax-sale-cur - sum-price-base-with-tax-sale) else (sum-price-rubl-with-tax-sale-cur - sum-price-rubl-with-tax-sale))                             d-supp-slts-vats-cons-fin.ov-vat              = d-supp-slts-vats-cons-fin.ov-vat              + (if varr-b = "base" then (sum-price-base-with-tax-sale-cur - sum-price-base-with-tax-sale) else (sum-price-rubl-with-tax-sale-cur - sum-price-rubl-with-tax-sale)) * bf_doc-line.vat-pc / (100 + bf_doc-line.vat-pc).
  end.
    if lookup( "d-slts-vats", use-table ) > 0 then do:
    find first d-slts-vats where
               d-slts-vats.vat-pc = ? and
               d-slts-vats.slt-pc = ? no-error.
    if not available d-slts-vats then do:
      create d-slts-vats.
      assign d-slts-vats.vat-pc = ?
             d-slts-vats.slt-pc = ?.
    end.
    assign d-slts-vats.fact-qnty           = 0                             d-slts-vats.acc-base            = 0                             d-slts-vats.acc-rubl            = 0                             d-slts-vats.acc-vat-base        = 0                             d-slts-vats.acc-vat-rubl        = 0                             d-slts-vats.acc-slt-base        = 0                             d-slts-vats.acc-slt-rubl        = 0                             d-slts-vats.acc-road-tax-base   = 0                             d-slts-vats.acc-road-tax-rubl   = 0                             d-slts-vats.acc-excise-base     = 0                             d-slts-vats.acc-excise-rubl     = 0                             d-slts-vats.acc-transport-base  = 0                             d-slts-vats.acc-transport-rubl  = 0                             d-slts-vats.acc-other-base      = 0                             d-slts-vats.acc-other-rubl      = 0                             d-slts-vats.pay-base            = d-slts-vats.pay-base            + sum-price-base-with-tax-sale                             d-slts-vats.pay-rubl            = d-slts-vats.pay-rubl            + sum-price-rubl-with-tax-sale                             d-slts-vats.no-vat-base         = d-slts-vats.no-vat-base         + sum-price-base-with-tax-sale - sum-vat-base-sale                             d-slts-vats.no-vat-rubl         = d-slts-vats.no-vat-rubl         + sum-price-rubl-with-tax-sale - sum-vat-rubl-sale                             d-slts-vats.vat-base            = d-slts-vats.vat-base            + sum-vat-base-sale                              d-slts-vats.vat-rubl            = d-slts-vats.vat-rubl            + sum-vat-rubl-sale                              d-slts-vats.vat-base-buyer      = d-slts-vats.vat-base-buyer      + sum-vat-base-buyer                             d-slts-vats.vat-rubl-buyer      = d-slts-vats.vat-rubl-buyer      + sum-vat-rubl-buyer                             d-slts-vats.slt-base            = d-slts-vats.slt-base            + sum-slt-base-sale                             d-slts-vats.slt-rubl            = d-slts-vats.slt-rubl            + sum-slt-rubl-sale                             d-slts-vats.road-tax            = d-slts-vats.road-tax            + (if varr-b = "base" then sum-road-tax-base-sale else sum-road-tax-rubl-sale)                             d-slts-vats.excise              = d-slts-vats.excise              + (if varr-b = "base" then sum-excise-base-sale   else sum-excise-rubl-sale )                             d-slts-vats.sale-base           = d-slts-vats.sale-base           + sum-price-base-with-tax-sale-cur                             d-slts-vats.sale-rubl           = d-slts-vats.sale-rubl           + sum-price-rubl-with-tax-sale-cur                             d-slts-vats.sale-vat-base       = d-slts-vats.sale-vat-base       + sum-vat-base-sale-cur                                        d-slts-vats.sale-vat-rubl       = d-slts-vats.sale-vat-rubl       + sum-vat-rubl-sale-cur                                        d-slts-vats.sale-vat-buyer-base = d-slts-vats.sale-vat-buyer-base + sum-vat-base-buyer-cur                                       d-slts-vats.sale-vat-buyer-rubl = d-slts-vats.sale-vat-buyer-rubl + sum-vat-rubl-buyer-cur                                       d-slts-vats.sale-slt-base       = d-slts-vats.sale-slt-base       + sum-slt-base-sale-cur                                        d-slts-vats.sale-slt-rubl       = d-slts-vats.sale-slt-rubl       + sum-slt-rubl-sale-cur                                        d-slts-vats.sale-road-tax-base  = d-slts-vats.sale-road-tax-base  + sum-road-tax-base-sale-cur                                   d-slts-vats.sale-road-tax-rubl  = d-slts-vats.sale-road-tax-rubl  + sum-road-tax-rubl-sale-cur                                   d-slts-vats.sale-excise-base    = d-slts-vats.sale-excise-base    + sum-excise-base-sale-cur                                     d-slts-vats.sale-excise-rubl    = d-slts-vats.sale-excise-rubl    + sum-excise-rubl-sale-cur                                     d-slts-vats.ov-base             = d-slts-vats.ov-base             + (if varr-b = "base" then (sum-price-base-with-tax-sale-cur - sum-price-base-with-tax-sale) else (sum-price-rubl-with-tax-sale-cur - sum-price-rubl-with-tax-sale))                             d-slts-vats.ov-vat              = d-slts-vats.ov-vat              + (if varr-b = "base" then (sum-price-base-with-tax-sale-cur - sum-price-base-with-tax-sale) else (sum-price-rubl-with-tax-sale-cur - sum-price-rubl-with-tax-sale)) * bf_doc-line.vat-pc / (100 + bf_doc-line.vat-pc).
  end.
    if lookup( "d-slts-vats-cons", use-table ) > 0 then do:
    find first d-slts-vats-cons where
               d-slts-vats-cons.vat-pc     = ? and
               d-slts-vats-cons.slt-pc     = ? and
               d-slts-vats-cons.purch-code = ? no-error.
    if not available d-slts-vats-cons then do:
      create d-slts-vats-cons.
      assign d-slts-vats-cons.vat-pc     = ?
             d-slts-vats-cons.slt-pc     = ?
             d-slts-vats-cons.purch-code = ?
             d-slts-vats-cons.purch-name = ?.
    end.
    assign d-slts-vats-cons.fact-qnty           = 0                             d-slts-vats-cons.acc-base            = 0                             d-slts-vats-cons.acc-rubl            = 0                             d-slts-vats-cons.acc-vat-base        = 0                             d-slts-vats-cons.acc-vat-rubl        = 0                             d-slts-vats-cons.acc-slt-base        = 0                             d-slts-vats-cons.acc-slt-rubl        = 0                             d-slts-vats-cons.acc-road-tax-base   = 0                             d-slts-vats-cons.acc-road-tax-rubl   = 0                             d-slts-vats-cons.acc-excise-base     = 0                             d-slts-vats-cons.acc-excise-rubl     = 0                             d-slts-vats-cons.acc-transport-base  = 0                             d-slts-vats-cons.acc-transport-rubl  = 0                             d-slts-vats-cons.acc-other-base      = 0                             d-slts-vats-cons.acc-other-rubl      = 0                             d-slts-vats-cons.pay-base            = d-slts-vats-cons.pay-base            + sum-price-base-with-tax-sale                             d-slts-vats-cons.pay-rubl            = d-slts-vats-cons.pay-rubl            + sum-price-rubl-with-tax-sale                             d-slts-vats-cons.no-vat-base         = d-slts-vats-cons.no-vat-base         + sum-price-base-with-tax-sale - sum-vat-base-sale                             d-slts-vats-cons.no-vat-rubl         = d-slts-vats-cons.no-vat-rubl         + sum-price-rubl-with-tax-sale - sum-vat-rubl-sale                             d-slts-vats-cons.vat-base            = d-slts-vats-cons.vat-base            + sum-vat-base-sale                              d-slts-vats-cons.vat-rubl            = d-slts-vats-cons.vat-rubl            + sum-vat-rubl-sale                              d-slts-vats-cons.vat-base-buyer      = d-slts-vats-cons.vat-base-buyer      + sum-vat-base-buyer                             d-slts-vats-cons.vat-rubl-buyer      = d-slts-vats-cons.vat-rubl-buyer      + sum-vat-rubl-buyer                             d-slts-vats-cons.slt-base            = d-slts-vats-cons.slt-base            + sum-slt-base-sale                             d-slts-vats-cons.slt-rubl            = d-slts-vats-cons.slt-rubl            + sum-slt-rubl-sale                             d-slts-vats-cons.road-tax            = d-slts-vats-cons.road-tax            + (if varr-b = "base" then sum-road-tax-base-sale else sum-road-tax-rubl-sale)                             d-slts-vats-cons.excise              = d-slts-vats-cons.excise              + (if varr-b = "base" then sum-excise-base-sale   else sum-excise-rubl-sale )                             d-slts-vats-cons.sale-base           = d-slts-vats-cons.sale-base           + sum-price-base-with-tax-sale-cur                             d-slts-vats-cons.sale-rubl           = d-slts-vats-cons.sale-rubl           + sum-price-rubl-with-tax-sale-cur                             d-slts-vats-cons.sale-vat-base       = d-slts-vats-cons.sale-vat-base       + sum-vat-base-sale-cur                                        d-slts-vats-cons.sale-vat-rubl       = d-slts-vats-cons.sale-vat-rubl       + sum-vat-rubl-sale-cur                                        d-slts-vats-cons.sale-vat-buyer-base = d-slts-vats-cons.sale-vat-buyer-base + sum-vat-base-buyer-cur                                       d-slts-vats-cons.sale-vat-buyer-rubl = d-slts-vats-cons.sale-vat-buyer-rubl + sum-vat-rubl-buyer-cur                                       d-slts-vats-cons.sale-slt-base       = d-slts-vats-cons.sale-slt-base       + sum-slt-base-sale-cur                                        d-slts-vats-cons.sale-slt-rubl       = d-slts-vats-cons.sale-slt-rubl       + sum-slt-rubl-sale-cur                                        d-slts-vats-cons.sale-road-tax-base  = d-slts-vats-cons.sale-road-tax-base  + sum-road-tax-base-sale-cur                                   d-slts-vats-cons.sale-road-tax-rubl  = d-slts-vats-cons.sale-road-tax-rubl  + sum-road-tax-rubl-sale-cur                                   d-slts-vats-cons.sale-excise-base    = d-slts-vats-cons.sale-excise-base    + sum-excise-base-sale-cur                                     d-slts-vats-cons.sale-excise-rubl    = d-slts-vats-cons.sale-excise-rubl    + sum-excise-rubl-sale-cur                                     d-slts-vats-cons.ov-base             = d-slts-vats-cons.ov-base             + (if varr-b = "base" then (sum-price-base-with-tax-sale-cur - sum-price-base-with-tax-sale) else (sum-price-rubl-with-tax-sale-cur - sum-price-rubl-with-tax-sale))                             d-slts-vats-cons.ov-vat              = d-slts-vats-cons.ov-vat              + (if varr-b = "base" then (sum-price-base-with-tax-sale-cur - sum-price-base-with-tax-sale) else (sum-price-rubl-with-tax-sale-cur - sum-price-rubl-with-tax-sale)) * bf_doc-line.vat-pc / (100 + bf_doc-line.vat-pc).
  end.
    if lookup( "d-slts-vats-cons-fin", use-table ) > 0 then do:
    find first d-slts-vats-cons-fin where
               d-slts-vats-cons-fin.vat-pc        = ? and
               d-slts-vats-cons-fin.slt-pc        = ? and
               d-slts-vats-cons-fin.contract-code = 0 and
               d-slts-vats-cons-fin.purch-code    = ? no-error.
    if not available d-slts-vats-cons-fin then do:
      create d-slts-vats-cons-fin.
      assign d-slts-vats-cons-fin.vat-pc        = ?
             d-slts-vats-cons-fin.slt-pc        = ?
             d-slts-vats-cons-fin.contract-code = 0
             d-slts-vats-cons-fin.purch-code    = ?
             d-slts-vats-cons-fin.purch-name    = ?.
    end.
    assign d-slts-vats-cons-fin.fact-qnty           = 0                             d-slts-vats-cons-fin.acc-base            = 0                             d-slts-vats-cons-fin.acc-rubl            = 0                             d-slts-vats-cons-fin.acc-vat-base        = 0                             d-slts-vats-cons-fin.acc-vat-rubl        = 0                             d-slts-vats-cons-fin.acc-slt-base        = 0                             d-slts-vats-cons-fin.acc-slt-rubl        = 0                             d-slts-vats-cons-fin.acc-road-tax-base   = 0                             d-slts-vats-cons-fin.acc-road-tax-rubl   = 0                             d-slts-vats-cons-fin.acc-excise-base     = 0                             d-slts-vats-cons-fin.acc-excise-rubl     = 0                             d-slts-vats-cons-fin.acc-transport-base  = 0                             d-slts-vats-cons-fin.acc-transport-rubl  = 0                             d-slts-vats-cons-fin.acc-other-base      = 0                             d-slts-vats-cons-fin.acc-other-rubl      = 0                             d-slts-vats-cons-fin.pay-base            = d-slts-vats-cons-fin.pay-base            + sum-price-base-with-tax-sale                             d-slts-vats-cons-fin.pay-rubl            = d-slts-vats-cons-fin.pay-rubl            + sum-price-rubl-with-tax-sale                             d-slts-vats-cons-fin.no-vat-base         = d-slts-vats-cons-fin.no-vat-base         + sum-price-base-with-tax-sale - sum-vat-base-sale                             d-slts-vats-cons-fin.no-vat-rubl         = d-slts-vats-cons-fin.no-vat-rubl         + sum-price-rubl-with-tax-sale - sum-vat-rubl-sale                             d-slts-vats-cons-fin.vat-base            = d-slts-vats-cons-fin.vat-base            + sum-vat-base-sale                              d-slts-vats-cons-fin.vat-rubl            = d-slts-vats-cons-fin.vat-rubl            + sum-vat-rubl-sale                              d-slts-vats-cons-fin.vat-base-buyer      = d-slts-vats-cons-fin.vat-base-buyer      + sum-vat-base-buyer                             d-slts-vats-cons-fin.vat-rubl-buyer      = d-slts-vats-cons-fin.vat-rubl-buyer      + sum-vat-rubl-buyer                             d-slts-vats-cons-fin.slt-base            = d-slts-vats-cons-fin.slt-base            + sum-slt-base-sale                             d-slts-vats-cons-fin.slt-rubl            = d-slts-vats-cons-fin.slt-rubl            + sum-slt-rubl-sale                             d-slts-vats-cons-fin.road-tax            = d-slts-vats-cons-fin.road-tax            + (if varr-b = "base" then sum-road-tax-base-sale else sum-road-tax-rubl-sale)                             d-slts-vats-cons-fin.excise              = d-slts-vats-cons-fin.excise              + (if varr-b = "base" then sum-excise-base-sale   else sum-excise-rubl-sale )                             d-slts-vats-cons-fin.sale-base           = d-slts-vats-cons-fin.sale-base           + sum-price-base-with-tax-sale-cur                             d-slts-vats-cons-fin.sale-rubl           = d-slts-vats-cons-fin.sale-rubl           + sum-price-rubl-with-tax-sale-cur                             d-slts-vats-cons-fin.sale-vat-base       = d-slts-vats-cons-fin.sale-vat-base       + sum-vat-base-sale-cur                                        d-slts-vats-cons-fin.sale-vat-rubl       = d-slts-vats-cons-fin.sale-vat-rubl       + sum-vat-rubl-sale-cur                                        d-slts-vats-cons-fin.sale-vat-buyer-base = d-slts-vats-cons-fin.sale-vat-buyer-base + sum-vat-base-buyer-cur                                       d-slts-vats-cons-fin.sale-vat-buyer-rubl = d-slts-vats-cons-fin.sale-vat-buyer-rubl + sum-vat-rubl-buyer-cur                                       d-slts-vats-cons-fin.sale-slt-base       = d-slts-vats-cons-fin.sale-slt-base       + sum-slt-base-sale-cur                                        d-slts-vats-cons-fin.sale-slt-rubl       = d-slts-vats-cons-fin.sale-slt-rubl       + sum-slt-rubl-sale-cur                                        d-slts-vats-cons-fin.sale-road-tax-base  = d-slts-vats-cons-fin.sale-road-tax-base  + sum-road-tax-base-sale-cur                                   d-slts-vats-cons-fin.sale-road-tax-rubl  = d-slts-vats-cons-fin.sale-road-tax-rubl  + sum-road-tax-rubl-sale-cur                                   d-slts-vats-cons-fin.sale-excise-base    = d-slts-vats-cons-fin.sale-excise-base    + sum-excise-base-sale-cur                                     d-slts-vats-cons-fin.sale-excise-rubl    = d-slts-vats-cons-fin.sale-excise-rubl    + sum-excise-rubl-sale-cur                                     d-slts-vats-cons-fin.ov-base             = d-slts-vats-cons-fin.ov-base             + (if varr-b = "base" then (sum-price-base-with-tax-sale-cur - sum-price-base-with-tax-sale) else (sum-price-rubl-with-tax-sale-cur - sum-price-rubl-with-tax-sale))                             d-slts-vats-cons-fin.ov-vat              = d-slts-vats-cons-fin.ov-vat              + (if varr-b = "base" then (sum-price-base-with-tax-sale-cur - sum-price-base-with-tax-sale) else (sum-price-rubl-with-tax-sale-cur - sum-price-rubl-with-tax-sale)) * bf_doc-line.vat-pc / (100 + bf_doc-line.vat-pc).
  end.
    if lookup( "d-slts-vats-cons-grp", use-table ) > 0 then do:
    find first d-slts-vats-cons-grp where
               d-slts-vats-cons-grp.vat-pc     = ?                 and
               d-slts-vats-cons-grp.slt-pc     = ?                 and
               d-slts-vats-cons-grp.purch-code = ?                 and
               d-slts-vats-cons-grp.grp-code   = bf_goods.grp-code no-error.
    if not available d-slts-vats-cons-grp then do:
      create d-slts-vats-cons-grp.
      assign d-slts-vats-cons-grp.vat-pc     = ?
             d-slts-vats-cons-grp.slt-pc     = ?
             d-slts-vats-cons-grp.purch-code = ?
             d-slts-vats-cons-grp.purch-name = ?
             d-slts-vats-cons-grp.grp-code   = bf_goods.grp-code
             d-slts-vats-cons-grp.grp-name   = varfull-name-grp.
    end.
    assign d-slts-vats-cons-grp.fact-qnty           = 0                             d-slts-vats-cons-grp.acc-base            = 0                             d-slts-vats-cons-grp.acc-rubl            = 0                             d-slts-vats-cons-grp.acc-vat-base        = 0                             d-slts-vats-cons-grp.acc-vat-rubl        = 0                             d-slts-vats-cons-grp.acc-slt-base        = 0                             d-slts-vats-cons-grp.acc-slt-rubl        = 0                             d-slts-vats-cons-grp.acc-road-tax-base   = 0                             d-slts-vats-cons-grp.acc-road-tax-rubl   = 0                             d-slts-vats-cons-grp.acc-excise-base     = 0                             d-slts-vats-cons-grp.acc-excise-rubl     = 0                             d-slts-vats-cons-grp.acc-transport-base  = 0                             d-slts-vats-cons-grp.acc-transport-rubl  = 0                             d-slts-vats-cons-grp.acc-other-base      = 0                             d-slts-vats-cons-grp.acc-other-rubl      = 0                             d-slts-vats-cons-grp.pay-base            = d-slts-vats-cons-grp.pay-base            + sum-price-base-with-tax-sale                             d-slts-vats-cons-grp.pay-rubl            = d-slts-vats-cons-grp.pay-rubl            + sum-price-rubl-with-tax-sale                             d-slts-vats-cons-grp.no-vat-base         = d-slts-vats-cons-grp.no-vat-base         + sum-price-base-with-tax-sale - sum-vat-base-sale                             d-slts-vats-cons-grp.no-vat-rubl         = d-slts-vats-cons-grp.no-vat-rubl         + sum-price-rubl-with-tax-sale - sum-vat-rubl-sale                             d-slts-vats-cons-grp.vat-base            = d-slts-vats-cons-grp.vat-base            + sum-vat-base-sale                              d-slts-vats-cons-grp.vat-rubl            = d-slts-vats-cons-grp.vat-rubl            + sum-vat-rubl-sale                              d-slts-vats-cons-grp.vat-base-buyer      = d-slts-vats-cons-grp.vat-base-buyer      + sum-vat-base-buyer                             d-slts-vats-cons-grp.vat-rubl-buyer      = d-slts-vats-cons-grp.vat-rubl-buyer      + sum-vat-rubl-buyer                             d-slts-vats-cons-grp.slt-base            = d-slts-vats-cons-grp.slt-base            + sum-slt-base-sale                             d-slts-vats-cons-grp.slt-rubl            = d-slts-vats-cons-grp.slt-rubl            + sum-slt-rubl-sale                             d-slts-vats-cons-grp.road-tax            = d-slts-vats-cons-grp.road-tax            + (if varr-b = "base" then sum-road-tax-base-sale else sum-road-tax-rubl-sale)                             d-slts-vats-cons-grp.excise              = d-slts-vats-cons-grp.excise              + (if varr-b = "base" then sum-excise-base-sale   else sum-excise-rubl-sale )                             d-slts-vats-cons-grp.sale-base           = d-slts-vats-cons-grp.sale-base           + sum-price-base-with-tax-sale-cur                             d-slts-vats-cons-grp.sale-rubl           = d-slts-vats-cons-grp.sale-rubl           + sum-price-rubl-with-tax-sale-cur                             d-slts-vats-cons-grp.sale-vat-base       = d-slts-vats-cons-grp.sale-vat-base       + sum-vat-base-sale-cur                                        d-slts-vats-cons-grp.sale-vat-rubl       = d-slts-vats-cons-grp.sale-vat-rubl       + sum-vat-rubl-sale-cur                                        d-slts-vats-cons-grp.sale-vat-buyer-base = d-slts-vats-cons-grp.sale-vat-buyer-base + sum-vat-base-buyer-cur                                       d-slts-vats-cons-grp.sale-vat-buyer-rubl = d-slts-vats-cons-grp.sale-vat-buyer-rubl + sum-vat-rubl-buyer-cur                                       d-slts-vats-cons-grp.sale-slt-base       = d-slts-vats-cons-grp.sale-slt-base       + sum-slt-base-sale-cur                                        d-slts-vats-cons-grp.sale-slt-rubl       = d-slts-vats-cons-grp.sale-slt-rubl       + sum-slt-rubl-sale-cur                                        d-slts-vats-cons-grp.sale-road-tax-base  = d-slts-vats-cons-grp.sale-road-tax-base  + sum-road-tax-base-sale-cur                                   d-slts-vats-cons-grp.sale-road-tax-rubl  = d-slts-vats-cons-grp.sale-road-tax-rubl  + sum-road-tax-rubl-sale-cur                                   d-slts-vats-cons-grp.sale-excise-base    = d-slts-vats-cons-grp.sale-excise-base    + sum-excise-base-sale-cur                                     d-slts-vats-cons-grp.sale-excise-rubl    = d-slts-vats-cons-grp.sale-excise-rubl    + sum-excise-rubl-sale-cur                                     d-slts-vats-cons-grp.ov-base             = d-slts-vats-cons-grp.ov-base             + (if varr-b = "base" then (sum-price-base-with-tax-sale-cur - sum-price-base-with-tax-sale) else (sum-price-rubl-with-tax-sale-cur - sum-price-rubl-with-tax-sale))                             d-slts-vats-cons-grp.ov-vat              = d-slts-vats-cons-grp.ov-vat              + (if varr-b = "base" then (sum-price-base-with-tax-sale-cur - sum-price-base-with-tax-sale) else (sum-price-rubl-with-tax-sale-cur - sum-price-rubl-with-tax-sale)) * bf_doc-line.vat-pc / (100 + bf_doc-line.vat-pc).
  end.
    if lookup( "d-slts-vats-cons-grp-fin", use-table ) > 0 then do:
    find first d-slts-vats-cons-grp-fin where
               d-slts-vats-cons-grp-fin.vat-pc        = ?                 and
               d-slts-vats-cons-grp-fin.slt-pc        = ?                 and
               d-slts-vats-cons-grp-fin.purch-code    = ?                 and
               d-slts-vats-cons-grp-fin.contract-code = 0                 and
               d-slts-vats-cons-grp-fin.grp-code      = bf_goods.grp-code no-error.
    if not available d-slts-vats-cons-grp-fin then do:
      create d-slts-vats-cons-grp-fin.
      assign d-slts-vats-cons-grp-fin.vat-pc        = ?
             d-slts-vats-cons-grp-fin.slt-pc        = ?
             d-slts-vats-cons-grp-fin.purch-code    = ?
             d-slts-vats-cons-grp-fin.purch-name    = ?
             d-slts-vats-cons-grp-fin.contract-code = 0
             d-slts-vats-cons-grp-fin.grp-code      = bf_goods.grp-code
             d-slts-vats-cons-grp-fin.grp-name      = varfull-name-grp.
    end.
    assign d-slts-vats-cons-grp-fin.fact-qnty           = 0                             d-slts-vats-cons-grp-fin.acc-base            = 0                             d-slts-vats-cons-grp-fin.acc-rubl            = 0                             d-slts-vats-cons-grp-fin.acc-vat-base        = 0                             d-slts-vats-cons-grp-fin.acc-vat-rubl        = 0                             d-slts-vats-cons-grp-fin.acc-slt-base        = 0                             d-slts-vats-cons-grp-fin.acc-slt-rubl        = 0                             d-slts-vats-cons-grp-fin.acc-road-tax-base   = 0                             d-slts-vats-cons-grp-fin.acc-road-tax-rubl   = 0                             d-slts-vats-cons-grp-fin.acc-excise-base     = 0                             d-slts-vats-cons-grp-fin.acc-excise-rubl     = 0                             d-slts-vats-cons-grp-fin.acc-transport-base  = 0                             d-slts-vats-cons-grp-fin.acc-transport-rubl  = 0                             d-slts-vats-cons-grp-fin.acc-other-base      = 0                             d-slts-vats-cons-grp-fin.acc-other-rubl      = 0                             d-slts-vats-cons-grp-fin.pay-base            = d-slts-vats-cons-grp-fin.pay-base            + sum-price-base-with-tax-sale                             d-slts-vats-cons-grp-fin.pay-rubl            = d-slts-vats-cons-grp-fin.pay-rubl            + sum-price-rubl-with-tax-sale                             d-slts-vats-cons-grp-fin.no-vat-base         = d-slts-vats-cons-grp-fin.no-vat-base         + sum-price-base-with-tax-sale - sum-vat-base-sale                             d-slts-vats-cons-grp-fin.no-vat-rubl         = d-slts-vats-cons-grp-fin.no-vat-rubl         + sum-price-rubl-with-tax-sale - sum-vat-rubl-sale                             d-slts-vats-cons-grp-fin.vat-base            = d-slts-vats-cons-grp-fin.vat-base            + sum-vat-base-sale                              d-slts-vats-cons-grp-fin.vat-rubl            = d-slts-vats-cons-grp-fin.vat-rubl            + sum-vat-rubl-sale                              d-slts-vats-cons-grp-fin.vat-base-buyer      = d-slts-vats-cons-grp-fin.vat-base-buyer      + sum-vat-base-buyer                             d-slts-vats-cons-grp-fin.vat-rubl-buyer      = d-slts-vats-cons-grp-fin.vat-rubl-buyer      + sum-vat-rubl-buyer                             d-slts-vats-cons-grp-fin.slt-base            = d-slts-vats-cons-grp-fin.slt-base            + sum-slt-base-sale                             d-slts-vats-cons-grp-fin.slt-rubl            = d-slts-vats-cons-grp-fin.slt-rubl            + sum-slt-rubl-sale                             d-slts-vats-cons-grp-fin.road-tax            = d-slts-vats-cons-grp-fin.road-tax            + (if varr-b = "base" then sum-road-tax-base-sale else sum-road-tax-rubl-sale)                             d-slts-vats-cons-grp-fin.excise              = d-slts-vats-cons-grp-fin.excise              + (if varr-b = "base" then sum-excise-base-sale   else sum-excise-rubl-sale )                             d-slts-vats-cons-grp-fin.sale-base           = d-slts-vats-cons-grp-fin.sale-base           + sum-price-base-with-tax-sale-cur                             d-slts-vats-cons-grp-fin.sale-rubl           = d-slts-vats-cons-grp-fin.sale-rubl           + sum-price-rubl-with-tax-sale-cur                             d-slts-vats-cons-grp-fin.sale-vat-base       = d-slts-vats-cons-grp-fin.sale-vat-base       + sum-vat-base-sale-cur                                        d-slts-vats-cons-grp-fin.sale-vat-rubl       = d-slts-vats-cons-grp-fin.sale-vat-rubl       + sum-vat-rubl-sale-cur                                        d-slts-vats-cons-grp-fin.sale-vat-buyer-base = d-slts-vats-cons-grp-fin.sale-vat-buyer-base + sum-vat-base-buyer-cur                                       d-slts-vats-cons-grp-fin.sale-vat-buyer-rubl = d-slts-vats-cons-grp-fin.sale-vat-buyer-rubl + sum-vat-rubl-buyer-cur                                       d-slts-vats-cons-grp-fin.sale-slt-base       = d-slts-vats-cons-grp-fin.sale-slt-base       + sum-slt-base-sale-cur                                        d-slts-vats-cons-grp-fin.sale-slt-rubl       = d-slts-vats-cons-grp-fin.sale-slt-rubl       + sum-slt-rubl-sale-cur                                        d-slts-vats-cons-grp-fin.sale-road-tax-base  = d-slts-vats-cons-grp-fin.sale-road-tax-base  + sum-road-tax-base-sale-cur                                   d-slts-vats-cons-grp-fin.sale-road-tax-rubl  = d-slts-vats-cons-grp-fin.sale-road-tax-rubl  + sum-road-tax-rubl-sale-cur                                   d-slts-vats-cons-grp-fin.sale-excise-base    = d-slts-vats-cons-grp-fin.sale-excise-base    + sum-excise-base-sale-cur                                     d-slts-vats-cons-grp-fin.sale-excise-rubl    = d-slts-vats-cons-grp-fin.sale-excise-rubl    + sum-excise-rubl-sale-cur                                     d-slts-vats-cons-grp-fin.ov-base             = d-slts-vats-cons-grp-fin.ov-base             + (if varr-b = "base" then (sum-price-base-with-tax-sale-cur - sum-price-base-with-tax-sale) else (sum-price-rubl-with-tax-sale-cur - sum-price-rubl-with-tax-sale))                             d-slts-vats-cons-grp-fin.ov-vat              = d-slts-vats-cons-grp-fin.ov-vat              + (if varr-b = "base" then (sum-price-base-with-tax-sale-cur - sum-price-base-with-tax-sale) else (sum-price-rubl-with-tax-sale-cur - sum-price-rubl-with-tax-sale)) * bf_doc-line.vat-pc / (100 + bf_doc-line.vat-pc).
  end.
  return.
end.
end.
end procedure.
